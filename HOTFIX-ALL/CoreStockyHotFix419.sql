--[Stocky HotFix Version]=419
DELETE FROM Versioncontrol WHERE Hotfixid='419'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('419','3.1.0.0','D','2014-10-09','2014-10-09','2014-10-09',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
--ADDED BY VETRI
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Tbl_PDAConfiguration_PDA' AND XTYPE ='U')
DROP TABLE Tbl_PDAConfiguration_PDA
GO
CREATE TABLE Tbl_PDAConfiguration_PDA
(
	[CId] [int] NOT NULL,
	[CName] [nvarchar](50)  NULL,
	[CValue] [nvarchar](200) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ExportValues_PDA' AND XTYPE ='P')
DROP PROC Proc_ExportValues_PDA
GO
CREATE PROC Proc_ExportValues_PDA
(
	@TypeId INT,
	@PId INT = 0
)
AS
/*
Proc_ExportValues 1
SELECT * FROM Tbl_PDAConfiguration_PDA
*/
BEGIN
	IF (@TypeId  = 1) --SALESMAN
	BEGIN
		SELECT SMId,SMName FROM SalesMan order by SMId
		SELECT SMCode,SMName FROM SalesMan order by SMId

		SELECT CValue FROM Tbl_PDAConfiguration_PDA WHERE CName='LastExportDate'
		SELECT CValue FROM Tbl_PDAConfiguration_PDA WHERE CName='LastImportDate'
		SELECT CValue FROM Tbl_PDAConfiguration_PDA WHERE CName='LastModifiedDate'

	END
	ELSE IF (@TypeId = 38)
	BEGIN
		UPDATE Tbl_PDAConfiguration_PDA SET CValue = GETDATE() WHERE CName='LastExportDate'
	END
	ELSE IF (@TypeId = 39)
	BEGIN
		UPDATE Tbl_PDAConfiguration_PDA SET CValue = GETDATE() WHERE CName='LastImportDate'
	END
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Sales_upload' AND XTYPE ='U')
DROP TABLE Sales_upload
GO
CREATE TABLE Sales_upload
(
	[SMID] [int] NULL,
	[RMID] [int] NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='SSM_UPLOAD' AND XTYPE ='U')
DROP TABLE SSM_UPLOAD
GO
CREATE TABLE SSM_UPLOAD
(
	[SMID] [int] NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Tbl_DownloadProcess_ExportPDA' AND XTYPE ='U')
DROP TABLE Tbl_DownloadProcess_ExportPDA
GO
CREATE TABLE Tbl_DownloadProcess_ExportPDA
(
	[SequenceNo] [int] NULL,
	[ProcessName] [varchar](100)  NULL,
	[PrkTableName] [varchar](100)  NULL,
	[SPName] [varchar](100)  NULL,
	[TRowCount] [int] NULL,
	[SelectCount] [int] NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='TBL_Downloadprocess_ImportPDA' AND XTYPE ='U')
DROP TABLE TBL_Downloadprocess_ImportPDA
GO
CREATE TABLE TBL_Downloadprocess_ImportPDA
(
	[SequenceNo] [int] NULL,
	[ProcessName] [varchar](100)  NULL,
	[PrkTableName] [varchar](100)  NULL,
	[SPName] [varchar](100) NULL,
	[TRowCount] [int] NULL,
	[SelectCount] [int] NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_PDA_SalesmanDetails' AND XTYPE ='P')
DROP PROC Proc_Export_PDA_SalesmanDetails
GO
CREATE PROC Proc_Export_PDA_SalesmanDetails
(
 @PID INT,
 @SSMCODE varchar(10) = null,
 @RMID varchar(10) = null
)
/*
SELECT * FROM SALES_UPLOAD
*/
AS
BEGIN
 IF @PID = 2
  BEGIN
	INSERT INTO SALES_UPLOAD SELECT @SSMCODE,@RMID
  END
 IF @PID = 1
  BEGIN
	DELETE FROM SALES_UPLOAD
  END
 IF @PID = 3
  BEGIN
	SELECT * FROM Tbl_DownloadProcess_ExportPDA ORDER BY SEQUENCENO
  END
IF @PID = 4
  BEGIN
	DELETE FROM SSM_UPLOAD WHERE SMID = 0
	SELECT R.Rmid AS RMID,Rmname from routemaster R 
	INNER JOIN SalesmanMarket SM on SM.Rmid=R.Rmid 
	INNER JOIN Salesman S on S.smid=SM.smid
	WHERE Rmstatus=1 AND S.smid IN (SELECT SMID FROM SSM_UPLOAD) AND (RMmon =1 OR RMTue =1 OR RMWed =1 OR RMThu =1 OR RMFri =1 OR
	RMSat =1 OR RMSun =1)  
END
 IF @PID = 5
  BEGIN
	SELECT * FROM Tbl_DownloadProcess_ImportPDA ORDER BY SEQUENCENO
  END

 IF @PID = 6
  BEGIN
	INSERT INTO SSM_UPLOAD SELECT @SSMCODE
  END
 IF @PID = 7
  BEGIN
	DELETE FROM SSM_UPLOAD
  END
 IF @PID = 8
  BEGIN
	SELECT count(*) FROM Tbl_DownloadProcess_ImportPDA 
  END
 IF @PID = 9
  BEGIN
	SELECT count(*) FROM Tbl_DownloadProcess_ExportPDA 
  END

END
GO
DELETE FROM Tbl_DownloadProcess_ExportPDA
DELETE FROM TBL_Downloadprocess_ImportPDA
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 1,'SalesRepresentative','Cos2Mob_SalesRepresentative','PROC_ExportPDA_SalesRepresentative',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 2,'Market','Cos2Mob_Market','PROC_ExportPDA_Market',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 3,'Retailer','Cos2Mob_Retailer','PROC_ExportPDA_Retailer',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 4,'ProductCategory','Cos2Mob_ProductCategory','PROC_ExportPDA_ProductCategory',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 5,'ProductCategoryValue','Cos2Mob_ProductCategoryValue','PROC_ExportPDA_ProductCategoryValue',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 6,'Product','Cos2Mob_Product','PROC_ExportPDA_Product',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 7,'Productbatch','Cos2Mob_Productbatch','PROC_ExportPDA_Productbatch',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 8,'Bank','Cos2Mob_Bank','PROC_ExportPDA_Bank',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 9,'BankBranch','Cos2Mob_BankBranch','PROC_ExportPDA_BankBranch',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 10,'PendingBills','Cos2Mob_PendingBills','PROC_ExportPDA_PendingBills',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 11,'CreditNote','Cos2Mob_CreditNote','PROC_ExportPDA_CreditNote',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 12,'DebitNote','Cos2Mob_DebitNote','PROC_ExportPDA_DebitNote',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 13,'RetailerCategoryLevel','Cos2Mob_RetailerCategoryLevel','PROC_ExportPDA_RetailerCategoryLevel',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 14,'RetailerCategory','Cos2Mob_RetailerCategory','PROC_ExportPDA_RetailerCategory',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 15,'RetailerValueClass','Cos2Mob_RetailerValueClass','PROC_ExportPDA_RetailerValueClass',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 16,'SchemeNarration','Cos2Mob_SchemeNarration','Proc_ExportPDA_SchemeNarration',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 17,'SchemeProductDetails','Cos2Mob_SchemeProductDetails','PROC_ExportPDA_SchemeProductDetails',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 18,'ReasonMaster','Cos2Mob_ReasonMaster','PROC_ExportPDA_ReasonMaster',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 19,'SalesmanDashBoard','Cos2Mob_SalesmanDashBoard','Proc_ExportPDA_SalesmanDashBoard',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 20,'RetailerDashBoard','Cos2Mob_RetailerDashBoard','Proc_ExportPDA_RetailerDashBoard',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 21,'OrderBookingDashBoard','Cos2Mob_OrderBookingDashBoard','Proc_ExportPDA_OrderBookingDashBoard',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 22,'OrderProductDashBoard','Cos2Mob_OrderProductDashBoard','Proc_ExportPDA_OrderProductDashBoard',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 23,'RetailerProductDashBoard','Cos2Mob_RetailerProductDashBoard','Proc_ExportPDA_RetailerProductDashBoard',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 24,'MarketIntelligencehd','Cos2Mob_MarketIntelligenceHD','Proc_Export_PDA_MarketIntelligencehd',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 25,'MarketIntelligencedt','Cos2Mob_MarketIntelligenceDT','Proc_Export_PDA_MarketIntelligencedt',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 26,'SFA_RetailerCategory','SFA_RetailerCategory','Proc_SFA_RetailerCategory',0,500
INSERT INTO Tbl_DownloadProcess_ExportPDA SELECT 27,'UomMaster','Cos2Mob_UomMaster','Proc_Export_PDA_UomMaster',0,500
INSERT INTO TBL_Downloadprocess_ImportPDA SELECT 1,'OrderBooking','Mob2Cos_OrderBooking','',0,500
INSERT INTO TBL_Downloadprocess_ImportPDA SELECT 2,'OrderBookingProduct','Mob2Cos_OrderBookingProduct','',0,500
INSERT INTO TBL_Downloadprocess_ImportPDA SELECT 3,'SalesReturn','Mob2Cos_SalesReturn','',0,500
INSERT INTO TBL_Downloadprocess_ImportPDA SELECT 4,'SalesReturnProduct','Mob2Cos_SalesReturnProduct','',0,500
INSERT INTO TBL_Downloadprocess_ImportPDA SELECT 5,'Receiptinvoice','Mob2Cos_Receiptinvoice','',0,500
INSERT INTO TBL_Downloadprocess_ImportPDA SELECT 6,'Import_CreditNote','Mob2Cos_CreditNote','',0,500
INSERT INTO TBL_Downloadprocess_ImportPDA SELECT 7,'Import_DebitNote','Mob2Cos_DebitNote','',0,500
INSERT INTO TBL_Downloadprocess_ImportPDA SELECT 8,'NewRetailer','Mob2Cos_NewRetailer','',0,500
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='Proc_PDAGetSalesMan' AND XTYPE='P')
DROP PROCEDURE Proc_PDAGetSalesMan
GO
CREATE PROCEDURE Proc_PDAGetSalesMan
(  	
 @PID INT,	
 @SMCode VARCHAR(50)= NULL,	
 @RMID INT = 0	
)  	
/*  	
Proc_PDAGetSalesMan 1  	
SELECT * FROM SSM_UPLOAD	
*/  	
AS  	
BEGIN  	
	
 IF @PID = 1  	
  BEGIN  	
	SELECT SMNAME AS SALESMAN,SMCODE AS SALESMANCODE FROM SALESMAN ORDER BY SMNAME  
  END  	
  	
 IF @PID = 2	
  BEGIN	
   DELETE FROM SSM_UPLOAD	
  END	
  	
  IF @PID = 3	
  BEGIN	
   DELETE FROM SSM_UPLOAD	
   INSERT INTO SSM_UPLOAD SELECT DISTINCT SMId FROM Salesman WHERE SMCode = @SMCode	
  END	
  	
  IF @PID = 4	
  BEGIN	
   SELECT DISTINCT SMName FROM Salesman WHERE SMId IN (SELECT SMId FROM SSM_UPLOAD)	
  END	
  	
  IF @PID = 5	
  BEGIN	
	SELECT R.Rmid AS RMID,Rmname from routemaster R 
	INNER JOIN SalesmanMarket SM on SM.Rmid=R.Rmid 
	INNER JOIN Salesman S on S.smid=SM.smid
	WHERE Rmstatus=1 AND S.smid IN (SELECT SMID FROM SSM_UPLOAD) AND (RMmon =1 OR RMTue =1 OR RMWed =1 OR RMThu =1 OR RMFri =1 OR
	RMSat =1 OR RMSun =1) 
  END	
  	
  IF @PID = 6	
  BEGIN	
	SELECT count(*) FROM Tbl_DownloadProcess_ExportPDA 
  END	
  	
  IF @PID = 7	
  BEGIN	
	SELECT DISTINCT SMCode FROM Salesman WHERE SMId IN (SELECT SMId FROM SSM_UPLOAD)
  END	
  	
   IF @PID = 8	
  BEGIN	
    DELETE FROM SALES_UPLOAD	
	SELECT SMId FROM SSM_UPLOAD
  END	
  	
 IF @PID = 9	
  BEGIN	
	INSERT INTO SALES_UPLOAD SELECT @SMCode,@RMID
  END	
  	
 IF @PID = 10	
  BEGIN	
	SELECT * FROM Tbl_DownloadProcess_ExportPDA ORDER BY SEQUENCENO
  END	
  	
   IF @PID = 11	
  BEGIN	
	SELECT COUNT(*) FROM Tbl_DownloadProcess_ImportPDA 
  END	
  	
   IF @PID = 12	
  BEGIN	
	SELECT * FROM Tbl_DownloadProcess_ImportPDA ORDER BY SEQUENCENO
  END	
END	
GO
----------ADDED BY KARTHICK
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE ID IN (SELECT ID FROM SYSOBJECTS WHERE NAME ='ReasonMaster' AND XTYPE='U') AND NAME='NonBilled')
ALTER TABLE ReasonMaster ADD NonBilled int DEFAULT 1 WITH VALUES
GO
DELETE FROM ReasonMaster WHERE Description='Did not visit'
INSERT INTO ReasonMaster
SELECT MAX(REASONID)+1,'R'+CAST(MAX(ReasonId)+1 AS NVARCHAR(2)),'Did not visit',0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM ReasonMaster
UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
GO
IF NOT EXISTS(SELECT * FROM ReasonMaster WHERE Description='Shop Closed')
BEGIN
INSERT INTO ReasonMaster
SELECT MAX(REASONID)+1,'R'+CAST(MAX(ReasonId)+1 AS NVARCHAR(2)),'Shop Closed',0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM ReasonMaster
UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
END
GO
IF NOT EXISTS(SELECT *  FROM ReasonMaster WHERE Description='Owner Unavailable')
BEGIN
INSERT INTO ReasonMaster
SELECT MAX(REASONID)+1,'R'+CAST(MAX(ReasonId)+1 AS NVARCHAR(2)),'Owner Unavailable',0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM ReasonMaster
UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
END
GO
IF NOT EXISTS(SELECT * FROM ReasonMaster WHERE Description='Did not visit')
BEGIN
INSERT INTO ReasonMaster
SELECT MAX(REASONID)+1,'R'+CAST(MAX(ReasonId)+1 AS NVARCHAR(2)),'Did not visit',0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM ReasonMaster
UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
END
GO
IF NOT EXISTS(SELECT *  FROM ReasonMaster WHERE Description='Credit Limit Exceeded')
BEGIN
INSERT INTO ReasonMaster
SELECT MAX(REASONID)+1,'R'+CAST(MAX(ReasonId)+1 AS NVARCHAR(2)),'Credit Limit Exceeded',0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM ReasonMaster
UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
END
GO
IF NOT EXISTS(SELECT *  FROM ReasonMaster WHERE Description='Has enough stock')
BEGIN
INSERT INTO ReasonMaster
SELECT MAX(REASONID)+1,'R'+CAST(MAX(ReasonId)+1 AS NVARCHAR(2)),'Has enough stock',0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM ReasonMaster
UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
END
GO
IF NOT EXISTS(SELECT * FROM ReasonMaster WHERE Description='Prefers Competitor Product:Price,Customer pref')
BEGIN
INSERT INTO ReasonMaster
SELECT MAX(REASONID)+1,'R'+CAST(MAX(ReasonId)+1 AS NVARCHAR(2)),'Prefers Competitor Product:Price,Customer pref',0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM ReasonMaster
UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
END
GO
IF NOT EXISTS(SELECT * FROM ReasonMaster WHERE Description='Required product NA (Distributor Stock)')
BEGIN
INSERT INTO ReasonMaster
SELECT MAX(REASONID)+1,'R'+CAST(MAX(ReasonId)+1 AS NVARCHAR(2)),'Required product NA (Distributor Stock)',0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM ReasonMaster
UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
END
GO
UPDATE Configuration SET STATUS=0 WHERE ModuleId in ('SALRET2','SALRET1','SALRET3','SALRET4')
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE ID IN (SELECT ID FROM SYSOBJECTS WHERE NAME ='Receipt' AND XTYPE='U') AND NAME='DocRefNo')
ALTER TABLE Receipt ADD DocRefNo NVARCHAR(50) DEFAULT '' WITH VALUES
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE ID IN (SELECT ID FROM SYSOBJECTS WHERE NAME ='Receipt' AND XTYPE='U') AND NAME='PDAReceipt')
ALTER TABLE Receipt ADD PDAReceipt INT DEFAULT 0 WITH VALUES
GO
UPDATE hotsearcheditorhd SET RemainsltString='SELECT Distinct ReceiptNo,ReceiptDate FROM PDA_ReceiptInvoice' WHERE FormId=10052
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10051
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10051,'Doc Reference No','Reference No','Srno',4500,0,'HotSch-3-2000-36',3 UNION ALL
SELECT 2,10051,'Retailer Code','Retailer Code','RtrCode',4500,0,'HotSch-3-2000-37',3 UNION ALL
SELECT 3,10051,'Retailer Name','Retailer Name','RtrName',4500,0,'HotSch-3-2000-38',3 
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10051
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10051,'Sales Return','DocRefNo','Select','SELECT R.RtrId,Srno,RtrCode,RtrName,SMID,SMName,RM.RMID,RMNAME FROM PDA_SalesReturn  
PD (NOLOCK)  INNER JOIN Retailer R (NOLOCK) ON R.Rtrid=Pd.Rtrid INNER JOIN RetailerMarket RTM (NOLOCK) ON RTM.RMID=PD.MktId AND 
RTM.Rtrid=R.Rtrid INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=RTM.RMID and 
RM.RMID=PD.MktId INNER JOIN SalesMan SM (NOLOCK) ON SM.SMID=PD.SrpID WHERE PD.Status=0'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10052
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10052,'CollectionRefNo','Receipt No','ReceiptNo',1500,0,'HotSch-9-2000-14',9 UNION ALL
SELECT 2,10052,'CollectionRefNo','Collected Date','ReceiptDate',4500,0,'HotSch-9-2000-15',9
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10052
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10052,'Collection Register','CollectionRefNo','Select','SELECT ReceiptNo,ReceiptDate FROM PDA_ReceiptInvoice'
GO
DELETE FROM HotSearchEditorHd WHERE formid= 10053
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10053,'Retailer Master','RetailerCode','select','SELECT distinct CustomerCode,CustomerName 
FROM PDA_NewRetailer where CustomerCode not in (select RtrCode from Retailer)'
GO
DELETE FROM HotSearchEditorDt WHERE formid= 10053
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10053,'RetailerCode','Code','CustomerCode',1000,0,'HotSch-79-2000-24',79 UNION ALL
SELECT 2,10053,'RetailerCode','Name','CustomerName',3500,0,'HotSch-79-2000-25',79 
GO
IF NOT EXISTS (SELECT * FROM UdcHd A (NOLOCK) INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId 
				WHERE A.MasterName='Retailer Master' AND A.MasterId=2 AND B.ColumnName='Latitude')
BEGIN
	INSERT INTO UdcMaster (UdcMasterId,MasterId,ColumnName,ColumnDataType,ColumnSize,ColumnPrecision,ColumnMandatory,PickFromDefault,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,Editable)
	SELECT Currvalue+1,2,'Latitude','VARCHAR',50,0,0,0,1,1,GETDATE(),1,GETDATE(),0
	FROM Counters (NOLOCK) WHERE TabName='UDCMaster' AND FldName='UdcMasterId'
	UPDATE A SET A.CurrValue=Currvalue+1 FROM Counters A (NOLOCK) WHERE TabName='UDCMaster' AND FldName='UdcMasterId'
END
GO
IF NOT EXISTS (SELECT * FROM UdcHd A (NOLOCK) INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId 
				WHERE A.MasterName='Retailer Master' AND A.MasterId=2 AND B.ColumnName='Longitude')
BEGIN
	INSERT INTO UdcMaster (UdcMasterId,MasterId,ColumnName,ColumnDataType,ColumnSize,ColumnPrecision,ColumnMandatory,PickFromDefault,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,Editable)
	SELECT Currvalue+1,2,'Longitude','VARCHAR',50,0,0,0,1,1,GETDATE(),1,GETDATE(),0
	FROM Counters (NOLOCK) WHERE TabName='UDCMaster' AND FldName='UdcMasterId'
	UPDATE A SET A.CurrValue=Currvalue+1 FROM Counters A (NOLOCK) WHERE TabName='UDCMaster' AND FldName='UdcMasterId'
END
GO
IF NOT EXISTS (SELECT B.UDCUniqueId FROM UdcMaster A INNER JOIN UDCDETAILS B ON A.UdcMasterId=B.UdcMasterId WHERE A.MasterId=2 AND A.ColumnName='Latitude')
BEGIN
	DECLARE @UDCDET TABLE
	(
		SLNO	BIGINT IDENTITY (1,1),
		UDCDETAILSID	BIGINT,
		UDCMASTERID INT,
		MASTERID INT,
		MASTERRECORDID INT,
		COLVAL	INT,
		UDCUNIQUEID	INT	
	)
	INSERT INTO @UDCDET 
	SELECT (SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UdcDetailsId') UDCDETAILSID,UdcMasterId,MasterId,RTRID,'',(SELECT CurrValue+1 FROM Counters WHERE TabName='UDCDetails' AND FldName='UDCUniqueId') FROM UdcMaster
	CROSS JOIN RETAILER WHERE COLUMNNAME='Latitude'
	UPDATE @UDCDET SET UDCDETAILSID=SLNO+UDCDETAILSID
	INSERT INTO UdcDetails (UdcDetailsId,UdcMasterId,MasterId,MasterRecordId,ColumnValue,UDCUniqueId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
	SELECT UDCDETAILSID,UDCMASTERID,MASTERID,MASTERRECORDID,COLVAL,UDCUNIQUEID,1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate,0 Upload FROM @UDCDET
	UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
	UPDATE Counters SET CurrValue=(SELECT ISNULL(MAX(UDCDETAILSID),0) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
END
GO
IF NOT EXISTS (SELECT B.UDCUniqueId FROM UdcMaster A INNER JOIN UDCDETAILS B ON A.UdcMasterId=B.UdcMasterId WHERE A.MasterId=2 AND A.ColumnName='Longitude')
BEGIN
	DECLARE @UDCDET TABLE
	(
		SLNO	BIGINT IDENTITY (1,1),
		UDCDETAILSID	BIGINT,
		UDCMASTERID INT,
		MASTERID INT,
		MASTERRECORDID INT,
		COLVAL	INT,
		UDCUNIQUEID	INT	
	)
	INSERT INTO @UDCDET 
	SELECT (SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UdcDetailsId') UDCDETAILSID,UdcMasterId,MasterId,RTRID,'',(SELECT CurrValue+1 FROM Counters WHERE TabName='UDCDetails' AND FldName='UDCUniqueId') FROM UdcMaster
	CROSS JOIN RETAILER WHERE COLUMNNAME='Longitude'
	UPDATE @UDCDET SET UDCDETAILSID=SLNO+UDCDETAILSID
	INSERT INTO UdcDetails (UdcDetailsId,UdcMasterId,MasterId,MasterRecordId,ColumnValue,UDCUniqueId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
	SELECT UDCDETAILSID,UDCMASTERID,MASTERID,MASTERRECORDID,COLVAL,UDCUNIQUEID,1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate,0 Upload FROM @UDCDET
	UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
	UPDATE Counters SET CurrValue=(SELECT ISNULL(MAX(UDCDETAILSID),0) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
END
GO
IF NOT EXISTS(SELECT * FROM UDCMASTER WHERE ColumnName='IMEI No')
BEGIN
	INSERT INTO UDCMASTER 
	SELECT MAX(udcmasterid)+1,4,'IMEI No','VARCHAR',50,0,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM UDCMASTER 
	UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='UDCMASTER' AND FldName='UdcMasterId'
END
GO
IF NOT EXISTS(SELECT * FROM UDCMASTER WHERE ColumnName='Password')
BEGIN
	INSERT INTO UDCMASTER 
	SELECT MAX(udcmasterid)+1,4,'Password','VARCHAR',50,0,0,0,1,1,GETDATE(),1,GETDATE(),1 FROM UDCMASTER 
	UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='UDCMASTER' AND FldName='UdcMasterId'
END
GO
IF NOT EXISTS (SELECT * FROM UdcDetails WHERE UdcMasterId IN (SELECT UdcMasterId FROM UdcMaster WHERE ColumnName='IMEI No'))
BEGIN
	INSERT INTO UdcDetails
	SELECT ROW_NUMBER() OVER (ORDER BY SMID)+MAX(UdcDetailsId) AS ROW,
	(SELECT UdcMasterId FROM UDCMASTER WHERE ColumnName='IMEI No'),4,SMId,'',
	(SELECT MAX(UDCUniqueId)+1 FROM UdcDetails ),1,1,GETDATE(),1,GETDATE(),0
	FROM UdcDetails U CROSS JOIN Salesman S GROUP BY SMID

	UPDATE COUNTERS SET CurrValue =(SELECT ISNULL(MAX(UdcDetailsId),0) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
	UPDATE COUNTERS SET CurrValue =CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
END
GO
IF NOT EXISTS (SELECT * FROM UdcDetails WHERE UdcMasterId IN (SELECT UdcMasterId FROM UdcMaster WHERE ColumnName='Password'))
BEGIN
	INSERT INTO UdcDetails
	SELECT ROW_NUMBER() OVER (ORDER BY SMID)+MAX(UdcDetailsId) as Row,
	(SELECT UdcMasterId FROM UDCMASTER WHERE ColumnName='Password'),4,SMId,'',
	(SELECT MAX(UDCUniqueId)+1 FROM UdcDetails ),1,1,GETDATE(),1,GETDATE(),0
	FROM UdcDetails U CROSS JOIN Salesman S GROUP BY SMID

	UPDATE COUNTERS SET CurrValue = (SELECT ISNULL(MAX(UdcDetailsId),0) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
	UPDATE COUNTERS SET CurrValue =CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_SalesRepresentative' AND XTYPE ='U')
DROP TABLE Cos2Mob_SalesRepresentative
GO
CREATE TABLE Cos2Mob_SalesRepresentative
(
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[SrpId] [int] NULL,
	[SrpCde] [varchar](50) NULL,
	[SrpNm] [varchar](50) NULL,
	[UploadFlag] [varchar](1) NULL,
	ImeiNo	varchar(50),
	SMPassword varchar(50)	
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Cos2Mob_Market' AND XTYPE='U')
DROP TABLE Cos2Mob_Market
GO
CREATE TABLE Cos2Mob_Market
(
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[MktId] [int] NULL,
	[MktCde] [varchar](50) NULL,
	[MktNm] [varchar](50) NULL,
	[MktDist] [int] NULL,
	[Monday] [int] ,
	[Tuesday] [int] ,
	[Wednesday] [int], 
	[Thursday] [int] ,
	[Friday] [int] ,
	[Saturday] [int], 
	[Sunday] [int] ,
	[UploadFlag] [varchar](1) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_Retailer' AND XTYPE ='U')
DROP TABLE Cos2Mob_Retailer
GO
CREATE TABLE Cos2Mob_Retailer
(
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[RtrId] [int] NULL,
	[MktId] [int] NULL,
	[RtrCode] [nvarchar](50) NULL,
	[RtrName] [nvarchar](100) NULL,
	[RtrAdd1] [nvarchar](100) NULL,
	[RtrPinNo] [int] NULL,
	[RtrPhoneNo] [nvarchar](100) NULL,
	[CtgName] [nvarchar](200) NULL,
	[CtgCode] [nvarchar](200) NULL,
	[CtgLevelName] [nvarchar](200) NULL,
	[BilledRet] [int] NULL,
	[RtrValueClassid] [int] NULL,
	[UploadFlag] [varchar](1) NULL,
	[Longitude]  [varchar](50) NULL,
	[Latitude]  [varchar](50) NULL,
	RtrMobileNo	NVARCHAR(100)	
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_ProductCategory' AND XTYPE ='U')
DROP TABLE Cos2Mob_ProductCategory
GO
CREATE TABLE  Cos2Mob_ProductCategory
(
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[CmpPrdCtgId] [int] NULL,
	[CmpPrdCtgName] [nvarchar](100) NULL,
	[LevelName] [nvarchar](100) NULL,
	[CmpId] [int] NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_ProductCategoryValue' AND XTYPE ='U')
DROP TABLE Cos2Mob_ProductCategoryValue
GO
CREATE TABLE  Cos2Mob_ProductCategoryValue		
(	
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode			NVARCHAR(20),
	SrpCde				VARCHAR(50),
	PrdCtgValMainId		INT,
	PrdCtgValLinkId		INT,
	CmpPrdCtgId			INT,
	PrdCtgValLinkCode	NVARCHAR(1000),
	PrdCtgValCode		NVARCHAR(200),
	PrdCtgValName		NVARCHAR(100),
	UploadFlag			VARCHAR	(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_Product' AND XTYPE ='U')
DROP TABLE Cos2Mob_Product
GO
CREATE TABLE  Cos2Mob_Product		
(	
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[PrdId] [int] NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdShrtNm] [nvarchar](200) NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[SpmId] [int] NULL,
	[PrdWgt] [numeric](18, 6) NULL,
	[PrdUnitId] [int] NULL,
	[UomGroupId] [int] NULL,
	[TaxGroupId] [int] NULL,
	[PrdType] [int] NULL,
	[CmpId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[FocusBrand] [int] NULL,
	[FrqBilledPrd] [int] NULL,
	[CategoryID] [int] NULL,
	[CAtegoryCode] [varchar](100) NULL,
	[CategoryName] [varchar](100) NULL,
	[Brandid] [int] NULL,
	[BtrandCode] [varchar](100) NULL,
	[BrandName] [varchar](100) NULL,
	[UploadFlag] [varchar](1) NULL,
	DefaultUomid    Int
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_Productbatch' AND XTYPE ='U')
DROP TABLE Cos2Mob_Productbatch
GO
CREATE TABLE  Cos2Mob_Productbatch
(	
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PriceId] [int] NULL,
	[CmpBatCode] [nvarchar](100) NULL,
	[MnfDate] [datetime] NULL,
	[ExpDate] [datetime] NULL,
	[Status] [tinyint] NULL,
	[TaxGroupId] [int] NULL,
	[MRP] [numeric](18, 6) NULL,
	[ListPrice] [numeric](18, 6) NULL,
	[SellingPrice] [numeric](18, 6) NULL,
	[SellingPriceWtTax] [numeric](18, 6) NULL,
	[TaxAmount] [numeric](18, 6) NULL,
	[StockInHand] [int] NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_Bank' AND XTYPE ='U')
DROP TABLE Cos2Mob_Bank
GO
CREATE TABLE  Cos2Mob_Bank
(	
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode	NVARCHAR(20),
	SrpCde		VARCHAR(50),
	BnkId		INT,
	BnkCode		VARCHAR(50),
	BnkName		VARCHAR(50),
	UploadFlag	VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_BankBranch' AND XTYPE ='U')
DROP TABLE Cos2Mob_BankBranch
GO
CREATE TABLE  Cos2Mob_BankBranch
(	
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode	NVARCHAR(20),
	SrpCde		VARCHAR(50),
	BnkId		INT,	
	BnkBrId		INT,
	BnkBrCode	NVARCHAR(40),
	BnkBrName	NVARCHAR(100),
	BnkBrACNo	NVARCHAR(40),
	DistBank	TINYINT,
	CoaId		INT,
	UploadFlag	VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_PendingBills' AND XTYPE ='U')
DROP TABLE Cos2Mob_PendingBills
GO
CREATE TABLE  Cos2Mob_PendingBills
(	
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode			NVARCHAR(20),
	SrpCde				VARCHAR(50),
	Salid				INT,
	SalInvNo			VARCHAR(25),
	SalInvDte			DATETIME,
	RtrId				INT,
	TotalInvoiceAmount	FLOAT,
	PaidAmount			FLOAT,
	BalanceAmount		FLOAT,
	UploadFlag			VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_CreditNote' AND XTYPE ='U')
DROP TABLE Cos2Mob_CreditNote
GO
CREATE TABLE  Cos2Mob_CreditNote
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode	NVARCHAR(20),
	SrpCde		VARCHAR	(50),
	CrNo		VARCHAR	(20),
	CrAmount	NUMERIC	(18,2),
	RtrId		NUMERIC	(18,2),
	CrAdjAmount	NUMERIC	(18,2),
	TranNo		VARCHAR	(20),
	Reasonid	INT,
	UploadFlag	VARCHAR	(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_DebitNote' AND XTYPE ='U')
DROP TABLE Cos2Mob_DebitNote
GO
CREATE TABLE  Cos2Mob_DebitNote
(	
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode	NVARCHAR(20),
	SrpCde		VARCHAR(50),
	DbNo		VARCHAR(20),
	DbAmount	NUMERIC(18,2),
	RtrId		NUMERIC(18,2),
	DbAdjAmount	NUMERIC(18,2),
	TransNo		VARCHAR(20),
	Reasonid	INT,
	UploadFlag	VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_RetailerCategoryLevel' AND XTYPE ='U')
DROP TABLE Cos2Mob_RetailerCategoryLevel
GO
CREATE TABLE  Cos2Mob_RetailerCategoryLevel
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode		NVARCHAR(20),
	CtgLevelId		INT,
	CtgLevelName	NVARCHAR(200),
	LevelName		NVARCHAR(200),
	UploadFlag		VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_RetailerCategory' AND XTYPE ='U')
DROP TABLE Cos2Mob_RetailerCategory
GO
CREATE TABLE  Cos2Mob_RetailerCategory
(	
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode	NVARCHAR(20),
	CtgMainId	INT,
	CtgLinkId	INT,
	CtgLevelId	INT,
	CtgLinkCode	NVARCHAR(400),
	CtgCode		NVARCHAR(40),
	CtgName		NVARCHAR(100),
	UploadFlag	VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_RetailerValueClass' AND XTYPE ='U')
DROP TABLE Cos2Mob_RetailerValueClass
GO
CREATE TABLE  Cos2Mob_RetailerValueClass
(
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[RtrClassId] [int] NULL,
	[CmpId] [int] NULL,
	[CtgMainId] [int] NULL,
	[ValueClassCode] [nvarchar](40) NULL,
	[ValueClassName] [nvarchar](100) NULL,
	[Turnover] [numeric](18, 2) NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_SchemeNarration' AND XTYPE ='U')
DROP TABLE Cos2Mob_SchemeNarration
GO
CREATE TABLE  Cos2Mob_SchemeNarration
(
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[Channel] [varchar](100) NULL,
	[SubType] [varchar](100) NULL,
	[CmpSchCode] [varchar](100) NULL,
	[Schdesc] [varchar](200) NULL,
	[Narration] [varchar](500) NULL,
	[UploadFlag] [varchar](1) NULL,
	ChannelCode VARCHAR(100),
	RtrClassId INT
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_SchemeProductDetails' AND XTYPE ='U')
DROP TABLE Cos2Mob_SchemeProductDetails
GO
CREATE TABLE  Cos2Mob_SchemeProductDetails
(
	[SlNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[CmpschCode] [varchar](200) NULL,
	[SchDsc] [varchar](200) NULL,
	[Prdcode] [varchar](100) NULL,
	[Prdname] [varchar](200) NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_ReasonMaster' AND XTYPE ='U')
DROP TABLE Cos2Mob_ReasonMaster
GO
CREATE TABLE  Cos2Mob_ReasonMaster		
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode		    NVARCHAR(20),
	SrpCde				VARCHAR(50),
	ReasonId			INT	,
	ReasonCode			NVARCHAR(40),
	[Description]		NVARCHAR(100),
	PurchaseReceipt		TINYINT,
	SalesInvoice		TINYINT,
	VanLoad				TINYINT,
	CrNoteSupplier		TINYINT,
	CrNoteRetailer		TINYINT,
	DeliveryProcess		TINYINT,
	SalvageRegister		TINYINT,
	PurchaseReturn		TINYINT,
	SalesReturn			TINYINT,
	VanUnload			TINYINT,
	DbNoteSupplier		TINYINT,
	DbNoteRetailer		TINYINT,
	StkAdjustment		TINYINT,
	StkTransferScreen	TINYINT,
	BatchTransfer		TINYINT,
	ReceiptVoucher		TINYINT,
	ReturnToCompany		TINYINT,
	LocationTrans		TINYINT,
	Billing				TINYINT,
	ChequeBouncing		TINYINT,
	ChequeDisbursal		TINYINT,
	NonBilled           TINYINT,
	UploadFlag			VARCHAR(1)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='SFA_RetailerCategory')
DROP TABLE SFA_RetailerCategory
GO
CREATE TABLE SFA_RetailerCategory
(
	[slNo] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) NULL,
	[RetCatId] [int] NULL,
	[ChannelCode] [nvarchar](40) NULL,
	[ChannelName] [nvarchar](100) NULL,
	[SubChannelCode] [nvarchar](40) NULL,
	[SubChannelName] [nvarchar](100) NULL,
	[GroupCode] [nvarchar](40) NULL,
	[GroupName] [nvarchar](100) NULL,
	[ClassCode] [nvarchar](40) NULL,
	[ClassName] [nvarchar](100) NULL,
	[UploadFlag] [varchar](1) NOT NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_UomMaster' AND XTYPE='U')
DROP TABLE Cos2Mob_UomMaster
GO
CREATE TABLE Cos2Mob_UomMaster
(
	SlNo       INT Identity(1,1)NOT NULL,
	[Distcode] [varchar](50) NULL,
	[SrpCde]   [varchar](25) NULL,
	UomGroupId INT,
	UomGroupCode	NVARCHAR(50),
	UomGroupDescription	NVARCHAR(50),
	UomId	INT,
	UomCode Nvarchar(50),
	UomDescription Nvarchar(50),
	BaseUom	NVARCHAR(50),
	ConversionFactor	INT,
	[UploadFlag] [varchar](1) NULL
)
GO
------------------ImPort Tables -----------------------------------------------------
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_SalesReturn' AND XTYPE ='U')
DROP TABLE ImportProductPDA_SalesReturn
GO
CREATE TABLE  ImportProductPDA_SalesReturn		
(
	[SrpCde] [varchar](50) NULL,
	[SrNo] [varchar](25) NULL,
	[SrDate] [datetime] NULL,
	[SalInvNo] [varchar](25) NULL,
	[RtrCde] [nvarchar](40) NULL,
	[Rtrid] [int] NULL,
	[Mktid] [int] NULL,
	[Srpid] [int] NULL,
	[ReturnMode] [int] NULL,
	[InvoiceType] [int] NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_SalesReturnProduct' AND XTYPE ='U')
DROP TABLE ImportProductPDA_SalesReturnProduct
GO
CREATE TABLE  ImportProductPDA_SalesReturnProduct		
(
	[SrpCde] [varchar](50) NULL,
	[SrNo] [nvarchar](50) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PriceId] [int] NULL,
	[SrQty] [int] NULL,
	[UsrStkTyp] [int] NULL,
	[salinvno] [varchar](25) NULL,
	[SlNo] [int] NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportPDA_NonProductiveRetailers' AND XTYPE ='U')
DROP TABLE ImportPDA_NonProductiveRetailers
GO
CREATE TABLE  ImportPDA_NonProductiveRetailers
(
	SrpCde		VARCHAR(50),
	RtrCode     NVARCHAR(50),
	ReasonId    INT,
	NonProdDate DATETIME,
	UploadFlag	VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportPDA_OrderBooking' AND XTYPE ='U')
DROP TABLE ImportPDA_OrderBooking
GO
CREATE TABLE  ImportPDA_OrderBooking		
(
	[SrpCde] [varchar](50) NULL,
	[OrdKeyNo] [varchar](50) NULL,
	[OrdDt] [datetime] NULL,
	[RtrCde] [nvarchar](200) NULL,
	[Mktid] [int] NULL,
	[SrpId] [int] NULL,
	[Rtrid] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
	[UploadFlag] [varchar](1) NULL,
	[Longitude] [varchar](50) NULL,
	[Latitude] [varchar](50) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportPDA_OrderBookingProduct' AND XTYPE ='U')
DROP TABLE ImportPDA_OrderBookingProduct
GO
CREATE TABLE  ImportPDA_OrderBookingProduct		
(
	SrpCde		VARCHAR(50),
	OrdKeyNo	VARCHAR(50),
	PrdId		INT,
	PrdBatId	INT,
	PriceId		INT,
	OrdQty		INT,
	UploadFlag	VARCHAR(1),
	Uomid       INT
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_SalesReturn' AND XTYPE ='U')
DROP TABLE ImportProductPDA_SalesReturn
GO
CREATE TABLE  ImportProductPDA_SalesReturn		
(
	SrpCde		VARCHAR(50),
	SrNo		VARCHAR(25),
	SrDate		DATETIME,
	SalInvNo	VARCHAR(25),
	RtrCde		NVARCHAR(40),
	Rtrid		INT	,
	Mktid		INT,	
	Srpid		INT,	
	ReturnMode	INT,	
	InvoiceType	INT,	
	UploadFlag	VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_SalesReturnProduct' AND XTYPE ='U')
DROP TABLE ImportProductPDA_SalesReturnProduct
GO
CREATE TABLE  ImportProductPDA_SalesReturnProduct
(
	[SrpCde] [varchar](50) NULL,
	[SrNo] [nvarchar](50) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PriceId] [int] NULL,
	[SrQty] [int] NULL,
	[UsrStkTyp] [int] NULL,
	[salinvno] [varchar](25) NULL,
	[SlNo] [int] NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_Receiptinvoice' AND XTYPE ='U')
DROP TABLE ImportProductPDA_Receiptinvoice
GO
CREATE TABLE  ImportProductPDA_Receiptinvoice
(
	[SrpCde] [varchar](50) NULL,
	[InvRcpNo] [varchar](50) NULL,
	[InvRcpDate] [datetime] NULL,
	[InvrcpAmt] [numeric](18, 2) NULL,
	[SalInvNo] [varchar](25) NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvAmt] [float] NULL,
	[InvRcpMode] [varchar](1) NULL,
	[BnkBrId] [int] NULL,
	[InvInsNo] [nvarchar](100) NULL,
	[InvInsDate] [datetime] NULL,
	[InvDepDate] [datetime] NULL,
	[InvInsSta] [varchar](1) NULL,
	[CashAmt] [numeric](18, 2) NULL,
	[ChequeAmt] [numeric](18, 2) NULL,
	[UploadFlag] [varchar](1) NULL,
	[RtrCode] [varchar](50) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_CreditNote' AND XTYPE ='U')
DROP TABLE ImportProductPDA_CreditNote
GO
CREATE TABLE  ImportProductPDA_CreditNote 
(
	SrpCde		VARCHAR(50),
	InvRcpNo	varchar	(50),
	CrNo		VARCHAR(20),
	CrAmount	NUMERIC(18,2),
	SalInvNo	varchar	(25),
	RtrId		NUMERIC(18,2),
	CrAdjAmount	NUMERIC(18,2),
	TranNo		VARCHAR(20),
	Reasonid	INT, 
	UploadFlag	VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_DebitNote' AND XTYPE ='U')
DROP TABLE ImportProductPDA_DebitNote
GO
CREATE TABLE  ImportProductPDA_DebitNote
(
	SrpCde		VARCHAR(50),
	DbNo		VARCHAR(20),
	DbAmount	NUMERIC(18,2),
	RtrId		NUMERIC(18,2),
	DbAdjAmount	NUMERIC(18,2),
	TransNo		VARCHAR(20),
	Reasonid	INT, 
	UploadFlag	VARCHAR(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_NewRetailer' AND XTYPE ='U')
DROP TABLE ImportProductPDA_NewRetailer
GO
CREATE TABLE  ImportProductPDA_NewRetailer
(
	[SrpCde] [varchar](50) NULL,
	[RtrCode] [nvarchar](50) NULL,
	[RetailerName] [nvarchar](100) NULL,
	[CtgLevelId] [int] NULL,
	[CtgMainID] [int] NULL,
	[RtrClassId] [int] NULL,
	[RtrAdd1] [nvarchar](100) NULL,
	[RtrAdd2] [nvarchar](100) NULL,
	[RtrAdd3] [nvarchar](100) NULL,
	[RtrPhoneNo] [nvarchar](100) NULL,
	[CreditAvailable] [numeric](18, 6) NULL,
	[RtrTINNo] [nvarchar](100) NULL,
	[UploadFlag] [varchar](1) NULL,
	[Longitude] [varchar](50) NULL,
	[Latitude] [varchar](50) NULL,
	RtrMobileNo NVARCHAR(100)
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_SalesRepresentative' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_SalesRepresentative
GO
--EXEC PROC_ExportPDA_SalesRepresentative 2
CREATE PROCEDURE PROC_ExportPDA_SalesRepresentative
AS
BEGIN
	DELETE FROM Cos2Mob_SalesRepresentative --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_SalesRepresentative (DistCode,SrpId,SrpCde,SrpNm,UploadFlag,ImeiNo,SMPassword)
	SELECT DistriButorCode,SMID,SMCode,SMName,'N' AS UploadFlag,'','' FROM SalesMan CROSS JOIN Distributor 
	
	WHERE SMId IN (SELECT SMId FROM Sales_upload) and Status=1
	

	UPDATE C SET ImeiNo=A.IMEINo FROM Cos2Mob_SalesRepresentative C INNER JOIN
	(SELECT SMId,UD.ColumnValue 'IMEINo' FROM UdcMaster UM 
	INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('IMEI No')
	INNER JOIN salesman R ON R.SMId=UD.MASTERRECORDID 
	WHERE UM.MasterId=4 )A ON C.SrpId=A.SMId

	UPDATE C SET SMPassword=LOWER(CONVERT(VARCHAR(32), HashBytes('MD5', A.Password), 2)) FROM Cos2Mob_SalesRepresentative C INNER JOIN
	(SELECT SMId,UD.ColumnValue 'Password' FROM UdcMaster UM 
	INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('Password')
	INNER JOIN salesman R ON R.SMId=UD.MASTERRECORDID 
	WHERE UM.MasterId=4 )A ON C.SrpId=A.SMId
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='PROC_ExportPDA_Market' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_Market
GO
--EXEC PROC_ExportPDA_Market  
CREATE PROCEDURE PROC_ExportPDA_Market
AS
BEGIN
	DELETE FROM Cos2Mob_Market --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_Market (DistCode,SrpCde,MktId,MktCde,MktNm,MktDist,Monday,Tuesday,
		Wednesday,Thursday,Friday,Saturday,Sunday,UploadFlag)
	SELECT DistributorCode,SMCode,R.RMId,RmCode,RmName,RMDistance,RMMon,RMTue,RMWed,RMThu,
	RMFri,RMSat,RMSun,'N' AS UploadFlag FROM RouteMaster R
	INNER JOIN SalesmanMarket SM on SM.RMId=R.RMId	
	INNER JOIN Salesman S on S.SMId=Sm.SMId	
	CROSS JOIN Distributor
	WHERE R.RMId IN(SELECT RMId FROM Sales_upload) AND R.RMstatus=1 and s.SMId IN (SELECT SMId FROM Sales_upload) and Status=1
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Retailer' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_Retailer
GO
--EXEC PROC_ExportPDA_Retailer 
CREATE PROCEDURE PROC_ExportPDA_Retailer
AS 
BEGIN
DECLARE @StartDate datetime

SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 

	DELETE FROM Cos2Mob_Retailer --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_Retailer (DistCode,SrpCde,RtrId,mktid,RtrCode,RtrName,RtrAdd1,RtrPinNo,RtrPhoneNo,CtgName,CtgCode,CtgLevelName,Billedret,RtrValueClassid,UploadFlag,Longitude,Latitude)
	SELECT DistributorCode,SMCode,R.RtrId,RM.RMId,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrPinNo,R.RtrPhoneNo,RC.CtgName,RC.CtgCode,RCL.CtgLevelName,0,RVM.RtrValueClassId,'N' AS UploadFlag,'',''
	FROM Retailer R
	INNER JOIN RetailerValueClassMap RVM ON R.RtrId=RVM.RtrId
	INNER JOIN RetailerValueClass RV ON RVM.RtrValueClassId=RV.RtrClassId
	INNER JOIN RetailerCategory RC ON RV.CtgMainId=RC.CtgMainId
	INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId=RCL.CtgLevelId
	INNER JOIN RetailerMarket RM on RM.RtrId=R.RtrId 
	INNER JOIN SalesmanMarket SM on SM.RMId=RM.RMId
	INNER JOIN Salesman S on S.SMId=SM.SMId
	CROSS JOIN Distributor
	where RM.RMId in(select RMId from Sales_upload) and R.RtrStatus=1 and s.SMId IN (SELECT SMId FROM Sales_upload) and s.Status=1
	
	SELECT RtrId into #TempBilled FROM SalesInvoice  WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121)
	
	update E set Billedret=1 from  Cos2Mob_Retailer E inner join #TempBilled T on E.RtrId=T.RtrId
	
	UPDATE C SET Latitude=A.Latitude FROM Cos2Mob_Retailer C INNER JOIN
	(SELECT RTRID,UD.ColumnValue 'Latitude' FROM UdcMaster UM 
	INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('Latitude')
	INNER JOIN Retailer R ON R.RTRID=UD.MASTERRECORDID 
	WHERE UM.MasterId=2 )A ON C.RtrId=A.RtrId

	UPDATE C SET Longitude=A.Longitude FROM Cos2Mob_Retailer C INNER JOIN
	(SELECT RTRID,UD.ColumnValue 'Longitude' FROM UdcMaster UM 
	INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('Latitude')
	INNER JOIN Retailer R ON R.RTRID=UD.MASTERRECORDID 
	WHERE UM.MasterId=2 )A ON C.RtrId=A.RtrId		
 END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_ProductCategory' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_ProductCategory
GO
--EXEC PROC_ExportPDA_ProductCategory SM01
CREATE PROCEDURE PROC_ExportPDA_ProductCategory
AS
BEGIN
	DELETE FROM Cos2Mob_ProductCategory --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_ProductCategory (DistCode,SrpCde,CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId,UploadFlag)
	SELECT DistributorCode,smcode,CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId,'N' AS UploadFlag 
	FROM ProductCategoryLevel 
	CROSS JOIN (SELECT DISTINCT smcode FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
	CROSS JOIN Distributor
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_ProductCategoryValue' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_ProductCategoryValue
GO
--EXEC PROC_ExportPDA_ProductCategoryValue SM01
CREATE PROCEDURE PROC_ExportPDA_ProductCategoryValue
AS
BEGIN
	DELETE FROM Cos2Mob_ProductCategoryValue --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_ProductCategoryValue (DistCode,SrpCde,PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,UploadFlag)
	SELECT DistributorCode,smcode,PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,'N' AS UploadFlag
	FROM ProductCategoryValue 
	CROSS JOIN (SELECT DISTINCT smcode FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
	CROSS JOIN Distributor
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Product' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_Product
GO
--EXEC PROC_ExportPDA_Product  
CREATE PROCEDURE PROC_ExportPDA_Product
AS
BEGIN
DECLARE @FromDate DATETIME
DECLARE @ToDate  DATETIME
DECLARE @DistCode nVarchar(50)
DECLARE @Smcode Nvarchar(50)
CREATE TABLE #tempproduct(Prdid INT)
	EXEC Proc_GR_Build_PH
	
	SELECT @FromDate=dateadd(MM,-3,getdate())
	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)
	SELECT @DistCode=DistributorCode  from Distributor
	SET @Smcode=(SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid)
	
	INSERT INTO #tempproduct
	SELECT DISTINCT PrdId FROM SalesInvoice SI inner join SalesInvoiceProduct SIP on SI.SalId=SIP.SalId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
	
	INSERT INTO #tempproduct	
	SELECT DISTINCT PrdId FROM PurchaseReceipt G inner join PurchaseReceiptProduct GP on G.PurRcptId=GP.PurRcptId where G.InvDate
	BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
	
	INSERT INTO #tempproduct	
	SELECT DISTINCT PrdId FROM stockledger where TransDate
	BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
	
	DELETE FROM Cos2Mob_Product-- WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_Product (DistCode,SrpCde,PrdId,PrdName, PrdShrtNm,PrdCCode,SpmId,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,CmpId,PrdCtgValMainId,FocusBrand,
	                             FrqBilledPrd,CategoryID,CAtegoryCode,CategoryName,Brandid,BtrandCode,BrandName,UploadFlag,DefaultUomid)
	SELECT DISTINCT @DistCode,@Smcode,P.PrdId,PrdName,PrdShrtName,PrdCCode,SpmId,PrdWgt,PrdUnitId,p.UomGroupId,TaxGroupId,PrdType,CmpId,PrdCtgValMainId,0,0,
	T.Brand_Id,T.Brand_Code,T.Brand_Caption,T.Pack_Id,T.Pack_Code,T.Pack_Caption,'N' AS UploadFlag,U.UomId
	FROM Product P INNER JOIN  TBL_GR_BUILD_PH T on T.PrdId=p.PrdId inner join #tempproduct tp on p.PrdId=tp.Prdid and t.PRDID=tp.Prdid
	INNER JOIN UOMGROUP U ON U.UomGroupId=P.UomGroupId AND BASEUOM='Y'
	WHERE PrdStatus=1
	
	SELECT  DISTINCT A.PRDID,count(A.prdid)AS SOLD,C.PrdName,C.PrdCCode INTO #SRI
	FROM SalesInvoiceproduct A
	INNER JOIN SalesInvoice B ON a.SalId=B.SalId
	INNER JOIN Product C ON a.prdid=C.prdid
    WHERE b.SalInvDate BETWEEN dateadd(month, -3, getdate()) AND CONVERT(VARCHAR(10),GETDATE(),121)
	GROUP BY a.prdid,c.PrdName,C.PrdCCode 
	
    UPDATE Cos2Mob_Product SET FrqBilledPrd=1 WHERE prdid IN (SELECT TOP 10 prdid FROM  #SRI GROUP BY prdid,PrdName,SOLD ORDER BY SOLD DESC)
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='ProductBatchTaxPercent' AND XTYPE='U')
DROP TABLE ProductBatchTaxPercent
GO
CREATE TABLE ProductBatchTaxPercent
(
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[TaxPercentage] [numeric](18, 5) NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='TempProductTax' AND XTYPE='U')
DROP TABLE TempProductTax
GO
CREATE TABLE TempProductTax
(
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[TaxId] [int] NULL,
	[TaxSlabId] [int] NULL,
	[TaxPercentage] [numeric](5, 2) NULL,
	[TaxAmount] [numeric](18, 5) NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_TaxCalCulation' AND XTYPE='P')
DROP PROCEDURE Proc_TaxCalCulation
GO
--Exec Proc_TaxCalCulation 528,1654
CREATE PROCEDURE Proc_TaxCalCulation
(
	@Prdid AS INT,
	@Prdbatid AS INT
	
)
AS
BEGIN
		DECLARE @TaxSettingDet TABLE       
		(      
			TaxSlab   INT,      
			ColNo   INT,      
			SlNo   INT,      
			BillSeqId  INT,      
			TaxSeqId  INT,      
			ColType   INT,       
			ColId   INT,      
			ColVal   NUMERIC(38,2)      
		) 
		
		DECLARE @PrdBatTaxGrp AS INT
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT    
		--To Take the Batch TaxGroup Id      
		SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) WHERE Prdid=@Prdid and  Prdbatid=@Prdbatid
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		Select @RtrTaxGrp=MIN(Distinct RtriD) FROM TaxSettingMaster (NOLOCK)
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
		TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
		WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
		AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)  
	
		SET @MRP=1
		TRUNCATE TABLE TempProductTax
		DECLARE  CurTax CURSOR FOR      
			SELECT DISTINCT TaxSlab FROM @TaxSettingDet      
		OPEN CurTax        
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		WHILE @@FETCH_STATUS = 0        
		BEGIN      
		SET @TaxableAmount = 0      
		--To Filter the Records Which Has Tax Percentage (>=0)      
		IF EXISTS (SELECT * FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0 and ColVal >= 0)      
		BEGIN      
		--To Get the Tax Percentage for the selected slab      
		SELECT @TaxPer = ColVal FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0      
		--To Get the TaxId for the selected slab      
		SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId > 0      
		SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP 
		--To Get the Parent Taxable Amount for the Tax Slab      
		SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM TempProductTax A      
		INNER JOIN @TaxSettingDet B ON A.TaxId = B.ColVal and  
		B.ColType = 3 AND B.TaxSlab = @TaxSlab 
		If @ParTaxableAmount>0
		BEGIN
			Set @TaxableAmount=@ParTaxableAmount
		END 
		ELSE
		BEGIN
			Set @TaxableAmount = @TaxableAmount
		END    
 
		INSERT INTO TempProductTax (PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,      
		TaxAmount)      
		SELECT @Prdid,@Prdbatid,@TaxId,@TaxSlab,@TaxPer,      
		cast(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
		 
		  
		END      
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		END        
		CLOSE CurTax        
		DEALLOCATE CurTax      
		SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
		FROM TempProductTax WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		PRINT @TaxPercentage
		IF EXISTS(SELECT * FROM ProductBatchTaxPercent WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
		BEGIN			
			UPDATE ProductBatchTaxPercent  SET TaxPercentage=@TaxPercentage
			WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		END	
		ELSE
		BEGIN			
			INSERT INTO ProductBatchTaxPercent(Prdid,Prdbatid,TaxPercentage)
			SELECT @Prdid,@Prdbatid,@TaxPercentage
		END
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Productbatch' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_Productbatch
GO
--EXEC PROC_ExportPDA_Productbatch SM01
CREATE PROCEDURE PROC_ExportPDA_Productbatch
AS
BEGIN
	DELETE FROM Cos2Mob_Productbatch --WHERE UploadFlag='Y'

DECLARE @Prdid1 AS INT
DECLARE @Prdid AS INT
DECLARE @PrdBatId AS INT
DECLARE @FromDate DATETIME
DECLARE @ToDate  DATETIME
DECLARE @DistCode nVarchar(50)
DECLARE @Smcode Nvarchar(50)

	SELECT @FromDate=dateadd(MM,-35,getdate())
	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)
	
	SELECT @DistCode=DistributorCode  from Distributor
	SET @Smcode=(SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid)

	CREATE TABLE #Tempproductbatch (Prdid int,prdbatid int)
	CREATE TABLE #tempproduct(Prdid int)
	
	INSERT INTO #tempproduct
	SELECT DISTINCT S.PrdId FROM Product P INNER JOIN  StockLedger S ON P.PrdId =S.PrdId 
	WHERE TransDate BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) AND PrdStatus=1  
	

	DECLARE Cur_Productbatch CURSOR
	FOR SELECT PRDID FROM #tempproduct
	OPEN  Cur_Productbatch 
	FETCH next FROM Cur_Productbatch INTO  @Prdid1
	WHILE @@FETCH_STATUS=0
	BEGIN
	 IF NOT EXISTS(SELECT P.prdid,P.prdbatid,SUM(PrdBatLcnSih-PrdBatLcnRessih)Qty FROM productbatchlocation P INNER JOIN PRODUCTBATCH PB ON P.PRDID=PB.PRDID 
	 AND P.PRDBATID=PB.PRDBATID WHERE P.PrdId=@Prdid1 AND (PrdBatLcnSih-PrdBatLcnRessih)>0 AND STATUS=1 GROUP BY P.prdid,P.PrdBatID)
		BEGIN  
			INSERT INTO #Tempproductbatch	
			SELECT prdid,MAX(PrdBatId)PrdBatId FROM ProductBatch WHERE PrdId=@Prdid1 AND STATUS=1 GROUP BY prdid
		END  
	 ELSE
		BEGIN 
			INSERT INTO #Tempproductbatch	
			SELECT P.prdid,MIN(P.prdbatid)prdbatid FROM productbatchlocation P INNER JOIN PRODUCTBATCH PB ON P.PRDID=PB.PRDID AND P.PRDBATID=PB.PRDBATID
			 WHERE P.prdid=@Prdid1 AND (PrdBatLcnSih-PrdBatLcnRessih)>0  AND STATUS=1 GROUP BY P.prdid
		END 
	FETCH NEXT FROM Cur_Productbatch INTO  @Prdid1
	END 
	CLOSE Cur_Productbatch
	DEALLOCATE Cur_Productbatch

 	DELETE FROM ProductBatchTaxPercent
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
	
	INSERT INTO Cos2Mob_Productbatch (DistCode,SrpCde,PrdId,PrdBatId,PriceId,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,MRP,ListPrice,SellingPrice,
										SellingPriceWtTax,TaxAmount,StockInHand,UploadFlag)
	SELECT  @DistCode,@Smcode,A.PrdId,A.PrdBatId,DefaultPriceId,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,MRP.PrdBatDetailValue AS MRP,
			ListPrice.PrdBatDetailValue AS ListPrice,SellingRate.PrdBatDetailValue AS SellingRate,
			SUM(SellingRate.PrdBatDetailValue+((SellingRate.PrdBatDetailValue*PBT.TaxPercentage)/100)) SellingRateWithTax,
			(SellingRate.PrdBatDetailValue*PBT.TaxPercentage)/100 AS TaxAmount,ISNULL(sum(PBl.PrdBatLcnSih-PrdBatLcnRessih),0) AS StockOnHand,'N' AS UploadFlag
			FROM ProductBatch A 
			INNER JOIN ProductBatchTaxPercent PBT ON A.PrdId=PBT.PrdId AND A.PrdBatId=PBT.PrdBatId
			LEFT OUTER JOIN ProductBatchLocation PBL ON A.PrdId=PBL.PrdId AND A.PrdBatId=PBL.PrdBatID
			INNER JOIN 
			(SELECT A.PrdId,A.PrdBatId,B.PriceId,B.SLNo,B.PrdBatDetailValue FROM ProductBatch  A INNER JOIN ProductBatchDetails B ON A.PrdBatId=B.PrdBatId AND A.DefaultPriceId=B.PriceId
			INNER JOIN BatchCreation C ON B.SLNo=C.SlNo WHERE B.SLNo=1) AS MRP ON A.PrdId=MRP.PrdId AND A.PrdBatId=MRP.PrdBatId AND A.DefaultPriceId=MRP.PriceId
			INNER JOIN 
			(SELECT A.PrdId,A.PrdBatId,B.PriceId,B.SLNo,B.PrdBatDetailValue FROM ProductBatch  A INNER JOIN ProductBatchDetails B ON A.PrdBatId=B.PrdBatId AND A.DefaultPriceId=B.PriceId
			INNER JOIN BatchCreation C ON B.SLNo=C.SlNo WHERE B.SLNo=2) AS ListPrice ON A.PrdId=ListPrice.PrdId AND A.PrdBatId=ListPrice.PrdBatId AND A.DefaultPriceId=ListPrice.PriceId
			INNER JOIN 
			(SELECT A.PrdId,A.PrdBatId,B.PriceId,B.SLNo,B.PrdBatDetailValue FROM ProductBatch  A INNER JOIN ProductBatchDetails B ON A.PrdBatId=B.PrdBatId AND A.DefaultPriceId=B.PriceId
			INNER JOIN BatchCreation C ON B.SLNo=C.SlNo WHERE B.SLNo=3) AS SellingRate ON A.PrdId=SellingRate.PrdId AND A.PrdBatId=SellingRate.PrdBatId AND A.DefaultPriceId=SellingRate.PriceId
			GROUP BY A.PrdId,A.PrdBatId,DefaultPriceId,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,MRP.PrdBatDetailValue,
			ListPrice.PrdBatDetailValue,SellingRate.PrdBatDetailValue,PBT.TaxPercentage 
			
			SELECT DISTINCT p.PrdId,pbd.PrdBatDetailValue,SUM(PRDBATLCNSIH-PrdBatLcnRessih)stock into #TempStock FROM product P INNER JOIN productbatch pb on p.PrdId=pb.PrdId 
			INNER JOIN productbatchdetails pbd on pb.PrdBatId=pbd.PrdBatId AND pbd.DefaultPrice=1 
			INNER JOIN PRODUCTBATCHLOCATION PBL ON PBL.PRDID=P.PRDID AND PBL.PRDBATID=PB.PRDBATID AND PBL.PRDBATID=PBD.PrdBatId
			WHERE slno=1 AND PB.Status=1 GROUP BY p.PrdId,pbd.PrdBatDetailValue HAVING SUM(PRDBATLCNSIH-PrdBatLcnRessih)>0 ORDER BY P.PrdId
			UPDATE C SET StockInHand=STOCK FROM Cos2Mob_Productbatch C INNER JOIN #TempStock T ON C.PrdId=T.PrdId AND C.MRP=T.PrdBatDetailValue
	
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Bank' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_Bank
GO
--EXEC PROC_ExportPDA_Bank SM1 
CREATE PROCEDURE PROC_ExportPDA_Bank
AS
BEGIN
		DELETE FROM Cos2Mob_Bank --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_Bank (DistCode,SrpCde,BnkId,BnkCode,BnkName,UploadFlag)
		SELECT DistributorCode,SMCODE,BnkId,BnkCode,BnkName,'N' AS UploadFlag FROM Bank 
		CROSS JOIN (SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
		CROSS JOIN Distributor
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_BankBranch' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_BankBranch
GO
--EXEC PROC_ExportPDA_BankBranch SM01
CREATE PROCEDURE PROC_ExportPDA_BankBranch
AS
BEGIN
		DELETE FROM Cos2Mob_BankBranch-- WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_BankBranch (DistCode,SrpCde,BnkId,BnkBrId,BnkBrCode,BnkBrName,BnkBrACNo,DistBank,CoaId,UploadFlag)
		SELECT DistributorCode,SMCODE,BnkId,BnkBrId,BnkBrCode,BnkBrName,BnkBrACNo,DistBank,CoaId,'N' AS UploadFlag 
		FROM BankBranch
		CROSS JOIN (SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
		CROSS JOIN Distributor 
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_CreditNote' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_CreditNote
GO
--EXEC PROC_ExportPDA_CreditNote SM01
CREATE PROCEDURE PROC_ExportPDA_CreditNote
AS
BEGIN
		DELETE FROM Cos2Mob_CreditNote --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_CreditNote (DistCode,SrpCde,CrNo,CrAmount,RtrId,CrAdjAmount,TranNo,Reasonid,UploadFlag)
		SELECT DistributorCode,s.SMCode,CrNoteNumber,Amount,C.RtrId,CrAdjAmount,PostedFrom,ReasonId,'N' AS UploadFlag
		FROM CreditNoteRetailer C
		INNER JOIN RetailerMarket RM on C.RtrId=RM.RtrId
		INNER JOIN SalesmanMarket SM on SM.RMId=RM.RMId
		INNER JOIN Salesman S on S.SMId=SM.SMId
		CROSS JOIN Distributor
		WHERE RM.RMId IN (SELECT RMId FROM Sales_upload ) and (Amount-CrAdjAmount)>0 and C.Status=1
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_DebitNote' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_DebitNote
GO
--EXEC PROC_ExportPDA_DebitNote SM01 
CREATE PROCEDURE PROC_ExportPDA_DebitNote
AS
BEGIN
		DELETE FROM Cos2Mob_DebitNote --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_DebitNote (DistCode,SrpCde,DbNo,DbAmount,RtrId,DbAdjAmount,TransNo,Reasonid,UploadFlag)
		SELECT DistributorCode,S.SMCODE,DbNoteNumber,Amount,D.RtrId,DbAdjAmount,PostedFrom,ReasonId,'N' AS UploadFlag
	    FROM DebitNoteRetailer D
		INNER JOIN RetailerMarket RM on D.RtrId=RM.RtrId
		INNER JOIN SalesmanMarket SM on SM.RMId=RM.RMId
		INNER JOIN Salesman S on S.SMId=SM.SMId
	    CROSS JOIN Distributor 		
	    WHERE RM.RMId IN (SELECT RMId FROM Sales_upload) and (Amount-DbAdjAmount)>0 and D.Status=1
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_RetailerCategoryLevel' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_RetailerCategoryLevel
GO
--EXEC PROC_ExportPDA_RetailerCategoryLevel SM01
CREATE PROCEDURE PROC_ExportPDA_RetailerCategoryLevel
AS
BEGIN
		DELETE FROM Cos2Mob_RetailerCategoryLevel --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_RetailerCategoryLevel (DistCode,CtgLevelId,CtgLevelName,LevelName,UploadFlag)
		SELECT DistributorCode,CtgLevelId,CtgLevelName,LevelName,'N' AS UploadFlag FROM RetailerCategoryLevel
		CROSS JOIN Distributor
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_RetailerCategory' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_RetailerCategory
GO
--EXEC PROC_ExportPDA_RetailerCategory SM01
CREATE PROCEDURE PROC_ExportPDA_RetailerCategory
AS
BEGIN
		DELETE FROM Cos2Mob_RetailerCategory --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_RetailerCategory (DistCode,CtgMainId,CtgLinkId,CtgLevelId,CtgLinkCode,CtgCode,CtgName,UploadFlag)
		SELECT DistributorCode,CtgMainId,CtgLinkId,CtgLevelId,CtgLinkCode,CtgCode,CtgName,'N' AS UploadFlag FROM RetailerCategory 
		CROSS JOIN Distributor
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_RetailerValueClass' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_RetailerValueClass
GO
--EXEC PROC_ExportPDA_RetailerValueClass SM01
CREATE PROCEDURE PROC_ExportPDA_RetailerValueClass
AS
BEGIN
		DELETE FROM Cos2Mob_RetailerValueClass --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_RetailerValueClass (DistCode,RtrClassId,CmpId,CtgMainId,ValueClassCode,ValueClassName,Turnover,UploadFlag)
		SELECT DistributorCode,RtrClassId,CmpId,CtgMainId,ValueClassCode,ValueClassName,Turnover,'N' AS UploadFlag FROM RetailerValueClass 
		CROSS JOIN Distributor
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='Proc_ExportPDA_SchemeNarration' AND XTYPE='P' )
DROP PROCEDURE Proc_ExportPDA_SchemeNarration
GO
--Exec Proc_ExportPDA_SchemeNarration 'SR02'
--SELECT * FROM Cos2Mob_SchemeNarration
CREATE PROCEDURE Proc_ExportPDA_SchemeNarration
AS
DECLARE @Schid AS int
DECLARE @CtgMainId AS int
DECLARE @CtgLevelId AS int 
DECLARE @RtrClassid AS int 
DECLARE @Slabid AS int
DECLARE @Str AS varchar(500)
DECLARE @EveryQty AS numeric(18,4)
DECLARE @DisCper AS numeric(18,4)
DECLARE @Flatamt AS numeric(18,4)
DECLARE @FreeQty AS int 
DECLARE @Count AS int
DECLARE @ForEveryUomId as int
DECLARE @schtype as int
BEGIN

DELETE FROM Cos2Mob_SchemeNarration-- Where UploadFlag='Y'
DECLARE Cur_SchemeMater CURSOR
FOR SELECT Schid,schtype FROM SchemeMaster WHERE SchStatus=1 AND Claimable=1 AND CONVERT(varchar(10),getdate(),121)  
          BETWEEN SchValidFrom AND SchValidtill
OPEN Cur_SchemeMater
FETCH next FROM Cur_SchemeMater INTO @Schid,@schtype
WHILE @@FETCH_status=0
BEGIN 
	DECLARE Cur_SchemeNarration CURSOR
	FOR SELECT DISTINCT ss.SlabId,PurQty,DiscPer,FlatAmt,SF.FreeQty,CASE ForEveryUomId WHEN 0 THEN UOMID ELSE ForEveryUomId END 
	FROM SchemeSlabs SS LEFT  OUTER  JOIN SchemeSlabFrePrds SF
		ON SF.SchId = SS.SchId AND SF.SlabId = SS.SlabId WHERE SS.SchId=@Schid
	SET @Count=0
	OPEN Cur_SchemeNarration
	FETCH next FROM Cur_SchemeNarration INTO @Slabid,@EveryQty,@DisCper,@Flatamt,@FreeQty,@ForEveryUomId
	WHILE @@FETCH_status=0
	BEGIN 
	IF @Count=0
		BEGIN 
			SET @Str='Scheme Applicable-For Purchase of Every  '+ Cast(@EveryQty AS varchar(15)) + 
			CASE @schtype when 1 then (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
					WHEN 2 THEN ' RS'
					WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
			END
	
			 IF @DisCper>0.00
			  BEGIN   
					SET @Str=@Str +' '+ Cast(@DisCper AS varchar(15)) +''+ '%' +'  Discount'
			  END 	 
			 IF @Flatamt>0.00
			  BEGIN
					SET @Str=@Str + ' '+ Cast(@Flatamt AS varchar(15)) +''+ 'FlatAmount' +''
			  END 
			 IF @FreeQty>0.00
			  BEGIN
					SET @Str=@Str + ' '+ Cast(@FreeQty AS varchar(15)) +' Quantity Free'
			  END 
			END
	ELSE
		 BEGIN 
			SET @Str=@Str +' And For Purchase of Every  '+ Cast(@EveryQty AS varchar(15)) + 
				CASE @schtype WHEN 1 THEN (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
							  WHEN 2 THEN ' RS'
					          WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
			end
		 IF @DisCper>0.00
			  BEGIN   
					SET @Str=@Str +' '+ Cast(@DisCper AS varchar(15)) +''+ '%' +'  Discount'
			  END 	 
			 IF @Flatamt>0.00
			  BEGIN
					SET @Str=@Str + ' '+ Cast(@Flatamt AS varchar(15)) +''+ 'FlatAmount' +''
			  END 
			 IF @FreeQty>0.00
			  BEGIN
					SET @Str=@Str + ' '+ Cast(@FreeQty AS varchar(15)) +' Quantity Free'
			  END 
		END 
	SET @Count=1
	FETCH next FROM Cur_SchemeNarration INTO @Slabid,@EveryQty,@DisCper,@Flatamt,@FreeQty,@ForEveryUomId
	END 
	CLOSE Cur_SchemeNarration
	DEALLOCATE Cur_SchemeNarration
	
	INSERT INTO Cos2Mob_SchemeNarration (DistCode,SrpCde,Channel,SubType,CmpSchCode,Schdesc,Narration,UploadFlag,ChannelCode,RtrClassId)
		SELECT DistributorCode,SM.SMCode,RC.CtgName,RVC.ValueClassName,CmpSchCode,SchDsc, cast(@Str AS varchar(500)),'N' AS UploadFlag,RC.CtgCode,RVC.RtrClassId
		FROM SchemeMaster S INNER JOIN SchemeRetAttr SR ON S.SchId=SR.SchId
		INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId=CASE SR.AttrId WHEN 0 THEN RVC.RtrClassId ELSE SR.AttrId END AND SR.AttrType=6
		INNER JOIN RetailerCategory RC ON RC.CtgMainId=RVC.CtgMainId  
		CROSS JOIN (SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) SM
		CROSS JOIN Distributor
		WHERE   S.SchId=@Schid
		
FETCH next FROM Cur_SchemeMater INTO @Schid,@schtype
END 
CLOSE Cur_SchemeMater
DEALLOCATE Cur_SchemeMater
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_PendingBills' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_PendingBills
GO
--EXEC PROC_ExportPDA_PendingBills Sm01
CREATE PROCEDURE PROC_ExportPDA_PendingBills
AS
BEGIN

DECLARE @FromDate AS DATETIME
DECLARE @ToDate AS DATETIME

	SELECT @FromDate=dateadd(MM,-3,getdate())
	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)
	
	DELETE FROM Cos2Mob_PendingBills --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_PendingBills (DistCode,SrpCde,Salid,SalInvNo,SalInvDte,RtrId,TotalInvoiceAmount,PaidAmount,BalanceAmount,UploadFlag)
	SELECT DistributorCode,SMCode,SalId,SalInvNo,SalInvDate,RtrId,SalNetAmt,SalPayAmt,(SalNetAmt-SalPayAmt) AS BalanceAmount,'N' AS UploadFlag
	FROM SalesInvoice S INNER JOIN SalesMan SM ON S.SMID=SM.SMId CROSS JOIN Distributor
	WHERE S.DlvSts >3 AND SM.SMId IN(SELECT SMId FROM Sales_upload) and (SalNetAmt-SalPayAmt)>0
	AND SalInvDate  BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121)
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='PROC_ExportPDA_SchemeProductDetails' AND XTYPE='P' )
DROP PROCEDURE PROC_ExportPDA_SchemeProductDetails
GO
--Exec PROC_ExportPDA_SchemeProductDetails 'DS01'
CREATE PROCEDURE PROC_ExportPDA_SchemeProductDetails
AS
BEGIN
	DELETE FROM Cos2Mob_SchemeProductDetails -- Where UploadFlag='Y'
	
	INSERT INTO Cos2Mob_SchemeProductDetails(DistCode,SrpCde,CmpschCode,SchDsc,Prdcode,Prdname,UploadFlag)
	SELECT DistributorCode,SMCODE,CmpSchCode,SchDsc,PrdCCode,PrdName,'N' as UploadFlag FROM 
		(
		SELECT CmpSchCode,SchDsc,PrdCCode,PrdName FROM SchemeMaster SM 
			INNER JOIN SchemeProducts SP ON SM.SchId=SP.SchId 
			INNER JOIN ProductCategoryValue PC ON PC.PrdCtgValMainId=SP.PrdCtgValMainId
			INNER JOIN TBL_GR_BUILD_PH T ON PC.PrdCtgValMainId=CASE PC.CmpPrdCtgId WHEN 2 THEN Category_Id
																	WHEN 3 THEN Taste_Id
																	WHEN 4 THEN Brand_Id
																	WHEN 4 THEN Pack_Id
																	
																	END 			
			INNER JOIN Product P ON P.PrdId=T.PrdId  
		WHERE SchStatus=1  AND CONVERT(varchar(10),getdate(),121)  BETWEEN SchValidFrom AND SchValidtill	
	  UNION ALL
  		SELECT CmpSchCode,SchDsc,PrdCCode,PrdName FROM SchemeMaster SM 
			INNER JOIN SchemeProducts SP ON SM.SchId=SP.SchId 
			INNER JOIN Product P ON P.PrdId=SP.PrdId
		WHERE SchStatus=1 AND CONVERT(varchar(10),getdate(),121)  BETWEEN SchValidFrom AND SchValidtill
        )A
		CROSS JOIN (SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
		CROSS JOIN Distributor
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='PROC_ExportPDA_ReasonMaster' AND XTYPE='P' )
DROP PROCEDURE PROC_ExportPDA_ReasonMaster
GO
--Exec PROC_ExportPDA_ReasonMaster 'KS'
CREATE PROCEDURE PROC_ExportPDA_ReasonMaster
AS
BEGIN
	DELETE FROM Cos2Mob_ReasonMaster --Where UploadFlag='Y'
	INSERT INTO Cos2Mob_ReasonMaster (DistCode,SrpCde,ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
										DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,
										StkTransferScreen,BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,
										NonBilled,UploadFlag)
	 SELECT DistributorCode,SMCODE,ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
			DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,
			StkTransferScreen,BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,1 as NonBilled, 'N' AS UploadFlag
			FROM ReasonMaster 
			CROSS JOIN (SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
			CROSS JOIN Distributor
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_IMPORT_PRODUCTPDA_ORDERBOOKING' AND XTYPE='P')
DROP PROCEDURE PROC_IMPORT_PRODUCTPDA_ORDERBOOKING
GO
--exec PROC_IMPORT_PRODUCTPDA_ORDERBOOKING 'SSM5'
CREATE PROCEDURE PROC_IMPORT_PRODUCTPDA_ORDERBOOKING
(            
	@SalRpCode varchar(50)      
)      
AS      
/*********************************/      
DECLARE @SQL AS nvarchar(3000)      
DECLARE @OPSQL AS nvarchar(3000)      
DECLARE @DelSQL AS varchar(1000)      
DECLARE @InsSQL AS varchar(5000)      
DECLARE @UpdSQL AS varchar(1000)      
DECLARE @UpdFlgSQL AS varchar(1000)      
DECLARE @OrdKeyNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT      
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @RtrShipId AS INT
DECLARE @OrdPrdCnt AS INT
DECLARE @PdaOrdPrdCnt AS INT
DECLARE @OrderDate AS DateTime
DECLARE @SeqNo AS int 
Declare @Psql as varchar(8000)
DECLARE @LAUdcMasterId AS VARCHAR(50)
DECLARE @LOUdcMasterId AS VARCHAR(50)
DECLARE @Longitude AS VARCHAR(50)
DECLARE @Latitude AS VARCHAR(50)
DECLARE @PError AS INT
BEGIN
	BEGIN TRANSACTION T1
	DELETE FROM ImportPDA_OrderBooking WHERE UploadFlag='Y'
	DELETE FROM ImportPDA_OrderBookingProduct WHERE UploadFlag='Y'
	DELETE FROM PDALOG WHERE DataPoint='ORDERBOOKING'
	
 IF  EXISTS(SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)
 BEGIN  	
	SET @SrpId = (SELECT SMId FROM SalesMan Where SMCode = @SalRpCode)
	DECLARE CUR_Import CURSOR FOR
	SELECT DISTINCT OrdKeyNo   From ImportPDA_OrderBooking  
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo 
	While @@Fetch_Status = 0
	BEGIN
		SET @OrdPrdCnt=0
		SET @PdaOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0
		
		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking WHERE DocRefNo = @OrdKeyNo)
		BEGIN
			SET @RtrId = (Select RtrId FROM ImportPDA_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@RtrId,'Retailer Does Not Exists for the Order ' + @OrdKeyNo 
			END
			
			SELECT @RtrShipId=RS.RtrShipId FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid 
			WHERE RtrShipDefaultAdd=1  AND R.RtrId=@RtrId  
			
			SET @MktId = (Select MktId FROM ImportPDA_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			
			IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Does Not Exists for the Order ' + @OrdKeyNo 
			END
			
			IF NOT EXISTS (SELECT * FROM SalesManMarket WHERE RMID = @MktId AND SMID = @SrpId)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Not Maped with the Salesman for the Order ' + @OrdKeyNo  
			END
			
			IF NOT EXISTS(SELECT OrdKeyNo FROM  ImportPDA_OrderBookingProduct WHERE OrdKeyNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Product Details Not Exists for the Order ' + @OrdKeyNo 
			END
			
			IF @lError=0
			BEGIN
				
				DECLARE @CNT AS INT
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @OrdQty AS INT
		        SET @CNT=0
				DECLARE CUR_ImportOrderProduct CURSOR FOR
				SELECT DISTINCT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  From ImportPDA_OrderBookingProduct WHERE OrdKeyNo=@OrdKeyNo GROUP BY PrdId,PrdBatId,PriceId
				OPEN CUR_ImportOrderProduct
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
						SET @PError = 0
						IF NOT EXISTS(SELECT PrdId From Product WHERE Prdid=@Prdid)
						BEGIN
							SET @PError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdid,' Product Does Not Exists for the Order ' + @OrdKeyNo  
						END
						
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @PError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdbatid,' Product Batch Does Not Exists for the Order ' + @OrdKeyNo  
						END
						
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @PError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@PriceId,' Product Batch Price Does Not Exists for the Order ' + @OrdKeyNo  
						END
						
						IF @OrdQty<=0
						BEGIN
							SET @PError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdQty,' Ordered Qty Should be Greater than Zero for the Order ' + @OrdKeyNo  
						END
						
						IF @PError=0
						BEGIN
							SET @CNT=@CNT+1
						END 
						
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				END
				CLOSE CUR_ImportOrderProduct
				DEALLOCATE CUR_ImportOrderProduct
				
			SET @GetKeyStr=''  
			SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('OrderBooking','OrderNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
				IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
				BEGIN  
					SET @lError = 1
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Ordered Key No not generated'  
					BREAK  
				END
			IF @lError = 0 AND @CNT>0
			BEGIN
				--HEDER 
					SELECT  @OrderDate= OrdDt FROM ImportPDA_OrderBooking WHERE  OrdKeyNo=@OrdKeyNo
					INSERT INTO OrderBooking(  
					OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,RtrId,OrdType,  
					Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,RndOffValue,TotalAmount,Status,  
					Availability,LastModBy,LastModDate,AuthId,AuthDate,PDADownLoadFlag,Upload)  
					SELECT @GetKeyStr,Convert(DateTime,@OrderDate,121),  
					Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					0,@OrdKeyNo,0, @SrpId as Smid,  
					@MktId as RmId,@RtrId as RtrId,0 as OrdType,0 as Priority,0 as FillAllPrd,0 as ShipTo,  
					@RtrShipId as RtrShipId,'' as Remarks,0  as RoundOff,0 as RndOffValue,  
					0 as TotalAmount,0 as Status,1,1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),1,0
					
					SELECT @Longitude=ISNULL(Longitude,0),@Latitude =ISNULL(Latitude,0) FROM ImportPDA_OrderBooking WHERE  OrdKeyNo=@OrdKeyNo 
					SELECT @LAUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Latitude'
                    SELECT @LOUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Longitude'
					UPDATE UdcDetails SET ColumnValue=@Latitude WHERE UdcMasterId=@LAUdcMasterId AND MasterRecordId=@RtrId
					UPDATE UdcDetails SET ColumnValue=@Longitude WHERE UdcMasterId=@LOUdcMasterId AND MasterRecordId=@RtrId
					
				 --DETAILS 
		    INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,ConvFact2,TotalQty,BilledQty,Rate,
					                          MRP,GrossAmount,PriceId,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
			SELECT @GetKeyStr ,Prdid,Prdbatid,UomID,OrdQty,ConversionFactor,0,0,0,OrdQty,0,
			SUM(Rate)Rate ,SUM(MRP)MRP,sum(GrossAmount)GrossAmount,sum(PriceId)PriceId,
			1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
			1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121) 
			FROM ( 
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			PBD.PrdBatDetailValue Rate,0 as Mrp,(PBD.PrdBatDetailValue*OrdQty) as GrossAmount,PBD.PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT I.PrdId,PrdBatId,PriceId,Sum(OrdQty*ConversionFactor) as OrdQty  FROM ImportPDA_OrderBookingProduct I 
				INNER JOIN Product P ON P.PrdId=I.PRDID
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId WHERE OrdKeyNo=  @OrdKeyNo 
				GROUP BY i.PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId  
			and BC.slno=PBD.SLNo AND BC.SelRte=1  and PBD.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y' 
		UNION ALL
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			0 Rate,PBD1.PrdBatDetailValue as Mrp,0 as GrossAmount,0 as PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT I.PrdId,PrdBatId,PriceId,Sum(OrdQty*ConversionFactor) as OrdQty  FROM ImportPDA_OrderBookingProduct I 
				INNER JOIN Product P ON P.PrdId=I.PRDID
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId WHERE OrdKeyNo=  @OrdKeyNo  
			 GROUP BY I.PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC1 (NOLOCK) ON BC1.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD1.PriceId  
			and BC1.slno=PBD1.SLNo AND BC1.MRP=1  and PBD1.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y')A
			GROUP BY Prdid,Prdbatid,UomID,OrdQty,ConversionFactor
			 
		  UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  
		  FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X  ON X.OrderNo=OB.OrderNo   
			  
		  SELECT DISTINCT SrpCde,OrdKeyNo,PrdId,PrdBatId  INTO #TEMPCHECK   
		  FROM ImportPDA_OrderBookingProduct WHERE OrdKeyNo=@OrdKeyNo
					
		SELECT @OrdPrdCnt=ISNULL(Count(PRDID),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
		SELECT @PdaOrdPrdCnt=ISNULL(Count(PRDID),0) FROM #TEMPCHECK (NOLOCK) WHERE OrdKeyNo=@OrdKeyNo
		
		IF @OrdPrdCnt=@PdaOrdPrdCnt  
		BEGIN 
			UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
			UPDATE ImportPDA_OrderBooking SET UploadFlag = 'Y' Where SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo = @OrdKeyNo
			UPDATE ImportPDA_OrderBookingProduct SET UploadFlag = 'Y' Where SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo =@OrdKeyNo 
		END
		ELSE
		BEGIN
			SET @lError = 1
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT @SalRpCode,'ORDERBOOKING',@OrdKeyNo,' Ordered Product Number of line count not match for the Order ' + @OrdKeyNo
			DELETE FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr  
			DELETE FROM ORDERBOOKING WHERE OrderNo=@GetKeyStr  
		END 
			DROP TABLE #TEMPCHECK
				END
			END
		END
		ELSE
		BEGIN
			Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'ORDERBOOKING'
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,'Order Already exists'
		END
		
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo 
	END
	Close CUR_Import
	DeAllocate CUR_Import
   EXEC PROC_PDASALESMANDETAILS @SalRpCode
  END
ELSE
	BEGIN
			 INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			 SELECT '' + @SalRpCode + '','ORDERBOOKING',@SalRpCode,'SalesMan Does not exists for Srno' + @OrdKeyNo 
	END 
	
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
IF EXISTS (SELECT * FROM SYSOBJECTS  WHERE NAME='PROC_IMPORT_PRODUCTPDA_SALESRETURN' AND XTYPE='P')
DROP PROCEDURE PROC_IMPORT_PRODUCTPDA_SALESRETURN
GO
--EXEC PROC_IMPORT_ProductPDA_SALESRETURN 'Smo1'
CREATE PROCEDURE PROC_IMPORT_ProductPDA_SALESRETURN
(      
 @SalRpCode varchar(50)      
)      
AS      
DECLARE @SQL AS nvarchar(3000)      
DECLARE @OPSQL AS nvarchar(3000)      
DECLARE @DelSQL AS varchar(1000)      
DECLARE @InsSQL AS varchar(5000)      
DECLARE @UpdSQL AS varchar(1000)      
DECLARE @UpdFlgSQL AS varchar(1000)      
DECLARE @SrNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT    
DECLARE @SalInvNo AS nVarchar(50)
DECLARE @Salid AS INT  
DECLARE @Reasonid AS int       
BEGIN      
 BEGIN TRANSACTION T1      
		DELETE FROM ImportProductPDA_SalesReturn WHERE uploadflag='Y'
		DELETE FROM ImportProductPDA_SalesReturnProduct WHERE uploadflag='Y'
		DELETE FROM PDALog where DataPoint='SALESRETURN'
 IF  EXISTS(SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)
 BEGIN  
		 SET @SrpId = (SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)      
				
		 DECLARE CUR_Import Cursor For      
		 Select Distinct SrNo From ImportProductPDA_SalesReturn   WHERE uploadflag='N'         
		 OPEN CUR_Import      
		 FETCH NEXT FROM CUR_Import INTO @SrNo      
		 While @@Fetch_Status = 0      
		 BEGIN      
		  SET @lError = 0
		  SET @SalInvNo	=''
		  SET @RtrId=0
		  SET @MktId=0
		  SET @SalId=0	
		  SET @Reasonid=0
		
		  IF NOT EXISTS (SELECT DocRefNo FROM ReturnHeader WHERE DocRefNo = @SrNo)      
		  BEGIN      
		  
			   SET @RtrId = (Select RtrId FROM ImportProductPDA_SalesReturn WHERE SrNo = @SrNo)       
			   IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE Rtrid = @RtrId and RtrStatus = 1)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@RtrId,'Retailer Does Not Exists for the SalesReturn No ' + @SrNo 
			   END      
		      
			   SET @MktId = (Select MktId FROM ImportProductPDA_SalesReturn WHERE SrNo = @SrNo)       
			   IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Does Not Exists for the SalesReturn No ' + @SrNo 
			   END      
		      
			   IF NOT EXISTS (SELECT RMId,SMId FROM SalesManMarket WHERE RMId = @MktId AND SMId = @SrpId)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Not Maped with the DBSR for the SalesReturn No ' + @SrNo  
			   END
			   
				IF EXISTS(SELECT SalInvNo FROM ImportProductPDA_SalesReturn WHERE SrNo = @SrNo and InvoiceType=1)
				BEGIN
					SELECT @SalInvNo=ISNULL(SalInvNo,'') FROM ImportProductPDA_SalesReturn WHERE SrNo = @SrNo and InvoiceType=1
					IF LEN(@SalInvNo)=0 
					BEGIN
						SET @lError = 1      
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
						SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Reference Invoice not exist for the SalesReturn No' + @SrNo 
					END
					ELSE IF NOT EXISTS(SELECT SalId From SalesInvoice WHERE Salinvno=@SalInvNo)
					BEGIN
						SET @lError = 1      
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
						SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Reference  SalesInvoice not exist for the SalesReturn No' + @SrNo 
					END
				END
				IF NOT EXISTS(SELECT SrNo FROM  ImportProductPDA_SalesReturnProduct WHERE SrNo=@SrNo)
				BEGIN
					SET @lError = 1
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Product Details Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
				END
			IF @lError=0
			BEGIN
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @RtnQty AS INT
				DECLARE @StockType AS INT
				DECLARE @SalinvnoRef AS nVarchar(50)
				DECLARE @UsrStkTyp AS INT
				DECLARE @Slno AS INT
				DECLARE CUR_ImportReturnProduct CURSOR FOR
				SELECT PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,SlNo,Reasonid From ImportProductPDA_SalesReturnProduct WHERE SrNo=@SrNo  ORDER BY SlNo 
				OPEN CUR_ImportReturnProduct
				FETCH NEXT FROM CUR_ImportReturnProduct INTO @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno,@Reasonid
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
						IF NOT EXISTS(SELECT PrdId From Product (NOLOCK) WHERE Prdid=@Prdid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdid,' Product Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdbatid,' Product Batch Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@PriceId,' Product Batch Price Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						
						IF @RtnQty<=0
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Return Qty Should be Greater than Zero for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						
			IF @UsrStkTyp=2 
				BEGIN 
						IF NOT EXISTS (SELECT * FROM ReasonMaster WHERE ReasonId=@Reasonid)
						   BEGIN      
							SET @lError = 1      
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
							SELECT '' + @SalRpCode + '','SALESRETURN',@Reasonid,'Reasonid does not exists for the SalesReturn No ' + @SrNo  
						   END	
				END 		
				
				FETCH NEXT FROM CUR_ImportReturnProduct INTO  @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno,@Reasonid
				END
				CLOSE CUR_ImportReturnProduct
				DEALLOCATE CUR_ImportReturnProduct
		 
					IF @lError = 0       
					BEGIN
						--HEADER	   
						INSERT INTO PDA_SalesReturn (SrNo,SrDate,SalInvNo,RtrId,Mktid,Srpid,ReturnMode,InvoiceType,Status)
						SELECT SrNo,Getdate(),SalInvNo,RtrId,Mktid,@SrpId,ReturnMode,InvoiceType,0
						FROM ImportProductPDA_SalesReturn WHERE SrNo=@SrNo
						
						--DETAILS
						INSERT INTO PDA_SalesReturnProduct(SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo)
						SELECT @SrNo,PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,isnull(SlNo,0) From ImportProductPDA_SalesReturnProduct  
						WHERE SrNo=@SrNo
						
						UPDATE ImportProductPDA_SalesReturn SET UploadFlag = 'Y' Where SrpCde = @SalRpCode and UploadFlag = 'N' AND SrNo =  @SrNo       
					  
						UPDATE ImportProductPDA_SalesReturnProduct SET UploadFlag = 'Y' Where SrpCde = @SalRpCode and UploadFlag = 'N' AND SrNo =@SrNo      
	     
					END 
			END      
		  END      
		  ELSE      
		  BEGIN      
			   Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'SALESRETURN'      
			   INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			   SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Sales Return Already exists for Srno' + @SrNo     
		  END       
		FETCH NEXT FROM CUR_Import INTO @SrNo      
		END      
		CLOSE CUR_Import      
		DEALLOCATE CUR_Import     
END
ELSE
BEGIN
		 INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
		 SELECT '' + @SalRpCode + '','SALESRETURN',@SalRpCode,'SalesMan Does not exists for Srno' + @SrNo 
END 
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='PDA_NewRetailer' AND XTYPE='U')
DROP TABLE PDA_NewRetailer
GO
CREATE TABLE PDA_NewRetailer
(
	[CustomerCode] [varchar](200) NULL,
	[CustomerName] [varchar](200) NULL,
	[Address1] [varchar](200) NULL,
	[Address2] [varchar](200) NULL,
	[Address3] [varchar](200) NULL,
	[City] [varchar](100) NULL,
	[State] [varchar](150) NULL,
	[Zip] [varchar](50) NULL,
	[Phone] [varchar](100) NULL,
	[Fax] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[RtrTINNo] [varchar](100) NULL,
	[ContactPerson] [varchar](200) NULL,
	[Notes] [varchar](500) NULL,
	[CustomerStatus] [int] NULL,
	[CtgCode] [varchar](100) NULL,
	[CtgName] [varchar](200) NULL,
	[ValueClassCode] [varchar](100) NULL,
	[ValueClassName] [varchar](200) NULL,
	[RtrClassid] [int] NULL,
	[CtgMainid] [int] NULL,
	[CtgLinkid] [int] NULL,
	[CtgLevelId] [int] NULL,
	[CtgLinkCode] [varchar](100) NULL,
	[CtgLevelName] [varchar](100) NULL,
	[Cmpid] [int] NULL,
	[CmpName] [varchar](200) NULL,
	[CrBills] [int] NULL,
	[RtrTaxable] [varchar](1) NULL,
	[RouteId] [int] NULL,
	[GeoMainId] [int] NULL,
	[GeoLevelName] [nvarchar](20) NULL,
	[GeoLevel] [nvarchar](20) NULL,
	[Longitude] [varchar](50) NULL,
	[Latitude] [varchar](50) NULL,
	[RtrMobileNo] [NVARCHAR](100) 
)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE = 'P' AND name = 'Proc_Import_PDA_NewRetailer')
DROP PROCEDURE Proc_Import_PDA_NewRetailer
GO
/*
BEGIN TRAN
Exec Proc_Import_PDA_NewRetailer  '1'
Select * from Pdalog (Nolock)
Select * from Pda_NewRetailer
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[Proc_Import_PDA_NewRetailer]
(      
 @SalRpCode varchar(50) )      
AS    
DECLARE @CustomerCode AS varchar(200) 
DECLARE @CustomerName AS varchar(200)
DECLARE @CtgMainID AS int
DECLARE @RtrClassId AS int
DECLARE @lError AS int
DECLARE @Ctgcode AS nvarchar(200)
DECLARE @ValueClassCode AS nvarchar(200)
DECLARE @CtgLinkid int 
DECLARE @CtgLevelId int
DECLARE @CtgLinkCode AS nvarchar(200)
DECLARE @CtgLevelName AS nvarchar(200)
DECLARE @Cmpid int 
DECLARE @CmpName AS nvarchar(200)
DECLARE @SQL AS NVARCHAR(1000)
DECLARE @UpdOPFlgSQL as nvarchar(1000)
DECLARE @CtgName as nvarchar(100)
DECLARE @ValueClassName as nvarchar(50)
BEGIN      
 BEGIN TRANSACTION T1      
 DELETE FROM ImportProductPDA_NewRetailer WHERE UploadFlag='Y'   
--ADDED BY PRAVEENRAJ BHASKARAN FOR AMUL SFA ON 10/04/2014	
DECLARE @TmpRetailerCategory TABLE 
(
	[RtrClassId] int ,
	[ValueClassCode] nvarchar(20) ,
	[Group Code] nvarchar(20) ,
	[Group Name] nvarchar(50) ,
	[Channel Code] nvarchar(20) ,
	[Channel Name] nvarchar(50) ,
	[GroupId] int ,
	[ChannelId] int 
)
	INSERT INTO @TmpRetailerCategory (RtrClassId,ValueClassCode,[Group Code],[Group Name],[Channel Code],[Channel Name],[GroupId],ChannelId)
	SELECT DISTINCT V.RtrClassId,V.ValueClassCode,C1.CtgCode [Group Code],C1.CtgName [Group Name],
	C2.CtgCode [Channel Code],C2.CtgName [Channel Name],C1.CtgMainId [GroupId],C2.CtgMainId AS ChannelId		
	FROM RetailerValueClass V (NOLOCK) 
	INNER JOIN (Select B.CtgLinkId,B.CtgMainId,B.CtgCode,B.CtgName from RetailerCategoryLevel A (NOLOCK) INNER JOIN RetailerCategory B (NOLOCK) ON A.CtgLevelId=B.CtgLevelId Where A.CtgLevelId=2) C1
	ON C1.CtgMainId=V.CtgMainId
	INNER JOIN (Select B.CtgLinkId,B.CtgMainId,B.CtgCode,B.CtgName from RetailerCategoryLevel A (NOLOCK) INNER JOIN RetailerCategory B (NOLOCK) ON A.CtgLevelId=B.CtgLevelId Where A.CtgLevelId=1) C2
	ON C1.CtgLinkId=C2.CtgMainId
	
--END HERE
 DECLARE CUR_ImportRetailer Cursor For      
 SELECT DISTINCT RtrCode,RetailerName,CtgMainID,RtrClassId 
		From ImportProductPDA_NewRetailer WHERE UploadFlag='N' 
		
 OPEN CUR_ImportRetailer      
 FETCH NEXT FROM CUR_ImportRetailer INTO  @CustomerCode,@CustomerName,@CtgMainID,@RtrClassId
 While @@Fetch_Status = 0      
 BEGIN      
  SET @lError = 0

	
  IF NOT EXISTS (SELECT RtrCode FROM Retailer WHERE RtrCode = @CustomerCode )      
   BEGIN
		SELECT @CtgMainID=GroupId FROM @TmpRetailerCategory WHERE RtrClassId=@RtrClassId   
		IF NOT EXISTS(SELECT * FROM RetailerCategory WHERE CtgMainId=@CtgMainID )
		BEGIN
			SET @lError = 1      
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			SELECT '' + @CustomerCode + '','New Retailer',@CustomerCode,'Reatailer category does not exists'  
		END
		IF NOT EXISTS(SELECT * FROM RetailerValueClass WHERE RtrClassId= @RtrClassId )
		BEGIN
			SET @lError = 1      
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			SELECT '' + @CustomerCode + '','New Retailer',@RtrClassId,'Reatailer Class does not exists'  
		END
		IF NOT EXISTS(SELECT * FROM RetailerValueClass WHERE CtgMainId=@CtgMainID and RtrClassId= @RtrClassId )
		BEGIN
			SET @lError = 1      
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			SELECT '' + @CustomerCode + '','New Retailer',@RtrClassId,'Reatailer Class does not belong to the selected category'  
		END
	IF @lError=0 
	 BEGIN 
		Select @ValueClassCode=A.ValueClassCode,
			   @CtgLinkid=B.CtgLinkId,
			   @CtgLevelId=B.CtgLevelId,
			   @CtgLinkCode=B.CtgLinkCode,
			   @Ctgcode=B.CtgCode,
			   @CtgLevelName=C.CtgLevelName,
			   @Cmpid=C.CmpId,
			   @CmpName=D.CmpName,
			   @CtgName=B.CtgName,
			   @ValueClassName=A.ValueClassName 
			FROM RetailerValueClass A,RetailerCategory B,RetailerCategoryLevel C,Company D 
			WHERE A.CtgMainId=B.CtgMainId And B.CtgLevelId=C.CtgLevelId And C.CmpId=D.CmpId
			AND A.CtgMainId=@CtgMainID AND A.RtrClassId=@RtrClassId
	 END 		
IF @lError=0 
		BEGIN
		
		  IF NOT EXISTS (SELECT * FROM PDA_NewRetailer WHERE CustomerCode=@CustomerCode)
           BEGIN 
				INSERT INTO PDA_NewRetailer 
				SELECT RtrCode,RetailerName,isnull(RtrAdd1,'')Address1,isnull(RtrAdd2,'')Address2,
				isnull(RtrAdd3,'')Address3,''as City,'' as State,'' as Zip,
				isnull(RtrPhoneNo,'')Phone,'' as Fax,'' as Email,isnull(RtrTINNo,''),'' as ContactPerson,
				'' as Notes,1 as CustomerStatus,@Ctgcode,isnull(@CtgName,'')CategoryCode1,
				@ValueClassCode,@ValueClassName,@RtrClassid,@CtgMainid,@CtgLinkid,@CtgLevelId,@CtgLinkCode,
				@CtgLevelName,@Cmpid,@CmpName,0 AS CrBills,'' RtrTaxable,'' RouteId,'' GeoMainId,'' GeoLevelName,
				''GeoLevel,ISNULL(Longitude,0),ISNULL(Latitude,0),ISNULL(RtrMobileNo,'')
				FROM ImportProductPDA_NewRetailer WHERE RtrCode=@CustomerCode
		   END 	
				UPDATE ImportProductPDA_NewRetailer SET UploadFlag='Y' WHERE RtrCode=@CustomerCode
  	    END 
   END      
  ELSE      
    BEGIN      
	   INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
	   SELECT '' + @CustomerCode + '','New Retailer',@CustomerCode,'Retailer Code Already exists'      
    END       
FETCH NEXT FROM CUR_ImportRetailer INTO @CustomerCode,@CustomerName,@CtgMainID,@RtrClassId
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
IF EXISTS (SELECT * FROM sysobjects WHERE name='PDA_ReceiptInvoice' AND xtype='U')
DROP TABLE PDA_ReceiptInvoice
GO
CREATE TABLE PDA_ReceiptInvoice
(
	[SrpCde] [varchar](50) NULL,
	[ReceiptNo] [nvarchar](100) NULL,
	[BillNumber] [nvarchar](40) NULL,
	[ReceiptDate] [datetime] NULL,
	[InvoiceAmount] [float] NULL,
	[Balance] [float] NULL,
	[ChequeNumber] [nvarchar](16) NULL,
	[CashAmount] [float] NULL,
	[ChequeAmount] [float] NULL,
	[DiscAmount] [float] NULL,
	[BankId] [int] NULL,
	[BranchId] [int] NULL,
	[ChequeDate] [datetime] NULL,
	[InvRcpMode] [int] NULL,
	[DistBank] [int] NULL,
	[DistBankBranch] [int] NULL,
	[CrNoteNo] [varchar](50) NULL,
	[DbNoteNo] [varchar](50) NULL,
	[CrAmt] [numeric](18, 2) NULL,
	[DbAmt] [numeric](18, 2) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_IMPORT_PRODUCTPDA_Collection' AND XTYPE ='P')
DROP PROCEDURE PROC_IMPORT_PRODUCTPDA_Collection
GO
--exec PROC_IMPORT_PRODUCTPDA_Collection 'SR01'
CREATE PROCEDURE PROC_IMPORT_PRODUCTPDA_Collection
(
 @SalRpCode varchar(50)      
)
AS
BEGIN
/*invrcpmode
	Cash 1
	Cheque 3
	Credit note 5
*/
DECLARE @lError AS INT        
DECLARE @InvRcpNo AS NVARCHAR(25)
DECLARE @InvRcpDate AS DATETIME
DECLARE @Amount AS NUMERIC(18,2)
DECLARE @Salid AS INT
DECLARE @Salinvno AS VARCHAR(25)
DECLARE @Salinvdate AS DATETIME
DECLARE @PendingAmt AS NUMERIC(18,2)
DECLARE @InvRcpMode as int
DECLARE @AvailAmt as numeric(18,2)
DECLARE @BnkBrId as int
DECLARE @BnkId as int
DECLARE @InvInsNo as nvarchar(100)
DECLARE @DistBank as INT
DECLARE @DistBranch AS INT
DECLARE @InvRcpNoT AS NVARCHAR(25)

CREATE  TABLE #PDA_ReceiptInvoiceSplitActual
(
Salid int,
InvRcpNo nvarchar(25),
Salinvno varchar(50),
Salinvdate datetime,
invrcpdate datetime,
CollectionAmt numeric(18,2),
InvinsNo nvarchar(200),
BnkBrid int,
InvRcpMode int
)

	DELETE FROM ImportProductPDA_CreditNote WHERE uploadflag='Y'
	DELETE FROM ImportProductPDA_Receiptinvoice WHERE uploadflag='Y'
	DELETE FROM PDALog where DataPoint='COLLECTION'
		
 IF  EXISTS(SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)
 BEGIN  	
 DECLARE Cur_CollectionTotal cursor
	FOR SELECT DISTINCT InvRcpNo  from ImportProductPDA_Receiptinvoice
	OPEN Cur_CollectionTotal
	FETCH NEXT FROM Cur_CollectionTotal INTO @InvRcpNoT 
	WHILE @@FETCH_STATUS = 0
	BEGIN
 			DECLARE Cur_Collection cursor
			FOR Select InvRcpNo,InvRcpDate,Amount,InvRcpMode,BnkBrId,invinsno from 
			(SELECT DISTINCT InvRcpNo,InvRcpDate,CashAmt AS Amount,1 as InvRcpMode,0 as BnkBrId,'' as invinsno FROM ImportProductPDA_Receiptinvoice  where invrcpno=@InvRcpNoT AND cashamt>0
			UNION
				SELECT DISTINCT InvRcpNo,InvRcpDate,ChequeAmt as AMount,3 as Invrcpmode,BnkBrId,invinsno FROM ImportProductPDA_Receiptinvoice where invrcpno=@InvRcpNoT AND chequeamt>0)A
				order by InvRcpNo,InvRcpMode Asc
			OPEN Cur_Collection
			FETCH NEXT FROM Cur_Collection INTO @InvRcpNo,@InvRcpDate,@Amount,@InvRcpMode,@BnkBrId,@InvInsNo
			WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @lError = 0 
			
				--IF EXISTS(SELECT * FROM ImportProductPDA_Receiptinvoice I WHERE NOT EXISTS(
				--SELECT SalInvNo from salesinvoice  SI where SI.SalInvNo=I.SalInvNo) and InvRcpNo=@InvRcpNo)
				--BEGIN
				--	SET @lError = 1
				--   INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)  
				--   SELECT '' + @SalRpCode + '','Collection',I.SalInvNo,'SalesInvoice No Does Not Exists for' + @InvRcpNo  from
				--   ImportProductPDA_Receiptinvoice I WHERE NOT EXISTS(SELECT SalInvNo from salesinvoice  SI where SI.SalInvNo=I.SalInvNo) and InvRcpNo=@InvRcpNo		
				--END 
				
				IF EXISTS (SELECT * FROM ImportProductPDA_Receiptinvoice WHERE InvRcpNo=@InvRcpNo AND ChequeAmt>0 )
				BEGIN
					IF NOT EXISTS(SELECT * FROM BankBranch where BnkBrId=@BnkBrId)
					BEGIN
					SET @lError = 1
						 INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)  
						 SELECT '' + @SalRpCode + '','Collection',@BnkBrId,'Bank branch does not exists for'+@InvRcpNo
					END
					ELSE
					BEGIN
						SELECT @BnkId=bnkid from BankBranch where BnkBrId=@BnkBrId
						 SELECT TOP 1 @DistBank=BnkId,@DistBranch=bnkbrid FROM bankbranch WHERE distbank=1
					END 
					--if  ltrim(RTRIM(@InvInsNo))<5
					--BEGIN
					--SET @lError = 1
					--	 INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)  
					--	 SELECT '' + @SalRpCode + '','Collection',@InvInsNo,'Instrument No Not given properly'+@InvRcpNo				
					--END	
				END 
				ELSE
				BEGIN
					SET @BnkBrId=0
					SET @BnkId=0
					SET @InvInsNo=''
				END 
				
			IF NOT EXISTS (SELECT DocRefNo FROM Receipt WHERE DocRefNo = @InvRcpNo)  
				  BEGIN   
					DECLARE Cur_Collection_Split cursor
					FOR SELECT DISTINCT SI.Salid,SI.SALINVNO,SI.SalInvDate,(SI.salnetamt-SI.salpayamt-isnull(CollectionAmt,0))PendingAmt 
					FROM ImportProductPDA_Receiptinvoice I
					INNER JOIN RETAILER R ON R.RTRCODE=I.RtrCode 
					 INNER JOIN (SELECT Salid,SALINVNO,SalInvDate,salnetamt,salpayamt,RTRID FROM salesinvoice WHERE Dlvsts=4) SI 
								 ON R.RTRID=SI.RTRID
					LEFT OUTER JOIN #PDA_ReceiptInvoiceSplitActual P on P.salinvno=I.salinvno	WHERE  I.InvRcpNo=@InvRcpNo
					--AND I.Salinvno NOT IN (SELECT salinvno FROM PDA_ReceiptInvoiceSplit where InvRcpNo=@InvRcpNo)
					and (SI.salnetamt-SI.salpayamt-isnull(CollectionAmt,0))>0
					ORDER BY si.salid ASC
					OPEN Cur_Collection_Split
					FETCH NEXT FROM Cur_Collection_Split INTO @Salid,@Salinvno,@Salinvdate,@PendingAmt
					WHILE @@FETCH_STATUS = 0
					BEGIN

				IF @Amount>0 
				 BEGIN 
					 IF (@Amount-@PendingAmt)>0 
						 BEGIN
							 INSERT INTO #PDA_ReceiptInvoiceSplitActual
							 SELECT @Salid,@InvRcpNo,@Salinvno,@Salinvdate,@InvRcpDate,@PendingAmt,@InvInsNo,@BnkBrId,@InvRcpMode
							SET @Amount=(@Amount-@PendingAmt) 
						 END 	
				   ELSE		 
					 IF (@Amount-@PendingAmt)=0 
						 BEGIN
							 INSERT INTO #PDA_ReceiptInvoiceSplitActual
							 SELECT @Salid,@InvRcpNo,@Salinvno,@Salinvdate,@InvRcpDate,@PendingAmt,@InvInsNo,@BnkBrId,@InvRcpMode
							SET @Amount=0
						 END 
				   ELSE	
					 IF (@Amount-@PendingAmt)<0 	 
						 BEGIN
							 INSERT INTO #PDA_ReceiptInvoiceSplitActual
							 SELECT @Salid,@InvRcpNo,@Salinvno,@Salinvdate,@InvRcpDate,@Amount,@InvInsNo,@BnkBrId,@InvRcpMode
							 SET @Amount=0
						 END 	
				END	
		  			FETCH NEXT FROM Cur_Collection_Split INTO @Salid,@Salinvno,@Salinvdate,@PendingAmt
					END
					CLOSE Cur_Collection_Split 
					DEALLOCATE Cur_Collection_Split 
					
			 IF @Amount>0 --To Raise On Account
				BEGIN
					 UPDATE P set CollectionAmt=CollectionAmt+@Amount from #PDA_ReceiptInvoiceSplitActual P INNER JOIN 
					 (SELECT MAX(salid)salid,InvRcpNo from #PDA_ReceiptInvoiceSplitActual where InvRcpNo=@InvRcpNo
					 and InvRcpMode=@InvRcpMode group by InvRcpNo)B
					 on P.Salid=B.salid and P.InvRcpNo=B.InvRcpNo
				END						
					
			  END
			 ELSE
			  BEGIN
				   SET @lError = 1  
				   INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)  
				   SELECT '' + @SalRpCode + '','Collection',@InvRcpNo,'Reference Number Already Exists' + @InvRcpNo  	 
			  END 	
			  
			FETCH NEXT FROM Cur_Collection INTO @InvRcpNo,@InvRcpDate,@Amount,@InvRcpMode,@BnkBrId,@InvInsNo
			END
			CLOSE Cur_Collection 
			DEALLOCATE Cur_Collection 

	  IF @lError=0 
			  BEGIN
			print @InvRcpNoT
				INSERT INTO PDA_ReceiptInvoice(SrpCde,ReceiptNo,BillNumber,ReceiptDate,InvoiceAmount,Balance,ChequeNumber,CashAmount,ChequeAmount,
				DiscAmount,BankId,BranchId,ChequeDate,InvRcpMode,DistBank,DistBankBranch)
				SELECT 	@SalRpCode,InvRcpNo,Salinvno,InvRcpDate,0 as InvoiceAmount,0 as Balance,'' AS ChequeNumber,
				SUM(CashAmount),SUM(ChequeAmount),0 as DiscAmount,SUM(Bnkid)Bnkid,sum(BnkBrid)BnkBrid,InvRcpDate,SUM(invrcpmode)invrcpmode,SUM(DistBank)DistBank,SUM(DistBankBranch)DistBankBranch 
				FROM 
				(SELECT InvRcpDate,Salinvno,InvRcpNo,SUM(CollectionAmt)CashAmount,0 AS ChequeAmount,0 AS Bnkid,0 as BnkBrid,0 as DistBank,0 as DistBankBranch,0 as invrcpmode
				FROM #PDA_ReceiptInvoiceSplitActual where InvRcpMode=1 and InvRcpNo=@InvRcpNoT  group by Salinvno,InvRcpNo,InvRcpDate
				UNION ALL 
				SELECT InvRcpDate,Salinvno,InvRcpNo,0 AS CashAmount,sum(CollectionAmt) AS ChequeAmount,@BnkId AS Bnkid,BnkBrId as BnkBrid,@DistBank as DistBank,@DistBranch as DistBankBranch,2 as invrcpmode
				FROM #PDA_ReceiptInvoiceSplitActual where InvRcpMode=3 and InvRcpNo=@InvRcpNoT group by Salinvno,InvRcpNo,InvRcpDate,BnkBrId
				)A
				GROUP BY InvRcpNo,Salinvno,InvRcpDate
				
				update P set ChequeNumber=invinsno  from  PDA_ReceiptInvoice P inner join (select distinct invinsno,InvRcpNo 
				from #PDA_ReceiptInvoiceSplitActual where InvRcpMode=3 and invrcpno=@InvRcpNoT)B on P.ReceiptNo=B.InvRcpNo
				where InvRcpMode=2
				
				UPDATE P SET CrNoteNo=CrNo,CrAmt=CrAdjAmount FROM  PDA_ReceiptInvoice P INNER JOIN ImportProductPDA_CreditNote I on P.ReceiptNo=I.InvRcpNo AND P.BillNumber=I.SalInvNo
				
				UPDATE ImportProductPDA_Receiptinvoice SET UploadFlag='Y' WHERE InvRcpNo=@InvRcpNoT
				UPDATE ImportProductPDA_CreditNote SET UploadFlag='Y' WHERE InvRcpNo=@InvRcpNoT
			 END	

			 
			FETCH NEXT FROM Cur_CollectionTotal INTO @InvRcpNoT 
			END
			CLOSE Cur_CollectionTotal 
			DEALLOCATE Cur_CollectionTotal 
 END 
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_SalesmanDashBoard' AND XTYPE='U')
DROP TABLE Cos2Mob_SalesmanDashBoard
GO
CREATE TABLE Cos2Mob_SalesmanDashBoard
(	
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode nvarchar(50),
	Smcode nvarchar(50),
	Smid   int,
	Rmid   int,
	RmCode VARCHAR(50),
	MTDSalesValue numeric(18,2),
	MTDLPC numeric(18,2),
	MTDSalesPerProdCall numeric(18,2),
	MTDBilledPrdCount int,
	MTDProductiveCallPer numeric(18,2),
	NewOutletsEnrolled  int,
	UploadFlag  varchar(1)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_RetailerDashBoard' AND XTYPE='U')
DROP TABLE Cos2Mob_RetailerDashBoard
GO
CREATE TABLE Cos2Mob_RetailerDashBoard
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode			nvarchar(50),
	Smcode				nvarchar(50),
	Rmid				int,
	RtrCode				nvarchar(50),
	Rtrid				int,
	L3MavgSales			numeric(18,2),
	MTDSaleValue		numeric(18,2),
	L3MAvgBills			numeric(18,2),
	NoOfBills			int,
	LPPC				numeric(18,2),
	LastVistDate		datetime,
	TotalCRBills		int,
	TotalCRValue		numeric(18,2),
	L3MPrdcallPer		numeric(18,2),
	SalesPerProductCall numeric(18,2),
	QTDSalesValue       numeric(18,6),
	QTDSalesTarget      numeric(18,6),
	UploadFlag			varchar(1)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_OrderBookingDashBoard' AND XTYPE='U')
DROP TABLE Cos2Mob_OrderBookingDashBoard
GO
CREATE TABLE Cos2Mob_OrderBookingDashBoard
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode nvarchar(50),
	Smcode nvarchar(50),
	Rmid int,
	RtRid int,
	OrderDate datetime,
	OrderValue numeric(18,6),
	NumOfLines int,
	UploadFlag  varchar(1)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_OrderProductDashBoard' AND XTYPE='U')
DROP TABLE Cos2Mob_OrderProductDashBoard
GO
CREATE TABLE Cos2Mob_OrderProductDashBoard
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode nvarchar(50),
	Smcode nvarchar(50),
	Rmid int,
	RtRid int,
	Prdid int,
	Prdccode nvarchar(50),
	MTDSalesQty int,
	MTDSalesValue numeric(18,6),
	L3MAvgSalQty numeric(18,0),
	L3MAvgSalValue numeric(18,6),
	L3MAvgQtyPerBill numeric(18,6),
	UploadFlag  varchar(1)
)
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='Proc_ExportPDA_SalesmanDashBoard' AND XTYPE='P' )
DROP PROCEDURE Proc_ExportPDA_SalesmanDashBoard
GO
--Exec Proc_ExportPDA_SalesmanDashBoard
CREATE PROCEDURE Proc_ExportPDA_SalesmanDashBoard
AS
BEGIN
DECLARE @StartDate datetime
Declare @DistCode nvarchar(50) 

select @DistCode=DistributorCode from Distributor
DELETE FROM Cos2Mob_SalesmanDashBoard  WHERE UploadFlag='Y'

SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 
 
INSERT INTO Cos2Mob_SalesmanDashBoard 
SELECT @DistCode,S.SMCode,S.SMId,R.RMId,R.RMCode,SUM(SI.SalNetAmt),0,0,0,0,0,'N' FROM SalesInvoice SI
INNER JOIN Sales_upload SU on SU.Smid=SI.SMId and SU.RMid=Si.RMId
INNER JOIN Salesman S on S.SMId=SI.SMId
INNER JOIN RouteMaster R on R.RMId=SI.RMId
WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	
GROUP BY S.SMCode,S.SMId,R.RMId,R.RMCode

SELECT SMid,Rmid,SUM(prdCnt)prdCnt,SUM(SalCnt)SalCnt Into #TempPrdCnt from (
SELECT salinvno,SI.SMId,SI.RMId,COUNT(distinct Prdid)PrdCnt,count(Distinct Salinvno)SalCnt from SalesInvoice SI
INNER JOIN SalesInvoiceProduct SIP on SI.SalId =SIP.SalId
INNER JOIN Sales_upload SU on SU.Smid=SI.SMId and SU.RMid=Si.RMId
WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	group by salinvno,SI.SMId,SI.RMId)A
GROUP BY SMid,Rmid

 UPDATE E SET MTDLPC=(prdCnt/SalCnt),MTDSalesPerProdCall=(MTDSalesValue/SalCnt),MTDBilledPrdCount=prdCnt
 FROM Cos2Mob_SalesmanDashBoard E INNER JOIN #TempPrdCnt T on E.Smid=T.SMId and E.Rmid=T.RMId

SELECT B.SMId,B.RMId,(RtrCnt/BillRtrCnt)MTDPC into #TempMonthTDPC FROM 
(SELECT SM.SMId,SM.RMId,COUNT(rtrid)RtrCnt FROM SalesmanMarket SM INNER JOIN RetailerMarket RM on SM.RMId=RM.RMId
INNER JOIN Sales_upload SU ON SU.Smid=SM.SMId AND SU.RMid=SM.RMId GROUP BY SM.SMId,SM.RMId)A
INNER JOIN
(SELECT SI.SMId,SI.RMId,COUNT(DISTINCT RtrId)BillRtrCnt FROM SalesInvoice SI INNER JOIN Sales_upload SU ON SU.Smid=SI.SMId AND SU.RMid=SI.RMId
WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	group by SI.SMId,SI.RMId)B
	on A.SMid=B.smid and A.rmid=B.rmid

 UPDATE E SET MTDProductiveCallPer=MTDPC
 FROM Cos2Mob_SalesmanDashBoard E INNER JOIN #TempMonthTDPC T on E.Smid=T.SMId and E.Rmid=T.RMId
 
SELECT D.SmId,D.Rmid,Count(DISTINCT A.RtrId) AS NewCnt into #TempNewRet FROM Retailer A    
			 INNER JOIN RetailerMarket B ON A.RtrId=B.RtrId    
			 INNER JOIN SalesmanMarket C ON B.RMID=C.RMID    
			 INNER JOIN Sales_upload  D ON C.SMID=D.SMID  and D.Rmid=C.RMId  
			 INNER JOIN SalesInvoice E ON A.RtrId=E.RtrId AND E.SMId=D.SmId and E.SMId=D.SMid and e.RMId=C.RMId    
		 WHERE E.Dlvsts IN(4,5) 
			 AND A.RtrRegDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121)  AND A.RtrStatus=1 and DlvSts in(4,5)	
			 Group by D.SmId,D.Rmid
			 
 UPDATE E SET NewOutletsEnrolled=NewCnt
 FROM Cos2Mob_SalesmanDashBoard E INNER JOIN #TempNewRet T on E.Smid=T.SMId and E.Rmid=T.RMId			 
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='TOTALDAYSCOUNT' AND XTYPE='U')
DROP TABLE TOTALDAYSCOUNT
GO
CREATE TABLE TOTALDAYSCOUNT
(
NAMEOFDAY VARCHAR(50),
COUNTDAYS INT,
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='GetCountOfDaysByDayNameInAMonth' AND XTYPE='P')
DROP PROCEDURE GetCountOfDaysByDayNameInAMonth
GO
--exec GetCountOfDaysByDayNameInAMonth  
CREATE PROCEDURE GetCountOfDaysByDayNameInAMonth
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE  @StartOfMonth    DATETIME
			,@EndofMonth      DATETIME;
			
   DELETE FROM TOTALDAYSCOUNT
 --   SELECT @StartOfMonth = DATEADD(MM,DATEDIFF(MM,0,@CurrentDate),0)
	--SELECT @EndofMonth   = DATEADD(MM,DATEDIFF(MM,0,DATEADD(MM,1,@StartOfMonth)),-1)
	SELECT @StartOfMonth=CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(DATEADD(MM,-3,getdate()))-1),DATEADD(MM,-3,getdate())),101) 
	SELECT @EndofMonth =DATEADD(dd, -DAY(DATEADD(m,1,getdate())), DATEADD(m,0,getdate()))
	BEGIN TRY

 ;WITH MaxNumberOfDaysInAnyMonth (N) AS 
		( 
					  SELECT 0
			UNION ALL SELECT 1
			UNION ALL SELECT 2
			UNION ALL SELECT 3
			UNION ALL SELECT 4
			UNION ALL SELECT 5
			UNION ALL SELECT 6
			UNION ALL SELECT 7
			UNION ALL SELECT 8
			UNION ALL SELECT 9
			UNION ALL SELECT 10
			UNION ALL SELECT 11
			UNION ALL SELECT 12
			UNION ALL SELECT 13
			UNION ALL SELECT 14
			UNION ALL SELECT 15
			UNION ALL SELECT 16
			UNION ALL SELECT 17
			UNION ALL SELECT 18
			UNION ALL SELECT 19
			UNION ALL SELECT 20
			UNION ALL SELECT 21
			UNION ALL SELECT 22
			UNION ALL SELECT 23
			UNION ALL SELECT 24
			UNION ALL SELECT 25
			UNION ALL SELECT 26
			UNION ALL SELECT 27
			UNION ALL SELECT 28
			UNION ALL SELECT 29
			UNION ALL SELECT 30
			UNION ALL SELECT 31
			UNION ALL SELECT 32
			UNION ALL SELECT 33
			UNION ALL SELECT 34
			UNION ALL SELECT 35
			UNION ALL SELECT 36
			UNION ALL SELECT 37
			UNION ALL SELECT 38
			UNION ALL SELECT 39
			UNION ALL SELECT 40
			UNION ALL SELECT 41
			UNION ALL SELECT 42
			UNION ALL SELECT 43
			UNION ALL SELECT 44
			UNION ALL SELECT 45
			UNION ALL SELECT 46
			UNION ALL SELECT 47
			UNION ALL SELECT 48
			UNION ALL SELECT 49
			UNION ALL SELECT 40
			UNION ALL SELECT 51
			UNION ALL SELECT 52
			UNION ALL SELECT 53
			UNION ALL SELECT 54
			UNION ALL SELECT 55
			UNION ALL SELECT 56
			UNION ALL SELECT 57
			UNION ALL SELECT 58
			UNION ALL SELECT 59
			UNION ALL SELECT 60
			UNION ALL SELECT 61
			UNION ALL SELECT 62
			UNION ALL SELECT 63
			UNION ALL SELECT 64
			UNION ALL SELECT 65
			UNION ALL SELECT 66
			UNION ALL SELECT 67
			UNION ALL SELECT 68
			UNION ALL SELECT 69
			UNION ALL SELECT 70
			UNION ALL SELECT 71
			UNION ALL SELECT 72
			UNION ALL SELECT 73
			UNION ALL SELECT 74
			UNION ALL SELECT 75
			UNION ALL SELECT 76
			UNION ALL SELECT 77
			UNION ALL SELECT 78
			UNION ALL SELECT 79
			UNION ALL SELECT 80
			UNION ALL SELECT 81
			UNION ALL SELECT 82
			UNION ALL SELECT 83
			UNION ALL SELECT 84
			UNION ALL SELECT 85
			UNION ALL SELECT 86
			UNION ALL SELECT 87
			UNION ALL SELECT 88
			UNION ALL SELECT 89
			UNION ALL SELECT 90		),
		DaysOfCurrentMonth AS
		(
			SELECT DATEADD(DD, N , @StartOfMonth ) DY
			FROM   MaxNumberOfDaysInAnyMonth
			WHERE  N <= DATEDIFF(DD,@StartOfMonth,@EndofMonth)
		)
		INSERT INTO TOTALDAYSCOUNT
		SELECT    DATENAME(DW,DY) NameOfTheDay,COUNT(*) CountOfDays
		FROM     DaysOfCurrentMonth
		GROUP BY DATENAME(DW,DY)
		ORDER BY  CASE  DATENAME(DW,DY) 
					WHEN 'Sunday'    THEN 1
					WHEN 'Monday'    THEN 2
					WHEN 'Tuesday'   THEN 3
					WHEN 'Wednesday' THEN 4
					WHEN 'Thursday'  THEN 5
					WHEN 'Friday'    THEN 6
					WHEN 'Satureday' THEN 7 
				 END ;
	END TRY

	BEGIN CATCH
	      SELECT ERROR_MESSAGE() AS [ERROR_MESSAGE]     
	END CATCH
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='Proc_ExportPDA_RetailerDashBoard' AND XTYPE='P' )
DROP PROCEDURE Proc_ExportPDA_RetailerDashBoard
GO
--Exec Proc_ExportPDA_RetailerDashBoard
CREATE PROCEDURE Proc_ExportPDA_RetailerDashBoard
AS
BEGIN
DECLARE @StartDate   datetime 
DECLARE @3MStartDate datetime
DECLARE @3MEndDate   datetime
Declare @DistCode nvarchar(50) 
DECLARE @JcmStd DATETIME
DECLARE @JcmEdt DATETIME
DECLARE @QtrID as nvarchar(10)

	EXEC GetCountOfDaysByDayNameInAMonth   

	DELETE from Cos2Mob_RetailerDashBoard

 SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 
 SELECT @3MStartDate= CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(DATEADD(MM,-3,getdate()))-1),DATEADD(MM,-3,getdate())),101) 
 SELECT @3MEndDate=DATEADD(dd, -DAY(DATEADD(m,1,getdate())), DATEADD(m,0,getdate()))
 SELECT @DistCode=DistributorCode from Distributor

	SELECT @JcmStd=JCMSTD,@JcmEdt=JCMEDT,@QtrID=QuarterDt from(
	SELECT MIN(JCMSDT)JCMSTD,MAX(JCMEDT)JCMEDT,A.QuarterDt FROM JCMONTH J INNER JOIN 
	(SELECT JCMID,QuarterDt FROM JCMONTH WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN JCMSDT AND JCMEDT)A
	ON J.JCMID=A.JCMID AND J.QuarterDt=A.QuarterDt group by A.QuarterDt)C 

	INSERT INTO Cos2Mob_RetailerDashBoard
	SELECT @DistCode,SM.SMCode ,SI.RMId,R.RtrCode,R.RtrId,0,sum(SI.SalNetAmt)SalesValue,0,Count(salinvno)SalCnt,0,Max(salinvdate),0,0,0,0,0,0,'N' FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	INNER JOIN Retailer R on R.RtrId =SI.RtrId
	inner join salesman SM on SM.SMId=S.SMID and SM.SMId=SI.SMId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	
	GROUP BY smcode,SI.RMId,R.RtrCode,R.RtrId
	
	SELECT smcode,SI.SMId,SI.RMId,SI.RtrId,sum(SI.SalNetAmt)SalesValue,Count(salinvno)SalCnt Into #Temp3monAvgsales FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	inner join salesman SM on SM.SMId=S.SMID and SM.SMId=SI.SMId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts in(4,5)	
	GROUP BY SI.SMId,SI.RMId,SI.RtrId,smcode
	
	SELECT SMCode,SMid,Rmid,RtrId,SUM(prdCnt)prdCnt,SUM(SalCnt)SalCnt Into #TempPrdCnt from (
	SELECT SM.SMCode,salinvno,SI.SMId,SI.RMId,RtrId,COUNT(distinct Prdid)PrdCnt,count(Distinct Salinvno)SalCnt from SalesInvoice SI
	INNER JOIN SalesInvoiceProduct SIP on SI.SalId =SIP.SalId
	INNER JOIN Sales_upload SU on SU.Smid=SI.SMId and SU.RMid=Si.RMId
	inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=SU.SMID
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts in(4,5) 
	group by salinvno,SI.SMId,SI.RMId,RtrId,SM.SMCode)A
	GROUP BY SMid,Rmid,RtrId,SMCode

	SELECT smcode,SI.SMId,SI.RMId,SI.RtrId,sum(SI.SalNetAmt)SalesValue,Count(salinvno)SalCnt Into #TempCreditbills FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=S.SMID
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts in(4,5) 
	GROUP BY SI.SMId,SI.RMId,SI.RtrId,smcode
	
	SELECT A.RTRID,CAST(SUM(T.COUNTDAYS*RtrCnt)/CAST(SUM(SALCNT) AS NUMERIC(18,6))*100 AS NUMERIC(18,2)) TOTRTRCNT  into #TempproductCallper  FROM (
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Monday' TOTDAY FROM RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId where RMMon=1 group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Tuesday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId where RMTue=1 group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Wednesday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId where RMWed=1 group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Thursday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId where RMThu=1 group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Friday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId where RMFri=1 group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Saturday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId where RMSat=1 group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Sunday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId where RMSun=1 group by RM.RTRID)A
	INNER JOIN TOTALDAYSCOUNT T ON A.TOTDAY=T.NAMEOFDAY
	INNER JOIN (SELECT SI.RTRID,COUNT(SalId)SALCNT FROM SalesInvoice SI INNER JOIN Retailer R ON SI.RtrId=R.RtrId
	INNER JOIN  RetailerMarket RM ON RM.RMId=SI.RMId AND RM.RtrId=SI.RtrId
	INNER JOIN SalesmanMarket SM ON SM.SMId=SI.SMId AND SM.RMId=SI.RMId AND SM.RMId=RM.RMId
	INNER JOIN Sales_upload SU ON SU.Rmid=SI.RMId 
	GROUP BY SI.RTRID)C ON C.RTRID=A.RTRID 
	GROUP BY A.RTRID
	
	SELECT sm.SMCode,SI.SMId as SMId,SI.RMId as RMId,SI.RtrId,sum(sip.PrdNetAmount)SalesValue INTO #TempQuarterSales
	FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	INNER JOIN SalesInvoiceProduct SIP on SI.SalId=sip.SalId
    inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=s.SMID
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@JcmStd,121) AND CONVERT(VARCHAR(10),@JcmEdt,121) and DlvSts in(4,5)	
    GROUP BY SI.SMId,SI.RMId,SI.RtrId,sm.SMCode	
	
	UPDATE  E SET L3MavgSales=(SalesValue/3),L3MAvgBills=(SalCnt/3),SalesPerProductCall=(SalesValue/SalCnt) FROM  Cos2Mob_RetailerDashBoard E 
	INNER JOIN #Temp3monAvgsales T on E.Smcode=T.SMCode and E.Rmid=T.RMId and E.Rtrid=T.RtrId
	
	UPDATE E SET LPPC=(prdCnt/SalCnt)  FROM  Cos2Mob_RetailerDashBoard E 
	INNER JOIN #TempPrdCnt T on E.Smcode=T.smcode and E.Rmid=T.RMId and E.Rtrid=T.RtrId

	UPDATE E SET TotalCRValue=SalesValue,TotalCRBills=SalCnt  FROM  Cos2Mob_RetailerDashBoard E 
	INNER JOIN #TempCreditbills T on E.Smcode=T.SMCode and E.Rmid=T.RMId and E.Rtrid=T.RtrId
	
	UPDATE E SET  QTDSalesValue=SalesValue FROM  Cos2Mob_RetailerDashBoard E 
	INNER JOIN #TempQuarterSales T on E.Smcode=T.SMCode and E.Rmid=T.RMId and E.Rtrid=T.RtrId

	UPDATE  E SET L3MPrdcallPer=TOTRTRCNT FROM  Cos2Mob_RetailerDashBoard E INNER JOIN #TempproductCallper T on E.Rtrid=T.RtrId
	
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='Proc_ExportPDA_OrderBookingDashBoard' AND XTYPE='P' )
DROP PROCEDURE Proc_ExportPDA_OrderBookingDashBoard
GO
--Exec Proc_ExportPDA_OrderBookingDashBoard
CREATE PROCEDURE Proc_ExportPDA_OrderBookingDashBoard
AS
BEGIN
DECLARE @StartDate   datetime 
Declare @DistCode nvarchar(50) 

 DELETE from Cos2Mob_OrderBookingDashBoard

 SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 
 SELECT @DistCode=DistributorCode from Distributor
	
 INSERT INTO Cos2Mob_OrderBookingDashBoard	
 select @DistCode,SM.SMCode,SI.RMId,RtrId,SalInvDate,SalNetAmt,COUNT(distinct Prdid),'N' from SalesInvoice SI
 INNER JOIN SalesInvoiceProduct SIP on si.SalId=sip.SalId
 INNER JOIN Sales_upload SU on SU.Smid=SI.SMId and SU.RMid=Si.RMId
 inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=SU.SMID
 WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	
 GROUP BY SMCode,SI.RMId,RtrId,SalInvDate,SalNetAmt

 END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='Proc_ExportPDA_OrderProductDashBoard' AND XTYPE='P' )
DROP PROCEDURE Proc_ExportPDA_OrderProductDashBoard
GO
--Exec Proc_ExportPDA_OrderProductDashBoard
CREATE PROCEDURE Proc_ExportPDA_OrderProductDashBoard
AS
BEGIN
DECLARE @StartDate   datetime 
DECLARE @3MStartDate datetime
DECLARE @3MEndDate   datetime
Declare @DistCode nvarchar(50) 

DELETE from Cos2Mob_OrderProductDashBoard

 SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 
 SELECT @3MStartDate= CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(DATEADD(MM,-3,getdate()))-1),DATEADD(MM,-3,getdate())),101) 
 SELECT @3MEndDate=DATEADD(dd, -DAY(DATEADD(m,1,getdate())), DATEADD(m,0,getdate()))
 SELECT @DistCode=DistributorCode from Distributor

	 INSERT INTO Cos2Mob_OrderProductDashBoard
	 SELECT @DistCode,sm.SMCode,SI.RMId,RtrId,sip.PrdId,PrdCCode,sum(sip.BaseQty),sum(sip.PrdNetAmount),0,0,0,'N' from SalesInvoice SI
	 INNER JOIN SalesInvoiceProduct SIP on si.SalId=sip.SalId
	 INNER JOIN Sales_upload SU on SU.Smid=SI.SMId and SU.RMid=Si.RMId
	 INNER JOIN Product P on P.PrdId=SIP.PrdId
     inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=SU.SMID
	 WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	
	 GROUP BY  sm.SMCode,SI.RMId,RtrId,sip.PrdId,PrdCCode


	SELECT sm.smcode,SI.SMId,SI.RMId,SI.RtrId,sum(SIP.PrdNetAmount)SalesValue,SUM(SIP.BaseQty)BaseQty,COUNT(DISTINCT SI.SalId)SALCNT Into #TempAvgBills FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	INNER JOIN SalesInvoiceProduct SIP on SI.SalId=sip.SalId
    inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=s.SMID
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts=4	
	GROUP BY SI.SMId,SI.RMId,SI.RtrId,sm.smcode
	
	UPDATE E SET L3MAvgSalQty=(BaseQty/3) ,L3MAvgSalValue=(SalesValue/3),L3MAvgQtyPerBill=(BaseQty/SALCNT)   FROM  Cos2Mob_OrderProductDashBoard E 
	INNER JOIN #TempAvgBills T on E.Smcode=T.SMCode and E.Rmid=T.RMId and E.Rtrid=T.RtrId	
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_RetailerProductDashBoard' AND XTYPE='U')
DROP TABLE Cos2Mob_RetailerProductDashBoard
GO
CREATE TABLE Cos2Mob_RetailerProductDashBoard
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	DistCode     nvarchar(50),
	SrpCde       nvarchar(50),
    Rmid         int,
	Rtrid		 int,
	PrdCcode     nvarchar(50),	
	Billed       Varchar(3),
	UploadFlag   varchar(1)
)
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='Proc_ExportPDA_RetailerProductDashBoard' AND XTYPE='P' )
DROP PROCEDURE Proc_ExportPDA_RetailerProductDashBoard
GO
--Exec Proc_ExportPDA_RetailerProductDashBoard
CREATE PROCEDURE Proc_ExportPDA_RetailerProductDashBoard
AS
BEGIN
Declare @DistCode nvarchar(50) 
DECLARE @3MStartDate datetime
DECLARE @3MEndDate   datetime

 SELECT @3MStartDate= CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(DATEADD(MM,-3,getdate()))-1),DATEADD(MM,-3,getdate())),101) 
 SELECT @3MEndDate=DATEADD(dd, -DAY(DATEADD(m,1,getdate())), DATEADD(m,0,getdate()))
 SELECT @DistCode=DistributorCode from Distributor
 
	DELETE FROM Cos2Mob_RetailerProductDashBoard
	
	INSERT INTO Cos2Mob_RetailerProductDashBoard
	SELECT @DistCode,Cos2Mob_Retailer.SrpCde,MktId,RtrId,PrdCCode,'No','N' FROM Cos2Mob_Retailer CROSS JOIN Cos2Mob_Product
	
	SELECT RtrId,PrdCCode into #BilledRetailer FROM salesinvoice SI INNER JOIN SalesInvoiceProduct SIP on SI.SalId=SIP.SalId 
	INNER JOIN Product P  on P.PrdId=SIP.PrdId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts in(4,5)	
	
	UPDATE E SET billed='Yes' FROM Cos2Mob_RetailerProductDashBoard E INNER JOIN
	#BilledRetailer B on E.rtrid=B.rtrid AND E.prdccode=B.prdccode

	DELETE FROM Cos2Mob_RetailerProductDashBoard WHERE billed='No'
	 
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='ImportProductPDA_NonProductiveRetailers')
DROP TABLE ImportProductPDA_NonProductiveRetailers
GO
CREATE TABLE ImportProductPDA_NonProductiveRetailers
(
	[SrpCde] [varchar](50) ,
	[RtrCode] [nvarchar](50) ,
	[ReasonId] [int] ,
	[NonProdDate] [datetime] ,
	[UploadFlag] [varchar](1)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='NonProductiveRetailers')
DROP TABLE NonProductiveRetailers
GO
CREATE TABLE NonProductiveRetailers
(
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReasonId] [int] NULL,
	[NonProdDate] [datetime] NULL
)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Import_PDA_NonProductiveRetailers' AND xtype='P')
DROP PROCEDURE Proc_Import_PDA_NonProductiveRetailers
GO
--Exec Proc_Import_PDA_NonProductiveRetailers  'DD'
CREATE PROCEDURE Proc_Import_PDA_NonProductiveRetailers
(      
 @SalRpCode varchar(50) )      
AS
BEGIN      
 BEGIN TRANSACTION T1      
 DELETE FROM ImportProductPDA_NonProductiveRetailers  WHERE UploadFlag='Y'   
 
 insert into NonProductiveRetailers
 select SrpCde,RtrCode,ReasonId,NonProdDate from ImportProductPDA_NonProductiveRetailers
 
 END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_OrderBooking')
DROP TABLE Mob2Cos_OrderBooking
GO
CREATE TABLE Mob2Cos_OrderBooking
(
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[OrdKeyNo] [varchar](50) NULL,
	[OrdDt] [datetime] NULL,
	[RtrCde] [nvarchar](200) NULL,
	[Mktid] [int] NULL,
	[SrpId] [int] NULL,
	[Rtrid] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
	[UploadFlag] [varchar](1) NULL,
	[Longitude] [varchar](50) NULL,
	[Latitude] [varchar](50) NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_OrderBookingProduct')
DROP TABLE Mob2Cos_OrderBookingProduct
GO
CREATE TABLE Mob2Cos_OrderBookingProduct
(
	[DistCode] [nvarchar](20) NULL,
	[Id] [int] NULL,
	[SrpCde] [varchar](50) NULL,
	[OrdKeyNo] [varchar](50) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PriceId] [int] NULL,
	[OrdQty] [int] NULL,
	[UploadFlag] [varchar](1) NULL,
	[Uomid]  [Int]
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_Receiptinvoice')
DROP TABLE Mob2Cos_Receiptinvoice
GO
CREATE TABLE Mob2Cos_Receiptinvoice
(
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[InvRcpNo] [varchar](50) NULL,
	[InvRcpDate] [datetime] NULL,
	[InvrcpAmt] [numeric](18, 2) NULL,
	[SalInvNo] [varchar](25) NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvAmt] [float] NULL,
	[InvRcpMode] [int] NULL,
	[BnkBrId] [int] NULL,
	[InvInsNo] [varchar](50) NULL,
	[InvInsDate] [datetime] NULL,
	[InvDepDate] [datetime] NULL,
	[InvInsSta] [varchar](1) NULL,
	[CashAmt] [numeric](18, 2) NULL,
	[ChequeAmt] [numeric](18, 2) NULL,
	[UploadFlag] [varchar](1) NULL,
	[RtrCode] [varchar](50) NULL	
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_SalesReturn')
DROP TABLE Mob2Cos_SalesReturn
GO
CREATE TABLE Mob2Cos_SalesReturn
(
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[SrNo] [varchar](25) NULL,
	[SrDate] [datetime] NULL,
	[SalInvNo] [varchar](25) NULL,
	[RtrCde] [nvarchar](40) NULL,
	[Rtrid] [int] NULL,
	[Mktid] [int] NULL,
	[Srpid] [int] NULL,
	[ReturnMode] [int] NULL,
	[InvoiceType] [int] NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_SalesReturnProduct')
DROP TABLE Mob2Cos_SalesReturnProduct
GO
CREATE TABLE Mob2Cos_SalesReturnProduct
(
	[DistCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SrNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PriceId] [int] NULL,
	[SrQty] [int] NULL,
	[UsrStkTyp] [int] NULL,
	[salinvno] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SlNo] [int] NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_CreditNote')
DROP TABLE Mob2Cos_CreditNote
GO
CREATE TABLE Mob2Cos_CreditNote
(
	[DistCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvRcpNo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CrNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CrAmount] [numeric](18, 2) NULL,
	[SalInvNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [numeric](18, 2) NULL,
	[CrAdjAmount] [numeric](18, 2) NULL,
	[TranNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_DebitNote')
DROP TABLE Mob2Cos_DebitNote
GO
CREATE TABLE Mob2Cos_DebitNote
(
	[DistCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DbNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DbAmount] [numeric](18, 2) NULL,
	[RtrId] [numeric](18, 2) NULL,
	[DbAdjAmount] [numeric](18, 2) NULL,
	[TransNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_NewRetailer')
DROP TABLE Mob2Cos_NewRetailer
GO
CREATE TABLE Mob2Cos_NewRetailer
(
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](50) NULL,
	[RtrCode] [nvarchar](50) NULL,
	[RetailerName] [nvarchar](100) NULL,
	[CtgLevelId] [int] NULL,
	[CtgMainID] [int] NULL,
	[RtrClassId] [int] NULL,
	[RtrAdd1] [nvarchar](100) NULL,
	[RtrAdd2] [nvarchar](100) NULL,
	[RtrAdd3] [nvarchar](100) NULL,
	[RtrPhoneNo] [nvarchar](100) NULL,
	[CreditAvailable] [numeric](18, 6) NULL,
	[RtrTINNo] [nvarchar](100) NULL,
	[UploadFlag] [varchar](1) NULL,
	[Longitude] [varchar](50) NULL,
	[Latitude] [varchar](50) NULL,
	RtrMobileNo NVARCHAR(100)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='Mob2Cos_NonProductiveRetailers')
DROP TABLE Mob2Cos_NonProductiveRetailers
GO
CREATE TABLE Mob2Cos_NonProductiveRetailers
(
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReasonId] [int] NULL,
	[NonProdDate] [datetime] NULL,
	[UploadFlag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ImportPDA2CS_USB' AND XTYPE ='P')
DROP PROC Proc_ImportPDA2CS_USB
GO
CREATE PROCEDURE Proc_ImportPDA2CS_USB
(
  @PROCESSNAME VARCHAR(100),
  @TABLENAME VARCHAR(100) = NULL
)
/*
*/
AS  
SET NOCOUNT ON  
BEGIN 
 DECLARE @hDoc AS INT  
  IF @PROCESSNAME = 'OrderBooking'
	BEGIN
	 DELETE FROM ImportPDA_OrderBooking  WHERE UploadFlag='Y'  
	 
	 IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_OrderBooking
		RETURN
	 END
	   	 
	 INSERT INTO ImportPDA_OrderBooking  
	 SELECT DISTINCT 
		SrpCde,OrdKeyNo,OrdDt,RtrCde,Mktid,
		SrpId,Rtrid,Remarks,UploadFlag,'' Longitude,'' Latitude
	FROM 
		Mob2Cos_OrderBooking
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_OrderBooking SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
	END
 IF @PROCESSNAME = 'OrderBookingProduct'
	BEGIN
	
	IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_OrderBookingProduct
		RETURN
	 END
	 DELETE FROM ImportPDA_OrderBookingProduct  WHERE UploadFlag='Y'  
   	 
	 INSERT INTO ImportPDA_OrderBookingProduct  
	 SELECT DISTINCT 
		SrpCde,OrdKeyNo,PrdId,PrdBatId,
		PriceId,OrdQty,UploadFlag ,Uomid
	FROM 
		Mob2Cos_OrderBookingProduct
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_OrderBookingProduct SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
	END
	
 IF @PROCESSNAME = 'SalesReturn'
	BEGIN
	
	IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_SalesReturn
		RETURN
	 END
	
	DELETE FROM ImportProductPDA_SalesReturn  WHERE UploadFlag='Y'  
	   
	 
	 INSERT INTO ImportProductPDA_SalesReturn  
	 SELECT 
		SrpCde,SrNo,SrDate,SalInvNo,RtrCde,Rtrid,
		Mktid,Srpid,ReturnMode,InvoiceType,UploadFlag
	 FROM	 
		Mob2Cos_SalesReturn
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_SalesReturn SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
	END
  IF @PROCESSNAME = 'SalesReturnProduct'
	BEGIN
	
	IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_SalesReturnProduct
		RETURN
	 END
	
	 DELETE FROM ImportProductPDA_SalesReturnProduct  WHERE UploadFlag='Y'  
	   
	 
	 INSERT INTO ImportProductPDA_SalesReturnProduct  
	 SELECT 
		SrpCde,SrNo,PrdId,PrdBatId,PriceId,SrQty,
		UsrStkTyp,salinvno,SlNo,Reasonid,UploadFlag
	 FROM
		Mob2Cos_SalesReturnProduct
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_SalesReturnProduct SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
	END
  IF @PROCESSNAME = 'Receiptinvoice'
	BEGIN
	
	  IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_Receiptinvoice
		RETURN
	 END
	 
	 DELETE FROM ImportProductPDA_Receiptinvoice  WHERE UploadFlag='Y'     	 
	 INSERT INTO ImportProductPDA_Receiptinvoice  
	 SELECT 
		SrpCde,InvRcpNo,InvRcpDate,InvrcpAmt,SalInvNo,SalInvDate,SalInvAmt,
	    InvRcpMode,BnkBrId,InvInsNo,InvInsDate,InvDepDate,InvInsSta,CashAmt,ChequeAmt,UploadFlag,RtrCode
	FROM 
		Mob2Cos_Receiptinvoice
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_Receiptinvoice SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
 END
 IF @PROCESSNAME = 'Import_CreditNote'
 BEGIN
   IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_CreditNote
		RETURN
	 END
	 
	 DELETE FROM ImportProductPDA_CreditNote  WHERE UploadFlag='Y'  
   	
	 INSERT INTO ImportProductPDA_CreditNote  
	 SELECT 
		SrpCde,InvRcpNo,CrNo,CrAmount,SalInvNo,
		RtrId,CrAdjAmount,TranNo,Reasonid,UploadFlag 
	FROM 
		Mob2Cos_CreditNote
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_CreditNote SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
 END
  IF @PROCESSNAME = 'Import_DebitNote'
	BEGIN
	
	   IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_DebitNote
		RETURN
	 END
	 DELETE FROM ImportProductPDA_DebitNote  WHERE UploadFlag='Y'  
	 
	 INSERT INTO ImportProductPDA_DebitNote
	 SELECT 
		SrpCde,DbNo,DbAmount,RtrId,DbAdjAmount,
		TransNo,Reasonid,UploadFlag
	 FROM 
		Mob2Cos_DebitNote
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_DebitNote SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
	 
	END
  IF @PROCESSNAME = 'NewRetailer'    
	BEGIN
	
	IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_NewRetailer
		RETURN
	 END
	
	 DELETE FROM ImportProductPDA_NewRetailer  WHERE UploadFlag='Y'  
	 
	 INSERT INTO ImportProductPDA_NewRetailer  
	 SELECT 
		SrpCde,RtrCode,RetailerName,CtgLevelId,CtgMainID,RtrClassId,
		RtrAdd1,RtrAdd2,RtrAdd3,RtrPhoneNo,CreditAvailable,RtrTINNo,UploadFlag,'' Longitude,'' Latitude,RtrMobileNo
	 FROM 
		Mob2Cos_NewRetailer
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_NewRetailer SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
	END	
	
	IF @PROCESSNAME = 'NonProductiveRetailers'		
  BEGIN
     IF @TABLENAME = 'COUNT'
	 BEGIN		
		SELECT COUNT(*) FROM Mob2Cos_NonProductiveRetailers
		RETURN
	 END
	 DELETE FROM ImportProductPDA_NonProductiveRetailers  WHERE UploadFlag='Y'  
	 
	 INSERT INTO ImportProductPDA_NonProductiveRetailers  
	 SELECT 
		SrpCde,RtrCode,ReasonId,NonProdDate,UploadFlag
	 FROM 
		Mob2Cos_NonProductiveRetailers
	WHERE UPLOADFLAG = 'N'
		
		UPDATE Mob2Cos_NonProductiveRetailers SET UPLOADFLAG = 'Y' WHERE UPLOADFLAG = 'N'
	 
	  END	  	  
	  	  
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='U' AND name='MarketIntelligenceHD')
DROP TABLE MarketIntelligenceHD
GO
CREATE TABLE [dbo].[MarketIntelligenceHD](
	[QuestionID] [int] NULL,
	[QuestionType] [int] NULL,
	[Question] [varchar](120) NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[ChannelCode] [varchar](20) NULL,
	[QuestionSetID] [int] NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='U' AND name='MarketIntelligenceDT')
DROP TABLE MarketIntelligenceDT
GO
CREATE TABLE [dbo].[MarketIntelligenceDT](
	[QuestionID] [int] NULL,
	[Answer] [varchar](25) NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_MarketIntelligenceDT' AND XTYPE='U')
DROP TABLE Cos2Mob_MarketIntelligenceDT
GO
CREATE TABLE Cos2Mob_MarketIntelligenceDT
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SRPCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QuestionID] [int] NULL,
	[Answer] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_MarketIntelligenceHD' AND XTYPE='U')
DROP TABLE Cos2Mob_MarketIntelligenceHD
GO
CREATE TABLE Cos2Mob_MarketIntelligenceHD
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SRPCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QuestionID] [int] NULL,
	[QuestionType] [int] NULL,
	[Question] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ChannelCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[QuestionSetID] [int] NULL,
	[UploadFlag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cos2Mob_ImageDownloadUrl' AND XTYPE='U')
DROP TABLE Cos2Mob_ImageDownloadUrl
GO
CREATE TABLE Cos2Mob_ImageDownloadUrl
(
	SlNo        int IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SRPCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ChannelCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Message] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Attachment] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Mob2Cos_MarketIntelligenceResponse' AND XTYPE='U')
DROP TABLE Mob2Cos_MarketIntelligenceResponse
GO
CREATE TABLE Mob2Cos_MarketIntelligenceResponse
(
	[DistCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SrpCode] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Rtrid] [int] NULL,
	[Qusetionid] [int] NULL,
	[QuestionSetid] [int] NULL,
	[Answer] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Mob2Cos_RetailerStockCapture' AND XTYPE='U')
DROP TABLE Mob2Cos_RetailerStockCapture
GO
CREATE TABLE Mob2Cos_RetailerStockCapture
(
	Distcode varchar(50),
	Srpcode varchar(25),
	Rtrid Int,
	Prdid int, 
	Stock int,
	UploadFlag varchar(1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportProductPDA_RetailerStockCapture' AND XTYPE ='U')
DROP TABLE ImportProductPDA_RetailerStockCapture
GO
CREATE TABLE  ImportProductPDA_RetailerStockCapture	
(
	SrpCde		VARCHAR(50),
	[Rtrid]		 [int] NULL,
	[Prdid]		 [int] NULL,
	[Stock]		 [int] NULL,
	[UploadFlag] [varchar](1)
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='RetailerStockCapture' AND XTYPE ='U')
DROP TABLE RetailerStockCapture
GO
CREATE TABLE  RetailerStockCapture	
(
	SrpCde		VARCHAR(50),
	[Rtrid]		 [int],
	[Prdid]		 [int],
	[Stock]		 [int],
	DownloadedDate Datetime
)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Import_PDA_RetailerStockCapture' AND xtype='P')
DROP PROCEDURE Proc_Import_PDA_RetailerStockCapture
GO
--Exec Proc_Import_PDA_RetailerStockCapture  'DD'
CREATE PROCEDURE Proc_Import_PDA_RetailerStockCapture
(      
 @SalRpCode varchar(50) )      
AS
BEGIN      
     
 DELETE FROM ImportProductPDA_RetailerStockCapture  WHERE UploadFlag='Y'   
 
 insert into RetailerStockCapture
 select SrpCde,Rtrid,Prdid,Stock,GETDATE() from ImportProductPDA_RetailerStockCapture
 
 END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_PDA_MarketIntelligencehd' AND XTYPE ='P')
DROP PROCEDURE Proc_Export_PDA_MarketIntelligencehd
GO
--EXEC Proc_Export_PDA_MarketIntelligencehd SM01
CREATE PROCEDURE Proc_Export_PDA_MarketIntelligencehd
AS
BEGIN
		TRUNCATE TABLE Cos2Mob_MarketIntelligenceHD 
		INSERT INTO Cos2Mob_MarketIntelligenceHD (DistCode,SRPCode,QuestionID,QuestionType,Question,ChannelCode,FromDate,ToDate,QuestionSetID,UploadFlag)
		SELECT DISTINCT DistributorCode,SMCode,QuestionID,QuestionType,Question,ChannelCode,FromDate,ToDate,QuestionSetID,'N' AS UploadFlag
		FROM MarketIntelligenceHD C (NOLOCK) 
		CROSS JOIN (SELECT SMCode FROM SALES_UPLOAD A (NOLOCK) INNER JOIN Salesman S (NOLOCK) ON A.SMID=S.SMId)S
		CROSS JOIN Distributor (NOLOCK)
		WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN CONVERT(NVARCHAR(10),FromDate,121) AND CONVERT(NVARCHAR(10),ToDate,121)     
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_PDA_MarketIntelligencedt' AND XTYPE ='P')
DROP PROCEDURE Proc_Export_PDA_MarketIntelligencedt
GO
--EXEC PROC_ExportPDA_CreditNote SM01
CREATE PROCEDURE Proc_Export_PDA_MarketIntelligencedt
AS
BEGIN
        TRUNCATE TABLE Cos2Mob_MarketIntelligenceDt 
        INSERT INTO Cos2Mob_MarketIntelligenceDt (DistCode,SRPCode,QuestionID,Answer,UploadFlag)
		SELECT DISTINCT DistributorCode,SMCode,B.QuestionID,Answer,'N' AS UploadFlag
		FROM MarketIntelligenceHD A (NOLOCK) INNER JOIN MarketIntelligenceDt B (NOLOCK) ON A.QuestionID = B.QuestionID
		CROSS JOIN (SELECT SMCode FROM SALES_UPLOAD A (NOLOCK) INNER JOIN Salesman S (NOLOCK) ON A.SMID=S.SMId)S
		CROSS JOIN Distributor (NOLOCK)
		WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN CONVERT(NVARCHAR(10),FromDate,121) AND CONVERT(NVARCHAR(10),ToDate,121)
END
GO
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE TYPE = 'P' AND NAME = 'Proc_ImportPDA2CS')
DROP PROCEDURE Proc_ImportPDA2CS
GO
CREATE PROCEDURE Proc_ImportPDA2CS
(
  @PROCESSNAME VARCHAR(100) ,
  @Pi_Records TEXT  
)
/*

*/
AS  
SET NOCOUNT ON  
BEGIN 
 DECLARE @hDoc AS INT  
 
  IF @PROCESSNAME = 'OrderBooking'
	BEGIN
	 DELETE FROM ImportPDA_OrderBooking  WHERE UploadFlag='Y'  
	   
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportPDA_OrderBooking  
	 SELECT SrpCde,OrdKeyNo,OrdDt,RtrCde,Mktid,SrpId,Rtrid,Remarks,UploadFlag,Longitude,Latitude
	 FROM OPENXML (@hdoc,'/Root/Mob2Cos_OrderBooking',1)  
	 WITH   
	 (  
		SrpCde	varchar(100),
		OrdKeyNo	varchar(100),
		OrdDt	datetime,
		RtrCde	nvarchar(100),
		Mktid	int,
		SrpId	int,
		Rtrid	int,
		Remarks	nvarchar(100),
		UploadFlag	varchar(1),
		Longitude varchar(50),
		Latitude varchar(50)
	 ) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  

	END

 IF @PROCESSNAME = 'OrderBookingProduct'

	BEGIN

	 DELETE FROM ImportPDA_OrderBookingProduct  WHERE UploadFlag='Y'  
   
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportPDA_OrderBookingProduct  
	 SELECT SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId,OrdQty,UploadFlag,UomId
	 FROM OPENXML (@hdoc,'/Root/Mob2Cos_OrderBookingProduct',1)  
	 WITH   
	 (  
		SrpCde	varchar(100),
		OrdKeyNo	varchar(100),
		PrdId	int,
		PrdBatId	int,
		PriceId	int,
		OrdQty	int,
		UploadFlag	varchar(2),
		UomId Int
	 ) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  

	END
 IF @PROCESSNAME = 'SalesReturn'

	BEGIN
	DELETE FROM ImportProductPDA_SalesReturn  WHERE UploadFlag='Y'  
	   
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportProductPDA_SalesReturn  
	 SELECT SrpCde,SrNo,SrDate,SalInvNo,RtrCde,Rtrid,Mktid,Srpid,ReturnMode,InvoiceType,UploadFlag
	 FROM OPENXML (@hdoc,'/Root/Mob2Cos_SalesReturn',1)  
	 WITH   
	 (  
		SrpCde	varchar(100),
		SrNo	varchar(100),
		SrDate	datetime,
		SalInvNo	varchar(100),
		RtrCde	nvarchar(100),
		Rtrid	int,
		Mktid	int,
		Srpid	int,
		ReturnMode	int,
		InvoiceType	int,
	   UploadFlag	varchar(1) 
	) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  

	END
  IF @PROCESSNAME = 'SalesReturnProduct'

	BEGIN
	 DELETE FROM ImportProductPDA_SalesReturnProduct  WHERE UploadFlag='Y'  
	   
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportProductPDA_SalesReturnProduct  
	 SELECT SrpCde,SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo,Reasonid,UploadFlag
	 FROM OPENXML (@hdoc,'/Root/Mob2Cos_SalesReturnProduct',1)  
	 WITH   
	 (  
		SrpCde	varchar(100),
		SrNo	nvarchar(100),
		PrdId	int,
		PrdBatId	int,
		PriceId	int,
		SrQty	int,
		UsrStkTyp	int,
		salinvno	varchar(100),
		SlNo	int,
		UploadFlag	varchar(1),
		Reasonid	int
	) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  
	END
  IF @PROCESSNAME = 'Receiptinvoice'

	BEGIN
	 DELETE FROM ImportProductPDA_Receiptinvoice  WHERE UploadFlag='Y'  
   
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  

	 INSERT INTO ImportProductPDA_Receiptinvoice  
	 SELECT 
		SrpCde,
		InvRcpNo,
		InvRcpDate,
		InvrcpAmt,
		SalInvNo,
		CONVERT(DATETIME,CONVERT(VARCHAR(10),SalInvDate,121),121),
		SalInvAmt,
		InvRcpMode,
		BnkBrId,
		InvInsNo,
		CONVERT(DATETIME,CONVERT(VARCHAR(10),InvInsDate,121),121),
		CONVERT(DATETIME,CONVERT(VARCHAR(10),InvDepDate,121),121), 
		InvInsSta,
		CashAmt,
		ChequeAmt,
		UploadFlag,
		RtrCode
	FROM OPENXML (@hdoc,'/Root/Mob2Cos_Receiptinvoice',1)  
	 WITH   
	 (  
		SrpCde		VARCHAR(50),
		InvRcpNo	VARCHAR(50),
		InvRcpDate	NVARCHAR(25),	 
		InvrcpAmt	NUMERIC(18,2),	 
		SalInvNo	VARCHAR(25),
		SalInvDate	NVARCHAR(100),
		SalInvAmt	FLOAT,	 
		InvRcpMode	VARCHAR(1),
		BnkBrId		INT,	 
		InvInsNo	NVARCHAR(100),
		InvInsDate	NVARCHAR(25),	 
		InvDepDate	NVARCHAR(25),	 
		InvInsSta	VARCHAR(1),
		CashAmt		NUMERIC	(18,2),
		ChequeAmt	NUMERIC	(18,2),
		UploadFlag	VARCHAR(1),
		RtrCode		varchar(50)
	) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  

 END
 IF @PROCESSNAME = 'Import_CreditNote'

 BEGIN
	 DELETE FROM ImportProductPDA_CreditNote  WHERE UploadFlag='Y'  
   
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportProductPDA_CreditNote  
	 SELECT SrpCde,InvRcpNo,CrNo,CrAmount,SalInvNo,RtrId,CrAdjAmount,TranNo,Reasonid,UploadFlag
	 FROM OPENXML (@hdoc,'/Root/Import_CreditNote',1)  
	 WITH   
	 (  
		SrpCde	varchar(100),InvRcpNo VARCHAR(50),
		CrNo	varchar(100),
		CrAmount	numeric(18,6),
		SalInvNo VARCHAR(25),RtrId NUMERIC(18,2),CrAdjAmount NUMERIC(18,2),
		TranNo	varchar(100),
		Reasonid	int,
		UploadFlag	varchar(1)

	) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  
 END
  IF @PROCESSNAME = 'Import_DebitNote'

	BEGIN
	 DELETE FROM ImportProductPDA_DebitNote  WHERE UploadFlag='Y'  
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportProductPDA_DebitNote  
	 SELECT SrpCde,DbNo,DbAmount,RtrId,DbAdjAmount,TransNo,Reasonid,UploadFlag
	 FROM OPENXML (@hdoc,'/Root/Import_DebitNote',1)  
	 WITH   
	 (  
		SrpCde	varchar(100),
		DbNo	varchar(100),
		DbAmount	numeric(18,6),
		RtrId	numeric(18,6),
		DbAdjAmount	numeric(18,6),
		TransNo	varchar(100),
		Reasonid	int,
		UploadFlag	varchar(1)
	) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  

	END
  IF @PROCESSNAME = 'NewRetailer'

	BEGIN
	 DELETE FROM ImportProductPDA_NewRetailer  WHERE UploadFlag='Y'  
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportProductPDA_NewRetailer  
	 SELECT SrpCde,RtrCode,RetailerName,CtgLevelId,CtgMainID,RtrClassId,RtrAdd1,RtrAdd2,RtrAdd3,RtrPhoneNo,CreditAvailable,RtrTINNo,UploadFlag,Longitude,Latitude,RtrMobileNo
	 FROM OPENXML (@hdoc,'/Root/Mob2Cos_NewRetailer',1)  
	 WITH   
	 (  
		SrpCde NVARCHAR(100),
		RtrCode NVARCHAR(100),
		RetailerName NVARCHAR(200),
		CtgLevelId int,
		CtgMainID int,
		RtrClassId int,
		RtrAdd1 nvarchar (200),
		RtrAdd2 nvarchar (200),
		RtrAdd3 nvarchar (200),
		RtrPhoneNo nvarchar (200),
		CreditAvailable numeric(18,6),
		RtrTINNo nvarchar (200),
		UploadFlag	VARCHAR(1),
		Longitude VARCHAR(50),
		Latitude VARCHAR(50),
		RtrMobileNo NVARCHAR(100)
	) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  

	END
IF @PROCESSNAME = 'NonProductiveRetailers'
  BEGIN
	 DELETE FROM ImportProductPDA_NonProductiveRetailers  WHERE UploadFlag='Y'  
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportProductPDA_NonProductiveRetailers  
	 SELECT SrpCde,RtrCode,ReasonId,NonProdDate,UploadFlag
	 FROM OPENXML (@hdoc,'/Root/NonProductiveRetailers',1)  
	 WITH   
	 (  
		SrpCde varchar(50),
		RtrCode nvarchar(50),
		ReasonId int ,
		NonProdDate datetime,
		UploadFlag varchar(1)
	) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  
	  END	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='PROC_PDA_LATANDLAO_VALUES')
DROP PROCEDURE PROC_PDA_LATANDLAO_VALUES
GO
/*
	BEGIN TRAN
	EXEC PROC_PDA_LATANDLAO_VALUES	167,'RTSM01201402192'
	SELECT * FROM UDCDETAILS WHERE UDCMASTERID IN (10,11)
	AND MASTERRECORDID IN (170)
	SELECT * FROM PDA_NEWRETAILER
	SELECT * FROM RETAILER WHERE RTRCODE='RTSM01201402192'
	SELECT * FROM COUNTERS WHERE TABNAME LIKE '%UDC%'
	ROLLBACK TRAN
	SELECT * FROM UDCMASTER
*/
CREATE PROCEDURE PROC_PDA_LATANDLAO_VALUES
(
	@PI_RTRID		BIGINT,
	@PDA_RTRCODE	VARCHAR(100)
)
AS
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE  : PROC_PDA_LATANDLAO_VALUES
* PURPOSE    : TO UPDATE UDC VALUES THROUGH PDA RETAILER SAVE OPTION
* CREATED BY : PRAVEENRAJ B
* CREATED ON : 21/02/2014
* MODIFICATION
*****************************************************************************/
BEGIN
		IF NOT EXISTS (SELECT * FROM PDA_NewRetailer WHERE CustomerCode=@PDA_RTRCODE) RETURN
--		DECLARE @LAT_EXISTS TABLE
--		(
--			MASTERID		INT,
--			UDCMASTERID		INT,
--			MASTERRECORDID	INT
--		)
--		DECLARE @LAT_NEW TABLE
--		(
--			MASTERID		INT,
--			UDCMASTERID		INT,
--			MASTERRECORDID	INT,
--			LATITUDE		NUMERIC(38,2)
--		)
--		DECLARE @UDCDET_LAT TABLE
--		(
--			SLNO	BIGINT IDENTITY (1,1),
--			UDCDETAILSID	BIGINT,
--			UDCMASTERID INT,
--			MASTERID INT,
--			MASTERRECORDID INT,
--			COLVAL	INT,
--			UDCUNIQUEID	INT	
--		)
		
--		INSERT INTO @LAT_EXISTS
--		SELECT U.MASTERID,U.UdcMasterId,D.MasterRecordId FROM UdcMaster U INNER JOIN UdcDetails D ON U.MasterId=D.MasterId AND U.UdcMasterId=D.UdcMasterId
--		WHERE U.MasterId=2 AND U.UdcMasterId IN (SELECT UdcMasterId FROM UdcMaster WHERE MasterId=2 AND UPPER(LTRIM(RTRIM(ColumnName)))='LATITUDE')
--		AND D.MasterRecordId=@PI_RTRID
--		INSERT INTO @LAT_NEW
--		SELECT 2,(SELECT UdcMasterId FROM UdcMaster WHERE MasterId=2 AND UPPER(LTRIM(RTRIM(ColumnName)))='LATITUDE'),R.RtrId,
--		(SELECT ISNULL(LATITIUDE,0) FROM PDA_NewRetailer WHERE CustomerCode=@PDA_RTRCODE) FROM Retailer R 		
--		WHERE NOT EXISTS (SELECT * FROM @LAT_EXISTS B WHERE B.MASTERRECORDID=R.RtrId) AND R.RtrId=@PI_RTRID
		
--		IF EXISTS (SELECT * FROM @LAT_NEW)
--		BEGIN
--			INSERT INTO @UDCDET_LAT 
--			SELECT (SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UdcDetailsId') UDCDETAILSID,UdcMasterId,MasterId,MASTERRECORDID,LATITUDE,(SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UDCUniqueId') FROM @LAT_NEW
--			UPDATE @UDCDET_LAT SET UDCDETAILSID=SLNO+UDCDETAILSID
--			INSERT INTO UdcDetails (UdcDetailsId,UdcMasterId,MasterId,MasterRecordId,ColumnValue,UDCUniqueId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
--			SELECT UDCDETAILSID,UDCMASTERID,MASTERID,MASTERRECORDID,COLVAL,UDCUNIQUEID,1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate,0 Upload FROM @UDCDET_LAT
----			UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
--			UPDATE Counters SET CurrValue=(SELECT MAX(UDCDETAILSID) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
--		END
		
--		DECLARE @LONG_EXISTS TABLE
--		(
--			MASTERID		INT,
--			UDCMASTERID		INT,
--			MASTERRECORDID	INT
--		)
--		DECLARE @LONG_NEW TABLE
--		(
--			MASTERID		INT,
--			UDCMASTERID		INT,
--			MASTERRECORDID	INT,
--			LONGTITUDE		NUMERIC(38,2)
--		)
--		DECLARE @UDCDET_LONG TABLE
--		(
--			SLNO	BIGINT IDENTITY (1,1),
--			UDCDETAILSID	BIGINT,
--			UDCMASTERID INT,
--			MASTERID INT,
--			MASTERRECORDID INT,
--			COLVAL	INT,
--			UDCUNIQUEID	INT	
--		)
		
--		INSERT INTO @LONG_EXISTS
--		SELECT U.MASTERID,U.UdcMasterId,D.MasterRecordId FROM UdcMaster U INNER JOIN UdcDetails D ON U.MasterId=D.MasterId AND U.UdcMasterId=D.UdcMasterId
--		WHERE U.MasterId=2 AND U.UdcMasterId IN (SELECT UdcMasterId FROM UdcMaster WHERE MasterId=2 AND UPPER(LTRIM(RTRIM(ColumnName)))='LONGITUDE')
--		AND D.MasterRecordId=@PI_RTRID
--		INSERT INTO @LONG_NEW
--		SELECT 2,(SELECT UdcMasterId FROM UdcMaster WHERE MasterId=2 AND UPPER(LTRIM(RTRIM(ColumnName)))='LONGITUDE'),R.RtrId,
--		(SELECT MAX(ISNULL(LONGTITUDE,0)) FROM PDA_NewRetailer WHERE CustomerCode=@PDA_RTRCODE) FROM Retailer R 
--		WHERE NOT EXISTS (SELECT * FROM @LAT_EXISTS B WHERE B.MASTERRECORDID=R.RtrId) AND R.RtrId=@PI_RTRID
		
--		IF EXISTS (SELECT * FROM @LONG_NEW)
--		BEGIN
--			INSERT INTO @UDCDET_LONG
--			SELECT (SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UdcDetailsId') UDCDETAILSID,UdcMasterId,MasterId,MASTERRECORDID,LONGTITUDE,(SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UDCUniqueId') FROM @LONG_NEW
--			UPDATE @UDCDET_LONG SET UDCDETAILSID=SLNO+UDCDETAILSID
--			INSERT INTO UdcDetails (UdcDetailsId,UdcMasterId,MasterId,MasterRecordId,ColumnValue,UDCUniqueId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
--			SELECT UDCDETAILSID,UDCMASTERID,MASTERID,MASTERRECORDID,COLVAL,UDCUNIQUEID,1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate,0 Upload FROM @UDCDET_LONG
--			--UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
--			UPDATE Counters SET CurrValue=(SELECT MAX(UDCDETAILSID) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
--		END

		UPDATE UDC SET UDC.COLUMNVALUE=(SELECT ISNULL(MAX(Latitude),0) FROM PDA_NEWRETAILER WHERE CUSTOMERCODE=@PDA_RTRCODE),UDC.UPLOAD=0 
		FROM UDCDETAILS UDC 
		INNER JOIN UDCMASTER M ON M.MASTERID=UDC.MASTERID AND M.UDCMASTERID=UDC.UDCMASTERID
		INNER JOIN RETAILER R ON R.RTRID=UDC.MASTERRECORDID
		WHERE UDC.MASTERID=2 AND UDC.UDCMASTERID IN (SELECT UDCMASTERID FROM UDCMASTER WHERE MASTERID=2 AND UPPER(LTRIM(RTRIM(COLUMNNAME)))='LATITUDE')
		
		UPDATE UDC SET UDC.COLUMNVALUE=(SELECT ISNULL(MAX(Longitude),0) FROM PDA_NEWRETAILER WHERE CUSTOMERCODE=@PDA_RTRCODE),UDC.UPLOAD=0 
		FROM UDCDETAILS UDC 
		INNER JOIN UDCMASTER M ON M.MASTERID=UDC.MASTERID AND M.UDCMASTERID=UDC.UDCMASTERID
		INNER JOIN RETAILER R ON R.RTRID=UDC.MASTERRECORDID
		WHERE UDC.MASTERID=2 AND UDC.UDCMASTERID IN (SELECT UDCMASTERID FROM UDCMASTER WHERE MASTERID=2 AND UPPER(LTRIM(RTRIM(COLUMNNAME)))='LONGITUDE')
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_PDA_UomMaster' AND XTYPE ='P')
DROP PROCEDURE Proc_Export_PDA_UomMaster
GO
--EXEC Proc_Export_PDA_UomMaster SM1 
CREATE PROCEDURE Proc_Export_PDA_UomMaster
AS
BEGIN
	DECLARE @Discode as varchar(50)
	SELECT @Discode=distributorcode FROM distributor
	
		DELETE FROM Cos2Mob_UomMaster 
		INSERT INTO Cos2Mob_UomMaster (Distcode,SrpCde,UomGroupId,UomGroupCode,UomGroupDescription,UomId,UomCode,
										UomDescription,BaseUom,ConversionFactor,UploadFlag)
										
		SELECT @Discode,SMCODE,UomGroupId,UomGroupCode,UomGroupDescription,UG.UomId,UomCode,
			   UomDescription,BaseUom,ConversionFactor,'N' UploadFlag 
	    FROM UOMGROUP UG INNER JOIN UOMMASTER UM ON UG.UOMID=UM.UOMID
		CROSS JOIN (SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
		
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_SFA_RetailerCategory' AND XTYPE='P')
DROP PROCEDURE Proc_SFA_RetailerCategory
GO
--EXEC Proc_SFA_RetailerCategory
--SELECT * FROM SFA_RetailerCategory
CREATE PROCEDURE Proc_SFA_RetailerCategory
AS
BEGIN
		DELETE PRK FROM SFA_RetailerCategory PRK (NOLOCK)
		
		INSERT INTO SFA_RetailerCategory (DistCode,RetCatId,ChannelCode,ChannelName,SubChannelCode,SubChannelName,GroupCode,GroupName,ClassCode,
										  ClassName,UploadFlag)
		SELECT DISTINCT DistributorCode,V.RtrClassId,
		C2.CtgCode [Channel Code],C2.CtgName [Channel Name] ,
		'' [Sub Channel Code],'' [Sub Channel Name],
		C1.CtgCode [Category Code],C1.CtgName [Category Name],
		V.ValueClassCode,V.ValueClassName,'N'	 UploadFlag	
		FROM 
		RetailerValueClass V (NOLOCK) 
		INNER JOIN (Select B.CtgLinkId,B.CtgMainId,B.CtgCode,B.CtgName from Cos2Mob_RetailerCategoryLevel A (NOLOCK) INNER JOIN Cos2Mob_RetailerCategory B (NOLOCK) ON A.CtgLevelId=B.CtgLevelId Where A.CtgLevelId=2) C1
		ON C1.CtgMainId=V.CtgMainId
		INNER JOIN (Select B.CtgLinkId,B.CtgMainId,B.CtgCode,B.CtgName from Cos2Mob_RetailerCategoryLevel A (NOLOCK) INNER JOIN Cos2Mob_RetailerCategory B (NOLOCK) ON A.CtgLevelId=B.CtgLevelId Where A.CtgLevelId=1) C2
		ON C1.CtgLinkId=C2.CtgMainId
		CROSS JOIN Distributor
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Mob2Cos_SalesmanPDADetails' AND xtype='U')
DROP TABLE Mob2Cos_SalesmanPDADetails
GO
CREATE TABLE Mob2Cos_SalesmanPDADetails
(
	[Slno] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) NULL,
	[Date] [datetime] NULL,
	[SmCode] [varchar](50) NULL,
	[RMId] [int] NULL,
	[RtrId] [int] NULL,
	[OrderNo] [varchar](50) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[NorOrDayend] [tinyint] NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Calculated_SalesmanPDADetails' AND xtype='U')
DROP TABLE Calculated_SalesmanPDADetails
GO
CREATE TABLE Calculated_SalesmanPDADetails
(
	[Date] [datetime] NULL,
	[SM] [varchar](10) NULL,
	[Beat] [int] NULL,
	[RTRID] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[TotalTime] [datetime] NULL,
	[TotnumofoutletsinBeat] [int] NULL,
	[TotNumofOutletsCovered] [int] NULL,
	[TottimeinOutlet] [datetime] NULL,
	[TotTravellingtime] [datetime] NULL,
	[AvgTimeperOutlet] [numeric](18, 2) NULL,
	[NumofSKUsOrdered] [int] NULL,
	[TotValueofOrderCollected] [numeric](38, 6) NULL,
	[Upload] [tinyint] NULL
)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Cs2Cn_Prk_Calculated_SalesmanPDADetails' AND xtype='U')
DROP TABLE Cs2Cn_Prk_Calculated_SalesmanPDADetails
GO
CREATE TABLE Cs2Cn_Prk_Calculated_SalesmanPDADetails
(
	[Slno] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) NULL,
	[Date] [datetime] NULL,
	[SMCode] [varchar](50) NULL,
	[BeatCode] [varchar](50) NULL,
	[DistRtrCode] [varchar](50) NULL,
	[StartTime] [varchar](25) NULL,
	[EndTime] [varchar](25) NULL,
	[TotalTime] [varchar](25) NULL,
	[TotnumofoutletsinBeat] [int] NULL,
	[TotNumofOutletsCovered] [int] NULL,
	[TottimeinOutlet] [varchar](25) NULL,
	[TotTravellingtime] [varchar](25) NULL,
	[AvgTimeperOutlet] [numeric](18, 2) NULL,
	[NumofSKUsOrdered] [int] NULL,
	[TotValueofOrderCollected] [numeric](38, 6) NULL,
	[UploadFlag] [varchar](1) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='SalesmanPDADetails' AND xtype='U')
DROP TABLE SalesmanPDADetails
GO
CREATE TABLE SalesmanPDADetails
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[SmCode] [varchar](50) NULL,
	[RMId] [int] NULL,
	[RtrId] [int] NULL,
	[OrderNo] [varchar](50) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[NorOrDayend] [tinyint] NULL,
	[Upload] [tinyint] NULL
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_Calculated_SalesmanPDADetailsWDSM' AND XTYPE='P')
DROP PROCEDURE PROC_Calculated_SalesmanPDADetailsWDSM
GO
CREATE PROCEDURE PROC_Calculated_SalesmanPDADetailsWDSM
(
	@PO_ERRNO INT OUT
)
AS
SET NOCOUNT ON
BEGIN
	SET @PO_ERRNO=0
	
	--IF NOT EXISTS (SELECT * FROM SalesmanPDADetails (NOLOCK) WHERE NorOrDayend=2 AND [DATE]=CONVERT(VARCHAR(10),GETDATE(),121))
	--BEGIN
	--	PRINT 'DAY END NOT COMPLETED FOR TODAYS DATE'
	--	RETURN
	--END
	
	CREATE TABLE #SalesmanPDADetails
	(
			SlNo			NUMERIC(38,0) IDENTITY (1,1),
			[Date]			DATETIME,
			SmCode			VARCHAR(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,
			RMId			INT,
			RtrId			INT,
			OrderNo			VARCHAR(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,
			StartTime		DATETIME,
			EndTime			DATETIME,
			NorOrDayend		TINYINT
	)
	
	CREATE TABLE #Calculated_SalesmanPDADetails
		(
			SlNo							NUMERIC(38,0) IDENTITY (1,1),
			[Date]							DATETIME,
			SM								VARCHAR(10)  COLLATE SQL_Latin1_General_CP1_CI_AS,
			Beat							INT,
			RTRID							INT,
			StartTime						DATETIME,
			EndTime							DATETIME,
			TotalTime						DATETIME,
			TotnumofoutletsinBeat			INT,
			TotNumofOutletsCovered			INT,
			TottimeinOutlet					DATETIME,
			TotTravellingtime				DATETIME,
			AvgTimeperOutlet				NUMERIC(18,2),
			NumofSKUsOrdered				INT,
			TotValueofOrderCollected		NUMERIC(38,6),
			upload							tinyint
		)
	
	INSERT INTO #SalesmanPDADetails ([Date],SmCode,RMId,RtrId,OrderNo,StartTime,EndTime,NorOrDayend)
	--SELECT [Date],SmCode,RMId,RtrId,OrderNo,StartTime,EndTime,NorOrDayend FROM SalesmanPDADetails WHERE [DATE]<=CONVERT(VARCHAR(10),GETDATE(),1)
	--AND UPLOAD=0 ORDER BY SLNO,StartTime
	SELECT [DATE] ,SmCode,RMId,RtrId,MAX(OrderNo) OrderNo,MIN(StartTime) StartTime,MAX(EndTime) EndTime,NorOrDayend FROM SalesmanPDADetails WHERE [DATE]<=CONVERT(VARCHAR(10),GETDATE(),1)
	AND UPLOAD=0
	GROUP BY [DATE] ,SmCode,RMId,RtrId,NorOrDayend
	ORDER BY StartTime
	
	INSERT INTO #Calculated_SalesmanPDADetails (Date,SM,Beat,RTRID,StartTime,EndTime,TotalTime,TotnumofoutletsinBeat,TotNumofOutletsCovered,TottimeinOutlet,
											   TotTravellingtime,AvgTimeperOutlet,NumofSKUsOrdered,TotValueofOrderCollected)
	
	SELECT [Date],SmCode,RMId,RtrId,StartTime,EndTime,0,0,0,0,0,0,0,0 FROM #SalesmanPDADetails 
	WHERE [DATE]<=CONVERT(VARCHAR(10),GETDATE(),1) ORDER BY SLNO,StartTime
	
	SELECT SM.SMID,SM.SMCode,RM.RMId,RM.RMCode,COUNT(DISTINCT R.RtrId) RTRCOUNT INTO #RTRCOUNT FROM Salesman SM 
	INNER JOIN SalesmanMarket SMM ON SM.SMId=SMM.SMId
	INNER JOIN RouteMaster RM ON RM.RMId=SMM.RMId
	INNER JOIN RetailerMarket RMM ON RMM.RMId=RM.RMId
	INNER JOIN Retailer R ON R.RtrId=RMM.RtrId
	WHERE R.RtrStatus=1
	GROUP BY SM.SMID,SM.SMCode,RM.RMId,RM.RMCode
	
	UPDATE MM SET MM.TotnumofoutletsinBeat=ISNULL(SM.RTRCOUNT,0) FROM #Calculated_SalesmanPDADetails MM
	INNER JOIN #RTRCOUNT SM ON MM.Beat=SM.RMId AND SM.SMCode=MM.SM
	
	UPDATE MM SET MM.TotNumofOutletsCovered=X.RTRCOV FROM #Calculated_SalesmanPDADetails MM
	INNER JOIN (SELECT SmCode,RMId,[DATE],ISNULL(COUNT(DISTINCT RtrId),0) RTRCOV FROM #SalesmanPDADetails GROUP BY SmCode,RMId,[DATE]) X 
	ON X.SmCode=MM.SM AND X.RMId=MM.Beat AND X.[Date]=MM.[Date]
	
	UPDATE MM SET MM.TottimeinOutlet=MM.EndTime-MM.StartTime	 FROM #Calculated_SalesmanPDADetails MM
	INNER JOIN #SalesmanPDADetails TMP ON TMP.SmCode=MM.SM AND TMP.RMId=MM.Beat AND TMP.[Date]=MM.[Date]
	
	--UPDATE MM SET MM.TottimeinOutlet=ISNULL(SUM(X.TOTALTIME),0) FROM Calculated_SalesmanPDADetails MM
	--INNER JOIN #SalesmanPDADetails TMP ON TMP.SmCode=MM.SM AND TMP.RMId=MM.Beat AND TMP.[Date]=MM.[Date]
	--INNER JOIN (SELECT ISNULL(SUM(TottimeinOutlet),0)  TOTALTIME,[DATE] FROM Calculated_SalesmanPDADetails 
	--WHERE [DATE]=CONVERT(VARCHAR(10),GETDATE(),121) GROUP BY [DATE]) X ON X.[Date]=MM.[Date]
	--select * from #SalesmanPDADetails
	--SELECT SMCODE,RMId,[DATE],SLNO,rtrid,(CASE SLNO WHEN 1 THEN 0 ELSE EndTime END) EndTime INTO #TRVENDTIME FROM #SalesmanPDADetails ORDER BY SlNo ASC 
	--SELECT SMCODE,RMId,[DATE],SlNo,rtrid,StartTime INTO #TRVSTARTTIME FROM #SalesmanPDADetails WHERE SlNo<>1 ORDER BY SlNo ASC
	
	--SELECT A.SmCode,A.RMId,A.[DATE],EndTime,StartTime,a.RtrId INTO #TOTTRAVLTIME FROM #TRVSTARTTIME A INNER JOIN #TRVENDTIME B ON A.SmCode=B.SmCode
	--AND A.RMId=B.RMId AND A.Date=B.Date and a.RtrId=b.RtrId ORDER BY B.SlNo
	----select * from #TRVENDTIME
	----select * from #TRVSTARTTIME
	--select * from #TOTTRAVLTIME
	--select * from #Calculated_SalesmanPDADetails
	--select * from #Calculated_SalesmanPDADetails
	DECLARE @SLNO NUMERIC(38,0)
	DECLARE @SLNONEW NUMERIC(38,0)
	DECLARE @STARTDATE AS DATETIME
	DECLARE @ENDDATE AS DATETIME
	DECLARE @SMCODE VARCHAR(50)
	DECLARE @RMID	INT
	DECLARE @RTRID	INT
	DECLARE CUR_TVL CURSOR FOR SELECT Starttime,Endtime,SLNO,SM,RTRID,BEAT FROM #Calculated_SalesmanPDADetails ORDER BY SLNO
	OPEN CUR_TVL
	FETCH NEXT FROM CUR_TVL INTO @STARTDATE,@ENDDATE,@SLNO,@SMCODE,@RTRID,@RMID  
	WHILE @@FETCH_STATUS=0
	BEGIN
			SET @SLNONEW=@SLNO+1
			SELECT @ENDDATE=endtime FROM #Calculated_SalesmanPDADetails WHERE SLNO=@SLNO order by SlNo--AND RTRID=@RTRID AND Beat=@RMID AND SM=@SMCODE
			SELECT @STARTDATE=starttime FROM #Calculated_SalesmanPDADetails WHERE SLNO=@SLNONEW order by SlNo-- AND RTRID=@RTRID AND Beat=@RMID AND SM=@SMCODE
			
			
			UPDATE #Calculated_SalesmanPDADetails SET TotTravellingtime=CASE @SLNONEW WHEN 1 THEN 0 ELSE 
			@STARTDATE-@ENDDATE END WHERE SLNO=@SLNONEW --AND RTRID=@RTRID AND Beat=@RMID AND SM=@SMCODE
	
	FETCH NEXT FROM CUR_TVL INTO @STARTDATE,@ENDDATE,@SLNO,@SMCODE,@RTRID,@RMID    
	END
	CLOSE CUR_TVL
	DEALLOCATE CUR_TVL
	--UPDATE MM SET MM.TotTravellingtime=ISNULL((B.EndTime-B.StartTime),0) FROM #Calculated_SalesmanPDADetails MM 
	--INNER JOIN #TOTTRAVLTIME B ON MM.SM=B.SmCode AND MM.Beat=B.RMId AND MM.[Date]=B.[Date] AND MM.StartTime=B.StartTime
	--and mm.RTRID=b.RtrId
	
		--DECLARE @TOTTIME NUMERIC(18,6)		
		--SELECT @TOTTIME=SUM(DATEDIFF(MINUTE,0,TottimeinOutlet))/60.0 FROM #Calculated_SalesmanPDADetails 
		--UPDATE #Calculated_SalesmanPDADetails SET TotalTime=@TOTTIME
		
		declare @start_time as datetime
		declare @end_time as Datetime
		select @start_time=StartTime from #Calculated_SalesmanPDADetails Where SlNo=1
		select @end_time=endtime from #Calculated_SalesmanPDADetails where SlNo in (select isnull(MAX(SlNo),0) from #Calculated_SalesmanPDADetails )
		update #Calculated_SalesmanPDADetails set TotalTime=@end_time-@start_time
	--UPDATE MM SET MM.AvgTimeperOutlet=ISNULL((TottimeinOutlet/TotalTime),0) FROM Calculated_SalesmanPDADetails MM 
	--INNER JOIN #SalesmanPDADetails B ON MM.SM=B.SmCode AND MM.Beat=B.RMId AND MM.[Date]=B.[Date]
	
	UPDATE A SET A.NumofSKUsOrdered=B.PRDCNT,A.TotValueofOrderCollected=B.GrossAmount FROM #Calculated_SalesmanPDADetails A INNER JOIN (
	SELECT ISNULL(COUNT(DISTINCT PrdId),0) PRDCNT,ISNULL(SUM(DISTINCT ORDP.GrossAmount),0) GrossAmount,ORD.RtrId,ORD.OrderDate,S.SMCode,ORD.RmId
	FROM OrderBooking ORD INNER JOIN OrderBookingProducts ORDP ON ORD.OrderNo=ORDP.OrderNo
	INNER JOIN #Calculated_SalesmanPDADetails CAL ON CAL.Beat=ORD.RmId AND CAL.Date=ORD.OrderDate
	INNER JOIN SalesmanPDADetails P ON P.SmCode=CAL.SM AND P.RMId=CAL.Beat AND P.Date=CAL.Date AND P.OrderNo=ORD.DocRefNo and p.RtrId=ord.RtrId
	INNER JOIN Salesman S ON S.SMCode=CAL.SM AND S.SMId=ORD.SmId
	WHERE ORD.PDADownLoadFlag=1 GROUP BY ORD.RtrId,ORD.OrderDate,S.SMCode,ORD.RmId,ORD.RtrId) B ON A.Beat=B.RmId AND A.Date=B.OrderDate AND A.SM=B.SMCode
	and a.RTRID=b.RtrId
	
	UPDATE #Calculated_SalesmanPDADetails SET AvgTimeperOutlet=(DATEDIFF(MINUTE,0,TottimeinOutlet)/60.0)/TotNumofOutletsCovered
	UPDATE #Calculated_SalesmanPDADetails SET upload=0
	
	INSERT INTO Calculated_SalesmanPDADetails (Date,SM,Beat,RTRID,StartTime,EndTime,TotalTime,TotnumofoutletsinBeat,TotNumofOutletsCovered,TottimeinOutlet,
											   TotTravellingtime,AvgTimeperOutlet,NumofSKUsOrdered,TotValueofOrderCollected,Upload)
	SELECT Date,SM,Beat,RTRID,StartTime,EndTime,TotalTime,TotnumofoutletsinBeat,TotNumofOutletsCovered,TottimeinOutlet,
											   TotTravellingtime,AvgTimeperOutlet,NumofSKUsOrdered,TotValueofOrderCollected,Upload FROM #Calculated_SalesmanPDADetails ORDER BY SlNo
	UPDATE PRK SET PRK.Upload=1 FROM SalesmanPDADetails PRK INNER JOIN #SalesmanPDADetails TMP ON PRK.Date=TMP.Date AND PRK.RMId=TMP.RMId AND PRK.SmCode=TMP.SmCode
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_PDASALESMANDETAILS' AND XTYPE='P')
DROP PROCEDURE PROC_PDASALESMANDETAILS
GO
CREATE PROCEDURE PROC_PDASALESMANDETAILS
(
	@SalRpCode VARCHAR(50)
)
AS
BEGIN
		DELETE PRK FROM Mob2Cos_SalesmanPDADetails PRK (NOLOCK) where UploadFlag='Y'
		
		DECLARE @DETAILSTOAVOID TABLE
		(
			SMCODE	VARCHAR(50),
			RMID	INT,
			RTRID	INT
		)
		
		CREATE TABLE #Mob2Cos_SalesmanPDADetails
		(
			DistCode		VARCHAR(50)		COLLATE SQL_Latin1_General_CP1_CI_AS,
			[Date]			DATETIME,
			SmCode			VARCHAR(50)		COLLATE SQL_Latin1_General_CP1_CI_AS,
			RMId			INT,
			RtrId			INT,
			OrderNo			VARCHAR(50)		COLLATE SQL_Latin1_General_CP1_CI_AS,
			StartTime		DATETIME,
			EndTime			DATETIME,
			NorOrDayend		TINYINT,
			UploadFlag		VARCHAR(1)		COLLATE SQL_Latin1_General_CP1_CI_AS
		)
		
		INSERT INTO #Mob2Cos_SalesmanPDADetails (DistCode,[Date],SmCode,RMId,RtrId,OrderNo,StartTime,EndTime,NorOrDayend,UploadFlag)
		SELECT DistCode,[Date],SmCode,RMId,RtrId,OrderNo,StartTime,EndTime,NorOrDayend,UploadFlag FROM Mob2Cos_SalesmanPDADetails (NOLOCK) WHERE UPLOADFLAG='N'
		
		--IF NOT EXISTS (SELECT * FROM #Mob2Cos_SalesmanPDADetails (NOLOCK) WHERE UploadFlag='N') RETURN
		
		
		IF NOT EXISTS (SELECT * FROM Salesman (NOLOCK) WHERE SMCode=@SalRpCode)
		BEGIN
			INSERT INTO PDALog (SrpCde,DataPoint,Name,Description)
			SELECT @SalRpCode,'SMCODE','Mob2Cos_SalesmanPDADetails','SALESMAN CODE NOT EXISTS SMCODE-->' +@SalRpCode
			RETURN
		END
		
		INSERT INTO @DETAILSTOAVOID (SMCODE,RMID,RTRID)
		SELECT PRK.SmCode,RMId,RtrId FROM #Mob2Cos_SalesmanPDADetails PRK (NOLOCK) WHERE NOT EXISTS (SELECT * FROM SALESMAN SM (NOLOCK) WHERE SM.SMCODE=PRK.SMCODE)
		
		INSERT INTO PDALog (SrpCde,DataPoint,Name,Description)
		SELECT @SalRpCode,'SMCODE','Mob2Cos_SalesmanPDADetails','SALESMAN CODE NOT EXISTS SMCODE-->' +PRK.SmCode
		FROM #Mob2Cos_SalesmanPDADetails PRK (NOLOCK) WHERE NOT EXISTS (SELECT * FROM SALESMAN SM (NOLOCK) WHERE SM.SMCODE=PRK.SMCODE)
		
		DELETE PRK FROM #Mob2Cos_SalesmanPDADetails PRK INNER JOIN @DETAILSTOAVOID DT ON PRK.SmCode=DT.SMCODE AND PRK.RMId=DT.RMID AND PRK.RtrId=DT.RTRID
		
		INSERT INTO @DETAILSTOAVOID (SMCODE,RMID,RTRID)
		SELECT PRK.SmCode,RMId,RtrId FROM #Mob2Cos_SalesmanPDADetails PRK (NOLOCK) WHERE NOT EXISTS (SELECT * FROM RouteMaster RM (NOLOCK) WHERE RM.RMId=PRK.RMId)
		
		INSERT INTO PDALog (SrpCde,DataPoint,Name,Description)
		SELECT @SalRpCode,'RMCODE','Mob2Cos_SalesmanPDADetails','ROUTE NOT EXISTS FOR SALESMAN -->' +PRK.SMCODE 
		FROM #Mob2Cos_SalesmanPDADetails PRK (NOLOCK) WHERE NOT EXISTS (SELECT * FROM RouteMaster RM (NOLOCK) WHERE RM.RMId=PRK.RMId)
		
		DELETE PRK FROM #Mob2Cos_SalesmanPDADetails PRK INNER JOIN @DETAILSTOAVOID DT ON PRK.SmCode=DT.SMCODE AND PRK.RMId=DT.RMID AND PRK.RtrId=DT.RTRID
		
		INSERT INTO @DETAILSTOAVOID (SMCODE,RMID,RTRID)
		SELECT PRK.SmCode,RMId,RtrId FROM #Mob2Cos_SalesmanPDADetails PRK (NOLOCK) WHERE NOT EXISTS (SELECT * FROM Retailer RTM (NOLOCK) WHERE RTM.RtrId=PRK.RtrId)
		
		INSERT INTO PDALog (SrpCde,DataPoint,Name,Description)
		SELECT @SalRpCode,'RTRCODE','Mob2Cos_SalesmanPDADetails','RETAILER NOT EXISTS FOR SALESMAN -->' +PRK.SMCODE 
		FROM #Mob2Cos_SalesmanPDADetails PRK (NOLOCK) WHERE NOT EXISTS (SELECT * FROM Retailer RTM (NOLOCK) WHERE RTM.RtrId=PRK.RtrId)
		
		DELETE PRK FROM #Mob2Cos_SalesmanPDADetails PRK INNER JOIN @DETAILSTOAVOID DT ON PRK.SmCode=DT.SMCODE AND PRK.RMId=DT.RMID AND PRK.RtrId=DT.RTRID
		
		INSERT INTO SalesmanPDADetails (Date,SmCode,RMId,RtrId,OrderNo,StartTime,EndTime,NorOrDayend,Upload)
		SELECT MAIN.Date,MAIN.SmCode,MAIN.RMId,MAIN.RtrId,MAIN.OrderNo,MAIN.StartTime,MAIN.EndTime,MAIN.NorOrDayend,0 FROM #Mob2Cos_SalesmanPDADetails PRK (NOLOCK)
		INNER JOIN Mob2Cos_SalesmanPDADetails MAIN ON MAIN.SmCode=PRK.SmCode AND MAIN.RMId=PRK.RMId AND MAIN.RtrId=PRK.RtrId AND MAIN.OrderNo=PRK.OrderNo
		WHERE NOT EXISTS (SELECT * FROM @DETAILSTOAVOID DT WHERE DT.SMCODE=MAIN.SmCode AND DT.RMID=MAIN.RMId AND DT.RTRID=MAIN.RtrId)
		
		UPDATE MAIN SET MAIN.UploadFlag='Y' FROM #Mob2Cos_SalesmanPDADetails PRK (NOLOCK)
		INNER JOIN Mob2Cos_SalesmanPDADetails MAIN ON MAIN.SmCode=PRK.SmCode AND MAIN.RMId=PRK.RMId AND MAIN.RtrId=PRK.RtrId AND MAIN.OrderNo=PRK.OrderNo
		INNER JOIN SalesmanPDADetails SFA ON MAIN.SmCode=SFA.SmCode AND MAIN.RMId=SFA.RMId AND MAIN.RtrId=SFA.RtrId AND MAIN.OrderNo=SFA.OrderNo
		WHERE NOT EXISTS (SELECT * FROM @DETAILSTOAVOID DT WHERE DT.SMCODE=MAIN.SmCode AND DT.RMID=MAIN.RMId AND DT.RTRID=MAIN.RtrId)
		
	--IF EXISTS (SELECT * FROM SalesmanPDADetails (NOLOCK) WHERE NorOrDayend=2 AND [DATE]=CONVERT(VARCHAR(10),GETDATE(),121))
	--BEGIN
	--	EXEC PROC_Calculated_SalesmanPDADetailsWDSM 0
	--END
	
	IF EXISTS (SELECT * FROM SalesmanPDADetails (NOLOCK) WHERE [DATE]<=CONVERT(VARCHAR(10),GETDATE(),121) AND Upload=0)
	BEGIN
	
		EXEC PROC_Calculated_SalesmanPDADetailsWDSM 0
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='TBL_INTEGRATIONPATH' AND XTYPE ='U')
DROP TABLE TBL_INTEGRATIONPATH
GO
CREATE TABLE TBL_INTEGRATIONPATH
(
	[INTEGRATION_PATH] [varchar](400) NULL,
	[INTEGRATION_TYPE] [varchar](100) NULL
)
GO
INSERT INTO TBL_INTEGRATIONPATH
SELECT 'http://220.226.206.19//ParlePDAIntegration/ExportToPDA.asmx','ExportPath'
UNION
SELECT 'http://220.226.206.19//ParlePDAIntegration/ImportToPDA.asmx','ImportPath'
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='BillStatus' AND ID IN (SELECT ID FROM SYSOBJECTS WHERE NAME='Cs2Cn_Prk_DailySales' AND XTYPE='U'))
BEGIN
	ALTER TABLE Cs2Cn_Prk_DailySales ADD BillStatus TINYINT
END
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='UploadedDate' AND ID IN (SELECT ID FROM SYSOBJECTS WHERE NAME='Cs2Cn_Prk_DailySales' AND XTYPE='U'))
BEGIN
	ALTER TABLE Cs2Cn_Prk_DailySales ADD UploadedDate DATETIME
END
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='OrderRefNo' AND ID IN (SELECT ID FROM SYSOBJECTS WHERE NAME='Cs2Cn_Prk_DailySales' AND XTYPE='U'))
BEGIN
	ALTER TABLE Cs2Cn_Prk_DailySales ADD OrderRefNo VARCHAR(50)
END
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='SFAOrderRefNo' AND ID IN (SELECT ID FROM SYSOBJECTS WHERE NAME='Cs2Cn_Prk_DailySales' AND XTYPE='U'))
BEGIN
	ALTER TABLE Cs2Cn_Prk_DailySales ADD SFAOrderRefNo VARCHAR(50)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_DailySales' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_DailySales
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_DailySales 0,'2014-09-26'
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
		SFAOrderRefNo
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
	GETDATE(),ISNULL(O.OrderNo,''),ISNULL(O.DocRefNo,'')	
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
DELETE FROM Tbl_DownloadIntegration WHERE ProcessName IN ('MarketIntelligence','MarketIntelligenceDT')
INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
SELECT 49,'MarketIntelligence','Cn2Cs_Prk_MarketIntelligenceHD','Proc_ImportMarketIntelligenceHD',0,500,CONVERT(NVARCHAR(10),GETDATE(),121) UNION
SELECT 50,'MarketIntelligenceDT','Cn2Cs_Prk_MarketIntelligenceDT','Proc_ImportMarketIntelligenceDT',0,500,CONVERT(NVARCHAR(10),GETDATE(),121)
GO
DELETE FROM CustomUpDownload WHERE UpDownload = 'Download' AND Module IN ('MarketIntelligence','MarketIntelligenceDT')
INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
SELECT 240,1,'MarketIntelligence','MarketIntelligence','','Proc_ImportMarketIntelligenceHD','Cn2Cs_Prk_MarketIntelligenceHD',
'Proc_ValidatetMarketIntelligenceHD','Master','Download',1 UNION
SELECT 241,1,'MarketIntelligenceDT','MarketIntelligenceDT','','Proc_ImportMarketIntelligenceDT','Cn2Cs_Prk_MarketIntelligenceDT',
'Proc_ValidatetMarketIntelligenceDT','Master','Download',1
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE = 'U' AND Name = 'Cn2Cs_Prk_MarketINTelligenceHD')
DROP TABLE Cn2Cs_Prk_MarketINTelligenceHD
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_MarketINTelligenceHD](
	[Distcode] [varchar](100) NULL,
	[QuestionID] [int] NULL,
	[QuestionType] [int] NULL,
	[Question] [varchar](250) NULL,
	[FROMDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[ChannelCode] [varchar](100) NULL,
	[QuestionSetID] [int] NULL,
	[DownLoadFlag] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE = 'U' AND Name = 'Cn2Cs_Prk_MarketINTelligenceDT')
DROP TABLE Cn2Cs_Prk_MarketINTelligenceDT
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_MarketINTelligenceDT](
	[Distcode] [varchar](100) NULL,
	[QuestionID] [int] NULL,
	[Answer] [varchar](200) NULL,
	[DownLoadFlag] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE = 'P' AND Name = 'Proc_ImportMarketIntelligenceHD')
DROP PROCEDURE Proc_ImportMarketIntelligenceHD
GO
CREATE PROCEDURE [dbo].[Proc_ImportMarketIntelligenceHD]
(
	@Pi_Records NTEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportMarketINTelligenceHD
* PURPOSE	: To Insert records FROM xml file in the Table Cn2Cs_Prk_MarketIntelligenceHD
* CREATED	: Murugan.R
* CREATED DATE	: 2011/12/20
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER 
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_MarketINTelligenceHD
	SELECT   [Distcode],[QuestionID],[QuestionType],[Question],[FROMDate],
		[ToDate],[ChannelCode],[QuestionSetID],[DownloadFlag],[CreatedDate] 
	FROM OPENXML (@hdoc,'/Root/Console2Cs_MarketIntelligenceHD',1)
	WITH (
            Distcode        VARCHAR(100),
			QuestionID		INT,
			QuestionType	INT,
			Question		VARCHAR(120),
			FROMDate		DATETIME,
			ToDate			DATETIME,
			ChannelCode		VARCHAR(20),
            QuestionSetID   INT, 
			DownloadFlag	VARCHAR(1),
			CreatedDate     DATETIME			
	) XMLObj	
	EXEC sp_xml_removedocument @hDoc 
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE = 'P' AND Name = 'Proc_ImportMarketIntelligenceDT')
DROP PROCEDURE Proc_ImportMarketIntelligenceDT
GO
CREATE PROCEDURE [dbo].[Proc_ImportMarketIntelligenceDT]
(
	@Pi_Records NTEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportMarketINTelligenceDT
* PURPOSE	: To Insert records FROM xml file in the Table Cn2Cs_Prk_MarketIntelligenceDT
* CREATED	: Murugan.R
* CREATED DATE	: 2011/12/20
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER 
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_MarketINTelligenceDT
	SELECT [Distcode],[QuestionID],[Answer],[DownloadFlag],[CreatedDate]
	FROM OPENXML (@hdoc,'/Root/Console2Cs_MarketIntelligenceDT',1)
	WITH (
            Distcode        VARCHAR(100),
			QuestionID		INT,
			Answer			VARCHAR(25),
			DownloadFlag    VARCHAR(10),
            CreatedDate     datetime	
				
	) XMLObj	
	EXEC sp_xml_removedocument @hDoc 
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE = 'P' AND Name = 'Proc_ValidatetMarketIntelligenceHD')
DROP PROCEDURE Proc_ValidatetMarketIntelligenceHD
GO
--EXEC Proc_ValidatetMarketIntelligenceHD 0
CREATE PROCEDURE [dbo].[Proc_ValidatetMarketIntelligenceHD]
(
	@Po_ErrNo INT OUTPUT	
)
/*********************************
* PROCEDURE	: Proc_ValidatetMarketIntelligenceHD
* PURPOSE	:To Validate the record
* CREATED	: Murugan.R
* CREATED DATE	: 2011/12/20
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
AS
SET NOCOUNT ON
BEGIN
	DECLARE @ErrDesc AS VARCHAR(1000)
	DECLARE @TabName AS VARCHAR(50)
	DECLARE @Taction AS INT	
	SET @TabName='Cn2Cs_Prk_MarketIntelligenceHD'
	SET @ErrDesc=''
	SET @Taction = 0
	SET @Po_ErrNo =0
	DELETE A FROM Cn2Cs_Prk_MarketIntelligenceHD A (NOLOCK) WHERE DownloadFlag='Y'
	DECLARE @Quest TABLE
	(
		QuestionID  INT,
		TypeId		TinyInt	
	)
	INSERT INTO @Quest(QuestionID,TypeId)
	SELECT QuestionID ,1 FROM Cn2Cs_Prk_MarketIntelligenceHD (NOLOCK) WHERE 
	(QuestionID<=0 OR  QuestionID IS NULL OR
	QuestionType IS NULL  OR QuestionType<=0 
	OR LEN(LTRIM(RTRIM(Question)))=0 OR Question IS NULL 
	OR LEN(LTRIM(RTRIM(ChannelCode)))=0 OR ChannelCode IS NULL )
	AND DownloadFlag='D'
	INSERT INTO @Quest(QuestionID,TypeId)
	SELECT A.QuestionID,2 FROM Cn2Cs_Prk_MarketIntelligenceHD A (NOLOCK) WHERE
	NOT EXISTS(SELECT B.QuestionID FROM Cn2Cs_Prk_MarketIntelligenceDT B (NOLOCK) WHERE A.QuestionID=B.QuestionID)
	AND A.DownloadFlag='D' and A.QuestionType IN(1,3)
	
	INSERT INTO @Quest(QuestionID,TypeId)
	SELECT A.QuestionID ,3 FROM Cn2Cs_Prk_MarketIntelligenceHD A (NOLOCK) INNER JOIN Cn2Cs_Prk_MarketIntelligenceDT B
	ON A.QuestionID=B.QuestionID WHERE (LEN(LTRIM(RTRIM(Answer)))=0 OR Answer IS NULL)
	AND  A.DownloadFlag='D'
	
	INSERT INTO @Quest(QuestionID,TypeId)
	SELECT A.QuestionID ,4 FROM Cn2Cs_Prk_MarketIntelligenceHD A (NOLOCK) WHERE 
	NOT EXISTS(SELECT CtgCode FROM RetailerCategory B (NOLOCK) WHERE A.ChannelCode=B.CtgCode) AND A.DownloadFlag='D'
	
	INSERT INTO @Quest(QuestionID,TypeId)
	SELECT A.QuestionID ,5 FROM Cn2Cs_Prk_MarketIntelligenceHD A (NOLOCK) WHERE 
	EXISTS(SELECT QuestionID FROM MarketIntelligenceHD B (NOLOCK) WHERE A.QuestionID=B.QuestionID)
	AND A.DownloadFlag='D'
	SET @ErrDesc = '    Mandatory Fields [QuestionID,QuestionType,Question,ChannelCode] values miss match'
	INSERT INTO Errorlog 
	SELECT 1,@TabName,'QuestionID', CAST(QuestionID AS VARCHAR(30))+@ErrDesc FROM @Quest where TypeId=1
	SET @ErrDesc = '   Detail data does not exists'
	INSERT INTO Errorlog 
	SELECT 2,@TabName,'QuestionID', CAST(QuestionID AS VARCHAR(30))+@ErrDesc FROM @Quest where TypeId=2
	SET @ErrDesc = '   Mandatory Fields [Answer] Values miss match'
	INSERT INTO Errorlog 
	SELECT 3,@TabName,'QuestionID', CAST(QuestionID AS VARCHAR(30))+@ErrDesc FROM @Quest where TypeId=3
	SET @ErrDesc = '   ChannelCode does not exists'
	INSERT INTO Errorlog 
	SELECT 4,@TabName,'QuestionID', CAST(QuestionID AS VARCHAR(30))+@ErrDesc FROM @Quest where TypeId=4
	SET @ErrDesc = '   Question Id Already Exists'
	INSERT INTO Errorlog 
	SELECT 5,@TabName,'QuestionID', CAST(QuestionID AS VARCHAR(30))+@ErrDesc FROM @Quest where TypeId=5
	
	INSERT INTO MarketIntelligenceHD(QuestionID,QuestionType,Question,FromDate,ToDate,ChannelCode,QuestionSetID,UploadFlag)
	SELECT QuestionID,QuestionType,Question,FromDate,ToDate,ChannelCode,QuestionSetID,'N'
	FROM Cn2Cs_Prk_MarketIntelligenceHD A (NOLOCK) WHERE NOT EXISTS(SELECT QuestionID FROM @Quest B WHERE A.QuestionID=B.QuestionID)
	AND A.DownloadFlag='D'
	
	UPDATE A SET DownloadFlag='Y' FROM Cn2Cs_Prk_MarketIntelligenceHD A (NOLOCK)
	INNER JOIN MarketIntelligenceHD B (NOLOCK) ON A.QuestionID=B.QuestionID
	AND A.QuestionID NOT IN(SELECT QuestionID FROM @Quest)
	
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE = 'P' AND Name = 'Proc_ValidatetMarketIntelligenceDT')
DROP PROCEDURE Proc_ValidatetMarketIntelligenceDT
GO
--EXEC Proc_ValidatetMarketIntelligenceDT 0
CREATE PROCEDURE [dbo].[Proc_ValidatetMarketIntelligenceDT]
(
	@Po_ErrNo INT OUTPUT	
)
/*********************************
* PROCEDURE	: Proc_ValidatetMarketIntelligenceDT
* PURPOSE	:To Validate the record
* CREATED	: Murugan.R
* CREATED DATE	: 2011/12/20
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
AS
SET NOCOUNT ON
BEGIN
	DECLARE @ErrDesc AS VARCHAR(1000)
	DECLARE @TabName AS VARCHAR(50)
	DECLARE @Taction AS INT	
	SET @TabName='Cn2Cs_Prk_MarketIntelligenceDT'
	SET @ErrDesc=''
	SET @Taction = 0
	SET @Po_ErrNo =0
	DELETE A FROM Cn2Cs_Prk_MarketIntelligenceDT A (NOLOCK) WHERE DownloadFlag='Y'
	DECLARE @Quest TABLE
	(
		QuestionID  INT,
		TypeId		TINYINT	
	)
	INSERT INTO @Quest(QuestionID,TypeId)
	SELECT QuestionID ,1 FROM Cn2Cs_Prk_MarketIntelligenceDT (NOLOCK) WHERE (LEN(LTRIM(RTRIM(Answer)))=0 OR Answer IS NULL)
	
	INSERT INTO @Quest(QuestionID,TypeId)
	SELECT A.QuestionID,2 FROM Cn2Cs_Prk_MarketIntelligenceDT A (NOLOCK) WHERE
	NOT EXISTS(SELECT B.QuestionID FROM Cn2Cs_Prk_MarketIntelligenceHD B (NOLOCK) WHERE A.QuestionID=B.QuestionID  and B.QuestionType IN(1,2,3))
	
	INSERT INTO @Quest(QuestionID,TypeId)
	SELECT A.QuestionID ,3 FROM Cn2Cs_Prk_MarketIntelligenceDT A (NOLOCK) WHERE 
	EXISTS(SELECT QuestionID FROM MarketIntelligenceDT B (NOLOCK) WHERE A.QuestionID=B.QuestionID)
	AND A.DownloadFlag='D'
	
	SET @ErrDesc = '    Mandatory Fields [Answer] values miss match'
	INSERT INTO Errorlog 
	SELECT 1,@TabName,'QuestionID', CAST(QuestionID AS VARCHAR(30))+@ErrDesc FROM @Quest WHERE TypeId=1
	SET @ErrDesc = '   Header data does not exists'
	INSERT INTO Errorlog 
	SELECT 2,@TabName,'QuestionID', CAST(QuestionID AS VARCHAR(30))+@ErrDesc FROM @Quest WHERE TypeId=2
	SET @ErrDesc = '   Already Exists'
	INSERT INTO Errorlog 
	SELECT 3,@TabName,'QuestionID', CAST(QuestionID AS VARCHAR(30))+@ErrDesc FROM @Quest WHERE TypeId=3
	
	INSERT INTO MarketIntelligenceDT(QuestionID,Answer,UploadFlag)
	SELECT A.QuestionID,Answer,'N' FROM Cn2Cs_Prk_MarketIntelligenceDT A (NOLOCK) 
	INNER JOIN (SELECT DISTINCT QuestionID FROM Cn2Cs_Prk_MarketIntelligenceHD (NOLOCK) WHERE QuestionType IN(1,2,3)) B ON A.QuestionID=B.QuestionID
	INNER JOIN 	(SELECT DISTINCT QuestionID FROM MarketIntelligenceHD (NOLOCK) WHERE QuestionType IN(1,2,3)) M ON  A.QuestionID=M.QuestionID 
	AND M.QuestionID=B.QuestionID WHERE NOT EXISTS(SELECT QuestionID FROM @Quest B WHERE B.QuestionID=A.QuestionID)	AND A.DownloadFlag='D'
	
	UPDATE A SET DownloadFlag='Y' FROM Cn2Cs_Prk_MarketIntelligenceDT A (NOLOCK) 
	INNER JOIN MarketIntelligenceDT B (NOLOCK) ON A.QuestionID=B.QuestionID	AND A.QuestionID NOT IN(SELECT QuestionID FROM @Quest) 
	
END
GO
DELETE FROM HotSearchEditorHd WHERE Formid=33 and ControlName='KitItemProduct'
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (33,'Kit Product Master','KitItemProduct','select','SELECT PrdId,PrdDcode,PrdCcode,PrdName,PrdShrtName,CmpId FROM Product WHERE PrdType = 3')
DELETE FROM HotSearchEditorHd WHERE Formid=34 and ControlName='KitItemProduct'
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (34,'Kit Product Master','KitItemProduct','select','SELECT PrdId,PrdDcode,PrdCcode,PrdName,PrdShrtName,CmpId FROM Product WHERE PrdType = 3 and PrdId Not In (Select KitPrdId from KitProduct)')
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='RptWithOutTaxBreakup_Excel' AND XTYPE='U')
DROP TABLE RptWithOutTaxBreakup_Excel
GO
CREATE TABLE [dbo].[RptWithOutTaxBreakup_Excel](
	[Bill Date] [datetime] NULL,
	[Bill No] [varchar](50) NULL,
	[Route Name] [varchar](75) NULL,
	[Retailer Code] [varchar](50) NULL,
	[Retailer Name] [varchar](200) NULL,
	[Product Code] [varchar](50) NULL,
	[Product Name] [varchar](200) NULL,
	[Batch Code] [varchar](75) NULL,
	[Selling Rate] [numeric](36, 4) NULL,
	[Sales Qty] [int] NULL,
	[Offer Qty] [int] NULL,
	[Total Qty] [int] NULL,
	[Gross Amt] [numeric](36, 4) NULL,
	[Scheme Amt] [numeric](36, 4) NULL,
	[SplDiscount] [numeric](36, 4) NULL,
	[Cash Discount] [numeric](36, 4) NULL,
	[Total Discount] [numeric](36, 4) NULL,
	[TaxPerc] [nvarchar](200) NULL,
	[TaxAmount] [numeric](36, 4) NULL,
	[Total Tax Amount] [numeric](36, 4) NULL,
	[NetAmount] [numeric](36, 4) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptBillWisePrdWise' AND XTYPE='P')
DROP  PROCEDURE Proc_RptBillWisePrdWise
GO
-- EXEC Proc_RptBillWisePrdWise 183,2
-- delete from RptBillWisePrdWise
-- delete from RptBillWisePrdWiseTaxBreakup
-- select * from RptBillWisePrdWise
-- select * from RptBillWisePrdWiseTaxBreakup
CREATE PROCEDURE Proc_RptBillWisePrdWise
(
	@Pi_RptId AS INT,
	@Pi_UsrId AS INT
)
AS 
/************************************************************  
* PROCEDURE : Proc_RptBillWisePrdWise  
* PURPOSE : To get the Product details and Bill details  
* CREATED BY : Murugan.R  
* CREATED DATE : 30/09/2009 
* NOTE  :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*************************************************************/  
BEGIN
	
	DELETE FROM RptBillWisePrdWise WHERE Usrid=@Pi_UsrId
	DELETE FROM RptBillWisePrdWiseTaxBreakup WHERE Usrid=@Pi_UsrId
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate   AS DATETIME  
	DECLARE @DiscBreakup as Int
	DECLARE @QtyBreakup as Int
	DECLARE @TaxBreakup as Int	
	DECLARE @CmpId      AS  INT  	
	DECLARE @CtgLevelId AS  INT  
	DECLARE @RtrClassId AS  INT  
	DECLARE @CtgMainId  AS  INT  
	DECLARE @SalId   AS BIGINT 
	DECLARE @CancelValue AS INT 
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))  
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)) 
	SET @DiscBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,242,@Pi_UsrId)) 
	SET @QtyBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) 
	SET @TaxBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,241,@Pi_UsrId)) 
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))  
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))  
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))  
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,243,@Pi_UsrId))  
	CREATE TABLE #RptRetailer
	(
		Rtrid Int,
		RtrCode Varchar(50),
		RtrName Varchar(100)
	)
	CREATE TABLE #RptSalesFree
	(
		SlNo INT,
		SalInvDate datetime,
		SalinvNo Varchar(50),
		Salid Int,
		RmId Int,
		RmName Varchar(75),
		Rtrid Int,
		RtrCode Varchar(50),
		RtrName VarChar(200),
		Lcnid INT,
		Cmpid INT,
		PrdCtgValMainId INT,
		CmpPrdCtgId INT,
		Prdid Int,
		Prdccode Varchar(50),
		PrdName Varchar(200),
		Prdbatid Int,
		PrdBatCode Varchar(75),
		Rate Numeric(36,4),
		SalesQty Int,
		FreeQty Int,
		TotQty Int,
		GrossAmt Numeric(36,4),
		SchemeAmt Numeric(36,4),
		SplDiscount Numeric(36,4),
		CashDiscount Numeric(36,4),
		TotalDiscount Numeric(36,4),
		TotalTax Numeric(36,4),
		NetAmount Numeric(36,4),	
		
	)

        --SET @TaxBreakup=2
		INSERT INTO #RptRetailer		
		SELECT DISTINCT R.Rtrid,RtrCode,RtrName FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
			,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
		WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
			AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
			AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
			RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
			AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
			AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
			RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
			AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
			RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
		INSERT INTO #RptSalesFree 	
		SELECT Max(slno) as Slno,Salinvdate,SalinvNo,X.Salid,RmId,RmName,Rtrid,RtrCode,RtrName,Lcnid,Cmpid,PrdCtgValMainId,
			CmpPrdCtgId,Prdid,Prdccode,PrdName,	Prdbatid,PrdBatCode,Rate,Sum(SalesQty) as SalesQty ,sum(FreeQty)as FreeQty,
			Sum(SalesQty+FreeQty) as TotQty,Sum(GrossAmt) as GrossAmt,Sum(SchemeAmt) as SchemeAmt,sum(SplDiscount) as SplDiscount,
			sum(CashDiscount) as CashDiscount,Sum(SchemeAmt+SplDiscount+CashDiscount) as TotalDiscount,Sum(TotalTax) as TotalTax,Sum(NetAmount) as NetAmount
		FROM(
			SELECT SIP.slNo,Salinvdate,Si.SalinvNo,Si.Salid,RM.RMId,RM.RMname,R.Rtrid,RtrCode,RtrName,SI.Lcnid,P.Cmpid,P.PrdCtgValMainId,PC.CmpPrdCtgId,
				   SIP.Prdid,Prdccode,PrdName,SIP.Prdbatid,PrdBatCode,PrdBatDetailValue as Rate,
				   BaseQty as SalesQty,SalManFreeQty as FreeQty,PrdGrossAmountAftEdit as GrossAmt,
				   Sum(Isnull(FlatAmount,0)+Isnull(DiscountPerAmount,0)) as SchemeAmt,PrdSplDiscAmount as SplDiscount,PrdCdAmount as CashDiscount,
				  Isnull(PrdTaxAmount,0) as TotalTax,Isnull(PrdNetAmount,0) as NetAmount
			FROM SalesInvoice SI (NOLOCK)
			INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SI.Salid=SIP.SalId	
			INNER JOIN Product P (NOLOCK) On P.Prdid=SIP.Prdid 
			INNER JOIN  ProductCategoryValue PC WITH (NOLOCK) ON  P.PrdCtgValMainId=PC.PrdCtgValMainId  
			INNER JOIN Productbatch PB (NOLOCK) On Pb.Prdid=P.Prdid and Pb.Prdbatid=SIP.Prdbatid
			INNER JOIN ProductBatchDetails D (NOLOCK) ON   PB.PrdBatId = D.PrdBatId AND SIP.PriceId = D.PriceId 
			INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = PB.BatchSeqId 
			AND D.SlNo = E.SlNo AND E.SelRte = 1  
			INNER JOIN RouteMaster RM ON RM.RMId=SI.RmId
			INNER JOIN #RptRetailer R ON R.Rtrid=SI.Rtrid
			LEFT OUTER JOIN SalesInvoiceSchemeLineWise SL ON SL.Salid=SIP.Salid and SL.Prdid=SIP.Prdid and SL.Prdbatid=SIP.Prdbatid
			WHERE SI.SalInvDate Between @FromDate AND @ToDate 
				AND	(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR  
					SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))  
				AND Dlvsts >=CASE WHEN @CancelValue=1 THEN 3 ELSE 4 END
								
			GROUP BY SIP.slNo,Salinvdate,Si.SalinvNo,Si.Salid,RM.RMId,RM.RMname,R.Rtrid,RtrCode,RtrName,SIP.Prdid,Prdccode,PrdName,SIP.Prdbatid,
					PrdBatCode,PrdBatDetailValue,BaseQty,SalManFreeQty,PrdGrossAmountAftEdit,PrdSplDiscAmount,
					PrdCdAmount,P.PrdCtgValMainId,PC.CmpPrdCtgId,SI.Lcnid,P.Cmpid,PrdTaxAmount,PrdNetAmount
			UNION ALL
			SELECT 0 as slno,Salinvdate,Si.SalinvNo, Sf.Salid,RM.RMId,RM.RMname,R.Rtrid,RtrCode,RtrName,SI.Lcnid,P.Cmpid,P.PrdCtgValMainId,
				PC.CmpPrdCtgId,SF.FreePrdId,Prdccode,PrdName,SF.FreePrdBatId,PrdBatCode,PrdBatDetailValue as Rate
				,0 as SalesQty,FreeQty,0 as  GrossAmt,0 as SchemeAmt,0 as SplDiscount,0 as CashDiscount,0 as TotalTax,0 as NetAmount
			FROM SalesInvoiceSchemeDtFreePrd SF 
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.salid=SF.Salid
			INNER JOIN Product P (NOLOCK) On P.Prdid=SF.FreePrdId 
			INNER JOIN  ProductCategoryValue PC WITH (NOLOCK) ON  P.PrdCtgValMainId=PC.PrdCtgValMainId  
			INNER JOIN Productbatch PB (NOLOCK) On Pb.Prdid=P.Prdid and Pb.Prdbatid=SF.FreePrdBatId
			INNER JOIN ProductBatchDetails D (NOLOCK) ON  PB.PrdBatId = D.PrdBatId and DefaultPrice=1
			INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = PB.BatchSeqId 
				AND D.SlNo = E.SlNo AND E.SelRte = 1 
			INNER JOIN RouteMaster RM ON RM.RMId=SI.RmId 
			INNER JOIN #RptRetailer R ON R.Rtrid=SI.Rtrid
			WHERE SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR  
					SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				AND Dlvsts >=CASE WHEN @CancelValue=1 THEN 3 ELSE 4 END
		)X 
		GROUP BY X.Salid,Prdid,Prdbatid,Salinvdate,SalinvNo,RMId,RMname,Rtrid,RtrCode,RtrName,Prdccode,PrdName,PrdBatCode,Rate,
				PrdCtgValMainId,CmpPrdCtgId,Lcnid,Cmpid
		--TaxBreakUp
		IF @TaxBreakup=1
		BEGIN
			INSERT INTO RptBillWisePrdWise
			SELECT SlNo,SalInvDate,SalinvNo,Salid,RMId,RMName,Rtrid,RtrCode,RtrName,
				Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,Prdid,Prdccode,PrdName,
				Prdbatid,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,SplDiscount,
				CashDiscount,TotalDiscount,TaxPerc,TaxAmount,TotalTax,Netamount,@DiscBreakup,@QtyBreakup,@TaxBreakup,@Pi_UsrId 
			FROM
				(
					SELECT SlNo,SalInvDate,SalinvNo,X.Salid,X.RMID,X.RmName,X.Rtrid,RtrCode,RtrName ,Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,
							Prdid,Prdccode,PrdName,Prdbatid,PrdBatCode, Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,SplDiscount,
							CashDiscount,TotalDiscount,Cast(Left(Isnull(TaxPerc,0),4) as Varchar(10))+'%' as TaxPerc,
							Isnull(TaxAmount,0) as TaxAmount,TotalTax,Netamount
					FROM #RptSalesFree X LEFT OUTER JOIN SalesinvoiceProducttax SPT ON SPT.PrdSlNo=X.SlNo and SPT.Salid=X.SalId and TaxAmount>0
				)X	
		END
		IF @TaxBreakup=2
		BEGIN	
			--Without TaxBreakUp
			INSERT INTO RptBillWisePrdWise
			SELECT X.SlNo,SalInvDate,SalinvNo,X.Salid,X.RMID,X.RmName,X.Rtrid,RtrCode,RtrName,Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,
					X.Prdid,Prdccode,PrdName,X.Prdbatid,PrdBatCode, Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,SplDiscount,
					CashDiscount,TotalDiscount,0,0,Isnull(PrdTaxAmount,0) as TotalTax,Isnull(PrdNetAmount,0) as NetAmount,
					@DiscBreakup,@QtyBreakup,@TaxBreakup,@Pi_UsrId
			 FROM #RptSalesFree X LEFT OUTER JOIN SalesInvoiceProduct SIP (NOLOCK) ON X.Salid=SIP.SalId	
					and X.Prdid=SIP.Prdid and X.prdbatid=SIP.Prdbatid and X.SlNo=Sip.Slno
		END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptBillWisePrdWiseOutPut' AND XTYPE='P')
DROP  PROCEDURE Proc_RptBillWisePrdWiseOutPut
GO
-- exec [Proc_RptBillWisePrdWiseOutPut] 183,2,0,'PARLE',0,0,1
CREATE PROCEDURE Proc_RptBillWisePrdWiseOutPut
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
* PROCEDURE : [Proc_RptBillWisePrdWiseOutPut]
* PURPOSE : To get the Product details
* CREATED BY : Murugan.R
* CREATED DATE : 30/09/2009
* NOTE  :
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @NewSnapId  AS INT
	DECLARE @DBNAME  AS  NVARCHAR(50)
	DECLARE @TblName  AS NVARCHAR(500)
	DECLARE @TblStruct  AS NVARCHAR(4000)
	DECLARE @TblFields  AS NVARCHAR(4000)
	DECLARE @sSql  AS  NVARCHAR(4000)
	DECLARE @ErrNo   AS INT
	DECLARE @PurDBName AS NVARCHAR(50)
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate   AS DATETIME
	DECLARE @CmpId   AS INT
	DECLARE @LcnId   AS INT
	DECLARE @SMId   AS INT
	DECLARE @RMId   AS INT
	DECLARE @RtrId   AS INT
	DECLARE @PrdCatId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @PrdId  AS INT
	DECLARE @SalId   AS BIGINT
	DECLARE @CancelValue AS INT
	DECLARE @BillStatus AS INT
	DECLARE @TaxBreakup AS INT	
	DECLARE @DiscBreakup AS INT
	DECLARE @QtyBreakup AS INT	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @PrdBatId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	SET @TaxBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,241,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))

	CREATE TABLE #RptWithOutTaxBreakup
		(
			SalInvDate datetime,
			SalinvNo Varchar(50),
			RouteName Varchar(75),		
			RtrCode Varchar(50),
			RtrName VarChar(200),			
			Prdccode Varchar(50),
			PrdName Varchar(200),
			PrdBatCode Varchar(75),
			Rate Numeric(36,4),
			SalesQty Int,
			FreeQty Int,
			TotQty Int,
			GrossAmt Numeric(36,4),
			SchemeAmt Numeric(36,4),
			SplDiscount Numeric(36,4),
			CashDiscount Numeric(36,4),
			TotalDiscount Numeric(36,4),
			TaxPerc NVARCHAR(200),		
			TaxAmount Numeric(36,4),				
			TotalTax Numeric(36,4),
			NetAmount Numeric(36,4),		
			DiscBreakup Int,
			QtyBreakup  Int,
			TaxBreakup Int
			
		)
		IF @TaxBreakup=2
		BEGIN
			SET @TblName = 'RptBillWisePrdWiseTaxBreakup'

			SET @TblStruct = 'SalInvDate datetime,
			SalinvNo Varchar(50),	
			RouteName Varchar(75),	
			RtrCode Varchar(50),
			RtrName VarChar(200),			
			Prdccode Varchar(50),
			PrdName Varchar(200),
			PrdBatCode Varchar(75),
			Rate Numeric(36,4),
			SalesQty Int,
			FreeQty Int,
			TotQty Int,
			GrossAmt Numeric(36,4),
			SchemeAmt Numeric(36,4),
			SplDiscount Numeric(36,4),
			CashDiscount Numeric(36,4),
			TotalDiscount Numeric(36,4),
			TotalTax Numeric(36,4),
			NetAmount Numeric(36,4),		
			DiscBreakup Int,
			QtyBreakup  Int,
			TaxBreakup Int'

			SET @TblFields = 'SalInvDate,SalinvNo,RouteName,RtrCode,RtrName,Prdccode,
			 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
			 SplDiscount,CashDiscount,TotalDiscount,TotalTax,NetAmount,DiscBreakup,QtyBreakup,TaxBreakup'
		END
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
		EXEC Proc_RptBillWisePrdWise 183,2
		--SET @TaxBreakup=2	
		SELECT DISTINCT @DiscBreakup=DiscBreakup FROM RptBillWisePrdWise WHERE UsrId=@Pi_UsrId
		SELECT DISTINCT @QtyBreakup=QtyBreakup FROM RptBillWisePrdWise WHERE UsrId=@Pi_UsrId
		INSERT INTO #RptWithOutTaxBreakup (SalInvDate,SalinvNo,RouteName,RtrCode,RtrName,Prdccode,
				 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
				 SplDiscount,CashDiscount,TotalDiscount,TaxPerc,TaxAmount,TotalTax,NetAmount,DiscBreakup,QtyBreakup,TaxBreakup)
			SELECT SalInvDate,SalinvNo,RmName,RtrCode,RtrName,Prdccode,
				PrdName,PrdBatCode, dbo.Fn_ConvertCurrency(Rate,@Pi_CurrencyId),SalesQty,FreeQty,TotQty,
				dbo.Fn_ConvertCurrency(GrossAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(SchemeAmt,@Pi_CurrencyId),
				dbo.Fn_ConvertCurrency(SplDiscount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
				dbo.Fn_ConvertCurrency(TotalDiscount,@Pi_CurrencyId),
				TaxPerc,
				dbo.Fn_ConvertCurrency(TaxAmount,@Pi_CurrencyId),			
				dbo.Fn_ConvertCurrency(TotalTax,@Pi_CurrencyId),
				dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId),DiscBreakup,QtyBreakup,TaxBreakup
		FROM RptBillWisePrdWise
		WHERE  UsrId=@Pi_UsrId
		AND  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND
		(LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
		LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
		AND
		(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND
		(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND
		(PrdBatId = (CASE @PrdBatId WHEN 0 THEN PrdBatId Else 0 END) OR
		PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))

		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			SET @SSQL = 'INSERT INTO #RptWithOutTaxBreakup ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE UsrId=' + CAST(@Pi_UsrId AS nVarchar(10)) + ''
			+ 'AND  (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
			+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
			+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
			+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR '
			+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
			+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
			+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
			+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
			+ 'AND (PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
			+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
			+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
			+ 'AND (PrdBatId = (CASE ' + CAST(@PrdBatId AS nVarchar(10)) + ' WHEN 0 THEN PrdBatId Else 0 END) OR '
			+ 'PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(' +
			+ CAST(@Pi_RptId AS nVarchar(10)) + ',7,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptWithOutTaxBreakup'
				EXEC (@SSQL)
				PRINT 'Saved Data Into SnapShot Table'
			END
		END
	END
	ELSE    --To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptWithOutTaxBreakup ' +
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
	IF @TaxBreakup=1
	BEGIN	
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptWithOutTaxBreakup
	END
	IF @TaxBreakup=2
	BEGIN	
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptWithOutTaxBreakup 	
	END

	DELETE FROM RptWithOutTaxBreakup_Excel
	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId	
		

	IF EXISTS (SELECT *	FROM RptDataCount WHERE RptId=183 and RecCount>0)
	BEGIN
	--Excel Report
		DELETE FROM RptExcelHeaders Where RptId=@Pi_RptId
		INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)	
		SELECT @Pi_RptId,ColId ,Name,Name,1,1 FROM SYSCOLUMNS S WHERE Id In (Select Id From SysObjects where Xtype='U' and Name='RptWithOutTaxBreakup_Excel')	
		IF (@DiscBreakup=2 AND @QtyBreakup=2)
		BEGIN	
			UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN(9,10,13,14,15)	and RptId=@Pi_RptId			
		END	
		IF (@DiscBreakup=1  AND @QtyBreakup=2)
		BEGIN		
			UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN(9,10) and RptId=@Pi_RptId				
		END	
		IF (@DiscBreakup=2  AND @QtyBreakup=1)
		BEGIN		
			UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno  In(13,14,15) and RptId=@Pi_RptId
		END

		IF @TaxBreakup = 1
		BEGIN		
			UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Slno IN(18,19) and RptId=@Pi_RptId				
		END	
		IF @TaxBreakup = 2
		BEGIN		
			UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN(18,19) and RptId=@Pi_RptId				
		END
		
		INSERT INTO RptWithOutTaxBreakup_Excel([Bill Date],[Bill No],[Route Name],[Retailer Code],[Retailer Name],[Product Code],[Product Name],
					[Batch Code],[Selling Rate],[Sales Qty],[Offer Qty],[Total Qty],[Gross Amt],[Scheme Amt],[SplDiscount],
					[Cash Discount],[Total Discount],TaxPerc,TaxAmount,[Total Tax Amount],[NetAmount ])
		SELECT SalInvDate,SalinvNo,RouteName,RtrCode,RtrName,Prdccode,
			 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
			 SplDiscount,CashDiscount,TotalDiscount,TaxPerc,TaxAmount,TotalTax,NetAmount from #RptWithOutTaxBreakup
		
		SELECT * FROM RptWithOutTaxBreakup_Excel
	--End
		--Grid Report
		
		DELETE FROM SpreadDisplayColumns WHERE MasterId=@Pi_RptId
		INSERT INTO SpreadDisplayColumns
		select @Pi_RptId,
		(select count(*) from RptExcelHeaders where slno <= t.slno and DisplayFlag=1 and RptId=@Pi_RptId),
		FieldName,1,1,1,GetDate(),1,Getdate() from RptExcelHeaders t where RptId=@Pi_RptId and DisplayFlag=1
		order by slno
		
		DECLARE @ColName as Varchar(4000)
		DECLARE @ColName1 as Varchar(4000)
		DECLARE @Gsql as Varchar(8000)
		DECLARE @Colcnt as INT
		SET @ColName=''
		SET @ColName1=''
		SELECT @ColName=@ColName+'['+ColumnName +'],'  FROM SpreadDisplayColumns WHERe MasterId=@Pi_RptId
		SELECT @Colcnt=Count(*) FROM SpreadDisplayColumns S WHERE MasterId=@Pi_RptId
		SET @ColName=SUBSTRING(@ColName,1,Len(@ColName)-1)
		SELECT @ColName1=@ColName1+'['+Name +'],' FROM SYSCOLUMNS S WHERE Id In (Select Id From SysObjects where Xtype='U' and Name='RptColvalues') and ColId<=@Colcnt
		SET @ColName1=SUBSTRING(@ColName1,1,Len(@ColName1)-1)
		SET @Gsql= 'INSERT INTO RptColvalues ( '+@ColName1+',Rptid,Usrid)
		SELECT '+@ColName+ ','+
		CAST(@Pi_RptId AS nVarchar(10))+','+ CAST(@Pi_UsrId AS nVarchar(10)) +'FROM RptWithOutTaxBreakup_Excel Order By [Bill Date],[Bill No]'
		EXEC (@Gsql)
	--END Grid Report
	END
	RETURN
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',419
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 419)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(419,'D','2014-10-09',GETDATE(),1,'Core Stocky Service Pack 419')