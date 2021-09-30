--[Stocky HotFix Version]=407
DELETE FROM Versioncontrol WHERE Hotfixid='407'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('407','3.0.0.0','D','2013-09-05','2013-09-05','2013-09-05',convert(varchar(11),getdate()),'PARLE-Major: Product Release July CR')
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and name='UtilityProcess')
DROP TABLE UtilityProcess
GO
CREATE TABLE UtilityProcess(
	[ProcId] [int] NULL,
	[ProcessName] [varchar](100) NULL,
	[ProcessPath] [varchar](500) NULL,
	[ProcessType] [varchar](20) NULL,
	[ConfigExists] [tinyint] NULL,
	[ModuleId] [varchar](100) NULL,
	[ModuleName] [varchar](200) NULL,
	[Mandatory] [int] NULL,
	[DependExe] [int] NULL,
	[VersionId]	Varchar(10),
	[ProcessHandle] TinyInt
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_DownloadedDetails')
DROP TABLE Cs2Cn_Prk_DownloadedDetails
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DownloadedDetails](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100),
	[Process] [nvarchar](100),
	[Detail1] [nvarchar](100),
	[Detail2] [nvarchar](100),
	[Detail3] [nvarchar](100),
	[Detail4] [nvarchar](100),
	[Detail5] [nvarchar](100),
	[Detail6] [nvarchar](100),
	[Detail7] [nvarchar](100),
	[Detail8] [nvarchar](100),
	[Detail9] [nvarchar](100),
	[Detail10] [nvarchar](100),
	[DownloadedDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10),
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) 
GO
IF NOT EXISTS (SELECT NAME FROM SysObjects WHERE Xtype='U' AND NAME='Sync_Master')
BEGIN
	CREATE TABLE Sync_Master
	(
		SyncId		NUMERIC(38,0),
		SyncDate	DATETIME
	)
END
GO
IF NOT EXISTS(SELECT NAME FROM SysObjects WHERE Xtype='U' AND NAME='SyncCounter')
BEGIN
	CREATE TABLE SyncCounter
	(
		TabName			NVARCHAR(20),
		CurrValue		NUMERIC(38,0),
		ModuleName		NVARCHAR(50),
		CurrYear		INT,
		Availability	INT,
		LastModBy		INT,
		LastModDate		DATETIME,
		AuthId			INT,
		AuthDate		DATETIME
	)
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DefendRestore')
BEGIN
	CREATE TABLE DefendRestore
	(
		AccessCode nVarchar(400),
		LastModDate DateTime,
		DbStatus TinyInt,
		ReqId int
	)
END
GO
IF NOT EXISTS (SELECT NAME FROM SysObjects WHERE Xtype='U' AND NAME='Sync_RecordDetails')
BEGIN
	CREATE TABLE Sync_RecordDetails
	(
		DistCode		NVARCHAR(25),
		SyncId			NUMERIC(38,0),
		SyncDate		DATETIME,
		ProcessName		NVARCHAR(100),
		RecCount		NUMERIC(18,0)
	)
END
GO
IF NOT EXISTS(SELECT * FROM Sysobjects WHERE Name ='Cs2Cn_Prk_DBUnlockDetails' AND Xtype = 'U')
BEGIN
CREATE TABLE Cs2Cn_Prk_DBUnlockDetails
(
	DistCode nvarchar(100),
	SyncId numeric(38,0),
	HotFixId numeric(38,0),
	IPAddress nvarchar(50),
	Reason nvarchar(100),
	Remarks nvarchar(200),
	DBUnlockStatus int,
	UploadDate datetime,
	UploadFlag nvarchar(5)
) 
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Users') and Name='HostName')
BEGIN
	ALTER TABLE Users ADD  HostName Varchar(100) DEFAULT '' WITH VALUES
END
GO
DELETE FROM UTILITYPROCESS
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (1,'Core Stocky.Exe','App.Path','EXE',0,'','',0,0,'3.0.0.0',0)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (2,'ScriptUpdater.Exe','App.Path','EXE',0,'','',1,0,'0',1)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (3,'Sync.Exe','App.Path','EXE',1,'GENCONFIG23','General Configuration',1,0,'PV.0.0.2',0)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (4,'BBoard.exe','App.Path','EXE',0,'','',1,0,'0',1)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (5,'Auto Deployment.exe','App.Path','EXE',0,'','',1,0,'0',0)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (6,'CSUpdates Alert.exe','App.Path','EXE',0,'','',1,0,'0',0)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DefendRestore')
DROP TABLE DefendRestore
GO
CREATE TABLE [DefendRestore](
	[AccessCode] [nvarchar](400) NULL,
	[LastModDate] [datetime] NULL ,
	[DbStatus] [tinyint] NULL,
	[ReqId] [int] NULL
	--[CSLockStatus] [tinyint] NULL
	--[CCLockStatus] [tinyint] NULL,
	--[IniDecryptString] [varchar](3000) NULL,
	--[IniEncryptString] [varchar](3000) NULL,
	--[ActualEncryptString] [varchar](3000) NULL,
	--[FilePath] [varchar](3000) NULL,
	--[HostName] [varchar](100) NULL
)
GO
--Murugan Sir
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='CSLockStatus')
BEGIN
	ALTER TABLE Defendrestore ADD  CSLockStatus TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='CCLockStatus')
BEGIN
	ALTER TABLE Defendrestore ADD  CCLockStatus TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='IniDecryptString')
BEGIN
	ALTER TABLE Defendrestore ADD  IniDecryptString Varchar(3000) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='IniEncryptString')
BEGIN
	ALTER TABLE Defendrestore ADD  IniEncryptString Varchar(3000) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='ActualEncryptString')
BEGIN
	ALTER TABLE Defendrestore ADD  ActualEncryptString Varchar(3000) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='FilePath')
BEGIN
	ALTER TABLE Defendrestore ADD  FilePath Varchar(3000) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='HostName')
BEGIN
	ALTER TABLE Defendrestore ADD  HostName Varchar(100) DEFAULT '' WITH VALUES
END
GO
--Murugan Sir Till Here
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='Tbl_ExeVersionControl')
BEGIN
	CREATE TABLE Tbl_ExeVersionControl
		(
			HostName Varchar(200) NOT NULL,
			VersionId Varchar(20) NOT NULL
		)				
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_UserValidation')
DROP PROCEDURE Proc_UserValidation
GO
--EXEC Proc_UserValidation 2,'C','D',1,''
CREATE PROCEDURE [Proc_UserValidation]
(	
	@Pi_UserId AS INT,
	@Pi_HostName AS Varchar(100),
	@Pi_DatabaseName AS Varchar(100),
	@Pi_UserStatus AS TinyInt OUTPUT,
	@Pi_Msg AS Varchar(300) OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UserValidation
* PURPOSE	: To Validate Users
* CREATED	: Murugan.R
* CREATED DATE	: 2013/01/23
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}     
****************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @Pi_HostNameLocked as Varchar(100)
	DECLARE @Pi_UserName as Varchar(100)
	DECLARE @Pi_Error TINYINT
	DECLARE @Pi_ErrorMsg TINYINT
	SET @Pi_Error =0
	SET @Pi_UserStatus=0
	SET @Pi_ErrorMsg=0
		BEGIN TRAN
		
		UPDATE Users Set LoggedStatus=1 where UserId=@Pi_UserId
		IF NOT EXISTS(Select UserId FROM Users (NOLOCK) WHERE UserId=@Pi_UserId and HostName NOT IN(@Pi_HostName,'') and LoggedStatus=1)
		BEGIN

			Update Users Set HostName=@Pi_HostName where UserId=@Pi_UserId
			Update Users Set HostName='' where UserId NOT IN(@Pi_UserId) and HostName=@Pi_HostName
			SET @Pi_Error=0
		END
		ELSE
		BEGIN
			IF EXISTS(
					SELECT Distinct A.HostName FROM Master..Sysprocesses A 
					INNER JOIN sys.dm_Exec_Sessions B ON A.Spid=B.session_id
					INNER JOIN master..SysDatabases C ON A.dbid=C.dbid
					WHERE C.Name collate SQL_Latin1_General_CP1_CI_AS =@Pi_DatabaseName AND LTRIM(RTRIM(A.HostName)) collate SQL_Latin1_General_CP1_CI_AS
					IN(SELECT hostname FROM Users (NOLOCK) WHERE UserId=@Pi_UserId) and A.PROGRAM_NAME IN('Core Stocky','Visual Basic')
					and A.Spid>50 And B.Client_Interface_Name='OLEDB'
					)
			BEGIN
				SELECT @Pi_HostName=HostName,@Pi_UserName=UserName FROM Users (NOLOCK) WHERE UserId=@Pi_UserId
				SET @Pi_Error=1	
			END
			ELSE
			BEGIN
				Update Users Set HostName=@Pi_HostName where UserId=@Pi_UserId
				Update Users Set HostName='' where UserId NOT IN(@Pi_UserId) and HostName=@Pi_HostName
				SET @Pi_Error=0
			END
			
		END
		---Version Control Process
		IF @Pi_Error=0
		BEGIN
			IF NOT EXISTS(SELECT HostName FROM Tbl_ExeVersionControl (NOLOCK) WHERE HostName =@Pi_HostName
						  AND LTRIM(RTRIM(VersionId)) IN(SELECT LTRIM(RTRIM(VersionId)) FROM UtilityProcess (NOLOCK)
											WHERE ProcId=1))
			BEGIN
				SET @Pi_Error=1
				SET @Pi_ErrorMsg=1
			END											
											
		END	
		--Till Here
		IF @Pi_Error=1 
		BEGIN
			IF @Pi_ErrorMsg=0 
			BEGIN
				SET @Pi_Msg='The User '+ UPPER(@Pi_UserName) +' already locked in the machine '+ @Pi_HostName
			END
			ELSE
			BEGIN
				SET @Pi_Msg='Core Stocky application Version mismatch, Please contact Support center for assistance'
			END		
			ROLLBACK TRAN
			SET @Pi_UserStatus=1
		END
		ELSE
		BEGIN
			SELECT 'User logged In' 
			COMMIT TRAN
			SET @Pi_UserStatus=0
			SET @Pi_Msg=''
		END		
END
GO

---------------- Console Script Started--------------
IF  NOT EXISTS (SELECT * FROM Sysobjects WHERE Name ='SyncStatus' AND Xtype = 'U')
BEGIN
CREATE TABLE SyncStatus(
	[DistCode] [varchar](100) NULL,
	[SyncId] [int] NULL,
	[DPStartTime] [datetime] NULL,
	[DPEndTime] [datetime] NULL,
	[UpStartTime] [datetime] NULL,
	[UpEndTime] [datetime] NULL,
	[DwnStartTime] [datetime] NULL,
	[DwnEndTime] [datetime] NULL,
	[SyncStatus] [int] NULL,
	[SyncFlag] [varchar](2) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT B.name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.name='SyncStatus' AND B.Name = 'SyncFlag')
BEGIN
	ALTER TABLE SyncStatus ADD SyncFlag Varchar(2)

END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Name ='SyncAttempt' AND Xtype = 'U')
BEGIN
DROP TABLE [SyncAttempt]
END
GO
CREATE TABLE [SyncAttempt](
	[IPAddress] [varchar](300) NULL,
	[Status] [int] NULL,
	[StartTime] [datetime] NULL
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustomUpDownloadStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CustomUpDownloadStatus](
	[SyncProcess] [nvarchar](30) NULL,
	[Status] [int] NULL
) 
END
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE Name ='CS2Console_Consolidated' AND Xtype = 'U')
BEGIN
CREATE TABLE [CS2Console_Consolidated](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](100) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ProcessName] [varchar](200) NULL,
	[ProcessDate] [datetime] NULL,
	[Column1] [varchar](200) NULL,
	[Column2] [varchar](200) NULL,
	[Column3] [varchar](200) NULL,
	[Column4] [varchar](200) NULL,
	[Column5] [varchar](200) NULL,
	[Column6] [varchar](200) NULL,
	[Column7] [varchar](200) NULL,
	[Column8] [varchar](200) NULL,
	[Column9] [varchar](200) NULL,
	[Column10] [varchar](200) NULL,
	[Column11] [varchar](200) NULL,
	[Column12] [varchar](200) NULL,
	[Column13] [varchar](200) NULL,
	[Column14] [varchar](200) NULL,
	[Column15] [varchar](200) NULL,
	[Column16] [varchar](200) NULL,
	[Column17] [varchar](200) NULL,
	[Column18] [varchar](200) NULL,
	[Column19] [varchar](200) NULL,
	[Column20] [varchar](200) NULL,
	[Column21] [varchar](200) NULL,
	[Column22] [varchar](200) NULL,
	[Column23] [varchar](200) NULL,
	[Column24] [varchar](200) NULL,
	[Column25] [varchar](200) NULL,
	[Column26] [varchar](200) NULL,
	[Column27] [varchar](200) NULL,
	[Column28] [varchar](200) NULL,
	[Column29] [varchar](200) NULL,
	[Column30] [varchar](200) NULL,
	[Column31] [varchar](200) NULL,
	[Column32] [varchar](200) NULL,
	[Column33] [varchar](200) NULL,
	[Column34] [varchar](200) NULL,
	[Column35] [varchar](200) NULL,
	[Column36] [varchar](200) NULL,
	[Column37] [varchar](200) NULL,
	[Column38] [varchar](200) NULL,
	[Column39] [varchar](200) NULL,
	[Column40] [varchar](200) NULL,
	[Column41] [varchar](200) NULL,
	[Column42] [varchar](200) NULL,
	[Column43] [varchar](200) NULL,
	[Column44] [varchar](200) NULL,
	[Column45] [varchar](200) NULL,
	[Column46] [varchar](200) NULL,
	[Column47] [varchar](200) NULL,
	[Column48] [varchar](200) NULL,
	[Column49] [varchar](200) NULL,
	[Column50] [varchar](200) NULL,
	[Column51] [varchar](200) NULL,
	[Column52] [varchar](200) NULL,
	[Column53] [varchar](200) NULL,
	[Column54] [varchar](200) NULL,
	[Column55] [varchar](200) NULL,
	[Column56] [varchar](200) NULL,
	[Column57] [varchar](200) NULL,
	[Column58] [varchar](200) NULL,
	[Column59] [varchar](200) NULL,
	[Column60] [varchar](200) NULL,
	[Column61] [varchar](200) NULL,
	[Column62] [varchar](200) NULL,
	[Column63] [varchar](200) NULL,
	[Column64] [varchar](200) NULL,
	[Column65] [varchar](200) NULL,
	[Column66] [varchar](200) NULL,
	[Column67] [varchar](200) NULL,
	[Column68] [varchar](200) NULL,
	[Column69] [varchar](200) NULL,
	[Column70] [varchar](200) NULL,
	[Column71] [varchar](200) NULL,
	[Column72] [varchar](200) NULL,
	[Column73] [varchar](200) NULL,
	[Column74] [varchar](200) NULL,
	[Column75] [varchar](200) NULL,
	[Column76] [varchar](200) NULL,
	[Column77] [varchar](200) NULL,
	[Column78] [varchar](200) NULL,
	[Column79] [varchar](200) NULL,
	[Column80] [varchar](200) NULL,
	[Column81] [varchar](200) NULL,
	[Column82] [varchar](200) NULL,
	[Column83] [varchar](200) NULL,
	[Column84] [varchar](200) NULL,
	[Column85] [varchar](200) NULL,
	[Column86] [varchar](200) NULL,
	[Column87] [varchar](200) NULL,
	[Column88] [varchar](200) NULL,
	[Column89] [varchar](200) NULL,
	[Column90] [varchar](200) NULL,
	[Column91] [varchar](200) NULL,
	[Column92] [varchar](200) NULL,
	[Column93] [varchar](200) NULL,
	[Column94] [varchar](200) NULL,
	[Column95] [varchar](200) NULL,
	[Column96] [varchar](200) NULL,
	[Column97] [varchar](200) NULL,
	[Column98] [varchar](200) NULL,
	[Column99] [varchar](200) NULL,
	[Column100] [varchar](200) NULL,
	[Remarks1] [varchar](500) NULL,
	[Remarks2] [varchar](500) NULL,
	[UploadFlag] [varchar](1) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE Name ='Tbl_UploadIntegration_Process' AND Xtype = 'U')
BEGIN
CREATE TABLE [Tbl_UploadIntegration_Process](
	[SequenceNo] [int] NULL,
	[ProcessName] [varchar](100) NULL,
	[FolderName] [varchar](200) NULL,
	[PrkTableName] [varchar](200) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Console2CS_Consolidated]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Console2CS_Consolidated](
	[SlNo] [numeric](38, 0) NOT NULL,
	[DistCode] [varchar](100) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ProcessName] [varchar](200) NULL,
	[ProcessDate] [datetime] NULL,
	[Column1] [varchar](200) NULL,
	[Column2] [varchar](200) NULL,
	[Column3] [varchar](200) NULL,
	[Column4] [varchar](200) NULL,
	[Column5] [varchar](200) NULL,
	[Column6] [varchar](200) NULL,
	[Column7] [varchar](200) NULL,
	[Column8] [varchar](200) NULL,
	[Column9] [varchar](200) NULL,
	[Column10] [varchar](200) NULL,
	[Column11] [varchar](200) NULL,
	[Column12] [varchar](200) NULL,
	[Column13] [varchar](200) NULL,
	[Column14] [varchar](200) NULL,
	[Column15] [varchar](200) NULL,
	[Column16] [varchar](200) NULL,
	[Column17] [varchar](200) NULL,
	[Column18] [varchar](200) NULL,
	[Column19] [varchar](200) NULL,
	[Column20] [varchar](200) NULL,
	[Column21] [varchar](200) NULL,
	[Column22] [varchar](200) NULL,
	[Column23] [varchar](200) NULL,
	[Column24] [varchar](200) NULL,
	[Column25] [varchar](200) NULL,
	[Column26] [varchar](200) NULL,
	[Column27] [varchar](200) NULL,
	[Column28] [varchar](200) NULL,
	[Column29] [varchar](200) NULL,
	[Column30] [varchar](200) NULL,
	[Column31] [varchar](200) NULL,
	[Column32] [varchar](200) NULL,
	[Column33] [varchar](200) NULL,
	[Column34] [varchar](200) NULL,
	[Column35] [varchar](200) NULL,
	[Column36] [varchar](200) NULL,
	[Column37] [varchar](200) NULL,
	[Column38] [varchar](200) NULL,
	[Column39] [varchar](200) NULL,
	[Column40] [varchar](200) NULL,
	[Column41] [varchar](200) NULL,
	[Column42] [varchar](200) NULL,
	[Column43] [varchar](200) NULL,
	[Column44] [varchar](200) NULL,
	[Column45] [varchar](200) NULL,
	[Column46] [varchar](200) NULL,
	[Column47] [varchar](200) NULL,
	[Column48] [varchar](200) NULL,
	[Column49] [varchar](200) NULL,
	[Column50] [varchar](200) NULL,
	[Column51] [varchar](200) NULL,
	[Column52] [varchar](200) NULL,
	[Column53] [varchar](200) NULL,
	[Column54] [varchar](200) NULL,
	[Column55] [varchar](200) NULL,
	[Column56] [varchar](200) NULL,
	[Column57] [varchar](200) NULL,
	[Column58] [varchar](200) NULL,
	[Column59] [varchar](200) NULL,
	[Column60] [varchar](200) NULL,
	[Column61] [varchar](200) NULL,
	[Column62] [varchar](200) NULL,
	[Column63] [varchar](200) NULL,
	[Column64] [varchar](200) NULL,
	[Column65] [varchar](200) NULL,
	[Column66] [varchar](200) NULL,
	[Column67] [varchar](200) NULL,
	[Column68] [varchar](200) NULL,
	[Column69] [varchar](200) NULL,
	[Column70] [varchar](200) NULL,
	[Column71] [varchar](200) NULL,
	[Column72] [varchar](200) NULL,
	[Column73] [varchar](200) NULL,
	[Column74] [varchar](200) NULL,
	[Column75] [varchar](200) NULL,
	[Column76] [varchar](200) NULL,
	[Column77] [varchar](200) NULL,
	[Column78] [varchar](200) NULL,
	[Column79] [varchar](200) NULL,
	[Column80] [varchar](200) NULL,
	[Column81] [varchar](200) NULL,
	[Column82] [varchar](200) NULL,
	[Column83] [varchar](200) NULL,
	[Column84] [varchar](200) NULL,
	[Column85] [varchar](200) NULL,
	[Column86] [varchar](200) NULL,
	[Column87] [varchar](200) NULL,
	[Column88] [varchar](200) NULL,
	[Column89] [varchar](200) NULL,
	[Column90] [varchar](200) NULL,
	[Column91] [varchar](200) NULL,
	[Column92] [varchar](200) NULL,
	[Column93] [varchar](200) NULL,
	[Column94] [varchar](200) NULL,
	[Column95] [varchar](200) NULL,
	[Column96] [varchar](200) NULL,
	[Column97] [varchar](200) NULL,
	[Column98] [varchar](200) NULL,
	[Column99] [varchar](200) NULL,
	[Column100] [varchar](200) NULL,
	[Remarks1] [varchar](500) NULL,
	[Remarks2] [varchar](500) NULL,
	[DownloadFlag] [varchar](1) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SyncStatus_Download]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SyncStatus_Download](
	[DistCode] [varchar](100) NULL,
	[SyncId] [int] NULL,
	[DwnStartTime] [datetime] NULL,
	[DwnEndTime] [datetime] NULL,
	[SyncStatus] [int] NULL,
	[SyncFlag] [varchar](1) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SyncStatus_Download_Archieve]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SyncStatus_Download_Archieve](
	[DistCode] [varchar](100) NULL,
	[SyncId] [int] NULL,
	[DwnStartTime] [datetime] NULL,
	[DwnEndTime] [datetime] NULL,
	[SyncStatus] [int] NULL,
	[SyncFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tbl_DownloadIntegration_Process]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Tbl_DownloadIntegration_Process](
	[SequenceNo] [int] NULL,
	[ProcessName] [varchar](100) NULL,
	[PrkTableName] [varchar](100) NULL,
	[SPName] [varchar](100) NULL,
	[TRowCount] [int] NULL,
	[SelectCount] [int] NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[XML2CSPT_ErrorLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[XML2CSPT_ErrorLog](
	[SP_Name] [varchar](250) NULL,
	[ErrorMessage] [varchar](6000) NULL,
	[ErrorDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReDownloadRequest]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ReDownloadRequest](
	[DistCode] [nvarchar](100) NULL,
	[Process] [nvarchar](100) NULL,
	[RefNo] [nvarchar](100) NULL,
	[Download] [nvarchar](100) NULL,
	[PrdCCode] [nvarchar](200) NULL,
	[PrdBatCode] [nvarchar](200) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SlNo] [int] IDENTITY(1,1) NOT NULL
) 
END
GO
-------------Default Values-------------
IF NOT EXISTS (SELECT * FROM SyncCounter)
BEGIN
	INSERT INTO SyncCounter (TabName,CurrValue,ModuleName,CurrYear,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
	SELECT 'SyncCounter',1,'SyncCount',YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE()
END
GO
IF NOT EXISTS (SELECT * FROM Sync_Master)
BEGIN
	INSERT INTO Sync_Master (SyncId,SyncDate )
	SELECT 1,GETDATE()
END
GO
IF NOT EXISTS (Select * From Tbl_UploadIntegration_Process Where SequenceNo = 1)
Begin
	Insert into Tbl_UploadIntegration_Process 
	Select 1,'Consolidated Upload','ConsolidatedUpload','CS2Console_Consolidated',GETDATE()
End
GO
IF NOT EXISTS (Select * from Syncstatus)
Begin
	Insert into Syncstatus
	Select DistributorCode,1,GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),0,'N' From Distributor 
End
GO
Update Configuration Set Status=1 WHERE ModuleId='GENCONFIG19' AND ModuleName='General Configuration' 
GO
IF Not Exists (Select * From Tbl_DownloadIntegration_Process Where SequenceNo = 1)
Begin
	Insert into Tbl_DownloadIntegration_Process 
	Select 1,'Consolidated_Download','Console2CS_Consolidated','Proc_Console2CS_Consolidated',0,0,GETDATE()
End
---------------- Procedures ------------------
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_Cs2Cn_SyncStatusUpdate')
DROP PROCEDURE Proc_Cs2Cn_SyncStatusUpdate
GO
--EXEC Proc_Cs2Cn_SyncStatusUpdate 0
CREATE PROCEDURE Proc_Cs2Cn_SyncStatusUpdate
(
	@Po_ErrNo INT OUTPUT
)
AS
/*************************************************************
* Procedure	: Proc_Cs2Cn_SyncStatusUpdate
* PURPOSE	: To Add SyncId Column into parking table
* CREATED BY	: Praveenraj B
* CREATED DATE	: 18/07/2012
*************************************************************/
BEGIN
		DECLARE @ParkTable AS NVARCHAR(100)
		DECLARE @SSQL AS NVARCHAR(2000)

		SET @Po_ErrNo=0
		
		DECLARE Cur_ParkTable CURSOR FOR SELECT ParkTable FROM Customupdownload WHERE Updownload='Upload' ORDER BY Slno
		OPEN Cur_ParkTable
		FETCH NEXT FROM Cur_ParkTable INTO @ParkTable
		WHILE @@FETCH_STATUS=0
		BEGIN
			IF NOT EXISTS (SELECT B.name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.name=@ParkTable AND B.Name ='SyncId')
			BEGIN
				SET @SSQL=''
				SET @SSQL='ALTER TABLE '+@ParkTable+' ADD SyncId NUMERIC(38,0)'
				EXEC (@SSQL)
			END
		    IF NOT EXISTS (SELECT B.name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.name=@ParkTable AND B.Name ='ServerDate')
			BEGIN
				SET @SSQL=''
				SET @SSQL='ALTER TABLE '+@ParkTable+' ADD ServerDate DATETIME'
				EXEC (@SSQL)
			END
		FETCH NEXT FROM Cur_ParkTable INTO @ParkTable
		END
		CLOSE Cur_ParkTable
		DEALLOCATE Cur_ParkTable
		
		DECLARE Cur_ParkTable CURSOR FOR SELECT PrkTableName FROM Tbl_uploadIntegration ( NOLOCK)  ORDER BY SequenceNo
		OPEN Cur_ParkTable
		FETCH NEXT FROM Cur_ParkTable INTO @ParkTable
		WHILE @@FETCH_STATUS=0
		BEGIN
			IF NOT EXISTS (SELECT B.name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.name=@ParkTable AND B.Name = 'SyncId')
			BEGIN
				SET @SSQL=''
				SET @SSQL='ALTER TABLE '+@ParkTable+' ADD SyncId NUMERIC(38,0)'
				EXEC (@SSQL)
			END
			IF NOT EXISTS (SELECT B.name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.name=@ParkTable AND B.Name ='ServerDate')
			BEGIN
				SET @SSQL=''
				SET @SSQL='ALTER TABLE '+@ParkTable+' ADD ServerDate DATETIME'
				EXEC (@SSQL)
			END
		FETCH NEXT FROM Cur_ParkTable INTO @ParkTable
		END
		CLOSE Cur_ParkTable
		DEALLOCATE Cur_ParkTable
END
GO
EXEC Proc_Cs2Cn_SyncStatusUpdate 0
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_SyncIdGeneration')
DROP PROCEDURE Proc_SyncIdGeneration
GO
--EXEC Proc_SyncIdGeneration 0
CREATE PROCEDURE Proc_SyncIdGeneration
(
	@Po_SyncStatus AS INT
)
AS
/*************************************************************
* Procedure	: Proc_SyncIdGeneration
* PURPOSE	: To Generate SyncId 
* CREATED BY	: Praveenraj B
* CREATED DATE	: 18/07/2012
*************************************************************/
BEGIN
		DECLARE @CurrValue AS NUMERIC(38,0)
		SELECT @CurrValue=CurrValue FROM SyncCounter WHERE ModuleName='SyncCount'
		
		IF @Po_SyncStatus=1
		BEGIN
			INSERT INTO Sync_Master (SyncId,SyncDate)
			SELECT @CurrValue+1,GETDATE() FROM  SyncCounter 
			UPDATE SyncCounter SET CurrValue=@CurrValue+1 WHERE ModuleName='SyncCount'
		END
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_Cs2Cn_SyncRecDetUpdate')
DROP PROCEDURE Proc_Cs2Cn_SyncRecDetUpdate
GO
--Proc_Cs2Cn_SyncRecDetUpdate 0,'2012-08-01'
CREATE PROCEDURE Proc_Cs2Cn_SyncRecDetUpdate
(
	@Po_ErrNo AS INT OUTPUT,
    @Sever_Date AS DATETIME
)
AS
/*************************************************************
* Procedure	: Proc_Cs2Cn_SyncRecDetUpdate
* PURPOSE	: To Update SyncId And Generate Record details 
* CREATED BY	: Praveenraj B
* CREATED DATE	: 18/07/2012
*************************************************************/
BEGIN
	DECLARE @ParkTable AS NVARCHAR(100)
	DECLARE @ProcessName AS NVARCHAR(100)
	DECLARE @CurrValue AS NUMERIC(38,0)
	DECLARE @DEL_SSQL AS NVARCHAR(1000)
	DECLARE @SSQL AS NVARCHAR(1000)
	DECLARE @IN_SQL	AS NVARCHAR(1000)
	DECLARE @SyncId AS NUMERIC(38,0)
	DECLARE @DistCode AS NVARCHAR(100)
		
		SELECT @SyncId=MAX(SyncId) FROM Sync_Master
		SELECT @DistCode=DistributorCode FROM Distributor	

	DECLARE Cur_ParkTable CURSOR FOR SELECT PrkTableName,ProcessName FROM Tbl_UploadIntegration WHERE ProcessName NOT IN ('For Integration') ORDER BY SequenceNo 
	OPEN Cur_ParkTable
	FETCH NEXT FROM Cur_ParkTable INTO @ParkTable,@ProcessName
	WHILE @@FETCH_STATUS=0
	BEGIN
			SET @SSQL=''
			SET @SSQL='UPDATE '+@ParkTable+' SET SyncId ='+CAST(@SyncId AS NVARCHAR(20))+',ServerDate ='''+CONVERT(VARCHAR(30),@Sever_Date,120)+''''
			EXEC (@SSQL)
			
			SET @DEL_SSQL=''
			SET @DEL_SSQL='DELETE FROM Sync_RecordDetails WHERE ProcessName= '''+@ProcessName+''' AND SyncId= '+CAST(@SyncId AS NVARCHAR(25))
			EXEC (@DEL_SSQL)
			SET @IN_SQL=''
			SET @IN_SQL='INSERT INTO Sync_RecordDetails(DistCode,SyncId,SyncDate,ProcessName,RecCount)'
			SET @IN_SQL=@IN_SQL	+' SELECT ''' +@DistCode+ ''',''' +CAST(@SyncId AS NVARCHAR(25))+''',GETDATE(),''' +@ProcessName+ ''',COUNT(Slno) FROM ' +@ParkTable
			EXEC (@IN_SQL)

	FETCH NEXT FROM Cur_ParkTable INTO @ParkTable,@ProcessName
	END
	CLOSE Cur_ParkTable
	DEALLOCATE Cur_ParkTable
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_DBUnlock')
DROP PROCEDURE Proc_DBUnlock
GO
CREATE Proc Proc_DBUnlock
(
@piTypeId int = 0,
@piReason nvarchar(100) = null,
@piRemarks nvarchar(200) = null,
@piDBStatus int = 0
)
as 
Begin

	If @piTypeId = 1
	Begin
	
		Select DistributorCode,DistributorName From Distributor with(nolock)
	
	End
	If @piTypeId = 2
	Begin
	
		Create table #Reason
		(
			RId int,
			RName nvarchar(100)
		)
		
		Insert into #Reason
		Select 0,'--- Select ---'
				
		Insert into #Reason
		Select 1,'Database Restored'
				
		Insert into #Reason
		Select 2,'Database Crashed '
				
		Insert into #Reason
		Select 3,'System Formated'
	
		Select RId,RName From #Reason 
			
	End
	If @piTypeId = 3
	Begin
	
		Select AccessCode,LastModDate,DbStatus,ReqId From DefendRestore with(nolock)
		
	End
	If @piTypeId = 4
	Begin
	
		Truncate table Cs2Cn_Prk_DBUnlockDetails
	
		Insert into Cs2Cn_Prk_DBUnlockDetails
		(
			DistCode,
			SyncId,
			HotFixId,
			IPAddress,
			Reason,
			Remarks,
			DBUnlockStatus,
			UploadDate,
			UploadFlag
		)
		Select Distinct
			DistributorCode as DistCode,
			0 as SyncId,
			0 as HotFixId,
			'' as IPAddress,
			@piReason as Reason,
			@piRemarks as Remarks,
			1 as DBUnlockStatus,
			getdate() as UploadDate,
			'N' as UploadFlag 
		From 
			Distributor 
			
		If ((Select Count(*) from SyncStatus with(nolock)) > 0)
		Begin
			
			If ((Select Count(*) from SyncStatus with(nolock) where SyncStatus = 1 ) > 0)
			Begin
				
				Update Cs2Cn_Prk_DBUnlockDetails set SyncId = (Select SyncId From SyncStatus with(nolock) where SyncStatus = 1 )
			
			End
			Else				
			Begin
				
				Update Cs2Cn_Prk_DBUnlockDetails set SyncId = (Select SyncId - 1 From SyncStatus with(nolock))
			
			End
		End
		Else
		Begin
			Update Cs2Cn_Prk_DBUnlockDetails set SyncId = 0
		End	
		
		
			
		Update Cs2Cn_Prk_DBUnlockDetails set HotFixId = (Select  IsNull(Max(FixID),0) From Hotfixlog with(nolock))
			
		Update Cs2Cn_Prk_DBUnlockDetails set IPAddress = (Select IPAddress From SyncAttempt with(nolock))
			
		Update Cs2Cn_Prk_DBUnlockDetails set DBUnlockStatus = (Select DbStatus From DefendRestore with(nolock))
	
		Update DefendRestore set ReqId = 999
		
		Select Distinct 
			DistCode,
			SyncId,
			HotFixId,
			IPAddress,
			Reason,
			Remarks,
			DBUnlockStatus,
			UploadDate,
			UploadFlag 
		From Cs2Cn_Prk_DBUnlockDetails with(nolock)	for xml auto
	
	End
	If @piTypeId = 5
	Begin
	
		Select * From Configuration with(nolock) Where ModuleId='DATATRANSFER44' AND ModuleName='DataTransfer'
		
	End
	If @piTypeId = 6
	Begin	
		
		Select * From Configuration with(nolock) Where ModuleId='DATATRANSFER45' AND ModuleName='DataTransfer'
		
	End
	If @piTypeId = 7
	Begin	
		
		If (@piDBStatus = 0)
		Begin
			Update DefendRestore set DBStatus = @piDBStatus,ReqId = 0
		End
		Else
		Begin
			Update DefendRestore set DBStatus = @piDBStatus
		End
		
	End
	If @piTypeId = 8
	Begin	
		
		If ((Select Count(*) from SyncStatus with(nolock)) > 0)
		Begin
			
			If ((Select Count(*) from SyncStatus with(nolock) where SyncStatus = 1 ) > 0)
			Begin
				
				Select SyncId From SyncStatus with(nolock) where SyncStatus = 1 
			
			End
			Else				
			Begin
				
				Select SyncId - 1 From SyncStatus with(nolock)
			
			End
		End
		Else
		Begin
			Select 0
		End		
	End
	If @piTypeId = 9
	Begin	
		Truncate table DefendRestore
	End
End
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'Cs2Cn_Prk_SyncDetails')
DROP TABLE Cs2Cn_Prk_SyncDetails
GO
CREATE TABLE Cs2Cn_Prk_SyncDetails(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[FixId] [int] NULL,
	[FixDate] [datetime] NULL,
	[FixVersion] [numeric](38, 6) NULL,
	[SyncDate] [datetime] NULL,
	[UploadFlag] [nvarchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate][Datetime] NULL,
	[HostName][NVARCHAR](200) NULL
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT B.name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.name='Cs2Cn_Prk_SyncDetails' AND B.Name = 'UpdatedHotfixId')
BEGIN
	ALTER TABLE Cs2Cn_Prk_SyncDetails ADD UpdatedHotfixId Numeric(18,6)
END
GO
IF NOT EXISTS (SELECT B.name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.name='Cs2Cn_Prk_SyncDetails' AND B.Name = 'SyncExeVersion')
BEGIN
	ALTER TABLE Cs2Cn_Prk_SyncDetails ADD SyncExeVersion Varchar(100)
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_SyncDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Cs2Cn_SyncDetails]
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
	SELECT @DistCode,FixId,FixedOn AS FixDate,SynVersion AS FixVersion,GETDATE(),'N',
	(SELECT ISNULL(MAX(SyncId),0) AS SYNCID FROM sync_master (NOLOCK)),@Sever_Date,@HostName,(Select MAX(Fixid) From UpdaterLog (Nolock)),
	(Select VersionId From UtilityProcess (Nolock) Where ProcId = 3)
	FROM AppTitle,HotFixLog WHERE FixId IN (SELECT ISNULL(MAX(FixId),0) FROM HotFixLog)
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnMaxTransactionDate')
DROP FUNCTION Fn_ReturnMaxTransactionDate
GO
--SELECT DBO.Fn_ReturnMaxTransactionDate()
CREATE FUNCTION Fn_ReturnMaxTransactionDate()
RETURNS  DATETIME
AS
/*********************************
* FUNCTION: Fn_ReturnMaxTransactionDate
* PURPOSE: Return Max Transaction Date
* NOTES: 
* CREATED: Murugan.R
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------*/
BEGIN
		DECLARE @RetDate as DATETIME
		SET @RetDate = CONVERT(DATETIME ,Convert(Varchar(10),GETDATE(),121),121)
		SELECT @RetDate =ISNULL(MAX(TransDate),GETDATE()) FROM (
		SELECT MAX(Transdate) as TransDate FROM StockLedger(NOLOCK)
		--UNION ALL
		--SELECT MAX(DayEndStartDate) as TransDate FROM Dayenddates (NOLOCK) WHERE Status=1
		)X
		RETURN(CONVERT(DATETIME ,Convert(Varchar(10),@RetDate,121),121))
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE = 'P' AND name='Proc_Cs2Cn_ValidateSyncDate')
DROP PROCEDURE Proc_Cs2Cn_ValidateSyncDate
GO
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_ValidateSyncDate]
(
	@Pi_ServerDate VARCHAR(10),
	@Pi_ReturnValue TINYINT OUTPUT
)
AS
/***************************************************************************************************************
* PROCEDURE	: Proc_Cs2Cn_ValidateSyncDate
* PURPOSE	: To Validate Sync date 
* CREATED BY	:  Murugan.R
* CREATED DATE	: 25/05/2012
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
*****************************************************************************************************************/
BEGIN
	DECLARE @MaxTransdate AS DATETIME
	DECLARE @Condition AS INT
	DECLARE @DayDiff AS INT
	SET @Pi_ReturnValue=0
	SELECT @Condition=CAST(ISNULL(ConfigValue,0) AS INT)  FROM Configuration WHERE Status=1 and ModuleId='BotreeSyncDateCheck'
	--PRINT @Condition
	SELECT @MaxTransdate= DBO.Fn_ReturnMaxTransactionDate()	
	SELECT @DayDiff=DATEDIFF(DAY,@MaxTransdate,CONVERT(DATETIME,CONVERT(Varchar(10),@Pi_ServerDate,121),121))
	
	IF @DayDiff<0
	BEGIN
		IF @Condition<ABS(@DayDiff)
		BEGIN
			SET @Pi_ReturnValue=1
		END
	END	
	
	SELECT 	@Pi_ReturnValue
	
	RETURN
	
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Console2CS_ConsolidatedDownload]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Console2CS_ConsolidatedDownload]
GO
CREATE PROCEDURE [dbo].[Proc_Console2CS_ConsolidatedDownload]  
AS  
Begin  
BEGIN TRY    
SET XACT_ABORT ON    
BEGIN TRANSACTION
DECLARE @Lvar INT  
DECLARE @MaxId INT  
DECLARE @SqlStr VARCHAR(8000)  
DECLARE @Process VARCHAR(100)  
DECLARE @colcount INT  
DECLARE @Col VARCHAR(5000)  
DECLARE @Tablename VARCHAR(100)  
DECLARE @Sequenceno INT  
 CREATE TABLE #Col (ColId INT)  
 CREATE TABLE #Console2CS_Consolidated  
 (  
  [SlNo] [numeric](38, 0) NULL, [DistCode] [VARCHAR](100) COLLATE Database_Default NULL, [SyncId] [numeric](38, 0) NULL,  
  [ProcessName] [VARCHAR](100) COLLATE Database_Default NULL, [ProcessDate] [datetime] NULL, [Column1] [VARCHAR](100) COLLATE Database_Default NULL,  
  [Column2] [VARCHAR](200) COLLATE Database_Default NULL, [Column3] [VARCHAR](200) COLLATE Database_Default NULL, [Column4] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column5] [VARCHAR](200) COLLATE Database_Default NULL, [Column6] [VARCHAR](200) COLLATE Database_Default NULL, [Column7] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column8] [VARCHAR](200) COLLATE Database_Default NULL, [Column9] [VARCHAR](200) COLLATE Database_Default NULL, [Column10] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column11] [VARCHAR](200) COLLATE Database_Default NULL, [Column12] [VARCHAR](200) COLLATE Database_Default NULL, [Column13] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column14] [VARCHAR](200) COLLATE Database_Default NULL, [Column15] [VARCHAR](200) COLLATE Database_Default NULL, [Column16] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column17] [VARCHAR](200) COLLATE Database_Default NULL, [Column18] [VARCHAR](200) COLLATE Database_Default NULL, [Column19] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column20] [VARCHAR](200) COLLATE Database_Default NULL, [Column21] [VARCHAR](200) COLLATE Database_Default NULL, [Column22] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column23] [VARCHAR](200) COLLATE Database_Default NULL, [Column24] [VARCHAR](200) COLLATE Database_Default NULL, [Column25] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column26] [VARCHAR](200) COLLATE Database_Default NULL, [Column27] [VARCHAR](200) COLLATE Database_Default NULL, [Column28] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column29] [VARCHAR](200) COLLATE Database_Default NULL, [Column30] [VARCHAR](200) COLLATE Database_Default NULL, [Column31] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column32] [VARCHAR](200) COLLATE Database_Default NULL, [Column33] [VARCHAR](200) COLLATE Database_Default NULL, [Column34] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column35] [VARCHAR](200) COLLATE Database_Default NULL, [Column36] [VARCHAR](200) COLLATE Database_Default NULL, [Column37] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column38] [VARCHAR](200) COLLATE Database_Default NULL, [Column39] [VARCHAR](200) COLLATE Database_Default NULL, [Column40] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column41] [VARCHAR](200) COLLATE Database_Default NULL, [Column42] [VARCHAR](200) COLLATE Database_Default NULL, [Column43] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column44] [VARCHAR](200) COLLATE Database_Default NULL, [Column45] [VARCHAR](200) COLLATE Database_Default NULL, [Column46] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column47] [VARCHAR](200) COLLATE Database_Default NULL, [Column48] [VARCHAR](200) COLLATE Database_Default NULL, [Column49] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column50] [VARCHAR](200) COLLATE Database_Default NULL, [Column51] [VARCHAR](200) COLLATE Database_Default NULL, [Column52] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column53] [VARCHAR](200) COLLATE Database_Default NULL, [Column54] [VARCHAR](200) COLLATE Database_Default NULL, [Column55] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column56] [VARCHAR](200) COLLATE Database_Default NULL, [Column57] [VARCHAR](200) COLLATE Database_Default NULL, [Column58] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column59] [VARCHAR](200) COLLATE Database_Default NULL, [Column60] [VARCHAR](200) COLLATE Database_Default NULL, [Column61] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column62] [VARCHAR](200) COLLATE Database_Default NULL, [Column63] [VARCHAR](200) COLLATE Database_Default NULL, [Column64] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column65] [VARCHAR](200) COLLATE Database_Default NULL, [Column66] [VARCHAR](200) COLLATE Database_Default NULL, [Column67] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column68] [VARCHAR](200) COLLATE Database_Default NULL, [Column69] [VARCHAR](200) COLLATE Database_Default NULL, [Column70] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column71] [VARCHAR](200) COLLATE Database_Default NULL, [Column72] [VARCHAR](200) COLLATE Database_Default NULL, [Column73] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column74] [VARCHAR](200) COLLATE Database_Default NULL, [Column75] [VARCHAR](200) COLLATE Database_Default NULL, [Column76] [VARCHAR](200) COLLATE Database_Default NULL,   
  [Column77] [VARCHAR](200) COLLATE Database_Default NULL, [Column78] [VARCHAR](200) COLLATE Database_Default NULL, [Column79] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column80] [VARCHAR](200) COLLATE Database_Default NULL, [Column81] [VARCHAR](200) COLLATE Database_Default NULL, [Column82] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column83] [VARCHAR](200) COLLATE Database_Default NULL, [Column84] [VARCHAR](200) COLLATE Database_Default NULL, [Column85] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column86] [VARCHAR](200) COLLATE Database_Default NULL, [Column87] [VARCHAR](200) COLLATE Database_Default NULL, [Column88] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column89] [VARCHAR](200) COLLATE Database_Default NULL, [Column90] [VARCHAR](200) COLLATE Database_Default NULL, [Column91] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column92] [VARCHAR](200) COLLATE Database_Default NULL, [Column93] [VARCHAR](200) COLLATE Database_Default NULL, [Column94] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column95] [VARCHAR](200) COLLATE Database_Default NULL, [Column96] [VARCHAR](200) COLLATE Database_Default NULL, [Column97] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column98] [VARCHAR](200) COLLATE Database_Default NULL, [Column99] [VARCHAR](200) COLLATE Database_Default NULL, [Column200] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Remarks1] [VARCHAR](200) COLLATE Database_Default NULL, [Remarks2] [VARCHAR](200) COLLATE Database_Default NULL, [DownloadFlag] [VARCHAR](1) COLLATE Database_Default NULL,  
  DWNStatus INT
 )   
 DELETE A FROM Console2CS_Consolidated A (NOLOCK) WHERE DownloadFlag='Y'  
 ----------------------------------
 	Create Table #SPLTBL (Id Int Identity(1,1),CId int,CName Varchar(200),CType Varchar(100))
	Insert into #SPLTBL
	Select A.column_id as CId,A.Name,C.name As CType From Sys.columns A (Nolock),Sys.objects B (Nolock),Sys.types C (Nolock) 
	where A.object_id = B.object_id and B.name = 'Console2CS_Consolidated'
	And A.system_type_id = C.system_type_id And C.name='varchar'
	Order by A.column_id 
	Declare @CName Varchar(100)
	Set @Lvar = 1
	Set @CName = ''
	Select @MaxId = IsNull(Count(CId),0) From #SPLTBL
	While @Lvar <= @MaxId
	Begin
		Select @CName = CName From #SPLTBL Where Id = @Lvar
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Console2CS_Consolidated  Set '+ @CName + ' = REPLACE(' + @CName + ','' amp;'',''&'')'
		exec (@SqlStr)
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Console2CS_Consolidated  Set '+ @CName + ' = REPLACE(' + @CName + ','' lt;'',''<'')'
		exec (@SqlStr)
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Console2CS_Consolidated  Set '+ @CName + ' = REPLACE(' + @CName + ','' gt;'',''>'')'
		exec (@SqlStr)
		Set @Lvar = @Lvar + 1
	End
 ----------------------------------
 INSERT INTO #Console2CS_Consolidated  
 SELECT *,0 AS DWNStatus FROM Console2CS_Consolidated (NOLOCK) WHERE DownloadFlag='N'  
   UPDATE A SET A.DWNStatus = 1  
   FROM  
    #Console2CS_Consolidated A (NOLOCK),  
    (  
     SELECT   
     DistCode,SyncId   
     FROM   
     SyncStatus_Download (NOLOCK)  
     WHERE       
     SyncStatus = 1 AND SyncId > 0  
     UNION  
     SELECT   
     DistCode,SyncId  
     FROM   
     SyncStatus_Download_Archieve (NOLOCK)  
     WHERE  
     SyncStatus = 1 AND SyncId > 0  
    ) B  
   WHERE   
    A.DistCode = B.DistCode AND   
    A.SyncId = B.SyncId   
 DELETE A FROM #Console2CS_Consolidated A (NOLOCK) WHERE DWNStatus = 0 
 Create Table #Process(ProcessName VARCHAR(100),PrkTableName VARCHAR(100), id INT Identity(1,1) )  
 INSERT INTO #Process(ProcessName , PrkTableName)   
 SELECT Distinct A.ProcessName , A.PrkTableName FROM Tbl_DownloadINTegration A,#Console2CS_Consolidated B   
 WHERE A.ProcessName = B.ProcessName And A.SequenceNo not in(100000) --Order By Sequenceno  
  SET @Lvar = 1  
  SELECT @MaxId = Max(id) FROM #Process  
  While @Lvar <= @MaxId  
   Begin  
    SELECT @Tablename = PrkTableName , @Process = ProcessName FROM #Process WHERE id  = @Lvar  
    SELECT @colcount = Count(Column_ID) FROM sys.columns WHERE object_id = (SELECT object_id FROM sys.objects WHERE name = @Tablename)  
    SET @SqlStr = ''  
    SET @SqlStr = @SqlStr + ' INSERT INTO ' + @Tablename + ' '  
    SET @Col = ''  
    SELECT @Col = @Col + '[' +name + '],' FROM sys.columns   
    WHERE object_id = ( SELECT object_id FROM sys.objects WHERE name = @Tablename) Order by Column_Id  
    Truncate Table #Col      
    INSERT INTO #Col     
    SELECT  a.column_id + 5 AS ColId  
    FROM sys.columns a,sys.types b WHERE a.user_type_id = b.user_type_id  
    and a.object_id = ( SELECT object_id FROM sys.objects WHERE name = @Tablename)  
    and b.name = 'datetime' --and a.name <> 'CreatedDate'  
    SET @SqlStr = @SqlStr + '(' + left(@Col,len(@Col)-1)  + ') '  
    SET @Col = ''  
    SELECT @Col = @Col + (Case when column_id In (SELECT ColId FROM #Col) then 'Convert(Datetime,'+name + ',121)' else name end) + ','   
    FROM sys.columns WHERE object_id = ( SELECT object_id FROM sys.objects WHERE name = 'Console2CS_Consolidated ')  
    and column_id  between 6 and 5 + @colcount 
    Order by column_id
    SET @SqlStr = @SqlStr + ' SELECT '+ left(@Col,len(@Col)-1)  + ' FROM #Console2CS_Consolidated (NOLOCK) '  
    SET @SqlStr = @SqlStr + ' WHERE ProcessName = '''+ @Process +''' And DWNStatus = 1 '      
    --PrINT (@SqlStr) 
    Exec (@SqlStr)  
    SET @Lvar = @Lvar + 1  
   End
   UPDATE A SET A.DownloadFlag = 'Y'   
   FROM   
    Console2CS_Consolidated A (NOLOCK),  
    #Console2CS_Consolidated B (NOLOCK)  
   WHERE   
    A.DistCode= B.DistCode And   
    A.SyncId = B.SyncId And   
    B.DWNStatus = 1  
   UPDATE A SET A.SyncFlag = 1  
   FROM   
    Syncstatus_Download A (NOLOCK),  
    #Console2CS_Consolidated B (NOLOCK)  
   WHERE   
    A.DistCode= B.DistCode And   
    A.SyncId = B.SyncId And   
    B.DWNStatus = 1  
COMMIT TRANSACTION    
 END TRY    
 BEGIN CATCH    
  ROLLBACK TRANSACTION    
  INSERT INTO XML2CSPT_ErrorLog VALUES ('Proc_Console2CS_ConsolidatedDownload', ERROR_MESSAGE(), GETDATE())    
 END CATCH    
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Console2CS_Consolidated]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Console2CS_Consolidated]
GO
CREATE  Procedure [dbo].[Proc_Console2CS_Consolidated]  
(  
 @Pi_Records TEXT  
)  
AS  
/*********************************  
* PROCEDURE : Proc_Console2CS_Consolidated  
* PURPOSE : To Insert records from xml file in the Table Console2CS_Consolidated  
* CREATED : Arul. V
* CREATED DATE : 02/11/2012
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
  
*********************************/  
SET NOCOUNT ON  
BEGIN  
  
	DECLARE @hDoc INTEGER  
	
	DELETE FROM Console2CS_Consolidated WHERE DownloadFlag='Y'  

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  

	INSERT INTO Console2CS_Consolidated
	(
	SlNo,DistCode,SyncId,ProcessName,ProcessDate,
	Column1,Column2,Column3,Column4,Column5,Column6,Column7,Column8,Column9,Column10,
	Column11,Column12,Column13,Column14,Column15,Column16,Column17,Column18,Column19,Column20,
	Column21,Column22,Column23,Column24,Column25,Column26,Column27,Column28,Column29,Column30,
	Column31,Column32,Column33,Column34,Column35,Column36,Column37,Column38,Column39,Column40,
	Column41,Column42,Column43,Column44,Column45,Column46,Column47,Column48,Column49,Column50,
	Column51,Column52,Column53,Column54,Column55,Column56,Column57,Column58,Column59,Column60,
	Column61,Column62,Column63,Column64,Column65,Column66,Column67,Column68,Column69,Column70,
	Column71,Column72,Column73,Column74,Column75,Column76,Column77,Column78,Column79,Column80,
	Column81,Column82,Column83,Column84,Column85,Column86,Column87,Column88,Column89,Column90,
	Column91,Column92,Column93,Column94,Column95,Column96,Column97,Column98,Column99,Column100,
	Remarks1,Remarks2,DownloadFlag)

	SELECT 	SlNo,DistCode,SyncId,ProcessName,ProcessDate,
	Column1,Column2,Column3,Column4,Column5,Column6,Column7,Column8,Column9,Column10,
	Column11,Column12,Column13,Column14,Column15,Column16,Column17,Column18,Column19,Column20,
	Column21,Column22,Column23,Column24,Column25,Column26,Column27,Column28,Column29,Column30,
	Column31,Column32,Column33,Column34,Column35,Column36,Column37,Column38,Column39,Column40,
	Column41,Column42,Column43,Column44,Column45,Column46,Column47,Column48,Column49,Column50,
	Column51,Column52,Column53,Column54,Column55,Column56,Column57,Column58,Column59,Column60,
	Column61,Column62,Column63,Column64,Column65,Column66,Column67,Column68,Column69,Column70,
	Column71,Column72,Column73,Column74,Column75,Column76,Column77,Column78,Column79,Column80,
	Column81,Column82,Column83,Column84,Column85,Column86,Column87,Column88,Column89,Column90,
	Column91,Column92,Column93,Column94,Column95,Column96,Column97,Column98,Column99,Column100,
	Remarks1,Remarks2,DownloadFlag

	FROM OPENXML (@hdoc,'/Root/DD',1)  
	WITH (  
	[SlNo] [numeric](38, 0) ,	[DistCode] [varchar](100) ,	[SyncId] [numeric](38, 0) ,	[ProcessName] [varchar](100) ,	[ProcessDate] [datetime] ,
	[Column1] [varchar](200) ,	[Column2] [varchar](200) ,	[Column3] [varchar](200) ,	[Column4] [varchar](200) ,	[Column5] [varchar](200) ,
	[Column6] [varchar](200) ,	[Column7] [varchar](200) ,	[Column8] [varchar](200) ,	[Column9] [varchar](200) ,	[Column10] [varchar](200) ,
	[Column11] [varchar](200) ,	[Column12] [varchar](200) ,	[Column13] [varchar](200) ,	[Column14] [varchar](200) ,	[Column15] [varchar](200) ,
	[Column16] [varchar](200) ,	[Column17] [varchar](200) ,	[Column18] [varchar](200) ,	[Column19] [varchar](200) ,	[Column20] [varchar](200) ,
	[Column21] [varchar](200) ,	[Column22] [varchar](200) ,	[Column23] [varchar](200) ,	[Column24] [varchar](200) ,	[Column25] [varchar](200) ,
	[Column26] [varchar](200) ,	[Column27] [varchar](200) ,	[Column28] [varchar](200) ,	[Column29] [varchar](200) ,	[Column30] [varchar](200) ,
	[Column31] [varchar](200) ,	[Column32] [varchar](200) ,	[Column33] [varchar](200) ,	[Column34] [varchar](200) ,	[Column35] [varchar](200) ,
	[Column36] [varchar](200) ,	[Column37] [varchar](200) ,	[Column38] [varchar](200) ,	[Column39] [varchar](200) ,	[Column40] [varchar](200) ,
	[Column41] [varchar](200) ,	[Column42] [varchar](200) ,	[Column43] [varchar](200) ,	[Column44] [varchar](200) ,	[Column45] [varchar](200) ,
	[Column46] [varchar](200) ,	[Column47] [varchar](200) ,	[Column48] [varchar](200) ,	[Column49] [varchar](200) ,	[Column50] [varchar](200) ,
	[Column51] [varchar](200) ,	[Column52] [varchar](200) ,	[Column53] [varchar](200) ,	[Column54] [varchar](200) ,	[Column55] [varchar](200) ,
	[Column56] [varchar](200) ,	[Column57] [varchar](200) ,	[Column58] [varchar](200) ,	[Column59] [varchar](200) ,	[Column60] [varchar](200) ,
	[Column61] [varchar](200) ,	[Column62] [varchar](200) ,	[Column63] [varchar](200) ,	[Column64] [varchar](200) ,	[Column65] [varchar](200) ,
	[Column66] [varchar](200) ,	[Column67] [varchar](200) ,	[Column68] [varchar](200) ,	[Column69] [varchar](200) ,	[Column70] [varchar](200) ,
	[Column71] [varchar](200) ,	[Column72] [varchar](200) ,	[Column73] [varchar](200) ,	[Column74] [varchar](200) ,	[Column75] [varchar](200) ,
	[Column76] [varchar](200) ,	[Column77] [varchar](200) ,	[Column78] [varchar](200) ,	[Column79] [varchar](200) ,	[Column80] [varchar](200) ,
	[Column81] [varchar](200) ,	[Column82] [varchar](200) ,	[Column83] [varchar](200) ,	[Column84] [varchar](200) ,	[Column85] [varchar](200) ,
	[Column86] [varchar](200) ,	[Column87] [varchar](200) ,	[Column88] [varchar](200) ,	[Column89] [varchar](200) ,	[Column90] [varchar](200) ,
	[Column91] [varchar](200) ,	[Column92] [varchar](200) ,	[Column93] [varchar](200) ,	[Column94] [varchar](200) ,	[Column95] [varchar](200) ,
	[Column96] [varchar](200) ,	[Column97] [varchar](200) ,	[Column98] [varchar](200) ,	[Column99] [varchar](200) ,	[Column100] [varchar](200) ,
	[Remarks1] [varchar](300) ,	[Remarks2] [varchar](300) ,	[DownloadFlag] [varchar](1)
		 )   

	EXEC sp_xml_removedocument @hDoc   

END
GO
--Murugan Sir
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='CSLockStatus')
BEGIN
	ALTER TABLE Defendrestore ADD  CSLockStatus TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='CCLockStatus')
BEGIN
	ALTER TABLE Defendrestore ADD  CCLockStatus TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='IniDecryptString')
BEGIN
	ALTER TABLE Defendrestore ADD  IniDecryptString Varchar(3000) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='IniEncryptString')
BEGIN
	ALTER TABLE Defendrestore ADD  IniEncryptString Varchar(3000) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='ActualEncryptString')
BEGIN
	ALTER TABLE Defendrestore ADD  ActualEncryptString Varchar(3000) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='FilePath')
BEGIN
	ALTER TABLE Defendrestore ADD  FilePath Varchar(3000) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Defendrestore') and Name='HostName')
BEGIN
	ALTER TABLE Defendrestore ADD  HostName Varchar(100) DEFAULT '' WITH VALUES
END
--Murugan Sir Till Here
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_SyncValidation')
DROP PROCEDURE Proc_SyncValidation
GO
--EXEC Proc_SyncValidation 0,'',0,0,0,'','',''
CREATE PROCEDURE Proc_SyncValidation
(    
@piTypeId Int,    
@piCode Varchar(100) = '', -- IP Address in Sync Attempt, DistCode in SyncStatus,    
@piVal1 Numeric(18)=0, -- SubTypeId in SyncStatus,    
@piVal2 Numeric(18)=0, -- SyncId in SyncStatus,    
@piVal3 Numeric(18)=0, -- RecCnt in SyncStatus,    
@piVal4 Varchar(100)='',    
@piVal5 Varchar(100)='',    
@piVal6 Varchar(100)=''    
)    
As    
Begin    
 Declare @Sql Varchar(Max)  
 Declare @IntRetVal Int
   
 IF @piTypeId = 1 -- Distributor Code, Proc_SyncValidation  piTypeId    
 Begin    
  SELECT DistributorCode FROM Distributor WHERE Distributorid=1     
 End    
 IF @piTypeId = 2 -- Upload And Download, Path Proc_SyncValidation  piTypeId    
 Begin    
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44','DATATRANSFER45') AND ModuleName='DataTransfer' Order By ModuleId     
 End     
 IF @piTypeId = 3 -- Sync Attempt Validation  Proc_SyncValidation  @piTypeId,@piCode    
 Begin    
  Set @piCode = (Select Top 1 HostName From Sys.sysprocesses where  status='RUNNABLE' Order By login_time desc)    
  IF ((SELECT Count(*) From SyncAttempt) < 1)    
   BEGIN    
    INSERT INTO SyncAttempt    
    SELECT @piCode,1,Getdate()    
    SELECT 1    
   END     
  ELSE    
   BEGIN    
    IF (SELECT Status From SyncAttempt) = 0    
     BEGIN    
      UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
      SELECT 1    
     END    
    ELSE    
     BEGIN    
      IF ((SELECT DatedIFf(hh,StartTime,Getdate()) From SyncAttempt) > 1)    
       BEGIN    
          UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
          SELECT 1    
       END    
      ELSE    
        IF ((SELECT Count(*) From SyncAttempt WHERE IPAddress = @piCode) = 1 )    
         BEGIN    
          UPDATE SyncAttempt SET Status = 1,StartTime = Getdate()     
          SELECT 1    
         END    
        ELSE    
         BEGIN    
          SELECT 0             
         END    
     END    
   END      
 End    
 IF @piTypeId = 4 -- Remove from Redownloadrequest,  Proc_SyncValidation   @piTypeId    
 Begin    
  TRUNCATE TABLE ReDownLoadRequest    
 End    
 IF @piTypeId = 5 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
   IF @piVal1 = 1     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess='SyncProcess0' ORDER BY SyncProcess    
   End    
   IF @piVal1 = 2     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess<>'SyncProcess0' ORDER BY SyncProcess    
   End    
 End    
 IF @piTypeId = 6 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1     
   Begin    
    SELECT DISTINCT SlNo,SlNo AS SeqNo,Module AS Process,TranType AS [Transaction Type],UpDownload AS [Exchange Type], 0 AS Count     
    FROM Customupdownload ORDER BY SlNo     
   End    
  IF @piVal1 = 2     
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Upload'    
   End    
  IF @piVal1 = 3    
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Download'    
   End    
 End    
 IF @piTypeId = 7 -- Sync Status Validation,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3    
 Begin    
 
  IF Exists(Select * from SyncStatus Where DistCode = @piCode and SyncId = @piVal2)        
   Begin        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End        
  Else        
   Begin        
    Delete From SyncStatus Where DistCode = @piCode and SyncStatus = 1  
    IF Not Exists (Select * From  SyncStatus (Nolock))
    Begin  
		Insert into SyncStatus Select @piCode,@piVal2,Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),0,'N'
    End        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End      
 End    
 IF @piTypeId = 8 -- Select Current SyncId,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select IsNull(MAX(SyncId),0) From SyncStatus    
 End     
 IF @piTypeId = 9 -- Select Syncstatus for this SyncId,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin    
  Select IsNull(Max(SyncStatus),0) From SyncStatus where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1    
 End      
 IF @piTypeId = 10 -- DB Restoration Concept,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
   Begin    
    Select Count(*) From DefendRestore    
   End     
  IF @piVal1 = 2    
   Begin    
    update DefendRestore Set DbStatus = 1,ReqId = 1,CCLockStatus = 1    
   End       
  IF @piVal1 = 3    
   Begin    
    Insert into DefendRestore (AccessCode,LastModDate,DbStatus,ReqId,CCLockStatus)
    Values('',GETDATE(),1,1,1)    
   End     
 End       
 IF @piTypeId = 11 -- AAD & Configuration Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId='BotreeSyncCheck'    
  End     
  IF @piVal1 = 2    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId LIKE 'BotreeSyncErrLog'    
  End       
  IF @piVal1 = 3    
  Begin    
   Select IsNull(Max(FixID),0) from Hotfixlog (NOLOCK)    
  End       
 End       
 IF @piTypeId = 12 -- System Date is less than the Last Transaction Date Validation,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT ISNULL(MAX(TransDate),GETDATE()-1) AS TransDate FROM StockLedger    
 End     
 IF @piTypeId = 13 -- DayEnd Process Updation,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  UPDATE DayEndProcess SET NextUpDate=@piCode WHERE ProcId=13    
 End     
 IF @piTypeId = 14 -- Update Sync Attempt Status ,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  Select @piCode =  HostName From Sys.sysprocesses where  status='RUNNABLE'    
  Update SyncAttempt Set Status=0 where IPAddress = @piCode    
 End      
 IF @piTypeId = 15 -- Latest SyncId from Sync_Master ,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select ISNull(Max(SyncId),0) From Sync_Master    
 End     
 IF @piTypeId = 16 -- Update the Flag as Y for all lesser than the latest Serial No ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
	 IF ((Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N') > 0)        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo >=   
	   (Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N')         
	  End        
	  Else        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal1 And SlNo <= @piVal2 
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo > @piVal2    
	  End 
 End      
 IF @piTypeId = 17 -- Record Count ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   Select Count(*) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2 and UploadFlag = 'N'    
  End    
  IF @piVal1 = 2     
  Begin    
   Select Count(Distinct Slno) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2     
  End       
  IF @piVal1 = 3     
  Begin    
   Select IsNull(Count(*),0) From SyncStatus (Nolock) Where DistCode = @piCode And SyncId = @piVal2 And SyncFlag = 'Y'     
  End    
 End      
 IF @piTypeId = 18 -- Datapreperation Process and Split each 1000 rows for xml file ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   SELECT * FROM  CustomUpDownload  WHERE SlNo=@piVal2  AND UpDownload='Upload' ORDER BY UpDownLoad,SlNo,SeqNo    
  End    
  IF @piVal1 = 2     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 3    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End        
  IF @piVal1 = 4    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT * FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE  SlNo= ' + Convert(Varchar(100),@piVal2) + '  ORDER BY UpDownLoad,SlNo,SeqNo '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 5    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM   ' + Convert(Varchar(100),@piCode) + '  '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 6    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' DELETE  FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE Downloadflag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 7    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE DownloadFlag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 8    
  Begin    
   Set @Sql = ''    
  Set @Sql = @Sql + ' SELECT TRowCount FROM Tbl_DownloadIntegration_Process WHERE PrkTableName =''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 9    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = 0  WHERE ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 10    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = ' + Convert(Varchar(100),@piVal2) + ' where ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 11     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MAX(SlNo),0) AS Cnt FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 12     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End      
  IF @piVal1 = 13     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 14     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Upload'' '    
   Exec (@Sql)    
  End         
  IF @piVal1 = 15     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS DownloadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Download'' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 16     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 17     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus_Download (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 18
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' SELECT * FROM ' + Convert(Varchar(100),@piCode) + ' As DU WHERE UploadFlag=''N'' AND SlNo BETWEEN  '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' ORDER BY SlNo  FOR XML AUTO '
		Select @Sql
	End	
  IF @piVal1 = 19
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''X'' WHERE UploadFlag=''N'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 20
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''Y'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 21
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''N'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	  

 End      
 IF @piTypeId = 19 -- View Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT * FROM ErrorLog WITH (NOLOCK)    
 End    
 IF @piTypeId = 20 -- Remove Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  DELETE FROM ErrorLog     
 End     
 IF @piTypeId = 21 -- Download Notification Details Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM  CustomUpDownloadCount WHERE UpDownload='Download' ORDER BY SlNo    
 End     
 IF @piTypeId = 22 -- Download Details to xml file ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='N'    
 End     
 IF @piTypeId = 23 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_DownloadIntegration_Process ORDER BY SequenceNo    
 End     
 IF @piTypeId = 24 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_DownloadIntegration_Process SET TRowCount=0    
 End      
 IF @piTypeId = 25 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_DownloadIntegration_Process WHERE ProcessName = @piCode    
 End      
 IF @piTypeId = 26 -- Upload Consolidated Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_UploadIntegration_Process ORDER BY SequenceNo    
 End      
 IF @piTypeId = 27 -- Download Details   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT DISTINCT Module,DownloadedCount FROM CustomUpDownloadCount WHERE UpDownload='Download' AND DownloadedCount>0    
 End      
 IF @piTypeId = 28 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeReDownload'    
 End     
 IF @piTypeId = 29 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM ReDownLoadRequest    
 End     
 IF @piTypeId = 30 -- Showboard    ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeBBOardOnSync' AND Status=1    
 End     
 IF @piTypeId = 31 -- Update sync status if disconnect    ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin     
  IF Not Exists (Select * From CS2Console_Consolidated (nolock) Where DistCode = @piCode And Syncid = @piVal1 And UploadFlag='N')    
  Begin    
   Update Syncstatus Set Syncstatus = 1 Where DistCode = @piCode And Syncid = @piVal1    
   Select IsNull(Max(SyncStatus),0) From SyncStatus (nolock) Where DistCode = @piCode And Syncid = @piVal1    
  End    
 End     
 IF @piTypeId = 32 -- Update sync status if disconnect,Proc_SyncValidation @piTypeId,@piCode,@piVal1    
 Begin     
  Declare @RETVAL Varchar(Max)    
  Set @RETVAL = ''    
  IF EXISTS (Select * From Chk_MainSalesIMEIUploadCnt (NOLOCK))    
  Begin      
  Select @RETVAL = Cast(COALESCE(@RETVAL + ', ', '') + Convert(Varchar(40),MainTblBillNo) as ntext) From Chk_MainSalesIMEIUploadCnt       
  Select @RETVAL    
  End    
 End    
 IF @piTypeId = 33 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select 'Request given for approval so please approve from Central Help Desk.'      
 End      
 IF @piTypeId = 34 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select IsNull(LTrim(RTrim(CmpCode)),'') From Company (Nolock) Where DefaultCompany = 1      
 End      
 IF @piTypeId = 35 -- Select Download Sync status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin       
  Select IsNull(SyncStatus,0) from Syncstatus_Download (nolock) Where Distcode = @picode and Syncid = @pival1    
 End      
 IF @piTypeId = 36 -- Select Max(Syncid) in Download Sync Status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SyncId),0) From SyncStatus_Download (Nolock)    
 End      
 IF @piTypeId = 37 -- Select Max(SlNo) in Console2CS_Consolidated  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SlNo),0) From Console2CS_Consolidated (Nolock) Where Distcode = @picode and Syncid = @pival1    
 End       
 IF @piTypeId = 38 -- Syncstatus  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin       
 Declare @RetState Int    
 IF Exists (Select * From SyncStatus (Nolock) where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1)    
  Begin    
    IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
     Begin    
      Set @RetState = 1 -- Upload and Download Completed Successfully        
     End    
    Else    
     Begin    
      Set @RetState = 2 -- Upload Completed, Download Incomplete     
     End    
  End    
  Else    
  Begin    
    IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
     Begin    
      Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully          
     End    
    Else    
     Begin    
      Set @RetState = 4 -- Upload and Download Incomplete!!!           
     End    
  End    
  Select @RetState    
 End       
 IF @piTypeId = 39 -- Update Download Sync Status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3      
 Begin       
 -------    
  IF Exists(Select * from SyncStatus_Download Where DistCode = @piCode and SyncId = @piVal2)                
   Begin                
    IF @piVal1 = 1                
    Begin              
     IF Exists(Select * From Console2CS_Consolidated (Nolock) Where DistCode = @piCode and SyncId = @piVal2)        
     Begin        
     Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2        
     End        
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2             
      End        
     End             
   End                
  Else                
   Begin                
    Insert into SyncStatus_Download_Archieve  Select *,Getdate() from SyncStatus_Download Where DistCode = @piCode           
    Delete From SyncStatus_Download Where DistCode = @piCode               
    Insert into SyncStatus_Download Select @piCode,@piVal2,Getdate(),Getdate(),0,0                
    Insert into SyncStatus_Download_Archieve Select @piCode,@piVal2,Getdate(),Getdate(),0,0,GETDATE()                 
    IF @piVal1 = 1                
    Begin                
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock) Where DistCode = @piCode and SyncId = @piVal2             
      End         
     End             
   End      
 ------    
 END      
  IF @piTypeId = 40 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_Customdownloadintegration ORDER BY SequenceNo    
 End     
 IF @piTypeId = 41 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_Customdownloadintegration SET TRowCount=0    
 End 
 IF @piTypeId = 42 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_Downloadintegration WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 43 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT TRowCount FROM Tbl_Customdownloadintegration WHERE PrkTableName = @piCode    
 End 
 IF @piTypeId = 44 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  Update Tbl_Customdownloadintegration Set TRowCount = @piVal1 WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 45 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId  
 Begin   
	Set @IntRetVal = 0  
	IF @piVal1 = 1
	Begin
		If Exists (Select * From sys.Objects where TYPE='U' and name ='UtilityProcess')  
		 Begin  
		  IF Exists (Select * from UtilityProcess where ProcId = 3)  
		  Begin  
		   IF ((Select Convert(Varchar(100),VersionId) from UtilityProcess where ProcId = 3) <> @piCode)  
		   Begin  
			Set @IntRetVal = 1      
		   End     
		  End  
		 End  
	End   
	IF @piVal1 = 2
	Begin
		If Not Exists (Select * From AppTitle (Nolock) Where  SynVersion = @piCode)  
		 Begin  
			Set @IntRetVal = 1
		 End
	End
	Select @IntRetVal 
 End  	
 IF @piTypeId = 46 -- Data Purge  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	IF Exists (Select * From Sys.objects Where name = 'DataPurgeDetails' and TYPE='U')
	Begin
		IF EXISTS (Select * From DataPurgeDetails)
		Begin
			Set @IntRetVal = 0
		End
	End
	Select @IntRetVal	
 End
 IF @piTypeId = 47 -- Update In Active Distributor  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	--IF Exists (Select * From Sys.objects Where name = 'Distributor' and TYPE='U')
	--Begin
	--	Update Distributor Set DistStatus = 0 Where DistributorCode = @piCode
	--End
 End

----------Additional Validation----------    
------------------------------------------    
END
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE Name = 'Sync_ErrorLog' AND Xtype = 'U')
BEGIN
CREATE TABLE Sync_ErrorLog(
	[SP_Name] [varchar](250) NULL,
	[ErrorMessage] [varchar](6000) NULL,
	[ErrorDate] [datetime] NULL
)
END
GO
IF EXISTS (SELECT NAME FROM Sysobjects WHERE XTYPE='P' AND name='Proc_PopulateToBeUploaded')
DROP PROCEDURE Proc_PopulateToBeUploaded
GO
--Exec Proc_PopulateToBeUploaded 0
CREATE PROCEDURE Proc_PopulateToBeUploaded
(
@Po_ErrNo INT OUTPUT
)
As
Begin

BEGIN TRY        
      
SET XACT_ABORT ON        
BEGIN TRANSACTION  

declare @SqlStr varchar(8000)
declare @Process varchar(100)
declare @colcount int
declare @Col varchar(5000)
declare @Tablename varchar(100)
declare @Sequenceno int
declare @Lvar int
declare @MaxId int
Declare @DistCode Varchar(100)
Declare @SyncId Int
SET @Po_ErrNo=0
-- *** upload integration table to be replaced....
Create table #Process(ProcessName varchar(100),PrkTableName varchar(100), id int identity(1,1) )
insert into #Process(ProcessName , PrkTableName) select ProcessName , PrkTableName from Tbl_UploadIntegration order by Sequenceno
Select @DistCode = DistributorCode From Distributor 
Select @SyncId = Max(SyncId) From Sync_Master
--Delete From CS2Console_Consolidated Where UploadFlag = 'Y'
--Delete A From CS2Console_Consolidated  A (Nolock) , SyncStatus B 
--Where A.DistCode = B.DistCode And A.UploadFlag = 'Y' And A.SyncId = B.SyncId And B.SyncStatus <> 0
	----- Added by Anand S on 10.09.2012 -- for handling the DB Restoration - SyncId Mismatch....
	--Declare @SyncSts int
	--Declare @ZCnt int
	--Select @SyncSts = ISNULL(SyncStatus,0) from SyncStatus (nolock)
	--select @ZCnt = Count(*) from CS2Console_Consolidated(nolock) where UploadFlag = 'N' and
	--SyncId = (select isnull(SyncId,0)  from SyncStatus (nolock) )
	--if (@SyncSts = 0 and @ZCnt = 0)
	--begin
	--Update CS2Console_Consolidated set UploadFlag = 'N' where 	SyncId = (select isnull(SyncId,0)  from SyncStatus (nolock) )
	--end
	--- Till Here
Delete A From CS2Console_Consolidated A (nolock) Where SyncId <> (Select ISNULL(MAX(SyncId),0) From SyncStatus)
--Delete A From CS2Console_Consolidated A (nolock) Where SyncId < (Select ISNULL(MAX(SyncId),0) From SyncStatus) AND UploadFlag='Y'
Delete A From CS2Console_Consolidated A (nolock) Where SyncId = (Select ISNULL(MAX(SyncId),0) From SyncStatus WHERE SyncStatus=1) AND UploadFlag='Y' 
IF ((Select Count(*) From CS2Console_Consolidated (nolock)) = 0)
Begin
	Truncate Table CS2Console_Consolidated
End
set @Lvar = 1
select @MaxId = Max(id) from #Process
while @Lvar <= @MaxId
begin
	select @Tablename = PrkTableName , @Process = ProcessName from #Process where id  = @Lvar
	select @colcount = Max(Column_ID) from sys.columns where object_id = (select object_id from sys.objects where name = @Tablename)
	set @SqlStr = ''
	set @SqlStr = @SqlStr + ' Insert into CS2Console_Consolidated '
	set @Col = ''
	select @Col = @Col + name + ',' from sys.columns 
	where object_id = ( select object_id from sys.objects where name = 'CS2Console_Consolidated')
	and column_id  between 2 and @colcount + 5
	set @SqlStr = @SqlStr + '(' + left(@Col,len(@Col)-1)  + ',UploadFlag)'
	
	set @Col = ''
	--select @Col = @Col + name + ',' from sys.columns 
	select @Col = @Col + (Case when (name = 'UploadedDate' Or name = 'ServerDate') Then  'CONVERT(VARCHAR(19),[' + name + '],121)' else 'REPLACE(['+name + '],'''''''','''')'  end)+ ',' from sys.columns 
	where Object_Id = ( select Object_Id from sys.objects where name = @Tablename)
	and column_id  <= @colcount
	set @SqlStr = @SqlStr + 'Select '''+ CONVERT(Varchar(50),@DistCode) + ''','+ CONVERT(Varchar(50),@SyncId) + ',''' + @Process + ''' ,getdate(), '
    set @SqlStr = @SqlStr + ' ' + left(@Col,len(@Col)-1)  + ',''N'' from ' + @Tablename + '(nolock) where UploadFlag = ''N''  And SyncId Is Not Null  Order By SlNo '
	--Print(@SqlStr)
	exec (@SqlStr)
	set @SqlStr = ''
	set @SqlStr = @SqlStr + ' Update B Set B.UploadFlag = ''Y'' From CS2Console_Consolidated A (Nolock),  ' + @Tablename  + ' B (nolock) '
	set @SqlStr = @SqlStr + ' Where A.DistCode = B.DistCode and a.SyncId = b.SyncId and A.ProcessName = ''' + @Process + '''  And A.SyncId Is Not Null '
	exec (@SqlStr)
	--Print(@SqlStr)
	set @SqlStr = ''
	
set @Lvar = @Lvar + 1
end
	Update SyncStatus Set SyncFlag = 'Y' Where DistCode=@DistCode And SyncId = @SyncId

	Create Table #SPLTBL (Id INT Identity(1,1),CId INT,CName VARCHAR(200),CType VARCHAR(100))
	INSERT INTO #SPLTBL
	SELECT A.column_id AS CId,A.Name,C.name AS CType FROM Sys.columns A,Sys.objects B,Sys.types C 
	WHERE A.object_id = B.object_id and B.name = 'CS2Console_Consolidated'
	And A.system_type_id = C.system_type_id And C.name='VARCHAR'
	Order by A.column_id 
	DECLARE @CName VARCHAR(100)
	SET @Lvar = 1
	SET @CName = ''
	SELECT @MaxId = IsNull(Count(CId),0) FROM #SPLTBL
	While @Lvar <= @MaxId
	Begin
		SELECT @CName = CName FROM #SPLTBL WHERE Id = @Lvar
		SET @SqlStr = ''
		SET @SqlStr = @SqlStr + ' UPDATE CS2Console_Consolidated  SET '+ @CName + ' = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(' + @CName + ','''''''',''''),''"'',''''),''&'',''''),''<'',''''),''>'','''') '
		Print (@SqlStr)
		exec (@SqlStr)
		
		SET @SqlStr = ''
		SET @SqlStr = @SqlStr + ' UPDATE CS2Console_Consolidated  SET '+ @CName + ' = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(' + @CName + ',''\r'',''''),''\n'',''''),''\f'',''''),''\p'',''''),''\t'',''''),''\s'','''') '
		Print (@SqlStr)
		exec (@SqlStr)
				
		SET @Lvar = @Lvar + 1
	End

COMMIT TRANSACTION        
        
 END TRY        
         
 BEGIN CATCH        
  ROLLBACK TRANSACTION        
  INSERT INTO Sync_ErrorLog VALUES ('Proc_PopulateToBeUploaded', ERROR_MESSAGE(), GETDATE())        
 END CATCH        

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_CheckDataPurge]') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_CheckDataPurge
GO
CREATE PROCEDURE Proc_CheckDataPurge
AS
BEGIN
DECLARE @RetVal INT
SET @RetVal = 1
IF EXISTS (SELECT * FROM Sys.objects Where name = 'DataPurgeDetails' and TYPE='U')
BEGIN
	IF EXISTS (SELECT * FROm DataPurgeDetails)
	BEGIN
		Set @RetVal = 0
	END
END
SELECT @RetVal
END
GO
---------------- Console Script Ended--------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_HierarchyLevel]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_HierarchyLevel]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_HierarchyLevel](
	[DistCode] [nvarchar](50) NULL,
	[HierarchyType] [int] NULL,
	[LevelCount] [int] NULL,
	[LevelName] [nvarchar](100) NULL,
	[HierarchyLevelName] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_HierarchyLevelValue]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_HierarchyLevelValue]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_HierarchyLevelValue](
	[DistCode] [nvarchar](50) NULL,
	[HierarchyType] [int] NULL,
	[LevelName] [nvarchar](100) NULL,
	[ParentCode] [nvarchar](50) NULL,
	[HierarchyCode] [nvarchar](50) NULL,
	[HierarchyName] [nvarchar](100) NULL,
	[AddInfo1] [nvarchar](100) NULL,
	[AddInfo2] [nvarchar](100) NULL,
	[AddInfo3] [nvarchar](100) NULL,
	[AddInfo4] [nvarchar](100) NULL,
	[AddInfo5] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_BLRetailerCategoryLevelValue]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_BLRetailerCategoryLevelValue]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_BLRetailerCategoryLevelValue](
	[DistCode] [nvarchar](50) NULL,
	[Hierarchy Level Code] [nvarchar](100) NULL,
	[Parent Hierarchy Level Value Code] [nvarchar](100) NULL,
	[Hierarchy Level Value Code] [nvarchar](100) NULL,
	[Hierarchy Level Value Name] [nvarchar](100) NULL,
	[Company Code] [nvarchar](100) NULL,
	[DownloadFlag] [nvarchar](5) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_BLRetailerValueClass]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_BLRetailerValueClass]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_BLRetailerValueClass](
	[DistCode] [nvarchar](50) NULL,
	[CmpCode] [nvarchar](100) NULL,
	[ChannelCode] [nvarchar](100) NULL,
	[ClassCode] [nvarchar](100) NULL,
	[ClassDesc] [nvarchar](100) NULL,
	[TrunOver] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](5) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_PrefixMaster]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_PrefixMaster]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_PrefixMaster](
	[DistCode] [nvarchar](20) NULL,
	[MasterType] [int] NULL,
	[RtrPrefix] [nvarchar](50) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_RetailerApproval]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_RetailerApproval]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_RetailerApproval](
	[DistCode] [nvarchar](200) NULL,
	[RtrCode] [nvarchar](100) NULL,
	[CmpRtrCode] [nvarchar](100) NULL,
	[RtrChannelCode] [nvarchar](100) NULL,
	[RtrGroupCode] [nvarchar](100) NULL,
	[RtrClassCode] [nvarchar](100) NULL,
	[Status] [nvarchar](100) NULL,
	[KeyAccount] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_BLUOM]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_BLUOM]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_BLUOM](
	[DistCode] [nvarchar](50) NULL,
	[UOMGroupCode] [nvarchar](100) NULL,
	[UOMGroupName] [nvarchar](100) NULL,
	[UOMCode] [nvarchar](100) NULL,
	[UOMName] [nvarchar](100) NULL,
	[BaseUOM] [nvarchar](100) NULL,
	[ConvFact] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](5) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ETL_Prk_TaxConfig_GroupSetting]') AND type in (N'U'))
DROP TABLE [dbo].[ETL_Prk_TaxConfig_GroupSetting]
GO
CREATE TABLE [dbo].[ETL_Prk_TaxConfig_GroupSetting](
	[DistCode] [nvarchar](50) NULL,
	[TaxId] [int] NULL,
	[TaxCode] [nvarchar](200) NULL,
	[TaxName] [nvarchar](200) NULL,
	[TaxGroupCode] [nvarchar](200) NULL,
	[TaxGroupName] [nvarchar](200) NULL,
	[GroupType] [nvarchar](200) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ETL_Prk_TaxSetting]') AND type in (N'U'))
DROP TABLE [dbo].[ETL_Prk_TaxSetting]
GO
CREATE TABLE [dbo].[ETL_Prk_TaxSetting](
	[DistCode] [nvarchar](50) NULL,
	[TaxGroupCode] [nvarchar](200) NULL,
	[Type] [nvarchar](200) NULL,
	[PrdTaxGroupCode] [nvarchar](200) NULL,
	[TaxCode] [nvarchar](200) NULL,
	[Percentage] [numeric](38, 6) NULL,
	[ApplyOn] [nvarchar](200) NULL,
	[Discount] [nvarchar](200) NULL,
	[SchDiscount] [nvarchar](200) NULL,
	[DBDiscount] [nvarchar](200) NULL,
	[CDDiscount] [nvarchar](200) NULL,
	[ApplyTax] [nvarchar](200) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_BLProductHiereachyChange]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_BLProductHiereachyChange]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_BLProductHiereachyChange](
	[DistCode] [nvarchar](20) NULL,
	[BusinessCode] [nvarchar](50) NULL,
	[BusinessName] [nvarchar](50) NULL,
	[CategoryCode] [nvarchar](50) NULL,
	[CategoryName] [nvarchar](50) NULL,
	[FamilyCode] [nvarchar](50) NULL,
	[FamilyName] [nvarchar](50) NULL,
	[GroupCode] [nvarchar](50) NULL,
	[GroupName] [nvarchar](50) NULL,
	[SubGroupCode] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[BrandCode] [nvarchar](50) NULL,
	[BrandName] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](5) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_Product]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_Product]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_Product](
	[DistCode] [nvarchar](20) NULL,
	[BusinessCode] [nvarchar](50) NULL,
	[BusinessName] [nvarchar](50) NULL,
	[CategoryCode] [nvarchar](50) NULL,
	[CategoryName] [nvarchar](50) NULL,
	[FamilyCode] [nvarchar](50) NULL,
	[FamilyName] [nvarchar](50) NULL,
	[GroupCode] [nvarchar](50) NULL,
	[GroupName] [nvarchar](50) NULL,
	[SubGroupCode] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[BrandCode] [nvarchar](50) NULL,
	[BrandName] [nvarchar](50) NULL,
	[AddHier1Code] [nvarchar](50) NULL,
	[AddHier1Name] [nvarchar](50) NULL,
	[AddHier2Code] [nvarchar](50) NULL,
	[AddHier2Name] [nvarchar](50) NULL,
	[AddHier3Code] [nvarchar](50) NULL,
	[AddHier3Name] [nvarchar](50) NULL,
	[AddHier4Code] [nvarchar](50) NULL,
	[AddHier4Name] [nvarchar](50) NULL,
	[AddHier5Code] [nvarchar](50) NULL,
	[AddHier5Name] [nvarchar](50) NULL,
	[AddHier6Code] [nvarchar](50) NULL,
	[AddHier6Name] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdWgt] [numeric](38, 6) NULL,
	[UOMGroupCode] [nvarchar](50) NULL,
	[PrdUPC] [int] NULL,
	[SerialNo] [nvarchar](50) NULL,
	[EANCode] [nvarchar](50) NULL,
	[Vending] [nvarchar](10) NULL,
	[ProductType] [nvarchar](100) NULL,
	[ProductUnit] [nvarchar](100) NULL,
	[ProductStatus] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](5) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_ProductBatch]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_ProductBatch]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_ProductBatch](
	[DistCode] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](200) NULL,
	[PrdBatCode] [nvarchar](200) NULL,
	[ManufacturingDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[EffectiveDate] [datetime] NULL,
	[MRP] [numeric](38, 6) NULL,
	[ListPrice] [numeric](38, 6) NULL,
	[SellingRate] [numeric](38, 6) NULL,
	[ClaimRate] [numeric](38, 6) NULL,
	[AddRate1] [numeric](38, 6) NULL,
	[AddRate2] [numeric](38, 6) NULL,
	[AddRate3] [numeric](38, 6) NULL,
	[AddRate4] [numeric](38, 6) NULL,
	[AddRate5] [numeric](38, 6) NULL,
	[AddRate6] [numeric](38, 6) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ETL_Prk_TaxMapping]') AND type in (N'U'))
DROP TABLE [dbo].[ETL_Prk_TaxMapping]
GO
CREATE TABLE [dbo].[ETL_Prk_TaxMapping](
	[DistCode] [nvarchar](200) NULL,
	[PrdCode] [nvarchar](200) NULL,
	[TaxGroupCode] [nvarchar](200) NULL,
	[MapStatus] [int] NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_SpecialRate]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_SpecialRate]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_SpecialRate](
	[DistCode] [nvarchar](50) NULL,
	[CtgLevelName] [nvarchar](100) NULL,
	[CtgCode] [nvarchar](100) NULL,
	[RtrCode] [nvarchar](100) NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[SpecialSellingRate] [numeric](38, 6) NULL,
	[EffectiveFromDate] [datetime] NULL,
	[EffectiveToDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[DownLoadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Etl_Prk_SchemeHD_Slabs_Rules]') AND type in (N'U'))
DROP TABLE [dbo].[Etl_Prk_SchemeHD_Slabs_Rules]
GO
CREATE TABLE [dbo].[Etl_Prk_SchemeHD_Slabs_Rules](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](100) NULL,
	[SchDsc] [nvarchar](200) NULL,
	[CmpCode] [nvarchar](50) NULL,
	[Claimable] [nvarchar](40) NULL,
	[ClmAmton] [nvarchar](100) NULL,
	[ClmGroupCode] [nvarchar](100) NULL,
	[SchLevel] [nvarchar](200) NULL,
	[SchType] [nvarchar](80) NULL,
	[BatchLevel] [nvarchar](100) NULL,
	[FlexiSch] [nvarchar](50) NULL,
	[FlexiSchType] [nvarchar](50) NULL,
	[CombiSch] [nvarchar](30) NULL,
	[Range] [nvarchar](30) NULL,
	[ProRata] [nvarchar](50) NULL,
	[QPS] [nvarchar](50) NULL,
	[QPSReset] [nvarchar](50) NULL,
	[ApyQPSSch] [nvarchar](50) NULL,
	[SchValidFrom] [nvarchar](40) NULL,
	[SchValidTill] [nvarchar](40) NULL,
	[SchStatus] [nvarchar](50) NULL,
	[Budget] [nvarchar](50) NULL,
	[AdjWinDispOnlyOnce] [nvarchar](30) NULL,
	[PurofEvery] [nvarchar](30) NULL,
	[SetWindowDisp] [nvarchar](30) NULL,
	[EditScheme] [nvarchar](30) NULL,
	[SchemeLevelMode] [nvarchar](200) NULL,
	[BudgetAllocationNo] [varchar](100) NULL,
	[SlabId] [nvarchar](40) NULL,
	[PurQty] [nvarchar](40) NULL,
	[FromQty] [nvarchar](40) NULL,
	[Uom] [nvarchar](200) NULL,
	[ToQty] [nvarchar](40) NULL,
	[ToUom] [nvarchar](200) NULL,
	[ForEveryQty] [nvarchar](40) NULL,
	[ForEveryUom] [nvarchar](200) NULL,
	[DiscPer] [nvarchar](40) NULL,
	[FlatAmt] [nvarchar](40) NULL,
	[FlxDisc] [nvarchar](40) NULL,
	[FlxValueDisc] [nvarchar](40) NULL,
	[FlxFreePrd] [nvarchar](100) NULL,
	[FlxGiftPrd] [nvarchar](100) NULL,
	[FlxPoints] [nvarchar](40) NULL,
	[Points] [nvarchar](40) NULL,
	[MaxDiscount] [nvarchar](40) NULL,
	[MinDiscount] [nvarchar](40) NULL,
	[MaxValue] [nvarchar](40) NULL,
	[MinValue] [nvarchar](40) NULL,
	[MaxPoints] [nvarchar](40) NULL,
	[MinPoints] [nvarchar](40) NULL,
	[SchConfig] [nvarchar](50) NULL,
	[SchRules] [nvarchar](200) NULL,
	[NoofBills] [nvarchar](50) NULL,
	[FromDate] [nvarchar](30) NULL,
	[ToDate] [nvarchar](30) NULL,
	[MarketVisit] [nvarchar](30) NULL,
	[ApplySchBasedOn] [nvarchar](100) NULL,
	[EnableRtrLvl] [nvarchar](30) NULL,
	[AllowSaving] [nvarchar](40) NULL,
	[AllowSelection] [nvarchar](40) NULL,
	[DownloadFlag] [varchar](10) NULL,
	[FBM] [nvarchar](10) NULL,
	[SchBasedOn] [nvarchar](50) NULL,	
	[SettlementType] [nvarchar](10) NULL,
	[AllowUncheck] [nvarchar](10) NULL,
	[CombiType] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Etl_Prk_SchemeHD_Slabs_Rules] ADD  DEFAULT ('ALL') FOR [SettlementType]
GO
ALTER TABLE [dbo].[Etl_Prk_SchemeHD_Slabs_Rules] ADD  DEFAULT ('NORMAL') FOR [CombiType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Etl_Prk_SchemeProducts_Combi]') AND type in (N'U'))
DROP TABLE [dbo].[Etl_Prk_SchemeProducts_Combi]
GO
CREATE TABLE [dbo].[Etl_Prk_SchemeProducts_Combi](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](200) NULL,
	[SlabId] [nvarchar](200) NULL,
	[SchLevel] [nvarchar](200) NULL,
	[PrdCode] [nvarchar](200) NULL,
	[PrdBatCode] [nvarchar](200) NULL,
	[SlabValue] [nvarchar](200) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Etl_Prk_Scheme_OnAttributes]') AND type in (N'U'))
DROP TABLE [dbo].[Etl_Prk_Scheme_OnAttributes]
GO
CREATE TABLE [dbo].[Etl_Prk_Scheme_OnAttributes](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](200) NULL,
	[AttrType] [nvarchar](200) NULL,
	[AttrName] [nvarchar](200) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Etl_Prk_Scheme_Free_Multi_Products]') AND type in (N'U'))
DROP TABLE [dbo].[Etl_Prk_Scheme_Free_Multi_Products]
GO
CREATE TABLE [dbo].[Etl_Prk_Scheme_Free_Multi_Products](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](200) NULL,
	[SlabId] [nvarchar](200) NULL,
	[PrdCode] [nvarchar](200) NULL,
	[FreeQty] [nvarchar](200) NULL,
	[OpnANDOR] [nvarchar](200) NULL,
	[SeqId] [nvarchar](200) NULL,
	[Type] [nvarchar](200) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Etl_Prk_Scheme_OnAnotherPrd]') AND type in (N'U'))
DROP TABLE [dbo].[Etl_Prk_Scheme_OnAnotherPrd]
GO
CREATE TABLE [dbo].[Etl_Prk_Scheme_OnAnotherPrd](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](200) NULL,
	[SlabId] [nvarchar](200) NULL,
	[SchType] [nvarchar](200) NULL,
	[SchLevel] [nvarchar](200) NULL,
	[SchLevelMode] [nvarchar](200) NULL,
	[Range] [nvarchar](200) NULL,
	[PrdType] [nvarchar](200) NULL,
	[PrdCode] [nvarchar](200) NULL,
	[PurQty] [nvarchar](200) NULL,
	[PurFrmQty] [nvarchar](200) NULL,
	[PurUom] [nvarchar](200) NULL,
	[PurToQty] [nvarchar](200) NULL,
	[PurToUom] [nvarchar](200) NULL,
	[PurofEveryQty] [nvarchar](200) NULL,
	[PurofUom] [nvarchar](200) NULL,
	[DiscPer] [nvarchar](200) NULL,
	[FlatAmt] [nvarchar](200) NULL,
	[Points] [nvarchar](200) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Etl_Prk_Scheme_RetailerLevelValid]') AND type in (N'U'))
DROP TABLE [dbo].[Etl_Prk_Scheme_RetailerLevelValid]
GO
CREATE TABLE [dbo].[Etl_Prk_Scheme_RetailerLevelValid](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](200) NULL,
	[RtrCode] [nvarchar](200) NULL,
	[FromDate] [nvarchar](200) NULL,
	[ToDate] [nvarchar](200) NULL,
	[BudgetAllocated] [nvarchar](200) NULL,
	[Status] [nvarchar](200) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_BLPurchaseReceipt]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_BLPurchaseReceipt]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_BLPurchaseReceipt](
	[DistCode] [varchar](50) NULL,
	[CompInvNo] [varchar](25) NULL,
	[CompInvDate] [datetime] NULL,
	[NetValue] [numeric](18, 2) NULL,
	[TotalTax] [numeric](18, 2) NULL,
	[LessDiscount] [numeric](18, 2) NULL,
	[LessSchemeAmount] [numeric](18, 2) NULL,
	[SupplierCode] [varchar](50) NULL,
	[CompanyName] [varchar](100) NULL,
	[TransporterName] [varchar](50) NULL,
	[LRNO] [varchar](15) NULL,
	[LRDate] [datetime] NULL,
	[WayBillNo] [varchar](50) NULL,
	[ProductCode] [varchar](100) NULL,
	[UOMCode] [varchar](25) NULL,
	[PurQty] [int] NULL,
	[CashDiscRs] [numeric](18, 2) NULL,
	[CashDiscPer] [numeric](18, 2) NULL,
	[LineLevelAmount] [numeric](18, 2) NULL,
	[BatchNo] [varchar](200) NULL,
	[ManufactureDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[MRP] [numeric](18, 2) NULL,
	[ListPriceNSP] [numeric](18, 2) NULL,
	[PurchaseTaxValue] [numeric](18, 2) NULL,
	[PurchaseDiscount] [numeric](18, 2) NULL,
	[PurchaseRate] [numeric](18, 2) NULL,
	[SellingRate] [numeric](18, 2) NULL,
	[SellingRateAfterTAX] [numeric](18, 2) NULL,
	[SellingRateAfterVAT] [numeric](18, 2) NULL,
	[FreightCharges] [numeric](18, 2) NULL,
	[VatBatch] [int] NULL,
	[VATTaxValue] [numeric](18, 2) NULL,
	[Status] [int] NULL,
	[FreeSchemeFlag] [varchar](5) NULL,
	[SchemeRefrNo] [varchar](25) NULL,
	[BundleDeal] [varchar](50) NULL,
	--[CreatedUserID] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[DownloadFlag] [varchar](1) NULL	
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_PurchaseReceiptMapping]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_PurchaseReceiptMapping]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_PurchaseReceiptMapping](
	[DistCode] [nvarchar](30) NULL,
	[CompInvNo] [nvarchar](25) NULL,
	[CompInvDate] [datetime] NULL,
	[SupplierCode] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdMapCode] [nvarchar](50) NULL,
	[PrdMapName] [nvarchar](200) NULL,
	[UOMCode] [nvarchar](25) NULL,
	[Qty] [int] NULL,
	[Rate] [numeric](38, 6) NULL,
	[GrossAmount] [numeric](38, 6) NULL,
	[DiscAmount] [numeric](38, 6) NULL,
	[TaxAmount] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[FreeSchemeFlag] [nvarchar](5) NULL,
	[SlNo] [int] NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_NVSchemeMasterControl]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_NVSchemeMasterControl]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_NVSchemeMasterControl](
	[DistCode] [nvarchar](200) NULL,
	[CmpSchCode] [nvarchar](100) NULL,
	[ChangeType] [nvarchar](100) NULL,
	[Description] [nvarchar](100) NULL,
	[FromValue] [nvarchar](100) NULL,
	[ToValue] [nvarchar](100) NULL,
	[ResField1] [nvarchar](100) NULL,
	[ResField2] [nvarchar](100) NULL,
	[ResField3] [nvarchar](100) NULL,
	[ResField4] [nvarchar](100) NULL,
	[ResField5] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](5) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_ClaimNorm]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_ClaimNorm]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_ClaimNorm](
	[DistCode] [nvarchar](50) NULL,
	[ClaimGroupCode] [nvarchar](50) NULL,
	[ClaimGroupName] [nvarchar](200) NULL,
	[ClaimablePerc] [numeric](38, 6) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_ReasonMaster]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_ReasonMaster]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_ReasonMaster](
	[DistCode] [nvarchar](50) NULL,
	[ReasonCode] [nvarchar](20) NULL,
	[Description] [nvarchar](50) NULL,
	[ApplicableTo] [nvarchar](50) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_BulletinBoard]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_BulletinBoard]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_BulletinBoard](
	[Distcode] [nvarchar](50) NULL,
	[MessageCode] [nvarchar](100) NULL,
	[Subject] [nvarchar](200) NULL,
	[MessageDesc] [nvarchar](2000) NULL,
	[Attachement] [nvarchar](500) NULL,
	[DownloadFlag] [nvarchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_ERPPrdCCodeMapping]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_ERPPrdCCodeMapping]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_ERPPrdCCodeMapping](
	[DistCode] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[ERPPrdCode] [nvarchar](100) NULL,
	[PrdShrtName] [nvarchar](500) NULL,
	[MappedDate] [datetime] NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_Configuration]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_Configuration]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_Configuration](
	[DistCode] [nvarchar](100) NULL,
	[ModuleId] [nvarchar](100) NULL,
	[ModuleName] [nvarchar](100) NULL,
	[Description] [nvarchar](100) NULL,
	[Status] [int] NULL,
	[Condition] [nvarchar](100) NULL,
	[ConfigValue] [numeric](38, 6) NULL,
	[SeqNo] [numeric](38, 6) NULL,
	[DownLoadFlag] [nvarchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_ClaimSettlementDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_ClaimSettlementDetails]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_ClaimSettlementDetails](
	[DistCode] [nvarchar](50) NULL,
	[ClaimSheetNo] [nvarchar](200) NULL,
	[ClaimRefNo] [nvarchar](200) NULL,
	[CreditNoteNo] [nvarchar](100) NULL,
	[DebitNoteNo] [nvarchar](100) NULL,
	[CreditDebitNoteDate] [nvarchar](50) NULL,
	[CreditDebitNoteAmt] [numeric](38, 6) NULL,
	[CreditDebitNoteReason] [nvarchar](250) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_ClusterMaster]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_ClusterMaster]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_ClusterMaster](
	[DistCode] [nvarchar](50) NULL,
	[ClusterCode] [nvarchar](50) NULL,
	[ClusterName] [nvarchar](100) NULL,
	[Remarks] [nvarchar](200) NULL,
	[Value] [numeric](38, 6) NULL,
	[PrdCtgLevelCode] [nvarchar](100) NULL,
	[Salesman] [nvarchar](10) NULL,
	[Retailer] [nvarchar](10) NULL,
	[AddMast1] [nvarchar](10) NULL,
	[AddMast2] [nvarchar](10) NULL,
	[AddMast3] [nvarchar](10) NULL,
	[AddMast4] [nvarchar](10) NULL,
	[AddMast5] [nvarchar](10) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_ClusterGroup]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_ClusterGroup]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_ClusterGroup](
	[DistCode] [nvarchar](50) NULL,
	[ClsGroupCode] [nvarchar](50) NULL,
	[ClsGroupName] [nvarchar](100) NULL,
	[ClsCategory] [nvarchar](50) NULL,
	[AppReqd] [nvarchar](10) NULL,
	[ClsGroupType] [nvarchar](100) NULL,
	[ClusterCode] [nvarchar](50) NULL,
	[ClusterName] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_ClusterAssignApproval]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_ClusterAssignApproval]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_ClusterAssignApproval](
	[DistCode] [nvarchar](50) NULL,
	[MasterCmpCode] [nvarchar](50) NULL,
	[MasterDistCode] [nvarchar](50) NULL,
	[ClusterCode] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[AssignDate] [datetime] NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_SupplierMaster]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_SupplierMaster]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_SupplierMaster](
	[DistCode] [nvarchar](50) NULL,
	[SpmCode] [nvarchar](50) NULL,
	[SpmName] [nvarchar](100) NULL,
	[SpmAdd1] [nvarchar](100) NULL,
	[SpmAdd2] [nvarchar](100) NULL,
	[SpmAdd3] [nvarchar](100) NULL,
	[TaxGroupCode] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](20) NULL,
	[FaxNo] [nvarchar](20) NULL,
	[EmailId] [nvarchar](100) NULL,
	[ContPerson] [nvarchar](100) NULL,
	[DefaultSpm] [nvarchar](10) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_UDCMaster]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_UDCMaster]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_UDCMaster](
	[DistCode] [nvarchar](50) NULL,
	[MasterId] [int] NULL,
	[MasterName] [nvarchar](200) NULL,
	[ColumnName] [nvarchar](50) NULL,
	[ColumnDataType] [nvarchar](50) NULL,
	[ColumnSize] [int] NULL,
	[ColumnPrecision] [int] NULL,
	[Editable] [nvarchar](20) NULL,
	[Mandatory] [nvarchar](20) NULL,
	[PickFromDefault] [nvarchar](20) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_UDCDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_UDCDetails]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_UDCDetails](
	[DistCode] [nvarchar](50) NULL,
	[MasterId] [int] NULL,
	[MasterName] [nvarchar](200) NULL,
	[MasterValueCode] [nvarchar](200) NULL,
	[MasterValueName] [nvarchar](200) NULL,
	[ColumnName] [nvarchar](100) NULL,
	[ColumnValue] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_UDCDefaults]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_UDCDefaults]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_UDCDefaults](
	[DistCode] [nvarchar](100) NULL,
	[MasterName] [nvarchar](100) NULL,
	[ColumnName] [nvarchar](100) NULL,
	[ColumnValue] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_RetailerMigration]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_RetailerMigration]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_RetailerMigration](
	[DistCode] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[CmpRtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[RtrAddress1] [nvarchar](100) NULL,
	[RtrAddress2] [nvarchar](100) NULL,
	[RtrAddress3] [nvarchar](100) NULL,
	[RtrPINCode] [nvarchar](20) NULL,
	[RtrChannelCode] [nvarchar](100) NULL,
	[RtrGroupCode] [nvarchar](100) NULL,
	[RtrClassCode] [nvarchar](100) NULL,
	[KeyAccount] [nvarchar](20) NULL,
	[RelationStatus] [nvarchar](100) NULL,
	[ParentCode] [nvarchar](100) NULL,
	[RtrRegDate] [nvarchar](100) NULL,
	[Status] [tinyint] NULL,
	[DownLoadFlag] [nvarchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_PointsRulesHeader]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_PointsRulesHeader]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_PointsRulesHeader](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](50) NULL,
	[SchDesc] [nvarchar](50) NULL,
	[Status] [nvarchar](10) NULL,
	[Claimable] [nvarchar](10) NULL,
	[ClaimRefCode] [nvarchar](50) NULL,
	[ClmAmtOn] [nvarchar](25) NULL,
	[ValidFromDt] [datetime] NULL,
	[ValidToDt] [datetime] NULL,
	[Budget] [numeric](36, 2) NULL,
	[RangeBasedSch] [nvarchar](10) NULL,
	[ForEvery] [nvarchar](10) NULL,
	[ReapplySch] [nvarchar](10) NULL,
	[SchemeBasedOn] [nvarchar](10) NULL,
	[ProRata] [nvarchar](10) NULL,
	[DownLoadFlag] [nvarchar](2) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_PointsRulesRetailer]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_PointsRulesRetailer]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_PointsRulesRetailer](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](50) NULL,
	[RtrCode] [nvarchar](50) NULL,
	[DownLoadFlag] [nvarchar](2) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_PointsRulesSlab]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_PointsRulesSlab]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_PointsRulesSlab](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](50) NULL,
	[SlabId] [int] NULL,
	[FromPoint] [int] NULL,
	[ToPoint] [int] NULL,
	[ForEvery] [int] NULL,
	[Amount] [numeric](36, 2) NULL,
	[DownLoadFlag] [nvarchar](2) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_PointsRulesProduct]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_PointsRulesProduct]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_PointsRulesProduct](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](50) NULL,
	[SlabId] [int] NULL,
	[FreeOrGift] [nvarchar](10) NULL,
	[Prdccode] [nvarchar](50) NULL,
	[UomCode] [nvarchar](20) NULL,
	[Qty] [int] NULL,
	[AndOrOption] [nvarchar](10) NULL,
	[DownLoadFlag] [nvarchar](2) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_Reupload]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_Reupload]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_Reupload](
	[DistCode] [nvarchar](50) NULL,
	[SeqNo] [int] NULL,
	[ProcessName] [nvarchar](200) NULL,
	[ReUploadDate] [datetime] NULL,
	[DownLoadFlag] [nvarchar](5) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_PurchaseReceiptAdjustments]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_PurchaseReceiptAdjustments]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_PurchaseReceiptAdjustments](
	[DistCode] [nvarchar](50) NULL,
	[CompInvNo] [nvarchar](50) NULL,
	[AdjType] [nvarchar](50) NULL,
	[RefNo] [nvarchar](50) NULL,
	[Amount] [nvarchar](50) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_VillageMaster]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_VillageMaster]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_VillageMaster](
	[DistCode] [nvarchar](50) NULL,
	[CmpVillageCode] [nvarchar](100) NULL,
	[VillageName] [nvarchar](100) NULL,
	[Distance] [numeric](38, 6) NULL,
	[VillPopulation] [numeric](38, 6) NULL,
	[RtrPopulation] [numeric](38, 6) NULL,
	[RoadCondition] [nvarchar](100) NULL,
	[IncomeLevel] [nvarchar](100) NULL,
	[Acceptability] [nvarchar](100) NULL,
	[Awareness] [nvarchar](100) NULL,
	[Status] [nvarchar](20) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_SchemePayout]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_SchemePayout]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_SchemePayout](
	[DistCode] [nvarchar](50) NULL,
	[CmpSchCode] [nvarchar](200) NULL,
	[CmpRtrCode] [nvarchar](200) NULL,
	[CrDbType] [nvarchar](100) NULL,
	[CrDbNoteNo] [nvarchar](100) NULL,
	[CrDbDate] [datetime] NULL,
	[CrDbAmt] [numeric](38, 6) NULL,
	[ResField1] [nvarchar](100) NULL,
	[ResField2] [nvarchar](100) NULL,
	[ResField3] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cn2Cs_Prk_KitProducts]') AND type in (N'U'))
DROP TABLE [dbo].[Cn2Cs_Prk_KitProducts]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_KitProducts](
	[DistCode] [nvarchar](50) NULL,
	[KitItemCode] [nvarchar](100) NULL,
	[ProductCode] [nvarchar](100) NULL,
	[ProductBatchCode] [nvarchar](50) NULL,
	[Quantity] [numeric](18, 0) NULL,
	[DownloadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
--Upload Parking Table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_UploadRecordCheck]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_UploadRecordCheck]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_UploadRecordCheck](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NOT NULL,
	[SeqNo] [int] NULL,
	[ProcessName] [nvarchar](200) NOT NULL,
	[UploadDate] [datetime] NULL,
	[CSMinCount] [numeric](38, 0) NULL,
	[CSMaxCount] [numeric](38, 0) NULL,
	[CSRecCount] [numeric](38, 0) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_Retailer]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_Retailer]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_Retailer](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[CmpRtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[RtrAddress1] [nvarchar](100) NULL,
	[RtrAddress2] [nvarchar](100) NULL,
	[RtrAddress3] [nvarchar](100) NULL,
	[RtrPINCode] [nvarchar](20) NULL,
	[RtrChannelCode] [nvarchar](100) NULL,
	[RtrGroupCode] [nvarchar](100) NULL,
	[RtrClassCode] [nvarchar](100) NULL,
	[KeyAccount] [nvarchar](20) NULL,
	[RelationStatus] [nvarchar](100) NULL,
	[ParentCode] [nvarchar](100) NULL,
	[RtrRegDate] [nvarchar](100) NULL,
	[GeoLevel] [nvarchar](100) NULL,
	[GeoLevelValue] [nvarchar](100) NULL,
	[VillageId] [int] NULL,
	[VillageCode] [nvarchar](100) NULL,
	[VillageName] [nvarchar](100) NULL,
	[Status] [tinyint] NULL,
	[Mode] [nvarchar](100) NULL,
	[DrugLNo] [nvarchar](50) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_DailySales]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_DailySales]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DailySales](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[SalInvNo] [nvarchar](50) NULL,
	[SalInvDate] [datetime] NULL,
	[SalDlvDate] [datetime] NULL,
	[SalInvMode] [nvarchar](100) NULL,
	[SalInvType] [nvarchar](100) NULL,
	[SalGrossAmt] [numeric](38, 6) NULL,
	[SalSplDiscAmt] [numeric](38, 6) NULL,
	[SalSchDiscAmt] [numeric](38, 6) NULL,
	[SalCashDiscAmt] [numeric](38, 6) NULL,
	[SalDBDiscAmt] [numeric](38, 6) NULL,
	[SalTaxAmt] [numeric](38, 6) NULL,
	[SalWDSAmt] [numeric](38, 6) NULL,
	[SalDbAdjAmt] [numeric](38, 6) NULL,
	[SalCrAdjAmt] [numeric](38, 6) NULL,
	[SalOnAccountAmt] [numeric](38, 6) NULL,
	[SalMktRetAmt] [numeric](38, 6) NULL,
	[SalReplaceAmt] [numeric](38, 6) NULL,
	[SalOtherChargesAmt] [numeric](38, 6) NULL,
	[SalInvLevelDiscAmt] [numeric](38, 6) NULL,
	[SalTotDedn] [numeric](38, 6) NULL,
	[SalTotAddn] [numeric](38, 6) NULL,
	[SalRoundOffAmt] [numeric](38, 6) NULL,
	[SalNetAmt] [numeric](38, 6) NULL,
	[LcnId] [int] NULL,
	[LcnCode] [nvarchar](100) NULL,
	[SalesmanCode] [nvarchar](100) NULL,
	[SalesmanName] [nvarchar](200) NULL,
	[SalesRouteCode] [nvarchar](100) NULL,
	[SalesRouteName] [nvarchar](200) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[VechName] [nvarchar](100) NULL,
	[DlvBoyName] [nvarchar](100) NULL,
	[DeliveryRouteCode] [nvarchar](100) NULL,
	[DeliveryRouteName] [nvarchar](200) NULL,
	[PrdCode] [nvarchar](50) NULL,
	[PrdBatCde] [nvarchar](50) NULL,
	[PrdQty] [int] NULL,
	[PrdSelRateBeforeTax] [numeric](38, 6) NULL,
	[PrdSelRateAfterTax] [numeric](38, 6) NULL,
	[PrdFreeQty] [int] NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdSplDiscAmt] [numeric](38, 6) NULL,
	[PrdSchDiscAmt] [numeric](38, 6) NULL,
	[PrdCashDiscAmt] [numeric](38, 6) NULL,
	[PrdDBDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SalInvLineCount] [int] NOT NULL,
	[SalInvLvlDiscPer] [numeric](18, 2) NOT NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_DailySales] ADD  DEFAULT ((0)) FOR [SalInvLineCount]
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_DailySales] ADD  DEFAULT ((0)) FOR [SalInvLvlDiscPer]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_Stock]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_Stock]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_Stock](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[TransDate] [datetime] NULL,
	[LcnId] [int] NULL,
	[LcnCode] [nvarchar](100) NULL,
	[PrdId] [int] NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[SalOpenStock] [numeric](18, 0) NULL,
	[UnSalOpenStock] [numeric](18, 0) NULL,
	[OfferOpenStock] [numeric](18, 0) NULL,
	[SalPurchase] [numeric](18, 0) NULL,
	[UnsalPurchase] [numeric](18, 0) NULL,
	[OfferPurchase] [numeric](18, 0) NULL,
	[SalPurReturn] [numeric](18, 0) NULL,
	[UnsalPurReturn] [numeric](18, 0) NULL,
	[OfferPurReturn] [numeric](18, 0) NULL,
	[SalSales] [numeric](18, 0) NULL,
	[UnSalSales] [numeric](18, 0) NULL,
	[OfferSales] [numeric](18, 0) NULL,
	[SalStockIn] [numeric](18, 0) NULL,
	[UnSalStockIn] [numeric](18, 0) NULL,
	[OfferStockIn] [numeric](18, 0) NULL,
	[SalStockOut] [numeric](18, 0) NULL,
	[UnSalStockOut] [numeric](18, 0) NULL,
	[OfferStockOut] [numeric](18, 0) NULL,
	[DamageIn] [numeric](18, 0) NULL,
	[DamageOut] [numeric](18, 0) NULL,
	[SalSalesReturn] [numeric](18, 0) NULL,
	[UnSalSalesReturn] [numeric](18, 0) NULL,
	[OfferSalesReturn] [numeric](18, 0) NULL,
	[SalStkJurIn] [numeric](18, 0) NULL,
	[UnSalStkJurIn] [numeric](18, 0) NULL,
	[OfferStkJurIn] [numeric](18, 0) NULL,
	[SalStkJurOut] [numeric](18, 0) NULL,
	[UnSalStkJurOut] [numeric](18, 0) NULL,
	[OfferStkJurOut] [numeric](18, 0) NULL,
	[SalBatTfrIn] [numeric](18, 0) NULL,
	[UnSalBatTfrIn] [numeric](18, 0) NULL,
	[OfferBatTfrIn] [numeric](18, 0) NULL,
	[SalBatTfrOut] [numeric](18, 0) NULL,
	[UnSalBatTfrOut] [numeric](18, 0) NULL,
	[OfferBatTfrOut] [numeric](18, 0) NULL,
	[SalLcnTfrIn] [numeric](18, 0) NULL,
	[UnSalLcnTfrIn] [numeric](18, 0) NULL,
	[OfferLcnTfrIn] [numeric](18, 0) NULL,
	[SalLcnTfrOut] [numeric](18, 0) NULL,
	[UnSalLcnTfrOut] [numeric](18, 0) NULL,
	[OfferLcnTfrOut] [numeric](18, 0) NULL,
	[SalReplacement] [numeric](18, 0) NULL,
	[OfferReplacement] [numeric](18, 0) NULL,
	[SalClsStock] [numeric](18, 0) NULL,
	[UnSalClsStock] [numeric](18, 0) NULL,
	[OfferClsStock] [numeric](18, 0) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_SalesReturn]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_SalesReturn]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_SalesReturn](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[SRNRefNo] [nvarchar](50) NULL,
	[SRNRefType] [nvarchar](100) NULL,
	[SRNDate] [datetime] NULL,
	[SRNMode] [nvarchar](100) NULL,
	[SRNType] [nvarchar](100) NULL,
	[SRNGrossAmt] [numeric](38, 6) NULL,
	[SRNSplDiscAmt] [numeric](38, 6) NULL,
	[SRNSchDiscAmt] [numeric](38, 6) NULL,
	[SRNCashDiscAmt] [numeric](38, 6) NULL,
	[SRNDBDiscAmt] [numeric](38, 6) NULL,
	[SRNTaxAmt] [numeric](38, 6) NULL,
	[SRNRoundOffAmt] [numeric](38, 6) NULL,
	[SRNNetAmt] [numeric](38, 6) NULL,
	[SalesmanName] [nvarchar](100) NULL,
	[SalesRouteName] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[PrdSalInvNo] [nvarchar](50) NULL,
	[PrdLcnId] [int] NULL,
	[PrdLcnCode] [nvarchar](100) NULL,
	[PrdCode] [nvarchar](50) NULL,
	[PrdBatCde] [nvarchar](50) NULL,
	[PrdSalQty] [int] NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdOfferQty] [int] NULL,
	[PrdSelRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdSplDiscAmt] [numeric](38, 6) NULL,
	[PrdSchDiscAmt] [numeric](38, 6) NULL,
	[PrdCashDiscAmt] [numeric](38, 6) NULL,
	[PrdDBDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SRNInvDiscount] [numeric](38, 6) NOT NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_SalesReturn] ADD  DEFAULT ((0)) FOR [SRNInvDiscount]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_PurchaseConfirmation]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_PurchaseConfirmation]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_PurchaseConfirmation](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[GRNCmpInvNo] [nvarchar](50) NULL,
	[GRNRefNo] [nvarchar](50) NULL,
	[GRNRcvdDate] [datetime] NULL,
	[GRNInvDate] [datetime] NULL,
	[GRNPORefNo] [nvarchar](50) NULL,
	[SupplierCode] [nvarchar](100) NULL,
	[TransporterCode] [nvarchar](100) NULL,
	[LRNo] [nvarchar](100) NULL,
	[LRDate] [datetime] NULL,
	[GRNGrossAmt] [numeric](38, 6) NULL,
	[GRNDiscAmt] [numeric](38, 6) NULL,
	[GRNTaxAmt] [numeric](38, 6) NULL,
	[GRNSchAmt] [numeric](38, 6) NULL,
	[GRNOtherChargesAmt] [numeric](38, 6) NULL,
	[GRNHandlingChargesAmt] [numeric](38, 6) NULL,
	[GRNTotDedn] [numeric](38, 6) NULL,
	[GRNTotAddn] [numeric](38, 6) NULL,
	[GRNRoundOffAmt] [numeric](38, 6) NULL,
	[GRNNetAmt] [numeric](38, 6) NULL,
	[GRNNetPayableAmt] [numeric](38, 6) NULL,
	[GRNDiffAmt] [numeric](38, 6) NULL,
	[PrdRowId] [int] NULL,
	[PrdSchemeFlag] [nvarchar](10) NULL,
	[PrdCmpSchCode] [nvarchar](100) NULL,
	[PrdLcnId] [int] NULL,
	[PrdLcnCode] [nvarchar](100) NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[PrdInvQty] [int] NULL,
	[PrdRcvdQty] [int] NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdShortQty] [int] NULL,
	[PrdExcessQty] [int] NULL,
	[PrdExcessRefusedQty] [int] NULL,
	[PrdLSP] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetRate] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[PrdLineBreakUpType] [nvarchar](100) NULL,
	[PrdLineLcnId] [int] NULL,
	[PrdLineLcnCode] [nvarchar](100) NULL,
	[PrdLineStockType] [nvarchar](100) NULL,
	[PrdLineQty] [int] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_PurchaseReturn]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_PurchaseReturn]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_PurchaseReturn](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[PRNRefNo] [nvarchar](100) NULL,
	[PRNDate] [datetime] NULL,
	[CmpCode] [nvarchar](100) NULL,
	[SpmCode] [nvarchar](100) NULL,
	[PRNMode] [nvarchar](100) NULL,
	[PRNType] [nvarchar](100) NULL,
	[GRNNo] [nvarchar](100) NULL,
	[CmpInvNo] [nvarchar](100) NULL,
	[PRNGrossAmt] [numeric](38, 6) NULL,
	[PRNDiscAmt] [numeric](38, 6) NULL,
	[PRNSchAmt] [numeric](38, 6) NULL,
	[PRNOtherChargesAmt] [numeric](38, 6) NULL,
	[PRNTaxAmt] [numeric](38, 6) NULL,
	[PRNTotDedn] [numeric](38, 6) NULL,
	[PRNTotAddn] [numeric](38, 6) NULL,
	[PRNRoundOffAmt] [numeric](38, 6) NULL,
	[PRNNetAmt] [numeric](38, 6) NULL,
	[PrdRowId] [int] NULL,
	[PrdSchemeFlag] [nvarchar](10) NULL,
	[PrdCmpSchCode] [nvarchar](100) NULL,
	[PrdLcnId] [int] NULL,
	[PrdLcnCode] [nvarchar](100) NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[PrdSalQty] [int] NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetRate] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[Reason] [nvarchar](200) NULL,
	[PrdLineBreakUpType] [nvarchar](100) NULL,
	[PrdLineLcnId] [int] NULL,
	[PrdLineLcnCode] [nvarchar](100) NULL,
	[PrdLineStockType] [nvarchar](100) NULL,
	[PrdLineQty] [int] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_ClaimAll]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_ClaimAll]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_ClaimAll](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[CmpName] [nvarchar](100) NULL,
	[ClaimType] [nvarchar](300) NULL,
	[ClaimMonth] [nvarchar](100) NULL,
	[ClaimYear] [int] NULL,
	[ClaimRefNo] [nvarchar](100) NULL,
	[ClaimDate] [datetime] NULL,
	[ClaimFromDate] [datetime] NULL,
	[ClaimToDate] [datetime] NULL,
	[DistributorClaim] [numeric](38, 6) NULL,
	[DistributorRecommended] [numeric](38, 6) NULL,
	[ClaimnormPerc] [numeric](38, 6) NULL,
	[SuggestedClaim] [numeric](38, 6) NULL,
	[TotalClaimAmt] [numeric](38, 6) NULL,
	[Remarks] [nvarchar](300) NULL,
	[Description] [nvarchar](300) NULL,
	[Amount1] [numeric](38, 6) NULL,
	[ProductCode] [nvarchar](100) NULL,
	[Batch] [nvarchar](100) NULL,
	[Quantity1] [int] NULL,
	[Quantity2] [int] NULL,
	[Amount2] [numeric](38, 6) NULL,
	[Amount3] [numeric](38, 6) NULL,
	[TotalAmount] [numeric](38, 6) NULL,
	[UploadFlag] [nvarchar](1) NULL,
	[SchemeCode] [varchar](100) NULL,
	[BillNo] [varchar](100) NULL,
	[BillDate] [datetime] NULL,
	[RetailerCode] [varchar](100) NULL,
	[RetailerName] [varchar](100) NULL,
	[TotalSalesInValue] [numeric](38, 6) NULL,
	[PromotedSalesinValue] [numeric](38, 6) NULL,
	[OID] [numeric](38, 6) NULL,
	[Discount] [numeric](38, 6) NULL,
	[FromStockType] [varchar](100) NULL,
	[ToStockType] [varchar](100) NULL,
	[Remark2] [varchar](100) NULL,
	[Remark3] [varchar](100) NULL,
	[PrdCode1] [varchar](100) NULL,
	[PrdCode2] [varchar](100) NULL,
	[PrdName1] [varchar](100) NULL,
	[PrdName2] [varchar](100) NULL,
	[Date2] [datetime] NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_SchemeUtilizationDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_SchemeUtilizationDetails]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_SchemeUtilizationDetails](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[TransName] [nvarchar](50) NULL,
	[SchUtilizeType] [nvarchar](50) NULL,
	[CmpCode] [nvarchar](100) NULL,
	[CmpSchCode] [nvarchar](50) NULL,
	[SchCode] [nvarchar](50) NULL,
	[SchDescription] [nvarchar](200) NULL,
	[SchType] [nvarchar](50) NULL,
	[SlabId] [int] NULL,
	[TransNo] [nvarchar](50) NULL,
	[TransDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[CmpRtrCode] [nvarchar](50) NULL,
	[RtrCode] [nvarchar](50) NULL,
	[BilledPrdCCode] [nvarchar](50) NULL,
	[BilledPrdBatCode] [nvarchar](50) NULL,
	[BilledQty] [int] NULL,
	[SchUtilizedAmt] [numeric](38, 6) NULL,
	[SchDiscPerc] [numeric](38, 6) NULL,
	[FreePrdCCode] [nvarchar](50) NULL,
	[FreePrdBatCode] [nvarchar](50) NULL,
	[FreeQty] [int] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[NoOfTimes] [int] NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_SampleIssue]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_SampleIssue]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_SampleIssue](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[Reference Number] [nvarchar](100) NULL,
	[Sample Issue Date] [datetime] NULL,
	[RtrId] [int] NOT NULL,
	[Retailer Code] [nvarchar](100) NULL,
	[Retailer Name] [nvarchar](100) NULL,
	[Sample SKU Code] [nvarchar](100) NULL,
	[Issue Qty] [numeric](38, 0) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_SampleReceipt]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_SampleReceipt]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_SampleReceipt](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[ReferenceNumber] [nvarchar](100) NULL,
	[SampleReceiptDate] [datetime] NULL,
	[SupplierCode] [nvarchar](100) NULL,
	[SupplierName] [nvarchar](100) NULL,
	[SampleSKUCode] [nvarchar](200) NULL,
	[ReceivedQty] [numeric](38, 0) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_SampleReturn]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_SampleReturn]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_SampleReturn](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[ReferenceNumber] [nvarchar](100) NULL,
	[SampleReturnDate] [datetime] NULL,
	[SampleIssueReferenceNumber] [nvarchar](100) NULL,
	[RtrId] [nvarchar](100) NULL,
	[RtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[SampleSKUCode] [nvarchar](100) NULL,
	[ReceivedQty] [numeric](38, 0) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_Salesman]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_Salesman]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_Salesman](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[SMId] [int] NULL,
	[SMCode] [nvarchar](100) NULL,
	[SMName] [nvarchar](100) NULL,
	[SMPhoneNo] [nvarchar](100) NULL,
	[SMEmail] [nvarchar](100) NULL,
	[SMOtherDetails] [nvarchar](500) NULL,
	[SMDailyAllowance] [numeric](38, 6) NULL,
	[SMMonthlySalary] [numeric](38, 6) NULL,
	[SMMktCredit] [numeric](38, 6) NULL,
	[SMCreditDays] [int] NULL,
	[Status] [nvarchar](20) NULL,
	[RMId] [int] NULL,
	[RMCode] [nvarchar](100) NULL,
	[RMName] [nvarchar](100) NULL,
	[UploadFlag] [nvarchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_Route]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_Route]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_Route](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[RMId] [int] NULL,
	[RMCode] [nvarchar](100) NULL,
	[RMName] [nvarchar](100) NULL,
	[Distance] [numeric](38, 6) NULL,
	[RMPopulation] [numeric](38, 6) NULL,
	[VanRoute] [nvarchar](100) NULL,
	[RouteType] [nvarchar](100) NULL,
	[LocalUpCountry] [nvarchar](100) NULL,
	[GeoLevel] [nvarchar](100) NULL,
	[GeoValue] [nvarchar](100) NULL,
	[Status] [nvarchar](20) NULL,
	[MonDay] [nvarchar](20) NULL,
	[TuesDay] [nvarchar](20) NULL,
	[WednesDay] [nvarchar](20) NULL,
	[ThursDay] [nvarchar](20) NULL,
	[FriDay] [nvarchar](20) NULL,
	[SaturDay] [nvarchar](20) NULL,
	[SunDay] [nvarchar](20) NULL,
	[UploadFlag] [nvarchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_RetailerRoute]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_RetailerRoute]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_RetailerRoute](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[RMId] [int] NULL,
	[RMCode] [nvarchar](100) NULL,
	[RMName] [nvarchar](100) NULL,
	[RouteType] [nvarchar](100) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_OrderBooking]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_OrderBooking]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_OrderBooking](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[OrderNo] [nvarchar](50) NULL,
	[OrderDate] [datetime] NULL,
	[OrdDlvDate] [datetime] NULL,
	[AllowBackOrder] [nvarchar](50) NULL,
	[OrdType] [nvarchar](50) NULL,
	[OrdPriority] [nvarchar](50) NULL,
	[OrdDocRef] [nvarchar](100) NULL,
	[Remarks] [nvarchar](500) NULL,
	[RoundOffAmt] [numeric](38, 6) NULL,
	[OrdTotalAmt] [numeric](38, 6) NULL,
	[SalesmanCode] [nvarchar](100) NULL,
	[SalesmanName] [nvarchar](200) NULL,
	[SalesRouteCode] [nvarchar](100) NULL,
	[SalesRouteName] [nvarchar](200) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[PrdCode] [nvarchar](50) NULL,
	[PrdBatCde] [nvarchar](50) NULL,
	[PrdQty] [int] NULL,
	[PrdBilledQty] [int] NULL,
	[PrdSelRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[RecordDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_SalesInvoiceOrders]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_SalesInvoiceOrders]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_SalesInvoiceOrders](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[SalInvNo] [nvarchar](50) NULL,
	[OrderNo] [nvarchar](50) NULL,
	[OrderDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_Claim_SchemeDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[ClaimRefNo] [nvarchar](100) NULL,
	[CmpSchCode] [nvarchar](100) NULL,
	[SlabId] [int] NULL,
	[SalInvNo] [nvarchar](100) NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[BilledQty] [nvarchar](100) NULL,
	[ClaimAmount] [numeric](38, 6) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SchCode] [nvarchar](100) NULL,
	[SchDesc] [nvarchar](200) NULL,
	[ClaimDate] [datetime] NULL,
	[UploadedDate] [datetime] NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails] ADD  DEFAULT ('') FOR [SchCode]
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails] ADD  DEFAULT ('') FOR [SchDesc]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_DailyBusinessDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_DailyBusinessDetails]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DailyBusinessDetails](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[UploadedDate] [datetime] NULL,
	[TransDate] [datetime] NULL,
	[SalInvCount] [int] NULL,
	[SalInvGrossValue] [numeric](38, 6) NULL,
	[SalInvNetValue] [numeric](38, 6) NULL,
	[PurInvCount] [int] NULL,
	[PurInvGrossValue] [numeric](38, 6) NULL,
	[PurInvNetValue] [numeric](38, 6) NULL,
	[SRNCount] [int] NULL,
	[SRNGrossValue] [numeric](38, 6) NULL,
	[SRNNetValue] [numeric](38, 6) NULL,
	[PRNCount] [int] NULL,
	[PRNGrossValue] [numeric](38, 6) NULL,
	[PRNNetValue] [numeric](38, 6) NULL,
	[InventoryCount] [int] NULL,
	[RetailerCount] [int] NULL,
	[SchSalInvCount] [int] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_DBDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_DBDetails]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DBDetails](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[IPAddress] [nvarchar](100) NULL,
	[MachineName] [nvarchar](100) NULL,
	[DBId] [int] NULL,
	[DBName] [nvarchar](100) NULL,
	[DBCreatedDate] [datetime] NULL,
	[DBRestoredDate] [datetime] NULL,
	[DBRestoreId] [int] NULL,
	[DBFileName] [nvarchar](4000) NULL,
	[UploadFlag] [nvarchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_DownLoadTracing]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_DownLoadTracing]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DownLoadTracing](
	[SlNo] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) NULL,
	[ProcessName] [varchar](100) NULL,
	[TotRowCount] [int] NULL,
	[Process1] [varchar](1) NULL,
	[Process2] [varchar](1) NULL,
	[Process3] [varchar](1) NULL,
	[Process4] [varchar](1) NULL,
	[Process5] [varchar](1) NULL,
	[Process6] [varchar](1) NULL,
	[Process7] [varchar](1) NULL,
	[Process8] [varchar](1) NULL,
	[Process9] [varchar](1) NULL,
	[ProcessPatch] [varchar](50) NULL,
	[Date] [datetime] NULL,
	[UploadFlag] [varchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_UpLoadTracing]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_UpLoadTracing]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_UpLoadTracing](
	[SlNo] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) NULL,
	[ProcessName] [varchar](100) NULL,
	[Process1] [varchar](1) NULL,
	[Process2] [varchar](1) NULL,
	[Process3] [varchar](1) NULL,
	[Process4] [varchar](1) NULL,
	[Process5] [varchar](1) NULL,
	[ProcessPatch] [varchar](50) NULL,
	[Date] [datetime] NULL,
	[UploadFlag] [varchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_DailyRetailerDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_DailyRetailerDetails]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DailyRetailerDetails](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[CmpRtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[RtrAddr1] [nvarchar](100) NULL,
	[RtrAddr2] [nvarchar](100) NULL,
	[RtrAddr3] [nvarchar](100) NULL,
	[RtrPINCode] [nvarchar](100) NULL,
	[RtrChannelCode] [nvarchar](100) NULL,
	[RtrGroupCode] [nvarchar](100) NULL,
	[RtrClassCode] [nvarchar](100) NULL,
	[GeoLevel] [nvarchar](100) NULL,
	[GeoName] [nvarchar](100) NULL,
	[RtrStatus] [nvarchar](100) NULL,
	[RegDate] [datetime] NULL,
	[RtrUploadStatus] [nvarchar](100) NULL,
	[UploadedDate] [datetime] NULL,
	[UploadFlag] [nvarchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_DailyProductDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_DailyProductDetails]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DailyProductDetails](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) NULL,
	[PrdId] [int] NULL,
	[ProductCompanyCode] [nvarchar](200) NULL,
	[ProductDistributorCode] [nvarchar](200) NULL,
	[ProductName] [nvarchar](200) NULL,
	[ProductShortName] [nvarchar](200) NULL,
	[ProductStatus] [nvarchar](200) NULL,
	[PrdBatId] [int] NULL,
	[ProductBatchCode] [nvarchar](200) NULL,
	[CompanyBatchCode] [nvarchar](200) NULL,
	[ProductBatchStatus] [nvarchar](200) NULL,
	[DefaultPriceCode] [nvarchar](200) NULL,
	[DefaultMRP] [numeric](38, 6) NULL,
	[DefaultListPrice] [numeric](38, 6) NULL,
	[DefaultSellingRate] [numeric](38, 6) NULL,
	[DefaultClaimRate] [numeric](38, 6) NULL,
	[AddRate1] [numeric](38, 6) NULL,
	[AddRate2] [numeric](38, 6) NULL,
	[AddRate3] [numeric](38, 6) NULL,
	[AddRate4] [numeric](38, 6) NULL,
	[AddRate5] [numeric](38, 6) NULL,
	[AddRate6] [numeric](38, 6) NULL,
	[UploadedDate] [datetime] NULL,
	[UploadFlag] [nvarchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_ClusterAssign]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_ClusterAssign]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_ClusterAssign](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[ClusterId] [int] NULL,
	[ClusterCode] [nvarchar](50) NULL,
	[ClusterName] [nvarchar](100) NULL,
	[ClsGroupId] [int] NULL,
	[ClsGroupCode] [nvarchar](50) NULL,
	[ClsGroupName] [nvarchar](100) NULL,
	[ClsCategory] [nvarchar](50) NULL,
	[MasterId] [int] NULL,
	[MasterCmpCode] [nvarchar](50) NULL,
	[MasterDistCode] [nvarchar](50) NULL,
	[MasterName] [nvarchar](100) NULL,
	[AssignDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_PurchaseOrder]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_PurchaseOrder]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_PurchaseOrder](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](150) NULL,
	[PONumber] [nvarchar](150) NULL,
	[CompanyPONumber] [nvarchar](150) NULL,
	[PODate] [datetime] NULL,
	[POConfirmDate] [datetime] NULL,
	[ProductHierarchyLevel] [nvarchar](150) NULL,
	[ProductHierarchyValue] [nvarchar](150) NULL,
	[ProductCode] [nvarchar](150) NULL,
	[Quantity] [numeric](38, 0) NULL,
	[POType] [nvarchar](150) NULL,
	[POExpiryDate] [datetime] NULL,
	[SiteCode] [nvarchar](50) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_RouteVillage]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_RouteVillage]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_RouteVillage](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[VillageId] [int] NULL,
	[RMId] [int] NULL,
	[RMCode] [nvarchar](100) NULL,
	[RMName] [nvarchar](100) NULL,
	[VillageCode] [nvarchar](100) NULL,
	[VillageName] [nvarchar](100) NULL,
	[Distance] [numeric](38, 6) NULL,
	[Population] [numeric](38, 6) NULL,
	[RtrPopulation] [numeric](38, 6) NULL,
	[RoadCondition] [nvarchar](100) NULL,
	[IncomeLevel] [nvarchar](100) NULL,
	[Accepability] [nvarchar](100) NULL,
	[Awareness] [nvarchar](100) NULL,
	[Status] [nvarchar](20) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_ReUploadInitiate]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_ReUploadInitiate]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_ReUploadInitiate](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[UploadFlag] [nvarchar](5) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_DownloadedDetails]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_DownloadedDetails]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DownloadedDetails](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[Process] [nvarchar](100) NULL,
	[Detail1] [nvarchar](100) NULL,
	[Detail2] [nvarchar](100) NULL,
	[Detail3] [nvarchar](100) NULL,
	[Detail4] [nvarchar](100) NULL,
	[Detail5] [nvarchar](100) NULL,
	[Detail6] [nvarchar](100) NULL,
	[Detail7] [nvarchar](100) NULL,
	[Detail8] [nvarchar](100) NULL,
	[Detail9] [nvarchar](100) NULL,
	[Detail10] [nvarchar](100) NULL,
	[DownloadedDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_HierarchyLevel' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_HierarchyLevel
GO
-- EXEC Proc_Cn2Cs_HierarchyLevel 0
CREATE PROCEDURE Proc_Cn2Cs_HierarchyLevel
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_HierarchyLevel
* PURPOSE		: To validate and update/insert the downloaded hierarchy data  
* CREATED		: Nandakumar R.G
* CREATED DATE	: 26/03/2010
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @ErrStatus INT
	DECLARE @CmpCode   NVARCHAR(50)

	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany=1 	

	TRUNCATE TABLE ETL_Prk_RetailerCategoryLevel

	INSERT INTO ETL_Prk_RetailerCategoryLevel([Company Code],[Maximum Hierarchy Level],
	[Level Name],[Category Level Name])
	SELECT DISTINCT @CmpCode,LevelCount,LevelName,HierarchyLevelName
	FROM Cn2Cs_Prk_HierarchyLevel WHERE DownLoadFlag='D' AND HierarchyType=4


	TRUNCATE TABLE ETL_Prk_GeographyHierarchyLevel

	INSERT INTO ETL_Prk_GeographyHierarchyLevel([Geography Hierarchy Level Code],
	[Level Name],[Maximum Level])
	SELECT DISTINCT HierarchyLevelName,LevelName,LevelCount
	FROM Cn2Cs_Prk_HierarchyLevel WHERE DownLoadFlag='D' AND HierarchyType=2

	EXEC Proc_ValidateRetailerCategoryLevel @Po_ErrNo= @ErrStatus OUTPUT

	EXEC Proc_ValidateGeographyHierarchyLevel @Po_ErrNo= @ErrStatus OUTPUT

	UPDATE Cn2Cs_Prk_HierarchyLevel SET DownLoadFlag='Y'
	WHERE HierarchyLevelName IN (SELECT CtgLevelName FROM RetailerCategoryLevel) AND HierarchyType=4

	UPDATE Cn2Cs_Prk_HierarchyLevel SET DownLoadFlag='Y'
	WHERE HierarchyLevelName IN (SELECT GeoLevelName FROM GeographyLevel) AND HierarchyType=2

	SET @Po_ErrNo= @ErrStatus
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_HierarchyLevelValue' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_HierarchyLevelValue
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_HierarchyLevelValue
TRUNCATE TABLE ETL_Prk_GeographyHierarchyLevelValue
EXEC Proc_Cn2Cs_HierarchyLevelValue 0
SELECT * FROM ETL_Prk_GeographyHierarchyLevelValue
SELECT * FROM Geography
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_HierarchyLevelValue
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_HierarchyLevelValue
* PURPOSE		: To validate and update/insert the downloaded hierarchy data
* CREATED		: Nandakumar R.G
* CREATED DATE	: 26/03/2010
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus INT
	DECLARE @CmpCode   NVARCHAR(50)
	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany=1 	
	TRUNCATE TABLE ETL_Prk_RetailerCategoryLevelValue
	INSERT INTO ETL_Prk_RetailerCategoryLevelValue([Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Hierarchy Level Value Code],[Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT LevelName,ParentCode,HierarchyCode,HierarchyName,@CmpCode
	FROM Cn2Cs_Prk_HierarchyLevelValue WHERE DownLoadFlag='D' AND HierarchyType=4 ORDER BY LevelName
	TRUNCATE TABLE ETL_Prk_GeographyHierarchyLevelValue
	
	INSERT INTO ETL_Prk_GeographyHierarchyLevelValue([Geography Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Geography Hierarchy Level Value Code],[Geography Hierarchy Level Value Name],[Population])
	SELECT DISTINCT LevelName,ParentCode,HierarchyCode,HierarchyName,0 AS AddInfo1
	FROM Cn2Cs_Prk_HierarchyLevelValue WHERE DownLoadFlag='D' AND HierarchyType=2 ORDER BY LevelName
	UPDATE ETL SET [Parent Hierarchy Level Value Code]='GeoFirstLevel'
	FROM ETL_Prk_GeographyHierarchyLevelValue ETL,GeographyLevel Geo
	WHERE ETL.[Geography Hierarchy Level Code]=Geo.LevelName AND ETL.[Geography Hierarchy Level Code]='Level1'
	UPDATE ETL SET [Geography Hierarchy Level Code]=GeoLevelName
	FROM ETL_Prk_GeographyHierarchyLevelValue ETL,GeographyLevel Geo
	WHERE ETL.[Geography Hierarchy Level Code]=Geo.LevelName
	EXEC Proc_ValidateRetailerCategoryLevelValue @Po_ErrNo= @ErrStatus OUTPUT
	EXEC Proc_ValidateGeographyHierarchyLevelValue @Po_ErrNo= @ErrStatus OUTPUT
	UPDATE Cn2Cs_Prk_HierarchyLevelValue SET DownLoadFlag='Y'
	WHERE HierarchyCode IN (SELECT CtgCode FROM RetailerCategory) AND HierarchyType=4
	UPDATE Cn2Cs_Prk_HierarchyLevelValue SET DownLoadFlag='Y'
	WHERE HierarchyCode IN (SELECT GeoCode FROM Geography) AND HierarchyType=2
	SET @Po_ErrNo= @ErrStatus
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateRetailerCategoryLevel' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateRetailerCategoryLevel
GO
--Exec Proc_ValidateRetailerCategoryLevel 0
CREATE Procedure Proc_ValidateRetailerCategoryLevel
(

	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateRetailerCategoryLevel
* PURPOSE	: To Insert and Update records  from xml file in the Table RetailerCategoryLevel 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
BEGIN

DECLARE @CompanyCode AS NVARCHAR(100)
DECLARE @MaxHierLevel AS NVARCHAR(100)
DECLARE @LevelName AS NVARCHAR(100)
DECLARE @CategoryLevelName AS NVARCHAR(100)
DECLARE @sLevelName AS NVARCHAR(100)
DECLARE @CmpId AS INT
DECLARE @CtgLevelId AS INT
DECLARE @Level AS INT
DECLARE @Taction AS INT
DECLARE @Tabname AS NVARCHAR(100)
DECLARE @CntTabname AS NVARCHAR(100)
DECLARE @Fldname AS NVARCHAR(100)
DECLARE @ErrDesc AS NVARCHAR(1000)
DECLARE @DiffCmp AS NVARCHAR(100)
DECLARE @sSql AS NVARCHAR(4000)
	SET @CntTabname='RetailerCategoryLevel'
	SET @Fldname='CtgLevelId'
	SET @Tabname = 'ETL_Prk_RetailerCategoryLevel'
	SET @Level=0
	SET @Po_ErrNo=0
	SET @Taction=0
	DECLARE Cur_RetailerCategoryLevel CURSOR 
	FOR SELECT ISNULL([Company Code],''),ISNULL([Maximum Hierarchy Level],''),ISNULL([Level Name],''),
    	ISNULL([Category Level Name],'')
	FROM ETL_Prk_RetailerCategoryLevel ORDER BY [Company Code]

	OPEN Cur_RetailerCategoryLevel
	
	FETCH NEXT FROM Cur_RetailerCategoryLevel INTO @CompanyCode,@MaxHierLevel,@LevelName,@CategoryLevelName
	
	WHILE @@FETCH_STATUS=0
	
	BEGIN	
		
		SET @Level=@Level+1
		IF NOT EXISTS  (SELECT * FROM Company WHERE CmpCode = @CompanyCode )    
	  		BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Company Code ' + @CompanyCode + ' is not available'  		 
				INSERT INTO Errorlog VALUES (1,@Tabname,'CompanyCode',@ErrDesc)
			END
		SELECT @CmpId=CmpId FROM Company WITH (NOLOCK)WHERE CmpCode = @CompanyCode
		IF @Level=1 
		BEGIN
			SET @DiffCmp=@CompanyCode
		END 
		IF @Level=1 
			BEGIN
				IF (SELECT COUNT(*) FROM RetailerCategoryLevel WITH (NOLOCK) WHERE CmpId = @CmpId)>0
					BEGIN
						SET @Po_ErrNo=1
						Set @ErrDesc = 'Category Level already exists for '+ @CompanyCode		 
						INSERT INTO Errorlog VALUES (2,@Tabname,'MaximumHierarchyLevel',@ErrDesc)
					END
				ELSE
					BEGIN
						SET @Taction=1
					END
			END
			
		IF @MaxHierLevel < (SELECT DISTINCT COUNT([Level Name]) FROM ETL_Prk_RetailerCategoryLevel WHERE [Company Code] = @CompanyCode )
			BEGIN
				SET @Po_ErrNo=1
				Set @ErrDesc = 'Level Name Should be equal to Maximum Hierarchy Level '+ @CompanyCode		 
				INSERT INTO Errorlog VALUES (3,@Tabname,'LevelName',@ErrDesc)
			END
			    
		SET @sLevelName= 'Level' + CAST(@Level AS VARCHAR(5))
		IF @sLevelName <> @LevelName 
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Invalid Level Name: ' + @sLevelName 		 
				INSERT INTO Errorlog VALUES (4,@Tabname,'LevelName',@ErrDesc)
			END
				
		IF LTRIM(RTRIM(@CategoryLevelName))='' 
			BEGIN
				SET @Po_ErrNo=1	
				SET @ErrDesc = 'Category Level Name should not be empty'		 
				INSERT INTO Errorlog VALUES (5,@Tabname,'CategoryLevelName',@ErrDesc)
			END
					
		IF LTRIM(RTRIM(@LevelName))='' 
			BEGIN
				SET @Po_ErrNo=1	
				SET @ErrDesc = 'Level Name should not be empty'	 
				INSERT INTO Errorlog VALUES (6,@Tabname,'LevelName',@ErrDesc)
			END
					
		IF ISNUMERIC(@MaxHierLevel)=0 
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Maximum Hierarchy Level should not be empty'+ @CompanyCode		 
				INSERT INTO Errorlog VALUES (7,@Tabname,'HierarchyLevel',@ErrDesc)
			END
					
				
		SELECT @CtgLevelId=dbo.Fn_GetPrimaryKeyInteger(@CntTabname,@FldName,CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
		IF  @CtgLevelId=0 
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Reset the Counter Value'		 
				INSERT INTO Errorlog VALUES (8,@Tabname,'Counter Value',@ErrDesc)
			END
		
		IF  @Taction=1  AND @Po_ErrNo=0
		BEGIN
			INSERT INTO RetailerCategoryLevel 
			(CtgLevelId,CtgLevelName,LevelName,CmpId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@CtgLevelId,@CategoryLevelName,
			@LevelName,@CmpId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  @CntTabname AND Fldname = @FldName

			SET @sSql ='INSERT INTO RetailerCategoryLevel 
			(CtgLevelId,CtgLevelName,LevelName,CmpId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES('+ CAST(@CtgLevelId AS VARCHAR(10))+','''+ @CategoryLevelName +''','''+ @LevelName +
			''','+ CAST(@CmpId AS VARCHAR(10))+',1,1,''' + CONVERT(NVARCHAR(10),GETDATE(),121)+ ''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'

			INSERT INTO Translog(strSql1) VALUES (@sSql)

			SET @sSql ='UPDATE Counters SET CurrValue =CurrValue'+'+1'+' WHERE Tabname ='''+@CntTabname+''' AND Fldname ='''+@FldName+''''
		
			INSERT INTO Translog(strSql1) VALUES (@sSql)
		END
		

	FETCH NEXT FROM Cur_RetailerCategoryLevel INTO  @CompanyCode,@MaxHierLevel,@LevelName,@CategoryLevelName
		IF @DiffCmp <> @CompanyCode 
		BEGIN
			SET @Level=0 
		END
		SET @DiffCmp=@CompanyCode
	END
	CLOSE Cur_RetailerCategoryLevel
	DEALLOCATE Cur_RetailerCategoryLevel
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateRetailerCategoryLevelValue' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateRetailerCategoryLevelValue
GO
CREATE Procedure Proc_ValidateRetailerCategoryLevelValue
(

	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateRetailerCategoryLevelValue
* PURPOSE	: To Insert and Update records  from xml file in the Table RetailerCategoryLevel 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
BEGIN

DECLARE @LevelCode AS NVARCHAR(100)
DECLARE @ParentLevelValueCode AS NVARCHAR(100)
DECLARE @LevelValueCode AS NVARCHAR(100)
DECLARE @LevelValueName AS NVARCHAR(100)
DECLARE @CompanyCode AS NVARCHAR(100)
DECLARE @CtgLevelId AS INT
DECLARE @CtgMainId AS INT
DECLARE @CtgLinkId AS INT
DECLARE @CmpId AS INT
DECLARE @Code AS INT 
DECLARE @CtgLinkCode AS NVARCHAR(500)
DECLARE @ParLinkCode AS NVARCHAR(500)
DECLARE @NewLinkCode AS NVARCHAR(500)
DECLARE @CtgLevelName AS NVARCHAR(100)
DECLARE @Taction AS INT
DECLARE @Tabname AS NVARCHAR(100)
DECLARE @CntTabname AS NVARCHAR(100)
DECLARE @Fldname AS NVARCHAR(100)
DECLARE @ErrDesc AS NVARCHAR(1000)
DECLARE @sSql AS NVARCHAR(4000)
	SET @Po_ErrNo=0
	SET @CntTabname='RetailerCategory'
	SET @Fldname='CtgMainId'
	SET @Tabname = 'ETL_Prk_RetailerCategoryLevelValue'
	SET @Taction=0
	DECLARE Cur_RetailerCategoryLevelValue CURSOR 

	FOR SELECT ISNULL([Hierarchy Level Code],''),ISNULL([Parent Hierarchy Level Value Code],''),
    	ISNULL([Hierarchy Level Value Code],''),ISNULL([Hierarchy Level Value Name],''),ISNULL([Company Code],'')
	FROM ETL_Prk_RetailerCategoryLevelValue	ORDER BY [Company Code]
	
	OPEN Cur_RetailerCategoryLevelValue
	FETCH NEXT FROM Cur_RetailerCategoryLevelValue INTO @LevelCode,@ParentLevelValueCode,@LevelValueCode,@LevelValueName,@CompanyCode
	WHILE @@FETCH_STATUS=0
		BEGIN
			
				
			IF NOT EXISTS  (SELECT * FROM Company WHERE CmpCode = @CompanyCode )    
	  			BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Company Code: ' + @CompanyCode + ' is not availble'  		 
					INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'CompanyCode',@ErrDesc)
				END
		
				SELECT @CmpId =CmpId FROM  Company WHERE CmpCode=@CompanyCode
			IF NOT EXISTS  (SELECT * FROM RetailerCategoryLevel WHERE CmpId = @CmpId AND CtgLevelName=@LevelCode)    
	  			BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Category Level: ' + @LevelCode + ' is not available'  		 
					INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'HierarchyLevelCode',@ErrDesc)
				END
			SELECT @CtgLevelName=LevelName FROM RetailerCategoryLevel WITH (NOLOCK)WHERE CmpId = @CmpId AND CtgLevelName=@LevelCode 
			IF @CtgLevelName <>'Level1'
				BEGIN
				IF @ParentLevelValueCode <> '' 
					BEGIN
						IF NOT EXISTS (SELECT CtgLevelId FROM RetailerCategory WHERE CtgCode=@ParentLevelValueCode)
							BEGIN
								SET @Po_ErrNo=1
								SET @ErrDesc = 'Parent Category: ' + @ParentLevelValueCode+ ' is not available'	 
								INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'ParentHierarchyLevelValueCode',@ErrDesc)
							END
					END
				END
			IF @CtgLevelName <> 'Level1' 
				BEGIN
					SELECT @CtgLinkId=CtgMainId,@CtgLevelId=CtgLevelId + 1,@ParLinkCode=CtgLinkCode FROM RetailerCategory WHERE CtgCode=@ParentLevelValueCode
				END
			ELSE
				BEGIN
					SET @CtgLinkId=1
					SELECT @CtgLevelId=CtgLevelId FROM RetailerCategoryLevel WITH (NOLOCK) WHERE  CmpId = @CmpId AND CtgLevelName=@LevelCode 
					SELECT @ParLinkCode=''--+CAST(@CtgLevelId AS NVARCHAR(1000))
				END
			
			SELECT @NewLinkCode=ISNULL(MAX(CtgLinkCode),0) 
					FROM RetailerCategory WHERE LEN(CtgLinkCode)=  Len(@ParLinkCode) +3
					AND CtgLinkCode LIKE  @ParLinkCode +'%' AND CtgLevelId =@CtgLevelId
			SELECT @CtgLinkCode=dbo.Fn_ReturnNewCode(@ParLinkCode,3,@NewLinkCode)
			
			IF LTRIM(RTRIM(@LevelValueCode))='' 
				BEGIN
					SET @Po_ErrNo=1	
					SET @ErrDesc = 'Category Level Value Code should not be empty'		 
					INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'HierarchyLevelValueCode',@ErrDesc)
				END
					
			IF EXISTS (SELECT CtgCode  FROM RetailerCategory WHERE CtgCode=@LevelValueCode)
				BEGIN
							
					SET @Taction=2
				END
			ELSE
				BEGIN
							
					SET @Taction=1
				END
					    	
				
			IF LTRIM(RTRIM(@LevelValueName))='' 
				BEGIN
					SET @Po_ErrNo=1	
					SET @ErrDesc = 'Category Level Value Name should not be empty'		 
					INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'HierarchyLevelValueName',@ErrDesc)
				END
							
		SELECT @CtgMainId=dbo.Fn_GetPrimaryKeyInteger(@CntTabname,@FldName,CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
		
		IF  @Taction=1 AND @Po_ErrNo=0
		BEGIN	
			INSERT INTO RetailerCategory 
			(CtgMainId,CtgLinkId,CtgLevelId,CtgLinkCode,CtgCode,CtgName,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES (@CtgMainId,@CtgLinkId,@CtgLevelId,@CtgLinkCode,@LevelValueCode,@LevelValueName,
			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  @CntTabname AND Fldname = @FldName

			SET @sSql='INSERT INTO RetailerCategory VALUES('+ CAST(@CtgMainId AS VARCHAR(10))+','+ CAST(@CtgLinkId AS VARCHAR(10))+' 
				,'+ CAST(@CtgLevelId AS VARCHAR(10))+','''+@CtgLinkCode+''','''+@LevelValueCode+''','''+@LevelValueName+''',
			1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
			INSERT INTO Translog(strSql1) VALUES (@sSql)

			SET @sSql='UPDATE Counters SET CurrValue = CurrValue'+'+1'+' WHERE Tabname ='''+ @CntTabname+''' AND Fldname = '''+@FldName+''''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
		END
		IF  @Taction=2 AND @Po_ErrNo=0
		BEGIN
			UPDATE RetailerCategory SET CtgName=@LevelValueName WHERE CtgCode=@LevelValueCode
			SET @sSql='UPDATE RetailerCategory SET CtgName='''+@LevelValueName+''' WHERE CtgCode='''+@LevelValueCode+''''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
		END
	FETCH NEXT FROM Cur_RetailerCategoryLevelValue INTO @LevelCode,@ParentLevelValueCode,@LevelValueCode,@LevelValueName,@CompanyCode
	END
	CLOSE Cur_RetailerCategoryLevelValue
	DEALLOCATE Cur_RetailerCategoryLevelValue
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateGeographyHierarchyLevel' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateGeographyHierarchyLevel
GO
--Exec Proc_ValidateGeographyHierarchyLevel 0
CREATE Procedure Proc_ValidateGeographyHierarchyLevel
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateGeographyHierarchyLevel
* PURPOSE	: To Insert and Update records in the Table GeographyLevel
* CREATED	: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @Exist 		AS 	INT
	DECLARE @Tabname 	AS	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	
	DECLARE @GeoHierLevelCode AS      NVARCHAR(100)
	DECLARE @LevelName 	  AS	  NVARCHAR(100)
	DECLARE @MaxHierLevel 	  AS      NVARCHAR(100)
	
	DECLARE @Index 		AS INT
	DECLARE @GeoLevelId 	AS INT
	DECLARE @HierLevel 	AS INT

	DECLARE @TransStr	AS NVARCHAR(4000) 		 	  

	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='GeographyLevel'
	SET @Fldname='GeoLevelId'
	SET @Tabname = 'ETL_Prk_GeographyHierarchyLevel'
	SET @Exist=0
	
	DECLARE Cur_GeograhyHierarchyLevel CURSOR
	FOR SELECT ISNULL([Geography Hierarchy Level Code],''),ISNULL([Level Name],''),ISNULL([Maximum Level],'')
	FROM ETL_Prk_GeographyHierarchyLevel

	OPEN Cur_GeograhyHierarchyLevel
	FETCH NEXT FROM Cur_GeograhyHierarchyLevel INTO @GeoHierLevelCode,@LevelName,@MaxHierLevel
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0

		SELECT @HierLevel=COUNT(DISTINCT [Level Name]) FROM ETL_Prk_GeographyHierarchyLevel

		IF @HierLevel<>CAST(@MaxHierLevel AS INT)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Max Hierarchy Level',
			'Max Hierarchy Level is not matched with the no of records in Level:'+@LevelName)
			SET @Po_ErrNo=1 			
		END
		
		IF @Po_ErrNo=0
		BEGIN

			IF CAST(@MaxHierLevel AS INT)<10
			BEGIN
				SET @Index=1
			END
			ELSE IF CAST(@MaxHierLevel AS INT)<100 AND CAST(@MaxHierLevel AS INT)>10
			BEGIN
				SET @Index=2
			END
			ELSE
			BEGIN
				SET @Index=3
			END

			IF CAST(@MaxHierLevel AS INT)>=CONVERT(INT,RIGHT(@LevelName,@Index)) AND CONVERT(INT,RIGHT(@LevelName,@Index))>0
			BEGIN
				SET @Po_ErrNo=0	
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Level Name',
				'Level Name:'+@LevelName+' is wrong')

				SET @Po_ErrNo=1
			END
		END

		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@GeoHierLevelCode))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarchy Level Code',
				'Geography Hierarchy Level Code should not be empty')

				SET @Po_ErrNo=1
			END
		END

		IF @Po_ErrNo=0 
		BEGIN
			IF EXISTS(SELECT * FROM GeographyLevel WITH (NOLOCK) WHERE LevelName=@LevelName)
			BEGIN
				SELECT @GeoLevelId=GeoLevelId FROM GeographyLevel WITH (NOLOCK) 
				WHERE LevelName=@LevelName

				SET @Exist=1 
			END
		
			IF @Exist=0 
			BEGIN
				SELECT @GeoLevelId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))

				INSERT INTO GeographyLevel 
				(GeoLevelId,GeoLevelName,LevelName,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES
				(@GeoLevelId,@GeoHierLevelCode,@LevelName,1,1,CONVERT(NVARCHAR(10),
				GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			

				SET @TransStr='INSERT INTO GeographyLevel 
				(GeoLevelId,GeoLevelName,LevelName,
				Availability,LastModBy,LastModDate,AuthId,AuthDate) 
				VALUES('+
				CAST(@GeoLevelId AS NVARCHAR(10))+','''+@GeoHierLevelCode+''','''+@LevelName+''',1,1,'''+
				CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
			
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)

				UPDATE Counters SET CurrValue=@GeoLevelId WHERE TabName=@DestTabname AND FldName=@FldName

				SET @TransStr='UPDATE Counters SET CurrValue='+
				CAST(@GeoLevelId AS NVARCHAR(10))+' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''

				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)

			END	
			ELSE
			BEGIN
				UPDATE GeographyLevel SET GeoLevelName=@GeoHierLevelCode
				WHERE GeoLevelId=@GeoLevelId

				SET @TransStr='UPDATE GeographyLevel SET GeoLevelName='''+@GeoHierLevelCode+'''
				WHERE GeoLevelId='+CAST(@GeoLevelId AS NVARCHAR(10))+''

				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)

			END
		END			

		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_GeograhyHierarchyLevel
			DEALLOCATE Cur_GeograhyHierarchyLevel
			RETURN
		END
			
		FETCH NEXT FROM Cur_GeograhyHierarchyLevel INTO @GeoHierLevelCode,@LevelName,@MaxHierLevel
	END
	CLOSE Cur_GeograhyHierarchyLevel
	DEALLOCATE Cur_GeograhyHierarchyLevel

END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateGeographyHierarchyLevelValue' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateGeographyHierarchyLevelValue
GO
/*
BEGIN TRANSACTION
SELECT * FROM ETL_Prk_GeographyHierarchyLevelValue
Exec Proc_ValidateGeographyHierarchyLevelValue 0
SELECT * FROM Geography
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_ValidateGeographyHierarchyLevelValue
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ValidateGeographyHierarchyLevelValue
* PURPOSE		: To Insert and Update records in the Table GeographyCategoryValue
* CREATED		: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*	{date}		{developer}		{brief modification description}
* 15/10/2010	Nandakumar R.G	Addition of Population field
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 		AS 	INT
	DECLARE @Tabname 	AS     	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	
	DECLARE @GeoHierLevelCode 		AS  NVARCHAR(100)
	DECLARE @ParentHierLevelCode 	AS  NVARCHAR(100)
	DECLARE @GeoHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @GeoHierLevelValueName 	AS  NVARCHAR(100)
	DECLARE @ParentLinkCode			AS 	NVARCHAR(100)
	DECLARE @NewLinkCode 			AS 	NVARCHAR(100)
	DECLARE @LevelName 				AS 	NVARCHAR(100)
	DECLARE @Population				AS 	NUMERIC(38,6)
	
	DECLARE @GeoLevelId 	AS 	INT
	DECLARE @GeoMainId 	AS 	INT
	DECLARE @GeoLinkId 	AS 	INT
	DECLARE @GeoLinkCode 	AS 	NVARCHAR(100)
	DECLARE @TransStr 	AS 	NVARCHAR(4000)
	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='Geography'
	SET @Fldname='GeoMainId'
	SET @Tabname = 'ETL_Prk_GeographyHierarchyLevelValue'
	SET @Exist=0
	
	DECLARE Cur_GeographyHierarchyLevelValue CURSOR
	FOR SELECT ISNULL([Geography Hierarchy Level Code],''),ISNULL([Parent Hierarchy Level Value Code],''),
	ISNULL([Geography Hierarchy Level Value Code],''),ISNULL([Geography Hierarchy Level Value Name],''),ISNULL([Population],0)
	FROM ETL_Prk_GeographyHierarchyLevelValue ETL,GEographyLevel GL
	WHERE ETL.[Geography Hierarchy Level Code]=GL.GeoLevelName
	ORDER BY GL.LevelName
	OPEN Cur_GeographyHierarchyLevelValue
	FETCH NEXT FROM Cur_GeographyHierarchyLevelValue INTO @GeoHierLevelCode,@ParentHierLevelCode,
	@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0
		IF NOT EXISTS(SELECT * FROM GeographyLevel WITH (NOLOCK) WHERE GeoLevelName=@GeoHierLevelCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Geography Level',
			'Geography Level:'+@GeoHierLevelCode+' is not available')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @GeoLevelId=GeoLevelId,@LevelName=LevelName FROM GeographyLevel WITH (NOLOCK)
			WHERE GeoLevelName=@GeoHierLevelCode
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Geography WITH (NOLOCK) WHERE GeoCode=@ParentHierLevelCode)
			AND @ParentHierLevelCode<>'GeoFirstLevel'
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Parent Geography Level',
				'Parent Geography Level:'+@ParentHierLevelCode+' is not available')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @GeoLinkId=ISNULL(GeoMainId,0) FROM Geography WITH (NOLOCK)
				WHERE GeoCode=@ParentHierLevelCode
				SET @GeoLinkId=ISNULL(@GeoLinkId,0)
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@GeoHierLevelValueCode))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value Code',
				'Geography Hierarvhy Level Value Code should not be empty')
				SET @Po_ErrNo=1
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@GeoHierLevelValueName))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value Name',
				'Geography Hierarvhy Level Value Name should not be empty')
				SET @Po_ErrNo=1
			END
		END		
		
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS(SELECT * FROM Geography WITH (NOLOCK) WHERE GeoCode=@GeoHierLevelValueCode)
			BEGIN
				SET @Exist=1
				SELECT @GeoMainId=GeoMainId FROM Geography WITH (NOLOCK) WHERE GeoCode=@GeoHierLevelValueCode
				
			END
		
			IF @Exist=0
			BEGIN
				SELECT @GeoMainId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
				IF @LevelName='Level1'			
				BEGIN
					SET @GeoLinkId=0
	
					SELECT @GeoLevelId=GeoLevelId FROM GeographyLevel WITH (NOLOCK)
					WHERE  GeoLevelName=@GeoHierLevelCode
		
					SELECT @ParentLinkCode='00'+CAST(@GeoLevelId AS NVARCHAR(100))
				END
				ELSE
				BEGIN
					SELECT 	@ParentLinkCode=GeoLinkCode FROM Geography
					WHERE GeoMainId=@GeoLinkId
				END
				SELECT @NewLinkCode=ISNULL(MAX(GeoLinkCode),0)
				FROM Geography WHERE LEN(GeoLinkCode)=  Len(@ParentLinkCode)+3
				AND GeoLinkCode LIKE  @ParentLinkCode +'%' AND GeoLevelId =@GeoLevelId
				SELECT 	@GeoLinkCode=dbo.Fn_ReturnNewCode(@ParentLinkCode,3,@NewLinkCode)
				IF LEN(@GeoLinkCode)<>(SUBSTRING(@LevelName,6,LEN(@LevelName))+1)*3
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value',
					'Geography Hierarvhy Level is not match with parent level for: '+@GeoHierLevelValueCode)
	
					SET @Po_ErrNo=1
				END
				
				IF @Po_ErrNo=0
				BEGIN
					INSERT INTO Geography(GeoMainId,GeoLinkId,GeoLevelId,GeoLinkCode,GeoCode,GeoName,[Population],
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@GeoMainId,@GeoLinkId,@GeoLevelId,@GeoLinkCode,
					@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
				
	
					SET @TransStr='INSERT INTO Geography
					(GeoMainId,GeoLinkId,GeoLevelId,GeoLinkCode,GeoCode,GeoName,[Population],
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES('+CAST(@GeoMainId AS NVARCHAR(10))+','+
					CAST(@GeoLinkId AS NVARCHAR(10))+','+CAST(@GeoLevelId AS NVARCHAR(10))+','''+@GeoLinkCode+''','''
					+@GeoHierLevelValueCode+''','''+@GeoHierLevelValueName+''+CAST(@Population AS NVARCHAR(100))+
					',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
	
					UPDATE Counters SET CurrValue=@GeoMainId WHERE TabName=@DestTabname AND FldName=@FldName
	
					SET @TransStr='UPDATE Counters SET CurrValue='+CAST(@GeoMainId AS NVARCHAR(10))+
					' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
				END
			END	
			ELSE
			BEGIN
				UPDATE Geography SET GeoName=@GeoHierLevelValueName
				WHERE GeoMainId=@GeoMainId
				SET @TransStr='UPDATE Geography SET GeoName='''+@GeoHierLevelValueName+
				''' WHERE GeoMainId='+CAST(@GeoMainId AS NVARCHAR(10))
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
			END	
		END	
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_GeographyHierarchyLevelValue
			DEALLOCATE Cur_GeographyHierarchyLevelValue
			RETURN
		END		
			
		FETCH NEXT FROM Cur_GeographyHierarchyLevelValue INTO @GeoHierLevelCode,@ParentHierLevelCode,
		@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population
	END
	CLOSE Cur_GeographyHierarchyLevelValue
	DEALLOCATE Cur_GeographyHierarchyLevelValue
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLRetailerCategoryLevelValue' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLRetailerCategoryLevelValue
GO
-- EXEC Proc_Cn2Cs_BLRetailerCategoryLevelValue ''
CREATE PROC Proc_Cn2Cs_BLRetailerCategoryLevelValue
(
	@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE: Proc_Cn2Cs_BLProduct
* PURPOSE: To Insert the records From Console into ETL_Prk_Product,
			ETL_Prk_ProductHierarchyLevelvalue
* SCREEN : Console Integration-Product Download
* CREATED: Nandakumar R.G 31-12-2008
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
-- 	BEGIN TRANSACTION

	DECLARE @ErrStatus INT

	TRUNCATE TABLE ETL_Prk_RetailerCategoryLevelValue

	INSERT INTO ETL_Prk_RetailerCategoryLevelValue([Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Hierarchy Level Value Code],[Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT [Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Hierarchy Level Value Code],[Hierarchy Level Value Name],[Company Code] 
	FROM Cn2Cs_Prk_BLRetailerCategoryLevelValue WHERE DownLoadFlag='D'

	EXEC Proc_ValidateRetailerCategoryLevelValue @Po_ErrNo= @ErrStatus OUTPUT
		
	IF(@ErrStatus=0)
	BEGIN		
		DELETE FROM Cn2Cs_Prk_BLRetailerCategoryLevelValue 
		--COMMIT TRANSACTION
	END
-- 	ELSE
-- 	BEGIN
-- 		ROLLBACK TRANSACTION
-- 	END
	
	SET @Po_ErrNo= @ErrStatus
	RETURN

END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateRetailerCategoryLevelValue' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateRetailerCategoryLevelValue
GO
CREATE Procedure Proc_ValidateRetailerCategoryLevelValue
(

	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateRetailerCategoryLevelValue
* PURPOSE	: To Insert and Update records  from xml file in the Table RetailerCategoryLevel 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
BEGIN

DECLARE @LevelCode AS NVARCHAR(100)
DECLARE @ParentLevelValueCode AS NVARCHAR(100)
DECLARE @LevelValueCode AS NVARCHAR(100)
DECLARE @LevelValueName AS NVARCHAR(100)
DECLARE @CompanyCode AS NVARCHAR(100)
DECLARE @CtgLevelId AS INT
DECLARE @CtgMainId AS INT
DECLARE @CtgLinkId AS INT
DECLARE @CmpId AS INT
DECLARE @Code AS INT 
DECLARE @CtgLinkCode AS NVARCHAR(500)
DECLARE @ParLinkCode AS NVARCHAR(500)
DECLARE @NewLinkCode AS NVARCHAR(500)
DECLARE @CtgLevelName AS NVARCHAR(100)
DECLARE @Taction AS INT
DECLARE @Tabname AS NVARCHAR(100)
DECLARE @CntTabname AS NVARCHAR(100)
DECLARE @Fldname AS NVARCHAR(100)
DECLARE @ErrDesc AS NVARCHAR(1000)
DECLARE @sSql AS NVARCHAR(4000)
	SET @Po_ErrNo=0
	SET @CntTabname='RetailerCategory'
	SET @Fldname='CtgMainId'
	SET @Tabname = 'ETL_Prk_RetailerCategoryLevelValue'
	SET @Taction=0
	DECLARE Cur_RetailerCategoryLevelValue CURSOR 

	FOR SELECT ISNULL([Hierarchy Level Code],''),ISNULL([Parent Hierarchy Level Value Code],''),
    	ISNULL([Hierarchy Level Value Code],''),ISNULL([Hierarchy Level Value Name],''),ISNULL([Company Code],'')
	FROM ETL_Prk_RetailerCategoryLevelValue	ORDER BY [Company Code]
	
	OPEN Cur_RetailerCategoryLevelValue
	FETCH NEXT FROM Cur_RetailerCategoryLevelValue INTO @LevelCode,@ParentLevelValueCode,@LevelValueCode,@LevelValueName,@CompanyCode
	WHILE @@FETCH_STATUS=0
		BEGIN
			
				
			IF NOT EXISTS  (SELECT * FROM Company WHERE CmpCode = @CompanyCode )    
	  			BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Company Code: ' + @CompanyCode + ' is not availble'  		 
					INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'CompanyCode',@ErrDesc)
				END
		
				SELECT @CmpId =CmpId FROM  Company WHERE CmpCode=@CompanyCode
			IF NOT EXISTS  (SELECT * FROM RetailerCategoryLevel WHERE CmpId = @CmpId AND CtgLevelName=@LevelCode)    
	  			BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Category Level: ' + @LevelCode + ' is not available'  		 
					INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'HierarchyLevelCode',@ErrDesc)
				END
			SELECT @CtgLevelName=LevelName FROM RetailerCategoryLevel WITH (NOLOCK)WHERE CmpId = @CmpId AND CtgLevelName=@LevelCode 
			IF @CtgLevelName <>'Level1'
				BEGIN
				IF @ParentLevelValueCode <> '' 
					BEGIN
						IF NOT EXISTS (SELECT CtgLevelId FROM RetailerCategory WHERE CtgCode=@ParentLevelValueCode)
							BEGIN
								SET @Po_ErrNo=1
								SET @ErrDesc = 'Parent Category: ' + @ParentLevelValueCode+ ' is not available'	 
								INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'ParentHierarchyLevelValueCode',@ErrDesc)
							END
					END
				END
			IF @CtgLevelName <> 'Level1' 
				BEGIN
					SELECT @CtgLinkId=CtgMainId,@CtgLevelId=CtgLevelId + 1,@ParLinkCode=CtgLinkCode FROM RetailerCategory WHERE CtgCode=@ParentLevelValueCode
				END
			ELSE
				BEGIN
					SET @CtgLinkId=1
					SELECT @CtgLevelId=CtgLevelId FROM RetailerCategoryLevel WITH (NOLOCK) WHERE  CmpId = @CmpId AND CtgLevelName=@LevelCode 
					SELECT @ParLinkCode=''--+CAST(@CtgLevelId AS NVARCHAR(1000))
				END
			
			SELECT @NewLinkCode=ISNULL(MAX(CtgLinkCode),0) 
					FROM RetailerCategory WHERE LEN(CtgLinkCode)=  Len(@ParLinkCode) +3
					AND CtgLinkCode LIKE  @ParLinkCode +'%' AND CtgLevelId =@CtgLevelId
			SELECT @CtgLinkCode=dbo.Fn_ReturnNewCode(@ParLinkCode,3,@NewLinkCode)
			
			IF LTRIM(RTRIM(@LevelValueCode))='' 
				BEGIN
					SET @Po_ErrNo=1	
					SET @ErrDesc = 'Category Level Value Code should not be empty'		 
					INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'HierarchyLevelValueCode',@ErrDesc)
				END
					
			IF EXISTS (SELECT CtgCode  FROM RetailerCategory WHERE CtgCode=@LevelValueCode)
				BEGIN
							
					SET @Taction=2
				END
			ELSE
				BEGIN
							
					SET @Taction=1
				END
					    	
				
			IF LTRIM(RTRIM(@LevelValueName))='' 
				BEGIN
					SET @Po_ErrNo=1	
					SET @ErrDesc = 'Category Level Value Name should not be empty'		 
					INSERT INTO Errorlog VALUES (@Po_ErrNo,@Tabname,'HierarchyLevelValueName',@ErrDesc)
				END
							
		SELECT @CtgMainId=dbo.Fn_GetPrimaryKeyInteger(@CntTabname,@FldName,CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
		
		IF  @Taction=1 AND @Po_ErrNo=0
		BEGIN	
			INSERT INTO RetailerCategory 
			(CtgMainId,CtgLinkId,CtgLevelId,CtgLinkCode,CtgCode,CtgName,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES (@CtgMainId,@CtgLinkId,@CtgLevelId,@CtgLinkCode,@LevelValueCode,@LevelValueName,
			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  @CntTabname AND Fldname = @FldName

			SET @sSql='INSERT INTO RetailerCategory VALUES('+ CAST(@CtgMainId AS VARCHAR(10))+','+ CAST(@CtgLinkId AS VARCHAR(10))+' 
				,'+ CAST(@CtgLevelId AS VARCHAR(10))+','''+@CtgLinkCode+''','''+@LevelValueCode+''','''+@LevelValueName+''',
			1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
			INSERT INTO Translog(strSql1) VALUES (@sSql)

			SET @sSql='UPDATE Counters SET CurrValue = CurrValue'+'+1'+' WHERE Tabname ='''+ @CntTabname+''' AND Fldname = '''+@FldName+''''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
		END
		IF  @Taction=2 AND @Po_ErrNo=0
		BEGIN
			UPDATE RetailerCategory SET CtgName=@LevelValueName WHERE CtgCode=@LevelValueCode
			SET @sSql='UPDATE RetailerCategory SET CtgName='''+@LevelValueName+''' WHERE CtgCode='''+@LevelValueCode+''''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
		END
	FETCH NEXT FROM Cur_RetailerCategoryLevelValue INTO @LevelCode,@ParentLevelValueCode,@LevelValueCode,@LevelValueName,@CompanyCode
	END
	CLOSE Cur_RetailerCategoryLevelValue
	DEALLOCATE Cur_RetailerCategoryLevelValue
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLRetailerValueClass' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLRetailerValueClass
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_BLRetailerValueClass
UPDATE Cn2Cs_Prk_BLRetailerValueClass SET DownloadFlag='D'
SELECT * FROM RetailerValueClass
SELECT * FROM ETL_Prk_RetailerValueClass
EXEC Proc_Cn2Cs_BLRetailerValueClass 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLRetailerValueClass
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_BLRetailerValueClass
* PURPOSE		: To DownLoad the Retailer Value Class from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 21/10/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @Taction  			INT
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @CmpCode  			NVARCHAR(200)
	DECLARE @CtgCode			NVARCHAR(200)
	DECLARE @ValueClassCode		NVARCHAR(200)
	DECLARE @ValueClassName		NVARCHAR(200)
	DECLARE @Turnover  			NUMERIC(18, 2)
	DECLARE @DownLoad			NVARCHAR(20)
	DECLARE @ErrStatus			INT
	DECLARE @LevelName			NVARCHAR(10)
	DECLARE @LinkCode			NVARCHAR(100)
	DECLARE @CmpId  			INT	

	DECLARE @MaxLevelName		NVARCHAR(10)
	DECLARE @LinkCodeLength  	INT	


	SET @Po_ErrNo=0	
	SET @Tabname = 'Cn2Cs_Prk_BLRetailerValueClass'
	
 	DELETE FROM Cn2Cs_Prk_BLRetailerValueClass WHERE DownLoadFlag='Y'
	TRUNCATE TABLE ETL_Prk_RetailerValueClass

	DECLARE Cur_RetailerValueClass CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([CmpCode])),''),ISNULL(LTRIM(RTRIM([ChannelCode])),''),
	ISNULL(LTRIM(RTRIM([ClassCode])),''),ISNULL(LTRIM(RTRIM([ClassDesc])),''),
	[TrunOver],
	[DownLoadFlag] FROM Cn2Cs_Prk_BLRetailerValueClass WHERE DownLoadFlag='D'

	OPEN Cur_RetailerValueClass
	FETCH NEXT FROM Cur_RetailerValueClass INTO @CmpCode,@CtgCode,@ValueClassCode,@ValueClassName,@Turnover,@DownLoad
	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @Po_ErrNo=0
	
		IF NOT EXISTS (SELECT CmpCode FROM Company WHERE CmpCode=@CmpCode)
		BEGIN
			SET @ErrDesc = 'Company Code:'+@CmpCode+' does not exists'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Code',@ErrDesc)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CmpCode=CmpCode FROM Company WHERE CmpCode=@CmpCode
			SELECT @CmpId=CmpId FROM Company WHERE CmpCode=@CmpCode			
		END

		IF NOT EXISTS (SELECT CtgCode FROM RetailerCategory WHERE CtgCode=@CtgCode)
		BEGIN
			SET @ErrDesc = 'Retailer Category Level Value Code:'+@CtgCode+' does not exists'
			INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Category Level Value',@ErrDesc)
			SET @Po_ErrNo=1
		END

		IF @Po_ErrNo=0
		BEGIN
			SELECT @LevelName=LevelName FROM RetailerCategoryLevel RCL,RetailerCategory RC
			WHERE RCL.CtgLevelId=RC.CtgLevelId AND RC.CtgCode=@CtgCode
			AND RCL.CmpId=@CmpId		

			SELECT @MaxLevelName=LevelName FROM RetailerCategoryLevel WHERE CmpId=@CmpId
			AND CtgLevelId IN(SELECT MAX(CtgLevelId) FROM RetailerCategoryLevel WHERE CmpId=@CmpId)

			SELECT @MaxLevelName=LevelName FROM RetailerCategoryLevel WHERE CmpId=@CmpId
			
			SELECT @LinkCodeLength=CAST(RIGHT(LevelName,LEN(LevelName)-5) AS INT) FROM RetailerCategoryLevel			
		END

		IF @Po_ErrNo=0
		BEGIN
			IF @LevelName=@MaxLevelName
			BEGIN
				IF NOT EXISTS (SELECT ValueClassCode FROM RetailerValueClass RVC,
				RetailerCategory RC WHERE RVC.CtgMainId=RC.CtgMainId AND RC.CtgCode=@CtgCode 
				AND RVC.ValueClassCode=@ValueClassCode)
				BEGIN
					INSERT INTO ETL_Prk_RetailerValueClass([Company Code],[Category Level Value Code],
					[Value Class Code],[Value Class Name],[Turn Over])
					VALUES(@CmpCode,@CtgCode,@ValueClassCode,@ValueClassName,@Turnover)
				END
			END
			ELSE 
			BEGIN				
				SELECT @LinkCode=CtgLinkCode FROM RetailerCategory WHERE CtgCode=@CtgCode

				INSERT INTO ETL_Prk_RetailerValueClass([Company Code],[Category Level Value Code],
				[Value Class Code],[Value Class Name],[Turn Over])				
				SELECT @CmpCode,CtgCode,@ValueClassCode,@ValueClassName,@Turnover
				FROM RetailerCategory RC,RetailerCategoryLevel RCL WHERE CtgLinkCode LIKE @LinkCode+'%'
				AND LEN(CtgLinkCode)=@LinkCodeLength*3 AND RC.CtgLevelId=RCL.CtgLevelId 
				AND RCL.CmpId=@CmpId				
			END

			UPDATE Cn2Cs_Prk_BLRetailerValueClass SET DownLoadFlag='Y'
			WHERE ChannelCode=@CtgCode AND ClassCode=@ValueClassCode
		END

		FETCH NEXT FROM Cur_RetailerValueClass INTO @CmpCode,@CtgCode,@ValueClassCode,@ValueClassName,@Turnover,@DownLoad
	END
	CLOSE Cur_RetailerValueClass
	DEALLOCATE Cur_RetailerValueClass
	
	EXEC Proc_ValidateBLRetailerValueClass @Po_ErrNo= @ErrStatus OUTPUT

--	IF @ErrStatus =0
--	BEGIN
--		UPDATE Cn2Cs_Prk_BLRetailerValueClass SET DownLoadFlag='Y'		
--	END

	SET @Po_ErrNo= @ErrStatus
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateBLRetailerValueClass' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateBLRetailerValueClass
GO
--Exec Proc_ValidateRetailerValueClass 0 
--select * from RetailerValueClass
--select * from ETL_Prk_RetailerValueClass
--SELECT * FROM ErrorLog
CREATE Procedure Proc_ValidateBLRetailerValueClass
(

	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateRetailerValueClass
* PURPOSE	: To Insert and Update records  from xml file in the Table RetailerValueClass 
* CREATED	: Nandakumar R.G
* CREATED DATE	: 30/01/2009
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
BEGIN

	DECLARE @CompanyCode AS NVARCHAR(100)
	DECLARE @CategoryLevelValueCode AS NVARCHAR(100)
	DECLARE @ValueClassCode AS NVARCHAR(100)
	DECLARE @ValueClassName AS NVARCHAR(100)
	DECLARE @TurnOver AS NVARCHAR(100)
	DECLARE @RtrClassId AS INT
	DECLARE @CmpId AS INT
	DECLARE @CtgMainId INT
	DECLARE @Taction AS INT
	DECLARE @Tabname AS NVARCHAR(100)
	DECLARE @CntTabname AS NVARCHAR(100)
	DECLARE @Fldname AS NVARCHAR(100)
	DECLARE @ErrDesc AS NVARCHAR(1000)
	DECLARE @sSql AS NVARCHAR(4000)

	SET @CntTabname='RetailerValueClass'
	SET @Fldname='RtrClassId'
	SET @Tabname = 'ETL_Prk_RetailerValueClass'
	SET @Taction=0
	SET @Po_ErrNo=0
	DECLARE Cur_RetailerValueClass CURSOR 
	FOR SELECT ISNULL([Company Code],''),ISNULL([Category Level Value Code],''),ISNULL([Value Class Code],''),
    	ISNULL([Value Class Name],''),ISNULL([Turn Over],'0')
	FROM ETL_Prk_RetailerValueClass
	
	OPEN Cur_RetailerValueClass
	FETCH NEXT FROM Cur_RetailerValueClass INTO @CompanyCode,@CategoryLevelValueCode,@ValueClassCode,@ValueClassName,@TurnOver
	WHILE @@FETCH_STATUS=0		
	BEGIN			

		IF NOT EXISTS  (SELECT * FROM Company WHERE CmpCode = @CompanyCode )    
  		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Company Code ' + @CompanyCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (1,@Tabname,'CompanyCode',@ErrDesc)
		END
		
		SELECT @CmpId =CmpId FROM  Company WHERE CmpCode=@CompanyCode
		IF NOT EXISTS  (SELECT * FROM RetailerCategory WHERE  CtgCode=@CategoryLevelValueCode)    
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Category Level Value ' + @CategoryLevelValueCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (2,@Tabname,'CategoryLevelValueCode',@ErrDesc)
		END
				
		SELECT @CtgMainId =CtgMainId FROM RetailerCategory WITH (NOLOCK)WHERE CtgCode=@CategoryLevelValueCode 
					
		IF LTRIM(RTRIM(@ValueClassCode))<>'' 
		BEGIN
			IF EXISTS (SELECT ValueClassCode  FROM RetailerValueClass WHERE ValueClassCode=@ValueClassCode AND CtgMainId=@CtgMainId)
			BEGIN
				SET @Taction=2
			END
			ELSE
			BEGIN
				SET @Taction=1
			END
		END
		ELSE
		BEGIN
			SET @Po_ErrNo=1	
			SET @Taction=0
			SET @ErrDesc = 'Value Class Code should not be empty'		 
			INSERT INTO Errorlog VALUES (3,@Tabname,'ValueClassCode',@ErrDesc)

		END		
							
		IF LTRIM(RTRIM(@ValueClassName))='' 
		BEGIN
			SET @Po_ErrNo=1	
			SET @Taction=0
			SET @ErrDesc = 'Value Class Name should not be empty'		 
			INSERT INTO Errorlog VALUES (4,@Tabname,'ValueClassName',@ErrDesc)
		END
								
		IF ISNUMERIC(@TurnOver)=0 
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Turn Over should not be empty'		 
			INSERT INTO Errorlog VALUES (5,@Tabname,'TurnOver',@ErrDesc)
		END
							
		SELECT @RtrClassId=dbo.Fn_GetPrimaryKeyInteger(@CntTabname,@FldName,CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))

		IF @RtrClassId=0 
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Reset the Counter Value'		 
			INSERT INTO Errorlog VALUES (6,@Tabname,'Counter Value',@ErrDesc)
		END
		
		IF  @Taction=1 AND @Po_ErrNo=0
		BEGIN	
			INSERT INTO RetailerValueClass 
			(RtrClassId,CmpId,CtgMainId,ValueClassCode,ValueClassName,Turnover,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RtrClassId,@CmpId,@CtgMainId,@ValueClassCode,@ValueClassName,@TurnOver,
			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))

			SET @sSql='INSERT INTO RetailerValueClass (RtrClassId,CmpId,CtgMainId,ValueClassCode,ValueClassName,Turnover,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES('+CAST(@RtrClassId AS VARCHAR(10))+','+CAST(@CmpId AS VARCHAR(10))+','+CAST(@CtgMainId AS VARCHAR(10))+','''+@ValueClassCode+''','''+@ValueClassName+''','+CAST(@TurnOver AS VARCHAR(20))+',
			1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
			INSERT INTO Translog(strSql1) VALUES (@sSql)

			UPDATE Counters SET CurrValue = @RtrClassId WHERE Tabname =  @CntTabname AND Fldname = @FldName
			SET @sSql='UPDATE Counters SET CurrValue = '+ CAST(@RtrClassId AS VARCHAR(10))+' WHERE Tabname ='''+@CntTabname+''' AND Fldname ='''+ @FldName+''''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
		END
		IF  @Taction=2 AND @Po_ErrNo=0
		BEGIN
			UPDATE RetailerValueClass SET ValueClassName=@ValueClassName,TurnOver=@TurnOver WHERE ValueClassCode=@ValueClassCode AND CtgMainId=@CtgMainId 
			SET @sSql='UPDATE RetailerValueClass SET ValueClassName='''+@ValueClassName+''',TurnOver='+CAST(@TurnOver AS VARCHAR(20))+' WHERE ValueClassCode='''+@ValueClassCode+''''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
		END
		FETCH NEXT FROM Cur_RetailerValueClass INTO @CompanyCode,@CategoryLevelValueCode,@ValueClassCode,@ValueClassName,@TurnOver
	END
	CLOSE Cur_RetailerValueClass
	DEALLOCATE Cur_RetailerValueClass


RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_PrefixMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_PrefixMaster
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PrefixMaster 0
SELECT * FROM CompanyCounters
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_PrefixMaster
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_PrefixMaster
* PURPOSE		: To Download the Prefix details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 26/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/

SET NOCOUNT ON
BEGIN	
	
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_PrefixMaster WHERE DownLoadFlag='D' AND MasterType=1)
	BEGIN
		INSERT INTO CompanyCounters(TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,YearReqd,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT 'Retailer','CmpRtrCode',RtrPrefix,5,1,0,'Retailer Master',1,2010,1,1,1,GETDATE(),1,GETDATE()
		FROM Cn2Cs_Prk_PrefixMaster WHERE DownLoadFlag='D' AND MasterType=1		
	END
	ELSE
	BEGIN
		UPDATE CompanyCounters SET Prefix=A.RtrPrefix FROM
		(SELECT DISTINCT RtrPrefix AS RtrPrefix FROM Cn2Cs_Prk_PrefixMaster WHERE DownLoadFlag='D' AND MasterType=1) A
		WHERE TabName='Retailer' AND FldName='CmpRtrCode'
	END		
	
	UPDATE Cn2Cs_Prk_PrefixMaster SET DownLoadFlag='Y'	

	SET @Po_ErrNo=0

	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_RetailerApproval' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_RetailerApproval
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_RetailerApproval 0
SELECT * FROM Cn2Cs_Prk_RetailerApproval
SELECT * FROM errorlog
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLUOM' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLUOM
GO
--EXEC Proc_Cn2Cs_BLUOM 0
CREATE PROCEDURE Proc_Cn2Cs_BLUOM
(
       @Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE: Proc_Cn2Cs_BLUOM
* PURPOSE: To Insert the records From Console to ETL_Prk_ProductBatch
* SCREEN : Console Integration-Product Batch
* CREATED BY: Nandakumar R.G 31-12-2008
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
	--BEGIN TRANSACTION

	DECLARE @ErrStatus INT

	TRUNCATE TABLE ETL_Prk_UOMMaster
	TRUNCATE TABLE ETL_Prk_UOMGroup

	DECLARE @BatchSeqCode VARCHAR(30)
	DECLARE @TaxGroupCode VARCHAR(20)

	INSERT INTO ETL_Prk_UOMMaster
	SELECT UOMCode,UOMName FROM Cn2Cs_Prk_BLUOM
	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster) 


	INSERT INTO ETL_Prk_UOMGroup
	SELECT UOMGroupCode,UOMGroupName,UOMCode,BaseUOM,ConvFact
	FROM Cn2Cs_Prk_BLUOM
	WHERE UOMGroupCode NOT IN (SELECT UOMGroupCode FROM UOMGroup)
	

	EXEC Proc_ValidateUOMMaster @Po_ErrNo= @ErrStatus OUTPUT
		
	IF(@ErrStatus=0)
	BEGIN		
		EXEC Proc_ValidateUOMGroup @Po_ErrNo= @ErrStatus OUTPUT
		IF(@ErrStatus=0)
		BEGIN		
			DELETE FROM Cn2Cs_Prk_BLUOM
		END
	END

	SET @Po_ErrNo=@ErrStatus
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateUOMMaster' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateUOMMaster
GO
--Exec Proc_ValidateUOMMaster 0
CREATE Procedure Proc_ValidateUOMMaster
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateUOMMaster
* PURPOSE	: To Insert and Update records in the Table UOM Master
* CREATED	: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
		
	DECLARE @Exist AS 	INT
	DECLARE @Tabname AS     NVARCHAR(100)
	DECLARE @DestTabname AS NVARCHAR(100)
	DECLARE @Fldname AS     NVARCHAR(100)
	
	DECLARE @UOMCode AS      NVARCHAR(100)
	DECLARE @UOMName AS      NVARCHAR(100)
	
	DECLARE @UOMId AS 	INT

	DECLARE @TransStr	AS 	NVARCHAR(4000)

	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='UOMMaster'
	SET @Fldname='UOMId'
	SET @Tabname = 'ETL_Prk_UOMMaster'
	SET @Exist=0
	
	DECLARE Cur_UOMMaster CURSOR
	FOR SELECT ISNULL([UOM Code],''),ISNULL([UOM Description],'')
	FROM ETL_Prk_UOMMaster

	OPEN Cur_UOMMaster
	FETCH NEXT FROM Cur_UOMMaster INTO @UOMCode,@UOMName
	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @Exist=0

		IF LTRIM(RTRIM(@UOMCode))=''
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'UOM Code',
			'UOM Code should not be empty')

			SET @Po_ErrNo=1
		END

		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@UOMName))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'UOM Name',
				'UOM Name should not be empty')

				SET @Po_ErrNo=1
			END
		END

		SET @Exist=0

		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS(SELECT * FROM UOMMaster WHERE UOMCode=@UOMCode)
			BEGIN
				SET @Exist=1 
			END
			
			IF @Exist=0
			BEGIN
				SET @UOMId = dbo.Fn_GetPrimaryKeyInteger('UOMMaster','UomId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))

				INSERT INTO UOMMaster 
				(UomId,UomCode,UomDescription,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@UOMId,@UOMCode,@UOMName,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 

				SET @TransStr='INSERT INTO UOMMaster 
				(UomId,UomCode,UomDescription,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES('+
				CAST(@UOMId AS NVARCHAR(10))+','''+@UOMCode+''','''+@UOMName+''',1,1,'''+
				CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'

				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)

				UPDATE Counters SET CurrValue = @UOMId WHERE TabName = 'UOMMaster' AND FldName = 'UomId'

              			SET @TransStr = 'UPDATE Counters SET CurrValue = ' + CAST(@UOMId AS VARCHAR(6)) + ' WHERE TabName = ' + '''UOMMaster''' + ' AND FldName = ' + '''UomId'''   

				INSERT INTO Translog(strSql1) Values (@TransStr)			

			END
			ELSE
			BEGIN
				UPDATE UOMMaster SET UOMDescription=@UOMName WHERE UOMCode=@UOMCode

				SET @TransStr='UPDATE UOMMaster SET UOMDescription='''+
				@UOMName+''' WHERE UOMCode='''+@UOMCode+''''

				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)

			END	
		END

		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_UOMMaster
			DEALLOCATE Cur_UOMMaster
			RETURN
		END

		FETCH NEXT FROM Cur_UOMMaster INTO @UOMCode,@UOMName
	END
	CLOSE Cur_UOMMaster
	DEALLOCATE Cur_UOMMaster

END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateTaxConfig_Group' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateTaxConfig_Group
GO
-- EXEC Proc_ValidateTaxConfig_Group 0
-- Select * from ETL_Prk_TaxConfig_GroupSetting
CREATE PROCEDURE Proc_ValidateTaxConfig_Group
(
@Po_ErrNo INT OUTPUT
)
AS
/**********************************************************************************************************************************
* PROCEDURE: Proc_ValidateTaxConfig_Group
* PURPOSE: To Insert and Update records  from xml file in the Table Tax Configuration and Group Setting
* CREATED: Boopathy.P	02/09/2009
************************************************************************************************************************************
* 08.09.2009  PanneerSelvam.k	Duplicate Issue 
***********************************************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Taction		INT
	DECLARE @StateId		INT
	DECLARE @ErrDesc		VARCHAR(1000)
	DECLARE @rno			INT
	DECLARE @Tabname		VARCHAR(50)
	DECLARE @sStr			NVARCHAR(4000)
	DECLARE @TaxCode		NVARCHAR(200)	
	DECLARE @TaxName		NVARCHAR(200)
	DECLARE @TaxId			INT
	DECLARE @InputTaxId		INT
	DECLARE @OutPutTaxId	INT
	DECLARE @AcCode			VARCHAR(10)
	DECLARE @CoaId			INT
	DECLARE @TaxGrpCode		NVARCHAR(200)	
	DECLARE @TaxGrpName		NVARCHAR(200)
	DECLARE @GrpType		NVARCHAR(200)
	DECLARE @GrpTypeId		INT
	DECLARE @TaxGrpId		INT
	SET @Po_ErrNo=0

	SET @Tabname = 'ETL_Prk_TaxConfig_GroupSetting'
	DECLARE Cur_TaxConfig CURSOR
	FOR SELECT ISNULL([TaxCode],''),ISNULL([TaxName],'') FROM 	
		(SELECT DISTINCT ISNULL(TaxId,0) AS TaxId,ISNULL([TaxCode],'') AS TaxCode,ISNULL([TaxName],'') AS TaxName 	
		FROM ETL_Prk_TaxConfig_GroupSetting Where DownLoadFlag = 'D') A ORDER BY TaxId
	OPEN Cur_TaxConfig
	FETCH NEXT FROM Cur_TaxConfig INTO @TaxCode,@TaxName
	Set @Rno = 0
	WHILE @@FETCH_STATUS=0
	BEGIN
		Set @Rno = @Rno + 1
		Set @Taction = 2 -- Insert
	
		--- Validation for NULL value
		IF ISNULL(@TaxCode,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Tax Code '+ @TaxCode + ' Not found '
			INSERT INTO Errorlog VALUES (1,@TabName,'Tax Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF ISNULL(@TaxName,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Tax Name '+ @TaxName + ' Not found '
			INSERT INTO Errorlog VALUES (1,@TabName,'Tax Name',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
	
		IF EXISTS (SELECT * FROM TaxConfiguration WHERE TaxCode = @TaxCode)
		BEGIN
			SET @Taction = 1  
		END
		IF @Taction = 1 
		BEGIN
			UPDATE TaxConfiguration SET TaxName=@TaxName
			WHERE TaxCode=@TaxCode
			SET @sStr = 'UPDATE TaxConfiguration SET TaxName=''' + @TaxName + ''' WHERE TaxCode=''' + @TaxCode + ''''
			INSERT INTO Translog(strSql1) Values (@sstr)
		END
		ELSE IF @Taction = 2 
		BEGIN
			IF @Taction = 2 
			BEGIN
				IF NOT EXISTS(SELECT CoaId FROM coamaster WHERE coaid=(SELECT max(a.coaid) FROM coamaster a
				WHERE a.aclevel= '4' and a.maingroup='2' and a.accode like '217%'))
				BEGIN
					SET @AcCode = '2170001'
				END
				ELSE
				BEGIN
					SELECT @AcCode=CAST(AcCode AS INT) FROM coamaster WHERE coaid=(SELECT max(a.coaid) FROM coamaster a
					WHERE a.aclevel= '4' and a.maingroup='2' and a.accode like '217%')
					SET @AcCode= CAST(@AcCode AS INT) + 1
				END
				SET @InputTaxId =dbo.Fn_GetPrimaryKeyInteger('CoaMaster','CoaId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
				IF @InputTaxId=0
				BEGIN
					SET @ErrDesc='Reset Counter Value'
					INSERT INTO Errorlog VALUES (1,@TabName,'Input Tax Coa Master',@ErrDesc)
  					SET @Taction = 0
  					SET @Po_ErrNo=1
				END			
				IF @Po_ErrNo=0
				BEGIN
					INSERT INTO CoaMaster (CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,
											LastModDate,AuthId,AuthDate) VALUES (@InputTaxId,CAST(@AcCode AS VARCHAR(50)),
											CAST(@TaxName + ' InPut' AS VARCHAR(50)),4,2,0,1,1,GETDATE(),1,GETDATE())

					--SELECT @InputTaxId,CAST(@AcCode AS VARCHAR(50)),
					--						CAST(@TaxName + ' InPut' AS VARCHAR(50)),4,2,0,1,1,GETDATE(),1,GETDATE()
					UPDATE Counters SET CurrValue =@InputTaxId WHERE TabName = 'CoaMaster' AND FldName = 'CoaId'
					--SELECT * FROM Counters WHERE TabName = 'CoaMaster' AND FldName = 'CoaId'

				END
				IF NOT EXISTS(SELECT * FROM coamaster WHERE coaid=(SELECT max(a.coaid) FROM coamaster a
				WHERE a.aclevel= '4' and a.maingroup='1' and a.accode like '131%'))
				BEGIN
					SET @AcCode = '1310001'
				END
				ELSE
				BEGIN
					SELECT @AcCode=AcCode FROM coamaster WHERE coaid=(SELECT max(a.coaid) FROM coamaster a
					WHERE a.aclevel= '4' and a.maingroup='1' and a.accode like '131%')
					SET @AcCode= CAST(@AcCode AS INT) + 1
				END
				SET @OutPutTaxId =dbo.Fn_GetPrimaryKeyInteger('CoaMaster','CoaId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
				IF @OutPutTaxId=0
				BEGIN
					SET @ErrDesc='Reset Counter Value'
					INSERT INTO Errorlog VALUES (1,@TabName,'Output Tax Coa Master',@ErrDesc)
  					SET @Taction = 0
  					SET @Po_ErrNo=1
				END

				IF @Po_ErrNo=0
				BEGIN
					INSERT INTO CoaMaster (CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,
											LastModDate,AuthId,AuthDate) VALUES (@OutPutTaxId,CAST(@AcCode AS VARCHAR(50)),
											CAST(@TaxName + ' OutPut' AS VARCHAR(50)),4,1,0,1,1,GETDATE(),1,GETDATE())

					--SELECT @OutPutTaxId,CAST(@AcCode AS VARCHAR(50)),
					--						CAST(@TaxName + ' OutPut' AS VARCHAR(50)),4,1,0,1,1,GETDATE(),1,GETDATE()
											
					UPDATE Counters SET CurrValue = @OutPutTaxId WHERE TabName = 'CoaMaster' AND FldName = 'CoaId'
						--SELECT * FROM Counters WHERE TabName = 'CoaMaster' AND FldName = 'CoaId'
					SET @sStr = 'UPDATE Counters SET currvalue = currvalue+1
						WHERE Tabname = ''CoaMaster'' and fldname =  ''CoaId'''
	
					INSERT INTO Translog(strSql1) Values (@sstr)
				END

				SET @TaxId = dbo.Fn_GetPrimaryKeyInteger('TaxConfiguration','TaxId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
				IF @TaxId=0
				BEGIN
					SET @ErrDesc='Reset Counter Value'
					INSERT INTO Errorlog VALUES (1,@TabName,'Tax',@ErrDesc)
  					SET @Taction = 0
  					SET @Po_ErrNo=1
				END

				INSERT INTO TaxConfiguration (TaxId,TaxCode,TaxName,InputTaxId,OutPutTaxId,Availability,
				LastModBy,LastModDate,AuthId,AuthDate) VALUES (@TaxId,@TaxCode,@TaxName,
				@InputTaxId,@OutPutTaxId,1,1,GETDATE(),1,GETDATE())
			
		
				INSERT INTO Translog(strSql1) Values (@sstr)
								UPDATE Counters SET CurrValue = @TaxId WHERE TabName = 'TaxConfiguration' AND FldName = 'TaxId'
				SET @sStr = 'UPDATE Counters SET currvalue = currvalue+1
				WHERE Tabname = ''TaxConfiguration'' and fldname = ''TaxId'''
				INSERT INTO Translog(strSql1) Values (@sstr) 
			END			
		END
		FETCH NEXT FROM Cur_TaxConfig INTO @TaxCode,@TaxName
	END
	CLOSE Cur_TaxConfig
	DEALLOCATE Cur_TaxConfig

	SET @Po_ErrNo=0
	DECLARE Cur_TaxGroup CURSOR
	FOR SELECT DISTINCT ISNULL([TaxGroupCode],''),ISNULL([TaxGroupName],''),ISNULL([GroupType],'')	
	FROM ETL_Prk_TaxConfig_GroupSetting Where DownLoadFlag = 'D'
	OPEN Cur_TaxGroup
	FETCH NEXT FROM Cur_TaxGroup INTO @TaxGrpCode,@TaxGrpName,@GrpType
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Taction = 2
		IF ISNULL(@TaxGrpCode,'') = ''
		BEGIN
			SET @ErrDesc =  ' Tax Group Code '+ @TaxGrpCode + ' Not found '
			INSERT INTO Errorlog VALUES (1,@TabName,'Tax Group Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF ISNULL(@TaxGrpName,'') = ''
		BEGIN
			SET @ErrDesc = ' Tax Group Name '+ @TaxGrpName + ' Not found '
			INSERT INTO Errorlog VALUES (1,@TabName,'Tax Group Name',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF ISNULL(@GrpType,'') = ''
		BEGIN
			SET @ErrDesc = ' Tax Group Type '+ @GrpType + ' Not found '
			INSERT INTO Errorlog VALUES (1,@TabName,'Group Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF NOT (UPPER(@GrpType)='RETAILER' OR UPPER(@GrpType)='SUPPLIER' OR UPPER(@GrpType)='PRODUCT')
		BEGIN
			SET @ErrDesc = ' Tax Group Type '+ @GrpType + ' Should be "Retailer/Supplier/Product"'
			INSERT INTO Errorlog VALUES (1,@TabName,'Group Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF (UPPER(@GrpType))='RETAILER'
		BEGIN
			SET @GrpTypeId=1
		END
		ELSE IF (UPPER(@GrpType))='SUPPLIER'
		BEGIN
			SET @GrpTypeId=3
		END
		ELSE IF (UPPER(@GrpType))='PRODUCT'
		BEGIN
			SET @GrpTypeId=2
		END

		IF @GrpTypeId <> 2
		BEGIN
			IF EXISTS(SELECT * FROM TaxGroupSetting WHERE RtrGroup=@TaxGrpCode)
			BEGIN
				SET @Taction = 1
				SELECT @TaxGrpId=TaxGroupId FROM TaxGroupSetting WHERE RtrGroup=@TaxGrpCode
			END			
			ELSE
			BEGIN
				SET @Taction = 2
			END
		END

		ELSE IF @GrpTypeId = 2
		BEGIN
			IF EXISTS(SELECT * FROM TaxGroupSetting WHERE PrdGroup=@TaxGrpCode)
			BEGIN
				SET @Taction = 1
				SELECT @TaxGrpId=TaxGroupId FROM TaxGroupSetting WHERE PrdGroup=@TaxGrpCode
			END
			ELSE
			BEGIN
				SET @Taction = 2
			END
		END

		IF @Taction = 1
		BEGIN
			IF EXISTS(SELECT *  FROM TaxSettingMaster WHERE (RtrId =@TaxGrpId  or PrdId = @TaxGrpId))
			BEGIN
				IF @GrpTypeId <> 2
				BEGIN
					UPDATE TaxGroupSetting SET TaxGroupName=@TaxGrpName
					WHERE RtrGroup=@TaxGrpCode AND TaxGroupId=@TaxGrpId
				
							/* Update Retailer & Supplier Download Flag Panneer 08.09.2009 */
					Update ETL_Prk_TaxConfig_GroupSetting Set DownLoadFlag = 'Y'
							From ETL_Prk_TaxConfig_GroupSetting 
							Where  TaxGroupName = @TaxGrpName  
									and TaxGroupCode = @TaxGrpCode and GroupType = @GrpType
							/* Till Here  */
				END
				ELSE IF @GrpTypeId = 2
				BEGIN
					UPDATE TaxGroupSetting SET TaxGroupName=@TaxGrpName
					WHERE PrdGroup=@TaxGrpCode AND TaxGroupId=@TaxGrpId

							 /* Update Product Download Flag Panneer 08.09.2009 */
					Update ETL_Prk_TaxConfig_GroupSetting Set DownLoadFlag = 'Y'
							From ETL_Prk_TaxConfig_GroupSetting 
							Where  TaxGroupName = @TaxGrpName  
									and TaxGroupCode = @TaxGrpCode and GroupType = @GrpType
							/* Till Here  */
				END
			END
			ELSE
			BEGIN
				IF @GrpTypeId <> 2
				BEGIN

					UPDATE TaxGroupSetting SET TaxGroupName=@TaxGrpName,TaxGroup=@GrpTypeId
					WHERE RtrGroup=@TaxGrpCode AND TaxGroupId=@TaxGrpId

								 /* Update Retailer & Supplier Panneer 08.09.2009 */
					Update ETL_Prk_TaxConfig_GroupSetting Set DownLoadFlag = 'Y'
							From ETL_Prk_TaxConfig_GroupSetting 
							Where  TaxGroupName = @TaxGrpName  
									and TaxGroupCode = @TaxGrpCode and GroupType = @GrpType
								/* Till Here  */
				END
				ELSE IF @GrpTypeId = 2
				BEGIN
					UPDATE TaxGroupSetting SET TaxGroupName=@TaxGrpName,TaxGroup=@GrpTypeId
					WHERE PrdGroup=@TaxGrpCode AND TaxGroupId=@TaxGrpId

								/* Update Product DownLoad Flag Panneer 08.09.2009 */
					Update ETL_Prk_TaxConfig_GroupSetting Set DownLoadFlag = 'Y'
							From ETL_Prk_TaxConfig_GroupSetting 
							Where  TaxGroupName = @TaxGrpName  
									and TaxGroupCode = @TaxGrpCode and GroupType = @GrpType
								/* Till Here  */
				END
			END
		END

		ELSE IF @Taction = 2
		BEGIN

			SET @TaxGrpId = dbo.Fn_GetPrimaryKeyInteger('TaxGroupSetting','TaxGroupId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
			IF @GrpTypeId <> 2
			BEGIN
				INSERT INTO TaxGroupSetting (TaxGroupId,RtrGroup,PrdGroup,TaxGroupName,TaxGroup,Availability,
				LastModBy,LastModDate,AuthId,AuthDate) VALUES (@TaxGrpId,@TaxGrpCode,'',@TaxGrpName,@GrpTypeId,
				1,1,GETDATE(),1,GETDATE())
				
				IF @GrpTypeId = 1  /*Update Retailer DownLoad Flag Panneer 08.09.2009 */
				BEGIN

					Update ETL_Prk_TaxConfig_GroupSetting Set DownLoadFlag = 'Y'
							From ETL_Prk_TaxConfig_GroupSetting 
							Where GroupType = 'RETAILER' and TaxGroupName = @TaxGrpName  
									and TaxGroupCode = @TaxGrpCode and GroupType = @GrpType
				END

				IF @GrpTypeId = 3 /* Update Supplier DownLoad Flag Panneer 08.09.2009 */ 
				BEGIN
					Update ETL_Prk_TaxConfig_GroupSetting Set DownLoadFlag = 'Y'
							From ETL_Prk_TaxConfig_GroupSetting 
							Where GroupType = 'SUPPLIER' and TaxGroupName = @TaxGrpName 
										and TaxGroupCode = @TaxGrpCode and GroupType = @GrpType
				END

			END
			ELSE IF @GrpTypeId = 2
			BEGIN
				INSERT INTO TaxGroupSetting (TaxGroupId,RtrGroup,PrdGroup,TaxGroupName,TaxGroup,Availability,
				LastModBy,LastModDate,AuthId,AuthDate) VALUES (@TaxGrpId,'',@TaxGrpCode,@TaxGrpName,@GrpTypeId,
				1,1,GETDATE(),1,GETDATE())	
			
								/* Update Product DownLoad Flag  Panneer 08.09.2009 */
				Update ETL_Prk_TaxConfig_GroupSetting Set DownLoadFlag = 'Y'
							From ETL_Prk_TaxConfig_GroupSetting
							Where GroupType = 'Product' and TaxGroupName = @TaxGrpName 
										and TaxGroupCode = @TaxGrpCode and GroupType = @GrpType					 
			END

			UPDATE Counters SET CurrValue = @TaxGrpId WHERE TabName = 'TaxGroupSetting' AND FldName = 'TaxGroupId'
			SET @sStr = 'UPDATE Counters SET currvalue = currvalue+1 WHERE Tabname = ''TaxGroupSetting'' and fldname =''TaxGroupId'''
			INSERT INTO Translog(strSql1) Values (@sstr)
		END
		FETCH NEXT FROM Cur_TaxGroup INTO @TaxGrpCode,@TaxGrpName,@GrpType
	END
	CLOSE Cur_TaxGroup
	DEALLOCATE Cur_TaxGroup

	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_TaxSetting' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_TaxSetting
GO
/*
BEGIN TRANSACTION
EXEC Proc_CN2CS_TaxSetting 0
SELECT * FROM ErrorLog
SELECT * FROM TaxSettingMaster
SELECT * FROM TaxSettingDetail
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
			CDDiscount		NVARCHAR(200)
		)
		DELETE FROM @TaxSettingTable
		INSERT INTO @TaxSettingTable
		SELECT DISTINCT TC.TaxId, ISNULL(ETL1.TaxGroupCode,''),ISNULL(ETL1.Type,''),
		ISNULL(ETL1.PrdTaxGroupCode,''),ISNULL(TC.TaxCode,''),ISNULL(ETL1.Percentage,0),
		ISNULL(ETL1.ApplyOn,'None'),ISNULL(ETL1.Discount,'None'),ISNULL(ETL1.SchDiscount,'None'),
		ISNULL(ETL1.DBDiscount,'None'),ISNULL(ETL1.CDDiscount,'None') 
		FROM
		(SELECT ISNULL(ETL.TaxGroupCode,'') AS TaxGroupCode,ISNULL(ETL.Type,'') AS Type,ISNULL(ETL.TaxCode,'') AS TaxCode,
		ISNULL(ETL.PrdTaxGroupCode,'') AS PrdTaxGroupCode,
		ISNULL(ETL.Percentage,0) AS Percentage,ISNULL(ETL.ApplyOn,'') AS ApplyOn,ISNULL(ETL.Discount,'') AS Discount,
		ISNULL(ETL.SchDiscount,'') AS SchDiscount,ISNULL(ETL.DBDiscount,'') AS DBDiscount,ISNULL(ETL.CDDiscount,'') AS CDDiscount
		FROM Etl_Prk_TaxSetting ETL
		WHERE DownloadFlag='D' AND TaxGroupCode=@TaxGroupCode AND PrdTaxGroupCode=@PrdTaxGroupCode) ETL1
		RIGHT OUTER JOIN TaxConfiguration TC ON TC.TaxCode=ETL1.TaxCode
		SET @RowId=0
		DECLARE Cur_TaxSettingDetail CURSOR		--TaxSettingDetail Cursor
		FOR SELECT TaxGrpCode,Type,TaxPrdGrpCode,TaxCode,Percentage,Applyon,Discount,SchDiscount,DBDiscount,CDDiscount
		FROM @TaxSettingTable Order By TaxId
		OPEN Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount,
		@SchDiscount,@DBDiscount,@CDDiscount
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
					END	
					ELSE IF @FieldDesc='Sch Disc' 
					BEGIN
						IF @SchDiscount='ADD'
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
						IF @DBDiscount='ADD'
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
						IF @CDDiscount='ADD'
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
					END	
					--->Till Here
				END
				ELSE IF UPPER(@Type)='SUPPLIER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(PurSeqId) FROM dbo.PurchaseSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.PurchaseSequenceDetail WHERE PurSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2
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
			@SchDiscount,@DBDiscount,@CDDiscount
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLProductHiereachyChange' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLProductHiereachyChange
GO
/*
BEGIN TRANSACTION
--SELECT * FROM ETL_Prk_ProductHierarchyLevelvalue
--SELECT * FROM Product
--SELECT * FROM ProductCategoryValue
--SELECT * FROM Cn2Cs_Prk_BLProductHiereachyChange
EXEC Proc_Cn2Cs_BLProductHiereachyChange 0
--SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROC Proc_Cn2Cs_BLProductHiereachyChange
(
       @Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE: Proc_Cn2Cs_BLProductHiereachyChange
* PURPOSE: To Insert the records From Console into ETL_Prk_Product,ETL_Prk_ProductHierarchyLevelvalue
* SCREEN : Console Integration-Product Hierarchy Change Download
* CREATED: Nandakumar R.G on 05-09-2009
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN

	DECLARE @CmpCode nVarChar(50)
	DECLARE @SpmCode nVarChar(50)
	DECLARE @ErrStatus INT

	DECLARE @DistCode		NVARCHAR(100)
	DECLARE @BusinessCode	NVARCHAR(100)
	DECLARE @BusinessName	NVARCHAR(100)
	DECLARE @CategoryCode	NVARCHAR(100)
	DECLARE @CategoryName	NVARCHAR(100)
	DECLARE @FamilyCode		NVARCHAR(100)
	DECLARE @FamilyName		NVARCHAR(100)
	DECLARE @GroupCode		NVARCHAR(100)
	DECLARE @GroupName		NVARCHAR(100)
	DECLARE @SubGroupCode	NVARCHAR(100)
	DECLARE @SubGroupName	NVARCHAR(100)
	DECLARE @BrandCode		NVARCHAR(100)
	DECLARE @BrandName		NVARCHAR(100)
	DECLARE @PrdCCode		NVARCHAR(100)
	DECLARE @PrdName		NVARCHAR(100)

	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany = 1

	TRUNCATE TABLE ETL_Prk_ProductHierarchyLevelvalue

	--For New Hierarchy
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Business',@CmpCode,BusinessCode,BusinessName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND BusinessCode<>'---' 
	AND BusinessCode NOT IN(SELECT PrdCtgValCode FROM ProductCategoryValue WHERE LEN(PrdCtgValLinkCode)=6) 
	
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Category',BusinessCode,CategoryCode,CategoryName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND CategoryCode<>'---' 
	AND CategoryCode NOT IN(SELECT PrdCtgValCode FROM ProductCategoryValue WHERE LEN(PrdCtgValLinkCode)=9)	

	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Family',CategoryCode,FamilyCode,FamilyName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND FamilyCode<>'---' 
	AND CategoryCode NOT IN(SELECT PrdCtgValCode FROM ProductCategoryValue WHERE LEN(PrdCtgValLinkCode)=12)

	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Group',FamilyCode,GroupCode,GroupName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND GroupCode<>'---' 
	AND CategoryCode NOT IN(SELECT PrdCtgValCode FROM ProductCategoryValue WHERE LEN(PrdCtgValLinkCode)=15)

	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'SubGroup',GroupCode,SubGroupCode,SubGroupName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND SubGroupCode<>'---' 
	AND CategoryCode NOT IN(SELECT PrdCtgValCode FROM ProductCategoryValue WHERE LEN(PrdCtgValLinkCode)=18)	

	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Brand',SubGroupCode,BrandCode,BrandName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND BrandCode<>'---' 
	AND CategoryCode NOT IN(SELECT PrdCtgValCode FROM ProductCategoryValue WHERE LEN(PrdCtgValLinkCode)=21)
	
--	SELECT * FROM ETL_Prk_ProductHierarchyLevelvalue

	--For Hierarchy Change from existing one
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Business',@CmpCode,BusinessCode,BusinessName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND CategoryCode='---' 
	AND BusinessCode<>'---'		

	UPDATE ProductCategoryValue SET PrdCtgValCode='OldHier-'+PrdCtgValCode
	WHERE PrdCtgValCode IN (SELECT BusinessCode FROM Cn2Cs_Prk_BLProductHiereachyChange 
	WHERE DownLoadFlag='D' AND CategoryCode='---')	

	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Category',BusinessCode,CategoryCode,CategoryName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND FamilyCode='---' 
	AND CategoryCode<>'---'
	
	UPDATE ProductCategoryValue SET PrdCtgValCode='OldHier-'+PrdCtgValCode
	WHERE PrdCtgValCode IN (SELECT CategoryCode FROM Cn2Cs_Prk_BLProductHiereachyChange 
	WHERE DownLoadFlag='D' AND FamilyCode='---')
	
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Family',CategoryCode,FamilyCode,FamilyName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND GroupCode='---' 
	AND FamilyCode<>'---'
	

	UPDATE ProductCategoryValue SET PrdCtgValCode='OldHier-'+PrdCtgValCode
	WHERE PrdCtgValCode IN (SELECT FamilyCode FROM Cn2Cs_Prk_BLProductHiereachyChange 
	WHERE DownLoadFlag='D' AND GroupCode='---')
	
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Group',FamilyCode,GroupCode,GroupName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND SubGroupCode='---' 	
	AND GroupCode<>'---'

	UPDATE ProductCategoryValue SET PrdCtgValCode='OldHier-'+PrdCtgValCode
	WHERE PrdCtgValCode IN (SELECT GroupCode FROM Cn2Cs_Prk_BLProductHiereachyChange 
	WHERE DownLoadFlag='D' AND SubGroupCode='---')

	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'SubGroup',GroupCode,SubGroupCode,SubGroupName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND BrandCode='---' 	
	AND SubGroupCode<>'---'

	UPDATE ProductCategoryValue SET PrdCtgValCode='OldHier-'+PrdCtgValCode
	WHERE PrdCtgValCode IN (SELECT SubGroupCode FROM Cn2Cs_Prk_BLProductHiereachyChange 
	WHERE DownLoadFlag='D' AND BrandCode='---')

	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT 'Brand',SubGroupCode,BrandCode,BrandName,@CmpCode
	FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag='D' AND PrdCCode='---'
	AND BrandCode<>'---'

	UPDATE ProductCategoryValue SET PrdCtgValCode='OldHier-'+PrdCtgValCode
	WHERE PrdCtgValCode IN (SELECT BrandCode FROM Cn2Cs_Prk_BLProductHiereachyChange 
	WHERE DownLoadFlag='D' AND PrdCCode='---')

--	SELECT * FROM ETL_Prk_ProductHierarchyLevelvalue

	EXEC Proc_ValidateProductHierarchyLevelValue @Po_ErrNo= @ErrStatus OUTPUT
	IF @ErrStatus =0
	BEGIN

		IF EXISTS(SELECT PrdCtgValLinkCode+'%' FROM ProductCategoryValue 
		WHERE PrdCtgValCode LIKE 'OldHier-%')
		BEGIN
			UPDATE ProductCategoryValue SET PrdCtgValLinkCode='OH-'+PrdCtgValLinkCode
			WHERE PrdCtgValLinkCode LIKE (SELECT PrdCtgValLinkCode+'%' FROM ProductCategoryValue 
			WHERE PrdCtgValCode LIKE 'OldHier-%')

			SELECT ProductCategoryValue.PrdCtgValLinkCode AS NewLinkCode,NPCV.PrdCtgValLinkCode OldLinkCode
			INTO PrdHierChanges FROM  ProductCategoryValue ,ProductCategoryValue NPCV WHERE 
			('OldHier-'+ProductCategoryValue.PrdCtgValCode)=NPCV.PrdCtgValCode --AND 'OldHier-'+ProductCategoryValue.PrdCtgValCode

			UPDATE ProductCategoryValue SET ProductCategoryValue.PrdCtgValLinkCode=REPLACE(ProductCategoryValue.PrdCtgValLinkCode,OldLinkCode,NewLinkCode)
			FROM PrdHierChanges WHERE ProductCategoryValue.PrdCtgValLinkCode LIKE PrdHierChanges.OldLinkCode+'%'

			DELETE FROM ProductCategoryValue WHERE PrdCtgValCode LIKE 'OldHier-%'
		END

		UPDATE Product SET Product.PrdCtgValMainId=PCV.PrdCtgValMainId 
		FROM Cn2Cs_Prk_BLProductHiereachyChange C,ProductCategoryValue PCV
		WHERE C.PrdCCode<>'---' AND PCV.PrdCtgValCode=C.BrandCode AND Product.PrdCCode=C.PrdCCode
		AND C.DownloadFlag='D'

		UPDATE Cn2Cs_Prk_BLProductHiereachyChange SET DownLoadFlag='Y'
	END

	SET @Po_ErrNo= @ErrStatus
	RETURN	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateProductHierarchyLevelValue' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateProductHierarchyLevelValue
GO
/*
BEGIN TRANSACTION
--SELECT * FROM ETL_Prk_ProductHierarchyLevelValue
--SELECT * FROM ProductCategoryValue
--SELECT * FROM ProductCategoryLevel
EXEC Proc_ValidateProductHierarchyLevelValue 0
SELECT * FROM ErrorLog
--SELECT * FROM ProductCategoryValue WHERE PrdCtgValCode='CA060-2828'
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_ValidateProductHierarchyLevelValue
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ValidateProductHierarchyLevelValue
* PURPOSE		: To Insert and Update records in the Table ProductCategoryValue
* CREATED		: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 2010/05/16	Nanda		 Link Code Change from 3 digit to 5 digit			
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 		AS 	INT
	DECLARE @Tabname 	AS     	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	
	DECLARE @PrdHierLevelCode 	AS  NVARCHAR(100)
	DECLARE @ParentHierLevelCode 	AS  NVARCHAR(100)
	DECLARE @PrdHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @PrdHierLevelValueName 	AS  NVARCHAR(100)
	DECLARE @LevelName 	AS  	NVARCHAR(100)
	DECLARE @ParentLinkCode AS 	NVARCHAR(100)
	DECLARE @NewLinkCode 	AS 	NVARCHAR(100)
	DECLARE @CompanyCode 	AS 	NVARCHAR(100)
	
	DECLARE @Index 		AS 	INT
	DECLARE @CmpId		AS 	INT
	DECLARE @CmpPrdCtgId 	AS 	INT
	DECLARE @PrdCtgMainId 	AS 	INT
	DECLARE @PrdCtgLinkId 	AS 	INT
	DECLARE @PrdCtgLinkCode AS 	NVARCHAR(100)
	DECLARE @TransStr 	AS 	NVARCHAR(4000)
	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='ProductCategoryValue'
	SET @Fldname='PrdCtgValMainId'
	SET @Tabname = 'ETL_Prk_ProductHierarchyLevelValue'
	SET @Exist=0
	
	DECLARE Cur_ProductHierarchyLevelValue CURSOR
	FOR SELECT ISNULL([Product Hierarchy Level Code],''),ISNULL([Parent Hierarchy Level Value Code],''),
	ISNULL([Product Hierarchy Level Value Code],''),ISNULL([Product Hierarchy Level Value Name],'')
	,ISNULL([Company code],'')
	FROM ETL_Prk_ProductHierarchyLevelValue INNER JOIN ProductCategoryLevel ON
	CmpPrdCtgName = [Product Hierarchy Level Code] ORDER BY LevelName
	OPEN Cur_ProductHierarchyLevelValue
	FETCH NEXT FROM Cur_ProductHierarchyLevelValue INTO @PrdHierLevelCode,@ParentHierLevelCode,
	@PrdHierLevelValueCode,@PrdHierLevelValueName,@CompanyCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0
		
		IF NOT EXISTS(SELECT * FROM Company WITH (NOLOCK) WHERE CmpCode=@CompanyCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Company',
			'Company Code:'+@CompanyCode+' is not available')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			
		SELECT @CmpId=CmpId FROM Company WITH (NOLOCK)
			WHERE CmpCode=@CompanyCode
		END
		IF NOT EXISTS(SELECT * FROM ProductCategoryLevel WITH (NOLOCK) WHERE CmpPrdCtgName=@PrdHierLevelCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Product Category Level',
			'Product Category Level:'+@PrdHierLevelCode+' is not available')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			
		SELECT @CmpPrdCtgId=CmpPrdCtgId,@LevelName=LevelName FROM ProductCategoryLevel WITH (NOLOCK)
			WHERE CmpPrdCtgName=@PrdHierLevelCode AND CmpId=@CmpId
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK)
			WHERE PrdCtgValCode=@ParentHierLevelCode)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Parent Category Level',
				'Parent Category Level:'+@ParentHierLevelCode+' is not available')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdCtgLinkId=ISNULL(PrdCtgValMainId,0) FROM ProductCategoryValue WITH (NOLOCK)
				WHERE PrdCtgValCode=@ParentHierLevelCode
			END
		END	
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@PrdHierLevelValueCode))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarvhy Level Value Code',
				'Product Hierarvhy Level Value Code should not be empty')
				SET @Po_ErrNo=1
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@PrdHierLevelValueName))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarvhy Level Value Name',
				'Product Hierarvhy Level Value Name should not be empty')
				SET @Po_ErrNo=1
			END
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK)
			WHERE PrdCtgValCode=@PrdHierLevelValueCode)
			BEGIN
				SET @Exist=1
			END
		
			IF @Exist=0
			BEGIN
				SELECT @PrdCtgMainId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
				SELECT 	@ParentLinkCode=PrdCtgValLinkCode FROM ProductCategoryValue
				WHERE PrdCtgValMainId=@PrdCtgLinkId
	
				SELECT @NewLinkCode=ISNULL(MAX(PrdCtgValLinkCode),0)
				FROM ProductCategoryValue WHERE LEN(PrdCtgValLinkCode)=  Len(@ParentLinkCode)+5
				AND PrdCtgValLinkCode LIKE  @ParentLinkCode +'%' AND CmpPrdCtgId =@CmpPrdCtgId

				SELECT 	@PrdCtgLinkCode=dbo.Fn_ReturnNewCode(@ParentLinkCode,5,@NewLinkCode)
	
				
				IF LEN(@PrdCtgLinkCode)<>(SUBSTRING(@LevelName,6,LEN(@LevelName)))*5
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarvhy Level Value',
					'Product Hierarvhy Level is not match with parent level for: '+@PrdHierLevelValueCode)
	
					SET @Po_ErrNo=1
				END
				
				IF @Po_ErrNo=0
				BEGIN
					INSERT INTO ProductCategoryValue
					(PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES	(@PrdCtgMainId,
					@PrdCtgLinkId,@CmpPrdCtgId,@PrdCtgLinkCode,@PrdHierLevelValueCode,@PrdHierLevelValueName,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
				
	
					SET @TransStr='INSERT INTO ProductCategoryValue
					(PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES	('+
					CAST(@PrdCtgMainId AS NVARCHAR(10))+','+CAST(@PrdCtgLinkId AS NVARCHAR(10))+','+
					CAST(@CmpPrdCtgId AS NVARCHAR(10))+','''+@PrdCtgLinkCode+''','''+@PrdHierLevelValueCode+
					''','''+@PrdHierLevelValueName+''',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+
					''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
	
					UPDATE Counters SET CurrValue=@PrdCtgMainId WHERE TabName=@DestTabname AND FldName=@FldName
					SET @PrdCtgLinkCode=''
	
					SET @TransStr='UPDATE Counters SET CurrValue='+
					CAST(@PrdCtgMainId AS NVARCHAR(10))+' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
				END
			END	
			ELSE
			BEGIN
				UPDATE ProductCategoryValue SET PrdCtgValName=@PrdHierLevelValueName
				WHERE PrdCtgValCode=@PrdHierLevelValueCode
				SET @TransStr='UPDATE ProductCategoryValue SET PrdCtgValName='''+@PrdHierLevelValueName+
				''' WHERE PrdCtgValCode='''+@PrdHierLevelValueCode+''''
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
			END	
		END

		FETCH NEXT FROM Cur_ProductHierarchyLevelValue INTO @PrdHierLevelCode,@ParentHierLevelCode,
		@PrdHierLevelValueCode,@PrdHierLevelValueName,@CompanyCode
	END
	CLOSE Cur_ProductHierarchyLevelValue
	DEALLOCATE Cur_ProductHierarchyLevelValue
	SET @Po_ErrNo=0
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_Product' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_Product
GO
--select * from Cn2Cs_Prk_Product
--EXEC Proc_Cn2Cs_Product 0
CREATE PROCEDURE Proc_Cn2Cs_Product  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
/*********************************  
* PROCEDURE  : Proc_Cn2Cs_Product  
* PURPOSE  : To validate the downloaded Products   
* CREATED BY : Nandakumar R.G  
* CREATED DATE : 03/04/2010  
* NOTE   :   
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @CmpCode nVarChar(50)  
 DECLARE @SpmCode nVarChar(50)  
 DECLARE @PrdUpc  INT    
 DECLARE @ErrStatus INT  
 TRUNCATE TABLE ETL_Prk_ProductHierarchyLevelvalue  
 TRUNCATE TABLE ETL_Prk_Product  
 DELETE FROM Cn2Cs_Prk_Product WHERE DownLoadFlag='Y'  
 SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany = 1  
 SELECT @SpmCode=S.SpmCode FROM Supplier S,Company C  
 WHERE C.CmpId=S.CmpId AND S.SpmDefault = 1 AND C.DefaultCompany = 1  
 --TO INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
--SELECT * FROM ETL_Prk_ProductHierarchyLevelvalue
--select * from productcategorylevel
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Category',@CmpCode,BusinessCode,BusinessName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Taste',BusinessCode,CategoryCode,CategoryName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Brand',CategoryCode,FamilyCode,FamilyName,@CmpCode
  FROM Cn2Cs_Prk_Product
 INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Pack',FamilyCode,GroupCode,GroupName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
 INSERT INTO ETL_Prk_Product  
 ([Product Distributor Code],[Product Name],[Product Short Name],[Product Company Code],  
 [Product Hierarchy Level Value Code],[Supplier Code],[Stock Cover Days],  
 [Unit Per SKU],[Tax Group Code],[Weight],[Unit Code],[UOM Group Code],  
 [Product Type],[Effective From Date],[Effective To Date],[Shelf Life],[Status],[EAN Code],[Vending])  
 SELECT DISTINCT C.PrdCCode,C.PrdName,left(C.PrdName,20) AS ProductShortName,  
 C.PrdCCode,C.GroupCode,@SpmCode,0,1,'',C.PrdWgt,ISNULL(C.ProductUnit,'Unit'),C.UOMGroupCode,  
 C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,C.ProductStatus,  
 C.[EANCode],C.Vending
 FROM Cn2Cs_Prk_Product C  
 EXEC Proc_ValidateProductHierarchyLevelValue @Po_ErrNo= @ErrStatus OUTPUT  
 IF @ErrStatus =0  
 BEGIN     
  EXEC Proc_Validate_Product @Po_ErrNo= @ErrStatus OUTPUT  
  IF @ErrStatus =0  
  BEGIN   
   UPDATE A SET DownLoadFlag='Y' FROM Product P INNER JOIN Cn2Cs_Prk_Product A ON A.PrdCCode=P.PrdCCode       
  END  
 END  
 SET @Po_ErrNo= @ErrStatus  
 RETURN  
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Validate_Product' AND XTYPE='P')
DROP PROCEDURE Proc_Validate_Product
GO
--EXEC Proc_Validate_Product 0
CREATE PROCEDURE Proc_Validate_Product
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_Product
* PURPOSE		: To Insert and Update records in the Table Product
* CREATED		: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist     AS  INT
	DECLARE @Tabname    AS  NVARCHAR(100)
	DECLARE @DestTabname   AS  NVARCHAR(100)
	DECLARE @Fldname    AS  NVARCHAR(100)
	DECLARE @PrdDCode    AS NVARCHAR(100)
	DECLARE @PrdName   AS NVARCHAR(100)
	DECLARE @PrdShortName  AS NVARCHAR(100)
	DECLARE @PrdCCode   AS NVARCHAR(100)
	DECLARE @PrdCtgValCode  AS NVARCHAR(100)
	DECLARE @StkCoverDays  AS NVARCHAR(100)
	DECLARE @UnitPerSKU   AS NVARCHAR(100)
	DECLARE @TaxGroupCode  AS NVARCHAR(100)
	DECLARE @Weight    AS NVARCHAR(100)
	DECLARE @UnitCode   AS NVARCHAR(100)
	DECLARE @UOMGroupCode  AS NVARCHAR(100)
	DECLARE @PrdType   AS NVARCHAR(100)
	DECLARE @EffectiveFromDate AS NVARCHAR(100)
	DECLARE @EffectiveToDate AS NVARCHAR(100)
	DECLARE @ShelfLife   AS NVARCHAR(100)
	DECLARE @Status    AS NVARCHAR(100)
	DECLARE @Vending   AS NVARCHAR(100)
	DECLARE @PrdVending   AS INT
	DECLARE @EANCode  AS NVARCHAR(100)
	DECLARE @CmpId   AS  INT
	DECLARE @PrdId   AS  INT
	DECLARE @CmpPrdCtgId  AS  INT
	DECLARE @PrdCtgMainId  AS  INT
	DECLARE @SpmId   AS  INT
	DECLARE @PrdUnitId AS  INT
	DECLARE @TaxGroupId AS  INT
	DECLARE @UOMGroupId AS  INT
	DECLARE @PrdTypeId AS  INT
	DECLARE @PrdStatus AS  INT
	SET @Po_ErrNo=0
	SET @Exist=0
	SET @DestTabname='Product'
	SET @Fldname='PrdId'
	SET @Tabname = 'ETL_Prk_Product'
	SET @Exist=0
	SELECT @SpmId=SpmId FROM Supplier WITH (NOLOCK) WHERE SpmDefault=1
	DECLARE Cur_Product CURSOR
	FOR SELECT ISNULL([Product Distributor Code],''),ISNULL([Product Name],''),ISNULL([Product Short Name],''),ISNULL([Product Company Code],''),
	ISNULL([Product Hierarchy Level Value Code],''),ISNULL([Stock Cover Days],0),ISNULL([Unit Per SKU],1),
	ISNULL([Tax Group Code],''),ISNULL([Weight],0),[Unit Code],[UOM Group Code],[Product Type],CONVERT(NVARCHAR(12),[Effective From Date],121),
	CONVERT(NVARCHAR(12),[Effective To Date],121),ISNULL([Shelf Life],0),ISNULL([Status],'ACTIVE'),ISNULL([EAN Code],''),ISNULL([Vending],'NO')
	FROM ETL_Prk_Product
	OPEN Cur_Product
	FETCH NEXT FROM Cur_Product INTO @PrdDCode,@PrdName,@PrdShortName,@PrdCCode,@PrdCtgValCode,
	@StkCoverDays,@UnitPerSKU,@TaxGroupCode,@Weight,@UnitCode,@UOMGroupCode,@PrdType,@EffectiveFromDate,
	@EffectiveToDate,@ShelfLife,@Status,@EANCode,@Vending
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @Exist=0
		IF NOT EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK) WHERE PrdCtgValCode=@PrdCtgValCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Category Level',
			'Product Category Level:'+@PrdCtgValCode+' is not available for the Product Code: '+@PrdDCode)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CmpId=PCL.CmpId FROM ProductCategoryLevel PCL WITH (NOLOCK),
			ProductCategoryValue PCV WITH (NOLOCK)
			WHERE PCV.PrdCtgValCode=@PrdCtgValCode AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId
			IF(SELECT ISNULL(PC.LevelName,'') FROM ProductCategoryValue PCV
			WITH (NOLOCK),ProductCategoryLevel PC WITH (NOLOCK)
			WHERE PCV.PrdCtgValCode=@PrdCtgValCode AND PC.CmpPrdCtgId=PCV.CmpPrdCtgId)<>
			(SELECT TOP 1 PC.LevelName FROM ProductCategoryLevel PC
			WHERE CmpId=@CmpId AND CmpPrdCtgId NOT IN (SELECT MAX(CmpPrdCtgId) FROM  ProductCategoryLevel PC WHERE CmpId=@CmpId)
			ORDER BY PC.CmpPrdCtgId DESC)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Category Level',
				'Product Category Level:'+@PrdCtgValCode+' is not last level in the hierarchy')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdCtgMainId=PrdCtgValMainId FROM ProductCategoryValue WITH (NOLOCK)
				WHERE PrdCtgValCode=@PrdCtgValCode
			END
		END
	
--		IF @Po_ErrNo=0
--		BEGIN
--			IF @TaxGroupCode<>''
--			BEGIN
--				IF NOT EXISTS(SELECT * FROM TaxGroupSetting WITH (NOLOCK)
--				WHERE PrdGroup=@TaxGroupCode)
--				BEGIN
--					INSERT INTO Errorlog VALUES (1,@TabName,'Tax Group',
--					'Tax Group:'+@TaxGroupCode+' is not available for the Product Code: '+@PrdDCode)
--					SET @Po_ErrNo=1
--				END
--				ELSE
--				BEGIN
--					SELECT @TaxGroupId=TaxGroupId FROM TaxGroupSetting WITH (NOLOCK)
--					WHERE PrdGroup=@TaxGroupCode
--				END
--			END
--			ELSE
--			BEGIN
				SET @TaxGroupId=0
--			END
--		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM UOMGroup WITH (NOLOCK) WHERE UOMGroupCode=@UOMGroupCode)
				BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'UOM Group',
				'UOM Group:'+@UOMGroupCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @UOMGroupId=UOMGroupId FROM UOMGroup WITH (NOLOCK) WHERE UOMGroupCode=@UOMGroupCode
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @PrdType='Normal'
			BEGIN
				SET @PrdTypeId=1
			END
			ELSE IF @PrdType='Pesticide'
			BEGIN
				SET @PrdTypeId=2
			END
			ELSE IF @PrdType='Kit Product'
			BEGIN
				SET @PrdTypeId=3
			END
			ELSE IF @PrdType='Gift'
			BEGIN
				SET @PrdTypeId=4
			END
			ELSE IF @PrdType='Drug'
			BEGIN
				SET @PrdTypeId=5
			END
			ELSE IF @PrdType='Food'
			BEGIN
				SET @PrdTypeId=6
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Type',
				'Product Type'+@PrdType+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @PrdTypeId=3 OR @PrdTypeId=5
			BEGIN
				IF ISDATE(@EffectiveFromDate)=1 AND ISDATE(@EffectiveToDate)=1
				BEGIN
					IF DATEDIFF(DD,@EffectiveFromDate,@EffectiveToDate)<0 OR DATEDIFF(DD,GETDATE(),@EffectiveToDate)<0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Effective From Date:' + @EffectiveFromDate + 'should be less than Effective To Date:' +@EffectiveToDate +' for the Product Code: '+@PrdDCode)
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Date',
					'Effective From or To Date is wrong for the Product Code: '+@PrdDCode)
					SET @Po_ErrNo=1
				END
			END
			ELSE
			BEGIN
				IF NOT ISDATE(@EffectiveFromDate)=1
				BEGIN
					SET @EffectiveFromDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				END
	
				IF NOT ISDATE(@EffectiveFromDate)=1
				BEGIN
					SET @EffectiveToDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				END
			END
		END
	
		IF @PrdTypeId=3
		BEGIN
			SET @EffectiveToDate=DATEADD(yy,3,@EffectiveFromDate)
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM ProductUnit WITH (NOLOCK)
			WHERE PrdUnitCode=@UnitCode)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Unit',
				'Product Unit'+@UnitCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdUnitId=PrdUnitId FROM ProductUnit WITH (NOLOCK)
				WHERE PrdUnitCode=@UnitCode
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(@Status)='ACTIVE' OR @Status='1'
			BEGIN
				SET @PrdStatus=1
			END
			ELSE
			BEGIN
			   SET @PrdStatus=2
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(@Vending)='YES'
			BEGIN
				SET @PrdVending=1
			END
			ELSE IF UPPER(@Vending)='NO'
			BEGIN
				SET @PrdVending=0
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode)
			BEGIN
				SET @Exist=0
			END
			ELSE
			BEGIN
				SET @Exist=1
				SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				SELECT @PrdId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
				
				IF @PrdId>(SELECT ISNULL(MAX(PrdId),0) FROM Product(NOLOCK))
				BEGIN
					INSERT INTO Product(PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,
					PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,
					CmpId,PrdCtgValMainId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
					IMEIEnabled,IMEILength,EANCode,Vending,XmlUpload)
					VALUES(@PrdId,@PrdName,@PrdShortName,@PrdDCode,@PrdCCode,@SpmId,@StkCoverDays,@UnitPerSKU,@Weight,
					@PrdUnitId,@UOMGroupId,@TaxGroupId,@PrdTypeId,@EffectiveFromDate,@EffectiveToDate,@ShelfLife,
					@PrdStatus,@CmpId,@PrdCtgMainId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),
					GETDATE(),121),0,0,@EANCode,ISNULL(@PrdVending,0),0)
					UPDATE Counters SET CurrValue=@PrdId WHERE TabName=@DestTabname AND FldName=@FldName
				END
				ELSE
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'System Date',
					'System is showing Date as :'+GETDATE()+'. Please change the System Date/Reset the Counters')
					SET @Po_ErrNo=1
				END
			END
			ELSE
			BEGIN
				EXEC Proc_DependencyCheck 'Product',@PrdId
				IF (SELECT COUNT(*) FROM TempDepCheck)>0
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,PrdShelfLife=@ShelfLife,
					PrdStatus=@PrdStatus,EanCode=@EANCode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
				END
				ELSE
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					UOMGroupId=@UOMGroupId,PrdType=@PrdTypeId,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,
					PrdShelfLife=@ShelfLife,PrdStatus=@PrdStatus,EanCode=@EANcode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
				END
			END
		END
	
		FETCH NEXT FROM Cur_Product INTO @PrdDCode,@PrdName,@PrdShortName,@PrdCCode,@PrdCtgValCode,
		@StkCoverDays,@UnitPerSKU,@TaxGroupCode,@Weight,@UnitCode,@UOMGroupCode,@PrdType,@EffectiveFromDate,
		@EffectiveToDate,@ShelfLife,@Status,@EANCode,@Vending
	END
	CLOSE Cur_Product
	DEALLOCATE Cur_Product
	SET @Po_ErrNo=0
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_DependencyCheck' AND XTYPE='P')
DROP PROCEDURE Proc_DependencyCheck
GO
--EXEC Proc_DependencyCheck 'FocusBrandHd',FBM0700003Proc_VoucherPostingDebitNote
CREATE PROCEDURE Proc_DependencyCheck
(
@Pi_TableName AS VARCHAR(30),
@Pi_Code AS VARCHAR(20)
)
AS
/*********************************
* PROCEDURE: Proc_DependencyCheck
* PURPOSE: To Delete the record
* CREATED: Deepa 19/01/06
* NOTE: General SP for all the Dependency Check
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[TempDepCheck]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [TempDepCheck]
	CREATE TABLE TempDepCheck
	(
		RecordId VARCHAR(50),
		RelatedTable Varchar(50)
	)

	DECLARE @Str AS VARCHAR(500)
	DECLARE @RelatedTable AS VARCHAR(100)
	DECLARE @FieldName AS VARCHAR(100)	
	DECLARE Cur_Dependency CURSOR FOR

	SELECT  RelatedTable,FieldName FROM DependencyTable WHERE PrimaryTable=@Pi_TableName
	OPEN Cur_Dependency
	FETCH NEXT FROM Cur_Dependency into @RelatedTable,@FieldName
	WHILE @@FETCH_STATUS=0
	BEGIN	
		SET @Str = 'INSERT INTO TempDepCheck '
		SET @Str= @Str + 'SELECT  DISTINCT '+ @FieldName
		SET @Str= @Str + ', '''+@RelatedTable+''' '
		SET @Str= @Str + ' FROM '+ @RelatedTable
		SET @Str= @Str + ' WHERE ' + @FieldName + '= ''' + CAST(@Pi_Code AS VARCHAR)
		SET @Str= @Str + ''' AND Availability = 1' 	
		EXEC(@Str)
		FETCH NEXT FROM Cur_Dependency INTO @RelatedTable,@FieldName
	END
	
	CLOSE Cur_Dependency
	DEALLOCATE Cur_Dependency
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ProductBatch' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ProductBatch
GO
--EXEC Proc_Cn2Cs_ProductBatch 0
CREATE PROCEDURE Proc_Cn2Cs_ProductBatch
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
    DECLARE @Po_BatchTransfer	AS  INT
    DECLARE @BatchTransfer		AS  INT
    DECLARE @Tabname 			AS  NVARCHAR(100)
	DECLARE @Exist 				AS  INT
	DECLARE @PrdCCode 	        AS 	NVARCHAR(100)
	DECLARE @BatchCode			AS 	NVARCHAR(100)
	DECLARE @PriceCode			AS 	NVARCHAR(4000)		
	DECLARE @MnfDate			AS 	NVARCHAR(100)
	DECLARE @ExpDate			AS 	NVARCHAR(100)
	DECLARE	@BatchSeqCode 		AS 	NVARCHAR(100)
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
	DECLARE @NoOfPrices 		AS 	INT
	DECLARE @ExistPrices 		AS 	INT
	DECLARE @DefaultPriceId 	AS 	INT
	DECLARE @ExistPriceId 		AS 	INT
	DECLARE @TransStr 			AS 	NVARCHAR(4000)
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
	DECLARE @NewPriceId			AS  INT
	DECLARE @OldLSP				AS  NUMERIC(38,6)
	DECLARE @StockInHand		AS  NUMERIC(38,0)
	DECLARE @ValDiffRefNo		AS  NVARCHAR(50)
	DECLARE @MRP				AS  NUMERIC(38,6)
	DECLARE @LSP				AS  NUMERIC(38,6)
	DECLARE @SR					AS  NUMERIC(38,6)
	DECLARE @CR					AS  NUMERIC(38,6)
	DECLARE @AR1				AS  NUMERIC(38,6)
	DECLARE @AR2				AS  NUMERIC(38,6)
	DECLARE @AR3				AS  NUMERIC(38,6)
	DECLARE @AR4				AS  NUMERIC(38,6)
	DECLARE @AR5				AS  NUMERIC(38,6)
	DECLARE @AR6				AS  NUMERIC(38,6)
	SET @Po_ErrNo=0
	SET @Exist=0
    SET @Tabname = 'ETL_Prk_ProductBatch'
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
--->Added
    SELECT [Product Code],[Batch Code],[Price Code],[Batch Sequence Code],COUNT(DISTINCT [Default Price]) AS DefaultPrice
	INTO #TempErrorLog	
	FROM ETL_Prk_ProductBatch
	GROUP BY [Product Code],[Batch Code],[Price Code],[Batch Sequence Code]
	HAVING COUNT(DISTINCT [Default Price])>1
    IF (SELECT COUNT(*) FROM #TempErrorLog)>0
	BEGIN
	INSERT INTO Errorlog VALUES (1,@TabName,'Default Price',
	 	'Default Price is not set correctly')
	 	SET @Po_ErrNo=1
	END
--->Till Here
--Added By Murugan
	--Check Product Code
	INSERT INTO Errorlog
	SELECT DISTINCT 1,@TabName,'Product','Product Code ['+ISNULL([Product Code],'') +'] does not exists for Batch Code ['+ISNULL([Batch Code],'')+']'
	FROM ETL_Prk_ProductBatch WHERE [Product Code] NOT IN(SELECT PrdCCode FROM Product)	
	--Till Here
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdCCode','Product :'+PrdCCode+' not available'
		FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		--->Added By Nanda on 05/05/2010
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Product Batch',PrdBatCode,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		--->Till Here				
	END
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch
	WHERE LEN(ISNULL(PrdBatCode,''))=0)
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch
		WHERE LEN(ISNULL(PrdBatCode,''))=0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdBatCode','Batch Code should not be empty for Product:'+PrdCCode
		FROM Cn2Cs_Prk_ProductBatch
		WHERE LEN(ISNULL(PrdBatCode,''))=0
	END
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PB.PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,MRP,ListPrice,SellingRate,ClaimRate,
	AddRate1,AddRate2,AddRate3,AddRate4,AddRate5,AddRate6
	FROM Cn2Cs_Prk_ProductBatch PB INNER JOIN Product P ON P.PrdCCode=PB.PrdCCode
	WHERE DownLoadFlag='D' AND PB.PrdCCode+'~'+PrdBatCode
	NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid)	
	ORDER BY PB.PrdCCode,PrdBatCode,EffectiveDate
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@AR1,@AR2,@AR3,@AR4,@AR5,@AR6	
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0
		SET @Po_ErrNo=0
		SET @DefaultPriceId=1
		SET @BatchStatus=1
		SET @PriceCode=@BatchCode+'-'+CAST(@MRP AS NVARCHAR(25))+'-'+CAST(@LSP AS NVARCHAR(25))+'-'+
		CAST(@SR AS NVARCHAR(25))+'-'+CAST(@CR AS NVARCHAR(25))+'-'+CAST(@AR1 AS NVARCHAR(25))
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
			SELECT @OldLSP=ISNULL(PBD.PrdBatDetailValue,0),@ExistPriceId=PriceId FROM ProductBatchDetails PBD
			WHERE PrdBatId=@PrdBatId AND DefaultPrice=1 AND SlNo=2
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
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_ProductBatch','System Date',
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
				IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatchSeqId)>4
				BEGIN
					INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
					DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,5,@AR1,@DefaultPriceId,1,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 
				END
				UPDATE ProductBatch SET DefaultPriceId=@PriceId WHERE PrdBatId=@PrdBatId AND PrdId=@PrdId
	
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'				
				IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRateForOldBatch'
				AND ModuleName='Botree Product Batch Download' AND Status=1)
				BEGIN
					IF @OldLSP-@LSP<>0 AND @Exist=1		
					BEGIN
						SELECT @StockInHand=ISNULL((PrdBatLcnSih+PrdBatLcnUih-PrdBatLcnRessih-PrdBatLcnResUih),0)
						FROM ProductBatchLocation WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId			
						IF @StockInHand>0
						BEGIN
							SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
							
							INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
							VALUES(@ValDiffRefNo,GETDATE(),@PrdId,@PrdBatId,@ExistPriceId,@PriceId,@OldLSP,@LSP,@StockInHand,(@OldLSP-@LSP),(@StockInHand*(@OldLSP-@LSP)),1,1,GETDATE(),1,GETDATE())
							UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'
						END
					END
				END
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_ProductBatch','System Date',
				'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
				SET @Po_ErrNo=1
				CLOSE Cur_ProductBatch
				DEALLOCATE Cur_ProductBatch
				RETURN
			END
		END
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@AR1,@AR2,@AR3,@AR4,@AR5,@AR6		
--		IF (SELECT COUNT(DISTINCT A.PriceId) AS COUNT FROM ProductBatchDetails A INNER JOIN ProductBatch B (NOLOCK) ON
--		A.PrdBatId=B.PrdBatId And B.PrdId=@PrdId WHERE A.DefaultPrice=1 AND A.PrdBatId=@PrdBatId GROUP BY A.PrdBatId	
--		HAVING COUNT(DISTINCT A.PriceId)>1)>1
--		BEGIN
--			UPDATE ProductBatchDetails SET DefaultPrice=0
--			WHERE PrdBatId=@PrdBatId AND PriceId NOT IN
--			(
--				SELECT MAX(DISTINCT PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK)
--				WHERE PrdBatId=@PrdBatId AND DefaultPrice=1
--			)						
--			
--			UPDATE ProductBatch SET DefaultPriceId=B.PriceId
--			FROM ProductBatchDetails B (NOLOCK) WHERE ProductBatch.PrdBatId=B.PrdBatId AND
--			ProductBatch.PrdBatId=@PrdBatId AND B.DefaultPrice=1 AND B.SlNo=1
--		END
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
						IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatchSeqId)>4
						BEGIN
							INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
							Availability,LastModBy,LastModDate,AuthId,AuthDate)
							SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
							SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
							FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=5
						END
						
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
	SELECT @NewPriceId=CurrValue FROM Counters (NOLOCK)	WHERE TabName='ProductBatchDetails' AND FldName='PriceId' 		
	--->Added By Nanda on 24/03/2010
	--->To Update Price
	IF @NewPriceId>@OldPriceId
	BEGIN
		IF EXISTS(SELECT * FROM Configuration(NOLOCK) WHERE ModuleId='BotreeRateForOldBatch'
		AND ModuleName='Botree Product Batch Download' AND Status=1)
		BEGIN
			EXEC Proc_DefaultPriceUpdation @ExistPrdBatMaxId,@OldPriceId,1
		END
	END
	--->Till Here
	
	--->Added By Nanda on 02/10/2009
	--->To Write Price History
	IF EXISTS(SELECT * FROM ProductBatchDetails WHERE DefaultPrice=1 AND PriceId>@OldPriceId)
	BEGIN
		EXEC Proc_DefaultPriceHistory 0,0,@OldPriceId,2,1
	END
	--->Till Here
	UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y' 
	WHERE PrdCCode+'~'+PrdBatCode IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode
	FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		--->Added By Nanda on 03/12/2009 for Special Rate
	IF @ExistPrdBatMaxId>0
	BEGIN		
		SET @BatchTransfer=0
		SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='BotreeAutoBatchTransfer'
		IF @BatchTransfer=1
		BEGIN
			EXEC Proc_AutoBatchTransfer @ExistPrdBatMaxId,@Po_ErrNo = @Po_BatchTransfer OUTPUT
			IF @Po_BatchTransfer=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Batch-Auto Batch Transfer',
				'Auto Batch Transfer is not done properly')           	
				SET @Po_ErrNo=1				
			END
		END
	END
--->Till Here
	RETURN	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_DefaultPriceUpdation' AND XTYPE='P')
DROP PROCEDURE Proc_DefaultPriceUpdation
GO
/*
BEGIN TRANSACTION
EXEC Proc_DefaultPriceUpdation 4871,22302,1
--SELECT * FROM ProductBatchDetails ORDER BY PriceId
--WHERE PriceId>19
--SELECT * FROM ValueDifferenceClaim
--SELECT * FROM ExistPriceDetails
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_DefaultPriceUpdation
(
	@Pi_ExistPrdBatId	INT,
	@Pi_ExistPriceId	INT,
	@Pi_UserId			INT
)
AS
/*********************************
* PROCEDURE		: Proc_DefaultPriceUpdation
* PURPOSE		: To update the latest Price
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @PrdId		INT
	DECLARE @PrdBatId	INT
	DECLARE @PriceId	INT
	DECLARE @PrdCCode	NVARCHAR(200)
	DECLARE @PrdBatCode	NVARCHAR(200)
	DECLARE @MRP		NUMERIC(38,6)
	DECLARE @LSP		NUMERIC(38,6)
	DECLARE @SellRate	NUMERIC(38,6)
	DECLARE @ClaimRate	NUMERIC(38,6)
	DECLARE @DClaimRate	NUMERIC(38,6)
	DECLARE @LSPChange		NUMERIC(38,6)
	DECLARE @StockInHand	NUMERIC(38,0)
	DECLARE @ValDiffRefNo	NVARCHAR(50)
	
	DECLARE @OldPriceId		INT
	DECLARE @OldLSP			NUMERIC(38,6)
	DECLARE @NewPriceId		INT
	DECLARE @NewPrdBatId	INT
	DECLARE @NewPrdBatCode	NVARCHAR(200)
	DECLARE @BatchSeqId		INT
	DECLARE @Check INT
	SET @Check=0
	if exists (select * from dbo.sysobjects where id = object_id(N'[ExistPriceDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [ExistPriceDetails]
	SELECT A.MRP,A.LSP,A.SR,A.CR,A.DCR,A.PrdId,MAX(A.PrdBatId) AS PrdBatId,MAX(A.BatchSeqId) AS BatchSeqId
	INTO ExistPriceDetails
	FROM
	(
		SELECT P.PrdId,P.PrdCCode,PB.PrdBatId,PB.PrdBatCode,PBDM.PriceId,PBDM.BatchSeqId,
		PBDM.PrdBatDetailValue AS MRP,PBDL.PrdBatDetailValue AS LSP,PBDS.PrdBatDetailValue AS SR,PBDC.PrdBatDetailValue AS CR,PBDD.PrdBatDetailValue AS DCR
		FROM Product P (NOLOCK)
		INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId
		INNER JOIN ProductBatchDetails PBDM (NOLOCK) ON PB.PrdBatId=PBDM.PrdBatId
		INNER JOIN BatchCreation BCM (NOLOCK) ON BCM.BatchSeqId=PBDM.BatchSeqId AND BCM.SlNo=PBDM.SlNo AND BCM.MRP=1
		INNER JOIN ProductBatchDetails PBDL (NOLOCK) ON PB.PrdBatId=PBDL.PrdBatId
		INNER JOIN BatchCreation BCL (NOLOCK) ON BCL.BatchSeqId=PBDL.BatchSeqId AND BCL.SlNo=PBDL.SlNo AND BCL.ListPrice=1
		INNER JOIN ProductBatchDetails PBDS (NOLOCK) ON PB.PrdBatId=PBDS.PrdBatId
		INNER JOIN BatchCreation BCS (NOLOCK) ON BCS.BatchSeqId=PBDS.BatchSeqId AND BCS.SlNo=PBDS.SlNo AND BCS.SelRte=1
		INNER JOIN ProductBatchDetails PBDC (NOLOCK) ON PB.PrdBatId=PBDC.PrdBatId
		INNER JOIN BatchCreation BCC (NOLOCK) ON BCC.BatchSeqId=PBDC.BatchSeqId AND BCC.SlNo=PBDC.SlNo AND BCC.ClmRte=1
		INNER JOIN ProductBatchDetails PBDD (NOLOCK) ON PB.PrdBatId=PBDD.PrdBatId
		INNER JOIN BatchCreation BCD (NOLOCK) ON BCD.BatchSeqId=PBDD.BatchSeqId AND BCD.SlNo=PBDD.SlNo AND BCD.RefCode='E'
		WHERE PBDM.PriceId>@Pi_ExistPriceId AND PBDL.PriceId>@Pi_ExistPriceId AND PBDS.PriceId>@Pi_ExistPriceId
		AND PBDC.PriceId>@Pi_ExistPriceId AND PBDD.PriceId>@Pi_ExistPriceId
		AND PBDM.DefaultPrice=1 AND PBDL.DefaultPrice=1 AND PBDS.DefaultPrice=1 AND PBDC.DefaultPrice=1 AND PBDD.DefaultPrice=1
	) A GROUP BY A.MRP,A.LSP,A.SR,A.CR,A.DCR,A.PrdId
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PrdId,PrdBatId,BatchSeqId,MRP,LSP,SR,CR,DCR
	FROM ExistPriceDetails (NOLOCK) 	
	ORDER BY PrdId,PrdBatId
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@BatchSeqId,@MRP,@LSP,@SellRate,@ClaimRate,@DClaimRate
	WHILE @@FETCH_STATUS=0
	BEGIN
			--SELECT @PrdId,@PrdCCode,@PrdBatId,@PrdBatCode,@PriceId,@BatchSeqId,@MRP,@LSP,@SellRate,@ClaimRate,@DClaimRate
			if exists (select * from dbo.sysobjects where id = object_id(N'[ExistNewPriceDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
			drop table [ExistNewPriceDetails]
			SELECT PrdBatId,PrdBatCode,A.LSP-@LSP AS LSPChange,A.LSP AS OldLSP,A.PriceId AS OldPriceId
			INTO ExistNewPriceDetails
			FROM
			(
				SELECT P.PrdId,P.PrdCCode,PB.PrdBatId,PB.PrdBatCode,PBDL.PriceId,
				PBDL.PrdBatDetailValue AS LSP,PBDS.PrdBatDetailValue AS SR,PBDC.PrdBatDetailValue AS CR,PBDD.PrdBatDetailValue AS DCR
				FROM Product P (NOLOCK)
				INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId
				INNER JOIN ProductBatchDetails PBDM (NOLOCK) ON PB.PrdBatId=PBDM.PrdBatId
				INNER JOIN BatchCreation BCM (NOLOCK) ON BCM.BatchSeqId=PBDM.BatchSeqId AND BCM.SlNo=PBDM.SlNo AND BCM.MRP=1
				INNER JOIN ProductBatchDetails PBDL (NOLOCK) ON PB.PrdBatId=PBDL.PrdBatId
				INNER JOIN BatchCreation BCL (NOLOCK) ON BCL.BatchSeqId=PBDL.BatchSeqId AND BCL.SlNo=PBDL.SlNo AND BCL.ListPrice=1
				INNER JOIN ProductBatchDetails PBDS (NOLOCK) ON PB.PrdBatId=PBDS.PrdBatId
				INNER JOIN BatchCreation BCS (NOLOCK) ON BCS.BatchSeqId=PBDS.BatchSeqId AND BCS.SlNo=PBDS.SlNo AND BCS.SelRte=1
				INNER JOIN ProductBatchDetails PBDC (NOLOCK) ON PB.PrdBatId=PBDC.PrdBatId
				INNER JOIN BatchCreation BCC (NOLOCK) ON BCC.BatchSeqId=PBDC.BatchSeqId AND BCC.SlNo=PBDC.SlNo AND BCC.ClmRte=1
				INNER JOIN ProductBatchDetails PBDD (NOLOCK) ON PB.PrdBatId=PBDD.PrdBatId
				INNER JOIN BatchCreation BCD (NOLOCK) ON BCD.BatchSeqId=PBDD.BatchSeqId AND BCD.SlNo=PBDD.SlNo AND BCD.RefCode='E'
				WHERE P.PrdId=@PrdId AND PBDM.PrdBatDetailValue=@MRP AND PBDM.DefaultPrice=1	
				AND PBDL.DefaultPrice=1 AND PBDS.DefaultPrice=1 AND PBDC.DefaultPrice=1 AND PBDD.DefaultPrice=1
			) A
			WHERE A.LSP<>@LSP OR A.SR<>@SellRate OR A.CR<>@ClaimRate OR A.DCR<>@DClaimRate
			DECLARE Cur_NewProductBatch CURSOR
			FOR SELECT PrdBatId,PrdBatCode,LSPChange,OldLSP,OldPriceId
			FROM ExistNewPriceDetails (NOLOCK)
			OPEN Cur_NewProductBatch
			FETCH NEXT FROM Cur_NewProductBatch INTO @NewPrdBatId,@NewPrdBatCode,@LSPChange,@OldLSP,@OldPriceId
			WHILE @@FETCH_STATUS=0
			BEGIN
				---SELECT @NewPrdBatId,@NewPrdBatCode,@LSPChange,@OldLSP,@OldPriceId
				SELECT @NewPriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))		
				UPDATE Counters SET CurrValue=@NewPriceId WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
				
				UPDATE ProductBatchDetails SET DefaultPrice=0 WHERE PrdBatId=@NewPrdBatId
				UPDATE ProductBatch SET DefaultPriceId=@NewPriceId WHERE PrdBatId=@NewPrdBatId
				INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,1,@MRP,1,1,1,1,GETDATE(),1,GETDATE()								
				UNION ALL
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,2,@LSP,1,1,1,1,GETDATE(),1,GETDATE()
				UNION ALL				
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,3,@SellRate,1,1,1,1,GETDATE(),1,GETDATE()
				UNION ALL				
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,4,@ClaimRate,1,1,1,1,GETDATE(),1,GETDATE()
				UNION ALL				
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,5,@DClaimRate,1,1,1,1,GETDATE(),1,GETDATE()	
				IF @LSPChange<>0
				BEGIN
					SELECT @StockInHand=ISNULL(SUM(PrdBatLcnSih+PrdBatLcnUih-PrdBatLcnRessih-PrdBatLcnResUih),0)
					FROM ProductBatchLocation (NOLOCK) WHERE PrdId=@PrdId AND PrdBatId=@NewPrdBatId			
					--SELECT @ValDiffRefNo,GETDATE(),@PrdId,(@StockInHand*@LSPChange),1,1,GETDATE(),1,GETDATE()
					--SELECT @StockInHand
					IF @StockInHand>0
					BEGIN
						SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
						
						INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@ValDiffRefNo,GETDATE(),@PrdId,@NewPrdBatId,@OldPriceId,@NewPriceId,@OldLSP,@LSP,@StockInHand,@LSPChange,@StockInHand*@LSPChange,1,1,GETDATE(),1,GETDATE())
						UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'
					END
				END
				FETCH NEXT FROM Cur_NewProductBatch INTO @NewPrdBatId,@NewPrdBatCode,@LSPChange,@OldLSP,@OldPriceId
			END
			CLOSE Cur_NewProductBatch
			DEALLOCATE Cur_NewProductBatch
		
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@BatchSeqId,@MRP,@LSP,@SellRate,@ClaimRate,@DClaimRate
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_DefaultPriceHistory' AND XTYPE='P')
DROP PROCEDURE Proc_DefaultPriceHistory
GO
--EXEC Proc_DefaultPriceHistory 21,21,1,1,1
CREATE Procedure Proc_DefaultPriceHistory
(
	@Pi_PrdId			INT,	
	@Pi_PrdBatId			INT,
	@Pi_PriceId			INT,
	@Pi_Mode			INT,
	@Pi_UserId			INT
)
AS
/*********************************
* PROCEDURE		: Proc_DefaultPriceHistory
* PURPOSE		: To Store the Default Price History
* CREATED		: Nandakumar R.G
* CREATED DATE	: 02/10/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
/*
	@Pi_Mode=1 ---> Through Front End
	@Pi_Mode=2 ---> Changes Through ETL/Download
*/
SET NOCOUNT ON
BEGIN
	DECLARE @PrdId		INT
	DECLARE @PrdBatId	INT
	DECLARE @PriceId	INT
	IF @Pi_Mode=1
	BEGIN
		IF NOT EXISTS(SELECT * FROM DefaultPriceHistory WHERE PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId 
		AND PriceId=@Pi_PriceId AND ToDate='1900-01-01')
		BEGIN
			
			-->To Set the To Date for old default price
			UPDATE DefaultPriceHistory SET ToDate=GETDATE()
			WHERE PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId AND CurrentDefault=1
			-->To update the old prices as non defaults
			UPDATE DefaultPriceHistory SET CurrentDefault=0
			WHERE PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId
		
			-->To insert the new defaults
			INSERT INTO DefaultPriceHistory(PrdId,PrdBatId,PriceId,SellingRate,PurchaseRate,MRP,FromDate,ToDate,CurrentDefault,
			Availability,LastModBy,LastModDate,AuthId,AuthDate) 	
			SELECT PB.PrdId,PB.PrdBatId,PBDS.PriceId,PBDS.PrdBatDetailValue,PBDP.PrdBatDetailValue,PBDM.PrdBatDetailValue,GETDATE(),'1900-01-01',1, 
			1,@Pi_UserId,GETDATE(),1,GETDATE() FROM ProductBatchDetails PBDS,ProductBatchDetails PBDP,ProductBatchDetails PBDM,
			ProductBatch PB,BatchCreation BCS,BatchCreation BCP,BatchCreation BCM
			WHERE PBDS.PriceId=PBDP.PriceId AND PBDS.PriceId=PBDM.PriceId AND PBDS.PrdbatId=@Pi_PrdBatId AND
			PBDS.PriceId=@Pi_PriceId AND PBDS.PrdBatId=PB.PrdBatId AND PB.PrdId=@Pi_PrdId
			AND PBDS.SlNo=BCS.SlNo AND PBDS.BatchSeqId=BCS.BatchSeqId AND BCS.SelRte=1
			AND PBDP.SlNo=BCP.SlNo AND PBDP.BatchSeqId=BCP.BatchSeqId AND BCP.ListPrice=1
			AND PBDM.SlNo=BCM.SlNo AND PBDM.BatchSeqId=BCM.BatchSeqId AND BCM.MRP=1
			AND PBDS.DefaultPrice=1 AND PBDP.DefaultPrice=1 AND PBDM.DefaultPrice=1
		END
	END
	ELSE IF @Pi_Mode=2
	BEGIN
		DECLARE Cur_DefaultPrice CURSOR
		FOR SELECT PB.PrdId,PB.PrdBatId,PBD.PriceId FROM ProductBatch PB(NOLOCK),ProductBatchDetails PBD(NOLOCK)
		WHERE PB.PrdBatId=PBD.PrdBatId AND PBD.PriceId>=@Pi_PriceId AND PBD.SlNo=1 AND PBD.DefaultPrice=1
		ORDER BY PB.PrdId,PB.PrdBatId,PBD.PriceId
		OPEN Cur_DefaultPrice
		FETCH NEXT FROM Cur_DefaultPrice INTO @PrdId,@PrdBatId,@PriceId
		WHILE @@FETCH_STATUS=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM DefaultPriceHistory WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId 
			AND PriceId=@PriceId AND ToDate='1900-01-01')
			BEGIN
				-->To Set the To Date for old default price
				UPDATE DefaultPriceHistory SET ToDate=GETDATE()
				WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId AND CurrentDefault=1
				-->To update the old prices as non defaults
				UPDATE DefaultPriceHistory SET CurrentDefault=0
				WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId
			
				-->To insert the new defaults
				INSERT INTO DefaultPriceHistory(PrdId,PrdBatId,PriceId,SellingRate,PurchaseRate,MRP,FromDate,ToDate,CurrentDefault,
				Availability,LastModBy,LastModDate,AuthId,AuthDate) 	
				SELECT PB.PrdId,PB.PrdBatId,PBDS.PriceId,PBDS.PrdBatDetailValue,PBDP.PrdBatDetailValue,PBDM.PrdBatDetailValue,GETDATE(),'1900-01-01',1, 
				1,@Pi_UserId,GETDATE(),1,GETDATE() FROM ProductBatchDetails PBDS,ProductBatchDetails PBDP,ProductBatchDetails PBDM,
				ProductBatch PB,BatchCreation BCS,BatchCreation BCP,BatchCreation BCM
				WHERE PBDS.PriceId=PBDP.PriceId AND PBDS.PriceId=PBDM.PriceId AND PBDS.PrdBatId=@PrdBatId AND
				PBDS.PriceId=@PriceId AND PBDS.PrdBatId=PB.PrdBatId AND PB.PrdId=@PrdId
				AND PBDS.SlNo=BCS.SlNo AND PBDS.BatchSeqId=BCS.BatchSeqId AND BCS.SelRte=1
				AND PBDP.SlNo=BCP.SlNo AND PBDP.BatchSeqId=BCP.BatchSeqId AND BCP.ListPrice=1
				AND PBDM.SlNo=BCM.SlNo AND PBDM.BatchSeqId=BCM.BatchSeqId AND BCM.MRP=1
				AND PBDS.DefaultPrice=1 AND PBDP.DefaultPrice=1 AND PBDM.DefaultPrice=1
			
			END
			FETCH NEXT FROM Cur_DefaultPrice INTO @PrdId,@PrdBatId,@PriceId
		END
		CLOSE Cur_DefaultPrice
		DEALLOCATE Cur_DefaultPrice
	END
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_AutoBatchTransfer' AND XTYPE='P')
DROP PROCEDURE Proc_AutoBatchTransfer
GO
/*
BEGIN TRANSACTION
EXEC Proc_AutoBatchTransfer 33113,0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_AutoBatchTransfer
(
	@Pi_OldMaxPrdBatId	INT,
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_AutoBatchTransfer
* PURPOSE		: To do Batch Transfer automatically while downloading New Batch for Existing Product
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/02/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 				AS 	INT
	DECLARE @Trans				AS 	INT
	DECLARE @Tabname 			AS  NVARCHAR(100)
	DECLARE @DestTabname 		AS 	NVARCHAR(100)
	DECLARE @Fldname 			AS  NVARCHAR(100)
	
	DECLARE @PrdDCode 	        AS 	NVARCHAR(100)
	DECLARE @BatchCode			AS 	NVARCHAR(100)
	DECLARE @CmpBatchCode		AS 	NVARCHAR(100)	
	DECLARE @PriceCode			AS 	NVARCHAR(4000)		
	DECLARE @MnfDate			AS 	NVARCHAR(100)
	DECLARE @ExpDate			AS 	NVARCHAR(100)
	DECLARE @TaxGroupCode		AS 	NVARCHAR(100)
	DECLARE @Status				AS 	NVARCHAR(100)
	DECLARE	@BatchSeqCode 		AS 	NVARCHAR(100)
	DECLARE @RefCode           	AS 	NVARCHAR(100)
	DECLARE @PriceValue         AS 	NVARCHAR(100)	
	DECLARE @DefaultPrice       AS 	NVARCHAR(100)	  	
	DECLARE @ExistPrdDCode		AS 	NVARCHAR(100)  	
	DECLARE @ExistBatchCode		AS 	NVARCHAR(100)
	DECLARE @ExistPriceCode		AS 	NVARCHAR(100)  	
	
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
	DECLARE @SlNo	 			AS 	INT
	DECLARE @NoOfPrices 		AS 	INT
	DECLARE @ExistPrices 		AS 	INT
	DECLARE @DefaultPriceId 	AS 	INT
	DECLARE @ExistPriceId 		AS 	INT
	DECLARE @TransStr 			AS 	NVARCHAR(4000)
	DECLARE @ExistPrdBatMaxId	AS 	INT
	DECLARE @NewPrdBatMaxId		AS 	INT
	DECLARE @ContPrdId 			AS 	INT
	DECLARE @ContPrdBatId 		AS 	INT
	DECLARE @ContExistPrdBatId 	AS 	INT
	DECLARE @ContPriceId 		AS 	INT
	DECLARE @ContractId 		AS 	INT
	DECLARE @ContPriceCode		AS NVARCHAR(100)
	DECLARE @ContPrdBatId1		AS INT
	DECLARE @ContPriceId1		AS INT
	DECLARE @BatchTransfer		AS INT
	DECLARE @SalStock			AS INT
	DECLARE @UnSalStock			AS INT
	DECLARE @OfferStock			AS INT
	DECLARE @FromPrdBatId		AS INT
	DECLARE @FromPrdBatCode		AS NVARCHAR(200)
	DECLARE @ToPrdBatId			AS INT
	DECLARE @LcnId				AS INT
	DECLARE @Po_StkPosting		AS INT
	DECLARE @TransDate			AS DATETIME
	SET @BatchTransfer=0
	SELECT @TransDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	---->Needs to be changed
	SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='GENConfig000001'
	SET @Po_ErrNo=0
	SET @Exist=0
	SET @ExistPrdDCode=''	
	SET @ExistBatchCode=''
	SET @ExistPriceCode=''
	
	SET @DestTabname='ProductBatch'
	SET @Fldname='PrdBatId'
	SET @Tabname = 'ETL_Prk_ProductBatch'
	SET @Exist=0
	
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PrdId,PrdBatId,PrdBatCode FROM ProductBatch
	WHERE PrdBatId >@Pi_OldMaxPrdBatId ORDER BY PrdId,PrdBatId,PrdBatCode
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@BatchCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		--SELECT 'Nanda'
		--SELECT @PrdId,@PrdBatId,@BatchCode
		DECLARE Cur_BatchTransfer CURSOR
		FOR SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
		FROM ProductBatchLocation PBL WHERE PBL.PrdId=@PrdId AND PBL.PrdBatId<>@PrdBatId
		AND ((PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih)+(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih)+(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre))>0
		OPEN Cur_BatchTransfer
		FETCH NEXT FROM Cur_BatchTransfer INTO @LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
		WHILE @@FETCH_STATUS=0
		BEGIN
			--SELECT @PrdId,@PrdBatId,@LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
			
			SET @Po_ErrNo=0
			
			IF @SalStock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 1,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 1,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 30,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 27,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END													
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
			
			IF @UnSalStock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 2,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 2,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 31,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 28,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END						
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
				
			IF @Offerstock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 3,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 3,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 32,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 29,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END						
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
			IF @Po_ErrNo>0
			BEGIN
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				VALUES(@FromPrdBatId,'','Error','Error')
			END
			FETCH NEXT FROM Cur_BatchTransfer INTO @LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
		END
		CLOSE Cur_BatchTransfer
		DEALLOCATE Cur_BatchTransfer
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@BatchCode
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	RETURN	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_UpdateProductBatchLocation' AND XTYPE='P')
DROP PROCEDURE Proc_UpdateProductBatchLocation
GO
--exec Proc_UpdateProductBatchLocation 1,2,1,2282,5,'2006-02-15',150,1,0
CREATE Procedure Proc_UpdateProductBatchLocation
(
	@Pi_ColId 		INT,
	@Pi_Type		INT,
	@Pi_PrdId		INT,
	@Pi_PrdBatId		INT,
	@Pi_LcnId		INT,
	@Pi_TranDate		DateTime,
	@Pi_TranQty		Numeric(38,0),
	@Pi_UsrId		INT,
	@Pi_ErrNo		INT	OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateProductBatchLocation
* PURPOSE	: To Update ProductBatchLocation 
* CREATED	: Thrinath
* CREATED DATE	: 05/01/2007
* NOTE		: General SP for Updating ProductBatchLocation
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/ 
SET NOCOUNT ON
Begin
	Declare @sSql as VARCHAR(2500)
	Declare @FldName as VARCHAR(100)
	Declare @StkChkFldName as VARCHAR(100)
	Declare @ErrNo as INT
	DECLARE @LastTranDate 	DATETIME

	IF EXISTS (SELECT PrdId FROM Product Where PrdId = @Pi_PrdId and PrdType = 3)
	BEGIN
		--IF Product is a KIT Item Return True
		Set @Pi_ErrNo = 0
		RETURN
	END

	IF NOT EXISTS (SELECT PrdId FROM ProductBatchLocation Where PrdId = @Pi_PrdId
		and PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId)
	BEGIN
		INSERT INTO ProductBatchLocation
		(
			LcnId,PrdId,PrdBatId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnfre,
			PrdBatLcnResSih,PrdBatLcnResUih,PrdBatLcnResFre,
			Availability,LastModBy,LastModDate,AuthId,AuthDate
		) VALUES
		(
			@Pi_LcnId,@Pi_PrdId,@Pi_PrdBatId,0,0,0,
			0,0,0,
			1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
		)
	END

	Select @FldName = CASE @Pi_ColId WHEN 1 THEN 'PrdBatLcnSih'
		WHEN 2 THEN 'PrdBatLcnUih'
		WHEN 3 THEN 'PrdBatLcnfre'
		WHEN 4 THEN 'PrdBatLcnResSih'
		WHEN 5 THEN 'PrdBatLcnResUih'
		WHEN 6 THEN 'PrdBatLcnResFre' END

	Select @StkChkFldName = CASE @Pi_ColId - 3 WHEN 1 THEN 'PrdBatLcnSih'
		WHEN 2 THEN 'PrdBatLcnUih'
		WHEN 3 THEN 'PrdBatLcnfre' END

	SET @Pi_ErrNo = 0

	IF @Pi_Type = 2 
	BEGIN
		Create Table #CheckStock 
		(	
			PrdId int
		)
		
		SET @sSql = ' Insert Into #CheckStock (Prdid) '
		SET @sSql = @sSql + 'Select Prdid From ProductBatchLocation Where'
		SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
		SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
		SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
		SET @sSql = @sSql + ' AND '  + @FldName + ' < ' + CAST(@Pi_TranQty as VARCHAR(10))
		
		Exec (@sSql)

		IF Exists(Select * From #CheckStock)
		BEGIN
			SET @Pi_ErrNo = 1
		END
	
		DROP TABLE #CheckStock 
	END

	IF @Pi_Type = 1 AND @Pi_ColId > 3
	BEGIN
		Create Table #CheckStock1 
		(	
			prdid int
		)
		
		SET @sSql = ' Insert Into #CheckStock1 (Prdid) '
		SET @sSql = @sSql + 'Select Prdid From ProductBatchLocation Where'
		SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
		SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
		SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
		SET @sSql = @sSql + ' AND ' + @StkChkFldName + ' < ' + @FldName + ' + ' 
		SET @sSql = @sSql + CAST(@Pi_TranQty as VARCHAR(10))
	
		Exec (@sSql)

		IF Exists(Select * From #CheckStock1)
		BEGIN
			SET @Pi_ErrNo = 1
		END
	
		DROP TABLE #CheckStock1 
	END

	IF @Pi_ErrNo = 0
	BEGIN
		SET @sSql = 'Update ProductBatchLocation Set ' + @FldName + ' = ' + @FldName + ' + '
		SET @sSql = @sSql + CASE @Pi_Type WHEN 2 Then '-1' Else '1' End + '* ' 
		SET @sSql = @sSql + CAST(@Pi_TranQty as VARCHAR(10)) 
		SET @sSql = @sSql + ', LastModDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
		SET @sSql = @sSql + ', AuthDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
		SET @sSql = @sSql + ', LastModBy = ' + CAST(@Pi_UsrId as VARCHAR(10))
		SET @sSql = @sSql + ', AuthId = ' + CAST(@Pi_UsrId as VARCHAR(10)) + ' Where'
		SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
		SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
		SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
	
		Exec (@sSql)
	End
--print @Pi_ErrNo
RETURN
End
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_UpdateStockLedger' AND XTYPE='P')
DROP PROCEDURE Proc_UpdateStockLedger
GO
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

					UPDATE ConsolidateStockLedger SET StockValue=  @CurVal + (SELECT StockValue FROM
					ConsolidateStockLedger WHERE TransDate=@MaxDate) WHERE TransDate=@Pi_TranDate

			END
	END

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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_UpdateOpeningStock' AND XTYPE='P')
DROP PROCEDURE Proc_UpdateOpeningStock
GO
CREATE Procedure Proc_UpdateOpeningStock
(
	@Pi_PrdId		INT,
	@Pi_PrdBatId		INT,
	@Pi_LcnId		INT,
	@Pi_TranDate		DateTime,
	@Pi_UsrId		INT,
	@Pi_OpnErrNo		INT	OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateOpeningStock
* PURPOSE	: To Update Opening Stock in StockLedger 
* CREATED	: Thrinath
* CREATED DATE	: 04/01/2007
* NOTE		: General SP for Updating Opening Stock in StockLedger
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
Begin
	DECLARE @LastTranDate 	DATETIME
	Declare @ErrNo as INT

	SET @Pi_OpnErrNo = 0

	Select @LastTranDate = isnull(Max(TransDate),CONVERT(VARCHAR(10),'1981-05-30',121)) from 
		StockLedger where PrdId=@Pi_PrdId and PrdBatId=@Pi_PrdBatId 
		and LcnId=@Pi_LcnId and TransDate < @Pi_TranDate
	
	IF @LastTranDate = '1981-05-30'
	BEGIN
		UPDATE StockLedger SET 
			SalOpenStock = 0,
			UnSalOpenStock = 0,
			OfferOpenStock = 0,
			LastModBy = @Pi_UsrId,
			LastModDate = CONVERT(VARCHAR(10),GetDate(),121),
			AuthId = @Pi_UsrId,
			AuthDate = CONVERT(VARCHAR(10),GetDate(),121)
		WHERE 
			PrdId = @Pi_PrdId AND PrdBatId = @Pi_PrdBatId AND LcnId = @Pi_LcnId
			AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
	END
	ELSE
	BEGIN
		Select @LastTranDate = DATEADD(DAY,1,@LastTranDate)
		While @LastTranDate <= @Pi_TranDate
		Begin

			IF NOT EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
				and PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
				and TransDate = CONVERT(VARCHAR(10),@LastTranDate,121))
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
					@LastTranDate,@Pi_LcnId,@Pi_PrdId,@Pi_PrdBatId,0,0,
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
					@Pi_UsrId,@LastTranDate,@Pi_UsrId,@LastTranDate
				)
			END

			DECLARE  @DecClsStk TABLE
			(
				DSalClsStock Numeric(38,0),
				DUnSalClsStock Numeric(38,0),
				DOfferClsStock Numeric(38,0),
				DPrdId INT,
				DPrdBatId INT,
				DLcnId INT,
				DTransDate DATETIME
			)

			Delete from @DecClsStk

			INSERT INTO @DecClsStk
			(
				DSalClsStock,DUnSalClsStock,
				DOfferClsStock,DPrdId,DPrdBatId,DLcnId,
				DTransDate 
			)
			Select SalClsStock,UnSalClsStock,
				OfferClsStock,PrdId,PrdBatId,LcnId,
				@LastTranDate
			From StockLedger
			WHERE 
				PrdId = @Pi_PrdId AND PrdBatId = @Pi_PrdBatId AND LcnId = @Pi_LcnId
				AND TransDate = CONVERT(VARCHAR(10),DATEADD(DAY,-1,@LastTranDate),121)

			UPDATE StockLedger SET 
				SalOpenStock = B.DSalClsStock,
				UnSalOpenStock = B.DUnSalClsStock,
				OfferOpenStock = B.DOfferClsStock,
				LastModBy = @Pi_UsrId,
				LastModDate = CONVERT(VARCHAR(10),GetDate(),121),
				AuthId = @Pi_UsrId,
				AuthDate = CONVERT(VARCHAR(10),GetDate(),121)
			FROM @DecClsStk B
			WHERE 
				PrdId = B.DPrdId AND PrdBatId = B.DPrdBatId AND LcnId = B.DLcnId
				AND TransDate = B.DTransDate
			
			EXEC Proc_UpdateClosingStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@LastTranDate,@Pi_UsrId,@Pi_ClsErrNo = @ErrNo OutPut

			IF @Pi_OpnErrNo = 0 AND @ErrNo = 1
			BEGIN
				Set @Pi_OpnErrNo = 1
			END

			Select @LastTranDate = DATEADD(DAY,1,@LastTranDate)
		End
	END
Return
End
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_UpdateClosingStock' AND XTYPE='P')
DROP PROCEDURE Proc_UpdateClosingStock
GO
--EXEC Proc_UpdateClosingStock 1,1,1,'',1,0
CREATE Procedure Proc_UpdateClosingStock
(
	@Pi_PrdId		INT,
	@Pi_PrdBatId		INT,
	@Pi_LcnId		INT,
	@Pi_TranDate		DateTime,
	@Pi_UsrId		INT,
	@Pi_ClsErrNo		INT	OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateClosingStock
* PURPOSE	: To Update Closing Stock in StockLedger 
* CREATED	: Thrinath
* CREATED DATE	: 04/01/2007
* NOTE		: General SP for Updating Closing Stock in StockLedger
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
Begin

	SET @Pi_ClsErrNo = 0

	IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
		AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
		AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
		AND (SalOpenStock  		+   
			SalPurchase   		+  
			SalStockIn  		+  
			SalSalesReturn 		+ 
			SalStkJurIn 		+ 
			SalBatTfrIn 		+ 
			SalLcnTfrIn 		- 
			SalPurReturn  	- 
			SalSales   		-  
			SalStockOut		- 
			SalStkJurOut 		- 
			SalBatTfrOut 		- 
			SalLcnTfrOut 		- 
			SalReplacement
		     ) < 0)
	BEGIN
		SET @Pi_ClsErrNo = 1
	END
	
	IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
		AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
		AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
		AND (UnSalOpenStock  		+ 
			UnSalPurchase 		+ 
			UnSalStockIn  		+ 
			DamageIn   			+  
			UnSalSalesReturn 	+ 
			UnSalStkJurIn  		+ 
			UnSalBatTfrIn 		+ 
			UnSalLcnTfrIn  		- 
			UnsalPurReturn 	-    
			UnSalSales 		- 
			UnSalStockOut 		- 
			DamageOut 			- 
			UnSalStkJurOut 		- 
			UnSalBatTfrOut 		- 
			UnSalLcnTfrOut 
		    ) < 0)
	BEGIN
		SET @Pi_ClsErrNo = 1
	END

	IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
		AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
		AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
		AND (OfferOpenStock  		+ 
			OfferPurchase 			+ 
			OfferStockIn   		+
			OfferSalesReturn 		+ 
			OfferStkJurIn 		+ 
			OfferBatTfrIn 		+ 
			OfferLcnTfrIn 		- 
			OfferPurReturn 		- 
			OfferSales   			- 
			OfferStockOut 		- 
			OfferStkJurOut 		- 
			OfferBatTfrOut 		- 
			OfferLcnTfrOut 		- 
			OfferReplacement
		     ) < 0)
	BEGIN
		SET @Pi_ClsErrNo = 1
	END

	IF @Pi_ClsErrNo = 0
	BEGIN
		UPDATE StockLedger SET 
			SalClsStock = (SalOpenStock  		+   
							SalPurchase   		+  
							SalStockIn  		+  
							SalSalesReturn 		+ 
							SalStkJurIn 		+ 
							SalBatTfrIn 		+ 
							SalLcnTfrIn 		- 
							SalPurReturn  	- 
							SalSales   		-  
							SalStockOut		- 
							SalStkJurOut 		- 
							SalBatTfrOut 		- 
							SalLcnTfrOut 		- 
							SalReplacement
						),
			UnSalClsStock = (UnSalOpenStock  		+ 
							UnSalPurchase 		+ 
							UnSalStockIn  		+ 
							DamageIn   			+  
							UnSalSalesReturn 	+ 
							UnSalStkJurIn  		+ 
							UnSalBatTfrIn 		+ 
							UnSalLcnTfrIn  		- 
							UnSalPurReturn 	-    
							UnSalSales 		- 
							UnSalStockOut 		- 
							DamageOut 			- 
							UnSalStkJurOut 		- 
							UnSalBatTfrOut 		- 
							UnSalLcnTfrOut 
						),
			OfferClsStock = (OfferOpenStock  			+ 
							OfferPurchase 			+ 
							OfferStockIn   		+
							OfferSalesReturn 		+ 
							OfferStkJurIn 		+ 
							OfferBatTfrIn 		+ 
							OfferLcnTfrIn 		- 
							OfferPurReturn 		- 
							OfferSales   			- 
							OfferStockOut 		- 
							OfferStkJurOut 		- 
							OfferBatTfrOut 		- 
							OfferLcnTfrOut 		- 
							OfferReplacement
						),
			LastModBy = @Pi_UsrId,
			LastModDate = CONVERT(VARCHAR(10),GetDate(),121),
			AuthId = @Pi_UsrId,
			AuthDate = CONVERT(VARCHAR(10),GetDate(),121)
		WHERE 
			PrdId = @Pi_PrdId AND PrdBatId = @Pi_PrdBatId AND LcnId = @Pi_LcnId
			AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
	END

RETURN
	
End
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateTaxMapping' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateTaxMapping
GO
---- EXEC Proc_ValidateTaxConfig_Group ''
CREATE PROCEDURE Proc_ValidateTaxMapping
(
	@Po_ErrNo INT OUTPUT
)
AS
/*************************************************************************************************
* PROCEDURE: Proc_ValidateTaxConfig_Group
* PURPOSE: To Insert and UPDATE records from xml file in the Table Tax Mapping
* CREATED: Boopathy.P	02/09/2009
***************************************************************************************************
* 08.09.2009  Aarthi Check the Map Status Condition
**************************************************************************************************/
BEGIN
	DECLARE @Taction		INT
	DECLARE @StateId		INT
	DECLARE @ErrDesc		VARCHAR(1000)
	DECLARE @rno			INT
	DECLARE @Tabname		VARCHAR(50)
	DECLARE @sStr			NVARCHAR(4000)
	DECLARE @PrdCode		NVARCHAR(200)	
	DECLARE @TaxGroupCode	NVARCHAR(200)
	DECLARE @PrdId			INT
	DECLARE @TaxGrpId		INT
	DECLARE @MapStatus		INT
	SET @Po_ErrNo=0
	SET @Tabname = 'Etl_Prk_TaxMapping'
	DECLARE Cur_PrdMapping CURSOR
	FOR SELECT DISTINCT ISNULL([PrdCode],''),ISNULL([TaxGroupCode],''),MapStatus	
	FROM Etl_Prk_TaxMapping where DownloadFlag='D'
	OPEN Cur_PrdMapping
	FETCH NEXT FROM Cur_PrdMapping INTO @PrdCode,@TaxGroupCode,@MapStatus
	SET @Rno = 0
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Rno = @Rno + 1
		SET @Taction = 2 -- Insert	
	    --- Validation for NULL value
		IF ISNULL(@PrdCode,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + CAST (@Rno AS VARCHAR(10)) + ' Product Code '+ @PrdCode + ' Should not be null '
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF ISNULL(@TaxGroupCode,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + CAST (@Rno AS VARCHAR(10)) + ' Tax Group '+ @TaxGroupCode + ' Should not be null '
			INSERT INTO Errorlog VALUES (1,@TabName,'Tax Group Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF EXISTS(SELECT * FROM Product WHERE PrdCCode=@PrdCode)
		BEGIN
			SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=@PrdCode
		END
		ELSE
		BEGIN
			SET @ErrDesc = 'In Row ' + CAST (@Rno AS VARCHAR(10)) + ' Product Code '+ @PrdCode + ' Not found '
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF EXISTS(SELECT * FROM TaxGroupSetting WHERE PrdGroup=@TaxGroupCode)
		BEGIN
			SELECT @TaxGrpId=TaxGroupId FROM TaxGroupSetting WHERE PrdGroup=@TaxGroupCode
		END
		ELSE
		BEGIN
			SET @ErrDesc = 'In Row ' + CAST (@Rno AS VARCHAR(10)) + ' Tax Group '+ @TaxGroupCode + ' Not found '
			INSERT INTO Errorlog VALUES (1,@TabName,'Tax Group Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo=1
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @MapStatus=1
			BEGIN				
				UPDATE Product SET TaxGroupId=@TaxGrpId WHERE PrdId=@PrdId
				UPDATE ProductBatch SET TaxGroupId=@TaxGrpId WHERE PrdId=@PrdId
			END
			ELSE
			BEGIN
				UPDATE Product SET TaxGroupId=0 WHERE PrdId=@PrdId
				UPDATE ProductBatch SET TaxGroupId=0 WHERE PrdId=@PrdId
			END
			UPDATE Etl_Prk_TaxMapping SET DownloadFlag='Y' WHERE PrdCode=@PrdCode AND TaxGroupCode=@TaxGroupCode and DownloadFlag='D'
		END
		FETCH NEXT FROM Cur_PrdMapping INTO  @PrdCode,@TaxGroupCode,@MapStatus
	END
	CLOSE Cur_PrdMapping
	DEALLOCATE Cur_PrdMapping
	
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_SpecialRate' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_SpecialRate
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_SpecialRate 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_SpecialRate
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ClusterMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ClusterMaster
GO
CREATE PROCEDURE Proc_Cn2Cs_ClusterMaster
/*    
BEGIN TRANSACTION    
EXEC Proc_Cn2Cs_ClusterMaster 0    
SELECT * FROM Cn2Cs_Prk_ClusterMaster    
SELECT * FROM errorlog    
ROLLBACK TRANSACTION    
*/      
(    
 @Po_ErrNo INT OUTPUT    
)    
AS    
/*********************************    
* PROCEDURE  : Proc_Cn2Cs_ClusterMaster    
* PURPOSE  : To validate the downloaded Cluster details from Console    
* CREATED  : Nandakumar R.G    
* CREATED DATE : 30/07/2010    
* MODIFIED    
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
* {date} {developer}  {brief modification description}    
*********************************/    
SET NOCOUNT ON    
BEGIN    
 DECLARE @TabName  NVARCHAR(100)    
 DECLARE @ErrDesc  NVARCHAR(1000)    
 DECLARE @ClusterCode  NVARCHAR(50)    
 DECLARE @ClusterName   NVARCHAR(100)    
 DECLARE @Remarks    NVARCHAR(200)    
 DECLARE @Salesman  NVARCHAR(10)    
 DECLARE @Retailer  NVARCHAR(10)    
 DECLARE @AddMast1    NVARCHAR(10)    
 DECLARE @AddMast2    NVARCHAR(10)    
 DECLARE @AddMast3    NVARCHAR(10)    
 DECLARE @AddMast4    NVARCHAR(10)    
 DECLARE @AddMast5    NVARCHAR(10)    
 DECLARE @ClusterId   INT    
 DECLARE @Exist    INT    
 DECLARE @Value   NUMERIC(38,6)    
 DECLARE @PrdCtgLevelCode NVARCHAR(100)    
 DECLARE @CmpPrdCtgId   INT    
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
    --Update For DownLoaded 
    Update  ClusterMaster Set  DownLoaded = 1 Where  ClusterId=@ClusterId     
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
    --Update For DownLoaded  
    Update  ClusterMaster Set  DownLoaded = 1 Where  ClusterId=@ClusterId     
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ClusterGroup' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ClusterGroup
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterGroup 0
SELECT * FROM Cn2Cs_Prk_ClusterGroup
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_ClusterGroup
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeMaster
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeMaster 0
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeAttributes' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeAttributes
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeAttributes 0
--SELECT * FROM ErrorLog
SELECT * FROM SchemeRetAttr WHERE SchId=50 AND AttrType=6
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeAttributes
(
@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeAttributes
* PURPOSE: To Insert and Update Scheme Attributes
* CREATED: Boopathy.P on 02/01/2009
***************************************************************************************************
* 12.09.2011  Panner AttrType Checking (Product or SKU)
**************************************************************************************************/
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
			ELSE IF (UPPER(LTRIM(RTRIM(@AttrType))) = 'SKU' OR UPPER(LTRIM(RTRIM(@AttrType)))= 'PRODUCT')
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
--		INSERT INTO SchemeRetAttr
--		SELECT DISTINCT B.SchId,6,A.RtrClassId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) 
--		FROM RETAILERVALUECLASS A 
--		INNER JOIN @Temp_CtgAttrDt B ON A.CtgMainId=B.CtgMainId 
--		INNER JOIN @Temp_ValAttrDt C ON A.ValueClassCode = C.ValClass AND B.SchId=C.SchId
--		AND B.SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
		INSERT INTO SchemeRetAttr
		SELECT DISTINCT C.SchId,6,A.RtrValueClassId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM 
		(SELECT DISTINCT RVC.ValueClassCode,RVCM.RtrValueClassId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId,
		R.RtrKeyAcc,R.VillageId,RC.CtgLinkCode
		FROM Retailer R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId 
		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId) A
		INNER JOIN @Temp_ValAttrDt C ON A.ValueClassCode = C.ValClass 
		INNER JOIN @Temp_CtgAttrDt B ON A.CtgLinkId=B.CtgMainId 
		AND C.SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeProducts' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeProducts
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeProducts 0
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeProducts
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeProducts
* PURPOSE: To Insert and Update Scheme Products
* CREATED: Boopathy.P on 05/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 	AS VARCHAR(50)
	DECLARE @Type  		AS VARCHAR(50)
	DECLARE @PrdCode 	AS VARCHAR(50)
	DECLARE @PrdBatCode 	AS VARCHAR(50)
	DECLARE @CmpId  	AS VARCHAR(50)
	DECLARE @TypeId  	AS VARCHAR(50)
	DECLARE @PrdId  	AS VARCHAR(50)
	DECLARE @PrdBatId 	AS VARCHAR(50)
	DECLARE @SchLevelId 	AS VARCHAR(50)
	DECLARE @BatchLvl 	AS VARCHAR(50)
	DECLARE @UDCId  	AS VARCHAR(50)
	DECLARE @CombiSch 	AS VARCHAR(50)
	DECLARE @ChkCount 	AS INT
	DECLARE @ErrDesc  	AS VARCHAR(1000)
	DECLARE @TabName  	AS VARCHAR(50)
	DECLARE @GetKey   	AS VARCHAR(50)
	DECLARE @Taction  	AS INT
	DECLARE @SelLvl   	AS VARCHAR(50)
	DECLARE @SelMode	AS VARCHAR(50)
	DECLARE @ConFig   	AS INT
	DECLARE @sSQL     	AS VARCHAR(4000)
	DECLARE @MaxSchLevelId 	AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SLevel		AS INT
	--->Added By Nanda on 09/11/2010
	DECLARE @MaxSchId	AS INT
	DECLARE @FBMSchCode AS NVARCHAR(100)
	DECLARE @FBMSchId	AS INT
	DECLARE @FBMDate	AS DATETIME
	SELECT @MaxSchId=ISNULL(MAX(SchId),0) FROM SchemeProducts
	--->Till Here
	
	SET @TabName = 'Etl_Prk_SchemeProducts_Combi'
	SET @Po_ErrNo =0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE Cur_SchemePrds CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL(SchLevel,'') AS [Type],
	ISNULL([PrdCode],'') AS [Code],ISNULL([PrdBatCode],'') AS [Batch Code]
	FROM Etl_Prk_SchemeProducts_Combi WHERE SlabValue = 0 AND SlabId=0
	AND CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchemePrds
	FETCH NEXT FROM Cur_SchemePrds INTO @SchCode,@Type,@PrdCode,@PrdBatCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Type))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF NOT EXISTS(SELECT DISTINCT PRDID FROM PRODUCT)
		BEGIN
			SET @ErrDesc = 'No Product(s) found in Product Master'
			INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF NOT EXISTS(SELECT DISTINCT Prdbatid FROM PRODUCTBATCH)
		BEGIN
			SET @ErrDesc = 'No Batch found in Batch Master'
			INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
-- 		ELSE IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' AND UPPER(LTRIM(RTRIM(@Type)))='UDC'
-- 		BEGIN
-- 			SET @ErrDesc = 'Type should be (PRODUCT OR UDC)'
-- 			INSERT INTO Errorlog VALUES (1,@TabName,'Type',@ErrDesc)
-- 			SET @Taction = 0
-- 			SET @Po_ErrNo =1
-- 		END
		SELECT @Type= SchemeLevelMode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found'
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
					FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
						FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found'
							INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
							B.CmpCode=A.CmpCode WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
							SELECT @SchLevelId=CmpPrdCtgId FROM Etl_Prk_SchemeHD_Slabs_Rules A
							INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
							INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
							AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
						END
					END
					ELSE
					BEGIN
						SELECT @CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
						FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	END
			END
			IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@Type)))='SKU' OR UPPER(LTRIM(RTRIM(@Type)))='MATERIAL'
			BEGIN
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @MaxSchLevelId=@SchLevelId
				BEGIN
					IF NOT EXISTS(SELECT PrdId FROM Product WHERE CmpId=@CmpId
					AND PrdCCode=LTRIM(RTRIM(@PrdCode)))
					BEGIN
						IF @ConFig<>1
						BEGIN
							SET @ErrDesc = 'Product Code Not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SET @PrdId= 0 --LTRIM(RTRIM(@PrdCode))
						END
					END
					ELSE
					BEGIN
						SELECT @PrdId=PrdId FROM Product WHERE CmpId=@CmpId
						AND PrdCCode=LTRIM(RTRIM(@PrdCode))
						SET @UDCId=0
						IF @BatchLvl=1
						BEGIN
							IF LTRIM(RTRIM(@PrdBatCode))= ''
							BEGIN
								SET @ErrDesc = 'Batch Code should not be blank for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'Batch Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1  					
							END
							IF NOT EXISTS(SELECT PrdBatId FROM ProductBatch WHERE PrdId=@PrdId AND
									PrdBatCode=LTRIM(RTRIM(@PrdBatCode)))
							BEGIN
								IF @ConFig<>1
								BEGIN
									SET @ErrDesc = 'Batch Code Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (11,@TabName,'Batch Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SET @PrdBatId=LTRIM(RTRIM(@PrdBatCode))
								END
							END
							ELSE
							BEGIN
								SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId AND
								PrdBatCode=LTRIM(RTRIM(@PrdBatCode))
							END
						END
						ELSE
						BEGIN
							SET @PrdBatId=0
						END
					END
				END
				ELSE  -- For Product Category Value
				BEGIN
					IF NOT EXISTS(SELECT A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
					ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
					AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId)
					BEGIN
						IF @ConFig<>1
						BEGIN
							SET @ErrDesc = 'Product Category Level Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
								ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
								AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
							SET @PrdId=0
							SET @PrdBatId=0
						END
					END
					ELSE
					BEGIN
						SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
						SET @PrdId=0
						SET @PrdBatId=0
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Type)))='UDC'
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
				ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
				INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
				WHERE A.UdcMasterId=@SchLevelId)
				BEGIN
					IF @ConFig<>1
					BEGIN
						SET @ErrDesc = 'UDC Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'UDC',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SET @UDCId=0
						SET @PrdId=0
						SET @PrdBatId=0
					END
				END
				ELSE
				BEGIN
					SELECT DISTINCT @UDCId=A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
					ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
					INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
					Where A.UdcMasterId=@SchLevelId
					SET @PrdId=0
					SET @PrdBatId=0
				END
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
			SELECT @ChkCount=COUNT(*) FROM TempDepCheck
			IF @ChkCount > 0
			BEGIN
				SET @Taction = 0
			END
			ELSE
			BEGIN
				IF @ConFig=1
				BEGIN
					SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
					IF @SchLevelId<@SLevel
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
							IF @SLevel=@SchLevelId
							BEGIN
								DELETE FROM SCHEMEPRODUCTS WHERE PrdId=@PrdId AND PrdBatId= @PrdBatId AND
							     	SchId=@GetKey
							     	SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdId=' + CAST(@PrdId AS VARCHAR(50)) +
							     	' AND PrdBatId=' + CAST(@PrdBatId AS VARCHAR(50)) + ' AND SchId=' + CAST(@GetKey AS VARCHAR(50))
							END
							ELSE
							BEGIN
								DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
								SchId=@GetKey
								SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(50)) +
								' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
							END
							
							INSERT INTO Translog(strSql1) Values (@sSQL)
							INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
							@PrdId ,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)
							
							SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
							CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',1)'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
						ELSE
						BEGIN
							INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
							VALUES(LTRIM(RTRIM(@SchCode)),@UDCId,@PrdId,LTRIM(RTRIM(@PrdCode)),@PrdBatId,'N')
							SET @sSQL ='INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
							VALUES('+ CAST(@SchCode AS VARCHAR(50)) + ',' +
							CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdCode AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
							 ',''N'''')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
							SET @Po_ErrNo=0
						END
					END
					ELSE
					BEGIN
						IF @SLevel=@SchLevelId
						BEGIN
							DELETE FROM Etl_Prk_SchemeProduct_Temp WHERE PrdId=CAST(@PrdId AS VARCHAR(50)) AND PrdBatId= CAST(@PrdBatId AS VARCHAR(50)) AND
						     	CmpSchCode=@GetKey AND UpLoadFlag='N'
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeProduct_Temp WHERE PrdCtgValMainId=CAST(@UDCId  AS VARCHAR(50)) AND
							CmpSchCode=@GetKey AND UpLoadFlag='N'
						END
						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
						VALUES(LTRIM(RTRIM(@SchCode)),@UDCId,@PrdId,LTRIM(RTRIM(@PrdCode)),@PrdBatId,'N')
						SET @sSQL ='INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
						VALUES('+ CAST(@SchCode AS VARCHAR(50)) + ',' +
						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdCode AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
						 ',''N'''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
						SET @Po_ErrNo=0
						
					END		
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@Type)))='UDC'
					BEGIN
						DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
						SchId=@GetKey
-- 						SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(10)) +
-- 						' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
						@PrdId,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)
-- 						SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
-- 						LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
-- 						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@Type)))='SKU' OR UPPER(LTRIM(RTRIM(@Type)))='MATERIAL'
					BEGIN
						IF @MaxSchLevelId=@SchLevelId
						BEGIN
						     DELETE FROM SCHEMEPRODUCTS WHERE PrdId=@PrdId AND PrdBatId= @PrdBatId AND
						     SchId=@GetKey
-- 						     SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdId=' + CAST(@PrdId AS VARCHAR(50)) +
-- 						     ' AND PrdBatId=' + CAST(@PrdBatId AS VARCHAR(50)) + ' AND SchId=' + CAST(@GetKey AS VARCHAR(50))
						END
						ELSE
						BEGIN
						     DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
						     SchId=@GetKey
-- 						     SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(50)) +
-- 						     ' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
						END
						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
						@PrdId,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)
-- 						SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
-- 						LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(ISNULL(@GetKey,0) AS VARCHAR(10)) + ',' +
-- 						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
	    				END
				END
			END
		END
		FETCH NEXT FROM Cur_SchemePrds INTO @SchCode,@Type,@PrdCode,@PrdBatCode
	END
	CLOSE Cur_SchemePrds
	DEALLOCATE Cur_SchemePrds
	--->Added By Nanda on 09/11/2010
	IF EXISTS(SELECT SP.* FROM SchemeProducts SP,SchemeMaster SM WHERE SM.FBM=1 AND SP.SchId=SM.SchId AND SP.SchId>@MaxSchId)
	BEGIN
		DECLARE Cur_FBMSch CURSOR
		FOR SELECT DISTINCT SM.SchCode,SM.SchId FROM SchemeProducts SP,SchemeMaster SM WHERE SM.FBM=1 AND SP.SchId=SM.SchId AND SP.SchId>@MaxSchId		
		OPEN Cur_FBMSch
		FETCH NEXT FROM Cur_FBMSch INTO @FBMSchCode,@FBMSchId
		WHILE @@FETCH_STATUS=0
		BEGIN					
			SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
			--SELECT 'Nanda02',45,@FBMSchCode,@FBMSchId,@FBMDate,1,0
			EXEC Proc_FBMTrack 45,@FBMSchCode,@FBMSchId,@FBMDate,1,0		
			FETCH NEXT FROM Cur_FBMSch INTO @FBMSchCode,@FBMSchId
		END
		CLOSE Cur_FBMSch
		DEALLOCATE Cur_FBMSch
	END
	--->Till Here
	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeSlab' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeSlab
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeSlab 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeSlab
(
	@Po_ErrNo INT OUTPUT	
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeSlab 1
* PURPOSE: To Insert and Update Scheme Slab Details
* CREATED: Boopathy.P on 02/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode AS VARCHAR(50)
	DECLARE @SlabCode AS INT
	DECLARE @FromUOM AS VARCHAR(200)
	DECLARE @FromQty AS NUMERIC(18,6)
	DECLARE @ToUOM  AS VARCHAR(200)
	DECLARE @ToQty  AS NUMERIC(18,6)
	DECLARE @ForEveryUOM AS VARCHAR(200)
	DECLARE @ForEveryQty AS NUMERIC(18,6)
	DECLARE @DiscPer AS NUMERIC(5,2)
	DECLARE @FlatAmt AS NUMERIC(18,6)
	DECLARE @Points  AS NUMERIC(18,6)
	DECLARE @FlexiFree AS NUMERIC(18,6)
	DECLARE @FlexiGift AS NUMERIC(18,6)
	DECLARE @FlexiDisc AS NUMERIC(18,6)
	DECLARE @FlexiFlat AS NUMERIC(18,6)
	DECLARE @FlexiPoints AS INT
	DECLARE @TempRange AS NUMERIC(18,6)
	DECLARE @CmpId  AS INT
	DECLARE @SchLevelId AS INT
	DECLARE @SchType AS INT
	DECLARE @FlexiId AS INT
	DECLARE @RangeId AS INT
	DECLARE @FlexiType AS INT
	DECLARE @CombiSch AS INT
	DECLARE @FlexiCnt AS INT
	DECLARE @FromUomId AS INT
	DECLARE @ToUomId AS INT
	DECLARE @ForEveryUomId AS INT
	DECLARE @ChkCount AS INT
	DECLARE @PurOfEvery	 AS INT
	DECLARE @ErrDesc  AS VARCHAR(1000)
	DECLARE @TabName  AS VARCHAR(50)
	DECLARE @GetKey  AS VARCHAR(50)
	DECLARE @Taction  AS INT
	DECLARE @MAXSLABID AS INT
	DECLARE @sSQL   AS VARCHAR(4000)
	DECLARE @MaxSchLevelId	AS INT
	DECLARE @CntVal	As	INT
	DECLARE @TempStr	AS Varchar(4000)
	DECLARE @TempStr1	AS Varchar(4000)
	DECLARE @SLevel		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @MaxDisc  AS NUMERIC(18,2)
	DECLARE @MinDisc  AS NUMERIC(18,2)
	DECLARE @MaxValue  AS NUMERIC(18,2)
	DECLARE @MinValue  AS NUMERIC(18,2)
	DECLARE @MaxPoints  AS INT
	DECLARE @MinPoints  AS INT
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SlabNotAppl AS INT
	Create Table  #TempTbl
	(
		PrdUnitId	INT,
		PrdUnitGrpId	INT,
		PrdUnitCode	Varchar(50)
	)
	SET @TabName = 'Etl_Prk_SchemeHD_Slabs_Rules'
	SET @Po_ErrNo =0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE Cur_SchemeSlabDt CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],
	ISNULL([SlabId],0) AS [SlabId],
	ISNULL([Uom],'0') AS [From Uom],
	CASE ISNULL([FromQty],'') WHEN '' THEN 0 ELSE CAST([FromQty] AS NUMERIC(18,2)) END AS [From Qty],
	ISNULL([ToUom],'0') AS [To Uom],
	CASE ISNULL([ToQty],'') WHEN '' THEN 0 ELSE CAST([ToQty] AS NUMERIC(18,2)) END AS [To Qty],
	ISNULL([ForEveryUom],'0') AS [For Every Uom],
	CASE ISNULL([ForEveryQty],'') WHEN '' THEN 0 ELSE CAST([ForEveryQty] AS NUMERIC(18,2)) END AS [For Every Qty],
	CASE ISNULL([DiscPer],'') WHEN '' THEN 0 ELSE CAST([DiscPer] AS NUMERIC(5,2)) END AS [Disc %],
	CASE ISNULL([FlatAmt],'') WHEN '' THEN 0 ELSE CAST([FlatAmt] AS NUMERIC(18,2)) END AS [Flat Amount],
	CASE ISNULL([Points],'') WHEN '' THEN 0 ELSE CAST([Points] AS NUMERIC(18,2)) END AS [Point],
	CASE ISNULL([FlxFreePrd],'') WHEN '' THEN 0 ELSE [FlxFreePrd] END AS [Flexi Free],
	CASE ISNULL([FlxGiftPrd],'') WHEN '' THEN 0 ELSE [FlxGiftPrd] END AS [Flexi Gift],
	CASE ISNULL([FlxDisc],'') WHEN '' THEN 0 ELSE [FlxDisc] END AS [Flexi Disc],
	CASE ISNULL([FlxValueDisc],'') WHEN '' THEN 0 ELSE [FlxValueDisc] END AS [Flexi Flat],
	CASE ISNULL([FlxPoints],'') WHEN '' THEN 0 ELSE [FlxPoints] END AS [Flexi Points],
	CASE ISNULL([MaxDiscount],'') WHEN '' THEN 0 ELSE CAST([MaxDiscount] AS NUMERIC(18,2)) END AS [Max Discount],
	CASE ISNULL([MinDiscount],'') WHEN '' THEN 0 ELSE CAST([MinDiscount] AS NUMERIC(18,2)) END AS [Min Discount],
	CASE ISNULL([MaxValue],'') WHEN '' THEN 0 ELSE CAST([MaxValue] AS NUMERIC(18,2)) END AS [Max Value],
	CASE ISNULL([MinValue],'') WHEN '' THEN 0 ELSE CAST([MinValue] AS NUMERIC(18,2)) END AS [Min Value],
	CASE ISNULL([MaxPoints],'') WHEN '' THEN 0 ELSE CAST([MaxPoints] AS NUMERIC(18,2)) END AS [Max Points],
	CASE ISNULL([MinPoints],'') WHEN '' THEN 0 ELSE CAST([MinPoints] AS NUMERIC(18,2)) END AS [Min Points]
	FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code],[SlabId]
	OPEN Cur_SchemeSlabDt
	FETCH NEXT FROM Cur_SchemeSlabDt INTO @SchCode,@SlabCode,@FromUOM,@FromQty,@ToUOM,@ToQty,@ForEveryUOM,
	@ForEveryQty,@DiscPer,@FlatAmt,@Points,@FlexiFree,@FlexiGift,@FlexiDisc,@FlexiFlat,@FlexiPoints,
	@MaxDisc,@MinDisc,@MaxValue,@MinValue,@MaxPoints,@MinPoints
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @CntVal=1
		SET @FromUomId=0
		SET @ToUomId=0
		SET @ForEveryUomId=0
		SET @TempStr=''
		SET @TempStr1=''
		DELETE FROM #TempTbl
		SELECT @MAXSLABID=MAX([SlabId])  FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE  [CmpSchCode]=@SchCode
		SET @Taction = 2
		SET @Po_ErrNo =0
		---->Modified By Nanda on 16/09/2009
		SET @SlabNotAppl=0
		IF (LTRIM(RTRIM(@SlabCode))= '---' OR LTRIM(RTRIM(@SlabCode))= '0')
		BEGIN						
			SET @SlabNotAppl=1
		END
		---->Till Here
		IF @SlabNotAppl=0
		BEGIN
			IF LTRIM(RTRIM(@SchCode))= ''
			BEGIN
				SET @ErrDesc = 'Company Scheme Code should not be blank'
				INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LEN(LTRIM(RTRIM(@SlabCode)))= 0
			BEGIN
				SET @ErrDesc = 'Slab Details should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			IF @Po_ErrNo=0
			BEGIN
				IF @ConFig<>1
				BEGIN
					IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
						@RangeId=Range,@CombiSch=CombiSch,@PurOfEvery=PurofEvery,@CmpPrdCtgId=SchLevelId  FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
						@RangeId=Range,@CombiSch=CombiSch,@PurOfEvery=PurofEvery,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END
					ELSE
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
						BEGIN
							IF NOT EXISTS(SELECT [CmpSchCode] FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE
							[CmpSchCode]=LTRIM(RTRIM(@SchCode)))
							BEGIN
								SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode +' in table Etl_Prk_SchemeHD_Slabs_Rules '
								INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
								B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
								SELECT @SchLevelId=C.CmpPrdCtgId,@FlexiId=A.FlexiSch,@CombiSch=A.CombiSch,
								@FlexiType=A.FlexiSchType,@SchType=A.SchType,@RangeId=A.Range
								FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
								INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
								AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
							END
						END
					ELSE
					BEGIN
						SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,
						@SchType=SchType,@RangeId=Range,@CombiSch=CombiSch,@CmpPrdCtgId=SchLevelId FROM Etl_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
				END
			END
			IF @Po_ErrNo=0
			BEGIN
				IF @FlexiId=1
				BEGIN
					SET @FlexiCnt=0
					IF LTRIM(RTRIM(@FlexiFree))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiGift))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiDisc))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiFlat))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiPoints))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF @FlexiCnt=5
					BEGIN
						SET @ErrDesc = 'Select Only Flexi Items for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'FLEXI SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
				IF @RangeId=1
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						IF LTRIM(RTRIM(@ToUOM))='0'
						BEGIN
							IF 	@MAXSLABID <> @SlabCode
							BEGIN
								SET @ErrDesc = 'To UOM Should Not Be Blank for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @MAXSLABID =@SlabCode
					BEGIN
						IF CONVERT(INT,@ToQty)>0
						BEGIN
							SET @ErrDesc = 'To Qty Should be ZERO for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
				IF @CombiSch=1
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							 SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
						END
						IF LTRIM(RTRIM(@ForEveryUOM))='0'
						BEGIN
							SET @ErrDesc = 'For Every UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							 SELECT @ForEveryUOMId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @PurOfEvery=1
					BEGIN
						IF LTRIM(RTRIM(@ForEveryQty))='0'
						BEGIN
							SET @ErrDesc = 'For Every Qty Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
				IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=0
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						IF LTRIM(RTRIM(@ForEveryUOM))='0'
						BEGIN
							SET @ErrDesc = 'For Every UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'NORMAL SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @PurOfEvery=1
					BEGIN
						IF LTRIM(RTRIM(@ForEveryQty))='0'
						BEGIN
							SET @ErrDesc = 'For Every Qty Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'NORMAL SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
			END
			IF @Po_ErrNo=0
			BEGIN
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @SchType<>4
				BEGIN
					IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=0
					BEGIN
						IF @SchType=1
						BEGIN
							IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
							END
							---->Modified By Nanda on 23/08/2009
							IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ForEveryUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
								END
							END
							ELSE
							BEGIN
								SET @ForEveryUomId=0
							END
							--->Till Here
						END
						ELSE IF @SchType=3
						BEGIN
							IF @MaxSchLevelId=@SchLevelId
							BEGIN
								IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (1) for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
									SET @FromUomId= ISNULL(@FromUomId,0)
								END
			
								---->Modified By Nanda on 23/08/2009
								IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
										SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
								END
							END
							ELSE
							BEGIN
								SET @sSQL=''
								IF @CntVal=(@MaxSchLevelId-@SchLevelId)
								BEGIN
									SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
								END
								ELSE
								BEGIN
									WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
									BEGIN
										IF @CntVal=1
										BEGIN
											SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
												  (SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
												   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
										END
			
											SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
											SET @TempStr1=@TempStr1+ ')'
										SET @CntVal=@CntVal+1	
										IF @CntVal=(@MaxSchLevelId-@SchLevelId)
										BEGIN
											IF ISNUMERIC(@GetKey)=1
											BEGIN									
												SET @sSQL=@sSQL + @TempStr +'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
											END
											ELSE
											BEGIN
												SET @sSQL=@sSQL + @TempStr +'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
											END																
										END
										
									END	
								END
								--Test		
								--SELECT @sSQL			
								EXEC(@sSQL)
								IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (2) for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
									SET @FromUomId= ISNULL(@FromUomId,0)
								END
					
								--->Modified By Nanda on 30/09/2010
								IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
								BEGIN
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
										SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
								END
								--->Till Here	
							END
						END
					END
					ELSE IF @FlexiId=1
					BEGIN
						IF @CombiSch=1
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
								---->Modified By Nanda on 23/08/2009
								IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
								BEGIN
									IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
									END
								END
								ELSE
								BEGIN
									SET @ForEveryUomId=0
								END
								---->Till Here
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (3) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
				
									--->Modified By Nanda on 30/09/2010
									IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
									BEGIN
										IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
										BEGIN
											IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
											BEGIN
												SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
												INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
												SET @Taction = 0
												SET @Po_ErrNo =1
											END
											ELSE
											BEGIN
												SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
												SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
											END
										END
										ELSE	
										BEGIN
											SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
										END
									END
									ELSE	
									BEGIN
										SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
									END
									--->Till Here	
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
			-- 								IF @CntVal<>1
			-- 								BEGIN
												SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
												SET @TempStr1=@TempStr1+ ')'
			-- 								END
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN				
												SET @sSQL=@sSQL + @TempStr +
												'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
												'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1	
												END	
											END
										END		
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (4) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
									--->Modified By Nanda on 30/09/2010
									IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
									BEGIN
										IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
										BEGIN
											SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
											INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
											SET @Taction = 0
											SET @Po_ErrNo =1
										END
										ELSE
										BEGIN
											SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
											SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
										END
									END
									BEGIN
										SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
									END
									--->Till Here
								END
							END
						END
						ELSE IF @RangeId=1
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM)))
								BEGIN
									SET @ErrDesc = 'To Uom:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'To UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ToUomId=ISNULL(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM))
								END
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (5) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN															
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
				
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
									BEGIN
										SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
										SET @ToUomId=ISNULL(@ToUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
			-- 								IF @CntVal<>1
			-- 								BEGIN
												SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
												SET @TempStr1=@TempStr1+ ')'
			-- 								END
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN					
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												ELSE
												BEGIN					
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
												END		
											END
										END	
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (6) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
									BEGIN
										SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
										SET @ToUomId= ISNULL(@ToUomId,0)
									END
								END
							END
						END
						ELSE
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (7) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0)FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
											SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
											SET @TempStr1=@TempStr1+ ')'
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												ELSE
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
												END																						
											END
										END		
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (8) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
								END
							END
						END
					END
				ELSE IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=1
				BEGIN
					IF @SchType=3
					BEGIN
						
						IF @MaxSchLevelId=@SchLevelId
						BEGIN
							IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (9) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
								SET @FromUomId= ISNULL(@FromUomId,0)
							END
			
							IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
							BEGIN
								SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
								SET @ToUomId=ISNULL(@ToUomId,0)
							END
			
							--Test
							IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
							BEGIN
								IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
									SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
								END
							END
							ELSE
							BEGIN
								SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
							END
						END
						ELSE
						BEGIN
							SET @sSQL=''
							IF @CntVal=(@MaxSchLevelId-@SchLevelId)
							BEGIN
								SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
							END
							ELSE
							BEGIN
								WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
								BEGIN
									IF @CntVal=1
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
												  (SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
											   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
									END
									
			-- 						IF @CntVal<>1
			-- 						BEGIN
										SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
										SET @TempStr1=@TempStr1+ ')'
			-- 						END
									SET @CntVal=@CntVal+1
									
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										IF ISNUMERIC(@GetKey)=1
										BEGIN				
										SET @sSQL=@sSQL + @TempStr +
										'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
											ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
										END
										ELSE
										BEGIN				
										SET @sSQL=@sSQL + @TempStr +
										'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
											ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
										END
									END
								END	
							END			
							EXEC(@sSQL)
							IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (10) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
								SET @FromUomId= ISNULL(@FromUomId,0)
							END
			
							IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@ToUOM+' not Found (11) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
								SET @ToUomId= ISNULL(@FromUomId,0)
							END
							--->Modified By Nanda on 30/09/2010
							IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
							BEGIN
								IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									
									SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN						
									SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
									SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
								END
							END
							ELSE
							BEGIN						
								SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
							END
							--->Till Here
						END
					END
					ELSE IF @SchType=1
					BEGIN
						IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
						BEGIN
							SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
							SET @ToUomId= ISNULL(@ToUomId,0)
						END
						IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM)))
						BEGIN
							SET @ErrDesc = 'To Uom:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'To UOM',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @ToUomId=ISNUll(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM))
							SET @ToUomId= ISNULL(@ToUomId,0)
						END
						---->Modified By Nanda on 23/08/2009
						IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)
						BEGIN
							IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
							BEGIN
								SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ForEveryUomId=ISNUll(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
								SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
							END
						END
						ELSE
						BEGIN
							SET @ForEveryUomId=0
						END
						--->Till Here	
					END
				END
			END
			IF @SchType<>4
			BEGIN
				IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
				END
				
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					SET @Taction=0
				END
				ELSE
				BEGIN
					IF @CombiSch=0 AND @FlexiId=0 AND @RangeId=0
					BEGIN
		  				IF   @SchType=2
						BEGIN
							SET @ForEveryUomId=0
							SET @ToUomId=0
							SET @FromUomId=0
						END
						SET @ToUomId=0
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
									DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
									0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),convert(INT,@FlexiPoints),convert(NUMERIC(18,2),@Points),1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
									0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--						SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--						INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
								0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
								@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
					
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(8)) + ',' + CAST(@FromQty AS VARCHAR(8)) + ',' + CAST(0 AS VARCHAR(8)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(8)) + ',' + CAST(0 AS VARCHAR(8)) + ',' + CAST(@ToUomId AS VARCHAR(8)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(8)) + ',' + CAST(@ForEveryUomId AS VARCHAR(8)) + ',' + CAST(@DiscPer AS VARCHAR(8)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(8)) + ',' + CAST(@FlexiDisc AS VARCHAR(8)) + ',' + CAST(@FlexiFlat AS VARCHAR(8)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(8)) + ',' + CAST(@FlexiGift AS VARCHAR(8)) + ',' + CAST(@FlexiPoints AS VARCHAR(8)) + ',' + CAST(@Points AS VARCHAR(8)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
							
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
							0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),convert(INT,@FlexiPoints),convert(NUMERIC(18,2),@Points),1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE IF @FlexiId=1 AND @RangeId=0 AND @CombiSch=0
					BEGIN
						IF @FlexiType=1 OR @FlexiType=2
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
										DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 								SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
						
										INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
										ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
										Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
										MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
										0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
										convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
										1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
						
		-- -- 								SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- -- 								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- -- 								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- -- 								MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- -- 								',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- -- 								CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- -- 								CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- -- 								INSERT INTO Translog(strSql1) Values (@sSQL)
									END
									ELSE
									BEGIN
										DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		-- 								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
										INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
										ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
										Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
										VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
										0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
										@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
		-- 					
		-- 								SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 								MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 								CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 								CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 								CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 								CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 								CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 								',0,0,0,0,0,0,''N'')'
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
										SET @Po_ErrNo =0
									END
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
									0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
								MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
								0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
								convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
								1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 						CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 						CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
							END
						END
					END
					ELSE IF @CombiSch=1 AND @FlexiId=0
					BEGIN
						
						IF NOT EXISTS(SELECT SchId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode)
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
				
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
							0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					IF EXISTS(SELECT SchId FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode)
		-- 					BEGIN
		-- 						DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabCombiPrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 		
		-- 						INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT @GetKey AS SchId,@SlabCode AS SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,@FromQty AS SlabValue,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121)
		-- 						FROM SchemeProducts WHERE SchId=@GetKey
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT ' + CAST(@GetKey AS VARCHAR(10)) + 'AS SchId,'+ CAST(@SlabCode AS VARCHAR(10)) + 'AS SlabId,
		-- 						PrdCtgValMainId,PrdId,PrdBatId' + CAST(@FromQty AS VARCHAR(10)) + 'AS SlabValue,1,1,
		-- 						''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + '''
		-- 						FROM SchemeProducts WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					END
						END
		-- 				ELSE
		-- 				BEGIN
		-- 					IF EXISTS(SELECT SchId FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode)
		-- 					BEGIN
		-- 						DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabCombiPrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 		
		-- 						INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT @GetKey AS SchId,@SlabCode AS SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,@FromQty AS SlabValue,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121)
		-- 						FROM SchemeProducts WHERE SchId=@GetKey
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT ' + CAST(@GetKey AS VARCHAR(10)) + 'AS SchId,'+ CAST(@SlabCode AS VARCHAR(10)) + 'AS SlabId,
		-- 						PrdCtgValMainId,PrdId,PrdBatId' + CAST(@FromQty AS VARCHAR(10)) + 'AS SlabValue,1,1,
		-- 						''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + '''
		-- 						FROM SchemeProducts WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					END
		-- 				END
					END
					ELSE IF @RangeId=0
					BEGIN
						DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 				SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 				' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 				INSERT INTO Translog(strSql1) Values (@sSQL)
						SET @TempRange=0
			
						INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
						MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),convert(NUMERIC(18,2),@TempRange),@FromUomId,
						0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
						convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
						1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
			
		-- 				SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 				ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 				Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 				MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 				CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' +
		-- 				CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 				CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 				CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 				CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 				',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 				INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF (@FlexiId=1 AND @CombiSch=1) OR (@FlexiId=1 AND @RangeId=1)
					BEGIN
						---->Modified By Nanda on 23/08/2009
						IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
						END
						---->Till Here
		--				SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		--				' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--				INSERT INTO Translog(strSql1) Values (@sSQL)
						IF @RangeId=1
						BEGIN
							SET @TempRange=0
						END
						ELSE
						BEGIN
							SET @TempRange=@FromQty
						END
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
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@TempRange),convert(NUMERIC(18,2),@FromQty),@FromUomId,
									convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 							CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 							CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- 			
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
								END
								ELSE
								BEGIN
															DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
									@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
--								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
--								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
--								INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
								@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
								@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
					
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@TempRange),convert(NUMERIC(18,2),@FromQty),@FromUomId,
							convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 					CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 					CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE IF @FlexiId=0 AND @RangeId=1 AND @CombiSch=0
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
									DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,0,convert(NUMERIC(18,2),@FromQty),@FromUomId,
									convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- -- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- -- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- -- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
									SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
									' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
									INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
									@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
								INSERT INTO Translog(strSql1) Values (@sSQL)
							
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,CAST(@SlabCode AS INT),0,CAST(@FromQty AS INT),CAST(@FromUomId AS INT),
								CAST(@ToQty AS INT),CAST(@ToUomId AS INT),CAST(@ForEveryQty As INT),CAST(@ForEveryUomId AS INT),CAST(@DiscPer AS NUMERIC(38,6)),CAST(@FlatAmt AS NUMERIC(38,6)),CAST(@FlexiDisc AS INT),CAST(@FlexiFlat AS INT),
								CAST(@FlexiFree AS INT),CAST(@FlexiGift AS INT),CAST(@FlexiPoints AS INT),CAST(@Points AS INT),0,0,0,0,0,0,'NO')
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
							
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,0,convert(NUMERIC(18,2),@FromQty),@FromUomId,
							convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
						END					
					END
				END
			END
		END
	END
	
	FETCH NEXT FROM Cur_SchemeSlabDt INTO  @SchCode,@SlabCode,@FromUOM,@FromQty,@ToUOM,@ToQty,@ForEveryUOM,
		@ForEveryQty,@DiscPer,@FlatAmt,@Points,@FlexiFree,@FlexiGift,@FlexiDisc,@FlexiFlat,@FlexiPoints,
		@MaxDisc,@MinDisc,@MaxValue,@MinValue,@MaxPoints,@MinPoints
	END
	CLOSE Cur_SchemeSlabDt
	DEALLOCATE Cur_SchemeSlabDt
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeRulesetting' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeRulesetting
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeRulesetting 0
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeRulesetting
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_BLSchemeRulesetting
* PURPOSE		: To Insert and Update records in the Table Etl_Prk_SchemeRuleSettings_Temp,
				  Etl_Prk_SchemeRtrLevelValidation_Temp
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/01/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}         {developer}      {brief modification description}
* 09-Apr-2010    Jayakumar N      Change done based on "Rtr Cap" in SchConfig column in table Etl_Prk_SchemeRuleSettings.
				 Based on "Rtr Cap" value updated in respective columns NoOfRtr and RtrCount in SchemeruleSettings table
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 		AS INT
	DECLARE @Tabname AS     NVARCHAR(100)
	DECLARE @DestTabname AS NVARCHAR(100)
	DECLARE @Fldname AS     NVARCHAR(100)

	DECLARE @CmpSchCode AS NVARCHAR(200)
	DECLARE @SchConfig AS NVARCHAR(200)
	DECLARE @SchRules AS NVARCHAR(200)
	DECLARE @NoofBills AS NVARCHAR(200)
	DECLARE @FromDate AS NVARCHAR(200)
	DECLARE @ToDate AS NVARCHAR(200)
	DECLARE @MarketVisit AS NVARCHAR(200)
	DECLARE @ApplySchBasedOn AS NVARCHAR(200)
	DECLARE @EnableRtrLvl AS NVARCHAR(200)
	DECLARE @AllowSaving AS NVARCHAR(200)
	DECLARE @AllowSelection AS NVARCHAR(200)

	DECLARE @RtrCode AS NVARCHAR(200)
	DECLARE @RtrFromDate AS NVARCHAR(200)
	DECLARE @RtrToDate AS NVARCHAR(200)
	DECLARE @BudgetAllocated AS NVARCHAR(200)
	DECLARE @Status AS NVARCHAR(200)

	DECLARE @SchId AS INT
	DECLARE @SchConfigId AS INT
	DECLARE @SchRulesId AS INT
	DECLARE @ApplySchBasedOnId AS INT
	DECLARE @EnableRtrLvlId AS INT
	DECLARE @AllowSavingId AS INT
	DECLARE @AllowSelectionId AS INT

	DECLARE @RtrId AS INT
	DECLARE @StatusId AS INT

	DECLARE @SchLevelId 	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @GetKey 	AS INT
	DECLARE @GetKeyCode	AS VARCHAR(200)
	DECLARE @CmpId 		AS INT
	DECLARE @SLevel		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SlNo 		AS INT
	DECLARE @RtrAttrCnt	AS INT
	DECLARE @RtrLvlCnt	AS INT

	DECLARE @SchWithOutPrd AS INT	
	
	SET @DestTabname='SchemeRuleSetting'
	SET @Fldname='SchConfig'
	SET @Tabname = 'Etl_Prk_SchemeRuleSettings_Temp'
	SET @Exist=0
	SET @Po_ErrNo=0

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'

	DECLARE Cur_SchemeRules CURSOR
	FOR SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,ISNULL(SchConfig,''),ISNULL(SchRules,''),ISNULL(NoofBills,''),ISNULL(SchValidFrom,''),ISNULL(SchValidTill,''),
	ISNULL(MarketVisit,''),ISNULL(ApplySchBasedOn,''),ISNULL(EnableRtrLvl,''),ISNULL(AllowSaving,''),ISNULL(AllowSelection,'')
	FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY CmpSchCode
	OPEN Cur_SchemeRules

	FETCH NEXT FROM Cur_SchemeRules INTO @CmpSchCode,@SchConfig,@SchRules,@NoofBills,
	@FromDate,@ToDate,@MarketVisit,@ApplySchBasedOn,@EnableRtrLvl,@AllowSaving,@AllowSelection
	WHILE @@FETCH_STATUS=0
	BEGIN		

		SET @Po_ErrNo=0

		IF LTRIM(RTRIM(@CmpSchCode))=''
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',
			'Company Scheme Code should not be empty')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @SchId=SchId,@SchLevelId=SchLevelId FROM SchemeMaster
			WHERE CmpSchCode=@CmpSchCode
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@SchConfig))='---'
			BEGIN
				CLOSE Cur_SchemeRules
				DEALLOCATE Cur_SchemeRules
				Return
			END
			IF LTRIM(RTRIM(@SchConfig))='YES'
			BEGIN
				SET @SchConfigId=1
			END
			ELSE 
			BEGIN
				SET @SchConfigId=0
			END

		END
		
		IF @SchConfigId=1 AND @Po_ErrNo=0
		BEGIN			
			IF LTRIM(RTRIM(@SchRules))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Rules',
				'Scheme Rules should not be empty for Scheme Code:'+@CmpSchCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				IF LTRIM(RTRIM(@SchRules))='PRODUCT'
				BEGIN
					SET @SchRulesId=0
				END
				ELSE IF LTRIM(RTRIM(@SchRules))='BILL'
				BEGIN
					SET @SchRulesId=1
				END	
				ELSE IF LTRIM(RTRIM(@SchRules))='DATE'
				BEGIN
					SET @SchRulesId=2
				END
				ELSE IF LTRIM(RTRIM(@SchRules))='MARKET'
				BEGIN
					SET @SchRulesId=3
				END			
			END
	
			IF @Po_ErrNo=0
			BEGIN
				IF @SchRulesId=1
				BEGIN
					IF NOT ISNUMERIC(@NoofBills)=1 
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme No Of Bills',
						'Scheme No Of Bills should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
					ELSE IF @NoofBills<=0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme No Of Bills',
						'Scheme No Of Bills should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END	
				END
				ELSE IF @SchRulesId=2
				BEGIN
					IF @Po_ErrNo=0
					BEGIN
						IF ISDATE(@FromDate)=1 AND ISDATE(@ToDate)=1
						BEGIN
							IF DATEDIFF(DD,@FromDate,@ToDate)<0 OR @ToDate< CONVERT(NVARCHAR(10),GETDATE(),121)
							BEGIN
								INSERT INTO Errorlog VALUES (1,@TabName,'Date',
								'From Date should be less than To Date for Scheme Code:'+@CmpSchCode)           	
								SET @Po_ErrNo=1
							END
						END
						ELSE
						BEGIN
							INSERT INTO Errorlog VALUES (1,@TabName,'Date',
							'Either From Date or To Date is wrong for Scheme Code:'+@CmpSchCode)           	
							SET @Po_ErrNo=1
						END
					END	
				END
				IF @SchRulesId=3
				BEGIN
					IF ISNUMERIC(@MarketVisit)=1 
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Market Visits',
						'Scheme Market Visits should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
					ELSE IF @MarketVisit<=0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme No Of Bills',
						'Scheme Market Visits should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
				END
			END
	
			IF @Po_ErrNo=0
			BEGIN
				IF LTRIM(RTRIM(@ApplySchBasedOn))=''
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme-Apply Based On',
					'Scheme-Apply Based On Rules should not be empty for Scheme Code:'+@CmpSchCode)
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					IF LTRIM(RTRIM(@ApplySchBasedOn))='Company'
					BEGIN
						SET @ApplySchBasedOnId=0
					END
					ELSE IF LTRIM(RTRIM(@ApplySchBasedOn))='Retailer'
					BEGIN
						SET @ApplySchBasedOnId=1
					END	
					ELSE IF LTRIM(RTRIM(@ApplySchBasedOn))='JC'
					BEGIN
						SET @ApplySchBasedOnId=2
					END
				END	
			END
		END
		ELSE
		BEGIN
			SET @SchRulesId=-1
			SET @ApplySchBasedOnId=-1		
			SET @MarketVisit=-1		

			IF UPPER(@SchConfig)<>UPPER('Rtr Cap')
			BEGIN
				SET @NoofBills=-1					
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@EnableRtrLvl))='Yes'
			BEGIN
				SET @EnableRtrLvlId=1					
			END
			ELSE
			BEGIN
				SET @EnableRtrLvlId=0
			END
		END
			
		IF @Po_ErrNo=0
		BEGIN
			IF @EnableRtrLvlId=1
			BEGIN
				IF NOT EXISTS (SELECT * FROM Etl_Prk_Scheme_RetailerLevelValid WHERE CmpSchCode=@CmpSchCode)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Level Validation',
					'Retailer not found for Scheme Code:'+@CmpSchCode)
					SET @Po_ErrNo =1
				END
				IF LTRIM(RTRIM(@AllowSaving))='Yes'
				BEGIN
					SET @AllowSavingId=1					
				END
				ELSE
				BEGIN
					SET @AllowSavingId=0					
				END

				IF LTRIM(RTRIM(@AllowSelection))='Yes'
				BEGIN
					SET @AllowSelectionId=1					
				END
				ELSE
				BEGIN
					SET @AllowSelectionId=0					
				END

			END
			ELSE
			BEGIN
				SET @AllowSavingId=0
				SET @AllowSelectionId=0
			END
		END
		
		
		---Insert Rule
		IF @ConFig<>1
		BEGIN
			IF NOT EXISTS(SELECT SchId FROM SchemeMaster 
			WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode)))
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',
				'Company Scheme Code not found')
				SET @Exist=0
				SET @Po_ErrNo =1
			END
			ELSE
			BEGIN
				SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))
				SELECT @CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))
				SET @Po_ErrNo =0
				IF EXISTS(SELECT * FROM SchemeRuleSettings WHERE SchId=@GetKey)
				BEGIN
					SET @Exist=1
				END
				ELSE
				BEGIN
					SET @Exist=0
				END
			END
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT SchId FROM SchemeMaster 
			WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode)))
			BEGIN
				SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster 
				WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))

				SELECT @CmpPrdCtgId=SchLevelId FROM SchemeMaster 
				WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))

				IF EXISTS(SELECT * FROM SchemeRuleSettings WHERE SchId=@GetKey)
				BEGIN
					SET @Exist=1
				END
				ELSE
				BEGIN
					SET @Exist=0
				END
				SET @Po_ErrNo =0
			END
			ELSE IF EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
				CmpSchCode=LTRIM(RTRIM(@CmpSchCode)) AND UpLoadFlag='N')
			BEGIN
				SELECT @GetKeyCode=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
				CmpSchCode=LTRIM(RTRIM(@CmpSchCode))

				SELECT @CmpPrdCtgId=SchLevelId
				FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))
				IF EXISTS(SELECT * FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode)))
				BEGIN
					SET @Exist=1
				END
				ELSE
				BEGIN
					SET @Exist=0
				END
			END	
		END		
		
		IF @ConFig=1
		BEGIN	
			SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
			IF @CmpPrdCtgId<@SLevel
			BEGIN
				SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
				WHERE A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode)) --AND UPPER(A.[SchLevel])='NO'
				AND A.SlabId=0 AND A.SlabValue=0

				SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
				WHERE A.[PrdCode] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
				A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode)) --AND UPPER(A.[SchLevel])='NO'
				AND A.SlabId=0 AND A.SlabValue=0
			END
			ELSE
			BEGIN
				SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
				WHERE A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode)) --AND UPPER(A.[SchLevel])='YES'
				AND A.SlabId=0 AND A.SlabValue=0

				SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
				WHERE A.[PrdCode] IN (SELECT PrdCCode FROM Product)
				AND  A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode)) --AND UPPER(A.[SchLevel])='YES'
				AND A.SlabId=0 AND A.SlabValue=0
			END

			IF @EtlCnt=@CmpCnt
			BEGIN	
				SELECT @EtlCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
				WHERE A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode))

				SELECT @CmpCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
				INNER JOIN Product B ON A.[PrdCode]=b.PrdCCode
				WHERE A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode))

				IF @EtlCnt=@CmpCnt
				BEGIN
					SET @SchWithOutPrd=1
				END
				ELSE
				BEGIN
					SET @SchWithOutPrd=2
				END	
			END
			ELSE
			BEGIN
				SET @SchWithOutPrd=2
			END	
		END
		ELSE
		BEGIN
			SET @SchWithOutPrd=1		
		END
		---		
		IF @Exist=0 AND @SchWithOutPrd=1   
		BEGIN
			INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,
			FromDate,ToDate,MarketVisit,ApplySchBasedOn,EnableRtrLvl,AllowSaving,
			AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,NoOfRtr,RtrCount)
			VALUES(@GetKey,@SchConfigId,@SchRulesId,
			CASE UPPER(@SchConfig) WHEN UPPER('Rtr Cap') THEN -1 ELSE @NoofBills END ,
			@FromDate,@ToDate,@MarketVisit,@ApplySchBasedOnId,
			CASE UPPER(@SchConfig) WHEN UPPER('Rtr Cap') THEN 1 ELSE @EnableRtrLvlId END,
			@AllowSavingId,@AllowSelectionId,1,1,GETDATE(),1,GETDATE(),
			CASE UPPER(@SchConfig) WHEN UPPER('Rtr Cap') THEN 1 ELSE 0 END,
			CASE UPPER(@SchConfig) WHEN UPPER('Rtr Cap') THEN @NoofBills ELSE 0 END)
		END

		IF @Exist=1 AND @SchWithOutPrd=1
		BEGIN
			UPDATE SchemeRuleSettings SET SchConfig=@SchConfigId,SchRules=@SchRulesId,
			NoofBills=@NoofBills,FromDate=@FromDate,ToDate=@ToDate,MarketVisit=@MarketVisit,
			ApplySchBasedOn=@ApplySchBasedOnId,EnableRtrLvl=@EnableRtrLvlId,AllowSaving=@AllowSavingId
			WHERE SchId=@GetKey			
		END
		IF @Exist=0 AND @SchWithOutPrd=2
		BEGIN
			INSERT INTO Etl_Prk_SchemeRuleSettings_Temp(CmpSchCode,SchConfig,SchRules,NoofBills,
			FromDate,ToDate,MarketVisit,ApplySchBasedOn,EnableRtrLvl,AllowSaving,AllowSelection)
			VALUES(@CmpSchCode,@SchConfigId,@SchRulesId,@NoofBills,@FromDate,@ToDate,
			@MarketVisit,@ApplySchBasedOnId,@EnableRtrLvlId,@AllowSavingId,
			@AllowSelectionId)
		END
		IF @Exist=1 AND @SchWithOutPrd=2
		BEGIN
			UPDATE Etl_Prk_SchemeRuleSettings_Temp SET SchConfig=@SchConfigId,
			SchRules=@SchRulesId,NoofBills=@NoofBills,FromDate=@FromDate,ToDate=@ToDate,
			MarketVisit=@MarketVisit,ApplySchBasedOn=@ApplySchBasedOnId,
			EnableRtrLvl=@EnableRtrLvlId,AllowSaving=@AllowSavingId
			WHERE CmpSchCode=@CmpSchCode			
		END

		IF @EnableRtrLvlId=1 AND @Po_ErrNo=0
		BEGIN
			DECLARE Cur_SchemeRulesRetailer CURSOR
			FOR SELECT ISNULL(RtrCode,''),ISNULL(FromDate,''),ISNULL(ToDate,''),
			ISNULL(BudgetAllocated,''),ISNULL(Status,'')
			FROM Etl_Prk_Scheme_RetailerLevelValid WHERE CmpSchCode=@CmpSchCode
	
			OPEN Cur_SchemeRulesRetailer
		
			FETCH NEXT FROM Cur_SchemeRulesRetailer INTO @RtrCode,@RtrFromDate,@RtrToDate,
			@BudgetAllocated,@Status
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF LTRIM(RTRIM(@RtrCode))=''
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',
					'Retailer Code should not be empty for Scheme Code:'+@CmpSchCode)
					SET @Po_ErrNo=1
				END

				IF @Po_ErrNo=0
				BEGIN
					IF NOT EXISTS(SELECT * FROM Retailer WITH (NOLOCK)
					WHERE RtrCode=@RtrCode)
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Retailer',
						'Retailer : '+@RtrCode+' is not available for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						SELECT @RtrId=RtrId FROM Retailer WITH (NOLOCK)
						WHERE RtrCode=@RtrCode
					END
				END		
				IF @Po_ErrNo=0
				BEGIN
					IF EXISTS(SELECT * FROM Etl_Prk_Scheme_OnAttributes WHERE 
						CmpSchCode=@CmpSchCode AND AttrType='RETAILER' AND AttrName<> 'ALL')
					BEGIN
						IF NOT EXISTS(SELECT * FROM Etl_Prk_Scheme_OnAttributes WHERE 
						CmpSchCode=@CmpSchCode AND AttrType='RETAILER' AND AttrName=@RtrCode)
						BEGIN
							INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Level Validation',
							'Retailer Mismatch for Scheme Code:'+@CmpSchCode)
							SET @Po_ErrNo =1
						END	
					END
				END
				IF @Po_ErrNo=0
				BEGIN
					IF ISDATE(@RtrFromDate)=1 AND ISDATE(@RtrToDate)=1
					BEGIN
						IF DATEDIFF(DD,@RtrFromDate,@RtrToDate)<0 OR @RtrToDate< CONVERT(NVARCHAR(10),GETDATE(),121)
						BEGIN
							INSERT INTO Errorlog VALUES (1,@TabName,'Date',
							'From Date should be less than To Date for Scheme Code:'+@CmpSchCode)           	
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Either From Date or To Date is wrong for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
				END
				
				IF @Po_ErrNo=0
				BEGIN
					IF (DATEDIFF(DD,@FromDate,@RtrFromDate)<0 OR DATEDIFF(DD,@RtrFromDate,@ToDate)<0)
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Retailer From Date should be within From and To Date for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
					
					IF (DATEDIFF(DD,@FromDate,@RtrToDate)<0 OR DATEDIFF(DD,@RtrToDate,@ToDate)<0)
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Retailer To Date should be within From and To Date for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
				END
				
				IF @Po_ErrNo=0
				BEGIN
					IF NOT ISNUMERIC(@BudgetAllocated)=1 
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Budget Allocated',
						'Budget Allocated should be numeric value for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
					ELSE IF @BudgetAllocated<=0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme No Of Bills',
						'Budget Allocated should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
				END

				IF @Po_ErrNo=0
				BEGIN				
					IF LTRIM(RTRIM(@Status))=''
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Status',
						'Retailer Status should not be empty for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						IF LTRIM(RTRIM(@Status))='Active'
						BEGIN
							SET @StatusId=1					
						END
						ELSE
						BEGIN
							SET @StatusId=0					
						END
					END
				END	

				IF @Exist=0 AND @SchWithOutPrd=1
				BEGIN
					INSERT INTO SchemeRtrLevelValidation(SchId,RtrId,FromDate,ToDate,
					BudgetAllocated,BudgetUtilized,BudgetAvailable,Status,Slno,
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@GetKey,@RtrId,@RtrFromDate,@RtrToDate,
					@BudgetAllocated,0,0,@StatusId,@SlNo,1,1,GETDATE(),1,GETDATE())
				
				END
				IF @Exist=1 AND @SchWithOutPrd=1
				BEGIN
					UPDATE SchemeRtrLevelValidation SET FromDate=@FromDate,ToDate=@ToDate,
					BudgetAllocated=@BudgetAllocated,BudgetAvailable=@BudgetAllocated-BudgetUtilized,
					Status=@StatusId
					WHERE SchId=@GetKey AND RtrId=@RtrId			 
				END
				IF @Exist=0 AND @SchWithOutPrd=2
				BEGIN
					INSERT INTO Etl_Prk_SchemeRtrLevelValidation_Temp(CmpSchCode,RtrId,
					RtrCode,FromDate,ToDate,BudgetAllocated,BudgetUtilized,BudgetAvailable,
					Status,Slno)
					VALUES(@CmpSchCode,@RtrId,@RtrCode,@RtrFromDate,@RtrToDate,@BudgetAllocated,
					0,0,@Status,@Slno)
				END
				IF @Exist=1 AND @SchWithOutPrd=2
				BEGIN
					UPDATE Etl_Prk_SchemeRtrLevelValidation_Temp SET FromDate=@FromDate,
					ToDate=@ToDate,BudgetAllocated=@BudgetAllocated,Status=@Status
					WHERE CmpSchCode=@CmpSchCode AND RtrCode=@RtrCode			
				END

				FETCH NEXT FROM Cur_SchemeRulesRetailer INTO @RtrCode,@RtrFromDate,@RtrToDate,@BudgetAllocated,@Status
			END
			CLOSE Cur_SchemeRulesRetailer
			DEALLOCATE Cur_SchemeRulesRetailer
		END				
		FETCH NEXT FROM Cur_SchemeRules INTO @CmpSchCode,@SchConfig,@SchRules,@NoofBills,@FromDate,@ToDate,
		@MarketVisit,@ApplySchBasedOn,@EnableRtrLvl,@AllowSaving,@AllowSelection
	END

	CLOSE Cur_SchemeRules
	DEALLOCATE Cur_SchemeRules
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeFreeProducts' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeFreeProducts
GO
/*
BEGIN TRANSACTION
DELETE FROM SchemeSlabMultiFrePrds
EXEC Proc_Cn2Cs_BLSchemeFreeProducts 0
SELECT * FROM ErrorLog
SELECT * FROM SchemeSlabMultiFrePrds
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeFreeProducts
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeFreeProducts    1
* PURPOSE: To Insert and Update Scheme Slab Free/Gift Products
* CREATED: Boopathy.P on 05/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode AS VARCHAR(50)
	DECLARE @SlabCode AS VARCHAR(50)
	DECLARE @Condition AS VARCHAR(50)
	DECLARE @PrdCode AS VARCHAR(150)
	DECLARE @Qty  AS INT
	DECLARE @TypeCode AS VARCHAR(50)
	DECLARE @PrdId  AS VARCHAR(50)
	DECLARE @CondId  AS INT
	DECLARE @TypeId  AS INT
	DECLARE @CmpId  AS INT
	DECLARE @SlabId  AS INT
	DECLARE @SchLevelId AS INT
	DECLARE @EtlCnt AS INT
	DECLARE @CmpCnt AS INT
	DECLARE @SchType AS INT
	DECLARE @SLevel AS INT
	DECLARE @FlexiId AS INT
	DECLARE @SeqId	AS INT
	DECLARE @RangeId AS INT
	DECLARE @FlexiType AS INT
	DECLARE @CombiSch AS INT
	DECLARE @PrevSlabId AS INT
	DECLARE @ChkCount AS INT
	DECLARE @ErrDesc  AS VARCHAR(1000)
	DECLARE @TabName  AS VARCHAR(50)
	DECLARE @GetKey  AS NVARCHAR(200)
	DECLARE @GetKeyCode	AS	NVARCHAR(200)
	DECLARE @PrvSchCode	AS	NVARCHAR(200)
	DECLARE @Taction  AS INT
	DECLARE @Cnt  AS INT
	DECLARE @TypeCnt AS INT
	DECLARE @ConFig   	AS INT
	DECLARE @sSQL   AS VARCHAR(4000)
	SET @TabName = 'Etl_Prk_Scheme_Free_Multi_Products'
	SET @Po_ErrNo =0
	SET @PrevSlabId=0
	SET @Cnt=0

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'

	SET @PrvSchCode=''

	DECLARE Cur_SchemeSlabFreePrds CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],
	ISNULL([SlabId],'0') AS [SlabId],
	ISNULL([OpnANDOR],'') AS [Condition],
	ISNULL([PrdCode],'') AS [Product Code],
	ISNULL([FreeQty],0) AS [Qty],
	ISNULL([Type],'') AS [Type]	
	FROM Etl_Prk_Scheme_Free_Multi_Products 
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code],[SlabId]

	OPEN Cur_SchemeSlabFreePrds
	FETCH NEXT FROM Cur_SchemeSlabFreePrds INTO @SchCode,@SlabCode,@Condition,@PrdCode,@Qty,@TypeCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0

		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SlabCode))= ''
		BEGIN
			SET @ErrDesc = 'Slab Details should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Condition))= ''
		BEGIN
			SET @ErrDesc = 'Condition should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Condition',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Condition)))<> 'OR' AND UPPER(LTRIM(RTRIM(@Condition)))<> 'AND'
		AND UPPER(LTRIM(RTRIM(@Condition)))<> '0'
		BEGIN
			SET @ErrDesc = 'Condition should be (OR/AND/0) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Condition',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF UPPER(LTRIM(RTRIM(@Condition)))= 'OR'
		BEGIN
			SET @CondId=1
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Condition)))= 'AND'
		BEGIN
			SET @CondId=2
		END
		ELSE
		BEGIN
			SET @CondId=3
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
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
					@RangeId=Range,@CombiSch=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SET @Po_ErrNo =0
				END
	
				IF NOT EXISTS(SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
				BEGIN
					SET @ErrDesc = 'Product Code:'+@PrdCode+' not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
				END
				IF NOT EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
				BEGIN
					SET @ErrDesc = 'Slab Details not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND
					SlabId=LTRIM(RTRIM(@SlabCode))
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
					@RangeId=Range,@CombiSch=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SET @Po_ErrNo =0
				END
				ELSE IF EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
				BEGIN
					SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
					@RangeId=Range,@CombiSch=CombiSch FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	
				ELSE
				BEGIN
					SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
					B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=C.CmpPrdCtgId,@CombiSch=A.CombiSch
					FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
					INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
					AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
				IF EXISTS(SELECT * FROM Etl_Prk_SchemeSlabs_Temp
					WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N' AND SlabId=CAST(LTRIM(RTRIM(@SlabCode)) AS INT))
				BEGIN
					SELECT @SlabId=SlabId FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND
					UpLoadFlag='N' AND SlabId=CAST(LTRIM(RTRIM(@SlabCode)) AS INT)
				END
				ELSE IF ISNUMERIC(@GetKey)>0
				BEGIN
					IF EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=CAST(@GetKey AS INT) AND SlabId=CAST(LTRIM(RTRIM(@SlabCode)) AS INT))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=CAST(@GetKey AS INT) AND
						SlabId=CAST(LTRIM(RTRIM(@SlabCode)) AS INT)
					END
				END
				IF EXISTS(SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
				BEGIN
					SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
				END
				ELSE
				BEGIN
					SET @PrdId=LTRIM(RTRIM(@PrdCode))
				END
			END

			--->Modified By Nanda on 08/09/2010
--			SELECT @PrvSchCode,@SchCode
--			IF LTRIM(RTRIM(@PrvSchCode))=''
--			BEGIN
--				--SET @PrvSchCode=@SchCode
--				SET @SeqId=1
--			END
--			ELSE IF LTRIM(RTRIM(@PrvSchCode))=LTRIM(RTRIM(@SchCode))
--			BEGIN
--				SET @SeqId = @SeqId +1				
--			END
--			ELSE
--			BEGIN
--				SET @SeqId=1				
--			END			

			IF LTRIM(RTRIM(@PrvSchCode))=''
			BEGIN
				IF @PrevSlabId=0 
				BEGIN
					SET @PrvSchCode=LTRIM(RTRIM(@SchCode))
					SET @PrevSlabId=@SlabId
					SET @SeqId=1
				END
				ELSE IF @PrevSlabId=@SlabId
				BEGIN
					SET @PrvSchCode=LTRIM(RTRIM(@SchCode))
					SET @PrevSlabId=@SlabId
					SET @SeqId=1
				END	
			END
			ELSE IF  LTRIM(RTRIM(@PrvSchCode))=LTRIM(RTRIM(@SchCode))
			BEGIN
				IF @PrevSlabId=0 
				BEGIN
					SET @PrvSchCode=LTRIM(RTRIM(@SchCode))
					SET @PrevSlabId=@SlabId
					SET @SeqId=1
				END
				ELSE IF @PrevSlabId=@SlabId
				BEGIN
					SET @PrvSchCode=LTRIM(RTRIM(@SchCode))
					SET @PrevSlabId=@SlabId
					SET @SeqId = @SeqId + 1
				END
				ELSE
				BEGIN
					SET @SeqId = 1
				END
			END
			ELSE
			BEGIN
				SET @SeqId =1
			END
			--->Till Here

			IF @SchType <> 4
			BEGIN
				IF @FlexiId=1
				BEGIN 	
					 IF LTRIM(RTRIM(@TypeCode))=''
					 BEGIN
						 SET @ErrDesc = 'Free/Gift Should not be blank for Scheme Code:'+@SchCode
						 INSERT INTO Errorlog VALUES (1,@TabName,'Free/Gift',@ErrDesc)
						 SET @Taction = 0
						 SET @Po_ErrNo =1
					 END
					 ELSE IF UPPER(LTRIM(RTRIM(@TypeCode)))<>'FREE' AND UPPER(LTRIM(RTRIM(@TypeCode)))<>'GIFT'
					 BEGIN
						 SET @ErrDesc = 'Product Type Should Be FREE/GIFT for Scheme Code:'+@SchCode
						 INSERT INTO Errorlog VALUES (1,@TabName,'Product Type',@ErrDesc)
						 SET @Taction = 0
						 SET @Po_ErrNo =1
					 END
					 IF UPPER(LTRIM(RTRIM(@TypeCode)))='FREE'
					 BEGIN
						SET @TypeId=1
					 END
					 ELSE IF UPPER(LTRIM(RTRIM(@TypeCode)))='GIFT'
					 BEGIN
						SET @TypeId=2
					 END
		
-- 					 EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
-- 					 SELECT @ChkCount=COUNT(*) FROM TempDepCheck
-- 					 IF @ChkCount > 0
-- 					 BEGIN
					 	SET @Taction=0
		
						SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
						IF @SchLevelId<@SLevel
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
							AND  A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) ---AND UPPER(A.[SchLevel])='YES'
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
								DELETE FROM  SchemeSlabMultiFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
								AND PrdId=@PrdId AND Type=@TypeId
								
								INSERT INTO SchemeSlabMultiFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,SeqId,Availability,
								LastModBy,LastModDate,AuthId,AuthDate,Type) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,@SeqId,
								1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@TypeId)
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N'
								
								INSERT INTO Etl_Prk_SchemeSlabMultiFrePrds_Temp(CmpSchCode,SlabId,PrdId,PrdCode,
								FreeQty,OpnANDOR,SeqId,Type,UpLoadFlag) VALUES (@GetKey,@SlabId,@SeqId,LTRIM(RTRIM(@PrdCode)),
								@Qty,@CondId,0,@TypeId,'N')
							END
						END
						ELSE
						BEGIN
-- 							DELETE FROM  SchemeSlabMultiFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 							AND PrdId=@PrdId AND Type=@TypeId
							
							INSERT INTO SchemeSlabMultiFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,SeqId,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,Type) VALUES(@GetKey,ISNULL(@SlabId,1),@PrdId,@Qty,@CondId,@SeqId,
							1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@TypeId)
						END
-- 					END
				END
				ELSE
				BEGIN
					IF CONVERT(INT,LTRIM(RTRIM(@Qty)))= 0
					BEGIN
						SET @ErrDesc = 'Quantity should be > 0 for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Quantity',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF (@SlabId)=LTRIM(RTRIM(@SlabCode))
					BEGIN
						 IF LTRIM(RTRIM(@TypeCode))=''
						 BEGIN
							 SET @ErrDesc = 'Free/Gift Should not be blank for Scheme Code:'+@SchCode
							 INSERT INTO Errorlog VALUES (1,@TabName,'Free/Gift',@ErrDesc)
							 SET @Taction = 0
							 SET @Po_ErrNo =1
						 END
						 ELSE IF UPPER(LTRIM(RTRIM(@TypeCode)))<>'FREE' AND UPPER(LTRIM(RTRIM(@TypeCode)))<>'GIFT'
						 BEGIN
							 SET @ErrDesc = 'Product Type Should Be FREE/GIFT for Scheme Code:'+@SchCode
							 INSERT INTO Errorlog VALUES (1,@TabName,'Product Type',@ErrDesc)
							 SET @Taction = 0
							 SET @Po_ErrNo =1
						 END
	
						 IF UPPER(LTRIM(RTRIM(@TypeCode)))='FREE'
						 BEGIN
							SET @TypeId=1
						 END
						 ELSE IF UPPER(LTRIM(RTRIM(@TypeCode)))='GIFT'
						 BEGIN
							SET @TypeId=2
						 END
						SELECT @TypeCnt=ISNULL(COUNT(LTRIM(RTRIM([PrdCode]))),0) FROM Etl_Prk_Scheme_Free_Multi_Products
						WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND [SlabId]=LTRIM(RTRIM(@SlabCode))
						AND [Type]=LTRIM(RTRIM(@TypeCode))
						SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
			
						IF @SchLevelId<@SLevel
						BEGIN
							SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[SchLevel])='NO'
							AND A.SlabId=0 AND A.SlabValue=0
		
							SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
							WHERE A.[PrdCode] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
							A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[SchLevel])='NO'
							AND A.SlabId=0 AND A.SlabValue=0
						END
						ELSE
						BEGIN
							SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[SchLevel])='YES'
							AND A.SlabId=0 AND A.SlabValue=0
	
							SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
							WHERE A.[PrdCode] IN (SELECT PrdCCode FROM Product)
							AND  A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[SchLevel])='YES'
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
								IF @TypeCnt <> 0 AND @SeqId<=1
								BEGIN
-- 									DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 									AND  PrdId=@PrdId
									INSERT INTO SchemeSlabFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,Availability,
									LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,
									1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
								END
								ELSE IF @TypeCnt <> 0 AND @TypeCnt>1
								BEGIN
									IF @CondId=1
									BEGIN
-- 										DELETE FROM  SchemeSlabMultiFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 										AND PrdId=@PrdId AND Type=@TypeId
			
										INSERT INTO SchemeSlabMultiFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,SeqId,Availability,
										LastModBy,LastModDate,AuthId,AuthDate,Type) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,@SeqId,
										1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@TypeId)
									END
									ELSE IF @CondId=2
									BEGIN
-- 										DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 										AND  PrdId=@PrdId
			
										INSERT INTO SchemeSlabFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,Availability,
										LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,
										1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
									END
								END
							END
							ELSE
							BEGIN
								IF @TypeCnt <> 0 AND @SeqId=1
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
									AND UpLoadFlag='N' AND SlabId=@SlabId AND  PrdCode=LTRIM(RTRIM(@PrdCode))
									INSERT INTO Etl_Prk_SchemeSlabFrePrds_Temp(CmpSchCode,SlabId,PrdId,PrdCode,FreeQty,OpnANDOR,UpLoadFlag)
										VALUES(@GetKey,@SlabId,@PrdId,LTRIM(RTRIM(@PrdCode)),@Qty,@CondId,'N')
								END
								ELSE IF @TypeCnt <> 0 AND @TypeCnt>1
								BEGIN
									IF @CondId=1
									BEGIN
										DELETE FROM Etl_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N'
										
										INSERT INTO Etl_Prk_SchemeSlabMultiFrePrds_Temp(CmpSchCode,SlabId,PrdId,PrdCode,
										FreeQty,OpnANDOR,SeqId,Type,UpLoadFlag) VALUES (@GetKey,@SlabId,0,LTRIM(RTRIM(@PrdCode)),
										@Qty,@CondId,@SeqId,@TypeId,'N')
									END
									ELSE IF @CondId=2
									BEGIN
										DELETE FROM Etl_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
										AND UpLoadFlag='N' AND SlabId=@SlabId AND  PrdCode=LTRIM(RTRIM(@PrdCode))
										INSERT INTO Etl_Prk_SchemeSlabFrePrds_Temp(CmpSchCode,SlabId,PrdId,PrdCode,FreeQty,OpnANDOR,UpLoadFlag)
											VALUES(@GetKey,@SlabId,@PrdId,LTRIM(RTRIM(@PrdCode)),@Qty,@CondId,'N')
									END
								END
							END
						END
						ELSE
						BEGIN
							IF @TypeCnt <> 0 AND @SeqId=1
							BEGIN
-- 								DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 								AND  PrdId=@PrdId
								INSERT INTO SchemeSlabFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,Availability,
								LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,
								1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
							END
							ELSE IF @TypeCnt <> 0 AND @TypeCnt>1
							BEGIN
								IF @CondId=1
								BEGIN
-- 									DELETE FROM  SchemeSlabMultiFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 									AND PrdId=@PrdId AND Type=@TypeId
		
									INSERT INTO SchemeSlabMultiFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,SeqId,Availability,
									LastModBy,LastModDate,AuthId,AuthDate,Type) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,@SeqId,
									1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@TypeId)
								END
								ELSE IF @CondId=2
								BEGIN
-- 									DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 									AND  PrdId=@PrdId
		
									INSERT INTO SchemeSlabFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,Availability,
									LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,
									1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
								END
							END
						END
					END
				END
			END
		END	
		SET @PrevSlabId=@SlabId
		SET @PrvSchCode=@SchCode
		FETCH NEXT FROM Cur_SchemeSlabFreePrds INTO  @SchCode,@SlabCode,@Condition,@PrdCode,@Qty,@TypeCode
	END
	CLOSE Cur_SchemeSlabFreePrds
	DEALLOCATE Cur_SchemeSlabFreePrds
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeCombiPrd' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeCombiPrd
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeCombiPrd 0
SELECT * FROM ErrorLog
SELECT * FROM SchemeSlabCombiPrds
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeCombiPrd
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeCombiPrd
* PURPOSE: To Insert and Update Scheme Combi Products
* CREATED: Boopathy.P on 03/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode	AS VARCHAR(200)
	DECLARE @SlabId		AS Varchar(200)
	DECLARE @Value		AS VARCHAR(50)
	DECLARE @PrdCode	AS VARCHAR(200)
	DECLARE @PrdBatCode	AS VARCHAR(200)
	DECLARE @SlabCode	AS VARCHAR(200)
	DECLARE @GetKeyCode	AS VARCHAR(200)
	DECLARE @PrdBatOpt	AS INT
	DECLARE @CombiSchId	AS INT
	DECLARE @BatchLvl	AS INT
	DECLARE @CmpId		AS INT
	DECLARE @PrdId		AS VARCHAR(200)
	DECLARE @PrdBatId	AS VARCHAR(200)	
	DECLARE @SchLevelId	AS INT
	DECLARE @PrdCtgId	AS INT
	DECLARE @CombiSch	AS INT
	DECLARE @ChkCount	AS INT
	DECLARE @ErrDesc 	AS VARCHAR(1000)
	DECLARE @TabName 	AS VARCHAR(50)
	DECLARE @GetKey 	AS INT
	DECLARE @Taction 	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @sSQL 		AS VARCHAR(4000)
	DECLARE @MaxSchLevelId	AS	INT
	DECLARE @SLevel		AS	INT
	DECLARE @CmpPrdCtgId	AS	INT
	DECLARE @SchLevelMode	AS	NVARCHAR(200)
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	SET @TabName = 'Etl_Prk_SchemeProducts_Combi'
	SET @Po_ErrNo =0
	DECLARE Cur_SchemeCombiPrds CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL(SlabId,'') AS [SlabId],
	ISNULL([PrdCode],'') AS [Code],ISNULL([PrdBatCode],'') AS [Batch Code],
	ISNULL([SlabValue],'') AS [Value] FROM Etl_Prk_SchemeProducts_Combi
	WHERE SlabValue > 0
	AND CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code],[SlabId]
	OPEN Cur_SchemeCombiPrds
	FETCH NEXT FROM Cur_SchemeCombiPrds INTO @SchCode,@SlabId,@PrdCode,@PrdBatCode,@Value
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		SET @SlabCode=@SlabId
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF EXISTS (SELECT * FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
		BEGIN
			SELECT @SchLevelId=SchLevelId,@CombiSchId=CombiSch, 
			@BatchLvl=BatchLevel FROM SchemeMaster
			WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		END
		ELSE IF EXISTS (SELECT * FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
		BEGIN
			SELECT @SchLevelId=SchLevelId,@CombiSchId=CombiSch,@BatchLvl=BatchLevel
			FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		END
		IF @CombiSchId=1
		BEGIN
			IF LTRIM(RTRIM(@SlabId))= ''
			BEGIN
				SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@PrdCode))= ''
			BEGIN
				SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@Value))= ''
			BEGIN
				SET @ErrDesc = 'Slab Value should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab Value',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@SchLevelMode))=''
			BEGIN
				SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
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
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
		
					SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
					IF @MaxSchLevelId=@SchLevelId
					BEGIN
						IF NOT EXISTS(SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
						BEGIN
							SET @ErrDesc = 'Product Code:'+@PrdCode+ ' not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
						END
					END
					IF NOT EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SET @ErrDesc = 'Slab Details not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND
						SlabId=LTRIM(RTRIM(@SlabCode))
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
					ELSE IF EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
							CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN
						SELECT @GetKeyCode=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@CombiSch=CombiSch,@CmpPrdCtgId=SchLevelId 
						FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END	
					ELSE
					BEGIN
						SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
						B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=C.CmpPrdCtgId,@CombiSch=A.CombiSch
						FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
						INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
						AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
					END
					IF EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND
						SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N' AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND
						UpLoadFlag='N' AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
				END
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @MaxSchLevelId=@SchLevelId
				BEGIN
					IF @BatchLvl=1
					BEGIN
						IF LTRIM(RTRIM(@PrdBatCode))= ''
						BEGIN
							SET @ErrDesc = 'Batch Code should not be blank for Product Code:'+@PrdCode+ 'of Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Batch Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
						
						IF NOT EXISTS(SELECT PrdId FROM Product WHERE CmpId=@CmpId
							AND PrdCCode=LTRIM(RTRIM(@PrdCode)))
						BEGIN
							SET @ErrDesc = 'Product Code:'+@PrdCode +' Not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @PrdId=PrdId FROM Product WHERE CmpId=@CmpId
							AND PrdCCode=LTRIM(RTRIM(@PrdCode))
							SET @PrdCtgId=0
							IF @BatchLvl=1
							BEGIN
								IF NOT EXISTS(SELECT PrdBatId FROM ProductBatch WHERE PrdId=@PrdId)
								BEGIN
		
									SET @ErrDesc = 'No Batch Code Found for Product Code:'+@PrdCode+ ' in Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (11,@TabName,'Batch Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId
								END
							END
							ELSE
							BEGIN
-- 								SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId
								SET @PrdBatId=0
							END
						END
-- 					END
				END
				ELSE
				BEGIN
					--->Modified By Nanda on 24/08/2009
					IF NOT EXISTS(SELECT A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId)
					BEGIN
						SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @PrdCtgId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
						SET @PrdId=0
						SET @PrdBatId=0
					END
					--Till Here
				END
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
			SELECT @ChkCount=COUNT(*) FROM TempDepCheck
			IF @ChkCount > 0
			BEGIN				
				SET @Taction = 0
			END
			ELSE
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
							DELETE FROM SchemeSlabCombiPrds WHERE SlabId=@SlabId AND SchId=@GetKey 
							AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND PrdCtgValMainId=@PrdCtgId
							
							SET @sSQL ='DELETE FROM SchemeSlabCombiPrds WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
								   ' AND SchId=' + CAST(@GetKey AS VARCHAR(200))
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
			
							INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
								    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,
								    @PrdCtgId,@PrdId,@PrdBatId,@Value,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
				
							SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
								    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
								   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
								   ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=@SlabId AND CmpSchCode=@GetKey
							AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UpLoadFlag='N'
							
							SET @sSQL ='DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
								   ' AND CmpSchCode=' + CAST(@GetKey AS VARCHAR(200)) + ' AND PrdId='+ CAST(@PrdId AS VARCHAR(200)) +
								   ' AND PrdBatId=' +  CAST(@PrdBatId AS VARCHAR(200)) + ' AND UpLoadFlag=''N'''
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
			
							INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
							VALUES(@GetKey,@SlabId,@PrdCtgId,@PrdId,@PrdBatId,@Value,'N')
				
							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
								    VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
								   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
								   ',''N'')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE
					BEGIN
						DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=@SlabId AND CmpSchCode=@GetKey
						AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UpLoadFlag='N'
						
						SET @sSQL ='DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
							   ' AND CmpSchCode=' + CAST(@GetKey AS VARCHAR(200)) + ' AND PrdId='+ CAST(@PrdId AS VARCHAR(200)) +
							   ' AND PrdBatId=' +  CAST(@PrdBatId AS VARCHAR(200)) + ' AND UpLoadFlag=''N'''
		
						INSERT INTO Translog(strSql1) Values (@sSQL)
		
						INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
						VALUES(@GetKey,@SlabId,@PrdCtgId,@PrdId,@PrdBatId,@Value,'N')
			
						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
							    VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
							   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
							   ',''N'')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END
				ELSE
				BEGIN
					DELETE FROM SchemeSlabCombiPrds WHERE SlabId=@SlabId AND SchId=@GetKey 
					AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND PrdCtgValMainId=@PrdCtgId
					
					SET @sSQL ='DELETE FROM SchemeSlabCombiPrds WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
						   ' AND SchId=' + CAST(@GetKey AS VARCHAR(200))
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
	
					INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
						    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,
						    @PrdCtgId,@PrdId,@PrdBatId,@Value,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
		
					SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
						    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
						   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
						   ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
			END
		END
		FETCH NEXT FROM Cur_SchemeCombiPrds INTO @SchCode,@SlabId,@PrdCode,@PrdBatCode,@Value
	END
	CLOSE Cur_SchemeCombiPrds
	DEALLOCATE Cur_SchemeCombiPrds
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeOnAnotherPrd' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeOnAnotherPrd
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeOnAnotherPrd 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeOnAnotherPrd
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeOnAnotherPrd
* PURPOSE: To Insert and Update records Of Scheme On Another Products
* CREATED: Boopathy.P on 06/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrDesc AS VARCHAR(1000)
	DECLARE @TabName AS VARCHAR(50)
	DECLARE @GetKey AS INT
	DECLARE @GetKeyStr AS NVARCHAR(200)
	DECLARE @Taction AS INT
	DECLARE @sSQL AS VARCHAR(4000)
	DECLARE @iCnt		AS INT
	DECLARE @SchCode 	AS VARCHAR(100)
	DECLARE @SchCode1 	AS VARCHAR(100)
	DECLARE @CmpCode 	AS VARCHAR(50)
	DECLARE @SchLevelMode	AS VARCHAR(50)
	DECLARE @SchLevel	AS VARCHAR(50)
	DECLARE @SlabCode	AS VARCHAR(50)
	DECLARE @SlabCode1	AS VARCHAR(50)
	DECLARE @SchType	AS VARCHAR(50)
	DECLARE @Range		AS VARCHAR(50)
	DECLARE @PrdType	AS VARCHAR(50)
	DECLARE @PrdCode	AS VARCHAR(50)
	DECLARE @PurQty		AS VARCHAR(50)
	DECLARE @PurFrmQty	AS VARCHAR(50)
	DECLARE @PurUom		AS VARCHAR(50)
	DECLARE @PurToQty	AS VARCHAR(50)
	DECLARE @PurToUom	AS VARCHAR(50)
	DECLARE @PurofEveryQty	AS VARCHAR(50)
	DECLARE @PurofUom	AS VARCHAR(50)
	DECLARE @DiscPer	AS VARCHAR(50)
	DECLARE @FlatAmt	AS VARCHAR(50)
	DECLARE @Points		AS VARCHAR(50)
	DECLARE @SchWithPrd	AS INT
	DECLARE @SLevel		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @CmpId		AS INT
	DECLARE @SchTypeId	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @SlabId		AS INT
	DECLARE @SlabId1	AS INT
	DECLARE @RangeId	AS INT
	DECLARE @SchLevelModeId	AS INT
	DECLARE @PrdTypeId	AS INT
	DECLARE @PrdId		AS INT
	DECLARE @PurUomId	AS INT
	DECLARE @ToUomId	AS INT
	DECLARE @ForEveryUomId	AS INT
	SET @TabName = 'Etl_Prk_Scheme_OnAnotherPrd'
	SET @Po_ErrNo =0
	SET @iCnt=0
	
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE Cur_SchOnAnotherPrdHd CURSOR
	FOR SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
	ISNULL(SlabId,'') AS SlabId,
	ISNULL(SchType,'') AS SchType,
	ISNULL(SchLevel,'') AS SchLevel,
	ISNULL(SchLevelMode,'') AS SchLevelMode,
	ISNULL(Range,'') AS Range
	FROM Etl_Prk_Scheme_OnAnotherPrd
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	OPEN Cur_SchOnAnotherPrdHd
	FETCH NEXT FROM Cur_SchOnAnotherPrdHd INTO @SchCode,@SlabCode, @SchType, @SchLevel, @SchLevelMode,@Range
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		SET @SchWithPrd=0
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SlabCode))= ''
		BEGIN
			SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Slab',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchType))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (3,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchLevel))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (4,@TabName,'Scheme Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchLevelMode))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level Mode should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (5,@TabName,'Scheme Level Mode',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))<> 'UDC') AND (UPPER(LTRIM(RTRIM(@SchLevelMode)))<> 'PRODUCT'))
		BEGIN
			SET @ErrDesc = 'Selection Mode should be (UDC OR PRODUCT) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (6,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF  LTRIM(RTRIM(@Range))<> ''
		BEGIN
			IF ((UPPER(LTRIM(RTRIM(@Range)))<> 'YES') AND (UPPER(LTRIM(RTRIM(@Range)))<> 'NO'))
			BEGIN
				SET @ErrDesc = 'Range Based Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (6,@TabName,'Range Based Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE SM.CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not available for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (7,@TabName,'Company Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SET @Taction = 1
	
					IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (9,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
				ELSE
				IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (10,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
					WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					
				END
			END
		END
		IF @Po_ErrNo=0 	
		BEGIN
			IF EXISTS (SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
			AND CmpPrdCtgName=LTRIM(RTRIM(@SchLevel)))
			BEGIN
				SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
				AND CmpPrdCtgName=LTRIM(RTRIM(@SchLevel))
			END
			ELSE
			BEGIN
				SET @ErrDesc = 'Scheme Level not found for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchType))) = 'QUANTITY'
			BEGIN
				SET @SchTypeId=1
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SchType))) = 'AMOUNT'
			BEGIN
				SET @SchTypeId=2
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SchType))) = 'WEIGHT'
			BEGIN
				SET @SchTypeId=3
			END
			IF LTRIM(RTRIM(@Range)) <> ''
			BEGIN
				IF ((UPPER(LTRIM(RTRIM(@Range)))= 'YES'))
				BEGIN
					SET @RangeId=1
				END
				ELSE IF ((UPPER(LTRIM(RTRIM(@Range)))= 'NO'))
				BEGIN
					SET @RangeId=0
				END
			END
			ELSE
			BEGIN
				SET @RangeId=0
			END
			IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))= 'UDC'))
			BEGIN
				SET @SchLevelModeId=1
			END
			ELSE IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))= 'PRODUCT'))
			BEGIN
				SET @SchLevelModeId=0
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS (SELECT A.SchId FROM SchemeMaster A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode)))
			BEGIN
				IF EXISTS (SELECT A.SchId FROM SchemeAnotherPrdHd A INNER JOIN SchemeMaster B ON
				A.SchId=B.SchId WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode))
				AND A.SlabId=LTRIM(RTRIM(@SlabCode)))
				BEGIN
					SET @Taction = 2
					SET @SchWithPrd=1
				END
				ELSE
				BEGIN
					SET @Taction = 1
					SET @SchWithPrd=1
					INSERT INTO SchemeAnotherPrdHd (SchId,SlabId,SchType,SchLevel,SchLevelMode,
						    Range,ApplySch,Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
					(@GetKey,@SlabId,@SchTypeId,@CmpPrdCtgId,@SchLevelModeId,@RangeId,0,
					 1,1,GETDATE(),1,GETDATE())
				END
			END
			ELSE IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeMaster_Temp A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode)) AND A.UpLoadFlag='N')
			BEGIN
				IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeAnotherPrdHd_Temp A INNER JOIN Etl_Prk_SchemeAnotherPrdHd_Temp B ON
				A.CmpSchCode=B.CmpSchCode WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode))
				AND A.SlabId=LTRIM(RTRIM(@SlabCode)))
				BEGIN
					SET @Taction = 2
					SET @SchWithPrd=2
				END
				ELSE
				BEGIN
					SET @Taction = 1
					SET @SchWithPrd=2
					INSERT INTO Etl_Prk_SchemeAnotherPrdHd_Temp (CmpSchCode,SlabId,SchType,SchLevel,SchLevelMode,Range)						
						VALUES (@SchCode,@SlabId,@SchTypeId,@CmpPrdCtgId,@SchLevelModeId,@RangeId)
				END
			END
--SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
--					ISNULL(SlabId,'') AS SlabId,
--					ISNULL(Range,'') AS Range,
--					ISNULL(PrdType,'') AS PrdType,
--					ISNULL(PrdCode,'') AS PrdCode,
--					ISNULL(PurQty,'0') AS PurQty,
--					ISNULL(PurFrmQty,'0') AS PurFrmQty,
--					ISNULL(PurUom ,'0') AS PurUom,
--					ISNULL(PurToQty ,'0') AS PurToQty,
--					ISNULL(PurToUom,'0') AS PurToUom,
--					ISNULL(PurofEveryQty ,'0') AS PurofEveryQty,
--					ISNULL(PurofUom ,'0') AS PurofUom,
--					ISNULL(DiscPer,'0') AS DiscPer,
--					ISNULL(FlatAmt,'0') AS FlatAmt,
--					ISNULL(Points,'0') AS Points
--					FROM Etl_Prk_Scheme_OnAnotherPrd WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
--					AND SlabId= LTRIM(RTRIM(@SlabCode))
			DECLARE Cur_SchOnAnotherPrdDt CURSOR
			FOR SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
					ISNULL(SlabId,'') AS SlabId,
					ISNULL(Range,'') AS Range,
					ISNULL(PrdType,'') AS PrdType,
					ISNULL(PrdCode,'') AS PrdCode,
					ISNULL(PurQty,'0') AS PurQty,
					ISNULL(PurFrmQty,'0') AS PurFrmQty,
					ISNULL(PurUom ,'0') AS PurUom,
					ISNULL(PurToQty ,'0') AS PurToQty,
					ISNULL(PurToUom,'0') AS PurToUom,
					ISNULL(PurofEveryQty ,'0') AS PurofEveryQty,
					ISNULL(PurofUom ,'0') AS PurofUom,
					ISNULL(DiscPer,'0') AS DiscPer,
					ISNULL(FlatAmt,'0') AS FlatAmt,
					ISNULL(Points,'0') AS Points
					FROM Etl_Prk_Scheme_OnAnotherPrd WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					AND SlabId= LTRIM(RTRIM(@SlabCode))
			OPEN Cur_SchOnAnotherPrdDt
			FETCH NEXT FROM Cur_SchOnAnotherPrdDt INTO @SchCode1,@SlabCode1,@Range,@PrdType,@PrdCode,
					@PurQty,@PurFrmQty,@PurUom,@PurToQty,@PurToUom,@PurofEveryQty,@PurofUom
					,@DiscPer, @FlatAmt, @Points
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF LTRIM(RTRIM(@SchCode1))= ''
				BEGIN
					SET @ErrDesc = 'Company Scheme Code should not be blank'
					INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@SlabCode1))= ''
				BEGIN
					SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Slab',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PrdType))= ''
				BEGIN
					SET @ErrDesc = 'Product Type should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Product Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PrdCode))= ''
				BEGIN
					SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Product Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PurQty))= ''
				BEGIN
					SET @ErrDesc = 'Purchase Qty should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Purchase Qty',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PurUom))= ''
				BEGIN
					SET @ErrDesc = 'Purchase Uom should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Purchase Uom',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF (LTRIM(RTRIM(@DiscPer))= '0' AND LTRIM(RTRIM(@FlatAmt))= '0' AND LTRIM(RTRIM(@Points))= '0')
				BEGIN
					SET @ErrDesc = 'Disc % or Flat Amount or Points should not be Zero for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Disc,Flat Amount and Points',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				IF @Po_ErrNo=0
				BEGIN
					IF @ConFig<>1
					BEGIN
						IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE SM.CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not available in Master Table for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (7,@TabName,'Company Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
							SET @Taction = 1
			
							IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
					END
					ELSE
					BEGIN
						IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
							IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (9,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
							CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (10,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
							WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
		
							IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)) AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF LTRIM(RTRIM(@PurofEveryQty))<> ''
						BEGIN
							IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurofUom)))
							BEGIN
								SELECT @ForEveryUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurofUom))
								
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Purchase of every Uom not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Purchase of every Uom',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						BEGIN
							SET @ForEveryUomId=0
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF UPPER(LTRIM(RTRIM(@PrdType)))= 'NO'
						BEGIN
							SET @PrdTypeId =0
						END
						ELSE IF UPPER(LTRIM(RTRIM(@PrdType)))= 'YES'
						BEGIN
							SET @PrdTypeId=1
						END
	
						IF UPPER(LTRIM(RTRIM(@PrdType)))= 'YES'
						BEGIN
							IF EXISTS (SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
							BEGIN
								SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Product Code:'+@PrdCode +' not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE IF UPPER(LTRIM(RTRIM(@PrdType)))= 'NO'
						BEGIN
							IF EXISTS (SELECT PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode=LTRIM(RTRIM(@PrdCode)))
							BEGIN
								SELECT @PrdId=PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode=LTRIM(RTRIM(@PrdCode))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Product Category Value Code:'+@PrdCode +' not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Product Category Value Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurUom)))
						BEGIN
							SELECT @PurUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurUom))
							SET @ToUomId=0
						END
						ELSE
						BEGIN
							SET @ErrDesc = 'Purchase Uom not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Purchase Uom',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF LTRIM(RTRIM(@Range)) <> ''
						BEGIN
							IF UPPER(LTRIM(RTRIM(@Range)))= 'YES'
							BEGIN
								SET @RangeId=1
							END
							ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NO'
							BEGIN
								SET @RangeId=0
							END
						END
						ELSE
						BEGIN
							SET @RangeId=0
						END
	
						IF @RangeId=1
						BEGIN
							IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurToUom)))
							BEGIN
								SELECT @ToUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurToUom))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Purchase Uom not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Purchase Uom',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						BEGIN
							SET @ToUomId=0
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF EXISTS (SELECT A.SchId FROM SchemeMaster A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							IF EXISTS (SELECT A.SchId FROM SchemeAnotherPrdDt A INNER JOIN SchemeMaster B ON
							A.SchId=B.SchId WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode1))
							AND A.SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SET @Taction = 2
							END
							ELSE
							BEGIN
								SET @Taction = 1
							END
						END
						ELSE IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeMaster_Temp A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode1)) AND A.UpLoadFlag='N')
						BEGIN
							IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeAnotherPrdHd_Temp A INNER JOIN Etl_Prk_SchemeMaster_Temp B ON
							A.CmpSchCode=B.CmpSchCode WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode1))
							AND A.SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SET @Taction = 2
							END
							ELSE
							BEGIN
								SET @Taction = 1
							END
						END
					END
					IF @Taction = 1
					BEGIN
						IF @SchWithPrd =1
						BEGIN
							INSERT INTO SchemeAnotherPrdDt (SchId,SlabId,PrdType,PrdId,PurQty,PurFrmQty,PurUomId,PurToQty,
							PurToUomId,PurofEveryQty,PurofUomId,DiscPer,FlatAmt,Points,Availability,
							LastModBy,LastModDate,AuthId,AuthDate) VALUES
							(@GetKey,@SlabId1,@PrdTypeId,@PrdId,@PurQty,@PurFrmQty,@PurUomId,@PurToQty,
							@ToUomId,@PurofEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,CAST(@Points AS NUMERIC(18,0)),1,1,
							GETDATE(),1,GETDATE())
						END
						ELSE IF @SchWithPrd =2
						BEGIN
							INSERT INTO Etl_Prk_SchemeAnotherPrdDt_Temp (CmpSchCode,SlabId,PrdType,PrdId,PrdCode,PurQty,PurFrmQty,
							PurUomId,PurUomCode,PurToQty,PurToUomId,PurToUomCode,PurofEveryQty,PurofUomId,PurofUomCode,
							DiscPer,FlatAmt,Points) VALUES (
							@GetKey,@SlabId1,@PrdTypeId,@PrdId,@PrdCode,@PurQty,@PurFrmQty,@PurUomId,@PurUom,@PurToQty,
							@ToUomId,@PurToUom,@PurofEveryQty,@ForEveryUomId,@PurofUom,@DiscPer,@FlatAmt,CAST(@Points AS NUMERIC(18,0)))
						END
					END
					ELSE IF @Taction = 2
					BEGIN
						IF @SchWithPrd =1
						BEGIN
							UPDATE SchemeAnotherPrdDt Set PrdType=@PrdTypeId,PrdId=@PrdId,PurQty=@PurQty,PurFrmQty=@PurFrmQty,
							PurUomId=@PurUomId,PurToQty=@PurToQty,PurToUomId=@ToUomId,PurofEveryQty=@PurofEveryQty,
							PurofUomId=@ForEveryUomId,DiscPer=@DiscPer,FlatAmt=@FlatAmt,Points=CAST(@Points AS NUMERIC(18,0))
							WHERE SchId=@GetKey AND SlabId=@SlabId1
						END
						ELSE IF @SchWithPrd =2
						BEGIN
							UPDATE Etl_Prk_SchemeAnotherPrdDt_Temp SET PrdType=@PrdTypeId,PrdId=@PrdId,PrdCode=@PrdCode,PurQty=@PurQty,
							PurFrmQty=@PurFrmQty,PurUomId=@PurUomId,PurUomCode=@PurUom,PurToQty=@PurToQty,
							PurToUomId=@ToUomId,PurToUomCode=@PurToUom,PurofEveryQty=@PurofEveryQty,
							PurofUomId=@ForEveryUomId,PurofUomCode=PurofUomCode,DiscPer=@DiscPer,
							FlatAmt=@FlatAmt,Points=CAST(@Points AS NUMERIC(18,0))
							WHERE CmpSchCode=@SchCode1 AND SlabId=@SlabId1
						END
					END
				END
				FETCH NEXT FROM Cur_SchOnAnotherPrdDt INTO @SchCode1,@SlabCode1,@Range,@PrdType,@PrdCode,
				@PurQty,@PurFrmQty,@PurUom,@PurToQty,@PurToUom,@PurofEveryQty,@PurofUom,@DiscPer,@FlatAmt,@Points
			END
			CLOSE Cur_SchOnAnotherPrdDt
			DEALLOCATE Cur_SchOnAnotherPrdDt
		END
		FETCH NEXT FROM Cur_SchOnAnotherPrdHd INTO  @SchCode,@SlabCode,@SchType,@SchLevel,@SchLevelMode,@Range
	END
	CLOSE Cur_SchOnAnotherPrdHd
	DEALLOCATE Cur_SchOnAnotherPrdHd	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_NVSchemeMasterControl' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_NVSchemeMasterControl
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_NVSchemeMasterControl 0
SELECT * FROM SchemeProducts WHERE SchId<4 AND PrdCtgValMainId>0
ROLLBACK TRANSACTION
*/
CREATE  PROCEDURE Proc_Cn2Cs_NVSchemeMasterControl
(
	@Po_ErrNo INT OUTPUT
)
AS
/********************************************************************************************
* PROCEDURE		: Proc_Cn2Cs_NVSchemeMasterControl
* PURPOSE		: To Validate Scheme Master Control Details
* SCREEN		: Console INTegration-SchemeMasterControl
* CREATED BY	: Nandakumar R.G On 23-10-2009
* MODIFIED		:
* DATE      	AUTHOR     DESCRIPTION
* {date}	{developer}  	{brief modIFication description}
*********************************************************************************************
* 11.01.2010	Panneer		Added and Delete to SchemeProducts Table
*********************************************************************************************/
SET NOCOUNT ON
BEGIN	
	
	SET @Po_ErrNo=0

	DECLARE @ErrStatus INT
	
	DECLARE @CmpSchCode		NVARCHAR(100)		
	DECLARE @ChangeType		NVARCHAR(100)
	DECLARE @Description	NVARCHAR(100)
	DECLARE @FromValue		NVARCHAR(100)
	DECLARE @ToValue		NVARCHAR(100)
	DECLARE @ResField1		NVARCHAR(100)
	DECLARE @ResField2		NVARCHAR(100)
	DECLARE @ResField3		NVARCHAR(100)
	DECLARE @ResField4		NVARCHAR(100)
	DECLARE @ResField5		NVARCHAR(100)
	DECLARE @SchId			INT
	DECLARE @StatusId		INT
	DECLARE @PrdId			INT
	DECLARE @CmpPrdCtgId	INT
	DECLARE @CmpId			INT
	SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SchToAvoid	
	END

	CREATE TABLE SchToAvoid
	(
		CmpSchCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Cn2Cs_Prk_NVSchemeMasterControl
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT DISTINCT CmpSchCode FROM Cn2Cs_Prk_NVSchemeMasterControl
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Scheme','Scheme:'+CmpSchCode+' Not Available' FROM Cn2Cs_Prk_NVSchemeMasterControl
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster)
	END	

	DECLARE Cur_Scheme CURSOR
	FOR SELECT DISTINCT CmpSchCode,ChangeType,Description,FromValue,ToValue,ResField1,ResField2,ResField3,ResField4,ResField5
	FROM Cn2Cs_Prk_NVSchemeMasterControl WHERE DownLoadFlag='D'
	AND CmpSchCode NOT IN(SELECT CmpSchCode FROM SchToAvoid)
	ORDER BY CmpSchCode,ChangeType,Description,FromValue,ToValue,ResField1,ResField2,ResField3,ResField4,ResField5
	
	OPEN Cur_Scheme
	FETCH NEXT FROM Cur_Scheme INTO @CmpSchCode,@ChangeType,@Description,@FromValue,@ToValue,
	@ResField1,@ResField2,@ResField3,@ResField4,@ResField5
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @PrdId=0

		SELECT @SchId=SchId FROM SchemeMaster WHERE CmpSchCode=@CmpSchCode

		IF @Description='Budget'
		BEGIN
			UPDATE SchemeMaster SET Budget=CAST(@FromValue AS NUMERIC(38,6)) WHERE SchId=@SchId			
		END

		IF @Description='Period'
		BEGIN
			UPDATE SchemeMaster SET SchValidTill=CAST(@ToValue AS DATETIME) WHERE SchId=@SchId			
		END

		IF @Description='Status'
		BEGIN			
			SET @StatusId=1
			IF @FromValue='Active'
			BEGIN
				SET @StatusId=1
			END
			ELSE
			BEGIN
				SET @StatusId=0
			END
			UPDATE SchemeMaster SET SchStatus=@StatusId WHERE SchId=@SchId
		END

		IF @Description='Product'
		BEGIN
			SELECT @CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE SchId=@SchId
			IF EXISTS(SELECT * FROM ProductCategoryLevel WHERE CmpId=@CmpId
			AND CmpPrdCtgId=@CmpPrdCtgId AND CmpPrdCtgId=(SELECT MAX(CmpPrdCtgId) FROM ProductCategoryLevel
			WHERE CmpId=@CmpId))
			BEGIN
				SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=CAST(@FromValue AS NVARCHAR(100))
				IF @PrdId=0
				BEGIN
					INSERT INTO SchToAvoid(CmpSchCode)
					SELECT @CmpSchCode
					INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
					SELECT DISTINCT 1,'Scheme Master','Scheme','Product:'+ @FromValue+' Not Available for Scheme:'+@CmpSchCode
				END
			END
			ELSE
			BEGIN
				SELECT @PrdId=PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode=CAST(@FromValue AS NVARCHAR(100))
				IF @PrdId=0
				BEGIN
					INSERT INTO SchToAvoid(CmpSchCode)
					SELECT @CmpSchCode
					INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
					SELECT DISTINCT 1,'Scheme Master','Scheme','Product Hierarchy:'+ @FromValue+' Not Available for Scheme:'+@CmpSchCode
				END
			END		
			IF @ChangeType='Add'
				BEGIN
					IF @PrdId>0
						BEGIN
							SELECT @CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE SchId=@SchId
							IF EXISTS(SELECT * FROM ProductCategoryLevel WHERE CmpId=@CmpId
										AND CmpPrdCtgId=@CmpPrdCtgId AND CmpPrdCtgId=(SELECT MAX(CmpPrdCtgId) FROM ProductCategoryLevel
										WHERE CmpId=@CmpId))
								BEGIN						
									IF NOT EXISTS(SELECT * FROM SchemeProducts WHERE SchId=@SchId AND PrdId=@PrdId)
										BEGIN 
											DELETE FROM SchemeProducts WHERE PrdId=@PrdId AND SchId=@SchId
											INSERT INTO SchemeProducts(SchId,PrdCtgValMainId,PrdId,PrdBatId,RowId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
											VALUES(@SchId,0,@PrdId,0,1,1,1,GETDATE(),1,GETDATE())
										END
								END
							ELSE
								BEGIN
									IF NOT EXISTS(SELECT * FROM SchemeProducts WHERE SchId=@SchId AND PrdCtgValMainId=@PrdId)
										BEGIN
											DELETE FROM SchemeProducts WHERE PrdCtgValMainId=@PrdId AND SchId=@SchId
											INSERT INTO SchemeProducts(SchId,PrdCtgValMainId,PrdId,PrdBatId,RowId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
											VALUES(@SchId,@PrdId,0,0,1,1,1,GETDATE(),1,GETDATE())
										END
								END				
						END
				END
			ELSE IF @ChangeType='Remove'
				BEGIN
					SELECT @CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE SchId=@SchId
					IF EXISTS(SELECT * FROM ProductCategoryLevel WHERE CmpId=@CmpId
								AND CmpPrdCtgId=@CmpPrdCtgId AND CmpPrdCtgId=(SELECT MAX(CmpPrdCtgId) FROM ProductCategoryLevel
								WHERE CmpId=@CmpId))
						BEGIN
							DELETE FROM SchemeProducts WHERE PrdId=@PrdId AND SchId=@SchId
						END
					ELSE
						BEGIN
							DELETE FROM SchemeProducts WHERE PrdCtgValMainId=@PrdId AND SchId=@SchId
						END
				END			
		END
		FETCH NEXT FROM Cur_Scheme INTO @CmpSchCode,@ChangeType,@Description,@FromValue,@ToValue,
		@ResField1,@ResField2,@ResField3,@ResField4,@ResField5
	END
	CLOSE Cur_Scheme
	DEALLOCATE Cur_Scheme	
	UPDATE Cn2Cs_Prk_NVSchemeMasterControl SET DownLoadFlag='Y'
	WHERE CmpSchCode NOT IN(SELECT CmpSchCode FROM SchToAvoid)

	INSERT INTO SchemeMasterControlHistory(CmpSchCode,ChangeType,Description,FromValue,ToValue,ResField1,
	ResField2,ResField3,ResField4,ResField5,UpDatedDate,Availability,LastModBy,lastModDate,AuthId,AuthDate)
	SELECT CmpSchCode,ChangeType,Description,FromValue,ToValue,ResField1,ResField2,ResField3,ResField4,ResField5,GETDATE(),1,1,GETDATE(),1,GETDATE()
	FROM Cn2Cs_Prk_NVSchemeMasterControl WHERE DownLoadFlag='Y' AND CmpSchCode NOT IN(SELECT CmpSchCode FROM SchToAvoid)

	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ClaimSettlementDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ClaimSettlementDetails
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClaimSettlementDetails 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_ClaimSettlementDetails
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClaimSettlementDetails
* PURPOSE		: To Download the Claim Settlement details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @Taction  			INT
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @DebitNoteNumber	NVARCHAR(500)
	DECLARE @CrDbNoteDate		DATETIME
	DECLARE @CrDbNoteReason		NVARCHAR(500)
	DECLARE @CreditNoteNumber	NVARCHAR(500)
	DECLARE @SpmId				INT
	DECLARE @DebitNo			NVARCHAR(500)
	DECLARE @CreditNo			NVARCHAR(500)
	DECLARE @ClaimNumber		NVARCHAR(500)
	DECLARE @ClmId				INT
	DECLARE @AccCoaId			INT
	DECLARE @ClmGroupId			INT
	DECLARE @ClmGroupNumber		NVARCHAR(500)
	DECLARE @CrDbNoteAmount		NUMERIC(38,6)
	DECLARE @CmpId				INT
	DECLARE @VocNo				NVARCHAR(500)

	DECLARE @ClaimSheetNo		NVARCHAR(500)

	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimSettleToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimSettleToAvoid	
	END
	CREATE TABLE ClaimSettleToAvoid
	(
		ClaimSheetNo NVARCHAR(50),
		ClaimRefNo	 NVARCHAR(50),
		CreditNoteNo NVARCHAR(50)
	)
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','ClaimRefNo','Claim Ref No should not be empty for :'+CreditNoteNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE CreditDebitNoteAmt<0)
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE CreditDebitNoteAmt<0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Amount','Amount should be greater than zero for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE CreditDebitNoteAmt<0
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Credit/Debite Note No','Credit/Debite Note No should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')=''
	END

--	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
--	WHERE ISNULL(CreditDebitNoteReason,'')='')
--	BEGIN
--		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
--		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
--		WHERE ISNULL(CreditDebitNoteReason,'')=''
--		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
--		SELECT DISTINCT 1,'Claim Settlement','Reason','Reason should not be empty for :'+ClaimRefNo
--		FROM Cn2Cs_Prk_ClaimSettlementDetails
--		WHERE ISNULL(CreditDebitNoteReason,'')=''
--	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(CreditDebitNoteDate,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditDebitNoteDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Date should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditDebitNoteDate,'')=''
	END

	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
	(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId))
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Claim Reference Number :'+ClaimRefNo+'does not exists'
		FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)
	END

	DECLARE Cur_ClaimSettlement CURSOR	
	FOR SELECT  ISNULL([ClaimSheetNo],''),ISNULL([ClaimRefNo],''),ISNULL([CreditNoteNo],'0'),ISNULL([DebitNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CreditDebitNoteDate],121),
	CAST(ISNULL([CreditDebitNoteAmt],0)AS NUMERIC(38,6)),
	ISNULL([CreditDebitNoteReason],'')
	FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CreditNoteNo NOT IN
	(SELECT ClaimRefNo+'~'+CreditNoteNo FROM ClaimSettleToAvoid)	
	OPEN Cur_ClaimSettlement
	FETCH NEXT FROM Cur_ClaimSettlement INTO @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,
	@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
	WHILE @@FETCH_STATUS=0
	BEGIN

		IF @CreditNoteNumber=''
		BEGIN
			SET @CreditNoteNumber='0'
		END

		IF @DebitNoteNumber=''
		BEGIN
			SET @DebitNoteNumber='0'
		END

--		SELECT @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,
--		@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason

		SET @Po_ErrNo=0
		SET @ErrStatus=1

		SELECT @ClmId=B.ClmId FROM ClaimSheetDetail B INNER JOIN ClaimSheetHd A ON A.ClmId=B.ClmId
		WHERE B.RefCode=@ClaimNumber AND A.ClmCode=@ClaimSheetNo

		SELECT @ClmGroupId=ClmGrpId,@ClmGroupNumber=ClmCode,@CmpId=CmpId FROM ClaimSheetHd WHERE ClmId=@ClmId

		SELECT @AccCoaId=CoaId FROM ClaimGroupMaster WHERE ClmGrpId=@ClmGroupId
		SELECT @SpmId=SpmId FROM Supplier WHERE SpmDefault=1 AND CmpId=@CmpId

		IF @SpmId=0
		BEGIN
			SET @ErrDesc = 'Default Supplier does not exists'
			INSERT INTO Errorlog VALUES (8,'Claim Settlement','Supplier',@ErrDesc)
			SET @Po_ErrNo=1	
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF @DebitNoteNumber = '0' AND @CreditNoteNumber<> '0'
			BEGIN
--				SELECT 'Db',@DebitNoteNumber,@CreditNoteNumber
				SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteSupplier','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
				
				INSERT INTO CreditNoteSupplier(CrNoteNumber,CrNoteDate,SpmId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,CrNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@CreditNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,16,
				'Cmp-'+@CreditNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')

				UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteSupplier' AND Fldname = 'CrNoteNumber'

				EXEC Proc_VoucherPosting 32,1,@CreditNo,3,6,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
				
				IF @ErrStatus<>1
				BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Credit Note Voucher Posting Failed for Claim Ref No:' + @ClaimNumber
					INSERT INTO Errorlog
					VALUES (9,'Claim Settlement','Credit Note Voucher Posting',@ErrDesc)
				END
				IF @Po_ErrNo=0
				BEGIN
					SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=6
					AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)

					IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
					BEGIN
						EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
					END

					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,CrDbmode=2,CrDbStatus=1,CrDbNotenumber=@CreditNo,Status=2
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE Cn2Cs_Prk_ClaimSettlementDetails SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber AND ClaimSheetNo=@ClaimSheetNo
				END
			END					
			ELSE IF @DebitNoteNumber <> '0' AND @CreditNoteNumber= '0'
			BEGIN
--				SELECT 'Db',@DebitNoteNumber,@CreditNoteNumber

				SELECT @DebitNo=dbo.Fn_GetPrimaryKeyString('DebitNoteSupplier','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))

				INSERT INTO DebitNoteSupplier(DbNoteNumber,DbNoteDate,SpmId,CoaId,ReasonId,Amount,DbAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,DbNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@DebitNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,33,
				'Cmp-'+@DebitNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')

				UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteSupplier' AND Fldname = 'DbNoteNumber'
			
				EXEC Proc_VoucherPosting 33,1,@DebitNo,3,7,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
				
				SELECT * FROM DebitNoteSupplier

				IF @ErrStatus<>1
				BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Debit Note Voucher Posting Failed'
					INSERT INTO Errorlog VALUES (10,'Claim Settlement','Debit Note Voucher Posting',@ErrDesc)
				END
		
				IF @Po_ErrNo=0
				BEGIN
					SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=7
					AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)

					IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
					BEGIN
						EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
					END

--					SELECT * FROM ClaimSheetDetail WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,RecommendedAmount=@CrDbNoteAmount,
					CrDbmode=1,CrDbStatus=1,CrDbNotenumber=@DebitNo,Status=2
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

--					SELECT * FROM ClaimSheetDetail WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE Cn2Cs_Prk_ClaimSettlementDetails SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber AND ClaimSheetNo=@ClaimSheetNo
				END
			END	
		END
		FETCH NEXT FROM Cur_ClaimSettlement INTO @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
	END
	CLOSE Cur_ClaimSettlement
	DEALLOCATE Cur_ClaimSettlement

	SET @Po_ErrNo=0

END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_PostVoucherCounterReset' AND XTYPE='P')
DROP PROCEDURE Proc_PostVoucherCounterReset
GO
--EXEC Proc_PostVoucherCounterReset '','','','',''
CREATE PROCEDURE Proc_PostVoucherCounterReset
(
	@Pi_TabName		NVARCHAR(50),
	@Pi_FldName		NVARCHAR(50),
	@Pi_CurVal		NVARCHAR(100),
	@Pi_VocDate 		DATETIME,
	@Po_NewVoc		NVARCHAR(100) OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PostVoucherCounterReset
* PURPOSE	: To do ReOrder the Back Dated Vouchers
* CREATED	: Nandakumar R.G
* CREATED DATE	: 09/03/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
		
	DECLARE @VocRefNo	NVARCHAR(50)
	DECLARE	@OldJVCount	INT
	DECLARE @Prefix		NVARCHAR(10)
	DECLARE @Year		NVARCHAR(10)
	DECLARE @zPad		INT
	DECLARe @NewCount	INT
	DECLARE @BaseCount	INT
	DECLARE @VocType	INT
	DECLARE @TempNewNo	TABLE
	(
		SlNo		INT,
		OldVocNo	NVARCHAR(50),
		NewNo		NVARCHAR(50)
	)
	--Get the Voucher Type
	IF @Pi_FldName='ContraVoc'
	BEGIN
		SET @VocType=0
	END
	ELSE IF @Pi_FldName='PaymentVoc'
	BEGIN
		SET @VocType=1
	END
	ELSE IF @Pi_FldName='ReceiptVoc'
	BEGIN
		SET @VocType=2
	END
	ELSE IF @Pi_FldName='JournalVoc'
	BEGIN
		SET @VocType=3
	END
	ELSE IF @Pi_FldName='SalesVoc'
	BEGIN
		SET @VocType=4
	END
	ELSE IF @Pi_FldName='PurchaseVoc'
	BEGIN
		SET @VocType=5
	END
	ELSE IF @Pi_FldName='MemoVoc'
	BEGIN
		SET @VocType=6
	END
	--Get the Prefix,Year,Zpad and Old Voucher Count from Counters
	SELECT @Prefix = Prefix,@Year = RIGHT(CurYear,2),@zPad = ZPad,@OldJVCount = CurrValue
	FROM Counters(NOLOCK) WHERE TabName=@Pi_TabName AND FldName=@Pi_FldName
	--Get the last voucher posted on previous date 
     SELECT  @BaseCount=MAX(ISNULL(CAST(SubString(VocRefNo,(LEN(@Prefix)+3),
	(LEN(VocRefNo) - (LEN(@Prefix)+2))) AS BIGINT),0) )
	FROM StdVocMaster (NOLOCK)
	WHERE VocType=@VocType AND VocDate < @Pi_VocDate 
--	SELECT @BaseCount = CAST(ISNULL(MAX(SubString(VocRefNo,(LEN(@Prefix)+3),
--	(LEN(VocRefNo) - (LEN(@Prefix)+2)))),0) AS INT)
--	FROM StdVocMaster (NOLOCK)
--	WHERE VocType=@VocType AND VocDate < @Pi_VocDate
	--Create a Table to store Old and New Voucher Nos
	IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[ReOrderVoucher]') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	DROP TABLE [ReOrderVoucher]
	CREATE TABLE ReOrderVoucher
	(
		SlNo		INT IDENTITY(1,1),
		OldVocNo	NVARCHAR(50),
		OldVocDate	DATETIME,
		NewVocNo	NVARCHAR(50)
	)
	--Insert the Old and New Voucher Nos
	INSERT INTO ReOrderVoucher(OldVocNo,OldVocDate,NewVocNo)
	SELECT VocRefNo,VocDate,'' FROM StdVocMaster(NOLOCK) WHERE VocType=@VocType AND VocDate >= @Pi_VocDate
	ORDER BY VocDate,VocRefNo
	INSERT INTO @TempNewNo(SlNo,OldVocNo,NewNo)	
	SELECT SlNo,OldVocNo,@Prefix+CAST(RIGHT(ACM.AcmYr,2) AS NVARCHAR(2))+dbo.Fn_ReturnzPad(@ZPad,SlNo+@BaseCount) AS NewNo 	
	FROM ReOrderVoucher (NOLOCK),AcMaster ACM (NOLOCK),AcPeriod ACP (NOLOCK)
	WHERE ACM.AcmId=ACP.AcmId AND OldVocDate BETWEEN ACP.AcmSdt AND ACP.AcmEdt
	UPDATE ReOrderVoucher SET NewVocNo=NewNo
	FROM @TempNewNo A WHERE ReOrderVoucher.SlNo=A.SlNo AND ReOrderVoucher.OldVocNo collate database_default=A.OldVocNo collate database_default
	--Get the New Voucher No for the given input
	SELECT @Po_NewVoc=NewVocNo FROM ReOrderVoucher(NOLOCK) WHERE OldVocNo=@Pi_CurVal	
-- 	--Remove the Key Constrains
-- 	IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster' 
--         AND Xtype = 'F') BEGIN  ALTER TABLE [dbo].[StdVocDetails] DROP CONSTRAINT 
--         [FK_StdVocDetails_StdVocMaster] END
--                     
--         IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND Xtype = 'PK')
--         BEGIN ALTER TABLE [dbo].[StdVocMaster] DROP CONSTRAINT [PK_StdVocMaster] END
	--Update Voucher tables with New Voucher Nos
		
	UPDATE StdVocDetails SET VocRefNo=NewVocNo
	FROM ReOrderVoucher(NOLOCK),StdVocMaster (NOLOCK) 
	WHERE StdVocDetails.VocRefNo=ReOrderVoucher.OldVocNo 
	AND StdVocDetails.VocRefNo=StdVocMaster.VocRefNo	
	AND StdVocMaster.VocType=@VocType
	
	UPDATE StdVocMaster SET VocRefNo=NewVocNo
	FROM ReOrderVoucher (NOLOCK)
	WHERE StdVocMaster.VocRefNo=ReOrderVoucher.OldVocNo AND StdVocMaster.VocType=@VocType
-- 	--Add the constarints again
-- 	IF NOT EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND 
-- 	Xtype = 'PK') BEGIN ALTER TABLE [dbo].[StdVocMaster] ADD CONSTRAINT [PK_StdVocMaster] 
-- 	PRIMARY KEY  CLUSTERED ([VocRefno])  ON [PRIMARY] END	
-- 	                    
-- 	IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster' 
-- 	AND Xtype = 'F') BEGIN ALTER TABLE [dbo].[StdVocDetails] ADD CONSTRAINT 
-- 	[FK_StdVocDetails_StdVocMaster] FOREIGN KEY ([VocRefno]) REFERENCES [StdVocMaster] 
-- 	([VocRefno]) END 
	--Update the counters with New Value 
	SELECT @NewCount=MAX(SlNo)+@BaseCount FROM ReOrderVoucher(NOLOCK)
	UPDATE Counters SET CurrValue=@NewCount
	WHERE TabName=@Pi_TabName AND FldName=@Pi_FldName
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_VoucherPosting' AND XTYPE='P')
DROP PROCEDURE Proc_VoucherPosting
GO
--EXEC Proc_VoucherPosting 250,1,'HQP0900023',1,1,1,'2009-07-31',0
CREATE Procedure Proc_VoucherPosting
(
	@Pi_TransId		Int,
	@Pi_SubTransId		Int,
	@Pi_ReferNo		nVarChar(100),
	@Pi_VocType		INT,
	@Pi_SubVocType		INT,	
	@Pi_UserId		Int,
	@Pi_VocDate		DateTime,
	@Po_ErrNo		Int OutPut
)
AS
/*********************************
* PROCEDURE	: Proc_VoucherPosting
* PURPOSE	: General SP for posting Voucher
* CREATED	: Thrinath
* CREATED DATE	: 25/08/2007
* MODIFIED
* DATE				AUTHOR				DESCRIPTION
* 29/07/2009		MarySubashini.S		Cheque Disbursal Cash Payment
* 30/07/2009		MarySubashini.S		HQ-Payment Posting
------------------------------------------------
* {date} {developer}  {brief modification description}
iTrans_OrderBooking = 1
iTrans_Billing = 2
iTrans_SalesReturn = 3
iTrans_LocationTransfer = 4
iTrans_Purchase = 5
iTrans_VanLoadUnload = 6
iTrans_PurchaseReturn = 7
iTrans_DebitMemo = 8
iTrans_Collection = 9
iTrans_CheuqeBounce = 10
iTrans_ChequePayment = 11
iTrans_CashBounce = 12
iTrans_StockManagement = 13
iTrans_BatchTransfer = 14
iTrans_PaymentReversal = 15
iTrans_ClaimSettlement = 16
iTrans_IRA = 17
iTrans_CreditNoteRetailer = 18
iTrans_DebitNoteRetailer = 19
iTrans_Replacement = 20
iTrans_Salvage = 21
iTrans_PaymentRegister = 22
iTrans_MarketReturn = 23
iTrans_ReturnandReplacement = 24
iTrans_SalesPanel = 25
iTrans_PurchaseOrder = 26
iTrans_SchemeMonitor = 27
iTrans_VehicleAllocation = 28
iTrans_DeliveryProcess = 29
iTrans_CreditNoteReplace = 30
iTrans_ResellDamage = 31
iTrans_CreditNoteSupplier = 32
iTrans_DebitNoteSupplier = 33
iTrans_RetailerOnAccount = 34
iTrans_CreditDebitAdjust = 35
iTrans_ChequeDisbursal = 36
iTrans_ReturnToCompany = 37
iTrans_StockJournal = 38
iTrans_StdVoucher = 39
iTrans_RouteCovPlan = 40
iTrans_RetailerShipAdd = 41
iTrans_ContPriceMaster = 42
iTrans_CollDiscMaster = 43
iTrans_ChqInvRetiler = 44
iTrans_SchemeMaster = 45
iTrans_TargetAnalysis = 46
iTrans_UOM = 47
iTrans_KitPrdMaster = 48
iTrans_PrdSalBundle = 49
iTrans_PurOrdNormMap = 50
iTrans_TargetNormMap = 51
iTrans_InventoryConsole = 52
iTrans_ChequeInventorySupp = 53
iTrans_PointRedemptionRule = 54
iTrans_PointRedemptionScreen = 55
iTrans_RspPunchingWindow = 56
iTrans_SubStockistEntry = 57
iTrans_LaunchProduct = 58
iTrans_CouponDefinition = 59
iTrans_CouponDenomination = 60
iTrans_CouponCollection = 61
iTrans_CouponRedemption = 62
iTrans_CouponMonitor = 63
iTrans_Attendance = 64
iTrans_FocusBrand = 65
iTrans_SalesmanIncCalc = 66
iTrans_ManualClaim = 104
iTrans_SplDiscountClaim = 143
iTrans_SalesmanSalaryAndDAClaim = 96
iTrans_DeliveryBoyClaim = 217
iTrans_TransporterClaim = 136
iTrans_RateDifferenceClaim = 97
iTrans_PurchaseShortageClaim = 99
iTrans_PurchaseExcessClaim = 105
iTrans_SpentReceived = 173
iTrans_VanSubsidyClaim = 178
iTrans_HQPaymentRegister = 250
*********************************/
SET NOCOUNT ON
BEGIN
	
DECLARE @ErrStatus		INT
DECLARE	@InvRcpSno		INT
DECLARE @ReplaceNo		nVarChar(100)
DECLARE @PayMode 		INT
DECLARE @ChqNo 			NVARCHAR(500)
DECLARE @AcmId			INT
SET @ErrStatus = 1
	--Claim
	SELECT @AcmId=ACM.AcmId FROM AcMaster ACM,AcPeriod ACP
	WHERE ACM.AcmId=ACP.AcmId AND @Pi_VocDate BETWEEN AcmSdt AND AcmEdt
	IF EXISTS(SELECT * FROM YearEnd WHERE AcmId=@AcmId)
	BEGIN
		SET @ErrStatus=-29
	END
	ELSE
	BEGIN
		IF @Pi_TransId= 153 OR  @Pi_TransId=178 OR @Pi_TransId=173 OR @Pi_TransId=96 OR @Pi_TransId=217
			OR @Pi_TransId=104 OR @Pi_TransId= 16 OR  @Pi_TransId= 66	-- Sales
		BEGIN
			IF @Pi_TransId = 16
			BEGIN
				IF (SELECT ISNULL(SUM(A.RecommendedAmount),0) FROM ClaimSheetDetail A INNER JOIN ClaimSheetHD B
				ON A.ClmId=B.ClmId WHERE B.ClmCode = @Pi_ReferNo AND A.SelectMode=1 AND A.CrDbStatus=0)>0
				BEGIN
					EXEC Proc_VoucherPostingClaim @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
			ELSE
			BEGIN
				EXEC Proc_VoucherPostingClaim @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
				@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
		END
		IF @Pi_TransId=3		-- Sales
		BEGIN
			IF @Pi_SubTransId = 1
			BEGIN
				EXEC Proc_VoucherPostingSales @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
	
		END
		IF @Pi_TransId = 5
		BEGIN
			IF @Pi_SubTransId = 1
			BEGIN
				EXEC Proc_VoucherPostingPurchase @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 2
			BEGIN
				IF EXISTS (SELECT * FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo AND
					HandlingCharges > 0)
				BEGIN
					EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
			IF @Pi_SubTransId = 3
			BEGIN
				IF EXISTS (SELECT ISNULL(SUM(B.Amount),0)FROM PurchaseReceipt A
					INNER JOIN PurchaseReceiptOtherCharges B ON A.PurRcptId = B.PurRcptId
						WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 1
					HAVING ISNULL(SUM(B.Amount),0) > 0)
				BEGIN
					EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
			IF @Pi_SubTransId = 4
			BEGIN
				EXEC Proc_VoucherPostingDebitNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 5
			BEGIN
				EXEC Proc_VoucherPostingDebitNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 6
			BEGIN
				EXEC Proc_VoucherPostingDebitNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 7
			BEGIN
				EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 8
				BEGIN
					IF EXISTS (SELECT ISNULL(SUM(B.Amount),0)FROM PurchaseReceipt A
						INNER JOIN PurchaseReceiptOtherCharges B ON A.PurRcptId = B.PurRcptId
							WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 2
							HAVING ISNULL(SUM(B.Amount),0) > 0)
					BEGIN
						IF EXISTS(SELECT B.CoaID FROM COAMaster A
							INNER JOIN PurchaseReceiptOtherCharges B on A.CoaId=B.CoaId Where A.AcCode Like '4%')	--ExpenseAccount
						BEGIN	
							EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
								@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
						END
						IF EXISTS(SELECT B.CoaID FROM COAMaster A
							INNER JOIN PurchaseReceiptOtherCharges B on A.CoaId=B.CoaId Where A.AcCode Like '3%')	--IncomeAccount
						BEGIN
							EXEC Proc_VoucherPostingCashReceipt @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,3,
								@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
						END
					END
				END
			
		END
		IF @Pi_TransId = 7		--Purchase Return
		BEGIN
			IF @Pi_SubTransId = 1
			BEGIN
				EXEC Proc_VoucherPostingPurchase @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
		END
		IF @Pi_TransId = 9		--Collection Register
		BEGIN
			IF @Pi_SubTransId = 1 -- (Bill Invoice)
			BEGIN
				---Cash Account Receipt	
				DECLARE VoucherReceiptModeCash_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM ReceiptInvoice WHERE InvRcpNo=@Pi_ReferNo and CanCelStatus=1
						and InvRcpMode=1
				     )
				OPEN VoucherReceiptModeCash_cursor
				FETCH NEXT FROM VoucherReceiptModeCash_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingCashReceipt @Pi_TransId,@Pi_SubTransId,@InvRcpSno,@Pi_VocType,3,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeCash_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeCash_cursor
				DEALLOCATE VoucherReceiptModeCash_cursor
				---Bank Account Receipt	
				DECLARE VoucherReceiptModeChqDD_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM ReceiptInvoice WHERE InvRcpNo=@Pi_ReferNo and CanCelStatus=1
						and InvRcpMode In(3,4,8) AND PostChequeVoucher=1
					
				     )
				OPEN VoucherReceiptModeChqDD_cursor
				FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingBankReceipt @Pi_TransId,@Pi_SubTransId,@InvRcpSno,@Pi_VocType,4,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeChqDD_cursor
				DEALLOCATE VoucherReceiptModeChqDD_cursor
		
				---Cash Discount Account Receipt
				DECLARE VoucherReceiptModeCashDisc_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM ReceiptInvoice WHERE InvRcpNo=@Pi_ReferNo and
						CanCelStatus=1 and InvRcpMode=2
				     )
				OPEN VoucherReceiptModeCashDisc_cursor
				FETCH NEXT FROM VoucherReceiptModeCashDisc_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@InvRcpSno,2,6,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeCashDisc_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeCashDisc_cursor
				DEALLOCATE VoucherReceiptModeCashDisc_cursor
			END
			IF @Pi_SubTransId = 5  -- (Debit Invoice)
			BEGIN
				---Cash Account Receipt	
				DECLARE VoucherReceiptModeCash_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM DebitInvoice WHERE InvRcpNo=@Pi_ReferNo and CanCelStatus=1
						and InvRcpMode=1
				     )
				OPEN VoucherReceiptModeCash_cursor
				FETCH NEXT FROM VoucherReceiptModeCash_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingCashReceipt @Pi_TransId,@Pi_SubTransId,@InvRcpSno,@Pi_VocType,3,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeCash_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeCash_cursor
				DEALLOCATE VoucherReceiptModeCash_cursor
				---Bank Account Receipt	
				DECLARE VoucherReceiptModeChqDD_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM DebitInvoice WHERE InvRcpNo=@Pi_ReferNo and CanCelStatus=1
						and InvRcpMode In(3,4,8) AND PostChequeVoucher=1
					
				     )
				OPEN VoucherReceiptModeChqDD_cursor
				FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingBankReceipt @Pi_TransId,@Pi_SubTransId,@InvRcpSno,@Pi_VocType,4,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeChqDD_cursor
				DEALLOCATE VoucherReceiptModeChqDD_cursor
		
				---Cash Discount Account Receipt
				DECLARE VoucherReceiptModeCashDisc_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM DebitInvoice WHERE InvRcpNo=@Pi_ReferNo and
						CanCelStatus=1 and InvRcpMode=2
				     )
				OPEN VoucherReceiptModeCashDisc_cursor
				FETCH NEXT FROM VoucherReceiptModeCashDisc_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@InvRcpSno,2,6,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeCashDisc_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeCashDisc_cursor
				DEALLOCATE VoucherReceiptModeCashDisc_cursor
			END
			IF @Pi_SubTransId = 0 --(Bill Invoice)
			BEGIN
				---Cash Account ReceiptCancel	
				If Exists(SELECT InvRcpSno FROM ReceiptInvoice WHERE InvRcpSno=@Pi_ReferNo and CanCelStatus=0 and InvRcpMode=1)
				BEGIN
					SELECT @InvRcpSno=InvRcpSno FROM ReceiptInvoice WHERE InvRcpSno=@Pi_ReferNo and
						CanCelStatus=0 and InvRcpMode=1
					EXEC Proc_VoucherPostingCashReceipt @Pi_TransId,@Pi_SubTransId,@InvRcpSno,@Pi_VocType,3,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
				
				---Cash Discount Account Receipt
				If EXISTS(SELECT InvRcpSno FROM ReceiptInvoice WHERE InvRcpSno=@Pi_ReferNo and CanCelStatus=0 and InvRcpMode=2)
				BEGIN
					SELECT @InvRcpSno=InvRcpSno FROM ReceiptInvoice WHERE InvRcpSno=@Pi_ReferNo and
						CanCelStatus=0 and InvRcpMode=2
					EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@InvRcpSno,2,6,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END	
			END
			IF @Pi_SubTransId = 6 --(Debit Invoice)
			BEGIN
				---Cash Account ReceiptCancel	
				If Exists(SELECT InvRcpSno FROM DebitInvoice WHERE InvRcpSno=@Pi_ReferNo and CanCelStatus=0 and InvRcpMode=1)
				BEGIN
					SELECT @InvRcpSno=InvRcpSno FROM DebitInvoice WHERE InvRcpSno=@Pi_ReferNo and
						CanCelStatus=0 and InvRcpMode=1
					EXEC Proc_VoucherPostingCashReceipt @Pi_TransId,@Pi_SubTransId,@InvRcpSno,@Pi_VocType,3,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
				
				---Cash Discount Account Receipt
				If EXISTS(SELECT InvRcpSno FROM DebitInvoice WHERE InvRcpSno=@Pi_ReferNo and CanCelStatus=0 and InvRcpMode=2)
				BEGIN
					SELECT @InvRcpSno=InvRcpSno FROM DebitInvoice WHERE InvRcpSno=@Pi_ReferNo and
						CanCelStatus=0 and InvRcpMode=2
					EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@InvRcpSno,2,6,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END	
			END
			IF @Pi_SubTransId = 2  --(Bill Invoice)
			BEGIN
				---Cheque Bank Account Receipt	
				DECLARE VoucherReceiptModeChqDD_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM ReceiptInvoice WHERE InvRcpSNo=@Pi_ReferNo and CanCelStatus=1
						and InvRcpMode In(3,4) AND PostChequeVoucher=2 
					
				     )
				OPEN VoucherReceiptModeChqDD_cursor
				FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingBankReceipt @Pi_TransId,1,@InvRcpSno,@Pi_VocType,4,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeChqDD_cursor
				DEALLOCATE VoucherReceiptModeChqDD_cursor
			END		
			IF @Pi_SubTransId = 7  --(Debit Invoice)
			BEGIN
				---Cheque Bank Account Receipt	
				DECLARE VoucherReceiptModeChqDD_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM DebitInvoice WHERE InvRcpSNo=@Pi_ReferNo and CanCelStatus=1
						and InvRcpMode In(3,4) AND PostChequeVoucher=2
					
				     )
				OPEN VoucherReceiptModeChqDD_cursor
				FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingBankReceipt @Pi_TransId,5,@InvRcpSno,@Pi_VocType,4,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeChqDD_cursor
				DEALLOCATE VoucherReceiptModeChqDD_cursor
			END		
			IF @Pi_SubTransId = 3  --(Bill Invoice)
			BEGIN
				---Cheque Bank Account Receipt	
				DECLARE VoucherReceiptModeChqDD_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM ReceiptInvoice WHERE InvRcpSNo=@Pi_ReferNo and CanCelStatus=1
						and InvRcpMode In(3,4) AND PostChequeVoucher=3
					
				     )
				OPEN VoucherReceiptModeChqDD_cursor
				FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingBankReceipt @Pi_TransId,1,@InvRcpSno,@Pi_VocType,4,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeChqDD_cursor
				DEALLOCATE VoucherReceiptModeChqDD_cursor
			END	
			IF @Pi_SubTransId = 8  --(Debit Invoice)
			BEGIN
				---Cheque Bank Account Receipt	
				DECLARE VoucherReceiptModeChqDD_cursor CURSOR
				FOR  (
				 	SELECT InvRcpSno FROM DebitInvoice WHERE InvRcpSNo=@Pi_ReferNo and CanCelStatus=1
						and InvRcpMode In(3,4) AND PostChequeVoucher=3
					
				     )
				OPEN VoucherReceiptModeChqDD_cursor
				FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingBankReceipt @Pi_TransId,5,@InvRcpSno,@Pi_VocType,4,
						@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherReceiptModeChqDD_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherReceiptModeChqDD_cursor
				DEALLOCATE VoucherReceiptModeChqDD_cursor
			END		
			
		END
		IF @Pi_TransId=10	--Cheque Bouncing
		BEGIN
			IF @Pi_SubTransId = 1 OR @Pi_SubTransId = 3		--Debit Note for Retailer
			BEGIN
				EXEC Proc_VoucherPostingDebitNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,1,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END

			IF @Pi_SubTransId = 2 OR @Pi_SubTransId = 4		--Bank Charges paid to the Bank
			BEGIN
				IF EXISTS (SELECT Penality FROM ChequePayment WHERE ChequePayId = @Pi_ReferNo
					AND Penality > 0 )
				BEGIN
					EXEC Proc_VoucherPostingBankPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,1,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
		END
		
		IF @Pi_TransId = 13
		BEGIN
			IF @Pi_SubTransId = 1 OR @Pi_SubTransId=0
			BEGIN
				EXEC Proc_VoucherPostingPurchase @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,0,
				@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
	-- 		IF @Pi_SubTransId = 0
	-- 		BEGIN
	-- 			EXEC Proc_VoucherPostingSales @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,0,
	-- 			@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
	-- 		END
		END
		IF @Pi_TransId = 18  OR @Pi_TransId = 32
		BEGIN
			EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
				@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
		END
		IF @Pi_TransId = 19  OR @Pi_TransId = 33
		BEGIN
			EXEC Proc_VoucherPostingDebitNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
			@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
		END
		
		IF @Pi_TransId = 22	--Payment Register
		BEGIN
			IF @Pi_SubTransId = 1 	--Cash Payment
			BEGIN
				IF EXISTS(SELECT PayAdvNo FROM PurchasePaymentDetails WHERE PayAdvNo=@Pi_ReferNo And PayMode = 1)
				BEGIN
					EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
		 	END
			IF @Pi_SubTransId = 2 	--Bank Payment
			BEGIN
				IF EXISTS(SELECT PayAdvNo FROM PurchasePaymentDetails WHERE PayAdvNo=@Pi_ReferNo And PayMode IN (2,3,5))
				BEGIN
					DECLARE VoucherPaymentModeChqDD_cursor CURSOR
					FOR  (
					 	SELECT PayMode,PayInsNo FROM PurchasePaymentDetails WHERE PayAdvNo=@Pi_ReferNo
						And PayMode in (2,3,5)
						
					     )
					OPEN VoucherPaymentModeChqDD_cursor
					FETCH NEXT FROM VoucherPaymentModeChqDD_cursor INTO @PayMode,@ChqNo
					WHILE @@FETCH_STATUS = 0
					BEGIN	 		
						EXEC Proc_VoucherPostingBankPay @Pi_TransId,@PayMode,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@ChqNo,@Po_PurErrNo = @ErrStatus OUTPUT
	
						FETCH NEXT FROM VoucherPaymentModeChqDD_cursor INTO  @PayMode,@ChqNo
					END
					CLOSE VoucherPaymentModeChqDD_cursor
					DEALLOCATE VoucherPaymentModeChqDD_cursor
				END
	
			END
		END
		IF @Pi_TransId = 24
		BEGIN
			EXEC Proc_VoucherPostingSales @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
				@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
		END
		IF @Pi_TransId = 29 	--Billing
		BEGIN
			IF @Pi_SubTransId = 1	--  Billing Voucher
			BEGIN
				EXEC Proc_VoucherPostingSales @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 2	-- Other Charges Add Expeneses Billing
			BEGIN
				IF EXISTS (SELECT ISNULL(SUM(B.AdjAmt),0)FROM SalesInvoice A INNER JOIN SalInvOtherAdj B ON
						A.SalId = B.SalId INNER JOIN PurSalAccConfig C
						ON C.AccDescId = B.AccDescId AND C.TransactionId=2
					WHERE A.SalInvno = @Pi_ReferNo AND C.Effect = 0
					HAVING ISNULL(SUM(B.AdjAmt),0) > 0)
				BEGIN
					EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
			IF @Pi_SubTransId = 3	--Market Return
			BEGIN
				IF EXISTS (SELECT MarketRetAmount FROM SalesInvoice Where MarketRetAmount >0
					AND SalInvno = @Pi_ReferNo)
				BEGIN
					EXEC Proc_VoucherPostingSales @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
			IF @Pi_SubTransId = 4	--Replacement sales
			BEGIN
				SET @ReplaceNo = ''
				SELECT @ReplaceNo = RepRefNo from ReplacementHd A INNER JOIN SalesInvoice B
					ON A.SalId = B.SalId AND B.SalInvNo = @Pi_ReferNo
				IF LTRIM(RTRIM(@ReplaceNo)) <> ''
				BEGIN
					EXEC Proc_VoucherPostingSales @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
			IF @Pi_SubTransId = 5	--Repalcement Sales Return
			BEGIN
				SET @ReplaceNo = ''
				SELECT @ReplaceNo = RepRefNo from ReplacementHd A INNER JOIN SalesInvoice B
					ON A.SalId = B.SalId AND B.SalInvNo = @Pi_ReferNo
				IF LTRIM(RTRIM(@ReplaceNo)) <> ''
				BEGIN
					EXEC Proc_VoucherPostingSales @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
			IF @Pi_SubTransId = 6	--Cash Sales
			BEGIN
				EXEC Proc_VoucherPostingCashReceipt @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 7	--Repalcement Debit Entry
			BEGIN
				SET @ReplaceNo = ''
				SELECT @ReplaceNo = RepRefNo from ReplacementHd A INNER JOIN SalesInvoice B
					ON A.SalId = B.SalId AND B.SalInvNo = @Pi_ReferNo
				IF LTRIM(RTRIM(@ReplaceNo)) <> ''
				BEGIN
					EXEC Proc_VoucherPostingSales @Pi_TransId,@Pi_SubTransId,@ReplaceNo,@Pi_VocType,
						@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
				END
			END
		END
		
		IF @Pi_TransId = 34
		BEGIN
			IF @Pi_SubTransId = 1
			BEGIN
				EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 2
			BEGIN
				EXEC Proc_VoucherPostingBankPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 3
			BEGIN
				EXEC Proc_VoucherPostingCashReceipt @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 4
			BEGIN
				EXEC Proc_VoucherPostingBankReceipt @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 5
			BEGIN
				EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 6
			BEGIN
				EXEC Proc_VoucherPostingBankPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 7
			BEGIN
				EXEC Proc_VoucherPostingCashReceipt @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 8
			BEGIN
				EXEC Proc_VoucherPostingBankReceipt @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
		END
		IF @Pi_TransId=36
		BEGIN
			IF @Pi_SubTransId=1
			BEGIN
				EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId=2
			BEGIN
				EXEC Proc_VoucherPostingBankPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId=3
			BEGIN
				EXEC Proc_VoucherPostingBankPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId=4
			BEGIN
				EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
		END
		IF @Pi_TransId = 38
		BEGIN
			IF @Pi_SubTransId = 1
			BEGIN
				EXEC Proc_VoucherPostingDebitNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 2
			BEGIN
				EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
		END
		IF @Pi_TransId = 14
		BEGIN
			IF @Pi_SubTransId = 1
			BEGIN
				EXEC Proc_VoucherPostingDebitNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
			IF @Pi_SubTransId = 2
			BEGIN
				EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
					@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
			END
		END
		IF @Pi_TransId=55 AND @Pi_SubTransId=1
		BEGIN
			EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
				@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
		END
		IF @Pi_TransId=62 AND @Pi_SubTransId=1
		BEGIN
			EXEC Proc_VoucherPostingCreditNote @Pi_TransId,@Pi_SubTransId,@Pi_ReferNo,@Pi_VocType,
				@Pi_SubVocType,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
		END
		
		IF @Pi_TransId = 250	--HQ Payment Register
		BEGIN
			IF @Pi_SubTransId = 1 
			BEGIN
				---Cash Account Payment	
				DECLARE VoucherPaymentModeCash_cursor CURSOR
				FOR  (
				 	SELECT PayRcpSno FROM HQPaymentDetails WHERE PayRcpNo=@Pi_ReferNo 
						AND PayMode=1
				     )
				OPEN VoucherPaymentModeCash_cursor
				FETCH NEXT FROM VoucherPaymentModeCash_cursor INTO @InvRcpSno
				WHILE @@FETCH_STATUS = 0
				BEGIN	 	
					EXEC Proc_VoucherPostingCashPay @Pi_TransId,@Pi_SubTransId,@InvRcpSno,@Pi_VocType,
						1,@Pi_UserId,@Pi_VocDate,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherPaymentModeCash_cursor INTO  @InvRcpSno
				END
				CLOSE VoucherPaymentModeCash_cursor
				DEALLOCATE VoucherPaymentModeCash_cursor
				---Bank Account Receipt	
				DECLARE VoucherPaymentModeChqDD_cursor CURSOR
				FOR  (
				 	SELECT PayRcpSno,InvInsNo FROM HQPaymentDetails WHERE PayRcpNo=@Pi_ReferNo 
						AND PayMode IN(3,4,8) 
				     )
				OPEN VoucherPaymentModeChqDD_cursor
				FETCH NEXT FROM VoucherPaymentModeChqDD_cursor INTO @InvRcpSno,@ChqNo
				WHILE @@FETCH_STATUS = 0
				BEGIN	 		
					EXEC Proc_VoucherPostingBankPay @Pi_TransId,1,@InvRcpSno,@Pi_VocType,
						2,@Pi_UserId,@Pi_VocDate,@ChqNo,@Po_PurErrNo = @ErrStatus OUTPUT
					FETCH NEXT FROM VoucherPaymentModeChqDD_cursor INTO  @InvRcpSno,@ChqNo 
				END
				CLOSE VoucherPaymentModeChqDD_cursor
				DEALLOCATE VoucherPaymentModeChqDD_cursor
			END
		END
	END
	SET @Po_ErrNo = @ErrStatus
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_PurchaseReceipt' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_PurchaseReceipt
GO
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
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim
	TRUNCATE TABLE ETL_Prk_PurchaseReceipt
	--------------------------------------
	DECLARE @ErrStatus			INT
	DECLARE @BatchNo			NVARCHAR(200)
	DECLARE @ProductCode		NVARCHAR(30)
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
	WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already downloaded and ready for invoicing' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0)
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
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE CompInvDate>GETDATE())	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvDate>GETDATE()
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Date','Invoice Date:'+CAST(CompInvDate AS NVARCHAR(10))+' is greater than current date in Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvDate>GETDATE()
	END
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK)))	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice UOM','UOM:'+UOMCode+' is not available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
	END		
	--->Till Here
	SET @ExistCompInvNo=0
	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,PurQty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs,BundleDeal,FreightCharges
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	ORDER BY CompInvNo,CAST(BundleDeal AS NUMERIC(18,0)),ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,UOMCode,PurQty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs
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
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount],[FreightCharges])
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
			[Batch Code],[Qty],[Stock Type],[Amount])
			VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0)
		END
--		SET @RowId=@RowId+1
		FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
		@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId,@FreightCharges
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase
	--To insert into ETL_Prk_PurchaseReceipt
	SELECT @SupplierCode=SpmCode FROM Supplier WHERE SpmDefault=1
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter)
	
	IF @TransporterCode=''
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Purchase Download','Transporter',
		'Transporter not available')
	END
	INSERT INTO ETL_Prk_PurchaseReceipt([Company Code],[Supplier Code],[Company Invoice No],[PO Number],
	[Invoice Date],[Transporter Code],[NetPayable Amount])
	SELECT DISTINCT C.CmpCode,@SupplierCode,P.CompInvNo,'',P.CompInvDate,@TransporterCode,P.NetValue
	FROM Company C,Cn2Cs_Prk_BLPurchaseReceipt P
	WHERE  C.DefaultCompany=1 AND DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
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
					SET @ErrStatus=@ErrStatus
				END
			END
		END
	END
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Validate_PurchaseReceipt' AND XTYPE='P')
DROP PROCEDURE Proc_Validate_PurchaseReceipt
GO
/*
BEGIN TRANSACTION
Exec Proc_Validate_PurchaseReceipt 0
SELECT * FROM ETL_Prk_PurchaseReceipt
SELECT * FROM ETLTempPurchaseReceipt
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_Validate_PurchaseReceipt
(
@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_PurchaseReceipt
* PURPOSE		: To Insert and Update records in the Table PurchaseReceipt
* CREATED		: Nandakumar R.G
* CREATED DATE	: 03/05/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist   AS  INT
	
	DECLARE @CmpCode  AS  NVARCHAR(100)
	DECLARE @SpmCode AS  NVARCHAR(100)
	DECLARE @CmpInvNo AS  NVARCHAR(100)
	DECLARE @PONo  AS  NVARCHAR(100)
	DECLARE @InvoiceDate AS  DATETIME
	DECLARE @TransCode AS  NVARCHAR(100)
	DECLARE @PurRcptNo AS  NVARCHAR(100)
	
	DECLARE @CmpId   AS  INT
	DECLARE @SpmId   AS  INT
	DECLARE @TransId  AS  INT
	DECLARE @NetAmt  AS  NUMERIC(18,0)	
	DECLARE @LcnId   AS  INT
	
	DECLARE @TransStr  AS  NVARCHAR(4000)	
	
	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @Exist=0

	DECLARE Cur_PurchaseReceipt CURSOR
	FOR SELECT DISTINCT ISNULL([Company Code],''),ISNULL([Supplier Code],''),ISNULL([Company Invoice No],''),
	ISNULL([PO Number],''),ISNULL([Invoice Date],GETDATE()),ISNULL([Transporter Code],''),ISNULL([NetPayable Amount],0)
	FROM ETL_Prk_PurchaseReceipt
	
	OPEN Cur_PurchaseReceipt
	FETCH NEXT FROM Cur_PurchaseReceipt INTO @CmpCode,@SpmCode,@CmpInvNo,@PONo,@InvoiceDate,@TransCode,@NetAmt
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0	
		SET @Exist=0
		
		SELECT @CmpId=ISNULL(CmpId,0) FROM Company WITH (NOLOCK) WHERE CmpCode=@CmpCode  											
		SELECT @SpmId=ISNULL(SpmId,0) FROM Supplier WITH (NOLOCK) WHERE SpmCode=@SpmCode
		SELECT @TransId=ISNULL(TransporterId,0) FROM Transporter WITH (NOLOCK) WHERE TransporterCode=@TransCode
		SELECT @LcnId=ISNULL(LcnId,0) FROM Location WHERE DefaultLocation=1		

		IF EXISTS(SELECT * FROM ETLTempPurchaseReceipt WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)
		BEGIN
			DELETE FROM dbo.ETLTempPurchaseReceipt WHERE CmpInvNo=@CmpInvNo
			DELETE FROM dbo.ETLTempPurchaseReceiptProduct WHERE CmpInvNo=@CmpInvNo
			DELETE FROM dbo.ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo=@CmpInvNo
			DELETE FROM dbo.ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo=@CmpInvNo
			DELETE FROM dbo.ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo=@CmpInvNo			 		
		END		
		
		IF @Po_ErrNo=0
		BEGIN
			INSERT INTO ETLTempPurchaseReceipt(CmpId,SpmId,PONo,CmpInvNo,InvDate,LcnId,TransporterId,NetAmt,DownLoadStatus)
			VALUES(@CmpId,@SpmId,@PONo,@CmpInvNo,@InvoiceDate,@LcnId,@TransId,@NetAmt,0)

			DELETE FROM ETL_Prk_PurchaseReceipt where [Company Invoice No]=@CmpInvno
		END

		FETCH NEXT FROM Cur_PurchaseReceipt INTO @CmpCode,@SpmCode,@CmpInvNo,@PONo,@InvoiceDate,@TransCode,@NetAmt	
	END
	CLOSE Cur_PurchaseReceipt
	DEALLOCATE Cur_PurchaseReceipt
			
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Validate_PurchaseReceiptProduct' AND XTYPE='P')
DROP PROCEDURE Proc_Validate_PurchaseReceiptProduct
GO
--EXEC Proc_Validate_PurchaseReceiptProduct 0
CREATE PROCEDURE Proc_Validate_PurchaseReceiptProduct  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
/*********************************  
* PROCEDURE		: Proc_Validate_PurchaseReceiptProduct  
* PURPOSE		: To Insert and Update records in the Table PurchaseReceiptProduct 
* CREATED		: Nandakumar R.G  
* CREATED DATE	: 03/05/2010  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
SET NOCOUNT ON  
BEGIN
	
	DECLARE @Exist			AS  INT  
	DECLARE @Tabname		AS  NVARCHAR(100)  
	DECLARE @Fldname		AS  NVARCHAR(100)  
	DECLARE @CmpInvNo		AS  NVARCHAR(100)   
	DECLARE @RowId			AS  INT
	DECLARE @PrdCode		AS  NVARCHAR(100)  
	DECLARE @PrdBatCode		AS  NVARCHAR(100)  
	DECLARE @InvUOMCode		AS  NVARCHAR(100)  
	DECLARE @InvQty			AS  NUMERIC(38,0)
	DECLARE @PRRate			AS  NUMERIC(38,6)
	DECLARE @GrossAmt		AS  NUMERIC(38,6)
	DECLARE @DiscAmt		AS  NUMERIC(38,6)  
	DECLARE @TaxAmt			AS  NUMERIC(38,6)  
	DECLARE @NetAmt			AS  NUMERIC(38,6)
	DECLARE @FreightCharges AS  NUMERIC(38,6)   
	
	DECLARE @PrdId			AS  INT  
	DECLARE @PrdBatId		AS  INT  
	DECLARE @InvUOMId		AS  INT  
	DECLARE @NewPrd			AS  INT  
	
	SET @Po_ErrNo=0  
	SET @Exist=0  
	
	SET @Fldname='CmpInvNo'  
	SET @Tabname = 'ETL_Prk_PurchaseReceiptPrdDt'  
	SET @Exist=0  
	
	DECLARE Cur_PurchaseReceiptProduct CURSOR  
	FOR SELECT ISNULL([Company Invoice No],''),ISNULL([RowId],0),ISNULL([Product Code],''),  
	ISNULL([Batch Code],''),ISNULL([UOM],''),ISNULL([Invoice Qty],0),ISNULL([Purchase Rate],0),ISNULL([Gross],0),ISNULL([Discount In Amount],0),  
	ISNULL([Tax In Amount],0),ISNULL([Net Amount],0), ISNULL([NewPrd],0),ISNULL([FreightCharges],0)
	FROM ETL_Prk_PurchaseReceiptPrdDt  
	
	OPEN Cur_PurchaseReceiptProduct  	
	FETCH NEXT FROM Cur_PurchaseReceiptProduct INTO @CmpInvNo,@RowId,@PrdCode,@PrdBatCode,  
	@InvUOMCode,@InvQty,@PRRate,@GrossAmt,@DiscAmt,@TaxAmt,@NetAmt,@NewPrd,@FreightCharges  
	
	WHILE @@FETCH_STATUS=0  
	BEGIN
	
		SET @PrdId =0
		SET @PrdBatId=0
		SET @InvUOMId=0
		
		SET @Exist=0  
		
		IF NOT EXISTS(SELECT * FROM ETLTempPurchaseReceipt WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)  
		BEGIN  
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Invoice No',  
			'Company Invoice No:'+ CAST(@CmpInvNo AS NVARCHAR(100)) +' is not available')    
			
			SET @Po_ErrNo=1  
		END  		
		
		SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCode  		
		SELECT @PrdBatId=PrdBatId FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@PrdBatCode AND PrdId=@PrdId  
		SELECT @InvUOMId=UOMId FROM UOMMaster WITH (NOLOCK) WHERE UOMCode=@InvUOMCode  
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT UM.UomId,um.UomCode,UG.ConversionFactor
			FROM UomGroup UG,UomMaster UM ,Product P
			WHERE UG.UomId = UM.UomId AND P.UomGroupId = UG.UomGroupId AND
			P.PrdId = @PrdId AND UG.UomId = @InvUOMId)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Invoice UOM',
				'Invoice UOM:'+ CAST(@InvUOMCode AS NVARCHAR(100)) +' is not available for the product:'+ CAST(@PrdCode  AS NVARCHAR(100)))
				
				SET @Po_ErrNo=1
			END
		END
		
		IF @Po_ErrNo=0  
		BEGIN  
			INSERT INTO ETLTempPurchaseReceiptProduct   
			(CmpInvNo,RowId,PrdId,PrdBatId,POUOMId,POQty,InvUOMId,InvQty,GrossAmt,DiscAmt,TaxAmt,NetAmt,NewPrd,FreightCharges)  
			VALUES(@CmpInvNo,@RowId,@PrdId,@PrdBatId,0,0,@InvUOMId,@InvQty,@GrossAmt,@DiscAmt,@TaxAmt,@NetAmt,@NewPrd,@FreightCharges)  
		END  		
		
		IF @Po_ErrNo<>0  
		BEGIN  
			CLOSE Cur_PurchaseReceiptProduct  
			DEALLOCATE Cur_PurchaseReceiptProduct  
			RETURN  
		END  
		
		FETCH NEXT FROM Cur_PurchaseReceiptProduct INTO @CmpInvNo,@RowId,@PrdCode,@PrdBatCode,  
		@InvUOMCode,@InvQty,@PRRate,@GrossAmt,@DiscAmt,@TaxAmt,@NetAmt,@NewPrd,@FreightCharges
	
	END  
	CLOSE Cur_PurchaseReceiptProduct  
	DEALLOCATE Cur_PurchaseReceiptProduct  
	IF @Po_ErrNo=0  
	BEGIN  
		TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	END  
	RETURN   
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Validate_PurchaseReceiptLineDt' AND XTYPE='P')
DROP PROCEDURE Proc_Validate_PurchaseReceiptLineDt
GO
/*
BEGIN TRANSACTION
SELECT * FROM ETL_Prk_PurchaseReceiptPrdLineDt
EXEC Proc_Validate_PurchaseReceiptLineDt 0
SELECT * FROM ETLTempPurchaseReceiptPrdLineDt WHERE RefCode='D'
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_Validate_PurchaseReceiptLineDt
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_PurchaseReceiptLineDt
* PURPOSE		: To Insert and Update records in the Table PurchaseReceiptLineDt
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
	DECLARE @DestTabname	AS 	NVARCHAR(100)
	DECLARE @Fldname 		AS  NVARCHAR(100)
	
	DECLARE @CmpInvNo		AS 	NVARCHAR(100)	
	DECLARE @RowId 			AS 	INT
	DECLARE @ColCode 		AS 	NVARCHAR(100)
	DECLARE @Amt			AS 	NUMERIC(38,6)
	
	DECLARE @SeqSlNo		AS 	INT
	DECLARE @PurSeqId		AS 	INT
	
	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='ETLTempPurchaseReceiptPrdLineDt'
	SET @Fldname='CmpInvNo'
	SET @Tabname = 'ETL_Prk_PurchaseReceiptPrdLineDt'
	SET @Exist=0
	
	DECLARE Cur_PurchaseReceiptProductLineDt CURSOR
	FOR SELECT ISNULL([Company Invoice No],''),ISNULL([RowId],0),ISNULL([Column Code],''),
	ISNULL([Value In Amount],0)
	FROM ETL_Prk_PurchaseReceiptPrdLineDt

	OPEN Cur_PurchaseReceiptProductLineDt

	FETCH NEXT FROM Cur_PurchaseReceiptProductLineDt INTO @CmpInvNo,@RowId,@ColCode,@Amt

	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Exist=0

		IF NOT EXISTS(SELECT * FROM ETLTempPurchaseReceiptProduct WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Invoice No',
			'Company Invoice No:'+@CmpInvNo+' is not available')  
         	
			SET @Po_ErrNo=1
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM ETLTempPurchaseReceiptProduct WITH (NOLOCK) WHERE RowId=@RowId)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Company Invoice No',
				'Row Id:'+@RowId+' is not available in ETLTempPurchaseReceiptProduct')  
	         	
				SET @Po_ErrNo=1
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM PurchaseSequenceDetail PSD WITH (NOLOCK)
			WHERE RefCode=@ColCode AND PSD.PurSeqId IN (SELECT MAX(PurSeqId) FROM PurchaseSequenceMaster PSM WITH (NOLOCK) ))
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product',
				'Purchase Sequence Code:'+@ColCode+' is not available in Company Invoice No:'+@CmpInvNo)         	

				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @SeqSlNo=SlNo,@PurSeqId=PSD.PurSeqId FROM PurchaseSequenceDetail PSD WITH (NOLOCK)
				WHERE RefCode=@ColCode AND PSD.PurSeqId IN (SELECT MAX(PurSeqId) FROM PurchaseSequenceMaster PSM WITH (NOLOCK))
			END
		END				

		IF @Po_ErrNo=0
		BEGIN
			INSERT INTO ETLTempPurchaseReceiptPrdLineDt(CmpInvNo,RowId,PurSeqId,SlNo,RefCode,Amt)
			VALUES(@CmpInvNo,@RowId,@PurSeqId,@SeqSlNo,@ColCode,@Amt)
		END
			
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_PurchaseReceiptProductLineDt
			DEALLOCATE Cur_PurchaseReceiptProductLineDt
			RETURN
		END

		FETCH NEXT FROM Cur_PurchaseReceiptProductLineDt INTO @CmpInvNo,@RowId,@ColCode,@Amt

	END
	CLOSE Cur_PurchaseReceiptProductLineDt
	DEALLOCATE Cur_PurchaseReceiptProductLineDt

	IF @Po_ErrNo=0
	BEGIN
		TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdLineDt
	END


	RETURN	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Validate_PurchaseReceiptClaimScheme' AND XTYPE='P')
DROP PROCEDURE Proc_Validate_PurchaseReceiptClaimScheme
GO
--Exec Proc_Validate_PurchaseReceiptClaimScheme 0
--SELECT * FROM ETL_Prk_PurchaseReceiptClaim
--SELECT * FROM ETLTempPurchaseReceiptClaimScheme
CREATE Procedure Proc_Validate_PurchaseReceiptClaimScheme
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
	ISNULL([Amount],0)
	FROM ETL_Prk_PurchaseReceiptClaim
	OPEN Cur_PurchaseReceiptClaim
	FETCH NEXT FROM Cur_PurchaseReceiptClaim INTO @CmpInvNo,@Type,@RefCode,@PrdCode,@PrdBatCode,
	@Qty,@StockType,@Amt
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
			INSERT INTO ETLTempPurchaseReceiptClaimScheme 
			(CmpInvNo,TypeId,RefCode,RefId,RefDescription,PrdId,PrdBatId,StockTypeId,Qty,Amt)
			VALUES(@CmpInvNo,@TypeId,@RefCode,@RefId,@RefDesc,@PrdId,@PrdBatId,@stockTypeId,@Qty,@Amt)
		END
			
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_PurchaseReceiptClaim
			DEALLOCATE Cur_PurchaseReceiptClaim
			RETURN
		END
		FETCH NEXT FROM Cur_PurchaseReceiptClaim INTO @CmpInvNo,@Type,@RefCode,@PrdCode,@PrdBatCode,
		@Qty,@StockType,@Amt
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_PurchaseReceiptMapping' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_PurchaseReceiptMapping
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_PurchaseReceiptMapping
EXEC Proc_Cn2Cs_PurchaseReceiptMapping 0
SELECT * FROM PurchaseReceiptMapping-- WHERE TabName='ReasonMaster'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_PurchaseReceiptMapping
(
	@Po_ErrNo INT OUTPUT
)
AS
/**********************************************************
* PROCEDURE		: Proc_Cn2Cs_PurchaseReceiptMapping
* PURPOSE		: To Download the Purchase Receipt Mapping details from Console to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
***********************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @Exists				INT
	DECLARE @ReasonId			INT
	DECLARE @DistCode			NVARCHAR(100)
	DECLARE @CompInvNo			NVARCHAR(50)
	DECLARE @CompInvDate		DATETIME
	DECLARE @SpmCode			NVARCHAR(50)
	DECLARE @PrdId				INT
	DECLARE @PrdCCode			NVARCHAR(50)
	DECLARE @PrdName			NVARCHAR(200)
	DECLARE @PrdMapCode			NVARCHAR(50)
	DECLARE @PrdMapName			NVARCHAR(200)
	DECLARE @UOMCode			NVARCHAR(50)
	DECLARE @Qty				INT
	DECLARE @Rate				NUMERIC(38,6)
	DECLARE @GrossAmt			NUMERIC(38,6)
	DECLARE @DiscAmt			NUMERIC(38,6)
	DECLARE @TaxAmt				NUMERIC(38,6)
	DECLARE @NetAmt				NUMERIC(38,6)
	DECLARE @FreeSchemeFlag		NVARCHAR(5)
	DECLARE @SlNo				INT
	SET @ErrStatus=1
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_PurchaseReceiptMapping'
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PRMapToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE PRMapToAvoid	
	END
	CREATE TABLE PRMapToAvoid
	(		
		CompInvNo		NVARCHAR(200)
	)
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE ISNULL(CompInvNo,'')='')
	BEGIN
		INSERT INTO PRMapToAvoid(CompInvNo)
		SELECT CompInvNo FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE ISNULL(CompInvNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_PurchaseReceiptMapping','CompInvNo','Company Invoice No should not be empty'
		FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE ISNULL(CompInvNo,'')=''
	END	
	DECLARE Cur_PRMap CURSOR	
	FOR SELECT DISTINCT CompInvNo,CompInvDate,SupplierCode,PrdCCode,PrdName,PrdMapCode,PrdMapName,
	UOMCode,Qty,Rate,GrossAmount,DiscAmount,TaxAmount,NetAmount,FreeSchemeFlag,SlNo
	FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE DownloadFlag='D' AND ISNULL(CompInvNo,'')<>''
	OPEN Cur_PRMap
	FETCH NEXT FROM Cur_PRMap INTO @CompInvNo,@CompInvDate,@SpmCode,@PrdCCode,@PrdName,@PrdMapCode,@PrdMapName,
	@UOMCode,@Qty,@Rate,@GrossAmt,@DiscAmt,@TaxAmt,@TaxAmt,@FreeSchemeFlag,@SlNo
	WHILE @@FETCH_STATUS=0
	BEGIN		
		IF NOT EXISTS(SELECT * FROM PurchaseReceiptMapping WHERE CompInvNo=@CompInvNo AND PrdCCode=@PrdCCode AND PrdMapCode=@PrdMapCode)
		BEGIN			
			INSERT INTO PurchaseReceiptMapping(CompInvNo,CompInvDate,SpmCode,PrdId,PrdCCode,PrdName,PrdMapCode,PrdMapName,
			UOMCode,Qty,Rate,GrossAmount,DiscAmount,TaxAmount,NetAmount,FreeSchemeFlag,SlNo,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@CompInvNo,@CompInvDate,@SpmCode,0,@PrdCCode,@PrdName,@PrdMapCode,@PrdMapName,
			@UOMCode,@Qty,@Rate,@GrossAmt,@DiscAmt,@TaxAmt,@TaxAmt,@FreeSchemeFlag,@SlNo,1,1,GETDATE(),1,GETDATE())						
		END		
		FETCH NEXT FROM Cur_PRMap INTO @CompInvNo,@CompInvDate,@SpmCode,@PrdCCode,@PrdName,@PrdMapCode,@PrdMapName,
		@UOMCode,@Qty,@Rate,@GrossAmt,@DiscAmt,@TaxAmt,@TaxAmt,@FreeSchemeFlag,@SlNo
	END
CLOSE Cur_PRMap
	DEALLOCATE Cur_PRMap
	UPDATE PR SET PR.PrdId=P.PrdId
	FROM PurchaseReceiptMapping PR,Product P
	WHERE PR.PrdCCode=P.PrdCCode AND PR.CompInvNo IN
	(SELECT CompInvNo FROM Cn2Cs_Prk_PurchaseReceiptMapping)
	UPDATE Cn2Cs_Prk_PurchaseReceiptMapping SET DownloadFlag='Y' WHERE DownloadFlag='D' AND ISNULL(CompInvNo,'')<>''
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ClaimNorm' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ClaimNorm
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClaimNorm 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_ClaimNorm
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClaimNorm
* PURPOSE		: To Download the Claim Norm details 
* CREATED		: Nandakumar R.G
* CREATED DATE	: 26/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @Taction  			INT
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @DebitNoteNumber	NVARCHAR(500)
	DECLARE @CrDbNoteDate		DATETIME
	DECLARE @CrDbNoteReason		NVARCHAR(500)
	DECLARE @CreditNoteNumber	NVARCHAR(500)
	DECLARE @SpmId				INT
	DECLARE @DebitNo			NVARCHAR(500)
	DECLARE @CreditNo			NVARCHAR(500)
	DECLARE @ClaimNumber		NVARCHAR(500)
	DECLARE @ClmId				INT
	DECLARE @AccCoaId			INT
	DECLARE @ClmGroupId			INT
	DECLARE @ClmGroupNumber		NVARCHAR(500)
	DECLARE @CrDbNoteAmount		NUMERIC(38,6)
	DECLARE @CmpId				INT
	DECLARE @VocNo				NVARCHAR(500)

	DECLARE @ClaimNormId		INT

	SET @Po_ErrNo=0

	SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1

	DELETE FROM Cn2Cs_Prk_ClaimNorm WHERE DownLoadFlag='Y'


	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimGroupToAvoid') 
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimGroupToAvoid	
	END

	CREATE TABLE ClaimGroupToAvoid
	(
		ClaimGroupCode	 NVARCHAR(50)
	)

	IF EXISTS(SELECT ClaimGroupCode FROM Cn2Cs_Prk_ClaimNorm
	WHERE ClaimGroupCode NOT IN (SELECT ClmGrpCode FROM ClaimGroupMaster))
	BEGIN
		INSERT INTO ClaimGroupToAvoid(ClaimGroupCode) 
		SELECT ClaimGroupCode FROM Cn2Cs_Prk_ClaimNorm
		WHERE ClaimGroupCode NOT IN (SELECT ClmGrpCode FROM ClaimGroupMaster)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Norm','Claim Group','Claim Group :'+ClaimGroupCode +' not available'
		FROM Cn2Cs_Prk_ClaimNorm  
		WHERE ClaimGroupCode NOT IN (SELECT ClmGrpCode FROM ClaimGroupMaster)
	END

	DELETE FROM ClaimNormDefinition

	SET @ClaimNormId = dbo.Fn_GetPrimaryKeyInteger('ClaimNormDefinition','ClmNormId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))

	INSERT INTO ClaimNormDefinition(ClmNormId,CmpId,ClmGrpId,Claimable,
	Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT DISTINCT @ClaimNormId,@CmpId,ClmGrpId,ISNULL(PRK.ClaimablePerc,0),1,1,GETDATE(),1,GETDATE()
	FROM ClaimGroupMaster CGM,Cn2Cs_Prk_ClaimNorm PRK
	WHERE CGM.ClmGrpCode=PRK.ClaimGroupCode

	UPDATE Counters SET CurrValue = @ClaimNormId WHERE TabName = 'ClaimNormDefinition' AND FldName = 'ClmNormId'

	UPDATE Cn2Cs_Prk_ClaimNorm SET DownLoadFlag='Y'
	WHERE ClaimGroupCode NOT IN (SELECT ClaimGroupCode FROM ClaimGroupToAvoid)

END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ReasonMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ReasonMaster
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_ReasonMaster
EXEC Proc_Cn2Cs_ReasonMaster 0
SELECT * FROM Counters WHERE TabName='ReasonMaster'
ROLLBACK TRANSACTION
*/
CREATE  PROCEDURE Proc_Cn2Cs_ReasonMaster
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ReasonMaster
* PURPOSE		: To Download the Reason details from Console to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @Exists				INT
	DECLARE @ReasonId			INT
	DECLARE @DistCode			NVARCHAR(100)
	DECLARE @ReasonCode			NVARCHAR(100)
	DECLARE @Description		NVARCHAR(100)
	DECLARE @ApplicableTo		NVARCHAR(100)
	SET @ErrStatus=1
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_ReasonMaster'
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ReasonToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ReasonToAvoid	
	END
	CREATE TABLE ReasonToAvoid
	(		
		RSMCode		NVARCHAR(200)
	)
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')='')
	BEGIN
		INSERT INTO ReasonToAvoid(RSMCode)
		SELECT ReasonCode FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_ReasonMaster','Reason Code','Reason code should not be empty'
		FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')=''
	END	
	DECLARE Cur_Reason CURSOR	
	FOR SELECT DISTINCT ReasonCode,Description
	FROM Cn2Cs_Prk_ReasonMaster WHERE DownloadFlag='D' AND ISNULL(ReasonCode,'')<>''
	OPEN Cur_Reason
	FETCH NEXT FROM Cur_Reason INTO @ReasonCode,@Description
	WHILE @@FETCH_STATUS=0
	BEGIN		
		IF NOT EXISTS(SELECT * FROM ReasonMaster WHERE ReasonCode=@ReasonCode)
		BEGIN
			SET @ReasonId=0
			SET @ReasonId = dbo.Fn_GetPrimaryKeyInteger('ReasonMaster','ReasonId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
			IF @ReasonId>0
			BEGIN
				INSERT INTO ReasonMaster(ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
				DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,StkTransferScreen,
				BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@ReasonId,@ReasonCode,@Description,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,GETDATE(),1,GETDATE())
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
			END
			ELSE
			BEGIN
				SET @ErrDesc='Check the System Date'
				INSERT INTO Errorlog VALUES (1,@TabName,'Description',@ErrDesc)
		  		SET @Po_ErrNo=1
			END
		END
		ELSE
		BEGIN
			SELECT @ReasonId=ReasonId FROM ReasonMaster WHERE ReasonCode=@ReasonCode
			UPDATE ReasonMaster SET PurchaseReceipt=0,SalesInvoice=0,VanLoad=0,CrNoteSupplier=0,CrNoteRetailer=0,
			DeliveryProcess=0,SalvageRegister=0,PurchaseReturn=0,SalesReturn=0,VanUnload=0,DbNoteSupplier=0,DbNoteRetailer=0,
			StkAdjustment=0,StkTransferScreen=0,BatchTransfer=0,ReceiptVoucher=0,ReturnToCompany=0,LocationTrans=0,
			Billing=0,ChequeBouncing=0,ChequeDisbursal=0 WHERE ReasonId=@ReasonId
		END
		
		IF @Po_ErrNo=0
		BEGIN
			DECLARE Cur_ReasonApplicable CURSOR	
			FOR SELECT DISTINCT ReasonCode,Description,ApplicableTo
			FROM Cn2Cs_Prk_ReasonMaster WHERE DownloadFlag='D' AND ReasonCode=@ReasonCode
			OPEN Cur_ReasonApplicable
			FETCH NEXT FROM Cur_ReasonApplicable INTO @ReasonCode,@Description,@ApplicableTo
			WHILE @@FETCH_STATUS=0
			BEGIN		
				SET @sSql=''
				IF @ApplicableTo='All'
				BEGIN
					SET @sSql='UPDATE ReasonMaster SET PurchaseReceipt=1,SalesInvoice=1,VanLoad=1,CrNoteSupplier=1,CrNoteRetailer=1,
					DeliveryProcess=1,SalvageRegister=1,PurchaseReturn=1,SalesReturn=1,VanUnload=1,DbNoteSupplier=1,DbNoteRetailer=1,
					StkAdjustment=1,StkTransferScreen=1,BatchTransfer=1,ReceiptVoucher=1,ReturnToCompany=1,LocationTrans=1,Billing=1,
					ChequeBouncing=1,ChequeDisbursal=1 WHERE ReasonId='+CAST(@ReasonId AS NVARCHAR(10))
				END
				ELSE
				BEGIN
					IF EXISTS (SELECT Id,Name FROM SysColumns WHERE Name = @ApplicableTo AND Id IN (SELECT Id FROM
					SysObjects WHERE Name ='ReasonMaster'))
					BEGIN
						SET @sSql='UPDATE ReasonMaster SET '+@ApplicableTo+'=1 WHERE ReasonId='+CAST(@ReasonId AS NVARCHAR(10))
					END					
				END
				IF LTRIM(RTRIM(@sSql))<>''
				BEGIN
					EXEC (@sSql)
				END
				FETCH NEXT FROM Cur_ReasonApplicable INTO @ReasonCode,@Description,@ApplicableTo
			END
			CLOSE Cur_ReasonApplicable
			DEALLOCATE Cur_ReasonApplicable
		END		
		FETCH NEXT FROM Cur_Reason INTO @ReasonCode,@Description
	END
	CLOSE Cur_Reason
	DEALLOCATE Cur_Reason
	UPDATE Cn2Cs_Prk_ReasonMaster SET DownloadFlag='Y' WHERE DownloadFlag='D' AND ISNULL(ReasonCode,'')<>''
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BulletinBoard' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BulletinBoard
GO
--Exec Proc_CS2CNValidateBulletingBoard 0
CREATE  PROCEDURE Proc_Cn2Cs_BulletinBoard
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_BulletinBoard
* PURPOSE		: To Insert records from parking table to Table BroadCast
* CREATED		: Murugan.R
* CREATED DATE	: 22/09/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	SET @Po_ErrNo=0

	INSERT INTO BroadCast(MessageCode,Subject,MessageDesc,Attachement,Status)
	SELECT MessageCode,Subject,MessageDesc,Attachement,0 FROM Cn2Cs_Prk_BulletinBoard
	WHERE DownloadFlag='D' AND MessageCode NOT IN(SELECT MessageCode FROM BroadCast)

	UPDATE Cn2Cs_Prk_BulletinBoard SET DownloadFlag='Y' 

END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ERPPrdCCodeMapping' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ERPPrdCCodeMapping
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_ERPPrdCCodeMapping
EXEC Proc_Cn2Cs_ERPPrdCCodeMapping 0
SELECT * FROM Counters WHERE TabName='ReasonMaster'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_ERPPrdCCodeMapping
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ERPPrdCCodeMapping
* PURPOSE		: To Download the ERP and Console Product Code Mapping to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 20/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @PrdCCode			NVARCHAR(100)
	DECLARE @ERPPrdCode			NVARCHAR(100)
	DECLARE @MappedDate			DATETIME
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_ERPPrdCCodeMapping'
	DECLARE Cur_Reason CURSOR	
	FOR SELECT DISTINCT PrdCCode,ERPPrdCode,MappedDate
	FROM Cn2Cs_Prk_ERPPrdCCodeMapping WHERE DownloadFlag='D'
	OPEN Cur_Reason
	FETCH NEXT FROM Cur_Reason INTO @PrdCCode,@ERPPrdCode,@MappedDate
	WHILE @@FETCH_STATUS=0
	BEGIN		
		IF NOT EXISTS(SELECT * FROM ERPPrdCCodeMapping WHERE ERPPrdCode=@ERPPrdCode)
		BEGIN
			INSERT INTO ERPPrdCCodeMapping(PrdCCode,ERPPrdCode,MappedDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@PrdCCode,@ERPPrdCode,@MappedDate,1,1,GETDATE(),1,GETDATE())
		END
		ELSE
		BEGIN			
			UPDATE ERPPrdCCodeMapping SET PrdCCode=@PrdCCode WHERE ERPPrdCode=@ERPPrdCode
		END		
		FETCH NEXT FROM Cur_Reason INTO @PrdCCode,@ERPPrdCode,@MappedDate
	END
    CLOSE Cur_Reason
	DEALLOCATE Cur_Reason
	--Added By Sathishkumar Veeramani
	UPDATE A SET A.PrdShrtName = LTRIM(RTRIM(B.PrdShrtName)) FROM Product A WITH (NOLOCK),Cn2Cs_Prk_ERPPrdCCodeMapping B WITH (NOLOCK)
	WHERE A.PrdCCode = B.PrdCCode AND ISNULL(LTRIM(RTRIM(B.PrdShrtName)),'') <> ''
	--Till Here
	UPDATE Cn2Cs_Prk_ERPPrdCCodeMapping SET DownloadFlag='Y' WHERE DownloadFlag='D'
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_Configuration' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_Configuration
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_Configuration 0
SELECT * FROM Cn2Cs_Prk_Configuration
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_Cn2Cs_Configuration
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_Configuration
* PURPOSE		: To Validate the Configuration Downloaded from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 24/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	SET @Po_ErrNo=0
	
	DECLARE @ModuleId		NVARCHAR(100)
	DECLARE @ModuleName		NVARCHAR(100)
	DECLARE @Description	NVARCHAR(100)
	DECLARE @Status			INT
	DECLARE @Condition		NVARCHAR(100)
	DECLARE @ConfigValue	NUMERIC(38,6)
	DECLARE @SeqNo			INT

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ConfigToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ConfigToAvoid	
	END

	CREATE TABLE ConfigToAvoid
	(		
		ModuleId		NVARCHAR(200),
		ModuleName		NVARCHAR(200)
	)

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_Configuration WHERE ISNULL(ModuleId,'')='') 
	BEGIN
		INSERT INTO ConfigToAvoid(ModuleId,ModuleName)
		SELECT ModuleId,ModuleName FROM Cn2Cs_Prk_Configuration WHERE ISNULL(ModuleId,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_Configuration','ModuleId','Module Id should not be empty'
		FROM Cn2Cs_Prk_Configuration WHERE ISNULL(ModuleId,'')=''
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_Configuration WHERE ISNULL(ModuleName,'')='') 
	BEGIN
		INSERT INTO ConfigToAvoid(ModuleId,ModuleName)
		SELECT ModuleId,ModuleName FROM Cn2Cs_Prk_Configuration WHERE ISNULL(ModuleName,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_Configuration','ModuleId','Module Name should not be empty'
		FROM Cn2Cs_Prk_Configuration WHERE ISNULL(ModuleName,'')=''
	END

	DECLARE Cur_Config CURSOR
	FOR SELECT ModuleId,ModuleName,Description,ISNULL(Status,0),ISNULL(Condition,''),ISNULL(ConfigValue,0),ISNULL(SeqNo,1)
	FROM Cn2Cs_Prk_Configuration WHERE DownLoadFlag='D' AND ISNULL(ModuleId,'')+'~'+ISNULL(ModuleName,'') 
	NOT IN (SELECT ISNULL(ModuleId,'')+'~'+ISNULL(ModuleName,'') FROM ConfigToAvoid)
	OPEN Cur_Config
	FETCH NEXT FROM Cur_Config INTO @ModuleId,@ModuleName,@Description,@Status,@Condition,@ConfigValue,@SeqNo
	WHILE @@FETCH_STATUS=0
	BEGIN

		IF NOT EXISTS(SELECT * FROM Configuration WHERE ModuleId=@ModuleId)
		BEGIN
			INSERT Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
			SELECT @ModuleId,@ModuleName,@Description,@Status,@Condition,@ConfigValue,@SeqNo				
		END
		ELSE
		BEGIN
			UPDATE Configuration SET Status=@Status,Condition=@Condition,ConfigValue=@ConfigValue
			WHERE ModuleId=@ModuleId AND ModuleName=@ModuleName
		END		

		FETCH NEXT FROM Cur_Config INTO @ModuleId,@ModuleName,@Description,@Status,@Condition,@ConfigValue,@SeqNo
	END
	CLOSE Cur_Config
	DEALLOCATE Cur_Config

	UPDATE Cn2Cs_Prk_Configuration SET DownLoadFlag='Y' WHERE DownLoadFlag='D' AND ISNULL(ModuleId,'')+'~'+ISNULL(ModuleName,'')
	NOT IN (SELECT ISNULL(ModuleId,'')+'~'+ISNULL(ModuleName,'') FROM ConfigToAvoid)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ClusterAssignApproval' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ClusterAssignApproval
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
CREATE  PROCEDURE Proc_Cn2Cs_ClusterAssignApproval
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_SupplierMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_SupplierMaster
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_SupplierMaster 0
SELECT * FROM Cn2Cs_Prk_SupplierMaster
--SELECT * FROM ErrorLog
SELECT * FROM Supplier
ROLLBACK TRANSACTION
*/
CREATE  PROCEDURE Proc_Cn2Cs_SupplierMaster
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_UDCMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_UDCMaster
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_UDCMaster
EXEC Proc_Cn2Cs_UDCMaster 0
SELECT * FROM UDCMaster
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_UDCMaster
(
       @Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_UDCMaster
* PURPOSE		: To validate the downloaded UDC Master Details 
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 22/06/2010
* NOTE			: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @InsertCount INT
	DECLARE @Exist  INT
	DECLARE @Trans  INT
	DECLARE @MasterName  nVarchar(100)
	DECLARE @ColumnName  nVarchar(100)
	DECLARE @ColumnDataType  nVarchar(100)
	DECLARE @ColumnSize  nVarchar(50)
	DECLARE @ColumnPrecision  nVarchar(20)
	DECLARE @Editable  nVarchar(20)
	DECLARE @EditId  TINYINT
	DECLARE @MasterId  INT
	DECLARE @PickFromDefault  nVarchar(20)
	DECLARE @PickDefaultId  TINYINT
	DECLARE @UdcMasterId  INT
	DECLARE @MandatoryId  INT
	DECLARE @Mandatory AS NVARCHAR(100)

	DECLARE @sStr	nVarchar(4000)
	
	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'UDCToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE UDCToAvoid	
	END

	CREATE TABLE UDCToAvoid
	(
		MasterName NVARCHAR(200),
		ColumnName NVARCHAR(200)
	)

	IF EXISTS(SELECT DISTINCT ColumnName FROM Cn2Cs_Prk_UDCMaster
	WHERE MasterName NOT IN (SELECT MasterName FROM UDCHd))
	BEGIN
		INSERT INTO UDCToAvoid(MasterName,ColumnName)
		SELECT DISTINCT MasterName,ColumnName FROM Cn2Cs_Prk_UDCMaster
		WHERE MasterName NOT IN (SELECT MasterName FROM UDCHd)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'UDC Master','MasterName','Master :'+MasterName+'is not available'
		FROM Cn2Cs_Prk_UDCMaster
		WHERE MasterName NOT IN (SELECT MasterName FROM UDCHd)		
	END

	IF EXISTS(SELECT DISTINCT ColumnName FROM Cn2Cs_Prk_UDCMaster
	WHERE ISNULL(ColumnName,'') ='')
	BEGIN
		INSERT INTO UDCToAvoid(MasterName,ColumnName)
		SELECT DISTINCT MasterName,ColumnName FROM Cn2Cs_Prk_UDCMaster
		WHERE ISNULL(ColumnName,'') =''
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'UDC Master','ColumnName','Column Name should not be empty for :'+MasterName
		FROM Cn2Cs_Prk_UDCMaster
		WHERE ISNULL(ColumnName,'') =''
	END

	DECLARE Cur_UDCMaster CURSOR
	FOR SELECT DISTINCT MasterName,ColumnName,ColumnDataType,ColumnSize,ColumnPrecision,Editable,Mandatory,PickFromDefault
	FROM Cn2Cs_Prk_UDCMaster
	OPEN Cur_UDCMaster
	FETCH NEXT FROM Cur_UDCMaster INTO @MasterName,@ColumnName,@ColumnDataType,@ColumnSize,
	@ColumnPrecision,@Editable,@Mandatory,@PickFromDefault

	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @Exist = 0 
		SET @Trans = 0

		SELECT @MasterId = MasterId FROM UDCHd WHERE MasterName = @MasterName

		IF @ColumnDataType <> 'Numeric'
		BEGIN
			SET @ColumnPrecision=0			
		END

		IF EXISTS (SELECT * FROM UdcMaster WHERE MasterId = @MasterId AND ColumnName = @ColumnName)
		BEGIN
			SELECT @UdcMasterId=UdcMasterId FROM UdcMaster WHERE MasterId = @MasterId AND ColumnName = @ColumnName
			SET @Exist=1
		END
		ELSE
		BEGIN
			SET @UdcMasterId = 0	
		END

		IF EXISTS (SELECT UdcMasterId FROM UDcDetails WHERE UdcMasterId=@UdcMasterId)
		BEGIN
			INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
			VALUES (1,'Cn2Cs_Prk_UDCMaster','UdcMasterId','Transaction Exists for column:' + CAST(@ColumnName AS VARCHAR) +' for :'+@MasterName)
			SET @Trans = 1
		END

		IF @Editable = 'No'
		BEGIN
			SET @EditId = 0
		END
		ELSE
		BEGIN
			SET @EditId = 1
		END

		IF @PickFromDefault = 'No'
		BEGIN
			SET @PickDefaultId = 0
		END
		ELSE
		BEGIN
			SET @PickDefaultId = 1
		END

		IF @Mandatory = 'No'
		BEGIN
			SET @MandatoryId = 0
		END
		ELSE
		BEGIN
			SET @MandatoryId = 1
		END

		IF @Exist = 1 AND @Trans = 0 
		BEGIN
			UPDATE UdcMaster SET ColumnName = @ColumnName,ColumnDataType = @ColumnDataType,
			ColumnSize= @ColumnSize,ColumnPrecision = @ColumnPrecision,
			Editable = @EditId,PickFromDefault = @PickDefaultId,ColumnMandatory=@MandatoryId
			WHERE ColumnName = @ColumnName AND UdcMaster.MasterId = @MasterId
		END
		ELSE 
		IF @Exist = 0
		BEGIN
			SET @UdcMasterId = dbo.Fn_GetPrimaryKeyInteger('UdcMaster','UdcMasterId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))

			INSERT INTO UdcMaster(UdcMasterId,MasterId,ColumnName,ColumnDataType,ColumnSize,ColumnPrecision,
			ColumnMandatory,Availability,LastModBy,LastModDate,AuthId,AuthDate,Editable,PickFromDefault) 
			VALUES(@UdcMasterId,@MasterId,@ColumnName,@ColumnDataType,@ColumnSize,@ColumnPrecision,@MandatoryId,
			1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),@EditId,@PickDefaultId)

			UPDATE Counters SET currvalue = @UDCMasterId WHERE TabName = 'UdcMaster' and FldName = 'UdcMasterId'
		END

		FETCH NEXT FROM Cur_UDCMaster INTO @MasterName,@ColumnName,@ColumnDataType,@ColumnSize,
		@ColumnPrecision,@Editable,@Mandatory,@PickFromDefault
	END
	CLOSE Cur_UDCMaster
	DEALLOCATE Cur_UDCMaster

	UPDATE Cn2Cs_Prk_UDCMaster SET DownLoadFlag='Y' WHERE MasterName+'~'+ColumnName IN 
	(SELECT MasterName+'~'+ColumnName FROM UDCMaster U,UDCHd H WHERE U.MasterId=H.MasterId)

	RETURN

END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_UDCDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_UDCDetails
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_UDCDetails 0
SELECT * FROM Cn2Cs_Prk_UDCDetails
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_Cn2Cs_UDCDetails
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_UDCDetails
* PURPOSE		: Dummy SP
* CREATED		: Nandakumar R.G
* CREATED DATE	: 24/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	SET @Po_ErrNo=0
	
	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_UDCDefaults' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_UDCDefaults
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_UDCDefaults 0
SELECT * FROM Cn2Cs_Prk_UDCDefaults
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_Cn2Cs_UDCDefaults
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_UDCDefaults
* PURPOSE		: To Validate the UDC Default Values Downloaded from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/08/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0
	DECLARE @MasterName		NVARCHAR(100)
	DECLARE @ColumnName		NVARCHAR(100)
	DECLARE @ColumnValue	NVARCHAR(100)
	
	DECLARE @SeqId			INT
	DECLARE @MasterId		INT
	DECLARE @UDCMasterId	INT
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'UDCDefToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE UDCDefToAvoid	
	END
	CREATE TABLE UDCDefToAvoid
	(		
		MasterName		NVARCHAR(200),
		ColumnName		NVARCHAR(200)
	)
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')='')
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','MasterName','Module Name should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')=''
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')='')
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','ColumnName','Column Name should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')=''
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')='')
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','ColumnValue','Column Value should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')=''
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN
	(SELECT MAsterName FROM UDCHd))
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN
		(SELECT MAsterName FROM UDCHd)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','MasterName','Master Name:'+MasterName+' not available'
		FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN
		(SELECT MAsterName FROM UDCHd)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN
	(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId))
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN
		(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','UDC Master','UDC Name:'+ColumnName+' not available for:'+MasterName
		FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN
		(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId)
	END
	DECLARE Cur_UDCDef CURSOR
	FOR SELECT MasterName,ColumnName,ColumnValue
	FROM Cn2Cs_Prk_UDCDefaults WHERE DownLoadFlag='D' AND ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'')
	NOT IN (SELECT ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'') FROM UDCDefToAvoid)
	OPEN Cur_UDCDef
	FETCH NEXT FROM Cur_UDCDef INTO @MasterName,@ColumnName,@ColumnValue
	WHILE @@FETCH_STATUS=0
	BEGIN
		SELECT @MasterId=MasterId FROM UDCHd WHERE MasterName=@MasterName
		SELECT @UdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName=@ColumnName
		IF NOT EXISTS(SELECT * FROM UDCDefault WHERE MasterId=@MasterId AND
		UDCMasterId=@UDCMasterId AND ColValue=@ColumnValue)
		BEGIN
			SELECT @SeqId=ISNULL(MAX(SeqId),0)+1 FROM UDCDefault WHERE MasterId=@MasterId AND
			UDCMasterId=@UDCMasterId
			INSERT UDCDefault(SeqId,MasterId,UdcMasterId,ColValue)
			SELECT @SeqId,@MasterId,@UDCMasterId,@ColumnValue
		END
		FETCH NEXT FROM Cur_UDCDef INTO @MasterName,@ColumnName,@ColumnValue
	END
	CLOSE Cur_UDCDef
	DEALLOCATE Cur_UDCDef
	UPDATE Cn2Cs_Prk_UDCDefaults SET DownLoadFlag='Y' WHERE DownLoadFlag='D' AND ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'')
	NOT IN (SELECT ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'') FROM UDCDefToAvoid)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_RetailerMigration' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_RetailerMigration
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_RetailerMigration 0
SELECT * FROM Cn2Cs_Prk_RetailerMigration
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_Cn2Cs_RetailerMigration
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_RetailerMigration
* PURPOSE		: Dummy SP
* CREATED		: Nandakumar R.G
* CREATED DATE	: 24/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	SET @Po_ErrNo=0
	
	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_PointsRulesSetting' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_PointsRulesSetting
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PointsRulesSetting 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_PointsRulesSetting
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_Dummy' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_Dummy
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_Dummy 0
ROLLBACK TRANSACTION	
*/
CREATE PROCEDURE Proc_Cn2Cs_Dummy
(
	@Po_ErrNo  INT OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cn2Cs_Dummy
* PURPOSE	: Dummy SP for Upload Integration
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 10/11/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	SET @Po_ErrNo  =0
	
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_SchemePayout' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_SchemePayout
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_SchemePayout
EXEC Proc_Cn2Cs_SchemePayout 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_SchemePayout
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SchemePayout
* PURPOSE		: To Download the Scheme Payout details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @Taction  			INT
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @CrDbNoteDate		DATETIME
	DECLARE @DebitNo			NVARCHAR(500)
	DECLARE @CreditNo			NVARCHAR(500)
	DECLARE @CoaId				INT
	DECLARE @VocNo				NVARCHAR(500)
	DECLARE @CmpSchCode			NVARCHAR(200)
	DECLARE @CmpRtrCode			NVARCHAR(200)
	DECLARE @CrDbType			NVARCHAR(200)
	DECLARE @CrDbNoteNo			NVARCHAR(200)
	DECLARE @CrDbDate			DATETIME
	DECLARE @CrDbAmt			NUMERIC(38,6)
	DECLARE @ResField1			NVARCHAR(200)
	DECLARE @ResField2			NVARCHAR(200)
	DECLARE @ResField3			NVARCHAR(200)
	DECLARE @RtrId				INT
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchPayToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SchPayToAvoid	
	END
	CREATE TABLE SchPayToAvoid
	(
		CmpSchCode	 NVARCHAR(50),
		CmpRtrCode	 NVARCHAR(50)
	)
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpSchCode,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CmpSchCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','CmpSchCode','Company Scheme Code should not be empty for :'+CmpRtrCode
		FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpSchCode,'')=''
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpRtrCode,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CmpRtrCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','CmpRtrCode','Company Retailer Code should not be empty for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpRtrCode,'')=''
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE CrDbAmt<0)
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE CrDbAmt<0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Amount','Amount should be greater than zero for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout
		WHERE CrDbAmt<0
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout
	WHERE ISNULL(CrDbDate,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CrDbDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Date','Date should not be empty for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CrDbDate,'')=''
	END	
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout
	WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer))
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout WHERE
		CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Retailer','Retailer:'+CmpRtrCode+' for Scheme:'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
	END
	SET @CrDbNoteDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	DECLARE Cur_SchemePayout CURSOR	
	FOR SELECT  ISNULL([CmpSchCode],''),ISNULL([CmpRtrCode],''),ISNULL([CrDbType],''),ISNULL([CrDbNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CrDbDate],121),CAST(ISNULL([CrDbAmt],0)AS NUMERIC(38,6)),
	ISNULL([ResField1],''),ISNULL([ResField2],''),ISNULL([ResField3],'')
	FROM Cn2Cs_Prk_SchemePayout WHERE DownloadFlag='D' AND CmpSchCode+'~'+CmpRtrCode NOT IN
	(SELECT CmpSchCode+'~'+CmpRtrCode FROM SchPayToAvoid)	
	OPEN Cur_SchemePayout
	FETCH NEXT FROM Cur_SchemePayout INTO @CmpSchCode,@CmpRtrCode,@CrDbType,@CrDbNoteNo,@CrDbDate,@CrDbAmt,@ResField1,@ResField2,@ResField3
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @ErrStatus=1
		SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode
		SELECT @CoaId=CoaId FROM ClaimGroupMaster WHERE ClmGrpId=17
		
		IF @CrDbType='Credit'
		BEGIN
			SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			
			INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
			PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			VALUES(@CreditNo,@CrDbNoteDate,@RtrId,@CoaId,9,@CrDbAmt,0,1,18,18,
			@CmpSchCode,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Payout for Scheme:'+@CmpSchCode)
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteRetailer' AND Fldname = 'CrNoteNumber'
			EXEC Proc_VoucherPosting 18,1,@CreditNo,3,6,1,@CrDbNoteDate,@Po_ErrNo=@ErrStatus OUTPUT
			IF @ErrStatus<>1
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Credit Note Voucher Posting Failed for Scheme Ref No:' + @CmpSchCode
				INSERT INTO Errorlog
				VALUES (9,'Scheme Payout','Credit Note Voucher Posting',@ErrDesc)
			END
--			IF @Po_ErrNo=0
--			BEGIN
--				SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=6
--				AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)
--
--				IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
--				BEGIN
--					EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
--				END
--			END
			UPDATE Cn2Cs_Prk_SchemePayout SET DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode AND CmpRtrCode=@CmpRtrCode
		END					
		ELSE IF @CrDbType='Debit'
		BEGIN
			SELECT @DebitNo=dbo.Fn_GetPrimaryKeyString('DebitNoteRetailer','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			INSERT INTO DebitNoteRetailer(DbNoteNumber,DbNoteDate,RtrId,CoaId,ReasonId,Amount,DbAdjAmount,Status,
			PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			VALUES(@DebitNo,@CrDbNoteDate,@RtrId,@CoaId,9,@CrDbAmt,0,1,19,19,
			@CmpSchCode,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Payout for Scheme:'+@CmpSchCode)
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteRetailer' AND Fldname = 'DbNoteNumber'
		
			EXEC Proc_VoucherPosting 19,1,@DebitNo,3,7,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
			
			IF @ErrStatus<>1
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Debit Note Voucher Posting Failed'
				INSERT INTO Errorlog VALUES (10,'Scheme Payout','Debit Note Voucher Posting',@ErrDesc)
			END
	
--			IF @Po_ErrNo=0
--			BEGIN
--				SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=7
--				AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)
--
--				IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
--				BEGIN
--					EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
--				END
--			END
			UPDATE Cn2Cs_Prk_SchemePayout SET DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode AND CmpRtrCode=@CmpRtrCode
		END	
		FETCH NEXT FROM Cur_SchemePayout INTO @CmpSchCode,@CmpRtrCode,@CrDbType,@CrDbNoteNo,@CrDbDate,@CrDbAmt,@ResField1,@ResField2,@ResField3
	END
	CLOSE Cur_SchemePayout
	DEALLOCATE Cur_SchemePayout
	SET @Po_ErrNo=0
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ReUpload' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ReUpload
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ReUpload 0
SELECT * FROM Tbl_UploadIntegration
SELECT * FROM Cn2Cs_Prk_Reupload
SELECT * FROM tbl_UploadIntegration
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_ReUpload
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_Cn2Cs_ReUpload
* PURPOSE	: Extract the Details of uploaded data from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 
* DATE		: 15-02-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/

	SET @Po_ErrNo=0

	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME

	DECLARE @sSql			As nVarchar(4000)
	DECLARE @SeqNo			As INT
	DECLARE @sProcName		As nVarchar(200)
	DECLARE @ReUploadDate	As DATETIME

	SELECT @DistCode = DistributorCode FROM Distributor

	
	DELETE FROM Cn2Cs_Prk_Reupload WHERE DownLoadFlag='Y' 

	DECLARE Cur_ReUpload CURSOR
	FOR SELECT SeqNo,ProcessName,ReUploadDate FROM Cn2Cs_Prk_Reupload ORDER BY SeqNo,ProcessName
	OPEN Cur_ReUpload
	FETCH NEXT FROM Cur_ReUpload INTO @SeqNo,@sProcName,@ReUploadDate
	WHILE @@FETCH_STATUS=0
	BEGIN
	
		IF DAY(@ReUploadDate)<6
		BEGIN
			SET @ReUploadDate=DATEADD(MM,-1,@ReUploadDate)
			SELECT @ChkDate=dbo.Fn_GetFirstDayOfMonth(@ReUploadDate)
		END
		ELSE
		BEGIN	
			SELECT @ChkDate=dbo.Fn_GetFirstDayOfMonth(@ReUploadDate)
		END			
		
		IF @sProcName='Daily Sales' AND @SeqNo=3
		BEGIN
			UPDATE SalesInvoice SET Upload=0 WHERE SalInvDate>=@ChkDate

			UPDATE Cn2Cs_Prk_Reupload SET DownLoadFlag='Y' 
			WHERE ProcessName='Daily Sales' AND SeqNo=3
		END

		IF @sProcName='Stock' AND @SeqNo=4
		BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @ChkDate AND ProcId = 11)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @ChkDate WHERE ProcId IN(11,2)
			END

			UPDATE Cn2Cs_Prk_Reupload SET DownLoadFlag='Y' 
			WHERE ProcessName='Stock' AND SeqNo=4
		END

		IF @sProcName='Sales Return' AND @SeqNo=5
		BEGIN
			UPDATE ReturnHeader SET Upload=0 WHERE ReturnDate>=@ChkDate
			
			UPDATE Cn2Cs_Prk_Reupload SET DownLoadFlag='Y' 
			WHERE ProcessName='Sales Return' AND SeqNo=5
		END

		IF @sProcName='Purchase Confirmation' AND @SeqNo=6
		BEGIN
			UPDATE PurchaseReceipt SET Upload=0 WHERE GoodsRcvdDate>=@ChkDate
			
			UPDATE Cn2Cs_Prk_Reupload SET DownLoadFlag='Y' 
			WHERE ProcessName='Purchase Confirmation' AND SeqNo=6
		END

		IF @sProcName='Purchase Return' AND @SeqNo=7
		BEGIN
			UPDATE PurchaseReturn SET Upload=0 WHERE PurRetDate>=@ChkDate

			UPDATE Cn2Cs_Prk_Reupload SET DownLoadFlag='Y' 
			WHERE ProcessName='Purchase Return' AND SeqNo=7
		END
		
		IF @sProcName='Scheme Utilization' AND @SeqNo=9
		BEGIN						
			UPDATE SalesInvoice SET SchemeUpload=0 WHERE SalInvDate>=@ChkDate
			UPDATE ChequeDisbursalMaster SET SchemeUpload=0 WHERE ChqDisDate>=@ChkDate
			UPDATE ReturnHeader SET SchemeUpload=0 WHERE ReturnDate>=@ChkDate			

			UPDATE Cn2Cs_Prk_Reupload SET DownLoadFlag='Y' 
			WHERE @sProcName='Scheme Utilization' AND SeqNo=9
		END		

		FETCH NEXT FROM Cur_ReUpload INTO @SeqNo,@sProcName,@ReUploadDate	
	END
	CLOSE Cur_ReUpload
	DEALLOCATE Cur_ReUpload
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_KitProduct' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_KitProduct
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_KitProduct 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_KitProduct
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE	: Proc_Cn2Cs_KitProduct
* PURPOSE	: To Insert and Update records Of KitProduct And KitProductBatch
* CREATED	: Sathishkumar Veeramani on 17/12/2012
****************************************************************************************************
* DATE         AUTHOR       DESCRIPTION
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
    SET @Po_ErrNo = 0
	DECLARE @DistCode AS  NVARCHAR(50)
	DECLARE @CmpId AS INT
	SELECT @DistCode=ISNULL(DistributorCode,'') FROM Distributor
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1
	DELETE FROM Cn2Cs_Prk_KitProducts WHERE DownloadFlag = 'Y'
	
--->Added By Sathishkumar Veeramani on 17/12/2012
	IF EXISTS (SELECT * FROM SysObjects WHERE Xtype = 'U' AND name = 'KitProductToAvoid')
	BEGIN
		DROP TABLE KitProductToAvoid	
	END
	CREATE TABLE KitProductToAvoid
	(
	    KitPrdCCode NVARCHAR(100),
		PrdCCode    NVARCHAR(100),
		PrdBatCode  NVARCHAR(100) 
	)
--Kit Product	
	DECLARE @KitProductCode TABLE
	(
	 KitPrdId NUMERIC(18,0),
	 KitPrdCCode NVARCHAR(100)
	)
--Kit Sub Product	
	DECLARE @KitSubProductCode TABLE
	(
	 PrdId NUMERIC(18,0),
	 PrdCCode NVARCHAR(100),
	 KitPrdCCode NVARCHAR(100),
	 Qty NUMERIC (18,0)
	)
--Existing Kit Product	
	DECLARE @ExistingKitProduct TABLE
	(
	 KitPrdId NUMERIC(18,0),
	 PrdId NUMERIC(18,0)
	)
--Till Here	
	IF EXISTS(SELECT DISTINCT KitItemCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE KitItemCode NOT IN 
	         (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)) 
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE KitItemCode NOT IN 
	    (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product','PrdCCode','KirProduct:'+KitItemCode+' Not Available in Product Master' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
        WHERE KitItemCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)
	END
	IF EXISTS(SELECT DISTINCT ProductCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)))
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK))
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'Product','PrdCCode','Product:'+KitItemCode+' Not Available in Product Master' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE KitItemCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK))
	END
	IF EXISTS(SELECT DISTINCT ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE ProductBatchCode NOT IN 
	         (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All')
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductBatchCode NOT IN (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 3,'Product Batch','PrdBatcode','Product Batch'+ProductBatchCode+ 'Not Available in Product Batch' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductBatchCode NOT IN (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All'
	END
	
--Kit Product Id 
     INSERT INTO @KitProductCode (KitPrdId,KitPrdCCode) 
     SELECT DISTINCT A.PrdId AS KitPrdId,C.KitItemCode
     FROM Product A WITH (NOLOCK),Cn2Cs_Prk_KitProducts C WITH (NOLOCK) 
     WHERE A.PrdCCode = C.KitItemCode AND A.PrdType = 3 AND C.DownloadFlag = 'D' AND C.KitItemCode+'~'+C.ProductCode NOT IN
     (SELECT KitPrdCCode+'~'+PrdCCode FROM KitProductToAvoid)
--Kit Sub Prdoduct Id
    IF EXISTS (SELECT * FROM @KitProductCode)
    BEGIN
         INSERT INTO @KitSubProductCode (PrdId,PrdCCode,KitPrdCCode,Qty)
		 SELECT DISTINCT A.PrdId AS PrdId,C.ProductCode,C.KitItemCode,Quantity AS Qty 
		 FROM Product A WITH (NOLOCK),Cn2Cs_Prk_KitProducts C WITH (NOLOCK) 
		 WHERE A.PrdCCode = C.ProductCode AND DownloadFlag = 'D' AND C.KitItemCode+'~'+C.ProductCode NOT IN
		 (SELECT KitPrdCCode+'~'+PrdCCode FROM KitProductToAvoid) --GROUP BY A.PrdId,C.ProductCode,C.KitItemCode
    END
--Existing KitProduct & KitSubProducts
    IF EXISTS (SELECT * FROM @KitSubProductCode)
    BEGIN
      INSERT INTO @ExistingKitProduct (KitPrdId,PrdId)
      SELECT KitPrdid,PrdId FROM KitProduct WITH (NOLOCK) WHERE CAST(KitPrdid AS NVARCHAR(10))+'~'+CAST(Prdid AS NVARCHAR(10)) IN
     (SELECT CAST(KitPrdid AS NVARCHAR(10))+'~'+CAST(Prdid AS NVARCHAR(10)) FROM @KitProductCode A,@KitSubProductCode B
      WHERE A.KitPrdCCode = B.KitPrdCCode)
    END        
 --KitProduct & KitSubProducts Not Exisits     
     INSERT INTO KitProduct (KitPrdid,PrdId,Qty,CmpId,Availability,LastModBy,LastModDate,AuthId,AuthDate)     
     SELECT DISTINCT A.KitPrdId AS KitPrdId,B.PrdId,SUM(B.Qty) AS Qty,@CmpId,1,1,CONVERT(NVARCHAr(10),GETDATE(),121),1,CONVERT(NVARCHAr(10),GETDATE(),121) 
     FROM @KitProductCode A,@KitSubProductCode B WHERE A.KitPrdCCode = B.KitPrdCCode AND CAST(A.KitPrdId AS NVARCHAR(10))+'~'+CAST(B.PrdId AS NVARCHAR(10)) 
     NOT IN (SELECT CAST(KitPrdId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)) FROM @ExistingKitProduct)
     GROUP BY A.KitPrdId,B.PrdId
     INSERT INTO KitProductBatch (KitPrdId,PrdId,PrdBatId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
     SELECT DISTINCT A.KitPrdId AS KitPrdId,B.PrdId,0,1,1,CONVERT(NVARCHAr(10),GETDATE(),121),1,CONVERT(NVARCHAr(10),GETDATE(),121)
     FROM @KitProductCode A,@KitSubProductCode B WHERE A.KitPrdCCode = B.KitPrdCCode AND CAST(A.KitPrdId AS NVARCHAR(10))+'~'+CAST(B.PrdId AS NVARCHAR(10)) 
     NOT IN (SELECT CAST(KitPrdId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)) FROM @ExistingKitProduct)
     GROUP BY A.KitPrdId,B.PrdId
 --KitProduct & KitSubProducts Exists    
     UPDATE A SET A.Qty = Z.Qty FROM KitProduct A INNER JOIN (
     SELECT C.KitPrdId,C.PrdId,SUM(Qty) AS Qty FROM @KitProductCode A,@KitSubProductCode B,@ExistingKitProduct C 
     WHERE A.KitPrdCCode = B.KitPrdCCode AND A.KitPrdId = C.KitPrdId AND B.PrdId = C.PrdId GROUP BY C.KitPrdId,C.PrdId ) Z ON 
     A.KitprdId = Z.KitPrdId AND A.Prdid = Z.PrdId        
 --DownloadFlag Updation
     SELECT KitPrdId,PrdCCode AS KitPrdCode INTO #KitProduct FROM KitProduct A WITH (NOLOCK),Product B WITH (NOLOCK) 
     WHERE A.KitPrdid = B.PrdId AND B.PrdType = 3
     SELECT KitPrdCode,PrdCCode INTO #DownloadKitProduct FROM #KitProduct A WITH (NOLOCK),KitProduct C WITH (NOLOCK),Product B WITH (NOLOCK)
     WHERE A.KitPrdid = C.KitPrdid AND C.PrdId = B.PrdId 
    UPDATE Cn2Cs_Prk_KitProducts SET DownloadFlag = 'Y' WHERE KitItemCode+'~'+ProductCode
    IN (SELECT KitPrdCode+'~'+ PrdCCode FROM #DownloadKitProduct)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_Retailer' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Retailer
GO
CREATE PROCEDURE Proc_Cs2Cn_Retailer
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_CS2CN_BLRetailer
* PURPOSE	: Extract Retailer Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 09-01-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Retailer WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Retailer
	(
		DistCode ,
		RtrId ,
		RtrCode ,
		CmpRtrCode ,
		RtrName ,
		RtrAddress1,
		RtrAddress2,
		RtrAddress3,
		RtrPINCode,
		RtrChannelCode ,
		RtrGroupCode ,
		RtrClassCode ,
		Status,
		KeyAccount,
		RelationStatus,
		ParentCode,
		RtrRegDate,
		GeoLevel,
		GeoLevelValue,
		VillageId,
		VillageCode,
		VillageName,
		Mode,
        DrugLNo,			
		UploadFlag
	)
	SELECT
		@DistCode ,
		R.RtrId ,
		R.RtrCode ,
		R.CmpRtrCode ,
		R.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode ,
		'' CtgCode ,
		'' ValueClassCode ,
		RtrStatus,	
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New',R.RtrDrugLicNo,'N'				
	FROM		
		Retailer R
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
	WHERE			
		R.Upload = 'N'
	UNION
	SELECT
		@DistCode ,
		RCC.RtrId,
		RCC.RtrCode,
		R.CmpRtrCode,
		RCC.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode,
		'' CtgCode,
		'' ValueClassCode,
		RtrStatus,
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','CR',R.RtrDrugLicNo,'N'			
	FROM
		RetailerClassficationChange RCC			
		INNER JOIN Retailer R ON R.RtrId=RCC.RtrId
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
	WHERE 	
		UpLoadFlag=0
	UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,ETL.RtrClassCode=RVC.ValueClassCode
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode ,RVC.ValueClassCode
		FROM
		RetailerValueClassMap RVCM ,
		RetailerValueClass RVC	,
		RetailerCategory RC ,
		RetailerCategoryLevel RCL,
		RetailerCategory RC1,
		Retailer R  		
	WHERE
		R.Rtrid = RVCM.RtrId
		AND	RVCM.RtrValueClassId = RVC.RtrClassId
		AND	RVC.CtgMainId=RC.CtgMainId
		AND	RCL.CtgLevelId=RC.CtgLevelId
		AND	RC.CtgLinkId = RC1.CtgMainId
	) AS RVC
	WHERE ETL.RtrId=RVC.RtrId
	
	UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoLevelValue=Geo.GeoName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
		ISNULL(G.GeoName,'') AS GeoName
		FROM			
		Retailer R  		
		LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
		LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId
	) AS Geo
	WHERE ETL.RtrId=Geo.RtrId	
	UPDATE ETL SET ETL.VillageId=V.VillageId,ETL.VillageCode=V.VillageCode,ETL.VillageName=V.VillageName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,R.VillageId,V.VillageCode,V.VillageName
		FROM			
		Retailer R  		
		INNER JOIN RouteVillage V ON R.VillageId=V.VillageId
	) V
	WHERE ETL.RtrId=V.RtrId	
	UPDATE Retailer SET Upload='Y' WHERE Upload='N'
	AND CmpRtrCode IN(SELECT CmpRtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='New')
	UPDATE RetailerClassficationChange SET UpLoadFlag=1 WHERE UpLoadFlag=0
	AND RtrCode IN(SELECT RtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='CR')
	UPDATE Cs2Cn_Prk_Retailer SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_DailySales' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_DailySales
GO
/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DailySales
UPDATE SalesInvoice SET Upload=0
EXEC Proc_Cs2Cn_DailySales 0
SELECT * FROM Cs2Cn_Prk_DailySales
SELECT * FROM SalesInvoice WHERE DlvSts IN (4,5)
SELECT SIP.* FROM SalesInvoice SI,SalesInvoiceProduct SIP WHERE SI.SAlId=SIP.SalId AND SI.DlvSts IN (4,5)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_DailySales
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DailySales
* PURPOSE		: To Extract Daily Sales Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 19/03/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 			AS INT
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @DefCmpAlone	AS INT
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'Y'
	SELECT @DefCmpAlone=Status FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1	
	INSERT INTO Cs2Cn_Prk_DailySales
	(
		DistCode		,
		SalInvNo		,
		SalInvDate		,
		SalDlvDate		,
		SalInvMode		,
		SalInvType		,
		SalGrossAmt		,
		SalSplDiscAmt	,
		SalSchDiscAmt	,
		SalCashDiscAmt	,
		SalDBDiscAmt	,
		SalTaxAmt		,
		SalWDSAmt		,
		SalDbAdjAmt		,
		SalCrAdjAmt		,
		SalOnAccountAmt	,
		SalMktRetAmt	,
		SalReplaceAmt	,
		SalOtherChargesAmt,
		SalInvLevelDiscAmt,
		SalTotDedn		,
		SalTotAddn		,
		SalRoundOffAmt	,
		SalNetAmt		,
		LcnId			,
		LcnCode			,
		SalesmanCode	,
		SalesmanName	,	
		SalesRouteCode	,
		SalesRouteName	,
		RtrId			,
		RtrCode			,
		RtrName			,
		VechName		,
		DlvBoyName		,
		DeliveryRouteCode	,	
		DeliveryRouteName	,	
		PrdCode				,
		PrdBatCde			,
		PrdQty				,
		PrdSelRateBeforeTax	,
		PrdSelRateAfterTax	,
		PrdFreeQty		,
		PrdGrossAmt		,
		PrdSplDiscAmt	,
		PrdSchDiscAmt	,
		PrdCashDiscAmt	,
		PrdDBDiscAmt	,
		PrdTaxAmt		,
		PrdNetAmt		,
		UploadFlag		,
		SalInvLineCount ,
		SalInvLvlDiscPer
	)
	SELECT 	@DistCode,A.SalInvNo,A.SalInvDate,A.SalDlvDate,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,
	A.OtherCharges,A.SalInvLvlDisc AS InvLevelDiscAmt,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,A.LcnId,L.LcnCode,
	B.SMCode,B.SMName,C.RMCode,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,
	ISNULL(E.VehicleRegNo,'') AS VehicleName,D.DlvBoyName,F.RMCode,F.RMName,H.PrdCCode,I.CmpBatCode,
	G.BaseQty AS SalInvQty ,G.PrdUom1EditedSelRate,G.PrdUom1EditedNetRate,G.SalManFreeQty AS SalInvFree ,
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount,
	'N' AS UploadFlag,0,A.SalInvLvlDiscPer
	FROM SalesInvoice A  (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID
	INNER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId AND H.PrdId=I.PrdId
	INNER JOIN Location L (NOLOCK)	ON L.LcnId=A.LcnId
	WHERE A.Dlvsts IN (4,5)  AND A.Upload=0
		
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where ProcId = 1
	UPDATE A SET SalInvLineCount=B.SalInvLineCount
	FROM Cs2Cn_Prk_DailySales A,(SELECT SI.SalInvNo,COUNT(SIP.PrdId) AS SalInvLineCount 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP WHERE 
	SI.DlvSts IN (4,5) AND SI.UPload=0 AND SI.SalId=SIP.SalId
	GROUP BY SI.SalInvNo) B
	WHERE A.SalInvNo=B.SalInvNo
	--->Added By Nanda on 17/08/2010
	INSERT INTO Cs2Cn_Prk_SalesInvoiceOrders(DistCode,SalInvNo,OrderNo,OrderDate,UploadFlag)
	SELECT DISTINCT @DistCode,SI.SalInvNo,OB.OrderNo,OB.OrderDate,'N'
	FROM SalesInvoice SI,SalesinvoiceOrderBooking SIOB,OrderBooking OB
	WHERE SI.SalId=SIOB.SalId AND SIOB.OrderNo=OB.OrderNo AND SI.Upload=0 AND SI.DlvSts>3
	--->Till Here
	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'N') AND Dlvsts IN (4,5)
	UPDATE Cs2Cn_Prk_DailySales SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_Stock' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Stock
GO
/*
BEGIN TRANSACTION
SELECT * FROM DayEndProcess
UPDATE DayEndProcess Set NextUpDate = '2008-12-01' Where procId = 11
DELETE FROM Cs2Cn_Prk_Stock
SELECT * FROM ETL_PrkCS2CNStkInventory WHERE [PRODUCTCODE]='701016' ORDER BY salInvDate
EXEC Proc_Cs2Cn_StkInventory
SELECT * FROM StockLedger WHERE TransDate>='2008/12/01'
SELECT * FROM Cs2Cn_Prk_Stock
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_Stock
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_CS2CNStkInventoryNew
* PURPOSE		: To Extract Stock Ledger Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 19/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @DefCmpAlone	AS INT
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Stock WHERE UploadFlag = 'Y'
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 11
	INSERT INTO Cs2Cn_Prk_Stock(DistCode,TransDate,LcnId,LcnCode,PrdId,PrdCode,PrdBatId,PrdBatCode,SalOpenStock,UnSalOpenStock,
	OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,
	SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
	OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,
	OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,
	OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,UploadFlag)
	SELECT @DistCode,TransDate,SL.LcnId,L.LcnCode,SL.PrdId,P.PrdCCode,SL.PrdBatId,PB.CmpBatCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,
	UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,
	SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,
	SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
	UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
	OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,
	SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,'N'
	FROM StockLedger SL (NOLOCK),Product P (NOLOCK),ProductBatch PB (NOLOCK),Location L (NOLOCK)
	WHERE SL.PrdId=P.PrdId AND SL.PrdBatId=PB.PrdBatId AND P.PrdId=PB.PrdId
	AND P.CmpId=(CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE P.CmpId END)
	AND SL.LcnId=L.LcnId AND Sl.TransDate>=@ChkDate	AND (SalPurchase+UnsalPurchase+OfferPurchase+SalPurReturn+UnsalPurReturn+
	OfferPurReturn+SalSales+UnSalSales+OfferSales+SalStockIn+UnSalStockIn+OfferStockIn+SalStockOut+UnSalStockOut+OfferStockOut+
	DamageIn+DamageOut+SalSalesReturn+UnSalSalesReturn+OfferSalesReturn+SalStkJurIn+UnSalStkJurIn+OfferStkJurIn+SalStkJurOut+
	UnSalStkJurOut+OfferStkJurOut+SalBatTfrIn+UnSalBatTfrIn+OfferBatTfrIn+SalBatTfrOut+UnSalBatTfrOut+OfferBatTfrOut+SalLcnTfrIn+
	UnSalLcnTfrIn+OfferLcnTfrIn+SalLcnTfrOut+UnSalLcnTfrOut+OfferLcnTfrOut+SalReplacement+OfferReplacement)>0
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GETDATE(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	WHERE ProcId = 11
	UPDATE Cs2Cn_Prk_Stock SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_SalesReturn' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_SalesReturn
GO
CREATE PROCEDURE Proc_Cs2Cn_SalesReturn  
(  
 @Po_ErrNo INT OUTPUT,
 @ServerDate DATETIME  
)  
AS
--EXEC Proc_Cs2Cn_SalesReturn 0   
/*********************************  
* PROCEDURE  : Proc_Cs2Cn_SalesReturn  
* PURPOSE  : To Extract Sales Return Details from CoreStocky to upload to Console  
* CREATED BY : Nandakumar R.G  
* CREATED DATE : 21/03/2010  
* NOTE   :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @CmpId    AS INT  
 DECLARE @DistCode  As nVarchar(50)  
 DECLARE @DefCmpAlone AS INT  
 SET @Po_ErrNo=0  
 SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'  
 DELETE FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'Y'  
 SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
 INSERT INTO [Cs2Cn_Prk_SalesReturn]  
 (  
  DistCode  ,  
  SRNRefNo  ,  
  SRNRefType  ,  
  SRNDate   ,  
  SRNMode   ,  
  SRNType   ,   
  SRNGrossAmt  ,  
  SRNSplDiscAmt ,   
  SRNSchDiscAmt ,  
  SRNCashDiscAmt ,  
  SRNDBDiscAmt ,  
  SRNTaxAmt  ,  
  SRNRoundOffAmt ,
  SRNInvDiscount,  
  SRNNetAmt  ,  
  SalesmanName ,  
  SalesRouteName ,  
  RtrId   ,  
  RtrCode   ,  
  RtrName   ,  
  PrdSalInvNo  ,  
  PrdLcnId  ,  
  PrdLcnCode  ,  
  PrdCode   ,  
  PrdBatCde  ,  
  PrdSalQty  ,  
  PrdUnSalQty  ,  
  PrdOfferQty  ,  
  PrdSelRate  ,  
  PrdGrossAmt  ,  
  PrdSplDiscAmt ,  
  PrdSchDiscAmt ,  
  PrdCashDiscAmt ,  
  PrdDBDiscAmt ,  
  PrdTaxAmt  ,  
  PrdNetAmt  ,  
  UploadFlag  
 )  
 SELECT  
  @DistCode ,  
  A.ReturnCode ,  
  (CASE ReturnType WHEN 1 THEN 'Market Return' ELSE 'Sales Return' END),  
  A.ReturnDate ,  
  (CASE A.ReturnMode WHEN 0 THEN '' WHEN 1 THEN 'Full' ELSE 'Partial' END),  
  (CASE A.InvoiceType WHEN 1 THEN 'Single Invoice' ELSE 'Multi Invoice' END),  
  A.RtnGrossAmt,A.RtnSplDisAmt,A.RtnSchDisAmt,A.RtnCashDisAmt,A.RtnDBDisAmt,  
  A.RtnTaxAmt,A.RtnRoundOffAmt,A.RtnInvLvlDisc,A.RtnNetAmt,  
  SM.SMName,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,  
  ISNULL(G.SalInvno,B.SalCode) AS SalInvNo,  
  L.LcnId,L.LcnCode,    
  D.PrdCCode,F.CmpBatCode,  
  (CASE ST.SystemStockType WHEN 1 THEN BaseQty ELSE 0 END)AS SalQty,  
  (CASE ST.SystemStockType WHEN 2 THEN BaseQty ELSE 0 END)AS UnSalQty,  
  (CASE ST.SystemStockType WHEN 3 THEN BaseQty ELSE 0 END)AS OfferQty,  
  B.PrdEditSelRte ,  
  B.PrdGrossAmt,B.PrdSplDisAmt,B.PrdSchDisAmt,B.PrdCDDisAmt,B.PrdDBDisAmt,  
  B.PrdTaxAmt,B.PrdNetAmt,  
  'N' AS UploadFlag  
 FROM ReturnHeader A INNER JOIN ReturnProduct B ON A.ReturnId = B.ReturnId  
  INNER JOIN RouteMaster C ON A.RMID = C.RMID  
  INNER JOIN Product D ON B.PrdId = D.PrdId  
  INNER JOIN Company E ON D.CmpId = E.CmpId  
  INNER JOIN ProductBatch F ON B.PrdBatId = F.PrdBatId  
  INNER JOIN Retailer R ON R.RtrId=A.RtrId  
  LEFT OUTER JOIN SalesInvoice G ON B.SalId = G.SalId  
  INNER JOIN Salesman SM ON A.SMId=SM.SMId  
  INNER JOIN StockType ST ON B.StockTypeId=ST.StockTypeId  
  INNER JOIN Location L ON L.LcnId=ST.LcnId  
 WHERE A.Status = 0 AND E.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE E.CmpId END)  
 AND A.Upload=0  
 UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),  
 ProcDate = CONVERT(nVarChar(10),GetDate(),121)  
 Where ProcId = 4  
 UPDATE ReturnHeader SET Upload=1 WHERE Upload=0 AND ReturnCode IN (SELECT DISTINCT  
 SRNRefNo FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'N') AND Status=0   
 UPDATE Cs2Cn_Prk_SalesReturn SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_PurchaseConfirmation' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_PurchaseConfirmation
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_PurchaseConfirmation 0
SELECT * FROM Cs2Cn_Prk_PurchaseConfirmation ORDER BY GRNRefNo
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_PurchaseConfirmation
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_PurchaseConfirmation
* PURPOSE		: To Extract Purchase Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 19/03/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INT
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @DefCmpAlone	AS INT
	SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_PurchaseConfirmation WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_PurchaseConfirmation
	(
		DistCode				,
		GRNCmpInvNo				,
		GRNRefNo				,
		GRNRcvdDate				,
		GRNInvDate				,
		GRNPORefNo				,
		SupplierCode			,
		TransporterCode			,
		LRNo					,
		LRDate					,
		GRNGrossAmt				,
		GRNDiscAmt				,
		GRNTaxAmt				,
		GRNSchAmt				,
		GRNOtherChargesAmt		,
		GRNHandlingChargesAmt	,
		GRNTotDedn				,
		GRNTotAddn				,
		GRNRoundOffAmt			,
		GRNNetAmt				,
		GRNNetPayableAmt		,
		GRNDiffAmt				,
		PrdRowId				,
		PrdSchemeFlag			,
		PrdCmpSchCode			,	
		PrdLcnId				,
		PrdLcnCode				,
		PrdCode					,
		PrdBatCode				,
		PrdInvQty				,
		PrdRcvdQty				,
		PrdUnSalQty				,
		PrdShortQty				,
		PrdExcessQty			,
		PrdExcessRefusedQty		,
		PrdLSP					,
		PrdGrossAmt				,
		PrdDiscAmt				,
		PrdTaxAmt				,
		PrdNetRate				,
		PrdNetAmt				,
		PrdLineBreakUpType		,
		PrdLineLcnId			,
		PrdLineLcnCode			,
		PrdLineStockType		,
		PrdLineQty				,
		UploadFlag			
	)
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GoodsRcvdDate AS GrnRcvDt ,
		PR.InvDate,PR.PurOrderRefNo,S.SpmCode,T.TransporterCode,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,PRP.PrdSlNo,'No','',PR.LcnId,L.LcnCode,
		P.PrdCCode AS ProdCode ,PB.CmpBatCode AS PrdBatCde ,
		PRP.InvBaseQty,PRP.RcvdGoodBaseQty,UnSalBaseQty,ShrtBaseQty,
		(CASE PRP.RefuseSale WHEN 0 THEN ExsBaseQty ELSE 0 END),
		(CASE PRP.RefuseSale WHEN 1 THEN ExsBaseQty ELSE 0 END),
		PRP.PrdLSP,PRP.PrdGrossAmount,PRP.PrdDiscount,PRP.PrdTaxAmount,PRP.PrdUnitNetRate,PRP.PrdNetAmount,
		ISNULL((CASE PRB.BreakUpType WHEN 1 THEN 'UnSaleable' WHEN 2 THEN 'Excess' END),''),
		ISNULL(PRBL.LcnId,0),ISNULL(PRBL.LcnCode,''),
		ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
		ISNULL(PRB.BaseQty,0),
		'N'					
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 AND
		PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END) AND PR.Upload=0
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN Location L ON L.LcnId=PR.LcnId
		LEFT OUTER JOIN PurchaseReceiptBreakUp PRB ON PRP.PurRcptId=PRB.PurRcptId AND PRP.PrdSlNo=PRB.PrdSlNo
		LEFT OUTER JOIN StockType ST ON PRB.StockTypeId=ST.StockTypeId
		LEFT OUTER JOIN Location PRBL ON PRBL.LcnId=ST.LcnId
	UNION ALL
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GoodsRcvdDate AS GrnRcvDt ,
		PR.InvDate,PR.PurOrderRefNo,S.SpmCode,T.TransporterCode,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,PRP.SlNo,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),
		ISNULL(Sch.CmpSchCode,Sch.SchCode),L.LcnId,L.LcnCode,
		P.PrdCCode AS ProdCode ,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'',0,'',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0,
		'N'					
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 AND
		PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END) AND PR.Upload=0 AND PRP.TypeId=2
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId
		LEFT OUTER JOIN SchemeMaster Sch ON Sch.SchId=RefId
	UNION ALL
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GoodsRcvdDate AS GrnRcvDt ,
		PR.InvDate,PR.PurOrderRefNo,S.SpmCode,T.TransporterCode,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,PRP.SlNo,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),
		ISNULL(CSD.RefCode,''),L.LcnId,L.LcnCode,
		P.PrdCCode AS ProdCode ,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'',0,'',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0,
		'N'					
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 AND
		PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END) AND PR.Upload=0 AND PRP.TypeId=1
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId
		INNER JOIN ClaimSheetHd CSH ON CSH.ClmId=PRP.RefId
		INNER JOIN ClaimSheetDetail CSD ON CSH.ClmId=CSD.ClmId AND PRP.SlNo=CSD.SlNo
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where procId = 3
	UPDATE PurchaseReceipt SET Upload=1 WHERE Upload=0 AND PurRcptRefNo IN (SELECT DISTINCT
	GRNRefNo FROM Cs2Cn_Prk_PurchaseConfirmation WHERE UploadFlag = 'N')
	UPDATE Cs2Cn_Prk_PurchaseConfirmation SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_PurchaseReturn' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_PurchaseReturn
GO
/*
BEGIN TRANSACTION
SELECT * FROM PurchaseReturn
EXEC Proc_Cs2Cn_PurchaseReturn 0
SELECT * FROM Cs2Cn_Prk_PurchaseReturn
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_PurchaseReturn
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_Cs2Cn_PurchaseReturn
* PURPOSE	: Extract Purchase Return Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G On 08-03-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	SET @Po_ErrNo=0
	DECLARE @CmpID 			AS INT
	DECLARE @DistCode		As nVarchar(50)
	DECLARE @ChkDate		AS DATETIME
	DECLARE @SeekApproval 	AS INT
	DECLARE @DefCmpAlone	AS INT
	SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	DELETE FROM Cs2Cn_Prk_PurchaseReturn WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @SeekApproval=ISNULL(Status,0) FROM Configuration WHERE ModuleId='PRN1'
	INSERT INTO Cs2Cn_Prk_PurchaseReturn
	(
		DistCode			,
		PRNRefNo			,	
		PRNDate				,
		CmpCode				,
		SpmCode				,
		PRNMode				,
		PRNType				,
		GRNNo				,
		CmpInvNo			,
		PRNGrossAmt			,
		PRNDiscAmt			,
		PRNSchAmt			,
		PRNOtherChargesAmt	,
		PRNTaxAmt			,
		PRNTotDedn			,
		PRNTotAddn			,
		PRNRoundOffAmt		,
		PRNNetAmt			,
		PrdRowId			,
		PrdSchemeFlag		,
		PrdCmpSchCode		,
		PrdLcnId			,
		PrdLcnCode			,
		PrdCode				,
		PrdBatCode			,
		PrdSalQty			,
		PrdUnSalQty			,
		PrdRate				,
		PrdGrossAmt			,
		PrdDiscAmt			,
		PrdTaxAmt			,
		PrdNetRate			,
		PrdNetAmt			,
		Reason				,
		PrdLineBreakUpType	,	
		PrdLineLcnId		,
		PrdLineLcnCode		,
		PrdLineStockType	,	
		PrdLineQty			,
		UploadFlag	
	)
	SELECT @DistCode,PR.PurRetRefNo,PR.PurRetDate,C.CmpCode,S.SpmCode,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PR.CmpInvNo,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,PR.TotalAddition,0,PR.NetAmount,
	PRP.PrdSlNo,'No','',PR.LcnId,L.LcnCode,P.PrdCCode,PB.PrdBatCode,PRP.RetSalBaseQty,PRP.RetUnSalBaseQty,
	PRP.PrdUnitLSP,PRP.PrdGrossAmount,PRP.PrdDiscount,PRP.PrdTaxAmount,PRP.PrdUnitNetRate,PRP.PrdNetAmount,ISNULL(R.Description,''),
	ISNULL((CASE PRB.BreakUpType WHEN 1 THEN 'UnSaleable' WHEN 2 THEN 'Excess' END),''),
	ISNULL(PRBL.LcnId,0),ISNULL(PRBL.LcnCode,''),
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	ISNULL(PRB.BaseQty,0),'N'
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnProduct PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId
	AND PR.Upload=0 AND PR.Status=(CASE @SeekApproval WHEN 1 THEN 0 ELSE 1 END)	AND
	PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END)
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN Location L ON L.LcnId=PR.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId	
	LEFT OUTER JOIN ReasonMaster R(NOLOCK) ON PRP.ReasonId=R.ReasonId
	LEFT OUTER JOIN PurchaseReturnBreakUp PRB ON PRP.PurRetId=PRB.PurRetId AND PRP.PrdSlNo=PRB.PrdSlNo
	LEFT OUTER JOIN StockType ST ON PRB.StockTypeId=ST.StockTypeId
	LEFT OUTER JOIN Location PRBL ON PRBL.LcnId=ST.LcnId
	UNION ALL
	SELECT @DistCode,PR.PurRetRefNo,PR.PurRetDate,C.CmpCode,S.SpmCode,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PR.CmpInvNo,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,
	PR.TotalAddition,0,PR.NetAmount,0,
	(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),ISNULL(SM.CmpSchCode,SM.SchCode),
	L.LcnId,L.LcnCode,P.PrdCCode,PB.PrdBatCode,PRP.RetQty,0,
	PRP.RetValue,PRP.RetAmount,0,0,0,PRP.RetAmount,'','',0,'',
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	0,'N'
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnClaimScheme PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId AND PRP.TypeId=2
	AND PR.Upload=0 AND PR.Status=(CASE @SeekApproval WHEN 1 THEN 0 ELSE 1 END)	AND
	PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END)
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
	INNER JOIN Location L ON L.LcnId=ST.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId		
	LEFT OUTER JOIN SchemeMaster SM(NOLOCK) ON SM.SchId=PRP.RefId
	
	UNION ALL
	SELECT @DistCode,PR.PurRetRefNo,PR.PurRetDate,C.CmpCode,S.SpmCode,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PR.CmpInvNo,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,
	PR.TotalAddition,0,PR.NetAmount,0,
	(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),ISNULL(CSD.RefCode,''),
	L.LcnId,L.LcnCode,P.PrdCCode,PB.PrdBatCode,PRP.RetQty,0,
	PRP.RetValue,PRP.RetAmount,0,0,0,PRP.RetAmount,'','',0,'',
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	0,'N'
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnClaimScheme PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId AND PRP.TypeId=1 AND
	PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END)
	INNER JOIN PurchaseReceiptClaimScheme PRPT(NOLOCK) ON PR.PurRcptId=PRPT.PurRcptId AND PRPT.TypeId=1
	AND PR.Upload=0 AND PR.Status=(CASE @SeekApproval WHEN 1 THEN 0 ELSE 1 END)	
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
	INNER JOIN Location L ON L.LcnId=ST.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId		
	LEFT OUTER JOIN ClaimSheetHd CSH ON CSH.ClmId=PRP.RefId
	LEFT OUTER JOIN ClaimSheetDetail CSD ON CSH.ClmId=CSD.ClmId AND PRPT.SlNo=CSD.SlNo
	
	IF @SeekApproval=0
	BEGIN
		UPDATE PurchaseReturn SET Upload=1 WHERE Upload=0 AND Status=1 AND PurRetRefNo IN (SELECT DISTINCT
		PRNRefNo FROM Cs2Cn_Prk_PurchaseReturn WHERE UploadFlag = 'N')
	END
	ELSE IF @SeekApproval=1
	BEGIN
		UPDATE PurchaseReturn SET Status=2,Upload=1 WHERE Upload=0 AND Status=0 AND PurRetRefNo IN (SELECT DISTINCT
		PRNRefNo FROM Cs2Cn_Prk_PurchaseReturn WHERE UploadFlag = 'N')
	END
	UPDATE Cs2Cn_Prk_PurchaseReturn SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_ClaimAll' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_ClaimAll
GO
/*
BEGIN TRANSACTION
TRUNCATE TABLE Cs2Cn_Prk_ClaimAll
TRUNCATE TABLE Cs2Cn_Prk_Claim_SchemeDetails
EXEC Proc_Cs2Cn_ClaimAll 0
SELECT * FROM Cs2Cn_Prk_ClaimAll
SELECT * FROM Cs2Cn_Prk_Claim_SchemeDetails
SELECT * FROM ClaimSheetHd
ROLLBACK TRANSACTION	
*/
CREATE PROCEDURE Proc_Cs2Cn_ClaimAll
(
	@Po_ErrNo  INT OUTPUT,
	@ServerDate DATETIME
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_ClaimAll
* PURPOSE	: Extract Claim sheet details from CoreStocky to Console-->Nivea
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 13/11/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag='Y'
	SET @Po_ErrNo  =0
	EXEC Proc_Cs2Cn_Claim_RateDiffernece
	EXEC Proc_Cs2Cn_Claim_Scheme
	EXEC Proc_Cs2Cn_Claim_Manual
	EXEC Proc_Cs2Cn_Claim_BatchTransfer
	EXEC Proc_Cs2Cn_Claim_DeliveryBoy
	EXEC Proc_Cs2Cn_Claim_PurchaseExcess
	EXEC Proc_Cs2Cn_Claim_PurchaseShortage
	EXEC Proc_Cs2Cn_Claim_ResellDamage
	EXEC Proc_Cs2Cn_Claim_ReturnToCompany
	EXEC Proc_Cs2Cn_Claim_Salesman
	EXEC Proc_Cs2Cn_Claim_SalesmanIncentive
	EXEC Proc_Cs2Cn_Claim_Salvage
	EXEC Proc_Cs2Cn_Claim_SpecialDiscount
	EXEC Proc_Cs2Cn_Claim_Transporter
	EXEC Proc_Cs2Cn_Claim_VanSubsidy
	EXEC Proc_Cs2Cn_Claim_Vat	
	EXEC Proc_Cs2Cn_Claim_StockJournal
	EXEC Proc_Cs2Cn_Claim_RateChange
	EXEC Proc_Cs2Cn_Claim_ModernTrade
	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH,ClaimSheetDetail CD
	WHERE CH.ClmId=CD.ClmId AND CD.RefCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll)
	AND CH.Confirm=1 AND Status=1
	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH
	WHERE CH.ClmCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll WHERE ClaimType='Scheme Claim')
	AND CH.Confirm=1
	
	UPDATE Cs2Cn_Prk_ClaimAll SET BillDate = CONVERT(NVARCHAR(10),GETDATE(),121) WHERE (BillDate IS NULL OR BillDate = '')
	UPDATE Cs2Cn_Prk_ClaimAll SET Date2 = CONVERT(NVARCHAR(10),GETDATE(),121) WHERE (Date2 IS NULL OR Date2 = '')
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(NVARCHAR(10),GETDATE(),121),
	ProcDate = CONVERT(NVARCHAR(10),GETDATE(),121)
	Where ProcId = 12
	RETURN
	UPDATE Cs2Cn_Prk_ClaimAll SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_SchemeUtilizationDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_SchemeUtilizationDetails
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_SchemeUtilizationDetails 0
SELECT * FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE SchUtilizeType='Points'
--SELECT * FROM SalesInvoiceSchemeLineWise
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_SchemeUtilizationDetails
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_SchemeUtilizationDetails
* PURPOSE		: To Extract Scheme Utilization Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 19/10/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @ChkSRDate	AS DATETIME
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 1
	SELECT @ChkSRDate = NextUpDate FROM DayEndProcess Where ProcId = 4
	--->Billing-Scheme Amount
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Billing','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,(ISNULL(SUM(FlatAmount),0)+ISNULL(SUM(DiscountPerAmount),0)) AS Utilized,		
	A.DiscPer,'','',0,0,'N'
	FROM SalesInvoiceSchemeLineWise A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId = B.SalId AND A.SalId=SIP.SalId AND SIP.PrdId=A.PrdID AND SIP.PrdBatId=A.PrdBatId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0 AND (FlatAmount+DiscountPerAmount)>0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,A.DiscPer
	--->Billing-Free Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Billing','Free Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Free Product','',0,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0) AS Utilized,0,
	P.PrdCCode,C.PrdBatCode,SUM(FreeQty) AS FreeQty,0,'N'
	FROM SalesInvoiceSchemeDtFreePrd A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.FreePrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode
	
	--->Billing-Gift Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Billing','Gift Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Gift Product','',0,ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0) AS Utilized,0,
	P.PrdCCode,C.PrdBatCode,SUM(GiftQty) AS GiftQty,0,'N'
	FROM SalesInvoiceSchemeDtFreePrd A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.GiftPrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode
	--->Billing-Window Display
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Billing','WDS',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	0,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(AdjAmt),0) AS Utilized,0,'','',0,0,'N'
	FROM SalesInvoiceWindowDisplay A
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode
	
	--->Billing-QPS Credit Note Conversion
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Billing','QPS Converted Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(A.CrNoteAmount),0) AS Utilized,0,'','',0,0,'N'
	FROM SalesInvoiceQPSSchemeAdj A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId AND Mode=1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode
	UNION ALL
	SELECT @DistCode,'Billing','QPS Converted Amount(Auto)',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,'AutoQPSConversion' AS SalInvNo,A.LastModDate,A.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(A.CrNoteAmount),0) AS Utilized,0,'','',0,0,'N'
	FROM SalesInvoiceQPSSchemeAdj A 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId AND Mode=2
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Retailer R ON R.RtrId = A.RtrId
	WHERE CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,A.LastModDate,
	A.RtrId,R.CmpRtrCode,R.RtrCode
	--->Billing-Scheme Points
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Billing','Points',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,SUM(A.Points) AS Utilized,0,'','',0,0,'N'
	FROM SalesInvoiceSchemeDtPoints A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId = B.SalId AND A.SalId=SIP.SalId AND SIP.PrdId=A.PrdID AND SIP.PrdBatId=A.PrdBatId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0 AND A.Points>0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty 
	--->Cheque Disbursal
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Cheque Disbursal','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	0,B.ChqDisRefNo,A.ChqDisDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(Amount),0) AS Utilized,0,'','',0,0,'N'
	FROM ChequeDisbursalMaster A
	INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo
	INNER JOIN SchemeMaster SM ON A.TransId = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE TransType = 1 AND CM.CmpID = @CmpID AND A.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,B.ChqDisRefNo,A.ChqDisDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode
	--->Sales Return-Amount
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,-1 * (ISNULL(SUM(ReturnFlatAmount),0) + ISNULL(SUM(ReturnDiscountPerAmount),0)),0,	
	'','',0,0,'N'
	FROM ReturnSchemeLineDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN ReturnProduct SIP ON SIP.ReturnId = B.ReturnId AND A.ReturnId=SIP.ReturnId AND SIP.PrdId=A.PrdId AND SIP.PrdBatId=A.PrdBatId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty
	--->Sales Return-Free Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Free Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Free Product','',0,-1 * ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0),0,
	P.PrdCCode,C.PrdBatCode,-1 * SUM(ReturnFreeQty),0,'N'
	FROM ReturnSchemeFreePrdDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.FreePrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode
	--->Sales Return-Gift Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Gift Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Gift Product','',0,-1 * ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0),0,
	P.PrdCCode,C.PrdBatCode,-1 * SUM(ReturnGiftQty),0,'N'
	FROM ReturnSchemeFreePrdDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.GiftPrdId = P.PrdId 
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode
	--->Sales Return-Scheme Points
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,NoOfTimes,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Points',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,-1 * SUM(ReturnPoints),0,'','',0,0,'N'
	FROM ReturnSchemePointsDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN ReturnProduct SIP ON SIP.ReturnId = B.ReturnId AND A.ReturnId=SIP.ReturnId AND SIP.PrdId=A.PrdId AND SIP.PrdBatId=A.PrdBatId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty
	SELECT SchId INTO #SchId FROM SchemeMaster WHERE SchCode IN (SELECT SchCode FROM Cs2Cn_Prk_SchemeUtilizationDetails
	WHERE UploadFlag='N')
	UPDATE SalesInvoice SET SchemeUpLoad=1 WHERE SalId IN (SELECT DISTINCT SalId FROM
	SalesInvoiceSchemeHd WHERE SchId IN (SELECT SchId FROM #SchId)) AND DlvSts IN (4,5)
	AND SalInvNo IN (SELECT TransNo FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE TransName='Billing')
	UPDATE SalesInvoice SET SchemeUpLoad=1 WHERE SalId IN (SELECT DISTINCT SalId FROM
	SalesInvoiceWindowDisplay WHERE SchId IN (SELECT SchId FROM #SchId)) AND DlvSts IN (4,5)
	AND SalInvNo IN (SELECT TransNo FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE TransName='Billing')	
	UPDATE A SET A.NoOfTimes=B.NoOfTimes
	FROM Cs2Cn_Prk_SchemeUtilizationDetails A,	
	(SELECT SI.SalInvNo,SI.SalId,SIS.SchId,SIS.SlabId,SM.CmpSchCOde,SIS.NoOfTimes FROM SalesInvoiceSchemeHd SIS,SalesInvoice SI,SchemeMaster SM
	WHERE SI.SalId=SIS.SalId AND SIS.SchId=SM.SchId) B
	WHERE A.TransName='Billing' AND A.CmpSchCode=B.CmpSchCode AND A.TransNo=B.SalInvNo
	UPDATE SalesInvoiceQPSSchemeAdj SET Upload=1
	WHERE SalId IN (SELECT SalId FROM SalesInvoice WHERE SchemeUpload=1) AND Mode=1
	UPDATE SalesInvoiceQPSSchemeAdj SET Upload=1
	WHERE SalId = -1000 AND Mode=2
	UPDATE ReturnHeader SET SchemeUpLoad=1 WHERE ReturnId IN 
	(
		SELECT DISTINCT ReturnId FROM 
		(
			SELECT ReturnId FROM ReturnSchemeFreePrdDt WHERE SchId IN (SELECT SchId FROM #SchId)
			UNION
			SELECT ReturnId FROM ReturnSchemeLineDt WHERE SchId IN (SELECT SchId FROM #SchId)
			UNION
			SELECT ReturnId FROM ReturnSchemePointsDt WHERE SchId IN (SELECT SchId FROM #SchId)
		)A
	) AND Status=0
	AND ReturnCode IN (SELECT TransNo FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE TransName='Sales Return')
	UPDATE ChequeDisbursalMaster SET SchemeUpLoad=1 WHERE ChqDisRefNo IN (SELECT DISTINCT ChqDisRefNo FROM
	ChequeDisbursalDetails WHERE TransId IN (SELECT SchId AS TransId FROM #SchId))
	AND TransType = 1 
	AND ChqDisRefNo IN (SELECT TransNo FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE TransName='Cheque Disbursal')
	UPDATE Cs2Cn_Prk_SchemeUtilizationDetails SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_SampleIssue' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_SampleIssue
GO
--EXEC Proc_Cs2Cn_SampleIssue 0
CREATE PROCEDURE Proc_Cs2Cn_SampleIssue
(
@Po_ErrNo INT OUTPUT,
@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_Cs2Cn_SampleIssue
* PURPOSE	: Extract Sample Issue sheet details from CoreStocky to Console
* NOTES		:
* CREATED	: Mahalakshmi.A   04-12-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_SampleIssue WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_SampleIssue
	(
		[DistCode] 		,
		[Reference Number]	,
		[Sample Issue Date]	,
		[RtrId]				,
		[Retailer Code]		,
		[Retailer Name]		,
		[Sample SKU Code]	,
		[Issue Qty]		,
		[UpLoadFlag]
	)
	SELECT @DistCode,A.IssueRefNo,A.IssueDate,A.RtrId,C.CmpRtrCode,C.RtrName,D.PrdDCode,B.IssueQty,'N' As UploadFlag
	FROM SampleISsueHd A WITH (NOLOCK),SampleIssueDt B WITH (NOLOCK),Retailer C WITH (NOLOCK),Product D WITH (NOLOCK)
	WHERE A.IssueID=B.IssueId AND A.RtrId=C.RtrID AND B.PrdID=D.PrdID AND B.[Select]=1 AND A.Upload=0
	UPDATE SampleISsueHd SET Upload=1 WHERE Status=1 AND Upload=0

	SET @Po_ErrNo=0
	UPDATE Cs2Cn_Prk_SampleIssue SET ServerDate=@ServerDate	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_SampleReturn' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_SampleReturn
GO
--EXEC [Proc_Cs2Cn_SampleReturn] 0
CREATE PROCEDURE Proc_Cs2Cn_SampleReturn
(
	@Po_ErrNo INT OUTPUT,	
	@ServerDate DATETIME

)
AS
/*********************************
* PROCEDURE	: Proc_Cs2Cn_SampleReturn
* PURPOSE	: Extract Sample Return sheet details from CoreStocky to Console
* NOTES		:
* CREATED	: Aarthi   29-06-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET  NOCOUNT ON
BEGIN

	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_SampleReturn WHERE UploadFlag = 'Y'

	SELECT @DistCode = DistributorCode FROM Distributor

	INSERT INTO Cs2Cn_Prk_SampleReturn
	(
		[DistCode],
		[ReferenceNumber],
		[SampleReturnDate],
		[SampleIssueReferenceNumber],
		[RtrId],
		[RtrCode],
		[RtrName],
		[SampleSKUCode],
		[ReceivedQty],
		[UploadFlag]
	)
	SELECT @DistCode,A.ReturnRefNo,A.ReturnDate,C.IssueRefNo,A.RtrId,D.CmpRtrCode,D.RtrName,E.PrdDCode,B.ReturnBaseQty,A.Upload
	FROM SampleReturnHd A WITH(NOLOCK), SampleReturnDt B WITH(NOLOCK),SampleIssueHd C WITH(NOLOCK),Retailer D WITH(NOLOCK),Product E WITH (NOLOCK)
	WHERE A.ReturnId=B.ReturnId AND B.IssueId=C.IssueId AND A.RtrId=D.RtrId AND B.PrdId=E.PrdId AND A.Status=1 AND A.Upload=0

	UPDATE SampleReturnHd SET Upload=1 WHERE Status=1 AND Upload=0

	SET @Po_ErrNo=0
	UPDATE Cs2Cn_Prk_SampleReturn SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_PurchaseOrder' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_PurchaseOrder
GO
/*
BEGIN TRANSACTION
Exec Proc_Cs2Cn_PurchaseOrder 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_PurchaseOrder
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS 

SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_Cs2Cn_PurchaseOrder
* PURPOSE	: Extract Purchase Order details from CoreStocky to Console
* NOTES		:
* CREATED	: MarySubashini.S 08-12-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_PurchaseOrder WHERE UploadFlag='Y' 

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 6
	SET @Po_ErrNo=0

	INSERT INTO Cs2Cn_Prk_PurchaseOrder 
	(	
		[DistCode]		,
		[PONumber]		,
		[CompanyPONumber]	,
		[PODate]		,
		[POConfirmDate]		,
		[ProductHierarchyLevel]	,
		[ProductHierarchyValue]	,
		[ProductCode]	 	,
		[Quantity]		,
		[POType]  		,
		[POExpiryDate]  	,
		[SiteCode]	,
		[UploadFlag]
	)
	SELECT @DistCode,PM.PurOrderRefNo,
	(CASE PM.DownLoad WHEN 1 THEN PM.CmpPoNo ELSE '' END) AS CompanyPONumber,
	PM.PurOrderDate,PM.PurOrderDate,PCL1.CmpPrdCtgName,PCV1.PrdCtgValCode,
	P.PrdDCode,(PD.OrdQty*UG.ConversionFactor) AS Quantity,
	(CASE PM.DownLoad WHEN 0 THEN 'Manual' ELSE 'Automatic' END ) AS POType,
	(CASE PM.DownLoad WHEN 0 THEN PM.PurOrderExpiryDate ELSE '' END ) AS POExpiryDate,
	ISNULL(SCM.SiteCode,''),'N'
	FROM PurchaseOrderDetails PD  WITH (NOLOCK) 
	LEFT OUTER JOIN PurchaseOrderMaster PM WITH (NOLOCK)  ON PM.PurOrderRefNo=PD.PurOrderRefNo
	LEFT OUTER JOIN Product P WITH (NOLOCK)  ON P.PrdId=PD.PrdId
	LEFT OUTER JOIN UomGroup UG WITH (NOLOCK)  ON UG.UomGroupId=P.UomGroupId AND UG.UomId=PD.OrdUomId
	LEFT OUTER JOIN ProductCategoryValue PCV WITH (NOLOCK)  ON PCV.PrdCtgValMainId=PM.PrdCtgValMainId 
	LEFT OUTER JOIN ProductCategoryValue PCV1 WITH (NOLOCK)  ON PCV1.PrdCtgValLinkCode=LEFT(PCV.PrdCtgValLInkCode,6) 
	LEFT OUTER JOIN ProductCategoryLevel PCL1 WITH (NOLOCK)  ON PCL1.CmpPrdCtgId=PCV1.CmpPrdCtgId 
	LEFT OUTER JOIN SiteCodeMaster SCM WITH (NOLOCK) ON PM.SiteId=SCM.SiteId 
	WHERE PM.ConfirmSts=1 AND PM.Upload=0

	UPDATE PurchaseOrderMaster SET Upload=1 WHERE Upload=0 AND ConfirmSts=1
	AND PurOrderRefNo IN (SELECT PONumber FROM Cs2Cn_Prk_PurchaseOrder)	
	UPDATE Cs2Cn_Prk_PurchaseOrder SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_OrderBooking' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_OrderBooking
GO
/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_OrderBooking
UPDATE OrderBooking SET Upload=0
EXEC Proc_Cs2Cn_OrderBooking 0
SELECT * FROM Cs2Cn_Prk_OrderBooking
SELECT * FROM OrderBooking 
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_OrderBooking
(
	@Po_ErrNo INT OUTPUT,	
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
		DECLARE @CmpId 			AS INT
		DECLARE @DistCode	As nVarchar(50)
		DECLARE @DefCmpAlone	AS INT
		SET @Po_ErrNo=0
		DELETE FROM Cs2Cn_Prk_OrderBooking WHERE UploadFlag = 'Y'
		SELECT @DefCmpAlone=Status FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
		SELECT @DistCode = DistributorCode FROM Distributor	
		SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1	
		INSERT INTO Cs2Cn_Prk_OrderBooking
		(
			DistCode		,
			OrderNo			,
			OrderDate		,
			OrdDlvDate		,
			AllowBackOrder	,
			OrdType			,
			OrdPriority		,
			OrdDocRef		,
			Remarks			,
			RoundOffAmt		,
			OrdTotalAmt		,
			SalesmanCode	,
			SalesmanName	,
			SalesRouteCode	,
			SalesRouteName	,
			RtrId			,
			RtrCode			,
			RtrName			,
			PrdCode			,
			PrdBatCde		,
			PrdQty			,
			PrdBilledQty	,
			PrdSelRate		,
			PrdGrossAmt		,
			RecordDate		,
			UploadFlag		
		)
		SELECT @DistCode,OB.OrderNo,OB.OrderDate,OB.DeliveryDate,(CASE OB.AllowBackOrder WHEN 1 THEN 'Yes' ELSE 'No' END) AS AllowBackOrder,
		(CASE OB.OrdType WHEN 0 THEN 'Phone' WHEN 1 THEN 'In Person' ELSE 'Internet' END) AS OrdType,
		(CASE OB.Priority WHEN 0 THEN 'Normal' WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' ELSE 'High' END) AS Priority,
		OB.DocRefNo,OB.Remarks,OB.RndOffValue,OB.TotalAmount,SM.SMCode,SM.SMName,RM.RMCode,RM.RMName,R.RtrId,R.RtrCode,R.RtrName,
		P.PrdCCode,PB.PrdBatCode,OBP.TotalQty,OBP.BilledQty,OBP.Rate,OBP.GrossAmount,GETDATE(),'N'
		FROM OrderBooking OB
		INNER JOIN OrderBookingProducts OBP ON OB.OrderNo=OBP.OrderNo AND OB.Upload=0 
		INNER JOIN Product P ON OBP.PrdId=P.PrdId
		INNER JOIN ProductBatch PB ON OBP.PrdBatId=PB.PrdBatId AND P.PrdId=PB.PrdId
		INNER JOIN SalesMan SM ON OB.SMId=SM.SMId
		INNER JOIN RouteMaster RM ON OB.RMId=RM.RMId
		INNER JOIN Retailer R ON OB.RtrId=R.RtrId
		UPDATE OrderBooking SET Upload=1 WHERE Upload=0 AND OrderNo IN (SELECT DISTINCT
		OrderNo FROM Cs2Cn_Prk_OrderBooking WHERE UploadFlag = 'N')
		UPDATE Cs2Cn_Prk_OrderBooking SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_Dummy' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Dummy
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_Dummy 0
ROLLBACK TRANSACTION	
*/
CREATE PROCEDURE Proc_Cs2Cn_Dummy
(
	@Po_ErrNo  INT OUTPUT,
	@ServerDate DATETIME
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_Dummy
* PURPOSE	: Dummy SP for Upload Integration
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 18/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	SET @Po_ErrNo  =0
	
	RETURN
	UPDATE Cs2Cn_Prk_SalesInvoiceOrders SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_Salesman' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Salesman
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_Salesman 0
SELECT * FROM Cs2Cn_Prk_Salesman ORDER BY SlNo
SELECT * FROM Retailer
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_Salesman
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_Salesman
* PURPOSE		: To Extract Salesman Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 22/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Salesman WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Salesman
	(
		DistCode,
		SMId,
		SMCode,
		SMName,
		SMPhoneNo,
		SMEmail,
		SMOtherDetails,
		SMDailyAllowance,
		SMMonthlySalary,
		SMMktCredit,
		SMCreditDays,
		Status,
		RMId,
		RMCode,
		RMName,
		UploadFlag
	)
	SELECT
		@DistCode,
		SM.SMId,
		SM.SMCode,
		SM.SMName,
		SM.SMPhoneNumber,
		SM.SMEmailID,
		SM.SMOtherDetails,
		SM.SMDailyAllowance,
		SM.SMMonthlySalary,
		SM.SMMktCredit,
		SM.SMCreditDays,
		(CASE SM.Status WHEN 0 THEN 'InActive' ELSE 'Active' END) AS Status,
		ISNULL(SMR.RMId,0) AS RMId,
		ISNULL(RM.RMCode,'') AS RMCode,
		ISNULL(RM.RMName,'') AS RMName,
		'N'				
	FROM		
		Salesman SM LEFT OUTER JOIN  SalesmanMarket SMR
		ON SM.SMId=SMR.SMId
		LEFT OUTER JOIN  RouteMaster RM ON SMR.RMId=RM.RMId
	WHERE			
		SM.Upload = 'N' 

	UPDATE Salesman SET Upload='Y'
	WHERE SMCode IN (SELECT SMCode FROM Cs2Cn_Prk_Salesman)
	UPDATE Cs2Cn_Prk_Salesman SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_Route' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Route
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_Route 0
SELECT * FROM Cs2Cn_Prk_Route ORDER BY SlNo
SELECT * FROM RouteMaster
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_Route
(
	@Po_ErrNo	INT OUTPUT,	
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_Route
* PURPOSE		: To Extract Route Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 22/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Route WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Route
	(
		DistCode,
		RMId,
		RMCode,
		RMName,
		Distance,
		RMPopulation,
		VanRoute,
		RouteType,
		LocalUpCountry,
		GeoLevel,
		GeoValue,
		Status,
		MonDay,
		TuesDay,
		WednesDay,
		ThursDay,
		FriDay,
		SaturDay,
		SunDay,
		UploadFlag
	)
	SELECT
		@DistCode,
		RM.RMId,
		RM.RMCode,
		RM.RMName,
		RM.RMDistance,
		RM.RMPopulation,
		RM.RMVanRoute,
		RM.RMSRouteType,
		RM.RMLocalUpcountry,
		'' AS GeoLevel,
		'' AS GeoValue,
		(CASE RM.RMstatus WHEN 0 THEN 'InActive' ELSE 'Active' END) AS Status,
		(CASE RM.RMMon WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMTue WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMWed WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMThu WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMFri WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMSat WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMSun WHEN 1 THEN 'Yes' ELSE 'No' END),		
		'N'				
	FROM		
		RouteMaster RM
	WHERE			
		RM.Upload = 'N'
	UPDATE A SET A.GeoLevel=B.GeoLevelName,A.GeoValue=B.GeoCode
	FROM Cs2Cn_Prk_Route A,
	(SELECT RM.RMId,GL.GeoLevelName,G.GeoCode FROM RouteMaster RM,Geography G,GeographyLevel GL
	WHERE RM.GeoMainId=G.GeoMainId AND G.GeoLevelId=GL.GeoLevelId AND RM.Upload='N') B
	WHERE A.RMid=B.RMId
	UPDATE RouteMaster  SET Upload='Y'
	WHERE RMCode IN (SELECT RMCode FROM Cs2Cn_Prk_Route)
	UPDATE Cs2Cn_Prk_Route SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_RetailerRoute' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_RetailerRoute
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_RetailerRoute 0
SELECT * FROM Cs2Cn_Prk_RetailerRoute ORDER BY SlNo
SELECT * FROM RetailerMarket
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_RetailerRoute
(
	@Po_ErrNo	INT OUTPUT,	
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_RetailerRoute
* PURPOSE		: To Extract Retailer Route Mapping Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_RetailerRoute WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_RetailerRoute
	(
		DistCode	,
		RtrId		,
		RtrCode		,
		RtrName		,
		RMId		,
		RMCode		,
		RMName		,
		RouteType	,
		UploadFlag	
	)
	SELECT @DistCode,RtrId,CmpRtrCode,RtrName,RMId,RMCode,RMName,RouteType,'N' 
	FROM 
	(
		SELECT RMK.RtrId,R.CmpRtrCode,R.RtrName,RMK.RMId,RM.RMCode,RM.RMName,'Sales Route' AS RouteType FROM RetailerMarket RMK,Retailer R,RouteMaster RM
		WHERE R.RtrId=RMK.RtrId AND RMK.RMId=RM.RMId AND RMK.Upload=0
		UNION ALL
		SELECT R.RtrId,R.CmpRtrCode,R.RtrName,R.RMId,RM.RMCode,RM.RMName,'Delivery Route' AS RouteType  FROM Retailer R,RouteMaster RM
		WHERE RM.RMId=R.RMId AND R.RtrId IN (SELECT RtrId FROM RetailerMarket WHERE Upload=0)
	)
	AS A
	ORDER BY RtrId,CmpRtrCode,RtrName,RMId,RMCode,RMName,RouteType 

	UPDATE RetailerMarket SET Upload=1
	WHERE RtrId IN (SELECT DISTINCT RtrId FROM Cs2Cn_Prk_RetailerRoute)
	UPDATE Cs2Cn_Prk_RetailerRoute SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_RouteVillage' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_RouteVillage
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_RouteVillage 0
SELECT * FROM Cs2Cn_Prk_RouteVillage ORDER BY SlNo
SELECT * FROM RouteMaster
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_RouteVillage
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_RouteVillage
* PURPOSE		: To Extract Route Village Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 11/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_RouteVillage WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_RouteVillage
	(
		DistCode,
		VillageId,
		RMId,
		RMCode,
		RMName,
		VillageCode,
		VillageName,
		Distance,
		[Population],
		RtrPopulation,
		RoadCondition,
		IncomeLevel,
		Accepability,
		Awareness,
		Status,
		UploadFlag
	)
	SELECT
		@DistCode,
		V.VillageId,
		RM.RMId,
		RM.RMCode,
		RM.RMName,
		V.VillageCode,
		V.VillageName,
		V.Distance,
		V.[Population],
		V.RtrPopulation,
		(CASE V.RoadCondition WHEN 1 THEN 'Good' WHEN 2 THEN 'Above Average' WHEN 3 THEN 'Average' WHEN 4 THEN 'Below Average' ELSE 'Poor' END),
		(CASE V.IncomeLevel WHEN 1 THEN 'Good' WHEN 2 THEN 'Above Average' WHEN 3 THEN 'Average' WHEN 4 THEN 'Below Average' ELSE 'Poor' END),
		(CASE V.Acceptability WHEN 1 THEN 'Good' WHEN 2 THEN 'Above Average' WHEN 3 THEN 'Average' WHEN 4 THEN 'Below Average' ELSE 'Poor' END),
		(CASE V.Awareness WHEN 1 THEN 'Good' WHEN 2 THEN 'Above Average' WHEN 3 THEN 'Average' WHEN 4 THEN 'Below Average' ELSE 'Poor' END),		
		(CASE V.VillageStatus WHEN 0 THEN 'InActive' ELSE 'Active' END) AS Status,		
		'N'				
	FROM		
		RouteVillage V,RouteMaster RM
	WHERE			
		V.RMId=RM.RMId AND V.Upload = 0
	
	UPDATE RouteVillage  SET Upload=1
	WHERE VillageCode IN (SELECT VillageCode FROM Cs2Cn_Prk_RouteVillage)
	UPDATE Cs2Cn_Prk_RouteVillage SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_ClusterAssign' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_ClusterAssign
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_ClusterAssign 0
SELECT * FROM Cs2Cn_Prk_ClusterAssign ORDER BY SlNo
SELECT * FROM ClusterAssign WHERE MasterId=79
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_ClusterAssign
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
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
	UPDATE Cs2Cn_Prk_ClusterAssign SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_DailyBusinessDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_DailyBusinessDetails
GO
/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DailyBusinessDetails
EXEC Proc_Cs2Cn_DailyBusinessDetails 0
SELECT * FROM Cs2Cn_Prk_DailyBusinessDetails
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_DailyBusinessDetails
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DailyBusinessDetails
* PURPOSE		: To Extract Daily Business Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 01/10/2010
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

	SET @Po_ErrNo=0

	DELETE FROM Cs2Cn_Prk_DailyBusinessDetails WHERE UploadFlag = 'Y'

	SELECT @DistCode=DistributorCode FROM Distributor

	DECLARE @BusinessDates TABLE
	(
		SLNo			INT,
		BusinessDate	DATETIME
	)

	SET @Idx=1
	WHILE @Idx<=7
	BEGIN
		INSERT INTO @BusinessDates(SlNo,BusinessDate)
		SELECT 1,CONVERT(NVARCHAR(10),GETDATE()-(7-@Idx),121)
		SET @Idx=@Idx+1
	END

	INSERT INTO Cs2Cn_Prk_DailyBusinessDetails(DistCode,UploadedDate,TransDate,SalInvCount,SalInvGrossValue,SalInvNetValue,PurInvCount,PurInvGrossValue,
	PurInvNetValue,SRNCount,SRNGrossValue,SRNNetValue,PRNCount,PRNGrossValue,PRNNetValue,InventoryCount,RetailerCount,SchSalInvCount,UploadFlag)
	SELECT @DistCode,GETDATE(),BusinessDate,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'N'
	FROM @BusinessDates

	--Sales Details	
	UPDATE A SET A.SalInvCount=B.SalInvCount,A.SalInvGrossValue=B.SalInvGrossValue,A.SalInvNetValue=B.SalInvNetValue
	FROM Cs2Cn_Prk_DailyBusinessDetails A,
	(SELECT BD.BusinessDate,COUNT(SalId) AS SalInvCount,SUM(SalGrossAmount) AS SalInvGrossValue,SUM(SalNetAmt) AS SalInvNetValue
	FROM SalesInvoice SI(NOLOCK),@BusinessDates BD WHERE SI.SalInvDate=BD.BusinessDate
	AND SI.DlvSts>3
	GROUP BY BD.BusinessDate) B
	WHERE A.TransDate=B.BusinessDate

	--Sales Return Details
	UPDATE A SET A.SRNCount=B.SRNCount,A.SRNGrossValue=B.SRNGrossValue,A.SRNNetValue=B.SRNNetValue
	FROM Cs2Cn_Prk_DailyBusinessDetails A,
	(SELECT BD.BusinessDate,COUNT(ReturnId) AS SRNCount,SUM(RtnGrossAmt) AS SRNGrossValue,SUM(RtnNetAmt) AS SRNNetValue
	FROM ReturnHeader SI(NOLOCK),@BusinessDates BD WHERE SI.ReturnDate=BD.BusinessDate
	AND SI.Status=0
	GROUP BY BD.BusinessDate) B
	WHERE A.TransDate=B.BusinessDate

	--Purchase Details
	UPDATE A SET A.PurInvCount=B.PurInvCount,A.PurInvGrossValue=B.PurInvGrossValue,A.PurInvNetValue=B.PurInvNetValue
	FROM Cs2Cn_Prk_DailyBusinessDetails A,
	(SELECT BD.BusinessDate,COUNT(PurRcptId) AS PurInvCount,SUM(GrossAmount) AS PurInvGrossValue,SUM(NetAmount) AS PurInvNetValue
	FROM PurchaseReceipt SI(NOLOCK),@BusinessDates BD WHERE SI.GoodsRcvdDate=BD.BusinessDate
	AND SI.Status=1
	GROUP BY BD.BusinessDate) B
	WHERE A.TransDate=B.BusinessDate

	--Purchase Return Details
	UPDATE A SET A.PRNCount=B.PRNCount,A.PRNGrossValue=B.PRNGrossValue,A.PRNNetValue=B.PRNNetValue
	FROM Cs2Cn_Prk_DailyBusinessDetails A,
	(SELECT BD.BusinessDate,COUNT(PurRetId) AS PRNCount,SUM(GrossAmount) AS PRNGrossValue,SUM(NetAmount) AS PRNNetValue
	FROM PurchaseReturn SI(NOLOCK),@BusinessDates BD WHERE SI.PurRetDate=BD.BusinessDate
	AND SI.Status=1
	GROUP BY BD.BusinessDate) B
	WHERE A.TransDate=B.BusinessDate

	--Inventory Details
	UPDATE A SET A.InventoryCount=B.InventoryCount
	FROM Cs2Cn_Prk_DailyBusinessDetails A,
	(SELECT BD.BusinessDate,COUNT(PrdId) AS InventoryCount
	FROM StockLedger SI(NOLOCK),@BusinessDates BD WHERE SI.TransDate=BD.BusinessDate	
	GROUP BY BD.BusinessDate) B
	WHERE A.TransDate=B.BusinessDate
	
	--Retailer Details
	UPDATE A SET A.RetailerCount=B.RetailerCount
	FROM Cs2Cn_Prk_DailyBusinessDetails A,
	(SELECT BD.BusinessDate,COUNT(RtrId) AS RetailerCount
	FROM Retailer SI(NOLOCK),@BusinessDates BD WHERE SI.RtrRegDate<=BD.BusinessDate
	GROUP BY BD.BusinessDate) B
	WHERE A.TransDate=B.BusinessDate

	--Scheme Utilization Details
	UPDATE A SET A.SchSalInvCount=B.SchSalInvCount
	FROM Cs2Cn_Prk_DailyBusinessDetails A,
	(SELECT BusinessDate,COUNT(DISTINCT SalId) AS SchSalInvCount FROM
	(
		SELECT DISTINCT BD.BusinessDate,SIS.SalId FROM SalesInvoiceSchemeLineWise SIS(NOLOCK),SalesInvoice SI(NOLOCK),@BusinessDates BD
		WHERE SIS.SalId=SI.SalId AND SI.SalInvDate=BD.BusinessDate AND Si.DlvSts>3
		UNION ALL
		SELECT DISTINCT BD.BusinessDate,SIS.SalId FROM SalesInvoiceSchemeDtFreePrd SIS(NOLOCK),SalesInvoice SI(NOLOCK),@BusinessDates BD
		WHERE SIS.SalId=SI.SalId AND SI.SalInvDate=BD.BusinessDate AND Si.DlvSts>3
		UNION ALL
		SELECT DISTINCT BD.BusinessDate,SIS.SalId FROM SalesInvoiceWindowDisplay SIS(NOLOCK),SalesInvoice SI(NOLOCK),@BusinessDates BD
		WHERE SIS.SalId=SI.SalId AND SI.SalInvDate=BD.BusinessDate AND Si.DlvSts>3
		UNION ALL
		SELECT DISTINCT BD.BusinessDate,SIS.SalId FROM SalesInvoiceQPSSchemeAdj SIS(NOLOCK),SalesInvoice SI(NOLOCK),@BusinessDates BD
		WHERE SIS.SalId=SI.SalId AND SI.SalInvDate=BD.BusinessDate AND Si.DlvSts>3	
	) AS Sch
	GROUP BY BusinessDate)B
	WHERE A.TransDate=B.BusinessDate
	UPDATE Cs2Cn_Prk_DailyBusinessDetails SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_DBDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_DBDetails
GO
/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DBDetails
EXEC Proc_Cs2Cn_DBDetails 0
SELECT * FROM Cs2Cn_Prk_DBDetails
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_DBDetails
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
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
	SELECT @DistCode+'~'+C.CmpCode+'~'+ISNULL(PrdKey,'') ,@IP,@@ServerName,DBId,Name,CrDate,CrDate,0,FileName,'N' 
	FROM Master.dbo.SysDataBases SD,CurrentDB CD,Company C
	LEFT OUTER JOIN RegInfo ON 1=1 
	WHERE SD.Name=CD.DBName AND C.DefaultCompany=1	
	UPDATE B SET B.DBRestoredDate=A.Restore_Date,B.DBRestoreId=A.Restore_History_Id
	FROM Cs2Cn_Prk_DBDetails B,
	(SELECT * FROM MSDB..RestoreHistory RS
	WHERE RS.Destination_DataBase_Name=@DBName
	AND RS.Restore_Date IN (SELECT MAX(Restore_Date) FROM MSDB..RestoreHistory WHERE Destination_DataBase_Name= @DBName)) A
	WHERE B.DBName=A.Destination_DataBase_Name
	UPDATE Cs2Cn_Prk_DBDetails SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_DownLoadTracing' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_DownLoadTracing
GO
CREATE PROCEDURE Proc_Cs2Cn_DownLoadTracing
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_Cs2Cn_DownLoadTracing
* PURPOSE: Extract Download Tracing details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R	 30-06-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_DownLoadTracing WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor
	
	INSERT INTO Cs2Cn_Prk_DownLoadTracing
	(
			[DistCode],
			[ProcessName],
			[TotRowCount],
			[Process1],
			[Process2],
			[Process3],
			[Process4],
			[Process5],
			[Process6],
			[Process7],
			[Process8],
			[Process9],
			[ProcessPatch],
			[Date],
			[UploadFlag]
	)
	SELECT @DistCode,ProcessName,TotRowCount,Process1,Process2,Process3,Process4,
			Process5,Process6,Process7,Process8,Process9,ProcessPatch,Date,'N' AS UploadFlag
			FROM CS2Console_DownLoadTracing WITH (NOLOCK)
			WHERE UploadFlag='N'
	UPDATE CS2Console_DownLoadTracing SET UploadFlag='Y' WHERE UploadFlag='N'
	UPDATE Cs2Cn_Prk_DownLoadTracing SET ServerDate=@ServerDate
	COMMIT TRAN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_UpLoadTracing' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_UpLoadTracing
GO
--EXEC Proc_Cs2Cn_UpLoadTracing 0
CREATE PROCEDURE Proc_Cs2Cn_UpLoadTracing
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_Cs2Cn_UpLoadTracing
* PURPOSE: Extract Upload Tracing details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R	 30-06-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_UpLoadTracing WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	
	INSERT INTO Cs2Cn_Prk_UpLoadTracing
	(
			[DistCode],
			[ProcessName],
			[Process1],
			[Process2],
			[Process3],
			[Process4],
			[Process5],
			[ProcessPatch],
			[Date],
			[UploadFlag]
	)
	SELECT @DistCode,ProcessName,Process1,Process2,Process3,Process4,Process5,
	ProcessPatch,Date,'N' AS UploadFlag
	FROM CS2Console_UpLoadTracing WITH (NOLOCK)
	WHERE UploadFlag='N'
	UPDATE CS2Console_UpLoadTracing SET UploadFlag='Y' WHERE UploadFlag='N'	
	UPDATE Cs2Cn_Prk_UpLoadTracing SET ServerDate=@ServerDate
	COMMIT TRAN
	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_DailyRetailerDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_DailyRetailerDetails
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_DailyRetailerDetails 0
--SELECT COUNT(*) FROM Cs2Cn_Prk_DailyRetailerDetails ORDER BY RtrId
--SELECT COUNT(*) FROM Retailer ORDER BY RtrId
--DELETE FROM RetailerValueClassMap WHERE RTrId BETWEEN 100 AND 103
--DELETE FROM UdcDetails WHERE MasterRecordId BETWEEN 200 AND 203
--DELETE FROM Cs2Cn_Prk_DailyRetailerDetails
SELECT * FROM Cs2Cn_Prk_DailyRetailerDetails
SELECT * FROM DayEndProcess
--UPDATE DayEndProcess SET NextUpDate='2010-08-10' WHERE ProcId>13
--UPDATE Configuration SET Status=1,ConfigValue=3 WHERE ModuleId='BotreeRtrUpload'
SELECT * FROM Configuration WHERE ModuleId='BotreeRtrUpload'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_DailyRetailerDetails
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DailyRetailerDetails
* PURPOSE		: Extract Retailer Details from CoreStocky to Console
* NOTES			:
* CREATED		: Nandakumar R.G
* CREATED DATE	: 30/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
***********************************************
*
***********************************************/
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @Days		AS INT
	SET @Po_ErrNo=0
	
	DELETE FROM Cs2Cn_Prk_DailyRetailerDetails WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRtrUpload' AND Status=1)
	BEGIN	
		SELECT @Days=ISNULL(ConfigValue,0) FROM Configuration WHERE ModuleId='BotreeRtrUpload' 		
		IF EXISTS(SELECT * FROM DayEndProcess WHERE DATEADD(DAY,@Days,NextUpDate)<=GETDATE() AND ProcId=14)
		BEGIN	
			INSERT INTO Cs2Cn_Prk_DailyRetailerDetails
			(
				DistCode,
				RtrId,
				RtrCode,
				CmpRtrCode,
				RtrName,
				RtrAddr1,
				RtrAddr2,
				RtrAddr3,
				RtrPINCode,
				RtrChannelCode,
				RtrGroupCode,
				RtrClassCode,
				GeoLevel,
				GeoName,
				RtrStatus,
				RegDate,
				RtrUploadStatus,
				UploadedDate,
				UploadFlag
			)
			SELECT
				@DistCode,
				R.RtrId,
				R.RtrCode,
				R.CmpRtrCode,
				R.RtrName,
				R.RtrAdd1,
				R.RtrAdd2,
				R.RtrAdd3,
				R.RtrPinNo,
				'' AS CtgCode,
				'' AS CtgCode,
				'' AS ValueClassCode,
				'' AS GeoLevelName,
				'' AS GeoName,
				(CASE RtrStatus WHEN 1 THEN 'Active' ELSE 'InActive' END) AS RtrStatus,	
				RtrRegDate,
				R.Upload,
				GETDATE(),
				'N'				
			FROM Retailer R  		
				
			UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,ETL.RtrClassCode=RVC.ValueClassCode
			FROM Cs2Cn_Prk_DailyRetailerDetails ETL,
			(
				SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode ,RVC.ValueClassCode
				FROM
				RetailerValueClassMap RVCM ,
				RetailerValueClass RVC	,
				RetailerCategory RC ,
				RetailerCategoryLevel RCL,
				RetailerCategory RC1,
				Retailer R  		
			WHERE
				R.Rtrid = RVCM.RtrId
				AND	RVCM.RtrValueClassId = RVC.RtrClassId
				AND	RVC.CtgMainId=RC.CtgMainId
				AND	RCL.CtgLevelId=RC.CtgLevelId
				AND	RC.CtgLinkId = RC1.CtgMainId
			) AS RVC
			WHERE ETL.RtrId=RVC.RtrId
			
			UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoName=Geo.GeoName
			FROM Cs2Cn_Prk_DailyRetailerDetails ETL,
			(
				SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
				ISNULL(G.GeoName,'') AS GeoName
				FROM			
				Retailer R  		
				LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId
			) AS Geo
			WHERE ETL.RtrId=Geo.RtrId	
			UPDATE DayEndProcess SET NextUpDate=DATEADD(DAY,@Days,NextUpDate) WHERE ProcId=14
		END		
	END
	UPDATE Cs2Cn_Prk_DailyRetailerDetails SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_DailyProductDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_DailyProductDetails
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_DailyProductDetails 0
SELECT COUNT(*) FROM Cs2Cn_Prk_DailyProductDetails
--DELETE FROM Cs2Cn_Prk_DailyProductDetails
SELECT * FROM DayEndProcess WHERE ProcId=15
--UPDATE DayEndProcess SET NextUpDate='2010-08-10' WHERE ProcId>13
--UPDATE Configuration SET Status=1,ConfigValue=2 WHERE ModuleId='BotreePrdUpload'
SELECT * FROM Configuration WHERE ModuleId='BotreeRtrUpload'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_DailyProductDetails
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DailyProductDetails
* PURPOSE		: Upload Daily Product Details from CoreStocky to Console
* NOTES			:
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 30-03-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*************************************************
*
*************************************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @Days		AS INT
	SELECT @DistCode = DistributorCode FROM Distributor
	DELETE FROM Cs2Cn_Prk_DailyProductDetails WHERE UploadFlag = 'Y'
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreePrdUpload' AND Status=1)
	BEGIN
		SELECT @Days=ISNULL(ConfigValue,0) FROM Configuration WHERE ModuleId='BotreePrdUpload'
		IF EXISTS(SELECT * FROM DayEndProcess WHERE DATEADD(DAY,@Days,NextUpDate)<=GETDATE() AND ProcId=15)
		BEGIN
			INSERT INTO Cs2Cn_Prk_DailyProductDetails
			(
				DistCode,
				PrdId,
				ProductCompanyCode,
				ProductDistributorCode,
				ProductName,
				ProductShortName,
				ProductStatus,
				PrdBatId,
				ProductBatchCode,
				CompanyBatchCode,
				ProductBatchStatus,
				DefaultPriceCode,
				DefaultMRP,
				DefaultListPrice,
				DefaultSellingRate,
				DefaultClaimRate,
				AddRate1,
				AddRate2,
				AddRate3,
				AddRate4,
				AddRate5,
				AddRate6,
				UploadedDate,
				UploadFlag
			)
			SELECT
			@DistCode,
			P.PrdId,
			P.PrdCCode AS ProductCompanyCode,
			P.PrdDCode AS ProductDistributorCode,
			P.PrdName AS ProductName,
			P.PrdShrtName AS ProductShortName,
			(CASE P.PrdStatus WHEN 1 THEN 'Active' ELSE 'InActive' END) AS ProductStatus,
			ISNULL(PB.PrdBatId,0) AS PrdBatId,
			ISNULL(PB.PrdBatCode,'') AS ProductBatchCode,
			ISNULL(PB.CmpBatCode,'') AS CompanyBatchCode,
			(CASE PB.Status WHEN 1 THEN 'Active' WHEN 0 THEN 'InActive' ELSE '' END) AS ProductBatchStatus,
			ISNULL(PB.DefaultPriceCode,'')	As DefaultPriceCode,
			ISNULL(PB.DefaultMRP,0) AS DefaultMRP,
			ISNULL(PB.DefaultListPrice,0) AS DefaultListPrice,
			ISNULL(PB.DefaultSellingRate,0) AS DefaultSellingRate,
			ISNULL(PB.DefaultClaimRate,0) AS DefaultClaimRate,
			ISNULL(PB.AddRate1,0) AS AddRate1,
			ISNULL(PB.AddRate2,0) AS AddRate2,
			ISNULL(PB.AddRate3,0) AS AddRate3,
			ISNULL(PB.AddRate4,0) AS AddRate4,
			ISNULL(PB.AddRate5,0) AS AddRate5,
			ISNULL(PB.AddRate6,0) AS AddRate6,
			GETDATE(),
			'N' AS UploadFlag
			FROM Product P
			LEFT OUTER JOIN
			(SELECT PB.PrdId,PB.PrdBatId,PB.CmpBatCode,PB.Status,PB.PrdBatCode,PBDM.PriceCode AS DefaultPriceCode,
			PBDM.PrdBatDetailValue AS DefaultMRP,
			PBDL.PrdBatDetailValue AS DefaultListPrice,
			PBDS.PrdBatDetailValue AS DefaultSellingRate,
			PBDC.PrdBatDetailValue AS DefaultClaimRate,
			0 AS AddRate1,
			0 AS AddRate2,
			0 AS AddRate3,
			0 AS AddRate4,
			0 AS AddRate5,
			0 AS AddRate6
			FROM ProductBatch PB
			INNER JOIN ProductBatchDetails PBDM ON PB.PrdBatId=PBDM.PrdBatId AND PBDM.DefaultPrice=1
			INNER JOIN BatchCreation BCM ON PBDM.SlNo=BCM.SlNo AND PBDM.BatchSeqId=BCM.BatchSeqId
			AND PBDM.BatchSeqId =BCM.BatchSeqId AND BCM.MRP=1
			INNER JOIN ProductBatchDetails PBDL ON PB.PrdBatId=PBDL.PrdBatId AND PBDL.DefaultPrice=1
			INNER JOIN BatchCreation BCL ON PBDL.SlNo=BCL.SlNo AND PBDL.BatchSeqId=BCL.BatchSeqId
			AND PBDL.BatchSeqId =BCL.BatchSeqId AND BCL.ListPrice=1
			INNER JOIN ProductBatchDetails PBDS ON PB.PrdBatId=PBDS.PrdBatId AND PBDS.DefaultPrice=1
			INNER JOIN BatchCreation BCS ON PBDS.SlNo=BCS.SlNo AND PBDS.BatchSeqId=BCS.BatchSeqId
			AND PBDS.BatchSeqId =BCS.BatchSeqId AND BCS.SelRte=1
			INNER JOIN ProductBatchDetails PBDC ON PB.PrdBatId=PBDC.PrdBatId AND PBDC.DefaultPrice=1
			INNER JOIN BatchCreation BCC ON PBDC.SlNo=BCC.SlNo AND PBDC.BatchSeqId=BCC.BatchSeqId
			AND PBDC.BatchSeqId =BCC.BatchSeqId AND BCC.ClmRte=1	
			) PB
			ON P.PrdId=PB.PrdId AND P.PrdCCode=PB.PrdBatCode
			UPDATE Prk SET AddRate1=PB.AddRate1
			FROM Cs2Cn_Prk_DailyProductDetails Prk,
			(SELECT PBDAD1.PrdBatId,PBDAD1.PrdBatDetailvalue AS AddRate1
			FROM BatchCreation BCAD1,ProductBatchDetails PBDAD1
			WHERE PBDAD1.SlNo=BCAD1.SlNo AND PBDAD1.BatchSeqId=BCAD1.BatchSeqId
			AND BCAD1.RefCode='E' AND PBDAD1.DefaultPrice=1) AS PB
			WHERE Prk.PrdBatId=PB.PrdBatId
			UPDATE DayEndProcess SET NextUpDate=DATEADD(DAY,@Days,NextUpDate) WHERE ProcId=15
		END	
	END
	UPDATE Cs2Cn_Prk_DailyProductDetails SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_UploadRecordCheck' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_UploadRecordCheck
GO
--EXEC Proc_Cs2Cn_UploadRecordCheck 0
--SELECT * FROM Cs2Cn_Prk_UploadRecordCheck
--TRUNCATE TABLE Cs2Cn_Prk_UploadRecordCheck
--SELECT * FROM Tbl_UploadIntegration
CREATE PROCEDURE Proc_Cs2Cn_UploadRecordCheck
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_Cs2Cn_UploadRecordCheck
* PURPOSE	: Extract the Details of uploaded data from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 
* DATE		: 15-02-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN

	SET @Po_ErrNo=0

	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME

	DECLARE @sSql		As nVarchar(4000)
	DECLARE @SeqNo		As INT
	DECLARE @sProcName	As nVarchar(200)

	SELECT @DistCode = DistributorCode FROM Distributor

	DELETE FROM Cs2Cn_Prk_UploadRecordCheck WHERE UploadFlag='Y'

	DECLARE Cur_UploadTrack CURSOR
	FOR SELECT SequenceNo,ProcessName FROM Tbl_UploadIntegration ORDER BY SequenceNo
	OPEN Cur_UploadTrack
	FETCH NEXT FROM Cur_UploadTrack INTO @SeqNo,@sProcName
	WHILE @@FETCH_STATUS=0
	BEGIN

		SELECT @sSql='INSERT INTO Cs2Cn_Prk_UploadRecordCheck(DistCode,SeqNo,ProcessName,UploadDate,
		CSMinCount,CSMaxCount,CSRecCount,UploadFlag) 
		SELECT '''+ @DistCode+''','+CAST(@SeqNo AS NVARCHAR(100))+','''+ProcessName+''' ,GETDATE(),ISNULL(MIN(SlNo),0),ISNULL(MAX(SlNo),0),
		ISNULL(COUNT(SlNo),0),''N'' 
		FROM '+PrkTableName+' WHERE UpLoadFlag=''N''' FROM Tbl_UploadIntegration WHERE Sequenceno=@SeqNo AND
		ProcessName=@sProcName 
			
		EXEC(@sSql)

		FETCH NEXT FROM Cur_UploadTrack INTO @SeqNo,@sProcName
	END

	CLOSE Cur_UploadTrack
	DEALLOCATE Cur_UploadTrack
	UPDATE Cs2Cn_Prk_UploadRecordCheck SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_ReUploadInitiate' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_ReUploadInitiate
GO
--EXEC Proc_Cs2Cn_ReUploadInitiate 0
--SELECT * FROM Cs2Cn_Prk_ReUploadInitiate
CREATE PROCEDURE Proc_Cs2Cn_ReUploadInitiate
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_ReUploadInitiate
* PURPOSE		: To Check Uploaded Records in Console
* NOTES			:
* CREATED		: Nandakumar R.G
* CREATED ON	: 19-02-2010
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	BEGIN TRAN
	DECLARE @DistCode	As nVarchar(100)
	SELECT @DistCode = DistributorCode FROM Distributor
	DELETE FROM Cs2Cn_Prk_ReUploadInitiate WHERE UploadFlag='Y'
	INSERT INTO Cs2Cn_Prk_ReUploadInitiate(DistCode,UploadFlag)
	SELECT @DistCode,'N'	
	SET @Po_ErrNo=0
	UPDATE Cs2Cn_Prk_ReUploadInitiate SET ServerDate=@ServerDate
	COMMIT TRAN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_IntegrationHouseKeeping' AND XTYPE='P')
DROP PROCEDURE Proc_IntegrationHouseKeeping
GO
--EXEC Proc_IntegrationHouseKeeping 0
CREATE PROCEDURE Proc_IntegrationHouseKeeping  
(  
	@Po_ErrNo INT Output,
	@ServerDate DATETIME
)  
AS  
/*********************************
* PROCEDURE	: Proc_IntegrationHouseKeeping
* PURPOSE	: To delete the downloaded records from download parking table 
* NOTES		:
* CREATED	: Nandakumar R.G 
* DATE		: 02-09-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN  

	SET @Po_ErrNo=0

	DECLARE @SeqNo INT
	DECLARE @TABLE VARCHAR(200)
	DECLARE @StrQry VARCHAR(8000)
	DECLARE @Count INT

	SET @TABLE = ''
	SET @StrQry = ''
	SET @Count = 0

	CREATE TABLE #CountCheck(RCount INT)

	SELECT @SeqNo = max(SequenceNo) FROM Tbl_DownloadINTegration

	WHILE (@SeqNo > 0)
	BEGIN

		SELECT  @TABLE  = PrkTABLEName FROM Tbl_DownloadINTegration WHERE SequenceNo =  @SeqNo
		SET @StrQry = @StrQry + 'DELETE FROM ' + @TABLE + ' WHERE DownLoadFlag = ''Y'' '

		EXEC(@StrQry)

		SET @StrQry = ''
			EXEC('INSERT INTo #CountCheck SELECT  Count(*)  AS RCount FROM  ' + @TABLE )
		SET @StrQry = ''
		IF (SELECT RCount FROM #CountCheck) = 0
		BEGIN
			SET @StrQry = @StrQry + 'TRUNCATE TABLE ' + @TABLE
			EXEC(@StrQry)
		END
		SET @StrQry = ''
		TRUNCATE TABLE #CountCheck
		SET @SeqNo = @SeqNo - 1

	END
	UPDATE Cs2Cn_Prk_IntegrationHouseKeeping SET ServerDate=@ServerDate
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.0.0.0',407
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 407)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(407,'D','2013-09-05',getdate(),1,'Core Stocky Service Pack 407')
GO