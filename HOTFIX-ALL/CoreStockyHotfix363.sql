--[Stocky HotFix Version]=363
Delete from Versioncontrol where Hotfixid='363'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('363','2.0.0.5','D','2011-03-17','2011-03-17','2011-03-17',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel and Henkel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 363' ,'363'
GO

--SRF-Nanda-211-001

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
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-211-002

DELETE FROM RptDetails WHERE RptId IN (17,18,19)

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','1','FromDate','-1','','','From Date*','','1','','10','0','0','Enter From Date','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','2','ToDate','-1','','','To Date*','','1','','11','0','0','Enter To Date','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','3','Vehicle','-1','','VehicleId,VehicleCode,VehicleRegNo','Vehicle...','','1','','36','0','0','Press F4/Double Click to Select Vehicle','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','4','VehicleAllocationMaster','-1','','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','','1','','37','0','0','Press F4/Double Click to Select Vehicle Allocation Number','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','5','Salesman','-1','','SMId,SMCode,SMName','Salesman...','','1','','1','0','0','Press F4/Double Click to Select Salesman','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','6','RouteMaster','-1','','RMId,RMCode,RMName','Delivery Route...','','1','','35','0','0','Press F4/Double Click to Select Delivery Route','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','7','Retailer','-1',NULL,'RtrId,RtrCode,RtrName','Retailer Group...',NULL,'1',NULL,'215',NULL,NULL,'Press F4/Double Click to select Retailer Group','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','8','Retailer','-1',NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,'1',NULL,'3',NULL,NULL,'Press F4/Double Click to select Retailer','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','9','UOMMaster','-1','','UOMId,UOMCode,UOMDescription','Display in*','','1','','129','1','1','Press F4/Double Click to Select UOM','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','10','SalesInvoice','-1',NULL,'SalId,SalInvRef,SalInvNo','From Bill No...',NULL,'1',NULL,'14','1','0','Press F4/Double Click to select From Bill','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('17','11','SalesInvoice','-1',NULL,'SalId,SalInvRef,SalInvNo','To Bill No...',NULL,'1',NULL,'15','1','0','Press F4/Double Click to select To Bill','0')


INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','1','FromDate','-1','','','From Date*','','1','','10','0','0','Enter From Date','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','2','ToDate','-1','','','To Date*','','1','','11','0','0','Enter To Date','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','3','Vehicle','-1','','VehicleId,VehicleCode,VehicleRegNo','Vehicle...','','1','','36','0','0','Press F4/Double Click to Select Vehicle','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','4','VehicleAllocationMaster','-1','','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','','1','','37','0','0','Press F4/Double Click to Select Vehicle Allocation Number','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','5','Salesman','-1','','SMId,SMCode,SMName','Salesman...','','1','','1','0','0','Press F4/Double Click to Select Salesman','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','6','RouteMaster','-1','','RMId,RMCode,RMName','Delivery Route...','','1','','35','0','0','Press F4/Double Click to Select Delivery Route','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','7','Retailer','-1',NULL,'RtrId,RtrCode,RtrName','Retailer Group...',NULL,'1',NULL,'215',NULL,NULL,'Press F4/Double Click to select Retailer Group','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','8','Retailer','-1',NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,'1',NULL,'3',NULL,NULL,'Press F4/Double Click to select Retailer','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','9','UOMMaster','-1','','UOMId,UOMCode,UOMDescription','Display in*','','1','','129','1','1','Press F4/Double Click to Select UOM','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','10','SalesInvoice','-1',NULL,'SalId,SalInvRef,SalInvNo','From Bill No...',NULL,'1',NULL,'14','1','0','Press F4/Double Click to select From Bill','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('18','11','SalesInvoice','-1',NULL,'SalId,SalInvRef,SalInvNo','To Bill No...',NULL,'1',NULL,'15','1','0','Press F4/Double Click to select To Bill','0')


INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('19','1','FromDate','-1','','','From Date*','','1','','10','0','1','Enter From Date','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('19','2','ToDate','-1','','','To Date*','','1','','11','0','1','Enter To Date','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('19','3','Vehicle','-1','','VehicleId,VehicleCode,VehicleRegNo','Vehicle...','','1','','36','0','0','Press F4/Double Click to Select Vehicle','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('19','4','VehicleAllocationMaster','-1','','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','','1','','37','0','0','Press F4/Double Click to Select Vehicle Allocation Number','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('19','5','Salesman','-1','','SMId,SMCode,SMName','Salesman...','','1','','1','0','0','Press F4/Double Click to Select Salesman','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('19','6','RouteMaster','-1','','RMId,RMCode,RMName','Delivery Route...','','1','','35','0','0','Press F4/Double Click to Select Delivery Route','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('19','7','Retailer','-1',NULL,'RtrId,RtrCode,RtrName','Retailer Group...',NULL,'1',NULL,'215',NULL,NULL,'Press F4/Double Click to select Retailer Group','0')

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('19','8','Retailer','-1',NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,'1',NULL,'3',NULL,NULL,'Press F4/Double Click to select Retailer','0')

--SRF-Nanda-211-003

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
DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 8,1,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
SELECT * FROM BillAppliedSchemeHd (NOLOCK)
--SELECT * FROM ApportionSchemeDetails (NOLOCK)
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=522
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
SELECT * FROM BillAppliedSchemeHd
SELECT * FROM BilledPrdHdForScheme
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
	DECLARE @QPSGivenPoints TABLE
	(
		SchId   INT,		
		Points  NUMERIC(38,0)
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
--		SELECT '1',* FROM @TempBilled1
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
--		SELECT '2',* FROM @TempBilled1
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
--		SELECT '3',* FROM @TempBilled1
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
--		SELECT '4',* FROM @TempBilled1
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
--		SELECT '5',* FROM @TempBilled1
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
--	SELECT '6',* FROM @TempBilled1
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
				FlatAmt * @NoOfTimes
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
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime 
		FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
		AND A.SchId=@Pi_SchId
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
		AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)

			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
			AND SchemeAmount =0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId ) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A 
	WHERE SchId=@Pi_SchId GROUP BY A.SchId	
	
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

	--->Added By Nanda for Points on 10/01/2011  
	INSERT INTO @QPSGivenPoints
	SELECT SchId,SUM(Points)
	FROM
	(
		SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(Points-ReturnPoints,0) AS Points
		FROM SalesInvoiceSchemeDtPoints SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3	
	) A  
	WHERE SchId=@Pi_SchId
	GROUP BY A.SchId	
	--->Till Here

	--->Added By Nanda on 21/02/2011
	UPDATE A SET SchemeAmount=B.SchemeAmount
	FROM BillAppliedSchemeHd A,
	(
		SELECT SchId,SlabId,MAX(SchemeAmount) AS SchemeAmount FROM BillAppliedSchemeHd
		WHERE TransID=@Pi_TransId AND UsrId=@Pi_UsrId
		GROUP BY SchId,SlabId 
	) B
	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId  AND A.SchId=@Pi_SchId
	--->Till Here

	--->For Scheme Amount Update
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

	--->For Scheme Points Update
	UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=CAST(BillAppliedSchemeHd.Points-A.Points AS NUMERIC(38,4))
	FROM @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

	--->For QPS Reset
	DECLARE @MSSchId AS INT
	DECLARE @MaxSlabId AS INT
	DECLARE @AmtToReduced AS NUMERIC(38,6)
	SET @AmtToReduced=0
	DECLARE Cur_QPSSlabs CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
				SELECT @AmtToReduced=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@MSSchId

--				SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHd 
--				WHERE SlabId=@MaxSlabId AND SchId=@MSSchId

				UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND SchemeAmount<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)		
				BEGIN
					
					SELECT @AmtToReduced=ABS(SchemeAmount) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND SchemeAmount<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

					UPDATE BillAppliedSchemeHd SET SchemeAmount=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @AmtToReduced=0
				END
			END
		END
		ELSE
		BEGIN
--			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
--			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
--			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId

			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
	
	--->For Points QPS Reset
	SET @MSSchId=0
	SET @MaxSlabId=0
	DECLARE @PointsToReduced AS NUMERIC(38,0)
	SET @PointsToReduced=0
	DECLARE Cur_QPSSlabsPoints CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabsPoints
	FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenPoints WHERE SchId=@MSSchId)
			BEGIN
				SELECT @PointsToReduced=ISNULL(SUM(Points),0) FROM @QPSGivenPoints WHERE SchId=@MSSchId

				UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				
				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId )		
				BEGIN
					SELECT @PointsToReduced=ABS(Points) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

					UPDATE BillAppliedSchemeHd SET Points=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @PointsToReduced=0
				END
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabsPoints
	DEALLOCATE Cur_QPSSlabsPoints
	--->Till Here

	--->Added By Boo for Free Product Calculation For QPS without QPS Reset
	IF @QPS<>0 AND @QPSReset=0 --AND @QPSApplicapple=1
	BEGIN
		UPDATE A SET FreeToBeGiven=FreeToBeGiven-FreeQty,GiftToBeGiven=GiftToBeGiven-GiftQty FROM BillAppliedSchemeHd A INNER JOIN
		(SELECT A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,
		(SUM(A.FreeQty)-SUM(A.ReturnFreeQty)) AS FreeQty,
		(SUM(A.GiftQty)-SUM(A.ReturnGiftQty)) AS GiftQty FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId=B.SalId 
		WHERE A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId AND B.DlvSts>3
		GROUP BY A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId) B ON
		A.SchId=B.SchId AND A.FreePrdId=B.FreePrdId AND	A.GiftPrdId=B.GiftPrdId 
		WHERE A.TransId=@Pi_TransId AND A.Usrid=@Pi_UsrId
	END
	--->Till Here	

	DELETE FROM BillAppliedSchemeHd WHERE ROUND(SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd,3)=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

	IF @QPSReset<>0
	BEGIN
		UPDATE B SET B.NoOfTimes=A.NoOfTimes,B.SchemeAmount=A.SchemeAmount
		FROM BillAppliedSchemeHd B,
		(
			SELECT SchId,SlabId,MAX(NoOfTimes) AS NoOfTimes,MAX(SchemeAmount) AS SchemeAmount
			FROM BillAppliedSchemeHd GROUP BY SchId,SlabId
		) AS A
		WHERE B.SchId=A.SchId AND B.SlabId=A.SlabId AND B.SchId=@Pi_SchId AND B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId 
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

	--->Added By Nanda on 25/01/2011
	IF @QPS=1
	BEGIN
		INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,PrdId,PrdBatId,SchType)
		SELECT DISTINCT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,PrdId,PrdBatId,SchType FROM 
		(SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,SchType FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId) A
		CROSS JOIN 
		(
			SELECT A.PrdId,A.PrdBatId FROM BilledPrdHdForQPSScheme A (NOLOCK) 
			INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON A.RowId=10000 AND 
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End		
			AND CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatId AS NVARCHAR(10)) 
			NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId
			AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId
		)
		)B
		WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		NOT IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
	END
	--->Till Here
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-211-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_PurchaseReceiptMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_PurchaseReceiptMapping]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_Import_PurchaseReceiptMapping '<Root></Root>'

CREATE    PROCEDURE [dbo].[Proc_Import_PurchaseReceiptMapping]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_ImportConfiguration
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_PurchaseReceiptMapping
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE DownLoadFlag='Y'

	INSERT INTO Cn2Cs_Prk_PurchaseReceiptMapping(DistCode,CompInvNo,CompInvDate,SupplierCode,PrdCCode,PrdName,
	PrdMapCode,PrdMapName,UOMCode,Qty,Rate,GrossAmount,DiscAmount,TaxAmount,NetAmount,FreeSchemeFlag,SlNo,DownLoadFlag)
	SELECT DistCode,CompInvNo,CompInvDate,SupplierCode,PrdCCode,PrdName,
	PrdMapCode,PrdMapName,UOMCode,Qty,Rate,GrossAmount,DiscAmount,TaxAmount,NetAmount,FreeSchemeFlag,SlNo,DownLoadFlag
	FROM OPENXML (@hdoc,'/Root/Console2Cs_PurchaseReceiptMapping',1)
	WITH 
	(	
			[DistCode]			NVARCHAR(30), 
			[CompInvNo]			NVARCHAR(25),
			[CompInvDate]		DATETIME,
			[SupplierCode]		NVARCHAR(50),
			[PrdCCode]			NVARCHAR(50),
			[PrdName]			NVARCHAR(200),			
			[PrdMapCode]		NVARCHAR(50),			
			[PrdMapName]		NVARCHAR(200),			
			[UOMCode]			NVARCHAR(25),			
			[Qty]				INT,			
			[Rate]				NUMERIC(38,6),
			[GrossAmount]		NUMERIC(38,6),
			[DiscAmount]		NUMERIC(38,6),
			[TaxAmount]			NUMERIC(38,6),
			[NetAmount]			NUMERIC(38,6),
			[FreeSchemeFlag]	NVARCHAR(5),					
			[SlNo]				INT,			
			[DownLoadFlag]		NVARCHAR(10) 
	) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-211-005-From Kalai

IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='RptAKSOExcelHeaders')
	BEGIN
		CREATE TABLE [RptAKSOExcelHeaders]
		(
			[RptId] [int] ,
			[SlNo] [int] ,
			[FieldName] [nvarchar](50) ,
			[DisplayName] [nvarchar](50) ,
			[DisplayFlag] [int] ,
			[LngId] [int] 
		) 
	END 
DELETE FROM RptAKSOExcelHeaders WHERE Rptid=501
INSERT INTO RptAKSOExcelHeaders VALUES (501,1,'DistCode','Dist Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,2,'DistName','Dist Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,3,'PODate','Purchase Order Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,4,'PONumber','Purchase Order No',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,5,'ProductCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,6,'ProductName','Product Name',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,7,'SysGenUomid','SysGenUomid',0,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,8,'SystemOrderQty','System Order Qty',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,9,'SystemOrderUOM','System Order UOM',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,10,'OrdUomId','OrdUomId',0,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,11,'FinalORDERQty','Final Order Qty',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,12,'FinalOrderUOM','Final Order UOM',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,13,'FinalOrderQtyBaseUOM','Final OrderQty Base UOM ',1,	1)

IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='ExtractAksoNobal')
	BEGIN
		CREATE TABLE ExtractAksoNobal
		(
			[SlNo] [int] ,
			[ExtractFileName] [nvarchar](100),
			[SPName] [nvarchar](100) ,
			[TblName] [nvarchar](100) ,
			[TransType] [nvarchar](20) ,
			[FileName] [nvarchar](50),
			[RptId] [int] 
		) 
	END 

IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='PurchaseOrderExtractExcel')
	BEGIN
		CREATE TABLE PurchaseOrderExtractExcel
		(
			DistCode NVARCHAR(150),
			DistName NVARCHAR(150),
			PODate	DATETIME,
			PONumber NVARCHAR(150),	
			ProductCode	NVARCHAR(550),
			ProductName	NVARCHAR(550),
			SysGenUomid Int,
			SystemOrderQty	INT,
			SystemOrderUOM	NVARCHAR(50),
			OrdUomId INT,
			FinalORDERQty	INT,
			FinalOrderUOM	NVARCHAR(50),
			FinalOrderQtyBaseUOM NVARCHAR(50)
		)
	END 
DELETE FROM ExtractAksoNobal
INSERT INTO ExtractAksoNobal VALUES 
(1,'Purchase Order','Proc_AN_PurchaseOrder','PurchaseOrderExtractExcel','Master','Excel Extract',501)

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_PurchaseOrder')
DROP PROCEDURE  Proc_AN_PurchaseOrder
GO
-- EXEC Proc_AN_PurchaseOrder '2011-02-22','2011-02-25'
CREATE PROCEDURE Proc_AN_PurchaseOrder
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
SET NoCOunt On
BEGIN
	DELETE FROM PurchaseOrderExtractExcel
	INSERT INTO PurchaseOrderExtractExcel (PONumber,PODate,ProductCode,ProductName,SysGenUomid,SystemOrderQty,OrdUomId,FinalORDERQty)
	
	SELECT DISTINCT A.PurOrderRefNo,A.PurOrderDate,C.PrdCCode,C.PrdName,B.SysGenUomid,B.SysGenQty,B.OrdUomId,B.OrdQty
		FROM PurchaseOrderMaster A
		INNER JOIN PurchaseOrderDetails B ON A.PurOrderRefNo=B.PurOrderRefNo
        INNER JOIN Product C ON B.PrdID=C.PrdID
		INNER JOIN Company D ON A.CmpId=D.CmpId
		LEFT OUTER JOIN Supplier E ON E.SpmID=A.SpmID
	WHERE PurOrderDate BETWEEN @Pi_FromDate AND @Pi_ToDate
   
	UPDATE PurchaseOrderExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE PurchaseOrderExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)
	UPDATE PO SET PO.SystemOrderUOM=UO.UOMDescription FROM PurchaseOrderExtractExcel PO INNER JOIN UomMaster UO ON PO.SysGenUomid=UO.UomId
	UPDATE PurchaseOrderExtractExcel SET FinalOrderUOM=UO.UOMDescription FROM PurchaseOrderExtractExcel PO INNER JOIN UomMaster UO ON PO.OrdUomId=UO.UomId
END 
GO 

--SRF-Nanda-211-006-From Panneer

--- Stock Management
Delete From ExtractAksoNobal where RptId = 506
Go
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,[FileName],RptId )
VALUES (6,'Stock Management','Proc_AN_StockManagement','StockManagementExtractExcel','Master','Excel Extract',506)
GO
IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='StockManagementExtractExcel')
BEGIN
		CREATE TABLE StockManagementExtractExcel
		(
			DistCode		NVARCHAR(200),
			DistName		NVARCHAR(200),
			TransName		NVARCHAR(200),	
			StkRefNumber	NVARCHAR(200),
			StkRefDate		DateTime,
			LocCode			NVARCHAR(200),
			LocName			NVARCHAR(200),
			StkMngtType     NVARCHAR(200),
			TransType		NVARCHAR(200),
			ProductCode		NVARCHAR(200),
			ProductName		NVARCHAR(200),
			BatchCode		NVARCHAR(200),
			StockType		NVARCHAR(200),
			Qty				INT,
			Rate			Numeric(38,6),
			Amount			Numeric(38,6),
			Reason		    NVARCHAR(200),
			PrdId			INT,
			PrdBatId		INT
		)
END 
GO
Delete From  RptAKSOExcelHeaders where RptId = 506
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,1,'DistCode','Distributor Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,2,'DistName','Distributor Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,3,'TransName','Transaction Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,4,'StkRefNumber','Stk Mgmt Ref. Number',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,5,'StkRefDate','Stk Mgmt Transaction Date',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,6,'LocCode','Location Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,7,'LocName','Location Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,8,'StkMngtType','Stock Management Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,9,'TransType','Transaction Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,10,'ProductCode','Product Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,11,'ProductName','Product Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,12,'BatchCode','Batch Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,13,'StockType','Stock Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,14,'Qty','Quantity',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,15,'Rate','Rate',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,16,'Amount','Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,17,'Reason','Reason',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,18,'PrdId','PrdId',0,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,19,'PrdBatId','PrdBatId',0,1)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_StockManagement')
DROP PROCEDURE  Proc_AN_StockManagement
GO
-- EXEC Proc_AN_StockManagement '2011-03-17','2011-03-17'
CREATE PROCEDURE Proc_AN_StockManagement
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
/****************************************************************************
* PROCEDURE: Proc_AN_StockJournal
* PURPOSE: Extract Data in SM Details -- Akso Nobel 
* NOTES:
* CREATED: Panneer	16.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
*****************************************************************************/
SET NOCOUNT ON
BEGIN
	DELETE FROM StockManagementExtractExcel
	INSERT INTO StockManagementExtractExcel ( DistCode,DistName,TransName,StkRefNumber,StkRefDate,
											  LocCode,LocName,StkMngtType,TransType,ProductCode,ProductName,
											  BatchCode,StockType,Qty,Rate,Amount,Reason,PrdId,PrdBatId )
	
	SELECT DISTINCT 
				'','','Stock Management',A.StkMngRefNo,StkMngDate,LcnCode,LcnName,
				Case OpenBal When 1 Then 'Opening Stock' Else 'Stock Management' End As StkMngtType,
				F.[Description],PrdCCode,PrdName,PrdBatCode,
				Case STockTypeId When 1 Then 'Saleable'
								 When 2 Then 'UnSaleable'
								 When 3 Then 'Offer' END AS StkMngtType,
				TotalQty,Rate,Amount,'' AS Reason,B.PrdId,B.PrdBatId
	From 
			StockManagement   A,StockManagementProduct B ,Location C,
			Product D,ProductBatch E,StockManagementType F
	Where
			A.StkMngRefNo = B.StkMngRefNo  AND A.LcnId = C.LcnId
			AND B.PrdId = D.PrdId  AND B.PrdId = E.PrdId  AND B.PrdBatId = E.PrdBatId
			AND A.StkMgmtTypeId = F.StkMgmtTypeId	AND A.Status = 1
			AND StkMngDate Between @Pi_FromDate  and @Pi_ToDate
	Order By 
			A.StkMngRefNo

	
	Select Distinct 
		StkMngRefNo,A.PrdId,A.PrdBatId,A.ReasonId,[Description] INTO  #UpdateStkMngt
	From 
		StockManagementProduct A,Product B,ProductBatch C,ReasonMaster D
	WHere 
		A.PrdId = B.PrdId  And A.PrdId = C.PrdId AND  A.PrdBatId = C.PrdBatId 
		AND A.ReasonId = D.ReasonId and A.ReasonId <> 0 
		--AND StkMngDate Between @Pi_FromDate  and @Pi_ToDate
	
	UPDATE StockManagementExtractExcel SET Reason = [Description]
	From StockManagementExtractExcel A,#UpdateStkMngt B 
	Where A.StkRefNumber = B.StkMngRefNo  AND A.PrdId = B.PrdId  
		  and A.PrdBatId = B.PrdBatId 


	UPDATE StockManagementExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE StockManagementExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)

	Select * from StockManagementExtractExcel
END 
GO 

--- Stock Journal
Delete From ExtractAksoNobal where RptId = 507
Go
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,[FileName],RptId )
VALUES (7,'Stock Journal','Proc_AN_StockJournal','StockJournalExtractExcel','Master','Excel Extract',507)
GO
IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='StockJournalExtractExcel')
BEGIN
		CREATE TABLE StockJournalExtractExcel
		(
			DistCode		NVARCHAR(200),
			DistName		NVARCHAR(200),
			TransName		NVARCHAR(200),	
			StkJnrRefNumber	NVARCHAR(200),
			StkJnrRefDate	DateTime,
			ProductCode		NVARCHAR(200),
			ProductName		NVARCHAR(200),
			BatchCode		NVARCHAR(200),
			FromLocCode		NVARCHAR(200),
			FromLocName		NVARCHAR(200),
			FromStockType	NVARCHAR(200),
			ToLocCode		NVARCHAR(200),
			ToLocLocName	NVARCHAR(200),
			ToStockType		NVARCHAR(200),
			TransQty		INT,
			BalQty			INT,			
			Reason		    NVARCHAR(200),
			PrdId			INT,
			PrdBatId		INT
		)
END 
GO
Delete From  RptAKSOExcelHeaders where RptId = 507
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,1,'DistCode','Distributor Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,2,'DistName','Distributor Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,3,'TransName','Transaction Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,4,'StkJnrRefNumber','Stk journal Ref. Number',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,5,'StkJnrRefDate','Stk Journal Transaction Date',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,6,'ProductCode','Product Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,7,'ProductName','Product Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,8,'BatchCode','Batch Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,9,'FromLocCode','From Location Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,10,'FromLocName','From Location Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,11,'FromStockType','From Stock Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,12,'ToLocCode','To Location Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,13,'ToLocName','To Location Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,14,'ToStockType','To Stock Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,15,'TransQty','Transfer Quantity',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,16,'BalQty','Balance Quantity',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,17,'Reason','Reason',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,18,'PrdId','PrdId',0,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,19,'PrdBatId','PrdBatId',0,1)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_StockJournal')
DROP PROCEDURE  Proc_AN_StockJournal
GO
----- EXEC Proc_AN_StockJournal '2011-03-17','2011-03-17'
CREATE PROCEDURE Proc_AN_StockJournal
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
/****************************************************************************
* PROCEDURE: Proc_AN_StockJournal
* PURPOSE: Extract Data in SJ Details -- Akso Nobel 
* NOTES:
* CREATED: Panneer	16.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
*****************************************************************************/

SET NoCount On
BEGIN
	DELETE FROM StockJournalExtractExcel
	INSERT INTO StockJournalExtractExcel ( DistCode,DistName,TransName,StkJnrRefNumber,StkJnrRefDate,
									ProductCode,ProductName,BatchCode,FromLocCode,FromLocName,FromStockType,
									ToLocCode,ToLocLocName,ToStockType,TransQty,BalQty,Reason,PrdId,PrdBatId )
	SELECT DISTINCT  
					'','','Stock Journal',A.StkJournalRefNo,A.StkJournalDate,
					PrdCCode,PrdName,PrdBatCode,E.LcnCode FromLocCode,E.LcnName FromLocName,
					Case D.SystemStockType When 1 Then 'Saleable'
									 When 2 Then 'UnSaleable' Else 'Offer' End As FromStockType,
					H.LcnCode ToLocCode,H.LcnName ToLocCode,
					Case G.SystemStockType When 1 Then 'Saleable'
									 When 2 Then 'UnSaleable' Else 'Offer' End As ToStockType,
					StkTransferQty TransferQty,BalanceQty,'' AS Reason ,A.PrdId,A.PrdBatId
	From 
			StockJournal A,Product B,ProductBatch C,StockType D,
			Location E,StockJournalDt F,StockType G,Location H
	WHere 
			A.PrdId = B.PrdId AND A.PrdId = C.PrdId and A.PrdBatId  = C.PrdBatId
			AND D.StockTypeId = F.StockTypeId   AND E.LcnId = D.LcnId
			AND G.StockTypeId = F.TransferStkTypeId   AND H.LcnId = G.LcnId		
			AND A.StkJournalRefNo = F.StkJournalRefNo
			AND StkJournalDate Between 	@Pi_FromDate and  @Pi_ToDate
	Order By 
			A.StkJournalRefNo

	Select Distinct 
		A.StkJournalRefNo,E.PrdId,E.PrdBatId,A.ReasonId,[Description] INTO  #UpdateStkJurMngt
	From 
		StockJournalDt A,Product B,ProductBatch C,
		ReasonMaster D,StockJournal E
	WHere 
		E.PrdId = B.PrdId  And E.PrdId = C.PrdId AND  E.PrdBatId = C.PrdBatId 
		AND A.ReasonId = D.ReasonId and A.ReasonId <> 0 
		AND A.StkJournalRefNo = E.StkJournalRefNo
		AND StkJournalDate Between 	@Pi_FromDate and  @Pi_ToDate 
	
	UPDATE StockJournalExtractExcel SET Reason = [Description]
	From StockJournalExtractExcel A,#UpdateStkJurMngt B 
	Where A.StkJnrRefNumber = B.StkJournalRefNo  AND A.PrdId = B.PrdId  
		  and A.PrdBatId = B.PrdBatId 
 
	UPDATE StockJournalExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE StockJournalExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)


	Select * from StockJournalExtractExcel
END 
GO 

---- Debit Note
Delete From ExtractAksoNobal where RptId = 508
Go
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,[FileName],RptId )
VALUES (8,'Debit Notes','Proc_AN_DebitNotes','DebitNotesExtractExcel','Master','Excel Extract',508)
GO
IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='DebitNotesExtractExcel')
BEGIN 
		CREATE TABLE DebitNotesExtractExcel
		(
			DistCode		NVARCHAR(200),
			DistName		NVARCHAR(200),
			TransName		NVARCHAR(200),
			DbNoteType		NVARCHAR(200),	
			DbNoteNumber	NVARCHAR(200),
			DBNoteDate		DateTime,
			SuppOrRetName	NVARCHAR(200),
			CreditAccount	NVARCHAR(200),
			Reason          NVARCHAR(200),
			DBAmount		Numeric(38,6),
			DBAdjAmount		Numeric(38,6),
			BalAmount		Numeric(38,6),
			[Status]        NVARCHAR(200),
			Remarks			NVARCHAR(200)
		)
END 
GO
Delete From  RptAKSOExcelHeaders where RptId = 508
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,1,'DistCode','Distributor Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,2,'DistName','Distributor Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,3,'TransName','Transaction Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,4,'DbNoteType','Debit Note Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,5,'DbNoteNumber','Debit Note Number',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,6,'DBNoteDate','Debit Note Date',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,7,'SuppOrRetName','Supplier Or Retailer Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,8,'CreditAccount','Credit Account',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,9,'Reason','Reason',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,10,'DBAmount','Debit Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,11,'DBAdjAmount','Adjusted Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,12,'BalAmount','Balance Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,13,'Status','Status',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,14,'Remarks','Remarks',1,1)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_DebitNotes')
DROP PROCEDURE  Proc_AN_DebitNotes
GO
----- EXEC Proc_AN_DebitNotes '2011-03-17','2011-03-17'
CREATE PROCEDURE Proc_AN_DebitNotes
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
/****************************************************************************
* PROCEDURE: Proc_AN_DebitNotes
* PURPOSE: Extract Data in Debit Note Details -- Akso Nobel 
* NOTES:
* CREATED: Panneer	16.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
*****************************************************************************/

SET NoCount On
BEGIN
	DELETE FROM DebitNotesExtractExcel
	INSERT INTO DebitNotesExtractExcel ( DistCode,DistName,TransName,DbNoteType,
							DbNoteNumber,DBNoteDate,SuppOrRetName,CreditAccount,
							Reason,DBAmount,DBAdjAmount,BalAmount,[Status],Remarks )
	SELECT  DISTINCT 
			'','','Debit Notes','Retailer',DbNoteNumber,DbNoteDate,
			RtrName,AcName,[Description],Amount,DbAdjAmount,
			Amount - DbAdjAmount As BalanceAmount,
			Case A.Status When 1 then 'Active' Else 'InActive' End As [Status],Remarks
	From 
			DebitNoteRetailer A,Retailer B,CoaMaster C ,
			ReasonMaster D
	WHere
			A.RtrId = B.RtrId  AND C.CoaId = A.CoaId
			AND A.ReasonId = D.ReasonId
			AND DbNoteDate Between @Pi_FromDate and @Pi_ToDate
 
	Union ALL

	SELECT  DISTINCT 
			'','','Debit Notes','Supplier',DbNoteNumber,DbNoteDate,
			SpmName,AcName,[Description],Amount,DbAdjAmount,
			Amount - DbAdjAmount As BalanceAmount,
			Case A.Status When 1 then 'Active' Else 'InActive' End As [Status],Remarks
	From 
			DebitNoteSupplier A,Supplier B,CoaMaster C ,
			ReasonMaster D
	WHere
			A.SpmId = B.SpmId  AND C.CoaId = A.CoaId
			AND A.ReasonId = D.ReasonId
			AND DbNoteDate Between @Pi_FromDate and @Pi_ToDate

	UPDATE DebitNotesExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE DebitNotesExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)


	Select * from DebitNotesExtractExcel
END 
GO 
 
---  Credit Note 
Delete From ExtractAksoNobal where RptId = 509
Go
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,[FileName],RptId )
VALUES (9,'Credit Notes','Proc_AN_CreditNotes','CreditNotesExtractExcel','Master','Excel Extract',509)
GO
IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='CreditNotesExtractExcel')
BEGIN 
		CREATE TABLE CreditNotesExtractExcel
		(
			DistCode		NVARCHAR(200),
			DistName		NVARCHAR(200),
			TransName		NVARCHAR(200),
			CRNoteType		NVARCHAR(200),	
			CRNoteNumber	NVARCHAR(200),
			CRNoteDate		DateTime,
			SuppOrRetName	NVARCHAR(200),
			DebitAccount	NVARCHAR(200),
			Reason          NVARCHAR(200),
			CRAmount		Numeric(38,6),
			CRAdjAmount		Numeric(38,6),
			BalAmount		Numeric(38,6),
			[Status]        NVARCHAR(200),
			Remarks			NVARCHAR(200)
		)
END 
GO
Delete From  RptAKSOExcelHeaders where RptId = 509
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,1,'DistCode','Distributor Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,2,'DistName','Distributor Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,3,'TransName','Transaction Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,4,'CRNoteType','Credit Note Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,5,'CRNoteNumber','Credit Note Number',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,6,'CRNoteDate','Credit Note Date',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,7,'SuppOrRetName','Supplier Or Retailer Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,8,'DebitAccount','Debit Account',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,9,'Reason','Reason',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,10,'CrAmount','Credit Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,11,'CRAdjAmount','Adjusted Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,12,'BalAmount','Balance Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,13,'Status','Status',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,14,'Remarks','Remarks',1,1)
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_CreditNotes')
DROP PROCEDURE  Proc_AN_CreditNotes
GO
----- EXEC Proc_AN_CreditNotes '2011-03-17','2011-03-17'
CREATE PROCEDURE Proc_AN_CreditNotes
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
/****************************************************************************
* PROCEDURE: Proc_AN_CreditNotes
* PURPOSE: Extract Data in Credit Note Details -- Akso Nobel 
* NOTES:
* CREATED: Panneer	16.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
*****************************************************************************/

SET NoCount On
BEGIN
	DELETE FROM CreditNotesExtractExcel
	INSERT INTO CreditNotesExtractExcel ( DistCode,DistName,TransName,CRNoteType,
							CRNoteNumber,CRNoteDate,SuppOrRetName,DebitAccount,
							Reason,CRAmount,CRAdjAmount,BalAmount,[Status],Remarks )
	SELECT  DISTINCT 
			'','','Credit Notes','Retailer',CrNoteNumber,CrNoteDate,
			RtrName,AcName,[Description],Amount,CrAdjAmount,
			Amount - CrAdjAmount As BalanceAmount,
			Case A.Status When 1 then 'Active' Else 'InActive' End As [Status],Remarks
	From 
			CreditNoteRetailer A,Retailer B,CoaMaster C ,
			ReasonMaster D
	WHere
			A.RtrId = B.RtrId  AND C.CoaId = A.CoaId
			AND A.ReasonId = D.ReasonId
			AND CRNoteDate Between @Pi_FromDate and @Pi_ToDate
 
	Union ALL

	SELECT  DISTINCT 
			'','','Credit Notes','Supplier',CrNoteNumber,CrNoteDate,
			SpmName,AcName,[Description],Amount,CrAdjAmount,
			Amount - CrAdjAmount As BalanceAmount,
			Case A.Status When 1 then 'Active' Else 'InActive' End As [Status],Remarks
	From 
			CreditNoteSupplier A,Supplier B,CoaMaster C ,
			ReasonMaster D
	WHere
			A.SpmId = B.SpmId  AND C.CoaId = A.CoaId
			AND A.ReasonId = D.ReasonId
			AND CRNoteDate Between @Pi_FromDate and @Pi_ToDate

	UPDATE CreditNotesExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE CreditNotesExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)


	Select * from CreditNotesExtractExcel
END 
GO 

--SRF-Nanda-211-007-From Panneer

--- Party Account Statement Report

DELETE From RptGroup Where RptId = 222
GO
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName)
Values('Akso Nobal Reports',222,'PartyAccountStatement','Party Account Statement')
GO
DELETE From RptHeader  Where RptId  = 222
GO
INSERT INTO RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
Values('Akso Nobal Reports','Party Account Statement',222,'Party Account Statement',
'Proc_RptAkzoRetAccStatement','RptAkzoRetAccStatement','RptAkzoRetAccStatement.rpt','')
GO
Delete From RptDetails Where RptId  = 222
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,
PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(222,1,'FromDate',-1,'','','From Date*','',1,'',10,'',1,'Enter From Date',0)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,
PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(222,2,'ToDate',-1,'','','To Date*','',1,'',11,'',1,'Enter To Date',0)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,
PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(222,3,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer*...','',1,'',3,0,1,'Press F4/Double Click to select Retailer',0)
GO


IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptAkzoRetAccStatement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptAkzoRetAccStatement]
GO
----   exec  Proc_RptAkzoRetAccStatement 222,2,0,'hh',0,0,1
CREATE  Procedure Proc_RptAkzoRetAccStatement
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
Begin
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE: Proc_RptAkzoRetAccStatement
* PURPOSE: General Procedure
* NOTES:
* CREATED: Panneer	14.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
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

	DECLARE @SMId				AS	INT
	DECLARE @RMId				AS	INT
	DECLARE @RtrId				AS	INT

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))


	CREATE TABLE #RptAkzoRetAccStatement
	(
			[Description]       NVARCHAR(200),
			[DocRefNo]          NVARCHAR(200),
			[Date]				DATETIME,
			[Debit]				NUMERIC (38,6),
			[Credit]			NUMERIC (38,6),
			[Balance]			NUMERIC (38,6),
			[TransactionDet]    NVARCHAR(200),
			[CheqorDueDate]     DATETIME,
			[SeqNo]				INT,
			[UserId]			INT
	)

SET @TblName = 'RptAkzoRetAccStatement'
SET @TblStruct = '	[Description]       NVARCHAR(200),
					[DocRefNo]          NVARCHAR(200),
					[Date]				DATETIME,
					[Debit]				NUMERIC (38,6),
					[Credit]			NUMERIC (38,6),
					[Balance]			NUMERIC (38,6),
					[TransactionDet]    NVARCHAR(200),
					[CheqorDueDate]     DATETIME,
					[SeqNo]				INT
					[UserId]			INT'
SET @TblFields = '  [Description],[DocRefNo],[Date],[Debit],[Credit],
					[Balance],[TransactionDet],[CheqorDueDate],[SeqNo],[UserId]'

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
		Exec Proc_RetailerAccountStment @FromDate,@ToDate,@RtrId

		INSERT INTO #RptAkzoRetAccStatement ([Description],DocRefNo,Date,Debit,Credit,Balance,
											 TransactionDet,CheqorDueDate,SeqNo,UserId)
			/*	Calculate Opening Balance Details  */	
		Select  
				'Opening Balance'   [Description], '' DocRefNo, @FromDate Date,
				 0 as Debit,0 As Credit,BalanceAmount as balance,
				'' as TransactionDet,'1900-01-01' CheqorDueDate,1 SeqNo,2 --@Pi_UsrId
		From 
				TempRetailerAccountStatement  (NoLock) 
		Where	Details = 'Opening Balance'
				
 				 
				/*	Calculate Sales Details  */ 
		UNION ALL 
		Select  
				'Invoice' [Description],SalInvNo DocRefNo,SalInvDate Date,
				DbAmount Debit,0 as Credit,0 Balance,'' as TransactionDet,
				SalDlvDate CheqorDueDate,2 SeqNo, 2---@Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 
		UNION ALL
		Select  
				'Total Invoice IN' [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit, Isnull(SUM(DbAmount),0) Balance,'' as TransactionDet,
				'1900-01-01' CheqorDueDate,3 SeqNo,2 ---@Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 

					/*	Calculate Cheque Details  */
		UNION ALL		
		Select  
				'Cheque Received' [Description],RI.InvRcpNo DocRefNo,InvRcpDate Date,
				0 Debit,Sum(CRAmount)  as Credit, 0 Balance,InvInsNo as TransactionDet,
				Isnull(InvInsDate,'1900-01-01') CheqorDueDate,4 SeqNo,2 --- @Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
		Group By
				RI.InvRcpNo,InvRcpDate,InvInsNo,InvInsDate 
		UNION ALL
		Select  
				'Total Receipt Received' [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0  as Credit, (-1) * Isnull(Sum(CRAmount),0) Balance,'' as TransactionDet,
				'1900-01-01' CheqorDueDate,5 SeqNo,2 --- @Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
		 

				/*	Calculate Debit Note Details  */
		UNION ALL
		Select 'Debit Note - CD' AS [Description],DBNoteNumber DocRefNo,DBNoteDate Date,
				Isnull(DbAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,6 SeqNo,2 ---@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'	
		UNION ALL
		Select 'Total Debit Notes' AS [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit, Isnull(Sum(DbAmount - CRAmount),0) Balance,'' as TransaonDet,
				'1900-01-01' CheqorDueDate,7 SeqNo,2 ---@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'
				
				/*  Calculate Return  Details  */
		UNION ALL
		Select  'Credit Invoice',ReturnCode DocRefNo,ReturnDate Date,
				0 as Debit,CrAmount as Credit,0 as  Balance,Isnull(DocRefNo,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,8 SeqNo,2 ---@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
		UNION ALL
		Select  'Total Credit Invoice','' DocRefNo,'1900-01-01' Date,
				0 as Debit,0 as Credit,Isnull(Sum(CrAmount),0) * (-1) as  Balance,
				'' as TransaonDet,
				'1900-01-01' CheqorDueDate,9 SeqNo,2 ---@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
	
 				/*  Calculate Credit Note  Details  */
		UNION ALL
		Select 'Credit Note' AS [Description],CRNoteNumber DocRefNo,CRNoteDate Date,
				Isnull(DBAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,10 SeqNo,2 ---@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'	
		UNION ALL
		Select 'Total Credit Notes' AS [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit,-(1) * Isnull(Sum(CRAmount-DBAmount),0) Balance,'' as TransaonDet,
				'1900-01-01' CheqorDueDate,11 SeqNo,2 ---@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Replacement' AS [Description],RepRefNo DocRefNo,RepDate  Date,
				DBAmount Debit,0 Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'1900-01-01' CheqorDueDate,12 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Replacement'
		Union ALL
		Select 
				'Total Return & Replacement-Replacement' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit,Isnull(Sum(DBAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,13 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Replacement'

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Return' AS [Description],RepRefNo DocRefNo,RepDate  Date,
				0 Debit,CRAmount Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'1900-01-01' CheqorDueDate,14 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Return'
		Union ALL
		Select 
				'Total Return & Replacement-Return' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit,(-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,15 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Return'

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cheque Bounce' AS [Description],InvRcpNo,InvRcpDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'1900-01-01' CheqorDueDate,16 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cheque Bounce'
		Union ALL
		Select 
				'Total Collection-Cheque Bounce' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,17 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cheque Bounce'

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cash Cancellation' AS [Description],InvRcpNo,InvRcpDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'1900-01-01' CheqorDueDate,18 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cash Cancellation'
		Union ALL
		Select 
				'Total Collection-Cash Cancellation' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,19 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cash Cancellation'

				/*  Calculate Retailer On Account Details  */
		Union ALl
		Select 
				'Retailer On Account' AS [Description],RtrAccRefNo,ChequeDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,Remarks DocRefNo,
				'1900-01-01' CheqorDueDate,20 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , RetailerOnAccount A (Nolock)
		WHERE
				A.RtrAccRefNo = T.DocumentNo AND Details = 'Retailer On Account'
		Union ALL
		Select 
				'Total Retailer On Account' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, (-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,21 SeqNo, 2 ---@Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Retailer On Account'

				/*  Calculate Closing Balance Details  */
		UNION ALL
		Select  
				'Closing Balance' [Description], '' DocRefNo,@ToDate Date,
				0 as Debit,0 Credit, 0  Balance,
				'' as TransactionDet,'1900-01-01' CheqorDueDate,22 SeqNo,2 --@Pi_UsrId
		From 
				TempRetailerAccountStatement 
		Where
				Details = 'Closing Balance'	

		DECLARE @ClBal Numeric(18,4)
		Select @ClBal = Sum(Balance)   From  #RptAkzoRetAccStatement 
		Where SeqNo in (1,3,5,7,9,11,13,15,17,19,21)
				
		Update #RptAkzoRetAccStatement Set Balance = @ClBal Where SeqNo = 22
		
	END

	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptAkzoRetAccStatement

	Delete From #RptAkzoRetAccStatement 
	WHere Balance  = 0 and SeqNo  in (3,5,7,9,11,13,15,17,19,21)
	Select * from #RptAkzoRetAccStatement Order by SeqNo,[Description]
END
GO

DELETE FRom  RptFormula Where RptId  = 222
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,1,'Fromdate','From Date',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,2,'Todate','To Date',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,3,'Dis_Fromdate','From Date',1,10)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,4,'Dis_Todate','To Date',1,11)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,5,'CapPrintDate','Date',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,6,'CapUserName','User Name',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,7,'Retailer','Retailer',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,8,'Dis_Retailer','Retailer',1,3)
GO 
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,9,'Description','Description',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,10,'DocRefNo','Doc.Ref.Number',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,11,'Date','Date',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,12,'Debit','Debit',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,13,'Credit','Credit',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,14,'Balance','Balance',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,15,'Remarks','Cheque.No/Ref.No/Trans Details',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(222,16,'CheqDue','Cheque/Due',1,0)
GO

DELETE FROM  RPTExcelHeaders WHere RptId = 222
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,1,'Description','Description',1,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,2,'DocRefNo','Doc.Ref.Number',1,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,3,'Date','Date',1,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,4,'Debit','Debit',1,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,5,'Credit','Credit',1,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,6,'Balance','Balance',1,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,7,'TransactionDet','Cheque.No/Ref.No/Trans Details',1,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,8,'ChequeorDueDate','Cheque/Due',1,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,9,'SeqNo','SeqNo',0,0)
GO
INSERT INTO RPTExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(222,10,'UserId','UserId',0,0)
GO

---- Stock Ledger Report

DELETE From RptGroup Where RptId = 225
GO
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName)
Values('Akso Nobal Reports',225,'StockLedgerReport','Stock Ledger Report')
GO
DELETE From RptHeader  Where RptId  = 225
GO
INSERT INTO RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
Values('Akso Nobal Reports','Stock Ledger Report',225,'Stock Ledger Report',
'Proc_RptAkzoStockLedgerReport','RptAkzoStockLedgerReport','RptAkzoStockLedgerReport.rpt','')
GO
DELETE FROM RptDetails Where RptId = 225
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,
CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES (225,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,
CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES (225,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,
CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES (225,3,'Location',-1,'','LcnId,LcnCode,LcnName','Location*...','',1,'',22,0,1,
'Press F4/Double Click to Select Location',0)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,
CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (225,4,'Company',-1,'',
'CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to Select Company',0)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,
CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES (225,5,'ProductCategoryLevel',4,'CmpId','CmpPrdCtgId,LevelName,CmpPrdCtgName',
'Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double click to select Product Hierarchy Level',1)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,
CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES (225,6,'ProductCategoryValue',5,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,
PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',
21,0,0,'Press F4/Double click to select Product Hierarchy Level Value',1)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,
CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES (225,7,'Product',6,'PrdCtgValMainId','PrdId,PrdDcode,PrdName','Product*...',
'ProductCategoryValue',1,'PrdCtgValMainId',5,1,1,'Press F4/Double click to select Product',0)
GO
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,
CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES (225,8,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Suppress Zero Stock*...',NULL,1,NULL,262,1,1,'Press F4/Double Click to Select the Supress Zero Stock',0)
GO

Delete From  RptSelectionHD Where SelcId = 262
Go
INSERT INTO RptSelectionHD(SelcId,SelcName,TblName,Condition)
Values(262,'Sel_StkLedger','RptFilter',1)
GO
Delete From RptFilter WHere RptId = 225
GO
INSERT Into RptFilter (RptId,SelcId,FilterId,FilterDesc)
Values(225,262,1,'YES')
GO
INSERT Into RptFilter (RptId,SelcId,FilterId,FilterDesc)
Values(225,262,2,'NO')
GO
DELETE  From  RptFormula Where RptId  =  225
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,1,'Fromdate','From Date',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,2,'Todate','To Date',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,3,'Dis_Fromdate','From Date',1,10)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,4,'Dis_Todate','To Date',1,11)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,5,'CapPrintDate','Date',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,6,'CapUserName','User Name',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,7,'Cap_Locaiton','Location',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,8,'Fil_Location','Location',1,22)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,9,'Disp_SupZeroStock','Suppress Zero Stock',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,10,'Fill_SupZeroStock','Suppress Zero Stock',1,262)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,11,'Company','Company',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,12,'CompanyDisp','ALL',1,262)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,13,'PrdLevel','Product Level',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,14,'PrdLevelDisp','ALL',1,21)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,15,'PrdLevelVal','Product Level Value',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,16,'PrdLevelValDisp','ALL',1,16)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,15,'Product','Product',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,16,'ProductDisp','ALL',1,5)
GO

INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,17,'Dis_TransDate','Date',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,18,'Dis_Transtype','Transaction',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,19,'Dis_TransNo','Transaction Ref.Number',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,20,'SalQty','Salable Qty',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,21,'SalQtyVolume','Salable Qty Volume',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,22,'UnSalQty','UnSalable Qty',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,23,'UnSalQtyVol','UnSalable Qty Volume',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,24,'OfferQty','Offer Qty',1,0)
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(225,25,'OfferQtyVol','Offer Qty Volume',1,0)
GO
Delete From RptExcelHeaders Where rptid  = 225
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,1,'TransactionDate','Date',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,2,'TransactionType','Transaction',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,3,'TransactionNumber','Transaction Reference Number',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,4,'SalQty','Salable Qty',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,5,'SalQtyVolume','Salable Qty Volume',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,6,'UnSalQty','UnSalable Qty',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,7,'UnSalQtyVolume','UnSalable Qty Volume',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,8,'OfferQty','Offer Qty',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,9,'OfferQtyVolume','Offer Qty Volume',1,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,10,'SlNo','SlNo',0,0)
GO
INSERT Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(225,11,'PrdId','PrdId',0,0)
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptAkzoStockLedgerReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptAkzoStockLedgerReport]
GO
----  Exec [Proc_RptAkzoStockLedgerReport] 225,2,0,'Loreal',0,0,1
---- select *  from RptProductTrack
CREATE  PROCEDURE [Proc_RptAkzoStockLedgerReport]
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
/***************************************************************************************************
* PROCEDURE : Proc_RptAkzoStockLedgerReport
* PURPOSE   : Product transaction details
* CREATED	: Panneer
* CREATED DATE : 16.03.2011
* NOTE		: General SP For Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------------------------------------
* {date}     {developer}  {brief modification description}
***************************************************************************************************/
BEGIN
SET NOCOUNT ON

	DECLARE @NewSnapId   AS INT
	DECLARE @DBNAME		 AS nvarchar(50)
	DECLARE @TblName	 AS nvarchar(500)
	DECLARE @TblStruct   AS nVarchar(4000)
	DECLARE @TblFields   AS nVarchar(4000)
	DECLARE @sSql		 AS nVarChar(4000)
	DECLARE @ErrNo		 AS INT
	DECLARE @PurDBName	 AS nVarChar(50)

	--Filter Variable
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @CmpId				AS Int
	DECLARE @CmpPrdCtgId		AS Int
	DECLARE @PrdCtgMainId		AS Int
	DECLARE @PrdId				AS INT
	DECLARE @PrdCatPrdId        AS  INT
	DECLARE @LcnId				AS INT
	DECLARE @SupZeroStock		AS INT
	DECLARE @ZeroStockRecCount  AS INT
	--Till Here

	--Assgin Value for the Filter Variable
	SET @FromDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate   = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @CmpId    = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId    = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))	
	SET @PrdId    = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SupZeroStock = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,262,@Pi_UsrId))

	EXEC Proc_AkzoProductTrackDetails @Pi_UsrId,@FromDate,@ToDate 

	CREATE TABLE #RptAkzoStockLedgerReport
	(
						TransactionDate		DATETIME,
						TransactionType		NVARCHAR(300),
						TransactionNumber   NVARCHAR(100),
						SalQty				NUMERIC(38,0),
						SalQtyVolume		NUMERIC(38,6),
						UnSalQty			NUMERIC(38,0),
						UnSalQtyVolume		NUMERIC(38,6),
						OfferQty   NUMERIC(38,0),
						OfferQtyVolume   NUMERIC(38,6),
						SlNo    INT,
						PrdId   INT
	)
	SET @TblName = 'RptAkzoStockLedgerReport'
	SET @TblStruct = '	TransactionDate		DATETIME,
						TransactionType		NVARCHAR(300),
						TransactionNumber   NVARCHAR(100),
						SalQty				NUMERIC(38,0),
						SalQtyVolume		NUMERIC(38,6),
						UnSalQty			NUMERIC(38,0),
						UnSalQtyVolume		NUMERIC(38,6),
						OfferQty   NUMERIC(38,0),
						OfferQtyVolume   NUMERIC(38,6),
						SlNo    INT,
						PrdId   INT'

	SET @TblFields = '	TransactionDate,TransactionType,TransactionNumber,SalQty,SalQtyVolume,
						UnSalQty,UnSalQtyVolume,OfferQty,OfferQtyVolume,SlNo,PrdId'

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

	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
			  INSERT INTO #RptAkzoStockLedgerReport (	TransactionDate,TransactionType,TransactionNumber,
														SalQty,SalQtyVolume,UnSalQty,UnSalQtyVolume,
														OfferQty,OfferQtyVolume,SlNo,PrdId)
			  SELECT 
					TransactionDate,TransactionType,TransactionNumber,
					SUM(SalQty),SUM(SalQty * PrdWgt) SalQtyVolume,
					SUM(UnSalQty),SUM(UnSalQty * PrdWgt) UnSalQtyVolume,
					SUM(OfferQty),SUM(OfferQty * PrdWgt) OfferQtyVolume,
					SlNo,A.PrdId
			  FROM 
					RptProductTrack A, Product B
			  WHERE 
					A. PrdId = B.Prdid 
					AND (A.CmpId=  (CASE @CmpId WHEN 0 THEN A.CmpId ELSE 0 END ) OR
							A.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
										
					AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
							LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) )

					 AND (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId ELSE 0 END) OR
							A.PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) )

					AND  TransactionDate BETWEEN @FromDate AND  @ToDate AND UsrId=@Pi_UsrId

			  GROUP BY 
					TransactionDate,TransactionType,TransactionNumber,SlNo,A.PrdId
			  ORDER BY 
					TransactionDate,SlNo

		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptAkzoStockLedgerReport ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+'  WHERE (CmpId=  (CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+', 4, '+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND (LcnId = (CASE '+CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN LcnId ELSE 0 END) OR
				LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',22,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (LevelId =  (CASE '+CAST(@CmpPrdCtgId AS NVARCHAR(10))+' WHEN 0 THEN LevelId ELSE 0 END ) OR
				LevelId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',21,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (LevelValId = (CASE '+CAST(@PrdCtgMainId AS NVARCHAR(10))+' WHEN 0 THEN LevelValId Else 0 END) OR
				LevelValId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',16,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (PrdId = (CASE '+CAST(@PrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND TransactionDate Between '''+CAST(@FromDate AS NVARCHAR(10))+''' and '''+ CAST(@FromDate AS NVARCHAR(10))+''''
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptAkzoStockLedgerReport'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END
	ELSE    --To Retrieve Data From Snap Data
	BEGIN
		PRINT @Pi_DbName
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptAkzoStockLedgerReport ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
			' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
			' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
			' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			PRINT @SSQL
			EXEC (@SSQL)
			PRINT 'Retrived Data From Snap Shot Table'
		END
	ELSE
	BEGIN
		--  SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	END
	END

	IF @SupZeroStock = 1
	BEGIN
		DELETE FROM #RptAkzoStockLedgerReport WHERE (SalQty+UnSalQty+OfferQty)=0 AND 
		TransactionType NOT IN ('Opening Stock','Closing Stock') 
	END

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)

	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptAkzoStockLedgerReport
	PRINT 'Data Executed'
	SELECT * FROM #RptAkzoStockLedgerReport ORDER BY TransactionDate,SlNo ASC 

	RETURN
END
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AkzoProductTrackDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AkzoProductTrackDetails]
GO
----  exec [Proc_ProductTrackDetails] 5,'2010-09-15','2010-09-15'
CREATE PROCEDURE [Proc_AkzoProductTrackDetails]
(
	 @Pi_UsrId INT,
	 @Pi_FromDate DATETIME,
	 @Pi_ToDate DATETIME
)
AS
/***************************************************************************************************
* PROCEDURE	: Proc_AkzoProductTrackDetails
* PURPOSE	: To Return the Product transaction details
* CREATED	: Panneer
* CREATED DATE	: 16.03.2011
* NOTE		: General SP For Generate Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
***************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @PrdId	AS INT
	SET @PrdId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(41,5,@Pi_UsrId))
	SELECT	TransDate,A.PrdId,A.PrdBatId,ISNULL(LcnId,0) AS LcnId,
			SUM(SalOpenStock) SalOpenStock,SUM(UnSalOpenStock) UnSalOpenStock,
			SUM(OfferOpenStock) OfferOpenStock INTO #OpenStk 
	FROM StockLedger A,
	(
		SELECT MAX(TransDate) AS MaxDate,PrdId,PrdBatId  FROM StockLedger WHERE TransDate <= @Pi_FromDate 
		AND PrdId=@PrdId GROUP BY PrdId,PrdBatId
	) B
	WHERE A.TransDate=B.MaxDate AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
	AND A.PrdId=@PrdId AND B.PrdId=@PrdId
	GROUP BY TransDate,A.PrdId,A.PrdBatId,LcnId
		
	SELECT TransDate,A.PrdId,A.PrdBatId,LcnId,SUM(SalClsStock) SalClsStock,SUM(UnSalClsStock) UnSalClsStock,
	SUM(OfferClsStock) OfferClsStock  INTO #CloseStk FROM StockLedger A ,
	(		SELECT MAX(TransDate) MaxDate,PrdId,PrdBatId FROM StockLedger WHERE TransDate <= @Pi_ToDate AND PrdId=@PrdId
			GROUP BY  PrdId,PrdBatId 
	) B 
	WHERE A.TransDate=B.MaxDate AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
	AND A.PrdId=@PrdId AND B.PrdId=@PrdId
	GROUP BY TransDate,A.PrdId,A.PrdBatId,LcnId

	TRUNCATE TABLE  RptProductTrack 
	INSERT INTO RptProductTrack(LevelValId,LevelValName,LevelId,LevelName,CmpId,CmpName,PrdId,
	PrdName,PrdBatId,PrdBatCode,SalQty,UnSalQty,OfferQty,TransactionType,
	TransactionNumber,TransactionDate,UsrId,SlNo,LcnId)
	--Opening Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(O.SalOpenStock,0),ISNULL(O.UnSalOpenStock,0),
		ISNULL(O.OfferOpenStock,0),
		'Opening Stock' ,'',@Pi_FromDate ,@Pi_UsrId,1,ISNULL(O.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #OpenStk O ON PH.PrdId = O.PrdId AND PH.PrdBatId = O.PrdBatId
		AND PH.PrdId=@PrdId
	UNION ALL
	--Stock Mng (In)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management - Add',M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,2,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=0
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Stock Mng (Out)	
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management - Reduce' ,M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,3,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=1
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND  M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer Out' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,4,M.FromLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer In' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,5,M.ToLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Bat Tran (In)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer Out',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,6,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.FromBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	UNION ALL
----	--- Bat Trans In (New)
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		(CASE S.SystemStockType WHEN 1 THEN (-1)*T.TransferQty ELSE 0 END ) AS SalStock,
----		(CASE S.SystemStockType WHEN 2 THEN (-1)*T.TransferQty ELSE 0 END ) AS UnSalStock,
----		(CASE S.SystemStockType WHEN 3 THEN (-1)*T.TransferQty ELSE 0 END ) AS OfferStock,
----		'Batch Transfer Out',T.BatRefNo,A.BatTrfDate,@Pi_UsrId,6,S.LcnId
----		FROM
----			BatchTransferHD A 
----			INNER JOIN BatchTransferDT T ON A.BatRefNo = T.BatRefNo
----			INNER JOIN StockType S On T.StockType = S.StockTypeId
----			INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.FrmBatId = PH.PrdBatId
----		WHERE A.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Bat Tran (Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer In',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,7,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.ToBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	UNION ALL 
--	-- New Bat Tran (Out)
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN T.TransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN T.TransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN T.TransferQty ELSE 0 END ) AS OfferStock,
--		'Batch Transfer In',T.BatRefNo,A.BatTrfDate,@Pi_UsrId,7,S.LcnId
--		FROM
--			BatchTransferHD A 
--			INNER JOIN BatchTransferDT T ON A.BatRefNo = T.BatRefNo
--			INNER JOIN StockType S On T.StockType = S.StockTypeId
--			INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.ToBatId = PH.PrdBatId
--		WHERE A.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL 
	--Salvage
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.SalvageQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.SalvageQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.SalvageQty ELSE 0 END ) AS OfferStock,
		'Salvage' TransType ,M.SalvageRefNo,M.SalvageDate,@Pi_UsrId,8,S.LcnId
		FROM
		Salvage M
		INNER JOIN SalvageProduct D ON M.SalvageRefNo = D.SalvageRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Stock journal (Out)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	--  SJ New Out
--	UNION ALL 
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS OfferStock,
--		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
--		FROM
--		StockJournalHD M
--		INNER JOIN StockJournalDet D ON M.StkJournalRefNo = D.StkJournalRefNo
--		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
--		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
--		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	--Stock journal(In)	
	UNION ALL	
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.TransferStkTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	--  SJ New IN
--	UNION ALL	
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN D.StkTransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN D.StkTransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN D.StkTransferQty ELSE 0 END ) AS OfferStock,
--		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
--		FROM
--		StockJournalHD M
--		INNER JOIN StockJournalDet D ON M.StkJournalRefNo = D.StkJournalRefNo
--		INNER JOIN StockType S ON D.TransferStkTypeId = S.StockTypeId
--		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
--		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Ret to cmp
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS OfferStock,
		'Return To Company' TransType ,
		M.RtnCmpRefNo TransNo,M.RtnCmpDate TransDate,@Pi_UsrId,11,S.LcnId
		FROM
		ReturnToCompany M
		INNER JOIN ReturnToCompanyDt D ON M.RtnCmpRefNo = D.RtnCmpRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		AND M.Status=1
	UNION ALL
	--Ret and replacement
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.RtnQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.RtnQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.RtnQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement - Return',M.RepRefNo,M.RepDate,@Pi_UsrId,12,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementIn D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Ret and replacement(Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.RepQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.RepQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.RepQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement - Replacement',M.RepRefNo,M.RepDate,@Pi_UsrId,13,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementOut D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Resell Damage Goods
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*D.Quantity,0,
		'Resell Damage Goods',M.ReDamRefNo,M.ReSellDate,@Pi_UsrId,14,M.LcnId
		FROM
		ReSellDamageMaster M
		INNER JOIN ReSellDamageDetails D ON M.ReDamRefNo = D.ReDamRefNo
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		AND M.Status=1
	UNION ALL
	--VanLoad&Unload
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Load',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,15,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 0 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL 
	--VanLoad&Unload (Unload)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Unload',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,16,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 1 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Sales		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.BaseQty,0,0,
		'Sales',M.SalInvNo,M.SalInvDate,@Pi_UsrId,17,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.FreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,18,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.FreePrdId = PH.PrdId AND D.FreePrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.SalManFreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,19,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Gift
	SELECT 		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.GiftQty,
		'Sales Gift',M.SalInvNo,M.SalInvDate,@Pi_UsrId,20,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.GiftPrdId = PH.PrdId AND D.GiftPrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		D.RcvdGoodBaseQty,0,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,21,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,E.BaseQty,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,22,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (Excess)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*E.BaseQty ELSE 0 END),
		(CASE S.SystemStockType WHEN 2 THEN (-1)*E.BaseQty ELSE 0 END),0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,23,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=2
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND D.RefuseSale=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- pur Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.Quantity,
		'Purchase Free',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,24,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptClaimScheme D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur ret (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.RetSalBaseQty,0,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,25,M.LcnId
		FROM PurchaseReturn M INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur ret (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*E.ReturnBsQty,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,26,S.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PurchaseReturnBreakup E ON E.PurRetId = D.PurRetId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur Ret Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.RetQty,
		'Purchase Return Free',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,27,M.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnClaimScheme D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1	AND PH.PrdId=@PrdId	 
	UNION ALL
	-- Sales Ret
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE ST.SystemStockType WHEN 1 THEN D.BaseQty ELSE 0 END ) AS SalStock,
		(CASE ST.SystemStockType WHEN 2 THEN D.BaseQty ELSE 0 END ) AS UnSalStock,
		(CASE ST.SystemStockType WHEN 3 THEN D.BaseQty ELSE 0 END ) AS OfferStock,
		'Sales Return',M.ReturnCode,M.ReturnDate,@Pi_UsrId,28,ST.LcnId
		FROM ReturnHeader M
		INNER JOIN ReturnProduct D ON M.Returnid = D.ReturnId
		INNER JOIN StockType ST ON D.StockTypeId = ST.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=0 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Receipt
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.RcvdGoodBaseQty,
		'Sample Receipt',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,29,M.LcnId
		FROM
		SamplePurchaseReceipt M
		INNER JOIN SamplePurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Issue		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.IssueBaseQty,
		'Sample Issue',M.IssueRefNo,M.IssueDate,@Pi_UsrId,30,M.LcnId
		FROM
		SampleIssueHd M
		INNER JOIN  SampleIssueDt D ON M.IssueId = D.IssueId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Return		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.ReturnBaseQty,
		'Sample Return',M.ReturnRefNo,M.ReturnDate,@Pi_UsrId,31,M.LcnId
		FROM
		SampleReturnHd M
		INNER JOIN  SampleReturnDt D ON M.ReturnId = D.ReturnId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1	 AND PH.PrdId=@PrdId
	--- added by Panneer
	----Sample Issue Free	
	UNION ALL
		SELECT
			PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
			PH.CmpPrdCtgName,
			PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
			0,0,(-1)*D.IssueBaseQty,
			'Sample Issue',M.IssueRefNo,M.IssueDate,@Pi_UsrId,30,M.LcnId
		FROM
			FreeIssueHd M
			INNER JOIN FreeIssueDt D ON M.IssueId = D.IssueId
			INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE
			M.IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
			AND M.Status=1 AND PH.PrdId=@PrdId
----	UNION ALL
----	--IDT (In)		
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		D.Qty AS SalStock,
----		0 AS UnSalStock,
----		0 AS OfferStock,
----		'IDT - IN',M.IDTMngRefNo,M.IDTMngDate,@Pi_UsrId,2,M.LcnId
----		FROM
----		IDTManagement M
----		INNER JOIN IDTManagementProduct D ON M.IDTMngRefNo = D.IDTMngRefNo AND StkMgmtTypeId=1
----		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
----		WHERE M.Status=1 AND M.IDTMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
----	UNION ALL
----	--IDT  (Out)	
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		(-1)*D.Qty AS SalStock,
----		0 AS UnSalStock,
----		0 AS OfferStock,
----		'IDT -OUT ' ,M.IDTMngRefNo,M.IDTMngDate,@Pi_UsrId,3,M.LcnId
----		FROM
----		IDTManagement M
----		INNER JOIN IDTManagementProduct D ON M.IDTMngRefNo = D.IDTMngRefNo AND StkMgmtTypeId=2
----		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
----		WHERE M.Status=1 AND M.IDTMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL --Closing Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(C.SalClsStock,0),
		ISNULL(C.UnSalClsStock,0),ISNULL(C.OfferClsStock,0),
		'Closing Stock' ,'',@Pi_ToDate ,@Pi_UsrId,32,ISNULL(C.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #CloseStk C ON PH.PrdId = C.PrdId AND PH.PrdBatId = C.PrdBatId AND PH.PrdId=@PrdId
END
GO

--SRF-Nanda-211-008-From VasanthaRaj

DELETE FROM RptGroup WHERE RptId=221
DELETE FROM RptHeader WHERE RptId=221
DELETE FROM RptDetails WHERE RptId=221
DELETE FROM RptSelectionHd WHERE SelcId = 260
DELETE FROM RptFilter WHERE RptId = 221 and SelcId = 260
DELETE FROM RptFilter WHERE RptId = 221 and SelcId = 240
DELETE FROM RptFilter WHERE RptId =221 and SelcId = 44
DELETE FROM RptFormula WHERE RptId =221

INSERT INTO RptGroup VALUES('Akso Nobal Reports',221,'AksoNobalCurrentStock','Akso Nobal CurrentStock')

INSERT INTO RptHeader VALUES('AksoNobalCurrentStock','AksoNobalCurrentStock',221,'Akso Nobal CurrentStock Report','Proc_RptCurrentStockAN','RptCurrentStockAN','RptCurrentStockAN.rpt','')

INSERT INTO RptDetails VALUES(221,1,'Company',-1,'','CmpId,CmpCode,CmpName','Company*...','',1,'',4,1,1,'Press F4/Double Click to select Company',0)
INSERT INTO RptDetails VALUES(221,2,'Location',-1,'','LcnId,LcnCode,LcnName','Location...','',1,'',22,'','','Press F4/Double Click to select Location',0)
INSERT INTO RptDetails VALUES(221,3,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Stock Type...','',1,'',240,1,0,'Press F4/Double Click to Select Stock Type',0)
INSERT INTO RptDetails VALUES(221,4,'ProductCategoryLevel',1,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,'','Press F4/Double Click to select Product Hierarchy Level',0)
INSERT INTO RptDetails VALUES(221,5,'ProductCategoryValue',4,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,'','','Press F4/Double Click to select Product Hierarchy Level Value',1)
INSERT INTO RptDetails VALUES(221,6,'Product',5,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,'','','Press F4/Double Click to select Product',0)
INSERT INTO RptDetails VALUES(221,7,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display Level*...','',1,'',260,1,1,'Press F4/Double Click to select Display Level',0)
INSERT INTO RptDetails VALUES(221,8,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Suppress Zero Stock...','',1,'',44,1,0,'Press F4/Double Click to Select the Supress Zero Stock',0)

INSERT INTO RptSelectionHd VALUES(260,'sel_DisplayLevel','RptFilter',1)

INSERT INTO RptFilter VALUES(221,260,1,'SKU Level')
INSERT INTO RptFilter VALUES(221,260,2,'Hierarchy Level')

INSERT INTO RptFilter VALUES(221,240,1,'Saleable')
INSERT INTO RptFilter VALUES(221,240,2,'UnSaleable')
INSERT INTO RptFilter VALUES(221,240,3,'Offer')

INSERT INTO RptFilter VALUES(221,44,1,'Yes')
INSERT INTO RptFilter VALUES(221,44,2,'No')

INSERT INTO RptFormula VALUES(221,1,'Product Code','Product Code',1,0)
INSERT INTO RptFormula VALUES(221,2,'Product Name','Product Name',1,0)
INSERT INTO RptFormula VALUES(221,3,'Saleable Stock','Saleable Stock',1,0)
INSERT INTO RptFormula VALUES(221,4,'Unsaleable Stock','Unsaleable Stock',1,0)
INSERT INTO RptFormula VALUES(221,5,'Offer Stock','Offer Stock',1,0)
INSERT INTO RptFormula VALUES(221,6,'Sal Stock Value','Stock value (Saleable)',1,0)
INSERT INTO RptFormula VALUES(221,7,'Unsal Stock Value','Stock Value (Unsaleable)',1,0)
INSERT INTO RptFormula VALUES(221,8,'Tot Stock Value','Stock Value (Total)',1,0)
INSERT INTO RptFormula VALUES(221,9,'Fil_Company','Company',1,0)
INSERT INTO RptFormula VALUES(221,10,'Fil_Location','Location',1,0)
INSERT INTO RptFormula VALUES(221,11,'Fil_PrdCtgLvl','Product Category Level',1,0)
INSERT INTO RptFormula VALUES(221,12,'Fil_PrdCtgValue','Product Category Value',1,0)
INSERT INTO RptFormula VALUES(221,13,'Fil_Prd','Product',1,0)
INSERT INTO RptFormula VALUES(221,14,'FilDisp_Company','ALL',1,4)
INSERT INTO RptFormula VALUES(221,15,'FilDisp_Location','ALL',1,22)
INSERT INTO RptFormula VALUES(221,16,'FilDisp_PrdCtgLvl','ALL',1,16)
INSERT INTO RptFormula VALUES(221,17,'FilDisp_PrdCtgValue','ALL',1,21)
INSERT INTO RptFormula VALUES(221,18,'FilDisp_Prd','ALL',1,5)
INSERT INTO RptFormula VALUES(221,19,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula VALUES(221,20,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula VALUES(221,21,'Hd_Total','Grand Total',1,0)
INSERT INTO RptFormula VALUES(221,22,'Cap_Batch','Batch',1,0)
INSERT INTO RptFormula VALUES(221,23,'Disp_Batch','Batch',1,7)
INSERT INTO RptFormula VALUES(221,24,'Disp_SupZeroStock','Suppress Zero Stock',1,0)
INSERT INTO RptFormula VALUES(221,25,'Fill_SupZeroStock','Suppress Zero Stock',1,44)
INSERT INTO RptFormula VALUES(221,26,'Disp_UomBased','Display Uom Based',1,0)
INSERT INTO RptFormula VALUES(221,27,'Fill_UomBased','Display Uom Based',1,221)
INSERT INTO RptFormula VALUES(221,28,'Disp_StockType','Stock Type',1,0)
INSERT INTO RptFormula VALUES(221,29,'Fill_StockType','Stock Type',1,240)
INSERT INTO RptFormula VALUES (221,30,'Disp_DisplayLevel','Display Level',1,0)
INSERT INTO RptFormula VALUES (221,31,'Fill_DisplayLevel','Display Level',1,260)
INSERT INTO RptFormula VALUES (221,32,'Product Hierarchy Level Value','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula VALUES (221,33,'Description','Description',1,0)
INSERT INTO RptFormula VALUES (221,34,'Location Name','Location Name',1,0)
INSERT INTO RptFormula VALUES (221,35,'Stock Type','Stock Type',1,0)
INSERT INTO RptFormula VALUES (221,36,'Quantity Packs','Quantity Packs',1,0)
INSERT INTO RptFormula VALUES (221,37,'Quantity in Volume(LT/KG/NO)','Quantity in Volume(LT/KG/NO)',1,0)
INSERT INTO RptFormula VALUES (221,38,'Value','Value',1,0)

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptCurrentStockAN]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptCurrentStockAN]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

--EXEC [Proc_RptCurrentStockAN] 221,2,0,'PARLEFRESHDB',0,0,1,0

CREATE PROC [dbo].[Proc_RptCurrentStockAN]
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
	DECLARE @PrdCatId  AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @CtgValue      AS Int
	DECLARE @PrdCatValId      AS Int
	DECLARE @DisplayLevel       AS Int
	DECLARE @PrdId        AS Int
	DECLARE @SupZeroStock	AS INT
	DECLARE @StockType	AS INT
	            
	--Till Here
	--Assgin Value for the Filter Variable
    SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
    SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
    SET @PrdCatValId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
    SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @DisplayLevel = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,260,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
    
    EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
    
	CREATE TABLE #RPTCURRENTSTOCKAN
	(
		[CmpPrdCtgId]						INT,
		[Product Hierarchy Level Value]     NVARCHAR(200),
		[PrdCtgValMainId]					INT,
		[PrdCtgValCode]						NVARCHAR(300),
		[Description]						NVARCHAR(300),
		[PrdId]								INT,
		[Product Code]						NVARCHAR(200),
		[Product Name]						NVARCHAR(300),
		[LcnId]								INT,
		[Location Name]						NVARCHAR(300),
		[SystemStockType]					TINYINT,
		[Stock Type]						NVARCHAR(100),
		[Quantity Packs]					INT,
		[PrdUnitId]							INT,
		[Quantity In Volume(Unit)]			NUMERIC(18,2),
		[Quantity In Volume(KG)]            NUMERIC(18,2),
		[Quantity In Volume(Litre)]         NUMERIC(18,2),
		[Value]								NUMERIC(18,2)
	)
	SET @TblName = 'RPTCURRENTSTOCK'
	SET @TblStruct = '  [CmpPrdCtgId]						INT,
						[Product Hierarchy Level Value]     NVARCHAR(200),
						[PrdCtgValMainId]					INT,
						[PrdCtgValCode]						NVARCHAR(300),
						[Description]						NVARCHAR(300),
						[PrdId]								INT,
						[Product Code]						NVARCHAR(200),
						[Product Name]						NVARCHAR(300),
						[LcnId]								INT,
						[Location Name]						NVARCHAR(300),
						[SystemStockType]					TINYINT,
						[Stock Type]						NVARCHAR(100),
						[Quantity Packs]					INT,
						[PrdUnitId]							INT,
						[Quantity In Volume(Unit)]			NUMERIC(18,2),
						[Quantity In Volume(KG)]            NUMERIC(18,2),
						[Quantity In Volume(Litre)]         NUMERIC(18,2),
						[Value]								NUMERIC(18,2)'
	SET @TblFields = '[CmpPrdCtgId],[Product Hierarchy Level Value],[PrdCtgValMainId],[PrdCtgValCode],[Description],[PrdId],[Product Code],
					  [Product Name],[LcnId],[Location Name],[SystemStockType],[Stock Type],[Quantity Packs],[PrdUnitId],
					  [Quantity In Volume(Unit)],[Quantity In Volume(KG)],[Quantity In Volume(Litre)],[Value]'
	
INSERT INTO #RPTCURRENTSTOCKAN
SELECT DISTINCT G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
F.PrdId,F.PrdCCode,F.PrdName,F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,BaseQty,PrdUnitId,PrdOnUnit,PrdOnKg,
PrdOnLitre,SumValue
	FROM ProductCategoryValue C
	INNER JOIN 
		(Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
			WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
			ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
			A.Prdid from Product A
	INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
		(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
		 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
	INNER JOIN 
(SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,0 AS BaseQty,
B.PrdUnitId,0 AS PrdOnUnit,0 AS PrdOnKg,0 AS PrdOnLitre,0 as SumValue
FROM ProductBatchLocation A 
INNER JOIN Product B ON A.PrdId=B.PrdId 

INNER JOIN Location C ON A.LcnId=C.LcnId
INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
WHERE B.CmpId=@CmpId AND
(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)))) F ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 	
INNER JOIN 
(SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,
CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END AS BaseQty,
B.PrdUnitId,0 AS PrdOnUnit,
ISNULL(CASE B.PrdUnitId WHEN 2 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
WHEN 3 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnKg,
ISNULL(CASE B.PrdUnitId WHEN 4 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
WHEN 5 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnLitre,
(CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)* G.SellingRate as SumValue
FROM ProductBatchLocation A 
INNER JOIN Product B ON A.PrdId=B.PrdId  
INNER JOIN Location C ON A.LcnId=C.LcnId
INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
INNER JOIN DefaultPriceHistory G ON A.PrdId=G.PrdId AND G.CurrentDefault=1 AND A.PrdBatId=G.PrdbatId

WHERE B.CmpId=@CmpId AND
(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))) GROUP BY 
A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,B.PrdUnitId,B.PrdWgt,G.SellingRate) F ON D.PrdId=F.PrdId 
	INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
	ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
	AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR
	C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
	(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
	G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
--      Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RPTCURRENTSTOCKAN
--	 Till Here

IF @SupZeroStock=1
	BEGIN 
		SELECT  * FROM #RPTCURRENTSTOCKAN WHERE [Quantity Packs]<>0 
    END
ELSE
		SELECT * FROM #RPTCURRENTSTOCKAN 

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-211-009-From Boo

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnFiltersValue]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnFiltersValue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Fn_ReturnFiltersValue]
(
	@Pi_RecordId Bigint,
	@Pi_ScreenId INT,
	@Pi_ReturnId INT
)
RETURNS nVarchar(1000)
AS
/*********************************
* FUNCTION: Fn_ReturnFiltersValue
* PURPOSE: Returns the Code or Name for the MasterId
* NOTES:
* CREATED: Thrinath Kola	31-07-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
@Pi_ReturnId		1		Code
@Pi_ReturnId		2		Name
*********************************/
BEGIN

	DECLARE @RetValue as nVarchar(1000)

	IF @Pi_ScreenId = 1
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SMCode ELSE SMName END
			FROM SalesMan WHERE SMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 2
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RMCode ELSE RMName END
			FROM RouteMaster WHERE RMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 3
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtrCode ELSE RtrName END
			FROM Retailer WHERE RtrID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 4
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpCode ELSE CmpName END
			FROM Company WHERE CmpId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 5
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdDCode ELSE PrdName END
			FROM Product WHERE PrdId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 7
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 8
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SchCode ELSE SchDsc END
			FROM SchemeMaster WHERE SchID  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 9
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SpmCode ELSE SpmName END
			FROM Supplier WHERE SpmID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 14
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SALESINVOICE WHERE SALID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 15
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SALESINVOICE WHERE SALID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 16 OR  @Pi_ScreenId = 251
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpPrdCtgName ELSE CmpPrdCtgName END
			FROM ProductCategoryLevel WHERE CmpPrdCtgId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 17
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 18
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 19
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 21
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdCtgValCode ELSE PrdCtgValName END
			FROM ProductCategoryValue WHERE PrdCtgValMainId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 22
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 23
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 24
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 25
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptId IN(7,13)
	END
	IF @Pi_ScreenId = 28
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 29
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CtgLevelName ELSE CtgLevelName END
			FROM RetailerCategoryLevel WHERE CtgLevelId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 30
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CtgName ELSE CtgName END
			FROM RetailerCategory WHERE CtgMainId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 31
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ValueClassCode ELSE ValueClassName END
			FROM RetailerValueClass WHERE RtrClassId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 32
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ReturnCode ELSE ReturnCode END
			FROM ReturnHeader WHERE ReturnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 33
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 34
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SalesInvoice WHERE SalId  = @Pi_RecordId
	END		
	IF @Pi_ScreenId = 35
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RMCode ELSE RMName END
			FROM RouteMaster WHERE RMId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 36
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCode ELSE VehicleRegNo END
			FROM Vehicle WHERE VehicleId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 37
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AllotmentNumber ELSE AllotmentNumber END
			FROM VehicleAllocationMaster WHERE AllotmentId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 38
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(67) AND SelId =38)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		ELSE
		BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM StockManagementType WHERE StkMgmtTypeId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 39
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 40
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 41
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ClmCode ELSE ClmDesc END
			FROM ClaimSheetHD WHERE ClmId  = @Pi_RecordId
	END        	
	IF @Pi_ScreenId = 42
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ClmGrpCode ELSE ClmGrpName END
			FROM ClaimGroupMaster WHERE ClmGrpId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 43
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 44
	--Added by Thiru on 03/09/09
	IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =4 AND SelId =44)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=4
		END
	ELSE
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 45
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 46
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 47
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE CoaId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 48
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 49
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE AcCode  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 50
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE AcCode  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 51
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	---Adde By Murugan
	IF @Pi_ScreenId = 53
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=53)
			BEGIN
				SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
					FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
			END
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=54)
			BEGIN
				SELECT @RetValue = UomDescription  FROM UomMaster WHERE Uomid in( SELECT SelValue FROM
					Reportfilterdt WHERE Rptid in(44,43) AND SelId=54)
			END
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=55)
			BEGIN
				SELECT @RetValue = PrdUnitCode  FROM productUnit WHERE PrdUnitId in( SELECT SelValue FROM
					Reportfilterdt WHERE Rptid in(44,43) AND SelId=55)
			END
	END
	IF @Pi_ScreenId = 56
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(44,59) AND SelId =56)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		
	END
	IF @Pi_ScreenId = 66
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 64
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Cast(FilterDesc as Varchar(20)) ELSE Cast(FilterDesc as Varchar(20)) END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 63
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 65
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VillageName ELSE VillageName END
			FROM RouteVillage WHERE VillageId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 67
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 68
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 69
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	
	IF @Pi_ScreenId = 70
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkCode ELSE BnkName END
			FROM Bank WHERE BnkId  = @Pi_RecordId
		END
	
	IF @Pi_ScreenId = 71
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkBrCode ELSE BnkBrName END
			FROM BankBranch WHERE BnkBrId  = @Pi_RecordId
		END
	IF @Pi_ScreenId = 77
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	IF @Pi_ScreenId = 75
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	IF @Pi_ScreenId = 52
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UOMCode ELSE UOMDescription END
			FROM UomMaster WHERE UOMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 12
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN JcmYr ELSE JcmYr END
			FROM JCMast WHERE JcmId  = @Pi_RecordId
		END
	IF @Pi_ScreenId = 79
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(63) AND SelId =79)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		
	END
	IF @Pi_ScreenId = 80
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(63) AND SelId =80)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 88
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM StockManagementType WHERE StkMgmtTypeId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 84
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DistributorName ELSE DistributorName END
			FROM Distributor WHERE DistributorId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 85
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransporterName ELSE TransporterName END
			FROM Transporter WHERE TransporterId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 86
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCtgName ELSE VehicleCtgName END
			FROM VehicleCategory WHERE VehicleCtgId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 87
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCode ELSE VehicleCode END
			FROM Vehicle WHERE VehicleId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 83
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(33) AND SelId =83)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	
	IF @Pi_ScreenId = 89
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 90
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 92
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrfCode ELSE PrfName END
			FROM ProfileHd WHERE PrfId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 93
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserName ELSE UserName END
			FROM Users WHERE UserId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 94
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 95
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrfName ELSE PrfName END
			FROM ProfileHd WHERE PrfId = @Pi_RecordId
	END
	IF @Pi_ScreenId = 96  --User Profile Master
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(80) AND SelId =96)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	
	IF @Pi_ScreenId = 99
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ColumnDataType ELSE ColumnName END
			FROM UdcMaster WHERE UdcMasterId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 100
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MasterName ELSE MasterName END
			FROM UdcHd WHERE MasterId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 101
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 102 --Credit Note Supplier
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CrNoteNumber ELSE CrNoteNumber END
			FROM CreditNoteSupplier WHERE CrNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 103 --Debit Note Retailer
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DbNoteNumber ELSE DbNoteNumber END
			FROM DebitNoteRetailer WHERE DbNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 108 --Credit Note Retailer
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CrNoteNumber ELSE CrNoteNumber END
			FROM CreditNoteRetailer WHERE CrNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 104
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =90 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=90
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =81 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=81
		END
		ELSE IF  EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =82 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=82
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =84 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=84
		END
		ELSE IF  EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =85 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=85
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =87 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=87
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =88 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=88
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =89 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=89
		END
		ELSE
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 91  --TaxConfiguration
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(78) AND SelId =91)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxCode ELSE TaxName END
			FROM TaxConfiguration WHERE TaxId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 97  --TaxGroupSetting
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(79) AND SelId =97)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 98  --TaxGroupSetting
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(79) AND SelId =98)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 109  --SalesForce Level
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =109)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LevelName ELSE LevelName END
			FROM SalesForcelevel WHERE SalesForceLevelId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 110  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =110)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalesForceCode ELSE SalesForceName END
			FROM SalesForce WHERE SalesForceMainId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 111  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(89) AND SelId =111)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DlvBoyCode ELSE DlvBoyName END
			FROM DeliveryBoy WHERE DlvBoyId  = @Pi_RecordId
		END
	END
---
	IF @Pi_ScreenId = 106 --Vehicle Subsidy Master
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(86) AND SelId =106)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptId in (86)
		END
		ELSE
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
---
	IF @Pi_ScreenId = 107  --Van Subsidy Master
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(86) AND SelId =107)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleSubCode ELSE VehicleSubCode END
			FROM VehicleSubsidy WHERE VehicleSubId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 109  --SalesForce Level
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =109)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LevelName ELSE LevelName END
			FROM SalesForcelevel WHERE SalesForceLevelId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 110  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =110)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalesForceCode ELSE SalesForceName END
			FROM SalesForce WHERE SalesForceMainId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 111  --Delivery Boy
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(89,97) AND SelId =111)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DlvBoyCode ELSE DlvBoyName END
			FROM DeliveryBoy WHERE DlvBoyId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 112  --Retailer Potential Class
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(93) AND SelId =112)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PotentialClassCode ELSE PotentialClassName END
			FROM RetailerPotentialClass WHERE RtrClassId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 113
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 114
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 115  --SalesMan Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(96) AND SelId =115)
		BEGIN
			
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ScmRefNo ELSE ScmRefNo END
			FROM SalesmanClaimMaster WHERE scmRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 96 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
		END
	END
	IF @Pi_ScreenId = 116  --Delivery Boy Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(97) AND SelId =116)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DbcRefNo ELSE DbcRefNo END
			FROM DeliveryBoyClaimMaster WHERE DlvBoyClmId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 117 --Transporter Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TrcRefNo ELSE TrcRefNo END
			FROM TransporterClaimMaster WHERE TrcRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 118  --Purchase Shortage Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(99) AND SelId =118)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurShortRefNo ELSE PurShortRefNo END
			FROM PurShortageClaim WHERE PurShortId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 119 --Purchase Excess Refusal Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM PurchaseExcessClaimMaster WHERE RefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 121  --Special Discount Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(102) AND SelId =121)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SdcRefNo ELSE SdcRefNo END
			FROM SpecialDiscountMaster WHERE SplDiscClaimId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 122  --Van Subsidy Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(103) AND SelId =122)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM VanSubsidyHD WHERE VanSubsidyId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 126 --Manual Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MacRefNo ELSE MacRefNo END
			FROM ManualClaimMaster WHERE MacRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 120  --Rate Difference Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(101) AND SelId =120)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM RateDifferenceClaim WHERE RateDiffClaimId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 123
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 124
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 125
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 127
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(106) AND SelId =127)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SicRefNo ELSE SicRefNo END
			FROM SMIncentiveCalculatorMaster WHERE SicRefNo  IN
			( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 106 AND SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
		END
	END
	IF @Pi_ScreenId = 128
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 129
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UOMCode ELSE UOMDescription END
			FROM UOMMaster WHERE UOMId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 130
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 131
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ChequeNo ELSE ChequeNo END
			FROM ChequeInventoryRtrDt WHERE ChequeNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 132
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 134
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
			FROM StockType WHERE UserStockType  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 135
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
			FROM StockType WHERE UserStockType  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 136
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM ReasonMaster WHERE ReasonId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 137
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN StkJournalRefNo ELSE StkJournalRefNo END
			FROM StockJournal WHERE StkJournalRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 138
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN NormDescription ELSE NormDescription END
			FROM Norms WHERE NormId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 141
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkBrCode ELSE BnkBrName END
		FROM BankBranch WHERE BnkBrId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 142 OR  @Pi_ScreenId = 143 OR  @Pi_ScreenId = 144 OR  @Pi_ScreenId = 145
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AttrName ELSE AttrName END
		FROM PurInvSeriesAttribute WHERE AttributeId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 146
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 147
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 148
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN InstrumentNo ELSE InstrumentNo END
			FROM ChequeInventorySuppDt WHERE InstrumentNo  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 149
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcmYr ELSE AcmYr END
		FROM AcMaster WHERE AcmYr  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 150
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 151
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 152
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN OrderNo ELSE OrderNo END
			FROM OrderBooking WHERE OrderNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 153
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionDescription ELSE TransactionDescription END
			FROM TransactionMaster WHERE TransactionId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 154
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 155
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 156
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 157
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VocRefNo ELSE VocRefNo END
			FROM StdVocMaster WHERE VocRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 158
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN StkMngRefNo ELSE StkMngRefNo END
			FROM StockManagement WHERE StkMngRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 127 AND
						SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 159
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN [Description] ELSE [Description] END
			FROM ReasonMaster WHERE ReasonId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 160
	BEGIN
	SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ReDamRefNo ELSE ReDamRefNo END
			FROM ResellDamageMaster WHERE ReDamRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 113 AND
						SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 161
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurOrderRefNo ELSE PurOrderRefNo END
			FROM PurchaseorderMaster WHERE PurOrderRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 162
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefCode ELSE RefCode END
			FROM BatchCreationMaster WHERE BatchSeqId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 163 --Van Load Unload
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VanLoadRefNo ELSE VanLoadRefNo END
			FROM VanLoadUnloadMaster WHERE VanLoadRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 164
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
		FROM StockType WHERE StockTypeId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 165
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtnCmpRefNo ELSE RtnCmpRefNo END
			FROM ReturnToCompany WHERE RtnCmpRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 166
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ModuleName ELSE ModuleName END
			FROM Counters WHERE ModuleName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 116 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 167
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 168
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 169
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 170
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 171 --Payment
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PayAdvNo ELSE PayAdvNo END
			FROM PurchasePayment WHERE PayAdvNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 172
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 173 --GRN Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRcptRefNo ELSE PurRcptRefNo END
			FROM PurchaseReceipt WHERE PurRcptRefNo  = @Pi_RecordId
	END	
	
	IF @Pi_ScreenId = 174 --Company Invoice Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpInvNo ELSE CmpInvNo END
			FROM PurchaseReceipt WHERE CmpInvNo  = @Pi_RecordId
	END
		
	IF @Pi_ScreenId = 175 --Purchase Return Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 176--Purchase Return Type
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 177 --From Product Batch
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 178 --To Product Batch
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 179
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 180
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BatRefNo ELSE BatRefNo END
			FROM BatchTRansfer WHERE BatRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 181
	BEGIN
			
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalvageRefNo ELSE SalvageRefNo END
			FROM Salvage WHERE SalvageRefNo  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 182
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 183
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 184
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FocusRefNo ELSE FocusRefNo END
			FROM FocusBrandHd WHERE FocusRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 140 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 185 OR @Pi_ScreenId = 186 OR @Pi_ScreenId = 187 OR @Pi_ScreenId = 188 OR @Pi_ScreenId = 189 OR @Pi_ScreenId = 192 OR @Pi_ScreenId = 193
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 190
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FormName ELSE FormName END
			FROM HotSearchEditorHd WHERE FormName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 144 AND
			SelId = @Pi_ScreenId )	
	END
	IF @Pi_ScreenId = 191
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ControlName ELSE ControlName END
			FROM HotSearchEditorHd WHERE ControlName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 144 AND
			SelId = @Pi_ScreenId )	
	END
	
	IF @Pi_ScreenId = 194
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpInvNo ELSE CmpInvNo END
			FROM PurchaseReceipt WHERE PurRcptId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 195
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionNo1 ELSE TransactionNo1 END
			FROM (SELECT DISTINCT SalInvNo AS TransactionNo1
			FROM SalesInvoice  UNION  SELECT DISTINCT ReturnCode AS TransactionNo1 FROM ReturnHeader
			UNION  SELECT DISTINCT RepRefNo AS TransactionNo1 FROM ReplacementHd) A WHERE TransactionNo1
			IN ( SELECT CAST(SelDate AS VARCHAR(25)) FROM ReportFilterDt WHERE Rptid= 29 AND
			SelId = @Pi_ScreenId)
	END
	IF @Pi_ScreenId = 196
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 197
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRcptRefNo ELSE PurRcptRefNo END
			FROM PurchaseReceipt WHERE PurRcptId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 199
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalvageRefNo ELSE SalvageRefNo END
			FROM sALVAGE WHERE SalvageRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 21 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 200
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 201
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionNo1 ELSE TransactionNo1 END
			FROM (SELECT DISTINCT PurRcptRefNo AS TransactionNo1
			FROM PurchaseReceipt  UNION  SELECT DISTINCT PurRetRefNo AS TransactionNo1 FROM PurchaseReturn) A WHERE TransactionNo1
			IN ( SELECT CAST(SelDate AS VARCHAR(25)) FROM ReportFilterDt WHERE Rptid= 29 AND
			SelId = @Pi_ScreenId)
	END
	IF @Pi_ScreenId = 202
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 203
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 204
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 205
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 206
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 208
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 209
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 210
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 211
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptID=153
	END
	IF @Pi_ScreenId = 215
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtrName ELSE RtrName END
			FROM Retailer WHERE RtrId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 216
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN IssueRefNo ELSE IssueRefNo END
			FROM SampleIssueHd WHERE IssueId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 217 OR @Pi_ScreenId = 241 OR @Pi_ScreenId = 260 OR @Pi_ScreenId =  261 OR @Pi_ScreenId =  262
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF  @Pi_ScreenId = 232
	BEGIN
		SELECT @RetValue = FilterDesc
		FROM RptFilter INNER JOIN ReportFilterDt ON SelId=SelcId
		AND ReportFilterDt.RptId=RptFilter.RptId  AND FilterId=SelValue
		WHERE  SelcId=@Pi_ScreenId	AND UsrId=@Pi_ReturnId
	END
	IF @Pi_ScreenId = 240 
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptID=5
	END

	IF @Pi_ScreenId = 255  --Mordern Trade Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid IN(213) AND SelId =255)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MTCRefNo ELSE MTCRefNo END
			FROM ModernTradeMaster WHERE MTCSplDiscClaimId  = @Pi_RecordId
		END
	END

	

	RETURN(@RetValue)

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-211-010-From Boo

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptRtrPrdWiseSales')
DROP PROCEDURE Proc_RptRtrPrdWiseSales
GO 
--select * from ReportfilterDt where rptid = 90 And selid = 66
--EXEC Proc_RptRtrPrdWiseSales 220,2,0,'ASKO',0,0,1
CREATE    PROCEDURE [dbo].[Proc_RptRtrPrdWiseSales]
/************************************************************
* PROCEDURE	: Proc_RptRtrPrdWiseSales
* PURPOSE	: Retailer and Product Wise Sales Volume
* CREATED BY	: Boopathy.P
* CREATED DATE	: 14/03/2011
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
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
SET NOCOUNT ON
BEGIN
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	nvarchar(50)
	DECLARE @TblName 		AS	nvarchar(500)
	DECLARE @TblStruct 		AS	nVarchar(4000)
	DECLARE @TblFields 		AS	nVarchar(4000)
	DECLARE @SSQL			AS 	VarChar(8000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @RMId			AS	INT
	DECLARE @SMId			AS	INT
	DECLARE @RtrId 			AS 	INT
	DECLARE @CmpId 			AS 	INT
	DECLARE @PrdCatLvlId 	AS 	INT
	DECLARE @PrdCatValId 	AS 	INT
	DECLARE @PrdId 			AS 	INT
	DECLARE @Display		AS 	INT

	CREATE  TABLE #RptRtrPrdWiseSales
		(
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			BaseQty				NUMERIC(18,0),
			PrdUnitId			INT,
			PrdOnUnit			NUMERIC(18,0),
			PrdOnKg				NUMERIC(18,6),
			PrdOnLitre			NUMERIC(18,6),
			PrdNetAmount		NUMERIC(18,6),
			DispMode			INT
		)


	SET @SMId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CmpId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdCatLvlId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @Display = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,260,@Pi_UsrId))

	IF @CmpId=0
	BEGIN
		SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
	END
	

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	
	SET @TblName = 'RptRtrPrdWiseSales'
	
	SET @TblStruct ='		
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			PrdUnitId			INT,
			PrdOnUnit			NUMERIC(18,0),
			PrdOnKg				NUMERIC(18,6),
			PrdOnLitre			NUMERIC(18,6),
			PrdNetAmount		NUMERIC(18,6),
			DispMode			INT'					
	
	SET @TblFields = 'RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
			PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode'
			
	IF @Display=2
	BEGIN
		IF (@PrdCatLvlId=0 AND @PrdCatValId=0 AND @PrdId=0) OR 
			(@PrdCatLvlId>0 AND @PrdCatValId=0 AND @PrdId=0) OR
			(@PrdCatLvlId>0 AND @PrdCatValId>0 AND @PrdId=0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   0,'','',PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdUnitId
		END
		ELSE --IF (@PrdCatLvlId>0 AND @PrdCatValId>0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   PrdId,PrdCCode,Prdname,PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),1 FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE 0 END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdId,PrdCCode,Prdname,PrdUnitId
		END
	END
	ELSE
	BEGIN
		INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
				PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
		SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			   PrdId,PrdCCode,Prdname,PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
			(
			SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
						WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
						ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
							FROM salesInvoice A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
							FROM salesInvoice A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
				C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			UNION
			SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
						WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
						ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
				C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ) A
				GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			    PrdId,PrdCCode,Prdname,PrdUnitId
	END
	UPDATE #RptRtrPrdWiseSales SET BaseQty=PrdOnUnit
	UPDATE #RptRtrPrdWiseSales SET PrdOnUnit=0 WHERE PrdUnitId>1
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptRtrPrdWiseSales
	select * from #RptRtrPrdWiseSales 
RETURN
END
GO

--SRF-Nanda-211-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_VoucherPostingPurchase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_VoucherPostingPurchase]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_VoucherPostingPurchase 5,1,'GRN100000003',5,0,2,'2011-03-17',0
SELECT * FROM StdVocMaster(NOLOCK) WHERE VocRefNo='PUR1000007'
SELECT * FROM StdVocDetails(NOLOCK) WHERE VocRefNo='PUR1000007'
SELECT * FROM CoaMaster(NOLOCK) WHERE CoaId IN (247,324,329,251)
ROLLBACK TRANSACTION
*/

CREATE                 Procedure [dbo].[Proc_VoucherPostingPurchase]
(
	@Pi_TransId		Int,
	@Pi_SubTransId		Int,
	@Pi_ReferNo		nVarChar(100),
	@Pi_VocType		INT,
	@Pi_SubVocType		INT,	
	@Pi_UserId		Int,
	@Pi_VocDate		DateTime,
	@Po_PurErrNo		Int OutPut
)
AS
/*********************************
* PROCEDURE	: Proc_VoucherPostingPurchase
* PURPOSE	: General SP for posting Purchase Voucher
* CREATED	: Thrinath
* CREATED DATE	: 25/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @AcmId 		INT
	DECLARE @AcpId		INT
	DECLARE @CoaId		INT
	DECLARE @VocRefNo	nVarChar(100)
	DECLARE @sStr		nVarChar(4000)
	DECLARE @Amt		Numeric(25,6)
	DECLARE @DCoaId		INT
	DECLARE @CCoaId		INT
	DECLARE @DiffAmt	Numeric(25,6)
	DECLARE @sSql           VARCHAR(4000)
	SET @Po_PurErrNo = 1

	IF @Pi_TransId = 5 AND @Pi_SubTransId = 1
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END

		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END

		--For Posting Purchase Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From GRN ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'

		--For Posting Purchase Account in Details Table on Debit(Gross Amount)
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110001')
		BEGIN
			SET @Po_PurErrNo = -2
			Return
		END
		
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110001'
		SELECT @Amt = SUM(PrdGrossAmount) FROM PurchaseReceiptProduct
		WHERE PurRcptId IN (SELECT PurRcptId FROM
		PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo)
		

		DECLARE @Amt1 AS NUMERIC(38,6)

		SELECT @Amt1=LessScheme FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo

		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt-@Amt1,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
		--For Posting Supplier Account in Details Table to Credit(Net Payable)
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
			WHERE C.PurRcptRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END

		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
			WHERE C.PurRcptRefNo = @Pi_ReferNo

		--->Modified By Nanda on 29/10/2010
		--SELECT @Amt = NetPayable FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
		SELECT @Amt = NetPayable+DbAdjustAmt-CrAdjustAmt FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))

		--For Posting Purchase Discount Account in Details Table to Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptHdAmount B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0

		--For Posting Purchase Addition Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,D.CoaId,1 AS DebitCredit,B.BaseQtyAmount AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,
			@Pi_UserId AS AuthId,Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurTotAdd
		FROM PurchaseReceipt A INNER JOIN PurchaseReceiptHdAmount B ON
			A.PurRcptId = B.PurRcptId
		INNER JOIN PurchaseSequenceMaster C ON
			A.PurSeqId = C.PurSeqId
		INNER JOIN PurchaseSequenceDetail D ON
			C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
		WHERE A.PurRcptRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
			EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurTotAdd

		--For Posting Purchase Tax Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,C.InputTaxId,1 AS DebitCredit,ISNULL(SUM(B.TaxAmount),0) AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,@Pi_UserId AS AuthId,
			Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurTaxForDiff
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptProductTax B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRcptRefNo = @Pi_ReferNo
			Group By C.InputTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0

		SELECT @DiffAmt=ISNULL((SUM(A.TotalAddition)-(SUM(B.Amount)+SUM(C.Amount))),0)
		FROM PurchaseReceipt A,#PurTaxForDiff B,#PurTotAdd C
		WHERE A.PurRcptRefNo = @Pi_ReferNo
		
		UPDATE #PurTaxForDiff SET Amount=Amount+@DiffAmt
		WHERE InputTaxId IN (SELECT MIN(InputTaxId) FROM #PurTaxForDiff)
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurTaxForDiff

		--For Posting Scheme Discount in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210002')
		BEGIN
			SET @Po_PurErrNo = -9
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210002'
		SET @Amt = 0
		SELECT @Amt = LessScheme FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND LessScheme > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Other Charges Add in Details Table For Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,B.CoaId,1,ISNULL(SUM(B.Amount),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptOtherCharges B ON
				A.PurRcptId = B.PurRcptId
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 0
			Group By B.CoaId
			HAVING ISNULL(SUM(B.Amount),0) > 0

		--For Posting Other Charges Reduce in Details Table To Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,B.CoaId,2,ISNULL(SUM(B.Amount),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptOtherCharges B ON
				A.PurRcptId = B.PurRcptId
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 1
			Group By B.CoaId
			HAVING ISNULL(SUM(B.Amount),0) > 0

		--For Posting Round Off Account reduce in Details Table to Debit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3220001')
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3220001'
		SET @Amt = 0
		SELECT @Amt = DifferenceAmount FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND DifferenceAmount > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,2,Abs(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Round Off Account Add in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4210001')
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4210001'
		SET @Amt = 0
		SELECT @Amt = DifferenceAmount FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND DifferenceAmount < 0
		
		IF @Amt < 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END

		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END

	IF @Pi_TransId = 7 AND @Pi_SubTransId = 1	--Purchase Return
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		--For Posting Purchase Return Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Purchase Return ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		--For Posting Purchase Return Account in Details Table on Debit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110002')
		BEGIN
			SET @Po_PurErrNo = -22
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110002'
		SELECT @Amt = GrossAmount FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Supplier Account in Details Table to Credit
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReturn C ON B.SpmId = C.SpmId
			WHERE C.PurRetRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReturn C ON B.SpmId = C.SpmId
			WHERE C.PurRetRefNo = @Pi_ReferNo
		SELECT @Amt = NetAmount FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Discount Account in Details Table to Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,1,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = @Pi_ReferNo AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',D.CoaId,1,B.BaseQtyAmount,1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Addition Account in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
				EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',D.CoaId,2,B.BaseQtyAmount,1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND B.RefCode <> ''' + 'D' + ''' AND
				EffectInNetAmount = 1 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Tax Account in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
				A.PurRetId = B.PurRetId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRetRefNo = @Pi_ReferNo
			Group By C.InPutTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
				A.PurRetId = B.PurRetId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + '''
			Group By C.InPutTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Scheme Discount in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210002')
		BEGIN
			SET @Po_PurErrNo = -9
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210002'
		SET @Amt = 0
		SELECT @Amt = LessScheme FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
			AND LessScheme > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'
			--INSERT INTO Translog(strSql1) Values (@sstr)
		END

		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END	
	IF @Pi_TransId = 13 AND @Pi_SubTransId = 0  -- Stock Out
	BEGIN

		IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
			INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
			WHERE SM.StkMngRefNo=@Pi_ReferNo AND SMT.Coaid=299)	
		BEGIN	
			Select @Amt=SUM(Amount)+SUM(TaxAmt)  FROM StockManagement SM
			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
			WHERE SM.StkMngRefNo=@Pi_ReferNo
		END
		ELSE
		BEGIN
			Select @Amt=SUM(Amount) FROM StockManagement SM
			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
			WHERE SM.StkMngRefNo=@Pi_ReferNo
		END
				
		
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		
		--For Posting StockAdjustment StockAdd Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
			(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Adjustment ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
				
			
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
				WHERE SM.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1 )
		BEGIN
			SET @Po_PurErrNo = -26
			Return
		END
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
				WHERE SM.StkMngRefNo=@Pi_ReferNo AND DebitCredit=2)
		BEGIN
			SET @Po_PurErrNo = -27
			Return
		END
		SELECT @DCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
		INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
		WHERE SM.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1 
		SELECT @CCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
		INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
		WHERE SM.StkMngRefNo=@Pi_ReferNo AND DebitCredit=2 AND SMT.Coaid<>299
			
		
		--For Posting Default Sales Account details on Debit
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'

			--For Posting Default Debtor Account details on Debit

			Select @Amt=SUM(Amount)  FROM StockManagement SM
			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
			WHERE SM.StkMngRefNo=@Pi_ReferNo
			
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'

			IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
				WHERE SM.StkMngRefNo=@Pi_ReferNo AND SMT.Coaid=299 AND DebitCredit=2)	
			BEGIN	

				SET @CCoaid=299

				Select @Amt=SUM(TaxAmt)  FROM StockManagement SM
				INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
				WHERE SM.StkMngRefNo=@Pi_ReferNo

				IF @Amt > 0
				BEGIN
					INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
					(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
						@Pi_UserId,Convert(varchar(10),Getdate(),121))
					SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
					(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
						',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
						+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
						Convert(nvarchar(10),Getdate(),121) + ''')'
				END

			END



		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			RETURN
		END
	END
	IF @Pi_TransId = 13 AND @Pi_SubTransId = 1   -- Stock In
	BEGIN
		

		Select @Amt=SUM(Amount) FROM StockManagement SM
		INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
		WHERE SM.StkMngRefNo=@Pi_ReferNo
			
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		
		--For Posting StockAdjustment StockAdd Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
			(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Adjustment ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
				
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
				WHERE SM.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1)
		BEGIN
			SET @Po_PurErrNo = -26
			Return
		END
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
				WHERE SM.StkMngRefNo=@Pi_ReferNo AND DebitCredit=2)
		BEGIN
			SET @Po_PurErrNo = -27
			Return
		END
				
		SELECT @DCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
			INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
			WHERE SM.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1 AND SMT.CoaId<>298

		SELECT @CCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
			INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
			WHERE SM.StkMngRefNo=@Pi_ReferNo AND DebitCredit=2 
			
		
		--For Posting Default Purchase Account details on Debit
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
				(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'


		IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
			INNER JOIN StockManagement SM ON SM.StkMgmtTypeId=SMT.StkMgmtTypeId
			WHERE SM.StkMngRefNo=@Pi_ReferNo AND SMT.Coaid=298 AND SMT.DebitCredit=1)	
		BEGIN

			Select @Amt=SUM(TaxAmt) FROM StockManagement SM
			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
			WHERE SM.StkMngRefNo=@Pi_ReferNo

			SET @DCoaid=298

			IF @Amt >0 
			BEGIN
				INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
					LastModDate,AuthId,AuthDate) VALUES
					(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
					@Pi_UserId,Convert(varchar(10),Getdate(),121))
				SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
						(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
						',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
						+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
						Convert(nvarchar(10),Getdate(),121) + ''')'
			END

		END


		Select @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagement SM
			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
			WHERE SM.StkMngRefNo=@Pi_ReferNo
			

		--For Posting Default Purchase Account details on Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'



		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			RETURN
		END
	END
	IF @Po_PurErrNo=1
	BEGIN
			EXEC Proc_PostStdDetails @Pi_VocDate,@VocRefNo,1
	END
	Return
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 363)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(363,'D','2011-03-17',getdate(),1,'Core Stocky Service Pack 363')
