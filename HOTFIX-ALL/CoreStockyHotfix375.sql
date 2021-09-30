--[Stocky HotFix Version]=375
Delete from Versioncontrol where Hotfixid='375'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('375','2.0.0.5','D','2011-04-28','2011-04-28','2011-04-28',convert(varchar(11),getdate()),'Parle;Major:-J&J Changes;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 375' ,'375'
GO

--SRF-Nanda-235-001

if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplateFinal]
GO

CREATE TABLE [dbo].[RptBillTemplateFinal]
(
	[Base Qty] [numeric](38, 2) NULL,
	[Batch Code] [nvarchar](100) ,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](100) ,
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
	[Company Address1] [nvarchar](100) ,
	[Company Address2] [nvarchar](100) ,
	[Company Address3] [nvarchar](100) ,
	[Company Code] [nvarchar](40) ,
	[Company Contact Person] [nvarchar](200) ,
	[Company EmailId] [nvarchar](100) ,
	[Company Fax Number] [nvarchar](100) ,
	[Company Name] [nvarchar](200) ,
	[Company Phone Number] [nvarchar](100) ,
	[Contact Person] [nvarchar](100) ,
	[CST Number] [nvarchar](100) ,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](200) ,
	[Delivery Boy] [nvarchar](100) ,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](100) ,
	[Distributor Address2] [nvarchar](100) ,
	[Distributor Address3] [nvarchar](100) ,
	[Distributor Code] [nvarchar](40) ,
	[Distributor Name] [nvarchar](100) ,
	[Drug Batch Description] [nvarchar](100) ,
	[Drug Licence Number 1] [nvarchar](100) ,
	[Drug Licence Number 2] [nvarchar](100) ,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) ,
	[EmailID] [nvarchar](100) ,
	[Geo Level] [nvarchar](100) ,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](100) ,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](100) ,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](100) ,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](100) ,
	[PhoneNo] [nvarchar](100) ,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](100) ,
	[Product Name] [nvarchar](400) ,
	[Product Short Name] [nvarchar](200) ,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](400) ,
	[Retailer Address1] [nvarchar](200) ,
	[Retailer Address2] [nvarchar](200) ,
	[Retailer Address3] [nvarchar](200) ,
	[Retailer Code] [nvarchar](100) ,
	[Retailer ContactPerson] [nvarchar](200) ,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](100) ,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](100) ,
	[Retailer EmailId] [nvarchar](200) ,
	[Retailer GeoLevel] [nvarchar](100) ,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](100) ,
	[Retailer Name] [nvarchar](300) ,
	[Retailer OffPhone1] [nvarchar](100) ,
	[Retailer OffPhone2] [nvarchar](100) ,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](100) ,
	[Retailer PhoneNo] [nvarchar](100) ,
	[Retailer Pin Code] [nvarchar](100) ,
	[Retailer ResPhone1] [nvarchar](100) ,
	[Retailer ResPhone2] [nvarchar](100) ,
	[Retailer Ship Address1] [nvarchar](200) ,
	[Retailer Ship Address2] [nvarchar](200) ,
	[Retailer Ship Address3] [nvarchar](200) ,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](100) ,
	[Retailer Village] [nvarchar](200) ,
	[Route Code] [nvarchar](100) ,
	[Route Name] [nvarchar](100) ,
	[Sales Invoice Number] [nvarchar](100) ,
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
	[SalesMan Code] [nvarchar](100) ,
	[SalesMan Name] [nvarchar](100) ,
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
	[TIN Number] [nvarchar](100) ,
	[Uom 1 Desc] [nvarchar](100) ,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](100) ,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](100) ,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[AmtInWrd] [nvarchar](500) ,
	[Product Weight] [numeric](38, 2) NULL,
	[Product UPC] [numeric](38, 0) NULL,
	[SalesInvoice Level Discount] [numeric](38, 6) NULL 
) ON [PRIMARY]
GO

--SRF-Nanda-235-002

if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal_Group]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplateFinal_Group]
GO

CREATE TABLE [dbo].[RptBillTemplateFinal_Group]
(
	[Base Qty] [numeric](38, 2) NULL,
	[Batch Code] [nvarchar](100) ,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](100) ,
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
	[Company Address1] [nvarchar](100) ,
	[Company Address2] [nvarchar](100) ,
	[Company Address3] [nvarchar](100) ,
	[Company Code] [nvarchar](40) ,
	[Company Contact Person] [nvarchar](200) ,
	[Company EmailId] [nvarchar](100) ,
	[Company Fax Number] [nvarchar](100) ,
	[Company Name] [nvarchar](200) ,
	[Company Phone Number] [nvarchar](100) ,
	[Contact Person] [nvarchar](100) ,
	[CST Number] [nvarchar](100) ,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](200) ,
	[Delivery Boy] [nvarchar](100) ,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](100) ,
	[Distributor Address2] [nvarchar](100) ,
	[Distributor Address3] [nvarchar](100) ,
	[Distributor Code] [nvarchar](40) ,
	[Distributor Name] [nvarchar](100) ,
	[Drug Batch Description] [nvarchar](100) ,
	[Drug Licence Number 1] [nvarchar](100) ,
	[Drug Licence Number 2] [nvarchar](100) ,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) ,
	[EmailID] [nvarchar](100) ,
	[Geo Level] [nvarchar](100) ,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](100) ,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](100) ,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](100) ,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](100) ,
	[PhoneNo] [nvarchar](100) ,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](100) ,
	[Product Name] [nvarchar](400) ,
	[Product Short Name] [nvarchar](200) ,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](400) ,
	[Retailer Address1] [nvarchar](200) ,
	[Retailer Address2] [nvarchar](200) ,
	[Retailer Address3] [nvarchar](200) ,
	[Retailer Code] [nvarchar](100) ,
	[Retailer ContactPerson] [nvarchar](200) ,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](100) ,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](100) ,
	[Retailer EmailId] [nvarchar](200) ,
	[Retailer GeoLevel] [nvarchar](100) ,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](100) ,
	[Retailer Name] [nvarchar](300) ,
	[Retailer OffPhone1] [nvarchar](100) ,
	[Retailer OffPhone2] [nvarchar](100) ,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](100) ,
	[Retailer PhoneNo] [nvarchar](100) ,
	[Retailer Pin Code] [nvarchar](100) ,
	[Retailer ResPhone1] [nvarchar](100) ,
	[Retailer ResPhone2] [nvarchar](100) ,
	[Retailer Ship Address1] [nvarchar](200) ,
	[Retailer Ship Address2] [nvarchar](200) ,
	[Retailer Ship Address3] [nvarchar](200) ,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](100) ,
	[Retailer Village] [nvarchar](200) ,
	[Route Code] [nvarchar](100) ,
	[Route Name] [nvarchar](100) ,
	[Sales Invoice Number] [nvarchar](100) ,
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
	[SalesMan Code] [nvarchar](100) ,
	[SalesMan Name] [nvarchar](100) ,
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
	[TIN Number] [nvarchar](100) ,
	[Uom 1 Desc] [nvarchar](100) ,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](100) ,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](100) ,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[AmtInWrd] [nvarchar](500) ,
	[Product Weight] [numeric](38, 2) NULL,
	[Product UPC] [numeric](38, 0) NULL,
	[SalesInvoice Level Discount] [numeric](38, 6) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-235-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBillTemplateFinal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
		SET @SSQL1='UPDATE Rpt SET Rpt.[Product UPC]=P.ConversionFactor 
					FROM 
					(
						SELECT P.PrdId,P.PrdCCode,MAX(U.ConversionFactor)AS ConversionFactor FROM Product P,UOMGroup U
						WHERE P.UOMGroupId=U.UOMGroupId
						GROUP BY P.PrdId,P.PrdCCode
					) P,RptBillTemplateFinal Rpt WHERE P.PrdCCode=Rpt.[Product Code]'
		EXEC (@SSQL1)
	END
	--->Till Here

	--->Added By Nanda on 2011/04/15 for J&J
	if not exists (Select Id,name from Syscolumns where name = 'SalesInvoice Level Discount' and id in (Select id from 
		Sysobjects where name ='RptBillTemplateFinal'))
	begin
		ALTER TABLE [dbo].[RptBillTemplateFinal]
		ADD [SalesInvoice Level Discount] NUMERIC(38,6) NULL DEFAULT 0 WITH VALUES
	END

	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='SalesInvoice Level Discount')
	BEGIN
		SET @SSQL1='UPDATE Rpt SET Rpt.[SalesInvoice Level Discount]=SI.SalInvLvlDisc
		FROM SalesInvoice SI,RptBillTemplateFinal Rpt WHERE SI.SalId=Rpt.[SalId]'

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
	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
	End

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

	----------------------------------Credit Debit Adjustment
	SELECT @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	IF @Sub_Val = 1
	BEGIN
		INSERT INTO RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		SELECT A.SalId,S.SalInvNo,A.CrNoteNumber,A.CrAdjAmount,A.AdjSoFar,CNR.Remarks,@Pi_UsrId
		FROM SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B,CreditNoteRetailer CNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND CNR.CrNoteNumber=A.CrNoteNumber
		UNION ALL
		SELECT A.SalId,S.SalInvNo,A.DbNoteNumber,A.DbAdjAmount,A.AdjSoFar,DNR.Remarks,@Pi_UsrId
		FROM SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B,DebitNoteRetailer DNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND DNR.DbNoteNumber=A.DbNoteNumber
	END

	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId,
		Rate,MRP,GrossAmount,SchemeAmount,DBDiscAmount,CDAmount,SplDiscAmount,TaxAmount)
		Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId,
		D.PrdUnitSelRte,D.PrdUnitMRP,D.PrdGrossAmt,D.PrdSchDisAmt,D.PrdDBDisAmt,D.PrdCDDisAmt,D.PrdSplDisAmt,D.PrdTaxAmt
		From ReturnHeader H,ReturnProduct D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B
		Where returntype = 1
		and H.ReturnID = D.ReturnID
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId,0,0,0,0,0,0,0,0
		From ReturnPrdHdForScheme D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B,ReturnHeader H,ReturnProduct T
		WHERE returntype = 1 AND
		D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = T.SalId
		and H.ReturnID = T.ReturnID
		and S.SalInvNo = B.[Bill Number]
	End

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
			[UsrId],[Visibility],[AmtInWrd],[Product Weight],[Product UPC],[SalesInvoice Level Discount]
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
		[UsrId],[Visibility],[AmtInWrd],SUM([Product Weight]),SUM([Product UPC]),[SalesInvoice Level Discount]
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
		[UsrId],[Visibility],[AmtInWrd],[SalesInvoice Level Discount]
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
		[UsrId],[Visibility],[AmtInWrd],[Product Weight],[Product UPC],[SalesInvoice Level Discount]
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-235-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_PurchaseReceipt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_PurchaseReceipt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PurchaseReceipt 0
--SELECT * FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE CompInvNo='7083240274'--'7083240274'
--SELECT MIN(TransDate) FROM StockLedger
SELECT * FROM ErrorLog
SELECT * FROM ETLTempPurchaseReceipt
SELECT * FROM ETLTempPurchaseReceiptProduct
SELECT * FROM ETLTempPurchaseReceiptPrdLineDt
SELECT * FROM ETLTempPurchaseReceiptClaimScheme
SELECT * FROM ETLTempPurchaseReceiptOtherCharges
SELECT * FROM ETLTempPurchaseReceiptCrDbAdjustments
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_PurchaseReceipt]
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
	DELETE FROM ETLTempPurchaseReceiptCrDbAdjustments WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)	
	DELETE FROM ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1

	TRUNCATE TABLE ETL_Prk_PurchaseReceiptCrDbAdjustments
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptOtherCharges
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim
	TRUNCATE TABLE ETL_Prk_PurchaseReceipt	
	--------------------------------------

	DECLARE @ErrStatus			INT
	DECLARE @BatchNo			NVARCHAR(30)
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
	DECLARE @VatBatch			INT
	DECLARE @BundleDeal			INT

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

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0)	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Qty','Invoice Qty should be gretaer than zero for Product:'+ProductCode+
		' for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0
	END			
	--->Till Here

	--->Added By Nanda on 10/11/2010
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreePurchaseClaim' AND Status=1)
	BEGIN
		IF NOT EXISTS(SELECT * FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
		WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote')
		BEGIN
			INSERT INTO InvToAvoid(CmpInvNo)
			SELECT DISTINCT CompInvNo FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote'
			
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Purchase Receipt',' Debit Note',' Debit Note:'+Prk.RefNo+
			' not adjusted agains claim for Invoice:'+CompInvNo 
			FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote'
		END

		IF NOT EXISTS(SELECT * FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
		WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote')
		BEGIN
			INSERT INTO InvToAvoid(CmpInvNo)
			SELECT DISTINCT CompInvNo FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote'
			
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Purchase Receipt','Credit Note',' Credit Note:'+Prk.RefNo+
			' not available for Invoice:'+CompInvNo 
			FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote'
		END
	END

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE NetValue<=0)
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE NetValue<=0

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','NetValue','NetValue<=0 for Company Invoice No:'+CompInvNo+' ' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE NetValue<=0
	END
	--->Till Here

	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT DISTINCT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,Qty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,ISNULL(VatBatch,0),ISNULL(BundleDeal,0)
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
	@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
	@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@VatBatch,@BundleDeal
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--To insert into ETL_Prk_PurchaseReceiptPrdDt
		IF(@FreeSchemeFlag='0')
		BEGIN
			INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount],[NewPrd])
			VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@Qty*@ListPrice,
			@PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty,@VatBatch)
		END

		--To insert into ETL_Prk_PurchaseReceiptClaim
		IF(@FreeSchemeFlag='1')
		BEGIN
			INSERT INTO ETL_Prk_PurchaseReceiptClaim([Company Invoice No],[Type],[Ref No],[Product Code],
			[Batch Code],[Qty],[Stock Type],[Amount])
			VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0)
		END

		SET @RowId=@RowId+1

		FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
		@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@VatBatch,@BundleDeal
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase

	--To insert into ETL_Prk_PurchaseReceipt
	SELECT @SupplierCode=SpmCode FROM Supplier WHERE SpmDefault=1
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter)

	--->Added By Nanda on 10/11/2010
	--To insert into ETL_Prk_PurchaseReceiptOtherCharges
	INSERT INTO ETL_Prk_PurchaseReceiptOtherCharges([Company Invoice No],[OC Description],Amount)
	SELECT CompInvNo,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE CompInvNo IN 
	(SELECT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid))
	AND DownLoadFlag='D' AND AdjType='OtherCharges'
	
	--To insert into ETL_Prk_PurchaseReceiptCrDbAdjustement
	INSERT INTO ETL_Prk_PurchaseReceiptCrDbAdjustments([Company Invoice No],[Adjustment Type],[Ref No],[Amount])
	SELECT CompInvNo,AdjType,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE CompInvNo IN 
	(SELECT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid))
	AND DownLoadFlag='D' AND AdjType<>'OtherCharges'
	--->Till Here

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
					EXEC Proc_Validate_PurchaseReceiptOtherCharges @Po_ErrNo= @ErrStatus OUTPUT
					IF @ErrStatus =0
					BEGIN
						EXEC Proc_Validate_PurchaseReceiptCrDbAdjustments @Po_ErrNo= @ErrStatus OUTPUT
						IF @ErrStatus =0
						BEGIN
							SET @ErrStatus=@ErrStatus					
						END
					END
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

	--->Added By Nanda on 10/11/2010
	UPDATE Cn2Cs_Prk_PurchaseReceiptAdjustments SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceiptOtherCharges)
	AND AdjType='OtherCharges'	

	UPDATE Cn2Cs_Prk_PurchaseReceiptAdjustments SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceiptCrDbAdjustments)
	AND AdjType<>'OtherCharges'
	--->Till Here

	SET @Po_ErrNo= @ErrStatus	
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-235-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ReturnSchMultiFree]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ReturnSchMultiFree]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec Proc_ReturnSchMultiFree 1,2,40002,40001,1,0
CREATE     Procedure [dbo].[Proc_ReturnSchMultiFree]
(
	@Pi_UsrId 		INT,
	@Pi_TransId		INT,
	@Pi_LcnId		INT,
	@Pi_SchId		INT,
	@Pi_SlabId		INT,
	@Pi_SalId		INT			
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSchMultiFree
* PURPOSE	: To Return the Free Product Details for Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 25/04/2007
* NOTE		: General SP for Returning the Free Product Details for Selected Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FreeQty As INT
	DECLARE @NoOfTimes As NUMERIC(38,6)
	DECLARE @AvailableQty TABLE
	(
		PrdId		INT,
		AvailQty	INT
	)
	DECLARE @NetAvailableQty TABLE
	(
		PrdId		INT,
		AvailQty	INT
	)
	DECLARE @FreePrdQty TABLE
	(
		PrdId		INT,
		AvailQty	INT,
		ToGive		INT,
		SeqId		INT
	)
	DECLARE @NetFreePrdQty TABLE
	(
		PrdId		INT,
		AvailQty	INT,
		ToGive		INT,
		SeqId		INT
	)
	IF EXISTS (SELECT OpnAndOR FROM SchemeSlabFrePrds WHERE SchId = @Pi_SchId AND SlabId = @Pi_SlabId AND OpnAndOR = 1)
	BEGIN
		IF NOT EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtFreePrd WHERE SalId = @Pi_SalId AND
				SchId = @Pi_SchId AND SlabId = @Pi_SlabId)
		BEGIN
			SELECT @FreeQty = FreeToBeGiven FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND
				TransId = @Pi_TransId AND SchId = @Pi_SchId AND SlabId = @Pi_SlabId
			INSERT INTO @AvailableQty(PrdId,AvailQty)
			SELECT A.PrdId,ISNULL(SUM((PrdBatLcnFre - PrdBatLcnResFre) + (PrdBatLcnSih - PrdBatLcnResSih)),0)
				FROM ProductBatchLocation A INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.FreePrdId
				WHERE A.LcnId = @Pi_LcnId AND B.Usrid = @Pi_Usrid AND B.TransId = @Pi_TransId AND
				B.SchId = @Pi_SchId AND B.SlabId = @Pi_SlabId GROUP BY A.PrdId
			INSERT INTO @AvailableQty(PrdId,AvailQty)
			SELECT A.PrdId,-1 * ISNULL(SUM(BaseQty),0) As AvailQty FROM BilledPrdHdForScheme A
				INNER JOIN @AvailableQty B ON A.PrdId = B.PrdId
				WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
				GROUP BY A.PrdId
			INSERT INTO @AvailableQty(PrdId,AvailQty)
			SELECT A.FreePrdId,-1 * ISNULL(SUM(FreeToBeGiven),0) As AvailQty FROM BillAppliedSchemeHd A
				INNER JOIN @AvailableQty B ON A.FreePrdId = B.PrdId
				WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId AND A.FreePrdBatId > 0
				GROUP BY A.FreePrdId
			INSERT INTO @NetAvailableQty(PrdId,AvailQty)
			SELECT PrdId,ISNULL(SUM(AvailQty),0) As AvailQty FROM @AvailableQty
				GROUP BY PrdId
				HAVING ISNULL(SUM(AvailQty),0) > @FreeQty
			IF NOT EXISTS (SELECT * FROM @NetAvailableQty)
			BEGIN
				SELECT @NoOfTimes = NoOfTimes FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND
				TransId = @Pi_TransId AND SchId = @Pi_SchId AND SlabId = @Pi_SlabId
				INSERT INTO @FreePrdQty (PrdId,AvailQty,ToGive,SeqId)
				SELECT A.PrdId,ISNULL(SUM((PrdBatLcnFre - PrdBatLcnResFre) + (PrdBatLcnSih - PrdBatLcnResSih)),0),
				(FreeQty * @NoOfTimes) As ToGive,SeqId FROM ProductBatchLocation A INNER JOIN
				SchemeSlabMultiFrePrds B ON A.PrdId = B.PrdId
				WHERE A.LcnId = @Pi_LcnId AND B.SchId = @Pi_SchId AND B.SlabId = @Pi_SlabId
				GROUP BY A.PrdId,B.SeqId,FreeQty ORDER BY B.SeqId
				INSERT INTO @FreePrdQty (PrdId,AvailQty,ToGive,SeqId)
				SELECT A.PrdId,-1 * ISNULL(SUM(BaseQty),0) As AvailQty,0,B.SeqId FROM BilledPrdHdForScheme A
				INNER JOIN SchemeSlabMultiFrePrds B ON A.PrdId = B.PrdId
				WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
				GROUP BY A.PrdId,B.SeqId ORDER BY B.SeqId
				INSERT INTO @FreePrdQty (PrdId,AvailQty,ToGive,SeqId)
				SELECT A.FreePrdId,-1 * ISNULL(SUM(FreeToBeGiven),0) As AvailQty,0,B.SeqId
				FROM BillAppliedSchemeHd A
				INNER JOIN SchemeSlabMultiFrePrds B ON A.FreePrdId = B.PrdId
				WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId AND A.FreePrdBatId > 0
				GROUP BY A.FreePrdId,B.SeqId ORDER BY B.SeqId
				INSERT INTO @NetFreePrdQty (PrdId,AvailQty,ToGive,SeqId)
				SELECT TOP 1 A.PrdId,ISNULL(SUM(AvailQty),0) As AvailQty,
				ISNULL(SUM(ToGive),0) As ToGive,A.SeqId FROM @FreePrdQty A
				GROUP BY A.PrdId,A.SeqId
				HAVING ISNULL(SUM(AvailQty),0) > ISNULL(SUM(ToGive),0)
				ORDER BY A.SeqId
				UPDATE BillAppliedSchemeHd SET FreePrdId = A.PrdId,FreeToBeGiven = A.ToGive
					FROM @NetFreePrdQty A WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
					AND BillAppliedSchemeHd.SchId = @Pi_SchId AND
					BillAppliedSchemeHd.SlabId = @Pi_SlabId
			END
			
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET FreePrdId = A.FreePrdId, FreePrdBatId = A.FreePrdBatId
				FROM SalesInvoiceSchemeDtFreePrd A WHERE A.SalId = @Pi_SalId AND
				A.SchId = @Pi_SchId AND A.SlabId = @Pi_SlabId AND BillAppliedSchemeHd.SchId = @Pi_SchId
				AND BillAppliedSchemeHd.SlabId = @Pi_SlabId AND Usrid = @Pi_UsrId AND
				TransId = @Pi_TransId AND BillAppliedSchemeHd.FreePrdId = A.FreePrdId AND BillAppliedSchemeHd.FreePrdBatId = A.FreePrdBatId
		END	
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-235-006

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_Prk_TaxSetting]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_Prk_TaxSetting]
GO

CREATE TABLE [dbo].[ETL_Prk_TaxSetting]
(
	[TaxGroupCode] [nvarchar](200) NULL,
	[Type] [nvarchar](200) NULL,
	[PrdTaxGroupCode] [nvarchar](200) NULL,
	[TaxCode] [nvarchar](200) NULL,
	[Percentage] [numeric](38, 6) NULL,
	[ApplyOn] [nvarchar](200) NULL,
	[Discount] [nvarchar](200) NULL,
	[SchDiscount] [nvarchar](200) NULL,
	[DBDiscount] [nvarchar](200) NULL,
	[CDDiscount] [nvarchar](200) NULL,
	[ApplyTax] [nvarchar](200) NULL,
	[DownloadFlag] [varchar](1) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-235-007

if not exists (Select Id,name from Syscolumns where name = 'SalInvLineCount' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_DailySales'))
begin
	ALTER TABLE [dbo].[Cs2Cn_Prk_DailySales]
	ADD [SalInvLineCount] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'SalInvLineCount' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_DailySales_Archive'))
begin
	ALTER TABLE [dbo].[Cs2Cn_Prk_DailySales_Archive]
	ADD [SalInvLineCount] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-235-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_TaxSetting]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_TaxSetting]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_CN2CS_TaxSetting 0
SELECT * FROM ErrorLog
SELECT * FROM TaxSettingMaster
SELECT * FROM TaxSettingDetail
ROLLBACK TRANSACTION
*/

CREATE  PROCEDURE [dbo].[Proc_Cn2Cs_TaxSetting] 
(
	@Po_ErrNo INT OUTPUT
)
AS
/*************************************************************************************************************
* PROCEDURE	: Proc_CN2CS_TaxSetting
* PURPOSE	: To Store TaxGroup Setting records  from xml file in the Table TaxGroupSetting
* CREATED	: Mahalakshmi.A
* CREATED DATE	: 20/08/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
* 07/09/2009    Nandakumar R.G  Change the validations for Tax on Tax and other basic validations
* 09.09.2009    Panneer			Update the Download Flag in Parking Table
* 19/08/2010    Nandakumar R.G  Discount Validation Changes
* 28/04/2011    Nandakumar R.G  Discount Validation Changes
**************************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TaxGroupCode	 AS NVARCHAR(200)
	DECLARE @Type			 AS NVARCHAR(200)
	DECLARE @PrdTaxGroupCode AS NVARCHAR(200)
	DECLARE @TaxCode		 AS NVARCHAR(200)
	DECLARE @Percentage	     AS NUMERIC(38,6)
	DECLARE @ApplyOn		 AS NVARCHAR(100)
	DECLARE @Discount		 AS NVARCHAR(100)
	DECLARE @Tabname		 AS NVARCHAR(100)
	DECLARE @ErrDesc		 AS NVARCHAR(1000)
	DECLARE @sSql			 AS NVARCHAR(4000)
	DECLARE @ErrStatus		 AS INT
	DECLARE @Taction		 AS INT
	DECLARE @TaxSeqId	 AS INT
	DECLARE @RtrId		 AS INT
	DECLARE @PrdId		 AS INT
	DECLARE @BillSeqId	 AS INT
	DECLARE @Slno		 AS INT
	DECLARE @ColNo		 AS INT
	DECLARE @iCntColNo	 AS INT
	DECLARE @iColType	 AS INT
	DECLARE @ColValue	 AS INT
	DECLARE @RowId		 AS INT
	DECLARE @TaxId		 AS INT
	DECLARE @iApplyOn	 AS INT
	DECLARE @iDiscount	 AS INT
	DECLARE @DColNo		 AS INT
	DECLARE @FieldDesc	 AS NVARCHAR(100)
	DECLARE @SColNo		 AS INT
	DECLARE @ColId		 AS INT
	DECLARE @SlNo1		 AS INT
	DECLARE @SlNo2		 AS INT
	DECLARE @BillSeqId_Temp	AS	INT
	DECLARE @EffetOnTax		AS	INT

	DECLARE @SchDiscount		 AS NVARCHAR(100)
	DECLARE @DBDiscount		 AS NVARCHAR(100)
	DECLARE @CDDiscount		 AS NVARCHAR(100)

	/*
		SET @iColType=1   For TaxPercentage Value Column
		SET @iColType=2	  For MRP,SellingRate,PurchaseRate , Bill Column Sequence Value and Purchase Column Sequence
		SET @iColType=3   For Tax Configuration TaxCode Column Value
		SET @ColValue=0	  For "NONE"
		SET @ColValue=1   For "ADD"
		SET @ColValue=2   For "REDUCE"		
	*/
	
	SET @Tabname = 'Etl_Prk_TaxSetting'
	SET @Po_ErrNo=0
	SET @iCntColNo=0
	DECLARE @TblColNo TABLE
	(
		ColNo			INT IDENTITY(0,1) NOT NULL,
		SlNo1			INT,
		SlNo2			INT,
		FieldDesc		NVARCHAR(50)
	)
	DECLARE @T1 TABLE
	(
		SlNo			INT,
		FieldDesc		NVARCHAR(50)
	)
	DELETE FROM Etl_Prk_TaxSetting WHERE DownLoadFlag='Y'
	DECLARE Cur_TaxSettingMaster CURSOR		--TaxSettingMaster Cursor
	FOR SELECT DISTINCT ISNULL(TaxGroupCode,''),ISNULL(Type,''),ISNULL(PrdTaxGroupCode,'')
	FROM Etl_Prk_TaxSetting WHERE DownloadFlag='D'
	OPEN Cur_TaxSettingMaster
	
	FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		--Check the Empty Values for TaxSetting Master
		SET @iCntColNo=6
		IF @TaxGroupCode=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Tax Group Code: ' + @TaxGroupCode + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Group code',@ErrDesc)
		END
		IF @Type=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Type ' + @Type + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Type',@ErrDesc)
		END
		IF @PrdTaxGroupCode=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Product Tax Group Code ' + @PrdTaxGroupCode + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Type',@ErrDesc)
		END
		--Till Here
		IF NOT EXISTS  (SELECT * FROM TaxgroupSetting WHERE RtrGroup = @TaxGroupCode) --Get the Retailer/Supplier TaxGroupId's
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'TaxGroupCode ' + @TaxGroupCode + ' is not available' 		
			INSERT INTO Errorlog VALUES (2,@Tabname,'Tax Group Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @RtrId=TaxGroupId FROM TaxGroupSetting WHERE RtrGroup= @TaxGroupCode
		END
		IF NOT EXISTS  (SELECT * FROM TaxgroupSetting WHERE PrdGroup = @PrdTaxGroupCode) --Get the Product TaxGroupId's
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'Product TaxGroupCode ' + @PrdTaxGroupCode + ' is not available' 		
			INSERT INTO Errorlog VALUES (2,@Tabname,'Product Tax Group Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @PrdId=TaxGroupId FROM TaxGroupSetting WHERE PrdGroup= @PrdTaxGroupCode
		END
		
		DELETE FROM @T1
		IF UPPER(@Type)='RETAILER'
		BEGIN
			SELECT DISTINCT @BillSeqId=BillSeqId FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo < (SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)
			SELECT @iCntColNo=@iCntColNo+COUNT(BillSeqId) FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo < (SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)
			
			INSERT INTO @T1(SlNo,FieldDesc)
			SELECT Slno,FieldDesc
			FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo <
			(SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) Order By SlNo
		END
		ELSE IF UPPER(@Type)='SUPPLIER'
		BEGIN
			SELECT DISTINCT @BillSeqId=PurSeqId FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))  and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster)
			
			SELECT @iCntColNo=@iCntColNo+COUNT(PurSeqId) FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))  and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster)
			INSERT INTO @T1(SlNo,FieldDesc)
			SELECT Slno,FieldDesc FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))
			and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster) Order By SlNo
		END
		SELECT @iCntColNo=@iCntColNo+(COUNT(TaxId)) FROM TaxConfiguration
		SELECT @TaxSeqId= dbo.Fn_GetPrimaryKeyInteger('TaxSettingMaster','TaxSeqId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
		IF  @Po_ErrNo=0
		BEGIN	
			INSERT INTO TaxSettingMaster(TaxSeqId,RtrId,PrdId,SequenceDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@TaxSeqId,@RtrId,@PrdID,CONVERT(NVARCHAR(11),GETDATE(),121),1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
			SET @sSql= 'INSERT INTO TaxSettingMaster(TaxSeqId,RtrId,PrdId,SequenceDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@TaxSeqId AS NVARCHAR(100)) + ',' + CAST(@RtrId AS NVARCHAR(100)) +','+ CAST(@PrdId AS NVARCHAR(100))+ ','''
						+ CONVERT(NVARCHAR(11),GETDATE(),121)+''',1,1,''' + CONVERT(NVARCHAR(11),GETDATE(),121)+''',1,'''+ CONVERT(NVARCHAR(11),GETDATE(),121)+ ''')'
						
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE	Tabname = 'TaxSettingMaster' AND Fldname = 'TaxSeqId'
			
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSettingMaster'' AND Fldname = ''TaxSeqId'''
			
			INSERT INTO Translog(strSql1) Values (@sSQL)
		END
		
		DECLARE @TaxSettingTable TABLE
		(
			TaxId			INT,
			TaxGrpCode		NVARCHAR(200),
			Type			NVARCHAR(200),
			TaxPrdGrpCode	NVARCHAR(200),
			TaxCode			NVARCHAR(200),
			Percentage		NUMERIC(38,6),
			Applyon			NVARCHAR(200),
			Discount		NVARCHAR(200),
			SchDiscount		NVARCHAR(200),
			DBDiscount		NVARCHAR(200),
			CDDiscount		NVARCHAR(200)
		)

		DELETE FROM @TaxSettingTable
		INSERT INTO @TaxSettingTable
		SELECT DISTINCT TC.TaxId, ISNULL(ETL1.TaxGroupCode,''),ISNULL(ETL1.Type,''),
		ISNULL(ETL1.PrdTaxGroupCode,''),ISNULL(TC.TaxCode,''),ISNULL(ETL1.Percentage,0),
		ISNULL(ETL1.ApplyOn,'None'),ISNULL(ETL1.Discount,'None'),ISNULL(ETL1.SchDiscount,'None'),
		ISNULL(ETL1.DBDiscount,'None'),ISNULL(ETL1.CDDiscount,'None') 
		FROM
		(SELECT ISNULL(ETL.TaxGroupCode,'') AS TaxGroupCode,ISNULL(ETL.Type,'') AS Type,ISNULL(ETL.TaxCode,'') AS TaxCode,
		ISNULL(ETL.PrdTaxGroupCode,'') AS PrdTaxGroupCode,
		ISNULL(ETL.Percentage,0) AS Percentage,ISNULL(ETL.ApplyOn,'') AS ApplyOn,ISNULL(ETL.Discount,'') AS Discount,
		ISNULL(ETL.SchDiscount,'') AS SchDiscount,ISNULL(ETL.DBDiscount,'') AS DBDiscount,ISNULL(ETL.CDDiscount,'') AS CDDiscount
		FROM Etl_Prk_TaxSetting ETL
		WHERE DownloadFlag='D' AND TaxGroupCode=@TaxGroupCode AND PrdTaxGroupCode=@PrdTaxGroupCode) ETL1
		RIGHT OUTER JOIN TaxConfiguration TC ON TC.TaxCode=ETL1.TaxCode

		SET @RowId=0

		DECLARE Cur_TaxSettingDetail CURSOR		--TaxSettingDetail Cursor
		FOR SELECT TaxGrpCode,Type,TaxPrdGrpCode,TaxCode,Percentage,Applyon,Discount,SchDiscount,DBDiscount,CDDiscount
		FROM @TaxSettingTable Order By TaxId
		OPEN Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount,
		@SchDiscount,@DBDiscount,@CDDiscount
		WHILE @@FETCH_STATUS=0
		BEGIN
			SET @RowId=@RowId+1
			--Nanda
			--SELECT @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount
			
			IF @TaxCode=''	--Check Empty Values For TaxSetting Details
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Tax Code' + @TaxCode + ' should not be Empty'
				INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Code',@ErrDesc)
			END
			
			IF @Percentage<0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Percentage' + CAST(@Percentage AS NVARCHAR(20)) + ' should not be Empty'
				INSERT INTO Errorlog VALUES (1,@Tabname,'Percentage',@ErrDesc)
			END
			IF @Applyon=''
			BEGIN
				SET @iApplyOn=0
			END
			ELSE IF UPPER(@ApplyOn)='SELLINGRATE' OR UPPER(@ApplyOn)='MRP' OR UPPER(@ApplyOn)='PURCHASERATE'
			BEGIN
				SET @iApplyOn=1
			END
			ELSE
			BEGIN
				SET @iApplyOn=2
			END
			IF @Discount='ADD'
			BEGIN
				SET @iDiscount=1
			END
			ELSE IF UPPER(@Discount)='REDUCE'
			BEGIN
				SET @iDiscount=2
			END
			ELSE
			BEGIN
				SET @iDiscount=0
			END		
			--Till Here
			IF NOT EXISTS  (SELECT * FROM TaxConfiguration WHERE TaxCode = @TaxCode )
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Tax Code: ' + @TaxCode + ' is not available' 		
				INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Code',@ErrDesc)
			END
			ELSE
			BEGIN
				SELECT @TaxId=TaxId FROM TaxConfiguration WHERE TaxCode=@TaxCode	
			END
			DELETE FROM @TblColNo
			INSERT INTO @TblColNo(SlNo1,SlNo2,FieldDesc)
			SELECT 1,1,'TaxID' AS FieldDesc
			UNION
			SELECT 2,1,'Tax Name' AS FieldDesc
			UNION
			SELECT 3,1,'Tax%' AS FieldDesc
			UNION
			SELECT 4,1,'MRP' AS FieldDesc
			UNION
			SELECT 5,1,'SELLING RATE' AS FieldDesc
			UNION
			SELECT 6,1,'PURCHASE RATE' AS FieldDesc
			UNION
			SELECT 7,Slno,FieldDesc FROM @T1
			UNION
			SELECT 8,TaxId,TaxName FROM TaxConfiguration
			
			SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			
			INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
			ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RowId,1,@SlNo,@BillSeqId,@TaxSeqId,1,@TaxId,@TaxId,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
			
			SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
				+ CAST(@RowId AS NVARCHAR(100)) + ',1,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
				+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',1,' + CAST(@TaxId AS NVARCHAR(100)) + ',' +CAST(@TaxId AS NVARCHAR(100)) + ',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
			ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RowId,3,@SlNo,@BillSeqId,@TaxSeqId,1,0,@Percentage,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					
			SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
				+ CAST(@RowId AS NVARCHAR(100)) + ',3,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
				+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',1,0,' +CAST(@Percentage AS NVARCHAR(100)) + ',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			SET @sColNo=4
			
			--------TaxSetting1-->Price Settings---------------------
			DECLARE Cur_TaxSetting1 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR SELECT ColNo,FieldDesc FROM @TblColNo WHERE SlNo1>3 AND SlNo1<7
			OPEN Cur_TaxSetting1
			FETCH NEXT FROM Cur_TaxSetting1 INTO @DColNo,@FieldDesc
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF @sColNo=4 AND UPPER(@ApplyOn)='MRP'
				BEGIN
					--SET MRP as 1 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					--SET Sellling Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF @sColNo=5 AND UPPER(@ApplyOn)='SELLINGRATE'	
				BEGIN
					--SET MRP AS Value as 0
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',4,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Selling Rate Value as 1
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',5,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF @sColNo=6 AND UPPER(@ApplyOn)='PURCHASERATE'	
				BEGIN
					--SET MRP AS Value as 0
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',4,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Sellling Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 1						
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF EXISTS(SELECT TaxCode FROM TaxConfiguration WHERE TaxCode=@ApplyOn) OR UPPER(@ApplyOn)='NONE'
				BEGIN					
					IF @sColNo=4
					BEGIN
						--SET MRP as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					END
					ELSE IF @sColNo=5
					BEGIN
						--SET Sellling Rate as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
						
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF @sColNo=6
					BEGIN
						--SET Purchase Rate as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
												
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END	
--				--Nanda
--				SELECT * FROM TaxSettingDetail WHERE TaxSeqId=@TaxSeqId AND RowId=@RowId
				SET @sColNo=@sColNo+1
	
				FETCH NEXT FROM Cur_TaxSetting1 INTO @DColNo,@FieldDesc
			END
			CLOSE Cur_TaxSetting1
			DEALLOCATE Cur_TaxSetting1
			-----TaxSetting1--------------------------------
			----------------TaxSetting2-->Bill/Purchase Column Sequnce Settings---------------------
			SET @sColNo=7
			SET @ColId=4
			--Nanda
			--SELECT ColNo,SlNo1,FieldDesc FROM @TblColNo WHERE SlNo1=7
			DECLARE Cur_TaxSetting2 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR
				SELECT ColNo,SlNo1,FieldDesc,SlNo2  FROM @TblColNo WHERE SlNo1=7
			OPEN Cur_TaxSetting2
			FETCH NEXT FROM Cur_TaxSetting2 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			WHILE @@FETCH_STATUS=0
			BEGIN
				
				SET @EffetOnTax=0
				IF UPPER(@Type)='RETAILER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(BillSeqId) FROM dbo.BillSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.BillSequenceDetail WHERE BillSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2

					--->Added By Nanda on 28/04/2011										
					IF @FieldDesc='Spl. Disc' 
					BEGIN
						IF @Discount='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@Discount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='Sch Disc' 
					BEGIN
						IF @SchDiscount='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@SchDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='DB Disc' 
					BEGIN
						IF @DBDiscount='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@DBDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='CD Disc'
					BEGIN
						IF @CDDiscount='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@CDDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE
					BEGIN
						IF @Discount='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@Discount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					--->Till Here
				END
				ELSE IF UPPER(@Type)='SUPPLIER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(PurSeqId) FROM dbo.PurchaseSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.PurchaseSequenceDetail WHERE PurSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2
				END
				
				IF @iApplyOn=2
				BEGIN
					SET @EffetOnTax=0
				END				
				SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
				INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
				ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				--VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,2,@ColId,@EffetOnTax,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
				VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,2,@ColId,@iDiscount,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,'+ CAST(@ColId AS NVARCHAR(100))+ ',' +CAST(@EffetOnTax AS NVARCHAR(100))+',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
				
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				
				UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
				SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
				INSERT INTO Translog(strSql1) Values (@sSQL)					
				SET @sColNo=@sColNo+1
				SET @ColId=@ColId+1
				FETCH NEXT FROM Cur_TaxSetting2 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			END
			CLOSE Cur_TaxSetting2
			DEALLOCATE Cur_TaxSetting2
			------TaxSetting2-----------------------
			-------TaxSetting3-->Tax On Tax Settings-----------------------
			SET @sColNo=@sColNo
			SET @ColId=1
			
			DECLARE Cur_TaxSetting3 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR SELECT ColNo,SlNo1,FieldDesc,SlNo2 FROM @TblColNo WHERE SlNo1=8 AND SlNo2<>@TaxId
			OPEN Cur_TaxSetting3
			FETCH NEXT FROM Cur_TaxSetting3 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			WHILE @@FETCH_STATUS=0
			BEGIN
				SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
				IF @iApplyOn<>2
				BEGIN
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,0,1,1,
					CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT * FROM TaxConfiguration WHERE TaxCode=@Applyon AND TaxId=@SlNo2)
					BEGIN
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,@SlNo2,1,1,
						CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @iApplyOn=1
					END
					ELSE
					BEGIN
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,0,1,1,
						CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					END
				END
				SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',3,'+ CAST(@TaxId AS NVARCHAR(100))+ ',0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
				
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
				SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
				INSERT INTO Translog(strSql1) Values (@sSQL)
				SET @ColId=@ColId+1
				FETCH NEXT FROM Cur_TaxSetting3 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			END
			CLOSE Cur_TaxSetting3
			DEALLOCATE Cur_TaxSetting3
			UPDATE Etl_Prk_TaxSetting  SET DownloadFlag = 'Y'
			WHERE TaxGroupCode = @TaxGroupCode AND TaxCode = @TaxCode AND Percentage = @Percentage
			AND Type = @Type AND PrdTaxGroupCode = @PrdTaxGroupCode
			FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount,
			@SchDiscount,@DBDiscount,@CDDiscount
		END
		CLOSE Cur_TaxSettingDetail
		DEALLOCATE Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	END
	CLOSE Cur_TaxSettingMaster
	DEALLOCATE Cur_TaxSettingMaster	

	UPDATE TaxSettingDetail SET ColVal=0 WHERE ColId=1 AND ColType=2 AND CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10))
	NOT IN (SELECT CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) FROM TaxSettingDetail WHERE ColType=1 AND ColId IN(SELECT TaxId FROM TaxConfiguration WHERE TaxCode='VAT'))
	AND  CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) IN (
	SELECT CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) FROM TaxSettingDetail WHERE ColType=1 AND ColId=0 AND ColVal=0)

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-235-009

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
		UploadFlag		,
		SalInvLineCount
	)
	SELECT 	@DistCode,A.SalInvNo,A.SalInvDate,A.SalDlvDate,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,
	A.OtherCharges,A.SalInvLvlDisc AS InvLevelDiscAmt,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,A.LcnId,L.LcnCode,
	B.SMCode,B.SMName,C.RMCode,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,
	ISNULL(E.VehicleRegNo,'') AS VehicleName,D.DlvBoyName,F.RMCode,F.RMName,H.PrdCCode,I.CmpBatCode,
	G.BaseQty AS SalInvQty ,G.PrdUom1EditedSelRate,G.PrdUom1EditedNetRate,G.SalManFreeQty AS SalInvFree ,
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount,
	'N' AS UploadFlag,0
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

	--->Added By Nanda on 28/04/2011
	UPDATE A SET SalInvLineCount=B.SalInvLineCount
	FROM Cs2Cn_Prk_DailySales A,(SELECT SI.SalInvNo,COUNT(SIP.PrdId) AS SalInvLineCount 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP WHERE 
	SI.DlvSts IN (4,5) AND SI.UPload=0 AND SI.SalId=SIP.SalId
	GROUP BY SI.SalInvNo) B
	WHERE A.SalInvNo=B.SalInvNo
	--->Till Here

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

--SRF-Nanda-235-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBillWisePrdWise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBillWisePrdWise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- EXEC Proc_RptBillWisePrdWise 183,2
-- delete from RptBillWisePrdWise
-- delete from RptBillWisePrdWiseTaxBreakup
-- select * from RptBillWisePrdWise
-- select * from RptBillWisePrdWiseTaxBreakup

CREATE PROCEDURE [dbo].[Proc_RptBillWisePrdWise]
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
        SET @TaxBreakup=2
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
		SELECT Max(slno) as Slno,Salinvdate,SalinvNo,X.Salid,Rtrid,RtrCode,RtrName,Lcnid,Cmpid,PrdCtgValMainId,
			CmpPrdCtgId,Prdid,Prdccode,PrdName,	Prdbatid,PrdBatCode,Rate,Sum(SalesQty) as SalesQty ,sum(FreeQty)as FreeQty,
			Sum(SalesQty+FreeQty) as TotQty,Sum(GrossAmt) as GrossAmt,Sum(SchemeAmt) as SchemeAmt,sum(SplDiscount) as SplDiscount,
			sum(CashDiscount) as CashDiscount,Sum(SchemeAmt+SplDiscount+CashDiscount) as TotalDiscount,Sum(TotalTax) as TotalTax,Sum(NetAmount) as NetAmount
		FROM(
			SELECT SIP.slNo,Salinvdate,Si.SalinvNo,Si.Salid,R.Rtrid,RtrCode,RtrName,SI.Lcnid,P.Cmpid,P.PrdCtgValMainId,PC.CmpPrdCtgId,
				   SIP.Prdid,Prdccode,PrdName,SIP.Prdbatid,PrdBatCode,PrdBatDetailValue as Rate,
				   BaseQty as SalesQty,SalManFreeQty as FreeQty,PrdGrossAmountAftEdit as GrossAmt,
				   Sum(Isnull(FlatAmount,0)+Isnull(DiscountPerAmount,0)) as SchemeAmt,PrdSplDiscAmount as SplDiscount,PrdCdAmount as CashDiscount,
				  Isnull(PrdTaxAmount,0) as TotalTax,Isnull(PrdNetAmount,0) as NetAmount
			FROM SalesInvoice SI (NOLOCK)
			INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SI.Salid=SIP.SalId	
			INNER JOIN Product P (NOLOCK) On P.Prdid=SIP.Prdid 
			INNER JOIN  ProductCategoryValue PC WITH (NOLOCK) ON  P.PrdCtgValMainId=PC.PrdCtgValMainId  
			INNER JOIN Productbatch PB (NOLOCK) On Pb.Prdid=P.Prdid and Pb.Prdbatid=SIP.Prdbatid
			INNER JOIN ProductBatchDetails D (NOLOCK) ON   
				PB.PrdBatId = D.PrdBatId AND SIP.PriceId = D.PriceId 
			INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = PB.BatchSeqId 
			AND D.SlNo = E.SlNo AND E.SelRte = 1  
			INNER JOIN #RptRetailer R ON R.Rtrid=SI.Rtrid
			LEFT OUTER JOIN SalesInvoiceSchemeLineWise SL ON SL.Salid=SIP.Salid and SL.Prdid=SIP.Prdid and SL.Prdbatid=SIP.Prdbatid
			WHERE SI.SalInvDate Between @FromDate AND @ToDate 
				AND	(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR  
					SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))  
				AND Dlvsts >=CASE WHEN @CancelValue=1 THEN 3 ELSE 4 END
								
			GROUP BY SIP.slNo,Salinvdate,Si.SalinvNo,Si.Salid,R.Rtrid,RtrCode,RtrName,SIP.Prdid,Prdccode,PrdName,SIP.Prdbatid,
					PrdBatCode,PrdBatDetailValue,BaseQty,SalManFreeQty,PrdGrossAmountAftEdit,PrdSplDiscAmount,
					PrdCdAmount,P.PrdCtgValMainId,PC.CmpPrdCtgId,SI.Lcnid,P.Cmpid,PrdTaxAmount,PrdNetAmount
			UNION ALL
			SELECT 0 as slno,Salinvdate,Si.SalinvNo, Sf.Salid,R.Rtrid,RtrCode,RtrName,SI.Lcnid,P.Cmpid,P.PrdCtgValMainId,
				PC.CmpPrdCtgId,SF.FreePrdId,Prdccode,PrdName,SF.FreePrdBatId,PrdBatCode,PrdBatDetailValue as Rate
				,0 as SalesQty,FreeQty,0 as  GrossAmt,0 as SchemeAmt,0 as SplDiscount,0 as CashDiscount,0 as TotalTax,0 as NetAmount
			FROM SalesInvoiceSchemeDtFreePrd SF 
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.salid=SF.Salid
			INNER JOIN Product P (NOLOCK) On P.Prdid=SF.FreePrdId 
			INNER JOIN  ProductCategoryValue PC WITH (NOLOCK) ON  P.PrdCtgValMainId=PC.PrdCtgValMainId  
			INNER JOIN Productbatch PB (NOLOCK) On Pb.Prdid=P.Prdid and Pb.Prdbatid=SF.FreePrdBatId
			INNER JOIN ProductBatchDetails D (NOLOCK) ON   
				PB.PrdBatId = D.PrdBatId and DefaultPrice=1
			INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = PB.BatchSeqId 
				AND D.SlNo = E.SlNo AND E.SelRte = 1  
			INNER JOIN #RptRetailer R ON R.Rtrid=SI.Rtrid
			WHERE SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR  
					SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				AND Dlvsts >=CASE WHEN @CancelValue=1 THEN 3 ELSE 4 END
		)X 
		GROUP BY X.Salid,Prdid,Prdbatid,Salinvdate,SalinvNo,Rtrid,RtrCode,RtrName,Prdccode,PrdName,PrdBatCode,Rate,
				PrdCtgValMainId,CmpPrdCtgId,Lcnid,Cmpid
		--TaxBreakUp
		IF @TaxBreakup=1
		BEGIN
			INSERT INTO RptBillWisePrdWiseTaxBreakup
			SELECT SlNo,SalInvDate,SalinvNo,Salid,Rtrid,RtrCode,RtrName,
				Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,Prdid,Prdccode,PrdName,
				Prdbatid,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,SplDiscount,
				CashDiscount,TotalDiscount,TaxPerc,TaxAmount,TotalTax,Netamount,@DiscBreakup,@QtyBreakup,@TaxBreakup,@Pi_UsrId 
			FROM
				(
					SELECT SlNo,SalInvDate,SalinvNo,X.Salid,X.Rtrid,RtrCode,RtrName ,Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,
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
			SELECT X.SlNo,SalInvDate,SalinvNo,X.Salid,X.Rtrid,RtrCode,RtrName,Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,
					X.Prdid,Prdccode,PrdName,X.Prdbatid,PrdBatCode, Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,SplDiscount,
					CashDiscount,TotalDiscount,0,0,Isnull(PrdTaxAmount,0) as TotalTax,Isnull(PrdNetAmount,0) as NetAmount,
					@DiscBreakup,@QtyBreakup,@TaxBreakup,@Pi_UsrId
			 FROM #RptSalesFree X LEFT OUTER JOIN SalesInvoiceProduct SIP (NOLOCK) ON X.Salid=SIP.SalId	
					and X.Prdid=SIP.Prdid and X.prdbatid=SIP.Prdbatid and X.SlNo=Sip.Slno
		END
		
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-235-011-From Boo

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptCmpWisePurchase')
DROP PROCEDURE Proc_RptCmpWisePurchase
GO 
--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
CREATE    PROCEDURE [dbo].[Proc_RptCmpWisePurchase]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
	--@Po_Errno		INT OUTPUT
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
DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate		AS	DATETIME
DECLARE @CmpId	 	AS	INT
DECLARE @PurRcptID 	AS	INT
DECLARE @EXLFlag	AS	INT
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @PurRcptID = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
Create TABLE #RptCmpWisePurchase
(
		CmpId 				INT,
		CmpName  			NVARCHAR(50),		
		PurRcptId 			BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		InvDate 			DATETIME,
		GrossAmount 		NUMERIC(38,6),
		SlNo 				INT,
		RefCode 			NVARCHAR(25),
		FieldDesc 			NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		LessScheme 			NUMERIC(38,6),
		OtherChgAddition	NUMERIC(38,6),	
		OtherChgDeduction	NUMERIC(38,6),		
		NetAmount 			NUMERIC(38,6),
		CmpInvNo			NVARCHAR(25),
		CmpInvDate 			DATETIME
	)
SET @TblName = 'RptCmpWisePurchase'
SET @TblStruct = '
		CmpId 				INT,
		CmpName  			NVARCHAR(50),		
		PurRcptId 			BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		InvDate 			DATETIME,
		GrossAmount 		NUMERIC(38,6),
		SlNo 				INT,
		RefCode 			NVARCHAR(25),
		FieldDesc 			NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		LessScheme 			NUMERIC(38,6),
		OtherChgAddition	NUMERIC(38,6),	
		OtherChgDeduction	NUMERIC(38,6),	
		NetAmount 			NUMERIC(38,6),
		CmpInvNo			NVARCHAR(25),
		CmpInvDate 			DATETIME'
			
SET @TblFields = 'CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
		 ,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate'
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
--SET @Po_Errno = 0
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN
--	EXEC Proc_GRNListing @Pi_UsrId

	SELECT PurRcptId,PurRcptRefNo,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
		   ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,RefCode,FieldDesc ,LineBaseQtyAmount,
		   PrdNetAmount,status,GoodsRcvdDate,LessScheme,OtherChgAddition,OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,
		   DifferenceAmount,PaidAmount,NetAmount,CmpId,CmpName,UsrId
	INTO #TempGrnListing FROM 
		(
			Select PR.PurRcptId,PurRcptRefNo,PRP.PrdId,PrdDCode,PrdName,PRP.PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
			ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,PRL.RefCode,FieldDesc ,LineBaseQtyAmount,
			PrdNetAmount,PR.status,GoodsRcvdDate,LessScheme,
			CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			FROM PurchaseReceipt PR
			INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId
			INNER JOIN PurchasereceiptLineAmount PRL ON PR.PurRcptId = PRL.PurRcptId
			and PRL.PrdSlNo = PRP.PrdSlNo
			INNER JOIN PurchaseSequenceMaster PS ON PR.PurSeqId = PS.PurSeqId
			INNER JOIN PurchaseSequenceDetail PD ON PD.PurSeqId = PS.PurSeqId and PRL.RefCode = PD.RefCode
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN Product P ON P.PrdId = PRP.PrdId
			INNER JOIN ProductBatch  PB ON PB.PrdId = PRP.PrdId  and PB.PrdBatId = PRP.PrdBatId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId
			WHERE PR.Status=1 AND PR.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND
			( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND ( PR.PurRcptId = (CASE @PurRcptID WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
						PR.PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId)))
					and PRP.PrdSlNo > 0 
			UNION ALL
			Select PR.PurRcptId,PurRcptRefNo,
			0 as PrdId,'' as PrdDCode,'' as PrdName,0 as PrdBatId,'' as PrdBatCode,Pr.CmpInvNo,InvDate,0 as InvBaseQty,0 as RcvdGoodBaseQty,
			0 as UnSalBaseQty,0 as ShrtBaseQty,0 as ExsBaseQty,0 AS RefuseSale,0 as PrdUnitLSP,
			0 as PrdGrossAmount,0 as Slno,'' as RefCode,'' as FieldDesc ,0 as LineBaseQtyAmount,
			0 as PrdNetAmount,PR.status,GoodsRcvdDate,
			LessScheme,
			CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			from purchasereceipt PR
			Inner join purchasereceiptclaimScheme PRCS on PRCS.PurRcptId = PR.PurRcptId
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN StockType ST ON ST.StockTypeId = PRCS.StockTypeId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId
			LEFT OUTER JOIN Product P ON P.PrdId = PRCS.PrdId
			LEFT OUTER JOIN ProductBatch  PB ON PB.PrdId =PRCS.PrdId  and PB.PrdBatId = PRCS.PrdBatId
			WHERE PR.Status=1 AND PR.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND
			( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND ( PR.PurRcptId = (CASE @PurRcptID WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
						PR.PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId)))
		) AS A
		


	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
		 ,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate)
		SELECT DISTINCT CmpId,CmpName,PurRcptId,PurRcptRefno,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,
		dbo.Fn_ConvertCurrency(sum(LineBaseQtyAmount),@Pi_CurrencyId) as LineBaseQtyAmount,
		dbo.Fn_ConvertCurrency(LessScheme,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(OtherChgAddition,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(OtherChgDeduction,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId),CmpInvNo,CmpInvdate
		From ( SELECT  cmpid,cmpname,purrcptid,purrcptrefno,InvDate,GrossAmount,slno,
		RefCode,FieldDesc,LineBaseQtyAmount,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,InvDate AS CmpInvDate,UsrId	
		FROM #TempGrnListing) x
		Group by
		cmpid,cmpname,purrcptid,purrcptrefno,InvDate, GrossAmount,slno,RefCode,FieldDesc,
		LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate,usrid	

	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,(Select max(SLNO) + 1 From PurchaseSequenceDetail) as SlNo,'AAA' as RefCode,'Net Amt.' as FieldDesc,
	NetAmount as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select MAX(slno) AS SLNO From #RptCmpWisePurchase)


	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-1 as SlNo,'BBB' as RefCode,'Other Charges Addition' as FieldDesc,
	OtherChgAddition as LineBaseQtyAmount,LessScheme,OtherChgAddition,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase)


	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-2 as SlNo,'CCC' as RefCode,'Scheme Disc.' as FieldDesc,
	LessScheme as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase)

	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-3 as SlNo,'DDD' as RefCode,'Gross Amount' as FieldDesc,
	GrossAmount  as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO  From #RptCmpWisePurchase)

	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-1.5 as SlNo,'EEE' as RefCode,'Other Charges Dedection' as FieldDesc,
	OtherChgDeduction as LineBaseQtyAmount,LessScheme,0,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase WHERE OtherChgDeduction>0)-- AND OtherChgDeduction>0

	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptCmpWisePurchase ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+' (PurRcptId = (CASE ' + CAST(@PurRcptID AS nVarchar(10)) + ' WHEN 0 THEN PurRcptId ELSE 0 END) OR ' +
			' PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',197,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') and (Slno > 0)  '
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCmpWisePurchase'
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
		SET @SSQL = 'INSERT INTO #RptCmpWisePurchase ' +
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
		--SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	   END
END
DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCmpWisePurchase
SELECT * FROM #RptCmpWisePurchase
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @InvDate DATETIME	
		DECLARE  @cCmpId INT
		DECLARE  @cPurRcptId INT
		DECLARE  @CmpInvNo NVARCHAR(100)	
		DECLARE  @SlNo INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCmpWisePurchase_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptCmpWisePurchase_Excel]
		DELETE FROM RptExcelHeaders Where RptId=23 AND SlNo>8
		CREATE TABLE RptCmpWisePurchase_Excel (CmpId BIGINT,CmpName NVARCHAR(100),PurRcptId BIGINT,PurRcptRefNo NVARCHAR(100),InvDate DATETIME,
						 		CmpInvNo NVARCHAR(100),CmpInvDate DateTime,UsrId INT)
		SET @iCnt=9
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT(Fielddesc),SlNo FROM #RptCmpWisePurchase ORDER BY SLNo
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@SlNo
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptCmpWisePurchase_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@SLNo
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur
		--Insert table values
		DELETE FROM RptCmpWisePurchase_Excel
		INSERT INTO RptCmpWisePurchase_Excel (CmpId ,CmpName ,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate ,UsrId)
		SELECT DISTINCT CmpId ,CmpName ,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate,@Pi_UsrId
				FROM #RptCmpWisePurchase
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT  CmpId,PurRcptId,InvDate,CmpInvNo,FieldDesc,LineBaseQtyAmount FROM #RptCmpWisePurchase
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @cCmpId,@cPurRcptId,@InvDate,@CmpInvNo,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptCmpWisePurchase_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE CmpId='+ CAST(@cCmpId AS VARCHAR(1000)) + ' AND PurRcptId=' + CAST(@cPurRcptId AS VARCHAR(1000)) + '
					AND InvDate=''' + CAST(@InvDate AS VARCHAR(1000))+''' AND CmpInvNo=''' + CAST(@CmpInvNo As VARCHAR(1000)) + ''' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @cCmpId,@cPurRcptId,@InvDate,@CmpInvNo,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptCmpWisePurchase_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptCmpWisePurchase_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/******************************************************************************************************/
	END
RETURN
END
GO

--SRF-Nanda-235-012-From Boo

IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'AllowUncheck' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='Etl_Prk_SchemeHD_Slabs_Rules'))
BEGIN
	ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD AllowUncheck NVARCHAR(10) NULL
END
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_ImportSchemeHD_Slabs_Rules')
DROP PROCEDURE Proc_ImportSchemeHD_Slabs_Rules
GO

CREATE Procedure [dbo].[Proc_ImportSchemeHD_Slabs_Rules] 
(
	@Pi_Records TEXT
)
AS
/***************************************************************************************************
* PROCEDURE		: Proc_ImportSchemeHD_Slabs_Rules
* PURPOSE		: To Insert records from xml file in the Table Etl_Prk_SchemeHD_Slabs_Rules
* CREATED		: Aarthi.R
* CREATED DATE	: 21/01/2008
* MODIFIED
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
* 25.08.2009   Panneer      Added the BudgetAllacationNo Column in Parking Table(Etl_Prk_SchemeHD_Slabs_Rules)
* 19.10.2009   Thiru		Added the SchBasedOn column in Parking Table(Etl_Prk_SchemeHD_Slabs_Rules)	
* 22/04/2010   Nanda        Added the FBM Column 
* 28/12/2010   Nanda        Added the Settlement Type Column 
****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	DECLARE @Company NVARCHAR(100)
	DECLARE @ClmGroupCode NVARCHAR(100)
	SELECT @Company = CmpCode FROM Company WHERE DefaultCompany = 1
	SELECT @ClmGroupCode = ClmGrpCode FROM ClaimGroupMaster WHERE ClmGrpId = 17
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Etl_Prk_SchemeHD_Slabs_Rules(CmpSchCode,SchDsc,CmpCode,Claimable,ClmAmton,ClmGroupCode,SchLevel,SchType,BatchLevel,FlexiSch,
	FlexiSchType,CombiSch,Range,ProRata,QPS,QPSReset,ApyQPSSch,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,PurofEvery,
	SetWindowDisp,EditScheme,SchemeLevelMode,SlabId,PurQty,FromQty,Uom,ToQty,ToUom,ForEveryQty,ForEveryUom,DiscPer,FlatAmt,FlxDisc,
	FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,SchConfig,SchRules,
	NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,EnableRtrLvl,AllowSaving,AllowSelection,BudgetAllocationNo,SchBasedOn,
	FBM,DownloadFlag,SettlementType,AllowUncheck)
	SELECT  [CmpSchCode],[SchDsc],@Company AS [CmpCode],[Claimable],[ClmAmton],@ClmGroupCode AS [ClmGroupCode],[SchLevel],[SchType],
	'NO' AS [BatchLevel],[FlexiSch],[FlexiSchType],[CombiSch],[Range],[ProRata],[QPS],[QPSReset],[ApyQPSSch],[SchValidFrom],[SchValidTill],
	[SchStatus],[Budget],[AdjWinDispOnlyOnce],[PurofEvery],[SetWindowDisp],[EditScheme],[SchemeLevelMode],[SlabId],[PurQty],[FromQty],
	[Uom],[ToQty],[ToUom],[ForEveryQty],[ForEveryUom],[DiscPer],[FlatAmt],[FlxDisc],[FlxValueDisc],[FlxFreePrd],[FlxGiftPrd],[FlxPoints],
	[Points],[MaxDiscount],[MinDiscount],[MaxValue],[MinValue],[MaxPoints],[MinPoints],[SchConfig],[SchRules],[NoofBills],[FromDate],
	[ToDate],[MarketVisit],[ApplySchBasedOn],[EnableRtrLvl],[AllowSaving],[AllowSelection],[BudgetAllocationNo],[SchBasedOn],
	[FBM],[DownloadFlag],ISNULL([SettlementType],'ALL'),ISNULL([AllowUncheck],'NO')
	FROM OPENXML (@hdoc,'/Root/Console2CS_Scheme_HD_Slabs_Rules ',1)
	WITH 
	(
		[CmpSchCode]			NVARCHAR(25),
		[SchDsc]				NVARCHAR(100),
		[CmpCode]				NVARCHAR(100),
		[Claimable]				NVARCHAR(10),
		[ClmAmton]				NVARCHAR(25) ,
		[ClmGroupCode]			NVARCHAR(100),
		[SchLevel]				NVARCHAR(25),
		[SchType]				NVARCHAR(20),
		[BatchLevel]			NVARCHAR(100),
		[FlexiSch]				NVARCHAR(10),
		[FlexiSchType]			NVARCHAR(15),
		[CombiSch]				NVARCHAR(10),
		[Range]					NVARCHAR(10),
		[ProRata]				NVARCHAR(10),
		[QPS]					NVARCHAR(10),
		[QPSReset]				NVARCHAR(10),
		[ApyQPSSch]				NVARCHAR(10),
		[SchValidFrom]			NVARCHAR(10),
		[SchValidTill]			NVARCHAR(10),
		[SchStatus]				NVARCHAR(10),
		[Budget]				NVARCHAR(20),
		[AdjWinDispOnlyOnce]	NVARCHAR(10),
		[PurofEvery]			NVARCHAR(10),
		[SetWindowDisp]			NVARCHAR(10),
		[EditScheme]			NVARCHAR(10),
		[SchemeLevelMode]		NVARCHAR(10),
		[SlabId]				INT ,
		[PurQty]				NUMERIC(18, 2) ,
		[FromQty]				NUMERIC(18, 2) ,
		[Uom]					NVARCHAR(10) ,
		[ToQty]					NUMERIC(18, 2) ,
		[ToUom]					NVARCHAR(10) ,
		[ForEveryQty]			NUMERIC(18, 2) ,
		[ForEveryUom]			NVARCHAR(10) ,
		[DiscPer]				NUMERIC(18, 2) ,
		[FlatAmt]				NUMERIC(18, 2) ,
		[FlxDisc]				NVARCHAR(10) ,
		[FlxValueDisc]			NVARCHAR(10) ,
		[FlxFreePrd]			NVARCHAR(10) ,
		[FlxGiftPrd]			NVARCHAR(10) ,
		[FlxPoints]				NVARCHAR(10) ,
		[Points]				NUMERIC(18, 2) ,
		[MaxDiscount]			NUMERIC(18, 2) ,
		[MinDiscount]			NUMERIC(18, 2) ,
		[MaxValue]				NUMERIC(18, 2) ,
		[MinValue]				NUMERIC(18, 2) ,
		[MaxPoints]				NUMERIC(18, 2) ,
		[MinPoints]				NUMERIC(18, 2) ,
		[SchConfig]				NVARCHAR(10) ,
		[SchRules]				NVARCHAR(10) ,
		[NoofBills]				INT ,
		[FromDate]				NVARCHAR(10) ,
		[ToDate]				NVARCHAR(10) ,
		[MarketVisit]			INT ,
		[ApplySchBasedOn]		NVARCHAR(10) ,
		[EnableRtrLvl]			NVARCHAR(10) ,
		[AllowSaving]			NVARCHAR(10) ,
		[AllowSelection]		NVARCHAR(10),
		[DownloadFlag]			NVARCHAR(1),
		[BudgetAllocationNo]	NVARCHAR (100),
		[SchBasedOn]			NVARCHAR (50),
		[FBM]					NVARCHAR (10),		
		[SettlementType]		NVARCHAR (10),
		[AllowUncheck]			NVARCHAR (10)		
	) XMLObj
	EXEC sp_xml_removedocument @hDoc
END
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_Cn2Cs_BLSchemeMaster')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeMaster
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeMaster 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE	: Proc_Cn2Cs_BLSchemeMaster
* PURPOSE	: To Insert and Update records Of Scheme Master
* CREATED	: Boopathy.P on 31/12/2008
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
* 25.08.2009   Panneer		Added BudgetAllocationNo in SchemeMaster Table
* 20.10.2009   Thiru		Added SchBasedOn in SchemeMaster Table		
* 22/04/2010   Nanda 		Added FBM
* 28/12/2010   Nanda 		Added Settlement Type
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 		AS NVARCHAR(100)
	DECLARE @SchDesc 		AS NVARCHAR(200)
	DECLARE @CmpCode 		AS NVARCHAR(50)
	DECLARE @ClmAble 		AS NVARCHAR(50)
	DECLARE @ClmAmtOn 		AS NVARCHAR(50)
	DECLARE @ClmGrpCode		AS NVARCHAR(50)
	DECLARE @SelnOn			AS NVARCHAR(50)
	DECLARE @SelLvl			AS NVARCHAR(50)
	DECLARE @SchType		AS NVARCHAR(50)
	DECLARE @BatLvl			AS NVARCHAR(50)
	DECLARE @FlxSch			AS NVARCHAR(50)
	DECLARE @FlxCond		AS NVARCHAR(50)
	DECLARE @CombiSch		AS NVARCHAR(50)
	DECLARE @Range			AS NVARCHAR(50)
	DECLARE @ProRata		AS NVARCHAR(50)
	DECLARE @Qps			AS NVARCHAR(50)
	DECLARE @QpsReset		AS NVARCHAR(50)
	DECLARE @ApyQpsOn		AS NVARCHAR(50)
	DECLARE @ForEvery		AS NVARCHAR(50)
	DECLARE @SchStartDate	AS NVARCHAR(50)
	DECLARE @SchEndDate		AS NVARCHAR(50)
	DECLARE @SchBudget		AS NVARCHAR(50)
	DECLARE @EditSch		AS NVARCHAR(50)
	DECLARE @AdjDisSch		AS NVARCHAR(50)
	DECLARE @SetDisMode		AS NVARCHAR(50)
	DECLARE @SchStatus		AS NVARCHAR(50)
	DECLARE @SchBasedOn		AS NVARCHAR(50)
	DECLARE @StatusId		AS INT
	DECLARE @CmpId			AS INT
	DECLARE @ClmGrpId		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @ClmableId		AS INT
	DECLARE @ClmAmtOnId		AS INT
	DECLARE @SelMode		AS INT
	DECLARE @SchTypeId		AS INT
	DECLARE @BatId			AS INT
	DECLARE @FlexiId		AS INT
	DECLARE @FlexiConId		AS INT
	DECLARE @CombiId		AS INT
	DECLARE @RangeId		AS INT
	DECLARE @ProRateId		AS INT
	DECLARE @QPSId			AS INT
	DECLARE @QPSResetId		AS INT
	DECLARE @AdjustSchId	AS INT
	DECLARE @ApplySchId		AS INT
	DECLARE @ForEveryId		AS INT
	DECLARE @SettleSchId	AS INT
	DECLARE @EditSchId		AS INT
	DECLARE @ChkCount		AS INT		
	DECLARE @ConFig			AS INT
	DECLARE @CmpCnt			AS INT
	DECLARE @EtlCnt			AS INT
	DECLARE @SLevel			AS INT
	DECLARE @SchBasedOnId	AS INT
	DECLARE @ErrDesc		AS NVARCHAR(1000)
	DECLARE @TabName		AS NVARCHAR(50)
	DECLARE @GetKey			AS INT
	DECLARE @GetKeyStr		AS NVARCHAR(200)
	DECLARE @Taction		AS INT
	DECLARE @sSQL			AS VARCHAR(4000)
	DECLARE @iCnt			AS INT
	DECLARE @BudgetAllocationNo	AS NVARCHAR(100)
	DECLARE @FBM				AS NVARCHAR(10)
	DECLARE @FBMId				AS INT
	DECLARE @SettlementType		AS NVARCHAR(10)
	DECLARE @SettlementTypeId	AS INT
	DECLARE @FBMDate			AS DATETIME
	DECLARE @AllowUnCheck		AS NVARCHAR(10)
	DECLARE @AllowUnCheckId		AS INT

	SET @TabName = 'Etl_Prk_SchemeHD_Slabs_Rules'
	SET @Po_ErrNo =0
	SET @AdjustSchId=0
	SET @iCnt=0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE @DistCode AS  NVARCHAR(50)
	SELECT @DistCode=ISNULL(DistributorCode,'') FROM Distributor
	--->Added By Nanda on 17/09/2009
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SchToAvoid	
	END
	CREATE TABLE SchToAvoid
	(
		CmpSchCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
	WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product'))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','CmpSchCode','Product :'+PrdCode+' not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)		
		SELECT @DistCode,'Scheme',CmpSchCode,'Product',PrdCode,'','N'
		FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND 
		CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'
	END
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Attributes','Attributes not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes)
	END
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Products','Scheme Products not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi)
	END
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Header','Header not Available for Scheme:'+CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules)
	END
	--->Till Here
	DECLARE Cur_SchMaster CURSOR
	FOR SELECT DISTINCT
	ISNULL([CmpSchCode],'') AS [Company Scheme Code],
	ISNULL([SchDsc],'') AS [Scheme Description],
	ISNULL([CmpCode],'') AS [Company Code],
	ISNULL([Claimable],'') AS [Claimable],
	ISNULL([ClmAmton],'') AS [Claim Amount On],
	ISNULL([ClmGroupCode],'') AS [Claim Group Code],
	ISNULL([SchemeLevelMode],'') AS [Selection On],
	ISNULL([SchLevel],'') AS [Selection Level Value],
	ISNULL([SchType],'') AS [Scheme Type],
	ISNULL([BatchLevel],'') AS [Batch Level],
	ISNULL([FlexiSch],'') AS [Flexi Scheme],
	ISNULL([FlexiSchType],'') AS [Flexi Conditional],
	ISNULL([CombiSch],'') AS [Combi Scheme],
	ISNULL([Range],'') AS [Range],
	ISNULL([ProRata],'') AS [Pro - Rata],
	ISNULL([Qps],'NO') AS [Qps],
	ISNULL([QPSReset],'') AS [Qps Reset],
	ISNULL([ApyQPSSch],'') AS [Qps Based On],
	ISNULL([PurofEvery],'') AS [Allow For Every],
	ISNULL([SchValidFrom],'') AS [Scheme Start Date],
	ISNULL([SchValidTill],'') AS [Scheme End Date],
	ISNULL([Budget],'') AS [Scheme Budget],
	ISNULL([EditScheme],'') AS [Allow Editing Scheme],
	ISNULL([AdjWinDispOnlyOnce],'0') AS [Adjust Display Once],
	ISNULL([SetWindowDisp],'') AS [Settle Display Through],
	ISNULL(SchStatus,'') AS SchStatus,
	ISNULL(BudgetAllocationNo,'') AS BudgetAllocationNo,
	ISNULL(SchBasedOn,'') AS SchemeBasedOn,
	ISNULL(FBM,'No') AS FBM,
	ISNULL(SettlementType,'ALL') AS SettlementType,
	ISNULL([AllowUncheck],'NO') AS AllowUncheck
	FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'			 
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
	@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck	
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @SchBasedOn='RETAILER'
		SET @Po_ErrNo =0		
		SET @Taction = 2
		SET @iCnt=@iCnt+1
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchDesc))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Description should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Description',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CmpCode))= ''
		BEGIN
			SET @ErrDesc = 'Company should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (3,@TabName,'Company',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ClmAble))= ''
		BEGIN
			SET @ErrDesc = 'Claimable should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (4,@TabName,'Claimable',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ClmAmtOn))= ''
		BEGIN
			SET @ErrDesc = 'Claim Amount On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (5,@TabName,'Claim Amount On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelnOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (6,@TabName,'Scheme Level Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelLvl))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (7,@TabName,'Scheme Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchType))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@BatLvl))= ''
		BEGIN
			SET @ErrDesc = 'Batch Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (9,@TabName,'Batch Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FlxSch))= ''
		BEGIN
			SET @ErrDesc = 'Flexi Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (10,@TabName,'Flexi Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FlxCond))= ''
		BEGIN
			SET @ErrDesc = 'Flexi Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (11,@TabName,'Flexi Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CombiSch))= ''
		BEGIN
			SET @ErrDesc = 'Combi Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (12,@TabName,'Combi Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Range))= ''
		BEGIN
			SET @ErrDesc = 'Range should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (13,@TabName,'Range Based Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ProRata))= ''
		BEGIN
			SET @ErrDesc = 'Pro-Rata should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (14,@TabName,'Pro-Rata',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Qps))= ''
		BEGIN
			SET @ErrDesc = 'QPS Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (15,@TabName,'QPS Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@QpsReset))= ''
		BEGIN
			SET @ErrDesc = 'QPS Reset should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (16,@TabName,'QPS Reset',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ApyQpsOn))= ''
		BEGIN
			SET @ErrDesc = 'Apply QPS Scheme Based On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (17,@TabName,'Apply QPS Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchStartDate))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Start Date should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (19,@TabName,'Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LEN(LTRIM(RTRIM(@SchStartDate)))<10
		BEGIN
			SET @ErrDesc = 'Scheme Start Date is not Date Format for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (20,@TabName,'Scheme Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@SchStartDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Scheme Start Date for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (21,@TabName,'Scheme Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchEndDate))= ''
		BEGIN
			SET @ErrDesc = 'Scheme End Date should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (23,@TabName,'End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LEN(LTRIM(RTRIM(@SchEndDate)))<10
		BEGIN
			SET @ErrDesc = 'Scheme End Date is not in Date Format for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (24,@TabName,'Scheme End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@SchEndDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Scheme End Date for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (25,@TabName,'Scheme End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@EditSch))= ''
		BEGIN
			SET @ErrDesc = 'Allow Editing Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (28,@TabName,'Editing Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SetDisMode))= ''
		BEGIN
			SET @ErrDesc = 'Settle Window Display Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (30,@TabName,'Settle Window Display Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelnOn))= ''
		BEGIN
			SET @ErrDesc = 'Selection On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (31,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchStatus))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Status should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (32,@TabName,'Scheme Status',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchBasedOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Based On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (70,@TabName,'SchemeBasedOn',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SchBasedOn)))<> 'RETAILER') AND (UPPER(LTRIM(RTRIM(@SchBasedOn)))<> 'KEY GROUP'))
		BEGIN
			SET @ErrDesc = 'Scheme Based On should be (RETAILER OR KEY GROUP) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (71,@TabName,'SchemeBasedOn',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SelnOn)))<> 'UDC') AND (UPPER(LTRIM(RTRIM(@SelnOn)))<> 'PRODUCT'))
		BEGIN
			SET @ErrDesc = 'Selection On should be (UDC OR PRODUCT) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (33,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@ClmAble)))<> 'YES') AND (UPPER(LTRIM(RTRIM(@ClmAble)))<> 'NO'))
		BEGIN
			SET @ErrDesc = 'Claimable should be (YES OR NO) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (34,@TabName,'Claimable',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SchStatus)))<> 'ACTIVE') AND (UPPER(LTRIM(RTRIM(@SchStatus)))<> 'INACTIVE'))
		BEGIN
			SET @ErrDesc = 'Scheme Stauts should be (ACTIVE OR INACTIVE) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (35,@TabName,'Scheme Stauts',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF (UPPER(LTRIM(RTRIM(@ClmAble)))= 'YES')
		BEGIN
			IF LTRIM(RTRIM(@ClmGrpCode))= ''
			BEGIN
				SET @ErrDesc = 'Claim Group Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (36,@TabName,'Claim Group Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF (UPPER(LTRIM(RTRIM(@ClmAmtOn)))<> 'PURCHASE RATE' AND UPPER(LTRIM(RTRIM(@ClmAmtOn)))<> 'SELLING RATE')
		BEGIN
			SET @ErrDesc = 'Claimable Amount should be (PURCHASE RATE OR SELLING RATE) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (37,@TabName,'Claimable Amount',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF (UPPER(LTRIM(RTRIM(@SchType)))<>'WINDOW DISPLAY' AND UPPER(LTRIM(RTRIM(@SchType)))<>'AMOUNT'
		   AND UPPER(LTRIM(RTRIM(@SchType)))<>'WEIGHT' AND UPPER(LTRIM(RTRIM(@SchType)))<>'QUANTITY')
		BEGIN
			SET @ErrDesc = 'Scheme Type should be (WINDOW DISPLAY OR AMOUNT OR WEIGHT OR QUANTITY) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (38,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF (UPPER(LTRIM(RTRIM(@SchType)))='WINDOW DISPLAY')
		BEGIN
			IF (UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Batch Level should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (39,@TabName,'Batch Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (40,@TabName,'Flexi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxCond)))<> 'UNCONDITIONAL')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme Type should be (UNCONDITIONAL) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (41,@TabName,'Flexi Scheme Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Combi Scheme should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (42,@TabName,'Combi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Range should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (43,@TabName,'Range',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO'
			   AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'ACTUAL')
			BEGIN
				SET @ErrDesc = 'Pro-Rata should be (YES OR NO OR ACTUAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (44,@TabName,'Pro-Rata',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Qps)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS should be (NO) for WINDOW DISPLAY SCHEME for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (45,@TabName,'QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@QpsReset)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS Reset should be (NO)for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (46,@TabName,'QPS Reset',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@AdjDisSch))= ''
			BEGIN
				SET @ErrDesc = 'Adjust Window Display Scheme Only Once should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (47,@TabName,'Adjust Window Display Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CASH' AND UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CHEQUE')
			BEGIN
				SET @ErrDesc = 'Settle Window Display Should be (CASH OR CHEQUE) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (48,@TabName,'SETTLE WINDOW DISPLAY',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE')
			BEGIN
				SET @ErrDesc = 'Apply QPS Scheme Should be (DATE) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (50,@TabName,'Apply QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		ELSE IF (UPPER(LTRIM(RTRIM(@SchType)))='AMOUNT' AND UPPER(LTRIM(RTRIM(@SchType)))='WEIGHT'
			AND UPPER(LTRIM(RTRIM(@SchType)))='QUANTITY')
		BEGIN
			IF UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO'
			BEGIN
				SET @ErrDesc = 'Batch Level should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (51,@TabName,'Batch Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))<> 'YES' AND UPPER(LTRIM(RTRIM(@FlxSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (52,@TabName,'Flexi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxCond)))<> 'UNCONDITIONAL' AND UPPER(LTRIM(RTRIM(@FlxCond)))<> 'CONDITIONAL')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme Type should be (UNCONDITIONAL OR CONDITIONAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (53,@TabName,'Flexi Scheme Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))= 'NO')
			BEGIN
				IF (UPPER(LTRIM(RTRIM(@FlxCond)))= 'CONDITIONAL')
				BEGIN
					SET @ErrDesc = 'Flexi Scheme Type should be UNCONDITIONAL When Flexi Scheme is YES for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (54,@TabName,'Flexi Scheme Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'YES' AND UPPER(LTRIM(RTRIM(@CombiSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Combi Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (55,@TabName,'Combi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Range)))<> 'YES' AND UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Range should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (56,@TabName,'Range',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO'
			   OR UPPER(LTRIM(RTRIM(@ProRata)))<> 'ACTUAL')
			BEGIN
				SET @ErrDesc = 'Pro-Rata should be (YES OR NO OR ACTUAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (57,@TabName,'Pro-Rata',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'YES')
			BEGIN
				IF (UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
				BEGIN
					SET @ErrDesc = 'IF COMBI SCHEME is YES, Then RANGE should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (58,@TabName,'Range',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO')
				BEGIN
					SET @ErrDesc = 'IF COMBI SCHEME is YES, Then PRO-RATA should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (59,@TabName,'Pro-Rata',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Qps)))<> 'YES' AND UPPER(LTRIM(RTRIM(@Qps)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (60,@TabName,'QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@QpsReset)))<> 'YES' AND UPPER(LTRIM(RTRIM(@QpsReset)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS Reset should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (61,@TabName,'QPS Reset',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'NO'
			BEGIN
				IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'YES'
				BEGIN
					SET @ErrDesc = 'IF QPS SCHEME is NO, Then QPS Reset should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (62,@TabName,'QPS Reset',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE'
				BEGIN
					SET @ErrDesc = 'IF QPS SCHEME is NO,Apply QPS Scheme Should be (DATE) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (63,@TabName,'Apply QPS Scheme',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'YES'
			BEGIN
				IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE' AND UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'QUANTITY'
				BEGIN
					SET @ErrDesc = 'Apply QPS Scheme Should be (DATE OR QUANTITY) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (64,@TabName,'Apply QPS Scheme',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CASH'
			BEGIN
				SET @ErrDesc = 'Settle Window Display Should be (CASH) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (65,@TabName,'SETTLE WINDOW DISPLAY',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@AllowUnCheck)))<> 'YES' AND UPPER(LTRIM(RTRIM(@AllowUnCheck)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Allow uncheck claimable should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (52,@TabName,'Allow Uncheck',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF NOT EXISTS(SELECT CmpId FROM Company WHERE CmpCode=LTRIM(RTRIM(@CmpCode)))
			BEGIN
				SET @ErrDesc = 'Company Not Found for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (66,@TabName,'Company',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE
			BEGIN
				SELECT @CmpId=CmpId FROM Company WHERE CmpCode=LTRIM(RTRIM(@CmpCode))
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			SET @GetKey=0
			SET @GetKeyStr=''
			IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE CMPID=@CmpId AND SM.CmpSchCode=LTRIM(RTRIM(@SchCode)))
			BEGIN
				SELECT @GetKey= dbo.Fn_GetPrimaryKeyInteger('SchemeMaster','SchId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
				SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('SchemeMaster','SchCode',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))				
				SET @Taction = 2
			END
			ELSE
			BEGIN
				SELECT @GetKey=SchId,@GetKeyStr=SchCode FROM SchemeMaster WHERE CMPID=@CmpId AND CmpSchCode=LTRIM(RTRIM(@SchCode))
				SET @Taction = 1
			END
		END
		IF @GetKey=0	
		BEGIN
			SET @ErrDesc = 'Scheme Id should be greater than zero Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (67,@TabName,'Scheme Id',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF LEN(LTRIM(RTRIM(@GetKeyStr )))=''
		BEGIN
			SET @ErrDesc = 'Scheme Code should be greater than zero Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (67,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF @Taction = 2
		BEGIN 
			IF @GetKey<=(SELECT ISNULL(MAX(SchId),0) AS SchId FROM SchemeMaster)
			BEGIN
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'SchId',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchBasedOn)))= 'RETAILER'
				SET @SchBasedOnId=1
			ELSE IF UPPER(LTRIM(RTRIM(@SchBasedOn)))= 'KEY GROUP'
				SET @SchBasedOnId=2
		END 
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@ClmAble)))='YES'
			BEGIN
				IF NOT EXISTS(SELECT ClmGrpId FROM ClaimGroupMaster WHERE ClmGrpCode=LTRIM(RTRIM(@ClmGrpCode)))
				BEGIN
					SET @ErrDesc = 'Claim Group Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (67,@TabName,'Claim Group',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @ClmGrpId=ClmGrpId FROM ClaimGroupMaster WHERE ClmGrpCode=LTRIM(RTRIM(@ClmGrpCode))
				END
			END
			ELSE
			BEGIN
				SET @ClmGrpId=0
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SelnOn)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@SelnOn)))='SKU' OR UPPER(LTRIM(RTRIM(@SelnOn)))='MATERIAL'
			BEGIN
				IF NOT EXISTS(SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
					AND CmpPrdCtgName=UPPER(LTRIM(RTRIM(@SelLvl))) AND LevelName <> 'Level1')
				BEGIN
					SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (68,@TabName,'Product Category',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
					AND CmpPrdCtgName=LTRIM(RTRIM(@SelLvl)) AND LevelName <> 'Level1'
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SelnOn)))='UDC'
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT A.UdcMasterId FROM UdcMaster A
					INNER JOIN UdcHD B ON A.MasterId=B.MasterId WHERE B.MasterId=1 AND A.COLUMNNAME=LTRIM(RTRIM(@SelLvl)))
				BEGIN
					SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (69,@TabName,'Product Category',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @CmpPrdCtgId=A.UdcMasterId FROM UdcMaster A INNER JOIN UdcHD B ON
					A.MasterId=B.MasterId WHERE B.MasterId=1 AND A.COLUMNNAME=LTRIM(RTRIM(@SelLvl))
				END
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchStatus)))= 'ACTIVE'
				SET @StatusId=1
			ELSE IF UPPER(LTRIM(RTRIM(@SchStatus)))= 'INACTIVE'
				SET @StatusId=0
			IF UPPER(LTRIM(RTRIM(@ClmAble)))= 'YES'
				SET @ClmableId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ClmAble)))= 'NO'
				SET @ClmableId=0
			
			IF UPPER(LTRIM(RTRIM(@ClmAmtOn)))= 'PURCHASE RATE'
				SET @ClmAmtOnId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ClmAmtOn)))= 'SELLING RATE'
				SET @ClmAmtOnId=2
			
			IF UPPER(LTRIM(RTRIM(@SelnOn)))= 'UDC'
				SET @SelMode=1
			ELSE IF UPPER(LTRIM(RTRIM(@SelnOn)))= 'PRODUCT'
				SET @SelMode=0
			
			IF UPPER(LTRIM(RTRIM(@SchType)))='WINDOW DISPLAY'
				SET @SchTypeId=4
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='AMOUNT'
				SET @SchTypeId=2
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='WEIGHT'
				SET @SchTypeId=3
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='QUANTITY'
				SET @SchTypeId=1
			
			IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'YES'
				SET @BatId=1
			ELSE IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'NO'
				SET @BatId=0
			
			
			IF UPPER(LTRIM(RTRIM(@FlxSch)))= 'YES'
				SET @FlexiId=1
			ELSE IF UPPER(LTRIM(RTRIM(@FlxSch)))= 'NO'
				SET @FlexiId=0
			
			IF UPPER(LTRIM(RTRIM(@FlxCond)))= 'UNCONDITIONAL'
				SET @FlexiConId=2
			ELSE IF UPPER(LTRIM(RTRIM(@FlxCond)))= 'CONDITIONAL'
				SET @FlexiConId=1
			ELSE
				SET @FlexiConId=2
			
			IF UPPER(LTRIM(RTRIM(@CombiSch)))= 'YES'				
				SET @CombiId=1
			ELSE IF UPPER(LTRIM(RTRIM(@CombiSch)))= 'NO'
				SET @CombiId=0
			
			IF UPPER(LTRIM(RTRIM(@Range)))= 'YES'
				SET @RangeId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NO'
				SET @RangeId=0
			
			IF UPPER(LTRIM(RTRIM(@ProRata)))= 'YES'
				SET @ProRateId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ProRata)))= 'NO'
				SET @ProRateId=0
			ELSE IF UPPER(LTRIM(RTRIM(@ProRata)))= 'ACTUAL'
				SET @ProRateId=2
			
			IF UPPER(LTRIM(RTRIM(@Qps)))= 'YES'
				SET @QPSId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'NO'
				SET @QPSId=0
			
			IF UPPER(LTRIM(RTRIM(@ForEvery)))= 'YES'
				SET @ForEveryId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ForEvery)))= 'NO'
				SET @ForEveryId=0
			IF UPPER(LTRIM(RTRIM(@EditSch)))= 'YES'
				SET @EditSchId=0
			ELSE IF UPPER(LTRIM(RTRIM(@EditSch)))= 'NO'
				SET @EditSchId=0
			IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'YES'
				SET @QPSResetId=1
			ELSE IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'NO'
				SET @QPSResetId=0
			IF LTRIM(RTRIM(@SchBudget))= ''
			BEGIN
				SET @SchBudget=0
			END
			IF @SchTypeId=4
			BEGIN
				IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))= 'DATE'
					SET @ApplySchId=1
				IF UPPER(LTRIM(RTRIM(@SetDisMode)))= 'CASH'
					SET @SettleSchId=1
				ELSE IF UPPER(LTRIM(RTRIM(@SetDisMode)))= 'CHEQUE'
					SET @SettleSchId=2
				IF LTRIM(RTRIM(@AdjDisSch))= 'NO'
					SET @AdjustSchId=0
				ELSE IF LTRIM(RTRIM(@AdjDisSch))= 'YES'
					SET @AdjustSchId=1
			END
			ELSE
			BEGIN
				IF @QPSId=1
				BEGIN
					IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))= 'DATE'
						SET @ApplySchId=1
					ELSE IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))='QUANTITY'
						SET @ApplySchId=2
					SET @SettleSchId=1
				END
				ELSE
				BEGIN
					SET @SettleSchId=1
					SET @ApplySchId=1
				END
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF @FBM='Yes'
			BEGIN
				SET @FBMId=1
				SET @SchBudget=0
			END
			ELSE
			BEGIN
				SET @FBMId=0
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF @SettlementType='Value'
			BEGIN
				SET @SettlementTypeId=1				
			END
			ELSE IF @SettlementType='Product'
			BEGIN
				SET @SettlementTypeId=2
			END
			ELSE 
			BEGIN
				SET @SettlementTypeId=0
			END
		END

		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@AllowUnCheck)))= 'YES'
			BEGIN
				SET @AllowUnCheckId=1
			END
			ELSE
			BEGIN
				SET @AllowUnCheckId=0
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF @Taction=1
			BEGIN
				EXEC Proc_DependencyCheck 'SchemeMaster',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					UPDATE SCHEMEMASTER SET SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget,SchStatus=@StatusId WHERE SchId=@GetKey
				END
				ELSE
				BEGIN
					DELETE FROM SchemeProducts WHERE SchId=@GetKey
					DELETE FROM SchemeRetAttr WHERE SchId=@GetKey
					DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabMultiFrePrds WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeRtrLevelValidation WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeRuleSettings WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeAnotherPrdDt WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeAnotherPrdHd WHERE SchId=@GetKey
					DELETE FROM SchemeSlabs WHERE SchId=@GetKey
					
					UPDATE SCHEMEMASTER SET SchDsc=LTRIM(RTRIM(@SchDesc)),CmpId=@CmpId,
					Claimable=@ClmableId,ClmAmton=@ClmAmtOnId,ClmRefId=@ClmGrpId,
					SchLevelId=@CmpPrdCtgId,SchType=@SchTypeId,BatchLevel=@BatId,
					FlexiSch=@FlexiId,FlexiSchType=@FlexiConId,CombiSch=@CombiId,
					Range=@RangeId,ProRata=@ProRateId,QPS=@QPSId,QPSReset=@QPSResetId,
					SchValidFrom=LTRIM(RTRIM(@SchStartDate)),SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget,ApyQPSSch=@ApplySchId,SetWindowDisp=@SettleSchId,
					SchemeLvlMode=@SelMode,SchStatus=@StatusId WHERE SchId=@GetKey

					INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,
					EnableRtrLvl,AllowSaving,AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,CalScheme,NoOfRtr,RtrCount)
					Select SchId,0,-1,-1,NULL,NULL,-1,-1,0,0,0,1,1,LastModDate,1,LastModDate,1,0,0 from schememaster (NOLOCK) where Claimable=1
					and SchId Not In(Select SchId from SchemeRuleSettings (NOLOCK))
				END
			END
			ELSE IF @Taction=2
			BEGIN
				IF @ConFig=1
				BEGIN
					SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
					IF @CmpPrdCtgId<@SLevel
					BEGIN
						SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='NO'
						AND A.SlabId=0 AND A.SlabValue=0
	
						SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[PrdCode] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
						A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='NO'
						AND A.SlabId=0 AND A.SlabValue=0
					END
					ELSE
					BEGIN
						SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='YES'
						AND A.SlabId=0 AND A.SlabValue=0
						SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[PrdCode] IN (SELECT PrdCCode FROM Product)
						AND  A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='YES'
						AND A.SlabId=0 AND A.SlabValue=0
					END
						IF @EtlCnt=@CmpCnt
						BEGIN
							SELECT @EtlCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode))
	
							SELECT @CmpCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
							INNER JOIN Product B ON A.[PrdCode]=b.PrdCCode
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode))
							IF @EtlCnt=@CmpCnt
							BEGIN	
								INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
								CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
								ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
								PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
								AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,
								BudgetAllocationNo,AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,SettlementType,ApplyClaim)
								VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
								LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
								CONVERT(VARCHAR(10),GETDATE(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId)
				
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'

								IF @FBMId=1
								BEGIN
									SET @GetKeyStr=LTRIM(RTRIM(@GetKeyStr))
									SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
									EXEC Proc_FBMTrack 45,@GetKeyStr,@GetKey,@FBMDate,1,0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeRuleSettings_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeRtrLevelValidation_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeAnotherPrdHd_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeAnotherPrdDt_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeAttribute_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeProduct_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabCombiPrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								
								INSERT INTO ETL_Prk_SchemeMaster_Temp(SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
								CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
								ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
								PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download) VALUES
								(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N',@BudgetAllocationNo,@SchBasedOnId,1)
							END
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeRuleSettings_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeRtrLevelValidation_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeAnotherPrdHd_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeAnotherPrdDt_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeAttribute_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeProduct_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabCombiPrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							
							INSERT INTO ETL_Prk_SchemeMaster_Temp(SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
							CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
							ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
							PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download) VALUES
							(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
							@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
							@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
							@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N',@BudgetAllocationNo,@SchBasedOnId,1)
						END							
				END
				ELSE
				BEGIN
					INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
					CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
					ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
					PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
					AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,BudgetAllocationNo,
					AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,SettlementType,ApplyClaim)
					VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
					LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
					@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
					@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
					@ApplySchId,@SettleSchId,1,1,convert(varchar(10),getdate(),121),1,
					convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId)
	
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'
					INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,
					EnableRtrLvl,AllowSaving,AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,CalScheme,NoOfRtr,RtrCount)
					Select SchId,0,-1,-1,NULL,NULL,-1,-1,0,0,0,1,1,LastModDate,1,LastModDate,1,0,0 from schememaster (NOLOCK) where Claimable=1
					AND SchId Not In(Select SchId from SchemeRuleSettings (NOLOCK))

					IF @FBMId=1
					BEGIN
						SET @GetKeyStr=LTRIM(RTRIM(@GetKeyStr))
						SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
						EXEC Proc_FBMTrack 45,@GetKeyStr,@GetKey,@FBMDate,1,0
					END
				END
			END
		END
		FETCH NEXT FROM Cur_SchMaster INTO  @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
		, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
		, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
		@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck
	END
	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END
GO

if not exists (select * from hotfixlog where fixid = 375)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(375,'D','2011-04-28',getdate(),1,'Core Stocky Service Pack 375')
