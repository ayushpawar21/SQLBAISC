--[Stocky HotFix Version]=431
DELETE FROM Versioncontrol WHERE Hotfixid='431'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('431','3.1.0.8','D','2017-04-07','2017-04-07','2017-04-07',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
DELETE FROM CustomUpDownload WHERE SlNo = 251
INSERT INTO CustomUpDownload(SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
SELECT 251,1,'SFAProductAlliasName','SFAProductAlliasName','','Proc_Import_SFAproductAlliasName','Cn2cs_Prk_ProductAlliasName','Proc_Cn2cs_ProductAlliasName','Master','Download',0
GO
DELETE FROM Tbl_DownloadIntegration where SequenceNo = 59
INSERT INTO Tbl_DownloadIntegration(SEquenceno,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
SELECT 59,'SFAProductAlliasName','Cn2cs_Prk_ProductAlliasName','Proc_Import_SFAproductAlliasName',0,500,GETDATE()
GO
IF NOT EXISTS(SELECT A.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.ID
WHERE A.NAME='OrderBookingProducts' AND B.NAME='SlNo' AND A.xtype='U')
BEGIN
	ALTER TABLE OrderBookingProducts ADD SlNo INT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='ProductSFAAlliasName' AND xtype='U')
CREATE TABLE ProductSFAAlliasName
(
	Prdid			INT,
	PrdCCode		VARCHAR(100),
	PrdAlliasName	VARCHAR(200),
	CreatedDate		DATETIME
)
GO
IF NOT EXISTS(SELECT * FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID(N'dbo.ProductSFAAlliasName'))
BEGIN
	ALTER TABLE ProductSFAAlliasName
	ADD CONSTRAINT FK_Prdid_ProductSFAAlliasName FOREIGN KEY (Prdid) REFERENCES Product(Prdid)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE name ='Cn2cs_Prk_ProductAlliasName' AND xtype='U')
CREATE TABLE Cn2cs_Prk_ProductAlliasName
(
	DistCode			VARCHAR(50),
	PrdCCode			VARCHAR(100),
	PrdAlliasName		VARCHAR(200),
	DownloadFlag		VARCHAR(20),
	Createddate			DATETIME
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name ='Proc_Cn2cs_ProductAlliasName' AND xtype='P')
DROP PROCEDURE Proc_Cn2cs_ProductAlliasName
GO
/*
BEGIN TRAN
SELECT * FROM Cn2cs_Prk_ProductAlliasName
EXEC Proc_Cn2cs_ProductAlliasName 0
SELECT * FROM ProductSFAAlliasName
SELECT * FROM ERRORLOG
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Cn2cs_ProductAlliasName
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2cs_ProductAlliasName
* PURPOSE		: To validate the downloaded Product AlliasName details from Console
* CREATED		: Mahesh Babu D
* CREATED DATE	: 20/02/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)

	SET @TabName = 'Cn2cs_Prk_ProductAlliasName'
	SET @Po_ErrNo=0
	
	DELETE FROM Cn2cs_Prk_ProductAlliasName WHERE DistCode <>(SELECT Distributorcode from Distributor)


	SELECT PrdCCode,Max(CreatedDate)CreatedDate INTO #Cn2cs_Prk_ProductAlliasName 
	FROM Cn2cs_Prk_ProductAlliasName
	GROUP BY PrdCCode
	
	

	
	SELECT B.* INTO #Cn2cs_Prk_ProductAlliasNameMaxDate FROM #Cn2cs_Prk_ProductAlliasName A INNER JOIN Cn2cs_Prk_ProductAlliasName B
	ON A.PrdCCode = B.PrdCCode AND A.CreatedDate = B.Createddate

	DELETE FROM Cn2cs_Prk_ProductAlliasName

	INSERT INTO Cn2cs_Prk_ProductAlliasName
	SELECT * FROM #Cn2cs_Prk_ProductAlliasNameMaxDate

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PrdAlliasToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE PrdAlliasToAvoid	
	END


	CREATE TABLE PrdAlliasToAvoid
	(
		PrdCCode NVARCHAR(50)
	)	

	IF EXISTS(SELECT '*' FROM Cn2cs_Prk_ProductAlliasName WHERE LTRIM(RTRIM(ISNULL(PrdCCode,'')))='')
	BEGIN
		INSERT INTO PrdAlliasToAvoid(PrdCCode)
		SELECT DISTINCT PrdCCode FROM Cn2cs_Prk_ProductAlliasName WHERE LTRIM(RTRIM(ISNULL(PrdCCode,'')))=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Code','PrdCCode','Product Code Should not be empty' FROM Cn2cs_Prk_ProductAlliasName WHERE LTRIM(RTRIM(ISNULL(PrdCCode,'')))=''
	END

	IF EXISTS(SELECT '*' FROM Cn2cs_Prk_ProductAlliasName A WHERE NOT EXISTS(SELECT * FROM Product B WHERE A.PrdCCode = B.PrdCCode))
	BEGIN
		INSERT INTO PrdAlliasToAvoid(PrdCCode)
		SELECT DISTINCT A.PrdCCode FROM Cn2cs_Prk_ProductAlliasName A WHERE NOT EXISTS(SELECT * FROM Product B WHERE A.PrdCCode = B.PrdCCode)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'Product Code','PrdCCode','Product Code Not Available in Master' FROM Cn2cs_Prk_ProductAlliasName A WHERE NOT EXISTS(SELECT * FROM Product B WHERE A.PrdCCode = B.PrdCCode)

	END

	IF EXISTS(SELECT '*' FROM Cn2cs_Prk_ProductAlliasName A WHERE LTRIM(RTRIM(ISNULL(PrdAlliasName,'')))='')
	BEGIN
		INSERT INTO PrdAlliasToAvoid(PrdCCode)
		SELECT DISTINCT A.PrdCCode FROM Cn2cs_Prk_ProductAlliasName A WHERE LTRIM(RTRIM(ISNULL(PrdAlliasName,'')))=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 3,'Product Code','PrdCCode','Product AlliasName Should not be Blank' FROM Cn2cs_Prk_ProductAlliasName A WHERE LTRIM(RTRIM(ISNULL(PrdAlliasName,'')))=''

	END

	SELECT A.* INTO #AlliasAvailable FROM Cn2cs_Prk_ProductAlliasName A(NOLOCK) 
	WHERE EXISTS(SELECT * FROM ProductSFAAlliasName B(NOLOCK) WHERE A.PrdCCode = B.PrdCCode)
	
	IF EXISTS(SELECT * FROM #AlliasAvailable)
	BEGIN
		
		UPDATE A SET A.PrdAlliasName = B.PrdAlliasName 
		FROM ProductSFAAlliasName  A INNER JOIN #AlliasAvailable B
		ON A.PrdCCode = B.PrdCCode
		
	END
	
	INSERT INTO ProductSFAAlliasName(Prdid,PrdCCode,PrdAlliasName,CreatedDate)
	SELECT DISTINCT A.prdid,A.PrdCCode,B.PrdAlliasName,GETDATE() AS CreatedDate 
	FROM Product A(NOLOCK) INNER JOIN Cn2cs_Prk_ProductAlliasName B(NOLOCK) ON A.PrdCCode = B.PrdCCode
	AND NOT EXISTS(SELECT * FROM PrdAlliasToAvoid C WHERE A.PrdCCode = C.PrdCCode AND B.PrdCCode = C.prdCCode)
	AND NOT EXISTS(SELECT * FROM #AlliasAvailable D WHERE A.PrdCCode = D.PrdCCode and B.PrdCCode = D.prdCCode)


	UPDATE A SET DownloadFlag='Y' FROM Cn2cs_Prk_ProductAlliasName A(NOLOCK) WHERE EXISTS(SELECT * FROM ProductSFAAlliasName B WHERE A.PrdCCode = B.PrdCCode)

END
GO
IF NOT EXISTS(SELECT B.* FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id = B.id and A.Name ='ImportProductPDA_SalesReturn' WHERE B.NAME='SrNo' AND B.Length='100')
BEGIN
	ALTER TABLE ImportProductPDA_SalesReturn
	ALTER COLUMN SrNo VARCHAR(100)
END
GO
IF NOT EXISTS(SELECT B.* FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id = B.id and A.Name ='PDA_SalesReturn' WHERE B.NAME='SrNo' AND B.Length='100')
BEGIN
	ALTER TABLE PDA_SalesReturn
	ALTER COLUMN SrNo VARCHAR(100)
END
GO
IF NOT EXISTS(SELECT B.* FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id = B.id and A.Name ='PDA_SalesReturnProduct' WHERE B.NAME='SrNo' AND B.Length='100')
BEGIN
	ALTER TABLE PDA_SalesReturnProduct
	ALTER COLUMN SrNo VARCHAR(100)
END
GO
IF NOT EXISTS(SELECT B.* FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id = B.id WHERE B.NAME='ReasonId' and A.Name ='PDA_SalesReturnProduct')
BEGIN
	ALTER TABLE PDA_SalesReturnProduct ADD ReasonId INT DEFAULT 0 WITH VALUES
END
GO
IF EXISTS(SELECT B.* FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id = B.id and A.Name ='ImportProductPDA_SalesReturnProduct' WHERE B.NAME='SrNo' AND B.Length='100')
BEGIN
	ALTER TABLE ImportProductPDA_SalesReturnProduct
	ALTER COLUMN SrNo VARCHAR(100)
END
GO
IF NOT EXISTS(SELECT B.* FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id = B.id and 
A.Name ='ImportProductPDA_SalesReturnProduct' WHERE B.NAME='MRP' AND A.XTYPE='U')
BEGIN
	ALTER TABLE ImportProductPDA_SalesReturnProduct	ADD MRP NUMERIC(18,3) DEFAULT 0 WITH VALUES
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE Name ='Mob2Cos_SalesReturnProduct' AND type in (N'U'))
DROP TABLE Mob2Cos_SalesReturnProduct
GO
CREATE TABLE Mob2Cos_SalesReturnProduct
(
	[DistCode] [nvarchar](20) NULL,
	[SrpCde] [varchar](100) NULL,
	[SrNo] [nvarchar](100) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PriceId] [int] NULL,
	[SrQty] [int] NULL,
	[UsrStkTyp] [int] NULL,
	[salinvno] [varchar](25) NULL,
	[SlNo] [int] NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] [varchar](1) NULL,
	[MRP] [numeric](18, 3) NULL
)
ALTER TABLE Mob2Cos_SalesReturnProduct ADD  DEFAULT ((0)) FOR [MRP]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE Name = 'Mob2Cos_OrderBookingProduct' AND type in (N'U'))
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
	[Uomid] [int] NULL,
	[LineId] [int] NULL
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_IMPORT_ProductPDA_SALESRETURN' AND XTYPE='P')
DROP PROCEDURE PROC_IMPORT_ProductPDA_SALESRETURN
GO
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
DECLARE @SrNo AS VARCHAR(50)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT    
DECLARE @SalInvNo AS nVarchar(50)
DECLARE @Salid AS INT  
DECLARE @Reasonid AS int  
DECLARE @MRP AS NUMERIC(18,3)   
DECLARE @MRPBatId  AS INT
DECLARE @MRPPriceId  AS INT
BEGIN
 BEGIN TRANSACTION T1
		DELETE FROM ImportProductPDA_SalesReturn WHERE uploadflag='Y'
		DELETE FROM ImportProductPDA_SalesReturnProduct WHERE uploadflag='Y'
		DELETE FROM PDALog where DataPoint='SALESRETURN'
		
		SELECT * INTO #ImportProductPDA_SalesReturnProduct FROM ImportProductPDA_SalesReturnProduct (NOLOCK)
		
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
				
				IF NOT EXISTS(SELECT SrNo FROM ImportProductPDA_SalesReturnProduct WHERE SrNo=@SrNo)
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
				SELECT PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,SlNo,Reasonid,MRP From ImportProductPDA_SalesReturnProduct WHERE SrNo=@SrNo  ORDER BY SlNo 
				OPEN CUR_ImportReturnProduct
				FETCH NEXT FROM CUR_ImportReturnProduct INTO @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno,@Reasonid,@MRP
				WHILE @@FETCH_STATUS = 0
				BEGIN
						SET @MRPBatId=0
						SET @MRPPriceId=0
						IF NOT EXISTS(SELECT PrdId From Product (NOLOCK) WHERE Prdid=@Prdid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdid,' Product Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						
						IF ISNULL(@PriceId,0)<>0 
						BEGIN
							IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid )
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
						END
						
						IF @RtnQty<=0
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Return Qty Should be Greater than Zero for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						
						IF ISNULL(@PriceId,0)=0 
						BEGIN
							SELECT @MRPBatId=MIN(A.PrdBatId) FROM ProductBatch A (NOLOCK)
							INNER JOIN ProductBatchDetails B(NOLOCK) ON A.PrdBatId=B.PrdBatId 
							INNER JOIN BatchCreation BC(NOLOCK) ON BC.SLNO=B.SLNO
							WHERE MRP=1 and A.PrdId=@Prdid AND B.PrdBatDetailValue=@MRP
							
							SELECT @MRPPriceId=B.PriceId FROM  ProductBatch A (NOLOCK)
							INNER JOIN ProductBatchDetails B(NOLOCK) ON A.PrdBatId=B.PrdBatId 
							WHERE B.PrdBatId=@MRPBatId AND A.PrdId=@Prdid  and DefaultPrice=1
							
							UPDATE #ImportProductPDA_SalesReturnProduct SET PrdBatId=ISNULL(@MRPBatId,0),PriceId=ISNULL(@MRPPriceId,0) 
							WHERE PriceId=0 and SrNo=@SrNo and PrdId=@Prdid and @MRP=@MRP AND SrpCde = @SalRpCode							
					
							------IF ISNULL(@MRPBatId,0)<>0 and ISNULL(@MRPPriceId,0)<>0
							------BEGIN
							------	UPDATE #ImportProductPDA_SalesReturnProduct SET PrdBatId=@MRPBatId,PriceId=@MRPPriceId WHERE PriceId=0 and SrNo=@SrNo 
							------	and PrdId=@Prdid and @MRP=@MRP AND SrpCde = @SalRpCode
							------END
							------ELSE
							------BEGIN
							------	SET @lError = 1
							------	INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							------	SELECT '' + @SalRpCode + '','SALESRETURN',@PriceId,' Product Batch Price Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
							------END
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
				
				FETCH NEXT FROM CUR_ImportReturnProduct INTO  @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno,@Reasonid,@MRP
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
						INSERT INTO PDA_SalesReturnProduct(SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo,ReasonId)
						SELECT @SrNo,PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,ISNULL(SlNo,0),ReasonId From #ImportProductPDA_SalesReturnProduct 
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
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' and NAME= 'Proc_Import_PDA_NewRetailerOrderBooking')
DROP PROCEDURE Proc_Import_PDA_NewRetailerOrderBooking
GO
CREATE PROCEDURE Proc_Import_PDA_NewRetailerOrderBooking
AS      
/*********************************/      
DECLARE @OrdKeyNo AS VARCHAR(75)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
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
DECLARE @SalRpCode AS NVARCHAR(25)
DECLARE @RtrCode  AS NVARCHAR(50)
BEGIN
	BEGIN TRANSACTION T1
	DELETE FROM ImportPDA_NewRetailerOrderBooking WHERE UploadFlag='Y'
	DELETE FROM ImportPDA_NewRetailerOrderProduct WHERE UploadFlag='Y'
	
	DECLARE CUR_Import CURSOR FOR
	SELECT DISTINCT OrdKeyNo,SrpCde,RtrCde From ImportPDA_NewRetailerOrderBooking  
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalRpCode,@RtrCode 
	While @@Fetch_Status = 0
	BEGIN
		SET @OrdPrdCnt=0
		SET @PdaOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0
		
		SET @SrpId = (SELECT SMId FROM SalesMan WHERE SMCode = @SalRpCode)
		
		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking WHERE DocRefNo = @OrdKeyNo)
		BEGIN
			SET @RtrId = (SELECT RtrId FROM Retailer WHERE Rtrcode = @RtrCode)
			
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
			END
			
			SELECT @RtrShipId=RS.RtrShipId FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid 
			WHERE RtrShipDefaultAdd=1  AND R.RtrId=@RtrId  
			
			SET @MktId = (SELECT RM.RMId FROM Retailer R INNER JOIN RetailerMarket RM ON R.RtrId=RM.RtrId	WHERE RtrCode=@RtrCode)
			
			IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)
			BEGIN
				SET @lError = 1 
			END
			
			IF NOT EXISTS (SELECT * FROM SalesManMarket WHERE RMID = @MktId AND SMID = @SrpId)
			BEGIN
				SET @lError = 1
			END
			
			IF NOT EXISTS(SELECT OrdKeyNo FROM  ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
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
				SELECT DISTINCT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  From ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo GROUP BY PrdId,PrdBatId,PriceId
				OPEN CUR_ImportOrderProduct
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
						SET @PError = 0
						IF NOT EXISTS(SELECT PrdId From Product WHERE Prdid=@Prdid)
						BEGIN
							SET @PError = 1
						END
						
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @PError = 1
						END
						
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @PError = 1  
						END
						
						IF @OrdQty<=0
						BEGIN
							SET @PError = 1
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
					BREAK  
				END
				
			IF @lError = 0 AND @CNT>0
			BEGIN
				--HEDER 
					SELECT  @OrderDate= OrdDt FROM ImportPDA_NewRetailerOrderBooking WHERE  OrdKeyNo=@OrdKeyNo
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
					
					SELECT @Longitude=ISNULL(Longitude,0),@Latitude =ISNULL(Latitude,0) FROM ImportPDA_NewRetailerOrderBooking WHERE  OrdKeyNo=@OrdKeyNo 
					SELECT @LAUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Latitude'
                    SELECT @LOUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Longitude'
					UPDATE UdcDetails SET ColumnValue=@Latitude WHERE UdcMasterId=@LAUdcMasterId AND MasterRecordId=@RtrId
					UPDATE UdcDetails SET ColumnValue=@Longitude WHERE UdcMasterId=@LOUdcMasterId AND MasterRecordId=@RtrId
					
				 --DETAILS 
		    INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,ConvFact2,TotalQty,BilledQty,Rate,
					                          MRP,GrossAmount,PriceId,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
			SELECT @GetKeyStr ,Prdid,Prdbatid,UomID,OrdQty,ConversionFactor,0,0,0,(OrdQty*ConversionFactor),0,
			SUM(Rate)Rate ,SUM(MRP)MRP,sum(GrossAmount)GrossAmount,sum(PriceId)PriceId,
			1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
			1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121) 
			FROM ( 
			SELECT P.Prdid,PB.Prdbatid,U.UomID,OrdQty,u.ConversionFactor,  
			PBD.PrdBatDetailValue Rate,0 as Mrp,(PBD.PrdBatDetailValue*OrdQty) as GrossAmount,PBD.PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN ImportPDA_NewRetailerOrderProduct I ON I.PRDID=P.PRDID AND I.PRDID=PB.PRDID AND I.PRDBATID=PB.PRDBATID
			INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId 
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId AND PBD.prdbatid=i.PrdBatId
					   AND BC.slno=PBD.SLNo AND BC.SelRte=1  and PBD.PriceId=I.PriceId 
			WHERE OrdKeyNo=  @OrdKeyNo  		   
		UNION ALL
			SELECT P.Prdid,PB.Prdbatid,U.UomID,OrdQty,ConversionFactor,  
			0 Rate,PBD.PrdBatDetailValue as Mrp,0 as GrossAmount,0 as PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN ImportPDA_NewRetailerOrderProduct I ON I.PRDID=P.PRDID AND I.PRDID=PB.PRDID AND I.PRDBATID=PB.PRDBATID
			INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId 
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId AND PBD.prdbatid=i.PrdBatId
					   AND BC.slno=PBD.SLNo AND BC.MRP=1  and PBD.PriceId=I.PriceId
			WHERE OrdKeyNo=  @OrdKeyNo  )A
					GROUP BY Prdid,Prdbatid,UomID,OrdQty,ConversionFactor
			 
		  UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  
		  FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X  ON X.OrderNo=OB.OrderNo   
			  
		  SELECT DISTINCT SrpCde,OrdKeyNo,PrdId,PrdBatId  INTO #TEMPCHECK   
				FROM ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo
					
		SELECT @OrdPrdCnt=ISNULL(Count(PRDID),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
		SELECT @PdaOrdPrdCnt=ISNULL(Count(PRDID),0) FROM #TEMPCHECK (NOLOCK) WHERE OrdKeyNo=@OrdKeyNo
		
		IF @OrdPrdCnt=@PdaOrdPrdCnt  
		BEGIN 
			UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
			UPDATE ImportPDA_NewRetailerOrderBooking SET UploadFlag = 'Y' WHERE SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo = @OrdKeyNo
			UPDATE ImportPDA_NewRetailerOrderProduct SET UploadFlag = 'Y' WHERE SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo =@OrdKeyNo 
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
			Delete From PDALog WHERE SrpCde = @SalRpCode And DataPoint = 'ORDERBOOKING'
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,'Order Already exists'
		END
		
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalRpCode,@RtrCode 
	END
	CLOSE CUR_Import
	DEALLOCATE CUR_Import
	
	  --EXEC PROC_PDASALESMANDETAILS @SalRpCode
 	
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
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Import_PDA_NonProductiveRetailers' AND XTYPE='P')
DROP PROCEDURE Proc_Import_PDA_NonProductiveRetailers
GO
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
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Import_PDA_NewRetailer' AND XTYPE='P')
DROP PROCEDURE Proc_Import_PDA_NewRetailer
GO
CREATE PROCEDURE Proc_Import_PDA_NewRetailer
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
	[Category Code] nvarchar(20) ,
	[Category Name] nvarchar(50) ,
	[Channel Code] nvarchar(20) ,
	[Channel Name] nvarchar(50) ,
	[CtgMainId] int ,
	[ChannelId] int 
)
	INSERT INTO @TmpRetailerCategory (RtrClassId,ValueClassCode,[Category Code],[Category Name],[Channel Code],
	[Channel Name],CtgMainId,ChannelId)
	SELECT V.RtrClassId,V.ValueClassCode,
	C1.CtgCode [Category Code],C1.CtgName [Category Name]
	,C2.CtgCode [Channel Code],C2.CtgName [Channel Name],
	C1.CtgMainId GroupId,C2.CtgMainId ChannelId		
	FROM RetailerValueClass V (NOLOCK) 
	INNER JOIN (Select B.CtgLinkId,B.CtgMainId,B.CtgCode,B.CtgName from RetailerCategoryLevel A (NOLOCK) INNER JOIN RetailerCategory B (NOLOCK) ON A.CtgLevelId=B.CtgLevelId Where A.CtgLevelId=2) C1
	ON C1.CtgMainId=V.CtgMainId
	INNER JOIN (Select B.CtgLinkId,B.CtgMainId,B.CtgCode,B.CtgName from RetailerCategoryLevel A (NOLOCK) INNER JOIN RetailerCategory B (NOLOCK) ON A.CtgLevelId=B.CtgLevelId Where A.CtgLevelId=1) C2
	ON C1.CtgLinkId=C2.CtgMainId
--END HERE
 DECLARE CUR_ImportRetailer Cursor For      
 Select Distinct RtrCode,RetailerName,CtgMainID,RtrClassId 
		From ImportProductPDA_NewRetailer WHERE UploadFlag='N' 
		
 OPEN CUR_ImportRetailer      
 FETCH NEXT FROM CUR_ImportRetailer INTO  @CustomerCode,@CustomerName,@CtgMainID,@RtrClassId
 While @@Fetch_Status = 0      
 BEGIN      
  SET @lError = 0
		
  IF NOT EXISTS (SELECT RtrCode FROM Retailer WHERE RtrCode = @CustomerCode )      
   BEGIN
		SELECT @CtgMainID=CtgMainid FROM @TmpRetailerCategory WHERE RtrClassId=@RtrClassId   
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
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ReturnPDAProductDt' AND xtype in ('TF','FN'))
DROP FUNCTION Fn_ReturnPDAProductDt
GO
CREATE FUNCTION Fn_ReturnPDAProductDt(@SrNo as Varchar(50))
RETURNS @PDAProducts TABLE
	(
		PrdId		INT,
		PrdName		Varchar(150),
		PrdCCode	Varchar(50),
		PrdBatID	INT,
		BatchCode	Varchar(100),
		Qty			INT,
		MRP			NUMERIC(18,6),
		SellRate	NUMERIC(18,6),
		PriceId		INT,
		SplPriceId  INT,
		StockTypeId	INT,
		ReasonId int,
		Description varchar(150)
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnPDAProductDt
* PURPOSE: Returns the PDA Product details
* NOTES:
* CREATED: MURURGAN.R
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
INSERT INTO	@PDAProducts
Select DISTINCT F.PrdId,F.PrdName,F.PrdCCode,0,'' AS BatchCode, [SrQty],0 as 'MRP',0 as 'SellRate',0 as PriceId, 
0 as SplPriceId,UsrStkTyp,isnull(RM.reasonid,'')reasonid,isnull(RM.Description,'')Description
FROM PRODUCT F 
INNER JOIN PDA_SalesReturnProduct G (NOLOCK) ON G.[PrdId] = F.Prdid --AND A.DefaultPriceId=G.PriceId 
LEFT OUTER JOIN ReasonMaster RM ON RM.ReasonId=G.ReasonId
WHERE [Srno]=@SrNo AND G.PriceId=0 --AND NOT EXISTS(SELECT DISTINCT Srno,PRDID FROM PDA_SalesReturnProduct M WHERE M.[Srno]=@SrNo and F.PrdId=M.PrdId and M.PriceId=0)

INSERT INTO	@PDAProducts
Select DISTINCT F.PrdId,F.PrdName,F.PrdCCode,A.PrdBatID,CmpBatCode AS BatchCode, [SrQty],B.PrdBatDetailValue as 'MRP',D.PrdBatDetailValue as 'SellRate',A.DefaultPriceId as PriceId, 0 as SplPriceId,UsrStkTyp,isnull(RM.reasonid,'')reasonid,
isnull(Description,'')Description
FROM ProductBatch A (NOLOCK) 
INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND   C.MRP = 1 
INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID  AND D.DefaultPrice=1 
INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.SelRte = 1 
INNER JOIN PRODUCT F (NOLOCK) ON A.PrdId=F.PrdId 
INNER JOIN PDA_SalesReturnProduct G (NOLOCK) ON G.[PrdId] = F.Prdid And G.[PrdBatId] = A.Prdbatid --AND A.DefaultPriceId=G.PriceId 
LEFT OUTER JOIN ReasonMaster RM ON RM.ReasonId=G.ReasonId
WHERE [Srno]=@SrNo Order By F.PrdCCode
RETURN
END
GO
-- Starts Here 
--> EXPORT PROCESS STARTS HERE
--< Till HERE
DELETE FROM HotSearchEditorHd where FormId = 10052
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) VALUES 
(10052,'Collection Register','CollectionRefNo','Select','SELECT Distinct ReceiptNo,ReceiptDate FROM PDA_ReceiptInvoice')
GO
--From Script Updater
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_AutoBatchTransfer_Parle' AND XTYPE='P')
DROP PROCEDURE Proc_AutoBatchTransfer_Parle
GO
/*
BEGIN TRANSACTION
select *from stockledger a where prdid = 2058 and TransDate = (select MAX(TransDate) from StockLedger where PrdId = a.PrdId and PrdBatId = a.PrdBatId)
EXEC Proc_AutoBatchTransfer_Parle 0
select *from stockledger a where prdid = 2058 and TransDate = (select MAX(TransDate) from StockLedger where PrdId = a.PrdId and PrdBatId = a.PrdBatId)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_AutoBatchTransfer_Parle
(
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
	
	SET @Exist=0
	
	select PrdId,MAX(mnfdate)mnfdate into #MaxMnfdate from ProductBatch
	group by PrdId

	select B.PrdId,MAX(PrdBatId)PrdBatId INTO #MaxProductBatch from #MaxMnfdate A INNER JOIN ProductBatch B
	ON A.PrdId = B.PrdId AND A.mnfdate = B.MnfDate
	group by B.PrdId
	
	
	DECLARE Cur_ProductBatch CURSOR
	FOR 
	SELECT PrdId,MAX(PrdBatId) PrdBatId FROM #MaxProductBatch GROUP BY PrdId
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	WHILE @@FETCH_STATUS=0
	BEGIN
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
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	RETURN	
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SpecialRateAftDownLoad_Calc]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[SpecialRateAftDownLoad_Calc](
		[RtrCtgCode] [nvarchar](100) NULL,
		[RtrCtgValueCode] [nvarchar](100) NULL,
		[RtrCode] [nvarchar](100) NULL,
		[PrdCCode] [nvarchar](100) NULL,
		[PrdBatCCode] [nvarchar](100) NULL,
		[SplSelRate] [numeric](38, 6) NULL,
		[FromDate] [datetime] NULL,
		[CreatedDate] [datetime] NULL,
		[DownloadedDate] [datetime] NULL,
		[ContractPriceIds] [nvarchar](1000) NULL,
		[ConSplSelRate] [numeric](18, 6) NULL,
		[DiscountPerc] [numeric](18, 6) NULL,
		[SplrateId] [int] NULL,
		[ApplyOn] [tinyint] NULL,
		[TYPE] [int] NULL
	)
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name ='Proc_ValidateRetailerMaster' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateRetailerMaster
GO
/*
BEGIN TRANSACTION
Exec Proc_ValidateRetailerMaster 0
SELECT * FROM Retailer
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_ValidateRetailerMaster
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
----------------------------------------------------------------------------
* {Date}         {Developer}             {Brief modification description}
  2013/10/10   Sathishkumar Veeramani     Junk Characters Removed  
*****************************************************************************/ 
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
	FOR SELECT dbo.Fn_Removejunk(ISNULL([Retailer Code],'')),dbo.Fn_Removejunk(ISNULL([Retailer Name],'')),dbo.Fn_Removejunk(ISNULL([Address1],'')),
		dbo.Fn_Removejunk(ISNULL([Address2],'')),dbo.Fn_Removejunk(ISNULL([Address3],'')),
		ISNULL([Pin Code],'0'),ISNULL([Phone No],'0'),dbo.Fn_Removejunk(ISNULL(EmailId,'')),ISNULL([Key Account],''),
		ISNULL([Coverage Mode],''),CAST([Registration Date] AS DATETIME) AS [Registration Date],ISNULL([Day Off],''),
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
	FROM ETL_Prk_Retailer WITH(NOLOCK) ORDER BY [Retailer Code]
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
		IF EXISTS (SELECT '*' FROM Configuration WHERE ModuleId = 'GENCONFIG30' AND ModuleName = 'General Configuration' AND Status = 1)
		BEGIN
			IF LTRIM(RTRIM(@PhoneNo))=''
			BEGIN
				--IF EXISTS (SELECT RtrPhoneNo from Retailer (Nolock) where RtrPhoneNo = @PhoneNo AND RtdId NOT IN (@RetailerCode))
				IF EXISTS (SELECT RtrPhoneNo from Retailer (Nolock) where RtrPhoneNo = @PhoneNo AND RtrCode NOT IN (@RetailerCode))
				BEGIN
					SET @Po_ErrNo=1		
					SET @Taction=0
					SET @ErrDesc = 'Retailer Phone Number not be Empty '		
					INSERT INTO Errorlog VALUES (43,@Tabname,'Phone Number',@ErrDesc)
				END
			END			
		END
		
		IF LTRIM(RTRIM(@PhoneNo))<>''
		BEGIN
			--IF EXISTS (SELECT RtrPhoneNo from Retailer (Nolock) where RtrPhoneNo = @PhoneNo AND RtrId  NOT IN (@RetailerCode))
			IF EXISTS (SELECT RtrPhoneNo from Retailer (Nolock) where RtrPhoneNo = @PhoneNo AND RtrCode  NOT IN (@RetailerCode))
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Retailer Phone Number should be unique '		
				INSERT INTO Errorlog VALUES (43,@Tabname,'Phone Number',@ErrDesc)
			END
		END
		IF LTRIM(RTRIM(@TINNumber))<>''
		BEGIN
			--IF EXISTS (SELECT RtrTINNo from Retailer (Nolock) where RtrTINNo = @TINNumber AND RtrId NOT IN (@RetailerCode))
			IF EXISTS (SELECT RtrTINNo from Retailer (Nolock) where RtrTINNo = @TINNumber AND RtrCode NOT IN (@RetailerCode))
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0
				SET @ErrDesc = 'Retailer Tin Number Should be unique '		
				INSERT INTO Errorlog VALUES (43,@Tabname,'TiN Number',@ErrDesc)
			END
		END				
		IF  @Taction=1 AND @Po_ErrNo=0
		BEGIN	
			INSERT INTO Retailer(RtrId,RtrCode,CmpRtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrKeyAcc,RtrCovMode,
			RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,RtrCSTNo,TaxGroupId,RtrCrBills,RtrCrLimit,RtrCrDays,
			RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,
			RtrPestLicNo,RtrPestExpiryDate,GeoMainId,RMId,VillageId,RtrResPhone1,RtrOffPhone1,RtrDepositAmt,RtrAnniversary,RtrDOB,CoaId,RtrOnAcc,
			RtrShipId,RtrType,RtrFrequency,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert,Upload,Approved,XmlUpload,
			Availability,LastModBy,LastModDate,AuthId,AuthDate,RtrUniqueCode)--Gopi at 08/11/2016
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
			'N',0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name ='Proc_GetStockLedgerSummaryDatewiseParle' AND XTYPE ='P')
DROP PROCEDURE  Proc_GetStockLedgerSummaryDatewiseParle
GO
CREATE PROCEDURE  Proc_GetStockLedgerSummaryDatewiseParle
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
------------------------------------------------
* 11/06/2014	Muthuvelsamy R	PMS Id DCRSTPAR0511
*********************************/
SET NOCOUNT ON
BEGIN
DECLARE @StockType AS NUMERIC(18,0)
IF EXISTS (SELECT DISTINCT SelValue FROM ReportFilterDt WHERE RptId = 245 AND SelId = 291 AND SelValue <> 0 AND UsrId = @Pi_UserId)
BEGIN 	
	SELECT @StockType = SystemStockType FROM ReportFilterDt A WITH (NOLOCK),StockType B WITH (NOLOCK) 
	WHERE A.SelValue = B.StockTypeId AND RptId = 245 AND SelId = 291 AND UsrId = @Pi_UserId
END
ELSE
BEGIN
   SET @StockType = 0
END
	TRUNCATE TABLE TempStockLedSummaryTotal
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		DELETE FROM TaxForReport WHERE UsrId=@Pi_UserId AND RptId=100
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UserId,100
	END
	
	DECLARE @ProdDetail TABLE
		(
			lcnid	INT,
			PrdBatId INT,
			TransDate DATETIME
		)
	DELETE FROM @ProdDetail
--	INSERT INTO @ProdDetail
--		(
--			lcnid,PrdBatId,TransDate
--		)
--	
--	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
--	(
--		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
--			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
--		Group by lcnid,prdbatid
--	) a LEFT OUTER JOIN
--	(
--		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
--			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--		Group by lcnid,prdbatid
--	) b
--	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
--	where b.lcnid is null and b.prdbatid is null
			
	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger SL(nolock)  
	/*Code Modified by Muthuvelsamy R for the PMS Id DCRSTPAR0511 begins here*/
	--WHERE TransDate <@Pi_FromDate AND CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) NOT IN
	--(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) 
	--FROM StockLedger WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate)
	WHERE TransDate <@Pi_FromDate AND NOT EXISTS
	(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) 
	FROM StockLedger X(NOLOCK) WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate 
	AND X.PrdId = SL.PrdId AND X.PrdBatId = SL.PrdBatId AND X.LcnId = SL.LcnId)
	/*Code Modified by Muthuvelsamy R for the PMS Id DCRSTPAR0511 ends here*/
	GROUP BY LcnId,PrdBatId
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
		(CASE @StockType WHEN 1 THEN Sl.SalOpenStock WHEN 2 THEN Sl.UnSalOpenStock WHEN 3 THEN Sl.OfferOpenStock
		ELSE (Sl.SalOpenStock+Sl.UnSalOpenStock+Sl.OfferOpenStock) END) AS Opening,
		(CASE @StockType WHEN 1 THEN Sl.SalPurchase WHEN 2 THEN Sl.UnsalPurchase WHEN 3 THEN Sl.OfferPurchase
		ELSE (Sl.SalPurchase+Sl.UnsalPurchase+Sl.OfferPurchase) END) AS Purchase,
		(CASE @StockType WHEN 1 THEN Sl.SalSales WHEN 2 THEN Sl.UnSalSales WHEN 3 THEN Sl.OfferSales
		ELSE (Sl.SalSales+Sl.UnSalSales+Sl.OfferSales) END) AS Sales,
		(CASE @StockType WHEN 1 THEN (-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement)
		WHEN 2 THEN	(-Sl.UnSalPurReturn+Sl.UnSalStockIn-Sl.UnSalStockOut+Sl.UnSalSalesReturn+Sl.UnSalStkJurIn-Sl.UnSalStkJurOut+
		Sl.UnSalBatTfrIn-Sl.UnSalBatTfrOut+Sl.UnSalLcnTfrIn-Sl.UnSalLcnTfrOut+Sl.DamageIn-Sl.DamageOut)	
		WHEN 3 THEN	(-Sl.OfferPurReturn+Sl.OfferStockIn-Sl.OfferStockOut+Sl.OfferSalesReturn+Sl.OfferStkJurIn-Sl.OfferStkJurOut+
		Sl.OfferBatTfrIn-Sl.OfferBatTfrOut+Sl.OfferLcnTfrIn-Sl.OfferLcnTfrOut-Sl.OfferReplacement)
		ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut)END) AS Adjustments,
		(CASE @StockType WHEN 1 THEN Sl.SalClsStock WHEN 2 THEN Sl.UnSalClsStock WHEN 3 THEN Sl.OfferClsStock
		ELSE (Sl.SalClsStock+Sl.UnSalClsStock+Sl.OfferClsStock) END) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
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
		(CASE @StockType WHEN 1 THEN Sl.SalOpenStock WHEN 2 THEN Sl.UnSalOpenStock WHEN 3 THEN 0
		ELSE (Sl.SalOpenStock+Sl.UnSalOpenStock) END) AS Opening,
		(CASE @StockType WHEN 1 THEN Sl.SalPurchase WHEN 2 THEN Sl.UnsalPurchase WHEN 3 THEN 0
		ELSE (Sl.SalPurchase+Sl.UnsalPurchase) END) AS Purchase,
		(CASE @StockType WHEN 1 THEN Sl.SalSales WHEN 2 THEN Sl.UnSalSales WHEN 3 THEN 0
		ELSE (Sl.SalSales+Sl.UnSalSales) END) AS Sales,
		(CASE @StockType WHEN 1 THEN (-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement)
		WHEN 2 THEN	(-Sl.UnSalPurReturn+Sl.UnSalStockIn-Sl.UnSalStockOut+Sl.UnSalSalesReturn+Sl.UnSalStkJurIn-Sl.UnSalStkJurOut+
		Sl.UnSalBatTfrIn-Sl.UnSalBatTfrOut+Sl.UnSalLcnTfrIn-Sl.UnSalLcnTfrOut+Sl.DamageIn-Sl.DamageOut)	
		--Commented and added by Rajesh ICRSTPAR4454
		--WHEN 3 THEN	0 ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.SalStockOut-Sl.UnSalStockOut
		WHEN 3 THEN	0 ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn-Sl.SalStockOut-Sl.UnSalStockOut
		--Till Here 
		
		+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-
		Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut)END) AS Adjustments,
		(CASE @StockType WHEN 1 THEN Sl.SalClsStock WHEN 2 THEN Sl.UnSalClsStock WHEN 3 THEN 0
		ELSE (Sl.SalClsStock+Sl.UnSalClsStock) END) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
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
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN ISNULL(Sl.OfferClsStock,0)
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) END) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN ISNULL(Sl.OfferClsStock,0)
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) END) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
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
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN 0
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) END) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN 0
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) END) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
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
	ProductBatch PrdBat (NOLOCK),ProductCategoryValue PCV (NOLOCK),Product Prd (NOLOCK)
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
	AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	
	UPDATE TempStockLedSummary SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
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
	END
--	SELECT * FROM TempStockLedSummary ORDER BY PrdId,PrdBatId,LcnId,TransDate
	
	SELECT MIN(TransDate) AS MinTransDate,MAX(TransDate) AS MaxTransDate,
	PrdId,PrdBatId,LcnId
	INTO #TempDates
	FROM TempStockLedSummary WHERE UserId=@Pi_UserId	
	GROUP BY PrdId,PrdBatId,LcnId
	ORDER BY PrdId,PrdBatId,LcnId
		
	
	INSERT INTO TempStockLedSummary(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
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
	UPDATE TempStockLedSummary SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummary.PrdId AND T.PrdBatId=TempStockLedSummary.PrdBatId AND
	T.LcnId=TempStockLedSummary.LcnId
	UPDATE TempStockLedSummary SET Closing=Opening+Purchase-Sales+Adjustment
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
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
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
END
GO
IF EXISTS (SELECT * FROM SYS.objects WHERE name ='Proc_ClosingStock' AND TYPE='P')
DROP PROCEDURE Proc_ClosingStock
GO
CREATE PROCEDURE [dbo].[Proc_ClosingStock]
(	
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_ToDate		DATETIME
)
AS
/*************************************************************
* PROCEDURE	: Proc_ClosingStock
* PURPOSE	: To get the Closing Stock Details
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 17/09/2008
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/ --select * from UOMMaster
BEGIN
	DECLARE @UOMID	AS INT	
	DELETE FROM TempClosingStock WHERE UsrId =@Pi_UsrId
	DELETE FROM TempStockLedSummary WHERE UserId =@Pi_UsrId
	EXEC Proc_GetStockLedgerSummaryDatewiseParle @Pi_ToDate, @Pi_ToDate,@Pi_UsrId,0,0,0
	
	SELECT @UOMID=UomID FROM UOMMaster WHERE UomDescription IN ('BOX','PACKETS') 
	INSERT INTO TempClosingStock([CmpId],[PrdId],[LcnId],[PrdName],[SellingRate],[ListPrice],[MRP],
	[Cases],[Pieces],[BaseQty],[BaseQtyWgt],[PrdStatus],[BatStatus],[UsrId],CloPurRte,CloSelRte )
	SELECT DISTINCT [CmpId],[PrdId],[LcnId],[PrdName],[SellingRate],[ListPrice],[MRP],
	[BillCase],[BillPiece],[Closing],[BaseQtyWgt],[PrdStatus],[Status],@Pi_UsrId AS [UsrId],CloPurRte,CloSelRte
	FROM
	(SELECT P.CmpID,LSB.[PrdId],LSB.[LcnId],
	P.[PrdName],PD.PrdBatDetailValue AS SellingRate,PD2.PrdBatDetailValue AS ListPrice,
	PD1.PrdBatDetailValue AS MRP,CASE ISNULL(UG.ConversionFactor,0)
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(LSB.[Closing] AS INT)/CAST(UG.ConversionFactor AS INT)
	END AS BillCase,
	CASE ISNULL(UG.ConversionFactor,0)
	WHEN 0 THEN LSB.[Closing] WHEN 1 THEN LSB.[Closing] ELSE
	CAST(LSB.[Closing] AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
	LSB.Closing,((LSB.Closing*P.PrdWgt)/1000) AS BaseQtyWgt,P.PrdStatus,PB.Status,LSB.CloPurRte,LSB.CloSelRte
	FROM TempStockLedSummary LSB WITH (NOLOCK),Product P WITH (NOLOCK)
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMID, --select * from ProductbatchDetails
	ProductBatch PB WITH (NOLOCK) ,
	ProductbatchDetails PD WITH (NOLOCK),
	BatchCreation BC WITH (NOLOCK),
	ProductbatchDetails PD1 WITH (NOLOCK),
	BatchCreation BC1 WITH (NOLOCK),
	ProductbatchDetails PD2 WITH (NOLOCK),
	BatchCreation BC2 WITH (NOLOCK),
	ProductCategoryLevel PCL WITH (NOLOCK),
	ProductCategoryValue PCV WITH (NOLOCK)
	WHERE LSB.PrdId=P.PrdId AND P.PrdID=PB.PrdID
	      	AND PB.PrdBatId=PD.PrdBatId AND PD.DefaultPrice=1
		AND PD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId
		AND BC.SelRte=1
		AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1
		AND PD1.SlNo =BC1.SlNo
		AND BC1.BatchSeqId=PB.BatchSeqId
		AND PD2.SlNo =BC2.SlNo
		AND BC2.BatchSeqId=PB.BatchSeqId
		AND P.PrdCtgValMainId=PCV.PrdCtgValMainId
		AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId
		AND PB.PrdBatId=PD2.PrdBatId AND BC2.ListPrice=1
		AND BC1.MRP=1 AND PD2.DefaultPrice=1
		AND LSB.PrdBatId=PB.PrdBatId
		/*Code Modified by Rajesh Ranjan for ICRSTPAR2960 begins here*/  
		--AND LSB.UserId =@Pi_UsrId
		AND LSB.UserId =@Pi_UsrId
		/*Code Modified by Rajesh Ranjan for ICRSTPAR2960 ends here*/ 
	) A
END
GO
DELETE FROM CONFIGURATION WHERE MODULEID IN ('GENCONFIG29')
INSERT INTO CONFIGURATION
SELECT 'GENCONFIG29','General Configuration','Display selected UOM in billing and order booking screens',1,0,0.00,29 
GO
DELETE FROM UOMCONFIG WHERE MODULEID='GENCONFIG29'
INSERT INTO UOMCONFIG(ModuleId,UomId,Value,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT 'GENCONFIG29',UomId,1,1,1,getdate(),1,getdate() FROM UOMMASTER(NOLOCK)
GO
DELETE FROM Configuration WHERE MODULEID='GENCONFIGNEW4'
INSERT INTO Configuration
SELECT 'GENCONFIGNEW4','General Configuration New','Order To Bill Conversion Based On Bill Product Uom Setting',0,'',0.00,4
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ReturnPrdBatchExpiryDay' AND XTYPE  in ('TF','FN'))
DROP FUNCTION Fn_ReturnPrdBatchExpiryDay
GO
--SELECT DISTINCT * FROM DBO.Fn_ReturnPrdBatchExpiryDay(3,1)
CREATE FUNCTION [dbo].[Fn_ReturnPrdBatchExpiryDay] (@PrdId AS BIGINT,@LcnId	AS INT)
RETURNS @PrdBatchBatchExpiryDay TABLE
	(
		PrdBatID     INT NOT NULL,
		PrdBatCode   NVARCHAR(100) NOT NULL,
		MRP          NUMERIC(18, 6) NOT NULL,
		PurchaseRate NUMERIC(18, 6) NOT NULL,
		SellRate     NUMERIC(18, 6) NOT NULL,
		StockAvail   INT NULL,
		ShelfDay     INT NULL,
		ExpiryDay    INT NULL,
		PriceId      NUMERIC(18,0) NOT NULL
	)
AS
BEGIN
/****************************************************************
* FUNCTION: Fn_ReturnPrdBatchExpiryDay
* PURPOSE: Returns the Product Batch ShelDay and ExpiryDay
* NOTES:
* CREATED: Sathishkumar Veeramani 2014/04/07
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------
*
*****************************************************************/
		INSERT INTO @PrdBatchBatchExpiryDay (PrdBatID,PrdBatCode,MRP,PurchaseRate,SellRate,StockAvail,ShelfDay,ExpiryDay,PriceId)
		SELECT DISTINCT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,
		(F.PrdBatLcnSih - F.PrdBatLcnRessih) AS StockAvail, DATEDIFF(DAY,CONVERT(VARCHAR(10),GETDATE(),121),DATEADD(DAY,PrdShelfLife,A.MnfDate)) AS ShelfDay,
		DATEDIFF(DAY,CONVERT(Varchar(10),GETDATE(),121),A.ExpDate) AS ExpiryDay,B.PriceId FROM ProductBatch A (NOLOCK) 
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
		INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
		INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
		INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
		INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
		INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId 
		WHERE A.Status = 1 AND A.PrdId=@PrdId AND F.LcnId = @LcnId And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 
		--AND B.PrdBatDetailValue >= D.PrdBatDetailValue
		ORDER BY A.PrdBatId Asc
 RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ReturnOrderBookingProducts' AND xtype in ('TF','FN'))
DROP FUNCTION Fn_ReturnOrderBookingProducts
GO
CREATE FUNCTION Fn_ReturnOrderBookingProducts(@OrderNo VARCHAR(100))
RETURNS @OrderBookingProduct TABLE
(
	SlNo		INT,
	PrdId		INT,
	PrdBatID	INT,
	PrddCode	NVARCHAR(100),
	PrdName		NVARCHAR(200),
	PrdBatCode	NVARCHAR(100),
	UomId1		INT,
	Qty1		INT,
	ConvFact1	INT,
	UomId2		INT,
	Qty2		INT,
	ConvFact2	INT,
	TotalQty	INT,
	billedQty	INT,
	MRP			NUMERIC(18,6),
	Rate		NUMERIC(18,6),
	GrossAmount	NUMERIC(18,6),
	PriceId		BIGINT
)
AS
BEGIN
	
	INSERT INTO @OrderBookingProduct
	SELECT OB.SLNO,ob.PrdId,ob.PrdBatID,G.PrddCode,G.PrdName,A.PrdBatCode, UomId1,
	Qty1,ConvFact1,UomId2,Qty2,ConvFact2,TotalQty,billedQty,MRP,Rate,GrossAmount,OB.PriceId 
	FROM ProductBatch A (NOLOCK) 
	INNER JOIN Product G (NOLOCK) ON G.Prdid = A.PrdId 
	INNER JOIN OrderBookingProducts OB (NOLOCK) ON OB.Prdid = G.PrdId and ob.prdbatid = a.prdbatid 
	WHERE OrderNo = @OrderNo ORDER BY SLNO ASC
RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_OrderProducts' AND xtype in ('TF','FN'))
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
	SellRate Numeric(36,6),
	SlNo Int,
	UnitSellRate Numeric(36,6)
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
	TotalQty BIGINT	,
	Slno INT
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
	
	INSERT INTO @OrderBookingProducts(Prdid,Prdbatid,PriceId,BaseQty,TotalQty,Slno)
	SELECT Prdid,Prdbatid,PriceId,(CASE @SelUOM WHEN 1 THEN SUM(Qty1) ELSE SUM(TotalQty) END) AS BaseQty,SUM(TotalQty) AS TotalQty,isnull(SlNo,1)
	FROM OrderBookingProducts (NOLOCK) WHERE OrderNo = @OrderNo
	GROUP BY Prdid,Prdbatid,PriceId,ISNULL(SlNo,1) HAVING SUM(TotalQty - IsNull(BilledQty, 0)) > 0	
	--ORDER BY LastModBy 
	
	IF @Type = 1
	BEGIN
		INSERT INTO @OrderProducts(Prdid,PrdDCode,PrdName,Prdbatid,PrdBatCode,BaseQty,TotalQty,PriceId,MRP,SellRate,Slno,UnitSellRate)
		SELECT X.Prdid,X.PrdDCode,X.PrdName,X.PrdBatId,X.PrdBatCode,BaseQty,TotalQty,X.PriceId,MRP,SellRate,Slno,SellRate
		FROM @Product X INNER JOIN  @OrderBookingProducts Y ON 
		X.Prdid=Y.Prdid and X.Prdbatid=Y.Prdbatid and X.PriceId=Y.PriceId
	END
	IF @Type = 2
	BEGIN
	    INSERT INTO @OrderProducts(Prdid,PrdDCode,PrdName,Prdbatid,PrdBatCode,BaseQty,TotalQty,PriceId,MRP,SellRate,Slno,UnitSellRate)
		SELECT X.Prdid,X.PrdDCode,X.PrdName,X.PrdBatId,X.PrdBatCode,BaseQty,TotalQty,X.PriceId,MRP,
		(CASE @SelUOM WHEN 1 THEN ((TotalQty*SellRate)/BaseQty) ELSE SellRate END) AS SellRate,Slno,SellRate
		FROM @Product X INNER JOIN  @OrderBookingProducts Y ON 
		X.Prdid=Y.Prdid and X.Prdbatid=Y.Prdbatid and X.PriceId=Y.PriceId
	END
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='TEMP_ReturnOrder_UOM_WS_Products' AND XTYPE='U')
DROP TABLE TEMP_ReturnOrder_UOM_WS_Products
GO
CREATE TABLE [dbo].[TEMP_ReturnOrder_UOM_WS_Products](
	[OrderNo] [nvarchar](50) NULL,
	[Prdid] [int] NULL,
	[PrdDCode] [varchar](100) NULL,
	[PrdName] [varchar](200) NULL,
	[Prdbatid] [int] NULL,
	[PrdBatCode] [varchar](100) NULL,
	[UomId1] [int] NULL,
	[UomDesc1] [varchar](25) NULL,
	[ConFac1] [int] NULL,
	[Qty1] [int] NULL,
	[UomId2] [int] NULL,
	[UomDesc2] [varchar](25) NULL,
	[ConFac2] [int] NULL,
	[Qty2] [int] NULL,
	[BaseQty] [int] NULL,
	[TotalQty] [int] NULL,
	[PriceId] [int] NULL,
	[MRP] [numeric](36, 6) NULL,
	[SellRate] [numeric](36, 6) NULL,
	[StockAvl] [int] NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='ManualConfiguration' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[ManualConfiguration](
	[ProjectName] [nvarchar](50) NOT NULL,
	[ModuleId] [nvarchar](50) NOT NULL,
	[ModuleName] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](300) NOT NULL,
	[Status] [tinyint] NOT NULL,
	[Condition] [nvarchar](4000) NULL,
	[ConfigValue] [numeric](18, 2) NULL,
	[SeqNo] [int] NOT NULL
) ON [PRIMARY]
END
GO
DELETE FROM ManualConfiguration WHERE ModuleId='MANUALCONFIG9'
INSERT INTO ManualConfiguration(ProjectName,ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'PARLE','MANUALCONFIG9','Manual Configuration','Retailer Validation removed from Sales panel',1,'',0,9
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='PROC_ReturnOrderProd_UOM_WS' AND xtype='P')
DROP PROCEDURE PROC_ReturnOrderProd_UOM_WS
GO
/*
EXEC PROC_ReturnOrderProd_UOM_WS 'ORD1600058',1,2,1
*/
CREATE PROCEDURE PROC_ReturnOrderProd_UOM_WS
(
	@OrderNo AS VARCHAR(100),
	@Lcnid AS INT,
	@Type AS INT,
	@UsrId AS INT
)
AS
BEGIN
DECLARE @PRDID INT
DECLARE @TOTALQTY INT	
DECLARE @UOMID INT
DECLARE @CONVERSIONFACTOR INT
DECLARE @PRDBATID INT
DECLARE @QTY INT
DECLARE @BPRDBATID INT
DECLARE @BQTY INT
DECLARE @UOMCODE VARCHAR(25)
DECLARE @BUOMID INT 
DECLARE @BConversionFactor INT
DECLARE @BUOMCODE VARCHAR(25)
--Added By Sathishkumar Veeramani 2015/02/03
DECLARE @Status AS INT
DECLARE @RtrType AS NUMERIC(18,0)
SET @Status = 0
SELECT @Status = ISNULL([Status],0) FROM Configuration (NOLOCK) WHERE ModuleId = 'BILL9' AND ModuleName = 'Billing'
SELECT @RtrType = ISNULL(RtrType,0) FROM Retailer A (NOLOCK) INNER JOIN OrderBooking B (NOLOCK) ON A.RtrId = B.RtrId 
WHERE B.OrderNo = @OrderNo
--Till Here 
DECLARE @NOS AS INT
SELECT @NOS = UomId FROM UomMaster (NOLOCK) WHERE UomCode = 'NOS'
	DELETE FROM TEMP_ReturnOrder_UOM_WS_Products WHERE UsrId=@UsrId
	
	CREATE TABLE #ORDERPRODUCTS 
	(
		PRDID INT,
		PRDBATID INT,
		Uomid1 INT,
		UomDesc1 Varchar(25),
		UomCon1 int,
		QTY1 INT,
		Uomid2 INT,
		UomDesc2 varchar(25),
		UomCon2 int,
		Qty2 INT,
		StockAvl INT
	)
	
	DECLARE @BilledOrder AS TABLE
	(
		SalId	BIGINT,
		OrderNo	VARCHAR(100),
		PrdId	BIGINT,
		BilledQty	BIGINT
	)
	
	CREATE TABLE #OrderBookingProducts
	(
		OrderNo		VARCHAR(100),
		PrdId		BIGINT,
		PrdBatId	BIGINT,
		BalanceQty	BIGINT		
	)
	
	INSERT INTO @BilledOrder
	SELECT SalId,OrderNo,PrdId,SUM(BilledQty) as BilledQty FROM 
	SalesInvoiceOrderBooking WHERE OrderNo=@OrderNo GROUP BY SalId,OrderNo,PrdId
	IF EXISTS(SELECT 'C' FROM @BilledOrder WHERE OrderNo=@OrderNo)
	BEGIN
				
		INSERT INTO #OrderBookingProducts(OrderNo,PrdId,PrdBatId,BalanceQty)
		SELECT OB.OrderNo,OBP.PrdId,PrdBatId,TotalQty-SUM(C.BilledQty) As BalanceQty FROM SalesInvoice A
		INNER JOIN OrderBooking OB ON A.OrderKeyNo=OB.OrderNo 
		INNER JOIN (SELECT OrderNo,PrdId,ConvFact1,MAX(PrdBatId) as PrdBatId,SUM(TOTALQTY) AS TOTALQTY FROM OrderBookingProducts 
		WHERE OrderNo=@OrderNo GROUP BY OrderNo,PrdId,ConvFact1)OBP ON OBP.OrderNo=OB.OrderNo and OBP.OrderNo=A.OrderKeyNo
		INNER JOIN @BilledOrder C ON C.SalId=A.SalId AND C.PrdId=OBP.PrdId AND C.OrderNo=OB.OrderNo AND C.OrderNo=OBP.OrderNo 
		WHERE DLVSTS<>3 GROUP BY OB.OrderNo,OBP.PrdId,PrdBatId,TotalQty
		
		INSERT INTO #OrderBookingProducts(OrderNo,PrdId,PrdBatId,BalanceQty)
		SELECT OB.OrderNo,OBP.PrdId,PrdBatId,TotalQty-BilledQty as BalanceQty FROM OrderBooking OB 
		INNER JOIN OrderBookingProducts OBP ON OBP.OrderNo=OB.OrderNo 
		WHERE OB.OrderNo=@OrderNo and NOT EXISTS(SELECT * FROM #OrderBookingProducts B WHERE OBP.PrdId=B.Prdid AND OB.OrderNo=B.OrderNo)
		
		
	END
	ELSE
	BEGIN
		INSERT INTO #OrderBookingProducts(OrderNo,PrdId,PrdBatId,BalanceQty)
		SELECT DISTINCT ORDERNO,PRDID,Prdbatid,TOTALQTY FROM ORDERBOOKINGPRODUCTS WHERE ORDERNO=@OrderNo
	END
	
	DECLARE CUR_orderBooking CURSOR
	FOR SELECT DISTINCT PRDID,Prdbatid,BalanceQty FROM #OrderBookingProducts WHERE ORDERNO=@OrderNo
	--SELECT DISTINCT PRDID,Prdbatid,TOTALQTY FROM ORDERBOOKINGPRODUCTS WHERE ORDERNO=@OrderNo
	OPEN CUR_orderBooking 
	FETCH NEXT FROM CUR_orderBooking  INTO @PRDID,@PRDBATID,@TOTALQTY
	WHILE @@FETCH_STATUS=0
	BEGIN
	
		--SELECT PrdId,SUM(PrdBatLcnSih-PrdBatLcnRessih) FROM ProductBatchLocation WHERE prdid=@PRDID AND LcnId=@Lcnid
		--GROUP BY prdid
	
	 -- IF EXISTS (SELECT PrdId,SUM(PrdBatLcnSih-PrdBatLcnRessih) FROM ProductBatchLocation WHERE prdid=@PRDID AND LcnId=@Lcnid
		--GROUP BY prdid HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>=@TOTALQTY )
	  IF EXISTS (SELECT PrdId,SUM(PrdBatLcnSih-PrdBatLcnRessih) FROM ProductBatchLocation WHERE prdid=@PRDID AND LcnId=@Lcnid
		GROUP BY prdid HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>=1)
	  BEGIN

			IF EXISTS (SELECT PrdId,PRDBATID,SUM(PrdBatLcnSih-PrdBatLcnRessih) FROM ProductBatchLocation WHERE prdid=@PRDID AND LcnId=@Lcnid
			GROUP BY prdid,PRDBATID HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>=@TOTALQTY )
				BEGIN		---UOM WISE SPLIT
				
					DECLARE CUR_UOM CURSOR
					FOR SELECT PRDBATID,UOMID,UOMCODE,CONVERSIONFACTOR,SUM(QTY) FROM(
						SELECT MAX(PRDBATID)PRDBATID,U.UOMID,UOMCODE,CONVERSIONFACTOR,(PrdBatLcnSih-PrdBatLcnRessih)QTY FROM ProductBatchLocation PB 
						INNER JOIN PRODUCT P ON PB.PRDID=P.PRDID INNER JOIN UOMGROUP U ON P.UOMGROUPID=U.UOMGROUPID INNER JOIN UOMMASTER UM ON UM.UOMID=U.UOMID
						WHERE PB.PrdId=@PRDID AND LcnId=@Lcnid
						GROUP BY u.UOMID,UOMCODE,CONVERSIONFACTOR ,PrdBatLcnSih,PrdBatLcnRessih)A GROUP BY PRDBATID,UOMID,UOMCODE,CONVERSIONFACTOR HAVING SUM(QTY)>=@TOTALQTY
						ORDER BY  CONVERSIONFACTOR DESC
					OPEN CUR_UOM
					FETCH NEXT FROM CUR_UOM INTO @PRDBATID,@UOMID,@UOMCODE,@CONVERSIONFACTOR,@QTY
					WHILE @@FETCH_STATUS=0
					BEGIN
					-- SELECT @PRDBATID,@UOMID,@UOMCODE,@CONVERSIONFACTOR,@QTY
					  IF  (@TOTALQTY/@CONVERSIONFACTOR>0) AND (@TOTALQTY%@CONVERSIONFACTOR>0)
						BEGIN
							INSERT INTO #ORDERPRODUCTS
							SELECT @PRDID,@PRDBATID,@UOMID,@UOMCODE,@CONVERSIONFACTOR,(@TOTALQTY/@CONVERSIONFACTOR),CASE @CONVERSIONFACTOR WHEN 1 THEN 0 ELSE @NOS END,
							CASE @CONVERSIONFACTOR WHEN 1 THEN '' ELSE 'NOS' END,CASE @CONVERSIONFACTOR WHEN 1 THEN 0 ELSE 1 END,
							CASE @CONVERSIONFACTOR WHEN 1 THEN 0 ELSE (@TOTALQTY%@CONVERSIONFACTOR) END,1
						BREAK	
						END 
					  IF  (@TOTALQTY/@CONVERSIONFACTOR>0) AND (@TOTALQTY%@CONVERSIONFACTOR=0)
						BEGIN
							INSERT INTO #ORDERPRODUCTS
							SELECT 	@PRDID,@PRDBATID,@UOMID,@UOMCODE,@CONVERSIONFACTOR,(@TOTALQTY/@CONVERSIONFACTOR),0,'',0,0,1
						BREAK	
						END 
					   
					FETCH NEXT FROM CUR_UOM INTO @PRDBATID,@UOMID,@UOMCODE,@CONVERSIONFACTOR,@QTY
					END 		
					CLOSE CUR_UOM 
					DEALLOCATE CUR_UOM					
				END
			ELSE
			 BEGIN --- BATCH WISE SPLIT
			 	DECLARE CUR_BATCH CURSOR
				FOR  SELECT PBL.PrdBatID,(PrdBatLcnSih-PrdBatLcnRessih)QTY FROM ProductBatchLocation PBL 
					 INNER JOIN ProductBatch PB ON PBL.PrdId=PB.PrdId AND PBL.PrdBatID=PB.PrdBatId WHERE PBL.PrdId=@PRDID AND LcnId=@Lcnid AND Status=1
				OPEN CUR_BATCH
				FETCH NEXT FROM CUR_BATCH INTO @BPRDBATID,@BQTY
				WHILE @@FETCH_STATUS=0
				BEGIN
				 	DECLARE CUR_BATCH_SPLIT CURSOR
					FOR  SELECT  U.UOMID,UomCode,ConversionFactor FROM PRODUCT P INNER JOIN UOMGROUP U ON P.UOMGROUPID=U.UOMGROUPID INNER JOIN UOMMASTER UM ON UM.UOMID=U.UOMID 
					WHERE PRDID=@PRDID ORDER BY ConversionFactor DESC
					OPEN CUR_BATCH_SPLIT
					FETCH NEXT FROM CUR_BATCH_SPLIT INTO @BUOMID,@BUOMCODE,@BConversionFactor
					WHILE @@FETCH_STATUS=0
					BEGIN
					  IF @TOTALQTY=0
						BEGIN
							BREAK
						END
						
					IF @BQTY>=@TOTALQTY
					 BEGIN	
						  IF  (@TOTALQTY/@BConversionFactor>0) AND (@TOTALQTY%@BConversionFactor>0)
							BEGIN
								INSERT INTO #ORDERPRODUCTS
								SELECT @PRDID,@BPRDBATID,@BUOMID,@BUOMCODE,@BConversionFactor,(@TOTALQTY/@BConversionFactor),CASE @BConversionFactor WHEN 1 THEN 0 ELSE @NOS END,
								CASE @BConversionFactor WHEN 1 THEN '' ELSE 'NOS' END,CASE @BConversionFactor WHEN 1 THEN 0 ELSE 1 END,
								CASE @BConversionFactor WHEN 1 THEN 0 ELSE (@TOTALQTY%@BConversionFactor) END,1
								
								SET @TOTALQTY=@TOTALQTY-@BQTY--
								
								BREAK	
							END 
						  IF  (@TOTALQTY/@BConversionFactor>0) AND (@TOTALQTY%@BConversionFactor=0)
							BEGIN
								INSERT INTO #ORDERPRODUCTS
								SELECT 	@PRDID,@BPRDBATID,@BUOMID,@BUOMCODE,@BConversionFactor,(@TOTALQTY/@BConversionFactor),0,'',0,0,1
								
								SET @TOTALQTY=@TOTALQTY-@BQTY--
								
								BREAK
							END 
					 END
					ELSE
					 BEGIN
					  
						  IF  (@BQTY/@BConversionFactor>0) AND (@BQTY%@BConversionFactor>0)
							BEGIN
								INSERT INTO #ORDERPRODUCTS
								SELECT @PRDID,@BPRDBATID,@BUOMID,@BUOMCODE,@BConversionFactor,(@BQTY/@BConversionFactor),CASE @BConversionFactor WHEN 1 THEN 0 ELSE @NOS END,
								CASE @BConversionFactor WHEN 1 THEN '' ELSE 'NOS' END,CASE @BConversionFactor WHEN 1 THEN 0 ELSE 1 END,
								CASE @BConversionFactor WHEN 1 THEN 0 ELSE (@BQTY%@BConversionFactor) END,1
								
								SET @TOTALQTY=@TOTALQTY-@BQTY
								BREAK	
							END 
						  IF  (@BQTY/@BConversionFactor>0) AND (@BQTY%@BConversionFactor=0)
							BEGIN
								INSERT INTO #ORDERPRODUCTS
								SELECT 	@PRDID,@BPRDBATID,@BUOMID,@BUOMCODE,@BConversionFactor,(@BQTY/@BConversionFactor),0,'',0,0,1
								
								SET @TOTALQTY=@TOTALQTY-@BQTY
								BREAK	
							END 
					 END
						
					FETCH NEXT FROM CUR_BATCH_SPLIT INTO @BUOMID,@BUOMCODE,@BConversionFactor
					END 		
					CLOSE CUR_BATCH_SPLIT 
					DEALLOCATE CUR_BATCH_SPLIT 	
			   
				FETCH NEXT FROM CUR_BATCH INTO @BPRDBATID,@BQTY
				END 		
				CLOSE CUR_BATCH 
				DEALLOCATE CUR_BATCH 
			 END	
		END
	  ELSE
	  BEGIN
	
		
		
		SELECT  @BUOMID=UG.UOMID,@BUOMCODE=UomCode,@BConversionFactor=ConversionFactor FROM PRODUCT P 
		INNER JOIN UOMGROUP UG ON P.UOMGROUPID=UG.UOMGROUPID 
		INNER JOIN UOMMASTER UM ON UM.UOMID=UG.UOMID 
		WHERE PRDID=@PRDID AND EXISTS(SELECT UomGroupId,ConversionFactor FROM (SELECT UomGroupId,MAX(ConversionFactor) as ConversionFactor FROM 
		UomGroup(NOLOCK) GROUP BY UomGroupId)UG1 WHERE UG.UomGroupId=UG1.UomGroupId and UG.ConversionFactor=UG1.ConversionFactor)

		SET @BPRDBATID=@PRDBATID
		SET @BQTY=@TOTALQTY
		
		IF @BQTY>=@TOTALQTY
		BEGIN	
		  IF  (@TOTALQTY/@BConversionFactor>0) AND (@TOTALQTY%@BConversionFactor>0)
			BEGIN
				INSERT INTO #ORDERPRODUCTS
				SELECT @PRDID,@BPRDBATID,@BUOMID,@BUOMCODE,@BConversionFactor,(@TOTALQTY/@BConversionFactor),CASE @BConversionFactor WHEN 1 THEN 0 ELSE @NOS END,
				CASE @BConversionFactor WHEN 1 THEN '' ELSE 'NOS' END,CASE @BConversionFactor WHEN 1 THEN 0 ELSE 1 END,
				CASE @BConversionFactor WHEN 1 THEN 0 ELSE (@TOTALQTY%@BConversionFactor) END,0
				
				SET @TOTALQTY=@TOTALQTY-@BQTY--
				
				BREAK	
			END 
		  IF  (@TOTALQTY/@BConversionFactor>0) AND (@TOTALQTY%@BConversionFactor=0)
			BEGIN
				INSERT INTO #ORDERPRODUCTS
				SELECT 	@PRDID,@BPRDBATID,@BUOMID,@BUOMCODE,@BConversionFactor,(@TOTALQTY/@BConversionFactor),0,'',0,0,0
				
				SET @TOTALQTY=@TOTALQTY-@BQTY--
				
				--BREAK
			END 
		END
		
	    --INSERT INTO #ORDERPRODUCTS
	    --SELECT @PRDID,@PRDBATID,UOMId1,UomCode,ConversionFactor,@TOTALQTY/ConversionFactor,0,'',0,0,0 FROM OrderBookingProducts O 
	    --INNER JOIN Product P ON O.PrdId=P.PrdId INNER JOIN UomGroup UG ON UG.UomGroupId=P.UomGroupId 
	    --AND UG.UomId=O.UOMId1 INNER JOIN UomMaster UM ON UM.UomId=UG.UomId
	    --WHERE OrderNo=@OrderNo AND  O.PrdId=@PRDID AND PrdBatId=@PRDBATID
	    
	  END 	
	FETCH NEXT FROM CUR_orderBooking INTO @PRDID,@PRDBATID,@TOTALQTY
	END
	CLOSE CUR_orderBooking
	DEALLOCATE CUR_orderBooking
	
	IF @Status = 1
	BEGIN
	    INSERT INTO TEMP_ReturnOrder_UOM_WS_Products
		SELECT @OrderNo,O.PRDID,P.PrdCCode,PrdName,O.PRDBATID,PrdBatCode,Uomid1,UomDesc1,UomCon1,QTY1,Uomid2,UomDesc2,
		UomCon2,Qty2,0,((UomCon1*QTY1)+(UomCon2*Qty2)),PBL1.PriceId,PBL1.PrdBatDetailValue AS MRP,
		PBL2.PrdBatDetailValue AS RATE,StockAvl,@UsrId FROM Product P (NOLOCK)
		INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId 
		INNER JOIN #ORDERPRODUCTS O (NOLOCK) ON O.PRDID=P.PrdId AND O.PRDID=PB.PrdId 
		INNER JOIN PRODUCTBATCHDETAILS PBL1 (NOLOCK) ON PBL1.PrdBatId=O.PRDBATID AND PBL1.PrdBatId=PB.PrdBatId AND PBL1.SLNO=1 AND PBL1.DefaultPrice=1
		INNER JOIN PRODUCTBATCHDETAILS PBL2 (NOLOCK) ON PBL2.PrdBatId=O.PRDBATID AND PBL2.PrdBatId=PB.PrdBatId 
		AND PBL2.SLNo=(CASE @RtrType WHEN 1 THEN 3 ELSE 2 END) AND PBL2.DefaultPrice=1
	END
	ELSE
	BEGIN 
	
		INSERT INTO TEMP_ReturnOrder_UOM_WS_Products
		SELECT @OrderNo,O.PRDID,P.PrdCCode,PrdName,O.PRDBATID,PrdBatCode,Uomid1,UomDesc1,UomCon1,QTY1,Uomid2,UomDesc2,
		UomCon2,Qty2,0,((UomCon1*QTY1)+(UomCon2*Qty2)),PBL1.PriceId,PBL1.PrdBatDetailValue,PBL2.PrdBatDetailValue,StockAvl,@UsrId 
		FROM Product P (NOLOCK) INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId 
		INNER JOIN #ORDERPRODUCTS O (NOLOCK) ON O.PRDID=P.PrdId AND O.PRDID=PB.PrdId 
		INNER JOIN PRODUCTBATCHDETAILS PBL1 (NOLOCK) ON PBL1.PrdBatId=O.PRDBATID AND PBL1.PrdBatId=PB.PrdBatId AND PBL1.DefaultPrice=1
		INNER JOIN BatchCreation BC1 (NOLOCK) ON BC1.SlNo=PBL1.SLNo AND BC1.MRP=1
		INNER JOIN PRODUCTBATCHDETAILS PBL2 (NOLOCK) ON PBL2.PrdBatId=O.PRDBATID AND PBL2.PrdBatId=PB.PrdBatId AND PBL2.DefaultPrice=1
		INNER JOIN BatchCreation BC2 (NOLOCK) ON BC2.SlNo=PBL2.SLNo AND BC2.SelRte=1
		
		--SELECT @OrderNo,O.PRDID,P.PrdCCode,PrdName,O.PRDBATID,PrdBatCode,Uomid1,UomDesc1,UomCon1,QTY1,Uomid2,UomDesc2,
		--UomCon2,Qty2,0,((UomCon1*QTY1)+(UomCon2*Qty2)),PBL1.PriceId,PBL1.PrdBatDetailValue,PBL2.PrdBatDetailValue,StockAvl,@UsrId 
		--FROM Product P (NOLOCK) INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId 
		--INNER JOIN #ORDERPRODUCTS O (NOLOCK) ON O.PRDID=P.PrdId AND O.PRDID=PB.PrdId 
		--INNER JOIN PRODUCTBATCHDETAILS PBL1 (NOLOCK) ON PBL1.PrdBatId=O.PRDBATID AND PBL1.PrdBatId=PB.PrdBatId AND PBL1.SLNO=1 AND PBL1.DefaultPrice=1
		--INNER JOIN PRODUCTBATCHDETAILS PBL2 (NOLOCK) ON PBL2.PrdBatId=O.PRDBATID AND PBL2.PrdBatId=PB.PrdBatId AND PBL2.SLNo=4 AND PBL2.DefaultPrice=1
		
	END
	SELECT * FROM TEMP_ReturnOrder_UOM_WS_Products
END
GO
DELETE FROM Tbl_downloadprocess_exportpda
INSERT INTO Tbl_DownloadProcess_ExportPDA(SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount)
SELECT 	'1','SalesManMaster',	'Cos2Mob_SalesManMaster',	'Proc_ExportPDA_SalesMan',	'0',	'500'	UNION ALL
SELECT 	'2','SalesRepresentative',	'Cos2Mob_SalesRepresentative',	'PROC_ExportPDA_SalesRepresentative',	'0',	'500'	 UNION ALL
SELECT 	'3','Market',	'Cos2Mob_Market',	'PROC_ExportPDA_Market',	'0',	'500'	 UNION ALL
SELECT 	'4','Retailer',	'Cos2Mob_Retailer',	'PROC_ExportPDA_Retailer',	'0',	'500'	 UNION ALL
SELECT 	'5','ProductCategory',	'Cos2Mob_ProductCategory',	'PROC_ExportPDA_ProductCategory',	'0',	'500'	 UNION ALL
SELECT 	'6','ProductCategoryValue',	'Cos2Mob_ProductCategoryValue',	'PROC_ExportPDA_ProductCategoryValue',	'0',	'500'	 UNION ALL
SELECT 	'7','Product',	'Cos2Mob_Product',	'PROC_ExportPDA_Product',	'0',	'500'	 UNION ALL
SELECT 	'8','Productbatch',	'Cos2Mob_Productbatch',	'PROC_ExportPDA_Productbatch',	'0',	'500'	 UNION ALL
SELECT 	'9','Bank',	'Cos2Mob_Bank',	'PROC_ExportPDA_Bank',	'0',	'500'	 UNION ALL
SELECT 	'10','BankBranch',	'Cos2Mob_BankBranch',	'PROC_ExportPDA_BankBranch',	'0',	'500'	 UNION ALL
SELECT 	'11','PendingBills',	'Cos2Mob_PendingBills',	'PROC_ExportPDA_PendingBills',	'0',	'500'	 UNION ALL
SELECT 	'12','CreditNote',	'Cos2Mob_CreditNote',	'PROC_ExportPDA_CreditNote',	'0',	'500'	 UNION ALL
SELECT 	'13','DebitNote',	'Cos2Mob_DebitNote',	'PROC_ExportPDA_DebitNote',	'0',	'500'	 UNION ALL
SELECT 	'14','RetailerCategoryLevel',	'Cos2Mob_RetailerCategoryLevel',	'PROC_ExportPDA_RetailerCategoryLevel',	'0',	'500'	 UNION ALL
SELECT 	'15','RetailerCategory',	'Cos2Mob_RetailerCategory',	'PROC_ExportPDA_RetailerCategory',	'0',	'500'	 UNION ALL
SELECT 	'16','RetailerValueClass',	'Cos2Mob_RetailerValueClass',	'PROC_ExportPDA_RetailerValueClass',	'0',	'500'	 UNION ALL
SELECT 	'17','SchemeNarration',	'Cos2Mob_SchemeNarration',	'Proc_ExportPDA_SchemeNarration',	'0',	'500'	 UNION ALL
SELECT 	'18','SchemeProductDetails',	'Cos2Mob_SchemeProductDetails',	'PROC_ExportPDA_SchemeProductDetails',	'0',	'500'	 UNION ALL
SELECT 	'19','ReasonMaster',	'Cos2Mob_ReasonMaster',	'PROC_ExportPDA_ReasonMaster',	'0',	'500'	 UNION ALL
SELECT 	'20','SalesmanDashBoard',	'Cos2Mob_SalesmanDashBoard',	'Proc_ExportPDA_SalesmanDashBoard',	'0',	'500'	 UNION ALL
SELECT 	'21','RetailerDashBoard',	'Cos2Mob_RetailerDashBoard',	'Proc_ExportPDA_RetailerDashBoard',	'0',	'500'	 UNION ALL
SELECT 	'22','OrderBookingDashBoard',	'Cos2Mob_OrderBookingDashBoard',	'Proc_ExportPDA_OrderBookingDashBoard',	'0',	'500'	 UNION ALL
SELECT 	'23','OrderProductDashBoard',	'Cos2Mob_OrderProductDashBoard',	'Proc_ExportPDA_OrderProductDashBoard',	'0',	'500'	 UNION ALL
SELECT 	'24','RetailerProductDashBoard',	'Cos2Mob_RetailerProductDashBoard',	'Proc_ExportPDA_RetailerProductDashBoard',	'0',	'500'	 UNION ALL
SELECT 	'25','MarketIntelligencehd',	'Cos2Mob_MarketIntelligenceHD',	'Proc_Export_PDA_MarketIntelligencehd',	'0',	'500'	 UNION ALL
SELECT 	'26','MarketIntelligencedt',	'Cos2Mob_MarketIntelligenceDT',	'Proc_Export_PDA_MarketIntelligencedt',	'0',	'500'	 UNION ALL
SELECT 	'27','SFA_RetailerCategory',	'SFA_RetailerCategory',	'Proc_SFA_RetailerCategory',	'0',	'500'	 UNION ALL
SELECT 	'28','UomMaster',	'Cos2Mob_UomMaster',	'Proc_Export_PDA_UomMaster',	'0',	'500'	
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id 
AND A.name='Mob2Cos_OrderBooking' AND B.name='EndTime')
BEGIN
	ALTER TABLE Mob2Cos_OrderBooking
	ADD [EndTime] [datetime] DEFAULT (GETDATE())
END
GO
IF NOT EXISTS(SELECT A.name FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.ID 
WHERE A.name='ImportPDA_OrderBooking' AND a.xtype='U' AND B.NAME='EndTime')
BEGIN
	ALTER TABLE ImportPDA_OrderBooking ADD EndTime DATETIME 
END
GO
UPDATE ImportPDA_OrderBooking SET EndTime=OrdDt WHERE ISNULL(EndTime,'')=''
GO
IF NOT EXISTS(SELECT A.name FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.ID 
WHERE A.name='ImportPDA_NewRetailerOrderBooking' AND a.xtype='U' AND B.NAME='EndTime')
BEGIN
	ALTER TABLE ImportPDA_NewRetailerOrderBooking ADD EndTime DATETIME 
END
GO
UPDATE ImportPDA_NewRetailerOrderBooking SET EndTime=OrdDt WHERE ISNULL(EndTime,'')=''
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND 
A.name='Mob2Cos_OrderBookingProduct' AND B.name='LineId')
BEGIN
	ALTER TABLE Mob2Cos_OrderBookingProduct
	ADD LineId INT DEFAULT (0)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND 
A.name='ImportPDA_OrderBookingProduct' AND B.name='LineId')
BEGIN
	ALTER TABLE ImportPDA_OrderBookingProduct
	ADD LineId INT DEFAULT (0)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND 
A.name='ImportPDA_NewRetailerOrderProduct' AND B.name='LineId')
BEGIN
	ALTER TABLE ImportPDA_NewRetailerOrderProduct
	ADD LineId INT DEFAULT (0)
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tbl_PDAConfiguration]') AND type in (N'U'))
DROP TABLE [dbo].[Tbl_PDAConfiguration]
GO
CREATE TABLE [dbo].[Tbl_PDAConfiguration](
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[ProcessName] [varchar](50) NULL,
	[Setting] [int] NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
Insert into [Tbl_PDAConfiguration]
select 'ClearSalesMan',	1,GetDate()
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Sales_Upload' AND XTYPE='U')
DROP TABLE Sales_Upload
GO
CREATE TABLE Sales_Upload
(
	[SMID] [int] NULL,
	[RMID] [int] NULL,
	[SUN] [tinyint] NULL,
	[MON] [tinyint] NULL,
	[TUE] [tinyint] NULL,
	[WED] [tinyint] NULL,
	[THU] [tinyint] NULL,
	[FRI] [tinyint] NULL,
	[SAT] [tinyint] NULL
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Fn_ReturnPDARouteMaster' AND XTYPE='TF')
DROP FUNCTION Fn_ReturnPDARouteMaster
GO
--SELECT DISTINCT * FROM Dbo.Fn_ReturnPDARouteMaster ()
CREATE FUNCTION Fn_ReturnPDARouteMaster()
RETURNS @ReturnPDARouteMaster TABLE    
(     
   RMId   NUMERIC(18,0)    
)    
AS    
/*****************************************************    
* FUNCTION  : Fn_ReturnPDADSRBeatCallDays    
* PURPOSE   : Return PDA Salesman & Route Details    
* NOTES     :     
* CREATED   : Sathishkumar Veeramani 2015/05/27    
* MODIFIED     
* DATE      AUTHOR     DESCRIPTION    
-----------------------------------------------------    
*     
*****************************************************/    
BEGIN    
     DECLARE @RouteCallDays TABLE     
     (    
       RMId   NUMERIC(18,0)    
     )     
     INSERT INTO @RouteCallDays (RMId)     
     SELECT DISTINCT RMId FROM (    
     SELECT DISTINCT RM.RMId FROM RouteMaster RM (NOLOCK) INNER JOIN SALES_UPLOAD SU (NOLOCK)     
     ON RM.RMSun = SU.SUN WHERE RM.RMSRouteType = 1 AND SU.SUN = 1 UNION    
     SELECT DISTINCT RM.RMId FROM RouteMaster RM (NOLOCK) INNER JOIN SALES_UPLOAD SU (NOLOCK)     
     ON RM.RMMon = SU.MON WHERE RM.RMSRouteType = 1 AND SU.MON = 1 UNION    
     SELECT DISTINCT RM.RMId FROM RouteMaster RM (NOLOCK) INNER JOIN SALES_UPLOAD SU (NOLOCK)     
     ON RM.RMTue = SU.TUE WHERE RM.RMSRouteType = 1 AND SU.TUE = 1 UNION    
     SELECT DISTINCT RM.RMId FROM RouteMaster RM (NOLOCK) INNER JOIN SALES_UPLOAD SU (NOLOCK)     
     ON RM.RMWed = SU.WED WHERE RM.RMSRouteType = 1 AND SU.WED = 1 UNION    
     SELECT DISTINCT RM.RMId FROM RouteMaster RM (NOLOCK) INNER JOIN SALES_UPLOAD SU (NOLOCK)     
     ON RM.RMThu = SU.THU WHERE RM.RMSRouteType = 1 AND SU.THU = 1 UNION    
     SELECT DISTINCT RM.RMId FROM RouteMaster RM (NOLOCK) INNER JOIN SALES_UPLOAD SU (NOLOCK)     
     ON RM.RMFri = SU.FRI WHERE RM.RMSRouteType = 1 AND SU.FRI = 1 UNION    
     SELECT DISTINCT RM.RMId FROM RouteMaster RM (NOLOCK) INNER JOIN SALES_UPLOAD SU (NOLOCK)     
     ON RM.RMSat = SU.SAT WHERE RM.RMSRouteType = 1 AND SU.SAT = 1)A    
     
     INSERT INTO @ReturnPDARouteMaster(RMId)    
     SELECT RM.RMId FROM SALES_UPLOAD SU (NOLOCK)     
     INNER JOIN SalesmanMarket SM (NOLOCK) ON SU.SMId = SM.SMId    
     INNER JOIN RouteMaster RM (NOLOCK) ON SM.RMId = RM.RMId AND RM.RMSRouteType = 1         
     --INNER JOIN RetailerMarket RM (NOLOCK) ON SM.RMId = RM.RMId    
     INNER JOIN @RouteCallDays RCD ON RM.RMId = RCD.RMId    
RETURN         
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_PDAGetSalesMan' AND XTYPE='P')
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

 CREATE TABLE #DAY  
 (DAYID INT,DAY_NAME VARCHAR(50))  
   
 INSERT INTO #DAY  
 SELECT 1,'Monday'  
 UNION  
 SELECT 2,'Tuesday'  
 UNION  
 SELECT 3,'Wednesday' UNION SELECT 4,'Thursday' UNION SELECT 5,'Friday' UNION SELECT 6,'Saturday' UNION SELECT 7,'Sunday'  


 IF @PID = 1       
  BEGIN       
 SELECT SMNAME AS SALESMAN,SMCODE AS SALESMANCODE FROM SALESMAN ORDER BY SMNAME   
 
  SELECT DAY_NAME,DAYID FROM #DAY ORDER BY DAYID  
 SELECT DAYID from #DAY WHERE DAY_NAME = DATENAME (DW,GETDATE())     
  END       
 IF @PID = 2     
  BEGIN     
   DELETE FROM SSM_UPLOAD     
  END     
  IF @PID = 3     
  BEGIN     
  -- DELETE FROM SSM_UPLOAD     
   INSERT INTO SSM_UPLOAD SELECT DISTINCT SMId FROM Salesman WHERE SMCode = @SMCode     
  END     
  IF @PID = 4     
  BEGIN     
   SELECT DISTINCT SMName FROM Salesman WHERE SMId IN (SELECT SMId FROM SSM_UPLOAD)     
  END     
  IF @PID = 5     
  BEGIN     
  
  SELECT R.Rmid AS RMID,Rmname from routemaster R   
 inner join SalesmanMarket SM on SM.Rmid=R.Rmid   
 inner join Salesman S on S.smid=SM.smid  
 where   
 Rmstatus=1   
 AND S.smid IN (SELECT SMID FROM SALES_UPLOAD)  

 --SELECT R.Rmid AS RMID,Rmname from routemaster R     
 --INNER JOIN SalesmanMarket SM on SM.Rmid=R.Rmid     
 --INNER JOIN Salesman S on S.smid=SM.smid    
 --WHERE Rmstatus=1 AND S.smid IN (SELECT SMID FROM SSM_UPLOAD) AND (RMmon =1 OR RMTue =1 OR RMWed =1 OR RMThu =1 OR RMFri =1 OR    
 --RMSat =1 OR RMSun =1)     
 --SELECT DISTINCT S.SMID,R.Rmid AS RMID   from Routemaster R     
 --INNER JOIN SalesmanMarket SM on SM.Rmid=R.Rmid     
 --INNER JOIN Salesman S on S.smid=SM.smid    
 --WHERE Rmstatus=1 AND S.smid IN (SELECT SMID FROM SSM_UPLOAD)    
 --And Sm.RMId in (SELECT RMId  FROM SALES_UPLOAD)    
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
 --INSERT INTO SALES_UPLOAD SELECT 0,@RMID    
 INSERT INTO SALES_UPLOAD  SELECT 0,@RMID,0,0,0,0,0,0,0
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
    IF @PID = 13     
  BEGIN     
 -- CREATE TABLE #SALESMAN    
 --(SMID INT,RMID INT,P_STATUS INT  )    
 --INSERT INTO #SALESMAN    
 --SELECT DISTINCT A.SMID,RMID,0 FROM SSM_UPLOAD A(NOLOCK),SALES_UPLOAD B(NOLOCK)    
 --SELECT DISTINCT S.SMID,R.Rmid AS RMID INTO #SALESMAN_ROOT     
 --from Routemaster R     
 --INNER JOIN SalesmanMarket SM on SM.Rmid=R.Rmid     
 --INNER JOIN Salesman S on S.smid=SM.smid    
 --WHERE Rmstatus=1 AND S.smid IN (SELECT SMID FROM SSM_UPLOAD)    
 --UPDATE A SET A.P_STATUS = 1 FROM #SALESMAN A,#SALESMAN_ROOT B    
 --WHERE A.SMID = B.SMId AND A.RMID = B.RMID     
 --DELETE FROM #SALESMAN WHERE P_STATUS = 0    
 --TRUNCATE TABLE SALES_UPLOAD    
 --INSERT INTO SALES_UPLOAD    
 --SELECT SMID,RMID  FROM #SALESMAN 
 
	IF @RMID = 1  
	  UPDATE SALES_UPLOAD SET MON = 1  
	 IF @RMID = 2  
	  UPDATE SALES_UPLOAD SET TUE = 1  
	 IF @RMID = 3  
	  UPDATE SALES_UPLOAD SET WED = 1  
	 IF @RMID = 4  
	  UPDATE SALES_UPLOAD SET THU = 1  
	 IF @RMID = 5  
	  UPDATE SALES_UPLOAD SET FRI = 1  
	 IF @RMID = 6  
	  UPDATE SALES_UPLOAD SET SAT = 1  
	 IF @RMID = 7  
	  UPDATE SALES_UPLOAD SET SUN = 1  
	    
	 CREATE TABLE #SALESMAN  
	 (SMID INT,RMID INT,SUN tinyint,MON tinyint,TUE tinyint,WED tinyint,THU tinyint ,FRI tinyint,SAT tinyint,P_STATUS INT  )  
	   
	 INSERT INTO #SALESMAN  
	 SELECT DISTINCT A.SMID,RMID,SUN,MON,TUE,WED,THU,FRI,SAT,0 FROM SSM_UPLOAD A(NOLOCK),SALES_UPLOAD B(NOLOCK)  
	   
	 SELECT DISTINCT S.SMID,R.Rmid AS RMID INTO #SALESMAN_ROOT from Routemaster R   
	 INNER JOIN SalesmanMarket SM on SM.Rmid=R.Rmid   
	 INNER JOIN Salesman S on S.smid=SM.smid  
	 WHERE Rmstatus=1 AND S.smid IN (SELECT SMID FROM SSM_UPLOAD)  
	   
	 UPDATE A SET A.P_STATUS = 1 FROM #SALESMAN A,#SALESMAN_ROOT B  
	 WHERE A.SMID = B.SMId AND A.RMID = B.RMID   
	   
	 DELETE FROM #SALESMAN WHERE P_STATUS = 0  
	   
	 TRUNCATE TABLE SALES_UPLOAD  
	   
	 INSERT INTO SALES_UPLOAD  
	 SELECT SMID,RMID,SUN,MON,TUE,WED,THU,FRI,SAT FROM #SALESMAN    
  END    
  IF @PID = 14     
  BEGIN     
 SELECT A.SMID,SMCode FROM SSM_UPLOAD A , Salesman B    
    Where A.SMID = B.SMId Order by A.SMID  
  END  
   
  IF @PID = 15   
  BEGIN   
   
 IF @RMID = 1  
  UPDATE SALES_UPLOAD SET MON = 1  
 IF @RMID = 2  
  UPDATE SALES_UPLOAD SET TUE = 1  
 IF @RMID = 3  
  UPDATE SALES_UPLOAD SET WED = 1  
 IF @RMID = 4  
  UPDATE SALES_UPLOAD SET THU = 1  
 IF @RMID = 5  
  UPDATE SALES_UPLOAD SET FRI = 1  
 IF @RMID = 6  
  UPDATE SALES_UPLOAD SET SAT = 1  
 IF @RMID = 7  
  UPDATE SALES_UPLOAD SET SUN = 1  
 END   
 
  IF @PID = 16   
  BEGIN   
	DELETE FROM SALES_UPLOAD
	INSERT INTO SALES_UPLOAD  
	SELECT SMID,0,0,0,0,0,0,0,0 FROM SSM_UPLOAD  
  END 
  
  IF @PID = 17   
  BEGIN   
   
 IF @RMID = 1  
  UPDATE SALES_UPLOAD SET MON = 1  
 IF @RMID = 2  
  UPDATE SALES_UPLOAD SET TUE = 1  
 IF @RMID = 3  
  UPDATE SALES_UPLOAD SET WED = 1  
 IF @RMID = 4  
  UPDATE SALES_UPLOAD SET THU = 1  
 IF @RMID = 5  
  UPDATE SALES_UPLOAD SET FRI = 1  
 IF @RMID = 6  
  UPDATE SALES_UPLOAD SET SAT = 1  
 IF @RMID = 7  
  UPDATE SALES_UPLOAD SET SUN = 1  
 END  
 
   IF @PID = 18  
  BEGIN
	SELECT Rmid AS RMID,Rmname from Routemaster WHERE Rmid IN   
	(SELECT DISTINCT * FROM Dbo.Fn_ReturnPDARouteMaster())  
  END 
  
 IF @PID = 19   
 Begin      
	Select Distinct SMID from SALES_UPLOAD  
 End 
 
 IF @PID = 20   
 Begin      
 Select Distinct Setting from Tbl_PDAConfiguration Where Processname = 'ClearSalesMan'  
 End       
         
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A WHERE A.name='Cos2Mob_SalesManMaster')
CREATE TABLE Cos2Mob_SalesManMaster
(
	Slno					INT				IDENTITY(1,1) NOT NULL,
	DistCode				NVARCHAR(50),
	SrpId					INT,
	SrpCde					NVARCHAR(40),
	SrpNm					NVARCHAR(100),
	UploadFlag				NVARCHAR(1),
	LastUploadedDate		DATETIME
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ExportPDA_SalesMan' AND XTYPE='P')
DROP PROCEDURE Proc_ExportPDA_SalesMan
GO
CREATE PROCEDURE Proc_ExportPDA_SalesMan
AS
BEGIN
DECLARE @DistCode NVARCHAR(40)
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
SELECT @DistCode = LTRIM(RTRIM(DistributorCode)) FROM Distributor(NOLOCK)

	IF ISNULL(@DistCode,'') <>''
	BEGIN
		DELETE FROM Cos2Mob_SalesManMaster --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_SalesManMaster (DistCode,SrpId,SrpCde,SrpNm,UploadFlag,LastUploadedDate)
		SELECT DISTINCT @DistCode,A.SMId,SMCode,SMName,'N' AS UploadFlag,@LastUploadedDate As LastUploadedDate FROM SalesMan A (NOLOCK)
		INNER JOIN SalesManMarket B(NOLOCK) ON A.SMid = B.SMID
		WHERE Status=1
	END
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_SalesRepresentative' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_SalesRepresentative
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_SalesRepresentative' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_SalesRepresentative
GO
CREATE PROCEDURE PROC_ExportPDA_SalesRepresentative
AS
BEGIN
DECLARE @DistCode NVARCHAR(40)
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
SELECT @DistCode = LTRIM(RTRIM(DistributorCode)) FROM Distributor(NOLOCK)

	IF ISNULL(@DistCode,'') <>''
	BEGIN
		DELETE FROM Cos2Mob_SalesRepresentative --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_SalesRepresentative (DistCode,SrpId,SrpCde,SrpNm,UploadFlag,ImeiNo,SMPassword,LastUploadedDate)
		SELECT @DistCode,SMID,SMCode,SMName,'N' AS UploadFlag,'','',@LastUploadedDate As LastUploadedDate FROM SalesMan A (NOLOCK)
		WHERE EXISTS (SELECT DISTINCT SMId FROM Sales_upload B WHERE A.SMid = B.SMID) and Status=1
	

		UPDATE C SET ImeiNo=A.IMEINo FROM Cos2Mob_SalesRepresentative C INNER JOIN
		(SELECT SMId,UD.ColumnValue 'IMEINo' FROM UdcMaster UM 
		INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('IMEI No')
		INNER JOIN salesman R ON R.SMId=UD.MASTERRECORDID 
		WHERE UM.MasterId=4 )A ON C.SrpId=A.SMId

		UPDATE C SET SMPassword= LOWER(SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5',  A.Password)), 3, 32)) FROM Cos2Mob_SalesRepresentative C INNER JOIN
		(SELECT SMId,UD.ColumnValue 'Password' FROM UdcMaster UM 
		INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('Password')
		INNER JOIN salesman R ON R.SMId=UD.MASTERRECORDID 
		WHERE UM.MasterId=4 )A ON C.SrpId=A.SMId
	END
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_Market' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_Market
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Market' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_Market
GO
CREATE PROCEDURE PROC_ExportPDA_Market
AS
BEGIN
DECLARE @DistCode NVARCHAR(40)
SELECT @DistCode = LTRIM(RTRIM(DistributorCode)) from Distributor(NOLOCK)
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
	IF ISNULL(@DistCode,'')<>''
	BEGIN
		DELETE FROM Cos2Mob_Market --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_Market 
		(	
			DistCode,SrpCde,MktId,MktCde,MktNm,MktDist,Monday,Tuesday,
			Wednesday,Thursday,Friday,Saturday,Sunday,UploadFlag,LastUploadedDate
		)
		SELECT 
					@DistCode,SMCode,R.RMId,RmCode,RmName,RMDistance,RMMon,RMTue,
					RMWed,RMThu,RMFri,RMSat,RMSun,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate 
		FROM		RouteMaster R(NOLOCK)
		INNER JOIN	SalesmanMarket SM(NOLOCK) on SM.RMId=R.RMId	
		INNER JOIN	Salesman S(NOLOCK) on S.SMId=Sm.SMId	
		--CROSS JOIN	Distributor(NOLOCK)
		WHERE EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = R.Rmid ) AND R.RMstatus=1 
		and EXISTS (SELECT DISTINCT SMID FROM Sales_upload B(NOLOCK) WHERE B.SMID = S.SMID ) and Status=1
	END
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_Retailer' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_Retailer
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Retailer' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_Retailer
GO
CREATE PROCEDURE PROC_ExportPDA_Retailer
AS 
BEGIN
DECLARE @StartDate datetime
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode NVARCHAR(40)
SELECT @DistCode = LTRIM(RTRIM(DistributorCode)) FROM Distributor(NOLOCK)

SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 
	DELETE FROM Cos2Mob_Retailer --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_Retailer (DistCode,SrpCde,RtrId,mktid,RtrCode,RtrName,RtrAdd1,RtrPinNo,RtrPhoneNo,CtgName,CtgCode,CtgLevelName,Billedret,RtrValueClassid,UploadFlag,
	Longitude,Latitude,LastUploadedDate,RtrMobileNo)
	SELECT @DistCode,SMCode,R.RtrId,RM.RMId,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrPinNo,R.RtrPhoneNo,RC.CtgName,RC.CtgCode,RCL.CtgLevelName,0,RVM.RtrValueClassId,'N' AS UploadFlag,'','',
	@LastUploadedDate AS LastUploadedDate,ISNULL(RtrOffPhone2,'') AS RtrOffPhone2
	FROM Retailer R
	INNER JOIN RetailerValueClassMap RVM ON R.RtrId=RVM.RtrId
	INNER JOIN RetailerValueClass RV ON RVM.RtrValueClassId=RV.RtrClassId
	INNER JOIN RetailerCategory RC ON RV.CtgMainId=RC.CtgMainId
	INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId=RCL.CtgLevelId
	INNER JOIN RetailerMarket RM on RM.RtrId=R.RtrId 
	INNER JOIN SalesmanMarket SM on SM.RMId=RM.RMId
	INNER JOIN Salesman S on S.SMId=SM.SMId
	--CROSS JOIN Distributor
	where EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid )
	and R.RtrStatus=1 and 
	s.SMId IN (SELECT DISTINCT SMId FROM Sales_upload) and s.Status=1
	
	SELECT RtrId into #TempBilled FROM SalesInvoice  WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121)
	
	update E set Billedret=1 from  Cos2Mob_Retailer E inner join #TempBilled T on E.RtrId=T.RtrId
	
	UPDATE C SET Latitude=A.Latitude FROM Cos2Mob_Retailer C INNER JOIN
	(SELECT RTRID,UD.ColumnValue 'Latitude' FROM UdcMaster UM 
	INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('Latitude')
	INNER JOIN Retailer R ON R.RTRID=UD.MASTERRECORDID 
	WHERE UM.MasterId=2 )A ON C.RtrId=A.RtrId
	
	UPDATE C SET Longitude=A.Longitude FROM Cos2Mob_Retailer C INNER JOIN
	(SELECT RTRID,UD.ColumnValue 'Longitude' FROM UdcMaster UM 
	INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('Longitude')
	INNER JOIN Retailer R ON R.RTRID=UD.MASTERRECORDID 
	WHERE UM.MasterId=2 )A ON C.RtrId=A.RtrId		
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_ProductCategory' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_ProductCategory
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_ProductCategory' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_ProductCategory
GO
--EXEC PROC_ExportPDA_ProductCategory SM01
CREATE PROCEDURE PROC_ExportPDA_ProductCategory
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode NVARCHAR(40)
SELECT @DistCode = LTRIM(RTRIM(DistributorCode)) FROM Distributor(NOLOCK)

	DELETE FROM Cos2Mob_ProductCategory --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_ProductCategory (DistCode,SrpCde,CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId,UploadFlag,LastUploadedDate)
	SELECT @DistCode,'' smcode,CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate 
	FROM ProductCategoryLevel 
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_ProductCategoryValue' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_ProductCategoryValue
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_ProductCategoryValue' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_ProductCategoryValue
GO
--EXEC PROC_ExportPDA_ProductCategoryValue SM01
CREATE PROCEDURE PROC_ExportPDA_ProductCategoryValue
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
DECLARE @DistCode NVARCHAR(40)
SELECT @DistCode = LTRIM(RTRIM(DistributorCode)) FROM Distributor(NOLOCK)
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)

	DELETE FROM Cos2Mob_ProductCategoryValue --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_ProductCategoryValue (DistCode,SrpCde,PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,UploadFlag,LastUploadedDate)
	SELECT @DistCode,'' smcode,PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate 
	FROM ProductCategoryValue 
	--CROSS JOIN (SELECT DISTINCT TOP 1 smcode FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
	--CROSS JOIN Distributor
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_Product' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_Product
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Product' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_Product
GO
CREATE PROCEDURE PROC_ExportPDA_Product
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @FromDate DATETIME
DECLARE @ToDate  DATETIME
DECLARE @DistCode nVarchar(50)
DECLARE @Smcode Nvarchar(50)
CREATE TABLE #tempproduct(Prdid INT)
	EXEC Proc_GR_Build_PH
	
	SELECT @FromDate=dateadd(MM,-3,getdate())
	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)
	SELECT @DistCode=DistributorCode  from Distributor
	--SET @Smcode=(SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid)

	INSERT INTO #tempproduct
	SELECT DISTINCT PrdId FROM SalesInvoice SI inner join SalesInvoiceProduct SIP on SI.SalId=SIP.SalId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
	
	INSERT INTO #tempproduct	
	SELECT DISTINCT PrdId FROM PurchaseReceipt G inner join PurchaseReceiptProduct GP on G.PurRcptId=GP.PurRcptId where G.InvDate
	BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
	
	INSERT INTO #tempproduct	
	SELECT DISTINCT PrdId FROM stockledger where TransDate
	BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 


--> Starts Here CCRSTPAR0156 Promotional Items to be Blocked Exporting to Interdb
DECLARE @PrdCtgValLinkCode AS VARCHAR(1000)
SELECT  @PrdCtgValLinkCode = PrdCtgValLinkCode FROM ProductCategoryValue WHERE PrdCtgValCode = 'C00'

DELETE B FROM Product A(NOLOCK),#tempproduct B 
WHERE A.prdid = B.Prdid and 
A.PrdCtgValMainId IN 
(
	SELECT PrdCtgValMainId FROM ProductCategoryValue where PrdCtgValLinkCode like  @PrdCtgValLinkCode +'%'
)
--< Till Here



	DELETE FROM Cos2Mob_Product-- WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_Product (DistCode,SrpCde,PrdId,PrdName, PrdShrtNm,PrdCCode,SpmId,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,CmpId,PrdCtgValMainId,FocusBrand,
	                             FrqBilledPrd,CategoryID,CAtegoryCode,CategoryName,Brandid,BtrandCode,BrandName,UploadFlag,DefaultUomid,LastUploadedDate)
	SELECT DISTINCT @DistCode,'' SMCODE,P.PrdId,PrdName,PrdShrtName,PrdCCode,SpmId,PrdWgt,PrdUnitId,p.UomGroupId,TaxGroupId,PrdType,CmpId,PrdCtgValMainId,0,0,
	T.PriceSlot_Id,T.PriceSlot_Code,T.PriceSlot_Caption,T.Flavor_Id,T.Flavor_Code,T.Flavor_Caption,'N' AS UploadFlag,U.UomId,@LastUploadedDate AS LastUploadedDate
	FROM Product P INNER JOIN  TBL_GR_BUILD_PH T on T.PrdId=p.PrdId inner join #tempproduct tp on p.PrdId=tp.Prdid and t.PRDID=tp.Prdid
	INNER JOIN UOMGROUP U ON U.UomGroupId=P.UomGroupId AND BASEUOM='Y'
	--CROSS JOIN (SELECT DISTINCT TOP 1 SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid)S
	WHERE PrdStatus=1
	
	SELECT  DISTINCT A.PRDID,count(A.prdid)AS SOLD,C.PrdName,C.PrdCCode INTO #SRI
	FROM SalesInvoiceproduct A
	INNER JOIN SalesInvoice B ON a.SalId=B.SalId
	INNER JOIN Product C ON a.prdid=C.prdid
    WHERE b.SalInvDate BETWEEN dateadd(month, -3, getdate()) AND CONVERT(VARCHAR(10),GETDATE(),121)
	GROUP BY a.prdid,c.PrdName,C.PrdCCode 

	
    UPDATE Cos2Mob_Product SET FrqBilledPrd=1 WHERE prdid IN (SELECT TOP 10 prdid FROM  #SRI GROUP BY prdid,PrdName,SOLD ORDER BY SOLD DESC)
	
--> Starts Here CCRSTPAR0161 For Updating Product Allias Name
	UPDATE A SET A.PrdName = B.PrdAlliasName,A.PrdShrtNm = B.PrdAlliasName FROM Cos2Mob_Product A(NOLOCK) INNER JOIN ProductSFAAlliasName B(NOLOCK)
	ON A.PrdId = B.Prdid
--< Till Here	
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_Productbatch' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_Productbatch
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Productbatch' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_Productbatch
GO
CREATE PROCEDURE PROC_ExportPDA_Productbatch
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)	
	TRUNCATE TABLE Cos2Mob_Productbatch --WHERE UploadFlag='Y'
	
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
	--SET @Smcode=(SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid)
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

	--> Starts Here CCRSTPAR0156 Promotional Items to be Blocked Exporting to Interdb
DECLARE @PrdCtgValLinkCode AS VARCHAR(1000)
SELECT  @PrdCtgValLinkCode = PrdCtgValLinkCode FROM ProductCategoryValue WHERE PrdCtgValCode = 'C00'

DELETE B FROM Product A(NOLOCK),#TEMPProductbatch B 
WHERE A.prdid = B.Prdid and 
A.PrdCtgValMainId IN 
(
	SELECT PrdCtgValMainId FROM ProductCategoryValue where PrdCtgValLinkCode like  @PrdCtgValLinkCode +'%'
)
--< Till Here


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
										SellingPriceWtTax,TaxAmount,StockInHand,UploadFlag,LastUploadedDate)
	SELECT  @DistCode,'' SMCODE,A.PrdId,A.PrdBatId,DefaultPriceId,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,MRP.PrdBatDetailValue AS MRP,
			ListPrice.PrdBatDetailValue AS ListPrice,SellingRate.PrdBatDetailValue AS SellingRate,
			SUM(SellingRate.PrdBatDetailValue+((SellingRate.PrdBatDetailValue*PBT.TaxPercentage)/100)) SellingRateWithTax,
			(SellingRate.PrdBatDetailValue*PBT.TaxPercentage)/100 AS TaxAmount,ISNULL(sum(PBl.PrdBatLcnSih-PrdBatLcnRessih),0) AS StockOnHand,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate
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
			--CROSS JOIN (SELECT DISTINCT TOP 1 SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid)S
			GROUP BY A.PrdId,A.PrdBatId,DefaultPriceId,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,MRP.PrdBatDetailValue,
			ListPrice.PrdBatDetailValue,SellingRate.PrdBatDetailValue,PBT.TaxPercentage--,SMCode 
			
			SELECT DISTINCT p.PrdId,pbd.PrdBatDetailValue,SUM(PRDBATLCNSIH-PrdBatLcnRessih)stock into #TempStock FROM product P INNER JOIN productbatch pb on p.PrdId=pb.PrdId 
			INNER JOIN productbatchdetails pbd on pb.PrdBatId=pbd.PrdBatId AND pbd.DefaultPrice=1 
			INNER JOIN PRODUCTBATCHLOCATION PBL ON PBL.PRDID=P.PRDID AND PBL.PRDBATID=PB.PRDBATID AND PBL.PRDBATID=PBD.PrdBatId
			WHERE slno=1 AND PB.Status=1 GROUP BY p.PrdId,pbd.PrdBatDetailValue HAVING SUM(PRDBATLCNSIH-PrdBatLcnRessih)>0 ORDER BY P.PrdId
			
			UPDATE C SET StockInHand=STOCK FROM Cos2Mob_Productbatch C INNER JOIN #TempStock T ON C.PrdId=T.PrdId AND C.MRP=T.PrdBatDetailValue


-->Starts Here for CCRSTPAR0157 Selling Rate should be Displayed as sellingPricewtTax
UPDATE Cos2Mob_Productbatch SET SEllingPrice = SEllingPriceWtTax
--< Till Here
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_Bank' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_Bank
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Bank' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_Bank
GO
--EXEC PROC_ExportPDA_Bank SM1 
CREATE PROCEDURE PROC_ExportPDA_Bank
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)	
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor

		DELETE FROM Cos2Mob_Bank --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_Bank (DistCode,SrpCde,BnkId,BnkCode,BnkName,UploadFlag,LastUploadedDate)
		SELECT @DistCode,'' SMCODE,BnkId,BnkCode,BnkName,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate FROM Bank 
		--CROSS JOIN (SELECT DISTINCT TOP 1 SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
		--CROSS JOIN Distributor
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_BankBranch' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_BankBranch
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_BankBranch' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_BankBranch
GO
CREATE PROCEDURE PROC_ExportPDA_BankBranch
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)	
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor

		DELETE FROM Cos2Mob_BankBranch-- WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_BankBranch (DistCode,SrpCde,BnkId,BnkBrId,BnkBrCode,BnkBrName,BnkBrACNo,DistBank,CoaId,UploadFlag,LastUploadedDate)
		SELECT @DistCode,'' SMCODE,BnkId,BnkBrId,BnkBrCode,BnkBrName,BnkBrACNo,DistBank,CoaId,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate
		FROM BankBranch
		--CROSS JOIN (SELECT DISTINCT TOP 1 SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
		--CROSS JOIN Distributor(NOLOCK)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_PendingBills' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_PendingBills
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_PendingBills' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_PendingBills
GO
CREATE PROCEDURE PROC_ExportPDA_PendingBills
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)	
DECLARE @FromDate AS DATETIME
DECLARE @ToDate AS DATETIME
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor

	SELECT @FromDate=dateadd(MM,-3,getdate())
	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)
	
	DELETE FROM Cos2Mob_PendingBills --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_PendingBills (DistCode,SrpCde,Salid,SalInvNo,SalInvDte,RtrId,TotalInvoiceAmount,PaidAmount,BalanceAmount,UploadFlag,LastUploadedDate)
	SELECT @DistCode,SMCode,SalId,SalInvNo,SalInvDate,RtrId,SalNetAmt,SalPayAmt,(SalNetAmt-SalPayAmt) AS BalanceAmount,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate
	FROM SalesInvoice S INNER JOIN SalesMan SM ON S.SMID=SM.SMId --CROSS JOIN Distributor
	WHERE S.DlvSts >3 AND 
	EXISTS (SELECT DISTINCT SMId FROM Sales_upload B WHERE S.SMID = B.SMID AND S.RMID = B.RMID) AND
	EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = S.Rmid)
	and (SalNetAmt-SalPayAmt)>0
	AND SalInvDate  BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121)
	
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_CreditNote' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_CreditNote
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_CreditNote' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_CreditNote
GO
CREATE PROCEDURE PROC_ExportPDA_CreditNote
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor	
	
		DELETE FROM Cos2Mob_CreditNote --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_CreditNote (DistCode,SrpCde,CrNo,CrAmount,RtrId,CrAdjAmount,TranNo,Reasonid,UploadFlag,LastUploadedDate)
		SELECT @DistCode,s.SMCode,CrNoteNumber,Amount,C.RtrId,CrAdjAmount,PostedFrom,ReasonId,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate
		FROM CreditNoteRetailer C
		INNER JOIN RetailerMarket RM on C.RtrId=RM.RtrId
		INNER JOIN SalesmanMarket SM on SM.RMId=RM.RMId
		INNER JOIN Salesman S on S.SMId=SM.SMId
		--CROSS JOIN Distributor
		WHERE 
		EXISTS (SELECT DISTINCT SMId FROM Sales_upload B WHERE S.SMID = B.SMID AND RM.RMID = B.RMID) AND
		EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid)
		and (Amount-CrAdjAmount)>0 and C.Status=1
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_DebitNote' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_DebitNote
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_DebitNote' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_DebitNote
GO
CREATE PROCEDURE PROC_ExportPDA_DebitNote
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)	
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor

		DELETE FROM Cos2Mob_DebitNote --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_DebitNote (DistCode,SrpCde,DbNo,DbAmount,RtrId,DbAdjAmount,TransNo,Reasonid,UploadFlag,LastUploadedDate)
		SELECT @DistCode,S.SMCODE,DbNoteNumber,Amount,D.RtrId,DbAdjAmount,PostedFrom,ReasonId,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate
	    FROM DebitNoteRetailer D
		INNER JOIN RetailerMarket RM on D.RtrId=RM.RtrId
		INNER JOIN SalesmanMarket SM on SM.RMId=RM.RMId
		INNER JOIN Salesman S on S.SMId=SM.SMId
	    --CROSS JOIN Distributor 		
	    WHERE 
	    EXISTS (SELECT DISTINCT SMId FROM Sales_upload B WHERE S.SMID = B.SMID AND RM.RMID = B.RMID) AND
	    EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid)
	     and (Amount-DbAdjAmount)>0 and D.Status=1
	     
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_RetailerCategoryLevel' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_RetailerCategoryLevel
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_RetailerCategoryLevel' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_RetailerCategoryLevel
GO
--EXEC PROC_ExportPDA_RetailerCategoryLevel SM01
CREATE PROCEDURE PROC_ExportPDA_RetailerCategoryLevel
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor

		DELETE FROM Cos2Mob_RetailerCategoryLevel --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_RetailerCategoryLevel (DistCode,CtgLevelId,CtgLevelName,LevelName,UploadFlag,LastUploadedDate)
		SELECT @DistCode,CtgLevelId,CtgLevelName,LevelName,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate 
		FROM RetailerCategoryLevel (NOLOCK)
		--CROSS JOIN Distributor
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_RetailerCategory' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_RetailerCategory
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_RetailerCategory' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_RetailerCategory
GO
--EXEC PROC_ExportPDA_RetailerCategory SM01
CREATE PROCEDURE PROC_ExportPDA_RetailerCategory
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor

		DELETE FROM Cos2Mob_RetailerCategory --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_RetailerCategory (DistCode,CtgMainId,CtgLinkId,CtgLevelId,CtgLinkCode,CtgCode,CtgName,UploadFlag,LastUploadedDate)
		SELECT @DistCode,CtgMainId,CtgLinkId,CtgLevelId,CtgLinkCode,CtgCode,CtgName,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate 
		FROM RetailerCategory (NOLOCK)
		--CROSS JOIN Distributor
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_RetailerValueClass' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_RetailerValueClass
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_RetailerValueClass' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_RetailerValueClass
GO
--EXEC PROC_ExportPDA_RetailerValueClass SM01
CREATE PROCEDURE PROC_ExportPDA_RetailerValueClass
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor (NOLOCK)

		DELETE FROM Cos2Mob_RetailerValueClass --WHERE UploadFlag='Y'
		INSERT INTO Cos2Mob_RetailerValueClass (DistCode,RtrClassId,CmpId,CtgMainId,ValueClassCode,ValueClassName,Turnover,UploadFlag,LastUploadedDate)
		SELECT @DistCode,RtrClassId,CmpId,CtgMainId,ValueClassCode,ValueClassName,Turnover,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate  
		FROM RetailerValueClass (NOLOCK)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_SchemeNarration' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_SchemeNarration
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ExportPDA_SchemeNarration' AND XTYPE='P')
DROP PROCEDURE Proc_ExportPDA_SchemeNarration
GO
--Exec Proc_ExportPDA_SchemeNarration 
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
DECLARE @FromQty as int
DECLARE @ToQty AS INT
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor (NOLOCK)
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
			FOR SELECT DISTINCT ss.SlabId,PurQty,DiscPer,FlatAmt,SF.FreeQty,CASE ForEveryUomId WHEN 0 THEN UOMID ELSE ForEveryUomId END,FromQty,ToQty
			FROM SchemeSlabs SS LEFT  OUTER  JOIN SchemeSlabFrePrds SF
				ON SF.SchId = SS.SchId AND SF.SlabId = SS.SlabId WHERE SS.SchId=@Schid
			SET @Count=0
			OPEN Cur_SchemeNarration
			FETCH next FROM Cur_SchemeNarration INTO @Slabid,@EveryQty,@DisCper,@Flatamt,@FreeQty,@ForEveryUomId,@FromQty,@ToQty
			WHILE @@FETCH_status=0
			BEGIN 
		
			IF @Count=0
				BEGIN 
				   IF @EveryQty =0.00
					   BEGIN
							SET @Str='Scheme Applicable-For Purchase Between '+ Cast(@FromQty AS varchar(15)) + 'To ' + Cast(@ToQty AS varchar(15)) +
							CASE @schtype when 1 then (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
								WHEN 2 THEN ' RS'
								WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
							 END
						print @Str
						END
				   ELSE
					   BEGIN
							SET @Str='Scheme Applicable-For Purchase of Every  '+ Cast(@EveryQty AS varchar(15)) + 
							CASE @schtype when 1 then (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
								WHEN 2 THEN ' RS'
								WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
								END				
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

				   IF @EveryQty=0.00 
					   BEGIN
							SET @Str=@Str + 'And For Purchase Between '+ Cast(@FromQty AS varchar(15)) + 'To ' + Cast(@ToQty AS varchar(15)) +
							CASE @schtype when 1 then (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
								WHEN 2 THEN ' RS'
								WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
							 END
						END
				   ELSE
					   BEGIN
					SET @Str=@Str +' And For Purchase of Every  '+ Cast(@EveryQty AS varchar(15)) + 
						CASE @schtype WHEN 1 THEN (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
									  WHEN 2 THEN ' RS'
									  WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
							END			   
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
			SET @Count=1
			FETCH next FROM Cur_SchemeNarration INTO @Slabid,@EveryQty,@DisCper,@Flatamt,@FreeQty,@ForEveryUomId,@FromQty,@ToQty
			END 
			CLOSE Cur_SchemeNarration
			DEALLOCATE Cur_SchemeNarration
	
			INSERT INTO Cos2Mob_SchemeNarration (DistCode,SrpCde,Channel,SubType,CmpSchCode,Schdesc,Narration,UploadFlag,ChannelCode,RtrClassId,LastUploadedDate)
				SELECT @DistCode,''SMCODE,RC.CtgName,RVC.ValueClassName,CmpSchCode,SchDsc, cast(@Str AS varchar(500)),'N' AS UploadFlag,RC.CtgCode,RVC.RtrClassId,@LastUploadedDate AS LastUploadedDate 
				FROM SchemeMaster S INNER JOIN SchemeRetAttr SR ON S.SchId=SR.SchId
				INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId=CASE SR.AttrId WHEN 0 THEN RVC.RtrClassId ELSE SR.AttrId END 
				AND SR.AttrType=6
				INNER JOIN RetailerCategory RC ON RC.CtgMainId=RVC.CtgMainId  
				--CROSS JOIN (SELECT DISTINCT TOP 1 SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) SM
				--CROSS JOIN Distributor
				WHERE   S.SchId=@Schid
		
		FETCH next FROM Cur_SchemeMater INTO @Schid,@schtype
		END 
		CLOSE Cur_SchemeMater
		DEALLOCATE Cur_SchemeMater
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_SchemeProductDetails' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_SchemeProductDetails
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_SchemeProductDetails' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_SchemeProductDetails
GO
--Exec PROC_ExportPDA_SchemeProductDetails 'DS01'
CREATE PROCEDURE PROC_ExportPDA_SchemeProductDetails
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode AS VARCHAR(100)
SELECT @DistCode=DistributorCode  from Distributor (NOLOCK)

	DELETE FROM Cos2Mob_SchemeProductDetails -- Where UploadFlag='Y'
	
	INSERT INTO Cos2Mob_SchemeProductDetails(DistCode,SrpCde,CmpschCode,SchDsc,Prdcode,Prdname,UploadFlag,LastUploadedDate)
	SELECT @DistCode,'' SMCODE,CmpSchCode,SchDsc,PrdCCode,PrdName,'N' as UploadFlag,@LastUploadedDate AS LastUploadedDate  
	FROM 
		(
		SELECT CmpSchCode,SchDsc,PrdCCode,PrdName FROM SchemeMaster SM 
			INNER JOIN SchemeProducts SP ON SM.SchId=SP.SchId 
			INNER JOIN ProductCategoryValue PC ON PC.PrdCtgValMainId=SP.PrdCtgValMainId
			INNER JOIN TBL_GR_BUILD_PH T ON PC.PrdCtgValMainId=CASE PC.CmpPrdCtgId WHEN 2 THEN Category_Id
																	WHEN 3 THEN Brand_Id
																	WHEN 4 THEN PriceSlot_Id
																	WHEN 5 THEN Flavor_Id									
																	END 			
			INNER JOIN Product P ON P.PrdId=T.PrdId  
		WHERE SchStatus=1  AND CONVERT(varchar(10),getdate(),121)  BETWEEN SchValidFrom AND SchValidtill	
	  UNION ALL
  		SELECT CmpSchCode,SchDsc,PrdCCode,PrdName FROM SchemeMaster SM 
			INNER JOIN SchemeProducts SP ON SM.SchId=SP.SchId 
			INNER JOIN Product P ON P.PrdId=SP.PrdId
		WHERE SchStatus=1 AND CONVERT(varchar(10),getdate(),121)  BETWEEN SchValidFrom AND SchValidtill
        )A
		--CROSS JOIN (SELECT DISTINCT TOP 1 SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
		--CROSS JOIN Distributor
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_ReasonMaster' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_ReasonMaster
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_ReasonMaster' AND XTYPE='P')
DROP PROCEDURE PROC_ExportPDA_ReasonMaster
GO
--Exec PROC_ExportPDA_ReasonMaster 'KS'
CREATE PROCEDURE PROC_ExportPDA_ReasonMaster
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @DistCode AS VARCHAR(100)
select @DistCode=DistributorCode from Distributor

	DELETE FROM Cos2Mob_ReasonMaster --Where UploadFlag='Y'
	INSERT INTO Cos2Mob_ReasonMaster (DistCode,SrpCde,ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
										DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,
										StkTransferScreen,BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,
										NonBilled,UploadFlag,LastUploadedDate)
	SELECT @DistCode,'' SMCODE,ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
			DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,
			StkTransferScreen,BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,1 as NonBilled, 'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate  
			FROM ReasonMaster (NOLOCK)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_SalesmanDashBoard' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_SalesmanDashBoard
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ExportPDA_SalesmanDashBoard' AND XTYPE='P')
DROP PROCEDURE Proc_ExportPDA_SalesmanDashBoard
GO
--Exec Proc_ExportPDA_SalesmanDashBoard
CREATE PROCEDURE Proc_ExportPDA_SalesmanDashBoard
AS
BEGIN
DECLARE @StartDate datetime
Declare @DistCode nvarchar(50) 
select @DistCode=DistributorCode from Distributor
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DELETE FROM Cos2Mob_SalesmanDashBoard  WHERE UploadFlag='Y'

SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 

INSERT INTO Cos2Mob_SalesmanDashBoard(DistCode,Smcode,Smid,Rmid,RmCode,MTDSalesValue,MTDLPC,MTDSalesPerProdCall,MTDBilledPrdCount,MTDProductiveCallPer,NewOutletsEnrolled,UploadFlag,LastUploadedDate)
SELECT @DistCode,S.SMCode,S.SMId,R.RMId,R.RMCode,SUM(SI.SalNetAmt),0,0,0,0,0,'N',@LastUploadedDate AS LastUploadedDate   
FROM SalesInvoice SI
INNER JOIN Sales_upload SU on SU.Smid=SI.SMId and SU.RMid=Si.RMId
INNER JOIN Salesman S on S.SMId=SI.SMId
INNER JOIN RouteMaster R on R.RMId=SI.RMId
WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5) AND 	
EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid )
GROUP BY S.SMCode,S.SMId,R.RMId,R.RMCode

SELECT SMid,Rmid,SUM(prdCnt)prdCnt,SUM(SalCnt)SalCnt Into #TempPrdCnt from (
SELECT salinvno,SI.SMId,SI.RMId,COUNT(distinct Prdid)PrdCnt,count(Distinct Salinvno)SalCnt from SalesInvoice SI
INNER JOIN SalesInvoiceProduct SIP on SI.SalId =SIP.SalId
INNER JOIN Sales_upload SU on SU.Smid=SI.SMId and SU.RMid=Si.RMId
WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	AND
EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid )
group by salinvno,SI.SMId,SI.RMId)A
GROUP BY SMid,Rmid

 UPDATE E SET MTDLPC=(prdCnt/SalCnt),MTDSalesPerProdCall=(MTDSalesValue/SalCnt),MTDBilledPrdCount=prdCnt
 FROM Cos2Mob_SalesmanDashBoard E INNER JOIN #TempPrdCnt T on E.Smid=T.SMId and E.Rmid=T.RMId
 
SELECT B.SMId,B.RMId,(RtrCnt/BillRtrCnt)MTDPC into #TempMonthTDPC FROM 
(SELECT SM.SMId,SM.RMId,COUNT(rtrid)RtrCnt FROM SalesmanMarket SM INNER JOIN RetailerMarket RM on SM.RMId=RM.RMId
INNER JOIN Sales_upload SU ON SU.Smid=SM.SMId AND SU.RMid=SM.RMId GROUP BY SM.SMId,SM.RMId)A
INNER JOIN
(SELECT SI.SMId,SI.RMId,COUNT(DISTINCT RtrId)BillRtrCnt FROM SalesInvoice SI 
INNER JOIN Sales_upload SU ON SU.Smid=SI.SMId AND SU.RMid=SI.RMId
WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	
AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid )
group by SI.SMId,SI.RMId)B
	on A.SMid=B.smid and A.rmid=B.rmid
	
 UPDATE E SET MTDProductiveCallPer=MTDPC
 FROM Cos2Mob_SalesmanDashBoard E INNER JOIN #TempMonthTDPC T on E.Smid=T.SMId and E.Rmid=T.RMId
SELECT D.SmId,D.Rmid,Count(DISTINCT A.RtrId) AS NewCnt into #TempNewRet FROM Retailer A    
			 INNER JOIN RetailerMarket B ON A.RtrId=B.RtrId    
			 INNER JOIN SalesmanMarket C ON B.RMID=C.RMID    
			 INNER JOIN Sales_upload  D ON C.SMID=D.SMID  and D.Rmid=C.RMId  
			 INNER JOIN SalesInvoice E ON A.RtrId=E.RtrId AND E.SMId=D.SmId and E.SMId=D.SMid and e.RMId=C.RMId    
		 WHERE E.Dlvsts IN(4,5) AND
		 EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = E.Rmid )
			 AND A.RtrRegDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121)  AND A.RtrStatus=1 and DlvSts in(4,5)	
			 Group by D.SmId,D.Rmid
			 
 UPDATE E SET NewOutletsEnrolled=NewCnt
 FROM Cos2Mob_SalesmanDashBoard E INNER JOIN #TempNewRet T on E.Smid=T.SMId and E.Rmid=T.RMId			 
 
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_RetailerDashBoard' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_RetailerDashBoard
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ExportPDA_RetailerDashBoard' AND XTYPE='P')
DROP PROCEDURE Proc_ExportPDA_RetailerDashBoard
GO
--Exec Proc_ExportPDA_RetailerDashBoard
CREATE PROCEDURE Proc_ExportPDA_RetailerDashBoard
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
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
	INSERT INTO Cos2Mob_RetailerDashBoard(DistCode,Smcode,Rmid,RtrCode,Rtrid,L3MavgSales,MTDSaleValue,L3MAvgBills,NoOfBills,LPPC,LastVistDate,TotalCRBills,TotalCRValue,L3MPrdcallPer,SalesPerProductCall,QTDSalesValue,QTDSalesTarget,UploadFlag,LastUploadedDate)
	SELECT @DistCode,SM.SMCode ,SI.RMId,R.RtrCode,R.RtrId,0,sum(SI.SalNetAmt)SalesValue,0,Count(salinvno)SalCnt,0,Max(salinvdate),0,0,0,0,0,0,'N',@LastUploadedDate AS LastUploadedDate  
	FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	INNER JOIN Retailer R on R.RtrId =SI.RtrId
	inner join salesman SM on SM.SMId=S.SMID and SM.SMId=SI.SMId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	
	AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid )
	GROUP BY smcode,SI.RMId,R.RtrCode,R.RtrId
	
	SELECT smcode,SI.SMId,SI.RMId,SI.RtrId,sum(SI.SalNetAmt)SalesValue,Count(salinvno)SalCnt Into #Temp3monAvgsales FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	inner join salesman SM on SM.SMId=S.SMID and SM.SMId=SI.SMId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts in(4,5)	
	AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid )
	GROUP BY SI.SMId,SI.RMId,SI.RtrId,smcode
	
	SELECT SMCode,SMid,Rmid,RtrId,SUM(prdCnt)prdCnt,SUM(SalCnt)SalCnt Into #TempPrdCnt from (
	SELECT SM.SMCode,salinvno,SI.SMId,SI.RMId,RtrId,COUNT(distinct Prdid)PrdCnt,count(Distinct Salinvno)SalCnt from SalesInvoice SI
	INNER JOIN SalesInvoiceProduct SIP on SI.SalId =SIP.SalId
	INNER JOIN Sales_upload SU on SU.Smid=SI.SMId and SU.RMid=Si.RMId
	inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=SU.SMID
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts in(4,5) 
	AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid )
	group by salinvno,SI.SMId,SI.RMId,RtrId,SM.SMCode
	)A
	GROUP BY SMid,Rmid,RtrId,SMCode
	SELECT smcode,SI.SMId,SI.RMId,SI.RtrId,sum(SI.SalNetAmt)SalesValue,Count(salinvno)SalCnt Into #TempCreditbills FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=S.SMID
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts in(4,5) 
	AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid )
	GROUP BY SI.SMId,SI.RMId,SI.RtrId,smcode
	
	SELECT A.RTRID,CAST(SUM(T.COUNTDAYS*RtrCnt)/CAST(SUM(SALCNT) AS NUMERIC(18,6))*100 AS NUMERIC(18,2)) TOTRTRCNT  into #TempproductCallper  FROM (
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Monday' TOTDAY FROM RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId 
	INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId where RMMon=1 
	AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid) group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Tuesday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId 
	where RMTue=1 AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid) group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Wednesday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId 
	where RMWed=1 AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid) group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Thursday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId 
	where RMThu=1 AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid) group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Friday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId 
	where RMFri=1 AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid) group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Saturday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId 
	where RMSat=1 AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid)  group by RM.RTRID
	UNION
	SELECT RM.RTRID,count(RtrId)RtrCnt,'Sunday'TOTDAY from RouteMaster R 
	inner join RetailerMarket RM on R.RMId=RM.RMId inner join Sales_upload S on S.Rmid=RM.RMId INNER JOIN SalesmanMarket SM ON SM.SMId=S.SMid AND SM.RMId=S.Rmid AND SM.RMId=RM.RMId 
	where RMSun=1 AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = RM.Rmid)  group by RM.RTRID)A
	INNER JOIN TOTALDAYSCOUNT T ON A.TOTDAY=T.NAMEOFDAY
	INNER JOIN (SELECT SI.RTRID,COUNT(SalId)SALCNT FROM SalesInvoice SI INNER JOIN Retailer R ON SI.RtrId=R.RtrId
	INNER JOIN  RetailerMarket RM ON RM.RMId=SI.RMId AND RM.RtrId=SI.RtrId
	INNER JOIN SalesmanMarket SM ON SM.SMId=SI.SMId AND SM.RMId=SI.RMId AND SM.RMId=RM.RMId
	INNER JOIN Dbo.Fn_ReturnPDARouteMaster () SU ON SU.Rmid=SI.RMId 
	GROUP BY SI.RTRID)C ON C.RTRID=A.RTRID 
	GROUP BY A.RTRID
	
	SELECT sm.SMCode,SI.SMId as SMId,SI.RMId as RMId,SI.RtrId,sum(sip.PrdNetAmount)SalesValue INTO #TempQuarterSales
	FROM SalesInvoice SI 
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	INNER JOIN SalesInvoiceProduct SIP on SI.SalId=sip.SalId
    inner join Salesman SM on SM.SMId=SI.SMId and SM.SMId=s.SMID
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@JcmStd,121) AND CONVERT(VARCHAR(10),@JcmEdt,121) and DlvSts in(4,5)
	AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid) 	
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
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_OrderBookingDashBoard' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_OrderBookingDashBoard
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ExportPDA_OrderBookingDashBoard' AND XTYPE='P')
DROP PROCEDURE Proc_ExportPDA_OrderBookingDashBoard
GO
--Exec Proc_ExportPDA_OrderBookingDashBoard
CREATE PROCEDURE Proc_ExportPDA_OrderBookingDashBoard
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @StartDate   datetime 
Declare @DistCode nvarchar(50) 
 DELETE from Cos2Mob_OrderBookingDashBoard
 SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 
 SELECT @DistCode=DistributorCode from Distributor
	
 INSERT INTO Cos2Mob_OrderBookingDashBoard(DistCode,Smcode,Rmid,RtRid,OrderDate,OrderValue,NumOfLines,UploadFlag,LastUploadedDate)
 select @DistCode,SM.SMCode,SI.RMId,RtrId,SalInvDate,SalNetAmt,COUNT(distinct Prdid),'N',@LastUploadedDate AS LastUploadedDate
 from SalesInvoice SI (NOLOCK)
 INNER JOIN SalesInvoiceProduct SIP(NOLOCK) on si.SalId=sip.SalId
 INNER JOIN Sales_upload SU(NOLOCK) on SU.Smid=SI.SMId and SU.RMid=Si.RMId
 inner join Salesman SM(NOLOCK) on SM.SMId=SI.SMId and SM.SMId=SU.SMID
 WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	
 AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid) 
 GROUP BY SMCode,SI.RMId,RtrId,SalInvDate,SalNetAmt
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_OrderProductDashBoard' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_OrderProductDashBoard
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ExportPDA_OrderProductDashBoard' AND XTYPE='P')
DROP PROCEDURE Proc_ExportPDA_OrderProductDashBoard
GO
--Exec Proc_ExportPDA_OrderProductDashBoard
CREATE PROCEDURE Proc_ExportPDA_OrderProductDashBoard
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
DECLARE @StartDate   datetime 
DECLARE @3MStartDate datetime
DECLARE @3MEndDate   datetime
Declare @DistCode nvarchar(50) 
DELETE from Cos2Mob_OrderProductDashBoard
 SELECT @StartDate =CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(GETDATE())-1),GETDATE()),121) 
 SELECT @3MStartDate= CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(DATEADD(MM,-3,getdate()))-1),DATEADD(MM,-3,getdate())),101) 
 SELECT @3MEndDate=DATEADD(dd, -DAY(DATEADD(m,1,getdate())), DATEADD(m,0,getdate()))
 SELECT @DistCode=DistributorCode from Distributor
	 INSERT INTO Cos2Mob_OrderProductDashBoard(DistCode,Smcode,Rmid,RtRid,Prdid,Prdccode,MTDSalesQty,MTDSalesValue,L3MAvgSalQty,L3MAvgSalValue,L3MAvgQtyPerBill,UploadFlag,LastUploadedDate)
	 SELECT @DistCode,sm.SMCode,SI.RMId,RtrId,sip.PrdId,PrdCCode,sum(sip.BaseQty),sum(sip.PrdNetAmount),0,0,0,'N',@LastUploadedDate AS LastUploadedDate 
	 from SalesInvoice SI (NOLOCK)
	 INNER JOIN SalesInvoiceProduct SIP(NOLOCK) on si.SalId=sip.SalId
	 INNER JOIN Sales_upload SU(NOLOCK) on SU.Smid=SI.SMId and SU.RMid=Si.RMId
	 INNER JOIN Product P(NOLOCK) on P.PrdId=SIP.PrdId
     inner join Salesman SM(NOLOCK) on SM.SMId=SI.SMId and SM.SMId=SU.SMID
	 WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate,121) AND CONVERT(VARCHAR(10),GETDATE(),121) and DlvSts in(4,5)	
	 AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid) 
	 GROUP BY  sm.SMCode,SI.RMId,RtrId,sip.PrdId,PrdCCode
	 
	SELECT sm.smcode,SI.SMId,SI.RMId,SI.RtrId,sum(SIP.PrdNetAmount)SalesValue,SUM(SIP.BaseQty)BaseQty,COUNT(DISTINCT SI.SalId)SALCNT Into #TempAvgBills FROM SalesInvoice SI (NOLOCK)
	INNER JOIN Sales_upload S on S.SMid=SI.SMId and S.Rmid=SI.RMId
	INNER JOIN SalesInvoiceProduct SIP(NOLOCK) on SI.SalId=sip.SalId
    inner join Salesman SM (NOLOCK) on SM.SMId=SI.SMId and SM.SMId=s.SMID
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts=4	
	AND EXISTS (SELECT DISTINCT RMID  FROM  Dbo.Fn_ReturnPDARouteMaster () A WHERE A.Rmid = SI.Rmid) 
	GROUP BY SI.SMId,SI.RMId,SI.RtrId,sm.smcode
	
	UPDATE E SET L3MAvgSalQty=(BaseQty/3) ,L3MAvgSalValue=(SalesValue/3),L3MAvgQtyPerBill=(BaseQty/SALCNT)   FROM  Cos2Mob_OrderProductDashBoard E 
	INNER JOIN #TempAvgBills T on E.Smcode=T.SMCode and E.Rmid=T.RMId and E.Rtrid=T.RtrId	
	
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_RetailerProductDashBoard' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_RetailerProductDashBoard
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ExportPDA_RetailerProductDashBoard' AND XTYPE='P')
DROP PROCEDURE Proc_ExportPDA_RetailerProductDashBoard
GO
--Exec Proc_ExportPDA_RetailerProductDashBoard
CREATE PROCEDURE Proc_ExportPDA_RetailerProductDashBoard
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
Declare @DistCode nvarchar(50) 
DECLARE @3MStartDate datetime
DECLARE @3MEndDate   datetime
 SELECT @3MStartDate= CONVERT(VARCHAR(25),DATEADD (dd,-(DAY(DATEADD(MM,-3,getdate()))-1),DATEADD(MM,-3,getdate())),101) 
 SELECT @3MEndDate=DATEADD(dd, -DAY(DATEADD(m,1,getdate())), DATEADD(m,0,getdate()))
 SELECT @DistCode=DistributorCode from Distributor
	DELETE FROM Cos2Mob_RetailerProductDashBoard
	
	INSERT INTO Cos2Mob_RetailerProductDashBoard(DistCode,SrpCde,Rmid,Rtrid,PrdCcode,Billed,UploadFlag,LastUploadedDate)
	SELECT @DistCode,Cos2Mob_Retailer.SrpCde,MktId,RtrId,PrdCCode,'No','N',@LastUploadedDate AS LastUploadedDate  
	FROM Cos2Mob_Retailer CROSS JOIN Cos2Mob_Product
	
	SELECT RtrId,PrdCCode into #BilledRetailer FROM salesinvoice SI INNER JOIN SalesInvoiceProduct SIP on SI.SalId=SIP.SalId 
	INNER JOIN Product P  on P.PrdId=SIP.PrdId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@3MStartDate,121) AND CONVERT(VARCHAR(10),@3MEndDate,121) and DlvSts in(4,5)	
	
	UPDATE E SET billed='Yes' FROM Cos2Mob_RetailerProductDashBoard E INNER JOIN
	#BilledRetailer B on E.rtrid=B.rtrid AND E.prdccode=B.prdccode
	DELETE FROM Cos2Mob_RetailerProductDashBoard WHERE billed='No'
	 
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_MarketIntelligenceHD' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_MarketIntelligenceHD
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_PDA_MarketIntelligencehd' AND XTYPE='P')
DROP PROCEDURE Proc_Export_PDA_MarketIntelligencehd
GO
CREATE PROCEDURE Proc_Export_PDA_MarketIntelligencehd
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
Declare @DistCode nvarchar(50) 
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
SELECT @DistCode=DistributorCode from Distributor

		TRUNCATE TABLE Cos2Mob_MarketIntelligenceHD
		INSERT INTO Cos2Mob_MarketIntelligenceHD (DistCode,SRPCode,QuestionID,QuestionType,Question,ChannelCode,FromDate,ToDate,QuestionSetID,UploadFlag,LastUploadedDate)
		SELECT DISTINCT @DistCode,'' SMCode,QuestionID,QuestionType,Question,ChannelCode,FromDate,ToDate,QuestionSetID,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate
		FROM MarketIntelligenceHD C (NOLOCK) 
		--CROSS JOIN (SELECT DISTINCT TOP 1 SMCode FROM SALES_UPLOAD A (NOLOCK) INNER JOIN Salesman S (NOLOCK) ON A.SMID=S.SMId)S
		--CROSS JOIN Distributor (NOLOCK)
		WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN CONVERT(NVARCHAR(10),FromDate,121) AND CONVERT(NVARCHAR(10),ToDate,121)     
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_MarketIntelligenceDT' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_MarketIntelligenceDT
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_PDA_MarketIntelligencedt' AND XTYPE='P')
DROP PROCEDURE Proc_Export_PDA_MarketIntelligencedt
GO
CREATE PROCEDURE Proc_Export_PDA_MarketIntelligencedt
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
Declare @DistCode nvarchar(50) 
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
SELECT @DistCode=DistributorCode from Distributor

        TRUNCATE TABLE Cos2Mob_MarketIntelligenceDt 
        INSERT INTO Cos2Mob_MarketIntelligenceDt (DistCode,SRPCode,QuestionID,Answer,UploadFlag,LastUploadedDate)
		SELECT DISTINCT @DistCode,'' SMCode,B.QuestionID,Answer,'N' AS UploadFlag,@LastUploadedDate AS LastUploadedDate
		FROM MarketIntelligenceHD A (NOLOCK) INNER JOIN MarketIntelligenceDt B (NOLOCK) ON A.QuestionID = B.QuestionID
		--CROSS JOIN (SELECT DISTINCT TOP 1 SMCode FROM SALES_UPLOAD A (NOLOCK) INNER JOIN Salesman S (NOLOCK) ON A.SMID=S.SMId)S
		--CROSS JOIN Distributor (NOLOCK)
		WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN CONVERT(NVARCHAR(10),FromDate,121) AND CONVERT(NVARCHAR(10),ToDate,121)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='SFA_RetailerCategory' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE SFA_RetailerCategory
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_SFA_RetailerCategory' AND XTYPE='P')
DROP PROCEDURE Proc_SFA_RetailerCategory
GO
--EXEC Proc_SFA_RetailerCategory
--SELECT * FROM SFA_RetailerCategory
CREATE PROCEDURE Proc_SFA_RetailerCategory
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
Declare @DistCode nvarchar(50) 
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
SELECT @DistCode=DistributorCode from Distributor

		DELETE PRK FROM SFA_RetailerCategory PRK (NOLOCK)
		
		INSERT INTO SFA_RetailerCategory (DistCode,RetCatId,ChannelCode,ChannelName,SubChannelCode,SubChannelName,GroupCode,GroupName,ClassCode,
										  ClassName,UploadFlag,LastUploadedDate)
		SELECT DISTINCT @DistCode,V.RtrClassId,
		C2.CtgCode [Channel Code],C2.CtgName [Channel Name] ,
		'' [Sub Channel Code],'' [Sub Channel Name],
		C1.CtgCode [Category Code],C1.CtgName [Category Name],
		V.ValueClassCode,V.ValueClassName,'N'	 UploadFlag,@LastUploadedDate AS LastUploadedDate	
		FROM 
		RetailerValueClass V (NOLOCK) 
		INNER JOIN (Select B.CtgLinkId,B.CtgMainId,B.CtgCode,B.CtgName from Cos2Mob_RetailerCategoryLevel A (NOLOCK) INNER JOIN Cos2Mob_RetailerCategory B (NOLOCK) ON A.CtgLevelId=B.CtgLevelId Where A.CtgLevelId=2) C1
		ON C1.CtgMainId=V.CtgMainId
		INNER JOIN (Select B.CtgLinkId,B.CtgMainId,B.CtgCode,B.CtgName from Cos2Mob_RetailerCategoryLevel A (NOLOCK) INNER JOIN Cos2Mob_RetailerCategory B (NOLOCK) ON A.CtgLevelId=B.CtgLevelId Where A.CtgLevelId=1) C2
		ON C1.CtgLinkId=C2.CtgMainId
		--CROSS JOIN Distributor
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSColumns B on A.Id = B.Id AND A.name='Cos2Mob_UomMaster' AND B.name='LastUploadedDate')
BEGIN
	ALTER TABLE Cos2Mob_UomMaster
	ADD LastUploadedDate DATETIME NOT NULL DEFAULT (GETDATE())
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_PDA_UomMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Export_PDA_UomMaster
GO
--EXEC Proc_Export_PDA_UomMaster SM1 
CREATE PROCEDURE Proc_Export_PDA_UomMaster
AS
BEGIN
DECLARE @LastUploadedDate DATETIME	
SET  @LastUploadedDate = CONVERT(VARCHAR(25),GETDATE(),121)
	DECLARE @Discode as varchar(50)
	SELECT @Discode=distributorcode FROM distributor
	
		DELETE FROM Cos2Mob_UomMaster 
		INSERT INTO Cos2Mob_UomMaster (Distcode,SrpCde,UomGroupId,UomGroupCode,UomGroupDescription,UomId,UomCode,
										UomDescription,BaseUom,ConversionFactor,UploadFlag,LastUploadedDate)
										
		SELECT @Discode,'' SMCODE,UomGroupId,UomGroupCode,UomGroupDescription,UG.UomId,UomCode,
			   UomDescription,BaseUom,ConversionFactor,'N' UploadFlag,@LastUploadedDate AS LastUploadedDate 
	    FROM UOMGROUP UG INNER JOIN UOMMASTER UM ON UG.UOMID=UM.UOMID
		--CROSS JOIN (SELECT DISTINCT TOP 1 SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='PROC_IMPORT_PRODUCTPDA_ORDERBOOKING' AND xtype='P')
DROP PROCEDURE PROC_IMPORT_PRODUCTPDA_ORDERBOOKING
GO
/*
	BEGIN TRANSACTION
	exec PROC_IMPORT_PRODUCTPDA_ORDERBOOKING '01'
	SELECT * FROM PDALOG
	SELECT * FROM ORDERBOOKING
	SELECT * FROM ORDERBOOKINGPRODUCTS
	ROLLBACK TRANSACTION
*/
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
DECLARE @OrdKeyNo AS VARCHAR(50)      
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
	EXEC PROC_IMPORT_NewRetailer_ORDERBOOKING
	UPDATE ImportPDA_OrderBooking SET MKTID=0 WHERE ISNULL(MKTID,0)=0
	UPDATE ImportPDA_OrderBooking SET Rtrid=0 WHERE ISNULL(Rtrid,0)=0
	---Check for New Retailer Order Booking
	IF EXISTS (SELECT * FROM ImportPDA_OrderBooking WHERE Mktid=0 and Rtrid=0)
	BEGIN
		INSERT INTO ImportPDA_NewRetailerOrderBooking
		SELECT * FROM ImportPDA_OrderBooking WHERE Mktid=0 and Rtrid=0
		
		INSERT INTO ImportPDA_NewRetailerOrderProduct
		SELECT * FROM ImportPDA_OrderBookingProduct WHERE OrdKeyNo in
		(SELECT OrdKeyNo FROM ImportPDA_OrderBooking WHERE Mktid=0 and Rtrid=0)
		
		DELETE FROM ImportPDA_OrderBookingProduct WHERE OrdKeyNo in
		(SELECT OrdKeyNo FROM ImportPDA_OrderBooking WHERE Mktid=0 and Rtrid=0)
		
		DELETE FROM ImportPDA_OrderBooking WHERE Mktid=0 and Rtrid=0
	END
	
	SELECT DISTINCT SrpCde,OrdKeyNo,EndTime INTO #ImportPDA_OrderBooking1 From ImportPDA_OrderBooking WHERE SrpCde=@SalRpCode 
	
 IF  EXISTS(SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)
 BEGIN  	
	DECLARE CUR_Import CURSOR FOR
	SELECT OrdKeyNo From #ImportPDA_OrderBooking1 ORDER BY EndTime ASC
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
		SET @SalRpCode=(SELECT DISTINCT SrpCde From ImportPDA_OrderBooking WHERE OrdKeyNo=@OrdKeyNo)
		
		SET @SrpId = (SELECT SMId FROM SalesMan Where SMCode = @SalRpCode)
		
		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking WHERE DocRefNo = @OrdKeyNo)
		BEGIN
			SET @RtrId = (Select TOP 1 RtrId FROM ImportPDA_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@RtrId,'Retailer Does Not Exists for the Order ' + @OrdKeyNo 
			END
			
			SET @RtrShipId=(
			SELECT top 1 RS.RtrShipId FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid 
			WHERE  R.RtrId=@RtrId)
			
			SET @MktId = (Select TOP 1 MktId FROM ImportPDA_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			
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
					0,@OrdKeyNo,1, @SrpId as Smid,  
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
					                          MRP,GrossAmount,PriceId,Availability,LastModBy,LastModDate,AuthId,AuthDate,SlNo)  
			SELECT @GetKeyStr,Prdid,Prdbatid,UomID,OrdQty,ConversionFactor,0,0,0,(OrdQty*ConversionFactor),0,
			SUM(Rate)Rate ,SUM(MRP)MRP,sum(GrossAmount)GrossAmount,sum(PriceId)PriceId,
			1,SUM(LineId),CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
			1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),SUM(LineId)
			FROM ( 
			SELECT P.Prdid,PB.Prdbatid,U.UomID,OrdQty,u.ConversionFactor,  
			PBD.PrdBatDetailValue Rate,0 as Mrp,(PBD.PrdBatDetailValue*(OrdQty*ConversionFactor)) as GrossAmount,PBD.PriceId,LineId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN ImportPDA_OrderBookingProduct I ON I.PRDID=P.PRDID AND I.PRDID=PB.PRDID AND I.PRDBATID=PB.PRDBATID
			INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId 
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid --and PB.DefaultPriceId=PBD.PriceId 
			AND PBD.prdbatid=i.PrdBatId
					   AND BC.slno=PBD.SLNo AND BC.SelRte=1  and PBD.PriceId=I.PriceId 
			WHERE OrdKeyNo=@OrdKeyNo	   
		UNION ALL
			SELECT P.Prdid,PB.Prdbatid,U.UomID,OrdQty,ConversionFactor,  
			0 Rate,PBD.PrdBatDetailValue as Mrp,0 as GrossAmount,0 as PriceId,0 LineId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN ImportPDA_OrderBookingProduct I ON I.PRDID=P.PRDID AND I.PRDID=PB.PRDID AND I.PRDBATID=PB.PRDBATID
			INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId 
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId AND PBD.prdbatid=i.PrdBatId
					   AND BC.slno=PBD.SLNo AND BC.MRP=1  and PBD.PriceId=I.PriceId
			WHERE OrdKeyNo=@OrdKeyNo)A
					GROUP BY Prdid,Prdbatid,UomID,OrdQty,ConversionFactor
			ORDER BY SUM(LineId)
			 
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
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='PROC_IMPORT_PRODUCTPDA_Collection' AND xtype='P')
DROP PROCEDURE PROC_IMPORT_PRODUCTPDA_Collection
GO
/*
BEGIN TRAN
DELETE from PDA_Receiptinvoice WHERE RECEIPTNO IN ('a2aab1d8-83da-4b40-826e-1c046e7b83f7','e842ac1f-a6af-4aec-afdc-dd524bc68ba4','405f7e50-3ec2-468a-b54a-c7e795dfb3ec')
exec PROC_IMPORT_PRODUCTPDA_Collection 'SM01'
SELECT * from PDA_Receiptinvoice WHERE RECEIPTNO IN ('a2aab1d8-83da-4b40-826e-1c046e7b83f7','e842ac1f-a6af-4aec-afdc-dd524bc68ba4','405f7e50-3ec2-468a-b54a-c7e795dfb3ec')
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[PROC_IMPORT_PRODUCTPDA_Collection]
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
DECLARE @InvRcpNo AS NVARCHAR(100)
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
DECLARE @InvRcpNoT AS NVARCHAR(100)
DECLARE @RtrCode AS VARCHAR(100)

--RETURN

CREATE  TABLE #PDA_ReceiptInvoiceSplitActual
(
Salid int,
InvRcpNo nvarchar(125),
Salinvno varchar(50),
Salinvdate datetime,
invrcpdate datetime,
CollectionAmt numeric(18,2),
InvinsNo nvarchar(200),
BnkBrid int,
InvRcpMode int
)

SET @RtrCode=''
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
				
				SET @RtrCode=(SELECT TOP 1 RtrCode FROM ImportProductPDA_Receiptinvoice I WHERE I.InvRcpNo=@InvRcpNo)
			
				
				--SELECT DISTINCT SI.Salid,SI.SALINVNO,SI.SalInvDate,(SI.salnetamt-SI.salpayamt-isnull(CollectionAmt,0))PendingAmt 
				--	FROM ImportProductPDA_Receiptinvoice I
				--	INNER JOIN RETAILER R ON R.RTRCODE=I.RtrCode 
				--	 INNER JOIN (SELECT Salid,SALINVNO,SalInvDate,salnetamt,salpayamt,RTRID FROM salesinvoice WHERE Dlvsts=4) SI 
				--				 ON R.RTRID=SI.RTRID
				--	LEFT OUTER JOIN @Table P on P.salinvno=I.salinvno	--WHERE  I.InvRcpNo=@InvRcpNo
				--	--AND I.Salinvno NOT IN (SELECT salinvno FROM PDA_ReceiptInvoiceSplit where InvRcpNo=@InvRcpNo)
				--	and (SI.salnetamt-SI.salpayamt-isnull(CollectionAmt,0))>0
				
				
				
			IF NOT EXISTS (SELECT DocRefNo FROM Receipt WHERE DocRefNo = @InvRcpNo)  
				  BEGIN   
					DECLARE Cur_Collection_Split cursor
					FOR SELECT DISTINCT SI.Salid,SI.SALINVNO,SI.SalInvDate,(SI.salnetamt-SI.salpayamt-isnull(CollectionAmt,0))PendingAmt 
					FROM RETAILER R 
					INNER JOIN (SELECT Salid,SALINVNO,SalInvDate,salnetamt,salpayamt,RTRID FROM salesinvoice WHERE Dlvsts=4) SI ON R.RTRID=SI.RTRID
					LEFT OUTER JOIN (SELECT salinvno,SUM(CollectionAmt) as CollectionAmt FROM 
						#PDA_ReceiptInvoiceSplitActual group by salinvno) P on P.salinvno=SI.salinvno where R.RtrCode=@RtrCode
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
					
					SELECT * FROM #PDA_ReceiptInvoiceSplitActual
			    
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
			SELECT @lError
			 
			FETCH NEXT FROM Cur_CollectionTotal INTO @InvRcpNoT 
			END
			CLOSE Cur_CollectionTotal 
			DEALLOCATE Cur_CollectionTotal 
			
			
 END 
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='PROC_IMPORT_NewRetailer_ORDERBOOKING' AND xtype='P')
DROP PROCEDURE PROC_IMPORT_NewRetailer_ORDERBOOKING
GO
--exec PROC_IMPORT_NewRetailer_ORDERBOOKING  
CREATE PROCEDURE PROC_IMPORT_NewRetailer_ORDERBOOKING
AS
/*********************************/      
DECLARE @OrdKeyNo AS VARCHAR(50)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
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
DECLARE @SalRpCode AS NVARCHAR(50)
DECLARE @RtrCode  AS NVARCHAR(50)
BEGIN
	BEGIN TRANSACTION T1
	DELETE FROM ImportPDA_NewRetailerOrderBooking WHERE UploadFlag='Y'
	DELETE FROM ImportPDA_NewRetailerOrderProduct WHERE UploadFlag='Y'
	
	DECLARE CUR_Import CURSOR FOR
	SELECT DISTINCT OrdKeyNo,SrpCde,RtrCde From ImportPDA_NewRetailerOrderBooking  
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalRpCode,@RtrCode 
	While @@Fetch_Status = 0
	BEGIN
		SET @OrdPrdCnt=0
		SET @PdaOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0
		
		SET @SrpId = (SELECT SMId FROM SalesMan WHERE SMCode = @SalRpCode)
		
		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking WHERE DocRefNo = @OrdKeyNo)
		BEGIN
			SET @RtrId = (SELECT RtrId FROM Retailer WHERE Rtrcode = @RtrCode)
			
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
			END
			
			SELECT @RtrShipId=RS.RtrShipId FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid 
			WHERE RtrShipDefaultAdd=1  AND R.RtrId=@RtrId  
			
			SELECT RM.RMId FROM Retailer R INNER JOIN RetailerMarket RM ON R.RtrId=RM.RtrId	WHERE RtrCode=@RtrCode
			SET @MktId = (SELECT RM.RMId FROM Retailer R INNER JOIN RetailerMarket RM ON R.RtrId=RM.RtrId	WHERE RtrCode=@RtrCode)
			
			IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)
			BEGIN
				SET @lError = 1 
			END
			
			IF NOT EXISTS (SELECT * FROM SalesManMarket WHERE RMID = @MktId AND SMID = @SrpId)
			BEGIN
				SET @lError = 1
			END
			
			IF NOT EXISTS(SELECT OrdKeyNo FROM  ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
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
				SELECT DISTINCT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  From ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo GROUP BY PrdId,PrdBatId,PriceId
				OPEN CUR_ImportOrderProduct
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
						SET @PError = 0
						IF NOT EXISTS(SELECT PrdId From Product WHERE Prdid=@Prdid)
						BEGIN
							SET @PError = 1
						END
						
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @PError = 1
						END
						
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @PError = 1  
						END
						
						IF @OrdQty<=0
						BEGIN
							SET @PError = 1
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
					BREAK  
				END
				
			IF @lError = 0 AND @CNT>0
			BEGIN
				--HEDER 
					SELECT  @OrderDate= OrdDt FROM ImportPDA_NewRetailerOrderBooking WHERE  OrdKeyNo=@OrdKeyNo
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
					
					SELECT @Longitude=ISNULL(Longitude,0),@Latitude =ISNULL(Latitude,0) FROM ImportPDA_NewRetailerOrderBooking WHERE  OrdKeyNo=@OrdKeyNo 
					SELECT @LAUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Latitude'
                    SELECT @LOUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Longitude'
					UPDATE UdcDetails SET ColumnValue=@Latitude WHERE UdcMasterId=@LAUdcMasterId AND MasterRecordId=@RtrId
					UPDATE UdcDetails SET ColumnValue=@Longitude WHERE UdcMasterId=@LOUdcMasterId AND MasterRecordId=@RtrId
					
				 --DETAILS 
		    INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,ConvFact2,TotalQty,BilledQty,Rate,
					                          MRP,GrossAmount,PriceId,Availability,LastModBy,LastModDate,AuthId,AuthDate,SlNo)  
			SELECT @GetKeyStr,Prdid,Prdbatid,UomID,OrdQty,ConversionFactor,0,0,0,OrdQty,0,
			SUM(Rate)Rate ,SUM(MRP)MRP,sum(GrossAmount)GrossAmount,sum(PriceId)PriceId,
			1,SUM(LineId),CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
			1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),SUM(LineId) 
			FROM ( 
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			PBD.PrdBatDetailValue Rate,0 as Mrp,(PBD.PrdBatDetailValue*(OrdQty*ConversionFactor)) as GrossAmount,PBD.PriceId,LineId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT I.PrdId,PrdBatId,PriceId,Sum(OrdQty*ConversionFactor) as OrdQty,SUM(LineId) AS LineId  FROM ImportPDA_NewRetailerOrderProduct I 
				INNER JOIN Product P ON P.PrdId=I.PRDID
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId WHERE OrdKeyNo=  @OrdKeyNo 
				GROUP BY i.PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid --and PB.DefaultPriceId=PBD.PriceId  
			and BC.slno=PBD.SLNo AND BC.SelRte=1  and PBD.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y' 
		UNION ALL
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			0 Rate,PBD1.PrdBatDetailValue as Mrp,0 as GrossAmount,0 as PriceId,0 LineId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT I.PrdId,PrdBatId,PriceId,Sum(OrdQty*ConversionFactor) as OrdQty  FROM ImportPDA_NewRetailerOrderProduct I 
				INNER JOIN Product P ON P.PrdId=I.PRDID
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId WHERE OrdKeyNo=  @OrdKeyNo  
			 GROUP BY I.PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC1 (NOLOCK) ON BC1.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatid=Pb.PrdBatid --and PB.DefaultPriceId=PBD1.PriceId  
			and BC1.slno=PBD1.SLNo AND BC1.MRP=1  and PBD1.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y')A
			GROUP BY Prdid,Prdbatid,UomID,OrdQty,ConversionFactor
			ORDER BY SUM(LineId)
			 
		  UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  
		  FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X  ON X.OrderNo=OB.OrderNo   
			  
		  SELECT DISTINCT SrpCde,OrdKeyNo,PrdId,PrdBatId  INTO #TEMPCHECK   
				FROM ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo
					
		SELECT @OrdPrdCnt=ISNULL(Count(PRDID),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
		SELECT @PdaOrdPrdCnt=ISNULL(Count(PRDID),0) FROM #TEMPCHECK (NOLOCK) WHERE OrdKeyNo=@OrdKeyNo
		
		IF @OrdPrdCnt=@PdaOrdPrdCnt  
		BEGIN 
			UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
			UPDATE ImportPDA_NewRetailerOrderBooking SET UploadFlag = 'Y' WHERE SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo = @OrdKeyNo
			UPDATE ImportPDA_NewRetailerOrderProduct SET UploadFlag = 'Y' WHERE SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo =@OrdKeyNo 
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
			Delete From PDALog WHERE SrpCde = @SalRpCode And DataPoint = 'ORDERBOOKING'
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,'Order Already exists'
		END
		
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalRpCode,@RtrCode 
	END
	CLOSE CUR_Import
	DEALLOCATE CUR_Import
	
	  --EXEC PROC_PDASALESMANDETAILS @SalRpCode
 	
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
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ImportPDA2CS' AND XTYPE='P')
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
	 INSERT INTO ImportPDA_OrderBooking(SrpCde,OrdKeyNo,OrdDt,RtrCde,Mktid,
	 SrpId,Rtrid,Remarks,UploadFlag,Longitude,Latitude,EndTime)
	 SELECT SrpCde,OrdKeyNo,OrdDt,RtrCde,Mktid,SrpId,Rtrid,Remarks,UploadFlag,Longitude,Latitude,EndTime
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
		Latitude varchar(50),
		EndTime DATETIME
	 ) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  
	END
 IF @PROCESSNAME = 'OrderBookingProduct'
	BEGIN
	 DELETE FROM ImportPDA_OrderBookingProduct  WHERE UploadFlag='Y'  
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportPDA_OrderBookingProduct(SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId,OrdQty,UploadFlag,Uomid,Lineid)  
	 SELECT SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId,OrdQty,UploadFlag,UomId,Lineid
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
		UomId Int,
		Lineid Int
	 ) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  
	END
 IF @PROCESSNAME = 'SalesReturn'
	BEGIN
	DELETE FROM ImportProductPDA_SalesReturn  WHERE UploadFlag='Y'  
	   
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportProductPDA_SalesReturn(SrpCde,SrNo,SrDate,SalInvNo,RtrCde,Rtrid,Mktid,Srpid,ReturnMode,InvoiceType,UploadFlag)  
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
	 INSERT INTO ImportProductPDA_SalesReturnProduct(SrpCde,SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,
	 salinvno,SlNo,Reasonid,UploadFlag,MRP)  
	 SELECT SrpCde,SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo,Reasonid,UploadFlag,MRP
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
		Reasonid	int,
		MRP NUMERIC(18,3)
	) XMLObj   
	 EXEC sp_xml_removedocument @hDoc  
	END
  IF @PROCESSNAME = 'Receiptinvoice'
	BEGIN
	 DELETE FROM ImportProductPDA_Receiptinvoice  WHERE UploadFlag='Y'  
	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
	 INSERT INTO ImportProductPDA_Receiptinvoice  (SrpCde,InvRcpNo,InvRcpDate,InvrcpAmt,SalInvNo,SalInvDate,SalInvAmt,InvRcpMode,BnkBrId,InvInsNo,
	 InvInsDate,InvDepDate,InvInsSta,CashAmt,ChequeAmt,UploadFlag,RtrCode)
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
	 INSERT INTO ImportProductPDA_CreditNote(SrpCde,InvRcpNo,CrNo,CrAmount,SalInvNo,RtrId,
	 CrAdjAmount,TranNo,Reasonid,UploadFlag) 
	 SELECT SrpCde,InvRcpNo,CrNo,CrAmount,SalInvNo,RtrId,CrAdjAmount,TranNo,Reasonid,UploadFlag
	 FROM OPENXML (@hdoc,'/Root/Import_CreditNote',1)  
	 WITH   
	 (  
		SrpCde	varchar(100),
		InvRcpNo VARCHAR(50),
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
	 INSERT INTO ImportProductPDA_DebitNote(SrpCde,DbNo,DbAmount,RtrId,DbAdjAmount,TransNo,Reasonid,UploadFlag) 
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
	 INSERT INTO ImportProductPDA_NewRetailer (SrpCde,RtrCode,RetailerName,CtgLevelId,CtgMainID,RtrClassId,RtrAdd1,RtrAdd2,RtrAdd3,
	 RtrPhoneNo,CreditAvailable,RtrTINNo,UploadFlag,Longitude,Latitude,RtrMobileNo)
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
	 INSERT INTO ImportProductPDA_NonProductiveRetailers(SrpCde,RtrCode,ReasonId,NonProdDate,UploadFlag)  
	 SELECT SrpCde,RtrCode,ReasonId,NonProdDate,UploadFlag
	 FROM OPENXML (@hdoc,'/Root/Mob2Cos_NonProductiveRetailers',1)  
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
  --EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records 
		--	INSERT INTO Mob2Cos_SalesmanPDADetails
		--	(
		--			DistCode,
		--			Date,
		--			SmCode,
		--			RMId,
		--			RtrId,
		--			OrderNo,
		--			StartTime,
		--			EndTime,
		--			NorOrDayend,
		--			UploadFlag
		--	)
		--	SELECT DISTINCT DistCode,
		--			OrdDt,
		--			SrpCde,
		--			Mktid,
		--			Rtrid,
		--			IsNull(OrdKeyNo,''),
		--			StartTime,
		--			EndTime,
		--			TransactionType,
		--			UploadFlag
		--	 FROM OPENXML (@hdoc,'/Root/DD',1)  
		--	 WITH   
		--	 (  
		--			DistCode		VARCHAR(50),
		--			OrdDt			DATETIME,
		--			SrpCde			VARCHAR(50),
		--			Mktid			INT,
		--			Rtrid			INT,
		--			OrdKeyNo			VARCHAR(50),
		--			StartTime		DATETIME,
		--			EndTime			DATETIME,
		--			TransactionType		TINYINT,
		--			UploadFlag		VARCHAR(1)
		--	) XMLObj   
		--	EXEC sp_xml_removedocument @hDoc  
		-- DELETE FROM ImportPDA_OrderBookingProduct  WHERE UploadFlag='Y'  
		-- EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records 
  
  
--IF @PROCESSNAME = 'RetailerStockCapture'
--  BEGIN
--	 DELETE FROM ImportProductPDA_NonProductiveRetailers  WHERE UploadFlag='Y'  
--	 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
--	 INSERT INTO ImportProductPDA_NonProductiveRetailers(SrpCde,RtrCode,ReasonId,NonProdDate,UploadFlag)  
--	 SELECT SrpCde,RtrCode,ReasonId,NonProdDate,UploadFlag
--	 FROM OPENXML (@hdoc,'/Root/Mob2Cos_RetailerStockCapture',1)  
--	 WITH   
--	 (  
--		SrpCde varchar(50),
--		RtrCode nvarchar(50),
--		ReasonId int ,
--		NonProdDate datetime,
--		UploadFlag varchar(1)
--	) XMLObj   
--	 EXEC sp_xml_removedocument @hDoc  
--  END  

END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ImportPDA2CS_USB' AND XTYPE='P')
DROP PROCEDURE Proc_ImportPDA2CS_USB
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
		SrpId,Rtrid,Remarks,UploadFlag,'' Longitude,'' Latitude,ENDTime
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
		PriceId,OrdQty,UploadFlag,Uomid,LineId
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
	   
	 
	 INSERT INTO ImportProductPDA_SalesReturnProduct(
	 SrpCde,SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo,Reasonid,UploadFlag,MRP)  
	 SELECT 
		SrpCde,SrNo,PrdId,PrdBatId,PriceId,SrQty,
		UsrStkTyp,salinvno,SlNo,Reasonid,UploadFlag,MRP
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
DELETE FROM Tbl_Downloadprocess_ImportPDA
INSERT INTO Tbl_Downloadprocess_ImportPDA([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount])
SELECT 1,'OrderBooking','Mob2Cos_OrderBooking','',0,500 UNION ALL
SELECT 2,'OrderBookingProduct','Mob2Cos_OrderBookingProduct','PROC_IMPORT_PRODUCTPDA_ORDERBOOKING',0,500 UNION ALL
SELECT 3,'SalesReturn','Mob2Cos_SalesReturn','',0,500 UNION ALL
SELECT 4,'SalesReturnProduct','Mob2Cos_SalesReturnProduct','PROC_IMPORT_ProductPDA_SALESRETURN',0,500 UNION ALL
SELECT 5,'Receiptinvoice','Mob2Cos_Receiptinvoice','PROC_IMPORT_PRODUCTPDA_Collection',0,500 UNION ALL
SELECT 6,'Import_CreditNote','Mob2Cos_CreditNote','PROC_IMPORT_PRODUCTPDA_Collection',0,500 UNION ALL
SELECT 7,'Import_DebitNote','Mob2Cos_DebitNote','PROC_IMPORT_PRODUCTPDA_Collection',0,500 UNION ALL
SELECT 8,'NewRetailer','Mob2Cos_NewRetailer','Proc_Import_PDA_NewRetailer',0,500 UNION ALL
SELECT 9,'NonProductiveRetailers','Mob2Cos_NonProductiveRetailers','',0,500 --UNION ALL
--10	RetailerStockCapture	Mob2Cos_RetailerStockCapture		0	500
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROC_IMPORT_PDAPROCESSDATA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PROC_IMPORT_PDAPROCESSDATA]
GO
CREATE PROCEDURE [dbo].[PROC_IMPORT_PDAPROCESSDATA]
(
@ProcessName	VARCHAR(300),
@SrpCode Varchar(100)
)
AS  
SET NOCOUNT ON 
BEGIN
DECLARE @SpName AS VARCHAR(200)
DECLARE @SQL AS VARCHAR(MAX)
	SELECT @SpName=SPName FROM TBL_Downloadprocess_ImportPDA WHERE ProcessName=@ProcessName
	
	IF ISNULL(@SpName,'')<>''
	BEGIN
		SET @SQL=''
		SET @SQL='EXEC '+@SpName + ' ''' +@SrpCode + ''''
		print @SQL
		EXEC (@SQL)
		--Print (@SQL)
	END
END 
GO
--Till Here
UPDATE UtilityProcess SET VersionId = '3.1.0.8' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.8',431
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 431)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(431,'D','2017-04-07',GETDATE(),1,'Core Stocky Service Pack 431')