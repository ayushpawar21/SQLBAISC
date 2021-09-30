--[Stocky HotFix Version]=382
Delete from Versioncontrol where Hotfixid='382'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('382','2.0.0.5','D','2011-08-24','2011-08-24','2011-08-24',convert(varchar(11),getdate()),'Major: Product Release FOR PM,CK,B&L')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 382' ,'382'
GO
IF Not Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RECEIPTINVOICE') and name='XMLUpload')
BEGIN
	Alter Table RECEIPTINVOICE ADD XMLUpload  INT
END
GO
IF Not Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RECEIPTINVOICE') and name='CancelUpload')
BEGIN
	Alter Table RECEIPTINVOICE ADD CancelUpload  INT
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[dbo].[SchemeCombiCriteria]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[SchemeCombiCriteria] 
(
	SchId				INT,
	PrdMode				INT,
	PrdCtgValMainId		INT,
	PrdId				INT,
	MinAmount			NUMERIC(18,6),
	NoofLines			INT,
	DiscPer				NUMERIC(18,2),
	FlatAmt				NUMERIC(18,6),
	Points				NUMERIC(18,0),
	CONSTRAINT [FK_SchemeMaster_SchId] FOREIGN KEY 
	([SchId]) REFERENCES [dbo].[SchemeMaster] ([SchId])
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'CombiType' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='SchemeMaster'))
BEGIN
	ALTER TABLE SchemeMaster ADD CombiType INT NOT NULL DEFAULT 0 WITH VALUES
END
GO
--SRF-Nanda-240-001

if not exists (select * from dbo.sysobjects where id = object_id(N'[BarCodeHd]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[BarCodeHd]
	(
		[BarCodeId] [int] NOT NULL,
		[BarCode] [varchar](200) NULL,
		[PrdCode] [varchar](200) NULL,
		[ConvFact] [int] NULL,
	) ON [PRIMARY]
end
GO


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_BarCodeHd_BarCodeId]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
begin
	ALTER TABLE [dbo].[BarCodeHd] WITH NOCHECK ADD 
		CONSTRAINT [PK_BarCodeHd_BarCodeId] PRIMARY KEY  CLUSTERED 
		(
			[BarCodeId]
		)  ON [PRIMARY] 
end
GO
if not exists (select * from hotfixlog where fixid = 382)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(382,'D','2011-07-17',getdate(),1,'Core Stocky Service Pack 382')
GO

--SRF-Nanda-240-002

if not exists (select * from dbo.sysobjects where id = object_id(N'[TransactionWiseBarCodeDt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[TransactionWiseBarCodeDt]
	(
		[TransId] [int] NULL,
		[TransRefId] [int] NULL,
		[TransRefCode] [varchar](200) NULL,
		[BarCodeId] [int] NULL,
		[PrdId] [int] NULL,
		[PrdbatId] [int] NULL,
		[Qty] [int] NULL,
		[ColFlag] [int] NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-240-003

if exists (select * from dbo.sysobjects where id = object_id(N'[BLCmpBatCode]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [BLCmpBatCode]
GO

CREATE TABLE [dbo].[BLCmpBatCode]
(
	[CmpBatCode] [nvarchar](100) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-240-004

if not exists (select * from dbo.sysobjects where id = object_id(N'[PrdOrderQty]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[PrdOrderQty]
	(
		[PrdId] [int] NOT NULL,
		[UOMId] [int] NOT NULL,
		[VariationId] [int] NOT NULL,
		[NormId] [int] NOT NULL,
		[BaseQty] [numeric](38, 0) NULL,
		[Qty] [numeric](12, 2) NOT NULL,
		[Mode] [varchar](4) NOT NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-240-005

if not exists (select * from dbo.sysobjects where id = object_id(N'[PurchaseReceiptProductMapping]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[PurchaseReceiptProductMapping]
	(
		[CompInvNo] [nvarchar](25) NOT NULL,
		[CompInvDate] [datetime] NOT NULL,
		[SpmCode] [nvarchar](50) NOT NULL,
		[PrdId] [int] NOT NULL,
		[PrdCCode] [nvarchar](50) NOT NULL,
		[PrdName] [nvarchar](200) NOT NULL,
		[PrdMapCode] [nvarchar](50) NOT NULL,
		[PrdMapName] [nvarchar](200) NOT NULL,
		[UOMCode] [nvarchar](25) NOT NULL,
		[Qty] [int] NOT NULL,
		[Rate] [numeric](38, 6) NOT NULL,
		[GrossAmount] [numeric](38, 6) NOT NULL,
		[DiscAmount] [numeric](38, 6) NOT NULL,
		[TaxAmount] [numeric](38, 6) NOT NULL,
		[NetAmount] [numeric](38, 6) NOT NULL,
		[FreeSchemeFlag] [nvarchar](5) NOT NULL,
		[Availability] [tinyint] NOT NULL,
		[LastModBy] [tinyint] NOT NULL,
		[LastModDate] [datetime] NOT NULL,
		[AuthId] [tinyint] NOT NULL,
		[AuthDate] [datetime] NOT NULL,
		[SLNo] [int] NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-240-006

if not exists (Select Id,name from Syscolumns where name = 'Status' and id in (Select id from 
	Sysobjects where name ='ReplacementHd'))
begin
	ALTER TABLE [dbo].[ReplacementHd]
	ADD [Status] INT NOT NULL DEFAULT 1 WITH VALUES
END
GO

--SRF-Nanda-240-007

if exists (select * from dbo.sysobjects where id = object_id(N'[RptGRNListing_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptGRNListing_Excel]
GO

CREATE TABLE [dbo].[RptGRNListing_Excel]
(
	[PurRcptId] [bigint] NULL,
	[PurRcptRefNo] [nvarchar](50) NULL,
	[CmpInvNo] [nvarchar](1000) NULL,
	[InvDate] [datetime] NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [nvarchar](20) NULL,
	[PrdName] [nvarchar](50) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[InvBaseQty] [int] NULL,
	[RcvdGoodBaseQty] [int] NULL,
	[Uom1] [int] NULL,
	[Uom2] [int] NULL,
	[Uom3] [int] NULL,
	[Uom4] [int] NULL,
	[UnSalBaseQty] [int] NULL,
	[ShrtBaseQty] [int] NULL,
	[ExsBaseQty] [int] NULL,
	[RefuseSale] [tinyint] NULL,
	[PrdUnitLSP] [numeric](38, 6) NULL,
	[PrdGrossAmount] [numeric](38, 6) NULL,
	[UsrId] [int] NULL,
	[Disc] [numeric](38, 6) NULL,
	[Tax] [numeric](38, 6) NULL,
	[Net Amt.] [numeric](38, 6) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-240-008

if exists (select * from dbo.sysobjects where id = object_id(N'[RptPRNPurchaseReturnTemplate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptPRNPurchaseReturnTemplate]
GO

CREATE TABLE [dbo].[RptPRNPurchaseReturnTemplate]
(
	[Company] [nvarchar](50) NULL,
	[Company Invoice Date] [datetime] NULL,
	[Company Invoice Number] [nvarchar](50) NULL,
	[Date] [datetime] NULL,
	[Discount] [numeric](38, 6) NULL,
	[GRN Date] [datetime] NULL,
	[GRN Number] [nvarchar](50) NULL,
	[Gross Amount] [numeric](38, 6) NULL,
	[LSP] [numeric](38, 6) NULL,
	[MRP] [numeric](38, 6) NULL,
	[Net Amount] [numeric](38, 6) NULL,
	[Product Batch] [nvarchar](100) NULL,
	[Product Company Code] [nvarchar](50) NULL,
	[Product Company Name] [nvarchar](100) NULL,
	[Product Short Code] [nvarchar](50) NULL,
	[Product Short Name] [nvarchar](100) NULL,
	[Pur Quantity Salable] [int] NULL,
	[Pur Quantity Un Salable] [int] NULL,
	[PurRetId] [bigint] NULL,
	[Rate] [numeric](38, 6) NULL,
	[Reason] [nvarchar](50) NULL,
	[Ref Number] [nvarchar](50) NULL,
	[Return Mode] [nvarchar](50) NULL,
	[Return Quantity Salable] [int] NULL,
	[Return Quantity un Salable] [int] NULL,
	[Supplier] [nvarchar](50) NULL,
	[Tax Amount] [numeric](38, 6) NULL,
	[Tax percentage] [numeric](38, 6) NULL,
	[Total Discount Amount] [numeric](38, 6) NULL,
	[Total Gross Amount] [numeric](38, 6) NULL,
	[Total Net Amount] [numeric](38, 6) NULL,
	[Total Tax Amount] [numeric](38, 6) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-240-009

if exists (select * from dbo.sysobjects where id = object_id(N'[RptSISampleTemplate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptSISampleTemplate]
GO

CREATE TABLE [dbo].[RptSISampleTemplate]
(
	[Bill Ref Number] [nvarchar](50) NULL,
	[Company Sample Scheme Code] [nvarchar](50) NULL,
	[Date] [datetime] NULL,
	[Doc Ref Number] [nvarchar](50) NULL,
	[Due Date for Return] [datetime] NULL,
	[Eligible Qty] [numeric](38, 6) NULL,
	[Eligible Qty UOM] [nvarchar](50) NULL,
	[Issue Qty] [numeric](38, 6) NULL,
	[Issue Qty UOM] [nvarchar](50) NULL,
	[Issued Qty] [numeric](38, 6) NULL,
	[Issued Qty UOM] [nvarchar](50) NULL,
	[IssueId] [int] NULL,
	[Ref Number] [nvarchar](50) NULL,
	[Retailer] [nvarchar](50) NULL,
	[Route] [nvarchar](50) NULL,
	[Salesman] [nvarchar](50) NULL,
	[Sample Product Batch] [nvarchar](100) NULL,
	[Sample Product Company Code] [nvarchar](50) NULL,
	[Sample Product Company Name] [nvarchar](50) NULL,
	[Sample Product Short Name] [nvarchar](50) NULL,
	[Sample Scheme Code] [nvarchar](50) NULL,
	[To be Returned  - Value] [numeric](38, 6) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-240-010

if exists (select * from dbo.sysobjects where id = object_id(N'[RptSRNSalesReturnTemplate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptSRNSalesReturnTemplate]
GO

CREATE TABLE [dbo].[RptSRNSalesReturnTemplate]
(
	[Distributor Code] [nvarchar](20) NULL,
	[Distributor Name] [nvarchar](50) NULL,
	[Distributor Address1] [nvarchar](50) NULL,
	[Distributor Address2] [nvarchar](50) NULL,
	[Distributor Address3] [nvarchar](50) NULL,
	[PinCode] [int] NULL,
	[PhoneNo] [nvarchar](50) NULL,
	[Tax Type] [tinyint] NULL,
	[TIN Number] [nvarchar](50) NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[CST Number] [nvarchar](50) NULL,
	[LST Number] [nvarchar](50) NULL,
	[Licence Number] [nvarchar](50) NULL,
	[Drug Licence Number 1] [nvarchar](50) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug Licence Number 2] [nvarchar](50) NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](50) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[SalId] [int] NULL,
	[Invoice Number] [nvarchar](50) NULL,
	[Invoice Date] [datetime] NULL,
	[ReturnId] [int] NULL,
	[Sales Return Number] [nvarchar](50) NULL,
	[Sales Return Date] [datetime] NULL,
	[Sales Man] [nvarchar](50) NULL,
	[Route] [nvarchar](50) NULL,
	[Retailer Code] [nvarchar](50) NULL,
	[Retailer Name] [nvarchar](50) NULL,
	[Retailer Phone Number] [nvarchar](50) NULL,
	[Retailer CST Number] [nvarchar](50) NULL,
	[Retailer Drug Lic  Number] [nvarchar](50) NULL,
	[Retailer Lic Number] [nvarchar](50) NULL,
	[Retailer Tin Number] [nvarchar](50) NULL,
	[Retailer Address] [nvarchar](50) NULL,
	[Product Company Code] [nvarchar](20) NULL,
	[Product Company Name] [nvarchar](50) NULL,
	[Product Short Code] [nvarchar](100) NULL,
	[Product Short Name] [nvarchar](100) NULL,
	[Stock Type] [nvarchar](100) NULL,
	[Return Quantity] [numeric](18, 0) NULL,
	[Selling Rate] [numeric](18, 6) NULL,
	[Gross Amount] [numeric](18, 6) NULL,
	[Special Discount] [numeric](18, 6) NULL,
	[Scheme Discount] [numeric](18, 6) NULL,
	[Distributor Discount] [numeric](18, 6) NULL,
	[Cash Discount] [numeric](18, 6) NULL,
	[Tax Percentage] [numeric](18, 6) NULL,
	[Tax Amount Line Level] [numeric](18, 6) NULL,
	[Line level Net Amount] [numeric](18, 6) NULL,
	[Reason] [nvarchar](100) NULL,
	[Type] [nvarchar](50) NULL,
	[Mode] [nvarchar](50) NULL,
	[Total Gross Amount] [numeric](18, 6) NULL,
	[Total Special Discount] [numeric](18, 6) NULL,
	[Total Scheme Discount] [numeric](18, 6) NULL,
	[Total Distributor Discount] [numeric](18, 6) NULL,
	[Total Cash Discount] [numeric](18, 6) NULL,
	[Total Tax Amount] [numeric](18, 6) NULL,
	[Total Net Amount] [numeric](18, 6) NULL,
	[Total Discount] [numeric](18, 6) NULL,
	[RtrId] [int] NULL,
	[RMID] [int] NULL,
	[SMID] [int] NULL,
	[Credit Note/Replacement Reference No] [nvarchar](50) NULL,
	[Credit Note Reference No] [nvarchar](50) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-240-011

if not exists (select * from dbo.sysobjects where id = object_id(N'[SalInvHDAmt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[SalInvHDAmt]
	(
		[SalId] [bigint] NULL,
		[RefCode] [nvarchar](25) NOT NULL,
		[FieldDesc] [nvarchar](100) NOT NULL,
		[BaseQtyAmount] [numeric](18, 6) NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-240-012

if not exists (select * from dbo.sysobjects where id = object_id(N'[SalInvLineAmt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[SalInvLineAmt]
	(
		[SalId] [bigint] NULL,
		[PrdSlNo] [int] NULL,
		[RefCode] [nvarchar](25) NOT NULL,
		[FieldDesc] [nvarchar](100) NOT NULL,
		[LineUnitAmount] [numeric](18, 6) NULL,
		[LineBaseQtyAmount] [numeric](18, 6) NULL,
		[LineUom1Amount] [numeric](18, 6) NULL,
		[LineUnitPerc] [numeric](10, 6) NULL,
		[LineBaseQtyPerc] [numeric](10, 6) NULL,
		[LineUom1Perc] [numeric](10, 6) NULL,
		[LineEffectAmount] [numeric](18, 6) NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-240-013

if exists (select * from dbo.sysobjects where id = object_id(N'[TempRtrAccStatement]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TempRtrAccStatement]
GO

CREATE TABLE [dbo].[TempRtrAccStatement]
(
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[AType] [varchar](20) NULL,
	[InvoiceNo] [nvarchar](50) NULL,
	[RefNo] [nvarchar](100) NULL,
	[Opng] [numeric](38, 6) NULL,
	[Debit] [numeric](38, 6) NULL,
	[Credit] [numeric](38, 6) NULL,
	[Balance] [numeric](38, 6) NULL,
	[CBalance] [numeric](38, 6) NULL,
	[RtrAdd1] [nvarchar](50) NULL,
	[RtrAdd2] [nvarchar](50) NULL,
	[RtrAdd3] [nvarchar](50) NULL,
	[RtrPinNo] [int] NULL,
	[RtrTinNo] [nvarchar](50) NULL
) ON [PRIMARY]
GO


--SRF-Nanda-240-014

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_BarCode]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_BarCode]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_BarCode]
(
	[DistCode] [nvarchar](20) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[BarCode] [nvarchar](50) NULL,
	[ConvFactor] [int] NULL,
	[DownLoadFlag] [nvarchar](5) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-240-015

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_DailySales_Undelivered]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_DailySales_Undelivered]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_DailySales_Undelivered]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[SalInvNo] [nvarchar](50) NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvAmt] [numeric](38, 6) NULL,
	[SalTaxAmt] [numeric](38, 6) NULL,
	[SalSchAmt] [numeric](38, 6) NULL,
	[SalDisAmt] [numeric](38, 6) NULL,
	[SalSplDis] [numeric](38, 6) NULL,
	[SalRetAmt] [numeric](38, 6) NULL,
	[SalVisAmt] [numeric](38, 6) NULL,
	[SalNetAmt] [numeric](38, 6) NULL,
	[SalDistDis] [numeric](38, 6) NULL,
	[SalTotDedn] [numeric](38, 6) NULL,
	[SalRoundOffAmt] [numeric](38, 6) NULL,
	[Salesman] [nvarchar](100) NULL,
	[Route] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) NULL,
	[BillMode] [nvarchar](100) NULL,
	[DlvBoyName] [nvarchar](100) NULL,
	[VechName] [nvarchar](100) NULL,
	[SalDlvDate] [datetime] NULL,
	[DbAdjAmt] [numeric](38, 6) NULL,
	[CrAdjAmt] [numeric](38, 6) NULL,
	[OnAccountAmt] [numeric](38, 6) NULL,
	[SalReplaceAmt] [numeric](38, 6) NULL,
	[DeliveryRoute] [nvarchar](100) NULL,
	[PrdCode] [nvarchar](50) NULL,
	[PrdBatCde] [nvarchar](50) NULL,
	[SalInvQty] [int] NULL,
	[SelRateBeforTax] [numeric](38, 6) NULL,
	[SelRateAfterTax] [numeric](38, 6) NULL,
	[SalInvFree] [int] NULL,
	[SalInvTax] [numeric](38, 6) NULL,
	[SalInvSch] [numeric](38, 6) NULL,
	[SalInvDist] [numeric](38, 6) NULL,
	[SalCshDis] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[SalInvCashDisc] [numeric](38, 6) NULL,
	[BillStatus] [nvarchar](50) NULL,
	[UploadedDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-240-016

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_GetBarCodeDt]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_GetBarCodeDt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT * FROM dbo.Fn_GetBarCodeDt('1111')
CREATE  FUNCTION [dbo].[Fn_GetBarCodeDt] 
(
	@Pi_Code AS VARCHAR(100)
)
RETURNS @BarCodeDt TABLE
	(
		BarCodeId	INT ,
		PrdId		INT ,
		PrdCode		VARCHAR(100) ,
		PrdName		VARCHAR(200) ,
		PrdbatId	INT ,
		PrdBatCode	VARCHAR(100) ,
		ConvFact	INT 
	)
AS
/*********************************
* FUNCTION: Fn_GetBarCodeDt
* PURPOSE: Return Bar Code Details
* NOTES:
* CREATED: Boopathy.P 0n 16/09/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	INSERT INTO @BarCodeDt
	SELECT A.BarCodeId,A.PrdId,A.PrdCode,A.PrdName,C.PrdbatId,B.PrdBatCode,A.ConvFact FROM 
    (SELECT A.BarCodeId,B.PrdId,A.PrdCode,B.PrdName,A.ConvFact FROM BarCodeHd A INNER JOIN Product B 
	ON A.PrdCode=B.PrdCCode   WHERE A.BarCode=@Pi_Code) A INNER JOIN ProductBatch B ON A.PrdId=B.PrdId
	 INNER JOIN (SELECT MAX(A.PrdBatId) AS PrdbatId FROM Productbatch A INNER JOIN 
	(SELECT B.PrdId FROM BarCodeHd A INNER JOIN Product B ON A.PrdCode=B.PrdCCode
	WHERE A.BarCode=@Pi_Code) B ON A.PrdId=B.PrdId) C ON B.PrdbatId=C.PrdbatId
RETURN 
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-017

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_GetBatchDtWithStock]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_GetBatchDtWithStock]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT * FROM dbo.Fn_GetBatchDtWithStock(73,10362,1)
CREATE  FUNCTION [dbo].[Fn_GetBatchDtWithStock] 
(
	@Pi_PrdId AS INT,
	@Pi_PrdBatId AS INT,
	@Pi_LcnId AS INT
)
RETURNS @BatchDetails TABLE
	(
		PrdBatID		INT ,
		PrdBatCode		VARCHAR(100) ,
		MRP				NUMERIC(18,6) ,
		PurchaseRate	NUMERIC(18,6) ,
		SellRate		NUMERIC(18,6) ,
		StockAvail		INT ,
		PriceId			INT 
	)
AS
/*********************************
* FUNCTION: Fn_GetBarCodeDt
* PURPOSE: Return Bar Code Details
* NOTES:
* CREATED: Boopathy.P 0n 16/09/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
		INSERT INTO @BatchDetails
		SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,
		K.PrdBatDetailValue AS SellRate,0 as StockAvail,B.PriceId FROM ProductBatch A (NOLOCK) 
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 INNER JOIN 
		BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 INNER JOIN 
		ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 INNER JOIN 
		BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
		INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
		INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
		INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
--		INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId 
		WHERE A.Status = 1 AND A.PrdId=@Pi_PrdId  Order By A.PrdBatId DESC 
		--AND A.PrdbatId= @Pi_PrdBatId  --And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 AND F.LcnId = @Pi_LcnId
RETURN 
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_AutoBatchTransfer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_AutoBatchTransfer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
BEGIN TRANSACTION
TRUNCATE TABLE ErrorLog
SELECT * FROM ErrorLog
----SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
----		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
----		FROM ProductBatchLocation PBL WHERE PBL.PrdBatId>23999
----SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
----		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
----		FROM ProductBatchLocation PBL WHERE PBL.PrdBatId<23999
EXEC Proc_AutoBatchTransfer 33113,0
--SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
--		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
--		FROM ProductBatchLocation PBL WHERE PBL.PrdBatId>23999
--SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
--		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
--		FROM ProductBatchLocation PBL WHERE PBL.PrdBatId<23999
--SELECT * FROM StockLedger WHERE TransDate='2010-02-10'
--SELECT * FROM StockLedger WHERE PrdbatId>23999
--SELECT * FROM ProductBatchLocation WHERE PrdbatId>23999
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE     PROCEDURE [dbo].[Proc_AutoBatchTransfer]
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
	
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PrdId,PrdBatId,PrdBatCode FROM ProductBatch
	WHERE PrdBatId >@Pi_OldMaxPrdBatId ORDER BY PrdId,PrdBatId,PrdBatCode
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
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	RETURN	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-019

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_BLDailySales_Undelivered]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_BLDailySales_Undelivered]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_BLDailySales_Undelivered 0
SELECT * FROM Cs2Cn_Prk_DailySales_Undelivered ORDER BY SlNo
ROLLBACK TRANSACTION
*/
CREATE     PROCEDURE [dbo].[Proc_BLDailySales_Undelivered]
(
	@Po_ErrNo INT OUTPUT
)
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE		: Proc_BLDailySales_Undelivered
* PURPOSE		: To Extract Undelivered Bill Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 20/01/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
	DECLARE @CmpId 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_DailySales_Undelivered WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where procId = 1
	SET @Po_ErrNo=0 
	INSERT INTO Cs2Cn_Prk_DailySales_Undelivered 
	(
		DistCode	,
		SalInvNo	,
		SalInvDate	,
		SalInvAmt	,
		SalTaxAmt	,
		SalSchAmt	,
		SalDisAmt	,
		SalSplDis	,
		SalRetAmt	,
		SalVisAmt	,
		SalNetAmt	,
		SalDistDis	,
		SalTotDedn	,
		SalRoundOffAmt	,
		Salesman	,
		Route		,
		RtrId		,
		RtrName		,
		BillMode	,
		DlvBoyName	,
		VechName	,
		SalDlvDate	,
		DbAdjAmt	,	
		CrAdjAmt	,
		OnAccountAmt	,	
		SalReplaceAmt	,
		DeliveryRoute	,
		PrdCode		,
		PrdBatCde	,
		SalInvQty	,
		SelRateBeforTax	,
		SelRateAfterTax	,
		SalInvFree	,
		SalInvTax	,
		SalInvSch	,
		SalInvDist	,
		SalCshDis	,
		PrdNetAmt	,
		SalInvCashDisc	,
		BillStatus	,
		UploadedDate ,
		UploadFlag		 
	)
	SELECT 	@DistCode,A.SalInvNo ,A.SalInvDate ,A.SalGrossAmount ,A.SalTaxAmount,
	A.SalSchDiscAmount,A.SalCDAmount,A.SalSplDiscAmount,A.MarketRetAmount ,
	A.WindowDisplayAmount,A.SalNetAmt,A.SalDBDiscAmount ,A.TotalDeduction ,
	A.SalRoundOffAmt ,B.SMName ,C.RMName ,A.RtrId ,R.RtrName ,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	ISNULL(D.DlvBoyName,''),ISNULL(E.VehicleRegNo,'') AS VehicleName ,
	A.SalDlvDate ,A.DBAdjAmount ,A.CRAdjAmount ,A.OnAccountAmount ,A.ReplacementDiffAmount ,
	F.RMName ,H.PrdCCode ,I.CmpBatCode ,SUM(G.BaseQty) AS SalInvQty ,G.PrdUnitSelRate ,
	G.PrdUnitSelRate ,SUM(G.SalManFreeQty) AS SalInvFree ,	SUM(G.PrdTaxAmount) AS SalInvTax ,
	SUM(G.PrdSchDiscAmount) AS SalInvSch ,	SUM(G.PrdDBDiscAmount) AS SalInvDist ,
	SUM(G.PrdCDAmount) AS SalCshDis ,	SUM(G.PrdNetAmount) AS PrdNetAmount ,
	(A.SalDBDiscAmount) AS SalInvCshDisc ,	'Pending' AS BillStatus,GETDATE() AS UploadedDate,
	'N' AS UploadFlag
	FROM SalesInvoice A  (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID 
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID 
	LEFT OUTER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId 
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId 
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID 
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId 
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId 
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId 			
	WHERE A.Dlvsts <3	
	GROUP BY A.SalInvNo,A.SalInvDate,A.SalGrossAmount,A.SalTaxAmount,A.SalSchDiscAmount,A.SalCDAmount,
	A.MarketRetAmount,A.WindowDisplayAmount ,A.SalNetAmt,A.SalDBDiscAmount,
	A.TotalDeduction,A.SalRoundOffAmt,B.SMName,C.RMName,A.RtrId ,A.BillMode,D.DlvBoyName,
	E.VehicleRegNo,A.SalDlvDate,A.DBAdjAmount,A.CRAdjAmount,OnAccountAmount,
	ReplacementDiffAmount,F.RMName,H.PrdCCode,I.CmpBatCode,G.PrdUnitSelRate,A.SalSplDiscAmount,R.RtrName
	UNION ALL
	SELECT 	@DistCode,A.SalInvNo ,A.SalInvDate ,A.SalGrossAmount ,A.SalTaxAmount,
	A.SalSchDiscAmount,A.SalCDAmount,A.SalSplDiscAmount,A.MarketRetAmount ,
	A.WindowDisplayAmount,A.SalNetAmt,A.SalDBDiscAmount ,A.TotalDeduction ,
	A.SalRoundOffAmt ,B.SMName ,C.RMName ,A.RtrId ,R.RtrName ,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	ISNULL(D.DlvBoyName,'') ,ISNULL(E.VehicleRegNo,'') AS VehicleName ,
	A.SalDlvDate ,A.DBAdjAmount ,A.CRAdjAmount ,A.OnAccountAmount ,A.ReplacementDiffAmount ,
	F.RMName ,H.PrdCCode ,I.CmpBatCode ,SUM(G.BaseQty) AS SalInvQty ,G.PrdUnitSelRate ,
	G.PrdUnitSelRate ,SUM(G.SalManFreeQty) AS SalInvFree ,	SUM(G.PrdTaxAmount) AS SalInvTax ,
	SUM(G.PrdSchDiscAmount) AS SalInvSch ,	SUM(G.PrdDBDiscAmount) AS SalInvDist ,
	SUM(G.PrdCDAmount) AS SalCshDis ,	SUM(G.PrdNetAmount) AS PrdNetAmount ,
	(A.SalDBDiscAmount) AS SalInvCshDisc ,	'Cancelled' AS BillStatus,GETDATE() AS UploadedDate,
	'N' AS UploadFlag
	FROM SalesInvoice A  (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID 
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID 
	LEFT OUTER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId 
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId 
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID 
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId 
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId 
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId 			
	WHERE A.Dlvsts =3 AND A.Upload=0	
	GROUP BY A.SalInvNo,A.SalInvDate,A.SalGrossAmount,A.SalTaxAmount,A.SalSchDiscAmount,A.SalCDAmount,
	A.MarketRetAmount,A.WindowDisplayAmount ,A.SalNetAmt,A.SalDBDiscAmount,
	A.TotalDeduction,A.SalRoundOffAmt,B.SMName,C.RMName,A.RtrId ,A.BillMode,D.DlvBoyName,
	E.VehicleRegNo,A.SalDlvDate,A.DBAdjAmount,A.CRAdjAmount,OnAccountAmount,
	ReplacementDiffAmount,F.RMName,H.PrdCCode,I.CmpBatCode,G.PrdUnitSelRate,A.SalSplDiscAmount,R.RtrName
	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySales_Undelivered WHERE BillStatus='Cancelled') AND Dlvsts=3
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BarCode]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BarCode]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- EXEC Proc_Cn2Cs_BarCode 0
-- SELECT * FROM ErrorLog
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_BarCode]
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE: Proc_Cn2Cs_BarCode
* PURPOSE: To Insert and Update records Of Barcode
* CREATED: Boopathy.P on 20/09/2010
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @ErrDesc	AS VARCHAR(1000)
	DECLARE @TabName	AS VARCHAR(200)
	DECLARE @GetKey		AS INT
	DECLARE @Taction	AS INT
	DECLARE @sSQL		AS VARCHAR(4000)
	DECLARE @iCnt		AS INT
	DECLARE @BarCode	AS VARCHAR(200)
	DECLARE @PrdCode	AS VARCHAR(200)
	DECLARE @ConvFact	AS INT
	DECLARE @BarCodeId	AS INT
	DECLARE @PrdId		AS INT
	SET @TabName = 'Cn2CS_Prk_BarCode'
	SET @Po_ErrNo =0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PrdToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE PrdToAvoid	
	END
	CREATE TABLE PrdToAvoid
	(
		PrdCode		NVARCHAR(50)
	)
	
	INSERT INTO PrdToAvoid
	SELECT PrdCCode FROM Cn2CS_Prk_BarCode WHERE PrdCCode NOT IN (SELECT PrdCCode from PRODUCT) AND DownloadFlag='D'
	INSERT INTO Errorlog 
	SELECT 1,@TabName,'Product Code', PrdCode + ' does not exixts' FROM PrdToAvoid
	DECLARE Cur_SchMaster CURSOR
	FOR SELECT BarCode,PrdCCode,ConvFactor FROM Cn2CS_Prk_BarCode WHERE DownloadFlag='D' 
			AND PrdCCode NOT IN (SELECT PrdCode FROM PrdToAvoid) 
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @BarCode,@PrdCode,@ConvFact
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		
		IF LTRIM(RTRIM(@BarCode))= ''
		BEGIN
			SET @ErrDesc = 'BarCode should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'BarCode',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ConvFact))= '' OR CAST(LTRIM(RTRIM(@ConvFact)) AS INT) <=0
		BEGIN
			SET @ErrDesc = 'Convertion Factor should be greater than Zero :' + LTRIM(RTRIM(@PrdCode))
			INSERT INTO Errorlog VALUES (1,@TabName,'Convertion Factor',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF @Po_ErrNo=0
		BEGIN
			SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=@PrdCode
			IF EXISTS (SELECT * FROM BarCodeHd WHERE BarCode=LTRIM(RTRIM(@BarCode)) AND PrdCode=LTRIM(RTRIM(@PrdCode))) 
			BEGIN
				SELECT @BarCodeId=BarCodeId FROM BarCodeHd WHERE BarCode=LTRIM(RTRIM(@BarCode)) AND PrdCode=LTRIM(RTRIM(@PrdCode))
				SET @Taction = 1
			END
			ELSE
			BEGIN
				SELECT @BarCodeId=ISNULL(MAX(BarCodeId),0)+1 FROM BarCodeHd
				SET @Taction = 2
			END
			IF @Taction = 1
			BEGIN
				UPDATE BarCodeHd Set ConvFact=@ConvFact WHERE BarCode=LTRIM(RTRIM(@BarCode)) AND PrdCode=LTRIM(RTRIM(@PrdCode))
			END
			ELSE
			BEGIN
				INSERT INTO BarCodeHd
				SELECT @BarCodeId,LTRIM(RTRIM(@BarCode)),LTRIM(RTRIM(@PrdCode)),@ConvFact
			END
		END
		FETCH NEXT FROM Cur_SchMaster INTO  @BarCode,@PrdCode,@ConvFact
	END
	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-021

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportBarCode]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportBarCode]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].[Proc_ImportBarCode]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportBarCode
* PURPOSE	: To Insert and Update records  from xml file in the Table BarCodeHd
* CREATED	: Boopathy
* CREATED DATE	: 20/09/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records	
	
	DELETE FROM Cn2CS_Prk_BarCode WHERE DownloadFlag='Y'
	INSERT INTO Cn2CS_Prk_BarCode
			SELECT  [DistCode] ,[PrdCCode],[BarCode],[ConvFactor],'D'
			FROM 	OPENXML (@hdoc,'/Root/Console2CS_BarCode ',1)
			WITH (
				[DistCode]	 VARCHAR(200),
				[PrdCCode]	 VARCHAR(200),
				[BarCode]	 VARCHAR(200),
				[ConvFactor]	 INT
		
			     ) XMLObj
EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptHierarchyWiseSalesReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptHierarchyWiseSalesReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptHierarchyWiseSalesReport 218,1,0,'BNLB',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptHierarchyWiseSalesReport]
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
/**********************************************************************************************
* PROCEDURE  : Proc_RptHierarchyWiseSalesReport
* PURPOSE    : To Generate Hierarchy Wise Sales Report
* CREATED BY : R.Vasantharaj 
* CREATED ON : 27.01.2011 
* MODIFICATION:
************************************************************************************************/
SET NOCOUNT ON
BEGIN
DECLARE @NewSnapId 	AS	INT
DECLARE @DBNAME		AS 	nvarchar(50)
DECLARE @TblName 	AS	nvarchar(500)
DECLARE @TblStruct 	AS	nVarchar(4000)
DECLARE @TblFields 	AS	nVarchar(4000)
DECLARE @sSql		AS 	nVarChar(4000)
DECLARE @ErrNo	 	AS	INT
DECLARE @PurDBName	AS	nVarChar(100)
--Filter Variable
DECLARE @FromDate	 AS	DATETIME
DECLARE @ToDate	 	 AS	DATETIME
DECLARE @CmpId       AS  INT
DECLARE @SMId 		 AS	INT
DECLARE @RMId	 	 AS	INT
DECLARE @RtrId	 	 AS	INT
DECLARE @CtgLevelId	 AS	INT
DECLARE @RtrClassId	 AS	INT
DECLARE @CtgMainId 	 AS	INT
DECLARE @PDC	     AS	INT
DECLARE @PrdCatId	 AS	INT
DECLARE @PrdId		 AS	INT
DECLARE @HirMainId	 AS INT
DECLARE @CtgValue    AS INT
DECLARE	@EXLFlag	 AS	INT
DECLARE @CancelValue AS	INT
--Till Here
--EXEC Proc_ReturnRptProduct 218,1
EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
EXEC Proc_GetProductwiseHierarchy
--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @HirMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))
SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
--Till Here
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--Till Here'
CREATE TABLE #RptHirerarchyWiseSales
		(
	    [Salesman Name] NVARCHAR(100),
		[Product/Band]  NVARCHAR(4000),
		[FreeQty]       INT,
		[Saleable Qty]  INT,
		[Gross Amt]     NUMERIC(18, 2),
		[Selling Rate]  NUMERIC(18, 2)
		)
SET @TblName = 'RptHirerarchyWiseSales'
SET @TblStruct = '
		[Salesman Name] NVARCHAR(100),
		[Product/Band]  NVARCHAR(4000),
		[FreeQty]       INT,
		[Saleable Qty]  INT,
		[Gross Amt]     NUMERIC(18, 2),
		[Selling Rate]  NUMERIC(18, 2)'
SET @TblFields = '[Salesman Name],[Product/Band],[FreeQty],[Saleable Qty],[Gross Amt],[Selling Rate]'
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
    IF @CancelValue = 2
	BEGIN
		SELECT DISTINCT Prdid, C.PrdCtgValName INTO #Tempa 
		FROM 
			ProductCategoryValue C 
			INNER JOIN ProductCategoryValue D ON
			D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode as nvarchar(4000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			INNER JOIN  ProductCategoryLevel PCL ON PCL.CmpPrdCtgId=C.CmpPrdCtgId 
		WHERE  PCL.CmpPrdCtgId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
			 	INSERT INTO #RptHirerarchyWiseSales([Salesman Name],[Product/Band],[FreeQty],[Saleable Qty],[Gross Amt],[Selling Rate])
				SELECT DISTINCT 				
					S.SMName AS [Salesman Name],A.PrdCtgValName AS [Product/Band],SIP.SalSchFreeQty AS [FreeQty],
                    SUM(SIP.BaseQty) AS [Saleable Qty],SUM(SIP.PrdGrossAmount) AS [Gross Amt],
                    SUM(SIP.PrdGrossAmount)/SUM(SIP.BaseQty) AS [Selling Rate] 
				FROM #Tempa A
						INNER JOIN  SalesInvoiceProduct SIP ON SIP.PrdId=A.PrdId
						INNER JOIN  SalesInvoice SI ON SI.SalId=SIP.SalId
						INNER JOIN  Salesman S ON S.SMId= SI.SMId
						INNER JOIN  RouteMaster RM ON RM.RMId=SI.RMId
						INNER JOIN  Retailer R ON R.RtrId=SI.RtrId
						INNER JOIN  RetailerValueClassMap RVCM WITH (NOLOCK)ON R.Rtrid = RVCM.RtrId 
						INNER JOIN  RetailerValueClass RVC WITH (NOLOCK) ON RVCM.RtrValueClassId = RVC.RtrClassId
							            AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
						                RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
						INNER JOIN Product P ON SIP.PrdId = P.Prdid 
				WHERE (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
									SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						 AND (SI.RMId=(CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
									SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
									
						 AND (SI.SMId=(CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
									SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				
						 AND (SI.SalInvDate Between @FromDate and @ToDate) AND SI.DlvSts NOT IN (3)
				AND 
				(SIP.PrdId = (CASE @PrdId WHEN 0 THEN SIP.PrdId Else 0 END) OR
					SIP.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
                GROUP BY S.SMName,A.PrdCtgValName,SIP.SalSchFreeQty--SIP.PrdUnitSelRate
    END
		ELSE IF @CancelValue=1
		BEGIN
            SELECT DISTINCT Prdid, C.PrdCtgValName INTO #Tempb 
		FROM 
			ProductCategoryValue C 
			INNER JOIN ProductCategoryValue D ON
			D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode as nvarchar(4000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			INNER JOIN  ProductCategoryLevel PCL ON PCL.CmpPrdCtgId=C.CmpPrdCtgId 
		WHERE  PCL.CmpPrdCtgId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				INSERT INTO #RptHirerarchyWiseSales([Salesman Name],[Product/Band],[FreeQty],[Saleable Qty],[Gross Amt],[Selling Rate])
				SELECT DISTINCT 				
					S.SMName AS [Salesman Name],B.PrdCtgValName AS [Product/Band],SIP.SalSchFreeQty AS [FreeQty],
                    SUM(SIP.BaseQty) AS [Saleable Qty],SUM(SIP.PrdGrossAmount) AS [Gross Amt],
                    SUM(SIP.PrdGrossAmount)/SUM(SIP.BaseQty) AS [Selling Rate] 
				FROM #Tempb B
						INNER JOIN  SalesInvoiceProduct SIP ON SIP.PrdId=B.PrdId
						INNER JOIN  SalesInvoice SI ON SI.SalId=SIP.SalId
						INNER JOIN  Salesman S ON S.SMId= SI.SMId
						INNER JOIN  RouteMaster RM ON RM.RMId=SI.RMId
						INNER JOIN  Retailer R ON R.RtrId=SI.RtrId
						INNER JOIN  RetailerValueClassMap RVCM WITH (NOLOCK)ON R.Rtrid = RVCM.RtrId 
						INNER JOIN  RetailerValueClass RVC WITH (NOLOCK) ON RVCM.RtrValueClassId = RVC.RtrClassId
							            AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
						                RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				WHERE (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
									SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						 AND (SI.RMId=(CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
									SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
									
						 AND (SI.SMId=(CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
									SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				
						 AND (SI.SalInvDate Between @FromDate and @ToDate) AND SI.DlvSts IN(4,5)
                         AND (SIP.PrdId = (CASE @PrdId WHEN 0 THEN SIP.PrdId Else 0 END) OR
					          SIP.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
                GROUP BY S.SMName,B.PrdCtgValName,SIP.SalSchFreeQty--,SIP.PrdUnitSelRate
     END
END
    --Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptHirerarchyWiseSales
	-- Till Here
SELECT Distinct  * FROM #RptHirerarchyWiseSales 
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-023

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptPendingOrderReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptPendingOrderReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

Create proc [dbo].[Proc_RptPendingOrderReport]
--EXEC Proc_RptPendingOrderReport 226,1,0,'BNLB',0,0,1
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
/**********************************************************************************************
* PROCEDURE  : Proc_RptPendingOrderReport
* PURPOSE    : To Generate Pending Order Report
* CREATED BY : R.Vasantharaj 
* CREATED ON : 06.04.2011 
* MODIFICATION:
************************************************************************************************/
AS
SET NOCOUNT ON 
BEGIN
DECLARE @NewSnapId 	AS	INT
DECLARE @DBNAME		AS 	nvarchar(50)
DECLARE @TblName 	AS	nvarchar(500)
DECLARE @TblStruct 	AS	nVarchar(4000)
DECLARE @TblFields 	AS	nVarchar(4000)
DECLARE @sSql		AS 	nVarChar(4000)
DECLARE @ErrNo	 	AS	INT
DECLARE @PurDBName	AS	nVarChar(100)
--Filter Variable
DECLARE @FromDate	 AS	DATETIME
DECLARE @ToDate	 	 AS	DATETIME
DECLARE @CmpId       AS  INT
DECLARE @SMId 		 AS	INT
DECLARE @RMId	 	 AS	INT
DECLARE @RtrId	 	 AS	INT
DECLARE @CtgLevelId	 AS	INT
DECLARE @RtrClassId	 AS	INT
DECLARE @CtgMainId 	 AS	INT
DECLARE @HirMainId   AS INT
DECLARE @CtgValue    AS INT
DECLARE @PrdCatId	 AS	INT
DECLARE @PrdId		 AS	INT
--Till Here
EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
EXEC Proc_GetProductwiseHierarchy
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @HirMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
CREATE TABLE #RptPendingOrder
	(
		RtrId         INT,
		RetailerName  NVARCHAR(1000),
		OrderNo       NVARCHAR(100),         
		OrderDate     DATETIME,
		PrdId         INT,
		Brand         NVARCHAR(4000),               
		ProductName   NVARCHAR(4000),
		Qty           INT,
		[Value]       NUMERIC(18, 2)
	)
SET @TblName = 'RptPendingOrder'
SET @TblStruct = '
		RtrId         INT,
		RetailerName  NVARCHAR(1000),
		OrderNo       NVARCHAR(100),         
		OrderDate     DATETIME,
		PrdId         INT,
		Brand         NVARCHAR(4000),               
		ProductName   NVARCHAR(4000),
		Qty           INT,
		[Value]       NUMERIC(18, 2)'
SET @TblFields = 'RtrId,RetailerName,OrderNo,OrderDate,PrdId,Brand,ProductName,Qty,[Value]'
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
INSERT INTO #RptPendingOrder(RtrId,RetailerName,OrderNo,OrderDate,PrdId,Brand,ProductName,Qty,[Value]) 
SELECT F.RtrId,G.RtrName AS RetailerName,E.OrderNo,F.OrderDate,E.PrdId,A.PrdCtgValName AS Brand,C.PrdName AS ProductName,(E.TotalQty-E.BilledQty)AS Qty,
((E.TotalQty-E.BilledQty)* J.PrdBatDetailValue) AS Value 
FROM ProductCategoryValue A
	INNER JOIN  ProductCategoryValue B ON B.PrdCtgValLinkCode LIKE Cast(A.PrdCtgValLinkCode as nvarchar(4000)) + '%'
	INNER JOIN  Product C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
	INNER JOIN  ProductCategoryLevel D ON D.CmpPrdCtgId=A.CmpPrdCtgId
	INNER JOIN  OrderBookingProducts E WITH(NOLOCK) ON C.PrdId=E.PrdId 
	INNER JOIN  OrderBooking F WITH(NOLOCK)ON F.OrderNo=E.OrderNo
	INNER JOIN  Retailer G WITH(NOLOCK) ON F.RtrId=G.RtrId
	INNER JOIN  ProductCategoryValue H WITH(NOLOCK) ON C.PrdCtgValMainId=H.PrdCtgValMainId
	INNER JOIN  ProductBatch I WITH(NOLOCK) ON E.PrdId=I.PrdId and C.PrdId=I.PrdId and E.PrdBatId=I.PrdBatId
	INNER JOIN  ProductBatchDetails J WITH(NOLOCK) ON E.PrdBatId=J.PrdBatId and I.PrdBatId=J.PrdBatId 
	INNER JOIN  BatchCreation K WITH(NOLOCK) ON J.BatchSeqId=K.BatchSeqId and J.SlNo=K.SlNo and K.FieldDesc='Selling'
	INNER JOIN  RouteMaster L ON F.RmId=L.RmId
	INNER JOIN  Salesman M ON F.SMId=M.SMId
WHERE (G.RtrId = (CASE @RtrId WHEN 0 THEN G.RtrId ELSE 0 END) OR
					 G.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						 AND (L.RMId=(CASE @RMId WHEN 0 THEN L.RMId ELSE 0 END) OR
									L.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
									
						 AND (M.SMId=(CASE @SMId WHEN 0 THEN M.SMId ELSE 0 END) OR
									M.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				
						 AND (F.OrderDate Between @FromDate and @ToDate) 
				         
                         AND D.CmpPrdCtgId IN (SELECT iCountid FROM Fn_ReturnRptFilters(226,16,1))
    --Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPendingOrder
	-- Till Here
SELECT Distinct  * FROM #RptPendingOrder ORDER BY OrderNo  
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-024

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRetailerAccStatement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRetailerAccStatement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---EXEC Proc_RptRetailerAccStatement 216,1,0,'NV02100309',0,0,1
CREATE   PROCEDURE [dbo].[Proc_RptRetailerAccStatement]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptRetailerAccStatement
* PURPOSE	: To get the Retailer Accounting Statements
* CREATED	: Mohamed Bahurudeen .G
* CREATED DATE	: 07/04/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	NVARCHAR(50)
	DECLARE @TblName 		AS	NVARCHAR(500)
	DECLARE @TblStruct 		AS	NVARCHAR(4000)
	DECLARE @TblFields 		AS	NVARCHAR(4000)
	DECLARE @sSql			AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
	DECLARE @Opng			AS	FLOAT
	DECLARE @Cnt			AS	INT
	DECLARE @Inc			AS	INT
	DECLARE @Bal			AS	FLOAT
	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @RtrId		    AS	INT
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	--Till Here
	CREATE TABLE #RptRtrAccStatement
	(
			Id				BIGINT,
			DATE			DATETIME,
			ATYPE	 		NVARCHAR(20),
			INVOICENO 		NVARCHAR(50),
			REFNO	 		NVARCHAR(100),
			OPNG			NUMERIC (38,6),
			DEBIT			NUMERIC (38,6),
			CREDIT			NUMERIC	(38,6),
			BALANCE			NUMERIC	(38,6),
			CBALANCE		NUMERIC	(38,6),
			RTRADD1 		NVARCHAR(50),
			RTRADD2 		NVARCHAR(50),
			RTRADD3 		NVARCHAR(50),
			RTRPINNO 		NVARCHAR(50),
			RTRTINNO 		NVARCHAR(50)
	)
	SET @TblName = 'RptRtrAccStatement'
	SET @TblStruct = '	
						Id				BIGINT,
						DATE			DATETIME,
						ATYPE	 		NVARCHAR(20),
						INVOICENO 		NVARCHAR(50),
						REFNO	 		NVARCHAR(100),
						OPNG			NUMERIC (38,6),
						DEBIT			NUMERIC (38,6),
						CREDIT			NUMERIC	(38,6),
						BALANCE			NUMERIC	(38,6),
						CBALANCE		NUMERIC	(38,6),
						RTRADD1 		NVARCHAR(50),
						RTRADD2 		NVARCHAR(50),
						RTRADD3 		NVARCHAR(50),
						RTRPINNO 		NVARCHAR(50),
						RTRTINNO 		NVARCHAR(50)	'
	SET @TblFields = 'Id,DATE,ATYPE,INVOICENO,REFNO,OPNG,DEBIT,BALANCE,CBALANCE'
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
		SET @Opng = (SELECT SUM(Op.Opng) as Opng FROM (
										SELECT isnull(Sum(SalNetamt),0) as Opng FROM SalesInvoice
										WHERE
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND SalInvDate < @FromDate AND DlvSts IN(4,5)
										UNION ALL
										SELECT (-1) * isnull(sum(isnull(RtnNetAmt,0)+isnull(RtnRoundOffAmt,0)),0) as Opng FROM ReturnHeader
										WHERE	
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND ReturnDate < @FromDate AND Status IN(0)
										UNION ALL
										SELECT isnull(Sum(Amount),0) as Opng FROM DebitNoteRetailer
										WHERE	
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND DbNoteDate < @FromDate AND Status IN(1)
										UNION ALL
										SELECT (-1) * isnull(Sum(Amount),0) as Opng FROM CreditNoteRetailer
										WHERE
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND CrNoteDate < @FromDate AND Status IN(1) AND TransId<>30
										UNION ALL
										SELECT (-1) * isnull(Sum(DiffAmount),0) as Opng FROM ReplacementHD
										WHERE	
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND RepDate < @FromDate
										
										UNION ALL
										SELECT (-1) * isnull(Sum(RI.SalInvAmt),0) as Opng FROM ReceiptInvoice RI
											INNER JOIN Receipt RE ON RE.InvRcpNo=RI.InvRcpNo
											INNER JOIN SalesInvoice SI on RI.SalId=SI.SalId
										WHERE
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND RE.InvRcpDate < @FromDate AND InvInsSta NOT IN(4) and RI.CancelStatus IN(1)
									    ) Op)
		TRUNCATE TABLE TempRtrAccStatement
		INSERT INTO TempRtrAccStatement
		SELECT Date,Type,InvoiceNo,RefNo,Opng,Debit,Credit,0 as Balance,0 as CBalance,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo From
										(
											SELECT SalInvDate as Date,'Invoice' as Type,SalInvNo as InvoiceNo,'' as RefNo,@Opng as Opng,isnull(SalNetamt,0) as Debit,0 as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo  FROM SalesInvoice SI
												INNER JOIN Retailer Rtr on SI.RtrId=Rtr.RtrId
											WHERE
												(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
													SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (SalInvDate Between @FromDate and @ToDate) AND DlvSts IN(4,5)
											UNION ALL
											SELECT ReturnDate as Date,'Return' as Type,ReturnCode as InvoiceNo,SalInvNo as RefNo,@Opng as Opng,0 as Debit,(isnull(RtnNetAmt,0)+isnull(RtnRoundOffAmt,0)) as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo FROM ReturnHeader Rh
												INNER JOIN SalesInvoice SI on Rh.SalId=SI.SalId
												INNER JOIN Retailer Rtr on SI.RtrId=Rtr.RtrId
											WHERE
												(Rh.RtrId = (CASE @RtrId WHEN 0 THEN Rh.RtrId ELSE 0 END) OR
														Rh.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (ReturnDate Between @FromDate and @ToDate) AND Status IN(0)
											UNION ALL
											SELECT DbNoteDate as Date,'Debit Note' as Type,DbNoteNumber as InvoiceNo,PostedRefNo as RefNo,
												@Opng as Opng,isnull(Amount,0) as Debit,0 as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo 
												FROM DebitNoteRetailer Dr
												INNER JOIN Retailer Rtr on Dr.RtrId=Rtr.RtrId 
											WHERE	
												(Dr.RtrId = (CASE @RtrId WHEN 0 THEN Dr.RtrId ELSE 0 END) OR
														Dr.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (DbNoteDate Between @FromDate and @ToDate) AND Status IN(1)
											UNION ALL
											SELECT CrNoteDate as Date,'Credit Note' as Type,CrNoteNumber as InvoiceNo,PostedRefNo as RefNo,
													@Opng as Opng,0 as Debit,isnull(Amount,0) as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo 
											FROM CreditNoteRetailer Cr
												INNER JOIN Retailer Rtr on Cr.RtrId=Rtr.RtrId	
											WHERE	
												(Cr.RtrId = (CASE @RtrId WHEN 0 THEN Cr.RtrId ELSE 0 END) OR
														Cr.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (CrNoteDate Between @FromDate and @ToDate) AND Status IN(1) AND TransId<>30
											UNION ALL
											SELECT RepDate as Date,'Replacement' as Type,RepRefNo as InvoiceNo,DocRefNo as RefNo,@Opng as Opng,(CASE WHEN ((-1) * isnull(DiffAmount,0))<=0 THEN 0 ELSE ((-1) * isnull(DiffAmount,0)) END) as Debit,(CASE WHEN isnull(DiffAmount,0)<=0 THEN 0 ELSE isnull(DiffAmount,0) END) as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo FROM ReplacementHD Rph
												INNER JOIN Retailer Rtr on Rph.RtrId=Rtr.RtrId
											WHERE
												(Rph.RtrId = (CASE @RtrId WHEN 0 THEN Rph.RtrId ELSE 0 END) OR
														Rph.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (RepDate Between @FromDate and @ToDate)
											UNION ALL
											SELECT RE.InvRcpDate as Date,'Collection' as Type,RI.InvRcpNo as InvoiceNo,Replace(RI.InvInsNo,'0','') as RefNo,55 as Opng,0 as Debit,
													isnull(SUM(RI.SalInvAmt),0) as Credit,Rtr.RtrAdd1,Rtr.RtrAdd2,Rtr.RtrAdd3,Rtr.RtrPinNo,Rtr.RtrTINNo
												FROM ReceiptInvoice RI
												INNER JOIN Receipt RE ON RE.InvRcpNo=RI.InvRcpNo
												INNER JOIN SalesInvoice SI on RI.SalId=SI.SalId
												INNER JOIN Retailer Rtr on SI.RtrId=Rtr.RtrId
											WHERE
												(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
														SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (RE.InvRcpDate Between @FromDate and @ToDate) AND InvInsSta NOT IN(4) AND RI.CancelStatus IN(1)
											GROUP BY  RE.InvRcpDate,RI.InvRcpNo,RI.InvInsNo,Rtr.RtrAdd1,Rtr.RtrAdd2,Rtr.RtrAdd3,Rtr.RtrPinNo,
													Rtr.RtrTINNo
										) S
		ORDER BY Date ASC
		SET @Cnt = (Select Count(Date) from TempRtrAccStatement)
		SET @Inc = 1
		SET @Bal = @Opng
		WHILE @Inc <= @Cnt
			BEGIN
				SET @Bal = (Select (@Bal+Debit)-Credit as Balance from TempRtrAccStatement Where Id = @Inc)
				UPDATE TempRtrAccStatement SET Balance = @Bal Where Id = @Inc
				SET @Inc = @Inc + 1
			END
		UPDATE TempRtrAccStatement SET CBalance = @Bal
		INSERT  INTO  #RptRtrAccStatement SELECT * FROM TempRtrAccStatement
		DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptRtrAccStatement
		SELECT * FROM #RptRtrAccStatement
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-025

--if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSalesRegister]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
--drop procedure [dbo].[Proc_RptSalesRegister]
--GO
--
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER OFF
--GO
--
------ Exec Proc_RptSalesRegister 227,1,0,'yg',0,0,1
--CREATE Procedure [dbo].[Proc_RptSalesRegister]
--(
--	@Pi_RptId			INT,
--	@Pi_UsrId			INT,
--	@Pi_SnapId			INT, 
--	@Pi_DbName			Nvarchar(50),
--	@Pi_SnapRequired	INT,
--	@Pi_GetFromSnap		INT,
--	@Pi_CurrencyId		INT
--)
--As
--/***************************************************************************************************
--* PROCEDURE	: Proc_RptSalesRegister
--* PURPOSE	: Sales,SR and Replacement  transaction details
--* CREATED	: Panneer
--* CREATED DATE	: 07.04.2011
--* NOTE		: General SP For Generate Product transaction details
--* MODIFIED
--* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------------------
--* {date}		{developer}		{brief modification description}
--***************************************************************************************************/
--Begin
--SET Nocount On
--		DECLARE @FromDate			AS  DATETIME
--		DECLARE @ToDate				AS  DATETIME
--		DECLARE @RtrId              AS  INT
--		
--		SET @FromDate	= (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
--		SET @ToDate		= (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
--		SET @RtrId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
--		/*  CREATE TABLE STRUCTURE */
--		DECLARE @NewSnapId 		AS	INT
--		DECLARE @DBNAME			AS 	nvarchar(50)
--		DECLARE @TblName 		AS	nvarchar(500)
--		DECLARE @TblStruct 		AS	nVarchar(4000)
--		DECLARE @TblFields 		AS	nVarchar(4000)
--		DECLARE @SSQL			AS 	VarChar(8000)
--		DECLARE @ErrNo	 		AS	INT
--		DECLARE @PurDBName		AS	nVarChar(50)
--		/*  Till Here  */
--	SET @TblName = 'RptSalesRegisterReport'
--	
--	SET @TblStruct ='	SalInvNo	nVarchar(100),
--						[Type]		nVarchar(100),
--						Date		DateTime,
--						RtrCode     nVarchar(100),
--						RtrName     nVarchar(100),
--						TinNo       nVarchar(100),
--						Categoty    nVarchar(100),
--						Brand		nVarchar(100),
--						PrdId Int,
--						PrdDCode nVarchar(100),
--						PrdName  nVarchar(100),
--						BaseQty  INT,
--						PrdUnitSelRate Numeric(38,6),
--						TaxAmt      Numeric(38,6),
--						DiscAmt     Numeric(38,6),
--						PrdNetAmount Numeric(38,6),
--						TotalAmt Numeric(38,6),
--						Mode nVarchar(100) '						
--										
--	SET @TblFields =	'SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode'
--	CREATE TABLE #RptSalesRegisterReport(	SalInvNo	nVarchar(100),[Type] nVarchar(100),	Date DateTime,
--						RtrCode     nVarchar(100),	RtrName     nVarchar(100),	TinNo       nVarchar(100),
--						Categoty    nVarchar(100),	Brand		nVarchar(100),	PrdId Int,
--						PrdDCode nVarchar(100),		PrdName  nVarchar(100),		BaseQty  INT,
--						PrdUnitSelRate Numeric(38,6),	TaxAmt      Numeric(38,6),  DiscAmt     Numeric(38,6),
--						PrdNetAmount Numeric(38,6),	TotalAmt Numeric(38,6),		Mode nVarchar(100))
--	Exec  Proc_GetProductwiseHierarchy
--			/* Purge DB */
--	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--			/*  Snap Shot Query    */
--	IF @Pi_GetFromSnap = 1
--	BEGIN
--		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
--		SET @DBNAME = @DBNAME
--	END
--	ELSE
--	BEGIN
--		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
--		SET @DBNAME = @PI_DBNAME + @DBNAME
--	END
--	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
--	BEGIN
--		Delete From #RptSalesRegisterReport
--		Insert Into #RptSalesRegisterReport(SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode)
--		---  Sales
--		Select  SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,Sum(BaseQty) BaseQty,PrdUnitSelRate,
--				SUm(PrdTaxAmount) TaxAmt,Sum(DiscAmt) DiscAmt,Sum(PrdNetAmount) PrdNetAmount,
--				Sum(TotalAmt) TotalAmt, Mode
--		FROM (
--				Select 
--						SalInvNo,'Billing' [Type],SalinvDate Date,RtrCode,RtrName,Isnull(RtrTINNo,'') TinNo,
--						Category AS Category,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,Sum(BaseQty) BaseQty,
--						PrdUnitSelRate,Sum(PrdTaxAmount) PrdTaxAmount,
--						Sum(PrdSplDiscAmount+PrdSchDiscAmount+PrdDBDiscAmount+PrdCDAmount) DiscAmt,
--						Sum(PrdNetAmount) PrdNetAmount,SalNetAmt TotalAmt,
--						Case BillMode WHen 1  Then 'Cash' 
--									  WHen 2  Then 'Credit' End As Mode
--				From 
--						Salesinvoice A (nolock) ,Retailer B (nolock),SalesInvoiceProduct C (nolock),
--						ProductWiseHierarchy D (nolock),Product P (nolock)				
--				Where 
--						A.RtrId  = B.RtrId		AND A.SalId = C.SalId
--						AND C.PrdId =  D.ProductId  AND C.PrdId = P.PrdId 
--						AND Dlvsts in (4,5)     AND P.PrdId = D.ProductId  
--						AND SalInvDate Between @FromDate  and @ToDate 
--					    AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
--							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
--				Group By 
--						SalInvNo,RtrCode,RtrName,SalinvDate,RtrCode,RtrName,RtrTINNo,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,PrdUnitSelRate,SalNetAmt,Category,BillMode )  A
--		Group By 
--				SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,PrdUnitSelRate,Mode,Category
--		
--		---  SalesReturn
--		Insert Into #RptSalesRegisterReport(SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode)
--		Select  ReturnCode,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,Sum(BaseQty) BaseQty,PrdUnitSelRte,
--				SUm(PrdTaxAmount) TaxAmt,Sum(DiscAmt),Sum(PrdNetAmount) PrdNetAmount,
--				Sum(TotalAmt) TotalAmt, Mode
--		FROM (
--				Select 
--						ReturnCode,'SRN' [Type],ReturnDate Date,RtrCode,RtrName,Isnull(RtrTINNo,'') TinNo,
--						Category AS Category,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,Sum(BaseQty) BaseQty,
--						PrdUnitSelRte,Sum(PrdTaxAmt) PrdTaxAmount,
--						Sum(PrdSplDisAmt+PrdSchDisAmt+PrdDBDisAmt+PrdCDDisAmt) DiscAmt,
--						Sum(PrdNetAmt) PrdNetAmount,RtnNetAmt TotalAmt,'Debit' Mode
--				From 
--						ReturnHeader A (nolock) ,Retailer B (nolock),ReturnProduct C (nolock),
--						ProductWiseHierarchy D (nolock),Product P (nolock)				
--				Where 
--						A.RtrId  = B.RtrId		AND A.ReturnId = C.ReturnId
--						AND C.PrdId =  D.ProductId  AND C.PrdId = P.PrdId 
--						AND P.PrdId = D.ProductId  
--						AND ReturnDate Between @FromDate  and @ToDate 
--					    AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
--							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
--				Group By 
--						ReturnCode,RtrCode,RtrName,ReturnDate,RtrCode,RtrName,RtrTINNo,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,PrdUnitSelRte,RtnNetAmt,Category )  A
--		Group By 
--				ReturnCode,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,PrdUnitSelRte,Mode,Category
--		---  Replacement IN
--		Insert Into #RptSalesRegisterReport(SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode)
--		Select  RepRefNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,Sum(BaseQty) BaseQty,SelRte,
--				SUm(PrdTaxAmount) TaxAmt,Sum(DiscAmt),Sum(PrdNetAmount) PrdNetAmount,
--				Sum(TotalAmt) TotalAmt, Mode
--		FROM (
--				Select 
--						A.RepRefNo,'Exchange' [Type],RepDate Date,RtrCode,RtrName,Isnull(RtrTINNo,'') TinNo,
--						Category AS Category,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,Sum(RtnQty) BaseQty,
--						SelRte,Sum(Tax) PrdTaxAmount,
--						0 DiscAmt,
--						Sum(RtnAmount) PrdNetAmount,0 TotalAmt,'Debit' Mode
--				From 
--						ReplacementHd A (nolock) ,Retailer B (nolock),ReplacementIn C (nolock),
--						ProductWiseHierarchy D (nolock),Product P (nolock)				
--				Where 
--						A.RtrId  = B.RtrId		AND A.RepRefNo = C.RepRefNo
--						AND C.PrdId =  D.ProductId  AND C.PrdId = P.PrdId 
--						AND P.PrdId = D.ProductId  
--						AND RepDate Between @FromDate  and @ToDate  
--						AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
--							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
--				Group By 
--						A.RepRefNo,RtrCode,RtrName,RepDate,RtrCode,RtrName,RtrTINNo,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,SelRte,Category )  A
--		Group By 
--				RepRefNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,SelRte,Mode,Category
--			
--		---  Replacement out
--		Insert Into #RptSalesRegisterReport(SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode)
--		Select  RepRefNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,Sum(BaseQty) BaseQty,SelRte,
--				SUm(PrdTaxAmount) TaxAmt,Sum(DiscAmt),Sum(PrdNetAmount) PrdNetAmount,
--				Sum(TotalAmt) TotalAmt, Mode
--		FROM (
--				Select 
--						A.RepRefNo,'Exchange' [Type],RepDate Date,RtrCode,RtrName,Isnull(RtrTINNo,'') TinNo,
--						Category AS Category,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,Sum(RepQty) BaseQty,
--						SelRte,Sum(Tax) PrdTaxAmount,
--						0 DiscAmt,
--						Sum(RepAmount) PrdNetAmount,0 TotalAmt,'Credit' Mode
--				From 
--						ReplacementHd A (nolock) ,Retailer B (nolock),ReplacementOut C (nolock),
--						ProductWiseHierarchy D (nolock),Product P (nolock)				
--				Where 
--						A.RtrId  = B.RtrId		AND A.RepRefNo = C.RepRefNo
--						AND C.PrdId =  D.ProductId  AND C.PrdId = P.PrdId 
--						AND P.PrdId = D.ProductId  
--						AND RepDate Between @FromDate  and @ToDate 
--						AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
--							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
--				Group By 
--						A.RepRefNo,RtrCode,RtrName,RepDate,RtrCode,RtrName,RtrTINNo,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,SelRte,Category )  A
--		Group By 
--				RepRefNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,SelRte,Mode,Category
--		/* New Snap Shot Data Stored*/
--		IF @Pi_SnapRequired = 1
--		BEGIN
--			SELECT @NewSnapId = @Pi_SnapId
--			
--			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
--				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
--			
--			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
--				'(SnapId,UserId,RptId,' + @TblFields + ')' +
--				' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
--				' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
--				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ',* FROM #RptSalesRegisterReport'		
--			EXEC (@SSQL)
--			PRINT 'Saved Data Into SnapShot Table'
--		END
--	END
--	ELSE				
--	BEGIN
--		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
--								  @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
--			IF @ErrNo = 0
--			BEGIN
--				SET @SSQL = 'INSERT INTO #RptSalesRegisterReport ' +
--					'(' + @TblFields + ')' +
--					' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
--					' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
--					' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
--					' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))	
--					EXEC (@SSQL)
--					PRINT 'Retrived Data From Snap Shot Table'
--					SELECT * FROM #RptSalesRegisterReport
--			END
--			ELSE
--			BEGIN
--				PRINT 'DataBase or Table not Found'
--				RETURN
--			END
--	END
--		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
--		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
--		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptSalesRegisterReport
--	Create table #RptSalReg(RefNo nvarchar(50),Mode nvarchar(50),PrdAmt numeric(18,6))
--	Insert Into #RptSalReg
--	Select  SalInvNo RefNo ,Mode,Sum(PrdNetAmount) PrdAmt  
--	From #RptSalesRegisterReport Where [Type] = 'Exchange'
--	Group by SalInvNo,Mode
--	Update #RptSalesRegisterReport Set TotalAmt = PrdAmt
--	From #RptSalesRegisterReport a,#RptSalReg b
--	Where salinvno = RefNo and A.mode = b.mode  AND [Type] = 'Exchange'
--	Select * from #RptSalesRegisterReport
--End
--
--GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-240-026

DELETE FROM CustomCaptions WHERE TransId=23 AND CtrlId=2000 AND SubCtrlId IN (37,38)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('23','2000','37','HotSch-23-2000-37','Selling Rate','','','1','1','1',CONVERT(datetime,'2010-12-16 16:38:05.140',121),'1',CONVERT(datetime,'2010-12-16 16:38:05.140',121),'Selling Rate','','','1','1')

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('23','2000','38','HotSch-23-2000-38','Purchase Rate','','','1','1','1',CONVERT(datetime,'2010-12-16 16:38:05.157',121),'1',CONVERT(datetime,'2010-12-16 16:38:05.157',121),'Purchase Rate','','','1','1')

DELETE FROM CustomCaptions WHERE TransId=24 AND CtrlId=2000 AND SubCtrlId IN (40)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('24','2000','40','HotSch-24-2000-40','Retailer','','','1','1','1',CONVERT(datetime,'2011-02-07 00:00:00.000',121),'1',CONVERT(datetime,'2011-02-07 00:00:00.000',121),'Retailer','','','1','1')

DELETE FROM CustomCaptions WHERE TransId=26 AND CtrlId=2000 AND SubCtrlId IN (39)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('26','2000','39','HotSch-26-2000-39','PO Type','','','1','1','1',CONVERT(datetime,'2010-04-21 12:21:38.990',121),'1',CONVERT(datetime,'2010-04-21 12:21:38.990',121),'PO Type','','','1','1')

--SRF-Nanda-251-001

DELETE FROM BillTemplateHD WHERE PrintType=8
INSERT INTO BillTemplateHD (TempName,BillSeqId,BillSeqDt,MarketRet,Replacement,OtherCharges,CrDbAdj,TaxDt,LineNumber,UsrId,Scheme,PrintType,SampleIssue)
VALUES ('Return and Replacement Bill Template',1,getdate(),0,0,0,0,0,15,1,0,8,0)
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[RptReplacementToPrint]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptReplacementToPrint]
GO

CREATE TABLE [RptReplacementToPrint]
(
	[RepRefNo] [nvarchar](100)  NULL,
	[RtrId] [int] NULL,
	[UsrId] [int] NULL
) 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[RptReplacementBillprint]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptReplacementBillprint]
GO

CREATE TABLE [RptReplacementBillprint]
(
	DistributorCode nvarchar(100),
	DistributorName nvarchar(200),
	DistributorAdd1 nvarchar(100),
	DistributorAdd2 nvarchar(100),
	DistributorAdd3 nvarchar(100),
	[Distributor TINNo] nvarchar(100),
	[Distributor DepositAmt] numeric(18,2),
	[Distributor CSTNo] nvarchar(100),
	[Distributor LSTNo] nvarchar(100),
	[Distributor LicNo] nvarchar(100),
	[Distributor DrugLicNo1]nvarchar(100),
	[Distributor DrugLicNo2] nvarchar(100),
	[Distributor PestLicNo] nvarchar(100),
	[Replacement Number] nvarchar(100),
	StockType nvarchar(100),
	[Replacement Date] datetime,
	DocRefNo nvarchar(100),
	RtrId int,
	[Retailer Name] nvarchar(200),
	[Retailer Code] nvarchar(100),
	[Retailer Address1] nvarchar(100),
	[Retailer PinNo] nvarchar(100),
	[Retailer PhoneNo] nvarchar(100),
	[Reatiler TinNo] nvarchar(100),
	[Retailer CSTNo] nvarchar(100),
	[Retailer LicNo] nvarchar(100),
	[Retailer DrugLicNo] nvarchar(100),
	[Retailer PestLicNo] nvarchar(100),
	PrdId int ,
	[Product Name] nvarchar(200),
	[Product ShrtName] nvarchar(200),
	[Product DistCode] nvarchar(200),
	[Product CompanyCode] nvarchar(200),
	UserStockType nvarchar(100),
	Qty int ,
	[Selling Rate] numeric(18,2),
	MRP numeric(18,2),
	Amount numeric(18,2),
	TotalTaxAmount  numeric(18,2),
	ReturnAmountInWord nvarchar(2500),
	ReplacementAmountInWord nvarchar(2500),
	TotalReturnAmount numeric(18,2),
	TotalReplacementAmount numeric(18,2)
)
GO

--Exec Proc_RetnReplacementBillPrint 16,1,0,'henkel',0,0,1,''
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RetnReplacementBillPrint]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RetnReplacementBillPrint]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Proc_RetnReplacementBillPrint
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

BEGIN 
	DELETE FROM RptReplacementBillprint
	INSERT INTO RptReplacementBillprint(DistributorCode,DistributorName,DistributorAdd1,DistributorAdd2,DistributorAdd3,
	[Distributor TINNo],[Distributor DepositAmt],[Distributor CSTNo],[Distributor LSTNo],[Distributor LicNo],[Distributor DrugLicNo1],
	[Distributor DrugLicNo2],[Distributor PestLicNo],[Replacement Number],[StockType],[Replacement Date],DocRefNo,RtrId,[Retailer Name],
	[Retailer Code],[Retailer Address1],[Retailer PinNo],[Retailer PhoneNo],[Reatiler TinNo],[Retailer CSTNo],[Retailer LicNo],
	[Retailer DrugLicNo],[Retailer PestLicNo],PrdId,[Product Name],[Product ShrtName],[Product DistCode],[Product CompanyCode],
	UserStockType,Qty,[Selling Rate],MRP,Amount,TotalTaxAmount)

	SELECT DistributorCode,DistributorName,DistributorAdd1,DistributorAdd2,DistributorAdd3,
		   TINNo,DepositAmt,CSTNo,LSTNo,LicNo,DrugLicNo1,DrugLicNo2,PestLicNo,
		   RepRefNo,StockType,RepDate,DocRefNo,RtrId,RtrName,RtrCode,RtrAdd1,RtrPinNo,RtrPhoneNo,RtrTINNo,RtrCSTNo,RtrLicNo,RtrDrugLicNo,
		   RtrPestLicNo,PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,UserStockType,sum(repQty)repQty,SelRte,MRP,
		   sum(Amount)Amount,sum(TaxAmount)TaxAmount
	FROM (
	SELECT DistributorCode,DistributorName,DistributorAdd1,DistributorAdd2,DistributorAdd3,
		   TINNo,DepositAmt,CSTNo,LSTNo,LicNo,DrugLicNo1,DrugLicNo2,PestLicNo,
		   RH.RepRefNo,'Return' AS StockType,RH.RepDate,RH.DocRefNo,RH.RtrId,RtrName,RtrCode,RtrAdd1,RtrPinNo,RtrPhoneNo,R.RtrTINNo,r.RtrCSTNo,r.RtrLicNo,r.RtrDrugLicNo,
		   R.RtrPestLicNo,RI.PrdId,p.PrdName,p.PrdShrtName,p.PrdDCode,p.PrdCCode,ST.UserStockType,(RtnQty) AS repQty,SelRte,pbd.PrdBatDetailValue MRP,
		   dbo.Fn_ConvertCurrency(RI.RtnAmount,@Pi_CurrencyId) AS Amount,sum(RT.TaxAmount)TaxAmount
	FROM 
		ReplacementHd RH 
		INNER JOIN Retailer R ON RH.RtrId=R.RtrId 
		INNER JOIN ReplacementIn RI ON RI.RepRefNo=RH.RepRefNo 
		INNER JOIN Product P ON P.PrdId=RI.PrdId 
		INNER JOIN ProductBatch PB ON PB.PrdId = P.PrdId AND PB.PrdId=RI.PrdId AND PB.PrdBatId=RI.PrdBatId
		INNER JOIN ReplacementInPrdTax RT ON RT.RepRefNo=RH.RepRefNo AND RT.RepRefNo=RI.RepRefNo AND RT.RowId=RI.RowId
		INNER JOIN StockType ST ON ST.StockTypeId=RI.StockTypeId 
		INNER JOIN ProductBatchDetails PBD ON PBD.PriceId=PB.DefaultPriceId AND PBD.PrdBatId=PB.PrdBatId
		INNER JOIN RptReplacementToPrint RTP ON RTP.RepRefNo=RI.RepRefNo AND RTP.RepRefNo=RH.RepRefNo AND RTP.rtrid=RH.rtrid
				   AND RTP.RTRid=R.rtrid
		CROSS JOIN  Distributor 
	WHERE 
		 PBD.SLNo=1 
	GROUP BY DistributorCode,DistributorName,DistributorAdd1,DistributorAdd2,DistributorAdd3,
		   TINNo,DepositAmt,CSTNo,LSTNo,LicNo,DrugLicNo1,DrugLicNo2,PestLicNo,
		   RH.RepRefNo,RH.RepDate,RH.DocRefNo,RH.RtrId,RtrName,RtrCode,RtrAdd1,RtrPinNo,RtrPhoneNo,R.RtrTINNo,r.RtrCSTNo,r.RtrLicNo,r.RtrDrugLicNo,
		   R.RtrPestLicNo,RI.PrdId,p.PrdName,p.PrdShrtName,p.PrdDCode,p.PrdCCode,ST.UserStockType,SelRte,pbd.PrdBatDetailValue,RtnQty,RI.RtnAmount  
	UNION ALL
	SELECT DistributorCode,DistributorName,DistributorAdd1,DistributorAdd2,DistributorAdd3,
		   TINNo,DepositAmt,CSTNo,LSTNo,LicNo,DrugLicNo1,DrugLicNo2,PestLicNo,
		   RH.RepRefNo,'Replacement' AS StockType,RH.RepDate,RH.DocRefNo,RH.RtrId,RtrName,RtrCode,RtrAdd1,RtrPinNo,RtrPhoneNo,R.RtrTINNo,r.RtrCSTNo,r.RtrLicNo,r.RtrDrugLicNo,
		   r.RtrPestLicNo,RI.PrdId,p.PrdName,p.PrdShrtName,p.PrdDCode,p.PrdCCode,ST.UserStockType,(RepQty) AS repQty,SelRte,pbd.PrdBatDetailValue MRP,
		   dbo.Fn_ConvertCurrency(RI.RepAmount,@Pi_CurrencyId) AS Amount,sum(RT.TaxAmount)TaxAmount
	FROM 
		ReplacementHd RH 
		INNER JOIN Retailer R ON RH.RtrId=R.RtrId 
		INNER JOIN ReplacementOut RI ON RI.RepRefNo=RH.RepRefNo 
		INNER JOIN Product P ON P.PrdId=RI.PrdId 
		INNER JOIN ProductBatch PB ON PB.PrdId = P.PrdId AND PB.PrdId=RI.PrdId AND PB.PrdBatId=RI.PrdBatId
		INNER JOIN ReplacementOutPrdTax RT ON RT.RepRefNo=RH.RepRefNo AND RT.RepRefNo=RI.RepRefNo AND RT.RowId=RI.RowId
		INNER JOIN StockType ST ON ST.StockTypeId=RI.StockTypeId  
		INNER JOIN ProductBatchDetails PBD ON PBD.PriceId=PB.DefaultPriceId AND PBD.PrdBatId=PB.PrdBatId
		INNER JOIN RptReplacementToPrint RTP ON RTP.RepRefNo=RI.RepRefNo AND RTP.RepRefNo=RH.RepRefNo AND RTP.rtrid=RH.rtrid
				   AND RTP.RTRid=R.rtrid
		CROSS JOIN  Distributor 
	WHERE 
		PBD.SLNo=1  
	GROUP BY 
		   DistributorCode,DistributorName,DistributorAdd1,DistributorAdd2,DistributorAdd3,
		   TINNo,DepositAmt,CSTNo,LSTNo,LicNo,DrugLicNo1,DrugLicNo2,PestLicNo,
		   RH.RepRefNo,RH.RepDate,RH.DocRefNo,RH.RtrId,RtrName,RtrCode,RtrAdd1,RtrPinNo,RtrPhoneNo,R.RtrTINNo,r.RtrCSTNo,r.RtrLicNo,r.RtrDrugLicNo,
		   r.RtrPestLicNo,RI.PrdId,p.PrdName,p.PrdShrtName,p.PrdDCode,p.PrdCCode,ST.UserStockType,SelRte,pbd.PrdBatDetailValue,RepQty,RI.RepAmount 

	)A 
	GROUP BY DistributorCode,DistributorName,DistributorAdd1,DistributorAdd2,DistributorAdd3,
			 TINNo,DepositAmt,CSTNo,LSTNo,LicNo,DrugLicNo1,DrugLicNo2,PestLicNo,
			 RepRefNo,StockType,RepDate,DocRefNo,RtrId,RtrName,RtrCode,RtrAdd1,RtrPinNo,RtrPhoneNo,RtrTINNo,RtrCSTNo,RtrLicNo,RtrDrugLicNo,
			 RtrPestLicNo,PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,UserStockType,SelRte,MRP
	ORDER BY RepRefNo,stocktype

	SELECT sum(Amount)Amount,StockType,[Replacement Number] INTO #TempAmount FROM RptReplacementBillprint 
	GROUP BY StockType,[Replacement Number]

	UPDATE R SET TotalReturnAmount=T.Amount FROM RptReplacementBillprint R,#TempAmount T
	WHERE T.StockType='Return' AND R.[Replacement Number]=T.[Replacement Number]

	UPDATE R SET TotalReplacementAmount=T.Amount FROM RptReplacementBillprint R,#TempAmount T
	WHERE T.StockType='Replacement' AND R.[Replacement Number]=T.[Replacement Number]

END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-251-002

if not exists (select * from dbo.sysobjects where id = object_id(N'[XmlDataExtract]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[XmlDataExtract]
	(
		[SlNo] [int] NULL,
		[ExtractFileName] [nvarchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SPName] [nvarchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TblName] [nvarchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TransType] [nvarchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FileName] [nvarchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ExecuteSP] [int] NULL
	) ON [PRIMARY]
end
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_VehicleMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_VehicleMaster]
GO

CREATE TABLE [dbo].[ETL_XML_VehicleMaster]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VehicleCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Registration No] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VehicleCategory] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Capacity] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_VanLoadUnload]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_VanLoadUnload]
GO

CREATE TABLE [dbo].[ETL_XML_VanLoadUnload]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VanLoadUnLoadNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Price] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VanLoadUnLoadMode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FromWhseCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FromWhseName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ToWhseCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ToWhseName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SchemeSlab]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SchemeSlab]
GO

CREATE TABLE [dbo].[ETL_XML_SchemeSlab]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Company Scheme Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SlabId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[From Uom] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[From Qty] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[To Uom] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[To Qty] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[For Every Uom] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[For Every Qty] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Disc %] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flat Amount] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Point] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flexi Free] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flexi Gift] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flexi Disc] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flexi Flat] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flexi Points] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Max Discount] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Min Discount] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Max Value] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Min Value] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Max Points] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Min Points] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SchemeProduct]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SchemeProduct]
GO

CREATE TABLE [dbo].[ETL_XML_SchemeProduct]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Company_Scheme_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Type] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Batch_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SchemeMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SchemeMaster]
GO

CREATE TABLE [dbo].[ETL_XML_SchemeMaster]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Company_Scheme_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Scheme_Description] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Company_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Claimable] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Claim_Amount_On] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Claim_Group_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Selection_On] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Selection_Level_Value] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Scheme_Type] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Batch_Level] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flexi_Scheme] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Flexi_Conditional] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Combi_Scheme] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Range] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Pro_Rata] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QPS] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qps_Reset] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qps_Based_On] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Allow_For_Every] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Adjust_Display_Once] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Settle_Display_Through] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Allow_Editing_Scheme] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Scheme_Budget] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Scheme_Start_Date] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Scheme_End_Date] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SchemeFreePrdDt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SchemeFreePrdDt]
GO

CREATE TABLE [dbo].[ETL_XML_SchemeFreePrdDt]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Company Scheme Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SlabId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Condition] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qty] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Type] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SchemeCombiPrdDt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SchemeCombiPrdDt]
GO

CREATE TABLE [dbo].[ETL_XML_SchemeCombiPrdDt]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Company Scheme Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SlabId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SlabValue] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BatchCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Selection_Level_Value] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SchemeAttributes]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SchemeAttributes]
GO

CREATE TABLE [dbo].[ETL_XML_SchemeAttributes]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Company_Scheme_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Attribute Type] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Attribute Master Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_Salvage]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_Salvage]
GO

CREATE TABLE [dbo].[ETL_XML_Salvage]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockyDocNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Comments] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StockTransType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockManagementType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SalesReturnScheme]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SalesReturnScheme]
GO

CREATE TABLE [dbo].[ETL_XML_SalesReturnScheme]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalRetNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalInvRefNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Company_Scheme_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemeDisAmount] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemeSlabID] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SalesReturn]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SalesReturn]
GO

CREATE TABLE [dbo].[ETL_XML_SalesReturn]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalRetNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalInvRefNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TaxCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UnitPrice] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchNumber] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Salesman] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrderBeat] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RdyStk] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreditNoteNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalDlvDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DeliveryBeat] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrdBatCde] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrimaryDiscount] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SecondaryDiscount] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalSchAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalDisAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalRetAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalVisAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalDistDis] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalTotDedn] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalRoundOffAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[dbadjamt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[cradjamt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OnAccountAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalReplaceAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalSplDis] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalInvSch] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalInvDist] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalCshDis] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SalesPaymentCancellation]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SalesPaymentCancellation]
GO

CREATE TABLE [dbo].[ETL_XML_SalesPaymentCancellation]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PaymentReceiptNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PaymentReceiptDate] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvoiceNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PaymentMode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PaidSum] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Penalty] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DebitNoteNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SalesPayment]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SalesPayment]
GO

CREATE TABLE [dbo].[ETL_XML_SalesPayment]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocDate] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Cardname] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Receipt No] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BillNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvdate] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PaymentMode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PaidSum] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Debit/Credit No] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Debit/Credit Date] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Debit/Credit Amount] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ChequeNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Cheque Date] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BankName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BankBranch] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Sales Man] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Collected By] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Route] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SalesManMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SalesManMaster]
GO

CREATE TABLE [dbo].[ETL_XML_SalesManMaster]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesmanCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesmanName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RouteCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SalesInvoiceScheme]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SalesInvoiceScheme]
GO

CREATE TABLE [dbo].[ETL_XML_SalesInvoiceScheme]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalInvNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Company_Scheme_Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemeDisAmount] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemeSlabID] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_SalesInvoice]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_SalesInvoice]
GO

CREATE TABLE [dbo].[ETL_XML_SalesInvoice]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalInvNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TaxCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UnitPrice] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Salesman] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrderBeat] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RdyStk] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BillMode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VechName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalDlvDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Location] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrdBatCde] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrimaryDiscount] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SecondaryDiscount] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalSchAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalDisAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalRetAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalVisAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalDistDis] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalTotDedn] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalRoundOffAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dbadjamt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cradjamt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OnAccountAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalReplaceAmt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalSplDis] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvSch] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvDist] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalCshDis] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UPloadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_RouteMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_RouteMaster]
GO

CREATE TABLE [dbo].[ETL_XML_RouteMaster]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RouteCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RouteName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Distance] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Population] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevel] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevelValue] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VanRoute] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RouteType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LocalUpCountry] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Monday] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Tuesday] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Wednesday] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Thursday] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Friday] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Saturday] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Sunday] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_PurchaseReturn]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_PurchaseReturn]
GO

CREATE TABLE [dbo].[ETL_XML_PurchaseReturn]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PurchaseReturnNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GRNNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DiscountPercent] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TaxCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UnitPrice] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DebitNoteNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_PurchaseReceipt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_PurchaseReceipt]
GO

CREATE TABLE [dbo].[ETL_XML_PurchaseReceipt]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CompanyInvoiceNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CompanyInvoiceDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GRNNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TransporterCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DiscountPercent] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TaxCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UnitPrice] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExpiryDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ManufacturerSerialNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ManufacturingDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProductCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PriceCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TaxGroupCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchSequenceCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MRPPrice] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LSPPrice] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrimaryDisc] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SellingRate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimRate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_ItemMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_ItemMaster]
GO

CREATE TABLE [dbo].[ETL_XML_ItemMaster]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ItemName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ForeignName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ItemsGroupCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MinInventory] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Manufacturer] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Stock Cover Days] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Tax Group Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[No of Pieces per Case] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[No of Pieces per Strip] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[No of Pieces per Mono carton] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Company Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Hierarchy level Value Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Hierarchy level Value Name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Weight] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Shelf Life] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BrandCategoryCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BrandCategoryName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_GoodsReceipt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_GoodsReceipt]
GO

CREATE TABLE [dbo].[ETL_XML_GoodsReceipt]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Price] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[WarehouseCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockyDocNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Batch] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Comments] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StockTransType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockManagementType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExpiryDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ManufacturerSerialNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ManufacturingDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProductCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PriceCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TaxGroupCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchSequenceCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MRPPrice] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LSPPrice] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrimaryDisc] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SellingRate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ClaimRate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_GoodsIssue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_GoodsIssue]
GO

CREATE TABLE [dbo].[ETL_XML_GoodsIssue]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Price] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockyDocNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Comments] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StockTransType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockManagementType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StockType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_DebitNotePurchase]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_DebitNotePurchase]
GO

CREATE TABLE [dbo].[ETL_XML_DebitNotePurchase]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DebitNoteNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AccountCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AccountName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LineTotal] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TransId] [int] NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_DebitNote_Sales]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_DebitNote_Sales]
GO

CREATE TABLE [dbo].[ETL_XML_DebitNote_Sales]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocDate] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AccountCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AccountName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DebitNoteNum] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LineTotal] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_Customer]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_Customer]
GO

CREATE TABLE [dbo].[ETL_XML_Customer]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GroupCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ClassCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RtrCde] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RtrTINNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_CreditNotePurchase]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_CreditNotePurchase]
GO

CREATE TABLE [dbo].[ETL_XML_CreditNotePurchase]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreditNoteNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AccountCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AccountName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LineTotal] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TransId] [int] NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_CreditNote_Sales]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_CreditNote_Sales]
GO

CREATE TABLE [dbo].[ETL_XML_CreditNote_Sales]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CardCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocDate] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AccountCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AccountName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreditNoteNum] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LineTotal] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransId] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_ClaimGrpMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_ClaimGrpMaster]
GO

CREATE TABLE [dbo].[ETL_XML_ClaimGrpMaster]
(
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Company] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimGroupCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimGroupName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AutoClaim] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_XML_BatchCloning]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_XML_BatchCloning]
GO

CREATE TABLE [dbo].[ETL_XML_BatchCloning]
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[ItemCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExpiryDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ManufacturerSerialNumber] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ManufacturingDate] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProductCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PriceCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TaxGroupCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchSequenceCode] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MRPPrice] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LSPPrice] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrimaryDisc] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SellingRate] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ClaimRate] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DefaultPriceId] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO

--SRF-Nanda-251-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ETL_Prk_Product]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ETL_Prk_Product]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_LRProduct]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_LRProduct]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_NESProductBatch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_NESProductBatch]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2CS_NSPriceApproval]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2CS_NSPriceApproval]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_Prk_RetailerCategory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_Prk_RetailerCategory]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ClaimGroupForNestle]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ClaimGroupForNestle]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ClaimGroupForNivea]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ClaimGroupForNivea]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SMProduct]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SMProduct]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_CS2CN_NS_PriceApproved]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_CS2CN_NS_PriceApproved]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportLRProduct]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportLRProduct]
GO

--SRF-Nanda-251-004

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='ClaimGroupMaster'))
begin
	ALTER TABLE [dbo].[ClaimGroupMaster]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'InvRcpNo' and id in (Select id from 
	Sysobjects where name ='CRDBNoteAdjustment'))
begin
	ALTER TABLE [dbo].[CRDBNoteAdjustment]
	ADD [InvRcpNo] NVARCHAR(100) NOT NULL DEFAULT '' WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='CreditNoteRetailer'))
begin
	ALTER TABLE [dbo].[CreditNoteRetailer]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='CreditNoteSupplier'))
begin
	ALTER TABLE [dbo].[CreditNoteSupplier]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='DebitNoteRetailer'))
begin
	ALTER TABLE [dbo].[DebitNoteRetailer]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO


if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='DebitNoteSupplier'))
begin
	ALTER TABLE [dbo].[DebitNoteSupplier]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='Product'))
begin
	ALTER TABLE [dbo].[Product]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='ProductBatchDetails'))
begin
	ALTER TABLE [dbo].[ProductBatchDetails]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='PurchaseReceipt'))
begin
	ALTER TABLE [dbo].[PurchaseReceipt]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='PurchaseReturn'))
begin
	ALTER TABLE [dbo].[PurchaseReturn]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='Retailer'))
begin
	ALTER TABLE [dbo].[Retailer]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='ReturnHeader'))
begin
	ALTER TABLE [dbo].[ReturnHeader]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='RouteMaster'))
begin
	ALTER TABLE [dbo].[RouteMaster]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='SalesInvoice'))
begin
	ALTER TABLE [dbo].[SalesInvoice]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='Salesman'))
begin
	ALTER TABLE [dbo].[Salesman]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='Salvage'))
begin
	ALTER TABLE [dbo].[Salvage]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='SchemeMaster'))
begin
	ALTER TABLE [dbo].[SchemeMaster]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='StockManagement'))
begin
	ALTER TABLE [dbo].[StockManagement]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='VanLoadUnloadMaster'))
begin
	ALTER TABLE [dbo].[VanLoadUnloadMaster]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'XMLUpload' and id in (Select id from 
	Sysobjects where name ='Vehicle'))
begin
	ALTER TABLE [dbo].[Vehicle]
	ADD [XMLUpload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-251-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Validate_Product]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Validate_Product]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[Proc_Validate_Product]
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
	CONVERT(NVARCHAR(12),[Effective To Date],121),ISNULL([Shelf Life],0),ISNULL([Status],'Active'),ISNULL([EAN Code],''),ISNULL([Vending],'NO')
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
			IF @Status='Active' OR @Status='1'
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
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,PrdShelfLife=@ShelfLife,
					PrdStatus=@PrdStatus,EanCode=@EANCode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
				END
				ELSE
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-251-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateRetailerMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateRetailerMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
Exec Proc_ValidateRetailerMaster 0
SELECT * FROM Retailer
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE                           Procedure [dbo].[Proc_ValidateRetailerMaster]
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
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
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
	FOR SELECT ISNULL([Retailer Code],''),ISNULL([Retailer Name],''),ISNULL([Address1],''),
		ISNULL([Address2],''),ISNULL([Address3],''),
		ISNULL([Pin Code],'0'),
		ISNULL([Phone No],'0'),ISNULL(EmailId,''),ISNULL([Key Account],''),ISNULL([Coverage Mode],''),
		CAST([Registration Date] AS DATETIME) AS [Registration Date],ISNULL([Day Off],''),
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
	FROM ETL_Prk_Retailer
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


		IF  @Taction=1 AND @Po_ErrNo=0
		BEGIN	
			INSERT INTO Retailer(RtrId,RtrCode,CmpRtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrKeyAcc,RtrCovMode,
			RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,RtrCSTNo,TaxGroupId,RtrCrBills,RtrCrLimit,RtrCrDays,
			RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,
			RtrPestLicNo,RtrPestExpiryDate,GeoMainId,RMId,VillageId,RtrResPhone1,RtrOffPhone1,RtrDepositAmt,RtrAnniversary,RtrDOB,CoaId,RtrOnAcc,
			RtrShipId,RtrType,RtrFrequency,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert,Upload,Approved,XmlUpload,Availability,LastModBy,LastModDate,AuthId,AuthDate)
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
			'N',0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))


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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-251-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateRouteMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateRouteMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Proc_ValidateRouteMaster]
(
@Po_ErrNo int OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_ValidateRouteMaster
* PURPOSE: To Insert and Update records  from xml file in the Table Route Master
* CREATED: Gunasekaran.D. 17/09/2007
*********************************/
BEGIN
	DECLARE @hDoc INTEGER
	DECLARE @InsertCount INTEGER
	DECLARE @Taction Int
	DECLARE @StateId Int
	DECLARE @ErrDesc Varchar(1000)
	DECLARE @rno int
	DECLARE @Tabname Varchar(50)
	DECLARE @RMId int
	DECLARE @RMCode Varchar(50)
	DECLARE @RMName Varchar(100)
	DECLARE @CmpCode Varchar(50)
	DECLARE @CmpId Int
	DECLARE @Dis Varchar(20)
	DECLARE @Pop Varchar(20)
	DECLARE @GeoMainId int
	DECLARE @HierVal Varchar(100)
	DECLARE @VanRoute Varchar(5)
	DECLARE @RMTypeId int
	DECLARE @RMType Varchar(50)
	DECLARE @LclUpId int
	DECLARE @LclUp Varchar(50)
	DECLARE @RMMon Varchar(5)
	DECLARE @RMTue Varchar(5)
	DECLARE @RMWed Varchar(5)
	DECLARE @RMThu Varchar(5)
	DECLARE @RMFri Varchar(5)
	DECLARE @RMSat Varchar(5)
	DECLARE @RMSun Varchar(5)
	DECLARE @sStr nVarchar(4000)

	Set @Tabname = 'ETL_Prk_RouteMaster'
	SET @Po_ErrNo = 0
	DECLARE Cur_ImpRoute CURSOR
	FOR SELECT * FROM ETL_Prk_RouteMaster
	OPEN Cur_ImpRoute
	FETCH NEXT FROM Cur_ImpRoute INTO
	@RMCode,@RMName,@CmpCode,@Dis,@Pop,@HierVal,@VanRoute,@RMType,@LclUp,
	@RMMon,@RMTue,@RMWed,@RMThu,@RMFri,@RMSat,@RMSun
	Set @Rno = 0
	WHILE @@FETCH_STATUS=0
	BEGIN
		Set @Rno = @Rno + 1
		Set @Taction = 2 -- Insert
		
		-- Validate Mandatory field is empty or null string
		IF IsNull(@RMCode,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Route Master Code is empty'
			INSERT INTO Errorlog VALUES (1,@TabName,'RMCode',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END	
		ELSE IF exists (SELECT *  FROM RouteMaster WHERE RMCode = @RMCode) and IsNull(@RMCode,'') <> ''
		BEGIN
			SET @Taction = 1
			--SELECT '5'
		END
		-- Route Master Name
		IF IsNull(@RMName,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Route Master Name is empty'
			INSERT INTO Errorlog VALUES (2,@TabName,'RMName',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END	
		-- Company
		IF IsNull(@CmpCode,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Company Code is empty'
			INSERT INTO Errorlog VALUES (3,@TabName,'CmpCode',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END	
		ELSE IF NOT exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Company Code '+ @CmpCode + ' Not found '
			INSERT INTO Errorlog VALUES (4,@TabName,'CmpCode',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		ELSE IF exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
		BEGIN
			SELECT @CmpId = CmpId FROM Company WHERE CmpCode = @CmpCode
		END
		-- Distance
		IF IsNull(@Dis,'') = ''
		BEGIN
			SET @Dis = 0
		END
		ELSE IF ISNUMERIC(@Dis) = 0
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Distance is not a numeric value'
			INSERT INTO Errorlog VALUES (4,@TabName,'Distance',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Population
		IF IsNull(@Pop,'') = ''
		BEGIN
			SET @Pop = 0
		END
		ELSE IF ISNUMERIC(@Pop) = 0
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Population is not a numeric value'
			INSERT INTO Errorlog VALUES (5,@TabName,'Population',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Geo Value
		IF IsNull(@HierVal,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Geography value is empty'
			INSERT INTO Errorlog VALUES (6,@TabName,'GeoName',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END	
		ELSE IF NOT exists (SELECT * FROM Geography WHERE GeoName = @HierVal ) and IsNull(@HierVal,'') <> ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Geography Name '+ @HierVal + ' Not found '
			INSERT INTO Errorlog VALUES (7,@TabName,'GeoName',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		ELSE IF exists (SELECT * FROM Geography WHERE GeoName = @HierVal ) and IsNull(@HierVal,'') <> ''
		BEGIN
			SELECT @GeoMainId = GeoMainId FROM Geography WHERE GeoName = @HierVal
		END
		-- Van route
		IF IsNull(@VanRoute,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Van Route is empty'
			INSERT INTO Errorlog VALUES (8,@TabName,'VanRoute',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		ELSE IF ISNUMERIC(@VanRoute) = 0
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Van route is not a numeric value'
			INSERT INTO Errorlog VALUES (9,@TabName,'Van route',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Route Type
		IF IsNull(@RMType,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Route Type is empty'
			INSERT INTO Errorlog VALUES (10,@TabName,'Route Type',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		ELSE IF Upper(@RMType) = 'SALES ROUTE'
		BEGIN
			SET @RMTypeId = 1
		END
		ELSE IF Upper(@RMType) = 'DELIVERY ROUTE'
		BEGIN
			SET @RMTypeId = 2
		END
		ELSE IF Upper(@RMType) = 'MERCHANDISING ROUTE'
		BEGIN
			SET @RMTypeId = 3
		END
		ELSE
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Route is wrong'
			INSERT INTO Errorlog VALUES (12,@TabName,'Route',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Local / Upcountry
		IF IsNull(@LclUp,'') = ''
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Local/upcoutry is empty'
			INSERT INTO Errorlog VALUES (11,@TabName,'Local/Upcountry',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		ELSE IF Upper(@LclUp) = 'LOCAL'
		BEGIN
			SET @LclUpId = 1
		END
		ELSE IF Upper(@RMType) = 'UPCOUNTRY'
		BEGIN
			SET @LclUpId = 2
		END
		ELSE
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Local Upcountry is wrong'
			INSERT INTO Errorlog VALUES (12,@TabName,'Local/Upcoutnry',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Monday
		IF IsNull(@RMMon,'') = ''
		BEGIN
			SET @RMMon = 0
		END
		ELSE IF ISNUMERIC(@RMMon) = 0
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Call Days - Mon is not a numeric value'
			INSERT INTO Errorlog VALUES (12,@TabName,'RMMon',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Tuesday
		IF IsNull(@RMTue,'') = ''
		BEGIN
			SET @RMTue = 0
		END
		ELSE IF ISNUMERIC(@RMTue) = 0
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Call Days - Tue is not a numeric value'
			INSERT INTO Errorlog VALUES (13,@TabName,'RMTue',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Wednesday
		IF IsNull(@RMWed,'') = ''
		BEGIN
			SET @RMWed = 0
		END
		ELSE IF ISNUMERIC(@RMWed) = 0
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Call Days - Wed is not a numeric value'
			INSERT INTO Errorlog VALUES (14,@TabName,'RMWed',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Thursday
		IF IsNull(@RMThu,'') = ''
		BEGIN
			SET @RMThu = 0
		END
		ELSE IF ISNUMERIC(@RMThu) = 0
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Call Days - Thu is not a numeric value'
			INSERT INTO Errorlog VALUES (15,@TabName,'RMThu',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Friday
		IF IsNull(@RMFri,'') = ''
		BEGIN
			SET @RMFri = 0
		END
		ELSE IF ISNUMERIC(@RMFri) = 0
		BEGIN
			SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Call Days - Fri is not a numeric value'
			INSERT INTO Errorlog VALUES (61,@TabName,'RMFri',@ErrDesc)           	
			SET @Taction = 0
			SET @Po_ErrNo = 1
		END
		-- Saturday
		IF IsNull(@RMSat,'') = ''
		BEGIN
			SET @RMSat = 0
		END
ELSE IF ISNUMERIC(@RMSat) = 0
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Call Days - Sat is not a numeric value'
	  INSERT INTO Errorlog VALUES (17,@TabName,'RMSat',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
-- Sunday
	     IF IsNull(@RMSun,'') = ''
	     BEGIN
	          SET @RMSun = 0
END
ELSE IF ISNUMERIC(@RMSun) = 0
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Call Days - Sun is not a numeric value'
	  INSERT INTO Errorlog VALUES (18,@TabName,'RMSun',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
		
	     IF @Taction = 1
	     BEGIN
-- Dependancy check Company
	           EXEC Proc_DependencyCheck 'RouteMaster',@CmpId
		       IF (SELECT COUNT(*) FROM TempDepCheck) > 0
	           BEGIN
		            SET @ErrDesc = 'Transaction Exists ' + CAST(@CmpId AS VARCHAR(6))
		 	        INSERT INTO Errorlog VALUES (19,@TabName,'CmpId',@ErrDesc)
		 	        SET @Taction = 0
		 	        SET @Po_ErrNo = 1
END
-- Dependancy check Geography value
	           EXEC Proc_DependencyCheck 'RouteMaster',@GeoMainId
		       IF (SELECT COUNT(*) FROM TempDepCheck) > 0
	           BEGIN
		            SET @ErrDesc = 'Transaction Exists ' + CAST(@GeoMainId AS VARCHAR(6))
		 	        INSERT INTO Errorlog VALUES (20,@TabName,'GeoMainId',@ErrDesc)
		 	        SET @Taction = 0
		 	        SET @Po_ErrNo = 1
END
		 END
--- Insert / Update to Master Table
	     IF @Taction = 1
	     BEGIN
	          UPDATE RouteMaster
		      SET RouteMaster.RMName = @RMName ,
		      RouteMaster.CmpId = @CmpId ,
		      RouteMaster.RMDistance = @Dis ,
		      RouteMaster.RMPopulation = @Pop ,
		      RouteMaster.GeoMainId = @GeoMainId ,
		      RouteMaster.RMVanRoute = @VanRoute ,
		      RouteMaster.RMSRouteType = @RMTypeId ,
		      RouteMaster.RMLocalUpcountry = @LclUpId ,
		      RouteMaster.RMMon = @RMMon ,
		      RouteMaster.RMTue = @RMTue ,
		      RouteMaster.RMWed = @RMWed ,
		      RouteMaster.RMThu = @RMThu ,
		      RouteMaster.RMFri = @RMFri ,
		      RouteMaster.RMSat = @RMSat ,
		      RouteMaster.RMSun = @RMSun
		      WHERE   RouteMaster.RMCode = @RMCode
		
	          SET @sStr = 'UPDATE RouteMaster
		      SET RouteMaster.RMName = ''' + @RMName + ''',
		      RouteMaster.CmpId = ' + CAST(@CmpId as Varchar(6)) + ',
		      RouteMaster.RMDistance = ' + CAST(@Dis as Varchar(10)) + ',
		      RouteMaster.RMPopulation = ' + CAST(@Pop as Varchar(10)) + ',
		      RouteMaster.GeoMainId = ' + CAST(@GeoMainId as Varchar(6)) + ',
		      RouteMaster.RMVanRoute = ''' + @VanRoute + ''',
		      RouteMaster.RMSRouteType = ' + CAST(@RMTypeId as Varchar(10)) + ',
		      RouteMaster.RMLocalUpcountry = ' + CAST(@LclUpId as Varchar(6)) + ',
		      RouteMaster.RMMon = ' + @RMMon + ',
		      RouteMaster.RMTue = ' + @RMTue   + ',
		      RouteMaster.RMWed = ' + @RMWed + ',
		      RouteMaster.RMThu = ' + @RMThu + ',
		      RouteMaster.RMFri = ' + @RMFri + ',
		      RouteMaster.RMSat = ' + @RMSat + ',
		      RouteMaster.RMSun = ' + @RMSun + '
		      WHERE   RouteMaster.RMCode = ''' + @RMCode + ''''
			
			  INSERT INTO Translog(strSql1) Values (@sstr)
		
		
END
	     ELSE IF @Taction = 2
	     BEGIN
	SET @RMId = dbo.Fn_GetPrimaryKeyInteger('RouteMaster','RMId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))

	INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GEOMainId,RMVanRoute,RMSRouteType,
	RMLocalUpCountry,RMMon,RMTue,RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,Upload,Availability,LastModBy,LastModDate,AuthId,AuthDate,XmlUpload) 
	VALUES (@RMId,@RMCode,@RMName,@CmpId,@Dis,@Pop,@GeoMainId,@VanRoute,@RMTypeId,
	@LclUpId,@RMMon,@RMTue,@RMWed,@RMThu,@RMFri,@RMSat,@RMSun,1,'N',1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),0)

	SET @sStr = 'INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GEOMainId,RMVanRoute,RMSRouteType,RMLocalUpCountry,RMMon,
	RMTue,RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,Upload,Availability,LastModBy,LastModDate,AuthId,AuthDate,XmlUpload) VALUES
	(' + CAST(@RMId as Varchar(6)) + ',''' + @RMCode + ''',''' + @RMName + ''',' + CAST(@CmpId as Varchar(6)) + ',' + CAST(@Dis as Varchar(10)) + ',' + CAST(@Pop as Varchar(10)) + ',' + CAST(@GeoMainId as Varchar(6)) + ',' + CAST(@VanRoute as Varchar(6)) + ',' + CAST(@RMTypeId as Varchar(6)) + ',' +
	CAST(@LclUpId as Varchar(6)) + ',' + @RMMon + ',' + @RMTue + ',' + @RMWed + ',' + @RMThu + ',' + @RMFri + ',' + @RMSat + ',' + @RMSun + ',1,''N'',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0)'
	
	INSERT INTO Translog(strSql1) Values (@sstr)
	UPDATE Counters SET currvalue = @RMId WHERE Tabname = 'RouteMaster' and fldname = 'RMId'
	SET @sStr = 'UPDATE Counters SET currvalue = ' + CAST(@RMId as VArchar(6)) + ' WHERE Tabname = ' + '''RouteMaster''' + ' and fldname = ' + '''RMId'''
	
	INSERT INTO Translog(strSql1) Values (@sstr)
END
	FETCH NEXT FROM Cur_ImpRoute INTO
	@RMCode,@RMName,@CmpCode,@Dis,@Pop,@HierVal,@VanRoute,@RMType,@LclUp,
	@RMMon,@RMTue,@RMWed,@RMThu,@RMFri,@RMSat,@RMSun
END
	CLOSE Cur_ImpRoute
	DEALLOCATE Cur_ImpRoute
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-251-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateSalesman]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateSalesman]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE [dbo].[Proc_ValidateSalesman]
(
@Po_ErrNo int OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_ValidateSalesman
* PURPOSE: To Insert and Update records  from xml file in the Table salesman
* CREATED: Gunasekaran.D. 17/09/2007
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @hDoc INTEGER
	DECLARE @InsertCount INTEGER
	DECLARE @Taction Int
	DECLARE @StateId Int
	DECLARE @ErrDesc Varchar(1000)
	DECLARE @rno int
	DECLARE @Tabname Varchar(50)
	DECLARE @CmpId int
	DECLARE @CmpCode Varchar(50)
	DECLARE @SFId int
	DECLARE @SFCode Varchar(50)
	DECLARE @SMId int
	DECLARE @SMCode Varchar(50)
	DECLARE @SMName Varchar(100)
	DECLARE @Phno Varchar(50)
	DECLARE @EId Varchar(50)
	DECLARE @StatusId int
	DECLARE @Status Varchar(50)
	DECLARE @DailyAllow Varchar(30)
	DECLARE @MonSal Varchar(30)
	DECLARE @MktCr Varchar(50)
	DECLARE @CrAmtAlert Varchar(50)
	DECLARE @CrAmtAlertId INT
	DECLARE @CrDays Varchar(20)
	DECLARE @CrDaysAlert Varchar(50)
	DECLARE @CrDaysAlertId INT
	DECLARE @RMId int
	DECLARE @RMCode Varchar(50)
	DECLARE @Type Varchar(50)
	DECLARE @sStr nVarchar(4000)
	SET @Tabname = 'ETL_Prk_Salesman'
	SET @Po_ErrNo = 0
	SET @CrDaysAlertId=0
	SET @CrAmtAlertId=0
DECLARE Cur_ImpSalesman CURSOR
FOR SELECT DISTINCT ISNULL(CmpCode,''),ISNULL([Sales Force Level Value Code],''),ISNULL([Salesman Code],''),
ISNULL([Salesman Name],''),ISNULL([Phone No],'0'),ISNULL([Email Id],''),ISNULL(Status,''),
ISNULL([Daily Allowance],'0'),ISNULL([Monthly Salary],'0'),ISNULL([Market Credit],''),ISNULL([Alert On Market Credit],''),
ISNULL([Credit Days],''),ISNULL([Alert On Credit Days],'') FROM ETL_Prk_Salesman
OPEN Cur_ImpSalesman
FETCH NEXT FROM Cur_ImpSalesman INTO
@CmpCode,@SFCode,@SMCode,@SMName,@Phno,@EId,@Status,@DailyAllow,@MonSal,
@MktCr,@CrAmtAlert,@CrDays,@CrDaysAlert
Set @Rno = 0
WHILE @@FETCH_STATUS=0
BEGIN
	     Set @Rno = @Rno + 1
	     Set @Taction = 2 -- Insert
	
	     -- Validate Mandatory field is empty or null string
	     -- Company
	     IF IsNull(@CmpCode,'') = ''
	     BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Company Code is empty'
	  INSERT INTO Errorlog VALUES (1,@TabName,'CmpCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END	
ELSE IF NOT exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
		 BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Company Code '+ @CmpCode + ' Not found '
	  INSERT INTO Errorlog VALUES (2,@TabName,'CmpCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
ELSE IF exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
BEGIN
SELECT @CmpId = CmpId FROM Company WHERE CmpCode = @CmpCode
END
-- Sales Force Value
	     IF IsNull(@SFCode,'') = ''
	     BEGIN
SET @SFId = 0
END	
ELSE IF NOT exists (SELECT * FROM SalesForce WHERE SalesForceCode = @SFCode ) and IsNull(@SFCode,'') <> ''
		 BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Sales Force Code '+ @SFCode + ' Not found '
	  INSERT INTO Errorlog VALUES (3,@TabName,'SFCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
ELSE IF exists (SELECT * FROM SalesForce WHERE SalesForceCode = @SFCode ) and IsNull(@SFCode,'') <> ''
BEGIN
SELECT @SFId = SalesForceMainId FROM SalesForce WHERE SalesForceCode = @SFCode
END
	     -- Salesman Code
	     IF IsNull(@SMCode,'') = ''
	     BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Salesman Code is empty'
	  INSERT INTO Errorlog VALUES (4,@TabName,'SMCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END	
ELSE IF exists (SELECT * FROM Salesman WHERE SMCode = @SMCode ) and IsNull(@SMCode,'') <> ''
BEGIN
SET @Taction = 1 -- update
END
	     -- Salesman Name
	     IF IsNull(@SMName,'') = ''
	     BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Salesman Name is empty'
	  INSERT INTO Errorlog VALUES (5,@TabName,'SMName',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END	
-- Phone no
IF IsNull(@PhNo,'') = ''
		 BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Phone Number '+ @PhNo + ' Not found '
	  INSERT INTO Errorlog VALUES (6,@TabName,'Phone Number',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
ELSE IF ISNUMERIC(@PhNo) = 0
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Phone number is not a numeric value'
	  INSERT INTO Errorlog VALUES (7,@TabName,'Phno',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
-- Status
	     IF IsNull(@Status,'') = ''
	     BEGIN
	          SET @StatusId = 1
END
ELSE IF Upper(@Status) = 'ACTIVE'
BEGIN
SET @StatusId = 1
END
ELSE IF Upper(@Status) = 'INACTIVE'
BEGIN
SET @StatusId = 0
END
ELSE
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Status value is wrong'
	  INSERT INTO Errorlog VALUES (8,@TabName,'Status',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
-- Daily Allowance
	     IF IsNull(@DailyAllow,'') = ''
	     BEGIN
SET @DailyAllow = 0
END
ELSE IF ISNUMERIC(@DailyAllow) = 0
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Daily allowance is not a numeric value'
	  INSERT INTO Errorlog VALUES (9,@TabName,'Daily allowance',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
-- Monthly Salary
	     IF IsNull(@MonSal,'') = ''
	     BEGIN
SET @MonSal = 0
END
ELSE IF ISNUMERIC(@MonSal) = 0
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Monthly Salary is not a numeric value'
	  INSERT INTO Errorlog VALUES (10,@TabName,'Monthly salary',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
-- Mkt Credit
	     IF IsNull(@MktCr,'') = ''
	     BEGIN
SET @MktCr = 0
END
ELSE IF ISNUMERIC(@MktCr) = 0
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Market Credit is not a numeric value'
	  INSERT INTO Errorlog VALUES (11,@TabName,'MktCr',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
-- Credit Days
	     IF IsNull(@CrDays,'') = ''
	     BEGIN
SET @CrDays = 0
END
ELSE IF ISNUMERIC(@CrDays) = 0
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Credit days is not a numeric value'
	  INSERT INTO Errorlog VALUES (12,@TabName,'Credit Days',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
IF LTRIM(RTRIM(@CrAmtAlert)) = ''
BEGIN
	 SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Market Credit Amount alert is empty'
	 INSERT INTO Errorlog VALUES (13,@TabName,'Credit Days',@ErrDesc)           	
	 SET @Taction = 0
	 SET @Po_ErrNo = 1
END
ELSE
BEGIN
	PRINT @CrAmtAlert
	IF UPPER(LTRIM(RTRIM(@CrAmtAlert)))='ALERT & STOP' OR UPPER(LTRIM(RTRIM(@CrAmtAlert)))='ALERT & ALLOW' OR UPPER(LTRIM(RTRIM(@CrAmtAlert)))='NONE'
	BEGIN
		IF UPPER(LTRIM(RTRIM(@CrAmtAlert)))='ALERT & STOP'
			BEGIN
				SET @CrAmtAlertId=2
			END
		ELSE IF UPPER(LTRIM(RTRIM(@CrAmtAlert)))='ALERT & ALLOW'
			BEGIN
				SET @CrAmtAlertId=1
			END
		ELSE IF UPPER(LTRIM(RTRIM(@CrAmtAlert)))='NONE'
			BEGIN
				SET @CrAmtAlertId=0
			END
	END
	ELSE
	BEGIN
		SET @Po_ErrNo=1		
		SET @Taction=0
		SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Market Credit Amount alert is not available'	
		INSERT INTO Errorlog VALUES (14,@Tabname,'Credit Amount Alert',@ErrDesc)
	END
END
IF LTRIM(RTRIM(@CrDaysAlert)) = ''
BEGIN
	 SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Credit days alert is empty'
	 INSERT INTO Errorlog VALUES (15,@TabName,'Credit Days',@ErrDesc)           	
	 SET @Taction = 0
	 SET @Po_ErrNo = 1
END
ELSE
BEGIN
	IF UPPER(LTRIM(RTRIM(@CrDaysAlert)))='ALERT & STOP' OR UPPER(LTRIM(RTRIM(@CrDaysAlert)))='ALERT & ALLOW' OR UPPER(LTRIM(RTRIM(@CrDaysAlert)))='NONE'
	BEGIN
		IF UPPER(LTRIM(RTRIM(@CrDaysAlert)))='ALERT & STOP'
			BEGIN
				SET @CrDaysAlertId=2
			END
		ELSE IF UPPER(LTRIM(RTRIM(@CrDaysAlert)))='ALERT & ALLOW'
			BEGIN
				SET @CrDaysAlertId=1
			END
		ELSE IF UPPER(LTRIM(RTRIM(@CrDaysAlert)))='NONE'
			BEGIN
				SET @CrDaysAlertId=0
			END
	END
	ELSE
	BEGIN
		SET @Po_ErrNo=1		
		SET @Taction=0
		SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + 'Credit Days alert is not available'	
		INSERT INTO Errorlog VALUES (16,@Tabname,'Credit Days Alert',@ErrDesc)
	END
END
--- Insert / Update to Master Table
	     IF @Taction = 1
	     BEGIN
	          UPDATE Salesman
		      SET Salesman.SMName = @SMName ,
		      Salesman.SMPhoneNumber = @Phno,
		      Salesman.SMEmailID = @EId,
		      Salesman.SMDailyAllowance = @DailyAllow,
		      Salesman.SMMonthlySalary = @MonSal,
		      Salesman.SMMktCredit = @MktCr,
		      Salesman.SMCreditDays = @CrDays ,
		      Salesman.CmpId = @CmpId ,
		      Salesman.SalesForceMainId = @SFId ,
		      Salesman.Status = @StatusId,
		      Salesman.SMCreditAmountAlert = @CrAmtAlertId,
		      Salesman.SMCreditDaysAlert = @CrDaysAlertId
		      WHERE   Salesman.SMCode = @SMCode
		
	          SET @sStr = 'UPDATE Salesman
		      SET Salesman.SMName = ''' + @SMName + ''',
		      Salesman.SMPhoneNumber = ''' + @Phno + ''',
		      Salesman.SMEmailID = ''' + @EId + ''',
		      Salesman.SMDailyAllowance = ' + CAST(@DailyAllow as VArchar(20)) + ',
		      Salesman.SMMonthlySalary = ' + CAST(@MonSal as VArchar(20)) + ',
		      Salesman.SMMktCredit = ' + CAST(@MktCr as VArchar(20)) + ',
		      Salesman.SMCreditDays = ' + CAST(@CrDays as VArchar(20)) + ',
		      Salesman.CmpId = ' + CAST(@CmpId as VArchar(20)) + ',
		      Salesman.SalesForceMainId = ' + CAST(@SFId as VArchar(20)) + ',
		      Salesman.Status = ' + CAST(@StatusId as VArchar(20)) + ',
		      Salesman.SMCreditAmountAlert = ' + CAST(@CrAmtAlertId as VArchar(20)) + ',
		      Salesman.SMCreditDaysAlert = ' + CAST(@CrDaysAlertId as VArchar(20)) + '
		      WHERE   Salesman.SMCode = ''' + @SMCode + ''''
			
			  INSERT INTO Translog(strSql1) Values (@sstr)		
END
	     ELSE IF @Taction = 2 AND @Po_ErrNo=0
	     BEGIN
          	SET @SMId = dbo.Fn_GetPrimaryKeyInteger('Salesman','SMId',CAST(YEAR(GetDate())AS INT),Month(GetDate()))	
		INSERT INTO Salesman (SMId,SMcode,SMName,SMPhoneNumber,SMEmailId,SMOtherDetails,
		SMDailyAllowance,SMMonthlySalary,SMMktCredit,SMCreditDays,CmpId,SalesForceMainId,
		Status,SMCreditAmountAlert,SMCreditDaysAlert,Upload,Availability,LastModBy,LastModDate,AuthId,AuthDate,XmlUpload) VALUES
		(@SMId,@SMCode,@SMName,@Phno,@EId,'',@DailyAllow,@MonSal,@MktCr,@CrDays,@CmpId,@SFId,
		@StatusId,@CrAmtAlertId,@CrDaysAlertId,'N',1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),0)
		SET @sStr = 'INSERT INTO Salesman (SMId,SMcode,SMName,SMPhoneNumber,SMEmailId,SMOtherDetails,SMDailyAllowance,SMMonthlySalary,SMMktCredit,SMCreditDays,CmpId,SalesForceMainId,Status,SMCreditAmountAlert,SMCreditDaysAlert,Upload,Availability,LastModBy,LastModDate,AuthId,AuthDate,XmlUpload) VALUES  (' + CAST(@SMId as VArchar(6)) + ',''' + @SMCode + ''',''' + @SMName + ''',''' + @Phno + ''',''' + @EId + ''',''' + '' + ''',' + CAST(@DailyAllow as VArchar(20)) + ',' + CAST(@MonSal as VArchar(20)) + ',' + CAST(@MktCr as VArchar(20)) + ',' + CAST(@CrDays as VArchar(20)) + ',' + CAST(@CmpId as Varchar(6))  + ',' +
		CAST(@SFId as Varchar(6)) + ',' + CAST(@StatusId as Varchar(6)) + ',' + CAST(@CrAmtAlertId as Varchar(6)) + ',' + CAST(@CrDaysAlertId as Varchar(6)) + ',''N'',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0)'
		
		INSERT INTO Translog(strSql1) Values (@sstr)		
		UPDATE Counters SET currvalue = @SMId WHERE Tabname = 'Salesman' and fldname = 'SMId'
		SET @sStr= 'UPDATE Counters SET currvalue = ' + CAST(@SMId as Varchar(6)) + ' WHERE Tabname = ' + '''Salesman''' + ' and fldname = ' + '''SMId'''
		
		INSERT INTO Translog(strSql1) Values (@sstr)		
	    END
FETCH NEXT FROM Cur_ImpSalesman INTO
@CmpCode,@SFCode,@SMCode,@SMName,@Phno,@EId,@Status,@DailyAllow,@MonSal,
@MktCr,@CrAmtAlert,@CrDays,@CrDaysAlert
END
CLOSE Cur_ImpSalesman
DEALLOCATE Cur_ImpSalesman
-------------- Salesman Market
DECLARE Cur_ImpSalesmanMarket CURSOR
FOR SELECT [Salesman Code],[Route Code],[Type] FROM ETL_Prk_Salesman
OPEN Cur_ImpSalesmanMarket
FETCH NEXT FROM Cur_ImpSalesmanMarket INTO @SMCode,@RMCode,@Type
Set @Rno = 0
WHILE @@FETCH_STATUS=0
BEGIN
	     Set @Rno = @Rno + 1
	     Set @Taction = 2 -- Insert
	
	     -- Validate Mandatory field is empty or null string
	     -- Salesman Code
	     IF IsNull(@SMCode,'') = ''
	     BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Salesman Code is empty'
	  INSERT INTO Errorlog VALUES (3,@TabName,'SMCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END	
ELSE IF Not exists (SELECT SMId FROM Salesman WHERE SMCode = @SMCode ) and IsNull(@SMCode,'') <> ''
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Salesman Code ' + @SMCode + ' not found in Master table'
	  INSERT INTO Errorlog VALUES (3,@TabName,'SMCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
ELSE
BEGIN
SELECT @SMId = SMId FROM Salesman WHERE SMCode = @SMCode
END
	     -- RM Code
	     IF IsNull(@RMCode,'') = ''
	     BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Route Code is empty'
	  INSERT INTO Errorlog VALUES (3,@TabName,'RMCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END	
ELSE IF Not exists (SELECT RMId FROM RouteMaster WHERE RMCode = @RMCode ) and IsNull(@RMCode,'') <> ''
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Route Code ' + @RMCode + ' not found in Master table'
	  INSERT INTO Errorlog VALUES (3,@TabName,'RMCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
ELSE
BEGIN
SELECT @RMId = RMId FROM RouteMaster WHERE RMCode = @RMCode
END
-- Type
IF IsNull(@Type,'') = ''
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Type should not be empty'
	  INSERT INTO Errorlog VALUES (3,@TabName,'Type',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1         	
END
		 ELSE IF @Type <> 'Add' and @Type <> 'Reduce'
		 BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Type should be wither Add or Reduce'
	  INSERT INTO Errorlog VALUES (3,@TabName,'Type',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1		 	
		 END
-- Set mode
IF EXISTS (SELECT * FROM SalesmanMarket WHERE SMID = @SMId and RMID = @RMId)  and @Type = 'Add'
BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Record already exists in map table'
	  INSERT INTO Errorlog VALUES (3,@TabName,'SMId and RMId',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo = 1
END
ELSE IF NOT EXISTS (SELECT * FROM SalesmanMarket WHERE SMID = @SMId and RMID = @RMId) and @Taction <> 0 and @Type = 'Add'
BEGIN
SET @Taction = 2
END
		 ELSE IF @Type = 'Reduce'
		 BEGIN
		 	  DELETE FROM SalesmanMarket WHERE SMID = @SMId and RMID = @RMId
		 	  SET @sStr = 'DELETE FROM SalesmanMarket WHERE SMID = ' + CAST(@SMId as Varchar(6)) + ' and RMID = ' + CAST(@RMId as Varchar(6))
			
			  INSERT INTO Translog(strSql1) Values (@sstr)		 	
		      SET @Taction = 0
		 END
--- Insert / Update to Master Table
	     IF @Taction = 2
	     BEGIN
INSERT INTO SalesmanMarket (SMId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
(@SMId,@RMId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
SET @sStr = 'INSERT INTO SalesmanMarket (SMId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
(' + CAST(@SMId as Varchar(6)) + ',' + CAST(@RMId as Varchar(6)) + ',1,1,''' + convert(varchar(10),getdate(),121)  + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
			
			  INSERT INTO Translog(strSql1) Values (@sstr)		 	
END
FETCH NEXT FROM Cur_ImpSalesmanMarket INTO @SMCode,@RMCode,@Type
END
CLOSE Cur_ImpSalesmanMarket
DEALLOCATE Cur_ImpSalesmanMarket
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-251-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateVehicleMaintenance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateVehicleMaintenance]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[Proc_ValidateVehicleMaintenance]
(
       @Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_ValidateVehicleMaintenance
* PURPOSE: To Insert and Update records  from xml file in the Table Vehicle
* CREATED: Swapneswar Sharma 18/09/2007
*********************************/
--SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	DECLARE @InsertCount INTEGER
	DECLARE @Taction  Int
	DECLARE @StateId  Int
	DECLARE @ErrDesc  Varchar(1000)
	DECLARE @rno  int
	DECLARE @Tabname  nVarchar(50)
	DECLARE @VehicleCode  nVarchar(20)
	DECLARE @VehicleRegNo  nVarchar(50)
	DECLARE @VehicleCtgCode  nVarchar(20)
	DECLARE @VehicleCapacity  nVarchar(20)
	DECLARE @RatePerCase  nVarchar(20)
	DECLARE @RatePerTonne  nVarchar(20)
	DECLARE @RatePerKM  nVarchar(20)
	DECLARE @VehicleStatus  nVarchar(20)
	DECLARE @StatusId  TINYINT
	DECLARE @VehicleId  INT
	DECLARE @LcnId  INT
	DECLARE @VehicleCtgId  INT
	DECLARE @StockTypeId INT
	DECLARE @sStr	nVarchar(4000)
	
	SET @Po_ErrNo=0
    Set @Tabname = 'ETL_Prk_VehicleMaintenance'

    DECLARE Cur_ImpVehicleMaintenance CURSOR
    FOR SELECT ISNULL([Vehicle Code],''),ISNULL([Vehicle RegNo],''),ISNULL([Vehicle Category Code],''),
    ISNULL([Vehicle Capacity],'0'),ISNULL([Rate Per Case],'0'),ISNULL([Rate Per Tonne],'0'),
    ISNULL([Rate Per KM],'0'),ISNULL([Vehicle Status],'') FROM ETL_Prk_VehicleMaintenance

    OPEN Cur_ImpVehicleMaintenance


    FETCH NEXT FROM Cur_ImpVehicleMaintenance INTO @VehicleCode,@VehicleRegNo,@VehicleCtgCode,@VehicleCapacity,@RatePerCase,
                                              @RatePerTonne,@RatePerKM,@VehicleStatus

    Set @Rno = 0

    WHILE @@FETCH_STATUS=0
    BEGIN
	     Set @Rno = @Rno + 1
	     Set @Taction = 2 -- Insert
	
         --- Validation for NULL value
         IF IsNull(@VehicleCode,'') = ''
		 BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Vehicle Code '+ @VehicleCode + ' Not found '
        	  INSERT INTO Errorlog VALUES (1,@TabName,'VehicleCode',@ErrDesc)
			  SET @Taction = 0
			  SET @Po_ErrNo=1
         END
         IF IsNull(@VehicleRegNo,'') = ''
		 BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Registraion No '+ @VehicleRegNo + ' Not found '
        	  INSERT INTO Errorlog VALUES (1,@TabName,'VehicleRegNo',@ErrDesc)
			  SET @Taction = 0
			  SET @Po_ErrNo=1
         END
         ----------	
         IF EXISTS (SELECT * FROM Vehicle WHERE VehicleCode = @VehicleCode)
         BEGIN
		      SET @Taction = 1  -- update
         END
         

         -- Get Toggle value for status
         IF UPPER(@VehicleStatus) = 'ACTIVE'
         BEGIN
              SET @StatusId = 1
         END
         ELSE
         BEGIN
             SET @StatusId = 2
         END

         --- Validation for VehicleCtgCode
         IF NOT EXISTS (SELECT * FROM VehicleCategory WHERE VehicleCtgCode = @VehicleCtgCode )
		 BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Category Code '+ @VehicleCtgCode + ' Not found '
        	  INSERT INTO Errorlog VALUES (1,@TabName,'VehicleCtgCode',@ErrDesc)
			  SET @Taction = 0
			  SET @Po_ErrNo=1
         END
         ELSE IF NOT EXISTS (SELECT VehicleCtgId FROM VehicleCategory WHERE VehicleCtgCode = @VehicleCtgCode ) and IsNull(@VehicleCtgCode,'') <> ''
         BEGIN
	          SET @ErrDesc = 'In Row ' + cast (@Rno as varchar(10)) + ' Category Code ' + @VehicleCtgCode + ' not found in Master table'
        	  INSERT INTO Errorlog VALUES (3,@TabName,'VehicleCtgCode',@ErrDesc)           	
			  SET @Taction = 0
			  SET @Po_ErrNo=1
         END
         ELSE
         BEGIN
              SELECT @VehicleCtgId = VehicleCtgId FROM VehicleCategory WHERE VehicleCtgCode = @VehicleCtgCode
         END

         --- Insert / Update to Master Table
	     IF @Taction = 1
	     BEGIN
		      UPDATE Vehicle
		      SET Vehicle.VehicleRegNo = @VehicleRegNo,
			  Vehicle.VehicleCapacity = @VehicleCapacity,
		      Vehicle.RatePerCase =  @RatePerCase,
			  Vehicle.RatePerTonne = @RatePerTonne,
		      Vehicle.RatePerKM = @RatePerKM,
			  Vehicle.VehicleStatus = @StatusId
		      WHERE Vehicle.VehicleCode = @VehicleCode
--------------		
		      SET @sStr = 'UPDATE Vehicle
		      SET Vehicle.VehicleRegNo = ''' + @VehicleRegNo + ''',
			  Vehicle.VehicleCapacity = ''' + @VehicleCapacity + ''',
		      Vehicle.RatePerCase =  ''' + @RatePerCase + ''',
			  Vehicle.RatePerTonne = ''' + @RatePerTonne + ''',
		      Vehicle.RatePerKM = ''' + @RatePerKM + ''',
			  Vehicle.VehicleStatus = ' + CAST(@StatusId AS VARCHAR(3)) + '
		      WHERE Vehicle.VehicleCode = ''' + @VehicleCode + ''''

               
              INSERT INTO Translog(strSql1) Values (@sstr)
--------------
         END
	     ELSE IF @Taction = 2
	     BEGIN


	          SET @LcnId = dbo.Fn_GetPrimaryKeyInteger('Location','LcnId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
			  INSERT INTO Location (LcnId,LcnCode,LcnName,LcnAddress1,LcnAddress2,LcnAddress3,
              LcnPhoneNo,DefaultLocation,Availability,LastModBy,LastModDate,AuthId,AuthDate)
              VALUES (@LcnId,@VehicleCode,@VehicleRegNo,@VehicleRegNo,'','','',0,1,1,
              convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
-------------	
		      SET @sStr = 'INSERT INTO Location (LcnId,LcnCode,LcnName,LcnAddress1,LcnAddress2,LcnAddress3,
              LcnPhoneNo,DefaultLocation,Availability,LastModBy,LastModDate,AuthId,AuthDate)
              VALUES (' + CAST(@LcnId AS VARCHAR(6)) + ',''' + @VehicleCode + ''',''' + @VehicleRegNo + ''',
              ''' + @VehicleRegNo + ''',''' + '' + ''',''' + '' + ''',''' + '' + ''',0,1,1,''' + convert(varchar(10),getdate(),121) + ''',1,
              ''' + convert(varchar(10),getdate(),121) + ''')'
		       
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------
			  UPDATE Counters SET currvalue = @LcnId WHERE Tabname = 'Location' and fldname = 'LcnId'
-------------
              SET @sStr = 'UPDATE Counters SET currvalue = ' + CAST(@LcnId AS VARCHAR(10)) + '
              WHERE Tabname = ' + '''Location''' + ' and fldname =  ' + '''LcnId'''
               
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------

	          SET @VehicleId = dbo.Fn_GetPrimaryKeyInteger('Vehicle','VehicleId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		      INSERT INTO Vehicle (VehicleId,VehicleCode,VehicleRegNo,VehicleCtgId,VehicleCapacity,RatePerCase,
              RatePerTonne,RatePerKM,VehicleStatus,LcnId,Availability,LastModBy,LastModDate,AuthId,AuthDate,XmlUpload)
              VALUES (@VehicleId,@VehicleCode,@VehicleRegNo,@VehicleCtgId,@VehicleCapacity,@RatePerCase,
              @RatePerTonne,@RatePerKM,@StatusId,@LcnId,1,1,
              convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),0)
-------------	
		      SET @sStr = 'INSERT INTO Vehicle (VehicleId,VehicleCode,VehicleRegNo,VehicleCtgId,VehicleCapacity,RatePerCase,
              RatePerTonne,RatePerKM,VehicleStatus,LcnId,Availability,LastModBy,LastModDate,AuthId,AuthDate,XmlUpload)
              VALUES (' + CAST(@VehicleId AS VARCHAR(6)) + ',''' + @VehicleCode + ''',''' + @VehicleRegNo + ''',
              ' + CAST(@VehicleCtgId AS VARCHAR(6)) + ',''' + @VehicleCapacity + ''',''' + @RatePerCase + ''',
              ''' + @RatePerTonne + ''',''' + @RatePerKM + ''',' + CAST(@StatusId AS VARCHAR(3)) + ',
              ' + CAST(@LcnId AS VARCHAR(3)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,
              ''' + convert(varchar(10),getdate(),121) + ''',0)'
		       
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------
		      UPDATE Counters SET currvalue = @VehicleId WHERE Tabname = 'Vehicle' and fldname = 'VehicleId'
-------------
              SET @sStr = 'UPDATE Counters SET currvalue = ' + CAST(@VehicleId AS VARCHAR(10)) + '
              WHERE Tabname = ' + '''Vehicle''' + ' and fldname =  ' + '''VehicleId'''
               
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------

			  SET @StockTypeId = dbo.Fn_GetPrimaryKeyInteger('StockType','StockTypeId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
              INSERT INTO StockType(StockTypeId,UserStockType,SystemStockType,UpdateInventory,LcnId,
              Availability,LastModBy,LastModDate,AuthId,AuthDate)
              VALUES (@StockTypeId,@VehicleCode+'Saleable',1,'Y',@LcnId,1,1,
              convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
-------------	
		      SET @sStr = 'INSERT INTO StockType(StockTypeId,UserStockType,SystemStockType,UpdateInventory,LcnId,
              Availability,LastModBy,LastModDate,AuthId,AuthDate)
              VALUES (' + CAST(@StockTypeId AS VARCHAR(6)) + ',''' + @VehicleCode + 'Saleable' + ''',1,
              ' + '''Y''' + ',' + CAST(@LcnId AS VARCHAR(6)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,
              ''' + convert(varchar(10),getdate(),121) + ''')'
		       
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------
              UPDATE Counters SET currvalue = @StockTypeId WHERE Tabname = 'StockType' and fldname = 'StockTypeId'
-------------
              SET @sStr = 'UPDATE Counters SET currvalue = ' + CAST(@StockTypeId AS VARCHAR(10)) + '
              WHERE Tabname = ' + '''StockType''' + ' and fldname =  ' + '''StockTypeId'''
               
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------

			  SET @StockTypeId = dbo.Fn_GetPrimaryKeyInteger('StockType','StockTypeId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
              INSERT INTO StockType(StockTypeId,UserStockType,SystemStockType,UpdateInventory,LcnId,
              Availability,LastModBy,LastModDate,AuthId,AuthDate)
              VALUES (@StockTypeId,@VehicleCode+'UnSaleable',2,'Y',@LcnId,1,1,
              convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
-------------	
		      SET @sStr = 'INSERT INTO StockType(StockTypeId,UserStockType,SystemStockType,UpdateInventory,LcnId,
              Availability,LastModBy,LastModDate,AuthId,AuthDate)
              VALUES (' + CAST(@StockTypeId AS VARCHAR(6)) + ',''' + @VehicleCode + 'UnSaleable' + ''',2,
              ' + '''Y''' + ',' + CAST(@LcnId AS VARCHAR(6)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,
              ''' + convert(varchar(10),getdate(),121) + ''')'
		       
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------
              UPDATE Counters SET currvalue = @StockTypeId WHERE Tabname = 'StockType' and fldname = 'StockTypeId'
-------------
              SET @sStr = 'UPDATE Counters SET currvalue = ' + CAST(@StockTypeId AS VARCHAR(10)) + '
              WHERE Tabname = ' + '''StockType''' + ' and fldname =  ' + '''StockTypeId'''
               
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------

			  SET @StockTypeId = dbo.Fn_GetPrimaryKeyInteger('StockType','StockTypeId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
              INSERT INTO StockType(StockTypeId,UserStockType,SystemStockType,UpdateInventory,LcnId,
              Availability,LastModBy,LastModDate,AuthId,AuthDate)
              VALUES (@StockTypeId,@VehicleCode+'Offer',3,'Y',@LcnId,1,1,
              convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
-------------	
		      SET @sStr = 'INSERT INTO StockType(StockTypeId,UserStockType,SystemStockType,UpdateInventory,LcnId,
              Availability,LastModBy,LastModDate,AuthId,AuthDate)
              VALUES (' + CAST(@StockTypeId AS VARCHAR(6)) + ',''' + @VehicleCode +'Offer' + ''',3,
              ' + '''Y''' + ',' + CAST(@LcnId AS VARCHAR(6)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,
              ''' + convert(varchar(10),getdate(),121) + ''')'
		       
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------
              UPDATE Counters SET currvalue = @StockTypeId WHERE Tabname = 'StockType' and fldname = 'StockTypeId'
-------------
              SET @sStr = 'UPDATE Counters SET currvalue = ' + CAST(@StockTypeId AS VARCHAR(10)) + '
              WHERE Tabname = ' + '''StockType''' + ' and fldname =  ' + '''StockTypeId'''
               
              INSERT INTO Translog(strSql1) Values (@sstr)
-------------

         END

      FETCH NEXT FROM Cur_ImpVehicleMaintenance INTO @VehicleCode,@VehicleRegNo,@VehicleCtgCode,@VehicleCapacity,@RatePerCase,
                                                @RatePerTonne,@RatePerKM,@VehicleStatus
      END
      CLOSE Cur_ImpVehicleMaintenance
      DEALLOCATE Cur_ImpVehicleMaintenance
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-251-010

DELETE FROM XmlDataExtract

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('1','Item Master','Proc_XmlUpload_ItemMaster','Etl_Xml_ItemMaster','Master','Item Master','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('2','Claim Group Master','Proc_XmlUpload_ClaimGrpaster','Etl_Xml_ClaimGrpMaster','Master','Claim Group Master','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('3','Vehicle Master','Proc_XmlUpload_VehicleMaster','Etl_Xml_VehicleMaster','Master','Vehicle Master','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('4','Route Master','Proc_XmlUpload_RouteMaster','Etl_Xml_RouteMaster','Master','Route Master','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('5','Sales Man Master','Proc_XmlUpload_SalesManMaster','Etl_Xml_SalesManMaster','Master','Sales Man Master','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('6','Customer Master','Proc_XmlUpload_Customer','Etl_Xml_Customer','Master','Customer Master','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('7','Batch Clone','Proc_XmlUpload_BatchCloning','ETL_XML_BatchCloning','Transaction','Batch Clone','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('8','Scheme Master','Proc_XmlUpload_SchemeMaster','Etl_Xml_SchemeMaster','Master','Scheme Master','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('9','Scheme Product','Proc_XmlUpload_SchemeProduct','Etl_Xml_SchemeProduct','Master','Scheme Product','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('10','Scheme Attribute','Proc_XmlUpload_SchemeAttributes','Etl_Xml_SchemeAttributes','Master','Scheme Attribute','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('11','Scheme Slab','Proc_XmlUpload_SchemeSlabs','Etl_Xml_SchemeSlab','Master','Scheme Slab','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('12','Scheme CombiDt','Proc_XmlUpload_SchemeCombiProducts','Etl_Xml_SchemeCombiPrdDt','Master','Scheme CombiDt','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('13','Scheme FreeDt','Proc_XmlUpload_SchemeFreePrdDt','Etl_Xml_SchemeFreePrdDt','Master','Scheme FreeDt','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('14','Sales Invoice','Proc_XmlUpload_SalesInvoice','ETL_XML_SalesInvoice','Transaction','Sales Invoice','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('15','Sales Invoice Scheme','Proc_XmlUpload_SalesInvoiceScheme','ETL_XML_SalesInvoiceScheme','Transaction','Sales Invoice Scheme','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('16','Sales Return','Proc_XmlUpload_SalesReturn','ETL_XML_SalesReturn','Transaction','Sales Return','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('17','Sales Return Scheme','Proc_XmlUpload_SalesReturnScheme','ETL_XML_SalesReturnScheme','Transaction','Sales Return Scheme','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('18','Credit Note (Sales)','Proc_XmlUpload_CreditNoteRetailer','Etl_Xml_CreditNote_Sales','Transaction','Credit Note (Sales)','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('19','Debit Note (Sales)','Proc_XmlUpload_DebitNoteRetailer','Etl_Xml_DebitNote_Sales','Transaction','Debit Note (Sales)','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('20','Sales Payment','Proc_XmlUpload_SalesPayment','Etl_Xml_SalesPayment','Transaction','Sales Payment','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('21','SalesPaymentCancellation','Proc_XmlUpload_SalesPaymentCancellation','Etl_Xml_SalesPaymentCancellation','Transaction','SalesPaymentCancellation','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('22','Purchase Invoice','Proc_XmlUpload_PurchaseReceipt','ETL_XML_PurchaseReceipt','Transaction','Purchase Invoice','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('23','Purchase Return','Proc_XmlUpload_PurchaseReturn','ETL_XML_PurchaseReturn','Transaction','Purchase Return','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('24','Debit Note (Purchase)','Proc_XmlUpload_DebitNotePurchase','ETL_XML_DebitNotePurchase','Transaction','Debit Note (Purchase)','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('25','Credit Note (Purchase)','Proc_XmlUpload_CreditNotePurchase','ETL_XML_CreditNotePurchase','Transaction','Credit Note (Purchase)','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('26','Goods Issue','Proc_XmlUpload_GoodsIssue','ETL_XML_GoodsIssue','Transaction','Goods Issue','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('27','Goods Receipt','Proc_XmlUpload_GoodsReceipt','ETL_XML_GoodsReceipt','Transaction','Goods Receipt','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('28','Salvage','Proc_XmlUpload_Salvage','ETL_XML_Salvage','Transaction','Salvage','1')

INSERT INTO XmlDataExtract(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,ExecuteSP) 
VALUES('29','Van Loading & Van Unloading','Proc_XmlUpload_VanLoadUnload','ETL_XML_VanLoadUnload','Transaction','Van Loading & Van Unloading','1')

--SRF-Nanda-251-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GR_Build_PH]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GR_Build_PH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC [Proc_GR_Build_PH]

CREATE PROC [dbo].[Proc_GR_Build_PH]
AS
/*********************************
* PROCEDURE	: Proc_GR_Build_PH
* PURPOSE	: House Keeping for Product Hierarchy
* CREATED	: ShyamSundar.N
* CREATED DATE	: 09/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 22/09/2010	Nanda		 Changes done for Default company and Product category level with space	
*********************************/
BEGIN
	IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TBL_GR_BUILD_PH') DROP TABLE TBL_GR_BUILD_PH
	DECLARE @SqlStr1	VARCHAR(1000)
	DECLARE @SqlMain	VARCHAR(3000)
	DECLARE @PHLevel	INT
	DECLARE @ILoop2		INT
	DECLARE @DefCmpId	INT
	SET @ILoop2=1
	
	SELECT @DefCmpId=ISNULL(CmpId,1) FROM Company WHERE DefaultCompany=1
	SELECT @PHLevel=MAX(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId =@DefCmpId
	SET @SqlMain = 'CREATE TABLE TBL_GR_BUILD_PH  (PrdId INT,ProductCode NVARCHAR(100),	ProductDescription NVARCHAR(200),'
	WHILE @ILoop2<=@PHLevel
	BEGIN
		SET @SqlStr1=''
		IF EXISTS(SELECT * FROM ProductCategoryLevel WHERE CmpPrdCtgId=@ILoop2 AND CmpId=@DefCmpId)
		BEGIN
			SELECT @SqlStr1='['+CmpPrdCtgName +'_Id] INT,['+CmpPrdCtgName+'_Code] VARCHAR(200),['+CmpPrdCtgName+'_Caption] VARCHAR(200),' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@ILoop2
			SET @SqlMain=@SqlMain+@SqlStr1
		END
		SET @ILoop2=@ILoop2+1
	END
	SET @SqlMain=@SqlMain + 'HashProducts NVARCHAR(3800))'
	EXECUTE (@SqlMain)
	SET @ILoop2=1
	SET @SqlStr1=''
	SET @SqlMain=''
	SELECT @SqlStr1='INSERT INTO TBL_GR_BUILD_PH (PrdId,ProductCode,ProductDescription,['+CmpPrdCtgName +'_Id],['+CmpPrdCtgName+'_Code],['+CmpPrdCtgName +'_Caption])' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@PHLevel
	SET @SqlStr1=@SqlStr1+' SELECT PrdId,PrdDCode,PrdName,A.PrdCtgValMainId,PrdCtgValCode,PrdCtgValName '
	SET @SqlStr1=@SqlStr1+' FROM Product A,ProductCategoryValue B WHERE A.PrdCtgValMainId=B.PrdCtgValMainId AND A.CmpId='+CAST(@DefCmpId AS VARCHAR(10))
	SET @SqlMain=@SqlStr1
	EXECUTE (@SqlMain)
	--SET @PHLevel=@PHLevel-1
	WHILE @ILoop2<@PHLevel
	BEGIN
		SET @SqlStr1=''
		SELECT @SqlStr1='UPDATE C SET ['+CmpPrdCtgName+'_Id]=A.PrdCtgValMainId,['+CmpPrdCtgName+'_Code]=A.PrdCtgValCode,['+CmpPrdCtgName+'_Caption]=A.PRDCTGVALNAME ' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@PHLevel-@ILoop2
		SELECT @SqlStr1=@SqlStr1+' FROM ProductCategoryValue A,ProductCategoryValue B,TBL_GR_BUILD_PH C WHERE ' FROM ProductCategoryLevel WHERE CmpPrdCtgId=(@PHLevel-@ILoop2)
		SELECT @SqlStr1=@SqlStr1+' B.PrdCtgValMainId=C.['+CmpPrdCtgName+'_Id] AND A.PrdCtgValMainId=B.PRDCTGVALLINKID ' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@PHLevel-@ILoop2+1
		SET @SqlMain=@SqlStr1
		EXECUTE (@SqlMain)
		SET @ILoop2=@ILoop2+1
	END
	SET @ILoop2=1
	SET @SqlStr1='UPDATE TBL_GR_BUILD_PH SET HashProducts='
	WHILE @ILoop2<=@PHLevel
	BEGIN
		SELECT @SqlStr1=@SqlStr1+'['+CmpPrdCtgName+'_Caption]+' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@ILoop2
		SET @ILoop2=@ILoop2+1
	END
	SET @SqlStr1=@SqlStr1+'ProductCode+ProductDescription'
	EXECUTE (@SqlStr1)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_BatchCloning]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_BatchCloning]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   Proc [dbo].[Proc_XmlUpload_BatchCloning]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	--  DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0

	DELETE FROM ETL_XML_BatchCloning --WHERE UploadFlag='Y'
	--  SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1

	INSERT INTO ETL_XML_BatchCloning (ItemCode,ItemName,ExpiryDate,ManufacturerSerialNumber,ManufacturingDate,ProductCode,PriceCode,TaxGroupCode,Status,BatchSequenceCode,MRPPrice,LSPPrice,PrimaryDisc,SellingRate,ClaimRate,DefaultPriceId,UploadFlag)
	SELECT PrdDCode,PrdName,CONVERT(VARCHAR(10),ExpDate,121),CmpBatCode,CONVERT(VARCHAR(10),MnfDate,121),
	PrdCCode,PBD1.PriceCode,PrdGroup,CASE PB.Status WHEN 1 THEN 'Active' ELSE 'Inactive' END,BCM.RefCode,
	PBD1.PrdBatDetailValue,PBD2.PrdBatDetailValue,PBD3.PrdBatDetailValue,PBD4.PrdBatDetailValue,
	PBD5.PrdBatDetailValue,CASE PBD1.DefaultPrice WHEN 1 THEN 'Y' ELSE 'N' END,'N'
	FROM Product P (NOLOCK)
	INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId
	INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatId=PB.PrdBatId AND PBD1.BatchSeqId=PB.BatchSeqId AND PBD1.SlNo=1 AND PBD1.PriceId=PB.DefaultPriceId
	INNER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=PB.TaxGroupId
	INNER JOIN BatchCreationMaster BCM (NOLOCK) ON BCM.BatchSeqId=PB.BatchSeqId
	INNER JOIN BatchCreation BC (NOLOCK) ON BC.SlNo=PBD1.SlNo AND BC.BatchSeqId=BCM.BatchSeqId AND BC.BatchSeqId=PB.BatchSeqId
	INNER JOIN ProductBatchDetails PBD2 (NOLOCK) ON PBD2.PrdBatId=PB.PrdBatId AND PBD2.BatchSeqId=PB.BatchSeqId AND PBD2.SlNo=2 AND PBD2.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD3 (NOLOCK) ON PBD3.PrdBatId=PB.PrdBatId AND PBD3.BatchSeqId=PB.BatchSeqId AND PBD3.SlNo=3 AND PBD3.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD4 (NOLOCK) ON PBD4.PrdBatId=PB.PrdBatId AND PBD4.BatchSeqId=PB.BatchSeqId AND PBD4.SlNo=4 AND PBD4.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD5 (NOLOCK) ON PBD5.PrdBatId=PB.PrdBatId AND PBD5.BatchSeqId=PB.BatchSeqId AND PBD5.SlNo=5 AND PBD5.PriceId=PB.DefaultPriceId
	WHERE PB.EnableCloning>0 AND PBD1.XmlUpload=0 AND PBD2.XmlUpload=0
	AND PBD3.XmlUpload=0 AND PBD4.XmlUpload=0 AND PBD5.XmlUpload=0 AND PB.Status=1
	ORDER BY P.PrdId
	UPDATE A SET XmlUpload=1 FROM ProductBatchDetails A,
	(SELECT P.PrdId AS ProdId,PB.PrdId AS ProdBatPrdId,PB.PrdBatId,PrdCCode,PrdDCode,CmpBatCode,PrdBatCode
	FROM Product P (NOLOCK) INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId = PB.PrdId
	INNER JOIN ETL_XML_BatchCloning C (NOLOCK) ON ItemCode=PrdDCode AND CmpBatCode=ManufacturerSerialNumber
	AND PrdCCode=ProductCode WHERE UploadFlag='N' AND PB.Status=1) AS B
	WHERE A.PrdBatId=B.PrdBatId AND A.XmlUpload=0 AND A.DefaultPrice=1
	SELECT * FROM ETL_XML_BatchCloning --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_ClaimGrpaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_ClaimGrpaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_XmlUpload_ClaimGrpaster]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT =0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_ClaimGrpaster
* PURPOSE: Claim Group Master XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_ClaimGrpMaster --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_ClaimGrpMaster
	(
	DistCode,
	Company,
	ClaimGroupCode,
	ClaimGroupName,
	AutoClaim,
	UploadFlag
	)
	SELECT @DistCode,B.CmpCode,A.ClmGrpCode,A.ClmGrpname, CASE A.AutoClaim WHEN 0 THEN 'N' WHEN 1 THEN 'Y' END,'N'
	FROM ClaimGroupMaster A INNER JOIN Company B ON A.CmpId=B.CmpId WHERE A.XmlUpload=0
	ORDER BY A.ClmGrpCode
	UPDATE A SET XmlUpload=1 FROM ClaimGroupMaster A INNER JOIN Etl_Xml_ClaimGrpMaster B ON
	B.ClaimGroupCode=A.ClmGrpCode WHERE A.XmlUpload=0 AND B.UploadFlag='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_CountCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_CountCheck]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Proc_XmlUpload_CountCheck]
(
@DATE AS DATETIME
)
AS
BEGIN
	DECLARE @SI1 AS INT
	DECLARE @SI2 AS INT
	DECLARE @SI3 AS INT
	DECLARE @SI4 AS INT
	DECLARE @SI5 AS INT
	DECLARE @SI6 AS INT
	DECLARE @RI1 AS INT
	DECLARE @RI2 AS INT
	DECLARE @RI3 AS INT
	DECLARE @RI4 AS INT
	DECLARE @PI1 AS INT
	DECLARE @PI2 AS INT
	DECLARE @PR1 AS INT
	DECLARE @PR2 AS INT
	DECLARE @SP1 AS INT
	DECLARE @SP2 AS INT
	DECLARE @SPC1 AS INT
	DECLARE @SPC2 AS INT
	DECLARE @SPC3 AS INT
	DECLARE @SPC4 AS INT
	DECLARE @SPC5 AS INT
	DECLARE @SPC6 AS INT
	DECLARE @GI1 AS INT
	DECLARE @GI2 AS INT
	DECLARE @GR1 AS INT
	DECLARE @GR2 AS INT
	DECLARE @VLU1 AS INT
	DECLARE @VLU2 AS INT
	DECLARE @DISTCODE AS NVARCHAR(30)
	SELECT @DISTCODE=DistributorCode FROM Distributor
	-- SALES INVOICE
	SELECT @SI1=(Select ISNULL(COUNT(salinvno),0) from salesinvoice s1 inner join salesinvoiceproduct s2 on s1.salid=s2.salid where saldlvdate=@DATE and dlvsts<>3)
	SELECT @SI2=(select ISNULL(COUNT(salinvno),0) from salesinvoice s1 inner join salesinvoiceschemedtfreeprd s2 on s1.salid=s2.salid where saldlvdate=@DATE and dlvsts<>3)
	SELECT @SI3=(select ISNULL(SUM(s2.baseqty),0) from salesinvoice s1 inner join salesinvoiceproduct s2 on s1.salid=s2.salid where s1.saldlvdate=@DATE and dlvsts<>3)
	SELECT @SI4=(select ISNULL(SUM(s2.freeqty),0) from salesinvoice s1 inner join salesinvoiceschemedtfreeprd s2 on s1.salid=s2.salid where s1.saldlvdate=@DATE and dlvsts<>3)
	SELECT @SI5=(select ISNULL(COUNT(s2.salmanfreeqty),0) from salesinvoice s1 inner join salesinvoiceproduct s2 on s1.salid=s2.salid where s1.saldlvdate=@DATE and dlvsts<>3 and salmanfreeqty<>0)
	SELECT @SI6=(select ISNULL(SUM(s2.salmanfreeqty),0) from salesinvoice s1 inner join salesinvoiceproduct s2 on s1.salid=s2.salid where s1.saldlvdate=@DATE and dlvsts<>3)
	-- SALES RETURN
	SELECT @RI1=(Select ISNULL(COUNT(returncode),0) from RETURNHEADER R1 inner join returnproduct r2 on r1.returnid=r2.returnid where returndate=@DATE)
	SELECT @RI2=(select ISNULL(COUNT(returncode),0) from returnheader r1 inner join ReturnSchemeFreePrdDt r2 on r1.returnid=r2.returnid where returndate=@DATE)
	SELECT @RI3=(Select ISNULL(sum(r2.baseqty),0) from RETURNHEADER R1 inner join returnproduct r2 on r1.returnid=r2.returnid where returndate=@DATE)
	SELECT @RI4=(select ISNULL(sum(r2.returnfreeqty),0) from returnheader r1 inner join ReturnSchemeFreePrdDt r2 on r1.returnid=r2.returnid where returndate=@DATE)
	-- PURCHASE INVOICE
	SELECT @PI1=(SELECT ISNULL(COUNT(P1.PURRCPTID),0) FROM PURCHASERECEIPT P1 INNER JOIN PURCHASERECEIPTPRODUCT P2 ON P1.PURRCPTID=P2.PURRCPTID WHERE GOODSRCVDDATE=@DATE)
	SELECT @PI2=(SELECT ISNULL(SUM(P2.INVBASEQTY),0) FROM PURCHASERECEIPT P1 INNER JOIN PURCHASERECEIPTPRODUCT P2 ON P1.PURRCPTID=P2.PURRCPTID WHERE GOODSRCVDDATE=@DATE)
	-- PURCHASE RETURN
	SELECT @PR1=(SELECT ISNULL(COUNT(P1.PURRETID),0) FROM PURCHASERETURN P1 INNER JOIN PURCHASERETURNPRODUCT P2 ON P1.PURRETID=P2.PURRETID WHERE PURRETDATE=@DATE)
	SELECT @PR2=(SELECT ISNULL(SUM(P2.RETINVBASEQTY),0) FROM PURCHASERETURN P1 INNER JOIN PURCHASERETURNPRODUCT P2 ON P1.PURRETID=P2.PURRETID WHERE PURRETDATE=@DATE)
	-- PAYMENT
	SELECT @SP1=(SELECT ISNULL(COUNT(R1.INVRCPNO),0) FROM RECEIPT R1 INNER JOIN RECEIPTINVOICE R2 ON R1.INVRCPNO=R2.INVRCPNO WHERE CANCELSTATUS=1 and INVRCPDATE=@DATE)
	SELECT @SP2=(SELECT ISNULL(SUM(R2.SALINVAMT),0) FROM RECEIPT R1 INNER JOIN RECEIPTINVOICE R2 ON R1.INVRCPNO=R2.INVRCPNO WHERE CANCELSTATUS=1 and INVRCPDATE=@DATE)
	-- PAYMENT CANCEL
	SELECT @SPC1=(SELECT ISNULL(COUNT(R1.INVRCPNO),0) FROM RECEIPT R1 INNER JOIN RECEIPTINVOICE R2 ON R1.INVRCPNO=R2.INVRCPNO WHERE R2.INVINSNO IN ((select  chequeno from chequepayment where status = 4 and lastmoddate =@DATE))AND R2.INVRCPMODE IN (3) AND R2.INVINSSTA = 4)
	SELECT @SPC2=(SELECT ISNULL(SUM(R2.SALINVAMT),0) FROM RECEIPT R1 INNER JOIN RECEIPTINVOICE R2 ON R1.INVRCPNO=R2.INVRCPNO WHERE R2.INVINSNO IN ((select  chequeno from chequepayment where status = 4 and lastmoddate =@DATE ))AND R2.INVRCPMODE IN (3) AND R2.INVINSSTA = 4)
	SELECT @SPC3=(SELECT ISNULL(COUNT(R1.INVRCPNO),0) FROM RECEIPT R1 INNER JOIN RECEIPTINVOICE R2 ON R1.INVRCPNO=R2.INVRCPNO WHERE R2.INVRCPNO IN ((select substring(remarks,44,10) from stdvocmaster where remarks like 'Posted From Receipt Cash Discount Reversal%' and vocdate=@DATE))AND R2.INVRCPMODE IN (2) AND R2.CANCELSTATUS = 0)
	SELECT @SPC4=(SELECT ISNULL(SUM(R2.SALINVAMT),0) FROM RECEIPT R1 INNER JOIN RECEIPTINVOICE R2 ON R1.INVRCPNO=R2.INVRCPNO WHERE R2.INVRCPNO IN ((select substring(remarks,44,10) from stdvocmaster where remarks like 'Posted From Receipt Cash Discount Reversal%' and vocdate=@DATE))AND R2.INVRCPMODE IN (2) AND R2.CANCELSTATUS = 0)
	SELECT @SPC5=(SELECT ISNULL(COUNT(R1.INVRCPNO),0) FROM RECEIPT R1 INNER JOIN RECEIPTINVOICE R2 ON R1.INVRCPNO=R2.INVRCPNO WHERE R2.INVRCPNO IN ((select substring(remarks,34,10) from stdvocmaster where remarks like 'Posted From Receipt Cancellation%' and vocdate=@DATE)) AND R2.INVRCPMODE IN (1) AND R2.CANCELSTATUS = 0)
	SELECT @SPC6=(SELECT ISNULL(SUM(R2.SALINVAMT),0) FROM RECEIPT R1 INNER JOIN RECEIPTINVOICE R2 ON R1.INVRCPNO=R2.INVRCPNO WHERE R2.INVRCPNO IN ((select substring(remarks,34,10) from stdvocmaster where remarks like 'Posted From Receipt Cancellation%' and vocdate=@DATE))AND R2.INVRCPMODE IN (1) AND R2.CANCELSTATUS = 0)
	--GOODS ISSUE
	SELECT @GI1=(SELECT ISNULL(COUNT(S1.STKMNGREFNO),0) CNT FROM StockManagement S1
	INNER JOIN STOCKMANAGEMENTPRODUCT S2 ON S1.STKMNGREFNO=S2.STKMNGREFNO
	INNER JOIN STOCKMANAGEMENTTYPE S3 ON S1.STKMGMTTYPEID=S3.STKMGMTTYPEID WHERE STKMNGDATE =@DATE AND S3.TransactionType=1)
	SELECT @GI2=(SELECT ISNULL(SUM(S2.TOTALQTY),0) CNT FROM StockManagement S1
	INNER JOIN STOCKMANAGEMENTPRODUCT S2 ON S1.STKMNGREFNO=S2.STKMNGREFNO
	INNER JOIN STOCKMANAGEMENTTYPE S3 ON S1.STKMGMTTYPEID=S3.STKMGMTTYPEID WHERE STKMNGDATE =@DATE AND S3.TransactionType=1)
	-- GOODS RECEIPT
	SELECT @GR1=(SELECT ISNULL(COUNT(S1.STKMNGREFNO),0) CNT FROM StockManagement S1
	INNER JOIN STOCKMANAGEMENTPRODUCT S2 ON S1.STKMNGREFNO=S2.STKMNGREFNO
	INNER JOIN STOCKMANAGEMENTTYPE S3 ON S1.STKMGMTTYPEID=S3.STKMGMTTYPEID WHERE  STKMNGDATE =@DATE AND S3.TransactionType=0 )
	SELECT @GR2=(SELECT ISNULL(SUM(S2.TOTALQTY),0) CNT FROM StockManagement S1
	INNER JOIN STOCKMANAGEMENTPRODUCT S2 ON S1.STKMNGREFNO=S2.STKMNGREFNO
	INNER JOIN STOCKMANAGEMENTTYPE S3 ON S1.STKMGMTTYPEID=S3.STKMGMTTYPEID WHERE  STKMNGDATE =@DATE AND S3.TransactionType=0 )
	-- VANLOAD UNLOAD
	SELECT @VLU1=(SELECT ISNULL(COUNT(V1.VANLOADREFNO),0) FROM VANLOADUNLOADMASTER V1 INNER JOIN VANLOADUNLOADDETAILS V2 ON V1.VANLOADREFNO=V2.VANLOADREFNO WHERE TRANSFERDATE=@DATE)
	SELECT @VLU2=(SELECT ISNULL(SUM(TRANSQTY),0) FROM VANLOADUNLOADMASTER V1 INNER JOIN VANLOADUNLOADDETAILS V2 ON V1.VANLOADREFNO=V2.VANLOADREFNO WHERE TRANSFERDATE=@DATE)
	--SALES INVOICE(SELECT)
	SELECT @DISTCODE AS DISTCODE,'SALINV' AS TRANSNAME,ISNULL((@SI1+@SI2+@SI5),0) AS LINECNT,ISNULL((@SI3+@SI4+@SI6),0) AS QTYCOUNT
	UNION ALL
	--SALES RETURN(SELECT)
	SELECT @DISTCODE AS DISTCODE,'SALRET'AS TRANSNAME,ISNULL((@RI1+@RI2),0) AS LINECNT,ISNULL((@RI3+@RI4),0) AS QTYCOUNT
	UNION ALL
	--PURCHASE INVOICE(SELECT)
	SELECT @DISTCODE AS DISTCODE,'PURINV'AS TRANSNAME,ISNULL(@PI1,0) AS LINECNT,ISNULL(@PI2,0) AS QTYCOUNT
	UNION ALL
	-- PURCHASE RETURN(SELECT)
	SELECT @DISTCODE AS DISTCODE,'PURRET'AS TRANSNAME,ISNULL(@PR1,0) AS LINECNT,ISNULL(@PR2,0) AS QTYCOUNT
	UNION ALL
	-- PAYMENT(SELECT)
	SELECT @DISTCODE AS DISTCODE,'PAY'AS TRANSNAME,ISNULL(@SP1,0) AS LINECNT,ISNULL(@SP2,0) AS QTYCOUNT
	UNION ALL
	-- PAYMENT CANCEL(SELECT)
	SELECT @DISTCODE AS DISTCODE,'PAY CAL'AS TRANSNAME,ISNULL((@SPC1+@SPC3+@SPC5),0) AS LINECNT,ISNULL((@SPC2+@SPC4+@SPC6),0) AS QTYCOUNT
	UNION ALL
	-- GOODS ISSUE(SELECT)
	SELECT @DISTCODE AS DISTCODE,'GOODSISS'AS TRANSNAME,ISNULL((@GI1),0) AS LINECNT,ISNULL((@GI2),0) AS QTYCOUNT
	UNION ALL
	-- GOODS ISSUE(SELECT)
	SELECT @DISTCODE AS DISTCODE,'GOODSRCD'AS TRANSNAME,ISNULL((@GR1),0) AS LINECNT,ISNULL((@GR2),0) AS QTYCOUNT
	UNION ALL
	-- VAN LOAD UNLOAD(SELECT)
	SELECT @DISTCODE AS DISTCODE,'VAN L/U'AS TRANSNAME,ISNULL((@VLU1),0) AS LINECNT,ISNULL((@VLU2),0) AS QTYCOUNT
	UNION ALL
	-- CREDIT NOTE RETAILER
	SELECT @DISTCODE AS DISTCODE,'CNRET'AS TRANSNAME,COUNT(CRNOTENUMBER),0 FROM CreditNoteRetailer WHERE TRANSID NOT IN (30) AND CRNOTEDATE=@DATE
	UNION ALL
	-- CREDIT NOTE SUPPLIER
	SELECT @DISTCODE AS DISTCODE,'CNSUP'AS TRANSNAME,COUNT(CRNOTENUMBER),0 FROM CreditNoteSupplier WHERE CRNOTEDATE=@DATE
	UNION ALL
	-- DEBIT NOTE RETAILER
	SELECT @DISTCODE AS DISTCODE,'DNRET'AS TRANSNAME,COUNT(DBNOTENUMBER),0 FROM DEBITNoteRetailer WHERE TRANSID NOT IN (11,115) AND DBNOTEDATE=@DATE
	UNION ALL
	-- DEBIT NOTE SUPPLIER
	SELECT @DISTCODE AS DISTCODE,'DNSUP'AS TRANSNAME,COUNT(DBNOTENUMBER),0 FROM DEBITNoteSupplier WHERE TRANSID NOT IN (7) AND DBNOTEDATE=@DATE
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_CreditNotePurchase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_CreditNotePurchase]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_XmlUpload_CreditNotePurchase]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_CreditNotePurchase --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO ETL_XML_CreditNotePurchase
	SELECT @DISTCODE,SpmCode,CrNoteNumber,CONVERT(VARCHAR(10),CrNoteDate,121),AcCode,AcName,Amount,TransId,'N'
	FROM CreditNoteSupplier DB (NOLOCK)
	INNER JOIN COAMaster CM (NOLOCK) ON CM.CoaId=DB.CoaId
	INNER JOIN Supplier S (NOLOCK) ON S.SpmId=DB.SpmId
	WHERE CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DB.XmlUpload=0 AND DB.Status=1 AND TransId IN(32,16)
	ORDER BY CrNoteNumber
	UPDATE A SET XmlUpload=1 FROM CreditNoteSupplier A,ETL_XML_CreditNotePurchase B
	WHERE A.CrNoteNumber=B.CreditNoteNo AND XmlUpload=0 AND UploadFlag='N' AND B.TransId IN(32,16)
	SELECT * FROM ETL_XML_CreditNotePurchase --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_CreditNoteRetailer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_CreditNoteRetailer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_XmlUpload_CreditNoteRetailer]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT = 0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_CreditNoteRetailer
* PURPOSE: Credit Note Retailer XML Upload
* NOTES:
* CREATED: Boopathy.P 03-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_CreditNote_Sales --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_CreditNote_Sales
	(
	DistCode,
	CardCode,
	DocDate,
	AccountCode,
	AccountName,
	CreditNoteNum,
	LineTotal,
	TransId,
	UploadFlag
	)
	SELECT @DistCode,--RtrCode,
	CASE LEN(DB.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(DB.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(DB.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(DB.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(DB.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(DB.RtrId AS VARCHAR(5))) END,
	CONVERT(VARCHAR(10),CrNoteDate,121),AcCode,AcName,CrNoteNumber,ISNULL(Amount,0),TransId,'N'
	FROM CreditNoteRetailer DB (NOLOCK)
	INNER JOIN COAMaster CM (NOLOCK) ON CM.CoaId=DB.CoaId
	INNER JOIN Retailer R (NOLOCK) ON R.RtrId=DB.RtrId
	WHERE CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DB.XmlUpload=0 AND TransId=18
	ORDER BY CrNoteNumber
	UPDATE A SET XmlUpload=1 FROM CreditNoteRetailer A INNER JOIN Etl_Xml_CreditNote_Sales B
	ON A.CrNoteNumber=B.CreditNoteNum WHERE B.UploadFlag='N' AND XmlUpload=0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_Customer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_Customer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [dbo].[Proc_XmlUpload_Customer]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_Customer --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO ETL_XML_Customer  (CardCode,CardName,GroupCode,ClassCode,RtrCde,RtrTINNo,Status,UploadFlag)
	SELECT CASE LEN(R.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(R.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(R.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(R.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(R.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(R.RtrId AS VARCHAR(5))) END, --(@DISTCODE+CAST(R.RtrId AS VARCHAR(20))),
	RtrName,CASE RtrType WHEN 1 THEN 'Retailer' ELSE 'Sub Stockist' END,
	CtgCode,RtrCode,ISNULL(RtrTINNo,0),CASE R.RtrStatus WHEN 1 THEN 'Active' ELSE 'Inactive' END,'N'
	FROM Retailer R (NOLOCK)
	INNER JOIN RetailerValueClassMap RVCM (NOLOCK) ON RVCM.RtrId=R.RtrId
	INNER JOIN RetailerValueClass RVC (NOLOCK) ON RVC.RtrClassId=RVCM.RtrValueClassId
	INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RVC.CtgMainId
	WHERE R.XmlUPload=0
	ORDER BY R.RtrId
	UPDATE A SET XmlUpload=1 FROM Retailer A,ETL_XML_Customer B
	WHERE XmlUpload=0 AND RtrCde=RtrCode AND UploadFlag='N'
	SELECT * FROM ETL_XML_Customer --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_DebitNotePurchase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_DebitNotePurchase]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[Proc_XmlUpload_DebitNotePurchase]
(
@Pi_FromDate  DATETIME,
@Pi_ToDate    DATETIME,
@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_DebitNotePurchase --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO ETL_XML_DebitNotePurchase
	SELECT @DISTCODE,SpmCode,DbNoteNumber,CONVERT(VARCHAR(10),DbNoteDate,121),AcCode,AcName,Amount,TransId,'N'
	FROM DebitNoteSupplier DB (NOLOCK)
	INNER JOIN COAMaster CM (NOLOCK) ON CM.CoaId=DB.CoaId
	INNER JOIN Supplier S (NOLOCK) ON S.SpmId=DB.SpmId
	WHERE DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DB.XmlUpload=0 AND DB.Status=1 AND TransId IN(33,16)
	ORDER BY DbNoteNumber
	UPDATE A SET XmlUpload=1 FROM DebitNoteSupplier A,ETL_XML_DebitNotePurchase B
	WHERE A.DbNoteNumber=B.DebitNoteNo AND XmlUpload=0 AND UploadFlag='N' AND B.TransId IN(33,16)
	SELECT * FROM ETL_XML_DebitNotePurchase --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_DebitNoteRetailer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_DebitNoteRetailer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_XmlUpload_DebitNoteRetailer]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_DebitNoteRetailer
* PURPOSE: Debit Note Retailer XML Upload
* NOTES:
* CREATED: Boopathy.P 03-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_DebitNote_Sales --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_DebitNote_Sales
	(
	DistCode,
	CardCode,
	DocDate,
	AccountCode,
	AccountName,
	DebitNoteNum,
	LineTotal,
	TransId,
	UploadFlag
	)
	SELECT @DistCode,--RtrCode,
	CASE LEN(DB.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(DB.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(DB.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(DB.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(DB.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(DB.RtrId AS VARCHAR(5))) END,
	CONVERT(VARCHAR(10),DbNoteDate,121),AcCode,AcName,DbNoteNumber,ISNULL(Amount,0),TransId,'N'
	FROM DebitNoteRetailer DB (NOLOCK)
	INNER JOIN COAMaster CM (NOLOCK) ON CM.CoaId=DB.CoaId
	INNER JOIN Retailer R (NOLOCK) ON R.RtrId=DB.RtrId
	WHERE DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DB.XmlUpload=0  AND DB.TransId=19
	ORDER BY DbNoteNumber
	UPDATE A SET XmlUpload=1 FROM DebitNoteRetailer A INNER JOIN Etl_Xml_DebitNote_Sales B
	ON A.DbNoteNumber=B.DebitNoteNum WHERE B.UploadFlag='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_GoodsIssue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_GoodsIssue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_XmlUpload_GoodsIssue]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_GoodsIssue --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO ETL_XML_GoodsIssue
	SELECT @DISTCODE,CONVERT(VARCHAR(10),StkMngDate,121),CmpBatCode,TotalQty,PrdCCode,PBD.PrdBatDetailValue,A.StkMngRefNo,
	Remarks,[Description],CASE OpenBal WHEN 0 THEN 'Stock Management' ELSE 'Opening Stock' END,UserStockType,'N'
	FROM StockManagement A (NOLOCK)
	INNER JOIN StockManagementProduct B (NOLOCK) ON B.StkMngRefNo=A.StkMngRefNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=B.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=B.PrdId AND PB.PrdBatId=B.PrdBatId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PB.PrdBatId AND PBD.BatchSeqId=PB.BatchSeqId AND PBD.PriceId=PB.DefaultPriceId AND PBD.SlNo=2
	INNER JOIN StockManagementType SMT (NOLOCK) ON SMT.StkMgmtTypeId=A.StkMgmtTypeId AND SMT.TransactionType=1  -- Stock OUT
	INNER JOIN StockType ST (NOLOCK) ON ST.StockTypeId=B.StockTypeId
	WHERE StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.XmlUpload=0 AND A.Status=1 AND PB.Status=1
	ORDER BY A.StkMngRefNo
	UPDATE A SET XmlUpload=1 FROM StockManagement A, ETL_XML_GoodsIssue B
	WHERE XmlUpload=0 AND UploadFlag='N' AND A.StkMngRefNo=B.StockyDocNo
	SELECT * FROM ETL_XML_GoodsIssue --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_GoodsReceipt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_GoodsReceipt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [dbo].[Proc_XmlUpload_GoodsReceipt]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_GoodsReceipt --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO ETL_XML_GoodsReceipt
	SELECT @DISTCODE,CONVERT(VARCHAR(10),StkMngDate,121),CmpBatCode,TotalQty,PrdCCode,PBD2.PrdBatDetailValue,
	LcnCode,A.StkMngRefNo,PrdBatCode,Remarks,[Description],CASE OpenBal WHEN 0 THEN 'Stock Management' ELSE 'Opening Stock' END,UserStockType,
	CONVERT(VARCHAR(10),ExpDate,121),CmpBatCode,CONVERT(VARCHAR(10),MnfDate,121),PrdDCode,PBD3.PriceCode,PrdGroup,
	CASE PB.Status WHEN 1 THEN 'Active' ELSE 'Inactive' END,BCM.RefCode,
	PBD1.PrdBatDetailValue,PBD2.PrdBatDetailValue,
	-- edited by ram for primery disc amt as on 30 11 2010 --
	(PBD2.PrdBatDetailValue-(PBD2.PrdBatDetailValue/(1+(PBD3.PrdBatDetailValue/100))))*TotalQty,
	-- edited by ram for primery disc amt as on 30 11 2010 --
	PBD4.PrdBatDetailValue,PBD5.PrdBatDetailValue,'N'
	FROM StockManagement A (NOLOCK)
	INNER JOIN StockManagementProduct B (NOLOCK) ON B.StkMngRefNo=A.StkMngRefNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=B.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=B.PrdId AND PB.PrdBatId=B.PrdBatId
	INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatId=PB.PrdBatId AND PBD1.BatchSeqId=PB.BatchSeqId AND PBD1.SlNo=1 AND PBD1.PriceId=PB.DefaultPriceId
	INNER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=PB.TaxGroupId
	INNER JOIN BatchCreationMaster BCM (NOLOCK) ON BCM.BatchSeqId=PB.BatchSeqId
	INNER JOIN BatchCreation BC (NOLOCK) ON BC.SlNo=PBD1.SlNo AND BC.BatchSeqId=BCM.BatchSeqId AND BC.BatchSeqId=PB.BatchSeqId
	INNER JOIN ProductBatchDetails PBD2 (NOLOCK) ON PBD2.PrdBatId=PB.PrdBatId AND PBD2.BatchSeqId=PB.BatchSeqId AND PBD2.SlNo=2 AND PBD2.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD3 (NOLOCK) ON PBD3.PrdBatId=PB.PrdBatId AND PBD3.BatchSeqId=PB.BatchSeqId AND PBD3.SlNo=3 AND PBD3.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD4 (NOLOCK) ON PBD4.PrdBatId=PB.PrdBatId AND PBD4.BatchSeqId=PB.BatchSeqId AND PBD4.SlNo=4 AND PBD4.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD5 (NOLOCK) ON PBD5.PrdBatId=PB.PrdBatId AND PBD5.BatchSeqId=PB.BatchSeqId AND PBD5.SlNo=5 AND PBD5.PriceId=PB.DefaultPriceId
	INNER JOIN StockManagementType SMT (NOLOCK) ON SMT.StkMgmtTypeId=A.StkMgmtTypeId AND SMT.TransactionType=0  -- Stock IN
	INNER JOIN StockType ST (NOLOCK) ON ST.StockTypeId=B.StockTypeId
	INNER JOIN Location L (NOLOCK) ON L.LcnId=A.LcnId
	WHERE StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.XmlUpload=0 AND A.Status=1 AND PB.Status=1
	ORDER BY A.StkMngRefNo
	UPDATE A SET XmlUpload=1 FROM StockManagement A, ETL_XML_GoodsReceipt B
	WHERE XmlUpload=0 AND UploadFlag='N' AND A.StkMngRefNo=B.StockyDocNo
	SELECT * FROM ETL_XML_GoodsReceipt --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_PurchaseReceipt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_PurchaseReceipt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_XmlUpload_PurchaseReceipt]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_PurchaseReceipt --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO ETL_XML_PurchaseReceipt  (DistCode,CardCode,DocDate,CompanyInvoiceNo,CompanyInvoiceDate,GRNNumber,TransporterCode,ItemCode,DiscountPercent,Quantity,TaxCode,UnitPrice,BatchCode,ExpiryDate,ManufacturerSerialNumber,ManufacturingDate,ProductCode,
	PriceCode,TaxGroupCode,Status,BatchSequenceCode,MRPPrice,LSPPrice,PrimaryDisc,SellingRate,ClaimRate,UploadFlag)
	SELECT @DISTCODE,SpmCode,CONVERT(VARCHAR(10),GoodsRcvdDate,121),CmpInvNo,CONVERT(VARCHAR(10),InvDate,121),
	PurRcptRefNo,TransporterCode,PrdCCode,--PBD.PrdBatDetailValue
	ISNULL(PRP.PrdDiscount,0),InvBaseQty,PrdGroup,ISNULL(PrdLSP,0),
	PrdBatCode,CONVERT(VARCHAR(10),ExpDate,121),CmpBatCode,CONVERT(VARCHAR(10),MnfDate,121),PrdCCode,PBD.PriceCode,PrdGroup,
	CASE PB.Status WHEN 1 THEN 'Active' ELSE 'Inactive' END,BCM.RefCode,
	PBD1.PrdBatDetailValue,PBD2.PrdBatDetailValue,PBD.PrdBatDetailValue,PBD3.PrdBatDetailValue,PBD4.PrdBatDetailValue,'N'
	FROM PurchaseReceipt PR (NOLOCK)
	INNER JOIN PurchaseReceiptProduct PRP (NOLOCK) ON PRP.PurRcptId=PR.PurRcptId
	INNER JOIN Supplier S (NOLOCK) ON S.SpmId=PR.SpmId
	INNER JOIN Transporter T (NOLOCK) ON T.TransporterId=PR.TransporterId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=PRP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=PRP.PrdId AND PB.PrdBatId=PRP.PrdBatId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PRP.PrdBatId AND PBD.SlNo=3 AND PBD.PriceId=PRP.Priceid --PBD.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatId=PRP.PrdBatId AND PBD1.SlNo=1 AND PBD1.PriceId=PRP.Priceid --PBD1.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD2 (NOLOCK) ON PBD2.PrdBatId=PRP.PrdBatId AND PBD2.SlNo=2 AND PBD2.PriceId=PRP.Priceid --PBD2.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD3 (NOLOCK) ON PBD3.PrdBatId=PRP.PrdBatId AND PBD3.SlNo=4 AND PBD3.PriceId=PRP.Priceid --PBD3.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD4 (NOLOCK) ON PBD4.PrdBatId=PRP.PrdBatId AND PBD4.SlNo=5 AND PBD4.PriceId=PRP.Priceid --PBD4.PriceId=PB.DefaultPriceId
	INNER JOIN BatchCreation BC (NOLOCK) ON BC.SlNo=PBD.SlNo AND BC.BatchSeqId=PBD.BatchSeqId
	INNER JOIN BatchCreationMaster BCM (NOLOCK) ON BCM.BatchSeqId=BC.BatchSeqId
	INNER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=PB.TaxGroupId
	WHERE GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PR.XmlUpload=0 AND PR.Status=1 AND PB.Status=1
	ORDER BY PR.PurRcptId
	UPDATE A SET XmlUpload=1 FROM PurchaseReceipt A, ETL_XML_PurchaseReceipt B
	WHERE XmlUpload=0 AND UploadFlag='N' AND A.PurRcptRefNo=B.GRNNumber
	SELECT * FROM ETL_XML_PurchaseReceipt --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_PurchaseReturn]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_PurchaseReturn]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[Proc_XmlUpload_PurchaseReturn]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_PurchaseReturn --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO Etl_Xml_PurchaseReturn(DistCode,DocDate,PurchaseReturnNo,GRNNumber,ItemCode,DiscountPercent,Quantity,TaxCode,UnitPrice,BatchCode,DebitNoteNo,UploadFlag)
	SELECT @DISTCODE,CONVERT(VARCHAR(10),PurRetDate,121),PurRetRefNo,
	ISNULL(PRC.PurRcptRefNo,'') PurRcptRefNo,PrdCCode,ISNULL(PRP.PrdDiscount,0),--PBD.PrdBatDetailValue,
	RetInvBaseQty,PrdGroup,PBD1.PrdBatDetailValue,CmpBatCode,ISNULL(DBN.DBNOTENUMBER,''),'N'
	FROM PurchaseReturn PR (NOLOCK)
	INNER JOIN PurchaseReturnProduct PRP (NOLOCK) ON PRP.PurRetId=PR.PurRetId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=PRP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=PRP.PrdId AND PB.PrdBatId=PRP.PrdBatId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.SlNo=3 AND PBD.PrdBatId=PB.PrdBatId AND PBD.BatchSeqId=PB.BatchSeqId AND PBD.Priceid=PRP.Priceid--PBD.PriceId=PB.DefaultPriceId
	INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.SlNo=2 AND PBD1.PrdBatId=PB.PrdBatId AND PBD1.BatchSeqId=PB.BatchSeqId AND PBD1.Priceid=PRP.Priceid --PBD1.PriceId=PB.DefaultPriceId
	INNER JOIN TaxGroupSetting T (NOLOCK) ON T.TaxGroupId=PB.TaxGroupId
	LEFT OUTER JOIN PurchaseReceipt PRC (NOLOCK) ON PRC.PurRcptId=PR.PurRcptId
	INNER JOIN DEBITNOTESUPPLIER DBN ON DBN.POSTEDFROM=PR.PURRETREFNO
	WHERE PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PR.XmlUpload=0 AND PR.Status=1 AND PB.Status=1
	ORDER BY PR.PurRetId
	UPDATE A SET XmlUpload=1 FROM PurchaseReturn A, Etl_Xml_PurchaseReturn B
	WHERE XmlUpload=0 AND UploadFlag='N' AND A.PurRetRefNo=B.PurchaseReturnNo
	SELECT * FROM Etl_Xml_PurchaseReturn --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_RouteMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_RouteMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_XmlUpload_RouteMaster]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT = 0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_RouteMaster
* PURPOSE: Route Master XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_RouteMaster --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_RouteMaster
	(
	DistCode,
	RouteCode,
	RouteName,
	Distance,
	Population,
	GeoLevel,
	GeoLevelValue,
	VanRoute,
	RouteType,
	LocalUpCountry,
	Monday,
	Tuesday,
	Wednesday,
	Thursday,
	Friday,
	Saturday,
	Sunday,
	UploadFlag
	)
	SELECT @DistCode,ISNULL(A.RMCode,''),ISNULL(A.RMName,''),ISNULL(A.RMDistance,''),ISNULL(A.RMPopulation,''),ISNULL(B.GeoLevelName,''),ISNULL(C.GeoName,''),
	CASE A.RMVanRoute WHEN 1 THEN 'YES' WHEN 0 THEN 'NO' END,
	CASE A.RMSRouteType WHEN 1 THEN 'SALES ROUTE' WHEN 2 THEN 'DELIVERY ROUTE' WHEN 3 THEN 'MERCHANDISING ROUTE' END,
	CASE A.RMLocalUpCountry WHEN 0 THEN 'UPCOUNTRY' WHEN 1 THEN 'LOCAL' END,
	CASE A.RMMon WHEN 1 THEN 'MONDAY' ELSE '' END,
	CASE A.RMTue WHEN 1 THEN 'TUESDAY' ELSE '' END,
	CASE A.RMWed WHEN 1 THEN 'WEDNESDAY' ELSE '' END,
	CASE A.RMThu WHEN 1 THEN 'THURSDAY' ELSE '' END,
	CASE A.RMFri WHEN 1 THEN 'FRIDAY' ELSE '' END,
	CASE A.RMSat WHEN 1 THEN 'SATURDAY' ELSE '' END,
	CASE A.RMSun WHEN 1 THEN 'SUNDAY' ELSE '' END,'N'
	FROM RouteMaster A INNER JOIN GeographyLevel B ON A.GeoMainId=B.GeoLevelId
	INNER JOIN Geography C ON A.GeoMainId=C.GeoMainId
	WHERE A.XmlUpload=0 ORDER BY A.RMId
	UPDATE A SET XmlUpload=1 FROM RouteMaster A INNER JOIN Etl_Xml_RouteMaster B
	ON A.RMCOde=B.RouteCode WHERE A.XmlUpload=0 AND B.UploadFlag='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_Salesinvoice]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_Salesinvoice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_XmlUpload_Salesinvoice]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_SalesInvoice --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	SELECT DistCode,CardCode,SalInvNo,DocDate,ItemCode,Quantity,TaxCode,UnitPrice,BatchNumber,Salesman,OrderBeat,RdyStk,
	BillMode,VechName,SalDlvDate,Location,PrdBatCde,PrimaryDiscount,SecondaryDiscount,SalSchAmt,SalDisAmt,SalRetAmt,
	SalVisAmt,SalDistDis,SalTotDedn,SalRoundOffAmt,dbadjamt,cradjamt,OnAccountAmt,SalReplaceAmt,SalSplDis,SalInvSch,
	SalInvDist,SalCshDis,UPloadFlag INTO #Temp_ETL_XML_SalesInvoice FROM ETL_XML_SalesInvoice WHERE 1=2
	--####Query modified by Premkumar on Scheme calculation on 10th Sep 2010#####
	INSERT INTO #Temp_ETL_XML_SalesInvoice (DistCode,CardCode,SalInvNo,DocDate,ItemCode,Quantity,TaxCode,UnitPrice,BatchNumber,Salesman,OrderBeat,RdyStk,BillMode,VechName,SalDlvDate,Location,PrdBatCde,PrimaryDiscount,SecondaryDiscount,SalSchAmt,
	SalDisAmt,SalRetAmt,SalVisAmt,SalDistDis,SalTotDedn,SalRoundOffAmt,dbadjamt,cradjamt,OnAccountAmt,SalReplaceAmt,SalSplDis,SalInvSch,SalInvDist,SalCshDis,UPloadFlag)
	SELECT @DISTCODE,CASE LEN(SI.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(SI.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(SI.RtrId AS VARCHAR(5))) END, -- @DISTCODE+CAST(SI.RtrId AS NVARCHAR(10)),
	SalInvNo,CONVERT(VARCHAR(10),SalInvDate,121),PrdCCode,
	SIP.BaseQty,PrdGroup,PrdUnitSelRate,CmpBatCode,@DISTCODE+SMCode,RM.RMCode,
	CASE BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END,
	BillMode,ISNULL(VehicleCode,''),CONVERT(VARCHAR(10),SalDlvDate,121),--RM1.RMCode,
	CASE SI.LCNID WHEN 1 THEN 'MAIN GODOWN' ELSE 'VAN' END,PrdBatCode,
	ISNULL(SIP.PrimarySchemeAmt,0), ISNULL((PrdSchDiscAmount-PrimarySchemeAmt),0),
	--ISNULL(SISLW.PrimarySchemeAmt,0),ISNULL((FlatAmount+DiscountPerAmount),0),
	ISNULL(SalSchDiscAmount,0),ISNULL(SalCDAmount,0),ISNULL(MarketRetAmount,0),ISNULL(WindowDisplayAmount,0),
	ISNULL(SalDBDiscAmount,0),ISNULL(TotalDeduction,0),ISNULL(SalRoundOffAmt,0),ISNULL(DBAdjAmount,0),ISNULL(CRAdjAmount,0),
	ISNULL(OnAccountAmount,0),ISNULL(ReplacementDiffAmount,0),
	ISNULL(PrdSplDiscAmount,0),ISNULL(PrdSchDiscAmount,0),ISNULL(PrdDBDiscAmount,0),ISNULL(PrdCDAmount,0),'N'
	FROM SalesInvoice SI (NOLOCK)
	INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SI.SalId=SIP.SalId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdBatId=SIP.PrdBatId
	INNER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=PB.TaxGroupId
	INNER JOIN Salesman S (NOLOCK) ON S.SMId=SI.SMId
	INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=SI.RMId
	INNER JOIN DeliveryBoy DB (NOLOCK) ON DB.DlvBoyId=SI.DlvBoyId
	LEFT OUTER JOIN Vehicle V (NOLOCK) ON V.VehicleId=SI.VehicleId
	INNER JOIN Retailer R (NOLOCK) ON R.RtrId=SI.RtrId
	INNER JOIN RouteMaster RM1 (NOLOCK)ON RM1.RMId=SI.DlvRMId
	-- LEFT OUTER JOIN SalesInvoiceSchemeLineWise SISLW (NOLOCK) ON SISLW.SalId=SIP.SalId AND SISLW.PrdId=SIP.PrdId AND SISLW.PrdBatId=SIP.PrdBatId
	WHERE SalDlvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--AND PB.Status=1
	AND SI.XmlUPload=0  AND SI.DLVSTS not in (1,2,3)
	--  ORDER BY SI.SalId
	UNION ALL
	SELECT @DISTCODE,CASE LEN(SI.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(SI.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(SI.RtrId AS VARCHAR(5))) END, -- @DISTCODE+CAST(SI.RtrId AS NVARCHAR(10)),
	SalInvNo,CONVERT(VARCHAR(10),SalInvDate,121),PrdCCode,
	SIP.SalManFreeQty,PrdGroup,0,CmpBatCode,@DISTCODE+SMCode,RM.RMCode,CASE BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END,
	BillMode,ISNULL(VehicleCode,''),CONVERT(VARCHAR(10),SalDlvDate,121),--RM1.RMCode,
	CASE SI.LCNID WHEN 1 THEN 'MAIN GODOWN' ELSE 'VAN' END,
	PrdBatCode,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,'N'
	FROM SalesInvoice SI (NOLOCK)
	INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SI.SalId=SIP.SalId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdBatId=SIP.PrdBatId
	INNER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=PB.TaxGroupId
	INNER JOIN Salesman S (NOLOCK) ON S.SMId=SI.SMId
	INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=SI.RMId
	INNER JOIN DeliveryBoy DB (NOLOCK) ON DB.DlvBoyId=SI.DlvBoyId
	LEFT OUTER JOIN Vehicle V (NOLOCK) ON V.VehicleId=SI.VehicleId
	INNER JOIN Retailer R (NOLOCK) ON R.RtrId=SI.RtrId
	INNER JOIN RouteMaster RM1 (NOLOCK)ON RM1.RMId=SI.DlvRMId
	WHERE SalDlvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--AND PB.Status=1
	AND SI.XmlUPload=0 AND SIP.SalManFreeQty>0 AND SI.DLVSTS not in (1,2,3)
	--  ORDER BY SI.SalId
	UNION ALL
	SELECT @DISTCODE,CASE LEN(SI.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(SI.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(SI.RtrId AS VARCHAR(5))) END, -- @DISTCODE+CAST(SI.RtrId AS NVARCHAR(10)),
	SalInvNo,CONVERT(VARCHAR(10),SalInvDate,121),PrdCCode,
	SIFP.FreeQty,PrdGroup,0,CmpBatCode,@DISTCODE+SMCode,RM.RMCode,CASE BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END,
	BillMode,ISNULL(VehicleCode,''),CONVERT(VARCHAR(10),SalDlvDate,121),--RM1.RMCode,
	CASE SI.LCNID WHEN 1 THEN 'MAIN GODOWN' ELSE 'VAN' END,
	PrdBatCode,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,'N'
	FROM SalesInvoice SI (NOLOCK)
	INNER JOIN SalesInvoiceSchemeHd SIS (NOLOCK) ON SIS.SalId=SI.SalId
	--INNER JOIN SalesInvoiceSchemeFlexiDt SIF (NOLOCK) ON SIF.SalId=SIS.SalId AND SIF.SchId=SIS.SchId AND SIF.SlabId=SIS.SlabId
	INNER JOIN SalesInvoiceSchemeDtFreePrd SIFP (NOLOCK) ON SIFP.SalId=SIS.SalId AND SIFP.SchId=SIS.SchId AND SIFP.SlabId=SIS.SlabId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=SIFP.FreePrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdBatId=SIFP.FreePrdBatId
	INNER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=PB.TaxGroupId
	INNER JOIN Salesman S (NOLOCK) ON S.SMId=SI.SMId
	INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=SI.RMId
	INNER JOIN DeliveryBoy DB (NOLOCK) ON DB.DlvBoyId=SI.DlvBoyId
	LEFT OUTER JOIN Vehicle V (NOLOCK) ON V.VehicleId=SI.VehicleId
	INNER JOIN Retailer R (NOLOCK) ON R.RtrId=SI.RtrId
	INNER JOIN RouteMaster RM1 (NOLOCK)ON RM1.RMId=SI.DlvRMId
	WHERE SalDlvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--AND PB.Status=1
	AND SI.XmlUPload=0 AND SI.DLVSTS not in (1,2,3)
	--  ORDER BY SI.SalId
	INSERT INTO ETL_XML_SalesInvoice  (DistCode,CardCode,SalInvNo,DocDate,ItemCode,Quantity,TaxCode,UnitPrice,BatchNumber,Salesman,OrderBeat,RdyStk,BillMode,VechName,SalDlvDate,Location,PrdBatCde,PrimaryDiscount,SecondaryDiscount,SalSchAmt,SalDisAmt,
	SalRetAmt,SalVisAmt,SalDistDis,SalTotDedn,SalRoundOffAmt,dbadjamt,cradjamt,OnAccountAmt,SalReplaceAmt,SalSplDis,SalInvSch,SalInvDist,SalCshDis,UPloadFlag)
	SELECT * FROM #Temp_ETL_XML_SalesInvoice ORDER BY SalInvNo
	UPDATE A SET XmlUpload=1 FROM SalesInvoice A, ETL_XML_SalesInvoice B
	WHERE XmlUpload=0 AND UploadFlag='N' AND A.SalInvNo=B.SalInvNo
	SELECT * FROM ETL_XML_SalesInvoice --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SalesInvoiceScheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SalesInvoiceScheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_XmlUpload_SalesInvoiceScheme]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_SalesInvoiceScheme --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	--####Query modified by Ramkumar on Scheme calculation on 10th Sep 2010#####
	INSERT INTO ETL_XML_SalesInvoiceScheme (DistCode,CardCode,SalInvNo,DocDate,ItemCode,BatchNumber,Quantity,Company_Scheme_Code,SchemeDisAmount,SchemeSlabID,UploadFlag)
	SELECT @DISTCODE,CASE LEN(SI.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(SI.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(SI.RtrId AS VARCHAR(5))) END, -- @DISTCODE+CAST(SI.RtrId AS NVARCHAR(10)),
	SalInvNo,CONVERT(VARCHAR(10),SalInvDate,121),PrdCCode,
	CmpBatCode,SIP.BaseQty,CmpSchCode,
	--ISNULL((FlatAmount+DiscountPerAmount),0),
	ISNULL(((SISLW.FlatAmount+SISLW.discountperamount)- SISLW.primaryschemeamt),0),
	SISLW.SlabId,'N'
	FROM SalesInvoice SI (NOLOCK)
	INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SI.SalId=SIP.SalId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdBatId=SIP.PrdBatId
	INNER JOIN SalesInvoiceSchemeLineWise SISLW (NOLOCK) ON SISLW.SalId=SI.SalId
	AND SIP.PrdId=SISLW.PrdId AND SIP.PrdBatId=SISLW.PrdBatId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SM.SchId=SISLW.SchId
	WHERE SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND PB.Status=1 --AND SI.XmlUPload=0
	ORDER BY SI.SalId
	-- UPDATE A SET XmlUpload=1 FROM SalesInvoice A, ETL_XML_SalesInvoiceScheme B
	-- WHERE XmlUpload=0 AND UploadFlag='N' AND A.SalInvNo=B.SalInvNo
	SELECT * FROM ETL_XML_SalesInvoiceScheme  WHERE DocDate BETWEEN @Pi_FromDate AND @Pi_ToDate   --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SalesManMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SalesManMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_XmlUpload_SalesManMaster]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT = 0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_SalesManMaster
* PURPOSE: Salesman master XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SalesManMaster --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_SalesManMaster
	(
	DistCode,
	SalesmanCode,
	SalesmanName,
	Status,
	RouteCode,
	UploadFlag
	)
	SELECT @DistCode,A.SMCode,A.SMName, CASE A.Status WHEN 1 THEN 'ACTIVE' ELSE 'INACTIVE' END,C.RMCODE,'N'
	FROM SalesMan A LEFT OUTER JOIN SalesManMarket B ON A.SMID=B.SMID LEFT OUTER JOIN RouteMaster C
	ON B.RMID=C.RMID WHERE A.XmlUpLoad=0
	ORDER BY A.SMID
	UPDATE A SET XmlUpload=1 FROM SalesMan A INNER JOIN Etl_Xml_SalesManMaster B
	ON A.SMCode=B.SalesmanCode WHERE A.XmlUpload=0 AND B.UploadFlag='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SalesPayment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SalesPayment]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_XmlUpload_SalesPayment]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT =0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_SalesPayment
* PURPOSE:  Sales Payment XML Upload
* NOTES:
* CREATED: Boopathy.P 03-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SalesPayment --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_SalesPayment
	(
	DistCode,
	DocDate,
	CardCode,
	Cardname,
	[Receipt No],
	BillNo,
	SalInvdate,
	PaymentMode,
	PaidSum,
	[Debit/Credit No],
	[Debit/Credit Date],
	[Debit/Credit Amount],
	ChequeNumber,
	[Cheque Date],
	BankName,
	BankBranch,
	[Sales Man],
	[Collected By],
	Route,
	UploadFlag
	)
	SELECT @DistCode,CONVERT(VARCHAR(10),R.InvRcpDate,121),
	CASE LEN(RT.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(RT.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(RT.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(RT.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(RT.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(RT.RtrId AS VARCHAR(5))) END, RT.RTRNAME,A.INVRCPNO,ISNULL(SI.SALINVNO,''),ISNULL(CONVERT(VARCHAR(10),SI.SALINVDATE,121),''),
	A.INVRCPMODE,
	CASE A.INVRCPMODE WHEN 5 THEN ISNULL(B.ADJAMOUNT,0)WHEN 6 THEN ISNULL(B.ADJAMOUNT,0) ELSE A.SALINVAMT END,
	ISNULL(NOTENO,''),
	Case A.INVRCPMODE
	WHEN 5 THEN ISNULL(CONVERT(VARCHAR(10),C.CRNOTEDATE,121),'') WHEN 6 THEN ISNULL(CONVERT(VARCHAR(10),DN.DBNOTEDATE,121),'') ELSE '' END,ISNULL(B.ADJAMOUNT,0),
	ISNULL(A.INVINSNO,0),ISNULL(CONVERT(VARCHAR(10),A.INVINSDATE,121),''),ISNULL(BK.BnkName,''),ISNULL(BKB.BnkBrName,''),
	ISNULL(SM.SmName,''),Case R.CollectedMode
	WHEN 1 THEN 'SALESMAN' WHEN 2 THEN 'DELIVERY BOY' ELSE '' END,ISNULL(E.RmName,''),'N'
	FROM RECEIPTINVOICE A
	INNER JOIN RECEIPT R ON A.INVRCPNO = R.INVRCPNO
	INNER JOIN SALESINVOICE SI ON A.SALID = SI.SALID
	INNER JOIN RETAILER RT ON SI.RTRID = RT.RTRID
	INNER JOIN SalesMan SM ON SM.SmId=SI.SmId
	INNER JOIN RouteMaster E ON SI.RMID=E.RMID
	left outer join CrdbNoteAdjustment b on a.salid = b.salid and a.invrcpmode = b.adjmode  and r.invrcpdate = b.lastmoddate  and a.invrcpno = b.invrcpno --and a.invrcpmode in (5,6)
	left outer join creditnoteretailer c on b.noteno = c.crnotenumber --and r.invrcpdate = c.crnotedate
	left outer join debitnoteretailer dn on b.noteno = dn.dbnotenumber
	LEFT OUTER JOIN BANK BK ON BK.BnkId=A.DisBnkId
	LEFT OUTER JOIN BANKBRANCH BKB ON BKB.BnkBrId=A.DisBnkBrId
	WHERE A.XmlUpload=0 AND R.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	-- where a.invrcpno in ('RCP1020106','RCP1019524','RCP1018866','RCP1020158')
	ORDER BY A.INVRCPNO,SI.SALINVNO,INVRCPMODE
	/* SELECT @DistCode,CONVERT(VARCHAR(10),C.InvRcpDate,121),
	CASE LEN(A.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(A.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(A.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(A.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(A.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(A.RtrId AS VARCHAR(5))) END, --@DistCode+CAST(A.RtrId AS VARCHAR(25)),
	CASE B.InvRcpMode WHEN 2 THEN SUM(B.SalInvAmt) ELSE 0 END,
	SUM(B.SalInvAmt),CASE B.InvRcpMode WHEN 1 THEN SUM(B.SalInvAmt) ELSE 0 END,
	CASE B.InvRcpMode WHEN 3 THEN SUM(B.SalInvAmt) ELSE 0 END,
	CASE B.InvRcpMode WHEN 3 THEN B.InvInsNo ELSE 0 END,
	B.InvRcpNo,CONVERT(VARCHAR(10),C.InvRcpDate,121),D.SmName,Case C.CollectedMode
	WHEN 1 THEN 'SALESMAN' WHEN 2 THEN 'DELIVERY BOY' ELSE '' END,E.RmName,A.SalInvNo,
	CASE B.InvRcpMode WHEN 3 THEN ISNULL(F.BnkName,'') ELSE '' END,
	CASE B.InvRcpMode WHEN 3 THEN ISNULL(G.BnkBrName,'') ELSE '' END,
	CASE B.InvRcpMode WHEN 5 THEN ISNULL(I.CrNoteNumber,'')  WHEN 6 THEN ISNULL(J.DbNoteNumber,'') ELSE '' END,
	CASE B.InvRcpMode WHEN 5 THEN CONVERT(VARCHAR(10),I.CrNoteDate,121) WHEN 6 THEN CONVERT(VARCHAR(10),J.DbNoteDate,121) ELSE '' END,
	CASE B.InvRcpMode WHEN 5 THEN ISNULL(I.Amount,0)  WHEN 6 THEN ISNULL(J.Amount,0) ELSE 0 END,'N'
	FROM ReceiptInvoice B INNER JOIN SalesInvoice A ON A.SalId=B.SalId
	INNER JOIN Receipt C ON B.InvRcpNo=C.InvRcpNo
	INNER JOIN SalesMan D ON D.SmId=A.SmId
	INNER JOIN RouteMaster E ON A.RMID=E.RMID
	LEFT OUTER JOIN BANK F ON F.BnkId=B.BnkId
	LEFT OUTER JOIN BANKBRANCH G ON G.BnkBrId=B.BnkBrId
	LEFT OUTER JOIN CrdbNoteAdjustment H ON H.InvRcpNo=B.InvRcpNo AND B.SalId=H.SalId
	LEFT OUTER JOIN dbo.CreditNoteRetailer I ON H.NoteNo=I.CrNoteNumber
	LEFT OUTER JOIN dbo.DebitNoteRetailer J ON H.NoteNo=J.DbNoteNumber
	WHERE B.XmlUpload=0 AND C.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY A.SalInvNo,B.InvRcpMode,B.InvRcpNo,C.InvRcpDate,B.InvInsNo,A.RtrId,D.SmName,
	C.CollectedMode,E.RmName,F.BnkName,G.BnkBrName,I.CrNoteNumber,I.CrNoteDate,I.Amount,J.DbNoteNumber,
	J.DbNoteDate,J.Amount    */
	UPDATE A SET XmlUpload=1 FROM ReceiptInvoice A INNER JOIN Etl_Xml_SalesPayment B
	ON A.InvRcpNo=B.[Receipt No] WHERE A.XmlUpload=0 AND B.UploadFlag='N'
	SELECT * FROM Etl_Xml_SalesPayment
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SalesPaymentCancellation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SalesPaymentCancellation]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[Proc_XmlUpload_SalesPaymentCancellation]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT=0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_SalesPaymentCancellation
* PURPOSE:  Sales Payment Cancellation XML Upload
* NOTES:
* CREATED: Boopathy.P 03-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SalesPaymentCancellation --WHERE UploadFlag='Y'
	-- TRUNCATE TABLE Etl_Xml_SalesPaymentCancellation
	SELECT DistCode,CardCode,PaymentReceiptNo,PaymentReceiptDate,InvoiceNo,PaymentMode,
	PaidSum,Penalty,DebitNoteNo,UploadFlag INTO #Temp_Etl_Xml_SalesPaymentCancellation
	FROM Etl_Xml_SalesPaymentCancellation WHERE 1=2
	------------- Alter By Ram As On 14/08/2010 ---------------------
	--Cash
	INSERT INTO #Temp_Etl_Xml_SalesPaymentCancellation
	(
	DistCode,
	CardCode,
	PaymentReceiptNo,
	PaymentReceiptDate,
	InvoiceNo,
	PaymentMode,
	PaidSum,
	Penalty,
	DebitNoteNo,
	UploadFlag
	)
	/* SELECT @DistCode AS DISTCODE,CASE LEN(B.RtrId) WHEN 1 THEN (@DistCode+'0000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DistCode+'000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DistCode+'00'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DistCode+'0'+CAST(B.RtrId AS VARCHAR(5)))
	ELSE (@DistCode+CAST(B.RtrId AS VARCHAR(5))) END as rtrid,
	A.INVRCPNO,CONVERT(VARCHAR(10),C.InvRcpDate,121) AS RECEIPTDATE,B.SalinvNo,A.INVRCPMODE,A.SALINVAMT,
	0,'','N' AS UPLOADFLG FROM RECEIPT C
	INNER JOIN RECEIPTINVOICE A ON A.INVRCPNO=C.INVRCPNO AND A.INVRCPMODE IN (1,2) AND A.CANCELSTATUS = 0
	INNER JOIN SALESINVOICE B ON A.SALID=B.SALID
	WHERE A.CancelUpload=0 AND C.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	-- WHERE C.INVRCPNO IN ('RCP1019725','RCP1020165','RCP1019700')  */
	SELECT @DistCode AS DISTCODE,CASE LEN(B.RtrId) WHEN 1 THEN (@DistCode+'0000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DistCode+'000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DistCode+'00'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DistCode+'0'+CAST(B.RtrId AS VARCHAR(5)))
	ELSE (@DistCode+CAST(B.RtrId AS VARCHAR(5))) END as rtrid,
	A.INVRCPNO,ISNULL(CONVERT(VARCHAR(10),C.InvRcpDate,121),'') AS RECEIPTDATE,B.SalinvNo,A.INVRCPMODE,ISNULL(A.SALINVAMT,0),
	0,'','N' AS UPLOADFLG FROM RECEIPT C
	INNER JOIN RECEIPTINVOICE A ON A.INVRCPNO=C.INVRCPNO AND A.INVRCPMODE IN (1) AND A.CANCELSTATUS = 0
	INNER JOIN SALESINVOICE B ON A.SALID=B.SALID
	WHERE A.CancelUpload=0 AND
	A.INVRCPNO in (select substring(remarks,34,10) from stdvocmaster where remarks like 'Posted From Receipt Cancellation%' and vocdate BETWEEN @Pi_FromDate AND @Pi_ToDate )
	--Cash Discount
	INSERT INTO #Temp_Etl_Xml_SalesPaymentCancellation
	(
	DistCode,
	CardCode,
	PaymentReceiptNo,
	PaymentReceiptDate,
	InvoiceNo,
	PaymentMode,
	PaidSum,
	Penalty,
	DebitNoteNo,
	UploadFlag
	)
	/* SELECT @DistCode AS DISTCODE,CASE LEN(B.RtrId) WHEN 1 THEN (@DistCode+'0000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DistCode+'000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DistCode+'00'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DistCode+'0'+CAST(B.RtrId AS VARCHAR(5)))
	ELSE (@DistCode+CAST(B.RtrId AS VARCHAR(5))) END as rtrid,
	A.INVRCPNO,CONVERT(VARCHAR(10),C.InvRcpDate,121) AS RECEIPTDATE,B.SalinvNo,A.INVRCPMODE,A.SALINVAMT,
	0,'','N' AS UPLOADFLG FROM RECEIPT C
	INNER JOIN RECEIPTINVOICE A ON A.INVRCPNO=C.INVRCPNO AND A.INVRCPMODE IN (1,2) AND A.CANCELSTATUS = 0
	INNER JOIN SALESINVOICE B ON A.SALID=B.SALID
	WHERE A.CancelUpload=0 AND C.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	-- WHERE C.INVRCPNO IN ('RCP1019725','RCP1020165','RCP1019700')  */
	SELECT @DistCode AS DISTCODE,CASE LEN(B.RtrId) WHEN 1 THEN (@DistCode+'0000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DistCode+'000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DistCode+'00'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DistCode+'0'+CAST(B.RtrId AS VARCHAR(5)))
	ELSE (@DistCode+CAST(B.RtrId AS VARCHAR(5))) END as rtrid,
	A.INVRCPNO,ISNULL(CONVERT(VARCHAR(10),C.InvRcpDate,121),'') AS RECEIPTDATE,B.SalinvNo,A.INVRCPMODE,ISNULL(A.SALINVAMT,0),
	0,'','N' AS UPLOADFLG FROM RECEIPT C
	INNER JOIN RECEIPTINVOICE A ON A.INVRCPNO=C.INVRCPNO AND A.INVRCPMODE IN (2) AND A.CANCELSTATUS = 0
	INNER JOIN SALESINVOICE B ON A.SALID=B.SALID
	WHERE A.CancelUpload=0 AND
	A.INVRCPNO in (select substring(remarks,44,10) from stdvocmaster where remarks like 'Posted From Receipt Cash Discount Reversal%' and vocdate BETWEEN @Pi_FromDate AND @Pi_ToDate )
	--CHEQUE
	INSERT INTO #Temp_Etl_Xml_SalesPaymentCancellation
	(
	DistCode,
	CardCode,
	PaymentReceiptNo,
	PaymentReceiptDate,
	InvoiceNo,
	PaymentMode,
	PaidSum,
	Penalty,
	DebitNoteNo,
	UploadFlag
	)
	/*SELECT @DistCode AS DISTCODE,CASE LEN(B.RtrId) WHEN 1 THEN (@DistCode+'0000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DistCode+'000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DistCode+'00'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DistCode+'0'+CAST(B.RtrId AS VARCHAR(5)))
	ELSE (@DistCode+CAST(B.RtrId AS VARCHAR(5))) END as rtrid,
	A.INVRCPNO,CONVERT(VARCHAR(10),C.InvRcpDate,121) AS RECEIPTDATE,B.SalinvNo,A.INVRCPMODE,A.SALINVAMT,
	ISNULL(DR.AMOUNT,0),ISNULL(DR.DBNOTENUMBER,''),'N' AS UPLOADFLG FROM RECEIPT C
	INNER JOIN RECEIPTINVOICE A ON A.INVRCPNO=C.INVRCPNO AND A.INVRCPMODE IN (3) AND A.INVINSSTA = 4
	INNER JOIN SALESINVOICE B ON A.SALID=B.SALID
	LEFT JOIN DEBITNOTERETAILER DR ON A.INVRCPNO=DR.POSTEDFROM
	WHERE A.CancelUpload=0 AND C.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	-- WHERE C.INVRCPNO IN ('RCP1019725','RCP1020165','RCP1019700')  */
	SELECT @DistCode AS DISTCODE,CASE LEN(B.RtrId) WHEN 1 THEN (@DistCode+'0000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DistCode+'000'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DistCode+'00'+CAST(B.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DistCode+'0'+CAST(B.RtrId AS VARCHAR(5)))
	ELSE (@DistCode+CAST(B.RtrId AS VARCHAR(5))) END as rtrid,
	A.INVRCPNO,ISNULL(CONVERT(VARCHAR(10),C.InvRcpDate,121),'') AS RECEIPTDATE,B.SalinvNo,A.INVRCPMODE,ISNULL(A.SALINVAMT,0),
	ISNULL(DR.AMOUNT,0),ISNULL(DR.DBNOTENUMBER,''),'N' AS UPLOADFLG FROM RECEIPT C
	INNER JOIN RECEIPTINVOICE A ON A.INVRCPNO=C.INVRCPNO AND A.INVRCPMODE IN (3) AND A.INVINSSTA = 4
	INNER JOIN SALESINVOICE B ON A.SALID=B.SALID
	LEFT JOIN DEBITNOTERETAILER DR ON A.INVRCPNO=DR.POSTEDFROM
	WHERE A.CancelUpload=0 AND
	-- WHERE A.INVRCPNO in  (select invrcpno from receiptinvoice where invinsno in (
	a.invinsno in (
	select  chequeno from chequepayment where status = 4 and lastmoddate BETWEEN @Pi_FromDate AND @Pi_ToDate )
	--and invinssta = 4 and invrcpmode = 3)
	INSERT INTO Etl_Xml_SalesPaymentCancellation (DistCode,CardCode,PaymentReceiptNo,PaymentReceiptDate,InvoiceNo,PaymentMode,PaidSum,Penalty,DebitNoteNo,UploadFlag)
	SELECT * FROM #Temp_Etl_Xml_SalesPaymentCancellation ORDER BY PaymentReceiptNo
	UPDATE A SET CancelUpload=1 FROM ReceiptInvoice A INNER JOIN Etl_Xml_SalesPaymentCancellation B
	ON A.InvRcpNo=B.PaymentReceiptNo WHERE A.CancelUpload=0 AND B.UploadFlag='N'
	Select * FROM Etl_Xml_SalesPaymentCancellation   ---For XML Auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SalesReturn]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SalesReturn]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_XmlUpload_SalesReturn]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	--TRUNCATE TABLE ETL_XML_SalesReturn
	DELETE FROM ETL_XML_SalesReturn --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	SELECT DistCode,DocDate,SalRetNo,SalInvRefNo,ItemCode,Quantity,TaxCode,UnitPrice,BatchNumber,Salesman,OrderBeat,RdyStk,Cardcode,
	CreditNoteNo,SalDlvDate,DeliveryBeat,PrdBatCde,PrimaryDiscount,SecondaryDiscount,SalSchAmt,SalDisAmt,SalRetAmt,SalVisAmt,SalDistDis,
	SalTotDedn,SalRoundOffAmt,dbadjamt,cradjamt,OnAccountAmt,SalReplaceAmt,SalSplDis,SalInvSch,SalInvDist,SalCshDis,UploadFlag
	INTO #Temp_ETL_XML_SalesReturn FROM ETL_XML_SalesReturn WHERE 1=2
	--***Procedure modified by Prem&Ram for Multi scheme & Without reference for Return product on 10th sep 2010*****-----------
	INSERT INTO #Temp_ETL_XML_SalesReturn
	SELECT @DISTCODE,CONVERT(VARCHAR(10),RETURNDATE,121),ReturnCode,ISNULL(SalInvNo,''),
	PrdCCode,RP.BaseQty,ISNULL(PrdGroup,''),ISNULL(PrdUnitSelRte,0),CmpBatCode,(@DISTCODE+SMCode),
	RM.RMCode,CASE BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END,
	CASE LEN(RH.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(RH.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(RH.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(RH.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(RH.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(RH.RtrId AS VARCHAR(5))) END,ISNULL(CNR.CRNOTENUMBER,'') as CreditNoteNo,ISNULL(CONVERT(VARCHAR(10),SalDlvDate,121),''),RM1.RMCode,PrdBatCode,
	-- ISNULL(SISLW.PrimarySchAmt,0),ISNULL((ReturnFlatAmount+ReturnDiscountPerAmount),0),
	ISNULL(RP.PrimarySchAmt,0),ISNULL(SUM(SISLW.RETURNCLAIMAMOUNT),0),
	ISNULL(RtnSchDisAmt,0),ISNULL(RtnCashDisamt,0),0,0,ISNULL(RtnDBDisAmt,0),0,ISNULL(RtnRoundOff,0),
	0,0,0,0,ISNULL(PrdSplDisAmt,0),ISNULL(PrdSchDisAmt,0),ISNULL(PrdDBDisAmt,0),ISNULL(PrdCDDisAmt,0),'N'
	FROM ReturnHeader RH (NOLOCK)
	INNER JOIN ReturnProduct RP (NOLOCK) ON RH.ReturnId=RP.ReturnId
	-- INNER JOIN SalesInvoice SI (NOLOCK) ON SI.SalId=RH.SalId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=RP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdBatId=RP.PrdBatId
	INNER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=PB.TaxGroupId
	INNER JOIN Salesman S (NOLOCK) ON S.SMId=RH.SMId
	INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=RH.RMId
	-- INNER JOIN DeliveryBoy DB (NOLOCK) ON DB.DlvBoyId=SI.DlvBoyId
	-- INNER JOIN Vehicle V (NOLOCK) ON V.VehicleId=SI.VehicleId
	INNER JOIN Retailer R (NOLOCK) ON R.RtrId=RH.RtrId
	INNER JOIN RouteMaster RM1 (NOLOCK)ON RM1.RMId=RH.RMId
	Left Outer JOIN SalesInvoice SI (NOLOCK) ON SI.SalId=RP.SalId
	LEFT OUTER JOIN ReturnSchemeLineDt SISLW (NOLOCK) ON SISLW.ReturnId=RP.ReturnId AND SISLW.PrdId=RP.PrdId AND SISLW.PrdBatId=RP.PrdBatId
	LEFT OUTER JOIN CREDITNOTERETAILER CNR ON CNR.PostedFrom=RH.RETURNCODE
	WHERE ReturnType=2 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--AND PB.Status=1
	AND RH.Status=0
	AND RH.XmlUPload=0
	GROUP BY rh.returnDATE,RH.RETURNCODE,SI.SALINVNO,P.PRDCCODE,TG.PRDGROUP,RP.PrdUnitSelRte,PB.CmpBatCode,S.SMCode,RM.RMCode,SI.BillType,RH.RtrId,SI.SalDlvDate,RM1.RMCode,
	PB.PrdBatCode,RP.PrimarySchAmt,RH.RtnSchDisAmt,RH.RtnCashDisAmt,RH.RtnDBDisAmt,RH.RtnRoundOff,RP.PrdSplDisAmT,RP.PrdSchDisAmt,RP.PrdDBDisAmt,RP.PrdCDDisAmt,RH.ReturnID,RP.BaseQty,CNR.CRNOTENUMBER
	--  ORDER BY RH.ReturnId
	UNION ALL
	--***Procedure modified by Prem&Ram for Multi scheme & Without reference for Free Return product on 10th sep 2010*****-----------
	SELECT @DISTCODE,CONVERT(VARCHAR(10),RETURNDATE,121),ReturnCode,ISNULL(SalInvNo,''),
	PrdCCode,SIFP.ReturnFreeQty,PrdGroup,0,CmpBatCode,(@DISTCODE+SMCode),
	RM.RMCode,CASE BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END,
	CASE LEN(RH.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(RH.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(RH.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(RH.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(RH.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(RH.RtrId AS VARCHAR(5))) END,
	ISNULL(CNR.CRNOTENUMBER,'') as CreditNoteNo,ISNULL(CONVERT(VARCHAR(10),SalDlvDate,121),''),RM1.RMCode,PrdBatCode,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,'N'
	FROM ReturnHeader RH (NOLOCK)
	-- INNER JOIN ReturnSchemeFlexiDt SIF (NOLOCK) ON SIF.ReturnId=RH.ReturnId --AND SIF.SchId=SIS.SchId AND SIF.SlabId=SIS.SlabId
	INNER JOIN ReturnSchemeFreePrdDt SIFP (NOLOCK) ON SIFP.ReturnId=RH.ReturnId --AND SIFP.SchId=SIF.SchId AND SIFP.SlabId=SIF.SlabId
	-- INNER JOIN SalesInvoice SI (NOLOCK) ON SI.SalId=RH.SalId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=SIFP.FreePrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdBatId=SIFP.FreePrdBatId
	INNER JOIN TaxGroupSetting TG (NOLOCK) ON TG.TaxGroupId=PB.TaxGroupId
	INNER JOIN Salesman S (NOLOCK) ON S.SMId=RH.SMId
	INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=RH.RMId
	-- INNER JOIN DeliveryBoy DB (NOLOCK) ON DB.DlvBoyId=SI.DlvBoyId
	-- INNER JOIN Vehicle V (NOLOCK) ON V.VehicleId=SI.VehicleId
	INNER JOIN Retailer R (NOLOCK) ON R.RtrId=RH.RtrId
	INNER JOIN RouteMaster RM1 (NOLOCK)ON RM1.RMId=RH.RMId
	LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON SI.SalId=RH.SalId
	LEFT OUTER JOIN CREDITNOTERETAILER CNR ON CNR.PostedFrom=RH.RETURNCODE
	WHERE ReturnType=2 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--AND PB.Status=1
	AND RH.Status=0
	AND RH.XmlUPload=0
	--  ORDER BY RH.ReturnId
	--SELECT * FROM #Temp_ETL_XML_SalesReturn ORDER BY SalRetNo
	INSERT INTO ETL_XML_SalesReturn(DistCode,DocDate,SalRetNo,SalInvRefNo,ItemCode,Quantity,TaxCode,UnitPrice,BatchNumber,Salesman,OrderBeat,RdyStk,Cardcode,CreditNoteNo,SalDlvDate,DeliveryBeat,PrdBatCde,PrimaryDiscount,SecondaryDiscount,SalSchAmt,SalDisAmt
	,SalRetAmt,SalVisAmt,SalDistDis,SalTotDedn,SalRoundOffAmt,dbadjamt,cradjamt,OnAccountAmt,SalReplaceAmt,SalSplDis,SalInvSch,SalInvDist,SalCshDis,UploadFlag)
	SELECT * FROM #Temp_ETL_XML_SalesReturn  ORDER BY SalRetNo
	UPDATE A SET XmlUpload=1 FROM ReturnHeader A, ETL_XML_SalesReturn B
	WHERE XmlUpload=0 AND UploadFlag='N' AND A.ReturnCode=B.SalRetNo AND ReturnType=2
	SELECT * FROM ETL_XML_SalesReturn --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SalesReturnScheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SalesReturnScheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_XmlUpload_SalesReturnScheme]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	----------- Alter By Ram AS On 11/09/2010--------------
	DELETE FROM ETL_XML_SalesReturnScheme --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO ETL_XML_SalesReturnScheme  (DistCode,CardCode,SalRetNo,DocDate,SalInvRefNo,ItemCode,BatchNumber,Quantity,Company_Scheme_Code,SchemeDisAmount,SchemeSlabID,UploadFlag)
	SELECT @DISTCODE,CASE LEN(SI.RtrId) WHEN 1 THEN (@DISTCODE+'0000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 2 THEN (@DISTCODE+'000'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 3 THEN (@DISTCODE+'00'+CAST(SI.RtrId AS VARCHAR(5)))
	WHEN 4 THEN (@DISTCODE+'0'+CAST(SI.RtrId AS VARCHAR(5)))
	ELSE (@DISTCODE+CAST(SI.RtrId AS VARCHAR(5))) END, -- (@DISTCODE+CAST(SI.RtrId AS NVARCHAR(10))),
	ReturnCode,CONVERT(VARCHAR(10),Returndate,121),S.SalInvNo,PrdCCode,
	CmpBatCode,SIP.BaseQty,CmpSchCode,
	--ISNULL((ReturnFlatAmount+ReturnDiscountPerAmount),0),
	ReturnClaimamount,
	SISLW.SlabId,'N'
	FROM ReturnHeader SI (NOLOCK)
	INNER JOIN ReturnProduct SIP (NOLOCK) ON SI.ReturnId=SIP.ReturnId
	INNER JOIN Product P (NOLOCK) ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdBatId=SIP.PrdBatId
	INNER JOIN ReturnSchemeLineDt SISLW (NOLOCK) ON SISLW.ReturnId=SI.ReturnId
	AND SIP.PrdId=SISLW.PrdId AND SIP.PrdBatId=SISLW.PrdBatId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SM.SchId=SISLW.SchId
	INNER JOIN SalesInvoice S (NOLOCK) ON S.SalId=SI.SalId
	WHERE ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND PB.Status=1
	--AND SI.XmlUPload=0
	AND ReturnType=2
	ORDER BY SI.ReturnId
	--UPDATE A SET XmlUpload=1 FROM ReturnHeader A, ETL_XML_SalesReturnScheme B
	--WHERE XmlUpload=0 AND UploadFlag='N' AND A.ReturnCode=B.SalRetNo AND ReturnType=2
	SELECT * FROM ETL_XML_SalesReturnScheme --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_Salvage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_Salvage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [dbo].[Proc_XmlUpload_Salvage]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_Salvage --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	INSERT INTO ETL_XML_Salvage
	SELECT @DISTCODE,CONVERT(VARCHAR(10),SalvageDate,121),CmpBatCode,SalvageQty,PrdCCode,A.SalvageRefNo,
	Remarks,'Stock Out','Salvage',UserStockType,'N'
	FROM Salvage A (NOLOCK)
	INNER JOIN SalvageProduct B (NOLOCK) ON B.SalvageRefNo=A.SalvageRefNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=B.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=B.PrdId AND PB.PrdBatId=B.PrdBatId
	INNER JOIN StockType ST (NOLOCK) ON ST.StockTypeId=A.StockTypeId
	WHERE SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.XmlUpload=0 AND A.Status=1 AND PB.Status=1
	ORDER BY A.SalvageRefNo
	UPDATE A SET XmlUpload=1 FROM Salvage A, ETL_XML_Salvage B
	WHERE XmlUpload=0 AND UploadFlag='N' AND A.SalvageRefNo=B.StockyDocNo
	SELECT * FROM ETL_XML_Salvage --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SchemeAttributes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SchemeAttributes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_XmlUpload_SchemeAttributes]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_SchemeAttributes
* PURPOSE: Scheme Attributes XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SchemeAttributes --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_SchemeAttributes
	(
	DistCode,
	SchemeId,
	SchemeCode,
	Company_Scheme_Code,
	[Attribute Type],
	[Attribute Master Code],
	UploadFlag
	)
	SELECT @DistCode,B.SchId AS [SchemeId],B.SchCode AS [SchemeCode],
	B.CmpSchCode AS [Company_Scheme_Code],
	CASE A.AttrType WHEN 1 THEN 'SALESMAN' WHEN 2 THEN 'ROUTE' WHEN 3 THEN 'VILLAGE'
	WHEN 4 THEN 'CATEGORY LEVEL' WHEN 5 THEN 'CATEGORY LEVEL VALUE' WHEN 6 THEN 'VALUECLASS'
	WHEN 7 THEN 'POTENTIALCLASS' WHEN 8 THEN 'RETAILER' WHEN 9 THEN 'PRODUCT'
	WHEN 10 THEN 'BILL TYPE' WHEN 11 THEN 'BILL MODE' WHEN 12 THEN 'RETAILER TYPE'
	WHEN 13 THEN 'CLASS TYPE' WHEN 14 THEN 'ROAD CONDITION' WHEN 15 THEN 'INCOME LEVEL'
	WHEN 16 THEN 'ACCEPTABILITY' WHEN 17 THEN 'AWARENESS' WHEN 18 THEN 'ROUTE TYPE'
	WHEN 19 THEN 'LOCALUPCOUNTRY' WHEN 20 THEN 'VAN/NON VAN ROUTE' END AS [Attribute Type],
	CASE A.AttrType
	WHEN 1 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE C.SMCode END
	WHEN 2 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE D.RMCode END
	WHEN 3 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE E.VILLAGECODE END
	WHEN 4 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE F.CtgLevelName END
	WHEN 5 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE G.CtgCode END
	WHEN 6 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE H.ValueClassCode END
	WHEN 7 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE I.PotentialClassCode END
	WHEN 8 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE J.RtrCode END
	WHEN 9 THEN CASE A.AttrId WHEN 0 THEN 'ALL' ELSE K.PrdDCode END
	WHEN 10 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'ORDER BOOKING'
	WHEN 2 THEN 'READY STOCK' WHEN 3 THEN 'VAN SALES' END
	WHEN 11 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'CASH' WHEN 2 THEN 'CREDIT' END
	WHEN 12 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'KEY OUTLET' WHEN 2 THEN 'NON-KEY OUTLET' END
	WHEN 13 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'VALUE CLASSIFICATION' WHEN 2 THEN 'POTENTIAL CLASSIFICATION' END
	WHEN 14 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'GOOD' WHEN 2 THEN 'ABOVE AVERAGE'
	WHEN 3 THEN 'AVERAGE' WHEN 4 THEN 'BELOW AVERAGE' WHEN 5 THEN 'POOR' END
	WHEN 15 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'GOOD' WHEN 2 THEN 'ABOVE AVERAGE'
	WHEN 3 THEN 'AVERAGE' WHEN 4 THEN 'BELOW AVERAGE' WHEN 5 THEN 'POOR' END
	WHEN 16 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'GOOD' WHEN 2 THEN 'ABOVE AVERAGE'
	WHEN 3 THEN 'AVERAGE' WHEN 4 THEN 'BELOW AVERAGE' WHEN 5 THEN 'POOR' END
	WHEN 17 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'GOOD' WHEN 2 THEN 'ABOVE AVERAGE'
	WHEN 3 THEN 'AVERAGE' WHEN 4 THEN 'BELOW AVERAGE' WHEN 5 THEN 'POOR' END
	WHEN 18 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'SALES ROUTE'
	WHEN 2 THEN 'DELIVERY ROUTE' WHEN 3 THEN 'MERCHANDISING ROUTE' END
	WHEN 19 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'LOCAL ROUTE'
	WHEN 2 THEN 'UPCOUNTRY ROUTE' END
	WHEN 20 THEN CASE A.AttrId WHEN 0 THEN 'ALL' WHEN 1 THEN 'VAN ROUTE'
	WHEN 2 THEN 'NON VAN ROUTE' END END AS [Attribute Master Code],'N'
	FROM SchemeRetAttr A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
	LEFT OUTER JOIN SalesMan C ON A.AttrId=C.SMId
	LEFT OUTER JOIN RouteMaster D ON A.AttrId=D.RMId
	LEFT OUTER JOIN RouteVillage E ON A.AttrId=E.VillageId
	LEFT OUTER JOIN RetailerCategoryLevel F ON A.AttrId=F.CtgLevelId
	LEFT OUTER JOIN RetailerCategory G ON A.AttrId=G.CtgMainId
	LEFT OUTER JOIN RetailerValueClass H ON A.AttrId=H.RtrClassId
	LEFT OUTER JOIN RetailerPotentialClass I ON A.AttrId=I.RtrClassId
	LEFT OUTER JOIN Retailer J ON A.AttrId=J.RtrId
	LEFT OUTER JOIN Product K ON A.AttrId=K.PrdId
	WHERE B.XmlUpload=0 ORDER BY B.SchId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SchemeCombiProducts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SchemeCombiProducts]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_XmlUpload_SchemeCombiProducts]
(
	@Pi_FromDate	DATETIME,
	@Pi_ToDate		DATETIME,
	@Po_ErrNo		INT	OUTPUT
)
AS
/*********************************				
* PROCEDURE: Proc_XmlUpload_SchemeCombiProducts
* PURPOSE: Scheme Combi Products XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode	VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SchemeCombiPrdDt WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_SchemeCombiPrdDt
	(
		DistCode,
		SchemeId,
		SchemeCode,
		[Company Scheme Code],
		SlabId,
		Product_Code,
		SlabValue,
		BatchCode,
		Selection_Level_Value,
		UploadFlag
	)
	SELECT @DistCode,B.SchId,B.SchCode,B.CmpSchCode AS [Company Scheme Code],A.SlabId AS [SlabId],
	CASE WHEN A.PrdCtgValMainId<>0 THEN C.PrdCtgValCode
	WHEN A.PrdId <> 0 THEN D.PrdDCode END AS [Product Code],
	ISNULL(A.SlabValue,0) AS [Value],
	CASE WHEN A.PrdBatId<>0 THEN E.PrdBatCode ELSE '0' END AS [Batch Code],F.CmpPrdCtgName,'N'
	FROM SchemeSlabCombiPrds A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
	INNER JOIN ProductCategoryLevel F ON F.CmpPrdCtgId=B.SchLevelId
	LEFT OUTER JOIN ProductCategoryValue C ON A.PrdCtgValMainId=C.PrdCtgValMainId
	LEFT OUTER JOIN Product D ON A.PrdId=D.PrdId
	LEFT OUTER JOIN ProductBatch E ON A.PrdBatId=E.PrdBatId
	WHERE B.XmlUpload=0 ORDER BY B.SchId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SchemeFreePrdDt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SchemeFreePrdDt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_XmlUpload_SchemeFreePrdDt]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_SchemeFreePrdDt
* PURPOSE: Scheme Free Products XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SchemeFreePrdDt --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_SchemeFreePrdDt
	(
	DistCode,
	SchemeId,
	SchemeCode,
	[Company Scheme Code],
	SlabId,
	Condition,
	Product_Code,
	Qty,
	Type,
	UploadFlag
	)
	SELECT DISTINCT @DistCode,B.SchId,B.SchCode,B.CmpSchCode as [Company Scheme Code],A.SlabId,
	CASE ISNULL(D.SchId,-1) WHEN -1 THEN 'AND' ELSE 'OR' END as [Condition],
	PrdDCode as [Product Code],A.FreeQty as [Qty],
	CASE ISNULL(D.SchId,-1) WHEN -1 THEN 'FREE' ELSE
	CASE D.Type WHEN 1 THEN 'FREE' WHEN 2 THEN 'GIFT' END END  as [Type],'N'
	FROM dbo.SchemeSlabFrePrds A
	INNER JOIN SchemeMaster B ON A.SchId = B.SchId
	INNER JOIN Product C ON A.PrdId = C.PrdId
	LEFT OUTER JOIN SchemeSlabMultiFrePrds D ON D.SchId = B.SchId
	AND D.SlabId = A.SlabId
	WHERE B.XmlUpload=0 --ORDER BY A.SchId
	UNION ALL
	SELECT DISTINCT @DistCode,B.SchId,B.SchCode,B.CmpSchCode as [Company Scheme Code],A.SlabId,'OR' as [Condition],
	PrdDCode as [Product Code],A.FreeQty as [Qty],
	CASE A.Type WHEN 1 THEN 'FREE' WHEN 2 THEN 'GIFT' END as [Type],'N'
	FROM dbo.SchemeSlabMultiFrePrds A
	INNER JOIN SchemeMaster B ON A.SchId = B.SchId
	INNER JOIN Product C ON A.PrdId = C.PrdId
	WHERE B.XmlUpload=0 --ORDER BY A.SchId
	UPDATE A SET XmlUpload=1 FROM SchemeMaster A INNER JOIN Etl_Xml_SchemeMaster B
	ON A.SchCode=B.SchemeCode WHERE A.XmlUpload=0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SchemeMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SchemeMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_XmlUpload_SchemeMaster]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT = 0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_SchemeMaster
* PURPOSE: Scheme master XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SchemeMaster --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_SchemeMaster
	(
	DistCode,
	SchemeId,
	SchemeCode,
	Company_Scheme_Code,
	Scheme_Description,
	Company_Code,
	Claimable,
	Claim_Amount_On,
	Claim_Group_Code,
	Selection_On,
	Selection_Level_Value,
	Scheme_Type,
	Batch_Level,
	Flexi_Scheme,
	Flexi_Conditional,
	Combi_Scheme,
	Range,
	Pro_Rata,
	QPS,
	Qps_Reset,
	Qps_Based_On,
	Allow_For_Every,
	Adjust_Display_Once,
	Settle_Display_Through,
	Allow_Editing_Scheme,
	Scheme_Budget,
	Scheme_Start_Date,
	Scheme_End_Date,
	UploadFlag
	)
	SELECT @DistCode,B.SchId AS [SchemeId],B.SchCode As [SchemeCode],
	B.CmpSchCode AS [Company_Scheme_Code],B.SchDsc AS [Scheme_Description],C.CmpCode AS [Company_Code],
	CASE B.Claimable WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Claimable],
	CASE B.ClmAmton WHEN 1 THEN 'PURCHASE RATE' WHEN 2 THEN 'SELLING RATE' END AS [Claim_Amount_On],
	ISNULL(D.ClmGrpCode,'') AS  [Claim_Group_Code],CASE B.SchemeLvlMode WHEN 0 THEN 'PRODUCT' WHEN 1 THEN 'UDC' END AS [Selection_On],
	E.CmpPrdCtgName AS [Selection_Level_Value],CASE B.SchType WHEN 1 THEN 'QUANTITY' WHEN 2 THEN 'AMOUNT'
	WHEN 3 THEN 'WEIGHT' WHEN 4 THEN 'WINDOW DISPLAY' END AS [Scheme_Type],
	CASE B.BatchLevel WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Batch_Level],
	CASE B.FlexiSch WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Flexi_Scheme],
	CASE B.FlexiSchType WHEN 1 THEN 'CONDITIONAL' WHEN 2 THEN 'UNCONDITIONAL' END AS [Flexi_Conditional],
	CASE B.CombiSch WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Combi_Scheme],
	CASE B.Range WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Range],
	CASE B.ProRata WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' WHEN 2 THEN 'ACTUAL' END AS [Pro_Rata],
	CASE B.QPS WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [QPS],
	CASE B.QPSReset WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Qps_Reset],
	CASE B.ApyQPSSch WHEN 1 THEN 'DATE' WHEN 2 THEN 'QUANTITY' END AS [Qps_Based_On],
	CASE B.PurofEvery WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Allow_For_Every],
	CASE B.AdjWinDispOnlyOnce WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Adjust_Display_Once],
	CASE B.SetWindowDisp WHEN 0 THEN 'CASH' WHEN 1 THEN 'CHEQUE' END AS [Settle_Display_Through],
	CASE B.EditScheme WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS [Allow_Editing_Scheme],
	ISNULL(B.Budget,0) AS [Scheme_Budget],CONVERT(NVARCHAR(10),B.SchValidFrom,121) AS [Scheme_Start_Date],
	CONVERT(NVARCHAR(10),B.SchValidTill,121) AS [Scheme_End_Date],'N'
	FROM SchemeMaster B INNER JOIN Company C ON B.CmpId=C.CmpId
	LEFT JOIN ClaimGroupMaster D ON B.ClmRefId=D.ClmGrpId
	INNER JOIN ProductCategoryLevel E ON B.SchLevelId=E.CmpPrdCtgId
	WHERE B.XmlUpload=0 ORDER BY B.SchId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SchemeProduct]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SchemeProduct]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_XmlUpload_SchemeProduct]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT = 0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_SchemeProduct
* PURPOSE: Scheme Product XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SchemeProduct --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_SchemeProduct
	(
	DistCode,
	SchemeId,
	SchemeCode,
	Company_Scheme_Code,
	Type,
	Code,
	Batch_Code,
	UploadFlag
	)
	SELECT @DistCode,B.SchId AS [SchemeId],B.SchCode As [SchemeCode],
	B.CmpSchCode AS [Company_Scheme_Code],D.CmpPrdCtgName AS [Type],F.PRODUCTCODE AS [Code],
	ISNULL(G.PrdBatCode,'') AS [Batch_Code],'N' FROM SchemeMaster B
	INNER JOIN SchemeProducts C ON B.SchId=C.SchId
	INNER JOIN Company E ON B.CmpId=E.CmpId
	INNER JOIN ProductCategoryLevel D ON D.CmpId=E.CmpId AND B.SchLevelId=D.CmpPrdCtgId
	INNER JOIN TBL_GR_BUILD_PH F ON C.PrdId=F.PrdId
	LEFT OUTER JOIN ProductBatch G ON F.PrdId=G.PrdId
	WHERE C.PrdId>0 AND B.XmlUpload=0
	UNION ALL
	SELECT @DistCode,B.SchId AS [SchemeId],B.SchCode As [SchemeCode],
	B.CmpSchCode AS [Company_Scheme_Code],D.CmpPrdCtgName AS [Type],F.PrdCtgValCode AS [Code],
	'' AS [Batch_Code],'N' FROM Distributor A,SchemeMaster B
	INNER JOIN SchemeProducts C ON B.SchId=C.SchId
	INNER JOIN Company E ON B.CmpId=E.CmpId
	INNER JOIN ProductCategoryLevel D ON D.CmpId=E.CmpId AND B.SchLevelId=D.CmpPrdCtgId
	INNER JOIN ProductCategoryValue F ON C.PrdCtgValMainId=F.PrdCtgValMainId
	WHERE C.PrdCtgValMainId>0 AND B.XmlUpload=0 --ORDER BY B.SchId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_SchemeSlabs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_SchemeSlabs]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_XmlUpload_SchemeSlabs]
(
@Pi_FromDate DATETIME,
@Pi_ToDate  DATETIME,
@Po_ErrNo  INT = 0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_SchemeSlabs
* PURPOSE: Scheme Slab XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_SchemeSlab --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_SchemeSlab
	(
	DistCode,
	SchemeId,
	SchemeCode,
	[Company Scheme Code],
	SlabId,
	[From Uom],
	[From Qty],
	[To Uom],
	[To Qty],
	[For Every Uom],
	[For Every Qty],
	[Disc %],
	[Flat Amount],
	Point,
	[Flexi Free],
	[Flexi Gift],
	[Flexi Disc],
	[Flexi Flat],
	[Flexi Points],
	[Max Discount],
	[Min Discount],
	[Max Value],
	[Min Value],
	[Max Points],
	[Min Points],
	UploadFlag
	)
	SELECT @DistCode,B.SchId AS [SchemeId],B.SchCode AS [SchemeCode],
	B.CmpSchCode AS [Company Scheme Code],A.SlabId AS [SlabId],
	CASE WHEN B.SchType=1 THEN
	CASE WHEN A.UomId>0 THEN ISNULL(C.UomCode,'') ELSE '' END
	WHEN B.SchType=3 THEN
	CASE WHEN A.UomId>0 THEN ISNULL(D.PrdUnitCode,'') ELSE '' END
	ELSE '0' END AS [From Uom],
	CASE WHEN A.PurQty <> 0 THEN A.PurQty ELSE A.FromQty END AS [From Qty],
	CASE WHEN B.SchType=1 THEN
	CASE WHEN A.ToUomId>0 THEN ISNULL(C.UomCode,'') ELSE '' END
	WHEN B.SchType=3 THEN
	CASE WHEN A.ToUomId>0 THEN ISNULL(D.PrdUnitCode,'') ELSE '0' END
	ELSE '0' END AS [To Uom],A.ToQty AS [To Qty],
	CASE WHEN B.SchType=1 THEN
	CASE WHEN A.ForEveryUomId>0 THEN ISNULL(C.UomCode,'') ELSE '' END
	WHEN B.SchType=3 THEN
	CASE WHEN A.ForEveryUomId>0 THEN ISNULL(D.PrdUnitCode,'') ELSE '' END
	ELSE '' END AS [For Every Uom],A.ForEveryQty AS [For Every Qty],
	A.DiscPer AS [Disc %],A.FlatAmt AS [Flat Amount],A.Points AS [Point],
	CASE WHEN A.FlxFreePrd >0 THEN ISNULL(E.PrdId,0) ELSE '0' END AS [Flexi Free],
	CASE WHEN A.FlxGiftPrd >0 THEN ISNULL(F.PrdId,0) ELSE '0' END AS [Flexi Gift],
	A.FlxDisc AS [Flexi Disc],A.FlxValueDisc AS [Flexi Flat],A.FlxPoints AS [Flexi Points],
	A.MaxDiscount AS [Max Discount],A.MinDiscount AS [Min Discount],A.MaxValue AS [Max Value],
	A.MinValue AS [Min Value],A.MaxPoints AS [Max Points],A.MinPoints AS [Min Points],'N'
	FROM SchemeSlabs A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
	LEFT OUTER JOIN UomMaster C ON A.UomId=C.UomId
	LEFT OUTER JOIN ProductUnit D ON A.UomId=D.PrdUnitId
	LEFT OUTER JOIN Product E ON A.FlxFreePrd = E.PrdId
	LEFT OUTER JOIN Product F ON A.FlxGiftPrd = F.PrdId
	WHERE B.XmlUpload=0 ORDER BY B.SchId,A.SlabId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_VanLoadUnload]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_VanLoadUnload]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_XmlUpload_VanLoadUnload]
(
	@Pi_FromDate  DATETIME,
	@Pi_ToDate    DATETIME,
	@Po_ErrNo     INT=0 OUTPUT
)
AS
BEGIN
	DECLARE @DISTCODE AS NVARCHAR(30)
	SET @Po_ErrNo=0
	DELETE FROM ETL_XML_VanLoadUnload --WHERE UploadFlag='Y'
	SELECT @DISTCODE=DistributorCode FROM Distributor (NOLOCK) WHERE Availability=1
	--VAN LOAD&UNLOAD
	INSERT INTO ETL_XML_VanLoadUnload
	SELECT @DISTCODE,A.VanLoadRefNo,CONVERT(VARCHAR(10),TransferDate,121),PrdCCode,TransQty,CmpBatCode,PBD.PrdBatDetailValue,
	A.VANLOADUNLOAD,L1.LCNCODE,CASE L1.LCNID WHEN 1 THEN 'MAINGODWON' ELSE 'VAN'END,L.LCNCODE,CASE L.LCNID WHEN 1 THEN 'MAINGODWON' ELSE 'VAN' END,'N'
	FROM VanLoadUnloadMaster A (NOLOCK)
	INNER JOIN VanLoadUnloadDetails B (NOLOCK) ON B.VanLoadRefNo=A.VanLoadRefNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=B.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=B.PrdId AND PB.PrdBatId=B.PrdBatId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PB.PrdBatId AND PBD.BatchSeqId=PB.BatchSeqId AND PBD.PriceId=PB.DefaultPriceId AND PBD.SlNo=2
	INNER JOIN LOCATION L1 (NOLOCK) ON L1.LcnId=A.FRMLcnId AND L1.Availability=1
	INNER JOIN LOCATION L ON L.LCNID=A.TOLCNID AND L.AVAILABILITY=1
	LEFT OUTER JOIN SalesMan S (NOLOCK) ON S.SMId=A.SMId
	LEFT OUTER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=A.RMId
	WHERE TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.XmlUpload=0
	--AND PB.Status=1
	AND PBD.SlNo=2 --AND VanLoadUnLoad=1
	ORDER BY A.VanLoadRefNo
	-- LOCATION TRANSFER
	INSERT INTO ETL_XML_VanLoadUnload
	select @distcode,ltm.lcnrefno,CONVERT(VARCHAR(10),ltm.lcntrfdate,121),p.prddcode,ltd.transferqty,pb.prdbatcode,pbd.prdbatdetailvalue,'2',l1.lcncode,
	CASE L1.LCNID WHEN 1 THEN 'MAINGODWON' ELSE 'VAN'END,L.LCNCODE,CASE L.LCNID WHEN 1 THEN 'MAINGODWON' ELSE 'VAN' END,'N'
	from locationtransfermaster ltm
	inner join locationtransferdetails ltd on ltm.lcnrefno=ltd.lcnrefno
	inner join product p on ltd.prdid=p.prdid inner join productbatch pb on ltd.prdbatid=pb.prdbatid
	inner join productbatchdetails pbd on pbd.prdbatid=pb.prdbatid and pbd.batchseqid=pb.batchseqid and pbd.priceid=pb.defaultpriceid and pbd.slno=2
	inner join location l1 on l1.lcnid=ltm.fromlcnid and l1.Availability=1
	inner join location l on l.lcnid=ltm.tolcnid and l.Availability=1
	WHERE ltm.lcntrfdate BETWEEN @Pi_FromDate AND @Pi_ToDate
	-- AND A.XmlUpload=0
	-- AND PB.Status=1
	AND PBD.SlNo=2 --AND VanLoadUnLoad=1
	ORDER BY ltm.lcnrefno
	/*
	-- VAN LOAD
	INSERT INTO ETL_XML_VanLoadUnload
	SELECT @DISTCODE,CONVERT(VARCHAR(10),TransferDate,121),PrdCCode,TransQty,CmpBatCode,PBD.PrdBatDetailValue,
	@DISTCODE+V.VehicleRegNo,'',A.VanLoadRefNo,ISNULL(SMName,''),ISNULL(RMName,''),'N'
	FROM VanLoadUnloadMaster A (NOLOCK)
	INNER JOIN VanLoadUnloadDetails B (NOLOCK) ON B.VanLoadRefNo=A.VanLoadRefNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=B.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=B.PrdId AND PB.PrdBatId=B.PrdBatId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PB.PrdBatId AND PBD.BatchSeqId=PB.BatchSeqId AND PBD.PriceId=PB.DefaultPriceId AND PBD.SlNo=2
	INNER JOIN Vehicle V (NOLOCK) ON V.LcnId=A.ToLcnId AND V.Availability=1 --AND V.LcnId=A.ToLcnId
	LEFT OUTER JOIN SalesMan S (NOLOCK) ON S.SMId=A.SMId
	LEFT OUTER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=A.RMId
	WHERE TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.XmlUpload=0 AND PB.Status=1 AND PBD.SlNo=2 AND VanLoadUnLoad=0
	ORDER BY A.VanLoadRefNo
	-- VAN UNLOAD
	INSERT INTO ETL_XML_VanLoadUnload
	SELECT @DISTCODE,CONVERT(VARCHAR(10),TransferDate,121),PrdCCode,TransQty,CmpBatCode,PBD.PrdBatDetailValue,
	@DISTCODE+V.VehicleRegNo,'',A.VanLoadRefNo,ISNULL(SMName,''),ISNULL(RMName,''),'N'
	FROM VanLoadUnloadMaster A (NOLOCK)
	INNER JOIN VanLoadUnloadDetails B (NOLOCK) ON B.VanLoadRefNo=A.VanLoadRefNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=B.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=B.PrdId AND PB.PrdBatId=B.PrdBatId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PB.PrdBatId AND PBD.BatchSeqId=PB.BatchSeqId AND PBD.PriceId=PB.DefaultPriceId AND PBD.SlNo=2
	INNER JOIN Vehicle V (NOLOCK) ON V.LcnId=A.FrmLcnId AND V.Availability=1
	INNER JOIN SalesMan S (NOLOCK) ON S.SMId=A.SMId
	INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=A.RMId
	WHERE TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.XmlUpload=0 AND PB.Status=1 AND PBD.SlNo=2 AND VanLoadUnLoad=1
	ORDER BY A.VanLoadRefNo
	*/
	UPDATE A SET XmlUpload=1 FROM VanLoadUnloadMaster A, ETL_XML_VanLoadUnload B
	WHERE XmlUpload=0 AND UploadFlag='N' AND A.VanLoadRefNo=B.VanLoadUnloadNo
	SELECT * FROM ETL_XML_VanLoadUnload --FOR XML auto
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_XmlUpload_VehicleMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_XmlUpload_VehicleMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_XmlUpload_VehicleMaster]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate  DATETIME,
	@Po_ErrNo  INT = 0 OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_XmlUpload_VehicleMaster
* PURPOSE: Vehicle master XML Upload
* NOTES:
* CREATED: Boopathy.P 02-08-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @DistCode VARCHAR(50)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Etl_Xml_VehicleMaster --WHERE UploadFlag='Y'
	INSERT INTO Etl_Xml_VehicleMaster
	(
	DistCode,
	VehicleCode,
	[Registration No],
	VehicleCategory,
	Capacity,
	Status,
	UploadFlag
	)
	SELECT @DistCode,A.VehicleCode,ISNULL(A.VehicleRegNo,''),B.VehicleCtgname,A.VehicleCapacity,
	CASE A.VehicleStatus WHEN 1 THEN 'ACTIVE' WHEN 0 THEN 'INACTIVE' END,'N' FROM
	Vehicle A INNER JOIN VehicleCategory B ON A.VehicleCtgId=B.VehicleCtgId
	WHERE A.XmlUpload=0 ORDER BY A.VehicleCtgId
	UPDATE A SET XmlUpload=1 FROM Vehicle A INNER JOIN Etl_Xml_VehicleMaster B
	ON A.VehicleCode=B.VehicleCode WHERE A.XmlUpload=0 AND B.UploadFlag='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SalesinvoiceTrackFlexiScheme]') and OBJECTPROPERTY(id, N'IsTABLE') = 1)
begin
	CREATE TABLE [dbo].SalesinvoiceTrackFlexiScheme
	(
		SchId		BIGINT,
		SlabId		BIGINT,
		DiscPer		NUMERIC(18,2),
		Amount		NUMERIC(18,6),
		UsrId		INT,
		TransId		INT
	) ON [PRIMARY]
end
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'DISCPER' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='SalesInvoiceQPSSchemeAdj'))
BEGIN
	ALTER TABLE SalesInvoiceQPSSchemeAdj ADD DISCPER NUMERIC(18,2) NOT NULL DEFAULT 0 WITH VALUES
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Fn_ReturnSchemeCombiCriteria') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].Fn_ReturnSchemeCombiCriteria
GO
CREATE FUNCTION [dbo].[Fn_ReturnSchemeCombiCriteria] (@SalId INT) RETURNS INT   
AS
BEGIN
	DECLARE @RetValue as INT
	SET @RetValue=0 
	SELECT @RetValue=CombiType
	FROM SchemeMaster A INNER JOIN SalesInvoiceSchemeLineWise B on A.SchId=B.SchId 
	INNER JOIN SalesInvoice C on C.SalId=B.SalId where C.SalId=@SalId and CombiSch=1 AND CombiType=1
	RETURN (@RetValue)
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Fn_ReturnBilledSchemeDet') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].Fn_ReturnBilledSchemeDet
GO
--SELECT * FROM Fn_ReturnBilledSchemeDet(697)
CREATE     FUNCTION [dbo].[Fn_ReturnBilledSchemeDet]
(
	@Pi_SalId BIGINT
)
RETURNS @BilledSchemeDet TABLE
(
	SchId			Int,
	SchCode			nVarChar(40),
	FlexiSch		TinyInt,
	FlexiSchType		TinyInt,
	SlabId			Int,
	SchType			INT,
	SchemeAmount		Numeric(38,6),
	SchemeDiscount		Numeric(38,6),
	Points			INT,
	FlxDisc			TINYINT,
	FlxValueDisc		TINYINT,
	FlxFreePrd		TINYINT,
	FlxGiftPrd		TINYINT,
	FlxPoints		TINYINT,
	FreePrdId 		INT,
	FreePrdBatId		INT,
	FreeToBeGiven		INT,
	GiftPrdId 		INT,
	GiftPrdBatId		INT,
	GiftToBeGiven		INT,
	NoOfTimes		Numeric(38,6),
	IsSelected		TINYINT,
	SchBudget		Numeric(38,6),
	BudgetUtilized		Numeric(38,6),
	LineType		TINYINT,
	PrdId			INT,
	PrdBatId		INT
)
AS
/*********************************
* FUNCTION: Fn_ReturnBilledSchemeDet
* PURPOSE: Returns the Scheme Details for the Selected Bill Number
* NOTES:
* CREATED: Thrinath Kola	02-05-2007
* MODIFIED
* DATE        AUTHOR     DESCRIPTION
------------------------------------------------
* 04-08-2011  Boopathy   Wrongly Update Value for Flexi based Scheme (Check Condition for non-Flexi Scheme)
* 05-08-2011  Booathy    For Flexi QPS Based Scheme-If Credit Note is Converted means,Converted Value is not added with Scheme Amount
*********************************/
BEGIN
	--For Scheme On Another Product
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		ISNULL(SUM(FlatAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,A.PrdId,A.PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		WHERE A.SalId = @Pi_SalId AND A.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd) 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points,A.PrdId,A.PrdBatId

	--For Normal Scheme 
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		ISNULL(SUM(FlatAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType, 0 AS PrdId,0 AS PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId AND A.SlabId=D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		WHERE A.SalId = @Pi_SalId AND A.SchId NOT IN (SELECT SchId FROM SchemeAnotherPrdHd) AND (ISNULL(FlatAmount,0)+ISNULL(A.DiscPer,0))>0 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points


	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,2 as LineType,0,0
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND FreePrdId > 0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,
		A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,C.Budget,B.NoOfTimes

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,3 as LineType,0,0
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND GiftPrdId > 0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,
		A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,C.Budget,B.NoOfTimes

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,0 AS SchType,
		ISNULL(SUM(A.FlatAmount),0) AS SchemeAmount,ISNULL(SUM(A.DiscountPerAmount),0) AS SchemeDiscount,
		ISNULL(A.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,
		A.FreePrdId as FreePrdId,0 as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,
		0 As GiftPrdId,	0 as GiftPrdBatId,0 as GiftToBeGiven,
		0 AS NoOfTimes,0 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,0 as LineType,0,0
		FROM SalesInvoiceUnSelectedScheme A
		INNER JOIN SchemeMaster C ON A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON A.SchId = D.SchId AND A.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,C.Budget

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,
		0 AS SchemeAmount,0 AS SchemeDiscount,
		ISNULL(A.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,
		0 as FreePrdId,0 as FreePrdBatId,0 as FreeToBeGiven,
		0 As GiftPrdId,	0 as GiftPrdBatId,0 as GiftToBeGiven,
		B.NoOfTimes AS NoOfTimes,1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,0,0
		FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON A.SchId = D.SchId AND A.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND A.POints>0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,C.Budget,B.NoOfTimes

		-- Added By Boopathy On 05-08-2011
		IF EXISTS (SELECT * FROM @BilledSchemeDet A INNER JOIN SalesInvoiceQPSSchemeAdj B (NOLOCK) ON A.SchId=B.SchId
					AND A.SlabId=B.SlabId INNER JOIN SchemeMaster SM (NOLOCK) ON B.SchId=B.SchId AND SM.FlexiSch=1  
					WHERE B.SalId=@Pi_SalId AND B.CrNoteAmount>0)
		BEGIN
				UPDATE  A SET A.SchemeAmount= A.SchemeAmount + CASE B.DISCPER WHEN 0 THEN B.CrNoteAmount ELSE 0 END
				FROM @BilledSchemeDet A INNER JOIN SalesInvoiceQPSSchemeAdj B (NOLOCK) ON A.SchId=B.SchId
				AND A.SlabId=B.SlabId INNER JOIN SchemeMaster SM (NOLOCK) ON B.SchId=B.SchId AND SM.FlexiSch=1 
				WHERE B.SalId=@Pi_SalId AND B.CrNoteAmount>0
		END
		
		INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
			FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
		SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
			CASE A.DISCPER WHEN 0 THEN ISNULL(SUM(CrNoteAmount),0) ELSE 0 END AS SchemeAmount,A.DISCPER AS SchemeDiscount,
			0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
			0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
			1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType, 0 AS PrdId,0 AS PrdBatId
			FROM SalesInvoiceQPSSchemeAdj A INNER JOIN SalesInvoiceSchemeHd B
			ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId 
			INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
			INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId AND A.SlabId=D.SlabId
			WHERE A.SalId = @Pi_SalId AND A.SchId NOT IN (SELECT SchId FROM SchemeAnotherPrdHd) AND (ISNULL(CrNoteAmount,0))>0 
			AND CAST(A.SchId AS VARCHAR(10))+'~'+CAST(A.SlabId AS VARCHAR(10)) NOT IN 
			(SELECT CAST(SchId AS VARCHAR(10))+'~'+CAST(SlabId AS VARCHAR(10))  FROM @BilledSchemeDet)
			GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
			D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,A.DISCPER

		
		-- Till Here
		

--		04-08-2011  Boopathy   Wrongly Update Value for Flexi based Scheme
		UPDATE @BilledSchemeDet SET SchemeDiscount = DiscountPercent
			FROM SalesInvoiceSchemeFlexiDt B, @BilledSchemeDet A WHERE B.SalId = @Pi_SalId
			AND A.SchId = B.SchId AND A.SlabId = B.SlabId AND A.FreeToBeGiven = 0
			AND A.GiftToBeGiven = 0 AND FlexiSch=0

		UPDATE @BilledSchemeDet SET FlxDisc = 0,FlxValueDisc = 0,FlxPoints = 0
			WHERE FreeToBeGiven > 0 or GiftToBeGiven > 0 AND FlexiSch=0

		DELETE FROM @BilledSchemeDet WHERE 
			((SchemeAmount)+(SchemeDiscount)+(Points)+
			(FlxDisc)+(FlxValueDisc)+(FlxFreePrd)+(FlxGiftPrd)+(FlxPoints)+(FreePrdId)+
			(FreePrdBatId)+(FreeToBeGiven)+(GiftPrdId)+(GiftPrdBatId)+(GiftToBeGiven))=0

	RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Fn_ReturnBillSchemeDetails') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].Fn_ReturnBillSchemeDetails
GO
-- SELECT * FROM DBO.Fn_ReturnBillSchemeDetails(2,2)
CREATE  FUNCTION [dbo].[Fn_ReturnBillSchemeDetails] (@Pi_UserId AS INT,@Pi_TransId AS INT)
RETURNS @ReturnBillSchemeDetails TABLE
	(
		SchId			INT,
		SchCode			VARCHAR(50),
		FlexiSch		INT,
		FlexiSchType	INT,
		SlabId			INT,
        SchemeAmount	NUMERIC(18,6),
		SchemeDiscount	NUMERIC(18,2),
		Points			INT,
		FlxDisc			INT,
        FlxValueDisc	INT,
		FlxFreePrd		INT,
		FlxGiftPrd		INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
        FreeToBeGiven	INT,
		EditScheme		INT,
		NoOfTimes		NUMERIC(18,6),
		Usrid			INT,
		FlxPoints		INT,
        GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftToBeGiven	INT,
		SchType			INT
	)
AS
/*********************************
* FUNCTION: Fn_ReturnBillSchemeDetails
* PURPOSE: Return Billed Scheme Details
* NOTES:
* CREATED: Boopathy.P 0n 14/07/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 06-08-2011 Boopathy.P Wrongly added prdbatid in Group by
*********************************/
BEGIN
		INSERT INTO @ReturnBillSchemeDetails
		SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=1 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount --ORDER BY A.SchId Asc,A.SlabId Asc
		UNION
		SELECT DISTINCT  A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset)=0 
		AND B.CombiSch=0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId 
		UNION
		SELECT DISTINCT  A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=0 AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset) >0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId,A.PrdBatId ORDER BY A.SchId Asc,A.SlabId Asc
RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Fn_ReturnBudgetUtilizedWithoutCurrBill') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].Fn_ReturnBudgetUtilizedWithoutCurrBill
GO
CREATE  FUNCTION [dbo].[Fn_ReturnBudgetUtilizedWithoutCurrBill](@Pi_SchId INT,@Pi_SalId INT)
RETURNS NUMERIC(38,6)
AS
BEGIN
/***************************************************************************************************
* FUNCTION: Fn_ReturnBudgetUtilized
* PURPOSE: Returns the Budget Utilized for the Selected Scheme
* NOTES: 
* CREATED: Panneer		02-05-2011
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------------------------
**************************************************************************************************/
DECLARE @SchemeAmt 	NUMERIC(38,6)
DECLARE @FreeValue	NUMERIC(38,6)
DECLARE @GiftValue	NUMERIC(38,6)
DECLARE @Points		INT
DECLARE @RetSchemeAmt 	NUMERIC(38,6)
DECLARE @RetFreeValue	NUMERIC(38,6)
DECLARE @RetGiftValue	NUMERIC(38,6)
DECLARE @RetPoints		INT
DECLARE @WindowAmt	NUMERIC(38,6)
DECLARE @CrNoteAmt NUMERIC(38,6)
DECLARE @BudgetUtilized	NUMERIC(38,6)
SET @Points=0
SET @RetPoints=0
								/*------------- Linewise SchemeAmount --------------*/
SELECT	
		@SchemeAmt = (ISNULL(SUM(FlatAmount - ReturnFlatAmount),0) + 
		ISNULL(SUM(DiscountPerAmount - ReturnDiscountPerAmount),0))
FROM 
		SalesInvoiceSchemeLineWise A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
WHERE 
		SchId = @Pi_SchId AND DlvSts <> 3 AND B.SalId <> @Pi_SalId
							/*-------------Free Qty Value SchemeAmount --------------*/
SELECT 
	 @FreeValue = ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0)
FROM 
	 SalesInvoiceSchemeDtFreePrd A (NOLOCK) 
	 INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId
	 INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
	 INNER JOIN ProductBatchDetails D (NOLOCK) ON 	C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
	 INNER JOIN BatchCreation E (NOLOCK)       ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
WHERE 
	 SchId = @Pi_SchId AND DlvSts <> 3  AND B.SalId <> @Pi_SalId
				
					 /*------------- Gift Qty Value SchemeAmount --------------*/
SELECT 
		@GiftValue = ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0)
FROM	
		SalesInvoiceSchemeDtFreePrd A (NOLOCK) 
		INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK)       ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
WHERE 
		SchId = @Pi_SchId AND DlvSts <> 3 AND B.SalId <> @Pi_SalId
				/*------------- Window Display Scheme Amount --------------*/
SELECT 
		@WindowAmt = ISNULL(SUM(AdjAmt),0) 
FROM 
		SalesInvoiceWindowDisplay A  (NOLOCK)
		INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId 
WHERE 
		SchId = @Pi_SchId AND DlvSts <> 3  AND B.SalId <> @Pi_SalId
				/*------------- Cheque Disbursa SchemeAmount --------------*/
SELECT 
		@WindowAmt = @WindowAmt + ISNULL(SUM(Amount),0) 
FROM 
		ChequeDisbursalMaster A (NOLOCK)
		INNER JOIN ChequeDisbursalDetails B (NOLOCK) ON A.ChqDisRefNo = B.ChqDisRefNo 
WHERE 
		TransId = @Pi_SchId AND TransType = 1
				/*------------- QPS SchemeAmount --------------*/
SELECT 
		@CrNoteAmt=ISNULL(SUM(CrNoteAmount),0) 
FROM 
		SalesInvoiceQPSSchemeAdj A (NOLOCK)
		INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId 
WHERE 
		SchId = @Pi_SchId  AND B.SalId <> @Pi_SalId
	SET @BudgetUtilized = (@SchemeAmt + @FreeValue + @GiftValue + @Points + @WindowAmt+@CrNoteAmt)
RETURN(@BudgetUtilized)
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Fn_ReturnQPSGivenAmt') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].Fn_ReturnQPSGivenAmt
GO
--SELECT ISNULL(Dbo.Fn_ReturnQPSGivenAmt(114,2),0) AS Amt
CREATE   FUNCTION [dbo].[Fn_ReturnQPSGivenAmt]
(
	@Pi_SchId INT,
	@Pi_RtrId INT	
)
RETURNS NUMERIC(38,6)
AS
/***********************************************
* FUNCTION		: Fn_ReturnQPSGivenAmt
* PURPOSE		: Returns the Given Scheme Amount for the Selected Scheme
* NOTES			:
* CREATED		: Nandakumar R.G
* CREATED DATE	: 27-10-2010
* MODIFIED
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 04-08-2011    Booathy.P  Join missed between SalesInvoiceQPSSchemeAdj and SalesInvoice (RtrId)
************************************************/
BEGIN
	DECLARE @SchemeAmt 		NUMERIC(38,6)	
	DECLARE @QPSFlatGiven	NUMERIC(38,6)	
	
	DECLARE @QPSGivenDisc TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	
	INSERT INTO @QPSGivenDisc
	SELECT SISL.SchId,SUM(SISL.DiscountPerAmount+SISL.FlatAmount)-SUM(SISL.ReturnDiscountPerAmount+SISL.ReturnFlatAmount) AS DiscountPerAmount 
	FROM SalesInvoiceSchemeLineWise SISL (NOLOCK),SalesInvoice SI (NOLOCK)
	Where Si.RtrId = @Pi_RtrId And Si.SalId = SISL.SalId And Si.DlvSts > 3 
	And SISL.SchId = @Pi_SchId 
	GROUP BY SISL.SchId
	UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
	FROM @QPSGivenDisc A,
	(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B (NOLOCK),SalesInvoice SI (NOLOCK)
	Where b.RtrId = @Pi_RtrId AND B.SchId= @Pi_SchId AND SI.SalId = B.SalId AND SI.DlvSts>3 AND SI.RtrId=B.RtrId --Add by Booathy.P 04-08-2011
	GROUP BY B.SchId) C
	WHERE A.SchId=C.SchId 	
	
	INSERT INTO @QPSGivenDisc
	SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B (NOLOCK),SalesInvoice SI (NOLOCK)
	WHERE B.RtrId=@Pi_RtrId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)AND SI.RtrId=B.RtrId --Add by Booathy.P 04-08-2011
	AND B.SchId= @Pi_SchId AND SI.SalId = B.SalId AND SI.DlvSts>3
	GROUP BY B.SchId	
	SELECT @SchemeAmt=ISNULL(SUM(Amount),0) FROM @QPSGivenDisc WHERE SchId=@Pi_SchId	
	
	SELECT @QPSFlatGiven=ISNULL(Amount,0) FROM BillQPSGivenFlat (NOLOCK) WHERE SchId=@Pi_SchId		
		
	IF @QPSFlatGiven>0 
	BEGIN	
		SELECT @SchemeAmt=0
	END
	RETURN(@SchemeAmt)
END
GO
if exists (SELECT * FROM dbo.sysobjects where id = object_id(N'[dbo].Fn_ReturnROUNDOFF') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].Fn_ReturnROUNDOFF
GO
CREATE FUNCTION [dbo].[Fn_ReturnROUNDOFF](@SALINVNO AS VARCHAR(50),@NETAMOUNT AS FLOAT) 
RETURNS @RoundOff TABLE
(
	SALINVNO Varchar(50),
	NETAMT NUMERIC (18,2),
	RoundAmt Numeric(18,5)
)
AS
BEGIN
	DECLARE @RoffScale as Int
	DECLARE @RoffType as Int
	DECLARE @Pos As Integer
	DECLARE @Ranger As Integer
	DECLARE @Remder As Float
	DECLARE @lAmt As BigInt
	DECLARE @tempn As Numeric(18,2)
	DECLARE @amt as Numeric(18,2)
	DECLARE @RundOff as Numeric(18,2)
	DECLARE @Diff as Numeric(18,5)

	SELECT @RoffScale =SalRoundOff FROM SalesInvoice WHERE SalInvNo=@SALINVNO
	SELECT @RoffType=ConfigValue FROM Configuration WHERE ModuleId = 'GENCONFIG8'

	If @RoffScale = 0 
	BEGIN	
    	SET @RundOff = @NETAMOUNT
		SET @Diff = 0
		INSERT INTO @RoundOff SELECT @SALINVNO,@RundOff,@Diff
		RETURN
	END
	IF Cast(CHARINDEX('.',CAST(@NETAMOUNT as VARCHAR(50))) as INT)<=0
	BEGIN
		SET @RundOff = @NETAMOUNT
		SET @Diff = 0
		INSERT INTO @RoundOff SELECT @SALINVNO,@RundOff,@Diff
		RETURN
	END 
	SET @lAmt=SubString(Ltrim(Cast( @NETAMOUNT as Varchar(50))),Cast(CharIndex('.',Cast(@NETAMOUNT as Varchar(50))) as Int)+1,2)	
	SET @Pos=Cast(CHARINDEX('.',CAST(@NETAMOUNT as VARCHAR(50))) as INT)

	IF @RoffScale=1 
	BEGIN
   	
		SET @RundOff = Substring(Cast(Round(@NETAMOUNT, 2) as Varchar(50)), 1, @Pos - 1)	
	    If @lAmt > 0 And @RoffType = 3 
		BEGIN
			SET @RundOff =  @RundOff + 1
		END
	    If @lAmt >= 50 And @RoffType = 1 
		BEGIN
			SET @RundOff =  @RundOff + 1
		END
		
	    SET @Diff = (@RundOff - @NETAMOUNT)
		INSERT INTO @RoundOff SELECT @SALINVNO,@RundOff,@Diff
    	RETURN
	END
		SET @RoffScale=@RoffScale*100
		SET @Ranger = Cast((@lAmt / @RoffScale) as INT)
		SET @Remder = @lAmt % @RoffScale
		IF @RoffType=3 
		BEGIN
			IF @Remder>0
			BEGIN
				SET @Ranger = @Ranger + 1
			END
			SET @Remder=0
		END
		IF @RoffType=1 
		BEGIN
			IF @Remder>@RoffScale/2
			BEGIN
				SET @Ranger = @Ranger + 1
				SET @Remder=0
			END
			SET @Remder=0
		END
		SET @tempn = ((@Ranger * @RoffScale) + @Remder) / 100
		SET @RundOff = Cast(Substring(Cast(Round(@NETAMOUNT, 2) as Varchar(50)), 1, @Pos - 1) as Numeric(18,2))+ @tempn
		SET @Diff = @RundOff - @NETAMOUNT
		INSERT INTO @RoundOff SELECT @SALINVNO,@RundOff,@Diff
	
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ApplyCombiSchemeInBill')
DROP PROCEDURE Proc_ApplyCombiSchemeInBill
GO
CREATE Procedure Proc_ApplyCombiSchemeInBill
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
)
AS
/*********************************
* PROCEDURE	: Proc_ApplyCombiSchemeInBill
* PURPOSE	: To Apply the Combi Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 17/04/2007
* NOTE		: General SP for Returning the Scheme Details for the Selected Combi Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		  {brief modification description}
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme	
* 02-08-2011    Boopathy.P		  QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
* 11-08-2011    Boopathy.P        A Product with different Batch Issue
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
	DECLARE @QpsReset		INT
	DECLARE @QpsResetAvail		INT
	DECLARE @PurOfEveryReq		INT
	DECLARE @SchemeBudget		NUMERIC(38,6)
	DECLARE @SlabId			INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @GrossAmount		NUMERIC(38,6)
	DECLARE @SchemeLvlMode		INT
	DECLARE @PrdId			INT
	DECLARE @PrdBatId		INT
	DECLARE @PrdCtgValMainId	INT
	DECLARE @FrmSchAch		NUMERIC(38,6)
	DECLARE @FrmUomAch		INT
	DECLARE @FromQty		NUMERIC(38,6)
	DECLARE @UomId			INT
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
	DECLARE @SchValidTill	DATETIME
	DECLARE @SchValidFrom	DATETIME
	DECLARE @QPSBasedOn		INT

	DECLARE @CombiType			INT
	DECLARE @NoofLines			INT
	DECLARE @TransMode			INT

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
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempBilledCombiAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempBilledQpsReset TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
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
		PrdbatId		INT
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
		NoOfTimes	numeric(38,6),
		IsSelected	tinyint,
		SchBudget	numeric(32,6),
		BudgetUtilized	numeric(32,6),
		TransId		tinyint,
		Usrid		int,
		PrdId		int,
		PrdBatId	int,
		SchType		int
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @TempBilledFinal TABLE
	(
		PrdMode			INT,
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId	INT,
		SchemeOnQty		NUMERIC(18,0),
		SchemeOnAmount	NUMERIC(18,6),
		SchemeOnKG		NUMERIC(18,6),
		SchemeOnLitre	NUMERIC(18,6),
		SchId			BIGINT,
		MinAmount		NUMERIC(18,6),
		DiscPer			NUMERIC(18,2),
		FlatAmt			NUMERIC(18,6),
		Points			NUMERIC(18,0)
	)

	DECLARE @QPSGivenFlatAmt AS NUMERIC(38,6)
	SELECT @SchCode = SchCode,@SchType = SchType,@BatchLevel = BatchLevel,@FlexiSch = FlexiSch,
		@FlexiSchType = FlexiSchType,@CombiScheme = CombiSch,@SchLevelId = SchLevelId,@ProRata = ProRata,
		@Qps = QPS,@QpsReset = QPSReset,@QPSBasedOn=ApyQPSSch,@SchemeBudget = Budget,@PurOfEveryReq = PurofEvery,
		@SchemeLvlMode = SchemeLvlMode,@CombiType=CombiType,@SchValidTill=SchValidTill,@SchValidFrom=SchValidFrom
	FROM SchemeMaster WHERE SchId = @Pi_SchId AND MasterType=1

	IF @CombiType=1
	BEGIN
		SET @TransMode=-1
		-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
		INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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
			SELECT @SchLevelId = SUBSTRING(LevelName,6,LEN(LevelName)) from ProductCategoryLevel
			WHERE CmpPrdCtgId = @SchLevelId
			
			INSERT INTO @TempHier (PrdId,PrdBatId,PrdCtgValMainId)
			SELECT DISTINCT D.PrdId,E.PrdBatId,C.PrdCtgValMainId FROM ProductCategoryValue C
			INNER JOIN ( Select LEFT(PrdCtgValLinkCode,@SchLevelId*5) as PrdCtgValLinkCode,A.Prdid from Product A
			INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId
			INNER JOIN @TempBilled F ON A.PrdId = F.PrdId) AS D ON
			D.PrdCtgValLinkCode = C.PrdCtgValLinkCode INNER JOIN ProductBatch E
			ON D.PrdId = E.PrdId

			SELECT @NoofLines=NoofLines FROM SchemeCombiCriteria WHERE SchId=@Pi_SchId

			IF @Pi_SalId<>0
			BEGIN
				IF NOT EXISTS (SELECT A.SalId FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B
							ON A.SalId=B.SalId WHERE B.SchId=@Pi_SchId AND A.RtrId=@Pi_RtrId AND A.SalId<>@Pi_SalId AND A.DlvSts>3)
				BEGIN
					SET @TransMode=0
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					
				END
				ELSE
				BEGIN
					SET @TransMode=1
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END					
				END
			END
			ELSE
			BEGIN
				IF NOT EXISTS (SELECT A.SalId FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B
				ON A.SalId=B.SalId WHERE B.SchId=@Pi_SchId AND A.RtrId=@Pi_RtrId AND A.SalId<>@Pi_SalId  AND A.DlvSts>3)
				BEGIN
					SET @TransMode=0
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
				END
				ELSE
				BEGIN
					SET @TransMode=1
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END	
				END
			END

			IF @TransMode=1
			BEGIN
				IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
						0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
						0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
						0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,B.PrdId,B.PrdBatId,0
						FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdCtgValMainId=B.PrdCtgValMainId
						INNER JOIN BilledPrdHdForScheme C (NOLOCK) ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) D ON C.PrdId = D.PrdId AND 
						C.PrdBatId = CASE D.PrdBatId WHEN 0 THEN C.PrdBatId ELSE D.PrdBatId End
						WHERE C.Usrid = @Pi_UsrId AND C.TransId = @Pi_TransId
				END
				ELSE
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
						0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
						0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
						0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,A.PrdId,A.PrdBatId,0
						FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
				END
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
				BEGIN
					IF EXISTS(SELECT A.SchId,COUNT(A.PrdCtgValMainId) AS Cnt FROM	@TempBilledFinal A
					INNER JOIN SchemeCombiCriteria B ON A.SchId=B.SchId AND A.PrdCtgValMainId=B.PrdCtgValMainId
					WHERE A.SchId=@Pi_SchId AND A.SchemeOnAmount>=B.MinAmount AND B.PrdMode=1 GROUP BY A.SchId
					HAVING COUNT(A.PrdCtgValMainId)>=@NoofLines)
					BEGIN
						INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
						Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
						FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
						BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
						SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
							1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
							0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
							0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
							0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
							0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,B.PrdId,B.PrdBatId,0
							FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdCtgValMainId=B.PrdCtgValMainId
							INNER JOIN BilledPrdHdForScheme C (NOLOCK) ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
							INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) D ON C.PrdId = D.PrdId AND 
							C.PrdBatId = CASE D.PrdBatId WHEN 0 THEN C.PrdBatId ELSE D.PrdBatId End
							WHERE C.Usrid = @Pi_UsrId AND C.TransId = @Pi_TransId
					END
				END
				ELSE
				BEGIN


					IF EXISTS(SELECT A.SchId,COUNT(A.PrdId) AS Cnt FROM	@TempBilledFinal A
					INNER JOIN SchemeCombiCriteria B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.SchId=@Pi_SchId AND A.SchemeOnAmount>=B.MinAmount AND B.PrdMode<>1 GROUP BY A.SchId
					HAVING COUNT(A.PrdId)>=@NoofLines)
					BEGIN
						INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
						Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
						FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
						BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
						SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
							1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
							0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
							0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
							0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
							0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,A.PrdId,A.PrdBatId,0
							FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					END
				END
			END
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM SalesInvoice WHERE SalId = @Pi_SalId)
		BEGIN
			SELECT @BillDate = SalInvDate FROM SalesInvoice WHERE SalId = @Pi_SalId
		END
		ELSE
		BEGIN
			SET @BillDate = CONVERT(VARCHAR(10),GETDATE(),121)
		END
		IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId = @Pi_SchId AND SchValidTill >= @BillDate)
		BEGIN
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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
		END
		IF @QPS <> 0
		BEGIN
		--		--To Add the Cumulative Qty
			IF @QPSBasedOn=2
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE
			BEGIN -- Added by Boopathy on 02-08-2011 for QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill   AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
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
				IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
				BEGIN
					INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
					SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
						-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
						-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
						FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
						AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
				END
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					GROUP BY PrdId,PrdBatId
		END
		INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
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
		INSERT INTO @TempBilledAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
		SELECT F.PrdId,F.PrdBatId,F.PrdCtgValMainId,ISNULL(CASE @SchType
			WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			WHEN 2 THEN SUM(SchemeOnAmount)
			WHEN 3 THEN (CASE A.UomId
					WHEN 2 THEN SUM(SchemeOnKg)* 1000
					WHEN 3 THEN SUM(SchemeOnKg)
					WHEN 4 THEN SUM(SchemeOnLitre) * 1000
					WHEN 5 THEN SUM(SchemeOnLitre)	END)
				END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
			A.Slabid,F.SlabValue as FromQty,A.UomId
			FROM SchemeSlabs A
			INNER JOIN SchemeSlabCombiPrds F ON A.SchId = F.SchId AND F.SchId = @Pi_SchId
			AND A.SlabId = F.SlabId
			INNER JOIN @TempBilled B ON A.SchId = B.SchId AND A.SchId = @Pi_SchId
			INNER JOIN Product C ON B.PrdId = C.PrdId
			INNER JOIN @TempHier G ON G.PrdId = CASE F.PrdId WHEN 0 THEN G.PrdId ELSE F.PrdId END
			AND G.PrdBatId = CASE F.PrdBatId WHEN 0 THEN G.PrdBatId ELSE F.PrdBatId END
			AND G.PrdCtgValMainId = CASE F.PrdCtgValMainId WHEN 0 THEN G.PrdCtgValMainId ELSE F.PrdCtgValMainId END
			AND B.PrdId = G.PrdId AND B.PrdBatId = G.PrdBatId
			LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
			GROUP BY F.PrdId,F.PrdBatId,F.PrdCtgValMainId,A.UomId,A.Slabid,A.PurQty,F.SlabValue,A.UomId
		SET @QpsResetAvail = 0
		IF @QpsReset <> 0
		BEGIN
			INSERT INTO @TempBilledQpsReset(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledAch A
				INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId
			
			--Select the Applicable Slab for the Scheme
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledQpsReset GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			SET @QpsResetAvail = 1
		END
		IF @QpsResetAvail = 1
		BEGIN
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,B.SlabValue,A.FrmUomAch,@SlabId,B.SlabValue,A.FrmUomAch
				FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				AND B.SlabId = @SlabId WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId
				AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
				AND B.SchId = @Pi_SchId
		END
		ELSE
		BEGIN
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId AND B.SchId = @Pi_SchId
		END
		WHILE (SELECT ISNULL(SUM(FrmSchAch),0) FROM @TempBilledCombiAch) > 0
		BEGIN
			DELETE FROM @TempRedeem
			--Select the Applicable Slab for the Scheme
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledCombiAch GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			
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
			SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
				(SELECT ROUND((FrmSchAch / (CASE FromQty WHEN 0 THEN 1 ELSE FROMQTY END)),0) AS NoOfTimes
				FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A

			IF @SchType = 1
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			IF @SchType = 2
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			IF @SchType = 3
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
								SET @AssignQty = (SELECT CASE PrdUnitId
									WHEN 2 THEN
										(@AssignKG /(CASE PrdWgt WHEN 0 THEN 1 ELSE
											PrdWgt END / 1000))
									WHEN 3 THEN
										(@AssignKG/(CASE PrdWgt WHEN 0 THEN 1 ELSE PrdWgt END))
									WHEN 4 THEN
										(@AssignLitre /(CASE PrdWgt WHEN 0 THEN 1 ELSE
											PrdWgt END / 1000))
									WHEN 5 THEN								(@AssignLitre/(CASE PrdWgt WHEN 0 THEN 1
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,					
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END				CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			--To Store the Gross amount for the Scheme billed Product
			SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempRedeem
			INSERT INTO BilledPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,
				SumInLitre,UserId,TransId)
			SELECT @Pi_RtrId,@Pi_SchId,PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,
				SchemeOnLitre,@Pi_UsrId,@Pi_TransId FROM @TempRedeem
			--->Added By Nanda on 29/10/2010
			IF EXISTS(SELECT * FROM @TempSchSlabAmt WHERE DiscPer=0)
			BEGIN
				INSERT INTO @QPSGivenFlat
				SELECT SchId,SUM(FlatAmount)
				FROM
				(
					SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0)-ISNULL(ReturnFlatAmount,0) AS FlatAmount
					FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM,SalesInvoice SI
					WHERE SM.QPS=1 AND FlexiSch=0 
					AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3			
				) A
				GROUP BY A.SchId	
			END
			UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
			FROM @QPSGivenFlat A,
			(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
			WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND SI.SalId=B.SalId AND SI.DlvSts>3
			GROUP BY B.SchId) C
			WHERE A.SchId=C.SchId 
			IF @FlexiSch=0
			BEGIN
				INSERT INTO @QPSGivenFlat
				SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
				WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenFlat)
				AND B.SchId IN (SELECT DISTINCT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchemeDiscount=0)
				AND SI.SalId=B.SalId AND SI.DlvSts>3
				GROUP BY B.SchId
			END
			SELECT @QPSGivenFlatAmt=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@Pi_SchId
			DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
			INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
			SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat
			--->Till Here
			--To Calculate the Scheme Flat Amount and Discount Percentage
			--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
			--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
			
			IF @QPS=0
			BEGIN
				INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
				SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
					SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
					IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
					FROM
					(
						SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						@SlabId as SlabId,PrdId,PrdBatId,
						(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
						((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
						As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
						FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
						0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
						@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
						WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
					) AS B
					GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
					GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
			END
			ELSE
			BEGIN
				UPDATE @TempSchSlabAmt SET FlatAmt=FlatAmt-@QPSGivenFlatAmt
				INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
				SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
					SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
					IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
					FROM
					(
						SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						@SlabId as SlabId,PrdId,PrdBatId,
						(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
						((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
						As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
						FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
						0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
						@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
						WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
					) AS B
					GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
					GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
			END
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
			UPDATE @TempBilledQPSReset Set FrmSchach = A.FrmSchAch - B.FrmSchAch
				FROM @TempBilledQPSReset A INNER JOIN @TempBilledCombiAch B
				ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId AND
				A.PrdCtgValMainId = B.PrdCtgValMainId
			DELETE FROM @TempBilledCombiAch
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledQPSReset A
				INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId  AND B.SchId = @Pi_SchId
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledCombiAch GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			DELETE FROM @TempBilledCombiAch
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,B.SlabValue,A.FrmUomAch,@SlabId,B.SlabValue,A.FrmUomAch
				FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				AND B.SlabId = @SlabId WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId
				AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
				AND B.SchId = @Pi_SchId
			
			DELETE FROM @TempSchSlabAmt
			DELETE FROM @TempSchSlabFree
		END



		INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
			BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
		SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount),SUM(SchemeDiscount),
			SUM(Points),FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,SUM(FreeToBeGiven),GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven),SUM(NoOfTimes),
			IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0 FROM @BillAppliedSchemeHd
			GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
			FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
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
				WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 )

				UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
				PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
				PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
				AND SchemeAmount =0
			END
		END
		DECLARE @TotalGross		AS	NUMERIC(18,6)
		IF @QPS=0 AND @CombiScheme=1
		BEGIN
			IF EXISTS (SELECT * FROM SchemeSlabCombiPrds WHERE PrdId>0 AND SchId=@Pi_SchId)
			BEGIN
				DELETE FROM @BillAppliedSchemeHd
				DECLARE @PrdWiseSch TABLE
				(
					SchId			INT,
					PrdCtgValMainId	INT,
					PrdId			INT,
					PrdbatId		INT
				)
				DECLARE @PrdWiseSchTemp TABLE
				(
					SchId			INT,
					PrdId			INT,
					PrdbatId		INT
				)
				INSERT INTO @PrdWiseSch
				SELECT DISTINCT A.SchId,B.PrdCtgValMainId,A.PrdId,A.PrdBatId FROM BillAppliedSchemeHd A INNER JOIN @TempHier B ON A.PrdId=B.PrdId 
				AND A.PrdbatId=B.PrdBatId WHERE A.SchId=@Pi_SchId AND A.TransId= @Pi_TransId AND Usrid = @Pi_UsrId
				INSERT INTO @PrdWiseSchTemp
				SELECT DISTINCT A.SchId,B.PrdId,B.PrdBatId FROM @PrdWiseSch A,BilledPrdHdForScheme B (NOLOCK) 
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) C ON
				B.PrdId = C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE B.PrdBatId End
				WHERE B.TransId = @Pi_TransId AND B.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
				DELETE FROM @PrdWiseSchTemp
				WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) IN
				(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillAppliedSchemeHd
				WHERE TransId = @Pi_TransId AND Usrid = @Pi_UsrId AND SchId=@Pi_SchId)
				SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
				AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId

				IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (FlatAmt+FlxValueDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,A.PrdId,B.PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					INNER JOIN @PrdWiseSchTemp B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId

					SELECT @TotalGross=SUM(B.GrossAmount) FROM BillAppliedSchemeHd A
					INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId

					UPDATE A SET SchemeAmount=  (((SELECT (FlatAmt+FlxValueDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)*( B.GrossAmount/@TotalGross)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
				ELSE IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (DiscPer+FlxDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,A.PrdId,B.PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					INNER JOIN @PrdWiseSchTemp B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId

					UPDATE A SET SchemeDiscount=  (((SELECT (DiscPer+FlxDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 


				END
			END
			ELSE
			BEGIN
				DELETE FROM BillAppliedSchemeHd WHERE PrdId=0
				DELETE FROM @BillAppliedSchemeHd
				DECLARE @BrandWiseSch TABLE
				(
					SchId			INT,
					PrdCtgValMainId	INT,
					PrdId			INT,
					PrdbatId		INT
				)
				DECLARE @BrandWiseSchTemp TABLE
				(
					SchId			INT,
					PrdId			INT,
					PrdbatId		INT
				)
				INSERT INTO @BrandWiseSch
				SELECT DISTINCT A.SchId,B.PrdCtgValMainId,A.PrdId,A.PrdBatId FROM BillAppliedSchemeHd A INNER JOIN @TempHier B ON A.PrdId=B.PrdId 
				AND A.PrdbatId=B.PrdBatId WHERE A.SchId=@Pi_SchId AND A.TransId= @Pi_TransId AND Usrid = @Pi_UsrId
				INSERT INTO @BrandWiseSchTemp
				SELECT DISTINCT A.SchId,B.PrdId,B.PrdBatId FROM @BrandWiseSch A,BilledPrdHdForScheme B (NOLOCK) 
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) C ON
				B.PrdId = C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE B.PrdBatId End
				WHERE B.TransId = @Pi_TransId AND B.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
				DELETE FROM @BrandWiseSchTemp
				WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) IN
				(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillAppliedSchemeHd
				WHERE TransId = @Pi_TransId AND Usrid = @Pi_UsrId AND SchId=@Pi_SchId)
				SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
				AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId


				IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (FlatAmt+FlxValueDisc)>0)
				BEGIN

				INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,B.PrdId,B.PrdBatId,A.SchType FROM
					(SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,0 AS SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,0 AS PrdId,0 AS PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId) A
					INNER JOIN @BrandWiseSchTemp B ON A.SchId=B.SchId
					
					SELECT @TotalGross=SUM(B.GrossAmount) FROM BillAppliedSchemeHd A
					INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId
					UPDATE A SET SchemeAmount=  (((SELECT (FlatAmt+FlxValueDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)*( B.GrossAmount/@TotalGross)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
				ELSE IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (DiscPer+FlxDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
						SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
						A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
						A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
						A.BudgetUtilized,A.TransId,A.Usrid,B.PrdId,B.PrdBatId,A.SchType FROM
						(SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,0 AS SchemeAmount,A.SchemeDiscount,A.Points,
						A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
						A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
						A.BudgetUtilized,A.TransId,A.Usrid,0 AS PrdId,0 AS PrdBatId,A.SchType FROM BillAppliedSchemeHd A
						WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId) A
						INNER JOIN @BrandWiseSchTemp B ON A.SchId=B.SchId


					UPDATE A SET SchemeAmount=  (((SELECT (DiscPer+FlxDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 

				END
			END
		END


		SELECT DISTINCT * INTO #BillAppliedSchemeHd FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		DELETE FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		INSERT INTO BillAppliedSchemeHd
		SELECT * FROM #BillAppliedSchemeHd
		SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
		AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
		UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
		SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
		TransId = @Pi_TransId AND Usrid = @Pi_UsrId
		--Added By Murugan
		IF @QPS<>0
		BEGIN
			DELETE FROM BilledPrdHdForQPSScheme WHERE Transid=@Pi_TransId and Usrid=@Pi_UsrId AND SchId=@Pi_SchId
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT RowId,@Pi_RtrId,BP.PrdId,BP.Prdbatid,SelRate,BaseQty,BaseQty*SelRate AS SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,ListPrice,0,@Pi_SchId
			From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB 	
		END
		--Till Here
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ApplyQPSSchemeInBill')
DROP PROCEDURE Proc_ApplyQPSSchemeInBill
GO
/*
	BEGIN TRANSACTION
	DELETE FROM BillAppliedSchemeHd
	EXEC Proc_ApplyQPSSchemeInBill 125,90,0,1,2
	ROLLBACK TRANSACTION
*/
CREATE Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT,
	@Pi_Mode		INT =0	
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
* {date}		{developer}		{brief modification description}
* 27-07-2011	Boopathy.P		Sales Return is not reduced for Data based QPS Scheme (Commented fetching data from table SalesInvoiceQPSCumulative)
* 02-08-2011    Boopathy.P		QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
* 08-08-2011    Boopathy.P      Bug Ref no : 23364
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
	END
	
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		IF @QPSBasedOn=2
		BEGIN
			IF @Pi_Mode=1
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE IF @Pi_Mode=2
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
		END
		ELSE
		BEGIN
			-- Commented by Boopathy 27-07-2011 (Sales Return is not reduced for Data based QPS Scheme)
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
				SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
				(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
					) AS A 
					INNER JOIN 
					(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
						ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
					) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill   AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
					) AS A 
					INNER JOIN 
					(
						SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
						WHERE A.SchId=@Pi_SchId
					) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
									(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
									AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill  AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						
					) AS A 
				)AS A GROUP BY PrdId,PrdBatId,SchId
		END
	
		IF @Pi_Mode=0
		BEGIN
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
				INNER JOIN ProductUnit D (NOLOCK) ON C.PrdUnitId = D.PrdUnitId,SchemeMaster H
				WHERE Dlvsts in(1,2) and Rtrid=@Pi_RtrId and SI.Salid <>@Pi_SalId
				and SI.Salid Not in(Select Salid from SalesInvoiceSchemeQPSGiven (NOLOCK) where Salid<>@Pi_SalId and  schid=@Pi_SchId)
				AND SI.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
				Group by SIP.Prdid,SIP.Prdbatid,D.PrdUnitId
		END
		IF @Pi_Mode<>2
		BEGIN
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
					WHERE A.SalId = @Pi_SalId AND A.SalId NOT IN (SELECT SalId FROM SalesInvoice WHERE DlvSts>3)
					GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
			
			END
			IF @QPSBasedOn=1 
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
			END
		END
	END
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
		
		
	DELETE FROM @TempBilled WHERE (SchemeOnQty+SchemeOnAmount+SchemeOnKG+SchemeOnLitre)<=0		
	--->Added By Nanda on 26/11/2010
	IF @QPSBasedOn<>1 AND @FlexiSch=1
	BEGIN
		DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG<=0	
	END
	ELSE
	BEGIN
		DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG=0	
	END
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
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
	--->Added By Boo and Nanda on 29/11/2010
	IF @SchType = 3 AND @QPSReset=1
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
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here
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
	BEGIN
		SELECT DISTINCT * INTO #TempBillApplied FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillApplied
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here
	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,SUM(SchemeDiscount) AS SchemeDiscount,
		SUM(Points) AS Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,(FreePrdId) as FreePrdId ,
		FreePrdBatId,SUM(FreeToBeGiven) As FreeToBeGiven,GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven) As GiftToBeGiven,SUM(NoOfTimes) AS NoOfTimes,
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,MAX(PrdBatId),0 FROM @BillAppliedSchemeHd
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
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
	IF @FlexiSch=0
	BEGIN
		INSERT INTO @QPSGivenFlat
		SELECT SchId,SUM(FlatAmount)
		FROM
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId ) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
		) A
		WHERE SchId=@Pi_SchId
		GROUP BY A.SchId	
		
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
	END
	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat
	--->Added By Nanda on 21/02/2011
	UPDATE A SET SchemeAmount=B.SchemeAmount
	FROM BillAppliedSchemeHd A,
	(
		SELECT SchId,SlabId,MAX(SchemeAmount) AS SchemeAmount FROM BillAppliedSchemeHd
		WHERE TransID=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
		GROUP BY SchId,SlabId 
	) B
	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SchId=@Pi_SchId
	--->Till Here
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
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
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0
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
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
		From @TempBilled TB 		
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
	-- Added By Boopathy.P on 08-08-2011 for Bug Ref no : 23364
	UPDATE B SET B.PrdBatId=A.PrdBatId FROM BillAppliedSchemeHd B INNER JOIN 
	(SELECT SchId,SlabId,PrdId,Max(PrdbatId) AS PrdBatId,TransId,UsrId FROM @BillAppliedSchemeHd WHERE 
	(FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd > 0) AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	AND SchId=@Pi_SchId GROUP BY SchId,SlabId,PrdId,TransId,UsrId) AS A ON A.SchId=B.SchId
	AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId AND A.TransId=B.TransId AND A.UsrId=B.UsrId 
	WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId AND B.SchId=@Pi_SchId
	SELECT DISTINCT * INTO #BillAppliedSchemeHd  FROM BillAppliedSchemeHd
	WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
	DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
	INSERT INTO BillAppliedSchemeHd
	SELECT * FROM #BillAppliedSchemeHd
	--->Till Here
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ApplySchemeInBill')
DROP PROCEDURE Proc_ApplySchemeInBill
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApplySchemeInBill 115,12,0,2,2
SELECT * FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme(NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE Procedure [dbo].[Proc_ApplySchemeInBill]
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
		PrdId			INT,
		PrdBatId		INT,
		SchemeOnQty 		NUMERIC(38,0),
		SchemeOnAmount		NUMERIC(38,6),
		SchemeOnKG		NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		SchId 			INT
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
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
	SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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
	--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
	INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
	SELECT ISNULL(CASE @SchType
		WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
	-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
		WHEN 2 THEN SUM(SchemeOnAmount)
		WHEN 3 THEN (CASE A.UomId
				WHEN 2 THEN SUM(SchemeOnKg) * 1000
				WHEN 3 THEN SUM(SchemeOnKg)
				WHEN 4 THEN SUM(SchemeOnLitre) * 1000
				WHEN 5 THEN SUM(SchemeOnLitre)	END)
			END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
		ISNULL(CASE @SchType
		WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
	-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
		WHEN 2 THEN SUM(SchemeOnAmount)
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ApportionSchemeAmountInLine')
DROP PROCEDURE Proc_ApportionSchemeAmountInLine
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApportionSchemeAmountInLine 2,2
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ApportionSchemeAmountInLine]
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT,
	@Pi_Mode	INT =0
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
* 04-08-2011    Boopathy.P        Update the Discount percentage for Flexi Scheme 
* 05-08-2011    Boopathy.P		  Previous Adjusted Value will not reduce for Flexi QPS Based Scheme
* 09-08-2011    Boopathy.P		  Bug No:23402
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
	DECLARE @RtrQPSId  INT
	DECLARE @TempSchGross TABLE
	(
		SchId   INT,
		GrossAmount  NUMERIC(38,6),
		QPSGrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6),
		QPSGrossAmount  NUMERIC(38,6)
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
	
    -- Added by Boopathy for QPS Quantitiy based checking
	DELETE FROM BillQPSSchemeAdj WHERE CrNoteAmount<=0 
	UPDATE SalesInvoiceQPSSchemeAdj SET AdjAmount=0 WHERE CrNoteAmount=0 AND AdjAmount>=0 	
	DELETE FROM ApportionSchemeDetails WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	-- End here 

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
			IF @QPS=0 
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF  @QPS<>0 
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 
			BEGIN			
				
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 
			BEGIN
				IF @Combi=1 
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,PrdId,PrdBatId,SchType FROM 
					(SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,SchType FROM BillApplieDSchemeHd WHERE SchId=@SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId) A
					CROSS JOIN 
					(
						SELECT A.PrdId,A.PrdBatId FROM BilledPrdHdForQPSScheme A (NOLOCK) 
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON A.RowId=10000 AND 
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End		
						AND CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatId AS NVARCHAR(10)) 
						NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillApplieDSchemeHd WHERE SchId=@SchId
						AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId
					)
					)B
					WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
					NOT IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
					FROM BillAppliedSchemeHd WHERE SchId=@SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
				END

				INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
				SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
				CASE @MRP
				WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
				WHEN 2 THEN A.GrossAmount
				WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
				AS GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
				UNION ALL
				SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
				CASE @MRP
				WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
				WHEN 2 THEN A.GrossAmount
				WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
				AS GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId

				IF @QPSDateQty=2 
				BEGIN
					UPDATE TPGS SET TPGS.RowId=BP.RowId
					FROM @TempPrdGross TPGS,BilledPrdHdForQPSScheme BP
					WHERE TPGS.PrdId=BP.PrdId AND TPGS.PrdBatId=BP.PrdBatId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND BP.RowId<>10000
					AND TPGS.SchId=BP.SchId

					UPDATE C SET C.GrossAmount=C.GrossAmount+A.OtherGross
					FROM @TempPrdGross C,
					(SELECT SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
					GROUP BY SchID) A,
					(SELECT SchId,ISNULL(MIN(RowId),2)  AS RowId FROM @TempPrdGross WHERE RowId<>10000 
					GROUP BY SchId) B
					WHERE A.SchId=B.SchId AND B.SchId=C.SchId AND B.RowId=C.RowId
					DELETE FROM @TempPrdGross WHERE RowId=10000
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
					WHERE TPGS.SchId=BP.SchId 
				END	
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
	UPDATE T1 SET QPSGrossAmount=A.GrossAmount
	FROM @TempPrdGross T1,BilledPrdHdForQPSScheme A
	WHERE T1.RowId=A.RowID AND T1.PrdId=A.PrdId AND T1.PrdBatId=A.PrdBatId AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	AND A.QPSPrd=0 AND A.SchId=T1.SchId 
	UPDATE S1 SET S1.QPSGrossAmount=A.QPSGross	
	FROM @TempSchGross S1,(SELECT SchId,SUM(QPSGrossAmount) AS QPSGross FROM @TempPrdGross GROUP BY SchId) AS A
	WHERE A.SchId=S1.SchId
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
			CASE 
				WHEN QPS=1 THEN
					(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
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
			(A.DiscPer+isnull(PrdbatDetailValue,0))
			as DISC,
			isnull(SUM(A.DiscPer+PrdbatDetailValue),SUM(A.DiscPer)) AS DiscSUM,ISNULL(B.SchAmt,0) AS SchAmt,
			CASE  WHEN (ISNULL(PrdbatDetailValue,0)>0 AND A.DiscPer > 0 )THEN 1
			  WHEN (ISNULL(PrdbatDetailValue,0)=0 AND A.DiscPer > 0) THEN 2
			  ELSE 3 END as Status
			INTO #TempSch1
			FROM ApportionSchemeDetails A LEFT OUTER JOIN #TempFinal B ON
			A.RowId =B.RowId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId
			AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.DiscPer > 0 AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
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
			A.SlabId= B.SlabId AND B.Status<3  AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
		END
		ELSE
		BEGIN
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
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
			FROM BillAppliedSchemeHd A 
			INNER JOIN TGQ B ON	A.SchId = B.SchId AND A.SlabId=B.SlabId
			INNER JOIN TPQ C ON A.Schid = C.SchId and B.SchId = C.SchId  AND B.SlabId=C.SlabId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid AND QPS=1 AND QPSReset=1	
			WHERE A.UsrId = @Pi_UsrId AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)	
			AND SM.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		END
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
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

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (CAST(CAST(C.GrossAmount AS NUMERIC(30,10))/CAST(B.GrossAmount AS NUMERIC(30,10)) AS NUMERIC(38,6))) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (CAST(CAST(C.GrossAmount AS NUMERIC(30,10))/CAST(B.GrossAmount AS NUMERIC(30,10)) AS NUMERIC(38,6))) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
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
		Case WHEN  (QPS=1 AND CombiSch=0) OR (QPS=0 AND CombiSch=1) THEN
		SchemeAmount 
		ELSE  (
				CASE   WHEN SM.FlexiSch=1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
					   WHEN SM.CombiSch=1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100  
				ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)

	END

	--Added by Boopathy.P  on 04-08-2011 
	IF EXISTS(SELECT * FROM SalesinvoiceTrackFlexiScheme WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
	BEGIN
		UPDATE A SET A.DiscPer=B.DiscPer FROM ApportionSchemeDetails A INNER JOIN SalesinvoiceTrackFlexiScheme B
		ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.UsrId=B.UsrId AND A.TransId=B.TransId
		WHERE A.UsrId=@Pi_UsrId AND A.TransID=@Pi_TransId
	END


	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	SELECT FreePrdId,FreePrdBatId,Sum(DISTINCT FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY FreePrdId,FreePrdBatId

	INSERT INTO @FreeQtyRow (RowId,PrdId,PrdBatId)
	SELECT MIN(A.RowId) as RowId,A.Prdid,MAX(A.PrdBatId) FROM BilledPrdHdForScheme A
	INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.PrdId AND
	A.PrdBatid = B.PrdBatId
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND
	B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY A.Prdid

	UPDATE ApportionSchemeDetails SET FreeQty = A.FreeQty FROM
	@FreeQtyDt A INNER JOIN @FreeQtyRow B ON
	A.FreePrdId  = B.PrdId
	WHERE ApportionSchemeDetails.RowId = B.RowId AND  ApportionSchemeDetails.PrdId = B.PrdId 
	AND ApportionSchemeDetails.UsrId = @Pi_UsrId AND ApportionSchemeDetails.TransId = @Pi_TransId
	AND CAST(ApportionSchemeDetails.SchId AS NVARCHAR(10))+'~'+CAST(ApportionSchemeDetails.SlabId AS NVARCHAR(10)) 
	IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10)) FROM BillAppliedSchemeHd WHERE FreeToBeGiven>0)

	--->Added the SchId+SlabId Concatenation By Nanda on 15/12/2010 in the above statement
	--->Added By Nanda on 20/09/2010
	SELECT * INTO #TempApp FROM ApportionSchemeDetails	
	DELETE FROM ApportionSchemeDetails
	INSERT INTO ApportionSchemeDetails
	SELECT DISTINCT * FROM #TempApp
	--->Till Here
	
	UPDATE ApportionSchemeDetails SET SchemeAmount=0 WHERE DiscPer>0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
	FROM 
	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
	WHERE RowId=10000 GROUP BY SchId) A,
	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId
	GROUP BY SchId) B
	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
	AND ApportionSchemeDetails.RowId=B.RowId AND ApportionSchemeDetails.TransId=@Pi_TransId AND ApportionSchemeDetails.UsrId=@Pi_UsrId  
	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	INSERT INTO @RtrQPSIds
	SELECT DISTINCT RtrId,SchId FROM BilledPrdHdForQPSScheme WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	IF @Pi_Mode=0
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,
		SISL.DiscountPerAmount-SISL.ReturnDiscountPerAmount AS DiscountPerAmount,SISL.FlatAmount-SISL.ReturnFlatAmount AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE DiscPer>0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId
		) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
		) A	
		GROUP BY A.SchId
		UNION  -- Added by Boopathy.P on 09-08-2011 for Bug No:23402
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,
		SISL.DiscountPerAmount-SISL.ReturnDiscountPerAmount AS DiscountPerAmount,SISL.FlatAmount-SISL.ReturnFlatAmount AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE DiscPer>0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId
		) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND (SM.FlexiSch=1 AND SM.FlexiSchType=1 AND SM.QPS=1) 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
		) A	
		GROUP BY A.SchId



		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
		WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId

		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId
	END
	ELSE IF @Pi_Mode=1
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount,SISL.FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL INNER JOIN
		(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE SchemeAmount=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		) A ON A.SchId=SISL.SchId AND A.SlabId=SISL.SlabId  INNER JOIN SchemeMaster SM 
		ON A.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 
		INNER JOIN SalesInvoice SI ON SISL.SalId=SI.SalId AND Si.DlvSts>3
		INNER JOIN @RtrQPSIds RQPS ON RQPS.RtrId=Si.RtrId AND SI.RtrId=@RtrId
		WHERE SISL.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		AND SISL.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		) A	GROUP BY A.SchId

		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI,
		SchemeMAster SM	
		WHERE B.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 AND 
		B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		AND B.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		AND B.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId

		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI,
		SchemeMAster SM	
		WHERE B.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 AND 
		B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		AND B.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		GROUP BY B.SchId
	END
	ELSE 
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount,SISL.FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL INNER JOIN
		(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE SchemeAmount=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		) A ON A.SchId=SISL.SchId AND A.SlabId=SISL.SlabId  INNER JOIN SchemeMaster SM 
		ON A.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 
		INNER JOIN SalesInvoice SI ON SISL.SalId=SI.SalId AND Si.DlvSts>3
		INNER JOIN @RtrQPSIds RQPS ON RQPS.RtrId=Si.RtrId AND SI.RtrId=@RtrId
		WHERE SISL.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		) A	GROUP BY A.SchId

		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
		WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId

		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId
	END	


	
	--->Added By Nanda on 04/03/2011 for Flexi Sch
	DELETE FROM @QPSGivenDisc WHERE SchId IN (SELECT SchId FROM SchemeMaster WHERE FlexiSch=1 AND FlexiSchType=2)

	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) 
	FROM ApportionSchemeDetails A
	INNER JOIN SchemeMaster	SM ON A.SchId=SM.SchId AND SM.QPS=1 AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId 
	GROUP BY A.SchId,B.Amount 

	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=2
	
	UPDATE A SET A.Contri=100*(B.GrossAmount/CASE C.GrossAmount WHEN 0 THEN 1 ELSE C.GrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=1

	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId )	
	AND ApportionSchemeDetails.TransId=@Pi_TransID AND ApportionSchemeDetails.UsrId=@Pi_UsrId

	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId )	
	AND ApportionSchemeDetails.TransId=@Pi_TransID AND ApportionSchemeDetails.UsrId=@Pi_UsrId
	-->Till Here

	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId AND ASD.SlabId=A.SlabId
	AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId

	UPDATE ASD SET SchemeAmount=SchemeAmount*SC.Contri
	FROM ApportionSchemeDetails ASD,
	(SELECT A.RowId,A.PrdId,A.PrdBatId,(A.GrossAmount/B.GrossAmount) AS Contri FROM BilledPrdHdForScheme A,
	(SELECT PrdId,PrdBatId,SUM(GrossAmount) AS GrossAmount FROM BilledPrdHdForScheme WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId
	GROUP BY PrdId,PrdBatId
	HAVING COUNT(*)>1) B
	WHERE A.PrdID=B.PrdID AND A.PrdBatId=B.PrdBatId) SC
	WHERE ASD.RowId=SC.RowId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId IN 
	(SELECT SchId FROM SchemeMAster WHERE QPS=0 AND CombiSch=0 AND FlexiSch=0)

END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ApplyReturnScheme')
DROP PROCEDURE Proc_ApplyReturnScheme
GO
/*
BEGIN TRANSACTION
EXEC [Proc_ApplyReturnScheme] 102,2,23
SELECT * FROM UserFetchReturnScheme 
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ApplyReturnScheme]
(
	@Pi_SalId int,
	@Pi_Usrid as int,
	@Pi_TransId as int
)
/******************************************************************************************
* PROCEDURE	: Proc_ApplyReturnScheme
* PURPOSE	: To Apply the Return Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Boopathy
* CREATED DATE	: 01/06/2007
* NOTE		: General SP for Returning the Scheme Details for the all type of Schemes
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}	
* 25/07/2009	Panneerselvam.k		Solve the Divied  By Zero Error
******************************************************************************************/
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Config		INT
	SET @Config=-1
	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN18' AND Status=1)
	BEGIN
		SET @Config=0 
	END
	ELSE IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN19' AND Status=1)
	BEGIN
		SET @Config=1
	END
	ELSE
	BEGIN
		SET @Config=-1
	END
	
	DECLARE @SchId			INT
	DECLARE @SlabId			INT
	DECLARE @PurOfEveryReq	INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @SchType		INT
	DECLARE @ProRata		INT
	DECLARE @RtrId			INT
	DECLARE @CurSlabId		INT
	DECLARE @PrdId			INT
	DECLARE @PrdbatId		INT
	DECLARE @RowId			INT
	DECLARE @Combi			INT
	DECLARE @SchCode		VARCHAR(100)
	DECLARE @FlexiSch		INT
	DECLARE @FlexiSchType	INT
	DECLARE @SchemeBudget	NUMERIC(18,6)
	DECLARE @SchLevelId			INT
	DECLARE @SchemeLvlMode		INT
	DECLARE @TempHier TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT
	)
	DECLARE @TempBilledAchCombi TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @SchEligiable TABLE
	(
		ManType			INT,
		Cnt				INT,
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId	INT,
		FrmSchAch 		NUMERIC(38,6),
		NoOfTimes		NUMERIC(38,6),
		SchId			INT,
		SlabId			INT
	)
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
	DECLARE @TempBilledCombiAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
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
		SchId			INT,
		SlabId			INT,
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
	DECLARE @FreePrdDt TABLE
	(
		SalId			INT,
		SchId			INT,
		SlabId			INT,
		FreeQty			INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
		FreePriceId		INT,
		GiftQty			INT,
		GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftPriceId		INT,
		PrdId			INT,
		PrdBatId		INT,
		RowId			INT
		
	)
	DECLARE @ReturnPrdHdForScheme TABLE
	(
		RowId		int,
		RtrId		int,
		PrdId		int,
		PrdBatId	int,
		SelRate		numeric(18,6),
		BaseQty		int,
		GrossAmount	numeric(18,6),
		TransId		tinyint,
		Usrid		int,
		SalId		bigint,
		RealQty		int,
		MRP			numeric(18,6)
	)
	DECLARE @t1 TABLE
	(
		SalId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		FlatAmt		NUMERIC(38,6),
		DiscPer		NUMERIC(38,6),
		Points		INT,
		NoofTimes	INT
	)
	DECLARE @TempSch1 Table
	(
		SalId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		BaseQty		NUMERIC(38,6),
		Selrate		NUMERIC(38,6),
		Grossvalue	NUMERIC(38,6),
		Schid		INT,
		Slabid		INT,
		Discper		NUMERIC(38,6),
		Flatamt		NUMERIC(38,6),
		Points		NUMERIC(38,6),
		NoofTimes	NUMERIC(38,6)
	)
	DECLARE @TempSch2 Table
	(
		SalId			INT,
		RowId			INT,
		PrdId			INT,
		PrdBatId		INT,
		Schid			INT,
		Slabid			INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6),
		Points			NUMERIC(38,6),
		Contri			NUMERIC(38,6),
		NoofTimes		NUMERIC(38,6)
	)
	DECLARE @MaxSchDt TABLE
	(
		SalId		INT,
		SchId		INT,
		SlabId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchAmt		NUMERIC(38,6)
	)
	DECLARE @SchGross TABLE
	(
		SchId	INT,
		Amt		NUMERIC(38,6)
	)
	--Apportion scheme amt prd wise
	DECLARE @DiscPer	NUMERIC(38,6)
	DECLARE @FlatAmt	NUMERIC(38,6)
	DECLARE @Points		INT
	DECLARE @SumValue	NUMERIC(38,6)
	DECLARE @FreePrd	INT
	DECLARE @GiftPrd	INT
	DECLARE @MaxPrdId	INT
	DECLARE @SalId		INT
	DECLARE @RefCode	VARCHAR(2)
	DECLARE @CombiSch	INT
	DECLARE @QPS		INT
	DECLARE @BillCnt	INT
	DECLARE @SchCnt		INT
	DECLARE @TempSlabId	INT
	DECLARE @Cnt1	AS	INT
	DECLARE @Cnt2	AS	INT
	DECLARE @FlatChk1 AS INT
	DECLARE @FlatChk2 AS INT
	DELETE FROM SalesReturnDbNoteAlert WHERE SalId=@Pi_SalId
	IF @Config=0
	BEGIN
		DELETE FROM UserFetchReturnScheme WHERE SalId=@Pi_SalId AND Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		INSERT INTO UserFetchReturnScheme(SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
		SELECT SalId,PrdId,PRdBatId,SchId,SlabId,SUM(Discamt),SUM(Flatamt),SUM(Points),FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId FROM 
		(
			SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
			((SIL.DiscountPerAmount-SIL.PrimarySchemeAmt-SIL.ReturnDiscountPerAmount)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty) AS Discamt,
			((SIL.FlatAmount-SIL.ReturnFlatAmount)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty) AS Flatamt,0 AS Points,
			0 AS FreeQty,0 AS FreePrdId,0 AS FreePrdBatId,0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,
			0 AS NoofTimes,@Pi_Usrid AS Usrid,@Pi_TransId AS TransId,RPS.RowId,0 AS FreePriceId,0 AS GiftPriceId
			FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
			INNER JOIN SalesInvoiceSchemeLineWise SIL ON SIL.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId 
			AND SIP.PrdBatId=SIL.PrdBatId AND SIP.Slno=SIL.RowId INNER JOIN
			ReturnPrdHdForScheme RPS ON RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND RPS.RtrId=SI.RtrId 
			WHERE SI.SalId=@Pi_SalId AND usrid = @Pi_Usrid AND TransId = @Pi_TransId
			UNION 
			SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
			0 AS Discamt,0 AS Flatamt,((SIL.Points-SIL.ReturnPoints)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty) AS Points,
			0 AS FreeQty,0 AS FreePrdId,0 AS FreePrdBatId,0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,
			0 AS NoofTimes,@Pi_Usrid AS Usrid,@Pi_TransId AS TransId,RPS.RowId,0 AS FreePriceId,0 AS GiftPriceId
			FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
			INNER JOIN SalesInvoiceSchemeDtPoints SIL ON SIL.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId 
			AND SIP.PrdBatId=SIL.PrdBatId INNER JOIN
			ReturnPrdHdForScheme RPS ON RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND RPS.RtrId=SI.RtrId 
			WHERE SI.SalId=@Pi_SalId AND usrid = @Pi_Usrid AND TransId = @Pi_TransId
		) A 
		---Nanda
		WHERE PrdId IS NOT NULL AND A.SchId NOT IN (SELECT  DISTINCT SchID FROM SchemeMaster WHERE Qps=1 AND ApyQPSSch=1)
		GROUP BY SalId,PrdId,PRdBatId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId

		DELETE FROM UserFetchReturnScheme WHERE SchId IN (SELECT  SchId FROM SchemeMaster WHERE CombiType=1)
		
		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@Pi_SalId
		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT a.SchId,a.SlabId FROM SalesInvoiceSchemeDtFreePrd a INNER JOIN SchemeMaster B On A.SchId=B.SchId
		WHERE a.SalId=@Pi_SalId AND B.CombiType=0 AND B.SchId NOT IN (SELECT  DISTINCT SchID FROM SchemeMaster WHERE Qps=1 AND ApyQPSSch=1)
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId,@CurSlabId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId
			SELECT @RowId=MIN(B.RowId) FROM ReturnPrdHdForScheme B  
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C ON
			C.PrdId = B.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
			INSERT INTO ReturnPrdHdForScheme
			SELECT A.Slno,@RtrId,A.Prdid,A.PrdBatId,A.PrdUnitSelRate,A.BaseQty-A.ReturnedQty,
			(A.BaseQty-A.ReturnedQty)*A.PrdUnitSelRate,@Pi_TransId,@Pi_UsrId,@Pi_SalId,0,A.PrdUnitMRP
			FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
			WHERE A.SalId=@Pi_SalId AND A.PrdId NOT IN (SELECT Distinct PrdId FROM ReturnPrdHdForScheme
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND SalId = @Pi_SalId )
			SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
			TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId
			INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,
			GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
			SELECT A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,CEILING((FreeQty/A.BaseQty)*SUM(B.RealQty)),
			0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM
			(SELECT A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,(A.FreeQty-A.ReturnFreeQty) AS FreeQty,A.FreePriceId,
			SUM((B.BaseQty-B.ReturnedQty)) AS BaseQty FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN 
			SalesInvoiceProduct B ON A.SalId=B.SalId INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C 
			ON B.PrdId=C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End 
			WHERE A.SchId=@SchId AND A.SlabId=@CurSlabId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,A.FreeQty,A.ReturnFreeQty,A.FreePriceId) AS A
			INNER JOIN ReturnPrdHdForScheme B ON A.SalId=B.SalId
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C ON
			C.PrdId = B.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,A.BaseQty
			FETCH NEXT FROM SchemeFreeCur INTO @schid,@CurSlabId
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur
		DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)<=0
		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				IF NOT EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId 
								AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UsrId=@Pi_Usrid)
				BEGIN
					INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
								RowId,FreePriceId,GiftPriceId)
					SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
								RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
								WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
								AND PrdId IS NOT NULL
				END
				ELSE
				BEGIN
					INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
								RowId,FreePriceId,GiftPriceId)
								SELECT DISTINCT A.SalID,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,0,0,0,B.FreeQty,B.FreePrdId,B.FreePrdBatId,
								B.GiftQty,B.GiftPrdId,B.GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
								B.RowId,B.FreePriceId,B.GiftPriceId FROM UserFetchReturnScheme A INNER JOIN @FreePrdDt B
								ON A.SalId=B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId --AND A.SchId=B.SchId AND A.SlabId=B.SlabId
								WHERE A.PrdId=@PrdId  AND B.PrdBatId=@PrdBatId AND A.SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid
								AND A.PrdId IS NOT NULL
				END	
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 	
							WHERE PrdId IS NOT NULL
			END
			DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)=0
		END	
	END
	ELSE IF @Config=1
	BEGIN
		Declare SchemeCur Cursor for
		SELECT distinct C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeLineWise a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		UNION
		SELECT distinct C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeDtPoints a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		open SchemeCur
		fetch next FROM SchemeCur into @SchId,@CombiSch,@QPS 
		while @@fetch_status= 0
		begin
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			DELETE FROM @TempBilledAchCombi				
			DELETE FROM @TempBilledCombiAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd 
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BASEQTY>0
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
				--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
				INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
				SELECT ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
				-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
					WHEN 2 THEN SUM(SchemeOnAmount)
					WHEN 3 THEN (CASE A.UomId
							WHEN 2 THEN SUM(SchemeOnKg) * 1000
							WHEN 3 THEN SUM(SchemeOnKg)
							WHEN 4 THEN SUM(SchemeOnLitre) * 1000
							WHEN 5 THEN SUM(SchemeOnLitre)	END)
						END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
					ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
				-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
					WHEN 2 THEN SUM(SchemeOnAmount)
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
					SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
						INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
						WHERE
					A.FrmSchAch >= B.FromQty AND
					A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
						ORDER BY A.SlabId DESC) As SlabId
		
			SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				
				IF @SlabId> 0 
				BEGIN
					--To Get the Number of Times the Scheme should apply
					IF @PurOfEveryReq = 0
					BEGIN
						SET @NoOfTimes = 1
					END
					ELSE
					BEGIN
					
						SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				END
				ELSE
				BEGIN
					SET @NoOfTimes =1
				END
				INSERT INTO @TempSch1 (SalId,RowId,PrdId,PrdBatId,BaseQty,Selrate,Grossvalue,Schid,Slabid,
    			Discper,Flatamt,Points,NoofTimes)
	   			SELECT DISTINCT a.SalId,a.RowId,C.PrdId,a.PrdBatId,
				CASE A1.BaseQty WHEN 0 THEN A1.RealQty ELSE A1.BaseQty END,a1.SelRate,--A1.BaseQty*a1.SelRate,
				CASE A1.BaseQty WHEN 0 THEN a1.RealQty ELSE A1.BaseQty END *a1.SelRate,
				@SchId,D.SlabId,(d.DiscPer+d.FlxDisc),(d.FlatAmt-d.FlxValueDisc),
				D.Points+D.FlxPoints,@NoOfTimes FROM SalesInvoiceSchemeLineWise A 
				INNER JOIN ReturnPrdHdForScheme a1 ON A.PrdId=a1.PrdId AND a.PrdBatId=a1.PrdbatId 
				AND A.SalId=a1.SalId and a1.Usrid = @Pi_Usrid AND a1.TransId = @Pi_TransId 
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END
				INNER JOIN SchemeSlabs d ON d.SchId=A.SchId AND D.SchId=@SchId AND D.SlabId=@SlabId
				INNER JOIN SalesInvoiceProduct G ON A.PrdId=G.PrdId AND A.PrdBatId=G.PrdBatId AND G.SalId=a.SalId
				WHERE a.SalId= @Pi_SalId
				IF @SlabId>0 
				BEGIN
					SELECT @DiscPer = (SELECT ROUND(ISNULL(SUM(b.DiscountPerAmount-b.ReturnDiscountPerAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.DiscountPerAmount-b.ReturnDiscountPerAmount)>0)
					
					SELECT @FlatAmt = (SELECT ROUND(ISNULL(SUM(b.FlatAmount-b.ReturnFlatAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.FlatAmount-b.ReturnFlatAmount)>0) 
					
					SELECT @Points = (SELECT ISNULL(Sum(b.Points-b.ReturnPoints),0) FROM dbo.SalesInvoiceSchemeDtPoints b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.Points-b.ReturnPoints)>0)
					SELECT @SumValue = (SELECT Sum(Grossvalue) FROM @TempSch1 WHERE SalId = @Pi_SalId AND SchId = @SchId)
	
					IF @DiscPer>0 
					BEGIN
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								((A.Grossvalue*A.Discper)/100)*@NoOfTimes as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								(C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								CASE WHEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-((A.Grossvalue*A.Discper)/100) <0 
								THEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)*@NoOfTimes
								ELSE (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) END	as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								 (SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId)B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue)>B.SchemeDiscount)
								BEGIN
									SET ROWCOUNT 1
									UPDATE A SET A.SchemeDiscount=A.SchemeDiscount+B.SchemeDiscount
									FROM @TempSch2 A
									INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
									WHERE (C.Grossvalue)>B.SchemeDiscount
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN							
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount,0,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
					END
			
					IF @FlatAmt>0
					BEGIN
						SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
						SELECT @FlatChk2=ISNULL(SUM(B.BaseQty),0) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
									0,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
									SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat1
									FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
									DELETE FROM @TempSch2 WHERE SchemeAmount<0 
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
									#temp_Flat1 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
								END
								ELSE
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes),
									0 as SchemeDiscount,
									0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
									SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat3
									FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
									DELETE FROM @TempSch2 WHERE SchemeAmount<0 
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
									#temp_Flat3 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
								END
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 as SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat2 
								FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
								DELETE FROM @TempSch2 WHERE SchemeAmount<0 
								UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
								FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
								#temp_Flat2 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
			
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount,0 as SchemeDiscount,
									0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
								ELSE
								BEGIN
									SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
									FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
									A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									WHERE A.SalId=@Pi_SalId
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
									0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
									AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
									INNER JOIN SalesInvoiceProduct B ON 
									A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
									IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.SchemeAmount))
									BEGIN
										SET ROWCOUNT 1
										UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
										FROM @TempSch2 A INNER JOIN 
										(SELECT A.SalId,A.Schid,A.SlabId,
										CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
										(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
										SchemeDiscount,Points,Contri,NoOfTimes FROM
										(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
										(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
										0 As SchemeDiscount,0 As Points,
										(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
										FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
										AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
										WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
										(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
										A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
										SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
										A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
										AND A.SchId=B.SchId And A.SlabId=B.SlabId 
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
										WHERE (C.Grossvalue>B.SchemeAmount)
										SET ROWCOUNT 0
									END
									ELSE
									BEGIN
										INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
										SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
										SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
										0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
										(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
										SchemeDiscount,Points,Contri,NoOfTimes FROM
										(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
										(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
										0 As SchemeDiscount,0 As Points,
										(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
										FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
										AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
										WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
										(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
										A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
										SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
										A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
									END
								END
							END
							ELSE
							BEGIN								
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId 
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,
								CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
								0 As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue>B.SchemeAmount))
								BEGIN				
									SET ROWCOUNT 1					
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.SchemeAmount)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
					END
					IF @Points>0
					BEGIN
						SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
						SELECT @FlatChk2=SUM(B.BaseQty) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,
									(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
								ELSE
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,
									((C.Points-C.ReturnPoints)-(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount, 0 as SchemeDiscount,
								(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,0 as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
									AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
							END
							ELSE
							BEGIN
								
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId 
								WHERE A.SalId=@Pi_SalId 
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 AS SchemeDiscount,
								(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.SchId=C.SchId
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
								,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								0 AS SchemeAmount,0 As SchemeDiscount,
								(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue)>B.Points)
								BEGIN			
									SET ROWCOUNT 1						
									UPDATE A SET A.Points=A.Points+B.Points
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
									,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									0 AS SchemeAmount,0 As SchemeDiscount,
									(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.Points)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0,0,ROUND(A.Points,0)*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									0 AS SchemeAmount,0 As SchemeDiscount,
									(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId 
								END
							END
						END
					END
				END		
				ELSE
				BEGIN
					INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
					SchemeDiscount,Points,Contri,NoofTimes)
					SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
					(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
					(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1
					FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
					UNION
					SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
					0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints)*@NoOfTimes As Points,
					100 As Contri,1 AS NoOfTimes
					FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
					AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
					WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
				
					INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
					SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
						SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
						SchemeDiscount,SchemeAmount,Points,0,@Pi_UsrId,@Pi_TransId FROM
						(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
						(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
						(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1 AS NoTimes 
						FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
						WHERE NOT EXISTS (
						SELECT PrdId,PrdBatId,SalId FROM
						(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
						AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
						WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
						A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
						UNION
						SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
						SchemeDiscount,SchemeAmount,Points*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
						(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid AS SlabId,
						0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints) As Points
						FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
						AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
						WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
						WHERE NOT EXISTS (
							SELECT PrdId,PrdBatId,SalId FROM
							(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
							INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
							AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
							WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
							A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
				END
			--Nanda
			DROP TABLE #tempBilledPrd
			FETCH NEXT FROM SchemeCur INTO @schid ,@CombiSch,@QPS
		END
		CLOSE SchemeCur
		DEALLOCATE SchemeCur
		DELETE FROM SalesReturnDbNoteAlert WHERE (SchDiscAmt+SchFlatAmt+SchPoints)=0
		SELECT SalId,SchId,SlabId,SUM(CAST(SchemeAmount AS NUMERIC(18,6))) AS SchAmt,SUM(SchemeDiscount) AS SchDisc,
		SUM(Points) AS SchPoints INTO #Test1 FROM @TempSch2
		GROUP BY SalId,SchId,SlabId 
		DELETE A FROM  @TempSch2 A INNER JOIN #Test1 B ON A.SalId=B.SalId AND A.SchId=B.SchId
		AND A.SlabId=B.SlabId WHERE B.SchAmt=0 AND B.SchDisc=0 AND B.SchPoints=0
		INSERT INTO UserFetchReturnScheme(SalId,RowId,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,FreePriceId,GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,NoofTimes,Usrid,TransId)
		SELECT a.SalId,a.RowId,a.PrdId,a.PrdBatId,b.SchId,b.SlabId,b.SchemeDiscount,b.SchemeAmount,
			b.Points,0,0,0,0,0,0,0,0,b.NoofTimes,@Pi_Usrid,@Pi_TransId
		FROM ReturnPrdHdForScheme a INNER JOIN @TempSch2 b ON
		a.SalId=b.SalId AND a.PrdId = b.PrdId AND a.PrdBatId=b.PrdBatId --AND a.RowId=B.RowId
		WHERE a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId = @Pi_SalId
		ORDER BY a.RowId
		DECLARE SchUpdateCur CURSOR FOR
		SELECT DISTINCT SalId,SchId,SlabId FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		OPEN SchUpdateCur
		FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		WHILE @@fetch_status= 0
		BEGIN
		
		   SELECT @MaxPrdId = (SELECT MAX(a.PrdId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND a.FreeQty<>0
		   AND a.SchId =@SchId AND a.SlabId = @SlabId HAVING COUNT(a.SchId) >1)
		   SELECT @PrdBatId = (SELECT DISTINCT MAX(a.PrdbatId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND
		   a.PrdId=@MaxPrdId)
		   UPDATE UserFetchReturnScheme SET FreeQty = 0,GiftQty=0 FROM
		   UserFetchReturnScheme a WHERE a.SalId = @Pi_SalId AND a.Usrid = @Pi_Usrid AND a.TransId = @Pi_TransId
		   AND  a.PrdBatId <> @PrdBatId AND a.SchId = @SchId AND a.SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE GiftPrdId <> 0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId<>0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND FreeQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId<>0 AND GiftPrdBatId<>0 AND GiftQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		
		   FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		END
		CLOSE SchUpdateCur
		DEALLOCATE SchUpdateCur
		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@SalId
		SELECT @RefCode=ISNULL(PrimaryRefCode,'XX') FROM SalesInvoice WHERE SalId=@SalId
		IF @RefCode <> 'XX'
		BEGIN
			SELECT DISTINCT PrdId,PrdBatId,SchId AS SchId ,SlabId,RowId INTO #TmpPrdDt 
			FROM UserFetchReturnScheme WHERE DiscAmt > 0
			UPDATE UserFetchReturnScheme SET DiscAmt = CASE WHEN (DiscAmt - tmp.Prim)>0 THEN (DiscAmt - tmp.Prim) ELSE 0 END FROM
			(SELECT F.SchId,F.SlabId,B.PrdId,B.PrdBatId,B.RowID,B.GrossAmount - (B.GrossAmount /(1 +( CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@SalId)
			WHEN 1 THEN   D.PrdBatDetailValue ELSE 0 END)/100)) AS Prim FROM BilledPrdHdForScheme B INNER JOIN ProductBatchDetails D ON D.PrdBatId = B.PrdBatId  AND D.DefaultPrice=1
			INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId AND E.Slno = D.Slno AND E.RefCode = @RefCode
			INNER JOIN #TmpPrdDt F ON B.PrdId=F.PrdId AND F.PrdBatId=B.PrdBatId AND B.RowId=F.RowId
			WHERE B.usrid = @Pi_Usrid And B.transid = @Pi_TransId) tmp,UserFetchReturnScheme A
			WHERE A.usrid = @Pi_Usrid And A.transid = @Pi_TransId AND A.SchId=tmp.schId AND A.SlabId=tmp.SlabId
			AND A.PrdId=tmp.PrdId AND A.PrdBatId=tmp.PrdBatId AND A.RowId=tmp.RowId AND A.DiscAmt >0
		END
		SELECT DISTINCT * INTO #UserFetchReturnScheme FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		DELETE FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		INSERT INTO UserFetchReturnScheme SELECT  * FROM #UserFetchReturnScheme
		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT a.SchId FROM BillAppliedSchemeHd a WHERE a.TransId=@Pi_TransId AND a.UsrId=@Pi_Usrid 
		AND (a.FreeToBeGiven + a.GiftToBeGiven+a.FlxFreePrd+a.FlxGiftPrd)>0 AND a.IsSelected=1
		UNION 
		SELECT SchId FROM dbo.SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd1
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd1 E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId 
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
			--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
			INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
			SELECT ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.UomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
				ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
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
				SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
					INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
					WHERE
				A.FrmSchAch >= B.FromQty AND
				A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
					ORDER BY A.SlabId DESC) As SlabId
				SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				--Store the Slab Free Product Details into a temp table
				INSERT INTO @TempSchSlabFree(ForEveryQty,ForEveryUomId,FreePrdId,FreeQty)
				SELECT A.ForEveryQty,A.ForEveryUomId,B.PrdId,B.FreeQty From
					SchemeSlabs A INNER JOIN SchemeSlabFrePrds B ON A.Schid = B.Schid
					AND A.SlabId = B.SlabId INNER JOIN Product C ON B.PrdId = C.PrdId
					WHERE A.Schid = @SchId And A.SlabId = @SlabId AND C.PrdType <> 4
				--To Get the Number of Times the Scheme should apply
				IF @PurOfEveryReq = 0
				BEGIN
					SET @NoOfTimes = 1
				END
				ELSE
				BEGIN
					SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				IF @SlabId>0
				BEGIN
				DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_Usrid  AND SchId=@SchId
				INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
				Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
				FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
				BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
				SELECT DISTINCT @SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
					@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
					0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
					CASE @SchType 
						WHEN 1 THEN 
							CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END 
						WHEN 2 THEN 
							CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
						WHEN 3 THEN
							CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
					END
					 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
					0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,1 as IsSelected,@SchemeBudget as SchBudget,
					0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId,0
					FROM @TempBilled , @TempSchSlabFree
					GROUP BY FreePrdId,FreeQty,ForEveryQty
					SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
					TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
					INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
					GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
					SELECT DISTINCT @Pi_SalId,@SchId,@SlabId,(E.FreeQty-E.ReturnFreeQty)-B.FreeToBeGiven AS FreeQty,
					E.FreePrdId,E.FreePrdBatId,E.FreePriceId AS FreePriceId,
					0 AS GiftQty,0,0,0 AS GiftPriceId,
					B.PrdId,B.PrdBatId,@RowId AS RowId FROM	BillAppliedSchemeHd B 
					INNER JOIN SalesInvoiceSchemeDtFreePrd E ON  B.SchId=E.SchId AND B.FreePrdId=E.FreePrdId
					WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId
					AND B.IsSelected=1 AND E.SalId=@Pi_SalId
				END
				ELSE IF @SlabId=0
				BEGIN
					IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
							AND (B.FreeToBeGiven + B.GiftToBeGiven+B.FlxFreePrd+B.FlxGiftPrd)>0 AND B.IsSelected=1 AND SchId=@SchId )
					BEGIN
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,B.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,FreePriceId AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
						INNER JOIN SalesInvoiceSchemeDtFreePrd E ON B.SchId=E.SchId AND B.SlabId=E.SlabId
						INNER JOIN @ReturnPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdbatId=C.PrdbatId
						WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId 
						AND B.IsSelected=1 AND E.SalId=@Pi_SalId
					END
					ELSE
					BEGIN
						SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
						SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,E.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
						SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId
					END
				END
			FETCH NEXT FROM SchemeFreeCur INTO @schid
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur	
		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
							WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 						
			END
			UPDATE A Set FreeQty=B.FreeQty ,FreePrdId=B.FreePrdId ,FreePrdBatId=B.FreePrdBatId,
					GiftQty=B.GiftQty ,GiftPrdId=B.GiftPrdId,GiftPrdBatId=B.GiftPrdBatId,
					FreePriceId=B.FreePriceId ,GiftPriceId=B.GiftPriceId FROM UserFetchReturnScheme A
					INNER JOIN @FreePrdDt B ON A.SalId=B.SalId AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.RowId=B.RowId
					AND A.FreePrdId=B.FreePrdId
					WHERE A.SalId=@Pi_SalId
			DELETE FROM UserFetchReturnScheme WHERE DiscAmt+FlatAmt+Points+FreeQty+GiftQty=0
		END	
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_QPSSchemeCrediteNoteConversion')
DROP PROCEDURE Proc_QPSSchemeCrediteNoteConversion
GO
/*
BEGIN TRANSACTION
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2011-07-25',0
SELECT * FROM SchQPSConvDetails WHERE schid=125
SELECT * FROM CreditNoteRetailer
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].Proc_QPSSchemeCrediteNoteConversion
(
	@Pi_TransId		INT,
	@Pi_TransDate	DATETIME,
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_QPSSchemeCrediteNoteConversion
* PURPOSE		: To Apply the QPS Scheme and convert the Scheme amount as credit note
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
	DECLARE @RtrId				AS INT
	DECLARE @RtrCode			AS NVARCHAR(100)
	DECLARE @CmpRtrCode			AS NVARCHAR(100)
	DECLARE @RtrName			AS NVARCHAR(200)
	DECLARE @UsrId				AS INT
	DECLARE @SchApplicable		AS INT
	DECLARE @SMId				AS INT
	DECLARE @RMId				AS INT
	DECLARE	@SchId				AS INT
	DECLARE	@SchCode			AS NVARCHAR(200)
	DECLARE	@CmpSchCode			AS NVARCHAR(200)
	DECLARE	@CombiSch			AS INT
	DECLARE	@QPS				AS INT	
	DECLARE	@LcnId				AS INT	
	DECLARE	@AvlSchId			AS INT
	DECLARE	@AvlSlabId			AS INT
	DECLARE	@AvlSchCode			AS NVARCHAR(200)
	DECLARE	@AvlCmpSchCode		AS NVARCHAR(200)
	DECLARE	@AvlSchAmt			AS NUMERIC(38,6)
	DECLARE	@AvlSchDiscPerc		AS NUMERIC(38,6)
	DECLARE	@SchAmtToConvert	AS NUMERIC(38,6)
	DECLARE	@SchApplicableAmt   AS NUMERIC(38,6)
	
	DECLARE	@AvlSchDesc			AS NVARCHAR(400)
	DECLARE @SchCoaId			AS INT
	DECLARE	@CrNoteNo			AS NVARCHAR(200)
	DECLARE @ErrStatus			AS INT
	DECLARE @VocDate			AS DATETIME
	DECLARE @MinPrdId			AS INT
	DECLARE @MinPrdBatId		AS INT
	DECLARE @MinRtrId			AS INT	



	DECLARE @SchemeAvailable TABLE
	(
		SchId			INT,
		SchCode			NVARCHAR(200),
		CmpSchCode		NVARCHAR(200),
		CombiSch		INT,
		QPS				INT		
	)
	DECLARE @Condition	INT
	DECLARE @Mode		INT


	SELECT @SchCoaId=CoaId FROM COAMaster WHERE Accode='4220001'	
	SET @LcnId=0
	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1
	IF @LcnId=0
	BEGIN
		SELECT @LcnId=LcnId FROM Location WHERE LcnId IN (SELECT MIN(LcnId) FROM Location)
	END	

	IF NOT EXISTS (SELECT * FROM Configuration WHERE ModuleName='Billing QPS Scheme' AND ModuleId IN ('BILLQPS3') AND Status=1)
	BEGIN
		SELECT @Condition=Condition FROM Configuration WHERE ModuleId IN ('DAYENDPROCESS4')
		SET @Pi_TransDate = DATEADD(D,(@Condition)*-1,@Pi_TransDate)
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM Configuration WHERE ModuleName='Billing QPS Scheme' AND ModuleId IN ('BILLQPS3') 
					AND Status=1)
		BEGIN
			SELECT @Mode=Condition FROM Configuration WHERE ModuleName='Billing QPS Scheme' AND ModuleId IN ('BILLQPS3')
			IF @Mode=0
			BEGIN
				SELECT @Condition=ConfigValue FROM Configuration WHERE ModuleName='Billing QPS Scheme' 
				AND ModuleId IN ('BILLQPS3') AND Status=1
				SET @Pi_TransDate = DATEADD(D,(@Condition)*-1,@Pi_TransDate)
			END
			ELSE
			BEGIN
				SELECT @Condition=Condition FROM Configuration WHERE ModuleId IN ('DAYENDPROCESS4')
				SET @Pi_TransDate = DATEADD(D,(@Condition)*-1,@Pi_TransDate)
			END
		END
	END
	
	if exists (select * from dbo.sysobjects where id = object_id(N'[TempSalesInvoiceQPSRedeemed]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [TempSalesInvoiceQPSRedeemed]	
	SELECT * INTO TempSalesInvoiceQPSRedeemed FROM SalesInvoiceQPSRedeemed

	SET @SMId=0
	SET @RMId=0
	SET @MinPrdId=0
	SET @MinPrdBatId=0
	SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesMan
	SELECT @RMId=ISNULL(MAX(RMId),0) FROM RouteMaster
	SELECT @MinPrdId=ISNULL(MIN(PrdId),0) FROM Product
	SELECT @MinPrdBatId=ISNULL(MIN(PrdBatId),0) FROM ProductBatch
	SELECT @MinRtrId=ISNULL(MIN(RtrId),0) FROM Retailer	
	SELECT @MinPrdId=ISNULL(MIN(PrdId),0) FROM ProductBatch WHERE PrdBatId=@MinPrdBatId
	SET @Po_ErrNo=0
	SET @UsrId=10000
	IF @SMId<>0 AND @RMId<>0 AND @MinPrdId<>0 AND @MinPrdBatId<>0 AND @MinRtrId<>0
	BEGIN
		DELETE FROM BilledPrdHdForScheme 

		--->To insert dummy invoice and details for applying QPS scheme		
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	
		INSERT INTO SalesInvoice (SalId,SalInvNo,SalInvDate,SalInvRef,CmpId,LcnId,BillType,BillMode,SMId,RMId,DlvRMId,RtrId,InterimSales,FillAllPrd,OrderKeyNo,
		OrderDate,BillShipTo,RtrShipId,Remarks,SalGrossAmount,SalRateDiffAmount,SalSplDiscAmount,SalSchDiscAmount,SalDBDiscAmount,SalTaxAmount,SalCDPer,
		SalCDAmount,SalCDGivenOn,RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrCDEdited,DBAdjAmount,CRAdjAmount,MarketRetAmount,OtherCharges,WindowDisplay,
		WindowDisplayAmount,OnAccount,OnAccountAmount,ReplacementDiffAmount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
		SalPayAmt,SalRoundOff,SalRoundOffAmt,DlvSts,VehicleId,DlvBoyId,SalDlvDate,BillSeqId,ConfigWinDisp,DecPoints,Upload,SchemeUpLoad,SalOffRoute,
		PrimaryRefCode,PrimaryApplicable,InvType,Availability,LastModBy,LastModDate,AuthId,AuthDate,BillPurUpLoad,FundUpload)
		VALUES (-1000,'JJDummyForQPS',GETDATE(),'',0,@LcnId,1,2,@SMId,@RMId,@RMId,@MinRtrId,0,0,'',GETDATE(),1,15,'',23653.28,0,0,1182.66,0,2808.83,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,
		2808.83,1182.66,25279.44,0,25279.5,0,1,0.05,4,1,1,GETDATE(),1,1,2,1,1,0,'',0,1,1,1,GETDATE(),1,GETDATE(),1,1)
		INSERT INTO SalesInvoiceProduct(SalId,PrdId,PrdBatId,Uom1Id,Uom1ConvFact,Uom1Qty,Uom2Id,Uom2ConvFact,Uom2Qty,BaseQty,SalSchFreeQty,SalManFreeQty,
		ReasonId,PrdUnitMRP,PrdUnitSelRate,PrdUom1SelRate,PrdUom1EditedSelRate,PrdRateDiffAmount,PrdGrossAmount,PrdGrossAmountAftEdit,SplDiscAmount,
		SplDiscPercent,PrdSplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,PrdCDAmount,PrdTaxAmount,PrdUom1NetRate,PrdUom1EditedNetRate,PrdNetRateDiffAmount,
		PrdActualNetAmount,PrdNetAmount,SlNo,DrugBatchDesc,RateDiffClaimId,DlvBoyClmId,SmIncCalcId,SmDAClaimId,VanSubsidyClmId,SplDiscClaimId,RateEditClaimReq,
		VatTaxClmId,ReturnedQty,ReturnedManFreeQty,PriceId,SplPriceId,PrimarySchemeAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate,RdClaimflag,
		KeyClaimflag)
		VALUES (-1000,@MinPrdId,@MinPrdBatId,1,1,2,0,0,0,400,0,0,0,24,17.87,3574,3574,0,7148,7148,0,0,0,357.4,0,0,848.83,3819.71,0,0,7639.43,7639.43,2,'',0,0,0,0,0,0,0,0,0,0,
		1,0,0,1,1,GETDATE(),1,GETDATE(),0,0)
		SET @SMId=0
		SET @RMId=0

		--->Retailerwise QPS conversion
		IF EXISTS (SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
			FROM Fn_ReturnApplicableProductDtQPS() B 
			INNER JOIN SchemeMaster C WITH(NoLock) ON C.SchId = B.SchId WHERE
			C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1 
			AND C.SchId NOT IN (SELECT DISTINCT SchId FROM SchQPSConvDetails WITH(NoLock)))
		BEGIN 
			DECLARE Cur_Retailer CURSOR	
			FOR SELECT distinct R.RtrId,R.RtrCode,R.CmpRtrCode,R.RtrName FROM Retailer  R WITH(NoLock) 
				INNER JOIN SalesInvoiceQPSCumulative B WITH(NoLock)ON B.RtrId = R.RtrId
				INNER JOIN SchemeMaster C WITH(NoLock) ON C.SchId = B.SchId  AND C.SchValidTill < @Pi_TransDate 
				AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1 AND C.SchId NOT IN (SELECT DISTINCT SchId FROM SchQPSConvDetails WITH(NoLock))
			OPEN Cur_Retailer
			FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
			WHILE @@FETCH_STATUS=0
			BEGIN
				TRUNCATE TABLE BilledPrdHdForScheme      
				DELETE FROM @SchemeAvailable
				INSERT INTO BilledPrdHdForScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice)
				VALUES(2,@RtrId,1,1,10.00,100,1000.00,12.00,2,@UsrId,7.50)

				INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
				SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
				FROM Fn_ReturnApplicableProductDtQPS() B 
				INNER JOIN SchemeMaster C WITH(NoLock) ON C.SchId = B.SchId WHERE
				C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1 
				AND C.SchId NOT IN (SELECT SchId FROM TempSalesInvoiceQPSRedeemed WITH(NoLock) WHERE SalId=-1000) 
				AND C.SchId NOT IN (SELECT SchId FROM SchQPSConvDetails WITH(NoLock))

				
				SELECT @RMId=ISNULL(MAX(RMId),0) FROM RetailerMarket WHERE RtrId=@RtrId
				SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesmanMarket WHERE RMId=@RMId
				
				IF @RMId=0
				BEGIN
					SELECT @RMId=ISNULL(MAX(RMId),0) FROM SalesInvoice WHERE RtrId=@RtrId
				END
				IF @SMId=0
				BEGIN
					SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesInvoice WHERE RMId=@RMId AND RtrId=@RtrId
				END
				IF @SMId=0
				BEGIN
					SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesInvoice WHERE RtrId=@RtrId
				END
				UPDATE SalesInvoice SET RtrId=@RtrId,SMId=@SMId,RMId=@RMId WHERE SalId=-1000
				
				TRUNCATE TABLE BillAppliedSchemeHd 
				TRUNCATE TABLE ApportionSchemeDetails 
				TRUNCATE TABLE BilledPrdRedeemedForQPS 
				TRUNCATE TABLE BilledPrdHdForQPSScheme

				--->Applying QPS Scheme
				DECLARE Cur_Scheme CURSOR	
				FOR SELECT DISTINCT SchId,SchCode,CmpSchCode,CombiSch,QPS FROM @SchemeAvailable
				OPEN Cur_Scheme 
				FETCH NEXT FROM Cur_Scheme INTO @SchId,@SchCode,@CmpSchCode,@CombiSch,@QPS
				WHILE @@FETCH_STATUS=0
				BEGIN
									
					SET @SchApplicable=0
					EXEC Proc_ReturnSchemeApplicable @SMId,@RMId,@RtrId,1,1,@SchId,@Po_Applicable= @SchApplicable OUTPUT
					IF @SchApplicable =1
					BEGIN
						IF @CombiSch=1
						BEGIN
							EXEC Proc_ApplyCombiSchemeInBill @SchId,@RtrId,0,@UsrId,2		
						END
						ELSE
						BEGIN
							EXEC Proc_ApplyQPSSchemeInBill @SchId,@RtrId,0,@UsrId,2		
						END
					END

					FETCH NEXT FROM Cur_Scheme INTO @SchId,@SchCode,@CmpSchCode,@CombiSch,@QPS
				END
				CLOSE Cur_Scheme
				DEALLOCATE Cur_Scheme
				--->To get the Free Products
				IF EXISTS(SELECT DISTINCT SchId,SlabId  FROM BillAppliedSchemeHd  Where TransId = 2 And UsrId = @UsrId
				AND FreeToBeGiven >0)
				BEGIN			
					DECLARE Cur_SchFree CURSOR	
					FOR SELECT DISTINCT SchId,SlabId  FROM BillAppliedSchemeHd  Where TransId = 2 And UsrId = @UsrId
					AND FreeToBeGiven >0
					OPEN Cur_SchFree
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSlabId
					WHILE @@FETCH_STATUS=0
					BEGIN	
						EXEC Proc_ReturnSchMultiFree @UsrId,2,@LcnId,@AvlSchId,@AvlSlabId,-1000
						FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSlabId
					END
					CLOSE Cur_SchFree
					DEALLOCATE Cur_SchFree
				END
		
				CREATE TABLE #AppliedSchemeDetails
				(
					SchId			INT,
					SchCode			NVARCHAR(200),
					CmpSchCode		NVARCHAR(200),
					FlexiSch		INT,
					FlexiSchType	INT,
					SlabId			INT,
					SchemeAmount	NUMERIC(38,6),
					SchemeDiscount	NUMERIC(38,6),
					Points			NUMERIC(38,0),
					FlxDisc			INT,
					FlxValueDisc	NUMERIC(38,2),
					FlxFreePrd		INT,
					FlxGiftPrd		INT,
					FreePrdId		INT,
					FreePrdBatId	INT,
					FreeToBeGiven	INT,
					EditScheme		INT,
					NoOfTimes		INT,
					Usrid			INT,
					FlxPoints		NUMERIC(38,0),
					GiftPrdId		INT,
					GiftPrdBatId	INT,
					GiftToBeGiven	INT,
					SchType			INT,
					SchDesc			NVARCHAR(400)
				)
				INSERT INTO #AppliedSchemeDetails
				SELECT DISTINCT A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, SUM(A.SchemeAmount) AS SchemeAmount,
				CASE A.SchType WHEN 0 THEN A.SchemeDiscount WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,
				A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, SUM(A.FreeToBeGiven) AS FreeToBeGiven,
				B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,
				A.SchType,B.SchDsc
				FROM BillAppliedSchemeHd A
				INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE Usrid=@UsrId AND TransId = 2 AND B.QPS=1 AND B.ApyQpsSch = 1
				GROUP BY A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,
				A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId,
				A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,PrdId,PrdBatId,B.SchDsc
				ORDER BY A.SchId ASC,A.SlabId ASC

				--->Convert the scheme amount as credit note and corresponding postings
				IF EXISTS(SELECT * FROM #AppliedSchemeDetails)
				BEGIN
					DECLARE Cur_SchFree CURSOR	
					FOR SELECT SchId,SchCode,CmpSchCode,SUM(SchemeAmount),SUM(SchemeDiscount),SchDesc 
						FROM #AppliedSchemeDetails	GROUP BY SchId,SchCode,CmpSchCode,SchDesc
					OPEN Cur_SchFree
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc,@AvlSchDesc
					WHILE @@FETCH_STATUS=0
					BEGIN				
						SET @SchAmtToConvert=0
						SELECT @SchApplicableAmt=SUM(GrossAmount) FROM BilledPrdHdForQPSScheme WHERE QPSPrd=1 AND UsrId=@UsrId
						AND TransId=2 AND SchId=@AvlSchId AND RtrId=@RtrId
						SET @SchAmtToConvert=@AvlSchAmt+((@SchApplicableAmt*@AvlSchDiscPerc)/100)
						IF @SchAmtToConvert>0
						BEGIN
							SELECT @CrNoteNo= dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
							INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
							PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
							VALUES(@CrNoteNo,GETDATE(),@RtrId,@SchCoaId,3,@SchAmtToConvert,0,1,'',2,'',1,1,GETDATE(),1,GETDATE(),
							'From QPS Scheme:'+@AvlSchDesc+'(Auto Conversion)')
							UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CreditNoteRetailer' AND FldName='CrNoteNumber'
							SET @VocDate=GETDATE()
							EXEC Proc_VoucherPosting 18,1,@CrNoteNo,3,6,@UsrId,@VocDate,@Po_ErrNo=@ErrStatus OUTPUT
							IF @ErrStatus<0
							BEGIN
								SET @Po_ErrNo=1
								DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
								DELETE FROM SalesInvoice WHERE SalId=-1000	
								CLOSE Cur_SchFree
								DEALLOCATE Cur_SchFree
								CLOSE Cur_Retailer
								DEALLOCATE Cur_Retailer
								RETURN
							END
						
							UPDATE BillAppliedSchemeHd SET IsSelected=1 WHERE TransId=2
							EXEC Proc_AssignQPSRedeemed -1000,@UsrId,2

							--->Insert Values into SalesInvoiceQPSSchemeAdj
							INSERT INTO SalesInvoiceQPSSchemeAdj(SalId,RtrId,SchId,CmpSchCode,SchCode,SchAmount,AdjAmount,CrNoteAmount,SlabId,Mode,Upload,
							Availability,LastModBy,LastModDate,AuthId,AuthDate)
							VALUES(-1000,@RtrId,@AvlSchId,@CmpSchCode,@CmpSchCode,@SchAmtToConvert,0,@SchAmtToConvert,1,2,0,
							1,1,CONVERT(NVARCHAR(10),GETDATE(),110),1,CONVERT(NVARCHAR(10),GETDATE(),110))
						END
						FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc,@AvlSchDesc
					END
					CLOSE Cur_SchFree
					DEALLOCATE Cur_SchFree
				END
				DROP TABLE #AppliedSchemeDetails
				FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
			END
			CLOSE Cur_Retailer
			DEALLOCATE Cur_Retailer
		END 
		DELETE FROM BilledPrdHdForScheme WHERE UsrId=@UsrId
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	
	END
	INSERT INTO SchQPSConvDetails(SchId,CmpSchCode,ConvDate)
	SELECT DISTINCT C.SchId,C.CmpSchCode,GETDATE() FROM SchemeMaster C 
	INNER JOIN SalesInvoiceQPSCumulative B ON C.SchId = B.SchId 
	INNER JOIN @SchemeAvailable A ON A.SchId=C.SchId
	WHERE C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_SalesCrNoteAdjustmentDelete')
DROP PROCEDURE Proc_SalesCrNoteAdjustmentDelete
GO
CREATE    Procedure [dbo].Proc_SalesCrNoteAdjustmentDelete
(
	@Pi_SalId  		INT	
)
AS
/*********************************
* PROCEDURE	: Proc_SalesCrNoteAdjustmentDelete
* PURPOSE	: To Delete the Duplicate Value for Salesinvoice Creditnote Adjustment
* CREATED	: Boopathy
* CREATED DATE	: 02-07-2011
* NOTE		: General SP Store the Qps Redeemed Quantity, Value and Weight for the Billed Products
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @RtrId AS INT
	SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@Pi_SalId
	DELETE A FROM SalesInvoiceQPSSchemeAdj A WHERE 
	CAST(A.SchId AS VARCHAR(10))+'~'+CAST(A.CmpSchCode AS VARCHAR(100)) NOT IN 
	(SELECT CAST(A.SchId AS VARCHAR(10))+'~'+CAST(B.CmpSchCode AS VARCHAR(100)) FROM SalesInvoiceQPSSchemeAdj A INNER JOIN
	SchemeMaster B ON A.SchId=B.SchId AND A.CmpSchCode=B.CmpSchCode WHERE Qps=1 AND SalId=@Pi_SalId AND RtrId=@RtrId)
	AND SalId=@Pi_SalId AND RtrId=@RtrId
END
GO
delete from customcaptions where SubctrlId in(101,102) and TransId=45 and ctrlId=1000 
go
insert into customcaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values(45,1000,101,'Msgbox-45-1000-101','','',
'Weight Based Product does not exists.Change the Scheme Type and Proceed.....',1,1,1,getdate(),1,getdate(),'','',
'Weight Based Product does not exists.Change the Scheme Type and Proceed.....',1,1)
go
insert into customcaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values(45,1000,102,'Msgbox-45-1000-102','','',
'Product Codes does not exists',1,1,1,getdate(),1,getdate(),'','',
'Product Codes does not exists',1,1)
GO
DELETE from Configuration Where UPPER(ModuleName) = 'PURCHASE RECEIPT' and ModuleId  = 'PURCHASERECEIPT26'
INSERT INTO Configuration VALUES ('PURCHASERECEIPT26','Purchase Receipt','Display MRP column in Purchase Receipt Screen',1,0,0.00,26)
DELETE FROM HotSearchEditorDt WHERE FormId=663
INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','663','Replacement No','Number','RepRefNo','1500','0','HotSch-24-2000-10','24')
INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','663','Replacement No','Date','RepDate','1000','0','HotSch-24-2000-11','24')
INSERT HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','663','Replacement No','Retailer','RtrName','2000','0','HotSch-24-2000-40','24')
DELETE FROM Configuration WHERE moduleID='RETREP2'
INSERT INTO Configuration VALUES ('RETREP2','RetReplacement','Allow user to save Replacement without Return Product(s)',1,0,0.00,2)
DELETE FROM ScreenDefaultValues WHERE TransId=22 AND CtrlId=21 AND CtrlValue=4
DELETE FROM ScreenDefaultValues WHERE TransId=153 AND CtrlId=101 AND CtrlValue=3
INSERT INTO ScreenDefaultValues
SELECT 22,21,4,'RTGS',4,1,1,1,GETDATE(),1,GETDATE(),'RTGS'
UNION
SELECT 153,101,3,'Offer',3,1,1,1,GETDATE(),1,GETDATE(),'Offer'
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ReturnSchemeApplicable')
DROP PROCEDURE Proc_ReturnSchemeApplicable
GO
CREATE    Procedure [dbo].[Proc_ReturnSchemeApplicable]
(
	@Pi_SrpId		INT,
	@Pi_RmId		INT,
	@Pi_RtrId		INT,
	@Pi_BillType		INT,
	@Pi_BillMode		INT,
	@Pi_SchId  		INT,
	@Po_Applicable 		INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ReturnSchemeApplicable
* PURPOSE		: To Return whether the Scheme is applicable for the Retailer or Not
* CREATED		: Thrinath
* CREATED DATE	: 12/04/2007
* NOTE			: General SP for Returning the whether the Scheme is applicable for the Retailer or Not
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @RetDet TABLE
	(
		RtrId 				INT,
		RtrValueClassId		INT,
		CtgMainId			INT,
		CtgLinkId           INT,
		CtgLevelId			INT,
		RtrPotentialClassId	INT,
		RtrKeyAcc			INT,
		VillageId			INT,
		CtgLinkCode         NVARCHAR(100)
	)
	DECLARE @RMDet TABLE
	(
		RMId				INT,
		RMVanRoute			INT,
		RMSRouteType		INT,
		RMLocalUpcountry	INT
	)
	DECLARE @VillageDet TABLE
	(
		VillageId			INT,
		RoadCondition		INT,
		Incomelevel			INT,
		Acceptability		INT,
		Awareness			INT
	)
	DECLARE @SchemeRetAttr TABLE
	(
		AttrType			INT,
		AttrId				INT
	)
	DECLARE @AttrType 				INT
	DECLARE	@AttrId					INT
	DECLARE @Applicable_SM			INT
	DECLARE @Applicable_RM			INT
	DECLARE @Applicable_Vill		INT
	DECLARE @Applicable_RtrLvl		INT
	DECLARE @Applicable_RtrVal		INT
	DECLARE @Applicable_VC			INT
	DECLARE @Applicable_PC			INT
	DECLARE @Applicable_Rtr			INT
	DECLARE @Applicable_BT			INT
	DECLARE @Applicable_BM			INT
	DECLARE @Applicable_RT			INT
	DECLARE @Applicable_CT			INT
	DECLARE @Applicable_VRC			INT
	DECLARE @Applicable_VI			INT
	DECLARE @Applicable_VA			INT
	DECLARE @Applicable_VAw			INT
	DECLARE @Applicable_RouteType	INT
	DECLARE @Applicable_LocUpC		INT
	DECLARE @Applicable_VanRoute	INT
	DECLARE @Applicable_Cluster		INT
	SET @Applicable_SM=0
	SET @Applicable_RM=0
	SET @Applicable_Vill=0
	SET @Applicable_RtrLvl=1
	SET @Applicable_RtrVal=0
	SET @Applicable_VC=0
	SET @Applicable_PC=0
	SET @Applicable_Rtr=0
	SET @Applicable_BT=0
	SET @Applicable_BM=0
	SET @Applicable_RT=0
	SET @Applicable_CT=0
	SET @Applicable_VRC=0
	SET @Applicable_VI=0
	SET @Applicable_VA=0
	SET @Applicable_VAw=0
	SET @Applicable_RouteType=0
	SET @Applicable_LocUpC=0
	SET @Applicable_VanRoute=0	
	SET @Applicable_Cluster=0
	SET @Po_Applicable = 1
	INSERT INTO @RetDet(RtrId,RtrValueClassId,CtgMainId,CtgLinkId,CtgLevelId,RtrPotentialClassId,RtrKeyAcc,VillageId,CtgLinkCode)
	SELECT R.RtrId,RVCM.RtrValueClassId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId,
		ISNULL(RPCM.RtrPotentialClassId,0) AS RtrPotentialClassId,R.RtrKeyAcc,R.VillageId,RC.CtgLinkCode
		FROM Retailer  R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
		LEFT OUTER JOIN RetailerPotentialClassmap RPCM on R.RtrId = RPCM.RtrId
		LEFT OUTER JOIN RetailerPotentialClass [RPC] on RPCM.RtrPotentialClassId = [RPC].RtrClassId
	
	INSERT INTO @RMDet(RMId,RMVanRoute,RMSRouteType,RMLocalUpcountry)
	SELECT  RMId,RMVanRoute,RMSRouteType,RMLocalUpcountry
		FROM RouteMaster RM WHERE RM.RMId = @Pi_RmId
	INSERT INTO @VillageDet(VillageId,RoadCondition,Incomelevel,Acceptability,Awareness)
	SELECT  A.VillageId,ISNULL(RoadCondition,0),ISNULL(Incomelevel,0),ISNULL(Acceptability,0),
		ISNULL(Awareness,0) FROM @RetDet A  LEFT OUTER JOIN Routevillage RV
		ON A.VillageId = RV.VillageId
	INSERT INTO @SchemeRetAttr (AttrType,AttrId)
	SELECT AttrType,AttrId FROM SchemeRetAttr  WHERE SchId = @Pi_SchId AND AttrId > 0 ORDER BY AttrType
	
	IF NOT EXISTS(SELECT AttrId FROM SchemeRetAttr WHERE SchId = @Pi_SchId AND AttrType=3)
	BEGIN
		SET @Applicable_Vill=1
	END
	IF NOT EXISTS(SELECT AttrId FROM SchemeRetAttr WHERE SchId = @Pi_SchId AND AttrType=7)
	BEGIN
		SET @Applicable_PC=1
	END
	DECLARE  CurSch1 CURSOR FOR
	SELECT DISTINCT AttrType FROM SchemeRetAttr WHERE AttrId=0 AND SchId = @Pi_SchId ORDER BY AttrType
		OPEN CurSch1
		FETCH NEXT FROM CurSch1 INTO @AttrType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AttrType = 1
			SET @Applicable_SM=1
		ELSE IF @AttrType =2
			SET @Applicable_RM=1
		ELSE IF @AttrType =3
			SET @Applicable_Vill=1
		ELSE IF @AttrType =4
			SET @Applicable_RtrLvl=1
		ELSE IF @AttrType =5
			SET @Applicable_RtrVal=1
		ELSE IF @AttrType =6
			SET @Applicable_VC=1
		ELSE IF @AttrType =7
			SET @Applicable_PC=1
		ELSE IF @AttrType =8
			SET @Applicable_Rtr=1
		ELSE IF @AttrType =10
			SET @Applicable_BT=1
		ELSE IF @AttrType =11
			SET @Applicable_BM=1
		ELSE IF @AttrType =12
			SET @Applicable_RT=1
		ELSE IF @AttrType =13
			SET @Applicable_CT=1
		ELSE IF @AttrType =14
			SET @Applicable_VRC=1
		ELSE IF @AttrType =15
			SET @Applicable_VI=1
		ELSE IF @AttrType =16
			SET @Applicable_VA=1
		ELSE IF @AttrType =17
			SET @Applicable_VAw=1
		ELSE IF @AttrType =18
			SET @Applicable_RouteType=1
		ELSE IF @AttrType =19
			SET @Applicable_LocUpC=1
		ELSE IF @AttrType =20
			SET @Applicable_VanRoute=1		
		ELSE IF @AttrType =21
			SET @Applicable_Cluster=1
		FETCH NEXT FROM CurSch1 INTO @AttrType
	END
	CLOSE CurSch1
	DEALLOCATE CurSch1
	
	DECLARE  CurSch CURSOR FOR
	SELECT AttrType,AttrId FROM @SchemeRetAttr ORDER BY AttrType
		OPEN CurSch
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AttrType = 1 AND @Applicable_SM=0		--SalesMan
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_SrpId)
				SET @Applicable_SM = 1
		END
		IF @AttrType = 2 AND @Applicable_RM=0		--Route
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RmId)
				SET @Applicable_RM = 1
		END
		IF @AttrType = 3 AND @Applicable_Vill=0		--Village
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.VillageId AND A.AttrType = @AttrType)
				SET @Applicable_Vill = 1
		END
--		IF @AttrType = 4 AND @Applicable_RtrLvl=0		--Retailer Category Level
--		BEGIN
--			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
--						ON A.AttrId = B.CtgLevelId  AND A.AttrType = @AttrType)
--				SET @Applicable_RtrLvl = 1
--		END
		IF @AttrType = 5 AND @Applicable_RtrVal=0		--Retailer Category Level Value
		BEGIN
			IF (SELECT COUNT(A.AttrId) FROM @SchemeRetAttr A WHERE A.AttrType = 4)=1
			BEGIN
				IF EXISTS(SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN RetailerCategoryLevel B
							ON A.AttrId = B.CtgLevelId  AND A.AttrType = 4 AND LevelName='Level1')
				BEGIN
					IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.CtgLinkId AND A.AttrType = @AttrType)
							SET @Applicable_RtrVal = 1			
				END
				ELSE
				BEGIN
					IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
								ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
					BEGIN
						SET @Applicable_RtrVal = 1
					END
				END
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
								ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
				BEGIN
					SET @Applicable_RtrVal = 1
				END
			END
		END
		IF @AttrType = 6 AND @Applicable_VC=0		--Retailer Class Value
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.RtrValueClassId AND A.AttrType = @AttrType)
				SET @Applicable_VC = 1
		END
--		IF @AttrType = 7 AND @Applicable_PC=0		--Retailer Potential Class
--		BEGIN
--			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A LEFT JOIN @RetDet B
--						ON A.AttrId = B.RtrPotentialClassId AND A.AttrType = @AttrType)
--				SET @Applicable_PC = 1
--		END
		IF @AttrType = 8 AND @Applicable_Rtr=0		--Retailer
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RtrId)
			BEGIN
				SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RtrId
				SET @Applicable_Rtr = 1
			END
		END
		IF @AttrType = 10 AND @Applicable_BT=0		--Bill Type
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_BillType)
				SET @Applicable_BT = 1
		END
		IF @AttrType = 11 AND @Applicable_BM=0		--Bill Mode
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_BillMode)
				SET @Applicable_BM = 1
		END
		IF @AttrType = 12 AND @Applicable_RT=0		--Retailer Type
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.RtrKeyAcc AND A.AttrType = @AttrType)
				SET @Applicable_RT = 1
		END
		IF @AttrType = 13 AND @Applicable_CT=0		--Class Type
		BEGIN
			IF EXISTS (SELECT B.RtrPotentialClassId FROM @RetDet B WHERE B.RtrPotentialClassId > 0 )
				SET @Applicable_CT = 1
		END
		IF @AttrType = 14 AND @Applicable_VRC=0		--Village Road Condition
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.RoadCondition AND A.AttrType = @AttrType)
				SET @Applicable_VRC = 1
		END
		IF @AttrType = 15 AND @Applicable_VI=0		--Village Income Level
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Incomelevel AND A.AttrType = @AttrType)
				SET @Applicable_VI = 1
		END
		IF @AttrType = 16 AND @Applicable_VA=0		--Village Acceptability
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Acceptability AND A.AttrType = @AttrType)
				SET @Applicable_VA = 1
		END
		IF @AttrType = 17 AND @Applicable_VAw=0		--Village Awareness
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Awareness AND A.AttrType = @AttrType)
				SET @Applicable_VAw = 1
		END
		IF @AttrType = 18 AND @Applicable_RouteType=0		--Route Type
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMSRouteType AND A.AttrType = @AttrType)
				SET @Applicable_RouteType = 1
		END
		IF @AttrType = 19 AND @Applicable_LocUpC=0		--Local / UpCountry
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMLocalUpcountry AND A.AttrType = @AttrType)
				SET @Applicable_LocUpC = 1
		END
		IF @AttrType = 20 AND @Applicable_VanRoute=0		--Van / NonVan Route
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMVanRoute AND A.AttrType = @AttrType)
				SET @Applicable_VanRoute = 1
		END
		IF @AttrType = 21 AND @Applicable_Cluster=0		--Cluster
		BEGIN			
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId IN(SELECT DISTINCT ClusterId FROM ClusterAssign WHERE MasterId=79 AND MAsterRecordId=@Pi_RtrId AND Status=1))
				SET @Applicable_Cluster = 1
		END
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	END
	CLOSE CurSch
	DEALLOCATE CurSch
--
	PRINT @Applicable_SM
	PRINT @Applicable_RM
	PRINT @Applicable_Vill
	PRINT @Applicable_RtrLvl
	PRINT @Applicable_RtrVal
	PRINT @Applicable_VC
	PRINT @Applicable_PC
	PRINT @Applicable_Rtr
	PRINT @Applicable_BT
	PRINT @Applicable_BM
	PRINT @Applicable_RT
	PRINT @Applicable_CT
	PRINT @Applicable_VRC
	PRINT @Applicable_VI
	PRINT @Applicable_VA
	PRINT @Applicable_VAw
	PRINT @Applicable_RouteType
	PRINT @Applicable_LocUpC
	PRINT @Applicable_VanRoute
	PRINT @Applicable_Cluster

	IF @Applicable_SM=1 AND @Applicable_RM=1 AND @Applicable_Vill=1 AND --@Applicable_RtrLvl=1 AND
	@Applicable_RtrVal=1 AND @Applicable_VC=1 AND @Applicable_PC=1 AND @Applicable_Rtr = 1 AND
	@Applicable_BT=1 AND @Applicable_BM=1 AND @Applicable_RT=1 AND @Applicable_CT=1 AND
	@Applicable_VRC=1 AND @Applicable_VI=1 AND @Applicable_VA=1 AND @Applicable_VAw=1 AND
	@Applicable_RouteType=1 AND @Applicable_LocUpC=1 AND @Applicable_VanRoute=1 AND @Applicable_Cluster=1
	BEGIN
		SET @Po_Applicable=1
	END
	ELSE
	BEGIN
		SET @Po_Applicable=0
	END

	--->Added By Nanda on 08/10/2010 for FBM Validations
	IF @Po_Applicable=1
	BEGIN
		IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId=@Pi_SchId AND FBM=1)
		BEGIN
			IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId=@Pi_SchId AND Budget>0)
			BEGIN
				SET @Po_Applicable=1
			END
			ELSE
			BEGIN
				SET @Po_Applicable=0
			END
		END
	END
	--->Till Here

	--PRINT @Po_Applicable
	RETURN
END
GO
--Select * from RptHeader where RptId in ('166','209')
--Select * from RptDetails where RptId in ('166','209')
--Select * from RptGroup where RptId in ('166','209')


--Delet RptGroup Values Rptid=166,209
Delete from RptGroup where RptId in ('166','209')
--Insert into Values RptGroup Rptid=211,171
--Rptid=211
Insert Into RptGroup (PId,RptId,GrpCode,GrpName) 
Values ('RspReport',211,'EFFECTIVECOVERAGEANALYSISREPORT','Effective Coverage Analysis Report')
--Rptid=171
Insert Into RptGroup (PId,RptId,GrpCode,GrpName) 
Values ('RspReport',171,'RetailerWiseValueReport','Retailer Wise Value Report')


--Delete the RptHeader Values RptId=166,209
Delete from RptHeader where RptId in ('166','209')

--Insert Values to RptHeader Table RptId=211
Insert Into RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds) 
values ('EFFECTIVECOVERAGEANALYSISREPORT','Effective Coverage Analysis Report',211,
'Effective Coverage Analysis Report','Proc_RptECAnalysisReport','RptECAnalysisReport','RptECAnalysisReport.rpt','')
--Insert Values to RptHeader Table RptId=171
Insert Into RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds) 
Values ('RetailerWiseValueReport','Retailer Wise Value Report',171,'Retailer Wise Value Report',	
'Proc_RptRetailerWiseValueReport','RptRetailerWiseValueReport','RptRetailerWiseValueReport.rpt','')

--Delete the RptDetails Values Rptid=166,209
Delete from RptDetails where RptId in ('166','209')
	
--Insert Values to RptHeader Table RptId=211
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	1,	'Fromdate',	-1,	NULL,	'',	'From Date*',NULL,	1,NULL,	10,	NULL,	'1',	'Enter From Date',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	2,	'Todate',	-1,	NULL,	'',	'To Date*',	NULL,	1,	NULL,	11,	NULL,	'1',	'Enter To Date',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	3,	'Company',	-1,	NULL,	'CmpId,CmpCode,CmpName',	'Company*...',	NULL,	1,	NULL,	4,	'1',	'1',	'Press F4/Double Click to select Company',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	4,	'SalesMan',	-1,	NULL,	'SMId,SMCode,SMName',	'SalesMan...',	NULL,	1,	NULL,	1,	'1',	NULL,	'Press F4/Double Click to select Salesman',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	5,	'RouteMaster',	-1,	NULL,	'RMId,RMCode,RMName',	'Route...',	NULL,	1,	NULL,	2,	NULL,	NULL,	'Press F4/Double Click to select Route',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	6,	'RetailerCategoryLevel',	3,	'CmpId',	'CtgLevelId,CtgLevelName,CtgLevelName',	'Retailer Category Level...',	'Company',	1,	'CmpId',	29,	'1',	NULL,	'Press F4/Double Click to Retailer Category Level',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	7,	'RetailerCategory',	6,	'CtgLevelId','CtgMainId,CtgName,CtgName',	'Retailer Category Level Value...',	'RetailerCategoryLevel',	1,	'CtgLevelId',	30,	'1',	NULL,	'Press F4/Double Click to Retailer Category Level Value',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	8,	'RetailerValueClass',	7,	'CtgMainId',	'RtrClassId,ValueClassName,ValueClassName',	'Retailer Value Classification...',	'RetailerCategory',	1,	'CtgMainId',	31,	'1',	NULL,	'Press F4/Double Click to select Retailer Value Classification',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	9,	'Retailer',	-1,	NULL,	'RtrId,RtrCode,RtrName',	'Retailer Group...',	NULL,	1,	NULL,	215,	NULL,	NULL,	'Press F4/Double Click to select Retailer Group',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	10,	'Retailer',	-1,	NULL,	'RtrId,RtrCode,RtrName',	'Retailer...',	NULL,	1,	NULL,	3,	NULL,	NULL,	'Press F4/Double Click to select Retailer',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	11,	'ProductCategoryLevel',	3,	'CmpId',	'CmpPrdCtgId,CmpPrdCtgName,LevelName',	'Product Hierarchy Level...',	'Company',	1,	'CmpId',	16,	'1',	NULL,	'Press F4/Double Click to select Product Hierarchy Level',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	12,	'ProductCategoryValue',	11,	'CmpPrdCtgId',	'PrdCtgValMainId,PrdCtgValCode,PrdCtgValName',	'Product Hierarchy Level Value...',	'ProductCategoryLevel',	1,	'CmpPrdCtgId',	21,	NULL,	NULL,	'Press F4/Double Click to select Product Hierarchy Level Value',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	13,	'Product',	12,	'PrdCtgValMainId',	'PrdId,PrdDCode,PrdName',	'Product...',	'ProductCategoryValue',	1,	'PrdCtgValMainId',	5,	NULL,	NULL,	'Press F4/Double Click to select Product',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	211,	14,	'RptFilter',	-1,	NULL,	'FilterId,FilterDesc,FilterDesc',	'Display Based On*...',	NULL,	1,	NULL,	246,	'1',	'1',	'Press F4/Double Click to select Display Based ON',	1	)


--Insert Values to RptHeader Table RptId=211
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	1,	'JCMast',	-1,	'',	'JcmId,JcmYr,JcmYr',	'JC Year*...',	'',	1,	NULL,	12,	1,	1,	'Press F4/Double Click to select JC Year',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	2,	'JCMonth',	1,	'JcmId',	'JcmJc,JcmSdt,JcmSdt',	'From JC Month*...',	'JcMast',	1,	'JcmId',	13,	1,	1,	'Press F4/Double Click to select From JC Month',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	3,	'JCMonth',	1,	'JcmId',	'JcmJc,JcmEdt,JcmEdt',	'To JC Month*...',	'JcMast',	1,	'JcmId',	20,	1,	1,	'Press F4/Double Click to select To JC Month',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	4,	'Company',	-1,	'',	'CmpId,CmpCode,CmpName',	'Company*...',	NULL,	1,	NULL,	4,	1,	1,	'Press F4/Double Click to select Company',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	5,	'SalesMan',	-1,	NULL,	'SMId,SMCode,SMName',	'SalesMan...',	NULL,	1,	NULL,	1,	1,	NULL,	'Press F4/Double Click to select Salesman',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	6,	'RouteMaster',	-1,	NULL,	'RMId,RMCode,RMName',	'Route...',	NULL,	1,	NULL,	2,	NULL,	NULL,	'Press F4/Double Click to select Route',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	7,	'RetailerCategoryLevel',	4,	'CmpId',	'CtgLevelId,CtgLevelName,CtgLevelName',	'Retailer Category Level...',	'Company',	1,	'CmpId',	29,	1,	NULL,	'Press F4/Double Click to Retailer Category Level',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	8,	'RetailerCategory',	7,	'CtgLevelId',	'CtgMainId,CtgName,CtgName',	'Retailer Category Level Value...',	'RetailerCategoryLevel',	1,	'CtgLevelId',	30,	1,	NULL,	'Press F4/Double Click to Retailer Category Level Value',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	9,	'RetailerValueClass',	8,	'CtgMainId',	'RtrClassId,ValueClassName,ValueClassName',	'Retailer Value Classification...',	'RetailerCategory',	1,	'CtgMainId',	31,	1,	NULL,	'Press F4/Double Click to select Retailer Value Classification',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	10,	'Retailer',	-1,	NULL,	'RtrId,RtrCode,RtrName',	'Retailer...',	NULL,	1,	NULL,	3,	NULL,	NULL,	'Press F4/Double Click to select Retailer',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	11,	'ProductCategoryLevel',	4,	'',	'CmpPrdCtgId,CmpPrdCtgName,LevelName',	'Product Hierarchy Level...',	'Company',	1,	'CmpId',	16,	1,	NULL,	'Press F4/Double Click to select Product Hierarchy Level',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	12,	'ProductCategoryValue',	11,	'CmpPrdCtgId',	'PrdCtgValMainId,PrdCtgValCode,PrdCtgValName',	'Product Hierarchy Level Value...',	'ProductCategoryLevel',	1,	'CmpPrdCtgId',	21,	NULL,	NULL,	'Press F4/Double Click to select Product Hierarchy Level Value',	0	)
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,
SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	171,	13,	'Product',	12,	'PrdCtgValMainId',	'PrdId,PrdDCode,PrdName',	'Product...',	'ProductCategoryValue',	1,	'PrdCtgValMainId',	5,	NULL,	NULL,	'Press F4/Double Click to select Product',	0	)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='spEXECsp_RECOMPILE')
DROP PROCEDURE spEXECsp_RECOMPILE
GO
CREATE PROCEDURE dbo.spEXECsp_RECOMPILE AS
/*
----------------------------------------------------------------------------
-- Object Name: dbo.spEXECsp_RECOMPILE 
-- Project: SQL Server Database Maintenance
-- Business Process: SQL Server Database Maintenance
-- Purpose: Execute sp_recompile for all tables in a database
-- Detailed Description: Execute sp_recompile for all tables in a database
-- Database: Admin
-- Dependent Objects: None
-- Called By: TBD
-- Upstream Systems: None
-- Downstream Systems: None
-- 
--------------------------------------------------------------------------------------
-- Rev | CMR | Date Modified | Developer | Change Summary
--------------------------------------------------------------------------------------
--
*/

SET NOCOUNT ON 

-- 1a - Declaration statements for all variables
DECLARE @TableName varchar(128)
DECLARE @OwnerName varchar(128)
DECLARE @CMD1 varchar(8000)
DECLARE @TableListLoop int
DECLARE @TableListTable table
(UIDTableList int IDENTITY (1,1),
OwnerName varchar(128),
TableName varchar(128))

-- 2a - Outer loop for populating the database names
INSERT INTO @TableListTable(OwnerName, TableName)
SELECT  u.[Name], o.[Name]
FROM dbo.sysobjects o
INNER JOIN dbo.sysusers u
ON o.uid = u.uid
WHERE o.Type = 'U'
ORDER BY o.[Name]

-- 2b - Determine the highest UIDDatabaseList to loop through the records
SELECT @TableListLoop = MAX(UIDTableList) FROM @TableListTable

-- 2c - While condition for looping through the database records
WHILE @TableListLoop > 0
BEGIN

-- 2d - Set the @DatabaseName parameter
SELECT @TableName = TableName,
@OwnerName = OwnerName
FROM @TableListTable
WHERE UIDTableList = @TableListLoop

-- 3f - String together the final backup command
SELECT @CMD1 = 'EXEC sp_recompile ' + '[' + @OwnerName + '.' + @TableName + ']' + char(13)

-- 3g - Execute the final string to complete the backups
-- SELECT @CMD1
EXEC (@CMD1)

-- 2h - Descend through the database list
SELECT @TableListLoop = @TableListLoop - 1

END
GO
if not exists (select * from hotfixlog where fixid = 382)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(382,'D','2011-08-24',getdate(),1,'Core Stocky Service Pack 382')
GO