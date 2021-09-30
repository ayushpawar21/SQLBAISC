--[Stocky HotFix Version]=430
DELETE FROM Versioncontrol WHERE Hotfixid='430'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('430','3.1.0.7','D','2017-01-02','2017-01-02','2017-01-02',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*	
	--> Instition Target Setting Report Changes & Download
	--> Retailer Unique Code
	--> Retailer Tin No,Mobile No
	/* From Updater
	Proc_AutoBatchTransfer_Parle,Proc_Cn2Cs_ProductBatch,Proc_ApplySchemeInBill,Proc_Cn2Cs_SpecialDiscount,
	Proc_Cs2Cn_SyncDetails,Proc_CN2CS_ProductCodeUnification,View_CurrentStockReport,View_CurrentStockReportNTax,
	Proc_RptCurrentStock,Proc_RptSchemeUtilization_Parle,Proc_RptClosingStockReportParle,Proc_RptStockandSalesVolumeParle,
	Proc_RptUnloadingSheet,Proc_RptECAnalysisReportParle,Proc_RptCurrentStockParle,Proc_CodeUnificationOldProduct_StockPosing,
	Proc_Validate_Product,Proc_RptBillTemplateFinal,Proc_RptLoadSheetItemWiseParle
	*/Till Here
*/
IF NOT EXISTS(SELECT * FROM SYSCOLUMNS WHERE name='RtrUniqueCode' AND ID IN(SELECT ID FROM SYSOBJECTS WHERE NAME='Retailer' AND XTYPE='U'))
BEGIN
	ALTER TABLE Retailer ADD RtrUniqueCode Nvarchar(400)
END
GO
Update Retailer set RtrUniqueCode='' where RtrUniqueCode is Null
GO
IF NOT EXISTS(SELECT * FROM SYSCOLUMNS WHERE name='RtrUniqueCode' AND ID IN(SELECT ID FROM SYSOBJECTS WHERE NAME='RetailerMasterMigration' AND XTYPE='U'))
BEGIN
	ALTER TABLE RetailerMasterMigration ADD RtrUniqueCode Nvarchar(400)
END
GO
Update RetailerMasterMigration set RtrUniqueCode='' where RtrUniqueCode is Null
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='ParleTargetMonthMaster' and XTYPE='U')
DROP TABLE ParleTargetMonthMaster
GO
CREATE TABLE ParleTargetMonthMaster
(
Monthid int,
MonthName Nvarchar(50),
AcmType Int,
Availability Int,
LastModBy int,
LastModDate Datetime,
Authid int,
AuthDate Datetime
)
GO
INSERT INTO ParleTargetMonthMaster
SELECT 1,'January',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 2,'February',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 3,'March',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 4,'April',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 5,'May',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 6,'June',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 7,'July',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 8,'August',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 9,'September',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 10,'October',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 11,'November',1,1,1,GETDATE(),1,GETDATE()
UNION ALL
SELECT 12,'December',1,1,1,GETDATE(),1,GETDATE()
GO
DELETE FROM RptSelectionHd WHERE SelcId=317
GO
INSERT INTO RptSelectionHd(SelcId,SelcName,TblName,Condition)
SELECT 317,'Sel_TargetMonth','ParleTargetMonthMaster',0
GO
DELETE FROM RptGroup WHERE Rptid=289
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',289,'InstitutionsTargetReport','Target Setting Report',1
GO
DELETE FROM RptHeader WHERE Rptid=289
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds) 
SELECT 'InstitutionsTargetReport','Target Setting Report',289,'Target Setting Report','Proc_RptInstitutionsTargetReport','RptInstitutionsTargetReport','RptInstitutionsTargetReport.rpt',''	
GO
DELETE FROM RptDetails WHERE Rptid=289
GO
INSERT INTO RptDetails
SELECT 289,1,'ACMaster',-1,'','AcmId,AcmType,AcmYr','Financial Year*...','',1,'',149,1,1,'Press F4/Double Click to select Account Year',0
Union
SELECT 289,2,'ParleTargetMonthMaster',-1,'','Monthid,AcmType,MonthName','Financial Month*...','',1,'',317,1,1,'Press F4/Double Click to select Month',0
GO
DELETE FROM RptExcelHeaders where Rptid=289
GO
INSERT INTO RptExcelHeaders
SELECT 289,1,'CtgName','Retailer Group',1,1
UNION ALL
SELECT 289,2,'RtrCode','Retailer Code',1,1
UNION ALL
SELECT 289,3,'RtrName','Retailer Name',1,1
UNION ALL
SELECT 289,4,'AvgSal','Avg Sale',1,1
UNION ALL
SELECT 289,5,'Target','Target',1,1
UNION ALL
SELECT 289,6,'CSAchievement','As On date Achievement',1,1
UNION ALL
SELECT 289,7,'Achievement','Achievement',1,1
UNION ALL
SELECT 289,8,'BaseAch','Base Achievement (%)',1,1
UNION ALL
SELECT 289,9,'TargetAch','Target Achievement (%)',1,1
UNION ALL
SELECT 289,10,'ValBaseAch','Value On Base Achievement',1,1
UNION ALL
SELECT 289,11,'ValTargetAch','Value On Target Achievement',1,1
UNION ALL
SELECT 289,12,'ClmAmount','Claim Amount',1,1
UNION ALL
SELECT 289,13,'Liability','Liability (%)',1,1
UNION ALL
SELECT 289,14,'Flag','Flag',0,1
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='InsTargetDetailsTrans' and Xtype='U')
DROP TABLE InsTargetDetailsTrans
GO
CREATE TABLE InsTargetDetailsTrans
(
	[SlNo] [int] NULL,
	[CtgMainId] [int] NULL,
	[CtgName] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[AvgSal] [numeric](18, 6) NULL,
	[Target] [numeric](18, 6) NULL,
	[CSAchievement] [numeric](18, 6) NULL,
	[Achievement] [numeric](18, 6) NULL,
	[BaseAch] [numeric](18, 6) NULL,
	[TargetAch] [numeric](18, 6) NULL,
	[ValBaseAch] [numeric](18, 6) NULL,
	[ValTargetAch] [numeric](18, 6) NULL,
	[ClmAmount] [numeric](18, 6) NULL,
	[Liability] [numeric](18, 6) NULL,
	[UserId] [int] NULL,
	[Flag] [Int]
)
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Cs2Cn_Prk_Retailer' and XTYPE='U')
DROP TABLE Cs2Cn_Prk_Retailer
GO
CREATE TABLE Cs2Cn_Prk_Retailer
(
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
	[RtrFrequency] [nvarchar](100) NULL,
	[RtrPhoneNo] [nvarchar](50) NULL,
	[RtrTINNumber] [nvarchar](50) NULL,
	[RtrTaxGroupCode] [nvarchar](200) NULL,
	[RtrCrLimit] [numeric](18, 2) NULL,
	[RtrCrDays] [int] NULL,
	[Approved] [varchar](100) NULL,
	[RtrType] [varchar](100) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
)
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Cs2Cn_Prk_DailySales' and XTYPE='U')
DROP TABLE Cs2Cn_Prk_DailySales
GO
CREATE TABLE Cs2Cn_Prk_DailySales
(
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
	[ServerDate] [datetime] NULL,
	[BillStatus] [tinyint] NULL,
	[UploadedDate] [datetime] NULL,
	[OrderRefNo] [varchar](50) NULL,
	[SFAOrderRefNo] [varchar](50) NULL,
	[LCTRAmount] [numeric](38, 6) NULL,
	[RtrUniqueCode] [nvarchar](100) NULL
) 
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_DailySales] ADD  DEFAULT ((0)) FOR [SalInvLineCount]
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_DailySales] ADD  DEFAULT ((0)) FOR [SalInvLvlDiscPer]
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_DailySales] ADD  DEFAULT ((0)) FOR [LCTRAmount]
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Cs2Cn_Prk_SalesReturn' and XTYPE='U')
DROP TABLE Cs2Cn_Prk_SalesReturn
GO
CREATE TABLE Cs2Cn_Prk_SalesReturn
(
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
	[ServerDate] [datetime] NULL,
	[LCTRAmount] [numeric](38, 6) NULL,
	[RtrUniqueCode] [nvarchar](100) NULL
) 
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_SalesReturn] ADD  DEFAULT ((0)) FOR [SRNInvDiscount]
GO
ALTER TABLE [dbo].[Cs2Cn_Prk_SalesReturn] ADD  DEFAULT ((0)) FOR [LCTRAmount]
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Cn2Cs_Prk_RetailerApproval' and XTYPE='U')
DROP TABLE Cn2Cs_Prk_RetailerApproval
GO
CREATE TABLE Cn2Cs_Prk_RetailerApproval
(
	[DistCode] [nvarchar](200) NULL,
	[RtrCode] [nvarchar](100) NULL,
	[CmpRtrCode] [nvarchar](100) NULL,
	[RtrChannelCode] [nvarchar](100) NULL,
	[RtrGroupCode] [nvarchar](100) NULL,
	[RtrClassCode] [nvarchar](100) NULL,
	[Status] [nvarchar](100) NULL,
	[KeyAccount] [nvarchar](100) NULL,
	[Approved] [nvarchar](100) NULL,
	[Mode] [nvarchar](100) NULL,
	[RtrUniqueCode] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) 
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Cn2Cs_Prk_RetailerMigration' and XTYPE='U')
DROP TABLE Cn2Cs_Prk_RetailerMigration
GO
CREATE TABLE Cn2Cs_Prk_RetailerMigration
(
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
	[RetailerGeoLevel] [nvarchar](200) NULL,
	[RetailerGeoCode] [nvarchar](200) NULL,
	[SalesManCode] [nvarchar](200) NULL,
	[SalesManName] [nvarchar](200) NULL,
	[SalRouteCode] [nvarchar](200) NULL,
	[SalRouteName] [nvarchar](200) NULL,
	[DlvRouteCode] [nvarchar](200) NULL,
	[DlvRouteName] [nvarchar](200) NULL,
	[RouteGeoLevel] [nvarchar](200) NULL,
	[RouteGeoCode] [nvarchar](200) NULL,
	[RtrPhoneNo] [nvarchar](200) NULL,
	[RtrTinNumber] [nvarchar](200) NULL,
	[RtrTaxGroupCode] [nvarchar](200) NULL,
	[RtrUniqueCode] [nvarchar](200) NULL,
	[DownLoadFlag] [nvarchar](1) NULL,
	[CreatedDate] [datetime] NULL
)
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Cn2Cs_Prk_InstitutionsTargetSetting' and XTYPE='U')
DROP TABLE Cn2Cs_Prk_InstitutionsTargetSetting
GO
CREATE TABLE Cn2Cs_Prk_InstitutionsTargetSetting
(
	[DistCode] [varchar](50) NULL,
	[ProgramCode] [varchar](50) NULL,
	[FromProgramYear] [int] NULL,
	[ToProgramYear] [int] NULL,
	[RtrGroup] [Varchar](100),
	[CmpRtrCode] [varchar](50) NULL,
	[RtrUniqueCode] [Varchar](50),
	[AVGSales] [numeric](18, 6) NULL,
	[TargetAmount] [numeric](18, 6) NULL,
	[EffFromMonthId] [Int] Null,
	[EffToMonthId] [Int] Null,
	[CreatedDate] [datetime] NULL,
	[DownloadFlag] [varchar](2) NULL
) 
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Cn2Cs_Prk_InstitutionsTargetAchievement' and XTYPE='U')
DROP TABLE Cn2Cs_Prk_InstitutionsTargetAchievement
GO
CREATE TABLE Cn2Cs_Prk_InstitutionsTargetAchievement
(
	[DistCode] [varchar](50) NULL,
	[ProgramCode] [varchar](50) NULL,
	[ProgramYear] [int] NULL,
	[ProgramMonth] [varchar](50) NULL,
	[MonthId] [Int] null,
	[CmpRtrCode] [varchar](50) NULL,
	[RtrUniqueCode] [varchar](50) NULL,
	[Achievement] [numeric](18, 6) NULL,
	[BaseAchievement%] [numeric](18, 6) NULL,
	[TargetAchievement%] [numeric](18, 6) NULL,
	[BaseAchievementValue] [numeric](18, 6) NULL,
	[TargetAchievementValue] [numeric](18, 6) NULL,
	[ClaimAmount] [numeric](18, 6) NULL,
	[Liability] [numeric](18, 6) NULL,
	[CreatedDate] [datetime] NULL,
	[DownloadFlag] [varchar](2) NULL	
)
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Cn2Cs_Prk_RetailerCreditNote' and XTYPE='U')
DROP TABLE Cn2Cs_Prk_RetailerCreditNote
GO
CREATE TABLE Cn2Cs_Prk_RetailerCreditNote
(
	[DistCode] [varchar](50),
	[CreditRefNumber] [varchar](50),
	[CmpRtrCode] [Varchar](50),
	[CreditAmount] [Numeric](18,6),
	[Status] [Varchar](25),
	[Reason] [Varchar](100),
	[CreatedDate] [datetime] NULL,
	[DownloadFlag] [varchar](2) NULL
)
GO
IF NOT EXISTS (SELECT * FROM Tbl_DownloadIntegration where ProcessName='InstitutionsTargetAchievement')
BEGIN
INSERT INTO Tbl_DownloadIntegration(SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
SELECT 57,'InstitutionsTargetAchievement','Cn2Cs_Prk_InstitutionsTargetAchievement','Proc_Import_InstitutionsTargetAchievement',0,500,Getdate()
END
GO
IF NOT EXISTS (SELECT * FROM Tbl_DownloadIntegration where ProcessName='RetailerCreditNote')
BEGIN
INSERT INTO Tbl_DownloadIntegration(SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
SELECT 58,'RetailerCreditNote','Cn2Cs_Prk_RetailerCreditNote','Proc_Import_RetailerCreditNote',0,500,Getdate()
END
GO
IF NOT EXISTS (SELECT * FROM CustomupDownload WHERE UpDownload='Download' and Module='InstitutionsTargetAchievement')
BEGIN
INSERT INTO CustomupDownload (SlNo,SeqNo,Module,Screen,ExportFnName,
ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
SELECT 249,1,'InstitutionsTargetAchievement','InstitutionsTargetAchievement','','Proc_Import_InstitutionsTargetAchievement',
'Cn2Cs_Prk_InstitutionsTargetAchievement','Proc_Cn2Cs_InstitutionsTargetAchievement','Transaction','Download',0
END
GO
IF NOT EXISTS (SELECT * FROM CustomupDownload WHERE UpDownload='Download' and Module='RetailerCreditNote')
BEGIN
INSERT INTO CustomupDownload (SlNo,SeqNo,Module,Screen,ExportFnName,
ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
SELECT 250,1,'RetailerCreditNote','RetailerCreditNote','','Proc_Import_RetailerCreditNote',
'Cn2Cs_Prk_RetailerCreditNote','Proc_Cn2Cs_RetailerCreditNote','Master','Download',0
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_Retailer' and XTYPE='P')
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
* PROCEDURE	: Proc_Cs2Cn_Retailer 0,'2016-11-11'
* PURPOSE	: Extract Retailer Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 09-01-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* Added AutoRetailerApproval for Parle ICRSTPAR1505
* Added RtrFrequency,RtrPhoneNo,TinNumber,Crlimit,CrDays,Approved,RtrType by Gopi on 08/11/2016
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	--CHANGED BY MAHESH FOR ICRSTPAR1505
	IF EXISTS (SELECT * FROM RETAILER WHERE APPROVED=0)
	BEGIN
		UPDATE RETAILER SET Approved=1 WHERE Approved=0
	END
	--Till Here
	DELETE FROM Cs2Cn_Prk_Retailer WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Retailer
	(
		DistCode ,
		RtrId ,
		RtrCode ,
		CmpRtrCode,
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
        RtrFrequency,
        RtrPhoneNo,
        RtrTINNumber,
        RtrTaxGroupCode,
        RtrCrLimit,
        RtrCrDays,
        Approved,
        RtrType,
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
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New',R.RtrDrugLicNo,
		CASE RtrFrequency WHEN 0 THEN 'WEEKLY' WHEN 1 THEN 'BI-WEEKLY' WHEN 2 THEN 'FORT NIGHTLY' when 3 then 'MONTHLY' when 4 then 'DAILY' END AS RtrFrequency,
		ISNULL(RtrPhoneNo,''),ISNULL(RtrTINNo,''),ISNULL(TGS.RtrGroup,''),R.RtrCrLimit,
        R.RtrCrDays,(CASE ISNULL(R.Approved,0) WHEN 0 THEN 'PENDING' WHEN 1 THEN 'APPROVED' ELSE 'REJECTED' END) AS Approved,
        (CASE R.RtrType WHEN 1 THEN 'Retailer' WHEN 2 THEN 'Sub Stockist' WHEN 3 THEN 'Hub' WHEN 4 THEN 'Spoke' ELSE 'Distributor' END) AS RtrType,
        'N'					
	FROM		
		Retailer R
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
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
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','CR',R.RtrDrugLicNo,
		CASE RtrFrequency WHEN 0 THEN 'WEEKLY' WHEN 1 THEN 'BI-WEEKLY' WHEN 2 THEN 'FORT NIGHTLY' when 3 then 'MONTHLY' when 4 then 'DAILY' END AS RtrFrequency,
		ISNULL(RtrPhoneNo,''),ISNULL(RtrTINNo,''),ISNULL(TGS.RtrGroup,''),R.RtrCrLimit,
        R.RtrCrDays,(CASE ISNULL(R.Approved,0) WHEN 0 THEN 'PENDING' WHEN 1 THEN 'APPROVED' ELSE 'REJECTED' END) AS Approved,
        (CASE R.RtrType WHEN 1 THEN 'Retailer' WHEN 2 THEN 'Sub Stockist' WHEN 3 THEN 'Hub' WHEN 4 THEN 'Spoke' ELSE 'Distributor' END) AS RtrType,
        'N'							
	FROM
		RetailerClassficationChange RCC			
		INNER JOIN Retailer R ON R.RtrId=RCC.RtrId
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_DailySales' and Xtype='P')
DROP PROCEDURE Proc_Cs2Cn_DailySales
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_DailySales 0,'2014-09-26'
--UPDATE SALESINVOICE SET UPLOAD=0 WHERE SALID=25
SELECT * FROM Cs2Cn_Prk_DailySales (NOLOCK)
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
21/10/2014 Jisha Mathew Included Undelivered bills New Column Added BillStatus,UploadedDate	
12/12/2015 PRAVEENRAJ BHASKARAN LCTRAmount ADDED FOR CCRSTPAR0118
09/11/2016 Gopikrishnan RtrUniqueCode Added
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 			AS INT
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @DefCmpAlone	AS INT
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'Y'
	IF EXISTS (SELECT * FROM Cs2Cn_Prk_DailySales WHERE UploadFlag='N' AND Billstatus<=2)
	BEGIN
		DELETE FROM Cs2Cn_Prk_DailySales WHERE UploadFlag='N' AND Billstatus<=2
	END
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
		SalInvLvlDiscPer,
		BillStatus,
		UploadedDate,
		OrderRefNo,
		SFAOrderRefNo,
		RtrUniqueCode
	)
	SELECT 	@DistCode,A.SalInvNo,A.SalInvDate,A.SalDlvDate,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,
	A.OtherCharges,A.SalInvLvlDisc AS InvLevelDiscAmt,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,A.LcnId,L.LcnCode,
	B.SMCode,B.SMName,C.RMCode,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,
	ISNULL(E.VehicleRegNo,'') AS VehicleName,ISNULL(D.DlvBoyName,''),F.RMCode,F.RMName,H.PrdCCode,I.CmpBatCode,
	G.BaseQty AS SalInvQty ,G.PrdUom1EditedSelRate,G.PrdUom1EditedNetRate,G.SalManFreeQty AS SalInvFree ,
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount,
	'N' AS UploadFlag,0,A.SalInvLvlDiscPer,Dlvsts AS BillStatus,
	GETDATE(),ISNULL(O.OrderNo,''),ISNULL(O.DocRefNo,''),isnull(R.RtrUniqueCode,'')	
	FROM SalesInvoice A  (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID
	LEFT OUTER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId AND H.PrdId=I.PrdId
	INNER JOIN Location L (NOLOCK)	ON L.LcnId=A.LcnId
	LEFT OUTER JOIN OrderBooking O(NOLOCK) ON O.OrderNo=A.OrderKeyNo
	WHERE A.Upload=0 ORDER BY A.SalId
	
	--UPDATE A SET A.LCTRAmount=ISNULL(Z.LCTRAmt,0)
	--FROM Cs2Cn_Prk_DailySales A (NOLOCK)
	--INNER JOIN (
	--SELECT SalId,SalInvNo,PrdCCode,CmpBatCode,ISNULL(GrossAmt,0) AS GrossAmt,ISNULL(TaxAmount,0) AS TaxAmount,ISNULL(GrossAmt+TaxAmount,0) AS LCTRAmt 
	--FROM(
	--SELECT S.SALID,S.SALINVNO,P.PRDID,P.PRDCCODE,PB.CmpBatCode,SP.BASEQTY,SP.PrdUom1EditedSelRate,ISNULL((SP.BASEQTY*SP.PrdUom1EditedSelRate),0) AS GrossAmt,
	--ISNULL(Tax.TaxAmount,0) AS TaxAmount
	--FROM SalesInvoice S (NOLOCK)
	--INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.SALID
	--INNER JOIN (
	--SELECT SalId,PrdSlno,SUM(TaxAmount) TaxAmount FROM SalesInvoiceProductTax (NOLOCK)
	--GROUP BY SalId,PrdSlno
	--)Tax ON Tax.SalId=S.SalId AND SP.SalId=Tax.SalId AND SP.SlNo=Tax.PrdSlNo
	--INNER JOIN Product P (NOLOCK) ON P.PrdId=SP.PrdId
	--INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND PB.PrdBatId=SP.PrdBatId
	--) X
	--WHERE EXISTS (SELECT SalInvNo,PrdCode,PrdBatCde FROM Cs2Cn_Prk_DailySales Y WHERE 
	--X.SalInvNo=Y.SalInvNo AND X.PrdCCode=Y.PrdCode AND X.CmpBatCode=Y.PrdBatCde)
	--) Z ON Z.SalInvNo=A.SalInvNo AND Z.PrdCCode=A.PrdCode AND Z.CmpBatCode=A.PrdBatCde
	
	UPDATE A SET A.LCTRAmount=ISNULL(Z.LCTRAmt,0)
	FROM Cs2Cn_Prk_DailySales A (NOLOCK)
	INNER JOIN (
		SELECT A.SalId,A.SalInvNo,B.PrdId,P.PrdCCode,PB.CmpBatCode,C.TaxPerc,
		SUM(C.TaxableAmount) AS TaxableAmount,
		(SUM(B.BASEQTY)*B.PrdUom1EditedSelRate)+(SUM(B.BaseQty)*B.PrdUom1EditedSelRate)*(C.TaxPerc/100) AS LCTRAmt
		FROM SalesInvoice A (NOLOCK)
		INNER JOIN SalesInvoiceProduct B (NOLOCK) ON A.SALID=B.SALID
		INNER JOIN SalesInvoiceProductTax C (NOLOCK) ON A.SalId=C.SalId AND B.SalId=C.SalId AND B.SlNo=C.PrdSlNo
		INNER JOIN PRODUCT P (NOLOCK) ON B.PrdId=P.PrdId
		INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdId=B.PrdId AND PB.PrdBatId=B.PrdBatId
		INNER JOIN Cs2Cn_Prk_DailySales PRK (NOLOCK)
		ON PRK.SalInvNo=A.SalInvNo AND PRK.PrdCode=P.PrdCCode AND PRK.PrdBatCde=PB.CmpBatCode
		GROUP BY A.SalId,A.SalInvNo,B.PrdId,B.PrdUom1EditedSelRate,C.TaxPerc,P.PrdCCode,PB.CmpBatCode
		HAVING (SUM(C.TaxableAmount))>0
	) Z ON Z.SalInvNo=A.SalInvNo AND Z.PrdCCode=A.PrdCode AND Z.CmpBatCode=A.PrdBatCde
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where ProcId = 1
	UPDATE A SET SalInvLineCount=B.SalInvLineCount
	FROM Cs2Cn_Prk_DailySales A,(SELECT SI.SalInvNo,COUNT(SIP.PrdId) AS SalInvLineCount 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP WHERE 
	SI.UPload=0 AND SI.SalId=SIP.SalId
	GROUP BY SI.SalInvNo) B
	WHERE A.SalInvNo=B.SalInvNo
	--->Added By Nanda on 17/08/2010
	INSERT INTO Cs2Cn_Prk_SalesInvoiceOrders(DistCode,SalInvNo,OrderNo,OrderDate,UploadFlag)
	SELECT DISTINCT @DistCode,SI.SalInvNo,OB.OrderNo,OB.OrderDate,'N'
	FROM SalesInvoice SI,SalesinvoiceOrderBooking SIOB,OrderBooking OB
	WHERE SI.SalId=SIOB.SalId AND SIOB.OrderNo=OB.OrderNo AND SI.Upload=0 AND SI.DlvSts>3
	--->Till Here
	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'N') AND Dlvsts IN (3,4,5)
	UPDATE Cs2Cn_Prk_DailySales SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_SalesReturn' and XTYPE='P')
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
 
 UPDATE PRK SET PRK.LCTRAmount=ISNULL(LCTRAmt,0)
 FROM Cs2Cn_Prk_SalesReturn PRK (NOLOCK)
 INNER JOIN 
 (
	SELECT R.ReturnId,R.ReturnCode,P.PrdCCode,PB.CmpBatCode,
	(SUM(RP.BaseQty)*RP.PrdEditSelRte)+(SUM(RP.BaseQty)*RP.PrdEditSelRte)*(RPT.TaxPerc/100) AS LCTRAmt,
	SUM(RPT.TaxableAmt) AS TaxableAmt,RPT.TaxPerc  
	FROM ReturnHeader R (NOLOCK)
	INNER JOIN ReturnProduct RP (NOLOCK) ON R.RETURNID=RP.RETURNID
	INNER JOIN ReturnProductTax RPT (NOLOCK) ON R.RETURNID=RPT.RETURNID AND RP.RETURNID=RPT.RETURNID AND RP.SlNO=RPT.PrdSlNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=RP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId AND PB.PrdId=RP.PrdId AND RP.PrdBatId=PB.PrdBatId
	INNER JOIN Cs2Cn_Prk_SalesReturn Prk (NOLOCK) ON Prk.PrdCode=P.PrdCCode AND Prk.PrdBatCde=PB.CmpBatCode
	GROUP BY R.ReturnId,R.ReturnCode,P.PrdCCode,PB.CmpBatCode,RPT.TaxPerc,RP.PrdEditSelRte
	HAVING (SUM(RPT.TaxableAmt))>0
 ) Z ON Z.ReturnCode=PRK.SRNRefNo AND Z.PrdCCode=PRK.PrdCode AND Z.CmpBatCode=PRK.PrdBatCde
  
 UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),  
 ProcDate = CONVERT(nVarChar(10),GetDate(),121)  
 Where ProcId = 4  
 UPDATE ReturnHeader SET Upload=1 WHERE Upload=0 AND ReturnCode IN (SELECT DISTINCT  
 SRNRefNo FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'N') AND Status=0   
 UPDATE Cs2Cn_Prk_SalesReturn SET ServerDate=@ServerDate
END
GO
DELETE FROM Tbl_DownloadIntegration WHERE PrkTableName='Cn2Cs_Prk_InstitutionsTargetStatus'
DELETE FROM CustomUpDownload WHERE Updownload='Download' and ParkTable='Cn2Cs_Prk_InstitutionsTargetStatus'
IF NOT EXISTS(SELECT * FROM SYSCOLUMNS WHERE name='RtrUniqueCode' AND ID IN(SELECT ID FROM SYSOBJECTS WHERE NAME='InsTargetDetails' AND XTYPE='U'))
BEGIN
	ALTER TABLE InsTargetDetails ADD RtrUniqueCode Nvarchar(400)
END
GO
Update B set RtrUniqueCode=A.RtrUniqueCode FROM Retailer A INNER JOIN InsTargetDetails B ON A.RtrId=B.RtrId
where B.RtrUniqueCode is Null
GO
IF NOT EXISTS(SELECT * FROM SYSCOLUMNS WHERE name='CmpRtrCode' AND ID IN(SELECT ID FROM SYSOBJECTS WHERE NAME='InsTargetDetails' AND XTYPE='U'))
BEGIN
	ALTER TABLE InsTargetDetails ADD CmpRtrCode Nvarchar(100)
END
GO
Update B set CmpRtrCode=A.CmpRtrCode FROM Retailer A INNER JOIN InsTargetDetails B ON A.RtrId=B.RtrId
where B.CmpRtrCode is Null
GO
IF NOT EXISTS(SELECT * FROM SYSCOLUMNS WHERE name='EffFromMonthId' AND ID IN(SELECT ID FROM SYSOBJECTS WHERE NAME='InsTargetHD' AND XTYPE='U'))
BEGIN
	ALTER TABLE InsTargetHD ADD EffFromMonthId INT
END
GO
IF NOT EXISTS(SELECT * FROM SYSCOLUMNS WHERE name='EffToMonthId' AND ID IN(SELECT ID FROM SYSOBJECTS WHERE NAME='InsTargetHD' AND XTYPE='U'))
BEGIN
	ALTER TABLE InsTargetHD ADD EffToMonthId INT
END
GO
IF NOT EXISTS(SELECT * FROM SYSCOLUMNS WHERE name='ToTargetYear' AND ID IN(SELECT ID FROM SYSOBJECTS WHERE NAME='InsTargetHD' AND XTYPE='U'))
BEGIN
	ALTER TABLE InsTargetHD ADD ToTargetYear INT
END
GO
IF NOT EXISTS (SELECT * FROM Sysobjects Where Name='InsTargetDetailsAch' and Xtype='U')
CREATE TABLE InsTargetDetailsAch
(
	[InsId] [bigint] NULL,
	[TargetYear] [Bigint],
	[TargetMonth] [Nvarchar](50),
	[RtrId] [int] NULL,
	[Achievement] [numeric](18, 6) NULL,
	[BaseAch] [numeric](18, 6) NULL,
	[TargetAch] [numeric](18, 6) NULL,
	[ValBaseAch] [numeric](18, 6) NULL,
	[ValTargetAch] [numeric](18, 6) NULL,
	[ClmAmount] [numeric](18, 6) NULL,
	[Liability] [numeric](18, 6) NULL,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL,
	[RtrUniqueCode] [nvarchar](400) NULL,
	[CmpRtrCode] [nvarchar](100) NULL
)
GO
IF NOT EXISTS(SELECT * FROM COAMaster (NOLOCK) WHERE AcName='Institutions Target Setting')
BEGIN
	INSERT INTO COAMaster (CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT (SELECT ISNULL(MAX(coaid),0)+1 FROM COAMaster(NOLOCK)),(SELECT MAX(accode)+1 from COAMaster (NOLOCK) WHERE AcLevel=4 and MainGroup=4),
	'Institutions Target Setting',4,4,0,1,1,GETDATE(),1,GETDATE()
	UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CoaMaster'
END
GO
IF NOT EXISTS (SELECT * FROM ReasonMaster WHERE DESCRIPTION='Institutions Target Setting')
BEGIN
	INSERT INTO ReasonMaster (ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,DeliveryProcess,
	SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,StkTransferScreen,BatchTransfer,ReceiptVoucher,
	ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,Availability,LastModBy,LastModDate,AuthId,AuthDate,NonBilled)
	SELECT CurrValue+1,'R0'+CAST(CurrValue+1 AS VARCHAR(5)),'Institutions Target Setting',
	0 AS PurchaseReceipt,0 AS SalesInvoice,0 AS VanLoad,0 AS CrNoteSupplier,1 AS CrNoteRetailer,
	0 AS DeliveryProcess,0 AS SalvageRegister,0 AS PurchaseReturn,0 AS SalesReturn,0 AS VanUnload,
	0 AS DbNoteSupplier,0 AS DbNoteRetailer,0 AS StkAdjustment,0 AS StkTransferScreen,0 AS BatchTransfer,
	0 AS ReceiptVoucher,0 AS ReturnToCompany,0 AS LocationTrans,0 AS Billing,0 AS ChequeBouncing,0 AS ChequeDisbursal,
	1 AS Availability,1 AS LastModBy,GETDATE() AS LastModDate,1 AS AuthId,GETDATE() AS AuthDate,1 as NonBilled
	FROM Counters WHERE TabName='ReasonMaster'
	UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster'
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Import_RetailerApproval' and XTYPE='P')
DROP PROCEDURE Proc_Import_RetailerApproval
GO
--EXEC Proc_Import_RetailerApproval '<Root><Console2CS_RetailerStatus DistCode="119188" RtrCode="JNJRtr001" CmpRtrCode="A011000001" RtrChannelCode="GT" RtrGroupCode="Beauty" RtrClassCode="2" Status="ACTIVE" KeyAccount="NO" CREATEdUserID="1" CREATEdDate="2010-04-04T14:27:11.393" DownLoadFlag="N"/><Console2CS_RetailerStatus DistCode="119188" RtrCode="JNJRtr002" CmpRtrCode="A011000002" RtrChannelCode="CSD" RtrGroupCode="IG" RtrClassCode="4" Status="ACTIVE" KeyAccount="NO" CREATEdUserID="1" CREATEdDate="2010-04-04T14:27:11.393" DownLoadFlag="N"/></Root>'
CREATE PROCEDURE Proc_Import_RetailerApproval
(
	@Pi_Records TEXT
)
AS
/***************************************************************************************************
* PROCEDURE		: Proc_Import_RetailerApproval
* PURPOSE		: To Insert and Update records  from xml file in the Table Retailer Status
* CREATED		: Nandakumar R.G
* CREATED DATE	: 05/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
*****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Cn2Cs_Prk_RetailerApproval(DistCode,RtrCode,CmpRtrCode,RtrChannelCode,RtrGroupCode,
	RtrClassCode,Status,KeyAccount,Approved,Mode,RtrUniqueCode,DownLoadFlag)
	SELECT  DistCode,RtrCode,CmpRtrCode,RtrChannelCode,RtrGroupCode,
	RtrClassCode,Status,Isnull(KeyAccount,''),Approved,Mode,RtrUniqueCode,ISNULL([DownLoadFlag],'D')
	FROM 	OPENXML (@hdoc,'/Root/Console2CS_RetailerStatus',1)
	WITH (
			[DistCode] 			NVARCHAR(200),
			[RtrCode] 			NVARCHAR(100),
			[CmpRtrCode] 		NVARCHAR(100),
			[RtrChannelCode]	NVARCHAR(100),
			[RtrGroupCode]		NVARCHAR(100),
			[RtrClassCode]		NVARCHAR(100),
			[Status]			NVARCHAR(100),
			[KeyAccount]		NVARCHAR(100),
			[Approved]			NVARCHAR(100),
			[Mode]				NVARCHAR(100),
			[RtrUniqueCode]     NVARCHAR (200),
			[DownLoadFlag]		NVARCHAR(10) 			
	     ) XMLObj
	--SELECT * FROM Cn2Cs_Prk_RetailerApproval
	--DELETE FROM Cn2Cs_Prk_RetailerApproval
	EXECUTE sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Import_RetailerMigration' and Xtype='P')
DROP PROCEDURE Proc_Import_RetailerMigration
GO
--EXEC Proc_Import_RetailerMigration '<Root></Root>'
CREATE PROCEDURE Proc_Import_RetailerMigration
(
	@Pi_Records nTEXT
)
AS
/*********************************
* PROCEDURE		: Proc_ImportConfiguration
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_RetailerMigration
* CREATED		: Nandakumar R.G
* CREATED DATE	: 24/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_RetailerMigration WHERE DownLoadFlag='Y'
	INSERT INTO Cn2Cs_Prk_RetailerMigration(DistCode,RtrId,RtrCode,CmpRtrCode,RtrName,
	RtrAddress1,RtrAddress2,RtrAddress3,RtrPINCode,RtrChannelCode,RtrGroupCode,RtrClassCode,
	KeyAccount,RelationStatus,ParentCode,RtrRegDate,Status,
	RetailerGeoLevel,RetailerGeoCode,SalesManCode,SalesManName,SalRouteCode,SalRouteName,DlvRouteCode,DlvRouteName,
	RouteGeoLevel,RouteGeoCode,RtrPhoneNo,RtrTinNumber,RtrTaxGroupCode,RtrUniqueCode,DownLoadFlag,
	CreatedDate)
	SELECT DistCode,RtrId,RtrCode,CmpRtrCode,RtrName,
	ISNULL(RtrAddress1,''),ISNULL(RtrAddress2,''),ISNULL(RtrAddress3,''),ISNULL(RtrPINCode,''),ISNULL(RtrChannelCode,''),ISNULL(RtrGroupCode,''),
	ISNULL(RtrClassCode,''),
	ISNULL(KeyAccount,''),ISNULL(RelationStatus,''),ISNULL(ParentCode,''),ISNULL(RtrRegDate,''),ISNULL(Status,0),
	ISNULL(RetailerGeoLevel,''),ISNULL(RetailerGeoCode,''),ISNULL(SalesManCode,''),ISNULL(SalesManName,''),
	ISNULL(SalRouteCode,''),ISNULL(SalRouteName,''),ISNULL(DlvRouteCode,''),ISNULL(DlvRouteName,''),ISNULL(RouteGeoLevel,''),ISNULL(RouteGeoCode,''),
	ISNULL(RtrPhoneNo,''),ISNULL(RtrTinNumber,''),ISNULL(RtrTaxGroupCode,''),ISNULL(RtrUniqueCode,''),
	ISNULL(DownLoadFlag,'D'),ISNULL(CreatedDate,GETDATE())
	FROM OPENXML (@hdoc,'/Root/Console2CS_RetailerMigration',1)
	WITH 
	(	
			[DistCode]			NVARCHAR(100), 
			[RtrId]				INT,
			[RtrCode]			NVARCHAR(100),
			[CmpRtrCode]		NVARCHAR(100),
			[RtrName]			NVARCHAR(100),
			[RtrAddress1]		NVARCHAR(100),			
			[RtrAddress2]		NVARCHAR(100),			
			[RtrAddress3]		NVARCHAR(100),			
			[RtrPINCode]		NVARCHAR(20),			
			[RtrChannelCode]	NVARCHAR(100),			
			[RtrGroupCode]		NVARCHAR(100),			
			[RtrClassCode]		NVARCHAR(100),		
			[KeyAccount]		NVARCHAR(20),
			[RelationStatus]	NVARCHAR(100),
			[ParentCode]		NVARCHAR(100),
			[RtrRegDate]		NVARCHAR(100),
			[Status]			TINYINT,
			RetailerGeoLevel	nvarchar(200) ,
			RetailerGeoCode		nvarchar(200) ,
			SalesManCode		nvarchar(200) ,
			SalesManName		nvarchar(200) ,
			SalRouteCode		nvarchar(200) ,
			SalRouteName		nvarchar(200) ,
			DlvRouteCode		nvarchar(200) ,
			DlvRouteName		nvarchar(200) ,
			RouteGeoLevel		nvarchar(200) ,
			RouteGeoCode		nvarchar(200) ,
			RtrPhoneNo			nvarchar(200) ,
			RtrTinNumber		nvarchar(200) ,
			RtrTaxGroupCode		nvarchar(200),
			RtrUniqueCode       nvarchar(200),
		    [DownLoadFlag]		NVARCHAR(10),
			CreatedDate			datetime 
	) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
	select * from Cn2Cs_Prk_RetailerMigration
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Import_InstitutionsTargetSetting' and XTYPE='P')
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
	
	INSERT INTO Cn2Cs_Prk_InstitutionsTargetSetting(DistCode,ProgramCode,FromProgramYear,ToProgramYear,RtrGroup,CmpRtrCode,
	RtrUniqueCode,AVGSales,TargetAmount,EffFromMonthId,EffToMonthId,CreatedDate,DownloadFlag)

	SELECT DistCode,ProgramCode,FromProgramYear,ToProgramYear,RtrGroup,CmpRtrCode,RtrUniqueCode,AVGSales,
	TargetAmount,EffFromMonthId,EffToMonthId,CreatedDate,ISNULL(DownloadFlag,'D') FROM
	OPENXML (@hdoc,'/Root/Console2CS_InstitutionsTargetSetting',1)                              
		WITH 
		(  
			DistCode		VARCHAR(50),
			ProgramCode		VARCHAR(50),
			FromProgramYear	INT,
			ToProgramYear   INT,
			RtrGroup		VARCHAR(50),
			CmpRtrCode		VARCHAR(50),
			RtrUniqueCode   VARCHAR(50),
			AVGSales		NUMERIC(18,6),
			TargetAmount	NUMERIC(18,6),
			EffFromMonthId  INT,
			EffToMonthId    INT,
			CreatedDate		DATETIME,
			DownloadFlag	VARCHAR(2)
		) XMLObj
		
	EXECUTE sp_xml_removedocument @hDoc
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects where name='Proc_Import_InstitutionsTargetAchievement' and XTYPE='P')
DROP PROCEDURE Proc_Import_InstitutionsTargetAchievement
GO
CREATE PROCEDURE Proc_Import_InstitutionsTargetAchievement
(
	@Pi_Records NTEXT 
)
AS
/*********************************
* PROCEDURE	: Proc_Import_InstitutionsTargetAchievement
* PURPOSE	: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_InstitutionsTargetAchievement 
* CREATED	: Gopikrishnan
* CREATED DATE	: 10/11/2016
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Cn2Cs_Prk_InstitutionsTargetAchievement(DistCode,ProgramCode,ProgramYear,ProgramMonth,CmpRtrCode,RtrUniqueCode,Achievement,
	[BaseAchievement%],[TargetAchievement%],BaseAchievementValue,TargetAchievementValue,ClaimAmount,Liability,CreatedDate,DownloadFlag,MonthId)
	SELECT DistCode,ProgramCode,ProgramYear,ProgramMonth,CmpRtrCode,RtrUniqueCode,Achievement,
	[BaseAchievement%],[TargetAchievement%],BaseAchievementValue,TargetAchievementValue,ClaimAmount,Liability,
	CreatedDate,ISNULL(DownloadFlag,'D'),MonthId FROM
	OPENXML (@hdoc,'/Root/Console2CS_InstitutionsTargetAchievement',1)                              
		WITH 
		(  
			[DistCode] [varchar](50),
			[ProgramCode] [varchar](50),
			[ProgramYear] [int],
			[ProgramMonth] [varchar](50),
			[CmpRtrCode] [varchar](50),
			[RtrUniqueCode] [Varchar](50),
			[Achievement] [numeric](18, 6),
			[BaseAchievement%] [numeric](18, 6),
			[TargetAchievement%] [numeric](18, 6),
			[BaseAchievementValue] [numeric](18, 6),
			[TargetAchievementValue] [numeric](18, 6),
			[ClaimAmount] [numeric](18, 6),
			[Liability] [numeric](18, 6),
			[CreatedDate] [datetime],
			[DownloadFlag] [varchar](2),
			[MonthId] [Int]
		) XMLObj
		
	EXECUTE sp_xml_removedocument @hDoc
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Import_RetailerCreditNote' and XTYPE='P')
DROP PROCEDURE Proc_Import_RetailerCreditNote
GO
CREATE PROCEDURE Proc_Import_RetailerCreditNote
(
	@Pi_Records NTEXT 
)
AS
/*********************************
* PROCEDURE	: Proc_Import_RetailerCreditNote
* PURPOSE	: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_RetailerCreditNote 
* CREATED	: Gopikrishnan
* CREATED DATE	: 09/11/2016
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Cn2Cs_Prk_RetailerCreditNote(DistCode,CreditRefNumber,CmpRtrCode,CreditAmount,Status,
	Reason,CreatedDate,DownloadFlag)

	SELECT DistCode,CreditRefNumber,CmpRtrCode,CreditAmount,Status,
	Reason,CreatedDate,ISNULL(DownloadFlag,'D') FROM
	OPENXML (@hdoc,'/Root/CS2Console_RetailerCreditNote',1)                              
		WITH 
		(  
			DistCode		VARCHAR(50),
			CreditRefNumber	VARCHAR(50),
			CmpRtrCode		VARCHAR(50),
			CreditAmount	NUMERIC(18,6),
			Status			VARCHAR(25),
			Reason			VARCHAR(100),
			CreatedDate		DATETIME,
			DownloadFlag	VARCHAR(2)
		) XMLObj
		
	EXECUTE sp_xml_removedocument @hDoc
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cn2Cs_RetailerApproval' and XTYPE='P')
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
	DECLARE @Approved       NVARCHAR(200)
	DECLARE @StatusId  		INT
	DECLARE @RtrId  		INT
	DECLARE @RtrClassId  	INT
	DECLARE @CtgLevelId  	INT
	DECLARE @CtgMainId  	INT	
	DECLARE @KeyAccId		INT
	DECLARE @ApprovedId		INT
	DECLARE @Pi_UserId  	INT	
	DECLARE @CtgClassMainId INT
	DECLARE @RtrUniqueCode NVARCHAR(200)
	DECLARE @Mode NVARCHAR(200)
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_RetailerApproval'
	SET @Pi_UserId=1
	
	
	DECLARE Cur_RetailerApproval CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([RtrCode])),''),ISNULL(LTRIM(RTRIM([CmpRtrCode])),''),ISNULL(LTRIM(RTRIM([RtrChannelCode])),''),ISNULL(LTRIM(RTRIM([RtrGroupCode])),''),
	ISNULL(LTRIM(RTRIM([RtrClassCode])),''),ISNULL(LTRIM(RTRIM([Status])),'Active'),ISNULL(LTRIM(RTRIM([KeyAccount])),'Yes'),
	(CASE WHEN LEN(ISNULL(LTRIM(RTRIM(UPPER(Approved))),''))=0 THEN 'PENDING' ELSE UPPER(Approved) END) AS Approved,
	ISNULL(RtrUniqueCode,'') AS RtrUniqueCode,Mode
	FROM Cn2Cs_Prk_RetailerApproval WHERE [DownLoadFlag] ='D'
	OPEN Cur_RetailerApproval
	FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,
	@Status,@KeyAcc,@Approved,@RtrUniqueCode,@Mode
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Po_ErrNo=0
		IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrCode=@RtrCode)
		BEGIN
			SET @ErrDesc = 'Retailer Code:'+@RtrCode+'does not exists'
			INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
			SET @Po_ErrNo=1
			SET @RtrId=0
		END
		ELSE
		BEGIN
			SELECT @RtrId=RtrId FROM Retailer WHERE RtrCode=@RtrCode			
		END
		
		IF NOT EXISTS (SELECT CtgMainId FROM RetailerCateGOry WHERE CtgCode=@RtrGroupCode)
		BEGIN
			SET @ErrDesc = 'Retailer CateGOry Level Value:'+@RtrGroupCode+' does not exists'
			INSERT INTO Errorlog VALUES (3,@TabName,'Retailer CateGOry Level Value',@ErrDesc)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CtgClassMainId=CtgMainId FROM RetailerCateGOry
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
		
		IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('PENDING')
		BEGIN
			SET @ApprovedId=0	
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('APPROVED')
		BEGIN
			SET @ApprovedId=1
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('REJECTED')
		BEGIN
		    SET @ApprovedId=2
		END
			
		IF @Po_ErrNo=0
		BEGIN
		    IF @ApprovedId = 2
		    BEGIN
		        IF @Mode = 'NEW'
		        BEGIN
		           UPDATE Retailer SET RtrStatus = 0,Approved=@ApprovedId WHERE RtrId=@RtrId
		        END
		        UPDATE Retailer SET RtrUniqueCode = @RtrUniqueCode WHERE RtrId = @RtrId
	
		    END
		    ELSE
		    BEGIN
				UPDATE Retailer SET RtrStatus=@Status,Approved=@ApprovedId,RtrKeyAcc=@KeyAccId,
				RtrUniqueCode = @RtrUniqueCode WHERE RtrId=@RtrId
	
				
				SET @sSql='UPDATE Retailer SET RtrStatus='+CAST(@Status AS NVARCHAR(100))+',RtrKeyAcc='+CAST(@KeyAccId AS NVARCHAR(100))+' WHERE RtrId='+CAST(@RtrId AS NVARCHAR(100))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				DECLARE @OldCtgMainId	NUMERIC(38,0)
				DECLARE @OldCtgLevelId	NUMERIC(38,0)
				DECLARE @OldRtrClassId	NUMERIC(38,0)
				DECLARE @NewCtgMainId	NUMERIC(38,0)
				DECLARE @NewCtgLevelId	NUMERIC(38,0)
				DECLARE @NewRtrClassId	NUMERIC(38,0)
				SELECT @OldCtgMainId=A.CtgMainId,@OldCtgLevelId=B.CtgLevelId,@OldRtrClassId=C.RtrClassId 
				FROM RetailerCateGOry A INNER JOIN RetailerCateGOryLevel B ON A.CtgLevelId=B.CtgLevelId
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
				FROM RetailerCateGOry A INNER JOIN RetailerCateGOryLevel B ON A.CtgLevelId=B.CtgLevelId
				INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
				INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
				WHERE D.RtrId=@RtrId
				
				INSERT INTO Track_RtrCateGOryandClassChange
				SELECT -3000,@RtrId,@OldCtgLevelId,@OldCtgMainId,@OldRtrClassId,@NewCtgLevelId,@NewCtgMainId, 
				@NewRtrClassId,CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(23),GETDATE(),121),4
				
				SET @sSql='INSERT INTO RetailerValueClassMap
				(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RtrClassId AS VARCHAR(10))+',
				1,'+CAST(@Pi_UserId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',
				'+CAST(@Pi_UserId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
			
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END				
		END
		FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,
		@Status,@KeyAcc,@Approved,@RtrUniqueCode,@Mode
	END
	CLOSE Cur_RetailerApproval
	DEALLOCATE Cur_RetailerApproval
	UPDATE A SET A.DownLoadFlag='Y' FROM Cn2Cs_Prk_RetailerApproval A (NOLOCK) WHERE DownLoadFlag ='D'
	AND EXISTS (SELECT DISTINCT RtrId FROM Retailer B(NOLOCK) WHERE A.RtrCode = B.RtrCode) 
	RETURN
END
GO
IF EXISTS(SELECT * FROM Sysobjects Where Name='Proc_Validate_InstitutionsTargetSetting' and Xtype='P')
DROP PROCEDURE Proc_Validate_InstitutionsTargetSetting
GO
CREATE PROCEDURE Proc_Validate_InstitutionsTargetSetting
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_Validate_InstitutionsTargetSetting 0
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
			(SELECT * FROM #CSCtgCode C (NOLOCK) WHERE Prk.RtrGroup = C.CtgCode AND Prk.CmpRtrCode = C.CmpRtrCode)
			
			INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,3,'Cn2Cs_Prk_InstitutionsTargetSetting','ProgramCode','No values should be NULL for the Program ' +
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting 
			WHERE (FromProgramYear) IS NULL  Or (ToProgramYear) IS NULL
			OR (RtrGroup + CmpRtrCode) IS NULL
			OR (AVGSales + TargetAmount + EffFromMonthId) IS NULL
			INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,4,'Cn2Cs_Prk_InstitutionsTargetSetting','TargetAmount','TargetAmount field should not be Zero Or NULL' +
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting 
			WHERE ISNULL(TargetAmount,0) = 0
			
		    INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,5,'Cn2Cs_Prk_InstitutionsTargetSetting','EffFromMonthId','EffFromMonthId field should not be Zero Or NULL' +
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting 
			WHERE ISNULL(EffFromMonthId,0) = 0
			
			INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,6,'Cn2Cs_Prk_InstitutionsTargetSetting','EffToMonthId','EffToMonthId field should not be Zero Or NULL' +
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting 
			WHERE ISNULL(EffToMonthId,0) = 0
			
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT SlNo,TableName,FieldName,ErrDesc FROM #InsToAvoid (NOLOCK)
			
			DELETE P FROM #Cn2Cs_Prk_InstitutionsTargetSetting P
			WHERE EXISTS (SELECT 'C' FROM #InsToAvoid A (NOLOCK) WHERE P.ProgramCode = A.ProgramCode)
			
			DECLARE @CurrValue AS INT
			
			SELECT @CurrValue = CurrValue FROM Counters  (NOLOCK) 
			WHERE TabName='InsTargetHD' AND FldName='InsId'
			
			--Header
			INSERT INTO InsTargetHD (InsId,InsRefNo,TargetDate,TargetMonth,TargetYear,[Status],Confirm,Upload,Availability,
			LastModBy,LastModDate,AuthId,AuthDate,EffFromMonthId,EffToMonthId,ToTargetYear)
			
			SELECT ROW_NUMBER() OVER(ORDER BY ProgramCode) + @CurrValue InsId,
			ProgramCode InsRefNo,GETDATE() TargetDate,EffFromMonthId [TargetMonth],FromProgramYear [TargetYear],1 [Status],0 Confirm,0 Upload,
			1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,MAX(CreatedDate) AuthDate,EffFromMonthId,EffToMonthId,ToProgramYear [ToTargetYear]			
			FROM #Cn2Cs_Prk_InstitutionsTargetSetting 
			GROUP BY ProgramCode,[FromProgramYear],EffFromMonthId,EffToMonthId,ToProgramYear
			
			--Retailer Details
			--INSERT INTO InsTargetDetails (InsId,RtrCtgMainId,RtrId,AvgSal,[Target],Achievement,BaseAch,TargetAch,
			--ValBaseAch,ValTargetAch,ClmAmount,Liability,Availability,LastModBy,LastModDate,AuthId,AuthDate,
			--RtrUniqueCode,CmpRtrCode,AchDownloadDate,MonthName,RtrGroup)
			
			--SELECT DISTINCT H.InsId,C.CtgMainId,C.RtrId,P.AVGSales,P.[TargetAmount],
			--0 Achievement,0 BaseAch,0 TargetAch,0 ValBaseAch,0 ValTargetAch,0 ClmAmount,0 Liability,
			--1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,CreatedDate AuthDate,
			--P.RtrUniqueCode,P.CmpRtrCode,'1900-01-01','',P.RtrGroup			
			--FROM #Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK)
			--INNER JOIN InsTargetHD H (NOLOCK) ON P.ProgramCode = H.InsRefNo
			--INNER JOIN #CSCtgCode C (NOLOCK) ON P.RtrGroup = C.CtgCode AND P.CmpRtrCode = C.CmpRtrCode
			--ORDER BY InsId,C.CtgMainId,C.RtrId
			
			INSERT INTO InsTargetDetails (InsId,RtrCtgMainId,RtrId,AvgSal,[Target],Achievement,BaseAch,TargetAch,
			ValBaseAch,ValTargetAch,ClmAmount,Liability,Availability,LastModBy,LastModDate,AuthId,AuthDate,
			RtrUniqueCode,CmpRtrCode)
			
			SELECT DISTINCT H.InsId,C.CtgMainId,C.RtrId,P.AVGSales,P.[TargetAmount],
			0 Achievement,0 BaseAch,0 TargetAch,0 ValBaseAch,0 ValTargetAch,0 ClmAmount,0 Liability,
			1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,CreatedDate AuthDate,
			P.RtrUniqueCode,P.CmpRtrCode		
			FROM #Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK)
			INNER JOIN InsTargetHD H (NOLOCK) ON P.ProgramCode = H.InsRefNo and P.EffFromMonthId=H.EffFromMonthId
			AND P.FromProgramYear=H.TargetYear
			INNER JOIN #CSCtgCode C (NOLOCK) ON P.RtrGroup = C.CtgCode AND P.CmpRtrCode = C.CmpRtrCode
			ORDER BY InsId,C.CtgMainId,C.RtrId
			
		
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cn2Cs_RetailerCreditNote' and XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_RetailerCreditNote
GO
CREATE PROCEDURE Proc_Cn2Cs_RetailerCreditNote
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_Cn2Cs_RetailerCreditNote 0
* PURPOSE	: To Insert and Update records  from xml file in the Table CreditNoteRetailer 
* CREATED	: Gopikrishnan.R
* CREATED DATE	: 10/11/2016
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo = 0
DECLARE @CreditRefNo AS NVARCHAR(50)
DECLARE @CreditDate AS Datetime
DECLARE @CmpRtrCode AS NVARCHAR(100)
DECLARE @CreditAccount AS NVARCHAR(100)
DECLARE @Reason AS NVARCHAR(200)
DECLARE @CreditAmount AS NVARCHAR(100)
DECLARE @Status AS NVARCHAR(100)
DECLARE @CrNoteNumber AS NVARCHAR(50)
DECLARE @Rtrid AS INT
DECLARE @CoaId AS INT
DECLARE @ReasonId AS INT
DECLARE @Taction AS INT
DECLARE @Tabname AS NVARCHAR(100)
DECLARE @CntTabname AS NVARCHAR(100)
DECLARE @Fldname AS NVARCHAR(100)
DECLARE @ErrDesc AS NVARCHAR(1000)
DECLARE @sSql AS NVARCHAR(4000)
DECLARE @ErrStatus		INT
DELETE FROM Cn2Cs_Prk_RetailerCreditNote WHERE DownloadFlag = 'Y'
	SET @CntTabname='CreditNoteRetailer'
	SET @Fldname='CrNoteNumber'
	SET @Tabname = 'Cn2Cs_Prk_RetailerCreditNote'
	SET @Taction=1
	DECLARE Cur_CreditNoteRetailer CURSOR 
	FOR SELECT DISTINCT ISNULL([CreditRefNumber],''),ISNULL([CmpRtrCode],''),
	ISNULL([CreditAmount],'0'),ISNULL(Status,''),ISNULL([Reason],'')
	FROM Cn2Cs_Prk_RetailerCreditNote where DownloadFlag='D'
	
	OPEN Cur_CreditNoteRetailer
	FETCH NEXT FROM Cur_CreditNoteRetailer INTO @CreditRefNo,@CmpRtrCode,@CreditAmount,@Status,@Reason
	WHILE @@FETCH_STATUS=0
		
		BEGIN
			
	        IF EXISTS (SELECT DISTINCT [CreditRefNumber] FROM Cn2Cs_Prk_RetailerCreditNote A WITH(NOLOCK),CreditNoteRetailer B WITH(NOLOCK)
	                   WHERE A.[CreditRefNumber] = @CreditRefNo AND A.[CreditRefNumber] = B.PostedRefNo AND ([CreditRefNumber] <> '' OR [CreditRefNumber] IS NOT NULL))
	        BEGIN
	             	SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Credit RefNumber:  ' + @CreditRefNo + ' Already available in CreditNote Supplier' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'CreditRefNumber',@ErrDesc)
	        END
	        IF EXISTS (SELECT DISTINCT [CreditRefNumber] FROM Cn2Cs_Prk_RetailerCreditNote WITH(NOLOCK) WHERE [CreditRefNumber] = @CreditRefNo AND 
	                   ([CreditRefNumber] = '' OR [CreditRefNumber] IS NULL))
	        BEGIN
	             	SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Credit RefNumber:  ' + @CreditRefNo + ' Should not be Empty' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'CreditRefNumber',@ErrDesc)
	        END            
	          
			IF NOT EXISTS  (SELECT * FROM Retailer WHERE CmpRtrCode = @CmpRtrCode )    
		  		BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Retailer Code:  ' + @CmpRtrCode + ' is not available' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'CmpRtrCode',@ErrDesc)
				END
				
			  IF EXISTS (SELECT DISTINCT [CreditRefNumber] FROM Cn2Cs_Prk_RetailerCreditNote WITH(NOLOCK) WHERE [CreditRefNumber] = @CreditRefNo AND 
	                   ([Reason] = '' OR [Reason] IS NULL))
	        BEGIN
	             	SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Reason for Credit Note Number :  ' + @CreditRefNo + ' Should not be Empty' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'Reason',@ErrDesc)
	        END 
	        
	        IF NOT EXISTS(SELECT * FROM COAMaster (NOLOCK) WHERE AcName='Institutions Target Setting')
			BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Credit Account for Credit Reference No:  ' + @CreditRefNo + ' is not available' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'CreditAccount',@ErrDesc)
				END
				
		   IF NOT EXISTS(SELECT * FROM ReasonMaster (NOLOCK) WHERE DESCRIPTION='Institutions Target Setting')
			BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Reason for Credit Reference No:  ' + @CreditRefNo + ' is not available' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'ReasonMaster',@ErrDesc)
				END
			
			IF ISNUMERIC(@CreditAmount)=0
				BEGIN
					SET @Po_ErrNo=1	
					SET @Taction=0
					SET @ErrDesc = 'Credit Amount should not be empty'		 
					INSERT INTO Errorlog VALUES (6,@Tabname,'CreditAmount',@ErrDesc)
	
				END	
			ELSE
				BEGIN
					IF CAST(@CreditAmount AS NUMERIC(18,2))<=0
						BEGIN
							SET @Po_ErrNo=1	
							SET @Taction=0
							SET @ErrDesc = 'Credit Amount should be greater than zero'		 
							INSERT INTO Errorlog VALUES (7,@Tabname,'CreditAmount',@ErrDesc)
						END
				END
									
			IF LTRIM(RTRIM(@Status))='' 
				BEGIN
					SET @Po_ErrNo=0
					SET @Taction=0
					SET @ErrDesc = 'Status should not be empty'		 
					INSERT INTO Errorlog VALUES (8,@Tabname,'Status',@ErrDesc)
				END
			ELSE
				BEGIN
					IF LTRIM(RTRIM(@Status))='Active' OR LTRIM(RTRIM(@Status))='InActive'
						BEGIN
							IF @Po_ErrNo=0
								BEGIN
									SET @Po_ErrNo=0	
								END	
						END
					ELSE
						BEGIN
							SET @Po_ErrNo=1		
							SET @Taction=0
							SET @ErrDesc = 'Status Type '+@Status+ ' is not available'		 
							INSERT INTO Errorlog VALUES (9,@Tabname,'Status',@ErrDesc)
						END
				END
				
				SELECT @CrNoteNumber= dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			IF @CrNoteNumber=''
				BEGIN
					SET @Po_ErrNo=1		
					SET @Taction=0
					SET @ErrDesc = 'Reset the Counter value'		 
					INSERT INTO Errorlog VALUES (10,@Tabname,'Counter Value',@ErrDesc)
				END
				
			IF  @Taction=1 AND @Po_ErrNo=0
				BEGIN
				    SET @Rtrid =(SELECT TOP 1 Rtrid from  Retailer(Nolock) WHERE CmpRtrCode = @CmpRtrCode)
					SET @CoaId =(SELECT TOP 1 CoaId FROM  CoaMaster WHERE AcName='Institutions Target Setting')
					SET @ReasonId =(SELECT TOP 1 ReasonId FROM  ReasonMaster (Nolock) WHERE DESCRIPTION='Institutions Target Setting')
				    SET @CreditDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				    
					INSERT INTO CreditNoteRetailer (CrNoteNumber,CrNoteDate,Rtrid,CoaId,ReasonId,Amount,CrAdjAmount,Status,PostedFrom,TransId,PostedRefNo,
					Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks,XMLUpload) 
					VALUES(@CrNoteNumber,CONVERT(NVARCHAR(10),@CreditDate,121),@Rtrid,@CoaId,@ReasonId,CAST(@CreditAmount AS NUMERIC(18,2)),0,
					(CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END),@CrNoteNumber,32,@CreditRefNo,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),
					'Download from Console: '+@Reason,0)
					
					UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CreditNoteRetailer' AND FldName='CrNoteNumber'
					
					EXEC Proc_VoucherPosting 18,1,@CrNoteNumber,3,6,1,@CreditDate,@Po_ErrNo=@ErrStatus OUTPUT
				    IF @ErrStatus<>1
					BEGIN
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=0
					END
				END
		FETCH NEXT FROM Cur_CreditNoteRetailer INTO @CreditRefNo,@CmpRtrCode,@CreditAmount,@Status,@Reason
	END
	CLOSE Cur_CreditNoteRetailer
	DEALLOCATE Cur_CreditNoteRetailer
    UPDATE Cn2Cs_Prk_RetailerCreditNote SET DownloadFlag = 'Y' WHERE CreditRefNumber IN (SELECT PostedRefNo FROM CreditNoteRetailer WITH (NOLOCK))
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cn2Cs_InstitutionsTargetAchievement' and XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_InstitutionsTargetAchievement
GO
CREATE PROCEDURE Proc_Cn2Cs_InstitutionsTargetAchievement
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_Cn2Cs_InstitutionsTargetAchievement 0
* PURPOSE	: To Validate InstitutionsTargetAchievement and move to main
* CREATED	: Gopikrishnan
* CREATED DATE	: 11/11/2016
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
BEGIN
	SET @Po_ErrNo=0
	
	DECLARE @ProgramCode Nvarchar(50)
	DECLARE @CmpRtrCode Nvarchar(50)
	DECLARE @Month Nvarchar(50)
	DECLARE @Achievement Numeric(18,6)
	DECLARE @BasePer Numeric(18,6)
	DECLARE @TargetPer Numeric(18,6)
	DECLARE @BaseValue Numeric(18,6)
	DECLARE @TargetValue Numeric(18,6)
	DECLARE @ClmAmt Numeric(18,6)
	DECLARE @Liability Numeric(18,6)
	
	DECLARE @Insid as Int
	BEGIN TRY		
			
			DELETE PRK FROM Cn2Cs_Prk_InstitutionsTargetAchievement PRK (NOLOCK) WHERE DownloadFlag='Y'
			
			SELECT DISTINCT * INTO #Cn2Cs_Prk_InstitutionsTargetAchievement FROM Cn2Cs_Prk_InstitutionsTargetAchievement (NOLOCK) WHERE DownloadFlag='D'
			
			IF NOT EXISTS (SELECT * FROM #Cn2Cs_Prk_InstitutionsTargetAchievement (NOLOCK)) RETURN
			
			CREATE TABLE #InsToAvoidAch
			(
				ProgramCode VARCHAR(50),
				CmpRtrCode  VARCHAR(50),
				SlNo INT,
				TableName NVARCHAR (200),
				FieldName NVARCHAR (200),
				ErrDesc	NVARCHAR (1000)
			)
			
			
			
			INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,CmpRtrCode,1,'Cn2Cs_Prk_InstitutionsTargetAchievement','ProgramCode','The program code Not Exists ' + 
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement Prk (NOLOCK) 
			WHERE ProgramCode NOT IN (SELECT ProgramCode FROM InsTargetHD C (NOLOCK))
			
			INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,CmpRtrCode,2,'Cn2Cs_Prk_InstitutionsTargetAchievement','ProgramCode','No values should be NULL for the Program ' +
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement 
			WHERE (ProgramYear) IS NULL 
			OR (ProgramMonth) IS NULL OR (MonthId) IS NULL 
			OR (CmpRtrCode) IS NULL
			OR (Achievement + [BaseAchievement%] +[TargetAchievement%]+ [BaseAchievementValue]+
			 TargetAchievementValue + ClaimAmount + Liability) IS NULL
			 
			INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,CmpRtrCode,3,'Cn2Cs_Prk_InstitutionsTargetAchievement','ProgramCode','The Retailer code Not Exists ' + 
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement Prk (NOLOCK) 
			WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer (NOLOCK))
			 
			--INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			--SELECT DISTINCT ProgramCode,CmpRtrCode,4,'Cn2Cs_Prk_InstitutionsTargetAchievement','Achievement','Achievement field should not be Zero Or NULL' +
			--ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement 
			--WHERE ISNULL(Achievement,0) = 0
			
			--INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			--SELECT DISTINCT ProgramCode,CmpRtrCode,5,'Cn2Cs_Prk_InstitutionsTargetAchievement','[BaseAchievement%]','[BaseAchievement%] field should not be Zero Or NULL' +
			--ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement 
			--WHERE ISNULL([BaseAchievement%],0) = 0
			
			--INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			--SELECT DISTINCT ProgramCode,CmpRtrCode,6,'Cn2Cs_Prk_InstitutionsTargetAchievement','[TargetAchievement%]','[TargetAchievement%] field should not be Zero Or NULL' +
			--ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement 
			--WHERE ISNULL([TargetAchievement%],0) = 0
			
			
			--INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			--SELECT DISTINCT ProgramCode,CmpRtrCode,7,'Cn2Cs_Prk_InstitutionsTargetAchievement','BaseAchievementValue','BaseAchievementValue field should not be Zero Or NULL' +
			--ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement 
			--WHERE ISNULL(BaseAchievementValue,0) = 0
			
			--INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			--SELECT DISTINCT ProgramCode,CmpRtrCode,8,'Cn2Cs_Prk_InstitutionsTargetAchievement','TargetAchievementValue','TargetAchievementValue field should not be Zero Or NULL' +
			--ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement 
			--WHERE ISNULL(TargetAchievementValue,0) = 0
			
			--INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			--SELECT DISTINCT ProgramCode,CmpRtrCode,9,'Cn2Cs_Prk_InstitutionsTargetAchievement','ClaimAmount','ClaimAmount field should not be Zero Or NULL' +
			--ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement 
			--WHERE ISNULL(ClaimAmount,0) = 0
			
			--INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			--SELECT DISTINCT ProgramCode,CmpRtrCode,10,'Cn2Cs_Prk_InstitutionsTargetAchievement','Liability','Liability field should not be Zero Or NULL' +
			--ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement 
			--WHERE ISNULL(Liability,0) = 0
			
			INSERT INTO #InsToAvoidAch (ProgramCode,CmpRtrCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,CmpRtrCode,11,'Cn2Cs_Prk_InstitutionsTargetAchievement','ProgramCode','The Retailer code Not Exists ' + 
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement Prk (NOLOCK) 
			WHERE ProgramCode + '~' + CmpRtrCode NOT IN (SELECT DISTINCT InsRefNo + '~' + CmpRtrCode FROM InsTargetHD A (NOLOCK) 
			INNER JOIN InsTargetDetails B (Nolock) ON A.InsId=B.InsId )
			
			
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT SlNo,TableName,FieldName,ErrDesc FROM #InsToAvoidAch (NOLOCK)
			
			DELETE P FROM #Cn2Cs_Prk_InstitutionsTargetAchievement P 
			WHERE ProgramCode + '~' + CmpRtrCode In (SELECT ProgramCode + '~' + CmpRtrCode FROM #InsToAvoidAch A (NOLOCK))
			
			
		
			
			INSERT INTO InsTargetDetailsAch(Insid,TargetYear,TargetMonth,RtrId,Achievement,BaseAch,TargetAch,
			ValBaseAch,ValTargetAch,ClmAmount,Liability,Availability,LastModBy,LastModDate,AuthId,AuthDate,
			RtrUniqueCode,CmpRtrCode)
			SELECT Distinct Insid,ProgramYear,ProgramMonth,R.Rtrid,Achievement,[BaseAchievement%],[TargetAchievement%],
			[BaseAchievementValue],[TargetAchievementValue],[ClaimAmount],[Liability],1,1,Getdate(),
			1,GETDATE(),A.RtrUniqueCode,A.CmpRtrCode FROM #Cn2Cs_Prk_InstitutionsTargetAchievement A (Nolock)
			INNER JOIN InsTargetHD H (NOLOCK) ON A.ProgramCode = H.InsRefNo 
			AND A.ProgramYear=H.TargetYear AND A.MonthId=H.EffFromMonthId
			INNER JOIN Retailer R (Nolock) ON A.CmpRtrCode=R.CmpRtrCode
			
			UPDATE P SET P.DownloadFlag='Y'
			FROM Cn2Cs_Prk_InstitutionsTargetAchievement P (NOLOCK),
			#Cn2Cs_Prk_InstitutionsTargetAchievement HP,
			InsTargetHD H (NOLOCK) WHERE P.ProgramCode = HP.ProgramCode AND P.ProgramCode = H.InsRefNo
			and HP.CmpRtrCode=P.CmpRtrCode
	END TRY
	
	BEGIN CATCH
		PRINT 'There is a problem in process!'
		SET @Po_ErrNo=1 -- 1 will rollback the process through Sync EXE
		RETURN
	END CATCH		
		
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Fn_FillRetailerDetailsinRetailerMaster' and XTYPE IN ('TF','FN'))
DROP FUNCTION Fn_FillRetailerDetailsinRetailerMaster
GO
CREATE FUNCTION Fn_FillRetailerDetailsinRetailerMaster(@Pi_TransId INT,@Pi_LgnId INT)
RETURNS @FillRetailerDetails TABLE
(
RtrId	INT,
RtrCode	NVARCHAR(100),
RtrName	NVARCHAR(100),
RtrAdd1	NVARCHAR(100),
RtrAdd2	NVARCHAR(100),
RtrAdd3	NVARCHAR(100),
RtrPinNo	INT,
RtrPhoneNo	NVARCHAR(100),
RtrEmailId	NVARCHAR(100),
RtrContactPerson	NVARCHAR(100),
RtrKeyAcc	NVARCHAR(100),
RtrCovMode	NVARCHAR(100),
RtrRegDate	DATETIME,
RtrDepositAmt	NUMERIC(18,2),
RtrStatus	NVARCHAR(100),
RtrTaxable	NVARCHAR(100),
RtrTaxType	NVARCHAR(100),
TaxGroupName	NVARCHAR(100),
RtrTINNo	NVARCHAR(100),
RtrCSTNo	NVARCHAR(100),
RtrDayOff	NVARCHAR(100),
RtrCrBills	INT,
RtrCrLimit	NUMERIC(18,2),
RtrCrDays	INT,
RtrCashDiscPerc	NUMERIC(18,2),
RtrCashDiscCond	VARCHAR(50),
RtrCashDiscAmt	NUMERIC(18,2),
RtrLicNo	NVARCHAR(100),
RtrLicExpiryDate	DATETIME,
RtrDrugLicNo	NVARCHAR(100),
RtrDrugExpiryDate	DATETIME,
RtrPestLicNo	NVARCHAR(100),
RtrPestExpiryDate	DATETIME,
GeoMainId	INT,
GeoName	NVARCHAR(100),
GeoLevelName	NVARCHAR(100),
RmId	INT,
RMName	NVARCHAR(100),
VillageId	INT,
VillageName	NVARCHAR(100),
RtrShipId	INT,
RtrShipAdd1	NVARCHAR(100),
RtrShipAdd2	NVARCHAR(100),
RtrShipAdd3	NVARCHAR(100),
RtrShipPinNo	INT,
RtrResPhone1	NVARCHAR(100),
RtrResPhone2	NVARCHAR(100),
RtrOffPhone1	NVARCHAR(100),
RtrOffPhone2	NVARCHAR(100),
RtrDOB	DATETIME,
RtrAnniversary	DATETIME,
RtrRemark1	NVARCHAR(100),
RtrRemark2	NVARCHAR(100),
RtrRemark3	NVARCHAR(100),
COAId	INT,
OnAccount	NUMERIC(18,2),
TaxGroupId	INT,
RtrType	NVARCHAR(100),
RtrFrequency	TINYINT,
RtrCrBillsAlert	TINYINT,
RtrCrLimitAlert	TINYINT,
RtrCrDaysAlert	TINYINT,
RtrKeyId	TINYINT,
RtrCoverageId	TINYINT,
RtrStatusId	TINYINT,
RtrDayOffId	INT,
RtrTaxableId	TINYINT,
RtrTaxTypeId	TINYINT,
RtrTypeId	TINYINT,
RtrRlStatus	NVARCHAR(100),
RlStatus	TINYINT,
CmpRtrCode	NVARCHAR(100),
Upload	NVARCHAR(10),
RtrPayment NVARCHAR(100),
RtrPaymentId INT,
RtrApproval NVARCHAR(100),
RtrApprovalId INT,
RtrUniqueCode NVARCHAR(200) ---Gopi at 08/11/2016
)
AS
BEGIN
	INSERT INTO @FillRetailerDetails (RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrContactPerson,RtrKeyAcc,
    RtrCovMode,RtrRegDate,RtrDepositAmt,RtrStatus,RtrTaxable,RtrTaxType,TaxGroupName,RtrTINNo,RtrCSTNo,RtrDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
    RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,GeoMainId,
    GeoName,GeoLevelName,RmId,RMName,VillageId,VillageName,RtrShipId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrResPhone1,RtrResPhone2,
    RtrOffPhone1,RtrOffPhone2,RtrDOB,RtrAnniversary,RtrRemark1,RtrRemark2,RtrRemark3,COAId,OnAccount,TaxGroupId,RtrType,RtrFrequency,RtrCrBillsAlert,
    RtrCrLimitAlert,RtrCrDaysAlert,RtrKeyId,RtrCoverageId,RtrStatusId,RtrDayOffId,RtrTaxableId,RtrTaxTypeId,RtrTypeId,RtrRlStatus,RlStatus,
    CmpRtrCode,Upload,RtrPayment,RtrPaymentId,RtrApproval,RtrApprovalId,RtrUniqueCode)
    SELECT Rt.RtrId,Rt.RtrCode,Rt.RtrName,Rt.RtrAdd1,Rt.RtrAdd2,Rt.RtrAdd3,Rt.RtrPinNo,Rt.RtrPhoneNo,Rt.RtrEmailId,Rt.RtrContactPerson, 
	ISNULL(SD1.CtrlDesc,'') AS RtrKeyAcc, ISNULL(SD2.CtrlDesc,'') AS RtrCovMode,Rt.RtrRegDate,Rt.RtrDepositAmt,ISNULL(SD3.CtrlDesc,'') AS RtrStatus, 
	ISNULL(SD4.CtrlDesc,'') AS RtrTaxable, ISNULL(SD5.CtrlDesc,'') AS RtrTaxType,ISNULL(TG.TaxGroupName,'') AS  TaxGroupName,
	Rt.RtrTINNo,Rt.RtrCSTNo, ISNULL(SD6.CtrlDesc,'') AS RtrDayOff, Rt.RtrCrBills,Rt.RtrCrLimit,Rt.RtrCrDays, Rt.RtrCashDiscPerc,  
	(CASE Rt.RtrCashDiscCond WHEN 1 THEN '>=' WHEN 0 THEN '<=' End)As RtrCashDiscCond,Rt.RtrCashDiscAmt,
	Rt.RtrLicNo,Rt.RtrLicExpiryDate,Rt.RtrDrugLicNo,Rt.RtrDrugExpiryDate,Rt.RtrPestLicNo,Rt.RtrPestExpiryDate,
	GE.GeoMainId,GE.GeoName,Gl.GeoLevelName,Rm.RmId,Rm.RMName,Rv.VillageId,Rv.VillageName,Rs.RtrShipId,
	Rs.RtrShipAdd1,Rs.RtrShipAdd2,Rs.RtrShipAdd3,Rs.RtrShipPinNo,Rt.RtrResPhone1,Rt.RtrResPhone2,Rt.RtrOffPhone1,Rt.RtrOffPhone2,
	Rt.RtrDOB,Rt.RtrAnniversary,Rt.RtrRemark1,Rt.RtrRemark2,Rt.RtrRemark3
	,Rt.COAId ,Rt.RtrOnAcc as OnAccount,Rt.TaxGroupId,  ISNULL(SD7.CtrlDesc,'') AS RtrType, Rt.RtrFrequency , 
	Rt.RtrCrBillsAlert, Rt.RtrCrLimitAlert, Rt.RtrCrDaysAlert, Rt.RtrKeyAcc AS RtrKeyId,Rt.RtrCovMode AS RtrCoverageId,Rt.RtrStatus 
	AS RtrStatusId,Rt.RtrDayOff AS RtrDayOffId, Rt.RtrTaxable AS RtrTaxableId,Rt.RtrTaxType AS RtrTaxTypeId,Rt.RtrType AS RtrTypeId ,
	ISNULL(SD8.CtrlDesc,'') AS RtrRlStatus,ISNULL(Rt.RtrRlStatus,1) AS RlStatus,Rt.CmpRtrCode,Rt.Upload ,
	ISNULL(SD9.CtrlDesc,'') AS RtrPayment,Rt.RtrPayment AS RtrPayModeId,ISNULL(SD10.CtrlDesc,'') AS RtrApproval,
	Rt.Approved AS RtrApprovalId,ISNULL(Rt.RtrUniqueCode,'') AS RtrUniqueCode
	FROM GeographyLevel Gl,Retailer Rt  
	LEFT OUTER JOIN Geography Ge ON GE.GeoMainId=Rt.GeoMainId  
	LEFT OUTER JOIN RouteMaster Rm ON Rm.RMId=Rt.RMId  
	LEFT OUTER JOIN RouteVillage Rv ON Rv.VillageId=Rt.VillageId  
	LEFT OUTER JOIN RetailerShipAdd Rs ON Rs.RtrShipId=Rt.RtrShipId  
	LEFT OUTER JOIN TaxGroupSetting TG ON TG.TaxGroupId=Rt.TaxGroupId  
	LEFT OUTER JOIN ScreenDefaultValues SD1 ON SD1.CtrlValue=Rt.RtrKeyAcc AND SD1.CtrlId=10 AND SD1.TransId=@Pi_TransId AND SD1.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD2 ON SD2.CtrlValue=Rt.RtrCovMode AND SD2.CtrlId=11 AND SD2.TransId=@Pi_TransId AND SD2.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD3 ON SD3.CtrlValue=Rt.RtrStatus AND SD3.CtrlId=14 AND SD3.TransId=@Pi_TransId AND SD3.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD4 ON SD4.CtrlValue=Rt.RtrTaxable AND SD4.CtrlId=18 AND SD4.TransId=@Pi_TransId AND SD4.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD5 ON SD5.CtrlValue=Rt.RtrTaxType AND SD5.CtrlId=19 AND SD5.TransId=@Pi_TransId AND SD5.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD6 ON SD6.CtrlValue=Rt.RtrDayOff AND SD6.CtrlId=13 AND SD6.TransId=@Pi_TransId AND SD6.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD7 ON SD7.CtrlValue=Rt.RtrType AND SD7.CtrlId=56 AND SD7.TransId=@Pi_TransId AND SD7.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD8 ON SD8.CtrlValue=Rt.RtrRlStatus AND SD8.CtrlId=135 AND SD8.TransId=@Pi_TransId AND SD8.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD9 ON SD9.CtrlValue=Rt.RtrPayment AND SD9.CtrlId=163 AND SD9.TransId=@Pi_TransId AND SD9.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD10 ON SD10.CtrlValue=Rt.Approved AND SD10.CtrlId=164 AND SD10.TransId=@Pi_TransId AND SD10.LngId=@Pi_LgnId 
	WHERE GE.GeoLevelId = Gl.GeoLevelId
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where Name='Fn_ReturnRptFiltersValue' and Xtype IN ('TF','FN'))
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
			AND @iSelid <> 195 AND @iSelid <> 199 AND @iSelid <> 201 AND @iSelid <> 278 AND @iSelid <> 275 AND @iSelid <> 316  AND @iSelid <> 317  
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
				
			   If  @iSelid=317
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				
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
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Proc_LoadingInstitutionsTarget' AND XTYPE = 'P')
DROP PROCEDURE Proc_LoadingInstitutionsTarget
GO
/*
Begin transaction
delete from InsTargetDetailsTrans
EXEC Proc_LoadingInstitutionsTarget 2016,11,'November',2
--select * from InsTargetDetailsTrans
rollback transaction
*/
create PROCEDURE Proc_LoadingInstitutionsTarget
(
	@Year AS INT,
	@Month AS INT,
	@MonthName AS Nvarchar(50),
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
		DECLARE @Confirm TINYINT
		
		DECLARE @FromDate DATETIME
		DECLARE @ToDate DATETIME
		
	
		SELECT @FromDate = CONVERT(Nvarchar(10),CAST(@Year AS VARCHAR(5))+ '-' + CAST(@Month AS VARCHAR(2)) + '-01',121)
		SELECT @ToDate = DATEADD(DD,-1,DATEADD(MM,1,@FromDate))
		
		DECLARE  @InsDetails TABLE
		(
		 Insid Int,
		 Rtrid int,
		 Achievement Numeric(18,6),
		 BaseAch Numeric(18,6),
		 TargetAch Numeric(18,6),
		 ValBaseAch Numeric(18,6),
		 ValTargetAch Numeric(18,6),
		 ClmAmount Numeric(18,6),
		 Liability Numeric(18,6)
		 )
		 
		 CREATE TABLE #Institution
		 (
		  CtgMainId Int,
		  CtgName Nvarchar(100),
		  Rtrid int,
		  RtrCode Nvarchar(50),
		  RtrName Nvarchar(100),
		  AvgSal Numeric(18,6),
		  Target Numeric(18,6),
		  Achievement Numeric(18,6),
		  BaseAch Numeric(18,6),
		  TargetAch Numeric(18,6),
		  ValBaseAch Numeric(18,6),
		  ValTargetAch Numeric(18,6),
		  ClmAmount Numeric(18,6),
		  Liability Numeric(18,6),
		  CSAch Numeric(18,6),
		  Insid int,
		  Flag Int
		  )
		  
		  
		 
		 
		INSERT INTO #Institution
		SELECT Distinct CtgMainId,CtgName,Rtrid,RtrCode,RtrName,AvgSal,[Target],0.00 as Achievement,0.00 as BaseAch,0.00 as TargetAch,
		0.00 as ValBaseAch,0.00 as ValTargetAch,0.00 as ClmAmount,0.00 as Liability,0.00 AS CSAch,Insid,0 as Flag  FROM
		(SELECT DISTINCT C.CtgMainId,C.CtgName,R.RtrId,R.RtrCode,R.RtrName,D.AvgSal,D.[Target],H.Insid
		FROM InsTargetHD H (NOLOCK)
		INNER JOIN InsTargetDetails D (NOLOCK) ON H.InsId = D.InsId
		INNER JOIN RetailerCategory C (NOLOCK) ON D.RtrCtgMainId = C.CtgMainId
		INNER JOIN RetailerValueClass V (NOLOCK) ON C.CtgMainId = V.CtgMainId
		INNER JOIN RetailerValueClassMap M (NOLOCK) ON V.RtrClassId = M.RtrValueClassId
		INNER JOIN Retailer R (NOLOCK) ON M.RtrId = R.RtrId AND D.RtrId = R.RtrId
		WHERE H.EffFromMonthId = @Month and H.TargetYear=@Year
		--WHERE H.EffFromMonthId <= @Month and H.TargetYear=@Year
		--UNION ALL
		--SELECT DISTINCT C.CtgMainId,C.CtgName,R.RtrId,R.RtrCode,R.RtrName,D.AvgSal,D.[Target],H.Insid
		--FROM InsTargetHD H (NOLOCK)
		--INNER JOIN InsTargetDetails D (NOLOCK) ON H.InsId = D.InsId
		--INNER JOIN RetailerCategory C (NOLOCK) ON D.RtrCtgMainId = C.CtgMainId
		--INNER JOIN RetailerValueClass V (NOLOCK) ON C.CtgMainId = V.CtgMainId
		--INNER JOIN RetailerValueClassMap M (NOLOCK) ON V.RtrClassId = M.RtrValueClassId
		--INNER JOIN Retailer R (NOLOCK) ON M.RtrId = R.RtrId AND D.RtrId = R.RtrId
		--WHERE H.EffToMonthId >= @Month and H.ToTargetYear=@Year		
		) A
		ORDER BY A.CtgName,A.RtrName
	
		
	
		
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
			
			INSERT INTO @InsDetails (Insid,Rtrid,Achievement,BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability)
			SELECT DISTINCT Insid,Rtrid,Achievement,BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability
			FROM InsTargetDetailsAch (Nolock)
			WHERE TargetYear=@Year and TargetMonth=@MonthName
			and Insid In (SELECT Distinct Insid from #Institution)			
									
			UPDATE I SET I.Achievement=A.Achievement,
			I.BaseAch=A.BaseAch,I.TargetAch=A.TargetAch,I.ValBaseAch=A.ValBaseAch,I.ValTargetAch=A.ValTargetAch,
			I.ClmAmount=A.ClmAmount,I.Liability=A.Liability,Flag=1
			FROM #Institution I (NOLOCK) INNER JOIN @InsDetails A
			ON I.Insid=A.Insid and I.Rtrid=A.Rtrid
						
			UPDATE I SET I.CSAch = A.Sales -- IF NEGATIVE?
			FROM #Institution I (NOLOCK),
			#SalesAsAchievement A (NOLOCK)
			WHERE I.RtrId = A.RtrId
	
		
		UPDATE I SET 
		I.AvgSal		= CAST(I.AvgSal AS NUMERIC(18,2)),
		I.[Target]		= CAST(I.[Target] AS NUMERIC(18,2)),
		I.Achievement	= CAST(I.Achievement AS NUMERIC(18,2)),
		I.BaseAch		= CAST(I.BaseAch AS NUMERIC(18,2)),
		I.TargetAch		= CAST(I.TargetAch AS NUMERIC(18,2)),
		I.ValBaseAch	= CAST(I.ValBaseAch AS NUMERIC(18,2)),
		I.ValTargetAch	= CAST(I.ValTargetAch AS NUMERIC(18,2)),
		I.ClmAmount		= CAST(I.ClmAmount AS NUMERIC(18,2)),
		I.Liability		= CAST(I.Liability AS NUMERIC(18,2)),
		I.CSAch		    = CAST(I.CSAch AS NUMERIC(18,2))
		FROM #Institution I (NOLOCK)		
		
		INSERT INTO InsTargetDetailsTrans (SlNo,CtgMainId,CtgName,RtrId,RtrCode,RtrName,AvgSal,[Target],
		CSAchievement,Achievement,BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,UserId,Flag)
		
		SELECT SlNo,CtgMainId,CtgName,RtrId,RtrCode,RtrName,AvgSal,[Target],
		CSAch,Achievement,BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,@UserId UserId,Flag
		FROM
		(
		SELECT ROW_NUMBER() OVER (PARTITION BY CtgMainId ORDER BY CtgName,RtrCode) SlNo,
		CtgMainId,CtgName,RtrId,RtrCode,RtrName,AvgSal,[Target],
		CSAch,Achievement,BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,Flag 
		FROM #Institution
		UNION ALL
		SELECT 9999 SlNo,CtgMainId,'ZZZZZZZZ' CtgName,0 RtrId,'ZZZZZZZZ' RtrCode,'Total' RtrName,SUM(AvgSal) AvgSal,SUM([Target]) [Target],
		sum(CSAch) CSAch,SUM(Achievement) Achievement,SUM(BaseAch) BaseAch,SUM(TargetAch) TargetAch,SUM(ValBaseAch) ValBaseAch,SUM(ValTargetAch) ValTargetAch,
		SUM(ClmAmount) ClmAmount,SUM(Liability),1 as Flag 
		FROM #Institution ROLLUP
		GROUP BY CtgMainId
		) Consolidated ORDER BY CtgMainId,RtrCode
		
		UPDATE I SET CtgName = '',RtrCode = ''
		FROM InsTargetDetailsTrans I (NOLOCK) WHERE SlNo = 9999
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_RptInstitutionsTargetReport' and XTYPE='P')
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
		
	DECLARE @Year	AS INT	
	DECLARE @Month  AS INT
	DECLARE @MonthName as Nvarchar(100)

	SET @Year = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,149,@Pi_UsrId))
	SET @Month = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,317,@Pi_UsrId))
	SET @MonthName=(SELECT  TOP 1 sCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,317,@Pi_UsrId))
	
	
	EXEC Proc_LoadingInstitutionsTarget @Year,@Month,@MonthName,@Pi_UsrId
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptInstitutionsTargetReport_Excel')
	DROP TABLE RptInstitutionsTargetReport_Excel
	
	SELECT CtgName,RtrCode,RtrName,AvgSal,[Target],CSAchievement,Achievement,BaseAch,TargetAch,
	ValBaseAch,ValTargetAch,ClmAmount,Liability,Flag 
	INTO RptInstitutionsTargetReport_Excel
	FROM InsTargetDetailsTrans (NOLOCK)  
	WHERE UserId = @Pi_UsrId Order by Ctgmainid,SlNo 
	


	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptInstitutionsTargetReport_Excel
	
	SELECT * FROM RptInstitutionsTargetReport_Excel
	
	RETURN
END
GO
DELETE FROM RptFormula WHERE RPTID=289
GO
INSERT INTO RptFormula (Rptid,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 289,1,'Hd_DistName','',1,0
UNION
SELECT 289,2,'Disp_Year','Financial Year',1,0
UNION
SELECT 289,3,'Val_Year','',1,149
UNION
SELECT 289,4,'Disp_Month','Financial Month',1,0
UNION
SELECT 289,5,'Val_Month','',1,317
UNION
SELECT 289,6,'Cap Page','Page',1,0
UNION
SELECT 289,7,'Cap User Name','User Name',1,0
UNION
SELECT 289,8,'Cap Print Date','Date',1,0
UNION
SELECT 289,9,'CtgName','Retailer Group',1,0
UNION
SELECT 289,10,'RtrCode','Retailer Code',1,0
UNION
SELECT 289,11,'RtrName','Retailer Name',1,0
UNION
SELECT 289,12,'AvgSal','Avg Sale',1,0
UNION
SELECT 289,13,'Target','Target',1,0
UNION
SELECT 289,14,'CsAch','As on Date Ach',1,0
UNION
SELECT 289,15,'Achievement','Achievement',1,0
UNION
SELECT 289,16,'BaseAch','Base Ach.(%)',1,0
UNION
SELECT 289,17,'TargetAch','Target Ach. (%)',1,0
UNION
SELECT 289,18,'ValBaseAch','Value On Base Ach.',1,0
UNION
SELECT 289,19,'ValTargetAch','Value On Target Ach.',1,0
UNION
SELECT 289,20,'ClmAmount','Claim Amount',1,0
UNION
SELECT 289,21,'Liability','Liability (%)',1,0
GO
DELETE from CustomCaptions where TransId = 79 AND CtrlId = 1000 AND SubCtrlId IN(46,47)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled])
SELECT 79,1000,46,'MsgBox-79-1000-46','','','Phone Number Should be Unique',1,1,1,getdate(),1,getdate(),'','','Phone Number Should be Unique',1,1 UNION 
SELECT 79,1000,47,'MsgBox-79-1000-47','','','Tin Number Should be Unique',1,1,1,getdate(),1,getdate(),'','','Tin Number Should be Unique',1,1 
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Proc_Cn2Cs_RetailerMigration' AND XTYPE = 'P')
DROP PROCEDURE Proc_Cn2Cs_RetailerMigration
GO
/*
Begin transaction
delete from ErrorLog
exec Proc_Cn2Cs_RetailerMigration 0
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
* {date}		{developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo=0
DECLARE @CmpId AS NUMERIC(18,0)
DECLARE @SmId AS NUMERIC(18,0)
DECLARE @RmId AS NUMERIC(18,0)
DECLARE @DlvRmId AS NUMERIC(18,0)
DECLARE @UdcMasterId AS NUMERIC(18,0)
DECLARE @DistCode AS NVARCHAR(200)
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
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrTinNumber','Duplicate Tin Number Not allow-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrTinNumber=B.RtrTINNo) AND DownloadFlag = 'D'
	AND ISNULL(A.RtrTinNumber,'') <> ''
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE LEN(RtrTinNumber) NOT BETWEEN 8 AND 12 AND DownloadFlag = 'D'

	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrTinNumber','Tin Number length Should be between 8 to 12-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	LEN(RtrTinNumber) NOT BETWEEN 8 AND 12 AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE LEN(RtrPhoneNo) NOT BETWEEN 8 AND 10 AND DownloadFlag = 'D'

	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Phone Number length Should be between 8 to 10-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	LEN(RtrPhoneNo) NOT BETWEEN 8 AND 10 AND DownloadFlag = 'D'
	
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

	IF EXISTS (SELECT '*' FROM Configuration WHERE ModuleId = 'GENCONFIG30' AND ModuleName = 'General Configuration' AND Status = 1)
	BEGIN
		INSERT INTO #ToAvoidRetailerMigration(RetailerCode)		
		SELECT DISTINCT CmpRtrCode from Cn2Cs_Prk_RetailerMigration (NOLOCK) WHERE isnull(RtrPhoneNo,'') = ''
		
		INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
		SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Retailer Phone Number Should be Mandatory-'+ RtrCode 
		FROM Cn2Cs_Prk_RetailerMigration  (NOLOCK)	where isnull(RtrPhoneNo,'') = ''		
		
	END
    	
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
	SELECT DISTINCT SalesManName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPincode,CtgLevelId,CtgLevelName,
	CtgMainId,CtgName,RtrClassId,ValueClassName,B.GeoLevelId,RetailerGeoLevel,C.GeoMainId,GeoName,D.RmId,SalRouteName,E.RmId,DlvRouteName,
	[Status],0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121),RtrPhoneNo,RtrTinNumber,ISNULL(TaxGroupId,0)AS RtrTaxGroupId,A.RtrUniqueCode
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
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_ValidateRetailerMaster' and XTYPE='P')
DROP PROCEDURE Proc_ValidateRetailerMaster
GO
/*
BEGIN TRANSACTION
Exec Proc_ValidateRetailerMaster 0
SELECT * FROM Retailer
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_ValidateRetailerMaster
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ValidateRetailerMaster
* PURPOSE		: To Insert and Update records  from xml file in the Table Retailer
* CREATED		: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------------------
* {Date}         {Developer}             {Brief modification description}
  2013/10/10   Sathishkumar Veeramani     Junk Characters Removed  
*****************************************************************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @RetailerCode AS NVARCHAR(100)
	DECLARE @RetailerName AS NVARCHAR(100)
	DECLARE	@Address1 AS NVARCHAR(100)
	DECLARE	@Address2 AS NVARCHAR(100)
	DECLARE	@Address3 AS NVARCHAR(100)
	DECLARE	@PinCode AS NVARCHAR(100)
	DECLARE	@PhoneNo AS NVARCHAR(100)
	DECLARE	@EmailId AS NVARCHAR(100)
	DECLARE	@KeyAccount AS NVARCHAR(100)
	DECLARE	@CoverageMode AS NVARCHAR(100)
	DECLARE	@RegistrationDate AS DATETIME
	DECLARE	@DayOff	AS NVARCHAR(100)
	DECLARE	@Status	AS NVARCHAR(100)
	DECLARE	@Taxable AS NVARCHAR(100)
	DECLARE	@TaxType AS NVARCHAR(100)
	DECLARE	@TINNumber AS NVARCHAR(100)
	DECLARE @CSTNumber AS NVARCHAR(100)
	DECLARE	@TaxGroup AS NVARCHAR(100)
	DECLARE	@CreditBills AS NVARCHAR(100)
	DECLARE	@CreditLimit AS NVARCHAR(100)
	DECLARE	@CreditDays AS NVARCHAR(100)
	DECLARE	@CashDiscountPercentage AS NVARCHAR(100)
	DECLARE	@CashDiscountCondition AS NVARCHAR(100)
	DECLARE	@CashDiscountLimitValue AS NVARCHAR(100)
	DECLARE	@LicenseNumber AS NVARCHAR(100)
	DECLARE	@LicNumberExDate AS NVARCHAR(10)
	DECLARE	@DrugLicNumber AS NVARCHAR(100)
	DECLARE	@DrugLicExDate AS NVARCHAR(10)
	DECLARE	@PestLicNumber	AS NVARCHAR(100)
	DECLARE	@PestLicExDate AS NVARCHAR(10)
	DECLARE	@GeographyHierarchyValue AS NVARCHAR(100)
	DECLARE	@DeliveryRoute	AS NVARCHAR(100)
	DECLARE	@ResidencePhoneNo AS NVARCHAR(100)
	DECLARE	@OfficePhoneNo 	AS NVARCHAR(100)
	DECLARE	@DepositAmount 	AS NVARCHAR(100)
	DECLARE	@VillageCode 	AS NVARCHAR(100)
	DECLARE	@PotentialClassCode AS NVARCHAR(100)
	DECLARE	@RetailerType AS NVARCHAR(100)
	DECLARE	@RetailerFrequency AS NVARCHAR(100)
	DECLARE	@RtrCrDaysAlert AS NVARCHAR(100)
	DECLARE	@RtrCrBillAlert AS NVARCHAR(100)
	DECLARE	@RtrCrLimitAlert AS NVARCHAR(100)
	DECLARE @GeoMainId AS INT
	DECLARE @RMId AS INT
	DECLARE @VillageId AS INT
	DECLARE @RtrId AS INT
	DECLARE @TaxGroupId AS INT
	DECLARE @RtrClassId AS INT
	DECLARE @Taction AS INT
	DECLARE @Tabname AS NVARCHAR(100)
	DECLARE @CntTabname AS NVARCHAR(100)
	DECLARE @Fldname AS NVARCHAR(100)
	DECLARE @ErrDesc AS NVARCHAR(1000)
	DECLARE @sSql AS NVARCHAR(4000)
	DECLARE @CoaId AS INT
	DECLARE @AcCode AS NVARCHAR(1000)
	DECLARE @CmpRtrCode AS NVARCHAR(200)	
	
	SET @CntTabname='Retailer'
	SET @Fldname='RtrId'
	SET @Tabname = 'ETL_Prk_Retailer'
	SET @Taction=0
	SET @Po_ErrNo=0
	SET @VillageId=0
	
	DECLARE Cur_Retailer CURSOR
	FOR SELECT dbo.Fn_Removejunk(ISNULL([Retailer Code],'')),dbo.Fn_Removejunk(ISNULL([Retailer Name],'')),dbo.Fn_Removejunk(ISNULL([Address1],'')),
		dbo.Fn_Removejunk(ISNULL([Address2],'')),dbo.Fn_Removejunk(ISNULL([Address3],'')),
		ISNULL([Pin Code],'0'),ISNULL([Phone No],'0'),dbo.Fn_Removejunk(ISNULL(EmailId,'')),ISNULL([Key Account],''),
		ISNULL([Coverage Mode],''),CAST([Registration Date] AS DATETIME) AS [Registration Date],ISNULL([Day Off],''),
		ISNULL([Status],''),ISNULL([Taxable],''),ISNULL([Tax Type],''),ISNULL([TIN Number],''),
		ISNULL([CST Number],''),ISNULL([Tax Group],''),ISNULL([Credit Bills],'0'),ISNULL([Credit Limit],'0'),
		ISNULL([Credit Days],'0'),ISNULL([Cash Discount Percentage],'0'),ISNULL([Cash Discount Condition],''),
		ISNULL([Cash Discount Limit Value],'0'),ISNULL([License Number],''),
		ISNULL([License Number Expiry Date],NULL),
		ISNULL([Drug License Number],''),ISNULL([Drug License Number Expiry Date],NULL),
		ISNULL([Pesticide License Number],''),ISNULL([Pesticide License Number Expiry Date],NULL),
		ISNULL([Geography Hierarchy Value],''),ISNULL([Delivery Route Code],''),ISNULL([Village Code],''),
		ISNULL([Residence Phone No],''),ISNULL([Office Phone No],''),ISNULL([Deposit Amount],'0'),
		ISNULL([Potential Class Code],''),
		ISNULL([Retailer Type],'') ,
		ISNULL([Retailer Frequency],''),ISNULL([Credit Days Alert],'') ,
		ISNULL([Credit Bills Alert],'') ,ISNULL([Credit Limit Alert],'')
	FROM ETL_Prk_Retailer WITH(NOLOCK) ORDER BY [Retailer Code]
	OPEN Cur_Retailer
	FETCH NEXT FROM Cur_Retailer INTO @RetailerCode,@RetailerName,@Address1,@Address2,@Address3,@PinCode,@PhoneNo,@EmailId,@KeyAccount,@CoverageMode,@RegistrationDate,@DayOff,
	@Status,@Taxable,@TaxType,@TINNumber,@CSTNumber,@TaxGroup,@CreditBills,@CreditLimit,@CreditDays,
	@CashDiscountPercentage,@CashDiscountCondition,@CashDiscountLimitValue,@LicenseNumber,
	@LicNumberExDate,@DrugLicNumber,@DrugLicExDate,@PestLicNumber,@PestLicExDate,@GeographyHierarchyValue,
	@DeliveryRoute,@VillageCode,@ResidencePhoneNo,@OfficePhoneNo,@DepositAmount,@PotentialClassCode,
	@RetailerType,@RetailerFrequency,@RtrCrDaysAlert,@RtrCrBillAlert,@RtrCrLimitAlert
	WHILE @@FETCH_STATUS=0		
	BEGIN
		IF NOT EXISTS  (SELECT * FROM Geography WHERE GeoCode = @GeographyHierarchyValue )
  		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Geogrpahy Code: ' + @GeographyHierarchyValue + ' is not available'  		
			INSERT INTO Errorlog VALUES (1,@Tabname,'GeographyHierarchyValue',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @GeoMainId =GeoMainId FROM Geography WHERE GeoCode = @GeographyHierarchyValue
		END
		IF NOT EXISTS  (SELECT * FROM RouteMaster WHERE RMCode = @DeliveryRoute AND RMSRouteType=2 )
  		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Route Code ' + @DeliveryRoute + ' is not available'  		
			INSERT INTO Errorlog VALUES (2,@Tabname,'DeliveryRoute',@ErrDesc)
		END
		ELSE
		BEGIN		
			SELECT @RMId =RMId FROM RouteMaster WHERE RMCode = @DeliveryRoute
		END
		IF LTRIM(RTRIM(@PotentialClassCode)) <> ''
		BEGIN
			IF NOT EXISTS  (SELECT * FROM RetailerPotentialClass WHERE PotentialClassCode = @PotentialClassCode )
	  		BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Potential Class Code ' + @PotentialClassCode + ' is not available'  		
				INSERT INTO Errorlog VALUES (3,@Tabname,'PotentialClassCode',@ErrDesc)
			END
			ELSE
			BEGIN
				SELECT @RtrClassId =RtrClassId FROM RetailerPotentialClass WHERE PotentialClassCode = @PotentialClassCode
			END
		END
		SELECT @TaxGroupId = 0
		IF LTRIM(RTRIM(@TaxGroup)) <> ''
		BEGIN
			IF NOT EXISTS  (SELECT * FROM TaxGroupSetting WHERE RtrGroup = @TaxGroup)
	  		BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Retailer Tax Group Code ' + @TaxGroup + ' is not available'  		
				INSERT INTO Errorlog VALUES (4,@Tabname,'TaxGroup',@ErrDesc)
			END
			ELSE
			BEGIN
				SELECT @TaxGroupId =TaxGroupId FROM TaxGroupSetting WHERE RtrGroup = @TaxGroup
			END
		END
		IF LTRIM(RTRIM(@VillageCode)) <> ''
		BEGIN
			IF NOT EXISTS  (SELECT * FROM RouteVillage WHERE VillageCode = @VillageCode)
	  		BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Village Code ' + @VillageCode + ' is not available'  		
				INSERT INTO Errorlog VALUES (5,@Tabname,'VillageCode',@ErrDesc)
			END
			ELSE
			BEGIN
				SELECT @VillageId =VillageId FROM RouteVillage WHERE VillageCode = @VillageCode
			END
		END
		IF LTRIM(RTRIM(@RetailerCode))<>''
		BEGIN
			IF EXISTS  (SELECT * FROM Retailer WHERE RtrCode = @RetailerCode )
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
			SET @ErrDesc = 'Retailer Code should not be empty '  		
			INSERT INTO Errorlog VALUES (6,@Tabname,'RetailerCode',@ErrDesc)
		END
		IF LTRIM(RTRIM(@RetailerName))=''
		BEGIN
			SET @Po_ErrNo=1	
			SET @Taction=0
			SET @ErrDesc = 'Retailer Name should not be empty'		
			INSERT INTO Errorlog VALUES (7,@Tabname,'RetailerName',@ErrDesc)
		END	
		IF LTRIM(RTRIM(@Address1))=''
		BEGIN
			SET @Po_ErrNo=1	
			SET @Taction=0
			SET @ErrDesc = 'Retailer Address  should not be empty'		
			INSERT INTO Errorlog VALUES (8,@Tabname,'Address',@ErrDesc)
		END
		IF LEN(@PinCode)<>0
		BEGIN
			IF ISNUMERIC(@PinCode)=0
			BEGIN
				SET @Po_ErrNo=1	
				SET @Taction=0
				SET @ErrDesc = 'PinCode is not in correct format'		
				INSERT INTO Errorlog VALUES (9,@Tabname,'PinCode',@ErrDesc)
			END	
		END					
				
		IF LTRIM(RTRIM(@KeyAccount))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'KeyAccount should not be empty'		
			INSERT INTO Errorlog VALUES (10,@Tabname,'KeyAccount',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@KeyAccount))='Yes' OR LTRIM(RTRIM(@KeyAccount))='No'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Key Account Type '+@KeyAccount+ ' is not available'		
				INSERT INTO Errorlog VALUES (11,@Tabname,'KeyAccount',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@CoverageMode))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Coverage Mode should not be empty'		
			INSERT INTO Errorlog VALUES (12,@Tabname,'CoverageMode',@ErrDesc)
		END
		ELSE
			BEGIN
			IF LTRIM(RTRIM(@CoverageMode))='Order Booking' OR LTRIM(RTRIM(@CoverageMode))='Van Sales' OR LTRIM(RTRIM(@CoverageMode))='Counter Sales'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END	
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Coverage Mode Type '+@CoverageMode+ ' does not exists'		
				INSERT INTO Errorlog VALUES (13,@Tabname,'CoverageMode',@ErrDesc)
			END
		END
		
		IF LTRIM(RTRIM(@RegistrationDate))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Registration Date should not be empty'		
			INSERT INTO Errorlog VALUES (14,@Tabname,'RegistrationDate',@ErrDesc)
		END
		ELSE
		BEGIN
			IF ISDATE(@RegistrationDate)=0
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Registration Date '+@RegistrationDate+ ' not in date format'		
				INSERT INTO Errorlog VALUES (15,@Tabname,'RegistrationDate',@ErrDesc)
			END
			ELSE
			BEGIN
				IF @RegistrationDate > (CONVERT(NVARCHAR(11),GETDATE(),121))
				BEGIN
					SET @Po_ErrNo=1		
					SET @Taction=0
					SET @ErrDesc = 'Invalid Registration Date'		
					INSERT INTO Errorlog VALUES (16,@Tabname,'RegistrationDate',@ErrDesc)
				END
			END
		END
		IF LTRIM(RTRIM(@DayOff))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Day Off should not be empty'		
			INSERT INTO Errorlog VALUES (17,@Tabname,'DayOff',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@DayOff))='Sunday' OR LTRIM(RTRIM(@DayOff))='Monday' OR LTRIM(RTRIM(@DayOff))='Tuesday' OR
			LTRIM(RTRIM(@DayOff))='Wednesday' OR LTRIM(RTRIM(@DayOff))='Thursday' OR LTRIM(RTRIM(@DayOff))='Friday' OR
			LTRIM(RTRIM(@DayOff))='Saturday'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END	
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Day Off Type '+@DayOff+ ' is not available'		
				INSERT INTO Errorlog VALUES (18,@Tabname,'DayOff',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@Status))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Status should not be empty'		
			INSERT INTO Errorlog VALUES (19,@Tabname,'Status',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@Status))='Active' OR LTRIM(RTRIM(@Status))='Inactive'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Status Type '+@Status+ ' is not available'		
				INSERT INTO Errorlog VALUES (20,@Tabname,'Status',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@Taxable))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Taxable should not be empty'		
			INSERT INTO Errorlog VALUES (21,@Tabname,'Taxable',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@Taxable))='Yes' OR LTRIM(RTRIM(@Taxable))='No'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END	
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Taxable Type '+@Taxable+ ' is not available'		
				INSERT INTO Errorlog VALUES (22,@Tabname,'Taxable',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@TaxType))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'TaxType should not be empty'		
			INSERT INTO Errorlog VALUES (23,@Tabname,'TaxType',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@TaxType))='VAT' OR LTRIM(RTRIM(@TaxType))='NON VAT'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END	
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'TaxType Type '+@TaxType+ ' is not available'		
				INSERT INTO Errorlog VALUES (24,@Tabname,'TaxType',@ErrDesc)
			END
		END
		IF @TaxType='VAT'
		BEGIN
			IF LTRIM(RTRIM(@TINNumber))=''
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'TIN Number should not be empty'		
				INSERT INTO Errorlog VALUES (25,@Tabname,'TINNumber',@ErrDesc)
			END
			ELSE
			BEGIN
				IF LEN(@TINNumber)>11
				BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'TIN Number Maximum Length should be 11'		
					INSERT INTO Errorlog VALUES (26,@Tabname,'TINNumber',@ErrDesc)
				END
			END
		END
		IF LTRIM(RTRIM(@CreditBills))<>''
		BEGIN
			IF ISNUMERIC(@CreditBills)=0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Credit Bills value Should be Number'		
				INSERT INTO Errorlog VALUES (27,@Tabname,'CreditBills',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@CreditLimit))<>''
		BEGIN
			IF ISNUMERIC(@CreditLimit)=0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Credit Limit value Should be Number'		
				INSERT INTO Errorlog VALUES (28,@Tabname,'CreditLimit',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@CreditDays))<>''
		BEGIN
			IF ISNUMERIC(@CreditDays)=0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Credit Days value Should be Number'		
				INSERT INTO Errorlog VALUES (29,@Tabname,'CreditDays',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@CashDiscountPercentage))<>''
		BEGIN
			IF ISNUMERIC(@CashDiscountPercentage)=0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Cash Discount Percentage value Should be Number'		
				INSERT INTO Errorlog VALUES (30,@Tabname,'CashDiscountPercentage',@ErrDesc)
			END
		END
		
		IF LTRIM(RTRIM(@CashDiscountPercentage))<>''
		BEGIN
			IF ISNUMERIC(@CashDiscountPercentage)=0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Cash Discount Percentage value Should be Number'		
				INSERT INTO Errorlog VALUES (31,@Tabname,'CashDiscountPercentage',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@CashDiscountCondition))<>''
		BEGIN
			IF LTRIM(RTRIM(@CashDiscountCondition))='>=' OR LTRIM(RTRIM(@CashDiscountCondition))='<='
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END	
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Cash Discount Condition Type '+@CashDiscountCondition+ ' is not available'		
				INSERT INTO Errorlog VALUES (32,@Tabname,'CashDiscountCondition',@ErrDesc)
			END
		END
			
	
		IF LTRIM(RTRIM(@CashDiscountLimitValue))<>''
		BEGIN
			IF ISNUMERIC(@CashDiscountLimitValue)=0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Cash Discount Limit Value value Should be Number'		
				INSERT INTO Errorlog VALUES (33,@Tabname,'CashDiscountLimitValue',@ErrDesc)
			END
		END
		
		IF LTRIM(RTRIM(@LicenseNumber))<>''
		BEGIN
			IF LTRIM(RTRIM(@LicNumberExDate))=''
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'License Number Expiry Date  should not be empty'		
				INSERT INTO Errorlog VALUES (34,@Tabname,'LicenseNumberExpiryDate',@ErrDesc)
			END
			ELSE
			BEGIN
				IF ISDATE(CONVERT(NVARCHAR(10),@LicNumberExDate,121))=0
				BEGIN
					SET @Po_ErrNo=1		
					SET @Taction=0
					SET @ErrDesc = 'License Number Expiry Date '+@LicNumberExDate+ 'not in date format'		
					INSERT INTO Errorlog VALUES (35,@Tabname,'LicenseNumberExpiryDate',@ErrDesc)
				END
				ELSE
				BEGIN
					IF  (CONVERT(NVARCHAR(10),@LicNumberExDate,121)) < CONVERT(NVARCHAR(10),GETDATE(),121)
					BEGIN
						SET @Po_ErrNo=1		
						SET @Taction=0
						SET @ErrDesc = 'Invalid License Number Expiry Date'		
						INSERT INTO Errorlog VALUES (36,@Tabname,'LicenseNumberExpiryDate',@ErrDesc)
					END
				END
			END
		END
		IF LTRIM(RTRIM(@DrugLicNumber))<>''
		BEGIN
			IF LTRIM(RTRIM(@DrugLicExDate))=''
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Drug License Number Expiry Date  should not be empty'		
				INSERT INTO Errorlog VALUES (37,@Tabname,'DrugLicenseNumberExpiryDate',@ErrDesc)
			END
			ELSE
			BEGIN
				IF ISDATE(CONVERT(NVARCHAR(10),@DrugLicExDate,121))=0
				BEGIN
					SET @Po_ErrNo=1		
					SET @Taction=0
					SET @ErrDesc = 'Drug License Number Expiry Date '+@DrugLicExDate+ 'not in date format'		
					INSERT INTO Errorlog VALUES (38,@Tabname,'DrugLicenseNumberExpiryDate',@ErrDesc)
				END
				ELSE
				BEGIN
					IF (CONVERT(NVARCHAR(10),@DrugLicExDate,121))< CONVERT(NVARCHAR(10),GETDATE(),121)
					BEGIN
						SET @Po_ErrNo=1		
						SET @Taction=0
						SET @ErrDesc = 'Invalid Drug License Number Expiry Date'		
						INSERT INTO Errorlog VALUES (39,@Tabname,'DrugLicenseNumberExpiryDate',@ErrDesc)
					END
				END
			END
		END
		IF LTRIM(RTRIM(@PestLicNumber))<>''
		BEGIN
			IF LTRIM(RTRIM(@PestLicExDate))=''
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Pesticide License Number Expiry Date  was not given'		
				INSERT INTO Errorlog VALUES (40,@Tabname,'PesticideLicenseNumberExpiryDate',@ErrDesc)
			END
			ELSE
			BEGIN
				IF ISDATE(CONVERT(NVARCHAR(10),@PestLicExDate,121))=0
					BEGIN
						SET @Po_ErrNo=1		
						SET @Taction=0
						SET @ErrDesc = 'Pesticide License Number Expiry Date '+@PestLicExDate+ 'not in date format'		
						INSERT INTO Errorlog VALUES (41,@Tabname,'PesticideLicenseNumberExpiryDate',@ErrDesc)
					END
				ELSE
				BEGIN
					IF (CONVERT(NVARCHAR(10),@PestLicExDate,121)) < CONVERT(NVARCHAR(10),GETDATE(),121)
					BEGIN
						SET @Po_ErrNo=1		
						SET @Taction=0
						SET @ErrDesc = 'Invalid Pesticide License Number Expiry Date '		
						INSERT INTO Errorlog VALUES (42,@Tabname,'PesticideLicenseNumberExpiryDate',@ErrDesc)
					END
				END
			END
		END
		IF LTRIM(RTRIM(@RetailerType))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Retailer Type should not be empty'		
			INSERT INTO Errorlog VALUES (43,@Tabname,'Retailer Type',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@RetailerType))='Retailer' OR LTRIM(RTRIM(@RetailerType))='Sub Stockist'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Retailer Type '+@RetailerType+ ' is not available'		
				INSERT INTO Errorlog VALUES (44,@Tabname,'Retailer Type',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@RetailerFrequency))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Retailer Frequency should not be empty'		
			INSERT INTO Errorlog VALUES (45,@Tabname,'Retailer Frequency',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@RetailerFrequency))='Weekly' OR LTRIM(RTRIM(@RetailerFrequency))='Bi-Weekly' OR LTRIM(RTRIM(@RetailerFrequency))='Fort Nightly' OR LTRIM(RTRIM(@RetailerFrequency))='Monthly' OR LTRIM(RTRIM(@RetailerFrequency))='Daily'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Retailer Frequency '+@RetailerFrequency+ ' is not available'		
				INSERT INTO Errorlog VALUES (46,@Tabname,'Retailer Frequency',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@RtrCrDaysAlert))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Credit Days Alert should not be empty'		
			INSERT INTO Errorlog VALUES (47,@Tabname,'Credit Days Alert',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@RtrCrDaysAlert))='None' OR LTRIM(RTRIM(@RtrCrDaysAlert))='Alert & Allow' OR LTRIM(RTRIM(@RtrCrDaysAlert))='Alert & Stop'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Credit Days Alert '+@RtrCrDaysAlert+ ' is not available'		
				INSERT INTO Errorlog VALUES (48,@Tabname,'Credit Days Alert',@ErrDesc)
			END
		END
		
		IF LTRIM(RTRIM(@RtrCrBillAlert))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Credit Bills Alert should not be empty'		
			INSERT INTO Errorlog VALUES (49,@Tabname,'Credit Bills Alert',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@RtrCrBillAlert))='None' OR LTRIM(RTRIM(@RtrCrBillAlert))='Alert & Allow' OR LTRIM(RTRIM(@RtrCrBillAlert))='Alert & Stop'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Credit Days Alert '+@RtrCrBillAlert+ ' is not available'		
				INSERT INTO Errorlog VALUES (50,@Tabname,'Credit Bills Alert',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@RtrCrLimitAlert))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Credit Limit Alert should not be empty'		
			INSERT INTO Errorlog VALUES (51,@Tabname,'Credit Days Alert',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@RtrCrLimitAlert))='None' OR LTRIM(RTRIM(@RtrCrLimitAlert))='Alert & Allow' OR LTRIM(RTRIM(@RtrCrLimitAlert))='Alert & Stop'
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					SET @Po_ErrNo=0	
				END
			END
			ELSE
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Credit Limit Alert '+@RtrCrLimitAlert+ ' is not available'		
				INSERT INTO Errorlog VALUES (52,@Tabname,'Credit Limit Alert',@ErrDesc)
			END
		END
		SET @CmpRtrCode=''
		SELECT @RtrId=dbo.Fn_GetPrimaryKeyInteger(@CntTabname,@FldName,CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
		SELECT @CoaId=dbo.Fn_GetPrimaryKeyInteger('CoaMaster','CoaId',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
		SELECT @AcCode=AcCode+1 FROM COAMaster WHERE CoaId=(SELECT MAX(A.CoaId) FROM COAMaster A Where A.MainGroup=2 and A.AcCode LIKE '216%')	
		IF (SELECT Status FROM Configuration WHERE ModuleId='RET33' AND ModuleName='Retailer')=1
		BEGIN			
			IF NOT EXISTS(SELECT * FROM Retailer)
			BEGIN
				UPDATE CompanyCounters SET CurrValue = 0 WHERE Tabname =  'Retailer' AND Fldname = 'CmpRtrCode'	
			END
			SELECT @CmpRtrCode=dbo.Fn_GetPrimaryKeyCmpString('Retailer','CmpRtrCode',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))			
		END
		ELSE
		BEGIN
			SET @CmpRtrCode=@RetailerCode
		END
		IF @CmpRtrCode=''
		BEGIN
			SET @Po_ErrNo=1		
			SET @Taction=0
			SET @ErrDesc = 'Company Retailer Code should not be empty'		
			INSERT INTO Errorlog VALUES (43,@Tabname,'Counter Value',@ErrDesc)
		END
		IF @RtrId=0
		BEGIN
			SET @Po_ErrNo=1		
			SET @Taction=0
			SET @ErrDesc = 'Reset the Counter Year Value '		
			INSERT INTO Errorlog VALUES (43,@Tabname,'Counter Value',@ErrDesc)
		END
		IF EXISTS (SELECT '*' FROM Configuration WHERE ModuleId = 'GENCONFIG30' AND ModuleName = 'General Configuration' AND Status = 1)
		BEGIN
			IF LTRIM(RTRIM(@PhoneNo))=''
			BEGIN
				IF EXISTS (SELECT RtrPhoneNo from Retailer (Nolock) where RtrPhoneNo = @PhoneNo AND RtrId NOT IN (@RetailerCode))
				BEGIN
					SET @Po_ErrNo=1		
					SET @Taction=0
					SET @ErrDesc = 'Retailer Phone Number not be Empty '		
					INSERT INTO Errorlog VALUES (43,@Tabname,'Phone Number',@ErrDesc)
				END
			END			
		END
		
		IF LTRIM(RTRIM(@PhoneNo))<>''
		BEGIN
			IF EXISTS (SELECT RtrPhoneNo from Retailer (Nolock) where RtrPhoneNo = @PhoneNo AND RtrId NOT IN (@RetailerCode))
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Retailer Phone Number should be unique '		
				INSERT INTO Errorlog VALUES (43,@Tabname,'Phone Number',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@TINNumber))<>''
		BEGIN
			IF EXISTS (SELECT RtrTINNo from Retailer (Nolock) where RtrTINNo = @TINNumber AND RtrId NOT IN (@RetailerCode))
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Retailer Tin Number Should be unique '		
				INSERT INTO Errorlog VALUES (43,@Tabname,'TiN Number',@ErrDesc)
			END
		END				
		IF  @Taction=1 AND @Po_ErrNo=0
		BEGIN	
			INSERT INTO Retailer(RtrId,RtrCode,CmpRtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrKeyAcc,RtrCovMode,
			RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,RtrCSTNo,TaxGroupId,RtrCrBills,RtrCrLimit,RtrCrDays,
			RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,
			RtrPestLicNo,RtrPestExpiryDate,GeoMainId,RMId,VillageId,RtrResPhone1,RtrOffPhone1,RtrDepositAmt,RtrAnniversary,RtrDOB,CoaId,RtrOnAcc,
			RtrShipId,RtrType,RtrFrequency,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert,Upload,Approved,XmlUpload,
			Availability,LastModBy,LastModDate,AuthId,AuthDate,RtrUniqueCode)--Gopi at 08/11/2016
			VALUES(@RtrId,@RetailerCode,@CmpRtrCode,@RetailerName,@Address1,@Address2,@Address3,CAST(@PinCode AS INT),@PhoneNo,@EmailId,
			(CASE @KeyAccount WHEN 'Yes' THEN 1 ELSE 0 END),
			(CASE @CoverageMode WHEN 'Order Booking' THEN 1 WHEN 'Counter Sales' THEN 2 WHEN 'Van Sales' THEN 3 END),
			@RegistrationDate,
			(CASE @DayOff WHEN 'Sunday' THEN 0 WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3 WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 END),
			(CASE @Status WHEN 'Active' THEN 1 ELSE 0 END),
			(CASE @Taxable WHEN 'Yes' THEN 1 ELSE 0 END),
			(CASE @TaxType WHEN 'VAT' THEN 0 ELSE 1 END),@TINNumber,@CSTNumber,@TaxGroupId,CAST(@CreditBills AS INT),CAST(@CreditLimit AS NUMERIC(18,2)),CAST(@CreditDays AS INT),
			(CAST(@CashDiscountPercentage AS NUMERIC(18,2))),(CASE @CashDiscountCondition WHEN '>=' THEN 1 ELSE 0 END),CAST(@CashDiscountLimitValue AS NUMERIC (18,2)),
			@LicenseNumber,CONVERT(NVARCHAR(10),@LicNumberExDate,121),@DrugLicNumber,CONVERT(NVARCHAR(10),@DrugLicExDate,121),
			@PestLicNumber,CONVERT(NVARCHAR(10),@PestLicExDate,121),@GeoMainId,@RMId,@VillageId,@ResidencePhoneNo,@OfficePhoneNo,
			CAST(@DepositAmount AS NUMERIC(18,2)),CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(10),GETDATE(),121),@CoaId,0,0,
			(CASE @RetailerType WHEN 'Retailer' THEN 1 WHEN 'Sub Stockist' THEN 2 END),
			(CASE @RetailerFrequency WHEN 'Weekly' THEN 0 WHEN 'Bi-Weekly' THEN 1 WHEN 'Fort Nightly' THEN 2 WHEN 'Monthly' THEN 3 WHEN 'Daily' THEN 4 END),
			(CASE @RtrCrDaysAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END),
			(CASE @RtrCrBillAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END),
			(CASE @RtrCrLimitAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END),
			'N',0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')
			UPDATE CompanyCounters SET CurrValue = CurrValue+1 WHERE Tabname =  'Retailer' AND Fldname = 'CmpRtrCode'
			SET @sSql='UPDATE CompanyCounters SET CurrValue =CurrValue'+'+1'+' WHERE Tabname =''Retailer'' AND Fldname =''CmpRtrCode'''
			INSERT INTO Translog(strSql1) VALUES (@sSql) 
			SET @sSql='INSERT INTO Retailer(RtrId,RtrCode,CmpRtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrKeyAcc,RtrCovMode,
			RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,RtrCSTNo,TaxGroupId,RtrCrBills,RtrCrLimit,RtrCrDays,RtrCashDiscPerc,
			RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrDrugLicNo,RtrPestLicNo,GeoMainId,RMId,VillageId,RtrResPhone1,RtrOffPhone1,RtrDepositAmt,RtrAnniversary,RtrDOB,CoaId,RtrOnAcc,
			RtrShipId,RtrType,RtrFrequency,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert,Upload,XmlUpload,Availability,LastModBy,LastModDate,AuthId,AuthDate,RtrLicExpiryDate,RtrDrugExpiryDate,RtrPestExpiryDate,Approved)
			VALUES('+CAST(@RtrId AS VARCHAR(10))+','''+@RetailerCode+''','''+@CmpRtrCode+''','''+@RetailerName+''','''+@Address1+''','''+@Address2+''','''+@Address3+''','+CAST(CAST(@PinCode AS INT)AS VARCHAR(10))+','''+@PhoneNo+''','''+@EmailId+''',
			'+CAST((CASE @KeyAccount WHEN 'Yes' THEN 1 ELSE 0 END)AS VARCHAR(10))+',
			'+CAST((CASE @CoverageMode WHEN 'Order Booking' THEN 1 WHEN 'Counter Sales' THEN 2 WHEN 'Van Sales' THEN 3 END)AS VARCHAR(10))+',
			'''+CAST(@RegistrationDate AS VARCHAR(12))+''',
			'+CAST((CASE @DayOff WHEN 'Sunday' THEN 0 WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3 WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 END)AS VARCHAR(10))+',
			'+CAST((CASE @Status WHEN 'Active' THEN 1 ELSE 0 END)AS VARCHAR(10))+',
			'+CAST((CASE @Taxable WHEN 'Yes' THEN 1 ELSE 0 END)AS VARCHAR(10))+',
			'+CAST((CASE @TaxType WHEN 'VAT' THEN 0 ELSE 1 END)AS VARCHAR(10))+','''+@TINNumber+''','''+@CSTNumber+''','+CAST(@TaxGroupId AS VARCHAR(10))+','+CAST(CAST(@CreditBills AS INT) AS VARCHAR(10))+','+CAST(CAST(@CreditLimit AS NUMERIC(18,2)) AS VARCHAR(20))+','+CAST(CAST(@CreditDays AS INT) AS VARCHAR(10))+',
			'+CAST((CAST(@CashDiscountPercentage AS NUMERIC(18,2)))AS VARCHAR(20))+','+CAST((CASE @CashDiscountCondition WHEN '>=' THEN 1 ELSE 0 END)AS VARCHAR(10))+','+CAST(CAST(@CashDiscountLimitValue AS NUMERIC (18,2))AS VARCHAR(20))+',
			'''+@LicenseNumber+''','''+@DrugLicNumber+''',
			'''+@PestLicNumber+''','+CAST(@GeoMainId AS VARCHAR(10))+','+CAST(@RMId AS VARCHAR(10))+','+CAST(@VillageId AS VARCHAR(10))+','''+@ResidencePhoneNo+''','''+@OfficePhoneNo+''',
			'+CAST(CAST(@DepositAmount AS NUMERIC(18,2))AS VARCHAR(20))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''','+CAST(@CoaId AS VARCHAR(10))+',0,0
			,'+CAST((CASE @RetailerType WHEN 'Retailer' THEN 1 WHEN 'Sub Stockist' THEN 2 END) AS VARCHAR(10))+'
			,'+CAST((CASE @RetailerFrequency WHEN 'Weekly' THEN 0 WHEN 'Bi-Weekly' THEN 1 WHEN 'Fort Nightly' THEN 2 WHEN 'Monthly' THEN 3 WHEN 'Daily' THEN 4 END) AS VARCHAR(10))+'
			,'+CAST((CASE @RtrCrDaysAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END) AS VARCHAR(10))+'
			,'+CAST((CASE @RtrCrBillAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END) AS VARCHAR(10))+'
			,'+CAST((CASE @RtrCrLimitAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END)AS VARCHAR(10))+'
			,''N'',0,0,1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',0'
			
			IF LTRIM(RTRIM(@LicNumberExDate)) IS NULL
			BEGIN
				SET @sSql=@sSql + ',Null'
			END
			ELSE
			BEGIN
				SET @sSql=@sSql + ','''+CONVERT(NVARCHAR(10),@LicNumberExDate,121)+''''
			END
			IF LTRIM(RTRIM(@DrugLicExDate))IS NULL
			BEGIN
				SET @sSql=@sSql + ',Null'
			END
			ELSE
			BEGIN
				SET @sSql=@sSql + ','''+CONVERT(NVARCHAR(10),@DrugLicExDate,121)+''''
			END
			IF LTRIM(RTRIM(@PestLicExDate))IS NULL
			BEGIN
				SET @sSql=@sSql + ',Null)'
			END
			ELSE
			BEGIN
				SET @sSql=@sSql + ','''+CONVERT(NVARCHAR(10),@PestLicExDate,121)+''')'
			END
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  @CntTabname AND Fldname = @FldName
			SET @sSql='UPDATE Counters SET CurrValue =CurrValue'+'+1'+' WHERE Tabname ='''+@CntTabname+''' AND Fldname ='''+@FldName+''''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			IF EXISTS (SELECT * FROM Retailer WHERE RtrId=@RtrId)
			BEGIN
				INSERT INTO CoaMaster (CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES (@CoaId,@AcCode,@RetailerName,4,2,2,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
				SET @sSql='INSERT INTO CoaMaster (CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES ('+CAST(@CoaId AS VARCHAR(10))+','''+@AcCode+''','''+@RetailerName+''',4,2,2,1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				
				IF @PotentialClassCode<>''
				BEGIN
					DELETE FROM RetailerPotentialClassMap WHERE RtrId=@RtrId
					SET @sSql='DELETE FROM RetailerPotentialClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+''
					INSERT INTO RetailerPotentialClassMap (RtrId,RtrPotentialClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES(@RtrId,@RtrClassId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
					SET @sSql='INSERT INTO RetailerPotentialClassMap (RtrId,RtrPotentialClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RtrClassId AS VARCHAR(10))+',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				END
				UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CoaMaster' AND Fldname = 'CoaId'
				SET @sSql='UPDATE Counters SET CurrValue =CurrValue'+'+1'+' WHERE Tabname =  ''CoaMaster'' AND Fldname = ''CoaId'''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END			
		END
		IF  @Taction=2 AND @Po_ErrNo=0
		BEGIN
			UPDATE Retailer SET  RtrName=@RetailerName,RtrAdd1=@Address1,RtrAdd2=@Address2,RtrAdd3=@Address3,
			RtrPinNo=CAST (@PinCode AS INT),RtrPhoneNo=@PhoneNo,
			RtrEmailId=@EmailId,
			RtrKeyAcc=(CASE @KeyAccount WHEN 'Yes' THEN 1 ELSE 0 END),
			RtrCovMode=(CASE @CoverageMode WHEN 'Order Booking' THEN 1 WHEN 'Counter Sales' THEN 2 WHEN 'Van Sales' THEN 3 END)
			,RtrRegDate=CONVERT(NVARCHAR(10),@RegistrationDate,121),
			RtrDayOff=(CASE @DayOff WHEN 'Sunday' THEN 0 WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3 WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 END),
			RtrStatus=(CASE @Status WHEN 'Active' THEN 1 ELSE 0 END),
			RtrTaxable=(CASE @Taxable WHEN 'Yes' THEN 1 ELSE 0 END),
			RtrTaxType=(CASE @TaxType WHEN 'VAT' THEN 0 ELSE 1 END),
			RtrTINNo=@TINNumber,
			RtrCSTNo=@CSTNumber,TaxGroupId=@TaxGroupId,RtrCrBills=CAST(@CreditBills AS INT),RtrCrLimit=CAST(@CreditLimit AS NUMERIC(18,2)),RtrCrDays=CAST(@CreditDays AS INT),
			RtrCashDiscPerc=CAST(@CashDiscountPercentage AS NUMERIC(18,2)),
			RtrCashDiscCond=(CASE @CashDiscountCondition WHEN '>=' THEN 1 ELSE 0 END),RtrCashDiscAmt=CAST(@CashDiscountLimitValue AS NUMERIC(18,2)),
			RtrLicNo=@LicenseNumber,RtrLicExpiryDate=CONVERT(NVARCHAR(10),@LicNumberExDate,121),RtrDrugLicNo=@DrugLicNumber,
			RtrDrugExpiryDate=CONVERT(NVARCHAR(10),@DrugLicExDate,121),RtrPestLicNo=@PestLicNumber,
			RtrPestExpiryDate=CONVERT(NVARCHAR(10),@PestLicExDate,121),GeoMainId=@GeoMainId,
			RMId=@RMId,VillageId=@VillageId,RtrResPhone1=@ResidencePhoneNo,RtrOffPhone1=@OfficePhoneNo,RtrDepositAmt=CAST(@DepositAmount AS NUMERIC(18,2)), 
			RtrType=(CASE @RetailerType WHEN 'Retailer' THEN 1 WHEN 'Sub Stockist' THEN 2 END),
			RtrFrequency=(CASE @RetailerFrequency WHEN 'Weekly' THEN 0 WHEN 'Bi-Weekly' THEN 1 WHEN 'Fort Nightly' THEN 2 WHEN 'Monthly' THEN 3 WHEN 'Daily' THEN 4 END),
			RtrCrDaysAlert=(CASE @RtrCrDaysAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END),
			RtrCrBillsAlert=(CASE @RtrCrBillAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END),
			RtrCrLimitAlert=(CASE @RtrCrLimitAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END)
			WHERE RtrCode=@RetailerCode
			SET @sSql='UPDATE Retailer SET  RtrName='''+@RetailerName+''',RtrAdd1='''+@Address1+''',RtrAdd2='''+@Address2+''',RtrAdd3='''+@Address3+''',
			RtrPinNo='+CAST(CAST(@PinCode AS INT) AS VARCHAR(20))+',RtrPhoneNo='''+@PhoneNo+''',
			RtrEmailId='''+@EmailId+''',
			RtrKeyAcc='+CAST((CASE @KeyAccount WHEN 'Yes' THEN 1 ELSE 0 END)AS VARCHAR(10))+',
			RtrCovMode='+CAST((CASE @CoverageMode WHEN 'Order Booking' THEN 1 WHEN 'Counter Sales' THEN 2 WHEN 'Van Sales' THEN 3 END)AS VARCHAR(10))+'
			,RtrRegDate='''+CONVERT(NVARCHAR(10),@RegistrationDate,121)+''',
			RtrDayOff='+CAST((CASE @DayOff WHEN 'Sunday' THEN 0 WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3 WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 END)AS VARCHAR(10))+',
			RtrStatus='+CAST((CASE @Status WHEN 'Active' THEN 1 ELSE 0 END)AS VARCHAR(10))+',
			RtrTaxable='+CAST((CASE @Taxable WHEN 'Yes' THEN 1 ELSE 0 END)AS VARCHAR(10))+',
			RtrTaxType='+CAST((CASE @TaxType WHEN 'VAT' THEN 0 ELSE 1 END)AS VARCHAR(10))+',
			RtrTINNo='''+@TINNumber+''',
			RtrCSTNo='''+@CSTNumber+''',TaxGroupId='+CAST(@TaxGroupId AS VARCHAR(10))+',RtrCrBills='+CAST(CAST(@CreditBills AS INT) AS VARCHAR(10))+',RtrCrLimit='+CAST(CAST(@CreditLimit AS NUMERIC(18,2)) AS VARCHAR(20))+',RtrCrDays='+CAST(CAST(@CreditDays AS INT) AS VARCHAR(10))+',
			RtrCashDiscPerc='+CAST(CAST(@CashDiscountPercentage AS NUMERIC(18,2)) AS VARCHAR(20))+',
			RtrCashDiscCond='+CAST((CASE @CashDiscountCondition WHEN '>=' THEN 1 ELSE 0 END)AS VARCHAR(10))+',RtrCashDiscAmt='+CAST(CAST(@CashDiscountLimitValue AS NUMERIC(18,2)) AS VARCHAR(20))+',
			RtrLicNo='''+@LicenseNumber+''',RtrDrugLicNo='''+@DrugLicNumber+''',RtrPestLicNo='''+@PestLicNumber+''',GeoMainId='+CAST(@GeoMainId AS VARCHAR(10))+',
			RMId='+CAST(@RMId AS VARCHAR(20))+',VillageId='+CAST(@VillageId AS VARCHAR(20))+',RtrResPhone1='''+@ResidencePhoneNo+''',RtrOffPhone1='''+@OfficePhoneNo+''',RtrDepositAmt='+CAST(CAST(@DepositAmount AS NUMERIC(18,2)) AS VARCHAR(20))+''
					
			IF LTRIM(RTRIM(@LicNumberExDate)) IS NULL
			BEGIN
				SET @sSql=@sSql + ',RtrLicExpiryDate=Null'
			END
			ELSE
			BEGIN
				SET @sSql=@sSql + ',RtrLicExpiryDate='''+CONVERT(NVARCHAR(10),@LicNumberExDate,121)+''''
			END
			IF LTRIM(RTRIM(@DrugLicExDate))IS NULL
			BEGIN
				SET @sSql=@sSql + ',RtrDrugExpiryDate=Null'
			END
			ELSE
			BEGIN
				SET @sSql=@sSql + ',RtrDrugExpiryDate='''+CONVERT(NVARCHAR(10),@DrugLicExDate,121)+''''
			END
			IF LTRIM(RTRIM(@PestLicExDate))IS NULL
			BEGIN
				SET @sSql=@sSql + ',RtrPestExpiryDate=Null'
			END
			ELSE
			BEGIN
				SET @sSql=@sSql + ',RtrPestExpiryDate='''+CONVERT(NVARCHAR(10),@PestLicExDate,121)+''''
			END
			SET @sSql=@sSql + ',RtrType='+CAST((CASE @RetailerType WHEN 'Retailer' THEN 1 WHEN 'Sub Stockist' THEN 2 END) AS VARCHAR(10))+'
			,RtrFrequency='+CAST((CASE @RetailerFrequency WHEN 'Weekly' THEN 0 WHEN 'Bi-Weekly' THEN 1 WHEN 'Fort Nightly' THEN 2 WHEN 'Monthly' THEN 3 WHEN 'Daily' THEN 4 END) AS VARCHAR(10))+'
			,RtrCrDaysAlert='+CAST((CASE @RtrCrDaysAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END) AS VARCHAR(10))+'
			,RtrCrBillsAlert='+CAST((CASE @RtrCrBillAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END) AS VARCHAR(10))+'
			,RtrCrLimitAlert='+CAST((CASE @RtrCrLimitAlert WHEN 'None' THEN 0 WHEN 'Alert & Allow' THEN 1 WHEN 'Alert & Stop' THEN 2 END)AS VARCHAR(10))+''
			SET @sSql=@sSql +' WHERE RtrCode='''+@RetailerCode+''''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			SELECT @CoaId=CoaId FROM Retailer WHERE RtrCode=@RetailerCode
			UPDATE CoaMAster SET AcName=@RetailerName WHERE CoaId=@CoaId
			SET @sSql='UPDATE CoaMaster SET AcName='''+@RetailerName+''' WHERE CoaId='+CAST(@CoaId AS VARCHAR(10))+''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			SELECT @RtrId=RtrId FROM Retailer WHERE RtrCode=@RetailerCode
			IF @PotentialClassCode<>''
			BEGIN
				DELETE FROM RetailerPotentialClassMap WHERE RtrId=@RtrId
				SET @sSql='DELETE FROM RetailerPotentialClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				INSERT INTO RetailerPotentialClassMap (RtrId,RtrPotentialClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@RtrId,@RtrClassId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
				SET @sSql='INSERT INTO RetailerPotentialClassMap (RtrId,RtrPotentialClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RtrClassId AS VARCHAR(10))+',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
		FETCH NEXT FROM Cur_Retailer INTO @RetailerCode,@RetailerName,@Address1,@Address2,@Address3,@PinCode,@PhoneNo,@EmailId,@KeyAccount,@CoverageMode,@RegistrationDate,@DayOff,
		@Status,@Taxable,@TaxType,@TINNumber,@CSTNumber,@TaxGroup,@CreditBills,@CreditLimit,@CreditDays,
		@CashDiscountPercentage,@CashDiscountCondition,@CashDiscountLimitValue,@LicenseNumber,
		@LicNumberExDate,@DrugLicNumber,@DrugLicExDate,@PestLicNumber,@PestLicExDate,@GeographyHierarchyValue,
		@DeliveryRoute,@VillageCode,@ResidencePhoneNo,@OfficePhoneNo,@DepositAmount,@PotentialClassCode,
		@RetailerType,@RetailerFrequency,@RtrCrDaysAlert,@RtrCrBillAlert,@RtrCrLimitAlert
	END
	CLOSE Cur_Retailer
	DEALLOCATE Cur_Retailer
	RETURN
END
GO
--Start
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_InstitutionsTargetSetting' and Xtype='P')
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
	
	--DECLARE @DistCode   As NVARCHAR(50)
	--DELETE FROM Cs2Cn_Prk_InstitutionsTargetSetting WHERE UploadFlag = 'Y'
	
	--SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)
	--SELECT InsId,H.InsRefNo,TargetMonth,TargetYear,Confirm,
	--CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01' FromDate,
	--DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01')) ToDate
	--INTO #InstitutionToBeUpload	
	--FROM InsTargetHD H (NOLOCK) WHERE H.Upload = 0 AND H.[Status] = 1
	--SELECT C.CtgMainId,C.CtgCode,R.RtrId,R.CmpRtrCode,D.AvgSal,D.[Target],D.Achievement,D.BaseAch,D.TargetAch,
	--D.ValBaseAch,D.ValTargetAch,D.ClmAmount,D.Liability,H.InsId,H.InsRefNo,H.FromDate,H.ToDate,H.Confirm
	--INTO #Institution
	--FROM #InstitutionToBeUpload H (NOLOCK)
	--INNER JOIN InsTargetDetails D (NOLOCK) ON H.InsId = D.InsId
	--INNER JOIN RetailerCategory C (NOLOCK) ON D.RtrCtgMainId = C.CtgMainId
	--INNER JOIN RetailerValueClass V (NOLOCK) ON C.CtgMainId = V.CtgMainId
	--INNER JOIN RetailerValueClassMap M (NOLOCK) ON V.RtrClassId = M.RtrValueClassId
	--INNER JOIN Retailer R (NOLOCK) ON M.RtrId = R.RtrId AND D.RtrId = R.RtrId
	--ORDER BY C.CtgName,R.RtrName
	
	--SELECT *
	--INTO #ConfirmInstitution
	--FROM #Institution I (NOLOCK) WHERE I.Confirm = 1
	
	--DELETE I FROM #Institution I (NOLOCK) WHERE I.Confirm = 1
	--SELECT S.InsId,S.RtrId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
	--INTO #SalesAsAchievement
	--FROM 
	--(
	--SELECT I.InsId,I.RtrId,SUM(S.SalGrossAmount) Sales FROM #Institution I (NOLOCK)
	--INNER JOIN SalesInvoice S (NOLOCK) ON I.RtrId = S.RtrId
	--WHERE S.SalInvDate BETWEEN I.FromDate AND I.ToDate AND S.DlvSts > 3
	--GROUP BY I.InsId,I.RtrId
	--UNION ALL
	--SELECT I.InsId,I.RtrId,-1 * SUM(R.RtnGrossAmt) FROM #Institution I (NOLOCK)
	--INNER JOIN ReturnHeader R (NOLOCK) ON I.RtrId = R.RtrId
	--WHERE R.ReturnDate BETWEEN I.FromDate AND I.ToDate AND R.Status = 0
	--GROUP BY I.InsId,I.RtrId
	--) AS S GROUP BY S.InsId,S.RtrId
	
	--UPDATE I SET I.Achievement = A.Sales -- IF NEGATIVE?
	--FROM #Institution I (NOLOCK),
	--#SalesAsAchievement A (NOLOCK)
	--WHERE I.InsId = A.InsId AND I.RtrId = A.RtrId
	--UPDATE I SET I.BaseAch = Achievement / AvgSal
	--FROM #Institution I (NOLOCK),
	--#SalesAsAchievement A (NOLOCK)
	--WHERE I.InsId = A.InsId AND I.RtrId = A.RtrId AND AvgSal <> 0
	--UPDATE I SET TargetAch = Achievement / [Target]
	--FROM #Institution I (NOLOCK),
	--#SalesAsAchievement A (NOLOCK)
	--WHERE I.InsId = A.InsId AND I.RtrId = A.RtrId AND [Target] <> 0
	--SELECT * 
	--INTO #InsTargetSlabDetails
	--FROM InsTargetSlabDetails S (NOLOCK) WHERE S.InsId IN (SELECT InsId FROM #Institution I (NOLOCK))
	
	--SELECT F.InsId,F.RtrId,F.SlabId,F.BaseSlab FromBase,ISNULL(T.BaseSlab,1000000000) - 0.01 ToBase,F.BasePerc,
	--F.TargetSlab FromTarget,ISNULL(T.TargetSlab,1000000000) - 0.01 ToTarget,F.TargetPerc
	--INTO #SlabDetails
	--FROM #InsTargetSlabDetails F (NOLOCK)
	--LEFT OUTER JOIN #InsTargetSlabDetails T (NOLOCK) ON F.SlabId  = T.SlabId - 1 AND F.RtrId = T.RtrId AND F.InsId = T.InsId
	
	--UPDATE I SET I.ValBaseAch = I.Achievement * (BasePerc / 100)
	--FROM #Institution I (NOLOCK),#SlabDetails S (NOLOCK)
	--WHERE I.InsId = S.InsId AND I.RtrId = S.RtrId AND I.Achievement BETWEEN FromBase AND ToBase
	--UPDATE I SET I.ValTargetAch = I.Achievement * (TargetPerc / 100)
	--FROM #Institution I (NOLOCK),#SlabDetails S (NOLOCK)
	--WHERE I.InsId = S.InsId AND I.RtrId = S.RtrId AND I.Achievement BETWEEN FromTarget AND ToTarget
	
	--UPDATE I SET I.ClmAmount = (I.ValBaseAch + I.ValTargetAch)
	--FROM #Institution I (NOLOCK)
	--UPDATE I SET I.Liability = I.ClmAmount / I.Achievement
	--FROM #Institution I (NOLOCK)
	--WHERE I.Achievement <> 0
	--UPDATE I SET 
	--I.AvgSal		= CAST(I.AvgSal AS NUMERIC(18,2)),
	--I.[Target]		= CAST(I.[Target] AS NUMERIC(18,2)),
	--I.Achievement	= CAST(I.Achievement AS NUMERIC(18,2)),
	--I.BaseAch		= CAST(I.BaseAch AS NUMERIC(18,2)),
	--I.TargetAch		= CAST(I.TargetAch AS NUMERIC(18,2)),
	--I.ValBaseAch	= CAST(I.ValBaseAch AS NUMERIC(18,2)),
	--I.ValTargetAch	= CAST(I.ValTargetAch AS NUMERIC(18,2)),
	--I.ClmAmount		= CAST(I.ClmAmount AS NUMERIC(18,2)),
	--I.Liability		= CAST(I.Liability AS NUMERIC(18,2))
	--FROM #Institution I (NOLOCK)
	--INSERT INTO Cs2Cn_Prk_InstitutionsTargetSetting (DistCode,ProgramCode,RtrGroup,RtrCode,AvgSales,TargetAmount,Achievement,
	--BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,UploadFlag,SyncId,ServerDate)
	
	--SELECT @DistCode,InsRefNo,CtgCode,CmpRtrCode,AvgSal,[Target],Achievement,
	--BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,'N',NULL,@ServerDate FROM #Institution
	--UNION ALL
	--SELECT @DistCode,InsRefNo,CtgCode,CmpRtrCode,AvgSal,[Target],Achievement,
	--BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,'N',NULL,@ServerDate FROM #ConfirmInstitution
	
	--UPDATE H SET H.Upload = 1
	--FROM InsTargetHD H (NOLOCK),
	--Cs2Cn_Prk_InstitutionsTargetSetting P (NOLOCK),
	--#ConfirmInstitution C (NOLOCK) 
	--WHERE H.InsRefNo = P.ProgramCode AND H.InsRefNo = C.InsRefNo
	
	RETURN			
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_RailwayDiscountReconsolidation' and XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_RailwayDiscountReconsolidation
GO
/*
Begin transaction
update SalesInvoice set RptUpload=0 where salinvdate>='2016-08-01'
EXEC Proc_Cs2Cn_RailwayDiscountReconsolidation 0,'2014-02-04'
exec Proc_Cs2Cn_ChainWiseBillDetails 0,'2014-02-04'
select * from Cs2Cn_Prk_RailwayDiscountReconsolidation order by slno
select * from Cs2Cn_Prk_ChainWiseBillDetails where billno='RET1612178'
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_ChainWiseBillDetails' and XTYPE='P')
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_MTChainSKUWise' and XTYPE='P')
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_MTDebitSummary' and XTYPE='P')
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_SchemeStockReconsolidation' and XTYPE='P')
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_DebitNoteTopSheet1' and XTYPE='P')
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_DebitNoteTopSheet2' and XTYPE='P')
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
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_Cs2Cn_DebitNoteTopSheet3' and XTYPE='P')
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
		DECLARE @Year	AS INT	
		DECLARE @Month  AS INT
		DECLARE @MonthName as Nvarchar(100)
		
		SELECT 	@TargetNo = InsId,@Year=TargetYear,@Month=TargetMonth FROM #InstitutionToBeUpload C (NOLOCK) WHERE SlNo = @RowNo
		
		SELECT @MonthName=MonthName FROM MonthDt (NOLOCK) WHERE MonthId=@Month
		
		--EXEC Proc_LoadingInstitutionsTarget @TargetNo,1
		
		EXEC Proc_LoadingInstitutionsTarget @Year,@Month,@MonthName,1
		
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
	
	RETURN			
END
GO
DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG30' AND ModuleName = 'General Configuration'
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES 
('GENCONFIG30','General Configuration','Retailer Phone Number As Mandatory',1,'',0.00,30)
GO
--From Updater
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_AutoBatchTransfer_Parle' AND XTYPE='P')
DROP PROCEDURE Proc_AutoBatchTransfer_Parle
GO
/*
BEGIN TRANSACTION
select *from stockledger a where prdid = 2058 and TransDate = (select MAX(TransDate) from StockLedger where PrdId = a.PrdId and PrdBatId = a.PrdBatId)
EXEC Proc_AutoBatchTransfer_Parle 0
select *from stockledger a where prdid = 2058 and TransDate = (select MAX(TransDate) from StockLedger where PrdId = a.PrdId and PrdBatId = a.PrdBatId)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_AutoBatchTransfer_Parle
(
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
	
	SET @Exist=0
	
	select PrdId,MAX(mnfdate)mnfdate into #MaxMnfdate from ProductBatch
	group by PrdId

	select B.PrdId,MAX(PrdBatId)PrdBatId INTO #MaxProductBatch from #MaxMnfdate A INNER JOIN ProductBatch B
	ON A.PrdId = B.PrdId AND A.mnfdate = B.MnfDate
	group by B.PrdId
	
	
	DECLARE Cur_ProductBatch CURSOR
	FOR 
	SELECT PrdId,MAX(PrdBatId) PrdBatId FROM #MaxProductBatch GROUP BY PrdId
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	WHILE @@FETCH_STATUS=0
	BEGIN
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
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	RETURN	
END
GO
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
	SELECT DISTINCT UpdatedHotfixId,'UpdaterLog' FROM Cs2Cn_Prk_SyncDetails	 A WHERE NOT EXISTS(SELECT * FROM Hotfixupdater_Bck B (NOLOCK) WHERE A.UpdatedHotfixid=B.Fixid AND B.FixType='UpdaterLog')
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' and NAME='Proc_CN2CS_ProductCodeUnification')
DROP PROCEDURE Proc_CN2CS_ProductCodeUnification
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_CN2CS_ProductCodeUnification 0
  SELECT * FROM Errorlog (NOLOCK)
  select * from ProductBatch (Nolock) where PrdId IN(3003,3004,3005)
  select * from ProductBatchDetails A (Nolock) INNER JOIN  ProductBatch B (Nolock) ON A.PrdBatId = B.PrdBatId where PrdId IN(3003,3004,3005)
  select * from ProductBatchLocation (Nolock) where PrdId IN(3003,3004,3005)
  SELECT * FROM CN2CS_Prk_ProductCodeUnification (NOLOCK) 
  ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CN2CS_ProductCodeUnification
(
       @Po_ErrNo INT OUTPUT
)
AS
/*****************************************************************************
* PROCEDURE      : Proc_CN2CS_ProductCodeUnification
* PURPOSE        : To Mapped the Sub Products to Main Products
* CREATED BY     : Sathishkumar Veeramani 18-11-2014
* MODIFIED       :
* DATE      AUTHOR     DESCRIPTION
* {DATE} {DEVELOPER}  {BRIEF MODIFICATION DESCRIPTION}
*******************************************************************************/
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo = 0
DECLARE @ToPrdId     AS NUMERIC(18,0)
DECLARE @PrdId       AS NUMERIC(18,0)
DECLARE @PrdBatId    AS NUMERIC(18,0)
DECLARE @ToPrdBatId  AS NUMERIC(18,0)
DECLARE @LcnId       AS BIGINT
DECLARE @SalTotQty   AS NUMERIC(18,0)
DECLARE @UnSalTotQty AS NUMERIC(18,0)
DECLARE @OfferTotQty AS NUMERIC(18,0)
DECLARE @SalQty      AS NUMERIC(18,0)
DECLARE @UnSalQty    AS NUMERIC(18,0)
DECLARE @OfferQty    AS NUMERIC(18,0)
DECLARE @InvDate     AS DATETIME

DECLARE @LcnIdCheck AS INT
DECLARE @Pi_ErrNo AS TINYINT
DECLARE @Pi_PrdbatLcn AS TINYINT
DECLARE @Pi_StkLedger AS TINYINT
DECLARE @MaxNo as INT
DECLARE @MinNo as INT
DECLARE @CurrValue AS BIGINT
DECLARE @StkKeyNumber AS VARCHAR(50)
DECLARE @iDecPoint AS INT
DECLARE @iRate AS Numeric(18,6)
DECLARE @UomId AS INT
DECLARE @SalPriceId AS BIGINT
DECLARE @StockTypeId AS INT

DECLARE @iReduceRate AS Numeric(18,6)
DECLARE @ReduceSalPriceId AS BIGINT
DECLARE @ReduceUomId AS INT

DELETE FROM CN2CS_Prk_ProductCodeUnification WHERE DownLoadFlag = 'Y'

	CREATE TABLE #ToAvoidProducts
	(
	  ProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
	  MapProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS
	)
	
	CREATE TABLE #Location
	(
		Slno INT IDENTITY (1,1),
		LcnId INT
	)	
	
	
	BEGIN TRY
			--Product Validations
			INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
			SELECT DISTINCT ProductCode,MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
			WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.ProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
			
			INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Product','PrdCCode',ProductCode+'-Product Or ProductBatch Not Available' 
			FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
			WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.ProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
			
			INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
			SELECT DISTINCT ProductCode,MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
			WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.MapProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
			
			INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Product','PrdCCode',MapProductCode+'-Product Code Not Available' 
			FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
			WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.MapProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
			
			--Main Product Code Unique Validation
			INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
			SELECT DISTINCT ProductCode,A.MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) INNER JOIN
			(SELECT COUNT(DISTINCT ProductCode) AS Counts,MapProductCode FROM CN2CS_Prk_ProductCodeUnification (NOLOCK)
			GROUP BY MapProductCode HAVING COUNT(DISTINCT ProductCode) > 1)B ON A.MapProductCode = B.MapProductCode
			WHERE DownLoadFlag = 'D'
			
			INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'CN2CS_Prk_ProductCodeUnification','ProductCode',ProductCode+'-Mapped More than One Products' 
			 FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) INNER JOIN
			(SELECT COUNT(DISTINCT ProductCode) AS Counts,MapProductCode FROM CN2CS_Prk_ProductCodeUnification (NOLOCK)
			GROUP BY MapProductCode HAVING COUNT(DISTINCT ProductCode) > 1)B ON A.MapProductCode = B.MapProductCode
			WHERE DownLoadFlag = 'D'
			
			--Unification Product Batch Creation
			--Parent Product & Child Product 
			SELECT DISTINCT B.PrdId AS PPrdId,B.TaxGroupId,C.PrdId AS CPrdId 
			INTO #ProductCodeUnification 
			FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK)
			INNER JOIN Product B (NOLOCK) ON A.ProductCode = B.PrdCCode
			INNER JOIN Product C (NOLOCK) ON A.MapProductCode = C.PrdCCode
			WHERE NOT EXISTS (SELECT DISTINCT ProductCode,MapProductCode FROM #ToAvoidProducts D WHERE A.ProductCode = D.ProductCode 
			AND A.MapProductCode = D.MapProductCode) 
			AND NOT EXISTS (SELECT DISTINCT PrdId FROM ProductBatch E (NOLOCK) WHERE B.PrdId = E.PrdId)
			AND DownLoadFlag = 'D' ORDER BY PPrdId,CPrdId ASC
			
			--Child Product Latest Batch
			SELECT DISTINCT PPrdId,TaxGroupId,MAX(CPrdBatId) AS CPrdBatId INTO #ProductBatch FROM (
			SELECT DISTINCT PPrdId,TaxGroupId,CPrdId,CPrdBatId FROM #ProductCodeUnification A INNER JOIN
			(SELECT PrdId,MAX(PrdBatId) AS CPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.CPrdId = B.PrdId)Qry
			GROUP BY PPrdId,TaxGroupId
			
			--Child Product Latest Batch Details
			SELECT PPrdId,TaxGroupId,CPrdBatId,CPriceId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue
			INTO #ProductBatchDetails 
			FROM #ProductBatch A INNER JOIN
			(
		    
				SELECT DISTINCT PrdBatId,MAX(PriceId) AS CPriceId FROM ProductBatchDetails (NOLOCK)  WHERE DefaultPrice=1 
				GROUP BY PrdBatId
		   
			)B ON A.CPrdBatId = B.PrdBatId
			INNER JOIN ProductBatchDetails C (NOLOCK) ON A.CPrdBatId = C.PrdBatId AND B.PrdBatId = C.PrdBatId AND B.CPriceId = C.PriceId
		   
		 
		    
			DECLARE @UPrdBatId AS NUMERIC(18,0)
			DECLARE @UPriceId  AS NUMERIC(18,0)
			SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
			SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
		    
			SELECT DISTINCT A.PPrdId,(DENSE_RANK()OVER (ORDER BY PPrdId ASC)+@UPrdBatId) AS PPrdBatId,A.TaxGroupId,PrdBatCode,
			CmpBatCode,MnfDate,ExpDate,BatchSeqId,DecPoints,EnableCloning,CPrdBatId INTO #ParentProductBatch 
			FROM #ProductBatch A INNER JOIN ProductBatch B (NOLOCK) ON A.CPrdBatId = B.PrdBatId 

			SELECT DISTINCT A.PPrdId,PPrdBatId,(DENSE_RANK()OVER(ORDER BY A.PPrdId,PPrdBatId ASC)+@UPriceId) AS PPriceId,
			PriceCode,B.BatchSeqId,SLNo,PrdBatDetailValue INTO #ParentProductBatchDetails 
			FROM #ParentProductBatch A INNER JOIN #ProductBatchDetails B ON A.PPrdId = B.PPrdId AND A.CPrdBatId = B.CPrdBatId
			
					
		    BEGIN TRANSACTION
						--To Insert Product Batch & ProductBatchDetails
						INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,[Status],TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,
						EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
						SELECT DISTINCT A.PPrdId,A.PPrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,1 AS [Status],TaxGroupId,A.BatchSeqId,DecPoints,
						PPriceId,EnableCloning,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
						FROM #ParentProductBatch A INNER JOIN #ParentProductBatchDetails B ON A.PPrdId = B.PPrdId AND A.PPrdBatId = B.PPrdBatId
						ORDER BY A.PPrdId,A.PPrdBatId,PPriceId
						
						INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
						SELECT PPriceId,PPrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
						CONVERT(NVARCHAR(10),GETDATE(),121),0 
						FROM #ParentProductBatchDetails ORDER BY PPriceId,PPrdBatId
					    
						--Current Stock Reports
						IF EXISTS (SELECT DISTINCT PPriceId FROM #ParentProductBatchDetails)
						BEGIN
							EXEC Proc_DefaultPriceHistory 0,0,@UPriceId,2,1
						END	
						--Till Here

						SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
						UPDATE Counters SET CurrValue = @UPrdBatId WHERE TabName = 'ProductBatch' AND FldName = 'PrdBatId'
						SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
						UPDATE Counters SET CurrValue = @UPriceId WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
						
						--Mapped Products Stock Posting
						SELECT DISTINCT D.PrdId AS ToPrdId,A.PrdId,PrdBatId,LcnId,(PrdBatLcnSih-PrdBatLcnRessih) AS SalStock,
						(PrdBatLcnUih-PrdBatLcnResUih) AS UnSalStock,(PrdBatLcnFre-PrdBatLcnResFre) AS OfferStock INTO #ProductBatchLocation
						FROM ProductBatchLocation A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId
						INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
						INNER JOIN Product D (NOLOCK) ON C.ProductCode = D.PrdCCode 
						WHERE (PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre) > 0 AND DownLoadFlag = 'D' AND
						NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
						    	
						SELECT DISTINCT ToPrdId,ToPrdBatId INTO #ParentProductLatestBatch FROM #ProductBatchLocation A INNER JOIN
						(SELECT DISTINCT PrdId,MAX(PrdBatId) AS ToPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.ToPrdId = B.PrdId
						ORDER BY ToPrdId
						
						SELECT DISTINCT A.ToPrdId,ToPrdBatId,PrdId,PrdBatId,LcnId,SalStock,UnSalStock,OfferStock INTO #ManualStockPosting
						FROM #ProductBatchLocation A INNER JOIN #ParentProductLatestBatch B ON A.ToPrdId = B.ToPrdId
						ORDER BY A.ToPrdId,ToPrdBatId,PrdId,PrdBatId
						
						
						
						INSERT INTO #Location(LcnId)
						SELECT DISTINCT  LcnId FROM #ManualStockPosting WHERE ISNULL(LcnId,0)>0
						
					
						
						SET @Pi_ErrNo=0
						SET @Pi_PrdbatLcn=0
						SET @Pi_StkLedger=0
						SET @LcnIdCheck=0
						SET @MinNo=1
								
								
								SELECT @MaxNo= Max(Slno) FROM  #Location
								
								WHILE @MinNo<=@MaxNo
								BEGIN
										
											
											SELECT @LcnIdCheck=LcnId FROM #Location WHERE Slno=@MinNo
											
											SET @StkKeyNumber=''
											SELECT @CurrValue= Currvalue+1 FROM Counters (NOLOCK) WHERE TabName='StockManagement' AND FldName='StkMngRefNo'

											SELECT @StkKeyNumber=PreFix+CAST(SUBSTRING(CAST(CurYear as Varchar(10)),3,LEN(CurYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(@CurrValue)>ZPad THEN (ZPad+1)-LEN(@CurrValue) ELSE (ZPad)-LEN(@CurrValue)END)+CAST(@CurrValue as Varchar(10)) 			
											FROM Counters (NOLOCK) WHERE TabName='StockManagement' AND FldName='StkMngRefNo'
											
											SET @iDecPoint=2
											SELECT @iDecPoint=ConfigValue FROM Configuration WHERE Description='Calculation Decimal Digit Value' AND ModuleName='General Configuration'
											
											UPDATE  Counters SET CurrValue= CurrValue+1 WHERE TabName='StockManagement' AND FldName='StkMngRefNo'
											
											IF (@LcnIdCheck<=0 OR LEN(LTRIM(RTRIM(@StkKeyNumber)))<=0)
											BEGIN
												SET @Po_ErrNo=1												
												RETURN
												
											END
										
											IF (@LcnIdCheck>0 and LEN(LTRIM(RTRIM(@StkKeyNumber)))>0 )
											BEGIN						
												
												INSERT INTO StockManagement(StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,DecPoints,
												OpenBal,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate,ConfigValue,XMLUpload)				
												SELECT @StkKeyNumber,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),@LcnIdCheck,0,0,0,'','Product Code Unification ',@iDecPoint,
												0,1,1,1,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),1,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),1,0
												
												
												DECLARE CUR_STOCKADJIN CURSOR
												FOR SELECT DISTINCT ToPrdId,ToPrdBatId,LcnId,PrdId,PrdBatId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
												SUM(UnSalStock) AS UnSalTotStock,SUM(OfferStock) AS OfferTotStock FROM #ManualStockPosting WITH (NOLOCK)
												WHERE  LcnId=@LcnIdCheck
												GROUP BY ToPrdId,ToPrdBatId,LcnId,PrdId,PrdBatId ORDER BY ToPrdId,ToPrdBatId
												OPEN CUR_STOCKADJIN		
												FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@PrdId,@PrdBatId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
												WHILE @@FETCH_STATUS = 0
												BEGIN	
												
														SET @SalPriceId=0
														SET @iRate=0.00
														SET @UomId=0
														SET @StockTypeId=0
														
														SET @iReduceRate=0.00
														SET @ReduceSalPriceId=0
														SET @ReduceUomId=0
														
														SELECT @SalPriceId=ISNULL(PriceId,0),@iRate=PrdBatDetailValue 
														FROM Product A INNER JOIN Productbatch PB (NOLOCK) ON A.Prdid=PB.Prdid
														INNER JOIN BatchCreation B (NOLOCK) ON PB.BatchSeqId=B.BatchSeqId 
														INNER JOIN Productbatchdetails PBD (NOLOCK) ON PBD.PrdbatId= PB.Prdbatid and PBD.Slno=B.Slno
														WHERE PB.PrdbatId= @ToPrdBatId and   DefaultPrice=1 and  ListPrice=1  and A.PrdId=@ToPrdId
														
														SELECT @UomId=UomId FROM Uomgroup U (NOLOCK) INNER JOIN Product P (NOLOCK) ON U.UomgroupId=P.UomGroupId
														WHERE Prdid=@ToPrdId and BaseUom='Y' 
														
														
														SELECT @ReduceSalPriceId=ISNULL(PriceId,0),@iReduceRate=PrdBatDetailValue 
														FROM Product A INNER JOIN Productbatch PB (NOLOCK) ON A.Prdid=PB.Prdid
														INNER JOIN BatchCreation B (NOLOCK) ON PB.BatchSeqId=B.BatchSeqId 
														INNER JOIN Productbatchdetails PBD (NOLOCK) ON PBD.PrdbatId= PB.Prdbatid and PBD.Slno=B.Slno
														WHERE PB.PrdbatId= @PrdBatId and   DefaultPrice=1 and  ListPrice=1
														and A.PrdId=@PrdId

														SELECT @ReduceUomId=UomId FROM Uomgroup U (NOLOCK) INNER JOIN Product P (NOLOCK) ON U.UomgroupId=P.UomGroupId
														WHERE Prdid=@PrdId and BaseUom='Y' 
												
														IF @SalTotQty > 0 
														BEGIN
															SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=1
																
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@SalTotQty,0,0,@SalTotQty,
															@iRate,@iRate*@SalTotQty,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
															
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0					
															--SALEABLE STOCK IN									
															EXEC Proc_UpdateStockLedger 10,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 1,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT		
															
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN												
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															
															--SALEABLE STOCK OUT																													
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@SalTotQty,0,0,@SalTotQty,
															@iReduceRate,@iReduceRate*@SalTotQty,0,@ReduceSalPriceId,1,111,@InvDate,1,@InvDate,0.00,2
															
													
															
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0	
															
															EXEC Proc_UpdateStockLedger 13,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 1,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT	
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																								
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															--TILL HERE
															
														END
														IF @UnSalTotQty > 0
														BEGIN
														
														
															SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=2
																
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@UnSalTotQty,0,0,@UnSalTotQty,
															@iRate,@iRate*@UnSalTotQty,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
															
															
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0	
														   --UNSALEABLE STOCK IN									
															EXEC Proc_UpdateStockLedger 11,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 2,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
																
															--UNSALEABLE STOCK OUT
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@UnSalTotQty,0,0,@UnSalTotQty,
															@iReduceRate,@iReduceRate*@UnSalTotQty,0,@ReduceSalPriceId,1,111,@InvDate,1,@InvDate,0.00,2
															
																														
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0	
															
															EXEC Proc_UpdateStockLedger 14,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 2,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															
															--Till HERE		
																
														END
														IF @OfferTotQty > 0 
														BEGIN
															
															SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=3
																
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@OfferTotQty,0,0,@OfferTotQty,
															0.00,0.00,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
															
														
															--OFFER STOCK IN
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0
																								
															EXEC Proc_UpdateStockLedger 12,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 3,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															
															--OFFER STOCK OUT
															
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@OfferTotQty,0,0,@OfferTotQty,
															0.00,0.00,0,0,1,111,@InvDate,1,@InvDate,0.00,2
															
															
															
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0
															
															EXEC Proc_UpdateStockLedger 15,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 3,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															
														END
														
														--SELECT 'X',* from ProductBatchLocation (NOLOCK) where PrdId=@ToPrdId and prdbatId=@ToPrdBatId and LcnId=@LcnId
														--SELECT 'Y',* from ProductBatchLocation (NOLOCK) where PrdId=@PrdId and prdbatId=@PrdBatId and LcnId=@LcnId
														--SELECT 'X',* from StockLedger (NOLOCK) where PrdId=@ToPrdId and prdbatId=@ToPrdBatId and LcnId=@LcnId and TransDate=@InvDate
														--SELECT 'Y',* from StockLedger (NOLOCK) where PrdId=@PrdId and prdbatId=@PrdBatId and LcnId=@LcnId and TransDate=@InvDate
																
												FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@PrdId,@PrdBatId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
												END
												CLOSE CUR_STOCKADJIN
												DEALLOCATE CUR_STOCKADJIN
												--Till Here
												
												
												
											END	
											
											
									SET @MinNo=@MinNo+1	
								END					
															
								
								
				
						
						---COMMENTED BY Murugan.R 05/07/2016,Reason Stock adjustment Transaction details not capture in previous version 427	
						--Main Product Stock Posting IN
						--DECLARE CUR_STOCKADJIN CURSOR
						--FOR SELECT DISTINCT ToPrdId,ToPrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
						--SUM(UnSalStock) AS UnSalTotStock,SUM(OfferStock) AS OfferTotStock FROM #ManualStockPosting WITH (NOLOCK) 
						--GROUP BY ToPrdId,ToPrdBatId,LcnId ORDER BY ToPrdId,ToPrdBatId
						--OPEN CUR_STOCKADJIN		
						--FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
						--WHILE @@FETCH_STATUS = 0
						--BEGIN	
						--        IF @SalTotQty > 0
						--        BEGIN
						--            --SALEABLE STOCK IN									
						--			EXEC Proc_UpdateStockLedger 10,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 1,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0		
						--		END
						--		IF @UnSalTotQty > 0
						--		BEGIN
						--		   --UNSALEABLE STOCK IN									
						--			EXEC Proc_UpdateStockLedger 11,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 2,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
						--		END
						--		IF @OfferTotQty > 0
						--		BEGIN
						--		    --OFFER STOCK IN									
						--			EXEC Proc_UpdateStockLedger 12,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 3,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
						--		END
										
						--FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
						--END
						--CLOSE CUR_STOCKADJIN
						--DEALLOCATE CUR_STOCKADJIN
						----Till Here
						
						----Mapped Product Stock Posting OUT
						--DECLARE CUR_STOCKADJOUT CURSOR
						--FOR SELECT DISTINCT PrdId,PrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalStock,
						--SUM(UnSalStock) AS UnSalStock,SUM(OfferStock) AS OfferStock FROM #ManualStockPosting WITH (NOLOCK) 
						--GROUP BY PrdId,PrdBatId,LcnId ORDER BY PrdId,PrdBatId
						--OPEN CUR_STOCKADJOUT		
						--FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
						--WHILE @@FETCH_STATUS = 0
						--BEGIN	
						--        IF @SalQty > 0
						--        BEGIN
						--			--SALEABLE STOCK OUT
						--			EXEC Proc_UpdateStockLedger 13,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 1,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0				
						--		END
						--		IF @UnSalQty > 0
						--		BEGIN
						--			--UNSALEABLE STOCK OUT
						--			EXEC Proc_UpdateStockLedger 14,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 2,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
						--		END
						--		IF @OfferQty > 0
						--		BEGIN
						--			--OFFER STOCK OUT
						--			EXEC Proc_UpdateStockLedger 15,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 3,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
						--		END
										
						--FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
						--END
						--CLOSE CUR_STOCKADJOUT
						--DEALLOCATE CUR_STOCKADJOUT	
						--Till Here
						---Till here Murugan.R
						
						SELECT DISTINCT A.PrdId,(SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih)) AS SalStock,(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih)) AS UnSalStock,
						(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) AS OfferStock INTO #FinalStockAvailable 
						FROM ProductBatchLocation A (NOLOCK) 
						INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId 
						INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
						WHERE NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
						GROUP BY A.PrdId
						HAVING (SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih))+(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih))+(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) > 0
						
						--Mapped Products and Product Batches are Inactivate Validation
						UPDATE A SET A.PrdCtgValMainId = C.PrdCtgValMainId FROM Product A (NOLOCK) 
						INNER JOIN CN2CS_Prk_ProductCodeUnification B (NOLOCK) ON A.PrdCCode = B.MapProductCode
						INNER JOIN Product C (NOLOCK) ON B.ProductCode = C.PrdCCode
						WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts C (NOLOCK)
						WHERE B.ProductCode = C.ProductCode AND B.MapProductCode = C.MapProductCode)
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable D WHERE A.PrdId = D.PrdId)
						
						UPDATE A SET A.[Status] = 0 FROM ProductBatch A (NOLOCK) INNER JOIN 
						(SELECT PrdId FROM Product B (NOLOCK) INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
						WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK)
						WHERE C.ProductCode = D.ProductCode AND C.MapProductCode = D.MapProductCode)) B ON A.PrdId = B.PrdId
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable E WHERE A.PrdId = E.PrdId) 
						
						UPDATE A SET A.[PrdStatus] = 0 FROM Product A (NOLOCK) INNER JOIN CN2CS_Prk_ProductCodeUnification B (NOLOCK) ON A.PrdCCode = B.MapProductCode
						WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts C (NOLOCK)
						WHERE B.ProductCode = C.ProductCode AND B.MapProductCode = C.MapProductCode)
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable D WHERE A.PrdId = D.PrdId) 
						--Till Here
						
						--Moorthi Start Here
						DECLARE @RefNo AS INT
						SELECT @RefNo=ISNULL(MAX(RefNo),0)+1 FROM ProductUnification_Track (NOLOCK)
						
						INSERT INTO ProductUnification_Track(RefNo,ProductCode,ProductName,MapProductCode,CreatedDate)
						SELECT @RefNo,A.ProductCode,A.ProductName,A.MapProductCode,GETDATE() FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
						INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
						NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
						AND A.MapProductCode = D.MapProductCode)	
						--Till Here	
						
						UPDATE A SET A.DownloadFlag = 'Y' FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
						INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
						NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
						AND A.MapProductCode = D.MapProductCode)
						

										
						COMMIT TRANSACTION	
						
	END TRY
	BEGIN CATCH
		SET @Po_ErrNo=1
		--select ERROR_MESSAGE()
		CLOSE CUR_STOCKADJIN
		DEALLOCATE CUR_STOCKADJIN		
		ROLLBACK TRAN	
	END CATCH    
	RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE name='View_CurrentStockReport' AND XTYPE='V')
DROP VIEW View_CurrentStockReport
GO
CREATE VIEW View_CurrentStockReport
/************************************************************
* VIEW	: View_CurrentStockReport
* PURPOSE	: To get the Current Stock of the Products with Batch details
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 26/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT LcnId,LcnName,PrdId,PrdDCode,Prdccode,PrdName,PrdBatId,PrdBatCode,sum(MRP)MRP,sum(SelRate)SelRate,sum(ListPrice)ListPrice,
	Saleable,SaleableWgt ,Unsaleable,UnsaleableWgt ,Offer,OfferWgt ,Total,sum(SalMRP)SalMRP,sum(UnSalMRP)UnSalMRP,sum(TotMRP)TotMRP,sum(SalSelRate)SalSelRate,
	sum(UnSalSelRate)UnSalSelRate,sum(TotSelRate)TotSelRate,sum(SalListPrice)SalListPrice,sum(UnSalListPrice)UnSalListPrice,
	sum(TotListPrice)TotListPrice,PrdStatus,Status,CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode
FROM (
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,PBDM.PrdBatDetailValue AS MRP,
		0 AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		(PrdBatLcnSih-PrdBatLcnResSih)* PBDM.PrdBatDetailValue  AS SalMRP,
		(PrdBatLcnUih-PrdBatLcnResUih)* PBDM.PrdBatDetailValue  AS UnSalMRP,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* PBDM.PrdBatDetailValue ) AS TotMRP,
		0 AS SalSelRate,
		0 AS UnSalSelRate,
		0 AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode--,TxRpt.UsrId
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		 ProductBatchDetails PBDM (NOLOCK),BatchCreation BCM (NOLOCK),
		 ProductBatchTaxPercent TxRpt (NOLOCK),
		 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId AND PrdBat.BatchSeqId=BCM.BatchSeqId
		AND BCM.MRP=1 AND BCM.SlNo=PBDM.SLNo AND PBDM.PrdBatId=PrdBat.PrdBatId  
		AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId 
		AND PrdBat.DefaultPriceId=PBDM.PriceId   
UNION ALL 
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
		PBDR.PrdBatDetailValue+((PBDR.PrdBatDetailValue*TxRpt.TaxPercentage)/100) AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		0 AS SalMRP,
		0 AS UnSalMRP,
		0 AS TotMRP,
		(PrdBatLcnSih-PrdBatLcnResSih)* (PBDR.PrdBatDetailValue+((PBDR.PrdBatDetailValue*TxRpt.TaxPercentage)/100))  AS SalSelRate,
		(PrdBatLcnUih-PrdBatLcnResUih)* (PBDR.PrdBatDetailValue+((PBDR.PrdBatDetailValue*TxRpt.TaxPercentage)/100))  AS UnSalSelRate,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (PBDR.PrdBatDetailValue+((PBDR.PrdBatDetailValue*TxRpt.TaxPercentage)/100)) ) AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode--,TxRpt.UsrId
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		ProductBatchDetails PBDR (NOLOCK),BatchCreation BCR (NOLOCK),
		ProductBatchTaxPercent TxRpt (NOLOCK),
		ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
		AND PrdBat.BatchSeqId=BCR.BatchSeqId
		AND BCR.SelRte=1 AND BCR.SlNo=PBDR.SLNo AND PBDR.PrdBatId=PrdBat.PrdBatId
		AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId
		AND PrdBat.DefaultPriceId=PBDR.PriceId 
UNION ALL 
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
		0 AS SelRate,
		PBDL.PrdBatDetailValue+((PBDL.PrdBatDetailValue*TxRpt.TaxPercentage)/100) AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		0 AS SalMRP,
		0 AS UnSalMRP,
		0 AS TotMRP,
		0 AS SalSelRate,
		0 AS UnSalSelRate,
		0 AS TotSelRate,
		(PrdBatLcnSih-PrdBatLcnResSih)* (PBDL.PrdBatDetailValue+((PBDL.PrdBatDetailValue*TxRpt.TaxPercentage)/100))  AS SalListPrice,
		(PrdBatLcnUih-PrdBatLcnResUih)* (PBDL.PrdBatDetailValue+((PBDL.PrdBatDetailValue*TxRpt.TaxPercentage)/100))  AS UnSalListPrice,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (PBDL.PrdBatDetailValue+((PBDL.PrdBatDetailValue*TxRpt.TaxPercentage)/100)) ) AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		ProductBatchDetails PBDL (NOLOCK),BatchCreation BCL (NOLOCK),
		ProductBatchTaxPercent TxRpt (NOLOCK),
		ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId  
		AND PrdBat.BatchSeqId=BCL.BatchSeqId
		AND BCL.ListPrice=1 AND BCL.SlNo=PBDL.SLNo AND PBDL.PrdBatId=PrdBat.PrdBatId
		AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId 
		AND PrdBat.DefaultPriceId=PBDL.PriceId
)A GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdCCode ,PrdName,PrdBatId,PrdBatCode,Saleable,SaleableWgt ,Unsaleable,UnsaleableWgt ,Offer,OfferWgt,Total,
			CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode,PrdStatus,Status
GO
IF EXISTS (SELECT * FROM SysObjects WHERE name='View_CurrentStockReportNTax' AND XTYPE='V')
DROP VIEW View_CurrentStockReportNTax
GO
CREATE    VIEW View_CurrentStockReportNTax
/************************************************************
* VIEW	: View_CurrentStockReportNTax
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	:  Karthick	
* CREATED DATE	:  2011-05-11
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT LcnId,LcnName,PrdId,PrdDCode,Prdccode,PrdName,PrdBatId,PrdBatCode,sum(MRP)MRP,sum(SelRate)SelRate,sum(ListPrice)ListPrice,
	Saleable,SaleableWgt ,Unsaleable,UnsaleableWgt ,Offer,OfferWgt ,Total,sum(SalMRP)SalMRP,sum(UnSalMRP)UnSalMRP,sum(TotMRP)TotMRP,sum(SalSelRate)SalSelRate,
	sum(UnSalSelRate)UnSalSelRate,sum(TotSelRate)TotSelRate,sum(SalListPrice)SalListPrice,sum(UnSalListPrice)UnSalListPrice,
	sum(TotListPrice)TotListPrice,PrdStatus,Status,CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode
FROM (
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,PBDM.PrdBatDetailValue AS MRP,
		0 AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		(PrdBatLcnSih-PrdBatLcnResSih)* PBDM.PrdBatDetailValue  AS SalMRP,
		(PrdBatLcnUih-PrdBatLcnResUih)* PBDM.PrdBatDetailValue  AS UnSalMRP,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* PBDM.PrdBatDetailValue ) AS TotMRP,
		0 AS SalSelRate,
		0 AS UnSalSelRate,
		0 AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		 ProductBatchDetails PBDM (NOLOCK),BatchCreation BCM (NOLOCK),
		 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		 AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId AND PrdBat.BatchSeqId=BCM.BatchSeqId
		 AND BCM.MRP=1 AND BCM.SlNo=PBDM.SLNo AND PBDM.PrdBatId=PrdBat.PrdBatId 
		 AND PrdBat.DefaultPriceId=PBDM.PriceId 
UNION ALL 
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
		PBDR.PrdBatDetailValue AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		0  AS SalMRP,
		0  AS UnSalMRP,
		0 AS TotMRP,
		(PrdBatLcnSih-PrdBatLcnResSih)* (PBDR.PrdBatDetailValue)  AS SalSelRate,
		(PrdBatLcnUih-PrdBatLcnResUih)* (PBDR.PrdBatDetailValue)  AS UnSalSelRate,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (PBDR.PrdBatDetailValue) ) AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		 ProductBatchDetails PBDR (NOLOCK),BatchCreation BCR (NOLOCK),
		 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
		AND PrdBat.BatchSeqId=BCR.BatchSeqId
		AND BCR.SelRte=1 AND BCR.SlNo=PBDR.SLNo AND PBDR.PrdBatId=PrdBat.PrdBatId
		AND PrdBat.DefaultPriceId=PBDR.PriceId  
UNION ALL
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
			0 AS SelRate,
			PBDL.PrdBatDetailValue AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
			((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
			0 AS SalMRP,
			0 AS UnSalMRP,
			0 AS TotMRP,
			0 AS SalSelRate,
			0 AS UnSalSelRate,
			0 AS TotSelRate,
			(PrdBatLcnSih-PrdBatLcnResSih)* (PBDL.PrdBatDetailValue)  AS SalListPrice,
			(PrdBatLcnUih-PrdBatLcnResUih)* (PBDL.PrdBatDetailValue)  AS UnSalListPrice,
			(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (PBDL.PrdBatDetailValue) ) AS TotListPrice,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		  	 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			 ProductBatchDetails PBDL (NOLOCK),BatchCreation BCL (NOLOCK),
			 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	    WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND PrdBat.BatchSeqId=BCL.BatchSeqId
			AND BCL.ListPrice=1 AND BCL.SlNo=PBDL.SLNo AND PBDL.PrdBatId=PrdBat.PrdBatId
			AND PrdBat.DefaultPriceId=PBDL.PriceId
)A GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdCCode ,PrdName,PrdBatId,PrdBatCode,Saleable,SaleableWgt ,Unsaleable,UnsaleableWgt ,Offer,OfferWgt,Total,
			CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode,PrdStatus,Status
GO
IF EXISTS (SELECT * FROM Sys.objects WHERE NAME='Proc_RptCurrentStock' AND TYPE='P')
DROP PROCEDURE Proc_RptCurrentStock
GO
--Exec [Proc_RptCurrentStock] 5,1,0,'Parle1',0,0,1,0
CREATE PROCEDURE Proc_RptCurrentStock
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
	IF @DispBatch = 1 
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	DELETE FROM TaxForReport WHERE UsrId=@Pi_UsrId AND RptId=@Pi_RptId
	IF @SupTaxGroupId<>0 OR @RtrTaxFroupId<>0
	BEGIN
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UsrId,@Pi_RptId
	END
	if exists (select * from dbo.sysobjects where id = object_id(N'[UOMIdWise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [UOMIdWise]
	CREATE TABLE [UOMIdWise] 
	(
		SlNo	INT IDENTITY(1,1),
		UOMId	INT
	) 
	INSERT INTO UOMIdWise(UOMId)
	SELECT UOMId FROM UOMMaster ORDER BY UOMId		
	Create TABLE #RptCurrentStock
	(
		PrdId    INT,
		PrdDcode  NVARCHAR(100),
		PrdCCode  NVARCHAR(100),
		PrdName   NVARCHAR(200),
		PrdBatId              INT,
		PrdBatCode   NVARCHAR(100),
		MRP                NUMERIC (38,6),
		DisplayRate         NUMERIC (38,6),
		Saleable              INT,
		SaleableWgt		NUMERIC (38,6),
		Unsaleable   INT,
		UnsaleableWgt		NUMERIC (38,6),
		Offer                 INT,
		OfferWgt		NUMERIC (38,6),
		DisplaySalRate       NUMERIC (38,6),
		DisplayUnSalRate      NUMERIC (38,6),
		DisplayTotRate        NUMERIC (38,6),
		DispBatch             INT,
		RtrTaxGroup           INT,
		SupTaxGroup           INT,
		StockType			  INT
		
	)
	SET @TblName = 'RptCurrentStock'
	SET @TblStruct = '  PrdId      INT,
						PrdDcode    NVARCHAR(100),
						PrdCCode  NVARCHAR(100),
						PrdName     NVARCHAR(200),
						PrdBatId       INT,
						PrdBatCode     NVARCHAR(100),
						MRP            NUMERIC (38,6),
						DisplayRate    NUMERIC (38,6),
						Saleable       INT,
						SaleableWgt		NUMERIC (38,6),
						Unsaleable		INT,
						UnsaleableWgt	NUMERIC (38,6),
						Offer           INT,
						OfferWgt		NUMERIC (38,6),
						DisplaySalRate    NUMERIC (38,6),
						DisplayUnSalRate   NUMERIC (38,6),
						DisplayTotRate     NUMERIC (38,6),
						DispBatch          INT,
						RtrTaxGroup        INT,
						SupTaxGroup        INT,
						StockType		   INT'
	SET @TblFields = 'PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType'
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
		IF @SupTaxGroupId<>0 OR @RtrTaxFroupId<>0
		BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReport
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))-- AND
				--UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReport
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))-- AND
				--UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
		END
		ELSE
		BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReportNTax
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				--AND UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReportNTax
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				--AND UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
		END
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
	
	IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND  GridFlag=1 AND UsrId=@Pi_UsrId)
	BEGIN
		SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
		(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
		(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
		CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
		(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
		a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
		INTO #RptColDetails
		FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,Rptid,Usrid)
		SELECT PrdDcode,PrdName,PrdBatCode,MRP,DisplayRate,Saleable,Uom1,Uom2,Uom3,Uom4,
		Unsaleable,Offer,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,@Pi_RptId,@Pi_UsrId
		FROM #RptColDetails
	END
	--SELECT @RptDispType
	SET @RptDispType=ISNULL(@RptDispType,1)
	IF @RptDispType=1
	BEGIN
		--TRUNCATE TABLE RptCurrentStock_Excel
		IF @SupZeroStock=1
		BEGIN
			SELECT * FROM #RptCurrentStock
			WHERE Saleable+Unsaleable+Offer <> 0
----			IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND Flag=1 AND UsrId=@Pi_UsrId)
----			BEGIN
----				INSERT INTO RptCurrentStock_Excel
----				SELECT * FROM #RptCurrentStock
----				WHERE (Saleable+UnSaleable+Offer)<>0
----			END
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE RptCurrentStock_Excel
				SELECT * INTO RptCurrentStock_Excel FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			PRINT 'Data Executed'
		END
		ELSE
		BEGIN
			SELECT * FROM #RptCurrentStock
----			IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND Flag=1 AND UsrId=@Pi_UsrId)
----			BEGIN
----				INSERT INTO RptCurrentStock_Excel
----				SELECT * FROM #RptCurrentStock
----			END
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE RptCurrentStock_Excel
				SELECT * INTO RptCurrentStock_Excel FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock 
			PRINT 'Data Executed'
		END
	END
	ELSE
	BEGIN		
		IF @SupZeroStock=1
		BEGIN
			SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
			a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
			FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
			AND (a.Saleable + a.Unsaleable + a.Offer) <> 0
		
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			PRINT 'Data Executed'
		END
		ELSE
		BEGIN
			SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
			a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
			FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
			
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock
			PRINT 'Data Executed'
		END
	END
		DELETE FROM RptExcelHeaders WHERE RptId=5
		DECLARE @COLUMN AS Varchar(80)
		DECLARE @C_SSQL AS Varchar(8000)
		DECLARE @iCnt AS Int 
		SET @iCnt=1
			DECLARE Cur_Col CURSOR FOR  
			SELECT SC.[Name] FROM SysColumns SC,SysObjects So WHERE SC.Id=SO.Id AND SO.[Name]='RptCurrentStock_Excel'
			OPEN Cur_Col
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
			SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
			SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
			EXEC (@C_SSQL)
			SET @iCnt=@iCnt+1
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			END
			CLOSE Cur_Col
			DEALLOCATE Cur_Col
		  UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN (1)
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name ='Proc_RptSchemeUtilization_Parle' AND XTYPE='P')
DROP PROCEDURE Proc_RptSchemeUtilization_Parle
GO
--EXEC Proc_RptSchemeUtilization_Parle 246,2,0,'Henkel',0,0,1
CREATE Procedure Proc_RptSchemeUtilization_Parle
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
*********************************/
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
	[ReferNo] [nvarchar](100) NULL,
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
	[SMName] [nvarchar](200) NULL,
	[RMName] [nvarchar](200) NULL,
	[DlvRMName] [nvarchar](200) NULL,
	[RtrName] [nvarchar](200) NULL,
	[VehicleName] [nvarchar](200) NULL,
	[DeliveryBoyName] [nvarchar](200) NULL,
	[PrdName] [nvarchar](200) NULL,
	[BatchName] [nvarchar](200) NULL,
	[FreePrdName] [nvarchar](200) NULL,
	[FreeBatchName] [nvarchar](200) NULL,
	[GiftPrdName] [nvarchar](200) NULL,
	[GiftBatchName] [nvarchar](200) NULL,
	[LineType] [int] NULL,
	[ReferDate] [datetime] NULL,
	[CtgLevelId] [int] NULL,
	[CtgLevelName] [nvarchar](200) NULL,
	[CtgMainId] [int] NULL,
	[CtgName] [nvarchar](200) NULL,
	[RtrClassId] [int] NULL,
	[ValueClassName] [nvarchar](200) NULL,
	[BaseQty] [Int],
	[BaseQtyBox] [Int],
	[BaseQtyPack] [Int]
) ON [PRIMARY]
	
	Create TABLE #RptSchemeUtilizationDet_Parle
	(
		SchId		Int,
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
		FreePrdName	nVarchar(200),
		FreeQty		Int,
		[BaseQty] [Int],
		BaseQtyBox	Int,
		BaseQtyPack Int,
		FreeValue	Numeric(38,6),
		GiftPrdName	nVarchar(200),
		GiftQty		Int,
		GiftValue	Numeric(38,6),
		[CircularNo] [Nvarchar](50)
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
		EXEC PROC_RPTStoreSchemeDetails @Pi_RptId,@Pi_UsrId
	
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
		Insert Into #RptStoreSchemeDetails(SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,RtrId,DlvSts,VehicleId,DlvBoyId,PrdID,PrdBatId,FlatAmount,DiscountPer,
										   Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,GiftQty,GiftValue,SchemeBudget,BudgetUtilized,
										   Selected,UserId,SMName,RMName,DlvRMName,RtrName,VehicleName,DeliveryBoyName,PrdName,BatchName,FreePrdName,FreeBatchName
										   ,GiftPrdName,GiftBatchName,LineType,ReferDate,CtgLevelId,CtgLevelName,CtgMainId,CtgName,RtrClassId,ValueClassName,BaseQty,BaseQtyBox,BaseQtyPack) 
		Select SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,RtrId,DlvSts,VehicleId,DlvBoyId,PrdID,PrdBatId,FlatAmount,DiscountPer,
										   Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,GiftQty,GiftValue,SchemeBudget,BudgetUtilized,
										   Selected,UserId,SMName,RMName,DlvRMName,RtrName,VehicleName,DeliveryBoyName,PrdName,BatchName,FreePrdName,FreeBatchName
										   ,GiftPrdName,GiftBatchName,LineType,ReferDate,CtgLevelId,CtgLevelName,CtgMainId,CtgName,RtrClassId,ValueClassName,0,0,0
										  From RPTStoreSchemeDetails Where Userid = @Pi_UsrId AND BudgetUtilized>0
		
		--Select Distinct ReferNo,BaseQty,PrdId,PrdBatId Into #RptScheme From #RptStoreSchemeDetails Where LineType<>3 And Userid = @Pi_UsrId
		
		Update X Set X.BaseQty=Sp.BaseQty --Case When FreeValue=0 Then Sp.BaseQty Else 0 End
			From SalesInvoice S
					Inner Join (SELECT SalId,PrdId,PrdBatId,SUM(BaseQty) AS BaseQty FROM SalesInvoiceProduct
					GROUP BY SalId,PrdId,PrdBatId) SP On S.SalId=SP.SalId
					Inner Join  #RptStoreSchemeDetails X On X.ReferNo=S.SalInvNo And X.PrdID=SP.PrdId And X.PrdBatId=SP.PrdBatId
					Inner join  #PrdUomAll PU On PU.PrdId=X.PrdID
				 Where X.LineType<>3 
		--SELECT 'lll', * FROM #RptStoreSchemeDetails
--EXEC Proc_RptSchemeUtilization_Parle 237,1,0,'Henkel',0,0,1
		
		--SELECT * FROM #RptStoreSchemeDetails Inner join  #PrdUomAll PU On PU.PrdId=#RptStoreSchemeDetails.PrdID
							   
		INSERT INTO #RptSchemeUtilizationDet_Parle(SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
			NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,BaseQty,BaseQtyBox,BaseQtyPack,FreeValue,
			GiftPrdName,GiftQty,GiftValue,CircularNo)
		SELECT DISTINCT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,Count(Distinct B.RtrId),
			Count(Distinct B.ReferNo),0 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
			CASE FreePrdId WHEN 0 THEN dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId) ELSE '0.00' END as DiscountPer,
			ISNULL(SUM(Points),0) as Points,CASE ISNULL(SUM(FreeQty),0) WHEN 0 THEN '' ELSE FreePrdName END AS FreePrdName,
			CASE FreePrdName WHEN '' THEN 0 ELSE ISNULL(SUM(FreeQty),0)  END as FreeQty,ISNULL(Sum(BaseQty),0) as BaseQty,
			Case When Isnull(Sum(BaseQty),0)<MAX(ConversionFactor) Then 0 Else Isnull(Sum(BaseQty),0)/MAX(ConversionFactor) End As BaseQtyBox,
			Case When Isnull(Sum(BaseQty),0)<MAX(ConversionFactor) Then Isnull(Sum(BaseQty),0) Else Isnull(Sum(BaseQty),0)%MAX(ConversionFactor) End As BaseQtyPack,
			ISNULL(SUM(FreeValue),0) as FreeValue,
			CASE ISNULL(SUM(GiftValue),0) WHEN 0 THEN '' ELSE GiftPrdName END AS GiftPrdName,ISNULL(SUM(GiftQty),0) as FreeQty,
			ISNULL(SUM(GiftValue),0) as GiftValue,isnull(BudgetAllocationNo,'')
		FROM SchemeMaster A INNER JOIN #RPTStoreSchemeDetails B On A.SchId= B.SchId
			AND B.Userid = @Pi_UsrId
		Inner Join #PrdUomAll PU On PU.PrdId=B.PrdID
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
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,FreePrdId,
			FreePrdName,GiftPrdName,BudgetAllocationNo--,B.PrdID 
			
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
	
		INSERT INTO @TempData(SchId,RtrCnt,BillCnt)
		SELECT SchId, Count(Distinct B.RtrId),Count(Distinct ReferNo)
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
		GROUP BY B.SchId
		
		UPDATE #RptSchemeUtilizationDet_Parle SET NoOfRetailer = NoOfRetailer,
			NoOfBills = BillCnt FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet_Parle.SchId
	
		DELETE FROM @TempData
	
		INSERT INTO @TempData(SchId,RtrCnt,BillCnt)
		SELECT SchId, Count(Distinct B.RtrId),Count(Distinct ReferNo)
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
			GROUP BY B.SchId
			
		UPDATE #RptSchemeUtilizationDet_Parle SET UnselectedCnt = RtrCnt
			FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet_Parle.SchId
		
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
	UPDATE A SET BaseQty = B.BaseQty FROM #RptSchemeUtilizationDet_Parle A INNER JOIN
	(SELECT C.SchId,(SUM(B.BaseQty)-SUM(ReturnedQty)) AS BaseQty FROM Salesinvoice A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
	INNER JOIN 
	(SELECT DISTINCT ReferNo,B.PrdId,A.SchId FROM RptStoreSchemeDetails A INNER JOIN Fn_ReturnSchemeProductWithScheme() B ON 
	A.SchId=B.SchId)C ON A.SalInvNo=C.ReferNo AND B.PrdId=C.PrdId GROUP BY C.SchId) B ON A.SchId=B.SchId
	
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
	
	SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,
	UnselectedCnt,(BaseQtyBox) AS BaseQtyBox,(BaseQtyPack) AS BaseQtyPack,
	DiscountPer,(CASE FreeQty WHEN 0 THEN '-' ELSE FreePrdName END) AS FreePrdName,FreeQty,
    (CASE FreeQty WHEN 0 THEN '0.00' ELSE FreeValue END) AS FreeValue,FlatAmount,Points,(BaseQty) AS BaseQty,
	GiftPrdName,GiftQty,GiftValue
	FROM #RptSchemeUtilizationDet_Parle 
	
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'RptSchemeUtilizationDet_Parle_Excel') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationDet_Parle_Excel
			SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,
			UnselectedCnt,(BaseQtyBox) AS BaseQtyBox,(BaseQtyPack) AS BaseQtyPack,
			DiscountPer,(CASE FreeQty WHEN 0 THEN '-' ELSE FreePrdName END) AS FreePrdName,FreeQty,
			(CASE FreeQty WHEN 0 THEN '0.00' ELSE FreeValue END) AS FreeValue,FlatAmount,Points,(BaseQty) AS BaseQty,
			GiftPrdName,GiftQty,GiftValue
			INTO RptSchemeUtilizationDet_Parle_Excel FROM #RptSchemeUtilizationDet_Parle Order By SchId
	END 
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name ='Proc_RptClosingStockReportParle' AND XTYPE='P')
DROP PROCEDURE Proc_RptClosingStockReportParle
GO
--EXEC Proc_RptClosingStockReportParle 254,1,0,'',0,0,1
CREATE PROCEDURE [Proc_RptClosingStockReportParle]
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
* {date} {developer}  {brief modification description}
	
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
	--Product UOM Details
    SELECT DISTINCT Prdid,U.ConversionFactor 
	Into #PrdUomBox
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	Inner Join UomMaster UM On U.UomId=Um.UomId
	--Where Um.UomCode ='BX' --Commented and added by Rajesh ICRSTPAR3196
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
	SELECT Prdid,
			Case PrdUnitId 
			When 2 Then (PrdWgt/1000)/1000
			When 3 Then PrdWgt/1000 END AS PrdWgt
			Into #PrdWeight  From Product
 --Till Here			
	CREATE TABLE #RptClosingStock
	(
				PrdId		INT,
				PrdDCode     NVARCHAR(200),
				PrdName		NVARCHAR(200),
				MRP		    NUMERIC(38,6),
				RATE        NUMERIC(38,6),
				Qty		    INT,
				TaxPerc     NUMERIC(18,2),
				StockValue	NUMERIC(38,6),
				TaxAmount   NUMERIC(38,6),
				NetAmount   NUMERIC(38,6)				
	)
	SET @TblName = 'RptClosingStock'
	SET @TblStruct = 'PrdId		INT,
	            PrdDCode     NVARCHAR(200),
				PrdName		NVARCHAR(100),
				MRP		    NUMERIC(38,6),
				RATE        NUMERIC(38,6),
				Qty		    INT,
				TaxPerc     NUMERIC(38,6),
				StockValue	NUMERIC(38,6),
				TaxAmount   NUMERIC(38,6),
				NetAmount   NUMERIC(38,6)'
	SET @TblFields = 'PrdId,PrdDCode,PrdName,MRP,RATE,Qty,TaxPerc,StockValue,TaxAmount,NetAmount'
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
	--Added By Sathishkumar Veeramani 2014/11/17 Tax Settings Details
	EXEC Proc_ClosingStockTaxCalCulation
	--Till Here
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptClosingStock (PrdId,PrdDCode,PrdName,MRP,RATE,Qty,TaxPerc,StockValue,TaxAmount,NetAmount)
		SELECT DISTINCT T.PrdId,P.PrdDCode,T.PrdName,MRP,CASE @DispValue WHEN 1 THEN T.Sellingrate ELSE ListPrice END,
		SUM(BaseQty),TaxPercentage,SUM((CASE @DispValue WHEN 1 THEN (BaseQty * SellingRate) ELSE (BaseQty*ListPrice) END)) As StockValue,
		SUM((CASE @DispValue WHEN 1 THEN ((BaseQty * SellingRate)*(TaxPercentage/100)) ELSE ((BaseQty*ListPrice)*(TaxPercentage/100)) END)) AS TaxAmount,
		SUM((CASE @DispValue WHEN 1 THEN (BaseQty * SellingRate) + ((BaseQty * SellingRate)*(TaxPercentage/100)) 
		ELSE (BaseQty*ListPrice)+((BaseQty*ListPrice)*(TaxPercentage/100)) END)) As NetAmount
		FROM TempClosingStock T WITH (NOLOCK) INNER JOIN Product P WITH (NOLOCK) ON T.PrdId = P.PrdId
		INNER JOIN ClosingStockProductTaxPercent TS WITH (NOLOCK) ON T.PrdId = TS.PrdId 		
		WHERE (T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
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
		GROUP BY T.PrdId,T.PrdName,MRP,SellingRate,ListPrice,P.PrdDCode,TaxPercentage ORDER BY P.PrdDCode
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
	
	
	IF @SupZeroStock=1 
	BEGIN
		--Check for Report Data
		Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock WHERE Qty <> 0
		-- Till Here
	
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		CASE WHEN SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		CASE WHEN SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
		TaxPerc,SUM(StockValue) AS StockValue,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount 
		FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    GROUP BY A.PrdId,PrdName,MRP,PrdDCode,TaxPerc Having SUM(Qty) <> 0 Order By PrdDCode
	    
	    IF EXISTS (SELECT * FROM Sysobjects Where XTYPE = 'U' And name = 'RptClosingStockReportParle_Excel')
		DROP TABLE RptClosingStockReportParle_Excel
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
		TaxPerc,SUM(StockValue) AS StockValue,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount
	    INTO RptClosingStockReportParle_Excel FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    Group By A.PrdId,PrdName,MRP,PrdDCode,TaxPerc Having SUM(Qty) <> 0 Order By PrdDCode
	
	END
	ELSE
	BEGIN
	
		--Check for Report Data
		Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock
		-- Till Here
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
		TaxPerc,SUM(StockValue) AS StockValue,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount
		FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    GROUP BY A.PrdId,PrdName,MRP,PrdDCode,TaxPerc ORDER BY PrdDCode
	    IF EXISTS (SELECT * FROM Sysobjects Where XTYPE = 'U' And name = 'RptClosingStockReportParle_Excel')
		DROP TABLE RptClosingStockReportParle_Excel
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
		TaxPerc,SUM(StockValue) AS StockValue,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount
	    INTO RptClosingStockReportParle_Excel FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    GROUP BY A.PrdId,PrdName,MRP,PrdDCode,TaxPerc Order By PrdDCode
	END
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name ='Proc_RptStockandSalesVolumeParle' AND XTYPE='P')
DROP PROCEDURE Proc_RptStockandSalesVolumeParle
GO
--EXEC Proc_RptStockandSalesVolumeParle 236,2,0,'CKProduct',0,0,1
CREATE PROCEDURE Proc_RptStockandSalesVolumeParle
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
/**************************************************************************
* PROCEDURE : Proc_RptStockandSalesVolume_Parle
* PURPOSE : To get the Stock and Sales Volume details Uom Wise for Report
* CREATED : Praveen Raj B
* CREATED DATE : 24/01/2012
* MODIFIED
***************************************************************************/
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
	DECLARE @PrdStatus  AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @StockValue 	AS	INT
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
	SET @PrdStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))  
	SET @PrdBatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))  
	SET @StockValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))  
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
 --IF @IncOffStk=1    
 --BEGIN    
  Exec Proc_GetStockNSalesDetailsWithOffer @FromDate,@ToDate,@Pi_UsrId    
 --END    
 --ELSE    
 --BEGIN    
 -- Exec Proc_GetStockNSalesDetails @FromDate,@ToDate,@Pi_UsrId    
 --END  
	CREATE TABLE #RptStockandSalesVolume_Parle  
	(  
		PrdId			INT,  
		PrdDCode			NVARCHAR(50),  
		PrdName			NVARCHAR(100),  
		PrdBatId			INT,  
		PrdBatCode		NVARCHAR(50),  
		CmpId			INT,  
		CmpName			NVARCHAR(50),  
		LcnId			INT,  
		LcnName			NVARCHAR(50),   
		OpeningStock		Int,    
		Purchase			Int,  
		Sales			INT,  
		Adjustment      Int,
		PurchaseReturn   INT,  
		SalesReturn		INT,    
		ClosingStock		INT,  
		ClosingStkValue	NUMERIC (38,6),
		OpenWeight	NUMERIC (38,6),
		PurchaseWeight NUMERIC (38,6),
		SalesWeight NUMERIC (38,6),
		AdjustmentWeight NUMERIC (38,6),
		PurchaseReturnWeight NUMERIC (38,6),
		SalesReturnWeight NUMERIC (38,6),
		ClosingStockWeight NUMERIC (38,6),
		OpeningStkValue NUMERIC (38,6),
		PurchaseStkValue NUMERIC (38,6),
		SalesStkValue NUMERIC (38,6),
		AdjustmentStkValue NUMERIC (38,6),
		ClosingStockkValue NUMERIC (38,6)
	)  
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
	
	SELECT Prdid,
			Case PrdUnitId 
			When 2 Then (PrdWgt/1000)/1000
			When 3 Then PrdWgt/1000 END AS PrdWgt
			Into #PrdWeight  From Product
	
	SELECT * INTO #RptStockandSalesVolume_Parle1 FROM #RptStockandSalesVolume_Parle  
	SET @TblName = 'RptStockandSalesVolume'  
	SET @TblStruct = 'PrdId    INT,  
					  PrdDCode			NVARCHAR(40),  
					  PrdName			NVARCHAR(100),  
					  PrdBatId			INT,  
					  PrdBatCode		NVARCHAR(50),  
					  CmpId				INT,  
					  CmpName			NVARCHAR(50),  
					  LcnId				INT,  
					  LcnName			NVARCHAR(50),   
					  OpeningStock		Int,  
					  Purchase			Int,  
					  Sales				INT,     
					  Adjustment		Int,
					  PurchaseReturn	INT,  
					  SalesReturn		INT,     
					  ClosingStock		INT,  
					  ClosingStkValue	NUMERIC (38,6),
					  OpenWeight		NUMERIC (38,6),
					  PurchaseWeight	NUMERIC (38,6),
					  SalesWeight		NUMERIC (38,6),
					  AdjustmentWeight	NUMERIC (38,6),
					  PurchaseReturnWeight	NUMERIC (38,6),
					  SalesReturnWeight		NUMERIC (38,6),
					  ClosingStockWeight	NUMERIC (38,6)  
					  OpeningStkValue		NUMERIC (38,6),
					  PurchaseStkValue		NUMERIC (38,6),
					  SalesStkValue			NUMERIC (38,6),
					  AdjustmentStkValue	NUMERIC (38,6),
					  ClosingStockkValue		NUMERIC (38,6)'
	SET @TblFields = 'PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
   					  LcnName,OpeningStock,Purchase,Sales,Adjustment,  
					  PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue,OpenWeight,PurchaseWeight
					  SalesWeight,AdjustmentWeight,PurchaseReturnWeight,SalesReturnWeight,ClosingStockWeight,
					  OpeningStkValue,PurchaseStkValue,SalesStkValue,AdjustmentStkValue,ClosingStockkValue'  
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
			INSERT INTO #RptStockandSalesVolume_Parle (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												 LcnName,OpeningStock,Purchase,Sales,Adjustment,PurchaseReturn,SalesReturn,
												 ClosingStock,ClosingStkValue,OpenWeight,PurchaseWeight,
												 SalesWeight,AdjustmentWeight,PurchaseReturnWeight,SalesReturnWeight,ClosingStockWeight
												 ,OpeningStkValue,PurchaseStkValue,SalesStkValue,AdjustmentStkValue,ClosingStockkValue)  
			SELECT PrdId,PrdDcode,PrdName,0,0,TempRptStockNSales.CmpId,CmpName,LcnId,LcnName,  
			Opening,(Purchase-PurchaseReturn),(Sales-SalesReturn),(AdjustmentIn-AdjustmentOut),PurchaseReturn,SalesReturn,Closing,
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId),0,0,0,0,0,0,0,
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN OpnSelRte WHEN 2 THEN OpnPurRte WHEN 3 THEN OpnMRPRte END,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN PurSelRte WHEN 2 THEN PurPurRte WHEN 3 THEN PurMRPRte END,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN SalSelRte WHEN 2 THEN SalPurRte WHEN 3 THEN SalMRPRte END,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN (AdjInSelRte-AdjOutSelRte) WHEN 2 THEN (AdjInPurRte+AdjOutPurRte) WHEN 3 THEN 
			(AdjInMRPRte+AdjOutMRPRte) END,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId)
			FROM TempRptStockNSales 
			INNER JOIN  Company  C ON C.CmpId = TempRptStockNSales.CmpId 
			WHERE 
			( TempRptStockNSales.CmpId = (CASE @CmpId WHEN 0 THEN TempRptStockNSales.CmpId ELSE 0 END) OR  
			TempRptStockNSales.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
			AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
			LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
			AND (PrdStatus = (CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END) OR  
			PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))  
			--AND (BatStatus = (CASE @BatStatus WHEN 0 THEN BatStatus ELSE 2 END) OR  
			--BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdCatValId WHEN 0 THEN PrdId Else 0 END) OR  
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
			AND UserId=@Pi_UsrId 
			And Opening+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+Closing <>0 Order By PrdDcode
			Update R Set OpenWeight=(OpeningStock*PrdWgt),
			PurchaseWeight=(Purchase*PrdWgt),
			SalesWeight=(Sales*PrdWgt),
			AdjustmentWeight=(Adjustment*PrdWgt),
			PurchaseReturnWeight=(PurchaseReturn*PrdWgt),
			SalesReturnWeight=(SalesReturn*PrdWgt),
			ClosingStockWeight=(ClosingStock*PrdWgt)
			From #PrdWeight PW 
			Inner Join #RptStockandSalesVolume_Parle R On R.PrdId=PW.PrdId
		
		IF LEN(@PurDBName) > 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume_Parle ' +  
			'(' + @TblFields + ')' +  
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +  
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( LcnId = (CASE ' + CAST(@LcnId AS nVarChar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR ' +  
			' LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE 0 END) OR ' +  
			' PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',24,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '  
			--+ '( BatStatus = (CASE ' + CAST(@BatStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE 0 END) OR ' +  
			--' BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',25,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptStockandSalesVolume_Parle'  
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
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume_Parle ' +  
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
	
			SELECT	RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName, 
					Cast(Case When SUM(OpeningStock)<MAX(ConversionFactor) Then 0 Else SUM(OpeningStock)/MAX(ConversionFactor) End As VarChar(25)) As OpeneningBox,
					Cast(Case When SUM(OpeningStock)<MAX(ConversionFactor) Then SUM(OpeningStock) Else SUM(OpeningStock)%MAX(ConversionFactor) End As VarChar(25)) As OpeneningPack,
					Cast(Case When SUM(Purchase)<MAX(ConversionFactor) Then 0 Else SUM(Purchase)/MAX(ConversionFactor) End As VarChar(25)) As PurchaseBox,
					Cast(Case When SUM(Purchase)<MAX(ConversionFactor) Then SUM(Purchase) Else SUM(Purchase)%MAX(ConversionFactor) End As VarChar(25)) As PurchasePack,
					Cast(Case When SUM(Sales)<MAX(ConversionFactor) Then 0 Else SUM(Sales)/MAX(ConversionFactor) End As VarChar(25)) As SalesBox,
					Cast(Case When SUM(Sales)<MAX(ConversionFactor) Then SUM(Sales) Else SUM(Sales)%MAX(ConversionFactor) End As VarChar(25)) As SalesPack,
					Cast(Case When SUM(Adjustment)<MAX(ConversionFactor) Then 0 Else SUM(Adjustment)/MAX(ConversionFactor) End As VarChar(25)) As AdjustmentBox,
					Cast(Case When SUM(Adjustment)<MAX(ConversionFactor) Then SUM(Adjustment) Else SUM(Adjustment)%MAX(ConversionFactor) End As VarChar(25)) As AdjustmentPack,
					--Cast(Case When AdjustmentIn<MAX(ConversionFactor) Then 0 Else AdjustmentIn/MAX(ConversionFactor) End As Int) -
					--Cast(Case When AdjustmentOut<MAX(ConversionFactor) Then 0 Else AdjustmentOut/MAX(ConversionFactor) End As Int)AdjustmentBox,
					--Cast(Case When AdjustmentIn<MAX(ConversionFactor) Then AdjustmentIn Else AdjustmentIn%MAX(ConversionFactor) End As Int)-
					--Cast(Case When AdjustmentOut<MAX(ConversionFactor) Then AdjustmentOut Else AdjustmentOut%MAX(ConversionFactor) End As Int) As AdjustmentPack,
					--Cast(Case When PurchaseReturn<MAX(ConversionFactor) Then 0 Else PurchaseReturn/MAX(ConversionFactor) End As VarChar(25)) As PurchaseReturnBox,
					--Cast(Case When PurchaseReturn<MAX(ConversionFactor) Then PurchaseReturn Else PurchaseReturn%MAX(ConversionFactor) End As VarChar(25)) As PurchaseReturnPack,
					--Cast(Case When SalesReturn<MAX(ConversionFactor) Then 0 Else SalesReturn/MAX(ConversionFactor) End As VarChar(25)) As SalesReturnBox,
					--Cast(Case When SalesReturn<MAX(ConversionFactor) Then SalesReturn Else SalesReturn%MAX(ConversionFactor) End As VarChar(25)) As SalesReturnPack,
					Cast(Case When SUM(ClosingStock)<MAX(ConversionFactor) Then 0 Else SUM(ClosingStock)/MAX(ConversionFactor) End As VarChar(25)) As ClosingStockBox,
					Cast(Case When SUM(ClosingStock)<MAX(ConversionFactor) Then SUM(ClosingStock) Else SUM(ClosingStock)%MAX(ConversionFactor) End As VarChar(25)) As ClosingStockPack,
					SUM(ClosingStkValue) AS ClosingStkValue,SUM(OpenWeight) AS OpenWeight,SUM(PurchaseWeight) AS PurchaseWeight,SUM(SalesWeight) AS SalesWeight,
					SUM(AdjustmentWeight) As AdjustmentWeight,
					--PurchaseReturnWeight,SalesReturnWeight,
					SUM(ClosingStockWeight) AS ClosingStockWeight,SUM(OpeningStkValue)AS OpeningStkValue,SUM(PurchaseStkValue) AS PurchaseStkValue,
					SUM(SalesStkValue)AS SalesStkValue,SUM(AdjustmentStkValue) AS AdjustmentStkValue,SUM(ClosingStockkValue) As ClosingStockkValue
					FROM #RptStockandSalesVolume_Parle RV 
					INNER JOIN #PrdUomAll P On RV.PrdId=P.PrdId
					Group By RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
							 LcnName Order By PrdDcode
						 --PurchaseReturnWeight,SalesReturnWeight,
							  
					DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
					INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
					SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume_Parle   
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN  
		If Exists (Select [Name] From SysObjects Where [Name]='RptStockandSalesVolumeParle_Excel' And XTYPE='U')
		Drop Table RptStockandSalesVolumeParle_Excel
			        SELECT RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName, 
					Cast(Case When SUM(OpeningStock)<MAX(ConversionFactor) Then 0 Else SUM(OpeningStock)/MAX(ConversionFactor) End As VarChar(25)) As OpeneningBox,
					Cast(Case When SUM(OpeningStock)<MAX(ConversionFactor) Then SUM(OpeningStock) Else SUM(OpeningStock)%MAX(ConversionFactor) End As VarChar(25)) As OpeneningPack,
					Cast(Case When SUM(Purchase)<MAX(ConversionFactor) Then 0 Else SUM(Purchase)/MAX(ConversionFactor) End As VarChar(25)) As PurchaseBox,
					Cast(Case When SUM(Purchase)<MAX(ConversionFactor) Then SUM(Purchase) Else SUM(Purchase)%MAX(ConversionFactor) End As VarChar(25)) As PurchasePack,
					Cast(Case When SUM(Sales)<MAX(ConversionFactor) Then 0 Else SUM(Sales)/MAX(ConversionFactor) End As VarChar(25)) As SalesBox,
					Cast(Case When SUM(Sales)<MAX(ConversionFactor) Then SUM(Sales) Else SUM(Sales)%MAX(ConversionFactor) End As VarChar(25)) As SalesPack,
					Cast(Case When SUM(Adjustment)<MAX(ConversionFactor) Then 0 Else SUM(Adjustment)/MAX(ConversionFactor) End As VarChar(25)) As AdjustmentBox,
					Cast(Case When SUM(Adjustment)<MAX(ConversionFactor) Then SUM(Adjustment) Else SUM(Adjustment)%MAX(ConversionFactor) End As VarChar(25)) As AdjustmentPack,
					--Cast(Case When AdjustmentIn<MAX(ConversionFactor) Then 0 Else AdjustmentIn/MAX(ConversionFactor) End As Int) -
					--Cast(Case When AdjustmentOut<MAX(ConversionFactor) Then 0 Else AdjustmentOut/MAX(ConversionFactor) End As Int)AdjustmentBox,
					--Cast(Case When AdjustmentIn<MAX(ConversionFactor) Then AdjustmentIn Else AdjustmentIn%MAX(ConversionFactor) End As Int)-
					--Cast(Case When AdjustmentOut<MAX(ConversionFactor) Then AdjustmentOut Else AdjustmentOut%MAX(ConversionFactor) End As Int) As AdjustmentPack,
					--Cast(Case When PurchaseReturn<MAX(ConversionFactor) Then 0 Else PurchaseReturn/MAX(ConversionFactor) End As VarChar(25)) As PurchaseReturnBox,
					--Cast(Case When PurchaseReturn<MAX(ConversionFactor) Then PurchaseReturn Else PurchaseReturn%MAX(ConversionFactor) End As VarChar(25)) As PurchaseReturnPack,
					--Cast(Case When SalesReturn<MAX(ConversionFactor) Then 0 Else SalesReturn/MAX(ConversionFactor) End As VarChar(25)) As SalesReturnBox,
					--Cast(Case When SalesReturn<MAX(ConversionFactor) Then SalesReturn Else SalesReturn%MAX(ConversionFactor) End As VarChar(25)) As SalesReturnPack,
					Cast(Case When SUM(ClosingStock)<MAX(ConversionFactor) Then 0 Else SUM(ClosingStock)/MAX(ConversionFactor) End As VarChar(25)) As ClosingStockBox,
					Cast(Case When SUM(ClosingStock)<MAX(ConversionFactor) Then SUM(ClosingStock) Else SUM(ClosingStock)%MAX(ConversionFactor) End As VarChar(25)) As ClosingStockPack,
					SUM(ClosingStkValue) AS ClosingStkValue,SUM(OpenWeight) AS OpenWeight,SUM(PurchaseWeight) AS PurchaseWeight,SUM(SalesWeight) AS SalesWeight,
					SUM(AdjustmentWeight) As AdjustmentWeight,
					--PurchaseReturnWeight,SalesReturnWeight,
					SUM(ClosingStockWeight) AS ClosingStockWeight,SUM(OpeningStkValue)AS OpeningStkValue,SUM(PurchaseStkValue) AS PurchaseStkValue,
					SUM(SalesStkValue)AS SalesStkValue,SUM(AdjustmentStkValue) AS AdjustmentStkValue,SUM(ClosingStockkValue) As ClosingStockkValue
					INTO RptStockandSalesVolumeParle_Excel FROM #RptStockandSalesVolume_Parle RV 
					INNER JOIN #PrdUomAll P On RV.PrdId=P.PrdId
					Group By RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
							 LcnName Order By PrdDcode
		END 
		
	RETURN  
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name ='Proc_RptUnloadingSheet' AND XTYPE='P')
DROP PROCEDURE Proc_RptUnloadingSheet
GO
-----Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
CREATE Procedure Proc_RptUnloadingSheet
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
/******************************************************************************************************
* CREATED BY	: PanneerSelvam.k
* CREATED DATE	: 05.11.2009 
* NOTE		    :
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}
* 12.11.2009	 	Panneer		 Added Cancel Transaction Details
* 14.11.2009       	Panneer		 Replacement Qty Value Mismatch
* 26.12.2009	 	Panneer		 Cancel Bill Qty Value Mismatch
* 01.02.2010       	Panneer		 Include Dlvsts 5
* 10-Jun-2010		Jayakumar.N	 BillWise RetailerWise is added
* 27.08.2010        Panneer      Shipping Address Duplicate Issue
* 17/01/2012		Praveenraj B Added Uom For Parle CR
********************************************************************************************************/
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
	
			/*	Filter Variables  */
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate	 			AS	DATETIME
	DECLARE @VehicleId 			AS	INT
	DECLARE @VehicleAllocId 	AS	INT
	DECLARE @SMId 				AS	INT
	DECLARE @DlvRouteId 		AS	INT
	DECLARE @RtrId 				AS	INT
	Declare @UomId				As  Int
	Declare @UomCode			As VarChar(20)
		/*  Assgin Value for the Filter Variable  */
	SELECT	@FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT	@ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)	
	SET @VehicleId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))	
	SET @VehicleAllocId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET	@SMId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId  	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))	
	SET @RtrId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	Set @UomId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,52,@Pi_UsrId))
	Select @UomCode=UomDescription From UomMaster Where UomId=@UomId
	
	Print @UomId
	Print @UomCode
--	exec PROC_UNLOAD
	Create TABLE #RptUnLoadingSheetReport
	(
				PrdId			INT,
				PrdDcode		NVARCHAR(100),
				PrdName			NVARCHAR(100),
				PrdBatId		INT,
				PrdBatCode		NVARCHAR(100),
				PrdUnitMRP		NUMERIC(38,2),
				PrdUnitSelRate	NUMERIC(38,2),
				LoadBilledQty	NUMERIC(38,2),
				LoadFreeQty 	NUMERIC(38,2),
				LoadReplacementQty NUMERIC(38,2),
				UnLoadSalQty	NUMERIC(38,2),
				UnLoadUnSalQty  NUMERIC(38,2),
				UnLoadFreeQty   NUMERIC(38,2)
	)
	SET @TblName = 'RptUnloadingSheet'
	SET @TblStruct = '	
				PrdId			INT,
				PrdDcode		NVARCHAR(100),
				PrdName			NVARCHAR(100),
				PrdBatId		INT,
				PrdBatCode		NVARCHAR(100),
				PrdUnitMRP		NUMERIC(38,2),
				PrdUnitSelRate	NUMERIC(38,2),
				LoadBilledQty	NUMERIC(38,2),
				LoadFreeQty 	NUMERIC(38,2),
				LoadReplacementQty NUMERIC(38,2),
				UnLoadSalQty	NUMERIC(38,2),
				UnLoadUnSalQty  NUMERIC(38,2),
				UnLoadFreeQty   NUMERIC(38,2)'
	
	SET @TblFields =   'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
							LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId'
				/*  Till Here  */
				/* Snap Shot Required  */
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
			/* Till Here  */
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
	CREATE TABLE #RptUnloadingSheet(SalId INT,PrdId INT,PrdDcode Varchar(100),PrdName Varchar(100),
									PrdBatId INT,PrdBatCode Varchar(100),PrdUnitMRP Numeric(38,2),
									PrdUnitSelRate Numeric(38,2),
									LoadBilledQty BigInt,LoadFreeQty BigInt,LoadReplacementQty BigInt,
									UnLoadSalQty BigInt,UnLoadUnSalQty BigInt,UnLoadOfferQty INT,UserId INT)
				/* ----------  LoadBilledQty  and Saleable Qty  in Temp Table ----------------------------*/
	DELETE FROM RptUnloadingSheet  
	DELETE FROM #RptUnloadingSheet 
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
			Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
			Sum(LoadReplacementQty) LoadReplacementQty,
			0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty, UserId
	FROM (
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				Max(BaseQty)  LoadBilledQty,0 AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 1	
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId  ) X
		GROUP BY 
				SalId,PrdId,PrdDcode,PrdName,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,UserId,PrdBatId
		
				/* ----------  Loaded Free Qty  in Temp Table ----------------------------*/
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
		Sum(LoadReplacementQty) LoadReplacementQty,
		0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,UserId
	FROM (		
					/* Sales Free */
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,Max(BaseQty) AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 2
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId  
	  ) X
	GROUP BY 
			SalId,PrdId,PrdDcode,PrdName,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,UserId,PrdBatId
		
				/* ----------  Loaded Replacement Qty  in Temp Table ----------------------------*/
		
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
		MAX(LoadReplacementQty) LoadReplacementQty,
		0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty, @Pi_UsrId UserId
	FROM (		
					
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,Sum(BaseQty) AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId,
				VersionNo   
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 4 AND S.StockType = 1
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo 
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId ,VersionNo
		UNION ALL
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,sUM(BaseQty) AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId,VersionNo
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 4 AND S.StockType = 3
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )	
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId ,VersionNo 
	  ) X
	GROUP BY SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
				LoadBilledQty,LoadFreeQty
					
				/*  Loaded Market Return Qty */
		INSERT INTO #RptUnloadingSheet
		SELECT	DISTINCT
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 3 
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
	
-- Added on 10-Jun-2010
	--DELETE FROM RptUnloadingSheet_Excel WHERE UserId=@Pi_UsrId
	--INSERT INTO RptUnloadingSheet_Excel
	--SELECT 
	--		A.SalId,SalInvNo,SI.RtrId,RtrCode,RtrName,(RSA.RtrShipAdd1+' --> '+RSA.RtrShipAdd2+' --> '+RSA.RtrShipAdd3),
	--		A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,
	--		Sum(LoadBilledQty) LoadBilledQty,
	--		SUm(LoadFreeQty) LoadFreeQty,
	--		SUm(LoadReplacementQty) LoadReplacementQty,
	--		Sum(UnLoadSalQty) UnLoadSalQty,
	--		Sum(UnLoadUnSalQty) UnLoadUnSalQty,
	--		Sum(UnLoadOfferQty) UnLoadOfferQty,
	--		'' [Description],UserId
	--FROM 
	--		#RptUnloadingSheet A
	--		INNER JOIN SalesInvoice SI ON A.SalId=SI.SalId 
	--		INNER JOIN Retailer R ON SI.RtrId=R.RtrId
	--		Left Outer JOIN RetailerShipAdd RSA ON R.RtrId=RSA.RtrId 
	--						       and SI.RtrShipId = RSA.RtrShipId
	--WHERE 
	--		UserId = @Pi_UsrId
	--GROUP BY 
	--		A.SalId,SalInvNo,SI.RtrId,RtrCode,RtrName,RSA.RtrShipAdd1,RSA.RtrShipAdd2,RSA.RtrShipAdd3,
	--		A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,UserId
-- End here
		/*  Final Output Table */
	INSERT INTO RptUnloadingSheet  
	SELECT 
			PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP, 0 As PrdUnitSelRate,
			Sum(LoadBilledQty) LoadBilledQty,
			SUm(LoadFreeQty) LoadFreeQty,
			SUm(LoadReplacementQty) LoadReplacementQty,
			Sum(UnLoadSalQty) UnLoadSalQty,
			Sum(UnLoadUnSalQty) UnLoadUnSalQty,
			Sum(UnLoadOfferQty) UnLoadOfferQty,
			UserId
	FROM 
			#RptUnloadingSheet
	WHERE 
			UserId = @Pi_UsrId
	GROUP BY 
			PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,UserId
			/* ---------- Update UnLoaded Saleable Qty  in RptUnloadingSheet Table ----------*/
					/*  Latest  Version  */
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #Tmp1000
	FROM (
					/* SalesInvoiceProduct table */
			SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty
			FROM SalesInvoiceProduct 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId,SalId
					/* Replacement table */
			UNION ALL
			SELECT SalId,PrdId,PrdBatId,Sum(RepQty) BaseQty
			FROM ReplacementHd R,ReplacementOut  Ro 
			WHERE  R.RepRefNo = RO.RepRefNo 
				   AND Ro.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 1) 
				   AND  SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				   AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId	,SalId	)  X 
	GROUP BY PrdId,PrdBatId,SalId
--
--
--SELECT B.SalId,B.PrdId,B.PrdBatId,SUM(BaseQty) BaseQty, VersionNo
--			FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
--			WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
--				   AND UserId  = @Pi_UsrId	AND TransactionFlag = 4 
--				   AND StockType = 1 
--				   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
--										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
--			GROUP BY B.SalId,B.PrdId,B.PrdBatId,VersionNo
				/*  Base  Version  */
	SELECT SalId,PrdId,PrdBatId,BaseQty INTO #Tmp1001
	FROM (
		SELECT A.SalId,A.PrdId,A.PrdBatId,Max(BaseQty) BaseQty 
		FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
		WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
			   AND UserId  = @Pi_UsrId	AND TransactionFlag = 1 And A.VehicleId>0
			   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
		GROUP BY A.SalId,A.PrdId,A.PrdBatId
		UNION ALL
		SELECT SalId,PrdId,PrdBatId,mAX(BaseQty) BaseQty
		FROM (
			SELECT A.SalId,A.PrdId,A.PrdBatId,SUM(BaseQty) BaseQty, VersionNo
			FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
			WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
				   AND UserId  = @Pi_UsrId	AND TransactionFlag = 4  
				   AND StockType = 1 AND B.LoadReplaceMentQty>0
				   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdBatId,VersionNo ) C
		GROUP BY SalId,PrdId,PrdBatId ) X			  
	GROUP BY SalId,PrdId,PrdBatId,BaseQty
		/*	Compare Base AND Latest Version */
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #FinalUnLoadSal
	FROM (
			SELECT PrdId,PrdBatId,Sum(BaseQty)BaseQty
			FROM #Tmp1000
			GROUP BY PrdId,PrdBatId
			UNION ALL	
			SELECT PrdId,PrdBatId,Sum(-BaseQty) BaseQty
			FROM #Tmp1001
			GROUP BY PrdId,PrdBatId ) X
	GROUP BY PrdId,PrdBatId
	--Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
-- Added on 10-Jun-2010
	--SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #FinalUnLoadSal_New
	--FROM (
	--		SELECT SalId,PrdId,PrdBatId,Sum(BaseQty)BaseQty
	--		FROM #Tmp1000
	--		GROUP BY SalId,PrdId,PrdBatId
	--		UNION ALL	
	--		SELECT SalId,PrdId,PrdBatId,Sum(-BaseQty) BaseQty
	--		FROM #Tmp1001
	--		GROUP BY SalId,PrdId,PrdBatId ) X
	--GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadSalQty =  Abs(BaseQty)
	--FROM  RptUnloadingSheet_Excel A,#FinalUnLoadSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- End here
	UPDATE RptUnloadingSheet SET UnLoadSalQty =  Abs(BaseQty)
			FROM  RptUnloadingSheet a,#FinalUnLoadSal B
			WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId -------AND BaseQty >= 0 
	
--Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
			/*  Update Market Return Saleable  */
	SELECT DISTINCT SR.SalId,Rp.PrdId,RP.PrdBatId,Rp.BaseQty INTO #Tmp1003
	FROM SalesInvoiceMarketReturn SR,#RptUnloadingSheet A,
	     ReturnHeader RH,ReturnProduct RP
	WHERE A.SalId = SR.SalID AND SR.ReturnId = RH.ReturnID
			AND RH.ReturnID = RP.ReturnID  AND A.PrdId = RP.PrdId AND A.PrdBatId = Rp.PrdBatId
			AND RP.StockTypeId in (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 1)
			AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
					WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRSal
	FROM #Tmp1003
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadSalQty = UnLoadSalQty + BaseQty
	FROM  RptUnloadingSheet a,#TempMRSal B
	WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRSal_New
	FROM #Tmp1003
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadSalQty = UnLoadSalQty + BaseQty
	--FROM RptUnloadingSheet_Excel A,#TempMRSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- End here
			/*	Till Here  */
		/* ---------- Update UnLoaded UnSaleable Qty in RptUnloadingSheet Table ----------*/
			/*  Update Market Return UnSaleable  */
	SELECT DISTINCT SR.SalId,Rp.PrdId,RP.PrdBatId,Rp.BaseQty INTO #Tmp1004
	FROM SalesInvoiceMarketReturn SR,#RptUnloadingSheet A,
			ReturnHeader RH,ReturnProduct RP
	WHERE A.SalId = SR.SalID AND SR.ReturnId = RH.ReturnID
			AND RH.ReturnID = RP.ReturnID  AND A.PrdId = RP.PrdId AND A.PrdBatId = Rp.PrdBatId
			AND RP.StockTypeId in (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2)
			AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
					WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRUnSal
	FROM #Tmp1004
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadUnSalQty = UnLoadUnSalQty + BaseQty
	FROM  RptUnloadingSheet a,#TempMRUnSal B
	WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRUnSal_New
	FROM #Tmp1004
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadUnSalQty = UnLoadUnSalQty + BaseQty
	--FROM  RptUnloadingSheet_Excel A,#TempMRUnSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
-- End here
		/*	Till Here  */
		/* ---------- Update UnLoaded Free Qty  in RptUnloadingSheet Table ----------*/
			
						/* SalesInvoiceProduct table Manual Free */
		SELECT SalId,PrdId,PrdbatId,Sum(BaseQty) BaseQty INTO #TempLat1006
		FROM (
			SELECT DISTINCT SalId,PrdId,PrdBatId,Sum(SalManFreeQty) BaseQty
			FROM SalesInvoiceProduct 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
			AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId,SalId
			UNION ALL
							/* SalesInvoiceFree table Free */
			SELECT DISTINCT SalId,FreePrdId,FreePrdBatId,Sum(FreeQty)  FreeQty
			FROM SalesInvoiceSchemeDtFreePrd 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY FreePrdId,FreePrdBatId,SalId	
			UNION ALL
							/* Market Return Table Scheme Free */
			SELECT DISTINCT SR.SalId,RF.FreePrdId,RF.FreePrdBatId,Sum(RF.ReturnFreeQty) BaseQty
			FROM 	ReturnSchemeFreePrdDt RF,ReturnHeader RH,SalesInvoiceMarketReturn SR
			WHERE	SR.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
					AND RH.ReturnID = RF.ReturnId  AND RH.ReturnID = SR.ReturnId
					AND SR.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY SR.SalId,RF.FreePrdId,RF.FreePrdBatId
			UNION ALL
							/* Market Return Offer  */
			SELECT DISTINCT SR.SalId,RF.PrdId,RF.PrdBatId,Sum(RF.BaseQty) BaseQty
			FROM 	ReturnProduct RF,ReturnHeader RH,SalesInvoiceMarketReturn SR
			WHERE	SR.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
					AND RH.ReturnID = RF.ReturnId  AND RH.ReturnID = SR.ReturnId
					AND RF.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 3)
				    AND SR.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY SR.SalId,RF.PrdId,RF.PrdBatId
			UNION ALL
							/* Replacement Offer */
			SELECT DISTINCT RH.SalId,Ro.PrdId,Ro.PrdBatId,Sum(Ro.RepQty) BaseQty
			FROM ReplacementHd RH,ReplacementOut RO
			WHERE RH.RepRefNo = RO.RepRefNo
				  AND RH.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND Ro.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 3)
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY RH.SalId,Ro.PrdId,Ro.PrdBatId	) y
		GROUP BY SalId,PrdId,PrdBatId		
					/*  Base  Version  */
					/* Scheme */
		SELECT SalId,PrdId,PrdbatId,Sum(BaseQty) BaseQty INTO #Tmpbase1007
		FROM (
			SELECT DISTINCT A.SalId,A.PrdId,A.PrdbatId,Max(BaseQty) BaseQty
			FROM SalesInvoiceModificationHistory  a, #RptUnloadingSheet B
			WHERE TransactionFlag = 2 AND A.SalId = B.SalId
				  AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
				  AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdbatId		
			UNION All
			SELECT DISTINCT A.SalId,A.PrdId,A.PrdbatId,Max(BaseQty) BaseQty
			FROM SalesInvoiceModificationHistory  a, #RptUnloadingSheet B
			WHERE TransactionFlag = 4 AND A.SalId = B.SalId
					AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
					AND StockType = 3
					AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdbatId		) Z
		GROUP BY SalId,PrdId,PrdbatId	
		/* Update Free in RptUnLoadingSheet Table */
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempUnLFree
	FROM (
		SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty 
		FROM #TempLat1006
		GROUP BY PrdId,PrdBatId
		UNION All
		SELECT PrdId,PrdBatId,Sum(-BaseQty) BaseQty  
		FROM #Tmpbase1007
		GROUP BY PrdId,PrdBatId ) h
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadFreeQty = Abs(UnLoadFreeQty) + Abs(BaseQty)
			FROM  RptUnloadingSheet a,#TempUnLFree B
			WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempUnLFree_New
	FROM (
		SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty 
		FROM #TempLat1006
		GROUP BY SalId,PrdId,PrdBatId
		UNION All
		SELECT SalId,PrdId,PrdBatId,Sum(-BaseQty) BaseQty  
		FROM #Tmpbase1007
		GROUP BY SalId,PrdId,PrdBatId 
	     ) h
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadFreeQty = Abs(UnLoadFreeQty) + Abs(BaseQty)
	--FROM RptUnloadingSheet_Excel A, #TempUnLFree_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
-- End here
					/*   Update Cancel Bill Saleable - */
							/* Saleable Qty */
		SELECT PrdId,PrdBatId,Sum(BilledQty) BilledQty INTO #TempCancelBilledQty
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadBilledQty) AS BilledQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY  PrdId,PrdBatId
		UPDATE RptUnloadingSheet SET UnLoadSalQty =  UnLoadSalQty + BilledQty
						FROM RptUnloadingSheet a, #TempCancelBilledQty B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(BilledQty) BilledQty INTO #TempCancelBilledQty_New
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadBilledQty) AS BilledQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY SalId,PrdId,PrdBatId
		--UPDATE A SET UnLoadSalQty =  UnLoadSalQty + BilledQty
		--FROM RptUnloadingSheet_Excel A, #TempCancelBilledQty_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
-- End here
							
				/*   Update Cancel Bill Offer - */
							/* Offer Qty */
		SELECT PrdId,PrdBatId,Sum(FreeQty) FreeQty INTO #TempCancelFree
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadFreeQty) AS FreeQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY  PrdId,PrdBatId				
		UPDATE RptUnloadingSheet SET UnLoadFreeQty = UnLoadFreeQty + FreeQty
						FROM RptUnloadingSheet a, #TempCancelFree B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(FreeQty) FreeQty INTO #TempCancelFree_New
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadFreeQty) AS FreeQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY SalId,PrdId,PrdBatId	
			
		--UPDATE A SET UnLoadFreeQty = UnLoadFreeQty + FreeQty
		--FROM RptUnloadingSheet_Excel a, #TempCancelFree_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
-- Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
-- End here
						/*   Update Cancel Bill UnSaleable - */
					/*	Canceled Bill -- Market UnSaleable  */
		SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempCancelUnSal
				FROM (	
					SELECT 	D.PrdId,D.PrdBatId,Sum(BaseQty) BaseQty  
					FROM	SalesInvoice A ,SalesInvoiceMarketReturn B, #RptUnloadingSheet C,
							ReturnProduct D,ReturnHeader E
					WHERE	 DlvSts = 3 AND A.SalId = B.SalId	AND B.SalId = C.SalId
							 AND A.SalId = C.SalId  AND B.ReturnId = E.ReturnID  AND D.ReturnID = E.ReturnID
							 AND D.PrdId = C.PrdId  AND D.PrdBatId = C.PrdBatId
							 AND D.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2) 
							 AND UserId  = @Pi_UsrId 
					GROUP BY D.PrdId,D.PrdBatId 
					) v
				GROUP By	PrdId,PrdbatId
				/* Update in Calcel Bill Qty UnSaleable */
				UPDATE RptUnloadingSheet SET UnLoadUnSalQty = 0 ------UnLoadUnSalQty - BaseQty
						FROM RptUnloadingSheet a, #TempCancelUnSal B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempCancelUnSal_New
		FROM (	
			SELECT C.SalId,D.PrdId,D.PrdBatId,Sum(BaseQty) BaseQty  
			FROM SalesInvoice A ,SalesInvoiceMarketReturn B, #RptUnloadingSheet C,
					ReturnProduct D,ReturnHeader E
			WHERE DlvSts = 3 AND A.SalId = B.SalId	AND B.SalId = C.SalId
					 AND A.SalId = C.SalId  AND B.ReturnId = E.ReturnID  AND D.ReturnID = E.ReturnID
					 AND D.PrdId = C.PrdId  AND D.PrdBatId = C.PrdBatId
					 AND D.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2) 
					 AND UserId  = @Pi_UsrId 
			GROUP BY C.SalId,D.PrdId,D.PrdBatId 
			) v
		GROUP By SalId,PrdId,PrdbatId
		/* Update in Calcel Bill Qty UnSaleable */
		--UPDATE A SET UnLoadUnSalQty = 0 ------UnLoadUnSalQty - BaseQty
		--FROM RptUnloadingSheet_Excel A, #TempCancelUnSal_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
		--UPDATE A SET Reason=[Description] FROM RptUnloadingSheet_Excel A,ReturnProduct RP,ReasonMaster R 
		--WHERE A.SalId=RP.SalId AND RP.ReasonId=R.ReasonId AND A.PrdId=RP.PrdId AND A.PrdBatId=RP.PrdBatId
-- End here
--Added by Praveenraj B for Parle CR--Display in Qty
	
					Create Table #PrdUom1 
					(
					PrdId Int,
					ConversionFactor Int
					)
					
					SELECT Prdid,Conversionfactor Into #PrdUom from Product P 
						INNER JOIN UomGroup UG ON UG.UomgroupId=P.UomgroupId
						INNER JOIN UomMaster U ON U.UomId=UG.UOMId						
						--WHERE U.UomCode='BX'--Commented and added by Rajesh ICRSTPAR3196
						WHERE U.UomCode IN ('BX','BOX')
						
	--Select * from UomMaster				
					SELECT Prdid,Conversionfactor Into #PrdUom2 from Product P 
						INNER JOIN UomGroup UG ON UG.UomgroupId=P.UomgroupId
						INNER JOIN UomMaster U ON U.UomId=UG.UOMId
						WHERE U.UomCode NOT IN ('BX','BOX') And PrdId Not In (Select PrdId From #PrdUom) And BaseUom='Y'
						--WHERE U.UomCode<>'BX' And PrdId Not In (Select PrdId From #PrdUom) And BaseUom='Y'
					Insert Into #PrdUom1
					Select Distinct Prdid,Conversionfactor From #PrdUom
					Union All
					Select Distinct Prdid,Conversionfactor From #PrdUom2
	
					Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
					INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
					SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptUnloadingSheet WHERE UserId =@Pi_UsrId
					SELECT ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
					CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN 0 ELSE LoadBilledQty/MAX(ConversionFactor) END As LoadBilledQtyBOX,
				    CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN LoadBilledQty ELSE LoadBilledQty%MAX(ConversionFactor) END As LoadBilledQtyPKTS,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE LoadFreeQty/MAX(ConversionFactor)END As LoadFreeQtyBOX,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN LoadFreeQty ELSE LoadFreeQty%MAX(ConversionFactor) END As LoadFreeQtyPKTS,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN 0 ELSE LoadReplacementQty/MAX(ConversionFactor)END LoadReplacementQtyBOX,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN LoadReplacementQty ELSE LoadReplacementQty%MAX(ConversionFactor) END As LoadReplacementQtyPKTS,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadSalQty/MAX(ConversionFactor)END AS UnLoadSalQtyBOX,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN UnLoadSalQty ELSE UnLoadSalQty%MAX(ConversionFactor) END As UnLoadSalQtyPKTS,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadUnSalQty/MAX(ConversionFactor)END AS UnLoadUnSalQtyBOX,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN UnLoadUnSalQty ELSE UnLoadUnSalQty%MAX(ConversionFactor) END As UnLoadUnSalQtyPKTS,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadFreeQty/MAX(ConversionFactor)END AS UnLoadFreeQtyBOX,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN UnLoadFreeQty ELSE UnLoadFreeQty%MAX(ConversionFactor) END As UnLoadFreeQtyPKTS,
					UserId
					FROM RptUnloadingSheet ST INNER JOIN #PrdUom1 P ON P.Prdid=ST.Prdid
					Where UserId=@Pi_UsrId And 
					(LoadBilledQty+LoadFreeQty+LoadReplacementQty+UnLoadSalQty+UnLoadUnSalQty+UnLoadFreeQty)>0
					GROUP BY  ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
					LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId
					Order By PrdDcode
					
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
				BEGIN
					IF EXISTS (SELECT [Name] FROM SysObjects WHERE [Name]='RptUnloadingSheet_Excel' And XTYPE='U')
					Drop Table RptUnloadingSheet_Excel
					SELECT ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
					CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN 0 ELSE LoadBilledQty/MAX(ConversionFactor) END As LoadBilledQtyBOX,
				    CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN LoadBilledQty ELSE LoadBilledQty%MAX(ConversionFactor) END As LoadBilledQtyPKTS,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE LoadFreeQty/MAX(ConversionFactor)END As LoadFreeQtyBOX,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN LoadFreeQty ELSE LoadFreeQty%MAX(ConversionFactor) END As LoadFreeQtyPKTS,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN 0 ELSE LoadReplacementQty/MAX(ConversionFactor)END LoadReplacementQtyBOX,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN LoadReplacementQty ELSE LoadReplacementQty%MAX(ConversionFactor) END As LoadReplacementQtyPKTS,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadSalQty/MAX(ConversionFactor)END AS UnLoadSalQtyBOX,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN UnLoadSalQty ELSE UnLoadSalQty%MAX(ConversionFactor) END As UnLoadSalQtyPKTS,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadUnSalQty/MAX(ConversionFactor)END AS UnLoadUnSalQtyBOX,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN UnLoadUnSalQty ELSE UnLoadUnSalQty%MAX(ConversionFactor) END As UnLoadUnSalQtyPKTS,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadFreeQty/MAX(ConversionFactor)END AS UnLoadFreeQtyBOX,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN UnLoadFreeQty ELSE UnLoadFreeQty%MAX(ConversionFactor) END As UnLoadFreeQtyPKTS,
					UserId INTO RptUnloadingSheet_Excel
					FROM RptUnloadingSheet ST INNER JOIN #PrdUom1 P ON P.Prdid=ST.Prdid
					Where UserId=@Pi_UsrId And 
					(LoadBilledQty+LoadFreeQty+LoadReplacementQty+UnLoadSalQty+UnLoadUnSalQty+UnLoadFreeQty)>0
					GROUP BY  ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
					LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId
					Order By PrdDcode
					  
				End	
		-- Till Here
	END
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_RptECAnalysisReportParle' AND XTYPE='P')
DROP PROCEDURE Proc_RptECAnalysisReportParle
GO
/*
BEGIN TRANSACTION
EXEC Proc_RptECAnalysisReportParle 252,1,0,'Dabur1',0,0,3   
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_RptECAnalysisReportParle
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
/**********************************************************************************  
* PROCEDURE  : Proc_RptECAnalysisReport  
* PURPOSE  : To Generate Effective Coverage Analysis Report  
* CREATED  : Thiruvengadam.L  
* CREATED DATE : 10/09/2009  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------------------------------------------  
* {date}  {developer}   {brief modification description}  
* 30.09.2009    Thiruvengadam  Bug No:20729  
* 11.03.2010    Panneer        Added Excel Table  
* 14.07.2014    Jai Ganesh R   Retailer Hierarchy Filter Issue Fixed
**********************************************************************************/  
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
 DECLARE @RtId  AS  INT  
 DECLARE @FromDate AS DATETIME  
 DECLARE @ToDate  AS DATETIME  
 DECLARE @SMId   AS INT  
 DECLARE @RMId   AS INT  
 DECLARE @RtrId   AS INT  
 DECLARE @BasedOn AS  INT  
 DECLARE @CmpId  AS INT  
 DECLARE @RtrCtgLvl AS INT  
 DECLARE @RtrCtgLvlVal AS INT  
 DECLARE @RtrValClass AS INT  
 DECLARE @RtrGroup  AS INT  
 DECLARE @PrdHieLvl  AS INT  
 DECLARE @PrdHieLvlVal AS INT  
 DECLARE @PrdId   AS INT  
 DECLARE @PrdCatId  AS INT
 DECLARE @RetCatId  AS INT
 SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
 SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
 SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
 SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))  
 SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))  
 SET @RtrCtgLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))  
 SET @RtrCtgLvlVal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))  
 SET @RtrValClass = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))  
 SET @RtrGroup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,215,@Pi_UsrId))   
 SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))  
 SET @PrdHieLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))  
 SET @PrdHieLvlVal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))  
 SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
 SET @BasedOn = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,246,@Pi_UsrId))  
 SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
 PRINT @BasedOn  
 EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
 SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
 SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
 EXEC Proc_ReturnRptRetailerCategory @Pi_RptId,@Pi_UsrId  
 SET @RetCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId))  
 SELECT DISTINCT Prdid,U.ConversionFactor   
 Into #PrdUomBox  
 FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid  
 Inner Join UomMaster UM On U.UomId=Um.UomId  
 --Where Um.UomCode='BX'  
 Where Um.UomCode IN ('BX'  ,'BOX')
 
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
 CREATE TABLE #AnalysisReportRoute  
 (  
  RMId INT,  
  RMName NVarchar(100),  
  TotalOutlet INT,  
 )  
 INSERT INTO #AnalysisReportRoute (RMId,RMName,TotalOutlet)  
 SELECT Distinct C.RMId,C.RmName,Count(A.RtrId) FROM Retailer A,RetailerMarket B,RouteMaster C   
 WHERE A.RtrId = B.RtrId AND B.RmId = C.RmId And A.RtrStatus = 1   
 GROUP BY C.RmId,C.RmName Order By C.RMName  
 CREATE TABLE #AnalysisReportSales  
 (  
  RMId INT,  
  RMName NVarchar(100),  
  TotalBilled INT,  
 )  
 IF @BasedOn = 1 OR @BasedOn = 3  
 BEGIN  
  UPDATE RptExcelHeaders Set DisplayFlag = 0 Where RptId = 243 And SlNo in (3,4)   
 END  
 IF @BasedOn = 2  
 BEGIN    
  UPDATE RptExcelHeaders Set DisplayFlag = 1 Where RptId = 243 And Slno in (3,4)  
 END   
 Create TABLE #RptECAnalysis  
 (  
         PrdId               INT,  
   Code   NVARCHAR(200),  
   Name         NVARCHAR(200),    
   TotalOutlets   INT,  
   TotalOutletBilled   INT,  
   SalableQty          INT,  
   SalesValue       NUMERIC(38,6),    
   EC        INT,  
   TLS        INT,  
   BasedOn             INT   
 )  
 SET @TblName = 'RptECAnalysis'  
 SET @TblStruct = 'RouteCode    NVARCHAR(200),  
       RouteName             NVARCHAR(200),    
       TotalOutlets       INT,  
       TotalOutletBilled     INT,  
       SalableQty            INT,     
       EC        INT,  
       TLS        INT'  
 SET @TblFields = 'RouteCode,RouteName,TotalOutlets,TotalOutletBilled,SalableQty,EC,TLS'  
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
 IF @Pi_GetFromSnap = 0  
 BEGIN   
     IF @BasedOn = 1  
     BEGIN  
		   INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)  
		   SELECT P.PrdId,P.PrdDCode as Code,P.PrdName AS Name,'','',SUM(SIP.BaseQty) AS Unit,SUM(SIP.PrdGrossAmount) AS SalesValue,Count(Distinct(SI.RtrId)) AS EC,COUNT(SIP.Prdid) AS TLS,@BasedOn   
		   FROM Product P (NOLOCK),ProductBatch PB(NOLOCK),SalesInvoice SI(NOLOCK),SalesInvoiceProduct SIP(NOLOCK),Company C(NOLOCK),Salesman S(NOLOCK),RouteMaster RM(NOLOCK),
		   Retailer R(NOLOCK),
		   --RetailerCategorylevel RCL,
		   RetailerValueClassMap RVCM(NOLOCK),
		   RetailerValueClass RVC(NOLOCK),
		   RetailerCategory RC(NOLOCK),  
		   
		   --RetailerCategorylevel RCV,
		   ProductCategoryLevel PCL(NOLOCK),
		   ProductCategoryValue PCV(NOLOCK)
		   WHERE 
		   SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId AND PB.PrdId=P.PrdId AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND 
		   --RCV.CtgLevelId=RC.CtgLevelId  
		   SI.SalInvDate BETWEEN @FromDate AND @ToDate AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId  AND 
		   SI.SMId=S.SMId AND SI.RMId=RM.RMId AND 
		   RVCM.RtrId=SI.RtrId AND
		   RVCM.RtrValueClassId=RVC.RtrClassId AND
		   RVC.CtgMainId=RC.CtgMainId  AND 
		   --AND RC.CtgLevelId=RCL.CtgLevelId    
		   PCV.PrdCtgValMainId=P.PrdCtgValMainId AND SI.DlvSts NOT IN (1,3) --Added by Thiru on 30.09.2009 for Bug No:20729  
		     
		   AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR  
		   P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
		   AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR  
		   SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
		   AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR  
		   SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
		   AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR  
		   SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
		   
		   --AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR  
		   --RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
		   
		   AND (RC.CtgMainId = (CASE @RetCatId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
		   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId)))  
		   
		   AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
		   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
		   
		   AND (P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR  
			 P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
		     
		   AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR  
			  P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
		   GROUP BY P.PrdDCode,P.PrdName,P.PrdId  
		   
    END    
    ELSE IF @BasedOn = 2  
    BEGIN   
           INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)  
		   SELECT P.Prdid,RM.RMCode as Code,RM.RMName AS Name,'','',SUM(SIP.BaseQty),SUM(SIP.PrdGrossAmount) AS SalesValue,  
		   SI.rtrid AS EC,Count(SI.rmid) AS TLS,@BasedOn 
		   FROM Product P(NOLOCK),ProductBatch PB(NOLOCK),SalesInvoice SI(NOLOCK),  
		   SalesInvoiceProduct SIP(NOLOCK),Company C(NOLOCK),Salesman S(NOLOCK),RouteMaster RM(NOLOCK),
		   
		   Retailer R(NOLOCK),
		   RetailerValueClassMap RVCM(NOLOCK),
		   RetailerValueClass RVC(NOLOCK),
		   RetailerCategory RC(NOLOCK),  
		   --RetailerCategorylevel RCL,
		   --RetailerCategorylevel RCV,
		   
		   ProductCategoryValue PCV(NOLOCK),ProductCategoryLevel PCL(NOLOCK)
		   WHERE 
		   
		   SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId AND PB.PrdId=P.PrdId  AND 
		   SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND 
		   RVCM.RtrId=SI.RtrId AND 
		   RVCM.RtrValueClassId=RVC.RtrClassId  AND
		   RVC.CtgMainId=RC.CtgMainId  AND 
		   --RCV.CtgLevelId=RC.CtgLevelId  
		   SI.SalInvDate BETWEEN @FromDate AND @ToDate AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId  
		   AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND 
		   
		   
		   --RVC.CtgMainId=RC.CtgMainId  AND 
		   --RC.CtgLevelId=RCL.CtgLevelId AND 
		   
		   PCV.PrdCtgValMainId=P.PrdCtgValMainId AND SI.DlvSts NOT IN (1,3) --Added by Thiru on 30.09.2009 for Bug No:20729  
		   
		   AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR  
		   P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
		   AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR  
		   SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
		   AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR  
		   SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
		   AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR  
		   SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
		   --AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR  
		   --RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
		   AND (RC.CtgMainId = (CASE @RetCatId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
		   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId))) 
		    
		   AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
		   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
		   AND (P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR  
		   P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
		     
		   AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR  
		   P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
		   GROUP BY RM.RMCode,RM.RMName,P.Prdid,SI.rtrid  
     END  
     ELSE IF @BasedOn = 3  
     BEGIN  
			INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)  
			SELECT P.PrdId,R.RtrCode As Code,R.RtrName AS Name,'','',SUM(SIP.BaseQty),SUM(SIP.PrdGrossAmount) AS SalesValue, SI.SalId AS EC,Count(SI.RtrId) AS TLS,@BasedOn  
			FROM Product P (Nolock) ,ProductBatch PB (Nolock),SalesInvoice SI (Nolock),  
			SalesInvoiceProduct SIP (Nolock),Company C (Nolock),Salesman S (Nolock),  
			Retailer R (Nolock),    
			RouteMaster RM (Nolock),  
			RetailerValueClassMap RVCM(NOLOCK),  
			RetailerValueClass RVC (Nolock),
			RetailerCategory RC(NOLOCK),
		    
			--RetailerCategorylevel RCV (Nolock),  
			--RetailerCategorylevel RCL,
		    
			ProductCategoryValue PCV (Nolock),    
			ProductCategoryLevel PCL (Nolock) 
		     
			 WHERE SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId  
			AND PB.PrdId=P.PrdId AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND 
			--RCV.CtgLevelId=RC.CtgLevelId  
			SI.SalInvDate BETWEEN @FromDate AND @ToDate  
			AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId  
			AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND 
			RVCM.RtrId=SI.RtrId AND
			RVCM.RtrValueClassId=RVC.RtrClassId  AND 
			RVC.CtgMainId=RC.CtgMainId AND   
		    
			--AND RC.CtgLevelId=RCL.CtgLevelId      
			PCV.PrdCtgValMainId=P.PrdCtgValMainId  
			AND SI.DlvSts NOT IN (1,3) --Added by Thiru on 30.09.2009 for Bug No:20729  
			AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR  
			  P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
			AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR  
			  SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
			AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR  
			  SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
			AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR  
			  SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
			--AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR  
			--  RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
			AND (RC.CtgMainId = (CASE @RetCatId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
			  RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId)))  
		    
			AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
			  RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
			AND (P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR  
			  P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))     
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR  
			   P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
		   GROUP BY  
			R.RtrCode,R.RtrName,P.PrdId,SI.SalId           
       END      
  IF LEN(@PurDBName) > 0  
  BEGIN  
   SET @SSQL = 'INSERT INTO #RptECAnalysis ' +  
    '(' + @TblFields + ')' +  
    ' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
    + 'AND  CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '  
    + 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '  
    + 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'  
    + 'AND RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '  
    + 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '  
    + 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND CtgLevelId = (CASE ' + CAST(@RtrCtgLvl AS nVarchar(10)) + ' WHEN 0 THEN CtgLevelId ELSE 0 END) OR '  
    + 'CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',29,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND CtgMainId = (CASE ' + CAST(@RtrCtgLvlVal AS nVarchar(10)) + ' WHEN 0 THEN CtgMainId ELSE 0 END) OR '  
    + 'CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',30,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND RtrClassId = (CASE ' + CAST(@RtrValClass AS nVarchar(10)) + ' WHEN 0 THEN RtrClassId Else 0 END) OR '  
    + 'RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',31,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'+  
    + 'AND P.PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN P.PrdId Else 0 END) OR '  
    + 'P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'  
    + 'AND P.PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN P.PrdId Else 0 END) OR '  
    + 'P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'  
    +' Salinvdate BETWEEN ''' + Convert(Varchar(10),@FromDate,121) + ''' AND ''' + Convert(Varchar(10),@ToDate,121) + ''''  
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
    ' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptECAnalysis'  
   EXEC (@SSQL)  
   PRINT 'Saved Data Into SnapShot Table'  
  END  
 END  
 ELSE    --To Retrieve Data From Snap Data  
 BEGIN  
  EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
   @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
  PRINT @ErrNo  
  IF @ErrNo = 0  
  BEGIN  
   SET @SSQL = 'INSERT INTO #RptECAnalysis ' +  
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
 DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
 INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
 SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptECAnalysis  
      SELECT DISTINCT A.Prdid,Code,Name,TotalOutlets,TotalOutletBilled,  
      Case When SUM(SalableQty) < MAX(ConversionFactor) Then 0 Else SUM(SalableQty) / MAX(ConversionFactor) End  As SaleableBOX,  
      Case When SUM(SalableQty) < MAX(ConversionFactor) Then SUM(SalableQty) Else SUM(SalableQty) % MAX(ConversionFactor) End As SaleablePKT,  
      SUM(SalesValue)AS SalesValue,EC,TLS,BasedOn INTO #EffectiveRoute FROM #RptECAnalysis A,#PrdUomAll B WHERE A.PrdId = B.PrdId    
      GROUP BY A.Prdid,Code,Name,TotalOutlets,TotalOutletBilled,EC,TLS,BasedOn HAVING SUM(SalableQty) <> 0 ORDER BY Name  
    IF @BasedOn = 1  
    BEGIN  
       SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,  
    EC,TLS,BasedOn FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn,EC,TLS Order By Name  
          IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')  
       DROP TABLE RptECAnalysisReportParle_Excel  
    SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,  
    EC,TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn,EC,TLS Order By Code     
 END   
 ELSE        
 IF @BasedOn = 2  
 BEGIN   
      SELECT DISTINCT Code,Name,B.TotalOutlet AS TotalOutlets,Count(Distinct (EC))As TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) AS SaleablePKT,SUM(SalesValue) AS SalesValue,  
      Count(Distinct (EC)) AS EC,SUM(TLS) AS TLS,BasedOn from #EffectiveRoute A,#AnalysisReportRoute B   
      WHERE A.Name = B.RMName   
      GROUP BY Code,Name,B.TotalOutlet,BasedOn ORDER BY Code     
         IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')  
      DROP TABLE RptECAnalysisReportParle_Excel  
      SELECT DISTINCT Code,Name,B.TotalOutlet AS TotalOutlets,Count(Distinct (EC)) As TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) AS SaleablePKT,SUM(SalesValue) AS SalesValue,  
      Count(Distinct (EC)) AS EC,SUM(TLS) AS TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute A,#AnalysisReportRoute B   
      WHERE A.Name = B.RMName GROUP BY Code,Name,B.TotalOutlet,BasedOn ORDER BY Code  
 END  
 ELSE   
 BEGIN  
       SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,  
    Count(Distinct(EC)) AS EC,SUM(TLS) AS TLS,BasedOn FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn Order By Name  
          IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')  
       DROP TABLE RptECAnalysisReportParle_Excel  
    SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,  
    Count(Distinct(EC)) AS EC,SUM(TLS) AS TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn Order By Code     
 END  
   RETURN  
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_RptCurrentStockParle' AND XTYPE='P')
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
	--Where Um.UomCode='BX'
	Where Um.UomCode IN ('BX','BOX')
	
	INSERT Into #PrdUomBox		
	SELECT DISTINCT Prdid,U.ConversionFactor
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	INNER JOIN UomMaster UM On U.UomId=Um.UomId
	Where  P.PrdId Not In (Select PrdId From #PrdUomBox) AND U.ConversionFactor > 1
			
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
			
			--select 'A',* from #PrdWeight
			
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
				FROM dbo.View_CurrentStockReportParle VC LEFT OUTER JOIN #PrdWeight P ON VC.PrdId = P.PrdId 
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
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
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_CodeUnificationOldProduct_StockPosing' AND xtype='P')
DROP PROCEDURE Proc_CodeUnificationOldProduct_StockPosing
GO
/*
BEGIN TRANSACTION
--select * from PRODUCTBATCHLOCATION(NOLOCK) where PRDID in (select PrdId from StockLedger(NOLOCK) where transdate='2016-09-13')
--select * from StockLedger(NOLOCK) where transdate='2016-09-13'
EXEC Proc_CodeUnificationOldProduct_StockPosing 0
--select * from PRODUCTBATCHLOCATION(NOLOCK) where PRDID in (select PrdId from StockLedger(NOLOCK) where transdate='2016-09-13')
select * from StockLedger(NOLOCK) where transdate='2016-09-13'
EXEC Proc_CodeUnificationOldProduct_StockPosing 0
SELECT * FROM STOCKMANAGEMENT WHERE STKMNGDATE='2016-09-13'
SELECT b.prdstatus,B.*,* FROM STOCKMANAGEMENTPRODUCT a inner join product b on a.prdid=b.prdid WHERE a.LASTMODDATE='2016-09-13' AND STKMGMTTYPEID=1
SELECT b.prdstatus,B.*,* FROM STOCKMANAGEMENTPRODUCT a inner join product b on a.prdid=b.prdid WHERE a.LASTMODDATE='2016-09-13' AND STKMGMTTYPEID=2
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CodeUnificationOldProduct_StockPosing
(
       @Po_ErrNo INT OUTPUT
)
AS
/*****************************************************************************
* PROCEDURE      : Proc_CodeUnificationOldProduct_StockPosing
* PURPOSE        : To Mapped the Sub Products to Main Products
* CREATED BY     : S.Moorthi
* MODIFIED       :
* DATE      AUTHOR     DESCRIPTION
* {DATE} {DEVELOPER}  {BRIEF MODIFICATION DESCRIPTION}
*******************************************************************************/
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo = 0
DECLARE @ToPrdId     AS NUMERIC(18,0)
DECLARE @PrdId       AS NUMERIC(18,0)
DECLARE @PrdBatId    AS NUMERIC(18,0)
DECLARE @ToPrdBatId  AS NUMERIC(18,0)
DECLARE @LcnId       AS BIGINT
DECLARE @SalTotQty   AS NUMERIC(18,0)
DECLARE @UnSalTotQty AS NUMERIC(18,0)
DECLARE @OfferTotQty AS NUMERIC(18,0)
DECLARE @SalQty      AS NUMERIC(18,0)
DECLARE @UnSalQty    AS NUMERIC(18,0)
DECLARE @OfferQty    AS NUMERIC(18,0)
DECLARE @InvDate     AS DATETIME
DECLARE @LcnIdCheck AS INT
DECLARE @Pi_ErrNo AS TINYINT
DECLARE @Pi_PrdbatLcn AS TINYINT
DECLARE @Pi_StkLedger AS TINYINT
DECLARE @MaxNo as INT
DECLARE @MinNo as INT
DECLARE @CurrValue AS BIGINT
DECLARE @StkKeyNumber AS VARCHAR(50)
DECLARE @iDecPoint AS INT
DECLARE @iRate AS Numeric(18,6)
DECLARE @UomId AS INT
DECLARE @SalPriceId AS BIGINT
DECLARE @StockTypeId AS INT
DECLARE @iReduceRate AS Numeric(18,6)
DECLARE @ReduceSalPriceId AS BIGINT
DECLARE @ReduceUomId AS INT

	CREATE TABLE #Location
	(
		Slno INT IDENTITY (1,1),
		LcnId INT
	)	
	
	
	BEGIN TRY					
		   BEGIN TRANSACTION
						
				--Mapped Products Stock Posting
				SELECT DISTINCT D.PrdId AS ToPrdId,A.PrdId,PrdBatId,LcnId,(PrdBatLcnSih-PrdBatLcnRessih) AS SalStock,
				(PrdBatLcnUih-PrdBatLcnResUih) AS UnSalStock,(PrdBatLcnFre-PrdBatLcnResFre) AS OfferStock INTO #ProductBatchLocation
				FROM ProductBatchLocation A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId
				INNER JOIN ProductUnification_Track C (NOLOCK) ON B.PrdCCode = C.MapProductCode
				INNER JOIN Product D (NOLOCK) ON C.ProductCode = D.PrdCCode 
				WHERE (PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre) > 0 
				AND B.PrdStatus<>1
			
				SELECT DISTINCT ToPrdId,ToPrdBatId INTO #ParentProductLatestBatch FROM #ProductBatchLocation A INNER JOIN
				(SELECT DISTINCT PrdId,MAX(PrdBatId) AS ToPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.ToPrdId = B.PrdId
				ORDER BY ToPrdId
				
				SELECT DISTINCT A.ToPrdId,ToPrdBatId,PrdId,PrdBatId,LcnId,SalStock,UnSalStock,OfferStock INTO #ManualStockPosting
				FROM #ProductBatchLocation A INNER JOIN #ParentProductLatestBatch B ON A.ToPrdId = B.ToPrdId
				ORDER BY A.ToPrdId,ToPrdBatId,PrdId,PrdBatId

				INSERT INTO #Location(LcnId)
				SELECT DISTINCT  LcnId FROM #ManualStockPosting WHERE ISNULL(LcnId,0)>0

				SET @Pi_ErrNo=0
				SET @Pi_PrdbatLcn=0
				SET @Pi_StkLedger=0
				SET @LcnIdCheck=0
				SET @MinNo=1
						
					SELECT @MaxNo= Max(Slno) FROM  #Location
					
					WHILE @MinNo<=@MaxNo
					BEGIN
							
								
								SELECT @LcnIdCheck=LcnId FROM #Location WHERE Slno=@MinNo
								
								SET @StkKeyNumber=''
								SELECT @CurrValue= Currvalue+1 FROM Counters (NOLOCK) WHERE TabName='StockManagement' AND FldName='StkMngRefNo'
								SELECT @StkKeyNumber=PreFix+CAST(SUBSTRING(CAST(CurYear as Varchar(10)),3,LEN(CurYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(@CurrValue)>ZPad THEN (ZPad+1)-LEN(@CurrValue) ELSE (ZPad)-LEN(@CurrValue)END)+CAST(@CurrValue as Varchar(10)) 	

								FROM Counters (NOLOCK) WHERE TabName='StockManagement' AND FldName='StkMngRefNo'
								
								SET @iDecPoint=2
								SELECT @iDecPoint=ConfigValue FROM Configuration WHERE Description='Calculation Decimal Digit Value' AND ModuleName='General Configuration'
								
								UPDATE  Counters SET CurrValue= CurrValue+1 WHERE TabName='StockManagement' AND FldName='StkMngRefNo'
								
								IF (@LcnIdCheck<=0 OR LEN(LTRIM(RTRIM(@StkKeyNumber)))<=0)
								BEGIN
									SET @Po_ErrNo=1												
									RETURN
									
								END
							
								IF (@LcnIdCheck>0 and LEN(LTRIM(RTRIM(@StkKeyNumber)))>0 )
								BEGIN						
									
									INSERT INTO StockManagement(StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,DecPoints,
									OpenBal,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate,ConfigValue,XMLUpload)				
									SELECT @StkKeyNumber,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),@LcnIdCheck,0,0,0,'','Product Code Unification ',@iDecPoint,
									0,1,1,1,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),1,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),1,0
									
									
									DECLARE CUR_STOCKADJIN CURSOR
									FOR SELECT DISTINCT ToPrdId,ToPrdBatId,LcnId,PrdId,PrdBatId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
									SUM(UnSalStock) AS UnSalTotStock,SUM(OfferStock) AS OfferTotStock FROM #ManualStockPosting WITH (NOLOCK)
									WHERE  LcnId=@LcnIdCheck
									GROUP BY ToPrdId,ToPrdBatId,LcnId,PrdId,PrdBatId ORDER BY ToPrdId,ToPrdBatId
									OPEN CUR_STOCKADJIN		
									FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@PrdId,@PrdBatId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
									WHILE @@FETCH_STATUS = 0
									BEGIN	
									
											SET @SalPriceId=0
											SET @iRate=0.00
											SET @UomId=0
											SET @StockTypeId=0
											
											SET @iReduceRate=0.00
											SET @ReduceSalPriceId=0
											SET @ReduceUomId=0
											
											SELECT @SalPriceId=ISNULL(PriceId,0),@iRate=PrdBatDetailValue 
											FROM Product A INNER JOIN Productbatch PB (NOLOCK) ON A.Prdid=PB.Prdid
											INNER JOIN BatchCreation B (NOLOCK) ON PB.BatchSeqId=B.BatchSeqId 
											INNER JOIN Productbatchdetails PBD (NOLOCK) ON PBD.PrdbatId= PB.Prdbatid and PBD.Slno=B.Slno
											WHERE PB.PrdbatId= @ToPrdBatId and   DefaultPrice=1 and  ListPrice=1  and A.PrdId=@ToPrdId
											
											SELECT @UomId=UomId FROM Uomgroup U (NOLOCK) INNER JOIN Product P (NOLOCK) ON U.UomgroupId=P.UomGroupId
											WHERE Prdid=@ToPrdId and BaseUom='Y' 
											
											
											SELECT @ReduceSalPriceId=ISNULL(PriceId,0),@iReduceRate=PrdBatDetailValue 
											FROM Product A INNER JOIN Productbatch PB (NOLOCK) ON A.Prdid=PB.Prdid
											INNER JOIN BatchCreation B (NOLOCK) ON PB.BatchSeqId=B.BatchSeqId 
											INNER JOIN Productbatchdetails PBD (NOLOCK) ON PBD.PrdbatId= PB.Prdbatid and PBD.Slno=B.Slno
											WHERE PB.PrdbatId= @PrdBatId and   DefaultPrice=1 and  ListPrice=1
											and A.PrdId=@PrdId
											SELECT @ReduceUomId=UomId FROM Uomgroup U (NOLOCK) INNER JOIN Product P (NOLOCK) ON U.UomgroupId=P.UomGroupId
											WHERE Prdid=@PrdId and BaseUom='Y' 
									
											IF @SalTotQty > 0 
											BEGIN
												SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=1
													
												INSERT INTO StockManagementproduct(							
												StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
												UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
												AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
												SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@SalTotQty,0,0,@SalTotQty,
												@iRate,@iRate*@SalTotQty,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
												
												SET @Pi_ErrNo=0
												SET @Pi_PrdbatLcn=0	
												SET @Pi_StkLedger=0					
												--SALEABLE STOCK IN									
												EXEC Proc_UpdateStockLedger 10,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
												EXEC Proc_UpdateProductBatchLocation 1,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT		
												
												
												IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
												BEGIN												
													SET @Po_ErrNo=1
													CLOSE CUR_STOCKADJIN
													DEALLOCATE CUR_STOCKADJIN
													ROLLBACK TRANSACTION
													RETURN
												END
												
												--SALEABLE STOCK OUT																													
												INSERT INTO StockManagementproduct(							
												StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
												UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
												AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
												SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@SalTotQty,0,0,@SalTotQty,
												@iReduceRate,@iReduceRate*@SalTotQty,0,@ReduceSalPriceId,1,111,@InvDate,1,@InvDate,0.00,2
												
										
												
												SET @Pi_ErrNo=0
												SET @Pi_PrdbatLcn=0	
												SET @Pi_StkLedger=0	
												
												EXEC Proc_UpdateStockLedger 13,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
												EXEC Proc_UpdateProductBatchLocation 1,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT	
												
												IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
												BEGIN
																					
													SET @Po_ErrNo=1
													CLOSE CUR_STOCKADJIN
													DEALLOCATE CUR_STOCKADJIN
													ROLLBACK TRANSACTION
													RETURN
												END
												--TILL HERE
												
											END
											IF @UnSalTotQty > 0
											BEGIN
											
											
												SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=2
													
												INSERT INTO StockManagementproduct(							
												StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
												UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
												AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
												SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@UnSalTotQty,0,0,@UnSalTotQty,
												@iRate,@iRate*@UnSalTotQty,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
												
												
												SET @Pi_ErrNo=0
												SET @Pi_PrdbatLcn=0	
												SET @Pi_StkLedger=0	
											   --UNSALEABLE STOCK IN									
												EXEC Proc_UpdateStockLedger 11,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
												EXEC Proc_UpdateProductBatchLocation 2,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
												
												IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
												BEGIN
													
													SET @Po_ErrNo=1
													CLOSE CUR_STOCKADJIN
													DEALLOCATE CUR_STOCKADJIN
													ROLLBACK TRANSACTION
													RETURN
												END
													
												--UNSALEABLE STOCK OUT
												INSERT INTO StockManagementproduct(							
												StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
												UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
												AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
												SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@UnSalTotQty,0,0,@UnSalTotQty,
												@iReduceRate,@iReduceRate*@UnSalTotQty,0,@ReduceSalPriceId,1,111,@InvDate,1,@InvDate,0.00,2
												
																											
												SET @Pi_ErrNo=0
												SET @Pi_PrdbatLcn=0	
												SET @Pi_StkLedger=0	
												
												EXEC Proc_UpdateStockLedger 14,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
												EXEC Proc_UpdateProductBatchLocation 2,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
												
												IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
												BEGIN
													
													SET @Po_ErrNo=1
													CLOSE CUR_STOCKADJIN
													DEALLOCATE CUR_STOCKADJIN
													ROLLBACK TRANSACTION
													RETURN
												END
												
												--Till HERE		
													
											END
											IF @OfferTotQty > 0 
											BEGIN
												
												SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=3
													
												INSERT INTO StockManagementproduct(							
												StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
												UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
												AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
												SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@OfferTotQty,0,0,@OfferTotQty,
												0.00,0.00,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
												
											
												--OFFER STOCK IN
												SET @Pi_ErrNo=0
												SET @Pi_PrdbatLcn=0	
												SET @Pi_StkLedger=0
																					
												EXEC Proc_UpdateStockLedger 12,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
												EXEC Proc_UpdateProductBatchLocation 3,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
												IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
												BEGIN
													
													SET @Po_ErrNo=1
													CLOSE CUR_STOCKADJIN
													DEALLOCATE CUR_STOCKADJIN
													ROLLBACK TRANSACTION
													RETURN
												END
												
												--OFFER STOCK OUT
												
												INSERT INTO StockManagementproduct(							
												StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
												UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
												AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
												SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@OfferTotQty,0,0,@OfferTotQty,
												0.00,0.00,0,0,1,111,@InvDate,1,@InvDate,0.00,2
												
												
												
												SET @Pi_ErrNo=0
												SET @Pi_PrdbatLcn=0	
												SET @Pi_StkLedger=0
												
												EXEC Proc_UpdateStockLedger 15,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
												EXEC Proc_UpdateProductBatchLocation 3,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
												
												IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
												BEGIN
													
													SET @Po_ErrNo=1
													CLOSE CUR_STOCKADJIN
													DEALLOCATE CUR_STOCKADJIN
													ROLLBACK TRANSACTION
													RETURN
												END
												
											END
											
											--SELECT 'X',* from ProductBatchLocation (NOLOCK) where PrdId=@ToPrdId and prdbatId=@ToPrdBatId and LcnId=@LcnId
											--SELECT 'Y',* from ProductBatchLocation (NOLOCK) where PrdId=@PrdId and prdbatId=@PrdBatId and LcnId=@LcnId
											--SELECT 'X',* from StockLedger (NOLOCK) where PrdId=@ToPrdId and prdbatId=@ToPrdBatId and LcnId=@LcnId and TransDate=@InvDate
											--SELECT 'Y',* from StockLedger (NOLOCK) where PrdId=@PrdId and prdbatId=@PrdBatId and LcnId=@LcnId and TransDate=@InvDate
													
									FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@PrdId,@PrdBatId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
									END
									CLOSE CUR_STOCKADJIN
									DEALLOCATE CUR_STOCKADJIN
									--Till Here

								END	
								
								
						SET @MinNo=@MinNo+1	
					END					
					
									
				COMMIT TRANSACTION	
						
	END TRY
	BEGIN CATCH
		SET @Po_ErrNo=1
		--select ERROR_MESSAGE()
		CLOSE CUR_STOCKADJIN
		DEALLOCATE CUR_STOCKADJIN		
		ROLLBACK TRAN	
	END CATCH    
	RETURN
END
GO
EXEC Proc_CodeUnificationOldProduct_StockPosing 0
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Validate_Product' AND xtype='P')
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
				
				--Added By S.Moorthi 19-02-2016 PMS No.: CCRSTPAR0128
				IF EXISTS(SELECT A.PrdId FROM Product A (NOLOCK) INNER JOIN ProductBatchLocation B (NOLOCK) ON A.PrdId=B.PrdId 
				WHERE A.PrdCCode=@PrdCCode AND B.PrdBatLcnSih+B.PrdBatLcnUih+B.PrdBatLcnFre+B.PrdBatLcnRessih+B.PrdBatLcnResUih+B.PrdBatLcnResFre>0)
				BEGIN
					SET @PrdStatus=1
				END
				--Till Here			
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
					
					--Added By Sathishkumar Veeramani 2014/07/14 ContractPricing Details Updated
					DELETE A FROM ContractPricingDetails A (NOLOCK) INNER JOIN ContractPricingMaster B (NOLOCK) ON A.ContractId = B.ContractId
					WHERE B.DisplayMode = 1 AND A.PrdId = @PrdId
					
					INSERT INTO ContractPricingDetails (ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,Availability,
					LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId,ClaimablePercOnMRP)
					SELECT DISTINCT ContractId,PrdId,0 AS PrdBatId,0 AS PriceId,Discount,FlatAmtDisc,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),
					1,CONVERT(NVARCHAR(10),GETDATE(),121),CtgValMainId,0 AS ClaimablePercOnMRP FROM (
					SELECT DISTINCT MAX(A.ContractId) AS ContractId,CtgLevelId,CtgMainId,RtrClassId,E.PrdId,Discount,
					FlatAmtDisc,B.CtgValMainId FROM ContractPricingMaster A (NOLOCK) 
					INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId = B.ContractId
					INNER JOIN ProductCategoryValue C (NOLOCK) ON A.CmpPrdCtgId = C.CmpPrdCtgId AND B.CtgValMainId = C.PrdCtgValMainId
					INNER JOIN ProductCategoryValue D (NOLOCK) ON D.PrdCtgValLinkCode LIKE C.PrdCtgValLinkCode+'%'
					INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
					WHERE A.DisplayMode = 1 AND E.PrdId = @PrdId GROUP BY CtgLevelId,CtgMainId,RtrClassId,E.PrdId,Discount,FlatAmtDisc,B.CtgValMainId)Qry
					--Added By Sathishkumar Veeramani 2014/07/14 Till Here
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
					UPDATE Product SET  SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,PrdShelfLife=@ShelfLife,
					PrdStatus=@PrdStatus,EanCode=@EANCode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
					/*UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,PrdShelfLife=@ShelfLife,
					PrdStatus=@PrdStatus,EanCode=@EANCode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
					*/
				END
				ELSE
				BEGIN
					UPDATE Product SET  SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name ='Proc_RptBillTemplateFinal' and XTYPE='P')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--EXEC PROC_RptBillTemplateFinal 16,3,0,'PARLE',0,0,1,'RPTBT_VIEW_FINAL1_BILLTEMPLATE'
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
* 01.10.2009		Panneer						Added Tax summary Report Part(UserId Condition)
* 10/07/2015		PRAVEENRAJ BHASKARAN	    Added Grammge For Parle
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
		    SELECT 'A',@vFieldName
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
		EXEC('CREATE TABLE RptBillTemplateFinal
		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')
	END
	ELSE
	BEGIN
		EXEC('CREATE TABLE RptBillTemplateFinal
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
		DELETE FROM RptBillTemplateFinal Where UsrId = @Pi_UsrId
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
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD SalesmanPhoneNo NUMERIC (18,0) DEFAULT 0 WITH VALUES 
		END		
		
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD Grammage NUMERIC (38,2) DEFAULT 0 WITH VALUES 
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
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.SalesmanPhoneNo=ISNULL(B.SMPhoneNumber,0) FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesMan B (NOLOCK) 
						ON A.[SalesMan Code]=B.SMCode AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END
--- Added by Rajesh ICRSTPAR3196
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='bx')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.bx=bx+box FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
			EXEC (@SSQL1)    
		END
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='PBG')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.PB=PB+PBG FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='TIN')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.Tn=TN+TIN FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
						       
			EXEC (@SSQL1)    
		END
		
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='TIF')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.TIF=TIF+TBX FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
						     
			EXEC (@SSQL1)    
		END
--Till here
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')    
		BEGIN 
					--SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK) 
					--				INNER JOIN (
					--					SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,ISNULL(
					--					CASE U.PRDUNITID WHEN 2 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0)/1000
					--					WHEN 3 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0) END,0) AS Grammage
					--					FROM RptBillTemplateFinal SP (NOLOCK)
					--					INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]
					--					INNER JOIN PRODUCTUNIT U (NOLOCK) ON P.PrdUnitId=U.PrdUnitId
					--					WHERE SP.USRID=
					--					GROUP BY P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,U.PRDUNITID,SP.[Sales Invoice Number]
					--				) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''					    
					SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK) 
									INNER JOIN (
										SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,P.PrdWgt Grammage
										FROM RptBillTemplateFinal SP (NOLOCK)
										INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]
										WHERE SP.USRID='+CAST(@Pi_UsrId AS VARCHAR(10))+'
									) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''					    
									
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name ='Proc_RptLoadSheetItemWiseParle' AND XTYPE ='P')
DROP PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
CREATE PROCEDURE Proc_RptLoadSheetItemWiseParle
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
/************************************************************    
* CREATED BY : Gunasekaran    
* CREATED DATE : 18/07/2007    
* NOTE  :    
* MODIFIED :    
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
* {date} {developer}  {brief modification description}    
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012    
* 02/07/2013 Jisha Mathew PARLECS/0613/008     
* 11/11/2013 Jisha Mathew Bug No:30616    
*01/09/2016 Rajesh Ranjan Added BOX UOM ICRSTPAR3196
* 28/09/2016	Sowmya S.R Added CMB.
*02/11/2016 Rajesh Ranjan Added UOM NUMBER,BAG,TIFFIN BOX,BAR,TBX
*************************************************************/    
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
 --Added by Sathishkumar Veeramani 2013/04/25    
 DECLARE @Prdid AS INT    
 DECLARE @PrdCode AS Varchar(50)    
 DECLARE @PrdBatchCode AS Varchar(50)    
 DECLARE @UOMSalId AS INT    
 DECLARE @BaseQty AS INT    
 DECLARE @FUOMID AS INT    
 DECLARE @FCONVERSIONFACTOR AS INT    
 DECLARE @StockOnHand AS INT    
 DECLARE @Converted AS INT    
 DECLARE @Remainder AS INT    
 DECLARE @COLUOM AS VARCHAR(50)    
 DECLARE @Sql AS VARCHAR(5000)    
 DECLARE @SlNo AS INT    
 --Till Here    
 --Jisha    
 DECLARE @TotConverted AS INT    
 DECLARE @TotRemainder AS INT     
 DECLARE @TotalQty as INT     
 --    
 --Filter Variable    
 DECLARE @FromDate    AS DATETIME    
 DECLARE @ToDate      AS DATETIME    
 DECLARE @VehicleId     AS  INT    
 DECLARE @VehicleAllocId AS INT    
 DECLARE @SMId   AS INT    
 DECLARE @DlvRouteId AS INT    
 DECLARE @RtrId   AS INT    
 DECLARE @UOMId   AS INT    
 DECLARE @FromBillNo AS  BIGINT    
 DECLARE @ToBillNo   AS  BIGINT    
 DECLARE @SalId   AS     BIGINT    
    DECLARE @OtherCharges AS NUMERIC(18,2)       
 --DECLARE @BillNoDisp   AS INT    
 --DECLARE @DispOrderby AS INT    
 --Till Here    
 EXEC Proc_RptItemWise @Pi_RptId ,@Pi_UsrId    
 --Assgin Value for the Filter Variable    
 SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))    
 SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))    
 SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))    
 SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))    
 SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))    
 SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))    
 SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))    
 SET @UOMId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,129,@Pi_UsrId))    
 SET @FromBillNo =(SELECT  MIN(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))    
 SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))    
 SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))     
 --SET @DispOrderby=(SELECT TOP 1 iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))    
 --Till Here    
 --DECLARE @RPTBasedON AS INT    
 --SET @RPTBasedON =0    
 --SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId)     
 SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)     
 CREATE TABLE #RptLoadSheetItemWiseParle1    
 (    
   [SalId]      INT,    
   [BillNo]    NVARCHAR (100),  
   [PrdId]               INT,    
   [PrdBatId]     INT,    
   [Product Code]        NVARCHAR (100),    
   [Product Description] NVARCHAR(150),    
   [PrdCtgValMainId]   INT,     
   [CmpPrdCtgId]    INT,    
   [Batch Number]        NVARCHAR(50),    
   [MRP]      NUMERIC (38,6) ,    
   [Selling Rate]    NUMERIC (38,6) ,    
   [Billed Qty]          NUMERIC (38,0),    
   [Free Qty]            NUMERIC (38,0),    
   [Return Qty]          NUMERIC (38,0),    
   [Replacement Qty]     NUMERIC (38,0),    
   [Total Qty]           NUMERIC (38,0),    
   [PrdWeight]     NUMERIC (38,4),    
   [PrdSchemeDisc]    NUMERIC (38,2),    
   [GrossAmount]    NUMERIC (38,2),    
   [TaxAmount]     NUMERIC (38,2),    
   [NetAmount]     NUMERIC (38,2),    
   [TotalBills]    NUMERIC (38,0),    
   [TotalDiscount]    NUMERIC (38,2),    
   [OtherAmt]     NUMERIC (38,2),    
   [AddReduce]     NUMERIC (38,2),    
   [Damage]              NUMERIC (38,2),    
   [BX]                  NUMERIC (38,0),
   [PB]                  NUMERIC (38,0),    
   [JAR]      NUMERIC (38,0),    
   [PKT]                 NUMERIC (38,0),    
   [CN]      NUMERIC (38,0),    
   [GB]                  NUMERIC (38,0),    
   [ROL]                 NUMERIC (38,0),    
   [TOR]                 NUMERIC (38,0),    
   [CTN]         NUMERIC (38,0),    
   [TN]         NUMERIC (38,0),    
   [CAR]         NUMERIC (38,0),    
   [PC]         NUMERIC (38,0),
   [CMB]         NUMERIC (38,0),  
   [BOX]                  NUMERIC (38,0), 
   [PBG]                  NUMERIC (38,0),    
   [TIN]                  NUMERIC (38,0),     
   
   [TIF]  NUMERIC (38,0), 
   [TBX]  NUMERIC (38,0),
   [BAR]  NUMERIC (38,0),
   [NOS]  NUMERIC (38,0),
   [BAG]  NUMERIC (38,0),
   [TotalQtyBX]          NUMERIC (38,0),
   [TotalQtyPB]          NUMERIC (38,0),    
   [TotalQtyPKT]         NUMERIC (38,0),    
   [TotalQtyJAR]         NUMERIC (38,0),    
   [TotalQtyCN]    NUMERIC (38,0),    
   [TotalQtyGB]          NUMERIC (38,0),    
   [TotalQtyROL]         NUMERIC (38,0),    
   [TotalQtyTOR]         NUMERIC (38,0),    
   [TotalQtyCTN]         NUMERIC (38,0),    
   [TotalQtyTN]         NUMERIC (38,0),    
   [TotalQtyCAR]         NUMERIC (38,0),    
   [TotalQtyPC]         NUMERIC (38,0),  
   [TotalQtyBOX]          NUMERIC (38,0), 
   [TotalQtyPBG]                  NUMERIC (38,0), 
   [TotalQtycmb]         NUMERIC (38,0),   
   [TotalQtyTIN]                  NUMERIC (38,0),
   [TotalQtyTIF]  NUMERIC (38,0), 
   [TotalQtyTBX]  NUMERIC (38,0),
   [TotalQtyBAR]  NUMERIC (38,0),
   [TotalQtyNOS]  NUMERIC (38,0),
   [TotalQtyBAG]  NUMERIC (38,0)          
 )    
 --IF @Pi_GetFromSnap = 0  --To Generate For New Report Data    
 --BEGIN    
  IF @FromBillNo <> 0 Or @ToBillNo <> 0    
  BEGIN    
   INSERT INTO #RptLoadSheetItemWiseParle1([SalId],[BillNo],[PrdId],[PrdBatId],[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],    
    [Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],    
    [TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[BOX],[PBG],[TIN],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TN],[CAR],[PC],CMB, 
	[TIF],[TBX],[BAR],[NOS],[BAG],       
    [TotalQtyBOX],[TotalQtyTIN],[TotalQtyPBG],[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],[TotalQtyCTN],    
    [TotalQtyTN],[TotalQtyCAR],[TotalQtyPC],[TotalQtycmb],[TotalQtyTIF],[TotalQtyTBX],[TotalQtyBAR],[TotalQtyNOS],[TotalQtyBAG])--select * from RtrLoadSheetItemWise    
   SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,    
   [PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],    
   dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],    
   Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM RtrLoadSheetItemWise RI    
   LEFT OUTER JOIN SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId    
   WHERE    
 RptId = @Pi_RptId and UsrId = @Pi_UsrId and    
 (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR    
     VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )    
  AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR    
     Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )    
  AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR    
     SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))    
  AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR    
   DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )    
  AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR    
     RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )    
  AND [SalInvDate] Between @FromDate and @ToDate    
    AND RI.SalId Between @FromBillNo and @ToBillNo    
----     
-- AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR     
--       RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))    
 GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],    
 NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId    
  END     
  ELSE    
  BEGIN    
   INSERT INTO #RptLoadSheetItemWiseParle1([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],    
     [Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],    
     [TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[BOX],[PBG],[TIN],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TN],[CAR],[PC],CMB, 
     [TIF],[TBX],[BAR],[NOS],[BAG],   
     [TotalQtyBoX],[TotalQtyTIN],[TotalQtyPBG],[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],    
     [TotalQtyCTN],[TotalQtyTN],[TotalQtyCAR],[TotalQtyPC],TotalQtycmb,[TotalQtyTIF],[TotalQtyTBX],[TotalQtyBAR],[TotalQtyNOS],[TotalQtyBAG])    
   SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),    
   BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,    
   dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],    
   ISNULL((SUM([TaxAmount])+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,0,0,    
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM RtrLoadSheetItemWise RI --select * from RtrLoadSheetItemWise    
   LEFT OUTER JOIN SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId    
   WHERE    
   RptId = @Pi_RptId and UsrId = @Pi_UsrId and    
   (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR    
       VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )    
    AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR    
       Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )    
    AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR    
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))    
    AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR    
       DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )    
    AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR    
       RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )    
   AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR    
     RI.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )    
   AND [SalInvDate] BETWEEN @FromDate AND @ToDate    
   GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,    
   GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId    
   ORDER BY PrdDCode    
  END      
  --Select '#RptLoadSheetItemWiseParle1',* From #RptLoadSheetItemWiseParle1 Where PrdId IN(6079,6093)
  UPDATE #RptLoadSheetItemWiseParle1 SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle1)    
-----Added By Sathishkumar Veeramani OtherCharges    
      ---Changed By Jisha for Bug No:30616    
               --SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2    
               SELECT @OtherCharges = ISNULL((SUM(B.TaxAmount)+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0)     
               FROM SalesInvoice A WITH (NOLOCK),RtrLoadSheetItemWise B WITH (NOLOCK)    
               LEFt OUTER JOIN SalesInvoiceProduct C WITH (NOLOCK) ON B.SalId = C.SalId     
    AND B.PrdId=C.PrdId And B.PrdBatId=C.PrdBatId    
               WHERE A.SalId = B.SalId AND B.SalInvDate Between @FromDate and @ToDate AND DlvSts = 2 AND UsrID = @Pi_UsrId AND RptId = @Pi_RptId    
               AND                  
   (B.VehicleId = (CASE @VehicleId WHEN 0 THEN B.VehicleId ELSE 0 END) OR    
       B.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )    
    AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR    
       Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )    
    AND (B.SMId=(CASE @SMId WHEN 0 THEN B.SMId ELSE 0 END) OR    
       B.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))    
    AND (B.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN B.DlvRMId ELSE 0 END) OR    
       B.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )    
    AND (B.RtrId = (CASE @RtrId WHEN 0 THEN B.RtrId ELSE 0 END) OR    
       B.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )    
   AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR    
     B.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )    
               UPDATE #RptLoadSheetItemWiseParle1 SET AddReduce = @OtherCharges     
     --Select '#RptLoadSheetItemWiseParleUpdate',* From #RptLoadSheetItemWiseParle1 Where PrdId IN(6079,6093)
-------Added By Sathishkumar Veeramani Damage Goods Amount---------     
   UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle1 R INNER JOIN    
  (SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP     
   WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B    
   ON R.SalId = B.SalId AND R.PrdId = B.PrdId     
  AND R.PrdBatId = B.PrdBatId    
  Update #RptLoadSheetItemWiseParle1 Set [Batch Number] = '',PrdBatId = 0 --Code Added by Muthuvelsamy R for DCRSTPAR0510    
------Till Here--------------------      
----Added By Jisha On 02/07/2013 for PARLECS/0613/008     
SELECT 0 AS [SalId],'' AS BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],    
[Batch Number] AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],SUM([Billed Qty]) as [Billed Qty],SUM([Free Qty]) as [Free Qty],SUM([Return Qty]) as [Return Qty],    
SUM([Replacement Qty]) AS [Replacement Qty],SUM([Total Qty]) AS [Total Qty],SUM(PrdWeight) AS PrdWeight,SUM(PrdSchemeDisc) AS PrdSchemeDisc,    
SUM(GrossAmount) AS GrossAmount,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,TotalBills,SUM(TotalDiscount) AS TotalDiscount,    
SUM(OtherAmt) AS OtherAmt,SUM(DISTINCT AddReduce) AS Addreduce,SUM([Damage])AS [Damage],0 AS[BX],0 AS[BOX],0 [PBG],0 [TIN],0 AS [PB],0 AS [JAR],0 AS [PKT],0 AS [CN],    
0 AS [GB],0 AS [ROL],0 AS [TOR],0 AS [CTN],0 AS [TN],0 AS [CAR],0 AS [PC],0 as CMB, 0 as [TIF],0 as [TBX],0 as [BAR],0 as [NOS],0 as [BAG],   
0 AS TotalQtyBOX,0 AS [TotalQtyTIN],0 AS [TotalQtyPBG],0 AS TotalQtyBX,0 AS TotalQtyPB,0 AS TotalQtyPKT,0 AS TotalQtyJAR,0 AS [TotalQtyCN],0 AS [TotalQtyGB],0 AS [TotalQtyROL],0 AS [TotalQtyTOR],    
0 AS [TotalQtyCTN],0 AS [TotalQtyTN],0 AS [TotalQtyCAR],0 AS [TotalQtyPC],0 AS TotalQtycmb ,0 AS [TotalQtyTIF],0 AS [TotalQtyTBX],0 AS [TotalQtyBAR],0 AS [TotalQtyNOS],0 AS [TotalQtyBAG]   
INTO #RptLoadSheetItemWiseParle FROM #RptLoadSheetItemWiseParle1    
GROUP BY PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],TotalBills    
-----    
--Added by Sathishkumar Veeramani 2013/04/25      
 DECLARE CUR_UOMQTY CURSOR     
 FOR    
  SELECT P.PrdId,Rpt.[Product Code],[Batch Number],SUM([Billed Qty]) AS [Billed Qty],SUM([Total Qty]) AS [Total Qty] FROM #RptLoadSheetItemWiseParle Rpt WITH (NOLOCK)    
  INNER JOIN Product P WITH (NOLOCK) ON  Rpt.PrdId=P.PrdId GROUP BY P.PrdId,Rpt.[Product Code],[Batch Number]      
 OPEN CUR_UOMQTY    
 FETCH NEXT FROM CUR_UOMQTY INTO @PrdId,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty    
 WHILE @@FETCH_STATUS=0    
 BEGIN     
   SET @Converted=0    
   SET @Remainder=0       
   SET @TotConverted=0    
   SET @TotRemainder=0        
   DECLARE CUR_UOMGROUP CURSOR    
   FOR     
   SELECT DISTINCT UOMID,CONVERSIONFACTOR FROM (    
   SELECT A.UOMID,CONVERSIONFACTOR FROM UOMMASTER A WITH (NOLOCK)     
   INNER JOIN UOMGROUP B WITH (NOLOCK) ON A.UomId = B.UomId INNER JOIN PRODUCT C WITH (NOLOCK)    
   ON C.UOMGROUPID=B.UOMGROUPID WHERE PRDID=@PrdId AND A.UOMCODE IN ('BOX','BX','GB','CN','PB','JAR','TOR','PKT','ROL','CTN','TN','PC','CAR','CMB','TIN','PBG'
   ,'TIF','TBX','BAR','NOS','BAG')) UOM ORDER BY CONVERSIONFACTOR DESC     
   OPEN CUR_UOMGROUP    
   FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR    
   WHILE @@FETCH_STATUS=0    
   BEGIN     
     SELECT @COLUOM=UOMCODE FROM UomMaster WITH (NOLOCK) WHERE UOMID=@FUOMID    
     IF @BaseQty >= @FCONVERSIONFACTOR    
     BEGIN    
      SET @Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)    
      SET @Remainder=CAST(@BaseQty%@FCONVERSIONFACTOR AS INT)    
      SET @BaseQty=@Remainder           
      SET @Sql='UPDATE #RptLoadSheetItemWiseParle  SET [' + @COLUOM +']='+ CAST(ISNULL(@Converted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+''''     
      EXEC(@Sql)    
     END     
     ELSE      
     BEGIN    
      SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [' + @COLUOM +']='+ CAST(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+''''     
      EXEC(@Sql)    
     END    
     ----Added By Jisha On 02/07/2013 for PARLECS/0613/008     
     IF @TotalQty >= @FCONVERSIONFACTOR    
     BEGIN          
      SET @TotConverted=CAST(@TotalQty/@FCONVERSIONFACTOR as INT)    
      SET @TotRemainder=CAST(@TotalQty%@FCONVERSIONFACTOR AS INT)    
      SET @TotalQty=@TotRemainder            
      SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM + ']= '+ CAST(ISNULL(@TotConverted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+''''     
      EXEC(@Sql)    
     END     
     ELSE      
     BEGIN    
      SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM +']='+ Cast(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+''''     
      EXEC(@Sql)    
     END         
     --         
   FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR    
   END     
   CLOSE CUR_UOMGROUP    
   DEALLOCATE CUR_UOMGROUP    
   SET @BaseQty=0    
   SET @TotalQty=0    
 FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty    
 END     
 CLOSE CUR_UOMQTY    
 DEALLOCATE CUR_UOMQTY    
------SELECT [PrdId],[PrdBatId],[Product Code],[Product Description],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],    
------[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR]    
------FROM #RptLoadSheetItemWiseParle    
 ---Commented By Jisha on 02/07/2013 for PARLECS/0613/008    
 ----UPDATE A SET A.TotalQtyBX = Z.TotalBox,A.TotalQtyPB = Z.TotalPouch,A.TotalQtyPKT = Z.TotalPacks FROM #RptLoadSheetItemWiseParle A WITH (NOLOCK)    
 ----INNER JOIN (SELECT PrdID,PrdBatId,SUM(BX) AS TotalBox,SUM(PB)+SUM(JAR) AS TotalPouch,SUM(PKT) AS TotalPacks     
 ----FROM #RptLoadSheetItemWiseParle WITH (NOLOCK)GROUP BY PrdID,PrdBatId) Z    
 ----ON A.PrdId = Z.PrdId AND A.PrdBatId = Z.PrdBatId    
--Till Here    
 --Check for Report Data    
    SELECT 0 AS [SalId],'' AS BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],    
    0 AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],([BX]+[GB]+[BOX]) AS BilledQtyBox,(([PB]+[PBG])+([JAR]+[CN]+[TOR]+[TN]+[TIN]+[CAR]+[BAG])) AS BilledQtyPouch,    
    ([PKT]+[ROL]+[CTN]+[PC]+[CMB]+[TIF]+[TBX]+[BAR]+[NOS]) AS BilledQtyPack,
    SUM([Total Qty]) AS [Total Qty],
    SUM(TotalQtyBoX+TotalQtyBX+TotalQtyGB) AS TotalQtyBOX,    
    SUM(TotalQtyPB+TotalQtyPBG+TotalQtyJAR+TotalQtyCN+TotalQtyTOR+TotalQtyTN+TotalQtyTIN+TotalQtyCAR+TotalQtyBag ) AS TotalQtyPouch,
    SUM(TotalQtyPKT+TotalQtyROL+TotalQtyCTN+TotalQtyPC+TotalQtyCmb+TotalQtyTIF+TotalQtyTBX+TotalQtyBAR+TotalQtyNOS) AS TotalQtyPack,    
    SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM([PrdWeight]) AS [PrdWeight],    
    SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) As PrdSchemeDisc,    
    SUM(TaxAmount) AS TaxAmount,SUM(NETAMOUNT) as NETAMOUNT,TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],    
    SUM([OtherAmt]) AS [OtherAmt],SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage] INTO #Result    
 FROM #RptLoadSheetItemWiseParle GROUP BY PrdId,[Product Code],[Product Description],[MRP],TotalBills,[PrdCtgValMainId],[CmpPrdCtgId],    
 [BX],[BOX],[PBG],[TIN],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TN],[CAR],[PC],CMB, [TIF],[TBX],[BAR],[NOS],[BAG]    
 ORDER BY [Product Description]   
 --Select '#Result',* From #Result Where PrdId IN(6079,6093)
 Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId    
 INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)    
 SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result 
 SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],    
  MRP,MAX([Selling Rate]) AS [Selling Rate],    
  SUM(BilledQtyBox) AS BilledQtyBox,SUM(BilledQtyPouch) AS BilledQtyPouch,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],    
  SUM(TotalQtyBox) AS TotalQtyBox,SUM(TotalQtyPouch) AS TotalQtyPouch,SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],    
  SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],    
  SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,    
  SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage]     
  INTO #TempLoadingSheet FROM #Result GROUP BY [SalId],BillNo,PrdId,[Product Code],[PRoduct Description],MRP,TotalBills    
  ORDER BY [Product Code]    
 SELECT * FROM #TempLoadingSheet    
 IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)      
 BEGIN    
  IF EXISTS (Select [Name] From SysObjects Where [Name]='RptLoadSheetItemWiseParle_Excel' And XTYPE='U')    
  Drop Table RptLoadSheetItemWiseParle_Excel    
     SELECT * INTO RptLoadSheetItemWiseParle_Excel FROM #TempLoadingSheet ORDER BY [Product Code]    
     --select * from RptLoadSheetItemWiseParle_Excel  
 END     
END
GO
--Till Here
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_RptDebitNoteTopSheet' AND xtype='P')
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
	WHERE UserId = @Pi_UsrId AND SlNo <> 0 and SlNo<>9999
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
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name ='Proc_AutoBatchTransfer' AND XTYPE='P')
DROP PROCEDURE Proc_AutoBatchTransfer
GO
CREATE PROCEDURE  Proc_AutoBatchTransfer
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
	
	--When Free Batch is downloaded last then stock is getting moved to Free batch. Added #FreeBatch--Rajesh on 21.12.2016 ICRSTPAR4195 
	
	SELECT DISTINCT Prdbatid INTO #FreeBatch FROM ProductBatchDetails(NOLOCK) GROUP BY Prdbatid HAVING SUM(PrdBatDetailValue)=0
	
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PrdId,PrdBatId,PrdBatCode FROM ProductBatch(NOLOCK)
	--WHERE PrdBatId >@Pi_OldMaxPrdBatId  ORDER BY PrdId,PrdBatId,PrdBatCode--Commented and added by Rajesh on 21.12.2016 ICRSTPAR4195 
	WHERE PrdBatId >@Pi_OldMaxPrdBatId AND PrdbatId NOT IN(Select Prdbatid FROM #FreeBatch)
	ORDER BY PrdId,PrdBatId,PrdBatCode
	---
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
		AND PBL.PrdbatId NOT IN(Select Prdbatid FROM #FreeBatch)--Added by Rajesh on 21.12.2016 ICRSTPAR4195 		
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
	
	--Added By rajesh To Inactivate Other batches except Downloaded batch & free Batch ICRSTPAR4148
	--DECLARE @MaxBatchId INT
	--SET @MaxBatchId =0
	--SELECT @MaxBatchId =MAX(PrdBatId) FROM  ProductBatch A(NOLOCK) WHERE PrdId =@PrdId AND PrdbatId NOT IN(Select Prdbatid FROM #FreeBatch)
	UPDATE A SET Status = 0 FROM  ProductBatch A(NOLOCK) WHERE PrdId =@PrdId AND PrdbatId NOT IN(Select Prdbatid FROM #FreeBatch)
	UPDATE A SET Status = 1 FROM  ProductBatch A(NOLOCK) WHERE PrdId =@PrdId AND PrdBatId =ISNULL(@PrdBatId ,0)
	--Till Here
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	
	RETURN	
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name ='Proc_UpdateStockLedger' AND XTYPE='P')
DROP PROCEDURE Proc_UpdateStockLedger
GO
CREATE Procedure  Proc_UpdateStockLedger
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
	BEGIN TRY --Code added by Muthuvel for Inventory check
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
						UPDATE ConsolidateStockLedger SET StockValue=  @CurVal + (SELECT DISTINCT StockValue FROM
						ConsolidateStockLedger WHERE TransDate=@MaxDate) WHERE TransDate=@Pi_TranDate
				END
		END
	/*Code added by Muthuvel for Inventory check begins here*/
	END TRY
	BEGIN CATCH
		SET @Pi_ErrNo = 1
	END CATCH
	/*Code added by Muthuvel for Inventory check ends here*/
	IF @Pi_ErrNo = 0
	BEGIN
		IF NOT EXISTS(SELECT * FROM StockLedgerDateCheck WHERE LastTransDate>=@Pi_TranDate)
		BEGIN
			TRUNCATE TABLE StockLedgerDateCheck 
			INSERT INTO StockLedgerDateCheck(LastColId,LastTransDate)
			VALUES(@Pi_ColId,@Pi_TranDate)
		END	
		-- Added by Rajesh to activate the batch having stock. ICRSTPAR4148
		IF EXISTS(SELECT 'X' FROM ProductBatch A (NOLOCK)INNER JOIN ProductBatchLocation B(NOLOCK) ON A.PrdId =B.PrdId AND A.PrdBatId =B.PrdBatID
					WHERE ((B.PrdBatLcnSih-B.PrdBatLcnRessih)+(B.PrdBatLcnUih-B.PrdBatLcnResUih)+(B.PrdBatLcnFre-B.PrdBatLcnResFre))>0 AND A.Status =0 )
		BEGIN 	
			UPDATE A SET A.Status =1 FROM ProductBatch A (NOLOCK)INNER JOIN ProductBatchLocation B(NOLOCK) ON A.PrdId =B.PrdId AND A.PrdBatId =B.PrdBatID
			WHERE ((B.PrdBatLcnSih-B.PrdBatLcnRessih)+(B.PrdBatLcnUih-B.PrdBatLcnResUih)+(B.PrdBatLcnFre-B.PrdBatLcnResFre))>0 AND A .Status =0
		END
		-- Till here 
	END
	RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name ='Proc_UpdateProductBatchLocation' AND XTYPE='P')
DROP PROCEDURE Proc_UpdateProductBatchLocation
GO
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
	BEGIN TRY --Code added by Muthuvel for Inventory check
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
	-- Added by Rajesh to activate the batch having stock. ICRSTPAR4148
		IF EXISTS(SELECT 'X' FROM ProductBatch A (NOLOCK)INNER JOIN ProductBatchLocation B(NOLOCK) ON A.PrdId =B.PrdId AND A.PrdBatId =B.PrdBatID
					WHERE ((B.PrdBatLcnSih-B.PrdBatLcnRessih)+(B.PrdBatLcnUih-B.PrdBatLcnResUih)+(B.PrdBatLcnFre-B.PrdBatLcnResFre))>0 AND A.Status =0 )
		BEGIN 	
			UPDATE A SET A.Status =1 FROM ProductBatch A (NOLOCK)INNER JOIN ProductBatchLocation B(NOLOCK) ON A.PrdId =B.PrdId AND A.PrdBatId =B.PrdBatID
			WHERE ((B.PrdBatLcnSih-B.PrdBatLcnRessih)+(B.PrdBatLcnUih-B.PrdBatLcnResUih)+(B.PrdBatLcnFre-B.PrdBatLcnResFre))>0 AND A .Status =0
		END
		-- Till here	
	/*Code added by Muthuvel for Inventory check begins here*/		
	END TRY
	BEGIN CATCH
		SET @Pi_ErrNo = 1
	END CATCH	
	/*Code added by Muthuvel for Inventory check ends here*/	
--print @Pi_ErrNo
RETURN
END
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.7' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.7',430
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 430)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(430,'D','2017-01-02',GETDATE(),1,'Core Stocky Service Pack 430')