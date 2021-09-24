IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TaxSettingDetail_BillSeqId_TaxSeqId_ColType')
BEGIN
CREATE INDEX IX_TaxSettingDetail_BillSeqId_TaxSeqId_ColType ON dbo.TaxSettingDetail (BillSeqId, TaxSeqId,ColType) INCLUDE (RowId, ColNo, SlNo, ColId, ColVal)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_CmpSchCode')
BEGIN
CREATE INDEX IX_SchemeMaster_CmpSchCode ON dbo.SchemeMaster (CmpSchCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TaxSettingDetail_TaxSeqId_ColId')
BEGIN
CREATE INDEX IX_TaxSettingDetail_TaxSeqId_ColId ON dbo.TaxSettingDetail (TaxSeqId, ColId) INCLUDE (ColVal)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TaxSettingDetail_ColId')
BEGIN
CREATE INDEX IX_TaxSettingDetail_ColId ON dbo.TaxSettingDetail (ColId) INCLUDE (TaxSeqId, ColVal)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductCategoryValue_CmpPrdCtgId_PrdCtgValCode')
BEGIN
CREATE INDEX IX_ProductCategoryValue_CmpPrdCtgId_PrdCtgValCode ON dbo.ProductCategoryValue (CmpPrdCtgId, PrdCtgValCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_ContractId_PrdId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_ContractId_PrdId ON dbo.ContractPricingDetails (ContractId, PrdId) INCLUDE (PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductCategoryValue_PrdCtgValCode')
BEGIN
CREATE INDEX IX_ProductCategoryValue_PrdCtgValCode ON dbo.ProductCategoryValue (PrdCtgValCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeLineWise_SchId_Availability')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeLineWise_SchId_Availability ON dbo.SalesInvoiceSchemeLineWise (SchId, Availability)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeDtBilled_SchId_Availability')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeDtBilled_SchId_Availability ON dbo.SalesInvoiceSchemeDtBilled (SchId, Availability)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeHd_SchId_Availability')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeHd_SchId_Availability ON dbo.SalesInvoiceSchemeHd (SchId, Availability)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductCategoryValue_CmpPrdCtgId_PrdCtgValCode')
BEGIN
CREATE INDEX IX_ProductCategoryValue_CmpPrdCtgId_PrdCtgValCode ON dbo.ProductCategoryValue (CmpPrdCtgId, PrdCtgValCode) INCLUDE (PrdCtgValMainId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_PrdId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_PrdId ON dbo.ContractPricingDetails (PrdId) INCLUDE (ContractId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TaxSettingDetail_TaxSeqId')
BEGIN
CREATE INDEX IX_TaxSettingDetail_TaxSeqId ON dbo.TaxSettingDetail (TaxSeqId) INCLUDE (RowId, ColNo, SlNo, BillSeqId, ColType, ColId, ColVal)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeLineWise_SchId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeLineWise_SchId ON dbo.SalesInvoiceSchemeLineWise (SchId) INCLUDE (PrdId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeLineWise_SchId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeLineWise_SchId ON dbo.SalesInvoiceSchemeLineWise (SchId) INCLUDE (SalId, FlatAmount, DiscountPerAmount, ReturnFlatAmount, ReturnDiscountPerAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeRuleSettings_SchId_EnableRtrLvl_NoOfRtr')
BEGIN
CREATE INDEX IX_SchemeRuleSettings_SchId_EnableRtrLvl_NoOfRtr ON dbo.SchemeRuleSettings (SchId, EnableRtrLvl, NoOfRtr)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeHd_SchId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeHd_SchId ON dbo.SalesInvoiceSchemeHd (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_MasterId')
BEGIN
CREATE INDEX IX_UdcDetails_MasterId ON dbo.UdcDetails (MasterId) INCLUDE (UdcMasterId, MasterRecordId, ColumnValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_ContractPricing_CmpId_CtgLevelId_CtgMainId_RtrClassId_CmpPrdCtgId_RtrId_EffectiveDate_RtrTaxGroupId_ComConRefNo')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_ContractPricing_CmpId_CtgLevelId_CtgMainId_RtrClassId_CmpPrdCtgId_RtrId_EffectiveDate_RtrTaxGroupId_ComConRefNo ON dbo.Cn2Cs_Prk_ContractPricing (CmpId, CtgLevelId, CtgMainId, RtrClassId, CmpPrdCtgId, RtrId, EffectiveDate, RtrTaxGroupId, ComConRefNo) INCLUDE (PrdCtgValMainId, PrdId, PrdBatId, PriceId, DiscountPerc, FlatAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdCCode')
BEGIN
CREATE INDEX IX_Product_PrdCCode ON dbo.Product (PrdCCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdStatus_PrdType')
BEGIN
CREATE INDEX IX_Product_PrdStatus_PrdType ON dbo.Product (PrdStatus,PrdType) INCLUDE (PrdId, PrdName, PrdDCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_SalInvDate_DlvSts ON dbo.SalesInvoice (RtrId,SalInvDate, DlvSts) INCLUDE (SalId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdStatus')
BEGIN
CREATE INDEX IX_Product_PrdStatus ON dbo.Product (PrdStatus) INCLUDE (PrdId, PrdCtgValMainId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_SLNo ON dbo.ProductBatchDetails (SLNo) INCLUDE (PriceId, PrdBatId, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_MasterId_MasterRecordId')
BEGIN
CREATE INDEX IX_UdcDetails_MasterId_MasterRecordId ON dbo.UdcDetails (MasterId, MasterRecordId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceModificationHistory_SalId')
BEGIN
CREATE INDEX IX_SalesInvoiceModificationHistory_SalId ON dbo.SalesInvoiceModificationHistory (SalId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_MasterRecordId')
BEGIN
CREATE INDEX IX_UdcDetails_MasterRecordId ON dbo.UdcDetails (MasterRecordId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceModificationHistory_SalId_VersionNo')
BEGIN
CREATE INDEX IX_SalesInvoiceModificationHistory_SalId_VersionNo ON dbo.SalesInvoiceModificationHistory (SalId, VersionNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (SalId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName ON dbo.WSMasterExportUploadTrack (ProcessName) INCLUDE (MasterCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchStatus_SchemeLvlMode_SchType_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchStatus_SchemeLvlMode_SchType_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchStatus, SchemeLvlMode,SchType, SchValidFrom, SchValidTill) INCLUDE (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_ContractId_PrdId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_ContractId_PrdId ON dbo.ContractPricingDetails (ContractId, PrdId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_CmpId_CmpSchCode')
BEGIN
CREATE INDEX IX_SchemeMaster_CmpId_CmpSchCode ON dbo.SchemeMaster (CmpId, CmpSchCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId ON dbo.SalesInvoice (RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdCCode')
BEGIN
CREATE INDEX IX_Product_PrdCCode ON dbo.Product (PrdCCode) INCLUDE (PrdId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_OrderBookingProducts_OrderNo')
BEGIN
CREATE INDEX IX_OrderBookingProducts_OrderNo ON dbo.OrderBookingProducts (OrderNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatch_Status')
BEGIN
CREATE INDEX IX_ProductBatch_Status ON dbo.ProductBatch (Status) INCLUDE (PrdId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_MasterRecordId')
BEGIN
CREATE INDEX IX_UdcDetails_MasterRecordId ON dbo.UdcDetails (MasterRecordId) INCLUDE (UdcMasterId, ColumnValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate,DlvSts)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PriceId_PrdBatId')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PriceId_PrdBatId ON dbo.ProductBatchDetails (PriceId, PrdBatId) INCLUDE (BatchSeqId, SLNo, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceiptMapping_CompInvNo_PrdCCode_PrdMapCode')
BEGIN
CREATE INDEX IX_PurchaseReceiptMapping_CompInvNo_PrdCCode_PrdMapCode ON dbo.PurchaseReceiptMapping (CompInvNo, PrdCCode, PrdMapCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName_MasterCode')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName_MasterCode ON dbo.WSMasterExportUploadTrack (ProcessName, MasterCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PriceId_PrdBatId_DefaultPrice')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PriceId_PrdBatId_DefaultPrice ON dbo.ProductBatchDetails (PriceId, PrdBatId, DefaultPrice) INCLUDE (BatchSeqId, SLNo, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PrdBatId_DefaultPrice')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PrdBatId_DefaultPrice ON dbo.ProductBatchDetails (PrdBatId, DefaultPrice) INCLUDE (PriceId, BatchSeqId, SLNo, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeProducts_PrdId_Availability')
BEGIN
CREATE INDEX IX_SchemeProducts_PrdId_Availability ON dbo.SchemeProducts (PrdId, Availability)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdType')
BEGIN
CREATE INDEX IX_Product_PrdType ON dbo.Product (PrdType) INCLUDE (PrdCCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdStatus')
BEGIN
CREATE INDEX IX_Product_PrdStatus ON dbo.Product (PrdStatus) INCLUDE (PrdDCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_Availability_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_Availability_DlvSts ON dbo.SalesInvoice (RtrId, Availability,DlvSts) INCLUDE (SalInvNo, SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_Availability_SalInvNo_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_Availability_SalInvNo_DlvSts ON dbo.SalesInvoice (RtrId, Availability,SalInvNo, DlvSts) INCLUDE (SalInvDate, SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_Availability_SalInvNo_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_Availability_SalInvNo_DlvSts ON dbo.SalesInvoice (RtrId, Availability,SalInvNo, DlvSts) INCLUDE (SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_DlvSts ON dbo.SalesInvoice (RtrId, DlvSts) INCLUDE (SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_DlvSts ON dbo.SalesInvoice (RtrId, DlvSts) INCLUDE (SalNetAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_OrderBookingProducts_OrderNo_PrdId')
BEGIN
CREATE INDEX IX_OrderBookingProducts_OrderNo_PrdId ON dbo.OrderBookingProducts (OrderNo, PrdId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_BillBookNo')
BEGIN
CREATE INDEX IX_SalesInvoice_BillBookNo ON dbo.SalesInvoice (BillBookNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceModificationHistory_SalId_TransactionFlag')
BEGIN
CREATE INDEX IX_SalesInvoiceModificationHistory_SalId_TransactionFlag ON dbo.SalesInvoiceModificationHistory (SalId,TransactionFlag)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_QPS_SchStatus_ApyQPSSch_SchemeLvlMode_SchType')
BEGIN
CREATE INDEX IX_SchemeMaster_QPS_SchStatus_ApyQPSSch_SchemeLvlMode_SchType ON dbo.SchemeMaster (QPS, SchStatus, ApyQPSSch, SchemeLvlMode,SchType) INCLUDE (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceiptProduct_PrdId_PrdBatId')
BEGIN
CREATE INDEX IX_PurchaseReceiptProduct_PrdId_PrdBatId ON dbo.PurchaseReceiptProduct (PrdId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_UDCUniqueId')
BEGIN
CREATE INDEX IX_UdcDetails_UDCUniqueId ON dbo.UdcDetails (UDCUniqueId) INCLUDE (MasterRecordId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceipt_CmpInvNo')
BEGIN
CREATE INDEX IX_PurchaseReceipt_CmpInvNo ON dbo.PurchaseReceipt (CmpInvNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_UdcMasterId_MasterId')
BEGIN
CREATE INDEX IX_UdcDetails_UdcMasterId_MasterId ON dbo.UdcDetails (UdcMasterId, MasterId) INCLUDE (MasterRecordId, ColumnValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatch_PrdBatCode')
BEGIN
CREATE INDEX IX_ProductBatch_PrdBatCode ON dbo.ProductBatch (PrdBatCode) INCLUDE (PrdId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_CmpSchCode')
BEGIN
CREATE INDEX IX_SchemeMaster_CmpSchCode ON dbo.SchemeMaster (CmpSchCode) INCLUDE (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_Availability')
BEGIN
CREATE INDEX IX_SalesInvoice_Availability ON dbo.SalesInvoice (Availability) INCLUDE (SalId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PrdBatId_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PrdBatId_SLNo ON dbo.ProductBatchDetails (PrdBatId, SLNo) INCLUDE (BatchSeqId, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_SalInvDate_DlvSts ON dbo.SalesInvoice (RtrId,SalInvDate, DlvSts) INCLUDE (SalGrossAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PriceId_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PriceId_SLNo ON dbo.ProductBatchDetails (PriceId, SLNo) INCLUDE (PriceCode, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceipt_CmpInvNo_Status')
BEGIN
CREATE INDEX IX_PurchaseReceipt_CmpInvNo_Status ON dbo.PurchaseReceipt (CmpInvNo, Status)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_SLNo ON dbo.ProductBatchDetails (SLNo) INCLUDE (PrdBatId, BatchSeqId, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (RtrId, SalGrossAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_DlvSts ON dbo.SalesInvoice (RtrId,DlvSts)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_StockLedger_PrdId_Availability')
BEGIN
CREATE INDEX IX_StockLedger_PrdId_Availability ON dbo.StockLedger (PrdId, Availability)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CS2Console_Consolidated_ProcessName_SyncId')
BEGIN
CREATE INDEX IX_CS2Console_Consolidated_ProcessName_SyncId ON dbo.CS2Console_Consolidated (ProcessName,SyncId) INCLUDE (DistCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_ContractId_PrdId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_ContractId_PrdId ON dbo.ContractPricingDetails (ContractId, PrdId) INCLUDE (PrdBatId, PriceId, Discount, FlatAmtDisc, ClaimablePercOnMRP)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_Availability_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_Availability_DlvSts ON dbo.SalesInvoice (SMId, Availability,DlvSts) INCLUDE (SalInvNo, SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceipt_Status')
BEGIN
CREATE INDEX IX_PurchaseReceipt_Status ON dbo.PurchaseReceipt (Status) INCLUDE (CmpInvNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_SpecialDiscount_RetCategoryLevel')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_SpecialDiscount_RetCategoryLevel ON dbo.Cn2Cs_Prk_SpecialDiscount (RetCategoryLevel) INCLUDE (RetCatLevelValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_SLNo ON dbo.ProductBatchDetails (SLNo) INCLUDE (PriceId, PriceCode, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_VehicleAllocationDetails_SaleInvNo')
BEGIN
CREATE INDEX IX_VehicleAllocationDetails_SaleInvNo ON dbo.VehicleAllocationDetails (SaleInvNo) INCLUDE (AllotmentNumber)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PriceId_PrdBatId_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PriceId_PrdBatId_SLNo ON dbo.ProductBatchDetails (PriceId, PrdBatId, SLNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_StockLedger_TransDate')
BEGIN
CREATE INDEX IX_StockLedger_TransDate ON dbo.StockLedger (TransDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CS2Console_Consolidated_SyncId_ProcessName')
BEGIN
CREATE INDEX IX_CS2Console_Consolidated_SyncId_ProcessName ON dbo.CS2Console_Consolidated (SyncId, ProcessName) INCLUDE (DistCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_Availability_SalInvNo_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_Availability_SalInvNo_DlvSts ON dbo.SalesInvoice (SMId, Availability,SalInvNo, DlvSts) INCLUDE (SalInvDate, RtrId, SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CN2CS_Prk_ProductCodeUnification_DownLoadFlag')
BEGIN
CREATE INDEX IX_CN2CS_Prk_ProductCodeUnification_DownLoadFlag ON dbo.CN2CS_Prk_ProductCodeUnification (DownLoadFlag) INCLUDE (ProductCode, MapProductCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate,DlvSts) INCLUDE (SalGrossAmount, SalNetAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cs2Cn_Prk_DailyProductDetails_UploadFlag')
BEGIN
CREATE INDEX IX_Cs2Cn_Prk_DailyProductDetails_UploadFlag ON dbo.Cs2Cn_Prk_DailyProductDetails (UploadFlag)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RptUpload_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RptUpload_DlvSts ON dbo.SalesInvoice (RptUpload,DlvSts) INCLUDE (SalId, SalInvNo, SalInvDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_SLNo ON dbo.ProductBatchDetails (SLNo) INCLUDE (PriceId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceProduct_RateDiffClaimId')
BEGIN
CREATE INDEX IX_SalesInvoiceProduct_RateDiffClaimId ON dbo.SalesInvoiceProduct (RateDiffClaimId) INCLUDE (SalId, PrdId, PrdBatId, BaseQty, PrdUom1EditedSelRate, PrdRateDiffAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_SpecialDiscount_ApplyOn')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_SpecialDiscount_ApplyOn ON dbo.Cn2Cs_Prk_SpecialDiscount (ApplyOn) INCLUDE (PrdCategoryLevelValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdCCode_TaxGroupId')
BEGIN
CREATE INDEX IX_Product_PrdCCode_TaxGroupId ON dbo.Product (PrdCCode, TaxGroupId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SalInvDate, SalGrossAmount, SalNetAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceProduct_RateDiffClaimId')
BEGIN
CREATE INDEX IX_SalesInvoiceProduct_RateDiffClaimId ON dbo.SalesInvoiceProduct (RateDiffClaimId) INCLUDE (SalId, PrdId, PrdBatId, SlNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_SpecialDiscount_ApplyOn')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_SpecialDiscount_ApplyOn ON dbo.Cn2Cs_Prk_SpecialDiscount (ApplyOn) INCLUDE (RetCategoryLevel, RetCatLevelValue, PrdCategoryLevel, PrdCategoryLevelValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_KitItemRetailerCategory_KitPrdCode_CtgCode')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_KitItemRetailerCategory_KitPrdCode_CtgCode ON dbo.Cn2Cs_Prk_KitItemRetailerCategory (KitPrdCode, CtgCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate,DlvSts) INCLUDE (SalId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_QPS_SchStatus_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_QPS_SchStatus_SchValidFrom_SchValidTill ON dbo.SchemeMaster (QPS, SchStatus,SchValidFrom, SchValidTill) INCLUDE (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_FBM_SchId')
BEGIN
CREATE INDEX IX_SchemeMaster_FBM_SchId ON dbo.SchemeMaster (FBM,SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeLineWise_SchId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeLineWise_SchId ON dbo.SalesInvoiceSchemeLineWise (SchId) INCLUDE (SalId, SlabId, PrdId, PrdBatId, FlatAmount, DiscountPerAmount, ReturnFlatAmount, ReturnDiscountPerAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeRuleSettings_SchId')
BEGIN
CREATE INDEX IX_SchemeRuleSettings_SchId ON dbo.SchemeRuleSettings (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceiptProduct_ShrtBaseQty')
BEGIN
CREATE INDEX IX_PurchaseReceiptProduct_ShrtBaseQty ON dbo.PurchaseReceiptProduct (ShrtBaseQty) INCLUDE (PurRcptId, InvBaseQty, PrdNetAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts_SalInvDate ON dbo.SalesInvoice (DlvSts,SalInvDate) INCLUDE (SMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SalId, SalInvDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceProduct_PrdSchDiscAmount')
BEGIN
CREATE INDEX IX_SalesInvoiceProduct_PrdSchDiscAmount ON dbo.SalesInvoiceProduct (PrdSchDiscAmount) INCLUDE (SalId, PrdId, PrdBatId, BaseQty, SlNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceiptProduct_ExsBaseQty')
BEGIN
CREATE INDEX IX_PurchaseReceiptProduct_ExsBaseQty ON dbo.PurchaseReceiptProduct (ExsBaseQty) INCLUDE (PurRcptId, InvBaseQty, PrdNetAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdType')
BEGIN
CREATE INDEX IX_Product_PrdType ON dbo.Product (PrdType) INCLUDE (PrdId, PrdCCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SAPPurchaseReceiptDetails_CmpInvNo')
BEGIN
CREATE INDEX IX_SAPPurchaseReceiptDetails_CmpInvNo ON dbo.SAPPurchaseReceiptDetails (CmpInvNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_Upload')
BEGIN
CREATE INDEX IX_SalesInvoice_Upload ON dbo.SalesInvoice (Upload) INCLUDE (SalId, SalInvNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_UdcMasterId_MasterId_ColumnValue')
BEGIN
CREATE INDEX IX_UdcDetails_UdcMasterId_MasterId_ColumnValue ON dbo.UdcDetails (UdcMasterId, MasterId, ColumnValue) INCLUDE (MasterRecordId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SpecialRateAftDownLoad_RtrCode')
BEGIN
CREATE INDEX IX_SpecialRateAftDownLoad_RtrCode ON dbo.SpecialRateAftDownLoad (RtrCode) INCLUDE (PrdCCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_DlvSts_SalInvDate_RMId')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_DlvSts_SalInvDate_RMId ON dbo.SalesInvoice (SMId, DlvSts,SalInvDate, RMId) INCLUDE (SalId, SalInvNo, RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeLineWise_SchId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeLineWise_SchId ON dbo.SalesInvoiceSchemeLineWise (SchId) INCLUDE (SalId, PrdId, PrdBatId, FlatAmount, ReturnFlatAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_Upload')
BEGIN
CREATE INDEX IX_SalesInvoice_Upload ON dbo.SalesInvoice (Upload) INCLUDE (SalId, SalInvNo, SalInvDate, LcnId, BillType, BillMode, SMId, RMId, DlvRMId, RtrId, OrderKeyNo, SalGrossAmount, SalSplDiscAmount, SalSchDiscAmount, SalDBDiscAmount, SalTaxAmount, SalCDAmount, DBAdjAmount, CRAdjAmount, MarketRetAmount, OtherCharges, WindowDisplayAmount, OnAccountAmount, ReplacementDiffAmount, TotalAddition, TotalDeduction, SalNetAmt, SalRoundOffAmt, DlvSts, VehicleId, DlvBoyId, SalDlvDate, SalInvLvlDisc, SalInvLvlDiscPer)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_MasterRecordId')
BEGIN
CREATE INDEX IX_UdcDetails_MasterRecordId ON dbo.UdcDetails (MasterRecordId) INCLUDE (UdcMasterId, MasterId, ColumnValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PrdBatId')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PrdBatId ON dbo.ProductBatchDetails (PrdBatId) INCLUDE (PriceId, PriceCode, BatchSeqId, SLNo, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PriceId_PrdBatId_DefaultPrice')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PriceId_PrdBatId_DefaultPrice ON dbo.ProductBatchDetails (PriceId, PrdBatId, DefaultPrice)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_OrderBookingProducts_OrderNo')
BEGIN
CREATE INDEX IX_OrderBookingProducts_OrderNo ON dbo.OrderBookingProducts (OrderNo) INCLUDE (PrdId, PrdBatId, TotalQty, BilledQty, Rate, GrossAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_SpecialDiscount_PrdCategoryLevel_DownLoadFlag')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_SpecialDiscount_PrdCategoryLevel_DownLoadFlag ON dbo.Cn2Cs_Prk_SpecialDiscount (PrdCategoryLevel, DownLoadFlag) INCLUDE (PrdCategoryLevelValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PrdBatId_DefaultPrice')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PrdBatId_DefaultPrice ON dbo.ProductBatchDetails (PrdBatId, DefaultPrice) INCLUDE (PriceId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_Claimable')
BEGIN
CREATE INDEX IX_SchemeMaster_Claimable ON dbo.SchemeMaster (Claimable) INCLUDE (SchId, LastModDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_SpecialDiscount_PrdCategoryLevel_DownLoadFlag')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_SpecialDiscount_PrdCategoryLevel_DownLoadFlag ON dbo.Cn2Cs_Prk_SpecialDiscount (PrdCategoryLevel, DownLoadFlag) INCLUDE (PrdCategoryLevelValue, CPRefCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_TaxGroupId_PrdStatus')
BEGIN
CREATE INDEX IX_Product_TaxGroupId_PrdStatus ON dbo.Product (TaxGroupId, PrdStatus) INCLUDE (PrdCCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_DefaultPrice')
BEGIN
CREATE INDEX IX_ProductBatchDetails_DefaultPrice ON dbo.ProductBatchDetails (DefaultPrice) INCLUDE (PriceId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PrdBatId')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PrdBatId ON dbo.ProductBatchDetails (PrdBatId) INCLUDE (PriceId, BatchSeqId, SLNo, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ETL_SAPPurchaseDetails_CmpInvNo')
BEGIN
CREATE INDEX IX_ETL_SAPPurchaseDetails_CmpInvNo ON dbo.ETL_SAPPurchaseDetails (CmpInvNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PriceId_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PriceId_SLNo ON dbo.ProductBatchDetails (PriceId, SLNo) INCLUDE (PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_SLNo')
BEGIN
CREATE INDEX IX_ProductBatchDetails_SLNo ON dbo.ProductBatchDetails (SLNo) INCLUDE (PriceId, PrdBatDetailValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_SpecialDiscount_PrdCategoryLevel_DownLoadFlag')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_SpecialDiscount_PrdCategoryLevel_DownLoadFlag ON dbo.Cn2Cs_Prk_SpecialDiscount (PrdCategoryLevel, DownLoadFlag) INCLUDE (DistCode, RetCategoryLevel, RetCatLevelValue, PrdCategoryLevelValue, DiscPer, EffFromDate, EffToDate, CreatedDate, ApplyOn, Type, FlatAmt, SplPrice, SPWTax, CPRefCode, CPRefName)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceipt_GoodsRcvdDate_Status')
BEGIN
CREATE INDEX IX_PurchaseReceipt_GoodsRcvdDate_Status ON dbo.PurchaseReceipt (GoodsRcvdDate, Status) INCLUDE (GrossAmount, NetAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatch_PrdBatCode')
BEGIN
CREATE INDEX IX_ProductBatch_PrdBatCode ON dbo.ProductBatch (PrdBatCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceProductTax_TaxId_TaxableAmount')
BEGIN
CREATE INDEX IX_SalesInvoiceProductTax_TaxId_TaxableAmount ON dbo.SalesInvoiceProductTax (TaxId,TaxableAmount) INCLUDE (SalId, PrdSlNo, TaxPerc)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdStatus')
BEGIN
CREATE INDEX IX_Product_PrdStatus ON dbo.Product (PrdStatus) INCLUDE (PrdId, PrdCCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_SalId_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_SalId_SalInvDate_DlvSts ON dbo.SalesInvoice (RtrId,SalId, SalInvDate, DlvSts)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceipt_Status')
BEGIN
CREATE INDEX IX_PurchaseReceipt_Status ON dbo.PurchaseReceipt (Status) INCLUDE (GoodsRcvdDate, GrossAmount, NetAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_ColumnValue')
BEGIN
CREATE INDEX IX_UdcDetails_ColumnValue ON dbo.UdcDetails (ColumnValue) INCLUDE (UdcMasterId, MasterId, MasterRecordId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_TaxGroupId')
BEGIN
CREATE INDEX IX_Product_TaxGroupId ON dbo.Product (TaxGroupId) INCLUDE (PrdId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceipt_CmpId_CmpInvNo')
BEGIN
CREATE INDEX IX_PurchaseReceipt_CmpId_CmpInvNo ON dbo.PurchaseReceipt (CmpId, CmpInvNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceProductTax_TaxableAmount')
BEGIN
CREATE INDEX IX_SalesInvoiceProductTax_TaxableAmount ON dbo.SalesInvoiceProductTax (TaxableAmount) INCLUDE (SalId, PrdSlNo, TaxId, TaxPerc)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeLineWise_SchId_SlabId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeLineWise_SchId_SlabId ON dbo.SalesInvoiceSchemeLineWise (SchId, SlabId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_DayEndDates_Status_DayEndStartDate')
BEGIN
CREATE INDEX IX_DayEndDates_Status_DayEndStartDate ON dbo.DayEndDates (Status,DayEndStartDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (SalId, SalInvNo, RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName ON dbo.WSMasterExportUploadTrack (ProcessName) INCLUDE (MasterCode, MasterName, Ref4Value)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_MasterRecordId_ColumnValue')
BEGIN
CREATE INDEX IX_UdcDetails_MasterRecordId_ColumnValue ON dbo.UdcDetails (MasterRecordId, ColumnValue) INCLUDE (UdcMasterId, MasterId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SpecialRateAftDownLoad_RtrCode')
BEGIN
CREATE INDEX IX_SpecialRateAftDownLoad_RtrCode ON dbo.SpecialRateAftDownLoad (RtrCode) INCLUDE (RtrCtgCode, RtrCtgValueCode, PrdCCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (SalGrossAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_SMId_RMId')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_SMId_RMId ON dbo.SalesInvoice (SalInvDate, SMId, RMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (SMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_LcnId_DlvSts_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_LcnId_DlvSts_SalInvDate ON dbo.SalesInvoice (LcnId, DlvSts,SalInvDate) INCLUDE (SMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_RMId_DlvSts_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_RMId_DlvSts_SalInvDate ON dbo.SalesInvoice (SMId, RMId, DlvSts,SalInvDate) INCLUDE (SalId, SalInvNo, RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_PrdId_PrdBatId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_PrdId_PrdBatId ON dbo.ContractPricingDetails (PrdId, PrdBatId) INCLUDE (ContractId, PriceId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (SMId, SalGrossAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_TaxGroupId')
BEGIN
CREATE INDEX IX_Product_TaxGroupId ON dbo.Product (TaxGroupId) INCLUDE (PrdCCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName_MasterCode_Status_Reference1')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName_MasterCode_Status_Reference1 ON dbo.WSMasterExportUploadTrack (ProcessName, MasterCode, Status, Reference1)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_SalInvDate ON dbo.SalesInvoice (SMId,SalInvDate) INCLUDE (SalGrossAmount, DlvSts)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SalInvDate, RtrId, SalGrossAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName ON dbo.WSMasterExportUploadTrack (ProcessName) INCLUDE (MasterCode, Status, Reference1)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SalId, LcnId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SalId, SalInvNo, SalInvDate, RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CS2Console_Consolidated_SyncId_UploadFlag')
BEGIN
CREATE INDEX IX_CS2Console_Consolidated_SyncId_UploadFlag ON dbo.CS2Console_Consolidated (SyncId, UploadFlag) INCLUDE (SlNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatch_BatchSeqId')
BEGIN
CREATE INDEX IX_ProductBatch_BatchSeqId ON dbo.ProductBatch (BatchSeqId) INCLUDE (PrdId, PrdBatId, PrdBatCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName ON dbo.WSMasterExportUploadTrack (ProcessName) INCLUDE (MasterCode, MasterName)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeDtBilled_SchId_SlabId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeDtBilled_SchId_SlabId ON dbo.SalesInvoiceSchemeDtBilled (SchId, SlabId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeHd_SchId_SlabId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeHd_SchId_SlabId ON dbo.SalesInvoiceSchemeHd (SchId, SlabId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductCategoryValue_CmpPrdCtgId')
BEGIN
CREATE INDEX IX_ProductCategoryValue_CmpPrdCtgId ON dbo.ProductCategoryValue (CmpPrdCtgId) INCLUDE (PrdCtgValLinkId, PrdCtgValCode, PrdCtgValName)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_DlvSts ON dbo.SalesInvoice (RtrId,DlvSts) INCLUDE (SalId, SalInvDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CS2Console_Consolidated_DistCode_SyncId_ProcessName')
BEGIN
CREATE INDEX IX_CS2Console_Consolidated_DistCode_SyncId_ProcessName ON dbo.CS2Console_Consolidated (DistCode, SyncId, ProcessName)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate ON dbo.SalesInvoice (SalInvDate) INCLUDE (SalId, SalInvNo, LcnId, BillType, BillMode, SMId, RMId, RtrId, SalGrossAmount, SalSplDiscAmount, SalSchDiscAmount, SalDBDiscAmount, SalTaxAmount, SalCDAmount, DBAdjAmount, CRAdjAmount, MarketRetAmount, ReplacementDiffAmount, SalNetAmt, DlvSts)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchType_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchType_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchType, SchValidFrom, SchValidTill) INCLUDE (SchId, CmpSchCode, SchStatus)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_RMId_DlvRMId_DlvSts_SalInvDate_RtrId')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_RMId_DlvRMId_DlvSts_SalInvDate_RtrId ON dbo.SalesInvoice (SMId, RMId, DlvRMId, DlvSts,SalInvDate, RtrId) INCLUDE (SalId, SalInvNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_DlvRMId_DlvSts_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_DlvRMId_DlvSts_SalInvDate ON dbo.SalesInvoice (SMId, DlvRMId, DlvSts,SalInvDate) INCLUDE (RMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_RMId_DlvRMId_DlvSts_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_RMId_DlvRMId_DlvSts_SalInvDate ON dbo.SalesInvoice (SMId, RMId, DlvRMId, DlvSts,SalInvDate) INCLUDE (RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SpecialRateAftDownLoad_PrdCCode')
BEGIN
CREATE INDEX IX_SpecialRateAftDownLoad_PrdCCode ON dbo.SpecialRateAftDownLoad (PrdCCode) INCLUDE (RtrCtgValueCode, PrdBatCCode, SplSelRate, DownloadedDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts_SalInvDate ON dbo.SalesInvoice (DlvSts,SalInvDate) INCLUDE (VehicleId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CustomCaptions_TransId_LngId')
BEGIN
CREATE INDEX IX_CustomCaptions_TransId_LngId ON dbo.CustomCaptions (TransId, LngId) INCLUDE (CtrlId, SubCtrlId, CtrlName, Caption, PnlMsg, MsgBox, DefaultCaption, DefaultPnlMsg, DefaultMsgBox)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_DlvSts_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_DlvSts_SalInvDate ON dbo.SalesInvoice (SMId, DlvSts,SalInvDate) INCLUDE (DlvRMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_ContractPricing_EffectiveDate')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_ContractPricing_EffectiveDate ON dbo.Cn2Cs_Prk_ContractPricing (EffectiveDate) INCLUDE (CmpId, CtgLevelId, CtgMainId, RtrClassId, CmpPrdCtgId, RtrId, ToDate, CreatedDate, RtrTaxGroupId, SplPrice, ComConRefNo, ComConRefName, ApplyON, WithTax)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_PriceId_PrdBatId')
BEGIN
CREATE INDEX IX_ProductBatchDetails_PriceId_PrdBatId ON dbo.ProductBatchDetails (PriceId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchStatus_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchStatus_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchStatus,SchValidFrom, SchValidTill)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_MasterId_Upload')
BEGIN
CREATE INDEX IX_UdcDetails_MasterId_Upload ON dbo.UdcDetails (MasterId, Upload) INCLUDE (UdcMasterId, MasterRecordId, ColumnValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_SalInvDate ON dbo.SalesInvoice (SMId,SalInvDate) INCLUDE (RMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_SalInvDate')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_SalInvDate ON dbo.SalesInvoice (SMId,SalInvDate) INCLUDE (DlvRMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_PrdId_PrdBatId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_PrdId_PrdBatId ON dbo.ContractPricingDetails (PrdId, PrdBatId) INCLUDE (ContractId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchStatus_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchStatus_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchStatus,SchValidFrom, SchValidTill) INCLUDE (Budget)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_ContractId_PrdId_PrdBatId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_ContractId_PrdId_PrdBatId ON dbo.ContractPricingDetails (ContractId, PrdId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_PrdId_CtgValMainId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_PrdId_CtgValMainId ON dbo.ContractPricingDetails (PrdId, CtgValMainId) INCLUDE (ContractId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_ContractId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_ContractId ON dbo.ContractPricingDetails (ContractId) INCLUDE (PrdId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_ContractId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_ContractId ON dbo.ContractPricingDetails (ContractId) INCLUDE (PrdId, PrdBatId, PriceId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_DefaultPriceHistory_PrdId_PrdBatId_PriceId_ToDate')
BEGIN
CREATE INDEX IX_DefaultPriceHistory_PrdId_PrdBatId_PriceId_ToDate ON dbo.DefaultPriceHistory (PrdId, PrdBatId, PriceId, ToDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_CmpSchCode')
BEGIN
CREATE INDEX IX_SchemeMaster_CmpSchCode ON dbo.SchemeMaster (CmpSchCode) INCLUDE (SchDsc, SchStatus, Budget)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (SalId, SMId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_CtgValMainId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_CtgValMainId ON dbo.ContractPricingDetails (CtgValMainId) INCLUDE (ContractId, PrdId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_DlvSts ON dbo.SalesInvoice (RtrId,DlvSts) INCLUDE (SalId, SalInvNo, SalInvDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_ContractId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_ContractId ON dbo.ContractPricingDetails (ContractId) INCLUDE (PrdBatId, CtgValMainId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SMId, SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ReportFilterDt_RptId_SelId_SelValue_UsrId')
BEGIN
CREATE INDEX IX_ReportFilterDt_RptId_SelId_SelValue_UsrId ON dbo.ReportFilterDt (RptId, SelId, SelValue, UsrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatchDetails_DefaultPrice')
BEGIN
CREATE INDEX IX_ProductBatchDetails_DefaultPrice ON dbo.ProductBatchDetails (DefaultPrice) INCLUDE (PriceId, PrdBatId, BatchSeqId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdStatus')
BEGIN
CREATE INDEX IX_Product_PrdStatus ON dbo.Product (PrdStatus) INCLUDE (PrdId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ReportFilterDt_RptId_SelId_UsrId')
BEGIN
CREATE INDEX IX_ReportFilterDt_RptId_SelId_UsrId ON dbo.ReportFilterDt (RptId, SelId, UsrId) INCLUDE (SelValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SMId, SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_DlvSts ON dbo.SalesInvoice (DlvSts) INCLUDE (SalInvDate, RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (SalInvNo, SMId, RtrId, SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_QPS_SchStatus_ApyQPSSch_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_QPS_SchStatus_ApyQPSSch_SchValidTill ON dbo.SchemeMaster (QPS, SchStatus, ApyQPSSch,SchValidTill) INCLUDE (SchId, CmpSchCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName_MasterCode')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName_MasterCode ON dbo.WSMasterExportUploadTrack (ProcessName, MasterCode) INCLUDE (MasterName)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Import_WS2CS_SalesOrderDetail_DownloadFlag')
BEGIN
CREATE INDEX IX_Import_WS2CS_SalesOrderDetail_DownloadFlag ON dbo.Import_WS2CS_SalesOrderDetail (DownloadFlag) INCLUDE (DocumentPrefix, DocumentNumber)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName_MasterCode_Ref4Value')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName_MasterCode_Ref4Value ON dbo.WSMasterExportUploadTrack (ProcessName, MasterCode,Ref4Value) INCLUDE (MasterName)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CustomCaptions_TransId_LngId_CtrlId')
BEGIN
CREATE INDEX IX_CustomCaptions_TransId_LngId_CtrlId ON dbo.CustomCaptions (TransId, LngId,CtrlId) INCLUDE (CtrlName, Caption, PnlMsg, DefaultCaption, DefaultPnlMsg)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchStatus_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchStatus_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchStatus,SchValidFrom, SchValidTill) INCLUDE (SchId, SchCode, SchDsc, Budget)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_MasterRecordId')
BEGIN
CREATE INDEX IX_UdcDetails_MasterRecordId ON dbo.UdcDetails (MasterRecordId) INCLUDE (UdcMasterId, MasterId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SpecialRate_Track_RtrCode_PrdCtgLevel_PrdCtgcode_ApplyOn_CreatedDate')
BEGIN
CREATE INDEX IX_SpecialRate_Track_RtrCode_PrdCtgLevel_PrdCtgcode_ApplyOn_CreatedDate ON dbo.SpecialRate_Track (RtrCode, PrdCtgLevel, PrdCtgcode, ApplyOn, CreatedDate) INCLUDE (RtrCtgCode, RtrCtgValueCode, DiscountPerc, CPRefNO)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TempSpecialRateDiscountProduct_EffectiveFromDate')
BEGIN
CREATE INDEX IX_TempSpecialRateDiscountProduct_EffectiveFromDate ON dbo.TempSpecialRateDiscountProduct (EffectiveFromDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SpecialRateAftDownLoad_Calc_RtrCtgValueCode')
BEGIN
CREATE INDEX IX_SpecialRateAftDownLoad_Calc_RtrCtgValueCode ON dbo.SpecialRateAftDownLoad_Calc (RtrCtgValueCode) INCLUDE (PrdCCode, PrdBatCCode, SplSelRate, DownloadedDate, DiscountPerc, TYPE)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_DlvSts ON dbo.SalesInvoice (RtrId,DlvSts) INCLUDE (SalId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_RtrId_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_RtrId_SalInvDate_DlvSts ON dbo.SalesInvoice (RtrId,SalInvDate, DlvSts)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Product_PrdCCode')
BEGIN
CREATE INDEX IX_Product_PrdCCode ON dbo.Product (PrdCCode) INCLUDE (UomGroupId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SalInvDate_DlvSts ON dbo.SalesInvoice (SalInvDate, DlvSts) INCLUDE (SalId, RtrId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoice_SMId_SalInvDate_DlvSts')
BEGIN
CREATE INDEX IX_SalesInvoice_SMId_SalInvDate_DlvSts ON dbo.SalesInvoice (SMId,SalInvDate, DlvSts) INCLUDE (SalInvNo, RtrId, SalNetAmt, SalPayAmt)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatch_PrdBatCode')
BEGIN
CREATE INDEX IX_ProductBatch_PrdBatCode ON dbo.ProductBatch (PrdBatCode) INCLUDE (PrdId, PrdBatId, DefaultPriceId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceSchemeLineWise_SchId')
BEGIN
CREATE INDEX IX_SalesInvoiceSchemeLineWise_SchId ON dbo.SalesInvoiceSchemeLineWise (SchId) INCLUDE (SalId, FlatAmount, DiscountPerAmount)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatch_PrdBatCode')
BEGIN
CREATE INDEX IX_ProductBatch_PrdBatCode ON dbo.ProductBatch (PrdBatCode) INCLUDE (PrdId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductBatch_CmpBatCode')
BEGIN
CREATE INDEX IX_ProductBatch_CmpBatCode ON dbo.ProductBatch (CmpBatCode) INCLUDE (PrdId, PrdBatId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TempSpecialRateDiscountProduct_EffectiveFromDate')
BEGIN
CREATE INDEX IX_TempSpecialRateDiscountProduct_EffectiveFromDate ON dbo.TempSpecialRateDiscountProduct (EffectiveFromDate) INCLUDE (SlNo, CtgLevelName, CtgCode, RtrCode, PrdCCode, PrdBatCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_CtgValMainId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_CtgValMainId ON dbo.ContractPricingDetails (CtgValMainId) INCLUDE (ContractId, ApplyOn)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SpecialRateAftDownLoad_Calc_RtrCtgCode_RtrCtgValueCode_RtrCode_PrdCCode_CreatedDate')
BEGIN
CREATE INDEX IX_SpecialRateAftDownLoad_Calc_RtrCtgCode_RtrCtgValueCode_RtrCode_PrdCCode_CreatedDate ON dbo.SpecialRateAftDownLoad_Calc (RtrCtgCode, RtrCtgValueCode, RtrCode, PrdCCode, CreatedDate) INCLUDE (DiscountPerc)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CS2Console_Consolidated_DistCode_SyncId')
BEGIN
CREATE INDEX IX_CS2Console_Consolidated_DistCode_SyncId ON dbo.CS2Console_Consolidated (DistCode, SyncId) INCLUDE (SlNo)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductCategoryValue_CmpPrdCtgId')
BEGIN
CREATE INDEX IX_ProductCategoryValue_CmpPrdCtgId ON dbo.ProductCategoryValue (CmpPrdCtgId) INCLUDE (PrdCtgValCode, PrdCtgValName)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchType_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchType_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchType, SchValidFrom, SchValidTill) INCLUDE (SchId, CmpSchCode, Range)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CS2Console_Consolidated_SyncId_UploadFlag')
BEGIN
CREATE INDEX IX_CS2Console_Consolidated_SyncId_UploadFlag ON dbo.CS2Console_Consolidated (SyncId, UploadFlag)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_CS2Console_Consolidated_SyncId')
BEGIN
CREATE INDEX IX_CS2Console_Consolidated_SyncId ON dbo.CS2Console_Consolidated (SyncId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_DefaultPriceHistory_ToDate')
BEGIN
CREATE INDEX IX_DefaultPriceHistory_ToDate ON dbo.DefaultPriceHistory (ToDate) INCLUDE (PrdId, PrdBatId, PriceId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_UdcMasterId_MasterId_MasterRecordId')
BEGIN
CREATE INDEX IX_UdcDetails_UdcMasterId_MasterId_MasterRecordId ON dbo.UdcDetails (UdcMasterId, MasterId, MasterRecordId) INCLUDE (UdcDetailsId, ColumnValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_UdcDetails_UdcMasterId_MasterId_MasterRecordId')
BEGIN
CREATE INDEX IX_UdcDetails_UdcMasterId_MasterId_MasterRecordId ON dbo.UdcDetails (UdcMasterId, MasterId, MasterRecordId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchType_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchType_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchType, SchValidFrom, SchValidTill) INCLUDE (SchId, SchDsc, CmpSchCode, QPS)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_DefaultPriceHistory_CurrentDefault')
BEGIN
CREATE INDEX IX_DefaultPriceHistory_CurrentDefault ON dbo.DefaultPriceHistory (CurrentDefault) INCLUDE (PrdId, PrdBatId, PriceId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName ON dbo.WSMasterExportUploadTrack (ProcessName) INCLUDE (MasterCode, Status, Ref4Value)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName ON dbo.WSMasterExportUploadTrack (ProcessName) INCLUDE (MasterCode, Reference2)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ProductCategoryValue_PrdCtgValCode')
BEGIN
CREATE INDEX IX_ProductCategoryValue_PrdCtgValCode ON dbo.ProductCategoryValue (PrdCtgValCode) INCLUDE (PrdCtgValLinkCode)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_SpecialDiscount_RetCatLevelValue')
BEGIN
CREATE INDEX IX_Cn2Cs_Prk_SpecialDiscount_RetCatLevelValue ON dbo.Cn2Cs_Prk_SpecialDiscount (RetCatLevelValue) INCLUDE (PrdCategoryLevelValue)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_ContractPricingDetails_CtgValMainId')
BEGIN
CREATE INDEX IX_ContractPricingDetails_CtgValMainId ON dbo.ContractPricingDetails (CtgValMainId) INCLUDE (ContractId, ApplyOn)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_WSMasterExportUploadTrack_ProcessName')
BEGIN
CREATE INDEX IX_WSMasterExportUploadTrack_ProcessName ON dbo.WSMasterExportUploadTrack (ProcessName) INCLUDE (MasterCode, Status, Reference1, Reference2, Reference3, Ref4Value)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_RptDetails_RptId')
BEGIN
CREATE INDEX IX_RptDetails_RptId ON dbo.RptDetails (RptId) INCLUDE (SlNo, TblName, PrntId, PrntRefFld, FldName, FldCaption, PrntTbl, CtrlType, CmnFld, SelcId, SingleMulti, Mandatory, PnlMsg, CaptionChange)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_RptDetails_RptId')
BEGIN
CREATE INDEX IX_RptDetails_RptId ON dbo.RptDetails (RptId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TempSpecialRateDiscountProduct_PRDCTGVALMAINID_RtrCode_EffectiveFromDate')
BEGIN
CREATE INDEX IX_TempSpecialRateDiscountProduct_PRDCTGVALMAINID_RtrCode_EffectiveFromDate ON dbo.TempSpecialRateDiscountProduct (PRDCTGVALMAINID,RtrCode, EffectiveFromDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_PurchaseReceipt_Availability')
BEGIN
CREATE INDEX IX_PurchaseReceipt_Availability ON dbo.PurchaseReceipt (Availability) INCLUDE (PurRcptId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchStatus_SchType_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchStatus_SchType_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchStatus,SchType, SchValidFrom, SchValidTill) INCLUDE (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TempSpecialRateDiscountProduct_RtrCode_PRDCTGVALMAINID_EffectiveFromDate')
BEGIN
CREATE INDEX IX_TempSpecialRateDiscountProduct_RtrCode_PRDCTGVALMAINID_EffectiveFromDate ON dbo.TempSpecialRateDiscountProduct (RtrCode, PRDCTGVALMAINID,EffectiveFromDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchStatus_FBM_SchType_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchStatus_FBM_SchType_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchStatus, FBM,SchType, SchValidFrom, SchValidTill) INCLUDE (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeMaster_SchStatus_SchValidFrom_SchValidTill')
BEGIN
CREATE INDEX IX_SchemeMaster_SchStatus_SchValidFrom_SchValidTill ON dbo.SchemeMaster (SchStatus,SchValidFrom, SchValidTill) INCLUDE (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SchemeProducts_PrdCtgValMainId')
BEGIN
CREATE INDEX IX_SchemeProducts_PrdCtgValMainId ON dbo.SchemeProducts (PrdCtgValMainId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TempSpecialRateDiscountProduct_RtrCode_EffectiveFromDate_PRDCTGVALMAINID')
BEGIN
CREATE INDEX IX_TempSpecialRateDiscountProduct_RtrCode_EffectiveFromDate_PRDCTGVALMAINID ON dbo.TempSpecialRateDiscountProduct (RtrCode, EffectiveFromDate, PRDCTGVALMAINID) INCLUDE (CtgLevelName, CtgCode, PrdCCode, PrdBatCode, DiscPer, SpecialSellingRate, EffectiveToDate, CreatedDate, ApplyOn, TYPE, CPRefCode, CPRefName)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_TempSpecialRateDiscountProduct_CtgLevelName')
BEGIN
CREATE INDEX IX_TempSpecialRateDiscountProduct_CtgLevelName ON dbo.TempSpecialRateDiscountProduct (CtgLevelName) INCLUDE (SlNo, CtgCode, RtrCode, PrdCCode, PrdBatCode, EffectiveFromDate)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceProduct_SalManFreeQty')
BEGIN
CREATE INDEX IX_SalesInvoiceProduct_SalManFreeQty ON dbo.SalesInvoiceProduct (SalManFreeQty) INCLUDE (SalId, PrdId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SpecialRateAftDownLoad_Calc_ApplyOn')
BEGIN
CREATE INDEX IX_SpecialRateAftDownLoad_Calc_ApplyOn ON dbo.SpecialRateAftDownLoad_Calc (ApplyOn) INCLUDE (RtrCtgCode, RtrCtgValueCode, RtrCode, PrdCCode, CreatedDate, TYPE)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_SalesInvoiceQPSCumulative_SchId')
BEGIN
CREATE INDEX IX_SalesInvoiceQPSCumulative_SchId ON dbo.SalesInvoiceQPSCumulative (SchId)
END
IF NOT EXISTS (SELECT * FROM SYS.indexes WHERE NAME='IX_Cn2Cs_Prk_ContractPricing_EffectiveDate')
BEGIN
CREATE INDEX [IX_Cn2Cs_Prk_ContractPricing_EffectiveDate] ON [dbo].[Cn2Cs_Prk_ContractPricing] ([EffectiveDate]) INCLUDE ([CmpId], [CtgLevelId], [CtgMainId], [RtrClassId], [CmpPrdCtgId], [RtrId], [ToDate], [CreatedDate], [RtrTaxGroupId], [SplPrice], [ComConRefNo], [ComConRefName], [ApplyON], [WithTax])
END