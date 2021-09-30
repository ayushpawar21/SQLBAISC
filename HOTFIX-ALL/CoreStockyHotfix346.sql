--[Stocky HotFix Version]=346
Delete from Versioncontrol where Hotfixid='346'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('346','2.0.0.5','D','2010-10-25','2010-10-25','2010-10-25',convert(varchar(11),getdate()),'JNJ 3rd Phase;Major:Order Booking Changes and Upload;Minor:')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 346' ,'346'
GO

--SRF-Nanda-163-001

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_OrderBooking]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_OrderBooking]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_OrderBooking]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderDate] [datetime] NULL,
	[OrdDlvDate] [datetime] NULL,
	[AllowBackOrder] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrdType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrdPriority] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrdDocRef] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Remarks] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RoundOffAmt] [numeric](38, 6) NULL,
	[OrdTotalAmt] [numeric](38, 6) NULL,
	[SalesmanCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesmanName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesRouteCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesRouteName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatCde] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdQty] [int] NULL,
	[PrdBilledQty] [int] NULL,
	[PrdSelRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-163-002

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_OrderBooking_Archive]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_OrderBooking_Archive]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_OrderBooking_Archive]
(
	[SlNo] [numeric](38, 0) NULL,
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
	[UploadFlag] [nvarchar](10) NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-163-003

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_SalesInvoiceOrders]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_SalesInvoiceOrders]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_SalesInvoiceOrders]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-163-004

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_SalesInvoiceOrders_Archive]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_SalesInvoiceOrders_Archive]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_SalesInvoiceOrders_Archive]
(
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-163-005

if not exists (Select Id,name from Syscolumns where name = 'Upload' and id in (Select id from 
	Sysobjects where name ='OrderBooking'))
begin
	ALTER TABLE [dbo].[OrderBooking]
	ADD [Upload] TINYINT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-163-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_OrderBooking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_OrderBooking]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_OrderBooking
UPDATE SalesInvoice SET Upload=0
EXEC Proc_Cs2Cn_OrderBooking 0
SELECT * FROM Cs2Cn_Prk_OrderBooking
SELECT * FROM OrderBooking 
ROLLBACK TRANSACTION
*/

CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_OrderBooking]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_OrderBooking
* PURPOSE		: To Extract Order Booking Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 17/08/2010
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
		UploadFlag		
	)
	SELECT @DistCode,OB.OrderNo,OB.OrderDate,OB.DeliveryDate,(CASE OB.AllowBackOrder WHEN 1 THEN 'Yes' ELSE 'No' END) AS AllowBackOrder,
	(CASE OB.OrdType WHEN 0 THEN 'Phone' WHEN 1 THEN 'In Person' ELSE 'Internet' END) AS OrdType,
	(CASE OB.Priority WHEN 0 THEN 'Normal' WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' ELSE 'High' END) AS Priority,
	OB.DocRefNo,OB.Remarks,OB.RndOffValue,OB.TotalAmount,SM.SMCode,SM.SMName,RM.RMCode,RM.RMName,R.RtrId,R.RtrCode,R.RtrName,
	P.PrdCCode,PB.PrdBatCode,OBP.TotalQty,OBP.BilledQty,OBP.Rate,OBP.GrossAmount,'N'
	FROM OrderBooking OB
	INNER JOIN OrderBookingProducts OBP ON OB.OrderNo=OBP.OrderNo AND OB.Upload=0 
	INNER JOIN Product P ON OBP.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON OBP.PrdBatId=PB.PrdBatId AND P.PrdId=PB.PrdId
	INNER JOIN SalesMan SM ON OB.SMId=SM.SMId
	INNER JOIN RouteMaster RM ON OB.RMId=RM.RMId
	INNER JOIN Retailer R ON OB.RtrId=R.RtrId

	UPDATE OrderBooking SET Upload=1 WHERE Upload=0 AND OrderNo IN (SELECT DISTINCT
	OrderNo FROM Cs2Cn_Prk_OrderBooking WHERE UploadFlag = 'N')
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-163-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_DailySales]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_DailySales]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_DailySales]
(
	@Po_ErrNo INT OUTPUT
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
		UploadFlag		
	)
	SELECT 	@DistCode,A.SalInvNo,A.SalInvDate,A.SalDlvDate,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,
	A.OtherCharges,0.00 AS InvLevelDiscAmt,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,A.LcnId,L.LcnCode,
	B.SMCode,B.SMName,C.RMCode,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,
	ISNULL(E.VehicleRegNo,'') AS VehicleName,D.DlvBoyName,F.RMCode,F.RMName,H.PrdCCode,I.CmpBatCode,
	G.BaseQty AS SalInvQty ,G.PrdUom1EditedSelRate,G.PrdUom1EditedNetRate,G.SalManFreeQty AS SalInvFree ,
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount,
	'N' AS UploadFlag
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

	--->Added By Nanda on 17/08/2010
	INSERT INTO Cs2Cn_Prk_SalesInvoiceOrders(DistCode,SalInvNo,OrderNo,OrderDate,UploadFlag)
	SELECT DISTINCT @DistCode,SI.SalInvNo,OB.OrderNo,OB.OrderDate,'N'
	FROM SalesInvoice SI,SalesinvoiceOrderBooking SIOB,OrderBooking OB
	WHERE SI.SalId=SIOB.SalId AND SIOB.OrderNo=OB.OrderNo AND SI.Upload=0 AND SI.DlvSts>3
	--->Till Here

	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'N') AND Dlvsts IN (4,5)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-163-008

DELETE FROM Configuration WHERE ModuleId='RET19'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('RET19','Retailer','Treat Retailer TaxGroup as Mandatory',1,'',0.00,19) 

--SRF-Nanda-163-009

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_Claim_SchemeDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_Claim_SchemeDetails]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimRefNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CmpSchCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SlabId] [int] NULL,
	[SalInvNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdCCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BilledQty] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimAmount] [numeric](38, 6) NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-163-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Scheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Scheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM DayEndProcess	WHERE ProcId = 12
--UPDATE DayEndProcess SET NextUpDate='2009-12-28' WHERE ProcId = 12
--DELETE FROM  Cs2Cn_Prk_ClaimAll
EXEC Proc_Cs2Cn_Claim_Scheme
SELECT * FROM Cs2Cn_Prk_ClaimAll
ROLLBACK TRANSACTION
*/
CREATE       PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Scheme]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_Claim_Scheme
* PURPOSE		: Extract Scheme Claim Details from CoreStocky to Console
* NOTES:
* CREATED		: Mahalakshmi.A  19-08-2008
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* 13/11/2009 Nandakumar R.G    Added WDS Claim
*********************************/
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType IN('Scheme Claim','Window Display Claim')

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode,CmpName,ClaimType,ClaimMonth,ClaimYear,ClaimRefNo,ClaimDate,ClaimFromDate,ClaimToDate,DistributorClaim,
		DistributorRecommended,ClaimnormPerc,SuggestedClaim,TotalClaimAmt,Remarks,Description,Amount1,ProductCode,Batch,
		Quantity1,Quantity2,Amount2,Amount3,TotalAmount,SchemeCode,BillNo,BillDate,RetailerCode,RetailerName,
		TotalSalesInValue,PromotedSalesinValue,OID,Discount,FromStockType,ToStockType,Remark2,Remark3,PrdCode1,
		PrdCode2,PrdName1,PrdName2,Date2,UploadFlag		
	)
	SELECT 	@DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,CH.FromDate,CH.ToDate,
	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount AS TotAmt,
	'',SM.SchDsc,(CASE SM.SchType WHEN 2 THEN SL.PurQty ELSE 0 END) AS SchemeOnAmt,ISNULL(P.PrdDCode,'') AS PrdDCode,
	ISNULL(P.PrdName,'') AS PrdName,(CASE SM.SchType WHEN 1 THEN CAST(SL.PurQty AS INT) ELSE 0 END) AS SchemeOnQty,
	ISNULL(SF.FreeQty,0) As SchemeQty,CD.FreePrdVal+GiftPrdVal as FGQtyValue,Cd.Discount AS SchemeAmt,
	(CD.FreePrdVal+GiftPrdVal+CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),'','',0,0,0,0,'','','','','','','','',GETDATE(),'N'
	FROM SchemeMaster SM
	INNER JOIN SchemeSlabs SL ON SM.SchId=SL.SchId
	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
	INNER JOIN Company CM ON CM.CmpId=CH.CmpId	
	LEFT OUTER JOIN SchemeSlabFrePrds SF ON SM.SchId=SF.SchId
	LEFT OUTER JOIN Product P ON SF.PrdId=P.PrdId
	WHERE CH.Confirm=1 AND CH.Upload='N'

	UNION	
	--SELECT 	@DistCode,CM.CmpName,'Window Display Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,
	SELECT 	@DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,	
	CH.FromDate,CH.ToDate,
	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,SUM(CD.ClmAmount),SUM(CD.RecommendedAmount) AS TotAmt,
	'',SM.SchDsc,0 AS SchemeOnAmt,'WDS' AS PrdDCode,'Window Display Claim' AS PrdName,0 AS SchemeOnQty,
	0 As SchemeQty,AdjAmt,SUM(Cd.Discount) AS SchemeAmt,
	SUM(CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),R.RtrCode,R.RtrName,0,0,0,0,'','','','','','','','',GETDATE(),'N'
	FROM SchemeMaster SM
	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
	INNER JOIN Company CM ON CM.CmpId=CH.CmpId
	INNER JOIN SalesInvoiceWindowDisplay SIW ON SIW.SchId=SM.SchId AND CH.ClmId=SIW.SchClmId
	INNER JOIN SalesInvoice SI ON SI.SalId=SIW.SalId 	
	INNER JOIN Retailer R ON SI.RtrId=R.RtrId 	
	WHERE CH.Confirm=1 AND SM.SchType=4 AND CH.Upload='N'
	GROUP BY CM.CmpName,CH.ClmDate,CH.ClmCode,SM.CmpSchCode,CH.ClmDate,CH.FromDate,CH.ToDate,
	SM.SchId,CD.RecommendedAmount,CD.ClmPercentage,SM.SchDsc,AdjAmt,
	R.RtrCode,R.RtrName

	--->Added By Nanda on 13/10/2010 for Claim Details
	DELETE FROM Cs2Cn_Prk_Claim_SchemeDetails WHERE UploadFlag='Y'

	INSERT INTO Cs2Cn_Prk_Claim_SchemeDetails(DistCode,ClaimRefNo,CmpSchCode,SlabId,SalInvNo,PrdCCode,BilledQty,ClaimAmount,UploadFlag)
	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISL.SlabId,SI.SalInvNo,P.PrdCCode,SUM(SIP.BaseQty),SUM(SISL.FlatAmount+SISL.DiscountPerAmount),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeLinewise SISL,SchemeMaster SM,
	SalesInvoice SI,Product P,SalesInvoiceProduct SIP
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND
	SISL.SchClmId=CD.ClmId AND SISL.SchId=SM.SchId AND SISL.SalId=Si.SalId AND SISl.PrdId=P.PrdId
	AND SISL.RowId =SIP.SlNo AND SISL.SalId=SIP.SalId AND SI.SalId = SIP.SalId 
	GROUP BY CH.ClmCode,SM.CmpSchCode,SISL.SlabId,SI.SalInvNo,P.PrdCCode
	HAVING SUM(SISL.FlatAmount+SISL.DiscountPerAmount)>0
	--->Till Here

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-163-011

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
SELECT * FROM BillAppliedSchemeHd
DELETE FROM ApportionSchemeDetails
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 2,2
SELECT * FROM ApportionSchemeDetails WHERE TransId=2
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
		GrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
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
	DECLARE @TempSchGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	--NNN
	DECLARE @TempPrdGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
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
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF  @QPS<>0 AND @Combi=0
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN			
				--SELECT @SchId,@MRP,@WithTax,@SlabId	
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 AND @Combi=0
			BEGIN
--				IF @QPSDateQty=2 
--				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
					--NNN
					IF @QPSDateQty=2 
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,BilledPrdHdForQPSScheme BP
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
					(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
	
	INSERT INTO @QPSGivenDisc
	SELECT A.SchId,SUM(A.DiscountPerAmount) FROM 
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount
	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,
	@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
	AND SISl.SlabId<=A.SlabId) A
	GROUP BY A.SchId
	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-B.Amount FROM ApportionSchemeDetails A,@QPSGivenDisc B
	WHERE A.SchId=B.SchId
	GROUP BY A.SchId,B.Amount
	SELECT * FROM @QPSNowAvailable
	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-163-012

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_DailyBusinessDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_DailyBusinessDetails]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_DailyBusinessDetails]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO


--SRF-Nanda-163-013

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_DailyBusinessDetails_Archive]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_DailyBusinessDetails_Archive]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_DailyBusinessDetails_Archive]
(
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadDate] [datetime] NULL,
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
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-163-014

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_DBDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_DBDetails]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_DBDetails]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IPAddress] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MachineName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBId] [int] NULL,
	[DBName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBCreatedDate] [datetime] NULL,
	[DBRestoredDate] [datetime] NULL,
	[DBRestoreId] [int] NULL,
	[DBFileName] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-163-015

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_DBDetails_Archive]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_DBDetails_Archive]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_DBDetails_Archive]
(
	[SlNo] [numeric](38, 0) NULL,
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
	[UploadedDate] [datetime]
) ON [PRIMARY]
GO


--SRF-Nanda-163-016

if exists (select * from dbo.sysobjects where id = object_id(N'[CurrentDB]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [CurrentDB]
GO

CREATE TABLE [dbo].[CurrentDB]
(
	[DBName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-163-017

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_DailyBusinessDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_DailyBusinessDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DailyBusinessDetails
EXEC Proc_Cs2Cn_DailyBusinessDetails 0
SELECT * FROM Cs2Cn_Prk_DailyBusinessDetails
ROLLBACK TRANSACTION
*/

CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_DailyBusinessDetails]
(
	@Po_ErrNo INT OUTPUT
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
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-163-018A

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Get_IP_Address]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Get_IP_Address]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_Get_IP_Address] 
(
	@IP VARCHAR(40) OUT
)
AS
/*********************************
* PROCEDURE		: Proc_Get_IP_Address
* PURPOSE		: To Extract IP Address
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 02/10/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON

	DECLARE @IPLINE VARCHAR(200)
	DECLARE @POS INT
	SET @IP = NULL

	CREATE TABLE #Temp (IPLine varchar(200))
	INSERT #Temp EXEC MASTER..XP_CmdShell 'ipconfig'
	SELECT @IPLine = IPLine
	FROM #TEMP
	WHERE UPPER (IPLine) LIKE '%IP ADDRESS%'

	IF (ISNULL (@IPLINE,'***') != '***')
	BEGIN 
		SET @POS = CHARINDEX (':',@IPLine,1);
		SET @IP = RTRIM(LTRIM(SUBSTRING (@IPLine,@POS + 1,LEN(@IPLine)-@POS)))
	END 
	DROP TABLE #Temp
	SET NOCOUNT OFF

END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-163-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_DBDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_DBDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DBDetails
EXEC Proc_Cs2Cn_DBDetails 0
SELECT * FROM Cs2Cn_Prk_DBDetails
ROLLBACK TRANSACTION
*/

CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_DBDetails]
(
	@Po_ErrNo INT OUTPUT
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

	INSERT INTO Cs2Cn_Prk_DBDetails(DistCode,IPAddress,MachineName,DBId,DBName,DBCreatedDate,DBRestoredDate,DBRestoreId,DBFileName,UploadFlag)
	SELECT @DistCode,@IP,@@ServerName,DBId,Name,CrDate,CrDate,0,FileName,'N' FROM Master.dbo.SysDataBases SD,CurrentDB CD
	WHERE SD.Name=CD.DBName

	UPDATE B SET B.DBRestoredDate=A.Restore_Date,B.DBRestoreId=A.Restore_History_Id
	FROM Cs2Cn_Prk_DBDetails B,
	(SELECT * FROM MSDB..RestoreHistory RS
	WHERE RS.Destination_DataBase_Name=@DBName
	AND RS.Restore_Date IN (SELECT MAX(Restore_Date) FROM MSDB..RestoreHistory WHERE Destination_DataBase_Name= @DBName)) A
	WHERE B.DBName=A.Destination_DataBase_Name
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-163-019

EXEC master.dbo.sp_configure 'show advanced options', 1

RECONFIGURE

EXEC master.dbo.sp_configure 'xp_cmdshell', 1

RECONFIGURE

--SRF-Nanda-163-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Dummy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Dummy]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_Dummy 0
ROLLBACK TRANSACTION	
*/
CREATE  PROCEDURE [dbo].[Proc_Cs2Cn_Dummy]
(
	@Po_ErrNo  INT OUTPUT
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
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- DEFAULT VALUES SCRIPT FOR Tbl_UploadIntegration
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

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (22,'Purchase Return','Cn2Cs_Prk_PurchaseReturnApproval','Proc_Import_PurchaseReturnApproval',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (23,'Scheme Master Control','Cn2Cs_Prk_NVSchemeMasterControl','Proc_ImportNVSchemeMasterControl',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (24,'Claim Norm','Cn2Cs_Prk_ClaimNorm','Proc_Import_ClaimNorm',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (25,'Reason Master','Cn2Cs_Prk_ReasonMaster','Proc_Import_ReasonMaster',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (26,'Bulletin Board','Cn2Cs_Prk_BulletinBoard','Proc_Import_BulletinBoard',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (27,'ReUpload','Cn2Cs_Prk_ReUpload','Proc_Import_ReUpload',0,500,GETDATE())

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

-- DEFAULT VALUES SCRIPT FOR CustomUpDownload

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
VALUES (108,1,'Sample Issue','Sample Issue','Proc_Cs2Cn_SampleIssue','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleIssue','Proc_ValidateSampleIssue','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (109,1,'Sample Receipt','Sample Receipt','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReceipt','Proc_ValidateSampleIssue','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (110,1,'Sample Return','Sample Return','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReturn','Proc_ValidateSampleIssue','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (111,1,'Scheme Utilization','Scheme Utilization','Proc_Cs2Cn_SchemeUtilization','Proc_Import_SchemeUtilization','Cs2Cn_Prk_SchemeUtilization','Proc_Cn2Cs_SchemeUtilization','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (112,1,'Salesman','Salesman','Proc_Cs2Cn_Salesman','Proc_Import_Salesman','Cs2Cn_Prk_Salesman','Proc_Cn2Cs_Salesman','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (113,1,'Route','Route','Proc_Cs2Cn_Route','Proc_Import_Route','Cs2Cn_Prk_Route','Proc_Cn2Cs_Route','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (114,1,'Cluster Assign','Cluster Assign','Proc_Cs2Cn_ClusterAssign','Proc_Import_ClusterAssign','Cs2Cn_Prk_ClusterAssign','Proc_Cn2Cs_ClusterAssign','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (115,1,'Retailer Route','Retailer Route','Proc_Cs2Cn_RetailerRoute','Proc_Import_RetailerRoute','Cs2Cn_Prk_RetailerRoute','Proc_Cn2Cs_RetailerRoute','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (116,1,'Order Booking','Order Booking','Proc_Cs2Cn_OrderBooking','Proc_Import_OrderBooking','Cs2Cn_Prk_OrderBooking','Proc_Cn2Cs_OrderBooking','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (117,1,'Sales Invoice Orders','Sales Invoice Orders','Proc_Cs2Cn_Dummy','Proc_Import_SalesInvoiceOrders','Cs2Cn_Prk_SalesInvoiceOrders','Proc_Cn2Cs_SalesInvoiceOrders','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (118,1,'Scheme Claim Details','Scheme Claim Details','Proc_Cs2Cn_Dummy','Proc_Import_SchemeClaimDetails','Cs2Cn_Prk_Claim_SchemeDetails','Proc_Cn2Cs_SchemeClaimDetails','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (119,1,'Daily Business Details','Daily Business Details','Proc_Cs2Cn_DailyBusinessDetails','Proc_Import_DailyBusinessDetails','Cs2Cn_Prk_DailyBusinessDetails','Proc_Cn2Cs_DailyBusinessDetails','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (120,1,'DB Details','DB Details','Proc_Cs2Cn_DBDetails','Proc_Import_DBDetails','Cs2Cn_Prk_DBDetails','Proc_Cn2Cs_DBDetails','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (121,1,'Download Trace','DownloadTracing','Proc_Cs2Cn_DownLoadTracing','Proc_ImportDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','Proc_Cn2CsDownLoadTracing','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (122,1,'Upload Trace','UploadTracing','Proc_Cs2Cn_UpLoadTracing','Proc_ImportUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','Proc_Cn2CsUpLoadTracing','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (123,1,'Daily Retailer Details','Daily Retailer Details','Proc_Cs2Cn_DailyRetailerDetails','','Cs2Cn_Prk_DailyRetailerDetails','','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (124,1,'Daily Product Details','Daily Product Details','Proc_Cs2Cn_DailyProductDetails','','Cs2Cn_Prk_DailyProductDetails','','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (125,1,'Upload Record Check','UploadRecordCheck','Proc_Cs2Cn_UploadRecordCheck','','Cs2Cn_Prk_UploadRecordCheck','','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (126,1,'ReUpload Initiate','ReUploadInitiate','Proc_Cs2Cn_ReUploadInitiate','','Cs2Cn_Prk_ReUploadInitiate','','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (127,1,'For Integration','ForIntegration','Proc_IntegrationHouseKeeping','','Cs2Cn_Prk_IntegrationHouseKeeping','','Transaction','Upload',1)

-- DEFAULT VALUES SCRIPT FOR CustomUpDownload

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

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,1,'Purchase Return Approval','Purchase Return Approval','Proc_Cs2Cn_PurchaseReturnApproval','Proc_Import_PurchaseReturnApproval','Cn2Cs_Prk_PurchaseReturnApproval','Proc_Cn2Cs_PurchaseReturnApproval','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (218,1,'Scheme Master Control','Scheme Master Control','Proc_CS2CNNVSchemeMasterControl','Proc_ImportNVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','Proc_Cn2Cs_NVSchemeMasterControl','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (219,1,'Claim Norm Mapping','Claim Norm Mapping','Proc_Cs2Cn_ClaimNorm','Proc_Import_ClaimNorm','Cn2Cs_Prk_ClaimNorm','Proc_Cn2Cs_ClaimNorm','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (220,1,'Reason Master','Reason Master','Proc_Cs2Cn_ReasonMaster','Proc_Import_ReasonMaster','Cn2Cs_Prk_ReasonMaster','Proc_Cn2Cs_ReasonMaster','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (222,1,'Bulletin Board','BulletingBoard','Proc_Cs2Cn_BulletinBoard','Proc_Import_BulletinBoard','Cn2Cs_Prk_BulletinBoard','Proc_Cn2Cs_BulletinBoard','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (223,1,'ReUpload','ReUpload','Proc_Cs2Cn_ReUpload','Proc_Import_ReUpload','Cn2Cs_Prk_ReUpload','Proc_Cn2Cs_ReUpload','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (224,1,'Configuration','Configuration','Proc_Cs2Cn_Configuration','Proc_Import_Configuration','Cn2Cs_Prk_Configuration','Proc_Cn2Cs_Configuration','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (225,1,'Claim Settlement','Claim Settlement','Proc_Cs2Cn_ClaimSettlement','Proc_Import_ClaimSettlement','Cn2Cs_Prk_ClaimSettlement','Proc_Cn2Cs_ClaimSettlement','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (230,1,'Cluster Master','Cluster Master','Proc_Cs2Cn_ClusterMaster','Proc_Import_ClusterMaster','Cn2Cs_Prk_ClusterMaster','Proc_Cn2Cs_ClusterMaster','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (231,1,'Cluster Group','Cluster Group','Proc_Cs2Cn_ClusterGroup','Proc_Import_ClusterGroup','Cn2Cs_Prk_ClusterGroup','Proc_Cn2Cs_ClusterGroup','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (232,1,'Cluster Assign Approval','Cluster Assign Approval','Proc_Cs2Cn_ClusterAssignApproval','Proc_Import_ClusterAssignApproval','Cn2Cs_Prk_ClusterAssignApproval','Proc_Cn2Cs_ClusterAssignApproval','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (233,1,'Supplier Master','Supplier Master','Proc_Cs2Cn_SupplierMaster','Proc_Import_SupplierMaster','Cn2Cs_Prk_SupplierMaster','Proc_Cn2Cs_SupplierMaster','Master','Download',1)	

-- DEFAULT VALUES SCRIPT FOR CustomUpDownloadCount

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
VALUES (108,1,'Sample Issue','Sample Issue','Cs2Cn_Prk_SampleIssue','Cs2Cn_Prk_SampleIssue','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (109,1,'Sample Receipt','Sample Receipt','Cs2Cn_Prk_SampleReceipt','Cs2Cn_Prk_SampleReceipt','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (110,1,'Sample Return','Sample Return','Cs2Cn_Prk_SampleReturn','Cs2Cn_Prk_SampleReturn','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (111,1,'Scheme Utilization','Scheme Utilization','Cs2Cn_Prk_SchemeUtilization','Cs2Cn_Prk_SchemeUtilization','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (112,1,'Download Trace','DownloadTracing','ETL_PRK_CS2CNDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (113,1,'Upload Trace','UploadTracing','ETL_PRK_CS2CNUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (114,1,'Upload Record Check','UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (115,1,'ReUpload Initiate','ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (116,1,'For Integration','ForIntegration','Cs2Cn_Prk_IntegrationHouseKeeping','Cs2Cn_Prk_IntegrationHouseKeeping','','','','Upload','0',0,'0',0,0,'')

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
VALUES (215,1,'Scheme','Scheme Master','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,2,'Scheme','Scheme Attributes','Etl_Prk_Scheme_OnAttributes','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,3,'Scheme','Scheme Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,4,'Scheme','Scheme Slabs','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,5,'Scheme','Scheme Rule Setting','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,6,'Scheme','Scheme Free Products','Etl_Prk_Scheme_Free_Multi_Products','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,7,'Scheme','Scheme Combi Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,8,'Scheme','Scheme On Another Product','Etl_Prk_Scheme_OnAnotherPrd','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (216,1,'Purchase Receipt','Purchase Receipt','Cn2Cs_Prk_BLPurchaseReceipt','ETLTempPurchaseReceipt','CmpInvNo','','DownLoadStatus=0','Download','0',0,'0',0,0,'SELECT CmpInvNo AS [Invoice No],InvDate AS [Invoice Date] FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,1,'Purchase Return Approval','Purchase Return Approval','Cn2Cs_Prk_PurchaseReturnApproval','Cn2Cs_Prk_PurchaseReturnApproval','DownLoadFlag','','','Download','0',0,'0',0,0,'')

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
VALUES (222,1,'Bulletin Board','BulletingBoard','Cn2Cs_Prk_BulletingBoard','Cn2Cs_Prk_BulletingBoard','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (223,1,'ReUpload','ReUpload','Cn2Cs_Prk_ReUpload','Cn2Cs_Prk_ReUpload','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (224,1,'Configuration','Configuration','Cn2Cs_Prk_Configuration','Cn2Cs_Prk_Configuration','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (225,1,'Claim Settlement','Claim Settlement','Cn2Cs_Prk_ClaimSettlement','Cn2Cs_Prk_ClaimSettlement','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (230,1,'Cluster Master','Cluster Master','Cn2Cs_Prk_ClusterMaster','ClusterMaster','ClusterId','','','Download','0',0,'0',0,0,'SELECT ClusterCode AS [Cluster Code],ClusterName AS [Cluster Name] FROM ClusterMaster WHERE ClusterId>OldMax')

if not exists (select * from hotfixlog where fixid = 346)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(346,'D','2010-10-25',getdate(),1,'Core Stocky Service Pack 346')