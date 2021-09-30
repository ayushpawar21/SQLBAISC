--[Stocky HotFix Version]=383
Delete from Versioncontrol where Hotfixid='383'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('383','2.0.0.5','D','2011-08-26','2011-08-26','2011-08-26',convert(varchar(11),getdate()),'Major: Product Release FOR PM,CK,B&L-Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 383' ,'383'
GO

--SRF-Nanda-257-001

DELETE FROM HotSearchEditorHd WHERE FormId in (238,663)
DELETE FROM HotSearchEditordT WHERE FormId in (238,663)

INSERT HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
VALUES('238','Purchase Order','ReferenceNo','Select','SELECT PurOrderRefNo,CmpId,CmpName,SpmId,SpmName,PurOrderDate,      CmpPoNo,CmpPoDate,PurOrderExpiryDate,FillAllPrds,GenQtyAuto,PurOrderStatus,    ConfirmSts,DownLoad,Upload,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValName,PrdCtgValLinkCode,      SiteId,SiteCode,PurOrderValue,DispOrdVal,POType     FROM (SELECT A.PurOrderRefNo,A.CmpId,B.CmpName,A.SpmId,C.SpmName,A.PurOrderDate,A.CmpPoNo,A.CmpPoDate,A.PurOrderExpiryDate,A.FillAllPrds,A.GenQtyAuto,    A.PurOrderStatus,A.ConfirmSts,A.DownLoad,A.Upload, ISNULL(A.CmpPrdCtgId,0) AS CmpPrdCtgId,  ISNULL(PCL.CmpPrdCtgName,'''') AS CmpPrdCtgName,    ISNULL(A.PrdCtgValMainId,0) AS PrdCtgValMainId,  ISNULL(PCV.PrdCtgValName,'''') AS PrdCtgValName,  ISNULL(PCV.PrdCtgValLinkCode,0) AS PrdCtgValLinkCode ,    SCM.SiteId,SCM.SiteCode,A.PurOrderValue,A.DispOrdVal,(CASE A.Download WHEN 1 THEN ''System Generated'' ELSE ''Manual'' END) AS POType      FROM PurchaseOrderMaster A   LEFT OUTER JOIN Company B ON B.CmpId=A.CmpId     LEFT OUTER JOIN Supplier C ON A.SpmId=C.SpmId         LEFT JOIN ProductCategoryLevel PCL ON PCL.CmpPrdCtgId=A.CmpPrdCtgId       LEFT JOIN ProductCategoryValue PCV ON PCV.PrdCtgValMainId=A.PrdCtgValMainId      LEFT OUTER JOIN SiteCodeMaster SCM ON PCV.PrdCtgValMainId=SCM.PrdCtgValMainId AND SCM.SiteId=A.SiteID  ) AS A')

INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','238','ReferenceNo','PO Type','POType','1400','3','HotSch-26-2000-39','26')

INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','238','ReferenceNo','Reference No','PurOrderRefNo','1500','2','HotSch-26-2000-3','26')

INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','238','ReferenceNo','Date','PurOrderDate','1500','1','HotSch-26-2000-4','26')


INSERT HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
VALUES('663','Return and Replacement','Replacement No','Select','SELECT RH.RepRefNo,RH.RepDate,RH.Status,RH.RepId,R.RtrName FROM ReplacementHd RH WITH (NOLOCK),Retailer R  WITH (NOLOCK) WHERE R.RtrId=RH.RtrId')

INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','663','Replacement No','Number','RepRefNo','1500','0','HotSch-24-2000-10','24')

INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','663','Replacement No','Date','RepDate','1000','0','HotSch-24-2000-11','24')

INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','663','Replacement No','Retailer','RtrName','2000','0','HotSch-24-2000-40','24')

--SRF-Nanda-257-002

DELETE FROM DependencyTable  WHERE PrimaryTable='OrderBooking'

INSERT INTO DependencyTable(PrimaryTable,RelatedTable,FieldName)
VALUES('OrderBooking','SalesInvoiceOrderBooking','OrderNo')

--SRF-Nanda-257-003-From Karthick

Delete from RptGroup where RptId in (166,209)
Delete from RptHeader where RptId in (166,209)
Delete from RptDetails where RptId in (166,209)
GO
DELETE FROM RptGroup WHERE GrpCode='EFFECTIVECOVERAGEANALYSISREPORT'
INSERT INTO RptGroup
SELECT 'RspReport',211,'EFFECTIVECOVERAGEANALYSISREPORT','Effective Coverage Analysis Report'
GO
DELETE FROM RptGroup WHERE GrpCode='RetailerWiseValueReport'
INSERT INTO RptGroup
SELECT 'RspReport',171,'RetailerWiseValueReport','Retailer Wise Value Report'
GO
DELETE FROM RptHeader WHERE RptId=171
INSERT INTO RptHeader 
SELECT 'RetailerWiseValueReport','Retailer Wise Value Report',171,'Retailer Wise Value Report','Proc_RptRetailerWiseValueReport','RptRetailerWiseValueReport','RptRetailerWiseValueReport.rpt',''	
GO
DELETE FROM RptHeader WHERE RptId=211
Insert Into RptHeader 
SELECT 'EFFECTIVECOVERAGEANALYSISREPORT','Effective Coverage Analysis Report',211,'Effective Coverage Analysis Report','Proc_RptECAnalysisReport','RptECAnalysisReport','RptECAnalysisReport.rpt',''
GO
 DELETE FROM Rptdetails WHERE RptId=171
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,1,'JCMast',-1,'','JcmId,JcmYr,JcmYr','JC Year*...','',1,NULL,12,1,1,'Press F4/Double Click to select JC Year',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,2,'JCMonth',1,'JcmId','JcmJc,JcmSdt,JcmSdt','From JC Month*...','JcMast',1,'JcmId',13,1,1,'Press F4/Double Click to select From JC Month',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,3,'JCMonth',1,'JcmId','JcmJc,JcmEdt,JcmEdt','To JC Month*...','JcMast',1,'JcmId',20,1,1,'Press F4/Double Click to select To JC Month',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,4,'Company',-1,'','CmpId,CmpCode,CmpName','Company*...',NULL,1,NULL,4,1,1,'Press F4/Double Click to select Company',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,5,'SalesMan',-1,NULL,'SMId,SMCode,SMName','SalesMan...',NULL,1,NULL,1,1,NULL,'Press F4/Double Click to select Salesman',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,6,'RouteMaster',-1,NULL,'RMId,RMCode,RMName','Route...',NULL,1,NULL,2,NULL,NULL,'Press F4/Double Click to select Route',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,7,'RetailerCategoryLevel',4,'CmpId','CtgLevelId,CtgLevelName,CtgLevelName','Retailer Category Level...','Company',1,'CmpId',29,1,NULL,'Press F4/Double Click to Retailer Category Level',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,8,'RetailerCategory',7,'CtgLevelId','CtgMainId,CtgName,CtgName','Retailer Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,1,NULL,'Press F4/Double Click to Retailer Category Level Value',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,9,'RetailerValueClass',8,'CtgMainId','RtrClassId,ValueClassName,ValueClassName','Retailer Value Classification...','RetailerCategory',1,'CtgMainId',31,1,NULL,'Press F4/Double Click to select Retailer Value Classification',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,10,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,1,NULL,3,NULL,NULL,'Press F4/Double Click to select Retailer',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,11,'ProductCategoryLevel',4,'','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,NULL,'Press F4/Double Click to select Product Hierarchy Level',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,12,'ProductCategoryValue',11,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,NULL,NULL,'Press F4/Double Click to select Product Hierarchy Level Value',0)
 INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (171,13,'Product',12,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,NULL,NULL,'Press F4/Double Click to select Product',0)
GO
 DELETE FROM RptDetails WHERE RptId=211
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,2,'ToDate',-1,'','','To Date*','',1,'',11,0,1,'Enter To Date',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company*...','',1,'',4,1,1,'Press F4/Double Click to select Company',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,4,'SalesMan',-1,'','SMId,SMCode,SMName','SalesMan...','',1,'',1,1,0,'Press F4/Double Click to select Salesman',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,5,'RouteMaster',-1,'','RMId,RMCode,RMName','Route...','',1,'',2,0,0,'Press F4/Double Click to select Route',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,6,'RetailerCategoryLevel',3,'CmpId','CtgLevelId,CtgLevelName,CtgLevelName','Retailer Category Level...','Company',1,'CmpId',29,1,0,'Press F4/Double Click to Retailer Category Level',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,7,'RetailerCategory',6,'CtgLevelId','CtgMainId,CtgName,CtgName','Retailer Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,1,NULL,'Press F4/Double Click to Retailer Category Level Value',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,8,'RetailerValueClass',7,'CtgMainId','RtrClassId,ValueClassName,ValueClassName','Retailer Value Classification...','RetailerCategory',1,'CtgMainId',31,1,NULL,'Press F4/Double Click to select Retailer Value Classification',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,9,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer Group...',NULL,1,NULL,215,NULL,NULL,'Press F4/Double Click to select Retailer Group',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,10,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,1,NULL,3,NULL,NULL,'Press F4/Double Click to select Retailer',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,11,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,NULL,'Press F4/Double Click to select Product Hierarchy Level',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,12,'ProductCategoryValue',11,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,NULL,NULL,'Press F4/Double Click to select Product Hierarchy Level Value',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,13,'Product',12,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,NULL,NULL,'Press F4/Double Click to select Product',0)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,14,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Bill Status...','',1,'',263,1,0,'Press F4/Double Click to select Bill Status',1)
 INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES (211,15,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display Based On*...','',1,'',246,1,1,'Press F4/Double Click to select Display Based on ',1)

--SRF-Nanda-257-004-From Karthick

IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptTopOutLet' AND xtype='P')
DROP PROCEDURE Proc_RptTopOutLet
GO
--EXEC Proc_RptTopOutLet 56,2,0,'CK',0,1,1,1
CREATE PROCEDURE [dbo].[Proc_RptTopOutLet]
/************************************************************
* PROCEDURE	: Proc_RptTopOutLet
* PURPOSE	: To get Top Outlet
* CREATED BY	: Jisha Mathew
* CREATED DATE	: 12/12/2007
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
	@Pi_CurrencyId		INT,
	@Po_Errno		INT OUTPUT
	
)
AS
BEGIN

	SET NOCOUNT ON 
	
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @SSQL		AS 	VarChar(8000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)

	DECLARE @SelNetSales TABLE
	(	
		TotSelNetSales NUMERIC(38,2),
		TotSelBills INT,
		SelPrdCnt INT,
		Usrid INT
	)

	DECLARE @DBNetSales TABLE
	(	
		TotDBNetSales NUMERIC(38,2),
		TotDBBills INT,
		DBPrdCnt INT,
		Rtrid INT,
		Usrid INT
	)

	CREATE TABLE #TopOutlet
	(	
		SMId INT,
		SMName NVARCHAR(100),
		RMId INT,
		RMName NVARCHAR(100),
		RtrId INT,
		RtrCode NVARCHAR(50),
		RtrName NVARCHAR(100),
		CtgName NVARCHAR(100),
		ClassName NVARCHAR(100),
		NetSales NUMERIC(38,4),
		TotBills INT,
		PrdCnt INT,		
		TotSelNetSales NUMERIC(38,2),
		TotSelBills INT,
		SelPrdCnt INT,
		TotDBNetSales NUMERIC(38,2),
		TotDBBills INT,
		DBPrdCnt INT,
		UsrId INT	
	)

	CREATE  TABLE #RPTTOPOUTLET
	(
		SMId INT,
		SMName NVARCHAR(100),
		RMId INT,
		RMName NVARCHAR(100),
		RtrId INT,
		RtrCode NVARCHAR(50),
		RtrName NVARCHAR(100),
		CtgName NVARCHAR(100),
		ClassName NVARCHAR(100),
		NetSales NUMERIC(38,4),
		TotBills INT,
		PrdCnt INT,	
		TotSelNetSales NUMERIC(38,2),
		TotSelBills INT,
		SelPrdCnt INT,
		TotDBNetSales NUMERIC(38,2),
		TotDBBills INT,
		DBPrdCnt INT,
		UsrId INT	
	)

	DECLARE @TEMPRTRID TABLE
	(
		RTRID  INT
	)


	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @PrdCatValId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @CmpId	 	AS	INT
	DECLARE @SMId           AS	INT
	DECLARE @RMId           AS	INT
	DECLARE @Basedon        AS	INT
	DECLARE @RtrId		AS 	INT
	DECLARE @CtgLevelId	AS 	INT
	DECLARE @RtrClassId	AS 	INT
	DECLARE @NoOfOutlets 	AS 	INT
	DECLARE @CtgMainId	AS 	INT	

	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @NoOfOutlets = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,66,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	DELETE FROM #TopOutlet Where Usrid=@Pi_UsrId	
	DELETE FROM @SelNetSales Where Usrid=@Pi_UsrId
	DELETE FROM @DBNetSales Where Usrid=@Pi_UsrId
	DELETE FROM #RPTTOPOUTLET Where Usrid=@Pi_UsrId
	DELETE FROM @TEMPRTRID
	
	INSERT INTO @TEMPRTRID (RTRID)
	SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)
	,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL
	WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
		RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
		RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
	AND (RCL.CmpId = (CASE @CmpId WHEN 0 THEN RCL.CmpId ELSE 0 END) OR
		RCL.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	AND (RVC.CmpId = (CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
		RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		
	SET @TblName = 'RptTopOutLet'

	SET @TblStruct ='SMId INT,
			SMName NVARCHAR(100),
			RMId INT,
			RMName NVARCHAR(100),
			RtrId INT,
			RtrCode NVARCHAR(50),
			RtrName NVARCHAR(100),
			CtgName NVARCHAR(100),
			ClassName NVARCHAR(100),
			NetSales NUMERIC(38,4),
			TotBills INT,
			PrdCnt INT,		
			TotSelNetSales NUMERIC(38,2),
			TotSelBills INT,
			SelPrdCnt INT,
			TotDBNetSales NUMERIC(38,2),
			TotDBBills INT,
			DBPrdCnt INT'		
			
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,CtgName,ClassName,NetSales,
					  TotBills,PrdCnt,TotSelNetSales,TotSelBills,SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt'
			
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
		INSERT INTO #TopOutlet (SMId,SMName,RMID,RMName,Rtrid,RtrCode,RtrName,CtgName,ClassName,Netsales,TotBills,PrdCnt,
		TotSelNetSales,TotSelBills,SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt,UsrId)
		Select Distinct A.SMId,A.SMName,A.RMID,A.RMName,A.Rtrid,A.RtrCode,A.RtrName,CtgName,ValueClassName,SUM(Netsales) as Netsales,SUM(TotBills) AS TotBills,
		SUM(PrdCnt) AS PrdCnt,0 AS TotSelNetSales,0 AS TotSelBills,0 AS SelPrdCnt,
		0 AS TotDBNetSales,0 AS TotDBBills,0 AS DBPrdCnt,@Pi_UsrId as UsrId
		From
		(
			Select Distinct S.SMId,S.SMName,RM.RMID,RM.RMName,R.RtrId,R.RtrCode,R.RtrName,CtgName,ValueClassName,
			Isnull(Sum(SIP.PrdNetAmount),0) as Netsales,isnull(Count(Distinct SI.SalId),0) AS TotBills,
			Isnull(Count(Distinct SIP.Prdid),0) AS PrdCnt
			FROM Salesinvoice SI WITH (NOLOCK)
			INNER JOIN SalesinvoiceProduct  SIP WITH (NOLOCK) on SI.SalId=SIP.SalId
			INNER JOIN PRODUCT P ON SIP.Prdid=P.Prdid
			AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
				P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
				P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
			AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR
				p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN Salesman S WITH (NOLOCK) ON SI.SMid=S.SMid
			AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId Else 0 END) OR
				SI.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			INNER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMid=RM.RMid
			AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId Else 0 END) OR
			    	SI.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			INNER JOIN Retailer R WITH (NOLOCK) ON   SI.Rtrid=R.Rtrid
			INNER JOIN @TEMPRTRID TP ON TP.RTRID= SI.Rtrid AND TP.RTRID=R.Rtrid
			INNER JOIN RetailerValueClassMap RVM WITH (NOLOCK)ON  RVM.rtrid=SI.rtrid AND RVM.rtrid=R.rtrid
									AND RVM.rtrid=TP.rtrid
			INNER JOIN RetailerValueClass RV WITH (NOLOCK) ON RV.RtrClassId = RVM.RtrValueClassId
		    INNER JOIN RetailerCategory RC WITH (NOLOCK) ON RV.CtgMainId = RC.CtgMainId
    		WHERE
				Salinvdate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121) AND   RM.RMSRouteType=1
					AND Dlvsts In(4,5)
			GROUP BY S.SMId,S.SMName,RM.RMID,RM.RMName,R.Rtrid,R.RtrCode,R.RtrName,CtgName,ValueClassName		
			UNION ALL
			Select Distinct S.SMId,S.SMName,RM.RMID,RM.RMName,R.Rtrid,R.RtrCode,R.RtrName,CtgName,ValueClassName,
			-1*Isnull(Sum(PrdNetAmt),0) as Netsales,0 as TotBills,0 AS PrdCnt
			FROM ReturnHeader RH WITH (NOLOCK)
			INNER JOIN ReturnProduct  RHP WITH (NOLOCK) on RH.ReturnId=RHP.ReturnId
			INNER JOIN PRODUCT P ON RHP.PrdId=P.PrdId
			AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
				P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
				P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
			AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR
				p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN Salesman S WITH (NOLOCK) ON RH.SMId=S.SMId
			AND (RH.SMId = (CASE @SMId WHEN 0 THEN RH.SMId Else 0 END) OR
				RH.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			INNER JOIN RouteMaster RM WITH (NOLOCK) ON RH.RMid=RM.RMid
			AND (RH.RMId = (CASE @RMId WHEN 0 THEN RH.RMId Else 0 END) OR
			    	RH.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			INNER JOIN Retailer R WITH (NOLOCK) ON RH.RtrId=R.RtrId
			INNER JOIN @TEMPRTRID TP ON TP.RTRID= RH.Rtrid AND TP.RTRID=R.RtrId
			INNER JOIN RetailerValueClassMap RVM WITH (NOLOCK)ON  RVM.rtrid=RH.rtrid AND RVM.rtrid=R.rtrid
									AND RVM.rtrid=TP.rtrid
			INNER JOIN RetailerValueClass RV WITH (NOLOCK) ON RV.RtrClassId = RVM.RtrValueClassId
		    INNER JOIN RetailerCategory RC WITH (NOLOCK) ON RV.CtgMainId = RC.CtgMainId
			WHERE
				ReturnDate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121) AND   RM.RMSRouteType=1
			GROUP BY S.SMId,S.SMName,RM.RMID,RM.RMName,R.Rtrid,R.RtrCode,R.RtrName,CtgName,ValueClassName
		)A GROUP BY A.SMId,A.SMName,A.RMID,A.RMName,A.Rtrid,A.RtrCode,A.RtrName,CtgName,ValueClassName
		
		INSERT INTO @SelNetSales(TotSelNetSales,TotSelBills,SelPrdCnt,UsrId)
		SELECT SUM(Netsales) as TotSelNetSales,SUM(Totalbillcuts)  as TotSelBills ,SUM(TotalPrdCount) as SelPrdCnt,
		@Pi_UsrId  as Usrid From(
		SELECT SUM(SI.SalNetAmt) as Netsales,COUNT(Distinct si.salinvno) as Totalbillcuts,COUNT(Distinct SIP.PrdId) AS TotalPrdCount
		From Salesinvoice SI
		INNER JOIN SalesinvoiceProduct SIP ON SI.SalId = SIP.SalId
		INNER JOIN PRODUCT P ON SIP.Prdid=P.Prdid
		AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
		AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR
			p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE
			SI.Salinvdate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
			AND SI.Dlvsts In(4,5)
		Union all
		SELECT	-1 * SUM(PrdNetAmt) as Netsales,0 as TotalBillCut,0 as TotalPrdCount	
		From ReturnHeader RH
		INNER JOIN ReturnProduct RHP ON RH.ReturnId = RHP.ReturnId
		INNER JOIN PRODUCT P ON RHP.PrdId=P.PrdId
		AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
		AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR
			p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE ReturnDate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
		)y
		UPDATE #TopOutlet SET TotSelNetSales = A.TotSelNetSales,
					TotSelBills = A.TotSelBills,
					SelPrdCnt = A.SelPrdCnt
		From  @SelNetSales A,#TopOutlet B Where B.UsrId = @Pi_UsrId
		SET @SSQL='Insert INTO #RPTTOPOUTLET SELECT Distinct Top '+Cast(@NoOfOutlets as Varchar(5))+' SMId,SMName,RT.RMID,'+
			    'RMName,RT.RtrId,RT.RtrCode,RT.RtrName,CtgName,ClassName,Netsales,TotBills,PrdCnt,TotSelNetSales,TotSelBills, '+
			    ' SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt,UsrId From #TopOutlet Rt,Retailer R where '+
			    ' UsrId='+ Cast(@Pi_UsrId as Varchar(15))+' And RT.RtrId=R.RtrId Order by Netsales Desc '
		EXEC (@SSQL)
		INSERT INTO @DBNetSales(TotDBNetSales,TotDBBills,DBPrdCnt,UsrId)
		SELECT SUM(Netsales) as TotDBNetSales,SUM(Totalbillcuts)  as TotDBBills ,SUM(TotalPrdCount) as DBPrdCnt,
		@Pi_UsrId  as Usrid From(
		SELECT SUM(SI.SalNetAmt) as Netsales,COUNT(Distinct si.salinvno) as Totalbillcuts,COUNT(Distinct SIP.PrdId) AS TotalPrdCount
		From Salesinvoice SI
		INNER JOIN SalesinvoiceProduct SIP ON SI.SalId = SIP.SalId
		WHERE
			SI.Salinvdate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
			AND SI.Dlvsts In(4,5)
		Union all
		SELECT	-1 * SUM(PrdNetAmt) as Netsales,0 as TotalBillCut,0 as TotalPrdCount	
		From ReturnHeader RH,ReturnProduct RHP
		WHERE ReturnDate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
		and RH.ReturnId = RHP.ReturnId )x
		
		Update #RPTTOPOUTLET SET TotDBNetSales= A.TotDBNetSales,
					TotDBBills=A.TotDBBills,
					DBPrdCnt = A.DBPrdCnt
		From @DBNetSales A, #RPTTOPOUTLET B WHERE B.Usrid=@Pi_UsrId
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RPTTOPOUTLET' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				
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
					'(SnapId,RptId,' + @TblFields + ',UserId)' +
					' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
					--' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RPTTOPOUTLET'
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
			SET @SSQL = 'INSERT INTO #RPTTOPOUTLET ' +
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

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RPTTOPOUTLET

	SELECT * FROM #RPTTOPOUTLET
 
IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
 BEGIN  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptTopOutLet_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE RptTopOutLet_Excel  
  SELECT * INTO RptTopOutLet_Excel FROM #RPTTOPOUTLET   
 END   

RETURN
END
GO

--SRF-Nanda-257-005-From Panneer

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[TempGRNListing]') AND type in (N'U'))
DROP TABLE [TempGRNListing]
GO
CREATE TABLE [TempGRNListing](
	[PurRcptId] [bigint] NULL,
	[PurRcptRefNo] [nvarchar](50)  NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [nvarchar](100)  NULL,
	[PrdName] [nvarchar](200)  NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](100)  NULL,
	[CmpInvNo] [nvarchar](100)  NULL,
	[CmpInvDate] [datetime] NULL,
	[InvBaseQty] [int] NULL,
	[RcvdGoodBaseQty] [int] NULL,
	[UnSalBaseQty] [int] NULL,
	[ShrtBaseQty] [int] NULL,
	[ExsBaseQty] [int] NULL,
	[RefuseSale] [tinyint] NULL,
	[PrdUnitLSP] [numeric](38, 6) NULL,
	[PrdGrossAmount] [numeric](38, 6) NULL,
	[Slno] [int] NULL,
	[RefCode] [nvarchar](25)  NULL,
	[FieldDesc] [nvarchar](100)  NULL,
	[LineBaseQtyAmount] [numeric](38, 6) NULL,
	[PrdNetAmount] [numeric](38, 6) NULL,
	[Status] [tinyint] NULL,
	[InvDate] [datetime] NULL,
	[LessScheme] [numeric](38, 6) NULL,
	[OtherCharges] [numeric](38, 6) NULL,
	[TotalAddition] [numeric](38, 6) NULL,
	[TotalDeduction] [numeric](38, 6) NULL,
	[GrossAmount] [numeric](38, 6) NULL,
	[NetPayable] [numeric](38, 6) NULL,
	[DifferenceAmount] [numeric](38, 6) NULL,
	[PaidAmount] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[SpmId] [int] NULL,
	[SpmName] [nvarchar](100)  NULL,
	[LcnId] [int] NULL,
	[LcnName] [nvarchar](100)  NULL,
	[TransporterId] [int] NULL,
	[TransporterName] [nvarchar](100)  NULL,
	[CmpId] [int] NULL,
	[CmpName] [nvarchar](100)  NULL,
	[PrdSlNo] [int] NULL,
	[SBreakupType] [tinyint] NULL,
	[SStockTypeId] [int] NULL,
	[SUserStockType] [nvarchar](100)  NULL,
	[SUomId] [int] NULL,
	[SUomCode] [nvarchar](20)  NULL,
	[SQuantity] [int] NULL,
	[SBaseQty] [numeric](38, 0) NULL,
	[EBreakupType] [tinyint] NULL,
	[EStockTypeId] [int] NULL,
	[EUserStockType] [nvarchar](50)  NULL,
	[EUomId] [int] NULL,
	[EUomCode] [nvarchar](20)  NULL,
	[EQuantity] [int] NULL,
	[EBaseQty] [numeric](38, 0) NULL,
	[CSRefId] [int] NULL,
	[CSRefCode] [nvarchar](20)  NULL,
	[CSRefName] [nvarchar](50)  NULL,
	[CSPrdId] [int] NULL,
	[CSPrdDCode] [nvarchar](20)  NULL,
	[CSPrdName] [nvarchar](100)  NULL,
	[CSPrdBatId] [int] NULL,
	[CSPrdBatCode] [nvarchar](50)  NULL,
	[CSQuantity] [numeric](38, 0) NULL,
	[RateForClaim] [numeric](38, 6) NULL,
	[CSStockTypeId] [int] NULL,
	[CSUserStockType] [nvarchar](50)  NULL,
	[CSLcnId] [int] NULL,
	[CsLcnName] [nvarchar](50)  NULL,
	[CSValue] [numeric](38, 6) NULL,
	[CSAmount] [numeric](38, 6) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptDistInfoMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptDistInfoMaster]
GO
---  exec  Proc_RptDistInfoMaster  66,3,0,'jj',0,0,1,0
CREATE PROCEDURE [Proc_RptDistInfoMaster]
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
* PROCEDURE  : Proc_RptDistInfoMaster
* PURPOSE    : To Generate  Distributor Info Master Report 
* CREATED BY : RathiDevi.P
* CREATED ON : 12/02/2008  
* MODIFICATION 
*************************************************   
* DATE          AUTHOR      DESCRIPTION    
* 26.08.2011    Panneer     bug no : 23620
*************************************************/       
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
--Filter Variable
DECLARE @DistributorId		        AS	Int
--Till Here
--Assgin Value for the Filter Variable
SET @DistributorId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,84,@Pi_UsrId))
SET @DistributorId = 1
--Till Here

Create TABLE #RptDistInfoMaster	
(
		DistributorId 		 INT,
		DistributorCode		 NVARCHAR(50),
		DistributorName 	 NVARCHAR(50),
		Address1			 NVARCHAR(50),
		Address2			 NVARCHAR(50),
		Address3			 NVARCHAR(50),
		Pincode				 NVARCHAR(50),
		PhoneNo				 NVARCHAR(50),
		ContactPerson		 NVARCHAR(50),
		EmailId				 NVARCHAR(50),
		DrugLicNo1			 NVARCHAR(50),
		DrugLicNo2			 NVARCHAR(50),
		PestLicNo			 NVARCHAR(50),
		GeographyLevel		 NVARCHAR(50),
		GeographyLevelValue  NVARCHAR(50),
		TaxType				 NVARCHAR(50),
		TinNo				 NVARCHAR(50),
		DefaultCompany		 NVARCHAR(50),
		DepositAmt			 NUMERIC(38,2),
		CSTNo				 NVARCHAR(50),
		LSTNo				 NVARCHAR(50),
		LicNo				 NVARCHAR(50),
		Drug1ExpiryDate		 DATETIME,
		Drug2ExpiryDate		 DATETIME,
		PestExpiryDate		 DATETIME,
		DayOff				 NVARCHAR(50)
		
)
SET @TblName = 'RptDistInfoMaster'
SET @TblStruct ='DistributorId 		 INT,
				DistributorCode		 NVARCHAR(50),
				DistributorName 	 NVARCHAR(50),
				Address1			 NVARCHAR(50),
				Address2			 NVARCHAR(50),
				Address3			 NVARCHAR(50),
				Pincode				 INT,
				PhoneNo				 NVARCHAR(50),
				ContactPerson		 NVARCHAR(50),
				EmailId				 NVARCHAR(50),
				DrugLicNo1			 NVARCHAR(50),
				DrugLicNo2			 NVARCHAR(50),
				PestLicNo			 NVARCHAR(50),
				GeographyLevel		 NVARCHAR(50),
				GeographyLevelValue  NVARCHAR(50),
				TaxType				 NVARCHAR(50),
				TinNo				 NVARCHAR(50),
				DefaultCompany		 NVARCHAR(50),
				DepositAmt			 NUMERIC(38,2),
				CSTNo				 NVARCHAR(50),
				LSTNo				 NVARCHAR(50),
				LicNo				 NVARCHAR(50),
				Drug1ExpiryDate		 DATETIME,
				Drug2ExpiryDate		 DATETIME,
				PestExpiryDate		 DATETIME,
				DayOff				 NVARCHAR(50)'
SET @TblFields = 'DistributorId,DistributorCode,DistributorName,Address1,Address2,Address3,Pincode,
				 PhoneNo,ContactPerson,EmailId,DrugLicNo1,DrugLicNo2,PestLicNo,GeographyLevel,GeographyLevelValue,TaxType,TinNo,
				DefaultCompany,DepositAmt,CSTNo,LSTNo,LicNo,Drug1ExpiryDate,Drug2ExpiryDate,PestExpiryDate,DayOff'
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

	INSERT INTO #RptDistInfoMaster (DistributorId,DistributorCode,DistributorName,Address1,Address2,Address3,Pincode,PhoneNo,ContactPerson,EmailId,DrugLicNo1,DrugLicNo2,PestLicNo,GeographyLevel,GeographyLevelValue,TaxType,TinNo,DefaultCompany,DepositAmt,CSTNo,LSTNo,LicNo,Drug1ExpiryDate,Drug2ExpiryDate,PestExpiryDate,DayOff)
	SELECT DISTINCT
			  A.DistributorId,A.DistributorCode,A.DistributorName,
			 ISNULL(A.DistributorAdd1,'') as DistributorAdd1 ,ISNULL(A.DistributorAdd2,'') as DistributorAdd2,
			 ISNULL(A.DistributorAdd3,'') as DistributorAdd3,ISNULL(A.PinCode,'') as PinCode,
			 ISNULL(A.PhoneNo,'') as PhoneNo,ISNULL(A.ContactPerson,'') as ContactPerson ,ISNULL(A.EmailID,'') as EMailId,
			 ISNULL(A.DrugLicNo1,'') as DrugLicNo1 ,ISNULL(A.DrugLicNo2,'') as DrugLicNo2,ISNULL(A.PestLicNo,'') as PestLicNo,
			 ISNULL(D.GeoLevelName,'') as GeoLevel,ISNULL(C.GeoName,'') as GeoLevelValue ,
			 (CASE A.TaxType When 1 then 'VAT' when 0 then 'NON VAT' END )as TaxType,
			 ISNULL(A.TINNo,'') as TINNo,
			 ISNULL(E.CmpName,'') as DefaultCompany,
			 ISNULL(A.DepositAmt,0) as DepositAmt , ISNULL(A.CSTNo,'') as CSTNo,ISNULL(A.LSTNo,'') as LSTNo ,ISNULL(A.LicNo,'') as LicNo ,
			 Convert(varchar(10),A.Drug1ExpiryDate,111) as Drug1ExpiryDate,convert(varchar(10),A.Drug2ExpiryDate,111) as Drug2ExpiryDate , 
			Convert(varchar(10),A.PestExpiryDate,111) as PestExpiryDate ,
			Case A.DayOff 
				when 0 then 'Sunday'
				when 1 then 'Monday'
				when 2 then 'Tuesday'
				when 3 then 'Wednesday'
				when 4 then 'Thursday'
				when 5 then 'Friday'
				when 6 then 'Saturday'
				end as DayOff
	From
		DISTRIBUTOR A Left Outer Join Geography C On  	A.GeoMainId = C.GeoMainId 
		LEFT OUTER JOIN GeographyLevel D on 	C.GeoLevelId=D.GeoLevelId,Company E
	WHERE 
		E.DefaultCompany=1


   	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptDistInfoMaster ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			 +' WHERE (DistributorId=  (CASE @DistributorId WHEN 0 THEN DistributorId ELSE 0 END ) OR
				DistributorId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,84,@Pi_UsrId)))'
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptDistInfoMaster'
		EXEC (@SSQL)
		PRINT 'Saved Data Into SnapShot Table'
	    END
END
ELSE				--To Retrieve Data From Snap Data
BEGIN
PRINT @Pi_DbName
	EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
			@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
	PRINT @ErrNo
	IF @ErrNo = 0
	   BEGIN
		SET @SSQL = 'INSERT INTO #RptDistInfoMaster ' +
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
		SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	   END
END
DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptDistInfoMaster
PRINT 'Data Executed'
SELECT * FROM #RptDistInfoMaster
RETURN
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TrigStockManagementProduct_Track]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[TrigStockManagementProduct_Track]
GO
CREATE TRIGGER [dbo].[TrigStockManagementProduct_Track]
ON [dbo].[StockManagementProduct]
AFTER INSERT
AS
BEGIN
--StockAction 1 Add,2 Reduce
INSERT INTO Unsaleable_In (TransId,RefId,TransCode,TransDate,Prdid,Prdbatid,StockTypeId,LcnId,InQty,StockAction,TolcnId,ToStockTypeId)
Select 3 AS TransId,0 AS RefId,StockManagement.StkMngRefNo AS TransCode,StkMngDate AS TransDate,PrdId,PrdBatId,INSERTED.StockTypeId,StockManagement.LcnId,TotalQty,1,StockManagement.LcnId,INSERTED.StockTypeId From StockManagement With (NoLock) Inner Join
INSERTED On StockManagement.StkMngRefNo=INSERTED.StkMngRefNo
INNER JOIN StockType ST With (NoLock) ON ST.StockTypeId=INSERTED.StockTypeId
WHERE ST.SystemStockType=2 AND StockManagement.Status=1 AND StockManagement.StkMgmtTypeId=1
END
GO 
DELETE  FROM CustomCaptions WHERE TransId=9 AND CtrlId=31
INSERT INTO CustomCaptions VALUES (9,31,1,'DgCommon-9-31-1','Bill No','','',1,1,1,'2008-03-19',1,'2008-03-19','Bill No','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,2,'DgCommon-9-31-2','Doc.Ref.No','','',1,1,1,'2008-03-19',1,'2008-03-19','Doc.Ref.No','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,3,'DgCommon-9-31-3','Remarks','','',1,1,1,'2008-03-19',1,'2008-03-19','Remarks','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,4,'DgCommon-9-31-4','Date','','',1,1,1,'2008-03-19',1,'2008-03-19','Date','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,6,'DgCommon-9-31-6','Retailer','','',1,1,1,'2008-03-19',1,'2008-03-19','Retailer','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,7,'DgCommon-9-31-7','Bill Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Bill Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,8,'DgCommon-9-31-8','Paid Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Paid Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,9,'DgCommon-9-31-9','Pending Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Pending Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,10,'DgCommon-9-31-10','Cash Disc','','',1,1,1,'2008-03-19',1,'2008-03-19','Cash Disc','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,11,'DgCommon-9-31-11','Cash','','',1,1,1,'2008-03-19',1,'2008-03-19','Cash','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,12,'DgCommon-9-31-12','Chq / DD','','',1,1,1,'2008-03-19',1,'2008-03-19','Chq / DD','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,13,'DgCommon-9-31-13','Credit','','',1,1,1,'2008-03-19',1,'2008-03-19','Credit','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,14,'DgCommon-9-31-14','Debit','','',1,1,1,'2008-03-19',1,'2008-03-19','Debit','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,15,'DgCommon-9-31-15','On Acc','','',1,1,1,'2008-03-19',1,'2008-03-19','On Acc','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,16,'DgCommon-9-31-16','AR Days','','',1,1,1,'2008-03-19',1,'2008-03-19','AR Days','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,17,'DgCommon-9-31-17','Collection Amount','','',1,1,1,'2008-03-19',1,'2008-03-19','Collection Amount','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,18,'DgCommon-9-31-18','Adjustment Amount','','',1,1,1,'2008-03-19',1,'2008-03-19','Adjustment Amount','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,25,'DgCommon-9-31-25','Debit No','','',1,1,1,'2008-03-19',1,'2008-03-19','Debit No','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,26,'DgCommon-9-31-26','Debit Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Debit Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,27,'DgCommon-9-31-27','Adj Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Adj Amt','','',1,1)
GO
DELETE from Configuration Where UPPER(ModuleName) = 'PURCHASE RECEIPT' and ModuleId  = 'PURCHASERECEIPT26'
INSERT INTO Configuration VALUES ('PURCHASERECEIPT26','Purchase Receipt','Display MRP column in Purchase Receipt Screen',1,0,0.00,26)
GO
DELETE FROM HotSearchEditorHd WHERE formid=541 and ControlName='OrderBill'
INSERT INTO  HotSearchEditorHd
SELECT 541,'Billing','OrderBill','select','SELECT OrderNo,OrderDate,RtrName,RtrId,RMId,RMName,SMId,SMName,
SMMktCredit,  SMCreditDays,SMCreditAmountAlert,SMCreditDaysAlert,  RtrShipId,RtrShipAdd1,RtrShipAdd2,
RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo  FROM (SELECT A.OrderNo,A.OrderDate,B.RtrName,A.RtrId,
A.RMId,C.RMName,A.SMId,D.SMName, SMMktCredit,SMCreditDays,SMCreditAmountAlert,  
SMCreditDaysAlert,A.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,RS.RtrShipPinNo,RS.RtrShipPhoneNo  
FROM OrderBooking A   INNER JOIN Retailer B ON A.RtrId = B.Rtrid    
INNER JOIN RouteMaster C ON A.RMId = C.RMId    
INNER JOIN Salesman D ON A.SMId = D.SMId    
INNER JOIN RetailerShipAdd RS ON RS.RtrShipId = A.RtrShipId    
WHERE A.Status =0    AND A.OrderNo IN (SELECT DISTINCT OrderNo FROM OrderBookingProducts)) A'
GO
IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='SchQPSConvDetails')
BEGIN
	CREATE TABLE [SchQPSConvDetails](
		[SchId] [int] NULL,
		[CmpSchCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ConvDate] [datetime] NULL
	) ON [PRIMARY]
END 
GO

if not exists (select * from hotfixlog where fixid = 383)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(383,'D','2011-08-26',getdate(),1,'Core Stocky Service Pack 383')
GO
