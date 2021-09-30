--[Stocky HotFix Version]=435
DELETE FROM Versioncontrol WHERE Hotfixid='435'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('435','3.1.0.12','D','2018-04-12','2018-04-12','2018-04-12',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product GST Issue Fix')
GO
DELETE FROM Configuration WHERE ModuleId = 'BILL6' AND ModuleName='Billing'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'BILL6','Billing','Enable Apply Scheme in Sync Date Validation',1,'',0.00,6
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ToValidateDailySyncinBilling' and xtype in ('TF','FN'))
DROP FUNCTION Fn_ToValidateDailySyncinBilling
GO
--SELECT * FROM Fn_ToValidateDailySyncinBilling('2017-07-08')
CREATE FUNCTION Fn_ToValidateDailySyncinBilling(@ServerDate AS DATETIME,@Type as int)
RETURNS @ValidateDailySyncinBilling TABLE
(
	MsgId	INT,
	Msg		VARCHAR(200),
	CBPSyncFlag	tinyint,
	GetSyncStatus	tinyint
)
AS
/*************************************************************************************************
* PROCEDURE  : Fn_ToValidateDailySyncinBilling
* PURPOSE    : To Return to Validate Dailt Sync Status for Biling
* CREATED BY : S.Moorthi
* CREATED ON : 12/12/2017
* MODIFICATION
**************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID       DESCRIPTION                         
**************************************************************************************************
12/12/2017  S.Moorthi   CR      CCRSTPAR0180         Distributor will not be allowed for billing, If sync process is not completed at least once in a day
**************************************************************************************************
*/
BEGIN

	--if @Type=3
	--BEGIN
	--	RETURN
	--END

	DECLARE @Mandatory as int
	SET @Mandatory=1
	DECLARE @Msg AS VARCHAR(200)
	
	SET @ServerDate=CONVERT(VARCHAR(10),GETDATE(),121)
	
	IF NOT EXISTS(SELECT Status FROM Configuration WHERE ModuleId = 'BILL6' AND ModuleName='Billing' AND Status=1)
	BEGIN
		RETURN
	END

	IF @Mandatory=0
	BEGIN
		SET @Msg='Sync not done for the day. Please do sync process for scheme to get applied, do you want to continue'
	END
	ELSE
	BEGIN
		SET @Msg='Sync not done for the day. Please do sync process to continue the billing'
	END
	
	IF NOT EXISTS(SELECT ISNULL(SyncStatus,0)SyncStatus FROM SYNCSTATUS(NOLOCK) 
	WHERE SyncStatus=1 AND CONVERT(VARCHAR(10),dwnendtime,121)=CONVERT(VARCHAR(10),@ServerDate,121))
	BEGIN	
		INSERT INTO @ValidateDailySyncinBilling
		SELECT @Mandatory,@Msg,0,1
	END

	
RETURN
END
GO
--Added By S.Moorthi Starts Here
DELETE FROM Tbl_DownloadIntegration WHERE ProcessName in ('RouteMaster','SalesManMaster','Retailer Re-Download')
INSERT INTO Tbl_DownloadIntegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) 
SELECT 78,'RouteMaster','Cn2Cs_Prk_RouteMaster','Proc_Import_RouteMaster',0,500,'2015-08-05' UNION
SELECT 79,'SalesManMaster','Cn2Cs_Prk_SalesManMaster','Proc_Import_SalesManMaster',0,500,'2015-08-05' UNION
SELECT 80,'Retailer Re-Download','Cn2Cs_Prk_RetailerReDownload','Proc_Import_RetailerReDownload',0,500,'2015-08-05'
GO
DELETE FROM CustomUpDownload WHERE Updownload='Download' and Module in ('RouteMaster','SalesManMaster','Retailer Re-Download')
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
SELECT 270,1,'RouteMaster','RouteMaster','','Proc_Import_RouteMaster','Cn2Cs_Prk_RouteMaster','Proc_CN2CS_RouteMaster','Master','Download',1 UNION
SELECT 271,1,'SalesManMaster','SalesManMaster','','Proc_Import_SalesManMaster','Cn2Cs_Prk_SalesManMaster','Proc_CN2CS_SalesManMaster','Master','Download',1 UNION
SELECT 272,1,'Retailer Re-Download','Retailer Re-Download','','Proc_Import_RetailerReDownload','Cn2Cs_Prk_RetailerReDownload','Proc_Cn2Cs_RetailerReDownload','Master','Download',1
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Cn2Cs_Prk_RetailerReDownload' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[Cn2Cs_Prk_RetailerReDownload](
	[DistCode] [nvarchar](100) NULL,
	[RetailerCode] [nvarchar](100) NULL,
	[CmpRtrCode] [nvarchar](100) NULL,
	[RetailerName] [nvarchar](400) NULL,
	[RtrAddress1] [nvarchar](400) NULL,
	[RtrAddress2] [nvarchar](400) NULL,
	[RtrAddress3] [nvarchar](400) NULL,
	[RtrPinNo] [int] NULL,
	[RtrChannelCode] [nvarchar](100) NULL,
	[RtrGroupCode] [nvarchar](100) NULL,
	[RtrClassCode] [nvarchar](100) NULL,
	[KeyAccount] [nvarchar](20) NULL,
	[RelationStatus] [nvarchar](100) NULL,
	[ParentCode] [nvarchar](100) NULL,
	[RtrRegDate] [nvarchar](100) NULL,
	[RtrStatus] [int]NULL,
	[Approved] [varchar](10) NULL,
	[SalesRoute] [nvarchar](50) NULL,
	[DeliveryRoute] [nvarchar](50) NULL,
	[RtrType] [varchar](100) NULL,
	[RtrTINNo] [nvarchar](100) NULL,
	[RtrCrBills] [int] NULL,
	[RtrCrLimit] [numeric](38, 6) NULL,
	[RtrCrDays] [int] NULL,
	[RtrDayOff] [int] NULL,
	[RtrCSTNo] [nvarchar](100) NULL,
	[RtrPhoneNo] [nvarchar](100) NULL,
	[RtrContactPerson] [nvarchar](100) NULL,
	[RtrTaxGroup] [nvarchar](100) NULL,
	[RtrTaxable] [varchar](1) NULL,
	[RtrUniqueCode]	[nvarchar](100) NULL,
	[RtrShippAdd1] [nvarchar](200) NULL,
	[RtrShippAdd2] [nvarchar](200) NULL,
	[RtrShippAdd3] [nvarchar](200) NULL,
	[DownloadFlag] [varchar](1) NULL,
	CreatedDate	[DATETIME]
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Cn2Cs_Prk_RouteMaster' AND xtype='U')
BEGIN
CREATE TABLE Cn2Cs_Prk_RouteMaster(
	[DistCode] [nvarchar](100) NULL,
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
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate]	[DATETIME]
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Cn2Cs_Prk_SalesmanMaster' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[Cn2Cs_Prk_SalesmanMaster](
	[DistCode] [nvarchar](100) NULL,
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
	[RMCode] [nvarchar](100) NULL,
	[RMName] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate]	[DATETIME]
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='SalesmanMasterTrack' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[SalesmanMasterTrack](
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
	[RMCode] [nvarchar](100) NULL,
	[RMName] [nvarchar](100) NULL,
	[CreateDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='RouteMasterTrack' AND XTYPE='U')
BEGIN
CREATE TABLE [dbo].[RouteMasterTrack](
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
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='RetailerReDownloadTracking' AND xtype='U')
BEGIN
CREATE TABLE RetailerReDownloadTracking(
	[TrackId] [bigint] NULL,
	[RetailerCode] [nvarchar](100) NULL,
	[CmpRtrCode] [nvarchar](100) NULL,
	[RetailerName] [nvarchar](400) NULL,
	[RtrAddress1] [nvarchar](400) NULL,
	[RtrAddress2] [nvarchar](400) NULL,
	[RtrAddress3] [nvarchar](400) NULL,
	[RtrPinNo] [int] NULL,
	[RtrChannelCode] [nvarchar](100) NULL,
	[RtrGroupCode] [nvarchar](100) NULL,
	[RtrClassCode] [nvarchar](100) NULL,
	[KeyAccount] [nvarchar](20) NULL,
	[RelationStatus] [nvarchar](100) NULL,
	[ParentCode] [nvarchar](100) NULL,
	[RtrRegDate] [nvarchar](100) NULL,
	[RtrStatus] [int] NULL,
	[Approved] [varchar](10) NULL,
	[SalesRoute] [nvarchar](50) NULL,
	[DeliveryRoute] [nvarchar](50) NULL,
	[RtrType] [varchar](100) NULL,
	[RtrTINNo] [nvarchar](100) NULL,
	[RtrCrBills] [int] NULL,
	[RtrCrLimit] [numeric](38, 6) NULL,
	[RtrCrDays] [int] NULL,
	[RtrDayOff] [int] NULL,
	[RtrCSTNo] [nvarchar](100) NULL,
	[RtrPhoneNo] [nvarchar](100) NULL,
	[RtrContactPerson] [nvarchar](100) NULL,
	[RtrTaxGroup] [nvarchar](100) NULL,
	[RtrTaxable] [varchar](1) NULL,
	[RtrUniqueCode]	[nvarchar](100) NULL,
	[RtrShippAdd1] [nvarchar](200) NULL,
	[RtrShippAdd2] [nvarchar](200) NULL,
	[RtrShippAdd3] [nvarchar](200) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Import_RouteMaster' AND xtype='P')
DROP PROCEDURE Proc_Import_RouteMaster
GO
CREATE PROCEDURE Proc_Import_RouteMaster
(
	@Pi_Records NTEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_RouteMaster
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_RouteMaster
* CREATED		: S.MOORTHI
* CREATED DATE	: 08/01/2018
* MODIFIED
**************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID       DESCRIPTION                         
**************************************************************************************************
 08/01/2018  S.Moorthi   CR     ICRSTPAR7299        for 1 CR point
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_RouteMaster WHERE DownLoadFlag='Y'
	INSERT INTO Cn2Cs_Prk_RouteMaster(DistCode,RMCode,RMName,Distance,RMPopulation,VanRoute,RouteType,LocalUpCountry,GeoLevel,
	GeoValue,Status,MonDay,TuesDay,WednesDay,ThursDay,FriDay,SaturDay,SunDay,DownLoadFlag,CreatedDate)
	SELECT DistCode,RMCode,RMName,Distance,RMPopulation,VanRoute,RouteType,LocalUpCountry,GeoLevel,
	GeoValue,Status,MonDay,TuesDay,WednesDay,ThursDay,FriDay,SaturDay,SunDay,ISNULL([DownLoadFlag],'D'),GETDATE()
	FROM OPENXML (@hdoc,'/Root/Console2CS_RouteMaster',1)
	WITH 
	(	
			[DistCode]		[nvarchar](100),
			[RMCode]		[nvarchar](100),
			[RMName]		[nvarchar](100),
			[Distance]		[numeric](38, 6),
			[RMPopulation]	[numeric](38, 6),
			[VanRoute]		[nvarchar](100),
			[RouteType]		[nvarchar](100),
			[LocalUpCountry] [nvarchar](100),
			[GeoLevel]		[nvarchar](100),
			[GeoValue]		[nvarchar](100),
			[Status]		[nvarchar](20),
			[MonDay]		[nvarchar](20),
			[TuesDay]		[nvarchar](20),
			[WednesDay]		[nvarchar](20),
			[ThursDay]		[nvarchar](20),
			[FriDay]		[nvarchar](20),
			[SaturDay]		[nvarchar](20),
			[SunDay]		[nvarchar](20),			
			[DownLoadFlag]	[nvarchar](10)
	) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Import_SalesmanMaster' AND xtype='P')
DROP PROCEDURE Proc_Import_SalesmanMaster
GO
CREATE PROCEDURE Proc_Import_SalesmanMaster
(
	@Pi_Records NTEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_SalesmanMaster
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_SalesmanMaster
* CREATED		: S.MOORTHI
* CREATED DATE	: 08/01/2018
* MODIFIED
**************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID       DESCRIPTION                         
**************************************************************************************************
 08/01/2018  S.Moorthi   CR     ICRSTPAR7299        for 1 CR point
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_SalesmanMaster WHERE DownLoadFlag='Y'
	INSERT INTO Cn2Cs_Prk_SalesmanMaster(DistCode,SMCode,SMName,SMPhoneNo,SMEmail,SMOtherDetails,SMDailyAllowance,
	SMMonthlySalary,SMMktCredit,SMCreditDays,Status,RMCode,RMName,DownLoadFlag)
	SELECT DistCode,SMCode,SMName,ISNULL(SMPhoneNo,'') AS SMPhoneNo,ISNULL(SMEmail,'') AS SMEmail,ISNULL(SMOtherDetails,'') AS SMOtherDetails,
	SMDailyAllowance,SMMonthlySalary,SMMktCredit,SMCreditDays,Status,RMCode,RMName,ISNULL([DownLoadFlag],'D')
	FROM OPENXML (@hdoc,'/Root/Console2CS_SalesmanMaster',1)
	WITH 
	(	
			[DistCode] [nvarchar](100),
			[SMCode] [nvarchar](100),
			[SMName] [nvarchar](100),
			[SMPhoneNo] [nvarchar](100),
			[SMEmail] [nvarchar](100),
			[SMOtherDetails] [nvarchar](500),
			[SMDailyAllowance] [numeric](38, 6),
			[SMMonthlySalary] [numeric](38, 6),
			[SMMktCredit] [numeric](38, 6),
			[SMCreditDays] [int],
			[Status] [nvarchar](20),
			[RMCode] [nvarchar](100),
			[RMName] [nvarchar](100),						
			[DownLoadFlag] [nvarchar](10)
	) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Import_RetailerReDownload' AND xtype='P')
DROP PROCEDURE Proc_Import_RetailerReDownload
GO
CREATE PROCEDURE [Proc_Import_RetailerReDownload]
(
	@Pi_Records NTEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_RouteMaster
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_RetailerReDownload
* CREATED		: S.MOORTHI
* CREATED DATE	: 08/01/2018
* MODIFIED
**************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID       DESCRIPTION                         
**************************************************************************************************
 08/01/2018  S.Moorthi   CR     ICRSTPAR7299        for 1 CR point
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_RetailerReDownload WHERE DownLoadFlag='Y'
	INSERT INTO Cn2Cs_Prk_RetailerReDownload(DistCode,RetailerCode,CmpRtrCode,RetailerName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPinNo,
	RtrChannelCode,RtrGroupCode,RtrClassCode,KeyAccount,RelationStatus,ParentCode,RtrRegDate,RtrStatus,Approved,SalesRoute,DeliveryRoute,RtrType,
	RtrTINNo,RtrCrBills,RtrCrLimit,RtrCrDays,RtrDayOff,RtrCSTNo,RtrPhoneNo,RtrContactPerson,RtrTaxGroup,RtrTaxable,RtrUniqueCode,RtrShippAdd1,RtrShippAdd2,
	RtrShippAdd3,DownloadFlag,CreatedDate)
	SELECT DistCode,RetailerCode,CmpRtrCode,RetailerName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPinNo,
	RtrChannelCode,RtrGroupCode,RtrClassCode,KeyAccount,RelationStatus,ParentCode,RtrRegDate,RtrStatus,Approved,SalesRoute,DeliveryRoute,RtrType,
	RtrTINNo,RtrCrBills,RtrCrLimit,RtrCrDays,RtrDayOff,RtrCSTNo,RtrPhoneNo,RtrContactPerson,RtrTaxGroup,RtrTaxable,RtrUniqueCode,RtrShippAdd1,RtrShippAdd2,
	RtrShippAdd3,ISNULL([DownLoadFlag],'D'),GETDATE()
	FROM OPENXML (@hdoc,'/Root/Console2CS_RetailerReDownload',1)
	WITH 
	(	
		[DistCode] [nvarchar](100),
		[RetailerCode] [nvarchar](100),
		[CmpRtrCode] [nvarchar](100),
		[RetailerName] [nvarchar](400),
		[RtrAddress1] [nvarchar](400),
		[RtrAddress2] [nvarchar](400),
		[RtrAddress3] [nvarchar](400),
		[RtrPinNo] [int] ,
		[RtrChannelCode] [nvarchar](100),
		[RtrGroupCode] [nvarchar](100),
		[RtrClassCode] [nvarchar](100),
		[KeyAccount] [nvarchar](20),
		[RelationStatus] [nvarchar](100),
		[ParentCode] [nvarchar](100),
		[RtrRegDate] [nvarchar](100),
		[RtrStatus] [int],
		[Approved] [varchar](10),
		[SalesRoute] [nvarchar](50),
		[DeliveryRoute] [nvarchar](50),
		[RtrType] [varchar](100),
		[RtrTINNo] [nvarchar](100),
		[RtrCrBills] [int] ,
		[RtrCrLimit] [numeric](38, 6),
		[RtrCrDays] [int] ,
		[RtrDayOff] [int] ,
		[RtrCSTNo] [nvarchar](100),
		[RtrPhoneNo] [nvarchar](100),
		[RtrContactPerson] [nvarchar](100),
		[RtrTaxGroup] [nvarchar](100),
		[RtrTaxable] [varchar](1),
		[RtrUniqueCode]	[nvarchar](100),
		[RtrShippAdd1] [nvarchar](200),
		[RtrShippAdd2] [nvarchar](200),
		[RtrShippAdd3] [nvarchar](200),
		[DownloadFlag] [varchar](1)
	) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_CN2CS_RouteMaster' AND xtype='P')
DROP PROCEDURE Proc_CN2CS_RouteMaster
GO
/*
BEGIN TRANSACTION
DELETE FROM ErrorLog
DELETE FROM ROUTEMASTER WHERE RMCODE IN ('RM1','RM002','RM003')
UPDATE Cn2Cs_Prk_RouteMaster SET RMCODE='127262-DR77' WHERE RMCODE='127262-SR77'
UPDATE Cn2Cs_Prk_RouteMaster SET GEOLEVEL='Territory' WHERE RMCODE='RM1'
SELECT * FROM RouteMaster WHERE RMCODE IN ('RM1','RM002','RM003')
SELECT * FROM Cn2Cs_Prk_RouteMaster
EXEC Proc_CN2CS_RouteMaster 0
SELECT * FROM Counters WHERE TabName='RouteMaster'
SELECT * FROM RouteMaster WHERE RMCODE IN ('RM1','RM002','RM003')
SELECT * FROM Cn2Cs_Prk_RouteMaster (NOLOCK)
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CN2CS_RouteMaster
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_CN2CS_SalesManMaster
* PURPOSE		: To Download the Route Details from Console to Core Stocky
* CREATED		: S.MOORTHI
* CREATED DATE	: 08/01/2018
* MODIFIED
**************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID       DESCRIPTION                         
**************************************************************************************************
 08/01/2018  S.Moorthi   CR     ICRSTPAR7299        for 1 CR point
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @DistCode			[nvarchar](100)
	DECLARE @Exists				INT
	DECLARE @RmId				INT
	DECLARE @CmpId AS	 INT
	
	SET @ErrStatus=1
	SET @Po_ErrNo=0
	SET @CmpId=0
	SET @Tabname = 'Cn2Cs_Prk_RouteMaster'
	
	DELETE FROM Errorlog WHERE TableName = 'Cn2Cs_Prk_RouteMaster'
	
	SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
		
	CREATE TABLE #ToAvoidRoute
	( 
	  RouteCode		 NVARCHAR(200),
	  GeoLevel       NVARCHAR(200),
	  GeoCode        NVARCHAR(200)
	)
	
	SELECT PR.RMCode INTO #ParkingDuplicateRetailers FROM Cn2Cs_Prk_RouteMaster PR (NOLOCK)
	WHERE DownloadFlag = 'D' GROUP BY PR.RMCode
	HAVING COUNT(7)>1
	
	INSERT INTO #ToAvoidRoute(RouteCode)
	SELECT DISTINCT RMCODE FROM #ParkingDuplicateRetailers
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Cn2Cs_Prk_RouteMaster','RouteName','Duplicate Route Code Available-'+RMCode  
	FROM #ParkingDuplicateRetailers WITH(NOLOCK) 
	
	INSERT INTO #ToAvoidRoute(RouteCode)
	SELECT DISTINCT RMCode FROM Cn2Cs_Prk_RouteMaster WITH(NOLOCK)
	WHERE ISNULL(RMCODE,'')='' OR ISNULL(RMNAME,'')='' AND DownloadFlag = 'D'
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Cn2Cs_Prk_RouteMaster','RouteName','Route Code/Name can not be Empty-'+RMCode+'+'+RMName  
	FROM Cn2Cs_Prk_RouteMaster WITH(NOLOCK) 
	WHERE ISNULL(RMCODE,'')='' OR ISNULL(RMNAME,'')='' AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRoute(RouteCode)
	SELECT DISTINCT A.RMCode FROM Cn2Cs_Prk_RouteMaster A (NOLOCK) 
	INNER JOIN ROUTEMASTER B (NOLOCK) ON A.RMCODE=B.RMCODE
	WHERE DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Cn2Cs_Prk_RouteMaster','RouteCode','Route Code Already Available-'+A.RMCode
	FROM Cn2Cs_Prk_RouteMaster A (NOLOCK) 
	INNER JOIN ROUTEMASTER B (NOLOCK) ON A.RMCODE=B.RMCODE
	WHERE DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRoute(RouteCode,GeoLevel)
	SELECT DISTINCT RMCode,GeoLevel FROM Cn2Cs_Prk_RouteMaster WITH(NOLOCK) WHERE GeoLevel NOT IN 
	(SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Cn2Cs_Prk_RouteMaster','GeoLevelName','Route Geography Level Not Available-'+GeoLevel 
	FROM Cn2Cs_Prk_RouteMaster WITH(NOLOCK) 
	WHERE GeoLevel NOT IN (SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRoute(RouteCode,GeoCode)
	SELECT DISTINCT RMCode,GeoValue FROM Cn2Cs_Prk_RouteMaster WITH(NOLOCK) WHERE GeoValue NOT IN 
	(SELECT GeoCode FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Cn2Cs_Prk_RouteMaster','GeoCode','Route Geography Not Available-'+RMCode+'-'+GeoValue FROM Cn2Cs_Prk_RouteMaster WITH(NOLOCK) 
	WHERE GeoValue NOT IN (SELECT GeoCode FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRoute(RouteCode,GeoCode)
	SELECT DISTINCT RMCODE,GeoValue FROM Cn2Cs_Prk_RouteMaster A (NOLOCK) WHERE NOT EXISTS 
	(SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId
	WHERE A.GeoLevel = B.GeoLevelName AND A.GeoValue = C.GeoCode)AND DownloadFlag = 'D'
	 
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Cn2Cs_Prk_RouteMaster','GeoCode','Route Geography Wrongly Mapped-'+RMCode+'-'+GeoLevel+'-'+GeoValue 
	FROM Cn2Cs_Prk_RouteMaster A (NOLOCK) WHERE NOT EXISTS 
		(SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) 
		INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId 
		WHERE A.GeoLevel = B.GeoLevelName AND A.GeoValue = C.GeoCode)AND DownloadFlag = 'D'
	
	--To Insert the Sales Route Details 
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	SET @RmId=ISNULL(@RmId,0)
	
	INSERT INTO RouteMasterTrack(RMCode,RMName,Distance,RMPopulation,VanRoute,RouteType,LocalUpCountry,GeoLevel,GeoValue,Status,
						MonDay,TuesDay,WednesDay,ThursDay,FriDay,SaturDay,SunDay,CreatedDate)
	SELECT RMCode,RMName,Distance,RMPopulation,VanRoute,RouteType,LocalUpCountry,GeoLevel,GeoValue,Status,
	MonDay,TuesDay,WednesDay,ThursDay,FriDay,SaturDay,SunDay,GETDATE() FROM Cn2Cs_Prk_RouteMaster A (NOLOCK) 
	INNER JOIN Geography B (NOLOCK) ON B.GeoCode = A.GeoValue 
	INNER JOIN GeographyLevel C (NOLOCK) ON B.GeoLevelId=C.GeoLevelId 
	WHERE NOT EXISTS(SELECT RouteCode,GeoLevel,GeoCode FROM #ToAvoidRoute D WHERE D.RouteCode=A.RMCODE) AND DownloadFlag='D'
	AND ISNULL(A.RMCODE,'')<>'' AND ISNULL(A.RMName,'')<>'' AND DownloadFlag = 'D'
	
	INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GeoMainId,RMVanRoute,
	RMSRouteType,RMLocalUpcountry,RMMon,RMTue,RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,UpLoad,
	Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT @RmId + ROW_NUMBER() OVER (ORDER BY RMCODE,RMName) AS RmId,RMCODE,RMNAME,@CmpId,ISNULL(Distance,0),ISNULL(RMPopulation,0),GeoMainId,
	ISNULL(VanRoute,0),RouteType,ISNULL(LocalUpCountry,1),(CASE UPPER(ISNULL(MonDay,'YES')) WHEN 'YES' THEN 1 ELSE 0 END) AS Monday,
	(CASE UPPER(ISNULL(TuesDay,'YES')) WHEN 'YES' THEN 1 ELSE 0 END) AS TuesDay,
	(CASE UPPER(ISNULL(WednesDay,'YES')) WHEN 'YES' THEN 1 ELSE 0 END) AS WednesDay,
	(CASE UPPER(ISNULL(ThursDay,'YES')) WHEN 'YES' THEN 1 ELSE 0 END) AS ThursDay,
	(CASE UPPER(ISNULL(FriDay,'YES')) WHEN 'YES' THEN 1 ELSE 0 END) AS FriDay,
	(CASE UPPER(ISNULL(SaturDay,'YES')) WHEN 'YES' THEN 1 ELSE 0 END) AS SaturDay,
	(CASE UPPER(ISNULL(SunDay,'YES')) WHEN 'YES' THEN 1 ELSE 0 END) AS SunDay,
	(CASE UPPER(ISNULL(Status,'ACTIVE')) WHEN 'ACTIVE' THEN 1 ELSE 0 END) AS RMStatus,
	'N',1,1,GETDATE(),1,GETDATE(),0
	FROM Cn2Cs_Prk_RouteMaster A (NOLOCK) 
	INNER JOIN Geography B (NOLOCK) ON B.GeoCode = A.GeoValue 
	INNER JOIN GeographyLevel C (NOLOCK) ON B.GeoLevelId=C.GeoLevelId 
	WHERE NOT EXISTS(SELECT RouteCode,GeoLevel,GeoCode FROM #ToAvoidRoute D WHERE D.RouteCode=A.RMCODE) AND DownloadFlag='D'
	AND ISNULL(A.RMCODE,'')<>'' AND ISNULL(A.RMName,'')<>'' AND DownloadFlag = 'D'
	
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	UPDATE Counters SET CurrValue = @RmId WHERE TabName = 'RouteMaster' AND FldName = 'RMId'
	
	UPDATE A SET A.DownloadFlag='Y' FROM Cn2Cs_Prk_RouteMaster A (NOLOCK) 
	INNER JOIN Geography B (NOLOCK) ON B.GeoCode = A.GeoValue 
	INNER JOIN GeographyLevel C (NOLOCK) ON B.GeoLevelId=C.GeoLevelId 
	WHERE NOT EXISTS(SELECT RouteCode,GeoLevel,GeoCode FROM #ToAvoidRoute D WHERE D.RouteCode=A.RMCODE) AND DownloadFlag='D'
	AND ISNULL(A.RMCODE,'')<>'' AND ISNULL(A.RMName,'')<>'' AND DownloadFlag = 'D'
	
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='SalesManToAvoid' AND xtype='U')
DROP TABLE SalesManToAvoid	
GO
CREATE TABLE SalesManToAvoid
(		
	SMCode		NVARCHAR(200),
	RMCODE		VARCHAR(100)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_CN2CS_SalesManMaster' AND xtype='P')
DROP PROCEDURE Proc_CN2CS_SalesManMaster
GO
/*
BEGIN TRANSACTION
DELETE FROM ERRORLOG
update Cn2Cs_Prk_SalesManMaster set rmcode='R30' WHERE SMCODE='T-PSR01' AND RMCODE='sm01'
SELECT * FROM Counters WHERE TabName='SalesMan'
EXEC Proc_CN2CS_SalesManMaster 0
SELECT * FROM Counters WHERE TabName='SalesMan'
SELECT * FROM SALESMAN 
SELECT * FROM SALESMANMARKET ORDER BY SMID DESC
SELECT * FROM Cn2Cs_Prk_SalesManMaster
SELECT * FROM ERRORLOG
ROLLBACK TRANSACTION
*/
CREATE  PROCEDURE Proc_CN2CS_SalesManMaster
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_CN2CS_SalesManMaster
* PURPOSE		: To Download the SalesMan details from Console to Core Stocky
* CREATED		: S.MOORTHI
* CREATED DATE	: 08/01/2018
* MODIFIED
**************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID       DESCRIPTION                         
**************************************************************************************************
 08/01/2018  S.Moorthi   CR     ICRSTPAR7299        for 1 CR point
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @Exists				INT
	DECLARE @SMId				INT
	
	SET @ErrStatus=1
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_SalesManMaster'
	
	DECLARE @DistCode		[nvarchar](100)
	DECLARE @SMCode			[nvarchar](100)
	DECLARE @SMName			[nvarchar](100)
	DECLARE @SMPhoneNo		[nvarchar](100)
	DECLARE @SMEmail		[nvarchar](100)
	DECLARE @SMOtherDetails [nvarchar](500)
	DECLARE @SMDailyAllowance [numeric](38, 6)
	DECLARE @SMMonthlySalary [numeric](38, 6)
	DECLARE @SMMktCredit	[numeric](38, 6)
	DECLARE @SMCreditDays	[int]
	DECLARE @Status			INT
	DECLARE @RMCode			[nvarchar](100)
	DECLARE @RMName			[nvarchar](100)	
	
	DELETE FROM Errorlog WHERE TableName = 'Cn2Cs_Prk_SalesManMaster'
	
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SalesManToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SalesManToAvoid	
	END
	CREATE TABLE SalesManToAvoid
	(		
		SMCode		NVARCHAR(200),
		RMCODE		VARCHAR(100)
	)
	
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SalesManMaster WHERE ISNULL(SMCode,'')='' OR ISNULL(SMName,'')='')
	BEGIN
		INSERT INTO SalesManToAvoid(SMCode,RMCODE)
		SELECT SMCODE,RMCODE FROM Cn2Cs_Prk_SalesManMaster WHERE ISNULL(SMCode,'')='' OR  ISNULL(SMName,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_SalesManMaster','SM Code','Salesman code should not be empty'
		FROM Cn2Cs_Prk_SalesManMaster WHERE ISNULL(SMCode,'')='' OR  ISNULL(SMName,'')=''
	END
	
	INSERT INTO SalesManToAvoid(SMCode,RMCODE)
	SELECT SMCODE,RMCode FROM Cn2Cs_Prk_SalesManMaster A (NOLOCK) WHERE NOT EXISTS(
	SELECT RMCode FROM RouteMaster B (NOLOCK) WHERE  A.RMCode=B.RMCODE)
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT 1,'Cn2Cs_Prk_SalesManMaster','RM Code','Route Code' + RMCode + 'Not Available' 
	FROM Cn2Cs_Prk_SalesManMaster A (NOLOCK) WHERE NOT EXISTS(
	SELECT RMCode FROM RouteMaster B (NOLOCK) WHERE A.RMCode=B.RMCODE)
	
	--INSERT INTO SalesManToAvoid(SMCode,RMCODE)
	--SELECT SMCODE,RMCode FROM Cn2Cs_Prk_SalesManMaster A (NOLOCK) WHERE EXISTS(
	--SELECT SMCode FROM SalesMan B (NOLOCK) WHERE A.SMCode=B.SMCode)
	
	--INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	--SELECT DISTINCT 1,'Cn2Cs_Prk_SalesManMaster','SalesMan Code','SalesMan Code ' + SMCode + ' Already Available' 
	--FROM Cn2Cs_Prk_SalesManMaster A (NOLOCK) WHERE EXISTS(
	--SELECT SMCode FROM SalesMan B (NOLOCK) WHERE A.SMCode=B.SMCode)
	
	INSERT INTO SalesManToAvoid(SMCode,RMCODE)
	SELECT A.SMCODE,A.RMCODE FROM Cn2Cs_Prk_SalesManMaster A(NOLOCK) 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMCODE=B.SMCode 
	INNER JOIN RouteMaster C (NOLOCK) ON C.RMCode=A.RMCODE
	INNER JOIN SalesmanMarket D (NOLOCK) ON D.SMId=B.SMId AND D.RMId=C.RMId 
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT 1,'Cn2Cs_Prk_SalesManMaster','RM Code','SalesMan and SalesManMarket ' + A.SMCode + '+'+ A.RMCode +' Details Already Available' 
	FROM Cn2Cs_Prk_SalesManMaster A(NOLOCK) 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMCODE=B.SMCode 
	INNER JOIN RouteMaster C (NOLOCK) ON C.RMCode=A.RMCODE
	INNER JOIN SalesmanMarket D (NOLOCK) ON D.SMId=B.SMId AND D.RMId=C.RMId 
	
	SELECT @SMId = ISNULL(MAX(SMId),0) FROM SalesMan (NOLOCK)
	SET @SMId=ISNULL(@SMId,0)
	
	INSERT INTO SalesmanMasterTrack(SMCode,SMName,SMPhoneNo,SMEmail,SMOtherDetails,SMDailyAllowance,SMMonthlySalary,
								SMMktCredit,SMCreditDays,Status,RMCode,RMName,CreateDate)
	SELECT SMCode,SMName,SMPhoneNo,SMEmail,SMOtherDetails,SMDailyAllowance,SMMonthlySalary,
	SMMktCredit,SMCreditDays,Status,RMCode,RMName,GETDATE() FROM Cn2Cs_Prk_SalesManMaster A (NOLOCK)
	WHERE DownloadFlag='D' AND ISNULL(SMCODE,'')<>'' AND  NOT EXISTS (SELECT SMCODE,RMCODE FROM SalesManToAvoid B (NOLOCK) WHERE A.SMCODE=B.SMCODE AND A.RMCODE=B.RMCODE) AND 
	NOT EXISTS(SELECT SMCODE FROM Salesman D(NOLOCK) WHERE D.SMCode=A.SMCODE)
	
	INSERT INTO SalesMan(SMId,SMCode,SMName,SMPhoneNumber,SMEmailID,SMOtherDetails,SMDailyAllowance,SMMonthlySalary,SMMktCredit,
					SMCreditDays,CmpId,SalesForceMainId,Status,SMCreditAmountAlert,SMCreditDaysAlert,UpLoad,
					Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY SMCODE,SMName)+@SMId) AS SMId,SMCode,SMName,ISNULL(SMPhoneNo,''),ISNULL(SMEmail,''),ISNULL(SMOtherDetails,''),ISNULL(SMDailyAllowance,0),
	ISNULL(SMMonthlySalary,0),isnull(SMMktCredit,0),ISNULL(SMCreditDays,0),0 AS CmpId,0 AS SalesForceMainId,(CASE UPPER(ISNULL(Status,'ACTIVE')) WHEN 'ACTIVE' THEN 1 ELSE 0 END),
	0,0,'N',1,1,GETDATE(),1,GETDATE(),0
	FROM Cn2Cs_Prk_SalesManMaster A (NOLOCK) WHERE DownloadFlag='D' AND ISNULL(SMCODE,'')<>'' AND  
	NOT EXISTS (SELECT SMCODE,RMCODE FROM SalesManToAvoid B (NOLOCK) WHERE A.SMCODE=B.SMCODE AND A.RMCODE=B.RMCODE) AND 
	NOT EXISTS(SELECT SMCODE FROM Salesman D(NOLOCK) WHERE D.SMCode=A.SMCODE)
		
	SELECT @SMId = ISNULL(MAX(SMId),0) FROM SalesMan (NOLOCK)
	UPDATE Counters SET CurrValue = @SMId WHERE TabName = 'SalesMan' AND FldName = 'SMId'
		
	INSERT INTO SalesmanMarket(SMId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT DISTINCT B.SMId,C.RMId,1,1,GETDATE(),1,GETDATE() FROM Cn2Cs_Prk_SalesManMaster A(NOLOCK) 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMCODE=B.SMCode 
	INNER JOIN RouteMaster C (NOLOCK) ON C.RMCode=A.RMCODE
	WHERE NOT EXISTS (SELECT SMCODE,RMCODE FROM SalesManToAvoid D (NOLOCK) 
	WHERE A.SMCODE=D.SMCODE AND A.RMCODE=D.RMCODE)AND DownloadFlag='D'
	
	UPDATE A SET A.DownloadFlag='Y' FROM Cn2Cs_Prk_SalesManMaster A(NOLOCK) 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMCODE=B.SMCode 
	INNER JOIN RouteMaster C (NOLOCK) ON C.RMCode=A.RMCODE
	WHERE NOT EXISTS (SELECT SMCODE,RMCODE FROM SalesManToAvoid D (NOLOCK) 
	WHERE A.SMCODE=D.SMCODE AND A.RMCODE=D.RMCODE) AND DownloadFlag='D' 
	
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_RetailerReDownload' AND xtype='P')
DROP PROCEDURE Proc_Cn2Cs_RetailerReDownload
GO
--BEGIN TRAN
--DELETE FROM ERRORLOG
--UPDATE Cn2Cs_Prk_SalesManMaster SET RMCODE='SR02'
--UPDATE RouteMaster SET RMCODE='S'+RMCODE
--EXEC Proc_CN2CS_RouteMaster 0
--EXEC Proc_CN2CS_SalesManMaster 0
--EXEC Proc_Cn2Cs_RetailerReDownload 0

--SELECT * FROM RouteMaster 
--SELECT * FROM Salesman 
--SELECT * FROM Retailer WHERE rtrid>907
--select * from RetailerMarket where rtrid>907
--select * from RetailerValueClassMap where rtrid>907
--select * from RetailerShipAdd where rtrid>907
--SELECT * FROM ERRORLOG
--ROLLBACK TRAN
CREATE PROCEDURE [Proc_Cn2Cs_RetailerReDownload]
(
	@Po_ErrNo	INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_RetailerMigration
* PURPOSE		: To validate and update records from parking table to main table
* CREATED		: S.MOORTHI
* CREATED DATE	: 08/01/2018
* MODIFIED
**************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID       DESCRIPTION                         
**************************************************************************************************
 08/01/2018  S.Moorthi   CR     ICRSTPAR7299        for 1 CR point
*********************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @MasterId INT
	DECLARE @UDCMasterId INT
	DECLARE @RtrId INT
	DECLARE @RtrShipAddId INT
	DECLARE @UdcCurrMasterId INT
	DECLARE @UdcCurrUniqueID INT	
	DECLARE @CoaID INT
	DECLARE @AccCode VARCHAR(200)
	
	BEGIN TRY
		
		
		SET @Po_ErrNo = 0
		SELECT @RtrId = CurrValue From Counters WHERE TabName = 'Retailer' AND FldName = 'RtrId'
		SELECT @RtrShipAddId = CurrValue From Counters WHERE TabName = 'RetailerShipAdd'
		SELECT @UdcCurrMasterId = CurrValue From Counters WHERE TabName = 'UDCDetails' AND FldName = 'UdcDetailsId'
		SELECT @UdcCurrUniqueID = CurrValue From Counters WHERE TabName = 'UDCDetails' AND FldName = 'UDCUniqueId'		
		SELECT @CoaID = CurrValue From Counters WHERE TabName = 'CoaMaster'
		SELECT @AccCode = MAX(AcCode) From COAMaster A Where A.MainGroup=2 and A.AcCode LIKE '216%'
		DELETE FROM Cn2Cs_Prk_RetailerReDownload WHERE DownloadFlag = 'Y'
		
		CREATE TABLE #TempMigrateRetailer
			(
				[RetailerCode] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[CmpRtrCode] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RetailerName] [nvarchar](200) COLLATE DATABASE_DEFAULT,
				[RtrAddress1] [nvarchar](200) COLLATE DATABASE_DEFAULT,
				[RtrAddress2] [nvarchar](200) COLLATE DATABASE_DEFAULT,
				[RtrAddress3] [nvarchar](200) COLLATE DATABASE_DEFAULT,
				[RtrPinNo] [int] NULL,
				[RtrChannelCode] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrGroupCode] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrClassCode] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[KeyAccount] [nvarchar](20) COLLATE DATABASE_DEFAULT,
				[RelationStatus] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[ParentCode] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrRegDate] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrStatus] [int]NULL,
				[Approved] [varchar](10) NULL,
				[SalesRoute] [nvarchar](50) COLLATE DATABASE_DEFAULT,
				[DeliveryRoute] [nvarchar](50) COLLATE DATABASE_DEFAULT,
				[RtrType] [varchar](100) NULL,
				[RtrTINNo] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrCrBills] [int] NULL,
				[RtrCrLimit] [numeric](38, 6) NULL,
				[RtrCrDays] [int] NULL,
				[RtrDayOff] [int] NULL,
				[RtrCSTNo] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrPhoneNo] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrContactPerson] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrTaxGroup] [nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrTaxable] [varchar](1) NULL,
				[RtrUniqueCode]	[nvarchar](100) COLLATE DATABASE_DEFAULT,
				[RtrShippAdd1] [nvarchar](200) COLLATE DATABASE_DEFAULT,
				[RtrShippAdd2] [nvarchar](200) COLLATE DATABASE_DEFAULT,
				[RtrShippAdd3] [nvarchar](200) COLLATE DATABASE_DEFAULT,
				[DownloadFlag] [varchar](1) NULL
			)
	
			DELETE FROM Errorlog WHERE TableName = 'Cn2Cs_Prk_RetailerReDownload'
			
			--Find Duplicate Retailers From Download
			SELECT PR.RetailerCode INTO #ParkingDuplicateRetailers FROM Cn2Cs_Prk_RetailerReDownload PR (NOLOCK)
			WHERE DownloadFlag = 'D' GROUP BY PR.RetailerCode
			HAVING COUNT(7)>1
			
			SELECT Row_Number() OVER(Order By RetailerCode,CmpRtrCode) RowNo,RetailerCode,CmpRtrCode 
			INTO #DuplicateRetailers
			FROM 
			(
				SELECT PR.RetailerCode,PR.CmpRtrCode FROM Cn2Cs_Prk_RetailerReDownload PR (NOLOCK) 
				INNER JOIN #ParkingDuplicateRetailers D ON PR.RetailerCode = D.RetailerCode
				WHERE DownloadFlag = 'D'		
				UNION				
				SELECT PR.RetailerCode,PR.CmpRtrCode FROM Cn2Cs_Prk_RetailerReDownload PR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON PR.RetailerCode = R.RtrCode
				WHERE DownloadFlag = 'D'
			) A
			
			--Find Duplicate Retailers From Download			
			SELECT Row_Number() OVER(Order By RetailerCode,RtrUniqueCode) RowNo,RetailerCode,RtrUniqueCode 
			INTO #DuplicateRetailers1
			FROM 
			(
				SELECT PR.RetailerCode,PR.RtrUniqueCode FROM Cn2Cs_Prk_RetailerReDownload PR (NOLOCK) 
				INNER JOIN #ParkingDuplicateRetailers D ON PR.RetailerCode = D.RetailerCode
				WHERE DownloadFlag = 'D'		
				UNION				
				SELECT PR.RetailerCode,PR.RtrUniqueCode FROM Cn2Cs_Prk_RetailerReDownload PR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON PR.RetailerCode = R.RtrCode
				WHERE DownloadFlag = 'D'
			) A
						
			--Delete Duplicate Retailers in Temp Table WHILE RtrStatus=1
			--DELETE D FROM #DuplicateRetailers D  (NOLOCK) 
			--INNER JOIN Retailer R (NOLOCK) ON D.RetailerCode = R.RtrCode AND D.CmpRtrCode = R.CmpRtrCode
			--WHERE R.RtrStatus = 1  --Approved=1
			
			--IF EXISTS (SELECT 7 FROM #DuplicateRetailers)
			--BEGIN
			
			--	SELECT RtrCode INTO #ExistingRtrCode FROM
			--	(
			--		SELECT RetailerCode AS RtrCode FROM Cn2Cs_Prk_RetailerReDownload PR (NOLOCK) WHERE DownloadFlag = 'D'
			--		UNION
			--		SELECT RtrCode  FROM Retailer R (NOLOCK)
			--	)X
			--	DECLARE @CntOfDuplicate AS INTEGER
			--	DECLARE @CurrentNo AS NVARCHAR(3)
			--	DECLARE @Counter AS NVARCHAR(6)
			--	DECLARE @RtrFlag AS TINYINT
			--	DECLARE @RetailerCode AS NVARCHAR(200)
			--	DECLARE @FreshRtrCode AS NVARCHAR(200)
			--	SET @CntOfDuplicate = 0
			--	SET @CurrentNo = 1
				
			--	--Duplicate Retailer Count
			--	SELECT @CntOfDuplicate = COUNT(7) FROM #DuplicateRetailers (NOLOCK)
			--	WHILE (@CntOfDuplicate >= @CurrentNo)
			--	BEGIN
			--		SET @RtrFlag = 0
			--		SET @Counter = 1
					
			--		SELECT @RetailerCode = RetailerCode FROM #DuplicateRetailers (NOLOCK) WHERE RowNo = @CurrentNo
					
			--		WHILE (@RtrFlag = 0)
			--		BEGIN
										
			--			SET @FreshRtrCode = 'M'+@Counter+@RetailerCode
						
			--			IF NOT EXISTS(SELECT 7 FROM #ExistingRtrCode E (NOLOCK) WHERE RtrCode = @FreshRtrCode)
			--			BEGIN
						
			--				UPDATE D SET RetailerCode = @FreshRtrCode FROM #DuplicateRetailers D (NOLOCK) WHERE RowNo = @CurrentNo
							
			--				INSERT INTO #ExistingRtrCode
			--				SELECT @FreshRtrCode
							
			--				SET @RtrFlag = 1			
			--			END
			--			ELSE
			--			BEGIN
			--				SET @Counter = @Counter + 1
			--			END						
			--		 END
					 					 
			--		 SET @CurrentNo = @CurrentNo + 1	
			--	 END
			
			--	UPDATE P SET P.RetailerCode = D.RetailerCode
			--	FROM #DuplicateRetailers D (NOLOCK) INNER JOIN Cn2Cs_Prk_RetailerReDownload P (NOLOCK) 
			--	ON P.CmpRtrCode = D.CmpRtrCode WHERE DownloadFlag = 'D'	
			--END
			--Till Here
			
			INSERT INTO #TempMigrateRetailer (RetailerCode,CmpRtrCode,RetailerName,RtrAddress1,RtrAddress2,
			RtrAddress3,RtrPinNo,RtrChannelCode,RtrGroupCode,RtrClassCode,KeyAccount,RelationStatus,ParentCode,RtrRegDate,RtrStatus,
			Approved,SalesRoute,DeliveryRoute,RtrType,RtrTINNo,RtrCrBills,RtrCrLimit,RtrCrDays,RtrDayOff,RtrCSTNo,RtrPhoneNo,
			RtrContactPerson,RtrTaxGroup,RtrTaxable,RtrUniqueCode,RtrShippAdd1,RtrShippAdd2,RtrShippAdd3)
			SELECT DISTINCT RetailerCode,CmpRtrCode,RetailerName,RtrAddress1,RtrAddress2,
			RtrAddress3,RtrPinNo,RtrChannelCode,RtrGroupCode,RtrClassCode,KeyAccount,RelationStatus,ParentCode,RtrRegDate,RtrStatus,
			Approved,SalesRoute,DeliveryRoute,RtrType,RtrTINNo,RtrCrBills,RtrCrLimit,RtrCrDays,RtrDayOff,RtrCSTNo,RtrPhoneNo,
			RtrContactPerson,RtrTaxGroup,RtrTaxable,RtrUniqueCode,RtrShippAdd1,RtrShippAdd2,RtrShippAdd3
			FROM Cn2Cs_Prk_RetailerReDownload A WITH (NOLOCK)  WHERE DownLoadFlag = 'D'
			AND NOT EXISTS(SELECT RetailerCode,CmpRtrCode FROM #DuplicateRetailers B WHERE A.RetailerCode=B.RetailerCode and A.CmpRtrCode=B.CmpRtrCode)	
			AND NOT EXISTS(SELECT RetailerCode,RtrUniqueCode FROM #DuplicateRetailers1 C WHERE A.RetailerCode=C.RetailerCode and A.RtrUniqueCode=C.RtrUniqueCode)	
	
			--Check Cmp Retailer Code --> Join Check RtrCode?
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 2,'RetailerMigration','CmpRtrCode','Retailer '+B.CmpRtrCode+' Already Exists' FROM Retailer A (NOLOCK)  
			INNER JOIN #TempMigrateRetailer B (NOLOCK) ON A.CmpRtrCode = B.CmpRtrCode AND A.RtrCode = B.RetailerCode 			
			
			DELETE B FROM Retailer A
			INNER JOIN #TempMigrateRetailer B ON A.CmpRtrCode = B.CmpRtrCode AND A.RtrCode = B.RetailerCode	
			
			--Retailer Code Length
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 2,'Retailer','RetailerCode','Retailer Code '+RetailerCode+' Maximum Length should be 25' 
			FROM #TempMigrateRetailer (NOLOCK) WHERE LEN(LTRIM(RTRIM(RetailerCode)))>25
			
			DELETE FROM #TempMigrateRetailer WHERE LEN(LTRIM(RTRIM(RetailerCode)))>25
			
			--Retailer Code Blank
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 2,'Retailer','RetailerCode','Company Retailer Code for '+RetailerCode+' is mandatory for Restored retailers' 
			FROM #TempMigrateRetailer (NOLOCK) WHERE LEN(LTRIM(RTRIM(RetailerCode)))<=0
			
			DELETE FROM #TempMigrateRetailer WHERE LEN(LTRIM(RTRIM(RetailerCode)))<=0
			
			--Company Retailer Code Blank
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 2,'Retailer','Company RetailerCode','Company Retailer Code for '+CmpRtrCode+' is mandatory for Restored retailers' 
			FROM #TempMigrateRetailer (NOLOCK) WHERE LEN(LTRIM(RTRIM(CmpRtrCode)))<=0
			
			DELETE FROM #TempMigrateRetailer WHERE LEN(LTRIM(RTRIM(CmpRtrCode)))<=0
			
			
			--RtrUniqueCode Blank
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 2,'Retailer','Company RetailerCode','Retailer Unique Code for '+RtrUniqueCode+' is mandatory for Restored retailers' 
			FROM #TempMigrateRetailer (NOLOCK) WHERE LEN(LTRIM(RTRIM(RtrUniqueCode)))<=0
			
			DELETE FROM #TempMigrateRetailer WHERE LEN(LTRIM(RTRIM(RtrUniqueCode)))<=0
			
			--Retailer Category CHANNEL
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 5,'Retailer Category','Catagory Code','Category Code '+RtrChannelCode+' does not exists' 
			FROM #TempMigrateRetailer A (NOLOCK) WHERE NOT EXISTS(SELECT CtgCode FROM RetailerCategory B (NOLOCK) 
			INNER JOIN RetailerCategoryLevel  C (NOLOCK) ON C.CtgLevelId=B.CtgLevelId
			WHERE A.RtrChannelCode=B.CtgCode AND UPPER(C.CtgLevelName)='CHANNEL') 
			
			DELETE A FROM #TempMigrateRetailer A WHERE NOT EXISTS(SELECT CtgCode FROM RetailerCategory B (NOLOCK) 
			INNER JOIN RetailerCategoryLevel C  (NOLOCK)ON C.CtgLevelId=B.CtgLevelId
			WHERE A.RtrChannelCode=B.CtgCode AND UPPER(C.CtgLevelName)='CHANNEL') 
			
			--Retailer Category GROUP
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 5,'Retailer Category','Catagory Code','Group Code '+RtrGroupCode+' does not exists' 
			FROM #TempMigrateRetailer A (NOLOCK) WHERE NOT EXISTS(SELECT CtgCode FROM RetailerCategory B (NOLOCK) 
			INNER JOIN RetailerCategoryLevel C (NOLOCK) ON C.CtgLevelId=B.CtgLevelId
			WHERE A.RtrGroupCode=B.CtgCode AND UPPER(C.CtgLevelName)='GROUP') 
			
			DELETE A FROM #TempMigrateRetailer A WHERE NOT EXISTS(SELECT CtgCode FROM RetailerCategory B (NOLOCK) 
			INNER JOIN RetailerCategoryLevel  C (NOLOCK) ON C.CtgLevelId=B.CtgLevelId
			WHERE A.RtrGroupCode=B.CtgCode AND UPPER(C.CtgLevelName)='GROUP')
						
			--Retailer Value Class
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 5,'Retailer Category','Catagory Code','Value Class Code '+RtrClassCode+' does not exists' 
			FROM #TempMigrateRetailer A (NOLOCK) WHERE NOT EXISTS(SELECT ValueClassCode FROM RetailerValueClass B (NOLOCK) 			
			WHERE A.RtrClassCode=B.ValueClassCode) 
			
			DELETE A FROM #TempMigrateRetailer A WHERE NOT EXISTS(SELECT ValueClassCode FROM RetailerValueClass B (NOLOCK) 			
			WHERE A.RtrClassCode=B.ValueClassCode)  
			
			--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			--SELECT 9,'Retailer','MigrateDate','Migrate Date for '+CmpRtrCode+' is mandatory for Migrated/Restored retailers' 
			--FROM #TempMigrateRetailer (NOLOCK) WHERE LEN(LTRIM(RTRIM(MigrateDate)))<=0 
			--DELETE FROM #TempMigrateRetailer WHERE LEN(LTRIM(RTRIM(MigrateDate)))<=0 
			
			--Sales Route Blank
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 10,'Retailer','RmCode','Sales Route for '+CmpRtrCode+' is mandatory for Migrated retailers' 
			FROM #TempMigrateRetailer (NOLOCK) WHERE LEN(LTRIM(RTRIM(SalesRoute)))<=0
			
			DELETE FROM #TempMigrateRetailer WHERE LEN(LTRIM(RTRIM(SalesRoute)))<=0
			
			--Delivery Route Blank
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 11,'Retailer','DRmCode','Delivery Route for '+CmpRtrCode+' is mandatory for Migrated retailers' 
			FROM #TempMigrateRetailer (NOLOCK) WHERE LEN(LTRIM(RTRIM(DeliveryRoute)))<=0
			
			DELETE FROM #TempMigrateRetailer WHERE LEN(LTRIM(RTRIM(DeliveryRoute)))<=0
			
			--Sales Route --> Route Master
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 12,'Retailer','RmCode','Sales Route for '+CmpRtrCode+' does not exists for Migrated retailers' 
			FROM #TempMigrateRetailer (NOLOCK) WHERE SalesRoute NOT IN (SELECT RMCode FROM RouteMaster WHERE RmStatus = 1 AND RMSRouteType = 1) 
			
			DELETE FROM #TempMigrateRetailer WHERE SalesRoute NOT IN (SELECT RMCode FROM RouteMaster WHERE RmStatus = 1 AND RMSRouteType = 1)
			
			--Delivery Route -->Route Master
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT 13,'Retailer','DRmCode','Delivery Route for '+CmpRtrCode+' does not exists for Migrated retailers' 
			FROM #TempMigrateRetailer (NOLOCK) WHERE DeliveryRoute NOT IN (SELECT RMCode FROM RouteMaster WHERE RmStatus = 1) 
			
			DELETE FROM #TempMigrateRetailer WHERE DeliveryRoute NOT IN (SELECT RMCode FROM RouteMaster WHERE RmStatus = 1)	
			--Take Geography Details
			CREATE TABLE #Geography
			(
				RtrCode			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				RmId			INT,
				RmCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
				GeoMainid		INT,
				GeoLevelId		INT,
				GeoName			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				GeoLevelName	NVARCHAR(200) COLLATE DATABASE_DEFAULT
			)
			
			INSERT INTO #Geography (RtrCode,RmId,RmCode,GeoMainid,GeoLevelId,GeoName,GeoLevelName)
			SELECT DISTINCT A.RetailerCode,R.RMId,R.RMCode,B.GeoMainId,C.GeoLevelId,B.GeoName,C.GeoLevelName 
			FROM #TempMigrateRetailer A (NOLOCK)
				INNER JOIN RouteMaster R (NOLOCK) ON A.SalesRoute=R.RMCode
				INNER JOIN Geography B (NOLOCK) ON R.GeoMainId=B.GeoMainId AND RMSRouteType=1
				INNER JOIN GeographyLevel C (NOLOCK) ON B.GeoLevelId=C.GeoLevelId
			
			
			--Take Delivery Route
			CREATE TABLE #DeliveryRoute
			(
				RtrCode			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				RmId			INT,
				RmCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT
			)
			
			INSERT INTO #DeliveryRoute (RtrCode,RmId,RmCode)
			SELECT DISTINCT A.RetailerCode,R.RMId,R.RMCode
			FROM #TempMigrateRetailer A (NOLOCK)
				INNER JOIN RouteMaster R (NOLOCK) ON A.DeliveryRoute=R.RMCode AND RMSRouteType=2
				
			SET @RtrId=ISNULL(@RtrId,0)
			
						
			----(CASE R.RtrType WHEN 1 THEN 'Retailer' WHEN 2 THEN 'Sub Stockist' WHEN 3 THEN 'Hub' WHEN 4 THEN 'Spoke' ELSE 'Distributor' END)
			INSERT INTO Retailer(RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrContactPerson,
			RtrKeyAcc,RtrCovMode,RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,RtrCSTNo,RtrDepositAmt,
			RtrCrBills,RtrCrLimit,RtrCrDays,RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,
			RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,GeoMainId,RMId,VillageId,RtrShipId,TaxGroupId,RtrResPhone1,
			RtrResPhone2,RtrOffPhone1,RtrOffPhone2,RtrDOB,RtrAnniversary,RtrRemark1,RtrRemark2,RtrRemark3,CoaId,RtrOnAcc,RtrType,RtrFrequency,
			RtrCrBillsAlert,RtrCrLimitAlert,RtrCrDaysAlert,Upload,RtrRlStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate,CmpRtrCode,
			Approved,XMLUpload,RtrPayment,RtrUniqueCode)
			SELECT @RtrId + ROW_NUMBER() OVER (ORDER BY RetailerCode,RetailerName),
			RetailerCode,RetailerName,ISNULL(RtrAddress1,''),ISNULL(RtrAddress2,''),
			ISNULL(RtrAddress3,''),ISNULL(RtrPinNo,''),ISNULL(RtrPhoneNo,''),'' AS RtrEmailId,ISNULL(RtrContactPerson,''),
			(CASE ISNULL(KeyAccount,'NO') WHEN 'NO' THEN 0 ELSE 1 END) AS KeyAccount,
			1,CONVERT(VARCHAR(10),CAST(RtrRegDate as datetime),121),ISNULL(RtrDayOff,0),ISNULL(RtrStatus,1),(CASE ISNULL(RtrTaxable,'Y') WHEN 'Y' THEN 1 ELSE 1 END) AS RtrTaxable,
			(CASE ISNULL(RtrTINNo,'') WHEN '' THEN 1 ELSE 0 END) AS RtrTaxType,ISNULL(RtrTINNo,'') AS RtrTINNo,ISNULL(RtrCSTNo,'') AS RtrCSTNo,0,ISNULL(RtrCrBills,0),ISNULL(RtrCrLimit,0),ISNULL(RtrCrDays,0),
			0,0,0,'','','','','','',ISNULL(#Geography.GeoMainid,0),ISNULL(#DeliveryRoute.RmId,0),0 VillageId,0 RtrShipId,0 TaxGroupId,'',
			'','','',GETDATE(),GETDATE(),'','','',0 AS CoaId,0,CASE RtrType WHEN 'Retailer' THEN 1 WHEN 'Sub Stockist' THEN  2 WHEN  'Hub' THEN 3 WHEN 'Spoke'  THEN  3 ELSE 0 END as RtrType,0, --ISNULL(RtrType,1),0,
			0,0,0,'N',CASE ISNULL(RelationStatus,'INDEPENDENT') WHEN 'PARENT' THEN 2 WHEN 'CHILD' THEN 3  ELSE 1 END AS RelationStatus,
						1,1,GETDATE(),1,GETDATE(),CmpRtrCode,CASE ISNULL(Approved,'APPROVED') WHEN 'APPROVED' THEN 1 WHEN 'PENDING' THEN 0  ELSE 2 END Approved,0,1,RtrUniqueCode
			 FROM #TempMigrateRetailer A (NOLOCK)
			LEFT OUTER JOIN #Geography ON A.RetailerCode =#Geography.RtrCode AND A.SalesRoute=#Geography.RmCode
			INNER JOIN #DeliveryRoute ON A.RetailerCode = #DeliveryRoute.RtrCode
			WHERE LEN(RetailerCode) > 0 AND LEN(RetailerName) > 0 AND LEN(A.CmpRtrCode) > 0
			
			
			DECLARE @TrackID as BIGINT			
			SELECT @TrackID=MAX(ISNULL(TrackID,0)) FROM RetailerReDownloadTracking
			
			INSERT INTO RetailerReDownloadTracking (TrackID,RetailerCode,CmpRtrCode,RetailerName,RtrAddress1,RtrAddress2,
			RtrAddress3,RtrPinNo,RtrChannelCode,RtrGroupCode,RtrClassCode,KeyAccount,RelationStatus,ParentCode,RtrRegDate,RtrStatus,
			Approved,SalesRoute,DeliveryRoute,RtrType,RtrTINNo,RtrCrBills,RtrCrLimit,RtrCrDays,RtrDayOff,RtrCSTNo,RtrPhoneNo,
			RtrContactPerson,RtrTaxGroup,RtrTaxable,RtrUniqueCode,RtrShippAdd1,RtrShippAdd2,RtrShippAdd3,CreatedDate)
			SELECT DISTINCT ISNULL(@TrackID,0)+1,RetailerCode,CmpRtrCode,RetailerName,RtrAddress1,RtrAddress2,
			RtrAddress3,RtrPinNo,RtrChannelCode,RtrGroupCode,RtrClassCode,KeyAccount,RelationStatus,ParentCode,RtrRegDate,RtrStatus,
			Approved,SalesRoute,DeliveryRoute,RtrType,RtrTINNo,RtrCrBills,RtrCrLimit,RtrCrDays,RtrDayOff,RtrCSTNo,RtrPhoneNo,
			RtrContactPerson,RtrTaxGroup,RtrTaxable,RtrUniqueCode,RtrShippAdd1,RtrShippAdd2,RtrShippAdd3,GETDATE()
			FROM #TempMigrateRetailer 
			
			--Retailer Market
			INSERT INTO RetailerMarket(RtrId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
			SELECT R.RtrId,ISNULL(#Geography.RmId,0),1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),0
			FROM Retailer R (NOLOCK)
			INNER JOIN #TempMigrateRetailer A (NOLOCK) ON R.RtrCode = A.RetailerCode AND R.CmpRtrCode = A.CmpRtrCode 
			LEFT OUTER JOIN #Geography ON R.RtrCode =#Geography.RtrCode 
			
			--Retailer Value Class
			CREATE TABLE #RetailerDet
			(
				RetailerCode		NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				ChannelCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
				GroupCode			NVARCHAR(200) COLLATE DATABASE_DEFAULT,				
				ValueClassCode		NVARCHAR(100) COLLATE DATABASE_DEFAULT,				
				RtrClassId			INT,
				CtgMainId			INT,
				CtgLinkId			INT,
				CtgLevelId			INT,		
				CtgLinkCode			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				CtgLevelName		NVARCHAR(200) COLLATE DATABASE_DEFAULT,
				CmpId				INT,		
				CmpName				NVARCHAR(200) COLLATE DATABASE_DEFAULT
			)
	
	
			INSERT INTO #RetailerDet (RetailerCode,ChannelCode,GroupCode,ValueClassCode,RtrClassId,CtgMainId,CtgLinkId,CtgLevelId,CtgLinkCode,
									  CtgLevelName,CmpId,CmpName)
			SELECT DISTINCT TR.RetailerCode,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode,RVC.ValueClassCode,
			RVC.RtrClassId,RC.CtgMainId,RC.CtgLinkId,RC.CtgLevelId,RC.CtgLinkCode,RCL.CtgLevelName,C.CmpId,C.CmpName
				FROM
				RetailerValueClass RVC,
				RetailerCategory RC,
				RetailerCategoryLevel RCL,
				RetailerCategory RC1,
				Cn2Cs_Prk_RetailerReDownload TR,
				Company C
			WHERE RVC.CtgMainId=RC.CtgMainId
				AND	RCL.CtgLevelId=RC.CtgLevelId
				AND	RC.CtgLinkId = RC1.CtgMainId				
				AND TR.RtrClassCode=RVC.ValueClassCode			
				AND RC.CtgCode=TR.RtrGroupCode
				AND C.CmpId=RCL.CmpId AND C.DefaultCompany=1
				
					
			INSERT INTO RetailerValueClassMap(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT R.RtrId,ISNULL(#RetailerDet.RtrClassId,0),1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)
			FROM Retailer R (NOLOCK)
			INNER JOIN #TempMigrateRetailer A (NOLOCK) ON R.RtrCode = A.RetailerCode AND R.CmpRtrCode = A.CmpRtrCode 
			LEFT OUTER JOIN #RetailerDet ON R.RtrCode =#RetailerDet.RetailerCode
			--Till Here
			
			--RetailerShipAdd
			INSERT INTO RetailerShipAdd (RtrShipId,RtrId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo,RtrShipDefaultAdd,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT @RtrShipAddId + ROW_NUMBER() OVER (ORDER BY RetailerCode,RetailerName),@RtrId + ROW_NUMBER() OVER (ORDER BY RetailerCode,RetailerName),
			A.RtrShippAdd1,A.RtrShippAdd2,A.RtrShippAdd3,'','',
			1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)
			FROM Retailer R (NOLOCK)
			INNER JOIN #TempMigrateRetailer A (NOLOCK) ON R.RtrCode = A.RetailerCode AND R.CmpRtrCode = A.CmpRtrCode 
			
			UPDATE A SET A.RtrShipId=B.RtrShipId FROM Retailer A(NOLOCK) 			
			INNER JOIN RetailerShipAdd B (NOLOCK) ON A.RtrId=B.RtrId 
			
			--UPDATE R SET R.VillageId=B.VillageId FROM Retailer R(NOLOCK) 			
			--INNER JOIN #TempMigrateRetailer A (NOLOCK) ON R.RtrCode = A.RetailerCode AND R.CmpRtrCode = A.CmpRtrCode 		
			--INNER JOIN RouteVillage B (NOLOCK) ON B.VillageCode=A.VillageCode 
			
			UPDATE R SET R.TaxGroupId=B.TaxGroupId FROM Retailer R(NOLOCK) 			
			INNER JOIN #TempMigrateRetailer A (NOLOCK) ON R.RtrCode = A.RetailerCode AND R.CmpRtrCode = A.CmpRtrCode 		
			INNER JOIN TaxGroupSetting B (NOLOCK) ON B.RtrGroup=A.RtrTaxGroup 
			
			--CoaMaster
			CREATE TABLE #TempCoaMaster
				(
					CoaId		INT,
					AcCode		VARCHAR(100),
					RtrCode		VARCHAR(100),
					CmpRtrCode	VARCHAR(100),
					RetailerName VARCHAR(200)	
				)
			
			INSERT INTO #TempCoaMaster(CoaId,AcCode,RtrCode,CmpRtrCode,RetailerName)
			SELECT @CoaId + ROW_NUMBER() OVER (ORDER BY RetailerCode,RetailerName),@AccCode + ROW_NUMBER() OVER (ORDER BY RetailerCode,RetailerName),RetailerCode,R.CmpRtrCode,RetailerName
			FROM #TempMigrateRetailer A
			INNER JOIN Retailer R WITH (NOLOCK) ON A.RetailerCode = R.RtrCode AND A.CmpRtrCode = R.CmpRtrCode
			WHERE LEN(RetailerCode) > 0 AND LEN(RetailerName) > 0 AND LEN(A.CmpRtrCode) > 0 
			
			--Coa Master
			INSERT INTO CoaMaster (CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT CoaId,AcCode,RetailerName,4,2,2,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)
			FROM #TempCoaMaster
			
			UPDATE A SET A.CoaId=R.CoaId FROM Retailer A
			INNER JOIN #TempCoaMaster R WITH (NOLOCK) ON A.RtrCode = R.RtrCode AND A.CmpRtrCode = R.CmpRtrCode
			
			--UPDATE COUNTERS
			SELECT @CoaID = ISNULL(MAX(CoaID),0) FROM COAMaster 	
			UPDATE Counters SET CurrValue = @CoaID WHERE TabName = 'COAMaster'
			
			
			SELECT @RtrShipAddId = ISNULL(MAX(RtrShipId),0) FROM RetailerShipAdd
			UPDATE Counters SET CurrValue = @RtrShipAddId WHERE TabName = 'RetailerShipAdd'
			
			SELECT @RtrID = ISNULL(MAX(RtrId),0) FROM Retailer
			UPDATE Counters SET CurrValue = @RtrID WHERE TabName = 'Retailer' AND FldName = 'RtrId'
			
			--Update CompanyCounters 
			IF EXISTS(SELECT 7 FROM Cn2Cs_Prk_RetailerReDownload P (NOLOCK))
			BEGIN
				SELECT Prefix,CurYear,MAX(REPLACE(CmpRtrCode,(Prefix+RIGHT(CurYear,2)),0)) CurValue
				INTO #UpdatingCompanyCounters
				FROM CompanyCounters C (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON R.CmpRtrCode LIKE (C.Prefix+RIGHT(C.CurYear,2))+'%'
				WHERE TabName = 'Retailer' AND FldName = 'CmpRtrCode' --AND CurrValue = 0
				GROUP BY Prefix,CurYear
				
				UPDATE T SET T.CurrValue = F.CurValue
				FROM #UpdatingCompanyCounters F (NOLOCK)
				INNER JOIN CompanyCounters T (NOLOCK) ON F.Prefix = T.Prefix AND F.CurYear = T.CurYear
			END
			
			IF EXISTS(SELECT '*' FROM Cn2Cs_Prk_RetailerGST(NOLOCK) WHERE ISNULL(DownLoadFlag,'D')='D')
			BEGIN
				EXEC Proc_Cn2Cs_RetailerGST 0
			END
			
			UPDATE A SET A.DownloadFlag='Y' FROM Cn2Cs_Prk_RetailerReDownload A (NOLOCK) 
			INNER JOIN Retailer B (NOLOCK) ON A.RetailerCode=B.RtrCode AND A.CmpRtrCode = B.CmpRtrCode 
			WHERE LEN(RetailerCode) > 0 AND LEN(RetailerName) > 0 AND LEN(A.CmpRtrCode) > 0 AND DownloadFlag = 'D' 
	
	END TRY
	BEGIN CATCH
		SET @Po_ErrNo=1
		SELECT ERROR_LINE(),ERROR_MESSAGE ()
	END CATCH
END
GO
--Till Here
DELETE FROM MANUALCONFIGURATION WHERE ModuleId='GSTR1HSNReturn' and ProjectName='GST'
INSERT INTO MANUALCONFIGURATION(ProjectName,ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'GST','GSTR1HSNReturn','GSTR1HSNReturn','Consider Sales Return for GSTR1 HSN Summary Report',1,0,0,18
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptGSTR1_HSNCODE' AND xtype='P')
DROP PROCEDURE Proc_RptGSTR1_HSNCODE
GO
/*
EXEC Proc_RptGSTR1_HSNCODE 419,1,1,'',0,1,1
 */
CREATE PROCEDURE [Proc_RptGSTR1_HSNCODE]
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
/*********************************
* PROCEDURE		: Proc_RptGSTR1_HSNCODE
* PURPOSE		: To Generate a report GSTR1 B2B
* CREATED		: Murugan.R
* CREATED DATE	: 13/04/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
**************************************************************************************
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 13-12-2017   S.Moorthi   CR			CCRSTMTR0092		GSTR1 report - HSN summary option should consider sales return - Unregistered bills
 11-01-2018	  Mohana S	  BZ			ICRSTLOR2374		GSTR1 Report - Consider Only IDT OUT
*********************************/
SET NOCOUNT ON
BEGIN

		TRUNCATE TABLE RptGSTR1_HSNCODE
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017
		
		
		CREATE TABLE #RptGSTR1_HSNCODE
		(
			[HSN]	Varchar(20),
			[Description]	Varchar(200),
			[UQC]	Varchar(20),
			[Total Quantity]	BIGINT,
			[Total Value]	Numeric(32,4),
			[Taxable Value]	Numeric(32,4),
			[Integrated Tax Amount]	Numeric(32,4),
			[Central Tax Amount]	Numeric(32,4),
			[State/UT Tax Amount]	Numeric(32,4),
			[Cess Amount]	Numeric(32,4),
			UsrId INT,
			[Group Name] Varchar(100),
			GroupType TINYINT
		)
	
		SELECT DISTINCT Prdid,ColumnValue as HSNCode,Cast('' as Varchar(150)) as HSNDesc
		INTO #ProductHsnCode
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Product R ON R.Prdid=UT.MasterRecordId
		WHERE U.MasterId=1 and ColumnName='HSN Code' 
		
		SELECT DISTINCT Prdid,ColumnValue as HSNDesc
		INTO #ProductHsnDesc
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Product R ON R.Prdid=UT.MasterRecordId
		WHERE U.MasterId=1 and ColumnName='HSN Description' 
		
		---Retailer Registered
		--SELECT R.RtrId,ColumnValue
		--INTO #RetailerUnRegister
		--FROM UDCHD U 
		--INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		--INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		--INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		--WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue='UnRegistered' 
		
		Update A Set A.HSNdesc=B.HSNDesc FROM #ProductHsnCode A INNER JOIN #ProductHsnDesc B ON A.Prdid=B.Prdid
		
		SELECT PurRcptId 
		INTO #PurchaseReceipt
		FROM PurchaseReceipt WHERE VatGst='VAT' and GoodsRcvdDate Between '2017-01-01' and '2017-06-30'
		and Status=1
		--SELECT Salid INTO #Sales1  FROM Salesinvoice (NOLOCK)		
		--WHERE Dlvsts>3 and Salinvdate between '2017-01-01' and '2017-06-30' and VatGst='VAT'
		
		
		SELECT Salid,Salinvno,SalInvdate,Prdslno,SUM(TaxableAmount) as TaxableAmount,SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
		INTO #Sales	
		FROM
		(		
			SELECT S.Salid,Salinvno,SalInvdate,Prdslno,
			ISNULL(CASE WHEN  TaxCode IN('OutputIGST','IGST','OutputCGST','CGST') THEN SUM(TaxableAmount) END,0) as TaxableAmount,
			ISNULL(CASE WHEN TaxCode IN('OutputIGST','IGST') THEN SUM(TaxAmount) END ,0) AS IGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputCGST','CGST') THEN SUM(TaxAmount) END ,0) AS CGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(TaxAmount) END ,0) AS SGSTUTTaxAmount
				
			FROM SalesInvoice S (NOLOCK) 
			INNER JOIN SalesInvoiceProductTax ST (NOLOCK) ON S.Salid=ST.SalId
			INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
			WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
			and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST')
			and ST.TaxableAmount>0
			GROUP BY S.Salid,Salinvno,SalInvdate,Prdslno,TaxCode
		)X GROUP BY Salid,Salinvno,SalInvdate,Prdslno
		
		SELECT  IDTMngRefNo,IDTMngDate,PrdSlNo,SUM(TaxableAmount) as TaxableAmount,SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
		INTO #IDTSales	
		FROM
		(		
			SELECT S.IDTMngRefNo,IDTMngDate,PrdSlNo,
			ISNULL(CASE WHEN  TaxCode IN('OutputIGST','IGST','InPutIGST','IDTIGST','OutputCGST','CGST','InPutCGST','IDTCGST') THEN SUM(TaxableAmount) END,0) as TaxableAmount,
			ISNULL(CASE WHEN TaxCode IN('OutputIGST','IGST','InPutIGST','IDTIGST') THEN SUM(TaxAmount) END ,0) AS IGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputCGST','CGST','InPutCGST','IDTCGST') THEN SUM(TaxAmount) END ,0) AS CGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST','InPutSGST','InPutUTGST','IDTSGST','IDTUTGST') THEN SUM(TaxAmount) END ,0) AS SGSTUTTaxAmount
				
			FROM IDTManagement S (NOLOCK) 
			INNER JOIN IDTManagementProductTax ST (NOLOCK) ON S.IDTMngRefNo=ST.IDTMngRefNo
			INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
			WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear  AND StkMgmtTypeId=2 --ICRSTLOR2374
			and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST',
			'InPutIGST','InPutCGST','InPutSGST','InPutUTGST','IDTIGST','IDTCGST','IDTSGST','IDTUTGST')
			and ST.TaxableAmount>0
			GROUP BY  S.IDTMngRefNo,IDTMngDate,PrdSlNo,TaxCode
		)X GROUP BY  IDTMngRefNo,IDTMngDate,PrdSlNo
		
		SELECT  PurRetId,PurRetRefNo,PurRetDate,PrdSlNo,SUM(TaxableAmount) as TaxableAmount,SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
		INTO #PurchaseSales	
		FROM
		(		
			SELECT S.PurRetId,S.PurRetRefNo,PurRetDate,PrdSlNo,
			ISNULL(CASE WHEN  TaxCode IN('OutputIGST','IGST','InPutIGST','IDTIGST','OutputCGST','CGST','InPutCGST','IDTCGST') THEN SUM(ST.TaxableAmount) END,0) as TaxableAmount,
			ISNULL(CASE WHEN TaxCode IN('OutputIGST','IGST','InPutIGST','IDTIGST') THEN SUM(ST.TaxAmount) END ,0) AS IGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputCGST','CGST','InPutCGST','IDTCGST') THEN SUM(ST.TaxAmount) END ,0) AS CGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST','InPutSGST','InPutUTGST','IDTSGST','IDTUTGST') THEN SUM(ST.TaxAmount) END ,0) AS SGSTUTTaxAmount
				
			FROM PurchaseReturn S (NOLOCK) 
			INNER JOIN PurchaseReturnProductTax ST (NOLOCK) ON S.PurRetId=ST.PurRetId
			INNER JOIN #PurchaseReceipt PR ON PR.PurRcptId=S.PurRcptId
			INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
			WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear 
			and TaxCode IN('IGST','CGST','SGST','UTGST','InPutIGST','InPutCGST','InPutSGST','InPutUTGST')
			and ST.TaxableAmount>0
			GROUP BY  S.PurRetId,S.PurRetRefNo,PurRetDate,PrdSlNo,TaxCode
		)X GROUP BY  PurRetId,PurRetRefNo,PurRetDate,PrdSlNo
		--Added S.Moorthi CCRSTMTR0092
		CREATE TABLE #SalesReturn
		(
			ReturnId	INT,
			ReturnCode	VARCHAR(100),
			ReturnDate	DATETIME,
			Prdslno		BIGINT,
			TaxableAmount	NUMERIC(18,6),
			IGSTTaxAmount	NUMERIC(18,6),
			CGSTTaxAmount	NUMERIC(18,6),
			SGSTUTTaxAmount	NUMERIC(18,6)
		)
		

		IF EXISTS(SELECT * FROM MANUALCONFIGURATION WHERE ModuleId='GSTR1HSNReturn' and ProjectName='GST' AND [Status]=1)
		BEGIN
		
			INSERT INTO #SalesReturn(ReturnId,ReturnCode,ReturnDate,Prdslno,TaxableAmount,IGSTTaxAmount,CGSTTaxAmount,SGSTUTTaxAmount)
			SELECT ReturnId,ReturnCode,ReturnDate,Prdslno,SUM(TaxableAmount) as TaxableAmount,SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount		
			FROM
			(		
				SELECT S.ReturnId,ReturnCode,ReturnDate,Prdslno,
				ISNULL(CASE WHEN  TaxCode IN('OutputIGST','IGST','OutputCGST','CGST') THEN SUM(TaxableAmt) END,0) as TaxableAmount,
				ISNULL(CASE WHEN TaxCode IN('OutputIGST','IGST') THEN SUM(TaxAmt) END ,0) AS IGSTTaxAmount ,
				ISNULL(CASE WHEN TaxCode IN('OutputCGST','CGST') THEN SUM(TaxAmt) END ,0) AS CGSTTaxAmount ,
				ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(TaxAmt) END ,0) AS SGSTUTTaxAmount
					
				FROM ReturnHeader S (NOLOCK) 
				--INNER JOIN #RetailerUnRegister R (NOLOCK) ON R.RtrId=S.RtrId
				--INNER JOIN #Sales1 SS ON SS.SalId=S.SalId
				INNER JOIN SalesInvoice SS (NOLOCK) ON SS.SalId=S.SalId
				INNER JOIN ReturnProductTax ST (NOLOCK) ON S.ReturnId=ST.ReturnId
				INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
				WHERE S.[Status]=0 and Month(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
				and S.VatGST='GST'
				and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST')
				and ST.TaxableAmt>0
				GROUP BY S.ReturnId,ReturnCode,ReturnDate,Prdslno,TaxCode
			)X GROUP BY ReturnId,ReturnCode,ReturnDate,Prdslno
			
		END
		--Till Here CCRSTMTR0092
		INSERT INTO #RptGSTR1_HSNCODE([HSN],[Description],[UQC],[Total Quantity],[Total Value],[Taxable Value],[Integrated Tax Amount],
		[Central Tax Amount],[State/UT Tax Amount],[Cess Amount],UsrId,[Group Name],GroupType)
		SELECT HSNCode,HSNDesc,'NOS-Numbers' as [UQC],SUM(BaseQty) as BaseQty,SUM(SalesValue) as SalesValue,
		SUM(TaxableAmount) as TaxableAmount,
		SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,
		SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount,
		0.00 as CessAmount,
		@Pi_UsrId,'' as [Group Type],2
		FROM
		(		
			SELECT ISNULL(HSNCode,'') as HSNCode,ISNULL(HSNDesc,'') as HSNDesc,SUM(BaseQty) as BaseQty,SUM(PrdNetAmount) as SalesValue,
			SUM(TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
			FROM #Sales S INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON S.Salid=SIP.Salid and S.Prdslno=SIP.Slno
			LEFT OUTER JOIN #ProductHsnCode P ON P.Prdid=SIP.Prdid
			GROUP BY 
			ISNULL(HSNCode,''),ISNULL(HSNDesc,'')
			UNION ALL
			SELECT ISNULL(HSNCode,'') as HSNCode,ISNULL(HSNDesc,'') as HSNDesc,SUM(Qty) as BaseQty,SUM(PrdNetAmount) as SalesValue,
			SUM(TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
			FROM #IDTSales S INNER JOIN IDTManagementProduct SIP (NOLOCK) ON S.IDTMngRefNo=SIP.IDTMngRefNo and S.Prdslno=SIP.Prdslno
			LEFT OUTER JOIN #ProductHsnCode P ON P.Prdid=SIP.Prdid
			GROUP BY 
			ISNULL(HSNCode,''),ISNULL(HSNDesc,'')
			UNION ALL
			SELECT ISNULL(HSNCode,'') as HSNCode,ISNULL(HSNDesc,'') as HSNDesc,SUM(RetSalBaseQty+RetUnSalBaseQty) as BaseQty,SUM(PrdNetAmount) as SalesValue,
			SUM(TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
			FROM #PurchaseSales S INNER JOIN PurchaseReturnProduct SIP (NOLOCK) ON S.PurRetId=SIP.PurRetId and S.Prdslno=SIP.Prdslno
			LEFT OUTER JOIN #ProductHsnCode P ON P.Prdid=SIP.Prdid
			GROUP BY 
			ISNULL(HSNCode,''),ISNULL(HSNDesc,'')
			UNION ALL --CCRSTMTR0092
			SELECT ISNULL(HSNCode,'') as HSNCode,ISNULL(HSNDesc,'') as HSNDesc,-1*SUM(SIP.BaseQty) as BaseQty,-1*SUM(SIP.PrdNetAmt) as SalesValue,
			-1*SUM(TaxableAmount) as TaxableAmount,
			-1*SUM(IGSTTaxAmount) as IGSTTaxAmount,
			-1*SUM(CGSTTaxAmount) as CGSTTaxAmount,
			-1*SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
			FROM #SalesReturn S INNER JOIN ReturnProduct SIP (NOLOCK) ON S.ReturnId=SIP.ReturnId and S.Prdslno=SIP.Slno
			LEFT OUTER JOIN #ProductHsnCode P ON P.Prdid=SIP.Prdid
			GROUP BY ISNULL(HSNCode,''),ISNULL(HSNDesc,'')
		) X GROUP BY HSNCode,HSNDesc
		

			
		IF NOT EXISTS(SELECT 'X' FROM #RptGSTR1_HSNCODE)
		BEGIN
			SELECT * FROM RptGSTR1_HSNCODE (NOLOCK) WHERE UsrId=@Pi_UsrId
			RETURN
		END
		
		INSERT INTO RptGSTR1_HSNCODE([HSN],[Description],[UQC],[Total Quantity],[Total Value],[Taxable Value],[Integrated Tax Amount],
		[Central Tax Amount],[State/UT Tax Amount],[Cess Amount],UsrId,[Group Name],GroupType)		
		SELECT [HSN],[Description],[UQC],[Total Quantity],[Total Value],[Taxable Value],[Integrated Tax Amount],
		[Central Tax Amount],[State/UT Tax Amount],[Cess Amount],UsrId,[Group Name],GroupType
		FROM #RptGSTR1_HSNCODE ORDER BY [HSN]
		
		INSERT INTO RptGSTR1_HSNCODE([HSN],[Description],[UQC],[Total Quantity],[Total Value],
		[Taxable Value],[Integrated Tax Amount],[Central Tax Amount],[State/UT Tax Amount],
		[Cess Amount],UsrId,[Group Name],GroupType)
		SELECT '' as [HSN],'' as [Description],'' as [UQC],SUM([Total Quantity]),SUM([Total Value]) as [Total Value],
		SUM([Taxable Value]),SUM([Integrated Tax Amount]),SUM([Central Tax Amount]),SUM([State/UT Tax Amount]),
		SUM([Cess Amount]),
		@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
		FROM #RptGSTR1_HSNCODE
		
		
		SELECT * FROM RptGSTR1_HSNCODE WHERE UsrId=@Pi_UsrId
				
END
GO
IF EXISTS (SELECT  * FROM SYS.OBJECTS WHERE TYPE='P' AND NAME='PROC_RPTGSTR1EXTRACT')
DROP  PROCEDURE Proc_RptGSTR1Extract
GO
/*
BEGIN tran
EXEC Proc_RptGSTR1Extract 424,1,0,'GSTTAX',0,0,1
Select * from RptInputtaxCreditGST
ROLLBACK tran 
*/
CREATE PROCEDURE [dbo].[Proc_RptGSTR1Extract]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptGSTR1Extract
* PURPOSE	: To get the Input Tax
* CREATED	: Murugan.R
* CREATED DATE	: 25/08/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
11-01-2018	  Mohana S	  BZ			ICRSTLOR2374		GSTR1 Report - REFRESH ISSUE FIX
*********************************/
BEGIN
SET NOCOUNT ON
		
	--DELETE FROM  ReportFilterDt WHERE RptId IN(414,415,416,417,418,419,420,421) 
	--INSERT INTO ReportFilterDt(RptId,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate)
	--SELECT 414,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 415,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 416,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 417,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 418,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId	
	--UNION ALL
	--SELECT 419,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 420,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 421,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	
	DELETE FROM Report_txt_PageHeader_GST WHERE RptId IN(414,415,416,417,418,419,420,421)
	INSERT INTO Report_txt_PageHeader_GST(ColId,RptId,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId)
	SELECT ColId,414,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,415,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,416,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,417,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,418,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,419,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,420,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,421,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	
	--WAITFOR DELAY '00:00:20'
	--EXEC Proc_RptGSTR1_Docs 420 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--WAITFOR DELAY '00:00:20'	
	--EXEC Proc_RptGSTR1_HSNCODE 419 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--WAITFOR DELAY '00:00:20'
	--EXEC Proc_RptGSTRTRANS1_CDNR 417 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--WAITFOR DELAY '00:00:20'
	--EXEC Proc_RptGSTRTRANS1_CDNUR 418 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--WAITFOR DELAY '00:00:20'
	--EXEC Proc_RptFORMGSTR1_Exempt 421 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId	
	--WAITFOR DELAY '00:00:20'
	--EXEC Proc_RptGSTR1_B2B 414,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--WAITFOR DELAY '00:00:20'
	--EXEC Proc_RptGSTR1_B2CL 415,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--WAITFOR DELAY '00:00:20'
	--EXEC Proc_RptGSTR1_B2CS 416 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
		
	
	SELECT * FROM RptGSTR1_HSNCODE WHERE UsrId=@Pi_UsrId
END
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Proc_RptGSTR1_B2B' AND XTYPE = 'P')
DROP PROCEDURE Proc_RptGSTR1_B2B
GO
/*
EXEC Proc_RptGSTR1_B2B 414,1,0,'',0,0,0
 */
CREATE PROCEDURE [Proc_RptGSTR1_B2B]
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
/*********************************
* PROCEDURE		: Proc_RptGSTR1_B2B
* PURPOSE		: To Generate a report GSTR1 B2B
* CREATED		: Murugan.R
* CREATED DATE	: 13/04/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
11-01-2018	  MURUGAN	  BZ			ICRSTLOR2374		GSTR1 Report - REFRESH ISSUE FIX

*********************************/
SET NOCOUNT ON
BEGIN
		TRUNCATE TABLE RptGSTR1_B2B
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		--ICRSTLOR2374
		DELETE FROM  ReportFilterDt WHERE RptId IN(414,415,416,417,418,419,420,421) 
		INSERT INTO ReportFilterDt(RptId,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate)
		SELECT 414,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 415,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 416,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 417,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 418,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId	
		UNION ALL
		SELECT 419,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 420,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 421,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		--ICRSTLOR2374
		
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017
		
		
		CREATE TABLE #RptGSTR1_B2B
		(
		TransId				TINYINT,
		TranType			VARCHAR(20),
		Refid				BIGINT,
		RtrShipId			INT,
		RtrId				INT,
		RtrCode				VARCHAR(50),		
		RtrName				VARCHAR(100),
		[GSTIN/UIN of Recipient]	 VARCHAR(50),
		[Retailer Type]		 VARCHAR(50),
		[Invoice Number]	 VARCHAR(50),
		[Invoice date]		 DATETIME,
		[Invoice Value]		 NUMERIC(32,2),
		[Place Of Supply]	 VARCHAR(125),
		[Reverse Charge]	 VARCHAR(10),
		[Invoice Type]		 VARCHAR(50),
		[Kind of transaction]			Varchar(50),
		[Identifier if Goods or Services]	Varchar(50),		
		[E-Commerce GSTIN]	 VARCHAR(50),
		[Rate]				 NUMERIC(10,2),
		[Taxable Value]		 NUMERIC(32,2),
		[Cess Amount]		 NUMERIC(32,2),
		[IGST rate]			 Numeric(32,2),
		[IGST amount]		 Numeric(32,2),
		[CGST rate]			 Numeric(32,2),
		[CGST amount]		 Numeric(32,2),
		[SGST/UTGST rate]	 Numeric(32,2),
		[SGST/UTGST amount]	 Numeric(32,2),		
		UsrId				 INT,
		[Group Name]		 VARCHAR(100),
		GroupType			 TINYINT
		)
		
		SELECT PurRcptId INTO #Purchareceipt
		FROM PurchaseReceipt (NOLOCK)
		WHERE GoodsRcvdDate Between '2017-01-01' and '2017-06-30' and VatGst='VAT'
		and Status=1
		
		---Retailer State
		SELECT DISTINCT  R.RtrId as RtrId,TinFirst2Digit+'-'+StateName as StateName
		INTO #RetailerState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=2 and ColumnName='State Name'
		
		---Supplier State
		SELECT DISTINCT  R.SpmId as RtrId,TinFirst2Digit+'-'+StateName as StateName
		INTO #SupplierState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Supplier R ON R.SpmId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=8 and ColumnName='State Name'
		
		---IDT Distributor State
		SELECT DISTINCT  R.SpmId as RtrId,TinFirst2Digit+'-'+StateName as StateName
		INTO #IDTSupplierState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN IDTMaster R ON R.SpmId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=8 and ColumnName='State Name'
		
		
		---Supplier GSTIN
		SELECT DISTINCT  SpmId as RtrId ,UT.ColumnValue
		INTO #SupplierGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Supplier R ON R.SpmId=UT.MasterRecordId
		WHERE U.MasterId=8 and ColumnName='GSTIN'
		
				
		---IDT Supplier GSTIN
		SELECT DISTINCT  SpmId as RtrId ,UT.ColumnValue
		INTO #IDTSupplierGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN IDTMaster R ON R.SpmId=UT.MasterRecordId
		WHERE U.MasterId=8 and ColumnName='GSTIN'
		
		---Retailer GSTIN
		SELECT DISTINCT  R.RtrId as RtrId,UT.ColumnValue INTO #RetailerGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='GSTIN'
		
		---Retailer Registered
		SELECT R.RtrId,ColumnValue	INTO #RetailerRegister
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue='Registered' 
		
		
		---Sales Data
		SELECT S.RtrId,S.RtrshipId,S.Salid,Salinvno,SalInvdate,Prdslno,OrgNetAmount,SUM(TaxPerc) as Taxperc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(TaxAmount) as TaxAmount
		INTO #Sales		
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProductTax ST (NOLOCK) ON S.Salid=ST.SalId
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST')
		and ST.TaxableAmount>0
		GROUP BY S.RtrId,S.Salid,Salinvno,SalInvdate,Prdslno,S.RtrshipId,OrgNetAmount

		SELECT S.SalId,S.Rtrid,SUM(PrdNetAmount)PrdNetAmount INTO #SalesNetValue FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SI (NOLOCK) ON S.Salid=SI.SalId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		GROUP BY S.SalId,S.Rtrid

		UPDATE S SET OrgNetAmount=PrdNetAmount FROM #Sales S INNER JOIN #SalesNetValue SI ON S.Salid=SI.Salid
		
		--IDT Sales Data
		SELECT ToSpmId,I.IDTMngRefNo,IDTMngDate,PrdSlNo,IDTNetAmt,SUM(TaxPerc) as TaxPerc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(TaxAmount) as TaxAmount
		INTO #IDTSales
		FROM IDTManagement I (NOLOCK) 
		INNER JOIN IDTManagementProductTax IT (NOLOCK) ON I.IDTMngRefNo=IT.IDTMngRefNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=IT.TaxId
		WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear
		and StkMgmtTypeId=2 and IT.TaxableAmount>0
		GROUP BY ToSpmId,I.IDTMngRefNo,IDTMngDate,PrdSlNo,IDTNetAmt
		
		---Purchase Return Supply Data
		SELECT SpmId,I.PurRetId,I.PurRetRefNo,PurRetDate,PrdSlNo,NetAmount,SUM(IT.TaxPerc) as TaxPerc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(IT.TaxAmount) as TaxAmount
		INTO #PurchaseReturn
		FROM PurchaseReturn I (NOLOCK) 
		INNER JOIN PurchaseReturnProductTax IT (NOLOCK) ON I.PurRetId=IT.PurRetId
		INNER JOIN #Purchareceipt R ON R.PurRcptId=I.PurRcptId
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=IT.TaxId
		WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
		and IT.TaxableAmount>0
		GROUP BY SpmId,I.PurRetRefNo,PurRetDate,PrdSlNo,I.PurRetId,NetAmount
		
		SELECT  S.ServiceToId,S.ServiceInvId as Salid,ServiceInvRefNo as Salinvno,ServiceInvDate as SalInvdate,
		RowNo,AppTotalAmount,SUM(TaxPerc) as Taxperc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(TaxAmount) as TaxAmount
		INTO #ServiceData
		FROM ServiceInvoiceHd S (NOLOCK) 
		INNER JOIN ServiceInvoiceTaxDetails SI (NOLOCK)
		ON S.ServiceInvId=SI.ServiceInvId
		WHERE ServiceInvFor=2 and  Month(ServiceInvDate)=@MonthStart and Year(ServiceInvDate)=@Jcmyear
		and SI.TaxableAmount>0
		GROUP BY S.ServiceToId,S.ServiceInvId,ServiceInvRefNo,ServiceInvDate,RowNo,AppTotalAmount
		
		-----Service
		--SELECT UniqueId,Proforma_Invoice_No ,Proforma_Invoice_Date ,
		--SUM(ISNULL(DocAmount+tax_Amount,0))ApprovedAmt ,SUM(CGST_Per+SGST_Per+IGST_Per+UTGST_Per) as Taxperc,
		--SUM(ISNULL(DocAmount,0)) as TaxableAmount,SUM(ISNULL(tax_Amount,0)) as TaxAmount,CGST_Per,SGST_Per,IGST_Per,UTGST_Per,
		--CGST_Amt,SGST_Amt,IGST_Amt,UTGST_Amt
		--INTO #ServiceData
		--FROM ClaimAcknowledgement WHERE ClaimType IN('Project1 Claim','Other Claim','Manual Claim',
		--'VAT Claim','Incentive Claim','ROI Subsidy Claim','VD ManPower Cost Claim','VD Subsidy Claim','OTHER SERVICE CLAIM')
		--and CAST(ClaimMonth as INT)=@MonthStart and ClaimYear=@Jcmyear 
		--and LEN(ISNULL(DocNumber,''))>0 and Status='APPROVED' and LEN(ISNULL(ServiceAcCode,''))>0
		--GROUP BY UniqueId,Proforma_Invoice_No,Proforma_Invoice_Date,CGST_Per,SGST_Per,IGST_Per,UTGST_Per,CGST_Amt,SGST_Amt,IGST_Amt,UTGST_Amt
		--HAVING SUM(ISNULL(IGST_AMT,0)+ISNULL(CGST_Amt,0)+ISNULL(SGST_Amt,0)+ISNULL(UTGST_Amt,0))>0
		
		---CALCULATE TAX SPLIT 
				
			SELECT TAXID,				
			CASE	WHEN TaxCode IN('OutputIGST','IGST','InputIGST') THEN 'OutputIGST'
			WHEN TaxCode IN ('OutputCGST','CGST','InputCGST') Then 'OutputCGST'
			WHEN TaxCode IN ('OutputSGST','SGST','InputSGST') Then 'OutputSGST'
			WHEN TaxCode IN ('OutputUTGST','UTGST','InputUTGST') Then 'OutputUTGST'
			END	 as TaxCode
			INTO #TaxConfiguration
			FROM  TaxConfiguration WHERE TaxCode 
			IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST',
			'InputCGST','InputSGST','InputIGST','InputUTGST')
		SELECT * INTO #SalesInvoiceProductTax FROM SalesInvoiceProductTax 
			WHERE SalId IN (SELECT DISTINCT salid FROM #Sales) 			
				
		SELECT * INTO #IDTManagementProductTax FROM IDTManagementProductTax 
			WHERE IDTMngRefNo IN (SELECT DISTINCT IDTMngRefNo FROM #IDTSales) 
		SELECT * INTO #PurchaseReturnProductTax  FROM PurchaseReturnProductTax 
			WHERE PurRetId IN (SELECT DISTINCT PurRetId FROM #PurchaseReturn) 
			SELECT * INTO #ServiceInvoiceTaxDetails  FROM ServiceInvoiceTaxDetails 
			WHERE ServiceInvId IN (SELECT DISTINCT ServiceInvId FROM #ServiceData) 
 			
  			SELECT BTYPE,Salinvno,Prdslno,TaxCode,TaxPercAmt INTO #TAXPIVOT
			FROM
			(
			----SALES DATA
			SELECT 1 AS BTYPE,SI.Salinvno,SI.Prdslno,
			TaxCode+'Perc' AS TaxCode
			,ST.TaxPerc AS TaxPercAmt 
				FROM #Sales SI
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL
			SELECT 1 AS BTYPE,SI.Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #Sales SI
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId  AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL	
			-------IDT DETAILS	
			SELECT 2 AS BTYPE,SI.IDTMngRefNo AS Salinvno,SI.Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
				FROM #IDTSales SI
				INNER JOIN #IDTManagementProductTax ST ON ST.IDTMngRefNo=SI.IDTMngRefNo AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST')) T ON T.TaxId=ST.TaxId
			UNION ALL
			SELECT 2 AS BTYPE,SI.IDTMngRefNo  AS Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #IDTSales SI
				INNER JOIN #IDTManagementProductTax ST ON ST.IDTMngRefNo=SI.IDTMngRefNo AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
				IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST')) T ON T.TaxId=ST.TaxId
			UNION ALL	
  			---PURCHASE RETURN DETAILS
				SELECT 3 AS BTYPE,SI.PurRetRefNo AS Salinvno,SI.Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
				FROM #PurchaseReturn SI
				INNER JOIN #PurchaseReturnProductTax ST ON ST.PurRetId=SI.PurRetId AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL
				SELECT 3 AS BTYPE,SI.PurRetRefNo AS Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #PurchaseReturn SI
				INNER JOIN #PurchaseReturnProductTax ST ON ST.PurRetId=SI.PurRetId AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId		
			UNION ALL	
  			---Service Invoice
				SELECT 4 AS BTYPE,SI.Salinvno AS Salinvno,SI.RowNo as Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
				FROM #ServiceData SI
				INNER JOIN #ServiceInvoiceTaxDetails ST ON ST.ServiceInvId=SI.Salid AND ST.RowNo=SI.RowNo
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL
				SELECT 4 AS BTYPE,SI.Salinvno AS Salinvno,SI.RowNo as Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #ServiceData SI
				INNER JOIN #ServiceInvoiceTaxDetails ST ON ST.ServiceInvId=SI.Salid AND ST.RowNo=SI.RowNo
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId			
  			)A
 			ORDER BY BTYPE 
 			SELECT BTYPE,Salinvno,Prdslno,SUM([OutputCGSTPerc])[OutputCGSTPerc],
				SUM([OutputCGST_Amt])[OutputCGST_Amt],SUM([OutputSGSTPerc])[OutputSGSTPerc],SUM([OutputSGST_Amt])[OutputSGST_Amt],
				SUM([OutputIGSTPerc])[OutputIGSTPerc],SUM([OutputIGST_Amt])[OutputIGST_Amt],SUM([OutputUTGSTPerc])[OutputUTGSTPerc],
				SUM([OutputUTGST_Amt])[OutputUTGST_Amt]
			INTO #TAXDETAILS
			FROM(
			SELECT BTYPE,Salinvno,Prdslno,
			ISNULL([OutputCGSTPerc],0)[OutputCGSTPerc],ISNULL([OutputCGST_Amt],0)[OutputCGST_Amt],
			ISNULL([OutputSGSTPerc],0)[OutputSGSTPerc],ISNULL([OutputSGST_Amt],0)[OutputSGST_Amt],
			ISNULL([OutputIGSTPerc],0)[OutputIGSTPerc],ISNULL([OutputIGST_Amt],0)[OutputIGST_Amt],
			ISNULL([OutputUTGSTPerc],0)[OutputUTGSTPerc],ISNULL([OutputUTGST_Amt],0)[OutputUTGST_Amt]
			FROM (
			SELECT BTYPE,Salinvno,Prdslno,TaxCode,TaxPercAmt
			FROM #TAXPIVOT) up
			PIVOT (SUM(TaxPercAmt) FOR TaxCode IN ([OutputCGST_Amt],[OutputCGSTPerc],
													[OutputSGST_Amt],[OutputSGSTPerc],
													[OutputIGST_Amt],[OutputIGSTPerc],
													[OutputUTGST_Amt],[OutputUTGSTPerc]))  AS PVT 
			)A
			GROUP BY BTYPE,Salinvno,Prdslno 		
 		INSERT INTO #RptGSTR1_B2B(TransId,TranType,Refid ,RtrShipId,RtrId,RtrCode,RtrName,
			[GSTIN/UIN of Recipient],[Retailer Type],[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],
			[Reverse Charge],[Invoice Type],[Kind of transaction],[Identifier if Goods or Services],[E-Commerce GSTIN],
			[Rate],[Taxable Value],[Cess Amount],[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],
			[SGST/UTGST amount],UsrId,[Group Name],GroupType)
		SELECT 1,'Sales',S.Salid,S.RtrShipId,R.RtrId,RtrCode,RtrName,'' as GSTTin,ISNULL(ColumnValue,'') as RetailerType,S.SalInvNo,Salinvdate, OrgNetAmount as SalesValue,'' as PlaceOfSupply,
			  'N' as ReverseCharge,'Regular' as InvoiceType,'Sale of goods' as Kind,'Goods' as Goods ,'' as [E-Commerce],Taxperc,SUM(TaxableAmount) as TaxableAmount,
			   0.00 as CessAmount,[OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			   ([OutputSGSTPerc]+[OutputUTGSTPerc]),SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM #Sales S INNER JOIN Retailer R (NOLOCK) ON R.RtrId=S.RtrId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.SalInvNo AND T.PrdSlNo=S.PrdSlNo AND T.BTYPE=1
		LEFT OUTER JOIN #RetailerRegister Rr ON Rr.RtrId=S.RtrId
		GROUP BY 
			S.Salid,R.RtrId,RtrCode,RtrName,S.Salinvno,Salinvdate,Taxperc,S.RtrShipId,OrgNetAmount,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc],ColumnValue
		UNION ALL
		SELECT 2,'IDT',0 as Salid,0 as RtrShipId,R.SpmId as RtrId,SpmCode as RtrCode,SpmName as RtrName,'' as GSTTin,'Registered' as RetailerType,
		S.IDTMngRefNo as Salinvno,IDTMngDate as Salinvdate,IDTNetAmt as SalesValue,'' as PlaceOfSupply,
		'N' as ReverseCharge,'Regular' as InvoiceType,'Sale of goods' as Kind,'Goods' as Goods ,'' as [E-Commerce],Taxperc,
		SUM(TaxableAmount) as TaxableAmount,0.00 as CessAmount,[OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			   ([OutputSGSTPerc]+[OutputUTGSTPerc]),SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM #IDTSales S INNER JOIN IDTMaster R (NOLOCK) ON R.SpmId=S.ToSpmId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.IDTMngRefNo AND T.PrdSlNo=S.PrdSlNo AND T.BTYPE=2
		GROUP BY 
			R.SpmId,SpmCode,SpmName,S.IDTMngRefNo,IDTMngDate,Taxperc,IDTNetAmt,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
		UNION ALL
		SELECT 3,'PurchaseReturn',S.PurRetId as Salid,0 as RtrShipId,R.SpmId as RtrId,SpmCode as RtrCode,
		SpmName as RtrName,'' as GSTTin,'Registered' as RetailerType,S.PurRetRefNo as Salinvno,PurRetDate as Salinvdate,NetAmount as SalesValue,
		'' as PlaceOfSupply,'N' as ReverseCharge,'Regular' as InvoiceType,'Sale of goods' as Kind,'Goods' as Goods ,
		'' as [E-Commerce],Taxperc,SUM(TaxableAmount) as TaxableAmount,0.00 as CessAmount,[OutputIGSTPerc],
		SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			   ([OutputSGSTPerc]+[OutputUTGSTPerc]),SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM #PurchaseReturn S 	INNER JOIN Supplier R (NOLOCK) ON R.SpmId=S.SpmId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.PurRetRefNo AND T.PrdSlNo=S.PrdSlNo AND T.BTYPE=3
		GROUP BY 
		R.SpmId,SpmCode,SpmName,S.PurRetRefNo,PurRetDate,Taxperc,S.PurRetId,NetAmount,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
		UNION ALL
		SELECT 4,'Service',S.Salid as Salid,0 as RtrShipId,S.ServiceToId as RtrId,SpmCode as RtrCode,
		SpmName as RtrName,'' as GSTTin,'Registered' as RetailerType,
		S.Salinvno as Salinvno,SalInvdate as Salinvdate,AppTotalAmount as SalesValue,'' as PlaceOfSupply,
		'N' as ReverseCharge,'Regular' as InvoiceType,'Sale of service' as Kind,
		'Services' as Goods,'' as [E-Commerce],Taxperc,SUM(TaxableAmount) as TaxableAmount,0.00 as CessAmount,
		[OutputIGSTPerc] as [OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc] as [OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
	   ([OutputSGSTPerc]+[OutputUTGSTPerc]) as [OutputSGSTPerc], SUM([OutputSGST_Amt]+[OutputUTGST_Amt]) AS [OutputSGST_Amt],
		@Pi_UsrId,'' as [Group Type],2
		FROM #ServiceData S INNER JOIN Supplier R (NOLOCK) ON R.SpmId=S.ServiceToId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.SalInvNo AND T.PrdSlNo=S.RowNo AND T.BTYPE=4
		GROUP BY S.ServiceToId,SpmCode,SpmName,S.Salinvno,SalInvdate,Taxperc,S.Salid,AppTotalAmount,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
		
		 
		UPDATE B Set B.[Place Of Supply]=A.StateName FROM #RetailerState A INNER JOIN #RptGSTR1_B2B B ON A.Rtrid=B.RtrId
		WHERE B.TransId=1
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=GSTTinNo FROM #RptGSTR1_B2B R INNER JOIN RetailerShipAdd RS ON RS.RtrShipId=R.RtrShipId
		and R.TransId=1
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=ColumnValue FROM #RptGSTR1_B2B R INNER JOIN #RetailerGSTIN RS ON RS.RtrId=R.RtrId
		WHERE LEN(ISNULL(R.[GSTIN/UIN of Recipient],''))=0 and R.TransId=1
		
		DELETE A FROM #RptGSTR1_B2B A WHERE NOT EXISTS(SELECT RtrId FROM #RetailerRegister B WHERE A.RtrId=B.RtrId)
		and TransId=1
		
		UPDATE B Set B.[Place Of Supply]=A.StateName FROM #SupplierState A INNER JOIN #RptGSTR1_B2B B ON A.RtrId=B.RtrId
		WHERE B.TransId IN(3,4)
	
		
		UPDATE B Set B.[Place Of Supply]=A.StateName FROM #IDTSupplierState A INNER JOIN #RptGSTR1_B2B B ON A.Rtrid=B.RtrId
		WHERE B.TransId=2
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=ColumnValue FROM #RptGSTR1_B2B R INNER JOIN #SupplierGSTIN RS ON RS.RtrId=R.RtrId
		WHERE  R.TransId IN(3,4)
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=ColumnValue FROM #RptGSTR1_B2B R INNER JOIN #IDTSupplierGSTIN RS ON RS.RtrId=R.RtrId
		WHERE  R.TransId=2
		
	 --select * from #RptGSTR1_B2B
		
		
			
		IF NOT EXISTS(SELECT 'X' FROM #RptGSTR1_B2B)
		BEGIN
			INSERT INTO RptGSTR1_B2B([GSTIN/UIN of Recipient],[Recipient Code in application],[Recipient Name],[Recipient Type]
			,[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],[Reverse Charge],[Invoice Type],[Kind of transaction],
			[Identifier if Goods or Services],[E-Commerce GSTIN],[Rate],[Taxable Value],[Cess Amount],
			[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType)
			SELECT '' as [GSTIN/UIN of Recipient],'' as [Recipient Code in application],'' as [Recipient Name],'' as[Recipient Type],
			'' as [Invoice Number],'' as [Invoice date],0,'' as [Place Of Supply],'' as [Reverse Charge],'' as [Invoice Type],'' as [Kind of transaction],	
			'' as [Identifier if Goods or Services],'' as [E-Commerce GSTIN],0.00 as [Rate],SUM([Taxable Value]),SUM([Cess Amount]),
			0 as [IGST rate],SUM([IGST amount]),0 as [CGST rate],SUM([CGST amount]),0 as [SGST/UTGST rate],SUM([SGST/UTGST amount]),
			@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
			FROM #RptGSTR1_B2B		
			SELECT * FROM RptGSTR1_B2B (NOLOCK) WHERE UsrId=@Pi_UsrId
			
			DELETE FROM RptGSTR1_B2B WHERE UsrId=@Pi_UsrId			
			
			RETURN
		END
		
		INSERT INTO RptGSTR1_B2B([GSTIN/UIN of Recipient],[Recipient Code in application],[Recipient Name],[Recipient Type]
		,[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],[Reverse Charge],[Invoice Type],[Kind of transaction],
		[Identifier if Goods or Services],[E-Commerce GSTIN],[Rate],[Taxable Value],[Cess Amount],
		[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType)		
		SELECT [GSTIN/UIN of Recipient],RtrCode,rtrname,[Retailer Type],[Invoice Number],
		REPLACE(REPLACE(CONVERT(VARCHAR,[Invoice date],106), ' ','-'), ',',''),[Invoice Value],[Place Of Supply],
		[Reverse Charge],[Invoice Type],[Kind of transaction],[Identifier if Goods or Services]	,[E-Commerce GSTIN],[Rate],[Taxable Value],
		[Cess Amount],[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType
		FROM #RptGSTR1_B2B 
		ORDER BY TransId,[GSTIN/UIN of Recipient],[Invoice date],[Invoice Number]
		
		SELECT DISTINCT TransId,[Invoice Number],[Invoice Value]
		INTO #GrandTotal
		FROM #RptGSTR1_B2B
		
		
		INSERT INTO RptGSTR1_B2B([GSTIN/UIN of Recipient],[Recipient Code in application],[Recipient Name],[Recipient Type]
		,[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],[Reverse Charge],[Invoice Type],[Kind of transaction],
		[Identifier if Goods or Services],[E-Commerce GSTIN],[Rate],[Taxable Value],[Cess Amount],
		[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType)
		SELECT '' as [GSTIN/UIN of Recipient],'' as [Recipient Code in application],'' as [Recipient Name],'' as[Recipient Type],
		'' as [Invoice Number],'' as [Invoice date],0,'' as [Place Of Supply],'' as [Reverse Charge],'' as [Invoice Type],'' as [Kind of transaction],	
		'' as [Identifier if Goods or Services],'' as [E-Commerce GSTIN],0.00 as [Rate],SUM([Taxable Value]),SUM([Cess Amount]),
		0 as [IGST rate],SUM([IGST amount]),0 as [CGST rate],SUM([CGST amount]),0 as [SGST/UTGST rate],SUM([SGST/UTGST amount]),
		@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
		FROM #RptGSTR1_B2B
		
		UPDATE RptGSTR1_B2B SET [Invoice Value]=(SELECT SUM([Invoice Value]) FROM #GrandTotal) WHERE GroupType=3
		
		
		SELECT * FROM RptGSTR1_B2B WHERE UsrId=@Pi_UsrId
				
END
GO
IF EXISTS (SELECT  * FROM SYS.OBJECTS WHERE TYPE='P' AND NAME='Proc_RptGSTR2Extract')
DROP  PROCEDURE Proc_RptGSTR2Extract
GO
/*
BEGIN tran
EXEC Proc_RptGSTR2Extract 424,1,0,'GSTTAX',0,0,1
Select * from RptInputtaxCreditGST
ROLLBACK tran 
*/
CREATE PROCEDURE [Proc_RptGSTR2Extract]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptGSTR2Extract
* PURPOSE	: GSTR2 Extract
* CREATED	: Murugan.R
* CREATED DATE	: 06/09/2017
* MODIFIED
*************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID		DESCRIPTION					
*************************************************
06/09/2017	Murugan.R	CR		CCRSTAN0150			GSTR2 Summary Report
11-01-2018	Mohana S    BZ		ICRSTLOR2374		GSTR2 Report - REFRESH ISSUE FIX
*/
BEGIN
SET NOCOUNT ON
		
	--DELETE FROM  ReportFilterDt WHERE RptId IN(425,426,427,428,429,430) 
	--INSERT INTO ReportFilterDt(RptId,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate)
	--SELECT 425,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 426,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 427,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 428,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	--UNION ALL
	--SELECT 429,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId	
	--UNION ALL
	--SELECT 430,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	--FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId

	
	DELETE FROM Report_txt_PageHeader_GST WHERE RptId IN(425,426,427,428,429,430)
	INSERT INTO Report_txt_PageHeader_GST(ColId,RptId,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId)
	SELECT ColId,425,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,426,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,427,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,428,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,429,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,430,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	
	
	--EXEC Proc_RptGSTR2_B2B 425 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId	
	--EXEC Proc_RptGSTR2_B2BUR 426 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--EXEC Proc_RptGSTR2_HSNSUM 427 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--EXEC Proc_RptGSTR2_NILRATE 428 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	--EXEC Proc_RptGSTR2_CDN 429 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId	
	--EXEC Proc_RptGSTR2_Summary 430,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
			
	
	SELECT * FROM  RptGSTR2_HSNSUM WHERE UsrId=@Pi_UsrId
END
GO
IF EXISTS(SELECT 'X' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptGSTR2_B2B')
DROP PROCEDURE Proc_RptGSTR2_B2B
GO
--EXEC Proc_RptGSTR2_B2B 225,2,0,'',0,0,1
CREATE PROCEDURE [Proc_RptGSTR2_B2B]
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
/************************************************
* PROCEDURE  : Proc_RptGSTR2_B2B
* PURPOSE    : To Generate GSTR2 B2B Report
* CREATED BY : Murugan.R
* CREATED ON : 17/08/2017
* MODIFICATION
*************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID		DESCRIPTION					
*************************************************
05/09/2017	Murugan.R	CR		CCRSTPAR0167		GSTR2-B2B
11-01-2018	  MOHANA	  BZ			ICRSTLOR2374		GSTR1 Report - REFRESH ISSUE FIX
*/
BEGIN
SET NOCOUNT ON
		
		DECLARE @MonthStart INT
		DECLARE @ReturnPeriod Varchar(20)
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		DECLARE @CmpId AS INT
		
		TRUNCATE TABLE RptGSTR2_B2B
		--ICRSTLOR2374
		DELETE FROM  ReportFilterDt WHERE RptId IN(425,426,427,428,429,430) 
		INSERT INTO ReportFilterDt(RptId,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate)
		SELECT 425,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=431 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 426,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=431 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 427,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=431 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 428,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=431 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 429,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=431 AND UsrId=@Pi_UsrId	
		UNION ALL
		SELECT 430,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=431 AND UsrId=@Pi_UsrId
		--ICRSTLOR2374
		
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		--SET @MonthStart=8
		--SET @Jcmyear=2017
		
		IF LEN(@MonthStart)=1 
		BEGIN
		 SET @ReturnPeriod='0'+Cast(@MonthStart as Varchar(5))+CAST(@Jcmyear as varchar(5))
		END
		ELSE
		BEGIN
		 SET @ReturnPeriod=Cast(@MonthStart as Varchar(5))+CAST(@Jcmyear as varchar(5))
		END 
--	GROUP BY PrdSlNo ORDER BY  SUM(TaxPerc)
	
	
		CREATE TABLE #RptGSTR2_B2B
		(
		TRANSID	TINYINT	,
		SpmId	INT,
		[Your GSTIN]	Varchar(50),
		[Return Period]	Varchar(20),
		[GSTIN of Supplier]	Varchar(50),
		[Refid] BIGINT,		
		[Invoice Num]	Varchar(50),
		[Invoice Date]	DateTime,
		[Invoice Value]	Numeric(32,6),
		[Place of supply]	Varchar(50),
		[Invoice type]	Varchar(10),
		[Serial no]	INT,
		[Tax Rate]	Numeric(10,2),
		[Taxable value]	Numeric(32,6),
		[IGST]	Numeric(32,6),
		[CGST]	Numeric(32,6),
		[SGST]	Numeric(32,6),
		[CESS]	Numeric(32,6),
		[ITC IGST Amt]	Numeric(32,6),
		[ITC CGST Amt]	Numeric(32,6),
		[ITC SGST Amt]	Numeric(32,6),
		[ITC Cess Amt]	Numeric(32,6),
		[Eligibility]	Varchar(10),
		[Reverse Charge]	Varchar(10)
		)	
	
		DECLARE @DistGSTIN VARCHAR(50)
		--Distributor GSTIN
		SELECT @DistGSTIN=UT.ColumnValue
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Distributor R ON R.DistributorId=UT.MasterRecordId
		WHERE U.MasterId=16 and ColumnName='GSTIN'
		--Supplier GSTIN
		SELECT DISTINCT  SpmId as SpmID ,UT.ColumnValue
		INTO #SupplierGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Supplier R ON R.SpmId=UT.MasterRecordId
		WHERE U.MasterId=8 and ColumnName='GSTIN'
		----IDT GSTIN
		SELECT DISTINCT  SpmId as SpmID ,UT.ColumnValue
		INTO #IDTSupplierGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN IDTMaster R ON R.SpmId=UT.MasterRecordId
		WHERE U.MasterId=8 and ColumnName='GSTIN'
		--Retailer GSTIN
		SELECT DISTINCT  Rtrid as Rtrid ,UT.ColumnValue
		INTO #RetailerGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.Rtrid=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='GSTIN'
		
		--Retailer Registered
		SELECT DISTINCT  Rtrid as Rtrid ,UT.ColumnValue
		INTO #RetailerRegistered
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.Rtrid=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='Retailer Type' and UT.ColumnValue='Registered'
		
		--Retailer State
		SELECT DISTINCT  Rtrid as Rtrid,StateId,StateCode,StateName,TinFirst2Digit,StateType
		INTO #RetailerState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.Rtrid=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=2 and ColumnName='State Name' 
		
		--Supplier State
		SELECT DISTINCT  Spmid as Spmid,StateId,StateCode,StateName,TinFirst2Digit,StateType
		INTO #SupplierState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Supplier R ON R.SpmId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=8 and ColumnName='State Name' 
		
		----IDT State
		SELECT DISTINCT  Spmid as Spmid,StateId,StateCode,StateName,TinFirst2Digit,StateType
		INTO #IDTState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN IDTMaster R ON R.SpmId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=8 and ColumnName='State Name' 
	
	
		SELECT Salid INTO #Sales  FROM Salesinvoice (NOLOCK)		
		WHERE Dlvsts>3 and Salinvdate between '2017-01-01' and '2017-06-30' and VatGst='VAT'
	
		SELECT SpmId,X.PurRcptId,CmpInvNo,InvDate,X.Prdslno,CAST( 0.00 as Numeric(36,6)) as PrdNetAmount, SUM(Taxperc) as Taxperc,
		SUM(DISTINCT TaxableAmount) as TaxableAmount,
		SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,
		SUM(SGSTUTGSTTaxAmount) as SGSTUTGSTTaxAmount,
		SUM(CESSTaxAmount) as CESSTaxAmount
		INTO #Pruchase
		FROM(
				SELECT SpmId,S.PurRcptId,CmpInvNo,InvDate,Prdslno,SUM(TaxPerc) as Taxperc,
				SUM(DISTINCT ST.TaxableAmount) as TaxableAmount,
				ISNULL(CASE  WHEN TaxCode IN('InputIGST','IGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS IGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('InputCGST','CGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS CGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('InputSGST','InputUTGST','SGST','UTGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS SGSTUTGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('InputGSTCess') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS CESSTaxAmount
				FROM PurchaseReceipt S (NOLOCK) 
				INNER JOIN PurchaseReceiptProductTax ST (NOLOCK) ON S.PurRcptId=ST.PurRcptId
				INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
				WHERE Status=1 and Month(InvDate)=@MonthStart and Year(InvDate)=@Jcmyear and VatGST='GST'
				and TaxCode IN('InputIGST','InputCGST','InputSGST','InputUTGST','IGST','CGST','SGST','UTGST','InputGSTCess')
				and ST.TaxableAmount>0 --and S.PurRcptId IN(913,914,915)
				GROUP BY S.PurRcptId,CmpInvNo,InvDate,Prdslno,ST.TaxableAmount,TaxCode,SpmId
			)	X 
			GROUP BY X.PurRcptId,CmpInvNo,InvDate,X.Prdslno,TaxableAmount,SpmId
			ORDER BY X.Prdslno
			
			

			SELECT S.PurRcptId,SUM(PrdNetAmount) as PrdNetAmount
			INTO #PurchaseReceiptProduct
			FROM PurchaseReceipt S (NOLOCK) 
			INNER JOIN PurchaseReceiptProduct ST (NOLOCK) ON S.PurRcptId=ST.PurRcptId
			WHERE Status=1 and Month(InvDate)=@MonthStart and Year(InvDate)=@Jcmyear and VatGST='GST'
			GROUP BY S.PurRcptId
			
			UPDATE A Set A.PrdNetAmount =B.PrdNetAmount FROM #Pruchase A INNER JOIN #PurchaseReceiptProduct B
			ON A.PurRcptId=B.PurRcptId
			
			
			---Sales Return
		
			SELECT RtrId,X.ReturnID,ReturnCode,ReturnDate,X.Prdslno,CAST( 0.00 as Numeric(36,6)) as PrdNetAmount, SUM(Taxperc) as Taxperc,
			SUM(DISTINCT TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTGSTTaxAmount) as SGSTUTGSTTaxAmount,
			SUM(CESSTaxAmount) as CESSTaxAmount
			INTO #SalesReturn
			FROM(
				SELECT R.Rtrid,S.ReturnID,ReturnCode,ReturnDate,Prdslno,SUM(TaxPerc) as Taxperc,
				SUM(DISTINCT ST.TaxableAmt) as TaxableAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputIGST','IGST') THEN SUM(ST.TaxAmt) ELSE 0 END,0) AS IGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputCGST','CGST') THEN SUM(ST.TaxAmt) ELSE 0 END,0) AS CGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(ST.TaxAmt) ELSE 0 END,0) AS SGSTUTGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutPutGSTCess') THEN SUM(ST.TaxAmt) ELSE 0 END,0) AS CESSTaxAmount
				FROM ReturnHeader S (NOLOCK) 
				INNER JOIN ReturnProductTax ST (NOLOCK) ON S.ReturnID=ST.ReturnID
				INNER JOIN #RetailerRegistered R ON R.Rtrid=S.RtrId
				INNER JOIN #Sales C ON C.SalId=S.SalId
				INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
				WHERE Status=0 and Month(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear --and VatGST='GST'
				and TaxCode IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST',
				'InputCGST','InputSGST','InputIGST','InputUTGST','InputGSTCess')
				and ST.TaxableAmt>0 --and S.PurRcptId IN(913,914,915)
				GROUP BY S.ReturnID,ReturnCode,ReturnDate,Prdslno,TaxCode,R.Rtrid
			)	X 
			GROUP BY X.ReturnID,ReturnCode,ReturnDate,X.Prdslno,RtrId
			ORDER BY X.Prdslno	
			
			
			SELECT S.ReturnID,SUM(PrdNetAmt) as PrdNetAmount
			INTO #SalesReturnProduct
			FROM ReturnHeader S (NOLOCK) 
			INNER JOIN ReturnProduct ST (NOLOCK) ON S.ReturnID=ST.ReturnID
			WHERE Status=0 and Month(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear --and VatGST='GST'
			GROUP BY S.ReturnID
			
			UPDATE A Set A.PrdNetAmount =B.PrdNetAmount FROM #SalesReturn A INNER JOIN #SalesReturnProduct B
			ON A.ReturnID=B.ReturnID
			
			-----IDT IN
			
			SELECT FromSpmId,IDTMngRefNo,IDTMngDate,X.Prdslno,CAST( 0.00 as Numeric(36,6)) as PrdNetAmount, SUM(Taxperc) as Taxperc,
			SUM(DISTINCT TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTGSTTaxAmount) as SGSTUTGSTTaxAmount,
			SUM(CESSTaxAmount) as CESSTaxAmount
			INTO #IDTIN
			FROM(
				SELECT FromSpmId,S.IDTMngRefNo,IDTMngDate,Prdslno,SUM(TaxPerc) as Taxperc,
				SUM(DISTINCT ST.TaxableAmount) as TaxableAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputIGST','IGST','InputIGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS IGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputCGST','CGST','InputCGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS CGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST','InputSGST','InputUTGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS SGSTUTGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutPutGSTCess','InputGSTCess') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS CESSTaxAmount
				FROM IDTManagement S (NOLOCK) 
				INNER JOIN IDTManagementProductTax ST (NOLOCK) ON S.IDTMngRefNo=ST.IDTMngRefNo
				INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
				WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear --and VatGST='GST'
				and StkMgmtTypeId=1
				and TaxCode IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST',
				'InputCGST','InputSGST','InputIGST','InputUTGST','InputGSTCess')
				and ST.TaxableAmount>0 --and S.PurRcptId IN(913,914,915)
				GROUP BY S.IDTMngRefNo,IDTMngDate,Prdslno,TaxCode,FromSpmId
			)	X 
			GROUP BY IDTMngRefNo,IDTMngDate,X.Prdslno,FromSpmId
			ORDER BY X.Prdslno	
			
			
			SELECT S.IDTMngRefNo,SUM(PrdNetAmount) as PrdNetAmount
			INTO #IDTProduct
			FROM IDTManagement S (NOLOCK) 
			INNER JOIN IDTManagementProduct ST (NOLOCK) ON S.IDTMngRefNo=ST.IDTMngRefNo
			WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear --and VatGST='GST'
			GROUP BY S.IDTMngRefNo
			
			UPDATE A Set A.PrdNetAmount =B.PrdNetAmount FROM #IDTIN A INNER JOIN #IDTProduct B
			ON A.IDTMngRefNo=B.IDTMngRefNo
			
			---Service Invoice
			SELECT ServiceFromId,X.ServiceInvId,X.ServiceInvRefNo,ServiceInvDate,X.RowNo,CAST( 0.00 as Numeric(36,6)) as PrdNetAmount, SUM(Taxperc) as Taxperc,
			SUM(DISTINCT TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTGSTTaxAmount) as SGSTUTGSTTaxAmount,
			SUM(CESSTaxAmount) as CESSTaxAmount
			INTO #ServiceRetailer
			FROM(
				SELECT ServiceFromId,S.ServiceInvId,S.ServiceInvRefNo,ServiceInvDate,RowNo,SUM(TaxPerc) as Taxperc,
				SUM(DISTINCT ST.TaxableAmount) as TaxableAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputIGST','IGST','InputIGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS IGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputCGST','CGST','InputCGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS CGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST','InputSGST','InputUTGST') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS SGSTUTGSTTaxAmount,
				ISNULL(CASE  WHEN TaxCode IN('OutPutGSTCess','InputGSTCess') THEN SUM(ST.TaxAmount) ELSE 0 END,0) AS CESSTaxAmount
				FROM ServiceInvoiceHd S (NOLOCK) 
				INNER JOIN ServiceInvoiceTaxDetails ST (NOLOCK) ON S.ServiceInvId=ST.ServiceInvId
				INNER JOIN #RetailerRegistered R ON R.Rtrid=S.ServiceFromId
				INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
				WHERE  Month(ServiceInvDate)=@MonthStart and Year(ServiceInvDate)=@Jcmyear --and VatGST='GST'
				and ServiceInvFor=1
				and TaxCode IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST',
				'InputCGST','InputSGST','InputIGST','InputUTGST','InputGSTCess')
				and ST.TaxableAmount>0 --and S.PurRcptId IN(913,914,915)
				--and ReverseCharges=0
				GROUP BY S.ServiceInvId,S.ServiceInvRefNo,ServiceInvDate,RowNo,TaxCode,ServiceFromId
			)	X 
			GROUP BY X.ServiceInvId,X.ServiceInvRefNo,ServiceInvDate,X.RowNo,ServiceFromId
			ORDER BY X.RowNo
			
			SELECT S.ServiceInvId,SUM(TotServiceAmount) as PrdNetAmount
			INTO #ServiceLineAmt
			FROM ServiceInvoiceHd S (NOLOCK) 
			INNER JOIN ServiceInvoiceDT ST (NOLOCK) ON S.ServiceInvId=ST.ServiceInvId
			WHERE Month(ServiceInvDate)=@MonthStart and Year(ServiceInvDate)=@Jcmyear --and VatGST='GST'
			--and ReverseCharges=0
			GROUP BY S.ServiceInvId
			
			UPDATE A Set A.PrdNetAmount =B.PrdNetAmount FROM #ServiceRetailer A INNER JOIN #ServiceLineAmt B
			ON A.ServiceInvId=B.ServiceInvId
			
			
			----Purchase
			INSERT INTO #RptGSTR2_B2B(TRANSID,SpmId,		
			[Your GSTIN],[Return Period],[GSTIN of Supplier],[Refid],[Invoice Num],[Invoice Date],
			[Invoice Value],[Place of supply],[Invoice type],[Serial no],[Tax Rate],[Taxable value],
			[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],[Eligibility],[Reverse Charge])	
			SELECT 1 AS TRANSID,SpmId,@DistGSTIN as [Your GSTIN],'' as [Return Period],'' as [GSTIN of Supplier],X.PurRcptId,CmpInvNo,InvDate,
			PrdNetAmount as [Invoice Value],'' as [Place of supply],'R' as [Invoice type],
			Row_Number() OVER(Partition by X.PurRcptId ORDER BY Taxperc,X.PurRcptId ) as [Serial no] ,Taxperc as [Tax Rate],
			SUM(X.TaxableAmount) as [Taxable value],
			SUM(IGSTTaxAmount) as [IGST],
			SUM(CGSTTaxAmount) as [CGST],
			SUM(SGSTUTGSTTaxAmount) as [SGST],
			SUM(CESSTaxAmount) as [CESS],		
			SUM(IGSTTaxAmount) as [ITC IGST Amt],
			SUM(CGSTTaxAmount) as [ITC CGST Amt],
			SUM(SGSTUTGSTTaxAmount) as [ITC SGST Amt],
			SUM(CESSTaxAmount) as [ITC Cess Amt],
			'IP' as [Eligibility],'N' as [Reverse Charge]
			FROM #Pruchase X 
			GROUP BY Taxperc,X.PurRcptId,CmpInvNo,InvDate,SpmId,PrdNetAmount
		---Sales Return
			INSERT INTO #RptGSTR2_B2B(TRANSID,SpmId,		
			[Your GSTIN],[Return Period],[GSTIN of Supplier],[Refid],[Invoice Num],[Invoice Date],
			[Invoice Value],[Place of supply],[Invoice type],[Serial no],[Tax Rate],[Taxable value],
			[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],[Eligibility],[Reverse Charge])	
			SELECT 2 AS TRANSID,RtrId,@DistGSTIN as [Your GSTIN],'' as [Return Period],'' as [GSTIN of Supplier],ReturnID,ReturnCode,ReturnDate,
			(PrdNetAmount) as [Invoice Value],'' as [Place of supply],'R' as [Invoice type],
			Row_Number() OVER(Partition by ReturnID ORDER BY Taxperc,ReturnID ) as [Serial no] ,Taxperc as [Tax Rate],
			SUM(TaxableAmount) as [Taxable value],
			SUM(IGSTTaxAmount) as [IGST],
			SUM(CGSTTaxAmount) as [CGST],
			SUM(SGSTUTGSTTaxAmount) as [SGST],
			SUM(CESSTaxAmount) as [CESS],		
			SUM(IGSTTaxAmount) as [ITC IGST Amt],
			SUM(CGSTTaxAmount) as [ITC CGST Amt],
			SUM(SGSTUTGSTTaxAmount) as [ITC SGST Amt],
			SUM(CESSTaxAmount) as [ITC Cess Amt],
			'IP' as [Eligibility],'N' as [Reverse Charge]
			FROM #SalesReturn
			GROUP BY Taxperc,ReturnID,ReturnCode,ReturnDate,RtrId,PrdNetAmount
		-----IDT IN	
			INSERT INTO #RptGSTR2_B2B(TRANSID,SpmId,		
			[Your GSTIN],[Return Period],[GSTIN of Supplier],[Refid],[Invoice Num],[Invoice Date],
			[Invoice Value],[Place of supply],[Invoice type],[Serial no],[Tax Rate],[Taxable value],
			[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],[Eligibility],[Reverse Charge])	
			SELECT 3 AS TRANSID,FromSpmId,@DistGSTIN as [Your GSTIN],'' as [Return Period],'' as [GSTIN of Supplier],0,IDTMngRefNo,IDTMngDate,
			(PrdNetAmount) as [Invoice Value],'' as [Place of supply],'R' as [Invoice type],
			Row_Number() OVER(Partition by IDTMngRefNo ORDER BY Taxperc,IDTMngRefNo ) as [Serial no] ,Taxperc as [Tax Rate],
			SUM(TaxableAmount) as [Taxable value],
			SUM(IGSTTaxAmount) as [IGST],
			SUM(CGSTTaxAmount) as [CGST],
			SUM(SGSTUTGSTTaxAmount) as [SGST],
			SUM(CESSTaxAmount) as [CESS],		
			SUM(IGSTTaxAmount) as [ITC IGST Amt],
			SUM(CGSTTaxAmount) as [ITC CGST Amt],
			SUM(SGSTUTGSTTaxAmount) as [ITC SGST Amt],
			SUM(CESSTaxAmount) as [ITC Cess Amt],
			'IP' as [Eligibility],'N' as [Reverse Charge]
			FROM #IDTIN
			GROUP BY Taxperc,IDTMngRefNo,IDTMngDate,FromSpmId,PrdNetAmount
			
		-----Service Invoice Retailer		
			INSERT INTO #RptGSTR2_B2B(TRANSID,SpmId,		
			[Your GSTIN],[Return Period],[GSTIN of Supplier],[Refid],[Invoice Num],[Invoice Date],
			[Invoice Value],[Place of supply],[Invoice type],[Serial no],[Tax Rate],[Taxable value],
			[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],[Eligibility],[Reverse Charge])	
			SELECT 4 AS TRANSID,ServiceFromId,@DistGSTIN as [Your GSTIN],'' as [Return Period],'' as [GSTIN of Supplier],ServiceInvId,ServiceInvRefNo,ServiceInvDate,
			(PrdNetAmount) as [Invoice Value],'' as [Place of supply],'R' as [Invoice type],
			Row_Number() OVER(Partition by ServiceInvId ORDER BY Taxperc,ServiceInvId ) as [Serial no] ,Taxperc as [Tax Rate],
			SUM(TaxableAmount) as [Taxable value],
			SUM(IGSTTaxAmount) as [IGST],
			SUM(CGSTTaxAmount) as [CGST],
			SUM(SGSTUTGSTTaxAmount) as [SGST],
			SUM(CESSTaxAmount) as [CESS],		
			SUM(IGSTTaxAmount) as [ITC IGST Amt],
			SUM(CGSTTaxAmount) as [ITC CGST Amt],
			SUM(SGSTUTGSTTaxAmount) as [ITC SGST Amt],
			SUM(CESSTaxAmount) as [ITC Cess Amt],
			'IP' as [Eligibility],'N' as [Reverse Charge]
			FROM #ServiceRetailer
			GROUP BY Taxperc,ServiceInvRefNo,ServiceInvDate,ServiceFromId,ServiceInvId,PrdNetAmount	
			
			--GSTIN
			UPDATE A SET A.[GSTIN of Supplier] = B.ColumnValue 
			FROM #RptGSTR2_B2B A INNER JOIN #SupplierGSTIN B ON A.SpmId=B.SpmId 
			WHERE TransId=1
			
			UPDATE A SET A.[GSTIN of Supplier] = B.ColumnValue 
			FROM #RptGSTR2_B2B A INNER JOIN #RetailerGSTIN B ON A.SpmId=B.Rtrid 
			WHERE TransId=2
			
			UPDATE A SET A.[GSTIN of Supplier] = B.ColumnValue 
			FROM #RptGSTR2_B2B A INNER JOIN #IDTSupplierGSTIN B ON A.SpmId=B.SpmId 
			WHERE TransId=3
			
			UPDATE A SET A.[GSTIN of Supplier] = B.ColumnValue 
			FROM #RptGSTR2_B2B A INNER JOIN #RetailerGSTIN B ON A.SpmId=B.Rtrid 
			WHERE TransId=4
			--Place Of Supply
			UPDATE A SET A.[Place of supply] = B.TinFirst2Digit 
			FROM #RptGSTR2_B2B A INNER JOIN #SupplierState B ON A.SpmId=B.SpmId 
			WHERE TransId=1
			
			UPDATE A SET A.[Place of supply] = B.TinFirst2Digit 
			FROM #RptGSTR2_B2B A INNER JOIN #RetailerState B ON A.SpmId=B.Rtrid 
			WHERE TransId=2
			
			UPDATE A SET A.[Place of supply] = B.TinFirst2Digit 
			FROM #RptGSTR2_B2B A INNER JOIN #IDTState B ON A.SpmId=B.SpmId 
			WHERE TransId=3
			
			UPDATE A SET A.[Place of supply] = B.TinFirst2Digit 
			FROM #RptGSTR2_B2B A INNER JOIN #RetailerState B ON A.SpmId=B.Rtrid 
			WHERE TransId=4
		
		
		IF NOT EXISTS(SELECT 'X' FROM #RptGSTR2_B2B)
		BEGIN
			INSERT INTO RptGSTR2_B2B([Your GSTIN],[Return Period],[GSTIN of Supplier],[Invoice Num],[Invoice Date],
			[Invoice Value],[Place of supply],[Invoice type],[Serial no],[Tax Rate],[Taxable value],
			[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],[Eligibility],[Reverse Charge],UsrId,[Group Name],GroupType)	
			SELECT '' as [Your GSTIN],'' as [Return Period],'' as [GSTIN of Supplier],'' as [Invoice Num],Null as [Invoice Date],
			0 as [Invoice Value],'' as [Place of supply],'' as [Invoice type],0 as [Serial no],0 as [Tax Rate],
			0 as [Taxable value],0 as [IGST],0 as [CGST],0 as [SGST],0 as [CESS],0 as [ITC IGST Amt],0 as [ITC CGST Amt],0 as [ITC SGST Amt],
			0 as [ITC Cess Amt],'' [Eligibility],'' as [Reverse Charge],@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
			
			SELECT * FROM RptGSTR2_B2B WHERE UsrId=@Pi_UsrId
			
			DELETE FROM RptGSTR2_B2B WHERE UsrId=@Pi_UsrId
			RETURN
		END
		
		INSERT INTO RptGSTR2_B2B([Your GSTIN],[Return Period],[GSTIN of Supplier],[Invoice Num],[Invoice Date],
			[Invoice Value],[Place of supply],[Invoice type],[Serial no],[Tax Rate],[Taxable value],
			[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],[Eligibility],[Reverse Charge],UsrId,[Group Name],GroupType)	
			SELECT 	[Your GSTIN],@ReturnPeriod as [Return Period],[GSTIN of Supplier],[Invoice Num],[Invoice Date],
			[Invoice Value],[Place of supply],[Invoice type],[Serial no],[Tax Rate],[Taxable value],
			[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],[Eligibility],[Reverse Charge],@Pi_UsrId as UsrId,'' as [Group Name],2 as GroupType
			FROM #RptGSTR2_B2B
		
		SELECT 
			SUM(IGST) as [IGST],
			SUM([CGST]) as [CGST],
			SUM([SGST]) as [SGST],
			SUM([CESS]) as [CESS],		
			SUM([ITC IGST Amt]) as [ITC IGST Amt],
			SUM([ITC CGST Amt]) as [ITC CGST Amt],
			SUM([ITC SGST Amt]) as [ITC SGST Amt],
			SUM([ITC Cess Amt]) as [ITC Cess Amt]
		INTO #TaxTotal	
		FROM #RptGSTR2_B2B	
		
		SELECT 3 as GroupType,SUM([Invoice Value]) as [Invoice Value]
		INTO #InvoiceGT
		FROM(
		SELECT DISTINCT TransId,[Refid],[Invoice Num],[Invoice Value]
		FROM #RptGSTR2_B2B
		)X
		
			
		INSERT INTO RptGSTR2_B2B([Your GSTIN],[Return Period],[GSTIN of Supplier],[Invoice Num],[Invoice Date],
			[Invoice Value],[Place of supply],[Invoice type],[Serial no],[Tax Rate],[Taxable value],
			[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],[Eligibility],[Reverse Charge],UsrId,[Group Name],GroupType)	
		SELECT '' as [Your GSTIN],'' as [Return Period],'' as [GSTIN of Supplier],'' as [Invoice Num],Null as [Invoice Date],
			0 as [Invoice Value],'' as [Place of supply],'' as [Invoice type],0 as [Serial no],0 as [Tax Rate],
			0 as [Taxable value],[IGST],[CGST],[SGST],[CESS],[ITC IGST Amt],[ITC CGST Amt],[ITC SGST Amt],
			[ITC Cess Amt],'' [Eligibility],'' as [Reverse Charge],@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
		FROM #TaxTotal
		
		UPDATE A SET A.[Invoice Value]=B.[Invoice Value] FROM  RptGSTR2_B2B A 
		INNER JOIN #InvoiceGT B ON  A.GroupType=B.GroupType
		WHERE A.GroupType=3 and UsrId=@Pi_UsrId
		
		UPDATE RptGSTR2_B2B SET [Taxable value] =(SELECT SUM([Taxable value])
		FROM #RptGSTR2_B2B WHERE [CESS]=0) WHERE GroupType=3 and UsrId=@Pi_UsrId
		
		SELECT * FROM RptGSTR2_B2B (NOLOCK) WHERE UsrId=@Pi_UsrId
		
		--DROP TABLE #Pruchase
		--DROP TABLE #RptGSTR2_B2B
		--DROP TABLE #Sales
		--DROP TABLE #SalesReturn
		--DROP TABLE #PurchaseReceiptProduct
		--DROP TABLE #SalesReturnProduct
		--DROP TABLE #IDTIN
		--DROP TABLE #IDTProduct
END
GO
--Added By Mohana.S
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptRailwayDiscountReconsolidation_Excel')
BEGIN 
DROP TABLE RptRailwayDiscountReconsolidation_Excel	
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptChainWiseBillDetails_Excel')
BEGIN
DROP TABLE RptChainWiseBillDetails_Excel
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptMTDebitSummary_Excel')
BEGIN
DROP TABLE RptMTDebitSummary_Excel
END 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptRailwayDiscountReconsolidation' AND TYPE='P')
DROP PROCEDURE Proc_RptRailwayDiscountReconsolidation
GO
--EXEC Proc_RptRailwayDiscountReconsolidation 288,1,0,'Parle',0,0,1
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
***************************************************************************************************
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 14-12-2017   S.Moorthi   CR			ICRSTPAR7049		1. IRCTC rate should display the net rate in billing screen   
 14-12-2017   S.Mohana    CR			ICRSTPAR7049	    Corrected Excel Column values.
 26-12-2017	  S.MOHANA	  SR			ICRSTPAR7809		1.Changed Column Name (IRCTC --> Chain And LCTR --> Normal rate)
															2.REMOVED TAX CALCULATION
															3.ADDED RATE-SCHEMEDISCOUNT 															

*************************************************************************/  
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
	SELECT DISTINCT R.RtrId,RC.CtgCode,RC.CtgName
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)	
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND RC.CtgLinkId NOT IN (SELECT CtgMainId FROM RetailerCategory WHERE CtgCode='GT')
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
--	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate
	
--	SELECT * INTO #ParleOutputTaxPercentage
--	FROM ParleOutputTaxPercentage (NOLOCK)	
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdUom1EditedSelRate,CAST(CAST(SP.PrdUom1NetRate AS NUMERIC(18,6))/Uom1ConvFact AS NUMERIC(18,6)) PrdUnitNetRate,CAST((SP.PrdSchDiscAmount/SP.BaseQty)  AS NUMERIC(18,6)) SchDisc
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.SlNo,SP.PrdEditSelRte,CAST(SIP.PrdUom1NetRate AS NUMERIC(18,6))/SIP.Uom1ConvFact PrdUnitNetRate,CAST((SP.PrdSchDisAmt/SP.BaseQty)  AS NUMERIC(18,6))SchDisc
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN SalesInvoice SI(NOLOCK) ON SI.SalId=S.SalId
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SIP.SalId=S.SalId and SIP.SalId=SI.SalId and SIP.PrdId=SP.PrdId and SIP.PrdBatId=SP.PrdBatId
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0 and S.InvoiceType=1 and S.ReturnMode=1
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	INSERT INTO #ReturnDetails
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdEditSelRte,
	CAST((PrdGrossAmt-(PrdSplDisAmt+PrdSchDisamt+PrdCDDisAmt)+PrdTaxAmt)/CAST(BaseQty AS NUMERIC(18,6)) AS NUMERIC(18,6))  AS PrdUnitNetRate,CAST((SP.PrdSchDisAmt/SP.BaseQty)  AS NUMERIC(18,6)) SchDisc 
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0 --AND (ISNULL(S.InvoiceType,0)<>1 OR ISNULL(S.ReturnMode,0)<>1)
	AND NOT EXISTS(SELECT * FROM #ReturnDetails R (NOLOCK) WHERE R.ReturnId=S.ReturnId)
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	
	
	--SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	--SP.PriceId,SP.SlNo,SP.PrdEditSelRte
	--INTO #ReturnDetails
	--FROM ReturnHeader S (NOLOCK)
	--INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	--WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0
	--AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	--AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,PrdUnitNetRate,MRP,PriceId,SlNo,SchDisc,CAST(0 AS NUMERIC(18,6))[SellRate],
	CAST(0 AS NUMERIC(18,6)) IRCTCMargin,CAST(0 AS INT) [Type],CAST(0 AS NUMERIC(18,6)) AS LCTR,CAST(0 AS NUMERIC(18,6)) ChainRate
	INTO #RailwaySalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,PrdUnitNetRate,MRP,PriceId,SlNo,SchDisc FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,PrdUnitNetRate,MRP,PriceId,SlNo,SchDisc FROM #ReturnDetails
	
	) Consolidated
	
	DECLARE @SlNo AS INT
	
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE R SET R.[SellRate] = D.PrdBatDetailValue
	FROM #RailwaySalesDetails R (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE R.PrdBatId = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	
	--SELECT R.PriceId,C.DiscountPerc,C.[TYPE],C.SplSelRate
	--INTO #ExistingSpecialPrice
	--FROM #RailwaySalesDetails R (NOLOCK),
	--SpecialRateAftDownLoad_Calc C (NOLOCK)
	--WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)
	
	
	SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate,S.DiscountPerc,Type
	INTO #SpecialPrice
	FROM SpecialRateAftDownLoad_Calc S (NOLOCK),
	#FilterRetailer R,
	Product P (NOLOCK), ProductBatch B (NOLOCK)
	WHERE S.RtrCtgValueCode = R.CtgCode AND
	S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId
	AND EXISTS (SELECT 'C' FROM #FilterProduct N (NOLOCK) WHERE P.PrdId = N.Prdid)	
	
	SELECT S.* 
	INTO #LatesSpecialPrice
	FROM #SpecialPrice S,
	(
		SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
		FROM #SpecialPrice
		GROUP BY RtrId,PrdId,PrdBatId
	) L
	WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate
	
	UPDATE R SET R.IRCTCMargin = S.DiscountPerc,R.[Type] = S.[TYPE]
	FROM #RailwaySalesDetails R (NOLOCK),
	#LatesSpecialPrice S (NOLOCK)
	WHERE R.Prdid = S.Prdid AND R.Rtrid = S.Rtrid AND R.Prdbatid = S.Prdbatid

	--UPDATE R SET R.LCTR = R.[SellRate] + (R.[SellRate]*(T.TaxPerc/100))
	--FROM #RailwaySalesDetails R (NOLOCK),
	--#ParleOutputTaxPercentage T (NOLOCK)
	--WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno	
	
	
	UPDATE R SET R.LCTR = R.[SellRate] 	FROM #RailwaySalesDetails R (NOLOCK)  
		
	--UPDATE R SET R.ChainRate = SplSelRate-SchDisc 	FROM #RailwaySalesDetails R (NOLOCK) INNER JOIN #LatesSpecialPrice S (NOLOCK)
	--ON R.Prdid = S.Prdid AND R.Rtrid = S.Rtrid AND R.Prdbatid = S.Prdbatid
	
	SELECT DISTINCT Priceid,PrdBatDetailValue  INTO #SpecialPrice_New FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #RailwaySalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #RailwaySalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	UPDATE M SET M.ChainRate = D.PrdBatDetailValue-SchDisc 
	FROM #RailwaySalesDetails M (NOLOCK),
	#SpecialPrice_New D (NOLOCK) 
	WHERE M.PriceId = D.PriceId  
	 
	 
	 
	UPDATE R SET R.ChainRate = (R.[SellRate]-SchDisc) --ROUND((R.[SellRate]-SchDisc),2,1) 
	FROM #RailwaySalesDetails R (NOLOCK)  WHERE ChainRate=0
	 	

	--SELECT RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,SUM(TotalPCS) TotalPCS,MRP,
	SELECT Ctgname,P.PrdId,P.PrdName,SUM(TotalPCS) TotalPCS,PrdUnitNetRate,MRP,
	LCTR As NormalRate,IRCTCMargin,CASE S.[Type] WHEN 1 THEN 'Mark Up' WHEN 2 THEN 'Mark Down' ELSE '' END MarkUpDown,
	ChainRate,
	CAST(0 AS NUMERIC(18,6)) TotalMRP,CAST(0 AS NUMERIC(18,6)) TotalLCTR,
	CAST(0 AS NUMERIC(18,6)) IRCTCTotal,CAST(0 AS NUMERIC(18,6)) ClmAmount,
	CAST(0 AS NUMERIC(18,6)) LibOnMRP,CAST(0 AS NUMERIC(18,6)) LibOnLCTR
	INTO #RailwayDiscount
	FROM #RailwaySalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN #FilterRetailer F ON F.Rtrid = S.Rtrid
	GROUP BY Ctgname,P.PrdId,P.PrdName,MRP,LCTR,IRCTCMargin,S.[Type],PrdUnitNetRate,ChainRate
	
	--UPDATE R SET R.IRCTCRate = MRP - (MRP * IRCTCMargin / 100.00), 
	--UPDATE R SET R.IRCTCRate = PrdUnitNetRate, 
	UPDATE R SET TotalMRP  = TotalPCS * MRP, 
	TotalLCTR = TotalPCS * NormalRate
	FROM #RailwayDiscount R (NOLOCK)
	
	UPDATE R SET R.IRCTCTotal = TotalPCS * ChainRate
	FROM #RailwayDiscount R (NOLOCK)
	 
	
	UPDATE R SET R.ClmAmount = ROUND((TotalLCTR - IRCTCTotal),2)
	FROM #RailwayDiscount R (NOLOCK)
	
	UPDATE R SET R.LibOnMRP = (ClmAmount / TotalMRP)*100
	FROM #RailwayDiscount R (NOLOCK)
	WHERE R.TotalMRP <> 0
	
	UPDATE R SET R.LibOnLCTR = (ClmAmount / TotalLCTR)*100
	FROM #RailwayDiscount R (NOLOCK)
	WHERE R.TotalLCTR <> 0	
	
	 

	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptRailwayDiscountReconsolidation_Excel')
	DROP TABLE RptRailwayDiscountReconsolidation_Excel	
	
	SELECT Ctgname,PrdId,PrdName,TotalPCS,PrdUnitNetRate,MRP,CAST(NormalRate  AS NUMERIC(18,2)) NormalRate,IRCTCMargin As ChainMargin,MarkUpDown,CAST (ChainRate  AS NUMERIC(18,2)) ChainRate,
	TotalMRP,CAST (TotalLCTR  AS NUMERIC(18,2)) TotalLCTR,CAST (ROUND(IRCTCTotal,2) AS NUMERIC(18,2)) IRCTCTotal 
	,CAST(ClmAmount  AS NUMERIC(18,2)) ClmAmount,CAST(LibOnMRP  AS NUMERIC(18,2)) LibOnMRP,	CAST (LibOnLCTR  AS NUMERIC(18,2)) LibOnLCTR
	INTO RptRailwayDiscountReconsolidation_Excel
	FROM #RailwayDiscount (NOLOCK) ORDER BY PrdName
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptRailwayDiscountReconsolidation_Excel
	
	SELECT * FROM RptRailwayDiscountReconsolidation_Excel ORDER BY PrdName,MarkUpDown
	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,1,'CtgName','Category Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,2,'PrdId','PrdId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,3,'PrdName','Product Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,4,'TotalPCS','Total PCS',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,5,'PrdUnitNetrate','PrdUnitNetrate',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,6,'MRP','MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,7,'Normal Rate','Normal Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,8,'IRCTCMargin','Chain Margin',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,9,'MarkUpDown','MarkUp /Mark Down',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,10,'Chain Rate','Chain Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,11,'TotalMRP','Parle Total MRP Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,12,'TotalLCTR','Parle Total Normal Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,13,'IRCTCTotal','Chain Total Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,14,'ClmAmount','Claim Amount',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,15,'LibOnMRP','% Lib On MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,16,'LibOnLCTR','% Lib On Total NormalRate',1,1)
	
	RETURN	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptChainWiseBillDetails' AND TYPE='P')
DROP PROCEDURE Proc_RptChainWiseBillDetails
GO
--EXEC Proc_RptChainWiseBillDetails 288,1,0,'PARLE_CR',0,0,1
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
************************************************************************************************************************************
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 14-12-2017   S.Moorthi   CR			ICRSTPAR7049		1. Chain lending rate should display the net rate in billing screen
															2. Bill number column should be after the party name column 
************************************************************************************************************************************												  
 19-12-2017   S.Mohana    CR			ICRSTPAR7049		3. Added SubTotal in Excel 
************************************************************************************************************************************
 23-12-2017	  S.MOHANA	  SR			ICRSTPAR7809		1.INCLUDED SALES RETURN
															2.REMOVED TAX CALCULATION
															3.ADDED RATE-SCHEMEDISCOUNT , GRANDTOTAL
************************************************************************************************************************************
 26-03-2018	  S.MOHANA	  CR			CCRSTPAR0186		Retailer Wise Sub Total Included. 
************************************************************************************************************************************/  
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
	--Added By Mohana
	CREATE TABLE #Chain
	(
		[SalId] [bigint] NOT NULL,
		[BillNo] [nvarchar](50) NOT NULL,
		[BillDate] NVARCHAR(100),
		[RtrId] [int] NOT NULL,
		RtrName NVARCHAR(100),
		Ctgname NVARCHAR(100) NOT NULL,
		[PrdId] [int] NOT NULL,
		PrdName NVARCHAR(100),
		PktWgt [numeric](18, 6),
		[MRP] [numeric](18, 6) NOT NULL,
		QtyInPkt [numeric](38, 0) NULL,		
		[ChainLandRate] [numeric](18, 6) NULL,
		Amount [numeric](38, 2) NULL,
		[GrpName] NVARCHAR(100),
		[Grpid] INT
	)  
	
	
	CREATE TABLE #ChainSalesDetails
	(
		[SalId] [bigint] NOT NULL,
		[SalInvNo] [nvarchar](50) NOT NULL,
		[SalInvDate] [datetime] NOT NULL,
		[RtrId] [int] NOT NULL,
		[PrdId] [int] NOT NULL,
		[TotalPCS] [numeric](38, 0) NULL,
		[MRP] [numeric](18, 6) NOT NULL,
		[PriceId] [int] NOT NULL,
		[PrdBatid] [int] NOT NULL,
		[ChainLandRate] [numeric](18, 6) NULL,
		[SchemeDiscount] [numeric](18, 6) NULL
	)


	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	
	SET @ReportType = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,315,@Pi_UsrId))
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode,Ctgname
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)	
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId 
	and  CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A(NOLOCK) where CtgCode NOT IN ('GT'))
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
	
	INSERT INTO #ChainSalesDetails
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SUM(SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.PrdBatid,
	--SUM(CAST(SP.PrdUom1NetRate AS NUMERIC(18,6))/Uom1ConvFact) as ChainLandRate --ICRSTPAR7049
	CAST(0 AS NUMERIC(18,6)) ChainLandRate,SUM(SP.PrdSchDiscAmount) SchDisc
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	GROUP BY S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.PriceId,SP.SplPriceid,SP.PrdBatid
	UNION ALL
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SUM(-1*SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.PrdBatid,
	--SUM(CAST(SP.PrdUom1NetRate AS NUMERIC(18,6))/Uom1ConvFact) as ChainLandRate --ICRSTPAR7049
	CAST(0 AS NUMERIC(18,6)) ChainLandRate,SUM(SP.PrdSchDisAmt) SchDisc
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	WHERE S.ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	GROUP BY S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.SplPriceid,SP.PriceId,SP.PrdBatid
	
	UPDATE #ChainSalesDetails SET SchemeDiscount = abs(SchemeDiscount/TotalPCS)
	
	--ICRSTPAR7049 Till Here
	--SELECT R.PriceId,C.SplSelRate 
	--INTO #ExistingSpecialPrice
	--FROM #ChainSalesDetails R (NOLOCK),
	--SpecialRateAftDownLoad_Calc C (NOLOCK)
	--WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)
	
	SELECT DISTINCT C.PrdBatid,C.Priceid,C.PrdbatDetailValue INTO #NormalPrice FROM #ChainSalesDetails A INNER JOIN Productbatch B ON A.Prdbatid=B.PrdBatid
	INNER JOIN ProductBatchDetails C ON  B.PRDBATID = C.PRDBATID AND DEFAULTPRICE = 1
	and SLNO=3	
	
	--ADDED BY MOHANA
	
	SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #ChainSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #ChainSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	

	
	UPDATE R SET R.ChainLandRate = (S.SplSelRate-R.SchemeDiscount)
	FROM #ChainSalesDetails R (NOLOCK),
	#ExistingSpecialPrice S (NOLOCK)
	WHERE R.PriceId = S.PriceId		
	--Till Here ICRSTPAR7049
	
	UPDATE A SET A.ChainLandRate = (B.PrdbatDetailValue-A.SchemeDiscount) FROM #ChainSalesDetails A INNER JOIN #NORMALPRICE B ON A.PRDBATID=B.PRDBATID WHERE A.ChainLandRate=0  

	
	INSERT INTO #Chain(SalId,BillNo,BillDate,RtrId,RtrName,Ctgname,PrdId,PrdName,PktWgt,MRP,QtyInPkt,ChainLandRate,Amount)
	SELECT S.SalId,S.SalInvNo BillNo,CONVERT(VARCHAR(10),S.SalInvDate,121) as  BillDate,S.RtrId,R.RtrName,CtgName,P.PrdId,P.PrdName,
	PrdWgt PktWgt,MRP,TotalPCS QtyInPkt,ChainLandRate, --ICRSTPAR7049
	CAST(0 AS NUMERIC(18,2)) Amount
	FROM #ChainSalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	INNER JOIN #FilterRetailer F ON S.Rtrid = F.Rtrid AND R.Rtrid = F.Rtrid
	UPDATE C SET C.Amount = QtyInPkt * ChainLandRate
	FROM #Chain C (NOLOCK)
	
	--Nagarajan on 29.08.2017 as per PMS : ICRSTPAR5917
	--SELECT S.SalId,S.RtrId,SP.PrdId,SUM(SPT.TaxAmount) TaxAmount
	--INTO #SalesInvoiceProductTax
	--FROM SalesInvoice S (NOLOCK)
	--INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	--INNER JOIN SalesInvoiceProductTax SPT (NOLOCK) ON SPT.SalId = SP.SalId AND SPT.PrdSlNo = SP.SlNo 
	--WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 AND SPT.TaxAmount > 0
	--AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	--AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	--GROUP BY S.SalId,S.RtrId,SP.PrdId
	
	--UPDATE C SET C.Amount = C.Amount + ISNULL(SPT.TaxAmount,0)
	--FROM #Chain C (NOLOCK)
	--INNER JOIN #SalesInvoiceProductTax SPT ON SPT.SalId=C.SalId AND SPT.RtrId = C.SalId AND SPT.PrdId=C.PrdId
	--WHERE C.Amount > 0
	--Till here
	-- ICRSTPAR7049 Bill No Column Change
	
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptChainWiseBillDetails_Excel')
	DROP TABLE RptChainWiseBillDetails_Excel
		 
	
	SELECT SalId,Ctgname,RtrName,BillNo,BillDate,RtrId,PrdId,PrdName,PktWgt,MRP,QtyInPkt,ROUND(ChainLandRate,2,1) ChainLandRate,ROUND(Amount,2,1) Amount,Grpid,GrpName
	INTO RptChainWiseBillDetails_Excel
	FROM #Chain (NOLOCK) Order by  Ctgname,RtrName
	
	UPDATE RptChainWiseBillDetails_Excel SET Grpname='Retailer'
	
 	SELECT  Row_numbeR() Over(Order by  Ctgname,Rtrid Asc) as Row ,Rtrid,Rtrname,Ctgname INTO #Excel  from RptChainWiseBillDetails_Excel  GROUP BY Rtrid ,Rtrname,Ctgname
 	UPDATE A SET A.Grpid = B.row from RptChainWiseBillDetails_Excel A INNER JOIN #Excel B ON A.Rtrid = B.Rtrid 
	 	
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptChainWiseBillDetails_Excel
	
	SELECT * FROM RptChainWiseBillDetails_Excel Order By Ctgname,BillNo
	
	--INSERT INTO RptChainWiseBillDetails_Excel
	--SELECT 0 SalId,'' Ctgname,'' RtrName,'TOTAL ' BillNo,'' BillDate,0 RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	--SUM(Amount) Amount,1000,CtgName  FROM RptChainWiseBillDetails_Excel	
	--group by CtgName
	--UNION  
	--SELECT 0 SalId,'' Ctgname,'' RtrName,'Grand Total ' BillNo,'' BillDate,0 RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	--SUM(Amount) Amount,10000,'zzzzzz' FROM RptChainWiseBillDetails_Excel	
 
	INSERT INTO RptChainWiseBillDetails_Excel
	SELECT 0 SalId,'' Ctgname,'' RtrName,'TOTAL ' BillNo,'' BillDate,RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	SUM(Amount) Amount,Max(Grpid),'SubTotal' FROM RptChainWiseBillDetails_Excel 
	group by RtrId
	UNION   
	SELECT 0 SalId,Ctgname,'' RtrName,'TOTAL ' BillNo,'' BillDate,0 RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	SUM(Amount) Amount,Max(Grpid),'ZSubStotal'  FROM RptChainWiseBillDetails_Excel 
	group by   Ctgname
	UNION  
	SELECT 0 SalId,'' Ctgname,'' RtrName,'Grand Total ' BillNo,'' BillDate,0 RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	SUM(Amount) Amount,1000000,'zzzzzzzzz' FROM RptChainWiseBillDetails_Excel	

	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,1,'SalId','SalId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,2,'CtgName','Category Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,3,'RtrName','Party Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,4,'BillNo','BillNo',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,5,'BillDate','BillDate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,6,'RtrId','RtrId',0,1)
 	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,7,'PrdId','PrdId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,8,'PrdName','Product Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,9,'PktWgt','Pkt Wgt',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,10,'MRP','MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,11,'QtyInPkt','Quantity in Pkts',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,12,'ChainLandRate','Chain Landing Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,13,'Amount','Amount',1,1)	
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,14,'Grpid','Grpid',0,1)	
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,15,'GrpName','GrpName',0,1)	
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptMTDebitSummary' AND TYPE='P')
DROP PROCEDURE Proc_RptMTDebitSummary
GO
--EXEC Proc_RptMTDebitSummary 288,1,0,'Parle',0,0,1
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
* CREATED	: Mohana -- ICRSTPAR7809
* CREATED DATE	: 28-02-2018 
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
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
	WHERE 
	R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId AND
	RC.CTGCODE IN (SELECT CtgCode FROM RetailerCategory A 
	WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A(NOLOCK) where CtgCode NOT IN ('GT')))
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
	

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid ,SP.SlNo,SP.PrdUom1EditedSelRate,B.DefaultPriceId,Cast((SP.PrdSchDiscAmount/SP.BaseQty)AS NUMERIC(18,6)) Schdisc
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdEditSelRte,B.DefaultPriceId,Cast((SP.PrdSchDisAmt/Sp.BaseQty) AS NUMERIC(18,6)) RtnSchdisc
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND  SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
 
 
 
	SELECT Salid,RTRid,Schid INTO #SalScheme FROM (
	Select Distinct SI.Salid,RTRid,Schid from Salesinvoice SI(NOLOCK) INNER JOIN SalesInvoiceSchemeLineWise SH(NOLOCK) ON SI.Salid=SH.Salid
	WHERE Salinvdate between @FromDate AND @ToDate and Dlvsts in (4,5)
	UNION 
	Select Distinct SI.Salid,RTRid,Schid from Salesinvoice SI(NOLOCK) INNER JOIN SalesInvoiceSchemeDtFreePrd SH(NOLOCK) ON SI.Salid=SH.Salid
	WHERE Salinvdate between @FromDate AND @ToDate and Dlvsts in (4,5)
	)A
	
	SELECT ReturnId,RTRid,Schid INTO #RtnScheme FROM (
	Select Distinct A.Returnid,RTRid,Schid FROM ReturnSchemeLineDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	WHERE ReturnDate between @FromDate AND @ToDate and B.Status = 0  
	UNION
	Select Distinct A.Returnid,RTRid,Schid FROM ReturnSchemeFreePrdDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	WHERE ReturnDate between @FromDate AND @ToDate and B.Status = 0  
	)A
	
 	SELECT Salid,RTRid, Schid,A.Prdid INTO #SalSchemeProducts FROM
	 (
		SELECT DISTINCT Salid,RTRid,A.Schid, B.Prdid FROM #SalScheme A(NOLOCK)
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN Product C(NOLOCK) On B.Prdid = C.PrdId
		UNION
		SELECT DISTINCT Salid,RTRid,A.Schid, E.Prdid FROM #SalScheme A(NOLOCK)
		INNER JOIN SchemeProducts B (NOLOCK)ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C (NOLOCK) ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D(NOLOCK) ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E(NOLOCK) On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F(NOLOCK) On
		F.PrdId = E.Prdid
	)A INNER JOIN #FilterProduct B ON A.PrdId = B.Prdid 
	
	
	 	SELECT DISTINCT ReturnId,RTRid,Schid,A.Prdid INTO #RtnSchemeProducts FROM
	 (
		SELECT DISTINCT ReturnId,RTRid,A.Schid, B.Prdid FROM #RtnScheme A
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN Product C(NOLOCK) On B.Prdid = C.PrdId
		UNION
		SELECT DISTINCT ReturnId,RTRid,A.Schid, E.Prdid FROM #RtnScheme A
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C(NOLOCK) ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D(NOLOCK) ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E(NOLOCK) On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F(NOLOCK) On
		F.PrdId = E.Prdid
	)A INNER JOIN #FilterProduct B ON A.PrdId = B.Prdid 
	
	 
	
	
	SELECT DISTINCT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],DefaultPriceId,SchDisc,Type,
	CAST(0 AS NUMERIC(18,6))[ActualSellRate],CAST(0 AS NUMERIC(18,6))[SpecialSellRate],
	CAST(0 AS NUMERIC(18,6)) NrmlLCTR, CAST(0 AS NUMERIC(18,6)) NrmlSecSalesTOT, CAST(0 AS NUMERIC(18,6)) TOTDifClms
	, CAST(0 AS NUMERIC(18,6)) OfferLCTR, CAST(0 AS NUMERIC(18,6)) OffSecSalesTOT, CAST(0 AS NUMERIC(18,6)) TotOffSalesChain,
	 CAST(0 AS NUMERIC(18,6)) OffClmDiff
	INTO #MTSalesDetails
	FROM 
	(
	SELECT DISTINCT 1 TransType,A.RtrId,A.SalId,SalInvDate TransDate,A.PrdId,A.PrdBatId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate],DefaultPriceId,
	SchDisc,CASE ISNULL(B.Salid,0) WHEN 0 THEN 'NS' ELSE 'S' END AS Type
	FROM #BillingDetails A(NOLOCK)
	LEFT OUTER JOIN #SalSchemeProducts B(NOLOCK) ON A.Salid = B.salid AND A.Prdid=B.Prdid AND A.Rtrid =B.Rtrid
	UNION ALL
	SELECT  DISTINCT 2 TransType,A.RtrId,A.ReturnID,ReturnDate TransDate,A.PrdId,A.PrdBatId, BaseQty,MRP,PriceId,SlNo,PrdEditSelRte,DefaultPriceId,
	RtnSchDisc,CASE ISNULL(B.ReturnID,0) WHEN 0 THEN 'NS' ELSE 'S' END AS Type
	FROM #ReturnDetails A(NOLOCK)
	LEFT OUTER JOIN #RtnSchemeProducts B(NOLOCK) ON A.Returnid = B.Returnid AND A.Prdid=B.Prdid AND A.Rtrid =B.Rtrid
	) A
	
	UPDATE A SET ActualSellRate = C.PrdBatDetailValue FROM #MTSalesDetails A INNER JOIN ProductBatch B ON A.Prdid = B.PrdId AND A.Prdbatid = B.PrdBatId
	INNER JOIN 	ProductBatchDetails C ON B.DefaultPriceid = C.PriceId  AND C.SLNo = 3
	 
	
	SELECT DISTINCT Priceid,PrdBatDetailValue  INTO #SpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	UPDATE M SET M.[SpecialSellRate] = D.PrdBatDetailValue
	FROM #MTSalesDetails M (NOLOCK),
	#SpecialPrice D (NOLOCK) 
	WHERE M.PriceId = D.PriceId  
	
	 
	--Non Scheme
	UPDATE A SET NrmlLCTR = TotalPcs*ActualSellrate FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
		
	UPDATE A SET NrmlSecSalesTot = ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*ActualSellrate) ELSE (TotalPcs*SpecialSellRate) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
	
	UPDATE A SET TotDifClms  = NrmlLCTR-NrmlSecSalesTot FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
	
			
	--Scheme
	
	UPDATE A SET OfferLCTR = TotalPcs*ActualSellrate FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
		
	UPDATE A SET OffSecSalesTOT = ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*ActualSellrate) ELSE (TotalPcs*SpecialSellRate) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
		
	UPDATE A SET TotOffSalesChain =  ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*(ActualSellrate-SchDisc)) ELSE (TotalPcs*(SpecialSellRate-SchDisc)) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
	UPDATE A SET OffClmDiff = OfferLCTR-TotOffSalesChain FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
	SELECT CtgName,SUM(NrmlLCTR) NrmlLCTR,SUM(NrmlSecSalesTOT) NrmlSecSalesTOT,SUM(TOTDifClms) TOTDifClms,SUM(OfferLCTR) OfferLCTR,
	SUM(OffSecSalesTOT) OffSecSalesTOT,	SUM(OffClmDiff) OffClmDiff,SUM(TotOffSalesChain) TotOffSalesChain,	CAST(0 AS NUMERIC(18,6)) LIABNormalSale,
	CAST(0 AS NUMERIC(18,6)) OffLIABValue,CAST(0 AS NUMERIC(18,6)) TotalSales,CAST(0 AS NUMERIC(18,6)) LIABOffClmWITHOUTTOT,
	CAST(0 AS NUMERIC(18,6)) LIABOffClmTotalSale,CAST(0 AS NUMERIC(18,6)) GrandTotClm,
	CAST(0 AS NUMERIC(18,6)) TOTALLIAB ,CAST(0 AS NUMERIC(18,6)) TotSalTOChain,CAST(0 AS NUMERIC(18,6)) OffLIABTtotalSales,CAST(0 AS NUMERIC(18,6)) TOTLiabTotal
	INTO #MTFinal
	FROM #MTSalesDetails D (NOLOCK) INNER JOIN #FilterRetailer B ON D.Rtrid = B.Rtrid 
	GROUP BY  CtgName
	
	UPDATE A SET LIABNormalSale = (TotDifClms/NrmlLCTR)*100  FROM #MTFinal A(NOLOCK)  WHERE NrmlLCTR>0

	UPDATE A SET OffLiabvalue = OffSecSalesTOT-TotOffSalesChain  FROM #MTFinal A(NOLOCK) 
	 
	UPDATE A SET TotalSales = OfferLCTR+NrmlLCTR FROM #MTFinal A(NOLOCK) 
		
	UPDATE A SET LIABOffClmWITHOUTTOT = (OffLiabvalue/OfferLCTR)*100 FROM #MTFinal A(NOLOCK) WHERE OfferLCTR>0
	
	UPDATE A SET LIABOffClmTotalSale  = (OffClmDiff/OfferLCTR)*100  FROM #MTFinal A(NOLOCK)     WHERE OfferLCTR>0
		
	UPDATE A SET GrandTotClm  = 	(OffClmDiff+TotDifClms)   FROM #MTFinal A(NOLOCK) 
		
	UPDATE A SET TOTALLIAB  = 	(GrandTotClm/TotalSales)*100   FROM #MTFinal A(NOLOCK) WHERE [TotalSales] > 0	
	
	UPDATE A SET TotsaltoChain  = NrmlSecsalesTOT+ TotOffSalesChain    FROM #MTFinal A(NOLOCK) 	
	
	UPDATE A SET OffLIABTtotalSales  = 	(OffLIABValue/TotalSales)*100   FROM #MTFinal A(NOLOCK) WHERE [TotalSales] > 0
	
	UPDATE A SET TOTLiabTotal  = 	((GrandTotClm-OffLIABValue)/TotalSales)*100   FROM #MTFinal A(NOLOCK)  WHERE [TotalSales] > 0
	
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptMTDebitSummary_Excel')
	DROP TABLE RptMTDebitSummary_Excel
	
	SELECT CtgName,ROUND(NrmlLCTR,2,1) NrmlLCTR,ROUND(NrmlSecSalesTOT,2,1) NrmlSecSalesTOT,ROUND(TOTDifClms,2,1) TOTDifClms,ROUND(LIABNormalSale,2,1) LIABNormalSale,
	ROUND(OfferLCTR,2,1) OfferLCTR,ROUND(OffSecSalesTOT,2,1) OffSecSalesTOT,ROUND(TotOffSalesChain,2,1) TotOffSalesChain,ROUND(OffClmDiff,2,1) OffClmDiff,
	ROUND(OffLIABValue,2,1) OffLIABValue,ROUND(TotalSales,2,1) TotalSales,ROUND(TotSalTOChain,2,1) TotSalTOChain,ROUND(GrandTotClm,2,1) GrandTotClm,
	ROUND(LIABOffClmWITHOUTTOT,2,1) LIABOffClmWITHOUTTOT,ROUND(LIABOffClmTotalSale,2,1) LIABOffClmTotalSale,ROUND(OffLIABTtotalSales,2,1) OffLIABTtotalSales,
	ROUND(TOTLiabTotal,2,1) TOTLiabTotal,ROUND(TOTALLIAB,2,1) TOTALLIAB,1 AS Grpid
	INTO RptMTDebitSummary_Excel
	FROM #MTFinal
	
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptMTDebitSummary_Excel	
	
	SELECT * FROM RptMTDebitSummary_Excel(NOLOCK) 
	
	INSERT INTO RptMTDebitSummary_Excel
	SELECT 'Grand TOTAL : ' ,SUM(NrmlLCTR),SUM(NrmlSecSalesTOT),SUM(TOTDifClms),SUM(LIABNormalSale),SUM(OfferLCTR),SUM(OffSecSalesTOT),SUM(TotOffSalesChain),SUM(OffClmDiff),
	SUM(OffLIABValue),SUM(TotalSales),SUM(TotSalTOChain),SUM(GrandTotClm),SUM(LIABOffClmWITHOUTTOT),SUM(LIABOffClmTotalSale),SUM(OffLIABTtotalSales),SUM(TOTLiabTotal),
	SUM(TOTALLIAB),9999999 FROM RptMTDebitSummary_Excel where CtgName not in ('Grand TOTAL : ')
	
 
	UPDATE  A SET	LIABNormalSale = ROUND((TOTDifClms/NrmlLCTR)*100,2,1) FROM RptMTDebitSummary_Excel  A where CtgName in ('Grand TOTAL : ') AND NrmlLCTR>0
	
	UPDATE  A SET LIABOffClmWITHOUTTOT =ROUND((OffLIABValue/OfferLCTR)*100,2,1), LIABOffClmTotalSale = ROUND((OffClmDiff/OfferLCTR)*100,2,1)
	FROM RptMTDebitSummary_Excel  A where CtgName in ('Grand TOTAL : ') AND OfferLctr>0
	
	UPDATE  A SET OffLIABTtotalSales = ROUND((OffLIABValue/TotalSales)*100,2,1),
	TOTLiabTotal =ROUND(((GrandTotClm-OffLIABValue)/TotalSales)*100,2,1),
	TOTALLIAB = ROUND((GrandTotClm/TotalSales)*100,2,1)  FROM RptMTDebitSummary_Excel  A where CtgName in ('Grand TOTAL : ') AND TotalSales>0
	
	
	
	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,1,'CHAIN NAME','CHAIN NAME',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,2,'TOTAL NORMAL AMOUNT','TOTAL NORMAL AMOUNT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,3,'TOTAL  NORMAL  SEC SALES AS PER TOT','TOTAL  NORMAL  SEC SALES AS PER TOT',1, 1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,4,'TOT DIFF CLAIMS','TOT DIFF CLAIMS',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,5,'% LIAB ON NORMAL SALE','% LIAB ON NORMAL SALE',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,6,'TOTAL OFFER NORMAL AMOUNT','TOTAL OFFER NORMAL AMOUNT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,7,'TOTAL OFFER SEC SALES AS PER TOT','TOTAL OFFER SEC SALES AS PER TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,8,'TOTAL OFFER SEC SALE','TOTAL OFFER SEC SALE',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,9,'OFFERS CLAIMS DIFF (TOT+OFFER)','OFFERS CLAIMS DIFF (TOT+OFFER)',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,10,'OFFER LIABILITY VALUE','OFFER LIABILITY VALUE',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,11,'TOTAL SALE(OFFER + NON OFFER)','TOTAL SALE(OFFER + NON OFFER)',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,12,'TOTAL SALE TO CHAIN','TOTAL SALE TO CHAIN',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,13,'GRAND TOTAL CLAIMS','GRAND TOTAL CLAIMS',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,14,'% LIAB OF OFFER CLAIMS ON SALE WITHOUT TOT','% LIAB OF OFFER CLAIMS ON SALE WITHOUT TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,15,'% LIAB OF OFFER CLAIMS ON TOTAL SALE','% LIAB OF OFFER CLAIMS ON TOTAL SALE',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,16,'% OFFER LIABILITY ON TOTAL SALES','% OFFER LIABILITY ON TOTAL SALES',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,17,'% TOT LIABILITY ON TOTAL SALES','% TOT LIABILITY ON TOTAL SALES',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,18,'TOTAL % LIAB','TOTAL % LIAB',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,19,'Grpid','Grpid',0,1)
	
	
RETURN

END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptDebitNoteTopSheet' AND TYPE='P')
DROP PROCEDURE Proc_RptDebitNoteTopSheet
GO
--Proc_RptDebitNoteTopSheet 291,1,0,'',0,0,1
CREATE PROCEDURE Proc_RptDebitNoteTopSheet
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*************************************************************************************************
* PROCEDURE	: Proc_RptDebitNoteTopSheet
* PURPOSE	: To Return the Scheme Utilization Details
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Debit Note Top Sheet
* MODIFIED 
***************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
10-10-2017  Mohana.S	 CR     CCRSTPAR0172          Included Circular Date and scheme Budget 
04-12-2017	Mohana		 BZ		ICRSTPAR6760		  Added New Function for calculating Scheme utilized for selected month
07-12-2017  Mary.S		 BZ		ICRSTPAR6933		  Excel Sheet row Witdth change    
13-12-2017  Mohana.S	 CR		ICRSTPAR6933		  Changed Sampling Amount as Zero (default)   
09-01-2018  lakshman M   BZ     ICRSTPAR7284          LCTR Formula velidation changed.(special price not consider in LCTR Value).
26-03-2018	Mohana S	 CR		CCRSTPAR0187		  TOT Diff Claims Report Created. 
***************************************************************************************************/     
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
	DECLARE @DBMonth As INT
	
	SELECT @DistributorCode = DistributorCode, @DistributorName = DistributorName,
	@CityName = G.GeoName
	FROM Distributor D (NOLOCK),
	Geography G (NOLOCK) WHERE D.GeoMainId = G.GeoMainId
	
	--Added By Mohana 
	
	--SELECT @DBMonth = COUNT(*) FROM ACMaster  A INNER JOIN ACPeriod B ON A.AcmId=B.AcmId WHERE AcmYr = YEAR (GETDATE()) AND AcmSdt < =@ToDate
	SELECT @DBMonth = CASE MONTH (@ToDate) 
		WHEN 4 THEN 1
		WHEN 5 THEN 2
		WHEN 6 THEN 3
		WHEN 7 THEN 4
		WHEN 8 THEN 5
		WHEN 9 THEN 6
		WHEN 10 THEN 7
		WHEN 11 THEN 8
		WHEN 12 THEN 9
		WHEN 1 THEN 10
		WHEN 2 THEN 11
		WHEN 3 THEN 12
 END 
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
	
	-------------------- Added by Lakshman M On 07/11/2017 PMS_ICRSTPAR6575-------------------
	 SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,    
	 B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue    
	 INTO #BillingDetails    
	 FROM SalesInvoice S (NOLOCK)    
	 INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId    
	 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId 
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1		 
	 WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =3
	    
	 SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,    
	 B.DefaultPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue  
	 INTO #ReturnDetails    
	 FROM ReturnHeader S (NOLOCK)    
	 INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID    
	 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId    
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1
	 WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =3
	     
	 SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,CAST (0 AS NUMERIC(18,6)) AS ActualSellRate,prdtaxamount,PrdBatDetailValue as PrdUnitSelRate,   
	 CAST (0 AS NUMERIC(18,6)) AS LCTR    
	 INTO #DebitSalesDetails    
	 FROM     
	 (    
	 SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,prdtaxamount,PrdBatDetailValue FROM #BillingDetails   
	 UNION ALL    
	 SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,DefaultPriceId ,SlNo,prdtaxamount,PrdBatDetailValue FROM #ReturnDetails    
	 ) Consolidated 
	    
	 UPDATE M SET M.ActualSellRate = round(D.PrdBatDetailValue,2)    
	 FROM #DebitSalesDetails M (NOLOCK),    
	 ProductBatchDetails D (NOLOCK)     
	 WHERE M.ActualPriceId = D.PriceId AND D.SLNo = @SlNo 
	
	---------------- commented by Lakshman M on 07/11/2017 ---------------  
	--UPDATE R SET R.LCTR = R.BaseQty * (R.ActualSellRate+(R.ActualSellRate*(T.TaxPerc/100)))
	--FROM #DebitSalesDetails R (NOLOCK),
	--#ParleOutputTaxPercentage T (NOLOCK)
	--WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType
  -----------------------
	 UPDATE R SET R.LCTR = ((R.BaseQty *(R.PrdUnitSelRate))+(R.PrdUnitSelRate *(T.TaxPerc/100)))    
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
	
	--Added CircularNo and date By Mohana
	SELECT S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	INTO #SchemeDebit
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId   AND B.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill
	GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate
	ORDER BY S.SchId
	--SchemeCirculardetails
	
	--SELECT S.SchId,SUM(B.BaseQty) [SecSalesQtyInScheme]
	--INTO #SchemeForLiab
	--FROM #ApplicableScheme S (NOLOCK),
	--#BillingDetails B (NOLOCK)
	--WHERE S.PrdId = B.PrdId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	--AND EXISTS (SELECT 'C' FROM SalesInvoiceSchemeDtBilled SB (NOLOCK) WHERE B.SalId = SB.SalId AND S.SchId = SB.SchId)
	--GROUP BY S.SchId
	
	UPDATE SD SET SD.Amount = DBO.Fn_ReturnBudgetUtilized_scheme(SD.SchId,@FromDate,@ToDate)   
	FROM #SchemeDebit SD (NOLOCK)
	  
	
	UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,6))
	FROM #SchemeDebit SD (NOLOCK)
	WHERE SD.[SecSalesVal] <> 0
	
	--Report 3
	
	--Report 4
	DECLARE @TargetNo	AS INT
	
	DECLARE @InsFromDate	AS	DATETIME	
	DECLARE @InsToDate		AS	DATETIME
	DECLARE @Year	AS INT	
	DECLARE @Month  AS INT
	DECLARE @MonthName as Nvarchar(100)
			
	SELECT TOP 1 @TargetNo = InsId,@Month=TargetMonth,@Year=TargetYear,
	@InsFromDate = CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01',
	@InsToDate = DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01'))	
	
	FROM InsTargetHD H (NOLOCK) WHERE H.[Status] = 1	
	AND CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01' BETWEEN @FromDate AND @ToDate
	ORDER BY InsId DESC
	
	SELECT @MonthName=MonthName FROM MonthDt (NOLOCK) WHERE MonthId=@Month
	update InsTargetHD set TargetMonth=EffFromMonthId where TargetMonth=0
	
	--EXEC Proc_LoadingInstitutionsTarget @TargetNo,@Pi_UsrId
	EXEC Proc_LoadingInstitutionsTarget @Year,@Month,@MonthName,@Pi_UsrId
	
	SELECT CtgMainId,CtgName,@InsFromDate FromDate,@InsToDate ToDate,SUM([Target]) [Target],SUM(ClmAmount) DiscAmount,
	CAST(0 AS NUMERIC(18,6)) L2MSales,CAST(0 AS NUMERIC(18,6)) CurMSales,CAST(0 AS NUMERIC(18,0)) Outlet
	INTO #Institutions
	FROM InsTargetDetailsTrans (NOLOCK) 
	--WHERE UserId = @Pi_UsrId AND SlNo <> 0 and SlNo<>9999
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
	
	--Nagarajan on 28.Aug.2017
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel1')
	BEGIN
		DROP TABLE RptDebitNoteTopSheet_Excel1	
	END	
	
	CREATE TABLE RptDebitNoteTopSheet_Excel1
	(
	[Scheme Description] VARCHAR(100),
	[From] VARCHAR(10),
	[To] VARCHAR(10),
	[Circular No] VARCHAR(100),
	[Date] NVARCHAR(10),
	[Scheme Budget] NUMERIC(18,6),
	[Sec Sales Qty] BIGINT,
	[Sec Sales Value] NUMERIC(18,6),
	[% Liability on Sec Sales] NUMERIC(18,6),
	[Claim Amount] NUMERIC(18,6)
	) 
	
		
	UPDATE #SchemeDebit SET Liab = (Amount / SecSalesVal) * 100 WHERE Liab > 0
	
	SELECT S.SchDsc [Scheme Description],CONVERT(VARCHAR(10),S.SchValidFrom,103) [From],CONVERT(VARCHAR(10),S.SchValidTill,103) [To],ISNULL(S.CircularNo,'') [Circular No],
	 CONVERT(VARCHAR(10),S.CircularDate,103)  [Date],S.SchemeBudget [Scheme Budget],[SecSalesQty] [Sec Sales Qty],[SecSalesVal] [Sec Sales Value],Liab [% Liability on Sec Sales],Amount [Claim Amount],'A' As Dummy
	INTO #RptDebitNoteTopSheet_Excel1
	FROM #SchemeDebit S (NOLOCK) WHERE Amount > 0
	
	DECLARE @RecCount AS BIGINT
	SELECT @RecCount = COUNT(7) FROM #RptDebitNoteTopSheet_Excel1
	
	IF (SELECT COUNT(*) FROM #RptDebitNoteTopSheet_Excel1) > 0
	BEGIN
		INSERT INTO #RptDebitNoteTopSheet_Excel1
		SELECT 'Total' [Scheme Description],'' [From],'' [To],'' [Circular No],'' [Date], 0 [Scheme Budget],
        0 [Sec Sales Qty], 0 [Sec Sales Value],0 [% Liability on Sec Sales],SUM([Claim Amount]) [Claim Amount],'B' Dummy
		FROM  #RptDebitNoteTopSheet_Excel1 
	END
	SELECT * INTO #Excel1 FROM #RptDebitNoteTopSheet_Excel1 ORDER BY Dummy
	
	INSERT INTO RptDebitNoteTopSheet_Excel1
	SELECT [Scheme Description],Cast([From] As Varchar(10)) [From],Cast([To] As Varchar(10)) [To],[Circular No],[Date],[Scheme Budget],
	[Sec Sales Qty],[Sec Sales Value],[% Liability on Sec Sales],[Claim Amount]
	FROM #Excel1
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel2')
	BEGIN
		DROP TABLE RptDebitNoteTopSheet_Excel2	
	END		
	CREATE TABLE RptDebitNoteTopSheet_Excel2
	(
		[Name Of the Category] NVARCHAR(200),
		[From] VARCHAR(10),
		[TO] VARCHAR(10),
		[Circular No] VARCHAR(50),
		[Monthly Target] NUMERIC(38,6),
	    [Last 2 Months Avg Sales] NUMERIC(18,6),
	    [Current Month] NUMERIC(18,6),
	    [No of Incentive Outlets] NUMERIC(18,0),
	    [Total Discount Amount] NUMERIC(38,6)
	)
	
	SELECT CtgName [Name Of the Category],convert(varchar(10),FromDate,103) [From],convert(varchar(10),ToDate,103) [To],'' [Circular No],[Target] [Monthly Target],
	L2MSales [Last 2 Months Avg Sales],CurMSales [Current Month],Outlet [No of Incentive Outlets],DiscAmount [Total Discount Amount],'A' Dummy
	INTO #RptDebitNoteTopSheet_Excel2
	FROM #Institutions (NOLOCK)
	IF (SELECT COUNT(*) FROM #RptDebitNoteTopSheet_Excel2) > 0
	BEGIN
----------------- modified by lakshman M on 04/10/2017----------------  
	 --INSERT INTO #RptDebitNoteTopSheet_Excel2   
	 --SELECT '' [Name Of the Category],'' [From],'' [To],'' [Circular No],'' [Monthly Target],    
	 --'' [Last 2 Months Avg Sales],'' [Current Month],'' [No of Incentive Outlets],sum([Total Discount Amount]) [Total Discount Amount],'B' Dummy    
	 --FROM #RptDebitNoteTopSheet_Excel2    
	 INSERT INTO #RptDebitNoteTopSheet_Excel2    
	 SELECT 0 As [Name Of the Category],0 As [From],0 As [To],0 As [Circular No],0 As [Monthly Target],    
	 0 As [Last 2 Months Avg Sales],0 As [Current Month],0 As [No of Incentive Outlets],sum([Total Discount Amount]) [Total Discount Amount],'B' Dummy    
	 FROM #RptDebitNoteTopSheet_Excel2 
	   
	 Update A set [Name Of the Category]= null ,[From]=null,[To]=null,[Monthly Target]=null,[Last 2 Months Avg Sales]=null  
	 ,[Current Month]=null,[No of Incentive Outlets]=null, [Total Discount Amount]=null,[Circular No]='' from #RptDebitNoteTopSheet_Excel2 A where Dummy ='B'  
  -------------------- Till here ----------------------------- 
	END
	
	SELECT * INTO #Excel2 FROM #RptDebitNoteTopSheet_Excel2 ORDER BY Dummy
	
	INSERT INTO RptDebitNoteTopSheet_Excel2
	SELECT [Name Of the Category],[From],[To],[Circular No],[Monthly Target],
	[Last 2 Months Avg Sales],[Current Month],[No of Incentive Outlets],[Total Discount Amount]
	FROM #Excel2

--------------------------------------------------------------TOT CLAIM Added By Mohana-------------------------------------------------------------------
	DECLARE @RecCount1 INT
	SELECT @RecCount1  = COUNT(*) FROM RptDebitNoteTopSheet_Excel2
	
	CREATE Table #TotClaimFinal 
	(
	CtgName		NVARCHAR(100),
	Fromdate	DATETIME,
	Todate	DATETIME,
	NrmlRate NUMERIC (18,2),
	SecSalesTot NUMERIC (18,2),
	DiffClaims NUMERIC (18,2)	
	)


	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,   
	B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue    
	INTO #BillingDetails1    
	FROM SalesInvoice S (NOLOCK)    
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId    
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1		 
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =3

	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,  
	B.DefaultPriceId ActualPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue  
	INTO #ReturnDetails1    
	FROM ReturnHeader S (NOLOCK)    
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID    
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId    
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =3

	SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName
	INTO #Retailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	
	SELECT tranid,Refid,Rtrid,CtgName,RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,SelRate,CAST(0 AS NUMERIC(18,2)) Nrmlrate,CAST(0 AS NUMERIC(18,2)) SplRate,CAST(0 AS NUMERIC(18,2)) Diff
	INTO #TotClaim FROM(
	SELECT 1 tranid,Salid Refid,A.Rtrid,CtgName,Salinvdate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate FROM #BillingDetails1 A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid 
	UNION 
	SELECT 2 Transid,ReturnID Refid,A.Rtrid,CtgName,ReturnDate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate FROM #ReturnDetails1  A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid 
	)A

	SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #TotClaim M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #TotClaim M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
 
	
	 UPDATE A SET A.SplRate = (BaseQty*B.SplselRate) FROM  #TotClaim A INNER JOIN #ExistingSpecialPrice B ON A.Priceid = B.Priceid WHERE A.Priceid <>0
	
	 UPDATE A SET A.SplRate = (BaseQty*SelRate) FROM  #TotClaim A WHERE A.Priceid =0
	
	 UPDATE A SET A.NrmlRate = (BaseQty*SelRate) FROM  #TotClaim A  
	 
	 
	 UPDATE A SET A.Diff = (NrmlRate-SplRate) FROM  #TotClaim A  
	 
	 INSERT INTO #TotClaimFinal(CtgName,NrmlRate,SecSalesTot,DiffClaims)
	 SELECT CtgName,SUM(NrmlRate),SUM(SplRate),SUM(Diff) FROM #TotClaim
	 GROUP BY Ctgname
	 
	 UPDATE A SET Fromdate = B.Frmdt ,Todate = B.todt FROM #TotClaimFinal A  INNER JOIN (SELECT Ctgname,MIn(RefDate) Frmdt,Max(RefDate) todt FROM #TotClaim GROUP BY CtgName) B ON A.CtgName = B.Ctgname
	 
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel3')
	BEGIN
		DROP TABLE RptDebitNoteTopSheet_Excel3	
	END		
	CREATE TABLE RptDebitNoteTopSheet_Excel3
	(
		[Name Of the Category] NVARCHAR(200),
		[From] DATETIME,
		[TO] DATETIME,
		[Total Normal amount] NUMERIC(18,2),
	    [Total  Normal  Sec Sales As Per TOT] NUMERIC(18,2),
	    [TOT Diff claims] NUMERIC(18,2) 
	)
	 
 	INSERT INTO RptDebitNoteTopSheet_Excel3
 	SELECT * FROM #TotClaimFinal
 	
	SET @RecCount = @RecCount + 1
	
	SET @RecCount1 = @RecCount1 +@RecCount + 1
	 
	-- Till here
		
	TRUNCATE TABLE RptExcelDebitNote  
	
	 
	INSERT INTO RptExcelDebitNote(Row,Col,MergeCells,Value)
	SELECT 1,1,'A1:J1','PARLE - DEBIT NOTE / CREDIT NOTE'
	UNION ALL
	SELECT 2,1,'A2:J2',''   --ICRSTPAR6933 (Row Number Changed OlRowNo+1)
	UNION ALL
	SELECT 3,1,'A3:H3','Name of the Town : ' + ISNULL(@CityName,'')
	UNION ALL
	SELECT 3,9,'I3:J3','Passed by SO / SE :'
	UNION ALL
	SELECT 4,1,'A4:F4','Name of the Wholesaler : ' + ISNULL(@DistributorName,'')
	UNION ALL
	SELECT 4,7,'G4:H4','Debit Note No :' + CONVERT(NVARCHAR(10),@DBMonth)
	UNION ALL
	SELECT 4,9,'I4:J4','Verified by ASM :'
	UNION ALL
	SELECT 5,1,'A5:F5','Wholesaler Code : ' + ISNULL(@DistributorCode,'')
	UNION ALL
	SELECT 5,7,'G5:H5','Credit Note No :'
	UNION ALL
	SELECT 5,9,'I5:J5','Authorized by DSM :'
	UNION ALL
	SELECT 6,1,'A6:F6','Name of the Division :'
	UNION ALL
	SELECT 6,7,'G6:H6','Credit Note Date :'
	UNION ALL
	SELECT 6,9,'I6:J6','Value of Approved credit note :'
	UNION ALL
	SELECT 7,1,'A7:J7',''
	UNION ALL	
	SELECT 8,1,'A8:J8','1.SAMPLING'
	UNION ALL
	SELECT 9,1,'A9:E9','DSM Sanction Letter Date '
	UNION ALL
	SELECT 9,6,'F9:J9','Sampling Amount : ' + CAST(@SamplingAmount AS VARCHAR(30))
	UNION ALL
	SELECT 10,1,'A10:D10','Product Sampled during the period  '
	UNION ALL
	SELECT 10,5,'E10:G10','From : ' + CONVERT(VARCHAR(11),@FromDate,105)
	UNION ALL
	SELECT 10,8,'H10:J10','To : ' + CONVERT(VARCHAR(11),@ToDate,105)
	UNION ALL
	SELECT 11,1,'A11:J11',''	
	UNION ALL
	SELECT 12,1,'A12:J12','2.TRADE SCHEME'	
	UNION ALL
	SELECT 13,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel1'
	UNION ALL
	SELECT 14,1,'A14','1R'	
	UNION ALL
	SELECT 14 + @RecCount + 1,1,'A' + CAST(14 + @RecCount + 1 AS VARCHAR(10)) + ':J' + CAST(14 + @RecCount + 1 AS VARCHAR(10)) ,'3.INSTITUTIONAL SALES'	
	UNION ALL
	SELECT 14 + @RecCount + 2,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel2'
	UNION ALL
	SELECT 14 + @RecCount + 3,1,'A' + CAST(14 + @RecCount + 3 AS VARCHAR(10)),'2R'
	UNION ALL
	SELECT 14 + @RecCount,1,'A' + CAST(14 + @RecCount AS VARCHAR(10)) + ':' + 'J' + CAST(14 + @RecCount AS VARCHAR(10)),''	
	UNION ALL--Added By Mohana
	SELECT 15,1,'A15','1R'
	UNION ALL
	SELECT 15 + @RecCount1 + 2,1,'A' + CAST(15 + @RecCount1 + 2 AS VARCHAR(10)) + ':J' + CAST(15 + @RecCount1 + 2 AS VARCHAR(10)) ,'4.TOT DIFF CLAIMS'	
	UNION ALL
 	SELECT 15 + @RecCount1 + 4,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel3'
 	UNION ALL
 	SELECT 15 + @RecCount1 + 6,1,'A' + CAST(15 + @RecCount1 + 6 AS VARCHAR(10)),'3R'
	UNION ALL
	SELECT 15 + @RecCount1+5,1,'A' + CAST(15 + @RecCount1+5 AS VARCHAR(10)) + ':' + 'J' + CAST(15 + @RecCount1+5 AS VARCHAR(10)),''	
	UNION ALL--Till Here
	SELECT 0,10,'B14','ColumnWidth'		
	UNION ALL
	SELECT 0,10,'C14','ColumnWidth'	
	UNION ALL
	SELECT 1,1,'-4108','HorizontalAlignment'
	UNION ALL
	SELECT 2,25,'2:6','RowHeight'	--ICRSTPAR6933
	
	RETURN	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_RailwayDiscountReconsolidation' AND TYPE='P')
DROP PROCEDURE Proc_Cs2Cn_RailwayDiscountReconsolidation
GO
/*  
Begin transaction  
update A set rptupload =0 from salesinvoice A  where SalInvDate between '2018-03-01'and'2018-03-30'
update a set RptUpload=0 from ReturnHeader a where returndate between '2018-03-01'and'2018-03-30'
exec Proc_Cs2Cn_RailwayDiscountReconsolidation 0,''  
select * from UploadingReportTransaction
select * from Cs2Cn_Prk_RailwayDiscountReconsolidation  
Rollback Transaction  
*/  
CREATE PROCEDURE Proc_Cs2Cn_RailwayDiscountReconsolidation  
(  
 @Po_ErrNo INT OUTPUT,  
 @ServerDate DATETIME  
)  
AS  
/*********************************  
* PROCEDURE  : Proc_Cs2Cn_RailwayDiscountReconsolidation   
* PURPOSE  :   
* CREATED BY : Aravindh Deva C  
* CREATED DATE : 03.06.2016  
* NOTE   :  
* MODIFIED  
************************************************************************************************************************
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 27-03-2018   S.MOhana     CR			CCRSTPAR0188		 Included reports changes in upload
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
 
 SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) FROM UploadingReportTransaction (NOLOCK)  
 
 
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
 AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  AND
 RC.CtgLinkId NOT IN (SELECT CtgMainId FROM RetailerCategory WHERE CtgCode='GT') 
 
 
 
 SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,  
 SP.PriceId,SP.SlNo,SP.PrdUom1EditedSelRate,(SP.PrdSchDiscAmount/SP.BaseQty) SchDisc  
 INTO #BillingDetails  
 FROM SalesInvoice S (NOLOCK)
 INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId  
 WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)  
 AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)  
 AND S.DlvSts > 3  
 
 SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,  
 SP.PriceId,SP.SlNo,SP.PrdEditSelRte,(SP.PrdSchDisAmt/SP.BaseQty) SchDisc  
 INTO #ReturnDetails  
 FROM ReturnHeader S (NOLOCK)  
 INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID  
 WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)  
 AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)  
 AND S.[Status] = 0  
 
 SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,CAST(0 AS NUMERIC(18,6))[SellRate],  
 CAST(0 AS NUMERIC(18,2)) IRCTCMargin,CAST(0 AS INT) [Type],CAST(0 AS NUMERIC(18,2)) AS LCTR,CAST(0 AS NUMERIC(18,2)) IRCTCRate,SchDisc
 INTO #RailwaySalesDetails  
 FROM   
 (  
 SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo,SchDisc FROM #BillingDetails  
 UNION ALL  
 SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo,SchDisc FROM #ReturnDetails  
 ) Consolidated  
 
 DECLARE @SlNo AS INT  
 SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'  
 UPDATE R SET R.[SellRate] = D.PrdBatDetailValue  
 FROM #RailwaySalesDetails R (NOLOCK),  
 ProductBatch B (NOLOCK),  
 ProductBatchDetails D (NOLOCK)  
 WHERE R.PrdBatId = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo   
 
	--SELECT R.PriceId,C.DiscountPerc,C.[TYPE],C.SplSelRate
	--INTO #ExistingSpecialPrice
	--FROM #RailwaySalesDetails R (NOLOCK),
	--SpecialRateAftDownLoad_Calc C (NOLOCK)
	--WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)
 
	SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate,S.DiscountPerc,Type
	INTO #SpecialPrice
	FROM SpecialRateAftDownLoad_Calc S (NOLOCK),
	#FilterRetailer R,
	Product P (NOLOCK), ProductBatch B (NOLOCK)
	WHERE S.RtrCtgValueCode = R.CtgCode AND
	S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId
	 	
	
	SELECT S.* 
	INTO #LatesSpecialPrice
	FROM #SpecialPrice S,
	(
		SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
		FROM #SpecialPrice
		GROUP BY RtrId,PrdId,PrdBatId
	) L
	WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate
	
	UPDATE R SET R.IRCTCMargin = S.DiscountPerc,R.[Type] = S.[TYPE]
	FROM #RailwaySalesDetails R (NOLOCK),
	#LatesSpecialPrice S (NOLOCK)
	WHERE R.Prdid = S.Prdid AND R.Rtrid = S.Rtrid AND R.Prdbatid = S.Prdbatid
 
	--UPDATE R SET R.LCTR = R.[SellRate] + (R.[SellRate]*(T.TaxPerc/100))
	--FROM #RailwaySalesDetails R (NOLOCK),
	--#ParleOutputTaxPercentage T (NOLOCK)
	--WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno	
	
	UPDATE R SET R.LCTR = R.[SellRate] 	FROM #RailwaySalesDetails R (NOLOCK)  
	
	SELECT DISTINCT Priceid,PrdBatDetailValue  INTO #SpecialPrice_New FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #RailwaySalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #RailwaySalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	
UPDATE M SET M.IRCTCRATE = D.PrdBatDetailValue-SchDisc 
FROM #RailwaySalesDetails M (NOLOCK),
#SpecialPrice_New D (NOLOCK) 
WHERE M.PriceId = D.PriceId  
	 
	 
UPDATE R SET R.IRCTCRATE = R.[SellRate] 	FROM #RailwaySalesDetails R (NOLOCK)  WHERE IRCTCRATE=0
	
	 
 SELECT RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,SUM(TotalPCS) TotalPCS,MRP,  
 LCTR,IRCTCMargin,CASE S.[Type] WHEN 1 THEN 'Mark Up' WHEN 2 THEN 'Mark Down' ELSE '' END MarkUpDown,  
 IRCTCRate,  CAST(0 AS NUMERIC(18,6)) TotalMRP,CAST(0 AS NUMERIC(18,6)) TotalLCTR,  
 CAST(0 AS NUMERIC(18,6)) IRCTCTotal,CAST(0 AS NUMERIC(18,6)) ClmAmount,  
 CAST(0 AS NUMERIC(18,2)) LibOnMRP,CAST(0 AS NUMERIC(18,2)) LibOnLCTR  
 INTO #RailwayDiscount  
 FROM #RailwaySalesDetails S (NOLOCK)  
 INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId  
 GROUP BY RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,MRP,LCTR,IRCTCMargin,S.[Type] ,IRCTCRate
 


UPDATE R SET TotalMRP  = TotalPCS * MRP, 
	TotalLCTR = TotalPCS * LCTR
	FROM #RailwayDiscount R (NOLOCK)
 
 
 UPDATE R SET R.IRCTCTotal = TotalPCS * IRCTCRate  
 FROM #RailwayDiscount R (NOLOCK)  
 
 UPDATE R SET R.ClmAmount = TotalLCTR - IRCTCTotal  
 FROM #RailwayDiscount R (NOLOCK)  
	
	UPDATE R SET R.LibOnMRP = (ClmAmount / TotalMRP)*100
	FROM #RailwayDiscount R (NOLOCK)
	WHERE R.TotalMRP <> 0
	
	UPDATE R SET R.LibOnLCTR = (ClmAmount / TotalLCTR)*100
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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_MTDebitSummary]') AND type in (N'U'))
DROP TABLE [dbo].[Cs2Cn_Prk_MTDebitSummary]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_MTDebitSummary](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[TransDate] [datetime] NULL,
	[CmpRtrCode] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[TotalLCTR] [numeric](18, 6) NULL,
	[SalesTOT] [numeric](18, 6) NULL,
	[ClaimDiff] [numeric](18, 6) NULL,
	[LiabSales] [numeric](18, 6) NULL,
	[TotalOffLCTR] [numeric](18, 6) NULL,
	[OffTOT] [numeric](18, 6) NULL,
	[TotalOff] [numeric](18, 6) NULL,
	[OffClaimDiff] [numeric](18, 6) NULL,
	[LiabOff] [numeric](18, 6) NULL,
	[TotalSales] [numeric](18, 6) NULL,
	TotSalTOChain  [numeric](18, 6) NULL,
	GrandTotClm  [numeric](18, 6) NULL,
	[LiabWOTOT] [numeric](18, 6) NULL,
	[LiabTOT] [numeric](18, 6) NULL,
	OffLIABTtotalSales  [numeric](18, 6) NULL,
	TOTLiabTotal  [numeric](18, 6) NULL,
	[TotalLiab] [numeric](18, 6) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_MTDebitSummary_New' AND TYPE='P')
DROP PROCEDURE Proc_Cs2Cn_MTDebitSummary_New
GO
/*
BEGIN TRAN
EXEC Proc_Cs2Cn_MTDebitSummary_New 0,''
SELECT * FROM Cs2Cn_Prk_MTDebitSummary a  
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Cs2Cn_MTDebitSummary_New
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_MTDebitSummary 
* PURPOSE		: Proc_Cs2Cn_MTDebitSummary (Create for report changes
* CREATED BY	: MOHANA --CCRSTPAR0188
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
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
	WHERE 
	R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId AND
	RC.CTGCODE IN (SELECT CtgCode FROM RetailerCategory A 
	WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A(NOLOCK) where CtgCode NOT IN ('GT')))
	
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
	
	SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) 
	FROM UploadingReportTransaction (NOLOCK)	
	
	
	
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid ,SP.SlNo,SP.PrdUom1EditedSelRate,B.DefaultPriceId,
	Cast((SP.PrdSchDiscAmount/SP.BaseQty)AS NUMERIC(18,6)) Schdisc
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE S.DlvSts > 3 AND S.SalInvDate BETWEEN @FromDate AND @ToDate
	--AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdEditSelRte,B.DefaultPriceId,
	Cast((SP.PrdSchDisAmt/Sp.BaseQty) AS NUMERIC(18,6)) RtnSchdisc
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND  SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE S.Status = 0 AND S.ReturnDate BETWEEN @FromDate AND @ToDate
	--AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)


	SELECT Salid,RTRid,Schid INTO #SalScheme FROM (
	Select Distinct SI.Salid,RTRid,Schid from Salesinvoice SI(NOLOCK) INNER JOIN SalesInvoiceSchemeLineWise SH(NOLOCK) ON SI.Salid=SH.Salid
	WHERE   Dlvsts in (4,5) AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	UNION 
	Select Distinct SI.Salid,RTRid,Schid from Salesinvoice SI(NOLOCK) INNER JOIN SalesInvoiceSchemeDtFreePrd SH(NOLOCK) ON SI.Salid=SH.Salid
	WHERE Dlvsts in (4,5) AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	)A
	
	SELECT ReturnId,RTRid,Schid INTO #RtnScheme FROM (
	Select Distinct A.Returnid,RTRid,Schid FROM ReturnSchemeLineDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	WHERE   B.Status = 0  AND B.ReturnDate BETWEEN @FromDate AND @ToDate
	UNION
	Select Distinct A.Returnid,RTRid,Schid FROM ReturnSchemeFreePrdDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	WHERE  B.Status = 0  AND B.ReturnDate BETWEEN @FromDate AND @ToDate
	)A
	
 	SELECT Salid,RTRid, Schid,A.Prdid INTO #SalSchemeProducts FROM
	 (
		SELECT DISTINCT Salid,RTRid,A.Schid, B.Prdid FROM #SalScheme A(NOLOCK)
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN Product C(NOLOCK) On B.Prdid = C.PrdId
		UNION
		SELECT DISTINCT Salid,RTRid,A.Schid, E.Prdid FROM #SalScheme A(NOLOCK)
		INNER JOIN SchemeProducts B (NOLOCK)ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C (NOLOCK) ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D(NOLOCK) ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E(NOLOCK) On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F(NOLOCK) On
		F.PrdId = E.Prdid
	)A 
	
	
	 	SELECT DISTINCT ReturnId,RTRid,Schid,A.Prdid INTO #RtnSchemeProducts FROM
	 (
		SELECT DISTINCT ReturnId,RTRid,A.Schid, B.Prdid FROM #RtnScheme A
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN Product C(NOLOCK) On B.Prdid = C.PrdId
		UNION
		SELECT DISTINCT ReturnId,RTRid,A.Schid, E.Prdid FROM #RtnScheme A
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C(NOLOCK) ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D(NOLOCK) ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E(NOLOCK) On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F(NOLOCK) On
		F.PrdId = E.Prdid
	)A  
	
	SELECT DISTINCT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],DefaultPriceId,SchDisc,Type,
	CAST(0 AS NUMERIC(18,6))[ActualSellRate],CAST(0 AS NUMERIC(18,6))[SpecialSellRate],
	CAST(0 AS NUMERIC(18,6)) NrmlLCTR, CAST(0 AS NUMERIC(18,6)) NrmlSecSalesTOT, CAST(0 AS NUMERIC(18,6)) TOTDifClms
	, CAST(0 AS NUMERIC(18,6)) OfferLCTR, CAST(0 AS NUMERIC(18,6)) OffSecSalesTOT, CAST(0 AS NUMERIC(18,6)) TotOffSalesChain,
	 CAST(0 AS NUMERIC(18,6)) OffClmDiff
	INTO #MTSalesDetails
	FROM 
	(
	SELECT DISTINCT 1 TransType,A.RtrId,A.SalId,SalInvDate TransDate,A.PrdId,A.PrdBatId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate],DefaultPriceId,
	SchDisc,CASE ISNULL(B.Salid,0) WHEN 0 THEN 'NS' ELSE 'S' END AS Type
	FROM #BillingDetails A(NOLOCK)
	LEFT OUTER JOIN #SalSchemeProducts B(NOLOCK) ON A.Salid = B.salid AND A.Prdid=B.Prdid AND A.Rtrid =B.Rtrid
	UNION ALL
	SELECT  DISTINCT 2 TransType,A.RtrId,A.ReturnID,ReturnDate TransDate,A.PrdId,A.PrdBatId, BaseQty,MRP,PriceId,SlNo,PrdEditSelRte,DefaultPriceId,
	RtnSchDisc,CASE ISNULL(B.ReturnID,0) WHEN 0 THEN 'NS' ELSE 'S' END AS Type
	FROM #ReturnDetails A(NOLOCK)
	LEFT OUTER JOIN #RtnSchemeProducts B(NOLOCK) ON A.Returnid = B.Returnid AND A.Prdid=B.Prdid AND A.Rtrid =B.Rtrid
	) A
	
 
	
	DECLARE @SlNo AS INT
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'

	SELECT DISTINCT Priceid,PrdBatDetailValue  INTO #SpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = @SlNo
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = @SlNo
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	UPDATE M SET M.[SpecialSellRate] = D.PrdBatDetailValue
	FROM #MTSalesDetails M (NOLOCK),
	#SpecialPrice D (NOLOCK) 
	WHERE M.PriceId = D.PriceId  
	
	UPDATE A SET ActualSellRate = C.PrdBatDetailValue FROM #MTSalesDetails A INNER JOIN ProductBatch B ON A.Prdid = B.PrdId AND A.Prdbatid = B.PrdBatId
	INNER JOIN 	ProductBatchDetails C ON B.DefaultPriceid = C.PriceId  AND C.SLNo = @SlNo
	
		--Non Scheme
	UPDATE A SET NrmlLCTR = TotalPcs*ActualSellrate FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
		
	UPDATE A SET NrmlSecSalesTot = ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*ActualSellrate) ELSE (TotalPcs*SpecialSellRate) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
	
	UPDATE A SET TotDifClms  = NrmlLCTR-NrmlSecSalesTot FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'


	--Scheme
	
	UPDATE A SET OfferLCTR = TotalPcs*ActualSellrate FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
		
	UPDATE A SET OffSecSalesTOT = ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*ActualSellrate) ELSE (TotalPcs*SpecialSellRate) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
	
	UPDATE A SET TotOffSalesChain =  ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*(ActualSellrate-SchDisc)) ELSE (TotalPcs*(SpecialSellRate-SchDisc)) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
	UPDATE A SET OffClmDiff = OfferLCTR-TotOffSalesChain FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'

	SELECT D.RtrId,TransDate,Prdid,SUM(NrmlLCTR) NrmlLCTR,SUM(NrmlSecSalesTOT) NrmlSecSalesTOT,SUM(TOTDifClms) TOTDifClms,SUM(OfferLCTR) OfferLCTR,
	SUM(OffSecSalesTOT) OffSecSalesTOT,	SUM(OffClmDiff) OffClmDiff,SUM(TotOffSalesChain) TotOffSalesChain,	CAST(0 AS NUMERIC(18,6)) LIABNormalSale,
	CAST(0 AS NUMERIC(18,6)) OffLIABValue,CAST(0 AS NUMERIC(18,6)) TotalSales,CAST(0 AS NUMERIC(18,6)) LIABOffClmWITHOUTTOT,
	CAST(0 AS NUMERIC(18,6)) LIABOffClmTotalSale,CAST(0 AS NUMERIC(18,6)) GrandTotClm,
	CAST(0 AS NUMERIC(18,6)) TOTALLIAB ,CAST(0 AS NUMERIC(18,6)) TotSalTOChain,CAST(0 AS NUMERIC(18,6)) OffLIABTtotalSales,CAST(0 AS NUMERIC(18,6)) TOTLiabTotal
	INTO #MTFinal
	FROM #MTSalesDetails D (NOLOCK) INNER JOIN #FilterRetailer B ON D.Rtrid = B.Rtrid 
	GROUP BY  D.RtrId,Prdid,TransDate
	
	UPDATE A SET LIABNormalSale = (TotDifClms/NrmlLCTR)*100  FROM #MTFinal A(NOLOCK)  WHERE NrmlLCTR>0

	UPDATE A SET OffLiabvalue = OffSecSalesTOT-TotOffSalesChain  FROM #MTFinal A(NOLOCK) 
	 
	UPDATE A SET TotalSales = OfferLCTR+NrmlLCTR FROM #MTFinal A(NOLOCK) 
		
	UPDATE A SET LIABOffClmWITHOUTTOT = (OffLiabvalue/OfferLCTR)*100 FROM #MTFinal A(NOLOCK) WHERE OfferLCTR>0
	
	UPDATE A SET LIABOffClmTotalSale  = (OffClmDiff/OfferLCTR)*100  FROM #MTFinal A(NOLOCK)     WHERE OfferLCTR>0
		
	UPDATE A SET GrandTotClm  = 	(OffClmDiff+TotDifClms)   FROM #MTFinal A(NOLOCK) 
		
	UPDATE A SET TOTALLIAB  = 	(GrandTotClm/TotalSales)*100   FROM #MTFinal A(NOLOCK) WHERE [TotalSales] > 0	
	
	UPDATE A SET TotsaltoChain  = NrmlSecsalesTOT+ TotOffSalesChain    FROM #MTFinal A(NOLOCK) 	
	
	UPDATE A SET OffLIABTtotalSales  = 	(OffLIABValue/TotalSales)*100   FROM #MTFinal A(NOLOCK) WHERE [TotalSales] > 0
	
	UPDATE A SET TOTLiabTotal  = 	((GrandTotClm-OffLIABValue)/TotalSales)*100   FROM #MTFinal A(NOLOCK)  WHERE [TotalSales] > 0
	

	INSERT INTO Cs2Cn_Prk_MTDebitSummary(dISTcODE,TransDate,CmpRtrCode,PrdCCode,TotalLCTR,SalesTOT,ClaimDiff,LiabSales,TotalOffLCTR,OffTOT,
	TotalOff,OffClaimDiff,LiabOff,TotalSales,TotSalTOChain,GrandTotClm,LiabWOTOT,LiabTOT,OffLIABTtotalSales,TOTLiabTotal,TotalLiab
	)
	SELECT @DistCode,TransDate,B.CmpRtrCode,C.PrdCCode,ROUND(NrmlLCTR,2,1) NrmlLCTR,ROUND(NrmlSecSalesTOT,2,1) NrmlSecSalesTOT,ROUND(TOTDifClms,2,1) TOTDifClms,
	ROUND(LIABNormalSale,2,1) LIABNormalSale,	ROUND(OfferLCTR,2,1) OfferLCTR,ROUND(OffSecSalesTOT,2,1) OffSecSalesTOT,
	ROUND(TotOffSalesChain,2,1) TotOffSalesChain,ROUND(OffClmDiff,2,1) OffClmDiff,
	ROUND(OffLIABValue,2,1) OffLIABValue,ROUND(TotalSales,2,1) TotalSales,ROUND(TotSalTOChain,2,1) TotSalTOChain,ROUND(GrandTotClm,2,1) GrandTotClm,
	ROUND(LIABOffClmWITHOUTTOT,2,1) LIABOffClmWITHOUTTOT,ROUND(LIABOffClmTotalSale,2,1) LIABOffClmTotalSale,ROUND(OffLIABTtotalSales,2,1) OffLIABTtotalSales,
	ROUND(TOTLiabTotal,2,1) TOTLiabTotal,ROUND(TOTALLIAB,2,1) TOTALLIAB
	FROM #MTFinal A
	INNER JOIN Retailer B ON A.Rtrid  = B.RtrId
	INNER JOIN Product C ON A.Prdid = C.Prdid 
	
	
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_MTDebitSummary' AND TYPE='P')
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
------------------------------------------------
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 14-12-2017   S.Moorthi   CR			ICRSTPAR7049		 Only MT & IRCTC category details should display in report
 27-03-2018   S.MOhana     CR			CCRSTPAR0188		 Included reports changes in upload(Commented and added by Mohana)

*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	EXEC Proc_Cs2Cn_MTDebitSummary_New @Po_ErrNo,@ServerDate
	
	--DECLARE @DistCode As NVARCHAR(50)
	--DELETE FROM Cs2Cn_Prk_MTDebitSummary WHERE UploadFlag = 'Y'
	
	--IF NOT EXISTS (SELECT '' FROM UploadingReportTransaction (NOLOCK))
	--BEGIN
	--	RETURN
	--END
	--SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	----To Filter Retailers
	--SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName,RC.CtgCode
	--INTO #FilterRetailer
	--FROM Retailer R (NOLOCK),
	--RetailerValueClassMap RVCM (NOLOCK),
	--RetailerValueClass RVC (NOLOCK),
	--RetailerCategory RC (NOLOCK),
	--RetailerCategoryLevel RCL (NOLOCK)	
	--WHERE 
	--RC.CTGCODE IN (SELECT CtgCode FROM RetailerCategory A 
	--WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A where CtgCode in ('IRCTC','NC','SSO')))
	
	--DECLARE @FromDate DATETIME
	--DECLARE @ToDate DATETIME
	
	--SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) 
	--FROM UploadingReportTransaction (NOLOCK)	
	--EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate
	--SELECT * INTO #ParleOutputTaxPercentage
	--FROM ParleOutputTaxPercentage (NOLOCK)
	--SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	--SP.PriceId,SP.SlNo,SP.PrdUom1EditedSelRate,B.DefaultPriceId
	--INTO #BillingDetails
	--FROM SalesInvoice S (NOLOCK)
	--INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	--INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	--WHERE S.DlvSts > 3
	--AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	
	--SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	--SP.PriceId,SP.SlNo,SP.PrdEditSelRte,B.DefaultPriceId
	--INTO #ReturnDetails
	--FROM ReturnHeader S (NOLOCK)
	--INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	--INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	--WHERE S.Status = 0
	--AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)
	--SELECT TransType,RtrId,SalId,TransDate,PrdId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],DefaultPriceId,
	--CAST(0 AS NUMERIC(18,6))[ActualSellRate],CAST(0 AS NUMERIC(18,6))[SpecialSellRate],
	--CAST(0 AS NUMERIC(18,6)) TotalLCTR, CAST(0 AS NUMERIC(18,6)) SalesTOT
	--INTO #MTSalesDetails
	--FROM 
	--(
	--SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate],DefaultPriceId FROM #BillingDetails
	
	--UNION ALL
	
	--SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,BaseQty,MRP,PriceId,SlNo,PrdEditSelRte,DefaultPriceId FROM #ReturnDetails
	
	--) Consolidated
	
	--SELECT M.TransType,M.SalId,M.RtrId,M.PrdId,M.SlNo,K.PrdId [NormalPrd],K.PrdBatId [NormalBat],
	--CAST(0 AS NUMERIC(18,6)) NormalSellRate,CAST(0 AS NUMERIC(18,6)) NormalSpecialRate
	--INTO #NormalProduct
	--FROM #MTSalesDetails M,
	--KitProductTransDt K (NOLOCK)
	--WHERE M.SalId = K.TransNo AND M.PrdId = K.KitPrdId AND M.SlNo = K.SlNo
	--AND K.TransId = (CASE M.TransType WHEN 2 THEN 8 ELSE 1 END) -- TransId = 1 - Billing, 8 - Sales Return
	
	--DECLARE @SlNo AS INT
	--SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	--UPDATE M SET M.ActualSellRate = D.PrdBatDetailValue
	--FROM #MTSalesDetails M (NOLOCK),
	--ProductBatchDetails D (NOLOCK) 
	--WHERE M.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	--UPDATE M SET M.[SpecialSellRate] = D.PrdBatDetailValue
	--FROM #MTSalesDetails M (NOLOCK),
	--ProductBatchDetails D (NOLOCK) 
	--WHERE M.PriceId = D.PriceId AND D.SLNo = @SlNo
	--AND PriceCode LIKE '%-Spl Rate-%'
	----
	--UPDATE N SET N.NormalSellRate = D.PrdBatDetailValue
	--FROM #NormalProduct N (NOLOCK),
	--ProductBatch B (NOLOCK),
	--ProductBatchDetails D (NOLOCK)
	--WHERE N.NormalBat = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	
	--UPDATE M SET M.[ActualSellRate] = N.NormalSellRate
	--FROM #MTSalesDetails M,
	--(
	--SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSellRate) NormalSellRate FROM #NormalProduct
	--GROUP BY TransType,SalId,PrdId,SlNo
	--) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo
	----
	
	--SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate
	--INTO #SpecialPrice
	--FROM SpecialRateAftDownLoad S (NOLOCK),
	--#FilterRetailer R,
	--Product P (NOLOCK), ProductBatch B (NOLOCK)
	--WHERE S.RtrCtgValueCode = R.CtgCode AND
	--S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId
	--AND EXISTS (SELECT 'C' FROM #NormalProduct N (NOLOCK) WHERE P.PrdId = N.NormalPrd)	
	--SELECT S.* 
	--INTO #LatesSpecialPrice
	--FROM #SpecialPrice S,
	--(
	--	SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
	--	FROM #SpecialPrice
	--	GROUP BY RtrId,PrdId,PrdBatId
	--) L
	--WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate
	--UPDATE N SET N.NormalSpecialRate = L.SplSelRate
	--FROM #NormalProduct N (NOLOCK),
	--#LatesSpecialPrice L (NOLOCK)
	--WHERE N.RtrId = L.RtrId AND N.NormalPrd = L.PrdId AND N.NormalBat = L.PrdBatId
	
	--UPDATE M SET M.[SpecialSellRate] = N.NormalSpecialRate
	--FROM #MTSalesDetails M,
	--(
	--SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSpecialRate) NormalSpecialRate FROM #NormalProduct
	--GROUP BY TransType,SalId,PrdId,SlNo
	--) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo		
	--UPDATE R SET R.TotalLCTR =  R.TotalPCS * (R.[ActualSellRate]+(R.[ActualSellRate]*(T.TaxPerc/100))),
	--R.SalesTOT = R.TotalPCS * (R.[SpecialSellRate]+(R.[SpecialSellRate]*(T.TaxPerc/100)))
	--FROM #MTSalesDetails R (NOLOCK),
	--#ParleOutputTaxPercentage T (NOLOCK)
	--WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno
	
	--SELECT M.RtrId,TransDate,M.PrdId,P.PrdCCode,SUM(CASE P.PrdType WHEN 3 THEN 0 ELSE TotalLCTR END) TotalLCTR,
	--SUM(CASE P.PrdType WHEN 3 THEN 0 ELSE SalesTOT END) SalesTOT,
	--CAST(0 AS NUMERIC(18,2)) [ClaimDiff], CAST(0 AS NUMERIC(18,2)) [LiabSales],
	--SUM(CASE P.PrdType WHEN 3 THEN TotalLCTR ELSE 0 END) [TotalOffLCTR],
	--SUM(CASE P.PrdType WHEN 3 THEN SalesTOT ELSE 0 END) [OffTOT],
	--CAST(0 AS NUMERIC(18,2)) [TotalOff],CAST(0 AS NUMERIC(18,2)) [OffClaimDiff],
	--CAST(0 AS NUMERIC(18,2)) [LiabOff],CAST(0 AS NUMERIC(18,2)) [TotalSales],
	--CAST(0 AS NUMERIC(18,2)) [LiabWOTOT],CAST(0 AS NUMERIC(18,2)) [LiabTOT],CAST(0 AS NUMERIC(18,2)) [TotalLiab]
	--INTO #DebitNote
	--FROM #MTSalesDetails M,
	--Product P (NOLOCK) 
	--WHERE M.PrdId = P.PrdId
	--GROUP BY M.RtrId,TransDate,M.PrdId,P.PrdCCode
	
	--UPDATE D SET [ClaimDiff] = TotalLCTR - SalesTOT, [TotalOff] = [TotalOffLCTR] - [OffTOT]
	--FROM #DebitNote D (NOLOCK)
	--UPDATE D SET [LiabSales] = [ClaimDiff] / TotalLCTR
	--FROM #DebitNote D (NOLOCK)
	--WHERE TotalLCTR <> 0
	--UPDATE D SET [OffClaimDiff] = [TotalOffLCTR] - [TotalOff]
	--FROM #DebitNote D (NOLOCK)
	--UPDATE D SET [LiabOff] = [OffTOT] - [TotalOff]
	--FROM #DebitNote D (NOLOCK)	
	--UPDATE D SET [TotalSales] = TotalLCTR + [TotalOffLCTR]
	--FROM #DebitNote D (NOLOCK)
	
	--UPDATE D SET [LiabWOTOT] = [LiabOff] / [TotalSales]
	--FROM #DebitNote D (NOLOCK)	
	--WHERE [TotalSales] <> 0
	--UPDATE D SET [LiabTOT] = [TotalOffLCTR] / [TotalSales]
	--FROM #DebitNote D (NOLOCK)
	--WHERE [TotalSales] <> 0		
	--UPDATE D SET [TotalLiab] = ([ClaimDiff] + [OffClaimDiff])/[TotalSales]
	--FROM #DebitNote D (NOLOCK)
	--WHERE [TotalSales] <> 0	
	
	----ICRSTPAR7049
	--UPDATE D SET [LiabSales] = [LiabSales]/100.00,
	--LiabWOTOT=LiabWOTOT/100.00,LiabTOT=LiabTOT/100.00,TotalLiab=TotalLiab/100.00
	--FROM #DebitNote D (NOLOCK)
	----Till Here ICRSTPAR7049
	
	--INSERT INTO Cs2Cn_Prk_MTDebitSummary (DistCode,TransDate,CmpRtrCode,PrdCCode,TotalLCTR,SalesTOT,ClaimDiff,LiabSales,
	--TotalOffLCTR,OffTOT,TotalOff,OffClaimDiff,LiabOff,TotalSales,LiabWOTOT,LiabTOT,TotalLiab,UploadFlag,SyncId,ServerDate)
	--SELECT @DistCode,TransDate,R.CmpRtrCode,PrdCCode,
	--SUM(TotalLCTR) TotalLCTR,
	--SUM(SalesTOT) SalesTOT,
	--SUM(ClaimDiff) ClaimDiff,
	--SUM(LiabSales) LiabSales,
	--SUM(TotalOffLCTR) TotalOffLCTR,
	--SUM(OffTOT) OffTOT,
	--SUM(TotalOff) TotalOff,
	--SUM(OffClaimDiff) OffClaimDiff,
	--SUM(LiabOff) LiabOff,
	--SUM(TotalSales) TotalSales,
	--SUM(LiabWOTOT) LiabWOTOT,
	--SUM(LiabTOT) LiabTOT,
	--SUM(TotalLiab) TotalLiab,'N' UploadFlag,NULL,@ServerDate
	--FROM #DebitNote D (NOLOCK),
	--Retailer R (NOLOCK)
	--WHERE D.RtrId = R.RtrId
	--GROUP BY TransDate,R.CmpRtrCode,PrdCCode
	RETURN			
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_ChainWiseBillDetails' AND TYPE='P')
DROP PROCEDURE Proc_Cs2Cn_ChainWiseBillDetails
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_ChainWiseBillDetails 0,'2014-02-04'
--select distinct * from Cs2Cn_Prk_ChainWiseBillDetails order by Billno
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
-----------------------------------------------
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 27-03-2018   S.MOhana     CR			CCRSTPAR0188		 Included reports changes in upload	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	CREATE TABLE #ChainSalesDetails
	(
		[SalId] [bigint] NOT NULL,
		[SalInvNo] [nvarchar](50) NOT NULL,
		[SalInvDate] [datetime] NOT NULL,
		[RtrId] [int] NOT NULL,
		[PrdId] [int] NOT NULL,
		[TotalPCS] [numeric](38, 0) NULL,
		[MRP] [numeric](18, 6) NOT NULL,
		[PriceId] [int] NOT NULL,
		[PrdBatid] [int] NOT NULL,
		[ChainLandRate] [numeric](18, 6) NULL,
		[SchemeDiscount] [numeric](18, 6) NULL
	)
	
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
	and  CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A(NOLOCK) where CtgCode NOT IN ('GT'))
	
	--To Filter Retailers
	INSERT INTO #ChainSalesDetails
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SUM(SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.PrdBatid,
	CAST(0 AS NUMERIC(18,6)) ChainLandRate,SUM(SP.PrdSchDiscAmount) SchDisc
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND S.DlvSts > 3  
	GROUP BY S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.PriceId,SP.SplPriceid,SP.PrdBatid
	UNION ALL
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SUM(-1*SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.PrdBatid,
	CAST(0 AS NUMERIC(18,6)) ChainLandRate,SUM(SP.PrdSchDisAmt) SchDisc
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	WHERE  EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)
	 AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)  
	GROUP BY S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.SplPriceid,SP.PriceId,SP.PrdBatid
	
	UPDATE #ChainSalesDetails SET SchemeDiscount = (SchemeDiscount/TotalPCS)
	
	SELECT DISTINCT C.PrdBatid,C.Priceid,C.PrdbatDetailValue INTO #NormalPrice FROM #ChainSalesDetails A INNER JOIN Productbatch B ON A.Prdbatid=B.PrdBatid
	INNER JOIN ProductBatchDetails C ON  B.PRDBATID = C.PRDBATID AND DEFAULTPRICE = 1
	and SLNO=3	
	
	--ADDED BY MOHANA
	
	SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #ChainSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #ChainSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	
	UPDATE R SET R.ChainLandRate = S.SplSelRate-R.SchemeDiscount
	FROM #ChainSalesDetails R (NOLOCK),
	#ExistingSpecialPrice S (NOLOCK)
	WHERE R.PriceId = S.PriceId
	
	UPDATE A SET A.ChainLandRate = (B.PrdbatDetailValue-A.SchemeDiscount) FROM #ChainSalesDetails A INNER JOIN #NORMALPRICE B ON A.PRDBATID=B.PRDBATID WHERE A.ChainLandRate=0  

	
	--SELECT S.SalId,S.SalInvNo BillNo,S.SalInvDate BillDate,S.RtrId,R.RtrName,R.CmpRtrCode,P.PrdId,P.PrdName,P.PrdCCode,
	--PrdWgt PktWgt,MRP,TotalPCS QtyInPkt,PriceId,ChainLandRate,
	--CAST(0 AS NUMERIC(18,6)) Amount
	--INTO #Chain
	--FROM #ChainSalesDetails S (NOLOCK)
	--INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	--INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	
	 
	SELECT S.SalId,S.SalInvNo BillNo,CONVERT(VARCHAR(10),S.SalInvDate,121) as  BillDate,S.RtrId,R.RtrName,R.CmpRtrCode,P.PrdId,P.PrdName,P.PrdCCode,
	PrdWgt PktWgt,MRP,TotalPCS QtyInPkt,ChainLandRate, --ICRSTPAR7049
	CAST(0 AS NUMERIC(18,2)) Amount
	INTO #Chain
	FROM #ChainSalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	INNER JOIN #FilterRetailer F ON S.Rtrid = F.Rtrid AND R.Rtrid = F.Rtrid
	
	UPDATE C SET C.Amount = QtyInPkt * ChainLandRate
	FROM #Chain C (NOLOCK)
	
	select BillNo,PrdId,QtyInPkt,ROUND(ChainLandRate,2,1),ROUND(Amount,2,1)  from #Chain order by  billno,prdid 
	
	INSERT INTO Cs2Cn_Prk_ChainWiseBillDetails (DistCode,BillNo,BillDate,CmpRtrCode,PrdCCode,PktWgt,PktMRP,QtyInPkt,
	ChainLandRate,Amount,UploadFlag,SyncId,ServerDate)
	SELECT @DistCode,BillNo,BillDate,CmpRtrCode,PrdCCode,PktWgt,MRP,QtyInPkt,ROUND(ChainLandRate,2,1),ROUND(Amount,2,1),
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
--Mohana.S Till Here
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='TrgAfterInsertDistributorInfo' AND XTYPE='TR')
DROP TRIGGER TrgAfterInsertDistributorInfo
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.12' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.12',435
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 435)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(435,'D','2018-04-12',GETDATE(),1,'Core Stocky Service Pack 435')
GO