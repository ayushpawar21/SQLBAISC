--[Stocky HotFix Version]=345
Delete from Versioncontrol where Hotfixid='345'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('345','2.0.0.5','D','2010-10-23','2010-10-23','2010-10-23',convert(varchar(11),getdate()),'Parle;Major:Phase I CRs;Minor:')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 345' ,'345'
GO

--SRF-Nanda-165-001

UPDATE HotSearchEditorHd SET RemainsltString=
'SELECT RtrSeqDtId,RtrId,RtrCode,RtrName,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert,
RTRDayOff,RtrTINNo,RtrCSTNo,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrDOB,RtrAnniversary,
RtrTaxType
FROM (SELECT B.RtrSeqDtId,C.RtrId,C.RtrCode,C.RtrName,C.RtrCrDaysAlert,C.RtrCrBillsAlert,C.RtrCrLimitAlert,  
C.RTRDayOff,C.RtrTINNo,C.RtrCSTNo,C.RtrLicNo,ISNULL(C.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,C.RtrDrugLicNo,
ISNULL(C.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,C.RtrPestLicNo,
ISNULL(C.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,
ISNULL(C.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,
ISNULL(C.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,C.RtrTaxType
FROM RetailerSequence A (NOLOCK) INNER JOIN RetailerSeqDetails B (NOLOCK)   ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId   
Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam And TransactionType=vTParam    
Union   
SELECT 100000 as RtrSeqDtId,D.RtrId,D.RtrCode,D.RtrName,D.RtrCrDaysAlert,D.RtrCrBillsAlert,D.RtrCrLimitAlert, 
D.RTRDayOff,D.RtrTINNo,D.RtrCSTNo,D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,
ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,
ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,
ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,
ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,D.RtrTaxType
FROM Retailer D (NOLOCK) INNER JOIN RetailerMarket E (NOLOCK) ON   D.RtrId = E.RtrId Where D.RtrStatus = 1 And E.RMId = vSParam And D.Rtrid Not In 
(SELECT C.RtrId   FROM RetailerSequence A (NOLOCK) INNER JOIN RetailerSeqDetails B (NOLOCK) ON   A.RtrSeqID = B.RtrSeqId 
INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId   Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam And TransactionType= vTParam)) a  
ORDER BY RtrSeqDtId'
WHERE FormId=668


UPDATE HotSearchEditorHd SET RemainsltString=
'SELECT PrdId,PrdDcode,PrdCcode,  PrdName,PrdShrtName,UomGroupId,PrdSeqDtId,PrdType 
FROM 
(
	SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName, A.UomGroupId,C.PrdSeqDtId,A.PrdType FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),  
	ProductSeqDetails C WITH (NOLOCK),ProductBatch D   WHERE B.TransactionId=vFParam AND A.PrdStatus=1   AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId   
	AND A.PrdId=D.PrdId AND A.PrdType IN (1,2,5,6)     
	UNION   
	SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,100000 AS PrdSeqDtId,A.PrdType FROM  Product A WITH (NOLOCK) 
	INNER JOIN ProductBatch D ON A.PrdId=D.PrdId AND D.Status=1     WHERE PrdStatus = 1 AND A.Cmpid =vSParam AND A.PrdId NOT IN 
	( 
		SELECT PrdId FROM ProductSequence B WITH (NOLOCK),    ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=vFParam AND B.PrdSeqId=C.PrdSeqId
	)   
	AND A.PrdType IN (1,2,5,6) 
) A ORDER BY PrdSeqDtId'
WHERE FormId=678

UPDATE HotSearchEditorHd SET RemainsltString=
'SELECT PrdId,PrdDcode,PrdCcode,  PrdName,PrdShrtName,UomGroupId,PrdSeqDtId,PrdType
FROM 
(
	SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,C.PrdSeqDtId,A.PrdType FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),  
	ProductSeqDetails C WITH (NOLOCK),  ProductBatch D WHERE B.TransactionId=vFParam AND A.PrdStatus=1    AND B.PrdSeqId = C.PrdSeqId   AND A.PrdId = C.PrdId 
	AND A.PrdId=D.PrdId AND A.PrdType IN (1,2,5,6)     
	UNION  
	SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,100000 AS PrdSeqDtId,A.PrdType FROM  Product A WITH (NOLOCK) 
	INNER JOIN ProductBatch D ON A.PrdId=D.PrdId     AND D.Status=1 WHERE PrdStatus = 1 and  
	A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) 
	WHERE B.TransactionId=vFParam AND B.PrdSeqId=C.PrdSeqId)     
	AND A.PrdType IN (1,2,5,6) 
) A ORDER BY PrdSeqDtId'
WHERE FormId=677


UPDATE HotSearchEditorHd SET RemainsltString=
'SELECT PrdId,PrdDcode,PrdCcode,  PrdName,PrdShrtName,UomGroupId,PrdSeqDtId,MRP,PrdType 
FROM 
(
	SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,c.PrdSeqDtId,PBD.PrdBatDetailValue AS MRP,A.PrdType   
	FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),ProductBatch D,ProductBatchDetails PBD,BatchCreation BC 
	WHERE B.TransactionId=  vFParam  AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId AND A.PrdId=D.PrdId 
	AND A.PrdType IN (1,2,5,6) AND D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId = BC.BatchSeqId      
	UNION 
	SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,100000 AS PrdSeqDtId,PBD.PrdBatDetailValue AS MRP,A.PrdType  
	FROM  Product A WITH (NOLOCK) INNER JOIN ProductBatch D ON A.PrdId=D.PrdId AND D.Status=1  
	Inner Join ProductBatchDetails PBD ON D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1    
	INNER JOIN  BatchCreation BC ON PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId   
	WHERE PrdStatus = 1 and A.Cmpid =vSParam  and 
	A.PrdId NOT IN 
	(
		SELECT PrdId FROM ProductSequence B WITH (NOLOCK),   
		ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId= vFParam AND B.PrdSeqId=C.PrdSeqId
	)   
	AND A.PrdType IN (1,2,5,6) 
) A ORDER BY PrdSeqDtId'
WHERE FormId=749

UPDATE HotSearchEditorHd SET RemainsltString=
'SELECT PrdId,PrdDcode,PrdCcode,PrdName,PrdShrtName,UomGroupId,PrdSeqDtId,MRP,PrdType  
FROM 
(
	SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,c.PrdSeqDtId,PBD.PrdBatDetailValue AS MRP,A.PrdType  
	FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK), ProductBatch D,ProductBatchDetails PBD, 
	BatchCreation BC   WHERE B.TransactionId=  vFParam AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId  AND A.PrdId = C.PrdId   AND A.PrdId=D.PrdId    
	AND A.PrdType IN (1,2,5,6) AND D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1     
	AND PBD.SlNo=BC.SlNo AND BC.MRP=1  AND PBD.BatchSeqId = BC.BatchSeqId 
	UNION 
	SELECT A.PrdId,A.PrdDcode,A.PrdCcode,  A.PrdName,A.PrdShrtName,A.UomGroupId,100000 AS PrdSeqDtId,PBD.PrdBatDetailValue AS MRP,A.PrdType  
	FROM  Product A WITH (NOLOCK)   INNER JOIN ProductBatch D   ON A.PrdId=D.PrdId  AND D.Status=1  
	Inner Join ProductBatchDetails PBD    ON D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 
	INNER JOIN  BatchCreation BC ON PBD.SlNo=BC.SlNo   AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId    
	WHERE PrdStatus = 1 and  
	A.PrdId NOT IN 
	(
		SELECT PrdId FROM   ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK)   
		WHERE B.TransactionId= vFParam   AND B.PrdSeqId=C.PrdSeqId
	)  
	AND A.PrdType IN (1,2,5,6) 
) A   ORDER BY PrdSeqDtId'
WHERE FormId=748

--SRF-Nanda-165-002

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_UDCDefaults]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_UDCDefaults]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_UDCDefaults]
(
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MasterName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DownLoadFlag] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_UDCDefaults]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_UDCDefaults]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_Import_Configuration '<Root></Root>'

CREATE    PROCEDURE [dbo].[Proc_Import_UDCDefaults]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_UDCDefaults
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_UDCDefaults
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/08/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_UDCDefaults WHERE DownLoadFlag='Y'

	INSERT INTO Cn2Cs_Prk_UDCDefaults(DistCode,MasterName,ColumnName,ColumnValue,DownLoadFlag)
	SELECT DistCode,MasterName,ColumnName,ColumnValue,DownLoadFlag
	FROM OPENXML (@hdoc,'/Root/Console2CS_UDCMasterValue',1)
	WITH 
	(	
			[DistCode]		NVARCHAR(100), 
			[MasterName]	NVARCHAR(100),
			[ColumnName]	NVARCHAR(100),						
			[ColumnValue]	NVARCHAR(100),			
			[DownLoadFlag]	NVARCHAR(10) 
	) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_UDCDefaults]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_UDCDefaults]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_UDCDefaults 0
SELECT * FROM Cn2Cs_Prk_UDCDefaults
ROLLBACK TRANSACTION
*/

CREATE            Procedure [dbo].[Proc_Cn2Cs_UDCDefaults]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_UDCDefaults
* PURPOSE		: To Validate the UDC Default Values Downloaded from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/08/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	SET @Po_ErrNo=0

	DECLARE @MasterName		NVARCHAR(100)
	DECLARE @ColumnName		NVARCHAR(100)
	DECLARE @ColumnValue	NVARCHAR(100)
	
	DECLARE @SeqId			INT
	DECLARE @MasterId		INT
	DECLARE @UDCMasterId	INT


	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'UDCDefToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE UDCDefToAvoid	
	END

	CREATE TABLE UDCDefToAvoid
	(		
		MasterName		NVARCHAR(200),
		ColumnName		NVARCHAR(200)
	)

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')='') 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','MasterName','Module Name should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')=''
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')='') 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','ColumnName','Column Name should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')=''
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')='') 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','ColumnValue','Column Value should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')=''
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN 
	(SELECT MAsterName FROM UDCHd)) 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN 
		(SELECT MAsterName FROM UDCHd)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','MasterName','Master Name:'+MasterName+' not available'
		FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN 
		(SELECT MAsterName FROM UDCHd)
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN 
	(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId)) 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN 
		(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','UDC Master','UDC Name:'+ColumnName+' not available for:'+MasterName
		FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN 
		(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId)
	END

	DECLARE Cur_UDCDef CURSOR
	FOR SELECT MasterName,ColumnName,ColumnValue
	FROM Cn2Cs_Prk_UDCDefaults WHERE DownLoadFlag='D' AND ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'') 
	NOT IN (SELECT ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'') FROM UDCDefToAvoid)
	OPEN Cur_UDCDef
	FETCH NEXT FROM Cur_UDCDef INTO @MasterName,@ColumnName,@ColumnValue
	WHILE @@FETCH_STATUS=0
	BEGIN

		SELECT @MasterId=MasterId FROM UDCHd WHERE MasterName=@MasterName
		SELECT @UdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName=@ColumnName

		IF NOT EXISTS(SELECT * FROM UDCDefault WHERE MasterId=@MasterId AND 
		UDCMasterId=@UDCMasterId AND ColValue=@ColumnValue)
		BEGIN
			SELECT @SeqId=ISNULL(MAX(SeqId),0)+1 FROM UDCDefault WHERE MasterId=@MasterId AND 
			UDCMasterId=@UDCMasterId

			INSERT UDCDefault(SeqId,MasterId,UdcMasterId,ColValue)
			SELECT @SeqId,@MasterId,@UDCMasterId,@ColumnValue
		END

		FETCH NEXT FROM Cur_UDCDef INTO @MasterName,@ColumnName,@ColumnValue
	END
	CLOSE Cur_UDCDef
	DEALLOCATE Cur_UDCDef

	UPDATE Cn2Cs_Prk_UDCDefaults SET DownLoadFlag='Y' WHERE DownLoadFlag='D' AND ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'')
	NOT IN (SELECT ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'') FROM UDCDefToAvoid)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-005

DELETE FROM Configuration WHERE ModuleId='BotreePrdUpload'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('BotreePrdUpload','BotreePrdUpload','Daily Product Upload',0,'',0.00,1)

DELETE FROM Configuration WHERE ModuleId='BotreeRtrUpload'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('BotreeRtrUpload','BotreeRtrUpload','Daily Retailer Upload',1,'',1.00,1)


DELETE FROM DayEndProcess WHERE ProcId=14
INSERT INTO DayEndProcess(ProcDate,ProcId,NextUpDate,ProcDesc)
VALUES(GETDATE(),14,GETDATE()-1,'Daily Retailer Upload')

DELETE FROM DayEndProcess WHERE ProcId=15
INSERT INTO DayEndProcess(ProcDate,ProcId,NextUpDate,ProcDesc)
VALUES(GETDATE(),15,GETDATE()-1,'Daily Product Upload')

--SRF-Nanda-165-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_DailyProductDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_DailyProductDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_DailyProductDetails 0
SELECT COUNT(*) FROM Cs2Cn_Prk_DailyProductDetails
--DELETE FROM Cs2Cn_Prk_DailyProductDetails
SELECT * FROM DayEndProcess WHERE ProcId=15
--UPDATE DayEndProcess SET NextUpDate='2010-08-10' WHERE ProcId>13
--UPDATE Configuration SET Status=1,ConfigValue=2 WHERE ModuleId='BotreePrdUpload'
SELECT * FROM Configuration WHERE ModuleId='BotreeRtrUpload'
ROLLBACK TRANSACTION
*/

CREATE       PROCEDURE [dbo].[Proc_Cs2Cn_DailyProductDetails]
(  
	@Po_ErrNo INT OUTPUT  
) 
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DailyProductDetails
* PURPOSE		: Upload Daily Product Details from CoreStocky to Console
* NOTES			:
* CREATED BY	: Nandakumar R.G   
* CREATED DATE	: 30-03-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*************************************************
*
*************************************************/
SET NOCOUNT ON
BEGIN

	SET @Po_ErrNo=0

	DECLARE @DistCode	As nVarchar(50)
	DECLARE @Days		AS INT

	SELECT @DistCode = DistributorCode FROM Distributor
	DELETE FROM Cs2Cn_Prk_DailyProductDetails WHERE UploadFlag = 'Y'

	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreePrdUpload' AND Status=1)
	BEGIN
		SELECT @Days=ISNULL(ConfigValue,0) FROM Configuration WHERE ModuleId='BotreePrdUpload' 

		IF EXISTS(SELECT * FROM DayEndProcess WHERE DATEADD(DAY,@Days,NextUpDate)<=GETDATE() AND ProcId=15)
		BEGIN
			INSERT INTO Cs2Cn_Prk_DailyProductDetails
			(
				DistCode,
				PrdId,
				ProductCompanyCode,
				ProductDistributorCode,
				ProductName,
				ProductShortName,
				ProductStatus,
				PrdBatId,
				ProductBatchCode,
				CompanyBatchCode,
				ProductBatchStatus,
				DefaultPriceCode,
				DefaultMRP,
				DefaultListPrice,
				DefaultSellingRate,
				DefaultClaimRate,
				AddRate1,
				AddRate2,
				AddRate3,
				AddRate4,
				AddRate5,
				AddRate6,
				UploadedDate,
				UploadFlag
			)
			SELECT 
			@DistCode,
			P.PrdId,
			P.PrdCCode AS ProductCompanyCode,
			P.PrdDCode AS ProductDistributorCode,
			P.PrdName AS ProductName,
			P.PrdShrtName AS ProductShortName,
			(CASE P.PrdStatus WHEN 1 THEN 'Active' ELSE 'InActive' END) AS ProductStatus,
			ISNULL(PB.PrdBatId,0) AS PrdBatId,
			ISNULL(PB.PrdBatCode,'') AS ProductBatchCode,
			ISNULL(PB.CmpBatCode,'') AS CompanyBatchCode,
			(CASE PB.Status WHEN 1 THEN 'Active' WHEN 0 THEN 'InActive' ELSE '' END) AS ProductBatchStatus,
			ISNULL(PB.DefaultPriceCode,'')	As DefaultPriceCode,
			ISNULL(PB.DefaultMRP,0) AS DefaultMRP,
			ISNULL(PB.DefaultListPrice,0) AS DefaultListPrice,
			ISNULL(PB.DefaultSellingRate,0) AS DefaultSellingRate,
			ISNULL(PB.DefaultClaimRate,0) AS DefaultClaimRate,
			ISNULL(PB.AddRate1,0) AS AddRate1,
			ISNULL(PB.AddRate2,0) AS AddRate2,
			ISNULL(PB.AddRate3,0) AS AddRate3,
			ISNULL(PB.AddRate4,0) AS AddRate4,
			ISNULL(PB.AddRate5,0) AS AddRate5,
			ISNULL(PB.AddRate6,0) AS AddRate6,
			GETDATE(),
			'N' AS UploadFlag
			FROM Product P
			LEFT OUTER JOIN 
			(SELECT PB.PrdId,PB.PrdBatId,PB.CmpBatCode,PB.Status,PB.PrdBatCode,PBDM.PriceCode AS DefaultPriceCode,
			PBDM.PrdBatDetailValue AS DefaultMRP,
			PBDL.PrdBatDetailValue AS DefaultListPrice,
			PBDS.PrdBatDetailValue AS DefaultSellingRate,
			PBDC.PrdBatDetailValue AS DefaultClaimRate,
			0 AS AddRate1,
			0 AS AddRate2,
			0 AS AddRate3,
			0 AS AddRate4,
			0 AS AddRate5,
			0 AS AddRate6
			FROM ProductBatch PB 
			INNER JOIN ProductBatchDetails PBDM ON PB.PrdBatId=PBDM.PrdBatId AND PBDM.DefaultPrice=1
			INNER JOIN BatchCreation BCM ON PBDM.SlNo=BCM.SlNo AND PBDM.BatchSeqId=BCM.BatchSeqId 
			AND PBDM.BatchSeqId =BCM.BatchSeqId AND BCM.MRP=1
			INNER JOIN ProductBatchDetails PBDL ON PB.PrdBatId=PBDL.PrdBatId AND PBDL.DefaultPrice=1
			INNER JOIN BatchCreation BCL ON PBDL.SlNo=BCL.SlNo AND PBDL.BatchSeqId=BCL.BatchSeqId 
			AND PBDL.BatchSeqId =BCL.BatchSeqId AND BCL.ListPrice=1
			INNER JOIN ProductBatchDetails PBDS ON PB.PrdBatId=PBDS.PrdBatId AND PBDS.DefaultPrice=1
			INNER JOIN BatchCreation BCS ON PBDS.SlNo=BCS.SlNo AND PBDS.BatchSeqId=BCS.BatchSeqId 
			AND PBDS.BatchSeqId =BCS.BatchSeqId AND BCS.SelRte=1
			INNER JOIN ProductBatchDetails PBDC ON PB.PrdBatId=PBDC.PrdBatId AND PBDC.DefaultPrice=1
			INNER JOIN BatchCreation BCC ON PBDC.SlNo=BCC.SlNo AND PBDC.BatchSeqId=BCC.BatchSeqId 
			AND PBDC.BatchSeqId =BCC.BatchSeqId AND BCC.ClmRte=1	
			) PB 
			ON P.PrdId=PB.PrdId AND P.PrdCCode=PB.PrdBatCode


			UPDATE Prk SET AddRate1=PB.AddRate1
			FROM Cs2Cn_Prk_DailyProductDetails Prk,
			(SELECT PBDAD1.PrdBatId,PBDAD1.PrdBatDetailvalue AS AddRate1 
			FROM BatchCreation BCAD1,ProductBatchDetails PBDAD1 
			WHERE PBDAD1.SlNo=BCAD1.SlNo AND PBDAD1.BatchSeqId=BCAD1.BatchSeqId 
			AND BCAD1.RefCode='E' AND PBDAD1.DefaultPrice=1) AS PB
			WHERE Prk.PrdBatId=PB.PrdBatId

			UPDATE DayEndProcess SET NextUpDate=DATEADD(DAY,@Days,NextUpDate) WHERE ProcId=15
		END	
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_DailyRetailerDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_DailyRetailerDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_DailyRetailerDetails 0
--SELECT COUNT(*) FROM Cs2Cn_Prk_DailyRetailerDetails ORDER BY RtrId
--SELECT COUNT(*) FROM Retailer ORDER BY RtrId
--DELETE FROM RetailerValueClassMap WHERE RTrId BETWEEN 100 AND 103
--DELETE FROM UdcDetails WHERE MasterRecordId BETWEEN 200 AND 203
--DELETE FROM Cs2Cn_Prk_DailyRetailerDetails
SELECT * FROM Cs2Cn_Prk_DailyRetailerDetails
SELECT * FROM DayEndProcess
--UPDATE DayEndProcess SET NextUpDate='2010-08-10' WHERE ProcId>13
--UPDATE Configuration SET Status=1,ConfigValue=3 WHERE ModuleId='BotreeRtrUpload'
SELECT * FROM Configuration WHERE ModuleId='BotreeRtrUpload'
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_DailyRetailerDetails]
(
	@Po_ErrNo INT OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DailyRetailerDetails
* PURPOSE		: Extract Retailer Details from CoreStocky to Console
* NOTES			:
* CREATED		: Nandakumar R.G 
* CREATED DATE	: 30/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
***********************************************
*
***********************************************/
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @Days		AS INT

	SET @Po_ErrNo=0
	
	DELETE FROM Cs2Cn_Prk_DailyRetailerDetails WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRtrUpload' AND Status=1)
	BEGIN	
		SELECT @Days=ISNULL(ConfigValue,0) FROM Configuration WHERE ModuleId='BotreeRtrUpload' 		

		IF EXISTS(SELECT * FROM DayEndProcess WHERE DATEADD(DAY,@Days,NextUpDate)<=GETDATE() AND ProcId=14)
		BEGIN	
			INSERT INTO Cs2Cn_Prk_DailyRetailerDetails
			(
				DistCode,
				RtrId,
				RtrCode,
				CmpRtrCode,
				RtrName,
				RtrAddr1,
				RtrAddr2,
				RtrAddr3,
				RtrPINCode,
				RtrChannelCode,
				RtrGroupCode,
				RtrClassCode,
				GeoLevel,
				GeoName,
				RtrStatus,
				RegDate,
				RtrUploadStatus,
				UploadedDate,
				UploadFlag
			)
			SELECT
				@DistCode,
				R.RtrId,
				R.RtrCode,
				R.CmpRtrCode,
				R.RtrName,
				R.RtrAdd1,
				R.RtrAdd2,
				R.RtrAdd3,
				R.RtrPinNo,
				'' AS CtgCode,
				'' AS CtgCode,
				'' AS ValueClassCode,
				'' AS GeoLevelName,
				'' AS GeoName,
				(CASE RtrStatus WHEN 1 THEN 'Active' ELSE 'InActive' END) AS RtrStatus,	
				RtrRegDate,
				R.Upload,
				GETDATE(),
				'N'				
			FROM Retailer R  		
				
			UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,ETL.RtrClassCode=RVC.ValueClassCode
			FROM Cs2Cn_Prk_DailyRetailerDetails ETL,
			(
				SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode ,RVC.ValueClassCode
				FROM
				RetailerValueClassMap RVCM ,
				RetailerValueClass RVC	,
				RetailerCategory RC ,
				RetailerCategoryLevel RCL,
				RetailerCategory RC1,
				Retailer R  		
			WHERE
				R.Rtrid = RVCM.RtrId 
				AND	RVCM.RtrValueClassId = RVC.RtrClassId 
				AND	RVC.CtgMainId=RC.CtgMainId 
				AND	RCL.CtgLevelId=RC.CtgLevelId 
				AND	RC.CtgLinkId = RC1.CtgMainId 
			) AS RVC
			WHERE ETL.RtrId=RVC.RtrId
			
			UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoName=Geo.GeoName
			FROM Cs2Cn_Prk_DailyRetailerDetails ETL,
			(
				SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
				ISNULL(G.GeoName,'') AS GeoName
				FROM			
				Retailer R  		
				LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId  
			) AS Geo 
			WHERE ETL.RtrId=Geo.RtrId	

			UPDATE DayEndProcess SET NextUpDate=DATEADD(DAY,@Days,NextUpDate) WHERE ProcId=14
		END		
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClaimSettlement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClaimSettlement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClaimSettlement 0
SELECT * FROM Cn2Cs_Prk_ClaimSettlement
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ClaimSettlement]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClaimSettlement
* PURPOSE		: To Download the Claim Settlement details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 31/03/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @Taction  			INT
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @DebitNoteNumber	NVARCHAR(500)
	DECLARE @CrDbNoteDate		DATETIME
	DECLARE @CrDbNoteReason		NVARCHAR(500)
	DECLARE @CreditNoteNumber	NVARCHAR(500)
	DECLARE @SpmId				INT
	DECLARE @DebitNo			NVARCHAR(500)
	DECLARE @CreditNo			NVARCHAR(500)
	DECLARE @ClaimNumber		NVARCHAR(500)
	DECLARE @ClmId				INT
	DECLARE @AccCoaId			INT
	DECLARE @ClmGroupId			INT
	DECLARE @ClmGroupNumber		NVARCHAR(500)
	DECLARE @CrDbNoteAmount		NUMERIC(38,6)
	DECLARE @CmpId				INT
	DECLARE @VocNo				NVARCHAR(500)
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimToAvoid	
	END
	CREATE TABLE ClaimToAvoid
	(
		ClaimRefNo	 NVARCHAR(50),
		CreditNoteNo NVARCHAR(50)
	)
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlement
	WHERE ISNULL(ClaimRefNo,'')='' )
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CreditNoteNo)
		SELECT ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(ClaimRefNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','ClaimRefNo','Claim Ref No should not be empty for :'--+CreditNoteNo
		FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(ClaimRefNo,'')=''
	END
	IF NOT EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlement
	WHERE ISNULL(CAST(CreditDebitNoteAmt AS NUMERIC(38,6)),0)=0)
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CreditNoteNo)
		SELECT ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(CAST(CreditDebitNoteAmt AS NUMERIC(38,6)),0)=0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Amount','Amount should be greater than zero for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(CAST(CreditDebitNoteAmt AS NUMERIC(38,6)),0)=0
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlement
	WHERE ISNULL(CreditNoteNo,'')='' OR ISNULL(DebitNoteNo,'')='')
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CreditNoteNo)
		SELECT ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(CreditNoteNo,'')='' OR ISNULL(DebitNoteNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Credit/Debite Note No','Credit/Debite Note No should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(CreditNoteNo,'')='' OR ISNULL(DebitNoteNo,'')=''
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlement
	WHERE ISNULL(CreditDebitNoteReason,'')='')
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CreditNoteNo)
		SELECT ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(CreditDebitNoteReason,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Reason','Reason should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(CreditDebitNoteReason,'')=''
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlement
	WHERE ISNULL(CreditDebitNoteDate,'')='')
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CreditNoteNo)
		SELECT ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(CreditDebitNoteDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Date should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlement
		WHERE ISNULL(CreditDebitNoteDate,'')=''
	END
	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlement WHERE ClaimRefNo NOT IN
	(SELECT B.RefCode FROM ClaimSheetDetail B))
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CreditNoteNo)
		SELECT ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlement WHERE ClaimRefNo NOT IN
		(SELECT B.RefCode FROM ClaimSheetDetail B)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Claim Reference Number :'+ClaimRefNo+'does not exists'
		FROM Cn2Cs_Prk_ClaimSettlement WHERE ClaimRefNo NOT IN
		(SELECT B.RefCode FROM ClaimSheetDetail B)
	END
	DECLARE Cur_ClaimSettlement CURSOR	
	FOR SELECT  ISNULL([ClaimRefNo],''),ISNULL([CreditNoteNo],'0'),ISNULL([DebitNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CreditDebitNoteDate],121),
	CAST(ISNULL([CreditDebitNoteAmt],0)AS NUMERIC(38,6)),
	ISNULL([CreditDebitNoteReason],'')
	FROM Cn2Cs_Prk_ClaimSettlement WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CreditNoteNo NOT IN
	(SELECT ClaimRefNo+'~'+CreditNoteNo FROM ClaimToAvoid)	
	OPEN Cur_ClaimSettlement
	FETCH NEXT FROM Cur_ClaimSettlement INTO @ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,
	@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @ErrStatus=1
		SELECT @ClmId=B.ClmId FROM ClaimSheetDetail B INNER JOIN ClaimSheetHd A ON A.ClmId=B.ClmId
		WHERE B.RefCode=@ClaimNumber
		SELECT @ClmGroupId=ClmGrpId,@ClmGroupNumber=ClmCode,@CmpId=CmpId FROM ClaimSheetHd WHERE ClmId=@ClmId
		SELECT @AccCoaId=CoaId FROM ClaimGroupMaster WHERE ClmGrpId=@ClmGroupId
		SELECT @SpmId=SpmId FROM Supplier WHERE SpmDefault=1 AND CmpId=@CmpId
		IF @SpmId=0
		BEGIN
			SET @ErrDesc = 'Default Supplier does not exists'
			INSERT INTO Errorlog VALUES (8,'Claim Settlement','Supplier',@ErrDesc)
			SET @Po_ErrNo=1	
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF @DebitNoteNumber = '0' AND @CreditNoteNumber<> '0'
			BEGIN
				SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteSupplier','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
				
				INSERT INTO CreditNoteSupplier(CrNoteNumber,CrNoteDate,SpmId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,CrNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@CreditNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,16,
				@CreditNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')
				UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteSupplier' AND Fldname = 'CrNoteNumber'
				EXEC Proc_VoucherPosting 32,1,@CreditNo,3,6,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
				
				IF @ErrStatus<>1
				BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Credit Note Voucher Posting Failed for Claim Ref No:' + @ClaimNumber
					INSERT INTO Errorlog
					VALUES (9,'Claim Settlement','Credit Note Voucher Posting',@ErrDesc)
				END
				IF @Po_ErrNo=0
				BEGIN
					SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=6
							AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)
					IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
					BEGIN
						EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
					END
					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,CrDbmode=2,CrDbStatus=1,CrDbNotenumber=@CreditNo,Status=1
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber
					UPDATE Cn2Cs_Prk_ClaimSettlement SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber
				END
			END					
			ELSE IF @DebitNoteNumber <> '0' AND @CreditNoteNumber= '0'
			BEGIN
				SELECT @DebitNo=dbo.Fn_GetPrimaryKeyString('DebitNoteSupplier','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
				INSERT INTO DebitNoteSupplier(DbNoteNumber,DbNoteDate,SpmId,CoaId,ReasonId,Amount,DbAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,DbNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@DebitNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,16,
				@DebitNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')
				UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteSupplier' AND Fldname = 'DbNoteNumber'
			
				EXEC Proc_VoucherPosting 33,1,@DebitNo,3,7,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
				
				IF @ErrStatus<>1
				BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Debit Note Voucher Posting Failed'
					INSERT INTO Errorlog VALUES (10,'Claim Settlement','Debit Note Voucher Posting',@ErrDesc)
				END
		
				IF @Po_ErrNo=0
				BEGIN
					SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=7
					AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)
					IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
					BEGIN
						EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
					END
					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,RecommendedAmount=@CrDbNoteAmount,CrDbmode=1,CrDbStatus=1,CrDbNotenumber=@DebitNo,Status=1
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber
					UPDATE Cn2Cs_Prk_ClaimSettlement SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber
				END
			END	
		END
		FETCH NEXT FROM Cur_ClaimSettlement INTO  @ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
END
CLOSE Cur_ClaimSettlement
DEALLOCATE Cur_ClaimSettlement
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-009

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
			Discount		NVARCHAR(200)
		)
		DELETE FROM @TaxSettingTable
		INSERT INTO @TaxSettingTable
		SELECT DISTINCT TC.TaxId, ISNULL(ETL1.TaxGroupCode,''),ISNULL(ETL1.Type,''),
		ISNULL(ETL1.PrdTaxGroupCode,''),ISNULL(TC.TaxCode,''),ISNULL(ETL1.Percentage,0),
		ISNULL(ETL1.ApplyOn,'None'),ISNULL(ETL1.Discount,'None') FROM
		(SELECT ISNULL(ETL.TaxGroupCode,'') AS TaxGroupCode,ISNULL(ETL.Type,'') AS Type,ISNULL(ETL.TaxCode,'') AS TaxCode,
		ISNULL(ETL.PrdTaxGroupCode,'') AS PrdTaxGroupCode,
		ISNULL(ETL.Percentage,0) AS Percentage,ISNULL(ETL.ApplyOn,'') AS ApplyOn,ISNULL(ETL.Discount,'') AS Discount
		FROM Etl_Prk_TaxSetting ETL
		WHERE DownloadFlag='D' AND TaxGroupCode=@TaxGroupCode AND PrdTaxGroupCode=@PrdTaxGroupCode) ETL1
		RIGHT OUTER JOIN TaxConfiguration TC ON TC.TaxCode=ETL1.TaxCode
		SET @RowId=0
		DECLARE Cur_TaxSettingDetail CURSOR		--TaxSettingDetail Cursor
		FOR SELECT TaxGrpCode,Type,TaxPrdGrpCode,TaxCode,Percentage,Applyon,Discount
		FROM @TaxSettingTable Order By TaxId
		OPEN Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount
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

			FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount
		END
		CLOSE Cur_TaxSettingDetail
		DEALLOCATE Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	END
	CLOSE Cur_TaxSettingMaster
	DEALLOCATE Cur_TaxSettingMaster	
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_UploadArchiving]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_UploadArchiving]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_Cs2Cn_UploadArchiving 0
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_UploadArchiving]
(
	@PO_ErrNo INT Output
)
AS
/*********************************
* PROCEDURE	: Proc_Cs2Cn_UploadArchiving
* PURPOSE	: To Archive the uploaded data
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 03/02/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @SeqNo INT
	DECLARE @PrkTable VARCHAR(200)
	DECLARE @StrQry VARCHAR(8000)
	SET @PO_ErrNo=0
	SET @PrkTable = ''
	SET @StrQry = ''
	SELECT @SeqNo = MAX(SequenceNo) FROM Tbl_UploadIntegration
	WHILE (@SeqNo > 0)
	BEGIN
		SELECT  @PrkTable  = ISNULL(PrkTableName,'') FROM Tbl_UploadIntegration WHERE SequenceNo =  @SeqNo
		IF @PrkTable<>''
		BEGIN
			IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'['+@PrkTable+'_Archive'+']') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
			BEGIN
				
				SET @StrQry = 'DELETE FROM '+@PrkTable+'_Archive WHERE UploadedDate<='''+ CONVERT(NVARCHAR(10),DATEADD(DAY,-365,GETDATE()),121) + ''''				
				EXEC(@StrQry)		

				SET @StrQry = 'INSERT INTO '+@PrkTable+'_Archive SELECT *,GETDATE() FROM ' + @PrkTable + ' WHERE UploadFlag = ''Y'''
				EXEC(@StrQry)		
			END
		END
		SET @SeqNo = @SeqNo - 1
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-011

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

	SELECT @SqlStr1='INSERT INTO TBL_GR_BUILD_PH (PrdId,ProductCode,ProductDescription,'+CmpPrdCtgName +'_Id,'+CmpPrdCtgName+'_Code,'+CmpPrdCtgName +'_Caption)' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@PHLevel
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

--SRF-Nanda-165-012

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GR_Build_RH]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GR_Build_RH]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_GR_Build_RH

CREATE PROCEDURE [dbo].[Proc_GR_Build_RH]
AS
/*********************************
* PROCEDURE	: Proc_GR_Build_RH
* PURPOSE	: House Keeping for Retailer Hierarchy
* CREATED	: ShyamSundar.N
* CREATED DATE	: 12/02/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}

*********************************/
BEGIN
	IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TBL_GR_BUILD_RH') DROP TABLE TBL_GR_BUILD_RH
	CREATE TABLE TBL_GR_BUILD_RH
	(
		RtrId INT,
		RtrCode NVARCHAR(100),
		RtrNm NVARCHAR(200),
		Hierarchy1 INT ,
		Hierarchy1Cap NVARCHAR(100),
		Hierarchy2 INT ,
		Hierarchy2Cap NVARCHAR(100),
		Hierarchy3 INT ,
		Hierarchy3Cap NVARCHAR(100),
		HashProducts NVARCHAR(1000)
	)

	--SELECT * FROM RetailerValueClassMap
	--SELECT * FROM RetailerValueClass
	--SELECT * FROM RetailerCategory

	INSERT INTO TBL_GR_BUILD_RH SELECT A.RtrId,RtrCode,RtrName,RtrClassId,ValueClassCode+':'+ValueClassName,CtgMainId,'',0,'','' 
	FROM Retailer A,RetailerValueClassMap B,RetailerValueClass C
	WHERE A.RtrId=B.RtrId AND B.RtrValueClassId=C.RtrClassId

	UPDATE A
	SET Hierarchy2Cap=CTGCODE+':'+CtgName,Hierarchy3=CtgLinkId
	FROM TBL_GR_BUILD_RH A,RetailerCategory B WHERE A.Hierarchy2=CtgMainId

	UPDATE A
	SET Hierarchy3Cap=CTGCODE+':'+CtgName
	FROM TBL_GR_BUILD_RH A,RetailerCategory B WHERE A.Hierarchy3=CtgMainId

	UPDATE TBL_GR_BUILD_RH
	SET HashProducts = Hierarchy1Cap+Hierarchy2Cap+Hierarchy3Cap
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-013

UPDATE Counters SET CurrValue=A.ClmGrpId 
FROM (SELECT ISNULL(MAX(ClmGrpId),0) AS ClmGrpId  FROM ClaimGroupMaster WHERE ClmGrpId<10001) AS A
WHERE TabName='ClaimGroupMaster' AND FldName='ClmGrpId'


--SRF-Nanda-165-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeOnAnotherPrd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeOnAnotherPrd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeOnAnotherPrd 0
ROLLBACK TRANSACTION
*/


CREATE                    PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeOnAnotherPrd]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeOnAnotherPrd
* PURPOSE: To Insert and Update records Of Scheme On Another Products
* CREATED: Boopathy.P on 06/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrDesc AS VARCHAR(1000)
	DECLARE @TabName AS VARCHAR(50)
	DECLARE @GetKey AS INT
	DECLARE @GetKeyStr AS NVARCHAR(200)
	DECLARE @Taction AS INT
	DECLARE @sSQL AS VARCHAR(4000)
	DECLARE @iCnt		AS INT
	DECLARE @SchCode 	AS VARCHAR(100)
	DECLARE @SchCode1 	AS VARCHAR(100)
	DECLARE @CmpCode 	AS VARCHAR(50)
	DECLARE @SchLevelMode	AS VARCHAR(50)
	DECLARE @SchLevel	AS VARCHAR(50)
	DECLARE @SlabCode	AS VARCHAR(50)
	DECLARE @SlabCode1	AS VARCHAR(50)
	DECLARE @SchType	AS VARCHAR(50)
	DECLARE @Range		AS VARCHAR(50)
	DECLARE @PrdType	AS VARCHAR(50)
	DECLARE @PrdCode	AS VARCHAR(50)
	DECLARE @PurQty		AS VARCHAR(50)
	DECLARE @PurFrmQty	AS VARCHAR(50)
	DECLARE @PurUom		AS VARCHAR(50)
	DECLARE @PurToQty	AS VARCHAR(50)
	DECLARE @PurToUom	AS VARCHAR(50)
	DECLARE @PurofEveryQty	AS VARCHAR(50)
	DECLARE @PurofUom	AS VARCHAR(50)
	DECLARE @DiscPer	AS VARCHAR(50)
	DECLARE @FlatAmt	AS VARCHAR(50)
	DECLARE @Points		AS VARCHAR(50)
	DECLARE @SchWithPrd	AS INT
	DECLARE @SLevel		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @CmpId		AS INT
	DECLARE @SchTypeId	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @SlabId		AS INT
	DECLARE @SlabId1	AS INT
	DECLARE @RangeId	AS INT
	DECLARE @SchLevelModeId	AS INT
	DECLARE @PrdTypeId	AS INT
	DECLARE @PrdId		AS INT
	DECLARE @PurUomId	AS INT
	DECLARE @ToUomId	AS INT
	DECLARE @ForEveryUomId	AS INT

	SET @TabName = 'Etl_Prk_Scheme_OnAnotherPrd'
	SET @Po_ErrNo =0
	SET @iCnt=0
	
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE Cur_SchOnAnotherPrdHd CURSOR
	FOR SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
	ISNULL(SlabId,'') AS SlabId,
	ISNULL(SchType,'') AS SchType,
	ISNULL(SchLevel,'') AS SchLevel,
	ISNULL(SchLevelMode,'') AS SchLevelMode,
	ISNULL(Range,'') AS Range
	FROM Etl_Prk_Scheme_OnAnotherPrd
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	OPEN Cur_SchOnAnotherPrdHd
	FETCH NEXT FROM Cur_SchOnAnotherPrdHd INTO @SchCode,@SlabCode, @SchType, @SchLevel, @SchLevelMode,@Range
	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @Po_ErrNo =0

		SET @Taction = 2
		SET @SchWithPrd=0
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SlabCode))= ''
		BEGIN
			SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Slab',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchType))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (3,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchLevel))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (4,@TabName,'Scheme Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchLevelMode))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level Mode should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (5,@TabName,'Scheme Level Mode',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))<> 'UDC') AND (UPPER(LTRIM(RTRIM(@SchLevelMode)))<> 'PRODUCT'))
		BEGIN
			SET @ErrDesc = 'Selection Mode should be (UDC OR PRODUCT) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (6,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF  LTRIM(RTRIM(@Range))<> ''
		BEGIN
			IF ((UPPER(LTRIM(RTRIM(@Range)))<> 'YES') AND (UPPER(LTRIM(RTRIM(@Range)))<> 'NO'))
			BEGIN
				SET @ErrDesc = 'Range Based Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (6,@TabName,'Range Based Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE SM.CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not available for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (7,@TabName,'Company Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SET @Taction = 1
	
					IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (9,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
				ELSE
				IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (10,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
					WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					
				END
			END
		END
		IF @Po_ErrNo=0 	
		BEGIN
			IF EXISTS (SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
			AND CmpPrdCtgName=LTRIM(RTRIM(@SchLevel)))
			BEGIN
				SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
				AND CmpPrdCtgName=LTRIM(RTRIM(@SchLevel))
			END
			ELSE
			BEGIN
				SET @ErrDesc = 'Scheme Level not found for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchType))) = 'QUANTITY'
			BEGIN
				SET @SchTypeId=1
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SchType))) = 'AMOUNT'
			BEGIN
				SET @SchTypeId=2
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SchType))) = 'WEIGHT'
			BEGIN
				SET @SchTypeId=3
			END
			IF LTRIM(RTRIM(@Range)) <> ''
			BEGIN
				IF ((UPPER(LTRIM(RTRIM(@Range)))= 'YES'))
				BEGIN
					SET @RangeId=1
				END
				ELSE IF ((UPPER(LTRIM(RTRIM(@Range)))= 'NO'))
				BEGIN
					SET @RangeId=0
				END
			END
			ELSE
			BEGIN
				SET @RangeId=0
			END
			IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))= 'UDC'))
			BEGIN
				SET @SchLevelModeId=1
			END
			ELSE IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))= 'PRODUCT'))
			BEGIN
				SET @SchLevelModeId=0
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS (SELECT A.SchId FROM SchemeMaster A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode)))
			BEGIN
				IF EXISTS (SELECT A.SchId FROM SchemeAnotherPrdHd A INNER JOIN SchemeMaster B ON
				A.SchId=B.SchId WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode))
				AND A.SlabId=LTRIM(RTRIM(@SlabCode)))
				BEGIN
					SET @Taction = 2
					SET @SchWithPrd=1
				END
				ELSE
				BEGIN
					SET @Taction = 1
					SET @SchWithPrd=1
					INSERT INTO SchemeAnotherPrdHd (SchId,SlabId,SchType,SchLevel,SchLevelMode,
						    Range,ApplySch,Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
					(@GetKey,@SlabId,@SchTypeId,@CmpPrdCtgId,@SchLevelModeId,@RangeId,0,
					 1,1,GETDATE(),1,GETDATE())
				END
			END
			ELSE IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeMaster_Temp A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode)) AND A.UpLoadFlag='N')
			BEGIN
				IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeAnotherPrdHd_Temp A INNER JOIN Etl_Prk_SchemeAnotherPrdHd_Temp B ON
				A.CmpSchCode=B.CmpSchCode WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode))
				AND A.SlabId=LTRIM(RTRIM(@SlabCode)))
				BEGIN
					SET @Taction = 2
					SET @SchWithPrd=2
				END
				ELSE
				BEGIN
					SET @Taction = 1
					SET @SchWithPrd=2
					INSERT INTO Etl_Prk_SchemeAnotherPrdHd_Temp (CmpSchCode,SlabId,SchType,SchLevel,SchLevelMode,Range)						
						VALUES (@SchCode,@SlabId,@SchTypeId,@CmpPrdCtgId,@SchLevelModeId,@RangeId)
				END
			END
--SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
--					ISNULL(SlabId,'') AS SlabId,
--					ISNULL(Range,'') AS Range,
--					ISNULL(PrdType,'') AS PrdType,
--					ISNULL(PrdCode,'') AS PrdCode,
--					ISNULL(PurQty,'0') AS PurQty,
--					ISNULL(PurFrmQty,'0') AS PurFrmQty,
--					ISNULL(PurUom ,'0') AS PurUom,
--					ISNULL(PurToQty ,'0') AS PurToQty,
--					ISNULL(PurToUom,'0') AS PurToUom,
--					ISNULL(PurofEveryQty ,'0') AS PurofEveryQty,
--					ISNULL(PurofUom ,'0') AS PurofUom,
--					ISNULL(DiscPer,'0') AS DiscPer,
--					ISNULL(FlatAmt,'0') AS FlatAmt,
--					ISNULL(Points,'0') AS Points
--					FROM Etl_Prk_Scheme_OnAnotherPrd WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
--					AND SlabId= LTRIM(RTRIM(@SlabCode))
			DECLARE Cur_SchOnAnotherPrdDt CURSOR
			FOR SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
					ISNULL(SlabId,'') AS SlabId,
					ISNULL(Range,'') AS Range,
					ISNULL(PrdType,'') AS PrdType,
					ISNULL(PrdCode,'') AS PrdCode,
					ISNULL(PurQty,'0') AS PurQty,
					ISNULL(PurFrmQty,'0') AS PurFrmQty,
					ISNULL(PurUom ,'0') AS PurUom,
					ISNULL(PurToQty ,'0') AS PurToQty,
					ISNULL(PurToUom,'0') AS PurToUom,
					ISNULL(PurofEveryQty ,'0') AS PurofEveryQty,
					ISNULL(PurofUom ,'0') AS PurofUom,
					ISNULL(DiscPer,'0') AS DiscPer,
					ISNULL(FlatAmt,'0') AS FlatAmt,
					ISNULL(Points,'0') AS Points
					FROM Etl_Prk_Scheme_OnAnotherPrd WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					AND SlabId= LTRIM(RTRIM(@SlabCode))
			OPEN Cur_SchOnAnotherPrdDt
			FETCH NEXT FROM Cur_SchOnAnotherPrdDt INTO @SchCode1,@SlabCode1,@Range,@PrdType,@PrdCode,
					@PurQty,@PurFrmQty,@PurUom,@PurToQty,@PurToUom,@PurofEveryQty,@PurofUom
					,@DiscPer, @FlatAmt, @Points
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF LTRIM(RTRIM(@SchCode1))= ''
				BEGIN
					SET @ErrDesc = 'Company Scheme Code should not be blank'
					INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@SlabCode1))= ''
				BEGIN
					SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Slab',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PrdType))= ''
				BEGIN
					SET @ErrDesc = 'Product Type should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Product Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PrdCode))= ''
				BEGIN
					SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Product Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PurQty))= ''
				BEGIN
					SET @ErrDesc = 'Purchase Qty should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Purchase Qty',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PurUom))= ''
				BEGIN
					SET @ErrDesc = 'Purchase Uom should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Purchase Uom',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF (LTRIM(RTRIM(@DiscPer))= '0' AND LTRIM(RTRIM(@FlatAmt))= '0' AND LTRIM(RTRIM(@Points))= '0')
				BEGIN
					SET @ErrDesc = 'Disc % or Flat Amount or Points should not be Zero for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Disc,Flat Amount and Points',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				IF @Po_ErrNo=0
				BEGIN
					IF @ConFig<>1
					BEGIN
						IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE SM.CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not available in Master Table for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (7,@TabName,'Company Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
							SET @Taction = 1
			
							IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
					END
					ELSE
					BEGIN
						IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
							IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (9,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
							CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (10,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
							WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
		
							IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)) AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF LTRIM(RTRIM(@PurofEveryQty))<> ''
						BEGIN
							IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurofUom)))
							BEGIN
								SELECT @ForEveryUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurofUom))
								
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Purchase of every Uom not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Purchase of every Uom',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						BEGIN
							SET @ForEveryUomId=0
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF UPPER(LTRIM(RTRIM(@PrdType)))= 'NO'
						BEGIN
							SET @PrdTypeId =0
						END
						ELSE IF UPPER(LTRIM(RTRIM(@PrdType)))= 'YES'
						BEGIN
							SET @PrdTypeId=1
						END
	
						IF UPPER(LTRIM(RTRIM(@PrdType)))= 'YES'
						BEGIN
							IF EXISTS (SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
							BEGIN
								SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Product Code:'+@PrdCode +' not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE IF UPPER(LTRIM(RTRIM(@PrdType)))= 'NO'
						BEGIN
							IF EXISTS (SELECT PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode=LTRIM(RTRIM(@PrdCode)))
							BEGIN
								SELECT @PrdId=PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode=LTRIM(RTRIM(@PrdCode))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Product Category Value Code:'+@PrdCode +' not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Product Category Value Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurUom)))
						BEGIN
							SELECT @PurUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurUom))
							SET @ToUomId=0
						END
						ELSE
						BEGIN
							SET @ErrDesc = 'Purchase Uom not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Purchase Uom',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF LTRIM(RTRIM(@Range)) <> ''
						BEGIN
							IF UPPER(LTRIM(RTRIM(@Range)))= 'YES'
							BEGIN
								SET @RangeId=1
							END
							ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NO'
							BEGIN
								SET @RangeId=0
							END
						END
						ELSE
						BEGIN
							SET @RangeId=0
						END
	
						IF @RangeId=1
						BEGIN
							IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurToUom)))
							BEGIN
								SELECT @ToUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurToUom))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Purchase Uom not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Purchase Uom',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						BEGIN
							SET @ToUomId=0
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF EXISTS (SELECT A.SchId FROM SchemeMaster A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							IF EXISTS (SELECT A.SchId FROM SchemeAnotherPrdDt A INNER JOIN SchemeMaster B ON
							A.SchId=B.SchId WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode1))
							AND A.SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SET @Taction = 2
							END
							ELSE
							BEGIN
								SET @Taction = 1
							END
						END
						ELSE IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeMaster_Temp A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode1)) AND A.UpLoadFlag='N')
						BEGIN
							IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeAnotherPrdHd_Temp A INNER JOIN Etl_Prk_SchemeMaster_Temp B ON
							A.CmpSchCode=B.CmpSchCode WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode1))
							AND A.SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SET @Taction = 2
							END
							ELSE
							BEGIN
								SET @Taction = 1
							END
						END
					END

					IF @Taction = 1
					BEGIN
						IF @SchWithPrd =1
						BEGIN
							INSERT INTO SchemeAnotherPrdDt (SchId,SlabId,PrdType,PrdId,PurQty,PurFrmQty,PurUomId,PurToQty,
							PurToUomId,PurofEveryQty,PurofUomId,DiscPer,FlatAmt,Points,Availability,
							LastModBy,LastModDate,AuthId,AuthDate) VALUES
							(@GetKey,@SlabId1,@PrdTypeId,@PrdId,@PurQty,@PurFrmQty,@PurUomId,@PurToQty,
							@ToUomId,@PurofEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,CAST(@Points AS NUMERIC(18,0)),1,1,
							GETDATE(),1,GETDATE())
						END
						ELSE IF @SchWithPrd =2
						BEGIN
							INSERT INTO Etl_Prk_SchemeAnotherPrdDt_Temp (CmpSchCode,SlabId,PrdType,PrdId,PrdCode,PurQty,PurFrmQty,
							PurUomId,PurUomCode,PurToQty,PurToUomId,PurToUomCode,PurofEveryQty,PurofUomId,PurofUomCode,
							DiscPer,FlatAmt,Points) VALUES (
							@GetKey,@SlabId1,@PrdTypeId,@PrdId,@PrdCode,@PurQty,@PurFrmQty,@PurUomId,@PurUom,@PurToQty,
							@ToUomId,@PurToUom,@PurofEveryQty,@ForEveryUomId,@PurofUom,@DiscPer,@FlatAmt,CAST(@Points AS NUMERIC(18,0)))
						END
					END
					ELSE IF @Taction = 2
					BEGIN
						IF @SchWithPrd =1
						BEGIN
							UPDATE SchemeAnotherPrdDt Set PrdType=@PrdTypeId,PrdId=@PrdId,PurQty=@PurQty,PurFrmQty=@PurFrmQty,
							PurUomId=@PurUomId,PurToQty=@PurToQty,PurToUomId=@ToUomId,PurofEveryQty=@PurofEveryQty,
							PurofUomId=@ForEveryUomId,DiscPer=@DiscPer,FlatAmt=@FlatAmt,Points=CAST(@Points AS NUMERIC(18,0))
							WHERE SchId=@GetKey AND SlabId=@SlabId1
						END
						ELSE IF @SchWithPrd =2
						BEGIN
							UPDATE Etl_Prk_SchemeAnotherPrdDt_Temp SET PrdType=@PrdTypeId,PrdId=@PrdId,PrdCode=@PrdCode,PurQty=@PurQty,
							PurFrmQty=@PurFrmQty,PurUomId=@PurUomId,PurUomCode=@PurUom,PurToQty=@PurToQty,
							PurToUomId=@ToUomId,PurToUomCode=@PurToUom,PurofEveryQty=@PurofEveryQty,
							PurofUomId=@ForEveryUomId,PurofUomCode=PurofUomCode,DiscPer=@DiscPer,
							FlatAmt=@FlatAmt,Points=CAST(@Points AS NUMERIC(18,0))
							WHERE CmpSchCode=@SchCode1 AND SlabId=@SlabId1
						END
					END
				END
				FETCH NEXT FROM Cur_SchOnAnotherPrdDt INTO @SchCode1,@SlabCode1,@Range,@PrdType,@PrdCode,
				@PurQty,@PurFrmQty,@PurUom,@PurToQty,@PurToUom,@PurofEveryQty,@PurofUom,@DiscPer,@FlatAmt,@Points
			END

			CLOSE Cur_SchOnAnotherPrdDt
			DEALLOCATE Cur_SchOnAnotherPrdDt
		END
		FETCH NEXT FROM Cur_SchOnAnotherPrdHd INTO  @SchCode,@SlabCode,@SchType,@SchLevel,@SchLevelMode,@Range
	END

	CLOSE Cur_SchOnAnotherPrdHd
	DEALLOCATE Cur_SchOnAnotherPrdHd

	UPDATE Etl_Prk_SchemeHD_Slabs_Rules SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_Scheme_OnAttributes SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_Scheme_Free_Multi_Products SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_Scheme_OnAnotherPrd SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_Scheme_RetailerLevelValid SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_SchemeProducts_Combi SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)	

	UPDATE Etl_Prk_Scheme_OnAnotherPrd SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-015

if exists (select * from dbo.sysobjects where id = object_id(N'[BillAppliedSchemeHdUnDelivered]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [BillAppliedSchemeHdUnDelivered]
GO

CREATE TABLE [dbo].[BillAppliedSchemeHdUnDelivered]
(
	[SchId] [int] NULL,
	[SchCode] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FlexiSch] [tinyint] NULL,
	[FlexiSchType] [tinyint] NULL,
	[SlabId] [int] NULL,
	[SchemeAmount] [numeric](38, 6) NULL,
	[SchemeDiscount] [numeric](38, 6) NULL,
	[Points] [int] NULL,
	[FlxDisc] [tinyint] NULL,
	[FlxValueDisc] [tinyint] NULL,
	[FlxFreePrd] [tinyint] NULL,
	[FlxGiftPrd] [tinyint] NULL,
	[FlxPoints] [tinyint] NULL,
	[FreePrdId] [int] NULL,
	[FreePrdBatId] [int] NULL,
	[FreeToBeGiven] [int] NULL,
	[GiftPrdId] [int] NULL,
	[GiftPrdBatId] [int] NULL,
	[GiftToBeGiven] [int] NULL,
	[NoOfTimes] [numeric](38, 6) NULL,
	[IsSelected] [tinyint] NULL,
	[SchBudget] [numeric](38, 6) NULL,
	[BudgetUtilized] [numeric](38, 6) NULL,
	[TransId] [tinyint] NULL,
	[Usrid] [int] NULL,
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[SchType] [int] NOT NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-016

if exists (select * from dbo.sysobjects where id = object_id(N'[BilledPrdHdForQPSSchemeUnDelivered]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [BilledPrdHdForQPSSchemeUnDelivered]
GO

CREATE TABLE [dbo].[BilledPrdHdForQPSSchemeUnDelivered]
(
	[RowId] [int] NULL,
	[RtrId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[SelRate] [numeric](18, 6) NULL,
	[BaseQty] [int] NULL,
	[GrossAmount] [numeric](18, 6) NULL,
	[MRP] [numeric](18, 6) NOT NULL,
	[TransId] [tinyint] NULL,
	[Usrid] [int] NULL,
	[ListPrice] [numeric](38, 6) NOT NULL,
	[QPSPrd] [int] NULL,
	[SchId] [int] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-017

if exists (select * from dbo.sysobjects where id = object_id(N'[BilledPrdHdForSchemeUnDelivered]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [BilledPrdHdForSchemeUnDelivered]
GO

CREATE TABLE [dbo].[BilledPrdHdForSchemeUnDelivered]
(
	[RowId] [int] NULL,
	[RtrId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[SelRate] [numeric](18, 6) NULL,
	[BaseQty] [int] NULL,
	[GrossAmount] [numeric](18, 6) NULL,
	[MRP] [numeric](18, 6) NOT NULL,
	[TransId] [tinyint] NULL,
	[Usrid] [int] NULL,
	[ListPrice] [numeric](38, 6) NOT NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill_UnDelivered]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill_UnDelivered]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSSchemeUnDelivered WHERE SchId=28
--SELECT * FROM BillAppliedSchemeHdUnDelivered(NOLOCK)
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
--DELETE FROM BillAppliedSchemeHdUnDelivered
EXEC Proc_ApplyQPSSchemeInBill_UnDelivered 151,947,0,2,2
--SELECT * FROM BilledPrdHdForQPSSchemeUnDelivered
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSSchemeUnDelivered
--SELECT * FROM BillAppliedSchemeHdUnDelivered WHERE TransId = 2 And UsrId = 1
SELECT * FROM BillAppliedSchemeHdUnDelivered
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=30
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
ROLLBACK TRANSACTION
*/
CREATE        Procedure [dbo].[Proc_ApplyQPSSchemeInBill_UnDelivered]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
)
AS
/*********************************
* PROCEDURE	: Proc_ApplyQPSSchemeInBill_UnDelivered
* PURPOSE	: To Apply the QPS Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Thrinath/Nanda
* CREATED DATE	: 27/09/2010
* NOTE		: General SP for Returning the Scheme Details for the Selected QPS Scheme(for Undeliverd Bills also)
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
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
		FlxValueDisc	TINYINT,
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
	DECLARE  @BillAppliedSchemeHdUnDelivered TABLE
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
	DECLARE @TempBillAppliedSchemeHdUnDelivered TABLE
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
--		SELECT '1',* FROM @TempBilled1
	END
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.SumQty),0) AS SchemeOnQty,
			ISNULL(SUM(A.SumValue),0) AS SchemeOnAmount,
			ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(SumInKG),0)
			WHEN 3 THEN ISNULL(SUM(SumInKG),0) END,0) AS SchemeOnKg,
			ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(SumInLitre),0)
			WHEN 5 THEN ISNULL(SUM(SumInLitre),0) END,0) AS SchemeOnLitre,@Pi_SchId
			FROM SalesInvoiceQPSCumulative A (NOLOCK)
			INNER JOIN Product C ON A.PrdId = C.PrdId
			INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
			WHERE A.SchId = @Pi_SchId AND A.RtrId = @Pi_RtrId
			GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
--		SELECT '3',* FROM @TempBilled1
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
--		SELECT '4',* FROM @TempBilled1
		--NNN
		IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
		BEGIN
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
			SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
				-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
				-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
				FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
				AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
		END
--		SELECT '5',* FROM @TempBilled1
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
			ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
			ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
--	SELECT '6',* FROM @TempBilled1
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
--	SELECT * FROM @TempBilled
--	SELECT 'N',@QPSReset
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
		SELECT @SlabId
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
--	SELECT 'N',@QPSResetAvail
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
--		SELECT 'SSSS',* FROM @TempBilledAch
		
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
				SELECT @SlabAssginValue
				WHILE @SlabAssginValue > CAST(0 AS NUMERIC(38,6))
				BEGIN
					SET @AssignQty  = 0
					SET @AssignAmount = 0
					SET @AssignKG = 0
					SET @AssignLitre = 0
					SELECT @SlabAssginValue
					SELECT @FrmSchAchRem
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
--				SELECT 'Slab',@SlabAssginValue 
--				SELECT 'Slab',* FROM BillAppliedSchemeHdUnDelivered
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
--					SELECT 'S1',* FROM @TempRedeem
--					SELECT 'S1',* FROM @TempBilledAch
--					SELECT 'S1',* FROM @TempBilledQPSReset
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
		
		--SELECT * FROM @TempRedeem		
		INSERT INTO BilledPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,
			SumInLitre,UserId,TransId)
		SELECT @Pi_RtrId,@Pi_SchId,PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,
			SchemeOnLitre,@Pi_UsrId,@Pi_TransId FROM @TempRedeem
		--To Store the Gross amount for the Scheme billed Product
		SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempRedeem
		--To Calculate the Scheme Flat Amount and Discount Percentage
		--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
		--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
		INSERT INTO @BillAppliedSchemeHdUnDelivered(SCHID,SCHCODE,FLEXISCH,FLEXISCHTYPE,SLABID,SCHEMEAMOUNT,SCHEMEDISCOUNT,
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
				--((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
				FlatAmt
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
		INSERT INTO @BillAppliedSchemeHdUnDelivered(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
	 		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
	 		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
	 		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
		SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
			@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
			0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
			CASE @SchType
				WHEN 1 THEN
					CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
				WHEN 2 THEN
					CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
				WHEN 3 THEN
					CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
			END as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
			0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
			0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId
			FROM @TempBilled , @TempSchSlabFree
			GROUP BY FreePrdId,FreeQty,ForEveryQty
		--To Calculate the Gift Qty to be given
		INSERT INTO @BillAppliedSchemeHdUnDelivered(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
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
	INSERT INTO BillAppliedSchemeHdUnDelivered(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount),SUM(SchemeDiscount),
		SUM(Points),FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,(FreePrdId) as FreePrdId ,
		FreePrdBatId,SUM(FreeToBeGiven),GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven),SUM(NoOfTimes),
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0 FROM @BillAppliedSchemeHdUnDelivered
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId
		,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
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
		UPDATE BillAppliedSchemeHdUnDelivered SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
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
			COUNT(DISTINCT PrdBatId) FROM BillAppliedSchemeHdUnDelivered
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId
			HAVING COUNT(DISTINCT PrdBatId)> 1

		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
		BEGIN
			INSERT INTO @TempBillAppliedSchemeHdUnDelivered
			SELECT A.* FROM BillAppliedSchemeHdUnDelivered A INNER JOIN @MoreBatch B
			ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId
			WHERE A.SchId=@Pi_SchId AND A.SlabId=@SlabId
			AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND A.FlexiSch<>1
			AND A.PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHdUnDelivered
			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 )
			UPDATE BillAppliedSchemeHdUnDelivered SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHdUnDelivered WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHdUnDelivered WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
			AND SchemeAmount =0
		END
	END

	SELECT @SlabId=SlabId FROM BillAppliedSchemeHdUnDelivered WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHdUnDelivered SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId

	INSERT INTO @QPSGivenFlat
	SELECT SchId,SUM(FlatAmount)
	FROM
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHdUnDelivered) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1 AND FlexiSch=0
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A
	GROUP BY A.SchId

--	SELECT 'N',* FROM @QPSGivenFlat
	UPDATE BillAppliedSchemeHdUnDelivered SET SchemeAmount=SchemeAmount-Amount
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHdUnDelivered.SchId=A.SchId	
	AND BillAppliedSchemeHdUnDelivered.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHdUnDelivered WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHdUnDelivered.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	DECLARE @MSSchId AS INT
	DECLARE @MaxSlabId AS INT
	DECLARE @AmtToReduced AS NUMERIC(38,6)
	DECLARE Cur_QPSSlabs CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHdUnDelivered 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHdUnDelivered WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHdUnDelivered.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN
	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHdUnDelivered WHERE SchId=@MSSchId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
				SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHdUnDelivered 
				WHERE SlabId=@MaxSlabId AND SchId=@MSSchId

				UPDATE BillAppliedSchemeHdUnDelivered SET SchemeAmount=0
				WHERE BillAppliedSchemeHdUnDelivered.SchId=@MSSchId AND BillAppliedSchemeHdUnDelivered.SlabId=@MaxSlabId			
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHdUnDelivered SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHdUnDelivered.SchId=@MSSchId 
			AND BillAppliedSchemeHdUnDelivered.SlabId=@MaxSlabId			
			AND A.SchId=BillAppliedSchemeHdUnDelivered.SchId
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs

	SELECT * FROM BillAppliedSchemeHdUnDelivered
	DELETE FROM BillAppliedSchemeHdUnDelivered WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0
	IF @QPS<>0 AND @QPSReset<>0	
	BEGIN
		DELETE FROM BillAppliedSchemeHdUnDelivered WHERE CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForQPSSchemeUnDelivered WHERE QPSPrd=0 AND SchId=@Pi_SchId) 
		AND SchId=@Pi_SchId AND SchId IN (
		SELECT SchId FROM BillAppliedSchemeHdUnDelivered WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	END
	--Added By Murugan
	IF @QPS<>0
	BEGIN
		DELETE FROM BilledPrdHdForQPSSchemeUnDelivered WHERE Transid=@Pi_TransId and Usrid=@Pi_UsrId AND SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSSchemeUnDelivered(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT RowId,@Pi_RtrId,BP.PrdId,BP.Prdbatid,SelRate,BaseQty,BaseQty*SelRate AS SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,ListPrice,0,@Pi_SchId
		From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId

		IF @FlexiSch=0
		BEGIN
			INSERT INTO BilledPrdHdForQPSSchemeUnDelivered(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB 		
		END
		ELSE
		BEGIN
			INSERT INTO BilledPrdHdForQPSSchemeUnDelivered(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB WHERE CAST(TB.PrdId AS NVARCHAR(10))+'~'+CAST(TB.PrdBatId AS NVARCHAR(10)) IN
			(SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForScheme)		
		END
	END

	DELETE FROM BillAppliedSchemeHdUnDelivered WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND 
	SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId)
	
	--Till Here	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-019

UPDATE CustomUpDownloadCount SET SelectQuery='SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
WHERE UpDownLoad='DownLoad' AND Module='Scheme' AND MainTable='SchemeMaster'

--SRF-Nanda-165-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeSlab]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeSlab]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeSlab 0
--SELECT *  FROM Etl_Prk_SchemeHD_Slabs_Rules
--SELECT * FROM SchemeMaster
SELECT * FROM ErrorLog
SELECT DISTINCT SchId FROM dbo.SchemeSlabs
ROLLBACK TRANSACTION
*/
CREATE     PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeSlab]
(
	@Po_ErrNo INT OUTPUT	
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeSlab 1
* PURPOSE: To Insert and Update Scheme Slab Details
* CREATED: Boopathy.P on 02/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode AS VARCHAR(50)
	DECLARE @SlabCode AS INT 
	DECLARE @FromUOM AS VARCHAR(200)
	DECLARE @FromQty AS NUMERIC(18,6) 
	DECLARE @ToUOM  AS VARCHAR(200)
	DECLARE @ToQty  AS NUMERIC(18,6) 
	DECLARE @ForEveryUOM AS VARCHAR(200)
	DECLARE @ForEveryQty AS NUMERIC(18,6) 
	DECLARE @DiscPer AS NUMERIC(5,2) 
	DECLARE @FlatAmt AS NUMERIC(18,6) 
	DECLARE @Points  AS NUMERIC(18,6) 
	DECLARE @FlexiFree AS NUMERIC(18,6) 
	DECLARE @FlexiGift AS NUMERIC(18,6) 
	DECLARE @FlexiDisc AS NUMERIC(18,6) 
	DECLARE @FlexiFlat AS NUMERIC(18,6) 
	DECLARE @FlexiPoints AS INT
	DECLARE @TempRange AS NUMERIC(18,6) 
	DECLARE @CmpId  AS INT
	DECLARE @SchLevelId AS INT
	DECLARE @SchType AS INT
	DECLARE @FlexiId AS INT
	DECLARE @RangeId AS INT
	DECLARE @FlexiType AS INT
	DECLARE @CombiSch AS INT
	DECLARE @FlexiCnt AS INT
	DECLARE @FromUomId AS INT
	DECLARE @ToUomId AS INT
	DECLARE @ForEveryUomId AS INT
	DECLARE @ChkCount AS INT
	DECLARE @PurOfEvery	 AS INT
	DECLARE @ErrDesc  AS VARCHAR(1000)
	DECLARE @TabName  AS VARCHAR(50)
	DECLARE @GetKey  AS VARCHAR(50)
	DECLARE @Taction  AS INT
	DECLARE @MAXSLABID AS INT
	DECLARE @sSQL   AS VARCHAR(4000)
	DECLARE @MaxSchLevelId	AS INT
	DECLARE @CntVal	As	INT
	DECLARE @TempStr	AS Varchar(4000)
	DECLARE @TempStr1	AS Varchar(4000)
	DECLARE @SLevel		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @MaxDisc  AS NUMERIC(18,2)
	DECLARE @MinDisc  AS NUMERIC(18,2)
	DECLARE @MaxValue  AS NUMERIC(18,2)
	DECLARE @MinValue  AS NUMERIC(18,2)
	DECLARE @MaxPoints  AS INT
	DECLARE @MinPoints  AS INT
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SlabNotAppl AS INT

	Create Table  #TempTbl
	(
		PrdUnitId	INT,
		PrdUnitGrpId	INT,
		PrdUnitCode	Varchar(50)
	)

	SET @TabName = 'Etl_Prk_SchemeHD_Slabs_Rules'
	SET @Po_ErrNo =0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'

	DECLARE Cur_SchemeSlabDt CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],
	ISNULL([SlabId],0) AS [SlabId],
	ISNULL([Uom],'0') AS [From Uom],
	CASE ISNULL([FromQty],'') WHEN '' THEN 0 ELSE CAST([FromQty] AS NUMERIC(18,2)) END AS [From Qty],
	ISNULL([ToUom],'0') AS [To Uom],
	CASE ISNULL([ToQty],'') WHEN '' THEN 0 ELSE CAST([ToQty] AS NUMERIC(18,2)) END AS [To Qty],
	ISNULL([ForEveryUom],'0') AS [For Every Uom],
	CASE ISNULL([ForEveryQty],'') WHEN '' THEN 0 ELSE CAST([ForEveryQty] AS NUMERIC(18,2)) END AS [For Every Qty],
	CASE ISNULL([DiscPer],'') WHEN '' THEN 0 ELSE CAST([DiscPer] AS NUMERIC(5,2)) END AS [Disc %],
	CASE ISNULL([FlatAmt],'') WHEN '' THEN 0 ELSE CAST([FlatAmt] AS NUMERIC(18,2)) END AS [Flat Amount],
	CASE ISNULL([Points],'') WHEN '' THEN 0 ELSE CAST([Points] AS NUMERIC(18,2)) END AS [Point],
	CASE ISNULL([FlxFreePrd],'') WHEN '' THEN 0 ELSE [FlxFreePrd] END AS [Flexi Free],
	CASE ISNULL([FlxGiftPrd],'') WHEN '' THEN 0 ELSE [FlxGiftPrd] END AS [Flexi Gift],
	CASE ISNULL([FlxDisc],'') WHEN '' THEN 0 ELSE [FlxDisc] END AS [Flexi Disc],
	CASE ISNULL([FlxValueDisc],'') WHEN '' THEN 0 ELSE [FlxValueDisc] END AS [Flexi Flat],
	CASE ISNULL([FlxPoints],'') WHEN '' THEN 0 ELSE [FlxPoints] END AS [Flexi Points],
	CASE ISNULL([MaxDiscount],'') WHEN '' THEN 0 ELSE CAST([MaxDiscount] AS NUMERIC(18,2)) END AS [Max Discount],
	CASE ISNULL([MinDiscount],'') WHEN '' THEN 0 ELSE CAST([MinDiscount] AS NUMERIC(18,2)) END AS [Min Discount],
	CASE ISNULL([MaxValue],'') WHEN '' THEN 0 ELSE CAST([MaxValue] AS NUMERIC(18,2)) END AS [Max Value],
	CASE ISNULL([MinValue],'') WHEN '' THEN 0 ELSE CAST([MinValue] AS NUMERIC(18,2)) END AS [Min Value],
	CASE ISNULL([MaxPoints],'') WHEN '' THEN 0 ELSE CAST([MaxPoints] AS NUMERIC(18,2)) END AS [Max Points],
	CASE ISNULL([MinPoints],'') WHEN '' THEN 0 ELSE CAST([MinPoints] AS NUMERIC(18,2)) END AS [Min Points]
	FROM Etl_Prk_SchemeHD_Slabs_Rules 
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code],[SlabId]
	OPEN Cur_SchemeSlabDt
	FETCH NEXT FROM Cur_SchemeSlabDt INTO @SchCode,@SlabCode,@FromUOM,@FromQty,@ToUOM,@ToQty,@ForEveryUOM,
	@ForEveryQty,@DiscPer,@FlatAmt,@Points,@FlexiFree,@FlexiGift,@FlexiDisc,@FlexiFlat,@FlexiPoints,
	@MaxDisc,@MinDisc,@MaxValue,@MinValue,@MaxPoints,@MinPoints
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @CntVal=1
		SET @FromUomId=0
		SET @ToUomId=0
		SET @ForEveryUomId=0
		SET @TempStr=''
		SET @TempStr1=''

		DELETE FROM #TempTbl
		SELECT @MAXSLABID=MAX([SlabId])  FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE  [CmpSchCode]=@SchCode
		SET @Taction = 2

		SET @Po_ErrNo =0

		---->Modified By Nanda on 16/09/2009
		SET @SlabNotAppl=0
		IF (LTRIM(RTRIM(@SlabCode))= '---' OR LTRIM(RTRIM(@SlabCode))= '0')
		BEGIN						
			SET @SlabNotAppl=1
		END
		---->Till Here

		IF @SlabNotAppl=0
		BEGIN
			IF LTRIM(RTRIM(@SchCode))= ''
			BEGIN
				SET @ErrDesc = 'Company Scheme Code should not be blank'
				INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LEN(LTRIM(RTRIM(@SlabCode)))= 0
			BEGIN
				SET @ErrDesc = 'Slab Details should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			IF @Po_ErrNo=0
			BEGIN
				IF @ConFig<>1
				BEGIN
					IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
						@RangeId=Range,@CombiSch=CombiSch,@PurOfEvery=PurofEvery,@CmpPrdCtgId=SchLevelId  FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
						@RangeId=Range,@CombiSch=CombiSch,@PurOfEvery=PurofEvery,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END
					ELSE
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
						BEGIN
							IF NOT EXISTS(SELECT [CmpSchCode] FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE
							[CmpSchCode]=LTRIM(RTRIM(@SchCode)))
							BEGIN
								SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode +' in table Etl_Prk_SchemeHD_Slabs_Rules '
								INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
								B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
								SELECT @SchLevelId=C.CmpPrdCtgId,@FlexiId=A.FlexiSch,@CombiSch=A.CombiSch,
								@FlexiType=A.FlexiSchType,@SchType=A.SchType,@RangeId=A.Range
								FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
								INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
								AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
							END
						END
					ELSE
					BEGIN
						SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,
						@SchType=SchType,@RangeId=Range,@CombiSch=CombiSch,@CmpPrdCtgId=SchLevelId FROM Etl_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
				END
			END
			IF @Po_ErrNo=0
			BEGIN
				IF @FlexiId=1
				BEGIN
					SET @FlexiCnt=0
					IF LTRIM(RTRIM(@FlexiFree))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiGift))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiDisc))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiFlat))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiPoints))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF @FlexiCnt=5
					BEGIN
						SET @ErrDesc = 'Select Only Flexi Items for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'FLEXI SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
				IF @RangeId=1
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						IF LTRIM(RTRIM(@ToUOM))='0'
						BEGIN
							IF 	@MAXSLABID <> @SlabCode
							BEGIN
								SET @ErrDesc = 'To UOM Should Not Be Blank for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END    
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @MAXSLABID =@SlabCode
					BEGIN
						IF CONVERT(INT,@ToQty)>0
						BEGIN
							SET @ErrDesc = 'To Qty Should be ZERO for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
				IF @CombiSch=1
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							 SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
						END
						IF LTRIM(RTRIM(@ForEveryUOM))='0'
						BEGIN
							SET @ErrDesc = 'For Every UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							 SELECT @ForEveryUOMId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @PurOfEvery=1
					BEGIN
						IF LTRIM(RTRIM(@ForEveryQty))='0'
						BEGIN
							SET @ErrDesc = 'For Every Qty Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
				IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=0
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						IF LTRIM(RTRIM(@ForEveryUOM))='0'
						BEGIN
							SET @ErrDesc = 'For Every UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'NORMAL SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @PurOfEvery=1
					BEGIN
						IF LTRIM(RTRIM(@ForEveryQty))='0'
						BEGIN
							SET @ErrDesc = 'For Every Qty Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'NORMAL SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
			END
			IF @Po_ErrNo=0
			BEGIN
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @SchType<>4
				BEGIN
					IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=0
					BEGIN
						IF @SchType=1
						BEGIN
							IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
							END
							---->Modified By Nanda on 23/08/2009
							IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ForEveryUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
								END
							END
							ELSE
							BEGIN
								SET @ForEveryUomId=0
							END
							--->Till Here
						END
						ELSE IF @SchType=3
						BEGIN
							IF @MaxSchLevelId=@SchLevelId
							BEGIN
								IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (1) for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
									SET @FromUomId= ISNULL(@FromUomId,0)
								END
			
								---->Modified By Nanda on 23/08/2009
								IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
										SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
								END
							END
							ELSE
							BEGIN
								SET @sSQL=''
								IF @CntVal=(@MaxSchLevelId-@SchLevelId)
								BEGIN
									SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
								END
								ELSE
								BEGIN
									WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
									BEGIN
										IF @CntVal=1
										BEGIN
											SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
												  (SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
												   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
										END
			
											SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
											SET @TempStr1=@TempStr1+ ')'
										SET @CntVal=@CntVal+1	
										IF @CntVal=(@MaxSchLevelId-@SchLevelId)
										BEGIN
											IF ISNUMERIC(@GetKey)=1
											BEGIN									
												SET @sSQL=@sSQL + @TempStr +'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
											END
											ELSE
											BEGIN
												SET @sSQL=@sSQL + @TempStr +'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
											END																
										END
										
									END	
								END
								--Test		
								--SELECT @sSQL			
								EXEC(@sSQL)
								IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (2) for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
									SET @FromUomId= ISNULL(@FromUomId,0)
								END
					
								--->Modified By Nanda on 30/09/2010
								IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
								BEGIN
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
										SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
								END
								--->Till Here	
							END
						END
					END
					ELSE IF @FlexiId=1
					BEGIN
						IF @CombiSch=1
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
								---->Modified By Nanda on 23/08/2009
								IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
								BEGIN
									IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
									END
								END
								ELSE
								BEGIN
									SET @ForEveryUomId=0
								END
								---->Till Here
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (3) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
				
									--->Modified By Nanda on 30/09/2010
									IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
									BEGIN
										IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
										BEGIN
											IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
											BEGIN
												SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
												INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
												SET @Taction = 0
												SET @Po_ErrNo =1
											END
											ELSE
											BEGIN
												SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
												SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
											END
										END
										ELSE	
										BEGIN
											SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
										END
									END
									ELSE	
									BEGIN
										SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
									END
									--->Till Here	
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
			-- 								IF @CntVal<>1
			-- 								BEGIN
												SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
												SET @TempStr1=@TempStr1+ ')'
			-- 								END
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN				
												SET @sSQL=@sSQL + @TempStr +
												'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
												'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1	
												END	
											END
										END		
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (4) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
									--->Modified By Nanda on 30/09/2010
									IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
									BEGIN
										IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
										BEGIN
											SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
											INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
											SET @Taction = 0
											SET @Po_ErrNo =1
										END
										ELSE
										BEGIN
											SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
											SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
										END
									END
									BEGIN
										SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
									END
									--->Till Here
								END
							END
						END
						ELSE IF @RangeId=1
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM)))
								BEGIN
									SET @ErrDesc = 'To Uom:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'To UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ToUomId=ISNULL(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM))
								END
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (5) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN															
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
				
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
									BEGIN
										SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
										SET @ToUomId=ISNULL(@ToUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
			-- 								IF @CntVal<>1
			-- 								BEGIN
												SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
												SET @TempStr1=@TempStr1+ ')'
			-- 								END
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN					
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												ELSE
												BEGIN					
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
												END		
											END
										END	
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (6) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
									BEGIN
										SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
										SET @ToUomId= ISNULL(@ToUomId,0)
									END
								END
							END
						END
						ELSE
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (7) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0)FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
											SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
											SET @TempStr1=@TempStr1+ ')'
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												ELSE
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
												END																						
											END
										END		
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (8) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
								END
							END
						END
					END
				ELSE IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=1
				BEGIN
					IF @SchType=3
					BEGIN
						
						IF @MaxSchLevelId=@SchLevelId
						BEGIN
							IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (9) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
								SET @FromUomId= ISNULL(@FromUomId,0)
							END
			
							IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
							BEGIN
								SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
								SET @ToUomId=ISNULL(@ToUomId,0)
							END
			
							--Test
							IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
							BEGIN
								IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
									SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
								END
							END
							ELSE
							BEGIN
								SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
							END
						END
						ELSE
						BEGIN
							SET @sSQL=''
							IF @CntVal=(@MaxSchLevelId-@SchLevelId)
							BEGIN
								SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
							END
							ELSE
							BEGIN
								WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
								BEGIN
									IF @CntVal=1
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
												  (SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
											   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
									END
									
			-- 						IF @CntVal<>1
			-- 						BEGIN
										SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
										SET @TempStr1=@TempStr1+ ')'
			-- 						END
									SET @CntVal=@CntVal+1
									
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										IF ISNUMERIC(@GetKey)=1
										BEGIN				
										SET @sSQL=@sSQL + @TempStr +
										'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
											ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
										END
										ELSE
										BEGIN				
										SET @sSQL=@sSQL + @TempStr +
										'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
											ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
										END
									END
								END	
							END			
							EXEC(@sSQL)
							IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (10) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
								SET @FromUomId= ISNULL(@FromUomId,0)
							END
			
							IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@ToUOM+' not Found (11) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
								SET @ToUomId= ISNULL(@FromUomId,0)
							END

							--->Modified By Nanda on 30/09/2010
							IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
							BEGIN
								IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									
									SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN						
									SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
									SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
								END
							END
							ELSE
							BEGIN						
								SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
							END
							--->Till Here
						END
					END
					ELSE IF @SchType=1
					BEGIN
						IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
						BEGIN
							SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
							SET @ToUomId= ISNULL(@ToUomId,0)
						END
						IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM)))
						BEGIN
							SET @ErrDesc = 'To Uom:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'To UOM',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @ToUomId=ISNUll(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM))
							SET @ToUomId= ISNULL(@ToUomId,0)
						END
						---->Modified By Nanda on 23/08/2009
						IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
						BEGIN
							IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
							BEGIN
								SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ForEveryUomId=ISNUll(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
								SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
							END
						END
						ELSE
						BEGIN
							SET @ForEveryUomId=0
						END
						--->Till Here	
					END
				END
			END
			IF @SchType<>4
			BEGIN
				IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
				END
				
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					SET @Taction=0
				END
				ELSE
				BEGIN
					IF @CombiSch=0 AND @FlexiId=0 AND @RangeId=0
					BEGIN
		  				IF   @SchType=2
						BEGIN
							SET @ForEveryUomId=0
							SET @ToUomId=0
							SET @FromUomId=0
						END
						SET @ToUomId=0
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
									DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
									0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),convert(INT,@FlexiPoints),convert(NUMERIC(18,2),@Points),1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
									0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--						SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--						INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
								0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
								@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
					
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(8)) + ',' + CAST(@FromQty AS VARCHAR(8)) + ',' + CAST(0 AS VARCHAR(8)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(8)) + ',' + CAST(0 AS VARCHAR(8)) + ',' + CAST(@ToUomId AS VARCHAR(8)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(8)) + ',' + CAST(@ForEveryUomId AS VARCHAR(8)) + ',' + CAST(@DiscPer AS VARCHAR(8)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(8)) + ',' + CAST(@FlexiDisc AS VARCHAR(8)) + ',' + CAST(@FlexiFlat AS VARCHAR(8)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(8)) + ',' + CAST(@FlexiGift AS VARCHAR(8)) + ',' + CAST(@FlexiPoints AS VARCHAR(8)) + ',' + CAST(@Points AS VARCHAR(8)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
							
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
							0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),convert(INT,@FlexiPoints),convert(NUMERIC(18,2),@Points),1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE IF @FlexiId=1 AND @RangeId=0 AND @CombiSch=0
					BEGIN
						IF @FlexiType=1 OR @FlexiType=2
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
										DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 								SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
						
										INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
										ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
										Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
										MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
										0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
										convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
										1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
						
		-- -- 								SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- -- 								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- -- 								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- -- 								MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- -- 								',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- -- 								CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- -- 								CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- -- 								INSERT INTO Translog(strSql1) Values (@sSQL)
									END
									ELSE
									BEGIN
										DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		-- 								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
										INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
										ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
										Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
										VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
										0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
										@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
		-- 					
		-- 								SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 								MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 								CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 								CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 								CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 								CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 								CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 								',0,0,0,0,0,0,''N'')'
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
										SET @Po_ErrNo =0
									END
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
									0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
								MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
								0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
								convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
								1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 						CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 						CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
							END
						END
					END
					ELSE IF @CombiSch=1 AND @FlexiId=0
					BEGIN
						
						IF NOT EXISTS(SELECT SchId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode)
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
				
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
							0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					IF EXISTS(SELECT SchId FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode)
		-- 					BEGIN
		-- 						DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabCombiPrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 		
		-- 						INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT @GetKey AS SchId,@SlabCode AS SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,@FromQty AS SlabValue,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121)
		-- 						FROM SchemeProducts WHERE SchId=@GetKey
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT ' + CAST(@GetKey AS VARCHAR(10)) + 'AS SchId,'+ CAST(@SlabCode AS VARCHAR(10)) + 'AS SlabId,
		-- 						PrdCtgValMainId,PrdId,PrdBatId' + CAST(@FromQty AS VARCHAR(10)) + 'AS SlabValue,1,1,
		-- 						''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + '''
		-- 						FROM SchemeProducts WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					END
						END
		-- 				ELSE
		-- 				BEGIN
		-- 					IF EXISTS(SELECT SchId FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode)
		-- 					BEGIN
		-- 						DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabCombiPrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 		
		-- 						INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT @GetKey AS SchId,@SlabCode AS SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,@FromQty AS SlabValue,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121)
		-- 						FROM SchemeProducts WHERE SchId=@GetKey
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT ' + CAST(@GetKey AS VARCHAR(10)) + 'AS SchId,'+ CAST(@SlabCode AS VARCHAR(10)) + 'AS SlabId,
		-- 						PrdCtgValMainId,PrdId,PrdBatId' + CAST(@FromQty AS VARCHAR(10)) + 'AS SlabValue,1,1,
		-- 						''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + '''
		-- 						FROM SchemeProducts WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					END
		-- 				END
					END
					ELSE IF @RangeId=0
					BEGIN
						DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 				SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 				' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 				INSERT INTO Translog(strSql1) Values (@sSQL)
						SET @TempRange=0
			
						INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
						MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),convert(NUMERIC(18,2),@TempRange),@FromUomId,
						0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
						convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
						1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
			
		-- 				SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 				ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 				Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 				MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 				CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' +
		-- 				CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 				CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 				CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 				CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 				',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 				INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF (@FlexiId=1 AND @CombiSch=1) OR (@FlexiId=1 AND @RangeId=1)
					BEGIN
						---->Modified By Nanda on 23/08/2009
						IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
						END
						---->Till Here
		--				SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		--				' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--				INSERT INTO Translog(strSql1) Values (@sSQL)
						IF @RangeId=1
						BEGIN
							SET @TempRange=0
						END
						ELSE
						BEGIN
							SET @TempRange=@FromQty
						END
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
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@TempRange),convert(NUMERIC(18,2),@FromQty),@FromUomId,
									convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 							CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 							CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- 			
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
								END
								ELSE
								BEGIN
															DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
									@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
--								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
--								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
--								INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
								@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
								@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
					
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@TempRange),convert(NUMERIC(18,2),@FromQty),@FromUomId,
							convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 					CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 					CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE IF @FlexiId=0 AND @RangeId=1 AND @CombiSch=0
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
									DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,0,convert(NUMERIC(18,2),@FromQty),@FromUomId,
									convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- -- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- -- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- -- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
									SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
									' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
									INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
									@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
								INSERT INTO Translog(strSql1) Values (@sSQL)
							
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,CAST(@SlabCode AS INT),0,CAST(@FromQty AS INT),CAST(@FromUomId AS INT),
								CAST(@ToQty AS INT),CAST(@ToUomId AS INT),CAST(@ForEveryQty As INT),CAST(@ForEveryUomId AS INT),CAST(@DiscPer AS NUMERIC(38,6)),CAST(@FlatAmt AS NUMERIC(38,6)),CAST(@FlexiDisc AS INT),CAST(@FlexiFlat AS INT),
								CAST(@FlexiFree AS INT),CAST(@FlexiGift AS INT),CAST(@FlexiPoints AS INT),CAST(@Points AS INT),0,0,0,0,0,0,'NO')
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
							
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,0,convert(NUMERIC(18,2),@FromQty),@FromUomId,
							convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
						END					
					END
				END
			END
		END
	END
	
	FETCH NEXT FROM Cur_SchemeSlabDt INTO  @SchCode,@SlabCode,@FromUOM,@FromQty,@ToUOM,@ToQty,@ForEveryUOM,
		@ForEveryQty,@DiscPer,@FlatAmt,@Points,@FlexiFree,@FlexiGift,@FlexiDisc,@FlexiFlat,@FlexiPoints,
		@MaxDisc,@MinDisc,@MaxValue,@MinValue,@MaxPoints,@MinPoints
	END
	CLOSE Cur_SchemeSlabDt
	DEALLOCATE Cur_SchemeSlabDt
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-021

if not exists (Select Id,name from Syscolumns where name = 'ClusterValues' and id in (Select id from 
	Sysobjects where name ='ClusterMaster'))
begin
	ALTER TABLE [dbo].[ClusterMaster]
	ADD [ClusterValues] NUMERIC(38,6) NOT NULL DEFAULT 0 WITH VALUES
END
GO


if not exists (Select Id,name from Syscolumns where name = 'DownLoaded' and id in (Select id from 
	Sysobjects where name ='ClusterMaster'))
begin
	ALTER TABLE [dbo].[ClusterMaster]
	ADD [DownLoaded] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-165-022

if not exists (Select Id,name from Syscolumns where name = 'DetailsId' and id in (Select id from 
	Sysobjects where name ='ClusterDetails'))
begin
	ALTER TABLE [dbo].[ClusterDetails]
	ADD [DetailsId] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-165-023

DELETE FROM DependencyTable WHERE PrimaryTable='ClusterMaster' 

INSERT INTO DependencyTable(PrimaryTable,RelatedTable,FieldName)
VALUES('ClusterMaster','ClusterAssign','ClusterId')

INSERT INTO DependencyTable(PrimaryTable,RelatedTable,FieldName)
VALUES('ClusterMaster','ClusterGroupDetails','ClusterId')

--SRF-Nanda-165-024

IF NOT EXISTS(SELECT * FROM ClusterScreens WHERE TransName='Product')
BEGIN
	INSERT INTO ClusterScreens(TransId,TransName,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
	VALUES(91,'Product',1,1,GETDATE(),1,GETDATE())	
END
GO

--SRF-Nanda-165-025

if exists (select * from dbo.sysobjects where id = object_id(N'[ClusterGroupMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ClusterGroupMaster]
GO

CREATE TABLE [dbo].[ClusterGroupMaster]
(
	[ClsGroupId] [int] NOT NULL,
	[ClsGroupCode] [nvarchar](50) NOT NULL,
	[ClsGroupName] [nvarchar](100) NOT NULL,
	[ClsType] [int] NOT NULL,
	[ClsTransId] [int] NOT NULL,
	[DownLoaded] [int] NOT NULL ,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL	 
) ON [PRIMARY]
GO

--SRF-Nanda-165-026

if exists (select * from dbo.sysobjects where id = object_id(N'[ClusterGroupDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ClusterGroupDetails]
GO

CREATE TABLE [dbo].[ClusterGroupDetails]
(
	[ClsGroupId] [int] NOT NULL,
	[ClusterId] [int] NOT NULL,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-027

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_ClusterGroupMaster_ClsGroupId]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
ALTER TABLE [dbo].[ClusterGroupMaster] DROP CONSTRAINT [PK_ClusterGroupMaster_ClsGroupId]
GO

ALTER TABLE [dbo].[ClusterGroupMaster] WITH NOCHECK ADD 
	CONSTRAINT [PK_ClusterGroupMaster_ClsGroupId] PRIMARY KEY  CLUSTERED 
	(
		[ClsGroupId]
	)  ON [PRIMARY] 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_ClusterGroupDetails_ClsGroupId]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [dbo].[ClusterGroupDetails] DROP CONSTRAINT [FK_ClusterGroupDetails_ClsGroupId]
GO
ALTER TABLE [dbo].[ClusterGroupDetails] ADD 
	CONSTRAINT [FK_ClusterGroupDetails_ClsGroupId] FOREIGN KEY 
	(
		[ClsGroupId]
	) REFERENCES [dbo].[ClusterGroupMaster] 
	(
		[ClsGroupId]
	)
GO

--SRF-Nanda-165-028

IF NOT EXISTS(SELECT * FROM menuDef where MenuName='mnuClusterGroup' and ParentId='mStk')
BEGIN
	Declare @Srno as Int
	Declare @menuId as Varchar(50)
	Declare @Srno1 as Int
	Declare @maxrow as int
	Declare @OldSrNo as int
	Declare @Newmaxrow as int
	Select TOP 1 @Srno= Srlno from MenuDef  where MenuId like 'mStk%' Order by Srlno Desc
	SET @Srno1=@Srno+1
	select @maxrow=Max(srlNo) from Menudef
	set @Newmaxrow=@maxrow+1
	set @OldSrNo= @maxrow

--	While @Srno<=@maxrow
--	begin	
--		Update Menudef set Srlno=@Newmaxrow where srlno=@OldSrNo
--		set @Newmaxrow= @Newmaxrow -1
--		Set @OldSrNo=@OldSrNo-1
--		Set @Srno=@Srno+1
--	End

--	SET @menuId= 'mStk'+Cast(@Srno1 as Varchar(5))

	SET @menuId= 'mStk27'
	SET @Srno1=170
	DELETE FROM Menudef WHERE MenuId=@menuId

	INSERT INTO Menudef (SrlNo,MenuId,MenuName,ParentId,Caption,MenuStatus,FormName,DefaultCaption) 
	VALUES (@Srno1,@menuId,'mnuClusterGroup','mStk','Cluster Group',0,'frmClusterGroup','Cluster Group')

	Delete From ProfileDt Where MenuId = @menuId and PrfId = 1
	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(1,@menuId,0,'New',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(1,@menuId,1,'Edit',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(1,@menuId,2,'Save',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(1,@menuId,3,'Delete',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(1,@menuId,4,'Cancel',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(1,@menuId,5,'Exit',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(1,@menuId,6,'Print',1,1,1,GETDATE(),1,GETDATE())

	Delete From ProfileDt Where MenuId = @menuId and PrfId = 2
	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(2,@menuId,0,'New',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(2,@menuId,1,'Edit',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(2,@menuId,2,'Save',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(2,@menuId,3,'Delete',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(2,@menuId,4,'Cancel',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(2,@menuId,5,'Exit',1,1,1,GETDATE(),1,GETDATE())

	INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	VALUES(2,@menuId,6,'Print',1,1,1,GETDATE(),1,GETDATE())
END
GO


--SRF-Nanda-165-029

DELETE FROM TransactionMaster WHERE TransactionId=264

INSERT INTO TransactionMaster(TransactionId,TransactionCode,TransactionDescription,StockChangeType,UomReq,RtrSeqReq,PrdSeqReq,PurSalSeqReq,
Availability,LastModBy,LastModDate,AuthId,AuthDate)
VALUES(264,'CLUSTERGRP','Cluster Group',0,0,1,0,0,1,1,GETDATE(),1,GETDATE())

--SRF-Nanda-165-030

IF NOT EXISTS(SELECT * FROM Counters WHERE TabName='ClusterGroupMaster')
BEGIN
	INSERT INTO Counters(TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,
	Availability,LastModBy,LastModDate,AuthId,AuthDate)
	VALUES('ClusterGroupMaster','ClsGroupId','',0,1,0,'Cluster Group',0,2010,1,1,GETDATE(),1,GETDATE())
END
GO

--SRF-Nanda-165-031

if not exists (Select Id,name from Syscolumns where name = 'Population' and id in (Select id from 
	Sysobjects where name ='Geography'))
begin
	ALTER TABLE [dbo].[Geography]
	ADD [Population] NUMERIC(38,2) NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-165-032

DELETE FROM CustomCaptions WHERE TransId=84 AND CtrlId=4 AND SubCtrlId=9

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(84,4,9,'DgCommon-84-4-9','Population','','',1,1,1,GETDATE(),1,GETDATE(),'Population','','',1,1)

--SRF-Nanda-165-033

DELETE FROM ConfigProfile WHERE ModuleName='mnuOptions2' AND TabId=6

INSERT INTO ConfigProfile(PrfId,PrfCode,PrfName,ModuleId,ModuleName,TabId,TabName,
SubTabId,SubTabName,Status,Availability,LastModBy,LastModDate,Authid,AuthDate)
VALUES(1,'PRF01','ADMIN',2,'mnuOptions2',6,'sstConfiguration',-1,'',1,1,1,GETDATE(),1,GETDATE())

INSERT INTO ConfigProfile(PrfId,PrfCode,PrfName,ModuleId,ModuleName,TabId,TabName,
SubTabId,SubTabName,Status,Availability,LastModBy,LastModDate,Authid,AuthDate)
VALUES(2,'PRF02','USER1',2,'mnuOptions2',6,'sstConfiguration',-1,'',0,1,1,GETDATE(),1,GETDATE())

--SRF-Nanda-165-034-From Boo

DELETE FROM CustomCaptions WHERE TransId=262
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1,0,'fxtSupplier','','Supplier Name','',1,1,1,'2010-10-04',1,'2010-10-04','','Supplier Name','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,2,0,'lblSupplier','Supplier Name','','',1,1,1,'2010-10-04',1,'2010-10-04','Supplier Name','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,3,0,'lblNoofCredit','Number of Credit Notes Available','','',1,1,1,'2010-10-04',1,'2010-10-04','Number of Credit Notes Available','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,4,0,'lblCreditAmt','Total Credit Note Amount','','',1,1,1,'2010-10-04',1,'2010-10-04','Total Credit Note Amount','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,5,0,'lblTotalCaption','Total','','',1,1,1,'2010-10-04',1,'2010-10-04','Total','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,6,1,'sprCredit-262-6-1','Credit Note Number*...','','',1,1,1,'2010-10-04',1,'2010-10-04','Credit Note Number*...','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,6,2,'sprCredit-262-6-2','Description','','',1,1,1,'2010-10-04',1,'2010-10-04','Description','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,6,3,'sprCredit-262-6-3','Credit Note Amount','','',1,1,1,'2010-10-04',1,'2010-10-04','Credit Note Amount','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,6,4,'sprCredit-262-6-4','Adjusted So far','','',1,1,1,'2010-10-04',1,'2010-10-04','Adjusted So far','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,6,5,'sprCredit-262-6-5','Available Amount','','',1,1,1,'2010-10-04',1,'2010-10-04','Available Amount','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,6,6,'sprCredit-262-6-6','Adjustment Amount','','',1,1,1,'2010-10-04',1,'2010-10-04','Adjustment Amount','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,7,0,'btnOperation','&Ok','','',1,1,1,'2010-10-04',1,'2010-10-04','&Ok','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,7,1,'btnOperation','&Cancel','','',1,1,1,'2010-10-04',1,'2010-10-04','&Cancel','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,8,1,'CoreHeaderTool','Credit Note Adjustment','','',1,1,1,'2010-10-04',1,'2010-10-04','Credit Note Adjustment','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,8,2,'CoreHeaderTool','Stocky','','',1,1,1,'2010-10-04',1,'2010-10-04','Stocky','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,1,'Msgbox-262-1000-1','','','Adjustment amount should be less than the bill amount',1,1,1,'2010-10-04',1,'2010-10-04','','','Adjustment amount should be less than the bill amount',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,2,'Msgbox-262-1000-2','','','Adjustment Amount Should be Greater than 0',1,1,1,'2010-10-04',1,'2010-10-04','','','Adjustment Amount Should be Greater than 0',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,3,'Msgbox-262-1000-3','','','No Credit Note Available For This Supplier',1,1,1,'2010-10-04',1,'2010-10-04','','','No Credit Note Available For This Supplier',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,4,'Msgbox-262-1000-4','','','Duplication Value Not Allowed',1,1,1,'2010-10-04',1,'2010-10-04','','','Duplication Value Not Allowed',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,5,'PnlMsg-262-1000-5','','Credit Note Number','',1,1,1,'2010-10-04',1,'2010-10-04','','Credit Note Number','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,6,'PnlMsg-262-1000-6','','Description','',1,1,1,'2010-10-04',1,'2010-10-04','','Description','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,7,'PnlMsg-262-1000-7','','Credit Note Amount','',1,1,1,'2010-10-04',1,'2010-10-04','','Credit Note Amount','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,8,'PnlMsg-262-1000-8','','Adjusted So far','',1,1,1,'2010-10-04',1,'2010-10-04','','Adjusted So far','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,9,'PnlMsg-262-1000-9','','Available Amount','',1,1,1,'2010-10-04',1,'2010-10-04','','Available Amount','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,1000,10,'PnlMsg-262-1000-10','','Enter Adjustment Amount','',1,1,1,'2010-10-04',1,'2010-10-04','','Enter Adjustment Amount','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,2000,1,'HotSch-262-2000-1','Credit Note No.','','',1,1,1,'2010-10-04',1,'2010-10-04','Credit Note No.','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,2000,2,'HotSch-262-2000-2','Description','','',1,1,1,'2010-10-04',1,'2010-10-04','Description','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,100000,1,'sprCredit-262-1','Credit Note Number','','',1,1,1,'2010-10-04',1,'2010-10-04','Credit Note Number','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (262,100001,6,'sprCredit-262-6','Adjustment Amount','','',1,1,1,'2010-10-04',1,'2010-10-04','Adjustment Amount','','',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10041
INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10041,'Purchase - Credit Note Adjustment','CreditNoteNo','select','SELECT CrNoteNumber,Description,Amount,CrAdjAmount,AvailAmount  FROM (
SELECT CRR.CrNoteNumber,R.Description ,CRR.Amount ,CRR.CrAdjAmount - ISNULL(C.CrAdjAmount,0) as CrAdjAmount,    
(CRR.Amount + ISNULL(C.CrAdjAmount,0) - CRR.CrAdjAmount) AvailAmount  FROM CreditNoteSupplier CRR   
INNER JOIN ReasonMaster R ON CRR.ReasonId = R.ReasonId and  CRR.SpmId = vFParam AND CRR.Status =1   
LEFT OUTER JOIN PurchaseCrNoteAdj C On   C.CrNoteNumber = CRR.CrNoteNumber AND C.PurRcptId = vSParam WHERE 
(CRR.Amount - CRR.CrAdjAmount)>0 ) AS a'
DELETE FROM HotSearchEditorDt WHERE FormId=10041
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10041,'CreditNoteNo','Credit Note No.','CrNoteNumber',1000,0,'HotSch-262-2000-1',262
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 2,10041,'CreditNoteNo','Description','Description',3500,0,'HotSch-262-2000-2',262
GO
IF NOT EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PurchaseCrNoteAdj')
AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
BEGIN
	CREATE TABLE PurchaseCrNoteAdj
	(
		PurRcptId		BIGINT,
		CrNoteNumber	VARCHAR(200),
		AdjSofar		NUMERIC(18,6),
		CrAdjAmount		NUMERIC(18,6),
		SpmId			INT,
		Availability	TINYINT,
		LastModBy		TINYINT,
		LastModDate		DATETIME,
		AuthId			TINYINT,
		AuthDate		DATETIME

	CONSTRAINT [FK_PurchaseReceipt_PurRcptId_CrNote] FOREIGN KEY 
	(
		[PurRcptId]
	) REFERENCES [dbo].[PurchaseReceipt] 
	(
		[PurRcptId]
	))  ON [PRIMARY] 
END
GO
IF NOT EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PurchaseDbNoteAdj')
AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
BEGIN
	CREATE TABLE PurchaseDbNoteAdj
	(
		PurRcptId		BIGINT,
		DbNoteNumber	VARCHAR(200),
		AdjSofar		NUMERIC(18,6),
		DbAdjAmount		NUMERIC(18,6),
		SpmId			INT,
		Availability	TINYINT,
		LastModBy		TINYINT,
		LastModDate		DATETIME,
		AuthId			TINYINT,
		AuthDate		DATETIME
	CONSTRAINT [FK_PurchaseReceipt_PurRcptId_DbNote] FOREIGN KEY 
	(
		[PurRcptId]
	) REFERENCES [dbo].[PurchaseReceipt] 
	(
		[PurRcptId]
	))  ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'CrAdjustAmt' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='PurchaseReceipt'))
BEGIN
	ALTER TABLE PurchaseReceipt ADD CrAdjustAmt  NUMERIC(18,6) NOT NULL DEFAULT 0 WITH VALUES 	
END
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'DbAdjustAmt' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='PurchaseReceipt'))
BEGIN
	ALTER TABLE PurchaseReceipt ADD DbAdjustAmt  NUMERIC(18,6) NOT NULL DEFAULT 0 WITH VALUES 	
END
GO
DELETE FROM CustomCaptions WHERE TransId=263
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1,0,'fxtSupplier','','Supplier Name','',1,1,1,'2010-10-05',1,'2010-10-05','','Supplier Name','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,2,0,'lblSupplier','Supplier Name','','',1,1,1,'2010-10-05',1,'2010-10-05','Supplier Name','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,3,0,'lblNoofDebit','Number of Debit Notes Available','','',1,1,1,'2010-10-05',1,'2010-10-05','Number of Debit Notes Available','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,4,0,'lblDebitAmt','Total Debit Note Amount','','',1,1,1,'2010-10-05',1,'2010-10-05','Total Debit Note Amount','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,5,0,'lblTotalCaption','Total','','',1,1,1,'2010-10-05',1,'2010-10-05','Total','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,6,1,'sprDebit-263-6-1','Debit Note Number*...','','',1,1,1,'2010-10-05',1,'2010-10-05','Debit Note Number*...','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,6,2,'sprDebit-263-6-2','Description','','',1,1,1,'2010-10-05',1,'2010-10-05','Description','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,6,3,'sprDebit-263-6-3','Debit Note Amount','','',1,1,1,'2010-10-05',1,'2010-10-05','Debit Note Amount','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,6,4,'sprDebit-263-6-4','Adjusted So far','','',1,1,1,'2010-10-05',1,'2010-10-05','Adjusted So far','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,6,5,'sprDebit-263-6-5','Available Amount','','',1,1,1,'2010-10-05',1,'2010-10-05','Available Amount','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,6,6,'sprDebit-263-6-6','Adjustment Amount','','',1,1,1,'2010-10-05',1,'2010-10-05','Adjustment Amount','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,7,0,'btnOperation','&Ok','','',1,1,1,'2010-10-05',1,'2010-10-05','&Ok','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,7,1,'btnOperation','&Cancel','','',1,1,1,'2010-10-05',1,'2010-10-05','&Cancel','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,8,1,'CoreHeaderTool','Debit Note Adjustment','','',1,1,1,'2010-10-05',1,'2010-10-05','Debit Note Adjustment','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,8,2,'CoreHeaderTool','Stocky','','',1,1,1,'2010-10-05',1,'2010-10-05','Stocky','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,1,'Msgbox-263-1000-1','','','Adjustment Amount Should be Greater than 0',1,1,1,'2010-10-05',1,'2010-10-05','','','Adjustment Amount Should be Greater than 0',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,2,'Msgbox-263-1000-2','','','No Debit Note Available For This Supplier',1,1,1,'2010-10-05',1,'2010-10-05','','','No Debit Note Available For This Supplier',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,3,'Msgbox-263-1000-3','','','Duplication Value Not Allowed',1,1,1,'2010-10-05',1,'2010-10-05','','','Duplication Value Not Allowed',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,4,'PnlMsg-263-1000-4','','Debit Note Number','',1,1,1,'2010-10-05',1,'2010-10-05','','Debit Note Number','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,5,'PnlMsg-263-1000-5','','Description','',1,1,1,'2010-10-05',1,'2010-10-05','','Description','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,6,'PnlMsg-263-1000-6','','Debit Note Amount','',1,1,1,'2010-10-05',1,'2010-10-05','','Debit Note Amount','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,7,'PnlMsg-263-1000-7','','Adjusted So far','',1,1,1,'2010-10-05',1,'2010-10-05','','Adjusted So far','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,8,'PnlMsg-263-1000-8','','Available Amount','',1,1,1,'2010-10-05',1,'2010-10-05','','Available Amount','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,1000,9,'PnlMsg-263-1000-9','','Enter Adjustment Amount','',1,1,1,'2010-10-05',1,'2010-10-05','','Enter Adjustment Amount','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,2000,1,'HotSch-263-2000-1','Code','','',1,1,1,'2010-10-05',1,'2010-10-05','Code','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,2000,2,'HotSch-263-2000-2','Description','','',1,1,1,'2010-10-05',1,'2010-10-05','Description','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,100000,1,'sprDebit-263-1','Debit Note Number','','',1,1,1,'2010-10-05',1,'2010-10-05','Debit Note Number','','',1,1)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (263,100001,6,'sprDebit-263-6','Adjustment Amount','','',1,1,1,'2010-10-05',1,'2010-10-05','Adjustment Amount','','',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10042
INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10042,'Purchase - Debit Note Adjustment','DebitNoteNo','select','SELECT DBNoteNumber,Description,Amount,DBAdjAmount,AvailAmount  FROM (  
SELECT DBR.DBNoteNumber , R.Description , DBR.Amount ,  DBR.DBAdjAmount - ISNULL(C.DBAdjAmount,0) as DBAdjAmount,  
(DBR.Amount + ISNULL(C.DBAdjAmount,0) - DBR.DBAdjAmount) AvailAmount,DBR.Status  FROM DebitNoteSupplier DBR 
INNER JOIN ReasonMaster R ON DBR.ReasonId = R.ReasonId and  DBR.SmpId = vFParam LEFT OUTER JOIN PurchaseDbNoteAdj  C 
On C.DBNoteNumber = DBR.DBNoteNumber AND C.PurRcptId =  vSParam) AS a  WHERE (Amount - DBAdjAmount)>0'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10042
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10042,'DebitNoteNo','Debit Note No.','DbNoteNumber',1000,0,'HotSch-263-2000-1',263
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 2,10042,'DebitNoteNo','Description','Description',3500,0,'HotSch-263-2000-2',263
GO
DELETE FROM CustomCaptions WHERE TransId=5 AND CtrlId=1000 AND SubCtrlId=103
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (5,1000,103,'MsgBox-5-1000-103','','','CreditNote not available for this Supplier',1,1,1,'2010-10-04',1,'2010-10-04','','CreditNote not available for this Supplier1','',1,1)
DELETE FROM CustomCaptions WHERE TransId=5 AND CtrlId=1000 AND SubCtrlId=104
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (5,1000,104,'MsgBox-5-1000-104','','','Select Supplier',1,1,1,'2010-10-04',1,'2010-10-04','','Select Supplier1','',1,1)
DELETE FROM CustomCaptions WHERE TransId=5 AND CtrlId=1000 AND SubCtrlId=105
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (5,1000,105,'MsgBox-5-1000-105','','','Save Failed While Adjust Credit Amount',1,1,1,'2010-10-04',1,'2010-10-04','','Save Failed While Adjust Credit Amount1','',1,1)
DELETE FROM CustomCaptions WHERE TransId=5 AND CtrlId=1000 AND SubCtrlId=106
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES (5,1000,106,'MsgBox-5-1000-106','','','Save Failed While Adjust Debit Amount',1,1,1,'2010-10-04',1,'2010-10-04','','Save Failed While Adjust Debit Amount1','',1,1)

--SRF-Nanda-165-035

--UPDATE ProfileDt SET BtnStatus=0 WHERE MenuId='mStk1'
--AND BtnIndex IN (0,1,3) AND PrfId<>1

--SRF-Nanda-165-036

if not exists (Select Id,name from Syscolumns where name = 'Upload' and id in (Select id from 
	Sysobjects where name ='RouteVillage'))
begin
	ALTER TABLE [dbo].[RouteVillage]
	ADD [Upload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-165-037

if not exists (Select Id,name from Syscolumns where name = 'Status' and id in (Select id from 
	Sysobjects where name ='ClusterAssign'))
begin
	ALTER TABLE [dbo].[ClusterAssign]
	ADD [Status] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'Upload' and id in (Select id from 
	Sysobjects where name ='ClusterAssign'))
begin
	ALTER TABLE [dbo].[ClusterAssign]
	ADD [Upload] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'AssignDate' and id in (Select id from 
	Sysobjects where name ='ClusterAssign'))
begin
	ALTER TABLE [dbo].[ClusterAssign]
	ADD [AssignDate] DATETIME NOT NULL DEFAULT GETDATE() WITH VALUES
END
GO

--SRF-Nanda-165-038

if not exists (Select Id,name from Syscolumns where name = 'AppReqd' and id in (Select id from 
	Sysobjects where name ='ClusterGroupMaster'))
begin
	ALTER TABLE [dbo].[ClusterGroupMaster]
	ADD [AppReqd] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-165-039

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_Retailer]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_Retailer]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_Retailer]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100)  NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100)  NULL,
	[CmpRtrCode] [nvarchar](100)  NULL,
	[RtrName] [nvarchar](100)  NULL,
	[RtrAddress1] [nvarchar](100)  NULL,
	[RtrAddress2] [nvarchar](100)  NULL,
	[RtrAddress3] [nvarchar](100)  NULL,
	[RtrPINCode] [nvarchar](20)  NULL,
	[RtrChannelCode] [nvarchar](100)  NULL,
	[RtrGroupCode] [nvarchar](100)  NULL,
	[RtrClassCode] [nvarchar](100)  NULL,
	[KeyAccount] [nvarchar](20)  NULL,
	[RelationStatus] [nvarchar](100)  NULL,
	[ParentCode] [nvarchar](100)  NULL,
	[RtrRegDate] [nvarchar](100)  NULL,
	[GeoLevel] [nvarchar](100)  NULL,
	[GeoLevelValue] [nvarchar](100)  NULL,
	[VillageId] [int] NULL,
	[VillageCode] [nvarchar](100)  NULL,
	[VillageName] [nvarchar](100)  NULL,
	[Status] [tinyint] NULL,
	[Mode] [nvarchar](100)  NULL,
	[UploadFlag] [nvarchar](10)  NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-040

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_Route]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_Route]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_Route]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RMId] [int] NULL,
	[RMCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Distance] [numeric](38, 6) NULL,
	[RMPopulation] [numeric](38, 6) NULL,
	[VanRoute] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RouteType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LocalUpCountry] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevel] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MonDay] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TuesDay] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WednesDay] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ThursDay] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FriDay] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SaturDay] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SunDay] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-041

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_Route_Archive]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_Route_Archive]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_Route_Archive]
(
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [nvarchar](100)  NULL,
	[RMId] [int] NULL,
	[RMCode] [nvarchar](100)  NULL,
	[RMName] [nvarchar](100)  NULL,
	[Distance] [numeric](38, 6) NULL,
	[RMPopulation] [numeric](38, 6) NULL,
	[VanRoute] [nvarchar](100)  NULL,
	[RouteType] [nvarchar](100)  NULL,
	[LocalUpCountry] [nvarchar](100)  NULL,
	[GeoLevel] [nvarchar](100)  NULL,
	[GeoValue] [nvarchar](100)  NULL,
	[Status] [nvarchar](20)  NULL,
	[MonDay] [nvarchar](20)  NULL,
	[TuesDay] [nvarchar](20)  NULL,
	[WednesDay] [nvarchar](20)  NULL,
	[ThursDay] [nvarchar](20)  NULL,
	[FriDay] [nvarchar](20)  NULL,
	[SaturDay] [nvarchar](20)  NULL,
	[SunDay] [nvarchar](20)  NULL,
	[UploadFlag] [nvarchar](10)  NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-042

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_RouteVillage]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_RouteVillage]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_RouteVillage]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100)  NULL,
	[VillageId] [int] NULL,
	[RMId] [int] NULL,
	[RMCode] [nvarchar](100)  NULL,
	[RMName] [nvarchar](100)  NULL,
	[VillageCode] [nvarchar](100)  NULL,
	[VillageName] [nvarchar](100)  NULL,
	[Distance] [numeric](38, 6) NULL,
	[Population] [numeric](38, 6) NULL,
	[RtrPopulation] [numeric](38, 6) NULL,
	[RoadCondition] [nvarchar](100)  NULL,
	[IncomeLevel] [nvarchar](100)  NULL,
	[Accepability] [nvarchar](100)  NULL,
	[Awareness] [nvarchar](100)  NULL,
	[Status] [nvarchar](20)  NULL,
	[UploadFlag] [nvarchar](10)  NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-043

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_RouteVillage_Archive]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_RouteVillage_Archive]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_RouteVillage_Archive]
(
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [nvarchar](100)  NULL,
	[VillageId] [int] NULL,
	[RMId] [int] NULL,
	[RMCode] [nvarchar](100)  NULL,
	[RMName] [nvarchar](100)  NULL,
	[VillageCode] [nvarchar](100)  NULL,
	[VillageName] [nvarchar](100)  NULL,
	[Distance] [numeric](38, 6) NULL,
	[Population] [numeric](38, 6) NULL,
	[RtrPopulation] [numeric](38, 6) NULL,
	[RoadCondition] [nvarchar](100)  NULL,
	[IncomeLevel] [nvarchar](100)  NULL,
	[Accepability] [nvarchar](100)  NULL,
	[Awareness] [nvarchar](100)  NULL,
	[Status] [nvarchar](20)  NULL,
	[UploadFlag] [nvarchar](10)  NULL,
	[UploadedDate] [datetime]  NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-044

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Retailer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Retailer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC [Proc_CS2CN_Retailer] 0
SELECT * FROM Cs2Cn_Prk_Retailer ORDER BY SlNo
SELECT * FROM Retailer
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Retailer]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_CS2CN_BLRetailer
* PURPOSE	: Extract Retailer Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 09-01-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Retailer WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Retailer
	(
		DistCode ,
		RtrId ,
		RtrCode ,
		CmpRtrCode ,
		RtrName ,
		RtrAddress1,
		RtrAddress2,
		RtrAddress3,
		RtrPINCode,
		RtrChannelCode ,
		RtrGroupCode ,
		RtrClassCode ,
		Status,
		KeyAccount,
		RelationStatus,
		ParentCode,
		RtrRegDate,
		GeoLevel,
		GeoLevelValue,
		VillageId,
		VillageCode,
		VillageName,
		Mode,			
		UploadFlag
	)
	SELECT
		@DistCode ,
		R.RtrId ,
		R.RtrCode ,
		R.CmpRtrCode ,
		R.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode ,
		'' CtgCode ,
		'' ValueClassCode ,
		RtrStatus,	
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New','N'				
	FROM		
		Retailer R
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
	WHERE			
		R.Upload = 'N'

	UNION

	SELECT
		@DistCode ,
		RCC.RtrId,
		RCC.RtrCode,
		R.CmpRtrCode,
		RCC.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode,
		'' CtgCode,
		'' ValueClassCode,
		RtrStatus,
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','CR','N'			
	FROM
		RetailerClassficationChange RCC			
		INNER JOIN Retailer R ON R.RtrId=RCC.RtrId
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
	WHERE 	
		UpLoadFlag=0

	UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,ETL.RtrClassCode=RVC.ValueClassCode
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode ,RVC.ValueClassCode
		FROM
		RetailerValueClassMap RVCM ,
		RetailerValueClass RVC	,
		RetailerCategory RC ,
		RetailerCategoryLevel RCL,
		RetailerCategory RC1,
		Retailer R  		
	WHERE
		R.Rtrid = RVCM.RtrId
		AND	RVCM.RtrValueClassId = RVC.RtrClassId
		AND	RVC.CtgMainId=RC.CtgMainId
		AND	RCL.CtgLevelId=RC.CtgLevelId
		AND	RC.CtgLinkId = RC1.CtgMainId
	) AS RVC
	WHERE ETL.RtrId=RVC.RtrId
	
	UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoLevelValue=Geo.GeoName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
		ISNULL(G.GeoName,'') AS GeoName
		FROM			
		Retailer R  		
		LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
		LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId
	) AS Geo
	WHERE ETL.RtrId=Geo.RtrId	

	UPDATE ETL SET ETL.VillageId=V.VillageId,ETL.VillageCode=V.VillageCode,ETL.VillageName=V.VillageName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,R.VillageId,V.VillageCode,V.VillageName
		FROM			
		Retailer R  		
		INNER JOIN RouteVillage V ON R.VillageId=V.VillageId
	) V
	WHERE ETL.RtrId=V.RtrId	

	UPDATE Retailer SET Upload='Y' WHERE Upload='N'
	AND CmpRtrCode IN(SELECT CmpRtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='New')

	UPDATE RetailerClassficationChange SET UpLoadFlag=1 WHERE UpLoadFlag=0
	AND RtrCode IN(SELECT RtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='CR')
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-045

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Route]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Route]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_Route 0
SELECT * FROM Cs2Cn_Prk_Route ORDER BY SlNo
SELECT * FROM RouteMaster
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Route]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_Route
* PURPOSE		: To Extract Route Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 22/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Route WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Route
	(
		DistCode,
		RMId,
		RMCode,
		RMName,
		Distance,
		RMPopulation,
		VanRoute,
		RouteType,
		LocalUpCountry,
		GeoLevel,
		GeoValue,
		Status,
		MonDay,
		TuesDay,
		WednesDay,
		ThursDay,
		FriDay,
		SaturDay,
		SunDay,
		UploadFlag
	)
	SELECT
		@DistCode,
		RM.RMId,
		RM.RMCode,
		RM.RMName,
		RM.RMDistance,
		RM.RMPopulation,
		RM.RMVanRoute,
		RM.RMSRouteType,
		RM.RMLocalUpcountry,
		'' AS GeoLevel,
		'' AS GeoValue,
		(CASE RM.RMstatus WHEN 0 THEN 'InActive' ELSE 'Active' END) AS Status,
		(CASE RM.RMMon WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMTue WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMWed WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMThu WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMFri WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMSat WHEN 1 THEN 'Yes' ELSE 'No' END),
		(CASE RM.RMSun WHEN 1 THEN 'Yes' ELSE 'No' END),		
		'N'				
	FROM		
		RouteMaster RM
	WHERE			
		RM.Upload = 'N'

	UPDATE A SET A.GeoLevel=B.GeoLevelName,A.GeoValue=B.GeoCode
	FROM Cs2Cn_Prk_Route A,
	(SELECT RM.RMId,GL.GeoLevelName,G.GeoCode FROM RouteMaster RM,Geography G,GeographyLevel GL
	WHERE RM.GeoMainId=G.GeoMainId AND G.GeoLevelId=GL.GeoLevelId AND RM.Upload='N') B
	WHERE A.RMid=B.RMId

	UPDATE RouteMaster  SET Upload='Y'
	WHERE RMCode IN (SELECT RMCode FROM Cs2Cn_Prk_Route)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-046

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_RouteVillage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_RouteVillage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_RouteVillage 0
SELECT * FROM Cs2Cn_Prk_RouteVillage ORDER BY SlNo
SELECT * FROM RouteMaster
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_RouteVillage]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_RouteVillage
* PURPOSE		: To Extract Route Village Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 11/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_RouteVillage WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_RouteVillage
	(
		DistCode,
		VillageId,
		RMId,
		RMCode,
		RMName,
		VillageCode,
		VillageName,
		Distance,
		[Population],
		RtrPopulation,
		RoadCondition,
		IncomeLevel,
		Accepability,
		Awareness,
		Status,
		UploadFlag
	)
	SELECT
		@DistCode,
		V.VillageId,
		RM.RMId,
		RM.RMCode,
		RM.RMName,
		V.VillageCode,
		V.VillageName,
		V.Distance,
		V.[Population],
		V.RtrPopulation,
		(CASE V.RoadCondition WHEN 1 THEN 'Good' WHEN 2 THEN 'Above Average' WHEN 3 THEN 'Average' WHEN 4 THEN 'Below Average' ELSE 'Poor' END),
		(CASE V.IncomeLevel WHEN 1 THEN 'Good' WHEN 2 THEN 'Above Average' WHEN 3 THEN 'Average' WHEN 4 THEN 'Below Average' ELSE 'Poor' END),
		(CASE V.Acceptability WHEN 1 THEN 'Good' WHEN 2 THEN 'Above Average' WHEN 3 THEN 'Average' WHEN 4 THEN 'Below Average' ELSE 'Poor' END),
		(CASE V.Awareness WHEN 1 THEN 'Good' WHEN 2 THEN 'Above Average' WHEN 3 THEN 'Average' WHEN 4 THEN 'Below Average' ELSE 'Poor' END),		
		(CASE V.VillageStatus WHEN 0 THEN 'InActive' ELSE 'Active' END) AS Status,		
		'N'				
	FROM		
		RouteVillage V,RouteMaster RM
	WHERE			
		V.RMId=RM.RMId AND V.Upload = 0
	
	UPDATE RouteVillage  SET Upload=1
	WHERE VillageCode IN (SELECT VillageCode FROM Cs2Cn_Prk_RouteVillage)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-047

--SELECT * FROM CustomCaptions WHERE TransId=33

UPDATE CustomCaptions SET Caption='Debit Account*...',DefaultCaption='Debit Account*...' ,PnlMsg='Debit Account',DefaultPnlMsg='Debit Account'
,MsgBox='Debit Account',DefaultMsgBox='Debit Account'
WHERE CtrlName='lblAccount' AND TransId=18 AND CtrlId=4 

UPDATE CustomCaptions SET Caption='',DefaultCaption='' ,PnlMsg='Press F4/Double Click to Select Debit Account',DefaultPnlMsg='Press F4/Double Click to Select Debit Account'
,MsgBox='Press F4/Double Click to Select Debit Account',DefaultMsgBox='Press F4/Double Click to Select Debit Account'
WHERE CtrlName='fxtAccount' AND TransId=18 AND CtrlId=10

UPDATE CustomCaptions SET Caption='Credit Account*...',DefaultCaption='Credit Account*...' ,PnlMsg='Credit Account',DefaultPnlMsg='Credit Account'
,MsgBox='Credit Account',DefaultMsgBox='Credit Account'
WHERE CtrlName='lblAccount' AND TransId=19 AND CtrlId=4  

UPDATE CustomCaptions SET Caption='',DefaultCaption='' ,PnlMsg='Press F4/Double Click to Select Credit Account',DefaultPnlMsg='Press F4/Double Click to Select Credit Account'
,MsgBox='Press F4/Double Click to Select Credit Account',DefaultMsgBox='Press F4/Double Click to Select Credit Account'
WHERE CtrlName='fxtAccount' AND TransId=19 AND CtrlId=10

UPDATE CustomCaptions SET Caption='Debit Account*...',DefaultCaption='Debit Account*...' ,PnlMsg='Debit Account',DefaultPnlMsg='Debit Account'
,MsgBox='Debit Account',DefaultMsgBox='Debit Account'
WHERE CtrlName='lblCrNoteAccount' AND TransId=32 AND CtrlId=4 

UPDATE CustomCaptions SET Caption='',DefaultCaption='' ,PnlMsg='Press F4/Double Click to Select Debit Account',DefaultPnlMsg='Press F4/Double Click to Select Debit Account'
,MsgBox='Press F4/Double Click to Select Debit Account',DefaultMsgBox='Press F4/Double Click to Select Debit Account'
WHERE CtrlName='fxtAccount' AND TransId=32 AND CtrlId=10

UPDATE CustomCaptions SET Caption='Credit Account*...',DefaultCaption='Credit Account*...' ,PnlMsg='Credit Account',DefaultPnlMsg='Credit Account'
,MsgBox='Credit Account',DefaultMsgBox='Credit Account'
WHERE CtrlName='lblDbNoteAccount' AND TransId=33 AND CtrlId=4  

UPDATE CustomCaptions SET Caption='',DefaultCaption='' ,PnlMsg='Press F4/Double Click to Select Credit Account',DefaultPnlMsg='Press F4/Double Click to Select Credit Account'
,MsgBox='Press F4/Double Click to Select Credit Account',DefaultMsgBox='Press F4/Double Click to Select Credit Account'
WHERE CtrlName='fxtAccount' AND TransId=33 AND CtrlId=10

--SRF-Nanda-165-048

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_HierarchyLevelValue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_HierarchyLevelValue]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_HierarchyLevelValue]
(
	[DistCode] [nvarchar](50)  NULL,
	[HierarchyType] [int] NULL,
	[LevelName] [nvarchar](100)  NULL,
	[ParentCode] [nvarchar](50)  NULL,
	[HierarchyCode] [nvarchar](50)  NULL,
	[HierarchyName] [nvarchar](100)  NULL,
	[AddInfo1] [nvarchar](100)  NULL,
	[AddInfo2] [nvarchar](100)  NULL,
	[AddInfo3] [nvarchar](100)  NULL,
	[AddInfo4] [nvarchar](100)  NULL,
	[AddInfo5] [nvarchar](100)  NULL,
	[DownLoadFlag] [nvarchar](10)  NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-049

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_SupplierMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_SupplierMaster]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_SupplierMaster]
(
	[DistCode] [nvarchar](50)  NULL,
	[SpmCode] [nvarchar](50)  NULL,
	[SpmName] [nvarchar](100)  NULL,
	[SpmAdd1] [nvarchar](100)  NULL,
	[SpmAdd2] [nvarchar](100)  NULL,
	[SpmAdd3] [nvarchar](100)  NULL,
	[TaxGroupCode] [nvarchar](100)  NULL,
	[PhoneNo] [nvarchar](20)  NULL,
	[FaxNo] [nvarchar](20)  NULL,
	[EmailId] [nvarchar](100)  NULL,
	[ContPerson] [nvarchar](100)  NULL,
	[DefaultSpm] [nvarchar](10)  NULL,
	[DownLoadFlag] [nvarchar](10)  NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-050

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_Prk_GeographyHierarchyLevelValue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_Prk_GeographyHierarchyLevelValue]
GO

CREATE TABLE [dbo].[ETL_Prk_GeographyHierarchyLevelValue]
(
	[Geography Hierarchy Level Code] [nvarchar](100)  NULL,
	[Parent Hierarchy Level Value Code] [nvarchar](100)  NULL,
	[Geography Hierarchy Level Value Code] [nvarchar](100)  NULL,
	[Geography Hierarchy Level Value Name] [nvarchar](100)  NULL,
	[Population] [nvarchar](100)  NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-051

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ExportGeographyHierarchyLevelValue]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ExportGeographyHierarchyLevelValue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT dbo.Fn_ExportGeographyHierarchyLevelValue() AS Query

CREATE     FUNCTION [dbo].[Fn_ExportGeographyHierarchyLevelValue] ()
RETURNS nVarchar(4000)
AS
BEGIN
/*********************************
* FUNCTION	: Fn_ExportGeographyHierarchyLevelValue
* PURPOSE	: Export-ETL For Geography Hierarchy Level Value
* NOTES		:
* CREATED	: Nandakumar R.G  on 12-09-2007
* MODIFIED
*	DATE		AUTHOR				DESCRIPTION
------------------------------------------------
*  15/10/2010	Nandakumar R.G		Addition of Population field	
*********************************/

	DECLARE @ConStr AS nVarchar(4000)
	SET @ConStr = 'SELECT GeoLevelName [Geography Hierarchy Level Code],GeoCodeLink AS [Parent Hierarchy Level Value Code],
	GeoCode AS [Geography Hierarchy Level Value Code],GeoName AS [Geography Hierarchy Level Value Name],[Population]
	INTO #Temp
	FROM 
	(SELECT GL.GeoLevelName,ISNULL(GLink.GeoCode,''GeoFirstLevel'') AS GeoCodeLink,G.GeoCode,G.GeoName,G.[Population]
	FROM GeographyLevel GL,Geography G LEFT OUTER JOIN Geography GLink ON G.GeoLinkId=GLink.GeoMainId
	WHERE G.GeoLevelId=GL.GeoLevelId) AS A
	SELECT * FROM #Temp'
	RETURN (@ConStr)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-052

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SupplierMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SupplierMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_SupplierMaster 0
SELECT * FROM Cn2Cs_Prk_SupplierMaster
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_SupplierMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SupplierMaster
* PURPOSE		: To validate the downloaded Supplier details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 15/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @SpmCode 		NVARCHAR(50)
	DECLARE @SpmName  		NVARCHAR(100)
	DECLARE @SpmAdd1	  	NVARCHAR(100)
	DECLARE @SpmAdd2		NVARCHAR(100)
	DECLARE @SpmAdd3		NVARCHAR(100)
	DECLARE @TaxGrpCode  	NVARCHAR(100)
	DECLARE @PhoneNo  		NVARCHAR(100)
	DECLARE @FaxNo  		NVARCHAR(100)
	DECLARE @EmailId  		NVARCHAR(100)
	DECLARE @ContPerson  	NVARCHAR(100)
	DECLARE @DefaultSpm  	NVARCHAR(100)
	DECLARE @AcCode			NVARCHAR(100)
	DECLARE @SpmId  		INT
	DECLARE @CoaId  		INT
	DECLARE @CmpId  		INT
	DECLARE @TaxGrpId  		INT
	DECLARE @Exist		 	INT

	SET @TabName = 'Cn2Cs_Prk_SupplierMaster'
	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SpmToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SpmToAvoid	
	END

	CREATE TABLE SpmToAvoid
	(
		SpmCode NVARCHAR(50)
	)

	IF EXISTS(SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
	WHERE LTRIM(RTRIM(ISNULL(SpmCode,'')))='' OR LTRIM(RTRIM(ISNULL(SpmName,'')))='')
	BEGIN
		INSERT INTO SpmToAvoid(SpmCode)
		SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(SpmCode,'')))='' OR LTRIM(RTRIM(ISNULL(SpmName,'')))=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Supplier Master','SpmCode','Supplier Code/Name Should not be empty' FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(SpmCode,'')))='' OR LTRIM(RTRIM(ISNULL(SpmName,'')))=''
	END		
	
	IF EXISTS(SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
	WHERE LTRIM(RTRIM(ISNULL(SpmAdd1,'')))='')
	BEGIN
		INSERT INTO SpmToAvoid(SpmCode)
		SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(SpmAdd1,'')))=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Supplier Master','SpmCode','Supplier Address1 Should not be empty' FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(SpmAdd1,'')))='' 
	END
	
	IF EXISTS(SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
	WHERE LTRIM(RTRIM(ISNULL(PhoneNo,'')))='')
	BEGIN
		INSERT INTO SpmToAvoid(SpmCode)
		SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(PhoneNo,'')))=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Supplier Master','SpmCode','Supplier Phone No Should not be empty' FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(PhoneNo,'')))='' 
	END

	DECLARE Cur_SupplierMaster CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([SpmCode])),''),ISNULL(LTRIM(RTRIM([SpmName])),''),ISNULL(LTRIM(RTRIM([SpmAdd1])),''),
	ISNULL(LTRIM(RTRIM([SpmAdd2])),''),ISNULL(LTRIM(RTRIM([SpmAdd3])),''),ISNULL(LTRIM(RTRIM([TaxGroupCode])),''),
	ISNULL(LTRIM(RTRIM([PhoneNo])),''),ISNULL(LTRIM(RTRIM([FaxNo])),''),ISNULL(LTRIM(RTRIM([EmailId])),''),
	ISNULL(LTRIM(RTRIM([ContPerson])),''),ISNULL(LTRIM(RTRIM([DefaultSpm])),'No')
	FROM Cn2Cs_Prk_SupplierMaster WHERE [DownLoadFlag] ='D' AND
	SpmCode NOT IN (SELECT SpmCode FROM SpmToAvoid)
	OPEN Cur_SupplierMaster
	FETCH NEXT FROM Cur_SupplierMaster INTO @SpmCode,@SpmName,@SpmAdd1,@SpmAdd2,@SpmAdd3,
	@TaxGrpCode,@PhoneNo,@FaxNo,@EmailId,@ContPerson,@DefaultSpm
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0

		IF NOT EXISTS(SELECT * FROM Company WHERE DefaultCompany=1)
		BEGIN
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Supplier Master','CmpCode','Default Company Not Foud' 
			SET @Po_ErrNo =1
		END
		ELSE
		BEGIN
			SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
		END

		IF NOT EXISTS(SELECT * FROM TaxGroupSetting WHERE RtrGroup=@TaxGrpCode AND TaxGroup=3)
		BEGIN
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Supplier Master','Tax Group Code','Tax Group Code Not Foud' 
			SET @Po_ErrNo =1
		END
		ELSE
		BEGIN
			SELECT @TaxGrpId=TaxGroupId FROM TaxGroupSetting WHERE RtrGroup=@TaxGrpCode AND TaxGroup=3
		END

		IF NOT EXISTS (SELECT * FROM Supplier WHERE SpmCode=@SpmCode)
		BEGIN			
			SET @SpmId = dbo.Fn_GetPrimaryKeyInteger('Supplier','SpmId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SET @Exist=0			
			IF @SpmId<=(SELECT ISNULL(MAX(SpmId),0) AS SpmId FROM Supplier)
			BEGIN
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO ErrorLog VALUES (67,@TabName,'SpmId',@ErrDesc)
				SET @Po_ErrNo =1
			END
		END
		ELSE
		BEGIN
			SELECT @SpmId=SpmId FROM Supplier WHERE SpmCode=@SpmCode			
			SET @Exist=1
		END		

		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN

				SET @CoaId = dbo.Fn_GetPrimaryKeyInteger('CoaMaster','CoaId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
				SELECT @AcCode = CAST(CAST(AcCode as Numeric(18,0)) + 1 as nVarchar(50)) FROM COAMaster 
				WHERE CoaId=(SELECT MAX(A.CoaId) FROM COAMaster A Where A.MainGroup=1 
				and A.AcCode LIKE '133%')

				INSERT INTO CoaMaster(CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) 
				Values (@CoaId,@AcCode,@SpmName,4,1,2,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
				CONVERT(VARCHAR(10),GETDATE(),121))

				INSERT INTO Supplier(SpmId,SpmCode,SpmName,SpmAdd1,SpmAdd2,SpmAdd3,SpmPhone,SpmFax,SpmEmail,
				SpmContact,SpmDefault,CoaId,CmpId,TaxGroupId,SpmOnAcc,Availability,LastModBy,LastModDate,AuthId,AuthDate)			
				VALUES(@SpmId,@SpmCode,@SpmName,@SpmAdd1,@SpmAdd2,@SpmAdd3,@PhoneNo,@FaxNo,@EmailId,
				@ContPerson,(CASE @DefaultSpm WHEN 'Yes' THEN 1 ELSE 0 END),@CoaId,@CmpId,@TaxGrpId,0,1,1,GETDATE(),1,GETDATE())								

				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='Supplier' AND FldName='SpmId'	  								
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CoaMaster' AND FldName='CoaId'
			END		
			ELSE 
			BEGIN
				UPDATE Supplier SET SpmName=@SpmName,SpmAdd1=@SpmAdd1,SpmAdd2=@SpmAdd2,SpmAdd3=@SpmAdd3,
				SpmPhone=@PhoneNo,SpmFax=@FaxNo,SpmContact=@ContPerson,SpmDefault=(CASE @DefaultSpm WHEN 'Yes' THEN 1 ELSE 0 END)				
				WHERE SpmId=@SpmId							
			END			
		END

		FETCH NEXT FROM Cur_SupplierMaster INTO @SpmCode,@SpmName,@SpmAdd1,@SpmAdd2,@SpmAdd3,
		@TaxGrpCode,@PhoneNo,@FaxNo,@EmailId,@ContPerson,@DefaultSpm
	END
	CLOSE Cur_SupplierMaster
	DEALLOCATE Cur_SupplierMaster

	UPDATE Cn2Cs_Prk_SupplierMaster SET DownLoadFlag='Y' WHERE 
	DownLoadFlag ='D' AND SpmCode IN (SELECT SpmCode FROM Supplier)
	AND SpmCode NOT IN (SELECT SpmCode FROM SpmToAvoid)

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-053

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_HierarchyLevelValue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_HierarchyLevelValue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_HierarchyLevelValue
TRUNCATE TABLE ETL_Prk_GeographyHierarchyLevelValue
EXEC Proc_Cn2Cs_HierarchyLevelValue 0
SELECT * FROM ETL_Prk_GeographyHierarchyLevelValue
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE  [dbo].[Proc_Cn2Cs_HierarchyLevelValue]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_HierarchyLevelValue
* PURPOSE		: To validate and update/insert the downloaded hierarchy data  
* CREATED		: Nandakumar R.G
* CREATED DATE	: 26/03/2010
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @ErrStatus INT
	DECLARE @CmpCode   NVARCHAR(50)

	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany=1 	

	TRUNCATE TABLE ETL_Prk_RetailerCategoryLevelValue

	INSERT INTO ETL_Prk_RetailerCategoryLevelValue([Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Hierarchy Level Value Code],[Hierarchy Level Value Name],[Company Code])

	SELECT DISTINCT LevelName,ParentCode,HierarchyCode,HierarchyName,@CmpCode
	FROM Cn2Cs_Prk_HierarchyLevelValue WHERE DownLoadFlag='D' AND HierarchyType=4 ORDER BY LevelName

	TRUNCATE TABLE ETL_Prk_GeographyHierarchyLevelValue

	INSERT INTO ETL_Prk_GeographyHierarchyLevelValue([Geography Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Geography Hierarchy Level Value Code],[Geography Hierarchy Level Value Name],[Population])
	SELECT DISTINCT LevelName,ParentCode,HierarchyCode,HierarchyName,AddInfo1
	FROM Cn2Cs_Prk_HierarchyLevelValue WHERE DownLoadFlag='D' AND HierarchyType=2 ORDER BY LevelName

	UPDATE ETL SET [Parent Hierarchy Level Value Code]='GeoFirstLevel'
	FROM ETL_Prk_GeographyHierarchyLevelValue ETL,GeographyLevel Geo
	WHERE ETL.[Geography Hierarchy Level Code]=Geo.LevelName AND ETL.[Geography Hierarchy Level Code]='Level1' 

	UPDATE ETL SET [Geography Hierarchy Level Code]=GeoLevelName
	FROM ETL_Prk_GeographyHierarchyLevelValue ETL,GeographyLevel Geo
	WHERE ETL.[Geography Hierarchy Level Code]=Geo.LevelName

	EXEC Proc_ValidateRetailerCategoryLevelValue @Po_ErrNo= @ErrStatus OUTPUT

	EXEC Proc_ValidateGeographyHierarchyLevelValue @Po_ErrNo= @ErrStatus OUTPUT

	UPDATE Cn2Cs_Prk_HierarchyLevelValue SET DownLoadFlag='Y'
	WHERE HierarchyCode IN (SELECT CtgCode FROM RetailerCategory) AND HierarchyType=4

	UPDATE Cn2Cs_Prk_HierarchyLevelValue SET DownLoadFlag='Y'
	WHERE HierarchyCode IN (SELECT GeoCode FROM Geography) AND HierarchyType=2

	SET @Po_ErrNo= @ErrStatus
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-054

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateGeographyHierarchyLevelValue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateGeographyHierarchyLevelValue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM ETL_Prk_GeographyHierarchyLevelValue
Exec Proc_ValidateGeographyHierarchyLevelValue 0
SELECT * FROM Geography
ROLLBACK TRANSACTION
*/

CREATE          Procedure [dbo].[Proc_ValidateGeographyHierarchyLevelValue]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ValidateGeographyHierarchyLevelValue
* PURPOSE		: To Insert and Update records in the Table GeographyCategoryValue
* CREATED		: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*	{date}		{developer}		{brief modification description}
* 15/10/2010	Nandakumar R.G	Addition of Population field
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @Exist 		AS 	INT
	DECLARE @Tabname 	AS     	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	
	DECLARE @GeoHierLevelCode 		AS  NVARCHAR(100)
	DECLARE @ParentHierLevelCode 	AS  NVARCHAR(100)
	DECLARE @GeoHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @GeoHierLevelValueName 	AS  NVARCHAR(100)
	DECLARE @ParentLinkCode			AS 	NVARCHAR(100)
	DECLARE @NewLinkCode 			AS 	NVARCHAR(100)
	DECLARE @LevelName 				AS 	NVARCHAR(100)
	DECLARE @Population				AS 	NUMERIC(38,6)
	
	DECLARE @GeoLevelId 	AS 	INT
	DECLARE @GeoMainId 	AS 	INT
	DECLARE @GeoLinkId 	AS 	INT
	DECLARE @GeoLinkCode 	AS 	NVARCHAR(100)

	DECLARE @TransStr 	AS 	NVARCHAR(4000)


	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='Geography'
	SET @Fldname='GeoMainId'
	SET @Tabname = 'ETL_Prk_GeographyHierarchyLevelValue'
	SET @Exist=0
	
	DECLARE Cur_GeographyHierarchyLevelValue CURSOR
	FOR SELECT ISNULL([Geography Hierarchy Level Code],''),ISNULL([Parent Hierarchy Level Value Code],''),
	ISNULL([Geography Hierarchy Level Value Code],''),ISNULL([Geography Hierarchy Level Value Name],''),ISNULL([Population],0)
	FROM ETL_Prk_GeographyHierarchyLevelValue

	OPEN Cur_GeographyHierarchyLevelValue
	FETCH NEXT FROM Cur_GeographyHierarchyLevelValue INTO @GeoHierLevelCode,@ParentHierLevelCode,
	@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population

	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0

		IF NOT EXISTS(SELECT * FROM GeographyLevel WITH (NOLOCK) WHERE GeoLevelName=@GeoHierLevelCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Geography Level',
			'Geography Level:'+@GeoHierLevelCode+' is not available')

			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @GeoLevelId=GeoLevelId,@LevelName=LevelName FROM GeographyLevel WITH (NOLOCK) 
			WHERE GeoLevelName=@GeoHierLevelCode
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Geography WITH (NOLOCK) WHERE GeoCode=@ParentHierLevelCode)
			AND @ParentHierLevelCode<>'GeoFirstLevel'
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Parent Geography Level',
				'Parent Geography Level:'+@ParentHierLevelCode+' is not available')

				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @GeoLinkId=ISNULL(GeoMainId,0) FROM Geography WITH (NOLOCK) 
				WHERE GeoCode=@ParentHierLevelCode

				SET @GeoLinkId=ISNULL(@GeoLinkId,0)
			END
		END	

		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@GeoHierLevelValueCode))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value Code',
				'Geography Hierarvhy Level Value Code should not be empty')

				SET @Po_ErrNo=1
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@GeoHierLevelValueName))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value Name',
				'Geography Hierarvhy Level Value Name should not be empty')

				SET @Po_ErrNo=1
			END
		END		
		
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS(SELECT * FROM Geography WITH (NOLOCK) WHERE GeoCode=@GeoHierLevelValueCode)
			BEGIN
				SET @Exist=1

				SELECT @GeoMainId=GeoMainId FROM Geography WITH (NOLOCK) WHERE GeoCode=@GeoHierLevelValueCode
				
			END
		
			IF @Exist=0
			BEGIN

				SELECT @GeoMainId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
				IF @LevelName='Level1'			
				BEGIN
					SET @GeoLinkId=0
	
					SELECT @GeoLevelId=GeoLevelId FROM GeographyLevel WITH (NOLOCK) 
					WHERE  GeoLevelName=@GeoHierLevelCode 
		
					SELECT @ParentLinkCode='00'+CAST(@GeoLevelId AS NVARCHAR(100))
				END
				ELSE
				BEGIN
					SELECT 	@ParentLinkCode=GeoLinkCode FROM Geography
					WHERE GeoMainId=@GeoLinkId

				END

				SELECT @NewLinkCode=ISNULL(MAX(GeoLinkCode),0) 
				FROM Geography WHERE LEN(GeoLinkCode)=  Len(@ParentLinkCode)+3
				AND GeoLinkCode LIKE  @ParentLinkCode +'%' AND GeoLevelId =@GeoLevelId

				SELECT 	@GeoLinkCode=dbo.Fn_ReturnNewCode(@ParentLinkCode,3,@NewLinkCode)

				IF LEN(@GeoLinkCode)<>(SUBSTRING(@LevelName,6,LEN(@LevelName))+1)*3
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value',
					'Geography Hierarvhy Level is not match with parent level for: '+@GeoHierLevelValueCode)
	
					SET @Po_ErrNo=1
				END
				
				IF @Po_ErrNo=0
				BEGIN
					INSERT INTO Geography(GeoMainId,GeoLinkId,GeoLevelId,GeoLinkCode,GeoCode,GeoName,[Population],
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@GeoMainId,@GeoLinkId,@GeoLevelId,@GeoLinkCode,
					@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
				
	
					SET @TransStr='INSERT INTO Geography 
					(GeoMainId,GeoLinkId,GeoLevelId,GeoLinkCode,GeoCode,GeoName,[Population],
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES('+CAST(@GeoMainId AS NVARCHAR(10))+','+
					CAST(@GeoLinkId AS NVARCHAR(10))+','+CAST(@GeoLevelId AS NVARCHAR(10))+','''+@GeoLinkCode+''','''
					+@GeoHierLevelValueCode+''','''+@GeoHierLevelValueName+''+CAST(@Population AS NVARCHAR(100))+
					',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
	
					UPDATE Counters SET CurrValue=@GeoMainId WHERE TabName=@DestTabname AND FldName=@FldName
	
					SET @TransStr='UPDATE Counters SET CurrValue='+CAST(@GeoMainId AS NVARCHAR(10))+
					' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
				END

			END	
			ELSE
			BEGIN

				UPDATE Geography SET GeoName=@GeoHierLevelValueName
				WHERE GeoMainId=@GeoMainId

				SET @TransStr='UPDATE Geography SET GeoName='''+@GeoHierLevelValueName+
				''' WHERE GeoMainId='+CAST(@GeoMainId AS NVARCHAR(10))

				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
			END	
		END	

		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_GeographyHierarchyLevelValue
			DEALLOCATE Cur_GeographyHierarchyLevelValue
			RETURN
		END		
			
		FETCH NEXT FROM Cur_GeographyHierarchyLevelValue INTO @GeoHierLevelCode,@ParentHierLevelCode,
		@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population

	END
	CLOSE Cur_GeographyHierarchyLevelValue
	DEALLOCATE Cur_GeographyHierarchyLevelValue

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-055

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterMaster 0
SELECT * FROM Cn2Cs_Prk_ClusterMaster
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterMaster
* PURPOSE		: To validate the downloaded Cluster details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 30/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @ClusterCode 	NVARCHAR(50)
	DECLARE @ClusterName  	NVARCHAR(100)
	DECLARE @Remarks	  	NVARCHAR(200)
	DECLARE @Salesman		NVARCHAR(10)
	DECLARE @Retailer		NVARCHAR(10)
	DECLARE @AddMast1  		NVARCHAR(10)
	DECLARE @AddMast2  		NVARCHAR(10)
	DECLARE @AddMast3  		NVARCHAR(10)
	DECLARE @AddMast4  		NVARCHAR(10)
	DECLARE @AddMast5  		NVARCHAR(10)
	DECLARE @ClusterId  	INT
	DECLARE @Exist		 	INT
	SET @TabName = 'Cn2Cs_Prk_ClusterMaster'
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClsToAvoid	
	END
	CREATE TABLE ClsToAvoid
	(
		ClusterCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
	WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))='')
	BEGIN
		INSERT INTO ClsToAvoid(ClusterCode)
		SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
		WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Master','ClusterCode','Cluster Code/Name Should not be empty' FROM Cn2Cs_Prk_ClusterMaster
		WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''
	END		
	DECLARE Cur_ClusterMaster CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([ClusterCode])),''),ISNULL(LTRIM(RTRIM([ClusterName])),''),ISNULL(LTRIM(RTRIM([Remarks])),''),
	ISNULL(LTRIM(RTRIM([Salesman])),'No'),ISNULL(LTRIM(RTRIM([Retailer])),'No'),ISNULL(LTRIM(RTRIM([AddMast1])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast2])),'No'),ISNULL(LTRIM(RTRIM([AddMast3])),'No'),ISNULL(LTRIM(RTRIM([AddMast4])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast5])),'No')
	FROM Cn2Cs_Prk_ClusterMaster WHERE [DownLoadFlag] ='D' AND
	ClusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)
	OPEN Cur_ClusterMaster
	FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
	@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0
		IF NOT EXISTS (SELECT * FROM ClusterMaster WHERE ClusterCode=@ClusterCode)
		BEGIN			
			SET @ClusterId = dbo.Fn_GetPrimaryKeyInteger('ClusterMaster','ClusterId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SET @Exist=0			
			IF @ClusterId<=(SELECT ISNULL(MAX(ClusterId),0) AS ClusterId FROM ClusterMaster)
			BEGIN
				SELECT @ClusterId
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'ClusterId',@ErrDesc)
				SET @Po_ErrNo =1
			END
		END
		ELSE
		BEGIN
			SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode			
			SET @Exist=1
		END		
		
		IF @Exist=1 
		BEGIN
			EXEC Proc_DependencyCheck 'ClusterMaster',@ClusterId
			IF (SELECT COUNT(*) FROM TempDepCheck)>0
			BEGIN
				SET @Exist=2
			END			
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				INSERT INTO ClusterMaster(ClusterId,ClusterCode,ClusterName,Remarks,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)			
				VALUES(@ClusterId,@ClusterCode,@ClusterName,@Remarks,1,1,1,GETDATE(),1,GETDATE())
			
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterMaster' AND FldName='ClusterId'	  
				DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE()

				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE() 
			END		
			ELSE IF @Exist=1
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE()
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE() 
			END
			ELSE IF @Exist=2
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
			END
		END
		FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
		@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5
	END
	CLOSE Cur_ClusterMaster
	DEALLOCATE Cur_ClusterMaster

	UPDATE Cn2Cs_Prk_ClusterMaster SET DownLoadFlag='Y' WHERE 
	DownLoadFlag ='D' AND ClusterCode IN (SELECT ClusterCode FROM ClusterMaster)
	AND CLusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-056

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_ClusterMaster]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_ClusterMaster]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_ClusterMaster]
(
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClusterCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClusterName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Remarks] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Value] [numeric](38, 6) NULL,
	[PrdCtgLevelCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Salesman] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Retailer] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AddMast1] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AddMast2] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AddMast3] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AddMast4] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AddMast5] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DownLoadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-057

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_ClusterGroup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_ClusterGroup]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_ClusterGroup]
(
	[DistCode] [nvarchar](50)  NULL,
	[ClsGroupCode] [nvarchar](50)  NULL,
	[ClsGroupName] [nvarchar](100)  NULL,
	[ClsCategory] [nvarchar](50)  NULL,
	[AppReqd] [nvarchar](10)  NULL,
	[ClsGroupType] [nvarchar](100)  NULL,
	[ClusterCode] [nvarchar](50)  NULL,
	[ClusterName] [nvarchar](100)  NULL,
	[DownLoadFlag] [nvarchar](10)  NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-058

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_ClusterAssign]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_ClusterAssign]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_ClusterAssign]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50)  NULL,
	[ClusterId] INT NULL,
	[ClusterCode] [nvarchar](50)  NULL,
	[ClusterName] [nvarchar](100)  NULL,
	[ClsGroupId] INT NULL,
	[ClsGroupCode] [nvarchar](50)  NULL,
	[ClsGroupName] [nvarchar](100)  NULL,
	[ClsCategory] [nvarchar](50)  NULL,
	[MasterId] INT  NULL,
	[MasterCmpCode] [nvarchar](50)  NULL,
	[MasterDistCode] [nvarchar](50)  NULL,
	[MasterName] [nvarchar](100)  NULL,
	[AssignDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10)  NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-059

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_ClusterAssignApproval]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_ClusterAssignApproval]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_ClusterAssignApproval]
(
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MasterCmpCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MasterDistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClusterCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AssignDate] [datetime] NULL,
	[DownLoadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-060

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_ClusterMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_ClusterMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC Proc_Import_ClusterMaster '<Root></Root>'

CREATE   PROCEDURE [dbo].[Proc_Import_ClusterMaster]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_ClusterMaster
* PURPOSE		: To Insert the records from xml file in the Table ClusterMaster
* CREATED		: Nandakumar R.G
* CREATED DATE	: 30/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
    
	INSERT INTO Cn2Cs_Prk_ClusterMaster(DistCode,ClusterCode,ClusterName,Remarks,[Value],PrdCtgLevelCode,Salesman,Retailer,
	AddMast1,AddMast2,AddMast3,AddMast4,AddMast5,DownLoadFlag)
	SELECT DistCode,ClusterCode,ClusterName,Remarks,[Value],PrdCtgLevelCode,Salesman,Retailer,
	AddMast1,AddMast2,AddMast3,AddMast4,AddMast5,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2CS_ClusterMaster',1)
	WITH (
				[DistCode]			NVARCHAR(50),
				[ClusterCode]		NVARCHAR(50),
				[ClusterName]		NVARCHAR(100),
				[Remarks]			NVARCHAR(200),
				[Value]				NUMERIC(38,6),
				[PrdCtgLevelCode]	NVARCHAR(100),
				[Salesman]			NVARCHAR(10),
				[Retailer]			NVARCHAR(10),
				[AddMast1]			NVARCHAR(10),
				[AddMast2]			NVARCHAR(10),
				[AddMast3]			NVARCHAR(10),
				[AddMast4]			NVARCHAR(10),
				[AddMast5]			NVARCHAR(10),
				[DownLoadFlag]		NVARCHAR(10)
	     ) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-061

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_ClusterGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_ClusterGroup]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Import_ClusterGroup '<Root></Root>'

CREATE   PROCEDURE [dbo].[Proc_Import_ClusterGroup]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_ClusterGroup
* PURPOSE		: To Insert the records from xml file in the Table Cluster Group
* CREATED		: Nandakumar R.G
* CREATED DATE	: 21/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
    
	INSERT INTO Cn2Cs_Prk_ClusterGroup(DistCode,ClsGroupCode,ClsGroupName,ClsCategory,
	AppReqd,ClsGroupType,ClusterCode,ClusterName,DownLoadFlag)
	SELECT DistCode,ClsGroupCode,ClsGroupName,ClsCategory,
	AppReqd,ClsGroupType,ClusterCode,ClusterName,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2CS_ClusterGroup',1)
	WITH 
	(
				[DistCode]			NVARCHAR(50),
				[ClsGroupCode]		NVARCHAR(50),
				[ClsGroupName]		NVARCHAR(100),
				[ClsCategory]		NVARCHAR(50),
				[AppReqd]			NVARCHAR(10),
				[ClsGroupType]		NVARCHAR(100),
				[ClusterCode]		NVARCHAR(50),
				[ClusterName]		NVARCHAR(100),
				[DownLoadFlag]		NVARCHAR(10)
	) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-062

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_ClusterAssignApproval]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_ClusterAssignApproval]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC Proc_Import_ClusterAssignApproval '<Root></Root>'

CREATE   PROCEDURE [dbo].[Proc_Import_ClusterAssignApproval]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_ClusterAssignApproval
* PURPOSE		: To Insert the records from xml file in the Table ClusterAssign
* CREATED		: Nandakumar R.G
* CREATED DATE	: 23/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
    
	INSERT INTO Cn2Cs_Prk_ClusterAssignApproval(DistCode,MasterCmpCode,MasterDistCode,ClusterCode,Status,AssignDate,DownLoadFlag)
	SELECT DistCode,MasterCmpCode,MasterDistCode,ClusterCode,Status,AssignDate,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2CS_ClusterAssignApproval',1)
	WITH 
	(
		[DistCode]			NVARCHAR(50),
		[MasterCmpCode]		NVARCHAR(50),
		[MasterDistCode]	NVARCHAR(50),
		[ClusterCode]		NVARCHAR(50),
		[Status]			NVARCHAR(50),
		[AssignDate]		DATETIME,
		[DownLoadFlag]		NVARCHAR(10)
	) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-063

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterMaster 0
SELECT * FROM Cn2Cs_Prk_ClusterMaster
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterMaster
* PURPOSE		: To validate the downloaded Cluster details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 30/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @ClusterCode 	NVARCHAR(50)
	DECLARE @ClusterName  	NVARCHAR(100)
	DECLARE @Remarks	  	NVARCHAR(200)
	DECLARE @Salesman		NVARCHAR(10)
	DECLARE @Retailer		NVARCHAR(10)
	DECLARE @AddMast1  		NVARCHAR(10)
	DECLARE @AddMast2  		NVARCHAR(10)
	DECLARE @AddMast3  		NVARCHAR(10)
	DECLARE @AddMast4  		NVARCHAR(10)
	DECLARE @AddMast5  		NVARCHAR(10)
	DECLARE @ClusterId  	INT
	DECLARE @Exist		 	INT
	DECLARE @Value			NUMERIC(38,6)
	DECLARE @PrdCtgLevelCode	NVARCHAR(100)
	DECLARE @CmpPrdCtgId  	INT

	SET @TabName = 'Cn2Cs_Prk_ClusterMaster'
	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClsToAvoid	
	END
	CREATE TABLE ClsToAvoid
	(
		ClusterCode NVARCHAR(50)
	)

	IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
	WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))='')
	BEGIN
		INSERT INTO ClsToAvoid(ClusterCode)
		SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
		WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Master','ClusterCode','Cluster Code/Name Should not be empty' FROM Cn2Cs_Prk_ClusterMaster
		WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''
	END		

	IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
	WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes')
	BEGIN
		INSERT INTO ClsToAvoid(ClusterCode)
		SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
		WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes'

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Master','ClusterCode','Product Category Level:'+PrdCtgLevelCode+' not found' FROM Cn2Cs_Prk_ClusterMaster
		WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes'
	END
	
	DECLARE Cur_ClusterMaster CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([ClusterCode])),''),ISNULL(LTRIM(RTRIM([ClusterName])),''),ISNULL(LTRIM(RTRIM([Remarks])),''),
	ISNULL(LTRIM(RTRIM([Salesman])),'No'),ISNULL(LTRIM(RTRIM([Retailer])),'No'),ISNULL(LTRIM(RTRIM([AddMast1])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast2])),'No'),ISNULL(LTRIM(RTRIM([AddMast3])),'No'),ISNULL(LTRIM(RTRIM([AddMast4])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast5])),'No'),ISNULL([Value],0),ISNULL(LTRIM(RTRIM(PrdCtgLevelCode)),'')
	FROM Cn2Cs_Prk_ClusterMaster WHERE [DownLoadFlag] ='D' AND
	ClusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)
	OPEN Cur_ClusterMaster
	FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
	@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5,@Value,@PrdCtgLevelCode
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0

		IF @AddMast1='Yes'
		BEGIN
			SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName=@PrdCtgLevelCode
		END
		ELSE
		BEGIN
			SET @CmpPrdCtgId=0
		END

		IF NOT EXISTS (SELECT * FROM ClusterMaster WHERE ClusterCode=@ClusterCode)
		BEGIN			
			SET @ClusterId = dbo.Fn_GetPrimaryKeyInteger('ClusterMaster','ClusterId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SET @Exist=0			
			IF @ClusterId<=(SELECT ISNULL(MAX(ClusterId),0) AS ClusterId FROM ClusterMaster)
			BEGIN
				SELECT @ClusterId
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'ClusterId',@ErrDesc)
				SET @Po_ErrNo =1
			END
		END
		ELSE
		BEGIN
			SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode			
			SET @Exist=1
		END		
		
		IF @Exist=1 
		BEGIN
			EXEC Proc_DependencyCheck 'ClusterMaster',@ClusterId
			IF (SELECT COUNT(*) FROM TempDepCheck)>0
			BEGIN
				SET @Exist=2
			END			
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				INSERT INTO ClusterMaster(ClusterId,ClusterCode,ClusterName,Remarks,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,ClusterValues)			
				VALUES(@ClusterId,@ClusterCode,@ClusterName,@Remarks,1,1,1,GETDATE(),1,GETDATE(),@Value)
			
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterMaster' AND FldName='ClusterId'	  
				DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0

				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0 

				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,91,'Product',(CASE @AddMast1 WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),@CmpPrdCtgId 
			END		
			ELSE IF @Exist=1
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0

				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0 

				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,91,'Product',(CASE @AddMast1 WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),@CmpPrdCtgId 
			END

			ELSE IF @Exist=2
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
			END

		END
		FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
		@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5
	END
	CLOSE Cur_ClusterMaster
	DEALLOCATE Cur_ClusterMaster

	UPDATE Cn2Cs_Prk_ClusterMaster SET DownLoadFlag='Y' WHERE 
	DownLoadFlag ='D' AND ClusterCode IN (SELECT ClusterCode FROM ClusterMaster)
	AND CLusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-064

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterGroup]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterGroup 0
SELECT * FROM Cn2Cs_Prk_ClusterGroup
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterGroup]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterGroup
* PURPOSE		: To validate the downloaded Cluster Group details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 18/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @ClsGroupCode 	NVARCHAR(50)
	DECLARE @ClsGroupName  	NVARCHAR(100)
	DECLARE @ClusterCode 	NVARCHAR(50)
	DECLARE @ClusterName  	NVARCHAR(100)
	DECLARE @ClsCategory  	NVARCHAR(100)
	DECLARE @ClsGroupType	NVARCHAR(100)
	DECLARE @AppReqd		NVARCHAR(10)
	
	DECLARE @ClusterId  	INT
	DECLARE @ClsGroupId  	INT
	DECLARE @ClsTransId  	INT

	DECLARE @Exist		 	INT


	SET @TabName = 'Cn2Cs_Prk_ClusterGroup'
	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsGrpToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClsGrpToAvoid	
	END
	CREATE TABLE ClsGrpToAvoid
	(
		ClsGrpCode NVARCHAR(50)
	)

	IF EXISTS(SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
	WHERE LTRIM(RTRIM(ISNULL(ClsGroupCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClsGroupName,'')))='')
	BEGIN
		INSERT INTO ClsGrpToAvoid(ClsGrpCode)
		SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
		WHERE LTRIM(RTRIM(ISNULL(ClsGroupCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClsGroupName,'')))=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Group','Cluster Group Code','Cluster Group Code/Name Should not be empty' FROM Cn2Cs_Prk_ClusterGroup
		WHERE LTRIM(RTRIM(ISNULL(ClsGroupCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClsGroupName,'')))=''
	END		

	IF EXISTS(SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
	WHERE ClusterCode IN (SELECT ClusterCode FROM ClusterMaster))
	BEGIN
		INSERT INTO ClsGrpToAvoid(ClsGrpCode)
		SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
		WHERE ClusterCode IN (SELECT ClusterCode FROM ClusterMaster)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Group','Cluster Code','Cluster:'+ClusterCode+'not found' FROM Cn2Cs_Prk_ClusterGroup
		WHERE ClusterCode IN (SELECT ClusterCode FROM ClusterMaster)
	END

	IF EXISTS(SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
	WHERE ClsCategory IN (SELECT TransName FROM ClusterScreens))
	BEGIN
		INSERT INTO ClsGrpToAvoid(ClsGrpCode)
		SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
		WHERE ClsCategory IN (SELECT TransName FROM ClusterScreens)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Group','Cluster Code','Cluster Category:'+ClsCategory+'not found' FROM Cn2Cs_Prk_ClusterGroup
		WHERE ClsCategory IN (SELECT TransName FROM ClusterScreens)
	END
	
	DECLARE Cur_ClusterMaster CURSOR
	FOR SELECT ClsGroupCode,ClsGroupName,ClsCategory,AppReqd,ClsGroupType,ClusterCode,ClusterName
	FROM Cn2Cs_Prk_ClusterGroup 
	WHERE [DownLoadFlag] ='D' AND ClsGroupCode NOT IN (SELECT ClsGrpCode FROM ClsGrpToAvoid)
	OPEN Cur_ClusterMaster
	FETCH NEXT FROM Cur_ClusterMaster INTO @ClsGroupCode,@ClsGroupName,@ClsCategory,@AppReqd,@ClsGroupType,@ClusterCode,@ClusterName
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0		

		IF NOT EXISTS (SELECT * FROM ClusterGroupMaster WHERE ClsGroupCode=@ClsGroupCode)
		BEGIN			
			SET @ClsGroupId = dbo.Fn_GetPrimaryKeyInteger('ClusterGroupMaster','ClsGroupId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SET @Exist=0			
			IF @ClsGroupId<=(SELECT ISNULL(MAX(ClsGroupId),0) AS ClsGroupId FROM ClusterGroupMaster)
			BEGIN
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'ClsGroupId',@ErrDesc)
				SET @Po_ErrNo =1
			END
		END
		ELSE
		BEGIN
			SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode			
			SET @Exist=1
		END		
		
		SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode		
		SELECT @ClsTransId=TransId FROM ClusterScreens WHERE TransName=@ClsCategory

		IF @Exist=1 
		BEGIN
			EXEC Proc_DependencyCheck 'ClusterGroupMaster',@ClusterId
			IF (SELECT COUNT(*) FROM TempDepCheck)>0
			BEGIN
				SET @Exist=2
			END			
		END

		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				INSERT INTO ClusterGroupMaster(ClsGroupId,ClsGroupCode,ClsGroupName,ClsType,ClsTransId,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DownLoaded,AppReqd)			
				VALUES(@ClsGroupId,@ClsGroupCode,@ClsGroupName,(CASE @ClsGroupType WHEN 'Exclusive' THEN 0 ELSE 1 END),@ClsTransId,1,1,GETDATE(),1,GETDATE(),
				1,(CASE @AppReqd WHEN 'Yes' THEN 1 ELSE 0 END))
			
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterGroupMaster' AND FldName='ClsGroupId'	  
				DELETE FROM ClusterGroupDetails WHERE ClsGroupId=@ClsGroupId				
			END		
			ELSE 
			BEGIN
				UPDATE ClusterGroupMaster SET ClsGroupName=@ClsGroupName
				WHERE ClsGroupId=@ClsGroupId				
			END
		
			IF @Exist<>2
			BEGIN
				DELETE FROM ClusterGroupDetails WHERE ClsGroupId=@ClsGroupId
				INSERT INTO ClusterGroupDetails(ClsGroupId,ClusterId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@ClsGroupId,@ClusterId,1,1,GETDATE(),1,GETDATE())
			END
		END

		FETCH NEXT FROM Cur_ClusterMaster INTO @ClsGroupCode,@ClsGroupName,@ClsCategory,@AppReqd,@ClsGroupType,@ClusterCode,@ClusterName
	END
	CLOSE Cur_ClusterMaster
	DEALLOCATE Cur_ClusterMaster

	UPDATE Cn2Cs_Prk_ClusterGroup SET DownLoadFlag='Y' WHERE 
	DownLoadFlag ='D' AND ClsGroupCode IN (SELECT ClsGroupCode FROM ClusterGroupMaster)
	AND ClsGroupCode NOT IN (SELECT ClsGrpCode FROM ClsGrpToAvoid)

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-065

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_ClusterAssign]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_ClusterAssign]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_ClusterAssign 0
SELECT * FROM Cs2Cn_Prk_ClusterAssign ORDER BY SlNo
SELECT * FROM ClusterAssign WHERE MasterId=79
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_ClusterAssign]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_ClusterAssign
* PURPOSE		: To Extract Cluster Assign Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 18/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_ClusterAssign WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_ClusterAssign
	(
		DistCode,
		ClusterId,
		ClusterCode,
		ClusterName,
		ClsGroupId,
		ClsGroupCode,
		ClsGroupName,
		ClsCategory,
		MasterId,
		MasterCmpCode,
		MasterDistCode,
		MasterName,
		AssignDate,
		UploadFlag
	)
	SELECT @DistCode,CA.ClusterId,CM.ClusterCode,CM.ClusterName,CGM.ClsGroupId,CGM.ClsGroupCode,CGM.ClsGroupName,
	CS.TransName,CA.MasterRecordId,R.CmpRtrCode,R.RtrCode,R.RtrName,CA.AssignDate,'N' 
	FROM ClusterAssign CA,ClusterMaster CM,ClusterScreens CS,
	ClusterGroupMaster CGM,ClusterGroupDetails CGD,Retailer R
	WHERE CA.ClusterId=CM.ClusterId AND CA.MasterId=CS.TransID AND CGM.ClsGroupId=CGD.ClsGroupId AND 
	CGD.ClusterId=CM.ClusterId AND CGD.ClusterId=CA.ClusterId AND CA.MasterId=79 AND CA.MasterRecordId=R.RtrId AND CA.Upload=0

	UPDATE ClusterAssign SET Upload=1
	WHERE ClusterId IN (SELECT ClusterId FROM Cs2Cn_Prk_ClusterAssign)
	AND MasterRecordId=79 AND Upload=0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-066

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterAssignApproval]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterAssignApproval]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterAssignApproval 0
SELECT * FROM Cn2Cs_Prk_ClusterAssignApproval
SELECT * FROM Errorlog
SELECT * FROM ClusterAssign
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterAssignApproval]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterAssignApproval
* PURPOSE		: To validate the downloaded Cluster Assign Approval details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 18/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)

	DECLARE @MasterCmpCode 	NVARCHAR(50)
	DECLARE @MasterDistCode	NVARCHAR(50)
	DECLARE @ClusterCode 	NVARCHAR(50)
	DECLARE @Status		  	NVARCHAR(50)
	DECLARE @AssignDate	  	DATETIME
	
	DECLARE @ClusterId  	INT
	DECLARE @Exist		 	INT	
	DECLARE @RtrId  		INT

	DECLARE @ClsGroupId  	INT
	DECLARE @ClsGrpType		INT

	SET @TabName = 'Cn2Cs_Prk_ClusterAssignApproval'
	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsAppToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClsAppToAvoid	
	END

	CREATE TABLE ClsAppToAvoid
	(
		ClusterCode NVARCHAR(50),
		MasterCmpCode NVARCHAR(50)
	)

	IF EXISTS(SELECT DISTINCT ClusterCode,MasterCmpCode FROM Cn2Cs_Prk_ClusterAssignApproval
	WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster))
	BEGIN
		INSERT INTO ClsAppToAvoid(ClusterCode,MasterCmpCode)
		SELECT DISTINCT ClusterCode,MasterCmpCode FROM Cn2Cs_Prk_ClusterAssignApproval
		WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Assign','ClusterCode','Cluster Code:'+ClusterCode+' not found' FROM Cn2Cs_Prk_ClusterAssignApproval
		WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster)
	END		

	IF EXISTS(SELECT DISTINCT ClusterCode,MasterCmpCode FROM Cn2Cs_Prk_ClusterAssignApproval
	WHERE MasterCmpCode NOT IN (SELECT CmpRtrCode FROM Retailer))
	BEGIN
		INSERT INTO ClsAppToAvoid(ClusterCode,MasterCmpCode)
		SELECT DISTINCT ClusterCode,MasterCmpCode FROM Cn2Cs_Prk_ClusterAssignApproval
		WHERE MasterCmpCode NOT IN (SELECT CmpRtrCode FROM Retailer)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Assign','MasterCmpCode','Retailer:'+MasterCmpCode+' not found' FROM Cn2Cs_Prk_ClusterAssignApproval
		WHERE MasterCmpCode NOT IN (SELECT CmpRtrCode FROM Retailer)
	END
	
	DECLARE Cur_ClusterAssign CURSOR
	FOR SELECT MasterCmpCode,MasterDistCode,ClusterCode,Status,AssignDate
	FROM Cn2Cs_Prk_ClusterAssignApproval WHERE [DownLoadFlag] ='D' AND
	ClusterCode NOT IN (SELECT ClusterCode FROM ClsAppToAvoid)
	OPEN Cur_ClusterAssign
	FETCH NEXT FROM Cur_ClusterAssign INTO @MasterCmpCode,@MasterDistCode,@ClusterCode,@Status,@AssignDate
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0		

		SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode
		SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@MasterCmpCode		

		SELECT @ClsGroupId=ClsGroupId FROM ClusterGroupDetails		
		SELECT @ClsGrpType=ClsType FROM ClusterGroupMaster

		IF @ClsGrpType=0 
		BEGIN
			DELETE FROM ClusterAssign WHERE ClusterId IN (SELECT ClusterId FROM ClusterGRoupDetails WHERE ClsGroupId=@ClsGroupId)
			AND ClusterId<>@ClusterId AND MasterRecordId=@RtrId
		END
	
		IF EXISTS(SELECT * FROM ClusterAssign WHERE ClusterId=@ClusterId AND MasterRecordId=@RtrId)
		BEGIN
			INSERT INTO ClusterAssign(ClusterId,MasterId,MasterRecordId,Status,Upload,AssignDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@ClusterId,79,@RtrId,(CASE @Status WHEN 'Approved' THEN 1 ELSE 0 END),1,GETDATE(),1,1,GETDATE(),1,GETDATE())
		END	
		ELSE
		BEGIN
			IF @Status='Approved'
			BEGIN
				UPDATE ClusterAssign SET Status=1
				WHERE ClusterId=@ClusterId AND MasterRecordId=@RtrId 
			END
			ELSE
			BEGIN
				DELETE FROM ClusterAssign WHERE ClusterId=@ClusterId AND MasterRecordId=@RtrId 
			END
		END
		
		FETCH NEXT FROM Cur_ClusterAssign INTO @MasterCmpCode,@MasterDistCode,@ClusterCode,@Status,@AssignDate
	END
	CLOSE Cur_ClusterAssign
	DEALLOCATE Cur_ClusterAssign

	UPDATE Cn2Cs_Prk_ClusterAssignApproval SET DownLoadFlag='Y' WHERE 
	DownLoadFlag ='D' AND ClusterCode+'~'+MasterCmpCode NOT IN (SELECT ClusterCode+'~'+MasterCmpCode FROM ClsAppToAvoid)

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-067

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_SchemeUtilizationDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_SchemeUtilizationDetails]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_SchemeUtilizationDetails]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[TransName] [nvarchar](50) NULL,
	[SchUtilizeType] [nvarchar](50) NULL,
	[CmpCode] [nvarchar](100) NULL,
	[CmpSchCode] [nvarchar](50) NULL,
	[SchCode] [nvarchar](50) NULL,
	[SchDescription] [nvarchar](200) NULL,
	[SchType] [nvarchar](50) NULL,
	[SlabId] [int] NULL,
	[TransNo] [nvarchar](50) NULL,
	[TransDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[CmpRtrCode] [nvarchar](50) NULL,
	[RtrCode] [nvarchar](50) NULL,
	[BilledPrdCCode] [nvarchar](50) NULL,
	[BilledPrdBatCode] [nvarchar](50) NULL,
	[BilledQty] [int] NULL,
	[SchUtilizedAmt] [numeric](38, 6) NULL,
	[SchDiscPerc] [numeric](38, 6) NULL,
	[FreePrdCCode] [nvarchar](50) NULL,
	[FreePrdBatCode] [nvarchar](50) NULL,
	[FreeQty] [int] NULL,
	[UploadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-068

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_SchemeUtilizationDetails_Archive]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_SchemeUtilizationDetails_Archive]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_SchemeUtilizationDetails_Archive]
(
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [nvarchar](50) NULL,
	[TransName] [nvarchar](50) NULL,
	[SchUtilizeType] [nvarchar](50) NULL,
	[CmpCode] [nvarchar](100) NULL,
	[CmpSchCode] [nvarchar](50) NULL,
	[SchCode] [nvarchar](50) NULL,
	[SchDescription] [nvarchar](200) NULL,
	[SchType] [nvarchar](50) NULL,
	[SlabId] [int] NULL,
	[TransNo] [nvarchar](50) NULL,
	[TransDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[CmpRtrCode] [nvarchar](50) NULL,
	[RtrCode] [nvarchar](50) NULL,
	[BilledPrdCCode] [nvarchar](50) NULL,
	[BilledPrdBatCode] [nvarchar](50) NULL,
	[BilledQty] [int] NULL,
	[SchUtilizedAmt] [numeric](38, 6) NULL,
	[SchDiscPerc] [numeric](38, 6) NULL,
	[FreePrdCCode] [nvarchar](50) NULL,
	[FreePrdBatCode] [nvarchar](50) NULL,
	[FreeQty] [int] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-069

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_SchemeUtilizationDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_SchemeUtilizationDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_SchemeUtilizationDetails 0
SELECT * FROM Cs2Cn_Prk_SchemeUtilizationDetails
--SELECT * FROM SalesInvoiceSchemeLineWise
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cs2Cn_SchemeUtilizationDetails]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_SchemeUtilizationDetails
* PURPOSE		: To Extract Scheme Utilization Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 19/10/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @ChkSRDate	AS DATETIME

	SET @Po_ErrNo=0

	DELETE FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE UploadFlag = 'Y'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 1
	SELECT @ChkSRDate = NextUpDate FROM DayEndProcess Where ProcId = 4

	--->Billing-Scheme Amount
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,(ISNULL(SUM(FlatAmount),0)+ISNULL(SUM(DiscountPerAmount),0)) As Utilized,		
	A.DiscPer,'','',0,'N'
	FROM SalesInvoiceSchemeLineWise A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId = B.SalId AND A.SalId=SIP.SalId AND SIP.PrdId=A.PrdID AND SIP.PrdBatId=A.PrdBatId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0 AND (FlatAmount+DiscountPerAmount)>0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,A.DiscPer

	--->Billing-Free Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','Free Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Free Product','',0,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0) As Utilized,0,
	P.PrdCCode,C.PrdBatCode,SUM(FreeQty) as FreeQty,'N'
	FROM SalesInvoiceSchemeDtFreePrd A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.FreePrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode
	
	--->Billing-Gift Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','Gift Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Gift Product','',0,ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0) As Utilized,0,
	P.PrdCCode,C.PrdBatCode,SUM(GiftQty) as GiftQty,'N'
	FROM SalesInvoiceSchemeDtFreePrd A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.GiftPrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode

	--->Billing-Window Display
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','WDS',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	0,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(AdjAmt),0) As Utilized,0,
	'','',0,'N'
	FROM SalesInvoiceWindowDisplay A
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode
	
	--->Billing-QPS Credit Note Conversion
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','QPS Converted Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(A.CrNoteAmount),0) As Utilized,0,
	'','',0,'N'
	FROM SalesInvoiceQPSSchemeAdj A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId AND Mode=1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode

	UNION ALL

	SELECT @DistCode,'Billing','QPS Converted Amount(Auto)',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,'AutoQPSConversion' AS SalInvNo,A.LastModDate,A.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(A.CrNoteAmount),0) As Utilized,0,
	'','',0,'N'
	FROM SalesInvoiceQPSSchemeAdj A 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId AND Mode=2
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Retailer R ON R.RtrId = A.RtrId
	WHERE CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,A.LastModDate,
	A.RtrId,R.CmpRtrCode,R.RtrCode

	--->Cheque Disbursal
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Cheque Disbursal','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	0,B.ChqDisRefNo,A.ChqDisDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(Amount),0) As Utilized,0,
	'','',0,'N'
	FROM ChequeDisbursalMaster A
	INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo
	INNER JOIN SchemeMaster SM ON A.TransId = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE TransType = 1 AND CM.CmpID = @CmpID AND A.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,B.ChqDisRefNo,A.ChqDisDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode

	--->Sales Return-Amount
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,-1 * (ISNULL(SUM(ReturnFlatAmount),0) + ISNULL(SUM(ReturnDiscountPerAmount),0)),0,	
	'','',0,'N'
	FROM ReturnSchemeLineDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN ReturnProduct SIP ON SIP.ReturnId = B.ReturnId AND A.ReturnId=SIP.ReturnId AND SIP.PrdId=A.PrdId AND SIP.PrdBatId=A.PrdBatId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty

	--->Sales Return-Free Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Free Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Free Product','',0,-1 * ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0),0,
	P.PrdCCode,C.PrdBatCode,-1 * SUM(ReturnFreeQty),'N'
	FROM ReturnSchemeFreePrdDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.FreePrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode

	--->Sales Return-Gift Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Gift Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Gift Product','',0,-1 * ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0),0,
	P.PrdCCode,C.PrdBatCode,-1 * SUM(ReturnGiftQty),'N'
	FROM ReturnSchemeFreePrdDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.GiftPrdId = P.PrdId 
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode

	SELECT SchId INTO #SchId FROM SchemeMaster WHERE SchCode IN (SELECT SchCode FROM Cs2Cn_Prk_SchemeUtilizationDetails
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-070

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ReasonMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ReasonMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_ReasonMaster
EXEC Proc_Cn2Cs_ReasonMaster 0
SELECT * FROM Counters WHERE TabName='ReasonMaster'
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ReasonMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ReasonMaster
* PURPOSE		: To Download the Reason details from Console to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @Exists				INT

	DECLARE @ReasonId			INT
	DECLARE @DistCode			NVARCHAR(100)
	DECLARE @ReasonCode			NVARCHAR(100)
	DECLARE @Description		NVARCHAR(100)
	DECLARE @ApplicableTo		NVARCHAR(100)


	SET @ErrStatus=1
	SET @Po_ErrNo=0

	SET @Tabname = 'Cn2Cs_Prk_ReasonMaster'

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ReasonToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ReasonToAvoid	
	END
	CREATE TABLE ReasonToAvoid
	(		
		RSMCode		NVARCHAR(200)
	)

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')='') 
	BEGIN
		INSERT INTO ReasonToAvoid(RSMCode)
		SELECT ReasonCode FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_ReasonMaster','Reason Code','Reason code should not be empty'
		FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')=''
	END	

	DECLARE Cur_Reason CURSOR	
	FOR SELECT DISTINCT ReasonCode,Description
	FROM Cn2Cs_Prk_ReasonMaster WHERE DownloadFlag='D' AND ISNULL(ReasonCode,'')<>''
	OPEN Cur_Reason
	FETCH NEXT FROM Cur_Reason INTO @ReasonCode,@Description
	WHILE @@FETCH_STATUS=0
	BEGIN		

		IF NOT EXISTS(SELECT * FROM ReasonMaster WHERE ReasonCode=@ReasonCode)
		BEGIN
			SET @ReasonId=0
			SET @ReasonId = dbo.Fn_GetPrimaryKeyInteger('ReasonMaster','ReasonId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
			IF @ReasonId>0
			BEGIN
				INSERT INTO ReasonMaster(ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
				DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,StkTransferScreen,
				BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@ReasonId,@ReasonCode,@Description,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,GETDATE(),1,GETDATE())
			END
			ELSE
			BEGIN
				SET @ErrDesc='Check the System Date'
				INSERT INTO Errorlog VALUES (1,@TabName,'Description',@ErrDesc)
		  		SET @Po_ErrNo=1
			END
		END
		ELSE
		BEGIN
			SELECT @ReasonId=ReasonId FROM ReasonMaster WHERE ReasonCode=@ReasonCode
			UPDATE ReasonMaster SET PurchaseReceipt=0,SalesInvoice=0,VanLoad=0,CrNoteSupplier=0,CrNoteRetailer=0,
			DeliveryProcess=0,SalvageRegister=0,PurchaseReturn=0,SalesReturn=0,VanUnload=0,DbNoteSupplier=0,DbNoteRetailer=0,
			StkAdjustment=0,StkTransferScreen=0,BatchTransfer=0,ReceiptVoucher=0,ReturnToCompany=0,LocationTrans=0,
			Billing=0,ChequeBouncing=0,ChequeDisbursal=0 WHERE ReasonId=@ReasonId 
		END
		
		IF @Po_ErrNo=0
		BEGIN
			DECLARE Cur_ReasonApplicable CURSOR	
			FOR SELECT DISTINCT ReasonCode,Description,ApplicableTo
			FROM Cn2Cs_Prk_ReasonMaster WHERE DownloadFlag='D' AND ReasonCode=@ReasonCode
			OPEN Cur_ReasonApplicable
			FETCH NEXT FROM Cur_ReasonApplicable INTO @ReasonCode,@Description,@ApplicableTo
			WHILE @@FETCH_STATUS=0
			BEGIN		

				SET @sSql=''

				IF @ApplicableTo='All'
				BEGIN
					SET @sSql='UPDATE ReasonMaster SET PurchaseReceipt=1,SalesInvoice=1,VanLoad=1,CrNoteSupplier=1,CrNoteRetailer=1,
					DeliveryProcess=1,SalvageRegister=1,PurchaseReturn=1,SalesReturn=1,VanUnload=1,DbNoteSupplier=1,DbNoteRetailer=1,
					StkAdjustment=1,StkTransferScreen=1,BatchTransfer=1,ReceiptVoucher=1,ReturnToCompany=1,LocationTrans=1,Billing=1,
					ChequeBouncing=1,ChequeDisbursal=1 WHERE ReasonId='+CAST(@ReasonId AS NVARCHAR(10))
				END
				ELSE
				BEGIN
					IF NOT EXISTS (SELECT Id,Name FROM SysColumns WHERE Name = @ApplicableTo AND Id IN (SELECT Id FROM 
					SysObjects WHERE Name ='ReasonMaster'))
					BEGIN
						SET @sSql='UPDATE ReasonMaster SET '+@ApplicableTo+'=1 WHERE ReasonId='+CAST(@ReasonId AS NVARCHAR(10))
					END					
				END

				IF LTRIM(RTRIM(@sSql))<>''
				BEGIN
					EXEC (@sSql)
				END

				FETCH NEXT FROM Cur_ReasonApplicable INTO @ReasonCode,@Description,@ApplicableTo
			END
			CLOSE Cur_ReasonApplicable
			DEALLOCATE Cur_ReasonApplicable
		END		

		FETCH NEXT FROM Cur_Reason INTO @ReasonCode,@Description
	END
    CLOSE Cur_Reason
	DEALLOCATE Cur_Reason

	UPDATE Cn2Cs_Prk_ReasonMaster SET DownloadFlag='Y' WHERE DownloadFlag='D' AND ISNULL(ReasonCode,'')<>''

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-071

DROP PROCEDURE Proc_CS2CN_NS_PriceApproved
DROP PROCEDURE Proc_Cn2Cs_NESProductBatch
DROP PROCEDURE Proc_Cn2CS_NSPriceApproval
DROP PROCEDURE Proc_Cn2Cs_LRProduct
DROP PROCEDURE Proc_Cn2Cs_ETL_Prk_Product
DROP PROCEDURE Proc_Cn2Cs_Prk_RetailerCategory
DROP PROCEDURE Proc_Cn2Cs_ImportProductClaimNorm
DROP PROCEDURE Proc_Cn2Cs_SMProduct

--SRF-Nanda-165-072

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_ContractPricing]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_ContractPricing]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_ContractPricing]
(
	[CmpId] [int] NULL,
	[CtgLevelId] [int] NULL,
	[CtgMainId] [int] NULL,
	[RtrClassId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[RtrId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PriceId] [int] NULL,
	[DiscountPerc] [numeric](38, 6) NULL,
	[FlatAmount] [numeric](38, 6) NULL,
	[EffectiveDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[RtrTaxGroupId] [int] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-073

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_SpecialRate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_SpecialRate]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_SpecialRate]
(
	[CtgLevelName] [nvarchar](100) NULL,
	[CtgCode] [nvarchar](100) NULL,
	[RtrCode] [nvarchar](100) NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[SpecialSellingRate] [numeric](38, 6) NULL,
	[EffectiveFromDate] [datetime] NULL,
	[EffectiveToDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[DownLoadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-074

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_ERPPrdCCodeMapping]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_ERPPrdCCodeMapping]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_ERPPrdCCodeMapping]
(
	[DistCode] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[ERPPrdCode] [nvarchar](100) NULL,
	[MappedDate] [datetime] NULL,
	[DownLoadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-075

if exists (select * from dbo.sysobjects where id = object_id(N'[ERPPrdCCodeMapping]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ERPPrdCCodeMapping]
GO

CREATE TABLE [dbo].[ERPPrdCCodeMapping]
(
	[PrdCCode] [nvarchar](50) NULL,
	[ERPPrdCode] [nvarchar](100) NULL,
	[MappedDate] [datetime] NULL,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

--SRF-Nanda-165-076

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_SpecialRate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_SpecialRate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec Proc_Import_SpecialRate '<Root></Root>'
CREATE          PROCEDURE [dbo].[Proc_Import_SpecialRate]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_SpecialRate
* PURPOSE		: To Insert records from xml file in the Table Cn2Cs_Prk_SpecialRate
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 04/05/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER 
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_SpecialRate(CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,
	SpecialSellingRate,EffectiveFromDate,EffectiveToDate,CreatedDate,DownLoadFlag)
	SELECT [RtrHierName],[RtrHierCode],[RtrCode],[ProductCode],[BatchCode],
	[SellingRate],[EffFromDate],[EffToDate],[CreatedDate],[DownloadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_GroupPricing',1)
	WITH 
	(
		[RtrHierName] 	NVARCHAR(100),
		[RtrHierCode] 	NVARCHAR(100),
		[RtrCode] 		NVARCHAR(100),
		[ProductCode] 	NVARCHAR(100),
		[BatchCode] 	NVARCHAR(100),
		[SellingRate] 	NUMERIC(18,6),
		[EffFromDate]	DATETIME,
		[EffToDate]		DATETIME,
		[CreatedDate]	DATETIME,
		[DownloadFlag] 	NVARCHAR(10)
	) XMLObj
	EXEC sp_xml_removedocument @hDoc 
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-077

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_ERPPrdCCodeMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_ERPPrdCCodeMapping]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Import_ERPPrdCCodeMapping '<Root></Root>'

CREATE   PROCEDURE [dbo].[Proc_Import_ERPPrdCCodeMapping]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_ERPPrdCCodeMapping
* PURPOSE		: To Insert the records from xml file in the Table ERP Product Mapping
* CREATED		: Nandakumar R.G
* CREATED DATE	: 21/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
    
	INSERT INTO Cn2Cs_Prk_ERPPrdCCodeMapping(DistCode,PrdCCode,ERPPrdCode,MappedDate,DownLoadFlag)
	SELECT DistCode,PrdCCode,ERPPrdCode,MappedDate,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2CS_ERPPrdCCodeMapping',1)
	WITH 
	(
				[DistCode]			NVARCHAR(50),
				[PrdCCode]			NVARCHAR(50),
				[ERPPrdCode]		NVARCHAR(100),
				[MappedDate]		DATETIME,				
				[DownLoadFlag]		NVARCHAR(10)
	) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-078

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Validate_ContractPricing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Validate_ContractPricing]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
BEGIN TRANSACTION
--SELECT DISTINCT * FROM Cn2Cs_Prk_ContractPricing
EXEC Proc_Validate_ContractPricing 0
SELECT * FROM ErrorLog
SELECT * FROM ContractPricingMaster
SELECT * FROM ContractPricingDetails
ROLLBACK TRANSACTION
*/
CREATE         PROCEDURE [dbo].[Proc_Validate_ContractPricing]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_ContractPricing(Base:Proc_ValidateBLContractPricing)
* PURPOSE		: To Insert Contract Pricing Details for Special Rates
* CREATED		: Nandakumar R.G
* CREATED DATE	: 04/05/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 21/10/2010	Nanda		 Effective From/To Date changes
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @EffectiveDate		AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @CmpId				AS INT
	DECLARE @RtrId				AS INT
	DECLARE @CtgMainId			AS INT
	DECLARE @CtgLevelId			AS INT
	DECLARE @PrdCtgValMainId	AS INT
	DECLARE @RtrClassId			AS INT
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdId				AS INT
	DECLARE @ContractId			AS INT
	DECLARE @RtrTaxGroupId		AS INT
	DECLARE @PrdBatId			AS INT
	DECLARE @PriceId			AS INT	

	DECLARE @ConRefNo			AS NVARCHAR(100)	

	DECLARE @Disc				AS NUMERIC(38,6)
	DECLARE @FlatAmt			AS NUMERIC(38,6)
 	
	SET @Po_ErrNo =0

	DECLARE Cur_ContPrice CURSOR
	FOR SELECT DISTINCT CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,RtrId,EffectiveDate,ToDate,RtrTaxGroupId
	FROM Cn2Cs_Prk_ContractPricing
	WHERE EffectiveDate<=GETDATE()
	ORDER BY CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,RtrId,EffectiveDate,ToDate,RtrTaxGroupId
	OPEN Cur_ContPrice
	FETCH NEXT FROM Cur_ContPrice INTO @CmpId,@CtgLevelId,@CtgMainId,@RtrClassId,@CmpPrdCtgId,@PrdCtgValMainId,
	@RtrId,@EffectiveDate,@ToDate,@RtrTaxGroupId
	WHILE @@FETCH_STATUS=0
	BEGIN  		
		SET @ContractId=0                		
		SET @ConRefNo=''

		SELECT @ContractId= dbo.Fn_GetPrimaryKeyInteger('ContractPricingMaster','ContractId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
		SELECT @ConRefNo= dbo.Fn_GetPrimaryKeyString('ContractPricingMaster','ConRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))

		IF @ContractId>(SELECT ISNULL(MAX(ContractId),0) AS ContractId FROM ContractPricingMaster) AND @ConRefNo<>''
		BEGIN
			INSERT INTO ContractPricingMaster(ContractId,CmpId,CtgLevelId,CtgMainId,RtrClassId,
			CmpPrdCtgId,PrdCtgValMainId,RtrId,RtrTaxGroupId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
			DisplayMode,ConRefNo,ConDate,ValidFromDate,ValidTillDate,Status,AllowDiscount)
			VALUES(@ContractId,@CmpId,@CtgLevelId,@CtgMainId,@RtrClassId,@CmpPrdCtgId,@PrdCtgValMainId,
			@RtrId,@RtrTaxGroupId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),
			0,@ConRefNo,GETDATE(),@EffectiveDate,@ToDate,1,0)

			UPDATE Counters SET CurrValue = CurrValue+1 WHERE TabName = 'ContractPricingMaster'
			AND FldName = 'ContractId'

			UPDATE Counters SET CurrValue = CurrValue+1 WHERE TabName = 'ContractPricingMaster'
			AND FldName = 'ConRefNo'

			INSERT INTO ContractPricingDetails(ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,
			Availability,LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId,ClaimablePercOnMRP)
			SELECT @ContractId,PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount,1,1,GETDATE(),1,GETDATE(),0,0
			FROM Cn2Cs_Prk_ContractPricing WHERE CmpId= @CmpId AND CtgLevelId= @CtgLevelId AND
			CtgMainId= @CtgMainId AND RtrClassId= @RtrClassId AND CmpPrdCtgId = @CmpPrdCtgId AND
			PrdCtgValMainId = @PrdCtgValMainId AND RtrId = @RtrId
			AND RtrTaxGroupId=@RtrTaxGroupId AND EffectiveDate=@EffectiveDate
			ORDER BY PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount
		END
		ELSE
		BEGIN
			INSERT INTO Errorlog VALUES (1,'Cn2Cs_Prk_ContractPricing','System Date',
			'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
			SET @Po_ErrNo=1
			CLOSE Cur_ContPrice
			DEALLOCATE Cur_ContPrice
			RETURN
		END

		FETCH NEXT FROM Cur_ContPrice INTO @CmpId,@CtgLevelId,@CtgMainId,@RtrClassId,@CmpPrdCtgId,@PrdCtgValMainId,
		@RtrId,@EffectiveDate,@ToDate,@RtrTaxGroupId
	END
	CLOSE Cur_ContPrice
	DEALLOCATE Cur_ContPrice
	IF @Po_ErrNo=0
	BEGIN
		DELETE FROM Cn2Cs_Prk_ContractPricing WHERE EffectiveDate<=GETDATE()
	END		
	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-079

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SpecialRate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SpecialRate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
-- DELETE FROM ContractPricingDetails WHERE ContractId>28
-- DELETE FROM ContractPricingMaster WHERE ContractId>28
--SELECT * FROM Cn2Cs_Prk_SpecialRate
EXEC Proc_Cn2Cs_SpecialRate 0
--SELECT COUNT(*) FROM ProductBatch --WHERE PrdBatId=21
--SELECT * FROM ProductBatchDetails --WHERE PrdBatId=22 ORDER BY priceid,SlNo
--DELETE FROM ProductBatchDetails WHERE PriceId>51
--SELECT * FROM ETL_Prk_BLContractPricing
--SELECT * FROM ErrorLog
--DELETE FROM ErrorLog
--SELECT * FROM ContractPricingMaster
--SELECT * FROM ContractPricingDetails --WHERE ContractId IN (20,21,22)--PriceId IN (29,30)
--SELECT * FROM SpecialRateAftDownLoad
--DELETE FROM SpecialRateAftDownLoad WHERE PrdCCode='TSRReCalcPrd'
ROLLBACK TRANSACTION
*/
CREATE	PROCEDURE [dbo].[Proc_Cn2Cs_SpecialRate]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SpecialRate
* PURPOSE		: To Insert and Update Special Rate records in the Table Product Batch Details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 04/05/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 21/10/2010	Nanda		 Effective From/To Date changes
*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @RtrHierLevelCode 		AS  NVARCHAR(100)
	DECLARE @RtrHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @RtrCode				AS 	NVARCHAR(100)
	
	DECLARE @PrdCCode				AS 	NVARCHAR(100)
	DECLARE @PrdBatCode				AS 	NVARCHAR(100)
	DECLARE @PrdBatCodeAll			AS 	NVARCHAR(100)
	DECLARE @PriceCode				AS 	NVARCHAR(4000)
	DECLARE @SplRate				AS 	NUMERIC(38,6)
	DECLARE @PrdCtgValMainId		AS	INT
	DECLARE @CtgLevelId				AS 	INT
	DECLARE @CtgMainId				AS 	INT
	DECLARE @RtrId 					AS 	INT
	DECLARE @PrdId 					AS 	INT
	DECLARE @PrdBatId				AS 	INT
	DECLARE @PriceId				AS 	INT
	DECLARE @ContractReq			AS 	INT
	DECLARE @SRReCalc				AS 	INT
	DECLARE @ReCalculatedSR			AS 	NUMERIC(38,6)
	DECLARE @EffFromDate			AS 	DATETIME
	DECLARE @EffToDate				AS 	DATETIME
	DECLARE @CreatedDate			AS 	DATETIME
	
	DECLARE @MulTaxGrp				AS 	INT
	DECLARE @TaxGroupId				AS	INT
	DECLARE @MulRtrId				AS	INT
	DECLARE @MulTaxGroupId			AS 	INT
	DECLARE @DownldSplRate			AS 	NUMERIC(38,6)
	DECLARE @ContHistExist			AS	INT
	DECLARE @ContractPriceIds		AS	NVARCHAR(1000)
	DECLARE @RefPriceId				AS	INT
	DECLARE @CmpId					AS	INT
	DECLARE @CmpPrdCtgId			AS	INT
	DECLARE @RefRtrId				AS	INT
	DECLARE @ErrStatus				AS	INT
	SET @Po_ErrNo=0
	SET @ErrStatus=0
	
	SELECT @ContractReq=ISNULL(Status,0) FROM Configuration WHERE ModuleId In ('BL2')
	SELECT @SRReCalc=ISNULL(Status,0) FROM Configuration WHERE ModuleId In ('BL1')
	SET @ContractReq=1
	
	TRUNCATE TABLE ETL_Prk_BLContractPricing	
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SplRateToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SplRateToAvoid	
	END
	CREATE TABLE SplRateToAvoid
	(
		RtrHierLevel	NVARCHAR(100),
		RtrHierValue	NVARCHAR(100),
		RtrCode			NVARCHAR(100),
		PrdCCode		NVARCHAR(100),
		PrdBatCode		NVARCHAR(100)
	)
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','ProductCode','Product Code:'+PrdCCode+' Not Available' FROM Cn2Cs_Prk_SpecialRate
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate
	WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId))
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','ProductCode','Batch is not available for Product Code:'+PrdCCode FROM Cn2Cs_Prk_SpecialRate
		WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate
	WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel))
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level','Retailer Category Level:'+CtgLevelName+' Not Available' FROM Cn2Cs_Prk_SpecialRate
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate
	WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory))
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level Value','Retailer Category Level Value:'+CtgCode+' Not Available' FROM Cn2Cs_Prk_SpecialRate
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate WHERE EffectiveFromDate>GETDATE())
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE EffectiveFromDate>GETDATE()
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Effective From Date','Effective Date :'+CAST(EffectiveFromDate AS NVARCHAR(12))+' is greater ' 
		FROM Cn2Cs_Prk_SpecialRate
		WHERE EffectiveFromDate>GETDATE()
	END
	SELECT @CmpId=ISNULL(CmpId,0) FROM Company C WHERE DefaultCompany=1
	DECLARE Cur_SpecialRate CURSOR
	FOR SELECT ISNULL(Prk.CtgLevelName,''),ISNULL(Prk.CtgCode,''),
	ISNULL(Prk.RtrCode,''),ISNULL(Prk.PrdCCode,''),ISNULL(Prk.PrdBatCode,''),ISNULL(SpecialSellingRate,0),
	ISNULL(Prk.EffectiveFromDate,GETDATE()),ISNULL(Prk.EffectiveToDate,GETDATE()),ISNULL(CreatedDate,GETDATE()),ISNULL(P.PrdId,0) AS PrdId,
	ISNULL(RCL.CtgLevelId,0) AS CtgLevelId,ISNULL(RC.CtgMainId,0) AS CtgMainId
	FROM Cn2Cs_Prk_SpecialRate Prk 
	INNER JOIN Product P ON Prk.PrdCCode=P.PrdCCode 
	INNER JOIN RetailerCategoryLevel RCL ON Prk.CtgLevelName=RCL.CtgLevelName 
	INNER JOIN RetailerCategory RC ON Prk.CtgCode=RC.CtgCode	
	WHERE Prk.DownloadFlag='D' AND Prk.EffectiveFromDate<=GETDATE() AND Prk.CtgLevelName+'~'+Prk.CtgCode
	+'~'+Prk.RtrCode+'~'+Prk.PrdCCode+'~'+Prk.PrdBatCode
	NOT IN(SELECT RtrHierLevel+'~'+RtrHierValue+'~'+RtrCode+'~'+PrdCCode+'~'+PrdBatCode FROM SplRateToAvoid)
	ORDER BY Prk.CtgLevelName,Prk.CtgCode,Prk.RtrCode,Prk.PrdCCode,
	Prk.PrdBatCode,SpecialSellingRate,EffectiveFromDate,EffectiveToDate,CreatedDate
	OPEN Cur_SpecialRate	
	FETCH NEXT FROM Cur_SpecialRate INTO @RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
	@PrdCCode,@PrdBatCodeAll,@SplRate,@EffFromDate,@EffToDate,@CreatedDate,@PrdId,@CtgLevelId,@CtgMainId
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @ContractPriceIds=''
		SELECT @PrdCtgValMainId=ISNULL(P.PrdCtgValMainId,0)
		FROM Product P,ProductCategoryValue PCV
		WHERE P.PrdCtgValMainId=PCV.PrdCtgValMainId AND P.PrdId=@PrdId
		SELECT @CmpPrdCtgId=ISNULL(PCL.CmpPrdCtgId,0) FROM ProductCategoryLevel PCL,ProductCategoryValue PCV
		WHERE PCL.CmpPrdCtgId=PCV.CmpPrdCtgId AND PCV.PrdCtgValMainId=@PrdCtgValMainId
		IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[BLCmpBatCode]')	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
		BEGIN
			DROP TABLE [BLCmpBatCode]				
		END
		
		CREATE  TABLE [BLCmpBatCode]
		(
			[CmpBatCode] NVARCHAR(100)	
		)
		INSERT INTO BLCmpBatCode
		SELECT CmpBatCode			
		FROM ProductBatch WHERE PrdId=@PrdId AND
		CmpBatCode=(CASE @PrdBatCodeAll WHEN 'All' THEN CmpBatCode ELSE @PrdBatCodeAll END)
		
		DECLARE Cur_Batch CURSOR
		FOR SELECT CmpBatCode FROM BLCmpBatCode
		OPEN Cur_Batch	
		FETCH NEXT FROM Cur_Batch INTO @PrdBatCode
		WHILE @@FETCH_STATUS=0
		BEGIN
			SELECT @PrdBatId=ISNULL(PrdBatId,0) FROM ProductBatch WITH (NOLOCK) WHERE CmpBatCode=@PrdBatCode AND PrdId=@PrdId
			IF @SRReCalc=2
			BEGIN				
				IF (SELECT COUNT(DISTINCT R.TaxGroupId) 
				FROM RetailerValueClass RVC,RetailerValueClassMap RVCM,Retailer R
				WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
				AND CtgMainId=@CtgMainId)>1
				BEGIN
					SET @MulTaxGrp=1
				END
				ELSE
				BEGIN
					SET @MulTaxGrp=0
				END	
				
				IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'TempRtrs')
				AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
				BEGIN
					DROP TABLE TempRtrs
				END
				SELECT R.TaxGroupId,COUNT(R.RtrId) NoOfRtrs
				INTO TempRtrs
				FROM RetailerValueClass RVC,RetailerValueClassMap RVCM,Retailer R
				WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
				AND CtgMainId=@CtgMainId
				GROUP BY R.TaxGroupId					
								
				SELECT @RtrId=RtrId,@TaxGroupId=R.TaxGroupId FROM Retailer R,TempRtrs TR WHERE R.TaxGroupId=TR.TaxGroupId
				AND TR.NoOfRtrs IN (SELECT MAX(NoOfRtrs) FROM TempRtrs)
				SET @DownldSplRate=@SplRate
				IF @SRReCalc=2
				BEGIN
					EXEC Proc_SellingRateReCalculation @RtrId,@PrdBatId,@SplRate,@Pi_SellingRate=@ReCalculatedSR OUTPUT
					IF @ReCalculatedSR<>0
					BEGIN
						SET @SplRate=@ReCalculatedSR						
					END
				END
			
				IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'TempRtrs')
				AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
				BEGIN
					DROP TABLE TempRtrs
				END
			END
			ELSE
			BEGIN
				SET @DownldSplRate=@SplRate
			END	
			SET @RefPriceId=0
			SELECT @RefPriceId=ISNULL(PriceId,0) FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId AND SlNo=1 AND DefaultPrice=1
			
			IF @RefPriceId=0
			BEGIN
				SELECT @RefPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId 
			END
			SET @PriceCode=@PrdBatCode+'-Spl Rate-'+CAST(@SplRate AS NVARCHAR(100))+CAST(GETDATE() AS NVARCHAR(20)) 
			SELECT @PriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',
			CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			IF NOT @PriceId>(SELECT ISNULL(MAX(PriceId),0) AS PriceId FROM ProductBatchDetails(NOLOCK))
			BEGIN			
				CLOSE Cur_Batch
				DEALLOCATE Cur_Batch
				
				CLOSE Cur_SpecialRate
				DEALLOCATE Cur_SpecialRate
				INSERT INTO Errorlog VALUES (1,'Special Rate','System Date',
				'System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(11))+'. Please change the System Date')
				SET @Po_ErrNo=1
				RETURN
			END
			INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
			DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT @PriceId,@PrdBatId,@PriceCode,PBD.BatchSeqId,PBD.SlNo,
			(CASE BC.SelRte WHEN 1 THEN @SplRate ELSE PBD.PrdBatDetailValue END) AS SelRte,
			0,1,1,1,GETDATE(),1,GETDATE()	
			FROM ProductBatchDetails PBD,BatchCreation BC
			WHERE PBD.PrdBatId=@PrdBatId AND PBD.BatchSeqId=BC.BatchSeqId AND PBD.SlNo=BC.SlNo
			AND PriceId=@RefPriceId
			UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
			UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId=@PrdBatId
			
			IF @ContractPriceIds=''
			BEGIN
				SET @ContractPriceIds='-'+CAST(@PriceId AS NVARCHAR(10))+'-'
			END
			ELSE
			BEGIN
				SET @ContractPriceIds=@ContractPriceIds+',-'+CAST(@PriceId AS NVARCHAR(10))+'-'
			END				
			IF @ContractReq=1
			BEGIN						
				SELECT @RefRtrId=ISNULL(RtrId,0) FROM Retailer WHERE CmpRtrCode=@RtrCode
				IF @RtrCode='ALL'
				BEGIN
					SET @RefRtrId=0
				END
				INSERT INTO Cn2Cs_Prk_ContractPricing(CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,
				RtrId,PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount,EffectiveDate,ToDate,CreatedDate,RtrTaxGroupId)
				VALUES(@CmpId,@CtgLevelId,@CtgMainId,0,0,0,@RefRtrId,
				@PrdId,@PrdBatId,@PriceId,0,0,@EffFromDate,@EffToDate,@CreatedDate,CASE @SRReCalc WHEN 2 THEN @TaxGroupId ELSE 0 END)
			END
			IF @SRReCalc=2
			BEGIN
				IF @MulTaxGrp=1 AND @SRReCalc=2
				BEGIN
					DECLARE Cur_MulTaxGroup CURSOR
					FOR SELECT DISTINCT R.TaxGroupId
					FROM Retailer R,RetailerValueClass RVC,RetailerValueClassMap RVCM
					WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
					AND RVC.CtgMainId=@CtgMainId AND R.TaxGroupId<>@TaxGroupId
					OPEN Cur_MulTaxGroup	
					FETCH NEXT FROM Cur_MulTaxGroup INTO @MulTaxGroupId
					WHILE @@FETCH_STATUS=0
					BEGIN						
						SELECT @MulRtrId=MAX(R.RtrId)
						FROM Retailer R,RetailerValueClass RVC,RetailerValueClassMap RVCM
						WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
						AND RVC.CtgMainId=@CtgMainId AND R.TaxGroupId=@MulTaxGroupId
			
						SET @ReCalculatedSR=0
						EXEC Proc_SellingRateReCalculation @MulRtrId,@PrdBatId,@DownldSplRate,@Pi_SellingRate=@ReCalculatedSR OUTPUT
						IF @ReCalculatedSR<>0
						BEGIN
							SET @SplRate=@ReCalculatedSR
						END
		
						SET @RefPriceId=0
						SELECT @RefPriceId=ISNULL(PriceId,0) FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId AND SlNo=1 AND DefaultPrice=1
						
						IF @RefPriceId=0
						BEGIN
							SELECT @RefPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId 
						END
						SET @PriceCode=@PrdBatCode+'-Spl Rate-'+CAST(@SplRate AS NVARCHAR(100))
						+CAST(GETDATE() AS NVARCHAR(20)) 
			
						SELECT @PriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',
						CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
						IF NOT @PriceId>(SELECT ISNULL(MAX(PriceId),0) AS PriceId FROM ProductBatchDetails(NOLOCK))
						BEGIN
							CLOSE Cur_MulTaxGroup
							DEALLOCATE Cur_MulTaxGroup
							CLOSE Cur_Batch
							DEALLOCATE Cur_Batch
							
							CLOSE Cur_SpecialRate
							DEALLOCATE Cur_SpecialRate
							INSERT INTO Errorlog VALUES (1,'Special Rate','System Date',
							'System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(11))+'. Please change the System Date')
							SET @Po_ErrNo=1
							RETURN
						END
						INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
						DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @PriceId,@PrdBatId,@PriceCode,PBD.BatchSeqId,PBD.SlNo,
						(CASE BC.SelRte WHEN 1 THEN @SplRate ELSE PBD.PrdBatDetailValue END) AS SelRte,0,1,1,1,GETDATE(),1,GETDATE()	
						FROM ProductBatchDetails PBD,BatchCreation BC
						WHERE PBD.PrdBatId=@PrdBatId AND PBD.BatchSeqId=BC.BatchSeqId AND PBD.SlNo=BC.SlNo AND PriceId=@RefPriceId
			
						UPDATE Counters SET CurrValue=@PriceId WHERE TabName='ProductBatchDetails' AND FldName='PriceId'			
						UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId=@PrdBatId
						
						IF @ContractPriceIds=''
						BEGIN
							SET @ContractPriceIds='-'+CAST(@PriceId AS NVARCHAR(10))+'-'
						END
						ELSE
						BEGIN
							SET @ContractPriceIds=@ContractPriceIds+',-'+CAST(@PriceId AS NVARCHAR(10))+'-'
						END
	
						IF @ContractReq=1
						BEGIN
							INSERT INTO Cn2Cs_Prk_ContractPricing(CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,
							RtrId,PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount,EffectiveDate,ToDate,CreatedDate,RtrTaxGroupId)
							VALUES(@CmpId,@CtgLevelId,@CtgMainId,0,0,0,0,
							@PrdId,@PrdBatId,@PriceId,0,0,@EffFromDate,@EffToDate,@CreatedDate,@MulTaxGroupId)
						END
						FETCH NEXT FROM Cur_MulTaxGroup INTO @MulTaxGroupId
					END
					CLOSE Cur_MulTaxGroup
					DEALLOCATE Cur_MulTaxGroup
				END
			END		
			
			FETCH NEXT FROM Cur_Batch INTO @PrdBatCode
		END
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_Batch
			DEALLOCATE Cur_Batch
			
			CLOSE Cur_SpecialRate
			DEALLOCATE Cur_SpecialRate
			RETURN
		END		
		
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[BLCmpBatCode]')
			AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
			BEGIN
				IF EXISTS(SELECT CmpBatCode FROM BLCmpBatCode)
				BEGIN	
					CLOSE Cur_Batch
					DEALLOCATE Cur_Batch
				END
			END
		END
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_SpecialRate
			DEALLOCATE Cur_SpecialRate
			RETURN
		END
		IF NOT EXISTS(SELECT * FROM SpecialRateAftDownLoad WHERE RtrCtgCode=@RtrHierLevelCode AND
		RtrCtgValueCode=@RtrHierLevelValueCode AND RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND
		PrdBatCCode=@PrdBatCodeAll AND SplSelRate=@SplRate AND FromDate<=@EffFromDate)
		BEGIN
			SET @ContHistExist=0
		END
		ELSE
		BEGIN	
			SET @ContHistExist=1
		END
		IF @ContHistExist=0	
		BEGIN	
			IF NOT EXISTS(SELECT * FROM SpecialRateAftDownLoad WHERE RtrCtgCode=@RtrHierLevelCode AND
			RtrCtgValueCode=@RtrHierLevelValueCode AND RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND
			PrdBatCCode=@PrdBatCodeAll AND FromDate<=@EffFromDate)
			BEGIN
				INSERT INTO SpecialRateAftDownLoad(RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,
				SplSelRate,FromDate,CreatedDate,DownloadedDate,ContractPriceIds)
				VALUES(@RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
				@PrdCCode,@PrdBatCodeAll,@DownldSplRate,@EffFromDate,@CreatedDate,GETDATE(),@ContractPriceIds)		
			END
			ELSE
			BEGIN
				UPDATE SpecialRateAftDownLoad SET SplSelRate=@DownldSplRate,ContractPriceIds=@ContractPriceIds
				WHERE RtrCtgCode=@RtrHierLevelCode AND RtrCtgValueCode=@RtrHierLevelValueCode AND
				RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND PrdBatCCode=@PrdBatCodeAll
				AND FromDate<=@EffFromDate
			END
		END
		FETCH NEXT FROM Cur_SpecialRate INTO @RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
		@PrdCCode,@PrdBatCodeAll,@SplRate,@EffFromDate,@EffToDate,@CreatedDate,@PrdId,@CtgLevelId,@CtgMainId
	END	
	CLOSE Cur_SpecialRate
	DEALLOCATE Cur_SpecialRate
	IF @ContractReq=1
	BEGIN
		EXEC Proc_Validate_ContractPricing @Po_ErrNo=@ErrStatus
		SET @Po_ErrNo=@ErrStatus
	END	
	IF @Po_ErrNo=0
	BEGIN	
		UPDATE Cn2Cs_Prk_SpecialRate SET DownLoadFlag='Y' 
		WHERE CtgLevelName+'~'+CtgCode+'~'+RtrCode+'~'+PrdCCode+'~'+PrdBatCode
		NOT IN(SELECT RtrHierLevel+'~'+RtrHierValue+'~'+RtrCode+'~'+PrdCCode+'~'+PrdBatCode FROM SplRateToAvoid)
	END
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-080

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ERPPrdCCodeMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ERPPrdCCodeMapping]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_ERPPrdCCodeMapping
EXEC Proc_Cn2Cs_ERPPrdCCodeMapping 0
SELECT * FROM Counters WHERE TabName='ReasonMaster'
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ERPPrdCCodeMapping]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ERPPrdCCodeMapping
* PURPOSE		: To Download the ERP and Console Product Code Mapping to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 20/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)

	DECLARE @PrdCCode			NVARCHAR(100)
	DECLARE @ERPPrdCode			NVARCHAR(100)
	DECLARE @MappedDate			DATETIME

	SET @Po_ErrNo=0

	SET @Tabname = 'Cn2Cs_Prk_ERPPrdCCodeMapping'


	DECLARE Cur_Reason CURSOR	
	FOR SELECT DISTINCT PrdCCode,ERPPrdCode,MappedDate
	FROM Cn2Cs_Prk_ERPPrdCCodeMapping WHERE DownloadFlag='D'
	OPEN Cur_Reason
	FETCH NEXT FROM Cur_Reason INTO @PrdCCode,@ERPPrdCode,@MappedDate
	WHILE @@FETCH_STATUS=0
	BEGIN		

		IF NOT EXISTS(SELECT * FROM ERPPrdCCodeMapping WHERE ERPPrdCode=@ERPPrdCode)
		BEGIN
			INSERT INTO ERPPrdCCodeMapping(PrdCCode,ERPPrdCode,MappedDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@PrdCCode,@ERPPrdCode,@MappedDate,1,1,GETDATE(),1,GETDATE())
		END
		ELSE
		BEGIN			
			UPDATE ERPPrdCCodeMapping SET PrdCCode=@PrdCCode WHERE ERPPrdCode=@ERPPrdCode
		END		

		FETCH NEXT FROM Cur_Reason INTO @PrdCCode,@ERPPrdCode,@MappedDate
	END
    CLOSE Cur_Reason
	DEALLOCATE Cur_Reason

	UPDATE Cn2Cs_Prk_ERPPrdCCodeMapping SET DownloadFlag='Y' WHERE DownloadFlag='D'

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-081

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_QPSSchemeCrediteNoteConversion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_QPSSchemeCrediteNoteConversion]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM SalesInvoiceQPSRedeemed
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BilledPrdHdForQPSScheme
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2010-10-20',0
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd WHERE TransId = 2 And UsrId = 1
--SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM SalesInvoiceQPSCumulative
--SELECT * FROM SchemeMaster
SELECT * FROM CreditNoteRetailer
--SELECT * FROM SalesInvoiceQPSRedeemed WHERE LastModDate>'2010-04-06' 
--SELECT * FROM SalesInvoiceQPSSchemeAdj 
ROLLBACK TRANSACTION
*/
CREATE        PROCEDURE [dbo].[Proc_QPSSchemeCrediteNoteConversion]
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
	
	DECLARE @SchCoaId			AS INT
	DECLARE	@CrNoteNo			AS NVARCHAR(200)
	DECLARE @ErrStatus			AS INT
	DECLARE @VocDate			AS DATETIME
	DECLARE @MinPrdId			AS INT
	DECLARE @MinPrdBatId		AS INT
	DECLARE @MinRtrId			AS INT	
	SELECT @SchCoaId=CoaId FROM COAMaster WHERE Accode='4220001'	
	SET @LcnId=0
	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1
	IF @LcnId=0
	BEGIN
		SELECT @LcnId=LcnId FROM Location WHERE LcnId IN (SELECT MIN(LcnId) FROM Location)
	END	
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
		DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId	
		DECLARE @SchemeAvailable TABLE
		(
			SchId			INT,
			SchCode			NVARCHAR(200),
			CmpSchCode		NVARCHAR(200),
			CombiSch		INT,
			QPS				INT		
		)
		--->To insert dummy invoice and details for applying QPS scheme
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
		DECLARE Cur_Retailer CURSOR	
		FOR SELECT RtrId,RtrCode,CmpRtrCode,RtrName FROM Retailer WHERE RtrId
		IN (SELECT DISTINCT RtrId FROM SalesInvoiceQPSCumulative)
		OPEN Cur_Retailer
		FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		WHILE @@FETCH_STATUS=0
		BEGIN	
			DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId --AND RtrId=@RtrId       
			DELETE FROM @SchemeAvailable

			INSERT INTO BilledPrdHdForScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice)
			VALUES(2,@RtrId,1,1,10.00,100,1000.00,12.00,2,@UsrId,7.50)

			--->Modified By Nanda on 20/10/2010
--			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
--			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
--			FROM BilledPrdHdForScheme A
--			INNER JOIN Fn_ReturnApplicableProductDtQPS() B ON A.PrdId = B.PrdId AND A.UsrId = @UsrId   AND A.TransId =  2
--			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
--			C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1

			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
			FROM Fn_ReturnApplicableProductDtQPS() B 
			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
			C.SchValidTill <= @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1
			--->Till Here

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
			
			DELETE FROM BillAppliedSchemeHd --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM ApportionSchemeDetails --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM BilledPrdRedeemedForQPS --WHERE Userid = @UsrId And TransId = 2
			DELETE FROM BilledPrdHdForQPSScheme

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

			--->Get the scheme details
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
				SchType			INT
			)
			INSERT INTO #AppliedSchemeDetails
			SELECT DISTINCT A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, SUM(A.SchemeAmount) AS SchemeAmount,
			CASE A.SchType WHEN 0 THEN A.SchemeDiscount WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,
			A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, SUM(A.FreeToBeGiven) AS FreeToBeGiven,
			B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,
			A.SchType
			FROM BillAppliedSchemeHd A
			INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE Usrid=@UsrId AND TransId = 2 AND B.QPS=1 AND B.ApyQpsSch = 1
			GROUP BY A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,
			A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId,
			A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,PrdId,PrdBatId
			ORDER BY A.SchId ASC,A.SlabId ASC

			--->Convert the scheme amount as credit note and corresponding postings
			IF EXISTS(SELECT * FROM #AppliedSchemeDetails)
			BEGIN
				DECLARE Cur_SchFree CURSOR	
				FOR SELECT SchId,SchCode,CmpSchCode,SchemeAmount,SchemeDiscount FROM #AppliedSchemeDetails		
				OPEN Cur_SchFree
				FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc
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
						'From QPS Scheme:'+@CmpSchCode+'(Auto Conversion)')
						UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CreditNoteRetailer' AND FldName='CrNoteNumber'
						SET @VocDate=GETDATE()
						EXEC Proc_VoucherPosting 18,1,@CrNoteNo,3,6,@UsrId,@VocDate,@Po_ErrNo=@ErrStatus OUTPUT
						IF @ErrStatus<0
						BEGIN
							SET @Po_ErrNo=1
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
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc
				END
				CLOSE Cur_SchFree
				DEALLOCATE Cur_SchFree
			END
			DROP TABLE #AppliedSchemeDetails
			FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		END
		CLOSE Cur_Retailer
		DEALLOCATE Cur_Retailer
		DELETE FROM BilledPrdHdForScheme WHERE UsrId=@UsrId
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-165-082

UPDATE MenuDef SET ParentId='mStk' WHERE MenuName='mnuClusterAssign'


if not exists (select * from hotfixlog where fixid = 345)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(345,'D','2010-10-23',getdate(),1,'Core Stocky Service Pack 345')