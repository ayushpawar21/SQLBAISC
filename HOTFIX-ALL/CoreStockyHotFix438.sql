--[Stocky HotFix Version]=438
DELETE FROM Versioncontrol WHERE Hotfixid='438'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('438','3.1.0.15','D','2019-01-18','2019-01-18','2019-01-18',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product June 2018')
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Tbl_SFAConfiguration' AND xtype='U')
BEGIN
CREATE TABLE Tbl_SFAConfiguration(
	[CId] [int] NOT NULL,
	[CName] [nvarchar](50) NULL,
	[CValue] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[CId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT * FROM Tbl_SFAConfiguration(NOLOCK))
BEGIN
	INSERT INTO Tbl_SFAConfiguration([CId],[CName],[CValue])
	SELECT 1,'Password','admin@123' UNION
	SELECT 2,'LastExportDate',NULL UNION
	SELECT 3,'LastImportDate',NULL UNION
	SELECT 4,'LastModifiedDate','Oct 14 2018  5:58PM' UNION
	SELECT 5,'AverageSales','0' UNION
	SELECT 6,'PendingInvoices','30' UNION
	SELECT 7,'WebserviceURL','https://xdintegration.vxceed.net/IntegrationService.svc?wsdl' UNION
	SELECT 8,'DeveloperKey',DistributorCode from Distributor UNION
	SELECT 9,'UserName','sysadmin'
END
GO
UPDATE Tbl_SFAConfiguration SET [CValue]=30 WHERE [CName]='PendingInvoices'
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Tbl_WSUploadIntegration' AND xtype='U')
DROP TABLE Tbl_WSUploadIntegration
GO
CREATE TABLE Tbl_WSUploadIntegration(
	[ProcessId]   [INT] ,
	[ProcessName] [varchar](100) ,
	[PrkTableName][varchar](200) ,
	[SPName]	  [varchar](200) ,
	[Enable]	  [INT],
	[Status]	  [INT],
	[CreatedDate] [datetime],
	[LastUpdatedDate] [datetime]
) ON [PRIMARY]
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Tbl_WSDownloadIntegration' AND xtype='U')
DROP TABLE Tbl_WSDownloadIntegration
GO
CREATE TABLE Tbl_WSDownloadIntegration(
	[ProcessId]		[INT] ,
	[ProcessName]	[varchar](100) ,
	[PrkTableName]	[varchar](200) ,
	[ImportSPName]	[varchar](200) ,
	[Enable]		[INT],
	[Status]		[INT],
	[ValidateSP]	[varchar](200) ,
	[CreatedDate]	[datetime],
	[LastUpdatedDate] [datetime] 
) ON [PRIMARY]
GO
DELETE FROM Tbl_WSUploadIntegration
INSERT INTO Tbl_WSUploadintegration([ProcessId],[ProcessName],[PrkTableName],[SPName],[Enable],[Status],[CreatedDate],[LastUpdatedDate])
SELECT 1,'Product HierarchyV1','Export_CS2WS_ProductCategory','Proc_Export_CS2WS_ProductCategory',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 2,'Customer HierarchyV1','Export_CS2WS_CustomerHierarchyV1','Proc_Export_CS2WS_CustomerHierarchyV1',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 3,'Product','Export_CS2WS_Product','Proc_Export_CS2WS_Product',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 4,'Pricing Plan','Export_CS2WS_PricingPlan','Proc_Export_CS2WS_PricingPlan',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 5,'Customer Category','Export_CS2WS_CustomerCategory','Proc_Export_CS2WS_CustomerCategory',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 6,'Customer','Export_CS2WS_Customer','Proc_Export_CS2WS_Customer',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 7,'Authorized Product','Export_CS2WS_AuthorizedProduct','Proc_Export_CS2WS_AuthorizedProduct',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 8,'Warehouse Inventory','Export_CS2WS_WarehouseInventory','Proc_Export_CS2WS_WarehouseInventory',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 9,'Location Details','Export_CS2WS_LocationDetails','Proc_Export_CS2WS_LocationDetails',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 10,'Vehicle Details','Export_CS2WS_VehicleDetails','Proc_Export_CS2WS_VehicleDetails',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 11,'Salesman Details','Export_CS2WS_SalesmanDetails','Proc_Export_CS2WS_SalesmanDetails',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 12,'HHTMaster Details','Export_CS2WS_HHTMasterDetails','Proc_Export_CS2WS_HHTMasterDetails',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 13,'List Selection','Export_CS2WS_ListSelection','Proc_Export_CS2WS_ListSelection',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 14,'Beat Master','Export_CS2WS_BeatMaster','Proc_Export_CS2WS_BeatMaster',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 15,'Journey Plan','Export_CS2WS_JourneyPlan','Proc_Export_CS2WS_JourneyPlan',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 16,'Route Setup','Export_CS2WS_RouteSetupV1','Proc_Export_CS2WS_RouteSetupV1',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 17,'Promotion Definition','Export_CS2WS_PromotionControl','Proc_Export_CS2WS_PromotionControl',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 18,'Promotion Assignment','Export_CS2WS_PromotionAssignment','Proc_Export_CS2WS_PromotionAssignment',0,0,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 19,'Promotion Product Group','Export_CS2WS_ProductGroup','Proc_Export_CS2WS_ProductGroup',0,0,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 20,'Customer Scheme Mapping','Export_CS2WS_CustomerHierarchy','Proc_Export_CS2WS_CustomerHierarchy',0,0,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 21,'Credit Details','Export_CS2WS_CreditDetails','Proc_Export_CS2WS_CreditDetails',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 22,'Customer Target','Export_CS2WS_CustomerTarget','Proc_Export_CS2WS_CustomerTarget',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 23,'Route Target','Export_CS2WS_RouteTarget','Proc_Export_CS2WS_RouteTarget',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 24,'Sales Invoice','Export_CS2WS_SalesInvoiceHeader','Proc_Export_CS2WS_SalesInvoiceHeader',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 25,'Sales Invoice Details','Export_CS2WS_SalesInvoiceDetails','Proc_Export_CS2WS_SalesInvoiceHeader',0,0,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 26,'Pending Invoice','Export_CS2WS_PendingInvoice','Proc_Export_CS2WS_PendingInvoice',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 27,'Scheme Achivement','Export_CS2WS_SchemeAchievement','Proc_Export_CS2WS_SchemeAchievement',1,1,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) 
GO
DELETE FROM Tbl_WSDownloadIntegration
GO
INSERT INTO Tbl_WSDownloadintegration([ProcessId],[ProcessName],[PrkTableName],[ImportSPName],[Enable],[Status],[ValidateSP],[CreatedDate],[LastUpdatedDate])
SELECT 1,'Upload Sync Keys','Import_WS2CS_UploadSyncKeys','Proc_Import_WS2CS_UploadSyncKeys',1,1,'Proc_Validate_WS2CS_UploadSyncKeys',CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 2,'Visit Summary','Import_WS2CS_VisitSummary','Proc_Import_WS2CS_VisitSummary',1,1,'Proc_Validate_WS2CS_VisitSummary',CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 3,'Sales Order','Import_WS2CS_SalesOrderDetail','Proc_Import_WS2CS_SalesOrderDetail',1,1,'Proc_Validate_WS2CS_SalesOrderDetail',CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 4,'AR Collection','Import_WS2CS_CollectionHeader','Proc_Import_WS2CS_Collection',1,1,'Proc_Validate_WS2CS_CollectionHeader',CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 5,'New Customer','Import_WS2CS_NewCustomerRequest','Proc_Import_WS2CS_NewCustomerRequest',1,1,'Proc_Validate_WS2CS_NewCustomerRequest',CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 6,'Customer Inventory','Import_WS2CS_CustomerInventory','Proc_Import_WS2CS_CustomerInventory',1,1,'Proc_Validate_WS2CS_CustomerInventory',CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) UNION
SELECT 7,'Transaction Message','Import_WS2CS_TransactionHeader','Proc_Import_WS2CS_TransactionHeader',0,0,'Proc_Validate_WS2CS_TransactionHeader',CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121) 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_SavePDAConfig' AND XTYPE='P')
DROP PROCEDURE Proc_SavePDAConfig
GO
CREATE PROC [dbo].[Proc_SavePDAConfig]
(
	@EConfig NTEXT = NULL,
	@Path NVARCHAR(100),
	@AvgSales NVARCHAR(10),
	@PendingInv NVARCHAR(10),
	@Pathnew NVARCHAR(100)
)
AS
BEGIN
SET NOCOUNT ON 
	DECLARE @iDOC INT
	EXEC SP_XML_PREPAREDOCUMENT @iDOC OUTPUT,@EConfig  
	SELECT
		ProcessId,
		Status
	INTO #PDAConfig
	FROM OPENXML(@IDOC,'/EConfig/Record',3)                            
	WITH  
	(  
		ProcessId INT,
		Status INT
	) 
	UPDATE A SET A.Status = B.Status,LastUpdatedDate=GETDATE()
	FROM Tbl_WSUploadIntegration A,#PDAConfig B
	WHERE A.ProcessId = B.ProcessId
	
	UPDATE Tbl_SFAConfiguration SET CValue=@Path WHERE CName ='WebserviceURL'
	UPDATE Tbl_SFAConfiguration SET CValue = GETDATE() WHERE CName='LastModifiedDate'
	UPDATE Tbl_SFAConfiguration SET CValue=@AvgSales WHERE CName ='AverageSales'
	UPDATE Tbl_SFAConfiguration SET CValue =@PendingInv WHERE CName='PendingInvoices'
	UPDATE Tbl_SFAConfiguration SET CValue=@Pathnew where cName='WebserviceURL_New'
	EXECUTE SP_XML_REMOVEDOCUMENT @iDOC   
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='WS2CS_UploadSyncKeysLog' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[WS2CS_UploadSyncKeysLog](
	[SlNo] [numeric](32, 0) IDENTITY(1,1) NOT NULL,
	[TenantCode] [nvarchar](12) NULL,
	[LocationCode] [nvarchar](12) NULL,	
	[LoggedDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='UploadSyncKeysLog_LoggedDate' AND B.xtype='D')
BEGIN
	ALTER TABLE [dbo].[WS2CS_UploadSyncKeysLog] ADD  CONSTRAINT [UploadSyncKeysLog_LoggedDate]  DEFAULT (getdate()) FOR LoggedDate
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='WS2CSSyncKeysLog' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[WS2CSSyncKeysLog](
	[TenantCode] [nvarchar](12) NULL,
	[LocationCode] [nvarchar](12) NULL,
	[SyncKey] [nvarchar](50) NULL,
	[ModuleName] [nvarchar](50) NULL,
	TotalCount   int , 
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='SyncKeys_CreatedDate' AND B.xtype='D')
BEGIN
	ALTER TABLE [dbo].[WS2CSSyncKeysLog] ADD  CONSTRAINT [SyncKeys_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='WS2CSTransactionDetail' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[WS2CSTransactionDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TenantCode] [nvarchar](12) NULL,
	[LocationCode] [nvarchar](12) NULL,
	[ModuleName] [nvarchar](50) NULL,
	[TransactionID] [nvarchar](max) NULL,
	[RecordProcessed] [nvarchar](50) NULL,
	[Result] [nvarchar](50) NULL,
	[TokenID] [nvarchar](max) NULL,
	[DownLoadFlag]  [nvarchar](50) ,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='Transaction_DownLoadFlag' AND B.xtype='D')
BEGIN
	ALTER TABLE [dbo].[WS2CSTransactionDetail] ADD  CONSTRAINT [Transaction_DownLoadFlag]  DEFAULT 'N' FOR [CreatedDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WSMasterExportUploadTrack]') AND type in (N'U'))
BEGIN
CREATE TABLE WSMasterExportUploadTrack(
	[ProcessName][varchar](100) NULL,
	[MasterCode] [nvarchar](100) NULL,
	[MasterName] [varchar](200) NULL,
	[ExportTime] [datetime] NULL,
	[Status]	 [INT] NULL,
	[Reference1] [varchar](100) NULL,
	[Reference2] [varchar](100) NULL,
	[Reference3] [varchar](100) NULL,
	[Ref4Value]	 [NUMERIC](18,6) NULL
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id WHERE A.name='Retailer' and 
B.name='WSUpload' and A.xtype='U')
BEGIN
	ALTER TABLE Retailer ADD WSUpload VARCHAR(1)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='Retailer_WSUploadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Retailer ADD constraint Retailer_WSUploadFlag DEFAULT ('N') FOR [WSUpload]
END
GO
UPDATE Retailer SET WSUpload='N' WHERE ISNULL(WSUpload,'')=''
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id WHERE A.name='salesman' and 
B.name='WSUpload' and A.xtype='U')
BEGIN
	ALTER TABLE salesman ADD WSUpload VARCHAR(1)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='Salesman_WSUploadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE salesman ADD constraint Salesman_WSUploadFlag DEFAULT ('N') FOR [WSUpload]
END
GO
UPDATE salesman SET WSUpload='N' WHERE ISNULL(WSUpload,'')=''
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='fn_getList' and xtype='TF')
DROP FUNCTION fn_getList
GO
CREATE FUNCTION [dbo].[fn_getList](@pTempList as varchar(8000))        
RETURNS @pTempTbl TABLE         
 (        
 pListId int,        
 pListValue varchar(8000)         
 )        
AS         
 BEGIN        
 DECLARE @pTempId VARCHAR(100),
 @Pos int,
 @pInc int        
 SET @pTempList = LTRIM(RTRIM(@pTempList))+ ','        
 SET @Pos = CHARINDEX(',', @pTempList, 1)        
 SET @pInc = 1        
 IF REPLACE(@pTempList, ',', '') <> ''        
	 BEGIN        
	  WHILE @Pos > 0        
		  BEGIN        
		   SET @pTempId = LTRIM(RTRIM(LEFT(@pTempList, @Pos - 1)))        
		   IF @pTempId  <> ''        
			   BEGIN        
				INSERT INTO @pTempTbl (pListId,pListValue) VALUES (@pInc,LTRIM(RTRIM(@pTempId)))         
			   END        
		   SET @pTempList = RIGHT(@pTempList, LEN(@pTempList) - @Pos)        
		   SET @Pos = CHARINDEX(',',@pTempList, 1)        
		   SET @pInc = @pInc + 1        
		  END        
	 END          
 RETURN        
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id WHERE A.name='salesman' and 
B.name='HHTDeviceSerialNumber' and A.xtype='U')
BEGIN
	ALTER TABLE salesman ADD HHTDeviceSerialNumber VARCHAR(100) NULL
END
GO
UPDATE salesman SET HHTDeviceSerialNumber='' WHERE HHTDeviceSerialNumber IS NULL
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='FN_ReturnSalesManHHTConfigValues' AND XTYPE='FN')
DROP FUNCTION FN_ReturnSalesManHHTConfigValues
GO
CREATE FUNCTION FN_ReturnSalesManHHTConfigValues(@iMode INT,@SMId INT)
RETURNS TINYINT
AS
-- SELECT dbo.FN_ReturnSalesManHHTConfigValues(2,1) As status
/**************************************************************************************************
* FUNCTION: FN_ReturnSalesManHHTConfigValues
* PURPOSE: Returns Configuration For HHT Serial Number Lock
* CREATED		: Amuthakumar P
* CREATED DATE	: 16/08/2018  
* MODIFIED
***************************************************************************************************
* DATE       AUTHOR        CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
16-08-2018  Amuthakumar P   CR     CRCRSTPAR0016     Returns Configuration for HHT Device Serial Number
***************************************************************************************************/ 
BEGIN
	DECLARE @Config TINYINT
	SET @Config=0
	
	IF @iMode=1 --Add
	BEGIN
		IF EXISTS (SELECT * FROM Salesman (NOLOCK) WHERE smid= @SMId )
		BEGIN
			SET @Config=0
		END 
	END 
	
	IF @iMode=2 --Edit
	BEGIN
		IF EXISTS (SELECT * FROM Salesman (NOLOCK) WHERE smid= @SMId )
		BEGIN
			SET @Config=0
		END 
	END 
		
	RETURN @Config
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Fn_SFAProductToSend' and xtype='TF')
DROP FUNCTION Fn_SFAProductToSend
GO
--SELECT * FROM Fn_SFAProductToSend()
CREATE FUNCTION Fn_SFAProductToSend()
RETURNS @SFAProduct TABLE
(
	PrdId	BIGINT
)
AS
/*******************************************************************************************
* PROCEDURE		: Fn_SFAProductToSend
* PURPOSE		: To Export Product details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 26/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN
DECLARE @Pi_FrmDate AS DATETIME
	DECLARE @Pi_ToDate AS DATETIME

	SET @Pi_FrmDate=DATEADD(MONTH,-6,CONVERT(VARCHAR(10),GETDATE(),121))
	SET @Pi_ToDate=CONVERT(VARCHAR(10),GETDATE(),121)


	INSERT INTO @SFAProduct(PrdId)
	--SELECT DISTINCT PrdId FROM  Product A WITH (NOLOCK) WHERE PrdStatus = 1
	--UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN SalesInvoiceProduct B (NOLOCK) ON A.PrdId=B.PrdId 
	INNER JOIN SalesInvoice C (NOLOCK) ON B.SalId=C.SalId 
	WHERE A.PrdStatus=1 AND C.SalInvDate between @Pi_FrmDate and @Pi_ToDate AND C.DlvSts in (4,5)
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN SalesInvoiceSchemeDtFreePrd B (NOLOCK) ON A.PrdId=B.FreePrdId 
	INNER JOIN SalesInvoice C (NOLOCK) ON B.SalId=C.SalId
	WHERE A.PrdStatus=1 AND C.SalInvDate between @Pi_FrmDate and @Pi_ToDate AND C.DlvSts in (4,5)	
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN ReturnProduct B (NOLOCK) ON A.PrdId=B.PrdId 
	INNER JOIN ReturnHeader C (NOLOCK) ON B.ReturnID=C.ReturnID 
	WHERE A.PrdStatus=1 AND C.ReturnDate between @Pi_FrmDate and @Pi_ToDate AND C.[Status] =0
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN ReturnSchemeFreePrdDt B (NOLOCK) ON A.PrdId=B.FreePrdId 
	INNER JOIN ReturnHeader C (NOLOCK) ON B.ReturnID=C.ReturnID 
	WHERE A.PrdStatus=1 AND C.ReturnDate between @Pi_FrmDate and @Pi_ToDate AND C.[Status] =0
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN PurchaseReceiptProduct B (NOLOCK) ON A.PrdId=B.PrdId 
	INNER JOIN PurchaseReceipt C (NOLOCK) ON B.PurRcptId=C.PurRcptId 
	WHERE A.PrdStatus=1 AND C.GoodsRcvdDate between @Pi_FrmDate and @Pi_ToDate AND C.[Status] =1

RETURN
END
GO
DELETE FROM CustomCaptions WHERE TransId=68 AND CtrlId=100024 AND CtrlName='LblHHTDeviceSerialNumber'
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (68,100024,1,'LblHHTDeviceSerialNumber','HHTDeviceSerialNo.','','',1,1,1,GETDATE(),1,GETDATE(),'HHTDeviceSerialNo','','',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId=68 AND CtrlId=100025 AND CtrlName='fxtHHTDeviceSerialNumber'
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (68,100025,1,'fxtHHTDeviceSerialNumber','','Enter HHTDeviceSerialNumber','',1,1,1,GETDATE(),1,GETDATE(),'','Enter HHTDeviceSerialNumber','',1,1)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_LocationDetails' AND XTYPE='U')
DROP TABLE Export_CS2WS_LocationDetails
GO
CREATE TABLE Export_CS2WS_LocationDetails(
	[TenantCode]    [Nvarchar](12) ,
	[LocationCode]	[Nvarchar](12) ,
	[LocationName]	[Nvarchar](50) ,
	[Address]	    [Nvarchar](100) ,
	[City] 	        [Nvarchar](40) ,
	[State]	        [Nvarchar](20) ,
	[Country]	    [Nvarchar](20) ,	
	[Zip] 	        [Nvarchar](10) ,
	[Phone]	        [Nvarchar](50) ,
	[Email]  	    [Nvarchar](35) ,
	[CurrencyCode] 	[Nvarchar](5) ,
	[UploadFlag]    [varchar](1) 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_LocationDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_LocationDetails
GO
/*
BEGIN TRAN
Exec Proc_Export_CS2WS_LocationDetails '1'
select * from Export_CS2WS_LocationDetails
select * from WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_LocationDetails
(
	@SalRpCode varchar(100)
)
AS
/*******************************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_LocationDetails 
* PURPOSE		: To Export Location details to the PDA Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 06/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 06/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Location details 
*********************************************************************************************************************/
BEGIN
	DECLARE @Smid AS int 
	DECLARE @Sql AS varchar(1000)
	
	DELETE FROM Export_CS2WS_LocationDetails WHERE UploadFlag='Y'
	
	SELECT Distributorid,DistributorCode,DistributorName ,DistributorAdd1,GeoName,PinCode,PhoneNo,EmailID
	INTO #DistributorInfo
	FROM Distributor D INNER JOIN Geography G ON D.GeoMainId = G.GeoMainId 
	
	SELECT DISTINCT B.ColumnName,A.ColumnValue,MasterRecordId INTO #TEMPUDCROUTE1
	FROM UdcDetails A,UdcMaster B, UdcHD C WHERE  A.UdcMasterId=B.UdcMasterId
	AND A.MasterId=B.MasterId AND ColumnName='State Name' AND MasterName='Distributor Info Master'
	
	INSERT INTO Export_CS2WS_LocationDetails(TenantCode,LocationCode,LocationName,Address,City,State,Country,Zip,Phone,Email,CurrencyCode,UploadFlag)
	SELECT DistributorCode,DistributorCode,DistributorName,DistributorAdd1,GeoName,B.ColumnValue,'INDIA',PinCode,PhoneNo,EmailID,'INR','N' 
	FROM  #DistributorInfo A INNER JOIN #TEMPUDCROUTE1 B ON DistributorId=B.MasterRecordId 
	WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.DistributorCode 
	AND M.ProcessName='Location Details') 
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'Location Details',LocationCode,LocationName,GETDATE(),0,'','','',0 FROM Export_CS2WS_LocationDetails B 
	INNER JOIN Distributor D ON D.DistributorCode=B.LocationCode WHERE UploadFlag='N'
		
	SELECT TenantCode,LocationCode,LocationName,Address,City,State,Country,Zip,Phone,Email,CurrencyCode	FROM Export_CS2WS_LocationDetails
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_CustomerCategory' AND XTYPE='U')
DROP TABLE Export_CS2WS_CustomerCategory
GO
CREATE TABLE Export_CS2WS_CustomerCategory(
	[TenantCode]    [Nvarchar](12) ,
	[CategoryType] [tinyint] ,
	[CategoryCode] [nvarchar](12) ,
	[CategoryDescription] [nvarchar](50) ,
	[UploadFlag] [varchar](1) 
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_CustomerCategory' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_CustomerCategory
GO
/*  
BEGIN TRAN  
DELETE FROM WSMasterExportUploadTrack WHERE PROCESSNAME='Customer Category'
Exec Proc_Export_CS2WS_CustomerCategory '1,2'  
--select * from Export_CS2WS_CustomerCategory  
ROLLBACK TRAN  
*/  
CREATE PROCEDURE Proc_Export_CS2WS_CustomerCategory  
(  
 @SalRpCode varchar(50)  
)  
AS  
/*******************************************************************************************************************  
* PROCEDURE  : Proc_Export_CS2WS_CustomerCategory  
* PURPOSE  : To Export Retailer Category details to the PDA Intermediate Database  
* CREATED  : Amuthakumar P            CR:  CRCRSTAPAR0016  
* CREATED DATE : 06/08/2018   
* MODIFIED  :  
* DATE   AUTHOR    USERSTORYID   CR/BZ      DESCRIPTION  
--------------------------------------------------------------------------------------------------------------------  
* 06/08/2018   Amuthakumar P        CRCRSTAPAR0016       CR     To Export Retailer Category details  
*********************************************************************************************************************/  
BEGIN  
DECLARE @DistCode As nVarchar(25)  
SELECT @DistCode = DistributorCode FROM Distributor  
   
DELETE FROM Export_CS2WS_CustomerCategory WHERE UploadFlag='Y'  
   
 INSERT INTO Export_CS2WS_CustomerCategory(TenantCode,CategoryType,CategoryCode,CategoryDescription,UploadFlag)   
 SELECT DISTINCT @DistCode,A.CtglevelId,CtgCode,CtgName,'N' AS UploadFlag FROM RetailerCategory A   
 WHERE 
 --EXISTS (SELECT CtgLevelId FROM RetailerCategoryLevel WHERE CtgLevelName <> 'Channel' AND CtgLevelId = A.CtgLevelId)  AND 
 NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.CtgCode AND M.ProcessName='Customer Category')    
 
 INSERT INTO Export_CS2WS_CustomerCategory(TenantCode,CategoryType,CategoryCode,CategoryDescription,UploadFlag)   
 SELECT DISTINCT @DistCode,3,ValueClassCode,ValueClassName,'N' AS UploadFlag FROM RetailerValueClass Rv 
 INNER JOIN RetailerCategory RC ON RC.CtgMainId = Rv.CtgMainId
 INNER JOIN Export_CS2WS_CustomerCategory B(NOLOCK) ON RC.CTGCODE=B.CategoryCode
 WHERE B.UploadFlag='N'
 --WHERE EXISTS(SELECT * FROM Export_CS2WS_CustomerCategory B WHERE RC.CTGCODE=B.CategoryCode)
-- WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = Rv.ValueClassCode AND M.ProcessName='Customer Category')   
    
 INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)  
 SELECT DISTINCT 'Customer Category',CategoryCode,CategoryDescription,GETDATE(),0,'','','',0 FROM Export_CS2WS_CustomerCategory WHERE UploadFlag='N' AND CategoryType<>3 
   
 SELECT DISTINCT  
  TenantCode,  
  CategoryType,  
  CategoryCode,  
  CategoryDescription   
 FROM Export_CS2WS_CustomerCategory WITH (NOLOCK)  
   
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_CustomerHierarchyV1' AND XTYPE='U')
DROP TABLE Export_CS2WS_CustomerHierarchyV1
GO
CREATE TABLE Export_CS2WS_CustomerHierarchyV1(
	[TenantCode]    [Nvarchar](12) ,
	[ParentCode] [nvarchar](100) ,
	[HierarchyLevel] [tinyint] ,
	[HierarchyCode] [nvarchar](30) , 
	[HierarchyName] [nvarchar](100) ,
	[ParentHierarchy] [nvarchar](100) ,
	[UploadFlag] [varchar](1) 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_CustomerHierarchyV1' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_CustomerHierarchyV1
GO
/*
BEGIN TRAN
Exec Proc_Export_CS2WS_CustomerHierarchyV1 '1,2'
select * from Export_CS2WS_CustomerHierarchyV1
select * from WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_CustomerHierarchyV1
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_CustomerHierarchyV1
* PURPOSE		: To Export Retailer Category Hierarchy details to the PDA Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 06/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 06/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Retailer Category Hierarchy details
*********************************************************************************************************************/
BEGIN
DECLARE @DistCode	As nVarchar(25)
SELECT @DistCode = DistributorCode FROM Distributor
 
DELETE FROM Export_CS2WS_CustomerHierarchyV1 WHERE UploadFlag='Y'
DECLARE @CtgLevelId as Int
DECLARE @CtgLevelName as Nvarchar(100)

DECLARE Cur_RtrCtg CURSOR FOR  
SELECT CtgLevelId,CtgLevelName from RetailerCategoryLevel
OPEN Cur_RtrCtg
FETCH NEXT FROM Cur_RtrCtg INTO @CtgLevelId,@CtgLevelName
WHILE @@FETCH_STATUS = 0
BEGIN

IF @CtgLevelId <> 1
	BEGIN

		Insert Into Export_CS2WS_CustomerHierarchyV1(TenantCode,ParentCode,HierarchyLevel,HierarchyCode,HierarchyName,ParentHierarchy,UploadFlag)
		select DISTINCT @DistCode,B.CTGCODE [ParentCode], A.CtgLevelId [HierarchyLevel],A.CtgCode [HierarchyCode] ,A.CtgName [HierarchyName]
		,'' [ParentHierarchy],'N' from RetailerCategory A (NOLOCK)
		INNER JOIN RetailerCategory B (NOLOCK) ON A.CtgLinkId = B.CtgMainId
		WHERE A.CtgLevelId = @CtgLevelId AND
		NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.CtgCode AND M.ProcessName='Customer HierarchyV1') 
	END
ELSE
	BEGIN
		Insert Into Export_CS2WS_CustomerHierarchyV1(TenantCode,ParentCode,HierarchyLevel,HierarchyCode,HierarchyName,ParentHierarchy,UploadFlag)
		select DISTINCT @DistCode, '' [ParentCode], A.CtgLevelId [HierarchyLevel],A.CtgCode [HierarchyCode] ,A.CtgName [HierarchyName]
		,''[ParentHierarchy], 'N' from RetailerCategory A (NOLOCK)
		--CROSS JOIN Company B
		WHERE A.CtgLevelId = 1 and --B.DefaultCompany = 1 AND
		NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.CtgCode AND M.ProcessName='Customer HierarchyV1') 
	END

FETCH NEXT FROM Cur_RtrCtg INTO @CtgLevelId,@CtgLevelName
END
CLOSE Cur_RtrCtg
DEALLOCATE Cur_RtrCtg

INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
SELECT 'Customer HierarchyV1',HierarchyCode,HierarchyName,GETDATE(),0,ParentCode,HierarchyLevel,'',0 FROM Export_CS2WS_CustomerHierarchyV1 WHERE UploadFlag='N'

	SELECT
		TenantCode,
		ParentCode,
		HierarchyLevel,
		HierarchyCode,
		HierarchyName,
		ParentHierarchy
	FROM Export_CS2WS_CustomerHierarchyV1	WITH (NOLOCK)
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_ProductCategory' AND XTYPE='U')
DROP TABLE Export_CS2WS_ProductCategory
GO
CREATE TABLE Export_CS2WS_ProductCategory(
	[TenantCode] [nvarchar](12) ,
	[ParentCode] [nvarchar](100) ,
	[HierarchyLevel] [tinyint] ,
	[HierarchyCode] [nvarchar](40) , --- In Table Struct it is 20 intitally
	[HierarchyName] [nvarchar](100) ,
	[ParentHierarchy] [nvarchar](100) ,
	[UploadFlag] [varchar](1) 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_ProductCategory' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_ProductCategory
GO
/*
BEGIN TRAN
truncate table WSMasterExportUploadTrack
Exec Proc_Export_CS2WS_ProductCategory 'SM07'
--select * from Export_CS2WS_ProductCategory
--SELECT * FROM WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_ProductCategory
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_ProductCategory
* PURPOSE		: To Export Product Category to the PDA Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 09/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 09/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Product Category
*********************************************************************************************************************/
BEGIN
 DECLARE @DistCode	As nVarchar(25)
 SELECT @DistCode = DistributorCode FROM Distributor

 DECLARE @PrdCtgId AS INT
 DECLARE @PrdCtgName AS Nvarchar(100)

 DELETE FROM Export_CS2WS_ProductCategory WHERE UploadFlag='Y'
 
 DECLARE Cur_PrdCtg CURSOR FOR  
 SELECT CMPPRDCTGID,CMPPRDCTGNAME from ProductCategoryLevel
 OPEN Cur_PrdCtg
	FETCH NEXT FROM Cur_PrdCtg INTO @PrdCtgId,@PrdCtgName
	WHILE @@FETCH_STATUS = 0
	BEGIN
	IF @PrdCtgId <> 1
		BEGIN
			Insert Into Export_CS2WS_ProductCategory(TenantCode,ParentCode,HierarchyLevel,HierarchyCode,HierarchyName,ParentHierarchy,UploadFlag)
			select DISTINCT @DistCode,B.PrdCtgValCode [ParentCode], A.CmpPrdCtgId [HierarchyLevel],A.PrdCtgValCode [HierarchyCode] ,A.PrdCtgValName [HierarchyName]
			,'' [ParentHierarchy],'N' from ProductCategoryValue A (NOLOCK)
			INNER JOIN ProductCategoryValue B (NOLOCK) ON A.PrdCtgValLinkId = B.PrdCtgValMainId
			WHERE A.CmpPrdCtgId = @PrdCtgId AND
			NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.PrdCtgValCode AND M.ProcessName='Product HierarchyV1')  
		END
	ELSE
		BEGIN
			Insert Into Export_CS2WS_ProductCategory(TenantCode,ParentCode,HierarchyLevel,HierarchyCode,HierarchyName,ParentHierarchy,UploadFlag)
			select DISTINCT @DistCode,'' [ParentCode], A.CmpPrdCtgId [HierarchyLevel],A.PrdCtgValCode [HierarchyCode] ,A.PrdCtgValName [HierarchyName]
			,'' [ParentHierarchy],'N' from ProductCategoryValue A (NOLOCK)
			--CROSS JOIN Company B 
			WHERE A.CmpPrdCtgId = 1 and --B.DefaultCompany = 1 AND
			NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.PrdCtgValCode AND M.ProcessName='Product HierarchyV1') 
		END
	FETCH NEXT FROM Cur_PrdCtg INTO @PrdCtgId,@PrdCtgName
	END
 CLOSE Cur_PrdCtg
 DEALLOCATE Cur_PrdCtg
 
 INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
 SELECT 'Product HierarchyV1',HierarchyCode,HierarchyName,GETDATE(),0,ParentCode,HierarchyLevel,'',0 FROM Export_CS2WS_ProductCategory WHERE UploadFlag='N'
 
 UPDATE A SET A.HierarchyCode=LEFT(HierarchyCode,3) FROM Export_CS2WS_ProductCategory A WHERE HierarchyLevel=2 
 -- As per client Confirmation
 
   SELECT ROW_NUMBER() OVER (ORDER BY PrdCtgValLinkCode) AS SlNo,A.LevelName,B.PrdCtgValLinkCode,B.PrdCtgValName,
  A.CmpId,B.PrdCtgValCode,b.CmpPrdCtgId  INTO #TEMP1 FROM ProductCategoryLevel A with (nolock) , 
  ProductCategoryValue B with (nolock) WHERE  B.Availability = 1 and A.CmpPrdCtgId = B.CmpPrdCtgId 
  ORDER BY PrdCtgValLinkCode
  
  UPDATE A SET A.PrdCtgValCode=LEFT(PrdCtgValCode,3) FROM #TEMP1 A WHERE CmpPrdCtgId=2
  
  SELECT TenantCode,	
		ParentCode,	
		HierarchyLevel,	
		HierarchyCode,
		HierarchyName,
		ParentHierarchy	 FROM Export_CS2WS_ProductCategory  a 
	inner join #TEMP1 b on a.HierarchyCode=b.PrdCtgValCode
	order by b.slno asc
 
	--SELECT 
	--	TenantCode,	
	--	ParentCode,	
	--	HierarchyLevel,	
	--	HierarchyCode,
	--	HierarchyName,
	--	ParentHierarchy	
	--FROM Export_CS2WS_ProductCategory WITH (NOLOCK)
 
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_BeatMaster' AND XTYPE='U')
DROP TABLE Export_CS2WS_BeatMaster
GO
CREATE TABLE Export_CS2WS_BeatMaster(
	[TenantCode] [nvarchar](12) ,
	[LocationCode] [nvarchar](12) ,
	[BeatCode] [nvarchar](12) ,
	[BeatName] [nvarchar](50) ,
	[UploadFlag] [varchar](1) 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_BeatMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_BeatMaster
GO
/*
BEGIN TRAN
Exec Proc_Export_CS2WS_BeatMaster '1'
select * from WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_BeatMaster
(
	@SalRpCode varchar(100)
)
AS
/*******************************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_BeatMaster 
* PURPOSE		: To Export Beat details to the PDA Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 06/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 06/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Beat details
*********************************************************************************************************************/
BEGIN
	DECLARE @Smid AS int 
	DECLARE @Sql AS varchar(1000)
	
	DELETE FROM Export_CS2WS_BeatMaster WHERE UploadFlag='Y'
	
	 SET @Sql='INSERT INTO Export_CS2WS_BeatMaster(TenantCode,LocationCode,BeatCode,BeatName,UploadFlag)'
	 SET @Sql=@Sql+' SELECT dISTINCT DistributorCode,DistributorCode,RMCode,RMName,''N'' AS UploadFlag FROM RouteMaster S
			INNER JOIN SalesmanMarket SM ON SM.RMId = S.RMId 
			CROSS JOIN Distributor D
			WHERE RMStatus = 1 AND
			NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = S.RMCode AND M.MasterName=S.RMNAME AND M.ProcessName=''Beat Master'')
			AND SM.SMId  in('+ CAST(@SalRpCode AS VARCHAR(100)) +')'
--	PRINT (@Sql)
	EXEC (@Sql)
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'Beat Master',BeatCode,BeatName,GETDATE(),0,LocationCode,'','',0 FROM Export_CS2WS_BeatMaster WHERE UploadFlag='N'
	
	SELECT DISTINCT 
		 TenantCode,
		 LocationCode,
		 BeatCode,
		 BeatName 
	FROM Export_CS2WS_BeatMaster WITH (NOLOCK)
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_ListSelection' AND XTYPE='U')
DROP TABLE Export_CS2WS_ListSelection
GO
CREATE TABLE Export_CS2WS_ListSelection(
	[TenantCode] [nvarchar](12) ,
	[ListTypeCode] [tinyint] ,
	[Code] [nvarchar](100) ,
	[Description] [nvarchar](200) ,
	[UploadFlag] [varchar](1) 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_ListSelection' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_ListSelection
GO
/*
BEGIN TRAN
Exec Proc_Export_CS2WS_ListSelection '1,2'
select * from Export_CS2WS_ListSelection
SELECT * FROM WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_ListSelection
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_ListSelection
* PURPOSE		: To Export Sales Return reason to the PDA Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 06/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 06/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Sales Return reason
*********************************************************************************************************************/
BEGIN
	DECLARE @DistCode	As nVarchar(25)
	SELECT @DistCode = DistributorCode FROM Distributor
	
	DELETE FROM Export_CS2WS_ListSelection  WHERE UploadFlag='Y'
	
	INSERT INTO Export_CS2WS_ListSelection(TenantCode,ListTypeCode,Code,Description,UploadFlag)
	SELECT @DistCode, ListTypeCode,Code,SUBSTRING(Description,1,50),'N' AS UploadFlag 
	FROM 
	( 	SELECT '' As TenantCode,8 AS ListTypeCode,ReasonCode AS Code,Description  FROM ReasonMaster R WHERE SalesReturn = 1
		AND NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = R.ReasonCode AND M.ProcessName='List Selection') 
		--UNION ALL 
		--SELECT '' As TenantCode,28 AS ListTypeCode,BnkBrCode AS Code,BnkName+BnkBrname AS Description FROM Bank A,BankBranch B
		--WHERE A.BnkId = B.BnkId
	) A
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'List Selection',Code,Description,GETDATE(),0,ListTypeCode,'','',0 FROM Export_CS2WS_ListSelection WHERE UploadFlag='N'
	
	SELECT
		 TenantCode,
		 ListTypeCode,
		 Code,
		 Description
	FROM Export_CS2WS_ListSelection WITH (NOLOCK)
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_SalesmanDetails' AND XTYPE='U')
DROP TABLE Export_CS2WS_SalesmanDetails
GO
CREATE TABLE Export_CS2WS_SalesmanDetails(
	[TenantCode]   [nvarchar](12) ,
	[LocationCode] [nvarchar](12) ,
	[SalesmanCode] [nvarchar](12) ,
	[SalesmanName] [nvarchar](50) ,
	[Address]      [nvarchar](100) ,
	[City]		   [nvarchar](40) ,	
	[State]		   [nvarchar](20) ,
	[Zip]          [nvarchar](10) ,
	[Phone]        [nvarchar](30) ,
	[IsActive]     TinyInt,
	[Password]     [nvarchar](50) ,
	[UploadFlag]   [varchar](1) 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_SalesmanDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_SalesmanDetails
GO
/*
BEGIN TRAN
Exec Proc_Export_CS2WS_SalesmanDetails '1,2'
select * from Export_CS2WS_SalesmanDetails
SELECT * FROM WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_SalesmanDetails
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_SalesmanDetails
* PURPOSE		: To Export SalesMan details to the PDA Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 06/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 06/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export SalesMan details
*********************************************************************************************************************/
BEGIN
	DECLARE @Sql AS varchar(1000)
	DELETE FROM Export_CS2WS_SalesmanDetails WHERE UploadFlag='Y'
	
	SET @Sql=' INSERT INTO Export_CS2WS_SalesmanDetails(TenantCode,LocationCode,SalesmanCode,SalesmanName,Address,City,State,Zip,Phone,IsActive,Password,UploadFlag)
			   SELECT DistributorCode,DistributorCode,SMCode,SMName,'''','''','''','''',SMPhoneNumber,S.Status,SMCode,''N'' AS UploadFlag FROM SalesMan S
			   CROSS JOIN Distributor D WHERE 
			   NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = S.SMCode AND M.ProcessName=''Salesman Details'')
			   AND SMId IN ('+ CAST(@SalRpCode AS VARCHAR(100)) +')'
	EXEC (@Sql)
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'Salesman Details',SalesmanCode,SalesmanName,GETDATE(),0,LocationCode,'','',0 FROM Export_CS2WS_SalesmanDetails WHERE UploadFlag='N'
	
	UPDATE RM SET RM.WSUpload='Y' FROM WSMasterExportUploadTrack A (NOLOCK)
		INNER JOIN SalesMan RM (NOLOCK) ON A.MasterCode=RM.SMCode
		WHERE ISNULL(RM.WSUpload,'N')='N' AND ProcessName='Salesman Details'
	
	SELECT DISTINCT 
		TenantCode,	
		LocationCode,
		SalesmanCode,
		SalesmanName,
		[Address],
		City,	
		[State],
		Zip,
		Phone,
		IsActive,
		[Password] 
	FROM Export_CS2WS_SalesmanDetails WITH (NOLOCK)
	
 END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_VehicleDetails' AND XTYPE='U')
DROP TABLE Export_CS2WS_VehicleDetails
GO
CREATE TABLE Export_CS2WS_VehicleDetails(
	[TenantCode]   [nvarchar](12) ,
	[LocationCode] [nvarchar](12) ,
	[VehicleCode]  [nvarchar](12) ,
	[VehicleTitle] [nvarchar](50) ,
	[UploadFlag] [varchar](1) 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_VehicleDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_VehicleDetails
GO
/*
BEGIN TRAN
Exec Proc_Export_CS2WS_VehicleDetails '1,2'
select * from Export_CS2WS_VehicleDetails
--SELECT * FROM WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_VehicleDetails
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_VehicleDetails
* PURPOSE		: To Export Vehicle details to the PDA Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 09/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 09/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Vehicle details
*********************************************************************************************************************/
BEGIN
	 DELETE FROM Export_CS2WS_VehicleDetails WHERE UploadFlag='Y'
	 
	 INSERT INTO Export_CS2WS_VehicleDetails(TenantCode,LocationCode,VehicleCode,VehicleTitle,UploadFlag)
	 SELECT DistributorCode,DistributorCode, SMCode,SMName,'N' AS UploadFlag 
	 FROM SalesMan S CROSS JOIN Distributor D WHERE --Status = 1 AND
	 NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = S.SMCode AND M.ProcessName='Vehicle Details') 
	 
	 INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	 SELECT 'Vehicle Details',VehicleCode,VehicleTitle,GETDATE(),0,LocationCode,'','',0 FROM Export_CS2WS_VehicleDetails WHERE UploadFlag='N'
	
	 SELECT
		 TenantCode,
		 LocationCode,
		 VehicleCode,
		 VehicleTitle
	FROM Export_CS2WS_VehicleDetails WITH (NOLOCK)
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_HHTMasterDetails' AND XTYPE='U')
DROP TABLE Export_CS2WS_HHTMasterDetails
GO
CREATE TABLE Export_CS2WS_HHTMasterDetails(
	[TenantCode]   [nvarchar](12) ,
	[LocationCode] [nvarchar](12) ,
	[HHTName]      [nvarchar](50) ,
	[HHTDeviceSerialNumber] [nvarchar](100) ,
	[UploadFlag] [varchar](1) 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_HHTMasterDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_HHTMasterDetails
GO
/*
BEGIN TRAN
Exec Proc_Export_CS2WS_HHTMasterDetails '1,2'
select * from Export_CS2WS_HHTMasterDetails
SELECT * FROM WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_HHTMasterDetails
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_HHTMasterDetails
* PURPOSE		: To Export HHT Device details to the PDA Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 06/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 06/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export HHT Device details
*********************************************************************************************************************/
BEGIN
	 DELETE FROM Export_CS2WS_HHTMasterDetails WHERE UploadFlag='Y'
	 
	 INSERT INTO Export_CS2WS_HHTMasterDetails(TenantCode,LocationCode,HHTName,HHTDeviceSerialNumber,UploadFlag)
	 SELECT DistributorCode,DistributorCode, DistributorCode+'-'+SMCode,HHTDeviceSerialNumber,'N' AS UploadFlag 
	 FROM SalesMan S CROSS JOIN Distributor D 
	 WHERE --Status = 1 AND 
	 NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = S.HHTDeviceSerialNumber AND M.ProcessName='HHTMaster Details') 
	 
	 INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	 SELECT 'HHTMaster Details',HHTDeviceSerialNumber,HHTName,GETDATE(),0,LocationCode,'','',0 FROM Export_CS2WS_HHTMasterDetails WHERE UploadFlag='N'
	 
	 UPDATE Export_CS2WS_HHTMasterDetails SET HHTDeviceSerialNumber=REPLACE(HHTName,'-','') WHERE ISNULL(HHTDeviceSerialNumber,'')=''
	 
	 SELECT DISTINCT 
		TenantCode,
		LocationCode,
		HHTName,
		HHTDeviceSerialNumber
	FROM Export_CS2WS_HHTMasterDetails WITH (NOLOCK)
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Export_CS2WS_Customer' AND XTYPE='U')
DROP TABLE Export_CS2WS_Customer
GO
CREATE TABLE [dbo].[Export_CS2WS_Customer](
	[TenantCode] [nvarchar](12) NULL,
	[LocationCode] [nvarchar](12) NULL,
	[CustomerCode] [nvarchar](25) NULL,
	[CustomerName] [nvarchar](50) NULL,
	[Address1] [nvarchar](100) NULL,
	[Address2] [nvarchar](100) NULL,
	[Address3] [nvarchar](100) NULL,
	[Address4] [nvarchar](100) NULL,
	[City] [nvarchar](40) NULL,
	[State] [nvarchar](20) NULL,
	[Zip] [nvarchar](10) NULL,
	[Phone] [nvarchar](30) NULL,
	[Fax] [nvarchar](30) NULL,
	[Email] [nvarchar](50) NULL,
	[ContactPerson] [nvarchar](50) NULL,
	[Notes] [nvarchar](100) NULL,
	[CategoryCode1] [nvarchar](12) NULL,
	[CategoryCode2] [nvarchar](12) NULL,
	[CategoryCode3] [nvarchar](12) NULL,
	[CustomerStatus] [tinyint] NULL,
	[SalesMode] [tinyint] NULL,
	[PaymentType] [tinyint] NULL,
	[CustomerPricingKey] [nvarchar](12) NULL,
	[TotalCreditLimit] [float] NULL,
	[TotalBalanceDue] [float] NULL,
	[IsTaxable] [tinyint] NULL,
	[TaxID] [nchar](5) NULL,
	[HierarchyCode] [nvarchar](20) NULL,
	[TerritoryHierarchy] [nvarchar](100) NULL,
	[SurveyKey] [nvarchar](24) NULL,
	[DateofBirth] [datetime] NULL,
	[IDNumber] [nvarchar](50) NULL,
	[TINNumber] [nvarchar](50) NULL,
	[UploadFlag] [nvarchar](1) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE NAME='TempRetailer' and xtype='U')
BEGIN
	DROP TABLE TempRetailer
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_ValidateRetailerShippingAddress]') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_ValidateRetailerShippingAddress
GO
CREATE PROCEDURE Proc_ValidateRetailerShippingAddress
(
	@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************************************************
* PROCEDURE	: Proc_ValidateRetailerShippingAddress
* PURPOSE	: To Insert and Update records  from xml file in the Table RetailerShippingAddress 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------------------------------
* {Date}       {Developer}               {brief modification description}      
* 21/07/2009   Nanda	                 Modified for Default Shipping Address Validation
  2013/10/10   Sathishkumar Veeramani    Junk Characters Removed  
*************************************************************************************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @RetailerCode AS NVARCHAR(100)
	DECLARE @Address1 AS NVARCHAR(100)
	DECLARE @Address2 AS NVARCHAR(100)
	DECLARE @Address3 AS NVARCHAR(100)
	DECLARE @RtrShipPinNo AS NVARCHAR(100)
	DECLARE @RtrShipPhoneNo AS NVARCHAR(100)
	DECLARE @DefaultShippingAddress AS NVARCHAR(100)
	DECLARE @RtrId AS INT
	DECLARE @RtrShipId AS INT
	DECLARE @SNewRtrId AS INT
	DECLARE @SOldRtrId AS INT
	DECLARE @DefCount AS INT 
	DECLARE @Tabname AS NVARCHAR(100)
	DECLARE @CntTabname AS NVARCHAR(100)
	DECLARE @FldName AS NVARCHAR(100)
	DECLARE @SRetailerCode AS NVARCHAR(100)
	DECLARE @ErrDesc AS NVARCHAR(1000)
	DECLARE @sSql AS NVARCHAR(4000)
	DECLARE @NewShipAddr AS NVARCHAR(4000)	
	
	DECLARE @ShipSlNo TABLE
	(
		SlNo		 INT IDENTITY,
		ErrorDesc	NVARCHAR(1000) COLLATE DATABASE_DEFAULT
	)
	
	SET @DefCount=0
	SET @Po_ErrNo=0
	SET @CntTabname='RetailerShipAdd'
	SET @Tabname='ETL_Prk_RetailerShippingAddress'
	SET @FldName='RtrShipId'
	SET @SRetailerCode=''
	DECLARE Cur_RetailerShippingAddress CURSOR 
	FOR SELECT dbo.Fn_Removejunk(ISNULL([Retailer Code],'')),dbo.Fn_Removejunk(ISNULL(Address1,'')),dbo.Fn_Removejunk(ISNULL(Address2,'')),
	dbo.Fn_Removejunk(ISNULL(Address3,'')),dbo.Fn_Removejunk(ISNULL([Retailer Shipping Pin Code],'0')),
	ISNULL([Retailer Shipping Phone No],''),dbo.Fn_Removejunk(ISNULL([Default Shipping Address],''))
	FROM ETL_Prk_RetailerShippingAddress WITH(NOLOCK) ORDER BY [Retailer Code],[Default Shipping Address]
	
	OPEN Cur_RetailerShippingAddress
	FETCH NEXT FROM Cur_RetailerShippingAddress INTO @RetailerCode,@Address1,@Address2,@Address3,
				@RtrShipPinNo,@RtrShipPhoneNo,@DefaultShippingAddress
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT EXISTS  (SELECT * FROM Retailer WHERE RtrCode = @RetailerCode)    
  		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'Retailer Code ' + @RetailerCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (1,@Tabname,'RetailerCode',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @RtrId =RtrId FROM Retailer WHERE RtrCode = @RetailerCode
		END
		IF LTRIM(RTRIM(@Address1))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'Retailer Shipping Address should not be empty'  		 
			INSERT INTO Errorlog VALUES (2,@Tabname,'Address',@ErrDesc)
		END
		IF LEN(@RtrShipPinNo)<>0
		BEGIN
			IF ISNUMERIC(@RtrShipPinNo)=0
			BEGIN
				SET @Po_ErrNo=1	
				SET @ErrDesc = 'PinCode is not in correct format'		 
				INSERT INTO Errorlog VALUES (3,@Tabname,'RtrShipPinNo',@ErrDesc)
			END	
		END					
		IF LTRIM(RTRIM(@RtrShipPhoneNo))<>'' 
		BEGIN		
			SET @Po_ErrNo=0	
		END	
	
		SET @DefCount=0
		
		IF LTRIM(RTRIM(@DefaultShippingAddress))='YES' 
		BEGIN
			IF NOT EXISTS (SELECT * FROM RetailerShipAdd WHERE RtrId=@RtrId AND 
			RtrShipDefaultAdd=1)
			BEGIN
				SET @DefCount=1
			END
			ELSE
			BEGIN
				SET @DefaultShippingAddress='NO'
				SET @DefCount=1
			END
		END
		ELSE
		BEGIN
			SET @DefCount=1
		END
		IF @DefCount=2
		BEGIN
			SET @Po_ErrNo=1		
			SET @ErrDesc = 'Default Shipping Address already exists for the Retailer '+@RetailerCode		 
			INSERT INTO Errorlog VALUES (6,@Tabname,'DefaultShippingAddress',@ErrDesc)
		END
		IF @DefCount=0 
		BEGIN
			SET @Po_ErrNo=1		
			SET @ErrDesc = 'Default Shipping Address is not available for the Retailer '+@RetailerCode		 
			INSERT INTO Errorlog VALUES (7,@Tabname,'DefaultShippingAddress',@ErrDesc)
		END
			
		SELECT @RtrShipId=dbo.Fn_GetPrimaryKeyInteger(@CntTabname,@FldName,CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
	
		IF @RtrShipId=0 
		BEGIN
			SET @Po_ErrNo=1		
			SET @ErrDesc = 'Reset the Counter value '+@RetailerCode		 
			INSERT INTO Errorlog VALUES (8,@Tabname,'Counter Value',@ErrDesc)
		END
			
		SELECT @NewShipAddr=@Address1+@Address2+@Address3+@RtrShipPinNo+@RtrShipPhoneNo
		IF NOT EXISTS(SELECT LTRIM(RTRIM(RtrShipAdd1))+LTRIM(RTRIM(RtrShipAdd2))+LTRIM(RTRIM(RtrShipAdd3))+
		LTRIM(RTRIM(CAST(RtrShipPinNo AS NVARCHAR(10))))+LTRIM(RTRIM(RtrShipPhoneNo))
		FROM RetailerShipAdd WHERE RtrId=@RtrId AND LTRIM(RTRIM(RtrShipAdd1))+LTRIM(RTRIM(RtrShipAdd2))+LTRIM(RTRIM(RtrShipAdd3))+
		LTRIM(RTRIM(CAST(RtrShipPinNo AS NVARCHAR(10))))+LTRIM(RTRIM(RtrShipPhoneNo))=LTRIM(RTRIM(@NewShipAddr)))
		BEGIN
			IF  @Po_ErrNo=0
			BEGIN	
				INSERT INTO RetailerShipAdd(RtrShipId,RtrId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo,RtrShipDefaultAdd,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,TaxGroupId,StateId,GSTTinNo,Upload) 
				VALUES(@RtrShipId,@RtrId,@Address1,@Address2,@Address3,@RtrShipPinNo,@RtrShipPhoneNo,
				(CASE @DefaultShippingAddress WHEN 'YES' THEN 1 ELSE 0 END),
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0,0,'','N')
				
				SET @sSql='INSERT INTO RetailerShipAdd(RtrShipId,RtrId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo,RtrShipDefaultAdd,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
				VALUES('+CAST(@RtrShipId AS VARCHAR(10))+','+CAST(@RtrId AS VARCHAR(10))+','''+@Address1+''','''+@Address2+''','''+@Address3+''','''','''','+CAST(@RtrShipPinNo AS VARCHAR(10))+','''+@RtrShipPhoneNo+''',
				'+CAST((CASE @DefaultShippingAddress WHEN 'YES' THEN 1 ELSE 0 END)AS VARCHAR(10))+',
				1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				INSERT INTO Translog(strSql1) VALUES (@sSql)
		
				UPDATE Retailer SET RtrShipId=@RtrShipId WHERE RtrId=@RtrId
				EXEC Proc_UpdateRetailerShipping @RtrId,@RtrShipId
		
				SET @sSql='UPDATE Retailer SET RtrShipId='+CAST(@RtrShipId AS VARCHAR(10))+' WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
	
			IF EXISTS (SELECT * FROM RetailerShipAdd WHERE RtrShipId=@RtrShipId)
			BEGIN
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName=@CntTabname AND FldName=@FldName
		
				SET @sSql='UPDATE Counters SET CurrValue=CurrValue'+'+1'+' WHERE TabName='''+@CntTabname+''' AND FldName='''+@FldName+''''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
			
		FETCH NEXT FROM Cur_RetailerShippingAddress INTO @RetailerCode,@Address1,@Address2,@Address3,@RtrShipPinNo,@RtrShipPhoneNo,@DefaultShippingAddress
	END
	CLOSE Cur_RetailerShippingAddress
	DEALLOCATE Cur_RetailerShippingAddress
	
	IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd WHERE RtrShipDefaultAdd=1))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 1,@Tabname,'Default Shipping Address','Default Shipping Address not available for '+CAST(RtrCode AS NVARCHAR(50)) FROM Retailer
		WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)
		SET @Po_ErrNo=1
	END
	--->Added By Nanda on 04/03/2010
	IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Shipping Address','Shipping Address is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerShipAdd)
		DELETE FROM RetailerMarket WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)
		DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)		
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerShipAdd))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)
		SET @sSql='DELETE FROM RetailerMarket WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)
		DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)		
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerShipAdd))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	ELSE IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Route','Route is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerMarket)
		DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerMarket))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)
		SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerMarket))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	ELSE IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerValueClassMap))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Value Class','Value Class is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerValueClassMap))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerValueClassMap)
		SET @sSql='DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerValueClassMap))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerValueClassMap)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	--->Till Here
	RETURN
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Export_CS2WS_Customer]') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_CS2WS_Customer
GO
/*
BEGIN TRAN
DELETE FROM WSMasterExportUploadTrack
DELETE FROM Export_CS2WS_Customer
Exec Proc_Export_CS2WS_Customer '1'
select * from Export_CS2WS_Customer 
--select * from WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[Proc_Export_CS2WS_Customer]
(
   @SalRpCode varchar(100)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_Customer 
* PURPOSE		: To Export Customer details to the PDA Intermediate Database
* CREATED		: AMUTHA KUMAR P
* CREATED DATE	: 16-08-2018
* MODIFIED		: 
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 16/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Customer details
*********************************************************************************************************************/
BEGIN

	IF NOT EXISTS(SELECT * FROM Retailer WHERE RtrCode='Dummy')
	BEGIN
		DELETE FROM ETL_Prk_Retailer
		DELETE FROM ETL_Prk_RetailerShippingAddress
		DELETE FROM ETL_Prk_RetailerRoute
		DELETE FROM ETL_Prk_RetailerValueClassMap

		INSERT INTO ETL_Prk_Retailer([Retailer Code],[Retailer Name],[Address1],[Address2],[Address3],[Pin Code],[Phone No],[EmailId],[Key Account],[Coverage Mode],[Registration Date],[Day Off],[Status],[Taxable],[Tax Type],[TIN Number],[CST Number],[Tax Group],[Credit Bills],[Credit Limit],[Credit Days],[Cash Discount Percentage],[Cash Discount Condition],[Cash Discount Limit Value],[License Number],[License Number Expiry Date],[Drug License Number],[Drug License Number Expiry Date],[Pesticide License Number],
		[Pesticide License Number Expiry Date],[Geography Hierarchy Value],[Delivery Route Code],[Village Code],[Residence Phone No],[Office Phone No],[Deposit Amount],[Potential Class Code],[Retailer Type],[Retailer Frequency],[Credit Days Alert],[Credit Bills Alert],[Credit Limit Alert]) 
		VALUES ('Dummy','Dummy','Dummy','','','0','1201301401','','NO','Order Booking',CONVERT(varchar(10),GETDATE(),121),'Sunday','Active','Yes','NON VAT','','','RTRINTRA','0','0.00','0','0.00','>=','0.00','',NULL,'',NULL,'',NULL,'','',NULL,'','','0.00',NULL,'Retailer','Weekly','None','None','None')

		UPDATE ETL_Prk_Retailer SET [Delivery Route Code]=(
		SELECT TOP 1 RMCode FROM RouteMaster WHERE RMSRouteType=2 Order by RMId DESC)
		UPDATE ETL_Prk_Retailer SET [Geography Hierarchy Value]=(
		SELECT TOP 1 GeoCode FROM Geography Order by GeoMainId DESC)

		INSERT INTO ETL_Prk_RetailerShippingAddress([Retailer Code],[Address1],[Address2],[Address3],[Retailer Shipping Pin Code],[Retailer Shipping Phone No],[Default Shipping Address])
		VALUES ('Dummy','Dummy','0','0','0','0','YES')
		
		INSERT INTO ETL_Prk_RetailerRoute([Retailer Code],[Route Code],[Selection Type])
		SELECT TOP 1 'Dummy',RMCode,'ADD' FROM RouteMaster WHERE RMSRouteType=1 
		AND RMId IN (SELECT MAX(RMID) AS RMID FROM SalesmanMarket GROUP BY SMId)
		
		INSERT INTO ETL_Prk_RetailerValueClassMap([Retailer Code],[Value Class Code],[Category Level Value],[Selection Type])
		SELECT TOP 1 'Dummy',A.ValueClassCode,B.CtgCode,'ADD' FROM RetailerValueClass A (NOLOCK)
		INNER JOIN RetailerCategory B (NOLOCK) ON A.CtgMainId=B.CtgMainId 
		ORDER BY RtrClassId DESC
		EXEC Proc_ValidateRetailerMaster 0
		
		IF EXISTS(SELECT * FROM Retailer WHERE RtrCode='Dummy')
		BEGIN
			EXEC Proc_ValidateRetailerValueClassMap 0
			EXEC Proc_ValidateRetailerRoute 0
			EXEC Proc_ValidateRetailerShippingAddress 0 
		END
		
		IF EXISTS(SELECT * FROM Retailer WHERE RtrCode='Dummy' AND ISNULL(CmpRtrCode,'')<>'Dummy')
		BEGIN
			UPDATE Retailer SET CmpRtrCode='Dummy' WHERE RtrCode='Dummy'
			UPDATE CompanyCounters SET CurrValue = CurrValue-1 WHERE Tabname =  'Retailer' AND Fldname = 'CmpRtrCode'
		END  
	END

	DECLARE @Smid AS int
	DECLARE @Sql AS varchar(3000)
	DECLARE @Date AS datetime
	DECLARE @Week AS int
	DECLARE @WCal AS int
	DECLARE @StartDate AS datetime
	DECLARE @EndDate AS datetime
	SELECT @StartDate=JcmSdt FROM JCMonth WHERE CONVERT(varchar(10),getdate(),121) BETWEEN JcmSdt AND JcmEdt
	SELECT @EndDate = JcmEdt FROM JCMonth WHERE CONVERT(varchar(10),getdate(),121) BETWEEN JcmSdt AND JcmEdt
	SELECT @Week=jcwwk FROM JCWeek WHERE CONVERT(varchar(10),getdate(),121) BETWEEN JcwSdt AND JcwEdt
	
	SELECT @date=CONVERT(varchar(10),getdate(),121)
	DELETE FROM Export_CS2WS_Customer WHERE UploadFlag='Y'
	
	IF EXISTS (SELECT * FROM sysobjects WHERE NAME='TempRetailer' and xtype='U')
	BEGIN
		DROP TABLE TempRetailer
	END
IF EXISTS (SELECT count(DISTINCT jcwwk) FROM JCWeek WHERE JcmJc=month(getdate()) HAVING count(DISTINCT jcwwk)=6)
 BEGIN
	IF @Week=1 	BEGIN SET @WCal=6 END 
	IF @Week=2	BEGIN SET @WCal=5 END 
	IF @Week=3	BEGIN SET @WCal=4 END 
	IF @Week=4	BEGIN SET @WCal=3 END
	IF @Week=5	BEGIN SET @WCal=2 END
	IF @Week=6	BEGIN SET @WCal=1 END
 END 
IF EXISTS (SELECT count(DISTINCT jcwwk) FROM JCWeek WHERE JcmJc=month(getdate()) HAVING count(DISTINCT jcwwk)=5)
 BEGIN
	IF @Week=1 	BEGIN SET @WCal=5 END 
	IF @Week=2	BEGIN SET @WCal=4 END 
	IF @Week=3	BEGIN SET @WCal=3 END 
	IF @Week=4	BEGIN SET @WCal=2 END
	IF @Week=5	BEGIN SET @WCal=1 END
 END 
IF EXISTS (SELECT count(DISTINCT jcwwk) FROM JCWeek WHERE JcmJc=month(getdate()) HAVING count(DISTINCT jcwwk)=4)
BEGIN 
	IF @Week=1	BEGIN SET @WCal=4 END 
	IF @Week=2	BEGIN SET @WCal=3 END 
	IF @Week=3	BEGIN SET @WCal=2 END 
	IF @Week=4	BEGIN SET @WCal=1 END 
END 

SET @Sql ='SELECT distinct  DistributorCode,R.RtrID,R.CmpRtrCode,R.RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,GeoName,GeoName as State,RtrPinNo,Left(RtrPhoneNo,30)RtrPhoneNo,RtrEmailId,RtrContactPerson,
	RtrRemark1,RC1.CtgCode AS ChannelCode,RC.CtgCode as GroupCode,ValueClassCode,RtrStatus AS CustomerStatus,1 As SalesMode,1 AS PaymentType,CAST('''' AS VARCHAR(100)) AS CustomerPricingKey,0 RmId,RtrCrLimit,0 AS TotalBalanceDue,
	1 as IsTaxable, 0 as TaxId,0 as SurveyKey,RtrDOB as DateofBirth, RtrTinNo as RtrTinNO INTO TempRetailer
	FROM Retailer R 
	INNER JOIN Geography G ON R.GeoMainId = G.GeoMainId
	INNER JOIN RetailerValueClassMap RVM ON R.RtrID = RVM.RtrID 
	INNER JOIN RetailerValueClass RV ON RVM.RtrValueClassId = RV.RtrClassId
	INNER JOIN RetailerCategory RC ON RC.CtgMainId = RV.CtgMainId 
	INNER JOIN RetailerCategory RC1 (NOLOCK) ON RC1.CtgMainId=RC.CtgLinkId 
	CROSS JOIN Distributor D WHERE RtrStatus in(1)'
	EXEC (@Sql)

--SET @Sql ='SELECT DistributorCode,R.RtrID,R.CmpRtrCode,R.RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,GeoName,GeoName as State,RtrPinNo,Left(RtrPhoneNo,30)RtrPhoneNo,RtrEmailId,RtrContactPerson,
--	RtrRemark1,CtgCode,ValueClassCode,RtrStatus AS CustomerStatus,1 As SalesMode,1 AS PaymentType,0 AS CustomerPricingKey,RM.RmId,RtrCrLimit,0 AS TotalBalanceDue,
--	1 as IsTaxable, 0 as TaxId,0 as SurveyKey,RtrDOB as DateofBirth, RtrTinNo as RtrTinNO INTO TempRetailer
--	FROM Retailer R 
--	INNER JOIN Geography G ON R.GeoMainId = G.GeoMainId
--	INNER JOIN RetailerValueClassMap RVM ON R.RtrID = RVM.RtrID 
--	INNER JOIN RetailerValueClass RV ON RVM.RtrValueClassId = RV.RtrClassId
--	INNER JOIN RetailerCategory RC ON RC.CtgMainId = RV.CtgMainId 
--	INNER JOIN RetailerMarket RM ON RM.RtrId=R.RtrId
--	INNER JOIN SalesmanMarket SM ON sm.RMId=RM.RMId
--	CROSS JOIN Distributor D WHERE RtrStatus in(1) AND
--	sm.SMId in('+ CAST(@SalRpCode AS VARCHAR(100)) +')'
--	EXEC (@Sql)
		
	SELECT DISTINCT B.ColumnName,A.ColumnValue,MasterRecordId INTO #TEMPUDCROUTE1
	FROM UdcDetails A,UdcMaster B, UdcHD C WHERE  A.UdcMasterId=B.UdcMasterId
	AND A.MasterId=B.MasterId AND ColumnName='State Name' AND MasterName='Retailer Master'
	
		
	UPDATE T SET [State]=R.ColumnValue FROM TempRetailer T INNER JOIN #TEMPUDCROUTE1 R ON T.rtrid=R.MasterRecordId 
	
	SELECT R.RtrId,R.CmpRtrCode,RC.CtgCode as GroupCode,RC.CtgMainId AS GroupId,
	RC1.CtgCode AS ChannelCode,RC1.CtgMainId AS ChannelId into #temp1 FROM Retailer R (NOLOCK)
	INNER JOIN RetailerValueClassMap RVCM (NOLOCK) ON R.RtrId=RVCM.RtrId 
	INNER JOIN RetailerValueClass RVC (NOLOCK) ON RVC.RtrClassId=RVCM.RtrValueClassId 
	INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RVC.CtgMainId
	INNER JOIN RetailerCategory RC1 (NOLOCK) ON RC1.CtgMainId=RC.CtgLinkId 
	
	
	
	CREATE TABLE #PricingKey
	(
		CustomerCode	VARCHAR(100),
		CtgCode			VARCHAR(100)
	)
	
	INSERT INTO #PricingKey(CustomerCode,CtgCode)
	SELECT DISTINCT R.CmpRtrCode,R.CmpRtrCode AS CmpRtrCode1 FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId=R.RtrId  
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.RtrId<>0
	
	UPDATE A SET A.CustomerPricingKey=B.CustomerCode FROM TempRetailer A INNER JOIN #PricingKey B ON A.CmpRtrCode=B.CustomerCode
	
	delete from #PricingKey
	
	INSERT INTO #PricingKey(CustomerCode,CtgCode)
	SELECT DISTINCT T.CmpRtrCode,R.CtgCode
	FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN RetailerCategory R (NOLOCK) ON A.CtgMainId=R.CtgMainId  
	inner JOIN #temp1 T (NOLOCK) ON (T.ChannelId=R.CtgMainId OR T.GroupId=R.CtgMainId)
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.CtgMainId<>0
	
	UPDATE A SET A.CustomerPricingKey=B.CtgCode FROM TempRetailer A INNER JOIN #PricingKey B ON A.CmpRtrCode=B.CustomerCode
	WHERE ISNULL(CustomerPricingKey,'')=''
	
	INSERT INTO Export_CS2WS_Customer(TenantCode,LocationCode,CustomerCode,CustomerName,Address1,Address2,Address3,Address4,City,State,Zip,Phone,Fax,Email,ContactPerson,
	Notes,CategoryCode1,CategoryCode2,CategoryCode3,CustomerStatus,SalesMode,PaymentType,CustomerPricingKey,TotalCreditLimit,TotalBalanceDue,
	IsTaxable,TaxID,HierarchyCode,TerritoryHierarchy,SurveyKey,DateofBirth,IDNumber,TINNumber,UploadFlag)
	SELECT DISTINCT  DistributorCode,DistributorCode,CmpRtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,'' as Address4,GeoName,State,RtrPinNo,RtrPhoneNo,'' as Fax,RtrEmailId,RtrContactPerson,
	RtrRemark1,ChannelCode,GroupCode,ValueClassCode,CustomerStatus,SalesMode,PaymentType,ISNULL(CustomerPricingKey,''),RtrCrLimit,TotalBalanceDue,IsTaxable,TaxID,GroupCode,'',SurveyKey,DateofBirth,'',RtrTinNo,
	'N' AS UploadFlag FROM TempRetailer R 
	WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = R.CmpRtrCode AND R.CustomerPricingKey=M.Reference2 AND M.ProcessName='Customer') 
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'Customer',CustomerCode,CustomerName,GETDATE(),0,LocationCode,CustomerPricingKey,CategoryCode2,0 FROM Export_CS2WS_Customer WHERE UploadFlag='N'
	 
	
	UPDATE R SET R.WSUpload='Y' FROM WSMasterExportUploadTrack A (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.MasterCode=R.CmpRtrCode
	WHERE ISNULL(R.WSUpload,'N')='N' AND ProcessName='Customer'
		
	SELECT	DISTINCT 
			TenantCode,
			LocationCode,
			CustomerCode,
			CustomerName,
			Address1,
			Address2,
			Address3,
			Address4,
			City,
			State,
			Zip,
			Phone,
			Fax,
			Email,
			ContactPerson,
			Notes,
			CategoryCode1,
			CategoryCode2,
			CategoryCode3,
			CustomerStatus,
			SalesMode,
			PaymentType,
			CustomerPricingKey,
			TotalCreditLimit,
			TotalBalanceDue,
			IsTaxable,
			TaxID,
			HierarchyCode,
			TerritoryHierarchy,
			SurveyKey,
			DateofBirth,
			IDNumber,
			TINNumber 
	FROM Export_CS2WS_Customer WITH (NOLOCK)
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_Product' and xtype='U')
DROP TABLE Export_CS2WS_Product
GO
CREATE TABLE Export_CS2WS_Product
(
	TenantCode			[nvarchar](12),
	ItemCode			[nvarchar](50),
	UnitsOfMeasure		[nvarchar](20),
	EANNumber			[nvarchar](18),
	ItemTypeCode		[Tinyint],
	ItemDescription		[nvarchar](100),
	ShortDescription	[nvarchar](50),
	DivisionCode		[nvarchar](12),	
	IsBUOM				[Tinyint],	
	Numerator			[Smallint],
	Denominator			[Smallint],
	[Weight]			[Float],
	MRP					[Float],
	DefaultDebitPrice	[Float],
	DefaultCreditPrice	[Float],
	DefaultDamagePrice	[Float],
	ChangeLimit			[Float],
	CodeDateFormat		[Tinyint],
	ItemShelfLife		[Smallint],
	IsActive			[Tinyint],
	ContributionMargin	[Float],
	IsBatchManaged		[Tinyint],
	HierarchyCode		[nvarchar](50),
	TaxCode				[Float],
	HSNCode				[nvarchar](12),
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_Product' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_Product
GO
--exec Proc_Export_CS2WS_Product '1'
--SELECT * FROM WSMasterExportUploadTrack where 
CREATE PROCEDURE Proc_Export_CS2WS_Product
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_Product
* PURPOSE		: To Export Product details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 06/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN
DECLARE @DistCode NVARCHAR(40)
DECLARE @Prdid AS int
DECLARE @Prdbatid AS int
	DELETE FROM Export_CS2WS_Product WHERE UploadFlag='Y'
	SELECT @DistCode = DistributorCode FROM Distributor
	
	CREATE TABLE #Export_CS2WS_Product
	(
			PrdID				[Bigint],
			TenantCode			[nvarchar](12)COLLATE DATABASE_DEFAULT,
			ItemCode			[nvarchar](50)COLLATE DATABASE_DEFAULT,
			UnitsOfMeasure		[nvarchar](20)COLLATE DATABASE_DEFAULT,
			EANNumber			[nvarchar](18)COLLATE DATABASE_DEFAULT,
			ItemTypeCode		[Tinyint],
			ItemDescription		[nvarchar](100) COLLATE DATABASE_DEFAULT,
			ShortDescription	[nvarchar](50) COLLATE DATABASE_DEFAULT,
			DivisionCode		[nvarchar](12) COLLATE DATABASE_DEFAULT,	
			IsBUOM				[Tinyint],	
			Numerator			[Smallint],
			Denominator			[Smallint],
			[Weight]			[Float],
			MRP					[Float],
			DefaultDebitPrice	[Float],
			DefaultCreditPrice	[Float],
			DefaultDamagePrice	[Float],
			ChangeLimit			[Float],
			CodeDateFormat		[Tinyint],
			ItemShelfLife		[Smallint],
			IsActive			[Tinyint],
			ContributionMargin	[Float],
			IsBatchManaged		[Tinyint],
			HierarchyCode		[nvarchar](50) COLLATE DATABASE_DEFAULT,
			TaxCode				[Float],
			HSNCode				[nvarchar](12)COLLATE DATABASE_DEFAULT
	)
	
	--DATA UPLOAD ALL UOMS LINE WISE
	INSERT INTO #Export_CS2WS_Product(PrdID,TenantCode,ItemCode,UnitsOfMeasure,EANNumber,ItemTypeCode,ItemDescription,
	ShortDescription,DivisionCode,IsBUOM,Numerator,Denominator,[Weight],MRP,DefaultDebitPrice,DefaultCreditPrice,DefaultDamagePrice,
	ChangeLimit,CodeDateFormat,ItemShelfLife,IsActive,ContributionMargin,IsBatchManaged,HierarchyCode,HSNCode,TaxCode)
	SELECT DISTINCT P.PrdID,@DistCode as TenantCode,PrdCCode,UM.UomCode,P.EANCode,1 ItemTypeCode,
	P.PrdName,'' PrdShrtName,'DD' as DivisionCode,CASE WHEN UG.BaseUom='Y' THEN 1 ELSE 0 END IsBUOM,UG.ConversionFactor Numerator,1 Denominator,ISNULL(P.PrdWgt,0) as PrdWgt,
	CAST(0 AS numeric(18,2)) AS MRP,CAST(0 AS numeric(18,2)) AS DefaultDebitPrice,CAST(0 AS numeric(18,2)) AS DefaultCreditPrice,
	CAST(0 AS numeric(18,2))AS DefaultDamagePrice,0 ChangeLimit,0 CodeDateFormat,PrdShelfLife ItemShelfLife,
	ISNULL(P.PrdStatus,0) AS PrdStatus,0 ContributionMargin,0 IsBatchManaged,'' HierarchyCode,'' HSNCode,0
	FROM Product P (NOLOCK)
	INNER JOIN Fn_SFAProductToSend() PB ON P.PrdId=PB.PrdId 
	INNER JOIN UomGroup UG ON P.UomGroupId = UG.UomGroupID
	INNER JOIN UomMaster UM ON UM.UomId=UG.UomId 
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId
	--WHERE PrdStatus = 1 --AND Publish = 1
	--and NOT EXISTS (SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = P.PrdCCode AND M.[Status]=P.PrdStatus AND M.ProcessName='Product') 	
		
	---Data Upload based on UOMGROUP
	--SELECT DISTINCT P.PrdID,@DistCode as TenantCode,PrdCCode,UOMgroupCode,P.EANCode,1 ItemTypeCode,
	--P.PrdName,'' PrdShrtName,'DD' as DivisionCode,1 IsBUOM,1 Numerator,1 Denominator,ISNULL(P.PrdWgt,0) as PrdWgt,
	--CAST(0 AS numeric(18,2)) AS MRP,CAST(0 AS numeric(18,2)) AS DefaultDebitPrice,CAST(0 AS numeric(18,2)) AS DefaultCreditPrice,
	--CAST(0 AS numeric(18,2))AS DefaultDamagePrice,0 ChangeLimit,0 CodeDateFormat,PrdShelfLife ItemShelfLife,
	--ISNULL(P.PrdStatus,0) AS PrdStatus,0 ContributionMargin,0 IsBatchManaged,'' HierarchyCode,'' HSNCode
	--FROM Product P
	--INNER JOIN UomGroup UG ON P.UomGroupId = UG.UomGroupID
	--INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId
	--WHERE PrdStatus = 1 --AND Publish = 1	
	

	
	---MRP AND Selling Rate
	SELECT A.PrdID,Max(PB.PrdBatId) AS PrdBatId	INTO #TempProductBatch FROM #Export_CS2WS_Product A 
	INNER JOIN ProductBatch PB (NOLOCK) ON A.PrdID=PB.PRDID
	WHERE  PrdBatCode <> 'Sample Batch' GROUP BY A.PrdID

	SELECT DISTINCT P.PrdID,PB.PrdBatId,B.PrdBatDetailValue AS MRP,B1.PrdBatDetailValue as SellRate 
	INTO #TempPriceDt
	FROM Product P
	INNER JOIN ProductBatch PB ON P.PrdID = PB.PrdID	
	INNER JOIN #TempProductBatch PB1 ON P.PrdID = PB1.PrdID AND PB.PrdBatId=PB1.PrdBatId AND PB.PrdID = PB1.PrdID
	INNER JOIN ProductBatchDetails B (NOLOCK) ON PB.PrdBatId = B.PrdBatID AND B.DefaultPrice=1
	INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = PB.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
	INNER JOIN ProductBatchDetails B1 (NOLOCK) ON PB.PrdBatId = B1.PrdBatID AND B1.DefaultPrice=1
	INNER JOIN BatchCreation C1 (NOLOCK) ON C1.BatchSeqId = PB.BatchSeqId AND B1.SlNo = C1.SlNo AND C1.SelRte = 1 
	ORDER BY P.PrdId
	
	UPDATE A SET A.MRP=B.MRP,A.DefaultCreditPrice=B.SellRate,A.DefaultDebitPrice=B.SellRate,A.DefaultDamagePrice=B.SellRate 
	FROM #Export_CS2WS_Product A 
	INNER JOIN #TempPriceDt B ON A.PrdID=B.PrdId 
	
	---	 Product HierarChy Code/Flavor Code
	UPDATE A SET A.HierarchyCode=ISNULL(B.Flavor_Code,'')
	FROM #Export_CS2WS_Product A 
	INNER JOIN TBL_GR_BUILD_PH B ON A.PrdID=B.PrdId 
	
	--Product HSN Code
	UPDATE D SET D.HSNCode=ISNULL(C.ColumnValue,'')  FROM UdcHD A (NOLOCK)
	INNER JOIN UdcMaster B(NOLOCK) ON A.MasterId=B.MasterId 
	INNER JOIN UdcDetails C(NOLOCK) ON C.UdcMasterId=B.UdcMasterId AND C.MasterId=B.MasterId AND C.MasterId=A.MasterId 
	INNER JOIN #Export_CS2WS_Product D ON D.PrdID=C.MasterRecordId 
	WHERE A.MasterName='Product Master' AND B.ColumnName='HSN Code'
	
	 TRUNCATE TABLE ProductBatchTaxPercent  
	 
	 DECLARE Cur_CalculateTax CURSOR   
	 FOR SELECT DISTINCT PrdId,PrdBatID FROM #TEMPProductbatch    
	 OPEN Cur_CalculateTax   
	 FETCH NEXT FROM Cur_CalculateTax INTO @Prdid,@Prdbatid      
	 WHILE @@FETCH_STATUS = 0          
	 BEGIN     
	  EXEC Proc_TaxCalCulation @Prdid,@Prdbatid   
	 FETCH NEXT FROM Cur_CalculateTax INTO @Prdid,@Prdbatid            
	 END          
	 CLOSE Cur_CalculateTax          
	 DEALLOCATE Cur_CalculateTax  
	 
	 UPDATE A SET TAXCode=b.TaxPercentage FROM #Export_CS2WS_Product A 
	 INNER JOIN ProductBatchTaxPercent B ON A.PrdID=b.PrdId 
	
	INSERT INTO Export_CS2WS_Product(TenantCode,ItemCode,UnitsOfMeasure,EANNumber,ItemTypeCode,ItemDescription,
	ShortDescription,DivisionCode,IsBUOM,Numerator,Denominator,[Weight],MRP,DefaultDebitPrice,DefaultCreditPrice,DefaultDamagePrice,
	ChangeLimit,CodeDateFormat,ItemShelfLife,IsActive,ContributionMargin,IsBatchManaged,HierarchyCode,TaxCode,HSNCode,UploadFlag)
	SELECT TenantCode,ItemCode,UnitsOfMeasure,EANNumber,ItemTypeCode,ItemDescription,
	ShortDescription,DivisionCode,IsBUOM,Numerator,Denominator,[Weight],MRP,DefaultDebitPrice,DefaultCreditPrice,DefaultDamagePrice,
	ChangeLimit,CodeDateFormat,ItemShelfLife,IsActive,ContributionMargin,IsBatchManaged,HierarchyCode,TaxCode,HSNCode,'N' UploadFlag 
	FROM #Export_CS2WS_Product P
	WHERE NOT EXISTS (SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = P.ItemCode AND M.[Status]=P.IsActive 
	AND M.Reference1=P.TaxCode AND M.Reference2=P.HierarchyCode  AND  M.Reference3=P.UnitsOfMeasure  AND  M.Ref4Value=P.DefaultDebitPrice 
	AND M.ProcessName='Product') 
	ORDER BY ItemCode
	
	DELETE A FROM WSMasterExportUploadTrack A INNER JOIN Export_CS2WS_Product B ON A.MasterCode=B.ItemCode
	WHERE ProcessName='Product'
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'Product',ItemCode,ItemDescription,GETDATE(),IsActive,TaxCode,HierarchyCode,UnitsOfMeasure,DefaultDebitPrice FROM Export_CS2WS_Product WHERE UploadFlag='N'
	
	
	SELECT DISTINCT 
			TenantCode,
			ItemCode,
			UnitsOfMeasure,
			EANNumber,
			ItemTypeCode,
			ItemDescription,
			ShortDescription,
			DivisionCode,  
			IsBUOM,
			Numerator,
			Denominator,
			[Weight],
			MRP,
			DefaultDebitPrice,
			DefaultCreditPrice,
			DefaultDamagePrice,
			ChangeLimit,
			CodeDateFormat,
			ItemShelfLife,
			IsActive,
			ContributionMargin,
			IsBatchManaged,
			HierarchyCode,
			TaxCode,
			HSNCode
		FROM Export_CS2WS_Product WITH (NOLOCK) 
	
	
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_PricingPlan' and xtype='U')
DROP TABLE Export_CS2WS_PricingPlan
GO
CREATE TABLE Export_CS2WS_PricingPlan
(
	TenantCode			[nvarchar](12),
	PricingCode			[nvarchar](12),
	PricingDescription	[nvarchar](12),
	StartDate			[Datetime],
	EndDate				[Datetime],
	ItemCode			[nvarchar](50),
	UnitsOfMeasure		[nvarchar](20),	
	DebitPrice			[Float],
	CreditPrice			[Float],
	DamagePrice			[Float],
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_PricingPlan' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_PricingPlan
GO
--EXEC Proc_Export_CS2WS_PricingPlan '1'
CREATE PROCEDURE Proc_Export_CS2WS_PricingPlan
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_PricingPlan
* PURPOSE		: To Export Product Price details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 07/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN
DECLARE @DistCode NVARCHAR(40)
DECLARE @Prdid AS int
DECLARE @Prdbatid AS int
	
	DELETE FROM Export_CS2WS_PricingPlan 
	
	SELECT @DistCode = DistributorCode FROM Distributor
	
	CREATE TABLE #Export_CS2WS_PricingPlan
	(
			PrdID				[Bigint],
			TenantCode			[nvarchar](12) COLLATE DATABASE_DEFAULT,
			PricingCode			[nvarchar](12)COLLATE DATABASE_DEFAULT,
			PricingDescription	[nvarchar](12)COLLATE DATABASE_DEFAULT,
			StartDate			[Datetime],
			EndDate				[Datetime],
			ItemCode			[nvarchar](50)COLLATE DATABASE_DEFAULT,
			UnitsOfMeasure		[nvarchar](20)COLLATE DATABASE_DEFAULT,	
			DebitPrice			[Float],
			CreditPrice			[Float],
			DamagePrice			[Float],
			PriceId			[BIGINT]
	)
	
	SELECT R.RtrId,R.CmpRtrCode,RC.CtgCode as GroupCode,RC.CtgMainId AS GroupId,
	RC1.CtgCode AS ChannelCode,RC1.CtgMainId AS ChannelId into #temp1 FROM Retailer R (NOLOCK)
	INNER JOIN RetailerValueClassMap RVCM (NOLOCK) ON R.RtrId=RVCM.RtrId 
	INNER JOIN RetailerValueClass RVC (NOLOCK) ON RVC.RtrClassId=RVCM.RtrValueClassId 
	INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RVC.CtgMainId
	INNER JOIN RetailerCategory RC1 (NOLOCK) ON RC1.CtgMainId=RC.CtgLinkId 

	INSERT INTO #Export_CS2WS_PricingPlan(Prdid,TenantCode,PricingCode,PricingDescription,StartDate,EndDate,
	ItemCode,UnitsOfMeasure,DebitPrice,CreditPrice,DamagePrice,PriceId)
	SELECT P.PrdId,@DistCode,R.CmpRtrCode,R.CmpRtrCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode,0,0,0,MAX(B.PriceId) as PriceId
	FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId=R.RtrId  
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.RtrId<>0
	GROUP BY P.PrdId,R.CmpRtrCode,R.CmpRtrCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode
	
	SELECT DISTINCT PricingCode into #PricingCode from #Export_CS2WS_PricingPlan
	
	INSERT INTO #Export_CS2WS_PricingPlan(Prdid,TenantCode,PricingCode,PricingDescription,StartDate,EndDate,
	ItemCode,UnitsOfMeasure,DebitPrice,CreditPrice,DamagePrice,PriceId)
	SELECT P.PrdId,@DistCode,T.CmpRtrCode,T.CmpRtrCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode,0,0,0,MAX(b.PriceId) as PriceId
	FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN RetailerCategory R (NOLOCK) ON A.CtgMainId=R.CtgMainId  
	inner JOIN #temp1 T (NOLOCK) ON (T.ChannelId=R.CtgMainId OR T.GroupId=R.CtgMainId)
	inner join #PricingCode E (NOLOCK) ON E.PricingCode=T.CmpRtrCode
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.CtgMainId<>0 AND 
	NOT EXISTS(SELECT * FROM #Export_CS2WS_PricingPlan EB INNER JOIN Product P (nolock) ON P.PrdCCode=EB.ItemCode 
	WHERE EB.PricingCode=T.CmpRtrCode AND EB.Prdid=P.PrdId AND EB.Prdid=FP.PrdId AND EB.Prdid=B.PrdId 
	AND EB.PricingCode=E.PricingCode)
	GROUP BY P.PrdId,T.CmpRtrCode,T.CmpRtrCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode
	
	INSERT INTO #Export_CS2WS_PricingPlan(Prdid,TenantCode,PricingCode,PricingDescription,StartDate,EndDate,
	ItemCode,UnitsOfMeasure,DebitPrice,CreditPrice,DamagePrice,PriceId)
	SELECT P.PrdId,@DistCode,R.CtgCode,R.CtgCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode,0,0,0,MAX(PriceId) As PriceId
	FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN RetailerCategory R (NOLOCK) ON A.CtgMainId=R.CtgMainId  
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.CtgMainId<>0
	GROUP BY P.PrdId,R.CtgCode,R.CtgCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode
	
	
	--SELECT A.PrdID,Max(PB.PrdBatId) AS PrdBatId	INTO #TempProductBatch FROM #Export_CS2WS_PricingPlan A 
	--INNER JOIN ProductBatch PB (NOLOCK) ON A.PrdID=PB.PRDID
	--WHERE  PrdBatCode <> 'Sample Batch' GROUP BY A.PrdID

	--SELECT DISTINCT P.PrdID,PB.PrdBatId,B1.PrdBatDetailValue as SellRate 
	--INTO #TempPriceDt
	--FROM Product P (NOLOCK)
	--INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdID = PB.PrdID	
	--INNER JOIN #TempProductBatch PB1(NOLOCK) ON P.PrdID = PB1.PrdID AND PB.PrdBatId=PB1.PrdBatId AND PB.PrdID = PB1.PrdID
	--INNER JOIN ProductBatchDetails B1 (NOLOCK) ON PB.PrdBatId = B1.PrdBatID AND B1.DefaultPrice=1
	--INNER JOIN BatchCreation C1 (NOLOCK) ON C1.BatchSeqId = PB.BatchSeqId AND B1.SlNo = C1.SlNo AND C1.SelRte = 1 
	--ORDER BY P.PrdId
	
	
	UPDATE PP SET PP.DebitPrice=B1.PrdBatDetailValue,PP.CreditPrice=B1.PrdBatDetailValue,PP.DamagePrice=B1.PrdBatDetailValue
	FROM Product P (NOLOCK)
	INNER JOIN #Export_CS2WS_PricingPlan PP ON P.PrdId=PP.PrdID 
	INNER JOIN ProductBatchDetails B1 (NOLOCK) ON B1.PriceId=PP.PriceId
	INNER JOIN BatchCreation C1 (NOLOCK) ON C1.BatchSeqId = B1.BatchSeqId AND B1.SlNo = C1.SlNo AND C1.SelRte = 1 
	
	--As discussed Mr. Awanish to remove duplicate based on Max start date
	SELECT PricingCode,ItemCode INTO #TempDuplicate FROM #Export_CS2WS_PricingPlan 
	GROUP BY PricingCode,ItemCode HAVING COUNT(ItemCode)>1

	SELECT A.PricingCode,A.ItemCode,MAX(A.StartDate) AS StartDate INTO #TempMaxStartDate FROM #Export_CS2WS_PricingPlan A 
	INNER JOIN #TempDuplicate B ON A.PricingCode=B.PricingCode AND A.ItemCode=B.ItemCode 
	GROUP BY A.PricingCode,A.ItemCode
	
	DELETE A FROM #Export_CS2WS_PricingPlan A (NOLOCK)
	INNER JOIN #TempMaxStartDate B ON A.ItemCode=B.ItemCode AND A.PricingCode=B.PricingCode 
	WHERE NOT EXISTS(SELECT * FROM #TempMaxStartDate M WHERE M.PricingCode=A.PricingCode AND M.ItemCode=A.ItemCode AND 
	M.StartDate=A.StartDate)
		
	--UPDATE A SET A.DebitPrice=B.SellRate,A.CreditPrice=B.SellRate,A.DamagePrice=B.SellRate 
	--FROM #Export_CS2WS_PricingPlan A 
	--INNER JOIN #TempPriceDt B ON A.PrdID=B.PrdId and A.PricingCode=
	
	INSERT INTO Export_CS2WS_PricingPlan(TenantCode,PricingCode,PricingDescription,StartDate,EndDate,
	ItemCode,UnitsOfMeasure,DebitPrice,CreditPrice,DamagePrice,UploadFlag)
	SELECT TenantCode,PricingCode,PricingDescription,StartDate,EndDate,ItemCode,UnitsOfMeasure,
	DebitPrice,CreditPrice,DamagePrice,'N' UploadFlag FROM #Export_CS2WS_PricingPlan ORDER BY ItemCode
	
	SELECT  Distinct
			TenantCode,
			PricingCode,
			PricingDescription,
			--CONVERT(VARCHAR(10),StartDate,103) AS StartDate,
			--CONVERT(VARCHAR(10),EndDate,103) AS EndDate,
			ItemCode,
			UnitsOfMeasure,
			DebitPrice,
			CreditPrice,
			DamagePrice
		FROM Export_CS2WS_PricingPlan WITH (NOLOCK) 
	
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_AuthorizedProduct' and xtype='U')
BEGIN
CREATE TABLE Export_CS2WS_AuthorizedProduct
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	Code				[nvarchar](12),
	[Description]		[Nvarchar](100),
	[ItemCode]			[Nvarchar](50),
	UploadFlag			[VARCHAR](1)
)
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='CS2WSProductTrack' and xtype='U')
BEGIN
CREATE TABLE CS2WSProductTrack
(
	SlNo		BIGINT IDENTITY(1,1),
	PrdId		BIGINT,
	PrdCCode	VARCHAR(100),
	PrdStatus	INT,
	Uploaddate	DATETIME
)
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_AuthorizedProduct' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_AuthorizedProduct
GO
--exec [Proc_Export_CS2WS_AuthorizedProduct] '1'
CREATE PROCEDURE Proc_Export_CS2WS_AuthorizedProduct
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_AuthorizedProduct
* PURPOSE		: To Export Authorized Product details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 07/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN
DECLARE @DistCode NVARCHAR(40)
DECLARE @Prdid AS int
DECLARE @DataSend AS int
	DELETE FROM Export_CS2WS_AuthorizedProduct WHERE UploadFlag='Y'
	SELECT @DistCode = DistributorCode FROM Distributor
	
	--SELECT PrdId,MAX(SlNo) AS SlNo INTO #TempPrdTrack 
	--FROM CS2WSProductTrack(NOLOCK) GROUP BY PrdId
	
	--SELECT A.PrdId,A.PrdCCode,A.PrdStatus INTO #CS2WSProductTrack FROM CS2WSProductTrack A (NOLOCK)
	--INNER JOIN #TempPrdTrack B ON A.PrdId=B.PrdId AND A.SlNo=B.SlNo 
	
	--SET @DataSend=0
	--IF EXISTS(SELECT * FROM Product A(NOLOCK) WHERE EXISTS(SELECT * FROM #CS2WSProductTrack B(NOLOCK) WHERE A.PrdId=B.PrdId 
	--AND A.PrdStatus<>B.PrdStatus))
	--BEGIN
	--	SET @DataSend=1
	--END
	
	--IF EXISTS(SELECT * FROM Product A(NOLOCK) WHERE PRDSTATUS=1 AND 
	--PrdId NOT IN (SELECT PrdId FROM CS2WSProductTrack (NOLOCK)))
	--BEGIN
	--	SET @DataSend=1
	--END

	--IF @DataSend=1
	--BEGIN 
		INSERT INTO Export_CS2WS_AuthorizedProduct(TenantCode,LocationCode,Code,[Description],ItemCode,UploadFlag)
		SELECT DISTINCT @DistCode TenantCode,@DistCode LocationCode,@DistCode,PrdDCode,PrdCCode,'N' UploadFlag  
		FROM Product P
		INNER JOIN Fn_SFAProductToSend() B ON P.PrdId=B.PrdId
		INNER JOIN UomGroup UG ON P.UomGroupId = UG.UomGroupID
		INNER JOIN UomMaster UM ON UM.UomId=UG.UomId 
		INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId
		WHERE PrdStatus = 1
		--FROM Product(NOLOCK) WHERE PrdStatus=1
	--END
	
	--AND PrdId NOT IN (SELECT PrdId FROM CS2WSProductTrack (NOLOCK))
	
	--INSERT INTO Export_CS2WS_AuthorizedProduct(TenantCode,LocationCode,Code,[Description],ItemCode,UploadFlag)
	--SELECT @DistCode TenantCode,@DistCode LocationCode,'',PrdName,PrdCCode,'N' UploadFlag  
	--FROM Product A(NOLOCK) WHERE EXISTS(SELECT * FROM #CS2WSProductTrack B(NOLOCK) WHERE A.PrdId=B.PrdId 
	--AND A.PrdStatus<>B.PrdStatus)	
	
	DECLARE @DATETIME AS DATETIME
	SET @DATETIME=GETDATE()
	INSERT INTO CS2WSProductTrack(PrdId,PrdCCode,PrdStatus,Uploaddate)
	SELECT B.PrdId,B.PrdCCode,B.PrdStatus,@DATETIME FROM Export_CS2WS_AuthorizedProduct A(NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.ItemCode=b.PrdCCode
	
	SELECT DISTINCT 
			TenantCode,
			LocationCode,
			Code,
			[Description],
			ItemCode
		FROM Export_CS2WS_AuthorizedProduct WITH (NOLOCK) 
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_WarehouseInventory' and xtype='U')
DROP TABLE Export_CS2WS_WarehouseInventory
GO
CREATE TABLE Export_CS2WS_WarehouseInventory
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	WarehouseCode		[nvarchar](12),
	[ItemCode]			[Nvarchar](50),
	[Quantity]			[Float],
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_WarehouseInventory' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_WarehouseInventory
GO
--exec Proc_Export_CS2WS_WarehouseInventory '1'
CREATE PROCEDURE Proc_Export_CS2WS_WarehouseInventory
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_WarehouseInventory
* PURPOSE		: To Export Inventory details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 07/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
 07/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN
DECLARE @DistCode NVARCHAR(40)
DECLARE @Prdid AS int
DECLARE @Prdbatid AS int
	DELETE FROM Export_CS2WS_WarehouseInventory
	SELECT @DistCode = DistributorCode FROM Distributor
	
	INSERT INTO Export_CS2WS_WarehouseInventory(TenantCode,LocationCode,WarehouseCode,ItemCode,Quantity,UploadFlag)
	SELECT @DistCode TenantCode,@DistCode LocationCode,'MG',PrdCCode,
	SUM(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS Quantity,'N' UploadFlag  
	FROM Product A (NOLOCK) 
	INNER JOIN Fn_SFAProductToSend() B ON A.PrdId=B.PrdId
	INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId and PBL.PrdId=B.PrdId
	INNER JOIN Location L (NOLOCK) ON L.LcnId=PBL.LcnId 	
	INNER JOIN UomGroup UG ON A.UomGroupId = UG.UomGroupID AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM ON UM.UomId=UG.UomId 
	INNER JOIN TaxGroupSetting TG ON A.TaxGroupId = TG.TaxGroupId
	WHERE PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih>0
	GROUP BY PrdCCode
	
	--INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId 	
	--INNER JOIN Location L (NOLOCK) ON L.LcnId=PBL.LcnId 
	--WHERE PrdStatus=1 AND PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih>0
	--GROUP BY L.LcnCode,PrdCCode
	
	SELECT  DISTINCT 
			TenantCode,
			LocationCode,
			WarehouseCode,
			ItemCode,
			Quantity
		FROM Export_CS2WS_WarehouseInventory WITH (NOLOCK) 
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_PromotionControl' and xtype='U')
DROP TABLE Export_CS2WS_PromotionControl
GO
CREATE TABLE Export_CS2WS_PromotionControl
(
	TenantCode				[nvarchar](12),
	PromotionCode			[nvarchar](50),
	PromotionDescription	[nvarchar](50),		
	PromotionRemarks		[nvarchar](500),
	PromotionTypeCode		[Tinyint],
	RangeBasis				[Tinyint],
	AmountBasis				[Tinyint],
	ExclusionOption			[Tinyint],
	PromotionIndicator		[nvarchar](3),	
	PromotionProductLevel	[Tinyint],
	PromotionQuotaCode		[nvarchar](50),		
	AllowQPS				[Tinyint],
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_PromotionAssignment' and xtype='U')
DROP TABLE Export_CS2WS_PromotionAssignment
GO
CREATE TABLE Export_CS2WS_PromotionAssignment
(
	TenantCode				[nvarchar](12),
	PromotionCode			[nvarchar](50),
	RangeLow				[Float],
	RangeHigh				[Float],
	RepeatingRange			[Tinyint],
	PromotionAmount			[Float],
	UploadFlag				[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_ProductGroup' and xtype='U')
DROP TABLE Export_CS2WS_ProductGroup
GO
CREATE TABLE Export_CS2WS_ProductGroup
(
	TenantCode				[nvarchar](12),
	PromotionCode			[nvarchar](50),
	GroupType				[nvarchar](1),
	ProductHierarchyCode	[nvarchar](12),
	ItemCode				[nvarchar](50),
	UnitsOfMeasure			[nvarchar](20),
	Quantity				[Smallint],
	UploadFlag				[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_CustomerHierarchy' and xtype='U')
DROP TABLE Export_CS2WS_CustomerHierarchy
GO
CREATE TABLE Export_CS2WS_CustomerHierarchy
(
	TenantCode				[nvarchar](12),
	LocationCode			[nvarchar](12),
	CustomerCode			[nvarchar](25),
	CategoryCode1			[nvarchar](12),
	CategoryCode2			[nvarchar](12),
	CategoryCode3			[nvarchar](12),
	CustomerHierarchyCode	[nvarchar](100),
	SequenceNumber			[Int],
	PromotionCode			[nvarchar](25),
	StartDate				[Datetime],
	EndDate					[Datetime],
	ActiveIndicator			[Tinyint],
	UploadFlag				[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_PromotionAssignment' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_PromotionAssignment
GO
--exec Proc_Export_CS2WS_PromotionAssignment '1'
CREATE PROCEDURE Proc_Export_CS2WS_PromotionAssignment
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_PromotionControl
* PURPOSE		: To Export Scheme Header details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 10/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN
	DELETE FROM Export_CS2WS_PromotionAssignment WHERE UploadFlag='Y'
	DECLARE @DistCode AS NVARCHAR(100)
	SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)
	
	INSERT INTO Export_CS2WS_PromotionAssignment(TenantCode,PromotionCode,RangeLow,
	RangeHigh,RepeatingRange,PromotionAmount,UploadFlag)
	SELECT @DistCode,CmpSchCode AS PromotionCode,	
	CASE Range WHEN 1 THEN FromQty ELSE PurQty END AS RangeLow,
		CASE Range WHEN 1 THEN ToQty ELSE PurQty END AS RangeHigh,
		--CASE Range WHEN 1 THEN 1 ELSE 0 END AS RepeatingRange,
		CASE WHEN (SS.DiscPer+SS.FlatAmt)=0 THEN 1 ELSE 0 END AS RepeatingRange,
		CASE DiscPer WHEN 0.00 THEN FlatAmt ELSE DiscPer END AS PromotionAmount,
		'N' AS UploadFlag 
		FROM SchemeMaster S 
		INNER JOIN SchemeSlabs SS ON S.SchId = SS.SchId 	
		WHERE  CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill 
		--and schstatus=1 
		AND SchType<>4 and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)
		
		update Export_CS2WS_PromotionAssignment SET RangeHigh=9999999 where RangeHigh=0 AND RangeHigh < RangeLow 
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_Export_CS2WS_ProductGroup' AND xtype='P')  
DROP PROCEDURE Proc_Export_CS2WS_ProductGroup
GO
--exec Proc_Export_CS2WS_ProductGroup '1'  
CREATE PROCEDURE Proc_Export_CS2WS_ProductGroup  
(  
 @SalRpCode varchar(50)  
)  
AS  
/*******************************************************************************************  
* PROCEDURE  : Proc_Export_CS2WS_ProductGroup  
* PURPOSE  : To Export Scheme Header details to the PDA Intermediate Database  
* CREATED  : S.Moorthi  
* CREATED DATE : 10/08/2018  
* MODIFIED  :  
* DATE      AUTHOR     DESCRIPTION  
*****************************************************************************************************  
* DATE         AUTHOR       CR/BZ    USER STORY ID   DESCRIPTION                           
*****************************************************************************************************  
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product  
  30/10/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product  
********************************************************************************************/  
BEGIN  
 DELETE FROM Export_CS2WS_ProductGroup WHERE UploadFlag='Y'  
 DECLARE @DistCode AS NVARCHAR(100)  
 SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)  
   
		--EXEC [PROC_GR_BUILD_PH]  
   
		SELECT DISTINCT A.SchId,E.Prdid INTO #SchemeProducts FROM SchemeMaster A    
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid    
		INNER JOIN ProductCategoryValue C ON     
		B.PrdCtgValMainId = C.PrdCtgValMainId     
		INNER JOIN ProductCategoryValue D ON    
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'    
		INNER JOIN Product E On    
		D.PrdCtgValMainId = E.PrdCtgValMainId     
		WHERE A.Schid In (Select Distinct Schid From SchemeMaster WHERE  SchemeLvlMode=0)  
		AND CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1   
		AND SchType<>4  and A.schid not in (select schid from SchemeSlabFrePrds)  

		INSERT INTO Export_CS2WS_ProductGroup(TenantCode,PromotionCode,GroupType,ProductHierarchyCode,  
		ItemCode,UnitsOfMeasure,Quantity,UploadFlag)  
		SELECT DISTINCT  @DistCode,CmpSchCode,GroupType,'' ProductHierarchyCode,PrdCCode,  
		UomGroupDescription,0,'N' AS UploadFlag FROM    
		(SELECt S.SchID,CmpSchCode,'Q' AS GroupType,  
		P.PrdId,P.PrdCCode,PurQty,UG.UomId,UM.UomCode AS UomGroupDescription   
		FROM SchemeMaster S(NOLOCK) INNER JOIN SchemeSlabs SS(NOLOCK) ON S.SchId = SS.SchID   
		INNER JOIN SchemeProducts SP(NOLOCK) ON S.SchID = SP.SchID AND SS.SchId = SP.SchID   
		INNER JOIN Product P(NOLOCK) ON SP.PrdId = P.PrdID  
		INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND SP.PrdId=FP.PrdId   
		INNER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId AND UG.BaseUom='Y'   
		INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId   
		INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1 AND SchType<>4   
		and NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL  
		SELECt S.SchID,CmpSchCode,'A' AS GroupType,  
		P.PrdId,P.PrdCCode,PurQty,UG.UomId,UM.UomCode AS UomGroupDescription   
		FROM SchemeMaster S (NOLOCK)INNER JOIN SchemeSlabs SS ON S.SchId = SS.SchID   
		INNER JOIN SchemeProducts SP(NOLOCK) ON S.SchID = SP.SchID AND SS.SchId = SP.SchID   
		INNER JOIN Product P (NOLOCK)ON SP.PrdId = P.PrdID  
		INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND SP.PrdId=FP.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		--UG.UomID =CASE WHEN SS.UomID=0 THEN UG.UomID ELSE SS.UomID END AND
		--UG.BASEUOM=CASE WHEN SS.UomID=0 THEN 'Y' ELSE UG.BASEUOM END 
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId   
		INNER JOIN TaxGroupSetting TG (NOLOCK)ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1   
		AND SchType<>4  and s.schid not in (select schid from SchemeSlabFrePrds)  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL  
		SELECT DISTINCT S.SchID,CmpSchCode,'Q' AS GroupType,PR.PrdId,Pr.PrdCCode,PurQty,UG.UomId,UM.UomCode AS UomGroupDescription  
		FROM SchemeMaster S(NOLOCK) INNER JOIN SchemeSlabs SS (NOLOCK)ON S.SchId = SS.SchID   
		INNER JOIN #SchemeProducts SP(NOLOCK) ON S.SchID = SP.SchID AND SS.SchId = SP.SchID   
		INNER JOIN Product Pr(NOLOCK) ON Pr.PrdId = SP.PrdID  
		INNER JOIN Fn_SFAProductToSend() FP ON Pr.PrdId=FP.PrdId AND SP.PrdId=FP.PrdId   
		INNER JOIN UOMGroup UG(NOLOCK) ON PR.UomGroupId = UG.UomGroupId and UG.BaseUom='Y'  
		INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId   
		INNER JOIN TaxGroupSetting TG ON Pr.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1 AND SchType<>4 --AND sf.Publish=1  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL  
		SELECT DISTINCT S.SchID,CmpSchCode,'A' AS GroupType,PR.PrdId,Pr.PrdCCode,PurQty,UG.UomId,UM.UomCode AS UomGroupDescription   
		FROM SchemeMaster S(NOLOCK) INNER JOIN SchemeSlabs SS(NOLOCK) ON S.SchId = SS.SchID   
		INNER JOIN #SchemeProducts SP ON S.SchID = SP.SchID AND SS.SchId = SP.SchID   
		INNER JOIN Product Pr(NOLOCK) ON Pr.PrdId = SP.PrdID  
		INNER JOIN Fn_SFAProductToSend() FP ON Pr.PrdId=FP.PrdId AND SP.PrdId=FP.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON Pr.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		--UG.UomID =CASE WHEN SS.UomID=0 THEN UG.UomID ELSE SS.UomID END AND
		--UG.BASEUOM=CASE WHEN SS.UomID=0 THEN 'Y' ELSE UG.BASEUOM END 
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId     
		INNER JOIN TaxGroupSetting TG ON Pr.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1   
		AND SchType<>4  and s.schid not in (select schid from SchemeSlabFrePrds)  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL   
		SELECT S.SchID,CmpSchCode,'A' AS GroupType,P.PrdId,P.PrdCCode,0,UG.UomId,UM.UomCode AS UomGroupDescription  
		FROM SchemeMaster S(NOLOCK)  
		INNER JOIN SchemeSlabs SS(NOLOCK) ON S.SchId = SS.SchID   
		INNER JOIN SchemeSlabFrePrds SP ON S.SchID = SP.SchID AND SS.SchId = SP.SchID AND SS.SlabId = SP.SlabId  
		INNER JOIN Product P(NOLOCK) ON SP.PrdId = P.PrdID   
		INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND SP.PrdId=fp.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		--UG.UomID =CASE WHEN SS.UomID=0 THEN UG.UomID ELSE SS.UomID END AND
		--UG.BASEUOM=CASE WHEN SS.UomID=0 THEN 'Y' ELSE UG.BASEUOM END 
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId     
		INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1 AND SchType<>4  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL  
		SELECT S.SchID,CmpSchCode,'A' AS GroupType,P.PrdId,P.PrdCCode,0,UG.UomId,UM.UomCode AS UomGroupDescription  
		FROM SchemeMaster S(NOLOCK)  
		INNER JOIN SchemeSlabs SS(NOLOCK) ON S.SchId = SS.SchID   
		INNER JOIN SchemeSlabMultiFrePrds SP ON S.SchID = SP.SchID AND SS.SchId = SP.SchID AND SS.SlabId = SP.SlabId  
		INNER JOIN Product P(NOLOCK) ON SP.PrdId = P.PrdID   
		INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND SP.PrdId=fp.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		--UG.UomID =CASE WHEN SS.UomID=0 THEN UG.UomID ELSE SS.UomID END AND
		--UG.BASEUOM=CASE WHEN SS.UomID=0 THEN 'Y' ELSE UG.BASEUOM END 
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId     
		INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1 AND SchType<>4  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		) A  
 
		UPDATE A SET A.UnitsOfMeasure=UM.UOMCODE from Export_CS2WS_ProductGroup A (nolock) 
		INNER JOIN Product P (NOLOCK) ON P.PrdCCode=A.ItemCode 
		INNER JOIN UomGroup UG ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
		INNER JOIN UomMaster UM ON UM.UomId=UG.UomId 
		WHERE UnitsOfMeasure IS NULL
 
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_CustomerHierarchy' AND xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_CustomerHierarchy
GO
--exec Proc_Export_CS2WS_CustomerHierarchy '1'
CREATE PROCEDURE [dbo].[Proc_Export_CS2WS_CustomerHierarchy]
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_PromotionControl
* PURPOSE		: To Export Scheme Header details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 10/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN
	DELETE FROM Export_CS2WS_CustomerHierarchy WHERE UploadFlag='Y'
	
	CREATE TABLE #Export_CS2WS_CustomerHierarchy
	(
		TenantCode				[nvarchar](12),
		LocationCode			[nvarchar](12),
		CustomerCode			[nvarchar](25),
		CategoryCode1			[nvarchar](12),
		CategoryCode2			[nvarchar](12),
		CategoryCode3			[nvarchar](12),
		CustomerHierarchyCode	[nvarchar](100),
		SequenceNumber			[Int],
		PromotionCode			[nvarchar](25),
		StartDate				[Datetime],
		EndDate					[Datetime],
		ActiveIndicator			[Tinyint],
		UploadFlag				[VARCHAR](1)
	)


	DECLARE @DistCode AS NVARCHAR(100)
	SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)	
	
	INSERT INTO #Export_CS2WS_CustomerHierarchy(TenantCode,LocationCode,CustomerCode,CategoryCode1,
	CategoryCode2,CategoryCode3,CustomerHierarchyCode,SequenceNumber,PromotionCode,StartDate,EndDate,
	ActiveIndicator,UploadFlag)
	SELECT DISTINCT  @DistCode,@DistCode,R.CmpRtrCode,'' AS ChannelCode,
	'' AS GroupCode,'','','',SM.CmpSchCode,CONVERT(VARCHAR(10),SM.SchValidFrom,121),CONVERT(VARCHAR(10),SM.SchValidTill,121),
	ISNULL(SM.[SchStatus],1),'N'
	FROM SchemeMaster SM  (NOLOCK) 
	INNER JOIN  SchemeRetAttr SR1(NOLOCK) ON SR1.SchId = SM.SchId    
	INNER JOIN  RetailerCategory RC(NOLOCK) ON RC.CtgMainId= case SR1.AttrId  when 0 then  RC.CtgMainId else SR1.AttrId end AND SR1.AttrType=5    
	INNER JOIN SchemeRetAttr SR2(NOLOCK) ON SR2.SchId = SM.SchId  
	INNER JOIN RetailerCategory RC1(NOLOCK) ON RC1.CtgLinkCode Like RC.CtgLinkCode+'%'
	INNER JOIN  RetailerValueClass RVC(NOLOCK) ON RVC.CtgMainId=RC1.CtgMainId    
	AND RVC.RtrClassId =case SR2.AttrId when 0 then RVC.RtrClassId else SR2.AttrId end AND SR2.AttrType=6     
	INNER JOIN SchemeRetAttr SR3(NOLOCK) ON SR3.SchId = SM.SchId    
	INNER JOIN RetailerValueClassMap RVCM (NOLOCK) ON RVCM.RtrValueClassId=RVC.RtrClassId 
	AND RVCM.RtrId =SR3.AttrId AND SR3.AttrType=8    
	INNER JOIN Retailer R (NOLOCK) ON R.RtrId=RVCM.RtrId    
	WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchType<>4 and R.RtrStatus=1
	and NOT EXISTS(SELECT  DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
	WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=SM.CmpSchCode)
	UNION ALL
	SELECT DISTINCT  @DistCode,@DistCode,@DistCode,'' AS ChannelCode,
	'' AS GroupCode,'' ValueClassCode,'','',SM.CmpSchCode,CONVERT(VARCHAR(10),SM.SchValidFrom,121),CONVERT(VARCHAR(10),SM.SchValidTill,121),
	ISNULL(SM.[SchStatus],1),'N'
	FROM SchemeMaster SM  (NOLOCK) 
	INNER JOIN SchemeRetAttr SR4(NOLOCK) ON SR4.SchId = SM.SchId AND SR4.AttrType=4
	INNER JOIN  SchemeRetAttr SR1(NOLOCK) ON SR1.SchId = SM.SchId  aND SR1.AttrId=0 AND SR1.AttrType=5
	INNER JOIN SchemeRetAttr SR2(NOLOCK) ON SR2.SchId = SM.SchId  aND SR2.AttrId=0 	AND SR2.AttrType=6  
	INNER JOIN SchemeRetAttr SR3(NOLOCK) ON SR3.SchId = SM.SchId   aND SR3.AttrId=0 AND SR3.AttrType=8   
	WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchType<>4
	and NOT EXISTS(SELECT  DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
	WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=SM.CmpSchCode)

	
	
	INSERT INTO #Export_CS2WS_CustomerHierarchy(TenantCode,LocationCode,CustomerCode,CategoryCode1,
	CategoryCode2,CategoryCode3,CustomerHierarchyCode,SequenceNumber,PromotionCode,StartDate,EndDate,
	ActiveIndicator,UploadFlag)	
	SELECT DISTINCT  @DistCode,@DistCode,'','' AS ChannelCode,
	RC1.CtgCode AS GroupCode,RVC.ValueClassCode,'','',SM.CmpSchCode,CONVERT(VARCHAR(10),SM.SchValidFrom,121),CONVERT(VARCHAR(10),SM.SchValidTill,121),
	ISNULL(SM.[SchStatus],1),'N'
	FROM SchemeMaster SM  (NOLOCK) 
	INNER JOIN  SchemeRetAttr SR1(NOLOCK) ON SR1.SchId = SM.SchId    
	INNER JOIN  RetailerCategory RC(NOLOCK) ON RC.CtgMainId= case SR1.AttrId  when 0 then  RC.CtgMainId else SR1.AttrId end AND SR1.AttrType=5    
	INNER JOIN SchemeRetAttr SR2(NOLOCK) ON SR2.SchId = SM.SchId  
	INNER JOIN RetailerCategory RC1(NOLOCK) ON RC1.CtgLinkCode Like RC.CtgLinkCode+'%'
	INNER JOIN  RetailerValueClass RVC(NOLOCK) ON RVC.CtgMainId=RC1.CtgMainId    
	AND RVC.RtrClassId =SR2.AttrId AND SR2.AttrType=6  
	INNER JOIN SchemeRetAttr SR3(NOLOCK) ON SR3.SchId = SM.SchId   aND SR3.AttrId=0   AND SR3.AttrType=8   
	WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchType<>4
	AND NOT EXISTS(SELECT CmpSchCode FROM #Export_CS2WS_CustomerHierarchy M WHERE M.PromotionCode=SM.CmpSchCode)
	and NOT EXISTS(SELECT  DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
	WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=SM.CmpSchCode)

	
	INSERT INTO #Export_CS2WS_CustomerHierarchy(TenantCode,LocationCode,CustomerCode,CategoryCode1,
	CategoryCode2,CategoryCode3,CustomerHierarchyCode,SequenceNumber,PromotionCode,StartDate,EndDate,
	ActiveIndicator,UploadFlag)
	SELECT DISTINCT  @DistCode,@DistCode,'',CASE WHEN SR4.AttrId=1 THEN RC.CtgCode ELSE '' END AS ChannelCode,
	CASE WHEN SR4.AttrId=1 THEN '' ELSE RC1.CtgCode END AS GroupCode,'' ValueClassCode,'','',SM.CmpSchCode,CONVERT(VARCHAR(10),SM.SchValidFrom,121),CONVERT(VARCHAR(10),SM.SchValidTill,121),
	ISNULL(SM.[SchStatus],1),'N'
	FROM SchemeMaster SM  (NOLOCK) 
	INNER JOIN SchemeRetAttr SR4(NOLOCK) ON SR4.SchId = SM.SchId AND SR4.AttrType=4
	INNER JOIN  SchemeRetAttr SR1(NOLOCK) ON SR1.SchId = SM.SchId    
	INNER JOIN  RetailerCategory RC(NOLOCK) ON RC.CtgMainId= case SR1.AttrId  when 0 then  RC.CtgMainId else SR1.AttrId end AND SR1.AttrType=5    
	INNER JOIN RetailerCategory RC1(NOLOCK) ON RC1.CtgLinkCode Like RC.CtgLinkCode+'%'
	INNER JOIN SchemeRetAttr SR2(NOLOCK) ON SR2.SchId = SM.SchId  aND SR2.AttrId=0 	 AND SR2.AttrType=6  
	INNER JOIN SchemeRetAttr SR3(NOLOCK) ON SR3.SchId = SM.SchId   aND SR3.AttrId=0   AND SR3.AttrType=8   
	WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchType<>4
	AND NOT EXISTS(SELECT CmpSchCode FROM #Export_CS2WS_CustomerHierarchy M WHERE M.PromotionCode=SM.CmpSchCode)
	and NOT EXISTS(SELECT  DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
	WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=SM.CmpSchCode)
	
	INSERT INTO Export_CS2WS_CustomerHierarchy(TenantCode,LocationCode,CustomerCode,CategoryCode1,
	CategoryCode2,CategoryCode3,CustomerHierarchyCode,SequenceNumber,PromotionCode,StartDate,EndDate,
	ActiveIndicator,UploadFlag)
	SELECT TenantCode,LocationCode,CustomerCode,CategoryCode1,
	CategoryCode2,CategoryCode3,CustomerHierarchyCode,SequenceNumber,PromotionCode,StartDate,EndDate,
	ActiveIndicator,UploadFlag FROM #Export_CS2WS_CustomerHierarchy
	
	
	--CREATE TABLE #TempSchemeRet
	--(
	--	CmpSchCode		VARCHAR(100)COLLATE DATABASE_DEFAULT,
	--	RtrId			BIGINT,
	--	RtrValueClassId	BIGINT,
	--	FromDate		DATETIME,
	--	ToDate			DATETIME,
	--	[Status]		TINYINT		
	--)
	
	--INSERT INTO #TempSchemeRet(CmpSchCode,RtrId,RtrValueClassId,FromDate,ToDate,[Status])
	--SELECT DISTINCT A.CmpSchCode,R.RtrId,RVCM.RtrValueClassId,B.FromDate,B.ToDate,ISNULL(B.[Status],1) 
	--FROM SchemeMaster A (NOLOCK)
	--INNER JOIN SchemeRtrLevelValidation B (NOLOCK) ON A.SCHID=B.SCHID
	--inner JOIN Retailer R (NOLOCK) ON R.RtrId=B.RtrId 
	--INNER JOIN RetailerValueclassMap RVCM (NOLOCK) ON RVCM.RtrId=B.RtrId AND R.RtrId=RVCM.RtrId 
	--WHERE CONVERT (VARCHAR(10),GETDATE(),121) between schvalidfrom and schvalidtill and schstatus=1 AND SchType<>4
	--and R.RtrStatus=1
	--and NOT EXISTS(SELECT  DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
	--	WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=A.CmpSchCode)
	
	--INSERT INTO #TempSchemeRet(CmpSchCode,RtrId,RtrValueClassId,FromDate,ToDate,[Status])
	--SELECT DISTINCT  SM.CmpSchCode,R.RtrId,RVCM.RtrValueClassId,SM.SchValidFrom,
	--SM.SchValidTill,1 as ActiveIndicator
	--FROM SchemeMaster SM  (NOLOCK) 
	--INNER JOIN  SchemeRetAttr SR1(NOLOCK) ON SR1.SchId = SM.SchId    
	--INNER JOIN  RetailerCategory RC(NOLOCK) ON RC.CtgMainId= case SR1.AttrId  when 0 then  RC.CtgMainId else SR1.AttrId end AND SR1.AttrType=5    
	--INNER JOIN SchemeRetAttr SR2(NOLOCK) ON SR2.SchId = SM.SchId  
	--INNER JOIN RetailerCategory RC1(NOLOCK) ON RC1.CtgLinkCode Like RC.CtgLinkCode+'%'
	--INNER JOIN  RetailerValueClass RVC(NOLOCK) ON RVC.CtgMainId=RC1.CtgMainId    
	--AND RVC.RtrClassId =case SR2.AttrId when 0 then RVC.RtrClassId else SR2.AttrId end AND SR2.AttrType=6     
	--INNER JOIN SchemeRetAttr SR3(NOLOCK) ON SR3.SchId = SM.SchId    
	--INNER JOIN RetailerValueClassMap RVCM (NOLOCK) ON RVCM.RtrValueClassId=RVC.RtrClassId 
	--AND RVCM.RtrId =case SR3.AttrId when 0 then RVCM.RtrId else SR3.AttrId end AND SR3.AttrType=8   
	--INNER JOIN Retailer R (NOLOCK) ON R.RtrId=RVCM.RtrId    
	--WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill and schstatus=1 AND SchType<>4
	--and R.RtrStatus=1
	--AND NOT EXISTS(SELECT CmpSchCode FROM #TempSchemeRet M WHERE M.CmpSchCode=SM.CmpSchCode)
	--and NOT EXISTS(SELECT  DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
	--	WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=SM.CmpSchCode)
	
	
	--INSERT INTO Export_CS2WS_CustomerHierarchy(TenantCode,LocationCode,CustomerCode,CategoryCode1,CategoryCode2,CategoryCode3,
	--CustomerHierarchyCode,SequenceNumber,PromotionCode,StartDate,EndDate,ActiveIndicator,UploadFlag)
	--SELECT @DistCode,@DistCode,R.CmpRtrCode,RC1.CtgCode AS ChannelCode,
	--RC.CtgCode AS GroupCode,ValueClassCode,'','',A.CmpSchCode,CONVERT(VARCHAR(10),A.FromDate,121),CONVERT(VARCHAR(10),A.ToDate,121),
	--ISNULL(A.[Status],1),'N' FROM #TempSchemeRet A
	--inner JOIN Retailer R (NOLOCK) ON R.RtrId=A.RtrId 
	--INNER JOIN RetailerValueclassMap RVCM (NOLOCK) ON RVCM.RtrId=A.RtrId AND A.RtrValueClassId=RVCM.RtrValueClassId 
	--INNER JOIN RetailerValueClass RVC(NOLOCK) ON RVC.RtrClassId=RVCM.RtrValueClassId AND A.RtrValueClassId=RVC.RtrClassId
	--INNER JOIN RetailerCategory RC (NOLOCK)ON RC.CtgMainId=RVC.CtgMainId
	--INNER JOIN RetailerCategory RC1 (NOLOCK) ON RC1.CtgMainId=RC.CtgLinkId
	--WHERE R.RtrStatus=1
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_PromotionControl' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_PromotionControl
GO
--DELETE FROM WSMasterExportUploadTrack
--exec Proc_Export_CS2WS_PromotionControl '1'
--SELECT * FROM Export_CS2WS_ProductGroup WHERE PROMOTIONCODE='SCH13689'
CREATE PROCEDURE Proc_Export_CS2WS_PromotionControl
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_PromotionControl
* PURPOSE		: To Export Scheme Header details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 10/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
  16/10/2018   S.Moorthi    SR         ILCRSTPAR2366   currently if new retailer created for that schemes not applied in PDA.
********************************************************************************************/
BEGIN

		DELETE FROM Export_CS2WS_PromotionControl WHERE UploadFlag='Y'
		
		DECLARE @DistCode AS NVARCHAR(100)
		SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)
				
		CREATE TABLE #ToRePush
		(
			CmpSchCode	VARCHAR(100)COLLATE DATABASE_DEFAULT
		)
		
		--CREATE TABLE #TempSchemeRet1
		--(
		--	CmpSchCode		VARCHAR(100)COLLATE DATABASE_DEFAULT,
		--	[CmpRtrCode]	VARCHAR(100)COLLATE DATABASE_DEFAULT,
		--	RtrId			BIGINT
		--)
		
		INSERT INTO #ToRePush(CmpSchCode)
		SELECT DISTINCT MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
		WHERE NOT EXISTS(SELECT * FROM SchemeMaster B (NOLOCK) WHERE WS.MasterCode=B.CmpSchCode AND WS.Ref4Value=B.Budget and B.SCHSTATUS=WS.[STATUS])
		AND WS.ProcessName='Promotion Definition' 
	
		--INSERT INTO #TempSchemeRet1(CmpSchCode,CmpRtrCode,RtrId)
		--SELECT DISTINCT A.CmpSchCode,R.CmpRtrCode,R.RtrId 
		--FROM SchemeMaster A (NOLOCK)
		--INNER JOIN SchemeRtrLevelValidation B (NOLOCK) ON A.SCHID=B.SCHID
		--inner JOIN Retailer R (NOLOCK) ON R.RtrId=B.RtrId 
		--INNER JOIN RetailerValueclassMap RVCM (NOLOCK) ON RVCM.RtrId=B.RtrId AND R.RtrId=RVCM.RtrId 
		--WHERE CONVERT (VARCHAR(10),GETDATE(),121) between schvalidfrom and schvalidtill and schstatus=1 AND SchType<>4
		--and R.RtrStatus=1 AND EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
		--	WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=A.CmpSchCode)
		
		--INSERT INTO #TempSchemeRet1(CmpSchCode,CmpRtrCode,RtrId)
		--SELECT DISTINCT  SM.CmpSchCode,R.CmpRtrCode,R.RtrId 
		--FROM SchemeMaster SM  (NOLOCK) 
		--INNER JOIN  SchemeRetAttr SR1(NOLOCK) ON SR1.SchId = SM.SchId    
		--INNER JOIN  RetailerCategory RC(NOLOCK) ON RC.CtgMainId= case SR1.AttrId  when 0 then  RC.CtgMainId else SR1.AttrId end AND SR1.AttrType=5    
		--INNER JOIN SchemeRetAttr SR2(NOLOCK) ON SR2.SchId = SM.SchId  
		--INNER JOIN RetailerCategory RC1(NOLOCK) ON RC1.CtgLinkCode Like RC.CtgLinkCode+'%'
		--INNER JOIN  RetailerValueClass RVC(NOLOCK) ON RVC.CtgMainId=RC1.CtgMainId    
		--AND RVC.RtrClassId =case SR2.AttrId when 0 then RVC.RtrClassId else SR2.AttrId end AND SR2.AttrType=6     
		--INNER JOIN SchemeRetAttr SR3(NOLOCK) ON SR3.SchId = SM.SchId    
		--INNER JOIN RetailerValueClassMap RVCM (NOLOCK) ON RVCM.RtrValueClassId=RVC.RtrClassId 
		--AND RVCM.RtrId =case SR3.AttrId when 0 then RVCM.RtrId else SR3.AttrId end AND SR3.AttrType=8   
		--INNER JOIN Retailer R (NOLOCK) ON R.RtrId=RVCM.RtrId    
		--WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill and schstatus=1 AND SchType<>4
		--and R.RtrStatus=1 AND NOT EXISTS(SELECT CmpSchCode FROM #TempSchemeRet1 M WHERE M.CmpSchCode=SM.CmpSchCode)
		--AND EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
		--	WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=SM.CmpSchCode)
		
		--INSERT INTO #ToRePush(CmpSchCode)
		--SELECT B.CmpSchCode FROM #TempSchemeRet1 B(NOLOCK) 
		--WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack WS (NOLOCK) WHERE 
		--WS.MasterCode=B.CmpSchCode AND WS.Reference1=B.CmpRtrCode AND WS.ProcessName='Promotion Customer')			
		

		DELETE WS FROM WSMasterExportUploadTrack WS(NOLOCK) 
		INNER JOIN #ToRePush B ON B.CmpSchCode=WS.MasterCode 
		WHERE WS.ProcessName='Promotion Definition'
		
		--DELETE WS FROM WSMasterExportUploadTrack WS(NOLOCK) 
		--INNER JOIN #ToRePush B ON B.CmpSchCode=WS.MasterCode 
		--WHERE WS.ProcessName='Promotion Customer' 	
	
		INSERT INTO Export_CS2WS_PromotionControl(TenantCode,PromotionCode,PromotionDescription,PromotionRemarks,
		PromotionTypeCode,RangeBasis,AmountBasis,ExclusionOption,PromotionIndicator,
		PromotionProductLevel,PromotionQuotaCode,AllowQPS,UploadFlag)
		SELECT DISTINCT @DistCode,CmpSchCode AS PromotionCode,SchDsc AS PromotionDescription,'' PromotionRemarks,
		CASE SchType 
			WHEN 4 THEN 5 
			WHEN 1 THEN CASE QPS WHEN 1 THEN (CASE DiscPer WHEN 0.00 THEN 5 ELSE 6 END)
						WHEN 0 THEN (CASE DiscPer WHEN 0.00 THEN 1 ELSE 2 END) END 
			WHEN 2 THEN CASE QPS WHEN 1 THEN (CASE DiscPer WHEN 0.00 THEN 5 ELSE 6 END)							
						WHEN 0 THEN (CASE DiscPer WHEN 0.00 THEN 1 ELSE 2 END) END 
			ELSE 4 END AS PromotionTypeCode,
			CASE SchType WHEN 1 THEN 1 ELSE 2 END AS RangeBasis,
			1 AS AmountBasis,0 As ExclusionOption,		
			'P' AS PromotionIndicator,0 PromotionProductLevel,'' PromotionQuotaCode,
			QPS AllowQPS,'N' AS UploadFlag 
			FROM SchemeMaster S 
				INNER JOIN SchemeSlabs SS ON S.SchId = SS.SchId 
			WHERE  CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill 
			--and schstatus=1 
			AND SchType<>4 and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK) 
			WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)

		EXEC Proc_Export_CS2WS_PromotionAssignment @SalRpCode
		EXEC Proc_Export_CS2WS_ProductGroup @SalRpCode
		EXEC Proc_Export_CS2WS_CustomerHierarchy @SalRpCode
		
		--INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
		--SELECT 'Promotion Customer',PromotionCode,B.SchDsc,GETDATE(),SchStatus,A.CustomerCode,'','',B.Budget FROM Export_CS2WS_CustomerHierarchy A (NOLOCK)
		--INNER JOIN SchemeMaster B (NOLOCK) ON  B.CmpSchCode=A.PromotionCode 
		--WHERE UploadFlag='N'
		
		INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
		SELECT 'Promotion Definition',PromotionCode,B.SchDsc,GETDATE(),SchStatus,'','','',B.Budget FROM Export_CS2WS_PromotionControl A (NOLOCK)
		INNER JOIN SchemeMaster B (NOLOCK) ON  B.CmpSchCode=A.PromotionCode 
		WHERE UploadFlag='N' 
	
		SELECT DISTINCT 
			TenantCode,
			PromotionCode,
			PromotionDescription,
			PromotionRemarks,
			PromotionTypeCode,
			RangeBasis,
			AmountBasis,
			ExclusionOption,
			PromotionIndicator,
			PromotionProductLevel,
			PromotionQuotaCode,
			AllowQPS
		FROM Export_CS2WS_PromotionControl WITH (NOLOCK) 
		
		SELECT DISTINCT 
			TenantCode,
			PromotionCode,
			RangeLow,
			RangeHigh,
			RepeatingRange,
			PromotionAmount
		FROM Export_CS2WS_PromotionAssignment WITH (NOLOCK) 
		
		SELECT DISTINCT 
			TenantCode,
			PromotionCode,
			GroupType,
			ProductHierarchyCode,
			ItemCode,
			UnitsOfMeasure,
			Quantity
		FROM Export_CS2WS_ProductGroup WITH (NOLOCK) 
		
		SELECT DISTINCT 
			TenantCode,
			LocationCode,
			CustomerCode,
			CategoryCode1,
			CategoryCode2,
			CategoryCode3,
			CustomerHierarchyCode,
			SequenceNumber,
			PromotionCode,
			CONVERT(VARCHAR(10),StartDate,121) AS StartDate,
			CONVERT(VARCHAR(10),EndDate,121) AS EndDate,
			ActiveIndicator
		FROM Export_CS2WS_CustomerHierarchy WITH (NOLOCK) 
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_CreditDetails' and xtype='U')
DROP TABLE Export_CS2WS_CreditDetails
GO
CREATE TABLE Export_CS2WS_CreditDetails
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	DivisionCode		[nvarchar](12),
	CustomerCode		[nvarchar](25),
	CreditLimit			[Float],
	CustomerBalanceDue	[Float],
	TotalNumberofInvoices	[SmallInt],
	TotalDaysofInvoices	[SmallInt],
	Blocked				[SmallInt],
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE NAME='TempCrRetailer' and xtype='U')
BEGIN
	DROP TABLE TempCrRetailer
END
GO
CREATE TABLE [dbo].[TempCrRetailer](
	[DistributorCode] [nvarchar](20) NOT NULL,
	[RtrID] [BIGint] NOT NULL,
	[RtrCode] [nvarchar](50) NULL,
	[RtrCrBills] [int] NULL,
	[RtrOutstndAmt] [numeric](18, 3) NULL,
	[RtrCrLimit] [numeric](18, 3) NULL,
	[RtrCrDays] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_CreditDetails' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_CreditDetails
GO
CREATE PROCEDURE Proc_Export_CS2WS_CreditDetails
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_CreditDetails
* PURPOSE		: To Export Authorized Product details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 07/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN

	DECLARE @Smid AS int 
	DECLARE @Sql AS varchar(1000)
	
	DELETE FROM Export_CS2WS_CreditDetails WHERE UploadFlag='Y'
	
	IF EXISTS (SELECT * FROM sysobjects WHERE NAME='TempCrRetailer' and xtype='U')
	BEGIN
		DROP TABLE TempCrRetailer
	END
	SET @Sql=' SELECT DistributorCode,R.RtrID,CmpRtrCode as RtrCode,RtrCrBills,0 As RtrOutstndAmt,RtrCrLimit,RtrCrDays INTO TempCrRetailer
	FROM Retailer R 
	INNER JOIN RetailerMarket RM ON RM.RtrId = R.RtrId
	INNER JOIN SalesmanMarket SM ON SM.RMId=RM.RMId
	INNER JOIN RetailerValueClassMap RVM ON R.RtrID = RVM.RtrID 
	INNER JOIN RetailerValueClass RV ON RVM.RtrValueClassId = RV.RtrClassId
	CROSS JOIN	Distributor
	WHERE sm.SMId in ('+ CAST(@SalRpCode AS VARCHAR(100)) +')'
		
	EXEC (@Sql)
	
	SELECT RtrID,SUM(SalNetAmt-SalPayAmt) AS SalNetAmt INTO #TempSalInvAmt FROM SalesInvoice GROUP BY RtrID ORDER BY RtrID
	
	UPDATE TempCrRetailer SET RtrOutstndAmt = SalNetAmt FROM TempCrRetailer A,#TempSalInvAmt B
	WHERE A.RtrID = B.RtrID
	

	
	INSERT INTO Export_CS2WS_CreditDetails(TenantCode,LocationCode,DivisionCode,CustomerCode,CreditLimit,
	CustomerBalanceDue,TotalNumberofInvoices,TotalDaysofInvoices,Blocked,UploadFlag)
	SELECT DistributorCode,DistributorCode AS LocationCode,'DD' AS DivisionCode,RtrCode AS CustomerCode,RtrCrLimit AS CreditLimit,
	RtrOutstndAmt AS CustomerBalanceDue,999 AS TotalNumberofInvoices,999 AS TotalDaysofInvoices,0 AS Blocked,
	'N' AS UploadFlag FROM TempCrRetailer S 
	WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = S.RtrCode AND ISNULL(M.MasterName,'')=S.DistributorCode 
	AND ISNULL(M.Ref4Value,0)= S.RtrOutstndAmt AND M.ProcessName='Credit Details') 
	
	DELETE B FROM WSMasterExportUploadTrack B WHERE EXISTS(SELECT * FROM Export_CS2WS_CreditDetails M 
	WHERE B.MasterCode=M.CustomerCode AND ISNULL(B.MasterName,'')=M.LocationCode 
	AND ISNULL(B.Ref4Value,0)<> M.CustomerBalanceDue and M.UploadFlag='N')
	AND B.ProcessName='Credit Details' 
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'Credit Details',CustomerCode,LocationCode,GETDATE(),0,'','','',CustomerBalanceDue FROM Export_CS2WS_CreditDetails WHERE UploadFlag='N' 
	
	SELECT DISTINCT 
		TenantCode,
		LocationCode,
		DivisionCode,
		CustomerCode,
		CreditLimit,
		CustomerBalanceDue,
		TotalNumberofInvoices,
		TotalDaysofInvoices,
		Blocked
	FROM Export_CS2WS_CreditDetails WITH (NOLOCK) 
	
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_RouteSetupV1' and xtype='U')
DROP TABLE Export_CS2WS_RouteSetupV1
GO
CREATE TABLE Export_CS2WS_RouteSetupV1
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	RouteCode			[nvarchar](12),
	RouteName			[nvarchar](50),
	VehicleCode			[nvarchar](12),
	HHTDeviceSerialNumber [nvarchar](100),
	SalesmanCode		[nvarchar](12),
	IsActive			[Tinyint],
	WarehouseCode		[nvarchar](12),
	JourneyPlanCode		[nvarchar](12),
	AuthorizedItemCode	[nvarchar](12),
	RouteType			[Tinyint],
	DefaultCashCustomer	[nvarchar](12),
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_RouteDivisionsList' and xtype='U')
DROP TABLE Export_CS2WS_RouteDivisionsList
GO
CREATE TABLE Export_CS2WS_RouteDivisionsList
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	RouteCode			[nvarchar](12),	
	Divisioncode		[nvarchar](12),
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_RouteDivisionsList' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_RouteDivisionsList
GO
--exec [Proc_Export_CS2WS_RouteDivisionsList] '1'
--select * from WSMasterExportUploadTrack
CREATE PROCEDURE Proc_Export_CS2WS_RouteDivisionsList
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_RouteDivisionsList
* PURPOSE		: To Export RouteDivisionsList details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 16/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN

	SELECT pListId Slno,pListValue Smid INTO #SMLIST1 from DBo.fn_getList(@SalRpCode)

	DECLARE @DistCode AS varchar(200)
	DELETE FROM Export_CS2WS_RouteDivisionsList WHERE UploadFlag='Y'
	SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)
	
	INSERT INTO Export_CS2WS_RouteDivisionsList(TenantCode,LocationCode,RouteCode,Divisioncode,UploadFlag)
	SELECT @DistCode,@DistCode,SMCode,'DD','N' FROM SalesMan A (NOLOCK)
	INNER JOIN #SMLIST1 B ON A.SMId=B.Smid
	WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.SMCode AND A.Status=M.Status AND Reference1=A.HHTDeviceSerialNumber 
	AND M.ProcessName='RouteDivisionsList') 

END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_RouteSetupV1' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_RouteSetupV1
GO
--exec [Proc_Export_CS2WS_RouteSetupV1] '1'
CREATE PROCEDURE Proc_Export_CS2WS_RouteSetupV1
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_RouteSetupV1
* PURPOSE		: To Export RouteSetupV1 details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 16/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN

	SELECT pListId Slno,pListValue Smid INTO #SMLIST1 from DBo.fn_getList(@SalRpCode)

	DECLARE @DistCode AS varchar(200)
	DELETE FROM Export_CS2WS_RouteSetupV1 WHERE UploadFlag='Y'
	SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)
	
	INSERT INTO Export_CS2WS_RouteSetupV1(TenantCode,LocationCode,RouteCode,RouteName,
	VehicleCode,HHTDeviceSerialNumber,SalesmanCode,IsActive,WarehouseCode,JourneyPlanCode,
	AuthorizedItemCode,RouteType,DefaultCashCustomer,UploadFlag)
	SELECT @DistCode,@DistCode,SMCode,SMName,SMCode VehicleCode,
	HHTDeviceSerialNumber HHTDeviceSerialNumber,SMCode,A.[Status],'MG',SMCode,@DistCode,4,'Dummy','N' 
	FROM SalesMan A (NOLOCK)
	INNER JOIN #SMLIST1 B ON A.SMId=B.Smid  
	WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.SMCode AND Reference1=A.HHTDeviceSerialNumber
	AND A.Status=M.Status AND M.ProcessName='RouteDivisionsList') 
	--INNER JOIN SalesmanMarket B (NOLOCK) ON A.SMId=B.SMId 
	--INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=B.RMId
	
	DELETE A FROM WSMasterExportUploadTrack A WHERE EXISTS(SELECT * FROM Export_CS2WS_RouteSetupV1 M 
	WHERE A.MasterCode = M.SalesmanCode and M.UploadFlag='N') AND A.ProcessName='RouteDivisionsList'

	EXEC Proc_Export_CS2WS_RouteDivisionsList @SalRpCode
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'RouteDivisionsList',RouteCode,LocationCode,GETDATE(),A.IsActive,HHTDeviceSerialNumber,'','',0 FROM Export_CS2WS_RouteSetupV1 A 
	WHERE UploadFlag='N'  
	
	UPDATE Export_CS2WS_RouteSetupV1 SET HHTDeviceSerialNumber='12345' WHERE ISNULL(HHTDeviceSerialNumber,'')=''
	
	SELECT DISTINCT TenantCode,
		LocationCode,
		RouteCode,
		RouteName,
		VehicleCode,
		HHTDeviceSerialNumber,
		SalesmanCode,
		IsActive,
		WarehouseCode,
		JourneyPlanCode,
		AuthorizedItemCode,
		RouteType,
		DefaultCashCustomer
		FROM Export_CS2WS_RouteSetupV1 (NOLOCK)
		
	SELECT DISTINCT TenantCode,
		LocationCode,
		RouteCode,
		Divisioncode
		FROM Export_CS2WS_RouteDivisionsList (NOLOCK)

END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_JourneyPlan' and xtype='U')
DROP TABLE Export_CS2WS_JourneyPlan
GO
CREATE TABLE Export_CS2WS_JourneyPlan
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	JourneyPlanCode		[nvarchar](12),
	JourneyPlanDescription		[nvarchar](50),
	CustomerCode		[nvarchar](25),
	SequenceWeek		[tinyint],
	SequenceDay			[tinyint],
	SequenceNumber		[smallint],
	BeatCode			[Nvarchar](12),
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='TempJourneyCycle' and xtype='U')
DROP TABLE TempJourneyCycle
GO
CREATE TABLE TempJourneyCycle
(
	DistributorCode NVARCHAR(20),
	SMCode NVARCHAR(50),
	[SMNAME] [nvarchar](50) NULL,	
	RMID	INT,
	RMCode NVARCHAR(50),
	RtrId	INT,
	RtrCode NVARCHAR(50),
	SeqWk	INT,
	SeqDay	INT,
	SeqNo	INT
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='TempRetailerHdr' and xtype='U')
DROP TABLE TempRetailerHdr
GO
CREATE TABLE TempRetailerHdr(
	[DistributorCode] [nvarchar](20) NOT NULL,
	[SMCode] [nvarchar](20) NOT NULL,
	[RMID] [int] NOT NULL,
	[RMCode] [varchar](20) NOT NULL,
	[RtrId] [int] NOT NULL,
	[RtrCode] [nvarchar](25) NULL,
	[SeqWk] [int] NOT NULL,
	[SeqDay] [int] NOT NULL,
	[SeqNo] [int] NOT NULL
) ON [PRIMARY]
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_JourneyPlan' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_JourneyPlan
GO
--exec [Proc_Export_CS2WS_JourneyPlan] '1'
CREATE PROCEDURE Proc_Export_CS2WS_JourneyPlan
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_JourneyPlan
* PURPOSE		: To Export Journy Plan details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 16/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN

	DECLARE @DelSQL AS VARCHAR(1000)
	DECLARE @InsSQL AS VARCHAR(5000)
	DECLARE @@JcwWk AS INT
	DECLARE @RMId AS INT
	DECLARE @RMMon AS INT
	DECLARE @RtrID AS INT
	DECLARE @Smid AS int 
	DECLARE @Sql AS varchar(3000)
	DELETE FROM Export_CS2WS_JourneyPlan 
	 
	TRUNCATE TABLE TempJourneyCycle
	
	IF EXISTS (SELECT * FROM sysobjects WHERE NAME='TempRetailerHdr' and xtype='U')
	BEGIN
		DROP TABLE TempRetailerHdr
	END
	
	---Company rtr code
	SET @Sql= 'SELECT DistributorCode,SMCode,RM.RMID,RMCode,R.RtrId,CmpRtrCode as RtrCode,0 AS SeqWk,0 AS SeqDay,0 SeqNo INTO TempRetailerHdr
	FROM Retailer R
	INNER JOIN RetailerMarket RM ON R.RtrId = RM.RtrId
	INNER JOIN RouteMaster ROT ON ROT.RMId = RM.RMId
	INNER JOIN Geography G ON R.GeoMainId = G.GeoMainId
	INNER JOIN SalesmanMarket SM ON RM.RMId = SM.RMId
	INNER JOIN Salesman S ON S.SMId = SM.SMId
	CROSS JOIN Distributor
	WHERE S.Status = 1 AND RMstatus = 1 AND RtrStatus = 1 AND S.SMId IN ('+ CAST(@SalRpCode AS VARCHAR(100)) +')'
	EXEC (@Sql)	
	
	--For Monday
	DECLARE Cur_RMId Cursor For
	SELECT distinct A.RMId,RMMon,RtrID FROM RouteMaster A,TempRetailerHdr B
	WHERE RMMon= 1 AND A.RMID = B.RmID ORDER BY A.RMId
	OPEN Cur_RMId	
	FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	WHILE @@FETCH_STATUS =0
	BEGIN
			DECLARE Cur_RMIdWK Cursor For
			SELECT JcwWk FROM (
			SELECT DISTINCT JcwWk FROM JCWeek WHERE JcwWk <=4
			UNION ALL 
			SELECT 5)A
			OPEN Cur_RMIdWK	
			FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			WHILE @@FETCH_STATUS =0
			BEGIN
				INSERT INTO TempJourneyCycle(DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,SeqWk,SeqDay,SeqNo)
				SELECT DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,@@JcwWk,1,0 AS SeqNo FROM TempRetailerHdr
				WHERE RMID = @RMId AND RtrID = @RtrID
			
				FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			END
		CLOSE Cur_RMIdWK
		DEALLOCATE Cur_RMIdWK
		FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	END
	CLOSE Cur_RMId
	DEALLOCATE Cur_RMId
	--For Tuesday
	DECLARE Cur_RMId Cursor For
	SELECT distinct A.RMId,RMMon,RtrID FROM RouteMaster A,TempRetailerHdr B
	WHERE RMTue= 1 AND A.RMID = B.RmID ORDER BY A.RMId
	OPEN Cur_RMId	
	FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	WHILE @@FETCH_STATUS =0
	BEGIN
			DECLARE Cur_RMIdWK Cursor For
			SELECT JcwWk FROM (
			SELECT DISTINCT JcwWk FROM JCWeek WHERE JcwWk <=4
			UNION ALL 
			SELECT 5)A
			OPEN Cur_RMIdWK	
			FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			WHILE @@FETCH_STATUS =0
			BEGIN
				INSERT INTO TempJourneyCycle(DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,SeqWk,SeqDay,SeqNo)
				SELECT DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,@@JcwWk,2,0 AS SeqNo FROM TempRetailerHdr
				WHERE RMID = @RMId AND RtrID = @RtrID
			
				FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			END
		CLOSE Cur_RMIdWK
		DEALLOCATE Cur_RMIdWK
		FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	END
	CLOSE Cur_RMId
	DEALLOCATE Cur_RMId
	--For Wednesday
	DECLARE Cur_RMId Cursor For
	SELECT distinct A.RMId,RMMon,RtrID FROM RouteMaster A,TempRetailerHdr B
	WHERE RMWed= 1 AND A.RMID = B.RmID ORDER BY A.RMId
	OPEN Cur_RMId	
	FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	WHILE @@FETCH_STATUS =0
	BEGIN
			DECLARE Cur_RMIdWK Cursor For
			SELECT JcwWk FROM (
			SELECT DISTINCT JcwWk FROM JCWeek WHERE JcwWk <=4
			UNION ALL 
			SELECT 5)A
			OPEN Cur_RMIdWK	
			FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			WHILE @@FETCH_STATUS =0
			BEGIN
				INSERT INTO TempJourneyCycle(DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,SeqWk,SeqDay,SeqNo)
				SELECT DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,@@JcwWk,3,0 AS SeqNo FROM TempRetailerHdr
				WHERE RMID = @RMId AND RtrID = @RtrID
			
				FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			END
		CLOSE Cur_RMIdWK
		DEALLOCATE Cur_RMIdWK
		FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	END
	CLOSE Cur_RMId
	DEALLOCATE Cur_RMId
	--For Thursday
	DECLARE Cur_RMId Cursor For
	SELECT distinct A.RMId,RMMon,RtrID FROM RouteMaster A,TempRetailerHdr B
	WHERE RMThu= 1 AND A.RMID = B.RmID ORDER BY A.RMId
	OPEN Cur_RMId	
	FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	WHILE @@FETCH_STATUS =0
	BEGIN
			DECLARE Cur_RMIdWK Cursor For
			SELECT JcwWk FROM (
			SELECT DISTINCT JcwWk FROM JCWeek WHERE JcwWk <=4
			UNION ALL 
			SELECT 5)A
			OPEN Cur_RMIdWK	
			FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			WHILE @@FETCH_STATUS =0
			BEGIN
				INSERT INTO TempJourneyCycle(DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,SeqWk,SeqDay,SeqNo)
				SELECT DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,@@JcwWk,4,0 AS SeqNo FROM TempRetailerHdr
				WHERE RMID = @RMId AND RtrID = @RtrID
			
				FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			END
		CLOSE Cur_RMIdWK
		DEALLOCATE Cur_RMIdWK
		FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	END
	CLOSE Cur_RMId
	DEALLOCATE Cur_RMId
	--For Friday
	DECLARE Cur_RMId Cursor For
	SELECT distinct A.RMId,RMMon,RtrID FROM RouteMaster A,TempRetailerHdr B
	WHERE RMFri= 1 AND A.RMID = B.RmID ORDER BY A.RMId
	OPEN Cur_RMId	
	FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	WHILE @@FETCH_STATUS =0
	BEGIN
			DECLARE Cur_RMIdWK Cursor For
			SELECT JcwWk FROM (
			SELECT DISTINCT JcwWk FROM JCWeek WHERE JcwWk <=4
			UNION ALL 
			SELECT 5)A
			OPEN Cur_RMIdWK	
			FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			WHILE @@FETCH_STATUS =0
			BEGIN
				INSERT INTO TempJourneyCycle(DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,SeqWk,SeqDay,SeqNo)
				SELECT DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,@@JcwWk,5,0 AS SeqNo FROM TempRetailerHdr
				WHERE RMID = @RMId AND RtrID = @RtrID
			
				FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			END
		CLOSE Cur_RMIdWK
		DEALLOCATE Cur_RMIdWK
		FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	END
	CLOSE Cur_RMId
	DEALLOCATE Cur_RMId
	--For Saturday
	DECLARE Cur_RMId Cursor For
	SELECT distinct A.RMId,RMMon,RtrID FROM RouteMaster A,TempRetailerHdr B
	WHERE RMSat= 1 AND A.RMID = B.RmID ORDER BY A.RMId
	OPEN Cur_RMId	
	FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	WHILE @@FETCH_STATUS =0
	BEGIN
			DECLARE Cur_RMIdWK Cursor For
			SELECT JcwWk FROM (
			SELECT DISTINCT JcwWk FROM JCWeek WHERE JcwWk <=4
			UNION ALL 
			SELECT 5)A
			OPEN Cur_RMIdWK	
			FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			WHILE @@FETCH_STATUS =0
			BEGIN
				INSERT INTO TempJourneyCycle(DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,SeqWk,SeqDay,SeqNo)
				SELECT DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,@@JcwWk,6,0 AS SeqNo FROM TempRetailerHdr
				WHERE RMID = @RMId AND RtrID = @RtrID
			
				FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			END
		CLOSE Cur_RMIdWK
		DEALLOCATE Cur_RMIdWK
		FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	END
	CLOSE Cur_RMId
	DEALLOCATE Cur_RMId
	--For Sunday
	DECLARE Cur_RMId Cursor For
	SELECT distinct A.RMId,RMMon,RtrID FROM RouteMaster A,TempRetailerHdr B
	WHERE RMSun= 1 AND A.RMID = B.RmID ORDER BY A.RMId
	OPEN Cur_RMId	
	FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	WHILE @@FETCH_STATUS =0
	BEGIN
			DECLARE Cur_RMIdWK Cursor For
			SELECT JcwWk FROM (
			SELECT DISTINCT JcwWk FROM JCWeek WHERE JcwWk <=4
			UNION ALL 
			SELECT 5)A
			OPEN Cur_RMIdWK	
			FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			WHILE @@FETCH_STATUS =0
			BEGIN
				INSERT INTO TempJourneyCycle(DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,SeqWk,SeqDay,SeqNo)
				SELECT DistributorCode,SMCode,RMID,RMCode,RtrId,RtrCode,@@JcwWk,7,0 AS SeqNo FROM TempRetailerHdr
				WHERE RMID = @RMId AND RtrID = @RtrID
				UPDATE TempJourneyCycle SET SeqNo = RtrSeqDtId FROM TempJourneyCycle A,RetailerSequence B,RetailerSeqDetails C
				WHERE A.RMID = B.RMID AND B.RtrSeqId = C.RtrSeqId AND A.RtrId = C.RtrId AND A.RMID = @RMId AND A.RtrID = @RtrID
			
				FETCH NEXT FROM Cur_RMIdWK INTO @@JcwWk
			END
		CLOSE Cur_RMIdWK
		DEALLOCATE Cur_RMIdWK
		FETCH NEXT FROM Cur_RMId INTO @RMId,@RMMon,@RtrID
	END
	CLOSE Cur_RMId
	DEALLOCATE Cur_RMId
	
	UPDATE A SET A.SMNAME=B.SMName FROM TempJourneyCycle A 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMCode=B.SMCode  
	
	INSERT INTO Export_CS2WS_JourneyPlan(TenantCode,LocationCode,JourneyPlanCode,
	JourneyPlanDescription,CustomerCode,SequenceWeek,SequenceDay,SequenceNumber,BeatCode,UploadFlag)
	SELECT DistributorCode AS TenantCode,DistributorCode AS LocationCode,SMCode AS SalesmanCode,
	SMNAME AS SalesmanName,RtrCode AS CmpRtrCode,SeqWk AS SequenceWeek,SeqDay AS SequenceDay,
	SeqNo AS SequenceNumber,RMCode AS BeatCode,'N' AS UploadFlag FROM TempJourneyCycle
	
	--Data Set Return
	SELECT distinct TenantCode,
		LocationCode,
		JourneyPlanCode,
		JourneyPlanDescription,
		CustomerCode,
		SequenceWeek,
		SequenceDay,
		SequenceNumber,
		BeatCode 
		FROM Export_CS2WS_JourneyPlan (NOLOCK)
	 
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_CustomerTarget' and xtype='U')
DROP TABLE Export_CS2WS_CustomerTarget
GO
CREATE TABLE Export_CS2WS_CustomerTarget
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteCode		[Nvarchar](12),
	CustomerCode	[Nvarchar](25),
	TargetMonth		[Nchar](7),
	TargetName		[Nvarchar](50),
	MonthTarget		Float, 
	TillDateTarget	Float,
	TargetAchieved	Float,
	Threshold1		Float,
	UploadFlag		[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_CustomerTarget' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_CustomerTarget
GO
/*
begin tran
EXEC Proc_Export_CS2WS_CustomerTarget '1'
rollback tran
*/
CREATE PROCEDURE Proc_Export_CS2WS_CustomerTarget
(
	@SalRpCode varchar(50)
)
AS
/****************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_CustomerTarget
* PURPOSE		: To Export Customer Target details to the PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 21/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR          CR/BZ    USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  21/08/2018   Amuthakumar P    CR      CRCRSTPAR0017   SFA-Upload-Download Integration --Customer Target
*****************************************************************************************************/
BEGIN
SET NOCOUNT ON
DECLARE @DistCode AS NVARCHAR(50)
DECLARE @CurrMonth INTEGER
DECLARE @CurrYear INTEGER
		
SELECT @CurrMonth=MONTH(GETDATE())
SELECT @CurrYear=YEAR(GETDATE())

SELECT @DistCode = DistributorCode FROM Distributor (NOLOCK)
SELECT pListId Slno,pListValue Smid INTO #SMLIST1 from DBo.fn_getList(@SalRpCode)

   IF @DistCode <> ''
    BEGIN
		DELETE A FROM Export_CS2WS_CustomerTarget A (NOLOCK)
						
		SELECT Distinct TenantCode,LocationCode,SMID,RouteCode,CustomerCode,TargetMonth,TargetYear,TargetName,[Target],0.00 as TillDateTarget,0.00 as TargetAchieved  INTO #TEMP1
		FROM
		(SELECT DISTINCT Distributorcode AS TenantCode,Distributorcode AS LocationCode,SM.SMID,SM.SMCode AS RouteCode,R.CmpRtrCode AS CustomerCode, TargetMonth,TargetYear,'SALES' AS TargetName,D.AvgSal,D.[Target],H.Insid
		FROM InsTargetHD H (NOLOCK) INNER JOIN InsTargetDetails D (NOLOCK) ON H.InsId = D.InsId
		INNER JOIN Retailer R ON D.RtrId = R.RtrId
		INNER JOIN RetailerMarket RMM ON RMM.RtrId =R.RTRID
		INNER JOIN RouteMaster RM ON RMM.RMId=RM.RMID
		INNER JOIN SalesmanMarket SMM ON SMM.RMId=RMM.RMID
		INNER JOIN Salesman SM ON SMM.SMId=SM.SMID
		CROSS JOIN Distributor 
		WHERE H.EffFromMonthId = @CurrMonth and H.TargetYear=@CurrYear AND H.Status =1
		) A
		
		INSERT INTO Export_CS2WS_CustomerTarget(TenantCode,LocationCode,RouteCode,CustomerCode,TargetMonth,TargetName,MonthTarget,TillDateTarget,TargetAchieved,Threshold1) 
		SELECT TenantCode,LocationCode,RouteCode,CustomerCode,(CAST(TargetMonth AS CHAR(2)) + '/' + CAST(TargetYear AS CHAR(4))) ,TargetName,[Target],0.00 as TillDateTarget,0.00 as TargetAchieved,0 AS Threshold1 
		FROM #TEMP1 A INNER JOIN #SMLIST1 B ON A.SMID = B.Smid 
		
		UPDATE Export_CS2WS_CustomerTarget SET Threshold1 = 100
				
	END
		
	SELECT DISTINCT 
				TenantCode		,
				LocationCode	,
				RouteCode		,
				CustomerCode	,
				TargetMonth		,
				TargetName		,
				MonthTarget		, 
				TillDateTarget	,
				TargetAchieved	,
				Threshold1		
	FROM Export_CS2WS_CustomerTarget WITH (NOLOCK) 
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_RouteTarget' and xtype='U')
DROP TABLE Export_CS2WS_RouteTarget
GO
CREATE TABLE Export_CS2WS_RouteTarget
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	TargetMonth		[Nchar](7),
	TargetName		[Nvarchar](50),
	MonthTarget		Float, 
	TillDateTarget	Float,
	TargetAchieved	Float,
	Threshold1		Float,
	UploadFlag		[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_RouteTarget' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_RouteTarget
GO
/*
begin tran
EXEC Proc_Export_CS2WS_RouteTarget '1'
rollback tran
*/
CREATE PROCEDURE Proc_Export_CS2WS_RouteTarget
(
	@SalRpCode varchar(50)
)
AS
/****************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_RouteTarget
* PURPOSE		: To Export Route Target details to the PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 21/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR          CR/BZ    USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  21/08/2018   Amuthakumar P    CR      CRCRSTPAR0017   SFA-Upload-Download Integration --Route Target
*****************************************************************************************************/
BEGIN
SET NOCOUNT ON
DECLARE @DistCode AS NVARCHAR(50)
DECLARE @CurrMonth INTEGER
DECLARE @CurrYear INTEGER
		
SELECT @CurrMonth=MONTH(GETDATE())
SELECT @CurrYear=YEAR(GETDATE())

SELECT @DistCode = DistributorCode FROM Distributor (NOLOCK)
SELECT pListId Slno,pListValue Smid INTO #SMLIST1 from DBo.fn_getList(@SalRpCode)

   IF @DistCode <> ''
    BEGIN
		DELETE A FROM Export_CS2WS_RouteTarget A (NOLOCK)
						
		SELECT Distinct TenantCode,LocationCode,SMID,RouteCode,SalesmanCode,TargetMonth,TargetYear,TargetName,[Target],
		0.00 as TillDateTarget,0.00 as TargetAchieved  INTO #TEMP1
		FROM
		(SELECT DISTINCT Distributorcode AS TenantCode,Distributorcode AS LocationCode,SM.SMID,SM.SMCode AS RouteCode,
		SM.SMCode AS SalesmanCode, TargetMonth,TargetYear,'SALES' AS TargetName,D.AvgSal,D.[Target],H.Insid
		FROM InsTargetHD H (NOLOCK) INNER JOIN InsTargetDetails D (NOLOCK) ON H.InsId = D.InsId
		INNER JOIN Retailer R ON D.RtrId = R.RtrId
		INNER JOIN RetailerMarket RMM ON RMM.RtrId =R.RTRID
		INNER JOIN RouteMaster RM ON RMM.RMId=RM.RMID
		INNER JOIN SalesmanMarket SMM ON SMM.RMId=RMM.RMID
		INNER JOIN Salesman SM ON SMM.SMId=SM.SMID
		CROSS JOIN Distributor 
		WHERE H.EffFromMonthId = @CurrMonth and H.TargetYear=@CurrYear AND H.Status =1
		) A
		
		INSERT INTO Export_CS2WS_RouteTarget(TenantCode,LocationCode,RouteCode,SalesmanCode,TargetMonth,TargetName,
		MonthTarget,TillDateTarget,TargetAchieved,Threshold1,UploadFlag) 
		SELECT TenantCode,LocationCode,RouteCode,SalesmanCode,(CAST(TargetMonth AS CHAR(2)) + '/' + CAST(TargetYear AS CHAR(4))) ,
		TargetName,ISNULL(SUM([Target]),0),
		0.00 as TillDateTarget,0.00 as TargetAchieved,0 AS Threshold1,'N' As UploadFlag 
		FROM #TEMP1 A INNER JOIN #SMLIST1 B ON A.SMID = B.Smid 
		GROUP BY TenantCode,LocationCode,RouteCode,SalesmanCode,TargetMonth,TargetYear,TargetName
		
		UPDATE Export_CS2WS_RouteTarget SET Threshold1 = 100
				
	END
		
	SELECT   Distinct
				TenantCode		,
				LocationCode	,
				RouteCode		,
				SalesmanCode	,
				TargetMonth		,
				TargetName		,
				MonthTarget		, 
				TillDateTarget	,
				TargetAchieved	,
				Threshold1		
	FROM Export_CS2WS_RouteTarget WITH (NOLOCK) 
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_SchemeAchievement' and xtype='U')
DROP TABLE Export_CS2WS_SchemeAchievement
GO
CREATE TABLE Export_CS2WS_SchemeAchievement
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	CustomerCode	[Nvarchar](25),
	PromotionCode	[Nvarchar](50),
	BudgetUtilized	Float,
	ActualSales		Float,
	UploadFlag		[VARCHAR](1)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_SchemeAchievement' AND XTYPE='P')
DROP PROCEDURE Proc_Export_CS2WS_SchemeAchievement
GO
/*
BEGIN TRAN
Exec Proc_Export_CS2WS_SchemeAchievement '1'
SELECT *  FROM WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Export_CS2WS_SchemeAchievement
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_SchemeAchievement
* PURPOSE		: To Export Scheme Acheivement Details Intermediate Database
* CREATED		: Amuthakumar P            CR:  CRCRSTAPAR0016
* CREATED DATE	: 24/08/2018 
* MODIFIED		:
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 24/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Scheme Acheivement details
*********************************************************************************************************************/
BEGIN

	 --SELECT pListId Slno,pListValue Smid INTO #SMLIST1 FROM DBo.fn_getList(@SalRpCode)
	 
	 DELETE FROM Export_CS2WS_SchemeAchievement WHERE UploadFlag='Y'
	 
		 CREATE TABLE #Schbudget
			(
					SchId				[Bigint],
					RTRId				[Bigint],
					SalId				[Bigint],
					BudgetUtilized 		FLOAT,
					SalesNetAmt			FLOAT
			)
			
			CREATE TABLE #SchActual
			(
					SchId				[Bigint],
					RTRId				[Bigint],
					SalId				[Bigint],
					BudgetUtilized 		FLOAT,
					SalesNetAmt			FLOAT
			)
			
			INSERT INTO #Schbudget
			SELECT S.Schid,Rtrid,A.Salid,
			(ISNULL(SUM(A.FlatAmount+A.DiscountPerAmount),0)) AS BudgetUtilized,			
			SUM(ISNULL(B.SalNetAmt,0))   AS SalNetAmt
			FROM SalesInvoiceSchemeLineWise A
			INNER JOIN SalesInvoice B ON A.SalId = B.SalId
			INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
			WHERE DlvSts <> 3 AND CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill 
			and schstatus=1 AND S.SchType<>4  --B.SalInvDate Between SchValidFrom and SchValidTill
			GROUP BY  S.Schid,Rtrid,A.SalId
			
			INSERT INTO #Schbudget	
			SELECT S.Schid,Rtrid,A.ReturnID AS SALID,
			-1*(ISNULL(SUM(A.ReturnFlatAmount+A.ReturnDiscountPerAmount),0)) AS BudgetUtilized,
			-1*SUM(ISNULL(B.RtnNetAmt,0))  AS SalNetAmt
			FROM ReturnSchemeLineDt A
			INNER JOIN ReturnHeader B ON A.RETURNID = B.RETURNID
			INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
			WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill 
			and schstatus=1 AND S.SchType<>4  --B.SalInvDate Between SchValidFrom and SchValidTill
			GROUP BY  S.Schid,Rtrid,A.ReturnID
			
			INSERT INTO #Schbudget
			SELECT S.Schid,Rtrid,A.SalId, 
			ISNULL(SUM((FreeQty - GiftQty) * D.PrdBatDetailValue),0) AS BudgetUtilized,
			SUM(ISNULL(B.SalNetAmt,0)) AS SalNetAmt
			FROM SalesInvoiceSchemeDtFreePrd A
			INNER JOIN SalesInvoice B ON A.SalId = B.SalId
			INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId
			INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId
			INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
			INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
			WHERE DlvSts <> 3 AND 
			CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill 
			and schstatus=1 AND s.SchType<>4 --B.SalInvDate Between SchValidFrom and SchValidTill
			GROUP BY  S.Schid,Rtrid,A.SalId
			
			INSERT INTO #Schbudget
			SELECT S.Schid,Rtrid,A.ReturnId As Salid, 
			-1*ISNULL(SUM((ReturnFreeQty - ReturnGiftQty) * D.PrdBatDetailValue),0) AS BudgetUtilized,
			-1* SUM(ISNULL(B.RtnNetAmt,0)) AS SalNetAmt
			FROM ReturnSchemeFreePrdDt  A
			INNER JOIN ReturnHeader  B ON A.ReturnId  = B.ReturnID 
			INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId
			INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId
			INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
			INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
			WHERE 
			CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill 
			and schstatus=1 AND s.SchType<>4 --B.SalInvDate Between SchValidFrom and SchValidTill
			GROUP BY  S.Schid,Rtrid,A.ReturnId
						
			--INSERT INTO #Schbudget
			--SELECT A.Schid,A.Rtrid,b.Salid, ISNULL(SUM(AdjAmt),0)  AS BudgetUtilized, 
			--SUM(ISNULL(b.SalNetAmt,0)) AS SalNetAmt
			--FROM SalesInvoiceWindowDisplay A
			--INNER JOIN SalesInvoice B ON A.SalId = B.SalId
			--INNER JOIN SchemeMaster C ON A.SchId = C.SchId 
			--WHERE DlvSts <> 3 AND 
			--CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill 
			--and schstatus=1 AND C.SchType<>4
			----B.SalInvDate Between SchValidFrom and SchValidTill
			--GROUP BY A.Schid,A.Rtrid,b.Salid
			
			INSERT INTO #Schbudget
			SELECT SIQ.Schid,si.Rtrid,si.SalId As Salid,
			ISNULL(SUM(CrNoteAmount),0),SUM(ISNULL(SI.SalNetAmt,0)) AS SalNetAmt FROM SalesInvoiceQPSSchemeAdj SIQ
			INNER JOIN SalesInvoice SI ON SI.SalId=SIQ.SalId AND SI.DlvSts>3 
			INNER JOIN SchemeMaster S ON SIQ.SchId=S.SchId
			WHERE SIQ.SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=0) and 
			CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill 
			and SCHSTATUS=1 GROUP BY SIQ.Schid,si.Rtrid,si.SalId
			
			INSERT INTO #SchActual
			SELECT SCHID,RTRID,SALID,ISNULL(SUM(BudgetUtilized),0), 
			ISNULL(SUM(SalesNetAmt),0)
			FROM #Schbudget
			GROUP BY SCHID,RTRID,SALID
		
			--SELECT @WindowAmt = @WindowAmt + ISNULL(SUM(Amount),0) FROM ChequeDisbursalMaster A
			--INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo
			--WHERE TransId = @Pi_SchId AND TransType = 1 AND B.RtrId =@Pi_RtrId And A.ChqDisDate Between @FromDate and @ToDate
				
			--SELECT @FBMSchAmt=ISNULL(SUM(DiscAmt),0) FROM FBMSchDetails WHERE SchId=@Pi_SchId AND TransId IN (2)
			--AND SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=1)
								
			--SELECT @QPSSchAmt=ISNULL(SUM(CrNoteAmount),0) FROM SalesInvoiceQPSSchemeAdj SIQ
			--INNER JOIN SalesInvoice SI ON SI.SalId=SIQ.SalId AND SI.DlvSts>3 AND SIQ.SchId=@Pi_SchId
			--WHERE SIQ.SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=0)
			
			
		INSERT INTO Export_CS2WS_SchemeAchievement(TenantCode,LocationCode,CustomerCode,PromotionCode,BudgetUtilized,ActualSales,UploadFlag)
		SELECT DISTINCT DistributorCode,DistributorCode,CmpRtrCode,CmpSchCode,SR.BudgetUtilized,SR.SalesNetAmt AS ActualSales,'N' AS UploadFlag 
		FROM #SchActual SR INNER JOIN SchemeMaster SM ON SR.SchId = SM.Schid 
		INNER JOIN Retailer R ON SR.RTRId = R.RtrId 
		--INNER JOIN #SMLIST1 S ON R.RtrId = S.Smid 
		CROSS JOIN Distributor D
		WHERE ISNULL(CmpSchCode,'')<>'' AND NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = R.CmpRtrCode AND M.MasterName = SM.CmpSchCode
		and M.Ref4Value=SR.BudgetUtilized AND M.ProcessName='Scheme Achivement')  
		
		DELETE M FROM Export_CS2WS_SchemeAchievement SR 
		INNER JOIN WSMasterExportUploadTrack M ON M.MasterCode = SR.CustomerCode AND M.MasterName = SR.PromotionCode
		WHERE M.ProcessName='Scheme Achivement'
			 
		TRUNCATE TABLE #Schbudget
		 	 
		INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
		SELECT 'Scheme Achivement',CustomerCode,PromotionCode,GETDATE(),0,LocationCode,'','',BudgetUtilized FROM Export_CS2WS_SchemeAchievement
		WHERE UploadFlag='N'
	 
		SELECT DISTINCT 
			TenantCode,
			LocationCode,
			CustomerCode,
			PromotionCode,
			BudgetUtilized,
			ActualSales
		FROM Export_CS2WS_SchemeAchievement WITH (NOLOCK)
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_PendingInvoice' and xtype='U')
DROP TABLE Export_CS2WS_PendingInvoice
GO
CREATE TABLE Export_CS2WS_PendingInvoice
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	CustomerCode		[nvarchar](25),
	RouteCode			[nvarchar](12),
	SalesmanCode		[nvarchar](12),	
	DivisionCode		[nvarchar](12),
	SAPNo				[nvarchar](30),
	InvoicePrefix		[nvarchar](20),
	InvoiceNumber		[Int],
	InvoiceDate			[Datetime],
	TotalInvoiceAmount	[Float],
	PaidAmount			[Float],
	BalanceAmount		[Float],
	IsNew				[Tinyint],
	DocumentType		[Int],
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_PendingInvoice' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_PendingInvoice
GO
--exec [Proc_Export_CS2WS_PendingInvoice] '1'
CREATE PROCEDURE Proc_Export_CS2WS_PendingInvoice
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_PendingInvoice
* PURPOSE		: To Export Pending Invoice Details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 21/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0020    Parle SFA integration to Vxceed server(P
********************************************************************************************/
BEGIN

	DECLARE @DistCode AS NVARCHAR(100)
	DECLARE @FromDate AS DateTime
	DECLARE @ToDate	AS DateTime
	DECLARE @Days AS int
	
	SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)
	DELETE FROM Export_CS2WS_PendingInvoice WHERE UploadFlag='Y'
	
	SELECT @Days=ISNULL(CValue,0) FROM Tbl_SFAConfiguration WHERE CName = 'PendingInvoices'
	
	IF ISNULL(@Days,0)=0
	BEGIN
		SET @FromDate=(SELECT MIN(SalInvDate) FROM SalesInvoice(NOLOCK))
	END
	ELSE
	BEGIN
		SET @FromDate=CONVERT(VARCHAR(10),DATEADD(DAY,-@Days,GETDATE()),121)
	END
	
	SELECT @ToDate= CONVERT(VARCHAR(10),GETDATE(),121)
	--select @FromDate,@ToDate
	
	SELECT pListId Slno,pListValue Smid INTO #SMLIST1 from DBo.fn_getList(@SalRpCode)
	
	INSERT INTO Export_CS2WS_PendingInvoice(TenantCode,LocationCode,CustomerCode,RouteCode,
	SalesmanCode,DivisionCode,SAPNo,InvoicePrefix,InvoiceNumber,InvoiceDate,TotalInvoiceAmount,
	PaidAmount,BalanceAmount,IsNew,DocumentType,UploadFlag)	
	SELECT @DistCode,@DistCode,CmpRtrCode,'' RouteCode,SM.SMCode,'DD' DivisionCode,
	'' SAPNo,A.SalInvNo,0 AS InvoiceNumber,A.SalInvDate,A.SalNetAmt,
	A.SalPayAmt,A.SalNetAmt-A.SalPayAmt,0,2,'N'
	 FROM SalesInvoice A (NOLOCK) 
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId=R.RtrId 
	INNER JOIN SalesMan SM(NOLOCK) ON SM.SMId=A.SMId 
	INNER JOIN #SMLIST1 SM1 ON SM1.Smid=SM.SMId AND SM1.Smid=A.SMId 
	WHERE A.SalNetAmt-A.SalPayAmt>0 AND DlvSts>3 
	and SalInvDate between @FromDate and @ToDate
	
	SELECT distinct
		TenantCode,
		LocationCode,
		CustomerCode,
		RouteCode,
		SalesmanCode,
		DivisionCode,
		SAPNo,
		InvoicePrefix,
		InvoiceNumber,
		InvoiceDate,
		TotalInvoiceAmount,
		PaidAmount,
		BalanceAmount,
		IsNew,
		DocumentType
		FROM Export_CS2WS_PendingInvoice WITH (NOLOCK) 
	
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_SalesInvoiceHeader' and xtype='U')
DROP TABLE Export_CS2WS_SalesInvoiceHeader
GO
CREATE TABLE Export_CS2WS_SalesInvoiceHeader
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	TransactionType		[Tinyint],	
	InvoiceNo			[nvarchar](20),
	HHTOrderNo			[nvarchar](20),
	DocumentDate		[Datetime],	
	RouteCode			[nvarchar](12),	
	SalesmanCode		[nvarchar](12),	
	CustomerCode		[nvarchar](25),
	DivisionCode		[nvarchar](12),	
	TotalQuantity		[Float],
	SalesAmount			[Float],
	ReturnAmount		[Float],
	DocumentAmount		[Float],	
	CurrencyCode		[Nvarchar](3),
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Export_CS2WS_SalesInvoiceDetails' and xtype='U')
DROP TABLE Export_CS2WS_SalesInvoiceDetails
GO
CREATE TABLE Export_CS2WS_SalesInvoiceDetails
(
	TenantCode			[nvarchar](12),
	LocationCode		[nvarchar](12),
	InvoiceNo			[nvarchar](20),
	SequenceNumber		[Int],
	ItemTransactionType		[Int],
	ItemCode			[Nvarchar](50),
	UnitsOfMeasure		[Nvarchar](20),
	ItemTypeCode		[Tinyint],
	ItemQuantity		[Float],
	ItemPrice			[Float],
	DiscountAmount		[Float],
	TaxAmount			[Float],
	NetUnitPrice		[Float],	
	NetLineAmount		[Float],	
	IsFreeGood			[tinyint],
	UploadFlag			[VARCHAR](1)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_SalesInvoiceHeader' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_SalesInvoiceHeader
GO
--exec [Proc_Export_CS2WS_SalesInvoiceHeader] '1'
CREATE PROCEDURE Proc_Export_CS2WS_SalesInvoiceHeader
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_SalesInvoiceHeader
* PURPOSE		: To Export Invoice Header Details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 23/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  23/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(P
********************************************************************************************/
BEGIN

	DECLARE @DistCode AS NVARCHAR(100)
	DECLARE @FromDate AS DateTime
	DECLARE @ToDate	AS DateTime
	DECLARE @Days AS int
		
	SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)
	
	SELECT pListId Slno,pListValue Smid INTO #SMLIST1 from DBo.fn_getList(@SalRpCode)
	
	IF @DistCode <> ''
    BEGIN
		DELETE FROM Export_CS2WS_SalesInvoiceHeader WHERE UploadFlag='Y'
		DELETE FROM Export_CS2WS_SalesInvoiceDetails WHERE UploadFlag='Y'
		
		--Sales Header
		INSERT INTO Export_CS2WS_SalesInvoiceHeader (TenantCode,LocationCode,TransactionType,InvoiceNo,HHTOrderNo,
		DocumentDate,RouteCode,SalesmanCode,CustomerCode,DivisionCode,TotalQuantity,
		SalesAmount,ReturnAmount,DocumentAmount,CurrencyCode,UploadFlag)
		(SELECT @DistCode,@DistCode,2,SalinvNo,LEFT(SalInvRef,20),SalinvDate,SMCode,SMCode,CmpRtrCode,'D1',SUM(BaseQty), --CmpRtrCode OR RtrCode
		SalNetAmt,0,SalNetAmt,'INR','N'  ---SalGrossAmount
		FROM Salesinvoice A 
		INNER JOIN SalesinvoiceProduct B ON A.Salid =B.SalId 
		INNER JOIN ROUTEMASTER C ON A.RMID =C.RMID 
		INNER JOIN Salesman D ON A.Smid =D.Smid 
		INNER JOIN #SMLIST1 SM ON SM.Smid=D.SMId AND  SM.Smid=A.Smid
		INNER JOIN RETAILER E ON A.RTRid =E.Rtrid 
		WHERE SALINVDATE>='2018-09-01' AND Dlvsts in(4,5) AND 
		NOT EXISTS (SELECT * FROM WSMasterExportUploadTrack X WHERE X.MasterCode=A.SalinvNO and ProcessName='Sales Invoice')
		GROUP BY SalinvNo,SalInvRef,SalinvDate,SMCode,CmpRtrCode,SalGrossAmount,SalTaxAmount,totalDeduction,SalRoundOffAmt,SalNetAmt
		UNION ALL
		SELECT @DistCode,@DistCode,3,ReturnCode,'',ReturnDate,SMCode,SMCode,CmpRtrCode,'D1',SUM(BaseQty),0,
		RtnNetAmt,RtnNetAmt,'INR','N' ---RtnGrossAmt
		FROM ReturnHeader A 
		INNER JOIN ReturnProduct B ON A.Returnid =B.Returnid  
		INNER JOIN ROUTEMASTER C ON A.RMID =C.RMID 
		INNER JOIN Salesman D ON A.Smid =D.Smid 
		INNER JOIN #SMLIST1 SM ON SM.Smid=D.SMId AND  SM.Smid=A.Smid
		INNER JOIN RETAILER E ON A.RTRid =E.Rtrid 
		WHERE ReturnDate >='2018-09-01' AND A.Status =0 
		AND NOT EXISTS (SELECT * FROM WSMasterExportUploadTrack X WHERE X.MasterCode=A.ReturnCode and ProcessName='Sales Return')
		GROUP BY ReturnCode,ReturnDate,SMCode,CmpRtrCode,RtnGrossAmt,RtnTaxAmt, RtnRoundOffAmt,RtnNetAmt
		)	
		
		--- Sales Details   ----
		INSERT INTO Export_CS2WS_SalesInvoiceDetails (TenantCode,LocationCode,InvoiceNo,
		SequenceNumber,ItemTransactionType,	ItemCode,UnitsOfMeasure,ItemTypeCode,ItemQuantity,ItemPrice,
		DiscountAmount,TaxAmount,NetUnitPrice,NetLineAmount,IsFreeGood,UploadFlag)
		(SELECT @DistCode,@DistCode,SalinvNo,Case WHEN B.Slno < 0 THEN B.Slno*-1 ELSE B.Slno END as Slno,1,PrdCCode,UM.UomCode,1,BaseQty,PrdUnitSelRate,
		SUM(PrdSplDiscAmount+PrdSchDiscAmount+PrdDBDiscAmount+PrdCDAmount),PrdtaxAmount,SUM(PrdActualNetAmount/Baseqty),
		PrdNetAmount,0,'N'
		FROM Salesinvoice A 
		INNER JOIN SalesinvoiceProduct B ON A.Salid =B.SalId 
		INNER JOIN Salesman S ON A.SMId =S.SMId 
		INNER JOIN #SMLIST1 SM ON SM.Smid=S.SMId AND  SM.Smid=A.Smid
		INNER JOIN PRODUCT C ON B.PRDID =C.PRDID 
		INNER JOIN UomGroup D ON C.UomGroupid =D.UomGroupid AND D.BaseUom='Y'
		INNER JOIN UomMaster UM ON UM.UomId=D.UomId  		
		WHERE SALINVDATE>='2018-09-01' AND Dlvsts in(4,5)
		AND NOT EXISTS (SELECT * FROM WSMasterExportUploadTrack X WHERE X.MasterCode=A.SalinvNO and ProcessName='Sales Invoice')
		GROUP BY SalinvNo,B.Slno,PrdCCode,UM.UomCode,BaseQty,PrdUnitSelRate,PrdtaxAmount,PrdNetAmount
		UNION ALL
		SELECT @DistCode,@DistCode,SalinvNo,1,1,PrdCCode,UM.UomCode,1,freeQty,0,0,0,0,0,1,'N' ----- free qty 
		FROM Salesinvoice A INNER JOIN SalesInvoiceSchemeDtFreePrd B ON A.Salid =B.SalId 
		INNER JOIN Salesman S ON A.SMId =S.SMId 
		INNER JOIN PRODUCT C ON B.FreePrdId =C.PRDID 
		INNER JOIN UomGroup D ON C.UomGroupid =D.UomGroupid AND D.BaseUom='Y'
		INNER JOIN UomMaster UM ON UM.UomId=D.UomId  
		WHERE SALINVDATE>='2018-09-01' AND Dlvsts in(4,5)
		AND NOT EXISTS (SELECT * FROM WSMasterExportUploadTrack X WHERE X.MasterCode=A.SalinvNO and ProcessName='Sales Invoice')
		UNION ALL
		SELECT @DistCode,@DistCode,SalinvNo,1,1,PrdCCode,UM.UomCode,1,B.SalManFreeQty,0,0,0,0,0,1,'N' ---- freee
		FROM Salesinvoice A INNER JOIN SalesInvoiceProduct B ON A.Salid =B.SalId 
		INNER JOIN Salesman S ON A.SMId =S.SMId 
		INNER JOIN PRODUCT C ON B.PrdId =C.PRDID 
		INNER JOIN UomGroup D ON C.UomGroupid =D.UomGroupid  AND D.BaseUom='Y'
		INNER JOIN UomMaster UM ON UM.UomId=D.UomId  
		WHERE SALINVDATE>='2018-09-01' AND Dlvsts in(4,5) AND SalManFreeQty>0
		AND NOT EXISTS (SELECT * FROM WSMasterExportUploadTrack X WHERE X.MasterCode=A.SalinvNO and ProcessName='Sales Invoice')
		UNION ALL
		SELECT @DistCode,@DistCode,ReturnCode,Case WHEN B.Slno < 0 THEN B.Slno*-1 ELSE B.Slno END ,2,PrdCCode,UM.UomCode,1,BaseQty,PrdUnitSelRte,
		SUM(PrdSplDisAmt+PrdSchDisAmt+PrdDBDisAmt+PrdCDDisAmt),PrdtaxAmt,SUM(PrdNetAmt/Baseqty),PrdNetAmt,0,'N'
		FROM ReturnHeader A 
		INNER JOIN ReturnProduct  B ON A.ReturnId  =B.ReturnId 
		INNER JOIN Salesman S ON A.SMId =S.SMId 
		INNER JOIN #SMLIST1 SM ON SM.Smid=S.SMId AND  SM.Smid=A.Smid
		INNER JOIN PRODUCT C ON B.PRDID =C.PRDID 
		INNER JOIN UomGroup D ON C.UomGroupid =D.UomGroupid AND D.BaseUom='Y' 
		INNER JOIN UomMaster UM ON UM.UomId=D.UomId   
		WHERE ReturnDate >='2018-09-01' AND a.Status =0
		AND NOT EXISTS (SELECT * FROM WSMasterExportUploadTrack X WHERE X.MasterCode=A.ReturnCode and ProcessName='Sales Return')
		GROUP BY ReturnCode,B.Slno,PrdCCode,UM.UomCode,BaseQty,PrdUnitSelRte,PrdtaxAmt,PrdNetAmt
		)	
		
		INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
		SELECT 'Sales Invoice',InvoiceNo,InvoiceNo,GETDATE(),0,'','','',0 FROM Export_CS2WS_SalesInvoiceHeader B WHERE UploadFlag='N' AND TransactionType=2 UNION ALL
		SELECT 'Sales Return',InvoiceNo,CustomerCode,GETDATE(),0,'','','',0 FROM Export_CS2WS_SalesInvoiceHeader B WHERE UploadFlag='N' AND TransactionType=3
				
		update Export_CS2WS_SalesInvoiceHeader  SET DivisionCode='DD' WHERE UploadFlag='N'
		
		SELECT Distinct TenantCode,
				LocationCode,
				TransactionType,
				InvoiceNo,
				HHTOrderNo,
				DocumentDate,
				RouteCode,
				SalesmanCode,
				CustomerCode,
				DivisionCode,
				TotalQuantity,
				SalesAmount,
				ReturnAmount,
				DocumentAmount,
				CurrencyCode 
				FROM Export_CS2WS_SalesInvoiceHeader(NOLOCK) WHERE UploadFlag='N'
				
				
		SELECT	Distinct TenantCode,
				LocationCode,
				InvoiceNo,
				SequenceNumber,
				ItemTransactionType,
				ItemCode,
				UnitsOfMeasure,
				ItemTypeCode,
				ItemQuantity,
				ItemPrice,
				DiscountAmount,
				TaxAmount,
				NetUnitPrice,
				NetLineAmount,
				IsFreeGood
			FROM Export_CS2WS_SalesInvoiceDetails(NOLOCK) WHERE UploadFlag='N'
    END	
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_ExportValues' AND XTYPE='P')
DROP PROCEDURE Proc_ExportValues
GO
CREATE PROCEDURE Proc_ExportValues
(
	@TypeId INT,
	@PId INT = 0
)
AS
/*
Proc_ExportValues 1
*/
BEGIN
	IF (@TypeId  = 1) --SALESMAN
	BEGIN
	
		SELECT SMId,SMName FROM SalesMan WHERE Status = 1 --AND ISNULL(SMOtherDetails, '') LIKE '%~%'
		SELECT SMCode,SMName FROM SalesMan WHERE Status = 1 --AND ISNULL(SMOtherDetails, '') LIKE '%~%'
		----SELECT * FROM SalesMan
		SELECT CValue FROM Tbl_SFAConfiguration WHERE CName='LastExportDate'
		SELECT CValue FROM Tbl_SFAConfiguration WHERE CName='LastImportDate'
		SELECT CValue FROM Tbl_SFAConfiguration WHERE CName='LastModifiedDate'
	END
	ELSE IF (@TypeId = 2)
	BEGIN
		SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_SFAConfiguration WHERE CName='WebserviceURL'
		SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_SFAConfiguration WHERE CName='DeveloperKey'
		SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_SFAConfiguration WHERE CName='UserName'
		SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_SFAConfiguration WHERE CName='Password'
	END
	ELSE IF (@TypeId = 3)
	BEGIN
		SELECT ISNULL(LTRIM(RTRIM(DistributorCode)),'') FROM Distributor 
		SELECT '0' EnableFlag 
	END
	ELSE IF (@TypeId  = 4) --Location Details Flag
	BEGIN
		UPDATE Export_CS2WS_LocationDetails SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 5)--Customer Category Flag
	BEGIN
		UPDATE Export_CS2WS_CustomerCategory SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 6)--Customer Hierarchy Flag
	BEGIN
		UPDATE Export_CS2WS_CustomerHierarchyV1 SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 7)--Customer HierarchyV1 Flag
	BEGIN
		UPDATE Export_CS2WS_ProductCategory SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 8)--ProductCategory Hierarchy Flag
	BEGIN
		UPDATE Export_CS2WS_BeatMaster SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 9)--List Selection Flag
	BEGIN
		UPDATE Export_CS2WS_ListSelection SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 10)--Salesman Details Flag
	BEGIN
		UPDATE Export_CS2WS_SalesmanDetails SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 11)--Vehicle Details Flag
	BEGIN
		UPDATE Export_CS2WS_VehicleDetails SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 12)--HHTMaster Details Flag
	BEGIN
		UPDATE Export_CS2WS_HHTMasterDetails SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 13) --Product Master Flag
	BEGIN
		UPDATE Export_CS2WS_Product SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 14)--PricingPlan Flag
	BEGIN
		UPDATE Export_CS2WS_PricingPlan SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 15)--PricingPlan Flag
	BEGIN
		UPDATE Export_CS2WS_AuthorizedProduct SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 16)--WarehouseInventory  Flag
	BEGIN
		UPDATE Export_CS2WS_WarehouseInventory SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 17)--Customer Master  Flag
	BEGIN
		UPDATE Export_CS2WS_Customer SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 18)--Scheme Header  Flag
	BEGIN
		UPDATE Export_CS2WS_PromotionControl SET UploadFlag = 'Y'
		UPDATE Export_CS2WS_ProductGroup SET UploadFlag = 'Y'
		UPDATE Export_CS2WS_PromotionAssignment SET UploadFlag = 'Y'
		UPDATE Export_CS2WS_CustomerHierarchy SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 19)--Credit Details
	BEGIN
		UPDATE Export_CS2WS_CreditDetails SET UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 20)--Scheme Header  Flag
	BEGIN
		UPDATE Export_CS2WS_JourneyPlan SET  UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 21)--Route Setup  Flag
	BEGIN
		UPDATE Export_CS2WS_RouteSetupV1 SET  UploadFlag = 'Y'
		UPDATE Export_CS2WS_RouteDivisionsList SET  UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 22)--Route Setup  Flag
	BEGIN
	
		DELETE A FROM WSMasterExportUploadTrack A (NOLOCK)
		INNER JOIN SalesMan RM (NOLOCK) ON A.MasterCode=RM.SMCode
		WHERE ISNULL(RM.WSUpload,'N')='N' AND ProcessName='Salesman Details'

		---Whenever salesman interface triggered, trigger vehicle details interface too.
		DELETE A FROM WSMasterExportUploadTrack A (NOLOCK)
		INNER JOIN SalesMan RM (NOLOCK) ON A.MasterCode=RM.SMCode
		WHERE ISNULL(RM.WSUpload,'N')='N' AND ProcessName='Vehicle Details'

		UPDATE RM SET RM.WSUpload='Y' FROM WSMasterExportUploadTrack A (NOLOCK)
		INNER JOIN SalesMan RM (NOLOCK) ON A.MasterCode=RM.SMCode
		WHERE ISNULL(RM.WSUpload,'N')='N' AND ProcessName='Salesman Details'

		---Retailer 
		DELETE A FROM WSMasterExportUploadTrack A (NOLOCK)
		INNER JOIN Retailer R (NOLOCK) ON A.MasterCode=R.CmpRtrCode
		WHERE ISNULL(R.WSUpload,'N')='N' AND ProcessName='Customer'

		UPDATE R SET R.WSUpload='Y' FROM WSMasterExportUploadTrack A (NOLOCK)
		INNER JOIN Retailer R (NOLOCK) ON A.MasterCode=R.CmpRtrCode
		WHERE ISNULL(R.WSUpload,'N')='N' AND ProcessName='Customer'
				
	
		SELECT ProcessId,ProcessName,[Enable],Status FROM Tbl_WSUploadIntegration WHERE [Status]=1  AND Enable=1 
		ORDER BY ProcessId	
		SELECT ProcessId,ProcessName,[Enable],Status FROM Tbl_WSdownloadIntegration WHERE [Status]=1  AND Enable=1 
		ORDER BY ProcessId	
		
		SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_SFAConfiguration WHERE CName='WebserviceURL'
		SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_SFAConfiguration WHERE CName='AverageSales'
		SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_SFAConfiguration WHERE CName='PendingInvoices'
		
	END
	ELSE IF (@TypeId = 23)
	BEGIN
		SELECT [Status] FROM Tbl_WSUploadIntegration WHERE ProcessId = @PId
	END
	ELSE IF (@TypeId = 24)
	BEGIN
		UPDATE Tbl_SFAConfiguration SET CValue = GETDATE() WHERE CName='LastExportDate'
	END
	ELSE IF (@TypeId = 25)
	BEGIN
		UPDATE Tbl_SFAConfiguration SET CValue = GETDATE() WHERE CName='LastImportDate'
	END
	ELSE IF (@TypeId  = 26)--Scheme Header  Flag
	BEGIN
		UPDATE Export_CS2WS_PendingInvoice SET  UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 27)--Customer   Flag
	BEGIN
		UPDATE Export_CS2WS_CustomerTarget SET  UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 28)--Scheme Header  Flag
	BEGIN
		UPDATE Export_CS2WS_RouteTarget SET  UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 29)--Scheme Header  Flag
	BEGIN
		UPDATE Export_CS2WS_SalesInvoiceHeader SET  UploadFlag = 'Y'
		UPDATE Export_CS2WS_SalesInvoiceDetails SET  UploadFlag = 'Y'
	END
	ELSE IF (@TypeId  = 30)--Scheme Header  Flag
	BEGIN
		UPDATE Export_CS2WS_SchemeAchievement SET  UploadFlag = 'Y'
	END
	--ELSE IF (@TypeId  = 4) -- LOCATION DETAILS
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		LocationName,
	--		Address,
	--		City,
	--		State,
	--		Country,	
	--		Zip,
	--		Phone,
	--		Email,
	--		CurrencyCode
	--	FROM Export_CS2WS_LocationDetails WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 5)
	--BEGIN
	--	UPDATE Export_CS2WS_LocationDetails SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 6) -- CUSTOMER CATEGORY
	--BEGIN
	--	SELECT 
	--		TenantCode,
	--		CategoryType,
	--		CategoryCode,
	--		CategoryDescription
	--	FROM Export_CS2WS_CustomerCategory WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 7)
	--BEGIN
	--	UPDATE Export_CS2WS_CustomerCategory SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 8) -- CUSTOMER HIERARCHY V1
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		ParentCode,
	--		HierarchyLevel,
	--		HierarchyCode,
	--		HierarchyName,
	--		ParentHierarchy
	--	FROM Export_CS2WS_CustomerHierarchyV1 WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 9)
	--BEGIN
	--	UPDATE Export_CS2WS_CustomerHierarchyV1 SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 10) -- PRODUCT CATEGORY
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		ParentCode,
	--		HierarchyLevel,
	--		HierarchyCode,
	--		HierarchyName,
	--		ParentHierarchy
	--	FROM Export_CS2WS_ProductCategory WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 11)
	--BEGIN
	--	UPDATE Export_CS2WS_ProductCategory SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 12) -- BEAT MASTER
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		BeatCode,
	--		BeatName
	--	FROM Export_CS2WS_BeatMaster WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 13)
	--BEGIN
	--	UPDATE Export_CS2WS_BeatMaster SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 14) -- LIST SELECTION
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		ListTypeCode,
	--		Code,
	--		Description
	--	FROM Export_CS2WS_ListSelection WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 15)
	--BEGIN
	--	UPDATE Export_CS2WS_ListSelection SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 16) -- SALESMAN DETAILS
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		SalesmanCode,
	--		SalesmanName,
	--		[Address],
	--		City,
	--		[State],
	--		Zip,
	--		Phone,
	--		IsActive,
	--		[Password]
	--	FROM Export_CS2WS_SalesmanDetails WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 17)
	--BEGIN
	--	UPDATE Export_CS2WS_SalesmanDetails SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 18) -- VEHICLE DETAILS
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		VehicleCode,
	--		VehicleTitle
	--	FROM Export_CS2WS_VehicleDetails WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 19)
	--BEGIN
	--	UPDATE Export_CS2WS_VehicleDetails SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 20) -- HHT MASTER DETAILS
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		HHTName,
	--		HHTDeviceSerialNumber
	--	FROM Export_CS2WS_HHTMasterDetails WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId  = 21)
	--BEGIN
	--	UPDATE Export_CS2WS_HHTMasterDetails SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 22) --Product Master
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		ItemCode,
	--		UnitsOfMeasure,
	--		EANNumber,
	--		ItemTypeCode,
	--		ItemDescription,
	--		ShortDescription,
	--		DivisionCode,
	--		IsBUOM,
	--		Numerator,
	--		Denominator,
	--		[Weight],
	--		MRP,
	--		DefaultDebitPrice,
	--		DefaultCreditPrice,
	--		DefaultDamagePrice,
	--		ChangeLimit,
	--		CodeDateFormat,
	--		ItemShelfLife,
	--		IsActive,
	--		ContributionMargin,
	--		IsBatchManaged,
	--		HierarchyCode,
	--		HSNCode
	--	FROM Export_CS2WS_Product WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 23) --Product Master Flag
	--BEGIN
	--	UPDATE Export_CS2WS_Product SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 24) -- PricingPlan
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		PricingCode,
	--		PricingDescription,
	--		CONVERT(VARCHAR(10),StartDate,103) AS StartDate,
	--		CONVERT(VARCHAR(10),EndDate,103) AS EndDate,
	--		ItemCode,
	--		UnitsOfMeasure,
	--		DebitPrice,
	--		CreditPrice,
	--		DamagePrice
	--	FROM Export_CS2WS_PricingPlan WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 25)--PricingPlan Flag
	--BEGIN
	--	UPDATE Export_CS2WS_PricingPlan SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 26) -- PricingPlan
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		Code,
	--		[Description],
	--		ItemCode
	--	FROM Export_CS2WS_AuthorizedProduct WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 27)--PricingPlan Flag
	--BEGIN
	--	UPDATE Export_CS2WS_AuthorizedProduct SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 28) -- WarehouseInventory
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		WarehouseCode,
	--		ItemCode,
	--		Quantity
	--	FROM Export_CS2WS_WarehouseInventory WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 29)--WarehouseInventory  Flag
	--BEGIN
	--	UPDATE Export_CS2WS_WarehouseInventory SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 30) -- Scheme Header
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		PromotionCode,
	--		PromotionDescription,
	--		PromotionRemarks,
	--		PromotionTypeCode,
	--		RangeBasis,
	--		AmountBasis,
	--		ExclusionOption,
	--		PromotionIndicator,
	--		PromotionProductLevel,
	--		PromotionQuotaCode,
	--		AllowQPS
	--	FROM Export_CS2WS_PromotionControl WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 31)--Scheme Header  Flag
	--BEGIN
	--	UPDATE Export_CS2WS_PromotionControl SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 32) -- Scheme Products
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		PromotionCode,
	--		GroupType,
	--		ProductHierarchyCode,
	--		ItemCode,
	--		UnitsOfMeasure,
	--		Quantity
	--	FROM Export_CS2WS_ProductGroup WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 33)--Scheme Header  Flag
	--BEGIN
	--	UPDATE Export_CS2WS_ProductGroup SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 34) -- Scheme Products
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		PromotionCode,
	--		RangeLow,
	--		RangeHigh,
	--		RepeatingRange,
	--		PromotionAmount
	--	FROM Export_CS2WS_PromotionAssignment WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 35)--Scheme Header  Flag
	--BEGIN
	--	UPDATE Export_CS2WS_PromotionAssignment SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 36) -- Scheme Products
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		CustomerCode,
	--		CategoryCode1,
	--		CategoryCode2,
	--		CategoryCode3,
	--		CustomerHierarchyCode,
	--		SequenceNumber,
	--		PromotionCode,
	--		CONVERT(VARCHAR(10),StartDate,103) AS StartDate,
	--		CONVERT(VARCHAR(10),EndDate,103) AS EndDate,
	--		ActiveIndicator
	--	FROM Export_CS2WS_CustomerHierarchy WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 37)--Scheme Header  Flag
	--BEGIN
	--	UPDATE Export_CS2WS_CustomerHierarchy SET UploadFlag = 'Y'
	--END
	--ELSE IF (@TypeId  = 38) -- Scheme Products
	--BEGIN
	--	SELECT
	--		TenantCode,
	--		LocationCode,
	--		DivisionCode,
	--		CustomerCode,
	--		CreditLimit,
	--		CustomerBalanceDue,
	--		TotalNumberofInvoices,
	--		TotalDaysofInvoices,
	--		Blocked
	--	FROM Export_CS2WS_CreditDetails WITH (NOLOCK) 
	
	--END
	--ELSE IF (@TypeId  = 39)--Scheme Header  Flag
	--BEGIN
	--	UPDATE Export_CS2WS_CreditDetails SET UploadFlag = 'Y'
	--END
	
	--ELSE IF (@TypeId = 34)
	--BEGIN
	--	SELECT ProcessId,ProcessName,[Enable],Status FROM Tbl_PDAProcess
	--	ORDER BY ProcessId	
		
	--	SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_PDAConfiguration WHERE CName='WebserviceURL'
	--	SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_PDAConfiguration WHERE CName='AverageSales'
	--	SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_PDAConfiguration WHERE CName='PendingInvoices'
	--	SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_PDAConfiguration WHERE CName='WebserviceURL_New'
	--END
	--ELSE IF (@TypeId = 35)
	--BEGIN
	--	SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_PDAConfiguration WHERE CName='Password'
	--END
	--ELSE IF (@TypeId = 36)
	--BEGIN
	--	SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_PDAConfiguration WHERE CName='WebserviceURL'
	--END
	--ELSE IF (@TypeId = 37)
	--BEGIN
	--	SELECT Status FROM Tbl_PDAProcess WHERE ProcessId = @PId
	--END
	--ELSE IF (@TypeId = 38)
	--BEGIN
	--	UPDATE Tbl_PDAConfiguration SET CValue = GETDATE() WHERE CName='LastExportDate'
	--END
	--ELSE IF (@TypeId = 39)
	--BEGIN
	--	UPDATE Tbl_PDAConfiguration SET CValue = GETDATE() WHERE CName='LastImportDate'
	--END
	--ELSE IF (@TypeId = 40)
	--BEGIN
	--	SELECT 
	--		LocationCode,
	--		SalesmanCode,
	--		DocumentNumber
	--	FROM
	--	Export_RtTransactionDataDetails WITH (NOLOCK) 
	--END
	--ELSE IF (@TypeId = 41) -- Special Item Details
	--BEGIN
	--	SELECT 
	--		LocationCode,
	--		CategoryCode1,
	--		CategoryCode2,
	--		SpecialItemGroup,
	--		Description,
	--		ItemCode
	--	FROM
	--	Export_RtSpecialItemsDetails (NOLOCK)
	--END
	--ELSE IF (@TypeId = 42)
	--BEGIN
	--	UPDATE Export_RtSpecialItemsDetails SET UPLOADFLAG = 'Y'
	--END
	--ELSE IF (@TypeId = 43)
	--BEGIN
	--	SELECT
	--		LocationCode,
	--		PlanogramName,
	--		CategoryCode1,
	--		CategoryCode2
	--	FROM	
	--	Export_RtMerchandizeLocation (NOLOCK)
	--END
	--ELSE IF (@TypeId = 44)
	--BEGIN
	--	UPDATE Export_RtMerchandizeLocation SET UPLOADFLAG = 'Y'
	--END
	--ELSE IF (@TypeId = 45)
	--BEGIN
	--	SELECT 
	--		PlanogramName,
	--		PlanogramImage
	--	FROM
	--	Export_RtMerchLocationImages (NOLOCK)
	--END
	--ELSE IF (@TypeId = 46)
	--BEGIN
	--	UPDATE Export_RtMerchLocationImages SET UPLOADFLAG = 'Y'
	--END
	--ELSE IF (@TypeId = 47)
	--BEGIN
	--	SELECT 
	--		LocationCode,
	--		SurveyTitle,
	--		SurveyType,
	--		StartDate,
	--		EndDate,
	--		CategoryCode1,
	--		CategoryCode2
	--	FROM
	--	Export_RtSurveyControl (NOLOCK)				
	--END	
	--ELSE IF (@TypeId = 48)
	--BEGIN
	--	UPDATE Export_RtSurveyControl SET UPLOADFLAG = 'Y'
	--END
	--ELSE IF (@TypeId = 49)
	--BEGIN
	--	SELECT 
	--		SurveyTitle,
	--		QuestionTitle,
	--		QuestionType,
	--		MinVal,
	--		MaxVal
	--	FROM
	--	Export_Rtsurveydefintiondetails (NOLOCK)
	--END
	--ELSE IF (@TypeId = 50)
	--BEGIN
	--	UPDATE Export_Rtsurveydefintiondetails SET UPLOADFLAG = 'Y'
	--END
	--ELSE IF (@TypeId = 51)
	--BEGIN
	--	SELECT
	--		SurveyTitle,
	--		QuestionTitle,
	--		AnswerTitle,
	--		AnswerType
	--	FROM
	--		Export_RtSurveyAnswerdetails (NOLOCK)
	--END
	--ELSE IF (@TypeId = 52)
	--BEGIN
	--	UPDATE Export_RtSurveyAnswerdetails SET UPLOADFLAG = 'Y'
	--END
	--ELSE IF (@TypeId = 53)
	--BEGIN
	--	SELECT 
	--		LocationCode,
	--		SalesmanCode,
	--		TargetMonth,
	--		TargetName,
	--		TargetValue,
	--		TargetAchieved
	--	FROM
	--		Export_RtSalesmanTargetDetails (NOLOCK)			
	--END
	--ELSE IF (@TypeId = 54)
	--BEGIN
	--	UPDATE Export_RtSalesmanTargetDetails SET UPLOADFLAG = 'Y'
	--END
	--ELSE IF (@TypeId = 55)
	--BEGIN
	--	SELECT 
	--		LocationCode,
	--		SalesmanCode,
	--		CustomerCode,
	--		ReferenceCode
	--	FROM
	--		Export_RtTransactionDataDetails_Others (NOLOCK)
			
	--END
	--ELSE IF (@TypeId = 56)
	--BEGIN
	--	SELECT 
	--		LocationCode,
	--		SalesmanCode,
	--		SurveyResponseDate
	--	FROM
	--		Export_RtTransactionDataDetails_SurveyResponse (NOLOCK)
	--END
	--ELSE IF (@TypeId = 57)
	--BEGIN
	--	SELECT ISNULL(LTRIM(RTRIM(CValue)),'') FROM Tbl_PDAConfiguration WHERE CName='WebserviceURL_New'
	--END
	--ELSE IF (@TypeId = 58)
	--BEGIN
	--	SELECT ISNULL(LTRIM(RTRIM(DistributorCode)),'') FROM Distributor 
	--END
END
GO
--Export Process Completed
---Phase 2 Import Process Starts
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_SalesOrderHeader' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_SalesOrderHeader
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	CustomerCode	[Nvarchar](25),
	DocumentType	[Tinyint],
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	DocumentDate	[DateTime],
	DeliveryDate	[DateTime],
	PostingDateTime	[DateTime],
	DocumentAmount	[Float],
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='SaleOrderHeader_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_SalesOrderHeader ADD constraint SaleOrderHeader_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='SaleOrderHeader_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_SalesOrderHeader ADD constraint SaleOrderHeader_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_SalesOrderDetail' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_SalesOrderDetail
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	SequenceNumber	[Integer],
	TransactionType	[Integer],
	ItemCode		[Nvarchar](50),
	UnitsOfMeasure	[Nvarchar](20),
	ItemQuantity	[float],
	ItemPrice		[float],
	PromotionAmount	[float],
	ItemExciseTax	[float],
	TotalLineAmount	[float],
	IsFreeGood		[tinyint],
	DownloadFlag		[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='SaleOrderDetail_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_SalesOrderDetail ADD constraint SaleOrderDetail_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='SaleOrderDetail_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_SalesOrderDetail ADD constraint SaleOrderDetail_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='WS2CS_SalesOrderHeader_NewRetailer' AND XTYPE='U')
BEGIN
CREATE TABLE WS2CS_SalesOrderHeader_NewRetailer
(
	OrderNo			[Nvarchar](25),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	CustomerCode	[Nvarchar](25),
	DocumentType	[Tinyint],
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	DocumentDate	[DateTime],
	DeliveryDate	[DateTime],
	PostingDateTime	[DateTime],
	DocumentAmount	[Float],
	DownloadFlag	[varchar](1)
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='WS2CS_SalesOrderDetail_NewRetailer' AND XTYPE='U')
BEGIN
CREATE TABLE WS2CS_SalesOrderDetail_NewRetailer
(
	OrderNo			[Nvarchar](25),
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	SequenceNumber	[Integer],
	TransactionType	[Integer],
	ItemCode		[Nvarchar](50),
	UnitsOfMeasure	[Nvarchar](20),
	ItemQuantity	[float],
	ItemPrice		[float],
	PromotionAmount	[float],
	ItemExciseTax	[float],
	TotalLineAmount	[float],
	IsFreeGood		[tinyint],
	[DownLoadFlag]	VARCHAR(1)
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_SalesOrderHeader_Track' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_SalesOrderHeader_Track
(
	SlNo			NUMERIC(32,0) IDENTITY(1,1),
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	CustomerCode	[Nvarchar](25),
	DocumentType	[Tinyint],
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	DocumentDate	[DateTime],
	DeliveryDate	[DateTime],
	PostingDateTime	[DateTime],
	DocumentAmount	[Float],
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_SalesOrderDetail_Track' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_SalesOrderDetail_Track
(
	SlNo			NUMERIC(32,0) IDENTITY(1,1),
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	SequenceNumber	[Integer],
	TransactionType	[Integer],
	ItemCode		[Nvarchar](50),
	UnitsOfMeasure	[Nvarchar](20),
	ItemQuantity	[float],
	ItemPrice		[float],
	PromotionAmount	[float],
	ItemExciseTax	[float],
	TotalLineAmount	[float],
	IsFreeGood		[tinyint],
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_SalesOrderReturnExchange' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_SalesOrderReturnExchange
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	DocumentPrefix	[Nvarchar](12),
	DocumentNumber	[Integer],
	SequenceNumber	[Integer],
	ItemTransactionType	[tinyint],
	ItemCode		[Nvarchar](50),
	UnitsOfMeasure	[Nvarchar](20),
	ItemQuantity	[float],
	ReasonCode		[Nvarchar](12),
	SalesDocumentNo	[Nvarchar](25),
	DownloadFlag		[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='SalesOrderReturnExchange_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_SalesOrderReturnExchange ADD constraint SalesOrderReturnExchange_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='SalesOrderReturnExchange_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_SalesOrderReturnExchange ADD constraint SalesOrderReturnExchange_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_SalesOrderReturnExchange_Track' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_SalesOrderReturnExchange_Track
(
	SlNo			[NUMERIC](32,0) IDENTITY(1,1),
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	DocumentPrefix	[Nvarchar](12),
	DocumentNumber	[Integer],
	SequenceNumber	[Integer],
	ItemTransactionType	[tinyint],
	ItemCode		[Nvarchar](50),
	UnitsOfMeasure	[Nvarchar](20),
	ItemQuantity	[float],
	ReasonCode		[Nvarchar](12),
	SalesDocumentNo	[Nvarchar](25),
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Import_WS2CS_SalesOrderDetail' AND xtype='P')
DROP PROCEDURE Proc_Import_WS2CS_SalesOrderDetail
GO
CREATE PROCEDURE Proc_Import_WS2CS_SalesOrderDetail
(
	@StrXml1 NTEXT,
	@StrXml2 NTEXT,  
	@StrXml3 NTEXT,  
	@StrXml4 NTEXT
)
AS 
/*******************************************************************************************
* PROCEDURE		: Proc_Import_WS2CS_SalesOrderDetail
* PURPOSE		: To Import Sales Order details From PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 24/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  24/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/
BEGIN
	DECLARE @IDOC1 AS INT 
	DECLARE @IDOC2 AS INT 
	DECLARE @IDOC3 AS INT 
	DECLARE @IDOC4 AS INT  
	DELETE FROM Import_WS2CS_SalesOrderHeader WHERE DownloadFlag='Y'
	DELETE FROM Import_WS2CS_SalesOrderDetail WHERE DownloadFlag='Y'
	DELETE FROM Import_WS2CS_SalesOrderReturnExchange WHERE DownloadFlag='Y'
	
	EXEC SP_XML_PREPAREDOCUMENT @IDOC1 OUTPUT, @StrXml1  
	-----SALES ORDER HEADER
	INSERT INTO Import_WS2CS_SalesOrderHeader
	(  
		TenantCode,
		LocationCode,
		RouteCode,
		SalesmanCode,
		CustomerCode,
		DocumentType,
		DocumentPrefix,
		DocumentNumber,
		DocumentDate,
		DeliveryDate,
		PostingDateTime,
		DocumentAmount,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		TenantCode,
		LocationCode,
		RouteCode,
		SalesmanCode,
		CustomerCode,
		DocumentType,
		DocumentPrefix,
		DocumentNumber,
		DocumentDate,
		DeliveryDate,
		PostingDateTime,
		DocumentAmount,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@IDOC1,'/SalesOrderHeader',2)  
	--(@iDOC,'/SalesOrder/SalesOrderHeader',2)  
	WITH  
	(   
		TenantCode		[Nvarchar](12),
		LocationCode	[Nvarchar](12),
		RouteCode		[Nvarchar](12),
		SalesmanCode	[Nvarchar](12),
		CustomerCode	[Nvarchar](25),
		DocumentType	[Tinyint],
		DocumentPrefix 	[Nvarchar](12),
		DocumentNumber	[Integer],
		DocumentDate	[DateTime],
		DeliveryDate	[DateTime],
		PostingDateTime	[DateTime],
		DocumentAmount	[Float]
	) 
	EXECUTE SP_XML_REMOVEDOCUMENT @IDOC1  
	
	-----SALES ORDER DETAILS 
	EXEC SP_XML_PREPAREDOCUMENT @IDOC2 OUTPUT, @StrXml2  
	
	INSERT INTO Import_WS2CS_SalesOrderDetail
	(  
		TenantCode,
		LocationCode,
		DocumentPrefix,
		DocumentNumber,
		SequenceNumber,
		TransactionType,
		ItemCode,
		UnitsOfMeasure,
		ItemQuantity,
		ItemPrice,
		PromotionAmount,
		ItemExciseTax,
		TotalLineAmount,
		IsFreeGood,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		TenantCode,
		LocationCode,
		DocumentPrefix,
		DocumentNumber,
		SequenceNumber,
		TransactionType,
		ItemCode,
		UnitsOfMeasure,
		ItemQuantity,
		ItemPrice,
		PromotionAmount,
		ItemExciseTax,
		TotalLineAmount,
		IsFreeGood,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@IDOC2,'/SalesOrderDetail',2) 
	--(@iDOC,'/SalesOrder/OrderHeader/OrderDetail',2)  
	WITH  
	(   
		TenantCode		[Nvarchar](12),
		LocationCode	[Nvarchar](12),
		DocumentPrefix 	[Nvarchar](12),
		DocumentNumber	[Integer],
		SequenceNumber	[Integer],
		TransactionType	[Integer],
		ItemCode		[Nvarchar](50),
		UnitsOfMeasure	[Nvarchar](20),
		ItemQuantity	[float],
		ItemPrice		[float],
		PromotionAmount	[float],
		ItemExciseTax	[float],
		TotalLineAmount	[float],
		IsFreeGood		[tinyint]
	)  
	EXECUTE SP_XML_REMOVEDOCUMENT @IDOC2  	
	
	-----Sales Return Details
	EXEC SP_XML_PREPAREDOCUMENT @IDOC3 OUTPUT, @StrXml3  
	
	INSERT INTO Import_WS2CS_SalesOrderReturnExchange
	(
		TenantCode,
		LocationCode,
		DocumentPrefix,
		DocumentNumber,
		SequenceNumber,
		ItemTransactionType,
		ItemCode,
		UnitsOfMeasure,
		ItemQuantity,
		ReasonCode,
		SalesDocumentNo,
		DownloadFlag,
		CreatedDate
	)
	SELECT 
		TenantCode,
		LocationCode,
		DocumentPrefix,
		DocumentNumber,
		SequenceNumber,
		ItemTransactionType,
		ItemCode,
		UnitsOfMeasure,
		ItemQuantity,
		ReasonCode,
		SalesDocumentNo,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@IDOC3,'/SalesOrderReturnExchange',2) 
	--(@iDOC,'/SalesOrder/OrderHeader/OrderDetail',2)  
	WITH  
	(   
		TenantCode		[Nvarchar](12),
		LocationCode	[Nvarchar](12),
		DocumentPrefix	[Nvarchar](12),
		DocumentNumber	[Integer],
		SequenceNumber	[Integer],
		ItemTransactionType	[tinyint],
		ItemCode		[Nvarchar](50),
		UnitsOfMeasure	[Nvarchar](20),
		ItemQuantity	[float],
		ReasonCode		[Nvarchar](12),
		SalesDocumentNo	[Nvarchar](25)
	)  
	EXECUTE SP_XML_REMOVEDOCUMENT @IDOC3  		
	
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_WS2CS_NewRetailerSalesOrderDetail' AND XTYPE='P')
DROP PROCEDURE Proc_WS2CS_NewRetailerSalesOrderDetail
GO
/*
BEGIN TRANSACTION 
DELETE FROM ERRORLOG
exec Proc_WS2CS_NewRetailerSalesOrderDetail 0 
SELECT * FROM ERRORLOG
SELECT * FROM ORDERBOOKING ORDER BY ORDERDATE DESC
SELECT * FROM ORDERBOOKINGPRODUCTS  where orderno in (SELECT orderno FROM ORDERBOOKING where orderdate='2018-08-11')
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_WS2CS_NewRetailerSalesOrderDetail
(
	@CmpRtrCode		NVARCHAR(100),
	@RtrCode		NVARCHAR(100)
)
AS      
/*******************************************************************************************
* PROCEDURE		: Proc_WS2CS_NewRetailerSalesOrderDetail
* PURPOSE		: To Validate the Order booking details From PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 07/09/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  24/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/ 
DECLARE @OrdKeyNo AS VARCHAR(50)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT
DECLARE @Smid AS INT 
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @RtrShipId AS INT
DECLARE @OrdPrdCnt AS INT
DECLARE @ImpOrdPrdCnt AS INT
DECLARE @OrderDate AS DateTime 
DECLARE @SalesmanCode NVarchar(100)
DECLARE @RouteCode NVarchar(100) 
DECLARE @RetailerCode NVarchar(100)
DECLARE @Remarks NVARCHAR(200)
DECLARE @lError AS INT
DECLARE @LAUdcMasterId AS VARCHAR(50)
DECLARE @LOUdcMasterId AS VARCHAR(50)
DECLARE @Longitude AS VARCHAR(50)
DECLARE @Latitude AS VARCHAR(50)
DECLARE @Po_ErrNo AS INT
SET @Po_ErrNo=0

BEGIN
	BEGIN TRANSACTION T1
	
	DELETE FROM WS2CS_SalesOrderHeader_NewRetailer WHERE DownloadFlag='Y'
	
	CREATE TABLE #ProductPrice
	(
		Prdid		INT, 
		PrdBatid	INT,
		PriceId		INT,
		MRP			NUMERIC(18,6)
	)
	
	CREATE TABLE #TEMPCHECK
	(
		OrderNo	NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		Cnt			INT
	)
	
	UPDATE A SET A.RouteCode=RM.RMCODE FROM WS2CS_SalesOrderHeader_NewRetailer A (NOLOCK)
	INNER JOIN Salesman SM (NOLOCK) ON A.SalesmanCode=SM.SMCode 		
	INNER JOIN SalesmanMarket SMM (NOLOCK) ON SMM.SMId=SM.SMId 
	INNER JOIN RouteMaster RM(NOLOCK) ON RM.RMId=SMM.RMId 
	INNER JOIN RetailerMarket RM1(NOLOCK) ON RM1.RMId=RM.RMId
	INNER JOIN Retailer R (nolock) ON R.CmpRtrCode=A.CustomerCode and RM1.RtrId=R.RtrId 
	WHERE ISNULL(CustomerCode,'')=@CmpRtrCode
		
	SELECT DISTINCT C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) OrderNo,
	C.SalesmanCode,C.RouteCode,C.CustomerCode,CONVERT(VARCHAR(10),C.PostingDateTime,121) OrderDt  INTO #ORDERDETAILS
	FROM WS2CS_SalesOrderHeader_NewRetailer C 
	INNER JOIN WS2CS_SalesOrderDetail_NewRetailer CP	ON C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) =CP.DocumentPrefix+CAST(CP.DocumentNumber AS VARCHAR(10))  --AND C.SfaOrderNo=CP.SfaOrderNo 
	INNER JOIN Retailer R (NOLOCK) ON R.CmpRtrCode=C.CustomerCode 
	WHERE ISNULL(CustomerCode,'')=@CmpRtrCode

	SELECT DISTINCT C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) OrderNo,
	ItemCode AS ProdCode,CAST('' AS VARCHAR(100)) AS ProdBatchCode,UnitsOfMeasure AS UomCode,ItemQuantity AS OrderQty,TotalLineAmount AS OrderValue
	INTO #WS2CS_SalesOrderDetail_NewRetailer
	FROM WS2CS_SalesOrderDetail_NewRetailer C WHERE DownLoadFlag='D' 
	AND C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) IN(SELECT OrderNo FROM #ORDERDETAILS)
	
	SELECT B.PrdId,PrdCCode,MAX(PrdBatId) AS PrdBatId INTO #TempBatDt FROM #WS2CS_SalesOrderDetail_NewRetailer A 
	INNER JOIN Product B (NOLOCK) ON A.ProdCode=B.PrdCCode 
	INNER JOIN ProductBatch C (NOLOCK) ON C.PrdId=B.PrdId 
	GROUP BY B.PrdId,PrdCCode
	
	UPDATE A SET A.ProdBatchCode=PB.PrdBatCode FROM #WS2CS_SalesOrderDetail_NewRetailer A 
	INNER JOIN #TempBatDt B ON A.ProdCode=B.PrdCCode 
	INNER JOIN ProductBatch PB ON PB.PrdBatId=B.PrdBatId AND PB.PrdId=PB.PrdId 
		
	
	SELECT OrderNo INTO #OrderNo FROM  
	#ORDERDETAILS GROUP BY OrderNo HAVING COUNT(OrderNo)>1
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  1,'SalesOrderHeader','WS2CS_SalesOrderHeader_NewRetailer','Duplicate Order details available for '+OrderNo FROM  
	#ORDERDETAILS GROUP BY OrderNo HAVING COUNT(OrderNo)>1
	
	SELECT UomCode INTO #TempBaseUOM FROM UomGroup UG (NOLOCK) 
	INNER JOIN UomMaster UM (NOLOCK) ON UG.UomId=UM.UomId WHERE UG.BaseUom='Y'

	DECLARE CUR_Import CURSOR FOR
	SELECT DISTINCT OrderNo,SalesmanCode,RouteCode,CustomerCode,OrderDt From #ORDERDETAILS 
	 ORDER BY OrderDt ASC
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalesmanCode,@RouteCode,@RetailerCode,@OrderDate 
	While @@Fetch_Status = 0
	BEGIN 
		
		SET @OrdPrdCnt=0
		SET @ImpOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0 
	
 		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking(NOLOCK) WHERE DocRefNo = @OrdKeyNo)
		BEGIN 
			IF NOT EXISTS (SELECT RtrId FROM Retailer(NOLOCK) WHERE LTRIM(RTRIM(CmpRtrCode)) = @RetailerCode)-- AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 1,'WS2CS_SalesOrderHeader_NewRetailer','CustomerCode','Retailer Does Not Exists for the Order ' + @OrdKeyNo
			END		
			ELSE
			BEGIN
					SELECT @Rtrid= RtrId FROM Retailer(NOLOCK) WHERE LTRIM(RTRIM(CmpRtrCode)) = @RetailerCode
			END
			
			SELECT @RtrShipId=(
			SELECT top 1 RS.RtrShipId FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid 
			WHERE  R.RtrId=@RtrId)
			
			IF ISNULL(@RtrShipId,0)=0
			BEGIN
				SET @RtrShipId=0
			END
			
			IF ISNULL(@RtrShipId,0)=0
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT  2,'WS2CS_SalesOrderHeader_NewRetailer','CustomerCode','Retailer Shipping Address Does Not Exists for the Order ' + @OrdKeyNo 
			END 
			
			IF NOT EXISTS (SELECT RMID FROM RouteMaster(NOLOCK) WHERE LTRIM(RTRIM(RMCode)) = @RouteCode AND RMstatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 3,'WS2CS_SalesOrderHeader_NewRetailer','RouteCode','Market Does Not Exists for the Order ' + @OrdKeyNo 
			END
			ELSE
			BEGIN
				SELECT @MktId=RMID FROM RouteMaster(NOLOCK) WHERE LTRIM(RTRIM(RMCode)) = @RouteCode
			END
			
			IF NOT EXISTS (SELECT SMId FROM Salesman(NOLOCK) WHERE LTRIM(RTRIM(SMCode)) = @SalesmanCode AND Status = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 4,'WS2CS_SalesOrderHeader_NewRetailer','DistrSalesmanCode','Salesman Does Not Exists for the Order ' + @OrdKeyNo  
			END
			ELSE
			BEGIN
				 SELECT @Smid=SMId FROM Salesman(NOLOCK) WHERE LTRIM(RTRIM(SMCode)) = @SalesmanCode
			END			
			
			--SELECT @lError,'T1'
			IF NOT EXISTS (SELECT * FROM SalesManMarket(NOLOCK) WHERE RMID = @MktId AND SMID = @Smid)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 5,'WS2CS_SalesOrderHeader_NewRetailer','DistrSalesmanCode','Market Not Maped with the Salesman for the Order ' + @OrdKeyNo 
			END
			
			IF EXISTS(SELECT ProdCode FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE ProdCode NOT IN(SELECT PrdCCode FROM PRODUCT ) AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 6,'#WS2CS_SalesOrderDetail_NewRetailer','ProdCode',ProdCode+' Product Code does not Exists for the Order ' + @OrdKeyNo 
				FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE ProdCode NOT IN(SELECT PrdCCode FROM PRODUCT) AND OrderNo=@OrdKeyNo				
			END 

			IF EXISTS(SELECT ProdCode FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE ProdBatchCode NOT IN(SELECT CmpBatCode FROM ProductBatch(NOLOCK)) AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 6,'#WS2CS_SalesOrderDetail_NewRetailer','ProdBatchCode',ProdBatchCode+' ProductBatch Code does not Exists for the Order ' + @OrdKeyNo 
				FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE ProdBatchCode NOT IN(SELECT CmpBatCode FROM ProductBatch(NOLOCK)) AND OrderNo=@OrdKeyNo				
			END 			
			
 
			IF EXISTS(SELECT ProdCode FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE OrderQty=0 AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT  8,'#WS2CS_SalesOrderDetail_NewRetailer','ProdCode',ProdCode+' Order Quantity is Zero for the Order ' + @OrdKeyNo 
				FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE OrderQty=0 AND OrderNo=@OrdKeyNo		
			END  
			
			IF EXISTS(SELECT ProdCode FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE ISNULL(UomCode,'')='' AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT  10,'#WS2CS_SalesOrderDetail_NewRetailer','UomCode',ProdCode+' Uom is Null for the Order ' + @OrdKeyNo 
				FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE ISNULL(UomCode,'')='' AND OrderNo=@OrdKeyNo
			END  		 

			IF EXISTS(SELECT ProdCode FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE ISNULL(UPPER(LTRIM(RTRIM(UomCode))),'') 
			NOT IN (SELECT UomCode FROM #TempBaseUOM)  AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 9,'#WS2CS_SalesOrderDetail_NewRetailer','UomCode',ProdCode+' Uom does not Exists for the Order ' + @OrdKeyNo  
				FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE ISNULL(UomCode,'') 
				NOT IN (SELECT UomCode FROM #TempBaseUOM) AND OrderNo=@OrdKeyNo 
			END
  
			IF EXISTS(SELECT * from #WS2CS_SalesOrderDetail_NewRetailer WHERE NOT EXISTS(
			SELECT Prdccode	FROM Product P (NOLOCK) 
			INNER JOIN #WS2CS_SalesOrderDetail_NewRetailer I ON I.ProdCode=P.Prdccode
			INNER JOIN UOMMaster UM ON UM.UomCode=I.UomCode
			INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND UM.Uomid=U.Uomid)
			and OrderNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 10,'#WS2CS_SalesOrderDetail_NewRetailer','UomCode',ProdCode+ ' UOM does not exists for the product ' + @OrdKeyNo 
				FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE NOT EXISTS(
				SELECT Prdccode	FROM Product P (NOLOCK) 
				INNER JOIN #WS2CS_SalesOrderDetail_NewRetailer I ON I.ProdCode=P.Prdccode
				INNER JOIN UOMMaster UM ON UM.UomCode=I.UomCode
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND UM.Uomid=U.Uomid)
				and OrderNo=@OrdKeyNo
							
			END 
			
			SET @GetKeyStr=''  
			SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('OrderBooking','OrderNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
				IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
				BEGIN  
					SET @lError = 1
					INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
					SELECT 11,'#WS2CS_SalesOrderDetail_NewRetailer','OrderNo','Ordered Key No not generated for ORder'+@OrdKeyNo  
					BREAK  
				END
				SELECT @lError,@OrdKeyNo
				IF @lError = 0  
				BEGIN
					--SELECT @Remarks=ISNULL(Remarks,'') FROM WS2CS_SalesOrderHeader_NewRetailer WHERE OrderNo=@OrdKeyNo 
					SET @Remarks=''
					
					INSERT INTO OrderBooking(  
					OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,RtrId,OrdType,  
					Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,RndOffValue,TotalAmount,Status,  
					Availability,LastModBy,LastModDate,AuthId,AuthDate,PDADownLoadFlag,Upload)  
					SELECT @GetKeyStr,CONVERT(DATETIME,@OrderDate,121),  
					CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
					0,@OrdKeyNo,0, @Smid AS Smid,  
					@MktId AS RmId,@RtrId AS RtrId,0 as OrdType,0 AS Priority,0 AS FillAllPrd,0 AS ShipTo,  
					@RtrShipId AS RtrShipId,@Remarks AS Remarks,0  AS RoundOff,0 AS RndOffValue,  
					0 AS TotalAmount,0 AS Status,1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
					1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),0,0 
			
				--DETAILS 
					DELETE FROM #ProductPrice
					INSERT INTO #ProductPrice	
					SELECT P.Prdid,PB.PrdBatid,MAX(PriceId) AS PriceId ,PrdBatDetailValue AS MRP
					FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
					INNER JOIN #WS2CS_SalesOrderDetail_NewRetailer I ON I.ProdCode=P.Prdccode AND I.ProdBatchCode=PB.CmpBatCode
					INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid
							AND   PBD.SLNo=1   
					WHERE OrderNo=@OrdKeyNo and PBD.DefaultPrice=1
					GROUP BY P.Prdid,PB.PrdBatid,PrdBatDetailValue
				
					INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,ConvFact2,TotalQty,BilledQty,Rate,
													  MRP,GrossAmount,PriceId,Availability,LastModBy,LastModDate,AuthId,AuthDate,SlNo)  
					SELECT @GetKeyStr,Prdid,Prdbatid,UomID,SUM(OrderQty),ConversionFactor,0,0,0,SUM(OrderQty*ConversionFactor),0,
					 Rate ,MRP,SUM(GrossAmount)GrossAmount,PriceId,
					1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
					1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),LineId
					FROM ( 
					SELECT  P.Prdid,PB.Prdbatid,U.UomID,OrderQty,u.ConversionFactor,  
					PBD.PrdBatDetailValue Rate,PP.Mrp,(PBD.PrdBatDetailValue*(OrderQty*ConversionFactor)) as GrossAmount,PBD.PriceId,ROW_Number()OVER(ORder by P.Prdid)LineId
					FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
					INNER JOIN #WS2CS_SalesOrderDetail_NewRetailer I ON I.ProdCode=P.Prdccode  AND I.ProdBatchCode=PB.CmpBatCode
					INNER JOIN UOMMaster UM ON UM.UomCode=I.UOMCode
					INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND UM.Uomid=U.Uomid
					INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId
					INNER JOIN #ProductPrice PP ON PP.Prdid=P.Prdid  AND PP.Prdbatid=PB.Prdbatid
					INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid AND PBD.Prdbatid=PP.Prdbatid  AND PP.Priceid=PBD.PriceId
							   AND BC.slno=PBD.SLNo AND BC.SelRte=1  
					WHERE OrderNo=@OrdKeyNo
					)A
					GROUP BY Prdid,Prdbatid,UomID,ConversionFactor,Rate,MRP,PriceId,LineId
					ORDER BY LineId
				 
					UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  
					FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X  ON X.OrderNo=OB.OrderNo   


					  INSERT INTO #TEMPCHECK 
					  SELECT OrderNo,Count(ProdCode)Cnt 	
					  FROM(	  
					  SELECT DISTINCT OrderNo,ProdCode,ProdBatchCode
					  FROM #WS2CS_SalesOrderDetail_NewRetailer WHERE OrderNo=@OrdKeyNo
					  )A GROUP BY OrderNo
					  			
					  SELECT @OrdPrdCnt=ISNULL(Count(PRDID),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
					  SELECT @ImpOrdPrdCnt=ISNULL(Cnt,0) FROM #TEMPCHECK (NOLOCK) WHERE OrderNo=@OrdKeyNo
			
						IF @OrdPrdCnt=@ImpOrdPrdCnt  
						BEGIN 
							UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
							UPDATE WS2CS_SalesOrderDetail_NewRetailer SET DownLoadFlag='Y' WHERE DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) = @OrdKeyNo 
							UPDATE WS2CS_SalesOrderHeader_NewRetailer SET DownLoadFlag='Y' WHERE DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) = @OrdKeyNo 
						END
						ELSE
						BEGIN
							SET @lError = 1
							INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
							SELECT 12,'WS2CS_SalesOrderDetail_NewRetailer','OrderNo','Imported Ordered Product Number count does not match with Processed Order ' + @OrdKeyNo  
							DELETE FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr  
							DELETE FROM ORDERBOOKING WHERE OrderNo=@GetKeyStr 
							DELETE FROM  ORDERBOOKING WHERE OrderNo NOT IN (SELECT OrderNo FROM ORDERBOOKINGPRODUCTS) AND OrderNo=@GetKeyStr
						END   
				END
			END
			ELSE
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc) 
				SELECT 1,'WS2CS_SalesOrderHeader_NewRetailer','OrderNo', @OrdKeyNo+' Order Already exists' 
			END
			
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalesmanCode,@RouteCode,@RetailerCode,@OrderDate  
	END
	CLOSE CUR_Import
	DEALLOCATE CUR_Import 
 
	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION T1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION T1
	END
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_Validate_WS2CS_SalesReturnProducts' and XTYPE='P')
DROP PROCEDURE Proc_Validate_WS2CS_SalesReturnProducts
GO
/*
 BEGIN TRAN
 delete from ERRORLOG
 select * from import_WS2CS_salesorderheader
 EXEC Proc_Validate_WS2CS_SalesOrderDetail 0
 select * from import_WS2CS_salesorderheader
 SELECT * FROM Import_WS2CS_SalesOrderReturnExchange
 SELECT * FROM PDA_SalesReturn
 SELECT * FROM PDA_SalesReturnProduct
 SELECT  * FROM ERRORLOG
 ROLLBACK TRAN
 */
CREATE PROCEDURE Proc_Validate_WS2CS_SalesReturnProducts
(
	@Po_ErrNo INT OUTPUT
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Validate_WS2CS_SalesReturnProducts
* PURPOSE		: To Validate the Order booking details From PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 27/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  27/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/ 
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0
	DECLARE @SalesReturnNo AS VARCHAR(100)
	DECLARE @RtrId AS INT   
	DECLARE @MktId AS INT
	DECLARE @SrpId AS INT
	
	DECLARE @RetErrNo AS INT
	DECLARE @FullReturn as int
	
	SET @RetErrNo=0
	SET @SalesReturnNo=''
	
	CREATE TABLE #SalesReturn
	(
		ReturnNo		VARCHAR(100)COLLATE DATABASE_DEFAULT
	)
	
	DECLARE @SalesDt AS TABLE
	(
		SalId		BIGINT,
		PrdId		BIGINT,
		PrdBatId	BIGINT,
		BaseQty		INT
	)
	
	BEGIN TRANSACTION T1
	
	DELETE FROM Import_WS2CS_SalesOrderReturnExchange_Track WHERE CONVERT(VARCHAR(10),CreatedDate,121)<=DATEADD(M,-3,CONVERT(VARCHAR(10),GETDATE(),121))
	
	INSERT INTO Import_WS2CS_SalesOrderHeader_Track(TenantCode,LocationCode,RouteCode,SalesmanCode,CustomerCode,
	DocumentType,DocumentPrefix,DocumentNumber,DocumentDate,DeliveryDate,PostingDateTime,
	DocumentAmount,DownloadFlag,CreatedDate)
	SELECT TenantCode,LocationCode,RouteCode,SalesmanCode,CustomerCode,
	DocumentType,DocumentPrefix,DocumentNumber,DocumentDate,DeliveryDate,PostingDateTime,
	DocumentAmount,DownloadFlag,CreatedDate FROM Import_WS2CS_SalesOrderHeader WHERE DownloadFlag='N'
	and DocumentAmount<0
	
	INSERT INTO Import_WS2CS_SalesOrderReturnExchange_Track(TenantCode,LocationCode,DocumentPrefix,
	DocumentNumber,SequenceNumber,ItemTransactionType,ItemCode,UnitsOfMeasure,ItemQuantity,ReasonCode,
	SalesDocumentNo,DownloadFlag,CreatedDate)
	SELECT TenantCode,LocationCode,DocumentPrefix,
	DocumentNumber,SequenceNumber,ItemTransactionType,ItemCode,UnitsOfMeasure,ItemQuantity,ReasonCode,
	SalesDocumentNo,DownloadFlag,CreatedDate FROM Import_WS2CS_SalesOrderReturnExchange WHERE DownloadFlag='N'
	and DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) IN 
	(SELECT DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) FROM Import_WS2CS_SalesOrderHeader_Track WHERE DocumentAmount<0)
	
	UPDATE Import_WS2CS_SalesOrderHeader SET DownloadFlag='D' WHERE DownloadFlag='N'
	UPDATE Import_WS2CS_SalesOrderReturnExchange SET DownLoadFlag='D' WHERE DownloadFlag='N'
	 
	DELETE FROM Import_WS2CS_SalesOrderReturnExchange WHERE DownLoadFlag='Y'
	
	IF NOT EXISTS(SELECT 'X' FROM Import_WS2CS_SalesOrderReturnExchange (NOLOCK) WHERE DownLoadFlag='D')
	BEGIN
		COMMIT TRANSACTION T1
		RETURN
	END
	
	UPDATE A SET A.RouteCode=RM.RMCODE FROM Import_WS2CS_SalesOrderHeader A (NOLOCK)
	INNER JOIN Salesman SM (NOLOCK) ON A.SalesmanCode=SM.SMCode 		
	INNER JOIN SalesmanMarket SMM (NOLOCK) ON SMM.SMId=SM.SMId 
	INNER JOIN RouteMaster RM(NOLOCK) ON RM.RMId=SMM.RMId 
	INNER JOIN RetailerMarket RM1(NOLOCK) ON RM1.RMId=RM.RMId
	INNER JOIN Retailer R (nolock) ON R.CmpRtrCode=A.CustomerCode and RM1.RtrId=R.RtrId 
	WHERE DownLoadFlag='D' and DocumentAmount<0
	
	SELECT DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) AS SalesReturnNo,* 
	INTO #Import_WS2CS_SalesOrderHeader FROM Import_WS2CS_SalesOrderHeader (NOLOCK) WHERE DownLoadFlag='D' 
	and DocumentAmount<0
	
	SELECT DISTINCT DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) SalesReturnNo,
	SalesDocumentNo InvoiceNumber,ItemCode ProdCode,CAST('' AS VARCHAR(100)) ProdBatchCode,ItemQuantity ReturnQty,
	ItemTransactionType StockType,ReasonCode 
	INTO #Import_WS2CS_SalesOrderReturnExchangeTemp from Import_WS2CS_SalesOrderReturnExchange (NOLOCK)
	WHERE DownLoadFlag='D' AND 	DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) IN 
	(SELECT SalesReturnNo FROM #Import_WS2CS_SalesOrderHeader)
	
	SELECT B.PrdId,PrdCCode,MIN(PrdBatId) AS PrdBatId INTO #TempBatDt FROM #Import_WS2CS_SalesOrderReturnExchangeTemp A 
	INNER JOIN Product B (NOLOCK) ON A.ProdCode=B.PrdCCode 
	INNER JOIN ProductBatch C (NOLOCK) ON C.PrdId=B.PrdId 
	GROUP BY B.PrdId,PrdCCode
	
	UPDATE A SET A.ProdBatchCode=PB.PrdBatCode FROM #Import_WS2CS_SalesOrderReturnExchangeTemp A 
	INNER JOIN #TempBatDt B ON A.ProdCode=B.PrdCCode 
	INNER JOIN ProductBatch PB ON PB.PrdBatId=B.PrdBatId AND PB.PrdId=PB.PrdId 
	
	INSERT INTO #SalesReturn (ReturnNo)
	SELECT SalesReturnNo FROM #Import_WS2CS_SalesOrderHeader
	GROUP BY SalesReturnNo HAVING COUNT(SalesReturnNo)>1
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  1,'SFA Sales Return','PDA_SalesReturn','Duplicate Return details available for '+SalesReturnNo FROM  
	#Import_WS2CS_SalesOrderHeader GROUP BY SalesReturnNo HAVING COUNT(SalesReturnNo)>1
	
		
	INSERT INTO #SalesReturn (ReturnNo)
	SELECT SalesReturnNo FROM #Import_WS2CS_SalesOrderHeader RH WHERE 
	SalesReturnNo IN (
	SELECT Docrefno FROM ReturnHeader WHERE DocRefNo<>''
	UNION 
	SELECT SrNo AS Docrefno FROM PDA_SalesReturn (NOLOCK))
	

	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  1,'SFA Sales Return','PDA_SalesReturn','Duplicate Order details available for '+SalesReturnNo 
	FROM  #Import_WS2CS_SalesOrderHeader RH WHERE SalesReturnNo IN (
	SELECT Docrefno FROM ReturnHeader WHERE DocRefNo<>''
	UNION 
	SELECT SrNo AS Docrefno FROM PDA_SalesReturn (NOLOCK))
	
	
	INSERT INTO #SalesReturn (ReturnNo)
	SELECT DISTINCT SalesReturnNo FROM #Import_WS2CS_SalesOrderHeader A 
	WHERE SalesReturnNo NOT IN (SELECT SalesReturnNo FROM #Import_WS2CS_SalesOrderHeader A (NOLOCK)
		INNER JOIN Salesman SM (NOLOCK) ON A.SalesmanCode=SM.SMCode 		
		INNER JOIN RouteMaster RM(NOLOCK) ON RM.RMCode=A.RouteCode 
		INNER JOIN SalesmanMarket SMM (NOLOCK) ON SMM.SMId=SM.SMId AND RM.RMId=SMM.RMId 
		INNER JOIN Retailer R (nolock) ON R.CmpRtrCode=A.CustomerCode 
		INNER JOIN RetailerMarket RM1(NOLOCK) ON RM1.RMId=RM.RMId AND RM1.RtrId=R.RtrId	
	)
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  2,'SFA Sales Return','PDA_SalesReturn','Salesman/Route/Retailer mapping details not available for '+SalesReturnNo 
	FROM  #Import_WS2CS_SalesOrderHeader A WHERE SalesReturnNo NOT IN (
	SELECT SalesReturnNo FROM #Import_WS2CS_SalesOrderHeader A (NOLOCK)
		INNER JOIN Salesman SM (NOLOCK) ON A.SalesmanCode=SM.SMCode 		
		INNER JOIN RouteMaster RM(NOLOCK) ON RM.RMCode=A.RouteCode 
		INNER JOIN SalesmanMarket SMM (NOLOCK) ON SMM.SMId=SM.SMId AND RM.RMId=SMM.RMId 
		INNER JOIN Retailer R (nolock) ON R.CmpRtrCode=A.CustomerCode 
		INNER JOIN RetailerMarket RM1(NOLOCK) ON RM1.RMId=RM.RMId AND RM1.RtrId=R.RtrId	
	)
	
	INSERT INTO #SalesReturn (ReturnNo)
	SELECT DISTINCT SalesReturnNo FROM #Import_WS2CS_SalesOrderReturnExchangeTemp A 
	WHERE NOT EXISTS( SELECT * FROM Product P (NOLOCK) WHERE A.ProdCode=P.PrdCCode)
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  3,'SFA Sales Return','PDA_SalesReturnProduct','Product/Product Batch details not available for '+SalesReturnNo 
	FROM #Import_WS2CS_SalesOrderReturnExchangeTemp A 
	WHERE NOT EXISTS( SELECT * FROM Product P (NOLOCK) WHERE A.ProdCode=P.PrdCCode)
	
	
	SELECT SalesReturnNo,P.PrdId,PB.PrdBatId,0 PriceId,SUM(ReturnQty) AS ReturnQty,StockType,
	ISNULL(RM.Reasonid,0) aS Reasonid
	INTO #Import_WS2CS_SalesOrderReturnExchange
	FROM #Import_WS2CS_SalesOrderReturnExchangeTemp A (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON A.ProdCode=P.PrdCCode
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdBatCode=A.ProdBatchCode AND PB.PrdId=P.PrdId
	LEFT OUTER JOIN ReasonMaster RM ON RM.REASONCODE=A.ReasonCode
	WHERE NOT EXISTS(SELECT * FROM #SalesReturn B WHERE A.SalesReturnNo=B.ReturnNo)   
	GROUP BY SalesReturnNo,P.PrdId,PB.PrdBatId,StockType,RM.Reasonid
	
	SELECT SalesReturnNo,A.PrdId,A.PrdBatId,MAX(B.PriceId) PriceId INTO #TempPriceDt FROM #Import_WS2CS_SalesOrderReturnExchange A 
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdBatId=A.PrdBatId AND A.PrdId=PB.PrdId 
	INNER JOIN ProductBatchDetails B(NOLOCK) ON A.PrdBatId=B.PrdBatId and DefaultPrice=1
	group by SalesReturnNo,A.PrdId,A.PrdBatId
	
	UPDATE A SET A.PriceId=B.PriceId FROM #Import_WS2CS_SalesOrderReturnExchange a 
	INNER JOIN #TempPriceDt B ON A.SalesReturnNo=B.SalesReturnNo AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
		
	DECLARE CUR_Import CURSOR FOR      
	SELECT DISTINCT SalesReturnNo FROM #Import_WS2CS_SalesOrderHeader A WHERE 
	NOT EXISTS(SELECT * FROM #SalesReturn B WHERE A.SalesReturnNo=B.ReturnNo)     
	OPEN CUR_Import      
	FETCH NEXT FROM CUR_Import INTO @SalesReturnNo
	WHILE @@FETCH_STATUS = 0      
	BEGIN      
		SET @RetErrNo=0	
		SET @FullReturn=0
		DELETE FROM @SalesDt
				
		IF NOT EXISTS(SELECT SalesReturnNo FROM #Import_WS2CS_SalesOrderReturnExchange WHERE SalesReturnNo=@SalesReturnNo)
		BEGIN
		
			SET @RetErrNo=1
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT  3,'SFA Sales Return','PDA_SalesReturn',' Product Details Not Exists for the SalesReturn No ' + @SalesReturnNo 
		END
		
	
			
		IF @RetErrNo=0
		BEGIN
		
			INSERT INTO PDA_SalesReturn (SrNo,SrDate,SalInvNo,RtrId,Mktid,Srpid,ReturnMode,InvoiceType,Status)
			SELECT DISTINCT SalesReturnNo,CONVERT(VARCHAR(10),GETDATE(),121),'' InvoiceNumber,R.RtrId,RM.RMId,SM.SMId,
			@FullReturn,0,0 
			FROM #Import_WS2CS_SalesOrderHeader A (NOLOCK)
			INNER JOIN Salesman SM (NOLOCK) ON A.SalesmanCode=SM.SMCode 		
			INNER JOIN RouteMaster RM(NOLOCK) ON RM.RMCode=A.RouteCode 
			INNER JOIN SalesmanMarket SMM (NOLOCK) ON SMM.SMId=SM.SMId AND RM.RMId=SMM.RMId 
			INNER JOIN Retailer R (nolock) ON R.CmpRtrCode=A.CustomerCode 
			INNER JOIN RetailerMarket RM1(NOLOCK) ON RM1.RMId=RM.RMId 	AND RM1.RtrId=R.RtrId	
			WHERE SalesReturnNo=@SalesReturnNo
					
			INSERT INTO PDA_SalesReturnProduct(SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo,ReasonId)
			SELECT @SalesReturnNo,PrdId,PrdBatId,PriceId,ReturnQty,CASE WHEN StockType=2 THEN 1 WHEN StockType=3 THEN 2 ELSE 3 END,
			'' InvoiceNumber,0,ReasonId From 
			#Import_WS2CS_SalesOrderReturnExchange  A 
			INNER JOIN #Import_WS2CS_SalesOrderHeader B ON A.SalesReturnNo=B.SalesReturnNo 
			WHERE A.SalesReturnNo=@SalesReturnNo
			
			
			UPDATE Import_WS2CS_SalesOrderReturnExchange SET DownLoadFlag = 'Y' Where DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10))=@SalesReturnNo AND DownLoadFlag='D'
			UPDATE Import_WS2CS_SalesOrderHeader SET DownLoadFlag = 'Y' Where DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10))=@SalesReturnNo AND DownLoadFlag='D'
		  
		END

		FETCH NEXT FROM CUR_Import INTO @SalesReturnNo 
	END      
	CLOSE CUR_Import      
	DEALLOCATE CUR_Import   

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION T1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION T1
	END
	
	RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Validate_WS2CS_SalesOrderDetail' AND XTYPE='P')
DROP PROCEDURE Proc_Validate_WS2CS_SalesOrderDetail
GO
/*
BEGIN TRANSACTION 
DELETE FROM ERRORLOG
exec Proc_Validate_WS2CS_SalesOrderDetail 0 
SELECT * FROM ERRORLOG
SELECT * FROM ORDERBOOKING ORDER BY ORDERDATE DESC
SELECT * FROM ORDERBOOKINGPRODUCTS  where orderno in (SELECT orderno FROM ORDERBOOKING where orderdate='2018-08-11')
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Validate_WS2CS_SalesOrderDetail
(
	@Po_ErrNo INT OUTPUT
)
AS      
/*******************************************************************************************
* PROCEDURE		: Proc_Validate_WS2CS_SalesOrderDetail
* PURPOSE		: To Validate the Order booking details From PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 24/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  24/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/ 
DECLARE @OrdKeyNo AS VARCHAR(50)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT
DECLARE @Smid AS INT 
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @RtrShipId AS INT
DECLARE @OrdPrdCnt AS INT
DECLARE @ImpOrdPrdCnt AS INT
DECLARE @OrderDate AS DateTime 
DECLARE @SalesmanCode NVarchar(100)
DECLARE @RouteCode NVarchar(100) 
DECLARE @RetailerCode NVarchar(100)
DECLARE @Remarks NVARCHAR(200)
DECLARE @lError AS INT
DECLARE @LAUdcMasterId AS VARCHAR(50)
DECLARE @LOUdcMasterId AS VARCHAR(50)
DECLARE @Longitude AS VARCHAR(50)
DECLARE @Latitude AS VARCHAR(50)
SET @Po_ErrNo=0

BEGIN
	BEGIN TRANSACTION T1
	
	DELETE FROM Import_WS2CS_SalesOrderHeader_Track WHERE CONVERT(VARCHAR(10),CreatedDate,121)<=DATEADD(M,-3,CONVERT(VARCHAR(10),GETDATE(),121))
	DELETE FROM Import_WS2CS_SalesOrderDetail_Track WHERE CONVERT(VARCHAR(10),CreatedDate,121)<=DATEADD(M,-3,CONVERT(VARCHAR(10),GETDATE(),121))
	
	DELETE FROM Import_WS2CS_SalesOrderDetail WHERE DownloadFlag='Y'
	DELETE FROM Import_WS2CS_SalesOrderHeader  WHERE DownloadFlag='Y' 
	
	SELECT DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) AS OrderNo into #tempORDER 
	from Import_WS2CS_SalesOrderHeader WHERE DocumentAmount>=0
	
	INSERT INTO Import_WS2CS_SalesOrderHeader_Track(TenantCode,LocationCode,RouteCode,SalesmanCode,CustomerCode,
	DocumentType,DocumentPrefix,DocumentNumber,DocumentDate,DeliveryDate,PostingDateTime,
	DocumentAmount,DownloadFlag,CreatedDate)
	SELECT TenantCode,LocationCode,RouteCode,SalesmanCode,CustomerCode,
	DocumentType,DocumentPrefix,DocumentNumber,DocumentDate,DeliveryDate,PostingDateTime,
	DocumentAmount,DownloadFlag,CreatedDate FROM Import_WS2CS_SalesOrderHeader WHERE DownloadFlag='N'
	and DocumentAmount>0 
	AND DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) IN (SELECT OrderNo FROM #tempORDER)

	INSERT INTO Import_WS2CS_SalesOrderDetail_Track(TenantCode,LocationCode,DocumentPrefix,DocumentNumber,
	SequenceNumber,TransactionType,ItemCode,UnitsOfMeasure,ItemQuantity,ItemPrice,PromotionAmount,ItemExciseTax,
	TotalLineAmount,IsFreeGood,DownloadFlag,CreatedDate)		
	SELECT TenantCode,LocationCode,DocumentPrefix,DocumentNumber,
	SequenceNumber,TransactionType,ItemCode,UnitsOfMeasure,ItemQuantity,ItemPrice,PromotionAmount,ItemExciseTax,
	TotalLineAmount,IsFreeGood,DownloadFlag,CreatedDate  FROM Import_WS2CS_SalesOrderDetail 
	WHERE DownloadFlag='N'	AND DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) IN (SELECT OrderNo FROM #tempORDER)
	
	UPDATE Import_WS2CS_SalesOrderHeader SET CustomerCode='' WHERE CustomerCode='Dummy' 
		
	UPDATE Import_WS2CS_SalesOrderHeader SET DownloadFlag='D' WHERE DownloadFlag='N'
	UPDATE Import_WS2CS_SalesOrderDetail SET DownloadFlag='D' WHERE DownloadFlag='N'
	
	UPDATE A SET A.RouteCode=RM.RMCODE FROM Import_WS2CS_SalesOrderHeader A (NOLOCK)
	INNER JOIN Salesman SM (NOLOCK) ON A.SalesmanCode=SM.SMCode 		
	INNER JOIN SalesmanMarket SMM (NOLOCK) ON SMM.SMId=SM.SMId 
	INNER JOIN RouteMaster RM(NOLOCK) ON RM.RMId=SMM.RMId 
	INNER JOIN RetailerMarket RM1(NOLOCK) ON RM1.RMId=RM.RMId
	INNER JOIN Retailer R (nolock) ON R.CmpRtrCode=A.CustomerCode and RM1.RtrId=R.RtrId 
	WHERE DownLoadFlag='D' and DocumentAmount>=0
	
	CREATE TABLE #ProductPrice
	(
		Prdid		INT, 
		PrdBatid	INT,
		PriceId		INT,
		MRP			NUMERIC(18,6)
	)
	
	CREATE TABLE #TEMPCHECK
	(
		OrderNo	NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		Cnt			INT
	)
	
	---ORDER FOR NEW RETAILERS 
	INSERT INTO WS2CS_SalesOrderHeader_NewRetailer(OrderNo,RouteCode,SalesmanCode,CustomerCode,DocumentType,DocumentPrefix,DocumentNumber,
	DocumentDate,DeliveryDate,PostingDateTime,DocumentAmount,DownLoadFlag)
	SELECT DISTINCT DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)),RouteCode,SalesmanCode,CustomerCode,DocumentType,DocumentPrefix,DocumentNumber,
	DocumentDate,DeliveryDate,PostingDateTime,DocumentAmount,DownloadFlag FROM Import_WS2CS_SalesOrderHeader 
			WHERE DownLoadFlag='D' AND ISNULL(CustomerCode,'')=''
			AND DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) IN (SELECT OrderNo FROM #tempORDER)
			
	INSERT INTO WS2CS_SalesOrderDetail_NewRetailer(OrderNo,DocumentPrefix,DocumentNumber,SequenceNumber,TransactionType,ItemCode,
	UnitsOfMeasure,ItemQuantity,ItemPrice,PromotionAmount,ItemExciseTax,TotalLineAmount,IsFreeGood,DownLoadFlag)
	SELECT DISTINCT DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) OrderNo,DocumentPrefix,DocumentNumber,SequenceNumber,TransactionType,ItemCode,
	UnitsOfMeasure,ItemQuantity,ItemPrice,PromotionAmount,ItemExciseTax,TotalLineAmount,IsFreeGood,DownLoadFlag
	FROM Import_WS2CS_SalesOrderDetail	WHERE DownLoadFlag='D' AND DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) IN
	(SELECT DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) FROM Import_WS2CS_SalesOrderHeader 
	WHERE DownLoadFlag='D' AND ISNULL(CustomerCode,'')='')  
	AND DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) IN (SELECT OrderNo FROM #tempORDER)
	
	UPDATE B SET DownLoadFlag='Y' FROM WS2CS_SalesOrderHeader_NewRetailer A 
	INNER JOIN Import_WS2CS_SalesOrderHeader B ON A.OrderNo=B.DocumentPrefix+CAST(B.DocumentNumber AS VARCHAR(10)) 
	WHERE B.DownLoadFlag='D' 
	
	UPDATE B SET DownLoadFlag='Y' FROM WS2CS_SalesOrderDetail_NewRetailer A 
	INNER JOIN Import_WS2CS_SalesOrderDetail B ON A.OrderNo=B.DocumentPrefix+CAST(B.DocumentNumber AS VARCHAR(10)) 
	WHERE B.DownLoadFlag='D' 
	
	
	SELECT DISTINCT C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) OrderNo,
	C.SalesmanCode,C.RouteCode,C.CustomerCode,CONVERT(VARCHAR(10),C.PostingDateTime,121) OrderDt  INTO #ORDERDETAILS
	FROM Import_WS2CS_SalesOrderHeader C 
	INNER JOIN Import_WS2CS_SalesOrderDetail CP	ON C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) =CP.DocumentPrefix+CAST(CP.DocumentNumber AS VARCHAR(10))  --AND C.SfaOrderNo=CP.SfaOrderNo 
	INNER JOIN Retailer R (NOLOCK) ON R.CmpRtrCode=C.CustomerCode 
	WHERE C.DownloadFlag='D'  --AND NewCustomerFlag='Y'
	AND C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) IN (SELECT OrderNo FROM #tempORDER) 

	SELECT DISTINCT C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) OrderNo,
	ItemCode AS ProdCode,CAST('' AS VARCHAR(100)) AS ProdBatchCode,UnitsOfMeasure AS UomCode,ItemQuantity AS OrderQty,TotalLineAmount AS OrderValue
	INTO #Import_WS2CS_SalesOrderDetail
	FROM Import_WS2CS_SalesOrderDetail C WHERE DownLoadFlag='D' 
	AND C.DocumentPrefix+CAST(C.DocumentNumber AS VARCHAR(10)) IN(SELECT OrderNo FROM #ORDERDETAILS)
	
	SELECT B.PrdId,PrdCCode,MAX(PrdBatId) AS PrdBatId INTO #TempBatDt FROM #Import_WS2CS_SalesOrderDetail A 
	INNER JOIN Product B (NOLOCK) ON A.ProdCode=B.PrdCCode 
	INNER JOIN ProductBatch C (NOLOCK) ON C.PrdId=B.PrdId 
	GROUP BY B.PrdId,PrdCCode
	
	UPDATE A SET A.ProdBatchCode=PB.PrdBatCode FROM #Import_WS2CS_SalesOrderDetail A 
	INNER JOIN #TempBatDt B ON A.ProdCode=B.PrdCCode 
	INNER JOIN ProductBatch PB ON PB.PrdBatId=B.PrdBatId AND PB.PrdId=PB.PrdId 
		
	
	SELECT OrderNo INTO #OrderNo FROM  
	#ORDERDETAILS GROUP BY OrderNo HAVING COUNT(OrderNo)>1
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  1,'SalesOrderHeader','Import_WS2CS_SalesOrderHeader','Duplicate Order details available for '+OrderNo FROM  
	#ORDERDETAILS GROUP BY OrderNo HAVING COUNT(OrderNo)>1
	
	SELECT UomCode INTO #TempBaseUOM FROM UomGroup UG (NOLOCK) 
	INNER JOIN UomMaster UM (NOLOCK) ON UG.UomId=UM.UomId WHERE UG.BaseUom='Y'

	DECLARE CUR_Import CURSOR FOR
	SELECT DISTINCT OrderNo,SalesmanCode,RouteCode,CustomerCode,OrderDt From #ORDERDETAILS 
	 ORDER BY OrderDt ASC
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalesmanCode,@RouteCode,@RetailerCode,@OrderDate 
	While @@Fetch_Status = 0
	BEGIN 
		
		SET @OrdPrdCnt=0
		SET @ImpOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0 
	
 		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking(NOLOCK) WHERE DocRefNo = @OrdKeyNo)
		BEGIN 
			IF NOT EXISTS (SELECT RtrId FROM Retailer(NOLOCK) WHERE LTRIM(RTRIM(CmpRtrCode)) = @RetailerCode)-- AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 1,'Import_WS2CS_SalesOrderHeader','CustomerCode','Retailer Does Not Exists for the Order ' + @OrdKeyNo
			END		
			ELSE
			BEGIN
					SELECT @Rtrid= RtrId FROM Retailer(NOLOCK) WHERE LTRIM(RTRIM(CmpRtrCode)) = @RetailerCode
			END
			
			SELECT @RtrShipId=(
			SELECT top 1 RS.RtrShipId FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid 
			WHERE  R.RtrId=@RtrId)
			
			IF ISNULL(@RtrShipId,0)=0
			BEGIN
				SET @RtrShipId=0
			END
			
			IF ISNULL(@RtrShipId,0)=0
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT  2,'Import_WS2CS_SalesOrderHeader','CustomerCode','Retailer Shipping Address Does Not Exists for the Order ' + @OrdKeyNo 
			END 
			
			IF NOT EXISTS (SELECT RMID FROM RouteMaster(NOLOCK) WHERE LTRIM(RTRIM(RMCode)) = @RouteCode AND RMstatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 3,'Import_WS2CS_SalesOrderHeader','RouteCode','Market Does Not Exists for the Order ' + @OrdKeyNo 
			END
			ELSE
			BEGIN
				SELECT @MktId=RMID FROM RouteMaster(NOLOCK) WHERE LTRIM(RTRIM(RMCode)) = @RouteCode
			END
			
			IF NOT EXISTS (SELECT SMId FROM Salesman(NOLOCK) WHERE LTRIM(RTRIM(SMCode)) = @SalesmanCode AND Status = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 4,'Import_WS2CS_SalesOrderHeader','DistrSalesmanCode','Salesman Does Not Exists for the Order ' + @OrdKeyNo  
			END
			ELSE
			BEGIN
				 SELECT @Smid=SMId FROM Salesman(NOLOCK) WHERE LTRIM(RTRIM(SMCode)) = @SalesmanCode
			END			
			
			--SELECT @lError,'T1'
			IF NOT EXISTS (SELECT * FROM SalesManMarket(NOLOCK) WHERE RMID = @MktId AND SMID = @Smid)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 5,'Import_WS2CS_SalesOrderHeader','DistrSalesmanCode','Market Not Maped with the Salesman for the Order ' + @OrdKeyNo 
			END
			
			IF EXISTS(SELECT ProdCode FROM #Import_WS2CS_SalesOrderDetail WHERE ProdCode NOT IN(SELECT PrdCCode FROM PRODUCT ) AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 6,'#Import_WS2CS_SalesOrderDetail','ProdCode',ProdCode+' Product Code does not Exists for the Order ' + @OrdKeyNo 
				FROM #Import_WS2CS_SalesOrderDetail WHERE ProdCode NOT IN(SELECT PrdCCode FROM PRODUCT) AND OrderNo=@OrdKeyNo				
			END 

			IF EXISTS(SELECT ProdCode FROM #Import_WS2CS_SalesOrderDetail WHERE ProdBatchCode NOT IN(SELECT CmpBatCode FROM ProductBatch(NOLOCK)) AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 6,'#Import_WS2CS_SalesOrderDetail','ProdBatchCode',ProdBatchCode+' ProductBatch Code does not Exists for the Order ' + @OrdKeyNo 
				FROM #Import_WS2CS_SalesOrderDetail WHERE ProdBatchCode NOT IN(SELECT CmpBatCode FROM ProductBatch(NOLOCK)) AND OrderNo=@OrdKeyNo				
			END 			
			
 
			IF EXISTS(SELECT ProdCode FROM #Import_WS2CS_SalesOrderDetail WHERE OrderQty=0 AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT  8,'#Import_WS2CS_SalesOrderDetail','ProdCode',ProdCode+' Order Quantity is Zero for the Order ' + @OrdKeyNo 
				FROM #Import_WS2CS_SalesOrderDetail WHERE OrderQty=0 AND OrderNo=@OrdKeyNo		
			END  
			
			IF EXISTS(SELECT ProdCode FROM #Import_WS2CS_SalesOrderDetail WHERE ISNULL(UomCode,'')='' AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT  10,'#Import_WS2CS_SalesOrderDetail','UomCode',ProdCode+' Uom is Null for the Order ' + @OrdKeyNo 
				FROM #Import_WS2CS_SalesOrderDetail WHERE ISNULL(UomCode,'')='' AND OrderNo=@OrdKeyNo
			END  		 

			IF EXISTS(SELECT ProdCode FROM #Import_WS2CS_SalesOrderDetail WHERE ISNULL(UPPER(LTRIM(RTRIM(UomCode))),'') 
			NOT IN (SELECT UomCode FROM #TempBaseUOM)  AND OrderNo=@OrdKeyNo )
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 9,'#Import_WS2CS_SalesOrderDetail','UomCode',ProdCode+' Uom does not Exists for the Order ' + @OrdKeyNo  
				FROM #Import_WS2CS_SalesOrderDetail WHERE ISNULL(UomCode,'') 
				NOT IN (SELECT UomCode FROM #TempBaseUOM) AND OrderNo=@OrdKeyNo 
			END
  
			IF EXISTS(SELECT * from #Import_WS2CS_SalesOrderDetail WHERE NOT EXISTS(
			SELECT Prdccode	FROM Product P (NOLOCK) 
			INNER JOIN #Import_WS2CS_SalesOrderDetail I ON I.ProdCode=P.Prdccode
			INNER JOIN UOMMaster UM ON UM.UomCode=I.UomCode
			INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND UM.Uomid=U.Uomid)
			and OrderNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT 10,'#Import_WS2CS_SalesOrderDetail','UomCode',ProdCode+ ' UOM does not exists for the product ' + @OrdKeyNo 
				FROM #Import_WS2CS_SalesOrderDetail WHERE NOT EXISTS(
				SELECT Prdccode	FROM Product P (NOLOCK) 
				INNER JOIN #Import_WS2CS_SalesOrderDetail I ON I.ProdCode=P.Prdccode
				INNER JOIN UOMMaster UM ON UM.UomCode=I.UomCode
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND UM.Uomid=U.Uomid)
				and OrderNo=@OrdKeyNo
							
			END 
			
			SET @GetKeyStr=''  
			SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('OrderBooking','OrderNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
				IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
				BEGIN  
					SET @lError = 1
					INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
					SELECT 11,'#Import_WS2CS_SalesOrderDetail','OrderNo','Ordered Key No not generated for ORder'+@OrdKeyNo  
					BREAK  
				END
				SELECT @lError,@OrdKeyNo
				IF @lError = 0  
				BEGIN
					--SELECT @Remarks=ISNULL(Remarks,'') FROM Import_WS2CS_SalesOrderHeader WHERE OrderNo=@OrdKeyNo 
					SET @Remarks=''
					
					INSERT INTO OrderBooking(  
					OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,RtrId,OrdType,  
					Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,RndOffValue,TotalAmount,Status,  
					Availability,LastModBy,LastModDate,AuthId,AuthDate,PDADownLoadFlag,Upload)  
					SELECT @GetKeyStr,CONVERT(DATETIME,@OrderDate,121),  
					CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
					0,@OrdKeyNo,0, @Smid AS Smid,  
					@MktId AS RmId,@RtrId AS RtrId,0 as OrdType,0 AS Priority,0 AS FillAllPrd,0 AS ShipTo,  
					@RtrShipId AS RtrShipId,@Remarks AS Remarks,0  AS RoundOff,0 AS RndOffValue,  
					0 AS TotalAmount,0 AS Status,1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
					1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),0,0 
			
				--DETAILS 
					DELETE FROM #ProductPrice
					INSERT INTO #ProductPrice	
					SELECT P.Prdid,PB.PrdBatid,MAX(PriceId) AS PriceId ,PrdBatDetailValue AS MRP
					FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
					INNER JOIN #Import_WS2CS_SalesOrderDetail I ON I.ProdCode=P.Prdccode AND I.ProdBatchCode=PB.CmpBatCode
					INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid
							AND   PBD.SLNo=1   
					WHERE OrderNo=@OrdKeyNo and PBD.DefaultPrice=1
					GROUP BY P.Prdid,PB.PrdBatid,PrdBatDetailValue
				
					INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,ConvFact2,TotalQty,BilledQty,Rate,
													  MRP,GrossAmount,PriceId,Availability,LastModBy,LastModDate,AuthId,AuthDate,SlNo)  
					SELECT @GetKeyStr,Prdid,Prdbatid,UomID,SUM(OrderQty),ConversionFactor,0,0,0,SUM(OrderQty*ConversionFactor),0,
					 Rate ,MRP,SUM(GrossAmount)GrossAmount,PriceId,
					1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
					1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),LineId
					FROM ( 
					SELECT  P.Prdid,PB.Prdbatid,U.UomID,OrderQty,u.ConversionFactor,  
					PBD.PrdBatDetailValue Rate,PP.Mrp,(PBD.PrdBatDetailValue*(OrderQty*ConversionFactor)) as GrossAmount,PBD.PriceId,ROW_Number()OVER(ORder by P.Prdid)LineId
					FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
					INNER JOIN #Import_WS2CS_SalesOrderDetail I ON I.ProdCode=P.Prdccode  AND I.ProdBatchCode=PB.CmpBatCode
					INNER JOIN UOMMaster UM ON UM.UomCode=I.UOMCode
					INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND UM.Uomid=U.Uomid
					INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId
					INNER JOIN #ProductPrice PP ON PP.Prdid=P.Prdid  AND PP.Prdbatid=PB.Prdbatid
					INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid AND PBD.Prdbatid=PP.Prdbatid  AND PP.Priceid=PBD.PriceId
							   AND BC.slno=PBD.SLNo AND BC.SelRte=1  
					WHERE OrderNo=@OrdKeyNo
					)A
					GROUP BY Prdid,Prdbatid,UomID,ConversionFactor,Rate,MRP,PriceId,LineId
					ORDER BY LineId
				 
					UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  
					FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X  ON X.OrderNo=OB.OrderNo   


					  INSERT INTO #TEMPCHECK 
					  SELECT OrderNo,Count(ProdCode)Cnt 	
					  FROM(	  
					  SELECT DISTINCT OrderNo,ProdCode,ProdBatchCode
					  FROM #Import_WS2CS_SalesOrderDetail WHERE OrderNo=@OrdKeyNo
					  )A GROUP BY OrderNo
					  			
					  SELECT @OrdPrdCnt=ISNULL(Count(PRDID),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
					  SELECT @ImpOrdPrdCnt=ISNULL(Cnt,0) FROM #TEMPCHECK (NOLOCK) WHERE OrderNo=@OrdKeyNo
			
						IF @OrdPrdCnt=@ImpOrdPrdCnt  
						BEGIN 
							UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
							UPDATE Import_WS2CS_SalesOrderDetail SET DownLoadFlag='Y' WHERE DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) = @OrdKeyNo 
							UPDATE Import_WS2CS_SalesOrderHeader SET DownLoadFlag='Y' WHERE DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10)) = @OrdKeyNo 
						END
						ELSE
						BEGIN
							SET @lError = 1
							INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
							SELECT 12,'Import_WS2CS_SalesOrderDetail','OrderNo','Imported Ordered Product Number count does not match with Processed Order ' + @OrdKeyNo  
							DELETE FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr  
							DELETE FROM ORDERBOOKING WHERE OrderNo=@GetKeyStr 
							DELETE FROM  ORDERBOOKING WHERE OrderNo NOT IN (SELECT OrderNo FROM ORDERBOOKINGPRODUCTS) AND OrderNo=@GetKeyStr
						END   
				END
			END
			ELSE
			BEGIN
				SET @lError = 1
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc) 
				SELECT 1,'Import_WS2CS_SalesOrderHeader','OrderNo', @OrdKeyNo+' Order Already exists' 
			END
			
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalesmanCode,@RouteCode,@RetailerCode,@OrderDate  
	END
	CLOSE CUR_Import
	DEALLOCATE CUR_Import 
 
	---Sales Return 
	EXEC Proc_Validate_WS2CS_SalesReturnProducts 0
	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION T1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION T1
	ENd
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_UploadSyncKeys' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_UploadSyncKeys
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	SyncKey 		[Nvarchar](50),
	ModuleName 		[Nvarchar](50),
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='UploadSyncKeys_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_UploadSyncKeys ADD constraint UploadSyncKeys_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='UploadSyncKeys_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_UploadSyncKeys ADD constraint UploadSyncKeys_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='WS2CS_UploadSyncKeysTrack' AND xtype='U')
BEGIN
CREATE TABLE WS2CS_UploadSyncKeysTrack
(
	[SlNo] [numeric](32, 0) IDENTITY(1,1) NOT NULL,
	[TenantCode] [nvarchar](12) NULL,
	[LocationCode] [nvarchar](12) NULL,
	[SyncKey] [nvarchar](50) NULL,
	[ModuleName] [nvarchar](50) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='UploadSyncKeys1_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE [dbo].[WS2CS_UploadSyncKeysTrack] ADD  CONSTRAINT [UploadSyncKeys1_DownloadFlag]  DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='UploadSyncKeys1_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE [dbo].[WS2CS_UploadSyncKeysTrack] ADD  CONSTRAINT [UploadSyncKeys1_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Import_WS2CS_UploadSyncKeys' AND xtype='P')
DROP PROCEDURE Proc_Import_WS2CS_UploadSyncKeys
GO
CREATE PROCEDURE Proc_Import_WS2CS_UploadSyncKeys
(
	@StrXml1 NTEXT,
	@StrXml2 NTEXT,  
	@StrXml3 NTEXT,  
	@StrXml4 NTEXT 
)
AS 
/*******************************************************************************************
* PROCEDURE		: Proc_Import_WS2CS_UploadSyncKeys
* PURPOSE		: To Import Sales Order details From PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 28/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  28/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/
BEGIN
	DECLARE @IDOC1 AS INT 
	DECLARE @IDOC2 AS INT 
	DECLARE @IDOC3 AS INT 
	DECLARE @IDOC4 AS INT  
	DELETE FROM Import_WS2CS_UploadSyncKeys WHERE DownloadFlag='Y'
	
	EXEC SP_XML_PREPAREDOCUMENT @IDOC1 OUTPUT, @StrXml1  


	INSERT INTO Import_WS2CS_UploadSyncKeys
	(  
		TenantCode,
		LocationCode,
		SyncKey,
		ModuleName,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		TenantCode,
		LocationCode,
		SyncKey,
		ModuleName,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@IDOC1,'/UploadSynkeys',2)
	WITH  
	(   
		TenantCode		[Nvarchar](12),
		LocationCode	[Nvarchar](12),
		SyncKey 		[Nvarchar](50),
		ModuleName 		[Nvarchar](50)
	) 
	EXECUTE SP_XML_REMOVEDOCUMENT @IDOC1  
	
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Validate_WS2CS_UploadSyncKeys' AND XTYPE='P')
DROP PROCEDURE Proc_Validate_WS2CS_UploadSyncKeys
GO
/*
BEGIN TRANSACTION 
DELETE FROM ERRORLOG
exec Proc_Validate_WS2CS_UploadSyncKeys 0 
SELECT * FROM ERRORLOG
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Validate_WS2CS_UploadSyncKeys
(
	@Po_ErrNo INT OUTPUT
)
AS      
/*******************************************************************************************
* PROCEDURE		: Proc_Validate_WS2CS_UploadSyncKeys
* PURPOSE		: To Track Upload Key Details From PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 24/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  24/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/ 
SET @Po_ErrNo=0
BEGIN

	DELETE FROM Import_WS2CS_UploadSyncKeys WHERE  DownloadFlag='Y'
	Update A Set A.DownloadFlag='Z'  from Import_WS2CS_UploadSyncKeys A , WS2CS_UploadSyncKeysTrack B where  A.TenantCode=B.TenantCode
	AND A.Synckey =B.SyncKey AND A.ModuleName=B.ModuleName
	
    Delete from Import_WS2CS_UploadSyncKeys where DownloadFlag='Z' 
	INSERT INTO WS2CS_UploadSyncKeysTrack(TenantCode,LocationCode,SyncKey,ModuleName,CreatedDate)
	SELECT TenantCode,LocationCode,SyncKey,ModuleName,CreatedDate FROM Import_WS2CS_UploadSyncKeys(NOLOCK) WHERE DownloadFlag='N'
	
	UPDATE Import_WS2CS_UploadSyncKeys SET DownloadFlag='Y' WHERE DownloadFlag='N'

END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_TransactionHeader' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_TransactionHeader
(
	LogID				[Int],
	TokenValue			[nvarchar](50),
	PostingDateTime		[Datetime],
	ResponseDateTime	[Datetime],
	[Status]			[Tinyint],
	StatusMessage		[nvarchar](400),
	EventType			[Tinyint],
	TransactionType		[nvarchar](50),
	DownloadFlag		[varchar](1),
	CreatedDate			[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='TransactionHeader_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_TransactionHeader ADD constraint TransactionHeader_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='TransactionHeader_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_TransactionHeader ADD constraint TransactionHeader_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_TransactionMessage' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_TransactionMessage
(
	LogID				[Int],
	MessageID			[Int],
	MessageCode			[nvarchar](50),
	MessageDescription	[text],
	DownloadFlag		[varchar](1),
	CreatedDate			[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='TransactionMessage_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_TransactionMessage ADD constraint TransactionMessage_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='TransactionMessage_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_TransactionMessage ADD constraint TransactionMessage_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_TransactionKeyValue' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_TransactionKeyValue
(
	MessageID			[Int],
	SequenceNumber		[Int],
	KeyName				[nvarchar](50),
	KeyValue			[nvarchar](200),
	DownloadFlag		[varchar](1),
	CreatedDate			[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='TransactionKeyValue_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_TransactionKeyValue ADD constraint TransactionKeyValue_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='TransactionKeyValue_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_TransactionKeyValue ADD constraint TransactionKeyValue_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='WS2CS_TransactionHeaderTrack' AND xtype='U')
BEGIN
CREATE TABLE WS2CS_TransactionHeaderTrack
(
	SlNo				[NUMERIC](32,0) IDENTITY(1,1),
	LogID				[Int],
	TokenValue			[nvarchar](50),
	PostingDateTime		[Datetime],
	ResponseDateTime	[Datetime],
	[Status]			[Tinyint],
	StatusMessage		[nvarchar](400),
	EventType			[Tinyint],
	TransactionType		[nvarchar](50),
	CreatedDate			[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='WS2CS_TransactionMessageTrack' AND xtype='U')
BEGIN
CREATE TABLE WS2CS_TransactionMessageTrack
(
	SlNo				[NUMERIC](32,0) IDENTITY(1,1),
	LogID				[Int],
	MessageID			[Int],
	SequenceNumber		[Int],
	MessageCode			[nvarchar](50),
	MessageDescription	[text],
	KeyName				[nvarchar](50),
	KeyValue			[nvarchar](200),
	CreatedDate			[DateTime]
)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Import_WS2CS_TransactionHeader' AND xtype='P')
DROP PROCEDURE Proc_Import_WS2CS_TransactionHeader
GO
CREATE PROCEDURE Proc_Import_WS2CS_TransactionHeader
(
	@StrXml1 NTEXT,
	@StrXml2 NTEXT,  
	@StrXml3 NTEXT,  
	@StrXml4 NTEXT
)
AS 
/*******************************************************************************************
* PROCEDURE		: Proc_Import_WS2CS_TransactionHeader
* PURPOSE		: To Import Sales Order details From PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 28/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  28/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/
BEGIN
	DECLARE @IDOC1 AS INT  
	DECLARE @IDOC2 AS INT  
	DECLARE @IDOC3 AS INT  
	DECLARE @IDOC4 AS INT  
	DELETE FROM Import_WS2CS_TransactionHeader WHERE DownloadFlag='Y'
	
	EXEC SP_XML_PREPAREDOCUMENT @IDOC1 OUTPUT, @StrXml1  
	
	INSERT INTO Import_WS2CS_TransactionHeader
	(  
		LogID,
		TokenValue,
		PostingDateTime,
		ResponseDateTime,
		[Status],
		StatusMessage,
		EventType,
		TransactionType,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		LogID,
		TokenValue,
		PostingDateTime,
		ResponseDateTime,
		[Status],
		StatusMessage,
		EventType,
		TransactionType,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@IDOC1,'/TransactionKeyStatus',2)  
	WITH  
	(   
		LogID				[Int],
		TokenValue			[nvarchar](50),
		PostingDateTime		[Datetime],
		ResponseDateTime	[Datetime],
		[Status]			[Tinyint],
		StatusMessage		[nvarchar](400),
		EventType			[Tinyint],
		TransactionType		[nvarchar](50)
	) 
	EXECUTE SP_XML_REMOVEDOCUMENT @iDOC1  
	
	-----Transaction Message
	EXEC SP_XML_PREPAREDOCUMENT @IDOC2 OUTPUT, @StrXml2  
	
	INSERT INTO Import_WS2CS_TransactionMessage
	(  
		LogID,
		MessageID,
		MessageCode,
		MessageDescription,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		LogID,
		MessageID,
		MessageCode,
		MessageDescription,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@IDOC2,'/TransactionMessage',2)  
	WITH  
	(   
		LogID				[Int],
		MessageID			[Int],
		MessageCode			[nvarchar](50),
		MessageDescription	[text]
	) 
	EXECUTE SP_XML_REMOVEDOCUMENT @IDOC2 
	
	
	-----Transaction Message Key Values
	EXEC SP_XML_PREPAREDOCUMENT @IDOC3 OUTPUT, @StrXml3  
		
	INSERT INTO Import_WS2CS_TransactionKeyValue
	(  
		MessageID,
		SequenceNumber,
		KeyName,
		KeyValue,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		MessageID,
		SequenceNumber,
		KeyName,
		KeyValue,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@IDOC3,'/KeyValues',2)  
	WITH  
	(   
		MessageID			[Int],
		SequenceNumber		[Int],
		KeyName				[nvarchar](50),
		KeyValue			[nvarchar](200)
	) 
	EXECUTE SP_XML_REMOVEDOCUMENT @IDOC3   
	
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Validate_WS2CS_TransactionHeader' AND XTYPE='P')
DROP PROCEDURE Proc_Validate_WS2CS_TransactionHeader
GO
/*
BEGIN TRANSACTION 
DELETE FROM ERRORLOG
exec Proc_Validate_WS2CS_TransactionHeader 0 
SELECT * FROM ERRORLOG
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Validate_WS2CS_TransactionHeader
(
	@Po_ErrNo INT OUTPUT
)
AS      
/*******************************************************************************************
* PROCEDURE		: Proc_Validate_WS2CS_TransactionHeader
* PURPOSE		: To Track Upload Key Details From PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 24/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  24/08/2018   S.Moorthi    CR         CRCRSTPAR0020   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/ 
SET @Po_ErrNo=0
BEGIN
	
	INSERT INTO WS2CS_TransactionHeaderTrack(LogID,TokenValue,PostingDateTime,ResponseDateTime,
	[Status],StatusMessage,EventType,TransactionType,CreatedDate)
	SELECT LogID,TokenValue,PostingDateTime,ResponseDateTime,
	[Status],StatusMessage,EventType,TransactionType,CreatedDate FROM Import_WS2CS_TransactionHeader(NOLOCK) 
	WHERE DownloadFlag='N'
	
	INSERT INTO WS2CS_TransactionMessageTrack(LogID,MessageID,SequenceNumber,MessageCode,
	MessageDescription,KeyName,KeyValue,CreatedDate)
	SELECT LogID,A.MessageID,SequenceNumber,MessageCode,
	MessageDescription,KeyName,KeyValue,A.CreatedDate FROM Import_WS2CS_TransactionMessage A (NOLOCK) 
	INNER JOIN Import_WS2CS_TransactionKeyValue B ON A.MessageID=A.MessageID  
	WHERE B.DownloadFlag='N'
	
	UPDATE Import_WS2CS_TransactionHeader SET DownloadFlag='Y' WHERE DownloadFlag='N'
	UPDATE A SET DownloadFlag='Y' FROM Import_WS2CS_TransactionMessage A (NOLOCK) 
	INNER JOIN Import_WS2CS_TransactionKeyValue B ON A.MessageID=A.MessageID  
	WHERE A.DownloadFlag='N'
	
	UPDATE B SET DownloadFlag='Y' FROM Import_WS2CS_TransactionMessage A (NOLOCK) 
	INNER JOIN Import_WS2CS_TransactionKeyValue B ON A.MessageID=A.MessageID  
	WHERE B.DownloadFlag='N'
	
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_CollectionHeader' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_CollectionHeader
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	CustomerCode	[Nvarchar](25),
	DocumentType	[Nvarchar](12),
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	DocumentDate	[DateTime],
	PostingDateTime	[DateTime],
	DocumentAmount	[Float],
	DivisionCode	[Nvarchar](12),
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='CollectionHeader_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_CollectionHeader ADD constraint CollectionHeader_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='CollectionHeader_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_CollectionHeader ADD constraint CollectionHeader_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_CollectionHeader_Track' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_CollectionHeader_Track
(
	SlNO			INT IDENTITY(1,1),
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	CustomerCode	[Nvarchar](25),
	DocumentType	[Nvarchar](12),
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	DocumentDate	[DateTime],
	PostingDateTime	[DateTime],
	DocumentAmount	[Float],
	DivisionCode	[Nvarchar](12),
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_CollectionDetail' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_CollectionDetail
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	SequenceNumber	[Integer],
	PaymentIndicator[Nvarchar](3),
	CheckNumber		[Nvarchar](25),
	CheckDate		[DateTime],
	BankDetails		[Nvarchar](50),
	BranchDetails	[Nvarchar](50),
	Amount			[Float],
	Comment			[Nvarchar](100),
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='CollectionDetail_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_CollectionDetail ADD constraint CollectionDetail_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='CollectionDetail_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_CollectionDetail ADD constraint CollectionDetail_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_CollectionDetail_Track' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_CollectionDetail_Track
(
	SlNO			INT IDENTITY(1,1),
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	DocumentPrefix 	[Nvarchar](12),
	DocumentNumber	[Integer],
	SequenceNumber	[Integer],
	PaymentIndicator[Nvarchar](3),
	CheckNumber		[Nvarchar](25),
	CheckDate		[DateTime],
	BankDetails		[Nvarchar](50),
	BranchDetails	[Nvarchar](50),
	Amount			[Float],
	Comment			[Nvarchar](100),
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Import_WS2CS_Collection' AND xtype='P')
DROP PROCEDURE Proc_Import_WS2CS_Collection
GO
CREATE PROCEDURE Proc_Import_WS2CS_Collection
(
	@StrXml1 NTEXT,
	@StrXml2 NTEXT,  
	@StrXml3 NTEXT,  
	@StrXml4 NTEXT    
)
AS 
/*******************************************************************************************
* PROCEDURE		: Proc_Import_WS2CS_Collection
* PURPOSE		: To Import Collection Header From PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 24/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  24/08/2018   Amuthakumar P	CR         CRCRSTPAR0019   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/
BEGIN
	DECLARE @IDOC1 AS INT
	DECLARE @IDOC2 AS INT  
	DECLARE @IDOC3 AS INT  
	DECLARE @IDOC4 AS INT  
	  
	DELETE FROM Import_WS2CS_CollectionHeader WHERE DownloadFlag='Y'
		
	EXEC SP_XML_PREPAREDOCUMENT @iDOC1 OUTPUT, @StrXml1  
	-----COLLECTION HEADER
	INSERT INTO Import_WS2CS_CollectionHeader
	(  
		TenantCode,
		LocationCode,
		RouteCode,
		SalesmanCode,
		CustomerCode,
		DocumentType,
		DocumentPrefix,
		DocumentNumber,
		DocumentDate,
		PostingDateTime,
		DocumentAmount,
		DivisionCode,
		DownloadFlag,
		CreatedDate		
	)  
	SELECT 
		TenantCode,
		LocationCode,
		RouteCode,
		SalesmanCode,
		CustomerCode,
		DocumentType,
		DocumentPrefix,
		DocumentNumber,
		DocumentDate,
		PostingDateTime,
		DocumentAmount,
		DivisionCode,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@iDOC1,'/CollectionHeader',2)  
	WITH  
	(   
		TenantCode		[Nvarchar](12),
		LocationCode	[Nvarchar](12),
		RouteCode		[Nvarchar](12),
		SalesmanCode	[Nvarchar](12),
		CustomerCode	[Nvarchar](25),
		DocumentType 	[Nvarchar](12),
		DocumentPrefix 	[Nvarchar](12),
		DocumentNumber	[Integer],
		DocumentDate	[DateTime],
		PostingDateTime	[DateTime],
		DocumentAmount	[Float],
		DivisionCode	[Nvarchar](12)
	)
		EXECUTE SP_XML_REMOVEDOCUMENT @iDOC1 
				
		EXEC SP_XML_PREPAREDOCUMENT @iDOC2 OUTPUT, @StrXml2  
	----- COLLECTION DETAILS 
	INSERT INTO Import_WS2CS_CollectionDetail
	(  
		TenantCode,
		LocationCode,
		DocumentPrefix,
		DocumentNumber,
		SequenceNumber,
		PaymentIndicator,
		CheckNumber,
		CheckDate,
		BankDetails,
		BranchDetails,
		Amount,
		Comment,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		TenantCode,
		LocationCode,
		DocumentPrefix,
		DocumentNumber,
		SequenceNumber,
		PaymentIndicator,
		CheckNumber,
		CheckDate,
		BankDetails,
		BranchDetails,
		Amount,
		Comment,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@iDOC2,'/CollectionDetail',2) 
	WITH  
	(   
		TenantCode		[Nvarchar](12),
		LocationCode	[Nvarchar](12),
		DocumentPrefix 	[Nvarchar](12),
		DocumentNumber	[Integer],
		SequenceNumber	[Integer],
		PaymentIndicator[Nvarchar](3),
		CheckNumber		[Nvarchar](25),
		CheckDate		[DateTime],
		BankDetails		[Nvarchar](50),
		BranchDetails	[Nvarchar](50),
		Amount			[Float],
		Comment			[Nvarchar](100)
	)  
		EXECUTE SP_XML_REMOVEDOCUMENT @iDOC2   
	
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='WS2CS_Prk_SFA_Collection' and XTYPE='U')
BEGIN
CREATE TABLE WS2CS_Prk_SFA_Collection(
	[DistCode]			[nvarchar](50) NULL,
	[CmpCode]			[varchar](10) NULL,	
	[CollectionNo]		[varchar](100) NULL,
	[CollectionMode]	[char](2) NULL,	
	[DistrSalesmanCode]	[varchar](50) NULL,
	[RouteCode]			[varchar](50) NULL,
	[CustomerCode]		[varchar](50) NULL,
	[CollectionDt]		[DATETIME] NULL,
	[CollectionAmt]		[NUMERIC](18,3) NULL,
	[InstrumentNo]		[varchar](50) NULL,
	[InstrumentDt]		[DATETIME] NULL,	
	[RtrBankCode]		[varchar](50),
	[RtrBankBrCode]		[varchar](50),
	[RtrBankName]		[varchar](50),
	[DownLoadFlag]		[varchar](10) NULL,
	[CreatedDate]		[datetime] NULL
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_Validate_WS2CS_CollectionHeader' AND xtype='P')
DROP PROCEDURE Proc_Validate_WS2CS_CollectionHeader
GO
/*
BEGIN TRAN
delete from ERRORLOG
EXEC Proc_Validate_WS2CS_CollectionHeader 0
SELECT * FROM Import_WS2CS_CollectionHeader 
SELECT * FROM Import_WS2CS_CollectionDetail
SELECT * FROM PDA_ReceiptInvoice
SELECT  * FROM ERRORLOG
ROLLBACK TRAN
 */
CREATE PROCEDURE Proc_Validate_WS2CS_CollectionHeader
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE		: Proc_Validate_WS2CS_CollectionHeader
* PURPOSE		: To validate the downloaded Collection Details from Console
* CREATED		: AMUTHAKUMAR P
* CREATED DATE	: 28/08/2018
* MODIFIED
* DATE       AUTHOR			CR/BZ	USER STORY ID       DESCRIPTION                         
***************************************************************************************************
 28/08/2018	AMUTHAKUMAR P	CR	   CRCRSTPAR0019		Collection Details Download
***************************************************************************************************/
SET NOCOUNT ON
BEGIN
DECLARE @lError AS INT        
DECLARE @CollectionNo AS NVARCHAR(100)
DECLARE @CollectionDt AS DATETIME
DECLARE @CollectionAmt AS NUMERIC(18,2)
DECLARE @Salid AS INT
DECLARE @Salinvno AS VARCHAR(25)
DECLARE @Salinvdate AS DATETIME
DECLARE @PendingAmt AS NUMERIC(18,2)
DECLARE @InvRcpMode as int
DECLARE @AvailAmt as numeric(18,2)
DECLARE @BnkBrCode as varchar(100)
DECLARE @BnkBrId as int
DECLARE @BnkId as int
DECLARE @InstrumentNo as nvarchar(100)
DECLARE @DistBank as INT
DECLARE @DistBranch AS INT
DECLARE @RtrCode AS VARCHAR(100)

	SET @Po_ErrNo=0
	
	CREATE TABLE #CollectionToAvoid
	(
		CollectionNo		VARCHAR(100) COLLATE DATABASE_DEFAULT
	)
	
	CREATE  TABLE #PDA_ReceiptInvoiceSplitActual
	(
		Salid int,
		CollectionNo nvarchar(125)COLLATE DATABASE_DEFAULT,
		Salinvno varchar(50),
		Salinvdate datetime,
		invrcpdate datetime,
		CollectionAmt numeric(18,2),
		InstrumentNo nvarchar(200)COLLATE DATABASE_DEFAULT,
		BnkBrid int,
		InvRcpMode int
	)
	
	DELETE FROM Import_WS2CS_CollectionHeader_Track WHERE CONVERT(VARCHAR(10),CreatedDate,121)<=DATEADD(M,-3,CONVERT(VARCHAR(10),GETDATE(),121))
	DELETE FROM Import_WS2CS_CollectionDetail_Track WHERE CONVERT(VARCHAR(10),CreatedDate,121)<=DATEADD(M,-3,CONVERT(VARCHAR(10),GETDATE(),121))
	
	DELETE FROM Import_WS2CS_CollectionHeader WHERE DownLoadFlag='Y'
	DELETE FROM Import_WS2CS_CollectionDetail WHERE DownLoadFlag='Y'
	
	INSERT INTO Import_WS2CS_CollectionHeader_Track(TenantCode,LocationCode,RouteCode,SalesmanCode,CustomerCode,DocumentType,DocumentPrefix,
				DocumentNumber,DocumentDate,PostingDateTime,DocumentAmount,DivisionCode,DownloadFlag,CreatedDate)
	SELECT TenantCode,LocationCode,RouteCode,SalesmanCode,CustomerCode,DocumentType,DocumentPrefix,
			    DocumentNumber,DocumentDate,PostingDateTime,DocumentAmount,DivisionCode,DownloadFlag,CreatedDate
	FROM Import_WS2CS_CollectionHeader WHERE downloadflag='N'
	
	UPDATE Import_WS2CS_CollectionHeader SET downloadflag='D' WHERE downloadflag='N'
	
	INSERT INTO Import_WS2CS_CollectionDetail_Track(TenantCode,LocationCode,DocumentPrefix,DocumentNumber,SequenceNumber,PaymentIndicator,
				CheckNumber,CheckDate,BankDetails,BranchDetails,Amount,Comment,DownloadFlag,CreatedDate)
	SELECT TenantCode,LocationCode,DocumentPrefix,DocumentNumber,SequenceNumber,PaymentIndicator,CheckNumber,CheckDate,BankDetails,BranchDetails,
				Amount,Comment,DownloadFlag,CreatedDate
	FROM Import_WS2CS_CollectionDetail WHERE downloadflag='N'
	
	UPDATE Import_WS2CS_CollectionDetail SET downloadflag='D' WHERE downloadflag='N'
	
	IF NOT EXISTS(SELECT 'X' FROM Import_WS2CS_CollectionHeader (NOLOCK) WHERE DownLoadFlag='D')
	BEGIN
		RETURN
	END
	
	
	-- CollectionDt,Collectionamt
	SELECT TenantCode,LocationCode,RouteCode,SalesmanCode,CustomerCode,DocumentType,(DocumentPrefix+CAST(DocumentNumber AS VARCHAR(4))) AS CollectionNo ,DocumentDate AS CollectionDt,PostingDateTime,DocumentAmount AS Collectionamt,DivisionCode,DownloadFlag,CreatedDate
	INTO #WS2CS_Prk_SFA_Collection FROM Import_WS2CS_CollectionHeader(NOLOCK) WHERE DownLoadFlag='D'
	
	SELECT TenantCode,LocationCode,(DocumentPrefix+CAST(DocumentNumber AS VARCHAR(4))) AS CollectionNo,SequenceNumber,PaymentIndicator,CheckNumber,CheckDate,ISNULL(BankDetails,'') BankDetails,ISNULL(BranchDetails,'') BranchDetails,Amount,Comment,DownloadFlag,CreatedDate
	INTO #WS2CS_Prk_SFA_CollectionDetail FROM 
	Import_WS2CS_CollectionDetail (NOLOCK) WHERE DownLoadFlag='D'
	
	--WORK AROUND AS PER UAT INSTRUCTION CHANGE BY AMUTHAKUMAR ON 28/09/2018
	UPDATE A  SET CheckDate=  CONVERT(VARCHAR(10),GETDATE(),121) FROM #WS2CS_Prk_SFA_CollectionDetail A (NOLOCK) WHERE PaymentIndicator='C'  
	and ISNULL(CheckNumber,'')<>'' and ISNULL(BankDetails,'')<>'' and ISNULL(CheckDate,'')=''
	--- TILL HERE
	
	--Collection No
	INSERT INTO #CollectionToAvoid (CollectionNo)
	SELECT DISTINCT CollectionNo FROM #WS2CS_Prk_SFA_Collection (NOLOCK) 
	WHERE ISNULL(CollectionNo,'') =''
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  1,'SFA Collection','PDA_ReceiptInvoice','Collection No can not be blank ' 
	FROM #WS2CS_Prk_SFA_Collection (NOLOCK) WHERE ISNULL(CollectionNo,'') =''
	
	--Collection Amount
	INSERT INTO #CollectionToAvoid (CollectionNo)
	SELECT DISTINCT CollectionNo FROM #WS2CS_Prk_SFA_Collection (NOLOCK) 
	WHERE ISNULL(Collectionamt,0) =0
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  1,'SFA Collection','PDA_ReceiptInvoice','Collection amount can not be 0 ' 
	FROM #WS2CS_Prk_SFA_Collection (NOLOCK) WHERE ISNULL(Collectionamt,0) =0
	
	--Collection Mode
	INSERT INTO #CollectionToAvoid (CollectionNo)
	SELECT DISTINCT CollectionNo FROM #WS2CS_Prk_SFA_CollectionDetail (NOLOCK) 
	WHERE ISNULL(PaymentIndicator,'') NOT IN ('D','C','P','E','M')
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  1,'SFA Collection','PDA_ReceiptInvoice','Collection Mode should be D or C or P or E or M for '+ CollectionNo
	FROM #WS2CS_Prk_SFA_CollectionDetail (NOLOCK) WHERE ISNULL(PaymentIndicator,'') NOT IN ('D','C','P','E','M')
	
	--Collection Mode = C
	INSERT INTO #CollectionToAvoid (CollectionNo)
	SELECT DISTINCT  CollectionNo FROM #WS2CS_Prk_SFA_CollectionDetail (NOLOCK) 
	WHERE PaymentIndicator='C' and (ISNULL(CheckNumber,'')='' OR ISNULL(CheckDate,'')='' OR ISNULL(BankDetails,'')='' OR ISNULL(BranchDetails,'')='')
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  2,'SFA Collection','PDA_ReceiptInvoice','InstrumentNo/InstrumentDate/BankCode mandatory columns for cheque collection '+  CollectionNo
	FROM #WS2CS_Prk_SFA_CollectionDetail (NOLOCK) WHERE PaymentIndicator='C'  
	and (ISNULL(CheckNumber,'')='' OR ISNULL(CheckDate,'')='' OR ISNULL(BankDetails,'')='' OR ISNULL(BranchDetails,'')='')

	--CmpRtrCode or RtrCode
	INSERT INTO #CollectionToAvoid (CollectionNo)
	SELECT DISTINCT  CollectionNo FROM #WS2CS_Prk_SFA_Collection 
	WHERE CustomerCode NOT IN (SELECT CmpRtrCode FROM Retailer (NOLOCK))
		
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  3,'SFA Collection','PDA_ReceiptInvoice','Retailer Not Available for Collection '+ CollectionNo
	FROM #WS2CS_Prk_SFA_Collection WHERE CustomerCode NOT IN (SELECT CmpRtrCode FROM Retailer (NOLOCK))
	
	--DocrefNo Duplicate Check
	INSERT INTO #CollectionToAvoid (CollectionNo)
	SELECT  CollectionNo FROM #WS2CS_Prk_SFA_Collection RH WHERE 
	CollectionNo IN (SELECT DocRefNo FROM Receipt (NOLOCK) WHERE DocRefNo<>'' UNION
	 SELECT ReceiptNo AS DocRefNo FROM PDA_ReceiptInvoice (NOLOCK))

	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT  4,'SFA Collection','PDA_ReceiptInvoice','Collection Ref No details already available for '+  CollectionNo 
	FROM #WS2CS_Prk_SFA_Collection RH WHERE CollectionNo IN (SELECT DocRefNo FROM Receipt (NOLOCK) WHERE DocRefNo<>'' UNION
	SELECT ReceiptNo AS DocRefNo FROM PDA_ReceiptInvoice (NOLOCK))
	
	
	DECLARE Cur_CollectionTotal cursor
	FOR SELECT DISTINCT CollectionNo FROM #WS2CS_Prk_SFA_Collection WHERE 
	CollectionNo NOT IN (SELECT CollectionNo FROM #CollectionToAvoid)
	OPEN Cur_CollectionTotal
	FETCH NEXT FROM Cur_CollectionTotal INTO @CollectionNo 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
 			DECLARE Cur_Collection cursor
			FOR SELECT A.CollectionNo,CollectionDt,Collectionamt,
				CASE WHEN PaymentIndicator='D' THEN 1 ELSE 3 END as InvRcpMode,
				CASE WHEN PaymentIndicator='D' THEN '' ELSE B.BankDetails END as RtrBankBrCode,
				CASE WHEN PaymentIndicator='D' THEN '' ELSE CheckNumber END as CheckNumber		
				FROM #WS2CS_Prk_SFA_Collection A INNER JOIN #WS2CS_Prk_SFA_CollectionDetail B
				ON A.CollectionNo = B.CollectionNo
				WHERE A.CollectionNo=@CollectionNo 
				ORDER BY A.CollectionNo,PaymentIndicator ASC
			OPEN Cur_Collection
			FETCH NEXT FROM Cur_Collection INTO @CollectionNo,@CollectionDt,@CollectionAmt,@InvRcpMode,@BnkBrCode,@InstrumentNo
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @lError = 0 
				
				--- Commented by Amuthakumar on 01/10/2018 --- No Bank and Brach details given at the Time of Collection
			
				--IF EXISTS (SELECT * FROM #WS2CS_Prk_SFA_Collection WHERE CollectionNo =@CollectionNo AND @InvRcpMode=3 )
				--BEGIN
				
				--	IF NOT EXISTS(SELECT * FROM BankBranch WHERE BnkBrCode=@BnkBrCode)
				--	BEGIN
				--		SET @lError = 1
				--		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				--		SELECT  5,'SFA Collection','PDA_ReceiptInvoice','Bank branch does not exists for '+@CollectionNo
				--	END
				--	ELSE
				--	BEGIN		
						
				--		IF EXISTS(SELECT * FROM BANK A (NOLOCK)	INNER JOIN BankBranch B ON A.BnkId=B.BnkId 
				--		WHERE B.BnkBrCode=@BnkBrCode) --AND BnkName IN (SELECT RtrBankName FROM #WS2CS_Prk_SFA_Collection
				--		--WHERE CollectionNo=@CollectionNo AND InstrumentNo=@InstrumentNo))
				--		BEGIN
				--				SELECT @BnkBrId=B.bnkbrid,@BnkId=A.bnkid FROM BANK A (NOLOCK)	
				--				INNER JOIN BankBranch B ON A.BnkId=B.BnkId WHERE B.BnkBrCode=@BnkBrCode --AND BnkName IN (SELECT RtrBankName FROM #WS2CS_Prk_SFA_Collection
				--				--WHERE CollectionNo=@CollectionNo AND InstrumentNo=@InstrumentNo)
								
				--				SELECT TOP 1 @DistBank=BnkId,@DistBranch=bnkbrid FROM bankbranch WHERE distbank=1
				--		END
				--		ELSE
				--		BEGIN
				--				SET @lError = 1
				--				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				--				SELECT  6,'SFA Collection','PDA_ReceiptInvoice','Bank/branch does not exists for '+@CollectionNo
								
				--				--SELECT @BnkId=bnkid from BankBranch WHERE BnkBrId=@BnkBrId
								
				--		END
				--	END 
				--END
				--ELSE
				--BEGIN
				--	SET @BnkBrId=0
				--	SET @BnkId=0
				--	SET @InstrumentNo=''
				--END 
				---- Till HEre
				
				
				IF @lError=0
				BEGIN
					SET @RtrCode=(SELECT TOP 1 CustomerCode FROM #WS2CS_Prk_SFA_Collection I WHERE I.CollectionNo =@CollectionNo)
				
					DECLARE Cur_Collection_Split cursor
					FOR SELECT DISTINCT SI.Salid,SI.SalInvNo,SI.SalInvDate,
					(SI.SalNetAmt-SI.SalPayAmt-ISNULL(CollectionAmt,0)) AS PendingAmt 
					FROM Retailer R (NOLOCK)
					INNER JOIN (SELECT SalId,SalInvNo,SalInvDate,SalNetAmt,SalPayAmt,RtrId FROM SalesInvoice (NOLOCK) 
					WHERE Dlvsts=4) SI ON R.RtrId=SI.RtrId
					LEFT OUTER JOIN (SELECT SalInvNo,SUM(CollectionAmt) as CollectionAmt FROM 
						#PDA_ReceiptInvoiceSplitActual GROUP BY SalInvNo) P ON P.SalInvNo=SI.SalInvNo WHERE 
						R.CmpRtrCode=@RtrCode and (SI.SalNetAmt-SI.SalPayAmt-isnull(CollectionAmt,0))>0
					ORDER BY si.salid ASC
					OPEN Cur_Collection_Split
					FETCH NEXT FROM Cur_Collection_Split INTO @Salid,@Salinvno,@Salinvdate,@PendingAmt
					WHILE @@FETCH_STATUS = 0
					BEGIN
								
						IF @CollectionAmt>0 
						BEGIN 
							IF (@CollectionAmt-@PendingAmt)>0 
							BEGIN
								INSERT INTO #PDA_ReceiptInvoiceSplitActual
								SELECT @Salid,@CollectionNo,@Salinvno,@Salinvdate,@CollectionDt,@PendingAmt,@InstrumentNo,@BnkBrId,@InvRcpMode
								SET @CollectionAmt=(@CollectionAmt-@PendingAmt) 
							END	
							ELSE		 
							IF (@CollectionAmt-@PendingAmt)=0 
							BEGIN
								INSERT INTO #PDA_ReceiptInvoiceSplitActual
								SELECT @Salid,@CollectionNo,@Salinvno,@Salinvdate,@CollectionDt,@PendingAmt,@InstrumentNo,@BnkBrId,@InvRcpMode
								SET @CollectionAmt=0
							END 
						ELSE	
							IF (@CollectionAmt-@PendingAmt)<0 	 
							BEGIN
								INSERT INTO #PDA_ReceiptInvoiceSplitActual
								SELECT @Salid,@CollectionNo,@Salinvno,@Salinvdate,@CollectionDt,@CollectionAmt,@InstrumentNo,@BnkBrId,@InvRcpMode
								SET @CollectionAmt=0
							END 	
						END	
					FETCH NEXT FROM Cur_Collection_Split INTO @Salid,@Salinvno,@Salinvdate,@PendingAmt
					END
					CLOSE Cur_Collection_Split 
					DEALLOCATE Cur_Collection_Split 
											    
					IF @CollectionAmt>0 --To Raise On Account
					BEGIN
						UPDATE P set CollectionAmt=CollectionAmt+@CollectionAmt from #PDA_ReceiptInvoiceSplitActual P INNER JOIN 
						(SELECT MAX(salid)salid,CollectionNo from #PDA_ReceiptInvoiceSplitActual WHERE CollectionNo=@CollectionNo
						and InvRcpMode=@InvRcpMode group by CollectionNo)B
						on P.Salid=B.salid and P.CollectionNo=B.CollectionNo
					END					
				END
			  
		FETCH NEXT FROM Cur_Collection INTO @CollectionNo,@CollectionDt,@CollectionAmt,@InvRcpMode,@BnkBrCode,@InstrumentNo
		END
		CLOSE Cur_Collection 
		DEALLOCATE Cur_Collection 
		
		IF @lError=0 
		BEGIN
	
			INSERT INTO PDA_ReceiptInvoice(SrpCde,ReceiptNo,BillNumber,ReceiptDate,InvoiceAmount,Balance,ChequeNumber,CashAmount,ChequeAmount,
			DiscAmount,BankId,BranchId,ChequeDate,InvRcpMode,DistBank,DistBankBranch)
			SELECT 	'',CollectionNo,Salinvno,InvRcpDate,0 as InvoiceAmount,0 as Balance,'' AS ChequeNumber,
			SUM(CashAmount),SUM(ChequeAmount),0 as DiscAmount,SUM(Bnkid)Bnkid,sum(BnkBrid)BnkBrid,InvRcpDate,SUM(invrcpmode)invrcpmode,SUM(DistBank)DistBank,SUM(DistBankBranch)DistBankBranch 
			FROM 
			(SELECT InvRcpDate,Salinvno,CollectionNo,SUM(CollectionAmt)CashAmount,0 AS ChequeAmount,0 AS Bnkid,0 as BnkBrid,0 as DistBank,0 as DistBankBranch,0 as invrcpmode
			FROM #PDA_ReceiptInvoiceSplitActual WHERE InvRcpMode=1 and CollectionNo=@CollectionNo  group by Salinvno,CollectionNo,InvRcpDate
			UNION ALL 
			SELECT InvRcpDate,Salinvno,CollectionNo,0 AS CashAmount,sum(CollectionAmt) AS ChequeAmount,@BnkId AS Bnkid,BnkBrId as BnkBrid,@DistBank as DistBank,@DistBranch as DistBankBranch,2 as invrcpmode
			FROM #PDA_ReceiptInvoiceSplitActual WHERE InvRcpMode=3 and CollectionNo=@CollectionNo group by Salinvno,CollectionNo,InvRcpDate,BnkBrId
			)A
			GROUP BY CollectionNo,Salinvno,InvRcpDate

			UPDATE P set ChequeNumber=InstrumentNo  from PDA_ReceiptInvoice P inner join (
			SELECT DISTINCT InstrumentNo,CollectionNo 
			from #PDA_ReceiptInvoiceSplitActual WHERE InvRcpMode=3 and CollectionNo=@CollectionNo)B on P.ReceiptNo=B.CollectionNo
			WHERE InvRcpMode=2
								
			UPDATE A SET A.DownLoadFlag='Y' FROM Import_WS2CS_CollectionHeader A (NOLOCK)
			INNER JOIN PDA_ReceiptInvoice B (NOLOCK) ON A.DocumentPrefix+CAST(A.DocumentNumber AS VARCHAR(4))=B.ReceiptNo 
			WHERE A.DocumentPrefix+CAST(A.DocumentNumber AS VARCHAR(4))=@CollectionNo

		 END	
						 
	FETCH NEXT FROM Cur_CollectionTotal INTO @CollectionNo 
	END
	CLOSE Cur_CollectionTotal 
	DEALLOCATE Cur_CollectionTotal 
	RETURN
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_VisitSummary' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_VisitSummary
(
	[TenantCode] [nvarchar](12) NULL,
	[LocationCode] [nvarchar](12) NULL,
	[RouteCode] [nvarchar](12) NULL,
	[CustomerCode] [nvarchar](25) NULL,
	[TransactionDate] [datetime] NULL,
	[VisitStartDateTime] [datetime] NULL,
	[VisitEndDateTime] [datetime] NULL,
	[VisitSequence] [int] NULL,
	[StartGeoCodeX] [float] NULL,
	[StartGeoCodeY] [float] NULL,
	[TotalVisitTime] [int] NULL,
	[RouteKey] [nvarchar](50) NULL,
	[JourneyDate] [datetime] NULL,
	[ScannedFlag] [nvarchar](12) NULL,
	[EndGeoCodeX] [float] NULL,
	[EndGeoCodeY] [float] NULL,
	[GeoCodeCompliance] [nvarchar](12) NULL,
	[VisitCompliance] [nvarchar](12) NULL,
	[GPSDistance] [nvarchar](12) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='VisitSummary_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_VisitSummary ADD constraint VisitSummary_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='VisitSummary_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_VisitSummary ADD constraint VisitSummary_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_VisitSummary_Track' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_VisitSummary_Track
(
	SlNO				INT IDENTITY(1,1),
	[TenantCode] [nvarchar](12) NULL,
	[LocationCode] [nvarchar](12) NULL,
	[RouteCode] [nvarchar](12) NULL,
	[CustomerCode] [nvarchar](25) NULL,
	[TransactionDate] [datetime] NULL,
	[VisitStartDateTime] [datetime] NULL,
	[VisitEndDateTime] [datetime] NULL,
	[VisitSequence] [int] NULL,
	[StartGeoCodeX] [float] NULL,
	[StartGeoCodeY] [float] NULL,
	[TotalVisitTime] [int] NULL,
	[RouteKey] [nvarchar](50) NULL,
	[JourneyDate] [datetime] NULL,
	[ScannedFlag] [nvarchar](12) NULL,
	[EndGeoCodeX] [float] NULL,
	[EndGeoCodeY] [float] NULL,
	[GeoCodeCompliance] [nvarchar](12) NULL,
	[VisitCompliance] [nvarchar](12) NULL,
	[GPSDistance] [nvarchar](12) NULL,
	[DownloadFlag] [varchar](1) NULL,
	[CreatedDate] [datetime] NULL
)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Import_WS2CS_VisitSummary' AND xtype='P')
DROP PROCEDURE Proc_Import_WS2CS_VisitSummary
GO
CREATE PROCEDURE Proc_Import_WS2CS_VisitSummary
(
	@StrXml1 NTEXT,
	@StrXml2 NTEXT,  
	@StrXml3 NTEXT,  
	@StrXml4 NTEXT  
)
AS 
/*******************************************************************************************
* PROCEDURE		: Proc_Import_WS2CS_VisitSummary
* PURPOSE		: To Import Route Visit Summary details From PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 27/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  27/08/2018   Amuthakumar P	CR         CRCRSTPAR0019   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/
BEGIN
	DECLARE @IDOC1 AS INT
	DECLARE @IDOC2 AS INT  
	DECLARE @IDOC3 AS INT  
	DECLARE @IDOC4 AS INT 
	
	DELETE FROM Import_WS2CS_VisitSummary WHERE DownloadFlag='Y'
	
	EXEC SP_XML_PREPAREDOCUMENT @iDOC1 OUTPUT, @StrXml1  
	-----VISIT SUMMARY
	INSERT INTO Import_WS2CS_VisitSummary
	(  
		TenantCode,
		LocationCode,
		RouteCode,
		CustomerCode,
		TransactionDate,
		VisitStartDateTime,
		VisitEndDateTime,
		VisitSequence,
		StartGeoCodeX,
		StartGeoCodeY,
		TotalVisitTime,
		RouteKey,
		JourneyDate,
		ScannedFlag,
		EndGeoCodeX,
		EndGeoCodeY,
		GeoCodeCompliance,
		VisitCompliance,
		GPSDistance,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		TenantCode,
		LocationCode,
		RouteCode,
		CustomerCode,
		TransactionDate,
		VisitStartDateTime,
		VisitEndDateTime,
		VisitSequence,
		StartGeoCodeX,
		StartGeoCodeY,
		TotalVisitTime,
		RouteKey,
		JourneyDate,
		ScannedFlag,
		EndGeoCodeX,
		EndGeoCodeY,
		GeoCodeCompliance,
		VisitCompliance,
		GPSDistance,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@iDOC1,'/VisitSummary',2)  
	WITH  
	(   
		[TenantCode] [nvarchar](12) ,
		[LocationCode] [nvarchar](12) ,
		[RouteCode] [nvarchar](12) ,
		[CustomerCode] [nvarchar](25) ,
		[TransactionDate] [datetime] ,
		[VisitStartDateTime] [datetime] ,
		[VisitEndDateTime] [datetime] ,
		[VisitSequence] [int] ,
		[StartGeoCodeX] [float] ,
		[StartGeoCodeY] [float] ,
		[TotalVisitTime] [int] ,
		[RouteKey] [nvarchar](50) ,
		[JourneyDate] [datetime] ,
		[ScannedFlag] [nvarchar](12) ,
		[EndGeoCodeX] [float] ,
		[EndGeoCodeY] [float] ,
		[GeoCodeCompliance] [nvarchar](12) ,
		[VisitCompliance] [nvarchar](12) ,
		[GPSDistance] [nvarchar](12)
	) 
	
	EXECUTE SP_XML_REMOVEDOCUMENT @iDOC1  
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='SalesmanVisitedDateTimeDetails' AND xtype='U')
BEGIN
CREATE TABLE SalesmanVisitedDateTimeDetails(
	TenantCode			[Nvarchar](12),
	LocationCode		[Nvarchar](12),
	RouteKey			[Nvarchar](50),
	RouteCode			[Nvarchar](12),
	JourneyDate			[DateTime],
	TransactionDate		[DateTime],
	VisitSequence		[Integer],
	CustomerCode		[Nvarchar](25),
	VisitStartDateTime	[DateTime],
	VisitEndDateTime	[DateTime],
	DocumentType		[Nvarchar](12),
	DocumentPrefix 		[Nvarchar](12),
	StartGeoCodeX		[Float],
	StartGeoCodeY		[Float],
	TotalVisitTime		[Integer],
	DivisionCode		[Nvarchar](12),
	CreatedDate			[DateTime]
) 
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Validate_WS2CS_VisitSummary' AND xtype='P')
DROP PROCEDURE Proc_Validate_WS2CS_VisitSummary
GO
--Exec Proc_Validate_WS2CS_VisitSummary '1,2'
CREATE PROCEDURE Proc_Validate_WS2CS_VisitSummary
(      
@SalRpCode varchar(50)      
)      
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Validate_WS2CS_VisitSummary
* PURPOSE		: To Validate and Insert Visit Summary details From PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 28/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  28/08/2018   Amuthakumar P	CR         CRCRSTPAR0019   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/         
BEGIN    
  
	DELETE FROM Import_WS2CS_VisitSummary WHERE downloadflag='Y'	
	
	DELETE FROM Import_WS2CS_VisitSummary_Track WHERE CONVERT(VARCHAR(10),CreatedDate,121)<=DATEADD(M,-3,CONVERT(VARCHAR(10),GETDATE(),121))
	
	INSERT INTO Import_WS2CS_VisitSummary_Track(TenantCode,LocationCode,RouteKey,RouteCode,JourneyDate,TransactionDate,VisitSequence,CustomerCode,VisitStartDateTime,VisitEndDateTime,
		 ---  DocumentType,DocumentPrefix,StartGeoCodeX,StartGeoCodeY,TotalVisitTime,DivisionCode,DownloadFlag,CreatedDate)
		  StartGeoCodeX,StartGeoCodeY,TotalVisitTime,DownloadFlag,CreatedDate)
	SELECT TenantCode,LocationCode,RouteKey,RouteCode,CONVERT(DATETIME,JourneyDate,126),CONVERT(DATETIME,TransactionDate,126),VisitSequence,CustomerCode,CONVERT(DATETIME,VisitStartDateTime,126),CONVERT(DATETIME,VisitEndDateTime ,126),
		  --- DocumentType,DocumentPrefix,StartGeoCodeX,StartGeoCodeY,TotalVisitTime,DivisionCode,DownloadFlag,GETDATE()
		   StartGeoCodeX,StartGeoCodeY,TotalVisitTime,DownloadFlag,GETDATE()
	FROM Import_WS2CS_VisitSummary
	WHERE downloadflag='N'
	
	UPDATE Import_WS2CS_VisitSummary SET downloadflag='D' WHERE downloadflag='N'
	
	INSERT INTO SalesmanVisitedDateTimeDetails(TenantCode,LocationCode,RouteKey,RouteCode,JourneyDate,TransactionDate,VisitSequence,CustomerCode,VisitStartDateTime,VisitEndDateTime,
		   StartGeoCodeX,StartGeoCodeY,TotalVisitTime,CreatedDate)
	SELECT TenantCode,LocationCode,RouteKey,RouteCode,CONVERT(DATETIME,JourneyDate,126),CONVERT(DATETIME,TransactionDate,126),VisitSequence,CustomerCode,CONVERT(DATETIME,VisitStartDateTime,126),CONVERT(DATETIME,VisitEndDateTime ,126),
		   StartGeoCodeX,StartGeoCodeY,TotalVisitTime,GETDATE()
	FROM Import_WS2CS_VisitSummary
	WHERE downloadflag='D'
	
	UPDATE Import_WS2CS_VisitSummary SET downloadflag='Y' WHERE downloadflag='D'
END 
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_NewCustomerRequest' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_NewCustomerRequest
(
	RequestID		[Integer],
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	PostingDate		[DateTime],
	CustomerName	[Nvarchar](50),
	Address1		[Nvarchar](35),
	Address2		[Nvarchar](35),
	Address3		[Nvarchar](35),
	City			[Nvarchar](20),
	State			[Nvarchar](20),
	Zip				[Nvarchar](10),
	Phone			[Nvarchar](30),
	Fax				[Nvarchar](30),
	Email			[Nvarchar](50),
	ContactPerson	[Nvarchar](50),
	Notes			[Nvarchar](100),
	GeoCodeX		[Float],
	GeoCodeY		[Float],
	CategoryCode1	[Nvarchar](12),
	CategoryCode2	[Nvarchar](12),
	CategoryCode3	[Nvarchar](12),
	HierarchyCode	[Nvarchar](100),
	DateofBirth		[DateTime],
	IDNumber		[Nvarchar](50),
	DocumentType	[Tinyint],
	DocumentPrefix	[Nvarchar](15),
	DocumentNumber	[Integer],
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]

)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='NewCustomerRequest_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_NewCustomerRequest ADD constraint NewCustomerRequest_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='NewCustomerRequest_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_NewCustomerRequest ADD constraint NewCustomerRequest_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_NewCustomerRequest_Track' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_NewCustomerRequest_Track
(
	SlNO			INT IDENTITY (1,1),
	RequestID		[Integer],
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	PostingDate		[DateTime],
	CustomerName	[Nvarchar](50),
	Address1		[Nvarchar](35),
	Address2		[Nvarchar](35),
	Address3		[Nvarchar](35),
	City			[Nvarchar](20),
	State			[Nvarchar](20),
	Zip				[Nvarchar](10),
	Phone			[Nvarchar](30),
	Fax				[Nvarchar](30),
	Email			[Nvarchar](50),
	ContactPerson	[Nvarchar](50),
	Notes			[Nvarchar](100),
	GeoCodeX		[Float],
	GeoCodeY		[Float],
	CategoryCode1	[Nvarchar](12),
	CategoryCode2	[Nvarchar](12),
	CategoryCode3	[Nvarchar](12),
	HierarchyCode	[Nvarchar](100),
	DateofBirth		[DateTime],
	IDNumber		[Nvarchar](50),
	DocumentType	[Tinyint],
	DocumentPrefix	[Nvarchar](15),
	DocumentNumber	[Integer],
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]

)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Import_WS2CS_NewCustomerRequest' AND xtype='P')
DROP PROCEDURE Proc_Import_WS2CS_NewCustomerRequest
GO
CREATE PROCEDURE Proc_Import_WS2CS_NewCustomerRequest
(
	@StrXml1 NTEXT,
	@StrXml2 NTEXT,  
	@StrXml3 NTEXT,  
	@StrXml4 NTEXT 
)
AS 
/*******************************************************************************************
* PROCEDURE		: Proc_Import_WS2CS_NewCustomerRequest
* PURPOSE		: To Import New Customer Request details From PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 27/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  27/08/2018   Amuthakumar P	CR         CRCRSTPAR0019   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/
BEGIN
	DECLARE @IDOC1 AS INT
	DECLARE @IDOC2 AS INT  
	DECLARE @IDOC3 AS INT  
	DECLARE @IDOC4 AS INT   
	DELETE FROM Import_WS2CS_NewCustomerRequest WHERE DownloadFlag='Y'
	
	EXEC SP_XML_PREPAREDOCUMENT @iDOC1 OUTPUT, @StrXml1  
	-----NEW CUSTOMER REQUEST
	INSERT INTO Import_WS2CS_NewCustomerRequest
	(  
		RequestID,
		TenantCode,
		LocationCode,
		RouteCode,
		SalesmanCode,
		PostingDate,
		CustomerName,
		Address1,
		Address2,
		Address3,
		City,
		State,
		Zip,
		Phone,
		Fax,
		Email,
		ContactPerson,
		Notes,
		GeoCodeX,
		GeoCodeY,
		CategoryCode1,
		CategoryCode2,
		CategoryCode3,
		HierarchyCode,
		DateofBirth,
		IDNumber,
		DocumentType,
		DocumentPrefix,
		DocumentNumber,
		DownloadFlag,
		CreatedDate
	)  
	SELECT 
		RequestID,
		TenantCode,
		LocationCode,
		RouteCode,
		SalesmanCode,
		GETDATE(),
		CustomerName,
		Address1,
		Address2,
		Address3,
		City,
		State,
		Zip,
		Phone,
		Fax,
		Email,
		ContactPerson,
		Notes,
		GeoCodeX,
		GeoCodeY,
		CategoryCode1,
		CategoryCode2,
		CategoryCode3,
		HierarchyCode,
		DateofBirth,
		IDNumber,
		DocumentType,
		DocumentPrefix,
		DocumentNumber,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@iDOC1,'/NewCustomer',2)  
	WITH  
	(   
		RequestID		[Integer],
		TenantCode		[Nvarchar](12),
		LocationCode	[Nvarchar](12),
		RouteCode		[Nvarchar](12),
		SalesmanCode	[Nvarchar](12),
		PostingDate		[DateTime],
		CustomerName	[Nvarchar](50),
		Address1		[Nvarchar](35),
		Address2		[Nvarchar](35),
		Address3		[Nvarchar](35),
		City			[Nvarchar](20),
		State			[Nvarchar](20),
		Zip				[Nvarchar](10),
		Phone			[Nvarchar](30),
		Fax				[Nvarchar](30),
		Email			[Nvarchar](50),
		ContactPerson	[Nvarchar](50),
		Notes			[Nvarchar](100),
		GeoCodeX		[Float],
		GeoCodeY		[Float],
		CategoryCode1	[Nvarchar](12),
		CategoryCode2	[Nvarchar](12),
		CategoryCode3	[Nvarchar](12),
		HierarchyCode	[Nvarchar](100),
		DateofBirth		[DateTime],
		IDNumber		[Nvarchar](50),
		DocumentType	[Tinyint],
		DocumentPrefix	[Nvarchar](15),
		DocumentNumber	[Integer]
	) 
	
	EXECUTE SP_XML_REMOVEDOCUMENT @iDOC1  
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id WHERE A.name='PDA_NewRetailer' and 
B.name='PDAFlag' and A.xtype='U')
BEGIN
	ALTER TABLE PDA_NewRetailer ADD PDAFlag VARCHAR(2) DEFAULT ('')
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id WHERE A.name='PDA_NewRetailer' and 
B.name='DateofBirth' and A.xtype='U')
BEGIN
	ALTER TABLE PDA_NewRetailer ADD DateofBirth [DateTime]
END
GO
UPDATE PDA_NewRetailer SET DateofBirth=CONVERT(VARCHAR(10),GETDATE(),121) WHERE DateofBirth IS NULL
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_Validate_WS2CS_NewCustomerRequest' AND xtype='P')
DROP PROCEDURE PROC_Validate_WS2CS_NewCustomerRequest
GO
/*
BEGIN TRAN
DELETE FROM PDAlog
Exec PROC_Validate_WS2CS_NewCustomerRequest '1,2'
SELECT * FROM Import_WS2CS_NewCustomerRequest
SELECT * FROM PDA_NewRetailer
SELECT * FROM PDAlog
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[PROC_Validate_WS2CS_NewCustomerRequest]
(      
@SalRpCode varchar(50)      
)      
AS
/*******************************************************************************************
* PROCEDURE		: PROC_Validate_WS2CS_NewCustomerRequest
* PURPOSE		: To Validate and Insert New Customer details From PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 28/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  28/08/2018   Amuthakumar P	CR         CRCRSTPAR0019   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/     
DECLARE @CustomerCode AS varchar(200) 
DECLARE @CustomerName AS varchar(200)
DECLARE @CategoryCode1 AS varchar(100)
DECLARE @CategoryCode2 AS varchar(100)
DECLARE @lError AS int
DECLARE @CtgName AS nvarchar(200)
DECLARE @ValueClassName AS nvarchar(200)
DECLARE @RtrClassid int
DECLARE @CtgMainid int
DECLARE @CtgLinkid int 
DECLARE @CtgLevelId int
DECLARE @CtgLinkCode AS nvarchar(200)
DECLARE @CtgLevelName AS nvarchar(200)
DECLARE @Cmpid int 
DECLARE @CmpName AS nvarchar(200)
BEGIN      
 BEGIN TRANSACTION T1      
 DELETE FROM Import_WS2CS_NewCustomerRequest WHERE DownloadFlag='Y' 
 	DELETE FROM Import_WS2CS_NewCustomerRequest_Track WHERE CONVERT(VARCHAR(10),CreatedDate,121)<=DATEADD(M,-3,CONVERT(VARCHAR(10),GETDATE(),121))
	INSERT INTO Import_WS2CS_NewCustomerRequest_Track(RequestID,TenantCode,LocationCode,RouteCode,SalesmanCode,PostingDate,CustomerName,Address1,
			 Address2,Address3,City,State,Zip,Phone,Fax,Email,ContactPerson,Notes,GeoCodeX,GeoCodeY,CategoryCode1,CategoryCode2,CategoryCode3,
			 HierarchyCode,DateofBirth,IDNumber,DocumentType,DocumentPrefix,DocumentNumber,DownloadFlag,CreatedDate)
	SELECT RequestID,TenantCode,LocationCode,RouteCode,SalesmanCode,PostingDate,CustomerName,Address1,Address2,Address3,City,State,Zip,Phone,Fax,
			 Email,ContactPerson,Notes,GeoCodeX,GeoCodeY,CategoryCode1,CategoryCode2,CategoryCode3,HierarchyCode,DateofBirth,IDNumber,DocumentType,
			 DocumentPrefix,DocumentNumber,DownloadFlag,CreatedDate
	FROM Import_WS2CS_NewCustomerRequest
	WHERE downloadflag='N'
	
	UPDATE Import_WS2CS_NewCustomerRequest SET DOWNLOADFLAG='D' WHERE DOWNLOADFLAG='N'
	
	
 DECLARE CUR_ImportRetailer Cursor For  
 SELECT DISTINCT '' CustomerCode, CustomerName,CategoryCode1,CategoryCode2 
		From Import_WS2CS_NewCustomerRequest WHERE DownloadFlag='D'   
 OPEN CUR_ImportRetailer      
 FETCH NEXT FROM CUR_ImportRetailer INTO  @CustomerCode,@CustomerName,@CategoryCode1,@CategoryCode2
 While @@Fetch_Status = 0      
 BEGIN      
  SET @lError = 0
    	
  IF NOT EXISTS (SELECT RtrName FROM Retailer WHERE RtrName = @CustomerName )      
   BEGIN   
		--IF NOT EXISTS(SELECT * FROM RetailerCategory WHERE CtgCode=@CategoryCode1)
		--BEGIN
		--	SET @lError = 1      
		--	INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
		--	SELECT '' + @CategoryCode1 + '','New Retailer',@CustomerName,'Reatailer Category1 does not exists'  
		--END
		--IF NOT EXISTS(SELECT * FROM RetailerValueClass WHERE ValueClassCode=@CategoryCode2)
		--BEGIN
		--	SET @lError = 1      
		--	INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
		--	SELECT '' + @CategoryCode2 + '','New Retailer',@CustomerName,'Reatailer Category2 does not exists'  
		--END
	IF @lError=0 
	 BEGIN
		Select @RtrClassid=A.RtrClassId,
			   @ValueClassName=A.ValueClassName,
			   @CtgMainid=B.CtgMainId,
			   @CtgLinkid=B.CtgLinkId,
			   @CtgLevelId=B.CtgLevelId,
			   @CtgLinkCode=B.CtgLinkCode,
			   @CtgName=B.CtgName,
			   @CtgLevelName=C.CtgLevelName,
			   @Cmpid=C.CmpId,
			   @CmpName=D.CmpName 
			FROM RetailerValueClass A,RetailerCategory B,RetailerCategoryLevel C,Company D 
			WHERE A.CtgMainId=B.CtgMainId And B.CtgLevelId=C.CtgLevelId And C.CmpId=D.CmpId
			AND CtgCode=@CategoryCode1 AND a.ValueClassCode=@CategoryCode2
	 
	 END 		
	IF @lError=0 
		BEGIN
		  IF NOT EXISTS (SELECT * FROM PDA_NewRetailer WHERE CustomerName=@CustomerName)
			   BEGIN 
					INSERT INTO PDA_NewRetailer(CustomerCode,CustomerName,Address1,Address2,Address3,City,State,Zip,Phone,Fax,Email,
					RtrTINNo,ContactPerson,Notes,CustomerStatus,CtgCode,CtgName,ValueClassCode,ValueClassName,RtrClassid,CtgMainid,
					CtgLinkid,CtgLevelId,CtgLinkCode,CtgLevelName,Cmpid,CmpName,CrBills,RtrTaxable,RouteId,GeoMainId,GeoLevelName,
					GeoLevel,Longitude,Latitude,RtrMobileNo,DateOfBirth,PDAFlag) 
					SELECT (DocumentPrefix+CAST(DocumentNumber AS VARCHAR(10))) CustomerCode,CustomerName,isnull(Address1,'')Address1,isnull(Address2,'')Address2,
					isnull(Address3,'')Address3,isnull(City,'')City,isnull(State,'')State,isnull(Zip,'')Zip,isnull(Phone,'')Phone,isnull(Fax,'')Fax,isnull(Email,'')Email,
					'' RtrTINNo,isnull(ContactPerson,'')ContactPerson,isnull(Notes,'')Notes,'' AS CustomerStatus,
					isnull(CategoryCode1,'')CategoryCode1,isnull(@CtgName,''),isnull(CategoryCode2,'')CategoryCode2,isnull(@ValueClassName,''),
					ISNULL(@RtrClassid,0),ISNULL(@CtgMainid,0),ISNULL(@CtgLinkid,0),ISNULL(@CtgLevelId,0),ISNULL(@CtgLinkCode,''),ISNULL(@CtgLevelName,''),
					ISNULL(@Cmpid,0),ISNULL(@CmpName,''),0,'' RtrTaxable,0,0,'' GeoLevelName,
					'' GeoLevel,isnull(GeoCodeX,'')GeoCodeX,isnull(GeoCodeY,'')GeoCodeY,''RtrMobileNo,ISNULL(CONVERT(VARCHAR(10),DateOfBirth,121),'') DateOfBirth,'WS' PDAFlag
					FROM Import_WS2CS_NewCustomerRequest WHERE CustomerName=@CustomerName
			   END 	
				UPDATE Import_WS2CS_NewCustomerRequest SET DownloadFlag='Y' WHERE CustomerName=@CustomerName
		 END 
	 END      
  ELSE      
    BEGIN      
	   INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
	   SELECT '' + @CustomerCode + '','New Retailer',@CustomerName,'Retailer Code Already exists'      
    END       
FETCH NEXT FROM CUR_ImportRetailer INTO @CustomerCode,@CustomerName,@CategoryCode1,@CategoryCode2
END      
CLOSE CUR_ImportRetailer      
DEALLOCATE CUR_ImportRetailer     
 IF @@ERROR = 0      
 BEGIN      
	COMMIT TRANSACTION T1      
 END      
 ELSE      
 BEGIN      
	ROLLBACK TRANSACTION T1      
 END      
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_CustomerInventory' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_CustomerInventory
(
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteKey		[Nvarchar](50),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	VisitDate		[DateTime],
	VisitSequence	[Integer],
	CustomerCode	[Nvarchar](25),
	ItemCode		[Nvarchar](50),
	UnitsOfMeasure	[Nvarchar](20),
	TotalQuantity	[Float],
	Location1Qty	[Float],
	Location2Qty	[Float],
	Location3Qty	[Float],
	Location4Qty	[Float],
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='CustomerInventory_DownloadFlag' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_CustomerInventory ADD constraint CustomerInventory_DownloadFlag DEFAULT ('N') FOR [DownloadFlag]
END
GO
IF NOT EXISTS(SELECT * FROM SYSCONSTRAINTS A INNER JOIN SYSOBJECTS B ON A.constid=B.id WHERE B.name='CustomerInventory_CreatedDate' AND B.xtype='D')
BEGIN
ALTER TABLE Import_WS2CS_CustomerInventory ADD constraint CustomerInventory_CreatedDate DEFAULT (getdate()) FOR [CreatedDate]
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Import_WS2CS_CustomerInventory_Track' AND xtype='U')
BEGIN
CREATE TABLE Import_WS2CS_CustomerInventory_Track
(
	SlNO			INT IDENTITY (1,1),
	TenantCode		[Nvarchar](12),
	LocationCode	[Nvarchar](12),
	RouteKey		[Nvarchar](50),
	RouteCode		[Nvarchar](12),
	SalesmanCode	[Nvarchar](12),
	VisitDate		[DateTime],
	VisitSequence	[Integer],
	CustomerCode	[Nvarchar](25),
	ItemCode		[Nvarchar](50),
	UnitsOfMeasure	[Nvarchar](20),
	TotalQuantity	[Float],
	Location1Qty	[Float],
	Location2Qty	[Float],
	Location3Qty	[Float],
	Location4Qty	[Float],
	DownloadFlag	[varchar](1),
	CreatedDate		[DateTime]
)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Import_WS2CS_CustomerInventory' AND xtype='P')
DROP PROCEDURE Proc_Import_WS2CS_CustomerInventory
GO
CREATE PROCEDURE [dbo].[Proc_Import_WS2CS_CustomerInventory]
(
	@StrXml1 NTEXT,
	@StrXml2 NTEXT,  
	@StrXml3 NTEXT,  
	@StrXml4 NTEXT 
)
AS 
/*******************************************************************************************
* PROCEDURE		: Proc_Import_WS2CS_CustomerInventory
* PURPOSE		: To Import Customer Inventory details From PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 24/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  24/08/2018   Amuthakumar P	CR         CRCRSTPAR0019   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/
BEGIN
	DECLARE @IDOC1 AS INT
	DECLARE @IDOC2 AS INT  
	DECLARE @IDOC3 AS INT  
	DECLARE @IDOC4 AS INT    
	DELETE FROM Import_WS2CS_CustomerInventory WHERE DownloadFlag='Y'
	
	EXEC SP_XML_PREPAREDOCUMENT @iDOC1 OUTPUT, @StrXml1  
	-----CUSTOMER INVENTORY
	INSERT INTO Import_WS2CS_CustomerInventory
	(  
		TenantCode,
		LocationCode,
		RouteKey,
		RouteCode,
		SalesmanCode,
		VisitDate,
		VisitSequence,
		CustomerCode,
		ItemCode,
		UnitsOfMeasure,
		TotalQuantity,
		Location1Qty,
		Location2Qty,
		Location3Qty,
		Location4Qty,
		DownloadFlag,
		CreatedDate	
	)  
	SELECT 
		TenantCode,
		LocationCode,
		RouteKey,
		RouteCode,
		SalesmanCode,
		VisitDate,
		VisitSequence,
		CustomerCode,
		ItemCode,
		UnitsOfMeasure,
		TotalQuantity,
		Location1Qty,
		Location2Qty,
		Location3Qty,
		Location4Qty,
		'N' AS DownloadFlag,
		GETDATE()
	FROM OPENXML  
	(@iDOC1,'/CustomerInventory',2)  
	WITH  
	(   
		TenantCode		[Nvarchar](12),
		LocationCode	[Nvarchar](12),
		RouteKey		[Nvarchar](50),
		RouteCode		[Nvarchar](12),
		SalesmanCode	[Nvarchar](12),
		VisitDate		[DateTime],
		VisitSequence	[Integer],
		CustomerCode	[Nvarchar](25),
		ItemCode		[Nvarchar](50),
		UnitsOfMeasure	[Nvarchar](20),
		TotalQuantity	[Float],
		Location1Qty	[Float],
		Location2Qty	[Float],
		Location3Qty	[Float],
		Location4Qty	[Float]
	) 
		EXECUTE SP_XML_REMOVEDOCUMENT @iDOC1  
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='CustomerInventory' AND xtype='U')
BEGIN
CREATE TABLE CustomerInventory(
	[TenantCode] [nvarchar](12),
	[LocationCode] [nvarchar](12),
	[RouteKey] [nvarchar](100),
	[RouteCode] [nvarchar](24),
	[SalesmanCode] [nvarchar](24),
	[VisitDate] [datetime],
	[VisitSequence] [int],
	[CustomerCode] [nvarchar](25),
	[ItemCode] [nvarchar](100),
	[UnitsOfMeasure] [nvarchar](40),
	[TotalQuantity] [Float],
	[Location1Qty] [Float],
	[Location2Qty] [Float],
	[Location3Qty] [Float],
	[Location4Qty] [Float],
	[CreatedDate] [datetime]
)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_Validate_WS2CS_CustomerInventory' AND xtype='P')
DROP PROCEDURE PROC_Validate_WS2CS_CustomerInventory
GO
CREATE PROCEDURE PROC_Validate_WS2CS_CustomerInventory
(
	@SalRpCode AS varchar(100)
)
AS
/*******************************************************************************************
* PROCEDURE		: PROC_Validate_WS2CS_CustomerInventory
* PURPOSE		: To Validate and Insert Customer Inventory details From PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 28/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  28/08/2018   Amuthakumar P	CR         CRCRSTPAR0019   Parle SFA integration to Vxceed server(Phase 2&3)
********************************************************************************************/ 
BEGIN 
	
	DELETE FROM Import_WS2CS_CustomerInventory WHERE DownloadFlag ='Y'
	
	DELETE FROM Import_WS2CS_CustomerInventory_Track WHERE CONVERT(VARCHAR(10),CreatedDate,121)<=DATEADD(M,-3,CONVERT(VARCHAR(10),GETDATE(),121))

	INSERT INTO Import_WS2CS_CustomerInventory_Track(TenantCode,LocationCode,RouteKey,RouteCode,SalesmanCode,VisitDate,VisitSequence,CustomerCode,ItemCode,UnitsOfMeasure,TotalQuantity,Location1Qty,Location2Qty,Location3Qty,Location4Qty,DownloadFlag,CreatedDate)
	SELECT TenantCode,LocationCode,RouteKey,RouteCode,SalesmanCode,VisitDate,VisitSequence,CustomerCode,ItemCode,UnitsOfMeasure,TotalQuantity,Location1Qty,Location2Qty,Location3Qty,Location4Qty,DownloadFlag,GETDATE ()
	FROM Import_WS2CS_CustomerInventory WHERE DownloadFlag ='N' 
	
	UPDATE Import_WS2CS_CustomerInventory SET DownloadFlag ='D' WHERE DownloadFlag ='N'
		
	INSERT INTO CustomerInventory (TenantCode,LocationCode,RouteKey,RouteCode,SalesmanCode,VisitDate,VisitSequence,CustomerCode,ItemCode,UnitsOfMeasure,TotalQuantity,Location1Qty,Location2Qty,Location3Qty,Location4Qty,CreatedDate)
	SELECT TenantCode,LocationCode,RouteKey,RouteCode,SalesmanCode,VisitDate,VisitSequence,CustomerCode,ItemCode,UnitsOfMeasure,TotalQuantity,Location1Qty,Location2Qty,Location3Qty,Location4Qty,GETDATE ()
	FROM Import_WS2CS_CustomerInventory WHERE DownloadFlag ='D'
	 
	UPDATE A SET A.DownloadFlag ='Y' FROM  Import_WS2CS_CustomerInventory A INNER JOIN  CustomerInventory B ON A.CustomerCode =B.CustomerCode 
	AND A.SalesmanCode=B.SalesmanCode Where DownloadFlag ='D'
	
END
GO
--Import Process Till Here
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_ImportValues' AND xtype='P')
DROP PROCEDURE Proc_ImportValues
GO
CREATE PROCEDURE Proc_ImportValues
(
	@TypeId INT,
	@TenantCode varchar(100)='',
	@ModuleName Varchar(200) ='',
	@SyncKey Varchar(500) ='',
	@Count Varchar(100) ='' ,
	@Result  varchar(200) ='' ,
	@TokenID Varchar(500) =''
	
)
AS
/*
/*******************************************************************************************
* PROCEDURE		: Proc_ImportValues
* PURPOSE		: To Validate and Insert Customer Inventory details From PDA Intermediate Database
* CREATED		: RAMESH.K
* CREATED DATE	: 28/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
********************************************************************************************/ 
*/


BEGIN
	IF (@TypeId  = 1)--Import Upload Sync Keys  Flag
	BEGIN
	    exec Proc_Validate_WS2CS_SalesOrderDetail 0

		Update Import_WS2CS_SalesOrderHeader SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_SalesOrderDetail SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_SalesOrderReturnExchange SET DownloadFlag='Y' where DownloadFlag ='N'

		exec Proc_Validate_WS2CS_CollectionHeader 0
		Update Import_WS2CS_CollectionHeader SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_CollectionDetail SET DownloadFlag='Y' where DownloadFlag ='N'

		exec Proc_Validate_WS2CS_CustomerInventory 0
		Update Import_WS2CS_CustomerInventory SET DownloadFlag='Y' where DownloadFlag ='N'

	    exec Proc_Validate_WS2CS_NewCustomerRequest 0
		Update Import_WS2CS_NewCustomerRequest SET DownloadFlag='Y' where DownloadFlag ='N'

		exec Proc_Validate_WS2CS_VisitSummary 0
		Update Import_WS2CS_VisitSummary SET DownloadFlag='Y' where DownloadFlag ='N'
		
		exec Proc_Validate_WS2CS_UploadSyncKeys 0 
		Insert into [WS2CS_UploadSyncKeysLog] (TenantCode,LocationCode,LoggedDate) values 
		                                      (  @TenantCode,@TenantCode,getdate() )
	END
	
	IF (@TypeId  = 2)--Get Sync Keys  Flag
	BEGIN
	SELECT SyncKey FROM WS2CS_UploadSyncKeysTrack where  DownloadFlag='N' AND ModuleName =@ModuleName
	end
	IF (@TypeId  = 3) 
	BEGIN

	  Insert into [WS2CSSyncKeysLog] ( [TenantCode],[LocationCode],[SyncKey],[ModuleName],[TotalCount])  Values 
	                                 (@TenantCode,@TenantCode,@SyncKey ,@ModuleName,@Count)
	 Update WS2CS_UploadSyncKeysTrack set DownloadFlag='Y' where SyncKey=@SyncKey AND ModuleName=@ModuleName AND DownloadFlag='N'

	END 
	IF ( (@TypeId  = 3) AND ( @ModuleName='SalesOrder'))
	BEGIN
		Update Import_WS2CS_SalesOrderDetail SET DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 
		Update Import_WS2CS_SalesOrderHeader  SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 
		Update Import_WS2CS_SalesOrderReturnExchange  SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 
	
		exec Proc_Validate_WS2CS_SalesOrderDetail 0

		Update Import_WS2CS_SalesOrderHeader SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_SalesOrderDetail SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_SalesOrderReturnExchange SET DownloadFlag='Y' where DownloadFlag ='N'
		
	END
	ELSE IF ( (@TypeId  = 3) AND ( @ModuleName='ARCollection'))
	BEGIN
	
		Update Import_WS2CS_CollectionHeader SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 
		Update Import_WS2CS_CollectionDetail SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 

		exec Proc_Validate_WS2CS_CollectionHeader 0

		Update Import_WS2CS_CollectionHeader SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_CollectionDetail SET DownloadFlag='Y' where DownloadFlag ='N'
	
	END

	ELSE IF ( (@TypeId  = 3) AND ( @ModuleName='CustomerInventoryV1'))
	BEGIN
	
		Update Import_WS2CS_CustomerInventory SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 

		exec Proc_Validate_WS2CS_CustomerInventory 0

		Update Import_WS2CS_CustomerInventory SET DownloadFlag='Y' where DownloadFlag ='N'

	END

	ELSE IF ( (@TypeId  = 3) AND ( @ModuleName='NewCustomer'))
	BEGIN

		update Import_WS2CS_NewCustomerRequest SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 

		exec Proc_Validate_WS2CS_NewCustomerRequest 0

		Update Import_WS2CS_NewCustomerRequest SET DownloadFlag='Y' where DownloadFlag ='N'

	END
	ELSE iF ( (@TypeId  = 3) AND ( @ModuleName='VisitSummary'))
	BEGIN
	  
		update Import_WS2CS_VisitSummary   SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 

		exec Proc_Validate_WS2CS_VisitSummary 0

		Update Import_WS2CS_VisitSummary SET DownloadFlag='Y' where DownloadFlag ='N'
	
	END

	ELSE IF  (@TypeId  = 4) 
	BEGIN
	Insert into WS2CSTransactionDetail ([TenantCode],[LocationCode],[ModuleName],TransactionID ,RecordProcessed,[Result],[TokenID] ,[CreatedDate],DownLoadFlag) values
	                                   (@TenantCode,@TenantCode, @ModuleName, @SyncKey,@Count, @Result,@TokenID,getdate() ,'N'  ) 

	END 

	ELSE IF  (@TypeId  = 5) 
	BEGIN
	 
	     Select Max(Loggeddate) from WS2CS_UploadSyncKeysLog  
	    ---Select getdate()-1
	END 

	ELSE IF  (@TypeId  = 6) 
	BEGIN	 
	   Select TenantCode, ModuleName ,TransactionID,TokenID  from WS2CSTransactionDetail  where RecordProcessed > 0  
	END
--	Proc_Validate_WS2CS_SalesOrderDetail
--Proc_Validate_WS2CS_CollectionHeader
--Proc_Validate_WS2CS_VisitSummary
--Proc_Validate_WS2CS_NewCustomerRequest
--Proc_Validate_WS2CS_CustomerInventory
--Proc_Validate_WS2CS_UploadSyncKeys
--Proc_Validate_WS2CS_TransactionHeader
END
GO
IF EXISTS(SELECT * fROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id 
WHERE A.name='Import_WS2CS_CollectionHeader' AND B.name='CustomerCode' AND A.xtype='U' AND [length]=24)
BEGIN
	ALTER TABLE Import_WS2CS_CollectionHeader ALTER COLUMN CustomerCode	[Nvarchar](25)
END
GO
IF EXISTS(SELECT * fROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id 
WHERE A.name='Import_WS2CS_CollectionHeader_Track' AND B.name='CustomerCode' AND A.xtype='U' AND [length]=24)
BEGIN
	ALTER TABLE Import_WS2CS_CollectionHeader_Track ALTER COLUMN CustomerCode [Nvarchar](25)
END
GO
IF EXISTS(SELECT * fROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id 
WHERE A.name='Import_WS2CS_VisitSummary' AND B.name='CustomerCode' AND A.xtype='U' AND [length]=24)
BEGIN
	ALTER TABLE Import_WS2CS_VisitSummary ALTER COLUMN CustomerCode	 [Nvarchar](25)
END
GO
IF EXISTS(SELECT * fROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id 
WHERE A.name='Import_WS2CS_VisitSummary_Track' AND B.name='CustomerCode' AND A.xtype='U' AND [length]=24)
BEGIN
	ALTER TABLE Import_WS2CS_VisitSummary_Track ALTER COLUMN CustomerCode [Nvarchar](25)
END
GO
IF EXISTS(SELECT * fROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id 
WHERE A.name='SalesmanVisitedDateTimeDetails' AND B.name='CustomerCode' AND A.xtype='U' AND [length]=24)
BEGIN
	ALTER TABLE SalesmanVisitedDateTimeDetails ALTER COLUMN CustomerCode [Nvarchar](25)
END
GO
IF EXISTS(SELECT * fROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id 
WHERE A.name='Import_WS2CS_CustomerInventory' AND B.name='CustomerCode' AND A.xtype='U' AND [length]=24)
BEGIN
	ALTER TABLE Import_WS2CS_CustomerInventory ALTER COLUMN CustomerCode [Nvarchar](25)
END
GO
IF EXISTS(SELECT * fROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id 
WHERE A.name='Import_WS2CS_CustomerInventory_Track' AND B.name='CustomerCode' AND A.xtype='U'AND [length]=24)
BEGIN
	ALTER TABLE Import_WS2CS_CustomerInventory_Track ALTER COLUMN CustomerCode [Nvarchar](25)
END
GO
IF EXISTS(SELECT * fROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id 
WHERE A.name='CustomerInventory' AND B.name='CustomerCode' AND A.xtype='U'AND [length]=24)
BEGIN
	ALTER TABLE CustomerInventory ALTER COLUMN CustomerCode [Nvarchar](25)
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_ImportValues' AND XTYPE ='P')
DROP PROCEDURE Proc_ImportValues
GO
CREATE PROCEDURE Proc_ImportValues
(
	@TypeId INT,
	@TenantCode varchar(100)='',
	@ModuleName Varchar(200) ='',
	@SyncKey Varchar(500) ='',
	@Count Varchar(100) ='' ,
	@Result  varchar(200) ='' ,
	@TokenID Varchar(500) =''
	
)
AS
/*
/*******************************************************************************************
* PROCEDURE		: Proc_ImportValues
* PURPOSE		: To Validate and Insert Customer Inventory details From PDA Intermediate Database
* CREATED		: RAMESH.K
* CREATED DATE	: 28/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR			CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
********************************************************************************************/ 
*/


BEGIN
	IF (@TypeId  = 1)--Import Upload Sync Keys  Flag
	BEGIN
	    exec Proc_Validate_WS2CS_SalesOrderDetail 0

		Update Import_WS2CS_SalesOrderHeader SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_SalesOrderDetail SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_SalesOrderReturnExchange SET DownloadFlag='Y' where DownloadFlag ='N'

		exec Proc_Validate_WS2CS_CollectionHeader 0
		Update Import_WS2CS_CollectionHeader SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_CollectionDetail SET DownloadFlag='Y' where DownloadFlag ='N'

		exec Proc_Validate_WS2CS_CustomerInventory 0
		Update Import_WS2CS_CustomerInventory SET DownloadFlag='Y' where DownloadFlag ='N'

	    exec Proc_Validate_WS2CS_NewCustomerRequest 0
		Update Import_WS2CS_NewCustomerRequest SET DownloadFlag='Y' where DownloadFlag ='N'

		exec Proc_Validate_WS2CS_VisitSummary 0
		Update Import_WS2CS_VisitSummary SET DownloadFlag='Y' where DownloadFlag ='N'
		
		exec Proc_Validate_WS2CS_UploadSyncKeys 0 
		Insert into [WS2CS_UploadSyncKeysLog] (TenantCode,LocationCode,LoggedDate) values 
		                                      (  @TenantCode,@TenantCode,getdate() )
	END
	
	IF (@TypeId  = 2)--Get Sync Keys  Flag
	BEGIN
	SELECT SyncKey FROM WS2CS_UploadSyncKeysTrack where  DownloadFlag='N' AND ModuleName =@ModuleName
	end
	IF (@TypeId  = 3) 
	BEGIN

	  Insert into [WS2CSSyncKeysLog] ( [TenantCode],[LocationCode],[SyncKey],[ModuleName],[TotalCount])  Values 
	                                 (@TenantCode,@TenantCode,@SyncKey ,@ModuleName,@Count)
	 Update WS2CS_UploadSyncKeysTrack set DownloadFlag='Y' where SyncKey=@SyncKey AND ModuleName=@ModuleName AND DownloadFlag='N'

	END 
	IF ( (@TypeId  = 3) AND ( @ModuleName='SalesOrder'))
	BEGIN
		Update Import_WS2CS_SalesOrderDetail SET DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 
		Update Import_WS2CS_SalesOrderHeader  SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 
		Update Import_WS2CS_SalesOrderReturnExchange  SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 
	
		exec Proc_Validate_WS2CS_SalesOrderDetail 0

		Update Import_WS2CS_SalesOrderHeader SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_SalesOrderDetail SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_SalesOrderReturnExchange SET DownloadFlag='Y' where DownloadFlag ='N'
		
	END
	ELSE IF ( (@TypeId  = 3) AND ( @ModuleName='ARCollection'))
	BEGIN
	
		Update Import_WS2CS_CollectionHeader SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 
		Update Import_WS2CS_CollectionDetail SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 

		exec Proc_Validate_WS2CS_CollectionHeader 0

		Update Import_WS2CS_CollectionHeader SET DownloadFlag='Y' where DownloadFlag ='N'
		Update Import_WS2CS_CollectionDetail SET DownloadFlag='Y' where DownloadFlag ='N'
	
	END

	ELSE IF ( (@TypeId  = 3) AND ( @ModuleName='CustomerInventoryV1'))
	BEGIN
	
		Update Import_WS2CS_CustomerInventory SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 

		exec Proc_Validate_WS2CS_CustomerInventory 0

		Update Import_WS2CS_CustomerInventory SET DownloadFlag='Y' where DownloadFlag ='N'

	END

	ELSE IF ( (@TypeId  = 3) AND ( @ModuleName='NewCustomer'))
	BEGIN

		update Import_WS2CS_NewCustomerRequest SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 

		exec Proc_Validate_WS2CS_NewCustomerRequest 0

		Update Import_WS2CS_NewCustomerRequest SET DownloadFlag='Y' where DownloadFlag ='N'

	END
	ELSE iF ( (@TypeId  = 3) AND ( @ModuleName='VisitSummary'))
	BEGIN
	  
		update Import_WS2CS_VisitSummary   SET  DownloadFlag='N',CreatedDate=getdate()   where DownloadFlag IS NULL 

		exec Proc_Validate_WS2CS_VisitSummary 0

		Update Import_WS2CS_VisitSummary SET DownloadFlag='Y' where DownloadFlag ='N'
	
	END

	ELSE IF  (@TypeId  = 4) 
	BEGIN
	Insert into WS2CSTransactionDetail ([TenantCode],[LocationCode],[ModuleName],TransactionID ,RecordProcessed,[Result],[TokenID] ,[CreatedDate],DownLoadFlag) values
	                                   (@TenantCode,@TenantCode, @ModuleName, @SyncKey,@Count, @Result,@TokenID,getdate() ,'N'  ) 

	END 

	ELSE IF  (@TypeId  = 5) 
	BEGIN
	 
	     --Select Max(Loggeddate) from WS2CS_UploadSyncKeysLog  
	    Select getdate()-30
	END 

	ELSE IF  (@TypeId  = 6) 
	BEGIN	 
	   Select TenantCode, ModuleName ,TransactionID,TokenID  from WS2CSTransactionDetail  where RecordProcessed > 0  
	END
--	Proc_Validate_WS2CS_SalesOrderDetail
--Proc_Validate_WS2CS_CollectionHeader
--Proc_Validate_WS2CS_VisitSummary
--Proc_Validate_WS2CS_NewCustomerRequest
--Proc_Validate_WS2CS_CustomerInventory
--Proc_Validate_WS2CS_UploadSyncKeys
--Proc_Validate_WS2CS_TransactionHeader
END
GO
IF EXISTS(select * from RetailerCategory where CtgCode ='SSOGT'AND Ctglinkid =1 AND CtgLevelId =1)
BEGIN
------------- Added By lakshman m Dated On 14122018 PMS ID: ILCRSTPAR2830 ------------
	Declare @Ctgmainid AS Int
	select @Ctgmainid = CtgMainId from RetailerCategory where CtgCode ='SSOGT' AND Ctglinkid =1 AND CtgLevelId =1 
	Update A set Ctglevelid =2  from RetailerCategory A where CtgCode ='SSOGT' AND Ctglinkid =1 AND CtgLevelId =1 AND CtgMainId =@Ctgmainid
	select * from RetailerCategory where CtgCode like '%sso%'
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_SalesOrderHeader' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_SalesOrderHeader ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_SalesOrderDetail' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_SalesOrderDetail ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='WS2CS_SalesOrderHeader_NewRetailer' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE WS2CS_SalesOrderHeader_NewRetailer ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='WS2CS_SalesOrderDetail_NewRetailer' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE WS2CS_SalesOrderDetail_NewRetailer ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_SalesOrderHeader_Track' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_SalesOrderHeader_Track ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_SalesOrderDetail_Track' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_SalesOrderDetail_Track ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_SalesOrderReturnExchange' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_SalesOrderReturnExchange ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_SalesOrderReturnExchange_Track' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_SalesOrderReturnExchange_Track ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_CollectionHeader' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_CollectionHeader ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_CollectionHeader_Track' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_CollectionHeader_Track ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_CollectionDetail' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_CollectionDetail ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='Import_WS2CS_CollectionDetail_Track' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE Import_WS2CS_CollectionDetail_Track ALTER column DocumentPrefix NVARCHAR(25)
END
IF EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID AND A.NAME ='SalesmanVisitedDateTimeDetails' AND B.NAME ='DocumentPrefix')
BEGIN
	ALTER TABLE SalesmanVisitedDateTimeDetails ALTER column DocumentPrefix NVARCHAR(25)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='rptheader_BK' AND XTYPE ='U')
BEGIN
CREATE TABLE [dbo].[rptheader_BK](
	[rptid] [nvarchar](100) NULL,
	[RpCaption] [nvarchar](100) NULL
) ON [PRIMARY]
END
GO
DELETE FROM rptheader_BK
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('1','Sales Value Report - Bill Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('100','Purcahse Excess Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('101','Rate Difference Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('102','Special Discount Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('103','Van Subsidy Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('104','Purchase Ageing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('105','Manual Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('106','Salesman Incentive Claim Detail Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('107','Claim Top Sheet Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('108','Retailer Cheque Inventory Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('109','Supplier Cheque and DD Inventory Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('11','Input Output Tax Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('110','Purchase Order Product Norm Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('111','Purchase Invoice Series Settings Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('112','Stock Journal Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('113','Resell Damage Goods Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('114','Accounts Calendar Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('115','Cheque Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('116','Counters')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('118','Opening Balance Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('119','Order Booking Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('12','Replacement Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('120','Product Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('121','Purchase Order Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('122','Purchase Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('123','Purchase Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('124','Retailer Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('126','Standard Voucher Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('127','Stock Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('128','Transaction Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('129','Van Load Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('13','Item Price List')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('130','Van Unload Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('131','Return To Company Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('132','Return To Company Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('133','Batch Transfer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('136','Retailer Stock Norm Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('137','Contract Pricing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('138','KIT Product Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('139','Product Sales Bundle Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('14','Retailer Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('140','Focus Brand Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('141','Van Load Guide Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('142','Batch Creation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('143','Target Norm Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('144','Hot Search Editor Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('145','Bill Series Settings Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('146','Salesman Incentive Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('147','Purchase Sales Account')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('148','Purchase Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('149','Purchase Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('15','Scheme Utilization')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('150','Datewise Productwise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('151','Stock Ledger Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('152','Scheme Utilization Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('153','ClosingStockReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('155','SalesmanAnanlysisReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('156','Focus SKU Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('157','Distributor Account Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('159','Sample Issue Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('165','Pending Bills Report-Shipping Address wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('168','Billwise Collection Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('169','DRCP New')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('17','Loading Sheet - Bill Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('171','Retailer Wise Value Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('18','Loading Sheet - Item Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('182','Ageing Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('183','BillWise ProductWise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('19','Loading Sheet - Collection Format')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('2','Product Wise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('20','Stock Adjustment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('201','Fund Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('202','Price Difference Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('203','Bench Marking Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('204','Discount Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('205','ASR Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('206','Retailer Master Detail Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('207','PSR Efficiency Datewise Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('21','Salvage Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('210','RetailerWise Productwise Sales Value and Volume Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('211','Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('212','Outletwise Retailing')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('213','Modern Trade Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('214','MarketwiseRetailing')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('215','Retailer Wise Scheme Utilization Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('216','Netsales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('217','Retailer Accounts Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('219','Hierarchywise Stock and Sales Report - Volume Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('22','Location Transfer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('220','Retailer and Product Wise Sales Volume')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('221','AksoNobalCurrentStock')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('222','Party Account Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('223','Sales Return Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('224','Retailer wise Bill wise Net Tax Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('225','Stock Ledger Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('228','JNJ Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('229','Bill Wise Scheme Utilization')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('23','Company Wise Purchase Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('230','Sales UOM Based Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('231','Retailer Category and Classification Shift')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('232','Sales Vat Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('233','UnLoadingSheetReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('234','DSR wise Report - Target Analysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('235','Launch Product Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('236','DSR wise BGR wise Report - Target Anlaysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('237','Brand wise Report - Target Anlaysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('238','Inter Stock Foresight')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('239','IDT Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('24','Product Purchase Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('240','Logistic Material Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('241','BillWise ProductWise Loading Sheet')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('242','Sub Stockist Claim Details')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('243','Business Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('244','Salesman Productivity Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('245','Stock and Sales Report - Volume Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('246','Scheme Utilization Report Parle')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('247','Product Wise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('248','Day End Collection Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('249','Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('25','Product Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('250','Vat Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('251','Loading Sheet Item-Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('252','Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('253','Monthly Vat Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('254','ClosingStockReportParle')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('255','Supplier Accounts Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('256','Vat Computation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('257','LoadingSheetProductWiseUOMWise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('258','UnLoading Sheet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('26','Retailer - Supplier Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('27','Retailer Wise Bill Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('276','UPVAT XXIV Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('277','Guj govt VAT report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('278','Guj govt VAT report 201A')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('279','Supplier Wise VAT Purchase')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('28','Input VAT Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('280','RetailerWise VAT Sales')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('281','Day Wise Collection Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('282','Monthly Stock Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('284','Bill Wise Market Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('285','BillWise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('286','Parle Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('287','Scheme Utilization Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('288','Trade Promotion Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('289','Target Setting Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('29','Output VAT Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('290','Scheme Stock Reconciliation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('291','Debit Note Top Sheet')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('3','Pending Bills Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('30','Retailer Outstanding Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('32','Tax Summary Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('33','Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('35','Profit And Loss Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('36','Trial Balance Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('37','Balance Sheet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('38','Accounts Ledger-Day Book')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('39','Accounts Ledger-BANK BOOK')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('4','Collection Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('40','Accounts Ledger-CASH BOOK')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('401','Product Wise Output Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('402','Product Wise Input Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('404','Output Sale Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('405','Input Tax Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('406','ServiceInvoice Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('407','Product wise Input output tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('41','Product Track Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('411','FORM GSTR-3B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('413','GSTR TRANS2')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('414','FORM GSTR1-B2B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('415','FORM GSTR1-B2CL')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('416','FORM GSTR1-B2CS')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('417','FORM GSTR1-CNDR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('418','FORM GSTR1-CDNUR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('419','FORM GSTR1-HSN')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('42','Route Coverage Plan Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('420','FORM GSTR1-DOCS')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('421','FORM GSTR1-Exempt')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('422','HSN Code wise output tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('423','HSN Code wise Input tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('424','GSTR1 Extract')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('425','FORM GSTR2-B2B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('426','FORM GSTR2-B2BUR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('427','FORM GSTR2-HSNSUM')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('428','FORM GSTR2-NILRATE')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('429','FORM GSTR2-CDN')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('43','Rsp Sales Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('430','FORM GSTR2-SUMMARY')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('431','GSTR2-Extract')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('432','E Way Bill Template')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('44','Rsp Sales Trend Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('45','Sub Stockist Jc Closing Review Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('5','Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('50','Dead Outlet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('51','RPS Drive Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('52','Sales Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('53','Bank Slip Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('54','TLSD Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('55','DRCP Deviation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('56','Top Outlet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('57','Window Display Contest Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('58','Distribution Width Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('59','Critical Sales Parameter Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('6','Stock and Sales Report - Volume Wise ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('60','Quantity Fill Ratio')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('61','Credit Evaluation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('62','Outlet Class Shift Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('63','Purchase Sales Trend')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('64','Company Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('65','Location Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('66','Distributor Info Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('67','Stock Management Type Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('68','Transporter Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('69','Supplier Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('7','Stock and Sales Report - Value Wise ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('70','Udc Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('71','Vehicle Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('72','Vehicle Category Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('73','Bank Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('74','Bank Branch Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('75','Stock Type Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('76','User Key Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('77','User Maintenance Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('78','Tax Configuration Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('79','Tax Group Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('8','GRN Listing ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('80','User Profile Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('81','Credit Note Retailer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('82','Retailer Debit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('83','Retailer Shipping Address Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('84','Supplier Credit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('85','Supplier Debit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('86','Vehicle SubSidy Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('87','Salesman Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('88','Route Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('89','Delivery Boy Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('9','Sales Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('90','Village Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('91','Claim Group Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('92','Claim Norm Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('93','Potential Classification Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('94','Value Classification Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('95','JC Calendar Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('96','Salesman Salary And DA Claim Details Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('97','Delivery Boy Salary And DA Claim Details Master  Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('98','Transporter Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('99','Purcahse Shortage Claim Master Report')
GO
UPDATE A set A.RpCaption  =B.rpcaption from rptheader_BK B INNER JOIN rptheader A ON A.Rptid =B.Rptid AND A.Rptid <> 107
GO
IF EXISTS(SELECT * FROM RptExcelHeaders WHERE Rptid =107)
BEGIN
		UPDATE A SET DisplayName ='Sales Value',DisplayFlag =1  FROM RptExcelHeaders A WHERE rptid = 107 and slno IN(10)
		UPDATE A SET DisplayName ='Lib %'  FROM RptExcelHeaders A WHERE rptid = 107 and slno IN(13)
		END
GO
IF EXISTS (select *from sysobjects where name ='Proc_RptClaimTopSheet' and xtype ='P')
DROP PROCEDURE Proc_RptClaimTopSheet
GO
-- EXEC Proc_RptClaimTopSheet 107,2,0,'',0,0,1,''
CREATE PROCEDURE Proc_RptClaimTopSheet
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
* PROCEDURE  : Proc_RptClaimTopSheet
* PURPOSE    : To Generate  Claim Top Sheet Report 
* CREATED BY : Boopathy.P
* CREATED ON : 19/03/2008  
* MODIFICATION 
*************************************************   
* DATE       AUTHOR      DESCRIPTION    
--------------------------------------------------------------------------------------------------------------------
* Date			  Author	   CR/BZ	 UserStoryId		    Description 
* 03-05-2018	 lakshman M      BZ	     ILCRSTPAR0448	        Claim wise Rpt name & Date range filter validation added in Core stocky
* 07-05-2018	 lakshman M      BZ	     ILCRSTPAR0478	        Claim wise scheme code,schem valid Date and tax amount validation added in Core stocky
* 27-06-2018     Deepak K		 BZ      ILCRSTPAR1185			Special Discount Claim RefCode validation added 
* 20-11-2018     lakshman M      BZ      ILCRSTPAR2606          Claim top sheet report tax amount validation missing in CS. 
* 04-11-2018     Lakshman M      SR      ILCRSTPAR2722          As per Awanish request claim top sheet report two New column added      
**********************************************************************************************************************/      
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	nvarchar(50)
	DECLARE @TblName 			AS	nvarchar(500)
	DECLARE @TblStruct 			AS	nVarchar(4000)
	DECLARE @TblFields 			AS	nVarchar(4000)
	DECLARE @sSql				AS 	nVarChar(4000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	nVarChar(50)
	--Filter Variable
	DECLARE @CmpId				AS	INT
	DECLARE @FromDate			AS 	DATETIME
	DECLARE @ToDate				AS 	DATETIME
	DECLARE @ClmGrpId			AS	INT
	DECLARE @ClmSts				AS	INT
	DECLARE @ClmConfSts			AS	INT
	DECLARE @ClmCode			AS	INT
--Till Here
--Assgin Value for the Filter Variable
	SET @CmpId = 		(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @FromDate =		(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate =		(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @ClmGrpId = 	(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,42,@Pi_UsrId))
	SET @ClmSts = 		(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,124,@Pi_UsrId))
	SET @ClmConfSts = 	(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,125,@Pi_UsrId))
	SET @ClmCode = 		(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,41,@Pi_UsrId))
	
	PRINT @CmpId
	PRINT @FromDate
	PRINT @ToDate
	PRINT @ClmGrpId
	PRINT @ClmSts
	PRINT @ClmConfSts
	PRINT @ClmCode
	---------- Added by lakshman M on 07/05/2018 PMS ID: ILCRSTPAR0478  new columns added in CS (Schcode,SchFrmDate,SchToDate,TaxAmount)----------------
	Create TABLE #RptClaimTopSheet
	(
			ClmCode			 NVARCHAR(50),
			ClmDesc		 	 NVARCHAR(50),
			ClmDate			 DATETIME,
			Schcode			 NVARCHAR(50),
			SchDesc			 NVARCHAR(100),
			SchFrmDate		 NVARCHAR(50),
			SchToDate		 NVARCHAR(50),	
			DiscountVal		 NUMERIC(38,6),
			FreePrdVal		 NUMERIC(38,6),
			GiftPrdVal		 NUMERIC(38,6),
			TotalSpend		 NUMERIC(38,6),
			TaxAmount		 NUMERIC(38,6),
			ClmPercentage	 NUMERIC(38,2),
			ClmAmount		 NUMERIC(38,6),
			RecommendedAmt	 NUMERIC(38,6),
			ReceivedAmt		 NUMERIC(38,6),
			CrDbNote		 NVARCHAR(50),
			Status			 NVARCHAR(50),
			ConfirmSts		 NVARCHAR(50),
			ClmType			 INT,
			ClmGrpId		 INT
	)
	SET @TblName = 'RptClaimTopSheet'
	SET @TblStruct ='ClmCode		 NVARCHAR(50),
			ClmDesc		 	 NVARCHAR(50),
			ClmDate			 DATETIME,
			Schcode			 NVARCHAR(50),
			SchDesc			 NVARCHAR(100),
			SchFrmDate		 NVARCHAR(50),
			SchToDate		 NVARCHAR(50),
			DiscountVal		 NUMERIC(38,6),
			FreePrdVal		 NUMERIC(38,6),
			GiftPrdVal		 NUMERIC(38,6),
			TotalSpend		 NUMERIC(38,6),
			TaxAmount		 NUMERIC(38,6),
			ClmPercentage	 NUMERIC(38,2),
			ClmAmount		 NUMERIC(38,6),
			RecommendedAmt	 NUMERIC(38,6),
			ReceivedAmt		 NUMERIC(38,6),
			CrDbNote		 NVARCHAR(50),
			Status			 NVARCHAR(50),
			ConfirmSts		 NVARCHAR(50),
			ClmType			 INT,
			ClmGrpId		 INT'
	
	SET @TblFields = 'ClmCode,ClmDesc,ClmDate,Schcode,SchDesc,SchFrmDate,SchToDate,DiscountVal,FreePrdVal,GiftPrdVal,TotalSpend,TaxAmount,
			ClmPercentage,ClmAmount,RecommendedAmt,ReceivedAmt,CrDbNote,Status,ConfirmSts,ClmType,ClmGrpId'
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
	
		INSERT INTO #RptClaimTopSheet (ClmCode,ClmDesc,ClmDate,Schcode,SchDesc,SchFrmDate,SchToDate,DiscountVal,FreePrdVal,GiftPrdVal,TotalSpend,TaxAmount,
		ClmPercentage,ClmAmount,RecommendedAmt,ReceivedAmt,CrDbNote,Status,ConfirmSts,ClmType,ClmGrpId)
		SELECT A.ClmCode,A.ClmDesc,CONVERT(NVARCHAR(10),A.ClmDate,121) AS ClmDate,Schcode,C.SchDsc,CONVERT(NVARCHAR(10),SchValidFrom,121) AS SchValidFrom,CONVERT(NVARCHAR(10),SchValidTill,121)AS SchValidTill,B.Discount,B.FreePrdVal,
		SalesValue,B.TotalSpent,
		ISNULL(B.GSTTax,0) AS [GSTTax], 
		--CASE WHEN SalesValue > 0 Then SalesValue WHEN GSTTax  > 0 Then GSTTax WHEN GSTTax  < 0 Then GSTTax END AS [GSTTax],  -- commented By Lakshman M Dated ON 2018-11-20 PMS ID:ILCRSTPAR2606
		B.Liability,B.ClmAmount,B.RecommendedAmount,B.ReceivedAmount,
		CASE B.CrDbMode WHEN 1 THEN 'Debit Note' WHEN 2 THEN 'Credit Note' ELSE 'Claim' END AS CrDbNote,
		CASE B.Status WHEN 1 THEN 'Pending' WHEN 2 THEN 'Settled' WHEN 3 THEN 'Cancelled' END AS Status,
		CASE A.Confirm WHEN 1 THEN 'Confirmed' WHEN 2 THEN 'Not confirmed' END AS ConfirmSts,A.ClmType,A.ClmGrpId 
		FROM ClaimSheetHD A INNER JOIN ClaimSheetDetail B ON A.ClmId=B.ClmId
		--INNER JOIN schememaster C ON C.SchCode =B.RefCode /*Commented By Deepak */
		LEFT OUTER JOIN schememaster C ON C.SchCode =B.RefCode /*Added by Deepak K ILCRSTPAR1185*/
		WHERE (A.CmpId=(CASE @CmpId WHEN 0 THEN A.CmpId ELSE @CmpId END)OR
			A.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
	        AND (A.ClmGrpId=(CASE @ClmGrpId WHEN 0 THEN A.ClmGrpId ELSE @ClmGrpId END) OR
			A.ClmGrpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,42,@Pi_UsrId))) 
	        AND (B.Status = (CASE @ClmSts WHEN 0 THEN B.Status ELSE @ClmSts END) OR
			B.Status in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,124,@Pi_UsrId))) 
			AND (A.Confirm = (CASE @ClmConfSts WHEN 0 THEN A.Confirm ELSE 0 END) OR
			A.Confirm in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,125,@Pi_UsrId))) 
			AND (A.ClmId = (CASE @ClmCode WHEN 0 THEN A.ClmId ELSE @ClmCode END)OR
			A.ClmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,41,@Pi_UsrId))) 
	        AND A.ClmDate BETWEEN @FromDate AND @ToDate
	---------- Till Here ----------------
	   	IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptClaimTopSheet ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE
				        (A.CmpId=(CASE @CmpId WHEN 0 THEN A.CmpId ELSE @CmpId END) 
				        AND A.ClmGrpId=(CASE @ClmGrpId WHEN 0 THEN A.ClmGrpId ELSE @ClmGrpId END) 
				        AND B.Status = (CASE @ClmSts WHEN 0 THEN B.Status ELSE @ClmSts END) 
					AND A.Confirm = (CASE @ClmConfSts WHEN 0 THEN A.Confirm ELSE @ClmConfSts END)
					AND A.ClmId = (CASE @ClmCode WHEN 0 THEN A.ClmId ELSE @ClmCode END) 			
				        AND A.ClmDate BETWEEN @FromDate AND @ToDate)'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptClaimTopSheet'
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
			SET @SSQL = 'INSERT INTO #RptClaimTopSheet ' +
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
	
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptClaimTopSheet
	-------------- Added by lakshman M On 03-05-2018 PMS ID: ILCRSTPAR0448---------------
	DECLARE @Rptname	AS	Varchar(100)
	DECLARE @ClmGroupname	AS	Varchar(100)
	Declare @frmDate As datetime
	Declare @TillDate As datetime 
	
	SET @Rptname ='' 
	SET @ClmGroupname =''
	SET @frmDate = ''
	SET @TillDate =''
	UPDATE RptHeader SET RpCaption='Claim Top Sheet Details Report' WHERE RPTID = @Pi_RptId
	
	SELECT @Rptname=RpCaption  FROM RptHeader WHERE RptId=@Pi_RptId
	SELECT @ClmGroupname=ClmGrpName,@frmDate=B.FromDate,@TillDate =B.todate FROM ClaimGroupMaster A inner join ClaimSheetHd B ON A.ClmGrpId =B.ClmGrpId
	INNER JOIN #RptClaimTopSheet C ON C.ClmGrpId =B.ClmGrpId WHERE C.ClmCode in(select ClmCode from #RptClaimTopSheet)
	SET @frmDate = ''
	SET @TillDate =''
	SELECT @frmDate=A.FromDate,@TillDate =A.ToDate from ClaimSheetHd A where A.ClmCode in(select ClmCode from #RptClaimTopSheet)
	
	SELECT @ClmGroupname=ClmGrpName FROM #RptClaimTopSheet A  
	INNER JOIN ClaimGroupMaster B ON A.ClmGrpId =B.ClmGrpId
	
	UPDATE RptHeader SET RpCaption=@ClmGroupname + ' - ' +  @Rptname +' For ' + CONVERT(varchar(10),@frmDate,105) +' - ' + CONVERT(varchar(10),@TillDate,105) WHERE RPTID = @Pi_RptId
	--UPDATE RptHeader SET RpCaption=@ClmGroupname + ' - ' +  @Rptname  WHERE RPTID = @Pi_RptId
	--select @ClmGroupname + ' - ' +  @Rptname + 'For' + CONVERT(varchar(10),@frmDate,121) +' - ' + CONVERT(varchar(10),@TillDate,121) from RptHeader WHERE RPTID = @Pi_RptId
	ALTER TABLE #RptClaimTopSheet drop column ClmGrpId
	------------ Till here -----------
	SELECT * FROM #RptClaimTopSheet
	------------- temp -------
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='rptheader_BK' AND XTYPE ='U')
BEGIN
	CREATE TABLE [dbo].[rptheader_BK](
		[rptid] [nvarchar](100) NULL,
		[RpCaption] [nvarchar](100) NULL
	) ON [PRIMARY]
END
DELETE FROM rptheader_BK
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('1','Sales Value Report - Bill Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('100','Purcahse Excess Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('101','Rate Difference Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('102','Special Discount Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('103','Van Subsidy Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('104','Purchase Ageing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('105','Manual Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('106','Salesman Incentive Claim Detail Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('107','Claim Top Sheet Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('108','Retailer Cheque Inventory Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('109','Supplier Cheque and DD Inventory Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('11','Input Output Tax Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('110','Purchase Order Product Norm Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('111','Purchase Invoice Series Settings Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('112','Stock Journal Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('113','Resell Damage Goods Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('114','Accounts Calendar Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('115','Cheque Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('116','Counters')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('118','Opening Balance Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('119','Order Booking Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('12','Replacement Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('120','Product Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('121','Purchase Order Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('122','Purchase Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('123','Purchase Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('124','Retailer Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('126','Standard Voucher Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('127','Stock Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('128','Transaction Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('129','Van Load Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('13','Item Price List')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('130','Van Unload Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('131','Return To Company Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('132','Return To Company Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('133','Batch Transfer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('136','Retailer Stock Norm Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('137','Contract Pricing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('138','KIT Product Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('139','Product Sales Bundle Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('14','Retailer Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('140','Focus Brand Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('141','Van Load Guide Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('142','Batch Creation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('143','Target Norm Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('144','Hot Search Editor Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('145','Bill Series Settings Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('146','Salesman Incentive Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('147','Purchase Sales Account')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('148','Purchase Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('149','Purchase Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('15','Scheme Utilization')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('150','Datewise Productwise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('151','Stock Ledger Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('152','Scheme Utilization Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('153','ClosingStockReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('155','SalesmanAnanlysisReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('156','Focus SKU Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('157','Distributor Account Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('159','Sample Issue Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('165','Pending Bills Report-Shipping Address wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('168','Billwise Collection Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('169','DRCP New')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('17','Loading Sheet - Bill Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('171','Retailer Wise Value Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('18','Loading Sheet - Item Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('182','Ageing Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('183','BillWise ProductWise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('19','Loading Sheet - Collection Format')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('2','Product Wise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('20','Stock Adjustment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('201','Fund Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('202','Price Difference Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('203','Bench Marking Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('204','Discount Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('205','ASR Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('206','Retailer Master Detail Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('207','PSR Efficiency Datewise Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('21','Salvage Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('210','RetailerWise Productwise Sales Value and Volume Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('211','Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('212','Outletwise Retailing')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('213','Modern Trade Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('214','MarketwiseRetailing')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('215','Retailer Wise Scheme Utilization Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('216','Netsales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('217','Retailer Accounts Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('219','Hierarchywise Stock and Sales Report - Volume Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('22','Location Transfer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('220','Retailer and Product Wise Sales Volume')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('221','AksoNobalCurrentStock')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('222','Party Account Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('223','Sales Return Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('224','Retailer wise Bill wise Net Tax Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('225','Stock Ledger Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('228','JNJ Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('229','Bill Wise Scheme Utilization')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('23','Company Wise Purchase Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('230','Sales UOM Based Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('231','Retailer Category and Classification Shift')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('232','Sales Vat Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('233','UnLoadingSheetReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('234','DSR wise Report - Target Analysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('235','Launch Product Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('236','DSR wise BGR wise Report - Target Anlaysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('237','Brand wise Report - Target Anlaysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('238','Inter Stock Foresight')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('239','IDT Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('24','Product Purchase Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('240','Logistic Material Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('241','BillWise ProductWise Loading Sheet')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('242','Sub Stockist Claim Details')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('243','Business Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('244','Salesman Productivity Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('245','Stock and Sales Report - Volume Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('246','Scheme Utilization Report Parle')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('247','Product Wise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('248','Day End Collection Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('249','Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('25','Product Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('250','Vat Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('251','Loading Sheet Item-Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('252','Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('253','Monthly Vat Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('254','ClosingStockReportParle')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('255','Supplier Accounts Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('256','Vat Computation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('257','LoadingSheetProductWiseUOMWise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('258','UnLoading Sheet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('26','Retailer - Supplier Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('27','Retailer Wise Bill Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('276','UPVAT XXIV Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('277','Guj govt VAT report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('278','Guj govt VAT report 201A')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('279','Supplier Wise VAT Purchase')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('28','Input VAT Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('280','RetailerWise VAT Sales')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('281','Day Wise Collection Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('282','Monthly Stock Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('284','Bill Wise Market Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('285','BillWise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('286','Parle Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('287','Scheme Utilization Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('288','Trade Promotion Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('289','Target Setting Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('29','Output VAT Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('290','Scheme Stock Reconciliation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('291','Debit Note Top Sheet')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('3','Pending Bills Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('30','Retailer Outstanding Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('32','Tax Summary Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('33','Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('35','Profit And Loss Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('36','Trial Balance Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('37','Balance Sheet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('38','Accounts Ledger-Day Book')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('39','Accounts Ledger-BANK BOOK')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('4','Collection Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('40','Accounts Ledger-CASH BOOK')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('401','Product Wise Output Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('402','Product Wise Input Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('404','Output Sale Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('405','Input Tax Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('406','ServiceInvoice Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('407','Product wise Input output tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('41','Product Track Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('411','FORM GSTR-3B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('413','GSTR TRANS2')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('414','FORM GSTR1-B2B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('415','FORM GSTR1-B2CL')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('416','FORM GSTR1-B2CS')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('417','FORM GSTR1-CNDR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('418','FORM GSTR1-CDNUR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('419','FORM GSTR1-HSN')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('42','Route Coverage Plan Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('420','FORM GSTR1-DOCS')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('421','FORM GSTR1-Exempt')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('422','HSN Code wise output tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('423','HSN Code wise Input tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('424','GSTR1 Extract')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('425','FORM GSTR2-B2B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('426','FORM GSTR2-B2BUR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('427','FORM GSTR2-HSNSUM')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('428','FORM GSTR2-NILRATE')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('429','FORM GSTR2-CDN')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('43','Rsp Sales Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('430','FORM GSTR2-SUMMARY')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('431','GSTR2-Extract')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('432','E Way Bill Template')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('44','Rsp Sales Trend Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('45','Sub Stockist Jc Closing Review Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('5','Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('50','Dead Outlet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('51','RPS Drive Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('52','Sales Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('53','Bank Slip Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('54','TLSD Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('55','DRCP Deviation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('56','Top Outlet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('57','Window Display Contest Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('58','Distribution Width Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('59','Critical Sales Parameter Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('6','Stock and Sales Report - Volume Wise ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('60','Quantity Fill Ratio')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('61','Credit Evaluation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('62','Outlet Class Shift Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('63','Purchase Sales Trend')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('64','Company Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('65','Location Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('66','Distributor Info Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('67','Stock Management Type Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('68','Transporter Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('69','Supplier Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('7','Stock and Sales Report - Value Wise ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('70','Udc Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('71','Vehicle Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('72','Vehicle Category Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('73','Bank Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('74','Bank Branch Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('75','Stock Type Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('76','User Key Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('77','User Maintenance Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('78','Tax Configuration Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('79','Tax Group Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('8','GRN Listing ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('80','User Profile Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('81','Credit Note Retailer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('82','Retailer Debit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('83','Retailer Shipping Address Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('84','Supplier Credit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('85','Supplier Debit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('86','Vehicle SubSidy Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('87','Salesman Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('88','Route Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('89','Delivery Boy Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('9','Sales Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('90','Village Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('91','Claim Group Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('92','Claim Norm Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('93','Potential Classification Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('94','Value Classification Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('95','JC Calendar Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('96','Salesman Salary And DA Claim Details Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('97','Delivery Boy Salary And DA Claim Details Master  Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('98','Transporter Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('99','Purcahse Shortage Claim Master Report')

UPDATE A set A.RpCaption  =B.rpcaption from rptheader_BK B INNER JOIN rptheader A ON A.Rptid =B.Rptid AND A.Rptid <> 107

RETURN
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_RptDebitNoteTopSheet]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_RptDebitNoteTopSheet]
GO
/*
BEGIN TRAN
EXEC Proc_RptDebitNoteTopSheet 291,2,0,'',0,0,1
SELECT * FROM RptDebitNoteTopSheet_Excel4
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[Proc_RptDebitNoteTopSheet]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/************************************************************************************************************************************
* PROCEDURE	: Proc_RptDebitNoteTopSheet
* PURPOSE	: To Return the Scheme Utilization Details
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Debit Note Top Sheet
* MODIFIED 
*************************************************************************************************************************************
* DATE       AUTHOR			CR/BZ	USER STORY ID           DESCRIPTION                         
*************************************************************************************************************************************
10-10-2017  Mohana.S		CR		CCRSTPAR0172          Included Circular Date and scheme Budget 
04-12-2017	Mohana			BZ		ICRSTPAR6760		  Added New Function for calculating Scheme utilized for selected month
07-12-2017  Mary.S			BZ		ICRSTPAR6933		  Excel Sheet row Witdth change    
13-12-2017  Mohana.S		CR		ICRSTPAR6933		  Changed Sampling Amount as Zero (default)   
09-01-2018  Lakshman M		BZ      ICRSTPAR7284          LCTR Formula validation changed.(special price not consider in LCTR Value).
26-03-2018	Mohana S		CR		CCRSTPAR0187		  TOT Diff Claims Report Created. 
08-05-2018	Mohana S		SR      ILCRSTPAR0500	      included Removed Scheme Products. 
09-05-2018	Mohana S		BZ	    ILCRSTPAR0506         chaged the target data selection
10-05-2018  Mohana S		BZ      ILCRSTPAR0546		  Sales return issue fix in Trade schemes
08-06-2018  Muthulakshmi.V  BZ      ILCRSTPAR0909         Scheme valid date checking condition changed
25-07-2018  Lakshman M		BZ		ILCRSTPAR1496         Scheme code valdiation included from CS.
30-08-2018  Amuthakumar P	BZ		ILCRSTPAR1917		  Changed Sampling Amount from Sample Issue ( FreeIssueDt)
19-09-2018  Amuthakumar P	BZ		CRCRSTAPAR0023		  Debit note Top Sheet not Consider un-salable Sales return / Manual Claim Report Inserted
09-10-2018   Mohana P		BZ	    ILCRSTPAR2313	    TAX CALCULATION CHANGED AS PER CLIENT REQUEST
12-10-2018   Mohana P		BZ	    ILCRSTPAR2343	    TAX CALCULATION CHANGED AS PER CLIENT REQUEST
16-10-2018   Mohana P		BZ	    ILCRSTPAR2343	     Incorprated LIVE Changes in UAT (AS per Awanish discussion, LIVE REport is correct. So we have changed based on live)
07-12-2018   Lakshman M     BZ      ILCRSTPAR2760        As per claient request manual claim valdaition included.
19-12-2018   Vasantharaj R  SR      ILCRSTPAR2868        As per Client request [All the report must be generate based on Date range selection.]
************************************************************************************************************************************/     
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
	
	EXEC Proc_SchUtilization_Report @FromDate,@ToDate
	
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
	DECLARE @SlNo AS INT
	
	DECLARE @SamplingAmount AS NUMERIC(18,2)
	SELECT @SlNo = SlNo FROM BatchCreation WHERE FieldDesc = 'Selling Price'
	
	---- Commented by Amuthakumar ILCRSTPAR1917
	
	--DECLARE @MGSaleable AS INT 
	--DECLARE @MGOffer AS INT
	
	--SELECT @MGSaleable = StockTypeId FROM StockType WHERE UserStockType = 'MGSaleable'
	--SELECT @MGOffer = StockTypeId FROM StockType WHERE UserStockType = 'MGOffer'
	--SELECT DISTINCT J.PrdId,J.PrdBatId,B.TaxGroupId,CAST(0 AS NUMERIC(18,2)) TaxPercentage
	--INTO #SamplingBatchTaxPercent
	--FROM StockJournal J,
	--StockJournalDt D (NOLOCK),
	--ProductBatch B (NOLOCK)
	--WHERE J.StkJournalRefNo = D.StkJournalRefNo
	--AND J.PrdBatId = B.PrdBatId	AND J.PrdId = B.PrdId
	--AND StockTypeId = @MGSaleable AND TransferStkTypeId = @MGOffer
	
	--SELECT ROW_NUMBER() OVER (ORDER BY T.TaxGroupId) RowNo,
	--MAX(T.PrdBatId) PrdBatId,T.TaxGroupId 
	--INTO #BatchTaxPercent
	--FROM #SamplingBatchTaxPercent T
	--WHERE T.TaxGroupId <> 0
	--GROUP BY T.TaxGroupId
	
	--DECLARE @PrdId AS INT
	--DECLARE @PrdBatId AS INT
	--DECLARE @TaxGroupId AS INT
	--DECLARE @TaxPercentage AS NUMERIC(18,2)
	--DECLARE @RowNo AS INT
	--DECLARE @TotalRow AS INT
	
	--SET @RowNo = 1
	--SELECT @TotalRow = COUNT(TaxGroupId) FROM #BatchTaxPercent D (NOLOCK)	
		
	--TRUNCATE TABLE SamplingBatchTaxPercent
	--WHILE (@RowNo < = @TotalRow)
	--BEGIN	
	--	SELECT @PrdId = B.PrdId, @PrdBatId = S.PrdBatId, @TaxGroupId = B.TaxGroupId
	--	FROM #BatchTaxPercent S,
	--	#SamplingBatchTaxPercent B (NOLOCK)
	--	WHERE S.PrdBatId = B.PrdBatId AND S.TaxGroupId = B.TaxGroupId
	--	AND RowNo = @RowNo
	--	EXEC Proc_SamplingTaxCalCulation @PrdId,@PrdBatId
		
	--	SELECT @TaxPercentage = TaxPercentage FROM SamplingBatchTaxPercent S (NOLOCK)
	--	WHERE PrdBatId = @PrdBatId
		
	--	UPDATE B SET B.TaxPercentage = @TaxPercentage
	--	FROM #SamplingBatchTaxPercent B
	--	WHERE B.TaxGroupId = @TaxGroupId
		
	--	SET @RowNo = @RowNo + 1
		
	--END	
	
	--SELECT @SamplingAmount =  ISNULL(SUM( D.StkTransferQty * (P.PrdBatDetailValue + (P.PrdBatDetailValue * (T.TaxPercentage / 100)))),0)
	--FROM StockJournal J (NOLOCK),
	--StockJournalDt D (NOLOCK),
	--ProductBatchDetails P (NOLOCK),
	--#SamplingBatchTaxPercent T (NOLOCK)
	--WHERE J.StkJournalRefNo = D.StkJournalRefNo AND J.PriceId = P.PriceId
	--AND P.PrdBatId = T.PrdBatId
	--AND StockTypeId = @MGSaleable AND TransferStkTypeId = @MGOffer
	--AND P.SLNo = @SlNo
	----Report 2
	---- Till Here ILCRSTPAR1917
	
	--- Change by Amuthakumar P ILCRSTPAR1917
	SELECT @SamplingAmount = ISNULL(SUM(D.TotalAmt),0)
	FROM FreeIssueHd J (NOLOCK),
	FreeIssueDt D (NOLOCK),
	ProductBatchDetails P (NOLOCK)
	WHERE J.IssueId = D.IssueId 
	AND P.PrdBatId = D.PrdBatId AND P.PriceId = D.PriceId 
	AND P.SLNo = @SlNo AND J.IssueDate BETWEEN @FromDate AND @ToDate
	--Report 2
	
	--- Till Here ILCRSTPAR1917
	
	--Report 3
	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate
	
	SELECT * INTO #ParleOutputTaxPercentage FROM ParleOutputTaxPercentage (NOLOCK)	
	
	-------------------- Added by Lakshman M On 07/11/2017 PMS_ICRSTPAR6575-------------------
	 -------------- Scheme code validation added by LAkshman M Dated By On 25/07/2018 PMS ID:ILCRSTPAR1496 ------------
	 SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,    
	 B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue--,D.Schid    
	 INTO #BillingDetails    
	 FROM SalesInvoice S (NOLOCK)    
	 INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId    
	 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId 
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1	
	 --INNER JOIN Debitnote_Scheme D ON D.Salid = S.SalId AND SP.SalId = D.Salid AND D.Prdid =SP.PrdID AND D.linetype = 1
	 WHERE S.SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =@SlNo
	    
	 SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,    
	 B.DefaultPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue--,D.Schid    
	 INTO #ReturnDetails    
	 FROM ReturnHeader S (NOLOCK)    
	 INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID    
	 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId    
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1
	 and StockTypeId IN (SELECT StockTypeId FROM STOCKTYPE WHERE SystemStockType = 1) 
	-- INNER JOIN Debitnote_Scheme D ON D.Salid = S.ReturnID AND SP.ReturnID = D.Salid  AND D.linetype = 2
	 WHERE S.ReturnDate BETWEEN  @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =@SlNo
	    
	 SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,CAST (0 AS NUMERIC(18,6)) AS ActualSellRate,prdtaxamount,
	 PrdBatDetailValue as PrdUnitSelRate,   
	 CAST (0 AS NUMERIC(18,6)) AS LCTR 
	 INTO #DebitSalesDetails    
	 FROM     
	 (    
	 SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,prdtaxamount,PrdBatDetailValue  FROM #BillingDetails   
	 UNION ALL    
	 SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,DefaultPriceId ,SlNo,prdtaxamount,PrdBatDetailValue  FROM #ReturnDetails    
	 ) Consolidated 
	------------------ Till Here ----------------------
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
	 UPDATE R SET R.LCTR = ROUND(((R.BaseQty *(R.PrdUnitSelRate))+(R.BaseQty*R.PrdUnitSelRate)*(T.TaxPerc/100)),2)      
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
		
  --added by mohana ILCRSTPAR0500	
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT Schid ,PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN Product C ON c.PrdCCode = A.FromValue
	WHERE ChangeType='Remove'   AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0 )
	
	INSERT INTO #ApplicableProduct(SchId,PrdId)		
	SELECT DISTINCT A.SchId,E.Prdid
	FROM SchemeMaster A
	INNER JOIN SchemeMasterControlHistory B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN ProductCategoryValue C ON 
	B.FromValue = C.PrdCtgValCode
	INNER JOIN ProductCategoryValue D ON
	D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
	INNER JOIN Product E On
	D.PrdCtgValMainId = E.PrdCtgValMainId 
	INNER JOIN ProductBatch F On
	F.PrdId = E.Prdid
	WHERE A.SchemeLvlMode = 0  AND A.SchId in (SELECT SchId FROM SchemeProducts Where PrdId = 0 )
	AND ChangeType='Remove'  
		
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
	SchemeMaster S (NOLOCK)
	WHERE A.SchId = S.SchId AND A.SchId  IN (SELECT SCHID FROM Debitnote_Scheme) 
	AND S.Claimable = 1
	
	--Added CircularNo and date By Mohana
	--SELECT S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	--SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	--CAST(0 AS NUMERIC(18,6)) Amount
	--INTO #SchemeDebit
	--FROM #ApplicableScheme S (NOLOCK),
	--#DebitSalesDetails B (NOLOCK) ,
	--SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode 
	--WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId AND S.SchId in (SELECT DISTINCT  SCHID FROM DEbitnote_Scheme) 
	--GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate
	--ORDER BY S.SchId
	--SchemeCirculardetails
		 
	SELECT  S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	INTO #SchemeDebit1
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=1 AND
	--PMS NO:ILCRSTPAR0909
	--S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--AND S.SchValidTill 	BETWEEN @FromDate AND @ToDate
	--(S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--or S.SchValidTill 	BETWEEN @FromDate AND @ToDate)
	(B.Transdate BETWEEN @FromDate AND @ToDate
	OR B.TransDate	BETWEEN @FromDate AND @ToDate)----PMS NO:ILCRSTPAR1309 Till Here
	GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,Transdate
	ORDER BY S.SchId
	 
	INSERT INTO #SchemeDebit1
	SELECT  S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2 AND 
	--PMSNo:ILCRSTPAR0909
	--S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--AND S.SchValidTill 	BETWEEN @FromDate AND @ToDate
	--(S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--or S.SchValidTill 	BETWEEN @FromDate AND @ToDate)
	(B.Transdate BETWEEN @FromDate AND @ToDate
	OR  B.Transdate 	BETWEEN @FromDate AND @ToDate)
	GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,Transdate
	ORDER BY S.SchId
	DELETE FROM #SchemeDebit1 WHERE SchId NOT IN (SELECT Schid FROM Debitnote_Scheme WHERE Linetype=1)      
	INSERT INTO #SchemeDebit1
	SELECT  S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	,Debitnote_Scheme D   
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2  
	AND S.Schid = D.Schid AND B.Prdid =D.Prdid AND B.Salid =D.Salid 
	AND S.SchId NOT IN (SELECT schid FROM #SchemeDebit1)
	GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate
	ORDER BY S.SchId
	 
	SELECT  SchId,SchDsc,SchValidFrom,SchValidTill,SchemeBudget,CircularNo, CircularDate,
	SUM(SecSalesQty) SecSalesQty,CAST(SUM(SecSalesVal) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	INTO #SchemeDebit from #SchemeDebit1  
	group by SchId,SchDsc,SchValidFrom,SchValidTill,SchemeBudget,CircularNo, CircularDate
 	 
	 
	--SELECT S.SchId,SUM(B.BaseQty) [SecSalesQtyInScheme]
	--INTO #SchemeForLiab
	--FROM #ApplicableScheme S (NOLOCK),
	--#BillingDetails B (NOLOCK)
	--WHERE S.PrdId = B.PrdId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	--AND EXISTS (SELECT 'C' FROM SalesInvoiceSchemeDtBilled SB (NOLOCK) WHERE B.SalId = SB.SalId AND S.SchId = SB.SchId)
	--GROUP BY S.SchId
	
	  --ILCRSTPAR2868
	    DROP TABLE #TaxPerc
		SELECT DISTINCT TaxPerc,B.SalId,B.PrdId  INTO #TaxPerc FROM SalesInvoiceProduct B 
		INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.SalId and  B.SlNo = P.PrdSlno AND TRANSID = 1 
		--Till Here 
		
			SELECT Schid,SUM(Schamt) SchAmt ,Sum(taxamt) TaxAmt INTO #SchFinal FROM 
		(
		SELECT A.SchId,SUM(A.schamt) SchAmt, (SUM(A.schamt)*(TaxPerc/100)) TaxAmt 
			FROM (
		--ILCRSTPAR2868
		--SELECT Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt FROM Debitnote_Scheme A 
		--INNER JOIN SalesInvoiceProduct B ON A.Salid = b.SalId AND a.Prdid = b.PrdId  
		--INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.SalId AND A.Salid = P.SalId AND B.SlNo = P.PrdSlno AND TRANSID = 1 AND Linetype = 1
		--GROUP BY  A.PRDID,A.SchId,TaxPerc
		SELECT  Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt FROM Debitnote_Scheme A 
		INNER JOIN #TaxPerc B ON A.Salid = b.SalId AND a.Prdid = b.PrdId AND Linetype = 1 
		GROUP BY  A.PRDID,A.SchId,TaxPerc
		--Till Here
		)A
		GROUP BY A.SchId,TaxPerc
		)B Group by  sCHID 
		insert into #SchFinal
		SELECT Schid,SUM(Schamt) SchAmt ,Sum(taxamt) TaxAmt FROM 
		(
		SELECT A.SchId,SUM(A.schamt) SchAmt, (SUM(A.schamt)*(TaxPerc/100)) TaxAmt 		 
		FROM (
		SELECT Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt FROM Debitnote_Scheme A INNER JOIN RETURNPRODUCT B ON A.Salid = b.ReturnID AND a.Prdid = b.PrdId 
		INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.ReturnID AND A.Salid = P.SalId AND B.SlNo = P.PrdSlno AND TRANSID = 2 AND a.Linetype =2
		and StockTypeId IN (SELECT StockTypeId FROM STOCKTYPE WHERE SystemStockType = 1)  
		GROUP BY  A.PRDID,A.SchId,TaxPerc
		)A
		GROUP BY A.SchId,TaxPerc
		)B Group by  sCHID 
		 
	UPDATE SD SET SD.Amount = CASE S.ApplyTaxForClaim WHEN 0 THEN schamt ELSE  (SchAmt+TaxAmt) END
	FROM #SchemeDebit SD (NOLOCK) INNER JOIN (SELECT Schid,SUM(SchAmt) SchAmt ,Sum(Taxamt) TaxAmt FROM  #SchFinal GROUP BY Schid) D  ON SD.Schid = D.Schid --CHANGED FOR CLAIMAMT MISMATCH
	INNER JOIN SchemeMaster S ON S.SchId = D.SCHID AND S.SchId = SD.SCHID 
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
 --Changed by Mohana ILCRSTPAR0506	
	SELECT   TOP 1 @TargetNo = InsId,@Month=TargetMonth,@Year=TargetYear,
	@InsFromDate = CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01',
	@InsToDate = DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01'))	
	FROM InsTargetHD H (NOLOCK) 
	INNER JOIN 	JCMonth A  ON H.TargetMonth = A.JcmJc
	INNER JOIN    JCMast b on a.JcmId = b.JcmId AND H.TargetYear =  B.JcmYr
	WHERE A.JcmEdt  BETWEEN @FromDate AND @ToDate AND H.[Status] = 1	
	ORDER BY InsId DESC
	
	SELECT @MonthName=MonthName FROM MonthDt (NOLOCK) WHERE MonthId=@Month
	UPDATE InsTargetHD SET TargetMonth=EffFromMonthId WHERE TargetMonth=0
	
	--EXEC Proc_LoadingInstitutionsTarget @TargetNo,@Pi_UsrId
	EXEC Proc_LoadingInstitutionsTarget @Year,@Month,@MonthName,@Pi_UsrId
	
	SELECT CtgMainId,CtgName,@InsFromDate FromDate,@InsToDate ToDate,SUM([Target]) [Target],SUM(ClmAmount) DiscAmount,
	CAST(0 AS NUMERIC(18,6)) L2MSales,CAST(0 AS NUMERIC(18,6)) CurMSales,CAST(0 AS NUMERIC(18,0)) Outlet
	INTO #Institutions
	FROM InsTargetDetailsTrans (NOLOCK) WHERE CtgName <>''
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
	 CONVERT(VARCHAR(10),S.CircularDate,103)  [Date],S.SchemeBudget [Scheme Budget],[SecSalesQty] [Sec Sales Qty],[SecSalesVal] [Sec Sales Value],CAST(Round(Liab,2) AS Numeric(18,2)) AS [% Liability on Sec Sales],
	 cast(round(Amount,2) as Numeric(18,2)) as  [Claim Amount],'A' As Dummy
	INTO #RptDebitNoteTopSheet_Excel1
	FROM #SchemeDebit S (NOLOCK) --WHERE Amount > 0	
	WHERE Amount <> 0 --- CRCRSTPAR0023  IF Difference of Claim Amt is Zero need not Shown --Changed as not equal to 
	
	
	IF (SELECT COUNT(*) FROM #RptDebitNoteTopSheet_Excel1) > 0
	BEGIN
		INSERT INTO #RptDebitNoteTopSheet_Excel1
		SELECT 'Total' [Scheme Description],'' [From],'' [To],'' [Circular No],'' [Date], 0 [Scheme Budget],
        0 [Sec Sales Qty], 0 [Sec Sales Value],0 [% Liability on Sec Sales],SUM([Claim Amount]) [Claim Amount],'B' Dummy
		FROM  #RptDebitNoteTopSheet_Excel1 
	END
	
	SELECT * INTO #Excel1 FROM #RptDebitNoteTopSheet_Excel1 ORDER BY Dummy
	
	DECLARE @RecCount AS BIGINT
	SELECT @RecCount = COUNT(7) FROM #RptDebitNoteTopSheet_Excel1
	
	INSERT INTO RptDebitNoteTopSheet_Excel1
	SELECT [Scheme Description],Cast([From] As Varchar(10)) [From],Cast([To] As Varchar(10)) [To],[Circular No],[Date],[Scheme Budget],
	[Sec Sales Qty],[Sec Sales Value],[% Liability on Sec Sales],[Claim Amount]
	FROM #Excel1 ORDER BY Dummy
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
	----------------------------------------------------TOT CLAIM Added By Mohana-------------------------------------------------------------------
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
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND StockTypeid in (select stocktypeid from  stocktype where systemstocktype =1)   
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
	
	SELECT tranid,Refid,Rtrid,CtgName,RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,SelRate,CAST(0 AS NUMERIC(18,2)) Nrmlrate,CAST(0 AS NUMERIC(18,2)) SplRate,CAST(0 AS NUMERIC(18,2)) Diff,Slno
	INTO #TotClaim FROM(
	SELECT 1 tranid,Salid Refid,A.Rtrid,CtgName,Salinvdate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate,Slno FROM #BillingDetails1 A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid 
	UNION 
	SELECT 2 Transid,ReturnID Refid,A.Rtrid,CtgName,ReturnDate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate,Slno FROM #ReturnDetails1  A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid 
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
	
	 UPDATE A SET A.SplRate = (BaseQty*((B.SplselRate)+(B.SplselRate*(p.TaxPerc/100)))) FROM  #TotClaim A INNER JOIN #ExistingSpecialPrice B
	 ON A.Priceid = B.Priceid 
	 INNER JOIN  ParleOutputtaxPercentage P ON A.Refid = p.salid and A.slno = p.prdslno AND A.Tranid=P.Transid
	 WHERE A.Priceid <>0
	
	
	 UPDATE A SET A.SplRate = (BaseQty*(( SelRate)+(SelRate*(P.TaxPerc/100)))) FROM  #TotClaim A 
	  INNER JOIN  #ParleOutputtaxPercentage P ON A.Refid = p.salid and a.slno = p.prdslno AND A.Tranid=P.Transid
	 WHERE A.Priceid =0
	
	 UPDATE A SET A.NrmlRate = (BaseQty*(( SelRate)+(SelRate*(P.TaxPerc/100)))) FROM  #TotClaim A 
	 INNER JOIN  #ParleOutputtaxPercentage P ON A.Refid = p.salid and a.slno = p.prdslno AND A.Tranid=P.Transid
	 
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
 	WHERE DiffClaims > 0 --- CRCRSTPAR0023  IF Difference of Claim Amt is Zero need not Shown
 	
	SET @RecCount = @RecCount + 1
	
	SET @RecCount1 = @RecCount1 +@RecCount + 1
	 
	-- Till here
	
	----------------------------------------MANUAL CLAIM Added By Amuthakumar CRCRSTAPAR0023 ---------------------------------------------
	
---------------- Added By Lakshman M Dated ON 07-12-2018 PMS ID: ILCRSTPAR2760 ----------- 
	--SELECT MCD.DESCRIPTION,MCM.MacDate As [From], MCM.MacDate AS [To],MCM.MacRefNo,ProposedLibPercent,TotalSales,ActualLibPercent,ClaimAmt
	--INTO #TotManualClaim
	--FROM ManualClaimMaster MCM INNER JOIN ManualClaimDetails MCD ON MCM.MacRefNo = MCD.MacRefNo
	--WHERE MacDate BETWEEN @FromDate AND @ToDate ------- commented by lakshman M on dated on 07-12-2018
	SELECT MCD.DESCRIPTION,A.MacDate As [From], A.MacDate AS [To],A.MacRefNo,ProposedLibPercent,TotalSales,ActualLibPercent,ClaimAmt
	INTO #TotManualClaim from ManualClaimMaster A 
	INNER JOIN ManualClaimDetails MCD ON A.MacRefNo = MCD.MacRefNo
	INNER JOIN  JCMonth B ON A.Jcmid = B.Jcmid AND A.FromJcmJcid = B.JcmJc AND A.ToJcmJcId = B.JcmJc 
	WHERE Jcmsdt  between @FromDate   AND @ToDate AND JcmEdt between @FromDate   AND @ToDate
 ----------------- Till Here -------------
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel4')
	BEGIN
		DROP TABLE RptDebitNoteTopSheet_Excel4	
	END		
	CREATE TABLE RptDebitNoteTopSheet_Excel4
	(
		[Scheme Description] NVARCHAR(200),
		[From] DATETIME,
		[TO] DATETIME,
		[Circular No] NVARCHAR(100),
		[Scheme Budget] NUMERIC(18,2),
	    [Sec Sales Value] NUMERIC(18,2),
	    [% Liability on Sec Sales] NUMERIC(18,2),
	    [Claim Amount] NUMERIC(18,2)
	)
		 
 	INSERT INTO RptDebitNoteTopSheet_Excel4
 	SELECT * FROM #TotManualClaim
 	
 	DECLARE @RecCount2 INT
	SELECT @RecCount2  = COUNT(*) FROM RptDebitNoteTopSheet_Excel3
		
	set @RecCount1 = @RecCount1+1
	SET @RecCount2 = @RecCount2 + @RecCount1 + 1
				
	-- Till Here CRCRSTAPAR0023
		
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
	--Added By Amuthakumar  CRCRSTAPAR0023
	SELECT 16,1,'A16','1R'
	UNION ALL
	SELECT 16 + @RecCount2 + 9,1,'A' + CAST(16 + @RecCount2 + 9 AS VARCHAR(10)) + ':J' + CAST(16 + @RecCount2 + 9 AS VARCHAR(10)) ,'5.MANUAL CLAIM'	
	UNION ALL
 	SELECT 16 + @RecCount2 + 11,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel4'
 	UNION ALL
 	SELECT 16 + @RecCount2 + 13,1,'A' + CAST(16 + @RecCount2 + 13 AS VARCHAR(10)),'4R'
	UNION ALL
	SELECT 16 + @RecCount2 + 12,1,'A' + CAST(16 + @RecCount2+12 AS VARCHAR(10)) + ':' + 'J' + CAST(16 + @RecCount2+12 AS VARCHAR(10)),''	
	UNION ALL--Till Here  CRCRSTAPAR0023
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
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_ValidateCSTimer' AND XTYPE ='P')
DROP PROCEDURE Proc_ValidateCSTimer
GO
--exec Proc_ValidateCSTimer '2018-12-28',1000,206
CREATE PROCEDURE Proc_ValidateCSTimer
(
@gServerDate DATETIME,
@iMode INT,
@TransId	INT
)
AS
/********************************************************************************************************************************************************************************
* PROCEDURE		: Proc_ValidateCSTimer
* PURPOSE		: To Validate the Server Date Details
* CREATED BY	: S.MOORTHI
* CREATED DATE	: 06/11/2018
* MODIFIED
* DATE        AUTHOR			CR/BZ	USER STORY ID		DESCRIPTION         
-----------------------------------------------------------------------      
 06-11-2018  S.Moorthi			CR		CRCRSTPAR0034       currently month end is happening on 6th day of month, this is happening based on system date. Is internet connection not available. 
															Need to get console server date through sync and validate user to perform month end process
 06-11-2018  S.Moorthi			CR		CRCRSTPAR0036       Back Date transaction should be allowed
 06-12-2018  M Lakshman         SR      ILCRSTPAR2752       In core stocky Proc_ValidateCSTimer fresh DB using that time stock ledger no records available. 
															Now validation added script level changes has been done.
 13-12-2018  M Lakshman         SR      ILCRSTPAR2927       As per client request Future date transaction wi allow only 5 days validation included in core stocky.							
********************************************************************************************************************************************************************************/ 
BEGIN
SET NOCOUNT ON
	DECLARE @CSDate AS DATETIME
	DECLARE @LocalDate AS DATETIME
	
	DECLARE @BackDateAllow AS DATETIME
	declare @TimInterval  AS NUMERIC(8,0)
	DECLARE @CSDateDD INT
	DECLARE @BackDateDays AS INT
	DECLARE @MonthEndDate AS DATETIME
	DECLARE @MaxTransDate AS DATETIME
	DECLARE @ValidateMsg AS VARCHAR(200)
	DECLARE @MonthEndDt AS DATETIME
	DECLARE @JCMONTHDT AS DATETIME
	DECLARE @ActMonthEndDt AS DATETIME
	DECLARE @MonthEndConfigDays AS INT
	DECLARE @csdateNew AS datetime
	

	IF NOT EXISTS(SELECT * FROM CSTimer (NOLOCK))
	BEGIN
		SELECT '' ValidMsg
		RETURN 
	END
	
	IF NOT EXISTS(SELECT * FROM StockLedger (NOLOCK))
	BEGIN
		SELECT '' ValidMsg
		RETURN 
	END


	SELECT @CSDate = CONVERT(VARCHAR(10),CSDate,121),@LocalDate = GETDATE() FROM CSTimer (NOLOCK)
	
	SELECT @MaxTransDate=ISNULL(MAX(TransDate),GETDATE()) FROM StockLedger (NOLOCK)
	--set @MaxTransDate=CONVERT(VARCHAR(10),@MaxTransDate,121)
	--SELECT @CSDate,@MaxTransDate


	SELECT  @csdateNew  = CSdate+4  from CSTimer (NOLOCK)
		--SELECT  csdateNew = CSdate  from CSTimer (NOLOCK)

	IF @csdateNew <= @gServerDate
	BEGIN	
		IF NOT EXISTS(SELECT * FROM CSTimer (NOLOCK) WHERE convert(varchar(10),CSDate,121) Between CONVERT(VARCHAR(10),@csdateNew,121) AND CONVERT (VARCHAR(10),@gServerDate,121) )
		BEGIN
			SELECT 'Please Change the System Date future date transaction will allow for only 5 days' ValidMsg
			RETURN 
		END
	END


	IF @MaxTransDate>@CSDate
	BEGIN
		SET @CSDate=@MaxTransDate		
		UPDATE CSTimer SET CSDate=@MaxTransDate
	END
	
	IF @iMode=1000 AND @TransId=206
	BEGIN
		IF @gServerDate>@CSDate
		BEGIN
			SET @CSDate=@gServerDate
			
			INSERT INTO CSTimerHistory(SyncId,ServerDate,CSDate,LocalDate,Upload)  
			SELECT SyncId,@gServerDate,@gServerDate,GETDATE(),Upload FROM CSTimer T (NOLOCK) 
			
			UPDATE CSTimer SET CSDate=@CSDate,ServerDate=@gServerDate,LocalDate=GETDATE()
		END
	END
	
	--select @BackDateDays,@CSDate
	IF EXISTS(SELECT * FROM CONFIGURATION WHERE MODULENAME='Month End Process' AND MODULEID='DAYMONTHEND1' AND CONFIGVALUE>0)
	BEGIN
		IF @iMode=0 AND @TransId=206
		BEGIN
			IF EXISTS(SELECT * fROM MANUALCONFIGURATION WHERE Moduleid='MonthEndServerDate' and status=1)
			BEGIN 
				goto xy
			END
		END
		
		SELECT @MonthEndConfigDays= ConfigValue FROM CONFIGURATION WHERE MODULENAME='Month End Process' AND MODULEID='DAYMONTHEND1'
		SET @ActMonthEndDt = dateadd(d,@MonthEndConfigDays,@gServerDate)
	
		SELECT @JCMONTHDT=Jcmsdt FROM JCMonth(NOLOCK) WHERE @CSDate BETWEEN JcmSdt AND JcmEdt 
		SET @MonthEndDt=dateadd(d,@MonthEndConfigDays,@JCMONTHDT)
	
		IF NOT EXISTS(SELECT * FROM JCMonthEnd (NOLOCK)	WHERE JcmEdt=DATEADD(D,-1,@JCMONTHDT) AND Status = 1)
		BEGIN
			IF @CSDate >= @MonthEndDt
			BEGIN
				IF @CSDate <> @gServerDate
					BEGIN
						SELECT 'Please change the System date with '+ CONVERT(NVARCHAR(20),@CSDate,103)+' and do Month End for '+DATENAME(M,DATEADD(D,-1,@JCMONTHDT))+' - '+CAST(YEAR(DATEADD(D,-1,@JCMONTHDT)) AS NVARCHAR(10)) as ValidMsg
						RETURN
						--SET @ValidateMsg='System Date does not match with Server Date. Please correct the system date and restart Sehyog to proceed.'
					END
			END
		END
	END
	xy:
	
	--select @BackDateAllow,@gServerDate
	IF EXISTS(SELECT * FROM ManualConfiguration(NOLOCK) WHERE ModuleId='CSTimer2' AND STATUS=1)
	BEGIN
		SELECT @BackDateDays = ISNULL(ConfigValue,0) FROM ManualConfiguration(NOLOCK) WHERE ModuleId='CSTimer2'
		SET @BackDateAllow=CONVERT(VARCHAR(10),DATEADD(D,-@BackDateDays+1,@CSDate),121)
		IF @BackDateAllow>@gServerDate
		BEGIN
			SELECT 'Back Date should be allow till '+ CONVERT(NVARCHAR(20),@BackDateAllow,103)+', Please Change the System Date and re-open Sehyog to continue ' ValidMsg
			--SELECT 'Back Date should be allow till '+ CONVERT(NVARCHAR(20),@BackDateAllow,103)+', Please Change System Date to '+ CONVERT(NVARCHAR(20),@CSDate,103)+' and re-open Sehyog to continue ' ValidMsg
			RETURN
		END
	END
	
	
	--Back Date Transaction Not Allowed, Please Change System Date to 
	--IF @CSDate>@gServerDate
	--BEGIN
	--	SELECT 	'Please change System date to '+ CONVERT(NVARCHAR(20),@CSDate,103)+' and re-open Sehyog to continue ' ValidMsg
	--	RETURN
	--END
	
	SELECT '' ValidMsg
	
RETURN 
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_RptSchemeUtilization_Parle]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_RptSchemeUtilization_Parle]
GO
/*
BEGIN TRAN
EXEC Proc_RptSchemeUtilization_Parle 246,1,0,'PARLEDEBIT NOTE123',0,0,1
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[Proc_RptSchemeUtilization_Parle]
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
* PROCEDURE: Proc_RptSchemeUtilization
* PURPOSE: Procedure To Return the Scheme Utilization for the Selected Filters
* NOTES:
* CREATED: Thrinath Kola	30-07-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*Modified by Praveenraj B For Parle Scheme Utilization Report On 25/01/2012
***************************************************************************************************
* DATE       AUTHOR			CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
12-10-2017  Mohana.S		CR      CCRSTPAR0175          Showing Slab Details Instead of Slab id 
08-12-2017  Mary.S			BZ      ICRSTPAR6933          Showing Slab wise Budget utilized Details   
12-12-2017  Mohana.S		BZ      ICRSTPAR6933          Showing Slab wise Details (all columns) 
19-12-2018  Vasantharaj R   SR      ILCRSTPAR2868         As per Client request [All the report must be generate based on Date range selection.] 
***************************************************************************************************/  
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
	DECLARE @FromDate	      AS 	DateTime
	DECLARE @ToDate		      AS	DateTime
	DECLARE @fSchId		      AS	Int
	DECLARE @fSMId		      AS	Int
	DECLARE @fRMId		      AS 	Int
	DECLARE @CtgLevelId           AS    	INT
	DECLARE @CtgMainId  	      AS    	INT
	DECLARE @RtrClassId           AS    	INT
	DECLARE @fRtrId		      AS	INT
	DECLARE @TempCtgLevelId       AS    	INT
	
	DECLARE @TempData	TABLE
	(	
		SchId	Int,
		Slabid INT,
		RtrCnt	Int,
		BillCnt	Int
	)
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @fSchId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))
	SET @fSMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @fRMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @CtgLevelId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @CtgMainId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @RtrClassId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @fRtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	--Till Here
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	SELECT DISTINCT Prdid,U.ConversionFactor 
	Into #PrdUomBox
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	Inner Join UomMaster UM On U.UomId=Um.UomId
	--Where Um.UomCode='BX'--Commented and added by Rajesh ICRSTPAR3196
	Where Um.UomCode IN('BX','BOX')
		
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
	
CREATE TABLE #RptStoreSchemeDetails
(
	[SchId] [int] NULL,
	[SlabId] [int] NULL,
	[ReferNo] [nvarchar](100) COLLATE DATABASE_DEFAULT  NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[DlvRMId] [int] NULL,
	[RtrId] [int] NULL,
	[DlvSts] [int] NULL,
	[VehicleId] [int] NULL,
	[DlvBoyId] [int] NULL,
	[PrdID] [int] NULL,
	[PrdBatId] [int] NULL,
	[FlatAmount] [numeric](38, 6) NULL,
	[DiscountPer] [numeric](38, 6) NULL,
	[Points] [int] NULL,
	[FreePrdId] [int] NULL,
	[FreePrdBatId] [int] NULL,
	[FreeQty] [int] NULL,
	[FreeValue] [numeric](38, 6) NULL,
	[GiftPrdId] [int] NULL,
	[GiftPrdBatId] [int] NULL,
	[GiftQty] [int] NULL,
	[GiftValue] [numeric](38, 6) NULL,
	[SchemeBudget] [numeric](38, 6) NULL,
	[BudgetUtilized] [numeric](38, 6) NULL,
	[Selected] [tinyint] NULL,
	[UserId] [int] NULL,
	[SMName] [nvarchar](200)  COLLATE DATABASE_DEFAULT NULL,
	[RMName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[DlvRMName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[RtrName] [nvarchar](200)  COLLATE DATABASE_DEFAULT  NULL,
	[VehicleName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[DeliveryBoyName] [nvarchar](200)COLLATE DATABASE_DEFAULT   NULL,
	[PrdName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[BatchName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[FreePrdName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[FreeBatchName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[GiftPrdName] [nvarchar](200)COLLATE DATABASE_DEFAULT   NULL,
	[GiftBatchName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[LineType] [int] NULL,
	[ReferDate] [datetime] NULL,
	[CtgLevelId] [int] NULL,
	[CtgLevelName] [nvarchar](200)COLLATE DATABASE_DEFAULT  NULL,
	[CtgMainId] [int] NULL,
	[CtgName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[RtrClassId] [int] NULL,
	[ValueClassName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[BaseQty] [Int],
	[BaseQtyBox] [Int],
	[BaseQtyPack] [Int],
	TAX NUMERIC(38,6)
) ON [PRIMARY]
	
	Create TABLE #RptSchemeUtilizationDet_Parle
	(
		SchId		Int,
		SchCode		nVarChar(100),
		SchDesc		nVarChar(500),
		SlabId		nVarChar(50),
		SchemeBudget	Numeric(38,6),
		BudgetUtilized	Numeric(38,6),
		NoOfRetailer	Int,
		NoOfBills	Int,
		UnselectedCnt	Int,
		FlatAmount	Numeric(38,6),
		DiscountPer	Numeric(38,6),
		Points		Int,
		FreePrdName	nVarchar(200),
		FreeQty		Int,
		[BaseQty] [Int],
		BaseQtyBox	Int,
		BaseQtyPack Int,
		FreeValue	Numeric(38,6),
		GiftPrdName	nVarchar(200),
		GiftQty		Int,
		GiftValue	Numeric(38,6),
		[CircularNo] [Nvarchar](50),
		Tax NUMERIC(38,6)
	)
	SET @TblName = '#RptSchemeUtilizationDet_Parle'
	
	SET @TblStruct = '	SchId		Int,
				SchCode		nVarChar(100),
				SchDesc		nVarChar(500),
				SlabId		nVarChar(10),
				SchemeBudget	Numeric(38,6),
				BudgetUtilized	Numeric(38,6),
				NoOfRetailer	Int,
				NoOfBills	Int,
				UnselectedCnt	Int,
				FlatAmount	Numeric(38,6),
				DiscountPer	Numeric(38,6),
				Points		Int,
				FreePrdName	nVarchar(50),
				FreeQty		Int,
				[BaseQty] [Int],
				BaseQtyBox	Int,
				BaseQtyPack Int,
				FreeValue	Numeric(38,6),
				GiftPrdName	nVarchar(50),
				GiftQty		Int,
				GiftValue	Numeric(38,6)'
	SET @TblFields = 'SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,BaseQty,BaseQtyBox,BaseQtyPack,FreeValue,
		GiftPrdName,GiftQty,GiftValue'
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
		EXEC Proc_RptStoreSchemeDetailsSlab @Pi_RptId,@Pi_UsrId --ICRSTPAR6933
	
		--Added By Nanda on 13/02/2009
--		IF @CtgLevelId=0 
--		BEGIN			
--			SELECT @TempCtgLevelId=MAX(CtgLevelId) FROM RetailerCategoryLevel
--		END
--		ELSE
--		BEGIN
			SELECT @TempCtgLevelId=iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)
--		END
		--Till Here
		
			CREATE TABLE #SalesSchemeDetailsTax	
			(
			SalInvNo		nVarChar(100),
			SchId			INT,
			SlabId			INT, 
			PrdId			INT,
			PrdBatId		INT,
			SlNo            INT,
			GSTTax          Numeric(38,6)
			)
			CREATE TABLE #ReturnSchemeDetailsTax	
			(
			SalInvNo		nVarChar(100),
			SchId			INT,
			SlabId			INT, 
			PrdId			INT,
			PrdBatId		INT,
			SlNo            INT,
			GSTTax          Numeric(38,6)
			)
			INSERT INTO #SalesSchemeDetailsTax (SalInvNo,SchId,SlabId,PrdId,PrdBatId,SlNo ,GSTTax  )
			SELECT B.SalInvno,A.SchId,A.SlabId,A.PrdId,A.PrdBatId,A.Rowid,
			SUM((FlatAmount + DiscountPerAmount)*(C.TaxPerc/100)) ---Gopi at 27/06/2017
			FROM SalesInvoiceSchemeLineWise A(NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)ON A.SalId = B.SalId 
			INNER JOIN SalesInvoiceProductTax C(NOLOCK) ON C.SalId=A.SalId AND C.SalId=B.SalId
			AND C.PrdSlNo=A.RowId
			WHERE DlvSts in (4,5)  AND C.TaxPerc>0.00
			AND B.SalInvDate Between @FromDate AND @tODate
			GROUP BY B.SalInvno,A.SchId,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
	
			INSERT INTO #ReturnSchemeDetailsTax(SalInvNo,SchId,SlabId,PrdId,PrdBatId,SlNo,GSTTax)
			SELECT B.ReturnCode,A.SchId,A.SlabId,A.Prdid,A.Prdbatid,A.RowId,
			Sum((ReturnFlatAmount + ReturnDiscountPerAmount)*(C.TaxPerc/100))*-1
			FROM ReturnSchemeLineDt A (NOLOCK) INNER JOIN ReturnHeader B(NOLOCK) ON A.ReturnId = B.ReturnId 
			INNER JOIN ReturnProductTax C(NOLOCK) ON C.ReturnId=A.ReturnID AND C.ReturnId=B.ReturnID
			AND C.PrdSlno=A.RowId
			WHERE B.Status = 0 AND C.TaxPerc>0.00
			AND B.ReturnDate Between   @FromDate AND @tODate
			GROUP BY B.ReturnCode,A.SchId,A.SlabId,A.Prdid,A.Prdbatid,A.RowId
		
			
		Insert Into #RptStoreSchemeDetails(SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,RtrId,DlvSts,VehicleId,DlvBoyId,PrdID,PrdBatId,FlatAmount,DiscountPer,
										   Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,GiftQty,GiftValue,SchemeBudget,BudgetUtilized,
										   Selected,UserId,SMName,RMName,DlvRMName,RtrName,VehicleName,DeliveryBoyName,PrdName,BatchName,FreePrdName,FreeBatchName
										   ,GiftPrdName,GiftBatchName,LineType,ReferDate,CtgLevelId,CtgLevelName,CtgMainId,CtgName,RtrClassId,ValueClassName,BaseQty,BaseQtyBox,BaseQtyPack) 
		Select SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,RtrId,DlvSts,VehicleId,DlvBoyId,PrdID,PrdBatId,FlatAmount,DiscountPer,
										   Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,GiftQty,GiftValue,SchemeBudget,BudgetUtilized,
										   Selected,UserId,SMName,RMName,DlvRMName,RtrName,VehicleName,DeliveryBoyName,PrdName,BatchName,FreePrdName,FreeBatchName
										   ,GiftPrdName,GiftBatchName,LineType,ReferDate,CtgLevelId,CtgLevelName,CtgMainId,CtgName,RtrClassId,ValueClassName,0,0,0
										  From RPTStoreSchemeDetails Where Userid = @Pi_UsrId AND BudgetUtilized>0
		
		
		UPDATE A SET Tax = B.GSTTax FROM #RptStoreSchemeDetails A INNER JOIN #SalesSchemeDetailsTax B ON A.SchId = B.SchId AND A.ReferNo = B.SalInvNo AND B.PrdId=A.Prdid 
		AND B.PrdBatId = A.PrdBatid AND A.LineType = 1
		UPDATE A SET Tax = B.GSTTax FROM #RptStoreSchemeDetails A INNER JOIN #returnSchemeDetailsTax B ON A.SchId = B.SchId AND A.ReferNo = B.SalInvNo AND B.PrdId=A.Prdid 
		AND B.PrdBatId = A.PrdBatid AND A.LineType = 2		
		
		--Select Distinct ReferNo,BaseQty,PrdId,PrdBatId Into #RptScheme From #RptStoreSchemeDetails Where LineType<>3 And Userid = @Pi_UsrId
		--Changed By Mohana
		Update X Set X.BaseQty=Sp.BaseQty --Case When FreeValue=0 Then Sp.BaseQty Else 0 End
			From SalesInvoice S
					Inner Join (SELECT A.SalId,slabid,a.PrdId,a.PrdBatId,SUM(BaseQty) AS BaseQty FROM SalesInvoiceProduct A INNER JOIN SalesInvoiceSchemeLineWise B ON 
					A.salid =b.salid and B.Prdid=A.Prdid AND A.prdbatid =B.prdbatid 
					GROUP BY A.SalId,slabid,a.PrdId,a.PrdBatId,slabid) SP On S.SalId=SP.SalId					 
					Inner Join  #RptStoreSchemeDetails X On X.ReferNo=S.SalInvNo And X.PrdID=SP.PrdId And X.PrdBatId=SP.PrdBatId and sp.slabid=x.slabid
					Inner join  #PrdUomAll PU On PU.PrdId=X.PrdID
				 Where X.LineType<>3 
		--SELECT 'lll', * FROM #RptStoreSchemeDetails
--EXEC Proc_RptSchemeUtilization_Parle 237,1,0,'Henkel',0,0,1
		
		--SELECT * FROM #RptStoreSchemeDetails Inner join  #PrdUomAll PU On PU.PrdId=#RptStoreSchemeDetails.PrdID
		--Changed By Mohana
		
		SELECT DISTINCT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.PrdID,SUM(Discountper) Discountper,ISNULL(Sum(BaseQty),0) as BaseQty,
		Case When Isnull(Sum(BaseQty),0)<MAX(ConversionFactor) Then 0 Else Isnull(Sum(BaseQty),0)/MAX(ConversionFactor) End As BaseQtyBox,
		Case When Isnull(Sum(BaseQty),0)<MAX(ConversionFactor) Then Isnull(Sum(BaseQty),0) Else Isnull(Sum(BaseQty),0)%MAX(ConversionFactor) End As BaseQtyPack
		INTO #ProductUOM
		FROM SchemeMaster A INNER JOIN #RPTStoreSchemeDetails B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId
		Inner Join #PrdUomAll PU On PU.PrdId=B.PrdID
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		B.LineType <> 3 AND BudgetUtilized>0
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.PrdID
		 
							   
		INSERT INTO #RptSchemeUtilizationDet_Parle(SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
			NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,BaseQty,BaseQtyBox,BaseQtyPack,FreeValue,
			GiftPrdName,GiftQty,GiftValue,CircularNo,Tax)
		SELECT DISTINCT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,Count(Distinct B.RtrId),
			Count(Distinct B.ReferNo),0 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
			CASE FreePrdId WHEN 0 THEN dbo.Fn_ConvertCurrency(ISNULL(SUM(B.DiscountPer),0),@Pi_CurrencyId) ELSE '0.00' END as DiscountPer,
			ISNULL(SUM(Points),0) as Points,CASE ISNULL(SUM(FreeQty),0) WHEN 0 THEN '' ELSE FreePrdName END AS FreePrdName,
			CASE FreePrdName WHEN '' THEN 0 ELSE ISNULL(SUM(FreeQty),0)  END as FreeQty,0 as BaseQty,
			 0 as BaseQtyBox,
			0 as BaseQtyPack,
			ISNULL(SUM(FreeValue),0) as FreeValue,
			CASE ISNULL(SUM(GiftValue),0) WHEN 0 THEN '' ELSE GiftPrdName END AS GiftPrdName,ISNULL(SUM(GiftQty),0) as FreeQty,
			ISNULL(SUM(GiftValue),0) as GiftValue,isnull(BudgetAllocationNo,''),CASE A.ApplyTaxForClaim WHEN 1 THEN SUM(tax) ELSE 0 END AS Tax
		FROM SchemeMaster A INNER JOIN #RPTStoreSchemeDetails B On A.SchId= B.SchId
			AND B.Userid = @Pi_UsrId
		Inner Join #ProductUOM PU On PU.PrdId=B.PrdID
		WHERE ReferDate Between @FromDate AND @ToDate  AND
			(B.SMId = (CASE @fSMId WHEN 0 THEN B.SMId Else 0 END) OR
			B.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
			(B.RMId = (CASE @fRMId WHEN 0 THEN B.RMId Else 0 END) OR
			B.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
			(B.CtgLevelId = (CASE @TempCtgLevelId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
			B.CtgLevelId in (@TempCtgLevelId)) AND
			(B.CtgMainId = (CASE @CtgMainId WHEN 0 THEN B.CtgMainId Else 0 END) OR
			B.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.RtrClassId = (CASE @RtrClassId WHEN 0 THEN B.RtrClassId Else 0 END) OR
			B.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
			(B.RtrID = (CASE @fRtrId WHEN 0 THEN B.RtrID Else 0 END) OR
			B.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
			(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
			A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
			B.LineType <> 3 AND BudgetUtilized>0
		GROUP BY A.SchId,B.SlabId,A.SchCode,A.SchDsc,B.SchemeBudget,B.BudgetUtilized,FreePrdId,
			FreePrdName,GiftPrdName,BudgetAllocationNo,ApplyTaxForClaim--,B.PrdID 
		
		UPDATE A SET Discountper=b.Discountper, BaseQty=B.BaseQty,BaseQtyBox=B.BaseQtyBox,BaseQtyPack=B.BaseQtyPack FROM #RptSchemeUtilizationDet_Parle A INNER JOIN 
		(SELECT SchId,SlabId,SUM(Discountper) Discountper,SUM(BaseQty) BaseQty,SUM(BaseQtyBox) BaseQtyBox,SUM(BaseQtyPack) BaseQtyPack FROM #ProductUOM
		GROUP BY SchId,Slabid
		) B ON A.SchId=B.SchId
		AND A.SlabId=B.SlabId
	 
				
			
		UPDATE A SET A.DiscountPer= (CASE FreePrdName WHEN '' THEN CAST(B.FlatAmt AS NUMERIC(18,2)) ELSE '0.00' END) FROM #RptSchemeUtilizationDet_Parle A INNER JOIN 
		(SELECT SchId,SlabId,SUM(FlatAmount)+SUM(DiscountPer) AS FlatAmt FROM #RptSchemeUtilizationDet_Parle GROUP BY SchId,SlabId) B
		ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		
		SELECT SchId,SlabId,ReferNo,RtrId INTO #TempBilledDt FROM RptStoreSchemeDetails WHERE LineType <> 3
		
		
		--UPDATE A SET NoOfBills = BillCnt FROM #RptSchemeUtilizationDet_Parle A INNER JOIN 
		--(SELECT SchId,SlabId,COUNT(DISTINCT ReferNo) AS BillCnt FROM
		--#TempBilledDt GROUP By SchId,SlabId) B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		
		--UPDATE A SET NoOfRetailer = RtrCnt FROM #RptSchemeUtilizationDet_Parle A INNER JOIN 
		--(SELECT SchId,SlabId,COUNT(DISTINCT RtrId) AS RtrCnt FROM
		--#TempBilledDt GROUP By SchId,SlabId) B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
				
		DELETE FROM #RptSchemeUtilizationDet_Parle WHERE (BaseQtyBox+BaseQtyPack+FreeQty+GiftQty)<=0
		
		DELETE FROM @TempData
	
		INSERT INTO @TempData(SchId,Slabid,RtrCnt,BillCnt)
		SELECT SchId,B.Slabid, Count(Distinct B.RtrId),Count(Distinct ReferNo)
		FROM RPTStoreSchemeDetails B 
		WHERE ReferDate Between @FromDate AND @ToDate  AND B.Userid = @Pi_UsrId AND
			(B.SMId = (CASE @fSMId WHEN 0 THEN B.SMId Else 0 END) OR
			B.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
			(B.RMId = (CASE @fRMId WHEN 0 THEN B.RMId Else 0 END) OR
			B.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
			(B.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
			B.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
			(B.CtgMainId = (CASE @CtgMainId WHEN 0 THEN B.CtgMainId Else 0 END) OR
			B.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.RtrClassId = (CASE @RtrClassId WHEN 0 THEN B.RtrClassId Else 0 END) OR
			B.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
			(B.RtrID = (CASE @fRtrId WHEN 0 THEN B.RtrID Else 0 END) OR
			B.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
			(B.SchId = (CASE @fSchId WHEN 0 THEN B.SchId Else 0 END) OR
			B.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
			B.LineType = 1
		GROUP BY B.SchId,B.Slabid
		
		UPDATE #RptSchemeUtilizationDet_Parle SET NoOfRetailer = NoOfRetailer,
			NoOfBills = BillCnt FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet_Parle.SchId AND B.Slabid = #RptSchemeUtilizationDet_Parle.SlabId
	
		DELETE FROM @TempData
	
		INSERT INTO @TempData(SchId,Slabid,RtrCnt,BillCnt)
		SELECT SchId,B.Slabid,  Count(Distinct B.RtrId),Count(Distinct ReferNo)
		FROM RPTStoreSchemeDetails B
		WHERE ReferDate Between @FromDate AND @ToDate  AND B.Userid = @Pi_UsrId AND
			(B.SMId = (CASE @fSMId WHEN 0 THEN B.SMId Else 0 END) OR
			B.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
			(B.RMId = (CASE @fRMId WHEN 0 THEN B.RMId Else 0 END) OR
			B.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
			(B.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
			B.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
			(B.CtgMainId = (CASE @CtgMainId WHEN 0 THEN B.CtgMainId Else 0 END) OR
			B.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.RtrClassId = (CASE @RtrClassId WHEN 0 THEN B.RtrClassId Else 0 END) OR
			B.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
			(B.RtrID = (CASE @fRtrId WHEN 0 THEN B.RtrID Else 0 END) OR
			B.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
			(B.SchId = (CASE @fSchId WHEN 0 THEN B.SchId Else 0 END) OR
			B.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
			B.LineType = 3
			AND CAST(B.SchId AS VARCHAR(10))+'~'+CAST(B.SlabId AS VARCHAR(10))+'~'+CAST(B.RtrId AS VARCHAR(10)) NOT IN 
			(Select DISTINCT CAST(SchId AS VARCHAR(10))+'~'+CAST(SlabId AS VARCHAR(10))+'~'+CAST(RtrId AS VARCHAR(10)) FROM #TempBilledDt)
			GROUP BY B.SchId,B.Slabid
			
		UPDATE #RptSchemeUtilizationDet_Parle SET UnselectedCnt = RtrCnt
			FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet_Parle.SchId AND B.Slabid = #RptSchemeUtilizationDet_Parle.SlabId
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptSchemeUtilizationDet_Parle ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
				' WHERE ReferDate Between ''' + @FromDate + ''' AND ''' + @ToDate + '''AND '+
				' (SMId = (CASE ' + CAST(@fSMId AS nVarchar(10)) + ' WHEN 0 THEN SMId Else 0 END) OR '+
				' SMId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (RMId = (CASE ' + CAST(@fRMId AS nVarchar(10)) + ' WHEN 0 THEN RMId Else 0 END) OR '+
				' RMId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (CtgLevelId = (CASE ' + CAST(@CtgLevelId AS nVarchar(10)) + ' WHEN 0 THEN CtgLevelId Else 0 END) OR '+
				' CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (CtgMainId = (CASE ' + CAST(@CtgMainId AS nVarchar(10)) + ' WHEN 0 THEN CtgMainId Else 0 END) OR '+
				' CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (RtrClassId = (CASE ' + CAST(@RtrClassId AS nVarchar(10)) + ' WHEN 0 THEN RtrClassId Else 0 END) OR '+
				' RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (RtrID = (CASE ' + CAST(@fRtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrID Else 0 END) OR ' +
				' RtrID in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (SchId = (CASE ' + CAST(@fSchId AS nVarchar(10)) + ' WHEN 0 THEN SchId Else 0 END) OR ' +
				' SchId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',8,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
	
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSchemeUtilizationDet_Parle'
				
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
			SET @SSQL = 'INSERT INTO #RptSchemeUtilizationDet_Parle ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSchemeUtilizationDet_Parle
	-- Till Here
	--UPDATE A SET BaseQty = B.BaseQty FROM #RptSchemeUtilizationDet_Parle A INNER JOIN
	--(SELECT C.SchId,(SUM(B.BaseQty)-SUM(ReturnedQty)) AS BaseQty FROM Salesinvoice A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
	--INNER JOIN 
	--(SELECT DISTINCT ReferNo,B.PrdId,A.SchId,SlabId FROM RptStoreSchemeDetails A INNER JOIN Fn_ReturnSchemeProductWithScheme() B ON 
	--A.SchId=B.SchId)C ON A.SalInvNo=C.ReferNo AND B.PrdId=C.PrdId GROUP BY C.SchId,slabid) B ON A.SchId=B.SchId 
	
	UPDATE A SET FreeQty = (CASE FreePrdName WHEN '' THEN 0 ELSE B.FreeQty END) FROM #RptSchemeUtilizationDet_Parle A INNER JOIN
	(SELECT C.SchId,(SUM(B.FreeQty)- SUM(ReturnFreeQty)) AS FreeQty FROM Salesinvoice A INNER JOIN SalesInvoiceSchemeDtFreePrd B ON A.SalId=B.SalId
	INNER JOIN 
	(SELECT DISTINCT ReferNo,A.FreePrdId,A.SchId FROM RptStoreSchemeDetails A INNER JOIN Fn_ReturnSchemeProductWithScheme() B ON 
	A.SchId=B.SchId AND A.FreePrdId > 0)C ON A.salInvNo=C.ReferNo GROUP BY C.SchId) B ON A.SchId=B.SchId
	
	--UPDATE A SET NoOfBills = B.BillCnt FROM #RptSchemeUtilizationDet_Parle A INNER JOIN
	--(SELECT SchId,SUM(BillCnt) As BillCnt FROM 
	--(SELECT  CASE LineType WHEN 1 THEN COUNT(DISTINCT ReferNo) ELSE COUNT(DISTINCT ReferNo) *-1 END 
	--AS BillCnt,A.SchId,LineType FROM RptStoreSchemeDetails A INNER JOIN Fn_ReturnSchemeProductWithScheme() B ON 
	--A.SchId=B.SchId AND A.FreePrdId<>0 GROUP BY A.SchId,LineType) A GROUp By SchId) B ON A.SchId=B.SchId
	UPDATE RPT SET RPT.SchCode=S.CmpSchCode FROM #RptSchemeUtilizationDet_Parle RPT INNER JOIN SchemeMaster S ON RPT.SchId=S.SchId 
	UPDATE #RptSchemeUtilizationDet_Parle SET DiscountPer = DiscountPer+Tax 
	
	
--Added By Mohana	
	SELECT A.SchId ,B.SlabId, CASE B.PurQty WHEN 0 THEN CONVERT (NVARCHAR(20),B.FromQty) + '-' + CONVERT(NVARCHAR(20),B.ToQty)
	ELSE  CONVERT (NVARCHAR(20),B.PurQty) + '-' + CONVERT(NVARCHAR(20),B.ToQty)END Slabdet INTO #SlabDet FROM SchemeMaster A INNER JOIN SchemeSlabs B ON A.SchId = B.SchId
	INNER JOIN #RptSchemeUtilizationDet_Parle R on R.schid=a.schid  and R.schid=b.SchId and R.slabid=b.SlabId 
	UPDATE A SET SlabId = Slabdet FROM #RptSchemeUtilizationDet_Parle A INNER JOIN #SlabDet B ON A.SchId =B.Schid AND A.SlabId = B.slabid
--Till here
    --SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,
	SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,DiscountPer AS BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,--ILCRSTPAR2868 
	UnselectedCnt,(BaseQtyBox) AS BaseQtyBox,(BaseQtyPack) AS BaseQtyPack,
	DiscountPer,(CASE FreeQty WHEN 0 THEN '-' ELSE FreePrdName END) AS FreePrdName,FreeQty,
    (CASE FreeQty WHEN 0 THEN '0.00' ELSE FreeValue END) AS FreeValue,FlatAmount,Points,(BaseQty) AS BaseQty,
	GiftPrdName,GiftQty,GiftValue
	FROM #RptSchemeUtilizationDet_Parle 
	
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'RptSchemeUtilizationDet_Parle_Excel') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationDet_Parle_Excel
		    --SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,
			SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,DiscountPer AS BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,--ILCRSTPAR2868 
			UnselectedCnt,(BaseQtyBox) AS BaseQtyBox,(BaseQtyPack) AS BaseQtyPack,
			DiscountPer,(CASE FreeQty WHEN 0 THEN '-' ELSE FreePrdName END) AS FreePrdName,FreeQty,
			(CASE FreeQty WHEN 0 THEN '0.00' ELSE FreeValue END) AS FreeValue,FlatAmount,Points,(BaseQty) AS BaseQty,
			GiftPrdName,GiftQty,GiftValue
			INTO RptSchemeUtilizationDet_Parle_Excel FROM #RptSchemeUtilizationDet_Parle Order By SchId
	END 
RETURN
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_SalesReturn]') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Cs2Cn_SalesReturn
GO
--BEGIN tran
--delete from Cs2Cn_Prk_SalesReturn
--EXEC Proc_Cs2Cn_SalesReturn 0,'2018-12-21'
--select * from Cs2Cn_Prk_SalesReturn where SRNRefNo ='PGST1800460'
--ROLLBACK tran
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
***************************************************************************************************  
* DATE         AUTHOR         CR/BZ    USER STORY ID           DESCRIPTION                           
***************************************************************************************************  
21-12-2018   Lakshman M        SR      ILCRSTPAR2905        AS per client request LCTR Formula validation changed special price not consider Now default price only considered in LCTR Value. 
*********************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @CmpId    AS INT  
 DECLARE @DistCode  As nVarchar(50)  
 DECLARE @DefCmpAlone AS INT  
 SET @Po_ErrNo=0 

DECLARE @FromDate DATETIME  
DECLARE @ToDate DATETIME  
SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) FROM UploadingReportTransaction S (NOLOCK)
EXEC Proc_SchUtilization_Report @FromDate,@ToDate
EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate  

SELECT * INTO #ParleOutputTaxPercentage  FROM ParleOutputTaxPercentage (NOLOCK) 
DECLARE @SlNo AS INT  
SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
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
  UploadFlag,
  RtrUniqueCode  
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
  'N' AS UploadFlag,ISNULL(R.RtrUniqueCode,'')  
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
 -------------- Added By LAkshman M dated ON 21-12-2018 PMS ID: ILCRSTPAR2905
 UPDATE PRK SET PRK.LCTRAmount=ISNULL(LCTRAmt,0)
 FROM Cs2Cn_Prk_SalesReturn PRK (NOLOCK)
 INNER JOIN 
 (
	SELECT R.ReturnId,R.ReturnCode,P.PrdCCode,PB.CmpBatCode,
	--(SUM(RP.BaseQty)*RP.PrdEditSelRte)+(SUM(RP.BaseQty)*RP.PrdEditSelRte)*(RPT.TaxPerc/100) AS LCTRAmt,
	ROUND(((Rp.BaseQty *(PBD.PrdBatDetailValue))+(Rp.BaseQty*PBD.PrdBatDetailValue)*(T.TaxPerc/100)),2) AS LCTRAmt,
	SUM(RPT.TaxableAmt) AS TaxableAmt,RPT.TaxPerc  
	FROM ReturnHeader R (NOLOCK)
	INNER JOIN ReturnProduct RP (NOLOCK) ON R.RETURNID=RP.RETURNID
	INNER JOIN ReturnProductTax RPT (NOLOCK) ON R.RETURNID=RPT.RETURNID AND RP.RETURNID=RPT.RETURNID AND RP.SlNO=RPT.PrdSlNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=RP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId AND PB.PrdId=RP.PrdId AND RP.PrdBatId=PB.PrdBatId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =PB.PrdBatId and DefaultPrice =1 AND PBD.SLNo =3
	INNER JOIN Cs2Cn_Prk_SalesReturn Prk (NOLOCK) ON Prk.PrdCode=P.PrdCCode AND Prk.PrdBatCde=PB.CmpBatCode
	INNER JOIN #ParleOutputTaxPercentage T (NOLOCK) ON R.SalId = T.Salid AND Rp.Slno = T.PrdSlno
	GROUP BY R.ReturnId,R.ReturnCode,P.PrdCCode,PB.CmpBatCode,RPT.TaxPerc,RP.PrdEditSelRte,Rp.BaseQty,PBD.PrdBatDetailValue,T.TaxPerc
	HAVING (SUM(RPT.TaxableAmt))>0
 ) Z ON Z.ReturnCode=PRK.SRNRefNo AND Z.PrdCCode=PRK.PrdCode AND Z.CmpBatCode=PRK.PrdBatCde
 ------------ Till here  ---------------
 UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),  
 ProcDate = CONVERT(nVarChar(10),GetDate(),121)  
 Where ProcId = 4  
 
 UPDATE ReturnHeader SET Upload=1 WHERE Upload=0 AND ReturnCode IN (SELECT DISTINCT  
 SRNRefNo FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'N') AND Status=0   
 
 UPDATE Cs2Cn_Prk_SalesReturn SET ServerDate=@ServerDate
 
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_ValidateDayEndProcess' AND XTYPE ='P')
DROP PROCEDURE Proc_ValidateDayEndProcess
GO 
---EXEC Proc_ValidateDayEndProcess '2012-02-07'
--SELECT * FROM DayEndValidation
CREATE PROCEDURE Proc_ValidateDayEndProcess
(
	@Pi_Fromdate AS DATETIME
)
AS
BEGIN
/*********************************
* PROCEDURE: Proc_ValidateDayEndProcess
* PURPOSE: To Validate the Day end
* NOTES: 
* CREATED:Murugan.R
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
* 17-07-2013 Praveenraj B for adding master user access validation for GCPL
------------------------------------------------*/
--DayEnd Type 1 --Find Jc Mont exists
--DayEnd Type 2 --Pending Day End
DECLARE @MonthEnd AS TINYINT
DECLARE @Pi_JcFromdate AS DATETIME
DECLARE @Pi_JcTodate AS DATETIME
DECLARE @CheckPendingTransaction AS TINYINT
DELETE FROM DayEndValidation
SET @MonthEnd=0
SET @CheckPendingTransaction=0
----------- Added By lakshman M Dated ON 07/01/2018 PMS ID: ILCRSTPAR3026 -------------
IF NOT EXISTS(SELECT * FROM stockledger)
BEGIN
	Return
END
----------- Till here -----------
IF NOT EXISTS(SELECT J.JcmId,JcmJc,JcmYr,JcmSdt,JcmEdt FROM JcMast J INNER JOIN Jcmonth Jc ON J.JcmId=Jc.JcmId INNER JOIN Company C On C.CmpId=J.CmpId
WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121) BETWEEN JcmSdt and JcmEdt And DefaultCompany=1)
BEGIN
	INSERT INTO DayEndValidation(DayEndType,DayEndStartDate,Status)
	SELECT 1,CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121),1
END	

SELECT  MIN(DayEndStartDate) as  DayEndStartDate 
INTO #DayEndExists
FROM DayEndDates WHERE DayEndStartDate<CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121)
AND Status=0

IF EXISTS(SELECT  * FROM #DayEndExists WHERE DayEndStartDate IS NOT NULL)
BEGIN
	INSERT INTO DayEndValidation(DayEndType,DayEndStartDate,Status)
	SELECT 2, MIN(DayEndStartDate) ,1 FROM DayEndDates WHERE DayEndStartDate<CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121)
	AND Status=0
END

IF EXISTS(SELECT TOP 1 JcmSdt,JcmEdt from JcmonthEnd WHERE Status=0 ORDER BY JcmSdt)
BEGIN
	SELECT TOP 1 JcmSdt,JcmEdt INTO #JCEND FROM JcmonthEnd WHERE Status=0 ORDER BY JcmSdt
	SELECT @Pi_JcFromdate=JcmSdt,@Pi_JcTodate=JcmEdt FROM #JCEND 
	IF NOT EXISTS(SELECT * from Dayenddates WHERE DayEndstartdate BETWEEN @Pi_JcFromdate and @Pi_JcTodate and Status=0)
	BEGIN
		INSERT INTO DayEndValidation(DayEndType,DayEndStartDate,Status)
		SELECT 3,JcmEdt ,1 FROM #JCEND 		
	END

END
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='PROC_CN2CS_RETAILERMIGRATION' AND XTYPE ='P')
DROP PROCEDURE Proc_Cn2Cs_RetailerMigration
GO
/*
Begin transaction
delete from ErrorLog
select * from RetailerMasterMigration
exec Proc_Cn2Cs_RetailerMigration 0
select * from RetailerMasterMigration
select * from ErrorLog
rollback transaction
*/  
CREATE PROCEDURE Proc_Cn2Cs_RetailerMigration
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_RetailerMigration 0
* PURPOSE		: Retailer to be Migrated from One DB to Other DB
* CREATED		: Sathishkumar Veeramani
* CREATED DATE	: 06/06/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
17-01-2018  lakshman M   BZ     ICRSTPAR7316          Retailer Tin No & Retailer Phone Number null values validation removed in Core stocky.
03-02-2018  lakshman M   BZ     ICRSTPAR7619          RtrPhone Number & RtrTinNumber Null values allowed in RetailerMasterMigartion Table
28-12-2018  Lakshman M   SR     ILCRSTPAR2934         As per client request Retailer default taxgroup validation included in core stocky.
***************************************************************************************************/
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo=0
DECLARE @CmpId AS NUMERIC(18,0)
DECLARE @SmId AS NUMERIC(18,0)
DECLARE @RmId AS NUMERIC(18,0)
DECLARE @DlvRmId AS NUMERIC(18,0)
DECLARE @UdcMasterId AS NUMERIC(18,0)
DECLARE @DistCode AS NVARCHAR(200)
DECLARE @Taxgroupid AS INT

DELETE FROM Cn2Cs_Prk_RetailerMigration WHERE DownLoadFlag = 'Y'
SELECT @DistCode = DistributorCode FROM Distributor WITH(NOLOCK)
SELECT @CmpId = CmpId FROM Company (NOLOCK) WHERE DefaultCompany = 1
	
	CREATE TABLE #ToAvoidRetailerMigration
	(
	  SalesmanCode   NVARCHAR(200),
	  SalRouteCode   NVARCHAR(200),
	  DlvRouteCode   NVARCHAR(200), 
	  RetailerCode   NVARCHAR(200),
	  GeoLevel       NVARCHAR(200),
	  GeoCode        NVARCHAR(200)
	)
	
	--Route Geography Level Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoLevel)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RouteGeoLevel NOT IN 
	(SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Route Geography Level Not Available-'+RouteGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RouteGeoLevel NOT IN (SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	--Route Geography Value Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoCode)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RouteGeoCode NOT IN 
	(SELECT GeoCode FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Route Geography Not Available-'+RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RouteGeoCode NOT IN (SELECT GeoCode FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoCode)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS 
	(SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId
	WHERE A.RouteGeoLevel = B.GeoLevelName AND A.RouteGeoCode = C.GeoCode)
	 
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Route Geography Wrongly Mapped-'+RouteGeoLevel+'-'+RouteGeoCode	
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS (SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) 
	INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId WHERE A.RouteGeoLevel = B.GeoLevelName AND A.RouteGeoCode = C.GeoCode)
	
	--Salesman Details Validation
	INSERT INTO #ToAvoidRetailerMigration(SalesmanCode)
	SELECT DISTINCT SalesManCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE SalesManName IN 
	(SELECT SmName FROM Salesman WITH(NOLOCK)) AND DownloadFlag = 'D'
	
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'Salesman','Salesman Name','Salesman Name Already Availabe-'+SalesManName 
	--FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE SalesManName IN (SELECT SmName FROM Salesman WITH(NOLOCK)) AND DownloadFlag = 'D'
	
	--Sales Route Details Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode)
	SELECT DISTINCT SalRouteCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE SalRouteName IN 
	(SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 1) AND DownloadFlag = 'D'
	
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'RouteMaster','Route Name','Sales Route Name Already Availabe-'+SalRouteName FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	--WHERE SalRouteName IN (SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 1) AND DownloadFlag = 'D'
	
	--Delivery Route Details Validation
	INSERT INTO #ToAvoidRetailerMigration(DlvRouteCode)
	SELECT DISTINCT DlvRouteCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DlvRouteName IN 
	(SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 2) AND DownloadFlag = 'D'
	
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'RouteMaster','Route Name','Delivery Route Name Already Availabe-'+DlvRouteName FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	--WHERE DlvRouteName IN (SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 2) AND DownloadFlag = 'D'
	
	--Retailer Details Validation
	--Retailer UNIQUE Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE EXISTS(
	SELECT * FROM RETAILER B WHERE A.RtrUniqueCode=B.RtrUniqueCode) AND DownloadFlag = 'D'
--	(RtrCode IS NULL OR RtrCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrUniqueCode','Duplicate Retailer Unique Code Not Allow-'+RtrUniqueCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE EXISTS(
	SELECT * FROM RETAILER B WHERE A.RtrUniqueCode=B.RtrUniqueCode) AND DownloadFlag = 'D'
	
	
	--Retailer UNIQUE Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrUniqueCode IS NULL OR RtrUniqueCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrUniqueCode','Retailer Unique Code Should Not be Empty-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrUniqueCode IS NULL OR RtrUniqueCode = '') AND DownloadFlag = 'D'
		
	----Duplicate Retailer Phone No & Tin No.
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrPhoneNo=B.RtrPhoneNo) AND DownloadFlag = 'D'
	And ISNULL(A.RTRPHONENO,'') <> ''
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Duplicate Phone Number Not allow-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrPhoneNo=B.RtrPhoneNo) AND DownloadFlag = 'D'
	AND ISNULL(A.RTRPHONENO,'') <> ''
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrTinNumber=B.RtrTINNo) AND DownloadFlag = 'D'
	AND ISNULL(A.RtrTinNumber,'') <> ''
	----------------- Retailer Tin No validation commented by lakshman M on 17/01/2018 PMS ID: ICRSTPAR7316 --------------------
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'Retailer','RtrTinNumber','Duplicate Tin Number Not allow-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	--EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrTinNumber=B.RtrTINNo) AND DownloadFlag = 'D'
	--AND ISNULL(A.RtrTinNumber,'') <> ''
	
	--INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	--SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE LEN(RtrTinNumber) NOT BETWEEN 8 AND 12 AND DownloadFlag = 'D'
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'Retailer','RtrTinNumber','Tin Number length Should be between 8 to 12-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	--LEN(RtrTinNumber) NOT BETWEEN 8 AND 12 AND DownloadFlag = 'D'
	
	--INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	--SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE LEN(RtrPhoneNo) NOT BETWEEN 8 AND 10 AND DownloadFlag = 'D'
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Phone Number length Should be between 8 to 10-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	--LEN(RtrPhoneNo) NOT BETWEEN 8 AND 10 AND DownloadFlag = 'D'
---------------------- Till Here ---------------------
	--Retailer Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrCode IS NULL OR RtrCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Code Should Not be Empty-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrCode IS NULL OR RtrCode = '') AND DownloadFlag = 'D'
	
	--Company Retailer Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (CmpRtrCode IS NULL OR CmpRtrCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Company Retailer Code Should Not be Empty-'+CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (CmpRtrCode IS NULL OR CmpRtrCode = '') AND DownloadFlag = 'D'
	
	--Retailer Name
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrName IS NULL OR RtrName = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Name Should Not be Empty-'+RtrName FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrName IS NULL OR RtrName = '') AND DownloadFlag = 'D'
	
	--Retailer Address
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrAddress1 IS NULL OR RtrAddress1 = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Address1 Should Not be Empty-'+RtrAddress1 FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrAddress1 IS NULL OR RtrAddress1 = '') AND DownloadFlag = 'D'
	
	--Retailer Geography Level Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RetailerGeoLevel NOT IN 
	(SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Level Not Available-'+RetailerGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RetailerGeoLevel NOT IN (SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoLevel) AS RetailerGeoLevel 
	FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoLevel) > 1)Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Level Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoLevel) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D'
	GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoLevel) > 1)Qry
	
	--Retailer Geography Value Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RetailerGeoCode NOT IN 
	(SELECT GeoName FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Retailer Geography Not Available-'+RetailerGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RetailerGeoCode NOT IN (SELECT GeoName FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoCode) AS RetailerGeoCode 
	FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoCode) > 1)Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoCode) AS RetailerGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoCode) > 1)Qry
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS 
	(SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId
	WHERE A.RetailerGeoLevel = B.GeoLevelName AND A.RetailerGeoCode = C.GeoName)
	 
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Retailer Geography Wrongly Mapped-'+RetailerGeoLevel+'-'+RetailerGeoCode 
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS (SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) 
	INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId WHERE A.RetailerGeoLevel = B.GeoLevelName AND A.RetailerGeoCode = C.GeoName)
	
	--Retailer Multiple Delivery Route
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT DlvRouteCode) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D'
	GROUP BY CmpRtrCode	HAVING COUNT(DISTINCT DlvRouteCode) >1) Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Route','RMcode','Retailer Delivery Route Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT DlvRouteCode) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	GROUP BY CmpRtrCode	HAVING COUNT(DISTINCT DlvRouteCode) >1) Qry	
	
	--Retailer Category Value Class	Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
    SELECT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS (
    SELECT DISTINCT C.CtgCode,D.CtgCode,E.ValueClassCode FROM RetailerCategoryLevel B WITH(NOLOCK)
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgLevelId = C.CtgLevelId 
    INNER JOIN RetailerCategory D WITH(NOLOCK) ON C.CtgMainId = D.CtgLinkId 
    INNER JOIN RetailerValueClass E WITH(NOLOCK) ON D.CtgMainId = E.CtgMainId WHERE A.RtrChannelCode = C.CtgCode AND
    A.RtrGroupCode = D.CtgCode AND A.RtrClassCode = E.ValueClassCode)
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'RetailerValueClass','ValueClassCode','Retailer Category and Value Class Not Available-'+
	RtrChannelCode+'-'+RtrGroupCode+'-'+RtrClassCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS (
    SELECT DISTINCT C.CtgCode,D.CtgCode,E.ValueClassCode FROM RetailerCategoryLevel B WITH(NOLOCK)
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgLevelId = C.CtgLevelId 
    INNER JOIN RetailerCategory D WITH(NOLOCK) ON C.CtgMainId = D.CtgLinkId 
    INNER JOIN RetailerValueClass E WITH(NOLOCK) ON D.CtgMainId = E.CtgMainId WHERE A.RtrChannelCode = C.CtgCode AND
    A.RtrGroupCode = D.CtgCode AND A.RtrClassCode = E.ValueClassCode)
    -- Phone & Tin Number Dublicate Validation
	--IF EXISTS (SELECT '*' FROM Configuration WHERE ModuleId = 'GENCONFIG30' AND ModuleName = 'General Configuration' AND Status = 1)
	--BEGIN
	--	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)		
	--	SELECT DISTINCT CmpRtrCode from Cn2Cs_Prk_RetailerMigration (NOLOCK) WHERE isnull(RtrPhoneNo,'') = ''
		
	--	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--	SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Retailer Phone Number Should be Mandatory-'+ RtrCode 
	--	FROM Cn2Cs_Prk_RetailerMigration  (NOLOCK)	where isnull(RtrPhoneNo,'') = ''		
		
	--END
    	
	SELECT DISTINCT RtrPhoneNo,COUNT(RtrPhoneNo) AS Counts INTO #RtrPhoneNo FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	group BY RtrPhoneNo HAVING COUNT(RtrPhoneNo) >1	
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)		
	SELECT DISTINCT CmpRtrCode from Cn2Cs_Prk_RetailerMigration A (NOLOCK) 
	INNER JOIN #RtrPhoneNo B (NOLOCK) ON A.RtrPhoneNo = B.RtrPhoneNo
	where isnull(A.RtrPhoneNo,'') <> ''
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Retailer Phone Number Should be Unique-'+ A.RtrCode 
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) INNER JOIN #RtrPhoneNo B (NOLOCK) ON A.RtrPhoneNo = B.RtrPhoneNo	
	where isnull(A.RtrPhoneNo,'') <> ''
	--Tin Number Validation
	SELECT DISTINCT RtrTinNumber,COUNT(RtrTinNumber) AS Counts INTO #RtrTinNumber FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	group BY RtrTinNumber HAVING COUNT(RtrTinNumber) >1
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)		
	SELECT DISTINCT CmpRtrCode from Cn2Cs_Prk_RetailerMigration A (NOLOCK) 
	INNER JOIN #RtrTinNumber B (NOLOCK) ON A.RtrTinNumber = B.RtrTinNumber
	WHERE isnull(A.RtrTinNumber,'') <> '' 
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrTinNumber','Retailer Tin Number Should be Unique-'+ A.RtrCode 
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) INNER JOIN #RtrTinNumber B (NOLOCK) ON A.RtrTinNumber = B.RtrTinNumber
	WHERE isnull(A.RtrTinNumber,'') <> '' 
     	
	--To Insert the Salesman Details
	SELECT @SmId = ISNULL(MAX(SMId),0) FROM Salesman (NOLOCK)
	
	INSERT INTO SalesmanMasterMigration (SMDCode,SMNCode,SMName,Upload,DownloadedDate)
	SELECT DISTINCT SalesmanCode,'SM0'+CAST((DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS NVARCHAR(200))+'-'+@DistCode AS SMCode,
	SalesManName,0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121)
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS 
	(SELECT ISNULL(SalesmanCode,'') FROM #ToAvoidRetailerMigration B WHERE A.SalesmanCode = ISNULL(B.SalesmanCode,''))
	
	INSERT INTO Salesman (SMId,SMCode,SMName,SMPhoneNumber,SMEmailID,SMOtherDetails,SMDailyAllowance,SMMonthlySalary,SMMktCredit,SMCreditDays,CmpId,
    SalesForceMainId,Status,SMCreditAmountAlert,SMCreditDaysAlert,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS SmId,
	'SM0'+CAST((DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS NVARCHAR(200))+'-'+@DistCode AS SMCode,SalesManName,0 AS SMPhoneNumer,
	'' AS SMEmailID,'' AS SMOtherDetails,0.00 AS SMDailyAllowance,0.00 AS SMMonthlySalary,0.00 AS SMMktCredit,0 AS SMCreditDays,0 AS CmpId,
	0 AS SalesForceMainId,1 AS [Status],0 AS SMCreditAmountAlert,0 AS SMCreditDaysAlert,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
	CONVERT(NVARCHAR(10),GETDATE(),121),0 FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS 
	(SELECT ISNULL(SalesmanCode,'') FROM #ToAvoidRetailerMigration B WHERE A.SalesmanCode = ISNULL(B.SalesmanCode,''))
	
	SELECT @SmId = ISNULL(MAX(SMId),0) FROM Salesman (NOLOCK)	
	UPDATE Counters SET CurrValue = @SmId WHERE TabName = 'Salesman' AND FldName = 'SMId'
	
	--To Insert the Sales Route Details 
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	SELECT @DlvRmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	
	INSERT INTO RouteMasterMigration (RMSalDCode,RMSalNCode,RMSalName,RMDlvDCode,RMDlvNCode,RMDlvName,Upload,DownloadedDate)
	SELECT DISTINCT SalRouteCode,'SR0'+CAST((DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,SalRouteName,
	DlvRouteCode,'DR0'+CAST((DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@DlvRmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,
	DlvRouteName,0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121)
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(SalRouteCode,'') FROM #ToAvoidRetailerMigration C 
	WHERE A.SalRouteCode = ISNULL(C.SalRouteCode,'') AND A.DlvRouteCode = ISNULL(C.DlvRouteCode,'')) 
	
	INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GeoMainId,RMVanRoute,RMSRouteType,RMLocalUpcountry,RMMon,RMTue,
    RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS RmId,
	'SR0'+CAST((DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,SalRouteName,@CmpId,0.00 AS RMDistance,
	0.00 AS RMPopulation,GeoMainId,1 AS RMVanRoute,1 AS RMSRouteType,1 AS RMLocalUpcountry,0 AS RMMon,0 AS RMTue,0 AS RMWed,0 AS RMThu,0 AS RMFri,
	0 AS RMSat,0 AS RMSun,1 AS RMstatus,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0   
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(SalRouteCode,'') FROM #ToAvoidRetailerMigration C WHERE A.SalRouteCode = ISNULL(C.SalRouteCode,''))
	
	--To Insert the Delivery Route Details
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	
	INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GeoMainId,RMVanRoute,RMSRouteType,RMLocalUpcountry,RMMon,RMTue,
    RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@RmId) AS RmId,
	'DR0'+CAST((DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@DlvRmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,DlvRouteName,@CmpId,0.00 AS RMDistance,
	0.00 AS RMPopulation,GeoMainId,1 AS RMVanRoute,2 AS RMSRouteType,1 AS RMLocalUpcountry,0 AS RMMon,0 AS RMTue,0 AS RMWed,0 AS RMThu,0 AS RMFri,
	0 AS RMSat,0 AS RMSun,1 AS RMstatus,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0   
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(DlvRouteCode,'') FROM #ToAvoidRetailerMigration C WHERE A.DlvRouteCode = ISNULL(C.DlvRouteCode,''))
	
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	UPDATE Counters SET CurrValue = @RmId WHERE TabName = 'RouteMaster' AND FldName = 'RMId'
	
	--Salesman Market Value Added
	INSERT INTO SalesmanMarket (SMId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT DISTINCT SMId,RmId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) 
	INNER JOIN RouteMaster B WITH(NOLOCK) ON A.SalRouteName = B.RMName 
	INNER JOIN Salesman C WITH(NOLOCK) ON A.SalesmanName = C.SMName WHERE B.RMSRouteType = 1 AND NOT EXISTS
	(SELECT SMId,RMId FROM SalesmanMarket D WITH(NOLOCK) WHERE C.SMId = D.SMId AND B.RMId = D.RMId)	
	
	
	--To Insert the Retailer Details
    SELECT DISTINCT SalesManName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPincode,B.CtgMainId AS CtgLevelId,
    B.CtgCode AS CtgLevelCode,B.CtgName AS CtgLevelName,C.CtgMainId,C.CtgCode,C.CtgName,D.RtrClassId,D.ValueClassCode,D.ValueClassName,
    SalRouteName,DlvRouteName,[Status],RetailerGeoLevel,RetailerGeoCode,RtrPhoneNo,RtrTinNumber,RtrTaxGroupCode,ISNULL(E.RtrUniqueCode,'')  AS RtrUniqueCode
    INTO #RetailerMigrationDetails FROM RetailerCategoryLevel A WITH(NOLOCK) 
    INNER JOIN RetailerCategory B WITH(NOLOCK) ON A.CtgLevelId = B.CtgLevelId
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgMainId = C.CtgLinkId  
    INNER JOIN RetailerValueClass D WITH(NOLOCK) ON C.CtgMainId = D.CtgMainId 
    INNER JOIN Cn2Cs_Prk_RetailerMigration E WITH(NOLOCK) ON B.CtgCode = E.RtrChannelCode AND C.CtgCode = E.RtrGroupCode AND DownLoadFlag = 'D'
    AND D.ValueClassCode = E.RtrClassCode WHERE CmpRtrCode NOT IN (SELECT ISNULL(RetailerCode,'') FROM #ToAvoidRetailerMigration)
	INSERT INTO RetailerMasterMigration (SMName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPincode,RtrCtgLevelId,RtrChannelCode,
	RtrCtgMainId,RtrGroupCode,RtrValClassId,RtrClassCode,RtrGeoLevelId,RtrGeoLvelName,RtrGeoId,RtrGeoName,RtrSalRMId,RtrSalRoute,RtrDlvRMId,RtrDlvRoute,
	RtrStatus,Upload,DownloadedDate,RtrPhoneNo,RtrTinNumber,RtrTaxGroupId,RtrUniqueCode)
	SELECT DISTINCT SalesManName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,ISNULL(RtrAddress2,0) AS RtrAddress2,ISNULL(RtrAddress3,0) as RtrAddress3,RtrPincode,CtgLevelId,CtgLevelName,
	CtgMainId,CtgName,RtrClassId,ValueClassName,B.GeoLevelId,RetailerGeoLevel,C.GeoMainId,GeoName,D.RmId,SalRouteName,E.RmId,DlvRouteName,
	[Status],0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121),ISNULL(RtrPhoneNo,0) AS RtrPhoneNo,ISNULL(RtrTinNumber,0) AS RtrTinNumber,---------- Null Values validation added in CS Pms id: ICRSTPAR7619
	ISNULL(TaxGroupId,0)AS RtrTaxGroupId,A.RtrUniqueCode
	FROM #RetailerMigrationDetails A (NOLOCK) 
	INNER JOIN GeographyLevel B WITH(NOLOCK) ON A.RetailerGeoLevel = B.GeoLevelName
	INNER JOIN Geography C WITH(NOLOCK) ON A.RetailerGeoCode = C.Geoname AND B.GeoLevelId = C.GeoLevelId
	INNER JOIN RouteMaster D WITH(NOLOCK) ON A.SalRouteName = D.RMName AND D.RMSRouteType = 1
	INNER JOIN RouteMaster E WITH(NOLOCK) ON A.DlvRouteName = E.RMName AND E.RMSRouteType = 2
	LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON A.RtrTaxGroupCode = TGS.RtrGroup AND TGS.TaxGroup = 1
	WHERE CmpRtrCode NOT IN (SELECT DISTINCT CmpRtrCode FROM RetailerMasterMigration (NOLOCK))
			
	UPDATE A SET A.Upload = 1 FROM SalesmanMasterMigration A WITH(NOLOCK) INNER JOIN Salesman B WITH (NOLOCK) ON A.SMName = B.SMName 
	
	UPDATE A SET A.Upload = 1 FROM RouteMasterMigration A WITH(NOLOCK) 
	INNER JOIN RouteMaster B WITH (NOLOCK) ON A.RMSalName = B.RMName AND B.RMSRouteType = 1
	INNER JOIN RouteMaster C WITH (NOLOCK) ON A.RMDlvName = C.RMName AND C.RMSRouteType = 2

	UPDATE A SET DownloadFlag = 'Y' FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) 
	INNER JOIN RetailerMasterMigration B WITH(NOLOCK) ON A.CmpRtrCode = B.CmpRtrCode

	--------------- Added  by Lakshman M Dated ON 28-12-2018 PMS ID:ILCRSTPAR2934 Default taxgroup validation added.
	SELECT  @Taxgroupid = Taxgroupid from TaxGroupSetting where RtrGroup ='RTRINTRA'
	UPDATE A set Rtrtaxgroupid =@Taxgroupid FROM RetailerMasterMigration A WHERE Rtrtaxgroupid = 0
	------------- Till here ------------
END
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.15' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.15',437
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 438)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(438,'D','2019-01-18',GETDATE(),1,'Core Stocky Service Pack 438')
GO