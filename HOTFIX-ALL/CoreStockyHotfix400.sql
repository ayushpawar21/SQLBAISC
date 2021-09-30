--[Stocky HotFix Version]=400
DELETE FROM Versioncontrol WHERE Hotfixid='400'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('400','2.0.0.5','D','2013-01-04','2013-01-04','2013-01-04',CONVERT(VARCHAR(11),GETDATE()),'PARLE-Major: Product Release Dec CR')
GO
--Parle CR 
DELETE FROM ScreenDefaultValues WHERE TransId = 79 AND CtrlId = 163
INSERT INTO ScreenDefaultValues
SELECT 79,163,1,'Cash',1,1,1,1,GETDATE(),1,GETDATE(),'Cash' UNION ALL
SELECT 79,163,2,'Cheque',2,1,1,1,GETDATE(),1,GETDATE(),'Cheque'
GO
DELETE FROM CustomCaptions WHERE TransId = 79 AND CtrlId = 125 AND SubCtrlId = 75
INSERT INTO CustomCaptions
SELECT 79,125,75,'DgCommon-79-125-75','PayMode','','',1,1,1,GETDATE(),1,GETDATE(),'PayMode','','',1,1
GO
IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE Name = 'Retailer' AND XTYPE = 'U') AND name = 'RtrPayment')
BEGIN
    ALTER TABLE Retailer ADD RtrPayment TINYINT DEFAULT 1 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE IN ('TF','FN') AND name = 'Fn_FillRetailerDetailsinRetailerMaster')
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
Approved	INT,
Upload	NVARCHAR(10),
RtrPayment NVARCHAR(100),
RtrPaymentId INT
)
AS
BEGIN
	INSERT INTO @FillRetailerDetails (RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrContactPerson,RtrKeyAcc,
    RtrCovMode,RtrRegDate,RtrDepositAmt,RtrStatus,RtrTaxable,RtrTaxType,TaxGroupName,RtrTINNo,RtrCSTNo,RtrDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
    RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,GeoMainId,
    GeoName,GeoLevelName,RmId,RMName,VillageId,VillageName,RtrShipId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrResPhone1,RtrResPhone2,
    RtrOffPhone1,RtrOffPhone2,RtrDOB,RtrAnniversary,RtrRemark1,RtrRemark2,RtrRemark3,COAId,OnAccount,TaxGroupId,RtrType,RtrFrequency,RtrCrBillsAlert,
    RtrCrLimitAlert,RtrCrDaysAlert,RtrKeyId,RtrCoverageId,RtrStatusId,RtrDayOffId,RtrTaxableId,RtrTaxTypeId,RtrTypeId,RtrRlStatus,RlStatus,
    CmpRtrCode,Approved,Upload,RtrPayment,RtrPaymentId)
    
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
	ISNULL(SD8.CtrlDesc,'') AS RtrRlStatus,ISNULL(Rt.RtrRlStatus,1) AS RlStatus,Rt.CmpRtrCode,Rt.Approved,Rt.Upload ,
	ISNULL(SD9.CtrlDesc,'') AS RtrPayment,Rt.RtrPayment AS RtrPayModeId 
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
	WHERE GE.GeoLevelId = Gl.GeoLevelId
RETURN
END
GO
DELETE FROM BillSeriesConfig WHERE SeriesMasterId = 4
INSERT INTO BillSeriesConfig
SELECT 4,1,'Cash',1,1,GETDATE(),1,GETDATE() UNION ALL
SELECT 4,2,'Cheque',1,1,GETDATE(),1,GETDATE()
GO
DELETE FROM CustomCaptions WHERE TransId = 2 AND CtrlId = 1000 AND SubCtrlId = 267
INSERT INTO CustomCaptions
SELECT 2,1000,267,'MsgBox-2-1000-267','','','Select Retailer',1,1,1,GETDATE(),1,GETDATE(),'','','Select Retailer',1,1
GO
IF NOT EXISTS (SELECT * FROM SysColumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'SalesInvoice') AND Name ='RtrPayMode')
BEGIN
    ALTER TABLE SalesInvoice ADD RtrPayMode TINYINT DEFAULT 1 WITH VALUES
END
GO
--Bill Print
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_InsertBillTemplateField')
DROP PROCEDURE Proc_InsertBillTemplateField
GO
--Exec Proc_InsertBillTemplateField 1,2
CREATE PROCEDURE Proc_InsertBillTemplateField
(
	@Pi_SeqNo INT,
	@Pi_Type  INT	
)
AS
BEGIN
	DECLARE @iCnt AS INT
	DELETE FROM SalesInvoiceReportingColumns WHERE Type=@Pi_Type
	IF @Pi_Type=1
	BEGIN
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Code','DistributorCode','nvarchar(20)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Name','DistributorName','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Address1','DistributorAdd1','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Address2','DistributorAdd2','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Address3','DistributorAdd3','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('PinCode','PinCode','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('PhoneNo','PhoneNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Contact Person','D_ContactPerson','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('EmailID','D_EmailID','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Type','TaxType','tinyint',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('TIN Number','TINNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Deposit Amount','DepositAmt','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Geo Level','D_GeoLevelName','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('CST Number','CSTNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('LST Number','LSTNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Licence Number','LicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug Licence Number 1','DrugLicNo1','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug1 Expiry Date','Drug1ExpiryDate','DateTime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug Licence Number 2','DrugLicNo2','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug2 Expiry Date','Drug2ExpiryDate','DateTime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Pesticide Licence Number','PestLicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Pesticide Expiry Date','PestExpiryDate','DateTime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company Code','CmpCode','nvarchar(20)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company Name','CmpName','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company Address1','Address1','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company Address2','Address2','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company Address3','Address3','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company Phone Number','PhoneNumber','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company Fax Number','FaxNumber','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company EmailId','EmailId','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Company Contact Person','ContactPerson','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Code','RtrCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Name','RtrName','nvarchar(150)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Address1','RtrAdd1','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Address2','RtrAdd2','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Address3','RtrAdd3','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Pin Code','RtrPinNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer PhoneNo','RtrPhoneNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer EmailId','RtrEmailId','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer ContactPerson','RtrContactPerson','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Coverage Mode','RtrCovMode','tinyint',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer TaxType','RtrTaxType','tinyint',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer TINNo','RtrTINNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer CSTNo','RtrCSTNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Deposit Amount','RtrDepositAmt','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Credit Bills','RtrCrBills','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Credit Limit','RtrCrLimit','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Credit Days','RtrCrDays','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer License No','RtrLicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer License ExpiryDate','RtrLicExpiryDate','datetime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Drug License No','RtrDrugLicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Drug ExpiryDate','RtrDrugExpiryDate','datetime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Pestcide LicNo','RtrPestLicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Pestcide ExpiryDate','RtrPestExpiryDate','datetime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer GeoLevel','GeoLevelName','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Village','VillageName','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer ShipId','RtrShipId','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Ship Address1','RtrShipAdd1','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Ship Address2','RtrShipAdd2','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Ship Address3','RtrShipAdd3','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer ResPhone1','RtrResPhone1','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer ResPhone2','RtrResPhone2','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer OffPhone1','RtrOffPhone1','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer OffPhone2','RtrOffPhone2','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer OnAccount','RtrOnAcc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalId','SalId','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Sales Invoice Number','SalInvNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Bill Date','SalInvDate','datetime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Delivery Date','SalDlvDate','datetime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Bill Doc Ref. Number','SalInvRef','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesMan Code','SMCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesMan Name','SMName','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Route Code','RMCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Route Name','RMName','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Interim Sales','InterimSales','tinyint',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Order Number','OrderKeyNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Order Date','OrderDate','datetime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Bill Type','BillType','tinyint',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Bill Mode','BillMode','tinyint',@Pi_Type,1,1,getDate(),1,getDate())
	    INSERT INTO SalesInvoiceReportingColumns VALUES ('Payment Mode','RtrPayMode','Tinyint',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Remarks','Remarks','nvarchar(200)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice Line Gross Amount','PrdGrossAmountAftEdit','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice Line Net Amount','PrdNetAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice Line Net Amount','PrdNetAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice GrossAmount','SalGrossAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice RateDiffAmount','SalRateDiffAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice CDPer','SalCDPer','numeric(9,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice DBAdjAmount','DBAdjAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice CRAdjAmount','CRAdjAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice MarketRetAmount','MarketRetAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice OtherCharges','OtherCharges','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice WindowDisplayAmount','WindowDisplayamount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice OnAccountAmount','OnAccountAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice ReplacementDiffAmount','ReplacementDiffAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice TotalAddition','TotalAddition','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice TotalDeduction','TotalDeduction','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice ActNetRateAmount','SalActNetRateAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice NetRateDiffAmount','SalNetRateDiffAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice NetAmount','SalNetAmt','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice RoundOffAmt','SalRoundOffAmt','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Vehicle Name','VehicleCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Delivery Boy','DlvBoyName','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Delivery Boy','DlvBoyName','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		Select @iCnt=Count(*) FROM TaxConfiguration
		IF @iCnt>0 
		BEGIN
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax 1','Tax1Perc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Amount1','Tax1Amount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		END
		IF @iCnt>1 
		BEGIN
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax 2','Tax2Perc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Amount2','Tax2Amount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())			
		END
		IF @iCnt>2 
		BEGIN
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax 3','Tax3Perc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Amount3','Tax3Amount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		END
		IF @iCnt>3 
		BEGIN
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax 4','Tax4Perc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Amount4','Tax4Amount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())			
		END
		IF @iCnt>4 
		BEGIN
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax 5','Tax5Perc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
			INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Amount5','Tax5Amount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		END
		INSERT INTO SalesInvoiceReportingColumns
		SELECT FieldDesc + ' Header Amount' as ColumnName,'[' + FieldDesc + '_HD]' FieldName, 'numeric(38,2)' DataType,@Pi_Type, 1 as Availability,1 LastModBy,
		getDate() LastModDate,1 AuthId,getDate() AuthDate
		FROM BillSequenceDetail WHERE BillSeqId in (
		@Pi_SeqNo) and SlNo > 3 ORDER BY slno
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Code','PrdCCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Name','PrdName','nvarchar(200)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Short Name','PrdShrtName','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Type','PrdType','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Batch Code','PrdBatCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Batch Manufacturing Date','MnfDate','datetime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Batch Expiry Date','ExpDate','datetime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Batch MRP','MRP','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Batch Selling Rate','[Selling Rate]','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Uom 1 Desc','Uom1Id','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Uom 1 Qty','Uom1Qty','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Uom 2 Desc','Uom2Id','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Uom 2 Qty','Uom2Qty','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Base Qty','BaseQty','numeric(38,0)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug Batch Description','DrugBatchDesc','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Manual Free Qty','SalManFreeQty','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Scheme Points','Points','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('DC NUMBER','DCNo','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('DC DATE','DCDate','DATETIME',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns
		SELECT FieldDesc + ' LineUnit Amount' as ColumnName,'[' + FieldDesc + '_UnitAmt_Dt]' FieldName, 'numeric(38,2)' DataType,@Pi_Type,1 as Availability,1 LastModBy,
		getDate() LastModDate,1 AuthId,getDate() AuthDate
		FROM BillSequenceDetail WHERE BillSeqId in (
		@Pi_SeqNo        ) and SlNo > 3 ORDER BY slno
		INSERT INTO SalesInvoiceReportingColumns
		SELECT FieldDesc + ' Base Qty Amount' as ColumnName,'[' + FieldDesc + '_Amount_Dt]' FieldName, 'numeric(38,2)' DataType,@Pi_Type,1 as Availability,1 LastModBy,
		getDate() LastModDate,1 AuthId,getDate() AuthDate
		FROM BillSequenceDetail WHERE BillSeqId in (
		@Pi_SeqNo        ) and SlNo > 3 ORDER BY slno
		INSERT INTO SalesInvoiceReportingColumns
		SELECT FieldDesc + ' UOM Amount' as ColumnName,'[' + FieldDesc + '_UomAmt_Dt]' FieldName, 'numeric(38,2)' DataType,@Pi_Type,1 as Availability,1 LastModBy,
		getDate() LastModDate,1 AuthId,getDate() AuthDate
		FROM BillSequenceDetail WHERE BillSeqId in (
		@Pi_SeqNo        ) and SlNo > 3 ORDER BY slno
		INSERT INTO SalesInvoiceReportingColumns
		SELECT FieldDesc + ' Unit Percentage' as ColumnName,'[' + FieldDesc + '_UnitPerc_Dt]' FieldName, 'numeric(38,2)' DataType,@Pi_Type,1 as Availability,1 LastModBy,
		getDate() LastModDate,1 AuthId,getDate() AuthDate
		FROM BillSequenceDetail WHERE BillSeqId in (
		@Pi_SeqNo        ) and SlNo > 3 ORDER BY slno
		INSERT INTO SalesInvoiceReportingColumns
		SELECT FieldDesc + ' Qty Percentage' as ColumnName,'[' + FieldDesc + '_QtyPerc_Dt]' FieldName, 'numeric(38,2)' DataType,@Pi_Type,1 as Availability,1 LastModBy,
		getDate() LastModDate,1 AuthId,getDate() AuthDate
		FROM BillSequenceDetail WHERE BillSeqId in (
		@Pi_SeqNo        ) and SlNo > 3 ORDER BY slno
		INSERT INTO SalesInvoiceReportingColumns
		SELECT FieldDesc + ' UOM Percentage' as ColumnName,'[' + FieldDesc + '_UomPerc_Dt]' FieldName, 'numeric(38,2)' DataType,@Pi_Type,1 as Availability,1 LastModBy,
		getDate() LastModDate,1 AuthId,getDate() AuthDate
		FROM BillSequenceDetail WHERE BillSeqId in (
		@Pi_SeqNo        ) and SlNo > 3 ORDER BY slno
		INSERT INTO SalesInvoiceReportingColumns
		SELECT FieldDesc + ' Effect Amount' as ColumnName,'[' + FieldDesc + '_EffectAmt_Dt]' FieldName, 'numeric(38,2)' DataType,@Pi_Type,1 as Availability,1 LastModBy,
		getDate() LastModDate,1 AuthId,getDate() AuthDate
		FROM BillSequenceDetail WHERE BillSeqId in (
		@Pi_SeqNo        ) and SlNo > 3 ORDER BY slno
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Line Unit Percentage','LineUnitPerc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Line Base Qty Percentage','LineBaseQtyPerc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Line UOM1 Percentage','LineUom1Perc','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Line Unit Amount','LineUnitamount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Line Base Qty Amount','LineBaseQtyAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Line UOM1 Amount','LineUom1Amount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Line Effect Amount','LineEffectAmount','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('EAN Code','EANCode','varchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
        INSERT INTO SalesInvoiceReportingColumns VALUES ('Product SL No','SLNo','Int',@Pi_Type,1,1,getDate(),1,getDate())
	END
	ELSE IF @Pi_Type=2
	BEGIN
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Code','DistributorCode','nvarchar(20)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Name','DistributorName','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Address1','DistributorAdd1','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Address2','DistributorAdd2','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Address3','DistributorAdd3','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('PinCode','PinCode','int',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('PhoneNo','PhoneNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Type','TaxType','tinyint',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('TIN Number','TINNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Deposit Amount','DepositAmt','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('CST Number','CSTNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('LST Number','LSTNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Licence Number','LicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug Licence Number 1','DrugLicNo1','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug1 Expiry Date','Drug1ExpiryDate','DateTime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug Licence Number 2','DrugLicNo2','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Drug2 Expiry Date','Drug2ExpiryDate','DateTime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Pesticide Licence Number','PestLicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Pesticide Expiry Date','PestExpiryDate','DateTime',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalId','SalesInvoice.SalId','INT',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Invoice Number','SalInvNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Invoice Date','SalInvDate','DATETIME',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('ReturnId','ReturnProduct.ReturnId','INT',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Sales Return Number','ReturnCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Sales Return Date','ReturnDate','DATETIME',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Sales Man','SMCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Route','RMCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Code','RtrCode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Name','RtrName','nvarchar(150)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Phone Number','RtrPhoneNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer CST Number','RtrCstNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Drug Lic  Number','RtrDrugLicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Lic Number','RtrLicNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Tin Number','RtrTINNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Retailer Address','RtrAdd1','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Company Code','CmpCode','nvarchar(20)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Company Name','CmpName','nvarchar(150)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Short Code','Product.PrdDCode','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Short Name','Product.PrdShrtName','nvarchar(150)',@Pi_Type,1,1,getDate(),1,getDate())
        INSERT INTO SalesInvoiceReportingColumns VALUES ('Product Name','Product.PrdName','nvarchar(150)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Stock Type','UserStockType','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Return Quantity','BaseQty','NUMERIC(18,0)',@Pi_Type,1,1,getDate(),1,getDate())
-- 		INSERT INTO SalesInvoiceReportingColumns VALUES ('Free Quantity','ReturnFreeQty','NUMERIC(18,0)',@Pi_Type,1,1,getDate(),1,getDate())
-- 		INSERT INTO SalesInvoiceReportingColumns VALUES ('Gift Quantity','ReturnGiftQty','NUMERIC(18,0)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Selling Rate','PrdEditSelRte','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Gross Amount','PrdGrossAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Special Discount','PrdSplDisAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Scheme Discount','PrdSchDisAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Distributor Discount','PrdDBDisAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Cash Discount','PrdCDDisAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Percentage','TaxPerc','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Tax Amount Line Level','TaxAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Line level Net Amount','PrdNetAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Reason','Description','nvarchar(100)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Type','InvoiceType','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Mode','ReturnMode','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Total Gross Amount','RtnGrossAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Total Special Discount','RtnSplDisAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Total Scheme Discount','RtnSchDisAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Total Distributor Discount','RtnDBDisAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Total Cash Discount','RtnCashDisAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Total Tax Amount','RtnTaxAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Total Net Amount','RtnNetAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Total Discount','RtnNetAmt','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('RtrId','Retailer.RtrId','INT',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('RMID','RouteMaster.RMId','INT',@Pi_Type,1,1,getDate(),1,getDate())		
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SMID','SalesMan.SMId','INT',@Pi_Type,1,1,getDate(),1,getDate())
        INSERT INTO SalesInvoiceReportingColumns VALUES ('MRP','ReturnProduct.PrdUnitMRP','NUMERIC(18,6)',@Pi_Type,1,1,getDate(),1,getDate())
		--Added By Maha on 10/02/2009
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Credit Note/Replacement Reference No','CreditNoteReplacementHd.CNRRefNo','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())	
		--Added By Mary on 13/03/2009 for Credit Note Number
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Credit Note Reference No','CreditNoteRetailer.CrNoteNumber','nvarchar(50)',@Pi_Type,1,1,getDate(),1,getDate())	
	END
	ELSE IF @Pi_Type=3
	BEGIN
	
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Ref Number','PurRetRefNo','NVARCHAR(50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Date','PurRetDate','DATETIME',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Company','Company.CmpName','NVARCHAR (50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Supplier','Supplier.SpmName','NVARCHAR (50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('GRN Number','PurchaseReceipt.PurRcptRefNo','NVARCHAR (50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('GRN Date','PurchaseReceipt.GoodsRcvdDate','DATETIME',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Company Invoice Date','PurchaseReceipt.InvDate','DATETIME',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Company Invoice Number','PurchaseReceipt.CmpInvNo','NVARCHAR (50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Return Mode','PurchaseReturn.ReturnMode','NVARCHAR (50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Product Company Code','Product.PrdCCode','NVARCHAR (50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Product Company Name','Product.PrdDCode','NVARCHAR (150)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Product Short Code','Product.PrdDCode','NVARCHAR (50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Product Short Name','Product.PrdShrtName','NVARCHAR (150)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Product Batch','ProductBatch.PrdBatCode','NVARCHAR (100)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Pur Quantity Salable','PurSalBaseQty','INT',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Pur Quantity Un Salable','PurUnSalBaseQty','INT',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Return Quantity Salable','RetSalBaseQty','INT',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Return Quantity un Salable','RetUnSalBaseQty','INT',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('MRP','PrdUnitMRP','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Rate','PrdUnitLSP','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('LSP','PrdLSP','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Gross Amount','PrdGrossAmount','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Discount','PrdDiscount','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Tax percentage','TaxPerc','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Tax Amount','PrdTaxAmount','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Net Amount','PrdNetAmount','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Reason','PurchaseReturnProduct.ReasonId','NVARCHAR (50)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Total Gross Amount','PurchaseReturn.GrossAmount','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Total Discount Amount','PurchaseReturn.Discount','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Total Tax Amount','PurchaseReturn.TaxAmount','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Total Net Amount','PurchaseReturn.NetAmount','NUMERIC(38,6)',@Pi_Type,1,1,GETDATE(),1,GETDATE())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('PurRetId','PurchaseReturn.PurRetId','BIGINT',@Pi_Type,1,1,GETDATE(),1,GETDATE())
	END
	ELSE IF @Pi_Type=4
	BEGIN 
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('IssueId','SampleIssueHd.IssueId','INT',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Ref Number','IssueRefNo','NVARCHAR(50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Date','IssueDate','DATETIME',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Salesman','Salesman.SMName','NVARCHAR (50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Route','RouteMaster.RMName','NVARCHAR (50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Retailer','Retailer.RtrName','NVARCHAR (150)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Bill Ref Number','SalesInvoice.SalInvNo','NVARCHAR (50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Doc Ref Number','DocRefNo','NVARCHAR (50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Sample Scheme Code','SampleSchemeMaster.SchCode','NVARCHAR (50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Company Sample Scheme Code','SampleSchemeMaster.CmpSchCode','NVARCHAR (50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Sample Product Company Code','Product.PrdCCode','NVARCHAR (50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Sample Product Company Name','Product.PrdName','NVARCHAR (150)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Sample Product Short Name','Product.PrdShrtName','NVARCHAR (150)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Sample Product Batch','ProductBatch.PrdBatCode','NVARCHAR (100)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Issued Qty','IssuedQty','NUMERIC(38,6)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Issued Qty UOM','UOMIssued.UOMCode','NVARCHAR(50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Eligible Qty','EligibleQty','NUMERIC(38,6)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Eligible Qty UOM','UOMEligible.UOMCode','NVARCHAR(50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Issue Qty UOM','UOMIssue.UOMCode','NVARCHAR(50)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Issue Qty','IssueQty','NUMERIC(38,6)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('To be Returned  - Value','TobeReturned','NUMERIC(38,6)',4,1,1,GETDATE(),1,GETDATE())
		
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
		VALUES('Due Date for Return','DueDate','DATETIME',4,1,1,GETDATE(),1,GETDATE())
	END
	ELSE IF @Pi_Type=5
	BEGIN
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('IssueId','FreeIssueHd.IssueId','INT',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Ref Number','IssueRefNo','NVARCHAR(50)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Date','IssueDate','DATETIME',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Salesman','Salesman.SMName','NVARCHAR (150)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Route','RouteMaster.RMName','NVARCHAR (150)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Retailer','Retailer.RtrName','NVARCHAR (150)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Sample Product Company Code','Product.PrdCCode','NVARCHAR (50)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Sample Product Company Name','Product.PrdName','NVARCHAR (150)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Sample Product Short Name','Product.PrdShrtName','NVARCHAR (150)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Sample Product Batch','ProductBatch.PrdBatCode','NVARCHAR (150)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Issued Qty','IssueQty','NUMERIC(38,0)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Issued Qty UOM','UomMaster.UOMCode','NVARCHAR(50)',5,1,1,Getdate(),1,Getdate())
		INSERT INTO SalesInvoiceReportingColumns(ColumnName,FieldName,DataType,Type,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES ('Issued BaseQty','IssueBaseQty','NUMERIC(38,0)',5,1,1,Getdate(),1,Getdate())
	END
END
GO
EXEC Proc_InsertBillTemplateField 1,2
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')
DROP TABLE RptBillTemplateFinal
GO
CREATE TABLE RptBillTemplateFinal(
	[Base Qty] [numeric](38, 2) NULL,
	[Batch Code] [nvarchar](100) NULL,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](100) NULL,
	[Bill Mode] [tinyint] NULL,
	[Bill Type] [tinyint] NULL,
	[CD Disc Base Qty Amount] [numeric](38, 2) NULL,
	[CD Disc Effect Amount] [numeric](38, 2) NULL,
	[CD Disc Header Amount] [numeric](38, 2) NULL,
	[CD Disc LineUnit Amount] [numeric](38, 2) NULL,
	[CD Disc Qty Percentage] [numeric](38, 2) NULL,
	[CD Disc Unit Percentage] [numeric](38, 2) NULL,
	[CD Disc UOM Amount] [numeric](38, 2) NULL,
	[CD Disc UOM Percentage] [numeric](38, 2) NULL,
	[Company Address1] [nvarchar](100) NULL,
	[Company Address2] [nvarchar](100) NULL,
	[Company Address3] [nvarchar](100) NULL,
	[Company Code] [nvarchar](40) NULL,
	[Company Contact Person] [nvarchar](200) NULL,
	[Company EmailId] [nvarchar](100) NULL,
	[Company Fax Number] [nvarchar](100) NULL,
	[Company Name] [nvarchar](200) NULL,
	[Company Phone Number] [nvarchar](100) NULL,
	[Contact Person] [nvarchar](100) NULL,
	[CST Number] [nvarchar](100) NULL,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](200) NULL,
	[Delivery Boy] [nvarchar](100) NULL,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](100) NULL,
	[Distributor Address2] [nvarchar](100) NULL,
	[Distributor Address3] [nvarchar](100) NULL,
	[Distributor Code] [nvarchar](40) NULL,
	[Distributor Name] [nvarchar](100) NULL,
	[Drug Batch Description] [nvarchar](100) NULL,
	[Drug Licence Number 1] [nvarchar](100) NULL,
	[Drug Licence Number 2] [nvarchar](100) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) NULL,
	[EmailID] [nvarchar](100) NULL,
	[Geo Level] [nvarchar](100) NULL,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](100) NULL,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](100) NULL,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](100) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](100) NULL,
	[Product Name] [nvarchar](400) NULL,
	[Product Short Name] [nvarchar](200) NULL,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](400) NULL,
	[Retailer Address1] [nvarchar](200) NULL,
	[Retailer Address2] [nvarchar](200) NULL,
	[Retailer Address3] [nvarchar](200) NULL,
	[Retailer Code] [nvarchar](100) NULL,
	[Retailer ContactPerson] [nvarchar](200) NULL,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](100) NULL,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](100) NULL,
	[Retailer EmailId] [nvarchar](200) NULL,
	[Retailer GeoLevel] [nvarchar](100) NULL,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](100) NULL,
	[Retailer Name] [nvarchar](300) NULL,
	[Retailer OffPhone1] [nvarchar](100) NULL,
	[Retailer OffPhone2] [nvarchar](100) NULL,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](100) NULL,
	[Retailer PhoneNo] [nvarchar](100) NULL,
	[Retailer Pin Code] [nvarchar](100) NULL,
	[Retailer ResPhone1] [nvarchar](100) NULL,
	[Retailer ResPhone2] [nvarchar](100) NULL,
	[Retailer Ship Address1] [nvarchar](200) NULL,
	[Retailer Ship Address2] [nvarchar](200) NULL,
	[Retailer Ship Address3] [nvarchar](200) NULL,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](100) NULL,
	[Retailer Village] [nvarchar](200) NULL,
	[Route Code] [nvarchar](100) NULL,
	[Route Name] [nvarchar](100) NULL,
	[Sales Invoice Number] [nvarchar](100) NULL,
	[SalesInvoice ActNetRateAmount] [numeric](38, 2) NULL,
	[SalesInvoice CDPer] [numeric](38, 2) NULL,
	[SalesInvoice CRAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice DBAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice GrossAmount] [numeric](38, 2) NULL,
	[SalesInvoice Line Gross Amount] [numeric](38, 2) NULL,
	[SalesInvoice Line Net Amount] [numeric](38, 2) NULL,
	[SalesInvoice MarketRetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetRateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice OnAccountAmount] [numeric](38, 2) NULL,
	[SalesInvoice OtherCharges] [numeric](38, 2) NULL,
	[SalesInvoice RateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice ReplacementDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice RoundOffAmt] [numeric](38, 2) NULL,
	[SalesInvoice TotalAddition] [numeric](38, 2) NULL,
	[SalesInvoice TotalDeduction] [numeric](38, 2) NULL,
	[SalesInvoice WindowDisplayAmount] [numeric](38, 2) NULL,
	[SalesMan Code] [nvarchar](100) NULL,
	[SalesMan Name] [nvarchar](100) NULL,
	[SalId] [int] NULL,
	[Sch Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Sch Disc Effect Amount] [numeric](38, 2) NULL,
	[Sch Disc Header Amount] [numeric](38, 2) NULL,
	[Sch Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Sch Disc Qty Percentage] [numeric](38, 2) NULL,
	[Sch Disc Unit Percentage] [numeric](38, 2) NULL,
	[Sch Disc UOM Amount] [numeric](38, 2) NULL,
	[Sch Disc UOM Percentage] [numeric](38, 2) NULL,
	[Scheme Points] [numeric](38, 2) NULL,
	[Spl. Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Spl. Disc Effect Amount] [numeric](38, 2) NULL,
	[Spl. Disc Header Amount] [numeric](38, 2) NULL,
	[Spl. Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Spl. Disc Qty Percentage] [numeric](38, 2) NULL,
	[Spl. Disc Unit Percentage] [numeric](38, 2) NULL,
	[Spl. Disc UOM Amount] [numeric](38, 2) NULL,
	[Spl. Disc UOM Percentage] [numeric](38, 2) NULL,
	[Tax 1] [numeric](38, 2) NULL,
	[Tax 2] [numeric](38, 2) NULL,
	[Tax 3] [numeric](38, 2) NULL,
	[Tax 4] [numeric](38, 2) NULL,
	[Tax Amount1] [numeric](38, 2) NULL,
	[Tax Amount2] [numeric](38, 2) NULL,
	[Tax Amount3] [numeric](38, 2) NULL,
	[Tax Amount4] [numeric](38, 2) NULL,
	[Tax Amt Base Qty Amount] [numeric](38, 2) NULL,
	[Tax Amt Effect Amount] [numeric](38, 2) NULL,
	[Tax Amt Header Amount] [numeric](38, 2) NULL,
	[Tax Amt LineUnit Amount] [numeric](38, 2) NULL,
	[Tax Amt Qty Percentage] [numeric](38, 2) NULL,
	[Tax Amt Unit Percentage] [numeric](38, 2) NULL,
	[Tax Amt UOM Amount] [numeric](38, 2) NULL,
	[Tax Amt UOM Percentage] [numeric](38, 2) NULL,
	[Tax Type] [tinyint] NULL,
	[TIN Number] [nvarchar](100) NULL,
	[Uom 1 Desc] [nvarchar](100) NULL,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](100) NULL,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](100) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[Distributor Product Code] [nvarchar](100) NULL,
	[Allotment No] [nvarchar](100) NULL,
	[Bx Selling Rate] [numeric](38, 2) NULL,
	[AmtInWrd] [nvarchar](500) NULL,
	[BX] [int] NULL,
	[PB] [int] NULL,
	[PKT] [int] NULL,
	[TOR] [int] NULL,
	[CN] [int] NULL,
	[JAR] [int] NULL,
	[GB] [int] NULL,
	[ROL] [int] NULL,
	[Product Weight] [numeric](38, 6) NULL,
	[Product UPC] [numeric](38, 6) NULL,
	[Payment Mode] [NVARCHAR](20) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RptBillTemplateFinal] ADD  DEFAULT ((0)) FOR [Product Weight]
GO
ALTER TABLE [dbo].[RptBillTemplateFinal] ADD  DEFAULT ((0)) FOR [Product UPC]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--exec PROC_RptBillTemplateFinal 16,1,0,'Parle',0,0,1,'RptBt_View_Final1_BillTemplate'
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
* 01.10.2009		Panneer	   Added Tax summary Report Part(UserId Condition)
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
	print @Pi_BTTblName
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
		Exec('CREATE TABLE RptBillTemplateFinal
		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')
	END
	ELSE
	BEGIN
		Exec('CREATE TABLE RptBillTemplateFinal
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
		Delete from RptBillTemplateFinal Where UsrId = @Pi_UsrId
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
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
--	End
	------------------------------ Other
	Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
	End
	---------------------------------------Replacement
	Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
	End
	----------------------------------Credit Debit Adjus
	Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
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
	End
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
	INSERT INTO RptBillTemplate_PrdUOMDetails(SalId,SalInvNo,TotPrdVolume,TotPrdKG,TotPrdLtrs,TotPrdUnits,
	TotPrdDrums,TotPrdCartons,TotPrdBuckets,TotPrdPieces,TotPrdBags,UsrId)	
	SELECT SalId,SalInvNo,SUM(TotPrdVolume) AS TotPrdVolume,SUM(TotPrdKG) AS TotPrdKG,SUM(TotPrdLtrs) AS TotPrdLtrs,SUM(TotPrdUnits) AS TotPrdUnits,
	SUM(TotPrdDrums) AS TotPrdDrums,SUM(TotPrdCartons) AS TotPrdCartons,SUM(TotPrdBuckets) AS TotPrdBuckets,SUM(TotPrdPieces) AS TotPrdPieces,SUM(TotPrdBags) AS TotPrdBags,@Pi_UsrId
	FROM
	(
		SELECT DISTINCT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.BaseQty*dbo.Fn_ReturnProductVolumeInLtrs(SIP.PrdId) AS TotPrdVolume,
		SIP.BaseQty*P.PrdUpSKU * (CASE P.PrdUnitId WHEN 2 THEN .001 WHEN 3 THEN 1 ELSE 0 END) AS TotPrdKG,
		SIP.BaseQty * P.PrdWgt * (CASE P.PrdUnitId WHEN 4 THEN .001 WHEN 5 THEN 1 ELSE 0 END) AS TotPrdLtrs,
		SIP.BaseQty*(CASE P.PrdUnitId WHEN 1 THEN 0 ELSE 0 END) AS TotPrdUnits,
		(CASE ISNULL(UMP1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP1.UOM1Qty,0) END)+
		(CASE ISNULL(UMP2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP2.UOM2Qty,0) END) AS TotPrdPieces,
		(CASE ISNULL(UMBU1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU1.UOM1Qty,0) END)+
		(CASE ISNULL(UMBU2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU2.UOM2Qty,0) END) AS TotPrdBuckets,
		(CASE ISNULL(UMBA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA1.UOM1Qty,0) END)+
		(CASE ISNULL(UMBA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA2.UOM2Qty,0) END) AS TotPrdBags,
		(CASE ISNULL(UMDR1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR1.UOM1Qty,0) END)+
		(CASE ISNULL(UMDR2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR2.UOM2Qty,0) END) AS TotPrdDrums,
		(CASE ISNULL(UMCA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA1.UOM1Qty,0) END)+
		(CASE ISNULL(UMCA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA2.UOM2Qty,0) END)+ 
		CEILING((CASE ISNULL(UMCN1.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN1.UOM1Qty,0) AS NUMERIC(38,6))/CAST(UGC1.ConvFact AS NUMERIC(38,6)) END))+
		CEILING((CASE ISNULL(UMCN2.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN2.UOM2Qty,0) AS NUMERIC(38,6))/CAST(UGC2.ConvFact AS NUMERIC(38,6)) END)) AS TotPrdCartons
		FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
		INNER JOIN RptBillToPrint Rpt ON SI.SalInvNo = Rpt.[Bill Number] AND Rpt.UsrId=@Pi_UsrId
		INNER JOIN Product P ON SIP.PrdID=P.PrdID
		INNER JOIN ProductBatch PB ON SIP.PrdBatID=PB.PrdBatID AND P.PrdID=PB.PrdId
		LEFT OUTER JOIN SalesInvoiceProduct SIPP1 ON SI.SalId=SIPP1.SalId AND SIP.PrdID=SIPP1.PrdID AND SIP.PrdBatID=SIPP1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPP2 ON SI.SalId=SIPP2.SalId AND SIP.PrdID=SIPP2.PrdID AND SIP.PrdBatID=SIPP2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBU1 ON SI.SalId=SIPBU1.SalId AND SIP.PrdID=SIPBU1.PrdID AND SIP.PrdBatID=SIPBU1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBU2 ON SI.SalId=SIPBU2.SalId AND SIP.PrdID=SIPBU2.PrdID AND SIP.PrdBatID=SIPBU2.PrdBatID		
		LEFT OUTER JOIN SalesInvoiceProduct SIPBA1 ON SI.SalId=SIPBA1.SalId AND SIP.PrdID=SIPBA1.PrdID AND SIP.PrdBatID=SIPBA1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBA2 ON SI.SalId=SIPBA2.SalId AND SIP.PrdID=SIPBA2.PrdID AND SIP.PrdBatID=SIPBA2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPDR1 ON SI.SalId=SIPDR1.SalId AND SIP.PrdID=SIPDR1.PrdID AND SIP.PrdBatID=SIPDR1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPDR2 ON SI.SalId=SIPDR2.SalId AND SIP.PrdID=SIPDR2.PrdID AND SIP.PrdBatID=SIPDR2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCA1 ON SI.SalId=SIPCA1.SalId AND SIP.PrdID=SIPCA1.PrdID AND SIP.PrdBatID=SIPCA1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCA2 ON SI.SalId=SIPCA2.SalId AND SIP.PrdID=SIPCA2.PrdID AND SIP.PrdBatID=SIPCA2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCN1 ON SI.SalId=SIPCN1.SalId AND SIP.PrdID=SIPCN1.PrdID AND SIP.PrdBatID=SIPCN1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCN2 ON SI.SalId=SIPCN2.SalId AND SIP.PrdID=SIPCN2.PrdID AND SIP.PrdBatID=SIPCN2.PrdBatID
		LEFT OUTER JOIN UOMMaster UMP1 ON UMP1.UOMId=SIPP1.UOM1Id AND UMP1.UOMDescription='PIECES'
		LEFT OUTER JOIN UOMMaster UMP2 ON UMP1.UOMId=SIPP2.UOM2Id AND UMP2.UOMDescription='PIECES'
		LEFT OUTER JOIN UOMMaster UMBU1 ON UMBU1.UOMId=SIPBU1.UOM1Id AND UMBU1.UOMDescription='BUCKETS' 
		LEFT OUTER JOIN UOMMaster UMBU2 ON UMBU1.UOMId=SIPBU2.UOM2Id AND UMBU2.UOMDescription='BUCKETS'
		LEFT OUTER JOIN UOMMaster UMBA1 ON UMBA1.UOMId=SIPBA1.UOM1Id AND UMBA1.UOMDescription='BAGS' 
		LEFT OUTER JOIN UOMMaster UMBA2 ON UMBA1.UOMId=SIPBA2.UOM2Id AND UMBA2.UOMDescription='BAGS'
		LEFT OUTER JOIN UOMMaster UMDR1 ON UMDR1.UOMId=SIPDR1.UOM1Id AND UMDR1.UOMDescription='DRUMS' 
		LEFT OUTER JOIN UOMMaster UMDR2 ON UMDR1.UOMId=SIPDR2.UOM2Id AND UMDR2.UOMDescription='DRUMS'
		LEFT OUTER JOIN UOMMaster UMCA1 ON UMCA1.UOMId=SIPCA1.UOM1Id AND UMCA1.UOMDescription='CARTONS' 
		LEFT OUTER JOIN UOMMaster UMCA2 ON UMCA1.UOMId=SIPCA2.UOM2Id AND UMCA2.UOMDescription='CARTONS'
		LEFT OUTER JOIN UOMMaster UMCN1 ON UMCN1.UOMId=SIPCN1.UOM1Id AND UMCN1.UOMDescription='CANS' 
		LEFT OUTER JOIN UOMMaster UMCN2 ON UMCN1.UOMId=SIPCN2.UOM2Id AND UMCN2.UOMDescription='CANS'
		LEFT OUTER JOIN (
		SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
		WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
		SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
		GROUP BY P.PrdID) UGC1 ON SIPCN1.PrdId=UGC1.PrdID
		LEFT OUTER JOIN (
		SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
		WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
		SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
		GROUP BY P.PrdID) UGC2 ON SIPCN2.PrdId=UGC2.PrdID
	) A
	GROUP BY SalId,SalInvNo
	--->Till Here
	--Added By Sathishkumar Veeramani 2012/12/13
	IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')
	BEGIN
	     ALTER TABLE RptBillTemplateFinal ADD [Payment Mode] NVARCHAR(20)
	     UPDATE A SET A.[Payment Mode] = Z.[Payment Mode] FROM RptBillTemplateFinal A INNER JOIN 
	    (SELECT SalId,(CASE RtrPayMode WHEN 1 THEN 'Cash' ELSE 'Cheque' END) AS [Payment Mode] FROM SalesInvoice WITH (NOLOCK)) Z ON A.Salid = Z.SalId 
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
DELETE FROM Tbl_DownloadIntegration WHERE SequenceNo = 46 AND ProcessName = 'KitItem'
INSERT INTO Tbl_DownloadIntegration
SELECT 46,'KitItem','Cn2Cs_Prk_KitProducts','Proc_ImportKitProduct',0,500,CONVERT(NVARCHAR(10),GETDATE(),121)
GO
DELETE FROM CustomUpDownload WHERE Slno = 237 AND Module = 'KitItem' AND UpDownload = 'Download'
INSERT INTO CustomUpDownload 
SELECT 237,1,'KitItem','KitItem','Proc_Cn2Cs_KitProduct','Proc_ImportKitProduct','Cn2Cs_Prk_KitProducts','Proc_Cn2Cs_KitProduct','Master','Download',1
GO
DELETE FROM CustomUpDownloadCount WHERE SlNo = 237 AND Module = 'KitItem' AND Updownload = 'Download'
INSERT INTO CustomUpDownloadCount
SELECT 237,1,'KitItem','KitItem','Cn2Cs_Prk_KitProducts','KitProduct','PrdId','','','Download',0,0,0,0,0,
'SELECT PrdCCode AS [Product Code],PrdName AS [Product Name] FROM KitProduct A WITH (NOLOCK),Product B WITH (NOLOCK)
WHERE A.PrdId = B.PrdId AND A.PrdId>OldMax'
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'Cn2Cs_Prk_KitProducts')
DROP TABLE Cn2Cs_Prk_KitProducts
GO
CREATE TABLE Cn2Cs_Prk_KitProducts
(
 DistCode NVARCHAR(50) NULL,
 KitItemCode NVARCHAR(100) NULL,
 ProductCode NVARCHAR(100) NULL,
 ProductBatchCode NVARCHAR(50) NULL,
 Quantity NUMERIC (18,0),
 DownloadFlag NVARCHAR(10) NULL,
 CreatedDate DATETIME
)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ImportKitProduct')
DROP PROCEDURE Proc_ImportKitProduct
GO
CREATE PROCEDURE Proc_ImportKitProduct
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportKitProduct
* PURPOSE	: To Insert records from xml file in the Table Cn2Cs_Prk_KitProducts
* CREATED	: Sathishkumar Veeramani
* CREATED DATE	: 17/12/2012
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {Date} {Developer}  {Brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @hDoc INTEGER 
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Cn2Cs_Prk_KitProducts([DistCode],[KitItemCode],[ProductCode],[ProductBatchCode],[Quantity],[DownloadFlag],[CreatedDate])
	SELECT [DistCode],[KitItemCode],[ProductCode],[ProductBatchCode],[Quantity],[DownloadFlag],[CreatedDate]
	FROM OPENXML (@hdoc,'/Root/Console2CS_KitItemMaster',1)
	WITH (
		[DistCode] 		NVARCHAR(50),
		[KitItemCode]   NVARCHAR(100),
		[ProductCode]      NVARCHAR(100),
		[ProductBatchCode]    NVARCHAR(50),
		[Quantity]           NUMERIC(18,0),
		[DownloadFlag]  NVARCHAR(10),
        [CreatedDate] DATETIME
	) XMLObj
	
	EXEC sp_xml_removedocument @hDoc 
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype = 'U' AND name = 'KitProductToAvoid')
DROP TABLE KitProductToAvoid	
GO
CREATE TABLE KitProductToAvoid
(
    KitPrdCCode NVARCHAR(100),
	PrdCCode    NVARCHAR(100),
	PrdBatCode  NVARCHAR(100) 
)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_Cn2Cs_KitProduct')
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
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE id IN(SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND name ='ETLTempPurchaseReceiptProduct') AND name='FreightCharges' )
ALTER TABLE ETLTempPurchaseReceiptProduct ADD FreightCharges NUMERIC (38,6)
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE id IN(SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND name ='ETL_Prk_PurchaseReceiptPrdDt') AND name='FreightCharges' )
ALTER TABLE ETL_Prk_PurchaseReceiptPrdDt ADD FreightCharges NUMERIC (38,6)
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE id IN(SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND name ='PurchaseReceiptProduct') AND name='FreightCharges' )
ALTER TABLE PurchaseReceiptProduct ADD FreightCharges NUMERIC (38,6)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND name='Cn2Cs_Prk_BLPurchaseReceipt')
DROP TABLE Cn2Cs_Prk_BLPurchaseReceipt
GO
CREATE TABLE Cn2Cs_Prk_BLPurchaseReceipt(
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
	[CreatedUserID] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[DownloadFlag] [varchar](1) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_ImportBLPurchaseReceipt')
DROP PROCEDURE Proc_ImportBLPurchaseReceipt
GO
CREATE PROCEDURE Proc_ImportBLPurchaseReceipt
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_ImportBLPurchaseReceipt
* PURPOSE		: To Insert and Update records  from xml file in the Table Purchase Receipt
* CREATED		: MarySubashini.S
* CREATED DATE	: 09/01/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	--TRUNCATE TABLE Cn2Cs_Prk_BLPurchaseReceipt
	INSERT INTO Cn2Cs_Prk_BLPurchaseReceipt([DistCode],[CompInvNo],[CompInvDate],[NetValue],[TotalTax],[LessDiscount],[LessSchemeAmount],
	[SupplierCode],[CompanyName],[TransporterName],[LRNO],[LRDate],[ProductCode],[UOMCode],
	[PurQty],[CashDiscRs],[CashDiscPer],[LineLevelAmount],[BatchNo],[ManufactureDate],[ExpiryDate],
	[MRP],[ListPriceNSP],[PurchaseTaxValue],[PurchaseDiscount],[PurchaseRate],[SellingRate],
	[SellingRateAfterTAX],[SellingRateAfterVAT],[FreightCharges],[VatBatch],[VATTaxValue],[Status],[FreeSchemeFlag],
	[SchemeRefrNo],[WayBillNo],[BundleDeal],[CreatedUserID],[CreatedDate],[DownloadFlag])
	SELECT  [DistCode],[CompInvNo],[CompInvDate],[NetValue],[TotalTax],[LessDiscount],[LessSchemeAmount],
	[SupplierCode],[CompanyName],[TransporterName],[LRNO],[LRDate],[ProductCode],[UOMCode],
	[PurQty],[CashDiscRs],[CashDiscPer],[LineLevelAmount],[BatchNo],[ManufactureDate],[ExpiryDate],
	[MRP],[ListPriceNSP],[PurchaseTaxValue],[PurchaseDiscount],[PurchaseRate],[SellingRate],
	[SellingRateAfterTAX],[SellingRateAfterVAT],[FreightCharges],[VatBatch],[VATTaxValue],[Status],[FreeSchemeFlag],
	[SchemeRefrNo],[WayBillNo],[BundleDeal],[CreatedUserID],[CreatedDate],DownloadFlag
	FROM 	OPENXML (@hdoc,'/Root/Console2CS_Purchase',1)
	WITH 
	(
		[DistCode]				NVARCHAR(50) ,
		[CompInvNo] 	  		NVARCHAR(25) ,
		[CompInvDate] 			DATETIME ,
		[NetValue]   			NUMERIC(38,6) ,
		[TotalTax] 	  			NUMERIC(38,6) ,
		[LessDiscount] 			NUMERIC(38,6) ,
		[LessSchemeAmount]		NUMERIC(38,6) ,
		[SupplierCode] 			NVARCHAR(50) ,
		[CompanyName]			NVARCHAR(100) ,
		[TransporterName] 		NVARCHAR(100) ,
		[LRNO]   				NVARCHAR(15) ,
		[LRDate] 	  			DATETIME ,
		[ProductCode] 			NVARCHAR(25) ,
		[UOMCode] 				NVARCHAR(25) ,
		[PurQty]  	 			INT ,
		[CashDiscRs]   			NUMERIC(38,6) ,
		[CashDiscPer]   		NUMERIC(38,6) ,
		[LineLevelAmount] 		NUMERIC(38,6) ,
		[BatchNo] 				NVARCHAR(200) ,
		[ManufactureDate]		DATETIME ,
		[ExpiryDate] 	  		DATETIME ,
		[MRP] 					NUMERIC(38,6) ,
		[ListPriceNSP]   		NUMERIC(38,6) ,
		[PurchaseTaxValue] 		NUMERIC(38,6) ,
		[PurchaseDiscount] 		NUMERIC(38,6) ,
		[PurchaseRate]   		NUMERIC(38,6) ,
		[SellingRate]   		NUMERIC(38,6) ,
		[SellingRateAfterTAX]	NUMERIC(38,6) ,
		[SellingRateAfterVAT]	NUMERIC(38,6) ,
		[FreightCharges]		NUMERIC(18,2) ,
		[VatBatch] 	  			INT ,
		[VATTaxValue] 			NUMERIC(38,6) ,
		[Status]   				INT ,
		[FreeSchemeFlag] 		NVARCHAR(5) ,
		[SchemeRefrNo] 			NVARCHAR(25) ,
		[WayBillNo]   			NVARCHAR(50) ,
		[BundleDeal] 	  		NVARCHAR(50) ,
		[CreatedUserID]			INT,
		[CreatedDate]			DATETIME,
		[DownloadFlag] 			NVARCHAR(1)
	) XMLObj

	SELECT * FROM Cn2Cs_Prk_BLPurchaseReceipt
	EXECUTE sp_xml_removedocument @hDoc
END
GO
DELETE FROM PurchaseSequenceDetail
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) VALUES (1,1,'A','Default','LSP','',-1,0,0,1,0,0,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) VALUES (1,2,'B','Default','Gross Amount','',-1,0,0,1,0,0,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) VALUES (1,4,'C','Default','Disc','',-1,0,0,1,1,2,1,250,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) VALUES (1,5,'E','Default','FreightCharges','',-1,0,0,1,0,1,1,0,1,1,'2012-12-31',1,'2012-12-31')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) VALUES (1,6,'D','Default','Tax','',-1,0,0,1,0,1,1,0,1,1,'2009-06-20',1,'2009-06-20')
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_Cn2Cs_PurchaseReceipt')
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_Validate_PurchaseReceiptProduct')
DROP PROCEDURE Proc_Validate_PurchaseReceiptProduct
GO
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
UPDATE ProfileDt SET BtnStatus = 0 WHERE PrfId IN (SELECT UserId FROM Users)
AND MenuId = 'mPrd4' AND BtnIndex NOT IN (1,2)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND Name = 'Proc_UpdateKitItemDt')
DROP PROCEDURE Proc_UpdateKitItemDt
GO
/*
BEGIN TRANSACTION
--EXEC Proc_UpdateKitItemDt 1,7,2,1,7,9,1,'2013-01-12',2,1,1,316,2,2,0 --Cash
EXEC Proc_UpdateKitItemDt 4,0,2,2,1075,1770,1,'2013-01-18',10,1,1,4692,2,2,0
select * from ProductBatchLocation where Prdid IN (895,1010)
select * from StockLedger where Prdid IN (895,1010) and TransDate = '2013-01-18' 
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_UpdateKitItemDt
(
	@Pi_ColId   		INT,
	@Pi_SLColId		INT,
	@Pi_Type  		INT,
	@Pi_SLType		INT,
	@Pi_PrdId  		INT,
	@Pi_PrdBatId  		INT,
	@Pi_LcnId  		INT,
	@Pi_TranDate  		DATETIME,
	@Pi_TranQty  		NUMERIC(38,0),
	@Pi_UsrId  		INT,
	@Pi_TransId		INT,
	@Pi_TransNo		nVARCHAR(50),
	@Pi_TransType		INT,
	@Pi_SlNo		INT,
	@Po_KsErrNo  		INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateKitItemDt
* PURPOSE	: General SP for Updating Kit Item Stock
* CREATED	: Thrinath 
* CREATED DATE	: 28/08/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @sSql AS VARCHAR(2500)
	DECLARE @ErrNo AS INT
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @Qty AS INT
	DECLARE @TotalQty AS INT
	DECLARE @ExistQty AS INT
	DECLARE @FieldName AS VARCHAR(200)
	DECLARE @FieldName1 AS VARCHAR(200)
	DECLARE @ExistPrdId AS INT
	DECLARE @ExistPrdBatId AS INT
	DECLARE @PrdBatLcnStock AS INT
	SET @Po_KsErrNo=0
	
	SELECT @FieldName = CASE @Pi_ColId
		WHEN 1 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 2 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 3 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' 
		WHEN 4 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 5 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 6 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' END
		
   SELECT @FieldName1 = CASE @Pi_ColId
		WHEN 1 THEN 'PrdBatLcnResSih'
		WHEN 2 THEN 'PrdBatLcnResUih'
		WHEN 3 THEN 'PrdBatLcnResFre' 
		WHEN 4 THEN 'PrdBatLcnResSih'
		WHEN 5 THEN 'PrdBatLcnResUih'
		WHEN 6 THEN 'PrdBatLcnResFre' END				
	
	CREATE  TABLE #KitProduct(PrdId INT,PrdBatId INT,Qty NUMERIC(38,0))
	CREATE  TABLE #KitBatch(PrdId INT,PrdBatId INT,Stock NUMERIC(38,0))
	IF @Pi_TransType = 1  --For Taking In The Stock
	BEGIN
		INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
		SELECT KP.PrdId,KPB.PrdBatId,KP.Qty 
			FROM KitProduct KP,KitProductBatch KPB
	  		WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
			KP.KitPrdId = @Pi_PrdId 
			ORDER BY KP.PrdId,KPB.PrdBatId
			
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		
		DECLARE Cur_KitProduct CURSOR FOR 	
			SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		
		OPEN Cur_KitProduct
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
			DELETE FROM #KitBatch
			SET @TotalQty=@Qty*@Pi_TranQty		
			IF @PrdBatId=0
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT PrdId,PrdBatId,1 AS Qty FROM ProductBatch
				WHERE PrdId= @PrdId  AND PrdBatId IN (SELECT MIN(PrdBatId)
				FROM ProductBatch WHERE PrdId=@PrdId) ORDER BY PrdBatId
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT PB.PrdId,PB.PrdBatId,1 FROM ProductBatch PB,KitProductBatch KPB
				WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB.PrdBatId AND 
				KPB.PrdBatId IN(SELECT MIN(KPB1.PrdBatId)FROM ProductBatch PB,KitProductBatch KPB1
				WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB1.PrdBatId) ORDER BY KPB.PrdBatId
			END
				
			SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
				
			DECLARE Cur_KitPrdBatch CURSOR FOR 	
				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
			OPEN Cur_KitPrdBatch
			FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			WHILE @@FETCH_STATUS=0
			BEGIN
				DELETE FROM KitProductTransDt 
					WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
					PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
					SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
					AND TransNo = @Pi_TransNo 
				INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,PrdBatId,LcnId,
					SalTransQty,UnSalTransQty,OfferTransQty,KitQty,Availability,LastModBy,
					LastModDate,AuthId,AuthDate) VALUES
				(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,@ExistPrdBatId,@Pi_LcnId,
					CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
 					CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
					CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
					@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
					
				--SELECT * FROM KitProductTransDt
				
				EXEC Proc_UpdateProductBatchLocation @Pi_ColId,@Pi_Type,@ExistPrdId,@ExistPrdBatId,
					@Pi_LcnId,@Pi_TranDate,@TotalQty,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
				IF @ErrNo = 1
				BEGIN
					SET @Po_KsErrNo = 1
					CLOSE Cur_KitPrdBatch
					DEALLOCATE Cur_KitPrdBatch
					CLOSE Cur_KitProduct
					DEALLOCATE Cur_KitProduct
					
					RETURN 
				END
				EXEC Proc_UpdateStockLedger @Pi_SLColId,@Pi_SLType,@ExistPrdId,@ExistPrdBatId,
					@Pi_LcnId,@Pi_TranDate,@TotalQty,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
				IF @ErrNo = 1
				BEGIN
					SET @Po_KsErrNo = 1
					CLOSE Cur_KitPrdBatch
					DEALLOCATE Cur_KitPrdBatch
					CLOSE Cur_KitProduct
					DEALLOCATE Cur_KitProduct
					
					RETURN 
				END
				FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			END
			CLOSE Cur_KitPrdBatch
			DEALLOCATE Cur_KitPrdBatch		
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
		SET @Po_KsErrNo = 0
		RETURN @Po_KsErrNo
	END
	ELSE	--For Taking Out the Stock
	BEGIN

		IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/09
		BEGIN
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT KP.PrdId,KPB.PrdBatId,KP.Qty FROM KitProduct KP,
				KitProductBatch KPB WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
				KP.KitPrdId = @Pi_PrdId ORDER BY KP.PrdId,KPB.PrdBatId
		END
		ELSE
		BEGIN
--			--->Added By Nanda on 21/01/2010
--			DELETE FROM KitProductTransDt
--
--			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
--			SELECT KP.PrdId,KPB.PrdBatId,KP.Qty 
--				FROM KitProduct KP,KitProductBatch KPB
--  				WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
--				KP.KitPrdId = @Pi_PrdId 
--				ORDER BY KP.PrdId,KPB.PrdBatId
--
--			SELECT PrdId,PrdBatId,Qty FROM #KitProduct
--
--			DECLARE Cur_KitProductNew CURSOR FOR 	
--				SELECT PrdId,PrdBatId,Qty FROM #KitProduct
--			
--			OPEN Cur_KitProductNew
--				FETCH NEXT FROM Cur_KitProductNew
--				INTO @PrdId,@PrdBatId,@Qty
--
--			WHILE @@FETCH_STATUS=0
--			BEGIN
--				DELETE FROM #KitBatch
--
--				SET @TotalQty=@Qty*@Pi_TranQty		
--
--				IF @PrdBatId=0
--				BEGIN
--					INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
--					SELECT PrdId,PrdBatId,1 AS Qty FROM ProductBatch
--						WHERE PrdId= @PrdId  AND PrdBatId IN (SELECT Max(PrdBatId)
--						FROM ProductBatch WHERE PrdId=@PrdId) 
--				END
--				ELSE
--				BEGIN
--					INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
--						SELECT PB.PrdId,PB.PrdBatId,1 FROM ProductBatch PB,KitProductBatch KPB
--						WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB.PrdBatId AND 
--						KPB.PrdBatId IN(SELECT MAX(KPB1.PrdBatId)FROM ProductBatch PB,KitProductBatch KPB1
--						WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB1.PrdBatId)
--				END	
--
--				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
--					ORDER BY PrdBatId
--
--				DECLARE Cur_KitPrdBatchNew CURSOR FOR 	
--					SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
--					ORDER BY PrdBatId
--
--				OPEN Cur_KitPrdBatchNew
--				FETCH NEXT FROM Cur_KitPrdBatchNew
--					INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
--
--				WHILE @@FETCH_STATUS=0
--				BEGIN
--					DELETE FROM KitProductTransDt 
--					WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
--					PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
--					SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
--					AND TransNo = @Pi_TransNo 
--
--					INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,PrdBatId,LcnId,
--					SalTransQty,UnSalTransQty,OfferTransQty,KitQty,Availability,LastModBy,
--					LastModDate,AuthId,AuthDate) VALUES
--					(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,@ExistPrdBatId,@Pi_LcnId,
--					CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
--					CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
--					CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
--					@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
--
--					SELECT 'Nanda2'
--					SELECT * FROM KitProductTransDt
--
--					FETCH NEXT FROM Cur_KitPrdBatchNew
--					INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
--				END
--				CLOSE Cur_KitPrdBatchNew
--				DEALLOCATE Cur_KitPrdBatchNew		
--
--				FETCH NEXT FROM Cur_KitProductNew
--				INTO @PrdId,@PrdBatId,@Qty
--			
--			END
--			CLOSE Cur_KitProductNew
--			DEALLOCATE Cur_KitProductNew
--
--			DELETE FROM #KitProduct
--			--->Till Here
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT DISTINCT KP.PrdId,KP.PrdBatId,KitQty FROM KitProductTransDt KP
				WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
				KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
				AND TransNo = @Pi_TransNo ORDER BY KP.PrdId,KP.PrdBatId
		END
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		DECLARE Cur_KitProduct CURSOR FOR 	
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct		
		OPEN Cur_KitProduct
		FETCH NEXT FROM Cur_KitProduct
		INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
		    SELECT @PrdId,@PrdBatId,@Qty
			DELETE FROM #KitBatch
			SET @TotalQty=@Qty*@Pi_TranQty
			IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/10
			BEGIN
			    IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId <> 0--Cash Bill
					BEGIN
					SELECT 'A'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName1 AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 4 AND @Pi_SLColId = 0 AND @Pi_SLType = 2
				BEGIN
				    SELECT 'B'
				    	SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId AND PrdBatLcnResSih > 0'
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId = 0 AND @Pi_ColId <> 4--Delivery Bill
					BEGIN
					SELECT 'C'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						Having SUM(PrdBatLcnSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,(PrdBatLcnSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId'
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 0 AND @Pi_SLType = 2 --Cancel Bill
				BEGIN
				SELECT 'D'
				    	SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih - PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnSih - PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnSih - PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType <> 2 --Credit Bill
				BEGIN
				SELECT 'E'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT Exists(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)				
				END---------------------------------Till Here 2013/01/10
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT DISTINCT KP.PrdId,KP.PrdBatId,
					CASE @Pi_ColId 	WHEN 1 THEN SalTransQty
							WHEN 2 THEN UnSalTransQty
							WHEN 3 THEN OfferTransQty
							WHEN 4 THEN SalTransQty
							WHEN 5 THEN UnSalTransQty
							WHEN 6 THEN OfferTransQty 
							WHEN 0 THEN 
								CASE @Pi_SLColId WHEN 7 THEN SalTransQty
									WHEN 9 THEN OfferTransQty END
							END
					FROM KitProductTransDt KP
					WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
						KP.PrdId=@PrdId AND KP.PrdBatId=@PrdBatId AND 
						KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
						AND TransNo = @Pi_TransNo 
					ORDER BY KP.PrdId,KP.PrdBatId
			END
			
			--SELECT 'Botree',PrdId,PrdBatId,Stock FROM #KitBatch 
			--ORDER BY PrdBatId
				
			DECLARE Cur_KitPrdBatch CURSOR FOR 	
				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
			OPEN Cur_KitPrdBatch
			FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			WHILE @@FETCH_STATUS=0
			BEGIN
					IF @TotalQty > 0
				BEGIN
				IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added by Sathishkumar Veeramani 2012/01/09
				BEGIN
					IF @PrdBatLcnStock>=@TotalQty
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN

							DELETE FROM KitProductTransDt 
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo 
		
							INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,
								PrdBatId,LcnId,SalTransQty,UnSalTransQty,OfferTransQty,KitQty,
								Availability,LastModBy,LastModDate,AuthId,AuthDate)

							VALUES(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								   @ExistPrdBatId,@Pi_LcnId,
								   CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
			 					   CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
								   CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
								   @Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
								
							 --   SELECT @Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								--@ExistPrdBatId,@Pi_LcnId,
								--CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
			 				--	CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
								--CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
								--@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
								--Select 'Software',* from KitProductTransDt
						END
						SET @PrdBatLcnStock = @TotalQty
						SET @TotalQty = 0
					END
					ELSE
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							DELETE FROM KitProductTransDt 
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo 
		
							INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,
								PrdBatId,LcnId,SalTransQty,UnSalTransQty,OfferTransQty,KitQty,
								Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
							(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								@ExistPrdBatId,@Pi_LcnId,
								CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock WHEN 4 THEN @PrdBatLcnStock ELSE 0 END,
			 					CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock WHEN 5 THEN @PrdBatLcnStock ELSE 0 END,
								CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock WHEN 6 THEN @PrdBatLcnStock ELSE 0 END,
								@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
							select @Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								@ExistPrdBatId,@Pi_LcnId,
								CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock WHEN 4 THEN @PrdBatLcnStock ELSE 0 END,
			 					CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock WHEN 5 THEN @PrdBatLcnStock ELSE 0 END,
								CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock WHEN 6 THEN @PrdBatLcnStock ELSE 0 END,
								@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
						END
						SET @TotalQty = @TotalQty - @PrdBatLcnStock
					END
				END
				ELSE
				BEGIN
					IF @PrdBatLcnStock>=@TotalQty
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							UPDATE KitProductTransDt SET 
								SalTransQty = SalTransQty - (CASE @Pi_ColId WHEN 1 THEN @TotalQty 
									WHEN 4 THEN @TotalQty ELSE 0 END),
								UnSalTransQty = UnSalTransQty - (CASE @Pi_ColId WHEN 2 THEN @TotalQty 
									WHEN 5 THEN @TotalQty ELSE 0 END),
								OfferTransQty = OfferTransQty - (CASE @Pi_ColId WHEN 3 THEN @TotalQty 
									WHEN 6 THEN @TotalQty ELSE 0 END)
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@PrdId AND PrdBatId=@PrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo
						END
						SET @PrdBatLcnStock = @TotalQty
						SET @TotalQty = 0
					END
					ELSE
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							UPDATE KitProductTransDt SET 
								SalTransQty = SalTransQty - (CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock 
									WHEN 4 THEN @PrdBatLcnStock ELSE 0 END),
								UnSalTransQty = UnSalTransQty - (CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock 
									WHEN 5 THEN @PrdBatLcnStock ELSE 0 END),
								OfferTransQty = OfferTransQty - (CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock 
									WHEN 6 THEN @PrdBatLcnStock ELSE 0 END)
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@PrdId AND PrdBatId=@PrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo
						END
						SET @TotalQty = @TotalQty - @PrdBatLcnStock
					END
				END
				
				IF @Pi_ColId > 0 
				BEGIN
					EXEC Proc_UpdateProductBatchLocation @Pi_ColId,@Pi_Type,@ExistPrdId,@ExistPrdBatId,
						@Pi_LcnId,@Pi_TranDate,@PrdBatLcnStock,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
		
					IF @ErrNo = 1
					BEGIN
						SET @Po_KsErrNo = 1
		
						CLOSE Cur_KitPrdBatch
						DEALLOCATE Cur_KitPrdBatch
		
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
				END
				IF @Pi_SLColId > 0
				BEGIN
					EXEC Proc_UpdateStockLedger @Pi_SLColId,@Pi_SLType,@ExistPrdId,@ExistPrdBatId,
						@Pi_LcnId,@Pi_TranDate,@PrdBatLcnStock,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
		
					IF @ErrNo = 1
					BEGIN
						SET @Po_KsErrNo = 1
		
						CLOSE Cur_KitPrdBatch
						DEALLOCATE Cur_KitPrdBatch
		
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
				END
				END
				FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			END
			CLOSE Cur_KitPrdBatch
			DEALLOCATE Cur_KitPrdBatch		
		
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		END
		IF @TotalQty > 0
		BEGIN 
			SET @Po_KsErrNo = 1
			CLOSE Cur_KitProduct
			DEALLOCATE Cur_KitProduct
					
			RETURN 
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
		
		DELETE FROM KitProductTransDt WHERE (SalTransQty + UnSalTransQty + OfferTransQty) = 0
		SET @Po_KsErrNo = 0
		RETURN @Po_KsErrNo
	END
	RETURN @Po_KsErrNo
END
GO
DELETE FROM Configuration WHERE Moduleid IN ('GENCONFIG29','GENCONFIG30','GENCONFIG31')
INSERT INTO Configuration
SELECT 'GENCONFIG29','General Configuration','Display selected UOM in Billing/OrderBooking',0,'0',0.00,29 UNION ALL
SELECT 'GENCONFIG30','General Configuration','Retailer Phone Number As Mandatory',0,'',0.00,30 UNION ALL
SELECT 'GENCONFIG31','General Configuration','Display selected UOM in Purchase Receipt',1,'0',0.00,31
GO
DELETE FROM UOMConfig
INSERT INTO UOMConfig (ModuleId,UomId,Value,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT 'GENCONFIG31',UOMId,1,1,1,GETDATE(),1,GETDATE() FROM UomMaster WHERE UomCode = 'BX'
GO
--Mohana
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptLoadSheetItemWiseParle' AND XTYPE='P')
DROP PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
--Exec Proc_RptLoadSheetItemWiseParle 242,2,0,'',0,0,1
CREATE Procedure Proc_RptLoadSheetItemWiseParle
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
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012
*************************************************************/
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
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @UOMId	 	AS	INT
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
	
	
	--Till Here	
	SELECT DISTINCT P.PrdId ,U.ConversionFactor 
		Into #PrdUomBox
		FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
		INNER JOIN UomMaster UM ON U.UomId=Um.UomId 
		--INNER JOIN SalesInvoiceProduct  SIP ON SIP.Uom1Id =U.UomId or SIP.Uom2Id=U.UomId 
		Where Um.UomCode='BX' or Um.UomCode='GB'
	--SELECT DISTINCT P.PrdId ,U.ConversionFactor 
	--	Into #PrdUomBox
	--	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	--	Inner Join UomMaster UM On U.UomId=Um.UomId 		
	--	Where Um.UomCode='BX'		
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
	
	CREATE TABLE #RptLoadSheetItemWiseParle
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[PrdBatId]			  Int,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
            [PrdCtgValMainId]	  int, 
			[CmpPrdCtgId]		  int,
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[PrdSchemeDisc]		  NUMERIC (38,2),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0),
			[TotalDiscount]		  NUMERIC (38,2),
			[OtherAmt]			  NUMERIC (38,2),
			[AddReduce]			  NUMERIC (38,2),
			[Damage]              NUMERIC (38,2)
	)
	
	SET @TblName = 'RptLoadSheetItemWiseParle'
	
	SET @TblStruct = '
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),		
			[PrdId]        	      INT,  
			[PrdBatId]			  Int,  	
			[Product Code]        VARCHAR (100),
			[Product Description] VARCHAR(200),
            [PrdCtgValMainId]	  int, 
			[CmpPrdCtgId]		  int, 
			[Batch Number]        VARCHAR(50),		
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[PrdSchemeDisc]		  NUMERIC (38,2),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0),
			[TotalDiscount]		  NUMERIC (38,2),
			[OtherAmt]			  NUMERIC (38,2),
			[AddReduce]			  NUMERIC (38,2)'
	
	SET @TblFields = '	
			[SalId]
			[BillNo]
			[PrdId]        	      ,
			[PrdBatId]			  ,
			[Product Code]        ,
			[Product Description] ,
            [PrdCtgValMainId]	  ,
			[CmpPrdCtgId]		  ,
			[Batch Number],
			[MRP]				  ,
			[Selling Rate]
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],
			[PrdWeight],
			[PrdSchemeDisc],
			[GrossAmount],
			[TaxAmount],[NetAmount],[TotalBills],[TotalDiscount],[OtherAmt],[AddReduce]'
	
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
	Print @FromBillNo
	Print @TOBillNo
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		IF @FromBillNo <> 0 Or @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
				[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage])--select * from RtrLoadSheetItemWise
	
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0
			 from RtrLoadSheetItemWise RI
			Left Outer Join SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
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
--			    RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))
	
	GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
					[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage])
			
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),
			BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) As [OtherAmt],0,0
			FROM RtrLoadSheetItemWise RI --select * from RtrLoadSheetItemWise
			Left Outer Join SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
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
							
		 AND [SalInvDate] Between @FromDate and @ToDate
		
			GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId
			ORDER BY PrdDCode
		END 	
	
		UPDATE #RptLoadSheetItemWiseParle SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle)
-----Added By Sathishkumar Veeramani OtherCharges
               SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2
               UPDATE #RptLoadSheetItemWiseParle SET AddReduce = @OtherCharges 
-------Added By Sathishkumar Veeramani Damage Goods Amount---------	
		 UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle R INNER JOIN
		(SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP 
		 WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B
		 ON R.SalId = B.SalId AND R.PrdId = B.PrdId 
		AND R.PrdBatId = B.PrdBatId
------Till Here--------------------		
	/*
		
		For ProductCategory Value and Product Filter
	
		R.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN R.PrdId Else 0 END) OR
		R.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
		AND R.PrdId = (CASE @fPrdId WHEN 0 THEN R.PrdId Else 0 END) OR
		R.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	*/
		
	IF LEN(@PurDBName) > 0
	BEGIN
		
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWiseParle ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
	 + '         WHERE
	 RptId = ' + @Pi_RptId + ' and UsrId = ' + @Pi_UsrId + ' and
	  (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
	
	 AND (Allotmentnumber = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
	
	 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
	
	 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
	
	 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
					
	 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetItemWiseParle'
	
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
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWiseParle ' +
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
			SELECT 0 AS [SalId],'' AS BillNo,LSB.PrdId,0 AS PrdBatId,LSB.[Product Code],LSB.[Product Description],LSB.[PrdCtgValMainId],LSB.[CmpPrdCtgId],
			    0 AS [Batch Number],LSB.[MRP],MAX([Selling Rate]) AS [Selling Rate],
				Cast (Case When SUM([Billed Qty])<MAX(ConversionFactor) Then 0 Else SUM([Billed Qty])/MAX(ConversionFactor) End As Int) As BilledQtyBox,
				Case When SUM([Billed Qty])<MAX(ConversionFactor) Then SUM([Billed Qty]) Else SUM([Billed Qty])%MAX(ConversionFactor)  End As BilledQtyPack,
				SUM(LSB.[Total Qty]) AS [Total Qty],
				Cast(Case When SUM([Total Qty])<MAX(ConversionFactor) Then 0 Else SUM([Total Qty])/MAX(ConversionFactor) End As Int)  As TotalQtyBox,
				Case When SUM([Total Qty])<MAX(ConversionFactor) Then SUM([Total Qty]) Else SUM([Total Qty])%MAX(ConversionFactor)  End As TotalQtyPack,
				SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],Sum([PrdWeight]) AS [PrdWeight],
				SUM(LSB.[Billed Qty]) AS [Billed Qty],
				SUM(LSB.GrossAmount) AS GrossAmount,
				Sum(LSB.PrdSchemeDisc) As PrdSchemeDisc,
				SUM(LSB.TaxAmount) AS TaxAmount,
				SUM(LSB.NETAMOUNT) as NETAMOUNT,LSB.TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],SUM([OtherAmt]) AS [OtherAmt],
				SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage]INTO #Result
				FROM #RptLoadSheetItemWiseParle LSB Inner Join #PrdUomAll PU On PU.PrdId=LSB.PrdId
				GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[MRP],
				LSB.TotalBills,LSB.[PrdCtgValMainId],LSB.[CmpPrdCtgId]
				Order by LSB.[Product Description]				
				
		Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result
		SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[PRoduct Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],MRP,MAX([Selling Rate]) AS [Selling Rate],
		 SUM(BilledQtyBox) AS BilledQtyBox ,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBox) AS TotalQtyBox,
		 SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],
		 SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,
		 SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage] 
		 INTO #TempLoadingSheet FROM #Result GROUP BY [SalId],BillNo,PrdId,[Product Code],[PRoduct Description],MRP,TotalBills
		 ORDER BY [Product Code]
		 SELECT * FROM #TempLoadingSheet
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
		IF EXISTS (Select [Name] From SysObjects Where [Name]='RptLoadSheetItemWiseParle_Excel' And XTYPE='U')
		Drop Table RptLoadSheetItemWiseParle_Excel
	    SELECT * INTO RptLoadSheetItemWiseParle_Excel FROM #TempLoadingSheet ORDER BY [Product Code]
	END 
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE name='Fn_ReturnRptFiltersValue' AND XTYPE='FN')
DROP FUNCTION Fn_ReturnRptFiltersValue
GO
--SELECT dbo.Fn_ReturnRptFiltersValue(3,2,1) AS FilterValue
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
		--->Till Here
		ELSE
		BEGIN
			If @iSelid <> 10 AND @iSelid <> 11  And @iSelid <>66 and @iSelid<>64 AND @iSelid <> 13 AND @iSelid <> 20 
			AND @iSelid <> 102 AND @iSelid <> 103 AND @iSelid <> 105  AND @iSelid <> 108 AND @iSelid <> 115 AND @iSelid <> 117 AND 
			@iSelid <> 119 AND @iSelid <> 126  AND @iSelid <> 139 AND @iSelid <> 140 AND @iSelid <> 152 AND @iSelid <> 157 AND @iSelid <> 158 AND @iSelid <> 161 
			AND @iSelid <> 163 AND @iSelid <> 165 AND @iSelid <> 171  AND @iSelid <> 173 AND @iSelid <> 174 AND @iSelid <> 180 AND @iSelid <> 181
			AND @iSelid <> 195 AND @iSelid <> 199 AND @iSelid <> 201 and @iSelid <> 278
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
				IF @iSelid=102 OR @iSelid=103 OR @iSelid=105 OR  @iSelid=108 OR @iSelid = 117 OR @iSelid = 119 OR @iSelid = 126 OR @iSelid = 159 OR @iSelid = 163  OR @iSelid = 165 OR @iSelid = 180 OR @iSelid = 181
				OR @iSelid = 173 OR @iSelid = 174 OR @iSelid=195 OR @iSelid=201 OR @iSelid = 171 OR @iSelid = 278
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_RptPendingBillReport')
DROP PROCEDURE Proc_RptPendingBillReport
GO
--EXEC Proc_RptPendingBillReport 3,1,0,'Dabur1',0,0,1
CREATE PROCEDURE Proc_RptPendingBillReport
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
	DECLARE @AsOnDate	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @PDCTypeId	 	AS	INT
	SELECT @AsOnDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @PDCTypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	DECLARE @RPTBasedON AS INT
	SET @RPTBasedON =0
	SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,256,@Pi_UsrId) 
	DECLARE @Orderby AS Int
	SET @Orderby=0 
	SET @Orderby = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,277,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@AsOnDate,@AsOnDate)
	Create TABLE #RptPendingBillsDetails
	(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         		INT,
			RtrName 		NVARCHAR(50),	
			SalId         		BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate              DATETIME,
			SalInvRef 		NVARCHAR(50),
			CollectedAmount 	NUMERIC (38,6),
			BalanceAmount   	NUMERIC (38,6),
			ArDays			INT,
			BillAmount      	NUMERIC (38,6)
	)
	CREATE TABLE #TempReceiptInvoice
	(
		SalId		INT,
		InvInsSta	INT,
		InvInsAmt	NUMERIC(38,2)
	)
	
	SET @TblName = 'RptPendingBillsDetails'
	
	SET @TblStruct = '	SMId 			INT,
				SMName			NVARCHAR(50),
				RMId 			INT,
				RMName 			NVARCHAR(50),
				RtrId         		INT,
				RtrName 		NVARCHAR(50),	
				SalId         		BIGINT,
				SalInvNo 		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				CollectedAmount 	NUMERIC (38,6),
				BalanceAmount   	NUMERIC (38,6),
				ArDays			INT,
				BillAmount      	NUMERIC (38,6)'
	
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,CollectedAmount,
			  BalanceAmount,ArDays,BillAmount'
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	END
	ELSE
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo = 3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	 BEGIN
			IF @PDCTypeId=1 --Include PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,
						SI.SalInvRef,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SI.SalInvDate,GetDate()) AS ArDays,SI.SalNetAmt
				 Into #PendingBills1
				 FROM Salesinvoice  SI WITH (NOLOCK),
					  Salesman S WITH (NOLOCK),
					  RouteMaster R WITH (NOLOCK),
					  Retailer RE  WITH (NOLOCK)
				
				 WHERE  SI.SMId = S.SMId  AND SI.RMId = R.RMId
						AND SI.RtrId = RE.RtrId  AND SI.DlvSts IN(4,5)
						AND SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(#PendingBills1.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				Update #PendingBills1
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills1
			END
			IF @PDCTypeId<>1 --Exclude PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,
						SI.SalInvRef,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SalInvDate,GetDate()) AS ArDays,SI.SalNetAmt
				 Into #PendingBills
				
				 FROM Salesinvoice  SI WITH (NOLOCK),
					  Salesman S WITH (NOLOCK),
					  RouteMaster R WITH (NOLOCK),
					  Retailer RE  WITH (NOLOCK)
				
				 WHERE  SI.SMId = S.SMId  AND SI.RMId = R.RMId
						AND SI.RtrId = RE.RtrId  AND SI.DlvSts IN (4,5)
						and SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(#PendingBills.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 AND InvInsDate<=CONVERT(DATETIME,@AsOnDate,103) and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				Update #PendingBills
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills
            END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR' +
				' SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '+
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR ' +
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR '+
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND SalInvDate<=''' + @AsOnDate + ''''
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptPendingBillsDetails'
	
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
		SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPendingBillsDetails
-- Till Here
--	SELECT * FROM #RptPendingBillsDetails ORDER BY SMId,SalId,ArDays,SalInvDate
	--Added by Thiru on 13/11/2009
	DELETE FROM #RptPendingBillsDetails WHERE (BillAmount-CollectedAmount)<=0
--	IF @RPTBasedON=1
--		BEGIN 
--			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
--        END 
--	
	IF @Orderby=0 AND @RPTBasedON=0 
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY SMName 
		END 
	IF @Orderby=1 AND @RPTBasedON=0  
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY RMName 
		END
	IF @Orderby=2 AND @RPTBasedON=0  
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY RtrName 
		END
	IF @Orderby=3 AND @RPTBasedON=0  
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY SalInvNo 
		END
	ELSE 
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY ArDays DESC
		END 
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptPendingBillsDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptPendingBillsDetails_Excel
		CREATE TABLE RptPendingBillsDetails_Excel
		(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         	INT,
			RtrCode			NVARCHAR(100),	
			RtrName 		NVARCHAR(150),	
			SalId         	BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate      DATETIME,
			SalInvRef 		NVARCHAR(50),
			BillAmount      NUMERIC (38,6),
			Cash			NUMERIC (38,6),
			ChequeAmt		NUMERIC (38,6),
			ChequeNo		Int,
			CollectedAmount NUMERIC (38,6),
			BalanceAmount   NUMERIC (38,6),
			ArDays			INT,
			OrderBy			Int
		)
		INSERT INTO RptPendingBillsDetails_Excel( SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,Cash,ChequeAmt,ChequeNo,CollectedAmount,
			  BalanceAmount,ArDays,OrderBy)
		  SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,0 As Cash,0 AS ChequeAmt,0 As ChequeNo,CollectedAmount,
			  BalanceAmount,ArDays,@OrderBy FROM  #RptPendingBillsDetails	
	   
		UPDATE RPT SET RPT.[RtrCode]=R.RtrCode FROM RptPendingBillsDetails_Excel RPT,Retailer R WHERE RPT.[RtrName]=R.RtrName
	END
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='PROC_RptLoadSheetCollectionFormat')
DROP PROCEDURE PROC_RptLoadSheetCollectionFormat
GO
--EXEC PROC_RptLoadSheetCollectionFormat 19,1,0,'',0,0,1
CREATE PROCEDURE PROC_RptLoadSheetCollectionFormat
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
/*******************************************************************************
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}
* 26.02.2010	Panneer		 Added Date,Salesman,route,retailer and Vehicle Filter(Proc_RptCollectionFormat)
*********************************************************************************/
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
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	--Till Here
	
	--Assgin Value for the Filter Variable
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))	
	--Till Here
	EXEC Proc_RptCollectionFormatLS @Pi_RptId ,@FromDate,@ToDate,@VehicleId,@VehicleAllocId,
								  @SMId,@DlvRouteId,@RtrId,@Pi_UsrId
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	--Till Here
	CREATE TABLE #RptLoadSheetCollectionFormat
	(
		[Bill Number]         NVARCHAR(50),
		[Bill Date]           DATETIME,
		[Billed Amount]       NUMERIC (38,2),  		
		[Retailer Name]       NVARCHAR(50),		
		[Outstand Amount]     NUMERIC (38,2),
		[Id]				 INT 
			  		
	
	)
	SET @TblName = 'RptLoadSheetCollectionFormat'
	
	SET @TblStruct = '[Bill Number]         NVARCHAR(50),
			[Bill Date]           DATETIME,
			[Billed Amount]       NUMERIC (38,2),  		
	  		[Retailer Name]       NVARCHAR(50),		
			[Outstand Amount]     NUMERIC (38,2),
		    [Id]				 INT '
	
	SET @TblFields = '[Bill Number],
			[Bill Date]           ,
			[Billed Amount]       ,  		
	  		[Retailer Name]       ,		
			[Outstand Amount]     ,
		    [Id]				  '
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
		INSERT INTO #RptLoadSheetCollectionFormat (  [Bill Number],
		[Bill Date]           ,
		[Billed Amount]       ,  		
		[Retailer Name]       ,		
		[Outstand Amount]     )
		SELECT SalInvNo,SalInvDate,dbo.Fn_ConvertCurrency(SalNetAmt,@Pi_CurrencyId) SalNetAmt,RtrNAme, dbo.Fn_ConvertCurrency(OutstandAmt,@Pi_CurrencyId) OutstandAmt from RtrLoadSheetCollectionFormat
		WHERE (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
		
		AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		
		AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
		AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		
		AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
					
		AND [SalInvDate] Between @FromDate and @ToDate AND UsrId=@Pi_UsrId
			
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetCollectionFormat ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			
			 + '         WHERE (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
							VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
			
			 AND (Allotmentnumber = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
							Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
			
			 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
			
			 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
			
			 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
							
			 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetCollectionFormat'
				
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
			SET @SSQL = 'INSERT INTO #RptLoadSheetCollectionFormat ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLoadSheetCollectionFormat
	-- Till Here
	
	--SELECT * FROM #RptLoadSheetCollectionFormat
	SELECT [Bill Number],CONVERT(VARCHAR(8),[Bill Date],3)[Bill Date],[Retailer Name],[Billed Amount],[Outstand Amount]
	FROM #RptLoadSheetCollectionFormat
	Order BY [Bill Number],[Bill Date],[Retailer Name]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetCollectionFormat_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetCollectionFormat_Excel
		SELECT [Bill Number],[Bill Date],[Retailer Name],[Billed Amount],[Outstand Amount],[Id] INTO RptLoadSheetCollectionFormat_Excel FROM #RptLoadSheetCollectionFormat Order By [Bill Number]
	END
RETURN
END
GO
DELETE FROM RptDetails WHERE RptId=19
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,2,'ToDate',-1,'','','To Date*','',1,'',11,0,1,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,3,'Vehicle',-1,'','VehicleId,VehicleCode,VehicleRegNo','Vehicle...','',1,'',36,0,0,'Press F4/Double Click to Select Vehicle',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,4,'VehicleAllocationMaster',-1,'','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','',1,'',37,0,0,'Press F4/Double Click to Select Vehicle Allocation Number',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,5,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,0,0,'Press F4/Double Click to Select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,6,'RouteMaster',-1,'','RMId,RMCode,RMName','Delivery Route...','',1,'',35,0,0,'Press F4/Double Click to Select Delivery Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,7,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer Group...','',1,'',215,0,0,'Press F4/Double Click to select Retailer Group',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,8,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'',3,0,0,'Press F4/Double Click to select Retailer',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (19,9,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Line Spacing*...','',1,'',44,1,1,'Press F4/Double Click to select the line spacing',0)
GO
DELETE FROM RptFilter WHERE SelcId=44 AND RptId=19
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc) SELECT 19,44,1,'Single Line'
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc) SELECT 19,44,2,'Double Line'
GO
SELECT DISTINCT PurRcptId,PrdSlNo,LineEffectAmount INTO #Temp1PurchaseReceiptLineAmount FROM PurchaseReceiptLineAmount WITH (NOLOCK)
INSERT INTO PurchaseReceiptLineAmount
SELECT DISTINCT A.PurRcptId,A.PrdSlNo,'E',0,0,0,0,0,A.LineEffectAmount,Availability,LastModBy,LastModDate,AuthId,Authdate 
FROM #Temp1PurchaseReceiptLineAmount A WITH (NOLOCK),PurchaseReceiptLineAmount B WITH (NOLOCK) WHERE A.PurRcptId = B.PurRcptId AND B.RefCode <> 'E' AND 
A.PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WHERE RefCode = 'E') ORDER BY A.PurRcptId
DROP TABLE #Temp1PurchaseReceiptLineAmount
GO
DELETE FROM Configuration WHERE ModuleId IN ('Datatransfer35','Datatransfer37')
INSERT INTO Configuration
SELECT 'DATATRANSFER35','DataTransfer','Updates Folder',0,'C:\Program Files\Core Stocky\New Release',0.00,35 UNION ALL
SELECT 'DATATRANSFER37','DataTransfer','Deploy Error Log Folder',0,'C:\Program Files\Core Stocky\Deploy ErrorLog',0.00,37
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 400' ,'400'
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 400)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(400,'D','2013-01-04',GETDATE(),1,'Core Stocky Service Pack 400')
GO