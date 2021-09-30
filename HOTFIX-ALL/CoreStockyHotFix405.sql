--[Stocky HotFix Version]=405
DELETE FROM Versioncontrol WHERE Hotfixid='405'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('405','2.0.0.0','D','2013-09-05','2013-09-05','2013-09-05',CONVERT(VARCHAR(11),GETDATE()),'PARLE-Major: Product Release March CR')
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and name='UtilityProcess')
DROP TABLE UtilityProcess
GO
CREATE TABLE UtilityProcess(
	[ProcId] [int] NULL,
	[ProcessName] [varchar](100) NULL,
	[ProcessPath] [varchar](500) NULL,
	[ProcessType] [varchar](20) NULL,
	[ConfigExists] [tinyint] NULL,
	[ModuleId] [varchar](100) NULL,
	[ModuleName] [varchar](200) NULL,
	[Mandatory] [int] NULL,
	[DependExe] [int] NULL,
	[VersionId]	Varchar(10),
	[ProcessHandle] TinyInt
) ON [PRIMARY]
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('Users') and Name='HostName')
BEGIN
	ALTER TABLE Users ADD  HostName Varchar(100) DEFAULT '' WITH VALUES
END
GO
DELETE FROM UTILITYPROCESS
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (1,'Core Stocky.Exe','App.Path','EXE',0,'','',0,0,'3.0.0.0',0)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (2,'ScriptUpdater.Exe','App.Path','EXE',0,'','',1,0,'0',1)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (3,'Sync.Exe','App.Path','EXE',1,'GENCONFIG23','General Configuration',1,0,'PV.0.0.2',0)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (4,'BBoard.exe','App.Path','EXE',0,'','',1,0,'0',1)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (5,'Auto Deployment.exe','App.Path','EXE',0,'','',1,0,'0',0)
INSERT INTO UTILITYPROCESS([ProcId],[ProcessName],[ProcessPath],[ProcessType],[ConfigExists],[ModuleId],[ModuleName],[Mandatory],[DependExe],VersionId,ProcessHandle) VALUES (6,'CSUpdates Alert.exe','App.Path','EXE',0,'','',1,0,'0',0)
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='DefendRestore')
BEGIN
CREATE TABLE [DefendRestore](
	[AccessCode] [nvarchar](400) NOT NULL,
	[LastModDate] [datetime] NOT NULL ,
	[DbStatus] [tinyint] NOT NULL,
	[ReqId] [int] NOT NULL,
	[CSLockStatus] [tinyint] NOT NULL,
	[CCLockStatus] [tinyint] NOT NULL,
	[IniDecryptString] [varchar](3000) NOT NULL,
	[IniEncryptString] [varchar](3000) NOT NULL,
	[ActualEncryptString] [varchar](3000) NOT NULL,
	[FilePath] [varchar](3000) NOT NULL,
	[HostName] [varchar](100) NOT NULL
)
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='Tbl_ExeVersionControl')
BEGIN
	CREATE TABLE Tbl_ExeVersionControl
		(
			HostName Varchar(200) NOT NULL,
			VersionId Varchar(20) NOT NULL
		)				
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_SampleReceipt' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_SampleReceipt
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_SampleReceipt 0
SELECT * FROM TempSamplePurchaseReceipt
SELECT DownloadFlag,* FROM Cn2Cs_Prk_SampleReceipt
ROLLBACK TRANSACTION 
*/
CREATE PROCEDURE Proc_Cn2Cs_SampleReceipt  
(
       @Po_ErrNo int OUTPUT
)
AS
/********************************************************************************************
* PROCEDURE		: Proc_Cn2Cs_SampleReceipt
* PURPOSE		: To Insert the values in Sample Receipt
* CREATED		: PanneerSelvam.k
* CREATED DATE	: 23.11.2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------
* {date}     {developer}  {brief modification description}
* 17.06.2013 B.Suganya   PMS NO:ICRSTHUT0013 Product gets duplicated in samplereceipt module
********************************************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @CmpCode	AS  NVARCHAR(100)
	DECLARE @SpmCode	AS  NVARCHAR(100)
	DECLARE @LocCode	AS  NVARCHAR(100)
	DECLARE @CmpInvNo   AS  NVARCHAR(100)
	DECLARE @CmpInvDate AS  NVARCHAR(100)
	DECLARE @TransCode  AS  NVARCHAR(100)
	DECLARE @CmpPrdCode AS  NVARCHAR(100)
	DECLARE @BatchCode  AS  NVARCHAR(100)
	DECLARE @UomCode	AS  NVARCHAR(100)
	DECLARE @InvoiceDate AS  NVARCHAR(100)
	DECLARE @InvoiceQty AS  INT
	DECLARE @CmpId		AS  INT
	DECLARE @SpmId		AS  INT
	DECLARE @TransId	AS  INT
	DECLARE @PrdId		AS  INT
	DECLARE @CounterId	AS  INT	
	DECLARE @PrdBatId	AS  INT	
	DECLARE @Qty		AS  INT
	DECLARE @UomId		AS  INT
	DECLARE @BatSeqId	AS  INT
	DECLARE @DefPriceId	AS  INT
	DECLARE @LcnId		AS  INT
	DECLARE @ErrorChk	AS  INT
	DECLARE @InvDate	AS  DATETIME
	DECLARE @Tabname	AS  NVARCHAR(100)
	DECLARE @ErrorDet  AS  NVARCHAR(4000)
	SET @Tabname = 'Cn2Cs_Prk_SampleReceipt'
	SET @Po_ErrNo = 0
	SET @ErrorChk = 0
	INSERT INTO Errorlog	  
	SELECT DISTINCT 1,'Cn2Cs_Prk_SampleReceipt','CompanyInvoiceNo ',CompanyInvoiceNo + ' is already available' 
	FROM Cn2Cs_Prk_SampleReceipt Where DownloadFlag = 'D'
	and CompanyInvoiceNo In (Select  CmpInvNo  From  SamplePurchaseReceipt)
	DECLARE Cur_SampleReceipt CURSOR
	FOR SELECT DISTINCT Isnull([CompanyCode],''),Isnull([SupplierCode],''),Isnull([LocationCode],''),
						Isnull([CompanyInvoiceNo],''),Isnull([InvoiceDate],''),
						Isnull([TransporterCode],''),Isnull([ProductCode],''),
						Isnull([BatchCode],''),Isnull([UomCode],''),Isnull([InvoiceQty],'')
		From Cn2Cs_Prk_SampleReceipt WHERE  DownloadFlag = 'D'  
		AND CompanyInvoiceNo NOT IN (Select CmpInvNo From  SamplePurchaseReceipt)		
		AND CompanyInvoiceNo NOT IN (SELECT CompanyInvoiceNo FROM TempSamplePurchaseReceipt)--ICRSTHUT0013
	OPEN Cur_SampleReceipt
	FETCH NEXT FROM Cur_SampleReceipt INTO @CmpCode,@SpmCode,@LocCode,@CmpInvNo,@CmpInvDate,@TransCode,
										   @CmpPrdCode,@BatchCode,@UomCode,@InvoiceQty
	WHILE @@FETCH_STATUS=0
	BEGIN 
			--- Company  
			IF NOT EXISTS(SELECT * FROM Company WITH (NOLOCK) WHERE CmpCode=@CmpCode)
			BEGIN
					INSERT INTO Errorlog 
					VALUES (1,@TabName,'Company',	'Company Code : '+ @CmpCode +' is not available')
					SET @Po_ErrNo=1
			END
			ELSE
			BEGIN		
					SELECT @CmpId = CmpId FROM Company WITH (NOLOCK)	WHERE CmpCode=@CmpCode  		
			END
			--- Supplier
			IF NOT EXISTS(SELECT * FROM Supplier WITH (NOLOCK) WHERE SpmCode=@SpmCode)
			BEGIN
				INSERT INTO Errorlog VALUES (2,@TabName,'Supplier','Supplier : '+ @SpmCode +' is not available')						
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @SpmId = SpmId FROM Supplier WITH (NOLOCK)	WHERE SpmCode=@SpmCode
			END
				
			--- Location
			IF NOT EXISTS(SELECT * FROM Location WITH (NOLOCK) WHERE LcnCode=@LocCode)
			BEGIN
				SELECT @LcnId = LcnId,@LocCode = LcnCode FROM Location WITH (NOLOCK) WHERE  DefaultLocation = 1
			END
			ELSE
			BEGIN
				SELECT @LcnId = LcnId FROM Location WITH (NOLOCK) WHERE LcnCode=@LocCode
			END
			--- Transporter
			IF NOT EXISTS(SELECT * FROM Transporter WITH (NOLOCK) WHERE TransporterCode=@TransCode)
			BEGIN
				SELECT @TransId = Min(TransporterId) FROM Transporter WITH (NOLOCK)
				SELECT @TransCode = TransporterCode  FROM Transporter WITH (NOLOCK) where TransporterId = @TransId
			END
			ELSE
			BEGIN
				SELECT @TransId = TransporterId FROM Transporter WITH (NOLOCK) WHERE TransporterCode=@TransCode
			END
			--- Company Invoice Number
			IF LTRIM(RTRIM(@CmpInvNo)) = ''
			BEGIN
				INSERT INTO Errorlog 
				VALUES (3,@TabName,'Company Invoice No','Company Invoice No should not be empty')
				SET @Po_ErrNo=1
			END	
			
			--- Invoice Date
			IF @CmpInvDate = ''
			BEGIN
				INSERT INTO Errorlog VALUES (4,@TabName,'Invoice Date',	@CmpInvNo + ' Invoice Date : '+ @CmpInvDate +' is not valid')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN 
				SET @InvDate = @CmpInvDate  ---  Convert(datetime,Convert(Varchar(10),@CmpInvDate,121),104)
				IF @InvDate > GETDATE()
				BEGIN
					INSERT INTO Errorlog VALUES (4,@TabName,'Invoice Date',
							@CmpInvNo + 'Invoice Date:' + CAST(@CmpInvDate AS NVARCHAR(20)) + ' is greater than current date for Invoice No:'+ Cast(@CmpInvNo as Varchar(100)))
							SET @Po_ErrNo=1
				END
			END
 		--- Company Product Code
			IF LTRIM(RTRIM(@CmpPrdCode)) <> ''
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT * FROM Product WITH (NOLOCK) WHERE PrdCCode = @CmpPrdCode)
				BEGIN
					INSERT INTO Errorlog VALUES (5,@TabName,'Product',
												@CmpInvNo + 'Company Product Code : '+ @CmpPrdCode +' is not available')
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @PrdId = PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@CmpPrdCode
				END
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog 
				VALUES (5,@TabName,'Company Product Code','Company Product Code should not be empty')
				SET @Po_ErrNo=1
			END
        --- Company Batch code 
			IF LTRIM(RTRIM(@BatchCode)) <> ''
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT * FROM ProductBatch A WITH (NOLOCK),Product B WITH (NOLOCK) 
				WHERE A.PrdId = B.PrdId AND PrdBatCode = @BatchCode AND PrdCCode = @CmpPrdCode)
				BEGIN
					INSERT INTO Errorlog VALUES (5,@TabName,'ProductBatch',
												@CmpInvNo + 'Company Product Batch Code : '+ @BatchCode +' is not available')
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @PrdBatId = PrdBatId FROM ProductBatch A WITH (NOLOCK),Product B WITH (NOLOCK) 
				    WHERE A.PrdId = B.PrdId AND PrdBatCode = @BatchCode AND PrdCCode = @CmpPrdCode
				END
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog 
				VALUES (6,@TabName,'Company Product Batch Code','Company Product Batch Code should not be empty')
				SET @Po_ErrNo=1
			END			
			---Uom Code
			IF LTRIM(RTRIM(@UomCode)) <> ''
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT * FROM UomMaster WITH (NOLOCK) WHERE UomCode = @UomCode)
				BEGIN
					INSERT INTO Errorlog VALUES (7,@TabName,'Uom',
												@CmpInvNo + ' Uom Code : '+ @UomCode +' is not available')
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @UomId = UomId FROM  UomMaster WITH (NOLOCK) WHERE UomCode = @UomCode
				END
				IF NOT EXISTS( SELECT UM.UomId,um.UomCode,UG.ConversionFactor
							   FROM UomGroup UG,UomMaster UM ,Product P
							   WHERE UG.UomId = UM.UomId AND P.UomGroupId = UG.UomGroupId AND
							   P.PrdId = @PrdId AND UG.UomId = @UomId)
				BEGIN
						INSERT INTO Errorlog VALUES (6,@TabName,'Invoice UOM',
						'Invoice UOM:'+ CAST(@UomCode AS NVARCHAR(100)) +' is not available for the product:'+ CAST(@CmpPrdCode  AS NVARCHAR(100)) 
						+' in Company Invoice No:'+ CAST(@CmpInvNo AS NVARCHAR(100)))
								
						SET @Po_ErrNo=1
				END
			END
			IF LTRIM(RTRIM(@UomCode)) = ''
			BEGIN
				INSERT INTO Errorlog 
				VALUES (8,@TabName,'Uom',@CmpInvNo + ' Uom Code should not be empty')
				SET @Po_ErrNo=1
			END
			---  Invoice Qty
			IF LTRIM(RTRIM(@InvoiceQty)) = 0
			BEGIN
				INSERT INTO Errorlog 
				VALUES (9,@TabName,'Quantity',@CmpInvNo + ' : ' + @CmpPrdCode + ' Quantity should not be empty')
				SET @Po_ErrNo=1
			END
			
			IF @Po_ErrNo = 0 and @InvoiceQty > 0 and @UomId > 0 and @PrdId > 0 And @PrdBatId > 0
			BEGIN
				INSERT INTO TempSamplePurchaseReceipt( [CompanyCode],[SupplierCode],[LocationCode],
								[CompanyInvoiceNo],[InvoiceDate],[TransporterCode],[ProductCode],
								[BatchCode],[UomCode],[InvoiceQty],AddInfo1,AddInfo2,AddInfo3,
								AddInfo4,AddInfo5,DownloadFlag)
				SELECT @CmpCode,@SpmCode,@LocCode,@CmpInvNo,@InvDate,@TransCode,
					   @CmpPrdCode,@BatchCode,@UomCode,@InvoiceQty,'','','','','','Y'
			END
			ELSE
			BEGIN
				INSERT INTO TempSamplePurchaseReceipt([CompanyInvoiceNo],DownloadFlag)
				VALUES(@CmpInvNo,'D')
			END
			SET @Po_ErrNo =  0
	FETCH NEXT FROM Cur_SampleReceipt INTO  @CmpCode,@SpmCode,@LocCode,@CmpInvNo,@CmpInvDate,@TransCode,
									        @CmpPrdCode,@BatchCode,@UomCode,@InvoiceQty
END	
	CLOSE Cur_SampleReceipt
	DEALLOCATE Cur_SampleReceipt
	DELETE FROM  TempSamplePurchaseReceipt where  [CompanyInvoiceNo] in (
				  Select [CompanyInvoiceNo] From  TempSamplePurchaseReceipt where DownloadFlag = 'D')
	UPDATE Cn2Cs_Prk_SampleReceipt SET DownloadFlag = 'Y'	WHERE [CompanyInvoiceNo] IN (
	SELECT [CompanyInvoiceNo] From  TempSamplePurchaseReceipt where DownloadFlag = 'Y')
	------ Product Batch Inserted
	--DECLARE @INVOICENO VARCHAR(100)
	--DECLARE @PRODUCTCODE VARCHAR(100)
	--DECLARE Cur_SampleReceiptBatch CURSOR
	--FOR Select Distinct [CompanyInvoiceNo],[ProductCode]
	--	From TempSamplePurchaseReceipt WHERE  DownloadFlag = 'Y'  		
	--	Open Cur_SampleReceiptBatch
	--	FETCH NEXT FROM Cur_SampleReceiptBatch INTO @INVOICENO,@PRODUCTCODE	
	--	WHILE @@FETCH_STATUS=0
	--	BEGIN 
	--		IF LTRIM(RTRIM(@PRODUCTCODE)) <> ''
	--		BEGIN
	--			IF NOT EXISTS(SELECT DISTINCT * FROM Product WITH (NOLOCK) WHERE PrdCCode = @CmpPrdCode)
	--			BEGIN
	--				INSERT INTO Errorlog VALUES (5,@TabName,'Product',
	--											@INVOICENO + 'Company Product Code : '+ @PRODUCTCODE +' is not available')
	--				SET @Po_ErrNo=1
	--			END
	--			ELSE
	--			BEGIN
	--				SELECT @PrdId = PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PRODUCTCODE
	--			END
	--		END
	--		ELSE
	--		BEGIN
	--			INSERT INTO Errorlog 
	--			VALUES (5,@TabName,'Company Product Code','Company Product Code should not be empty')
	--			SET @Po_ErrNo=1
	--		END
	
	--		IF @PrdId > 0  and @Po_ErrNo = 0
	--		BEGIN
	--		    IF Not Exists(SELECT * From ProductBatch Where CmpBatCode = 'Sample Batch' and PrdId = @PrdId)
	--			BEGIN
	--				SELECT  @CounterId = CurrValue FROM Counters  Where TabName = 'ProductBatch' 
	--				SET @CounterId = @CounterId + 1
					
	--				Select @BatSeqId = Max(BatchSeqId) From BatchCreationMaster
			
	--				INSERT INTO ProductBatch (PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,
	--							TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning,Availability,
	--							LastModBy,LastModDate,AuthId,AuthDate)	
	--				Values(@PrdId,@CounterId,'Sample Batch','Sample Batch','1900-01-01','1900-01-01',1,
	--					   0,@BatSeqId,6,0,0,1,1,GETDATE(),1,GETDATE())
	--				SET @PrdBatId =  @CounterId
	--				IF Not Exists(Select * from  ProductBatchDetails where PrdBatId = @CounterId)
	--				BEGIN
	--					SELECT  @DefPriceId = CurrValue FROM Counters  
	--					Where TabName = 'ProductBatchDetails' AND FldName = 'Priceid'
	--					SET @DefPriceId = @DefPriceId + 1
				
	--					INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,
	--											SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
	--											LastModBy,LastModDate,AuthId,AuthDate)
	--					Values(@DefPriceId,@CounterId,00-0.000000,@BatSeqId,1,0.000000,1,1,1,1,
	--						   GETDATE(),1,GETDATE())
	--					INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,
	--																	SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
	--																	LastModBy,LastModDate,AuthId,AuthDate)
	--					Values(@DefPriceId,@CounterId,00-0.000000,@BatSeqId,2,0.000000,1,1,1,1,
	--						   GETDATE(),1,GETDATE())
	--					INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,
	--																	SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
	--																	LastModBy,LastModDate,AuthId,AuthDate)
	--					Values(@DefPriceId,@CounterId,00-0.000000,@BatSeqId,3,0.000000,1,1,1,1,
	--						   GETDATE(),1,GETDATE())
	--					INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,
	--																	SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
	--																	LastModBy,LastModDate,AuthId,AuthDate)
	--					Values(@DefPriceId,@CounterId,00-0.000000,@BatSeqId,4,0.000000,1,1,1,1,
	--						   GETDATE(),1,GETDATE())
	--				END
	--				Update ProductBatch SET DefaultPriceId = @DefPriceId WHERE CmpBatCode = 'Sample Batch'
	--				Update Counters SET CurrValue = @CounterId Where TabName = 'ProductBatch' 
	--				Update Counters SET CurrValue = @DefPriceId 
	--								Where TabName = 'ProductBatchDetails' AND FldName = 'Priceid'
	--			END
	--			ELSE
	--			BEGIN
	--				Select @PrdBatId = PrdBatId From ProductBatch WHERE CmpBatCode = 'Sample Batch'
	--			END
	--		END
	--		FETCH NEXT FROM Cur_SampleReceiptBatch INTO  @INVOICENO,@PRODUCTCODE
	--	END	
	--CLOSE Cur_SampleReceiptBatch
	--DEALLOCATE Cur_SampleReceiptBatch
	----- Tiil Here
	RETURN
END
GO
DELETE FROM Configuration WHERE ModuleId IN ('GENCONFIG7','GENCONFIG8','GENCONFIG9','GENCONFIG22','GENCONFIG26','GENCONFIG27',
'DISTAXCOLL6','DISTAXCOLL7','GENCONFIG29','DISTAXCOLL5','GENCONFIG13','GENCONFIG14')
INSERT INTO Configuration 
SELECT 'GENCONFIG22','General Configuration','Display Quantity in UOM based',0,'0',0.00,22 UNION
SELECT 'GENCONFIG27','General Configuration','Enable Database restoration check',0,'',0.00,27 UNION
SELECT 'GENCONFIG7','General Configuration','1.00',1,'5',0.00,7 UNION
SELECT 'GENCONFIG8','General Configuration','Nearest',1,'0',1.00,8 UNION
SELECT 'GENCONFIG9','General Configuration','Display Batch automatically when single batch is available in the attached screens',0,'',0.00,9 UNION
SELECT 'GENCONFIG26','General Configuration','Save excel reports in',0,'',0.00,26 UNION
SELECT 'DISTAXCOLL6','Discount & Tax Collection','Automatically perform Vehicle allocation while saving the bill',1,'',0.00,6 UNION
SELECT 'DISTAXCOLL7','Discount & Tax Collection','Enable Bill Book Number Tracking in Billing Screen',0,'',0.00,7 UNION
SELECT 'DISTAXCOLL5','Discount & Tax Collection','Perform auto confirmation of bill',0,'',1.00,6 UNION
SELECT 'GENCONFIG29','General Configuration','Display selected UOM in billing and order booking screens',0,'0',0.00,29 UNION
SELECT 'GENCONFIG13','General Configuration','Currency',1,'Rupees',0.00,13 UNION
SELECT 'GENCONFIG14','General Configuration','Coin',1,'Paise',0.00,14
GO
DELETE FROM Configuration WHERE ModuleId='GENCONFIG31' AND ModuleName='General Configuration'
INSERT INTO configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('GENCONFIG31','General Configuration','Display selected UOM in Order',0,'',0.00,31)
GO
DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG32'
INSERT INTO Configuration
SELECT 'GENCONFIG32','General Configuration','Display selected UOM in Purchase Receipt',1,'0',0.00,32
GO
IF EXISTS (SELECT * FROM UomMaster WHERE UomCode = 'BX')
BEGIN
   DELETE FROM UomConfig
   DECLARE @UomId AS INT
   SELECT @UomId = UOMId FROM UomMaster WHERE UomCode = 'BX'
   INSERT INTO UomConfig (ModuleId,UomId,Value,Availability,LastModBy,LastModDate,AuthId,AuthDate)
   SELECT 'GENCONFIG32',@UomId,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_OrderProducts' AND XTYPE='TF')
DROP FUNCTION Fn_OrderProducts
GO
CREATE FUNCTION Fn_OrderProducts (@OrderNo AS VARCHAR(100),@SelUOM AS INT,@Type AS INT)
RETURNS @OrderProducts TABLE
(
	Prdid BIGINT,
	PrdDCode VARCHAR(100),
	PrdName VARCHAR(200),
	Prdbatid BIGINT,	
	PrdBatCode Varchar(100),
	BaseQty BIGINT,
	TotalQty BIGINT,
	PriceId BIGINT,
	MRP Numeric(36,6),
	SellRate Numeric(36,6)
)
AS
BEGIN
/*********************************
* FUNCTION: Fn_OrderProducts
* PURPOSE: Returns the Order ProductDetails
* NOTES:
* CREATED: Murugan.R	16/04/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
DECLARE @Product TABLE
(
	Prdid BIGINT,
	PrdDCode VARCHAR(100),
	Prdname VARCHAR(200),
	Prdbatid BIGINT,
	PriceId BIGINT,
	PrdBatCode Varchar(100),
	MRP Numeric(36,6),
	SellRate Numeric(36,6)
)
DECLARE @OrderBookingProducts TABLE
(
	Prdid BIGINT,
	Prdbatid BIGINT,
	PriceId BIGINT,
	BaseQty BIGINT,
	TotalQty BIGINT	
)
	INSERT INTO @Product(Prdid,PrdDCode,Prdname,Prdbatid,PriceId,PrdBatCode,MRP,SellRate)	
	SELECT DISTINCT Prdid,PrdDCode,Prdname,PrdBatId,PriceId,PrdBatCode ,SUM(MRP) as MRP,SUM([SellRate]) as [SellRate]
	FROM (
	Select P.PrdId,PrdDCode,Prdname,pb.PrdBatId,PriceId,PrdBatCode,PrdBatDetailValue  as MRP,0 as [SellRate]
	FROM Product P INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.Prdid 
	INNER JOIN BatchCreation B (NOLOCK) ON PB.BatchSeqId=B.BatchSeqId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PB.PrdBatId=PBD.PrdBatId and B.SlNo=PBD.SLNo
	WHERE  PBD.DefaultPrice=1 and MRP = 1 
	UNION ALL
	Select P.PrdId,PrdDCode,Prdname,pb.PrdBatId,PriceId,PrdBatCode,0  as MRP,PrdBatDetailValue  as [SellRate]
	FROM Product P INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.Prdid
	INNER JOIN BatchCreation B (NOLOCK) ON PB.BatchSeqId=B.BatchSeqId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PB.PrdBatId=PBD.PrdBatId and B.SlNo=PBD.SLNo
	WHERE  PBD.DefaultPrice=1 and SelRte = 1 )X
	GROUP BY Prdid,PrdDCode,Prdname,PrdBatId,PriceId,PrdBatCode
	
	INSERT INTO @OrderBookingProducts(Prdid,Prdbatid,PriceId,BaseQty,TotalQty)
	SELECT Prdid,Prdbatid,PriceId,(CASE @SelUOM WHEN 1 THEN SUM(Qty1) ELSE SUM(TotalQty) END) AS BaseQty,SUM(TotalQty) AS TotalQty
	FROM OrderBookingProducts (NOLOCK) WHERE OrderNo = @OrderNo
	GROUP BY Prdid,Prdbatid,PriceId	HAVING SUM(TotalQty - IsNull(BilledQty, 0)) > 0	
	
	IF @Type = 1
	BEGIN
		INSERT INTO @OrderProducts(Prdid,PrdDCode,PrdName,Prdbatid,PrdBatCode,BaseQty,TotalQty,PriceId,MRP,SellRate)
		SELECT X.Prdid,X.PrdDCode,X.PrdName,X.PrdBatId,X.PrdBatCode,BaseQty,TotalQty,X.PriceId,MRP,SellRate
		FROM @Product X INNER JOIN  @OrderBookingProducts Y ON 
		X.Prdid=Y.Prdid and X.Prdbatid=Y.Prdbatid and X.PriceId=Y.PriceId
	END
	IF @Type = 2
	BEGIN
	    INSERT INTO @OrderProducts(Prdid,PrdDCode,PrdName,Prdbatid,PrdBatCode,BaseQty,TotalQty,PriceId,MRP,SellRate)
		SELECT X.Prdid,X.PrdDCode,X.PrdName,X.PrdBatId,X.PrdBatCode,BaseQty,TotalQty,X.PriceId,MRP,
		(CASE @SelUOM WHEN 1 THEN ((TotalQty*SellRate)/BaseQty) ELSE SellRate END) AS SellRate
		FROM @Product X INNER JOIN  @OrderBookingProducts Y ON 
		X.Prdid=Y.Prdid and X.Prdbatid=Y.Prdbatid and X.PriceId=Y.PriceId
	END
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_GetStockLedgerSummaryDatewiseTemp' AND XTYPE='P')
DROP PROCEDURE Proc_GetStockLedgerSummaryDatewiseTemp
GO
--SELECT * FROM StockLedger
CREATE PROCEDURE Proc_GetStockLedgerSummaryDatewiseTemp
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_UserId		INT,
	@SupTaxGroupId		INT,
	@RtrTaxFroupId		INT,
	@Pi_OfferStock		INT
)
AS
/*********************************
* PROCEDURE	: Proc_GetStockLedgerSummaryDatewise
* PURPOSE	: To Get Stock Ledger Detail
* CREATED	: Nandakumar R.G
* CREATED DATE	: 15/02/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	TRUNCATE TABLE TempStockLedSummaryTotal
	DELETE FROM TaxForReport WHERE UsrId=@Pi_UserId AND RptId=100
-- Commeted on 18-Nov-2010 for report performence
--	EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UserId,100
	
	DECLARE @ProdDetail TABLE
		(
			lcnid	INT,
			PrdBatId INT,
			TransDate DATETIME
		)
	DELETE FROM @ProdDetail
	INSERT INTO @ProdDetail
		(
			lcnid,PrdBatId,TransDate
		)
	
	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
	(
		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) a LEFT OUTER JOIN
	(
		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) b
	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
	where b.lcnid is null and b.prdbatid is null
			
	DELETE FROM TempStockLedSummary WHERE UserId=@Pi_UserId
	
	--      Stocks for the given date---------
	IF @Pi_OfferStock=1
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
		(Sl.SalOpenStock+Sl.UnSalOpenStock+Sl.OfferOpenStock) AS Opening,
		(Sl.SalPurchase+Sl.UnsalPurchase+Sl.OfferPurchase) AS Purchase,
		(Sl.SalSales+Sl.UnSalSales+Sl.OfferSales) AS Sales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock+Sl.UnSalClsStock+Sl.OfferClsStock) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCateGOryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId AND
		Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	END
	ELSE
	BEGIN	
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
		(Sl.SalOpenStock+Sl.UnSalOpenStock) AS Opening,
		(Sl.SalPurchase+Sl.UnsalPurchase) AS Purchase,
		(Sl.SalSales+Sl.UnSalSales) AS Sales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-
		Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock+Sl.UnSalClsStock) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCateGOryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId AND
		Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	END	
	--      Stocks for those not included in the given date---------
	IF @Pi_OfferStock=1
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT @Pi_FromDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCateGOryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid
		AND Sl.TransDate< @Pi_FromDate
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	END
	ELSE
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT @Pi_FromDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCateGOryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid
		AND Sl.TransDate< @Pi_FromDate
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	END
	--      Stocks for those not included in the stockLedger---------
	INSERT INTO TempStockLedSummary
	(
	TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
	Purchase,Sales,Adjustment,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
	PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
	BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
	)			
	SELECT @Pi_FromDate AS TransDate,Lcn.LcnId,
	Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,
	0 AS Opening,0 AS Sales,0 AS Purchase,0 AS Adjustments,0 AS Closing,
	0,0,0,0,0,0,0,0,0,0,0,0,
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
	FROM
	ProductBatch PrdBat (NOLOCK),ProductCateGOryValue PCV (NOLOCK),Product Prd (NOLOCK)
	CROSS JOIN Location Lcn (NOLOCK)
	WHERE
		PrdBat.PrdBatId IN
		(
		SELECT PrdBatId FROM (
		SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM
		ProductBatch A (nolock) LEFT OUTER JOIN StockLedger B (nolock)
		ON A.Prdid =B.Prdid) a
		WHERE ISNULL(NewPrdBatId,0) = 0
	)
	AND PrdBat.PrdId=Prd.PrdId
	AND Prd.PrdCtgVAlMainId=PCV.PrdCtgValMainId
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,PrdBat.BatchSeqId
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	UPDATE TempStockLedSummary SET TotalStock=(Opening+Purchase+Sales+Adjustment+Closing)
	
--	UPDATE TempStockLedSummary SET TempStockLedSummary.PurchaseRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummary,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummary.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND TempStockLedSummary.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummary.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.ListPrice=1
--	
--	UPDATE TempStockLedSummary SET TempStockLedSummary.SellingRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummary,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummary.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND TempStockLedSummary.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummary.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.SelRte=1
	UPDATE TRSS SET TRSS.SellingRate=DPH.SellingRate,TRSS.PurchaseRate=DPH.PurchaseRate
	FROM TempStockLedSummary TRSS,DefaultPriceHistory DPH
	WHERE TRSS.PrdId=DPH.PrdId AND TRSS.PrdBatId=DPH.PrdBatId 
	--AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	
	UPDATE TempStockLedSummary SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	
	UPDATE TSL SET OpnPurRte=OpnPurRte+(Opening*ISNULL(Tax.PurchaseTaxAmount,0)),
	PurPurRte=PurPurRte+(Purchase*ISNULL(Tax.PurchaseTaxAmount,0)),
	SalPurRte=SalPurRte+(Sales*ISNULL(Tax.PurchaseTaxAmount,0)),
	AdjPurRte=AdjPurRte+(Adjustment*ISNULL(Tax.PurchaseTaxAmount,0)),
	CloPurRte=CloPurRte+(Closing*ISNULL(Tax.PurchaseTaxAmount,0)),
	OpnSelRte=OpnSelRte+(Opening*ISNULL(Tax.SellingTaxAmount,0)),
	PurSelRte=PurSelRte+(Purchase*ISNULL(Tax.SellingTaxAmount,0)),
	SalSelRte=SalSelRte+(Sales*ISNULL(Tax.SellingTaxAmount,0)),
	AdjSelRte=AdjSelRte+(Adjustment*ISNULL(Tax.SellingTaxAmount,0)),
	CloSelRte=CloSelRte+(Closing*ISNULL(Tax.SellingTaxAmount,0))
	FROM TempStockLedSummary TSL LEFT OUTER JOIN TaxForReport Tax
	ON Tax.PrdId=TSL.PrdId AND Tax.PrdBatId=TSL.PrdBatId AND TSL.UserId= Tax.UsrId AND Tax.RptId=100
--	SELECT * FROM TempStockLedSummary ORDER BY PrdId,PrdBatId,LcnId,TransDate
	
	SELECT MIN(TransDate) AS MinTransDate,MAX(TransDate) AS MaxTransDate,
	PrdId,PrdBatId,LcnId
	INTO #TempDates
	FROM TempStockLedSummary WHERE UserId=@Pi_UserId	
	GROUP BY PrdId,PrdBatId,LcnId
	ORDER BY PrdId,PrdBatId,LcnId
		
	
	INSERT INTO TempStockLedSummaryTotal(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,PurSelRte,SalSelRte,
	AdjSelRte,CloSelRte,BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock)
	SELECT T.PrdId,T.PrdBatId,T.LcnId,T.Opening,T.Purchase,T.Sales,T.Adjustment,T.Closing,
	T.PurchaseRate,T.OpnPurRte,T.PurPurRte,T.SalPurRte,T.AdjPurRte,T.CloPurRte,T.SellingRate,
	T.OpnSelRte,T.PurSelRte,T.SalSelRte,T.AdjSelRte,T.CloSelRte,T.BatchSeqId,T.PrdCtgValLinkCode,
	T.CmpId,T.Status,T.UserId,T.TotalStock
	FROM TempStockLedSummary T,#TempDates TD
	WHERE T.PrdId=TD.PrdId AND T.PrdBatId=TD.PrdBatId AND T.LcnId=TD.LcnId
	AND T.TransDate=TD.MinTransDate AND T.UserId=@Pi_UserId
	
	SELECT T.PrdId,T.PrdBatId,T.LcnId,SUM(T.Purchase) AS TotPur,SUM(T.Sales) AS TotSal,
	SUM(T.Adjustment) AS TotAdj
	INTO #TemDetails
	FROM TempStockLedSummary T,#TempDates TD
	WHERE T.PrdId=TD.PrdId AND T.PrdBatId=TD.PrdBatId AND T.LcnId=TD.LcnId
	AND T.TransDate BETWEEN TD.MinTransDate AND TD.MaxTransDate AND T.UserId=@Pi_UserId
	GROUP BY T.PrdId,T.PrdBatId,T.LcnId
	UPDATE TempStockLedSummaryTotal SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummaryTotal.PrdId AND T.PrdBatId=TempStockLedSummaryTotal.PrdBatId AND
	T.LcnId=TempStockLedSummaryTotal.LcnId
	UPDATE TempStockLedSummaryTotal SET Closing=Opening+Purchase-Sales+Adjustment
--	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.PurchaseRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.ListPrice=1
--	
--	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.SellingRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.SelRte=1
--	UPDATE TRSS SET TRSS.SellingRate=DPH.SellingRate,TRSS.PurchaseRate=DPH.PurchaseRate
--	FROM TempStockLedSummaryTotal TRSS,DefaultPriceHistory DPH
--	WHERE TRSS.PrdId=DPH.PrdId AND TRSS.PrdBatId=DPH.PrdBatId 
--	AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	UPDATE TempStockLedSummaryTotal SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	UPDATE TSLT SET OpnPurRte=OpnPurRte+(Opening*ISNULL(Tax.PurchaseTaxAmount,0)),
	PurPurRte=PurPurRte+(Purchase*ISNULL(Tax.PurchaseTaxAmount,0)),
	SalPurRte=SalPurRte+(Sales*ISNULL(Tax.PurchaseTaxAmount,0)),
	AdjPurRte=AdjPurRte+(Adjustment*ISNULL(Tax.PurchaseTaxAmount,0)),
	CloPurRte=CloPurRte+(Closing*ISNULL(Tax.PurchaseTaxAmount,0)),
	OpnSelRte=OpnSelRte+(Opening*ISNULL(Tax.SellingTaxAmount,0)),
	PurSelRte=PurSelRte+(Purchase*ISNULL(Tax.SellingTaxAmount,0)),
	SalSelRte=SalSelRte+(Sales*ISNULL(Tax.SellingTaxAmount,0)),
	AdjSelRte=AdjSelRte+(Adjustment*ISNULL(Tax.SellingTaxAmount,0)),
	CloSelRte=CloSelRte+(Closing*ISNULL(Tax.SellingTaxAmount,0))
	FROM TempStockLedSummaryTotal TSLT LEFT OUTER JOIN TaxForReport Tax ON 
	Tax.PrdId=TSLT.PrdId AND Tax.PrdBatId=TSLT.PrdBatId AND
	TSLT.UserId= Tax.UsrId AND Tax.RptId=100
	
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Fn_ReturnPrdBatchDetailsWithStock' AND XTYPE IN ('TF','FN'))
DROP FUNCTION Fn_ReturnPrdBatchDetailsWithStock
GO
-- SELECT * FROM DBO.Fn_ReturnPrdBatchDetailsWithStock(3334,1,2)
CREATE FUNCTION Fn_ReturnPrdBatchDetailsWithStock (@PrdId AS BIGINT,@LcnId	AS	INT,@OrderMode AS INT)
RETURNS @PrdBatchDetailsWithStock TABLE
	(
		PrdId		INT,
		PrdName		Varchar(150),
		PrdCCode	Varchar(50),
		PrdDCode	Varchar(50),
		PrdBatID	INT,
		BatchCode	Varchar(100),
		MRP			NUMERIC(18,6),
		LSP			NUMERIC(18,6),
		SellRate	NUMERIC(18,6),
		StockAvail	NUMERIC(18,0),
		PriceId		INT
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnPrdBatchDetailsWithStock
* PURPOSE: Returns the Product details with stock
* NOTES:
* CREATED: Boopathy.P
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
--DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),DATEADD(Day,PrdShelfLife,A.MnfDate)) as ShelfDay, DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),A.ExpDate) as ExpiryDay,
	IF @OrderMode=1
	BEGIN
		INSERT INTO @PrdBatchDetailsWithStock
		SELECT @PrdId,G.PrdName,G.PrdCCode,G.PrdDCode,A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,
		(F.PrdBatLcnSih - F.PrdBatLcnRessih) as StockAvail, B.PriceId FROM ProductBatch A (NOLOCK) 
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
		INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
		INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
		INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
		INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
		INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId WHERE A.Status = 1 
		AND A.PrdId=@PrdId AND F.LcnId = @LcnId And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 
		AND B.PrdBatDetailValue >= D.PrdBatDetailValue ORDER BY (F.PrdBatLcnSih - F.PrdBatLcnRessih)DESC
	END
	ELSE
	BEGIN
		INSERT INTO @PrdBatchDetailsWithStock
		SELECT @PrdId,G.PrdName,G.PrdCCode,G.PrdDCode,A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,
		(F.PrdBatLcnSih - F.PrdBatLcnRessih) as StockAvail, B.PriceId FROM ProductBatch A (NOLOCK) 
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
		INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
		INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
		INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
		INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
		INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId WHERE A.Status = 1 
		AND A.PrdId=@PrdId AND F.LcnId = @LcnId And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 
		AND B.PrdBatDetailValue >= D.PrdBatDetailValue ORDER BY A.PrdBatId DESC
	END
RETURN
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE ID= OBJECT_ID('RptGroup') and Name='VISIBILITY')
BEGIN
	ALTER TABLE RptGroup ADD VISIBILITY INT DEFAULT 1 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'BotreeAddress')
DROP TABLE BotreeAddress
GO
CREATE TABLE BotreeAddress
(  
 [Address] NVARCHAR(4000),
 [Email] NVARCHAR(1000),
 [Status] INT
)
GO
DELETE FROM BotreeAddress
INSERT INTO BotreeAddress ([Address],[Email],[Status])
SELECT '                 Developed By :  Botree Software International Private Limited                                                        37, Nelson Manickam Road                                                                                         Chennai - 600029                                                                                                            +91-44-23741591                                                                                                                                                                                                                ','E-mail              :      corestockysupport@botree.co.in',0 UNION
SELECT '                 Developed By :  Botree Software International Private Limited                                                       Second Floor, WSS Towers,No.107,Harris Road,                                                                      Chennai - 600002                                                                                                            +91-44-28551591                                                                                                                                                                                                                ','E-mail              :      corestockysupport@botree.co.in',1
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 405',405
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 405)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(405,'D','2013-09-05',GETDATE(),1,'Core Stocky Service Pack 405')
GO