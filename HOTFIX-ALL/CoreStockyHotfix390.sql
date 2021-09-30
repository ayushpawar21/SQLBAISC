--[Stocky HotFix Version]=390
Delete from Versioncontrol where Hotfixid='390'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('390','2.0.0.5','D','2011-09-26','2011-09-26','2011-09-26',convert(varchar(11),getdate()),'Major: Product Release')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 390' ,'390'
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_InsertBillTemplateField')
DROP PROCEDURE Proc_InsertBillTemplateField
GO
CREATE PROCEDURE [dbo].[Proc_InsertBillTemplateField]
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
		INSERT INTO SalesInvoiceReportingColumns VALUES ('Remarks','Remarks','nvarchar(200)',@Pi_Type,1,1,getDate(),1,getDate())
		INSERT INTO SalesInvoiceReportingColumns VALUES ('SalesInvoice Line Gross Amount','PrdGrossAmountAftEdit','numeric(38,2)',@Pi_Type,1,1,getDate(),1,getDate())
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
Exec Proc_InsertBillTemplateField 2,2
GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'RptSRNSALESRETURN') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE RptSRNSALESRETURN
GO
 CREATE TABLE RptSRNSALESRETURN
( 
	[Credit Note Reference No] nvarchar(50),
	[Distributor Code] nvarchar(20),
	[Distributor Name] nvarchar(50),
	[Distributor Address1] nvarchar(50),
	[Distributor Address2] nvarchar(50),
	[Distributor Address3] nvarchar(50),
	[PinCode] int,
	[PhoneNo] nvarchar(50),
	[Tax Type] tinyint,
	[TIN Number] nvarchar(50),
	[Deposit Amount] numeric(38,2),
	[CST Number] nvarchar(50),
	[LST Number] nvarchar(50),
	[Licence Number] nvarchar(50),
	[Drug Licence Number 1] nvarchar(50),
	[Drug1 Expiry Date] DateTime,
	[Drug Licence Number 2] nvarchar(50),
	[Drug2 Expiry Date] DateTime,
	[Pesticide Licence Number] nvarchar(50),
	[Pesticide Expiry Date] DateTime,
	[SalId] INT,
	[Invoice Number] nvarchar(50),
	[Invoice Date] DATETIME,
	[ReturnId] INT,
	[Sales Return Number] nvarchar(50),
	[Sales Return Date] DATETIME,
	[Sales Man] nvarchar(50),
	[Route] nvarchar(50),
	[Retailer Code] nvarchar(50),
	[Retailer Name] nvarchar(150),
	[Retailer Phone Number] nvarchar(50),
	[Retailer CST Number] nvarchar(50),
	[Retailer Drug Lic  Number] nvarchar(50),
	[Retailer Lic Number] nvarchar(50),
	[Retailer Tin Number] nvarchar(50),
	[Retailer Address] nvarchar(50),
	[Product Company Code] nvarchar(20),
	[Product Company Name] nvarchar(150),
	[Product Short Code] nvarchar(100),
	[Product Short Name] nvarchar(150),
	[Product Name] nvarchar(150),
	[Stock Type] nvarchar(100),
	[Return Quantity] NUMERIC(18,0),
	[Selling Rate] NUMERIC(18,6),
	[Gross Amount] NUMERIC(18,6),
	[Special Discount] NUMERIC(18,6),
	[Scheme Discount] NUMERIC(18,6),
	[Distributor Discount] NUMERIC(18,6),
	[Cash Discount] NUMERIC(18,6),
	[Tax Percentage] NUMERIC(18,6),
	[Tax Amount Line Level] NUMERIC(18,6),
	[Line level Net Amount] NUMERIC(18,6),
	[Reason] nvarchar(100),
	[Type] nvarchar(50),
	[Mode] nvarchar(50),
	[Total Gross Amount] NUMERIC(18,6),
	[Total Special Discount] NUMERIC(18,6),
	[Total Scheme Discount] NUMERIC(18,6),
	[Total Distributor Discount] NUMERIC(18,6),
	[Total Cash Discount] NUMERIC(18,6),
	[Total Tax Amount] NUMERIC(18,6),
	[Total Net Amount] NUMERIC(18,6),
	[Total Discount] NUMERIC(18,6),
	[RtrId] INT,
	[RMID] INT,
	[SMID] INT,
	[MRP] NUMERIC(18,6),
	[Credit Note/Replacement Reference No] nvarchar(50),
	UsrId int,
	Visibility tinyint 
)
GO
IF EXISTS (Select * from SysObjects Where Xtype = 'P' And Name = 'Proc_RptSRNSALESRETURN')
DROP PROCEDURE Proc_RptSRNSALESRETURN
GO
--Exec Proc_RptSRNSALESRETURN 1,1
CREATE PROCEDURE [dbo].[Proc_RptSRNSALESRETURN]  
(
	@Pi_UsrId Int = 1,
	@Pi_Type INT 
) 
As SET NOCOUNT ON 
Begin  
 DECLARE @FromReturnId AS  VARCHAR(25)  
 DECLARE @ToReturnId   AS  VARCHAR(25) 
 DECLARE @Cnt AS INT 
 DECLARE @TempReturnId TABLE (ReturnId INT) 
 DECLARE  @RptSRNTemplate Table 
( 
	[Credit Note Reference No] nvarchar(50),
	[Distributor Code] nvarchar(20),
	[Distributor Name] nvarchar(50),
	[Distributor Address1] nvarchar(50),
	[Distributor Address2] nvarchar(50),
	[Distributor Address3] nvarchar(50),
	[PinCode] int,
	[PhoneNo] nvarchar(50),
	[Tax Type] tinyint,
	[TIN Number] nvarchar(50),
	[Deposit Amount] numeric(38,2),
	[CST Number] nvarchar(50),
	[LST Number] nvarchar(50),
	[Licence Number] nvarchar(50),
	[Drug Licence Number 1] nvarchar(50),
	[Drug1 Expiry Date] DateTime,
	[Drug Licence Number 2] nvarchar(50),
	[Drug2 Expiry Date] DateTime,
	[Pesticide Licence Number] nvarchar(50),
	[Pesticide Expiry Date] DateTime,
	[SalId] INT,
	[Invoice Number] nvarchar(50),
	[Invoice Date] DATETIME,
	[ReturnId] INT,
	[Sales Return Number] nvarchar(50),
	[Sales Return Date] DATETIME,
	[Sales Man] nvarchar(50),
	[Route] nvarchar(50),
	[Retailer Code] nvarchar(50),
	[Retailer Name] nvarchar(150),
	[Retailer Phone Number] nvarchar(50),
	[Retailer CST Number] nvarchar(50),
	[Retailer Drug Lic  Number] nvarchar(50),
	[Retailer Lic Number] nvarchar(50),
	[Retailer Tin Number] nvarchar(50),
	[Retailer Address] nvarchar(50),
	[Product Company Code] nvarchar(20),
	[Product Company Name] nvarchar(150),
	[Product Short Code] nvarchar(100),
	[Product Short Name] nvarchar(150),
	[Product Name] nvarchar(150),
	[Stock Type] nvarchar(100),
	[Return Quantity] NUMERIC(18,0),
	[Selling Rate] NUMERIC(18,6),
	[Gross Amount] NUMERIC(18,6),
	[Special Discount] NUMERIC(18,6),
	[Scheme Discount] NUMERIC(18,6),
	[Distributor Discount] NUMERIC(18,6),
	[Cash Discount] NUMERIC(18,6),
	[Tax Percentage] NUMERIC(18,6),
	[Tax Amount Line Level] NUMERIC(18,6),
	[Line level Net Amount] NUMERIC(18,6),
	[Reason] nvarchar(100),
	[Type] nvarchar(50),
	[Mode] nvarchar(50),
	[Total Gross Amount] NUMERIC(18,6),
	[Total Special Discount] NUMERIC(18,6),
	[Total Scheme Discount] NUMERIC(18,6),
	[Total Distributor Discount] NUMERIC(18,6),
	[Total Cash Discount] NUMERIC(18,6),
	[Total Tax Amount] NUMERIC(18,6),
	[Total Net Amount] NUMERIC(18,6),
	[Total Discount] NUMERIC(18,6),
	[RtrId] INT,
	[RMID] INT,
	[SMID] INT,
	[MRP] NUMERIC(18,6),
	[Credit Note/Replacement Reference No] nvarchar(50),
	UsrId int,Visibility tinyint 
) 
	IF @Pi_Type=1 
	BEGIN   
		INSERT INTO @TempReturnId SELECT SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 32  AND UsrId=@Pi_UsrId
	END
	ELSE   
	BEGIN 
		SELECT @FromReturnId=SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 14 AND UsrId=@Pi_UsrId
		SELECT @ToReturnId=SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 15  AND UsrId=@Pi_UsrId
	END
	IF @Pi_Type=1 BEGIN 
		Insert into @RptSRNTemplate  
		SELECT CreditNoteRetailer.CrNoteNumber,	DistributorCode,	DistributorName,	DistributorAdd1,
		DistributorAdd2,	DistributorAdd3,	PinCode,	PhoneNo,	TaxType,	TINNo,	DepositAmt,
		CSTNo,	LSTNo,	LicNo,	DrugLicNo1,	Drug1ExpiryDate,	DrugLicNo2,	Drug2ExpiryDate,	PestLicNo,
		PestExpiryDate,	SalesInvoice.SalId,	SalInvNo,	SalInvDate,	ReturnProduct.ReturnId,	ReturnCode,
		ReturnDate,	SMCode,	RMCode,	RtrCode,	RtrName,	RtrPhoneNo,	RtrCstNo,	RtrDrugLicNo,	RtrLicNo,
		RtrTINNo,	RtrAdd1,	CmpCode,	CmpName,	Product.PrdDCode,	Product.PrdShrtName,	Product.PrdName,
		UserStockType,	BaseQty,	PrdEditSelRte,	PrdGrossAmt,	PrdSplDisAmt,	PrdSchDisAmt,	PrdDBDisAmt,
		PrdCDDisAmt,	SUM(TaxPerc),	SUM(TaxAmt),	PrdNetAmt,	Description,	InvoiceType,	ReturnMode,	RtnGrossAmt,
		RtnSplDisAmt,	RtnSchDisAmt,	RtnDBDisAmt,	RtnCashDisAmt,	RtnTaxAmt,	RtnNetAmt,	RtnNetAmt,	Retailer.RtrId,
		RouteMaster.RMId,	SalesMan.SMId,	ReturnProduct.PrdUnitMRP,	CreditNoteReplacementHd.CNRRefNo,
		@Pi_UsrId,1 Visibility FROM  Distributor,ReturnProduct INNER JOIN ReturnHeader ON ReturnHeader.ReturnId=ReturnProduct.ReturnId
		INNER JOIN Retailer ON ReturnHeader.RtrId=Retailer.RtrId
		INNER JOIN SalesMan ON ReturnHeader.SMId=SalesMan.SMId
		INNER JOIN RouteMaster ON ReturnHeader.RMId=RouteMaster.RMId 
		LEFT OUTER JOIN SalesInvoice ON SalesInvoice.SalId=ReturnProduct.SalId
		LEFT OUTER JOIN CreditNoteReplacementHd ON CreditNoteReplacementHd.SrNo=ReturnHeader.ReturnCode 
		LEFT OUTER JOIN CreditNoteRetailer ON CreditNoteRetailer.PostedFrom=ReturnHeader.ReturnCode AND CreditNoteRetailer.TransId = 30 
		INNER JOIN Product ON ReturnProduct.PrdId=Product.PrdId
		INNER JOIN Company ON Product.CmpId=Company.CmpId
		INNER JOIN StockType ON StockType.StockTypeId=ReturnProduct.StockTypeId
		LEFT OUTER JOIN ReturnProductTax ON ReturnProductTax.ReturnId=ReturnProduct.ReturnId
		AND ReturnProduct.Slno=ReturnProductTax.PrdSlNo
		LEFT OUTER JOIN ReasonMaster ON ReasonMaster.ReasonId=ReturnProduct.ReasonId WHERE ReturnHeader.ReturnId IN (SELECT ReturnId FROM @TempReturnId)  
		GROUP BY CREDITNOTERETAILER.CRNOTENUMBER,	DISTRIBUTORCODE,	DISTRIBUTORNAME,
		DISTRIBUTORADD1,	DISTRIBUTORADD2,	DISTRIBUTORADD3,	PINCODE,	PHONENO,	TAXTYPE,	TINNO,	DEPOSITAMT,
		CSTNO,	LSTNO,	LICNO,	DRUGLICNO1,	DRUG1EXPIRYDATE,	DRUGLICNO2,	DRUG2EXPIRYDATE,	PESTLICNO,	PESTEXPIRYDATE,
		SALESINVOICE.SALID,	SALINVNO,	SALINVDATE,	RETURNPRODUCT.RETURNID,	RETURNCODE,	RETURNDATE,	SMCODE,	RMCODE,
		RTRCODE,	RTRNAME,	RTRPHONENO,	RTRCSTNO,	RTRDRUGLICNO,	RTRLICNO,	RTRTINNO,	RTRADD1,	CMPCODE,
		CMPNAME,	PRODUCT.PRDDCODE,	PRODUCT.PRDSHRTNAME,	PRODUCT.PRDNAME,	USERSTOCKTYPE,	BASEQTY,	PRDEDITSELRTE,
		PRDGROSSAMT,	PRDSPLDISAMT,	PRDSCHDISAMT,	PRDDBDISAMT,	PRDCDDISAMT,	PRDNETAMT,	DESCRIPTION,	INVOICETYPE,
		RETURNMODE,	RTNGROSSAMT,	RTNSPLDISAMT,	RTNSCHDISAMT,	RTNDBDISAMT,	RTNCASHDISAMT,	RTNTAXAMT,	RTNNETAMT,
		RTNNETAMT,	RETAILER.RTRID,	ROUTEMASTER.RMID,	SALESMAN.SMID,	RETURNPRODUCT.PRDUNITMRP,	CREDITNOTEREPLACEMENTHD.CNRREFNO 
	END  
	ELSE 
	BEGIN 
		Insert into @RptSRNTemplate  
		SELECT CreditNoteRetailer.CrNoteNumber,	DistributorCode,	DistributorName,	DistributorAdd1,	DistributorAdd2,
		DistributorAdd3,	PinCode,	PhoneNo,	TaxType,	TINNo,	DepositAmt,	CSTNo,	LSTNo,	LicNo,	DrugLicNo1,
		Drug1ExpiryDate,	DrugLicNo2,	Drug2ExpiryDate,	PestLicNo,	PestExpiryDate,	SalesInvoice.SalId,	SalInvNo,
		SalInvDate,	ReturnProduct.ReturnId,	ReturnCode,	ReturnDate,	SMCode,	RMCode,	RtrCode,	RtrName,	RtrPhoneNo,
		RtrCstNo,	RtrDrugLicNo,	RtrLicNo,	RtrTINNo,	RtrAdd1,	CmpCode,	CmpName,	Product.PrdDCode,
		Product.PrdShrtName,	Product.PrdName,	UserStockType,	BaseQty,	PrdEditSelRte,	PrdGrossAmt,	PrdSplDisAmt,
		PrdSchDisAmt,	PrdDBDisAmt,	PrdCDDisAmt,	SUM(TaxPerc),	SUM(TaxAmt),	PrdNetAmt,	Description,	InvoiceType,
		ReturnMode,	RtnGrossAmt,	RtnSplDisAmt,	RtnSchDisAmt,	RtnDBDisAmt,	RtnCashDisAmt,	RtnTaxAmt,	RtnNetAmt,	RtnNetAmt,
		Retailer.RtrId,	RouteMaster.RMId,	SalesMan.SMId,	ReturnProduct.PrdUnitMRP,	CreditNoteReplacementHd.CNRRefNo,
		@Pi_UsrId,1 Visibility FROM  Distributor,ReturnProduct INNER JOIN ReturnHeader ON ReturnHeader.ReturnId=ReturnProduct.ReturnId
		INNER JOIN Retailer ON ReturnHeader.RtrId=Retailer.RtrId
		INNER JOIN SalesMan ON ReturnHeader.SMId=SalesMan.SMId
		INNER JOIN RouteMaster ON ReturnHeader.RMId=RouteMaster.RMId
		LEFT OUTER JOIN SalesInvoice ON SalesInvoice.SalId=ReturnProduct.SalId
		LEFT OUTER JOIN CreditNoteReplacementHd ON CreditNoteReplacementHd.SrNo=ReturnHeader.ReturnCode
		LEFT OUTER JOIN CreditNoteRetailer ON CreditNoteRetailer.PostedFrom=ReturnHeader.ReturnCode  AND CreditNoteRetailer.TransId=30
		INNER JOIN Product ON ReturnProduct.PrdId=Product.PrdId
		INNER JOIN Company ON Product.CmpId=Company.CmpId
		INNER JOIN StockType ON StockType.StockTypeId=ReturnProduct.StockTypeId
		LEFT OUTER JOIN ReturnProductTax ON ReturnProductTax.ReturnId=ReturnProduct.ReturnId
		AND ReturnProduct.Slno=ReturnProductTax.PrdSlNo
		LEFT OUTER JOIN ReasonMaster ON ReasonMaster.ReasonId=ReturnProduct.ReasonId WHERE ReturnHeader.ReturnId BETWEEN  @FromReturnId  AND  @ToReturnId  
		GROUP BY CREDITNOTERETAILER.CRNOTENUMBER,	DISTRIBUTORCODE,	DISTRIBUTORNAME,	DISTRIBUTORADD1,	DISTRIBUTORADD2,
		DISTRIBUTORADD3,	PINCODE,	PHONENO,	TAXTYPE,	TINNO,	DEPOSITAMT,	CSTNO,	LSTNO,	LICNO,	DRUGLICNO1,	DRUG1EXPIRYDATE,
		DRUGLICNO2,	DRUG2EXPIRYDATE,	PESTLICNO,	PESTEXPIRYDATE,	SALESINVOICE.SALID,	SALINVNO,	SALINVDATE,	RETURNPRODUCT.RETURNID,
		RETURNCODE,	RETURNDATE,	SMCODE,	RMCODE,	RTRCODE,	RTRNAME,	RTRPHONENO,	RTRCSTNO,	RTRDRUGLICNO,	RTRLICNO,	RTRTINNO,
		RTRADD1,	CMPCODE,	CMPNAME,	PRODUCT.PRDDCODE,	PRODUCT.PRDSHRTNAME,	PRODUCT.PRDNAME,	USERSTOCKTYPE,	BASEQTY,
		PRDEDITSELRTE,	PRDGROSSAMT,	PRDSPLDISAMT,	PRDSCHDISAMT,	PRDDBDISAMT,	PRDCDDISAMT,	PRDNETAMT,	DESCRIPTION,
		INVOICETYPE,	RETURNMODE,	RTNGROSSAMT,	RTNSPLDISAMT,	RTNSCHDISAMT,	RTNDBDISAMT,	RTNCASHDISAMT,	RTNTAXAMT,
		RTNNETAMT,	RTNNETAMT,	RETAILER.RTRID,	ROUTEMASTER.RMID,	SALESMAN.SMID,	RETURNPRODUCT.PRDUNITMRP,	CREDITNOTEREPLACEMENTHD.CNRREFNO 
	END  
	INSERT INTO RptSRNSALESRETURN SELECT * FROM @RptSRNTemplate 
	Select * from RptSRNSALESRETURN
END
GO
IF EXISTS ( Select * from Sysobjects Where Xtype = 'U' And Name = 'TmpRPTBillDetailsRtrLevelTaxSummary_Excel')
DROP TABLE TmpRPTBillDetailsRtrLevelTaxSummary_Excel
GO
IF EXISTS ( Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_RetailerWsBillTaxSummary')
DROP PROCEDURE Proc_RetailerWsBillTaxSummary
GO
--SELECT * FROM RPTBillDetailsRtrLevelTaxSummary
-- select  * from users
-- EXEC Proc_RetailerWsBillTaxSummary 224,2,0,'Deploy',0,0,1,0
CREATE Procedure [dbo].[Proc_RetailerWsBillTaxSummary]
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
/*********************************
* PROCEDURE	: Proc_RetailerWsBillTaxSummary
* PURPOSE	: To Display Net Tax summary report
* CREATED	: 
* CREATED DATE	: 17/03/2011
* NOTE		: General SP for Retailer wise bill details Net Tax 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TaxId AS FLOAT 
	DECLARE @TaxName AS NVARCHAR(100)
	DECLARE @SSQL AS VARCHAR(8000)
	DECLARE @Count AS INT 
	DECLARE @SalTaxableName AS NVARCHAR(100)
	DECLARE @SalTaxName AS NVARCHAR(100)
	DECLARE @RtnTaxableName AS NVARCHAR(100)
	DECLARE @RtnTaxName AS NVARCHAR(100)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @SMId	 	AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @TransNo	AS	NVARCHAR(100)
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
 	SET @TransNo =(SELECT TOP 1 SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId))

	IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='RPTBillDetailsRtrLevelTaxSummary')
	BEGIN
		DROP TABLE RPTBillDetailsRtrLevelTaxSummary	
	END
	CREATE TABLE [RPTBillDetailsRtrLevelTaxSummary](
		[Bill Id]				BIGINT,
	[Bill Number]			NVARCHAR(50),
	[Bill Date]				DATETIME,	
	[Retailer Company Code]	  NVARCHAR(50),
	[Retailer Code (Dist)]	  NVARCHAR(50),
	[Retailer Name]			NVARCHAR(150),
	[Retailer Address 1]	 NVARCHAR(200),
	[Retailer Address 2]	 NVARCHAR(200),
	[Retailer Address 3]	 NVARCHAR(200),
	[Retailer Tax Group]	 NVARCHAR(100),	
	[Taxable Status]		 NVARCHAR(5),
	[TIN Number]			 NVARCHAR(50),
	[Gross Amount]			 NUMERIC(38,6),
	[Special Discount]		 NUMERIC(38,6),
	[Scheme Discount]		 NUMERIC(38,6),
	[Distributor Discount]	 NUMERIC(38,6),
	[Cash Discount]			 NUMERIC(38,6),
	[Taxable Amount1]		NUMERIC(38,6),
	[Taxable Amount2]		NUMERIC(38,6),
	[Taxable Amount3]		NUMERIC(38,6),
	[Taxable Amount4]		NUMERIC(38,6),
	[Taxable Amount5]		NUMERIC(38,6),
	[Taxable Amount6]		NUMERIC(38,6),
	[Taxable Amount7]		NUMERIC(38,6),
	[Taxable Amount8]		NUMERIC(38,6),
	[Tax Amount1]			NUMERIC(38,6),	 
	[Tax Amount2]			NUMERIC(38,6),	
	[Tax Amount3]			NUMERIC(38,6),	
	[Tax Amount4]			NUMERIC(38,6),	
	[Tax Amount5]			NUMERIC(38,6),	
	[Tax Amount6]			NUMERIC(38,6),	
	[Tax Amount7]			NUMERIC(38,6),	
	[Tax Amount8]			NUMERIC(38,6),	
	[Total Tax]				NUMERIC(38,6),	
	[Display Amount]		NUMERIC(38,6),	
	[Market Return Ref Number]	    NVARCHAR(50),	
	[Market Return - Gross Amount]	NUMERIC(38,6),
	[Market Return - Special Discount]	NUMERIC(38,6),
	[Market Return - Scheme Discount]	NUMERIC(38,6),
	[Market Return - Distributor Discount]	NUMERIC(38,6),
	[Market Return - Cash Discount]	NUMERIC(38,6),
	[Market Return - Taxable Amount1]NUMERIC(38,6),	
	[Market Return - Taxable Amount2]	NUMERIC(38,6),
	[Market Return - Taxable Amount3]	NUMERIC(38,6),
	[Market Return - Taxable Amount4]	NUMERIC(38,6),
	[Market Return - Taxable Amount5]	NUMERIC(38,6),
	[Market Return - Taxable Amount6]	NUMERIC(38,6),
	[Market Return - Taxable Amount7]	NUMERIC(38,6),
	[Market Return - Taxable Amount8]	NUMERIC(38,6),
	[Market Return - Tax Amount1]	NUMERIC(38,6),
	[Market Return - Tax Amount2]	NUMERIC(38,6),
	[Market Return - Tax Amount3]	NUMERIC(38,6),
	[Market Return - Tax Amount4]	NUMERIC(38,6),
	[Market Return - Tax Amount5]	NUMERIC(38,6),
	[Market Return - Tax Amount6]	NUMERIC(38,6),
	[Market Return - Tax Amount7]	NUMERIC(38,6),
	[Market Return - Tax Amount8]	NUMERIC(38,6),
	[Market Return - Total Tax]		NUMERIC(38,6),
	[Credit Note Adjustment]		NUMERIC(38,6),
	[Debit Note Adjustment]			NUMERIC(38,6),
	[On Account Adjustment]			NUMERIC(38,6),
	[Other Charges (Add)]			NUMERIC(38,6),
	[Other Charges (Reduce)]		NUMERIC(38,6),
	[Invoice Net Amount]			NUMERIC(38,6)
	)
	DECLARE  @SalTaxAmt TABLE
	(
		SalId BIGINT ,
		TaxId FLOAT ,
		SalTaxPerc FLOAT,
		SalTaxableAmount NUMERIC(38,6),
		SalTaxAmount NUMERIC(38,6)
	)
	DECLARE  @RtnTaxAmt TABLE
	(
		SalId BIGINT ,
		TaxId FLOAT ,
		RtnTaxPerc FLOAT,
		RtnTaxableAmount NUMERIC(38,6),
		RtnTaxAmount NUMERIC(38,6)
	)	
	DECLARE  @TaxPerName TABLE
	(
		TaxId FLOAT,
		TaxName FLOAT
	)
	TRUNCATE TABLE RPTBillDetailsRtrLevelTaxSummary
	
	INSERT INTO RPTBillDetailsRtrLevelTaxSummary ([Bill Id],[Bill Number],[Bill Date],[Retailer Company Code],[Retailer Code (Dist)],[Retailer Name],
			[Retailer Address 1],[Retailer Address 2],[Retailer Address 3],[Retailer Tax Group],
			[Taxable Status],[TIN Number],[Gross Amount],[Special Discount],
			[Scheme Discount],[Distributor Discount],[Cash Discount],[Total Tax],
			[Display Amount],[Market Return Ref Number],[Market Return - Gross Amount],
			[Market Return - Special Discount],[Market Return - Scheme Discount],
			[Market Return - Distributor Discount],[Market Return - Cash Discount],
			[Market Return - Total Tax],[Credit Note Adjustment],[Debit Note Adjustment],
			[On Account Adjustment],[Other Charges (Add)],[Other Charges (Reduce)],[Invoice Net Amount],
			[Taxable Amount1],[Taxable Amount2],[Taxable Amount3],[Taxable Amount4],
			[Taxable Amount5],[Taxable Amount6],[Taxable Amount7],[Taxable Amount8],
			[Tax Amount1],[Tax Amount2],[Tax Amount3],[Tax Amount4],
			[Tax Amount5],[Tax Amount6],[Tax Amount7],[Tax Amount8],
			[Market Return - Taxable Amount1],[Market Return - Taxable Amount2],
			[Market Return - Taxable Amount3],[Market Return - Taxable Amount4],
			[Market Return - Taxable Amount5],[Market Return - Taxable Amount6],
			[Market Return - Taxable Amount7],[Market Return - Taxable Amount8],
			[Market Return - Tax Amount1],[Market Return - Tax Amount2],
			[Market Return - Tax Amount3],[Market Return - Tax Amount4],
			[Market Return - Tax Amount5],[Market Return - Tax Amount6],
			[Market Return - Tax Amount7],[Market Return - Tax Amount8])
	
		SELECT  
			SI.SalId,SI.SalInvNo,SI.SalInvDate,R.CmpRtrCode,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,
			ISNULL(TG.TaxGroupName,'') AS TaxGroupName,(CASE  R.RtrTaxable WHEN 1 THEN 'YES' ELSE 'NO' END) AS RtrTaxable ,
			R.RtrTINNo,SI.SalGrossAmount,SI.SalSplDiscAmount,SI.SalSchDiscAmount,SI.SalDBDiscAmount,
			SI.SalCDAmount,SI.SalTaxAmount,SI.WindowDisplayAmount,ISNULL(RH.ReturnCode,''),
			(-1) * ISNULL(RH.RtnGrossAmt,0), (-1) * ISNULL(RH.RtnSplDisAmt,0),
			(-1) * ISNULL(RH.RtnSchDisAmt,0),(-1) * ISNULL(RH.RtnDBDisAmt,0),
			(-1) * ISNULL(RH.RtnCashDisAmt,0),(-1) * ISNULL(RH.RtnTaxAmt,0),
			SI.CRAdjAmount,SI.DBAdjAmount,SI.OnAccountAmount,SI.OtherCharges,SI.OtherCharges,SI.SalNetAmt,
			0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,
			0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00
		FROM 
			SalesInvoice SI (NOLOCK)
			INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			LEFT OUTER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=R.TaxGroupId
			LEFT OUTER JOIN ReturnHeader RH (NOLOCK) ON RH.SalId=SI.SalId AND RH.ReturnType=1 AND RH.Status=0
		WHERE SI.DlvSts IN (4,5) 
			AND (SI.SMId = (CASE @SmId WHEN 0 THEN SI.SMId ELSE 0 END) OR
				SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (SI.RMId = (CASE @RmId WHEN 0 THEN SI.RMId ELSE 0 END) OR
				SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
				SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND (SalInvNo = (CASE @TransNo WHEN '0' THEN SalInvNo ELSE '' END) OR
				SalInvNo in (SELECT SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId)))  
			AND SI.SalInvDate  BETWEEN @FromDate and @ToDate 
	UNION ALL
		SELECT 
			90000+RP.ReturnId,NULL,NULL,R.CmpRtrCode,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,TG.TaxGroupName,
			(CASE  R.RtrTaxable WHEN 1 THEN 'YES' ELSE 'NO' END) AS RtrTaxable ,
			R.RtrTINNo,0.00,0.00,0.00,0.00,0.00,0.00,0.00,ISNULL(RP.ReturnCode,'') AS ReturnCode,
			(-1) * ISNULL(RP.PrdGrossAmt,0) AS RtnGrossAmt,(-1) * ISNULL(RP.PrdSplDisAmt,0) AS RtnSplDisAmt,
			(-1) * ISNULL(RP.PrdSchDisAmt,0) AS RtnSchDisAmt,(-1) * ISNULL(RP.PrdDBDisAmt,0) AS RtnDBDisAmt,
			(-1) * ISNULL(RP.PrdCDDisAmt,0) AS RtnCashDisAmt,(-1) * ISNULL(RP.PrdTaxAmt,0) AS RtnTaxAmt,0.00,0.00,0.00,0.00,0.00,(-1) * ISNULL(RP.RtnNetAmt,0),  --- 0.00,  Commented by panneer and added  RtnNetAmt
			0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00		
		FROM Retailer R (NOLOCK)
		LEFT OUTER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=R.TaxGroupId
		INNER JOIN (SELECT
						B.returnid,B.ReturnCode,B.ReturnDate,B.SmId,B.RtrId,B.RmId,B.ReturnType,
						B.Status,ISNULL(SUM(PrdGrossAmt),0) As PrdGrossAmt,
						ISNULL(SUM(PrdSplDisAmt),0) As PrdSplDisAmt,ISNULL(SUM(PrdSchDisAmt),0) As PrdSchDisAmt,
						ISNULL(SUM(PrdDBDisAmt),0) As PrdDBDisAmt,
						ISNULL(SUM(PrdCDDisAmt),0) As PrdCDDisAmt,ISNULL(SUM(PrdTaxAmt),0) As PrdTaxAmt ,
						ISNULL(SUM(PrdNetAmt),0) RtnNetAmt
					FROM 
						ReturnProduct A (NOLOCK) 
						INNER JOIN ReturnHeader B ON A.ReturnId=B.ReturnId 
					WHERE 
						ReturnType =2 AND B.Status=0 
						AND B.ReturnDate BETWEEN @FromDate and @ToDate 

						AND (B.SMId = (CASE @SmId WHEN 0 THEN B.SMId ELSE 0 END) OR
							B.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))

						AND (B.RMId = (CASE @RmId WHEN 0 THEN B.RMId ELSE 0 END) OR
							B.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))

						AND (B.RtrId = (CASE @RtrId WHEN 0 THEN B.RtrId ELSE 0 END) OR
								B.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))

					GROUP BY B.returnid,B.ReturnCode,B.ReturnDate,B.SmId,B.RtrId,B.RmId,B.ReturnType,B.Status) RP ON R.RtrId=RP.RtrId
		WHERE 
			 (RP.SMId = (CASE @SmId WHEN 0 THEN RP.SMId ELSE 0 END) OR
					RP.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))

			AND (RP.RMId = (CASE @RmId WHEN 0 THEN RP.RMId ELSE 0 END) OR
				RP.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))

			AND (RP.RtrId = (CASE @RtrId WHEN 0 THEN RP.RtrId ELSE 0 END) OR
					RP.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))

		AND RP.ReturnDate  BETWEEN @FromDate and @ToDate AND RP.ReturnType =2 AND RP.Status=0 

		Update RPTBillDetailsRtrLevelTaxSummary Set [Invoice Net Amount] = (-1) * RtnNetAmt 
		from RPTBillDetailsRtrLevelTaxSummary a, ReturnHeader
		Where [Market Return Ref Number] = ReturnCode and ReturnType =2 AND  Status=0 

		UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Other Charges (Add)]=Other.AddAmt,[Other Charges (Reduce)]=Other.ReduceAmt
		FROM RPTBillDetailsRtrLevelTaxSummary,
		(SELECT SI.SalId,SO1.AdjAmt AS AddAmt,SO2.AdjAmt  AS ReduceAmt
			FROM  SalesInvoice SI 
			INNER JOIN  SalInvOtherAdj SO1 (NOLOCK) ON SI.SalId=SO1.SalId
			INNER JOIN PurSalAccConfig PS1 (NOLOCK) ON PS1.AccDescId=SO1.AccDescId AND PS1.Effect=1 AND PS1.TransactionId=2 
			INNER JOIN SalInvOtherAdj SO2 (NOLOCK) ON SI.SalId=SO2.SalId
			INNER JOIN PurSalAccConfig PS2 (NOLOCK) ON PS2.AccDescId=SO2.AccDescId AND PS2.TransactionId=2 AND PS2.Effect=0
		) Other  WHERE Other.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id]

		DELETE FROM @SalTaxAmt
		INSERT INTO @SalTaxAmt (SalId,TaxId,SalTaxPerc,SalTaxableAmount,SalTaxAmount)
		SELECT  SI.SalId,SPT.TaxPerc,SPT.TaxPerc AS SalTaxPerc,SUM(SPT.TaxableAmount) AS SalTaxableAmount,SUM(SPT.TaxAmount) AS SalTaxAmount
		 FROM SalesInvoice SI WITH (NOLOCK)  
		 INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
		 INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo  
		 WHERE SI.DlvSts IN (4,5)  AND SI.SalInvDate BETWEEN @FromDate and @ToDate
		 GROUP BY SPT.TaxPerc,SPT.TaxPerc,SI.SalId
		 HAVING SUM(SPT.TaxableAmount) >= 0  
		DELETE FROM @RtnTaxAmt

		INSERT INTO @RtnTaxAmt (SalId,TaxId,RtnTaxPerc,RtnTaxableAmount,RtnTaxAmount)
		SELECT  SI.SalId,RPT.TaxPerc,RPT.TaxPerc AS RtnTaxPerc, SUM(RPT.TaxableAmt) AS RtnTaxableAmount, SUM(RPT.TaxAmt) AS RtnTaxAmount
		FROM SalesInvoice SI WITH (NOLOCK)  
		INNER JOIN ReturnHeader RH WITH (NOLOCK) ON SI.SalId = RH.SalId  
		INNER JOIN ReturnProduct RIP WITH (NOLOCK) ON RH.ReturnId = RIP.ReturnId  
		INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RIP.ReturnId AND RIP.SlNo=RPT.PrdSlNo  
		WHERE SI.DlvSts IN (4,5) AND SI.SalInvDate BETWEEN @FromDate and @ToDate
		AND RH.Status=0 AND RH.ReturnType in (1)
		GROUP BY RPT.TaxPerc,RPT.TaxPerc,SI.SalId HAVING SUM(RPT.TaxableAmt) >= 0 
		UNION ALL
		SELECT  (90000+RH.ReturnId) ,RPT.TaxPerc,RPT.TaxPerc AS RtnTaxPerc,  SUM(RPT.TaxableAmt) AS RtnTaxableAmount, SUM(RPT.TaxAmt) AS RtnTaxAmount
		FROM ReturnHeader RH WITH (NOLOCK)  INNER JOIN ReturnProduct RIP WITH (NOLOCK) ON RH.ReturnId = RIP.ReturnId  
		INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RIP.ReturnId AND RIP.SlNo=RPT.PrdSlNo  
		WHERE   RH.ReturnDate BETWEEN @FromDate and @ToDate
		AND RH.Status=0 AND RH.ReturnType =2
		GROUP BY RH.ReturnId,RPT.TaxPerc,RPT.TaxPerc
		HAVING SUM(RPT.TaxableAmt) >= 0

		INSERT INTO @TaxPerName (TaxId,TaxName)
		SELECT DISTINCT TOP 8 TaxPerc,TaxPerc FROM SalesInvoiceProductTax SIPT INNER JOIN SalesInvoice SI ON SI.SalId = SIPT.SalId  
		WHERE SI.SalInvDate BETWEEN @FromDate and @ToDate ORDER BY TaxPerc DESC

		SET @Count=0
		DECLARE Cur_TaxName CURSOR
		FOR SELECT TaxId,TaxName  FROM @TaxPerName ORDER BY TaxId DESC
		OPEN Cur_TaxName
		FETCH NEXT FROM Cur_TaxName INTO @TaxId,@TaxName 
		WHILE @@FETCH_STATUS=0
		BEGIN
				SET @Count=@Count+1
				IF @Count=1
				BEGIN
					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Taxable Amount1]=A.SalTaxableAmount,[Tax Amount1]=A.SalTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@SalTaxAmt A  
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

					UPDATE RPTBillDetailsRtrLevelTaxSummary 
					SET [Market Return - Taxable Amount1] = (-1) * A.RtnTaxableAmount,
						[Market Return - Tax Amount1] = (-1) * A.RtnTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@RtnTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId
				END 
				IF @Count=2
				BEGIN
					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Taxable Amount2]=A.SalTaxableAmount,[Tax Amount2]=A.SalTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@SalTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Market Return - Taxable Amount2]= (-1) * A.RtnTaxableAmount,
						[Market Return - Tax Amount2] = (-1) * A.RtnTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@RtnTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId
				END 
				IF @Count=3
				BEGIN
					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Taxable Amount3]=A.SalTaxableAmount,[Tax Amount3]=A.SalTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@SalTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Market Return - Taxable Amount3]= (-1) * A.RtnTaxableAmount,
						[Market Return - Tax Amount3] = (-1) * A.RtnTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@RtnTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

				END 
				IF @Count=4
				BEGIN
					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Taxable Amount4]=A.SalTaxableAmount,[Tax Amount4]=A.SalTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@SalTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Market Return - Taxable Amount4]= (-1) * A.RtnTaxableAmount,
						[Market Return - Tax Amount4]= (-1) * A.RtnTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@RtnTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId
				END 
				IF @Count=5
				BEGIN
					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Taxable Amount5]=A.SalTaxableAmount,[Tax Amount5]=A.SalTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@SalTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Market Return - Taxable Amount5]= (-1) * A.RtnTaxableAmount,
						[Market Return - Tax Amount5]= (-1) * A.RtnTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@RtnTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId
				END 
				IF @Count=6
				BEGIN
					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Taxable Amount6]=A.SalTaxableAmount,[Tax Amount6]=A.SalTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@SalTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Market Return - Taxable Amount6]= (-1) * A.RtnTaxableAmount,
						[Market Return - Tax Amount6]= (-1) * A.RtnTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@RtnTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId
				END 
				IF @Count=7
				BEGIN
					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Taxable Amount7]=A.SalTaxableAmount,[Tax Amount7]=A.SalTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@SalTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Market Return - Taxable Amount7]= (-1) * A.RtnTaxableAmount,
						[Market Return - Tax Amount7] = (-1) * A.RtnTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@RtnTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

				END 
				IF @Count=8
				BEGIN
					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Taxable Amount8]=A.SalTaxableAmount,[Tax Amount8]=A.SalTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@SalTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId

					UPDATE RPTBillDetailsRtrLevelTaxSummary SET [Market Return - Taxable Amount8] = (-1) * A.RtnTaxableAmount,
						[Market Return - Tax Amount8] = (-1) * A.RtnTaxAmount
					FROM RPTBillDetailsRtrLevelTaxSummary,@RtnTaxAmt A 
					WHERE A.SalId=RPTBillDetailsRtrLevelTaxSummary.[Bill Id] AND A.TaxId=@TaxId
				END 

			SET @SSQL='sp_rename ''RPTBillDetailsRtrLevelTaxSummary.[Taxable Amount'+ CAST(@Count AS NVARCHAR(10))+']'',''Taxable Amount '+ CAST(@TaxName AS NVARCHAR(5)) +'%'''+',''COLUMN'''
			EXEC (@SSQL)
			SET @SSQL='sp_rename ''RPTBillDetailsRtrLevelTaxSummary.[Tax Amount'+ CAST(@Count AS NVARCHAR(10))+']'',''Tax Amount '+ CAST(@TaxName AS NVARCHAR(5)) +'%'''+',''COLUMN'''
			EXEC (@SSQL)
			SET @SSQL='sp_rename ''RPTBillDetailsRtrLevelTaxSummary.[Market Return - Taxable Amount'+ CAST(@Count AS NVARCHAR(10))+']'',''Market Return - Taxable Amount '+ CAST(@TaxName AS NVARCHAR(5)) +'%'''+',''COLUMN'''
			EXEC (@SSQL)
			SET @SSQL='sp_rename ''RPTBillDetailsRtrLevelTaxSummary.[Market Return - Tax Amount'+ CAST(@Count AS NVARCHAR(10))+']'',''Market Return - Tax Amount '+ CAST(@TaxName AS NVARCHAR(5)) +'%'''+',''COLUMN'''
			EXEC (@SSQL)
		FETCH NEXT FROM Cur_TaxName INTO @TaxId,@TaxName
		END
		CLOSE Cur_TaxName
		DEALLOCATE Cur_TaxName

		if exists (Select Id,name from Syscolumns where name = 'Retailer Company Code' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
		BEGIN
			ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Retailer Company Code]
		END
		if exists (Select Id,name from Syscolumns where name = 'Retailer Address 3' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
		BEGIN
			ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Retailer Address 3]
		END
		if exists (Select Id,name from Syscolumns where name = 'Retailer Tax Group' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
		BEGIN
			ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Retailer Tax Group]
		END
		if exists (Select Id,name from Syscolumns where name = 'Taxable Status' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
		BEGIN
			ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Status]
		END		
		IF @Count=1
		BEGIN
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount2' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount2]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount2' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount2]
			END
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount2' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount2]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount2' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount2]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount3' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
					ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount3]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount3' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount3]
			END
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount3' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount3]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount3' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount3]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount4]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount4' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount4]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount4]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount4]
			END
			--- Added on 09-Nov-2010 as per client request
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount5]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount5' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount5]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount5]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount5]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount6' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount7' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount8]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount8' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount8]
			END
			--- Ended on 09-Nov-2010 as per client request	
		END 
		ELSE IF @Count=2
		BEGIN
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount3' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
					ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount3]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount3' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount3]
			END
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount3' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount3]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount3' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount3]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount4]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount4' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount4]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount4]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount4]
			END
			
			--- Added on 09-Nov-2010 as per client request
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount5]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount5' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount5]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount5]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount5]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount6' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount7' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount8]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount8' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount8]
			END
			--- Ended on 09-Nov-2010 as per client request	
		END 
		ELSE IF @Count=3
		BEGIN
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount4]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount4' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount4]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount4]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount4' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount4]
			END
		
			--- Added on 09-Nov-2010 as per client request
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount5]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount5' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount5]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount5]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount5]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount6' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount7' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount8]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount8' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount8]
			END
			--- Ended on 09-Nov-2010 as per client request	
		END 
		
		ELSE IF @Count=4
		BEGIN
			--- Added on 09-Nov-2010 as per client request
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount5]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount5' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount5]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount5]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount5' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount5]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount6' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount7' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount8]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount8' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount8]
			END
			--- Ended on 09-Nov-2010 as per client request	
		END 
		ELSE IF @Count=5
		BEGIN
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount6' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount6]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount6' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount6]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount7' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount8]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount8' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount8]
			END
			--- Ended on 09-Nov-2010 as per client request	
		END 
		ELSE IF @Count=6
		BEGIN
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount7' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount7]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount7' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount7]
			END
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount8]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount8' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount8]
			END
			--- Ended on 09-Nov-2010 as per client request	
		END 
		ELSE IF @Count=7
		BEGIN
			if exists (Select Id,name from Syscolumns where name = 'Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Taxable Amount8]
			END
			if exists (Select Id,name from Syscolumns where name = 'Tax Amount8' and id in (Select id from 
				Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Tax Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Taxable Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Taxable Amount8]
			END 
			if exists (Select Id,name from Syscolumns where name = 'Market Return - Tax Amount8' and id in (Select id from 
			Sysobjects where name ='RPTBillDetailsRtrLevelTaxSummary'))
			BEGIN
				ALTER TABLE RPTBillDetailsRtrLevelTaxSummary DROP COLUMN [Market Return - Tax Amount8]
			END
			--- Ended on 09-Nov-2010 as per client request	
		END 
 
			UPDATE A SET A.[Retailer Address 1] = SMName,A.[Retailer Address 2] = RMName 
			FROM RPTBillDetailsRtrLevelTaxSummary A,SalesInvoice SI (nolock),  Salesman S (nolock) ,
				 RouteMaster R (nolock)
			WHere A.[Bill Id] = SI.SalId and SI.SmId = S.SMId and SI.RMId  = R.RmId and [Bill Number] is not null
 

			UPDATE A SET A.[Retailer Address 1] = SMName,A.[Retailer Address 2] = RMName 
			FROM RPTBillDetailsRtrLevelTaxSummary A,ReturnHeader SI (nolock),  Salesman S (nolock) ,
				 RouteMaster R (nolock)
			WHere A.[Market Return Ref Number] = SI.ReturnCode and SI.SmId = S.SMId and SI.RMId  = R.RmId and [Bill Number] is null
		 
   			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM RPTBillDetailsRtrLevelTaxSummary
			IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='RPTBillDetailsRtrLevelTaxSummary_Excel')
				BEGIN 
					DROP TABLE RPTBillDetailsRtrLevelTaxSummary_Excel
					SELECT * INTO RPTBillDetailsRtrLevelTaxSummary_Excel FROM RPTBillDetailsRtrLevelTaxSummary 
				END 
			ELSE
				BEGIN 
					SELECT * INTO RPTBillDetailsRtrLevelTaxSummary_Excel FROM RPTBillDetailsRtrLevelTaxSummary 
				END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM RPTBillDetailsRtrLevelTaxSummary_Excel
	
		DELETE FROM RptExcelHeaders WHERE RptId=224
		DECLARE @iCnt AS INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		SET @iCnt=1
		SET @Pi_RptId=224
		DECLARE Column_Cur CURSOR FOR
		SELECT name FROM dbo.sysColumns where id = object_id(N'[RPTBillDetailsRtrLevelTaxSummary]') ORDER BY ColID
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
				
					EXEC (@C_SSQL)
				SET @iCnt=@iCnt+1
					FETCH NEXT FROM Column_Cur INTO @Column
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE RptId=224 AND SlNo=1
        UPDATE RptExcelHeaders SET DisplayName='Sales Man' WHERE RptId=224 AND SlNo=6
		UPDATE RptExcelHeaders SET DisplayName='Route' WHERE RptId=224 AND SlNo=7
		DECLARE @SsqlStr as Varchar(4000)
		SET @SsqlStr=''
		SELECT @SsqlStr=@SsqlStr+'SUM(['+Name+']),' FROM dbo.sysColumns where id = object_id(N'[RPTBillDetailsRtrLevelTaxSummary_Excel]') and Name NOT IN(
		Select TOP 8 Name FROM dbo.sysColumns where id = object_id(N'[RPTBillDetailsRtrLevelTaxSummary_Excel]') ORDER BY ColID) --AND NAME <>'[Market Return Ref Number]'
		SELECT @SsqlStr =substring( @SsqlStr,1,len(@SsqlStr)-1)    
        

		SET @SsqlStr=REPLACE(@SsqlStr,'SUM([Market Return Ref Number])','[Market Return Ref Number]')


		DECLARE @SsqlFieldStr as Varchar(4000)
        SET @SsqlFieldStr=''
        SELECT @SsqlFieldStr=@SsqlFieldStr+'['+Name+'],' FROM dbo.sysColumns where id = object_id(N'[RPTBillDetailsRtrLevelTaxSummary_Excel]') and Name NOT IN(
		Select TOP 8 Name FROM dbo.sysColumns where id = object_id(N'[RPTBillDetailsRtrLevelTaxSummary_Excel]') ORDER BY ColID) --AND NAME<>'[Market Return Ref Number]'
        SELECT @SsqlFieldStr =substring( @SsqlFieldStr,1,len(@SsqlFieldStr)-1)

		SET @SsqlFieldStr=REPLACE(@SsqlFieldStr,'SUM([Market Return Ref Number])','[Market Return Ref Number]')


		IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TmpRPTBillDetailsRtrLevelTaxSummary_Excel')
			BEGIN 
				DROP TABLE TmpRPTBillDetailsRtrLevelTaxSummary_Excel
				SELECT * INTO TmpRPTBillDetailsRtrLevelTaxSummary_Excel FROM RPTBillDetailsRtrLevelTaxSummary_Excel WHERE 1=2
			END 
		ELSE
			BEGIN 
				SELECT * INTO TmpRPTBillDetailsRtrLevelTaxSummary_Excel FROM RPTBillDetailsRtrLevelTaxSummary_Excel WHERE 1=2
			END 

		SET @SsqlStr=REPLACE(@SsqlStr,'[Market Return Ref Number]','0')

		 SET @sSql='INSERT INTO TmpRPTBillDetailsRtrLevelTaxSummary_Excel ([Bill Id],[TIN Number],' + @SsqlFieldStr + ')
			SELECT 999999,''Total'',' + @SsqlStr + ' FROM RPTBillDetailsRtrLevelTaxSummary_Excel'
        PRINT @sSql
        EXEC (@sSql)
        
		UPDATE TmpRPTBillDetailsRtrLevelTaxSummary_Excel SET [Market Return Ref Number] ='' WHERE [TIN Number]='Total'

		SET @sSql='INSERT INTO RPTBillDetailsRtrLevelTaxSummary_Excel ([Bill Id],[TIN Number],' + @SsqlFieldStr + ')
			SELECT 999999,''Total'',' + @SsqlFieldStr + ' FROM TmpRPTBillDetailsRtrLevelTaxSummary_Excel'
       
        EXEC (@sSql)
	
		SELECT * FROM RPTBillDetailsRtrLevelTaxSummary_Excel ORDER BY [Bill Id]
		IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='RPTBillDetailsRtrLevelTaxSummary')
	BEGIN
		DROP TABLE RPTBillDetailsRtrLevelTaxSummary	
	END
	CREATE TABLE [RPTBillDetailsRtrLevelTaxSummary](
		[Bill Id]				BIGINT,
	[Bill Number]			NVARCHAR(50),
	[Bill Date]				DATETIME,	
	[Retailer Company Code]	  NVARCHAR(50),
	[Retailer Code (Dist)]	  NVARCHAR(50),
	[Retailer Name]			NVARCHAR(150),
	[Retailer Address 1]	 NVARCHAR(200),
	[Retailer Address 2]	 NVARCHAR(200),
	[Retailer Address 3]	 NVARCHAR(200),
	[Retailer Tax Group]	 NVARCHAR(100),	
	[Taxable Status]		 NVARCHAR(5),
	[TIN Number]			 NVARCHAR(50),
	[Gross Amount]			 NUMERIC(38,6),
	[Special Discount]		 NUMERIC(38,6),
	[Scheme Discount]		 NUMERIC(38,6),
	[Distributor Discount]	 NUMERIC(38,6),
	[Cash Discount]			 NUMERIC(38,6),
	[Taxable Amount1]		NUMERIC(38,6),
	[Taxable Amount2]		NUMERIC(38,6),
	[Taxable Amount3]		NUMERIC(38,6),
	[Taxable Amount4]		NUMERIC(38,6),
	[Taxable Amount5]		NUMERIC(38,6),
	[Taxable Amount6]		NUMERIC(38,6),
	[Taxable Amount7]		NUMERIC(38,6),
	[Taxable Amount8]		NUMERIC(38,6),
	[Tax Amount1]			NUMERIC(38,6),	 
	[Tax Amount2]			NUMERIC(38,6),	
	[Tax Amount3]			NUMERIC(38,6),	
	[Tax Amount4]			NUMERIC(38,6),	
	[Tax Amount5]			NUMERIC(38,6),	
	[Tax Amount6]			NUMERIC(38,6),	
	[Tax Amount7]			NUMERIC(38,6),	
	[Tax Amount8]			NUMERIC(38,6),	
	[Total Tax]				NUMERIC(38,6),	
	[Display Amount]		NUMERIC(38,6),	
	[Market Return Ref Number]	NVARCHAR(50),	
	[Market Return - Gross Amount]	NUMERIC(38,6),
	[Market Return - Special Discount]	NUMERIC(38,6),
	[Market Return - Scheme Discount]	NUMERIC(38,6),
	[Market Return - Distributor Discount]	NUMERIC(38,6),
	[Market Return - Cash Discount]	NUMERIC(38,6),
	[Market Return - Taxable Amount1]NUMERIC(38,6),	
	[Market Return - Taxable Amount2]	NUMERIC(38,6),
	[Market Return - Taxable Amount3]	NUMERIC(38,6),
	[Market Return - Taxable Amount4]	NUMERIC(38,6),
	[Market Return - Taxable Amount5]	NUMERIC(38,6),
	[Market Return - Taxable Amount6]	NUMERIC(38,6),
	[Market Return - Taxable Amount7]	NUMERIC(38,6),
	[Market Return - Taxable Amount8]	NUMERIC(38,6),
	[Market Return - Tax Amount1]	NUMERIC(38,6),
	[Market Return - Tax Amount2]	NUMERIC(38,6),
	[Market Return - Tax Amount3]	NUMERIC(38,6),
	[Market Return - Tax Amount4]	NUMERIC(38,6),
	[Market Return - Tax Amount5]	NUMERIC(38,6),
	[Market Return - Tax Amount6]	NUMERIC(38,6),
	[Market Return - Tax Amount7]	NUMERIC(38,6),
	[Market Return - Tax Amount8]	NUMERIC(38,6),
	[Market Return - Total Tax]		NUMERIC(38,6),
	[Credit Note Adjustment]		NUMERIC(38,6),
	[Debit Note Adjustment]			NUMERIC(38,6),
	[On Account Adjustment]			NUMERIC(38,6),
	[Other Charges (Add)]			NUMERIC(38,6),
	[Other Charges (Reduce)]		NUMERIC(38,6),
	[Invoice Net Amount]			NUMERIC(38,6)
	)
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='Cs2Cn_Prk_SchemeUtilization_Archive')
DROP TABLE Cs2Cn_Prk_SchemeUtilization_Archive
GO
CREATE TABLE [Cs2Cn_Prk_SchemeUtilization_Archive](
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [nvarchar](50) NOT NULL,
	[SchemeCode] [nvarchar](50) NOT NULL,
	[SchemeDescription] [nvarchar](200) NOT NULL,
	[InvoiceNo] [nvarchar](50) NOT NULL,
	[RtrCode] [nvarchar](50) NOT NULL,
	[Company] [nvarchar](100) NOT NULL,
	[SchDate] [datetime] NULL,
	[SchemeType] [nvarchar](50) NOT NULL,
	[SchemeUtilizedAmt] [numeric](18, 2) NULL,
	[SchemeFreeProduct] [nvarchar](50) NOT NULL,
	[SchemeUtilizedQty] [int] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[CompanySchemeCode] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[SchemeMode] nvarchar (50),
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO
if not exists (Select Id,name from Syscolumns where name = 'SchemeMode' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_SchemeUtilization'))
begin
	ALTER TABLE [dbo].[Cs2Cn_Prk_SchemeUtilization]
	ADD [SchemeMode] nvarchar (50)
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_Cs2Cn_SchemeUtilization')
DROP PROCEDURE  Proc_Cs2Cn_SchemeUtilization
GO
--SELECT * FROM DayEndProcess Where procId = 4
--EXEC Proc_Cs2Cn_SchemeUtilization 0
--SELECT * FROM  Cs2Cn_Prk_SchemeUtilization
Create PROCEDURE [Proc_Cs2Cn_SchemeUtilization]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_Cs2Cn_SchemeUtilization
* PURPOSE: Extract Scheme Utilization Details from CoreStocky to Console
* NOTES:
* CREATED: Thrinath Kola 16-12-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @ChkSRDate	AS DATETIME

	SET @Po_ErrNo=0

	DELETE FROM Cs2Cn_Prk_SchemeUtilization WHERE UploadFlag = 'Y'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 1
	SELECT @ChkSRDate = NextUpDate FROM DayEndProcess Where ProcId = 4

	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END,
		(ISNULL(SUM(FlatAmount),0) + ISNULL(SUM(DiscountPerAmount),0)) As Utilized,
		'' as SchemeFreeProduct ,
		0 as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceSchemeLineWise A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,CM.CmpCode,B.SalInvNo,R.CmpRtrCode,B.SalInvDate ,SM.SchType,SM.CmpSchCode,SM.Download

	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0) As Utilized ,
		P.PrdCCode as SchemeFreeProduct,
		SUM(FreeQty) as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Product P ON A.FreePrdId = P.PrdId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,B.SalInvNo,R.CmpRtrCode,CM.CmpCode,B.SalInvDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,SM.Download
	
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType 	WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0) As Utilized ,
		P.PrdCCode as SchemeFreeProduct,
		SUM(GiftQty) as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Product P ON A.GiftPrdId = P.PrdId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,B.SalInvNo,R.CmpRtrCode,CM.CmpCode,B.SalInvDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,SM.Download
	
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(AdjAmt),0) As Utilized,
		'' as SchemeFreeProduct ,
		0 as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceWindowDisplay A
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,B.SalInvNo,R.CmpRtrCode,CM.CmpCode ,B.SalInvDate ,SM.SchType,SM.CmpSchCode,SM.Download
	

	--->Added By Nanda on 06/04/2010 For QPS Scheme-Credit Note Conversion
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(A.CrNoteAmount),0) As Utilized ,
		'' AS SchemeFreeProduct,
		0 AS SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceQPSSchemeAdj A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId AND Mode=1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY SM.SchCode,SM.SchDsc,B.SalInvNo,R.CmpRtrCode,CM.CmpCode,B.SalInvDate,SM.SchType,SM.CmpSchCode,SM.Download

	UNION ALL

	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		'AutoQPSConversion' AS SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		A.LastModDate,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(A.CrNoteAmount),0) As Utilized ,
		'' AS SchemeFreeProduct,
		0 AS SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121) ,
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceQPSSchemeAdj A 
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId AND Mode=2
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Retailer R ON R.RtrId = A.RtrId
		WHERE CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY SM.SchCode,SM.SchDsc,R.CmpRtrCode,CM.CmpCode,A.LastModDate,SM.SchType,SM.CmpSchCode,SM.Download
	--->Till Here

	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.ChqDisRefNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		A.ChqDisDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(Amount),0) As Utilized ,
		'' as SchemeFreeProduct ,
		0 as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM ChequeDisbursalMaster A
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo
		INNER JOIN SchemeMaster SM ON A.TransId = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE TransType = 1 AND CM.CmpID = @CmpID AND A.SchemeUpLoad=0--A.ChqDisDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,B.ChqDisRefNo,R.CmpRtrCode,CM.CmpCode ,A.ChqDisDate ,SM.SchType,SM.CmpSchCode,SM.Download

	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.ReturnCode,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.ReturnDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END,
		-1 * (ISNULL(SUM(ReturnFlatAmount),0) + ISNULL(SUM(ReturnDiscountPerAmount),0)),
		'' as SchemeFreeProduct ,
		0 as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM ReturnSchemeLineDt A 
		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.ReturnDate >= @ChkSRDate
	GROUP BY SM.SchCode,SM.SchDsc,B.ReturnCode,R.CmpRtrCode,CM.CmpCode ,B.ReturnDate ,SM.SchType,SM.CmpSchCode,SM.Download
	
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.ReturnCode,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.ReturnDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END,
		-1 * ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0),
		P.PrdCCode as SchemeFreeProduct ,
		-1 * SUM(ReturnFreeQty) as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode ,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 	
		FROM ReturnSchemeFreePrdDt A 
		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Product P ON A.FreePrdId = P.PrdId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.ReturnDate >= @ChkSRDate
	GROUP BY SM.SchCode,SM.SchDsc,B.ReturnCode,R.CmpRtrCode,CM.CmpCode ,B.ReturnDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,SM.Download
	
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.ReturnCode,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.ReturnDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END,
		ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0),
		P.PrdCCode as SchemeFreeProduct ,
		-1 * SUM(ReturnGiftQty) as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode ,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM ReturnSchemeFreePrdDt A 
		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Product P ON A.GiftPrdId = P.PrdId 
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.ReturnDate >= @ChkSRDate
	GROUP BY SM.SchCode,SM.SchDsc,B.ReturnCode,R.CmpRtrCode,CM.CmpCode ,B.ReturnDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,SM.Download

	SELECT SchId INTO #SchId FROM SchemeMaster WHERE SchCode IN (SELECT SchemeCode FROM Cs2Cn_Prk_SchemeUtilization
	WHERE UploadFlag='N')

	UPDATE SalesInvoice SET SchemeUpLoad=1 WHERE SalId IN (SELECT DISTINCT SalId FROM
	SalesInvoiceSchemeHd WHERE SchId IN (SELECT SchId FROM #SchId)) AND DlvSts IN (4,5)

	UPDATE SalesInvoice SET SchemeUpLoad=1 WHERE SalId IN (SELECT DISTINCT SalId FROM
	SalesInvoiceWindowDisplay WHERE SchId IN (SELECT SchId FROM #SchId)) AND DlvSts IN (4,5)
	
	UPDATE SalesInvoiceQPSSchemeAdj SET Upload=1
	WHERE SalId IN (SELECT SalId FROM SalesInvoice WHERE SchemeUpload=1) AND Mode=1

	UPDATE SalesInvoiceQPSSchemeAdj SET Upload=1
	WHERE SalId = -1000 AND Mode=2

	UPDATE ReturnHeader SET SchemeUpLoad=1 WHERE ReturnId IN (SELECT DISTINCT ReturnId FROM (
	SELECT ReturnId FROM ReturnSchemeFreePrdDt WHERE SchId IN (SELECT SchId FROM #SchId)
	UNION
	SELECT ReturnId FROM ReturnSchemeLineDt WHERE SchId IN (SELECT SchId FROM #SchId))A) AND Status=0

	UPDATE ChequeDisbursalMaster SET SchemeUpLoad=1 WHERE ChqDisRefNo IN (SELECT DISTINCT ChqDisRefNo FROM
	ChequeDisbursalDetails WHERE TransId IN (SELECT SchId AS TransId FROM #SchId))
	AND TransType = 1
END
GO
if EXISTS (select * from dbo.sysobjects where id = object_id(N'[TrigStockManagementProduct_Track]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
DROP TRIGGER [TrigStockManagementProduct_Track]
GO
CREATE TRIGGER [dbo].[TrigStockManagementProduct_Track]
ON [dbo].[StockManagementProduct]
AFTER INSERT
AS
BEGIN
	--StockAction 1 Add,2 Reduce
	INSERT INTO Unsaleable_In (TransId,RefId,TransCode,TransDate,Prdid,Prdbatid,StockTypeId,LcnId,InQty,StockAction,TolcnId,ToStockTypeId)
	Select 3 AS TransId,0 AS RefId,StockManagement.StkMngRefNo AS TransCode,StkMngDate AS TransDate,PrdId,PrdBatId,
	INSERTED.StockTypeId,StockManagement.LcnId,TotalQty,1,StockManagement.LcnId,INSERTED.StockTypeId From StockManagement With (NoLock) Inner Join
	INSERTED On StockManagement.StkMngRefNo=INSERTED.StkMngRefNo
	INNER JOIN StockType ST With (NoLock) ON ST.StockTypeId=INSERTED.StockTypeId
	WHERE ST.SystemStockType=2 AND StockManagement.Status=1 AND INSERTED.StkMgmtTypeId=1
END
GO
-- Added by Karthick.KJ on 11/08/2011 for CR Aug 0001
DELETE FROM BillTemplateHD WHERE PrintType=6
INSERT INTO BillTemplateHD (TempName,BillSeqId,BillSeqDt,MarketRet,Replacement,OtherCharges,CrDbAdj,TaxDt,LineNumber,UsrId,Scheme,PrintType,SampleIssue)
VALUES ('CRN Bill Template',1,getdate(),0,0,0,0,0,15,1,0,6,0)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='U' and Name='RptCRNToPrint')
DROP TABLE RptCRNToPrint
GO
CREATE TABLE [RptCRNToPrint](
	[CreditNoteNumber] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='U' and Name='RPTCRNBillPrint')
DROP TABLE RPTCRNBillPrint
GO 
CREATE TABLE RPTCRNBillPrint(
	[DistributorCode] varchar(100),
	[DistributorName] varchar(200),
	[DistributorAddress] varchar(500),
	[Rtrid]int,
	[RetailerCode] varchar(100),
	[RetailerName] varchar(300),
	[RetailerAddress1] varchar(200),
	[RetailerAddress2] varchar(200),
	[RetailerAddress3] varchar(200),
	[RetailerTinNo] nvarchar(100),
	[CreditNoteNumber] [nvarchar](100),
	[CreditNoteDate] datetime,
	[CreditNoteReasonId] int,
	[ReasonDescription] varchar(300),
	[CreditAmount] numeric(18,6),
	[CreditAdjAmount] numeric(18,6),
	[BalanceAmount] numeric(18,6),
	[TransactionId] int,
	[PostedFrom] varchar(100),
	[Remarks] varchar(500),
	[AmountInWord] varchar(1000),
	[UserId] [int] NULL
) ON [PRIMARY]
GO 
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='U' and Name='RptCRnTax')
DROP TABLE RptCRnTax
GO 
CREATE TABLE RptCRnTax
(
CrediteNoteNo nvarchar(100),
TaxId int,
TaxCode nvarchar(50),
TaxName nvarchar(50),
TaxPerc numeric(18,2),
TaxableAmount numeric(18,6),
TaxAmount numeric(18,6),
UsrId int
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_CRNTBillPrint')
DROP PROCEDURE Proc_CRNTBillPrint
GO 
-- Select * from CRNBillPrint
--EXEC Proc_CRNTBillPrint  1,2,1,'',0,0,0,''
CREATE Procedure [Proc_CRNTBillPrint]
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
/****************************************************************************************
* PROCEDURE	: Proc_CRNBillPrint
* PURPOSE	: General Procedure
* NOTES		:
* CREATED	:  
* MODIFIED
* DATE			AUTHOR		  DESCRIPTION
------------------------------------------------------------------------------------------
****************************************************************************************/
SET NOCOUNT ON
DECLARE @FromDate		DateTime
DECLARE @ToDate			DateTime
DECLARE @LcnId			INT
DECLARE @FromDistId		INT
DECLARE @ToDistId		INT
DECLARE @CRNRefNo nVarchar(100)
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT   TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
BEGIN
   
		
	DELETE FROM RPTCRNBillPrint  
	INSERT INTO RPTCRNBillPrint ( 
			DistributorCode,DistributorName,DistributorAddress,Rtrid,RetailerCode,RetailerName,RetailerAddress1,
			RetailerAddress2,RetailerAddress3,RetailerTinNo,CreditNoteNumber,CreditNoteDate,CreditNoteReasonId,
			ReasonDescription,CreditAmount,CreditAdjAmount,BalanceAmount,TransactionId,PostedFrom,Remarks,
			AmountInWord,UserId)
	SELECT DistributorCode,DistributorName,DistributorAdd1,R.RtrId,r.RtrCode,r.RtrName,r.RtrAdd1,r.RtrAdd2,
		   r.RtrAdd3,r.RtrTINNo,CR.CrNoteNumber,CR.CrNoteDate,CR.ReasonId,Rm.Description,CR.Amount,CR.CrAdjAmount,
		  (CR.Amount-CR.CrAdjAmount)Balance,CR.TransId,PostedFrom,Remarks,'',@Pi_UsrId
	FROM CreditNoteRetailer CR 
		INNER JOIN Retailer R ON R.RtrId = CR.RtrId 
		INNER JOIN ReasonMaster RM ON RM.ReasonId=CR.ReasonId
		INNER JOIN RptCRNToPrint RC ON RC.creditnotenumber=CR.CrNoteNumber AND RC.rtrid=CR.RtrId
		CROSS JOIN Distributor 
	WHERE RM.CrNoteRetailer=1

	DELETE FROM RptCRnTax
	INSERT INTO RptCRnTax 
		   (CrediteNoteNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
	SELECT CR.CrNoteNumber,CT.TaxId,TX.TaxCode,TX.TaxName,Ct.TaxPerc,CT.GrossAmt,CT.TaxAmt,@Pi_UsrId
	FROM CreditNoteRetailer CR 
		INNER JOIN CrDbNoteTaxBreakUp CT ON CT.RefNo=CR.CrNoteNumber AND CT.TransId=CR.TransId
		INNER JOIN TaxConfiguration TX ON TX.TaxId=CT.TaxId
		INNER JOIN RptCRNToPrint RC ON RC.creditnotenumber=CR.CrNoteNumber AND RC.rtrid=CR.RtrId 
				   AND RC.CreditNoteNumber=CT.RefNo	

END 
GO 
DELETE FROM BillTemplateHD WHERE PrintType=7
INSERT INTO BillTemplateHD (TempName,BillSeqId,BillSeqDt,MarketRet,Replacement,OtherCharges,CrDbAdj,TaxDt,LineNumber,UsrId,Scheme,PrintType,SampleIssue)
VALUES ('DBN Bill Template',1,getdate(),0,0,0,0,0,15,1,0,7,0)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='U' and Name='RptDBNToPrint')
DROP TABLE RptDBNToPrint
GO
CREATE TABLE [RptDBNToPrint](
	[DebitNoteNumber] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='U' and Name='RPTDBNBillPrint')
DROP TABLE RPTDBNBillPrint
GO 
CREATE TABLE [RPTDBNBillPrint](
	[RtrID] [int] ,
    [RtrCode] [nvarchar](100),
	[RtrName] [nvarchar](500),
    [RtrAdress1] [nvarchar](500),
    [RtrAdress2] [nvarchar](500), 
    [RtrTinNo] [nvarchar](100),
	[DebitNoteNumber] [nvarchar](100),
	[DebitNoteDate] [datetime] ,
	[ReasonId] [int],
	[ReasonDesc] [nvarchar](100),
	[DebitAmount] [numeric](38, 2),
    [DebitAdjAmount] [numeric](38, 2),
    [BalanceAmount] [numeric](38, 2),
    [TransID]  [int] ,
    [PostedFrom] [nvarchar](100),
    [Remarks] [nvarchar](500),
    [AmountInWord] [nvarchar](2500),
    [DistCode] [nvarchar](500),
    [DistName] [nvarchar](500),
    [DistAdd1] [nvarchar](500),
    [DistAdd2] [nvarchar](500),
    [AuthId] [Int],
	[UserId] [int] NULL
) ON [PRIMARY]
GO 
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='U' and Name='RptDBnTax')
DROP TABLE RptDBnTax
GO 
CREATE TABLE RptDBnTax
(
DebitNoteNo nvarchar(100),
TaxId int,
TaxCode nvarchar(50),
TaxName nvarchar(50),
TaxPerc numeric(18,2),
TaxableAmount numeric(18,6),
TaxAmount numeric(18,6),
UsrId int
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_DBNTBillPrint')
DROP PROCEDURE Proc_DBNTBillPrint
GO 
-- Select * from CRNBillPrint
--EXEC Proc_CRNTBillPrint  
CREATE Procedure [Proc_DBNTBillPrint]
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
/****************************************************************************************
* PROCEDURE	: Proc_DBNBillPrint
* PURPOSE	: General Procedure
* NOTES		:
* CREATED	:  
* MODIFIED
* DATE			AUTHOR		  DESCRIPTION
------------------------------------------------------------------------------------------
****************************************************************************************/
SET NOCOUNT ON
DECLARE @FromDate		DateTime
DECLARE @ToDate			DateTime
DECLARE @LcnId			INT
DECLARE @FromDistId		INT
DECLARE @ToDistId		INT
DECLARE @DBNNRefNo nVarchar(100)

SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT   TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
BEGIN
   
		DELETE FROM RPTDBNBillPrint --WHERE UserId=@Pi_UsrId    
		INSERT INTO RPTDBNBillPrint ([RtrID],[RtrCode],[RtrName],[RtrAdress1],[RtrAdress2],[RtrTinNo],
			[DebitNoteNumber],[DebitNoteDate],[ReasonId],[ReasonDesc],[DebitAmount],
			[DebitAdjAmount],[BalanceAmount],[TransID],[PostedFrom],[Remarks],[UserId],[AuthId])

        SELECT DISTINCT B.RtrId AS RtrId,B.RtrCode,B.RtrName AS RtrName,B.RtrAdd1,B.RtrAdd2,B.RtrTINNo,A.DbNoteNumber AS DebitNoteNumber,DbNoteDate AS DebitNoteDate,
		C.ReasonId AS ReasonId,C.Description AS ReasonDesc,
		dbo.Fn_ConvertCurrency(A.Amount,@Pi_CurrencyId) AS DebitAmount,
		dbo.Fn_ConvertCurrency(A.DbAdjAmount,@Pi_CurrencyId) AS debitAdjAmount,
		dbo.Fn_ConvertCurrency((A.Amount - DbAdjAmount),@Pi_CurrencyId) AS BalanceAmount,
		A.TransId,A.PostedFrom,A.Remarks,
		@Pi_UsrId AS UsrId,1
		FROM DebitNoteRetailer A
		INNER JOIN Retailer B On A.RtrId = B.RtrId
		INNER JOIN ReasonMaster C ON A.ReasonId = C.ReasonId
        INNER JOIN RptDBNToPrint D ON A.DbNoteNumber=D.DebitNoteNumber AND A.RtrId=D.RtrID
		--WHERE  CrNoteDate BETWEEN @FromDate AND @ToDate
		
		UPDATE R SET R.[DistCode]=DistributorCode,R.[DistName]=DistributorName,R.[DistAdd1] =DistributorAdd1,R.[DistAdd2]=DistributorAdd2 FROM RPTDBNBillPrint R LEFT OUTER JOIN Distributor D ON R.AuthId=D.AuthId

	DELETE FROM RptDBnTax
	INSERT INTO RptDBnTax 
		   (DebitNoteNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
	SELECT CR.DbNoteNumber,CT.TaxId,TX.TaxCode,TX.TaxName,Ct.TaxPerc,CT.GrossAmt,CT.TaxAmt,@Pi_UsrId
	FROM DebitNoteRetailer CR 
		INNER JOIN CrDbNoteTaxBreakUp CT ON CT.RefNo=CR.DbNoteNumber AND CT.TransId=CR.TransId
		INNER JOIN TaxConfiguration TX ON TX.TaxId=CT.TaxId
		INNER JOIN RptDBNToPrint RC ON RC.DebitNoteNumber=CR.DbNoteNumber AND RC.rtrid=CR.RtrId 
				   AND RC.DebitNoteNumber=CT.RefNo	

END 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ASRTemplate')
DROP PROCEDURE Proc_ASRTemplate
GO
--EXEC Proc_ASRTemplate 205,1
--SELECT * FROM TempASRJCWeekValue
CREATE      Proc [dbo].[Proc_ASRTemplate]
(
	@Pi_RptId INT,
	@Pi_UsrId INT
)
AS
/************************************************************
* VIEW	: Proc_ASRTemplate
* PURPOSE	: To get the Retailer Sales Details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 29/03/2010
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @FromDate AS DATETIME
	DECLARE @RtrId AS INT
	DECLARE @RMId AS INT
	DECLARE @SMId AS INT
	DECLARE @CmpId AS INT
	DECLARE @CtgLevelId AS INT
	DECLARE @CtgMainId AS INT
	DECLARE @RtrClassId AS INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @JcmId AS INT 
	DECLARE @SlNo AS INT 
	DECLARE @CurRtrId AS INT 
	DECLARE @CurRtrCode AS NVARCHAR(100) 
	DECLARE @CurRtrName AS NVARCHAR(200)
	DECLARE @JCWeek TABLE
	(
		SlNo INT IDENTITY (1, 1) ,
		JcwSdt DATETIME,
		JcwEdt DATETIME
	)
	DECLARE @JCWeekValue TABLE
	(
		SlNo INT ,
		PrdId INT,
		RtrId INT,
		SalesQty INT 
	)
	SET @FromDate =GETDATE()
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @CtgLevelId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @CtgMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @RtrClassId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))

	IF @PrdCatId=''
		SET @PrdCatId=0

	IF @RtrId=''
		SET @RtrId=0


	SELECT @JcmId=JcmId FROM JcWeek WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN JcwSdt AND JcwEdt
	INSERT INTO @JCWeek (JcwSdt,JcwEdt)
		SELECT JcwSdt,JcwEdt FROM JcWeek WHERE JcmId IN(
		SELECT JcmId FROM JCMast WHERE JcmYr IN (YEAR(GETDATE()),YEAR(GETDATE())-2,YEAR(GETDATE())-1))
			ORDER BY JcmId,JcmJc,JcwWk
	SELECT @SlNo=SlNo FROM @JCWeek WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN JcwSdt AND JcwEdt

	TRUNCATE TABLE  TempASRJCWeekValue 
	INSERT INTO TempASRJCWeekValue(RtrId,RtrCode,RtrName,PrdId,PrdCCode,PrdName,RptId,UsrId)
	SELECT RE.RtrId,RE.RtrCode,RE.RtrName,P.PrdId,P.PrdCCode,P.PrdName,@Pi_RptId,@Pi_UsrId
		  	FROM Product P ,Retailer RE WITH (NOLOCK) 
				INNER JOIN RetailerMarket REM (NOLOCK) ON REM.RtrId=RE.RtrId
				INNER JOIN RouteMaster RM WITH (NOLOCK) ON REM.RMId=RM.RMId
				INNER JOIN SalesmanMarket SEM WITH (NOLOCK) ON RM.RMId=SEM.RMId
				INNER JOIN Salesman SM WITH (NOLOCK) ON SEM.SMId=SM.SMId
				INNER JOIN RetailerValueClassMap RVCM ON RVCM.Rtrid=RE.RtrId
				INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId =RVC.RtrClassId 
				INNER JOIN RetailerCategory RC ON RC.CtgMainId=RVC.CtgMainId
				INNER JOIN RetailerCategoryLevel RCL ON RCL.CtgLevelId=RC.CtgLevelId 
		  	WHERE (SM.SMId = (CASE @SMId WHEN 0 THEN SM.SMId ELSE 0 END) OR
					SM.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (RM.RMId=(CASE @RMId WHEN 0 THEN RM.RMId ELSE 0 END) OR
						RM.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			AND	(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
					RCL.CtgLevelId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) 
			AND	(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
				RC.CtgMainId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) 
			AND (RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
				RVC.RtrClassId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) 
			AND (RCL.CmpId = (CASE @CmpId WHEN 0 THEN RCL.CmpId Else 0 END) OR
				RCL.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND RE.RtrStatus=1	
			AND	(P.PrdId = (CASE ISNULL(@PrdCatId,0) WHEN 0 THEN P.PrdId ELSE 0 END) OR
				P.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId ELSE 0 END) OR
				P.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND P.PrdStatus=1

		--Last 13 Weeks Updation
		UPDATE TempASRJCWeekValue SET TempASRJCWeekValue.SalesQty=ISNULL(B.SalesQty,0),
		TempASRJCWeekValue.SalesValue=ISNULL(B.SalesValue,0)
		FROM 
		(SELECT SIP.PrdId,SI.RtrId,SUM(SIP.BaseQty) SalesQty,SUM(SIP.PrdGrossAmount) SalesValue FROM @JCWeek A
		INNER JOIN SalesInvoice SI (NOLOCK) ON SI.SalInvDate BETWEEN A.JcwSdt AND A.JcwEdt 
			AND SI.RtrId IN (SELECT DISTINCT RtrId FROM TempASRJCWeekValue )
			AND SI.DlvSts IN (4,5)
		INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SIP.SalId=SI.SalId 
			AND	(SIP.PrdId = (CASE @PrdCatId WHEN 0 THEN SIP.PrdId ELSE 0 END) OR
				SIP.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND (SIP.PrdId = (CASE @PrdId WHEN 0 THEN SIP.PrdId ELSE 0 END) OR
				SIP.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		WHERE A.SlNo BETWEEN (@SlNo-14) AND (@SlNo-2)
		GROUP BY SIP.PrdId,SI.RtrId	) B WHERE TempASRJCWeekValue.RtrId=B.RtrId AND TempASRJCWeekValue.PrdId=B.PrdID


		
		--Last 14 Week Updation
		UPDATE TempASRJCWeekValue SET TempASRJCWeekValue.LstSalesQty=ISNULL(B.SalesQty,0),
			TempASRJCWeekValue.LstSalesValue=ISNULL(B.SalesValue,0)
		FROM 
		(SELECT SIP.PrdId,SI.RtrId,SUM(SIP.BaseQty) SalesQty,SUM(SIP.PrdGrossAmount) SalesValue FROM @JCWeek A
		INNER JOIN SalesInvoice SI (NOLOCK) ON SI.SalInvDate BETWEEN A.JcwSdt AND A.JcwEdt 
			AND SI.RtrId IN (SELECT DISTINCT RtrId FROM TempASRJCWeekValue )
			AND SI.DlvSts IN (4,5,1,2)
		INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SIP.SalId=SI.SalId 
			AND	(SIP.PrdId = (CASE @PrdCatId WHEN 0 THEN SIP.PrdId ELSE 0 END) OR
				SIP.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND (SIP.PrdId = (CASE @PrdId WHEN 0 THEN SIP.PrdId ELSE 0 END) OR
				SIP.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		WHERE A.SlNo =@SlNo-1
		GROUP BY SIP.PrdId,SI.RtrId	) B WHERE TempASRJCWeekValue.RtrId=B.RtrId AND TempASRJCWeekValue.PrdId=B.PrdID

		--No.Of Weeks Updation
		INSERT INTO @JCWeekValue(SlNo,RtrId,PrdId,SalesQty)
		SELECT A.SlNo,SI.RtrId,SIP.PrdId,SUM(SIP.BaseQty) SalesQty FROM @JCWeek A
		INNER JOIN SalesInvoice SI (NOLOCK) ON SI.SalInvDate BETWEEN A.JcwSdt AND A.JcwEdt 
			AND SI.RtrId IN (SELECT DISTINCT RtrId FROM TempASRJCWeekValue )
			AND SI.DlvSts IN (4,5)
		INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SIP.SalId=SI.SalId 
			AND	(SIP.PrdId = (CASE @PrdCatId WHEN 0 THEN SIP.PrdId ELSE 0 END) OR
				SIP.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND (SIP.PrdId = (CASE @PrdId WHEN 0 THEN SIP.PrdId ELSE 0 END) OR
				SIP.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		WHERE A.SlNo BETWEEN (@SlNo-14) AND (@SlNo-2)
		GROUP BY A.SlNo,SIP.PrdId,SI.RtrId
		UPDATE TempASRJCWeekValue SET AvgCount=A.AvgSlNo,AvgSalesQty=ROUND(SalesQty/A.AvgSlNo,2) 
				,AvgSalesValue=ROUND(SalesValue/A.AvgSlNo,2)
		FROM (
			SELECT ISNULL(COUNT(DISTINCT SlNo),0) AS AvgSlNo,PrdId,RtrId FROM @JCWeekValue  
			GROUP BY PrdId,RtrId,SalesQty HAVING SalesQty>0
		)A WHERE A.PrdId=TempASRJCWeekValue.PrdId AND  A.RtrId=TempASRJCWeekValue.RtrId AND TempASRJCWeekValue.SalesQty>0
		
		UPDATE TempASRJCWeekValue SET ActSalesQty=
			(CASE WHEN ISNULL(AvgSalesQty,0)<ISNULL(LstSalesQty,0) THEN (2*(ISNULL(AvgSalesQty,0))-ISNULL(LstSalesQty,0)) 
			 WHEN ISNULL(AvgSalesQty,0)>ISNULL(LstSalesQty,0) THEN (2*(ISNULL(AvgSalesQty,0))-ISNULL(LstSalesQty,0))
			 WHEN ISNULL(AvgSalesQty,0)=ISNULL(LstSalesQty,0) THEN  ISNULL(LstSalesQty,0)  ELSE 0 END) ,
			ActSalesValue=
			(CASE WHEN ISNULL(AvgSalesValue,0)<ISNULL(LstSalesValue,0) THEN (2*(ISNULL(AvgSalesValue,0))-ISNULL(LstSalesValue,0)) 
			 WHEN ISNULL(AvgSalesValue,0)>ISNULL(LstSalesValue,0) THEN (2*(ISNULL(AvgSalesValue,0))-ISNULL(LstSalesValue,0))
			 WHEN ISNULL(AvgSalesValue,0)=ISNULL(LstSalesValue,0) THEN  ISNULL(AvgSalesValue,0)  ELSE 0 END) 
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptASRTemplate')
DROP PROCEDURE Proc_RptASRTemplate
GO
--EXEC [Proc_RptASRTemplate] 205,1,0,'TEST',0,0,1
CREATE                 PROCEDURE [dbo].[Proc_RptASRTemplate]
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
* VIEW	: Proc_RptASRTemplate
* PURPOSE	: To get the Sales Details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 29/03/2010
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

	DECLARE @ExcelFlag AS INT
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate AS DATETIME
	DECLARE @RtrId AS INT
	DECLARE @RMId AS INT
	DECLARE @SMId AS INT
	DECLARE @CmpId AS INT
	DECLARE @CtgLevelId AS INT
	DECLARE @CtgMainId AS INT
	DECLARE @RtrClassId AS INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT

	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @CtgLevelId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @CtgMainId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @RtrClassId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	Create TABLE #RptASRTemplate
	(
		SlNo INT, 
		RtrId INT,
		RtrCode NVARCHAR(100),	
		RtrName NVARCHAR(200),	
		Description NVARCHAR(5)
	)

	SET @TblName = 'RptASRTemplate'

	SET @TblStruct = '	SlNo INT, 
		RtrId INT,
		RtrCode NVARCHAR(100),	
		RtrName NVARCHAR(200),	
		Description NVARCHAR(5)'

	SET @TblFields = 'SlNo,RtrId,RtrCode,RtrName'


	IF @Pi_GetFromSnap = 1 
	   BEGIN
		SELECT @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	   END
	ELSE
    BEGIN
		SELECT @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
		SET @DBNAME = @PI_DBNAME + @DBNAME
    END

	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	   BEGIN
		EXEC Proc_ASRTemplate @Pi_RptId,@Pi_UsrId

		INSERT INTO #RptASRTemplate (SlNo,RtrId,RtrCode,RtrName,Description)
				SELECT DISTINCT 1,RtrId,RtrCode,RtrName,'SO' FROM TempASRJCWeekValue
				UNION SELECT DISTINCT 2,RtrId,RtrCode,RtrName,'AO' FROM TempASRJCWeekValue
				WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
				
				
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptASRTemplate ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+ 'WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR ' 
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptASRTemplate'
		
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
			SET @SSQL = 'INSERT INTO #RptASRTemplate ' + 
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
	DELETE FROM RptDataCount WHERE  RptId = @Pi_RptId AND UserId = @Pi_UsrId

	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) AS RecCount,@ErrNo,@Pi_UsrId FROM #RptASRTemplate
	-- Till Here
--
--	SELECT * FROM #RptASRTemplate

	SELECT @ExcelFlag=Flag FROM RptExcelFlag WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId
	IF @ExcelFlag = 1 
	BEGIN
		/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @CRtrId AS INT 
		DECLARE  @CPrdId AS INT 
		DECLARE  @CSalesQty AS INT 
		DECLARE  @CPrdName VARCHAR(200)
		DECLARE  @Name VARCHAR(200)
		DECLARE  @Column1 VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT

		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptASRTemplate_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptASRTemplate_Excel]

		DELETE FROM RptExcelHeaders WHERE RptId=@Pi_RptId AND SlNo>7

		CREATE TABLE [RptASRTemplate_Excel] (RptId INT,UsrId INT,SlNo INT,RtrId INT,RtrCode VARCHAR(100),RtrName VARCHAR(200),Description NVARCHAR(5))

		SET @iCnt=8
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT PrdName FROM TempASRJCWeekValue
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column1
			   WHILE @@FETCH_STATUS = 0
				BEGIN

					SET @C_SSQL='ALTER TABLE [RptASRTemplate_Excel] ADD ['+ @Column1 +'] INT'
					EXEC (@C_SSQL)

					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(10))+ ',' + CAST(@iCnt AS VARCHAR(10))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column1 AS VARCHAR(200))+']'','''+ CAST(@Column1 AS VARCHAR(200))+''',1,1)'
					EXEC (@C_SSQL)
		
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column1
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur

		--Insert table values
		TRUNCATE TABLE [RptASRTemplate_Excel]
		INSERT INTO [RptASRTemplate_Excel] (RptId,UsrId,SlNo,RtrId,RtrCode,RtrName,Description)
		SELECT DISTINCT @Pi_RptId,@Pi_UsrId,SlNo,RtrId,RtrCode,RtrName,Description FROM #RptASRTemplate


		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT RtrId,PrdName,SUM(ActSalesQty) FROM TempASRJCWeekValue 
					GROUP BY RtrId,PrdName ORDER BY RtrId
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @CRtrId,@CPrdName,@CSalesQty
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					
					SET @C_SSQL='UPDATE [RptASRTemplate_Excel] SET ['+ @CPrdName +']= '+ CAST(@CSalesQty AS VARCHAR(50))+''
					SET @C_SSQL=@C_SSQL+ ' WHERE RtrId =' + CAST(@CRtrId AS VARCHAR(10)) + '
					AND RptId =' + CAST(@Pi_RptId AS VARCHAR(10)) + ' AND UsrId =' + CAST(@Pi_UsrId AS VARCHAR(10)) + ' AND SlNo=1 '
					--PRINT @C_SSQL
					EXEC (@C_SSQL)
					FETCH NEXT FROM Values_Cur INTO @CRtrId,@CPrdName,@CSalesQty
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur

		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptASRTemplate_Excel]') 
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					
					SET @C_SSQL='UPDATE [RptASRTemplate_Excel] SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ' AND SlNo=1'
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur

--SELECT * FROM [RptASRTemplate_Excel]

		--Cursors
		/***************************************************************************************************************************/
	END
--EXEC [Proc_RptASRTemplate] 205,1,0,'TEST',0,0,1
RETURN
END
GO
DELETE FROM AUTOBACKUPCONFIGURATION WHERE MODULEID IN
( 'AUTOBACKUP1', 'AUTOBACKUP2', 'AUTOBACKUP3', 'AUTOBACKUP4', 'AUTOBACKUP5',
 'AUTOBACKUP6', 'AUTOBACKUP7', 'AUTOBACKUP8', 'AUTOBACKUP9', 'AUTOBACKUP10',
 'AUTOBACKUP11', 'AUTOBACKUP12', 'AUTOBACKUP13')

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP1','AutomaticBackup','Take Full Backup of the database Every time',1,'',0,'2011-Mar-08 00:00:00',1)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP2','AutomaticBackup','Take Backup/Extract Log while Logging on to the application',0,'',0,'2011-Mar-08 00:00:00',2)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP3','AutomaticBackup','Take Backup/Extract Log while Logging out of the application',1,'',0,'2011-Mar-08 00:00:00',3)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP4','AutomaticBackup','Take Compulsary Backup',0,'',0,'2011-Mar-08 00:00:00',4)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP5','AutomaticBackup','Clear Temporary tables while taking backup',1,'',0,'2011-Mar-08 00:00:00',5)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP6','AutomaticBackup','Compact database while taking backup',1,'',0,'2011-Mar-08 00:00:00',6)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP7','AutomaticBackup','Remove Backup Files',1,'',30,'2011-Mar-08 00:00:00',7)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP8','AutomaticBackup','Take Backup in the following path…',1,'d:\CoreStockyBackup',0,'2011-Mar-08 00:00:00',8)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP9','AutomaticBackup','Full Extract',0,'',0,'2011-Mar-08 00:00:00',9)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP10','AutomaticBackup','Incremental Extract',1,'',0,'2011-Mar-08 00:00:00',10)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP11','AutomaticBackup','Extract and Retain Data',1,'',0,'2011-Mar-08 00:00:00',11)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP12','AutomaticBackup','Extract and Delete Data',0,'',0,'2011-Mar-08 00:00:00',12)

 INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) VALUES ('AUTOBACKUP13','AutomaticBackup','Max Value',1,'',0,'2011-Mar-08 00:00:00',13)

DELETE from Customupdownload WHERE MODULE IN( 'Retailer', 'Purchase Order', 'PO Quantity Split Up', 'Daily Sales', 'Sales Return',
 'Stock', 'Purchase Confirmation', 'Claims', 'Sample Issue Details', 'Scheme Upload for Approval', 'Retailer Category Level Value',
 'Retailer Value Classification', 'Retailer Status & Classification', 'Product Hierarchy Exchange', 'Product', 'Product Batch',
 'Site Code', 'Purchase Receipt', 'Payment Details', 'Payment Status', 'Scheme', 'Special Rate', 'Account Statement', 'Stock Norm',
 'Scheme Approval Download', 'Purchase Order', 'UOM', 'Claim Settlement', 'JC Calendar', 'Bulletin Board', 'Scheme Utilization',
 'Download Trace', 'Upload Trace', 'DailySalesUndelivered', 'For Integration', 'BarCode', 'Sample Receipt')

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (1,1,'Retailer','Retailer','Proc_CS2CN_BLRetailer','Proc_ImportBLRetailer','ETL_Prk_CS2CNBLRetailer','Proc_CN2CSBLRetailer','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (2,1,'Purchase Order','Purchase Order','Proc_CS2CNPurchaseOrder','Proc_ImportCS2CNPurchaseOrder','ETL_Prk_CS2CNPurchaseOrder','Proc_ValidateCS2CNPurchaseOrder','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (3,1,'PO Quantity Split Up','PO Quantity Split Up','Proc_CS2CNPOQuantitySplitUp','Proc_ImportCS2CNPOQuantitySplitUp','ETL_Prk_CS2CNPOQuantitySplitUp','Proc_ValidateCS2CNPOQuantitySplitUp','Transaction','Upload',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (4,1,'Daily Sales','Daily Sales','Proc_BLDailySales','Proc_ImportBLDailySales','ETL_Prk_BLDailySales','Proc_ValidateBLDailySales','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (5,1,'Sales Return','Sales Return','Proc_CS2CN_BLSalesReturn','Proc_ImportBLSalesReturn','ETL_Prk_CS2CNBLSalesReturn','Proc_CN2CSBLSalesReturn','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (6,1,'Stock','Stock','Proc_BLStkInventory','Proc_ImportBLStockInventory','ETL_PrkBLStkInventory','Proc_ValidateBLStockInventory','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (7,1,'Purchase Confirmation','Purchase Confirmation','Proc_CS2CN_BLPurchaseConfirmation','Proc_ImportBLPurchaseConfirmation','ETL_Prk_CS2CNBLPurchaseConfirmation','Proc_CN2CSBLPurchaseConfirmation','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (8,1,'Claims','Claims','Proc_CS2CNClaimAll','Proc_ImportBLClaimAll','ETL_Prk_CS2CNClaimAll','Proc_Cn2Cs_BLClaimAll','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (9,1,'Sample Issue Details','Sample Issue','Proc_CS2CNSampleIssue','Proc_ImportSampleIssue','ETL_PrkCS2CNSampleIssue','Proc_ValidateSampleIssue','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (10,1,'Scheme Upload for Approval','Scheme Upload for Approval','Proc_CS2CN_SchemeApproval','Proc_ImportSchemeApproval','Etl_Prk_CN2CSSchemeApproval','Proc_ValidateSchemeApproval','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (11,1,'Retailer Category Level Value','Retailer Category Level Value','Proc_CS2CNBLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_Cn2Cs_BLRetailerCategoryLevelValue','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (12,1,'Retailer Value Classification','Retailer Value Classification','Proc_CS2CNBLRetailerValueClass','Proc_ImportBLRetailerValueClass','Cn2Cs_Prk_BLRetailerValueClass','Proc_Cn2Cs_BLRetailerValueClass','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (13,1,'Retailer Status & Classification','Retailer Status & Classification','Proc_CS2CNRetailerStatus','Proc_ImportBLRetailerStatus','ETL_Prk_RetailerStatus','Proc_ValidateRetailerStatus','Master','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (14,1,'Product Hierarchy Exchange','Product Hierarchy Exchange','Proc_CS2CNBLProductHierarchyChange','Proc_ImportBLProductHiereachyChange','Cn2Cs_Prk_BLProductHiereachyChange','Proc_Cn2Cs_BLProductHiereachyChange','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (15,1,'Product','Product','Proc_CS2CNBLProduct','Proc_ImportBLProduct','Cn2Cs_Prk_BLProduct','Proc_Cn2Cs_BLProduct','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (16,1,'Product Batch','Product Batch','Proc_CS2CNBLProductBatch','Proc_ImportBLProductBatch','Cn2Cs_Prk_BLProductBatch','Proc_Cn2Cs_BLProductBatch','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (17,1,'Site Code','Site Code','Proc_CS2CNSiteCode','Proc_ImportSiteCode','ETL_Prk_CN2CSSiteCode','Proc_ValidateSiteCode','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (18,1,'Purchase Receipt','Purchase Receipt','Proc_CS2CNBLPurchaseReceipt','Proc_ImportBLPurchaseReceipt','Cn2Cs_Prk_BLPurchaseReceipt','Proc_Cn2Cs_PurchaseReceipt','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (19,1,'Payment Details','Payment Details','Proc_CS2CNPaymentDetails','Proc_ImportBLPaymentDetails','ETL_Prk_PaymentDetails','Proc_ValidatePaymentDetails','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (20,1,'Payment Status','Payment Status','Proc_CS2CNChequeBounce','Proc_ImportBLChequeBounce','ETL_Prk_ChequeBounce','Proc_ValidateChequeBounce','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (21,1,'Scheme','Scheme Master','Proc_CS2CNBLSchemeMaster','Proc_ImportBLSchemeMaster','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeMaster','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (21,2,'Scheme','Scheme Attributes','Proc_CS2CNBLSchemeAttributes','Proc_ImportBLSchemeAttributes','Etl_Prk_Scheme_OnAttributes','Proc_CN2CS_BLSchemeAttributes','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (21,3,'Scheme','Scheme Products','Proc_CS2CNBLSchemeProducts','Proc_ImportBLSchemeProducts','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeProducts','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (21,4,'Scheme','Scheme Slabs','Proc_CS2CNBLSchemeSlab','Proc_ImportBLSchemeSlab','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeSlab','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (21,5,'Scheme','Scheme Rule Setting','Proc_CS2CNBLSchemeRulesetting','Proc_ImportBLSchemeRulesetting','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeRulesetting','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (21,6,'Scheme','Scheme Free Products','Proc_CS2CNBLSchemeFreeProducts','Proc_ImportBLSchemeFreeProducts','Etl_Prk_Scheme_Free_Multi_Products','Proc_CN2CS_BLSchemeFreeProducts','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (21,7,'Scheme','Scheme Combi Products','Proc_CS2CNBLSchemeCombiPrd','Proc_ImportBLSchemeCombiPrd','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeCombiPrd','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (21,8,'Scheme','Scheme On Another Product','Proc_CS2CNBLSchemeOnAnotherPrd','Proc_ImportBLSchemeOnAnotherPrd','Etl_Prk_Scheme_OnAnotherPrd','Proc_CN2CS_BLSchemeOnAnotherPrd','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (22,1,'Special Rate','Special Rate','Proc_CS2CNSpecialRate','Proc_ImportBLSpecialRate','ETL_Prk_SpecialRate','Proc_ValidateSpecialRate','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (23,1,'Account Statement','Account Statement','Proc_CS2CNACStatement','Proc_ImportBLAcStatement','ETL_Prk_ACStatment','Proc_ValidateAcStatment','Report','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (24,1,'Stock Norm','Stock Norm','Proc_CS2CNStockNorm','Proc_ImportBLStockNorm','ETL_Prk_StockNorm','Proc_ValidateStockNorm','Report','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (25,1,'Scheme Approval Download','Scheme Upload for Approval','Proc_CS2CN_SchemeApproval','Proc_ImportSchemeApproval','Etl_Prk_CN2CSSchemeApproval','Proc_ValidateSchemeApproval','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (26,1,'Purchase Order','Purchase Order','Proc_CS2CNBLPurchaseOrder','Proc_ImportBLPurchaseOrder','Cn2Cs_Prk_BLPurchaseOrder','Proc_Cn2Cs_BLPurchaseOrder','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (26,1,'UOM','UOM','Proc_CS2CNBLUOM','Proc_ImportBLUOM','Cn2Cs_Prk_BLUOM','Proc_Cn2Cs_BLUOM','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (27,1,'Claim Settlement','Claim Settlement','Proc_CS2CNClaimSettlement','Proc_ImportBLClaimSettlement','ETL_Prk_BLClaimSettlement','Proc_BLValidateClaimSettlement','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (28,1,'JC Calendar','JC Calendar','Proc_CS2CNJCCalendar','Proc_ImportBLJCCalendar','ETL_Prk_BLJCCalendar','Proc_BLValidateJCCalendar','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (29,1,'Bulletin Board','BulletinBoard','Proc_CS2CNBulletingBoard','Proc_ImportBulletingBoard','Cn2Cs_Prk_BulletingBoard','Proc_Cn2Cs_IntegrationHouseKeeping','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (30,1,'Scheme Utilization','Scheme Utilization','Proc_CS2CNBLSchemeUtilization','Proc_ImportBLSchemeUtilization','ETL_PrkCS2CNBLSchemeUtilization','Proc_ValidateBLSchemeUtilization','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (31,1,'Download Trace','DownloadTracing','Proc_CS2CNDownLoadTracing','Proc_ImportDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','Proc_Cn2CsDownLoadTracing','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (32,1,'Upload Trace','UploadTracing','Proc_CS2CNUpLoadTracing','Proc_ImportUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','Proc_Cn2CsUpLoadTracing','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (33,1,'DailySalesUndelivered','DailySalesUndelivered','Proc_BLDailySales_Undelivered','Proc_ImportBLDailySales_Undelivered','Cs2Cn_Prk_DailySales_Undelivered','Proc_ValidateBLDailySales_Undelivered','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (34,1,'For Integration','For Integration','Proc_IntegrationHouseKeeping','Proc_ImportIntegrationHouseKeeping','ETL_Prk_IntegrationHouseKeeping','Proc_Cn2Cs_IntegrationHouseKeeping','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (35,1,'BarCode','BarCode','Proc_ImportBarCode','Proc_ImportBarCode','Cn2CS_Prk_BarCode','Proc_Cn2Cs_BarCode','MASTER','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (36,1,'Sample Receipt','Sample Receipt','','Proc_ImportSampleReceipt','Cn2Cs_Prk_SampleReceipt','Proc_Cn2Cs_SampleReceipt','Transaction','Download',1)


DELETE from  Tbl_UploadIntegration WHERE ProcessName IN( 'Purchase_Order', 'PO_Quantity_Split_Up', 'Sample_Issue', 'Daily_Sales',
 'Stock', 'Retailer', 'Sales_Return', 'Purchase_Confirmation', 'Claims',
 'Scheme_Utilization', 'DownloadTracing', 'UploadTracing', 'DailySalesUndelivered')


 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (1,'Purchase_Order','Purchase_Order','ETL_Prk_CS2CNPurchaseOrder','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (2,'PO_Quantity_Split_Up','PO_Quantity_Split_Up','ETL_Prk_CS2CNPOQuantitySplitUp','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (3,'Sample_Issue','Sample_Issue','ETL_PrkCS2CNSampleIssue','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (4,'Daily_Sales','Daily_Sales','ETL_Prk_BLDailySales','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (5,'Stock','Stock','ETL_PrkBLStkInventory','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (6,'Retailer','Retailer','ETL_Prk_CS2CNBLRetailer','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (7,'Sales_Return','Sales_Return','ETL_Prk_CS2CNBLSalesReturn','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (8,'Purchase_Confirmation','Purchase_Confirmation','ETL_Prk_CS2CNBLPurchaseConfirmation','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (9,'Claims','Claims','ETL_Prk_CS2CNClaimAll','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (10,'Scheme_Utilization','Scheme_Utilization','ETL_PrkCS2CNBLSchemeUtilization','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (11,'DownloadTracing','DownloadTracing','ETL_Prk_CS2CNDownLoadTracing','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (12,'UploadTracing','UploadTracing','ETL_Prk_CS2CNUpLoadTracing','2011-Feb-23 12:21:35')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (13,'DailySalesUndelivered','DailySalesUndelivered','Cs2Cn_Prk_DailySales_Undelivered','2011-Feb-23 12:21:35')


DELETE from Tbl_DownloadIntegration WHERE ProcessName IN ('Stock_Norm', 'Channel_Class_Info', 'Channel_Group_Info', 'Purchase_Order',
 'Retailer_Approval', 'Group_Pricing', 'Batch_Master', 'Payment_Status', 'Product', 'Payment', 'Account_Statement', 'Purchase',
 'Scheme_HD_Slabs_Rules', 'Scheme_Products', 'Scheme_Attributes', 'Scheme_FreeProducts', 'Scheme_OnAnotherProduct', 'Scheme_RtrValidation',
 'Site_Code', 'UOM_Group', 'JCCalendar', 'Claim_Status', 'BulletinBoard', 'BarCode', 'SampleReceipt')

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (1,'Stock_Norm','ETL_Prk_StockNorm','Proc_ImportBLStockNorm',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (2,'Channel_Class_Info','Cn2Cs_Prk_BLRetailerValueClass','Proc_ImportBLRetailerValueClass',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (3,'Channel_Group_Info','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (4,'Purchase_Order','Cn2Cs_Prk_BLPurchaseOrder','Proc_ImportBLPurchaseOrder',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (5,'Retailer_Approval','ETL_Prk_RetailerStatus','Proc_ImportBLRetailerStatus',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (6,'Group_Pricing','ETL_Prk_SpecialRate','Proc_ImportBLSpecialRate',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (7,'Batch_Master','Cn2Cs_Prk_BLProductBatch','Proc_ImportBLProductBatch',10260,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (8,'Payment_Status','ETL_Prk_ChequeBounce','Proc_ImportBLChequeBounce',1179,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (9,'Product','Cn2Cs_Prk_BLProduct','Proc_ImportBLProduct',1768,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (10,'Payment','ETL_Prk_PaymentDetails','Proc_ImportBLPaymentDetails',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (11,'Account_Statement','ETL_Prk_ACStatment','Proc_ImportBLAcStatement',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (12,'Purchase','Cn2Cs_Prk_BLPurchaseReceipt','Proc_ImportBLPurchaseReceipt',1865,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (13,'Scheme_HD_Slabs_Rules','Etl_Prk_SchemeHD_Slabs_Rules','Proc_ImportSchemeHD_Slabs_Rules',4,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (14,'Scheme_Products','Etl_Prk_SchemeProducts_Combi','Proc_ImportSchemeProducts_Combi',2,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (15,'Scheme_Attributes','Etl_Prk_Scheme_OnAttributes','Proc_ImportScheme_OnAttributes',52,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (16,'Scheme_FreeProducts','Etl_Prk_Scheme_Free_Multi_Products','Proc_ImportScheme_Free_Multi_Products',0,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (17,'Scheme_OnAnotherProduct','Etl_Prk_Scheme_OnAnotherPrd','Proc_ImportScheme_OnAnotherPrd',0,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (18,'Scheme_RtrValidation','Etl_Prk_Scheme_RetailerLevelValid','Proc_ImportScheme_RetailerLevelValid',0,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (19,'Site_Code','ETL_Prk_CN2CSSiteCode','Proc_ImportSiteCode',0,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (20,'UOM_Group','Cn2Cs_Prk_BLUOM','Proc_ImportBLUOM',0,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (21,'JCCalendar','ETL_Prk_BLJCCalendar','Proc_ImportBLJCCalendar',0,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (22,'Claim_Status','ETL_Prk_BLClaimSettlement','Proc_ImportBLClaimSettlement',0,100,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (23,'BulletinBoard','Cn2Cs_Prk_BulletingBoard','Proc_ImportBulletingBoard',0,500,'2011-Feb-23 12:21:35')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (25,'BarCode','Cn2CS_Prk_BarCode','Proc_ImportBarCode',0,500,'2011-Aug-03 09:44:11')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (26,'SampleReceipt','Cn2Cs_Prk_SampleReceipt','Proc_ImportSampleReceipt',0,500,'2011-Aug-03 09:44:11')

DELETE FROM CONFIGURATION WHERE MODULEID IN ('DBOY1','DBOY2','PO1','RET1','RET2','RET3','RET4','RET5',
'RET6','RET7','RET8','RET9','BCD1','DBCRNOTE7','SJN5','SCHCON4','SAMPLE1','DBCRNOTE8','DBCRNOTE10',
'DBCRNOTE11','DBCRNOTE12','DBCRNOTE13','SAL1','SAL2','VANLOAD1','VANLOAD2','VANLOAD3','VANLOAD4',
'VANLOAD5','VANLOAD6','VANLOAD7','IRA1','IRA2','IRA3','IRA4','SALVAGE1','SALVAGE2','SALVAGE3',
'SALVAGE4','SALVAGE5','SALVAGE6','SALVAGE7','SALVAGE8','SALVAGE9','SALVAGE10','SALVAGE11',
'SALVAGE12','STKMGNT1','STKMGNT2','STKMGNT3','STKMGNT4','STKMGNT5','STKMGNT6','STKMGNT7','STKMGNT8',
'STKMGNT9','STKMGNT10','STKMGNT11','RTNTOCOMPANY1','RTNTOCOMPANY2','RTNTOCOMPANY3','RTNTOCOMPANY4','RTNTOCOMPANY5',
'RTNTOCOMPANY6','PRDSALBUNDLE1','PRDSALBUNDLE2','PRDSALBUNDLE3','BAT1','BAT2','BAT3','BAT4','BAT5','BAT6','BAT7',
'BAT8','COLL1','COLL2','COLL3','COLL4','COLL5','COLL6','COLL7','COLL8','COLL9','COLL10','COLL11','COLL12','COLL13',
'COLL14','SJN1','SJN2','SJN3','SJN4','PAYMENT1','PAYMENT2','PAYMENT3','PAYMENT4','PAYMENT5','CHEQUE1','CHEQUE2',
'CHEQUE3','CHEQUE4','CHEQUE5','CHEQUE6','CHEQUE7','REP1','RETREP1','BILALERTMGNT1','BILALERTMGNT2','BILALERTMGNT3',
'BILALERTMGNT4','BILALERTMGNT5','BILALERTMGNT6','BILALERTMGNT7','BILALERTMGNT8','BILALERTMGNT9','BILALERTMGNT10',
'BILALERTMGNT11','BILALERTMGNT12','BILALERTMGNT13','BILALERTMGNT14','PURCHASERECEIPT17','DBCRNOTE9','BCD2','BCD3',
'BCD4','BCD5','BCD6','BCD7','BCD8','BCD9','BCD10','BCD11','BCD12','BCD13','BCD14','BILLRTEDIT1','BILLRTEDIT2',
'BILLRTEDIT3','BILLRTEDIT4','BILLRTEDIT5','BILLRTEDIT6','BCD15','BILLRTEDIT7','BILLRTEDIT8','BILLRTEDIT9','BILLRTEDIT10',
'BILLRTEDIT11','BILLRTEDIT12','BILLRTEDIT13','BILLRTEDIT14','BILLRTEDIT15','BILLRTEDIT16','BILLRTEDIT17','DISTAXCOLL1',
'DISTAXCOLL5','DISTAXCOLL6','RET21','RET22','RET23','RET24','SCHEMESTNG13','SCHEMESTNG12','SCHEMESTNG11','SCHEMESTNG10',
'SCHEMESTNG9','SCHEMESTNG8','SCHEMESTNG7','SCHEMESTNG6','SCHEMESTNG5','SCHEMESTNG4','SCHEMESTNG3','SCHEMESTNG2','SCHEMESTNG1',
'RET25','GENCONFIG1','PURCHASERECEIPT1','PURCHASERECEIPT2','PURCHASERECEIPT3','PURCHASERECEIPT4','PURCHASERECEIPT5','PURCHASERECEIPT6',
'RET27','PURCHASERECEIPT7','PURCHASERECEIPT8','PURCHASERECEIPT9','PURCHASERECEIPT10','PURCHASERECEIPT11','PURCHASERECEIPT12','PURCHASERECEIPT13',
'PURCHASERECEIPT14','DISTAXCOLL3','TARGETANALYSIS1','TARGETANALYSIS2','TARGETANALYSIS3','TARGETANALYSIS4','TARGETANALYSIS5',
'TARGETANALYSIS6','TARGETANALYSIS7','TARGETANALYSIS8','TARGETANALYSIS9','TARGETANALYSIS10','TARGETANALYSIS11','TARGETANALYSIS12',
'TARGETANALYSIS13','TARGETANALYSIS14','SALESRTN1','SALESRTN2','SALESRTN3','SALESRTN4','SALESRTN5','SALESRTN6','SALESRTN7',
'SALESRTN8','SALESRTN9','SALESRTN10','SALESRTN11','SALESRTN12','SALESRTN13','SALESRTN14','MARKETRTN1','MARKETRTN2','MARKETRTN3',
'MARKETRTN4','MARKETRTN5','MARKETRTN6','MARKETRTN7','MARKETRTN8','DISTAXCOLL4','MARKETRTN9','MARKETRTN10','MARKETRTN11','MARKETRTN12',
'MARKETRTN13','MARKETRTN14','GENCONFIG3','GENCONFIG4','GENCONFIG9','PO2','PO3','PO4','PO5','PO6','PO7','PO8','PO9','PO10','PO11','PO12',
'PO13','RET10','RET11','RET12','RET13','RET19','RET26','RET14','RET15','PWDPROTECTION1','PWDPROTECTION2','PWDPROTECTION3','PWDPROTECTION4',
'PWDPROTECTION5','PWDPROTECTION6','PWDPROTECTION7','PWDPROTECTION8','PWDPROTECTION9','PWDPROTECTION10','REMINDER1','REMINDER2','REMINDER3',
'RET16','RET17','RET18','RET20','REMINDER4','REMINDER5','REMINDER6','REMINDER7','SCHEMESTNG14','SCHEMESTNG15','DBCRNOTE1',
'DBCRNOTE2','DBCRNOTE3','DBCRNOTE4','GENCONFIG2','GENCONFIG5','GENCONFIG6','GENCONFIG10','GENCONFIG12','GENCONFIG16','GENCONFIG17','BL1',
'BL2','BL3','ORD1','ORD2','ORD4','ORD5','ORD6','ORD7','BILLRTEDIT18','PO14','GENCONFIG18','JC1','PO15','PO16','PO17','PO18','PO19','PO20',
'PO21','PO22','PO23','PO24','BILLRTEDIT19','DATATRANSFER1','PURCHASERECEIPT22','SALESRTN16','PO25','PO26','PO27','PO28','RET28','PURCHASERECEIPT16',
'GENCONFIG19','BCD16','GENCONFIG20','PRD1','PRD2','PRD3','PRD4','DBCRNOTE14','CHEQUE8','SCHCON5','GENCONFIG21','GENCONFIG22','GENCONFIG7','GENCONFIG8',
'SALESRTN17','GENCONFIG13','JC2','JC3','PO29','PO30','PO31','PO32','PO33','PO34','PO35','RET29','SALESRTN15','BotreeNewBatch','RET30','DATATRANSFER2',
'DATATRANSFER4','DATATRANSFER5','DATATRANSFER6','DATATRANSFER7','DATATRANSFER8','DATATRANSFER9','DATATRANSFER10','ORD3','ORD8','ORD9','ORD10','PURCHASERECEIPT15',
'DATATRANSFER11','DATATRANSFER12','DATATRANSFER13','RET31','DATATRANSFER3','DATATRANSFER14','DATATRANSFER15','DATATRANSFER16','DATATRANSFER17','DATATRANSFER18',
'DATATRANSFER19','DATATRANSFER20','DATATRANSFER21','DATATRANSFER22','DATATRANSFER23','DATATRANSFER24','DATATRANSFER25','DATATRANSFER26','DATATRANSFER27',
'DATATRANSFER28','DATATRANSFER29','DATATRANSFER30','DATATRANSFER31','DATATRANSFER32','DATATRANSFER33','DATATRANSFER34','DATATRANSFER35','DATATRANSFER36',
'DATATRANSFER37','DATATRANSFER38','DATATRANSFER39','SALESRTN18','GENCONFIG14','DAYENDPROCESS1','DAYENDPROCESS2','DAYENDPROCESS3','BILLRTEDIT20','BILLRTEDIT31',
'BILLRTEDIT21','BILLRTEDIT22','BILLRTEDIT23','BILLRTEDIT24','DAYENDPROCESS4','DAYENDPROCESS5','DAYENDPROCESS6','BILLRTEDIT30','BILLRTEDIT25','BCD17','BCD18',
'BotreeAutoBatchTransfer','RETREP2','DATATRANSFER40','GENCONFIG15')

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBOY1','Delivery Boy','Allow Route Sharing by Delivery Boy',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBOY2','Delivery Boy','Allow Automatic Route attatchment if no Routes are selected',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO1','Purchase Order','Auto generates purchase order qty based on norm settings by populating all products automatically based on product sequencing screen settings',0,'0',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET1','Retailer','Make TIN Number as Mandatory if Tax Type is VAT',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET2','Retailer','Set Cash Discount Maximum Limit As',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET3','Retailer','Set Cash Discount Condition as',0,'1',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET4','Retailer','Make Expiry date as Mandatory if Licence Number is entered',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET5','Retailer','Make Expiry date as Mandatory if Drug Licence Number is entered',1,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET6','Retailer','Make Expiry date as Mandatory if Pesticide Licence Number is entered',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET7','Retailer','Allow attaching multiple sales routes for same company',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET8','Retailer','Always use default Geography Level as...',1,'City',5,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET9','Retailer','Always display default Coverage Mode as',1,'1',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD1','BillConfig_Display','Enable automatic Popup of Salesman and Route in the Bill Tag',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE7','DebitNoteCreditNote','Supplier Credit Note',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN5','Stock Journal','Create Reason as Mantatory',1,'0',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON4','Scheme Master','Allow user to create',0,'-1',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SAMPLE1','Sample Maintenance','Allow Sample Issue without rule setting',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE8','DebitNoteCreditNote','Supplier Debit Note',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE10','DebitNoteCreditNote','Retailer Debit Note',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE11','DebitNoteCreditNote','Supplier Credit Note',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE12','DebitNoteCreditNote','Supplier Debit Note',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE13','DebitNoteCreditNote','Retailer Credit Note',0,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SAL1','Salesman','Allow Route Sharing By Salesman as',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SAL2','Salesman','Allow Automatic Route Attatchment if no routes are selected',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD1','VanLoadUnload','Follow FIFO for Automatic Van Load',1,'FIFO',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD2','VanLoadUnload','Allow Van To Van Transfer',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD3','VanLoadUnload','Use MonthDefault Value',1,'',1,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD4','VanLoadUnload','Raise a debit Note against Salesman for the Shortage Qty',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD5','VanLoadUnload','Set Focus on Uom1',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD6','VanLoadUnload','Required Uom2',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD7','VanLoadUnload','Use Default Option for VanLoading',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('IRA1','IRA','Dispay the Batch Details',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('IRA2','IRA','Perform Stock Addition Automatically',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('IRA3','IRA','Perform Stock Out Automatically',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('IRA4','IRA','Variance Price',2,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE1','Salvage','Fill Batches automatically when Product is selected',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE2','Salvage','Display only UnSaleable Location in the Location search',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE3','Salvage','Display only UnSaleable Stock Types in the Stock Type search',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE4','Salvage','Repeat the first selected reason for all the lines',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE5','Salvage','Make Reason as mandatory is the Stock Type is :',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE6','Salvage','Allow editing of Claim Amount field',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE7','Salvage','Allow the edited Amount to be higher than the Actual Amount',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE8','Salvage','Allow Creating new Location by pressing Insert Key',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE9','Salvage','Allow Creating Stock Type by pressing Insert Key',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE10','Salvage','Allow Creating new Product by pressing Insert Key',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE11','Salvage','Allow Creating new Batches Type by pressing Insert Key',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE12','Salvage','Allow Creating new Reason by pressing Insert Key',1,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT1','Stock Management','Manual Selection for Batches',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT2','Stock Management','Follow FIFO for Loading Batches',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT3','Stock Management','Follow LIFO for Loading Batches',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT4','Stock Management','Display Vans while searching the Location Name',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT5','Stock Management','Repeat the first selected reason for all the lines',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT6','Stock Management','Make the reason as mandatory if the stock type is :',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT7','Stock Management','Allow Creating new Batches by pressing Insert Key',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT8','Stock Management','Allow Creating new Location by pressing Insert Key',1,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT9','Stock Management','Allow Creating Stock Adjustment Type by pressing Insert Key',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT10','Stock Management','Allow Creating new Product by pressing Insert Key',1,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT11','Stock Management','Allow Creating new Reason by pressing Insert Key',1,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY1','ReturnToCompany','Fill Bathes automatically once product is selected',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY2','ReturnToCompany','Repeat the first selected reason for all the lines',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY3','ReturnToCompany','Make the reason Mandatory of the stock Type is >',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY4','ReturnToCompany','Allow Editing of Claim Amount Field',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY5','ReturnToCompany','Allow Edited to be higher than the Actual Amount',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY6','ReturnToCompany','Include Tax on Product Value',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRDSALBUNDLE1','ProductSalesBundle','Allow Salesman selection Irrespective of Company selection',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRDSALBUNDLE2','ProductSalesBundle','Allow Route selection Irrespective of Company selection',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRDSALBUNDLE3','ProductSalesBundle','Display Total Number of Routes attached Irrespective of Company selection',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT1','Batch Transfer','Allow Selection of Batches of any Stock Type',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT2','Batch Transfer','Allow Selection only of Stock Type',0,'Damaged',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT3','Batch Transfer','Raise Supplier Credit Note',1,'Rate for Claim/Greater than/Rate for Claim',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT4','Batch Transfer','Raise Supplier Debit Note',1,'Rate for Claim/Greater than/Rate for Claim',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT5','Batch Transfer','Raise a Claim',0,'Rate for Claim/Greater than/Rate for Claim',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT6','Batch Transfer','Allow Creating new Product by pressing Insert Key',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT7','Batch Transfer','Allow Creating new Batches by pressing Insert Key',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT8','Batch Transfer','Allow Creating new Reason by Pressing Insert Key',1,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL1','Collection Register','From Date as',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL2','Collection Register','Salesman Based on Date',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL3','Collection Register','Delivery Route Based on',1,'0',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL4','Collection Register','Sales Route Based on',1,'0',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL5','Collection Register','Retailer Based on',1,'0',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL6','Collection Register','Collected By',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL7','Collection Register','Salesman',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL8','Collection Register','Delivery Route',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL9','Collection Register','Sales Route',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL10','Collection Register','Retailer',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL11','Collection Register','Bank',1,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL12','Collection Register','Branch',1,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL13','Collection Register','ExcessCollection',1,'1',NULL,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL14','Collection Register','Perform Account Posting for Cheques',1,'0',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN1','Stock Journal','Allow Creating new Stock Type by pressing Insert Key',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN2','Stock Journal','Allow Creating new Product by pressing Insert Key',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN3','Stock Journal','Allow Creating new Batches by pressing Insert Key',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN4','Stock Journal','Allow Creating new Reason by pressing Insert Key',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT1','Payment Register','Allow partial payment for an Invoice',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT2','Payment Register','Allow creation of new Credit Note by pressing Insert key',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT3','Payment Register','Allow creation of new Debit Note by pressing Insert key',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT4','Payment Register','Allow multiple mode of pay for a single payment',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT5','Payment Register','Allow creation of new Cheque/DD  by pressing Insert key',1,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE1','Cheque Payment','Allow bulk updation of Pending Cheques to Banked',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE2','Cheque Payment','Allow bulk updation of Pending Cheques to Settled',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE3','Cheque Payment','Allow bulk updation of Pending Cheques to Bounced',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE4','Cheque Payment','Allow bulk updation of Banked Cheques to Settled',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE5','Cheque Payment','Allow bulk updation of Banked Cheques to Bounced',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE6','Cheque Payment','Alert Regarding CDC Cheques at the time of Logging out',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE7','Cheque Payment','Alert Regarding CDC Cheques at the time of Logging in',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REP1','Replacement','Allow user to select only the same product  for Replacement',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RETREP1','RetReplacement','Allow user to select only the same product  for Replacement',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT1','Alert Management','Action on Credit Days Limit',0,'0',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT2','Alert Management','Action on Allowed Credit Amount Limit',1,'1',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT3','Alert Management','Action on Credit Bills Limit',0,'0',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT4','Alert Management','Allow Billing on Distributors off Day',1,'1',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT5','Alert Management','Allow Billing on Retailers off Day',1,'1',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT6','Alert Management','Allow Billing on Weekend Days - JC Calendar',1,'1',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT7','Alert Management','Allow Billing on Holidays defined',1,'1',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT8','Alert Management','Restrict Billing if TIN number is not filling in the Retailer master for VAT Retailers',0,'0',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT9','Alert Management','Restrict Billing if CST number is not filling in the Retailer master',0,'0',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT10','Alert Management','Restrict Billing for Drug Products if Drug Product License Number is not filled in Retailer master',0,'0',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT11','Alert Management','Restrict Billing if License Number is not filled in Retailer master',0,'0',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT12','Alert Management','Restrict Billing if Pesticide License Number is not filled in Retailer master',0,'0',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT13','Alert Management','Alert if Shelf Life of the selected Batch is',0,'0',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT14','Alert Management','Alert if Expiry Date of the selected Batch is',0,'0',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT17','Purchase Receipt','Allow Editing of Gross Amount in Purchase Receipt Screen',1,'0',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE9','DebitNoteCreditNote','Retailer Credit Note',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD2','BillConfig_Display','Allow direct Retailer Selection',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD3','BillConfig_Display','Display Retailer based on Coverage Mode in the hotsearch',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD4','BillConfig_Display','Display Retailer based on Route Coverage plan in hotsearch',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD5','BillConfig_Display','Display Messages for Retailer Birthday / Anniversary / Registration - On Retailer Selection',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD6','BillConfig_Display','Populate Products automatically based on the Product sequencing screen settings',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD7','BillConfig_Display','Automatically popup the hotsearch window if the user types in the Product code',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD8','BillConfig_Display','Fill Batches automatically based on',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD9','BillConfig_Display','Set the Tab focus on UOM 1 Once the Batch is selected',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD10','BillConfig_Display','Hide the columns for UOM2 and Qty2',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD11','BillConfig_Display','Popup a screen for entering the Batch Number for drug products while billing the drug products',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD12','BillConfig_Display','Display all the Debit Notes while pressing the Debit Note adjustment button',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD13','BillConfig_Display','Display all the Credit Notes while pressing the Credit Note adjustment button',0,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD14','BillConfig_Display','Display Retailer Based On',1,'Name',1,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT1','BillConfig_RateEdit','Allow Editing of Selling Rate in the billing screen',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT2','BillConfig_RateEdit','Allow Editing of Net Rate in the billing screen',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT3','BillConfig_RateEdit','Allow the user to reduce the amount from batch rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT4','BillConfig_RateEdit','Allow the user to add the amount from batch rate',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT5','BillConfig_RateEdit','Allow both addition and reduction',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT6','BillConfig_RateEdit','Make reason as mandatory if the user is reducing the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD15','BillConfig_Display','Enable bill to bill copying option',0,'',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT7','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT8','BillConfig_RateEdit','Treat the difference amount as Distributor Discount',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT9','BillConfig_RateEdit','Add the difference amount to Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT10','BillConfig_RateEdit','Make reason as mandatory if the user is adding the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT11','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT12','BillConfig_RateEdit','Add the difference amount to Gross Profit',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT13','BillConfig_RateEdit','Treat the difference amount in Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT14','BillConfig_RateEdit','Allow the user to reduce the amount of Net Rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT15','BillConfig_RateEdit','Allow the user to add the amount of Net Rate',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT16','BillConfig_RateEdit','Allow both addition and reduction',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT17','BillConfig_RateEdit','Make reason as mandatory if the user is reducing the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL1','Discount & Tax Collection','Allow Editing of Cash Discount in the billing screen',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL5','Discount & Tax Collection','Perform auto confirmation of bill',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL6','Discount & Tax Collection','Automatically perform Vehicle allocation while saving the bill',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET21','Retailer','Change retailer status inactive if the norm is violater for',0,'0',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET22','Retailer','Credit Norm - Credit Bills',0,'0',0,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET23','Retailer','Credit Norm - Credit Limit',0,'0',0,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET24','Retailer','Credit Norm - Credit Days',0,'0',0,24)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG13','Schemes OrderSelection','Adjust Window Display Schemes only once',0,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG12','Schemes OrderSelection','Display all Window Dispaly Schemes by pressing Insert Key',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG11','Schemes OrderSelection','Allow Creation of new reasons by pressing Insert Key',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG10','Schemes OrderSelection','Allow Creation of new Shipping Address by pressing Insert Key',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG9','Schemes OrderSelection','Allow Creation of new Retailers by pressing Insert Key',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG8','Schemes OrderSelection','Set the default reason as',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG7','Schemes OrderSelection','Popup the reason for non billing while changing the route or closing the billing screen',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG6','Schemes OrderSelection','Hide retailer details in the Order Selection screen if user selects the order after selecting the re',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG5','Schemes OrderSelection','Allow partial settlement of Orders in multiple bills',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG4','Schemes OrderSelection','Treat the order as closed once selected in the Bill',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG3','Schemes OrderSelection','Allow Selection of Multiple orders',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG2','Schemes OrderSelection','Restrict the user from unchecking the claimable schemes',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG1','Schemes OrderSelection','Automatically apply the schemes other than flexi scheme',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET25','Retailer','Automatically activate the retailer once the norm is reinstated',0,'0',0,25)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG1','General Configuration','Allow Multi Company Operation',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT1','Purchase Receipt','Allow Creation of Purchase Receipt with and without Purchase Order',1,'Allow Addition of More Products',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT2','Purchase Receipt','Allow Creation of Purchase Receipt only with Purchase Order',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT3','Purchase Receipt','Allow Creation of Purchase Receipt only without Purchase Order',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT4','Purchase Receipt','Allow Creation of new Product by Pressing Insert Key',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT5','Purchase Receipt','Allow Creation of new Batch by Pressing Insert Key',1,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT6','Purchase Receipt','Include provision for entering Handling Charges in Purchae Receipt',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET27','Retailer','Change the Retailer Status as Inactive if the following Credit Norm is Violated Before Approval',0,'0',0,27)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT7','Purchase Receipt','Allow Refuse Sale in Purchase',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT8','Purchase Receipt','Allow selection of Saleable Quantity for Refusal',1,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT9','Purchase Receipt','Allow selection of UnSaleable quantity for Refusal',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT10','Purchase Receipt','Allow Saving of Purchase Receipt even if There is a Rate difference',1,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT11','Purchase Receipt','Use Company Product Code for reference in Purchase Receipt',1,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT12','Purchase Receipt','Use Distributor Product Code for reference in Purchase Receipt',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT13','Purchase Receipt','Populate Products Automatically based on the Product Sequencing Screen Settings',0,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT14','Purchase Receipt','Allow Duplicate Rows',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL3','Discount & Tax Collection','Calculate Tax in Line Level',1,'LEVEL',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS1','Target Analysis','Automatic',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS2','Target Analysis','Company',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS3','Target Analysis','Prd Hier',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS4','Target Analysis','Target Type',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS5','Target Analysis','Auto Confirm Target when',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS6','Target Analysis','Allow Target Saving in',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS7','Target Analysis','Sales between',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS8','Target Analysis','Previous',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS9','Target Analysis','Target Split',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS10','Target Analysis','Allow user to set the Target on Distributors Holidays',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS11','Target Analysis','Display Distributors Holidays in Different Colours',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS12','Target Analysis','Allow user to set the Target on Distributors  Off days',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS13','Target Analysis','Display Distributors Off days in Different Colours',0,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS14','Target Analysis','Display Retailers Off days in Different Colours',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN1','Sales Return','Allow Editing of Selling Rates in the Sales Return Screen  When no Bill Reference is Selected',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN2','Sales Return','Allow the user to reduce the amount from batch rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN3','Sales Return','Allow the user to add the amount from batch rate',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN4','Sales Return','Allow both addition and reduction',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN5','Sales Return','Make reason as mandatory if the user is reducing the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN6','Sales Return','Raise Claims Based on Reasons Attached',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN7','Sales Return','Treat the difference amount as',1,'Distributor Discount',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN8','Sales Return','Add the difference amount to S R Rate Difference Claim',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN9','Sales Return','Make reason as mandatory if the user is Adding the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN10','Sales Return','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN11','Sales Return','Add the difference amount to Gross Profit',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN12','Sales Return','Treat the difference amount in S R Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN13','Sales Return','Automatically pop up the hot search window if the user types in the product code',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN14','Sales Return','Make reason as mandatory if the Stock Type is',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN1','Market Return','Allow Editing of Selling Rate in the Market Return Screen',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN2','Market Return','Allow the user to reduce the amount from batch rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN3','Market Return','Allow the user to add the amount from batch rate',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN4','Market Return','Allow both addition and reduction',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN5','Market Return','Make reason as mandatory if the user is reducing the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN6','Market Return','Raise Claims Based on Reasons Attached',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN7','Market Return','Treat the difference amount as',1,'Distributor Discount',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN8','Market Return','Add the difference amount to S R Rate Difference Claim',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL4','Discount & Tax Collection','Post Vouchers on Bill date',1,'0',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN9','Market Return','Make reason as mandatory if the user is Adding the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN10','Market Return','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN11','Market Return','Add the difference amount to Gross Profit',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN12','Market Return','Treat the difference amount in S R Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN13','Market Return','Automatically pop up the hot search window if the user types in the product code',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN14','Market Return','Make reason as mandatory if the Stock Type is',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG3','General Configuration','Display Dash Board while opening the application',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG4','General Configuration','Connect to Website:',1,'www.botree.co.in',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG9','General Configuration','Display Batch automatically when single batch is available in the attached screens',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO2','Purchase Order','Auto generates purchase order qty based on norm settings by manually selecting products',0,'0',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO3','Purchase Order','Populate products automatically based on the product sequencing screen settings but not auto generate Purchase Order Qty',0,'0',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO4','Purchase Order','Manually select products and not auto generate Purchase Order Qty',1,'0',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO5','Purchase Order','Allow Creating new Product by pressing Insert Key',0,'0',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO6','Purchase Order','Make Supplier Selection Compulsory in Purchase Order Screen',0,'0',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO7','Purchase Order','Purchase Between',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO8','Purchase Order','Sales Between',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO9','Purchase Order','Purchase Order Between',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO10','Purchase Order','Previous',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO11','Purchase Order','Previous',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO12','Purchase Order','Previous',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO13','Purchase Order','Use Company Product Code for reference in Purchase Order Screen',1,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET10','Retailer','Always display default Retailer Day Off as',1,'0',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET11','Retailer','Set the default Retailer Status as while adding a new retailer',1,'0',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET12','Retailer','Set the default Retailer Tax Group as... while adding a new retailer',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET13','Retailer','Always display default Coverage Frequency as',1,'0',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET19','Retailer','Treat Retailer TaxGroup as Mandatory',1,'',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET26','Retailer','Automatically Populate Retailer Code based on  Counter Settings for Retailer Code Creation',1,'',0,26)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET14','Retailer','Credit Bills',0,'0',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET15','Retailer','Credit Limit',0,'0',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION1','Password Protection','Set the minimum number of digits as                     for Password',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION2','Password Protection','Ask for new password in every                     days',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION3','Password Protection','Password should not be repeated for                    times',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION4','Password Protection','Password should be different from user name',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION5','Password Protection','Make alphanumeric password (cgk123) as mandatory',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION6','Password Protection','Allow special characters (%#$@^) in password field',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION7','Password Protection','Make special characters as mandatory in password field',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION8','Password Protection','Allow keyboard sequence (asdf) and sequential numbers (123)',1,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION9','Password Protection','Allow the password with all numbers, uppercase letters or lowercase letters',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION10','Password Protection','Allow using repeating character (aa11)',1,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER1','Reminder','From Time(HH:MM)',1,'09',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER2','Reminder','From Time(HH:MM)',1,'00',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER3','Reminder','ToTime(HH:MM))',1,'09',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET16','Retailer','Credit Days',0,'0',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET17','Retailer','Seek approval for retailer classification && category change',1,'0',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET18','Retailer','Enable Retailer Status Update Lock',1,'2',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET20','Retailer','Automatically inactivate the retailer if not approved                      Days',0,'0',0,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER4','Reminder','From Time(HH:MM)',1,'00',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER5','Reminder','Set the duration between times(MM)',1,'30',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER6','Reminder','From Time(HH:MM)',1,'0',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER7','Reminder','ToTime(HH:MM)',1,'1',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG14','Schemes OrderSelection','Include Primary Scheme Amount in Primary Scheme,Primary Discount Column',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG15','Schemes OrderSelection','Consider Edited Selling rate for Scheme Calculation',0,'',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE1','DebitNoteCreditNote','Allow to enter tax breakup for Credit Note (Supplier)',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE2','DebitNoteCreditNote','Allow to enter tax breakup for Debit Note (Supplier)',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE3','DebitNoteCreditNote','Allow to enter tax breakup for Credit Note (Retailer)',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE4','DebitNoteCreditNote','Allow to enter tax breakup for Debit Note (Retailer)',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG2','General Configuration','Run Retailer Class Update Tool at Month End',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG5','General Configuration','Calculation Decimal Digit Value',1,'',2,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG6','General Configuration','Screen Color',1,'Stocky Green',6,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG10','General Configuration','Consider Post Dated Cheque for Credit check',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG12','General Configuration','Display default Company,Supplier and Location',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG16','General Configuration','Download the schemes even though the products does not exists in product master',1,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG17','General Configuration','Enable Advanced Search Option',1,'0',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BL1','BL Configuration','Automatically create price batches based on selling rate received from Console',2,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BL2','BL Configuration','Automatically create contract price entry based on new price batch creation',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BL3','BL Configuration','Perform Cheque Bounce based on data received from Console',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD1','Order Booking','Enable Delivery Challan Option',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD2','Order Booking','Focus on Delivery Challan Tab while opening the screen',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD4','Order Booking','Prompt the user to convert open DCs to Bill after',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD5','Order Booking','Enable DC to Bill conversion based on user selection',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD6','Order Booking','Automatically bill all the pending DCs on the due date',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD7','Order Booking','Auto Convert the DCs based on individual DC date',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT18','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO14','Purchase Order','Use Ditributor Product Code for reference in Purchase Order Screen',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG18','General Configuration','Show HotSearch in Standard Width',1,'0',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('JC1','JC Calendar','Populate dates automatically based on the first entry',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO15','Purchase Order','Allow Entering quantity break up against(+) ',1,'1',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO16','Purchase Order','Download Suggested PO From Console',1,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO17','Purchase Order','Auto generate PO Based On Company Defined Norms',0,'',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO18','Purchase Order','Enable only addition of quantity',1,'',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO19','Purchase Order','Enable addition and reduction',0,'',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO20','Purchase Order','Enable only reduction of quantity',0,'',0,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO21','Purchase Order','Do not display alert on pending POs',1,'',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO22','Purchase Order','Display daily alert on number of pending POs',0,'',0,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO23','Purchase Order','Display alert on due date on number of pending POs',0,'',0,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO24','Purchase Order','Both Events',0,'',0,24)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT19','BillConfig_RateEdit','Treat the difference amount as Distributor Discount',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER1','DataTransfer','Automatic check for Internet Connection',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT22','Purchase Receipt','Allow Manual Calculation while Donwloading Purchase',0,'',0,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN16','Sales Return','Enable Delivery Return Option in Sales Return',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO25','Purchase Order','While Logging Out',0,'',0,25)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO26','Purchase Order','While Logging In',1,'',0,26)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO27','Purchase Order','Auto Confirm at Log In',0,'',0,27)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO28','Purchase Order','Auto Convert at Log Out',1,'',0,28)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET28','Retailer','Credit Norm Approval - Credit Bills',0,'0',0,28)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT16','Purchase Receipt','Allow OID Calculation',0,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG19','General Configuration','Include Scheme Claims in  Claim Top Sheet',1,'0',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD16','BillConfig_Display','Invoke sample issue screen by pressing key combination',1,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG20','General Configuration','Enable tracking of Unsalable quantity based on transaction reference number',0,'0',0,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD1','Product Master','Treat EAN code field as Mandatory',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD2','Product Master','Allow manual editing of the EAN code even after transactions made for the product',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD3','Product Master','Update EAN code when downloaded from central server',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD4','Product Master','Allow same EAN code for multiple products',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE14','DebitNoteCreditNote','Retailer Debit Note',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE8','Cheque Payment','Enable Re- Presenting of Bounced Cheque',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON5','Scheme Master','Treat budget amount as mandatory if claimable condition is set as',0,'-1',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG21','General Configuration','Display MRP in Product Hot Search Screen',0,'',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG22','General Configuration','Display Quantity in UOM based',0,'0',0,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG7','General Configuration','1.00',1,'5',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG8','General Configuration','Nearest',1,'0',1,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN17','Sales Return','Allow User to Make Direst Sales Return',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG13','General Configuration','Currency',1,'Rupees',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('JC2','JC Calendar','Allow Manual Entry of Week Start and End dates',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('JC3','JC Calendar','Restrict no of days based on No of Days in Calendar year',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO29','Purchase Order','Allow Editing of auto generated quantity',1,'',0,29)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO30','Purchase Order','Alert the user to confirm && Upload open PO',1,'5',0,30)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO31','Purchase Order','Enable PO Confirmation based on user selection',1,'',0,31)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO32','Purchase Order','Automatically confirm all the pending POs on the due date',1,'',0,32)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO33','Purchase Order','Does not allow transaction if PO is not confirmed after due date',1,'',0,33)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO34','Purchase Order','Make Product Hierarchy selection compulsory In Purchase Order Screen',1,'',0,34)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO35','Purchase Order','Display Purchase Order Value',1,'',0,35)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET29','Retailer','Credit Norm Approval - Credit Limit',0,'0',0,29)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN15','Sales Return','Perform automatic Credit Note / Replacement selection entry based on the rule setting',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeNewBatch','BotreeNewBatch','Allow to create Product Batches only for Industrial Packs',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET30','Retailer','Credit Norm Approval - Credit Days',0,'0',0,30)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER2','DataTransfer','Time Interval for Net Connection Check -in minute',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER4','DataTransfer','Zip the file while sendingFTP',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER5','DataTransfer','Upload Server Path',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER6','DataTransfer','Download Server Path',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER7','DataTransfer','Upload Server Username',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER8','DataTransfer','Upload Server Password',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER9','DataTransfer','Download Server Username',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER10','DataTransfer','Download Server Password',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD3','Order Booking','Perform Tax Calculation in Delivery Challan',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD8','Order Booking','Does not allow transaction if DC is not converted after due date',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD9','Order Booking','Allow deleting Unbilled DCs',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD10','Order Booking','Do not display alert on pending DCs',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT15','Purchase Receipt','Enable Sample Receipt option through 
Purchase Receipt Screen',1,'',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER11','DataTransfer','Archive In Folder FTP',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER12','DataTransfer','Archive Out Folder FTP',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER13','DataTransfer','No of Days for Deleting Archiving FTP',0,'',30,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET31','Retailer','Automattically Activate the Retailer once the Pre-Approval Norm is Reinstated',0,'0',0,31)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER3','DataTransfer','FileFormatSelectionFTP',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER14','DataTransfer','Error Log Folder Ftp',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER15','DataTransfer','FileFormatSelection HTTP',0,'',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER16','DataTransfer','Zip the file while sending HTTP',1,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER17','DataTransfer','Upload URL Path',0,'',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER18','DataTransfer','Download URL Path',0,'',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER19','DataTransfer','Server Webservice Path',0,'',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER20','DataTransfer','Archive In Folder HTTP',0,'',0,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER21','DataTransfer','Archive Out Folder HTTP',0,'',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER22','DataTransfer','No of Days for Deleting Archiving HTTP',0,'',30,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER23','DataTransfer','Error Log Folder Ftp',0,'',0,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER24','DataTransfer','FileFormatSelection Email',0,'',0,24)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER25','DataTransfer','Zip the file while sending Email',0,'',0,25)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER26','DataTransfer','POP3 Server Username',0,'',0,26)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER27','DataTransfer','POP3 Server Password',0,'',0,27)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER28','DataTransfer','From Email ID',0,'',0,28)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER29','DataTransfer','Allow Automatic Deployment',1,'',0,29)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER30','DataTransfer','Dowload files from',2,'',0,30)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER31','DataTransfer','Server Path',0,'http://bsipl146/BLTest/',0,31)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER32','DataTransfer','Deployment Server Path',0,'LATEST_RELEASE/',0,32)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER33','DataTransfer','User Name',0,'',0,33)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER34','DataTransfer','Password',0,'',0,34)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER35','DataTransfer','Updates Folder',0,'c:\Program Files\Core Stocky\BL NewRelease',0,35)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER36','DataTransfer','LAN Server Path',0,'\\CHITRA\SQLEXPRESS',0,36)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER37','DataTransfer','Deploy Error Log Folder',0,'c:\Program Files\Core Stocky\BL DeployErrorLog',0,37)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER38','DataTransfer','Out Master',0,'OUT_MAST/',0,38)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER39','DataTransfer','Out Trans',0,'OUT_TRANS/',0,39)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN18','Sales Return','Allow Editing Selling Rate > MRP',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG14','General Configuration','Coin',1,'Paise',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS1','Day End Process','Allow Modification of Pending Bills up to',1,'3',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS2','Day End Process','Block the user to perform transaction if day end is not done for',0,'0',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS3','Day End Process','Perform automatic delivery of pending Bills with Day End',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT20','BillConfig_RateEdit','Add the difference amount to Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT31','BillConfig_RateEdit','Recalculate Selling rate based on edited Net Rate',0,'',0,31)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT21','BillConfig_RateEdit','Make reason as mandatory if the user is adding the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT22','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT23','BillConfig_RateEdit','Add the difference amount to Gross Profit',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT24','BillConfig_RateEdit','Treat the difference amount in Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS4','Day End Process','Perform automatic delivery of pending Bills after',1,'3',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS5','Day End Process','Perform automatic delivery of pending Bills  while extracting data',0,'0',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS6','Day End Process','Allow Automatic Delivery',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT30','BillConfig_RateEdit','Recalculate Selling rate based on edited Net Rate',0,'',0,30)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT25','BillConfig_RateEdit','Allow Editing Selling Rate > MRP',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD17','BillConfig_Display','Enable DC Option in Billing',0,'',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD18','BillConfig_Display','Display total saleable quantity in product hotsearch',0,'',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeAutoBatchTransfer','Product Batch Download','Transfer Stock Automatically from old batch to new batch on new batch download',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RETREP2','RetReplacement','Allow user to save Replacement without Return Product',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER40','DataTransfer','WebService',0,'CoreStockyWS/CoreStocky',0,40)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG15','General Configuration','Currency Display Format',1,'0',0,15)
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[MultiUserTransValidation]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
	CREATE TABLE [dbo].[MultiUserTransValidation]
	(
		[UserId] [int] NOT NULL,
		[UserName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TransId] [int] NOT NULL,
		[TransName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LockedDate] [datetime] NOT NULL
	) ON [PRIMARY]
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplate_CrDbAdjustment]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplate_CrDbAdjustment]
GO
CREATE TABLE RptBillTemplate_CrDbAdjustment ( 
	[SalId] [int]  NULL ,
	[SalInvNo] [nvarchar]  NULL ,
	[NoteNumber] [nvarchar]  NULL ,
	[Amount] [numeric]  NULL ,
	[PreviousAmount] [numeric]  NULL ,
	[CrDbRemarks] [nvarchar]  NULL ,
	[UsrId] [int]  NULL 
) ON [PRIMARY]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplate_Scheme]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplate_Scheme]
GO
CREATE TABLE RptBillTemplate_Scheme ( 
	[SalId] [int]  NULL ,
	[SalInvNo] [nvarchar]  NULL ,
	[SchId] [int]  NULL ,
	[SchType] [nvarchar]  NULL ,
	[CmpSchCode] [nvarchar]  NULL ,
	[SchCode] [nvarchar]  NULL ,
	[SchName] [nvarchar]  NULL ,
	[PrdId] [int]  NULL ,
	[PrdCCode] [nvarchar]  NULL ,
	[PrdDCode] [nvarchar]  NULL ,
	[PrdShrtName] [nvarchar]  NULL ,
	[PrdName] [nvarchar]  NULL ,
	[PrdBatId] [int]  NULL ,
	[PrdBatCode] [nvarchar]  NULL ,
	[Qty] [numeric]  NULL ,
	[Rate] [numeric]  NULL ,
	[SchemeValueInAmt] [numeric]  NULL ,
	[SchemeValueInPoints] [numeric]  NULL ,
	[SalInvSchemevalue] [numeric]  NULL ,
	[SchemeCumulativePoints] [numeric]  NULL ,
	[UsrId] [int]  NULL 
) ON [PRIMARY]
GO
--SRF-Nanda-262-002

DELETE FROM Configuration WHERE ModuleId ='BotreeMultiUser'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('BotreeMultiUser','BotreeMultiUser','Enable Multi User Validation',1,'',0.00,1)

GO

-- Prepared by Boopthy on 25-08-2011 for bill Print Issue
-- Removed Userid mapping for supreports on 30-08-2011
-- UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'RptSELECTedBills') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
DROP TABLE RptSELECTedBills
CREATE TABLE RptSELECTedBills
(
	SalId	BIGINT,
	UsrId	INT
)
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBTBillTemplate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBTBillTemplate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_RptBTBillTemplate]
(
	@Pi_UsrId Int = 1,
	@Pi_Type INT,
	@Pi_InvDC INT
)
AS
/*********************************
* PROCEDURE		: Proc_RptBTBillTemplate
* PURPOSE		: To Get the Bill Details 
* CREATED		: Nandakumar R.G
* CREATED DATE	: 29/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FROMBillId AS  VARCHAR(25)
	DECLARE @ToBillId   AS  VARCHAR(25)
	DECLARE @Cnt AS INT

	--->Added By Nanda on 2011/09/19
	DECLARE @FromDate	AS DATETIME
	DECLARE @ToDate		AS DATETIME

	SELECT @FromDate=FilterDate FROM ReportFilterDt (NOLOCK) WHERE SelId=10 AND UsrId=@Pi_UsrId AND RptId=16
	SELECT @ToDate=FilterDate FROM ReportFilterDt (NOLOCK) WHERE SelId=11 AND UsrId=@Pi_UsrId AND RptId=16
	--->Till Here

	DECLARE @TempSalId TABLE
	(
		SalId	INT,
		UsrId	INT
	)
	DECLARE  @RptBillTemplate Table
	(
		[Base Qty] numeric(38,0),
		[Batch Code] nvarchar(50),
		[Batch Expiry Date] datetime,
		[Batch Manufacturing Date] datetime,
		[Batch MRP] numeric(38,2),
		[Batch Selling Rate] numeric(38,2),
		[Bill Date] datetime,
		[Bill Doc Ref. Number] nvarchar(50),
		[Bill Mode] tinyint,
		[Bill Type] tinyint,
		[CD Disc Base Qty Amount] numeric(38,2),
		[CD Disc Effect Amount] numeric(38,2),
		[CD Disc Header Amount] numeric(38,2),
		[CD Disc LineUnit Amount] numeric(38,2),
		[CD Disc Qty Percentage] numeric(38,2),
		[CD Disc Unit Percentage] numeric(38,2),
		[CD Disc UOM Amount] numeric(38,2),
		[CD Disc UOM Percentage] numeric(38,2),
		[Company Address1] nvarchar(50),
		[Company Address2] nvarchar(50),
		[Company Address3] nvarchar(50),
		[Company Code] nvarchar(20),
		[Company Contact Person] nvarchar(100),
		[Company EmailId] nvarchar(50),
		[Company Fax Number] nvarchar(50),
		[Company Name] nvarchar(100),
		[Company Phone Number] nvarchar(50),
		[Contact Person] nvarchar(50),
		[CST Number] nvarchar(50),
		[DB Disc Base Qty Amount] numeric(38,2),
		[DB Disc Effect Amount] numeric(38,2),
		[DB Disc Header Amount] numeric(38,2),
		[DB Disc LineUnit Amount] numeric(38,2),
		[DB Disc Qty Percentage] numeric(38,2),
		[DB Disc Unit Percentage] numeric(38,2),
		[DB Disc UOM Amount] numeric(38,2),
		[DB Disc UOM Percentage] numeric(38,2),
		[DC DATE] DATETIME,
		[DC NUMBER] nvarchar(100),
		[Delivery Boy] nvarchar(50),
		[Delivery Date] datetime,
		[Deposit Amount] numeric(38,2),
		[Distributor Address1] nvarchar(50),
		[Distributor Address2] nvarchar(50),
		[Distributor Address3] nvarchar(50),
		[Distributor Code] nvarchar(20),
		[Distributor Name] nvarchar(50),
		[Drug Batch Description] nvarchar(50),
		[Drug Licence Number 1] nvarchar(50),
		[Drug Licence Number 2] nvarchar(50),
		[Drug1 Expiry Date] DateTime,
		[Drug2 Expiry Date] DateTime,
		[EAN Code] varchar(50),
		[EmailID] nvarchar(50),
		[Geo Level] nvarchar(50),
		[Interim Sales] tinyint,
		[Licence Number] nvarchar(50),
		[Line Base Qty Amount] numeric(38,2),
		[Line Base Qty Percentage] numeric(38,2),
		[Line Effect Amount] numeric(38,2),
		[Line Unit Amount] numeric(38,2),
		[Line Unit Percentage] numeric(38,2),
		[Line UOM1 Amount] numeric(38,2),
		[Line UOM1 Percentage] numeric(38,2),
		[LST Number] nvarchar(50),
		[Manual Free Qty] int,
		[Order Date] datetime,
		[Order Number] nvarchar(50),
		[Pesticide Expiry Date] DateTime,
		[Pesticide Licence Number] nvarchar(50),
		[PhoneNo] nvarchar(50),
		[PinCode] int,
		[Product Code] nvarchar(50),
		[Product Name] nvarchar(200),
		[Product Short Name] nvarchar(100),
		[Product SL No] Int,
		[Product Type] int,
		[Remarks] nvarchar(200),
		[Retailer Address1] nvarchar(100),
		[Retailer Address2] nvarchar(100),
		[Retailer Address3] nvarchar(100),
		[Retailer Code] nvarchar(50),
		[Retailer ContactPerson] nvarchar(100),
		[Retailer Coverage Mode] tinyint,
		[Retailer Credit Bills] int,
		[Retailer Credit Days] int,
		[Retailer Credit Limit] numeric(38,2),
		[Retailer CSTNo] nvarchar(50),
		[Retailer Deposit Amount] numeric(38,2),
		[Retailer Drug ExpiryDate] datetime,
		[Retailer Drug License No] nvarchar(50),
		[Retailer EmailId] nvarchar(100),
		[Retailer GeoLevel] nvarchar(50),
		[Retailer License ExpiryDate] datetime,
		[Retailer License No] nvarchar(50),
		[Retailer Name] nvarchar(150),
		[Retailer OffPhone1] nvarchar(50),
		[Retailer OffPhone2] nvarchar(50),
		[Retailer OnAccount] numeric(38,2),
		[Retailer Pestcide ExpiryDate] datetime,
		[Retailer Pestcide LicNo] nvarchar(50),
		[Retailer PhoneNo] nvarchar(50),
		[Retailer Pin Code] nvarchar(50),
		[Retailer ResPhone1] nvarchar(50),
		[Retailer ResPhone2] nvarchar(50),
		[Retailer Ship Address1] nvarchar(100),
		[Retailer Ship Address2] nvarchar(100),
		[Retailer Ship Address3] nvarchar(100),
		[Retailer ShipId] int,
		[Retailer TaxType] tinyint,
		[Retailer TINNo] nvarchar(50),
		[Retailer Village] nvarchar(100),
		[Route Code] nvarchar(50),
		[Route Name] nvarchar(50),
		[Sales Invoice Number] nvarchar(50),
		[SalesInvoice ActNetRateAmount] numeric(38,2),
		[SalesInvoice CDPer] numeric(9,6),
		[SalesInvoice CRAdjAmount] numeric(38,2),
		[SalesInvoice DBAdjAmount] numeric(38,2),
		[SalesInvoice GrossAmount] numeric(38,2),
		[SalesInvoice Line Gross Amount] numeric(38,2),
		[SalesInvoice Line Net Amount] numeric(38,2),
		[SalesInvoice MarketRetAmount] numeric(38,2),
		[SalesInvoice NetAmount] numeric(38,2),
		[SalesInvoice NetRateDiffAmount] numeric(38,2),
		[SalesInvoice OnAccountAmount] numeric(38,2),
		[SalesInvoice OtherCharges] numeric(38,2),
		[SalesInvoice RateDiffAmount] numeric(38,2),
		[SalesInvoice ReplacementDiffAmount] numeric(38,2),
		[SalesInvoice RoundOffAmt] numeric(38,2),
		[SalesInvoice TotalAddition] numeric(38,2),
		[SalesInvoice TotalDeduction] numeric(38,2),
		[SalesInvoice WindowDisplayAmount] numeric(38,2),
		[SalesMan Code] nvarchar(50),
		[SalesMan Name] nvarchar(50),
		[SalId] int,
		[Sch Disc Base Qty Amount] numeric(38,2),
		[Sch Disc Effect Amount] numeric(38,2),
		[Sch Disc Header Amount] numeric(38,2),
		[Sch Disc LineUnit Amount] numeric(38,2),
		[Sch Disc Qty Percentage] numeric(38,2),
		[Sch Disc Unit Percentage] numeric(38,2),
		[Sch Disc UOM Amount] numeric(38,2),
		[Sch Disc UOM Percentage] numeric(38,2),
		[Scheme Points] numeric(38,2),
		[Spl. Disc Base Qty Amount] numeric(38,2),
		[Spl. Disc Effect Amount] numeric(38,2),
		[Spl. Disc Header Amount] numeric(38,2),
		[Spl. Disc LineUnit Amount] numeric(38,2),
		[Spl. Disc Qty Percentage] numeric(38,2),
		[Spl. Disc Unit Percentage] numeric(38,2),
		[Spl. Disc UOM Amount] numeric(38,2),
		[Spl. Disc UOM Percentage] numeric(38,2),
		[Tax 1] numeric(38,2),
		[Tax 2] numeric(38,2),
		[Tax 3] numeric(38,2),
		[Tax 4] numeric(38,2),
		[Tax Amount1] numeric(38,2),
		[Tax Amount2] numeric(38,2),
		[Tax Amount3] numeric(38,2),
		[Tax Amount4] numeric(38,2),
		[Tax Amt Base Qty Amount] numeric(38,2),
		[Tax Amt Effect Amount] numeric(38,2),
		[Tax Amt Header Amount] numeric(38,2),
		[Tax Amt LineUnit Amount] numeric(38,2),
		[Tax Amt Qty Percentage] numeric(38,2),
		[Tax Amt Unit Percentage] numeric(38,2),
		[Tax Amt UOM Amount] numeric(38,2),
		[Tax Amt UOM Percentage] numeric(38,2),
		[Tax Type] tinyint,
		[TIN Number] nvarchar(50),
		[Uom 1 Desc] nvarchar(50),
		[Uom 1 Qty] int,
		[Uom 2 Desc] nvarchar(50),
		[Uom 2 Qty] int,
		[Vehicle Name] nvarchar(50),
		UsrId int,
		Visibility tinyint
	)
	IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplate]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
	DROP TABLE [RptBillTemplate]

	DELETE FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId
	IF @Pi_Type=1
	BEGIN
		--->Modified By Nanda on 2011/09/19
		INSERT INTO @TempSalId
		/* Added Distinct Shyam-Boopathy 24082011 16:*/
		--SELECT Distinct SelValue,UsrId FROM ReportFilterDt WHERE RptId = 16 AND SelId = 34 AND UsrId=@Pi_UsrId

		SELECT DISTINCT R.SelValue,UsrId FROM ReportFilterDt R (NOLOCK),SalesInvoice SI (NOLOCK)
		WHERE RptId = 16 AND SelId = 34  AND UsrId=@Pi_UsrId AND R.SelValue=Si.SalId AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
		--->Till Here

		INSERT INTO RptSELECTedBills
		SELECT SalId,UsrId FROM @TempSalId
	END
	ELSE
	BEGIN
		IF @Pi_InvDC=1
		BEGIN
			DECLARE @FROMId INT
			DECLARE @ToId INT
			DECLARE @FROMSeq INT
			DECLARE @ToSeq INT
			SELECT @FROMId=SelValue FROM ReportFilterDt (NOLOCK) WHERE RptId=16 AND SelId=14 AND UsrId=@Pi_UsrId
			SELECT @ToId=SelValue FROM ReportFilterDt (NOLOCK) WHERE RptId=16 AND SelId=15 AND UsrId=@Pi_UsrId
			SELECT @FROMSeq=SeqNo FROM SalInvoiceDeliveryChallan (NOLOCK) WHERE SalId=@FROMId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan (NOLOCK) WHERE SalId=@ToId
			
			INSERT INTO RptSELECTedBills
/* Added Distinct Shyam-Boopathy 24082011 16:*/

			SELECT Distinct SalId,@Pi_UsrId FROM SalInvoiceDeliveryChallan (NOLOCK) WHERE SeqNo BETWEEN @FROMSeq AND @ToSeq
		END
		ELSE
		BEGIN
			SELECT @FROMBillId=SelValue FROM ReportFilterDt (NOLOCK) WHERE RptId = 16 AND SelId = 14 AND UsrId=@Pi_UsrId
			SELECT @ToBillId=SelValue FROM ReportFilterDt (NOLOCK) WHERE RptId = 16 AND SelId = 15 AND UsrId=@Pi_UsrId
			INSERT INTO RptSELECTedBills
/* Added Distinct Shyam-Boopathy 24082011 16:*/

			SELECT Distinct SalId,@Pi_UsrId FROM SalesINvoice (NOLOCK) WHERE SalId BETWEEN @FROMBillId AND @ToBillId
		END
	END
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,
		[CD Disc_Amount_Dt],[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],
		[CD Disc_UomPerc_Dt],Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,
		[DB Disc_Amount_Dt],[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],
		[DB Disc_UomPerc_Dt],DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,
		DistributorName,DrugBatchDesc,DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,
		LineBaseQtyAmount,LineBaseQtyPerc,LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,
		OrderKeyNo,PestExpiryDate,PestLicNo,PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,
		RtrContactPerson,RtrCovMode,RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,
		GeoLevelName,RtrLicExpiryDate,RtrLicNo,RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,
		RtrResPhone1,RtrResPhone2,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,
		SalActNetRateAmount,SalCDPer,CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,
		SalNetRateDiffAmount,OnAccountAmount,OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,
		WindowDisplayamount,SMCode,SMName,SalId,[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],
		[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],
		[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],
		Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],
		[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,
		Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,
						SalRateDiffAmount,SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,
						Replacementdiffamount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
						SalRoundOffAmt,V.VehicleId,V.VehicleCode,D.DlvBoyId , D.DlvBoyName FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,
						R.RtrCrLimit,R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,
						GL.GeoLevelName,RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2 , R.RtrOffPhone1, R.RtrOffPhone2, R.RtrOnAcc FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK) WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,BPT.Tax3Perc,
							BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId AND BPT.UsrId=@Pi_UsrId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId AND LW.SchId = PO.SchId AND
								--LW.SlabId = PO.SlabId
								LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId 
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId) 
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
--							'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
							'0' UOM2,'0' Uom2Qty,SUM(SIP.FreeQty) BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
							GROUP BY SIP.SalId,SIP.FreePrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.FreePriceId
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
--							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SUM(SIP.GiftQty) AS BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
							GROUP BY SIP.SalId,SIP.GiftPrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.GiftPriceId
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt] 
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
					AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
						) MRP
						LEFT OUTER JOIN
						(
						SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
						FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
						WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId
						AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM @TempSalId)
	END
	ELSE
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,[CD Disc_Amount_Dt],
		[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],[CD Disc_UomPerc_Dt],
		Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,[DB Disc_Amount_Dt],
		[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],[DB Disc_UomPerc_Dt],
		DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,DistributorName,DrugBatchDesc,
		DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,LineBaseQtyAmount,LineBaseQtyPerc,
		LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,OrderKeyNo,PestExpiryDate,PestLicNo,
		PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,RtrContactPerson,RtrCovMode,
		RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,GeoLevelName,RtrLicExpiryDate,RtrLicNo,
		RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,RtrResPhone1,RtrResPhone2,
		RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,SalActNetRateAmount,SalCDPer,
		CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,SalNetRateDiffAmount,OnAccountAmount,
		OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,SalId,
		[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],
		[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],
		[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,
		Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],
		[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,SalRateDiffAmount,
						SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,Replacementdiffamount,
						TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,SalRoundOffAmt,V.VehicleId,V.VehicleCode,
						D.DlvBoyId,D.DlvBoyName
						FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,R.RtrCrLimit,
						R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,GL.GeoLevelName,
						RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrOnAcc
						FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK)
						WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,
						C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,
							P.PrdName,P.PrdShrtName,P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,
							BPT.Tax3Perc,BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId AND BPT.UsrId=@Pi_UsrId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId) 
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1 AND
					SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
						) MRP
						LEFT OUTER JOIN
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
							FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
						) SelRtr ON MRP.PrdId = SelRtr.PrdId
						AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
	END
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[RptBTBillTemplate]')
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
--	DROP TABLE [RptBTBillTemplate]
	BEGIN
		DELETE FROM RptBTBillTemplate WHERE UsrId=@Pi_UsrId
		INSERT INTO RptBTBillTemplate
		SELECT DISTINCT *  FROM @RptBillTemplate WHERE UsrId=@Pi_UsrId
	END
	ELSE
	BEGIN
		SELECT DISTINCT * INTO RptBTBillTemplate FROM @RptBillTemplate WHERE UsrId=@Pi_UsrId
	END
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_BillPrintingTax')
DROP PROCEDURE Proc_BillPrintingTax
GO
--EXEC Proc_BillPrintingTax 2,1,1000
CREATE PROCEDURE [dbo].[Proc_BillPrintingTax] 
(
	@Pi_UsrId		INT,
	@Pi_FromBillNo	INT,
	@Pi_ToBillNo	INT
)
AS 
SET NOCOUNT ON
/***************************************************************************************************
* PROCEDURE		: Proc_BillPrintingTax
* PURPOSE		: General Procedure get the tax details 
* NOTES			:
* CREATED		: Nandakumar R.G
* CREATED ON	: 12/11/2010
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
*UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
****************************************************************************************************/
BEGIN
	DECLARE @TaxId	AS INT	
	DECLARE @iIdx	AS INT
	DECLARE @sSql	AS NVARCHAR(4000)

	SELECT @Pi_FromBillNo=MIN(SalId) FROM RptSelectedBills (NOLOCK) WHERE UsrId = @Pi_UsrId
	SELECT @Pi_ToBillNo=MAX(SalId) FROM RptSelectedBills (NOLOCK) WHERE UsrId = @Pi_UsrId

	DELETE FROM BillPrintTaxTemp WHERE UsrId=@Pi_UsrId	  

	INSERT INTO BillPrintTaxTemp(SalId,PrdId,PrdCode,PrdBatId,BatchCode,Tax1Id,Tax2Id,Tax3Id,Tax4Id,Tax5Id,
	Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax5Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,Tax5Amount,UsrId)	
	SELECT	SIP.SalId,SIP.PrdId,P.PrdCCode,SIP.PrdBatId,PB.PrdBatCode,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@Pi_UsrId
	FROM SalesInvoiceProduct SIP (NOLOCK)
	INNER JOIN Product P  (NOLOCK) ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK)  ON PB.PrdBatId=SIP.PrdBatId AND P.PrdId=PB.PrdId
	WHERE SIP.SalId BETWEEN @Pi_FromBillNo AND @Pi_ToBillNo 	 
	ORDER BY SIP.SalId,SIP.PrdId,SIP.PrdBatId
	
	SELECT	SIP.SalId,SIP.PrdId,P.PrdCCode,SIP.PrdBatId,PB.PrdBatCode,ISNULL(SIPT.TaxId,0) AS TaxId,
	ISNULL(SIPT.TaxPerc,0) AS TaxPerc,ISNULL(SIPT.TaxAmount,0) AS TaxAmount,@Pi_UsrId As UsrId
	INTO #SalesTaxDetails
	FROM SalesInvoiceProduct SIP (NOLOCK) 
	INNER JOIN Product P  (NOLOCK) ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB  (NOLOCK) ON PB.PrdBatId=SIP.PrdBatId AND P.PrdId=PB.PrdId
	LEFT OUTER JOIN SalesInvoiceProductTax SIPT  (NOLOCK) ON SIP.SlNo=SIPT.PrdSlNo AND SIP.SalId=SIPT.SalId 	
	WHERE SIP.SalId BETWEEN @Pi_FromBillNo AND @Pi_ToBillNo
	AND ISNULL(SIPT.TaxPerc,0)+ISNULL(SIPT.TaxAmount,0)>0
	ORDER BY SIP.SalId,SIP.PrdId,SIP.PrdBatId,SIPT.TaxId
	
	SET @iIdx=1
	DECLARE Cur_Tax CURSOR FOR
	SELECT DISTINCT TaxId FROM #SalesTaxDetails  WHERE UsrId = @Pi_UsrId ORDER BY TaxId
	OPEN Cur_Tax
	FETCH NEXT FROM Cur_Tax INTO @TaxId
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT @iIdx>5
		BEGIN
			SET @sSql='UPDATE BPT SET BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id=ST.TaxId,
					   BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc=ST.TaxPerc,
					   BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount=ST.TaxAmount
					   FROM BillPrintTaxTemp BPT,
					   (
				    		SELECT SalId,PrdId,PrdCCode,PrdBatId,PrdBatCode,TaxId,TaxPerc,TaxAmount
							FROM #SalesTaxDetails WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND TaxId='+CAST(@TaxId AS NVARCHAR(10))+'			
					   )ST
					   WHERE BPT.UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND BPT.SalId=ST.SalId AND BPT.PrdId=ST.PrdId AND BPT.PrdBatId=ST.PrdBatId' 
			EXEC (@sSql)
			IF @iIdx>1
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount=0
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id'
				EXEC (@sSql)
			END
			IF @iIdx>2
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount=0
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id'
				EXEC (@sSql)
			END
			IF @iIdx>3
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount=0
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id'
				EXEC (@sSql)
			END
			IF @iIdx>4
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount=0
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id'
				EXEC (@sSql)
			END
		END
		SET @iIdx=@iIdx+1
		FETCH NEXT FROM Cur_Tax INTO @TaxId
	END
	CLOSE Cur_Tax
	DEALLOCATE Cur_Tax
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptReportToBill')
DROP PROCEDURE Proc_RptReportToBill
GO
-- EXEC Proc_RptReportToBill 2,16,0,1
CREATE PROCEDURE [dbo].[Proc_RptReportToBill]
(
	@Pi_UsrId INT,
	@Pi_RptId INT,
	@Pi_Sel INT,
	@Pi_InvDC INT
)
AS
/***************************************************************************************************
* PROCEDURE: Proc_RptReportToBill
* PURPOSE: General Procedure
* NOTES:
* CREATED: Nanda	 
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
* 01.10.2009		Panneer	   Checked in Invoice Type Condition
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	--Filter Variable
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SelBillNo  AS  BIGINT
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	--Assgin Value for the Filter Variable
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @FromBillNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SelBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId))
	SET @FromDate =(SELECT  TOP 1 dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	IF @Pi_Sel = 1
	BEGIN
		 SELECT @FromBillNo = Min(SalId) FROM SalesInvoice (NOLOCK) 
		 SELECT @ToBillNo = Max(SalId) FROM SalesInvoice (NOLOCK) 
	END

	DELETE from RptBillToPrint where [UsrId] = @Pi_UsrId

	IF @Pi_InvDC=2
	BEGIN	
		INSERT INTO  RptBillToPrint
		SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice (NOLOCK) 
		WHERE
		 (SalId=(CASE @SelBillNo WHEN 0 THEN SalId ELSE 0 END) OR
							SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
		AND
		 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND
		 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
		AND (SalId BETWEEN @FromBillNo AND @ToBillNo)
		AND (SalInvDate BETWEEN @FromDate AND @ToDate)
		AND InvType=0
	END
	ELSE
	BEGIN
		--->Added By Nanda on 24/09/2009
		IF @Pi_Sel = 0
		BEGIN

			DECLARE @FromId INT
			DECLARE @ToId INT
			DECLARE @StartBill AS nvarchar(100)
			DECLARE @EndBill AS nvarchar(500)
			DECLARE @FromSeq INT
			DECLARE @ToSeq INT
			SELECT @FromId=SelValue FROM ReportFilterDt  (NOLOCK) WHERE RptId=16 AND SelId=14 AND UsrId = @Pi_UsrId
			SELECT @ToId=SelValue FROM ReportFilterDt  (NOLOCK) WHERE RptId=16 AND SelId=15 AND UsrId = @Pi_UsrId
			
			PRINT @FromId
			PRINT @ToId
			
			SELECT  @StartBill= SalInvno FROM SalesInvoice  (NOLOCK) WHERE SalId=@FromId
			SELECT  @EndBill=	SalInvno FROM SalesInvoice (NOLOCK)  WHERE SalId=@ToId		
			SELECT @FromSeq=SeqNo FROM SalInvoiceDeliveryChallan  (NOLOCK) WHERE SalId=@FromId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan  (NOLOCK) WHERE SalId=@ToId	
		
			INSERT INTO  RptBillToPrint		
			SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice (NOLOCK) 
			WHERE
			 (SalId IN (SELECT SalId FROM SalesInvoice  (NOLOCK) WHERE SalId BETWEEN @FromId AND @ToId))	
			AND
			 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND
			 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
								RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
								DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
			AND (SalInvDate BETWEEN @FromDate AND @ToDate)
			AND InvType=1			
		END
		ELSE--->Till Here
		BEGIN
			INSERT INTO  RptBillToPrint		
			SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice (NOLOCK) 
			WHERE
			 (SalId=(CASE @SelBillNo WHEN 0 THEN SalId ELSE 0 END) OR
								SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
			AND
			 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND
			 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
								RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
								DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
			AND (SalId BETWEEN @FromBillNo AND @ToBillNo)
			AND (SalInvDate BETWEEN @FromDate AND @ToDate)
			AND InvType=1
		END
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL_BILLTEMPLATE'
CREATE PROCEDURE [dbo].[Proc_RptBillTemplateFinal]
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
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
* Removed Userid mapping for supreports on 30-08-2011 By Boopathy.P
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
	SELECT @DeliveredBill=Status FROM  Configuration  (NOLOCK) WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'
	IF @DeliveredBill=1
	BEGIN		
		DELETE FROM RptBillToPrint WHERE [Bill Number] IN(
		SELECT SalInvNo FROM SalesInvoice  (NOLOCK) WHERE DlvSts NOT IN(4,5))  AND UsrId=@Pi_UsrId
	END
	--Till Here
	--Added By Murugan 04/09/2009
	SET @FieldCount=0
	SELECT @UomStatus=Isnull(Status,0) FROM configuration  (NOLOCK)  WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22
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
		if len(@FieldTypeList) > 3000
		begin
			Set @FieldTypeList2 = @FieldTypeList
			Set @FieldTypeList = ''
		end
		--->Added By Nanda on 12/03/2010
		IF LEN(@FieldList)>3000
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
		FOR SELECT UOMID,UOMCODE FROM UOMMASTER  (NOLOCK)  Order BY UOMID
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
			'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND T.UsrId='+@Pi_UsrId)
		END
		ELSE
		BEGIN
			--SELECT 'Nanda002'	
			Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +
			'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND  T.UsrId='+ @Pi_UsrId)
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +
				'(' + @TblFields + ')' +
			' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + '  (NOLOCK) Where UsrId = ' +  CAST(@Pi_UsrId AS VARCHAR(10))
		
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
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
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
		AND [RptBillTemplateFinal].[Batch Code] =ProductBatch.[PrdBatCode] AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
--- End Sl No
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
	---------------------------------TAX (SubReport)
	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI  (NOLOCK) , TaxConfiguration T (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
	End
	------------------------------ Other
	Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI (NOLOCK) ,PurSalAccConfig P (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
		AND B.UsrId = @Pi_UsrId
	End
	---------------------------------------Replacement
	Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H (NOLOCK) , ReplacementOut D (NOLOCK) , Product P (NOLOCK) , ProductBatch PB (NOLOCK) ,SalesInvoice SI (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
		AND B.UsrId = @Pi_UsrId
	End
	----------------------------------Credit Debit Adjus
	Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,UsrId)
		Select A.SalId,S.SalInvNo,CrNoteNumber,A.CrAdjAmount,@Pi_UsrId
		from SalInvCrNoteAdj A (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
		Union All
		Select A.SalId,S.SalInvNo,DbNoteNumber,A.DbAdjAmount,@Pi_UsrId
		from SalInvDbNoteAdj A (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number]AND B.UsrId = @Pi_UsrId
	End
	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId)
		Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId
		From ReturnHeader H (NOLOCK) ,ReturnProduct D (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		Where returntype = 1
		and H.ReturnID = D.ReturnID
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId
		From ReturnPrdHdForScheme D (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) ,ReturnHeader H (NOLOCK) ,ReturnProduct T (NOLOCK) 
		WHERE returntype = 1 AND
		D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = T.SalId
		and H.ReturnID = T.ReturnID
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
	End
	------------------------------ SampleIssue
	Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
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
		WHERE I.UsrId = @Pi_UsrId
	End
	--->Added By Nanda on 10/03/2010
	------------------------------ Scheme
	Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,18,LEN(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeLineWise SISL (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) 
		WHERE SISL.SchId=SM.SchId AND SI.SalId=SISL.SalId AND RBT.[Bill Number]=SI.SalInvNo AND RBT.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc
		HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,
		ProductBatchDetails PBD (NOLOCK) ,BatchCreation BC (NOLOCK) 
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.FreePrdId=P.PrdId AND SISFP.FreePrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND RBT.UsrId = @Pi_UsrId

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,
		ProductBatchDetails PBD (NOLOCK) ,BatchCreation BC (NOLOCK) 
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.GiftPrdId=P.PrdId AND SISFP.GiftPrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND RBT.UsrId = @Pi_UsrId

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SIWD.AdjAmt),0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceWindowDisplay SIWD (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) 
		WHERE SIWD.SchId=SM.SchId AND SI.SalId=SIWD.SalId AND RBT.[Bill Number]=SI.SalInvNo AND RBT.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc

		UPDATE RPT SET SalInvSchemevalue=A.SalInvSchemevalue
		FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemevalue FROM RptBillTemplate_Scheme WHERE UsrId = @Pi_UsrId GROUP BY SalId)A
		WHERE A.SAlId=RPT.SalId AND RPT.UsrId = @Pi_UsrId
	End
	--->Till Here	
	--->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products
	IF EXISTS(SELECT * FROM Configuration  (NOLOCK) WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
		DROP TABLE [RptBillTemplateFinal_Group]

		SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal  (NOLOCK) WHERE UsrId = @Pi_UsrId
		DELETE FROM RptBillTemplateFinal WHERE UsrId = @Pi_UsrId

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
			[UsrId],[Visibility],[AmtInWrd]
		)		
		SELECT DISTINCT
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
		[Uom 1 Desc] AS [Uom 1 Desc],SUM([Uom 1 Qty]) AS [Uom 1 Qty],'' AS [Uom 2 Desc],0 AS [Uom 2 Qty],[Vehicle Name],
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
		[UsrId],[Visibility],[AmtInWrd]
		FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK) 
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId
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
		[Uom 1 Desc],	
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
		[UsrId],[Visibility],[AmtInWrd]
		FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK) 
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId
	END	


--	SELECT * FROM RptBillTemplateFinal
--	SELECT * FROM SalesInvoiceProduct A INNER JOIN Product

	--->Till Here
	IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
				ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId)
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
		INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)
		SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
		ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId
	END
	ELSE
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
	END
	RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnIsBackDated]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnIsBackDated]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     FUNCTION [dbo].[Fn_ReturnIsBackDated]
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
*********************************/
BEGIN
	DECLARE @RetValue as INT
	SET @RetValue = 0
	IF @Pi_ScreenId = 26
	BEGIN
		SELECT @RetValue = COUNT(PurOrderRefNo) FROM PurchaseOrderMaster (NOLOCK)
			WHERE PurOrderDate > @Pi_TransDate
	END
	IF @Pi_ScreenId <> 39 AND @Pi_ScreenId <> 26
	BEGIN
		SELECT @RetValue = COUNT(Availability) FROM StockLedger(NOLOCK)
		WHERE TransDate > @Pi_TransDate	
	END
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
 		SELECT @RetValue = COUNT(PurOrderRefNo) FROM PurchaseOrderMaster (NOLOCK)
 			WHERE PurOrderDate > @Pi_TransDate
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL_BILLTEMPLATE'
CREATE PROCEDURE [dbo].[Proc_RptBillTemplateFinal]
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
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
* Removed Userid mapping for supreports on 30-08-2011 By Boopathy.P
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
	SELECT @DeliveredBill=Status FROM  Configuration  (NOLOCK) WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'
	IF @DeliveredBill=1
	BEGIN		
		DELETE FROM RptBillToPrint WHERE [Bill Number] IN(
		SELECT SalInvNo FROM SalesInvoice  (NOLOCK) WHERE DlvSts NOT IN(4,5))  AND UsrId=@Pi_UsrId
	END
	--Till Here
	--Added By Murugan 04/09/2009
	SET @FieldCount=0
	SELECT @UomStatus=Isnull(Status,0) FROM configuration  (NOLOCK)  WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22
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
		if len(@FieldTypeList) > 3000
		begin
			Set @FieldTypeList2 = @FieldTypeList
			Set @FieldTypeList = ''
		end
		--->Added By Nanda on 12/03/2010
		IF LEN(@FieldList)>3000
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
		FOR SELECT UOMID,UOMCODE FROM UOMMASTER  (NOLOCK)  Order BY UOMID
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
--	if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
--	drop table [RptBillTemplateFinal]
--	IF @UomStatus=1
--	BEGIN	
--		Exec('CREATE TABLE RptBillTemplateFinal
--		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')
--	END
--	ELSE
--	BEGIN
--		Exec('CREATE TABLE RptBillTemplateFinal
--		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500))')
--	END
	DELETE FROM RptBillTemplateFinal WHERE Usrid=@Pi_UsrId
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
			'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND T.UsrId='+@Pi_UsrId)
		END
		ELSE
		BEGIN
			--SELECT 'Nanda002'	
			Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +
			'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND  T.UsrId='+ @Pi_UsrId)
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +
				'(' + @TblFields + ')' +
			' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + '  (NOLOCK) Where UsrId = ' +  CAST(@Pi_UsrId AS VARCHAR(10))
		
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
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
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
		AND [RptBillTemplateFinal].[Batch Code] =ProductBatch.[PrdBatCode] AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
--- End Sl No
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
	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI  (NOLOCK) , TaxConfiguration T (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
	End
	------------------------------ Other
	Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI (NOLOCK) ,PurSalAccConfig P (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
		AND B.UsrId = @Pi_UsrId
	End
	---------------------------------------Replacement
	Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H (NOLOCK) , ReplacementOut D (NOLOCK) , Product P (NOLOCK) , ProductBatch PB (NOLOCK) ,SalesInvoice SI (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
		AND B.UsrId = @Pi_UsrId
	End
	----------------------------------Credit Debit Adjustment
	SELECT @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	IF @Sub_Val = 1
	BEGIN
		INSERT INTO RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		SELECT A.SalId,S.SalInvNo,A.CrNoteNumber,A.CrAdjAmount,A.AdjSoFar,CNR.Remarks,@Pi_UsrId
		FROM SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B,CreditNoteRetailer CNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND CNR.CrNoteNumber=A.CrNoteNumber  AND B.UsrId=@Pi_UsrId
		UNION ALL
		SELECT A.SalId,S.SalInvNo,A.DbNoteNumber,A.DbAdjAmount,A.AdjSoFar,DNR.Remarks,@Pi_UsrId
		FROM SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B,DebitNoteRetailer DNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND DNR.DbNoteNumber=A.DbNoteNumber AND B.UsrId=@Pi_UsrId
	END

	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId)
		Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId
		From ReturnHeader H (NOLOCK) ,ReturnProduct D (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		Where returntype = 1
		and H.ReturnID = D.ReturnID
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId
		From ReturnPrdHdForScheme D (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) ,ReturnHeader H (NOLOCK) ,ReturnProduct T (NOLOCK) 
		WHERE returntype = 1 AND
		D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = T.SalId
		and H.ReturnID = T.ReturnID
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
	End
	------------------------------ SampleIssue
	Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
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
		WHERE I.UsrId = @Pi_UsrId
	End
	--->Added By Nanda on 10/03/2010
	------------------------------ Scheme
	Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,19,LEN(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeLineWise SISL (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) 
		WHERE SISL.SchId=SM.SchId AND SI.SalId=SISL.SalId AND RBT.[Bill Number]=SI.SalInvNo AND RBT.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc
		HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,
		ProductBatchDetails PBD (NOLOCK) ,BatchCreation BC (NOLOCK) 
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.FreePrdId=P.PrdId AND SISFP.FreePrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND RBT.UsrId = @Pi_UsrId

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,
		ProductBatchDetails PBD (NOLOCK) ,BatchCreation BC (NOLOCK) 
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.GiftPrdId=P.PrdId AND SISFP.GiftPrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND RBT.UsrId = @Pi_UsrId

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SIWD.AdjAmt),0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceWindowDisplay SIWD (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) 
		WHERE SIWD.SchId=SM.SchId AND SI.SalId=SIWD.SalId AND RBT.[Bill Number]=SI.SalInvNo AND RBT.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc

		UPDATE RPT SET SalInvSchemevalue=A.SalInvSchemevalue
		FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemevalue FROM RptBillTemplate_Scheme WHERE UsrId = @Pi_UsrId GROUP BY SalId)A
		WHERE A.SAlId=RPT.SalId AND RPT.UsrId = @Pi_UsrId

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
	--->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products
	IF EXISTS(SELECT * FROM Configuration  (NOLOCK) WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
		DROP TABLE [RptBillTemplateFinal_Group]

		SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal  (NOLOCK) WHERE UsrId = @Pi_UsrId
		DELETE FROM RptBillTemplateFinal WHERE UsrId = @Pi_UsrId

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
			[UsrId],[Visibility],[AmtInWrd]
		)		
		SELECT DISTINCT
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
		[Uom 1 Desc] AS [Uom 1 Desc],SUM([Uom 1 Qty]) AS [Uom 1 Qty],'' AS [Uom 2 Desc],0 AS [Uom 2 Qty],[Vehicle Name],
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
		[UsrId],[Visibility],[AmtInWrd]
		FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK) 
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId
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
		[Uom 1 Desc],	
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
		[UsrId],[Visibility],[AmtInWrd]
		FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK) 
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId
	END	

--	UPDATE RptBillTemplateFinal SET Visibility=0 WHERE UsrId<>@Pi_UsrId


--	SELECT * FROM RptBillTemplateFinal
--	SELECT * FROM SalesInvoiceProduct A INNER JOIN Product

	--->Till Here
	IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
				ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId)
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
		INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)
		SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
		ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId
	END
	ELSE
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
	END
	RETURN
END
GO
IF EXISTS(SELECT * FROM SysObjects WHERE Name = 'RptBt_View_Final_BILLTEMPLATE' AND Xtype='V')
BEGIN
	IF EXISTS(SELECT * FROM SysObjects WHERE Name = 'RptBt_View_Final1_BILLTEMPLATE' AND Xtype='U')
	BEGIN
		DELETE FROM RptBt_View_Final1_BILLTEMPLATE
		INSERT INTO RptBt_View_Final1_BILLTEMPLATE
		SELECT * FROM RptBt_View_Final_BILLTEMPLATE
		DROP VIEW RptBt_View_Final_BILLTEMPLATE
	END
	ELSE
	BEGIN
		SELECT * INTO RptBt_View_Final1_BILLTEMPLATE FROM RptBt_View_Final_BILLTEMPLATE
		DROP VIEW RptBt_View_Final_BILLTEMPLATE
	END
END
GO
if not exists (select * from hotfixlog where fixid = 390)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(390,'D','2011-09-26',getdate(),1,'Core Stocky Service Pack 390')
GO