--[Stocky HotFix Version]=387
Delete from Versioncontrol where Hotfixid='387'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('387','2.0.0.5','D','2011-09-07','2011-09-07','2011-09-07',convert(varchar(11),getdate()),'Major: Product Release FOR Akzo Nobal Cr')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 387' ,'387'
GO
DELETE FROM MenuDef WHERE MenuId='mStk28'
INSERT INTO MenuDef(SrlNo,MenuId,MenuName,ParentId,Caption,MenuStatus,FormName,DefaultCaption )
SELECT 172,'mStk28','mnuFTPUpload','mStk','FTP Upload',0,'frmFTP','FTP Upload'
GO
DELETE FROM ProfileDt WHERE MenuId='mStk28'
INSERT INTO ProfileDt(PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT PrfId,'mStk28',1,'FTPUpload',1,1,1,Getdate(),1,Getdate()
FROM ProfileHd
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[ExtractAksoNobal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[ExtractAksoNobal]
	(
		[SlNo] [int] NULL,
		[ExtractFileName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SPName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TblName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TransType] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FileName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RptId] [int] NULL
	) ON [PRIMARY]
end
GO
DELETE FROM ExtractAksoNobal WHERE Slno=10
INSERT INTO ExtractAksoNobal(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId)
SELECT 10,'Pending Bills','Proc_AN_Pendingbills','PendingBillsExtractExcel','Master','ExcelExtract',510 
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='PendingBillsExtractExcel')
DROP TABLE PendingBillsExtractExcel
GO
CREATE TABLE PendingBillsExtractExcel
(
	[Distributor Code]		VARCHAR(50),
	[Distributor Name]		VARCHAR(100),
	[Salesman]				VARCHAR(75),
	[Route]					VARCHAR(75),
	[Retailer Code]			VARCHAR(50),
	[Retailer Name]				VARCHAR(100),
	[Bill Number]			VARCHAR(50),
	[Bill Date]				DATETIME,
	[Doc Ref No]			VARCHAR(50),
	[Bill Amount]			NUMERIC(36,2),
	[Collected Amount]		NUMERIC(36,2),
	[Balance Amount]		NUMERIC(36,2),
	[AR Days]				INT
)
GO

IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AN_Pendingbills')
DROP PROCEDURE Proc_AN_Pendingbills
GO
--EXEC Proc_AN_Pendingbills '2011-08-12','2011-08-12'
--SELECT * FROM PendingBillsExtractExcel
CREATE PROCEDURE [Proc_AN_Pendingbills]  
(  
 @Pi_FromDate  DATETIME,  
 @Pi_ToDate DATETIME  
)  
AS 
/**************************************************************************
* PROCEDURE : Proc_AN_Pendingbills
* PURPOSE : To Export pending bills details
* CREATED : Murugan.R
* CREATED DATE :11/08/2011
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
---------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}.
***************************************************************************/
SET NOCOUNT ON  
BEGIN  
   
	TRUNCATE TABLE PendingBillsExtractExcel  
	INSERT INTO PendingBillsExtractExcel (
	[Distributor Code],[Distributor Name],[Salesman],[Route],[Retailer Code],[Retailer Name],[Bill Number],
	[Bill Date],[Doc Ref No],[Bill Amount],[Collected Amount],[Balance Amount],[AR Days])
	SELECT DistributorCode,DistributorName,SMName,RMName,RtrCode,RtrName,
	SalInvNo,SalInvDate,SalInvRef,SalNetAmt,SalPayAmt,(SalNetAmt-SalPayAmt),DateDiff(Day,SalInvDate,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121)) as ArDays
	FROM SalesInvoice SI 
	INNER JOIN Retailer R ON R.Rtrid=SI.Rtrid
	INNER JOIN SalesMan S ON S.SMID=SI.SMID
	INNER JOIN RouteMaster RM ON RM.RMID=SI.RMID
	CROSS JOIN Distributor D    
	WHERE Dlvsts>3   and (SalNetAmt-SalPayAmt)>0
	ORDER BY SalInvDate,SalInvNo 
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[RptAKSOExcelHeaders]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[RptAKSOExcelHeaders]
	(
		[RptId] [int] NULL,
		[SlNo] [int] NULL,
		[FieldName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DisplayName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DisplayFlag] [int] NULL,
		[LngId] [int] NULL
	) ON [PRIMARY]
end
GO
DELETE FROM RptAKSOExcelHeaders WHERE Rptid=510
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
SELECT 510,1,'Distributor Code','Distributor Code',1,1
UNION ALL
SELECT 510,2,'Distributor Name','Distributor Name',1,1
UNION ALL
SELECT 510,3,'Salesman','Salesman',1,1
UNION ALL
SELECT 510,4,'Route','Route',1,1
UNION ALL
SELECT 510,5,'Retailer Code','Retailer Code',1,1
UNION ALL
SELECT 510,6,'Retailer Name','Retailer Name',1,1
UNION ALL
SELECT 510,7,'Bill Number','Bill Number',1,1
UNION ALL
SELECT 510,8,'Bill Date','Bill Date',1,1
UNION ALL
SELECT 510,9,'Doc Ref No','Doc Ref No',1,1
UNION ALL
SELECT 510,10,'Bill Amount','Bill Amount',1,1
UNION ALL
SELECT 510,11,'Collected Amount','Collected Amount',1,1
UNION ALL
SELECT 510,12,'Balance Amount','Balance Amount',1,1
UNION ALL
SELECT 510,13,'AR Days','AR Days',1,1
GO

DELETE FROM ExtractAksoNobal WHERE Slno=11
INSERT INTO ExtractAksoNobal(SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId)
SELECT 11,'Current Stock','Proc_AN_CurrentStock','CurrentStockExtractExcel','Master','ExcelExtract',511 
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='CurrentStockExtractExcel')
DROP TABLE CurrentStockExtractExcel
GO
CREATE TABLE CurrentStockExtractExcel
(
[Distributor Code]			VARCHAR(50),
[Distributor Name]			VARCHAR(100),
[Product Code]				VARCHAR(50),
[Product Name]				VARCHAR(100),
[Batch Code]				VARCHAR(50),
[MRP]						NUMERIC(36,6),
[Rate]						NUMERIC(36,6),
[Saleable Qty]				NUMERIC(36,0),
[Saleable Qty in Volume]	NUMERIC(36,6),
[Unsaleable Qty]			NUMERIC(36,0),
[Unsaleable Qty in Volume]	NUMERIC(36,6),
[Offer Qty]					NUMERIC(36,0),
[Offer Qty in Volume]		NUMERIC(36,6),
[Saleable Value]			NUMERIC(36,6),
[UnSaleable Value]			NUMERIC(36,6),
[Total Value]				NUMERIC(36,6)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AN_CurrentStock')
DROP PROCEDURE Proc_AN_CurrentStock
GO
--EXEC Proc_AN_CurrentStock '2011-01-01','2011-08-01'
--SELECT * FROM CurrentStockExtractExcel
CREATE PROCEDURE [Proc_AN_CurrentStock]  
(  
 @Pi_FromDate  DATETIME,  
 @Pi_ToDate DATETIME  
)  
AS 
/**************************************************************************
* PROCEDURE : Proc_AN_CurrentStock
* PURPOSE : To Export Current Stockdetails
* CREATED : Murugan.R
* CREATED DATE :11/08/2011
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
---------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}.
***************************************************************************/
SET NOCOUNT ON  
BEGIN  
   
	TRUNCATE TABLE CurrentStockExtractExcel  
	SELECT Prdid,Prdbatid,Priceid,SUM(MPR) as MPR,SUM(ListPrice) as ListPrice,SUM(SellingRate) as SellingRate
	INTO #TempProductPrice
	FROM
		(
		SELECT P.Prdid,PB.Prdbatid,PBL.Priceid,PrdBatDetailValue  as MPR ,0 as ListPrice ,0 as SellingRate
		FROM Product P 
		INNER JOIN Productbatch	PB ON P.Prdid=Pb.PrdId
		INNER JOIN Productbatchdetails	PBL ON PBL.PrdbatId=Pb.PrdbatId and PB.DefaultPriceId=PBL.PriceId
		INNER JOIN BatchCreation B ON B.Slno=PBL.SlNo and B.BatchseqId=PBl.BatchseqId
		WHERE DefaultPrice=1  and MRP=1
		UNION ALL
		SELECT P.Prdid,PB.Prdbatid,PBL.Priceid,0 as MRP,PrdBatDetailValue as ListPrice,0 as SellingRate 
		FROM Product P 
		INNER JOIN Productbatch	PB ON P.Prdid=Pb.PrdId
		INNER JOIN Productbatchdetails	PBL ON PBL.PrdbatId=Pb.PrdbatId and PB.DefaultPriceId=PBL.PriceId
		INNER JOIN BatchCreation B ON B.Slno=PBL.SlNo and B.BatchseqId=PBl.BatchseqId
		WHERE DefaultPrice=1  and ListPrice=1
		UNION ALL
		SELECT P.Prdid,PB.Prdbatid,PBL.Priceid,0 as MRP,0 as ListPrice,PrdBatDetailValue as SellingRate 
		FROM Product P 
		INNER JOIN Productbatch	PB ON P.Prdid=Pb.PrdId
		INNER JOIN Productbatchdetails	PBL ON PBL.PrdbatId=Pb.PrdbatId and PB.DefaultPriceId=PBL.PriceId
		INNER JOIN BatchCreation B ON B.Slno=PBL.SlNo and B.BatchseqId=PBl.BatchseqId
		WHERE DefaultPrice=1  and SelRte=1
		)X 			
		GROUP BY Prdid,Prdbatid,Priceid

		INSERT INTO CurrentStockExtractExcel (
		[Distributor Code],[Distributor Name],[Product Code],[Product Name],[Batch Code],[MRP],
		[Rate],[Saleable Qty],[Saleable Qty in Volume],[Unsaleable Qty],[Unsaleable Qty in Volume],
		[Offer Qty],[Offer Qty in Volume],[Saleable Value],
		[UnSaleable Value],[Total Value])
		SELECT DistributorCode,DistributorName,Prdccode,PrdName,CmpBatCode,MPR,SellingRate,
		SUM(PrdBatLcnSih-PrdBatLcnRessih) as SaleableQty,
		SUM(PrdBatLcnSih-PrdBatLcnRessih) * PrdWgt as [Saleable Qty in Volume],
		SUM(PrdBatLcnUih-PrdBatLcnResUih) as UnSaleableQty,SUM(PrdBatLcnUih-PrdBatLcnResUih) * PrdWgt as [Unsaleable Qty in Volume],
		SUM(PrdBatLcnFre-PrdBatLcnResFre) as FreeQty,SUM(PrdBatLcnFre-PrdBatLcnResFre) * PrdWgt as [Offer Qty in Volume], 
		SUM(PrdBatLcnSih-PrdBatLcnRessih)*SellingRate as SalesValue,
		SUM(PrdBatLcnUih-PrdBatLcnResUih)*SellingRate as UnSalesValue,
		(SUM(PrdBatLcnSih-PrdBatLcnRessih)+SUM(PrdBatLcnUih-PrdBatLcnResUih))*SellingRate as TotalSalesValue
		FROM ProductbatchLocation PBL
		INNER JOIN Product P ON P.Prdid=PBL.Prdid
		INNER JOIN Productbatch PB ON PB.Prdid=P.Prdid  and PBL.Prdid=PB.Prdid and PB.Prdbatid=PBL.Prdbatid
		INNER JOIN #TempProductPrice T ON T.PrdId=PBL.Prdid and T.Prdid=P.Prdid
		and PB.Prdid=T.Prdid and T.Prdbatid=PBL.Prdbatid and T.Prdbatid=PB.Prdbatid
		CROSS JOIN Distributor D 
		GROUP BY DistributorCode,DistributorName,Prdccode,PrdName,CmpBatCode,MPR,SellingRate,PrdWgt

END
GO
DELETE FROM RptAKSOExcelHeaders WHERE Rptid=511
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
SELECT 511,1,'Distributor Code','Distributor Code',1,1 UNION ALL
SELECT 511,2,'Distributor Name','Distributor Name',1,1  UNION ALL
SELECT 511,3,'Product Code','Product Code',1,1  UNION ALL
SELECT 511,4,'Product Name','Product Name',1,1  UNION ALL
SELECT 511,5,'Batch Code','Batch Code',1,1  UNION ALL
SELECT 511,6,'MRP','MRP',1,1  UNION ALL
SELECT 511,7,'Rate','Rate',1,1  UNION ALL
SELECT 511,8,'Saleable Qty','Saleable Qty',1,1  UNION ALL
SELECT 511,9,'Saleable Qty in Volume','Saleable Qty in Volume',1,1  UNION ALL
SELECT 511,10,'Unsaleable Qty','Unsaleable Qty',1,1  UNION ALL
SELECT 511,11,'Unsaleable Qty in Volume','Unsaleable Qty in Volume',1,1  UNION ALL
SELECT 511,12,'Offer Qty','Offer Qty',1,1  UNION ALL
SELECT 511,13,'Offer Qty in Volume','Offer Qty in Volume',1,1  UNION ALL
SELECT 511,14,'Saleable Value','Saleable Value',1,1  UNION ALL
SELECT 511,15,'UnSaleable Value','UnSaleable Value',1,1  UNION ALL
SELECT 511,16,'Total Value','Total Value',1,1
GO
DECLARE @FMaxReasoId Int 
IF NOT EXISTS (SELECT * FROM ReasonMaster WHERE Description='Auto Debit/Credit Note')
	BEGIN 
		DELETE FROM ReasonMaster WHERE Description='Auto Debit/Credit Note'
		SELECT @FMaxReasoId=max(ReasonID)+1 FROM ReasonMaster
		INSERT INTO ReasonMaster VALUES 
		(@FMaxReasoId,'R022','Auto Debit/Credit Note',1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,'2011-09-02',1,'2011-09-02')
		UPDATE Counters SET CurrValue =@FMaxReasoId WHERE TabName='ReasonMaster' AND FldName='ReasonId'
	END 

DELETE FROM HotsearchEditorHd WHERE FormId=10048
INSERT INTO HotsearchEditorHd
SELECT 10048,'Auto DB/CD','Reference No','SELECT',
'SELECT DISTINCT RefId,RefNo,RefDate FROM ACDDBSDetails Order by RefId'

DELETE FROM HotsearchEditorDt WHERE FormId=10048
INSERT INTO HotsearchEditorDt
SELECT 1,10048,'Auto DB/CD','Reference No','RefNo',7500,0,'',1000

if not exists (Select Id,name from Syscolumns where name = 'AutoDBCD' and id in (Select id from 
	Sysobjects where name ='SalesInvoice'))
begin
	ALTER TABLE [dbo].[SalesInvoice]
	ADD [AutoDBCD] Int NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[AutoDbCrSlabConfig]') and OBJECTPROPERTY(id, N'IsTABLE') = 1)
begin
	CREATE TABLE AutoDbCrSlabConfig (
			ModuleId nVarchar(20),
			SlabName nVarchar(150),
			SlabId int,
			CreditPeriod int,
			Discount numeric(10,4)
			)
end
GO


DELETE FROM COUNTERS WHERE TabName='AutoDBCDCreation' AND CurrValue=0
IF NOT EXISTS (SELECT * FROM COUNTERS WHERE TabName='AutoDBCDCreation')
BEGIN
	INSERT INTO COUNTERS (TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,
							CurYear,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT 'AutoDBCDCreation','RefDBCDId','',0,1,0,'Auto DBCD Creation',0,YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE()
	UNION
	SELECT 'AutoDBCDCreation','RefDBCDNo','ADC',5,1,0,'Auto DBCD Creation',1,YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE()
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='RaiseCreditDebit' AND xtype='U')
DROP TABLE RaiseCreditDebit
GO
CREATE TABLE RaiseCreditDebit
(
CrDr varchar(100),
Salid int,
Rtrid int,
CrAmt numeric(28,6),
Discount numeric(28,6),
OrgAmt numeric(28,6),
CRDBInt numeric(28,6),
MaxPerc numeric(18,6)
)
GO

IF NOT  EXISTS (SELECT * FROM sysobjects WHERE name='AutoRaisedCreditDebit' AND xtype='U')
 BEGIN 
	CREATE TABLE AutoRaisedCreditDebit
	(
	RtrId Int,
	RtrCode nvarchar(50),
	RtrName nVarchar(200),
	Salid int,
	SalInvNo nVarchar(50),
	SalInvDate Datetime,
	DBCRNoteNo nVarchar(50),
	DBCRNoteAmt numeric(28,6)
	)
 END 
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AutoDBCDSlabAchieved' AND xtype='U')
BEGIN 
	CREATE TABLE AutoDBCDSlabAchieved
	(
	SalID BigInt,
	SalInvNo nVarchar(50)
	)
END 
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AutoDBCDPrdSlabAchieved' AND xtype='U')
BEGIN 
	CREATE TABLE AutoDBCDPrdSlabAchieved
	(
	SalID BigInt,
	PrdId Int,
	PrdBatId Int,
	SlabId Int,
	DiffAmt numeric(28,6),
	CollnAmt numeric(28,6)
	)
END 
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ACDDBSDetails' AND xtype='U')
BEGIN 
	CREATE TABLE ACDDBSDetails
	(
	RefId Int,
	RefNo nVarchar(50),
	RefDate Datetime,
	RtrId Int,
	Salid int,
	DBCRNoteNo nVarchar(50),
	DBCRNoteAmt numeric(28,6),
	Availability int,
	LastModBy int,
	LastModDate Datetime,
	AuthId int,
	AuthDate Datetime
)
END 
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AutoDBCDProductTax' AND xtype='U')
BEGIN 
	CREATE TABLE [AutoDBCDProductTax](
		[SalId] [bigint] NOT NULL,
		[PrdSlNo] [int] NOT NULL,
		[TaxId] [int] NOT NULL,
		[TaxPerc] [numeric](10, 6) NOT NULL,
		[TaxableAmount] [numeric](18, 6) NOT NULL,
		[TaxAmount] [numeric](18, 6) NOT NULL,
		[MaxTaxPerc] [numeric](10, 6) NOT NULL,
		[Availability] [tinyint] NULL,
		[LastModBy] [tinyint] NULL,
		[LastModDate] [datetime] NULL,
		[AuthId] [tinyint] NULL,
		[AuthDate] [datetime] NULL,
		[SlabId] [int]
	) ON [PRIMARY]
END 
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AutoDBCDCreation')
DROP PROCEDURE Proc_AutoDBCDCreation
GO
/*
BEGIN TRANSACTION
exec Proc_AutoDBCDCreation 'a','2011-09-05'
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_AutoDBCDCreation
(
	@Pi_RefNo		nVarchar(10),
	@Pi_TransDate   DATETIME 
)
AS

SET NOCOUNT ON
BEGIN

	DECLARE @Slabid AS int 
	DECLARE @CreditPeriod AS int 
	DECLARE @Discount AS numeric(18,6)
	DECLARE @salinvno AS varchar(50)
	DECLARE @salid AS int 
	DECLARE @SalCDPer AS numeric(18,6)
	DECLARE @CashDis AS numeric(18,6)
	DECLARE @DiffAmt AS numeric(18,6)
	DECLARE @CollectionAmt AS  numeric(18,6)
	DECLARE @CashDis1 AS numeric(18,6)
	DECLARE @Rtrid AS int
	DECLARE @DateDiff AS Int
	DECLARE @DebitCreditNo AS nvarchar(100)
	DECLARE @CrDbNoteDate AS DATETIME
	DECLARE @AccCoaId	AS INT
	DECLARE @DBCRRtrID AS Int 
	DECLARE @CRDBName AS nVarchar(20)
	DECLARE @CRDBSalid AS BigInt
	DECLARE @DBCRCollectionAmt numeric(28,6)
	DECLARE @DBCDRtrCode AS nVarchar(20)
	DECLARE @DBCDRtrName AS nVarchar(200)
	DECLARE @DBCDSalInvNo AS nVarchar(100)
	DECLARE @DBCDSalInvDate AS datetime 
	DECLARE @FindReasoId AS INT
	DECLARE @TobeCalAmt numeric(28,6)
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS Int 
	DECLARE @Slno AS INT
	DECLARE @Row AS INT 
	DECLARE @DiffIntAmt AS numeric(28,6)
	DECLARE @MaxTaxPerc AS numeric(15,6)
	DECLARE @MaxCRDVBPerc AS numeric(15,6)
	DECLARE @ErrStatus			INT
	DECLARE @FStatus AS INT
	DECLARE @MAxCreditPeriod AS INT
	DECLARE @MaxSlabid AS INT
	DECLARE @FFromDate AS datetime 	

-- To be commented
	TRUNCATE TABLE  RaiseCreditDebit
	TRUNCATE TABLE AutoRaisedCreditDebit
-- end here
	SET @DiffIntAmt=0
	SET @MaxTaxPerc=0

	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='DBCRNOTE15' AND Status=1)
		BEGIN 
			 SET @FStatus=1
		END 
    ELSE
		BEGIN 
			SET @FStatus=0
		END 

	SET @ErrStatus=1

	SELECT @FFromDate=FixedOn FROM HotFixLog WHERE FixId=387
	
	DECLARE cur_CreditSlab CURSOR
	FOR SELECT Slabid,CreditPeriod,Discount FROM AutoDbCrSlabConfig ORDER BY slabid
	OPEN cur_CreditSlab
	FETCH next FROM cur_CreditSlab INTO @Slabid,@CreditPeriod,@Discount
	WHILE @@Fetch_status=0
	BEGIN 
		SET @DiffIntAmt=0
		SET @MaxTaxPerc=0
		DECLARE cur_Salinvno CURSOR
		FOR SELECT salinvno,SalId,PrdId,PrdBatId,Slno,SalCDPer,(sum(ActPrdGross)-sum(OrgGrossAmt))DiffAmt,isnull(sum(OrgGrossAmt),0)CollectionAmt,Rtrid
			FROM (
				SELECT DISTINCT SIP.Slno,SIP.PrdId,sip.Prdbatid,salinvno,SI.SalId,SalCDPer,si.SalGrossAmount,A.SalInvAmt CollectionAmt,
					sum((PrdGrossAmount - ISnull(PrdGrossAmt,0))*(isnull(A.SalInvAmt,0)/(SalNetAmt))) OrgGrossAmt,SI.RtrId,sum(PrdGrossAmount) ActPrdGross
				FROM salesinvoice SI INNER JOIN salesinvoiceproduct SIP ON SI.salid=SIP.salid 
				LEFT OUTER JOIN (SELECT SalId,sum(SalInvAmt)SalInvAmt FROM ReceiptInvoice RI INNER JOIN Receipt R ON R.InvRcpNo=RI.InvRcpNo
			    WHERE datediff(day,RI.SalInvDate,R.InvRcpDate)<=@CreditPeriod 
			    GROUP BY SalId)A ON A.salid=SI.salid AND A.salid=SIP.SalId
			    LEFT OUTER JOIN (SELECT RH.Salid,RP.PrdId,Rp.PrdBatId,sum(PrdGrossAmt) PrdGrossAmt FROM ReturnHeader RH INNER JOIN ReturnProduct RP ON RH.returnid=RP.ReturnId
					GROUP BY RH.Salid,RP.PrdId,Rp.PrdBatId) B ON B.SalId=SI.SalId AND B.PrdId=SIP.PrdId AND B.PrdBatId=SIP.PrdBatId
			    WHERE DlvSts>=4  AND AutoDBCD=0 AND SalInvDate>=CONVERT(NVARCHAR(10),@FFromDate,121) --AND SI.SalId=6
			    GROUP BY SIP.Slno,SIP.PrdId,sip.Prdbatid,SI.SalId,SI.RtrId,SalCDPer,SalInvNo,si.SalGrossAmount,A.SalInvAmt,Rtrid)A
			    GROUP BY salinvno,SalId,PrdId,PrdBatId,Slno,SalCDPer,Rtrid
		OPEN cur_Salinvno
		FETCH next FROM cur_Salinvno INTO @salinvno,@salid,@PrdId,@PrdBatId,@Row,@SalCDPer,@DiffAmt,@CollectionAmt,@Rtrid
		WHILE @@Fetch_status=0
		BEGIN 
		SET @DiffIntAmt=0
		SET @MaxTaxPerc=0
		SELECT @DateDiff=datediff(day,Si.SalInvDate,isnull(InvRcpDate,getdate())) FROM Salesinvoice SI 
			LEFT OUTER JOIN (SELECT SalId,max(InvRcpDate) InvRcpDate FROM ReceiptInvoice RI INNER JOIN Receipt R ON R.InvRcpNo=RI.InvRcpNo GROUP BY SalId) B
			ON SI.SalId=B.SalId
			WHERE SI.SalId=@SalId
	   
		--SELECT @DateDiff,@CreditPeriod,@DiffAmt
		IF NOT EXISTS (SELECT * FROM AutoDBCDPrdSlabAchieved WHERE SalId=@salid AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND SlabId=@Slabid)
			BEGIN 
				IF @DateDiff>@CreditPeriod AND @DiffAmt>0
					BEGIN 
						INSERT INTO AutoDBCDPrdSlabAchieved
							SELECT @salid,@PrdId,@PrdBatId,@Slabid,@DiffAmt,@CollectionAmt

						IF 	@Slabid=1 
							BEGIN 		
								SELECT @CashDis=SalCDPer FROM salesinvoice WHERE SalId=@salid     
							END 
						ELSE 
							BEGIN
								SET @CashDis=0
							END 
						IF @CashDis=0
							BEGIN 
								IF exists (SELECT  * FROM salesinvoice WHERE SalCDPer>0 AND SalId=@salid)
									BEGIN 
										SET @CashDis1=@Discount-@CashDis

										SET @TobeCalAmt= ((@DiffAmt*@CashDis1)/100) 	

										--SELECT 'a',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
										IF @FStatus=1
											BEGIN 
												EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid							
												
												SELECT @DiffIntAmt= sum(TaxAmount) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
												SELECT @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
											END 
										INSERT INTO RaiseCreditDebit
										SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
									END 
								ELSE
									BEGIN 
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														--SELECT 'b1',@DiffAmt,@CashDis,@Row
														--SELECT 'b',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
														IF @FStatus=1
														BEGIN
															EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
															
															SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
															SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
										ELSE
											BEGIN 
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid
												SET @CashDis=@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @FStatus=1
														BEGIN
															EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
															
															SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
															SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END
											END 
									END 
							END
						ELSE
							BEGIN 
								IF @CashDis-@Discount=0 
									BEGIN 
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1

												SET @TobeCalAmt= ((@DiffAmt*@CashDis)/100)
												--SELECT 'd',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @FStatus=1
													BEGIN
														EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid

														SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													END 
												INSERT INTO RaiseCreditDebit
												SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
											END 
										ELSE
											BEGIN 

												SET @TobeCalAmt= ((@DiffAmt*@Discount)/100)
												--SELECT 'e',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @FStatus=1
													BEGIN
														EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid

														SELECT  @DiffIntAmt=sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													END 
												INSERT INTO RaiseCreditDebit
												SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@Discount,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
											END 
									END 
								ELSE 
									BEGIN
										IF 	@CollectionAmt >0 
											BEGIN 
												SET @CashDis1=@Discount-@CashDis
												SET @TobeCalAmt= ((@CollectionAmt*@CashDis1)/100)
												--SELECT 'f',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @FStatus=1
													BEGIN
														EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
														
														SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													END 
													INSERT INTO RaiseCreditDebit
													SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc	
											END 	
										ELSE
											BEGIN 
												SELECT @MaxSlabid=max(Slabid) FROM AutoDbCrSlabConfig
												IF @Slabid = @MaxSlabid
													BEGIN 
														SELECT @CashDis1 = SalCDPer FROM salesinvoice WHERE SalCDPer>0 AND SalId=@salid
														SET @TobeCalAmt= ((@DiffAmt*@CashDis1)/100) 	
														--SELECT 'a',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
														IF @FStatus=1
															BEGIN 
																EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid							
																
																SELECT @DiffIntAmt= sum(TaxAmount) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																SELECT @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
									END 
							END 
					END 	
			END 
		SELECT @MAxCreditPeriod=CreditPeriod FROM AutoDbCrSlabConfig WHERE SlabId IN (SELECT max(Slabid) FROM AutoDbCrSlabConfig)
		IF @MAxCreditPeriod<@DateDiff
			BEGIN 
				IF NOT EXISTS (SELECT * FROM AutoDBCDSlabAchieved WHERE SalId=@salid)
					BEGIN 
						INSERT INTO AutoDBCDSlabAchieved
							SELECT @salid,@salinvno
					END 
			END 
		
		FETCH next FROM cur_Salinvno INTO @salinvno,@salid,@PrdId,@PrdBatId,@Row,@SalCDPer,@DiffAmt,@CollectionAmt,@Rtrid
		END 
		CLOSE cur_Salinvno
		DEALLOCATE cur_Salinvno
	FETCH next FROM cur_CreditSlab INTO @Slabid,@CreditPeriod,@Discount
	END 
	CLOSE cur_CreditSlab
	DEALLOCATE cur_CreditSlab


	DECLARE cur_CreditDebtitGen CURSOR
		FOR SELECT CrDr,Salid,Rtrid,MaxPerc,sum(CrAmt+CRDBInt) CRDBAmt FROM RaiseCreditDebit GROUP BY CrDr,Salid,Rtrid,MaxPerc

		OPEN cur_CreditDebtitGen
		FETCH next FROM cur_CreditDebtitGen INTO @CRDBName,@CRDBSalid,@DBCRRtrID,@MaxCRDVBPerc,@DBCRCollectionAmt
		WHILE @@Fetch_status=0
		BEGIN 
			IF @CRDBName='Debit'
				BEGIN 
					SELECT @DebitCreditNo=dbo.Fn_GetPrimaryKeyString('DebitNoteRetailer','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
					SET @CrDbNoteDate=GETDATE()
					SELECT @AccCoaId=CoaId FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId=@DBCRRtrID)
					SELECT @FindReasoId= ReasonId FROM ReasonMaster WHERE ReasonCode='R022'
					SELECT @DBCDRtrCode=RtrCode FROM Retailer WHERE RtrId=@DBCRRtrID
					SELECT @DBCDRtrName=RtrName FROM Retailer WHERE RtrId=@DBCRRtrID
					SELECT @DBCDSalInvNo=SalInvNo FROM SalesInvoice WHERE SalId=@CRDBSalid
					SELECT @DBCDSalInvDate=SalInvDate FROM SalesInvoice WHERE SalId=@CRDBSalid
									
					INSERT INTO DebitNoteRetailer(DbNoteNumber,DbNoteDate,RtrId,CoaId,ReasonId,Amount,DbAdjAmount,
						Status,PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
					VALUES(@DebitCreditNo,CONVERT(DATETIME,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),121),@DBCRRtrID,@AccCoaId,@FindReasoId,@DBCRCollectionAmt,0,
						1,'Auto Debit Note',19,'AUTO DB/CD',1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'From Auto Debit Note ' + @Pi_RefNo + '  ' + @DBCDSalInvNo)
					
					IF @FStatus=1
						BEGIN 
							INSERT INTO CrDbNoteTaxBreakUp
							SELECT @DebitCreditNo AS Debitno,19 AS Transid,TaxID,TaxPerc,sum(TaxableAmount) TaxableAmount,sum(TaxAmount) TaxAmount,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)  FROM AutoDBCDProductTax WHERE SalId=@CRDBSalid AND MaxTaxPerc=@MaxCRDVBPerc
								GROUP BY TaxId,Taxperc
								ORDER BY TaxId
						END 
					UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteRetailer' AND Fldname = 'DbNoteNumber'

					EXEC Proc_VoucherPosting 19,1,@DebitCreditNo,3,6,1,@Pi_TransDate,@Po_ErrNo= @ErrStatus OUTPUT
					
														
					INSERT INTO AutoRaisedCreditDebit(RtrId,RtrCode,RtrName,Salid,SalInvNo,SalInvDate,DBCRNoteNo,DBCRNoteAmt)
						VALUES (@DBCRRtrID,@DBCDRtrCode,@DBCDRtrName,@CRDBSalid,@DBCDSalInvNo,@DBCDSalInvDate,@DebitCreditNo,@DBCRCollectionAmt)			

				END 
			ELSE
				IF @CRDBName='Credit'
					BEGIN 
						SELECT @DebitCreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
										
						SET @CrDbNoteDate=GETDATE()
						SELECT @AccCoaId=CoaId FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrID=@DBCRRtrID)
						SELECT @FindReasoId= ReasonId FROM ReasonMaster WHERE ReasonCode='R022'
						SELECT @DBCDRtrCode=RtrCode FROM Retailer WHERE RtrId=@DBCRRtrID
						SELECT @DBCDRtrName=RtrName FROM Retailer WHERE RtrId=@DBCRRtrID
						SELECT @DBCDSalInvNo=SalInvNo FROM SalesInvoice WHERE SalId=@CRDBSalid
						SELECT @DBCDSalInvDate=SalInvDate FROM SalesInvoice WHERE SalId=@CRDBSalid

							INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,
							Status,PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
							VALUES(@DebitCreditNo,CONVERT(DATETIME,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),121),@DBCRRtrID,@AccCoaId,@FindReasoId,@DBCRCollectionAmt,0,
							1,'Auto Credit Note',18,'AUTO DB/CD',1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'From Auto Credit Note ' + @Pi_RefNo+ ' ' + @DBCDSalInvNo)
						
						IF @FStatus=1
							BEGIN 
								INSERT INTO CrDbNoteTaxBreakUp
								SELECT @DebitCreditNo AS Debitno,18 AS Transid,TaxID,TaxPerc,sum(TaxableAmount) TaxableAmount,sum(TaxAmount) TaxAmount,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)  FROM AutoDBCDProductTax WHERE SalId=@CRDBSalid AND MaxTaxPerc=@MaxCRDVBPerc
								GROUP BY TaxId,Taxperc
								ORDER BY TaxId				
							END 
						UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteRetailer' AND Fldname = 'CrNoteNumber'
						
						EXEC Proc_VoucherPosting 18,1,@DebitCreditNo,3,6,1,@Pi_TransDate,@Po_ErrNo= @ErrStatus OUTPUT

						
										
						INSERT INTO AutoRaisedCreditDebit(RtrId,RtrCode,RtrName,Salid,SalInvNo,SalInvDate,DBCRNoteNo,DBCRNoteAmt)
							VALUES (@DBCRRtrID,@DBCDRtrCode,@DBCDRtrName,@CRDBSalid,@DBCDSalInvNo,@DBCDSalInvDate,@DebitCreditNo,@DBCRCollectionAmt)		

					END 
			FETCH next FROM cur_CreditDebtitGen INTO @CRDBName,@CRDBSalid,@DBCRRtrID,@MaxCRDVBPerc,@DBCRCollectionAmt
		END 
	CLOSE cur_CreditDebtitGen
	DEALLOCATE cur_CreditDebtitGen
	
	UPDATE SalesInvoice SET AutoDBCD=1 WHERE SalId IN (SELECT SalId FROM AutoDBCDSlabAchieved)
END 
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AutoTAXDBCDCreation')
DROP PROCEDURE Proc_AutoTAXDBCDCreation
GO
/*
BEGIN TRANSACTION
exec Proc_AutoTAXDBCDCreation 6,45,1304,4,1
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_AutoTAXDBCDCreation
(
	@SalId int,
	@PrdId int,
	@PrdBaId int,
	@Row int,
	@TobeCalAmt numeric(28,6),
	@Slabid int
	
)
AS
SET NOCOUNT ON
BEGIN
		DECLARE @Pi_TransId AS int 
		DECLARE @Pi_UsrId  AS int
		SET @Pi_TransId=1
		SET @Pi_UsrId=1
		DELETE FROM BilledPrdHdForTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		DELETE FROM BilledPrdDtForTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId

		INSERT INTO BilledPrdHdForTax
		SELECT B.Slno,A.RtrId,B.PrdId,B.PrdBatId,B.BaseQty,A.BillSeqId,@Pi_UsrId,@Pi_TransId,B.PriceId
		FROM SalesInvoiceProduct B INNER JOIN SalesInvoice A ON A.SalId=B.SalId 
		WHERE A.SalId=@SalId AND B.PrdId=@PrdId AND B.PrdBatId=@PrdBaId 

		INSERT INTO BilledPrdDtForTax
		SELECT @Row,-2 AS ColId,@TobeCalAmt AS ColValue,@Pi_UsrId AS Usrid,@Pi_TransId AS TransId 

		DECLARE CalCulateTax CURSOR FOR
		SELECT Slno FROM SalesinvoiceProduct WHERE SalId=@SalId AND PrdId=@PrdId AND PrdBatId=@PrdBaId  ORDER BY Slno
		OPEN CalCulateTax
		FETCH next FROM CalCulateTax INTO @Row
		WHILE @@fetch_status= 0
		BEGIN
			DELETE FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
			EXEC Proc_ComputeTax @Row,@Pi_TransId,@Pi_UsrId
			IF EXISTS (SELECT * FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
			BEGIN
				DELETE FROM AutoDBCDProductTax WHERE SalId=@SalId AND PrdSlno=@Row AND SlabId=@Slabid
				INSERT INTO AutoDBCDProductTax(SalId,PrdSlNo,TaxId,TaxPerc,TaxableAmount,TaxAmount,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxTaxPerc,SlabId)
				SELECT DISTINCT @SalId,RowId,TaxId,TaxPercentage,TaxableAmount,TaxAmount,1,1,GETDATE(),1,GETDATE(),0,@Slabid
				FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND RowId=@Row
				UPDATE AutoDBCDProductTax SET MaxTaxPerc=(SELECT max(TaxPercentage) FROM BilledPrdDtCalculatedTax WHERE  TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND RowId=@Row)  WHERE  SalId=@SalId AND PrdSlno=@Row AND SlabId=@Slabid
			END
			FETCH next FROM CalCulateTax INTO @Row
		END
		CLOSE CalCulateTax
		DEALLOCATE CalCulateTax
END 
GO 

DELETE FROM Configuration WHERE ModuleId='RET37' AND ModuleName='Retailer'
INSERT INTO Configuration
SELECT 'RET37','Retailer','Enable Selection of Discount % in retailer master',1,0,0.00,37
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='RetailerDiscountConfig' AND xtype='U')
DROP TABLE RetailerDiscountConfig
GO
CREATE TABLE RetailerDiscountConfig
(
	[ModuleId] [nvarchar](50) NOT NULL,
	[Discount] numeric(18,6) NOT NULL,
	[AuthDate] [datetime] NOT NULL
)
GO
DELETE FROM CustomCaptions WHERE TransId=79 AND CtrlId=2000 AND SubCtrlId=23
INSERT INTO CustomCaptions 
SELECT 79,2000,23,'HotSch-79-2000-23','Discount','','',1,1,1,getdate(),1,getdate(),'Discount','','',1,1
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10047
INSERT INTO HotSearchEditorHd
SELECT 10047,'Retailer','Retailer CashDis','select','SELECT DISTINCT Discount FROM RetailerDiscountConfig'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10047
INSERT INTO HotSearchEditorDt
SELECT 1,10047,'Retailer CashDis','Discount','Discount',3000,0,'HotSch-79-2000-23',79
GO
UPDATE FieldLevelAccessDt SET AccessSts=0 WHERE TransId=2 AND CtrlId IN (100015,100016)
GO
DELETE FROM HotsearchEditorHd WHERE FormId=10045
INSERT INTO HotsearchEditorHd
SELECT 10045,'Spl Price','Product','SELECT',
'SELECT PrdId,PrdDcode,PrdCcode,PrdName,PrdShrtName,PrdbatId,PrdbatCode,Mrp,LSP FROM (
SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,
B.PrdbatId,B.PrdbatCode,B1.PrdBatDetailValue AS Mrp,B2.PrdBatDetailValue AS LSP  
FROM Product A WITH (NOLOCK) INNER JOIN ProductBatch B WITH (NOLOCK) ON A.PrdId=B.PrdId
INNER JOIN ProductBatchDetails B1 (NOLOCK)
			ON B.PrdBatId = B1.PrdBatID AND B1.DefaultPrice=1
			INNER JOIN BatchCreation C1 (NOLOCK)
			ON C1.BatchSeqId = B.BatchSeqId AND B1.SlNo = C1.SlNo
			AND C1.MRP = 1
INNER JOIN ProductBatchDetails B2 (NOLOCK)
			ON B.PrdBatId = B2.PrdBatID AND B2.DefaultPrice=1
			INNER JOIN BatchCreation C2 (NOLOCK)
			ON C2.BatchSeqId = B.BatchSeqId AND B2.SlNo = C2.SlNo
			AND C2.ListPrice = 1
WHERE A.PrdStatus=1 AND A.PrdType IN (1,2,5,6)      
)A WHERE PrdCcode LIKE ''IN70%'' Order By PrdId'

DELETE FROM HotsearchEditorDt WHERE FormId=10045
INSERT INTO HotsearchEditorDt
SELECT 1,10045,'Product','Dist Code','PrdDCode',1000,0,'',1000
UNION
SELECT 2,10045,'Product','Comp Code','PrdCcode',1000,0,'',1000
UNION
SELECT 3,10045,'Product','Name','PrdName',1000,0,'',1500
UNION
SELECT 4,10045,'Product','Short Name','PrdShrtName',1000,0,'',1000
UNION
SELECT 5,10045,'Product','Batch Code','PrdbatCode',1000,0,'',1000
UNION
SELECT 6,10045,'Product','MRP','MRP',1000,0,'',1500
UNION
SELECT 7,10045,'Product','LSP','LSP',1000,0,'',1000
DELETE FROM HotsearchEditorHd WHERE FormId=10046
INSERT INTO HotsearchEditorHd
SELECT 10046,'Spl Price','Reference No','SELECT',
'SELECT DISTINCT RefId,RefNo,RefDate FROM ManualSplPricingMaster'
DELETE FROM HotsearchEditorDt WHERE FormId=10046
INSERT INTO HotsearchEditorDt
SELECT 1,10046,'Reference No','Reference No','RefNo',4500,0,'',1000
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='ManualSplPricingMaster')
BEGIN
	CREATE TABLE ManualSplPricingMaster
	(
		RefId			BIGINT,
		RefNo			VARCHAR(50),
		RefDate			DATETIME,
		PrdId			BIGINT,
		PrdbatId		BIGINT,
		Mrp				NUMERIC(38,6),
		Lsp				NUMERIC(38,6),
		SelRate			NUMERIC(38,6),
		PriceCode		VARCHAR(200),
		IsSelect		TINYINT,
		Availability	TINYINT,
		LastModBy		TINYINT,
		LastModDate		DATETIME,
		AuthId			TINYINT,
		AuthDate		DATETIME
	) ON [PRIMARY]
END
GO
DELETE FROM COUNTERS WHERE TabName='ManualSplPricingMaster' AND CurrValue=0
IF NOT EXISTS (SELECT * FROM COUNTERS WHERE TabName='ManualSplPricingMaster')
BEGIN
	INSERT INTO COUNTERS (TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,
							CurYear,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT 'ManualSplPricingMaster','RefId','',0,1,0,'Spl Pricing',0,YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE()
	UNION
	SELECT 'ManualSplPricingMaster','RefNo','SPL',5,1,0,'Spl Pricing',1,YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE()
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CreateBatchCloning')
DROP PROCEDURE Proc_CreateBatchCloning
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApplySchemeInBill 115,12,0,2,2
SELECT * FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme(NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE Procedure [dbo].Proc_CreateBatchCloning
(
	@Pi_RefId		INT	
)
AS
/*********************************
* PROCEDURE		: Proc_CreateBatchCloning
* PURPOSE		: To Create the Batch cloning for Akzo Nobal
* CREATED		: Boopathy
* CREATED DATE	: 20-08-2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}       {developer}  {brief modification description}
* 
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @SR					AS  NUMERIC(38,6)
	DECLARE @PriceCode			AS	VARCHAR(200)
	DECLARE @BatchSeqId			AS  INT

	IF EXISTS (SELECT * FROM ManualSplPricingMaster (NOLOCK) WHERE RefId=@Pi_RefId)
	BEGIN
		SELECT @BatchSeqId=BatchSeqId FROM BatchCreationMaster WHERE BatchSeqId IN
		(SELECT MAX(BatchSeqId) FROM BatchCreationMaster)

		DECLARE Cur_ProductBatch CURSOR
		FOR SELECT PrdId,PrdBatId,SelRate,PriceCode 
			FROM ManualSplPricingMaster (NOLOCK) WHERE RefId=@Pi_RefId AND IsSelect=1
		OPEN Cur_ProductBatch
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@SR,@PriceCode
		WHILE @@FETCH_STATUS=0
		BEGIN
			SELECT @PriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))

			INSERT INTO ProductbatchDetails
			SELECT @PriceId,@PrdBatId,@PriceCode,@BatchSeqId,Slno,PrdBatDetailValue,1,1,1,1,GETDATE(),1,GETDATE(),0
			FROM ProductbatchDetails  (NOLOCK) WHERE DefaultPrice=1 AND PrdbatId=@PrdBatId AND BatchSeqId=@BatchSeqId 

			UPDATE ProductbatchDetails SET DefaultPrice=0
			WHERE DefaultPrice=1 AND PrdbatId=@PrdBatId AND PriceCode<>@PriceCode

			UPDATE ProductBatch SET DefaultPriceId=@PriceId,EnableCloning=1 WHERE PrdId=@PrdId AND PrdbatId=@PrdBatId
			
			UPDATE A SET PrdBatDetailValue=@SR FROM ProductbatchDetails A INNER JOIN
			(SELECT SlNo FROM BatchCreation  (NOLOCK) WHERE SelRte=1 AND BatchSeqId=@BatchSeqId) B
			ON A.Slno=B.Slno WHERE A.DefaultPrice=1 AND A.PrdbatId=@PrdBatId AND A.BatchSeqId=@BatchSeqId 
			AND A.PriceCode=@PriceCode

			UPDATE COUNTERS SET CurrValue=@PriceId WHERE TabName='ProductBatchDetails' AND FldName='PriceId'

			FETCH NEXT FROM Cur_ProductBatch INTO  @PrdId,@PrdBatId,@SR,@PriceCode

		END
		CLOSE Cur_ProductBatch
		DEALLOCATE Cur_ProductBatch

	END
END
GO
if not exists (select * from hotfixlog where fixid = 387)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(387,'D','2011-09-07',getdate(),1,'Core Stocky Service Pack 387')
GO  
