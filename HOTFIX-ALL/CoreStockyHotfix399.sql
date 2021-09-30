--[Stocky HotFix Version]=399
DELETE FROM Versioncontrol WHERE Hotfixid='399'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('399','2.0.0.5','D','2012-07-13','2012-07-13','2012-07-13',CONVERT(VARCHAR(11),GETDATE()),'PARLE-Major: Product Release Dec CR')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 399' ,'399'
GO
UPDATE CustomCaptions SET Caption='Circular No*' WHERE TransId=45 and CtrlName='lblBudgetAllco'
GO
UPDATE Configuration SET STATUS=1 WHERE ModuleId='GENCONFIG29' AND ModuleName='General Configuration'
GO
DELETE FROM Configuration WHERE ModuleName='Billing' aND ModuleId='Bill3'
INSERT INTO Configuration 
SELECT 'Bill3','Billing','Allow to Enter Distributor discount in % when discount type is in value',1,'',0.00,3
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='RptBTBillTemplate' AND XTYPE='U')
DROP TABLE RptBTBillTemplate
GO
CREATE TABLE RptBTBillTemplate
(
	[Base Qty] [numeric](38, 0) NULL,
	[Batch Code] [nvarchar](50) NULL,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](50) NULL,
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
	[Company Address1] [nvarchar](50) NULL,
	[Company Address2] [nvarchar](50) NULL,
	[Company Address3] [nvarchar](50) NULL,
	[Company Code] [nvarchar](20) NULL,
	[Company Contact Person] [nvarchar](100) NULL,
	[Company EmailId] [nvarchar](50) NULL,
	[Company Fax Number] [nvarchar](50) NULL,
	[Company Name] [nvarchar](100) NULL,
	[Company Phone Number] [nvarchar](50) NULL,
	[Contact Person] [nvarchar](50) NULL,
	[CST Number] [nvarchar](50) NULL,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](100) NULL,
	[Delivery Boy] [nvarchar](50) NULL,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](50) NULL,
	[Distributor Address2] [nvarchar](50) NULL,
	[Distributor Address3] [nvarchar](50) NULL,
	[Distributor Code] [nvarchar](20) NULL,
	[Distributor Name] [nvarchar](50) NULL,
	[Drug Batch Description] [nvarchar](50) NULL,
	[Drug Licence Number 1] [nvarchar](50) NULL,
	[Drug Licence Number 2] [nvarchar](50) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) NULL,
	[EmailID] [nvarchar](50) NULL,
	[Geo Level] [nvarchar](50) NULL,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](50) NULL,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](50) NULL,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](50) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](50) NULL,
	[PhoneNo] [nvarchar](50) NULL,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](50) NULL,
	[Product Name] [nvarchar](200) NULL,
	[Product Short Name] [nvarchar](100) NULL,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](200) NULL,
	[Retailer Address1] [nvarchar](100) NULL,
	[Retailer Address2] [nvarchar](100) NULL,
	[Retailer Address3] [nvarchar](100) NULL,
	[Retailer Code] [nvarchar](50) NULL,
	[Retailer ContactPerson] [nvarchar](100) NULL,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](50) NULL,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](50) NULL,
	[Retailer EmailId] [nvarchar](100) NULL,
	[Retailer GeoLevel] [nvarchar](50) NULL,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](50) NULL,
	[Retailer Name] [nvarchar](150) NULL,
	[Retailer OffPhone1] [nvarchar](50) NULL,
	[Retailer OffPhone2] [nvarchar](50) NULL,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](50) NULL,
	[Retailer PhoneNo] [nvarchar](50) NULL,
	[Retailer Pin Code] [nvarchar](50) NULL,
	[Retailer ResPhone1] [nvarchar](50) NULL,
	[Retailer ResPhone2] [nvarchar](50) NULL,
	[Retailer Ship Address1] [nvarchar](100) NULL,
	[Retailer Ship Address2] [nvarchar](100) NULL,
	[Retailer Ship Address3] [nvarchar](100) NULL,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](50) NULL,
	[Retailer Village] [nvarchar](100) NULL,
	[Route Code] [nvarchar](50) NULL,
	[Route Name] [nvarchar](50) NULL,
	[Sales Invoice Number] [nvarchar](50) NULL,
	[SalesInvoice ActNetRateAmount] [numeric](38, 2) NULL,
	[SalesInvoice CDPer] [numeric](9, 6) NULL,
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
	[SalesMan Code] [nvarchar](50) NULL,
	[SalesMan Name] [nvarchar](50) NULL,
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
	[TIN Number] [nvarchar](50) NULL,
	[Uom 1 Desc] [nvarchar](50) NULL,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](50) NULL,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](50) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[Distributor Product Code] nvarchar(50),
	[Allotment No] nvarchar(50),
	[Bx Selling Rate] numeric(18,2)
)  
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='RptBt_View_Final1_BILLTEMPLATE' AND XTYPE='U')
DROP TABLE RptBt_View_Final1_BILLTEMPLATE
GO
CREATE TABLE RptBt_View_Final1_BILLTEMPLATE
(
	[Base Qty] [numeric](38, 0) NULL,
	[Batch Code] [nvarchar](50) NULL,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](50) NULL,
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
	[Company Address1] [nvarchar](50) NULL,
	[Company Address2] [nvarchar](50) NULL,
	[Company Address3] [nvarchar](50) NULL,
	[Company Code] [nvarchar](20) NULL,
	[Company Contact Person] [nvarchar](100) NULL,
	[Company EmailId] [nvarchar](50) NULL,
	[Company Fax Number] [nvarchar](50) NULL,
	[Company Name] [nvarchar](100) NULL,
	[Company Phone Number] [nvarchar](50) NULL,
	[Contact Person] [nvarchar](50) NULL,
	[CST Number] [nvarchar](50) NULL,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](100) NULL,
	[Delivery Boy] [nvarchar](50) NULL,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](50) NULL,
	[Distributor Address2] [nvarchar](50) NULL,
	[Distributor Address3] [nvarchar](50) NULL,
	[Distributor Code] [nvarchar](20) NULL,
	[Distributor Name] [nvarchar](50) NULL,
	[Drug Batch Description] [nvarchar](50) NULL,
	[Drug Licence Number 1] [nvarchar](50) NULL,
	[Drug Licence Number 2] [nvarchar](50) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) NULL,
	[EmailID] [nvarchar](50) NULL,
	[Geo Level] [nvarchar](50) NULL,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](50) NULL,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](50) NULL,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](50) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](50) NULL,
	[PhoneNo] [nvarchar](50) NULL,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](50) NULL,
	[Product Name] [nvarchar](200) NULL,
	[Product Short Name] [nvarchar](100) NULL,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](200) NULL,
	[Retailer Address1] [nvarchar](100) NULL,
	[Retailer Address2] [nvarchar](100) NULL,
	[Retailer Address3] [nvarchar](100) NULL,
	[Retailer Code] [nvarchar](50) NULL,
	[Retailer ContactPerson] [nvarchar](100) NULL,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](50) NULL,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](50) NULL,
	[Retailer EmailId] [nvarchar](100) NULL,
	[Retailer GeoLevel] [nvarchar](50) NULL,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](50) NULL,
	[Retailer Name] [nvarchar](150) NULL,
	[Retailer OffPhone1] [nvarchar](50) NULL,
	[Retailer OffPhone2] [nvarchar](50) NULL,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](50) NULL,
	[Retailer PhoneNo] [nvarchar](50) NULL,
	[Retailer Pin Code] [nvarchar](50) NULL,
	[Retailer ResPhone1] [nvarchar](50) NULL,
	[Retailer ResPhone2] [nvarchar](50) NULL,
	[Retailer Ship Address1] [nvarchar](100) NULL,
	[Retailer Ship Address2] [nvarchar](100) NULL,
	[Retailer Ship Address3] [nvarchar](100) NULL,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](50) NULL,
	[Retailer Village] [nvarchar](100) NULL,
	[Route Code] [nvarchar](50) NULL,
	[Route Name] [nvarchar](50) NULL,
	[Sales Invoice Number] [nvarchar](50) NULL,
	[SalesInvoice ActNetRateAmount] [numeric](38, 2) NULL,
	[SalesInvoice CDPer] [numeric](9, 6) NULL,
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
	[SalesMan Code] [nvarchar](50) NULL,
	[SalesMan Name] [nvarchar](50) NULL,
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
	[TIN Number] [nvarchar](50) NULL,
	[Uom 1 Desc] [nvarchar](50) NULL,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](50) NULL,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](50) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[Distributor Product Code] nvarchar(50),
	[Allotment No] nvarchar(50),
	[Bx Selling Rate] numeric(18,2)
)  
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='RptBillTemplateFinal' AND XTYPE='U')
DROP TABLE RptBillTemplateFinal
GO
CREATE TABLE RptBillTemplateFinal
(
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
	[Distributor Product Code] nvarchar(50),
	[Allotment No] nvarchar(50),
	[Bx Selling Rate] numeric(18,2),
	[AmtInWrd] [nvarchar](500) NULL,
	[BX] [int] NULL,
	[PB] [int] NULL,
	[PKT] [int] NULL,
	[CN] [int] NULL,
	[GB] [int] NULL,
	[ROL] [int] NULL,
	[JAR] [int] NULL,
	[TOR] [int] NULL,
	[Product Weight] [numeric](38, 6) NULL,
	[Product UPC] [numeric](38, 6) NULL
)  
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='PROC_RPTBTBILLTEMPLATE' AND XTYPE='P')
DROP PROCEDURE  PROC_RPTBTBILLTEMPLATE
GO
--select * from Rptbilltemplatefinal
--Exec Proc_RptBTBillTemplate 1,1,2
CREATE PROCEDURE Proc_RptBTBillTemplate
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
* optimize the bill print generation by Boopathy on 02-11-2011
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
		Visibility tinyint,
		[Distributor Product Code] nvarchar(50),
		[Allotment No] nvarchar(50),
		[Bx Selling Rate] numeric(18,2)
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
		Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility,PrdDcode,'',0
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
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,PrdDcode,P.PrdName,P.PrdShrtName,
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
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,PrdDcode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
							'0' UOM2,'0' Uom2Qty,SUM(SIP.FreeQty) BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
							GROUP BY SIP.SalId,SIP.FreePrdId,P.PrdCCode,PrdDcode,P.PrdName,P.PrdShrtName,
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
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,PrdDcode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SUM(SIP.GiftQty) AS BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
							GROUP BY SIP.SalId,SIP.GiftPrdId,P.PrdCCode,PrdDcode,P.PrdName,P.PrdShrtName,
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
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
					AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT DISTINCT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT DISTINCT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
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
		OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,B.SalId,
		[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],
		[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],
		[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,
		Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],
		[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility,PrdDcode,'',0
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
					SELECT DISTINCT SalesInv.* , RtrDt.*,HDAmt.* FROM
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
						INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
						WHERE E.UsrId=@Pi_UsrId 
					) SalesInv
					INNER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,R.RtrCrLimit,
						R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,GL.GeoLevelName,
						RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrOnAcc
						FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK)
						WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND E.UsrId=@Pi_UsrId --SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					INNER JOIN
					(   -- Comment by Boopathy on 02-11-2011 for taking long time to generate
						--SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						--ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						--FROM SalesInvoice SI (NOLOCK)
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) D ON SI.SalId = D.SalId
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) E ON SI.SalId = E.SalId
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) F ON SI.SalId = F.SalId
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) G ON SI.SalId = G.SalId
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) H ON SI.SalId = H.SalId
						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						
						
						SELECT DISTINCT D.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM 
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) D, --ON SI.SalId = D.SalId
						--INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) E, --ON SI.SalId = E.SalId
						--INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) F, --ON SI.SalId = F.SalId
						--INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) G, --ON SI.SalId = G.SalId
						--INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) H --ON SI.SalId = H.SalId
						WHERE D.SalId =E.SalId AND E.SalId=F.SalId AND F.SalId=G.SalId AND G.SalId=H.SalId
												
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
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,PrdDcode,
							P.PrdName,P.PrdShrtName,P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,
							BPT.Tax3Perc,BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId AND BPT.UsrId=@Pi_UsrId
							INNER JOIN  RptSELECTedBills E WITH (NOLOCK) ON SIP.SalId=E.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								INNER JOIN  RptSELECTedBills E WITH (NOLOCK) ON LW.SalId=E.SalId
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId
								WHERE E.UsrId=@Pi_UsrId
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE E.UsrId=@Pi_UsrId --.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId) 
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax@Pi_UsrIdAmount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,PrdDcode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN  RptSELECTedBills E WITH (NOLOCK) ON SIP.SalId=E.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE E.UsrId=@Pi_UsrId
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax@Pi_UsrIdAmount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,PrdDcode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN  RptSELECTedBills E WITH (NOLOCK) ON SIP.SalId=E.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE E.UsrId=@Pi_UsrId
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT DISTINCT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
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
						INNER JOIN  RptSELECTedBills E1 WITH (NOLOCK) ON SI.SalId=E1.SalId,
						--INNER JOIN -- Comment by Boopathy on 02-11-2011 for taking long time to generate
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						--INNER JOIN
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						--INNER JOIN
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						--INNER JOIN
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						--INNER JOIN
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) D,-- ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) E ,--ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) F ,--ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) G ,--ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) H --ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo						
						WHERE SI.SalId=D.SalId AND E1.UsrId=@Pi_UsrId AND D.SalId =E.SalId AND E.SalId=F.SalId AND F.SalId=G.SalId AND G.SalId=H.SalId
						AND SI.SlNo = D.PrdSlNo AND D.PrdSlNo=E.PrdSlNo AND E.PrdSlNo=F.PrdSlNo AND F.PrdSlNo=G.PrdSlNo AND G.PrdSlNo=H.PrdSlNo
						
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1 AND
					SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT E1.SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK) INNER JOIN  RptSELECTedBills E1 WITH (NOLOCK) ON SalesInvoiceProduct.SalId=E1.SalId
						WHERE E1.UsrId=@Pi_UsrId
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT DISTINCT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT E1.SalId,PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM 
							SalesInvoiceProduct SI WITH (NOLOCK) INNER JOIN  RptSELECTedBills E1 WITH (NOLOCK) ON SI.SalId=E1.SalId,
							ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
							AND SI.PrdId=PB.PrdId AND SI.PrdBatId=PB.PrdBatId AND SI.PriceId=PBV.PriceId AND E1.UsrId=@Pi_UsrId
						) MRP
						INNER JOIN
						(
							SELECT E1.SalId,PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
							FROM 
							SalesInvoiceProduct SI WITH (NOLOCK) INNER JOIN  RptSELECTedBills E1 WITH (NOLOCK) ON SI.SalId=E1.SalId,
							ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
							AND SI.PrdId=PB.PrdId AND SI.PrdBatId=PB.PrdBatId AND SI.PriceId=PBV.PriceId AND E1.UsrId=@Pi_UsrId
						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND SelRtr.SalId=MRP.SalId
						AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  INNER JOIN RptSELECTedBills B (NOLOCK) ON B.SalId=FinalSI.SalId WHERE UsrId=@Pi_UsrId
	END
	
	UPDATE @RptBillTemplate set [Allotment No]=V.AllotmentNumber from @RptBillTemplate R inner join VehicleAllocationDetails V on R.[Sales Invoice Number]=V.SaleInvNo
	
	UPDATE @RptBillTemplate set [Bx Selling Rate]=PrdBatDetailValue*ConversionFactor from @RptBillTemplate R inner join 
	(SELECT PrdCCode,pb.PrdBatCode,PBD.PrdBatDetailValue,uG.ConversionFactor from Product P inner join ProductBatch PB on P.PrdId=PB.PrdId
	INNER JOIN ProductBatchDetails PBD on PBD.PrdBatId=PB.PrdBatId and PBD.DefaultPrice=1 and SLNo=3
	INNER JOIN UomGroup UG on P.UomGroupId=UG.UomGroupId and UOMId=1)A	
	on R.[Batch Code]=A.PrdBatCode AND R.[Product Code]=PrdCCode
	
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_RptBillTemplateFinal' AND XTYPE='P')
DROP PROCEDURE  Proc_RptBillTemplateFinal
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_RptBillTemplateLineNo' AND XTYPE='P')
DROP PROCEDURE  Proc_RptBillTemplateLineNo
GO
CREATE PROCEDURE Proc_RptBillTemplateLineNo  
(
	@Pi_Type    INT
) 
AS 
BEGIN      
	DECLARE @Salinvno	AS  NVARCHAR(25)      
	DECLARE @Prdcnt		AS	INT      
	DECLARE @PrdAva		AS	INT 
	DECLARE @prdChk		AS	INT      
	DECLARE @PrdLine	AS	INT 
	DECLARE @FROMBillId AS  NVARCHAR(25)  
	DECLARE @ToBillId   AS  NVARCHAR(25)

	DECLARE @TempSalId TABLE 
	(
		SalId INT
	) 

	DECLARE @TmpSalInvoice TABLE 
	(
		SalId INT
	)

	SET @Prdline = (SELECT LineNumber FROM BillTemplateHD WHERE  PrINTType =1  AND UsrId=1 and tempName ='BillTemplate') 

	IF @Prdline = 1         
	BEGIN
		SET @Prdline = 15      
	END
	ELSE          
	BEGIN	
		SET @Prdline = 10 
	END

	IF @Pi_Type=1 
	BEGIN   
		INSERT INTO @TmpSalInvoice SELECT SelValue FROM ReportFilterDt WHERE RptId = 16 And SelId = 34 
	END
	ELSE   
	BEGIN 
		SELECT @FROMBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 And SelId = 14 
		SELECT @ToBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 And SelId = 15 
	END

	IF @Pi_Type=1 
	BEGIN  
		INSERT INTO @TempSalId(SalId) SELECT DISTINCT SalId FROM RptBTBillTemplate WITH (nolock) WHERE UsrId = 1 
		AND SalId IN( SELECT SalId FROM @TmpSalInvoice) 
	END 
	ELSE 
	BEGIN 
		INSERT INTO @TempSalId(SalId) SELECT DISTINCT SalId FROM RptBTBillTemplate WITH (nolock) 
		WHERE UsrId = 1 AND SalId Between @FROMBillId AND @ToBillId  
	END

	DECLARE Cur_Salno CURSOR FOR 
	SELECT DISTINCT A.SalId FROM RptBTBillTemplate A WITH (nolock) INNER JOIN @TempSalId B ON A.SalId= B.SalId
	WHERE UsrId = 1 
	OPEN Cur_Salno 
	FETCH NEXT FROM Cur_Salno INTO @Salinvno 
	WHILE @@FETCH_STATUS =0 
	BEGIN     
		SELECT @prdcnt = count(DISTINCT [Product Code]) FROM RptBTBillTemplate A WITH (nolock) WHERE UsrId = 1 and  [SalId] = @Salinvno 
		SET @prdChk =  @prdcnt/@Prdline 
		IF @prdchk = 0         
		BEGIN
			SET @PrdAva = @Prdline - @prdcnt      
		END
		ELSE 
		BEGIN 
			SET @PrdAva =  @prdcnt - (@prdChk*@Prdline) 
			SET @PrdAva = @Prdline - @PrdAva     
		END 

		IF @PrdAva = @Prdline    
		BEGIN
			SET @PrdAva = 0 
		END

		WHILE @PrdAva > 0 
		BEGIN 
			INSERT INTO RptBTBillTemplate( [Base Qty],[Batch Code],[Batch Expiry Date],[Batch Manufacturing Date],[Batch MRP],[Batch Selling Rate],
			[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],[CD Disc Base Qty Amount],[CD Disc Effect Amount],[CD Disc Header Amount],
			[CD Disc LineUnit Amount],[CD Disc Qty Percentage],[CD Disc Unit Percentage],[CD Disc UOM Amount],[CD Disc UOM Percentage],[Company Address1],
			[Company Address2],[Company Address3],[Company Code],[Company Contact Person],[Company EmailId],[Company Fax Number],[Company Name],
			[Company Phone Number],[Contact Person],[CST Number],[DB Disc Base Qty Amount],[DB Disc Effect Amount],[DB Disc Header Amount],
			[DB Disc LineUnit Amount],[DB Disc Qty Percentage],[DB Disc Unit Percentage],[DB Disc UOM Amount],[DB Disc UOM Percentage],[DC DATE],
			[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],[Distributor Address1],[Distributor Address2],[Distributor Address3],
			[Distributor Code],[Distributor Name],[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],
			[Drug2 Expiry Date],[EAN Code],[EmailID],[Geo Level],[INTerim Sales],[Licence Number],[Line Base Qty Amount],[Line Base Qty Percentage],
			[Line Effect Amount],[Line Unit Amount],[Line Unit Percentage],[Line UOM1 Amount],[Line UOM1 Percentage],[LST Number],[Manual Free Qty],
			[Order Date],[Order Number],[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],[Product Code],[Product Name],
			[Product Short Name],[Product SL No],[Product Type],[Remarks],[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],
			[Retailer ContactPerson],[Retailer Coverage Mode],[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],
			[Retailer Deposit Amount],[Retailer Drug ExpiryDate],[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],
			[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],
			[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],
			[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],
			[Retailer Village],[Route Code],[Route Name],[Sales Invoice Number],[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],
			[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],[SalesInvoice Line Gross Amount],[SalesInvoice Line Net Amount],
			[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDIFfAmount],[SalesInvoice OnAccountAmount],
			[SalesInvoice OtherCharges],[SalesInvoice RateDIFfAmount],[SalesInvoice ReplacementDIFfAmount],[SalesInvoice RoundOffAmt],
			[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],[SalId],
			[Sch Disc Base Qty Amount],[Sch Disc Effect Amount],[Sch Disc Header Amount],[Sch Disc LineUnit Amount],[Sch Disc Qty Percentage],
			[Sch Disc Unit Percentage],[Sch Disc UOM Amount],[Sch Disc UOM Percentage],[Scheme PoINTs],[Spl. Disc Base Qty Amount],[Spl. Disc Effect Amount],
			[Spl. Disc Header Amount],[Spl. Disc LineUnit Amount],[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],[Spl. Disc UOM Amount],
			[Spl. Disc UOM Percentage],[Tax 1],[Tax 2],[Tax 3],[Tax 4],[Tax Amount1],[Tax Amount2],[Tax Amount3],[Tax Amount4],[Tax Amt Base Qty Amount],
			[Tax Amt Effect Amount],[Tax Amt Header Amount],[Tax Amt LineUnit Amount],[Tax Amt Qty Percentage],[Tax Amt Unit Percentage],[Tax Amt UOM Amount],
			[Tax Amt UOM Percentage],[Tax Type],[TIN Number],[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name] ,UsrId ,Visibility ,
			[Distributor Product Code],[Allotment No],[Bx Selling Rate])  
			SELECT TOP 1 [Base Qty],[Batch Code],[Batch Expiry Date],[Batch Manufacturing Date],[Batch MRP],[Batch Selling Rate],[Bill Date],
			[Bill Doc Ref. Number],[Bill Mode],[Bill Type],[CD Disc Base Qty Amount],[CD Disc Effect Amount],[CD Disc Header Amount],[CD Disc LineUnit Amount],
			[CD Disc Qty Percentage],[CD Disc Unit Percentage],[CD Disc UOM Amount],[CD Disc UOM Percentage],[Company Address1],[Company Address2],
			[Company Address3],[Company Code],[Company Contact Person],[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],
			[Contact Person],[CST Number],[DB Disc Base Qty Amount],[DB Disc Effect Amount],[DB Disc Header Amount],[DB Disc LineUnit Amount],
			[DB Disc Qty Percentage],[DB Disc Unit Percentage],[DB Disc UOM Amount],[DB Disc UOM Percentage],[DC DATE],[DC NUMBER],[Delivery Boy],
			[Delivery Date],[Deposit Amount],[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
			[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],[EAN Code],[EmailID],[Geo Level],
			[INTerim Sales],[Licence Number],[Line Base Qty Amount],[Line Base Qty Percentage],[Line Effect Amount],[Line Unit Amount],[Line Unit Percentage],
			[Line UOM1 Amount],[Line UOM1 Percentage],[LST Number],[Manual Free Qty],[Order Date],[Order Number],[Pesticide Expiry Date],
			[Pesticide Licence Number],[PhoneNo],[PinCode],[Product Code],[Product Name],[Product Short Name],[Product SL No],[Product Type],[Remarks],
			[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
			[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
			[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
			[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
			[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
			[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],[Route Code],[Route Name],[Sales Invoice Number],
			[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
			[SalesInvoice Line Gross Amount],[SalesInvoice Line Net Amount],[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],
			[SalesInvoice NetRateDIFfAmount],[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDIFfAmount],
			[SalesInvoice ReplacementDIFfAmount],[SalesInvoice RoundOffAmt],[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],
			[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],[SalId],[Sch Disc Base Qty Amount],[Sch Disc Effect Amount],
			[Sch Disc Header Amount],[Sch Disc LineUnit Amount],[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],[Sch Disc UOM Amount],
			[Sch Disc UOM Percentage],[Scheme PoINTs],[Spl. Disc Base Qty Amount],[Spl. Disc Effect Amount],[Spl. Disc Header Amount],
			[Spl. Disc LineUnit Amount],[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],[Spl. Disc UOM Amount],[Spl. Disc UOM Percentage],
			[Tax 1],[Tax 2],[Tax 3],[Tax 4],[Tax Amount1],[Tax Amount2],[Tax Amount3],[Tax Amount4],[Tax Amt Base Qty Amount],[Tax Amt Effect Amount],
			[Tax Amt Header Amount],[Tax Amt LineUnit Amount],[Tax Amt Qty Percentage],[Tax Amt Unit Percentage],[Tax Amt UOM Amount],
			[Tax Amt UOM Percentage],[Tax Type],[TIN Number],[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name], 1,1,
			[Distributor Product Code],[Allotment No],[Bx Selling Rate]  
			FROM RptBTBillTemplate
			WHERE [SalId] = @Salinvno and UsrId = 1

			SET @PrdAva = @PrdAva - 1     
		END 
		FETCH NEXT FROM Cur_Salno INTo @Salinvno
	END 
	CLOSE Cur_Salno 
	DEALLOCATE Cur_Salno 
END
GO
DELETE FROM tbl_Generic_Reports WHERE  rptid=14
INSERT INTO tbl_Generic_Reports VALUES
(14,'Retailer Wise SpecialRate','Proc_GR_RetailerWsSplRate','Retailer Wise Product Wise Special Rate','Not Available')
GO
DELETE FROM TBL_GENERIC_REPORTS_FILTERS WHERE RptId=14
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 14,1,'Retailer Group','Proc_GR_RetailerWsSplRate_Values','Retailer Wise SpecialRate'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 14,2,'Retailer','Proc_GR_RetailerWsSplRate_Values','Retailer Wise SpecialRate'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 14,3,'Product Code','Proc_GR_RetailerWsSplRate_Values','Retailer Wise SpecialRate'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 14,4,'Not Applicable','Proc_GR_RetailerWsSplRate_Values','Retailer Wise SpecialRate'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 14,5,'Not Applicable','Proc_GR_RetailerWsSplRate_Values','Retailer Wise SpecialRate'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 14,6,'Not Applicable','Proc_GR_RetailerWsSplRate_Values','Retailer Wise SpecialRate'
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_GR_RetailerWsSplRate_Values' AND xtype='P')
DROP PROCEDURE Proc_GR_RetailerWsSplRate_Values
GO
CREATE PROCEDURE Proc_GR_RetailerWsSplRate_Values
(  
  @FILTERCAPTION  NVARCHAR(100),  
  @TEXTLIKE  NVARCHAR(100)  
)  
As  
BEGIN 
	SET @TEXTLIKE='%'+ISNULL(@TEXTLIKE,'')+'%'
	
	IF @FILTERCAPTION='Retailer Group' 
	BEGIN
		SELECT DISTINCT CTGNAME AS FILTERVALUES FROM RETAILERCATEGORY WHERE CTGNAME LIKE @TEXTLIKE
	END
	IF @FILTERCAPTION='Retailer' 
	BEGIN
		SELECT DISTINCT Rtrname AS FILTERVALUES FROM RETAILER  WHERE Rtrname LIKE @TEXTLIKE
	END	
	IF @FILTERCAPTION='Product Code' 
	BEGIN
		SELECT DISTINCT PrdName AS FILTERVALUES FROM Product  WHERE PrdName LIKE @TEXTLIKE
	END		
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_GR_RetailerWsSplRate' AND xtype='P')
DROP PROCEDURE Proc_GR_RetailerWsSplRate
GO
CREATE PROCEDURE Proc_GR_RetailerWsSplRate
(  
	 @Pi_RptName  NVARCHAR(100),  
	 @Pi_FromDate DATETIME,  
	 @Pi_ToDate  DATETIME,  
	 @Pi_Filter1  NVARCHAR(100),  
	 @Pi_Filter2  NVARCHAR(100),  
	 @Pi_Filter3  NVARCHAR(100),  
	 @Pi_Filter4  NVARCHAR(100),  
	 @Pi_Filter5  NVARCHAR(100),  
	 @Pi_Filter6  NVARCHAR(100)  
)  
AS   
BEGIN  
  SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'          
  SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'          
  SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'          
  SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'          
  SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'    
  SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'
  
 SELECT 'Retailer Ws Special Rate',ctgname as [Retailer Group],rtrname as [Retialer Name],prdname as [Product Name],Prdccode as [Product Code],prdbatdetailvalue as [Special Rate],validfromdate,ValidTilldate from 
(SELECT RC.ctgname,R.rtrname,prdname,Prdccode,CM.contractid,CD.prdid,max(CD.priceid)priceid,CM.validfromdate,ValidTilldate from ContractPricingDetails CD
 INNER JOIN ContractPricingMaster CM on CD.contractid=CM.contractid
 INNER JOIN product P on P.prdid=CD.prdid
 INNER JOIN retailercategory RC on RC.ctglevelid=CM.ctglevelid and RC.ctgmainid=CM.ctgmainid
 INNER JOIN retailervalueclass RV on RV.Ctgmainid=CM.ctgmainid and RV.ctgmainid=RC.ctgmainid
 INNER JOIN retailervalueclassmap RCM on RCM.rtrvalueclassid=Rv.rtrclassid
 INNER JOIN retailer R on R.rtrid=RCM.rtrid
 WHERE ctgname LIKE @Pi_FILTER1 AND rtrname LIKE @Pi_FILTER2 AND PrdName LIKE @Pi_FILTER3
 AND @Pi_FromDate>=CM.validfromdate and @Pi_ToDate<=ValidTilldate
 GROUP BY  RC.ctgname,R.rtrname,prdname,Prdccode,CM.contractid,CD.prdid,CM.validfromdate,ValidTilldate)A INNER JOIN
 Productbatchdetails P on A.priceid=P.priceid WHERE slno=3
END
GO
DELETE FROM HotSearchEditorHd WHERE FormId=550
INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
SELECT 550,'Billing','Retailer Display Based On Name','Select',
'SELECT RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrSeqDtId,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,
RtrCrBills,RtrCrLimit,  RtrCrDays,RtrTINNo,RtrCSTNo,RtrLicNo,RtrLicExpiryDate,  RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,
RtrDOB,RtrAnniversary,  RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT C.RtrId,C.RtrName,C.RtrCode,B.RtrSeqDtId,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,
C.RtrCovMode,C.RtrCashDiscPerc, C.RtrCashdiscCond,  C.RtrCashDiscAmt,C.RtrTaxType,C.RMId AS DelvRMId,C.RTRDayOff,C.RtrCrBills,C.RtrCrLimit,C.RtrCrDays,
C.RtrTINNo,C.RtrCSTNo, C.RtrLicNo,ISNULL(C.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,C.RtrDrugLicNo,ISNULL(C.RtrDrugExpiryDate,
Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,  C.RtrPestLicNo,ISNULL(C.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,  
ISNULL(C.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(C.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(C.RtrAnniversary,
Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary, RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM RetailerSequence A (NOLOCK) 
INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId INNER JOIN   Retailer C (NOLOCK) on C.RtrId = B.RtrId Where C.RtrStatus = 1 
And A.SMId=vFParam And A.RMId=vSParam And TransactionType=vTParam   Union   SELECT D.RtrId,D.RtrName,D.RtrCode,
100000 as RtrSeqDtId,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscPerc, D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,
D.RMId AS DelvRMId,D.RTRDayOff, D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,
Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,   D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,  
D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,  ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary, RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)   INNER JOIN RetailerMarket E (NOLOCK) ON D.RtrId = E.RtrId   Where D.RtrStatus = 1 And E.RMId = vSParam And D.Rtrid Not In (SELECT C.RtrId FROM   RetailerSequence A (NOLOCK)   INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on   C.RtrId = B.RtrId Where C.RtrStatus = 1 And A.SMId=vFParam And A.RMId=vSParam And TransactionType=vTParam) ) a  ORDER BY RtrSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId=551
INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
SELECT 551,'Billing','Retailer Display Based On Sequence','Select','SELECT RtrId,RtrSeqDtId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,  RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,RtrTINNo,RtrCSTNo,  RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,  RtrDOB,RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT C.RtrId,B.RtrSeqDtId,C.RtrCode,  C.RtrName,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrCovMode,C.RtrCashDiscPerc,C.RtrCashdiscCond,C.RtrCashDiscAmt,C.RtrTaxType,C.RMId AS DelvRMId,C.RTRDayOff,  C.RtrCrBills,C.RtrCrLimit,C.RtrCrDays,C.RtrTINNo,C.RtrCSTNo, C.RtrLicNo,ISNULL(C.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,  C.RtrDrugLicNo,ISNULL(C.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,C.RtrPestLicNo,  ISNULL(C.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,ISNULL(C.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,  ISNULL(C.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,   ISNULL(C.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,  RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM RetailerSequence A (NOLOCK) INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId   INNER JOIN   Retailer C (NOLOCK) on C.RtrId = B.RtrId  Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam And TransactionType=vTParam    Union   SELECT D.RtrId,100000 as RtrSeqDtId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscPerc,  D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,  D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,  ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,  Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,  D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,  ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,   ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,  ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)   INNER JOIN   RetailerMarket E (NOLOCK) ON D.RtrId = E.RtrId Where D.RtrStatus = 1 And E.RMId = vSParam    And D.Rtrid Not In (SELECT C.RtrId FROM RetailerSequence A (NOLOCK) INNER JOIN  RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId   INNER JOIN Retailer C (NOLOCK) on   C.RtrId = B.RtrId Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam    And TransactionType=vTParam)) A ORDER BY RtrSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId=552
INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
SELECT 552,'Billing','Retailer Display Based On Code','Select','SELECT RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrSeqDtId,RtrCovMode,  RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,  RtrCrLimit,RtrCrDays,RtrTINNo,RtrCSTNo,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,  RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,  RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT C.RtrId,C.RtrCode,C.RtrName,  B.RtrSeqDtId,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrCovMode,C.RtrCashDiscPerc,C.RtrCashdiscCond,C.RtrCashDiscAmt,C.RtrTaxType,C.RMId AS DelvRMId,C.RTRDayOff,  C.RtrCrBills,C.RtrCrLimit,C.RtrCrDays,C.RtrTINNo,C.RtrCSTNo, C.RtrLicNo,  ISNULL(C.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,C.RtrDrugLicNo,  ISNULL(C.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,C.RtrPestLicNo,  ISNULL(C.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,ISNULL(C.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,  ISNULL(C.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,   ISNULL(C.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,  RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM RetailerSequence A (NOLOCK) INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId   INNER JOIN Retailer C (NOLOCK) on   C.RtrId = B.RtrId Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam And TransactionType=vTParam    Union   SELECT D.RtrId,D.RtrCode,D.RtrName,100000 as RtrSeqDtId,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,  D.RMId AS DelvRMId,D.RTRDayOff,   D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo,D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,  Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,   D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,  D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,  ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,   ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,  ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)   INNER JOIN   RetailerMarket E (NOLOCK) ON D.RtrId = E.RtrId Where D.RtrStatus = 1 And E.RMId = vSParam And D.Rtrid Not In (SELECT C.RtrId FROM   RetailerSequence A (NOLOCK)   INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on   C.RtrId = B.RtrId   Where C.RtrStatus = 1   And A.SMId = vFParam And A.RMId = vSParam And TransactionType=vTParam)) a ORDER BY RtrSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 553
INSERT INTO HotSearchEditorHd 
SELECT 553,'Billing','Select Display with Route Coverage Plan Based on Retailer Sequence','select',
'SELECT RtrId,RtrSeqDtId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
RtrTINNo,RtrCSTNo,RtrLicNo,  RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT D.RtrId,100000 as RtrSeqDtId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,
D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo,D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,IsNull(D.RtrPestExpiryDate, 
Convert(VarChar(10),GetDate(), 121)) AS RtrPestExpiryDate,ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,
Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,
RtrCrLimitAlert FROM Retailer D (NOLOCK) INNER JOIN RetailerMarket B ON D.RtrId = B.RtrId  INNER JOIN RouteCovPlanMaster C ON C.RMId = B.RMId AND C.RMSRouteType=1 
AND D.RtrId = CASE C.RtrId WHEN 0 THEN D.RtrId else C.RtrId END  INNER JOIN RouteCovPlanDetails E ON C.RCPMAsterId = E.RCPMasterId  AND RCPGeneratedDates = ''vSParam'' 
AND RCPHolidayStatus=0 Where D.RtrStatus = 1  AND B.RMId = vFParam ) a ORDER BY RtrSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 554
INSERT INTO HotSearchEditorHd
SELECT 554,'Billing','Select Display with Route Coverage Plan Based on Retailer Name','select',
'SELECT RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrSeqDtId,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
RtrTINNo,RtrCSTNo,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,
RtrCrLimitAlert FROM (SELECT D.RtrId,D.RtrName,D.RtrCode,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,100000 as RtrSeqDtId,D.RtrCovMode,D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,
D.RMId AS DelvRMId,D.RTRDayOff,  D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,  ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrLicExpiryDate,  D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo ,IsNull(D.RtrPestExpiryDate, 
Convert(VarChar(10), GetDate(), 121)) AS RtrPestExpiryDate,  ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate, ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,  
ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) INNER JOIN RetailerMarket B ON   
D.RtrId = B.RtrId INNER JOIN RouteCovPlanMaster C ON C.RMId = B.RMId AND C.RMSRouteType=1  AND D.RtrId = CASE C.RtrId WHEN 0 THEN D.RtrId else C.RtrId END INNER JOIN RouteCovPlanDetails E ON C.RCPMAsterId = E.RCPMasterId  
AND RCPGeneratedDates = ''vSParam'' AND RCPHolidayStatus=0 Where D.RtrStatus = 1 AND B.RMId = vFParam) a ORDER BY RtrSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 555
INSERT INTO HotSearchEditorHd
SELECT 555,'Billing','Select Display with Route Coverage Plan Based on Retailer Code','select',
'SELECT RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrSeqDtId,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
RtrTINNo,  RtrCSTNo,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,100000 as RtrSeqDtId,D.RtrCovMode,D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,
D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff, D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo,D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,
IsNull(D.RtrPestExpiryDate,Convert(VarChar(10), GetDate(), 121)) AS RtrPestExpiryDate,ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,
ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) INNER JOIN RetailerMarket B ON  D.RtrId = B.RtrId  INNER JOIN RouteCovPlanMaster C ON C.RMId = B.RMId 
AND C.RMSRouteType=1 AND D.RtrId = CASE C.RtrId WHEN 0 THEN D.RtrId else C.RtrId END  INNER JOIN RouteCovPlanDetails E ON C.RCPMAsterId = E.RCPMasterId 
AND RCPGeneratedDates = ''vSParam''  AND RCPHolidayStatus=0 Where D.RtrStatus = 1 AND B.RMId = vFParam) a ORDER BY RtrSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 556
INSERT INTO HotSearchEditorHd
SELECT 556,'Billing','Direct Retailer Based on Sequence','select',
'SELECT RtrId,RtrSeqDtId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
RtrTINNo,RtrCSTNo,  RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT D.RtrId,100000 as RtrSeqDtId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode, D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,
D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo,D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,
Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),
GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)
Where D.RtrStatus = 1 ) a ORDER BY RtrSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 557
INSERT INTO HotSearchEditorHd 
SELECT 557,'Billing','Direct Retailer Based on Name','select',
'SELECT RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrSeqDtId,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,
RtrCrDays,RtrTINNo,RtrCSTNo,  RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,  
RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT D.RtrId,D.RtrName,D.RtrCode,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,100000 as RtrSeqDtId,D.RtrCovMode,D.RtrCashDiscPerc,
D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,  D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, 
D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,  D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,  ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,  
ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,  
ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) 
Where D.RtrStatus = 1 ) a ORDER BY RtrSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 558
INSERT INTO HotSearchEditorHd
SELECT 558,'Billing','Direct Retailer Based on Code','select',
'SELECT RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrSeqDtId,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,RtrTINNo,RtrCSTNo,RtrLicNo,  
RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM 
(SELECT D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,100000 as RtrSeqDtId,D.RtrCovMode,D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,
D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,
D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrPestExpiryDate, ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,
ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,  RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)
Where D.RtrStatus = 1) a ORDER BY RtrSeqDtId'
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'SalesinvoiceSchemeFlag')
BEGIN
CREATE TABLE SalesinvoiceSchemeFlag
(
UserId INT,
SalId INT,
Flag  Tinyint,
Mode  INT,
Modified DateTime
)
END
GO
DELETE FROM CustomCaptions WHERE TransId = 2 And CtrlId = 1000 And SubCtrlId = 266
INSERT INTO CustomCaptions
SELECT 2,1000,266,'MsgBox-2-1000-266','','','While Updating SalesinvoiceSchemeFlag',1,1,1,GETDATE(),1,GETDATE(),'','','While Updating SalesinvoiceSchemeFlag',1,1
GO
DELETE FROM RptExcelHeaders where RptId=241
INSERT INTO RptExcelHeaders 
SELECT 241,1,'InvDate','Invoice Date',1,1
UNION
SELECT 241,2,'GrossAmount','GrossAmont',1,1
UNION
SELECT 241,3,'Discount','Discount',1,1 
UNION
SELECT 241,4,'Scheme','Scheme',1,1 
UNION
SELECT 241,5,'Damage','Damage',1,1 
UNION
SELECT 241,6,'AddLess','AddLess',1,1 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptVatSummary_Parle' AND XTYPE='P')
DROP PROCEDURE Proc_RptVatSummary_Parle
GO
--Exec Proc_RptVatSummary_Parle 241,1,0,'eeeee',0,0,0
CREATE PROCEDURE Proc_RptVatSummary_Parle
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
/*******************************************************************************************************
* VIEW	: Proc_RptVatSummary_Parle
* PURPOSE	: To get sales tax Details
* CREATED BY	: Karthick.K.J
* CREATED DATE	:  
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------
* {date} {developer}  {brief modification description}	
********************************************************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @InvoiceType AS  INT 
	DECLARE @EXLFlag	AS 	INT

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,278,@Pi_UsrId))
	
	print @InvoiceType
	delete from RptVatsummary
		
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_IOTaxSummary_Parle @FromDate,@ToDate,@InvoiceType
	--select * from 	Temp_IOTaxDetails_Parle
		INSERT INTO RptVatsummary 
		SELECT InvDate,sum(GrossAmount)as GrossAmount,sum(Discount) as Discount,TaxPerc,sum(TaxableAmount) as TaxableAmount,TaxFlag,TaxPercent,TaxId,
		sum(Scheme)as Scheme,sum(Damage) as Damage,sum(AddLess) as AddLess,sum(FinalAmount) as FinalAmount,colno from Temp_IOTaxDetails_Parle
		GROUP BY InvDate,TaxPerc,TaxFlag,TaxPercent,TaxId,colno
		
		--GrossAmount	
		insert into RptVatsummary 
		select distinct InvDate,GrossAmount,Discount,'Gross Amount',GrossAmount,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,1 from RptVatsummary
		--Discount	
		insert into RptVatsummary 
		select distinct InvDate,GrossAmount,Discount,'Discount',Discount,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,2 from RptVatsummary
		
		--Scheme	
		insert into RptVatsummary 
		select distinct InvDate,GrossAmount,Discount,'Scheme',Scheme,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,3 from RptVatsummary
		
		--Damage	
		insert into RptVatsummary 
		select distinct InvDate,GrossAmount,Discount,'Damage',Damage,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,4 from RptVatsummary
		
		----Other Charges	
		insert into RptVatsummary 
		select distinct InvDate,GrossAmount,Discount,'Add/less',AddLess,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,7 from RptVatsummary
		----Final Amount
		insert into RptVatsummary 
		select distinct InvDate,GrossAmount,Discount,'Final Amount',FinalAmount,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,8 from RptVatsummary
		
	END 
	
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM RptVatsummary  
	
	update ReportFilterDt set SelDate='Sales' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=278 and SelValue=0
	update ReportFilterDt set SelDate='Purchase' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=278 and SelValue=1
	
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		--ORDER BY InvId,TaxFlag ASC
		/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @InvId			BIGINT
		--DECLARE  @RtrId		INT
		DECLARE	 @RefNo			NVARCHAR(100)
		DECLARE  @PurRcptRefNo  NVARCHAR(50)
		DECLARE	 @TaxPerc 		NVARCHAR(100)
		DECLARE	 @TaxableAmount NUMERIC(38,6)
		DECLARE  @IOTaxType     NVARCHAR(100)
		DECLARE  @SlNo			INT		
		DECLARE	 @TaxFlag       INT
		DECLARE  @Column		VARCHAR(80)
		DECLARE  @C_SSQL		VARCHAR(4000)
		DECLARE  @iCnt			INT
		DECLARE  @TaxPercent	NUMERIC(38,6)
		DECLARE  @Name			NVARCHAR(100)
		DECLARE  @Taxid			INT
		DECLARE  @ColNo         INT
		DECLARE  @invdate       DATETIME
		--DROP TABLE RptOUTPUTVATSummary_Excel
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptVATSummary_Excel]
		DELETE FROM RptExcelHeaders Where RptId=241 and slno>6
		
		CREATE TABLE RptVATSummary_Excel (InvDate datetime,[Gross Amount] numeric(18,6),Discount numeric(18,6),Scheme numeric(18,6),Damage numeric(18,6),[Add/Less] numeric(18,6))
		SET @iCnt=7
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag,taxid,ColNo FROM RptVatsummary where colno in(5,6) ORDER BY colno,TaxPercent,taxid ,TaxFlag 
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag,@Taxid,@ColNo
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptVATSummary_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
				
					EXEC (@C_SSQL)
				SET @iCnt=@iCnt+1
					FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag,@Taxid,@ColNo
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		
		ALTER TABLE RptVATSummary_Excel Add [Final Amount] numeric(18,6)
		INSERT INTO RptExcelHeaders SELECT 241,(select MAX(slno)+1 from RptExcelHeaders where RptId=241),'Final Amount','Final Amount',1,1
		--Insert table values
		DELETE FROM RptVATSummary_Excel
		INSERT INTO RptVATSummary_Excel(InvDate,[Gross Amount],Discount,Scheme,Damage,[Add/Less])
		SELECT InvDate,SUM(grossamount),sum(Discount),sum(Scheme),sum(Damage),sum(AddLess) from (
		SELECT DISTINCT InvDate,GrossAmount,sum(Discount)Discount,sum(Scheme)Scheme,sum(Damage)Damage,sum(AddLess)AddLess
				FROM RptVatsummary group by InvDate,GrossAmount )A group by InvDate 
		--Select * from RptOUTPUTVATSummary_Excel
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT invdate,TaxPerc,round(sum(TaxableAmount),2)TaxableAmount FROM RptVatsummary group by invdate,TaxPerc
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @invdate,@TaxPerc,@TaxableAmount
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptVATSummary_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL+ ' WHERE invdate='''+ CONVERT(varchar(10),@invdate,121)+''''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @invdate,@TaxPerc,@TaxableAmount
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptVATSummary_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptVATSummary_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
	END
	
	select * from 	RptVatsummary order by InvDate
	
  RETURN 
END 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptSchemeUtilization_Parle' AND XTYPE='P')
DROP PROCEDURE  Proc_RptSchemeUtilization_Parle
GO
--EXEC Proc_RptSchemeUtilization_Parle 237,1,0,'Henkel',0,0,1
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
	Where Um.UomCode='BX'
		
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
		FreePrdName	nVarchar(50),
		FreeQty		Int,
		[BaseQty] [Int],
		BaseQtyBox	Int,
		BaseQtyPack Int,
		FreeValue	Numeric(38,6),
		GiftPrdName	nVarchar(50),
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
DELETE FROM RptExcelHeaders WHERE RptId=207
INSERT INTO RptExcelHeaders 
SELECT 207,1,'SMId','',0,1 UNION
SELECT 207,2,'SMName','Salesman',1,1 UNION
SELECT 207,3,'RMId','',0,1 UNION
SELECT 207,4,'RMName','Route Name',1,1 UNION
SELECT 207,5,'TotalOutlets','Total Outlets',1,1 UNION
SELECT 207,6,'OutletsBilled','Outlets Billed',1,1 UNION
SELECT 207,7,'Efficiecy','Efficiency',1,1 UNION
SELECT 207,8,'ScheduledCalls','Scheduled Calls',1,1 UNION
SELECT 207,9,'ActualBills','Actual Bills',1,1 UNION
SELECT 207,10,'Coverage','Coverage',0,1 UNION
SELECT 207,11,'CompanyId','CompanyId',0,1 UNION
SELECT 207,12,'TotalLinesSold','TotalLinesSold',0,1 UNION
SELECT 207,13,'Productivity','Productivity %',1,1 UNION
SELECT 207,14,'LinesPerCall','LinesPerCall',1,1
GO
DELETE FROM RptExcelHeaders WHERE rptid=237
INSERT INTO RptExcelHeaders 
SELECT 	237,1,'SchId','SchId',0,1	UNION
SELECT 	237,2,'SchCode','SchCode',1,1	UNION
SELECT 	237,3,'SchDesc','SchDesc',1,1	UNION
SELECT 	237,4,'CircularNo','CircularNo',1,1	UNION
SELECT 	237,5,'SlabId','Slab',1,1	UNION
SELECT 	237,6,'SchemeBudget','Scheme Budget',1,1	UNION
SELECT 	237,7,'BudgetUtilized','BudgetUtilized',1,1	UNION
SELECT 	237,8,'NoOfRetailer','NoOfRetailerBilled',1,1	UNION
SELECT 	237,9,'NoOfBills','NoOfBillsApplied',1,1	UNION
SELECT 	237,10,'UnSELECTedCnt','NoOfBillsNotApplied',1,1	UNION
SELECT 	237,11,'BaseQtyBox','BaseQtyBox',1,1	UNION
SELECT 	237,12,'BaseQtyPack','BaseQtyPack',1,1	UNION
SELECT 	237,13,'DiscountPer','Scheme Amount',1,1	UNION
SELECT 	237,14,'FreePrdName','Free ProductName',1,1	UNION
SELECT 	237,15,'FreeQty','Free Qty',1,1	UNION
SELECT 	237,16,'FreeValue','Free Qty Value',0,1	UNION
SELECT 	237,17,'FlatAmount','FlatAmount',0,1	UNION
SELECT 	237,18,'Points','Points',0,1	UNION
SELECT 	237,19,'BaseQty','BaseQty',1,1	UNION
SELECT 	237,20,'GiftPrdName','GiftPrdName',0,1	UNION
SELECT 	237,21,'GiftQty','GiftQty',0,1	UNION
SELECT 	237,22,'GiftValue','GiftValue',0,1
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_RptPSREfficiencyDatewiseReport' AND XTYPE='P')
DROP PROCEDURE  Proc_RptPSREfficiencyDatewiseReport
GO
-- EXEC Proc_RptPSREfficiencyDatewiseReport 207,1,0,'NV02100309',0,0,1
CREATE PROCEDURE Proc_RptPSREfficiencyDatewiseReport
( 
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT, 
	@Pi_DbName			Nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/****************************************************************************************************************
* PROCEDURE  : Proc_RptPSREfficiencyDatewiseReport
* PURPOSE    : To Generate PSR Efficiency Report 
* CREATED BY : Panneerselvam.k
* CREATED ON : 09/12/2009  
* MODIFICATION 
*****************************************************************************************************************   
* DATE       AUTHOR      DESCRIPTION   
*****************************************************************************************************************/ 
BEGIN
SET NOCOUNT ON
		/* Get the Filter Values  */		
		DECLARE @CmpId	 			AS	INT
		DECLARE @SMId				AS	INT
		DECLARE @RMId				AS	INT
		DECLARE @RetCatLevelId      AS	INT
		DECLARE @RetCatLevelValId   AS	INT
		DECLARE @RetLevelClassId    AS	INT
		DECLARE @RetailerId		AS	INT
		DECLARE @PrdCatId      		AS	INT
		DECLARE @PrdId			AS	INT
		DECLARE @FromDate			AS  DATETIME
		DECLARE @ToDate				AS  DATETIME
		
		SET @FromDate			=(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
		SET @ToDate				= (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
		SET @CmpId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @SMId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
		SET @RMId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
		SET @RetCatLevelId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
		SET @RetCatLevelValId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
		SET @RetLevelClassId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
		SET @RetailerId			= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
		EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
		SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
		SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
			/*  CREATE TABLE STRUCTURE */
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	nvarchar(50)
	DECLARE @TblName 		AS	nvarchar(500)
	DECLARE @TblStruct 		AS	nVarchar(4000)
	DECLARE @TblFields 		AS	nVarchar(4000)
	DECLARE @SSQL			AS 	VarChar(8000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
			/*  Till Here  */
	SET @TblName = 'RptEfficiencyDatewiseReport'
	
	SET @TblStruct ='	SMId INT,
						SMName Varchar(100),
						RMId INT,
						RMName VARCHAR(100),
						TotalOutlets Numeric(18,3),
						OutletsBilled Numeric(18,3),
						Coverage Numeric(18,3),						
						ScheduledCalls Numeric(18,3),
						ActualBills Numeric(18,3),
						Efficiecy Numeric(18,3),
						CompanyId INT,
						TotalLinesSold int,
						Productivity numeric(18,2),
						LinesPerCall numeric(18,2)'		
										
	SET @TblFields =	'SMId,SMName,RMId,RMName,TotalOutlets,OutletsBilled,Coverage,						
						 ScheduledCalls,ActualBills,Efficiecy,CompanyId'
	CREATE TABLE #RptEfficiencyDatewiseReport(	SMId INT,SMName VARCHAR(100),RMId INT,RMName VARCHAR(100),
									TotalOutlets Numeric(18,3),OutletsBilled Numeric(18,3),Coverage Numeric(18,3),
									ScheduledCalls Numeric(18,3),ActualBills Numeric(18,3),Efficiecy Numeric(18,3),
									CompanyId INT,TotalLinesSold int,Productivity numeric(18,2),LinesPerCall numeric(18,2))
	CREATE TABLE #TempRptEfficiencyDatewiseReport(	SMId INT,SMName VARCHAR(100),RMId INT,RMName VARCHAR(100),
									TotalOutlets Numeric(18,3),OutletsBilled Numeric(18,3),Coverage Numeric(18,3),
									ScheduledCalls Numeric(18,3),ActualBills Numeric(18,3),Efficiecy Numeric(18,3),
									CompanyId INT,TotalLinesSold int,Productivity numeric(18,2),LinesPerCall numeric(18,2))
			/* Purge DB */
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
			/*  Snap Shot Query    */
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
			/* Main Query */
		Delete From #TempRptEfficiencyDatewiseReport
		Delete From #RptEfficiencyDatewiseReport	  
		INSERT INTO #TempRptEfficiencyDatewiseReport
		
		SELECT SMId,SMName,RMId,RMName,TotalOutlets,OutletsBilled,Coverage,
				ScheduledCalls,sum(ActualBills)ActualBills,Efficiecy,
				CompanyId,sum(TotalLinesSold)TotalLinesSold,0,0 FROM (
				SELECT  
				SI.SMId,S.SMName,SI.RMId,RM.RMName,
				0 AS TotalOutlets,0 AS OutletsBilled,0 AS Coverage,
				0 AS ScheduledCalls,Count(DISTINCT SI.SalId) AS ActualBills,0 AS Efficiecy,
				P.CmpId CompanyId,COUNT(Distinct SIP.PrdId) as TotalLinesSold,si.salid
		FROM 
				SalesInvoice SI				WITH (NOLOCK),Salesman S WITH (NOLOCK),
				RouteMaster RM				WITH (NOLOCK),Retailer R WITH (NOLOCK),
				SalesmanMarket SM			WITH (NOLOCK),RetailerMarket RETMAR		WITH (NOLOCK),
				Product P					WITH (NOLOCK),SalesInvoiceProduct SIP	WITH (NOLOCK),
				ProductBatch PB				WITH (NOLOCK),RetailerValueClass RVC	WITH (NOLOCK),
				RetailerCategory RC			WITH (NOLOCK),RetailerCategorylevel RCL	WITH (NOLOCK),
				ProductCategoryLevel PCL    WITH (NOLOCK),ProductCategoryValue PCV	WITH (NOLOCK), 
				RetailerValueClassMap RVCM  WITH (NOLOCK)
		WHERE 
				SI.SMId = S.SMId				AND SI.RMId = RM.RMId				
				AND SI.RtrId = R.RtrId			AND R.RtrStatus = 1
				AND SI.SMId = SM.SMId			AND RM.RMId = SI.RMId
				AND SM.RMId = RETMAR.RMId		AND RETMAR.RtrId = R.RtrId 
				AND RETMAR.RtrId =Si.RtrId		AND DlvSts <> 3
				AND SIP.PrdId = P.PrdId			AND SI.SalId = SIP.SalId
				AND P.PrdId = PB.PrdId			AND PB.PrdId = SIP.PrdId
				AND SIP.PrdBatId = PB.PrdBatId	AND RVC.CtgMainId=RC.CtgMainId
				AND RVCM.RtrId=SI.RtrId			AND RC.CtgLevelId=RCL.CtgLevelId 
				AND RVCM.RtrValueClassId=RVC.RtrClassId				
				AND PCV.PrdCtgValMainId=P.PrdCtgValMainId
				AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
					/* Filters */
				AND SalInvDate Between @FromDate and @ToDate 	
				--- Company  
				AND (P.CmpId =  (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR 
								P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				--- SalesMan
				And (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
							    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route 
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level 
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category  
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (SI.RtrId = (CASE @RetailerId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
								SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
					AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					/* Till Here */
		GROUP BY
				SI.SMId,S.SMName,SI.RMId,RM.RMName,P.CmpId,si.salid )A
				group by SMId,SMName,RMId,RMName,TotalOutlets,OutletsBilled,Coverage,
				ScheduledCalls,Efficiecy,CompanyId
		
					/* Calculate Total Outlets */
		INSERT INTO #TempRptEfficiencyDatewiseReport
		SELECT 
				SM.SMId,SM.SMName,RM.RMId,RM.RMName,
				Count(R.RtrId) AS TotalOutlets ,0 AS OutletsBilled,0 AS Coverage,	
				0 AS ScheduledCalls,0 AS ActualBills,0 AS Efficiecy,
				CompanyId,0 as TotalLinesSold,0,0
		FROM  
				Salesman SM,RouteMaster RM,SalesmanMarket SRM,
				Retailer R,RetailerMarket RMARKET,#TempRptEfficiencyDatewiseReport T,
				RetailerValueClass RVC,
				RetailerCategory RC,RetailerCategorylevel RCL,
				RetailerValueClassMap RVCM  
		WHERE
				SRM.SMId = SM.SMId 					AND SRM.RMId = RM.RMId 
				AND SRM.RMId = RMARKET.RMId			AND RM.RMId = RMARKET.RMId
				AND R.RtrId = RMARKET.RtrId			AND RtrStatus = 1
				AND T.SMId = SM.SMId				AND T.RMId = RM.RMId
				AND RVCM.RtrId=R.RtrId				AND RC.CtgLevelId=RCL.CtgLevelId 				
				AND RVC.CmpId = T.CompanyId			AND RVC.CtgMainId = RC.CtgMainId	
				AND RC.CtgLevelId=RCL.CtgLevelId	AND RVCM.RtrValueClassId=RVC.RtrClassId			
				/* Filters */
				--- Company  
				AND (T.CompanyId =  (CASE @CmpId WHEN 0 THEN T.CompanyId ELSE 0 END) OR 
								T.CompanyId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				--- SalesMan
				And (SM.SMId = (CASE @SMId WHEN 0 THEN SM.SMId Else 0 END) OR
							    SM.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route 
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level 
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category  
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (R.RtrId = (CASE @RetailerId WHEN 0 THEN R.RtrId ELSE 0 END) OR
								R.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					/* Till Here */
		GROUP BY 
				SM.SMId,SM.SMName,RM.RMId,RM.RMName,CompanyId
				/* Calculate Outlets Billed */
		INSERT INTO #TempRptEfficiencyDatewiseReport
		SELECT 
				SI.SMId,S.SMName,SI.RMId,RM.RMName,
				0 AS TotalOutlets ,Count(DISTINCT SI.RtrId) AS OutletsBilled,0 AS Coverage,	
				0 AS ScheduledCalls,0 AS ActualBills,0 AS Efficiecy,
				T.CompanyId,0 as TotalLinesSold,0,0
		FROM  
				SalesInvoice SI				WITH (NOLOCK),	Salesman S WITH (NOLOCK),
				RouteMaster RM				WITH (NOLOCK),	Retailer R WITH (NOLOCK),
				SalesmanMarket SM			WITH (NOLOCK),  RetailerMarket RETMAR     WITH (NOLOCK),
				Product P					WITH (NOLOCK),	SalesInvoiceProduct SIP   WITH (NOLOCK),
				ProductBatch PB				WITH (NOLOCK),	RetailerValueClass RVC    WITH (NOLOCK),
				RetailerCategory RC			WITH (NOLOCK),	RetailerCategorylevel RCL WITH (NOLOCK),
				ProductCategoryLevel PCL    WITH (NOLOCK),
				ProductCategoryValue PCV    WITH (NOLOCK), 
				RetailerValueClassMap RVCM  WITH (NOLOCK),
				#TempRptEfficiencyDatewiseReport T
		WHERE
				SI.SMId = S.SMId				AND SI.RMId = RM.RMId				
				AND SI.RtrId = R.RtrId			AND R.RtrStatus = 1
				AND SI.SMId = SM.SMId			AND RM.RMId = SI.RMId
				AND SM.RMId = RETMAR.RMId		AND RETMAR.RtrId = R.RtrId 
				AND RETMAR.RtrId =Si.RtrId		AND DlvSts <> 3
				AND SIP.PrdId = P.PrdId			AND SI.SalId = SIP.SalId
				AND P.PrdId = PB.PrdId			AND PB.PrdId = SIP.PrdId
				AND SIP.PrdBatId = PB.PrdBatId	AND RVC.CtgMainId=RC.CtgMainId
				AND RVCM.RtrId=SI.RtrId			AND RC.CtgLevelId=RCL.CtgLevelId 
				AND T.SMId = SM.SMId				AND T.RMId = RM.RMId
				AND RVCM.RtrValueClassId=RVC.RtrClassId				
				AND PCV.PrdCtgValMainId=P.PrdCtgValMainId
				AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
					/* Filters */
				AND SalInvDate Between @FromDate and @ToDate 	
				--- Company  
				AND (P.CmpId =  (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR 
								P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				--- SalesMan
				And (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
							    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route 
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level 
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category  
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (SI.RtrId = (CASE @RetailerId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
								SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
					AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					/* Till Here */
		GROUP BY
				SI.SMId,S.SMName,SI.RMId,RM.RMName,P.CmpId,T.CompanyId 
			/* Calculate Total Outlets */
			---	0 - Weekly,1 - BiWeekly,2 - Fort Nightly,3 - Monthly,4 - Daily
		INSERT INTO #TempRptEfficiencyDatewiseReport
		SELECT 
				SM.SMId,SM.SMName,RM.RMId,RM.RMName,
				0 AS TotalOutlets ,0 AS OutletsBilled,0 AS Coverage,	
				Case RtrFrequency 
							When 0 Then Count(DISTINCT R.RtrId) * 4 
							When 2 Then Count(DISTINCT R.RtrId) * 2 
							When 4 Then Count(DISTINCT R.RtrId) * 24  END AS ScheduledCalls,
				0 AS ActualBills,0 AS Efficiecy,
				CompanyId,0 as TotalLinesSold,0,0
		FROM  
				Salesman SM					WITH (NOLOCK),RouteMaster RM			WITH (NOLOCK) ,
				Retailer R					WITH (NOLOCK),RetailerMarket RMARKET	WITH (NOLOCK),
				#TempRptEfficiencyDatewiseReport T	WITH (NOLOCK),RetailerValueClass RVC	WITH (NOLOCK),
				RetailerCategory RC			WITH (NOLOCK),RetailerCategorylevel RCL WITH (NOLOCK),
				RetailerValueClassMap RVCM	WITH (NOLOCK),SalesmanMarket SRM		WITH (NOLOCK) 
		WHERE
				SRM.SMId = SM.SMId 					AND SRM.RMId = RM.RMId 
				AND SRM.RMId = RMARKET.RMId			AND RM.RMId = RMARKET.RMId
				AND R.RtrId = RMARKET.RtrId			AND RtrStatus = 1
				AND T.SMId = SM.SMId				AND T.RMId = RM.RMId
				AND RVCM.RtrId=R.RtrId				AND RC.CtgLevelId=RCL.CtgLevelId 				
				AND RVC.CmpId = T.CompanyId			AND RVC.CtgMainId = RC.CtgMainId	
				AND RC.CtgLevelId=RCL.CtgLevelId	AND RVCM.RtrValueClassId=RVC.RtrClassId			
				/* Filters */
				--- Company  
				AND (T.CompanyId =  (CASE @CmpId WHEN 0 THEN T.CompanyId ELSE 0 END) OR 
								T.CompanyId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				--- SalesMan
				And (SM.SMId = (CASE @SMId WHEN 0 THEN SM.SMId Else 0 END) OR
							    SM.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route 
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level 
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category  
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (R.RtrId = (CASE @RetailerId WHEN 0 THEN R.RtrId ELSE 0 END) OR
								R.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					/* Till Here */
		GROUP BY 
				SM.SMId,SM.SMName,RM.RMId,RM.RMName,CompanyId,RtrFrequency
					
					/* Final Output Query  */
		INSERT INTO #RptEfficiencyDatewiseReport
		SELECT 
				SMId,SMName,RMId,RMName,
				Sum(TotalOutlets) AS TotalOutlets,		Sum(OutletsBilled) AS OutletsBilled,
				Isnull(Sum(TotalOutlets)/ NullIf(Sum(OutletsBilled),0),0) * 100 AS Coverage,
				Sum(TotalOutlets) AS TotalOutlets,
				---Sum(ScheduledCalls) AS ScheduledCalls,	
				Sum(ActualBills) AS ActualBills,
				---Isnull(Sum(ActualBills)/ NullIf(Sum(ScheduledCalls),0),0) * 100 AS Efficiecy,
				Isnull(Sum(OutletsBilled)/ NullIf(Sum(TotalOutlets),0),0) * 100 AS Efficiecy,
				CompanyId AS CompanyId,SUM(TotalLinesSold)TotalLinesSold,
				Isnull(Sum(ActualBills)/ NullIf(Sum(TotalOutlets),0),0) * 100, 
				Isnull(Sum(TotalLinesSold)/ NullIf(Sum(ActualBills),0),0) 
				FROM
				#TempRptEfficiencyDatewiseReport
		GROUP BY 
				SMId,SMName,RMId,RMName,CompanyId
		ORDER BY 
				SMId,RMId
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptEfficiencyDatewiseReport
 		
		SELECT SMId,SMName,RMId,RMName,TotalOutlets,OutletsBilled,Efficiecy,ScheduledCalls,ActualBills,Coverage,CompanyId,
		TotalLinesSold,Productivity,LinesPerCall FROM #RptEfficiencyDatewiseReport  ORDER BY SMName,RMName
				
				/* New Snap Shot Data Stored*/
		IF @Pi_SnapRequired = 1
		BEGIN
			SELECT @NewSnapId = @Pi_SnapId
			
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			
			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
				'(SnapId,UserId,RptId,' + @TblFields + ')' +
				' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ',* FROM #RptEfficiencyDatewiseReport'		
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END 
			/* To Retrieve Data From Snap Data */
	ELSE				
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
								  @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			IF @ErrNo = 0
			BEGIN
				SET @SSQL = 'INSERT INTO #RptEfficiencyDatewiseReport ' +
					'(' + @TblFields + ')' +
					' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
					' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
					' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
					' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))	
					EXEC (@SSQL)
					PRINT 'Retrived Data From Snap Shot Table'
					SELECT * FROM #RptEfficiencyDatewiseReport
			END
			ELSE
			BEGIN
				PRINT 'DataBase or Table not Found'
				RETURN
			END
		END
END
GO
DELETE FROM Configuration WHERE ModuleId='DISTAXCOLL8' AND ModuleName='Discount & Tax Collection'
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'DISTAXCOLL8','Discount & Tax Collection','Enable Invoice Level Discount field in the Billing Screen',1,'',0,8
GO
DELETE FROM Configuration WHERE ModuleId='DISTAXCOLL9' AND ModuleName='Discount & Tax Collection'
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'DISTAXCOLL9','Discount & Tax Collection','Treat Invoice Level Discount as',1,'',1,9
GO
DELETE FROM Configuration WHERE ModuleName='Day End Process' AND ModuleId='DAYENDPROCESS4'
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'DAYENDPROCESS4','Day End Process','Perform automatic delivery of pending Bills after                     day(s)',1,5,1,4
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 399)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(399,'D','2012-07-13',GETDATE(),1,'Core Stocky Service Pack 399')
GO