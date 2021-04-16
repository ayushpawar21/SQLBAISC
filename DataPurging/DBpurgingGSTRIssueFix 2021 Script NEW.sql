
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE Xtype='U' and Name='StockmismatchProducts')
BEGIN
CREATE TABLE StockmismatchProducts
(
Prdid Numeric(36,0),
Prdbatid Numeric(36,0),
StockAdjusted TinyInt,
Createdate DateTime
)		
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE Xtype='U' and Name='PurgeStockManagement')
BEGIN
CREATE TABLE PurgeStockManagement(
	[StkMngRefNo] [nvarchar](25) NOT NULL,
	[StkMngDate] [datetime] NOT NULL,
	[LcnId] [int] NOT NULL,
	[StkMgmtTypeId] [int] NOT NULL,
	[RtrId] [int] NULL,
	[SpmId] [int] NULL,
	[DocRefNo] [nvarchar](20) NULL,
	[Remarks] [nvarchar](250) NULL,
	[DecPoints] [int] NOT NULL,
	[OpenBal] [tinyint] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL,
	[ConfigValue] [Int] NULL,
    [XMLUpload] [Int] NULL,
	VatGst [varchar](10) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE Xtype='U' and Name='PurgeStockManagementProduct')
BEGIN
CREATE TABLE [PurgeStockManagementProduct](
	[StkMngRefNo] [nvarchar](25) NOT NULL,
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[StockTypeId] [int] NOT NULL,
	[UOMId1] [int] NOT NULL,
	[Qty1] [int] NOT NULL,
	[UOMId2] [int] NULL,
	[Qty2] [int] NULL,
	[TotalQty] [int] NOT NULL,
	[Rate] [numeric](18, 6) NOT NULL,
	[Amount] [numeric](18, 6) NOT NULL,
	[ReasonId] [int] NULL,
	[PriceId] [bigint] NOT NULL,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL,
	[TaxAmt] [numeric](18, 6) NULL,
	[PrdSlNo] [int] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE Xtype='U' and Name='StockmismatchProducts')
BEGIN
CREATE TABLE StockmismatchProducts
(
Prdid Numeric(36,0),
Prdbatid Numeric(36,0),
StockAdjusted TinyInt,
Createdate DateTime
)		
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE Xtype='U' and Name='PurgeProductBatchLocation')
BEGIN
CREATE TABLE [PurgeProductBatchLocation](
	[PrdId] [int] NOT NULL,
	[PrdBatID] [int] NOT NULL,
	[LcnId] [int] NOT NULL,
	[PrdBatLcnSih] [int] NOT NULL,
	[PrdBatLcnUih] [int] NOT NULL,
	[PrdBatLcnFre] [int] NOT NULL,
	[PrdBatLcnRessih] [int] NOT NULL,
	[PrdBatLcnResUih] [int] NOT NULL,
	[PrdBatLcnResFre] [int] NOT NULL,
	[Availability] [int] NOT NULL,
	[LastModBy] [int] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [int] NOT NULL,
	[AuthDate] [datetime] NOT NULL,
) ON [PRIMARY]
END
GO
--DROP TABLE StockmismatchProducts
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE Xtype='U' and Name='PurgeStockLedger')
BEGIN
CREATE TABLE [PurgeStockLedger](
[TransDate] [datetime] NOT NULL,
[LcnId] [int] NOT NULL,
[PrdId] [int] NOT NULL,
[PrdBatId] [int] NOT NULL,
[SalOpenStock] [numeric](18, 0) NULL,
[UnSalOpenStock] [numeric](18, 0) NULL,
[OfferOpenStock] [numeric](18, 0) NULL,
[SalPurchase] [numeric](18, 0) NULL,
[UnsalPurchase] [numeric](18, 0) NULL,
[OfferPurchase] [numeric](18, 0) NULL,
[SalPurReturn] [numeric](18, 0) NULL,
[UnsalPurReturn] [numeric](18, 0) NULL,
[OfferPurReturn] [numeric](18, 0) NULL,
[SalSales] [numeric](18, 0) NULL,
[UnSalSales] [numeric](18, 0) NULL,
[OfferSales] [numeric](18, 0) NULL,
[SalStockIn] [numeric](18, 0) NULL,
[UnSalStockIn] [numeric](18, 0) NULL,
[OfferStockIn] [numeric](18, 0) NULL,
[SalStockOut] [numeric](18, 0) NULL,
[UnSalStockOut] [numeric](18, 0) NULL,
[OfferStockOut] [numeric](18, 0) NULL,
[DamageIn] [numeric](18, 0) NULL,
[DamageOut] [numeric](18, 0) NULL,
[SalSalesReturn] [numeric](18, 0) NULL,
[UnSalSalesReturn] [numeric](18, 0) NULL,
[OfferSalesReturn] [numeric](18, 0) NULL,
[SalStkJurIn] [numeric](18, 0) NULL,
[UnSalStkJurIn] [numeric](18, 0) NULL,
[OfferStkJurIn] [numeric](18, 0) NULL,
[SalStkJurOut] [numeric](18, 0) NULL,
[UnSalStkJurOut] [numeric](18, 0) NULL,
[OfferStkJurOut] [numeric](18, 0) NULL,
[SalBatTfrIn] [numeric](18, 0) NULL,
[UnSalBatTfrIn] [numeric](18, 0) NULL,
[OfferBatTfrIn] [numeric](18, 0) NULL,
[SalBatTfrOut] [numeric](18, 0) NULL,
[UnSalBatTfrOut] [numeric](18, 0) NULL,
[OfferBatTfrOut] [numeric](18, 0) NULL,
[SalLcnTfrIn] [numeric](18, 0) NULL,
[UnSalLcnTfrIn] [numeric](18, 0) NULL,
[OfferLcnTfrIn] [numeric](18, 0) NULL,
[SalLcnTfrOut] [numeric](18, 0) NULL,
[UnSalLcnTfrOut] [numeric](18, 0) NULL,
[OfferLcnTfrOut] [numeric](18, 0) NULL,
[SalReplacement] [numeric](18, 0) NULL,
[OfferReplacement] [numeric](18, 0) NULL,
[SalClsStock] [numeric](18, 0) NULL,
[UnSalClsStock] [numeric](18, 0) NULL,
[OfferClsStock] [numeric](18, 0) NULL,
[Availability] [tinyint] NOT NULL,
[LastModBy] [tinyint] NOT NULL,
[LastModDate] [datetime] NOT NULL,
[AuthId] [tinyint] NOT NULL,
[AuthDate] [datetime] NOT NULL,
--[UploadFlag1] TinyInt NOT NULL, 
--[UploadFlag2] TinyInt NOT NULL 
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DataPurge_TransactionProcess')
DROP TABLE DataPurge_TransactionProcess
GO
CREATE TABLE DataPurge_TransactionProcess
(
	SlNo INT,
	ModuleId INT,
	ModuleName Varchar(100),
	TableName	Varchar(100),
	ParentTable Varchar(100),
	DateFieldName Varchar(50),
	TableKeyField Varchar(50),
	ParentKeyField Varchar(50),
	ConditionField Varchar(50),
	ConditionValue Varchar(50)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DataPurge_DeleteTransactionSourceDB')
DROP TABLE DataPurge_DeleteTransactionSourceDB
GO
CREATE TABLE DataPurge_DeleteTransactionSourceDB
(
	SlNo INT,
	ModuleId INT,
	ModuleName Varchar(100),
	TableName	Varchar(100),
	ParentTable Varchar(100),
	DateFieldName Varchar(50),
	TableKeyField Varchar(50),
	ParentKeyField Varchar(50),
	ConditionField Varchar(50),
	ConditionValue Varchar(50)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='Tbl_DisEnableTriggerAndConstraint')
DROP TABLE Tbl_DisEnableTriggerAndConstraint
GO
CREATE TABLE Tbl_DisEnableTriggerAndConstraint
(
	Xtype						Varchar(50),
	TableName					Varchar(150),
	DisableTriggerAndConstraint VARCHAR(3000)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DataPurge_TransactionTable')
DROP TABLE DataPurge_TransactionTable
GO
CREATE TABLE DataPurge_TransactionTable
(
	DataPurgTransTable Varchar(200)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempPurgeDataValidate')
DROP TABLE TempPurgeDataValidate
GO
CREATE TABLE TempPurgeDataValidate
(
	ModuleId INT,
	Modulename Varchar(100),
	PendingCount BIGINT
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DataPurge_MasterTable')
DROP TABLE DataPurge_MasterTable
GO
CREATE TABLE DataPurge_MasterTable
(
	DataPurgMasterTable Varchar(200)
)
GO
INSERT INTO	DataPurge_TransactionProcess(SlNO,ModuleId,ModuleName,TableName,ParentTable,DateFieldName,TableKeyField,ParentKeyField,ConditionField,ConditionValue)
SELECT 1,1,'Purchase Order','PurchaseorderMaster','PurchaseorderMaster','PurOrderDate','PurorderRefNo','PurorderRefNo','ConfirmSts','1,0' UNION ALL 
SELECT 2,1,'Purchase Order','PurchaseOrderDetails','PurchaseorderMaster','PurOrderDate','PurorderRefNo','PurorderRefNo','ConfirmSts','1,0' UNION ALL 
--CCRSTBot0009
SELECT 3,1,'Purchase Order','PurchaseOrderProductTax','PurchaseorderMaster','PurOrderDate','PurorderRefNo','PurorderRefNo','ConfirmSts','1,0' UNION ALL 
SELECT 4,1,'Purchase Order','PORtrBreakUp','PurchaseorderMaster','PurOrderDate','PurorderRefNo','PurorderRefNo','ConfirmSts','1,0' UNION ALL 
SELECT 5,2,'Purchase Receipt','Purchasereceipt','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 6,2,'Purchase Receipt','PurchaseReceiptProduct','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 7,2,'Purchase Receipt','PurchaseReceiptBreakup','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 8,2,'Purchase Receipt','PurchaseReceiptHdAmount','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 9,2,'Purchase Receipt','PurchaseReceiptLineAmount','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 10,2,'Purchase Receipt','PurchaseReceiptProductTax','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 11,2,'Purchase Receipt','PurchaseReceiptOtherCharges','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 12,2,'Purchase Receipt','PurchaseReceiptClaimScheme','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 13,2,'Purchase Receipt','PurchaseReceiptClaim','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 14,2,'Purchase Receipt','PurchaseReceiptCreditDebit','Purchasereceipt','GoodsRcvdDate','CmpInvNo','CmpInvNo','Status','1' UNION ALL 
SELECT 15,2,'Purchase Receipt','PurchaseReceiptMapping','Purchasereceipt','GoodsRcvdDate','CompInvNo','CmpInvNo','Status','1' UNION ALL 
SELECT 16,2,'Purchase Receipt','PurchaseReceiptProductMapping','Purchasereceipt','GoodsRcvdDate','CompInvNo','CmpInvNo','Status','1' UNION ALL 
SELECT 17,3,'Purchase Return','PurchaseReturn','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 18,3,'Purchase Return','PurchaseReturnProduct','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 19,3,'Purchase Return','PurchaseReturnBreakUp','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 20,3,'Purchase Return','PurchaseReturnHdAmount','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 21,3,'Purchase Return','PurchaseReturnLineAmount','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 22,3,'Purchase Return','PurchaseReturnProductTax','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 23,3,'Purchase Return','PurchaseReturnOtherCharges','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 24,3,'Purchase Return','PurchaseReturnClaimScheme','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 25,4,'Return to Company','ReturntoCompany','ReturntoCompany','RtnCmpDate','RtnCmpRefNo','RtnCmpRefNo','Status','1' UNION ALL 
SELECT 26,4,'Return to Company','ReturnToCompanyDt','ReturntoCompany','RtnCmpDate','RtnCmpRefNo','RtnCmpRefNo','Status','1' UNION ALL 
SELECT 27,4,'Return to Company','ReturnToCompanyDtTax','ReturntoCompany','RtnCmpDate','RtnCmpRefNo','RtnCmpRefNo','Status','1' UNION ALL 
SELECT 28,5,'IDT Management','IDTManagement','IDTManagement','IDTMngDate','IDTMngRefNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 29,5,'IDT Management','IDTManagementProduct','IDTManagement','IDTMngDate','IDTMngRefNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 30,5,'IDT Management','IDTManagementProductTax','IDTManagement','IDTMngDate','IDTMngRefNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 31,5,'IDT Management','IDTManagementLineAmount','IDTManagement','IDTMngDate','IDTMngRefNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 32,5,'IDT Management','IDTReceipt','IDTReceipt','IDTCollectionDate','IDTRcpNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 33,5,'IDT Management','IDTReceiptInvoice','IDTReceipt','IDTCollectionDate','IDTRcpNo','IDTRcpNo','Status','1' UNION ALL 
SELECT 34,5,'IDT Management','IDTReceiptInvoice','IDTReceipt','IDTCollectionDate','IDTRcpNo','IDTRcpNo','Status','1' UNION ALL 
SELECT 35,6,'Stock Management','StockManagement','StockManagement','StkMngDate','StkMngRefNo','StkMngRefNo','Status','1' UNION ALL 
SELECT 36,6,'Stock Management','StockManagementProduct','StockManagement','StkMngDate','StkMngRefNo','StkMngRefNo','Status','1' UNION ALL 
SELECT 37,6,'Stock Management','StockManagementProductTax','StockManagement','StkMngDate','StkMngRefNo','StkMngRefNo','Status','1' UNION ALL 
SELECT 38,7,'Location Master','LocationTransferMaster','LocationTransferMaster','LcnTrfDate','LcnRefNo','LcnRefNo','','' UNION ALL 
SELECT 39,7,'Location Master','LocationTransferDetails','LocationTransferMaster','LcnTrfDate','LcnRefNo','LcnRefNo','','' UNION ALL 
SELECT 40,8,'Batch Transfer','BatchTransfer','BatchTransfer','BatTrfDate','BatRefNo','BatRefNo','','' UNION ALL 
SELECT 41,9,'Salvage','Salvage','Salvage','SalvageDate','SalvageRefNo','SalvageRefNo','Status','1' UNION ALL 
SELECT 42,9,'Salvage','SalvageProduct','Salvage','SalvageDate','SalvageRefNo','SalvageRefNo','Status','1' UNION ALL 
SELECT 43,10,'Stock Journal','StockJournal','StockJournal','StkJournalDate','StkJournalRefNo','StkJournalRefNo','','' UNION ALL 
SELECT 44,10,'Stock Journal','StockJournalDt','StockJournal','StkJournalDate','StkJournalRefNo','StkJournalRefNo','','' UNION ALL 
SELECT 45,10,'Stock Journal','StkJournalClaim','StockJournal','StkJournalDate','StkJournalRefNo','StkJournalRefNo','','' UNION ALL 
SELECT 46,11,'Order Booking','OrderBooking','OrderBooking','OrderDate','OrderNo','OrderNo','','' UNION ALL 
SELECT 47,11,'Order Booking','OrderBookingProducts','OrderBooking','OrderDate','OrderNo','OrderNo','','' UNION ALL 
SELECT 48,12,'Billing','VehicleAllocationMaster','VehicleAllocationMaster','AllotmentDate','AllotmentNumber','AllotmentNumber','','' UNION ALL 
SELECT 49,12,'Billing','VehicleAllocationDetails','SalesInvoice','SalInvDate','SaleInvNo','SAlinvno','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 50,12,'Billing','SalesInvoiceEditableHistory','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 51,12,'Billing','SalesInvoice','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 52,12,'Billing','SalesInvoiceProduct','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 53,12,'Billing','SalesInvoiceHdAmount','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 54,12,'Billing','SalesInvoiceLineAmount','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 55,12,'Billing','SalesInvoiceProductTax','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 56,12,'Billing','SalesInvoiceSchemeHd','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 57,12,'Billing','SalesInvoiceSchemeDtBilled','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 58,12,'Billing','SalesInvoiceSchemeLineWise','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 59,12,'Billing','SalesInvoiceSchemeFlexiDt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 60,12,'Billing','SalesInvoiceSchemeDtFreePrd','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 61,12,'Billing','SalesInvoiceSchemeDtPoints','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 62,12,'Billing','SalesInvoiceSchemeQPSGiven','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 63,12,'Billing','SalesInvoiceUnSelectedScheme','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 64,12,'Billing','SalesInvoiceQPSCumulative','SalesInvoiceQPSCumulative','LastModDate','','','','' UNION ALL 
SELECT 65,12,'Billing','SalesInvoiceQPSRedeemed','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 66,12,'Billing','SalInvoiceDeliveryChallan','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 67,12,'Billing','SalesInvoiceCrDays','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 68,12,'Billing','SalesInvoiceQPSSchemeAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 69,12,'Billing','SalesinvoiceSchemeFlag','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 70,12,'Billing','SalesInvoiceModificationHistory','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 71,12,'Billing','SalesInvoiceSchemeClaimDt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 72,12,'Billing','SalesInvoiceKitItemDt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 73,12,'Billing','SalesInvoiceMrkRtnDbNote','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 74,12,'Billing','SalesInvoiceWindowService','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 75,12,'Billing','TransactionWiseBarCodeDt','SalesInvoice','SalInvDate','TransRefCode','Salinvno','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 76,12,'Billing','SalesInvoiceWindowDisplay','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 77,12,'Billing','SalesInvoiceMarketReturn','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 78,12,'Billing','SalesInvoiceMrkRtnDbNote','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 79,12,'Billing','SalInvDbNoteAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 80,12,'Billing','SalInvOnAccAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 81,12,'Billing','SalesinvoiceOrderBooking','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 82,12,'Billing','SalInvLineAmt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 83,12,'Billing','SalInvHDAmt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 84,12,'Billing','SalInvCrNoteAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 86,12,'Billing','SalInvOtherAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 87,13,'Sales Return','ReturnHeader','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 88,13,'Sales Return','ReturnHDAmount','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 89,13,'Sales Return','ReturnProduct','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 90,13,'Sales Return','ReturnLineAmount','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 91,13,'Sales Return','ReturnProductTax','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 92,13,'Sales Return','ReturnSchemeLineDt','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 93,13,'Sales Return','ReturnSchemeFlexiDt','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 94,13,'Sales Return','ReturnSchemePointsDt','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 95,13,'Sales Return','ReturnSchemeFreePrdDt','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 96,13,'Sales Return','ReturnSchemeQPSGiven','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 97,13,'Sales Return','ReturnSchemeDbNote','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 98,14,'Return and Replacement','ReplacementHd','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 99,14,'Return and Replacement','ReplacementIn','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 100,14,'Return and Replacement','ReplacementOut','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 101,14,'Return and Replacement','ReplacementInPrdTax','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 102,14,'Return and Replacement','ReplacementOutPrdTax','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 103,14,'Return and Replacement','TransactionWiseBarCodeDt','ReplacementHd','RepDate','TransRefCode','RepRefNo','','' UNION ALL 
SELECT 104,15,'ResellDamageGoods','ResellDamageMaster','ResellDamageMaster','ReSellDate','ReDamRefNo','ReDamRefNo','Status','1' UNION ALL 
SELECT 105,15,'ResellDamageGoods','ResellDamageDetails','ResellDamageMaster','ReSellDate','ReDamRefNo','ReDamRefNo','Status','1' UNION ALL 
SELECT 106,16,'Sample Management','SamplePurchaseReceipt','SamplePurchaseReceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 107,16,'Sample Management','SamplePurchaseReceiptProduct','SamplePurchaseReceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 108,16,'Sample Management','SampleIssueHd','SampleIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 109,16,'Sample Management','SampleSchemeIssue','SampleIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 110,16,'Sample Management','SampleIssueDt','SampleIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 111,16,'Sample Management','SampleReturnHd','SampleReturnHd','ReturnDate','ReturnId','ReturnId','Status','1' UNION ALL 
SELECT 112,16,'Sample Management','SampleReturnDt','SampleReturnHd','ReturnDate','ReturnId','ReturnId','Status','1' UNION ALL 
SELECT 113,16,'Sample Management','FreeIssueHd','FreeIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 114,16,'Sample Management','FreeIssueDt','FreeIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 115,17,'Vanload and Unload','VanLoadUnloadMaster','VanLoadUnloadMaster','TransferDate','VanLoadRefNo','VanLoadRefNo','','' UNION ALL 
SELECT 116,17,'Vanload and Unload','VanLoadUnLoadDetails','VanLoadUnloadMaster','TransferDate','VanLoadRefNo','VanLoadRefNo','','' UNION ALL 
SELECT 117,18,'Standard Voucher','StdVocMaster','StdVocMaster','VocDate','VocRefNo','VocRefNo','','' UNION ALL 
SELECT 118,18,'Standard Voucher','StdVocDetails','StdVocMaster','VocDate','VocRefNo','VocRefNo','','' UNION ALL 
SELECT 119,19,'Credit Note Retailer','Creditnoteretailer','Creditnoteretailer','CrnoteDate','CrNoteNumber','CrNoteNumber','','' UNION ALL 
SELECT 120,20,'Debit Note Retailer','Debitnoteretailer','Debitnoteretailer','DbNoteDate','DbNoteNumber','DbNoteNumber','','' UNION ALL 
SELECT 121,21,'Collection Details','Receipt','Receipt','InvRcpDate','InvRcpNo','InvRcpNo','','' UNION ALL 
SELECT 122,21,'Collection Details','ReceiptInvoice','Receipt','InvRcpDate','InvRcpNo','InvRcpNo','','' UNION ALL 
SELECT 123,21,'Collection Details','CRDBNoteAdjustment','Creditnoteretailer','CrnoteDate','NoteNo','CrNoteNumber','','' UNION ALL 
SELECT 124,21,'Collection Details','CRDBNoteAdjustment','Debitnoteretailer','DbNoteDate','NoteNo','DbNoteNumber','','' UNION ALL 
SELECT 125,22,'Credit Note Supplier','CreditNoteSupplier','CreditNoteSupplier','CrNoteDate','CrNoteNumber','CrNoteNumber','','' UNION ALL 
SELECT 126,22,'Credit Note Supplier','CRDBNotePayAdjustment','CreditNoteSupplier','CrNoteDate','NoteNo','CrNoteNumber','','' UNION ALL 
SELECT 127,23,'Debit Note Supplier','DebitNoteSupplier','DebitNoteSupplier','DbNoteDate','DbNoteNumber','DbNoteNumber','','' UNION ALL 
SELECT 128,23,'Debit Note Supplier','CRDBNotePayAdjustment','DebitNoteSupplier','DbNoteDate','NoteNo','DbNoteNumber','','' UNION ALL 
SELECT 129,24,'Manual Claim','manualclaimmaster','manualclaimmaster','MacDate','MacRefNo','MacRefNo','','' UNION ALL 
SELECT 130,24,'Manual Claim','manualclaimdetails','manualclaimmaster','MacDate','MacRefNo','MacRefNo','','' UNION ALL 
SELECT 131,25,'Salesman Claim','SalesmanClaimMaster','SalesmanClaimMaster','ScmDate','ScmRefNo','ScmRefNo','','' UNION ALL 
SELECT 132,25,'Salesman Claim','SalesmanClaimDetail','SalesmanClaimMaster','ScmDate','ScmRefNo','ScmRefNo','','' UNION ALL 
SELECT 133,26,'DeliveryBoy Claim','DeliveryBoyClaimMaster','DeliveryBoyClaimMaster','DbcDate','DbcRefNo','DbcRefNo','','' UNION ALL 
SELECT 134,26,'DeliveryBoy Claim','DeliveryBoyClaimDetails','DeliveryBoyClaimMaster','DbcDate','DbcRefNo','DbcRefNo','','' UNION ALL 
SELECT 135,27,'Salesman Incentive Claim','SMIncentiveCalculatorMaster','SMIncentiveCalculatorMaster','SicDate','SicRefNo','SicRefNo','','' UNION ALL 
SELECT 136,27,'Salesman Incentive Claim','SMIncentiveCalculatorDetails','SMIncentiveCalculatorMaster','SicDate','SicRefNo','SicRefNo','','' UNION ALL 
SELECT 137,28,'VanSubsidy Claim','VanSubsidyHD','VanSubsidyHD','SubsidyDt','RefNo','RefNo','','' UNION ALL 
SELECT 138,28,'VanSubsidy Claim','VanSubsidyDetail','VanSubsidyHD','SubsidyDt','RefNo','RefNo','','' UNION ALL 
SELECT 139,29,'Transporter Claim','TransporterClaimMaster','TransporterClaimMaster','TrcDate','TrcRefNo','TrcRefNo','','' UNION ALL 
SELECT 140,29,'Transporter Claim','TransporterClaimDetails','TransporterClaimMaster','TrcDate','TrcRefNo','TrcRefNo','','' UNION ALL 
SELECT 141,30,'BatchTransfer Claim','BatchTransferClaim','BatchTransferClaim','BatTrfDate','BatRefNo','BatRefNo','','' UNION ALL 
SELECT 142,31,'Special Discount Claim','SpecialDiscountMaster','SpecialDiscountMaster','SdcDate','SdcRefNo','SdcRefNo','','' UNION ALL 
SELECT 143,31,'Special Discount Claim','SpecialDiscountDetails','SpecialDiscountMaster','SdcDate','SdcRefNo','SdcRefNo','','' UNION ALL 
SELECT 144,32,'Rate Difference Claim','RateDifferenceClaim','RateDifferenceClaim','Date','RefNo','RefNo','','' UNION ALL 
SELECT 145,33,'Purchase Shortage Claim','PurShortageClaim','PurShortageClaim','ClaimDate','PurShortId','PurShortId','','' UNION ALL 
SELECT 146,33,'Purchase Shortage Claim','PurShortageClaimDetails','PurShortageClaim','ClaimDate','PurShortId','PurShortId','','' UNION ALL 
SELECT 147,34,'Purchase Excess Claim','PurchaseExcessClaimMaster','PurchaseExcessClaimMaster','Date','RefNo','RefNo','','' UNION ALL 
SELECT 148,34,'Purchase Excess Claim','PurchaseExcessClaimDetails','PurchaseExcessClaimMaster','Date','RefNo','RefNo','','' 
GO
INSERT INTO	DataPurge_DeleteTransactionSourceDB(SlNO,ModuleId,ModuleName,TableName,ParentTable,DateFieldName,TableKeyField,ParentKeyField,ConditionField,ConditionValue)
SELECT 1,1,'Purchase Order','PurchaseorderMaster','PurchaseorderMaster','PurOrderDate','PurorderRefNo','PurorderRefNo','ConfirmSts','1,0' UNION ALL 
SELECT 2,1,'Purchase Order','PurchaseOrderDetails','PurchaseorderMaster','PurOrderDate','PurorderRefNo','PurorderRefNo','ConfirmSts','1,0' UNION ALL 
--CCRSTBot0009
SELECT 3,1,'Purchase Order','PurchaseOrderProductTax','PurchaseorderMaster','PurOrderDate','PurorderRefNo','PurorderRefNo','ConfirmSts','1,0' UNION ALL 
SELECT 4,1,'Purchase Order','PORtrBreakUp','PurchaseorderMaster','PurOrderDate','PurorderRefNo','PurorderRefNo','ConfirmSts','1,0' UNION ALL 
SELECT 5,2,'Purchase Receipt','Purchasereceipt','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 6,2,'Purchase Receipt','PurchaseReceiptProduct','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 7,2,'Purchase Receipt','PurchaseReceiptBreakup','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 8,2,'Purchase Receipt','PurchaseReceiptHdAmount','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 9,2,'Purchase Receipt','PurchaseReceiptLineAmount','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 10,2,'Purchase Receipt','PurchaseReceiptProductTax','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 11,2,'Purchase Receipt','PurchaseReceiptOtherCharges','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 12,2,'Purchase Receipt','PurchaseReceiptClaimScheme','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 13,2,'Purchase Receipt','PurchaseReceiptClaim','Purchasereceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 14,2,'Purchase Receipt','PurchaseReceiptCreditDebit','Purchasereceipt','GoodsRcvdDate','CmpInvNo','CmpInvNo','Status','1' UNION ALL 
SELECT 15,2,'Purchase Receipt','PurchaseReceiptMapping','Purchasereceipt','GoodsRcvdDate','CompInvNo','CmpInvNo','Status','1' UNION ALL 
SELECT 16,2,'Purchase Receipt','PurchaseReceiptProductMapping','Purchasereceipt','GoodsRcvdDate','CompInvNo','CmpInvNo','Status','1' UNION ALL 
SELECT 17,3,'Purchase Return','PurchaseReturn','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 18,3,'Purchase Return','PurchaseReturnProduct','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 19,3,'Purchase Return','PurchaseReturnBreakUp','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 20,3,'Purchase Return','PurchaseReturnHdAmount','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 21,3,'Purchase Return','PurchaseReturnLineAmount','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 22,3,'Purchase Return','PurchaseReturnProductTax','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 23,3,'Purchase Return','PurchaseReturnOtherCharges','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 24,3,'Purchase Return','PurchaseReturnClaimScheme','PurchaseReturn','PurRetDate','PurRetId','PurRetId','Status','1' UNION ALL 
SELECT 25,4,'Return to Company','ReturntoCompany','ReturntoCompany','RtnCmpDate','RtnCmpRefNo','RtnCmpRefNo','Status','1' UNION ALL 
SELECT 26,4,'Return to Company','ReturnToCompanyDt','ReturntoCompany','RtnCmpDate','RtnCmpRefNo','RtnCmpRefNo','Status','1' UNION ALL 
SELECT 27,4,'Return to Company','ReturnToCompanyDtTax','ReturntoCompany','RtnCmpDate','RtnCmpRefNo','RtnCmpRefNo','Status','1' UNION ALL 
SELECT 28,5,'IDT Management','IDTManagement','IDTManagement','IDTMngDate','IDTMngRefNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 29,5,'IDT Management','IDTManagementProduct','IDTManagement','IDTMngDate','IDTMngRefNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 30,5,'IDT Management','IDTManagementProductTax','IDTManagement','IDTMngDate','IDTMngRefNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 31,5,'IDT Management','IDTManagementLineAmount','IDTManagement','IDTMngDate','IDTMngRefNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 32,5,'IDT Management','IDTReceipt','IDTReceipt','IDTCollectionDate','IDTRcpNo','IDTMngRefNo','Status','1' UNION ALL 
SELECT 33,5,'IDT Management','IDTReceiptInvoice','IDTReceipt','IDTCollectionDate','IDTRcpNo','IDTRcpNo','Status','1' UNION ALL 
SELECT 34,5,'IDT Management','IDTReceiptInvoice','IDTReceipt','IDTCollectionDate','IDTRcpNo','IDTRcpNo','Status','1' UNION ALL 
SELECT 35,6,'Stock Management','StockManagement','StockManagement','StkMngDate','StkMngRefNo','StkMngRefNo','Status','1' UNION ALL 
SELECT 36,6,'Stock Management','StockManagementProduct','StockManagement','StkMngDate','StkMngRefNo','StkMngRefNo','Status','1' UNION ALL 
SELECT 37,6,'Stock Management','StockManagementProductTax','StockManagement','StkMngDate','StkMngRefNo','StkMngRefNo','Status','1' UNION ALL 
SELECT 38,7,'Location Master','LocationTransferMaster','LocationTransferMaster','LcnTrfDate','LcnRefNo','LcnRefNo','','' UNION ALL 
SELECT 39,7,'Location Master','LocationTransferDetails','LocationTransferMaster','LcnTrfDate','LcnRefNo','LcnRefNo','','' UNION ALL 
SELECT 40,8,'Batch Transfer','BatchTransfer','BatchTransfer','BatTrfDate','BatRefNo','BatRefNo','','' UNION ALL 
SELECT 41,9,'Salvage','Salvage','Salvage','SalvageDate','SalvageRefNo','SalvageRefNo','Status','1' UNION ALL 
SELECT 42,9,'Salvage','SalvageProduct','Salvage','SalvageDate','SalvageRefNo','SalvageRefNo','Status','1' UNION ALL 
SELECT 43,10,'Stock Journal','StockJournal','StockJournal','StkJournalDate','StkJournalRefNo','StkJournalRefNo','','' UNION ALL 
SELECT 44,10,'Stock Journal','StockJournalDt','StockJournal','StkJournalDate','StkJournalRefNo','StkJournalRefNo','','' UNION ALL 
SELECT 45,10,'Stock Journal','StkJournalClaim','StockJournal','StkJournalDate','StkJournalRefNo','StkJournalRefNo','','' UNION ALL 
SELECT 46,11,'Order Booking','OrderBooking','OrderBooking','OrderDate','OrderNo','OrderNo','','' UNION ALL 
SELECT 47,11,'Order Booking','OrderBookingProducts','OrderBooking','OrderDate','OrderNo','OrderNo','','' UNION ALL 
SELECT 48,12,'Billing','VehicleAllocationMaster','VehicleAllocationMaster','AllotmentDate','AllotmentNumber','AllotmentNumber','','' UNION ALL 
SELECT 49,12,'Billing','VehicleAllocationDetails','SalesInvoice','SalInvDate','SaleInvNo','SAlinvno','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 50,12,'Billing','SalesInvoiceEditableHistory','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 51,12,'Billing','SalesInvoice','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 52,12,'Billing','SalesInvoiceProduct','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 53,12,'Billing','SalesInvoiceHdAmount','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 54,12,'Billing','SalesInvoiceLineAmount','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 55,12,'Billing','SalesInvoiceProductTax','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 56,12,'Billing','SalesInvoiceSchemeHd','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 57,12,'Billing','SalesInvoiceSchemeDtBilled','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 58,12,'Billing','SalesInvoiceSchemeLineWise','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 59,12,'Billing','SalesInvoiceSchemeFlexiDt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 60,12,'Billing','SalesInvoiceSchemeDtFreePrd','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 61,12,'Billing','SalesInvoiceSchemeDtPoints','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 62,12,'Billing','SalesInvoiceSchemeQPSGiven','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 63,12,'Billing','SalesInvoiceUnSelectedScheme','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 64,12,'Billing','SalesInvoiceQPSCumulative','SalesInvoiceQPSCumulative','LastModDate','','','','' UNION ALL 
SELECT 65,12,'Billing','SalesInvoiceQPSRedeemed','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 66,12,'Billing','SalInvoiceDeliveryChallan','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 67,12,'Billing','SalesInvoiceCrDays','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 68,12,'Billing','SalesInvoiceQPSSchemeAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 69,12,'Billing','SalesinvoiceSchemeFlag','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 70,12,'Billing','SalesInvoiceModificationHistory','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 71,12,'Billing','SalesInvoiceSchemeClaimDt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 72,12,'Billing','SalesInvoiceKitItemDt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 73,12,'Billing','SalesInvoiceMrkRtnDbNote','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 74,12,'Billing','SalesInvoiceWindowService','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 75,12,'Billing','TransactionWiseBarCodeDt','SalesInvoice','SalInvDate','TransRefCode','Salinvno','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 76,12,'Billing','SalesInvoiceWindowDisplay','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 77,12,'Billing','SalesInvoiceMarketReturn','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 78,12,'Billing','SalesInvoiceMrkRtnDbNote','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 79,12,'Billing','SalInvDbNoteAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 80,12,'Billing','SalInvOnAccAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 81,12,'Billing','SalesinvoiceOrderBooking','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL
SELECT 82,12,'Billing','SalInvLineAmt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 83,12,'Billing','SalInvHDAmt','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 84,12,'Billing','SalInvCrNoteAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 85,12,'Billing','SalInvOnAccAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 86,12,'Billing','SalInvOtherAdj','SalesInvoice','SalInvDate','Salid','Salid','Dlvsts','1,2,3,4,5' UNION ALL 
SELECT 87,13,'Sales Return','ReturnHeader','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 88,13,'Sales Return','ReturnHDAmount','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 89,13,'Sales Return','ReturnProduct','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 90,13,'Sales Return','ReturnLineAmount','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 91,13,'Sales Return','ReturnProductTax','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 92,13,'Sales Return','ReturnSchemeLineDt','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 93,13,'Sales Return','ReturnSchemeFlexiDt','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 94,13,'Sales Return','ReturnSchemePointsDt','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 95,13,'Sales Return','ReturnSchemeFreePrdDt','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 96,13,'Sales Return','ReturnSchemeQPSGiven','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 97,13,'Sales Return','ReturnSchemeDbNote','ReturnHeader','ReturnDate','ReturnID','ReturnID','Status','0' UNION ALL 
SELECT 98,14,'Return and Replacement','ReplacementHd','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 99,14,'Return and Replacement','ReplacementIn','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 100,14,'Return and Replacement','ReplacementOut','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 101,14,'Return and Replacement','ReplacementInPrdTax','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 102,14,'Return and Replacement','ReplacementOutPrdTax','ReplacementHd','RepDate','RepRefNo','RepRefNo','','' UNION ALL 
SELECT 103,14,'Return and Replacement','TransactionWiseBarCodeDt','ReplacementHd','RepDate','TransRefCode','RepRefNo','','' UNION ALL 
SELECT 104,15,'ResellDamageGoods','ResellDamageMaster','ResellDamageMaster','ReSellDate','ReDamRefNo','ReDamRefNo','Status','1' UNION ALL 
SELECT 105,15,'ResellDamageGoods','ResellDamageDetails','ResellDamageMaster','ReSellDate','ReDamRefNo','ReDamRefNo','Status','1' UNION ALL 
SELECT 106,16,'Sample Management','SamplePurchaseReceipt','SamplePurchaseReceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 107,16,'Sample Management','SamplePurchaseReceiptProduct','SamplePurchaseReceipt','GoodsRcvdDate','PurRcptId','PurRcptId','Status','1' UNION ALL 
SELECT 108,16,'Sample Management','SampleIssueHd','SampleIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 109,16,'Sample Management','SampleSchemeIssue','SampleIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 110,16,'Sample Management','SampleIssueDt','SampleIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 111,16,'Sample Management','SampleReturnHd','SampleReturnHd','ReturnDate','ReturnId','ReturnId','Status','1' UNION ALL 
SELECT 112,16,'Sample Management','SampleReturnDt','SampleReturnHd','ReturnDate','ReturnId','ReturnId','Status','1' UNION ALL 
SELECT 113,16,'Sample Management','FreeIssueHd','FreeIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 114,16,'Sample Management','FreeIssueDt','FreeIssueHd','IssueDate','IssueId','IssueId','Status','1' UNION ALL 
SELECT 115,17,'Vanload and Unload','VanLoadUnloadMaster','VanLoadUnloadMaster','TransferDate','VanLoadRefNo','VanLoadRefNo','','' UNION ALL 
SELECT 116,17,'Vanload and Unload','VanLoadUnLoadDetails','VanLoadUnloadMaster','TransferDate','VanLoadRefNo','VanLoadRefNo','','' UNION ALL 
SELECT 118,18,'Standard Voucher','StdVocMaster','StdVocMaster','VocDate','VocRefNo','VocRefNo','','' UNION ALL 
SELECT 117,18,'Standard Voucher','StdVocDetails','StdVocMaster','VocDate','VocRefNo','VocRefNo','','' UNION ALL 
SELECT 119,19,'Credit Note Retailer','Creditnoteretailer','Creditnoteretailer','CrnoteDate','CrNoteNumber','CrNoteNumber','','' UNION ALL 
SELECT 120,20,'Debit Note Retailer','Debitnoteretailer','Debitnoteretailer','DbNoteDate','DbNoteNumber','DbNoteNumber','','' UNION ALL 
SELECT 121,21,'Collection Details','Receipt','Receipt','InvRcpDate','InvRcpNo','InvRcpNo','','' UNION ALL 
SELECT 122,21,'Collection Details','ReceiptInvoice','Receipt','InvRcpDate','InvRcpNo','InvRcpNo','','' UNION ALL 
SELECT 123,21,'Collection Details','CRDBNoteAdjustment','Creditnoteretailer','CrnoteDate','NoteNo','CrNoteNumber','','' UNION ALL 
SELECT 124,21,'Collection Details','CRDBNoteAdjustment','Debitnoteretailer','DbNoteDate','NoteNo','DbNoteNumber','','' UNION ALL 
SELECT 125,22,'Credit Note Supplier','CreditNoteSupplier','CreditNoteSupplier','CrNoteDate','CrNoteNumber','CrNoteNumber','','' UNION ALL 
SELECT 126,22,'Credit Note Supplier','CRDBNotePayAdjustment','CreditNoteSupplier','CrNoteDate','NoteNo','CrNoteNumber','','' UNION ALL 
SELECT 127,23,'Debit Note Supplier','DebitNoteSupplier','DebitNoteSupplier','DbNoteDate','DbNoteNumber','DbNoteNumber','','' UNION ALL 
SELECT 128,23,'Debit Note Supplier','CRDBNotePayAdjustment','DebitNoteSupplier','DbNoteDate','NoteNo','DbNoteNumber','','' UNION ALL 
SELECT 129,24,'Manual Claim','manualclaimmaster','manualclaimmaster','MacDate','MacRefNo','MacRefNo','','' UNION ALL 
SELECT 130,24,'Manual Claim','manualclaimdetails','manualclaimmaster','MacDate','MacRefNo','MacRefNo','','' UNION ALL 
SELECT 131,25,'Salesman Claim','SalesmanClaimMaster','SalesmanClaimMaster','ScmDate','ScmRefNo','ScmRefNo','','' UNION ALL 
SELECT 132,25,'Salesman Claim','SalesmanClaimDetail','SalesmanClaimMaster','ScmDate','ScmRefNo','ScmRefNo','','' UNION ALL 
SELECT 133,26,'DeliveryBoy Claim','DeliveryBoyClaimMaster','DeliveryBoyClaimMaster','DbcDate','DbcRefNo','DbcRefNo','','' UNION ALL 
SELECT 134,26,'DeliveryBoy Claim','DeliveryBoyClaimDetails','DeliveryBoyClaimMaster','DbcDate','DbcRefNo','DbcRefNo','','' UNION ALL 
SELECT 135,27,'Salesman Incentive Claim','SMIncentiveCalculatorMaster','SMIncentiveCalculatorMaster','SicDate','SicRefNo','SicRefNo','','' UNION ALL 
SELECT 136,27,'Salesman Incentive Claim','SMIncentiveCalculatorDetails','SMIncentiveCalculatorMaster','SicDate','SicRefNo','SicRefNo','','' UNION ALL 
SELECT 137,28,'VanSubsidy Claim','VanSubsidyHD','VanSubsidyHD','SubsidyDt','RefNo','RefNo','','' UNION ALL 
SELECT 138,28,'VanSubsidy Claim','VanSubsidyDetail','VanSubsidyHD','SubsidyDt','RefNo','RefNo','','' UNION ALL 
SELECT 139,29,'Transporter Claim','TransporterClaimMaster','TransporterClaimMaster','TrcDate','TrcRefNo','TrcRefNo','','' UNION ALL 
SELECT 140,29,'Transporter Claim','TransporterClaimDetails','TransporterClaimMaster','TrcDate','TrcRefNo','TrcRefNo','','' UNION ALL 
SELECT 141,30,'BatchTransfer Claim','BatchTransferClaim','BatchTransferClaim','BatTrfDate','BatRefNo','BatRefNo','','' UNION ALL 
SELECT 142,31,'Special Discount Claim','SpecialDiscountMaster','SpecialDiscountMaster','SdcDate','SdcRefNo','SdcRefNo','','' UNION ALL 
SELECT 143,31,'Special Discount Claim','SpecialDiscountDetails','SpecialDiscountMaster','SdcDate','SdcRefNo','SdcRefNo','','' UNION ALL 
SELECT 144,32,'Rate Difference Claim','RateDifferenceClaim','RateDifferenceClaim','Date','RefNo','RefNo','','' UNION ALL 
SELECT 145,33,'Purchase Shortage Claim','PurShortageClaim','PurShortageClaim','ClaimDate','PurShortId','PurShortId','','' UNION ALL 
SELECT 146,33,'Purchase Shortage Claim','PurShortageClaimDetails','PurShortageClaim','ClaimDate','PurShortId','PurShortId','','' UNION ALL 
SELECT 147,34,'Purchase Excess Claim','PurchaseExcessClaimMaster','PurchaseExcessClaimMaster','Date','RefNo','RefNo','','' UNION ALL 
SELECT 148,34,'Purchase Excess Claim','PurchaseExcessClaimDetails','PurchaseExcessClaimMaster','Date','RefNo','RefNo','','' 
GO
INSERT INTO  DataPurge_MasterTable(DataPurgMasterTable)
SELECT 'AccountsDerivedTemplate' UNION ALL
SELECT 'AccountsTemplate' UNION ALL
SELECT 'ACDDBSDetails' UNION ALL
SELECT 'AcGroupSettings' UNION ALL
SELECT 'ACMaster' UNION ALL
SELECT 'ACPeriod' UNION ALL
SELECT 'ACStatment' UNION ALL
SELECT 'AppTitle' UNION ALL
SELECT 'AttendanceRegister' UNION ALL
SELECT 'Attributes' UNION ALL
SELECT 'AutoBackUp' UNION ALL
SELECT 'AutoBackupConfiguration' UNION ALL
SELECT 'AutoDBCDPrdSlabAchieved' UNION ALL
SELECT 'AutoDBCDProductTax' UNION ALL
SELECT 'AutoDBCDSlabAchieved' UNION ALL
SELECT 'AutoDbCrSlabConfig' UNION ALL
SELECT 'AutoPO' UNION ALL
SELECT 'AutoRetailerClassShift' UNION ALL
SELECT 'Bank' UNION ALL
SELECT 'BankBranch' UNION ALL
SELECT 'BarCodeHd' UNION ALL
SELECT 'BatchCreation' UNION ALL
SELECT 'BatchCreationMaster' UNION ALL
SELECT 'BatchTransferConfig' UNION ALL
SELECT 'BillSequenceDetail' UNION ALL
SELECT 'BillSequenceMaster' UNION ALL
SELECT 'BillSeriesConfig' UNION ALL
SELECT 'BillSeriesDt' UNION ALL
SELECT 'BillSeriesDtValue' UNION ALL
SELECT 'BillSeriesHD' UNION ALL
SELECT 'BillTemplateHD' UNION ALL
SELECT 'BnkAcNo' UNION ALL
SELECT 'BroadCast' UNION ALL
SELECT 'Configuration' UNION ALL
SELECT 'CounterConfiguration' UNION ALL
SELECT 'CustomUpDownload' UNION ALL
SELECT 'CSDetails' UNION ALL
SELECT 'ContractPricingMaster' UNION ALL
SELECT 'ContractPricingDetails' UNION ALL
SELECT 'Construction' UNION ALL
SELECT 'ClaimGroupMaster' UNION ALL
SELECT 'COAMaster' UNION ALL
SELECT 'ConfigUsers' UNION ALL
SELECT 'ConfigProfile' UNION ALL
SELECT 'CustomCaptions' UNION ALL
SELECT 'CouponRedHd' UNION ALL
SELECT 'CouponRedSlabDt' UNION ALL
SELECT 'CaptionTypeMaster' UNION ALL
SELECT 'CompanyCounters' UNION ALL
SELECT 'CouponRedProducts' UNION ALL
SELECT 'CouponRedOtherDt' UNION ALL
SELECT 'CouponDenomHd' UNION ALL
SELECT 'CouponDenomDt' UNION ALL
SELECT 'CouponDenomSlabDt' UNION ALL
SELECT 'CouponDenomFreePrd' UNION ALL
SELECT 'CouponDefinitionHd' UNION ALL
SELECT 'CouponDefinitionDt' UNION ALL
SELECT 'CouponCollectionHd' UNION ALL
SELECT 'CouponCollectionDt' UNION ALL
SELECT 'ClaimNormDefinition' UNION ALL
SELECT 'CustomUpDownloadStatus' UNION ALL
SELECT 'ClusterScreens' UNION ALL
SELECT 'ClusterMaster' UNION ALL
SELECT 'ClusterDetails' UNION ALL
SELECT 'ContractPrdBatId' UNION ALL
SELECT 'ClusterGroupMaster' UNION ALL
SELECT 'CustomUpDownloadCount' UNION ALL
SELECT 'ClusterGroupDetails' UNION ALL
SELECT 'ClusterAssign' UNION ALL
SELECT 'COAOpeningBalance' UNION ALL
SELECT 'ConfigMailDetails' UNION ALL
SELECT 'Counters' UNION ALL
SELECT 'Company' UNION ALL
SELECT 'DeliveryBoy' UNION ALL
SELECT 'DeliveryBoyRoute' UNION ALL
SELECT 'DependencyTable' UNION ALL
SELECT 'DownloadNotification' UNION ALL
SELECT 'DownloadNotificationCount' UNION ALL
SELECT 'DBShrink' UNION ALL
SELECT 'Distributor' UNION ALL
SELECT 'DayEndDates' UNION ALL
SELECT 'DayEndValidation' UNION ALL
SELECT 'DEPLOY_FILE_ORDER' UNION ALL
SELECT 'DEPLOY_FILENAMES' UNION ALL
SELECT 'DayEndProcess' UNION ALL
SELECT 'DBAccessDT' UNION ALL
SELECT 'DEPLOYSTATUSUPDATE' UNION ALL
SELECT 'DeployExeNames' UNION ALL
SELECT 'DefineFileEmail' UNION ALL
SELECT 'DefineFileFTPHTTP' UNION ALL
SELECT 'DefaultPriceHistory' UNION ALL
SELECT 'DefendRestore' UNION ALL
SELECT 'ERPPrdCCodeMapping' UNION ALL
SELECT 'ExtractAksoNobal' UNION ALL
SELECT 'ExistPriceDetails' UNION ALL
SELECT 'ETLExtractTableName' UNION ALL
SELECT 'ExtractFileMaster' UNION ALL
SELECT 'ETLMaster' UNION ALL
SELECT 'ExtractFileDetails' UNION ALL
SELECT 'EXTRACT_FILE_NAMES' UNION ALL
SELECT 'EXP_MOVE_FILES' UNION ALL
SELECT 'FBMAUsers' UNION ALL
SELECT 'FocusBrandHd' UNION ALL
SELECT 'FocusBrandDt' UNION ALL
SELECT 'FieldLevelAccessDt' UNION ALL
SELECT 'FTP_FILE_STATUS' UNION ALL
SELECT 'FocusRuleSettings' UNION ALL
SELECT 'FocusBrandTargetHd' UNION ALL
SELECT 'FocusBrandTargetDt' UNION ALL
SELECT 'FBMLedger' UNION ALL
SELECT 'FBMSchDetails' UNION ALL
SELECT 'FBMSwitching' UNION ALL
SELECT 'FBMSwitchingDetails' UNION ALL
SELECT 'FBMTrackIn' UNION ALL
SELECT 'FBMTrackOut' UNION ALL
SELECT 'FBMSchemeOpen' UNION ALL
SELECT 'FBMAdjustmentDetails' UNION ALL
SELECT 'Geography' UNION ALL
SELECT 'GeographyLevel' UNION ALL
SELECT 'GraphicalRepMasterData' UNION ALL
SELECT 'GraphicalRepOption' UNION ALL
SELECT 'GraphicalRepSPParam' UNION ALL
SELECT 'GraphicalRepViewBy' UNION ALL
SELECT 'HealthCheckMaster' UNION ALL
SELECT 'HotFixLog' UNION ALL
SELECT 'HotSearchEditorDt' UNION ALL
SELECT 'HotSearchEditorHd' UNION ALL
SELECT 'HotSearchEditorHd2' UNION ALL
SELECT 'IDTSequenceDetail' UNION ALL
SELECT 'IDTSequenceMaster' UNION ALL
SELECT 'IMPORT_DEPLOY_FILENAMES' UNION ALL
SELECT 'IMPORT_FILE_DETAILS' UNION ALL
SELECT 'IMPORT_FILENAMES' UNION ALL
SELECT 'IMPORT_FTP_FILENAMES' UNION ALL
SELECT 'JCHoliday' UNION ALL
SELECT 'JCMast' UNION ALL
SELECT 'JCMonth' UNION ALL
SELECT 'JCMonthEnd' UNION ALL
SELECT 'JCRep' UNION ALL
SELECT 'JCWeek' UNION ALL
SELECT 'KeyClaimGroup' UNION ALL
SELECT 'KeyDiscountClaim' UNION ALL
SELECT 'KeyGroupDisc' UNION ALL
SELECT 'KeyGroupMaster' UNION ALL
SELECT 'KitProduct' UNION ALL
SELECT 'KitProductBatch' UNION ALL
SELECT 'KitProductStock' UNION ALL
SELECT 'KitProductTransDt' UNION ALL
SELECT 'LanguageMaster' UNION ALL
SELECT 'LaunchTargetDt' UNION ALL
SELECT 'LaunchTargetFilter' UNION ALL
SELECT 'LaunchTargetHd' UNION ALL
SELECT 'LaunchTargetMonthPlan' UNION ALL
SELECT 'LoadingSheetSubRpt' UNION ALL
SELECT 'Location' UNION ALL
SELECT 'LocationType' UNION ALL
SELECT 'LoyaltyHeader' UNION ALL
SELECT 'LoyaltyProductWise' UNION ALL
SELECT 'LoyaltyRetailer' UNION ALL
SELECT 'LoyaltyScheme' UNION ALL
SELECT 'MassUpdateOldPrdBatTaxGroup' UNION ALL
SELECT 'MassUpdateOldRtrTaxGroup' UNION ALL
SELECT 'MasterUploadTable' UNION ALL
SELECT 'Menudef' UNION ALL
SELECT 'ModernTradeDetails' UNION ALL
SELECT 'ModernTradeMaster' UNION ALL
SELECT 'MonthDt' UNION ALL
SELECT 'MOVE_FILES' UNION ALL
SELECT 'MultiCurrencyValue' UNION ALL
SELECT 'MultiUserTransValidation' UNION ALL
SELECT 'ManualSplPricingMaster' UNION ALL
SELECT 'NewProduct' UNION ALL
SELECT 'Norms' UNION ALL
SELECT 'ProductClaimNormDefHd' UNION ALL
SELECT 'ProductClaimNormDefDt' UNION ALL
SELECT 'PurInvSeriesAttrList' UNION ALL
SELECT 'PurInvSeriesHD' UNION ALL
SELECT 'PurInvSeriesDt' UNION ALL
SELECT 'PurInvSeriesPrefix' UNION ALL
SELECT 'PurInvSeriesAttribute' UNION ALL
SELECT 'Product' UNION ALL
SELECT 'PointRedemptionMaster' UNION ALL
SELECT 'PointRedemptionRtr' UNION ALL
SELECT 'PointRedemptionSlab' UNION ALL
SELECT 'PointRedemptionSlabPrd' UNION ALL
SELECT 'ProductCategoryLevel' UNION ALL
SELECT 'PurchaseReceiptMapping' UNION ALL
SELECT 'ProductNSVPriceDt' UNION ALL
SELECT 'ProductCategoryValue' UNION ALL
SELECT 'ProductBatch' UNION ALL
SELECT 'PurchaseOrderConfig' UNION ALL
SELECT 'ProductBatchDetails' UNION ALL
SELECT 'PntRetSchemeHD' UNION ALL
SELECT 'PrdBatUOMMapping' UNION ALL
SELECT 'PntRetSchemeDt' UNION ALL
SELECT 'ProductSequence' UNION ALL
SELECT 'PDAPrdCategoryValue' UNION ALL
SELECT 'ProductSeqDetails' UNION ALL
SELECT 'ProductBatchConstruction' UNION ALL
SELECT 'ProductUnit' UNION ALL
SELECT 'PurchaseColumns' UNION ALL
SELECT 'PurSalAccConfig' UNION ALL
SELECT 'PriceDifference' UNION ALL
SELECT 'PriceApprovalHD' UNION ALL
SELECT 'PriceApprovalProduct' UNION ALL
SELECT 'PriceApprovedTax' UNION ALL
SELECT 'ProductCategoryLevel_Migration' UNION ALL
SELECT 'PrdSalesBundleProducts' UNION ALL
SELECT 'PrdSalesBundle' UNION ALL
SELECT 'PurchaseSequenceDetail' UNION ALL
SELECT 'PurchaseSequenceMaster' UNION ALL
SELECT 'ProfileHD' UNION ALL
SELECT 'ProductBatchTaxPercent' UNION ALL
SELECT 'ProfileDt' UNION ALL
SELECT 'POPrdNormMappingHd' UNION ALL
SELECT 'POPrdNormMappingDt' UNION ALL
SELECT 'QuarterMaster' UNION ALL
SELECT 'RdClaimPercentage' UNION ALL
SELECT 'RdFrieghtClaimAmount' UNION ALL
SELECT 'Reginfo' UNION ALL
SELECT 'RetailerCategoryLevel' UNION ALL
SELECT 'RegDistDetails' UNION ALL
SELECT 'RetailerCategory' UNION ALL
SELECT 'RetailerPotentialClass' UNION ALL
SELECT 'RptDetails' UNION ALL
SELECT 'RetailerValueClass' UNION ALL
SELECT 'RptFormula' UNION ALL
SELECT 'RetailerSeqDetails' UNION ALL
SELECT 'RptFilter' UNION ALL
SELECT 'RetailerSequence' UNION ALL
SELECT 'RptSelectionHd' UNION ALL
SELECT 'RetailerShipAdd' UNION ALL
SELECT 'RptGroup' UNION ALL
SELECT 'RouteCovPlanMaster' UNION ALL
SELECT 'RptHeader' UNION ALL
SELECT 'RouteCovPlanDetails' UNION ALL
SELECT 'ReportFilterDt' UNION ALL
SELECT 'RouteVillage' UNION ALL
SELECT 'RetailerRelation' UNION ALL
SELECT 'RedemPointsAchived' UNION ALL
SELECT 'Retailer' UNION ALL
SELECT 'RetailerClassficationChange' UNION ALL
SELECT 'ROI' UNION ALL
SELECT 'RetailerBank' UNION ALL
SELECT 'ReDownloadRequest' UNION ALL
SELECT 'RetailerMarket' UNION ALL
SELECT 'RetailerValueClassMap' UNION ALL
SELECT 'RptSubReport' UNION ALL
SELECT 'RetailerPotentialClassMap' UNION ALL
SELECT 'RetailerDiscountConfig' UNION ALL
SELECT 'RetailerPrdMerchandise' UNION ALL
SELECT 'Report_Udc_FilterDt' UNION ALL
SELECT 'Rpt_Udc_Details' UNION ALL
SELECT 'Rpt_Udc_Filter' UNION ALL
SELECT 'Rpt_Udc_Formula' UNION ALL
SELECT 'Rpt_Udc_Group' UNION ALL
SELECT 'Rpt_Udc_Header' UNION ALL
SELECT 'Rpt_Udc_SelectionHd' UNION ALL
SELECT 'RptUdcGroupSales' UNION ALL
SELECT 'RptUdcStoreSchemeDetails' UNION ALL
SELECT 'RetailerStkNormHD' UNION ALL
SELECT 'RetailerStkNormDt' UNION ALL
SELECT 'RptColNames' UNION ALL
SELECT 'RptExcelFlag' UNION ALL
SELECT 'RptExcelHeaders' UNION ALL
SELECT 'RetailerOnAccount' UNION ALL
SELECT 'RptColValues' UNION ALL
SELECT 'RetailerClassShiftDetails' UNION ALL
SELECT 'ReasonMaster' UNION ALL
SELECT 'RouteMaster' UNION ALL
SELECT 'RefreshReason' UNION ALL
SELECT 'ReminderEntry' UNION ALL
SELECT 'SyncStatus' UNION ALL
SELECT 'SyncAttempt' UNION ALL
SELECT 'SalInvRtrReason' UNION ALL 
SELECT 'StockJournalConfig' UNION ALL
SELECT 'Supplier' UNION ALL
SELECT 'SampleSchemeMaster' UNION ALL
SELECT 'SampleSchemeProducts' UNION ALL
SELECT 'SampleSlabFrePrds' UNION ALL
SELECT 'SampleSlabMultiFrePrds' UNION ALL
SELECT 'StockNorm' UNION ALL
SELECT 'SchemeAnotherPrdHd' UNION ALL
SELECT 'SMCustomUpDownload' UNION ALL
SELECT 'SchemeAnotherPrdDt' UNION ALL
SELECT 'SalesInvoiceReportingColumns' UNION ALL
SELECT 'SpreadDisplayColumns' UNION ALL
SELECT 'SampleScheme' UNION ALL
SELECT 'SETUPDETAILS' UNION ALL
SELECT 'SyncProcess' UNION ALL
SELECT 'SchemeMasterControlHistory' UNION ALL
SELECT 'SalesInvoiceBookNoSettings' UNION ALL
SELECT 'StockType' UNION ALL
SELECT 'ScExtractFileMaster' UNION ALL
SELECT 'SpecialRateAftDownLoad' UNION ALL
SELECT 'Sync_Master' UNION ALL
SELECT 'SalesmanIncentive' UNION ALL
SELECT 'SyncCounter' UNION ALL
SELECT 'SchemeBudget' UNION ALL
SELECT 'Sync_RecordDetails' UNION ALL
SELECT 'SerialCounter' UNION ALL
SELECT 'SpecialRatesApplicable' UNION ALL
SELECT 'SchemeCombiCriteria' UNION ALL
SELECT 'ScreenDefaultValues' UNION ALL
SELECT 'StockLedgerDateCheck' UNION ALL
SELECT 'SchemeBudgetValues' UNION ALL
SELECT 'SchemeSlabCouponMaster' UNION ALL
SELECT 'SchemeSlabCouponDt' UNION ALL
SELECT 'SiteCodeMaster' UNION ALL
SELECT 'SchemeRuleSettings' UNION ALL
SELECT 'SchemeRtrLevelValidation' UNION ALL
SELECT 'StockManagementType' UNION ALL
SELECT 'StockManagementTypeDt' UNION ALL
SELECT 'StkMgntConfig' UNION ALL
SELECT 'StkMgmtCoaIds' UNION ALL
SELECT 'SynchronizeHdrSPTableName' UNION ALL
SELECT 'SynchronizeTranSPTableName' UNION ALL
SELECT 'SchemeRuleCategory' UNION ALL
SELECT 'SchemeMaster' UNION ALL
SELECT 'sysdiagrams' UNION ALL
SELECT 'SchemeProducts' UNION ALL
SELECT 'SchemeRetAttr' UNION ALL
SELECT 'SchemeSlabCombiPrds' UNION ALL
SELECT 'Salesman' UNION ALL
SELECT 'SchemeSlabFrePrds' UNION ALL
SELECT 'SalesmanMarket' UNION ALL
SELECT 'SchemeSlabMultiFrePrds' UNION ALL
SELECT 'SchemeSlabs' UNION ALL
SELECT 'tbl_gr_users' UNION ALL
SELECT 'Tbl_Generic_Reports' UNION ALL
SELECT 'Tbl_Generic_Reports_Filters' UNION ALL
SELECT 'Tbl_DownloadIntegration' UNION ALL
SELECT 'Tbl_gr_housekeeping' UNION ALL
SELECT 'Tbl_UploadIntegration_Process' UNION ALL
SELECT 'Tbl_UploadIntegration' UNION ALL
SELECT 'TBL_GR_BUILD_RH' UNION ALL
SELECT 'TempDownloadNotification' UNION ALL
SELECT 'TargetNormMappingHd' UNION ALL
SELECT 'TargetNormMappingDt' UNION ALL
SELECT 'TaxConfiguration' UNION ALL
SELECT 'TaxGroupSetting' UNION ALL
SELECT 'TransactionMaster' UNION ALL
SELECT 'TransactionUomMapping' UNION ALL
SELECT 'Transporter' UNION ALL
SELECT 'TransactionScreen' UNION ALL
SELECT 'TBL_Downloadprocess_ImportPDA' UNION ALL
SELECT 'Track_RtrCategoryandClassChange' UNION ALL
SELECT 'Tbl_PDAConfiguration_PDA' UNION ALL
SELECT 'TBL_GR_BUILD_PH' UNION ALL
SELECT 'Tbl_DownloadProcess_ExportPDA' UNION ALL
SELECT 'TargetAnalysisHolidays' UNION ALL
SELECT 'TaxSettingMaster' UNION ALL
SELECT 'TaxSettingDetail' UNION ALL
SELECT 'UdcDefault' UNION ALL
SELECT 'UdcDetails' UNION ALL
SELECT 'UDCGroupDt' UNION ALL
SELECT 'UDCGroupDtValue' UNION ALL
SELECT 'UDCGroupHD' UNION ALL
SELECT 'UdcHD' UNION ALL
SELECT 'UdcMaster' UNION ALL
SELECT 'Unsaleable_In' UNION ALL
SELECT 'Unsaleable_Out' UNION ALL
SELECT 'UomConfig' UNION ALL
SELECT 'UomGroup' UNION ALL
SELECT 'UOMHave' UNION ALL
SELECT 'UOMIdWise' UNION ALL
SELECT 'UomMaster' UNION ALL
SELECT 'UOMNotHave' UNION ALL
SELECT 'UpdaterLog' UNION ALL
SELECT 'UserKeys' UNION ALL
SELECT 'Users' UNION ALL
SELECT 'VanLoadGuideDetails' UNION ALL
SELECT 'VanLoadGuideMaster' UNION ALL
SELECT 'VatTaxClaim' UNION ALL
SELECT 'VatTaxClaimDet' UNION ALL
SELECT 'Vehicle' UNION ALL
SELECT 'VehicleCategory' UNION ALL
SELECT 'VehicleSubsidy' UNION ALL
SELECT 'VersionControl' UNION ALL
SELECT 'XmlDataExtract' UNION ALL
SELECT 'YearEnd' UNION ALL
SELECT 'YearEndLog' UNION ALL
SELECT 'YearEndOpenTrans' UNION ALL
SELECT 'YEExport' UNION ALL
SELECT 'SalInvReasonList' UNION ALL
SELECT 'SalesForceLevel' UNION ALL
SELECT 'SalesForce' UNION ALL
SELECT 'Report_Template_GST' UNION ALL 
SELECT 'ManualConfiguration' 
GO
INSERT INTO DataPurge_TransactionTable(DataPurgTransTable)
SELECT 'ApportionSchemeDetails' UNION ALL 
SELECT 'AutoRaisedCreditDebit' UNION ALL 
SELECT 'AvgCrAmtDate' UNION ALL 
SELECT 'BatchTransfer' UNION ALL 
SELECT 'BatchTransferClaim' UNION ALL 
SELECT 'BillAppliedSchemeHd' UNION ALL 
SELECT 'BillAppliedSchemeHdUnDelivered' UNION ALL 
SELECT 'BilledOrderPrdGRNTrack' UNION ALL 
SELECT 'BilledPrdDtCalculatedTax' UNION ALL 
SELECT 'BilledPrdDtForTax' UNION ALL 
SELECT 'BilledPrdGRNTrack' UNION ALL 
SELECT 'BilledPrdHdForPayOut' UNION ALL 
SELECT 'BilledPrdHdForQPSScheme' UNION ALL 
SELECT 'BilledPrdHdForQPSSchemeUnDelivered' UNION ALL 
SELECT 'BilledPrdHdForScheme' UNION ALL 
SELECT 'BilledPrdHdForSchemeUnDelivered' UNION ALL 
SELECT 'BilledPrdHdForTax' UNION ALL 
SELECT 'BilledPrdHdForTax_GST' UNION ALL 
SELECT 'BilledPrdRedeemedForQPS' UNION ALL 
SELECT 'BillHdForPayOut' UNION ALL 
SELECT 'BillPrintMsg' UNION ALL 
SELECT 'BillPrintReturnTaxTemp' UNION ALL 
SELECT 'BillPrintTaxTemp' UNION ALL 
SELECT 'BillQPSGivenFlat' UNION ALL 
SELECT 'BillQPSSchemeAdj' UNION ALL 
SELECT 'BillSplitUpProducts' UNION ALL 
SELECT 'BLCmpBatCode' UNION ALL 
SELECT 'BLTempStockLedSummary' UNION ALL 
SELECT 'BudgetUtilizedWithOutPrimary' UNION ALL 
SELECT 'CategoryApproval' UNION ALL 
SELECT 'ChequeDisbursalDetails' UNION ALL 
SELECT 'ChequeDisbursalMaster' UNION ALL 
SELECT 'ChequeInventoryRtr' UNION ALL 
SELECT 'ChequeInventoryRtrDt' UNION ALL 
SELECT 'ChequeInventorySupp' UNION ALL 
SELECT 'ChequeInventorySuppDt' UNION ALL 
SELECT 'ChequePayment' UNION ALL 
SELECT 'ClaimDebitCreditNote' UNION ALL 
SELECT 'ClaimDisclaimer' UNION ALL 
SELECT 'ClaimFreePrdSettlement' UNION ALL 
SELECT 'ClaimGroupDisplayClaim' UNION ALL 
SELECT 'ClaimGroupRDClaim' UNION ALL 
SELECT 'ClaimGroupSalvageClaim' UNION ALL 
SELECT 'ClaimGroupSchemeDiscount' UNION ALL 
SELECT 'ClaimGroupSpecialDiscount' UNION ALL 
SELECT 'ClaimGroupToAvoid' UNION ALL 
SELECT 'ClaimNSheetHd' UNION ALL 
SELECT 'ClaimSettlement' UNION ALL 
SELECT 'ClaimSettlementDt' UNION ALL 
SELECT 'ClaimSheetDetail' UNION ALL 
SELECT 'ClaimSheetDisplayClaim' UNION ALL 
SELECT 'ClaimSheetHD' UNION ALL 
SELECT 'ClaimSheetInvoiceWiseDetails' UNION ALL 
SELECT 'ClaimSheetRDClaim' UNION ALL 
SELECT 'ClaimSheetSalvageClaim' UNION ALL 
SELECT 'ClaimSheetSchemeDiscount' UNION ALL 
SELECT 'ClaimSheetSpecialDiscount' UNION ALL 
SELECT 'CN2CS_BillPrintMsgDetails' UNION ALL 
SELECT 'CN2CS_BillPrintMsgHeader' UNION ALL 
SELECT 'Cn2Cs_CategoryApproval' UNION ALL 
SELECT 'CN2CS_PDAPrdCategoryValue' UNION ALL 
SELECT 'Cn2Cs_Prk_ActiveSKU' UNION ALL 
SELECT 'Cn2Cs_Prk_BarCode' UNION ALL 
SELECT 'Cn2CS_Prk_BillSeriesDtUpdationGST' UNION ALL 
SELECT 'Cn2Cs_Prk_BLProduct' UNION ALL 
SELECT 'Cn2Cs_Prk_BLProductBatch' UNION ALL 
SELECT 'Cn2Cs_Prk_BLProductHiereachyChange' UNION ALL 
SELECT 'Cn2Cs_Prk_BLPurchaseOrder' UNION ALL 
SELECT 'Cn2Cs_Prk_BLPurchaseReceipt' UNION ALL 
SELECT 'Cn2Cs_Prk_BLRetailerCategoryLevel' UNION ALL 
SELECT 'Cn2Cs_Prk_BLRetailerCategoryLevelValue' UNION ALL 
SELECT 'Cn2Cs_Prk_BLRetailerValueClass' UNION ALL 
SELECT 'Cn2Cs_Prk_BLUOM' UNION ALL 
SELECT 'Cn2Cs_Prk_BulletinBoard' UNION ALL 
SELECT 'Cn2Cs_Prk_BulletingBoard' UNION ALL 
SELECT 'Cn2Cs_Prk_ClaimFreePrdSettlement' UNION ALL 
SELECT 'Cn2Cs_Prk_ClaimNorm' UNION ALL 
SELECT 'Cn2Cs_Prk_ClaimSettlement' UNION ALL 
SELECT 'Cn2Cs_Prk_ClaimSettlementDetails' UNION ALL 
SELECT 'Cn2Cs_Prk_ClassInfo' UNION ALL 
SELECT 'Cn2Cs_Prk_ClusterAssignApproval' UNION ALL 
SELECT 'Cn2Cs_Prk_ClusterGroup' UNION ALL 
SELECT 'Cn2Cs_Prk_ClusterMaster' UNION ALL 
SELECT 'Cn2CS_Prk_CompanyCountersUpdationGST' UNION ALL 
SELECT 'Cn2Cs_Prk_Configuration' UNION ALL 
SELECT 'Cn2Cs_Prk_ContractPricing' UNION ALL 
SELECT 'Cn2CS_Prk_CountersUpdationGST' UNION ALL 
SELECT 'Cn2Cs_Prk_DamageClaimStatus' UNION ALL 
SELECT 'Cn2Cs_Prk_DayNorm' UNION ALL 
SELECT 'CN2CS_Prk_DHCSettings' UNION ALL 
SELECT 'Cn2Cs_Prk_DistributorInfo' UNION ALL 
SELECT 'Cn2Cs_Prk_DistributorType' UNION ALL 
SELECT 'Cn2Cs_Prk_ERPPrdCCodeMapping' UNION ALL 
SELECT 'Cn2Cs_Prk_FixedNorm' UNION ALL 
SELECT 'Cn2Cs_Prk_FocusBrand' UNION ALL 
SELECT 'Cn2Cs_Prk_GCScoreCard' UNION ALL 
SELECT 'Cn2Cs_Prk_GCTarget' UNION ALL 
SELECT 'Cn2Cs_Prk_GroupInfo' UNION ALL 
SELECT 'Cn2Cs_Prk_GSECScoreCard' UNION ALL 
SELECT 'Cn2Cs_Prk_GSTConfiguration' UNION ALL 
SELECT 'Cn2Cs_Prk_HierarchyLevel' UNION ALL 
SELECT 'Cn2Cs_Prk_HierarchyLevelValue' UNION ALL 
SELECT 'Cn2Cs_Prk_HotFixLog' UNION ALL 
SELECT 'Cn2Cs_Prk_LoyaltyHeader' UNION ALL 
SELECT 'Cn2Cs_Prk_LoyaltyProduct' UNION ALL 
SELECT 'Cn2Cs_Prk_LoyaltyRetailer' UNION ALL 
SELECT 'Cn2Cs_Prk_LoyaltyScheme' UNION ALL 
SELECT 'Cn2Cs_Prk_MasterApproval' UNION ALL 
SELECT 'CN2CS_Prk_Masteruserrestriction' UNION ALL 
SELECT 'CN2CS_Prk_Masteruserrestriction_Archive' UNION ALL 
SELECT 'Cn2Cs_Prk_MigratedRetailer' UNION ALL 
SELECT 'Cn2Cs_Prk_MigratedRetailer_CrNote' UNION ALL 
SELECT 'CN2CS_Prk_MigratedRoute' UNION ALL 
SELECT 'Cn2Cs_Prk_MSLNeilsonPayOut' UNION ALL 
SELECT 'Cn2Cs_Prk_NESProductBatch' UNION ALL 
SELECT 'Cn2Cs_Prk_NesPurchaseReceipt' UNION ALL 
SELECT 'Cn2Cs_Prk_NSPriceApproval' UNION ALL 
SELECT 'Cn2Cs_Prk_NSVPrice' UNION ALL 
SELECT 'Cn2Cs_Prk_NVFundSettlement' UNION ALL 
SELECT 'Cn2Cs_Prk_NVPriceDifference' UNION ALL 
SELECT 'Cn2Cs_Prk_NVSalesInvoice' UNION ALL 
SELECT 'Cn2Cs_Prk_NVSalesInvoiceScheme' UNION ALL 
SELECT 'Cn2Cs_Prk_NVSalesInvoiceSequence' UNION ALL 
SELECT 'Cn2Cs_Prk_NVSchemeMasterControl' UNION ALL 
SELECT 'Cn2Cs_Prk_NVSSClaimSettlement' UNION ALL 
SELECT 'Cn2Cs_Prk_NVSSRetailer' UNION ALL 
SELECT 'Cn2Cs_Prk_NVSubStkClaimSettlement' UNION ALL 
SELECT 'Cn2Cs_Prk_OrderNotGiven' UNION ALL 
SELECT 'Cn2Cs_Prk_Parivarscorecard' UNION ALL 
SELECT 'Cn2Cs_Prk_PayoutProducts' UNION ALL 
SELECT 'Cn2Cs_Prk_POIndex' UNION ALL 
SELECT 'Cn2Cs_Prk_PointsRulesHeader' UNION ALL 
SELECT 'Cn2Cs_Prk_PointsRulesProduct' UNION ALL 
SELECT 'Cn2Cs_Prk_PointsRulesRetailer' UNION ALL 
SELECT 'Cn2Cs_Prk_PointsRulesSlab' UNION ALL 
SELECT 'Cn2Cs_Prk_PrefixMaster' UNION ALL 
SELECT 'Cn2Cs_Prk_Product' UNION ALL 
SELECT 'Cn2Cs_Prk_ProductBatch' UNION ALL 
SELECT 'Cn2Cs_Prk_ProductBatch_Archive' UNION ALL 
SELECT 'Cn2Cs_Prk_ProductClaimNorm' UNION ALL 
SELECT 'Cn2Cs_Prk_ProductHSNCode' UNION ALL 
SELECT 'Cn2Cs_Prk_ProductSplRate' UNION ALL 
SELECT 'Cn2Cs_Prk_ProfessionalDistPrdCtg' UNION ALL 
SELECT 'Cn2CS_Prk_PurchaseinvSeriesDtGST' UNION ALL 
SELECT 'Cn2Cs_Prk_PurchaseReceipt' UNION ALL 
SELECT 'Cn2Cs_Prk_PurchaseReceiptAdjustments' UNION ALL 
SELECT 'Cn2Cs_Prk_PurchaseReceiptMapping' UNION ALL 
SELECT 'Cn2Cs_Prk_PurchaseReturn' UNION ALL 
SELECT 'Cn2Cs_Prk_PurchaseReturnApproval' UNION ALL 
SELECT 'Cn2Cs_Prk_ReasonMaster' UNION ALL 
SELECT 'CN2CS_Prk_Retailer_QPSFreeProductUpdation' UNION ALL 
SELECT 'CN2CS_Prk_Retailer_QPSLineWiseUpdation' UNION ALL 
SELECT 'CN2CS_Prk_Retailer_QPSUpdation' UNION ALL 
SELECT 'Cn2Cs_Prk_RetailerApproval' UNION ALL 
SELECT 'Cn2Cs_Prk_RetailerCategory' UNION ALL 
SELECT 'Cn2Cs_Prk_RetailerGST' UNION ALL 
SELECT 'Cn2Cs_Prk_RetailerMigration' UNION ALL 
SELECT 'CN2CS_Prk_RetailerUDCMigration' UNION ALL 
SELECT 'Cn2Cs_Prk_RetailerUDCUpdation' UNION ALL 
SELECT 'Cn2Cs_Prk_Reupload' UNION ALL 
SELECT 'Cn2Cs_Prk_RouteDay' UNION ALL 
SELECT 'Cn2Cs_Prk_RtrMultiRouteAssign' UNION ALL 
SELECT 'Cn2Cs_Prk_RtrOtherThanGCClaim' UNION ALL 
SELECT 'Cn2Cs_Prk_RtrPrefix' UNION ALL 
SELECT 'Cn2Cs_Prk_SalesDataMismatch' UNION ALL 
SELECT 'Cn2Cs_Prk_SalesDataMismatch_Track' UNION ALL 
SELECT 'Cn2Cs_Prk_SaralClaim' UNION ALL 
SELECT 'Cn2CS_Prk_SchemeHD' UNION ALL 
SELECT 'Cn2Cs_Prk_SchemePayout' UNION ALL 
SELECT 'Cn2CS_Prk_SchemeProducts' UNION ALL 
SELECT 'Cn2CS_Prk_SchemeRetAttr' UNION ALL 
SELECT 'Cn2CS_Prk_SchemeSlabs' UNION ALL 
SELECT 'Cn2Cs_Prk_ServiceClaimGroup' UNION ALL 
SELECT 'Cn2Cs_Prk_ServiceMaster' UNION ALL 
SELECT 'Cn2Cs_Prk_ServiceTaxSetting' UNION ALL 
SELECT 'Cn2Cs_Prk_SFACollectionDET' UNION ALL 
SELECT 'Cn2Cs_Prk_SFACollectionHD' UNION ALL 
SELECT 'Cn2Cs_Prk_SFAOrderCouponDET' UNION ALL 
SELECT 'Cn2Cs_Prk_SFAOrderCouponDET_BackUp' UNION ALL 
SELECT 'Cn2Cs_Prk_SFAOrderDET' UNION ALL 
SELECT 'Cn2Cs_Prk_SFAOrderDET_BackUp' UNION ALL 
SELECT 'Cn2Cs_Prk_SFAOrderHD' UNION ALL 
SELECT 'Cn2Cs_Prk_SFAOrderHD_BackUp' UNION ALL 
SELECT 'Cn2Cs_Prk_SFAOrderLuckydraw' UNION ALL 
SELECT 'Cn2Cs_Prk_SFAOrderLuckydraw_BackUp' UNION ALL 
SELECT 'Cn2Cs_Prk_SFARetailer' UNION ALL 
SELECT 'Cn2Cs_Prk_SFARetailerPhNo' UNION ALL 
SELECT 'Cn2Cs_Prk_SFASalesReturnDET' UNION ALL 
SELECT 'Cn2Cs_Prk_SFASalesReturnHD' UNION ALL 
SELECT 'Cn2Cs_Prk_SMProduct' UNION ALL 
SELECT 'Cn2Cs_Prk_SpecialDiscount' UNION ALL 
SELECT 'Cn2Cs_Prk_SpecialRate' UNION ALL 
SELECT 'Cn2Cs_Prk_SplitUpProducts' UNION ALL 
SELECT 'Cn2Cs_Prk_StateMaster' UNION ALL 
SELECT 'Cn2Cs_Prk_SubStkClaimDetails' UNION ALL 
SELECT 'Cn2Cs_Prk_SubStkClaimSettlementDetails' UNION ALL 
SELECT 'Cn2Cs_Prk_SupplierMaster' UNION ALL 
SELECT 'Cn2Cs_Prk_SyncVersion' UNION ALL 
SELECT 'Cn2Cs_Prk_UDCDefaults' UNION ALL 
SELECT 'Cn2Cs_Prk_UDCDetails' UNION ALL 
SELECT 'Cn2Cs_Prk_UDCMaster' UNION ALL 
SELECT 'Cn2Cs_Prk_UpdaterLog' UNION ALL 
SELECT 'CN2CS_Prk_URCForExistingOutlet' UNION ALL 
SELECT 'Cn2Cs_Prk_VillageMaster' UNION ALL 
SELECT 'Cn2Cs_Prk_WDSBudgetValues' UNION ALL 
SELECT 'CN2CS_RtrAttributeChange' UNION ALL 
SELECT 'CnCs_CategoryApproval' UNION ALL 
SELECT 'CollectionDiscount' UNION ALL 
SELECT 'CollectionDiscountDetails' UNION ALL 
SELECT 'Console_OrderNotGiven' UNION ALL 
SELECT 'ConsolidateStockLedger' UNION ALL 
SELECT 'ConsolidateVocWithOutRetailer' UNION ALL 
SELECT 'ConsolidateVocWithRetailer' UNION ALL 
SELECT 'CouponSchemeApplicable' UNION ALL 
SELECT 'CRConvSchemeDt' UNION ALL 
SELECT 'CRDBAdjustment' UNION ALL 
SELECT 'CRDBAdjustmentDt' UNION ALL 
SELECT 'CRDBNoteAdjustment' UNION ALL 
SELECT 'CRDBNotePayAdjustment' UNION ALL 
SELECT 'CrDbNoteTaxBreakUp' UNION ALL 
SELECT 'CrDbt' UNION ALL 
SELECT 'CreditCheckOrderCategory' UNION ALL 
SELECT 'CreditCheckOrderProductDt' UNION ALL 
SELECT 'CreditNoteReplacementDT' UNION ALL 
SELECT 'CreditNoteReplacementHD' UNION ALL 
SELECT 'CreditNoteRetailer' UNION ALL 
SELECT 'CreditNoteRetailerForBilling' UNION ALL 
SELECT 'CreditNotesExtractExcel' UNION ALL 
SELECT 'CreditNoteSupplier' UNION ALL 
SELECT 'CRNoteConvSchRtr' UNION ALL 
SELECT 'CRNoteConvSchRtrAch' UNION ALL 
SELECT 'Cs2Cn_BillPrintMsg' UNION ALL 
SELECT 'CS2CN_CouponMaster' UNION ALL 
SELECT 'Cs2Cn_DBDetailsUpload' UNION ALL 
SELECT 'CS2CN_DiscountApproval' UNION ALL 
SELECT 'CS2CN_DiscountApproval_Rtr' UNION ALL 
SELECT 'CS2CN_PDADetails' UNION ALL 
SELECT 'Cs2Cn_Prk_AttendanceRegister' UNION ALL 
SELECT 'Cs2Cn_Prk_AttendanceRegister_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_Bank' UNION ALL 
SELECT 'Cs2Cn_Prk_BillSeriesDtGST' UNION ALL 
SELECT 'Cs2Cn_Prk_BillToPurchase' UNION ALL 
SELECT 'Cs2Cn_Prk_BusinessSnapShot' UNION ALL 
SELECT 'Cs2Cn_Prk_Claim_SchemeDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_ClaimAll' UNION ALL 
SELECT 'Cs2Cn_Prk_ClaimAll_Archive' UNION ALL 
SELECT 'CS2CN_Prk_ClaimSheetInvoiceWiseDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_ClusterAssign' UNION ALL 
SELECT 'Cs2Cn_Prk_CollectionReg' UNION ALL 
SELECT 'Cs2Cn_Prk_CollectionRegDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_CompanyCountersGST' UNION ALL 
SELECT 'Cs2Cn_Prk_CountersGST' UNION ALL 
SELECT 'Cs2Cn_Prk_CouponCreditNote' UNION ALL 
SELECT 'Cs2Cn_Prk_CouponRedemptionDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_CurrentStock' UNION ALL 
SELECT 'Cs2Cn_Prk_DailyBusinessDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_DailyBusinessDetails_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_DailyProductDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_DailyRetailerDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_DailySales' UNION ALL 
SELECT 'Cs2Cn_Prk_DailySales_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_DailySales_GCPL_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_DailySales_Undelivered' UNION ALL 
SELECT 'Cs2Cn_Prk_DamageClaim' UNION ALL 
SELECT 'Cs2Cn_Prk_DayEndProcess' UNION ALL 
SELECT 'Cs2Cn_Prk_DBDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_DBDetails_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_DBUnlockDetails' UNION ALL 
SELECT 'CS2CN_Prk_DHCDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_DistributorOrder' UNION ALL 
SELECT 'Cs2Cn_Prk_DownloadedDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_DownLoadTracing' UNION ALL 
SELECT 'Cs2Cn_Prk_DownLoadTracing_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_Dummy' UNION ALL 
SELECT 'Cs2Cn_Prk_Dummy_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_FBMTrack' UNION ALL 
SELECT 'Cs2Cn_Prk_FBMTrack_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_GSTAcknowledge' UNION ALL 
SELECT 'Cs2Cn_Prk_GSTBillsPrice' UNION ALL 
SELECT 'Cs2Cn_Prk_InputOutPutGSTTax' UNION ALL 
SELECT 'Cs2Cn_Prk_InputTaxCreditReport' UNION ALL 
SELECT 'Cs2Cn_Prk_IntegrationHouseKeeping' UNION ALL 
SELECT 'Cs2Cn_Prk_LuckyDrawCouponDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_MastersCount' UNION ALL 
SELECT 'CS2CN_Prk_MonthEnd' UNION ALL 
SELECT 'CS2CN_Prk_MonthEnd_Arch' UNION ALL 
SELECT 'Cs2Cn_Prk_NSVPriceUpload' UNION ALL 
SELECT 'Cs2Cn_Prk_OrderBooking' UNION ALL 
SELECT 'Cs2Cn_Prk_OrderBooking_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_OtherThanGCClaims' UNION ALL 
SELECT 'Cs2Cn_Prk_PayOutUpload' UNION ALL 
SELECT 'Cs2Cn_Prk_PendingCreditNote' UNION ALL 
SELECT 'Cs2Cn_Prk_PONormDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_ProductWiseStock' UNION ALL 
SELECT 'Cs2Cn_Prk_PurchaseConfirmation' UNION ALL 
SELECT 'Cs2Cn_Prk_PurchaseConfirmation_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_PurchaseinvSeriesDtGST' UNION ALL 
SELECT 'Cs2Cn_Prk_PurchaseOrder' UNION ALL 
SELECT 'Cs2Cn_Prk_PurchaseReturn' UNION ALL 
SELECT 'Cs2Cn_Prk_PurchaseReturn_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_QPSAchRetailers' UNION ALL 
SELECT 'Cs2Cn_Prk_QPSCreditNote' UNION ALL 
SELECT 'Cs2Cn_Prk_QPSCRNUtilized' UNION ALL 
SELECT 'Cs2Cn_Prk_RDSMWorkingEfficiency' UNION ALL 
SELECT 'Cs2Cn_Prk_Retailer' UNION ALL 
SELECT 'Cs2Cn_Prk_Retailer_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_Retailer_QPSFreeProductMigration' UNION ALL 
SELECT 'Cs2Cn_Prk_Retailer_QPSLineWiseMigration' UNION ALL 
SELECT 'Cs2Cn_Prk_Retailer_QPSMigration' UNION ALL 
SELECT 'Cs2Cn_Prk_Retailer_Unapproved' UNION ALL 
SELECT 'Cs2Cn_Prk_RetailerAlias' UNION ALL 
SELECT 'Cs2Cn_Prk_RetailerAliasBilling' UNION ALL 
SELECT 'Cs2Cn_Prk_RetailerClassShift' UNION ALL 
SELECT 'Cs2Cn_Prk_RetailerClassShift_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_RetailerRoute' UNION ALL 
SELECT 'Cs2Cn_Prk_RetailerRoute_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_RetailerShipAddress' UNION ALL 
SELECT 'Cs2Cn_Prk_ReUploadInitiate' UNION ALL 
SELECT 'Cs2Cn_Prk_Route' UNION ALL 
SELECT 'Cs2Cn_Prk_Route_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_Route_Unapproved' UNION ALL 
SELECT 'Cs2Cn_Prk_RouteCoveragePlan' UNION ALL 
SELECT 'Cs2Cn_Prk_RouteCoveragePlan_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_RouteVillage' UNION ALL 
SELECT 'Cs2Cn_Prk_RouteVillage_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_SalesInvoiceOrders' UNION ALL 
SELECT 'Cs2Cn_Prk_SalesInvoiceOrders_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_Salesman' UNION ALL 
SELECT 'Cs2Cn_Prk_Salesman_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_Salesman_Unapproved' UNION ALL 
SELECT 'Cs2Cn_Prk_SalesReturn' UNION ALL 
SELECT 'Cs2Cn_Prk_SalesReturn_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_SampleIssue' UNION ALL 
SELECT 'Cs2Cn_Prk_SampleIssue_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_SampleReceipt' UNION ALL 
SELECT 'Cs2Cn_Prk_SampleReceipt_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_SampleReturn' UNION ALL 
SELECT 'Cs2Cn_Prk_SampleReturn_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_SchemeDifference' UNION ALL 
SELECT 'Cs2Cn_Prk_SchemeTrack' UNION ALL 
SELECT 'Cs2Cn_Prk_SchemeUtilization' UNION ALL 
SELECT 'Cs2Cn_Prk_SchemeUtilization_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_SchemeUtilizationDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_SchemeUtilizationDetails_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_ServiceInvoice' UNION ALL 
SELECT 'Cs2Cn_Prk_Stock' UNION ALL 
SELECT 'Cs2Cn_Prk_Stock_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_Stock_GCPL_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_SyncDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_SystemInfo' UNION ALL 
SELECT 'Cs2Cn_Prk_TaxTrace' UNION ALL 
SELECT 'Cs2Cn_Prk_TransactionWiseGrnTracking' UNION ALL 
SELECT 'CS2CN_Prk_TransactionWiseSerialNo' UNION ALL 
SELECT 'CS2CN_Prk_TransactionWiseSerialNo_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_UDCDetails' UNION ALL 
SELECT 'Cs2Cn_Prk_UDCDetails_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_UploadRecordCheck' UNION ALL 
SELECT 'Cs2Cn_Prk_UpLoadTracing' UNION ALL 
SELECT 'Cs2Cn_Prk_UpLoadTracing_Archive' UNION ALL 
SELECT 'Cs2Cn_Prk_WinDispCreditNote' UNION ALL 
SELECT 'Cs2Cn_Prk_WinDispCRNUtilized' UNION ALL 
SELECT 'CS2CN_QPSDataBasedCrNoteTrack' UNION ALL 
SELECT 'CS2CN_QPSDataBasedCrNoteTrack_Archive' UNION ALL 
SELECT 'Cs2Cn_ReturnTaxuploadGST' UNION ALL 
SELECT 'CS2CN_RtrSalesDetails' UNION ALL 
SELECT 'Cs2Cn_SalesTaxuploadGST' UNION ALL 
SELECT 'CS2Console_Consolidated' UNION ALL 
SELECT 'CS2Console_DownLoadTracing' UNION ALL 
SELECT 'CS2Console_UpLoadTracing' UNION ALL 
SELECT 'CSTimer' UNION ALL 
SELECT 'CSTimerHistory' UNION ALL 
SELECT 'CurrentDB' UNION ALL 
SELECT 'CurrentStockExtractExcel' UNION ALL  
SELECT 'CutOffHistory' UNION ALL 
SELECT 'CutOffOrders' UNION ALL 
SELECT 'CutOfftempReOrder' UNION ALL 
SELECT 'CutOffTempTbl' UNION ALL 
SELECT 'DamageClaimDetail' UNION ALL 
SELECT 'DamageClaimHD' UNION ALL 
SELECT 'DamageClaimRef' UNION ALL 
SELECT 'DamageClaimStatus' UNION ALL 
SELECT 'DashBoardBusinessDt' UNION ALL 
SELECT 'DashBoardBusinessPendingDT' UNION ALL 
SELECT 'DashBoardClosingDt' UNION ALL 
SELECT 'DashBoardHD' UNION ALL 
SELECT 'DashBoardInventoryDT' UNION ALL 
SELECT 'DashBoardPendingDt' UNION ALL 
SELECT 'DashBoardPendingDtSM' UNION ALL 
SELECT 'DashBoardSchemeDT' UNION ALL 
SELECT 'DashBoardSMColumn' UNION ALL 
SELECT 'DataPurge_DeleteTransactionSourceDB' UNION ALL 
SELECT 'DataPurge_TransactionProcess' UNION ALL 
SELECT 'DataPurge_TransactionTable' UNION ALL 
SELECT 'DataPurgeDetails' UNION ALL 
SELECT 'DebitInvoice' UNION ALL 
SELECT 'DebitNoteRetailer' UNION ALL 
SELECT 'DebitNotesExtractExcel' UNION ALL 
SELECT 'DebitNoteSupplier' UNION ALL 
SELECT 'DeliveryBoyClaimDetails' UNION ALL 
SELECT 'DeliveryBoyClaimMaster' UNION ALL 
SELECT 'DesignCodeSkuMapping' UNION ALL 
SELECT 'DesignCodeSkuMappingHistory' UNION ALL 
SELECT 'DtBasedQPSSchRtrDetails' UNION ALL 
SELECT 'ETL_CS2CNSalvageCreditNote' UNION ALL 
SELECT 'ETL_Prk_AccountCalender' UNION ALL 
SELECT 'ETL_Prk_ACStatment' UNION ALL 
SELECT 'ETL_Prk_Bank' UNION ALL 
SELECT 'ETL_Prk_BankBranch' UNION ALL 
SELECT 'ETL_Prk_BatchCreation' UNION ALL 
SELECT 'ETL_Prk_BLClaimSettlement' UNION ALL 
SELECT 'ETL_Prk_BLContractPricing' UNION ALL 
SELECT 'ETL_Prk_BLDailySales' UNION ALL 
SELECT 'ETL_Prk_BLJCCalendar' UNION ALL 
SELECT 'ETL_Prk_ChequeBounce' UNION ALL 
SELECT 'ETL_Prk_ChequeInvRetailer' UNION ALL 
SELECT 'ETL_Prk_ChequeInvSupplier' UNION ALL 
SELECT 'ETL_Prk_CN2CS_UdcDetails' UNION ALL 
SELECT 'ETL_Prk_CN2CSSchemeApproval' UNION ALL 
SELECT 'ETL_Prk_CN2CSSiteCode' UNION ALL 
SELECT 'ETL_Prk_COAMaster' UNION ALL 
SELECT 'ETL_Prk_Company' UNION ALL 
SELECT 'ETL_Prk_ContractPricing' UNION ALL 
SELECT 'ETL_Prk_CreditNoteRetailer' UNION ALL 
SELECT 'ETL_Prk_CreditNoteSupplier' UNION ALL 
SELECT 'Etl_Prk_Cs2Cn_BackUpLog' UNION ALL 
SELECT 'ETL_Prk_CS2CNBLPurchaseConfirmation' UNION ALL 
SELECT 'ETL_Prk_CS2CNBLRetailer' UNION ALL 
SELECT 'ETL_Prk_CS2CNBLSalesReturn' UNION ALL 
SELECT 'ETL_Prk_CS2CNClaimAll' UNION ALL 
SELECT 'ETL_Prk_CS2CNCollectionDetails' UNION ALL 
SELECT 'ETL_Prk_CS2CNDownLoadTracing' UNION ALL 
SELECT 'ETL_Prk_CS2CNNSPriceApproved' UNION ALL 
SELECT 'ETL_Prk_CS2CNNVFundManagement' UNION ALL 
SELECT 'ETL_Prk_CS2CNNVSalesInvoice' UNION ALL 
SELECT 'ETL_Prk_CS2CNNVSalesInvoiceScheme' UNION ALL 
SELECT 'ETL_Prk_CS2CNNVSalesInvoiceSequence' UNION ALL 
SELECT 'ETL_Prk_CS2CNNVSubStkClaimSettlement' UNION ALL 
SELECT 'ETL_Prk_CS2CNPOQuantitySplitUp' UNION ALL 
SELECT 'ETL_Prk_CS2CNPurchaseConfirmation' UNION ALL 
SELECT 'ETL_Prk_CS2CNPurchaseConfirmation_TempId1' UNION ALL 
SELECT 'ETL_Prk_CS2CNPurchaseConfirmation_TempId2' UNION ALL 
SELECT 'ETL_Prk_CS2CNPurchaseOrder' UNION ALL 
SELECT 'ETL_Prk_CS2CNRetailer' UNION ALL 
SELECT 'ETL_Prk_CS2CNRetailer_TempId1' UNION ALL 
SELECT 'ETL_Prk_CS2CNRetailer_TempId2' UNION ALL 
SELECT 'ETL_Prk_CS2CNSchemeApproval' UNION ALL 
SELECT 'ETL_Prk_CS2CNSyncProcess' UNION ALL 
SELECT 'ETL_Prk_CS2CNTargetAnalysis' UNION ALL 
SELECT 'ETL_Prk_CS2CNUpLoadTracing' UNION ALL 
SELECT 'ETL_Prk_DebitNoteRetailer' UNION ALL 
SELECT 'ETL_Prk_DebitNoteSupplier' UNION ALL 
SELECT 'ETL_Prk_DeliveryBoy' UNION ALL 
SELECT 'Etl_Prk_DiscountApproval' UNION ALL 
SELECT 'ETL_Prk_GeographyHierarchyLevel' UNION ALL 
SELECT 'ETL_Prk_GeographyHierarchyLevelValue' UNION ALL 
SELECT 'ETL_Prk_ImportClaimSheetSpentReceived' UNION ALL 
SELECT 'ETL_Prk_INTegrationHouseKeeping' UNION ALL 
SELECT 'ETL_Prk_JcHeader' UNION ALL 
SELECT 'ETL_Prk_JcHoliday' UNION ALL 
SELECT 'ETL_Prk_JcMonth' UNION ALL 
SELECT 'ETL_Prk_JcWeek' UNION ALL 
SELECT 'Etl_Prk_KeyGroup' UNION ALL 
SELECT 'ETL_Prk_Location' UNION ALL 
SELECT 'ETL_Prk_NES_PurchaseReceiptPrdDt' UNION ALL 
SELECT 'ETL_Prk_OpeningBalance' UNION ALL 
SELECT 'ETL_PRK_OrderBooking' UNION ALL 
SELECT 'ETL_Prk_PaymentDetails' UNION ALL 
SELECT 'ETL_Prk_PODetails' UNION ALL 
SELECT 'ETL_Prk_POMaster' UNION ALL 
SELECT 'ETL_Prk_PrdBatchDetails' UNION ALL 
SELECT 'ETL_PRK_PrdSalBundle' UNION ALL 
SELECT 'ETL_Prk_Product' UNION ALL 
SELECT 'ETL_Prk_ProductBatch' UNION ALL 
SELECT 'ETL_Prk_ProductBatchDetails' UNION ALL 
SELECT 'ETL_Prk_ProductHierarchyLevel' UNION ALL 
SELECT 'ETL_Prk_ProductHierarchyLevelValue' UNION ALL 
SELECT 'ETL_Prk_ProductUOMMapping' UNION ALL 
SELECT 'ETL_Prk_PurchaseReceipt' UNION ALL 
SELECT 'ETL_Prk_PurchaseReceiptClaim' UNION ALL 
SELECT 'ETL_Prk_PurchaseReceiptCrDbAdjustments' UNION ALL 
SELECT 'ETL_Prk_PurchaseReceiptOtherCharges' UNION ALL 
SELECT 'ETL_Prk_PurchaseReceiptPrdDt' UNION ALL 
SELECT 'ETL_Prk_PurchaseReceiptPrdLineDt' UNION ALL 
SELECT 'Etl_Prk_RdClaim' UNION ALL 
SELECT 'Etl_Prk_RdFrieght' UNION ALL 
SELECT 'ETL_Prk_Reason' UNION ALL 
SELECT 'ETL_Prk_Retailer' UNION ALL 
SELECT 'ETL_Prk_RetailerCategoryLevel' UNION ALL 
SELECT 'ETL_Prk_RetailerCategoryLevelValue' UNION ALL 
SELECT 'ETL_Prk_RetailerGST' UNION ALL 
SELECT 'ETL_Prk_RetailerPotentialClass' UNION ALL 
SELECT 'Etl_Prk_RetailerReassign' UNION ALL 
SELECT 'ETL_Prk_RetailerRoute' UNION ALL 
SELECT 'ETL_Prk_RetailerShippingAddress' UNION ALL 
SELECT 'ETL_Prk_RetailerStatus' UNION ALL 
SELECT 'ETL_Prk_RetailerUDC' UNION ALL 
SELECT 'ETL_Prk_RetailerValueClass' UNION ALL 
SELECT 'ETL_Prk_RetailerValueClassMap' UNION ALL 
SELECT 'ETL_PRK_RouteCoveragePlan' UNION ALL 
SELECT 'ETL_PRK_RouteMaster' UNION ALL 
SELECT 'ETL_Prk_RouteUDC' UNION ALL 
SELECT 'ETL_PRK_RouteVillage' UNION ALL 
SELECT 'ETL_Prk_RtrSequencing' UNION ALL 
SELECT 'ETL_Prk_SalesForceLevel' UNION ALL 
SELECT 'ETL_Prk_SalesForceLevelValue' UNION ALL 
SELECT 'ETL_Prk_Salesman' UNION ALL 
SELECT 'ETL_Prk_SalesmanUDC' UNION ALL 
SELECT 'Etl_Prk_Scheme_CombiCriteria' UNION ALL 
SELECT 'Etl_Prk_Scheme_Free_Multi_Products' UNION ALL 
SELECT 'Etl_Prk_Scheme_OnAnotherPrd' UNION ALL 
SELECT 'Etl_Prk_Scheme_OnAttributes' UNION ALL 
SELECT 'Etl_Prk_Scheme_RetailerLevelValid' UNION ALL 
SELECT 'Etl_Prk_Scheme_SchemeStatus' UNION ALL 
SELECT 'Etl_Prk_SchemeAnotherPrdDt_Temp' UNION ALL 
SELECT 'Etl_Prk_SchemeAnotherPrdHd_Temp' UNION ALL 
SELECT 'ETL_Prk_SchemeAttribute' UNION ALL 
SELECT 'Etl_Prk_SchemeAttribute_Temp' UNION ALL 
SELECT 'ETL_Prk_SchemeCombiDetails' UNION ALL 
SELECT 'Etl_Prk_SchemeHD_Slabs_Rules' UNION ALL 
SELECT 'ETL_Prk_SchemeMaster' UNION ALL 
SELECT 'ETL_Prk_SchemeMaster_Temp' UNION ALL 
SELECT 'ETL_Prk_SchemeProduct' UNION ALL 
SELECT 'Etl_Prk_SchemeProduct_Temp' UNION ALL 
SELECT 'Etl_Prk_SchemeProducts_Combi' UNION ALL 
SELECT 'Etl_Prk_SchemeRtrLevelValidation_Temp' UNION ALL 
SELECT 'Etl_Prk_SchemeRuleSettings_Temp' UNION ALL 
SELECT 'Etl_Prk_SchemeSlabCombiPrds_Temp' UNION ALL 
SELECT 'ETL_Prk_SchemeSlabDetails' UNION ALL 
SELECT 'ETL_Prk_SchemeSlabFreeDt' UNION ALL 
SELECT 'Etl_Prk_SchemeSlabFrePrds_Temp' UNION ALL 
SELECT 'Etl_Prk_SchemeSlabMultiFrePrds_Temp' UNION ALL 
SELECT 'Etl_Prk_SchemeSlabs_Temp' UNION ALL 
SELECT 'ETL_Prk_SCJ_Client' UNION ALL 
SELECT 'ETL_Prk_SCJ_Sales' UNION ALL 
SELECT 'ETL_Prk_SCJ_StkInventory' UNION ALL 
SELECT 'ETL_Prk_SMProduct' UNION ALL 
SELECT 'ETL_Prk_SpecialRate' UNION ALL 
SELECT 'ETL_Prk_StockManagementType' UNION ALL 
SELECT 'ETL_Prk_StockNorm' UNION ALL 
SELECT 'ETL_Prk_StockTransfer' UNION ALL 
SELECT 'ETL_Prk_StockType' UNION ALL 
SELECT 'ETL_Prk_Supplier' UNION ALL 
SELECT 'ETL_PRK_TaxConfig' UNION ALL 
SELECT 'ETL_Prk_TaxConfig_GroupSetting' UNION ALL 
SELECT 'ETL_PRK_TaxGroup' UNION ALL 
SELECT 'ETL_Prk_TaxMapping' UNION ALL 
SELECT 'ETL_Prk_TaxMapping_GST' UNION ALL 
SELECT 'ETL_Prk_TaxSetting' UNION ALL 
SELECT 'ETL_Prk_TransactionUOMMapping' UNION ALL 
SELECT 'ETL_Prk_Transporter' UNION ALL 
SELECT 'ETL_Prk_UdcDetails' UNION ALL 
SELECT 'ETL_Prk_UDCMaster' UNION ALL 
SELECT 'ETL_Prk_UDCRetailerGST' UNION ALL 
SELECT 'ETL_Prk_UOMGroup' UNION ALL 
SELECT 'ETL_Prk_UOMMaster' UNION ALL 
SELECT 'ETL_Prk_VanLoadGuideMaster' UNION ALL 
SELECT 'ETL_Prk_VehicleCategory' UNION ALL 
SELECT 'ETL_Prk_VehicleMaintenance' UNION ALL 
SELECT 'ETL_Prk_VehicleSubsidy' UNION ALL 
SELECT 'ETL_PrkBLStkInventory' UNION ALL 
SELECT 'ETL_PrkCS2CNBidcoSchemeUtilization' UNION ALL 
SELECT 'ETL_PrkCS2CNBLSchemeUtilization' UNION ALL 
SELECT 'ETL_PrkCS2CNClaimSheet' UNION ALL 
SELECT 'ETL_PrkCS2CNDailySales' UNION ALL 
SELECT 'ETL_PrkCS2CNDailySales_TempId1' UNION ALL 
SELECT 'ETL_PrkCS2CNDailySales_TempId2' UNION ALL 
SELECT 'ETL_PrkCS2CNRouteCovPlan' UNION ALL 
SELECT 'ETL_PrkCS2CNRouteMaster' UNION ALL 
SELECT 'ETL_PrkCS2CNRSPPunchingWindow' UNION ALL 
SELECT 'ETL_PrkCS2CNSalesman' UNION ALL 
SELECT 'ETL_PrkCS2CNSalesReturn' UNION ALL 
SELECT 'ETL_PrkCS2CNSalesReturn_TempId1' UNION ALL 
SELECT 'ETL_PrkCS2CNSalesReturn_TempId2' UNION ALL 
SELECT 'ETL_PrkCS2CNSampleIssue' UNION ALL 
SELECT 'ETL_PrkCS2CNSchemeUtilization' UNION ALL 
SELECT 'ETL_PrkCS2CNSchemeUtilization_TempId1' UNION ALL 
SELECT 'ETL_PrkCS2CNSchemeUtilization_TempId2' UNION ALL 
SELECT 'ETL_PrkCS2CNStkInventory' UNION ALL 
SELECT 'ETL_PrkCS2CNStkInventory_TempId1' UNION ALL 
SELECT 'ETL_PrkCS2CNStkInventory_TempId2' UNION ALL 
SELECT 'ETL_PrkCS2CNSubStockistSalesDetail' UNION ALL 
SELECT 'ETL_PrkCS2CNSubStockistSalesMaster' UNION ALL 
SELECT 'ETL_XML_BatchCloning' UNION ALL 
SELECT 'ETL_XML_ClaimGrpMaster' UNION ALL 
SELECT 'ETL_XML_CreditNote_Sales' UNION ALL 
SELECT 'ETL_XML_CreditNotePurchase' UNION ALL 
SELECT 'ETL_XML_Customer' UNION ALL 
SELECT 'ETL_XML_DebitNote_Sales' UNION ALL 
SELECT 'ETL_XML_DebitNotePurchase' UNION ALL 
SELECT 'ETL_XML_GoodsIssue' UNION ALL 
SELECT 'ETL_XML_GoodsReceipt' UNION ALL 
SELECT 'ETL_XML_ItemMaster' UNION ALL 
SELECT 'ETL_XML_PurchaseReceipt' UNION ALL 
SELECT 'ETL_XML_PurchaseReturn' UNION ALL 
SELECT 'ETL_XML_RouteMaster' UNION ALL 
SELECT 'ETL_XML_SalesInvoice' UNION ALL 
SELECT 'ETL_XML_SalesInvoiceScheme' UNION ALL 
SELECT 'ETL_XML_SalesManMaster' UNION ALL 
SELECT 'ETL_XML_SalesPayment' UNION ALL 
SELECT 'ETL_XML_SalesPaymentCancellation' UNION ALL 
SELECT 'ETL_XML_SalesReturn' UNION ALL 
SELECT 'ETL_XML_SalesReturnScheme' UNION ALL 
SELECT 'ETL_XML_Salvage' UNION ALL 
SELECT 'ETL_XML_SchemeAttributes' UNION ALL 
SELECT 'ETL_XML_SchemeCombiPrdDt' UNION ALL 
SELECT 'ETL_XML_SchemeFreePrdDt' UNION ALL 
SELECT 'ETL_XML_SchemeMaster' UNION ALL 
SELECT 'ETL_XML_SchemeProduct' UNION ALL 
SELECT 'ETL_XML_SchemeSlab' UNION ALL 
SELECT 'ETL_XML_VanLoadUnload' UNION ALL 
SELECT 'ETL_XML_VehicleMaster' UNION ALL 
SELECT 'ETLMaster_Trace' UNION ALL 
SELECT 'ETLPrdBatchDetailsEffective' UNION ALL 
SELECT 'ETLTempNesPurchaseReceiptProduct' UNION ALL 
SELECT 'ETLTempPurchaseReceipt' UNION ALL 
SELECT 'ETLTempPurchaseReceiptClaimScheme' UNION ALL 
SELECT 'ETLTempPurchaseReceiptCrDbAdjustments' UNION ALL 
SELECT 'ETLTempPurchaseReceiptOtherCharges' UNION ALL 
SELECT 'ETLTempPurchaseReceiptPrdLineDt' UNION ALL 
SELECT 'ETLTempPurchaseReceiptProduct' UNION ALL 
SELECT 'ExcelHeaderCaption_GST' UNION ALL 
SELECT 'FBMAdjustment' UNION ALL 
SELECT 'FreeIssueDt' UNION ALL 
SELECT 'FreeIssueHd' UNION ALL 
SELECT 'FundSettlement' UNION ALL 
SELECT 'GCScoreCard' UNION ALL 
SELECT 'GCTragetDetails' UNION ALL 
SELECT 'GSECScoreCard' UNION ALL 
SELECT 'GSSTMonthEndDetails' UNION ALL 
SELECT 'IDTBillPrint' UNION ALL 
SELECT 'IDTManagement' UNION ALL 
SELECT 'IDTManagementLineAmount' UNION ALL 
SELECT 'IDTManagementProduct' UNION ALL 
SELECT 'IDTManagementProductTax' UNION ALL 
SELECT 'IDTMaster' UNION ALL 
SELECT 'IDTReceipt' UNION ALL 
SELECT 'IDTReceiptInvoice' UNION ALL 
SELECT 'IDTReceiptInvoiceDetails' UNION ALL 
SELECT 'ImportPDA_NewRetailer' UNION ALL 
SELECT 'InvoicePrdDtCalculatedTax' UNION ALL 
SELECT 'InvoicePrdDtForTax' UNION ALL 
SELECT 'InvoicePrdHdForTax' UNION ALL 
SELECT 'InvToAvoid' UNION ALL 
SELECT 'IRAMaster' UNION ALL 
SELECT 'L3MSalesQty' UNION ALL 
SELECT 'L3MSalesQtyPriority' UNION ALL 
SELECT 'LocationTransferDetails' UNION ALL 
SELECT 'LocationTransferMaster' UNION ALL 
SELECT 'LuckyDrawCouponSchemeApplicable' UNION ALL 
SELECT 'MakeOverSold' UNION ALL 
SELECT 'ManualAllocationModified' UNION ALL 
SELECT 'ManualAllocationProduct' UNION ALL 
SELECT 'ManualClaimDetails' UNION ALL 
SELECT 'ManualClaimMaster' UNION ALL 
SELECT 'MMSDetails' UNION ALL 
SELECT 'MMSDetailsInHotSearch' UNION ALL 
SELECT 'MMSDetailsInHotSearchBackUp' UNION ALL 
SELECT 'MMSDetailsInSearch' UNION ALL 
SELECT 'MMSOrder' UNION ALL 
SELECT 'MMSOrderDetails' UNION ALL 
SELECT 'MMSOrderSalesman' UNION ALL 
SELECT 'MMSOrderSearchDetails' UNION ALL 
SELECT 'MMSOrderTracker' UNION ALL 
SELECT 'MMSOrderTrackerErrorlog' UNION ALL 
SELECT 'MTOrdertoBillingProducts' UNION ALL 
SELECT 'MultiUserSelectionValidation' UNION ALL 
SELECT 'OrderBooking' UNION ALL 
SELECT 'OrderBookingCategoryLevel' UNION ALL 
SELECT 'OrderBookingCouponDetails' UNION ALL 
SELECT 'OrderBookingHeader' UNION ALL 
SELECT 'OrderBookingProducts' UNION ALL 
SELECT 'OrderBookingShowStock' UNION ALL 
SELECT 'OrderBookingTax' UNION ALL 
SELECT 'OrderProducts' UNION ALL 
SELECT 'OrdersInSummary' UNION ALL 
SELECT 'OrdersInSummaryInHF442' UNION ALL 
SELECT 'OrderStock_Colour' UNION ALL 
SELECT 'OrderStock_Product' UNION ALL 
SELECT 'OrderSummary' UNION ALL 
SELECT 'OrderSummaryDetails' UNION ALL 
SELECT 'OrdertoCashFlowProduct' UNION ALL 
SELECT 'OutputTaxPercentage' UNION ALL 
SELECT 'OverSoldOrderQty' UNION ALL 
SELECT 'Parivarscorecard' UNION ALL 
SELECT 'PatternMatch' UNION ALL 
SELECT 'PayOutProducts' UNION ALL 
SELECT 'PBAY_OUT_Scheme_type_master' UNION ALL 
SELECT 'PBLOrderToCashFlow' UNION ALL 
SELECT 'PDA_NewRetailer' UNION ALL 
SELECT 'PDA_Order_Marketreturn' UNION ALL 
SELECT 'PDA_Ordererrorcapture' UNION ALL 
SELECT 'PDA_ReceiptInvoice' UNION ALL 
SELECT 'PDA_SalesReturn' UNION ALL 
SELECT 'PDA_SalesReturnProduct' UNION ALL 
SELECT 'PDA_Temp_CreditNote' UNION ALL 
SELECT 'PDA_Temp_DebitNote' UNION ALL 
SELECT 'PDA_Temp_OrderBooking' UNION ALL 
SELECT 'PDA_Temp_OrderProduct' UNION ALL 
SELECT 'PDA_Temp_SalesReturn' UNION ALL 
SELECT 'PDA_Temp_SalesReturnProduct' UNION ALL 
SELECT 'PDA_TempCollection' UNION ALL 
SELECT 'PDALog' UNION ALL 
SELECT 'PDCStdVocChqDetails' UNION ALL 
SELECT 'PDCStdVocDetails' UNION ALL 
SELECT 'PDCStdVocMaster' UNION ALL 
SELECT 'PendingBillsExtractExcel' UNION ALL 
SELECT 'PendingCreditNoteUploadTrack' UNION ALL 
SELECT 'PendingOrdDetails' UNION ALL 
SELECT 'PendingSalesOrderService' UNION ALL 
SELECT 'POBatchBreakUp' UNION ALL 
SELECT 'POPromoPercentagedefinition' UNION ALL 
SELECT 'PrdBatRate' UNION ALL 
SELECT 'PrdBatStockCorrection' UNION ALL 
SELECT 'PrdBatToAvoid' UNION ALL 
SELECT 'PrdOrderQty' UNION ALL 
SELECT 'PrdVariationType' UNION ALL 
SELECT 'Prk_SalesInvoice' UNION ALL 
SELECT 'Prk_SalesInvoiceProduct' UNION ALL 
SELECT 'Prk_SalesInvoiceProductTax' UNION ALL 
SELECT 'Prk_SalesInvoiceSchemeCouponWise' UNION ALL 
SELECT 'Prk_SalesInvoiceSchemeLuckyDrawCouponWise' UNION ALL 
SELECT 'Product_PromoHierarchy' UNION ALL 
--SELECT 'ProductBatchLocation' UNION ALL 
SELECT 'ProductBatchVATTaxB4GST' UNION ALL 
SELECT 'ProductOrd' UNION ALL 
SELECT 'ProductOrdWithoutBatch' UNION ALL 
SELECT 'PurchaseCrNoteAdj' UNION ALL 
SELECT 'PurchaseDbNoteAdj' UNION ALL 
SELECT 'PurchaseExcessClaimDetails' UNION ALL 
SELECT 'PurchaseExcessClaimMaster' UNION ALL 
SELECT 'PurchaseOrderDayConfigSettings' UNION ALL 
SELECT 'PurchaseOrderDayConfigSettingsHistory' UNION ALL 
SELECT 'PurchaseOrderDayNormsSettings' UNION ALL 
SELECT 'PurchaseOrderDayNormsSettingsHistory' UNION ALL 
SELECT 'PurchaseOrderDetails' UNION ALL 
SELECT 'PurchaseOrderExtractExcel' UNION ALL 
SELECT 'PurchaseOrderFixedNormsSettings' UNION ALL 
SELECT 'PurchaseOrderFixedNormsSettingsHistory' UNION ALL 
SELECT 'PurchaseOrderIndexSettings' UNION ALL 
SELECT 'PurchaseOrderIndexSettingsHistory' UNION ALL 
SELECT 'PurchaseOrderMaster' UNION ALL 
SELECT 'PurchaseOrderNormDetails' UNION ALL 
SELECT 'PurchaseOrderNormHeader' UNION ALL 
SELECT 'PurchasePayment' UNION ALL 
SELECT 'PurchasePaymentDetails' UNION ALL 
SELECT 'PurchasePaymentGRN' UNION ALL 
SELECT 'PurchasePayOnAccount' UNION ALL 
SELECT 'PurchaseReceipt' UNION ALL 
SELECT 'PurchaseReceiptBreakUp' UNION ALL 
SELECT 'PurchaseReceiptClaim' UNION ALL 
SELECT 'PurchaseReceiptClaimScheme' UNION ALL 
SELECT 'PurchaseReceiptHdAmount' UNION ALL 
SELECT 'PurchaseReceiptLineAmount' UNION ALL 
SELECT 'PurchaseReceiptOtherCharges' UNION ALL 
SELECT 'PurchaseReceiptProduct' UNION ALL 
SELECT 'PurchaseReceiptProductMapping' UNION ALL 
SELECT 'PurchaseReceiptProductTax' UNION ALL 
SELECT 'PurchaseReturn' UNION ALL 
SELECT 'PurchaseReturnBreakUp' UNION ALL 
SELECT 'PurchaseReturnClaimScheme' UNION ALL 
SELECT 'PurchaseReturnExtractExcel' UNION ALL 
SELECT 'PurchaseReturnHdAmount' UNION ALL 
SELECT 'PurchaseReturnLineAmount' UNION ALL 
SELECT 'PurchaseReturnOtherCharges' UNION ALL 
SELECT 'PurchaseReturnProduct' UNION ALL 
SELECT 'PurchaseReturnProductTax' UNION ALL 
SELECT 'PurchaseTaxOID' UNION ALL 
SELECT 'PurShortageClaim' UNION ALL 
SELECT 'PurShortageClaimDetails' UNION ALL 
SELECT 'RaiseCreditDebit' UNION ALL 
SELECT 'RateDifferenceClaim' UNION ALL 
SELECT 'RDClaimGroup' UNION ALL 
SELECT 'RDClaimSheet' UNION ALL 
SELECT 'Receipt' UNION ALL 
SELECT 'ReceiptInvoice' UNION ALL 
SELECT 'ReCreateDbXmlFileName' UNION ALL 
SELECT 'ReCreateDbXmlNo' UNION ALL 
SELECT 'ReplacementHd' UNION ALL 
SELECT 'ReplacementIn' UNION ALL 
SELECT 'ReplacementInPrdTax' UNION ALL 
SELECT 'ReplacementOut' UNION ALL 
SELECT 'ReplacementOutPrdTax' UNION ALL  
SELECT 'Report_txt_ExcelFilterCaption_GST' UNION ALL 
SELECT 'Report_txt_PageHeader_GST' UNION ALL 
SELECT 'ReSellDamageDetails' UNION ALL 
SELECT 'ReSellDamageMaster' UNION ALL 
SELECT 'RetailerOtherThanGC' UNION ALL 
SELECT 'RetailerOtherThanGC_History' UNION ALL 
SELECT 'RetailerOtherThanGCCrNotePayout' UNION ALL 
SELECT 'ReturnHDAmount' UNION ALL 
SELECT 'ReturnHeader' UNION ALL 
SELECT 'ReturnLineAmount' UNION ALL 
SELECT 'ReturnPrdHdForScheme' UNION ALL 
SELECT 'ReturnProduct' UNION ALL 
SELECT 'ReturnProductTax' UNION ALL 
SELECT 'ReturnQPSRedeemed' UNION ALL 
SELECT 'ReturnSchemeClaimDt' UNION ALL 
SELECT 'ReturnSchemeDbNote' UNION ALL 
SELECT 'ReturnSchemeFlexiDt' UNION ALL 
SELECT 'ReturnSchemeFreePrdDt' UNION ALL 
SELECT 'ReturnSchemeLineDt' UNION ALL 
SELECT 'ReturnSchemePointsDt' UNION ALL 
SELECT 'ReturnSchemeQPSGiven' UNION ALL 
SELECT 'ReturnToCompany' UNION ALL 
SELECT 'ReturnToCompanyDt' UNION ALL 
SELECT 'ReturnToCompanyDtTax' UNION ALL 
SELECT 'RouteMod_Rejected' UNION ALL 
SELECT 'RouteModification' UNION ALL 
SELECT 'RptAKSOExcelHeaders' UNION ALL 
SELECT 'RptBank' UNION ALL 
SELECT 'RptBankBranch' UNION ALL 
SELECT 'RptBillAttribute' UNION ALL 
SELECT 'RPTBillDetailsRtrLevelTaxSummary' UNION ALL 
SELECT 'RptBillTemplate_BillPrintMsg' UNION ALL 
SELECT 'RptBillTemplate_CoupounDetails' UNION ALL 
SELECT 'RptBillTemplate_CrDbAdjustment' UNION ALL 
SELECT 'RptBillTemplate_GCScoreCard' UNION ALL 
SELECT 'RptBillTemplate_GSECScoreCard' UNION ALL 
SELECT 'RptBillTemplate_LuckyDrawCoupounDetails' UNION ALL 
SELECT 'RptBillTemplate_MarketReturn' UNION ALL 
SELECT 'RptBillTemplate_Other' UNION ALL 
SELECT 'RptBillTemplate_ParivaarScoreCard' UNION ALL 
SELECT 'RptBillTemplate_PrdUOMDetails' UNION ALL 
SELECT 'RptBillTemplate_Replacement' UNION ALL 
SELECT 'RptBillTemplate_SalesReturn' UNION ALL 
SELECT 'RptBillTemplate_SampleIssue' UNION ALL 
SELECT 'RptBillTemplate_Scheme' UNION ALL 
SELECT 'RptBillTemplate_Tax' UNION ALL 
SELECT 'RptBillTemplateFinal' UNION ALL 
SELECT 'RptBillTemplateSerInv_GSTTax' UNION ALL 
SELECT 'RptBillToPrint' UNION ALL 
SELECT 'RptBillWiseCollectionExcel' UNION ALL 
SELECT 'RptBillWisePrdWise' UNION ALL 
SELECT 'RptBillWisePrdWiseTaxBreakup' UNION ALL 
SELECT 'RptBt_View_Final1_BillTemplate' UNION ALL 
SELECT 'RptBTBillTemplate' UNION ALL 
SELECT 'RptBTDCTemplate' UNION ALL 
SELECT 'RptChequePaymentDetail' UNION ALL 
SELECT 'RptClaimReportAll' UNION ALL 
SELECT 'RptClosingStock_Excel' UNION ALL 
SELECT 'RptCmpWisePurchase_Excel' UNION ALL 
SELECT 'RptCollectionCancelFormat' UNION ALL 
SELECT 'RptCollectionDetail_Excel' UNION ALL 
SELECT 'RptCollectionValue' UNION ALL 
SELECT 'RptCompany' UNION ALL 
SELECT 'RptContractPricingValues' UNION ALL 
SELECT 'RptCriticalSales' UNION ALL 
SELECT 'RPTCRNBillPrint' UNION ALL 
SELECT 'RptCrNoteRetailer_Excel' UNION ALL 
SELECT 'RPTCRNSLNPrint' UNION ALL 
SELECT 'RptCRnTax' UNION ALL 
SELECT 'RptCRNToPrint' UNION ALL 
SELECT 'RptCurrentStock_Excel' UNION ALL 
SELECT 'RptCurrentStockWithUom' UNION ALL 
SELECT 'RptDataCount' UNION ALL 
SELECT 'RptDatewiseProductwiseSales_Excel' UNION ALL 
SELECT 'RPTDBNBillPrint' UNION ALL 
SELECT 'RptDBnTax' UNION ALL 
SELECT 'RptDBNToPrint' UNION ALL 
SELECT 'RptDeadOutlet_Excel' UNION ALL 
SELECT 'RptDeliveryBoy' UNION ALL 
SELECT 'RptDeliveryBoyRoute' UNION ALL 
SELECT 'RptDeliveryReport_Excel' UNION ALL 
SELECT 'RptDistributorInfoMaster' UNION ALL 
SELECT 'RptDrillProfitLossFinance' UNION ALL 
SELECT 'RptEffectiveCoverageAnalysis_Excel' UNION ALL 
SELECT 'RptFinalBillTemplate_DC' UNION ALL 
SELECT 'RptFORMGSTR_3B_1' UNION ALL 
SELECT 'RptFORMGSTR_3B_2' UNION ALL 
SELECT 'RptFORMGSTR_3B_3' UNION ALL 
SELECT 'RptFORMGSTR_3B_4' UNION ALL 
SELECT 'RptFORMGSTR_3B_5' UNION ALL 
SELECT 'RptFORMGSTR_3B_6' UNION ALL 
SELECT 'RptFORMGSTR1_Exempt' UNION ALL 
SELECT 'RptGRNListing_Excel' UNION ALL 
SELECT 'RptGSTR_TRANS2_CGST' UNION ALL 
SELECT 'RptGSTR_TRANS2_SGST' UNION ALL 
SELECT 'RptGSTR1_B2B' UNION ALL 
SELECT 'RptGSTR1_B2CL' UNION ALL 
SELECT 'RptGSTR1_B2CS' UNION ALL 
SELECT 'RptGSTR1_Docs' UNION ALL 
SELECT 'RptGSTR1_HSNCODE' UNION ALL 
SELECT 'RptGSTR2_B2B' UNION ALL 
SELECT 'RptGSTR2_B2BUR' UNION ALL 
SELECT 'RptGSTR2_CDN' UNION ALL 
SELECT 'RptGSTR2_HSNSUM' UNION ALL 
SELECT 'RptGSTR2_NILRATE' UNION ALL 
SELECT 'RptGSTR2_Summary' UNION ALL 
SELECT 'RptGSTRTRANS1_CDNR' UNION ALL 
SELECT 'RptGSTRTRANS1_CDNUR' UNION ALL 
SELECT 'RPTIDTReport' UNION ALL 
SELECT 'RptIDTToPrint' UNION ALL 
SELECT 'RptInputOutPutGSTTax' UNION ALL 
SELECT 'RptInputtaxCreditGST' UNION ALL 
SELECT 'RptINPUTVATSummary_Excel' UNION ALL 
SELECT 'RPTINPUTVATSUMMARY_GCPL_Excel' UNION ALL 
SELECT 'RptIOTaxSummary_Excel' UNION ALL 
SELECT 'RptITCReport_Excel' UNION ALL 
SELECT 'RptItemListPrice_Excel' UNION ALL 
SELECT 'RptJcMast' UNION ALL 
SELECT 'RptJcWeek' UNION ALL 
SELECT 'RptLoadSheetBillWiseUOMOutPut' UNION ALL 
SELECT 'RptLoadSheetItemWise_Excel' UNION ALL 
SELECT 'RptLoadSheetItemWiseUomBased' UNION ALL 
SELECT 'RptLoadSheetItemWiseUOMOutPut' UNION ALL 
SELECT 'RptLocation' UNION ALL 
SELECT 'RptLocationTransferAll' UNION ALL 
SELECT 'RptNOSAgeAnalysis_Excel' UNION ALL 
SELECT 'RptOpeningBalance' UNION ALL 
SELECT 'RptOrderVSSales_Excel' UNION ALL 
SELECT 'RptOutputSaleTaxGST' UNION ALL 
SELECT 'RptOutputVATDayWise_Excel' UNION ALL 
SELECT 'RptOUTPUTVATSummary_Excel' UNION ALL 
SELECT 'RptPendingBillsDetails_Excel' UNION ALL 
SELECT 'RptPrdTrackAll' UNION ALL 
SELECT 'RptPrdWiseVatTax' UNION ALL 
SELECT 'RptPRNPurchaseReturnTemplate' UNION ALL 
SELECT 'RptPRNTemplate_Scheme' UNION ALL 
SELECT 'RptPRNTemplate_Tax' UNION ALL 
SELECT 'RptPRNTemplateFinal' UNION ALL 
SELECT 'RptPRNToPrint' UNION ALL 
SELECT 'RptProductPurchase_Excel' UNION ALL 
SELECT 'RptProductTrack' UNION ALL 
SELECT 'RptProductWise' UNION ALL 
SELECT 'RptProductWiseDetail_Excel' UNION ALL 
SELECT 'RptProductWiseSalesTaxGST' UNION ALL 
SELECT 'RptProductWiseUomBased' UNION ALL 
SELECT 'RptProfiltLoss' UNION ALL 
SELECT 'RptProfitLossFinance' UNION ALL 
SELECT 'RptPurAttribute' UNION ALL 
SELECT 'RptPurchasePayment_Excel' UNION ALL 
SELECT 'RptPurchaseReturnDetail_Excel' UNION ALL 
SELECT 'RptPurchaseReturnValues' UNION ALL 
SELECT 'RptPurchaseReturnValuesDetail' UNION ALL 
SELECT 'RptPurchaseTaxGST' UNION ALL 
SELECT 'RptRDSMWorkingEfficiency' UNION ALL 
SELECT 'RptRDSMWorkingEfficiency_Excel' UNION ALL 
SELECT 'RptReplacement_Excel' UNION ALL 
SELECT 'RptReplacementBillprint' UNION ALL 
SELECT 'RptReplacementToPrint' UNION ALL 
SELECT 'RptRetailer' UNION ALL 
SELECT 'RptRetailerAccStmtsExecl' UNION ALL 
SELECT 'RptRetailerBank' UNION ALL 
SELECT 'RptRetailerClassification' UNION ALL 
SELECT 'RptRetailerMarket' UNION ALL 
SELECT 'RptRetailerOtherThanGC' UNION ALL 
SELECT 'RptRetailerPotentialClassMap' UNION ALL 
SELECT 'RptRetailerPrdMerchandise' UNION ALL 
SELECT 'RptRetailerShipAdd' UNION ALL 
SELECT 'RptRetailerStockNormValues' UNION ALL 
SELECT 'RptRetailerValueClassMap' UNION ALL 
SELECT 'RptRetailerWiseOverSoldProduct' UNION ALL 
SELECT 'RptReturnBillTemplate_Tax' UNION ALL 
SELECT 'RptRetwsProdwsSalesReport_Excel' UNION ALL 
SELECT 'RptRoute' UNION ALL 
SELECT 'RptRouteCovPlan' UNION ALL 
SELECT 'RptRouteCovPlanDetails' UNION ALL 
SELECT 'RptRouteVillage' UNION ALL 
SELECT 'RPTRSPSALESVALUE' UNION ALL 
SELECT 'RPTRSPVALUEVOLUME' UNION ALL 
SELECT 'RptRtrClassAnalysis_Excel' UNION ALL 
SELECT 'RptRtrPrdWiseSales_Excel' UNION ALL 
SELECT 'RptRtrSequence' UNION ALL 
SELECT 'RptRtrSequenceDetails' UNION ALL 
SELECT 'RptRtrWiseBillWiseVatReport_Excel' UNION ALL 
SELECT 'RptSalavageAll_Excel' UNION ALL 
SELECT 'RptSalesBillWise_Excel' UNION ALL 
SELECT 'RptSalesBillWise_GCPL' UNION ALL 
SELECT 'RptSalesMan' UNION ALL 
SELECT 'RptSalesManMarket' UNION ALL 
SELECT 'RptSalesReportSubTab' UNION ALL 
SELECT 'RptSalesReturnCNTaxGST' UNION ALL 
SELECT 'RptSalvageAll' UNION ALL 
SELECT 'RptSampleIssue_Excel' UNION ALL 
SELECT 'RptSchemeAndDiscountCreditNote_Excel' UNION ALL 
SELECT 'RptSchemeAndDiscountSummary_Excel' UNION ALL 
SELECT 'RptSchemeUtilization_Excel' UNION ALL 
SELECT 'RptSELECTedBills' UNION ALL 
SELECT 'RptSelectedServiceId' UNION ALL 
SELECT 'RptServiceInvoicePrint' UNION ALL 
SELECT 'RptSISampleTemplate' UNION ALL 
SELECT 'RptSITemplateFinal' UNION ALL 
SELECT 'RptSIToPrint' UNION ALL 
SELECT 'RptSRNFinalTemplate' UNION ALL 
SELECT 'RptSRNGCPLSRNTemplate' UNION ALL 
SELECT 'RptSRNSALESRETURN' UNION ALL 
SELECT 'RptSRNSalesReturnTemplate' UNION ALL 
SELECT 'RptSRNSchemeFinalTemplate' UNION ALL 
SELECT 'RptSRNTaxFinalTemplate' UNION ALL 
SELECT 'RptStockandSalesValue_Excel' UNION ALL 
SELECT 'RptStockandSalesVolume_Excel' UNION ALL 
SELECT 'RptStockandSalesVolumeHierarchy_Excel' UNION ALL 
SELECT 'RptStockManagementAll' UNION ALL 
SELECT 'RptStoreSchemeDetails' UNION ALL 
SELECT 'RptSummaryDet' UNION ALL 
SELECT 'RptSummaryDet_Excel' UNION ALL 
SELECT 'RptSupplierMaster' UNION ALL 
SELECT 'RptTaxConfiguration' UNION ALL 
SELECT 'RptTaxGroupSetting' UNION ALL 
SELECT 'RptTaxSummary_Excel' UNION ALL 
SELECT 'RptTempDistWidth' UNION ALL 
SELECT 'RptTempSalesAnalysis' UNION ALL 
SELECT 'RptTopOutLet_Excel' UNION ALL 
SELECT 'RptTransporterMaster' UNION ALL 
SELECT 'RptTransSequencing' UNION ALL 
SELECT 'RptTrialBalFinance' UNION ALL 
SELECT 'RptUdcRetailer' UNION ALL 
SELECT 'RptUnloadingSheet' UNION ALL 
SELECT 'RptUnloadingSheet_Excel' UNION ALL 
SELECT 'RptVehicleCategory' UNION ALL 
SELECT 'RptVehicleMaintenance' UNION ALL 
SELECT 'RptVehicleSubsidy' UNION ALL 
SELECT 'RptWithOutTaxBreakup_Excel' UNION ALL 
SELECT 'RspPunchWindowHd' UNION ALL 
SELECT 'RspPunchWindowPrdDt' UNION ALL 
SELECT 'RspPunchWindowRtrDt' UNION ALL 
SELECT 'RtpSchemeWithOutPrimary' UNION ALL 
SELECT 'RtrLoadSheetBillWise' UNION ALL 
SELECT 'RtrLoadSheetCollectionFormat' UNION ALL 
SELECT 'RtrLoadSheetItemWise' UNION ALL 
SELECT 'SalesDetailExtractExcel' UNION ALL 
SELECT 'SalesInvoice' UNION ALL 
SELECT 'SalesinvoiceBookNosettings_Bk' UNION ALL 
SELECT 'SalesInvoiceCrDays' UNION ALL 
SELECT 'SalesInvoiceEditableHistory' UNION ALL 
SELECT 'SalesInvoiceHdAmount' UNION ALL 
SELECT 'SalesInvoiceHeaderBackUp' UNION ALL 
SELECT 'SalesInvoiceLineAmount' UNION ALL 
SELECT 'SalesInvoiceMarketReturn' UNION ALL 
SELECT 'SalesInvoiceModificationHistory' UNION ALL 
SELECT 'SalesInvoiceMrkRtnDbNote' UNION ALL 
SELECT 'SalesInvoiceOrderBooking' UNION ALL 
SELECT 'SalesInvoiceProduct' UNION ALL 
SELECT 'SalesInvoiceProductTax' UNION ALL 
SELECT 'SalesInvoiceQPSCumulative' UNION ALL 
SELECT 'SalesInvoiceQpsDatebasedTrack' UNION ALL 
SELECT 'SalesInvoiceQPSRedeemed' UNION ALL 
SELECT 'SalesInvoiceQPSSchemeAdj' UNION ALL 
SELECT 'SalesInvoiceSchemeClaimDt' UNION ALL 
SELECT 'SalesInvoiceSchemeCouponDt' UNION ALL 
SELECT 'SalesInvoiceSchemeCouponWise' UNION ALL 
SELECT 'SalesInvoiceSchemeCouponWise_RolledBk' UNION ALL 
SELECT 'SalesInvoiceSchemeDtBilled' UNION ALL 
SELECT 'SalesInvoiceSchemeDtFreePrd' UNION ALL 
SELECT 'SalesInvoiceSchemeDtPoints' UNION ALL 
SELECT 'SalesInvoiceSchemeFlexiDt' UNION ALL 
SELECT 'SalesInvoiceSchemeHd' UNION ALL 
SELECT 'SalesInvoiceSchemeLineWise' UNION ALL 
SELECT 'SalesInvoiceSchemeLuckyDrawCouponWise' UNION ALL 
SELECT 'SalesInvoiceSchemeLuckyDrawCouponWise_RolledBk' UNION ALL 
SELECT 'SalesInvoiceSchemeQPSGiven' UNION ALL 
SELECT 'SalesinvoiceTrackFlexiScheme' UNION ALL 
SELECT 'SalesInvoiceUnSelectedScheme' UNION ALL 
SELECT 'SalesInvoiceWindowDisplay' UNION ALL 
SELECT 'SalesmanClaimDetail' UNION ALL 
SELECT 'SalesmanClaimMaster' UNION ALL 
SELECT 'SalesmanIncentive_Temp' UNION ALL 
SELECT 'SalesmanMod_Rejected' UNION ALL 
SELECT 'SalesmanModification' UNION ALL 
SELECT 'SalesPanel_ErrorLog' UNION ALL 
SELECT 'SalesReturnDbNoteAlert' UNION ALL 
SELECT 'SalesReturnExtractExcel' UNION ALL 
SELECT 'SalInvCrNoteAdj' UNION ALL 
SELECT 'SalInvDBNoteAdj' UNION ALL 
SELECT 'SalInvHDAmt' UNION ALL 
SELECT 'SalInvLineAmt' UNION ALL 
SELECT 'SalInvoiceDeliveryChallan' UNION ALL 
SELECT 'SalInvOnAccAdj' UNION ALL 
SELECT 'SalInvOtherAdj' UNION ALL 
SELECT 'SalUpdate' UNION ALL 
SELECT 'Salvage' UNION ALL 
SELECT 'SalvageProduct' UNION ALL 
SELECT 'SampleAppliedSchemeHd' UNION ALL 
SELECT 'SampleClaimGroup' UNION ALL 
SELECT 'SampleFrequencyQty' UNION ALL 
SELECT 'SampleIssueClaim' UNION ALL 
SELECT 'SampleIssueDt' UNION ALL 
SELECT 'SampleIssueHd' UNION ALL 
SELECT 'SamplePurchaseReceipt' UNION ALL 
SELECT 'SamplePurchaseReceiptProduct' UNION ALL 
SELECT 'SampleRetailerSlab' UNION ALL 
SELECT 'SampleReturnDt' UNION ALL 
SELECT 'SampleReturnHd' UNION ALL 
SELECT 'SampleSchemeIssue' UNION ALL 
SELECT 'SampleSchemeRetAttr' UNION ALL 
SELECT 'SaralClaimDetails' UNION ALL 
SELECT 'SchAttrToAvoid' UNION ALL 
SELECT 'SchemeApplicable' UNION ALL 
SELECT 'SchemeClaimDetails' UNION ALL 
SELECT 'SchemePointsApplied' UNION ALL 
SELECT 'SchQPSConvDetails' UNION ALL 
SELECT 'SchToAvoid' UNION ALL 
SELECT 'SearchBillInCollection' UNION ALL 
SELECT 'SellRateUpdate' UNION ALL 
SELECT 'ServerDateConfigError' UNION ALL 
SELECT 'ServiceInvoiceDT' UNION ALL 
SELECT 'ServiceInvoiceHd' UNION ALL 
SELECT 'ServiceInvoiceTaxDetails' UNION ALL 
SELECT 'ServiceMaster' UNION ALL 
SELECT 'ServicePayoutDate' UNION ALL 
SELECT 'ServiceTaxGroupMaster' UNION ALL 
SELECT 'ServiceTaxGroupSetting' UNION ALL 
SELECT 'SMIncentiveCalculatorMaster' UNION ALL
SELECT 'SMIncentiveCalculatorDetails' UNION ALL
SELECT 'SMIncentiveCalculatorTemp' UNION ALL 
SELECT 'SMMarketCallDays' UNION ALL 
SELECT 'SnapShotHD' UNION ALL 
SELECT 'SpecialDiscount_NewProducts' UNION ALL 
SELECT 'SpecialDiscountMaster' UNION ALL
SELECT 'SpecialDiscountDetails' UNION ALL
SELECT 'SpentReceivedDT' UNION ALL 
SELECT 'SpentReceivedHD' UNION ALL 
SELECT 'SplitUpProducts' UNION ALL 
SELECT 'SplitUpProductsHistory' UNION ALL 
SELECT 'SplRateToAvoid' UNION ALL 
SELECT 'SpmToAvoid' UNION ALL 
--SELECT 'StateMaster' UNION ALL 
SELECT 'StdVocDetails' UNION ALL 
SELECT 'StdVocMaster' UNION ALL 
SELECT 'StkJournalClaim' UNION ALL 
SELECT 'StockJournal' UNION ALL 
SELECT 'StockJournalDt' UNION ALL 
SELECT 'StockJournalExtractExcel' UNION ALL 
--SELECT 'StockLedger' UNION ALL 
--SELECT 'StockledgerClone' UNION ALL 
SELECT 'StockManagement' UNION ALL 
SELECT 'StockManagementExtractExcel' UNION ALL 
SELECT 'StockManagementProduct' UNION ALL 
SELECT 'StockManagementProductTax' UNION ALL 
SELECT 'StockmismatchProducts' UNION ALL 
SELECT 'SubStkClaimDetails' UNION ALL 
SELECT 'SubStockistClaims' UNION ALL 
SELECT 'SubStockistRetailer' UNION ALL 
SELECT 'SubStockistSalesDet' UNION ALL 
SELECT 'SubStockistSalesMaster' UNION ALL 
SELECT 'SubStockistScheme' UNION ALL 
SELECT 'SupplierCSTTaxPercent' UNION ALL 
SELECT 'SupplierGSTTaxGroupUpdate' UNION ALL 
SELECT 'SupplierTaxPercentage' UNION ALL 
SELECT 'TargetAnalysisDt' UNION ALL 
SELECT 'TargetAnalysisHd' UNION ALL 
SELECT 'TargetAnalysisLineAmount' UNION ALL 
SELECT 'TargetDet' UNION ALL 
SELECT 'TargetDetails' UNION ALL 
SELECT 'TaxAccountConfig' UNION ALL 
SELECT 'TaxForBilltoShipId' UNION ALL 
SELECT 'Taxformation' UNION ALL 
SELECT 'TaxForReport' UNION ALL 
SELECT 'TaxSequenceFormation' UNION ALL 
SELECT 'Tbl_Generic_Reports_RemoveBackUp' UNION ALL 
SELECT 'Tbl_LoginDisclaimer' UNION ALL 
SELECT 'Tbl_Numbers' UNION ALL 
SELECT 'TBl_OrderStock' UNION ALL 
SELECT 'Tbl_PrdHierarchy' UNION ALL 
SELECT 'Tbl_ProductBackUp' UNION ALL 
SELECT 'Tbl_ProductCategoryValueBackUp' UNION ALL 
SELECT 'Tbl_Productuom' UNION ALL 
SELECT 'tbl_SystemInfo' UNION ALL 
SELECT 'tbl_SystemInfoHistory' UNION ALL 
SELECT 'TblUsermaster_History' UNION ALL 
SELECT 'Temp_BillCouponProcess' UNION ALL 
SELECT 'Temp_BillLuckyDrawCouponProcess' UNION ALL 
SELECT 'Temp_Claim_DisplayClaim' UNION ALL 
SELECT 'Temp_Claim_SchDiscount' UNION ALL 
SELECT 'Temp_CompanyCounters' UNION ALL 
SELECT 'Temp_DisttoCompanyClaimDetails' UNION ALL 
SELECT 'Temp_DisttoCompanyInvoiceDetails' UNION ALL 
SELECT 'Temp_DisttoCompanyTaxDetails' UNION ALL 
SELECT 'Temp_Hotsearch' UNION ALL 
SELECT 'Temp_KeyAcDiscount' UNION ALL 
SELECT 'Temp_MMSDetailsInHotSearch' UNION ALL 
SELECT 'Temp_PurchaseReturn' UNION ALL 
SELECT 'Temp_RDClaimable' UNION ALL 
SELECT 'Temp_RDDiscount' UNION ALL 
SELECT 'Temp_RettoCompanyClaimDetails' UNION ALL 
SELECT 'Temp_RettoCompanyTaxDetails' UNION ALL 
SELECT 'Temp_RettoCompanyTransactionDT' UNION ALL 
SELECT 'Temp_SalesReturnSubReport' UNION ALL 
SELECT 'TEMP1' UNION ALL 
SELECT 'temp100' UNION ALL 
SELECT 'TempAGAgeningRpt' UNION ALL 
SELECT 'TempASRJCWeekValue' UNION ALL 
SELECT 'TEMPBACKUPCHECK' UNION ALL 
SELECT 'TempBalanceAssSheetSummary' UNION ALL 
SELECT 'TempBalanceLibSheetSummary' UNION ALL 
SELECT 'TempBalanceSheet' UNION ALL 
SELECT 'TempBalanceSheetSummary' UNION ALL 
SELECT 'TempBenchMarkAnlSales' UNION ALL 
SELECT 'TempBenchMarkSales' UNION ALL 
SELECT 'TempBillingRetailer' UNION ALL 
SELECT 'TempClaimMaster' UNION ALL 
SELECT 'TempClaimProductPerc' UNION ALL 
SELECT 'TempClosingStock' UNION ALL 
SELECT 'TempCouponCollection' UNION ALL 
SELECT 'TempCouponSlabAllocation' UNION ALL 
SELECT 'TempCurStk' UNION ALL 
SELECT 'TempDatewiseProductwiseSales' UNION ALL 
SELECT 'TempDepCheck' UNION ALL 
SELECT 'TempDRCPDeviation' UNION ALL 
SELECT 'TempETLBillDetailsPrdLevel' UNION ALL 
SELECT 'TempETLBillDetailsRtrLevel' UNION ALL 
SELECT 'TempETLInvoiceDetailsPrdLevel' UNION ALL 
SELECT 'TempETLInvoiceDetailsSupLevel' UNION ALL 
SELECT 'TempETLSchemeProduct' UNION ALL 
SELECT 'TempETLSRDetailsPrdLevel' UNION ALL 
SELECT 'TempETLSRDetailsRtrLevel' UNION ALL 
SELECT 'TempFBMTrackReport' UNION ALL 
SELECT 'TEMPFILLPRODUCTBATCH' UNION ALL 
SELECT 'TempFinalList' UNION ALL 
SELECT 'TempFocusBrandSetting' UNION ALL 
SELECT 'TempFocusNoOfBills' UNION ALL 
SELECT 'TempGRNListing' UNION ALL 
SELECT 'TempLaunchMonthPlan' UNION ALL 
SELECT 'TempLaunchProduct' UNION ALL 
SELECT 'TempLoadPrdUomwise' UNION ALL 
SELECT 'TempLoyaltyPoints' UNION ALL 
SELECT 'TempMassRetailer' UNION ALL 
SELECT 'TempNorm' UNION ALL 
SELECT 'TempOrderChange' UNION ALL 
SELECT 'TempOrdersInSummary' UNION ALL 
SELECT 'TempOrderTax' UNION ALL 
SELECT 'TempPDA_RtrWiseProductSales' UNION ALL 
SELECT 'TempPointBasedLoyalty' UNION ALL 
SELECT 'TempPointRedemtion' UNION ALL 
SELECT 'TempPointsAchivedDt' UNION ALL 
SELECT 'TempPriceDt' UNION ALL 
SELECT 'TempProductBasedLoyalty' UNION ALL 
SELECT 'TempProductDT' UNION ALL 
SELECT 'TempProductTax' UNION ALL 
SELECT 'TempPurchaseDiscDetail' UNION ALL 
SELECT 'TempPurchaseReturnBreakUp' UNION ALL 
SELECT 'TempPurgeDataValidate' UNION ALL 
SELECT 'TempQty' UNION ALL 
SELECT 'TempReportSalesReturnValues' UNION ALL 
SELECT 'TempRetailerAccountStatement' UNION ALL 
SELECT 'TempRetailerModification' UNION ALL 
SELECT 'TempRetailerOtherThanGC' UNION ALL 
SELECT 'TempRetailerOutstanding' UNION ALL 
SELECT 'TempRetialerWiseTax' UNION ALL 
SELECT 'TempReturnVatInvoiceSlno' UNION ALL 
SELECT 'TempRouteModification' UNION ALL 
SELECT 'TempRPSDrive' UNION ALL 
SELECT 'TempRptDatewiseProductwiseSales_Excel' UNION ALL 
SELECT 'TempRptSalestaxsumamry' UNION ALL 
SELECT 'TempRptStockNSales' UNION ALL 
SELECT 'TempRtrAccStatement' UNION ALL 
SELECT 'TempRtrCheck' UNION ALL 
SELECT 'TempRtrModified' UNION ALL 
SELECT 'TempSalesInvoiceQPSRedeemed' UNION ALL 
SELECT 'TempSalesmanAnalysis' UNION ALL 
SELECT 'TempSalesmanModification' UNION ALL 
SELECT 'tempSalesmanMTDDashBoard' UNION ALL 
SELECT 'TempSalesReturn' UNION ALL 
SELECT 'TempSalesReturnProduct' UNION ALL 
SELECT 'TempSalInvCrNoteAdj' UNION ALL 
SELECT 'TempSalInvDiscDetail' UNION ALL 
SELECT 'TempSampleAppliedSchemeHd' UNION ALL 
SELECT 'TempSampleIssue' UNION ALL 
SELECT 'TempSchemeClaimDetails' UNION ALL 
SELECT 'TempSchemeClaimDetails_BackUp' UNION ALL 
SELECT 'TempSchemeSelect' UNION ALL 
SELECT 'TempServiceTaxLineDT' UNION ALL 
SELECT 'TempServiceTaxLineSplitUp' UNION ALL 
SELECT 'TempShiftDetails' UNION ALL 
SELECT 'TempSpecialDiscount' UNION ALL 
SELECT 'TEMPSpecialRateProduct' UNION ALL 
SELECT 'TempStkstStk' UNION ALL 
SELECT 'TempStockLedDet' UNION ALL 
SELECT 'TempStockledgerClone' UNION ALL 
SELECT 'TempStockLedSummary' UNION ALL 
SELECT 'TempStockLedSummaryTotal' UNION ALL 
SELECT 'TempStockLedSummaryTotal_ROI' UNION ALL 
SELECT 'TempTbl' UNION ALL 
SELECT 'TempValidateBookNoPrefix' UNION ALL 
SELECT 'TempValidateBookNoSuffix' UNION ALL 
SELECT 'TempValueBasedLoyalty' UNION ALL 
SELECT 'TempVatClaim' UNION ALL 
SELECT 'TempVoucherDetails' UNION ALL 
SELECT 'TempVoucherDetailsNew' UNION ALL 
SELECT 'TempVoucherHeader' UNION ALL 
SELECT 'TempVoucherHeaderNew' UNION ALL 
SELECT 'TG' UNION ALL 
SELECT 'TgtPrdLevel' UNION ALL 
SELECT 'TgtRMLevel' UNION ALL 
SELECT 'TgtRtrLevel' UNION ALL 
SELECT 'TmpJcHierarchyLevel' UNION ALL 
SELECT 'TmpJcProductLevel' UNION ALL 
SELECT 'TmpPrdWiseVatTax' UNION ALL 
SELECT 'TmpPurchaseOrderNorms' UNION ALL 
SELECT 'TmpPurchaseOrderNormsOptionEdit' UNION ALL 
SELECT 'TmpRetailerWiseVatTax' UNION ALL 
SELECT 'TmpRptIOTaxSummary' UNION ALL 
SELECT 'TP' UNION ALL 
SELECT 'TransactionWiseGrnTracking' UNION ALL 
SELECT 'TranSactionWsSerailNo' UNION ALL 
SELECT 'TransporterClaimDetails' UNION ALL 
SELECT 'TransporterClaimMaster' UNION ALL 
SELECT 'UserFetchReturnScheme' UNION ALL 
SELECT 'ValueDifferenceClaim' UNION ALL 
SELECT 'VanLoadUnloadDetails' UNION ALL 
SELECT 'VanLoadUnloadMaster' UNION ALL 
SELECT 'VatClosingStock' UNION ALL 
SELECT 'VehicleAllocationDetails' UNION ALL 
SELECT 'VehicleAllocationMaster'UNION ALL
SELECT 'VanSubsidyDetail' UNION ALL
SELECT 'VanSubsidyHD' UNION ALL
SELECT 'BilledOrderPrdGRNTrack' UNION ALL
SELECT 'BilledPrdGRNTrack' UNION ALL
SELECT 'BilledPrdHdForTax_GST' UNION ALL
SELECT 'Cn2CS_Prk_BillSeriesDtUpdationGST' UNION ALL
SELECT 'Cn2CS_Prk_CompanyCountersUpdationGST' UNION ALL
SELECT 'Cn2CS_Prk_CountersUpdationGST' UNION ALL
SELECT 'Cn2Cs_Prk_DistributorInfo' UNION ALL
SELECT 'Cn2Cs_Prk_GSTConfiguration' UNION ALL
SELECT 'Cn2Cs_Prk_ProductHSNCode' UNION ALL
SELECT 'Cn2CS_Prk_PurchaseinvSeriesDtGST' UNION ALL
SELECT 'Cn2Cs_Prk_RetailerGST' UNION ALL
SELECT 'Cn2Cs_Prk_ServiceClaimGroup' UNION ALL
SELECT 'Cn2Cs_Prk_ServiceMaster' UNION ALL
SELECT 'Cn2Cs_Prk_ServiceTaxSetting' UNION ALL
SELECT 'Cn2Cs_Prk_StateMaster' UNION ALL
SELECT 'Cs2Cn_Prk_BillSeriesDtGST' UNION ALL
SELECT 'Cs2Cn_Prk_CompanyCountersGST' UNION ALL
SELECT 'Cs2Cn_Prk_CountersGST' UNION ALL
SELECT 'Cs2Cn_Prk_GSTAcknowledge' UNION ALL
SELECT 'Cs2Cn_Prk_InputTaxCreditReport' UNION ALL
SELECT 'Cs2Cn_Prk_PurchaseinvSeriesDtGST' UNION ALL
SELECT 'Cs2Cn_Prk_RetailerShipAddress' UNION ALL
SELECT 'Cs2Cn_Prk_ServiceInvoice' UNION ALL
SELECT 'Cs2Cn_Prk_TransactionWiseGrnTracking' UNION ALL
SELECT 'Cs2Cn_ReturnTaxuploadGST' UNION ALL
SELECT 'Cs2Cn_SalesTaxuploadGST' UNION ALL
SELECT 'ETL_Prk_CN2CS_UdcDetails' UNION ALL
SELECT 'ETL_Prk_RetailerGST' UNION ALL
SELECT 'ETL_Prk_TaxMapping_GST' UNION ALL
SELECT 'ETL_Prk_UDCRetailerGST' UNION ALL
SELECT 'FBMAdjustment' UNION ALL
SELECT 'IDTReceiptInvoiceDetails' UNION ALL
SELECT 'ManualConfiguration' UNION ALL
SELECT 'PDA_Temp_OrderBooking' UNION ALL
SELECT 'RptCollectionDetail_Excel' UNION ALL
SELECT 'RptInputOutPutGSTTax' UNION ALL
SELECT 'RptInputtaxCreditGST' UNION ALL
SELECT 'RptIOTaxSummary_Excel' UNION ALL
SELECT 'RptOutputSaleTaxGST' UNION ALL
SELECT 'RptProductWiseSalesTaxGST' UNION ALL
SELECT 'RptPurchaseTaxGST' UNION ALL
SELECT 'RptRtrWiseBillWiseVatReport_Excel' UNION ALL
SELECT 'RptSalesReturnCNTaxGST' UNION ALL
SELECT 'RptSelectedServiceId' UNION ALL
SELECT 'RptServiceInvoicePrint' UNION ALL
SELECT 'RptTopOutLet_Excel' UNION ALL
SELECT 'ServiceInvoiceDT' UNION ALL
SELECT 'ServiceInvoiceHd' UNION ALL
SELECT 'ServiceInvoiceTaxDetails' UNION ALL
SELECT 'ServiceMaster' UNION ALL
SELECT 'ServiceTaxGroupMaster' UNION ALL
SELECT 'ServiceTaxGroupSetting' UNION ALL
SELECT 'StockledgerClone' UNION ALL
SELECT 'StockmismatchProducts' UNION ALL
SELECT 'Temp_DisttoCompanyClaimDetails' UNION ALL
SELECT 'Temp_DisttoCompanyInvoiceDetails' UNION ALL
SELECT 'Temp_DisttoCompanyTaxDetails' UNION ALL
SELECT 'Temp_RettoCompanyClaimDetails' UNION ALL
SELECT 'Temp_RettoCompanyTaxDetails' UNION ALL
SELECT 'TempPurgeDataValidate' UNION ALL
SELECT 'TempReturnVatInvoiceSlno' UNION ALL
SELECT 'TempStockledgerClone' UNION ALL
SELECT 'TempTbl' UNION ALL
SELECT 'TransactionWiseGrnTracking'
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_PurgeTransactionData')
DROP PROCEDURE Proc_PurgeTransactionData
GO
/*
BEGIN TRAN
EXEC Proc_PurgeTransactionData 12,'2017-01-01','ParlePurg',0
ROLLBACK TRAN
*/
CREATE PROCEDURE [Proc_PurgeTransactionData] 
(
	@Pi_ModuleId	INT,
	@Pi_AsOndate	DATETIME,
	@Pi_PurgeDb		Varchar(100),
	@Pi_Error		TinyInt OUTPUT
)
AS 
SET NOCOUNT ON
/***************************************************************************************************
* PROCEDURE		: Proc_PurgeTransactionData
* PURPOSE		: To Insert Transaction details from base database to purge database
* NOTES			:
* CREATED		: Murugan.R
* CREATED ON	: 2012-09-06
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
--CCRSTBot0009 -Changes done based on PARLE Details
****************************************************************************************************/
BEGIN
		SET @Pi_Error=0
		DECLARE @Ssql AS VARCHAR(8000)
		DECLARE @ColumnNames AS VARCHAR(8000)
		DECLARE @ColumnNames1 AS VARCHAR(8000)
		DECLARE @TableName AS VARCHAR(100)
		DECLARE @ParentTable AS VARCHAR(100)
		DECLARE @DateFieldName AS VARCHAR(100)
		DECLARE @TableKeyField AS VARCHAR(100)
		DECLARE @ParentKeyField AS VARCHAR(100)
		DECLARE @ConditionField AS Varchar(50)
		DECLARE	@ConditionValue AS Varchar(50)
		
		CREATE TABLE #PurgCRDRVehicle (Tablename NVARCHAR(200))
		INSERT INTO #PurgCRDRVehicle (Tablename) 
		SELECT 'VehicleAllocationMaster' UNION 
		SELECT 'CreditNoteRetailer' UNION 
		SELECT 'DebitNoteRetailer'
		--Till Here
		
		SET @ColumnNames=''
		SET @ColumnNames1=''
		SET @Ssql=''
			BEGIN TRY
					IF @Pi_ModuleId=12
					BEGIN
						SELECT DISTINCT S.Salid,Salinvno,DCNo,Dcdate AS Salinvdate,Dlvsts,RtrId,RmId,SmId
						INTO #SalesInvoice
						FROM SalesInvoice S INNER JOIN SalInvoiceDeliveryChallan SC ON S.Salid=SC.Salid
						WHERE DcDate>=@Pi_AsOndate AND Dlvsts<>3 
					END
    
					
					DECLARE Cur_Tablename CURSOR
					FOR SELECT TableName,ParentTable,DateFieldName,TableKeyField,ParentKeyField,ConditionField,ConditionValue
					FROM  DataPurge_TransactionProcess WHERE ModuleId=@Pi_ModuleId ORDER BY Slno
					OPEN Cur_Tablename
					FETCH NEXT  FROM Cur_Tablename INTO @TableName,@ParentTable,@DateFieldName,@TableKeyField,
					@ParentKeyField,@ConditionField,@ConditionValue
					WHILE @@FETCH_STATUS=0
					BEGIN
							
							SET @Ssql=''
							SET @ColumnNames=''
							SET @ColumnNames1=''
							
							IF @Pi_ModuleId=12
							BEGIN
								IF	@ParentTable<>'SalesInvoiceQPSCumulative'
								BEGIN							
									SET @ParentTable='SalesInvoice'
								END		
							END
							IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name=@TableName)
							BEGIN
								
								SELECT @ColumnNames=@ColumnNames+'A.'+Quotename(B.NAME)+',' 
								FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id
								WHERE A.name=@TableName Order by B.colid
								SET @ColumnNames=SUBSTRING(@ColumnNames,1,LEN(@ColumnNames)-1)
								
								SELECT @ColumnNames1=@ColumnNames1+Quotename(B.NAME)+',' 
								FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id
								WHERE A.name=@TableName Order by B.colid
								SET @ColumnNames1=SUBSTRING(@ColumnNames1,1,LEN(@ColumnNames1)-1)
					
								IF (@TableName='VehicleAllocationMaster')
								BEGIN
										
										SELECT DISTINCT A.* INTO #VehicleAllocationMaster FROM VehicleAllocationMaster A 
										INNER JOIN VehicleAllocationDetails B ON A.AllotmentNumber=B.AllotmentNumber
										--INNER JOIN #SalesInvoice S ON S.DCNo=B.SaleInvNo										
										
									
										SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..'+@TableName+		
										' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..'+@TableName+'('+@ColumnNames1+')'+
										' SELECT '+@ColumnNames1+' FROM #VehicleAllocationMaster (NOLOCK) '
										--PRINT @Ssql
										EXEC(@Ssql)
								END
								IF (@TableName='CreditNoteRetailer')
								BEGIN
										SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..'+@TableName+		
										' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..'+@TableName+'('+@ColumnNames1+')'+
										' SELECT '+@ColumnNames1+' FROM '+@TableName+' (NOLOCK) WHERE (Amount-CrAdjAmount)>0'
										--PRINT @Ssql
										EXEC(@Ssql)
								END
								IF (@TableName='DebitNoteRetailer')
								BEGIN
										SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..'+@TableName+		
										' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..'+@TableName+'('+@ColumnNames1+')'+
										' SELECT '+@ColumnNames1+' FROM '+@TableName+' (NOLOCK) WHERE (Amount-DbAdjAmount)>0'
										--PRINT @Ssql
										EXEC(@Ssql)
								END
								IF NOT EXISTS (SELECT * FROM #PurgCRDRVehicle WHERE Tablename = @TableName)
								BEGIN			
										IF UPPER(@TableName)=UPPER(@ParentTable)
										BEGIN
											
												SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..'+@TableName+		
												' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..'+@TableName+'('+@ColumnNames1+')'+
												' SELECT '+@ColumnNames1+' FROM '+@TableName+' (NOLOCK) WHERE '+Quotename(@DateFieldName)+'>='+''''+CONVERT(VARCHAR(10),@Pi_AsOndate,121)+''''
												
												IF LEN(LTRIM(RTRIM(@ConditionField)))>0
												BEGIN
													SET @Ssql=@Ssql+ ' AND '+Quotename(@ConditionField)+' IN ('+@ConditionValue+')'
												END
										
											--PRINT @Ssql
											EXEC(@Ssql)
										END
										ELSE
										BEGIN
											SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..'+@TableName+		
											' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..'+@TableName+'('+@ColumnNames1+')'+
											' SELECT '+@ColumnNames+' FROM '+@TableName+' A (NOLOCK)'+
											' INNER JOIN '+ @ParentTable+' B (NOLOCK) ON A.'+Quotename(@TableKeyField)+'=B.'+Quotename(@ParentKeyField)+
											' WHERE B.'+Quotename(@DateFieldName)+'>='+''''+CONVERT(VARCHAR(10),@Pi_AsOndate,121)+''''
											IF LEN(LTRIM(RTRIM(@ConditionField)))>0
											BEGIN
												SET @Ssql=@Ssql+ ' AND B.'+Quotename(@ConditionField)+' IN ('+@ConditionValue+')'
											END
											--PRINT @Ssql
											EXEC(@Ssql)
										END
								END										
							END	
					FETCH NEXT  FROM  Cur_Tablename INTO @TableName,@ParentTable,@DateFieldName,@TableKeyField,@ParentKeyField
								,@ConditionField,@ConditionValue
					END
					CLOSE Cur_Tablename
					DEALLOCATE Cur_Tablename		
			
			END TRY
			BEGIN CATCH
				SELECT @@ERROR
				SET @Pi_Error=1
				CLOSE Cur_Tablename
				DEALLOCATE Cur_Tablename	
			END CATCH

END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_DisableTriggerAndConstraint')
DROP PROCEDURE Proc_DisableTriggerAndConstraint
GO
--EXEC Proc_DisableTriggerAndConstraint 'PARLE'
CREATE PROCEDURE Proc_DisableTriggerAndConstraint
(
	@Pi_DatabaseName AS Varchar(200)
)
AS
/*********************************
* PROCEDURE	: Proc_DisableTriggerAndConstraint
* PURPOSE	: To Disable Trigger and Constraint
* CREATED	: Murugan.R
* CREATED DATE	: 30/06/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
		DECLARE @DisableTriggerAndConstraint AS VARCHAR(3000)
		TRUNCATE TABLE  Tbl_DisEnableTriggerAndConstraint
		INSERT INTO Tbl_DisEnableTriggerAndConstraint(Xtype,TableName,DisableTriggerAndConstraint)
		--SELECT 'Constraint',QuoteName(NAME),'IF EXISTS(SELECT NAME FROM ['+@Pi_DatabaseName+']..SYSOBJECTS WHERE XTYPE=''U'' AND NAME='+''''+NAME+''''+') BEGIN ALTER TABLE ['+@Pi_DatabaseName+']..'+QuoteName(NAME)+' NOCHECK CONSTRAINT ALL END' FROM SYSOBJECTS WHERE XTYPE='U'
		SELECT DISTINCT 'Constraint',QuoteName(SO1.NAME),'IF EXISTS(SELECT NAME FROM ['+@Pi_DatabaseName+']..SYSOBJECTS WHERE XTYPE=''U'' AND NAME='+''''+SO1.NAME+''''+') BEGIN ALTER TABLE ['+@Pi_DatabaseName+']..'+QuoteName(SO1.NAME)+' NOCHECK CONSTRAINT ALL END' 
		FROM SYSCONSTRAINTS SC 
		INNER JOIN SYSOBJECTS SO ON SO.ID=SC.Constid 
		INNER JOIN SYSOBJECTS SO1 ON SO1.Id=SC.ID
		WHERE SO.XTYPE IN('F') and SO1.XTYPE='U'
		UNION ALL
		SELECT DISTINCT 'Trigger',QuoteName(SS.NAME),'IF EXISTS(SELECT NAME FROM ['+@Pi_DatabaseName+']..SYSOBJECTS WHERE XTYPE=''U'' AND NAME='+''''+SS.NAME+''''+') BEGIN ALTER TABLE ['+@Pi_DatabaseName+']..'+QuoteName(SS.NAME)+' DISABLE TRIGGER ALL END' 
		FROM SYSOBJECTS S INNER JOIN SYSOBJECTS SS ON S.Parent_obj=SS.Id 
		WHERE  SS.XTYPE='U' AND S.XTYPE='TR'
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_EnableTriggerAndConstraint')
DROP PROCEDURE Proc_EnableTriggerAndConstraint
GO
--EXEC Proc_EnableTriggerAndConstraint 'Nestle'
CREATE PROCEDURE Proc_EnableTriggerAndConstraint
(
	@Pi_DatabaseName AS Varchar(200)
)
AS
/*********************************
* PROCEDURE	: Proc_EnableTriggerAndConstraint
* PURPOSE	: To Enable Trigger and Constraint
* CREATED	: Murugan.R
* CREATED DATE	: 30/06/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
		DECLARE @DisableTriggerAndConstraint AS VARCHAR(3000)
		TRUNCATE TABLE  Tbl_DisEnableTriggerAndConstraint
		INSERT INTO Tbl_DisEnableTriggerAndConstraint(Xtype,TableName,DisableTriggerAndConstraint)
		--SELECT 'Constraint',QuoteName(NAME),'IF EXISTS(SELECT NAME FROM ['+@Pi_DatabaseName+']..SYSOBJECTS WHERE XTYPE=''U'' AND NAME='+''''+NAME+''''+') BEGIN ALTER TABLE ['+@Pi_DatabaseName+']..'+QuoteName(NAME)+' CHECK CONSTRAINT ALL END' FROM SYSOBJECTS WHERE XTYPE='U'
		SELECT DISTINCT 'Constraint',QuoteName(SO1.NAME),'IF EXISTS(SELECT NAME FROM ['+@Pi_DatabaseName+']..SYSOBJECTS WHERE XTYPE=''U'' AND NAME='+''''+SO1.NAME+''''+') BEGIN ALTER TABLE ['+@Pi_DatabaseName+']..'+QuoteName(SO1.NAME)+' CHECK CONSTRAINT ALL END' 
		FROM SYSCONSTRAINTS SC 
		INNER JOIN SYSOBJECTS SO ON SO.ID=SC.Constid 
		INNER JOIN SYSOBJECTS SO1 ON SO1.Id=SC.ID
		WHERE SO.XTYPE IN('F') and SO1.XTYPE='U'
		UNION ALL
		SELECT DISTINCT 'Trigger',QuoteName(SS.NAME),'IF EXISTS(SELECT NAME FROM ['+@Pi_DatabaseName+']..SYSOBJECTS WHERE XTYPE=''U'' AND NAME='+''''+SS.NAME+''''+') BEGIN ALTER TABLE ['+@Pi_DatabaseName+']..'+QuoteName(SS.NAME)+' ENABLE TRIGGER ALL END' 
		FROM SYSOBJECTS S INNER JOIN SYSOBJECTS SS ON S.Parent_obj=SS.Id 
		WHERE  SS.XTYPE='U' AND S.XTYPE='TR'
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='TF' AND NAME='Fn_ReturnSchemeandDiscountExists')
DROP FUNCTION Fn_ReturnSchemeandDiscountExists
GO
--SELECT * FROM DBO.Fn_ReturnSchemeandDiscountExists('2012-09-11',1)
CREATE FUNCTION Fn_ReturnSchemeandDiscountExists(@AsOndate as Datetime,@Pi_CmpId AS INT)
RETURNS @SchemeExists TABLE (RefId BIGINT)
AS
/*********************************
* PROCEDURE	: Fn_ReturnSchemeandDiscountExists
* PURPOSE	: To Return Scheme and Discount Value
* CREATED	: Murugan.R
* CREATED DATE	: 11/09/2012
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
	DECLARE @sTodate AS DateTime
	DECLARE @sFromdate AS DateTime
	DEClARE @FL AS INT
	SET @FL=0
	SELECT @sTodate=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	SELECT @sFromdate=DATEADD(mm, @FL + DATEDIFF(mm, 0, @sTodate), 0) - @FL
	
	DECLARE @TempFreeScheme TABLE
	(
		Salid BIGINT,
		SchId INT
	)
	
	DECLARE @SchMst Table
	(
	SchId  INT
	)
	
	
	INSERT INTO @TempFreeScheme(Salid,SchId)
	SELECT DISTINCT S.Salid,S.Schid 
	FROM SalesInvoiceSchemeLineWise S 
	INNER JOIN SalesInvoiceSchemeDtBilled SS
	ON S.Salid=SS.Salid and S.Schid=SS.Schid
	
	INSERT INTO @SchMst(SchId)
	SELECT A.SchId
	FROM
	SchemeMaster A WITH (NOLOCK) INNER JOIN ClaimGroupMaster B WITH (NOLOCK) ON A.ClmRefId=B.ClmGrpId
	INNER JOIN UdcDetails C WITH (NOLOCK) ON A.ClmRefId=C.MasterRecordId
	INNER JOIN (
				Select Distinct Schid from Salesinvoice SI INNER JOIN SalesInvoiceSchemeHd SH ON SI.Salid=SH.Salid
				WHERE
				Salinvdate <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0)) and Dlvsts in (4,5)
				UNION 
				Select Distinct Schid FROM ReturnSchemeLineDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
				WHERE ReturnDate<=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
				and B.Status = 0 AND A.SchClmId =0
				UNION
				Select Distinct Schid FROM ReturnSchemeFreePrdDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
				WHERE ReturnDate <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
				and B.Status = 0 AND A.SchClmId =0
	)X ON A.Schid=X.Schid 
	WHERE 
	A.Claimable=1 AND UPPER(C.ColumnValue)=UPPER('Scheme and Discount') AND A.CmpId IN(0,@Pi_CmpId)
	
	INSERT INTO @SchemeExists(RefId)
	SELECT A.SchId
	FROM SalesInvoiceSchemeLineWise A WITH (NOLOCK) INNER JOIN SalesInvoice B WITH (NOLOCK) ON A.SalId = B.SalId
	INNER JOIN @SchMst S ON A.SchId = S.SchId
	WHERE DlvSts in (4,5) AND A.SchClmId =0	
	AND B.SalInvDate <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))	
	UNION ALL
	SELECT A.SchId
	FROM SalesInvoiceSchemeDtFreePrd A WITH (NOLOCK) 
	INNER JOIN SalesInvoice B WITH (NOLOCK) ON A.SalId = B.SalId
	INNER JOIN @TempFreeScheme TF ON TF.Salid=A.Salid and TF.Schid=A.Schid and B.Salid=TF.Salid
	INNER JOIN @SchMst S ON A.SchId = S.SchId and S.Schid=TF.Schid
	WHERE DlvSts in (4,5) AND A.SchClmId =0
	AND B.SalInvDate <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))	
	UNION ALL
	SELECT A.SchId
	FROM SalesInvoiceSchemeDtFreePrd A WITH (NOLOCK) 
	INNER JOIN SalesInvoice B WITH (NOLOCK) ON A.SalId = B.SalId
	INNER JOIN @SchMst S ON A.SchId = S.SchId
	WHERE DlvSts in (4,5) AND A.SchClmId=0
	AND B.SalInvDate <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	UNION ALL
	SELECT A.SchId
	FROM ReturnSchemeLineDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	INNER JOIN @SchMst S ON A.SchId = S.SchId
	WHERE B.Status = 0 AND A.SchClmId =0
	AND B.ReturnDate<=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	UNION ALL
	SELECT A.SchId
	FROM ReturnSchemeFreePrdDt A WITH (NOLOCK) 
	INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	INNER JOIN @SchMst S ON A.SchId = S.SchId	
	WHERE B.Status = 0 AND A.SchClmId =0
	AND B.ReturnDate<=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	UNION ALL
	SELECT A.SchId
	FROM ReturnSchemeFreePrdDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	INNER JOIN @SchMst S ON A.SchId = S.SchId
	WHERE B.Status = 0 AND A.SchClmId =0
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_DataPurgeSchemeClaimDetails')
DROP PROCEDURE Proc_DataPurgeSchemeClaimDetails
GO
--EXEC Proc_DataPurgeSchemeClaimDetails '2012-05-01',1,0
CREATE  PROCEDURE [Proc_DataPurgeSchemeClaimDetails]
	(
	
		@AsOndate as Datetime,
		@Pi_CmpId AS INT,
		@SchemeDiscountExists TINYINT OUTPUT

	)
AS 
/***************************************************************************************************
* PROCEDURE		: Proc_DataPurgeSchemeClaimDetails
* PURPOSE		: To Insert Transaction details from base database to purge database
* NOTES			:
* CREATED		: Murugan.R
* CREATED ON	: 2012-09-06
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
--CCRSTBot0009 -Changes done based on PARLE Details
****************************************************************************************************/
BEGIN

SET @SchemeDiscountExists=0	

CREATE Table #SchMst 
(
	SchId 	INT,
	SchCode	nVarchar(100),
	SchDesc	nVarChar(100)
)

INSERT INTO #SchMst(SchId,SchCode,SchDesc) 
	SELECT SchId,SchCode,SchDsc FROM SchemeMaster (NOLOCK) 
	WHERE CmpId = 1 AND	Claimable = 1 AND SchValidTill  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	 

CREATE Table #SchemeDetails 
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SlabId			INT,
	DiscountAmt		Numeric(38,6),
	FreeAmt			Numeric(38,6),
	GiftAmt			Numeric(38,6),
	SchCode			nVarchar(100),
	SchDesc			nVarChar(100),
	Type			INT
)
INSERT INTO #SchemeDetails(SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo --AND E.ListPrice = 1 Commented By Murugan
	        AND E.ClmRte=1
		INNER JOIN #SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId = 0
		AND B.SalInvDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
	UNION ALL
	SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0),SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN #SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId = 0
		AND B.SalInvDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
	UNION ALL
	SELECT B.ReturnCode,A.SchId,A.SlabId,0 as DiscountAmt,
		ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0)*(-1),0 as GiftAmt,SchCode,SchDesc,1
		FROM ReturnSchemeFreePrdDt A (NOLOCK) INNER JOIN ReturnHeader B (NOLOCK) ON A.ReturnId = B.ReturnId 
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo --AND E.ListPrice = 1  Commented By Murugan
	        AND E.ClmRte=1
		INNER JOIN #SchMst S ON A.SchId = S.SchId
		WHERE B.Status = 0 AND A.SchClmId = 0
		AND B.ReturnDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	UNION ALL
	SELECT B.ReturnCode,A.SchId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0)*(-1),SchCode,SchDesc,1
		FROM ReturnSchemeFreePrdDt A (NOLOCK) INNER JOIN ReturnHeader B (NOLOCK) ON A.ReturnId = B.ReturnId 
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN #SchMst S ON A.SchId = S.SchId
		WHERE B.Status = 0 AND A.SchClmId = 0
		AND B.ReturnDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	UNION ALL
	SELECT B.SalInvno,A.SchId,1 as SlabId,ISNULL(SUM(AdjAmt),0),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,2
		FROM SalesInvoiceWindowDisplay A (NOLOCK) 
		INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId 
		INNER JOIN #SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId = 0
		AND B.SalInvDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
	GROUP BY B.SalInvno,A.SchId,SchCode,SchDesc
	UNION ALL	
	SELECT B.ChqDisRefNo,A.TransId,1 as SlaId,ISNULL(SUM(Amount),0),
		0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,3 
		FROM ChequeDisbursalMaster A (NOLOCK) 
		INNER JOIN ChequeDisbursalDetails B (NOLOCK) ON A.ChqDisRefNo = B.ChqDisRefNo 
		INNER JOIN #SchMst S ON A.TransId = S.SchId
		WHERE TransType = 1 AND A.ChqDisDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
		AND A.SchClmId = 0
	GROUP BY B.ChqDisRefNo,A.TransId,SchCode,SchDesc
	UNION ALL
	
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,ISNULL(SUM(CrAmt),0),0 as FreeAmt,0 As GiftAmt,
		SchCode,SchDesc,4
		FROM PntRetSchemeHD A (NOLOCK) INNER JOIN PntRetSchemeDt B (NOLOCK)
		ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN #SchMst S ON A.PntRedSchId = S.SchId
		WHERE A.Status = 1 AND A.TransDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
		AND CrAmt>0 AND B.SchClmId = 0
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc
	UNION ALL
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,0 as DiscountAmt,ISNULL(SUM(Qty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,4
		FROM PntRetSchemeDt A (NOLOCK) INNER JOIN PntRetSchemeHD B (NOLOCK) ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN #SchMst S ON B.PntRedSchId = S.SchId
		WHERE B.Status = 1 AND B.TransDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
		AND CrAmt=0 AND A.Type=1 AND A.SchClmId = 0
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc
	UNION ALL
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(Qty * D.PrdBatDetailValue),0) as GiftAmt,SchCode,SchDesc,4
		FROM PntRetSchemeDt A (NOLOCK) INNER JOIN PntRetSchemeHD B (NOLOCK) ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN #SchMst S ON B.PntRedSchId = S.SchId
		WHERE B.Status = 1 AND B.TransDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
		AND CrAmt=0 AND A.Type=2 AND A.SchClmId = 0
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc
	
UNION ALL
	SELECT A.CpnRedCode,A.CouponDenomId,B.SlabId,ISNULL(SUM(CrAmt),0),0 as FreeAmt,0 As GiftAmt,
		SchCode,SchDesc,5
		FROM CouponRedHd A (NOLOCK) INNER JOIN CouponRedOtherDt B (NOLOCK)
		ON A.CpnRefId = B.CpnRefId
		INNER JOIN #SchMst S ON A.CouponDenomId = S.SchId
		WHERE A.Status = 1 AND A.CpnRedDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
		AND CrAmt>0 AND B.SchClmId = 0
	GROUP BY A.CpnRedCode,A.CouponDenomId,B.SlabId,SchCode,SchDesc
 UNION ALL
 	SELECT B.CpnRedCode,B.CouponDenomId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(Qty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,5
		FROM CouponRedProducts A (NOLOCK) INNER JOIN CouponRedHd B (NOLOCK) ON A.CpnRefId = B.CpnRefId
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN #SchMst S ON B.CouponDenomId = S.SchId
		INNER JOIN Product P ON P.PrdId = A.PrdId AND P.PrdId = C.PrdId AND PrdType <> 4
		WHERE B.Status = 1 AND B.CpnRedDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
		AND A.SchClmId = 0
	GROUP BY B.CpnRedCode,B.CouponDenomId,A.SlabId,SchCode,SchDesc
 UNION ALL
 	SELECT B.CpnRedCode,B.CouponDenomId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(Qty * D.PrdBatDetailValue),0) as GiftAmt,SchCode,SchDesc,5
		FROM CouponRedProducts A (NOLOCK) INNER JOIN CouponRedHd B (NOLOCK) ON A.CpnRefId = B.CpnRefId
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN #SchMst S ON B.CouponDenomId = S.SchId
		INNER JOIN Product P ON P.PrdId = A.PrdId AND P.PrdId = C.PrdId AND PrdType =4
		WHERE B.Status = 1 AND B.CpnRedDate  <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
		AND A.SchClmId = 0
	GROUP BY B.CpnRedCode,B.CouponDenomId,A.SlabId,SchCode,SchDesc
 
	
	IF EXISTS(SELECT * FROM #SchemeDetails)
	BEGIN
		SET @SchemeDiscountExists=1
	END	
END
GO
------------------IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='TF' AND NAME='Fn_ReturnDamageClaimExists')
------------------DROP FUNCTION Fn_ReturnDamageClaimExists
------------------GO
--------------------SELECT * FROM DBO.Fn_ReturnDamageClaimExists('2018-01-18',1)
------------------CREATE FUNCTION Fn_ReturnDamageClaimExists(@AsOndate as Datetime,@Pi_CmpId AS INT)
------------------RETURNS @SchemeExists TABLE (Prdccode Varchar(50))
------------------AS
------------------/*********************************
------------------* PROCEDURE	: Fn_ReturnDamageClaimExists
------------------* PURPOSE	: To Return Salvage claim
------------------* CREATED	: Mohana S -- ICRSTGCP5842 
------------------* CREATED DATE	: 18-01-2017 
------------------* MODIFIED
------------------* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------
------------------*********************************/
------------------BEGIN
------------------	DECLARE @sTodate AS DateTime
------------------	DECLARE @sFromdate AS DateTime
------------------	DEClARE @FL AS INT
------------------	SET @FL=0
------------------	SELECT @sTodate=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0))
------------------	SELECT @sFromdate=DATEADD(mm, @FL + DATEDIFF(mm, 0, @sTodate), 0) - @FL
------------------	INSERT INTO @SchemeExists(Prdccode)
------------------	SELECT P.PrdCCode AS [Product Code]
------------------	FROM DamageClaimhd A WITH (NOLOCK)
------------------	INNER JOIN DamageClaimDetail B WITH (NOLOCK) ON A.ClmId=B.ClmId
------------------	INNER JOIN Product P WITH (NOLOCK) ON B.PrdId=P.PrdId	
------------------	WHERE 
------------------	A.ClmDate <=DATEADD(Day,-1,DATEADD(mm, DATEDIFF(m,0,@AsOndate),0)) and
------------------	A.Status<>'Approved'  and P.Cmpid =@Pi_CmpId
------------------	GROUP BY  P.PrdCCode, P.PrdName,B.PrdId 
------------------	Having SUM(B.ClmQty)>0
------------------	RETURN
------------------END
------------------GO
/*
begin tran
EXEC Proc_DataPurgeDeleteMaster 'GCPLLiveDT201411',1,0,0,'2014-01-01',0
rollback tran
*/
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_DataPurgeDeleteMaster')
DROP PROCEDURE Proc_DataPurgeDeleteMaster
GO
--EXEC Proc_DataPurgeDeleteMaster 'NestleCloneDb',1,0,0,'2012-01-01',0
CREATE PROCEDURE Proc_DataPurgeDeleteMaster
(
	@Pi_PurgeDb as Varchar(100),
	@Pi_TransactionExists AS TinyInt,
	@Pi_AllowInactiveMaster AS TinyInt,
	@Pi_AllowExpiredbatch AS TinyInt,
	@Pi_PurgeDate DATETIME,
	@Pi_Error as TinyInt OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_DataPurgeDeleteMaster
* PURPOSE	: To Remove Master Record 
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN	
		BEGIN TRANSACTION
		DECLARE @Ssql AS VARCHAR(MAX)
		SET @Pi_Error=0
		BEGIN TRY	
			SET @Ssql=''
			
			CREATE TABLE ##MasterRecord
			(
			 RtrId BIGINT,
			 SMID INT,
			 RMID INT
			)
			CREATE TABLE ##SchemeRecord
			(
			 SchId BIGINT
			)	
			CREATE 	TABLE ##StockBatch
			(
				Prdid BIGINT,
				Prdbatid BIGINT
			)				
			
			CREATE TABLE ##Retailer
			(
				RtrId BIGINT,
				CoaId INT
			)	
			
			CREATE TABLE ##SalesMan
			(
				SMID BIGINT
			)
			
			CREATE TABLE ##RouteMaster
			(
				RMID BIGINT
			)
			
			CREATE TABLE ##SchemeMaster
			(
				Schid BIGINT
			)
			CREATE TABLE ##ProductBatch
			(
				Prdid BIGINT,
				Prdbatid BIGINT
			)
			
			IF @Pi_AllowInactiveMaster=0
			BEGIN
					IF @Pi_TransactionExists=1
					BEGIN
					
						SET @Ssql= 'INSERT INTO  ##MasterRecord(RtrId,SMID,RMID) SELECT DISTINCT RtrId,SMID,RMID FROM('+
						'SELECT DISTINCT RtrId,SMID,RMID FROM '+QuoteName(@Pi_PurgeDb)+'..SalesInvoice '+
						' UNION ALL'+
						' SELECT DISTINCT RtrId,SMID,RMID FROM '+QuoteName(@Pi_PurgeDb)+'..ReturnHeader '+
						' UNION ALL'+
						' SELECT DISTINCT RtrId,SMID,RMID FROM '+QuoteName(@Pi_PurgeDb)+'..FreeIssueHd '+
						' UNION ALL'+
						' SELECT DISTINCT RtrId,0 as SMID,0 as Rmid  FROM '+QuoteName(@Pi_PurgeDb)+'.. CreditNoteRetailer '+
						' UNION ALL'+
						' SELECT DISTINCT RtrId,0 as SMID,0 as Rmid  FROM '+QuoteName(@Pi_PurgeDb)+'.. DebitNoteRetailer)X'
					
						EXEC(@Ssql)
					
					
						SET @Ssql=' INSERT INTO ##Retailer (RtrId,CoaId) SELECT DISTINCT RtrId,CoaId FROM '+QuoteName(@Pi_PurgeDb)+'..Retailer A '+
						' WHERE NOT EXISTS(SELECT DISTINCT RtrId FROM ##MasterRecord B WHERE A.RtrId=B.RtrId) '+
						' AND  RtrStatus=0 and Approved=1'
						EXEC(@Ssql)			
					END	
					
					IF @Pi_TransactionExists=0
					BEGIN
						SET @Ssql='INSERT INTO ##Retailer (RtrId,CoaId) SELECT DISTINCT RtrId,CoaId  FROM '+QuoteName(@Pi_PurgeDb)+'..Retailer A '+
						' WHERE  RtrStatus=0 and ApprovedSts=1'
						EXEC(@Ssql)			
					END
					--SalesMan
					IF @Pi_TransactionExists=1
					BEGIN
						SET @Ssql=' INSERT INTO ##SalesMan (SMID) SELECT DISTINCT SMID FROM '+QuoteName(@Pi_PurgeDb)+'..SalesMan A '+
						' WHERE NOT EXISTS(SELECT DISTINCT SMID FROM ##MasterRecord B WHERE A.SMID=B.SMID) '+
						' AND  Status=0'
						EXEC(@Ssql)			
					END	
					
					IF @Pi_TransactionExists=0
					BEGIN
						SET @Ssql='INSERT INTO ##SalesMan (SMID) SELECT DISTINCT SMID  FROM '+QuoteName(@Pi_PurgeDb)+'..SalesMan A '+
						' WHERE Status=0'
						EXEC(@Ssql)			
					END
					--RouteMaster
					IF @Pi_TransactionExists=1
					BEGIN
						SET @Ssql=' INSERT INTO ##RouteMaster (RMID) SELECT DISTINCT RMID FROM '+QuoteName(@Pi_PurgeDb)+'..RouteMaster A '+
						' WHERE NOT EXISTS(SELECT DISTINCT RMID FROM ##MasterRecord B WHERE A.RMID=B.RMID) '+
						' AND  RmStatus=0'
						EXEC(@Ssql)			
					END	
					
					IF @Pi_TransactionExists=0
					BEGIN
						SET @Ssql='INSERT INTO ##RouteMaster(RMID) SELECT DISTINCT RMID  FROM '+QuoteName(@Pi_PurgeDb)+'..RouteMaster A '+
						' WHERE RmStatus=0'
						EXEC(@Ssql)			
					END
					
					--Inactive Retailer Delete			
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..RetailerValueClassMap A '+
					'INNER JOIN ##Retailer B ON A.RtrId=B.RtrId '
				
					PRINT 	@Ssql	
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..COAMaster A  '+
					'INNER JOIN  ##Retailer B ON A.Coaid=B.Coaid'
					
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..RetailerMarket A '+
					'INNER JOIN  ##Retailer B ON A.RtrId=B.Rtrid '
				
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..RetailerShipAdd A '+
					'INNER JOIN  ##Retailer B ON A.RtrId=B.Rtrid '
				
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..RetailerRelation A '+ 
					'INNER JOIN  ##Retailer B ON A.RtrId=B.Rtrid '
					
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..RetailerPotentialClassMap A '+
					'INNER JOIN  ##Retailer B ON A.RtrId=B.Rtrid '
				
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..RetailerBank A '+
					'INNER JOIN  ##Retailer B ON A.RtrId=B.Rtrid '
				
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..UDCdetails A '+
					'INNER JOIN ##Retailer B ON A.MasterRecordId=B.Rtrid WHERE A.MasterId=2'
			
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..Retailer A '+
					' INNER JOIN  ##Retailer B ON A.RtrId=B.Rtrid '
			
					EXEC(@Ssql)
					
					--SalesMan
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..SalesmanMarket A '+
					' INNER JOIN  ##SalesMan B ON A.SMID=B.SMID '
					EXEC(@Ssql)
					
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..SalesMan A '+
					' INNER JOIN  ##SalesMan B ON A.SMID=B.SMID '
					
					EXEC(@Ssql)
					--RouteMaster
					SET @Ssql ='DELETE A FROM  '+QuoteName(@Pi_PurgeDb)+'..RouteMaster A '+
					' INNER JOIN  ##RouteMaster B ON A.RMID=B.RMID '
					EXEC(@Ssql)
					
					--SchemeMaster
					IF @Pi_TransactionExists=1
					BEGIN
						SET @Ssql ='INSERT INTO ##SchemeRecord (Schid) SELECT DISTINCT SchId FROM ('+
						' SELECT Schid FROM '+QuoteName(@Pi_PurgeDb)+'..SalesInvoiceSchemeHd'+
						' UNION ALL'+
						' SELECT Schid FROM '+QuoteName(@Pi_PurgeDb)+'..ReturnSchemeLineDt'+
						' UNION ALL'+
						' SELECT Schid FROM '+QuoteName(@Pi_PurgeDb)+'..ReturnSchemeFreePrdDt '+
						' UNION ALL'+
						' SELECT Schid FROM '+QuoteName(@Pi_PurgeDb)+'..SalesInvoiceWindowDisplay)X'
						print @Ssql
						EXEC(@ssql)
						
						SET @Ssql=' INSERT INTO ##SchemeMaster (SchId) SELECT SchId FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeMaster A '+
						' WHERE NOT EXISTS(SELECT SchId FROM ##SchemeRecord B WHERE A.SchId=B.SchId) '+
						' AND  SchStatus=0'
							
						EXEC(@Ssql)	
					END
					IF @Pi_TransactionExists=0
					BEGIN
						SET @Ssql=' INSERT INTO ##SchemeMaster (SchId) SELECT SchId FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeMaster '+
						' WHERE SchStatus=0'
						EXEC(@Ssql)	
					END
							
						SET @Ssql ='DELETE A FROM SchemeProducts A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId' 
						
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeRetAttr A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeSlabCombiPrds A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeSlabFrePrds A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeSlabMultiFrePrds A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeRtrLevelValidation A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeRuleSettings A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeAnotherPrdDt A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeAnotherPrdHd A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeSlabs A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeBudget A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeBudgetValues A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeCombiCriteria A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemePointsApplied A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
					
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeSlabCombiPrds A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeSlabCouponDt A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)	
					 
						--SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeApplicable A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						--EXEC(@Ssql)	
						----SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'.. A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						----EXEC(@Ssql)	
						----SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'.. A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						----EXEC(@Ssql)	
						SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..SchemeMaster A INNER JOIN ##SchemeMaster B ON A.Schid=B.SchId'
						EXEC(@Ssql)
			END						
			--Stockledger
			IF @Pi_AllowExpiredbatch=1
			BEGIN
					IF @Pi_TransactionExists=1
					BEGIN
						SET @Ssql ='INSERT INTO ##StockBatch(Prdid,PrdbatId) SELECT DISTINCT PrdId,Prdbatid  FROM '+QuoteName(@Pi_PurgeDb)+'..Stockledger'
						
						EXEC(@ssql)
						
						SET @Ssql=' INSERT INTO ##ProductBatch (Prdid,Prdbatid) SELECT A.Prdid,A.Prdbatid FROM '+QuoteName(@Pi_PurgeDb)+'..Productbatch A '+
						' WHERE NOT EXISTS(SELECT Prdid,Prdbatid FROM ##StockBatch B WHERE A.Prdid=B.Prdid and A.Prdbatid=B.Prdbatid) '+
						' AND ExpDate<'+''''+CONVERT(Varchar(10),@Pi_PurgeDate,121)+''''
						PRINT 	@Ssql
						EXEC(@Ssql)	
					END
					IF @Pi_TransactionExists=0
					BEGIN
						SET @Ssql=' INSERT INTO ##ProductBatch (Prdid,Prdbatid) SELECT Prdid,Prdbatid FROM '+QuoteName(@Pi_PurgeDb)+'..Productbatch A '+
						' WHERE ExpDate<'+''''+CONVERT(Varchar(10),@Pi_PurgeDate,121)+''''
						EXEC(@Ssql)	
					END
					
					SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..Productbatchdetails A INNER JOIN ##ProductBatch B ON A.PrdbatId=B.PrdbatId'
					EXEC(@Ssql)
					SET @Ssql ='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..Productbatch A INNER JOIN ##ProductBatch B ON A.Prdid=B.Prdid and A.PrdbatId=B.PrdbatId'
					EXEC(@Ssql)
			END					
					SET @Ssql='DELETE A FROM '+QuoteName(@Pi_PurgeDb)+'..COAOpeningBAlance A INNER JOIN CoaMaster B ON A.CoaId=B.CoaId WHERE B.AcName=''Opening Stock'''
					PRINT @Ssql
					EXEC(@Ssql)		

			DROP TABLE ##Retailer
			DROP TABLE ##SalesMan
			DROP TABLE ##RouteMaster			
			DROP TABLE ##SchemeMaster		
			DROP TABLE ##ProductBatch
			DROP TABLE ##MasterRecord		
			DROP TABLE ##SchemeRecord			
			DROP TABLE ##StockBatch	
			
			DECLARE @CurrValue AS BIGINT
			SELECT @CurrValue =CurrValue from Counters where TabName='StockManagement' and FldName='StkMngRefNo'
			IF ISNULL(@CurrValue,0)>0
			BEGIN
				SET @Ssql='Update '++QuoteName(@Pi_PurgeDb)+'..Counters Set CurrValue='+CAST(@CurrValue as Varchar(10))+' where TabName=''StockManagement'' and FldName=''StkMngRefNo'''	
				EXEC(@Ssql)
			END	
			
			SET @Ssql='DELETE FROM  '+QuoteName(@Pi_PurgeDb)+'..Counters WHERE TabName =''StdVocMaster'''+
			' INSERT INTO '+QuoteName(@Pi_PurgeDb)+'..Counters(TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,Availability,LastModBy,LastModDate,AuthId,AuthDate)'+
			' SELECT  TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,Availability,LastModBy,LastModDate,AuthId,AuthDate FROM Counters WHERE TabName=''StdVocMaster'''
			EXEC(@Ssql)
			
			--SELECT DISTINCT C.Schid,A.RtrId INTO #TempScheme
			--FROM SalesInvoice A INNER JOIN SalesInvoiceWindowDisplay B ON A.SalId=B.SalId and A.RtrId=B.RtrId
			--INNER JOIN SchemeRtrLevelValidation C ON C.SchId=B.SchId and C.RtrId=B.RtrId
			--WHERE Status=1   and A.Dlvsts<>3 
			--GROUP BY C.Schid,A.RtrId,C.BudgetAllocated Having (ROUND(SUM(BudgetAllocated),2)-SUM(AdjAmt))<=0.50

			SET @Ssql='UPDATE '+QuoteName(@Pi_PurgeDb)+'..SchemeRtrLevelValidation SET Status=0'
			EXEC(@Ssql)		
					
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			SELECT @@ERROR
			SET @Pi_Error=1
			ROLLBACK TRANSACTION	
			SELECT @Pi_Error
			DROP TABLE ##Retailer
			DROP TABLE ##SalesMan
			DROP TABLE ##RouteMaster			
			DROP TABLE ##SchemeMaster		
			DROP TABLE ##ProductBatch
			DROP TABLE ##MasterRecord		
			DROP TABLE ##SchemeRecord			
			DROP TABLE ##StockBatch	
		END CATCH

		
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_DataPurgeStockTransfer')
DROP PROCEDURE Proc_DataPurgeStockTransfer
GO
--EXEC Proc_DataPurgeStockTransfer 'GCPL_CN_CRDT201711',0
CREATE PROCEDURE Proc_DataPurgeStockTransfer
(
	@Pi_PurgeDb as Varchar(100),	
	@Pi_Error as TinyInt OUTPUT	
)
AS
/*********************************
* PROCEDURE	: Proc_DataPurgeStockTransfer
* PURPOSE	: To Transfer Stock  SourceDb To PurgeDb 
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	SET @Pi_Error=0
	DECLARE @ColumnNames VARCHAR(MAX)
	DECLARE @ColumnNames1 VARCHAR(MAX)
	DECLARE @Ssql VARCHAR(MAX)
	SET @Ssql=''
	SET @ColumnNames=''
	SET @ColumnNames1=''
	
	--SELECT @ColumnNames=@ColumnNames+'A.'+Quotename(B.NAME)+',' 
	--FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id
	--WHERE A.name='StockLedger' Order by B.colid
	
	--SET @ColumnNames=SUBSTRING(@ColumnNames,1,LEN(@ColumnNames)-1)

	SELECT @ColumnNames1=@ColumnNames1+Quotename(B.NAME)+',' 
	FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id
	WHERE A.name='StockLedger' Order by B.colid
	
	SET @ColumnNames1=SUBSTRING(@ColumnNames1,1,LEN(@ColumnNames1)-1)
	
	BEGIN TRY
		--BEGIN TRANSACTION
	
			SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..Stockledger'+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..Stockledger'+'('+@ColumnNames1+')'+
			' SELECT '+@ColumnNames1+' FROM PurgeStockLedger  (NOLOCK)'
			PRINT @Ssql
			EXEC(@Ssql)
			

			
			SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..Productbatchlocation'+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..Productbatchlocation(PrdId,PrdBatID,LcnId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,'+
			'PrdBatLcnResUih,PrdBatLcnResFre,Availability,LastModBy,LastModDate,AuthId,AuthDate)'+
			' SELECT DISTINCT PrdId,PrdBatID,LcnId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,'+
			' PrdBatLcnResUih,PrdBatLcnResFre,1 as Availability,1 as LastModBy,LastModDate,1 as AuthId,AuthDate FROM PurgeProductBatchLocation A (NOLOCK)'
			PRINT @Ssql
			EXEC(@Ssql)
			
			--StockAdjustment
			SET @Ssql='DELETE A FROM '+Quotename(@Pi_PurgeDb)+'..StockManagement A WHERE EXISTS(SELECT StkMngRefNo FROM PurgeStockManagement B (NOLOCK) WHERE A.StkMngRefNo=B.StkMngRefNo)'+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..StockManagement(StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,'+
			'Remarks,DecPoints,OpenBal,Status,Availability,LastModBy,LastModDate,'+
			'AuthId,AuthDate,ConfigValue,XMLUpload,VatGst)'+
			' SELECT StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,'+
			'Remarks,DecPoints,OpenBal,Status,Availability,LastModBy,LastModDate,'+
			'AuthId,AuthDate,ConfigValue,XMLUpload,VatGst FROM PurgeStockManagement (NOLOCK)'
			PRINT @Ssql
			EXEC(@Ssql)
			
			--StockAdjustmentProduct
			SET @Ssql='DELETE A FROM '+Quotename(@Pi_PurgeDb)+'..StockManagementProduct A WHERE EXISTS(SELECT StkMngRefNo FROM PurgeStockManagement B (NOLOCK) WHERE A.StkMngRefNo=B.StkMngRefNo)'+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..StockManagementProduct(StkMngRefNo,PrdId,PrdBatId,StockTypeId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,'+
			'Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,AuthId,'+
			'AuthDate,TaxAmt)'+
			' SELECT StkMngRefNo,PrdId,PrdBatId,StockTypeId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,'+
			'Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,AuthId,'+
			'AuthDate,TaxAmt FROM PurgeStockManagementProduct (NOLOCK)'
			PRINT @Ssql
			EXEC(@Ssql)
			
			--Standard Voucher
			SET @Ssql='DELETE A FROM '+Quotename(@Pi_PurgeDb)+'..StdVocMaster A INNER JOIN  PurgeStockManagement B ON LTRIM(RTRIM(SUBSTRING(A.Remarks,29,CHARINDEX('' Dated'',A.Remarks)-29)))=StkMngRefNo WHERE A.Remarks like ''Posted From Stock Adjustment%'''+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,VocSubType,AutoGen,'+
			'YEEntry,Availability,LastModBy,LastModDate,AuthId,AuthDate)'+
			' SELECT DISTINCT VocRefNo,AcmId,AcpId,VocType,VocDate,A.Remarks,VocSubType,AutoGen,'+
			'YEEntry,A.Availability,A.LastModBy,A.LastModDate,A.AuthId,A.AuthDate FROM StdVocMaster A INNER JOIN  PurgeStockManagement B ON LTRIM(RTRIM(SUBSTRING(A.Remarks,29,CHARINDEX('' Dated'',A.Remarks)-29)))=StkMngRefNo WHERE A.Remarks like ''Posted From Stock Adjustment%'''
			PRINT @Ssql
			EXEC(@Ssql)
			
			SET @Ssql='DELETE B FROM '+Quotename(@Pi_PurgeDb)+'..StdVocMaster A INNER JOIN '+Quotename(@Pi_PurgeDb)+'..StdVocDetails B ON A.VocRefNo=B.VocRefNo INNER JOIN  PurgeStockManagement C ON LTRIM(RTRIM(SUBSTRING(A.Remarks,29,CHARINDEX('' Dated'',A.Remarks)-29)))=C.StkMngRefNo WHERE A.Remarks like ''Posted From Stock Adjustment%'''+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,LastModDate,AuthId,AuthDate)'+
			' SELECT DISTINCT B.VocRefNo,CoaId,DebitCredit,Amount,B.Availability,B.LastModBy,B.LastModDate,b.AuthId,b.AuthDate'+
			' FROM StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo INNER JOIN  PurgeStockManagement C ON LTRIM(RTRIM(SUBSTRING(A.Remarks,29,CHARINDEX('' Dated'',A.Remarks)-29)))=StkMngRefNo WHERE A.Remarks like ''Posted From Stock Adjustment%'''		
			--PRINT @Ssql
			EXEC(@Ssql)
			
			--COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--ROLLBACK TRANSACTION
		SET @Pi_Error=1	
		SELECT 	@Pi_Error
	END CATCH			
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_PurgeOpeningStockAdjustment')
DROP PROCEDURE Proc_PurgeOpeningStockAdjustment
GO
--EXEC Proc_PurgeOpeningStockAdjustment '2012-07-01',	0
CREATE    PROCEDURE [Proc_PurgeOpeningStockAdjustment]
(
@Pi_TransDate DATETIME,
@Pi_OpenStockError TinyInt OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PurgeOpeningStockAdjustment
* PURPOSE	: To Add Opening Stock
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON
			SET @Pi_OpenStockError=0
			BEGIN TRY
						
			SELECT LcnId,PrdId,Prdbatid,MAX(Transdate) as Transdate
			INTO #Stock
			FROM StockLedger where Transdate between '1999-01-30' and CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121)
			GROUP BY  LcnId,Prdbatid,PrdId
			
			--DROP TABLE #Productbatch
			
			CREATE TABLE #StockManagementProduct(
			[PrdId] [int] NOT NULL,
			[PrdBatId] [int] NOT NULL,
			[StockTypeId] [int] NOT NULL,
			[UOMId1] [int] NOT NULL,
			[Qty1] [int] NOT NULL,
			[UOMId2] [int] NULL,
			[Qty2] [int] NULL,
			[TotalQty] [int] NOT NULL,
			[Rate] [numeric](18, 6) NOT NULL,
			[Amount] [numeric](18, 6) NOT NULL,
			[ReasonId] [int] NULL,
			[PriceId] [bigint] NOT NULL,
			[Availability] [tinyint] NOT NULL,
			[LastModBy] [tinyint] NOT NULL,
			[LastModDate] [datetime] NOT NULL,
			[AuthId] [tinyint] NOT NULL,
			[AuthDate] [datetime] NOT NULL,
			[TaxAmt] [numeric](18, 6) NULL,
			[LcnId] INT			
			) 
			SELECT Prdid,PB.Prdbatid,PriceId,PrdBatDetailValue Into #Productbatch FROM 
			BatchCreation B
			INNER JOIN  ProductBatch PB ON  B.BatchSeqId=PB.BatchSeqId
			INNER JOIN ProductBatchDetails PD ON 
			PB.PrdBatId=PD.PrdBatId and PB.DefaultPriceId=PD.PriceId
			and B.SlNo=PD.SLNo
			WHERE DefaultPrice=1 and ListPrice=1
		
			--Saleable OpenIng Stock Adjustment	
			INSERT INTO #StockManagementProduct(PrdId,PrdBatId,StockTypeId,
			UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,TaxAmt,LcnId)
			SELECT S.PrdId,S.PrdBatId,ST1.StockTypeId
			,1 as UOMId1,ABS(SalClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(SalClsStock) as TotalQty,
			PrdBatDetailValue as Rate,ABS(SalClsStock)*PrdBatDetailValue as Amount
			,ReasonId,PriceId, 
			9 as Availability,9 as LastModBy,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as LastModDate,9  as AuthId,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as AuthDate,0 as TaxAmt,L.Lcnid				
			FROM StockLedger S INNER JOIN #Stock ST ON S.PrdId=ST.PrdId and S.PrdBatId=St.PrdBatId
			and S.LcnId=ST.LcnId and S.TransDate=St.Transdate
			INNER JOIN StockType ST1 ON ST1.LcnId=S.LcnId and ST1.LcnId=ST.LcnId 
			INNER JOIN Location L ON S.LcnId=ST.LcnId and L.LcnId=ST.LcnId and L.LcnId=ST1.LcnId
			INNER JOIN #Productbatch PB ON PB.PrdId=S.Prdid and PB.PrdBatId=S.PrdBatId and Pb.PrdId=St.PrdId
			and PB.PrdBatId=St.PrdBatId
			CROSS JOIN ReasonMaster
			WHERE SalClsStock>0 and SystemStockType=1 and  ReasonCode='OS'
			
			--UnSaleable OpenIng Stock Adjustment	
			INSERT INTO #StockManagementProduct(PrdId,PrdBatId,StockTypeId,
			UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,TaxAmt,LcnId)
			SELECT S.PrdId,S.PrdBatId,ST1.StockTypeId
			,1 as UOMId1,ABS(UnSalClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(UnSalClsStock) as TotalQty,
			PrdBatDetailValue as Rate,ABS(UnSalClsStock)*PrdBatDetailValue as Amount
			,ReasonId,PriceId, 
			9 as Availability,9 as LastModBy,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as LastModDate,9  as AuthId,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as AuthDate,0 as TaxAmt,L.Lcnid					
			FROM StockLedger S INNER JOIN #Stock ST ON S.PrdId=ST.PrdId and S.PrdBatId=St.PrdBatId
			and S.LcnId=ST.LcnId and S.TransDate=St.Transdate
			INNER JOIN StockType ST1 ON ST1.LcnId=S.LcnId and ST1.LcnId=ST.LcnId 
			INNER JOIN Location L ON S.LcnId=ST.LcnId and L.LcnId=ST.LcnId and L.LcnId=ST1.LcnId
			INNER JOIN #Productbatch PB ON PB.PrdId=S.Prdid and PB.PrdBatId=S.PrdBatId and Pb.PrdId=St.PrdId
			and PB.PrdBatId=St.PrdBatId
			CROSS JOIN ReasonMaster
			WHERE UnSalClsStock>0 and SystemStockType=2 and  ReasonCode='OS'
			
			----Offer OpenIng Stock Adjustment	
			INSERT INTO #StockManagementProduct(PrdId,PrdBatId,StockTypeId,
			UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,TaxAmt,LcnId)
			SELECT S.PrdId,S.PrdBatId,ST1.StockTypeId
			,1 as UOMId1,ABS(OfferClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(OfferClsStock) as TotalQty,
			0 as Rate,0 as Amount
			,ReasonId,PriceId, 
			9 as Availability,9 as LastModBy,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as LastModDate,9  as AuthId,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as AuthDate,0 as TaxAmt,L.Lcnid					
			FROM StockLedger S INNER JOIN #Stock ST ON S.PrdId=ST.PrdId and S.PrdBatId=St.PrdBatId
			and S.LcnId=ST.LcnId and S.TransDate=St.Transdate
			INNER JOIN StockType ST1 ON ST1.LcnId=S.LcnId and ST1.LcnId=ST.LcnId 
			INNER JOIN Location L ON S.LcnId=ST.LcnId and L.LcnId=ST.LcnId and L.LcnId=ST1.LcnId
			INNER JOIN #Productbatch PB ON PB.PrdId=S.Prdid and PB.PrdBatId=S.PrdBatId and Pb.PrdId=St.PrdId
			and PB.PrdBatId=St.PrdBatId
			CROSS JOIN ReasonMaster
			WHERE OfferClsStock>0 and SystemStockType=2 and  ReasonCode='OS'
			
			
			DECLARE @Vocdate as DateTime
			DECLARE @Lcnid AS INT
			DECLARE CUR_STOCKADJ CURSOR
			FOR  (SELECT DISTINCT LcnId FROM #StockManagementProduct)
			OPEN CUR_STOCKADJ		
			FETCH NEXT FROM CUR_STOCKADJ INTO @LcnId			
			WHILE @@FETCH_STATUS = 0
			BEGIN	
			DECLARE @GetKeyStr AS VARCHAR(50)
			DECLARE @CurrValue AS BIGINT 
			DECLARE @Zpad AS INT
			
			SELECT @CurrValue=ISNULL(CurrValue,0),@Zpad=ISNULL(ZPad,0) FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			
			IF @CurrValue=99  AND @Zpad=2 
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=999  AND @Zpad=3
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END 
			ELSE IF @CurrValue=9999 AND @Zpad=4
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=99999 AND @Zpad=5
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=999999  AND @Zpad=6
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=9999999  AND @Zpad=7
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=99999999  AND @Zpad=8
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=999999999  AND @Zpad=9
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('StockManagement','StkMngRefNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			
			

				IF LEN(LTRIM(RTRIM(@GetKeyStr)))>0
				BEGIN
					BEGIN TRANSACTION
					
					INSERT INTO PurgeStockManagement (StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,DecPoints,OpenBal,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate,ConfigValue,XMLUpload,VatGst)
					SELECT @GetKeyStr,CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121),
					@LcnId,1,0,0,'','Openign Stock for Data Purging',5,0,1,1,1,@Pi_TransDate,99,@Pi_TransDate,0,0,'GST'
					
					INSERT INTO PurgeStockManagementProduct (StkMngRefNo,PrdId,PrdBatId,StockTypeId,UOMId1,Qty1,
					UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
					LastModDate,AuthId,AuthDate,TaxAmt,PrdSlNo)
					SELECT @GetKeyStr,PrdId,PrdBatId,StockTypeId,
					UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
					LastModDate,AuthId,AuthDate,TaxAmt,ROW_NUMBER() OVER(Order by Prdid,PrdbatId,StockTypeId) 
					FROM #StockManagementProduct WHERE Lcnid=@LcnId
					
					SET @VocDate =CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121)
					
					EXEC Proc_VoucherPosting 13,1,@GetKeyStr,5,0,2,@VocDate,0
					
					UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='StockManagement'
					COMMIT TRANSACTION
				END		
			FETCH NEXT FROM CUR_STOCKADJ INTO @LcnId		
			END
			CLOSE CUR_STOCKADJ
			DEALLOCATE CUR_STOCKADJ
				
			END TRY
			BEGIN CATCH
				SET @Pi_OpenStockError=1
			END CATCH			
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ValidatePendingTransaction')
DROP PROCEDURE Proc_ValidatePendingTransaction
GO
--EXEC Proc_ValidatePendingTransaction '2017-01-01'
--SELECT * FROM TempPurgeDataValidate
CREATE PROCEDURE Proc_ValidatePendingTransaction
(
	@Pi_Fromdate DATETIME
)
AS
/***************************************************************************************************
* PROCEDURE		: Proc_DataPurgeSchemeClaimDetails
* PURPOSE		: To Insert Transaction details from base database to purge database
* NOTES			:
* CREATED		: Murugan.R
* CREATED ON	: 2012-09-06
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
--CCRSTBot0009 -Changes done based on PARLE Details
****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @RdClaim AS TINYINT
	DECLARE @SchemeExists AS TINYINT

	TRUNCATE TABLE TempPurgeDataValidate
	DECLARE @Pi_CmpId AS INT
	SELECT @Pi_CmpId =CmpId FROM Company WHERE DefaultCompany=1
	--Upload Pending Data
	CREATE TABLE ##PendingUpload
	(
		UploadFlag Varchar(2),
		TransId TinyInt
	)
	CREATE TABLE #RDPending
	(
		RDClaim  TinyInt
	)
	CREATE TABLE #SchemePending
	(
		SchemeClaim  TinyInt
	)
		
	DECLARE @SsqlUpload AS VARCHAR(MAX)
	DECLARE @NewLineChar AS CHAR(2)
	SET @NewLineChar = CHAR(13) + CHAR(10)
	SET @SsqlUpload =''
	
	SELECT @SsqlUpload=@SsqlUpload+'SELECT UploadFlag FROM '+PrkTableName+' (NOLOCK) WHERE UploadFlag=''N'' UNION ALL '+@NewLineChar from Tbl_UploadIntegration 
	WHERE PrkTableName NOT IN('Cs2Cn_Prk_SystemInfo') Order by SequenceNo
	
	SET @SsqlUpload ='INSERT INTO ##PendingUpload SELECT UploadFlag,0 FROM ('+SUBSTRING(@SsqlUpload,1,LEN(@SsqlUpload)-13)+')X'
	EXEC(@SsqlUpload)
	
	INSERT INTO ##PendingUpload SELECT DISTINCT Upload as UploadFlag,1 FROM ClaimNSheetHd WHERE Confirm=1 and Upload='N'
	INSERT INTO ##PendingUpload SELECT DISTINCT Upload as UploadFlag,2 FROM ReturnHeader WHERE UpLoad=0 and Status=0
	INSERT INTO ##PendingUpload	SELECT DISTINCT Upload as UploadFlag,3 FROM SalesInvoice WHERE Upload=0 AND DlvSts>3	
	INSERT INTO ##PendingUpload SELECT DISTINCT Upload as UploadFlag,4 FROM ClaimSheetHd WHERE Confirm=1 and Upload='N'
	----RD CLAIM	
	--EXEC Proc_RDPendingTransaction @Pi_Fromdate,@Pi_CmpId,@Pi_Exists=@RdClaim OUTPUT
	--SCHEME AND DISCOUNT
	EXEC Proc_DataPurgeSchemeClaimDetails @Pi_Fromdate,@Pi_CmpId,@SchemeDiscountExists=@SchemeExists OUTPUT
	
	--IF @RdClaim=1
	--BEGIN
	--	INSERT INTO #RDPending SELECT 1
	--END
	
	IF @SchemeExists=1
	BEGIN
		INSERT INTO #SchemePending SELECT 1
	END
	INSERT INTO TempPurgeDataValidate(ModuleId,Modulename,PendingCount)
	SELECT ModuleId,ModuleName,SUM(NoOfPending) 
	FROM(
			SELECT 1 as ModuleId,'Purchase Order' as ModuleName,ISNULL(Count(PurorderRefNo),0) as NoOfPending FROM PurchaseOrderMaster (NOLOCK) where ConfirmSts=0
			UNION ALL
			SELECT 2,'Purchase Receipt',ISNULL(Count(PurRcptRefNo),0) as NoOfPending FROM PurchaseReceipt (NOLOCK) where Status=0
			UNION ALL
			SELECT 3,'Purchase Receipt',ISNULL(Count(CmpInvNo),0) from ETLTempPurchaseReceipt A (NOLOCK) WHERE 
			NOT EXISTS(SELECT CmpInvNo FROM PurchaseReceipt B (NOLOCK) WHERE A.CmpInvNo=B.CmpInvNo)
			AND DownLoadStatus=1
			UNION ALL
			SELECT 4,'Purchase Return',ISNULL(Count(PurRetRefNo),0) FROM PurchaseReturn (NOLOCK) WHERE Status=0
			UNION ALL
			SELECT 5,'Undelivered Bills' ,ISNULL(Count(Salid),0) FROM SalesInvoice (NOLOCK) WHERE Dlvsts IN(1,2)
			AND Salinvdate<@Pi_Fromdate
			UNION ALL
			SELECT 6,'Sales Return',ISNULL(Count(ReturnId),0) FROM ReturnHeader (NOLOCK) WHERE Status=1
			AND Returndate<@Pi_Fromdate
			UNION ALL
			SELECT 7,'Pending Collection',ISNULL(Count(Salid),0) FROM SalesInvoice (NOLOCK) WHERE (SalNetAmt-SalPayAmt)>0
			AND DlvSts>3 and Salinvdate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'Manual Claim',ISNULL(Count(MacRefId),0) FROM ManualClaimMaster WHERE Status=0 and MacDate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'Salesman Claim',ISNULL(Count(ScmRefNo),0) FROM SalesmanClaimMaster WHERE Status=0 and ScmDate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'DeliveryBoy Claim',ISNULL(Count(DbcRefNo),0) FROM DeliveryBoyClaimMaster WHERE Status=0 and DbcDate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'Salesman Incentive Claim',ISNULL(Count(SicRefNo),0) FROM SMIncentiveCalculatorMaster WHERE Status=0 and SicDate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'VanSubsidy Claim',ISNULL(Count(RefNo),0) FROM VanSubsidyHD WHERE Confirm=0 and SubsidyDt<@Pi_Fromdate
			UNION ALL
			SELECT 8,'Transporter Claim',ISNULL(Count(TrcRefNo),0) FROM TransporterClaimMaster WHERE Status=0 and TrcDate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'Special Discount Claim',ISNULL(Count(SdcRefNo),0) FROM SpecialDiscountMaster WHERE Status=0 and SdcDate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'Rate Difference Claim',ISNULL(Count(RefNo),0) FROM RateDifferenceClaim WHERE Status=0 and Date<@Pi_Fromdate
			UNION ALL
			SELECT 8,'Purchase Shortage Claim',ISNULL(Count(PurShortRefNo),0) FROM PurShortageClaim WHERE Status=0 and ClaimDate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'Purchase Excess Claim',ISNULL(Count(RefNo),0) FROM PurchaseExcessClaimMaster WHERE Status=0 and Date<@Pi_Fromdate
			UNION ALL
			SELECT 8, 'Special Discount Claim',ISNULL(COUNT(Salid),0) FROM DBO.Fn_ReturnSplDiscountClaim(0,@Pi_Fromdate,@Pi_Fromdate,@Pi_CmpId)
			--UNION ALL
			--SELECT 8,'Special Discount Claim',ISNULL(Count(SdcRefNo),0) FROM SpecialDiscountMaster WHERE Status=0 and SdcDate<@Pi_Fromdate
			UNION ALL
			SELECT 8,'ModernTrade Claim', ISNULL(COUNT(Salid),0) FROM Fn_ReturnModernTradeClaim(0,@Pi_Fromdate,@Pi_Fromdate,@Pi_CmpId,0,0,0)
			UNION ALL
			SELECT 8,'Scheme Claim' ClamGrDesc,ISNULL(Count(clmId),0) FROM ClaimSheetHD WITH (NOLOCK)WHERE Confirm=0 GROUP BY ClmType
			UNION ALL
			SELECT 8,'Scheme and Discount Claim' , 0 FROM #SchemePending		 
			--------UNION ALL CCRSTBot0009
			--------SELECT 8,'Damage Claim' ,ISNULL(COUNT(Prdccode),0) FROM DBO.Fn_ReturnDamageClaimExists(@Pi_Fromdate,1)
			UNION ALL
			SELECT 9,'Claim Top Sheet Upload Pending,Do Sync', ISNULL(COUNT(UploadFlag),0) FROM ##PendingUpload WHERE TransId=1
			UNION ALL
			SELECT 10,'Sales Return Upload Pending,Do Sync', ISNULL(COUNT(UploadFlag),0) FROM ##PendingUpload  WHERE TransId=2
			UNION ALL
			SELECT 11,'Sales Upload Pending,Do Sync', ISNULL(COUNT(UploadFlag),0) FROM ##PendingUpload  WHERE TransId=3
			UNION ALL
			SELECT 12,'Pending Upload data,Do Sync', ISNULL(COUNT(UploadFlag),0) FROM ##PendingUpload  WHERE TransId=0
			UNION ALL
			SELECT 13,'Claim Top Sheet Manual Claim Confirm Pending', ISNULL(Count(clmId),0) FROM Claimsheethd  WITH (NOLOCK)
			WHERE Confirm=0
			UNION ALL
			SELECT 14,'Claim Top Sheet Manual Claim Upload Pending', ISNULL(COUNT(UploadFlag),0) FROM ##PendingUpload  WHERE TransId=4
			
	)	X		GROUP BY ModuleName,ModuleId
	
	DROP TABLE ##PendingUpload
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'StockledgerClone')
DROP TABLE StockledgerClone
GO
CREATE TABLE StockledgerClone(
	[TransDate] [datetime] NOT NULL,
	[LcnId] [int] NOT NULL,
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[SalOpenStock] [numeric](18, 0) NULL,
	[UnSalOpenStock] [numeric](18, 0) NULL,
	[OfferOpenStock] [numeric](18, 0) NULL,
	[SalPurchase] [numeric](18, 0) NULL,
	[UnsalPurchase] [numeric](18, 0) NULL,
	[OfferPurchase] [numeric](18, 0) NULL,
	[SalPurReturn] [numeric](18, 0) NULL,
	[UnsalPurReturn] [numeric](18, 0) NULL,
	[OfferPurReturn] [numeric](18, 0) NULL,
	[SalSales] [numeric](18, 0) NULL,
	[UnSalSales] [numeric](18, 0) NULL,
	[OfferSales] [numeric](18, 0) NULL,
	[SalStockIn] [numeric](18, 0) NULL,
	[UnSalStockIn] [numeric](18, 0) NULL,
	[OfferStockIn] [numeric](18, 0) NULL,
	[SalStockOut] [numeric](18, 0) NULL,
	[UnSalStockOut] [numeric](18, 0) NULL,
	[OfferStockOut] [numeric](18, 0) NULL,
	[DamageIn] [numeric](18, 0) NULL,
	[DamageOut] [numeric](18, 0) NULL,
	[SalSalesReturn] [numeric](18, 0) NULL,
	[UnSalSalesReturn] [numeric](18, 0) NULL,
	[OfferSalesReturn] [numeric](18, 0) NULL,
	[SalStkJurIn] [numeric](18, 0) NULL,
	[UnSalStkJurIn] [numeric](18, 0) NULL,
	[OfferStkJurIn] [numeric](18, 0) NULL,
	[SalStkJurOut] [numeric](18, 0) NULL,
	[UnSalStkJurOut] [numeric](18, 0) NULL,
	[OfferStkJurOut] [numeric](18, 0) NULL,
	[SalBatTfrIn] [numeric](18, 0) NULL,
	[UnSalBatTfrIn] [numeric](18, 0) NULL,
	[OfferBatTfrIn] [numeric](18, 0) NULL,
	[SalBatTfrOut] [numeric](18, 0) NULL,
	[UnSalBatTfrOut] [numeric](18, 0) NULL,
	[OfferBatTfrOut] [numeric](18, 0) NULL,
	[SalLcnTfrIn] [numeric](18, 0) NULL,
	[UnSalLcnTfrIn] [numeric](18, 0) NULL,
	[OfferLcnTfrIn] [numeric](18, 0) NULL,
	[SalLcnTfrOut] [numeric](18, 0) NULL,
	[UnSalLcnTfrOut] [numeric](18, 0) NULL,
	[OfferLcnTfrOut] [numeric](18, 0) NULL,
	[SalReplacement] [numeric](18, 0) NULL,
	[OfferReplacement] [numeric](18, 0) NULL,
	[SalClsStock] [numeric](18, 0) NULL,
	[UnSalClsStock] [numeric](18, 0) NULL,
	[OfferClsStock] [numeric](18, 0) NULL,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'TempStockledgerClone')
DROP TABLE TempStockledgerClone
GO
CREATE TABLE TempStockledgerClone(
	[TransDate] [datetime] NOT NULL,
	[LcnId] [int] NOT NULL,
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[SalPurchase] [numeric](18, 0) NULL,
	[UnsalPurchase] [numeric](18, 0) NULL,
	[OfferPurchase] [numeric](18, 0) NULL,
	[SalPurReturn] [numeric](18, 0) NULL,
	[UnsalPurReturn] [numeric](18, 0) NULL,
	[OfferPurReturn] [numeric](18, 0) NULL,
	[SalSales] [numeric](18, 0) NULL,
	[UnSalSales] [numeric](18, 0) NULL,
	[OfferSales] [numeric](18, 0) NULL,
	[SalStockIn] [numeric](18, 0) NULL,
	[UnSalStockIn] [numeric](18, 0) NULL,
	[OfferStockIn] [numeric](18, 0) NULL,
	[SalStockOut] [numeric](18, 0) NULL,
	[UnSalStockOut] [numeric](18, 0) NULL,
	[OfferStockOut] [numeric](18, 0) NULL,
	[DamageIn] [numeric](18, 0) NULL,
	[DamageOut] [numeric](18, 0) NULL,
	[SalSalesReturn] [numeric](18, 0) NULL,
	[UnSalSalesReturn] [numeric](18, 0) NULL,
	[OfferSalesReturn] [numeric](18, 0) NULL,
	[SalStkJurIn] [numeric](18, 0) NULL,
	[UnSalStkJurIn] [numeric](18, 0) NULL,
	[OfferStkJurIn] [numeric](18, 0) NULL,
	[SalStkJurOut] [numeric](18, 0) NULL,
	[UnSalStkJurOut] [numeric](18, 0) NULL,
	[OfferStkJurOut] [numeric](18, 0) NULL,
	[SalBatTfrIn] [numeric](18, 0) NULL,
	[UnSalBatTfrIn] [numeric](18, 0) NULL,
	[OfferBatTfrIn] [numeric](18, 0) NULL,
	[SalBatTfrOut] [numeric](18, 0) NULL,
	[UnSalBatTfrOut] [numeric](18, 0) NULL,
	[OfferBatTfrOut] [numeric](18, 0) NULL,
	[SalLcnTfrIn] [numeric](18, 0) NULL,
	[UnSalLcnTfrIn] [numeric](18, 0) NULL,
	[OfferLcnTfrIn] [numeric](18, 0) NULL,
	[SalLcnTfrOut] [numeric](18, 0) NULL,
	[UnSalLcnTfrOut] [numeric](18, 0) NULL,
	[OfferLcnTfrOut] [numeric](18, 0) NULL,
	[SalReplacement] [numeric](18, 0) NULL,
	[OfferReplacement] [numeric](18, 0) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_ReUpdateClosingStockClone]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_ReUpdateClosingStockClone]
GO
--EXEC Proc_ReUpdateClosingStockClone 1,745,1,'2013-03-12',1 
CREATE   Procedure [Proc_ReUpdateClosingStockClone]
(
	@Pi_PrdId		INT,
	@Pi_PrdBatId	INT,
	@Pi_LcnId		INT,
	@Pi_TranDate	DateTime,
	@Pi_UsrId		INT

)
AS
/*********************************
* PROCEDURE	: Proc_ReUpdateClosingStockClone
* PURPOSE	: To Update Closing Stock in StockledgerCloneClone 
* CREATED	: Murugan.R
* CREATED DATE	: 18/02/2010
* NOTE		: General SP for Updating Closing Stock in StockledgerCloneClone
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
Begin

		UPDATE StockledgerClone SET 
			SalClsStock = (SalOpenStock  		+   
							SalPurchase   		+  
							SalStockIn  		+  
							SalSalesReturn 		+ 
							SalStkJurIn 		+ 
							SalBatTfrIn 		+ 
							SalLcnTfrIn 		- 
							SalPurReturn  	- 
							SalSales   		-  
							SalStockOut		- 
							SalStkJurOut 		- 
							SalBatTfrOut 		- 
							SalLcnTfrOut 		- 
							SalReplacement
						),
					UnSalClsStock = (UnSalOpenStock  		+ 
							UnSalPurchase 		+ 
							UnSalStockIn  		+ 
							DamageIn   			+  
							UnSalSalesReturn 	+ 
							UnSalStkJurIn  		+ 
							UnSalBatTfrIn 		+ 
							UnSalLcnTfrIn  		- 
							UnSalPurReturn 	-    
							UnSalSales 		- 
							UnSalStockOut 		- 
							DamageOut 			- 
							UnSalStkJurOut 		- 
							UnSalBatTfrOut 		- 
							UnSalLcnTfrOut 
						),
			OfferClsStock = (OfferOpenStock  			+ 
							OfferPurchase 			+ 
							OfferStockIn   		+
							OfferSalesReturn 		+ 
							OfferStkJurIn 		+ 
							OfferBatTfrIn 		+ 
							OfferLcnTfrIn 		- 
							OfferPurReturn 		- 
							OfferSales   			- 
							OfferStockOut 		- 
							OfferStkJurOut 		- 
							OfferBatTfrOut 		- 
							OfferLcnTfrOut 		- 
							OfferReplacement
						),
			LastModBy = @Pi_UsrId,
			LastModDate = CONVERT(VARCHAR(10),@Pi_TranDate,121),
			AuthId = @Pi_UsrId,
			AuthDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
		WHERE 
			PrdId = @Pi_PrdId AND PrdBatId = @Pi_PrdBatId AND LcnId = @Pi_LcnId
			AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
End
GO

---- 3.Proc_ReUpdateOpeningStockClone (Recreate Opening)

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_ReUpdateOpeningStockClone')
DROP PROCEDURE Proc_ReUpdateOpeningStockClone
GO
--EXEC Proc_ReUpdateOpeningStockClone 1,745,1,'2013-03-12',1 
CREATE PROCEDURE Proc_ReUpdateOpeningStockClone
(
	@Pi_PrdId		INT,
	@Pi_PrdBatId		INT,
	@Pi_LcnId		INT,
	@Pi_TranDate		DateTime,
	@Pi_UsrId		INT
	
)
AS
/*********************************
* PROCEDURE	: Proc_ReUpdateOpeningStockClone
* PURPOSE	: To Update Opening Stock in StockledgerCloneClone 
* CREATED	: Murugan.R
* CREATED DATE	: 18/02/2010
* NOTE		: General SP for Updating Opening Stock in StockledgerClone
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
Begin
	DECLARE @LastTranDate 	DATETIME
	Declare @ErrNo as INT

	

	Select @LastTranDate = isnull(Max(TransDate),CONVERT(VARCHAR(10),'1981-05-30',121)) from 
		StockledgerClone where PrdId=@Pi_PrdId and PrdBatId=@Pi_PrdBatId 
		and LcnId=@Pi_LcnId and TransDate < @Pi_TranDate
	
	IF @LastTranDate = '1981-05-30'
	BEGIN
		UPDATE StockledgerClone SET 
			SalOpenStock = 0,
			UnSalOpenStock = 0,
			OfferOpenStock = 0,
			LastModBy = @Pi_UsrId,
			LastModDate = CONVERT(VARCHAR(10),GetDate(),121),
			AuthId = @Pi_UsrId,
			AuthDate = CONVERT(VARCHAR(10),GetDate(),121)
		WHERE 
			PrdId = @Pi_PrdId AND PrdBatId = @Pi_PrdBatId AND LcnId = @Pi_LcnId
			AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
	END
	ELSE
	BEGIN
		Select @LastTranDate = DATEADD(DAY,1,@LastTranDate)
		While @LastTranDate <= @Pi_TranDate
		Begin

			IF NOT EXISTS (SELECT PrdId FROM StockledgerClone Where PrdId = @Pi_PrdId
				and PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
				and TransDate = CONVERT(VARCHAR(10),@LastTranDate,121))
			BEGIN
				INSERT INTO StockledgerClone
				(
					TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,
					OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,	
					SalPurReturn,UnsalPurReturn,OfferPurReturn,
					SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,
					OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,
					DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,
					SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
					UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,	
					OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
					SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,
					UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,	
					SalClsStock,UnSalClsStock,OfferClsStock,Availability,
					LastModBy,LastModDate,AuthId,AuthDate
				) VALUES
				(
					@LastTranDate,@Pi_LcnId,@Pi_PrdId,@Pi_PrdBatId,0,0,
					0,0,0,0,
					0,0,0,
					0,0,0,0,0,
					0,0,0,0,0,
					0,0,0,0,
					0,0,0,0,
					0,0,0,0,
					0,0,0,0,
					0,0,0,0,
					0,0,0,0,
					0,0,0,1,
					@Pi_UsrId,@LastTranDate,@Pi_UsrId,@LastTranDate
				)
			END

			DECLARE  @DecClsStk TABLE
			(
				DSalClsStock Numeric(38,0),
				DUnSalClsStock Numeric(38,0),
				DOfferClsStock Numeric(38,0),
				DPrdId INT,
				DPrdBatId INT,
				DLcnId INT,
				DTransDate DATETIME
			)

			Delete from @DecClsStk

			INSERT INTO @DecClsStk
			(
				DSalClsStock,DUnSalClsStock,
				DOfferClsStock,DPrdId,DPrdBatId,DLcnId,
				DTransDate 
			)
			Select SalClsStock,UnSalClsStock,
				OfferClsStock,PrdId,PrdBatId,LcnId,
				@LastTranDate
			From StockledgerClone
			WHERE 
				PrdId = @Pi_PrdId AND PrdBatId = @Pi_PrdBatId AND LcnId = @Pi_LcnId
				AND TransDate = CONVERT(VARCHAR(10),DATEADD(DAY,-1,@LastTranDate),121)

			UPDATE StockledgerClone SET 
				SalOpenStock = B.DSalClsStock,
				UnSalOpenStock = B.DUnSalClsStock,
				OfferOpenStock = B.DOfferClsStock,
				LastModBy = @Pi_UsrId,
				LastModDate = CONVERT(VARCHAR(10),@Pi_TranDate,121),
				AuthId = @Pi_UsrId,
				AuthDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			FROM @DecClsStk B
			WHERE 
				PrdId = B.DPrdId AND PrdBatId = B.DPrdBatId AND LcnId = B.DLcnId
				AND TransDate = B.DTransDate
			
			EXEC Proc_ReUpdateClosingStockClone @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@LastTranDate,@Pi_UsrId			

			Select @LastTranDate = DATEADD(DAY,1,@LastTranDate)
		End
	END
End
GO
---- 4.Proc_ReUpdateStockledgerClone (Recreate StockLedger)
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_ReUpdateStockledgerClone')
DROP PROCEDURE Proc_ReUpdateStockledgerClone
GO
--EXEC Proc_ReUpdateStockledgerClone 1,745,1,'2013-03-12',1 
CREATE PROCEDURE Proc_ReUpdateStockledgerClone
(
@Pi_PrdId  INT,
@Pi_PrdBatId  INT,
@Pi_LcnId  INT,
@Pi_TranDate  DateTime,
@Pi_UsrId  INT
)
AS
/*********************************
* PROCEDURE	: Proc_ReUpdateStockledgerClone
* PURPOSE	: To Update StockledgerClone
* CREATED	: Murugan.R
* CREATED DATE	: 18/02/2010
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
	Begin
		 Declare @sSql as VARCHAR(2500)
		 Declare @FldName as VARCHAR(100)
		 Declare @ErrNo as INT
		 DECLARE @LastTranDate  DATETIME
		 DECLARE @OldValue	AS NUMERIC(38,6)
		 DECLARE @MaxDate AS DATETIME
		 DECLARE @CurVal	 AS NUMERIC(38,6)
    	 SET @OldValue =ISNULL(@OldValue,0)
		 IF NOT EXISTS (SELECT PrdId FROM StockledgerClone Where PrdId = @Pi_PrdId
		  and PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
		  and TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121))
		 BEGIN
			  INSERT INTO StockledgerClone
			  (
			   TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,
			   OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,
			   SalPurReturn,UnsalPurReturn,OfferPurReturn,
			   SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,
			   OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,
			   DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,
			   SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
			   UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,
			   OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
			   SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,
			   UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
			   SalClsStock,UnSalClsStock,OfferClsStock,Availability,
			   LastModBy,LastModDate,AuthId,AuthDate
			  ) 
			  SELECT TransDate,LcnId,PrdId,PrdBatId,0,0,0,
					SalPurchase,UnsalPurchase,OfferPurchase,
					SalPurReturn,UnsalPurReturn,OfferPurReturn,
					SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,
					OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,
					DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,
					SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
					UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,
					OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
					SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,
					UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,	
			   		0,0,0,1, @Pi_UsrId,TransDate,@Pi_UsrId,TransDate
			  FROM TempStockledgerClone	
			  WHERE TransDate=@Pi_TranDate and Prdid=@Pi_PrdId and Prdbatid=@Pi_PrdBatId
					and Lcnid=@Pi_LcnId
			  
		 END
				EXEC Proc_ReUpdateOpeningStockClone @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId

		  EXEC Proc_ReUpdateClosingStockClone @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId

		  Select @LastTranDate = ISNULL(MAX(TransDate),CONVERT(VARCHAR(10),'1981-05-30',121)) from
		   StockledgerClone where PrdId=@Pi_PrdId and PrdBatId=@Pi_PrdBatId
		   and LcnId=@Pi_LcnId and TransDate > @Pi_TranDate
		  IF @LastTranDate <> '1981-05-30'
		  BEGIN
			   SELECT @Pi_TranDate = DATEADD(DAY,1,@Pi_TranDate)
			   WHILE @Pi_TranDate <= @LastTranDate
			   BEGIN
				    EXEC Proc_ReUpdateOpeningStockClone @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@Pi_OpnErrNo = @ErrNo OutPut
				    SELECT @Pi_TranDate = DATEADD(DAY,1,@Pi_TranDate)
			   END
		  END	 		
End
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_PurgeManualStockAdjusment')
DROP PROCEDURE Proc_PurgeManualStockAdjusment
GO
--EXEC Proc_PurgeManualStockAdjusment 753,	2999
CREATE    PROCEDURE [Proc_PurgeManualStockAdjusment]
(
@Pi_PrdId  INT,
@Pi_PrdBatId  INT,
@Pi_AdjError TinyInt OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PurgeManualStockAdjusment
* PURPOSE	: To Adjust negative Stock
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON
DECLARE @Transdate AS DATETIME 
DECLARE @PrdId AS INT
DECLARE @PrdBatId AS INT
DECLARE @LcnId AS INT
DECLARE	@SalClsStock AS INT
DECLARE @UnSalClsStock AS INT
DECLARE  @OfferClsStock AS INT
DECLARE  @OfferStockTypeId AS INT
DECLARE  @SalesStockTypeId AS INT
DECLARE  @UnSaleableStockTypeId AS INT
DECLARE  @ReasonId AS INT
SET @Pi_AdjError=0
CREATE TABLE #StockManagementProduct(
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[StockTypeId] [int] NOT NULL,
	[UOMId1] [int] NOT NULL,
	[Qty1] [int] NOT NULL,
	[UOMId2] [int] NULL,
	[Qty2] [int] NULL,
	[TotalQty] [int] NOT NULL,
	[Rate] [numeric](18, 6) NOT NULL,
	[Amount] [numeric](18, 6) NOT NULL,
	[ReasonId] [int] NULL,
	[PriceId] [bigint] NOT NULL,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL,
	[TaxAmt] [numeric](18, 6) NULL
	
) 
BEGIN TRY
					IF EXISTS(SELECT * FROM StockledgerClone WHERE 
						(SalOpenStock<0 OR UnSalOpenStock<0 OR OfferOpenStock<0 OR
						SalPurchase<0 OR UnsalPurchase<0 OR OfferPurchase<0 OR
						SalPurReturn<0 OR UnsalPurReturn<0 OR OfferPurReturn<0 OR
						SalSales<0 OR UnSalSales<0 OR OfferSales<0 OR
						SalStockIn<0 OR UnSalStockIn<0 OR OfferStockIn<0 OR
						SalStockOut<0 OR UnSalStockOut<0 OR OfferStockOut<0 OR
						DamageIn<0 OR DamageOut<0 OR SalSalesReturn<0 OR
						UnSalSalesReturn<0 OR OfferSalesReturn<0 OR SalStkJurIn<0 OR
						UnSalStkJurIn<0 OR OfferStkJurIn<0 OR SalStkJurOut<0 OR
						UnSalStkJurOut<0 OR OfferStkJurOut<0 OR SalBatTfrIn<0 OR
						UnSalBatTfrIn<0 OR OfferBatTfrIn<0 OR SalBatTfrOut<0 OR
						UnSalBatTfrOut<0 OR OfferBatTfrOut<0 OR SalLcnTfrIn<0 OR
						UnSalLcnTfrIn<0 OR  OfferLcnTfrIn<0 OR SalLcnTfrOut<0 OR
						UnSalLcnTfrOut<0 OR  OfferLcnTfrOut<0 OR SalReplacement<0 OR
						OfferReplacement<0 OR SalClsStock<0 OR UnSalClsStock<0 OR
						OfferClsStock<0 ) and Prdid=@Pi_PrdId and Prdbatid=@Pi_PrdBatId)
					BEGIN							
							
							DECLARE CUR_STOCKADJ CURSOR
							FOR  (
									SELECT TOP 1 Transdate,Prdid,Prdbatid,LcnId,SalClsStock,UnSalClsStock,OfferClsStock
									FROM StockledgerClone 
									WHERE (SalClsStock<0 OR UnSalClsStock<0 OR OfferClsStock<0)
							)	
							OPEN CUR_STOCKADJ		
							FETCH NEXT FROM CUR_STOCKADJ INTO @Transdate,@PrdId,@PrdBatId,@LcnId,
							@SalClsStock,@UnSalClsStock,@OfferClsStock
							WHILE @@FETCH_STATUS = 0
							BEGIN	
									SET @ReasonId=0
							
									SELECT @ReasonId=ReasonId 
									FROM ReasonMaster where Description='Shortage Quantity'
									
									IF @SalClsStock<0
									BEGIN
										SELECT	@SalesStockTypeId=StockTypeId 
										FROM StockType S 
										INNER JOIN Location L ON S.Lcnid=L.LcnId
										WHERE SystemStockType=1 and L.LcnId=@LcnId										

										INSERT INTO #StockManagementProduct
										SELECT @PrdId as PrdId,@PrdBatId as PrdBatId,@SalesStockTypeId as StockTypeId
										,1 as UOMId1,ABS(@SalClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(@SalClsStock) as TotalQty,
										PrdBatDetailValue as Rate,ABS(@SalClsStock)*PrdBatDetailValue as Amount
										,@ReasonId as ReasonId,PriceId, 
										9 as Availability,9 as LastModBy,@Transdate as LastModDate,9  as AuthId,
										@Transdate as AuthDate,0 as TaxAmt
										FROM BatchCreation B
										INNER JOIN  ProductBatch PB ON  B.BatchSeqId=PB.BatchSeqId
										INNER JOIN ProductBatchDetails PD ON 
										PB.PrdBatId=PD.PrdBatId and PB.DefaultPriceId=PD.PriceId
										and B.SlNo=PD.SLNo
										WHERE PrdId=@PrdId and Pb.Prdbatid=@PrdBatId
										and DefaultPrice=1 and ListPrice=1
										
									END
									IF @UnSalClsStock<0
									BEGIN
										
										SELECT	@UnSaleableStockTypeId=StockTypeId 
										FROM StockType S 
										INNER JOIN Location L ON S.Lcnid=L.LcnId
										WHERE SystemStockType=2 and L.LcnId=@LcnId	
									
										INSERT INTO #StockManagementProduct
										SELECT @PrdId as PrdId,@PrdBatId as PrdBatId,@UnSaleableStockTypeId as StockTypeId
										,1 as UOMId1,ABS(@UnSalClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(@UnSalClsStock) as TotalQty,
										PrdBatDetailValue as Rate,ABS(@UnSalClsStock)*PrdBatDetailValue as Amount
										,@ReasonId as ReasonId,PriceId, 
										9 as Availability,9 as LastModBy,@Transdate as LastModDate,9  as AuthId,
										@Transdate as AuthDate,0 as TaxAmt										
										FROM BatchCreation B
										INNER JOIN  ProductBatch PB ON  B.BatchSeqId=PB.BatchSeqId
										INNER JOIN ProductBatchDetails PD ON 
										PB.PrdBatId=PD.PrdBatId and PB.DefaultPriceId=PD.PriceId
										and B.SlNo=PD.SLNo
										WHERE PrdId=@PrdId and Pb.Prdbatid=@PrdBatId
										and DefaultPrice=1 and ListPrice=1
									END
									IF @OfferClsStock<0
									BEGIN
										SELECT	@OfferStockTypeId=StockTypeId 
										FROM StockType S 
										INNER JOIN Location L ON S.Lcnid=L.LcnId
										WHERE SystemStockType=3 and L.LcnId=@LcnId	
									
										INSERT INTO #StockManagementProduct
										SELECT @PrdId as PrdId,@PrdBatId as PrdBatId,@OfferStockTypeId as StockTypeId
										,1 as UOMId1,ABS(@OfferClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(@OfferClsStock) as TotalQty,
										0 as Rate,0 as Amount
										,@ReasonId as ReasonId,PriceId, 
										9 as Availability,9 as LastModBy,@Transdate as LastModDate,9  as AuthId,
										@Transdate as AuthDate,0 as TaxAmt										
										FROM BatchCreation B
										INNER JOIN  ProductBatch PB ON  B.BatchSeqId=PB.BatchSeqId
										INNER JOIN ProductBatchDetails PD ON 
										PB.PrdBatId=PD.PrdBatId and PB.DefaultPriceId=PD.PriceId
										and B.SlNo=PD.SLNo
										WHERE PrdId=@PrdId and Pb.Prdbatid=@PrdBatId
										and DefaultPrice=1 and ListPrice=1
									END
									
									DECLARE @GetKeyStr AS VARCHAR(50)
									SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('StockManagement','StkMngRefNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
										IF LEN(LTRIM(RTRIM(@GetKeyStr)))>0
										BEGIN
											--BEGIN TRANSACTION
											INSERT INTO PurgeStockManagement (StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,
											DecPoints,OpenBal,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate)--,UploadFlag)
											SELECT @GetKeyStr,@Transdate,@LcnId,1,0,0,'','Adjustment after stock system reconciliation',
											5,0,1,1,1,@Transdate,99,@Transdate--,'N'
											
											INSERT INTO PurgeStockManagementProduct (StkMngRefNo,PrdId,PrdBatId,StockTypeId,UOMId1,
											Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,
											LastModBy,LastModDate,AuthId,AuthDate,TaxAmt)--,PrdSlNo)
											SELECT @GetKeyStr,PrdId,PrdBatId,StockTypeId,
											UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,
											Availability,LastModBy,
											LastModDate,AuthId,AuthDate,TaxAmt--,ROW_NUMBER() OVER(Order by Prdid,PrdbatId,StockTypeId)  
											FROM #StockManagementProduct											
											
											EXEC Proc_VoucherPosting 13,1,@GetKeyStr,5,0,2,@Transdate,0
											
											UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='StockManagement'
											--COMMIT TRANSACTION
										END
							FETCH NEXT FROM CUR_STOCKADJ INTO  @Transdate,@PrdId,@PrdBatId,@LcnId,
							@SalClsStock,@UnSalClsStock,@OfferClsStock
							END
							CLOSE CUR_STOCKADJ
							DEALLOCATE CUR_STOCKADJ	
					END
					
	END TRY
	BEGIN CATCH
		--ROLLBACK TRANSACTION
		SET @Pi_AdjError=1
	END CATCH		
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_DataPurgeRecreateStock')
DROP PROCEDURE Proc_DataPurgeRecreateStock
GO
-- EXEC Proc_DataPurgeRecreateStock 4,7,'2012-07-01',0
CREATE PROCEDURE Proc_DataPurgeRecreateStock
(
	@Pi_StkTransdate AS DATETIME,
	@Pi_StockError AS TinyINT OUTPUT
)	
AS
/*********************************
* PROCEDURE	: Proc_DataPurgeRecreateStock
* PURPOSE	: To Recreate Stock
* CREATED	: Murugan.R
* CREATED DATE	: 18/02/2010
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	SET @Pi_StockError=0
		
	BEGIN TRY
	--To Move the stock record which has transaction above PurgeDate
	CREATE TABLE #StockAbovePurgeDate
	(
		PrdID		INT,
		PrdBatid	INT,
		LcnID		TINYINT
	)
	
	INSERT INTO #StockAbovePurgeDate
	SELECT DISTINCT PrdId,PrdBatID,LcnId FROM Stockledger (NOLOCK) WHERE TransDate >=@Pi_StkTransdate
	INSERT INTO PurgeStockledger
	(TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,
	SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
	OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
	OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,
	Availability,LastModBy,LastModDate,AuthId,AuthDate--,UploadFlag1,UploadFlag2 --(CCRSTBO009)
	)
	SELECT TransDate,A.LcnId,A.PrdId,A.PrdBatId,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,
	SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
	OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
	OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,
	Availability,LastModBy,LastModDate,AuthId,AuthDate--,UploadFlag1,UploadFlag2 --(CCRSTBO009) 
	FROM Stockledger A (NOLOCK) 
	INNER JOIN #StockAbovePurgeDate B ON A.PrdID=B.PrdID AND A.PrdBatID=B.PrdBatID AND A.LcnID=B.LcnID
	WHERE TransDate >=@Pi_StkTransdate
	
	--To Move Stock which has transaction below Purge Date
	CREATE TABLE #StockBelowPurgeDate
	(
		PrdID		INT,
		PrdBatid	INT,
		LcnID		TINYINT
	)
	
	INSERT INTO #StockBelowPurgeDate
	SELECT * FROM 
	(SELECT DISTINCT PrdId,PrdBatID,LcnId FROM Stockledger (NOLOCK)) A  WHERE NOT EXISTS (SELECT * FROM #StockAbovePurgeDate B 
	WHERE CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatID AS NVARCHAR(10))+'~'+CAST(A.LcnId AS NVARCHAR(10))=
	CAST(B.PrdID AS NVARCHAR(10))+'~'+CAST(B.PrdBatid AS NVARCHAR(10))+'~'+CAST(B.LcnID AS NVARCHAR(10)))
	
	--SELECT * FROM 
	--(SELECT DISTINCT PrdId,PrdBatID,LcnId FROM Stockledger (NOLOCK)) A  WHERE CAST(A.PrdId AS NVARCHAR(10))+CAST(A.PrdBatID AS NVARCHAR(10))+CAST(A.LcnId AS NVARCHAR(10)) NOT IN
	--(SELECT CAST(PrdId AS NVARCHAR(10))+CAST(PrdBatID AS NVARCHAR(10))+CAST(LcnId AS NVARCHAR(10)) FROM #StockAbovePurgeDate)
	
	IF EXISTS (SELECT * FROM #StockBelowPurgeDate)
	BEGIN
		CREATE TABLE #StockBelowPurgeDateWithDate
		(
			PrdID		INT,
			PrdBatid	INT,
			LcnID		TINYINT,
			TransDate	DATETIME
		)
		INSERT INTO #StockBelowPurgeDateWithDate
		SELECT A.PrdId,A.PrdBatId,A.LcnId,MAX(TransDate) TransDate FROM Stockledger A (NOLOCK)
		INNER JOIN #StockBelowPurgeDate B ON A.PrdId=B.PrdID AND A.PrdBatID=B.PrdBatid AND A.LcnId=B.LcnID GROUP BY A.PrdId,A.PrdBatId,A.LcnId
		
		INSERT INTO PurgeStockledger
		(TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,
		SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
		OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
		OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,
		Availability,LastModBy,LastModDate,AuthId,AuthDate--,UploadFlag1,UploadFlag2 --(CCRSTBO009)
		)
		SELECT @Pi_StkTransdate,A.LcnId,A.PrdId,A.PrdBatId,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,
		SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
		OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
		OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,
		Availability,LastModBy,LastModDate,AuthId,AuthDate--,UploadFlag1,UploadFlag2 --(CCRSTBO009)
		FROM Stockledger A (NOLOCK) 
		INNER JOIN #StockBelowPurgeDateWithDate B ON A.PrdID=B.PrdID AND A.PrdBatID=B.PrdBatID AND A.LcnID=B.LcnID AND A.TransDate=B.TransDate 
	END
	
	INSERT INTO PurgeProductBatchLocation
	(PrdId,PrdBatID,LcnId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,PrdBatLcnResUih,PrdBatLcnResFre,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT PrdId,PrdBatID,LcnId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,PrdBatLcnResUih,PrdBatLcnResFre,Availability,LastModBy,LastModDate,AuthId,AuthDate
	FROM ProductBatchLocation
	
	END TRY
	--
	BEGIN CATCH
	--ROLLBACK TRANSACTION
	SET @Pi_StockError=1
	END CATCH
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_PurgeStockAdujsmentProcess')
DROP PROCEDURE Proc_PurgeStockAdujsmentProcess
GO
/*
BEGIN TRAN
EXEC Proc_PurgeStockAdujsmentProcess 5297,8603,'2017-01-01',0
ROLLBACK TRAN
*/
CREATE    PROCEDURE [Proc_PurgeStockAdujsmentProcess]
(
	@PrdId AS INT,
	@PrdbatId AS INT,	
	@Pi_FromDate AS DATETIME,
	@Pi_AdjProcessError AS TinyInt OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PurgeStockAdujsmentProcess
* PURPOSE	: To Adjust negative Stock
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON
DECLARE @SlNo AS INT
DECLARE @Pi_StkError AS TinyInt
DECLARE @Pi_AdjStkError AS TinyInt
SET @SlNo=1	
SET @Pi_AdjProcessError=0
BEGIN TRY	
		WHILE @SlNo<25
		BEGIN
			IF EXISTS(SELECT * FROM StockmismatchProducts  WHERE StockAdjusted=0 and Prdid=@PrdId and Prdbatid=@PrdBatId) 
			BEGIN
				--EXEC Proc_DataPurgeRecreateStock @PrdId,@PrdBatId,@Pi_FromDate,@Pi_StockError=@Pi_StkError OUTPUT
				EXEC Proc_DataPurgeRecreateStock @Pi_FromDate,@Pi_StockError=@Pi_StkError OUTPUT
				IF @Pi_StkError=0
				BEGIN
					EXEC Proc_PurgeManualStockAdjusment @PrdId,@PrdBatId,@Pi_AdjError=@Pi_AdjStkError OUTPUT
				END	
				
			END		
			SET @SlNo=@SlNo+1
		END
		SET @SlNo=1
END TRY
BEGIN CATCH
	SET @Pi_AdjProcessError=1
END  CATCH		
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_PurgeDeactivateAllTransactionModule')
DROP PROCEDURE Proc_PurgeDeactivateAllTransactionModule
GO
--EXEC Proc_PurgeDeactivateAllTransactionModule
CREATE PROCEDURE [Proc_PurgeDeactivateAllTransactionModule] 
AS 
SET NOCOUNT ON
/***************************************************************************************************
* PROCEDURE		: Proc_PurgeDeactivateAllTransactionModule
* PURPOSE		: To Deactivate All Module
* NOTES			:
* CREATED		: Murugan.R
* CREATED ON	: 2012-09-06
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
****************************************************************************************************/
BEGIN
	UPDATE ProfileDt SET BtnStatus=0 WHERE --BtnDescription<>'Exit' and BtnDescription<>'E&xit'
	--and BtnDescription<>'Print' and 
	MenuId NOT IN('mRep4','mRep7','mRep2','mStk25','mRot3')
	DELETE FROM Tbl_DownloadIntegration
	DELETE FROM Tbl_UploadIntegration
	UPDATE Configuration Set Condition='' WHERE ModuleID='DATATRANSFER31'
	UPDATE Configuration Set Condition='' WHERE ModuleID IN ('DATATRANSFER44','DATATRANSFER45')
	UPDATE Configuration Set Status=0 WHERE ModuleID='GENCONFIG23'
	UPDATE  Configuration SET Status=0 WHERE ModuleId='GENCONFIG24' AND ModuleName='General Configuration'
	UPDATE  Configuration SET Status=0 WHERE ModuleId='GENCONFIG27' AND ModuleName='General Configuration'
	UPDATE Configuration Set Status=0 WHERE ModuleId IN('DATATRANSFER41','DATATRANSFER42','DATATRANSFER43','DATATRANSFER46')
	UPDATE AutoBackupConfiguration Set Status=0 where  Moduleid IN('AUTOBACKUP2','AUTOBACKUP3')
	
	DELETE FROM MenuDefToAvoid WHERE MenuId='mRot3'
	
	IF NOT EXISTS (SELECT 'X' FROM MenuDef WHERE MenuId='mStk34' AND MenuName='mnuclaimsync')
	BEGIN
		INSERT INTO MenuDef(SrlNo,MenuId,MenuName,Caption,ParentId,MenuStatus,FormName,DefaultCaption)
		SELECT 203,'mStk34','mnuclaimsync','Claim Sync','mStk',0,'','Claim Sync'  
	END
	IF NOT EXISTS (SELECT 'X' FROM MenuDef WHERE MenuId='mStk35' AND MenuName='mnuGSTFileDownload')
	BEGIN
		INSERT INTO MenuDef(SrlNo,MenuId,MenuName,Caption,ParentId,MenuStatus,FormName,DefaultCaption)
		SELECT 204,'mStk35','mnuGSTFileDownload','File Download','mStk',0,'','File Download'  
	END
	IF NOT EXISTS (SELECT 'X' FROM MenuDef WHERE MenuId='mStk36' AND MenuName='mnusfaintegration')
	BEGIN
		INSERT INTO MenuDef(SrlNo,MenuId,MenuName,Caption,ParentId,MenuStatus,FormName,DefaultCaption)
		SELECT 205,'mStk36','mnusfaintegration','SFA Integration','mStk',0,'','SFA Integration'  
	END
	IF NOT EXISTS (SELECT 'X' FROM MenuDef WHERE MenuId='mStk37' AND MenuName='mnuSFAExport_ReUpload')
	BEGIN
		INSERT INTO MenuDef(SrlNo,MenuId,MenuName,Caption,ParentId,MenuStatus,FormName,DefaultCaption)
		SELECT 206,'mStk37','mnuSFAExport_ReUpload','SFA Export ReUpload','mStk',0,'','SFA Export ReUpload'  
	END
	IF NOT EXISTS (SELECT 'X' FROM MenuDef WHERE MenuId='mFin13' AND MenuName='mnuYearEnd')
	BEGIN
		INSERT INTO MenuDef(SrlNo,MenuId,MenuName,Caption,ParentId,MenuStatus,FormName,DefaultCaption)
		SELECT  207,'mFin13','mnuYearEnd','Year End','mFin',0,'frmYearEnd','Year End'
	END 
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_PurgeDbShrink')
DROP PROCEDURE Proc_PurgeDbShrink
GO
CREATE PROCEDURE Proc_PurgeDbShrink
(
	@Pi_PurgeDb Varchar(100)
)	
AS
BEGIN
	dbcc shrinkdatabase (@Pi_PurgeDb, 1)	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_PurgeDateValidation')
DROP PROCEDURE Proc_PurgeDateValidation
GO
--EXEC Proc_PurgeDateValidation '2012-09-22',''
CREATE PROCEDURE Proc_PurgeDateValidation
(
	@Pi_Purgedate AS DATETIME,
	@Pi_SystemPurgeDate AS DATETIME OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PurgeDateValidation
* PURPOSE	: To Validate Purge Date
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON

--SELECT @Pi_SystemPurgeDate=ISNULL(MIN(SchValidFrom),@Pi_Purgedate)    FROM (
--SELECT Schid,SchValidFrom
--FROM SchemeMaster WHERE CONVERT(VARCHAR(10),@Pi_Purgedate	,121) Between SchValidFrom and SchValidTill
--AND SchStatus=1 and Claimable=1)X

SELECT @Pi_SystemPurgeDate=ISNULL(MIN(SchValidFrom),@Pi_Purgedate)    FROM (
SELECT Schid,SchValidFrom
FROM SchemeMaster WHERE CONVERT(VARCHAR(10),Getdate()	,121) Between SchValidFrom and SchValidTill
AND SchStatus=1 and Claimable=1)X


--SELECT Schid INTO #SchemeTemp
--FROM(
--		SELECT DISTINCT SchId 
--		FROM SalesInvoiceSchemeDtBilled S 
--		INNER JOIN SalesInvoice SI ON S.SalId=SI.SalId
--		WHERE DlvSts<>3 and Salinvdate< CONVERT(VARCHAR(10),@Pi_Purgedate,121)
--		UNION ALL 
--		SELECT DISTINCT SchId 
--		FROM ReturnSchemeLineDt R 
--		INNER JOIN ReturnHeader RH ON R.ReturnID=RH.ReturnID
--		WHERE ReturnDate< CONVERT(VARCHAR(10),@Pi_Purgedate	,121)
--		UNION ALL
--		SELECT DISTINCT SchId 
--		FROM ReturnSchemeFreePrdDt R
--		INNER JOIN ReturnHeader RH ON R.ReturnID=RH.ReturnID
--		WHERE ReturnDate< CONVERT(VARCHAR(10),@Pi_Purgedate	,121)
--	)X WHERE EXISTS(SELECT SchId FROM  	#SchemeMaster Y WHERE  X.Schid=Y.SchId)

--SELECT @Pi_SystemPurgeDate=ISNULL(MIN(SchValidFrom),@Pi_Purgedate)
--FROM #SchemeMaster A INNER JOIN #SchemeTemp B ON A.SchId=B.SchId
SELECT @Pi_SystemPurgeDate
RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_DeleteDataFromSourceDB')
DROP PROCEDURE Proc_DeleteDataFromSourceDB
GO
--EXEC Proc_DeleteDataFromSourceDB 12,'2012-07-01',0
CREATE PROCEDURE Proc_DeleteDataFromSourceDB 
(
	@Pi_ModuleId	INT,
	@Pi_AsOndate	DATETIME,
	@Pi_Error		TinyInt OUTPUT
)
AS 
SET NOCOUNT ON
/***************************************************************************************************
* PROCEDURE		: Proc_DeleteDataFromSourceDB
* PURPOSE		: To Delete Data From Source Database
* NOTES			:
* CREATED		: Murugan.R
* CREATED ON	: 2012-09-06
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
****************************************************************************************************/
BEGIN
		SET @Pi_Error=0
		DECLARE @Ssql AS VARCHAR(8000)
		DECLARE @ColumnNames AS VARCHAR(8000)
		DECLARE @ColumnNames1 AS VARCHAR(8000)
		DECLARE @TableName AS VARCHAR(100)
		DECLARE @ParentTable AS VARCHAR(100)
		DECLARE @DateFieldName AS VARCHAR(100)
		DECLARE @TableKeyField AS VARCHAR(100)
		DECLARE @ParentKeyField AS VARCHAR(100)
		DECLARE @ConditionField AS Varchar(50)
		DECLARE	@ConditionValue AS Varchar(50)
		
		--Added by Sathishkumar Veeramani 2013/03/22
		CREATE TABLE #PurgCRDRVehicle (Tablename NVARCHAR(200))
		INSERT INTO #PurgCRDRVehicle (Tablename) 
		SELECT 'VehicleAllocationMaster' UNION 
		SELECT 'CreditNoteRetailer' UNION 
		SELECT 'DebitNoteRetailer'
		--Till Here
		
		SET @ColumnNames=''
		SET @ColumnNames1=''
		SET @Ssql=''
			BEGIN TRY
					IF @Pi_ModuleId=12
					BEGIN
						SELECT DISTINCT S.Salid,Salinvno,DCNo,Dcdate AS Salinvdate,Dlvsts,RtrId,RmId,SmId
						INTO #SalesInvoice
						FROM SalesInvoice S INNER JOIN SalInvoiceDeliveryChallan SC ON S.Salid=SC.Salid
						WHERE DcDate>=@Pi_AsOndate and Dlvsts<>3 
					END
					
					DECLARE Cur_Tablename CURSOR
					FOR SELECT TableName,ParentTable,DateFieldName,TableKeyField,ParentKeyField,ConditionField,ConditionValue
					FROM  DataPurge_DeleteTransactionSourceDB WHERE ModuleId=@Pi_ModuleId ORDER BY Slno
					OPEN Cur_Tablename
					FETCH NEXT  FROM Cur_Tablename INTO @TableName,@ParentTable,@DateFieldName,@TableKeyField,
					@ParentKeyField,@ConditionField,@ConditionValue
					WHILE @@FETCH_STATUS=0
					BEGIN
							
							SET @Ssql=''
							SET @ColumnNames=''
							SET @ColumnNames1=''
							
							IF @Pi_ModuleId=12
							BEGIN
								IF	@ParentTable<>'SalesInvoiceQPSCumulative'
								BEGIN							
									SET @ParentTable='SalesInvoice'
								END		
							END
							IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name=@TableName)
							BEGIN
																					
								IF @TableName='VehicleAllocationMaster'
								BEGIN
										
										SELECT DISTINCT A.* INTO #VehicleAllocationMaster FROM VehicleAllocationMaster A 
										INNER JOIN VehicleAllocationDetails B ON A.AllotmentNumber=B.AllotmentNumber
										--INNER JOIN #SalesInvoice S ON S.DCNo=B.SaleInvNo										
										
										SELECT AllotmentNumber FROM #VehicleAllocationMaster 
										SET @Ssql='DELETE FROM '+@TableName+' WHERE AllotmentNumber IN('+
										' SELECT AllotmentNumber FROM #VehicleAllocationMaster  )'
										PRINT @Ssql
										EXEC(@Ssql)
								END
								IF (@TableName='CreditNoteRetailer') --Added By Sathishkumar Veeramani 2013/03/22
								BEGIN
										SET @Ssql='DELETE FROM '+@TableName+' WHERE (Amount-CrAdjAmount)> 0'
										PRINT @Ssql
										EXEC(@Ssql)
								END
								IF (@TableName='DebitNoteRetailer')
								BEGIN
										SET @Ssql='DELETE FROM '+@TableName+' WHERE (Amount-DbAdjAmount)> 0'
										PRINT @Ssql
										EXEC(@Ssql)
								END
								IF NOT EXISTS (SELECT * FROM #PurgCRDRVehicle WHERE Tablename = @TableName) --Till Here	
								BEGIN			
										IF UPPER(@TableName)=UPPER(@ParentTable)
										BEGIN
											
												SET @Ssql='DELETE FROM '+@TableName+		
												' WHERE '+Quotename(@DateFieldName)+'>='+''''+CONVERT(VARCHAR(10),@Pi_AsOndate,121)+''''
												
												IF LEN(LTRIM(RTRIM(@ConditionField)))>0
												BEGIN
													SET @Ssql=@Ssql+ ' AND '+Quotename(@ConditionField)+' IN ('+@ConditionValue+')'
												END
										
											PRINT @Ssql
											EXEC(@Ssql)
										END
										ELSE
										BEGIN
											
											SET @Ssql=' DELETE A FROM '+@TableName+' A '+
											' INNER JOIN '+ @ParentTable+' B  ON A.'+Quotename(@TableKeyField)+'=B.'+Quotename(@ParentKeyField)+
											' WHERE B.'+Quotename(@DateFieldName)+'>='+''''+CONVERT(VARCHAR(10),@Pi_AsOndate,121)+''''
											IF LEN(LTRIM(RTRIM(@ConditionField)))>0
											BEGIN
												SET @Ssql=@Ssql+ ' AND B.'+Quotename(@ConditionField)+' IN ('+@ConditionValue+')'
											END
											PRINT @Ssql
											EXEC(@Ssql)
										END
								END										
							END	
					FETCH NEXT  FROM  Cur_Tablename INTO @TableName,@ParentTable,@DateFieldName,@TableKeyField,@ParentKeyField
								,@ConditionField,@ConditionValue
					END
					CLOSE Cur_Tablename
					DEALLOCATE Cur_Tablename		
			
			END TRY
			BEGIN CATCH
				SELECT @@ERROR
				SET @Pi_Error=1
				CLOSE Cur_Tablename
				DEALLOCATE Cur_Tablename	
			END CATCH

END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_PurgeClaimData')
DROP PROCEDURE Proc_PurgeClaimData
GO
/*

begin tran
 EXEC Proc_PurgeClaimData 'GCPL_CN_CRDT201711',0
rollback tran

*/
CREATE PROCEDURE [Proc_PurgeClaimData] 
(
	
	@Pi_PurgeDb		Varchar(100),
	@Pi_Error		TinyInt OUTPUT
)
AS 
SET NOCOUNT ON
/***************************************************************************************************
* PROCEDURE		: Proc_PurgeClaimData
* PURPOSE		: To Insert Transaction details from base database to purge database
* NOTES			:
* CREATED		: Murugan.R
* CREATED ON	: 2012-09-06
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
****************************************************************************************************/
BEGIN
SET @Pi_Error=0

DECLARE @Ssql AS VARCHAR(8000)
DECLARE @ColumnNames AS VARCHAR(8000)
DECLARE @ColumnNames1 AS VARCHAR(8000)
DECLARE @TableName AS VARCHAR(100)	
SET @ColumnNames=''
SET @ColumnNames1=''
SET @Ssql=''

CREATE TABLE #ClaimTable
(
	TableName Varchar(100)	
)
INSERT INTO #ClaimTable
SELECT 'ClaimSheetHd' UNION ALL
SELECT 'ClaimSheetInvoiceWiseDetails' UNION ALL
----SELECT 'DamageClaimDetail' UNION ALL
----SELECT 'DamageClaimhd' UNION ALL
SELECT 'ClaimSheetDetail' 


CREATE Table #Claim
(
	ClmId BIGINT
)


SET @Ssql ='INSERT INTO #Claim(ClmId) '+
'SELECT DISTINCT SchclmId FROM( '+
'Select Distinct SchclmId from '+Quotename(@Pi_PurgeDb)+'..SalesInvoiceSchemeLinewise WHERE SchclmId>0 UNION ALL '+
'Select Distinct SchclmId from '+Quotename(@Pi_PurgeDb)+'..SalesInvoiceSchemeDtFreePrd WHERE SchclmId>0 UNION ALL '+
'Select Distinct SchclmId from '+Quotename(@Pi_PurgeDb)+'..ReturnSchemeLineDt WHERE SchclmId>0 UNION ALL '+
'Select Distinct SchclmId from '+Quotename(@Pi_PurgeDb)+'..ReturnSchemeFreePrdDt WHERE SchclmId>0 UNION ALL '+
'Select Distinct SchclmId from '+Quotename(@Pi_PurgeDb)+'..SalesInvoiceWindowDisplay WHERE SchclmId>0 UNION ALL  '+
'Select Distinct SchclmId from '+Quotename(@Pi_PurgeDb)+'..ChequeDisbursalMaster WHERE SchclmId>0 UNION ALL '+
--'Select Distinct Clmid as SchclmId from '+Quotename(@Pi_PurgeDb)+'..DamageClaimhd WHERE Status= ''Approved'' UNION ALL '+
'Select Distinct SchClmId as SchclmId from '+Quotename(@Pi_PurgeDb)+'..SalesInvoiceWindowDisplay WHERE SchClmId>0 UNION ALL '+
'Select Distinct SchClmId as SchclmId from '+Quotename(@Pi_PurgeDb)+'..ChequeDisbursalMaster WHERE SchClmId>0 )X'

EXEC(@Ssql)

SET @Ssql=''
	BEGIN TRY
		
		
		DECLARE @@TableName VARCHAR(100)
		DECLARE Cur_Tablename CURSOR
		FOR SELECT TableName
		FROM  #ClaimTable 
		OPEN Cur_Tablename
		FETCH NEXT  FROM Cur_Tablename INTO @TableName
		WHILE @@FETCH_STATUS=0
		BEGIN
								
								SET @Ssql=''
								SET @ColumnNames=''
								SET @ColumnNames1=''
								
								
								IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name=@TableName)
								BEGIN
									
									SELECT @ColumnNames=@ColumnNames+'A.'+Quotename(B.NAME)+',' 
									FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id
									WHERE A.name=@TableName Order by B.colid
									SET @ColumnNames=SUBSTRING(@ColumnNames,1,LEN(@ColumnNames)-1)
									
									SELECT @ColumnNames1=@ColumnNames1+Quotename(B.NAME)+',' 
									FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id
									WHERE A.name=@TableName Order by B.colid
									SET @ColumnNames1=SUBSTRING(@ColumnNames1,1,LEN(@ColumnNames1)-1)
						
												
												SET @Ssql='DELETE A FROM '+Quotename(@Pi_PurgeDb)+'..'+@TableName+' A INNER JOIN #Claim B ON A.ClmId=B.ClmId'+		
												' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..'+@TableName+'('+@ColumnNames1+')'+
												' SELECT '+@ColumnNames+' FROM '+@TableName+' A (NOLOCK)'+
												' INNER JOIN #Claim B ON A.ClmId=B.ClmId'
												
												print @Ssql
												EXEC(@Ssql)
												
												SET @Ssql='DELETE A FROM '+@TableName+' A INNER JOIN #Claim B ON A.ClmId=B.ClmId'
												print @Ssql
												EXEC(@Ssql)							
								END	
						FETCH NEXT  FROM  Cur_Tablename INTO @TableName
						END
						CLOSE Cur_Tablename
						DEALLOCATE Cur_Tablename
						
					
		END TRY
		BEGIN CATCH
			
			SET @Pi_Error=1
			SELECT @Pi_Error
			SELECT ERROR_MESSAGE()
		END CATCH								
			

END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DataPurgeDetails')
BEGIN
	CREATE TABLE DataPurgeDetails
	(
		PurgeDate DATETIME,
		PurgeDBName Varchar(50),
		CloneDBName Varchar(50),
		CreatedDate DATETIME		
	)	
END
GO
--Change SP In Datapurging tool
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_PurgeDateValidation')
DROP PROCEDURE Proc_PurgeDateValidation
GO
--EXEC Proc_PurgeDateValidation '2012-09-22',''
CREATE PROCEDURE Proc_PurgeDateValidation
(
	@Pi_Purgedate AS DATETIME,
	@Pi_SystemPurgeDate AS DATETIME OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PurgeDateValidation
* PURPOSE	: To Validate Purge Date
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON
SELECT @Pi_SystemPurgeDate=ISNULL(MIN(SchValidFrom),@Pi_Purgedate)FROM (
SELECT Schid,SchValidFrom
FROM SchemeMaster WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom and SchValidTill
AND SchStatus=1 and Claimable=1 AND FBM = 0 UNION ALL
SELECT Schid,SchValidFrom 
FROM SchemeMaster WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom and SchValidTill AND FBM = 1)X

SELECT @Pi_SystemPurgeDate
RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_PurgeOpeningStockAdjustment')
DROP PROCEDURE Proc_PurgeOpeningStockAdjustment
GO
--EXEC Proc_PurgeOpeningStockAdjustment '2012-07-01',	0
CREATE    PROCEDURE [Proc_PurgeOpeningStockAdjustment]
(
@Pi_TransDate DATETIME,
@Pi_OpenStockError TinyInt OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PurgeOpeningStockAdjustment
* PURPOSE	: To Add Opening Stock
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON

			SET @Pi_OpenStockError=0
			RETURN
			BEGIN TRY
						
			SELECT LcnId,PrdId,Prdbatid,MAX(Transdate) as Transdate
			INTO #Stock
			FROM StockLedger where Transdate between '1999-01-30' and CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121)
			GROUP BY  LcnId,Prdbatid,PrdId
			
			--DROP TABLE #Productbatch
			
			CREATE TABLE #StockManagementProduct(
			[PrdId] [int] NOT NULL,
			[PrdBatId] [int] NOT NULL,
			[StockTypeId] [int] NOT NULL,
			[UOMId1] [int] NOT NULL,
			[Qty1] [int] NOT NULL,
			[UOMId2] [int] NULL,
			[Qty2] [int] NULL,
			[TotalQty] [int] NOT NULL,
			[Rate] [numeric](18, 6) NOT NULL,
			[Amount] [numeric](18, 6) NOT NULL,
			[ReasonId] [int] NULL,
			[PriceId] [bigint] NOT NULL,
			[Availability] [tinyint] NOT NULL,
			[LastModBy] [tinyint] NOT NULL,
			[LastModDate] [datetime] NOT NULL,
			[AuthId] [tinyint] NOT NULL,
			[AuthDate] [datetime] NOT NULL,
			[TaxAmt] [numeric](18, 6) NULL,
			[LcnId] INT			
			) 
			SELECT Prdid,PB.Prdbatid,PriceId,PrdBatDetailValue Into #Productbatch FROM 
			BatchCreation B
			INNER JOIN  ProductBatch PB ON  B.BatchSeqId=PB.BatchSeqId
			INNER JOIN ProductBatchDetails PD ON 
			PB.PrdBatId=PD.PrdBatId and PB.DefaultPriceId=PD.PriceId
			and B.SlNo=PD.SLNo
			WHERE DefaultPrice=1 and ListPrice=1
		
			--Saleable OpenIng Stock Adjustment	
			INSERT INTO #StockManagementProduct(PrdId,PrdBatId,StockTypeId,
			UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,TaxAmt,LcnId)
			SELECT S.PrdId,S.PrdBatId,ST1.StockTypeId
			,1 as UOMId1,ABS(SalClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(SalClsStock) as TotalQty,
			PrdBatDetailValue as Rate,ABS(SalClsStock)*PrdBatDetailValue as Amount
			,ReasonId,PriceId, 
			9 as Availability,9 as LastModBy,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as LastModDate,9  as AuthId,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as AuthDate,0 as TaxAmt,L.Lcnid				
			FROM StockLedger S INNER JOIN #Stock ST ON S.PrdId=ST.PrdId and S.PrdBatId=St.PrdBatId
			and S.LcnId=ST.LcnId and S.TransDate=St.Transdate
			INNER JOIN StockType ST1 ON ST1.LcnId=S.LcnId and ST1.LcnId=ST.LcnId 
			INNER JOIN Location L ON S.LcnId=ST.LcnId and L.LcnId=ST.LcnId and L.LcnId=ST1.LcnId
			INNER JOIN #Productbatch PB ON PB.PrdId=S.Prdid and PB.PrdBatId=S.PrdBatId and Pb.PrdId=St.PrdId
			and PB.PrdBatId=St.PrdBatId
			CROSS JOIN ReasonMaster
			WHERE SalClsStock>0 and SystemStockType=1 and  ReasonCode='OS'
			
			--UnSaleable OpenIng Stock Adjustment	
			INSERT INTO #StockManagementProduct(PrdId,PrdBatId,StockTypeId,
			UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,TaxAmt,LcnId)
			SELECT S.PrdId,S.PrdBatId,ST1.StockTypeId
			,1 as UOMId1,ABS(UnSalClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(UnSalClsStock) as TotalQty,
			PrdBatDetailValue as Rate,ABS(UnSalClsStock)*PrdBatDetailValue as Amount
			,ReasonId,PriceId, 
			9 as Availability,9 as LastModBy,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as LastModDate,9  as AuthId,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as AuthDate,0 as TaxAmt,L.Lcnid					
			FROM StockLedger S INNER JOIN #Stock ST ON S.PrdId=ST.PrdId and S.PrdBatId=St.PrdBatId
			and S.LcnId=ST.LcnId and S.TransDate=St.Transdate
			INNER JOIN StockType ST1 ON ST1.LcnId=S.LcnId and ST1.LcnId=ST.LcnId 
			INNER JOIN Location L ON S.LcnId=ST.LcnId and L.LcnId=ST.LcnId and L.LcnId=ST1.LcnId
			INNER JOIN #Productbatch PB ON PB.PrdId=S.Prdid and PB.PrdBatId=S.PrdBatId and Pb.PrdId=St.PrdId
			and PB.PrdBatId=St.PrdBatId
			CROSS JOIN ReasonMaster
			WHERE UnSalClsStock>0 and SystemStockType=2 and  ReasonCode='OS'
			
			----Offer OpenIng Stock Adjustment	
			INSERT INTO #StockManagementProduct(PrdId,PrdBatId,StockTypeId,
			UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,TaxAmt,LcnId)
			SELECT S.PrdId,S.PrdBatId,ST1.StockTypeId
			,1 as UOMId1,ABS(OfferClsStock) as Qty1,0 as UOMId2,0 as Qty2,ABS(OfferClsStock) as TotalQty,
			0 as Rate,0 as Amount
			,ReasonId,PriceId, 
			9 as Availability,9 as LastModBy,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as LastModDate,9  as AuthId,
			CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121) as AuthDate,0 as TaxAmt,L.Lcnid					
			FROM StockLedger S INNER JOIN #Stock ST ON S.PrdId=ST.PrdId and S.PrdBatId=St.PrdBatId
			and S.LcnId=ST.LcnId and S.TransDate=St.Transdate
			INNER JOIN StockType ST1 ON ST1.LcnId=S.LcnId and ST1.LcnId=ST.LcnId 
			INNER JOIN Location L ON S.LcnId=ST.LcnId and L.LcnId=ST.LcnId and L.LcnId=ST1.LcnId
			INNER JOIN #Productbatch PB ON PB.PrdId=S.Prdid and PB.PrdBatId=S.PrdBatId and Pb.PrdId=St.PrdId
			and PB.PrdBatId=St.PrdBatId
			CROSS JOIN ReasonMaster
			WHERE OfferClsStock>0 and SystemStockType=2 and  ReasonCode='OS'
			
			
			DECLARE @Vocdate as DateTime
			DECLARE @Lcnid AS INT
			DECLARE CUR_STOCKADJ CURSOR
			FOR  (SELECT DISTINCT LcnId FROM #StockManagementProduct)
			OPEN CUR_STOCKADJ		
			FETCH NEXT FROM CUR_STOCKADJ INTO @LcnId			
			WHILE @@FETCH_STATUS = 0
			BEGIN	
			DECLARE @GetKeyStr AS VARCHAR(50)
			DECLARE @CurrValue AS BIGINT 
			DECLARE @Zpad AS INT
			
			SELECT @CurrValue=ISNULL(CurrValue,0),@Zpad=ISNULL(ZPad,0) FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			
			IF @CurrValue=99  AND @Zpad=2 
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=999  AND @Zpad=3
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END 
			ELSE IF @CurrValue=9999 AND @Zpad=4
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=99999 AND @Zpad=5
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=999999  AND @Zpad=6
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=9999999  AND @Zpad=7
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=99999999  AND @Zpad=8
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			ELSE IF @CurrValue=999999999  AND @Zpad=9
			BEGIN
				UPDATE Counters SET Zpad=Zpad+1 FROM Counters WHERE TabName ='StockManagement' AND FldName ='StkMngRefNo'
			END
			SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('StockManagement','StkMngRefNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			
			

				IF LEN(LTRIM(RTRIM(@GetKeyStr)))>0
				BEGIN
					BEGIN TRANSACTION
					
					INSERT INTO PurgeStockManagement (StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,DecPoints,OpenBal,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate,ConfigValue,XMLUpload,VatGst)
					SELECT @GetKeyStr,CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121),
					@LcnId,1,0,0,'','Openign Stock for Data Purging',5,0,1,1,1,@Pi_TransDate,99,@Pi_TransDate,0,0,'GST'
					
					INSERT INTO PurgeStockManagementProduct (StkMngRefNo,PrdId,PrdBatId,StockTypeId,UOMId1,Qty1,
					UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
					LastModDate,AuthId,AuthDate,TaxAmt,PrdSlNo)
					SELECT @GetKeyStr,PrdId,PrdBatId,StockTypeId,
					UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,
					LastModDate,AuthId,AuthDate,TaxAmt,ROW_NUMBER() OVER(Order by Prdid,PrdbatId,StockTypeId) 
					FROM #StockManagementProduct WHERE Lcnid=@LcnId
					
					SET @VocDate =CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(DAY,-1,@Pi_TransDate),121),121)
					
					EXEC Proc_VoucherPosting 13,1,@GetKeyStr,5,0,2,@VocDate,0
					
					UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='StockManagement'
					COMMIT TRANSACTION
				END		
			FETCH NEXT FROM CUR_STOCKADJ INTO @LcnId		
			END
			CLOSE CUR_STOCKADJ
			DEALLOCATE CUR_STOCKADJ
				
			END TRY
			BEGIN CATCH
				SET @Pi_OpenStockError=1
			END CATCH			
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_DataPurgeRecreateStock')
DROP PROCEDURE Proc_DataPurgeRecreateStock
GO
-- EXEC Proc_DataPurgeRecreateStock 4,7,'2012-07-01',0
CREATE PROCEDURE Proc_DataPurgeRecreateStock
(
	@Pi_StkTransdate AS DATETIME,
	@Pi_StockError AS TinyINT OUTPUT
)	
AS
/*********************************
* PROCEDURE	: Proc_DataPurgeRecreateStock
* PURPOSE	: To Recreate Stock
* CREATED	: Murugan.R
* CREATED DATE	: 18/02/2010
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	SET @Pi_StockError=0
	RETURN
	BEGIN TRY
	--To Move the stock record which has transaction above PurgeDate
	CREATE TABLE #StockAbovePurgeDate
	(
		PrdID		INT,
		PrdBatid	INT,
		LcnID		TINYINT
	)
	
	INSERT INTO #StockAbovePurgeDate
	SELECT DISTINCT PrdId,PrdBatID,LcnId FROM Stockledger (NOLOCK) WHERE TransDate >=@Pi_StkTransdate
	INSERT INTO PurgeStockledger
	(TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,
	SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
	OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
	OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,
	Availability,LastModBy,LastModDate,AuthId,AuthDate--,UploadFlag1,UploadFlag2 --(CCRSTBO009)
	)
	SELECT TransDate,A.LcnId,A.PrdId,A.PrdBatId,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,
	SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
	OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
	OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,
	Availability,LastModBy,LastModDate,AuthId,AuthDate--,UploadFlag1,UploadFlag2 --(CCRSTBO009) 
	FROM Stockledger A (NOLOCK) 
	INNER JOIN #StockAbovePurgeDate B ON A.PrdID=B.PrdID AND A.PrdBatID=B.PrdBatID AND A.LcnID=B.LcnID
	WHERE TransDate >=@Pi_StkTransdate
	
	--To Move Stock which has transaction below Purge Date
	CREATE TABLE #StockBelowPurgeDate
	(
		PrdID		INT,
		PrdBatid	INT,
		LcnID		TINYINT
	)
	
	INSERT INTO #StockBelowPurgeDate
	SELECT * FROM 
	(SELECT DISTINCT PrdId,PrdBatID,LcnId FROM Stockledger (NOLOCK)) A  WHERE NOT EXISTS (SELECT * FROM #StockAbovePurgeDate B 
	WHERE CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatID AS NVARCHAR(10))+'~'+CAST(A.LcnId AS NVARCHAR(10))=
	CAST(B.PrdID AS NVARCHAR(10))+'~'+CAST(B.PrdBatid AS NVARCHAR(10))+'~'+CAST(B.LcnID AS NVARCHAR(10)))
	
	--SELECT * FROM 
	--(SELECT DISTINCT PrdId,PrdBatID,LcnId FROM Stockledger (NOLOCK)) A  WHERE CAST(A.PrdId AS NVARCHAR(10))+CAST(A.PrdBatID AS NVARCHAR(10))+CAST(A.LcnId AS NVARCHAR(10)) NOT IN
	--(SELECT CAST(PrdId AS NVARCHAR(10))+CAST(PrdBatID AS NVARCHAR(10))+CAST(LcnId AS NVARCHAR(10)) FROM #StockAbovePurgeDate)
	
	IF EXISTS (SELECT * FROM #StockBelowPurgeDate)
	BEGIN
		CREATE TABLE #StockBelowPurgeDateWithDate
		(
			PrdID		INT,
			PrdBatid	INT,
			LcnID		TINYINT,
			TransDate	DATETIME
		)
		INSERT INTO #StockBelowPurgeDateWithDate
		SELECT A.PrdId,A.PrdBatId,A.LcnId,MAX(TransDate) TransDate FROM Stockledger A (NOLOCK)
		INNER JOIN #StockBelowPurgeDate B ON A.PrdId=B.PrdID AND A.PrdBatID=B.PrdBatid AND A.LcnId=B.LcnID GROUP BY A.PrdId,A.PrdBatId,A.LcnId
		
		INSERT INTO PurgeStockledger
		(TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,
		SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
		OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
		OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,
		Availability,LastModBy,LastModDate,AuthId,AuthDate--,UploadFlag1,UploadFlag2 --(CCRSTBO009)
		)
		SELECT @Pi_StkTransdate,A.LcnId,A.PrdId,A.PrdBatId,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,
		SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
		OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
		OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,
		Availability,LastModBy,LastModDate,AuthId,AuthDate--,UploadFlag1,UploadFlag2 --(CCRSTBO009)
		FROM Stockledger A (NOLOCK) 
		INNER JOIN #StockBelowPurgeDateWithDate B ON A.PrdID=B.PrdID AND A.PrdBatID=B.PrdBatID AND A.LcnID=B.LcnID AND A.TransDate=B.TransDate 
	END
	
	INSERT INTO PurgeProductBatchLocation
	(PrdId,PrdBatID,LcnId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,PrdBatLcnResUih,PrdBatLcnResFre,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT PrdId,PrdBatID,LcnId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,PrdBatLcnResUih,PrdBatLcnResFre,Availability,LastModBy,LastModDate,AuthId,AuthDate
	FROM ProductBatchLocation
	
	END TRY
	--
	BEGIN CATCH
	--ROLLBACK TRANSACTION
	SET @Pi_StockError=1
	END CATCH
END
GO

IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_PurgeStockAdujsmentProcess')
DROP PROCEDURE Proc_PurgeStockAdujsmentProcess
GO
/*
BEGIN TRAN
EXEC Proc_PurgeStockAdujsmentProcess 5297,8603,'2017-01-01',0
ROLLBACK TRAN
*/
CREATE    PROCEDURE [Proc_PurgeStockAdujsmentProcess]
(
	@PrdId AS INT,
	@PrdbatId AS INT,	
	@Pi_FromDate AS DATETIME,
	@Pi_AdjProcessError AS TinyInt OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PurgeStockAdujsmentProcess
* PURPOSE	: To Adjust negative Stock
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @SlNo AS INT
	DECLARE @Pi_StkError AS TinyInt
	DECLARE @Pi_AdjStkError AS TinyInt
	SET @SlNo=1	
	SET @Pi_AdjProcessError=0
RETURN
BEGIN TRY	
		WHILE @SlNo<25
		BEGIN
			IF EXISTS(SELECT * FROM StockmismatchProducts  WHERE StockAdjusted=0 and Prdid=@PrdId and Prdbatid=@PrdBatId) 
			BEGIN
				--EXEC Proc_DataPurgeRecreateStock @PrdId,@PrdBatId,@Pi_FromDate,@Pi_StockError=@Pi_StkError OUTPUT
				EXEC Proc_DataPurgeRecreateStock @Pi_FromDate,@Pi_StockError=@Pi_StkError OUTPUT
				IF @Pi_StkError=0
				BEGIN
					EXEC Proc_PurgeManualStockAdjusment @PrdId,@PrdBatId,@Pi_AdjError=@Pi_AdjStkError OUTPUT
				END	
				
			END		
			SET @SlNo=@SlNo+1
		END
		SET @SlNo=1
END TRY
BEGIN CATCH
	SET @Pi_AdjProcessError=1
END  CATCH		
END
GO



IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_DataPurgeStockTransfer')
DROP PROCEDURE Proc_DataPurgeStockTransfer
GO
--EXEC Proc_DataPurgeStockTransfer 'GCPL_CN_CRDT201711',0
CREATE PROCEDURE Proc_DataPurgeStockTransfer
(
	@Pi_PurgeDb as Varchar(100),	
	@Pi_Error as TinyInt OUTPUT	
)
AS
/*********************************
* PROCEDURE	: Proc_DataPurgeStockTransfer
* PURPOSE	: To Transfer Stock  SourceDb To PurgeDb 
* CREATED	: Murugan.R
* CREATED DATE	: 04/07/2012
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	SET @Pi_Error=0
	RETURN 
	DECLARE @ColumnNames VARCHAR(MAX)
	DECLARE @ColumnNames1 VARCHAR(MAX)
	DECLARE @Ssql VARCHAR(MAX)
	SET @Ssql=''
	SET @ColumnNames=''
	SET @ColumnNames1=''
	
	--SELECT @ColumnNames=@ColumnNames+'A.'+Quotename(B.NAME)+',' 
	--FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id
	--WHERE A.name='StockLedger' Order by B.colid
	
	--SET @ColumnNames=SUBSTRING(@ColumnNames,1,LEN(@ColumnNames)-1)

	SELECT @ColumnNames1=@ColumnNames1+Quotename(B.NAME)+',' 
	FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id
	WHERE A.name='StockLedger' Order by B.colid
	
	SET @ColumnNames1=SUBSTRING(@ColumnNames1,1,LEN(@ColumnNames1)-1)
	
	BEGIN TRY
		--BEGIN TRANSACTION
	
			SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..Stockledger'+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..Stockledger'+'('+@ColumnNames1+')'+
			' SELECT '+@ColumnNames1+' FROM PurgeStockLedger  (NOLOCK)'
			PRINT @Ssql
			EXEC(@Ssql)
			

			
			SET @Ssql='DELETE FROM '+Quotename(@Pi_PurgeDb)+'..Productbatchlocation'+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..Productbatchlocation(PrdId,PrdBatID,LcnId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,'+
			'PrdBatLcnResUih,PrdBatLcnResFre,Availability,LastModBy,LastModDate,AuthId,AuthDate)'+
			' SELECT DISTINCT PrdId,PrdBatID,LcnId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,'+
			' PrdBatLcnResUih,PrdBatLcnResFre,1 as Availability,1 as LastModBy,LastModDate,1 as AuthId,AuthDate FROM PurgeProductBatchLocation A (NOLOCK)'
			PRINT @Ssql
			EXEC(@Ssql)
			
			--StockAdjustment
			SET @Ssql='DELETE A FROM '+Quotename(@Pi_PurgeDb)+'..StockManagement A WHERE EXISTS(SELECT StkMngRefNo FROM PurgeStockManagement B (NOLOCK) WHERE A.StkMngRefNo=B.StkMngRefNo)'+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..StockManagement(StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,'+
			'Remarks,DecPoints,OpenBal,Status,Availability,LastModBy,LastModDate,'+
			'AuthId,AuthDate,ConfigValue,XMLUpload,VatGst)'+
			' SELECT StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,'+
			'Remarks,DecPoints,OpenBal,Status,Availability,LastModBy,LastModDate,'+
			'AuthId,AuthDate,ConfigValue,XMLUpload,VatGst FROM PurgeStockManagement (NOLOCK)'
			PRINT @Ssql
			EXEC(@Ssql)
			
			--StockAdjustmentProduct
			SET @Ssql='DELETE A FROM '+Quotename(@Pi_PurgeDb)+'..StockManagementProduct A WHERE EXISTS(SELECT StkMngRefNo FROM PurgeStockManagement B (NOLOCK) WHERE A.StkMngRefNo=B.StkMngRefNo)'+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..StockManagementProduct(StkMngRefNo,PrdId,PrdBatId,StockTypeId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,'+
			'Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,AuthId,'+
			'AuthDate,TaxAmt)'+
			' SELECT StkMngRefNo,PrdId,PrdBatId,StockTypeId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,'+
			'Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,AuthId,'+
			'AuthDate,TaxAmt FROM PurgeStockManagementProduct (NOLOCK)'
			PRINT @Ssql
			EXEC(@Ssql)
			
			--Standard Voucher
			SET @Ssql='DELETE A FROM '+Quotename(@Pi_PurgeDb)+'..StdVocMaster A INNER JOIN  PurgeStockManagement B ON LTRIM(RTRIM(SUBSTRING(A.Remarks,29,CHARINDEX('' Dated'',A.Remarks)-29)))=StkMngRefNo WHERE A.Remarks like ''Posted From Stock Adjustment%'''+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,VocSubType,AutoGen,'+
			'YEEntry,Availability,LastModBy,LastModDate,AuthId,AuthDate)'+
			' SELECT DISTINCT VocRefNo,AcmId,AcpId,VocType,VocDate,A.Remarks,VocSubType,AutoGen,'+
			'YEEntry,A.Availability,A.LastModBy,A.LastModDate,A.AuthId,A.AuthDate FROM StdVocMaster A INNER JOIN  PurgeStockManagement B ON LTRIM(RTRIM(SUBSTRING(A.Remarks,29,CHARINDEX('' Dated'',A.Remarks)-29)))=StkMngRefNo WHERE A.Remarks like ''Posted From Stock Adjustment%'''
			PRINT @Ssql
			EXEC(@Ssql)
			
			SET @Ssql='DELETE B FROM '+Quotename(@Pi_PurgeDb)+'..StdVocMaster A INNER JOIN '+Quotename(@Pi_PurgeDb)+'..StdVocDetails B ON A.VocRefNo=B.VocRefNo INNER JOIN  PurgeStockManagement C ON LTRIM(RTRIM(SUBSTRING(A.Remarks,29,CHARINDEX('' Dated'',A.Remarks)-29)))=C.StkMngRefNo WHERE A.Remarks like ''Posted From Stock Adjustment%'''+		
			' INSERT INTO '+Quotename(@Pi_PurgeDb)+'..StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,LastModDate,AuthId,AuthDate)'+
			' SELECT DISTINCT B.VocRefNo,CoaId,DebitCredit,Amount,B.Availability,B.LastModBy,B.LastModDate,b.AuthId,b.AuthDate'+
			' FROM StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo INNER JOIN  PurgeStockManagement C ON LTRIM(RTRIM(SUBSTRING(A.Remarks,29,CHARINDEX('' Dated'',A.Remarks)-29)))=StkMngRefNo WHERE A.Remarks like ''Posted From Stock Adjustment%'''		
			--PRINT @Ssql
			EXEC(@Ssql)
			
			--COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--ROLLBACK TRANSACTION
		SET @Pi_Error=1	
		SELECT 	@Pi_Error
	END CATCH			
END
GO
