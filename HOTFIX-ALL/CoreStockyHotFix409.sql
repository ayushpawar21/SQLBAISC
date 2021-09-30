--[Stocky HotFix Version]=409
DELETE FROM Versioncontrol WHERE Hotfixid='409'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('409','3.1.0.0','D','2013-10-21','2013-10-21','2013-10-21',CONVERT(varchar(11),GETDATE()),'Product Version-Major: Product Release August CR')
GO
IF NOT EXISTS (SELECT Name FROM Syscolumns WHERE ID IN (SELECT ID FROM sysobjects WHERE name = 'SpecialRateAftDownLoad' AND Xtype = 'U') 
AND Name ='DiscountPerc')
BEGIN
    ALTER TABLE SpecialRateAftDownLoad ADD DiscountPerc NUMERIC(18,6) DEFAULT 0 WITH VALUES
END
GO
--Month End Process
DELETE FROM Menudef WHERE MenuId IN ('mStk29','mStk30')
INSERT INTO Menudef (SrlNo,MenuId,MenuName,ParentId,Caption,MenuStatus,FormName,DefaultCaption)
SELECT 182,'mStk29','mnuDayendProcess','mStk','Day End Process',0,'FrmDayendProcess','Day End Process' UNION
SELECT 183,'mStk30','mnuMonthEndProcess','mStk','Month End Process',0,'FrmMonthEndPorcess','Month End Process'
GO
DELETE FROM ProfileDt WHERE MenuId IN ('mStk29','mStk30')
INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,'mStk29',0,'PerformDayEnd',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk29',1,'Edit',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk29',2,'Save',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk29',3,'Delete',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk29',6,'Print',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk29',7,'Load',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk30',0,'PerformDayEnd',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk30',1,'Edit',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk30',2,'Save',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk30',3,'Delete',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk30',6,'Print',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk30',7,'Load',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK)
GO
DELETE FROM CustomCaptions WHERE TransId = 276
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1,1,'CoreHeaderTool','Day End Process','','',1,1,1,'2009-04-28',1,'2009-04-28','Day End Process','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1,2,'CoreHeaderTool','Stocky','','',1,1,1,'2009-04-28',1,'2009-04-28','Stocky','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,1,'MsgBox-276-1000-1','','','Day End Updated Sucessfully',1,1,1,'2009-04-28',1,'2009-04-28','','','Day End Updated Sucessfully',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,2,'MsgBox-276-1000-2','','','Error While Update Day End',1,1,1,'2009-04-28',1,'2009-04-28','','','Error While Update Day End',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,3,'MsgBox-276-1000-3','','','Back Dated Transaction Not Allowed',1,1,1,'2009-04-28',1,'2009-04-28','','','Back Dated Transaction Not Allowed',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,4,'MsgBox-276-1000-4','','','Date Not Exists Please check the dayenddates Table',1,1,1,'2009-04-28',1,'2009-04-28','','','Date Not Exists Please check the dayenddates Table',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,5,'MsgBox-276-1000-5','','','To date must between the given date range ',1,1,1,'2009-04-28',1,'2009-04-28','','','To date must between the given date range ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,6,'MsgBox-276-1000-6','','','Close the day end process ',1,1,1,'2009-04-28',1,'2009-04-28','','','Close the day end process ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,7,'PnlMsg-276-1000-7','','Please Wait Processing PDA Data...','',1,1,1,'2009-04-28',1,'2009-04-28','','Please Wait Processing PDA Data...','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,8,'MsgBox-276-1000-8','','','PDA Data Processing Failed ',1,1,1,'2009-04-28',1,'2009-04-28','','','PDA Data Processing Failed ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (276,1000,9,'MsgBox-276-1000-9','','','Error in SP Proc_ExportImport ',1,1,1,'2009-04-28',1,'2009-04-28','','','Error in SP Proc_ExportImport ',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId = 277
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1,1,'CoreHeaderTool','Month End Process','','',1,1,1,'2009-04-28',1,'2009-04-28','Month End Process','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1,2,'CoreHeaderTool','Stocky','','',1,1,1,'2009-04-28',1,'2009-04-28','Stocky','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,1,'MsgBox-277-1000-1','','','Month End Updated Sucessfully',1,1,1,'2009-04-28',1,'2009-04-28','','','Month End Updated Sucessfully',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,2,'MsgBox-277-1000-2','','','Error While Update Month End',1,1,1,'2009-04-28',1,'2009-04-28','','','Error While Update Month End',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,3,'MsgBox-277-1000-3','','','Close the Month End',1,1,1,'2009-04-28',1,'2009-04-28','','','Close the Month End',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,4,'MsgBox-277-1000-4','','','Date Not Exists Please check the dayenddates Table',1,1,1,'2009-04-28',1,'2009-04-28','','','Date Not Exists Please check the dayenddates Table',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,5,'MsgBox-277-1000-5','','','Error In Sp ',1,1,1,'2009-04-28',1,'2009-04-28','','','Error In Sp ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,6,'MsgBox-277-1000-6','','','Error In Auto Claim Generation ',1,1,1,'2009-04-28',1,'2009-04-28','','','Error In Auto Claim Generation  ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,7,'PnlMsg-277-1000-7','','Please Wait Auto Claim Process Running...','',1,1,1,'2009-04-28',1,'2009-04-28','','Please Wait Auto Claim Process Running...','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,8,'MsgBox-277-1000-8','','','Do You Want To Reset Counters',1,1,1,'2013-03-28',1,'2013-03-28','','','Do You Want To Reset Counters',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,9,'MsgBox-277-1000-9','','','Financial Year Has been Changed',1,1,1,'2013-03-28',1,'2013-03-28','','','Financial Year Has been Changed',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,10,'MsgBox-277-1000-10','','','Month End and Year End completed',1,1,1,'2013-03-28',1,'2013-03-28','','','Month End and Year End completed',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,11,'MsgBox-277-1000-11','','','All counters have been reset. Press Ok to change billing counters',1,1,1,'2013-03-28',1,'2013-03-28','','','All counters have been reset. Press Ok to change billing counters',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,12,'MsgBox-277-1000-12','','','If You want the invoice numbers to start with 1,Press "Edit" and change the prefix else press "Exit" to continue',1,1,1,'2013-03-28',1,'2013-03-28','','','If You want the invoice numbers to start with 1,Press "Edit" and change the prefix else press "Exit" to continue',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (277,1000,13,'MsgBox-277-1000-13','','','Counters Reset, Please run Month end to close the month and Year',1,1,1,'2013-03-28',1,'2013-03-28','','','Counters Reset, Please run Month end to close the month and Year',1,1)
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND Name = 'DayEndDates')
BEGIN
CREATE TABLE DayEndDates(
	[DayEndStartDate] [datetime] NULL,
	[DayEndClosedate] [datetime] NULL,
	[DayEndType] [tinyint] NULL,
	[Status] [tinyint] NULL,
	[UserId] [int] NULL,
	[Upload] [int] NULL
) ON [PRIMARY]
ALTER TABLE DayEndDates ADD DEFAULT ((0)) FOR [Upload]
END
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND Name = 'DayEndValidation')
BEGIN
CREATE TABLE DayEndValidation(
	[DayEndType] [tinyint] NULL,
	[DayEndStartDate] [datetime] NULL,
	[Status] [tinyint] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND Name = 'JCMonthEnd')
BEGIN
CREATE TABLE JCMonthEnd(
	[JcmId] [int] NOT NULL,
	[JcmJc] [int] NOT NULL,
	[JcmSdt] [datetime] NOT NULL,
	[JcmEdt] [datetime] NOT NULL,
	[JcmMontEnddate] [datetime] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[Upload] [tinyint] NOT NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT * FROM DayEndDates)
BEGIN	
	DECLARE @DateDiff AS INT
	DECLARE @StartDate DATETIME
	DECLARE @CurDate AS DATETIME
	SELECT @StartDate ='2010-01-01'
	SELECT Max(TransDate) Transdate INTO #Tran FROM StockLedger
	IF EXISTS(SELECT * FROM #Tran WHERE Transdate IS NOT NULL)
	BEGIN
		SELECT @CurDate=DATEADD(D,-1,CONVERT(DATETIME,CONVERT(VARCHAR(10),(TransDate),121),121)) FROM #Tran
	END
	ELSE
	BEGIN
		SELECT @CurDate=DATEADD(D,-1,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121))
	END
	WHILE @StartDate<='2030-12-31'
	BEGIN
		INSERT INTO DayEndDates(DayEndStartDate,DayEndClosedate,DayEndType,Status,UserId)
		SELECT @StartDate, @StartDate,0,0,0
		SET @StartDate=DATEADD(D,1,@StartDate)
	END
	Update DayEndDates Set Status=1 where DayEndStartDate<=@CurDate
	DROP TABLE #Tran	
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='MonthEndClosing')
BEGIN
CREATE TABLE MonthEndClosing(
	[StkMonth] [varchar](50) NULL,
	[StkYear] [int] NULL,
	[UploadFlag] [nvarchar](1) NULL
)
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='FN' AND NAME='Fn_ReturnLastMonthEndDate')
DROP FUNCTION Fn_ReturnLastMonthEndDate
GO
CREATE FUNCTION [Fn_ReturnLastMonthEndDate](@CurDate DATETIME) 
RETURNS DATETIME
AS
BEGIN
	DECLARE @Date	DATETIME
	SELECT @Date=DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@CurDate),0))
RETURN(@Date)
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='MonthEndClosingStockSnapShot')
BEGIN
CREATE TABLE [MonthEndClosingStockSnapShot](
	[StkMonth] [nvarchar](50) NULL,
	[StkYear] [int] NULL,	
	[LcnName] [nvarchar](100) NULL,	
	[PrdCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](100) NULL,	
	[PrdBatchCode] [nvarchar](100) NULL,
	[MRP] Numeric(36,6),
	[CLP] Numeric (36,6),
	OpeningSales Numeric(36,0),
	OpeningUnSaleable Numeric(36,0),
	OpenignOffer Numeric(36,0),
	PurchaseSales	Numeric(36,0),
	PurchaseUnSaleable Numeric(36,0),
	PurchaseOffer Numeric(36,0),
	InvoiceSales Numeric(36,0),
	InvoiceUnSaleable Numeric(36,0),
	InvoiceOffer Numeric(36,0),
	Adjustment Numeric(36,0),
	ClosingSales Numeric(36,0),
	ClosingUnSaleable Numeric(36,0),
	ClosingOffer Numeric(36,0),
	SecondarySales  Numeric(36,0),
	UploadFlag Varchar(1),	
	[UploadedDate] [datetime] NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='YearEndOpenTrans')
DROP TABLE YearEndOpenTrans
GO
CREATE TABLE YearEndOpenTrans(
	[SlNo] [int] NULL,
	[ScreenName] [nvarchar](100) NULL,
	[TabName] [nvarchar](100) NULL,
	[OpenTrans] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='YearEndLog')
DROP TABLE YearEndLog
GO
CREATE TABLE YearEndLog(
	[SlNo] [int] NULL,
	[ScreenName] [nvarchar](100) NULL,
	[RefNo] [nvarchar](100) NULL
) ON [PRIMARY]
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' and NAME='Proc_YEGetOpenTrans')
DROP PROCEDURE Proc_YEGetOpenTrans
GO
--EXEC Proc_YEGetOpenTrans '2008-04-01','2009-03-31'
--SELECT * FROM YearEndOpenTrans
CREATE PROCEDURE Proc_YEGetOpenTrans
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_YEGetOpenTrans
* PURPOSE	: To get the Open transactions for Year End
* CREATED	: Nandakumar R.G
* CREATED DATE	: 09/03/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	TRUNCATE TABLE YearEndOpenTrans
	TRUNCATE TABLE YearEndLog
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 1,'Purchase','PurchaseReceipt',ISNULL(COUNT(*),0)
	FROM PurchaseReceipt
	WHERE Status=0 AND GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 1,'Purchase',PurRcptRefNo
	FROM PurchaseReceipt
	WHERE Status=0 AND GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 2,'Purchase Return','PurchaseReturn',ISNULL(COUNT(*),0)
	FROM PurchaseReturn
	WHERE Status=0 AND PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 2,'Purchase Return',PurRetRefNo
	FROM PurchaseReturn
	WHERE Status=0 AND PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 3,'Return To Company','ReturnToCompany',ISNULL(COUNT(*),0)
	FROM ReturnToCompany
	WHERE Status=0 AND RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 3,'Return To Company',RtnCmpRefNo
	FROM ReturnToCompany
	WHERE Status=0 AND RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 4,'Stock Management','StockManagement',ISNULL(COUNT(*),0)
	FROM StockManagement
	WHERE Status=0 AND StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 4,'Stock Management',StkMngRefNo
	FROM StockManagement
	WHERE Status=0 AND StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 5,'Salvage','Salvage',ISNULL(COUNT(*),0)
	FROM Salvage
	WHERE Status=0 AND SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 5,'Salvage',SalvageRefNo
	FROM Salvage
	WHERE Status=0 AND SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 6,'Billing','SalesInvoice',ISNULL(COUNT(*),0)
	FROM SalesInvoice
	WHERE DlvSts NOT IN(5,3,4) AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 6,'Billing',SalInvNo
	FROM SalesInvoice
	WHERE DlvSts NOT IN(5,3,4) AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--->Added By Nanda on 15/03/2011
--	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
--	SELECT 7,'Sales Return','ReturnHeader',ISNULL(COUNT(*),0)
--	FROM ReturnHeader
--	WHERE Status=1 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
--	SELECT 7,'Sales Return',ReturnCode
--	FROM ReturnHeader
--	WHERE Status=1 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 7,'Sales Return','Sales Return',A.Counts+B.Counts
	FROM 
	(
		SELECT ISNULL(COUNT(*),0) AS Counts 
		FROM ReturnHeader
		WHERE Status=1 AND ReturnType=2 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	) A	,
	(
		SELECT ISNULL(COUNT(*),0) AS Counts 
		FROM ReturnHeader RH,SalesInvoice SI
		WHERE RH.Status=1 AND RH.ReturnType=1 
		AND RH.SalId=SI.SalId AND SI.DlvSts<3
		AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	) B
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 7,'Sales Return',ReturnCode
	FROM ReturnHeader
	WHERE Status=1 AND ReturnType=2 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 7,'Sales Return',ReturnCode
	FROM ReturnHeader RH,SalesInvoice SI
	WHERE RH.Status=1 AND RH.ReturnType=1 AND RH.SalId=SI.SalId AND SI.DlvSts<3
	AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--->Till Here
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 8,'Resell Damage Goods','ResellDamageMaster',ISNULL(COUNT(*),0)
	FROM ResellDamageMaster
	WHERE Status=0 AND ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 8,'Resell Damage Goods',ReDamRefNo
	FROM ResellDamageMaster
	WHERE Status=0 AND ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 9,'Salesman Salary & DA Claim','SalesmanClaimMaster',ISNULL(COUNT(*),0)
	FROM SalesmanClaimMaster
	WHERE Status=0 AND ScmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 9,'Salesman Salary & DA Claim',ScmRefNo
	FROM SalesmanClaimMaster
	WHERE Status=0 AND ScmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 10,'Delivery boy Salary & DA Claim','DeliveryBoyClaimMaster',ISNULL(COUNT(*),0)
	FROM DeliveryBoyClaimMaster
	WHERE Status=0 AND DbcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 10,'Delivery boy Salary & DA Claim',DbcRefNo
	FROM DeliveryBoyClaimMaster
	WHERE Status=0 AND DbcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 11,'Salesman Incentive Claim','SMIncentiveCalculatorMaster',ISNULL(COUNT(*),0)
	FROM SMIncentiveCalculatorMaster
	WHERE Status=0 AND SicDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 11,'Salesman Incentive Claim',SicRefNo
	FROM SMIncentiveCalculatorMaster
	WHERE Status=0 AND SicDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 12,'Van Subsidy Claim','VanSubsidyHD',ISNULL(COUNT(*),0)
	FROM VanSubsidyHD
	WHERE [Confirm]=0 AND SubsidyDt BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 12,'Van Subsidy Claim',RefNo
	FROM VanSubsidyHD
	WHERE [Confirm]=0 AND SubsidyDt BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 13,'Transporter Claim','TransporterClaimMaster',ISNULL(COUNT(*),0)
	FROM TransporterClaimMaster
	WHERE Status=0 AND TrcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 13,'Transporter Claim',TrcRefNo
	FROM TransporterClaimMaster
	WHERE Status=0 AND TrcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 14,'Special Discount Claim','SpecialDiscountMaster',ISNULL(COUNT(*),0)
	FROM SpecialDiscountMaster
	WHERE Status=0 AND SdcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 14,'Special Discount Claim',SdcRefNo
	FROM SpecialDiscountMaster
	WHERE Status=0 AND SdcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 15,'Rate Difference Claim','RateDifferenceClaim',ISNULL(COUNT(*),0)
	FROM RateDifferenceClaim
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 15,'Rate Difference Claim',RefNo
	FROM RateDifferenceClaim
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 16,'Purchase Shortage Claim','PurShortageClaim',ISNULL(COUNT(*),0)
	FROM PurShortageClaim
	WHERE Status=0 AND ClaimDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 16,'Purchase Shortage Claim',PurShortRefNo
	FROM PurShortageClaim
	WHERE Status=0 AND ClaimDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 17,'Purchase Excess Quantity Refusal Claim','PurchaseExcessClaimMaster',ISNULL(COUNT(*),0)
	FROM PurchaseExcessClaimMaster
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 17,'Purchase Excess Quantity Refusal Claim',RefNo
	FROM PurchaseExcessClaimMaster
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 18,'Manual Claim','ManualClaimMaster',ISNULL(COUNT(*),0)
	FROM ManualClaimMaster
	WHERE Status=0 AND MacDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 18,'Manual Claim',MacRefNo
	FROM ManualClaimMaster
	WHERE Status=0 AND MacDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 19,'VAT Claim','VatTaxClaim',ISNULL(COUNT(*),0)
	FROM VatTaxClaim
	WHERE Status=0 AND VatDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 19,'VAT Claim',SvatNo
	FROM VatTaxClaim
	WHERE Status=0 AND VatDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	--SELECT 20,'Claim Top Sheet','ClaimSheetHD',ISNULL(COUNT(*),0)
	--FROM ClaimSheetHD
	--WHERE [Confirm]=0 --AND ClmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	--SELECT 20,'Claim Top Sheet',ClmCode
	--FROM ClaimSheetHD
	--WHERE [Confirm]=0 --AND ClmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 21,'Spent & Received','SpentReceivedHD',ISNULL(COUNT(*),0)
	FROM SpentReceivedHD
	WHERE Status=0 AND SRDDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 21,'Spent & Received',SRDRefNo
	FROM SpentReceivedHD
	WHERE Status=0 AND SRDDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 22,'Point Redemption','PntRetSchemeHD',ISNULL(COUNT(*),0)
	FROM PntRetSchemeHD
	WHERE Status=0 AND TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 22,'Point Redemption',PntRedRefNo
	FROM PntRetSchemeHD
	WHERE Status=0 AND TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 23,'Coupon Redemption','CouponRedHd',ISNULL(COUNT(*),0)
	FROM CouponRedHd
	WHERE Status=0 AND CpnRedDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 23,'Coupon Redemption',CpnRedCode
	FROM CouponRedHd
	WHERE Status=0 AND CpnRedDate BETWEEN @Pi_FromDate AND @Pi_ToDate	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='CS2CN_Prk_MonthEndClosingStock')
DROP TABLE CS2CN_Prk_MonthEndClosingStock
GO
CREATE TABLE [CS2CN_Prk_MonthEndClosingStock](
	[SlNo] Numeric (38,0) IDENTITY (1,1),
	[DistCode] Varchar(50),
	[StkMonth] [nvarchar](50) NULL,
	[StkYear] [int] NULL,	
	[LcnName] [nvarchar](100) NULL,	
	[PrdCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdBatchCode] [nvarchar](100) NULL,
	[MRP] Numeric(36,6),
	[CLP] Numeric (36,6),
	OpeningSales Numeric(36,0),
	OpeningUnSaleable Numeric(36,0),
	OpenignOffer Numeric(36,0),
	PurchaseSales	Numeric(36,0),
	PurchaseUnSaleable Numeric(36,0),
	PurchaseOffer Numeric(36,0),
	InvoiceSales Numeric(36,0),
	InvoiceUnSaleable Numeric(36,0),
	InvoiceOffer Numeric(36,0),
	Adjustment Numeric(36,0),
	ClosingSales Numeric(36,0),
	ClosingUnSaleable Numeric(36,0),
	ClosingOffer Numeric(36,0),
	SecondarySales  Numeric(36,0),
	UploadFlag  Nvarchar(1),
	SyncId numeric(38, 0) NULL,
	ServerDate datetime NULL
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CS2CNMonthEndClosingStock')
DROP PROCEDURE Proc_CS2CNMonthEndClosingStock
GO
--Exec Proc_CS2CNMonthEndClosingStock 0,'2013-09-30'
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger
CREATE	PROCEDURE Proc_CS2CNMonthEndClosingStock
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_CS2CNMonthEndClosingStock
* PURPOSE	: To Get Stock Ledger Detail
* CREATED	: Murugan.R
* CREATED DATE	: 17/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
    SET @Po_ErrNo = 0
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @MaxTransDate AS DATETIME
	DECLARE @Pi_ToDate AS DATETIME
	DECLARE @Pi_ToDate1 AS DATETIME
	
	
	SELECT @DistCode = DistributorCode FROM Distributor
	DELETE FROM CS2CN_Prk_MonthEndClosingStock WHERE UploadFlag='N'
	IF EXISTS(SELECT StkMonth,StkYear FROM MonthEndClosing WHERE UploadFlag='N')	
	BEGIN

		SELECT @Pi_ToDate1=CONVERT(DATETIME,CONVERT(VARCHAR(10),DBO.Fn_ReturnLastMonthEndDate(Getdate()),121),121)
		SELECT @MaxTransDate =MAX(DayEndStartDate) FROM Dayenddates (NOLOCK) WHERE Status=1	

		SET @Pi_ToDate=@Pi_ToDate1
	
	
	CREATE TABLE #CS2CN_Prk_MonthEndClosingStock(
	Transdate Datetime,
	[LcnId] [int] NULL,
	[LcnName] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
	[PrdId] [int] NULL,
	[PrdCode] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
	[PrdName] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
	[PrdBatId] [int] NULL,
	[PrdBatchCode] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
	[MRP] Numeric(36,6),
	[CLP] Numeric (36,6),
	OpeningSales Numeric(36,0),
	OpeningUnSaleable Numeric(36,0),
	OpenignOffer Numeric(36,0),
	PurchaseSales	Numeric(36,0),
	PurchaseUnSaleable Numeric(36,0),
	PurchaseOffer Numeric(36,0),
	InvoiceSales Numeric(36,0),
	InvoiceUnSaleable Numeric(36,0),
	InvoiceOffer Numeric(36,0),
	Adjustment Numeric(36,0),
	ClosingSales Numeric(36,0),
	ClosingUnSaleable Numeric(36,0),
	ClosingOffer Numeric(36,0),
	SecondarySales  Numeric(36,6)
	)


	DECLARE @ProdDetail TABLE
		(
			lcnid	INT,
			PrdBatId INT,
			TransDate DATETIME
		)
	DELETE FROM @ProdDetail
	
	select lcnid,prdbatid,max(TransDate) as TransDate  
	INTO #Stock1
	FROM StockLedger Stk (nolock)
	WHERE Stk.TransDate NOT BETWEEN @Pi_ToDate AND @Pi_ToDate
	Group by lcnid,prdbatid
	
	select distinct lcnid,prdbatid,max(TransDate) as TransDate 
	INTO #Stock2
	FROM StockLedger Stk (nolock)
	WHERE Stk.TransDate BETWEEN @Pi_ToDate AND @Pi_ToDate
	Group by lcnid,prdbatid
	
	
		
	INSERT INTO @ProdDetail
		(
			lcnid,PrdBatId,TransDate
		)
	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM #Stock1 a
	LEFT OUTER JOIN #Stock2 B
	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
	where b.lcnid is null and b.prdbatid is null
			
	DELETE FROM #CS2CN_Prk_MonthEndClosingStock 
	
	--      Stocks for the given date---------

		INSERT INTO #CS2CN_Prk_MonthEndClosingStock
		(Transdate,LcnId,LcnName,PrdId,PrdCode,PrdName,PrdBatId,PrdBatchCode,
		MRP,CLP,OpeningSales,OpeningUnSaleable,OpenignOffer,
		PurchaseSales,PurchaseUnSaleable,PurchaseOffer,
		InvoiceSales,InvoiceUnSaleable,InvoiceOffer,
		Adjustment,ClosingSales,ClosingUnSaleable,
		ClosingOffer,SecondarySales)
					
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,0 as MRP,0 as CLP,
		Sl.SalOpenStock,Sl.UnSalOpenStock,Sl.OfferOpenStock,
		Sl.SalPurchase,Sl.UnsalPurchase,Sl.OfferPurchase,
		Sl.SalSales,Sl.UnSalSales,Sl.OfferSales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		Sl.SalClsStock,Sl.UnSalClsStock,Sl.OfferClsStock,
		0 as SecondarySales
		FROM
		Product Prd (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId 	AND
		Sl.TransDate BETWEEN @Pi_ToDate AND @Pi_ToDate			
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	
	--      Stocks for those not included in the given date---------

		INSERT INTO #CS2CN_Prk_MonthEndClosingStock
		(Transdate,LcnId,LcnName,PrdId,PrdCode,PrdName,PrdBatId,PrdBatchCode,
		MRP,CLP,OpeningSales,OpeningUnSaleable,OpenignOffer,
		PurchaseSales,PurchaseUnSaleable,PurchaseOffer,
		InvoiceSales,InvoiceUnSaleable,InvoiceOffer,
		Adjustment,ClosingSales,ClosingUnSaleable,
		ClosingOffer,SecondarySales)
		
		SELECT @Pi_ToDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,0 as MRP,0 as CLP,
		ISNULL(Sl.SalClsStock,0),ISNULL(Sl.UnSalClsStock,0),ISNULL(Sl.OfferClsStock,0),
		0 as PurchaseSales,0 as PurchaseUnSaleable,0 as PurchaseOffer,
		0 as InvoiceSales,0 as InvoiceUnSaleable,0 as InvoiceOffer,		
		0 AS Adjustments,
		ISNULL(Sl.SalClsStock,0) as ClosingSales,ISNULL(Sl.UnSalClsStock,0) as ClosingUnSaleable,
		ISNULL(Sl.OfferClsStock,0) AS ClosingOffer,
		0 as SecondarySales
		FROM
		Product Prd (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid		
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Sl.TransDate< @Pi_ToDate
		
	
	--      Stocks for those not included in the stockLedger---------
	SELECT DISTINCT Prdid,Prdbatid INTO #StockLedger FROM StockLedger
	SELECT DISTINCT PrdBatId INTO #Stockbatch FROM (
		SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM
		ProductBatch A (nolock) LEFT OUTER JOIN #StockLedger B (nolock)
		ON A.Prdid =B.Prdid) a
		WHERE ISNULL(NewPrdBatId,0) = 0
		
	INSERT INTO #CS2CN_Prk_MonthEndClosingStock
	(
		Transdate,LcnId,LcnName,PrdId,PrdCode,PrdName,PrdBatId,PrdBatchCode,
		MRP,CLP,OpeningSales,OpeningUnSaleable,OpenignOffer,
		PurchaseSales,PurchaseUnSaleable,PurchaseOffer,
		InvoiceSales,InvoiceUnSaleable,InvoiceOffer,
		Adjustment,ClosingSales,ClosingUnSaleable,
		ClosingOffer,SecondarySales
	)			
	SELECT @Pi_ToDate AS TransDate,Lcn.LcnId,
	Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,
	0 as MRP,0 as CLP,
	0 as OpeningSales,0 asOpeningUnSaleable,0 as OpenignOffer,
	0 as PurchaseSales,0 as PurchaseUnSaleable,0 as PurchaseOffer,
	0 as InvoiceSales,0 as InvoiceUnSaleable,0 as InvoiceOffer,
	0 as Adjustment,0 as ClosingSales,0 as ClosingUnSaleable,0 as ClosingOffer,0 as SecondarySales	
	FROM
	ProductBatch PrdBat (NOLOCK),Product Prd (NOLOCK)
	CROSS JOIN Location Lcn (NOLOCK)
	WHERE
		PrdBat.PrdBatId IN
		(SELECT PrdBatId FROM #Stockbatch)
	AND PrdBat.PrdId=Prd.PrdId
	
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	
	
	SELECT Prdid,Prdbatid,PriceId,Status,SUM(SelRte) as SelRte,SUM(ListPrice) as ListPrice,SUM(MRP) as MRP
	INTO #Productbatch
	FROM(
		SELECT Prdid,P.Prdbatid,PriceId,Status,PrdBatDetailValue as SelRte,0 as ListPrice,0 as MRP   FROM BatchCreation BC 
		INNER JOIN ProductBatch P  ON BC.BatchSeqId=P.BatchSeqId
		INNER JOIN ProductBatchDetails PB ON P.PrdBatId=PB.PrdBatId and P.DefaultPriceId=PB.PriceId
		and BC.SlNo=pb.SLNo WHERE DefaultPrice=1 and Bc.SelRte=1
		UNION ALL
		SELECT Prdid,P.Prdbatid,PriceId,Status, 0 as SelRte,PrdBatDetailValue as ListPrice,0 as MRP  FROM BatchCreation BC 
		INNER JOIN ProductBatch P  ON BC.BatchSeqId=P.BatchSeqId
		INNER JOIN ProductBatchDetails PB ON P.PrdBatId=PB.PrdBatId and P.DefaultPriceId=PB.PriceId
		and BC.SlNo=pb.SLNo WHERE DefaultPrice=1 and Bc.ListPrice=1
		UNION ALL
		SELECT Prdid,P.Prdbatid,PriceId,Status,0 as SelRte,0 as ListPrice,PrdBatDetailValue as MRP  FROM BatchCreation BC 
		INNER JOIN ProductBatch P  ON BC.BatchSeqId=P.BatchSeqId
		INNER JOIN ProductBatchDetails PB ON P.PrdBatId=PB.PrdBatId and P.DefaultPriceId=PB.PriceId
		and BC.SlNo=pb.SLNo WHERE DefaultPrice=1 and Bc.MRP=1
	) X GROUP BY 	Prdid,Prdbatid,PriceId,Status
	
	Update A Set A.MRP=B.MRP, A.CLP=b.ListPrice,SecondarySales=(InvoiceSales*b.ListPrice)
	FROM #CS2CN_Prk_MonthEndClosingStock A INNER JOIN #Productbatch B
	ON A.PrdId=B.PrdId and A.PrdBatId=B.PrdBatId
	
	INSERT INTO CS2CN_Prk_MonthEndClosingStock(DistCode,StkMonth,StkYear,
	LcnName,PrdCode,PrdName,PrdBatchCode,MRP,CLP,OpeningSales,OpeningUnSaleable,
	OpenignOffer,PurchaseSales,PurchaseUnSaleable,PurchaseOffer,InvoiceSales,
	InvoiceUnSaleable,InvoiceOffer,Adjustment,ClosingSales,ClosingUnSaleable,
	ClosingOffer,SecondarySales,UploadFlag)
	SELECT @DistCode as DistCode,StkMonth,StkYear,
	LcnName,PrdCode,PrdName,PrdBatchCode,MRP,CLP,OpeningSales,OpeningUnSaleable,
	OpenignOffer,PurchaseSales,PurchaseUnSaleable,PurchaseOffer,InvoiceSales,
	InvoiceUnSaleable,InvoiceOffer,Adjustment,ClosingSales,ClosingUnSaleable,
	ClosingOffer,SecondarySales,'N' as UploadFlag
	FROM #CS2CN_Prk_MonthEndClosingStock  CROSS JOIN MonthEndClosing  
	WHERE (OpeningSales+OpeningUnSaleable+OpenignOffer+ClosingSales+ClosingUnSaleable+ClosingOffer)>0
	AND UploadFlag='N'
	
	UPDATE MonthEndClosing SET UploadFlag='Y'
	--UPDATE DayEndDates SET Status=1 , DayEndClosedate=Getdate(),UserId=2
	--WHERE DayEndStartDate between @MaxTransDate and  CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_ToDate,121),121)
	

	DELETE A FROM MonthEndClosingStockSnapShot A WHERE EXISTS(SELECT StkMonth,StkYear FROM CS2CN_Prk_MonthEndClosingStock B WHERE A.StkMonth=B.StkMonth and A.StkYear=B.StkYear)
	
	INSERT INTO MonthEndClosingStockSnapShot
	(StkMonth,StkYear,LcnName,PrdCode,PrdName,
	PrdBatchCode,MRP,CLP,
	OpeningSales,OpeningUnSaleable,OpenignOffer,
	PurchaseSales,PurchaseUnSaleable,PurchaseOffer,
	InvoiceSales,InvoiceUnSaleable,InvoiceOffer,
	Adjustment,ClosingSales,ClosingUnSaleable,ClosingOffer,
	SecondarySales,UploadFlag,UploadedDate)
	SELECT StkMonth,StkYear,
	LcnName,PrdCode,PrdName,PrdBatchCode,MRP,CLP,OpeningSales,OpeningUnSaleable,
	OpenignOffer,PurchaseSales,PurchaseUnSaleable,PurchaseOffer,InvoiceSales,
	InvoiceUnSaleable,InvoiceOffer,Adjustment,ClosingSales,ClosingUnSaleable,
	ClosingOffer,SecondarySales, 0 as UploadFlag ,Serverdate as UploadedDate
	FROM CS2CN_Prk_MonthEndClosingStock WHERE UploadFlag='N'

	
	END
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype IN ('TF','FN') AND Name = 'Fn_ReturnHolidays')
DROP FUNCTION Fn_ReturnHolidays
GO
CREATE FUNCTION Fn_ReturnHolidays (@CurrDate AS DATETIME)    
RETURNS TINYINT    
AS    
/*********************************    
* FUNCTION: Fn_ReturnHolidays    
* PURPOSE: To Return Holidays    
* CREATED: Murugan.R 02/02/2012    
*********************************/    
BEGIN    
 DECLARE @ReturnHolidays AS INT    
 SET @ReturnHolidays=0    
 SELECT @ReturnHolidays=ISNULL(SUM(DISTINCT CNT),0)     
 FROM(    
   SELECT ISNULL(COUNT(JcmId),0) AS CNT     
   FROM JCHoliday WHERE @CurrDate BETWEEN HoliDaySdt AND HolidayEdt    
   UNION ALL    
   SELECT ISNULL(COUNT(DistributorCode),0) AS CNT    
   FROM DISTRIBUTOR    
   WHERE UPPER(DATENAME(DW,@CurrDate))=UPPER(CASE DayOff WHEN 0 THEN 'Sunday'    
              WHEN 1 THEN 'Monday'    
              WHEN 2 THEN 'Tuesday'    
              WHEN 3 THEN 'Wednesday'    
              WHEN 4 THEN 'Thursday'    
              WHEN 5 THEN 'Friday'    
              WHEN 6 THEN 'Saturday' END)    
  UNION ALL
  SELECT ISNULL(JcmId,0) AS CNT 
   FROM JCMast 
   WHERE JcmYr=YEAR(GETDATE())
   AND UPPER(DATENAME(DW,@CurrDate))=UPPER(CASE WkEndDay WHEN 1 THEN 'Sunday'    
              WHEN 2 THEN 'Monday'    
              WHEN 3 THEN 'Tuesday'    
              WHEN 4 THEN 'Wednesday'    
              WHEN 5 THEN 'Thursday'    
              WHEN 6 THEN 'Friday'    
              WHEN 7 THEN 'Saturday' END)
  )X    
 RETURN(@ReturnHolidays)    
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype IN ('TF','FN') AND Name = 'Fn_ReturnHolidaysCount')
DROP FUNCTION Fn_ReturnHolidaysCount
GO
--SELECT DBO.Fn_ReturnHolidaysCount('2012-02-08') AS HoliDayCount
CREATE FUNCTION Fn_ReturnHolidaysCount (@CurrDate AS DATETIME)
RETURNS TINYINT
AS
/*********************************
* FUNCTION: Fn_ReturnHolidaysCount
* PURPOSE: To Return Holidays Count
* CREATED: Murugan.R 02/02/2012
*********************************/
BEGIN
DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
DECLARE @Condition AS INT
DECLARE @HoliDayExists AS INT
DECLARE @HoliDayCnt AS INT
SET @Condition=0
SET @HoliDayExists=0
SET @HoliDayCnt=0
SELECT @Condition=Condition FROM CONFIGURATION where ModuleId='DAYENDPROCESS4' AND Status=1
SET @EndDate=@CurrDate
SELECT @StartDate=DATEADD(D,-@Condition,@EndDate)
SELECT @EndDate=DATEADD(D,-1,@EndDate)
WHILE @StartDate<=@EndDate
BEGIN
	SELECT @HoliDayExists=DBO.Fn_ReturnHolidays(@StartDate)
	IF @HoliDayExists=1
	BEGIN
		SET @HoliDayCnt=@HoliDayCnt+1
	END	
	SET @StartDate=DATEADD(D,1,@StartDate)	
END
	RETURN(@HoliDayCnt)
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_ValidateDayEndProcess')
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
IF NOT EXISTS(SELECT J.JcmId,JcmJc,JcmYr,JcmSdt,JcmEdt FROM
 JcMast J INNER JOIN Jcmonth Jc ON J.JcmId=Jc.JcmId
 INNER JOIN Company C On C.CmpId=J.CmpId
 WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121) BETWEEN JcmSdt and JcmEdt
 And DefaultCompany=1)
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
DELETE FROM configuration WHERE ModuleId='DAYENDPROCESS7'
INSERT INTO configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('DAYENDPROCESS7','Day End Process','Enable Day and Month End Process',0,'0',0.00,7)
DELETE FROM configuration WHERE ModuleId='DAYENDPROCESS8'
INSERT INTO configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('DAYENDPROCESS8','Day End Process','Restrict transactions on distributor off day',0,'0',0.00,8)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN('FN','TF') AND NAME='Fn_ValidateTransactionDate')
DROP FUNCTION Fn_ValidateTransactionDate
GO
--SELECT LastTransdate,CurrentDate,UserMessage FROM DBO.Fn_ValidateTransactionDate() WHERE UserMessage IS NOT NULL
CREATE FUNCTION Fn_ValidateTransactionDate()
RETURNS @TransactionDate TABLE 
( LastTransdate DATETIME,
  CurrentDate  DATETIME,
  iType			TinyInt,
  UserMessage	VARCHAR(200)
  
 )
 AS
 BEGIN 
						 
INSERT INTO @TransactionDate(LastTransdate,CurrentDate,iType,UserMessage)
	SELECT Max(Transdate),CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121),
	CASE WHEN DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<0
	THEN 1 ELSE 2 END ITYPE,
	CASE WHEN DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<0
	THEN 'Back Dated Transaction'

	WHEN DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))>0
	AND DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<7

	THEN CAST (DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate)) as Varchar(10))+
	' Day Difference From last transaction date' 
	WHEN DateDiff(WEEK,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))>0
	AND DateDiff(WEEK,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<5	
	THEN  
	' More than ['+ CAST (DateDiff(WEEK,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate)) as Varchar(10))+'] Week Difference From last transaction date'  
	WHEN DateDiff(MONTH,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))>0
	AND DateDiff(MONTH,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<12
	THEN  
	' More than ['+ CAST (DateDiff(MONTH,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate)) as Varchar(10))+'] Month Difference From last transaction date' 
	WHEN DateDiff(YEAR,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))>0
	THEN  
	' More than ['+ CAST (DateDiff(YEAR,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate)) as Varchar(10))+'] Year Difference From last transaction date'    

	END 
			 FROM Stockledger (NOLOCK)
RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN('FN','TF') AND NAME='Fn_ReturnIsBackDated')
DROP FUNCTION Fn_ReturnIsBackDated
GO
--SELECT DBo.Fn_ReturnIsBackDated ('2013-10-31',206)
CREATE FUNCTION Fn_ReturnIsBackDated
(
	@Pi_TransDate DATETIME,
	@Pi_ScreenId INT
)
RETURNS INT
AS
/*********************************
* FUNCTION: Fn_ReturnIsBackDated
* PURPOSE: Check For Back Dated Transcation
* NOTES: 
* CREATED: Thrinath Kola	29-06-2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
@Pi_ScreenId		1		OrderBooking
@Pi_ScreenId		2		Billing
@Pi_ScreenId		3		SalesReturn
@Pi_ScreenId		4		LocationTransfer
@Pi_ScreenId		5		Purchase
@Pi_ScreenId		6		VanLoadUnload
@Pi_ScreenId		7		PurchaseReturn
@Pi_ScreenId		8		DebitMemo
@Pi_ScreenId		9		Collection
@Pi_ScreenId		10		CheuqeBounce
@Pi_ScreenId		11		ChequePayment
@Pi_ScreenId		12		CashBounce
@Pi_ScreenId		13		StockManagement
@Pi_ScreenId		14		BatchTransfer
@Pi_ScreenId		15		PaymentReversal
@Pi_ScreenId		16		ClaimSettlement
@Pi_ScreenId		17		IRA
@Pi_ScreenId		18		CreditNoteRetailer
@Pi_ScreenId		19		DebitNoteRetailer
@Pi_ScreenId		20		Replacement
@Pi_ScreenId		21		Salvage
@Pi_ScreenId		22		PaymentRegister
@Pi_ScreenId		23		MarketReturn
@Pi_ScreenId		24		ReturnandReplacement
@Pi_ScreenId		25		SalesPanel
@Pi_ScreenId		26		PurchaseOrder
@Pi_ScreenId		27		SchemeMonitor
@Pi_ScreenId		28		VehicleAllocation
@Pi_ScreenId		29		DeliveryProcess
@Pi_ScreenId		30		CreditNoteReplace
@Pi_ScreenId		31		ResellDamage
@Pi_ScreenId		32		CreditNoteSupplier
@Pi_ScreenId		33		DebitNoteSupplier
@Pi_ScreenId		34		RetailerOnAccount
@Pi_ScreenId		35		CreditDebitAdjust
@Pi_ScreenId		36		ChequeDisbursal
@Pi_ScreenId		37		ReturnToCompany
@Pi_ScreenId		38		StockJournal
@Pi_ScreenId		39		StdVoucher
@Pi_ScreenId		206		UserLogin
*********************************/
BEGIN
	DECLARE @RetValue as INT
	SET @RetValue = 0
	IF @Pi_ScreenId = 26
	BEGIN
		SELECT @RetValue = ISNULL(SUM(CNT),0) 
		FROM
		(
			SELECT ISNULL(COUNT(PurOrderRefNo),0) AS CNT FROM PurchaseOrderMaster (NOLOCK)
			WHERE PurOrderDate > @Pi_TransDate
			UNION ALL
			SELECT ISNULL(COUNT(Status),0) as CNT FROM  Dayenddates WHERE Status=1 and DayEndstartDate>=@Pi_TransDate
		)X
	END
	IF @Pi_ScreenId <> 39 AND @Pi_ScreenId <> 26
	BEGIN
		SELECT @RetValue=ISNULL(SUM(CNT),0)
		FROM 
		(
			----SELECT  ISNULL(COUNT(Availability),0) as CNT FROM StockLedger(NOLOCK)
			----WHERE TransDate > @Pi_TransDate	
			----UNION ALL
			SELECT ISNULL(COUNT(Status),0) as CNT FROM  Dayenddates WHERE Status=1 and DayEndstartDate>=@Pi_TransDate
		)X
	END
--Added by Praveenraj B to Restrict userlogin if backdated
	IF @Pi_ScreenId =206  
	BEGIN
		SELECT @RetValue=ISNULL(SUM(CNT),0)
		FROM 
		(
			--SELECT  ISNULL(COUNT(Availability),0) as CNT FROM StockLedger(NOLOCK)
			--WHERE TransDate > @Pi_TransDate	
			--UNION ALL
			SELECT ISNULL(COUNT(Status),0) as CNT FROM  Dayenddates WHERE Status=1 and DayEndstartDate>=@Pi_TransDate
		)X
	END
--End Here
-- 	IF @Pi_ScreenId = 1 
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(OrderNo) FROM OrderBooking 
-- 			WHERE OrderDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 2 
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(SalId) FROM SalesInvoice 
-- 			WHERE SalInvDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 3
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(ReturnID) FROM ReturnHeader 
-- 			WHERE ReturnDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 4
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(LcnRefNo) FROM LocationTransferMaster 
-- 			WHERE LcnTrfDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 5
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(PurRcptId) FROM PurchaseReceipt 
-- 			WHERE GoodsRcvdDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 6
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(VanLoadRefNo) FROM VanLoadUnLoadMaster 
-- 			WHERE TransferDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 7
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(PurRetId) FROM PurchaseReturn 
-- 			WHERE PurRetDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 8
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 9
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(InvRcpNo) FROM Receipt 
-- 			WHERE InvRcpDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 10
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 11
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(ChequePayId) FROM ChequePayment 
-- 			WHERE LastModDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 12
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 13
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(StkMngRefNo) FROM StockManagement 
-- 			WHERE StkMngDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 14
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(BatRefNo) FROM BatchTransfer 
-- 			WHERE BatTrfDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 15
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 16
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 17
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 18
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(CrNoteNumber) FROM CreditNoteRetailer 
-- 			WHERE CrNoteDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 19
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(DbNoteNumber) FROM DebitNoteRetailer 
-- 			WHERE DbNoteDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 20
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 21
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(SalVageRefNo) FROM Salvage 
-- 			WHERE SalvageDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 22
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(PayAdvNo) FROM PurchasePayment 
-- 			WHERE PaymentDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 23
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 	
-- 	IF @Pi_ScreenId = 24
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(RepRefNo) FROM ReplacementHd 
-- 			WHERE RepDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 25
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(SalId) FROM SalesInvoice 
-- 			WHERE SalInvDate > @Pi_TransDate
-- 	END
-- 
 	IF @Pi_ScreenId = 26
 	BEGIN
		SELECT @RetValue = ISNULL(SUM(CNT),0) 
		FROM
		(
			--SELECT ISNULL(COUNT(PurOrderRefNo),0) AS CNT FROM PurchaseOrderMaster (NOLOCK)
			--WHERE PurOrderDate > @Pi_TransDate
			--UNION ALL
			SELECT ISNULL(COUNT(Status),0) as CNT FROM  Dayenddates WHERE Status=1 and DayEndstartDate>=@Pi_TransDate
		)X
-- 		SELECT @RetValue = COUNT(PurOrderRefNo) FROM PurchaseOrderMaster (NOLOCK)
-- 			WHERE PurOrderDate > @Pi_TransDate
 	END
-- 
-- 	IF @Pi_ScreenId = 27
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 28
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(AllotmentNumber) FROM VehicleAllocationMaster 
-- 			WHERE AllotmentDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 29
-- 	BEGIN
-- 		SELECT @RetValue =COUNT(SalId) FROM SalesInvoice
-- 			WHERE SalDlvDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 30
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(CNRRefNo) FROM CreditNoteReplacementHd
-- 			WHERE CNRDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 31
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(ReDamRefNo) FROM ReSellDamageMaster 
-- 			WHERE ReSellDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 32
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(CrNoteNumber) FROM CreditNoteSupplier 
-- 			WHERE CrNoteDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 33
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(DBNoteNumber) FROM DebitNoteSupplier 
-- 			WHERE DBNoteDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 34
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(RtrAccRefNo) FROM RetailerOnAccount 
-- 			WHERE LastModDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 35
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(CRDBAdjustmentId) FROM CRDBAdjustment 
-- 			WHERE LastModDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 36
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(ChqDisRefNo) FROM ChequeDisbursalMaster 
-- 			WHERE ChqDisDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 37
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(RtnCmpRefNo) FROM ReturnToCompany 
-- 			WHERE RtnCmpDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 38
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(StkJournalRefNo) FROM StockJournal 
-- 			WHERE StkJournalDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 39
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
	RETURN(@RetValue)
END
GO
--Auto Backup
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DbBackupDt')
BEGIN
CREATE TABLE [DbBackupDt](
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DBBacupDate] [datetime] NULL,
	[FilePath] [varchar](2000) NULL,
	[ZipFileName] [varchar](100) NULL,
	[DbName] [varchar](200) NULL,
	[DbStatus] [tinyint] NULL,
	[HotFixNumber] Numeric(36,0),
	[HFReleasedOn] DateTime,
	[HFFixedOn] DateTime,
	[UpdaterNumber] Numeric (36,0),
	[USReleasedOn] DateTime,
	[USFixedOn] DateTime,
	[CSVersionNumber] Varchar(100),
	[SyncVersion] Varchar(100),
	[WindowsVersion] Varchar(150),
	[RAMSize] Varchar(200),
	ProcSpeed Varchar(50),
	IPAddr Varchar(100),
	MachineName Varchar(100),	
	DiskSize Numeric(38,6),
	[DiskUsedSpace] Varchar(300),
	[DiskFreeSpace] Varchar(300),
	[ProcesssorName] Varchar(300),
	BackupFileCount INT,
	[Servicepack] Varchar(500),
	[UploadFlag] [tinyint] NULL
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='Backup_Exists')
DROP TABLE Backup_Exists
GO
CREATE TABLE [Backup_Exists](
	[Back_Id] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[Back_Path] [nvarchar](100) NULL,
	[Back_File] [nvarchar](100) NULL,
	[Back_Date] [datetime] NULL
)
--GO
--DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 36 AND ProcessName = 'DataBaseBackupStatus'
--INSERT INTO Tbl_UploadIntegration
--SELECT 36,'DataBaseBackupStatus','DataBaseBackupStatus','Cs2Cn_Prk_DBBackupStatus',GETDATE()
--GO
--DELETE FROM Customupdownload WHERE SlNo = 131 AND Module = 'DataBaseBackupStatus'
--INSERT INTO Customupdownload
--SELECT 131,1,'DataBaseBackupStatus','DataBaseBackupStatus','Proc_Cs2Cn_DBBackupStatus','Proc_Cn2Cs_Dummy','Cs2Cn_Prk_DBBackupStatus',
--'Proc_Cs2Cn_DBBackupStatus','Transaction','Upload',1
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='Cs2Cn_Prk_DBBackupStatus')
DROP TABLE Cs2Cn_Prk_DBBackupStatus
GO
CREATE TABLE [Cs2Cn_Prk_DBBackupStatus](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[DBbackupdate] [datetime] NULL,
	[FilePath] [varchar](2000) NULL,
	[DbbackupFileName] [varchar](100) NULL,
	[DbName] [varchar](150) NULL,
	[DbStatus] [tinyint] NULL,
	[HotFixNumber] Numeric(36,0),
	[HFReleasedOn] DateTime,
	[HFFixedOn] DateTime,
	[UpdaterNumber] Numeric (36,0),
	[USReleasedOn] DateTime,
	[USFixedOn] DateTime,
	[CSVersionNumber] Varchar(100),
	[SyncVersion] Varchar(100),
	[WindowsVersion] Varchar(150),
	[RAMSize] Varchar(200),
	ProcSpeed Varchar(50),
	IPAddr Varchar(100),
	MachineName Varchar(100),	
	DiskSize Numeric(36,6),
	[UploadFlag] [nvarchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cs2Cn_DBBackupStatus')
DROP PROCEDURE Proc_Cs2Cn_DBBackupStatus
GO
--EXEC Proc_Cs2Cn_DBBackupStatus 0,'2013-09-12'
CREATE   PROCEDURE Proc_Cs2Cn_DBBackupStatus     
(
	@Po_ErrNo INT OUTPUT
	
)
AS
BEGIN
SET NOCOUNT ON
/********************************************************************************************
* PROCEDURE		: Proc_Cs2Cn_DBBackupStatus
* PURPOSE		: DbStatus Upload
* NOTES			:
* CREATED		: Murugan.R 
* CREATED DATE	: 16/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
**************************************************************************************
*
**************************************************************************************/
	SET @Po_ErrNo=0
	
	DELETE FROM Cs2Cn_Prk_DBBackupStatus WHERE UploadFlag = 'Y'
	INSERT INTO Cs2Cn_Prk_DBBackupStatus(DistCode,DBbackupdate,FilePath,DbbackupFileName,DbName,DbStatus,
	HotFixNumber,HFReleasedOn,HFFixedOn,UpdaterNumber,USReleasedOn,USFixedOn,
	CSVersionNumber,SyncVersion,WindowsVersion,RAMSize,
	ProcSpeed,IPAddr,MachineName,DiskSize,UploadFlag,SyncId,ServerDate)
	SELECT DistributorCode,DBBacupDate,FilePath,ZipFileName,DbName,DbStatus,
	HotFixNumber,HFReleasedOn,HFFixedOn,UpdaterNumber,USReleasedOn,USFixedOn,
	CSVersionNumber,SyncVersion,WindowsVersion,RAMSize,
	ProcSpeed,IPAddr,MachineName,DiskSize,'N',0,GETDATE()
	FROM DbbackupDt (NOLOCK) Cross Join Distributor (NOLOCK) WHERE UploadFlag=0
	Update DbbackupDt Set UploadFlag=1 where UploadFlag=0
END
GO
DECLARE @BackupPath AS VARCHAR(200)
SELECT @BackupPath = Condition FROM AutoBackupConfiguration WITH(NOLOCK) WHERE Description Like 'Take Backup in the following path%'
DELETE FROM AutoBackupConfiguration
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP2','AutomaticBackup','Take Backup/Extract Log while Logging on to the application',1,'',0.00,'2013-09-16',2)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP3','AutomaticBackup','Take Backup/Extract Log while Logging out of the application',1,'',0.00,'2013-09-16',3)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP4','AutomaticBackup','Take Compulsary Backup',1,'',1.00,'2013-09-16',4)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP5','AutomaticBackup','Clear Temporary tables while taking backup',1,'',0.00,'2013-09-16',5)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP6','AutomaticBackup','Compact database while taking backup',1,'',0.00,'2013-09-16',6)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP7','AutomaticBackup','Remove backup based on',1,'Count(s)',0.00,'2013-09-16',7)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP8','AutomaticBackup','Enter Number of Count(s)',1,'',10.00,'2013-09-16',8)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP9','AutomaticBackup','Take Backup in the following path…',1,@BackupPath,0.00,'2013-09-16',9)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP10','AutomaticBackup','Full Extract',1,'',0.00,'2013-09-16',10)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP11','AutomaticBackup','Incremental Extract',0,'',0.00,'2013-09-16',11)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP12','AutomaticBackup','Extract and Retain Data',0,'',0.00,'2013-09-16',12)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP13','AutomaticBackup','Extract and Delete Data',0,'',0.00,'2013-09-16',13)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP14','AutomaticBackup','Max Value',1,'',0.00,'2013-09-16',14)
INSERT INTO AutoBackupConfiguration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[BackupDate],[SeqNo]) VALUES ('AUTOBACKUP1','AutomaticBackup','Take Full Backup of the database Every time',1,'',0.00,'2013-09-16',1)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN('FN','TF') AND NAME='Fn_TaxNotAppliedProduct')
DROP FUNCTION Fn_TaxNotAppliedProduct
GO
CREATE FUNCTION Fn_TaxNotAppliedProduct(@Salid AS BIGINT)
RETURNS @NonTaxProduct TABLE (Salid BIGINT ,Slno INT)
AS
BEGIN
	INSERT INTO @NonTaxProduct(Salid,Slno)
	SELECT Salid,Slno-1 FROM SalesInvoiceProduct A (Nolock) 
	WHERE 
	NOT EXISTS(SELECT Salid,Prdslno FROM SalesInvoiceProductTax B (Nolock) where A.Salid=B.Salid and A.Slno=B.Prdslno)
	AND SalId=@Salid
	RETURN
END
GO
DELETE FROM HotSearcheditorHd where Formid = 238
INSERT INTO HotSearcheditorHd
SELECT 238,'Purchase Order','ReferenceNo','Select',
'SELECT PurOrderRefNo,CmpId,CmpName,SpmId,SpmName,PurOrderDate,CmpPoNo,CmpPoDate,PurOrderExpiryDate,FillAllPrds,GenQtyAuto,PurOrderStatus,
ConfirmSts,DownLoad,Upload,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValName,PrdCtgValLinkCode,SiteId,SiteCode,PurOrderValue,DispOrdVal,POType,Status
FROM (SELECT A.PurOrderRefNo,A.CmpId,B.CmpName,A.SpmId,C.SpmName,A.PurOrderDate,A.CmpPoNo,A.CmpPoDate,A.PurOrderExpiryDate,A.FillAllPrds,A.GenQtyAuto,
A.PurOrderStatus,A.ConfirmSts,A.DownLoad,A.Upload, ISNULL(A.CmpPrdCtgId,0) AS CmpPrdCtgId,  ISNULL(PCL.CmpPrdCtgName,'''') AS CmpPrdCtgName,         
ISNULL(A.PrdCtgValMainId,0) AS PrdCtgValMainId,  ISNULL(PCV.PrdCtgValName,'''') AS PrdCtgValName,ISNULL(PCV.PrdCtgValLinkCode,0) AS PrdCtgValLinkCode 
,SCM.SiteId,SCM.SiteCode,A.PurOrderValue,A.DispOrdVal,(CASE A.Download WHEN 1 THEN ''System Generated'' ELSE ''Manual'' END) AS POType,status          
FROM PurchaseOrderMaster A LEFT OUTER JOIN Company B ON B.CmpId=A.CmpId  LEFT OUTER JOIN Supplier C ON A.SpmId=C.SpmId  LEFT JOIN ProductCategoryLevel PCL 
ON PCL.CmpPrdCtgId=A.CmpPrdCtgId LEFT JOIN ProductCategoryValue PCV ON PCV.PrdCtgValMainId=A.PrdCtgValMainId  LEFT OUTER JOIN SiteCodeMaster SCM 
ON PCV.PrdCtgValMainId=SCM.PrdCtgValMainId AND SCM.SiteId=A.SiteID  INNER JOIN(SELECT purorderrefno,''Settled'' as Status from PurchaseOrderMaster 
WHERE Purorderrefno in (Select PurOrderRefNo FROM PurchaseReceipt) And PurOrderStatus = 1  UNION ALL SELECT purorderrefno,''Cancelled'' 
as Status from PurchaseOrderMaster WHERE Purorderstatus = 2 UNION ALL SELECT purorderrefno,''Expired'' as Status from PurchaseOrderMaster
WHERE PurOrderExpiryDate < CONVERT(varchar(10),GETDATE(),121) And purorderstatus = 0     UNION ALL Select purorderrefno,''Pending'' as Status 
from PurchaseOrderMaster WHERE Confirmsts = 1 And PurOrderStatus = 0 And convert(varchar(10),getdate(),121) between purorderdate and PurOrderExpiryDate 
And Purorderrefno in (Select PurOrderRefNo FROM PurchaseReceipt) UNION ALL SELECT purorderrefno,''Open'' as Status from PurchaseOrderMaster 
WHERE Purorderstatus = 0 And Confirmsts = 0 And convert(varchar(10),getdate(),121) between purorderdate and PurOrderExpiryDate 
And Purorderrefno Not In (Select PurOrderRefNo FROM PurchaseReceipt)    
UNION ALL Select purorderrefno,''Confirmed'' as Status from PurchaseOrderMaster WHERE Confirmsts = 1 And PurOrderStatus = 0 
And convert(varchar(10),getdate(),121) between purorderdate and PurOrderExpiryDate And Purorderrefno Not In (Select PurOrderRefNo FROM PurchaseReceipt)  )Z 
on Z.purorderrefno=A.purorderrefno ) AS A Order by PurOrderRefNo'
GO
DELETE FROM HotSearcheditorDt where Formid = 238
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,238,'ReferenceNo','Reference No','PurOrderRefNo',1100,2,'HotSch-26-2000-3',26)
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,238,'ReferenceNo','Date','PurOrderDate',1100,1,'HotSch-26-2000-4',26)
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,238,'ReferenceNo','PO Type','POType',1600,3,'HotSch-26-2000-39',26)
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,238,'ReferenceNo','status','Satus',1400,3,'HotSch-26-2000-40',26)
GO
--Auto Batch Transfer
DELETE FROM Configuration WHERE ModuleId='BotreeAutoBatchTransfer'
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('BotreeAutoBatchTransfer','Product Batch Download','Transfer Stock Automatically from old batch to new batch on new batch download',0,'',0.00,1)
GO
DELETE FROM Configuration WHERE ModuleId IN ('BCD19','GENCONFIG32')
INSERT INTO Configuration
SELECT 'BCD19','BillConfig_Display','Enable Latest Price in billing header field',0,'',0.00,19 UNION
SELECT 'GENCONFIG32','General Configuration','Display selected UOM in Purchase Receipt',1,'0',0.00,32
GO
UPDATE UTILITYPROCESS SET VersionId='3.1.0.0' WHERE ProcId=1 AND ProcessName='Core Stocky.Exe'
UPDATE UTILITYPROCESS SET VersionId='PV.0.0.3' WHERE ProcId=3 AND ProcessName='Sync.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',409
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 409)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(409,'D','2013-10-21',GETDATE(),1,'Core Stocky Service Pack 409')
GO