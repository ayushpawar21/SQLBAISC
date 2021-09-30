--[Stocky HotFix Version]=436
DELETE FROM Versioncontrol WHERE Hotfixid='436'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('436','3.1.0.13','D','2018-08-01','2018-08-01','2018-08-01',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product GST Issue Fix')
GO
DELETE FROM Configuration WHERE ModuleId='RET32' and ModuleName='Retailer'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'RET32','Retailer','Allow Billing for unapproved retailers up to Number of bills',1,0,1.00,32
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='RetailerApprovalStatus' AND xtype='U')
BEGIN
CREATE TABLE RetailerApprovalStatus(
	[RtrId] [numeric](18, 0) NULL,
	[RtrCtgId] [bigint] NULL,
	[RtrClassId] [bigint] NULL,
	[RtrStatus] [tinyint] NULL,
	[Rtrname] [nvarchar](50) NULL,
	[Geoid] [int] NULL,
	[Upload] [tinyint] NULL,
	[Mode] [tinyint] NULL,
	[ModDate] [datetime] NULL
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='FN_RETURNRTRCHANGEDETAILS' AND xtype IN ('TF','FN'))
DROP FUNCTION FN_RETURNRTRCHANGEDETAILS
GO
CREATE FUNCTION [dbo].[FN_RETURNRTRCHANGEDETAILS](
			@PI_RTRID BIGINT,
			@PI_MODE INT,
			@PI_RTRNAME VARCHAR(500),
			@PI_RTRCLASSID BIGINT,
			@PI_GEOID BIGINT,
			@PI_RTRSTATUS INT
			)
RETURNS TINYINT
AS
/************************************************
* FUNCTION  : FN_RETURNRTRCHANGEDETAILS
* PURPOSE    : TO RETURN CHANGE MADE IN RETAILER
* CREATED BY : PRAVEENRAJ B
* CREATED ON : 12/03/2014
* MODIFICATION 
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  10/05/2018   S.Moorthi    CR         CRCRSTPAR0001   Retailer Approval process - Manual
*************************************************/    
BEGIN
		DECLARE @RTRDETAILS TABLE
		(
			RTRID BIGINT,
			RTRNAME VARCHAR(500),
			RTRCLASSID BIGINT,
			CTGMAINID BIGINT,
			GEOID BIGINT,
			RTRSTATUS INT
		)
		
		INSERT INTO @RTRDETAILS(RTRID,RTRNAME,RTRCLASSID,CTGMAINID,GEOID,RTRSTATUS)
		SELECT DISTINCT R.RtrId,R.RtrName,C.RtrClassId,RC.CtgMainId,R.GeoMainId,R.RtrStatus 
		FROM RETAILER R (NOLOCK)
		INNER JOIN RetailerValueClassMap M (NOLOCK) ON M.RtrId=R.RtrId
		INNER JOIN RetailerValueClass C (NOLOCK) ON C.RtrClassId=M.RtrValueClassId
		INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=C.CtgMainId
		
		DECLARE @CHNAGEMADE	TINYINT
		SET @CHNAGEMADE=0
		IF ISNULL(@PI_MODE,0)=2
		BEGIN
		
			IF NOT EXISTS (SELECT * FROM @RTRDETAILS WHERE UPPER(LTRIM(RTRIM(RTRNAME)))=UPPER(LTRIM(RTRIM(@PI_RTRNAME))) AND RTRID=@PI_RTRID)
			BEGIN
				SET @CHNAGEMADE=1
			END
			ELSE IF NOT EXISTS (SELECT * FROM @RTRDETAILS WHERE RTRID=@PI_RTRID AND RTRCLASSID=@PI_RTRCLASSID)
			BEGIN
				SET @CHNAGEMADE=1
			END
			
			ELSE IF NOT EXISTS (SELECT * FROM @RTRDETAILS WHERE RTRID=@PI_RTRID AND GEOID=@PI_GEOID)
			BEGIN
				SET @CHNAGEMADE=1
			END
			
			ELSE IF NOT EXISTS (SELECT * FROM @RTRDETAILS WHERE RTRID=@PI_RTRID AND RTRSTATUS=@PI_RTRSTATUS)
			BEGIN
				SET @CHNAGEMADE=1
			END
			
		END
RETURN(@CHNAGEMADE)
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='RetailerFlagChange' AND xtype='U')
BEGIN
CREATE TABLE RetailerFlagChange(
	[RtrId] [numeric](18, 0) NULL,	
	[RtrCatChange] [tinyint] NULL,
	[RtrClassChange] [tinyint] NULL,
	[RtrGeoChange] [tinyint] NULL,
	[RtrStatusChange] [tinyint] NULL,
	[Upload] [tinyint] NULL
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RetailerFlagChange' AND xtype='P')
DROP PROCEDURE Proc_RetailerFlagChange
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_RetailerFlagChange 6,2,'A  k dairy',182,1534,39,1,'9818804156','2343242423'
  SELECT * FROM RetailerFlagChange (NOLOCK) where RtrId =6
  select * from RetailerApprovalStatus (NOLOCK) where RtrId =6
  ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_RetailerFlagChange
(
	@PI_RtrId		NUMERIC(18,0),
	@PI_MODE		INT,			
	@PI_RTRCATGID	NUMERIC(18,0),
	@PI_RTRCLASSID	NUMERIC(18,0),  		
	@PI_RtrStatus	INT,
	@PI_RtrName		NVARCHAR(200),
	@PI_GeoMainId	INT
)
AS
/*************************************************************
* PROCEDURE	: Proc_RetailerFlagChange
* PURPOSE	: Retailer Upload Flag Change to Get the Reason
* CREATED	: Sathishkumar Veeramani
* CREATED DATE	: 26/05/2014
* MODIFIED
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  10/05/2018   S.Moorthi    CR         CRCRSTPAR0001   Retailer Approval process - Manual
***************************************************************/
BEGIN


		DECLARE @RTRDETAILS TABLE
		(
			RtrId		BIGINT,
			RtrName	NVARCHAR(100),
			RtrClassId BIGINT,
			CtgMainId INT,			
			RtrStatus INT,
			GeoId	INT,
			[APPROVED]	[int]
		)
		
		INSERT INTO @RTRDETAILS(RtrId,RtrName,RtrClassId,CtgMainId,RtrStatus,GeoId,[APPROVED])
		SELECT DISTINCT R.RtrId,R.RtrName,C.RtrClassId,RC.CtgMainId,R.RtrStatus,GeoMainId,Approved 
		FROM RETAILER R (NOLOCK) 
		INNER JOIN RetailerValueClassMap M (NOLOCK) ON M.RtrId=R.RtrId
		INNER JOIN RetailerValueClass C (NOLOCK) ON C.RtrClassId=M.RtrValueClassId
		INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=C.CtgMainId
		WHERE R.RtrId=@PI_RtrId
		
		
		IF ISNULL(@PI_MODE,0)=3
		BEGIN
			IF EXISTS (SELECT DISTINCT RtrId FROM @RTRDETAILS WHERE APPROVED <> 0 AND RtrId = @PI_RtrId)
			BEGIN
				IF NOT EXISTS (SELECT DISTINCT RtrId FROM RetailerApprovalStatus WHERE RtrId = @PI_RtrId)
				BEGIN
					INSERT INTO RetailerApprovalStatus(RtrId,RtrCtgId,RtrClassId,
					RtrStatus,Rtrname,Geoid,Upload,Mode,ModDate)
					SELECT @PI_RtrId,@PI_RTRCATGID,@PI_RtrClassId,2,'',0,0,@PI_MODE,GETDATE()
				END
				ELSE
				BEGIN
					UPDATE RetailerApprovalStatus SET RtrCtgId = @PI_RTRCATGID,RtrClassId = @PI_RtrClassId,Mode = @PI_MODE
					WHERE RtrId = @PI_RtrId 
				END
			END
			
			RETURN
		END
		
		IF EXISTS (SELECT DISTINCT RtrId FROM @RTRDETAILS WHERE APPROVED <> 0 AND RtrId = @PI_RtrId)
		BEGIN
			IF ISNULL(@PI_MODE,0)>=2
			BEGIN
										
				--Retailer Category Change
				IF EXISTS (SELECT * FROM @RTRDETAILS WHERE RtrClassId <> @PI_RtrClassId AND RtrId = @PI_RtrId)
				BEGIN
					IF NOT EXISTS (SELECT DISTINCT RtrId FROM RetailerApprovalStatus WHERE RtrId = @PI_RtrId)
					BEGIN
						INSERT INTO RetailerApprovalStatus(RtrId,RtrCtgId,RtrClassId,
						RtrStatus,Rtrname,Geoid,Upload,Mode,ModDate)
						SELECT @PI_RtrId,@PI_RTRCATGID,@PI_RtrClassId,2,'',0,0,@PI_MODE,GETDATE()
					END
					ELSE
					BEGIN
						UPDATE RetailerApprovalStatus SET RtrCtgId = @PI_RTRCATGID,RtrClassId = @PI_RtrClassId,Mode = @PI_MODE
						WHERE RtrId = @PI_RtrId 
					END
				END
				
				
				--RtrName
				IF EXISTS (SELECT * FROM @RTRDETAILS WHERE RtrName <> @PI_RtrName AND RtrId = @PI_RtrId)
				BEGIN
					IF NOT EXISTS (SELECT DISTINCT RtrId FROM RetailerApprovalStatus WHERE RtrId = @PI_RtrId)
					BEGIN
						INSERT INTO RetailerApprovalStatus(RtrId,RtrCtgId,RtrClassId,
						RtrStatus,Rtrname,Geoid,Upload,Mode,ModDate)
						SELECT @PI_RtrId,0,0,2,@PI_RtrName,0,0,@PI_MODE,GETDATE()
					END
					ELSE
					BEGIN
						UPDATE RetailerApprovalStatus SET Rtrname=@PI_RtrName,Mode = @PI_MODE WHERE RtrId = @PI_RtrId
					END
				END
				
				--Rtr Geography
				IF EXISTS (SELECT * FROM @RTRDETAILS WHERE GeoId <> @PI_GeoMainId AND RtrId = @PI_RtrId)
				BEGIN
					IF NOT EXISTS (SELECT DISTINCT RtrId FROM RetailerApprovalStatus WHERE RtrId = @PI_RtrId)
					BEGIN
						INSERT INTO RetailerApprovalStatus(RtrId,RtrCtgId,RtrClassId,
						RtrStatus,Rtrname,Geoid,Upload,Mode,ModDate)
						SELECT @PI_RtrId,0,0,2,'',@PI_GeoMainId,0,@PI_MODE,GETDATE()
					END
					ELSE
					BEGIN
						UPDATE RetailerApprovalStatus SET Geoid=@PI_GeoMainId,Mode = @PI_MODE WHERE RtrId = @PI_RtrId
					END
				END	
				
				--Retailer Status
				IF EXISTS (SELECT * FROM @RTRDETAILS WHERE RtrStatus <> @PI_RtrStatus AND RtrId = @PI_RtrId)
				BEGIN
					IF NOT EXISTS (SELECT DISTINCT RtrId FROM RetailerApprovalStatus WHERE RtrId = @PI_RtrId)
					BEGIN
						INSERT INTO RetailerApprovalStatus(RtrId,RtrCtgId,RtrClassId,
						RtrStatus,Rtrname,Geoid,Upload,Mode,ModDate)
						SELECT @PI_RtrId,0,0,@PI_RtrStatus,'',0,0,@PI_MODE,GETDATE()
					END
					ELSE
					BEGIN
						UPDATE RetailerApprovalStatus SET RtrStatus = @PI_RtrStatus,Mode = @PI_MODE
						WHERE RtrId = @PI_RtrId 
					END
				END
				
			END
		END
RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_Cs2Cn_Retailer' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Retailer
GO
/*
BEGIN TRAN
SELECT 'Approval Track Before upload',* from RetailerApprovalStatus
DELETE FROM CS2CN_PRK_RETAILER
EXEC Proc_Cs2Cn_Retailer 0,'2018-05-14'
SELECT Mode,Approved,* FROM CS2CN_PRK_RETAILER
SELECT 'Approval Track After upload',* FROM RetailerApprovalStatus
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Cs2Cn_Retailer
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_Cs2Cn_Retailer 0,'2016-11-11'
* PURPOSE	: Extract Retailer Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 09-01-2009
* MODIFIED	:
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  10/05/2018   S.Moorthi     CR        CRCRSTPAR0001   Retailer Approval process - Manual
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	
	----Commented by Moorthi CRCRSTPAR0001 --CHANGED BY MAHESH FOR ICRSTPAR1505
	--IF EXISTS (SELECT * FROM RETAILER WHERE APPROVED=0)
	--BEGIN
	--	UPDATE RETAILER SET Approved=1 WHERE Approved=0
	--END
	----Till Here
	DELETE FROM Cs2Cn_Prk_Retailer WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Retailer
	(
		DistCode ,
		RtrId ,
		RtrCode ,
		CmpRtrCode,
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
        DrugLNo,
        RtrFrequency,
        RtrPhoneNo,
        RtrTINNumber,
        RtrTaxGroupCode,
        RtrCrLimit,
        RtrCrDays,
        Approved,
        RtrType,
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
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New',R.RtrDrugLicNo,
		CASE RtrFrequency WHEN 0 THEN 'WEEKLY' WHEN 1 THEN 'BI-WEEKLY' WHEN 2 THEN 'FORT NIGHTLY' when 3 then 'MONTHLY' when 4 then 'DAILY' END AS RtrFrequency,
		ISNULL(RtrPhoneNo,''),ISNULL(RtrTINNo,''),ISNULL(TGS.RtrGroup,''),R.RtrCrLimit,
        R.RtrCrDays,(CASE ISNULL(R.Approved,0) WHEN 0 THEN 'PENDING' WHEN 1 THEN 'APPROVED' ELSE 'REJECTED' END) AS Approved,
        (CASE R.RtrType WHEN 1 THEN 'Retailer' WHEN 2 THEN 'Sub Stockist' WHEN 3 THEN 'Hub' WHEN 4 THEN 'Spoke' ELSE 'Distributor' END) AS RtrType,
        'N'					
	FROM		
		Retailer R
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
	WHERE			
		R.Upload = 'N'
		AND  NOT EXISTS (SELECT DISTINCT RAS.RtrId FROM RetailerApprovalStatus RAS (NOLOCK) WHERE R.RtrId = RAS.RtrId)		
	UNION
	SELECT
		@DistCode ,
		RCC.RtrId,
		R.RtrCode,
		R.CmpRtrCode,
		(CASE ISNULL(RCC.RtrName,'') WHEN '' THEN R.RtrName ELSE RCC.RtrName END) AS RtrName,
		--RCC.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode,
		'' CtgCode,
		'' ValueClassCode,
		--RtrStatus,
		(CASE ISNULL(RCC.RtrStatus,2) WHEN 2 THEN R.RtrStatus ELSE RCC.RtrStatus END) AS RtrStatus,
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','AP',R.RtrDrugLicNo,
		CASE RtrFrequency WHEN 0 THEN 'WEEKLY' WHEN 1 THEN 'BI-WEEKLY' WHEN 2 THEN 'FORT NIGHTLY' when 3 then 'MONTHLY' when 4 then 'DAILY' END AS RtrFrequency,
		ISNULL(RtrPhoneNo,''),ISNULL(RtrTINNo,''),ISNULL(TGS.RtrGroup,''),R.RtrCrLimit,
        R.RtrCrDays,(CASE ISNULL(R.Approved,0) WHEN 0 THEN 'PENDING' WHEN 1 THEN 'APPROVED' ELSE 'REJECTED' END) AS Approved,
        (CASE R.RtrType WHEN 1 THEN 'Retailer' WHEN 2 THEN 'Sub Stockist' WHEN 3 THEN 'Hub' WHEN 4 THEN 'Spoke' ELSE 'Distributor' END) AS RtrType,
        'N'							
	FROM
	RetailerApprovalStatus RCC	--CRCRSTPAR0001		
		INNER JOIN Retailer R ON R.RtrId=RCC.RtrId
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
	WHERE 	
		RCC.Upload=0 
		
	--	RetailerClassficationChange RCC			
	--	INNER JOIN Retailer R ON R.RtrId=RCC.RtrId
	--	LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
	--	INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
	--	LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
	--WHERE 	
	--	UpLoadFlag=0
		
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
	
	--Added By MohanaKrishna A.B For GST
	Update Cs2Cn_Prk_Retailer SET StateName='' where StateName is Null
	Update Cs2Cn_Prk_Retailer SET GSTTIN ='' where GSTTIN is Null
	Update Cs2Cn_Prk_Retailer SET PanNumber ='' where PanNumber is Null
	Update Cs2Cn_Prk_Retailer SET RetailerType ='' where RetailerType is Null
	Update Cs2Cn_Prk_Retailer SET Composite ='' where Composite is Null
	Update Cs2Cn_Prk_Retailer SET RelatedParty ='' where RelatedParty is Null
	----
	
	--Added By Mohana For GST
	SELECT C.MasterRecordId,B.ColumnName,ISNULL(C.ColumnValue,'') ColumnValue INTO #RtrUDC FROM UdcHD A INNER JOIN UdcMaster B ON A.MasterId=B.MasterId AND A.MasterName='Retailer Master'
	INNER JOIN UdcDetails C ON A.MasterId= C.MasterId AND B.UdcMasterId=C.UdcMasterId --AND masterrecordid =445
	INNER JOIN Retailer R ON R.RtrId =C.MasterRecordId AND B.ColumnName IN ('State name','GSTIN','PAN Number','Retailer Type','Related Party','Composition')
	UPDATE A SET StateName =ISNULL(C.ColumnValue,'') FROM Cs2Cn_Prk_Retailer A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='State Name'
	UPDATE A SET GSTTIN = ISNULL(C.ColumnValue,'')  FROM Cs2Cn_Prk_Retailer A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='GSTIN'
	UPDATE A SET PanNumber = ISNULL(C.ColumnValue,'')  FROM Cs2Cn_Prk_Retailer A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='PAN Number'
	UPDATE A SET RetailerType = ISNULL(C.ColumnValue,'') FROM Cs2Cn_Prk_Retailer A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='Retailer Type'
	UPDATE A SET RelatedParty = ISNULL(C.ColumnValue,'')  FROM Cs2Cn_Prk_Retailer A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='Related Party'
	UPDATE A SET Composite = ISNULL(C.ColumnValue,'')  FROM Cs2Cn_Prk_Retailer A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='Composition'
	--Till Here
	
	--Added By S.Moorthi	
	SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode,RVC.ValueClassCode 
	INTO #TempCategory	
			FROM
			RetailerValueClass RVC	,
			RetailerCategory RC ,
			RetailerCategoryLevel RCL,
			RetailerCategory RC1,		
			RetailerApprovalStatus R
		WHERE			
			R.RtrClassId = RVC.RtrClassId
			AND	RVC.CtgMainId=RC.CtgMainId
			AND	RCL.CtgLevelId=RC.CtgLevelId
			AND	RC.CtgLinkId = RC1.CtgMainId
			AND ISNULL(R.RtrClassId,0)<>0
			AND R.Upload=0
			
	UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,
	ETL.RtrClassCode=RVC.ValueClassCode
	FROM Cs2Cn_Prk_Retailer ETL (NOLOCK) 
	INNER JOIN RetailerApprovalStatus RAS (NOLOCK) ON ETL.RtrId=RAS.RtrId 
	INNER JOIN #TempCategory RVC ON RVC.RtrId=ETL.RtrId and RVC.RtrId=RAS.RtrId
	WHERE ETL.UploadFlag='N' AND RAS.Upload=0
	
	UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoLevelValue=Geo.GeoName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
		ISNULL(G.GeoName,'') AS GeoName
		FROM			
		Retailer R  	
		INNER JOIN RetailerApprovalStatus RAS (NOLOCK) ON R.RtrId=RAS.RtrId 	
		LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
		LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId
		WHERE ISNULL(RAS.Geoid,0)<>0  AND RAS.Upload=0
	) AS Geo
	WHERE ETL.RtrId=Geo.RtrId

	--UPDATE Cs2Cn_Prk_Retailer SET Mode = 'CR' WHERE ISNULL(Approved,'PENDING') IN ('APPROVED','REJECTED') AND Mode = 'New' AND UploadFlag='N'
	--UPDATE Cs2Cn_Prk_Retailer SET Mode = 'New' WHERE ISNULL(Approved,'PENDING') NOT IN ('APPROVED','REJECTED') AND UploadFlag='N'
	UPDATE Cs2Cn_Prk_Retailer SET Mode = 'CR' WHERE ISNULL(Approved,'PENDING') IN ('APPROVED') AND Mode = 'New' AND UploadFlag='N'
	UPDATE Cs2Cn_Prk_Retailer SET Mode = 'New' WHERE ISNULL(Approved,'PENDING') IN ('PENDING','REJECTED') AND UploadFlag='N'
	--Till Here
	
	UPDATE Retailer SET Upload='Y' WHERE Upload='N'
	AND CmpRtrCode IN(SELECT CmpRtrCode FROM Cs2Cn_Prk_Retailer WHERE UploadFlag='N') --WHERE Mode='New')
	
	UPDATE RetailerClassficationChange SET UpLoadFlag=1 WHERE UpLoadFlag=0
	AND RtrCode IN(SELECT RtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='AP' AND UploadFlag='N')
	
	UPDATE RetailerApprovalStatus SET Upload=1 WHERE Upload=0
	AND RtrId IN(SELECT RtrId FROM Cs2Cn_Prk_Retailer WHERE Mode='AP' AND UploadFlag='N')
	
	
	UPDATE Cs2Cn_Prk_Retailer SET ServerDate=@ServerDate
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_RetailerApprovalStatus' AND xtype IN ('TF','FN'))
DROP FUNCTION Fn_RetailerApprovalStatus
GO
--SELECT Dbo.Fn_RetailerApprovalStatus(3)
CREATE FUNCTION Fn_RetailerApprovalStatus(@Pi_RtrId AS BIGINT)
RETURNS VARCHAR(500)
AS
BEGIN
/**********************************************************
* FUNCTION: Fn_RetailerApprovalStatus
* PURPOSE:  Return Approval Status for Retailer 
* NOTES: 
* CREATED: S.MOORTHI
* MODIFIED 
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  10/05/2018   S.Moorthi     CR        CRCRSTPAR0001   Retailer Approval process - Manual
************************************************************/
DECLARE @Approval AS VARCHAR(500)
SET @Approval = ''

 IF EXISTS (SELECT DISTINCT RtrId FROM Retailer (NOLOCK) WHERE Approved = 0 AND Upload = 'Y' AND RtrId = @Pi_RtrId)
 BEGIN
	 SET @Approval = 'Retailer Approval is Pending,Cannot Edit this Retailer'
 END
 
 IF EXISTS (SELECT DISTINCT A.RtrId FROM RetailerApprovalStatus A (NOLOCK) INNER JOIN Retailer B (NOLOCK) ON A.RtrId = B.RtrId
 WHERE B.Approved = 1 AND B.Upload = 'Y' AND A.RtrId = @Pi_RtrId)
 BEGIN
	 SET @Approval = 'Retailer Approval is Pending,Cannot Edit this Retailer'
 END

RETURN(@Approval)
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_Cn2Cs_RetailerApproval' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_RetailerApproval
GO
/*
BEGIN TRANSACTION
insert into Cn2Cs_Prk_RetailerApproval
SELECT DistCode,RtrCode,CmpRtrCode,RtrChannelCode,RtrGroupCode,RtrClassCode,case when Status=0 then 'InActive' else 'Active' end,KeyAccount,'Approved' Approved,Mode,'UN'+CmpRtrCode RtrUniqueCode,'D' DownLoadFlag,GETDATE() CreatedDate FROM CS2CN_PRK_RETAILER WHERE RtrCode='RET1001' UNION
SELECT DistCode,RtrCode,CmpRtrCode,RtrChannelCode,RtrGroupCode,RtrClassCode,case when Status=0 then 'InActive' else 'Active' end,KeyAccount,'Rejected' Approved,Mode,'UN'+CmpRtrCode RtrUniqueCode,'D' DownLoadFlag,GETDATE() CreatedDate FROM CS2CN_PRK_RETAILER WHERE RtrCode='RET1002' UNION
SELECT DistCode,RtrCode,CmpRtrCode,RtrChannelCode,RtrGroupCode,RtrClassCode,case when Status=0 then 'InActive' else 'Active' end,KeyAccount,'Approved' Approved,Mode,'UN'+CmpRtrCode RtrUniqueCode,'D' DownLoadFlag,GETDATE() CreatedDate FROM CS2CN_PRK_RETAILER WHERE RtrCode IN ('01','RET003','RET005','RET008') UNION
SELECT DistCode,RtrCode,CmpRtrCode,RtrChannelCode,RtrGroupCode,RtrClassCode,case when Status=0 then 'InActive' else 'Active' end,KeyAccount,'Rejected' Approved,Mode,'UN'+CmpRtrCode RtrUniqueCode,'D' DownLoadFlag,GETDATE() CreatedDate FROM CS2CN_PRK_RETAILER WHERE RtrCode IN ('RET064','RET102') 
SELECT 'Approval Track Before Download',* from RetailerApprovalStatus
EXEC Proc_Cn2Cs_RetailerApproval 0
SELECT 'Approval Track After Download',* from RetailerApprovalStatus
SELECT * FROM Cn2Cs_Prk_RetailerApproval
--SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_RetailerApproval
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_RetailerApproval
* PURPOSE		: To Change the Retailer Status,Classification
* CREATED		: Nandakumar R.G
* CREATED DATE	: 05/03/2010
* MODIFIED
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  10/05/2018   S.Moorthi     CR        CRCRSTPAR0001   Retailer Approval process - Manual
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @sSql			NVARCHAR(2000)
	DECLARE @Taction  		INT
	DECLARE @ErrDesc  		NVARCHAR(1000)
	DECLARE @Tabname  		NVARCHAR(50)
	DECLARE @RtrCode  		NVARCHAR(200)
	DECLARE @CmpRtrCode  	NVARCHAR(200)
	DECLARE @RtrClassCode  	NVARCHAR(200)
	DECLARE @RtrChannelCode	NVARCHAR(200)
	DECLARE @RtrGroupCode	NVARCHAR(200)
	DECLARE @Status  		NVARCHAR(200)
	DECLARE @KeyAcc  		NVARCHAR(200)
	DECLARE @Approved       NVARCHAR(200)
	DECLARE @StatusId  		INT
	DECLARE @RtrId  		INT
	DECLARE @RtrClassId  	INT
	DECLARE @CtgLevelId  	INT
	DECLARE @CtgMainId  	INT	
	DECLARE @KeyAccId		INT
	DECLARE @ApprovedId		INT
	DECLARE @Pi_UserId  	INT	
	DECLARE @CtgClassMainId INT
	DECLARE @RtrUniqueCode NVARCHAR(200)
	DECLARE @Mode NVARCHAR(200)
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_RetailerApproval'
	SET @Pi_UserId=1
	
	
	DECLARE Cur_RetailerApproval CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([RtrCode])),''),ISNULL(LTRIM(RTRIM([CmpRtrCode])),''),ISNULL(LTRIM(RTRIM([RtrChannelCode])),''),ISNULL(LTRIM(RTRIM([RtrGroupCode])),''),
	ISNULL(LTRIM(RTRIM([RtrClassCode])),''),ISNULL(LTRIM(RTRIM([Status])),'Active'),ISNULL(LTRIM(RTRIM([KeyAccount])),'Yes'),
	(CASE WHEN LEN(ISNULL(LTRIM(RTRIM(UPPER(Approved))),''))=0 THEN 'PENDING' ELSE UPPER(Approved) END) AS Approved,
	ISNULL(RtrUniqueCode,'') AS RtrUniqueCode,Mode
	FROM Cn2Cs_Prk_RetailerApproval WHERE [DownLoadFlag] ='D'
	OPEN Cur_RetailerApproval
	FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,
	@Status,@KeyAcc,@Approved,@RtrUniqueCode,@Mode
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Po_ErrNo=0
		IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrCode=@RtrCode)
		BEGIN
			SET @ErrDesc = 'Retailer Code:'+@RtrCode+'does not exists'
			INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
			SET @Po_ErrNo=1
			SET @RtrId=0
		END
		ELSE
		BEGIN
			SELECT @RtrId=RtrId FROM Retailer WHERE RtrCode=@RtrCode			
		END
		
		IF NOT EXISTS (SELECT CtgMainId FROM RetailerCateGOry WHERE CtgCode=@RtrGroupCode)
		BEGIN
			SET @ErrDesc = 'Retailer CateGOry Level Value:'+@RtrGroupCode+' does not exists'
			INSERT INTO Errorlog VALUES (3,@TabName,'Retailer CateGOry Level Value',@ErrDesc)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CtgClassMainId=CtgMainId FROM RetailerCateGOry
			WHERE CtgCode=@RtrGroupCode
		END
		
		IF NOT EXISTS (SELECT RtrClassId FROM RetailerValueClass WHERE ValueClassCode=@RtrClassCode
		AND CtgMainId=@CtgClassMainId)
		BEGIN
			SET @ErrDesc = 'Retailer Value Class:'+@RtrClassCode+' does not exists'
			INSERT INTO Errorlog VALUES (4,@TabName,'Retailer Value Class',@ErrDesc)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @RtrClassId=RtrClassId FROM RetailerValueClass
			WHERE ValueClassCode=@RtrClassCode AND CtgMainId=@CtgClassMainId
		END
			
		IF UPPER(LTRIM(RTRIM(@Status)))=UPPER('ACTIVE')
		BEGIN
			SET @StatusId=1	
		END
		ELSE
		BEGIN
			SET @StatusId=0
		END
		IF UPPER(LTRIM(RTRIM(@KeyAcc)))=UPPER('YES')
		BEGIN
			SET @KeyAccId=1	
		END
		ELSE
		BEGIN
			SET @KeyAccId=0
		END
		
		IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('PENDING')
		BEGIN
			SET @ApprovedId=0	
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('APPROVED')
		BEGIN
			SET @ApprovedId=1
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('REJECTED')
		BEGIN
		    SET @ApprovedId=2
		END
			
		IF @Po_ErrNo=0
		BEGIN
		    IF @ApprovedId = 2
		    BEGIN
		    
				IF EXISTS(SELECT * FROM RetailerApprovalStatus(NOLOCK) WHERE RtrId=@RtrId and Upload=1)
				BEGIN
					DELETE A FROM RetailerApprovalStatus A (NOLOCK) WHERE RtrId = @RtrId and Upload=1
				END
				ELSE
				BEGIN
					UPDATE Retailer SET RtrStatus=0,RtrUniqueCode = @RtrUniqueCode,Approved=@ApprovedId WHERE RtrId=@RtrId 
				END
				
		        --IF @Mode = 'NEW'
		        --BEGIN
		        --   UPDATE Retailer SET RtrStatus = 0,Approved=@ApprovedId WHERE RtrId=@RtrId
		        --END
		        --UPDATE Retailer SET RtrUniqueCode = @RtrUniqueCode WHERE RtrId = @RtrId
	
		    END
		    ELSE IF @ApprovedId=1
			BEGIN
			
				IF EXISTS(SELECT * FROM RetailerApprovalStatus(NOLOCK) WHERE RtrId=@RtrId and Upload=1)
				BEGIN		
									
					UPDATE A SET 
					A.RtrName=CASE WHEN ISNULL(B.Rtrname,'')='' THEN A.Rtrname ELSE B.Rtrname END,
					A.GeoMainId=CASE WHEN ISNULL(B.Geoid,0)=0 THEN A.GeoMainId ELSE B.Geoid END,
					RtrKeyAcc=@KeyAccId,RtrStatus=@StatusId,Approved=@ApprovedId,
					RtrUniqueCode = @RtrUniqueCode FROM Retailer A(NOLOCK) 
					INNER JOIN RetailerApprovalStatus B (NOLOCK) ON A.RtrId=B.RtrId 	
					WHERE A.RtrId=@RtrId
			
					DELETE A FROM RetailerApprovalStatus A (NOLOCK) WHERE RtrId = @RtrId and Upload=1
					
				END
				ELSE
				BEGIN
					UPDATE Retailer SET RtrStatus=@StatusId,Approved=@ApprovedId,RtrKeyAcc=@KeyAccId,
					RtrUniqueCode = @RtrUniqueCode	WHERE RtrId=@RtrId
				END
			
				--UPDATE Retailer SET RtrStatus=@Status,Approved=@ApprovedId,RtrKeyAcc=@KeyAccId,
				--RtrUniqueCode = @RtrUniqueCode WHERE RtrId=@RtrId
	
				
				SET @sSql='UPDATE Retailer SET RtrStatus='+CAST(@StatusId AS NVARCHAR(100))+',RtrKeyAcc='+CAST(@KeyAccId AS NVARCHAR(100))+' WHERE RtrId='+CAST(@RtrId AS NVARCHAR(100))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				DECLARE @OldCtgMainId	NUMERIC(38,0)
				DECLARE @OldCtgLevelId	NUMERIC(38,0)
				DECLARE @OldRtrClassId	NUMERIC(38,0)
				DECLARE @NewCtgMainId	NUMERIC(38,0)
				DECLARE @NewCtgLevelId	NUMERIC(38,0)
				DECLARE @NewRtrClassId	NUMERIC(38,0)
				SELECT @OldCtgMainId=A.CtgMainId,@OldCtgLevelId=B.CtgLevelId,@OldRtrClassId=C.RtrClassId 
				FROM RetailerCateGOry A INNER JOIN RetailerCateGOryLevel B ON A.CtgLevelId=B.CtgLevelId
				INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
				INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
				WHERE D.RtrId=@RtrId
				
				DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId
				
				SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(100))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				
				INSERT INTO RetailerValueClassMap
				(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@RtrId,@RtrClassId,
				1,@Pi_UserId,CONVERT(NVARCHAR(10),GETDATE(),121),@Pi_UserId,CONVERT(NVARCHAR(10),GETDATE(),121))
				SELECT @NewCtgMainId=A.CtgMainId,@NewCtgLevelId=B.CtgLevelId,@NewRtrClassId=C.RtrClassId 
				FROM RetailerCateGOry A INNER JOIN RetailerCateGOryLevel B ON A.CtgLevelId=B.CtgLevelId
				INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
				INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
				WHERE D.RtrId=@RtrId
				
				INSERT INTO Track_RtrCateGOryandClassChange
				SELECT -3000,@RtrId,@OldCtgLevelId,@OldCtgMainId,@OldRtrClassId,@NewCtgLevelId,@NewCtgMainId, 
				@NewRtrClassId,CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(23),GETDATE(),121),4
				
				SET @sSql='INSERT INTO RetailerValueClassMap
				(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RtrClassId AS VARCHAR(10))+',
				1,'+CAST(@Pi_UserId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',
				'+CAST(@Pi_UserId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
			
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END				
		END
		FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,
		@Status,@KeyAcc,@Approved,@RtrUniqueCode,@Mode
	END
	CLOSE Cur_RetailerApproval
	DEALLOCATE Cur_RetailerApproval
	UPDATE A SET A.DownLoadFlag='Y' FROM Cn2Cs_Prk_RetailerApproval A (NOLOCK) WHERE DownLoadFlag ='D'
	AND EXISTS (SELECT DISTINCT RtrId FROM Retailer B(NOLOCK) WHERE A.RtrCode = B.RtrCode) 
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateRetailerMaster' AND xtype='P')
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
  * DATE         AUTHOR				CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  2013/10/10   Sathishkumar V		CR						  Junk Characters Removed  
  10/05/2018   S.Moorthi			CR        CRCRSTPAR0001   Retailer Approval process - Manual
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
		SET @RtrId=0
		
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
				SELECT @RtrId=RtrId from Retailer WHERE RtrCode = @RetailerCode
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
		
		IF @Taction=1
		BEGIN
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
		
		IF @Po_ErrNo=0
		BEGIN		
			DECLARE @MSG AS VARCHAR(100)
			SET @MSG=''
			SELECT @MSG=DBO.Fn_RetailerApprovalStatus(@RtrId)
			IF ISNULL(@MSG,'')<>''
			BEGIN
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
				SELECT DISTINCT 5,'Retailer ApprovalStatus','ApprovalStatus',@MSG 
				SET @Po_ErrNo =1 
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
			
			--Added By S.Moorthi CRCRSTPAR0001
				IF EXISTS (SELECT '*' FROM Retailer (NOLOCK) WHERE RTRID = @RtrId and (RtrName<>@RetailerName
				or RtrStatus<>(CASE @Status WHEN 'Active' THEN 1 ELSE 0 END) or ISNULL(GeoMainId,0)<>ISNULL(@GeoMainId,0)))
				BEGIN

					IF NOT EXISTS (SELECT DISTINCT RtrId FROM RetailerApprovalStatus WHERE RtrId = @RtrId)
					BEGIN

						INSERT INTO RetailerApprovalStatus(RtrId,RtrCtgId,RtrClassId,RtrStatus,
						Rtrname,Geoid,Upload,Mode,ModDate)
						SELECT @RtrId,0,0,
						CASE WHEN RtrStatus=(CASE @Status WHEN 'Active' THEN 1 ELSE 0 END) THEN 2 ELSE (CASE @Status WHEN 'Active' THEN 1 ELSE 0 END) END,
						CASE WHEN RtrName=@RetailerName THEN '' ELSE @RetailerName END,
						CASE WHEN GeoMainId=@GeoMainId THEN 0 ELSE @GeoMainId END,
						0,2,GETDATE() FROM Retailer (NOLOCK) WHERE RtrId = @RtrId
					END
								  
					UPDATE A SET RtrName = CASE WHEN RTRIM(LTRIM(B.RtrName))=RTRIM(LTRIM(@RetailerName)) THEN '' ELSE @RetailerName END,
					RtrStatus=CASE WHEN B.RtrStatus=(CASE @Status WHEN 'Active' THEN 1 ELSE 0 END) THEN 2 ELSE (CASE @Status WHEN 'Active' THEN 1 ELSE 0 ENd) END,
					GeoId=CASE WHEN GeoMainId=@GeoMainId THEN 0 ELSE @GeoMainId END FROM RetailerApprovalStatus A INNER JOIN Retailer B ON A.RtrId=B.RtrId
					WHERE A.RtrId = @RtrId 

					SELECT @RetailerName=CASE WHEN RtrName=@RetailerName THEN @RetailerName ELSE RtrName END,
					@GeoMainId=CASE WHEN GeoMainId=@GeoMainId THEN @GeoMainId ELSE GeoMainId END,	
					@Status= CASE WHEN RtrStatus=(CASE @Status WHEN 'Active' THEN 1 ELSE 0 END) THEN (CASE @Status WHEN 'Active' THEN 1 ELSE 0 END) ELSE RtrStatus END 
					FROM Retailer (NOLOCK) WHERE RtrId = @RtrId

					UPDATE R SET R.Upload='N' FROM RetailerApprovalStatus A(NOLOCK)     
					INNER JOIN  RETAILER R (NOLOCK) ON A.RTRID=R.RTRID    
					WHERE A.Upload=0 AND R.RtrId=@RtrId    
						
				END
			--Till Here
			
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
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateRetailerValueClassMap' AND xtype='P')
DROP PROCEDURE Proc_ValidateRetailerValueClassMap
GO
CREATE PROCEDURE Proc_ValidateRetailerValueClassMap
(
	@Po_ErrNo INT OUTPUT
)
AS
/********************************************************************************************
* PROCEDURE	: Proc_ValidateRetailerValueClassMap
* PURPOSE	: To Insert and Update records  from xml file in the Table RetailerValueClassMap 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
  * DATE         AUTHOR				CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  2013/10/10   Sathishkumar V		CR						  Junk Characters Removed  
  10/05/2018   S.Moorthi			CR        CRCRSTPAR0001   Retailer Approval process - Manual
***********************************************************************************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @RetailerCode AS NVARCHAR(100)
	DECLARE @ValueClassCode AS NVARCHAR(100)
	DECLARE @CtgCode AS NVARCHAR(100)
	DECLARE @RtrId AS INT
	DECLARE @RtrValueClassId AS INT
	DECLARE @Taction AS INT
	DECLARE @Tabname AS NVARCHAR(100)
	DECLARE @TransType AS INT 
	DECLARE @SelectionType AS NVARCHAR(100)
	DECLARE @ErrDesc AS NVARCHAR(1000)
	DECLARE @sSql AS NVARCHAR(4000)
	DECLARE @CtgMainId AS NVARCHAR(100)
	DECLARE @CmpId AS NVARCHAR(100)
	
	SET @Taction=1
	SET @Po_ErrNo=0
	SET @TransType=1
	SET @Tabname='ETL_Prk_RetailerValueClassMap'
	DECLARE Cur_RetailerValueClassMap CURSOR 
	FOR SELECT dbo.Fn_Removejunk(ISNULL([Retailer Code],'')),dbo.Fn_Removejunk(ISNULL([Value Class Code],'')),
	ISNULL([CateGOry Level Value],''),ISNULL([Selection Type],'')
	FROM ETL_Prk_RetailerValueClassMap WITH(NOLOCK) ORDER BY [Retailer Code]
	OPEN Cur_RetailerValueClassMap
	FETCH NEXT FROM Cur_RetailerValueClassMap INTO @RetailerCode,@ValueClassCode,@CtgCode,@SelectionType
	WHILE @@FETCH_STATUS=0
	BEGIN	
		SET @CmpId=0
		IF NOT EXISTS (SELECT * FROM Retailer WHERE RtrCode = @RetailerCode)    
  		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Retailer Code ' + @RetailerCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (1,@Tabname,'RetailerCode',@ErrDesc)
		END
		ELSE
		BEGIN						
			SELECT @RtrId =RtrId FROM Retailer WHERE RtrCode = @RetailerCode
		END
		IF NOT EXISTS (SELECT * FROM RetailerCateGOry WHERE  CtgCode=@CtgCode)    
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'CateGOry Code ' + @CtgCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (2,@Tabname,'CateGOry Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @CtgMainId =CtgMainId FROM RetailerCateGOry WHERE CtgCode=@CtgCode
		END
		
		IF NOT EXISTS  (SELECT * FROM RetailerValueClass WHERE  ValueClassCode=@ValueClassCode AND CtgMainId=@CtgMainId )    
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Value Class Code ' + @ValueClassCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (3,@Tabname,'ValueClassCode',@ErrDesc)
		END
		ELSE
		BEGIN						
			SELECT @RtrValueClassId =RtrClassId,@CmpId=CmpId FROM RetailerValueClass WITH (NOLOCK)
			WHERE ValueClassCode=@ValueClassCode AND CtgMainId=@CtgMainId 
		END
		IF EXISTS (SELECT * FROM RetailerValueClassMap WHERE  RtrValueClassId=@RtrValueClassId AND RtrId=@RtrId)    
		BEGIN
			SET @Taction=2
		END
		ELSE
		BEGIN
			SET @Taction=1				
		END
		
		IF LTRIM(RTRIM(@SelectionType))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Value Class Selection Type should not be empty'  		 
			INSERT INTO Errorlog VALUES (4,@Tabname,'SelectionType',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@SelectionType))='ADD' OR LTRIM(RTRIM(@SelectionType))='REDUCE'
			BEGIN
				IF LTRIM(RTRIM(@SelectionType))='ADD' 
				BEGIN
					SET @TransType=1
				END
				IF LTRIM(RTRIM(@SelectionType))='REDUCE' 
				BEGIN
					SET @TransType=2
				END
			END
			ELSE 
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Value Class Type '+@SelectionType+' is not available'  		 
				INSERT INTO Errorlog VALUES (5,@Tabname,'SelectionType',@ErrDesc)
			END
		END
		
		IF @Po_ErrNo=0
		BEGIN
			DECLARE @MSG AS VARCHAR(MAX)						
			SET @MSG=''
			SELECT @MSG=DBO.Fn_RetailerApprovalStatus(@RtrId)
			IF ISNULL(@MSG,'')<>''
			BEGIN
				SET @Po_ErrNo=1		
				SET @Taction=0				
				SET @ErrDesc =@MSG
				INSERT INTO Errorlog VALUES (20,@Tabname,'Status',@MSG)
			END
		END
		
		IF @TransType=1 
		BEGIN
			IF  @Po_ErrNo=0 
			BEGIN
				DECLARE @OldCtgMainId	NUMERIC(38,0)
				DECLARE @OldCtgLevelId	NUMERIC(38,0)
				DECLARE @OldRtrClassId	NUMERIC(38,0)
				DECLARE @NewCtgMainId	NUMERIC(38,0)
				DECLARE @NewCtgLevelId	NUMERIC(38,0)
				DECLARE @NewRtrClassId	NUMERIC(38,0)
				DECLARE @RtrCnt			NUMERIC(38,0)
				SET @RtrCnt=0
				IF EXISTS(SELECT * FROM RetailerValueClassMap WHERE RtrId=@RtrId AND RtrValueClassId IN
						(SELECT RtrClassId FROM RetailerValueClass WHERE CmpId=@CmpId))
				BEGIN
			
					SELECT @OldCtgMainId=A.CtgMainId,@OldCtgLevelId=B.CtgLevelId,@OldRtrClassId=C.RtrClassId 
					FROM RetailerCateGOry A INNER JOIN RetailerCateGOryLevel B ON A.CtgLevelId=B.CtgLevelId
					INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
					INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
					WHERE D.RtrId=@RtrId
					SET @RtrCnt=1
				END
				--DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId AND RtrValueClassId=@RtrValueClassId
				--added by S.Moorthi
				DECLARE @ValueClassShift AS INT
				SET @ValueClassShift=1
				
				IF EXISTS(SELECT * FROM RetailerValueClassMap(nolock) WHERE RtrId=@RtrId)
				BEGIN
					IF NOT EXISTS(SELECT * FROM RetailerValueClassMap WHERE RtrId=@RtrId 
					AND RtrValueClassId=@RtrValueClassId)
					BEGIN
						SET @ValueClassShift=0	
					END				
				END
				
				IF @ValueClassShift=1
				BEGIN
					DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId AND RtrValueClassId IN
					(SELECT RtrClassId FROM RetailerValueClass WHERE CmpId=@CmpId)
					
					SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+
					' AND RtrValueClassId='+CAST(@RtrValueClassId AS NVARCHAR(10))
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					INSERT INTO RetailerValueClassMap 
					(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RtrId,@RtrValueClassId,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
					IF @RtrCnt=1
					BEGIN
						SELECT @OldCtgMainId=A.CtgMainId,@OldCtgLevelId=B.CtgLevelId,@OldRtrClassId=C.RtrClassId 
						FROM RetailerCateGOry A INNER JOIN RetailerCateGOryLevel B ON A.CtgLevelId=B.CtgLevelId
						INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
						INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
						WHERE D.RtrId=@RtrId
						INSERT INTO Track_RtrCateGOryandClassChange
						SELECT -4000,@RtrId,@OldCtgLevelId,@OldCtgMainId,@OldRtrClassId,@NewCtgLevelId,@NewCtgMainId, 
						@NewRtrClassId,CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(23),GETDATE(),121),5					
					END
				END
				ELSE
				BEGIN
					IF NOT EXISTS (SELECT DISTINCT RtrId FROM RetailerApprovalStatus WHERE RtrId = @RtrId)
					BEGIN
						INSERT INTO RetailerApprovalStatus(RtrId,RtrCtgId,RtrClassId,
						RtrStatus,RtrName,Geoid,Upload,Mode,ModDate)
						SELECT @RtrId,0,@RtrValueClassId,2,'',0,0,2,GETDATE()
					END
					ELSE
					BEGIN
						UPDATE RetailerApprovalStatus SET RtrCtgId = 0,RtrClassId = @RtrValueClassId,Mode = 2
						WHERE RtrId = @RtrId
					END
				END
				
				SET @sSql='INSERT INTO RetailerValueClassMap 
				(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RtrValueClassId AS VARCHAR(10))+', 
				1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
			
		IF @TransType=2 
		BEGIN
			IF @Po_ErrNo=0
			BEGIN
				DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId AND RtrValueClassId=@RtrValueClassId
				SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+' AND RtrValueClassId='+CAST(@RtrValueClassId AS VARCHAR(10))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
		
		FETCH NEXT FROM Cur_RetailerValueClassMap INTO @RetailerCode,@ValueClassCode,@CtgCode,@SelectionType		
	END
	CLOSE Cur_RetailerValueClassMap
	DEALLOCATE Cur_RetailerValueClassMap
	--->Added By Nanda on 04/03/2010
	IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap))
	BEGIN		
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Value Class','Value Class is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerValueClassMap))
		DELETE FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap)
		SET @sSql='DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerValueClassMap))'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
		SET @sSql='DELETE FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	--->Till Here
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ReturnTaxError' AND xtype IN ('FN','TF'))
DROP FUNCTION Fn_ReturnTaxError
GO
--Select * from Fn_ReturnTaxError(272,69,1007,0,0,0,1)
CREATE FUNCTION Fn_ReturnTaxError(@TransId AS INT,@MasterId as INT, @RtrId AS INT,@Prdid AS INT,
@PrdbatId AS INT,@SpmId as INT,@RtrShipId AS INT)
RETURNS @ReturnTaxError TABLE
(
	ErrorMessage  Varchar(500)
)
AS
/*********************************
* PROCEDURE		: Fn_ReturnTaxError
* PURPOSE		: Validate the Tax in Billing
* CREATED		: 
* CREATED DATE	:
* MODIFIED
*************************************************
* DATE			 AUTHOR				 CR/BZ		USER STORY ID		DESCRIPTION					
*************************************************
  10/05/2018    S.Moorthi			 CR        CRCRSTPAR0001   Retailer Approval process - Manual
*********************************/
BEGIN
	DECLARE @DistState AS Varchar(100)
	DECLARE @SupState AS Varchar(100)
	DECLARE @SupIntra AS Varchar(100)
	DECLARE @SupInter AS Varchar(100)
	DECLARE @RtrState AS Varchar(100)
	DECLARE @RtrIntra AS Varchar(100)
	DECLARE @RtrInter AS Varchar(100)
	DECLARE @Enabled AS TINYINT
	DECLARE @RtrType AS VARCHAR(50)
	SET @Enabled=0
	
	IF EXISTS(SELECT 'X' FROM GSTConfiguration (NOLOCK)
	WHERE  ModuleId='GSTCONFIG' AND Description='GST Configuration' AND ActivationStatus=1 and AcknowledgeStatus=1 and ConsoleAckStatus=1 
	--AND CONVERT(DATETIME,CONVERT(VARCHAR(10),@Date,121),121)>=ActivationDate
	)
	BEGIN
		SET @Enabled=1
	END
	
	
	IF @MasterId=79 AND @TransId IN(2,25,3)--Retailer Master
	BEGIN
		---BOTH GST AND VAT TAX Validation
		IF EXISTS(Select 'X' FROM Retailer (NOLOCK) WHERE RtrId=@RtrId and TaxgroupId=0)
		BEGIN
				INSERT INTO @ReturnTaxError(ErrorMessage)
				SELECT 'Retailer tax group not attached for the retailer '+ RtrCode FROM Retailer (NOLOCK) WHERE RtrId=@RtrId 
				RETURN
		END
		
		IF NOT EXISTS (Select 'X' FROM Retailer A (NOLOCK) INNER JOIN RetailerShipAdd B (Nolock) on A.RtrId=B.RtrId  WHERE A.RtrId=@RtrId)
		BEGIN
			INSERT INTO @ReturnTaxError(ErrorMessage)
			SELECT 'Retailer Shipping Address not available for the retailer '+ RtrCode FROM Retailer (NOLOCK) WHERE RtrId=@RtrId 
			RETURN
		END 
		
		--CRCRSTPAR0001
		IF @TransId IN(2,25)
		BEGIN
			IF EXISTS(Select 'X' FROM Retailer (NOLOCK) WHERE RtrId=@RtrId and Approved=2)
			BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'Rejected Retailer, Cannot Continue Billing '+ RtrCode FROM Retailer (NOLOCK) WHERE RtrId=@RtrId 
					RETURN
			END
			
			IF Exists (SELECT * FROM Configuration where ModuleId ='RET32' AND Status=1)
			BEGIN
				Declare @Confic AS Int
				SELECT @Confic=ConfigValue FROM Configuration where ModuleId ='RET32' AND Status=1
				
				IF EXISTS (Select COUNT(*) from SalesInvoice (Nolock) Where RtrId =@RtrId  HAVING COUNT(*)>= @Confic)
				BEGIN 
					IF EXISTS(SELECT 'X' FROM Retailer (NOLOCK) WHERE RtrId=@RtrId AND Approved=0)
					BEGIN
						INSERT INTO @ReturnTaxError(ErrorMessage)
						SELECT 'Get the Approval from the central system for the selected Retailer'+ RtrCode FROM Retailer (NOLOCK) WHERE RtrId=@RtrId 
						RETURN
					END
				END
			END	
			
		END
		
		IF @Enabled=1---GST Tax Validation
		BEGIN
		
			IF EXISTS(Select 'X' FROM Retailer  A(NOLOCK) 
			INNER JOIN RetailerShipAdd B (NOLOCK) ON A.RtrId=B.RtrId  
			WHERE A.RtrId=@RtrId AND B.RtrShipId=@RtrShipId and B.TaxgroupId=0)
			BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'Retailer Shipping Address tax group not attached for the retailer '+ RtrCode FROM Retailer (NOLOCK) WHERE RtrId=@RtrId 
					RETURN
			END
			
			IF EXISTS(Select 'X' FROM Retailer  A(NOLOCK) 
			INNER JOIN RetailerShipAdd B (NOLOCK) ON A.RtrId=B.RtrId  
			WHERE A.RtrId=@RtrId AND B.RtrShipId=@RtrShipId and B.RtrShipDefaultAdd=1 and A.TaxGroupId<>B.TaxGroupId)
			BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'Retailer Tax Group shuold be same for Default Shipping Address Tax Group for the retailer '+ RtrCode FROM Retailer (NOLOCK) 
					WHERE RtrId=@RtrId 
					RETURN
			END
			
			
			SELECT @RtrType=ColumnValue FROM UdcMaster U (NOLOCK) 
			INNER JOIN UdcDetails UD (NOLOCK) ON U.MasterId=UD.MasterId and U.UdcMasterId=UD.UdcMasterId
			INNER JOIN Retailer D (NOLOCK) ON D.RtrId=UD.MasterRecordId
			WHERE U.MasterId=2 and ColumnName='Retailer Type'   and D.RtrId=@RtrId
			IF LEN(LTRIM(RTRIM(ISNULL(@RtrType,''))))=0
			BEGIN
				INSERT INTO @ReturnTaxError(ErrorMessage)
				SELECT 'Please attach the Retailer Type in Retailer Master on UDC tab for the retailer code '+
				RtrCode FROM Retailer (NOLOCK) WHERE RtrId=@RtrId 
				
				RETURN
	        END
		
				SELECT @DistState=ColumnValue FROM UdcMaster U (NOLOCK) 
				INNER JOIN UdcDetails UD (NOLOCK) ON U.MasterId=UD.MasterId and U.UdcMasterId=UD.UdcMasterId
				INNER JOIN Distributor D (NOLOCK) ON D.DistributorId=UD.MasterRecordId
				INNER JOIN StateMaster S (NOLOCK) ON S.StateName=UD.ColumnValue
				WHERE U.MasterId=16 and ColumnName='State Name' 
				
				IF LEN(LTRIM(RTRIM(ISNULL(@DistState,''))))=0
				BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'Please attach the state in Distributor on UDC tab'
					RETURN
				END
				
				
				SELECT @RtrState=ColumnValue FROM UdcMaster U (NOLOCK) 
				INNER JOIN UdcDetails UD (NOLOCK) ON U.MasterId=UD.MasterId and U.UdcMasterId=UD.UdcMasterId
				INNER JOIN Retailer D (NOLOCK) ON D.RtrId=UD.MasterRecordId
				INNER JOIN StateMaster S (NOLOCK) ON S.StateName=UD.ColumnValue
				WHERE U.MasterId=2 and ColumnName='State Name'   and D.RtrId=@RtrId
				
				IF LEN(LTRIM(RTRIM(ISNULL(@RtrState,''))))=0
				BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'Please attach the state in Retailer Master on UDC tab for the retailer code '+
					RtrCode FROM Retailer (NOLOCK) WHERE RtrId=@RtrId 
					RETURN
				END
				
			IF @RtrShipId<>0
			BEGIN	
				----Added by Gopi at 10/07/2017
				SELECT @RtrState=StateName from StateMaster A INNER JOIN RetailerShipAdd B ON A.StateId=B.StateId
				AND B.RtrShipId=@RtrShipId and Rtrid=@Rtrid
				
				IF LEN(LTRIM(RTRIM(ISNULL(@RtrState,''))))=0
				BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'Please attach the state in Retailer Shpping address for the retailer address '+
					RtrShipadd1 FROM RetailerShipAdd (NOLOCK) WHERE RtrId=@RtrId and RtrShipId=@RtrShipId
					RETURN
				END
			END	
			----Till Here ----
		
		IF @RtrShipId=0
		BEGIN
				---Distributor and Retailer in Same State
				IF UPPER(@DistState)=UPPER(@RtrState)
				BEGIN
					SELECT @RtrIntra=RtrGroup from TaxGroupSetting A (NOLOCK) 
					INNER JOIN Retailer B (NOLOCK) ON A.TaxGroupId=B.TaxGroupId
					WHERE RtrId=@RtrId
					IF UPPER(@RtrIntra)<>'RTRINTRA'
					BEGIN
						INSERT INTO @ReturnTaxError(ErrorMessage)
						SELECT 'Please attach Retailer intra tax group (RTRINTRA) in Retailer Master on UDC tab'
						RETURN
					END
				END
				---Distributor and Retailer in different State
				IF UPPER(@DistState)<>UPPER(@RtrState)
				BEGIN
					SELECT @RtrInter=RtrGroup from TaxGroupSetting A (NOLOCK) 
					INNER JOIN Retailer B (NOLOCK) ON A.TaxGroupId=B.TaxGroupId
					WHERE RtrId=@RtrId
					IF UPPER(@RtrInter)<>'RTRINTER'
					BEGIN
						INSERT INTO @ReturnTaxError(ErrorMessage)
						SELECT 'Please attach Retailer Inter tax group (RTRINTER) in Retailer Master on UDC Tab'
						RETURN
					END
				END	
			END
				
				---Distributor and Retailer in Same State
				IF UPPER(@DistState)=UPPER(@RtrState)
				BEGIN
					SELECT @RtrIntra=RtrGroup from TaxGroupSetting A (NOLOCK) 
					INNER JOIN RetailerShipAdd B (NOLOCK) ON A.TaxGroupId=B.TaxGroupId
					WHERE RtrId=@RtrId and B.RtrShipId=@RtrShipId
					IF UPPER(@RtrIntra)<>'RTRINTRA'
					BEGIN
						INSERT INTO @ReturnTaxError(ErrorMessage)
						SELECT 'Please attach Retailer intra tax group (RTRINTRA) in Retailer Shipping'
						RETURN
					END
				END
				---Distributor and Retailer in different State
				IF UPPER(@DistState)<>UPPER(@RtrState)
				BEGIN
					SELECT @RtrInter=RtrGroup from TaxGroupSetting A (NOLOCK) 
					INNER JOIN RetailerShipAdd B (NOLOCK) ON A.TaxGroupId=B.TaxGroupId
					WHERE RtrId=@RtrId and B.RtrShipId=@RtrShipId
					IF UPPER(@RtrInter)<>'RTRINTER'
					BEGIN
						INSERT INTO @ReturnTaxError(ErrorMessage)
						SELECT 'Please attach Retailer intra tax group (RTRINTER) in Retailer Shipping'
						RETURN
					END
				END	
				
		END			
	END	
	--Billing,Salespanel,SalesReturn,Purchase,Purchase Return
	IF @TransId IN(2,25,3,5,7,272)--Product
	BEGIN
		IF EXISTS(Select 'X' FROM Product (NOLOCK) WHERE Prdid=@Prdid and TaxgroupId=0)
		BEGIN
				INSERT INTO @ReturnTaxError(ErrorMessage)
				SELECT 'Product tax group not attached for the product '+ PrdCCode FROM Product (NOLOCK) WHERE Prdid=@Prdid 
				RETURN
		END
	END	
	--Billing,Salespanel,SalesReturn,Purchase,Purchase Return
	IF @TransId IN(2,25,3,5,7,272)
	BEGIN
			
		IF EXISTS(Select 'X' FROM Productbatch (NOLOCK) WHERE PrdbatId=@PrdbatId and TaxgroupId=0)
		BEGIN
				INSERT INTO @ReturnTaxError(ErrorMessage)
				SELECT 'Product tax group not attached for the product batch '+ PrdBatCode +Space(2)+' for the product ' +  PrdCCode
				FROM Productbatch A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId=B.Prdid WHERE PrdbatId=@PrdbatId 
				RETURN
		END
		
		IF @TransId IN(2,25)
		BEGIN
			IF @Enabled=1
			BEGIN
				IF EXISTS(SELECT '*' FROM ProductBatch_Temp_GST(NOLOCK))
				BEGIN
					DECLARE @Count AS INT
					SET @Count=0
					
					SELECT @Count=Count(*) FROM ProductBatch_Temp_GST(NOLOCK)  WHERE DownLoadFlag='Y'
					
					IF ISNULL(@Count,0)=0
					BEGIN
						INSERT INTO @ReturnTaxError(ErrorMessage)
						SELECT 'GST Product batch downloaded pending for batch transfer,Please login and continue..'					
						RETURN
					END
				END
				ELSE
				BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'GST Product batch not downloaded can not continue..'					
					RETURN
				END	
			END
		END
		
	END	
	
	IF @MasterId=69 AND @TransId=272--Supplier	
	BEGIN
		IF EXISTS(Select 'X' FROM IDTMaster (NOLOCK) WHERE SpmId=@SpmId and TaxgroupId=0)
		BEGIN
				INSERT INTO @ReturnTaxError(ErrorMessage)
				SELECT 'IDT Distributor tax group not attached for the Distributor Code '+SpmCode FROM IDTMaster (NOLOCK) WHERE SpmId=@SpmId
				RETURN
		END
	END
	
	IF @MasterId=69 AND @TransId IN(5,7)--Supplier		
	BEGIN
	
		IF EXISTS(Select 'X' FROM Supplier (NOLOCK) WHERE SpmId=@SpmId and TaxgroupId=0)
		BEGIN
				INSERT INTO @ReturnTaxError(ErrorMessage)
				SELECT 'Supplier tax group not attached for the Supplier Code '+SpmCode FROM Supplier (NOLOCK) WHERE SpmId=@SpmId
				RETURN
		END
		IF @Enabled=1---GST Tax Validation
		BEGIN
			SELECT @DistState=ColumnValue FROM UdcMaster U (NOLOCK) 
			INNER JOIN UdcDetails UD (NOLOCK) ON U.MasterId=UD.MasterId and U.UdcMasterId=UD.UdcMasterId
			INNER JOIN Distributor D (NOLOCK) ON D.DistributorId=UD.MasterRecordId
			INNER JOIN StateMaster S (NOLOCK) ON S.StateName=UD.ColumnValue
			WHERE U.MasterId=16 and ColumnName='State Name' 
			
			IF LEN(LTRIM(RTRIM(ISNULL(@DistState,''))))=0
			BEGIN
				INSERT INTO @ReturnTaxError(ErrorMessage)
				SELECT 'Please attach the state in Distributor on UDC tab'
				RETURN
			END
			SELECT @SupState=ColumnValue FROM UdcMaster U (NOLOCK) 
			INNER JOIN UdcDetails UD (NOLOCK) ON U.MasterId=UD.MasterId and U.UdcMasterId=UD.UdcMasterId
			INNER JOIN Supplier D (NOLOCK) ON D.SpmId=UD.MasterRecordId
			INNER JOIN StateMaster S (NOLOCK) ON S.StateName=UD.ColumnValue
			WHERE U.MasterId=8 and ColumnName='State Name' and SpmId=@SpmId
			
			IF LEN(LTRIM(RTRIM(ISNULL(@SupState,''))))=0
			BEGIN
				INSERT INTO @ReturnTaxError(ErrorMessage)
				SELECT 'Please attach the state in Supplier Master on UDC tab'
				RETURN
			END
			---Distributor and supplier in Same State
			IF UPPER(@DistState)=UPPER(@SupState)
			BEGIN
				SELECT @SupIntra=RtrGroup from TaxGroupSetting A (NOLOCK) 
				INNER JOIN Supplier B (NOLOCK) ON A.TaxGroupId=B.TaxGroupId
				WHERE SpmId=@SpmId
				IF UPPER(@SupIntra)<>'SUPINTRA'
				BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'Please attach supplier intra tax group (SUPINTRA) in Supplier Master'
					RETURN
				END
			END
			---Distributor and supplier in different State
			IF UPPER(@DistState)<>UPPER(@SupState)
			BEGIN
				SELECT @SupInter=RtrGroup from TaxGroupSetting A (NOLOCK) 
				INNER JOIN Supplier B (NOLOCK) ON A.TaxGroupId=B.TaxGroupId
				WHERE SpmId=@SpmId
				IF UPPER(@SupInter)<>'SUPINTER'
				BEGIN
					INSERT INTO @ReturnTaxError(ErrorMessage)
					SELECT 'Please attach supplier Inter tax group (SUPINTER) in Supplier Master'
					RETURN
				END
			END
		END
	END	
		
RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_Validate_InstitutionsTargetSetting' AND xtype='P')  
DROP PROCEDURE Proc_Validate_InstitutionsTargetSetting
GO
/*
BEGIN TRAN
--SELECT * FROM InsTargetHD (NOLOCK)
EXEC Proc_Validate_InstitutionsTargetSetting 0
SELECT * FROM InsTargetHD (NOLOCK)
select * from Cn2Cs_Prk_InstitutionsTargetSetting
ROLLBACK TRAN
*/  
CREATE PROCEDURE Proc_Validate_InstitutionsTargetSetting  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
/*********************************  
* PROCEDURE : Proc_Validate_InstitutionsTargetSetting 0  
* PURPOSE : To Validate Proc_Validate_InstitutionsTargetSetting and move to main  
* CREATED : Aravindh Deva C  
* CREATED DATE : 20/05/2016  
* MODIFIED   
' Version       Date        Person           User Story ID    CR/BZ          Remarks               Code Review By   Review Date
' 436           15/05/2018  S.MOORTHI        CRCRSTPAR0004    CR			 Target Resetting   
*********************************/   
BEGIN  
 SET @Po_ErrNo=0  
 BEGIN TRY    
     
   DELETE PRK FROM Cn2Cs_Prk_InstitutionsTargetSetting PRK (NOLOCK) WHERE DownloadFlag='Y'  
     
   SELECT DISTINCT * INTO #Cn2Cs_Prk_InstitutionsTargetSetting FROM Cn2Cs_Prk_InstitutionsTargetSetting (NOLOCK) WHERE DownloadFlag='D'  
     
   IF NOT EXISTS (SELECT * FROM #Cn2Cs_Prk_InstitutionsTargetSetting (NOLOCK)) RETURN  
     
   CREATE TABLE #InsToAvoid  
   (  
    ProgramCode VARCHAR(50),  
    SlNo INT,  
    TableName NVARCHAR (200),  
    FieldName NVARCHAR (200),  
    ErrDesc NVARCHAR (1000)  
   )  
     
   SELECT DISTINCT C.CtgCode,R.CmpRtrCode,C.CtgMainId,R.RtrId  
   INTO #CSCtgCode  
   FROM RetailerCategory C (NOLOCK)  
   INNER JOIN RetailerValueClass V (NOLOCK) ON C.CtgMainId = V.CtgMainId  
   INNER JOIN RetailerValueClassMap M (NOLOCK) ON V.RtrClassId = M.RtrValueClassId  
   INNER JOIN Retailer R (NOLOCK) ON M.RtrId = R.RtrId  
     
   INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT ProgramCode,1,'Cn2Cs_Prk_InstitutionsTargetSetting','ProgramCode','The program code is already existing ' +   
   ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting Prk (NOLOCK)   
   WHERE EXISTS (SELECT 'C' FROM InsTargetHD C (NOLOCK) WHERE Prk.ProgramCode = C.InsRefNo)  
     
   INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT ProgramCode,2,'Cn2Cs_Prk_InstitutionsTargetSetting','CtgCode','Retailer / Category / Retailer and Category mapping is not valid for Program ' +   
   ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting Prk (NOLOCK) WHERE NOT EXISTS  
   (SELECT * FROM #CSCtgCode C (NOLOCK) WHERE Prk.RtrGroup = C.CtgCode AND Prk.CmpRtrCode = C.CmpRtrCode)  
     
   INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT ProgramCode,3,'Cn2Cs_Prk_InstitutionsTargetSetting','ProgramCode','No values should be NULL for the Program ' +  
   ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting   
   WHERE (FromProgramYear) IS NULL  Or (ToProgramYear) IS NULL  
   OR (RtrGroup + CmpRtrCode) IS NULL  
   OR (AVGSales + TargetAmount + EffFromMonthId) IS NULL  
   INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT ProgramCode,4,'Cn2Cs_Prk_InstitutionsTargetSetting','TargetAmount','TargetAmount field should not be Zero Or NULL' +  
   ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting   
   WHERE ISNULL(TargetAmount,0) = 0  
     
      INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT ProgramCode,5,'Cn2Cs_Prk_InstitutionsTargetSetting','EffFromMonthId','EffFromMonthId field should not be Zero Or NULL' +  
   ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting   
   WHERE ISNULL(EffFromMonthId,0) = 0  
     
   INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT ProgramCode,6,'Cn2Cs_Prk_InstitutionsTargetSetting','EffToMonthId','EffToMonthId field should not be Zero Or NULL' +  
   ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting   
   WHERE ISNULL(EffToMonthId,0) = 0  
     
   INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT SlNo,TableName,FieldName,ErrDesc FROM #InsToAvoid (NOLOCK)  
     
   DELETE P FROM #Cn2Cs_Prk_InstitutionsTargetSetting P  
   WHERE EXISTS (SELECT 'C' FROM #InsToAvoid A (NOLOCK) WHERE P.ProgramCode = A.ProgramCode)  
     
   DECLARE @CurrValue AS INT  
     
   SELECT @CurrValue = CurrValue FROM Counters  (NOLOCK)   
   WHERE TabName='InsTargetHD' AND FldName='InsId'  
   
   ----CRCRSTPAR0004
	UPDATE B SET B.[Status]=0 FROM #Cn2Cs_Prk_InstitutionsTargetSetting A 
	INNER JOIN InsTargetHD B ON A.FromProgramYear=B.TargetYear and A.EffFromMonthId=B.TargetMonth
	WHERE CAST(CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(targetmonth AS VARCHAR(2))+ '-01'  AS DATETIME)>=
	(SELECT JcmSdt FROM JCMonth WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN JcmSdt AND JcmEdt)

	DELETE A FROM #Cn2Cs_Prk_InstitutionsTargetSetting A  
	INNER JOIN InsTargetHD B ON A.FromProgramYear=B.TargetYear and A.EffFromMonthId=B.TargetMonth
	WHERE CAST(CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(targetmonth AS VARCHAR(2))+ '-01'  AS DATETIME)<
	(SELECT JcmSdt FROM JCMonth WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN JcmSdt AND JcmEdt)
    --CRCRSTPAR0004
     
   --Header  
   INSERT INTO InsTargetHD (InsId,InsRefNo,TargetDate,TargetMonth,TargetYear,[Status],Confirm,Upload,Availability,  
   LastModBy,LastModDate,AuthId,AuthDate,EffFromMonthId,EffToMonthId,ToTargetYear)  
     
   SELECT ROW_NUMBER() OVER(ORDER BY ProgramCode) + @CurrValue InsId,  
   ProgramCode InsRefNo,GETDATE() TargetDate,EffFromMonthId [TargetMonth],FromProgramYear [TargetYear],1 [Status],0 Confirm,0 Upload,  
   1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,MAX(CreatedDate) AuthDate,EffFromMonthId,EffToMonthId,ToProgramYear [ToTargetYear]     
   FROM #Cn2Cs_Prk_InstitutionsTargetSetting   
   GROUP BY ProgramCode,[FromProgramYear],EffFromMonthId,EffToMonthId,ToProgramYear  
     
   --Retailer Details  
   --INSERT INTO InsTargetDetails (InsId,RtrCtgMainId,RtrId,AvgSal,[Target],Achievement,BaseAch,TargetAch,  
   --ValBaseAch,ValTargetAch,ClmAmount,Liability,Availability,LastModBy,LastModDate,AuthId,AuthDate,  
   --RtrUniqueCode,CmpRtrCode,AchDownloadDate,MonthName,RtrGroup)  
     
   --SELECT DISTINCT H.InsId,C.CtgMainId,C.RtrId,P.AVGSales,P.[TargetAmount],  
   --0 Achievement,0 BaseAch,0 TargetAch,0 ValBaseAch,0 ValTargetAch,0 ClmAmount,0 Liability,  
   --1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,CreatedDate AuthDate,  
   --P.RtrUniqueCode,P.CmpRtrCode,'1900-01-01','',P.RtrGroup     
   --FROM #Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK)  
   --INNER JOIN InsTargetHD H (NOLOCK) ON P.ProgramCode = H.InsRefNo  
   --INNER JOIN #CSCtgCode C (NOLOCK) ON P.RtrGroup = C.CtgCode AND P.CmpRtrCode = C.CmpRtrCode  
   --ORDER BY InsId,C.CtgMainId,C.RtrId  
     
   INSERT INTO InsTargetDetails (InsId,RtrCtgMainId,RtrId,AvgSal,[Target],Achievement,BaseAch,TargetAch,  
   ValBaseAch,ValTargetAch,ClmAmount,Liability,Availability,LastModBy,LastModDate,AuthId,AuthDate,  
   RtrUniqueCode,CmpRtrCode)  
     
   SELECT DISTINCT H.InsId,C.CtgMainId,C.RtrId,P.AVGSales,P.[TargetAmount],  
   0 Achievement,0 BaseAch,0 TargetAch,0 ValBaseAch,0 ValTargetAch,0 ClmAmount,0 Liability,  
   1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,CreatedDate AuthDate,  
   P.RtrUniqueCode,P.CmpRtrCode    
   FROM #Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK)  
   INNER JOIN InsTargetHD H (NOLOCK) ON P.ProgramCode = H.InsRefNo and P.EffFromMonthId=H.EffFromMonthId  
   AND P.FromProgramYear=H.TargetYear  
   INNER JOIN #CSCtgCode C (NOLOCK) ON P.RtrGroup = C.CtgCode AND P.CmpRtrCode = C.CmpRtrCode  
   ORDER BY InsId,C.CtgMainId,C.RtrId  
     
    
   UPDATE C SET C.CurrValue = (SELECT ISNULL(MAX(InsId),0) FROM InsTargetHD (NOLOCK))  
   FROM Counters C (NOLOCK)  
   WHERE TabName='InsTargetHD' AND FldName='InsId'  
     
   UPDATE P SET P.DownloadFlag='Y'  
   FROM Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK),  
   #Cn2Cs_Prk_InstitutionsTargetSetting HP,  
   InsTargetHD H (NOLOCK) WHERE P.ProgramCode = HP.ProgramCode AND P.ProgramCode = H.InsRefNo  
 END TRY  
   
 BEGIN CATCH  
  PRINT 'There is a problem in process!'  
  SET @Po_ErrNo=1 -- 1 will rollback the process through Sync EXE  
  RETURN  
 END CATCH    
    
RETURN  
END
GO
--ADDED BY MOHANA FOR TAX CALCULATE IN WITHOUT REFERENCE RETURN ILCRSTKAL0073
DELETE FROM ManualConfiguration where ModuleId='PUR_RETURN1'
INSERT INTO ManualConfiguration 
SELECT 'GST','PUR_RETURN1','Purchase Return','Apply Tax for Without Reference Returns',1,0,0.00,1
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='FN_CheckForPurchaseReturnTax_GST' AND TYPE='FN')
DROP FUNCTION FN_CheckForPurchaseReturnTax_GST
GO
CREATE FUNCTION FN_CheckForPurchaseReturnTax_GST(@Date AS DATETIME,@RefNo AS NVARCHAR(50),@InvDate AS DATETIME)
RETURNS INTEGER 
AS	
BEGIN
	DECLARE @Year AS INT
	DECLARE @Month AS INT
	DECLARE @ActivationDate AS DATETIME
	DECLARE @FinanceFromDate AS DATETIME
	DECLARE @FinanceToDate AS DATETIME
	DECLARE @TaxSubMissionDate AS DATETIME
	DECLARE @Day AS INT
	DECLARE @ApplyTax AS  INT
	
	SET @Year=YEAR(GETDATE())
	SET @Month=MONTH(GETDATE())
	 
	SELECT @Day =ISNULL(configvalue,0) FROM MANUALCONFIGURATION WHERE ProjectName='GST' AND ModuleId='SAL_RETURN1' AND ModuleName='Sales Return'
	SET @ApplyTax=1  
	
	IF EXISTS(SELECT 'X' FROM GSTConfiguration 
	WHERE ModuleId='GSTCONFIG' AND Description='GST Configuration' and ActivationStatus=1 AND AcknowledgeStatus=1 AND ConsoleAckStatus=1)
	BEGIN
		SET @TaxSubMissionDate=CONVERT(VARCHAR(10),@Year)+'-'+ CONVERT(VARCHAR(5),@Day) +'-'+'01'
		
		SET @TaxSubMissionDate=CONVERT(VARCHAR(10),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@TaxSubMissionDate)+1,0)),121)--GET THE LAST DATE OF THE MONTH
		
		IF @Date<=@TaxSubMissionDate
		BEGIN		
			SET @FinanceFromDate=(SELECT CONVERT(VARCHAR(10),DATEADD(MONTH,-18,@TaxSubMissionDate),121) ) 
			SET @FinanceFromDate=(SELECT CONVERT(VARCHAR(10),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@FinanceFromDate)+1,0)),121))--GET THE LAST DATE OF THE MONTH
			
			IF @InvDate>@FinanceFromDate
			BEGIN
				SET @ApplyTax=1
			END
			
			IF @InvDate<=@FinanceFromDate
			BEGIN
				SET @ApplyTax=0
			END			
 		END
		
		IF @Date>=@TaxSubMissionDate
		BEGIN
			SET @FinanceFromDate= CONVERT(VARCHAR(10),@Year)+'-04-'+'01' 
			IF @InvDate>=@FinanceFromDate
			BEGIN
				SET @ApplyTax=1			
			END
		
			IF 	@InvDate<@FinanceFromDate
			BEGIN
				SET @ApplyTax=0		
			END
 		 END
 		 --Commented for BZ:ICRSTNIV2954
  	--	IF @InvDate<'2017-07-01' AND (YEAR(@InvDate)=2017 OR YEAR(@InvDate)=2018)
 		--BEGIN
 		--	SET @ApplyTax=0		
 		--END 
		
	END 
	RETURN(@ApplyTax)
END
GO
--Added By Mohana.S
IF  EXISTS (SELECT * FROM sys.objects WHERE NAME='Debitnote_Scheme' AND TYPE ='U')
DROP TABLE Debitnote_Scheme
GO
CREATE TABLE Debitnote_Scheme
(
	[SchId] [int] NULL,
	[SlabId] [int] NULL,
	[Salid] [int] NULL,
	[FlatAmount] [numeric](38, 6) NULL,
	[DiscountPer] [numeric](38, 6) NULL,
	[FreeValue] [numeric](38, 6) NULL,
	[GiftValue] [numeric](38, 6) NULL,
	[SchemeBudget] [numeric](38, 6) NULL,
	[BudgetUtilized] [numeric](38, 6) NULL,
	[Selected] [int] NULL,
	[Linetype] [int] NULL,
	[Salinvdate] [datetime] NULL,
	[Prdid] [int] NULL
)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 56
INSERT INTO Tbl_UploadIntegration 
SELECT 56,'DebitNoteTopSheet4','DebitNoteTopSheet4','Cs2Cn_Prk_DebitNoteTopSheet4',GETDATE()
GO
DELETE FROM CustomUpDownload WHERE UpDownload ='upload' AND SlNo = 158
INSERT INTO CustomUpDownload 
SELECT 158,1,'Debit Note Top Sheet TOT','DebitNoteTopSheet4','Proc_Cs2Cn_DebitNoteTopSheet4','','Cs2Cn_Prk_DebitNoteTopSheet4','','Transaction','Upload',1
GO
IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cs2Cn_Prk_DebitNoteTopSheet4]') AND type in (N'U'))
DROP TABLE Cs2Cn_Prk_DebitNoteTopSheet4
GO
CREATE TABLE Cs2Cn_Prk_DebitNoteTopSheet4
(
	[SlNo] [NUMERIC](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode]   [NVARCHAR](50) NULL,
	[RTRCODE]    [NVARCHAR](50) NULL,
	[CTGNAME]    [NVARCHAR](50) NULL,
	[SalInvNo]   [NVARCHAR](50) NULL,
	[SalInvDate] [NVARCHAR](50) NULL,
	[PrdCCode]   [NVARCHAR](50) NULL,
	[NRMLRATE]   NUMERIC(38,2) NULL,
	[SPLRATE]    NUMERIC(38,2) NULL,
	[DIFF]       NUMERIC(38,2) NULL,
	[UploadFlag] [NVARCHAR](10) NULL,
	[SyncId] [NUMERIC](38, 0) NULL,
	[ServerDate] [DATETIME] NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Fn_ReturnPrice' AND TYPE='FN')
DROP FUNCTION Fn_ReturnPrice
GO
--SELECT DBO.FN_RETURNPRICE (@PRDID,@PRDBATID) AS PRICEID
CREATE FUNCTION  Fn_ReturnPrice(@prdid  AS bigint,@Prdbatid AS bigint)
RETURNS bigint 
AS 
BEGIN
/*********************************
* FUNCTION		: Fn_ReturnPrice
* PURPOSE		: To return Normal Price (Copied From Nestle for spldiscount issue)
* CREATED		: Mohana
* CREATED DATE	: 31-05-2018
* PMS NO		: ILCRSTPAR0830
****************************************************************************************************/
DECLARE @PriceId as bigint

SET @PriceId=(SELECT  DISTINCT B.PriceId FROM ProductBatch A (NOLOCK)
INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId WHERE A.Status = 1 
AND A.PrdId=@prdid AND B.prdbatid=@Prdbatid )

RETURN(@PriceId)

END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptPendingBillReport' AND TYPE='P')
DROP PROCEDURE Proc_RptPendingBillReport
GO
--EXEC Proc_RptPendingBillReport 3,2,0,'fer',0,0,1
CREATE PROCEDURE Proc_RptPendingBillReport
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
/*******************************************************************************************************************   
* Date			  Author	    CR/BZ	 UserStoryId		    Description
* 08-06-2018	 Mohana S       BZ	     ILCRSTPAR0925	        Cheque Bounce status has included
****************************************************************************************************/
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
	DECLARE @AsOnDate	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @PDCTypeId	 	AS	INT
	SELECT @AsOnDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @PDCTypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	DECLARE @RPTBasedON AS INT
	SET @RPTBasedON =0
	SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,256,@Pi_UsrId) 
	DECLARE @Orderby AS Int
	SET @Orderby=0 
	SET @Orderby = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,277,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@AsOnDate,@AsOnDate)
	Create TABLE #RptPendingBillsDetails
	(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         		INT,
			RtrName 		NVARCHAR(50),	
			SalId         		BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate              DATETIME,
			SalInvRef 		NVARCHAR(50),
			CollectedAmount 	NUMERIC (38,6),
			BalanceAmount   	NUMERIC (38,6),
			ArDays			INT,
			BillAmount      	NUMERIC (38,6)
	)
	CREATE TABLE #TempReceiptInvoice
	(
		SalId		INT,
		InvInsSta	INT,
		InvInsAmt	NUMERIC(38,2)
	)
	
	SET @TblName = 'RptPendingBillsDetails'
	
	SET @TblStruct = '	SMId 			INT,
				SMName			NVARCHAR(50),
				RMId 			INT,
				RMName 			NVARCHAR(50),
				RtrId         		INT,
				RtrName 		NVARCHAR(50),	
				SalId         		BIGINT,
				SalInvNo 		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				CollectedAmount 	NUMERIC (38,6),
				BalanceAmount   	NUMERIC (38,6),
				ArDays			INT,
				BillAmount      	NUMERIC (38,6)'
	
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,CollectedAmount,
			  BalanceAmount,ArDays,BillAmount'
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	END
	ELSE
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo = 3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	 BEGIN
			IF @PDCTypeId=1 --Include PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,
						SI.SalInvRef,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SI.SalInvDate,GetDate()) AS ArDays,SI.SalNetAmt
				 Into #PendingBills1
				 FROM Salesinvoice  SI WITH (NOLOCK),
					  Salesman S WITH (NOLOCK),
					  RouteMaster R WITH (NOLOCK),
					  Retailer RE  WITH (NOLOCK)
				
				 WHERE  SI.SMId = S.SMId  AND SI.RMId = R.RMId
						AND SI.RtrId = RE.RtrId  AND SI.DlvSts IN(4,5)
						AND SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO and INVINSSta<> 4 AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(#PendingBills1.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				Update #PendingBills1
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills1
			END
			IF @PDCTypeId<>1 --Exclude PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,
						SI.SalInvRef,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SalInvDate,GetDate()) AS ArDays,SI.SalNetAmt
				 Into #PendingBills
				
				 FROM Salesinvoice  SI WITH (NOLOCK),
					  Salesman S WITH (NOLOCK),
					  RouteMaster R WITH (NOLOCK),
					  Retailer RE  WITH (NOLOCK)
				
				 WHERE  SI.SMId = S.SMId  AND SI.RMId = R.RMId
						AND SI.RtrId = RE.RtrId  AND SI.DlvSts IN (4,5)
						and SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(#PendingBills.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 AND InvInsDate<=CONVERT(DATETIME,@AsOnDate,103) and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				Update #PendingBills
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills
            END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR' +
				' SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '+
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR ' +
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR '+
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND SalInvDate<=''' + @AsOnDate + ''''
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptPendingBillsDetails'
	
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
		SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPendingBillsDetails
-- Till Here
--	SELECT * FROM #RptPendingBillsDetails ORDER BY SMId,SalId,ArDays,SalInvDate
	--Added by Thiru on 13/11/2009
	DELETE FROM #RptPendingBillsDetails WHERE (BillAmount-CollectedAmount)<=0
--	IF @RPTBasedON=1
--		BEGIN 
--			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
--        END 
--	
	IF @Orderby=0 AND @RPTBasedON=0 
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY SMName 
		END 
	IF @Orderby=1 AND @RPTBasedON=0  
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY RMName 
		END
	IF @Orderby=2 AND @RPTBasedON=0  
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY RtrName 
		END
	IF @Orderby=3 AND @RPTBasedON=0  
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY SalInvNo 
		END
	ELSE 
		BEGIN 
			SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,CONVERT(VARCHAR(8), SalinvDate, 3) SalInvDate,SalInvRef,CollectedAmount,BalanceAmount,ArDays,BillAmount FROM #RptPendingBillsDetails ORDER BY ArDays DESC
		END 
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptPendingBillsDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptPendingBillsDetails_Excel
		CREATE TABLE RptPendingBillsDetails_Excel
		(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         	INT,
			RtrCode			NVARCHAR(100),	
			RtrName 		NVARCHAR(150),	
			SalId         	BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate      DATETIME,
			SalInvRef 		NVARCHAR(50),
			BillAmount      NUMERIC (38,6),
			Cash			NUMERIC (38,6),
			ChequeAmt		NUMERIC (38,6),
			ChequeNo		Int,
			CollectedAmount NUMERIC (38,6),
			BalanceAmount   NUMERIC (38,6),
			ArDays			INT,
			OrderBy			Int
		)
		INSERT INTO RptPendingBillsDetails_Excel( SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,Cash,ChequeAmt,ChequeNo,CollectedAmount,
			  BalanceAmount,ArDays,OrderBy)
		  SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,0 As Cash,0 AS ChequeAmt,0 As ChequeNo,CollectedAmount,
			  BalanceAmount,ArDays,@OrderBy FROM  #RptPendingBillsDetails	
	   
		UPDATE RPT SET RPT.[RtrCode]=R.RtrCode FROM RptPendingBillsDetails_Excel RPT,Retailer R WHERE RPT.[RtrName]=R.RtrName
	END
	RETURN
END
GO
--Mohana.S Till Here
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptGSTR1_B2B' AND TYPE='P')
DROP PROCEDURE Proc_RptGSTR1_B2B
GO
/*
EXEC Proc_RptGSTR1_B2B 414,1,0,'',0,0,0
 */
CREATE PROCEDURE Proc_RptGSTR1_B2B
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
* PROCEDURE		: Proc_RptGSTR1_B2B
* PURPOSE		: To Generate a report GSTR1 B2B
* CREATED		: Murugan.R
* CREATED DATE	: 13/04/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
11-01-2018	  MURUGAN	  BZ			ICRSTLOR2374		GSTR1 Report - REFRESH ISSUE FIX
* 11-06-2018	  S.MOORTHI	  BZ			ILCRSTPAR0926       IDT TAX AMOUNT NOT SHOWING/ILCRSTLOR0379
*********************************/
SET NOCOUNT ON
BEGIN
		TRUNCATE TABLE RptGSTR1_B2B
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		--ICRSTLOR2374
		DELETE FROM  ReportFilterDt WHERE RptId IN(414,415,416,417,418,419,420,421) 
		INSERT INTO ReportFilterDt(RptId,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate)
		SELECT 414,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 415,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 416,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 417,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 418,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId	
		UNION ALL
		SELECT 419,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 420,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		UNION ALL
		SELECT 421,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
		FROM ReportFilterDt WHERE RptId=424 AND UsrId=@Pi_UsrId
		--ICRSTLOR2374
		
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017
		
		
		CREATE TABLE #RptGSTR1_B2B
		(
		TransId				TINYINT,
		TranType			VARCHAR(20),
		Refid				BIGINT,
		RtrShipId			INT,
		RtrId				INT,
		RtrCode				VARCHAR(50),		
		RtrName				VARCHAR(100),
		[GSTIN/UIN of Recipient]	 VARCHAR(50),
		[Retailer Type]		 VARCHAR(50),
		[Invoice Number]	 VARCHAR(50),
		[Invoice date]		 DATETIME,
		[Invoice Value]		 NUMERIC(32,2),
		[Place Of Supply]	 VARCHAR(125),
		[Reverse Charge]	 VARCHAR(10),
		[Invoice Type]		 VARCHAR(50),
		[Kind of transaction]			Varchar(50),
		[Identifier if Goods or Services]	Varchar(50),		
		[E-Commerce GSTIN]	 VARCHAR(50),
		[Rate]				 NUMERIC(10,2),
		[Taxable Value]		 NUMERIC(32,2),
		[Cess Amount]		 NUMERIC(32,2),
		[IGST rate]			 Numeric(32,2),
		[IGST amount]		 Numeric(32,2),
		[CGST rate]			 Numeric(32,2),
		[CGST amount]		 Numeric(32,2),
		[SGST/UTGST rate]	 Numeric(32,2),
		[SGST/UTGST amount]	 Numeric(32,2),		
		UsrId				 INT,
		[Group Name]		 VARCHAR(100),
		GroupType			 TINYINT
		)
		
		SELECT PurRcptId INTO #Purchareceipt
		FROM PurchaseReceipt (NOLOCK)
		WHERE GoodsRcvdDate Between '2017-01-01' and '2017-06-30' and VatGst='VAT'
		and Status=1
		
		---Retailer State
		SELECT DISTINCT  R.RtrId as RtrId,TinFirst2Digit+'-'+StateName as StateName
		INTO #RetailerState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=2 and ColumnName='State Name'
		
		---Supplier State
		SELECT DISTINCT  R.SpmId as RtrId,TinFirst2Digit+'-'+StateName as StateName
		INTO #SupplierState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Supplier R ON R.SpmId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=8 and ColumnName='State Name'
		
		---IDT Distributor State
		SELECT DISTINCT  R.SpmId as RtrId,TinFirst2Digit+'-'+StateName as StateName
		INTO #IDTSupplierState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN IDTMaster R ON R.SpmId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=8 and ColumnName='State Name'
		
		
		---Supplier GSTIN
		SELECT DISTINCT  SpmId as RtrId ,UT.ColumnValue
		INTO #SupplierGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Supplier R ON R.SpmId=UT.MasterRecordId
		WHERE U.MasterId=8 and ColumnName='GSTIN'
		
				
		---IDT Supplier GSTIN
		SELECT DISTINCT  SpmId as RtrId ,UT.ColumnValue
		INTO #IDTSupplierGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN IDTMaster R ON R.SpmId=UT.MasterRecordId
		WHERE U.MasterId=8 and ColumnName='GSTIN'
		
		---Retailer GSTIN
		SELECT DISTINCT  R.RtrId as RtrId,UT.ColumnValue INTO #RetailerGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='GSTIN'
		
		---Retailer Registered
		SELECT R.RtrId,ColumnValue	INTO #RetailerRegister
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue='Registered' 
		
		
		---Sales Data
		SELECT S.RtrId,S.RtrshipId,S.Salid,Salinvno,SalInvdate,Prdslno,OrgNetAmount,SUM(TaxPerc) as Taxperc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(TaxAmount) as TaxAmount
		INTO #Sales		
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProductTax ST (NOLOCK) ON S.Salid=ST.SalId
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST')
		and ST.TaxableAmount>0
		GROUP BY S.RtrId,S.Salid,Salinvno,SalInvdate,Prdslno,S.RtrshipId,OrgNetAmount

		SELECT S.SalId,S.Rtrid,SUM(PrdNetAmount)PrdNetAmount INTO #SalesNetValue FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SI (NOLOCK) ON S.Salid=SI.SalId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		GROUP BY S.SalId,S.Rtrid

		UPDATE S SET OrgNetAmount=PrdNetAmount FROM #Sales S INNER JOIN #SalesNetValue SI ON S.Salid=SI.Salid
		
		--IDT Sales Data
		SELECT ToSpmId,I.IDTMngRefNo,IDTMngDate,PrdSlNo,IDTNetAmt,SUM(TaxPerc) as TaxPerc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(TaxAmount) as TaxAmount
		INTO #IDTSales
		FROM IDTManagement I (NOLOCK) 
		INNER JOIN IDTManagementProductTax IT (NOLOCK) ON I.IDTMngRefNo=IT.IDTMngRefNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=IT.TaxId
		WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear
		and StkMgmtTypeId=2 and IT.TaxableAmount>0
		GROUP BY ToSpmId,I.IDTMngRefNo,IDTMngDate,PrdSlNo,IDTNetAmt
		
		---Purchase Return Supply Data
		SELECT SpmId,I.PurRetId,I.PurRetRefNo,PurRetDate,PrdSlNo,NetAmount,SUM(IT.TaxPerc) as TaxPerc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(IT.TaxAmount) as TaxAmount
		INTO #PurchaseReturn
		FROM PurchaseReturn I (NOLOCK) 
		INNER JOIN PurchaseReturnProductTax IT (NOLOCK) ON I.PurRetId=IT.PurRetId
		INNER JOIN #Purchareceipt R ON R.PurRcptId=I.PurRcptId
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=IT.TaxId
		WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
		and IT.TaxableAmount>0
		GROUP BY SpmId,I.PurRetRefNo,PurRetDate,PrdSlNo,I.PurRetId,NetAmount
		
		SELECT  S.ServiceToId,S.ServiceInvId as Salid,ServiceInvRefNo as Salinvno,ServiceInvDate as SalInvdate,
		RowNo,AppTotalAmount,SUM(TaxPerc) as Taxperc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(TaxAmount) as TaxAmount
		INTO #ServiceData
		FROM ServiceInvoiceHd S (NOLOCK) 
		INNER JOIN ServiceInvoiceTaxDetails SI (NOLOCK)
		ON S.ServiceInvId=SI.ServiceInvId
		WHERE ServiceInvFor=2 and  Month(ServiceInvDate)=@MonthStart and Year(ServiceInvDate)=@Jcmyear
		and SI.TaxableAmount>0
		GROUP BY S.ServiceToId,S.ServiceInvId,ServiceInvRefNo,ServiceInvDate,RowNo,AppTotalAmount
		
		-----Service
		--SELECT UniqueId,Proforma_Invoice_No ,Proforma_Invoice_Date ,
		--SUM(ISNULL(DocAmount+tax_Amount,0))ApprovedAmt ,SUM(CGST_Per+SGST_Per+IGST_Per+UTGST_Per) as Taxperc,
		--SUM(ISNULL(DocAmount,0)) as TaxableAmount,SUM(ISNULL(tax_Amount,0)) as TaxAmount,CGST_Per,SGST_Per,IGST_Per,UTGST_Per,
		--CGST_Amt,SGST_Amt,IGST_Amt,UTGST_Amt
		--INTO #ServiceData
		--FROM ClaimAcknowledgement WHERE ClaimType IN('Project1 Claim','Other Claim','Manual Claim',
		--'VAT Claim','Incentive Claim','ROI Subsidy Claim','VD ManPower Cost Claim','VD Subsidy Claim','OTHER SERVICE CLAIM')
		--and CAST(ClaimMonth as INT)=@MonthStart and ClaimYear=@Jcmyear 
		--and LEN(ISNULL(DocNumber,''))>0 and Status='APPROVED' and LEN(ISNULL(ServiceAcCode,''))>0
		--GROUP BY UniqueId,Proforma_Invoice_No,Proforma_Invoice_Date,CGST_Per,SGST_Per,IGST_Per,UTGST_Per,CGST_Amt,SGST_Amt,IGST_Amt,UTGST_Amt
		--HAVING SUM(ISNULL(IGST_AMT,0)+ISNULL(CGST_Amt,0)+ISNULL(SGST_Amt,0)+ISNULL(UTGST_Amt,0))>0
		
		---CALCULATE TAX SPLIT 
				
			SELECT TAXID,				
			CASE	WHEN TaxCode IN('OutputIGST','IGST','InputIGST') THEN 'OutputIGST'
			WHEN TaxCode IN ('OutputCGST','CGST','InputCGST') Then 'OutputCGST'
			WHEN TaxCode IN ('OutputSGST','SGST','InputSGST') Then 'OutputSGST'
			WHEN TaxCode IN ('OutputUTGST','UTGST','InputUTGST') Then 'OutputUTGST'
			END	 as TaxCode
			INTO #TaxConfiguration
			FROM  TaxConfiguration WHERE TaxCode 
			IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST',
			'InputCGST','InputSGST','InputIGST','InputUTGST')
		SELECT * INTO #SalesInvoiceProductTax FROM SalesInvoiceProductTax 
			WHERE SalId IN (SELECT DISTINCT salid FROM #Sales) 			
				
		SELECT * INTO #IDTManagementProductTax FROM IDTManagementProductTax 
			WHERE IDTMngRefNo IN (SELECT DISTINCT IDTMngRefNo FROM #IDTSales) 
		SELECT * INTO #PurchaseReturnProductTax  FROM PurchaseReturnProductTax 
			WHERE PurRetId IN (SELECT DISTINCT PurRetId FROM #PurchaseReturn) 
			SELECT * INTO #ServiceInvoiceTaxDetails  FROM ServiceInvoiceTaxDetails 
			WHERE ServiceInvId IN (SELECT DISTINCT ServiceInvId FROM #ServiceData) 
 			
  			SELECT BTYPE,Salinvno,Prdslno,TaxCode,TaxPercAmt INTO #TAXPIVOT
			FROM
			(
			----SALES DATA
			SELECT 1 AS BTYPE,SI.Salinvno,SI.Prdslno,
			TaxCode+'Perc' AS TaxCode
			,ST.TaxPerc AS TaxPercAmt 
				FROM #Sales SI
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL
			SELECT 1 AS BTYPE,SI.Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #Sales SI
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId  AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL	
			-------IDT DETAILS	
			SELECT 2 AS BTYPE,SI.IDTMngRefNo AS Salinvno,SI.Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
				FROM #IDTSales SI
				INNER JOIN #IDTManagementProductTax ST ON ST.IDTMngRefNo=SI.IDTMngRefNo AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN (SELECT TAXID,TAXCODE FROM  #TaxConfiguration WHERE TaxCode --ADDED BY MOHANA ILCRSTLOR0379
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST')) T ON T.TaxId=ST.TaxId
			UNION ALL
			SELECT 2 AS BTYPE,SI.IDTMngRefNo  AS Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #IDTSales SI
				INNER JOIN #IDTManagementProductTax ST ON ST.IDTMngRefNo=SI.IDTMngRefNo AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN (SELECT TAXID,TAXCODE FROM  #TaxConfiguration WHERE TaxCode   --ADDED BY MOHANA ILCRSTLOR0379
				IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST')) T ON T.TaxId=ST.TaxId
			UNION ALL	
  			---PURCHASE RETURN DETAILS
				SELECT 3 AS BTYPE,SI.PurRetRefNo AS Salinvno,SI.Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
				FROM #PurchaseReturn SI
				INNER JOIN #PurchaseReturnProductTax ST ON ST.PurRetId=SI.PurRetId AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL
				SELECT 3 AS BTYPE,SI.PurRetRefNo AS Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #PurchaseReturn SI
				INNER JOIN #PurchaseReturnProductTax ST ON ST.PurRetId=SI.PurRetId AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId		
			UNION ALL	
  			---Service Invoice
				SELECT 4 AS BTYPE,SI.Salinvno AS Salinvno,SI.RowNo as Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
				FROM #ServiceData SI
				INNER JOIN #ServiceInvoiceTaxDetails ST ON ST.ServiceInvId=SI.Salid AND ST.RowNo=SI.RowNo
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL
				SELECT 4 AS BTYPE,SI.Salinvno AS Salinvno,SI.RowNo as Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #ServiceData SI
				INNER JOIN #ServiceInvoiceTaxDetails ST ON ST.ServiceInvId=SI.Salid AND ST.RowNo=SI.RowNo
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId			
  			)A
 			ORDER BY BTYPE 
 			SELECT BTYPE,Salinvno,Prdslno,SUM([OutputCGSTPerc])[OutputCGSTPerc],
				SUM([OutputCGST_Amt])[OutputCGST_Amt],SUM([OutputSGSTPerc])[OutputSGSTPerc],SUM([OutputSGST_Amt])[OutputSGST_Amt],
				SUM([OutputIGSTPerc])[OutputIGSTPerc],SUM([OutputIGST_Amt])[OutputIGST_Amt],SUM([OutputUTGSTPerc])[OutputUTGSTPerc],
				SUM([OutputUTGST_Amt])[OutputUTGST_Amt]
			INTO #TAXDETAILS
			FROM(
			SELECT BTYPE,Salinvno,Prdslno,
			ISNULL([OutputCGSTPerc],0)[OutputCGSTPerc],ISNULL([OutputCGST_Amt],0)[OutputCGST_Amt],
			ISNULL([OutputSGSTPerc],0)[OutputSGSTPerc],ISNULL([OutputSGST_Amt],0)[OutputSGST_Amt],
			ISNULL([OutputIGSTPerc],0)[OutputIGSTPerc],ISNULL([OutputIGST_Amt],0)[OutputIGST_Amt],
			ISNULL([OutputUTGSTPerc],0)[OutputUTGSTPerc],ISNULL([OutputUTGST_Amt],0)[OutputUTGST_Amt]
			FROM (
			SELECT BTYPE,Salinvno,Prdslno,TaxCode,TaxPercAmt
			FROM #TAXPIVOT) up
			PIVOT (SUM(TaxPercAmt) FOR TaxCode IN ([OutputCGST_Amt],[OutputCGSTPerc],
													[OutputSGST_Amt],[OutputSGSTPerc],
													[OutputIGST_Amt],[OutputIGSTPerc],
													[OutputUTGST_Amt],[OutputUTGSTPerc]))  AS PVT 
			)A
			GROUP BY BTYPE,Salinvno,Prdslno 		
 		INSERT INTO #RptGSTR1_B2B(TransId,TranType,Refid ,RtrShipId,RtrId,RtrCode,RtrName,
			[GSTIN/UIN of Recipient],[Retailer Type],[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],
			[Reverse Charge],[Invoice Type],[Kind of transaction],[Identifier if Goods or Services],[E-Commerce GSTIN],
			[Rate],[Taxable Value],[Cess Amount],[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],
			[SGST/UTGST amount],UsrId,[Group Name],GroupType)
		SELECT 1,'Sales',S.Salid,S.RtrShipId,R.RtrId,RtrCode,RtrName,'' as GSTTin,ISNULL(ColumnValue,'') as RetailerType,S.SalInvNo,Salinvdate, OrgNetAmount as SalesValue,'' as PlaceOfSupply,
			  'N' as ReverseCharge,'Regular' as InvoiceType,'Sale of goods' as Kind,'Goods' as Goods ,'' as [E-Commerce],Taxperc,SUM(TaxableAmount) as TaxableAmount,
			   0.00 as CessAmount,[OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			   ([OutputSGSTPerc]+[OutputUTGSTPerc]),SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM #Sales S INNER JOIN Retailer R (NOLOCK) ON R.RtrId=S.RtrId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.SalInvNo AND T.PrdSlNo=S.PrdSlNo AND T.BTYPE=1
		LEFT OUTER JOIN #RetailerRegister Rr ON Rr.RtrId=S.RtrId
		GROUP BY 
			S.Salid,R.RtrId,RtrCode,RtrName,S.Salinvno,Salinvdate,Taxperc,S.RtrShipId,OrgNetAmount,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc],ColumnValue
		UNION ALL
		SELECT 2,'IDT',0 as Salid,0 as RtrShipId,R.SpmId as RtrId,SpmCode as RtrCode,SpmName as RtrName,'' as GSTTin,'Registered' as RetailerType,
		S.IDTMngRefNo as Salinvno,IDTMngDate as Salinvdate,IDTNetAmt as SalesValue,'' as PlaceOfSupply,
		'N' as ReverseCharge,'Regular' as InvoiceType,'Sale of goods' as Kind,'Goods' as Goods ,'' as [E-Commerce],Taxperc,
		SUM(TaxableAmount) as TaxableAmount,0.00 as CessAmount,[OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			   ([OutputSGSTPerc]+[OutputUTGSTPerc]),SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM #IDTSales S INNER JOIN IDTMaster R (NOLOCK) ON R.SpmId=S.ToSpmId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.IDTMngRefNo AND T.PrdSlNo=S.PrdSlNo AND T.BTYPE=2
		GROUP BY 
			R.SpmId,SpmCode,SpmName,S.IDTMngRefNo,IDTMngDate,Taxperc,IDTNetAmt,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
		UNION ALL
		SELECT 3,'PurchaseReturn',S.PurRetId as Salid,0 as RtrShipId,R.SpmId as RtrId,SpmCode as RtrCode,
		SpmName as RtrName,'' as GSTTin,'Registered' as RetailerType,S.PurRetRefNo as Salinvno,PurRetDate as Salinvdate,NetAmount as SalesValue,
		'' as PlaceOfSupply,'N' as ReverseCharge,'Regular' as InvoiceType,'Sale of goods' as Kind,'Goods' as Goods ,
		'' as [E-Commerce],Taxperc,SUM(TaxableAmount) as TaxableAmount,0.00 as CessAmount,[OutputIGSTPerc],
		SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			   ([OutputSGSTPerc]+[OutputUTGSTPerc]),SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM #PurchaseReturn S 	INNER JOIN Supplier R (NOLOCK) ON R.SpmId=S.SpmId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.PurRetRefNo AND T.PrdSlNo=S.PrdSlNo AND T.BTYPE=3
		GROUP BY 
		R.SpmId,SpmCode,SpmName,S.PurRetRefNo,PurRetDate,Taxperc,S.PurRetId,NetAmount,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
		UNION ALL
		SELECT 4,'Service',S.Salid as Salid,0 as RtrShipId,S.ServiceToId as RtrId,SpmCode as RtrCode,
		SpmName as RtrName,'' as GSTTin,'Registered' as RetailerType,
		S.Salinvno as Salinvno,SalInvdate as Salinvdate,AppTotalAmount as SalesValue,'' as PlaceOfSupply,
		'N' as ReverseCharge,'Regular' as InvoiceType,'Sale of service' as Kind,
		'Services' as Goods,'' as [E-Commerce],Taxperc,SUM(TaxableAmount) as TaxableAmount,0.00 as CessAmount,
		[OutputIGSTPerc] as [OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc] as [OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
	   ([OutputSGSTPerc]+[OutputUTGSTPerc]) as [OutputSGSTPerc], SUM([OutputSGST_Amt]+[OutputUTGST_Amt]) AS [OutputSGST_Amt],
		@Pi_UsrId,'' as [Group Type],2
		FROM #ServiceData S INNER JOIN Supplier R (NOLOCK) ON R.SpmId=S.ServiceToId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.SalInvNo AND T.PrdSlNo=S.RowNo AND T.BTYPE=4
		GROUP BY S.ServiceToId,SpmCode,SpmName,S.Salinvno,SalInvdate,Taxperc,S.Salid,AppTotalAmount,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
		
		 
		UPDATE B Set B.[Place Of Supply]=A.StateName FROM #RetailerState A INNER JOIN #RptGSTR1_B2B B ON A.Rtrid=B.RtrId
		WHERE B.TransId=1
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=GSTTinNo FROM #RptGSTR1_B2B R INNER JOIN RetailerShipAdd RS ON RS.RtrShipId=R.RtrShipId
		and R.TransId=1
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=ColumnValue FROM #RptGSTR1_B2B R INNER JOIN #RetailerGSTIN RS ON RS.RtrId=R.RtrId
		WHERE LEN(ISNULL(R.[GSTIN/UIN of Recipient],''))=0 and R.TransId=1
		
		DELETE A FROM #RptGSTR1_B2B A WHERE NOT EXISTS(SELECT RtrId FROM #RetailerRegister B WHERE A.RtrId=B.RtrId)
		and TransId=1
		
		UPDATE B Set B.[Place Of Supply]=A.StateName FROM #SupplierState A INNER JOIN #RptGSTR1_B2B B ON A.RtrId=B.RtrId
		WHERE B.TransId IN(3,4)
	
		
		UPDATE B Set B.[Place Of Supply]=A.StateName FROM #IDTSupplierState A INNER JOIN #RptGSTR1_B2B B ON A.Rtrid=B.RtrId
		WHERE B.TransId=2
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=ColumnValue FROM #RptGSTR1_B2B R INNER JOIN #SupplierGSTIN RS ON RS.RtrId=R.RtrId
		WHERE  R.TransId IN(3,4)
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=ColumnValue FROM #RptGSTR1_B2B R INNER JOIN #IDTSupplierGSTIN RS ON RS.RtrId=R.RtrId
		WHERE  R.TransId=2
		
	 --select * from #RptGSTR1_B2B
		
		
			
		IF NOT EXISTS(SELECT 'X' FROM #RptGSTR1_B2B)
		BEGIN
			INSERT INTO RptGSTR1_B2B([GSTIN/UIN of Recipient],[Recipient Code in application],[Recipient Name],[Recipient Type]
			,[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],[Reverse Charge],[Invoice Type],[Kind of transaction],
			[Identifier if Goods or Services],[E-Commerce GSTIN],[Rate],[Taxable Value],[Cess Amount],
			[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType)
			SELECT '' as [GSTIN/UIN of Recipient],'' as [Recipient Code in application],'' as [Recipient Name],'' as[Recipient Type],
			'' as [Invoice Number],'' as [Invoice date],0,'' as [Place Of Supply],'' as [Reverse Charge],'' as [Invoice Type],'' as [Kind of transaction],	
			'' as [Identifier if Goods or Services],'' as [E-Commerce GSTIN],0.00 as [Rate],SUM([Taxable Value]),SUM([Cess Amount]),
			0 as [IGST rate],SUM([IGST amount]),0 as [CGST rate],SUM([CGST amount]),0 as [SGST/UTGST rate],SUM([SGST/UTGST amount]),
			@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
			FROM #RptGSTR1_B2B		
			SELECT * FROM RptGSTR1_B2B (NOLOCK) WHERE UsrId=@Pi_UsrId
			
			DELETE FROM RptGSTR1_B2B WHERE UsrId=@Pi_UsrId			
			
			RETURN
		END
		
		INSERT INTO RptGSTR1_B2B([GSTIN/UIN of Recipient],[Recipient Code in application],[Recipient Name],[Recipient Type]
		,[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],[Reverse Charge],[Invoice Type],[Kind of transaction],
		[Identifier if Goods or Services],[E-Commerce GSTIN],[Rate],[Taxable Value],[Cess Amount],
		[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType)		
		SELECT [GSTIN/UIN of Recipient],RtrCode,rtrname,[Retailer Type],[Invoice Number],
		REPLACE(REPLACE(CONVERT(VARCHAR,[Invoice date],106), ' ','-'), ',',''),[Invoice Value],[Place Of Supply],
		[Reverse Charge],[Invoice Type],[Kind of transaction],[Identifier if Goods or Services]	,[E-Commerce GSTIN],[Rate],[Taxable Value],
		[Cess Amount],[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType
		FROM #RptGSTR1_B2B 
		ORDER BY TransId,[GSTIN/UIN of Recipient],[Invoice date],[Invoice Number]
		
		SELECT DISTINCT TransId,[Invoice Number],[Invoice Value]
		INTO #GrandTotal
		FROM #RptGSTR1_B2B
		
		
		INSERT INTO RptGSTR1_B2B([GSTIN/UIN of Recipient],[Recipient Code in application],[Recipient Name],[Recipient Type]
		,[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],[Reverse Charge],[Invoice Type],[Kind of transaction],
		[Identifier if Goods or Services],[E-Commerce GSTIN],[Rate],[Taxable Value],[Cess Amount],
		[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType)
		SELECT '' as [GSTIN/UIN of Recipient],'' as [Recipient Code in application],'' as [Recipient Name],'' as[Recipient Type],
		'' as [Invoice Number],'' as [Invoice date],0,'' as [Place Of Supply],'' as [Reverse Charge],'' as [Invoice Type],'' as [Kind of transaction],	
		'' as [Identifier if Goods or Services],'' as [E-Commerce GSTIN],0.00 as [Rate],SUM([Taxable Value]),SUM([Cess Amount]),
		0 as [IGST rate],SUM([IGST amount]),0 as [CGST rate],SUM([CGST amount]),0 as [SGST/UTGST rate],SUM([SGST/UTGST amount]),
		@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
		FROM #RptGSTR1_B2B
		
		UPDATE RptGSTR1_B2B SET [Invoice Value]=(SELECT SUM([Invoice Value]) FROM #GrandTotal) WHERE GroupType=3
		
		
		SELECT * FROM RptGSTR1_B2B WHERE UsrId=@Pi_UsrId
				
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_Retailer_Reupload' AND xtype='P')
DROP PROCEDURE Proc_Cs2Cn_Retailer_Reupload
GO
CREATE PROCEDURE Proc_Cs2Cn_Retailer_Reupload  
 (  
  @Po_ErrNo INT OUTPUT,  
  @ServerDate DATETIME  
 )  
 AS  
 SET NOCOUNT ON  
 BEGIN  
 /*********************************  
 * PROCEDURE : Proc_Cs2Cn_Retailer 0,'2016-11-11'  
 * PURPOSE : Extract Retailer Details from CoreStocky to Console  
 * NOTES  :  
 * CREATED : Nandakumar R.G 09-01-2009  
 * MODIFIED  
 * DATE      AUTHOR     DESCRIPTION  
 ------------------------------------------------  
 * Added AutoRetailerApproval for Parle ICRSTPAR1505  
 * Added RtrFrequency,RtrPhoneNo,TinNumber,Crlimit,CrDays,Approved,RtrType by Gopi on 08/11/2016  
 * DATE         AUTHOR       CR/BZ    USER STORY ID   DESCRIPTION                           
*****************************************************************************************************  
  10/05/2018   S.Moorthi     CR        CRCRSTPAR0001   Retailer Approval process - Manual  
 *********************************/  
  DECLARE @CmpID   AS INTEGER  
  DECLARE @DistCode As nVarchar(50)  
    
  SET @Po_ErrNo=0  
  
 ----Commented by Moorthi CRCRSTPAR0001 --CHANGED BY MAHESH FOR ICRSTPAR1505  
 --IF EXISTS (SELECT * FROM RETAILER WHERE APPROVED=0)  
 --BEGIN  
 -- UPDATE RETAILER SET Approved=1 WHERE Approved=0  
 --END  
  
  --Till Here  
  --DELETE FROM Cs2Cn_Prk_Retailer WHERE UploadFlag = 'Y'  
  SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
  SELECT @DistCode = DistributorCode FROM Distributor  
  IF EXISTS (SELECT * FROM Cs2Cn_Prk_Retailer_Reupload )  
  BEGIN   
  RETURN  
  END  
  INSERT INTO Cs2Cn_Prk_Retailer_Reupload  
  (  
   DistCode ,  
   RtrId ,  
   RtrCode ,  
   CmpRtrCode,  
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
   DrugLNo,  
   RtrFrequency,  
   RtrPhoneNo,  
   RtrTINNumber,  
   RtrTaxGroupCode,  
   RtrCrLimit,  
   RtrCrDays,  
   Approved,  
   RtrType,  
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
   CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New',R.RtrDrugLicNo,  
   CASE RtrFrequency WHEN 0 THEN 'WEEKLY' WHEN 1 THEN 'BI-WEEKLY' WHEN 2 THEN 'FORT NIGHTLY' when 3 then 'MONTHLY' when 4 then 'DAILY' END AS RtrFrequency,  
   ISNULL(RtrPhoneNo,''),ISNULL(RtrTINNo,''),ISNULL(TGS.RtrGroup,''),R.RtrCrLimit,  
   R.RtrCrDays,(CASE ISNULL(R.Approved,0) WHEN 0 THEN 'PENDING' WHEN 1 THEN 'APPROVED' ELSE 'REJECTED' END) AS Approved,  
   (CASE R.RtrType WHEN 1 THEN 'Retailer' WHEN 2 THEN 'Sub Stockist' WHEN 3 THEN 'Hub' WHEN 4 THEN 'Spoke' ELSE 'Distributor' END) AS RtrType,  
   'N'       
  FROM    
   Retailer R  
   LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE  
   INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId  
   LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1  
    
  UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,ETL.RtrClassCode=RVC.ValueClassCode  
  FROM Cs2Cn_Prk_Retailer_Reupload ETL,  
  (  
   SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode ,RVC.ValueClassCode  
   FROM  
   RetailerValueClassMap RVCM ,  
   RetailerValueClass RVC ,  
   RetailerCategory RC ,  
   RetailerCategoryLevel RCL,  
   RetailerCategory RC1,  
   Retailer R      
  WHERE  
   R.Rtrid = RVCM.RtrId  
   AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND RVC.CtgMainId=RC.CtgMainId  
   AND RCL.CtgLevelId=RC.CtgLevelId  
   AND RC.CtgLinkId = RC1.CtgMainId  
  ) AS RVC  
  WHERE ETL.RtrId=RVC.RtrId  
    
  UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoLevelValue=Geo.GeoName  
  FROM Cs2Cn_Prk_Retailer_Reupload ETL,  
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
  FROM Cs2Cn_Prk_Retailer_Reupload ETL,  
  (  
   SELECT R.RtrId,R.VillageId,V.VillageCode,V.VillageName  
   FROM     
   Retailer R      
   INNER JOIN RouteVillage V ON R.VillageId=V.VillageId  
  ) V  
  WHERE ETL.RtrId=V.RtrId   
    
  ----UPDATE Retailer SET Upload='Y' WHERE Upload='N' AND CmpRtrCode IN(SELECT CmpRtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='New')  
  ----UPDATE RetailerClassficationChange SET UpLoadFlag=1 WHERE UpLoadFlag=0 AND RtrCode IN(SELECT RtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='CR')  
    
  UPDATE Cs2Cn_Prk_Retailer_Reupload SET ServerDate=@ServerDate  
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_ChainWiseBillDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Cs2Cn_ChainWiseBillDetails]
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_ChainWiseBillDetails 0,'2014-02-04'
select   * from Cs2Cn_Prk_ChainWiseBillDetails order by Billno
Rollback Transaction
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_ChainWiseBillDetails]
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_ChainWiseBillDetails 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
-----------------------------------------------
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 27-03-2018   S.MOhana     CR			CCRSTPAR0188		 Included reports changes in upload	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	CREATE TABLE #ChainSalesDetails
	(
		[SalId] [bigint] NOT NULL,
		[SalInvNo] [nvarchar](50) NOT NULL,
		[SalInvDate] [datetime] NOT NULL,
		[RtrId] [int] NOT NULL,
		[PrdId] [int] NOT NULL,
		[TotalPCS] [numeric](38, 0) NULL,
		[MRP] [numeric](18, 6) NOT NULL,
		[PriceId] [int] NOT NULL,
		[PrdBatid] [int] NOT NULL,
		[ChainLandRate] [numeric](18, 6) NULL,
		[SchemeDiscount] [numeric](18, 6) NULL
	)
	
	DECLARE @DistCode As NVARCHAR(50)
	DELETE FROM Cs2Cn_Prk_ChainWiseBillDetails WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT '' FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
			
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	and  CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A(NOLOCK) where CtgCode NOT IN ('GT'))
	
	--To Filter Retailers
	INSERT INTO #ChainSalesDetails
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SUM(SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.PrdBatid,
	CAST(0 AS NUMERIC(18,6)) ChainLandRate,SUM(SP.PrdSchDiscAmount) SchDisc
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND S.DlvSts > 3  
	GROUP BY S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.PriceId,SP.SplPriceid,SP.PrdBatid
	UNION ALL
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SUM(-1*SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.PrdBatid,
	CAST(0 AS NUMERIC(18,6)) ChainLandRate,SUM(SP.PrdSchDisAmt) SchDisc
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	WHERE  EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)
	 AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)  
	GROUP BY S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.SplPriceid,SP.PriceId,SP.PrdBatid
	
	UPDATE #ChainSalesDetails SET SchemeDiscount = abs(SchemeDiscount/TotalPCS)
	
	SELECT DISTINCT C.PrdBatid,C.Priceid,C.PrdbatDetailValue INTO #NormalPrice FROM #ChainSalesDetails A INNER JOIN Productbatch B ON A.Prdbatid=B.PrdBatid
	INNER JOIN ProductBatchDetails C ON  B.PRDBATID = C.PRDBATID AND DEFAULTPRICE = 1
	and SLNO=3	
	
	--ADDED BY MOHANA
	
	SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #ChainSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #ChainSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	
	UPDATE R SET R.ChainLandRate = S.SplSelRate-R.SchemeDiscount
	FROM #ChainSalesDetails R (NOLOCK),
	#ExistingSpecialPrice S (NOLOCK)
	WHERE R.PriceId = S.PriceId
	
	UPDATE A SET A.ChainLandRate = (B.PrdbatDetailValue-A.SchemeDiscount) FROM #ChainSalesDetails A INNER JOIN #NORMALPRICE B ON A.PRDBATID=B.PRDBATID WHERE A.ChainLandRate=0  
	
	--SELECT S.SalId,S.SalInvNo BillNo,S.SalInvDate BillDate,S.RtrId,R.RtrName,R.CmpRtrCode,P.PrdId,P.PrdName,P.PrdCCode,
	--PrdWgt PktWgt,MRP,TotalPCS QtyInPkt,PriceId,ChainLandRate,
	--CAST(0 AS NUMERIC(18,6)) Amount
	--INTO #Chain
	--FROM #ChainSalesDetails S (NOLOCK)
	--INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	--INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	
	 
	SELECT S.SalId,S.SalInvNo BillNo,CONVERT(VARCHAR(10),S.SalInvDate,121) as  BillDate,S.RtrId,R.RtrName,R.CmpRtrCode,P.PrdId,P.PrdName,P.PrdCCode,
	PrdWgt PktWgt,MRP,TotalPCS QtyInPkt,ChainLandRate, --ICRSTPAR7049
	CAST(0 AS NUMERIC(18,2)) Amount
	INTO #Chain
	FROM #ChainSalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	INNER JOIN #FilterRetailer F ON S.Rtrid = F.Rtrid AND R.Rtrid = F.Rtrid
	
	UPDATE C SET C.Amount = QtyInPkt * ChainLandRate
	FROM #Chain C (NOLOCK)
	
	--select BillNo,PrdId,QtyInPkt,ROUND(ChainLandRate,2,1),ROUND(Amount,2,1)  from #Chain order by  billno,prdid 
	
	INSERT INTO Cs2Cn_Prk_ChainWiseBillDetails (DistCode,BillNo,BillDate,CmpRtrCode,PrdCCode,PktWgt,PktMRP,QtyInPkt,
	ChainLandRate,Amount,UploadFlag,SyncId,ServerDate)
	SELECT @DistCode,BillNo,BillDate,CmpRtrCode,PrdCCode,PktWgt,MRP,sum(QtyInPkt),sum(ROUND(ChainLandRate,2,1)),sum(ROUND(Amount,2,1)),
	'N' UploadFlag,NULL,@ServerDate
	FROM #Chain (NOLOCK) 
	GROUP BY  BillNo,BillDate,CmpRtrCode,PrdCCode,PktWgt,MRP
	
	--UPDATE S SET S.RptUpload = 1
	--FROM UploadingReportTransaction U (NOLOCK),
	--SalesInvoice S (NOLOCK) WHERE U.TransType = 1 AND U.TransId = S.SalId
	--UPDATE S SET S.RptUpload = 1
	--FROM UploadingReportTransaction U (NOLOCK),
	--ReturnHeader S (NOLOCK) WHERE U.TransType = 2 AND U.TransId = S.ReturnID
	
	RETURN			
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_RptChainWiseBillDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_RptChainWiseBillDetails]
GO
--EXEC Proc_RptChainWiseBillDetails 288,2,0,'PARLE_CR',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptChainWiseBillDetails]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptChainWiseBillDetsils
* PURPOSE	: 
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
************************************************************************************************************************************
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 14-12-2017   S.Moorthi   CR			ICRSTPAR7049		1. Chain lending rate should display the net rate in billing screen
															2. Bill number column should be after the party name column 
************************************************************************************************************************************												  
 19-12-2017   S.Mohana    CR			ICRSTPAR7049		3. Added SubTotal in Excel 
************************************************************************************************************************************
 23-12-2017	  S.MOHANA	  SR			ICRSTPAR7809		1.INCLUDED SALES RETURN
															2.REMOVED TAX CALCULATION
															3.ADDED RATE-SCHEMEDISCOUNT , GRANDTOTAL
************************************************************************************************************************************
 26-03-2018	  S.MOHANA	  CR			CCRSTPAR0186		Retailer Wise Sub Total Included. 
 12-07-2018   Lakshman M  BZ            ILCRSTPAR1325       negative values validataion added from core stocky.
************************************************************************************************************************************/  
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	DECLARE @CmpId				AS  INT 
	DECLARE @CtgLevelId			AS  INT  
	DECLARE @CtgMainId			AS  INT	
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT	
	
	DECLARE @ReportType	AS INT	
	--Added By Mohana
	CREATE TABLE #Chain
	(
		[SalId] [bigint] NOT NULL,
		[BillNo] [nvarchar](50) NOT NULL,
		[BillDate] NVARCHAR(100),
		[RtrId] [int] NOT NULL,
		RtrName NVARCHAR(100),
		Ctgname NVARCHAR(100) NOT NULL,
		[PrdId] [int] NOT NULL,
		PrdName NVARCHAR(100),
		PktWgt [numeric](18, 6),
		[MRP] [numeric](18, 6) NOT NULL,
		QtyInPkt [numeric](38, 0) NULL,		
		[ChainLandRate] [numeric](18, 6) NULL,
		Amount [numeric](38, 2) NULL,
		[GrpName] NVARCHAR(100),
		[Grpid] INT
	)  
	
	
	CREATE TABLE #ChainSalesDetails
	(
		[SalId] [bigint] NOT NULL,
		[SalInvNo] [nvarchar](50) NOT NULL,
		[SalInvDate] [datetime] NOT NULL,
		[RtrId] [int] NOT NULL,
		[PrdId] [int] NOT NULL,
		[TotalPCS] [numeric](38, 0) NULL,
		[MRP] [numeric](18, 6) NOT NULL,
		[PriceId] [int] NOT NULL,
		[PrdBatid] [int] NOT NULL,
		[ChainLandRate] [numeric](18, 6) NULL,
		[SchemeDiscount] [numeric](18, 6) NULL
	)


	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	
	SET @ReportType = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,315,@Pi_UsrId))
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode,Ctgname
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)	
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId 
	and  CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A(NOLOCK) where CtgCode NOT IN ('GT'))
	AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
	RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
	RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
	RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	--To Filter Retailers
	--To Filter Products
	SELECT DISTINCT E.PrdId
	INTO #FilterProduct
	FROM ProductCategoryValue C (NOLOCK)
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
	INNER JOIN ProductCategoryLevel L (NOLOCK) ON L.CmpPrdCtgId = C.CmpPrdCtgId	
	WHERE 
	(L.CmpId=(CASE @CmpId WHEN 0 THEN L.CmpId ELSE 0 END) OR
	L.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
	
	(L.CmpPrdCtgId = (CASE @CmpPrdCtgId  WHEN 0 THEN L.CmpPrdCtgId ELSE 0 END) OR
	L.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))
	
	AND (C.PrdCtgValMainId = (CASE @PrdCtgValMainId  WHEN 0 THEN C.PrdCtgValMainId ELSE 0 END) OR 
	C.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,21, @Pi_UsrId)))
	--To Filter Products
	
	INSERT INTO #ChainSalesDetails
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SUM(SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.PrdBatid,
	--SUM(CAST(SP.PrdUom1NetRate AS NUMERIC(18,6))/Uom1ConvFact) as ChainLandRate --ICRSTPAR7049
	CAST(0 AS NUMERIC(18,6)) ChainLandRate,SUM(SP.PrdSchDiscAmount) SchDisc
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	GROUP BY S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.PriceId,SP.SplPriceid,SP.PrdBatid
	UNION ALL
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SUM(-1*SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.PrdBatid,
	--SUM(CAST(SP.PrdUom1NetRate AS NUMERIC(18,6))/Uom1ConvFact) as ChainLandRate --ICRSTPAR7049
	CAST(0 AS NUMERIC(18,6)) ChainLandRate,SUM(SP.PrdSchDisAmt) SchDisc
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	WHERE S.ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	GROUP BY S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.SplPriceid,SP.PriceId,SP.PrdBatid
	
	------------- commented By lakshman M ON 12/07/2018 PMS ID : ILCRSTPAR1325
	--UPDATE #ChainSalesDetails SET SchemeDiscount = abs(SchemeDiscount/TotalPCS)
	UPDATE #ChainSalesDetails SET SchemeDiscount =abs (SchemeDiscount/TotalPCS)
	-------------------- Till here ----------------------------
	--ICRSTPAR7049 Till Here
	--SELECT R.PriceId,C.SplSelRate 
	--INTO #ExistingSpecialPrice
	--FROM #ChainSalesDetails R (NOLOCK),
	--SpecialRateAftDownLoad_Calc C (NOLOCK)
	--WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)
	
	SELECT DISTINCT C.PrdBatid,C.Priceid,C.PrdbatDetailValue INTO #NormalPrice FROM #ChainSalesDetails A INNER JOIN Productbatch B ON A.Prdbatid=B.PrdBatid
	INNER JOIN ProductBatchDetails C ON  B.PRDBATID = C.PRDBATID AND DEFAULTPRICE = 1
	and SLNO=3	
	
	--ADDED BY MOHANA
	
	SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #ChainSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #ChainSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	

	
	UPDATE R SET R.ChainLandRate = (S.SplSelRate-R.SchemeDiscount)
	FROM #ChainSalesDetails R (NOLOCK),
	#ExistingSpecialPrice S (NOLOCK)
	WHERE R.PriceId = S.PriceId		
	--Till Here ICRSTPAR7049
	
	UPDATE A SET A.ChainLandRate = (B.PrdbatDetailValue-A.SchemeDiscount) FROM #ChainSalesDetails A INNER JOIN #NORMALPRICE B ON A.PRDBATID=B.PRDBATID WHERE A.ChainLandRate=0  

	
	INSERT INTO #Chain(SalId,BillNo,BillDate,RtrId,RtrName,Ctgname,PrdId,PrdName,PktWgt,MRP,QtyInPkt,ChainLandRate,Amount)
	SELECT S.SalId,S.SalInvNo BillNo,CONVERT(VARCHAR(10),S.SalInvDate,121) as  BillDate,S.RtrId,R.RtrName,CtgName,P.PrdId,P.PrdName,
	PrdWgt PktWgt,MRP,TotalPCS QtyInPkt,ChainLandRate, --ICRSTPAR7049
	CAST(0 AS NUMERIC(18,2)) Amount
	FROM #ChainSalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	INNER JOIN #FilterRetailer F ON S.Rtrid = F.Rtrid AND R.Rtrid = F.Rtrid
	UPDATE C SET C.Amount = QtyInPkt * ChainLandRate
	FROM #Chain C (NOLOCK)
	
	--Nagarajan on 29.08.2017 as per PMS : ICRSTPAR5917
	--SELECT S.SalId,S.RtrId,SP.PrdId,SUM(SPT.TaxAmount) TaxAmount
	--INTO #SalesInvoiceProductTax
	--FROM SalesInvoice S (NOLOCK)
	--INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	--INNER JOIN SalesInvoiceProductTax SPT (NOLOCK) ON SPT.SalId = SP.SalId AND SPT.PrdSlNo = SP.SlNo 
	--WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 AND SPT.TaxAmount > 0
	--AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	--AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	--GROUP BY S.SalId,S.RtrId,SP.PrdId
	
	--UPDATE C SET C.Amount = C.Amount + ISNULL(SPT.TaxAmount,0)
	--FROM #Chain C (NOLOCK)
	--INNER JOIN #SalesInvoiceProductTax SPT ON SPT.SalId=C.SalId AND SPT.RtrId = C.SalId AND SPT.PrdId=C.PrdId
	--WHERE C.Amount > 0
	--Till here
	-- ICRSTPAR7049 Bill No Column Change
	
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptChainWiseBillDetails_Excel')
	DROP TABLE RptChainWiseBillDetails_Excel
		 
	
	SELECT SalId,Ctgname,RtrName,BillNo,BillDate,RtrId,PrdId,PrdName,PktWgt,MRP,QtyInPkt,ROUND(ChainLandRate,2,1) ChainLandRate,ROUND(Amount,2,1) Amount,Grpid,GrpName
	INTO RptChainWiseBillDetails_Excel
	FROM #Chain (NOLOCK) Order by  Ctgname,RtrName
	
	UPDATE RptChainWiseBillDetails_Excel SET Grpname='Retailer'
	
 	SELECT  Row_numbeR() Over(Order by  Ctgname,Rtrid Asc) as Row ,Rtrid,Rtrname,Ctgname INTO #Excel  from RptChainWiseBillDetails_Excel  GROUP BY Rtrid ,Rtrname,Ctgname
 	UPDATE A SET A.Grpid = B.row from RptChainWiseBillDetails_Excel A INNER JOIN #Excel B ON A.Rtrid = B.Rtrid 
	 	
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptChainWiseBillDetails_Excel
	
	SELECT * FROM RptChainWiseBillDetails_Excel Order By Ctgname,BillNo
	
	--INSERT INTO RptChainWiseBillDetails_Excel
	--SELECT 0 SalId,'' Ctgname,'' RtrName,'TOTAL ' BillNo,'' BillDate,0 RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	--SUM(Amount) Amount,1000,CtgName  FROM RptChainWiseBillDetails_Excel	
	--group by CtgName
	--UNION  
	--SELECT 0 SalId,'' Ctgname,'' RtrName,'Grand Total ' BillNo,'' BillDate,0 RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	--SUM(Amount) Amount,10000,'zzzzzz' FROM RptChainWiseBillDetails_Excel	
 
	INSERT INTO RptChainWiseBillDetails_Excel
	SELECT 0 SalId,'' Ctgname,'' RtrName,'TOTAL ' BillNo,'' BillDate,RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	SUM(Amount) Amount,Max(Grpid),'SubTotal' FROM RptChainWiseBillDetails_Excel 
	group by RtrId
	UNION   
	SELECT 0 SalId,Ctgname,'' RtrName,'TOTAL ' BillNo,'' BillDate,0 RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	SUM(Amount) Amount,Max(Grpid),'ZSubStotal'  FROM RptChainWiseBillDetails_Excel 
	group by   Ctgname
	UNION  
	SELECT 0 SalId,'' Ctgname,'' RtrName,'Grand Total ' BillNo,'' BillDate,0 RtrId,0 PrdId, '' PrdName,0 PktWgt,0 MRP,SUM(QtyInPkt) QtyInPkt,SUM(ChainLandRate) ChainLandRate,
	SUM(Amount) Amount,1000000,'zzzzzzzzz' FROM RptChainWiseBillDetails_Excel	

	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,1,'SalId','SalId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,2,'CtgName','Category Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,3,'RtrName','Party Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,4,'BillNo','BillNo',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,5,'BillDate','BillDate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,6,'RtrId','RtrId',0,1)
 	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,7,'PrdId','PrdId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,8,'PrdName','Product Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,9,'PktWgt','Pkt Wgt',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,10,'MRP','MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,11,'QtyInPkt','Quantity in Pkts',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,12,'ChainLandRate','Chain Landing Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,13,'Amount','Amount',1,1)	
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,14,'Grpid','Grpid',0,1)	
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,15,'GrpName','GrpName',0,1)	
	RETURN
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_RailwayDiscountReconsolidation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Cs2Cn_RailwayDiscountReconsolidation]
GO
/*  
Begin transaction
truncate table Cs2Cn_Prk_RailwayDiscountReconsolidation  
update A set upload =0,rptupload =0 from salesinvoice A  where SalInvDate between '2018-03-01' and '2018-03-31'
update a set upload =0,RptUpload=0 from ReturnHeader a where returndate between '2018-03-01' and '2018-03-31'
exec Proc_Cs2Cn_RailwayDiscountReconsolidation 0,'2018-07-11'  
--select * from UploadingReportTransaction
select * from Cs2Cn_Prk_RailwayDiscountReconsolidation  for xml AUTO --where PrdCCode ='100301301079070190PKT10010N'  
Rollback Transaction  
*/  
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_RailwayDiscountReconsolidation]  
(  
@Po_ErrNo INT OUTPUT,  
@ServerDate DATETIME  
)  
AS  
/*********************************  
* PROCEDURE  : Proc_Cs2Cn_RailwayDiscountReconsolidation   
* PURPOSE  :   
* CREATED BY : Aravindh Deva C  
* CREATED DATE : 03.06.2016  
* NOTE   :  
* MODIFIED  
************************************************************************************************************************
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
27-03-2018   S.MOhana     CR			CCRSTPAR0188		 Included reports changes in upload
11-07-2018   Lakshman M   BZ            ILCRSTPAR1325       negative values division validation added from core stocky.
*********************************/  
SET NOCOUNT ON  
BEGIN  
SET @Po_ErrNo=0  
DECLARE @DistCode   As NVARCHAR(50)  
DELETE FROM Cs2Cn_Prk_RailwayDiscountReconsolidation WHERE UploadFlag = 'Y'  

TRUNCATE TABLE UploadingReportTransaction  

INSERT INTO UploadingReportTransaction (TransType,TransId,TransNo,TransDate)  
SELECT 1,SalId,SalInvNo,SalInvDate FROM SalesInvoice (NOLOCK) WHERE DlvSts > 3 AND RptUpload = 0  
UNION ALL  
SELECT 2,ReturnID,ReturnCode,ReturnDate FROM ReturnHeader (NOLOCK) WHERE Status = 0 AND RptUpload = 0  

IF NOT EXISTS (SELECT '' FROM UploadingReportTransaction (NOLOCK))  
BEGIN  
RETURN  
END  


DECLARE @FromDate DATETIME  
DECLARE @ToDate DATETIME  

SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) FROM UploadingReportTransaction (NOLOCK)  


SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)   
--To Filter Retailers  
SELECT DISTINCT R.RtrId,RC.CtgCode  
INTO #FilterRetailer  
FROM Retailer R (NOLOCK),  
RetailerValueClassMap RVCM (NOLOCK),  
RetailerValueClass RVC (NOLOCK),  
RetailerCategory RC (NOLOCK),  
RetailerCategoryLevel RCL (NOLOCK)  
WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  AND
RC.CtgLinkId NOT IN (SELECT CtgMainId FROM RetailerCategory WHERE CtgCode='GT') 



SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,  
CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdUom1EditedSelRate,(SP.PrdSchDiscAmount/SP.BaseQty) SchDisc  
INTO #BillingDetails  
FROM SalesInvoice S (NOLOCK)
INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId  
WHERE SalInvDate between @FromDate AND @ToDate 
AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)  
AND S.DlvSts > 3  

-- SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,  
--CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdEditSelRte,(SP.PrdSchDisAmt/SP.BaseQty) SchDisc  
-- INTO #ReturnDetails  
-- FROM ReturnHeader S (NOLOCK)  
-- INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1) 
-- WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)  
-- AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)  
-- AND S.[Status] = 0  


SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.SlNo,SP.PrdEditSelRte,CAST((SP.PrdSchDisAmt/SP.BaseQty)  AS NUMERIC(18,6))SchDisc
INTO #ReturnDetails
FROM ReturnHeader S (NOLOCK)
INNER JOIN SalesInvoice SI(NOLOCK) ON SI.SalId=S.SalId
INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SIP.SalId=S.SalId and SIP.SalId=SI.SalId and SIP.PrdId=SP.PrdId and SIP.PrdBatId=SP.PrdBatId
WHERE 
ReturnDate    between @FromDate AND @ToDate 
AND S.Status = 0 and S.InvoiceType=1 and S.ReturnMode=1
AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)

INSERT INTO #ReturnDetails
SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdEditSelRte,
CAST((SP.PrdSchDisAmt/SP.BaseQty)  AS NUMERIC(18,6)) SchDisc 
FROM ReturnHeader S (NOLOCK)
INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
WHERE  ReturnDate  between  @FromDate AND @ToDate  AND   S.Status = 0 --AND (ISNULL(S.InvoiceType,0)<>1 OR ISNULL(S.ReturnMode,0)<>1)
AND NOT EXISTS(SELECT * FROM #ReturnDetails R (NOLOCK) WHERE R.ReturnId=S.ReturnId)
AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)

SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,CAST(0 AS NUMERIC(18,6))[SellRate],  
CAST(0 AS NUMERIC(18,6)) IRCTCMargin,CAST(0 AS INT) [Type],CAST(0 AS NUMERIC(18,6)) AS LCTR,CAST(0 AS NUMERIC(18,6)) IRCTCRate,SchDisc
INTO #RailwaySalesDetails  
FROM   
(  
SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo,SchDisc FROM #BillingDetails  
UNION ALL  
SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo,SchDisc FROM #ReturnDetails  
) Consolidated  

DECLARE @SlNo AS INT  
SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'  
UPDATE R SET R.[SellRate] = D.PrdBatDetailValue  
FROM #RailwaySalesDetails R (NOLOCK),  
ProductBatch B (NOLOCK),  
ProductBatchDetails D (NOLOCK)  
WHERE R.PrdBatId = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo   

--SELECT R.PriceId,C.DiscountPerc,C.[TYPE],C.SplSelRate
--INTO #ExistingSpecialPrice
--FROM #RailwaySalesDetails R (NOLOCK),
--SpecialRateAftDownLoad_Calc C (NOLOCK)
--WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)

SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate,S.DiscountPerc,Type
INTO #SpecialPrice
FROM SpecialRateAftDownLoad_Calc S (NOLOCK),
#FilterRetailer R,
Product P (NOLOCK), ProductBatch B (NOLOCK)
WHERE S.RtrCtgValueCode = R.CtgCode AND
S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId


SELECT S.* 
INTO #LatesSpecialPrice
FROM #SpecialPrice S,
(
SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
FROM #SpecialPrice  
GROUP BY RtrId,PrdId,PrdBatId
) L
WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate

UPDATE R SET R.IRCTCMargin = S.DiscountPerc,R.[Type] = S.[TYPE]
FROM #RailwaySalesDetails R (NOLOCK),
#LatesSpecialPrice S (NOLOCK)
WHERE R.Prdid = S.Prdid AND R.Rtrid = S.Rtrid AND R.Prdbatid = S.Prdbatid

--UPDATE R SET R.LCTR = R.[SellRate] + (R.[SellRate]*(T.TaxPerc/100))
--FROM #RailwaySalesDetails R (NOLOCK),
--#ParleOutputTaxPercentage T (NOLOCK)
--WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno	

UPDATE R SET R.LCTR = R.[SellRate] 	FROM #RailwaySalesDetails R (NOLOCK)  

SELECT DISTINCT Priceid,PrdBatDetailValue  INTO #SpecialPrice_New FROM
(
SELECT D.PriceId,D.PrdBatDetailValue 
FROM #RailwaySalesDetails M (NOLOCK),
ProductBatchDetails D (NOLOCK) 
WHERE M.PriceId = D.PriceId AND D.SLNo = 3
AND PriceCode LIKE '%-Spl Rate-%'   
UNION 
SELECT D.PriceId,D.PrdBatDetailValue 
FROM #RailwaySalesDetails M (NOLOCK),
ProductBatchDetails D (NOLOCK) 
WHERE M.PriceId = D.PriceId AND D.SLNo = 3
AND PriceCode LIKE '%SplRate%'  
)A


UPDATE M SET M.IRCTCRATE = D.PrdBatDetailValue-SchDisc 
FROM #RailwaySalesDetails M (NOLOCK),
#SpecialPrice_New D (NOLOCK) 
WHERE M.PriceId = D.PriceId  
 
UPDATE R SET R.IRCTCRATE = R.[SellRate] - Schdisc 	FROM #RailwaySalesDetails R (NOLOCK)  WHERE IRCTCRATE=0

 
--SELECT RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,SUM(TotalPCS) TotalPCS,MRP,  
--LCTR,IRCTCMargin,CASE S.[Type] WHEN 1 THEN 'Mark Up' WHEN 2 THEN 'Mark Down' ELSE '' END MarkUpDown,  
--IRCTCRate,  CAST(0 AS NUMERIC(18,6)) TotalMRP,CAST(0 AS NUMERIC(18,6)) TotalLCTR,  
--CAST(0 AS NUMERIC(18,6)) IRCTCTotal,CAST(0 AS NUMERIC(18,6)) ClmAmount,  
--CAST(0 AS NUMERIC(18,2)) LibOnMRP,CAST(0 AS NUMERIC(18,2)) LibOnLCTR  
--INTO #RailwayDiscount  
--FROM #RailwaySalesDetails S (NOLOCK)  
--INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId   
--GROUP BY RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,MRP,LCTR,IRCTCMargin,S.[Type] ,IRCTCRate

SELECT RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,(TotalPCS) AS TotalPCS,MRP,  
LCTR,IRCTCMargin,CASE S.[Type] WHEN 1 THEN 'Mark Up' WHEN 2 THEN 'Mark Down' ELSE '' END MarkUpDown,  
IRCTCRate,  CAST(0 AS NUMERIC(18,6)) TotalMRP,CAST(0 AS NUMERIC(18,6)) TotalLCTR,  
CAST(0 AS NUMERIC(18,6)) IRCTCTotal,CAST(0 AS NUMERIC(18,6)) ClmAmount,  
CAST(0 AS NUMERIC(18,2)) LibOnMRP,CAST(0 AS NUMERIC(18,2)) LibOnLCTR  
INTO #RailwayDiscount1  
FROM #RailwaySalesDetails S (NOLOCK)  
INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId   
-- GROUP BY RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,MRP,LCTR,IRCTCMargin,S.[Type] ,IRCTCRate,TotalPCS 

--------------- added by Lakshman M on 11-07-2018 PMS ID: ILCRSTPAR1325----------
UPDATE R SET TotalMRP  = TotalPCS * MRP, 
TotalLCTR = TotalPCS * LCTR
FROM #RailwayDiscount1 R (NOLOCK)


UPDATE R SET R.IRCTCTotal = TotalPCS * IRCTCRate  
FROM #RailwayDiscount1 R (NOLOCK)  

UPDATE R SET R.ClmAmount = TotalLCTR - IRCTCTotal  
FROM #RailwayDiscount1 R (NOLOCK)  

UPDATE R SET R.LibOnMRP = (ClmAmount / TotalMRP)*100
FROM #RailwayDiscount1 R (NOLOCK)
WHERE R.TotalMRP <> 0

UPDATE R SET LibOnMRP = -1* LibOnMRP
FROM #RailwayDiscount1 R (NOLOCK) WHERE TotalPCS <0


UPDATE R SET R.LibOnLCTR = (ClmAmount / TotalLCTR)*100
FROM #RailwayDiscount1 R (NOLOCK)
WHERE R.TotalLCTR <> 0	

UPDATE R SET LibOnLCTR = -1* LibOnLCTR
FROM #RailwayDiscount1 R (NOLOCK) WHERE TotalPCS <0
------------ Till Here ---------------

INSERT INTO Cs2Cn_Prk_RailwayDiscountReconsolidation (DistCode,TransDate,CmpRtrCode,PrdCCode,TotalPCS,MRP,LCTR,IRCTCMargin,MarkUpDown,IRCTCRate,TotalMRP,TotalLCTR,IRCTCTotal,ClmAmount,LibOnMRP,  
LibOnLCTR,UploadFlag,SyncId,ServerDate)  
SELECT @DistCode,TransDate,R.CmpRtrCode,PrdCCode,sum(TotalPCS) AS TotalPCS ,MRP,LCTR,IRCTCMargin,MarkUpDown,IRCTCRate,sum(TotalMRP) AS TotalMRP,CAST ((sum(TotalLCTR))  AS NUMERIC(18,2)) TotalLCTR,CAST (ROUND(sum(IRCTCTotal),2) AS NUMERIC(18,2)) IRCTCTotal 
,CAST(sum(ClmAmount)  AS NUMERIC(18,2)) ClmAmount,CAST(sum(LibOnMRP)  AS NUMERIC(18,2)) LibOnMRP,	CAST (sum(LibOnLCTR)  AS NUMERIC(18,2)) LibOnLCTR,'N' UploadFlag,NULL,@ServerDate 
FROM #RailwayDiscount1 RD,  
Retailer R (NOLOCK)  
WHERE RD.RtrId = R.RtrId  GROUP BY TransDate,R.CmpRtrCode,PrdCCode,MRP,LCTR,IRCTCMargin,MarkUpDown,IRCTCRate
RETURN     
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_RailwayDiscountReconsolidation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_RptRailwayDiscountReconsolidation]
GO
--EXEC Proc_RptRailwayDiscountReconsolidation 288,2,0,'Parle',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptRailwayDiscountReconsolidation]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptTradePromotionReport
* PURPOSE	: To Return the Scheme Utilization Details
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
***************************************************************************************************
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 14-12-2017   S.Moorthi   CR			ICRSTPAR7049		1. IRCTC rate should display the net rate in billing screen   
 14-12-2017   S.Mohana    CR			ICRSTPAR7049	    Corrected Excel Column values.
 26-12-2017	  S.MOHANA	  SR			ICRSTPAR7809		1.Changed Column Name (IRCTC --> Chain And LCTR --> Normal rate)
															2.REMOVED TAX CALCULATION
															3.ADDED RATE-SCHEMEDISCOUNT 
 11-07-2018   Lakshman M  BZ            ILCRSTPAR1325       negative values division validation added from core stocky.															
*************************************************************************/  
BEGIN
	SET NOCOUNT ON
	
	DECLARE  @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	DECLARE @CmpId				AS  INT 
	DECLARE @CtgLevelId			AS  INT  
	DECLARE @CtgMainId			AS  INT	
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT	
	
	SELECT  @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	 
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode,RC.CtgName
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)	
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND RC.CtgLinkId NOT IN (SELECT CtgMainId FROM RetailerCategory WHERE CtgCode='GT')
	AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
	RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
	RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
	RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	--To Filter Retailers
	--To Filter Products
 
	SELECT DISTINCT E.PrdId
	INTO #FilterProduct
	FROM ProductCategoryValue C (NOLOCK)
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
	INNER JOIN ProductCategoryLevel L (NOLOCK) ON L.CmpPrdCtgId = C.CmpPrdCtgId
	
	WHERE (L.CmpId=(CASE @CmpId WHEN 0 THEN L.CmpId ELSE 0 END) OR
	L.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	 
	AND (L.CmpPrdCtgId = (CASE @CmpPrdCtgId  WHEN 0 THEN L.CmpPrdCtgId ELSE 0 END) OR
	L.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))
	
	AND (C.PrdCtgValMainId = (CASE @PrdCtgValMainId  WHEN 0 THEN C.PrdCtgValMainId ELSE 0 END) OR 
	C.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,21, @Pi_UsrId)))
	--To Filter Products
--	EXEC Proc_ReturnSalesProductTaxPercentage  @FromDate,@ToDate
	
--	SELECT * INTO #ParleOutputTaxPercentage
--	FROM ParleOutputTaxPercentage (NOLOCK)	
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdUom1EditedSelRate,CAST(CAST(SP.PrdUom1NetRate AS NUMERIC(18,4))/Uom1ConvFact AS NUMERIC(18,4)) PrdUnitNetRate,CAST((SP.PrdSchDiscAmount/SP.BaseQty)  AS NUMERIC(18,6)) SchDisc
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN  @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid,SP.SlNo,SP.PrdEditSelRte,CAST(SIP.PrdUom1NetRate AS NUMERIC(18,4))/SIP.Uom1ConvFact PrdUnitNetRate,CAST((SP.PrdSchDisAmt/SP.BaseQty)  AS NUMERIC(18,6))SchDisc
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN SalesInvoice SI(NOLOCK) ON SI.SalId=S.SalId
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SIP.SalId=S.SalId and SIP.SalId=SI.SalId and SIP.PrdId=SP.PrdId and SIP.PrdBatId=SP.PrdBatId
	WHERE ReturnDate BETWEEN  @FromDate AND @ToDate AND S.Status = 0 and S.InvoiceType=1 and S.ReturnMode=1
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	INSERT INTO #ReturnDetails
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdEditSelRte,
	CAST((PrdGrossAmt-(PrdSplDisAmt+PrdSchDisamt+PrdCDDisAmt)+PrdTaxAmt)/CAST(BaseQty AS NUMERIC(18,6)) AS NUMERIC(18,4))  AS PrdUnitNetRate,CAST((SP.PrdSchDisAmt/SP.BaseQty)  AS NUMERIC(18,6)) SchDisc 
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	WHERE ReturnDate BETWEEN  @FromDate AND @ToDate AND S.Status = 0 --AND (ISNULL(S.InvoiceType,0)<>1 OR ISNULL(S.ReturnMode,0)<>1)
	AND NOT EXISTS(SELECT * FROM #ReturnDetails R (NOLOCK) WHERE R.ReturnId=S.ReturnId)
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	
	
	--SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	--SP.PriceId,SP.SlNo,SP.PrdEditSelRte
	--INTO #ReturnDetails
	--FROM ReturnHeader S (NOLOCK)
	--INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	--WHERE ReturnDate BETWEEN  @FromDate AND @ToDate AND S.Status = 0
	--AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	--AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,PrdUnitNetRate,MRP,PriceId,SlNo,SchDisc,CAST(0 AS NUMERIC(18,6))[SellRate],
	CAST(0 AS NUMERIC(18,6)) IRCTCMargin,CAST(0 AS INT) [Type],CAST(0 AS NUMERIC(18,6)) AS LCTR,CAST(0 AS NUMERIC(18,6)) ChainRate
	INTO #RailwaySalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,PrdUnitNetRate,MRP,PriceId,SlNo,SchDisc FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,PrdUnitNetRate,MRP,PriceId,SlNo,SchDisc FROM #ReturnDetails
	
	) Consolidated
	
	DECLARE @SlNo AS INT
	
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE R SET R.[SellRate] = D.PrdBatDetailValue
	FROM #RailwaySalesDetails R (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE R.PrdBatId = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	
	--SELECT R.PriceId,C.DiscountPerc,C.[TYPE],C.SplSelRate
	--INTO #ExistingSpecialPrice
	--FROM #RailwaySalesDetails R (NOLOCK),
	--SpecialRateAftDownLoad_Calc C (NOLOCK)
	--WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)
	
	
	SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate,S.DiscountPerc,Type
	INTO #SpecialPrice
	FROM SpecialRateAftDownLoad_Calc S (NOLOCK),
	#FilterRetailer R,
	Product P (NOLOCK), ProductBatch B (NOLOCK)
	WHERE S.RtrCtgValueCode = R.CtgCode AND
	S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId
	AND EXISTS (SELECT 'C' FROM #FilterProduct N (NOLOCK) WHERE P.PrdId = N.Prdid)	
	
	SELECT S.* 
	INTO #LatesSpecialPrice
	FROM #SpecialPrice S,
	(
		SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
		FROM #SpecialPrice  WHERE Prdid in (SELECT PrdId FROM #FilterProduct)
		GROUP BY RtrId,PrdId,PrdBatId
	) L
	WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate
	
	UPDATE R SET R.IRCTCMargin = S.DiscountPerc,R.[Type] = S.[TYPE]
	FROM #RailwaySalesDetails R (NOLOCK),
	#LatesSpecialPrice S (NOLOCK)
	WHERE R.Prdid = S.Prdid AND R.Rtrid = S.Rtrid AND R.Prdbatid = S.Prdbatid

	--UPDATE R SET R.LCTR = R.[SellRate] + (R.[SellRate]*(T.TaxPerc/100))
	--FROM #RailwaySalesDetails R (NOLOCK),
	--#ParleOutputTaxPercentage T (NOLOCK)
	--WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno	
	
	
	UPDATE R SET R.LCTR = R.[SellRate] 	FROM #RailwaySalesDetails R (NOLOCK)  
		
	--UPDATE R SET R.ChainRate = SplSelRate-SchDisc 	FROM #RailwaySalesDetails R (NOLOCK) INNER JOIN #LatesSpecialPrice S (NOLOCK)
	--ON R.Prdid = S.Prdid AND R.Rtrid = S.Rtrid AND R.Prdbatid = S.Prdbatid
	
	SELECT DISTINCT Priceid,PrdBatDetailValue  INTO #SpecialPrice_New FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #RailwaySalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #RailwaySalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	UPDATE M SET M.ChainRate = D.PrdBatDetailValue-SchDisc 
	FROM #RailwaySalesDetails M (NOLOCK),
	#SpecialPrice_New D (NOLOCK) 
	WHERE M.PriceId = D.PriceId  
	 
	 
	 
	UPDATE R SET R.ChainRate = (R.[SellRate]-SchDisc) --ROUND((R.[SellRate]-SchDisc),2,1) 
	FROM #RailwaySalesDetails R (NOLOCK)  WHERE ChainRate=0
	 	

	--SELECT RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,SUM(TotalPCS) TotalPCS,MRP,
	
	--SELECT Ctgname,P.PrdId,P.PrdName,SUM(TotalPCS) TotalPCS,PrdUnitNetRate,MRP,
	--LCTR As NormalRate,IRCTCMargin,CASE S.[Type] WHEN 1 THEN 'Mark Up' WHEN 2 THEN 'Mark Down' ELSE '' END MarkUpDown,
	--ChainRate,
	--CAST(0 AS NUMERIC(18,6)) TotalMRP,CAST(0 AS NUMERIC(18,6)) TotalLCTR,
	--CAST(0 AS NUMERIC(18,6)) IRCTCTotal,CAST(0 AS NUMERIC(18,6)) ClmAmount,
	--CAST(0 AS NUMERIC(18,6)) LibOnMRP,CAST(0 AS NUMERIC(18,6)) LibOnLCTR
	--INTO #RailwayDiscount
	--FROM #RailwaySalesDetails S (NOLOCK)
	--INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	--INNER JOIN #FilterRetailer F ON F.Rtrid = S.Rtrid
	--GROUP BY Ctgname,P.PrdId,P.PrdName,MRP,LCTR,IRCTCMargin,S.[Type],PrdUnitNetRate,ChainRate
		
	-----

	SELECT Ctgname,P.PrdId,P.PrdName,(TotalPCS) TotalPCS,PrdUnitNetRate,MRP,
	LCTR As NormalRate,IRCTCMargin,CASE S.[Type] WHEN 1 THEN 'Mark Up' WHEN 2 THEN 'Mark Down' ELSE '' END MarkUpDown,
	ChainRate,
	CAST(0 AS NUMERIC(18,6)) TotalMRP,CAST(0 AS NUMERIC(18,6)) TotalLCTR,
	CAST(0 AS NUMERIC(18,6)) IRCTCTotal,CAST(0 AS NUMERIC(18,6)) ClmAmount,
	CAST(0 AS NUMERIC(18,6)) LibOnMRP,CAST(0 AS NUMERIC(18,6)) LibOnLCTR
	INTO #RailwayDiscount1
	FROM #RailwaySalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN #FilterRetailer F ON F.Rtrid = S.Rtrid
	-----
	--UPDATE R SET R.IRCTCRate = MRP - (MRP * IRCTCMargin / 100.00), 
	--UPDATE R SET R.IRCTCRate = PrdUnitNetRate, 
	UPDATE R SET TotalMRP  = TotalPCS * MRP, 
	TotalLCTR = TotalPCS * NormalRate
	FROM #RailwayDiscount1 R (NOLOCK)
	--------------- added by Lakshman M on 11-07-2018 PMS ID: ILCRSTPAR1325----------
	
	UPDATE R SET R.IRCTCTotal = TotalPCS * ChainRate
	FROM #RailwayDiscount1 R (NOLOCK)
	 
	
	UPDATE R SET R.ClmAmount = ROUND((TotalLCTR - IRCTCTotal),2)
	FROM #RailwayDiscount1 R (NOLOCK)
	
	UPDATE R SET R.LibOnMRP = (ClmAmount / TotalMRP)*100
	FROM #RailwayDiscount1 R (NOLOCK)
	WHERE R.TotalMRP <> 0
	
	UPDATE R SET LibOnMRP = -1* LibOnMRP
	FROM #RailwayDiscount1 R (NOLOCK) WHERE TotalPCS <0
	
	UPDATE R SET R.LibOnLCTR = (ClmAmount / TotalLCTR)*100
	FROM #RailwayDiscount1 R (NOLOCK)
	WHERE R.TotalLCTR <> 0	
	
	UPDATE R SET LibOnLCTR = -1* LibOnLCTR
	FROM #RailwayDiscount1 R (NOLOCK) WHERE TotalPCS <0
	 
------------ Till Here ---------------

	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptRailwayDiscountReconsolidation_Excel')
	DROP TABLE RptRailwayDiscountReconsolidation_Excel	
	
	SELECT Ctgname,PrdId,PrdName,SUM(TotalPCS) TotalPCS,PrdUnitNetRate,MRP,CAST(NormalRate  AS NUMERIC(18,2)) NormalRate,IRCTCMargin As ChainMargin,MarkUpDown,CAST (sum(ChainRate)  AS NUMERIC(18,2)) ChainRate,
	SUM(TotalMRP) TotalMRP,CAST (SUM(TotalLCTR)  AS NUMERIC(18,2)) TotalLCTR,CAST ((ROUND(SUM(IRCTCTotal),2)) AS NUMERIC(18,2)) IRCTCTotal 
	,CAST(SUM(ClmAmount)  AS NUMERIC(18,2)) ClmAmount,CAST(SUM(LibOnMRP)  AS NUMERIC(18,2)) LibOnMRP,	CAST (SUM(LibOnLCTR)  AS NUMERIC(18,2)) LibOnLCTR
	INTO RptRailwayDiscountReconsolidation_Excel
	FROM #RailwayDiscount1 (NOLOCK) 
	GROUP BY Ctgname,PrdId,PrdName,PrdUnitNetRate,MRP,NormalRate,IRCTCMargin,ChainRate,MarkUpDown 
	ORDER BY PrdName
	
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptRailwayDiscountReconsolidation_Excel
	
	SELECT * FROM RptRailwayDiscountReconsolidation_Excel ORDER BY PrdName,MarkUpDown
	DELETE FROM RptExcelHeaders WHERE RptId = 288
	
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,1,'CtgName','Category Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,2,'PrdId','PrdId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,3,'PrdName','Product Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,4,'TotalPCS','Total PCS',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,5,'PrdUnitNetrate','PrdUnitNetrate',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,6,'MRP','MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,7,'Normal Rate','Normal Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,8,'IRCTCMargin','Chain Margin',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,9,'MarkUpDown','MarkUp /Mark Down',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,10,'Chain Rate','Chain Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,11,'TotalMRP','Parle Total MRP Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,12,'TotalLCTR','Parle Total Normal Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,13,'IRCTCTotal','Chain Total Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,14,'ClmAmount','Claim Amount',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,15,'LibOnMRP','% Lib On MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,16,'LibOnLCTR','% Lib On Total NormalRate',1,1)
	RETURN	
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_MTDebitSummary_New]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Cs2Cn_MTDebitSummary_New]
GO
 /*
BEGIN TRAN
Update A SET  upload = 0,rptupload = 0 from salesinvoice A where salinvdate between '2018-03-01' and '2018-03-31'
Update A SET  upload = 0,rptupload = 0 from returnheader A where returndate between '2018-03-01' and '2018-03-31'
exec Proc_Cs2Cn_RailwayDiscountReconsolidation 0,'2018-07-10'
EXEC Proc_Cs2Cn_MTDebitSummary_New 0,'2018-07-10'
SELECT * FROM Cs2Cn_Prk_MTDebitSummary where cmprtrcode in(210331400020,210331700162)
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_MTDebitSummary_New]
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_MTDebitSummary 
* PURPOSE		: Proc_Cs2Cn_MTDebitSummary (Create for report changes
* CREATED BY	: MOHANA --CCRSTPAR0188
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
------------------------------------------------
* DATE        AUTHOR      CR/BZ			USER STORY ID       DESCRIPTION   
 02-07-2018   M Lakshman   BZ			ILCRSTPAR1233		Upload flag include in MTDebit summary process.
 10-07-2018   M Lakshman   BZ           ILCRSTPAR1325       sales return logice included from core stocky.
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)
	DELETE FROM Cs2Cn_Prk_MTDebitSummary WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT * FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)	
	WHERE 
	R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId AND
	RC.CTGCODE IN (SELECT CtgCode FROM RetailerCategory A 
	WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A(NOLOCK) where CtgCode NOT IN ('GT')))
	
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
	
	SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) 
	FROM UploadingReportTransaction (NOLOCK)
	
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid ,SP.SlNo,SP.PrdUom1EditedSelRate,B.DefaultPriceId,
	Cast((SP.PrdSchDiscAmount/SP.BaseQty)AS NUMERIC(18,6)) Schdisc
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE S.DlvSts > 3 AND S.SalInvDate BETWEEN @FromDate AND @ToDate
	--AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdEditSelRte,B.DefaultPriceId,
	Cast((SP.PrdSchDisAmt/Sp.BaseQty) AS NUMERIC(18,6)) RtnSchdisc
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND  SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE S.Status = 0 AND S.ReturnDate BETWEEN @FromDate AND @ToDate
	--AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)

	SELECT Salid,RTRid,Schid,PrdId INTO #SalScheme FROM (
	Select Distinct SI.Salid,RTRid,Schid,PrdId from Salesinvoice SI(NOLOCK) INNER JOIN SalesInvoiceSchemeLineWise SH(NOLOCK) ON SI.Salid=SH.Salid
	WHERE Salinvdate between @FromDate AND @ToDate and Dlvsts in (4,5)
	UNION 
	Select Distinct SI.Salid,RTRid,SH.Schid,SIB.prdid from Salesinvoice SI(NOLOCK) INNER JOIN SalesInvoiceSchemeDtFreePrd SH(NOLOCK) ON SI.Salid=SH.Salid
	INNER JOIN SalesInvoiceSchemeDtBilled SIB (NOLOCK) ON SIB.SalId =Si.SalId
	WHERE Salinvdate between @FromDate AND @ToDate and Dlvsts in (4,5)
	)A
	
	SELECT ReturnId,RTRid,Schid,PrdId INTO #RtnScheme FROM (
	Select Distinct A.Returnid,RTRid,Schid,PrdId FROM ReturnSchemeLineDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	WHERE ReturnDate between @FromDate AND @ToDate and B.Status = 0  
	UNION
	Select Distinct A.Returnid,RTRid,Schid,0 As Prdid FROM ReturnSchemeFreePrdDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	WHERE ReturnDate between @FromDate AND @ToDate and B.Status = 0  
	)A
	--------------- Till Here --------------
 	SELECT Salid,RTRid, Schid,A.Prdid INTO #SalSchemeProducts FROM
	 (
		SELECT DISTINCT Salid,RTRid,A.Schid,B.Prdid FROM #SalScheme A(NOLOCK)
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN Product C(NOLOCK) On B.Prdid = C.PrdId
		INNER JOIN Schememaster SM (Nolock) ON SM.schid =B.schid WHERE SM.Claimable =1 AND A.PrdId =C.PrdId  --- Added By Lakshman  M on 21/06/2018 PMS ID:ILCRSTPAR1100
		UNION
		SELECT DISTINCT Salid,RTRid,A.Schid, E.Prdid FROM #SalScheme A(NOLOCK)
		INNER JOIN SchemeProducts B (NOLOCK)ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C (NOLOCK) ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D(NOLOCK) ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E(NOLOCK) On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F(NOLOCK) On
		F.PrdId = E.Prdid
		INNER JOIN Schememaster SM (Nolock) ON SM.schid =B.schid WHERE SM.Claimable =1 AND A.PrdId =E.PrdId --- Added By Lakshman  M on 21/06/2018 PMS ID:ILCRSTPAR1100
	)A --INNER JOIN #FilterProduct B ON A.PrdId = B.Prdid 
	
	 	SELECT DISTINCT ReturnId,RTRid,Schid,A.Prdid INTO #RtnSchemeProducts FROM
		(
		SELECT DISTINCT ReturnId,RTRid,A.Schid, B.Prdid FROM #RtnScheme A
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN Product C(NOLOCK) On B.Prdid = C.PrdId
		INNER JOIN Schememaster SM (Nolock) ON SM.schid =B.schid WHERE SM.Claimable =1 --- Added By Lakshman  M on 21/06/2018 PMS ID:ILCRSTPAR1100
		UNION
		SELECT DISTINCT ReturnId,RTRid,A.Schid, E.Prdid FROM #RtnScheme A
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C(NOLOCK) ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D(NOLOCK) ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E(NOLOCK) On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F(NOLOCK) On
		F.PrdId = E.Prdid
		INNER JOIN Schememaster SM (Nolock) ON SM.schid =B.schid WHERE SM.Claimable =1 AND A.PrdId =E.PrdId--- Added By Lakshman  M on 21/06/2018 PMS ID:ILCRSTPAR1100
	)A --INNER JOIN #FilterProduct B ON A.PrdId = B.Prdid 
	
	------------- Added By Lakshman M On 22/06/2018 PMS ID: ILCRSTPAR1100
	INSERT INTO #RtnSchemeProducts(ReturnId,RTRid,SchId,PrdId)
	SELECT ReturnId,RTRid,B.Schid,C.PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN Product C ON c.PrdCCode = A.FromValue
	INNER JOIN #RtnScheme RS (NOLOCK) ON RS.SchId =B.SchId 
	WHERE ChangeType='Remove' AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0)
	------------- PMS ID: ILCRSTPAR1325 ------------
	INSERT INTO #SalSchemeProducts(SalId ,RTRid,SchId,PrdId)
	SELECT salid,RTRid,B.Schid,C.PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN Product C ON c.PrdCCode = A.FromValue
	INNER JOIN #SalScheme RS (NOLOCK) ON RS.SchId =B.SchId 
	WHERE ChangeType='Remove' AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0)
    ---------------- Till Here --------------
	INSERT INTO #RtnSchemeProducts(ReturnId,RTRid,SchId,PrdId)		
	SELECT DISTINCT RS.ReturnID,RS.RtrId ,A.SchId,E.Prdid
	FROM SchemeMaster A
	INNER JOIN SchemeMasterControlHistory B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN ProductCategoryValue C ON 
	B.FromValue = C.PrdCtgValCode
	INNER JOIN ProductCategoryValue D ON
	D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
	INNER JOIN Product E On
	D.PrdCtgValMainId = E.PrdCtgValMainId 
	INNER JOIN ProductBatch F On
	F.PrdId = E.Prdid
	INNER JOIN #RtnScheme RS (NOLOCK) ON RS.SchId =A.SchId 
	WHERE A.SchemeLvlMode = 0  AND A.SchId in (SELECT SchId FROM SchemeProducts Where PrdId = 0 )
	AND ChangeType='Remove'
	------------ Till Here ----------------------
	
	SELECT DISTINCT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],DefaultPriceId,SchDisc,Type,
	CAST(0 AS NUMERIC(18,6))[ActualSellRate],CAST(0 AS NUMERIC(18,6))[SpecialSellRate],
	CAST(0 AS NUMERIC(18,6)) NrmlLCTR, CAST(0 AS NUMERIC(18,6)) NrmlSecSalesTOT, CAST(0 AS NUMERIC(18,6)) TOTDifClms
	, CAST(0 AS NUMERIC(18,6)) OfferLCTR, CAST(0 AS NUMERIC(18,6)) OffSecSalesTOT, CAST(0 AS NUMERIC(18,6)) TotOffSalesChain,
	 CAST(0 AS NUMERIC(18,6)) OffClmDiff
	INTO #MTSalesDetails
	FROM 
	(
	SELECT DISTINCT 1 TransType,A.RtrId,A.SalId,SalInvDate TransDate,A.PrdId,A.PrdBatId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate],DefaultPriceId,
	SchDisc,CASE ISNULL(B.Salid,0) WHEN 0 THEN 'NS' ELSE 'S' END AS Type
	FROM #BillingDetails A(NOLOCK)
	LEFT OUTER JOIN #SalSchemeProducts B(NOLOCK) ON A.Salid = B.salid AND A.Prdid=B.Prdid AND A.Rtrid =B.Rtrid
	UNION ALL
	SELECT  DISTINCT 2 TransType,A.RtrId,A.ReturnID,ReturnDate TransDate,A.PrdId,A.PrdBatId, BaseQty,MRP,PriceId,SlNo,PrdEditSelRte,DefaultPriceId,
	RtnSchDisc,CASE ISNULL(B.ReturnID,0) WHEN 0 THEN 'NS' ELSE 'S' END AS Type
	FROM #ReturnDetails A(NOLOCK)
	LEFT OUTER JOIN #RtnSchemeProducts B(NOLOCK) ON A.Returnid = B.Returnid AND A.Prdid=B.Prdid AND A.Rtrid =B.Rtrid
	) A
		
	DECLARE @SlNo AS INT
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'

UPDATE A SET ActualSellRate = C.PrdBatDetailValue FROM #MTSalesDetails A INNER JOIN ProductBatch B ON A.Prdid = B.PrdId AND A.Prdbatid = B.PrdBatId
	INNER JOIN 	ProductBatchDetails C ON B.DefaultPriceid = C.PriceId  AND C.SLNo = @SlNo
	
	 


	SELECT DISTINCT Priceid,PrdBatDetailValue  INTO #SpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = @SlNo
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = @SlNo
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	UPDATE M SET M.[SpecialSellRate] = D.PrdBatDetailValue
	FROM #MTSalesDetails M (NOLOCK),
	#SpecialPrice D (NOLOCK) 
	WHERE M.PriceId = D.PriceId  
	
	
	--Non Scheme
	UPDATE A SET NrmlLCTR = TotalPcs*ActualSellrate FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
		
	UPDATE A SET NrmlSecSalesTot = ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*ActualSellrate) ELSE (TotalPcs*SpecialSellRate) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
	
	UPDATE A SET TotDifClms  = NrmlLCTR-NrmlSecSalesTot FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'

	--Scheme
	
	UPDATE A SET OfferLCTR = TotalPcs*ActualSellrate FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
		
	UPDATE A SET OffSecSalesTOT = ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*ActualSellrate) ELSE (TotalPcs*SpecialSellRate) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
	
	UPDATE A SET TotOffSalesChain =  ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*(ActualSellrate-SchDisc)) ELSE (TotalPcs*(SpecialSellRate-SchDisc)) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
	UPDATE A SET OffClmDiff = OfferLCTR-TotOffSalesChain FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'

	SELECT D.RtrId,TransDate,SUM(NrmlLCTR) NrmlLCTR,SUM(NrmlSecSalesTOT) NrmlSecSalesTOT,SUM(TOTDifClms) TOTDifClms,SUM(OfferLCTR) OfferLCTR,
	SUM(OffSecSalesTOT) OffSecSalesTOT,	SUM(OffClmDiff) OffClmDiff,SUM(TotOffSalesChain) TotOffSalesChain,	CAST(0 AS NUMERIC(18,6)) LIABNormalSale,
	CAST(0 AS NUMERIC(18,6)) OffLIABValue,CAST(0 AS NUMERIC(18,6)) TotalSales,CAST(0 AS NUMERIC(18,6)) LIABOffClmWITHOUTTOT,
	CAST(0 AS NUMERIC(18,6)) LIABOffClmTotalSale,CAST(0 AS NUMERIC(18,6)) GrandTotClm,
	CAST(0 AS NUMERIC(18,6)) TOTALLIAB ,CAST(0 AS NUMERIC(18,6)) TotSalTOChain,CAST(0 AS NUMERIC(18,6)) OffLIABTtotalSales,CAST(0 AS NUMERIC(18,6)) TOTLiabTotal
	INTO #MTFinal
	FROM #MTSalesDetails D (NOLOCK) INNER JOIN #FilterRetailer B ON D.Rtrid = B.Rtrid 
	GROUP BY  D.RtrId,TransDate
	
	UPDATE A SET LIABNormalSale = (TotDifClms/NrmlLCTR)*100  FROM #MTFinal A(NOLOCK)  WHERE NrmlLCTR>0

	UPDATE A SET OffLiabvalue = OffSecSalesTOT-TotOffSalesChain  FROM #MTFinal A(NOLOCK) 
	 
	UPDATE A SET TotalSales = OfferLCTR+NrmlLCTR FROM #MTFinal A(NOLOCK) 
		
	UPDATE A SET LIABOffClmWITHOUTTOT = (OffLiabvalue/OfferLCTR)*100 FROM #MTFinal A(NOLOCK) WHERE OfferLCTR>0
	
	UPDATE A SET LIABOffClmTotalSale  = (OffClmDiff/OfferLCTR)*100  FROM #MTFinal A(NOLOCK)     WHERE OfferLCTR>0
		
	UPDATE A SET GrandTotClm  = 	(OffClmDiff+TotDifClms)   FROM #MTFinal A(NOLOCK) 
		
	UPDATE A SET TOTALLIAB  = 	(GrandTotClm/TotalSales)*100   FROM #MTFinal A(NOLOCK) WHERE [TotalSales] > 0	
	
	UPDATE A SET TotsaltoChain  = NrmlSecsalesTOT+ TotOffSalesChain    FROM #MTFinal A(NOLOCK) 	
	
	UPDATE A SET OffLIABTtotalSales  = 	(OffLIABValue/TotalSales)*100   FROM #MTFinal A(NOLOCK) WHERE [TotalSales] > 0
	
	UPDATE A SET TOTLiabTotal  = 	((GrandTotClm-OffLIABValue)/TotalSales)*100   FROM #MTFinal A(NOLOCK)  WHERE [TotalSales] > 0
	

	INSERT INTO Cs2Cn_Prk_MTDebitSummary(dISTcODE,TransDate,CmpRtrCode,TotalLCTR,SalesTOT,ClaimDiff,LiabSales,TotalOffLCTR,OffTOT,
	TotalOff,OffClaimDiff,LiabOff,TotalSales,TotSalTOChain,GrandTotClm,LiabWOTOT,LiabTOT,OffLIABTtotalSales,TOTLiabTotal,TotalLiab,UploadFlag ---- Added By Lakshman M PMS ID: ILCRSTPAR1233
	)
	SELECT @DistCode,TransDate,B.CmpRtrCode,NrmlLCTR AS NrmlLCTR,NrmlSecSalesTOT AS NrmlSecSalesTOT,ROUND(TOTDifClms,2,1) TOTDifClms,
	ROUND(LIABNormalSale,2,1) LIABNormalSale,	ROUND(OfferLCTR,2,1) OfferLCTR,ROUND(OffSecSalesTOT,2,1) OffSecSalesTOT,
	ROUND(TotOffSalesChain,2,1) TotOffSalesChain,ROUND(OffClmDiff,2,1) OffClmDiff,
	ROUND(OffLIABValue,2,1) OffLIABValue,ROUND(TotalSales,2,1) TotalSales,ROUND(TotSalTOChain,2,1) TotSalTOChain,ROUND(GrandTotClm,2,1) GrandTotClm,
	ROUND(LIABOffClmWITHOUTTOT,2,1) LIABOffClmWITHOUTTOT,ROUND(LIABOffClmTotalSale,2,1) LIABOffClmTotalSale,ROUND(OffLIABTtotalSales,2,1) OffLIABTtotalSales,
	ROUND(TOTLiabTotal,2,1) TOTLiabTotal,ROUND(TOTALLIAB,2,1) TOTALLIAB,'N'
	FROM #MTFinal A
	INNER JOIN Retailer B ON A.Rtrid  = B.RtrId
	--INNER JOIN Product C ON A.Prdid = C.Prdid 
	
	UPDATE Cs2Cn_Prk_MTDebitSummary SET ServerDate=@ServerDate  --- Added By Lakshman M PMS ID: ILCRSTPAR1233	
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_MTDebitSummary_New]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_RptMTDebitSummary]
GO
--EXEC Proc_RptMTDebitSummary 288,3,0,'',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptMTDebitSummary]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptTradePromotionReport
* PURPOSE	: To Return the Trade Promotion Report 
* CREATED	: Mohana -- ICRSTPAR7809
* CREATED DATE	: 28-02-2018 
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
* DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
21-06-2018  Lakshman M   BZ     ILCRSTPAR1100         Return stock type validation added in core stocky 
22-06-2018  Lakshman M   BZ     ILCRSTPAR1100         scheme master control history change type remove validation added In CS.
26-06-2018  Lakshman M   BZ     ILCRSTPAR1151         scheme products taken form sales details
***************************************************************************************************/  
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	DECLARE @CmpId				AS  INT 
	DECLARE @CtgLevelId			AS  INT  
	DECLARE @CtgMainId			AS  INT	
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT	
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE 
	R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId AND
	RC.CTGCODE IN (SELECT CtgCode FROM RetailerCategory A 
	WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory A(NOLOCK) where CtgCode NOT IN ('GT')))
	AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
	RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
	RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
	RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	--To Filter Retailers
	
	--To Filter Products
	SELECT DISTINCT E.PrdId,E.PrdType
	INTO #FilterProduct
	FROM ProductCategoryValue C (NOLOCK)
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
	INNER JOIN ProductCategoryLevel L (NOLOCK) ON L.CmpPrdCtgId = C.CmpPrdCtgId
	WHERE 	
	(L.CmpId=(CASE @CmpId WHEN 0 THEN L.CmpId ELSE 0 END) OR
	L.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))	AND 
	(L.CmpPrdCtgId = (CASE @CmpPrdCtgId  WHEN 0 THEN L.CmpPrdCtgId ELSE 0 END) OR
	L.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))
	AND (C.PrdCtgValMainId = (CASE @PrdCtgValMainId  WHEN 0 THEN C.PrdCtgValMainId ELSE 0 END) OR 
	C.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,21, @Pi_UsrId)))
	--To Filter Products
	

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS Priceid ,SP.SlNo,SP.PrdUom1EditedSelRate,B.DefaultPriceId,Cast((SP.PrdSchDiscAmount/SP.BaseQty)AS NUMERIC(18,6)) Schdisc
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	CASE SP.SplPriceid WHEN 0 THEN 0 ELSE  SP.Priceid END AS  Priceid,SP.SlNo,SP.PrdEditSelRte,B.DefaultPriceId,Cast((SP.PrdSchDisAmt/Sp.BaseQty) AS NUMERIC(18,6)) RtnSchdisc
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND  SP.StockTypeId IN (SELECT StockTypeId FROM StockType WHERE SystemStockType = 1)
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
 
 
	--------------- Added by LAkshman M On 26/06/2018 PMS ID: ILCRSTPAR1151 ----------------------
	SELECT Salid,RTRid,Schid,PrdId INTO #SalScheme FROM (
	Select Distinct SI.Salid,RTRid,Schid,PrdId from Salesinvoice SI(NOLOCK) INNER JOIN SalesInvoiceSchemeLineWise SH(NOLOCK) ON SI.Salid=SH.Salid
	WHERE Salinvdate between @FromDate AND @ToDate and Dlvsts in (4,5)
	UNION 
	Select Distinct SI.Salid,RTRid,SH.Schid,SIB.prdid from Salesinvoice SI(NOLOCK) INNER JOIN SalesInvoiceSchemeDtFreePrd SH(NOLOCK) ON SI.Salid=SH.Salid
	INNER JOIN SalesInvoiceSchemeDtBilled SIB (NOLOCK) ON SIB.SalId =Si.SalId
	WHERE Salinvdate between @FromDate AND @ToDate and Dlvsts in (4,5)
	)A
	
	
	SELECT ReturnId,RTRid,Schid,PrdId INTO #RtnScheme FROM (
	Select Distinct A.Returnid,RTRid,Schid,PrdId FROM ReturnSchemeLineDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	WHERE ReturnDate between @FromDate AND @ToDate and B.Status = 0  
	UNION
	Select Distinct A.Returnid,RTRid,Schid,0 As Prdid FROM ReturnSchemeFreePrdDt A WITH (NOLOCK) INNER JOIN ReturnHeader B WITH (NOLOCK) ON A.ReturnId = B.ReturnId
	WHERE ReturnDate between @FromDate AND @ToDate and B.Status = 0  
	)A
	--------------- Till Here --------------
 	SELECT Salid,RTRid, Schid,A.Prdid INTO #SalSchemeProducts FROM
	 (
		SELECT DISTINCT Salid,RTRid,A.Schid,B.Prdid FROM #SalScheme A(NOLOCK)
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN Product C(NOLOCK) On B.Prdid = C.PrdId
		INNER JOIN Schememaster SM (Nolock) ON SM.schid =B.schid WHERE SM.Claimable =1 AND A.PrdId =C.PrdId  --- Added By Lakshman  M on 21/06/2018 PMS ID:ILCRSTPAR1100
		UNION
		SELECT DISTINCT Salid,RTRid,A.Schid, E.Prdid FROM #SalScheme A(NOLOCK)
		INNER JOIN SchemeProducts B (NOLOCK)ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C (NOLOCK) ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D(NOLOCK) ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E(NOLOCK) On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F(NOLOCK) On
		F.PrdId = E.Prdid
		INNER JOIN Schememaster SM (Nolock) ON SM.schid =B.schid WHERE SM.Claimable =1 AND A.PrdId =E.PrdId --- Added By Lakshman  M on 21/06/2018 PMS ID:ILCRSTPAR1100
	)A INNER JOIN #FilterProduct B ON A.PrdId = B.Prdid 
	
 
	 	SELECT DISTINCT ReturnId,RTRid,Schid,A.Prdid INTO #RtnSchemeProducts FROM
		(
		SELECT DISTINCT ReturnId,RTRid,A.Schid, B.Prdid FROM #RtnScheme A
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN Product C(NOLOCK) On B.Prdid = C.PrdId
		INNER JOIN Schememaster SM (Nolock) ON SM.schid =B.schid WHERE SM.Claimable =1 --- Added By Lakshman  M on 21/06/2018 PMS ID:ILCRSTPAR1100
		UNION
		SELECT DISTINCT ReturnId,RTRid,A.Schid, E.Prdid FROM #RtnScheme A
		INNER JOIN SchemeProducts B(NOLOCK) ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C(NOLOCK) ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D(NOLOCK) ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E(NOLOCK) On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F(NOLOCK) On
		F.PrdId = E.Prdid
		INNER JOIN Schememaster SM (Nolock) ON SM.schid =B.schid WHERE SM.Claimable =1 AND A.PrdId =E.PrdId--- Added By Lakshman  M on 21/06/2018 PMS ID:ILCRSTPAR1100
	)A INNER JOIN #FilterProduct B ON A.PrdId = B.Prdid 
	
	------------- Added By Lakshman M On 22/06/2018 PMS ID: ILCRSTPAR1100
	INSERT INTO #RtnSchemeProducts(ReturnId,RTRid,SchId,PrdId)
	SELECT ReturnId,RTRid,B.Schid,C.PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN Product C ON c.PrdCCode = A.FromValue
	INNER JOIN #RtnScheme RS (NOLOCK) ON RS.SchId =B.SchId 
	WHERE ChangeType='Remove' AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0)

	INSERT INTO #SalSchemeProducts(SalId ,RTRid,SchId,PrdId)
	SELECT salid,RTRid,B.Schid,C.PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN Product C ON c.PrdCCode = A.FromValue
	INNER JOIN #SalScheme RS (NOLOCK) ON RS.SchId =B.SchId 
	WHERE ChangeType='Remove' AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0)
	----
	INSERT INTO #RtnSchemeProducts(ReturnId,RTRid,SchId,PrdId)		
	SELECT DISTINCT RS.ReturnID,RS.RtrId ,A.SchId,E.Prdid
	FROM SchemeMaster A
	INNER JOIN SchemeMasterControlHistory B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN ProductCategoryValue C ON 
	B.FromValue = C.PrdCtgValCode
	INNER JOIN ProductCategoryValue D ON
	D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
	INNER JOIN Product E On
	D.PrdCtgValMainId = E.PrdCtgValMainId 
	INNER JOIN ProductBatch F On
	F.PrdId = E.Prdid
	INNER JOIN #RtnScheme RS (NOLOCK) ON RS.SchId =A.SchId 
	WHERE A.SchemeLvlMode = 0  AND A.SchId in (SELECT SchId FROM SchemeProducts Where PrdId = 0 )
	AND ChangeType='Remove'
	------------ Till Here ----------------------
	
	SELECT DISTINCT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],DefaultPriceId,SchDisc,Type,
	CAST(0 AS NUMERIC(18,6))[ActualSellRate],CAST(0 AS NUMERIC(18,6))[SpecialSellRate],
	CAST(0 AS NUMERIC(18,6)) NrmlLCTR, CAST(0 AS NUMERIC(18,6)) NrmlSecSalesTOT, CAST(0 AS NUMERIC(18,6)) TOTDifClms
	, CAST(0 AS NUMERIC(18,6)) OfferLCTR, CAST(0 AS NUMERIC(18,6)) OffSecSalesTOT, CAST(0 AS NUMERIC(18,6)) TotOffSalesChain,
	 CAST(0 AS NUMERIC(18,6)) OffClmDiff
	INTO #MTSalesDetails
	FROM 
	(
	SELECT DISTINCT 1 TransType,A.RtrId,A.SalId,SalInvDate TransDate,A.PrdId,A.PrdBatId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate],DefaultPriceId,
	SchDisc,CASE ISNULL(B.Salid,0) WHEN 0 THEN 'NS' ELSE 'S' END AS Type
	FROM #BillingDetails A(NOLOCK)
	LEFT OUTER JOIN #SalSchemeProducts B(NOLOCK) ON A.Salid = B.salid AND A.Prdid=B.Prdid AND A.Rtrid =B.Rtrid
	UNION ALL
	SELECT  DISTINCT 2 TransType,A.RtrId,A.ReturnID,ReturnDate TransDate,A.PrdId,A.PrdBatId, BaseQty,MRP,PriceId,SlNo,PrdEditSelRte,DefaultPriceId,
	RtnSchDisc,CASE ISNULL(B.ReturnID,0) WHEN 0 THEN 'NS' ELSE 'S' END AS Type
	FROM #ReturnDetails A(NOLOCK)
	LEFT OUTER JOIN #RtnSchemeProducts B(NOLOCK) ON A.Returnid = B.Returnid AND A.Prdid=B.Prdid AND A.Rtrid =B.Rtrid
	) A
	
	
	UPDATE A SET ActualSellRate = C.PrdBatDetailValue FROM #MTSalesDetails A INNER JOIN ProductBatch B ON A.Prdid = B.PrdId AND A.Prdbatid = B.PrdBatId
	INNER JOIN 	ProductBatchDetails C ON B.DefaultPriceid = C.PriceId  AND C.SLNo = 3
	 
	
	SELECT DISTINCT Priceid,PrdBatDetailValue  INTO #SpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	UPDATE M SET M.[SpecialSellRate] = D.PrdBatDetailValue
	FROM #MTSalesDetails M (NOLOCK),
	#SpecialPrice D (NOLOCK) 
	WHERE M.PriceId = D.PriceId  
	
	 
	--Non Scheme
	UPDATE A SET NrmlLCTR = TotalPcs*ActualSellrate FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
		
	UPDATE A SET NrmlSecSalesTot = ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*ActualSellrate) ELSE (TotalPcs*SpecialSellRate) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
	
	UPDATE A SET TotDifClms  = NrmlLCTR-NrmlSecSalesTot FROM #MTSalesDetails A(NOLOCK) WHERE Type='NS'
	
			
	--Scheme
	
	UPDATE A SET OfferLCTR = TotalPcs*ActualSellrate FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
		
	UPDATE A SET OffSecSalesTOT = ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*ActualSellrate) ELSE (TotalPcs*SpecialSellRate) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
		
	UPDATE A SET TotOffSalesChain =  ( CASE SpecialSellRate WHEN 0 THEN (TotalPcs*(ActualSellrate-SchDisc)) ELSE (TotalPcs*(SpecialSellRate-SchDisc)) END )
	FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
	UPDATE A SET OffClmDiff = OfferLCTR-TotOffSalesChain FROM #MTSalesDetails A(NOLOCK) WHERE Type='S'
	
	SELECT CtgName,SUM(NrmlLCTR) NrmlLCTR,SUM(NrmlSecSalesTOT) NrmlSecSalesTOT,SUM(TOTDifClms) TOTDifClms,SUM(OfferLCTR) OfferLCTR,
	SUM(OffSecSalesTOT) OffSecSalesTOT,	SUM(OffClmDiff) OffClmDiff,SUM(TotOffSalesChain) TotOffSalesChain,	CAST(0 AS NUMERIC(18,6)) LIABNormalSale,
	CAST(0 AS NUMERIC(18,6)) OffLIABValue,CAST(0 AS NUMERIC(18,6)) TotalSales,CAST(0 AS NUMERIC(18,6)) LIABOffClmWITHOUTTOT,
	CAST(0 AS NUMERIC(18,6)) LIABOffClmTotalSale,CAST(0 AS NUMERIC(18,6)) GrandTotClm,
	CAST(0 AS NUMERIC(18,6)) TOTALLIAB ,CAST(0 AS NUMERIC(18,6)) TotSalTOChain,CAST(0 AS NUMERIC(18,6)) OffLIABTtotalSales,CAST(0 AS NUMERIC(18,6)) TOTLiabTotal
	INTO #MTFinal
	FROM #MTSalesDetails D (NOLOCK) INNER JOIN #FilterRetailer B ON D.Rtrid = B.Rtrid 
	GROUP BY  CtgName
	select * from  #MTFinal

	UPDATE A SET LIABNormalSale = (TotDifClms/NrmlLCTR)*100  FROM #MTFinal A(NOLOCK)  WHERE NrmlLCTR>0

	UPDATE A SET OffLiabvalue = OffSecSalesTOT-TotOffSalesChain  FROM #MTFinal A(NOLOCK) 
	 
	UPDATE A SET TotalSales = OfferLCTR+NrmlLCTR FROM #MTFinal A(NOLOCK) 
		
	UPDATE A SET LIABOffClmWITHOUTTOT = (OffLiabvalue/OfferLCTR)*100 FROM #MTFinal A(NOLOCK) WHERE OfferLCTR>0
	
	UPDATE A SET LIABOffClmTotalSale  = (OffClmDiff/OfferLCTR)*100  FROM #MTFinal A(NOLOCK)     WHERE OfferLCTR>0
		
	UPDATE A SET GrandTotClm  = 	(OffClmDiff+TotDifClms)   FROM #MTFinal A(NOLOCK) 
		
	UPDATE A SET TOTALLIAB  = 	(GrandTotClm/TotalSales)*100   FROM #MTFinal A(NOLOCK) WHERE [TotalSales] > 0	
	
	UPDATE A SET TotsaltoChain  = NrmlSecsalesTOT+ TotOffSalesChain    FROM #MTFinal A(NOLOCK) 	
	
	UPDATE A SET OffLIABTtotalSales  = 	(OffLIABValue/TotalSales)*100   FROM #MTFinal A(NOLOCK) WHERE [TotalSales] > 0
	
	UPDATE A SET TOTLiabTotal  = 	((GrandTotClm-OffLIABValue)/TotalSales)*100   FROM #MTFinal A(NOLOCK)  WHERE [TotalSales] > 0
	
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptMTDebitSummary_Excel')
	DROP TABLE RptMTDebitSummary_Excel
	
	SELECT CtgName,ROUND(NrmlLCTR,2,1) NrmlLCTR,ROUND(NrmlSecSalesTOT,2,1) NrmlSecSalesTOT,ROUND(TOTDifClms,2,1) TOTDifClms,ROUND(LIABNormalSale,2,1) LIABNormalSale,
	ROUND(OfferLCTR,2,1) OfferLCTR,ROUND(OffSecSalesTOT,2,1) OffSecSalesTOT,ROUND(TotOffSalesChain,2,1) TotOffSalesChain,ROUND(OffClmDiff,2,1) OffClmDiff,
	ROUND(OffLIABValue,2,1) OffLIABValue,ROUND(TotalSales,2,1) TotalSales,ROUND(TotSalTOChain,2,1) TotSalTOChain,ROUND(GrandTotClm,2,1) GrandTotClm,
	ROUND(LIABOffClmWITHOUTTOT,2,1) LIABOffClmWITHOUTTOT,ROUND(LIABOffClmTotalSale,2,1) LIABOffClmTotalSale,ROUND(OffLIABTtotalSales,2,1) OffLIABTtotalSales,
	ROUND(TOTLiabTotal,2,1) TOTLiabTotal,ROUND(TOTALLIAB,2,1) TOTALLIAB,1 AS Grpid
	INTO RptMTDebitSummary_Excel
	FROM #MTFinal
	
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptMTDebitSummary_Excel	
	
	SELECT * FROM RptMTDebitSummary_Excel(NOLOCK) 
	
	INSERT INTO RptMTDebitSummary_Excel
	SELECT 'Grand TOTAL : ' ,SUM(NrmlLCTR),SUM(NrmlSecSalesTOT),SUM(TOTDifClms),SUM(LIABNormalSale),SUM(OfferLCTR),SUM(OffSecSalesTOT),SUM(TotOffSalesChain),SUM(OffClmDiff),
	SUM(OffLIABValue),SUM(TotalSales),SUM(TotSalTOChain),SUM(GrandTotClm),SUM(LIABOffClmWITHOUTTOT),SUM(LIABOffClmTotalSale),SUM(OffLIABTtotalSales),SUM(TOTLiabTotal),
	SUM(TOTALLIAB),9999999 FROM RptMTDebitSummary_Excel where CtgName not in ('Grand TOTAL : ')
	
 
	UPDATE  A SET	LIABNormalSale = ROUND((TOTDifClms/NrmlLCTR)*100,2,1) FROM RptMTDebitSummary_Excel  A where CtgName in ('Grand TOTAL : ') AND NrmlLCTR>0
	
	UPDATE  A SET LIABOffClmWITHOUTTOT =ROUND((OffLIABValue/OfferLCTR)*100,2,1), LIABOffClmTotalSale = ROUND((OffClmDiff/OfferLCTR)*100,2,1)
	FROM RptMTDebitSummary_Excel  A where CtgName in ('Grand TOTAL : ') AND OfferLctr>0
	
	UPDATE  A SET OffLIABTtotalSales = ROUND((OffLIABValue/TotalSales)*100,2,1),
	TOTLiabTotal =ROUND(((GrandTotClm-OffLIABValue)/TotalSales)*100,2,1),
	TOTALLIAB = ROUND((GrandTotClm/TotalSales)*100,2,1)  FROM RptMTDebitSummary_Excel  A where CtgName in ('Grand TOTAL : ') AND TotalSales>0
	
	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,1,'CHAIN NAME','CHAIN NAME',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,2,'TOTAL NORMAL AMOUNT','TOTAL NORMAL AMOUNT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,3,'TOTAL  NORMAL  SEC SALES AS PER TOT','TOTAL  NORMAL  SEC SALES AS PER TOT',1, 1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,4,'TOT DIFF CLAIMS','TOT DIFF CLAIMS',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,5,'% LIAB ON NORMAL SALE','% LIAB ON NORMAL SALE',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,6,'TOTAL OFFER NORMAL AMOUNT','TOTAL OFFER NORMAL AMOUNT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,7,'TOTAL OFFER SEC SALES AS PER TOT','TOTAL OFFER SEC SALES AS PER TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,8,'TOTAL OFFER SEC SALE','TOTAL OFFER SEC SALE',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,9,'OFFERS CLAIMS DIFF (TOT+OFFER)','OFFERS CLAIMS DIFF (TOT+OFFER)',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,10,'OFFER LIABILITY VALUE','OFFER LIABILITY VALUE',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,11,'TOTAL SALE(OFFER + NON OFFER)','TOTAL SALE(OFFER + NON OFFER)',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,12,'TOTAL SALE TO CHAIN','TOTAL SALE TO CHAIN',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,13,'GRAND TOTAL CLAIMS','GRAND TOTAL CLAIMS',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,14,'% LIAB OF OFFER CLAIMS ON SALE WITHOUT TOT','% LIAB OF OFFER CLAIMS ON SALE WITHOUT TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,15,'% LIAB OF OFFER CLAIMS ON TOTAL SALE','% LIAB OF OFFER CLAIMS ON TOTAL SALE',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,16,'% OFFER LIABILITY ON TOTAL SALES','% OFFER LIABILITY ON TOTAL SALES',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,17,'% TOT LIABILITY ON TOTAL SALES','% TOT LIABILITY ON TOTAL SALES',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,18,'TOTAL % LIAB','TOTAL % LIAB',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES(288,19,'Grpid','Grpid',0,1)
	
RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptMastSpecialDiscClaim' AND type='P')
DROP PROCEDURE Proc_RptMastSpecialDiscClaim
GO
--select * from ReportfilterDt where rptid = 102
--EXEC Proc_RptMastSpecialDiscClaim 102,2,10,'',1,0,1
--EXEC Proc_RptMastSpecialDiscClaim 102,2,0,'1005537',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptMastSpecialDiscClaim]
/************************************************************
* PROCEDURE	: Proc_RptMastSpecialDiscClaim
* PURPOSE	: To Get Special Discount Claim
* CREATED BY	: Jisha Mathew
* CREATED DATE	: 11/03/2008
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
--------------------------------------------------------------------------------------------------------------------
* Date			  Author	   CR/BZ			UserStoryId				Description
09-04-2018		Mohana S        BZ		     ILCRSTPAR0085			Sales return values included 		 
02-05-2018		lakshman M      BZ	         ILCRSTPAR0448	        Claim wise Rpt name & Date range filter validation added in Core stocky 
17-05-2018		lakshman M      BZ	         ILCRSTPAR0625	        spent Amount before tax & claim amount column newly adedd in CS
11-07-2018		Deepak K		BZ			 ILCRSTPAR1336          Rpt Header Name not Refreshed 
**********************************************************************************************************************/  
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
SET NOCOUNT ON
BEGIN
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @SSQL		AS 	VarChar(8000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @CmpId		AS	INT
	DECLARE @Claimable	AS	INT
	DECLARE @ClmStatus	AS	INT
	DECLARE @SplDiscClaimId	AS	INT
	DECLARE @RtrId		AS	INT
	CREATE  TABLE #RptMastSpecialDiscClaim
		(
			CmpId 			INT,
			CmpName 		NVARCHAR(100),
			SplDiscClaimId		INT,
			SdcRefNo		NVARCHAR(100),
			SdcDate			DATETIME,
			SalId			INT,
			SalInvNo		NVARCHAR(100),
			RtrId 			INT,
			RtrName 		NVARCHAR(100),
			Rtrgroup 		NVARCHAR(100),
			Fromdt 			NVARCHAR(10),
			Todt 			NVARCHAR(10),
			SpentGrossAmt	NUMERIC (38,2),
			SpenttaxAmt		NUMERIC (38,2),
			SpentAmt 		NUMERIC (38,2),
			RecAmt	 		NUMERIC (38,2),
			TaxAmount	 	NUMERIC (38,2),
			Claimable 		NVARCHAR(100),
			ConfStatus 		NVARCHAR(100),
			claimamount		NUMERIC (38,2),
			UsrId 			INT	
		)
	SET @CmpId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @Claimable = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,113,@Pi_UsrId))
	SET @ClmStatus = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,114,@Pi_UsrId))
	SET @SplDiscClaimId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,121,@Pi_UsrId))
	SET @RtrId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate) 
	
	DELETE FROM #RptMastSpecialDiscClaim Where Usrid=@Pi_UsrId
	
	SET @TblName = 'RptMastSpecialDiscClaim'
	
	SET @TblStruct ='		
			CmpId 			INT,
			CmpName 		NVARCHAR(100),
			SplDiscClaimId		INT,
			SdcRefNo		NVARCHAR(100),
			SdcDate			DATETIME,
			SalId			INT,
			SalInvNo		NVARCHAR(100),
			RtrId 			INT,
			RtrName 		NVARCHAR(100),
			Rtrgroup 		NVARCHAR(100),
			Fromdt 			DATETIME,
			Todt 			DATETIME,
			SpentGrossAmt	NUMERIC (38,2),
			SpenttaxAmt		NUMERIC (38,2),
			SpentAmt 		NUMERIC (38,2),
			RecAmt	 		NUMERIC (38,2),
			TaxAmount	 	NUMERIC (38,2),
			Claimable 		NVARCHAR(100),
			ConfStatus 		NVARCHAR(100),
			claimamount		NUMERIC (38,2),
			UsrId 			INT	
		'					
	
	SET @TblFields = 'CmpId,CmpName,SplDiscClaimId,SdcRefNo,SdcDate,SalId,SalInvNo,RtrId,RtrName,Rtrgroup,Fromdt,Todt,SpentGrossAmt,SpenttaxAmt,SpentAmt,
			  RecAmt,TaxAmount,Claimable,ConfStatus,claimamount,UsrId'
			 
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
		INSERT INTO #RptMastSpecialDiscClaim (CmpId,CmpName,SplDiscClaimId,SdcRefNo,SdcDate,SalId,SalInvNo,RtrId,RtrName,SpentGrossAmt,SpenttaxAmt,SpentAmt,
		RecAmt,Claimable,ConfStatus,claimamount,UsrId)
		Select Distinct CmpId,CmpName,SplDiscClaimId,SdcRefNo,SdcDate,SalId,SalInvNo,RtrId,RtrName,SpentGrossAmt,SpentTaxAmt,
		SpentAmt,RecAmt,Claimable,ConfStatus,claimamount,@Pi_UsrId AS UsrId 		
		FROM (
		Select Distinct C.CmpId,CmpName,SplDiscClaimId,A.SdcRefNo AS SdcRefNo,SdcDate,D.SalId AS SalId,SalInvNo,E.RtrId AS RtrId,RtrName,SpentGrossAmt,SpenttaxAmt,
		dbo.Fn_ConvertCurrency(SpentAmt,@Pi_CurrencyId) AS SpentAmt,
		dbo.Fn_ConvertCurrency(RecAmt,@Pi_CurrencyId) AS RecAmt,
		CASE B.Status WHEN 1 THEN 'Claimable' ELSE 'Non Claimable' END AS Claimable,
		CASE A.Status WHEN 1 THEN 'Confirmed' ELSE 'Not Confirmed' END AS ConfStatus,(SpentGrossAmt + SpenttaxAmt) claimamount--------> Added by lakshman M on 17/05/2018 PMS ID:ILCRSTPAR0625
		From SpecialDiscountMaster A
		INNER JOIN SpecialDiscountDetails B ON A.SdcRefNo = B.SdcRefNo 
		INNER JOIN Company C On A.CmpId = C.CmpId 
		INNER JOIN SalesInvoice D ON B.SalId = D.SalId 
		INNER JOIN Retailer E On E.RtrId = D.RtrId 
		Where (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
					C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND  (B.Status = (CASE @Claimable WHEN 0 THEN B.Status ELSE 3 END) OR
					B.Status in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,113,@Pi_UsrId)))
		AND  (A.Status = (CASE @ClmStatus WHEN 0 THEN A.Status ELSE 3 END) OR
					A.Status in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,114,@Pi_UsrId)))
		AND  (A.SplDiscClaimId = (CASE @SplDiscClaimId WHEN 0 THEN A.SplDiscClaimId ELSE 0 END) OR
					A.SplDiscClaimId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,121,@Pi_UsrId)))
		AND  (E.RtrId = (CASE @RtrId WHEN 0 THEN E.RtrId ELSE 0 END) OR
					E.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND SdcDate BETWEEN @FromDate AND @ToDate AND Itype =1
		UNION
		Select Distinct C.CmpId,CmpName,SplDiscClaimId,A.SdcRefNo AS SdcRefNo,SdcDate,D.SalId AS SalId,REturnCode SalInvNo,E.RtrId AS RtrId,RtrName,SpentGrossAmt,SpenttaxAmt,
		dbo.Fn_ConvertCurrency(SpentAmt,@Pi_CurrencyId) AS SpentAmt,
		dbo.Fn_ConvertCurrency(RecAmt,@Pi_CurrencyId) AS RecAmt,
		CASE B.Status WHEN 1 THEN 'Claimable' ELSE 'Non Claimable' END AS Claimable,
		CASE A.Status WHEN 1 THEN 'Confirmed' ELSE 'Not Confirmed' END AS ConfStatus,(SpentGrossAmt + SpenttaxAmt) claimamount --------> Added by lakshman M on 17/05/2018 PMS ID:ILCRSTPAR0625
		From SpecialDiscountMaster A
		INNER JOIN SpecialDiscountDetails B ON A.SdcRefNo = B.SdcRefNo 
		INNER JOIN Company C On A.CmpId = C.CmpId 
		INNER JOIN ReturnHeader D ON B.SAlid = D.Returnid 
		INNER JOIN Retailer E On E.RtrId = D.RtrId 
		Where (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
					C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND  (B.Status = (CASE @Claimable WHEN 0 THEN B.Status ELSE 3 END) OR
					B.Status in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,113,@Pi_UsrId)))
		AND  (A.Status = (CASE @ClmStatus WHEN 0 THEN A.Status ELSE 3 END) OR
					A.Status in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,114,@Pi_UsrId)))
		AND  (A.SplDiscClaimId = (CASE @SplDiscClaimId WHEN 0 THEN A.SplDiscClaimId ELSE 0 END) OR
					A.SplDiscClaimId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,121,@Pi_UsrId)))
		AND  (E.RtrId = (CASE @RtrId WHEN 0 THEN E.RtrId ELSE 0 END) OR
					E.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND SdcDate BETWEEN @FromDate AND @ToDate AND Itype = 2 
		)A
		
	   SELECT DISTINCT C.CtgCode,C.CtgName,R.CmpRtrCode,C.CtgMainId,R.RtrId  
	   INTO #RetailerCtgCode  
	   FROM RetailerCategory C (NOLOCK)  
	   INNER JOIN RetailerValueClass V (NOLOCK) ON C.CtgMainId = V.CtgMainId  
	   INNER JOIN RetailerValueClassMap M (NOLOCK) ON V.RtrClassId = M.RtrValueClassId  
	   INNER JOIN Retailer R (NOLOCK) ON M.RtrId = R.RtrId 
		
	   UPDATE A SET A.Rtrgroup = B.CtgName from #RptMastSpecialDiscClaim A  INNER JOIN #RetailerCtgCode B ON A.RtrId =B.RtrId
	
   	   	IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptMastSpecialDiscClaim ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ ' WHERE RptId=' + CAST(@Pi_RptId AS nVarchar(10)) + ' AND UsrId=' + CAST(@Pi_UsrId AS nVarchar(10)) + '' 
				+ 'AND (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (Status = (CASE ' + CAST(@Claimable AS nVarchar(10)) + ' WHEN 0 THEN Status ELSE 3 END) OR '
				+ 'Status in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',113,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (Status = (CASE ' + CAST(@ClmStatus AS nVarchar(10)) + ' WHEN 0 THEN Status ELSE 3 END) OR '
				+ 'Status in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',114,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (SplDiscClaimId = (CASE ' + CAST(@SplDiscClaimId AS nVarchar(10)) + ' WHEN 0 THEN SplDiscClaimId ELSE 0 END) OR '
				+ 'SplDiscClaimId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',121,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '
				+ 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
	
			EXEC (@SSQL)
		END
	
		IF @Pi_SnapRequired = 1
		   BEGIN
			SELECT @NewSnapId = @Pi_SnapId
	
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			IF @ErrNo = 0
			   BEGIN
				SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName + 
					'(SnapId,RptId,UserId,' + @TblFields + ')' + 
					' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', ' + CAST(@Pi_UsrId AS VARCHAR(10)) + ',* FROM #RptMastSpecialDiscClaim'
	
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
			SET @SSQL = 'INSERT INTO #RptMastSpecialDiscClaim ' + 
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

-------------- Added by lakshman M On 03-05-2018 PMS ID: ILCRSTPAR0448  ---------------
	DECLARE @Rptname AS varchar(max)
	DECLARE @SplClmid	AS	Varchar(100)
	DECLARE @Jcmid	AS	Varchar(100)
	Declare @JCfrmDate As datetime
	Declare @JCTillDate As datetime 
	Declare @JCSDDate As datetime
	Declare @JCENDDate As datetime 
	
	SET @SplClmid ='' 
	SET @Jcmid =''
	SET @JCfrmDate = ''
	SET @JCTillDate =''
	set @Rptname = ''
	set @JCSDDate = ''
	set @JCENDDate = ''
	
--EXEC Proc_RptMastSpecialDiscClaim 102,2,10,'',1,0,1

	
	select @SplClmid=A.SplDiscClaimId,@Jcmid=A.JcmId,@JCfrmDate=A.FromJcmJcId,@JCTillDate=A.ToJcmJcId,@JCSDDate=B.JcmSdt,@JCENDDate=B.Jcmedt 
	from SpecialDiscountMaster A INNER JOIN JCMonth B ON A.JcmId =B.JcmId and A.FromJcmJcId =B.JcmJc
	inner join #RptMastSpecialDiscClaim C ON C.SplDiscClaimId =A.SplDiscClaimId
	
	
	select @JCSDDate=JcmSdt,@JCENDDate=JcmEdt from SpecialDiscountMaster A INNER JOIN JCMast B ON A.JcmId =B.JcmId 
	INNER JOIN JCMonth C ON C.JcmId =B.JcmId AND A.FromJcmJcId = C.JcmJc 
	INNER JOIN #RptMastSpecialDiscClaim D ON D.SplDiscClaimId =A.SplDiscClaimId 
	
	Update D SET D.Fromdt=convert(varchar(10),JcmSdt,103),D.Todt=convert(varchar(10),JcmEdt,103) from SpecialDiscountMaster A INNER JOIN JCMast B ON A.JcmId =B.JcmId 
	INNER JOIN JCMonth C ON C.JcmId =B.JcmId AND A.FromJcmJcId = C.JcmJc 
	INNER JOIN #RptMastSpecialDiscClaim D ON D.SplDiscClaimId =A.SplDiscClaimId 
	--Print @JCSDDate
	--print @JCENDDate
	
	--UPDATE RptHeader SET RpCaption = '' WHERE RPTID = @Pi_RptId
/*Modified By Deepak K PMS NoILCRSTPAR1336 */
	DELETE FROM rptformula WHERE RPTID = 102 AND FORMULA = 'Dis_Discount' 
	INSERT INTO rptformula
	SELECT 102,(select max(SlNo) +1 from rptformula WHERE RPTID = 102),'Dis_Discount','',1,0

	UPDATE rptformula SET FormulaValue='Special Discount Claim Master Report' WHERE RPTID = @Pi_RptId AND Formula = 'Dis_Discount' 
	
	SELECT @Rptname= FormulaValue  FROM rptformula WHERE RPTID = @Pi_RptId AND Formula = 'Dis_Discount' 
		
	--UPDATE RptHeader SET RpCaption= @Rptname +' For ' +'('+ CONVERT(varchar(10),@JCSDDate,105) +' - ' + CONVERT(varchar(10),@JCENDDate,105)+')' WHERE RPTID = @Pi_RptId
	
	UPDATE rptformula SET FormulaValue= @Rptname +' For ' +'('+ CONVERT(varchar(10),@JCSDDate,105) +' - ' + CONVERT(varchar(10),@JCENDDate,105)+')' 
	WHERE RPTID = @Pi_RptId AND Formula = 'Dis_Discount' and SLNO = 25
--Till Here
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptMastSpecialDiscClaim 

	select * from #RptMastSpecialDiscClaim
---------- Till here ----------------
RETURN
END
GO
IF EXISTS (select * from RptDetails WHERE Rptid =107)
BEGIN
DELETE FROM RptDetails WHERE Rptid =107 AND SelcId =41
INSERT INTO  RptDetails
SELECT 107,7,'ClaimSheetHD',-1,'','ClmId,ClmCode,ClmCode+''-''+ClmDesc ClmDesc','Claim Description...','',1,'',41,1,0,'Press F4/Double Click to Select Claim Code',0
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='Cs2Cn_Prk_DebitNoteTopSheet4')
BEGIN
	ALTER TABLE Cs2Cn_Prk_DebitNoteTopSheet4 ALTER COLUMN  SalInvDate DATETIME
END
GO
IF NOT EXISTS(SELECT A.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.ID 
WHERE A.NAME='Cs2Cn_Prk_DebitNoteTopSheet2' AND B.NAME='TransDate' AND A.xtype='U')
BEGIN
	ALTER TABLE Cs2Cn_Prk_DebitNoteTopSheet2 ADD TransDate DATETIME
END
GO
IF NOT EXISTS (Select A.Name from sysobjects A INNER JOIN SYSCOLUMNS B ON A.id = B.id 
WHERE A.NAME='Cs2Cn_Prk_DebitNoteTopSheet2' AND B.NAME='TransType' AND A.xtype='U')
BEGIN
	ALTER TABLE Cs2Cn_Prk_DebitNoteTopSheet2 ADD TransType NVarchar(50)
END
GO
UPDATE Cs2Cn_Prk_DebitNoteTopSheet2 SET TransDate ='' WHERE TransDate is null AND UploadFlag='N'
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='DebitNoteTopSheet2Track' AND xtype='U')
BEGIN
CREATE TABLE DebitNoteTopSheet2Track
(
	SlNo		BIGINT IDENTITY(1,1),
	TransDate	DATETIME,
	CreatedDate	DATETIME,
	Upload INT
)
END
GO
IF EXISTS(SELECT '*' FROM Udchd A(NOLOCK)
INNER JOIN UdcMaster UM (NOLOCK) ON A.MasterId=UM.MasterId
INNER JOIN UdcDetails UD(NOLOCK) ON A.MasterId=UD.MasterId and UD.MasterId=UM.MasterId AND UD.UdcMasterId=UM.UdcMasterId
WHERE A.MasterName='Distributor Info Master' AND UM.ColumnName='State Name' and ColumnValue  IN ('Tamil Nadu'))
BEGIN
	IF NOT EXISTS(SELECT * FROM DebitNoteTopSheet2Track(NOLOCK))
	BEGIN
		INSERT INTO DebitNoteTopSheet2Track(TransDate,CreatedDate,Upload)
		SELECT DISTINCT '2017-11-01',GETDATE(),0
	END
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_DebitNoteTopSheet4]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Cs2Cn_DebitNoteTopSheet4]
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_DebitNoteTopSheet4 0,'2018-07-26'
select * from Cs2Cn_Prk_DebitNoteTopSheet4 order by slno
Rollback Transaction
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_DebitNoteTopSheet4]
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DebitNoteTopSheet4
* PURPOSE		: To Extract TOT CLAIMS
* CREATED BY	: MOHANA S
* CREATED DATE	: 03-05-2018
* PMS 			: CCRSTPAR0187
* MODIFIED	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)
	DELETE FROM Cs2Cn_Prk_DebitNoteTopSheet4 WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,   
	B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue    
	INTO #BillingDetails1    
	FROM SalesInvoice S (NOLOCK)    
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId    
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1		 
	WHERE SalInvNo in (SELECT DISTINCT salinvno FROM Cs2Cn_Prk_DailySales) AND S.DlvSts > 3 and PBD.SLNo =3
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,  
	B.DefaultPriceId ActualPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue  
	INTO #ReturnDetails1    
	FROM ReturnHeader S (NOLOCK)    
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND StockTypeid in (select stocktypeid from  stocktype where systemstocktype =1)   
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId    
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1
	WHERE ReturnCode IN (SELECT SrNRefNO from Cs2Cn_Prk_Salesreturn) AND S.[Status] = 0 and PBD.SLNo =3
	
	SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName
	INTO #Retailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	
	SELECT tranid,Refid,Rtrid,CtgName,RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,SelRate,CAST(0 AS NUMERIC(18,2)) Nrmlrate,CAST(0 AS NUMERIC(18,2)) SplRate,CAST(0 AS NUMERIC(18,2)) Diff
	INTO #TotClaim FROM(
	SELECT 1 tranid,Salid Refid,A.Rtrid,CtgName,Salinvdate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate FROM #BillingDetails1 A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid 
	UNION 
	SELECT 2 Transid,ReturnID Refid,A.Rtrid,CtgName,ReturnDate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate FROM #ReturnDetails1  A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid 
	)A
	
	SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #TotClaim M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #TotClaim M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	 UPDATE A SET A.SplRate = (BaseQty*B.SplselRate) FROM  #TotClaim A INNER JOIN #ExistingSpecialPrice B ON A.Priceid = B.Priceid WHERE A.Priceid <>0
	
	 UPDATE A SET A.SplRate = (BaseQty*SelRate) FROM  #TotClaim A WHERE A.Priceid =0
	
	 UPDATE A SET A.NrmlRate = (BaseQty*SelRate) FROM  #TotClaim A  
	 
	 
	UPDATE A SET A.Diff = (NrmlRate-SplRate) FROM  #TotClaim A  
	
	INSERT INTO Cs2Cn_Prk_DebitNoteTopSheet4
	SELECT @DistCode,CmpRtrCode,CTGNAME,SalInvNo,SalInvDate,PrdCCode,NRMLRATE ,SPLRATE,DIFF,'N',NULL,@ServerDate FROM
	(
	SELECT R.CmpRtrCode,CTGNAME,B.SalInvNo,B.SalInvDate,P.PrdCCode,SUM(NRMLRATE)NRMLRATE ,SUM(SPLRATE)SPLRATE, SUM(DIFF)  DIFF
	FROM #TotClaim A INNER JOIN SALESINVOICE B ON A.REFID =B.SALID
	INNER JOIN RETAILER R ON A.RTRID = R.RTRID AND B.RTRID =  R.RtrId
	INNER JOIN Product P ON A.PRDID = P.PRDID 
	WHERE Tranid = 1
	GROUP BY R.CmpRtrCode,CTGNAME,B.SalInvNo,B.SalInvDate,P.PrdCCode
	UNION ALL
	SELECT R.CmpRtrCode,CTGNAME,B.RETURNCODE,B.RETURNDATE,P.PrdCCode,SUM(NRMLRATE)NRMLRATE ,SUM(SPLRATE)SPLRATE, SUM(DIFF)  DIFF
	FROM #TotClaim A INNER JOIN ReturnHeader B ON A.REFID =B.RETURNID
	INNER JOIN RETAILER R ON A.RTRID = R.RTRID AND B.RTRID =  R.RtrId
	INNER JOIN Product P ON A.PRDID = P.PRDID 
	WHERE Tranid = 2
	GROUP BY R.CmpRtrCode,CTGNAME,B.RETURNDATE,B.RETURNCODE,P.PrdCCode
	)A
	
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_DebitNoteTopSheet2]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Cs2Cn_DebitNoteTopSheet2]
GO
/*  
Begin transaction 
delete  from Cs2Cn_Prk_DebitNoteTopSheet2
update A set rptupload =0,upload=0 from salesinvoice A where SalInvDate between '2018-01-01' and'2018-06-30'
update A set rptupload =0,upload=0 from Returnheader A where ReturnDate between '2018-01-01' and'2018-06-30'
exec Proc_Cs2Cn_RailwayDiscountReconsolidation 0,''  
EXEC Proc_Cs2Cn_DebitNoteTopSheet2 0,'2018-07-24'  
select *from Cs2Cn_Prk_DebitNoteTopSheet2 where cmpschcode ='SCH13813'
select *from cs2console_consolidated where column3 ='SCH13813' and processname like '%debitnote%'
Rollback Transaction
*/  
CREATE  PROCEDURE [dbo].[Proc_Cs2Cn_DebitNoteTopSheet2]  
(  
 @Po_ErrNo INT OUTPUT,  
 @ServerDate DATETIME  
)  
AS  
/*********************************  
* PROCEDURE  : Proc_Cs2Cn_DebitNoteTopSheet2   
* PURPOSE  : To Extract LMISDetails  
* CREATED BY : Aravindh Deva C  
* CREATED DATE : 03.06.2016  
* NOTE   :   
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*************************************************  
* [DATE]      [DEVELOPER]      [USER_STORY_ID]   [CR/BUG]       [DESCRIPTION]  
* 26-12-2017  S.MOORTHI	 CR      ICRSTPAR7182                 Date Wise Data Upload(TransDate)
* 18-12-2017  Lakshman. M        ICRSTPAR7106        BUG      Scheme id validation missing.Script validation added from CS.
* 13-07-2018  Lakshman M         ILCRSTPAR1254       BZ       Report caluculation included for upload process debit note top sheet2 from CS.
* 25/07/2018  Lakshman M         ILCRSTPAR1496       BZ       scheme code valdiation included from CS.
*************************************************/  
SET NOCOUNT ON  
BEGIN  
	 SET @Po_ErrNo=0  
	 DECLARE @DistCode As NVARCHAR(50)  
	 DELETE FROM Cs2Cn_Prk_DebitNoteTopSheet2 WHERE UploadFlag = 'Y'  
		 IF NOT EXISTS (SELECT * FROM UploadingReportTransaction (NOLOCK))  
		 BEGIN  
		  RETURN  
		 END  
	 
	 SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)   
	 DECLARE @FromDate DATETIME  
	 DECLARE @ToDate DATETIME  
 
 	--ICRSTPAR7182
	--SELECT @FromDate = MIN(SchValidFrom),@ToDate = MAX(SchValidTill) FROM SchemeMaster S (NOLOCK)
	--WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill)
	
	 SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) FROM UploadingReportTransaction S (NOLOCK)
	--ICRSTPAR7182 till here  
	
	EXEC Proc_SchUtilization_Report @FromDate,@ToDate
	 
	 EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate  
	 SELECT * INTO #ParleOutputTaxPercentage  FROM ParleOutputTaxPercentage (NOLOCK)  
 
	 DECLARE @SlNo AS INT  
	 SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price' 

 
 ------------------ added by Lakshman M dated on 13/07/2018 Pms ID: ILCRSTPAR1254 ------------
 --------------------- Added By Lakshman M Dated on 25/07/2018 PMS ID: ILCRSTPAR1496 ---------------
	 SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,    
	 B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue,D.Schid    
	 INTO #BillingDetails    
	 FROM SalesInvoice S (NOLOCK)    
	 INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId    
	 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId 
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1	
	 INNER JOIN Debitnote_Scheme D ON D.Salid = S.SalId AND SP.SalId = D.Salid AND D.Prdid =SP.PrdID AND D.linetype = 1
	 WHERE S.SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =3
	    		
	 SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,    
	 B.DefaultPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue,D.Schid    
	 INTO #ReturnDetails    
	 FROM ReturnHeader S (NOLOCK)    
	 INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID    
	 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId    
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1
		INNER JOIN Debitnote_Scheme D ON D.Salid = S.ReturnID AND SP.ReturnID = D.Salid  AND D.linetype = 2
	 WHERE S.ReturnDate BETWEEN  @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =3
	    
	 SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,CAST (0 AS NUMERIC(18,6)) AS ActualSellRate,prdtaxamount,
	 PrdBatDetailValue as PrdUnitSelRate ,Schid ,
	 CAST (0 AS NUMERIC(18,6)) AS LCTR  
	 INTO #DebitSalesDetails    
	 FROM     
	 (    
	 SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,prdtaxamount,PrdBatDetailValue , schid FROM #BillingDetails   
	 UNION ALL    
	 SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,DefaultPriceId ,SlNo,prdtaxamount,PrdBatDetailValue, schid  FROM #ReturnDetails    
	 ) Consolidated 
 ------------------------- Till Here ----------------
	 UPDATE M SET M.ActualSellRate = round(D.PrdBatDetailValue,2)    
	 FROM #DebitSalesDetails M (NOLOCK),    
	 ProductBatchDetails D (NOLOCK)     
	 WHERE M.ActualPriceId = D.PriceId AND D.SLNo = @SlNo 
 
	 UPDATE R SET R.LCTR = ROUND(((R.BaseQty *(R.PrdUnitSelRate))+(R.BaseQty*R.PrdUnitSelRate)*(T.TaxPerc/100)),2)      
	 FROM #DebitSalesDetails R (NOLOCK),    
	 #ParleOutputTaxPercentage T (NOLOCK)
	 WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType  
	 
	 --------------------- Till Here ----------------    
	 CREATE TABLE #ApplicableProduct  
	 (  
	  SchId  INT,  
	  PrdId   INT  
	 )
	  ----------------- added by lakshman M on 21-12-2017 sales invoice scheme added --------------  
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT DISTINCT A.SchId,B.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN Product C On B.Prdid = C.PrdId
		WHERE A.SchemeLvlMode = 0 AND B.PrdId <> 0
	UNION ALL
	SELECT DISTINCT A.SchId,E.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On
		F.PrdId = E.Prdid
		WHERE A.SchemeLvlMode = 0 AND B.PrdCtgValMainId <> 0
	UNION ALL
	SELECT DISTINCT S.SchId,B.MasterRecordId
		FROM SchemeProducts A 
		INNER JOIN UdcDetails B on B.UDCUniqueId =A.PrdCtgValMainId 
		INNER JOIN SchemeMaster S ON A.SchId = S.SchId
		WHERE S.SchemeLvlMode = 1
		
  --added by mohana ILCRSTPAR0500	
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT Schid ,PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN Product C ON c.PrdCCode = A.FromValue
	WHERE ChangeType='Remove'   AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0)
	
	INSERT INTO #ApplicableProduct(SchId,PrdId)		
	SELECT DISTINCT A.SchId,E.Prdid
	FROM SchemeMaster A
	INNER JOIN SchemeMasterControlHistory B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN ProductCategoryValue C ON 
	B.FromValue = C.PrdCtgValCode
	INNER JOIN ProductCategoryValue D ON
	D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
	INNER JOIN Product E On
	D.PrdCtgValMainId = E.PrdCtgValMainId 
	INNER JOIN ProductBatch F On
	F.PrdId = E.Prdid
	WHERE A.SchemeLvlMode = 0  AND A.SchId in (SELECT SchId FROM SchemeProducts Where PrdId = 0 )
	AND ChangeType='Remove'  
	--------------- Tille Here --------------
	 CREATE TABLE #ApplicableScheme  
	 (  
	  SchId   INT,  
	  CmpSchCode  NVARCHAR(100),  
	  SchValidFrom DATETIME,  
	  SchValidTill DATETIME,   
	  Budget   NUMERIC(18,2),  
	  BudgetAllocationNo VARCHAR(100),  
	  PrdId INT  
	 )
	------------- added by M. Lakshman dated on 18-12-2017 ----- Scheme id validation ----------   
	INSERT INTO #ApplicableScheme (SchId,CmpSchCode,SchValidFrom,SchValidTill,Budget,BudgetAllocationNo,PrdId)			
	SELECT DISTINCT A.SchId,S.cmpschcode,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo, A.PrdId
	FROM #ApplicableProduct A (NOLOCK),
	SchemeMaster S (NOLOCK)
	WHERE A.SchId = S.SchId AND A.SchId  IN (SELECT SCHID FROM Debitnote_Scheme) 
	AND S.Claimable = 1
 
 	SELECT  S.SchId,B.transdate,B.TransType,SM.CmpSchCode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	INTO #SchemeDebit1
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,Debitnote_Scheme D ,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=1 AND  B.Schid = D.Schid  AND SM.Schid = D.Schid AND
	d.sCHID = s.sCHID and s.PRDID = D.PRDID AND b.PrdId = D.PRDID  and b.sALID = d.sALID AND Linetype = 1 AND	
	--PMS NO:ILCRSTPAR0909
	--S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--AND S.SchValidTill 	BETWEEN @FromDate AND @ToDate
	--(S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--or S.SchValidTill 	BETWEEN @FromDate AND @ToDate)
	(B.Transdate BETWEEN @FromDate AND @ToDate
	or B.Transdate 	BETWEEN @FromDate AND @ToDate)
	GROUP BY S.SchId,SM.cmpschcode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,B.transdate,B.TransType
	ORDER BY S.SchId
 
	INSERT INTO #SchemeDebit1
	SELECT  S.SchId,B.transdate,B.TransType ,SM.Cmpschcode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,Debitnote_Scheme D,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2 AND  B.Schid = D.Schid  AND SM.Schid = D.Schid AND   Linetype = 2 AND
	d.sCHID = s.sCHID and s.PRDID = D.PRDID AND b.PrdId = D.PRDID  and b.sALID = d.sALID AND  S.SchId =B.SchId AND B.SchId =SM.SchId and 
	--PMSNo:ILCRSTPAR0909
	--S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--AND S.SchValidTill 	BETWEEN @FromDate AND @ToDate
	--(S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--or S.SchValidTill 	BETWEEN @FromDate AND @ToDate)
	(B.Transdate BETWEEN @FromDate AND @ToDate
	or B.Transdate 	BETWEEN @FromDate AND @ToDate)
	GROUP BY S.SchId,SM.cmpschcode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,B.transdate,B.TransType
	ORDER BY S.SchId

 	INSERT INTO #SchemeDebit1
	SELECT  S.SchId,B.transdate,B.TransType ,SM.CmpSchCode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	,Debitnote_Scheme D   
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2  
	AND S.Schid = D.Schid AND B.Prdid =D.Prdid AND B.Salid =D.Salid 
	AND S.SchId NOT IN (SELECT schid FROM #SchemeDebit1) AND Linetype = 2
	GROUP BY S.SchId,SM.CmpSchCode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,B.transdate,B.TransType
	ORDER BY S.SchId

	SELECT  SchId,transdate,CmpSchCode,SchValidFrom,SchValidTill,SchemeBudget,CircularNo, CircularDate,
	SUM(SecSalesQty) SecSalesQty,CAST(SUM(SecSalesVal) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount,CASE TransType WHEN 1 THEN 'Sales' WHEN 2 THEN 'Sales Return' END TransType
	INTO #SchemeDebit from #SchemeDebit1  
	GROUP BY SchId,CmpSchCode,SchValidFrom,SchValidTill,SchemeBudget,CircularNo, CircularDate,transdate,TransType
	 ----------------- Till here -------------- 
	 --SELECT S.SchId,B.TransDate,S.CmpSchCode,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo,  
	 --SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,2)) Liab,  
	 --CAST(0 AS NUMERIC(18,2)) Amount , CASE TransType WHEN 1 THEN 'Sales' WHEN 2 THEN 'Sales Return' END TransType
	 --INTO #SchemeDebit  
	 --FROM #ApplicableScheme S (NOLOCK),
	 --#DebitSalesDetails B (NOLOCK)   
	 --WHERE S.PrdId = B.PrdId AND B.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill  
	 --GROUP BY S.SchId,S.CmpSchCode,S.SchValidFrom,S.SchValidTill,Budget,BudgetAllocationNo,B.TransDate,TransType
	 --ORDER BY S.SchId
 
	 --Commented and Added by Mohana ICRSTPAR6760
	 --UPDATE SD SET SD.Amount = DBO.Fn_ReturnBudgetUtilized(SD.SchId)  
	 --FROM #SchemeDebit SD (NOLOCK)
	
	---- UPDATE SD SET SD.Amount = DBO.Fn_ReturnBudgetUtilized_scheme(SD.SchId,@FromDate,@ToDate)   
	---- FROM #SchemeDebit SD (NOLOCK)  
	---- UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,2))  
	---- FROM #SchemeDebit SD (NOLOCK)  
	---- WHERE SD.[SecSalesVal] <> 0

	---- UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,6))
	----FROM #SchemeDebit SD (NOLOCK)
	----WHERE SD.[SecSalesVal] <> 0
	  
	UPDATE SD SET SD.Amount = schamt
	FROM #SchemeDebit SD (NOLOCK) INNER JOIN (SELECT Schid ,Salinvdate ,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt
	FROM Debitnote_Scheme where Linetype = 1  group by Schid,Salinvdate )D  ON SD.Schid = D.Schid AND SD.TransDate =D.Salinvdate
	ANd transType = 'Sales'
	
	UPDATE SD SET SD.Amount = schamt
	FROM #SchemeDebit SD (NOLOCK) INNER JOIN (SELECT Schid ,Salinvdate ,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt
	FROM Debitnote_Scheme where Linetype = 2  group by Schid,Salinvdate)D  ON SD.Schid = D.Schid AND SD.TransDate =D.Salinvdate
	ANd transType = 'Sales Return'
 
	UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,6))
	FROM #SchemeDebit SD (NOLOCK)
	WHERE SD.[SecSalesVal] <> 0

	 INSERT INTO Cs2Cn_Prk_DebitNoteTopSheet2 (DistCode,CmpSchCode,SecSalesQty,SecSalesVal,Liab,Amount,  
	 UploadFlag,SyncId,ServerDate,TransDate,TransType)  
	 SELECT @DistCode,CmpSchCode,[SecSalesQty],[SecSalesVal],Liab,Amount,'N' UploadFlag,NULL,@ServerDate,TransDate,TransType
	 FROM #SchemeDebit
	--ICRSTPAR7182
	UPDATE A SET UPLOAD=1 FROM DebitNoteTopSheet2Track A(NOLOCK) WHERE Upload=0 and TransDate=@FromDate
	--ICRSTPAR7182
	RETURN     
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_RptDebitNoteTopSheet]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_RptDebitNoteTopSheet]
GO
--Proc_RptDebitNoteTopSheet 291,2,0,'',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptDebitNoteTopSheet]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*************************************************************************************************
* PROCEDURE	: Proc_RptDebitNoteTopSheet
* PURPOSE	: To Return the Scheme Utilization Details
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Debit Note Top Sheet
* MODIFIED 
***************************************************************************************************
* DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
10-10-2017  Mohana.S	 CR     CCRSTPAR0172          Included Circular Date and scheme Budget 
04-12-2017	Mohana		 BZ		ICRSTPAR6760		  Added New Function for calculating Scheme utilized for selected month
07-12-2017  Mary.S		 BZ		ICRSTPAR6933		  Excel Sheet row Witdth change    
13-12-2017  Mohana.S	 CR		ICRSTPAR6933		  Changed Sampling Amount as Zero (default)   
09-01-2018  Lakshman M   BZ     ICRSTPAR7284          LCTR Formula validation changed.(special price not consider in LCTR Value).
26-03-2018	Mohana S	 CR		CCRSTPAR0187		  TOT Diff Claims Report Created. 
08-05-2018	Mohana S	 SR     ILCRSTPAR0500	      included Removed Scheme Products. 
09-05-2018	Mohana S     BZ	    ILCRSTPAR0506         chaged the target data selection
10-05-2018  Mohana S     BZ     ILCRSTPAR0546		  Sales return issue fix in Trade schemes
08-06-2018  Muthulakshmi.V  BZ      ILCRSTPAR0909         Scheme valid date checking condition changed
25/07/2018  Lakshman M   BZ    ILCRSTPAR1496          scheme code valdiation included from CS.
***************************************************************************************************/     
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	 
	--Report 1
	DECLARE @CityName AS NVARCHAR(100)
	DECLARE @DistributorCode AS NVARCHAR(40)
	DECLARE @DistributorName AS NVARCHAR(100)
	DECLARE @DBMonth As INT
	
	EXEC Proc_SchUtilization_Report @FromDate,@ToDate
	
	SELECT @DistributorCode = DistributorCode, @DistributorName = DistributorName,
	@CityName = G.GeoName
	FROM Distributor D (NOLOCK),
	Geography G (NOLOCK) WHERE D.GeoMainId = G.GeoMainId
	
	--Added By Mohana 
	
	--SELECT @DBMonth = COUNT(*) FROM ACMaster  A INNER JOIN ACPeriod B ON A.AcmId=B.AcmId WHERE AcmYr = YEAR (GETDATE()) AND AcmSdt < =@ToDate
	SELECT @DBMonth = CASE MONTH (@ToDate) 
		WHEN 4 THEN 1
		WHEN 5 THEN 2
		WHEN 6 THEN 3
		WHEN 7 THEN 4
		WHEN 8 THEN 5
		WHEN 9 THEN 6
		WHEN 10 THEN 7
		WHEN 11 THEN 8
		WHEN 12 THEN 9
		WHEN 1 THEN 10
		WHEN 2 THEN 11
		WHEN 3 THEN 12
	END 
	--Report 1
		
	--Report 2
	DECLARE @MGSaleable AS INT 
	DECLARE @MGOffer AS INT
	DECLARE @SlNo AS INT
	
	DECLARE @SamplingAmount AS NUMERIC(18,2)
	SELECT @MGSaleable = StockTypeId FROM StockType WHERE UserStockType = 'MGSaleable'
	SELECT @MGOffer = StockTypeId FROM StockType WHERE UserStockType = 'MGOffer'
	SELECT @SlNo = SlNo FROM BatchCreation WHERE FieldDesc = 'Selling Price'
	SELECT DISTINCT J.PrdId,J.PrdBatId,B.TaxGroupId,CAST(0 AS NUMERIC(18,2)) TaxPercentage
	INTO #SamplingBatchTaxPercent
	FROM StockJournal J,
	StockJournalDt D (NOLOCK),
	ProductBatch B (NOLOCK)
	WHERE J.StkJournalRefNo = D.StkJournalRefNo
	AND J.PrdBatId = B.PrdBatId	AND J.PrdId = B.PrdId
	AND StockTypeId = @MGSaleable AND TransferStkTypeId = @MGOffer
	
	SELECT ROW_NUMBER() OVER (ORDER BY T.TaxGroupId) RowNo,
	MAX(T.PrdBatId) PrdBatId,T.TaxGroupId 
	INTO #BatchTaxPercent
	FROM #SamplingBatchTaxPercent T
	WHERE T.TaxGroupId <> 0
	GROUP BY T.TaxGroupId
	
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @TaxGroupId AS INT
	DECLARE @TaxPercentage AS NUMERIC(18,2)
	DECLARE @RowNo AS INT
	DECLARE @TotalRow AS INT
	
	SET @RowNo = 1
	SELECT @TotalRow = COUNT(TaxGroupId) FROM #BatchTaxPercent D (NOLOCK)	
		
	TRUNCATE TABLE SamplingBatchTaxPercent
	WHILE (@RowNo < = @TotalRow)
	BEGIN	
		SELECT @PrdId = B.PrdId, @PrdBatId = S.PrdBatId, @TaxGroupId = B.TaxGroupId
		FROM #BatchTaxPercent S,
		#SamplingBatchTaxPercent B (NOLOCK)
		WHERE S.PrdBatId = B.PrdBatId AND S.TaxGroupId = B.TaxGroupId
		AND RowNo = @RowNo
		EXEC Proc_SamplingTaxCalCulation @PrdId,@PrdBatId
		
		SELECT @TaxPercentage = TaxPercentage FROM SamplingBatchTaxPercent S (NOLOCK)
		WHERE PrdBatId = @PrdBatId
		
		UPDATE B SET B.TaxPercentage = @TaxPercentage
		FROM #SamplingBatchTaxPercent B
		WHERE B.TaxGroupId = @TaxGroupId
		
		SET @RowNo = @RowNo + 1
		
	END	
	
	SELECT @SamplingAmount =  ISNULL(SUM( D.StkTransferQty * (P.PrdBatDetailValue + (P.PrdBatDetailValue * (T.TaxPercentage / 100)))),0)
	FROM StockJournal J,
	StockJournalDt D (NOLOCK),
	ProductBatchDetails P (NOLOCK),
	#SamplingBatchTaxPercent T (NOLOCK)
	WHERE J.StkJournalRefNo = D.StkJournalRefNo AND J.PriceId = P.PriceId
	AND P.PrdBatId = T.PrdBatId
	AND StockTypeId = @MGSaleable AND TransferStkTypeId = @MGOffer
	AND P.SLNo = @SlNo
	--Report 2
	
	--Report 3
	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate
	
	SELECT * INTO #ParleOutputTaxPercentage FROM ParleOutputTaxPercentage (NOLOCK)	
	
	-------------------- Added by Lakshman M On 07/11/2017 PMS_ICRSTPAR6575-------------------
	 -------------- Scheme code validation added by LAkshman M Dated By On 25/07/2018 PMS ID:ILCRSTPAR1496 ------------
	 SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,    
	 B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue,D.Schid    
	 INTO #BillingDetails    
	 FROM SalesInvoice S (NOLOCK)    
	 INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId    
	 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId 
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1	
	 INNER JOIN Debitnote_Scheme D ON D.Salid = S.SalId AND SP.SalId = D.Salid AND D.Prdid =SP.PrdID AND D.linetype = 1
	 WHERE S.SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =3
	    
	 SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,    
	 B.DefaultPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue,D.Schid    
	 INTO #ReturnDetails    
	 FROM ReturnHeader S (NOLOCK)    
	 INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID    
	 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId    
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1
	 INNER JOIN Debitnote_Scheme D ON D.Salid = S.ReturnID AND SP.ReturnID = D.Salid  AND D.linetype = 2
	 WHERE S.ReturnDate BETWEEN  @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =3
	    
	 SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,CAST (0 AS NUMERIC(18,6)) AS ActualSellRate,prdtaxamount,
	 PrdBatDetailValue as PrdUnitSelRate ,Schid ,
	 CAST (0 AS NUMERIC(18,6)) AS LCTR  
	 INTO #DebitSalesDetails    
	 FROM     
	 (    
	 SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,prdtaxamount,PrdBatDetailValue , schid FROM #BillingDetails   
	 UNION ALL    
	 SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,DefaultPriceId ,SlNo,prdtaxamount,PrdBatDetailValue, schid  FROM #ReturnDetails    
	 ) Consolidated 
	------------------ Till Here ----------------------
	 UPDATE M SET M.ActualSellRate = round(D.PrdBatDetailValue,2)    
	 FROM #DebitSalesDetails M (NOLOCK),    
	 ProductBatchDetails D (NOLOCK)     
	 WHERE M.ActualPriceId = D.PriceId AND D.SLNo = @SlNo 
	
	---------------- commented by Lakshman M on 07/11/2017 ---------------  
	--UPDATE R SET R.LCTR = R.BaseQty * (R.ActualSellRate+(R.ActualSellRate*(T.TaxPerc/100)))
	--FROM #DebitSalesDetails R (NOLOCK),
	--#ParleOutputTaxPercentage T (NOLOCK)
	--WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType
  -----------------------
	 UPDATE R SET R.LCTR = ROUND(((R.BaseQty *(R.PrdUnitSelRate))+(R.BaseQty*R.PrdUnitSelRate)*(T.TaxPerc/100)),2)      
	 FROM #DebitSalesDetails R (NOLOCK),    
	 #ParleOutputTaxPercentage T (NOLOCK)
	 WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType  
	
	CREATE TABLE #ApplicableProduct
	(
		SchId		INT,
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT DISTINCT A.SchId,B.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN Product C On B.Prdid = C.PrdId
		WHERE A.SchemeLvlMode = 0 AND B.PrdId <> 0
	UNION ALL
	SELECT DISTINCT A.SchId,E.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On
		F.PrdId = E.Prdid
		WHERE A.SchemeLvlMode = 0 AND B.PrdCtgValMainId <> 0
	UNION ALL
	SELECT DISTINCT S.SchId,B.MasterRecordId
		FROM SchemeProducts A 
		INNER JOIN UdcDetails B on B.UDCUniqueId =A.PrdCtgValMainId 
		INNER JOIN SchemeMaster S ON A.SchId = S.SchId
		WHERE S.SchemeLvlMode = 1
		
  --added by mohana ILCRSTPAR0500	
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT Schid ,PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN Product C ON c.PrdCCode = A.FromValue
	WHERE ChangeType='Remove'   AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0 )
	
	INSERT INTO #ApplicableProduct(SchId,PrdId)		
	SELECT DISTINCT A.SchId,E.Prdid
	FROM SchemeMaster A
	INNER JOIN SchemeMasterControlHistory B ON A.CmpSchCode = B.CmpSchCode
	INNER JOIN ProductCategoryValue C ON 
	B.FromValue = C.PrdCtgValCode
	INNER JOIN ProductCategoryValue D ON
	D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
	INNER JOIN Product E On
	D.PrdCtgValMainId = E.PrdCtgValMainId 
	INNER JOIN ProductBatch F On
	F.PrdId = E.Prdid
	WHERE A.SchemeLvlMode = 0  AND A.SchId in (SELECT SchId FROM SchemeProducts Where PrdId = 0 )
	AND ChangeType='Remove'  
		
	CREATE TABLE #ApplicableScheme
	(
		SchId			INT,
		SchDsc			NVARCHAR(100),
		SchValidFrom	DATETIME,
		SchValidTill	DATETIME,	
		Budget			NUMERIC(18,2),
		BudgetAllocationNo VARCHAR(100),
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableScheme (SchId,SchDsc,SchValidFrom,SchValidTill,Budget,BudgetAllocationNo,PrdId)			
	SELECT DISTINCT A.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo, A.PrdId
	FROM #ApplicableProduct A (NOLOCK),
	SchemeMaster S (NOLOCK)
	WHERE A.SchId = S.SchId AND A.SchId  IN (SELECT SCHID FROM Debitnote_Scheme) 
	AND S.Claimable = 1
	
	--Added CircularNo and date By Mohana
	--SELECT S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	--SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	--CAST(0 AS NUMERIC(18,6)) Amount
	--INTO #SchemeDebit
	--FROM #ApplicableScheme S (NOLOCK),
	--#DebitSalesDetails B (NOLOCK) ,
	--SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode 
	--WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId AND S.SchId in (SELECT DISTINCT  SCHID FROM DEbitnote_Scheme) 
	--GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate
	--ORDER BY S.SchId
	--SchemeCirculardetails
		 
	SELECT  S.SchId,Transdate,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	INTO #SchemeDebit1
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,Debitnote_Scheme D ,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=1 AND  B.Schid = D.Schid  AND SM.Schid = D.Schid AND
	d.sCHID = s.sCHID and s.PRDID = D.PRDID AND b.PrdId = D.PRDID  and b.sALID = d.sALID AND	
	--PMS NO:ILCRSTPAR0909
	--S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--AND S.SchValidTill 	BETWEEN @FromDate AND @ToDate
	--(S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--or S.SchValidTill 	BETWEEN @FromDate AND @ToDate)
	(B.Transdate BETWEEN @FromDate AND @ToDate
	or B.Transdate 	BETWEEN @FromDate AND @ToDate)
	GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,Transdate
	ORDER BY S.SchId
	 
	INSERT INTO #SchemeDebit1
	SELECT  S.SchId,Transdate,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,Debitnote_Scheme D,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2 AND  B.Schid = D.Schid  AND SM.Schid = D.Schid AND
	d.sCHID = s.sCHID and s.PRDID = D.PRDID AND b.PrdId = D.PRDID  and b.sALID = d.sALID AND
	--PMSNo:ILCRSTPAR0909
	--S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--AND S.SchValidTill 	BETWEEN @FromDate AND @ToDate
	--(S.SchValidFrom BETWEEN @FromDate AND @ToDate
	--or S.SchValidTill 	BETWEEN @FromDate AND @ToDate)
	(B.Transdate BETWEEN @FromDate AND @ToDate
	OR  B.Transdate 	BETWEEN @FromDate AND @ToDate)
	GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,Transdate
	ORDER BY S.SchId
	 
	INSERT INTO #SchemeDebit1
	SELECT  S.SchId,Transdate,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) ,
	SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana
	,Debitnote_Scheme D   
	WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2  
	AND S.Schid = D.Schid AND B.Prdid =D.Prdid AND B.Salid =D.Salid 
	AND S.SchId NOT IN (SELECT schid FROM #SchemeDebit1)
	GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,Transdate
	ORDER BY S.SchId
	 
	SELECT  A.Schid,CmpSchcode,A.SchDsc,A.SchValidFrom,A.SchValidTill,SchemeBudget,CircularNo, CircularDate,
	SUM(SecSalesQty) SecSalesQty,CAST(SUM(SecSalesVal) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,
	CAST(0 AS NUMERIC(18,6)) Amount
	INTO #SchemeDebit from #SchemeDebit1  A
	INNER JOIN SchemeMaster B ON A.Schid = B.Schid 
	GROUP BY  A.Schid, CmpSchcode,A.SchDsc,A.SchValidFrom,A.SchValidTill,SchemeBudget,CircularNo, CircularDate
 
	--SELECT S.SchId,SUM(B.BaseQty) [SecSalesQtyInScheme]
	--INTO #SchemeForLiab
	--FROM #ApplicableScheme S (NOLOCK),
	--#BillingDetails B (NOLOCK)
	--WHERE S.PrdId = B.PrdId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	--AND EXISTS (SELECT 'C' FROM SalesInvoiceSchemeDtBilled SB (NOLOCK) WHERE B.SalId = SB.SalId AND S.SchId = SB.SchId)
	--GROUP BY S.SchId
	
	UPDATE SD SET SD.Amount = schamt
	FROM #SchemeDebit SD (NOLOCK) INNER JOIN (SELECT Schid ,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt
	FROM Debitnote_Scheme group by Schid )D  ON SD.Schid = D.Schid 
	  
	UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,6))
	FROM #SchemeDebit SD (NOLOCK)
	WHERE SD.[SecSalesVal] <> 0
	
	--Report 3
	
	--Report 4
	DECLARE @TargetNo	AS INT
	
	DECLARE @InsFromDate	AS	DATETIME	
	DECLARE @InsToDate		AS	DATETIME
	DECLARE @Year	AS INT	
	DECLARE @Month  AS INT
	DECLARE @MonthName as Nvarchar(100)
 --Changed by Mohana ILCRSTPAR0506	
	SELECT   TOP 1 @TargetNo = InsId,@Month=TargetMonth,@Year=TargetYear,
	@InsFromDate = CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01',
	@InsToDate = DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01'))	
	
	FROM InsTargetHD H (NOLOCK) 
	INNER JOIN 	JCMonth A  ON H.TargetMonth = A.JcmJc
	INNER JOIN    JCMast b on a.JcmId = b.JcmId AND H.TargetYear =  B.JcmYr
	WHERE A.JcmEdt  BETWEEN @FromDate AND @ToDate AND H.[Status] = 1	
	ORDER BY InsId DESC
	
	SELECT @MonthName=MonthName FROM MonthDt (NOLOCK) WHERE MonthId=@Month
	UPDATE InsTargetHD SET TargetMonth=EffFromMonthId WHERE TargetMonth=0
	
	--EXEC Proc_LoadingInstitutionsTarget @TargetNo,@Pi_UsrId
	EXEC Proc_LoadingInstitutionsTarget @Year,@Month,@MonthName,@Pi_UsrId
	
	SELECT CtgMainId,CtgName,@InsFromDate FromDate,@InsToDate ToDate,SUM([Target]) [Target],SUM(ClmAmount) DiscAmount,
	CAST(0 AS NUMERIC(18,6)) L2MSales,CAST(0 AS NUMERIC(18,6)) CurMSales,CAST(0 AS NUMERIC(18,0)) Outlet
	INTO #Institutions
	FROM InsTargetDetailsTrans (NOLOCK) WHERE CtgName <>''
	--WHERE UserId = @Pi_UsrId AND SlNo <> 0 and SlNo<>9999
	GROUP BY CtgMainId,CtgName
	
	SELECT DISTINCT R.RtrId,RC.CtgMainId
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND EXISTS (SELECT '' FROM #Institutions I (NOLOCK) WHERE I.CtgMainId = RC.CtgMainId)
	
	SELECT S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
	INTO #CurrentSales
	FROM 
	(
	SELECT R.CtgMainId,SUM(S.SalGrossAmount) Sales FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.CtgMainId
	UNION ALL
	SELECT F.CtgMainId,-1 * SUM(R.RtnGrossAmt) FROM ReturnHeader R (NOLOCK),
	#FilterRetailer F
	WHERE R.ReturnDate BETWEEN @InsFromDate AND @InsToDate AND R.Status = 0
	AND F.RtrId = R.RtrId
	GROUP BY F.CtgMainId
	) AS S GROUP BY S.CtgMainId
	SELECT R.CtgMainId,COUNT(DISTINCT S.RtrId) Outlet
	INTO #NoOfOutlet
	FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.CtgMainId	
	
	--Last Two Month Sales
	SELECT @InsToDate = DATEADD (D,-1,@InsFromDate) 
	SELECT @InsFromDate = DATEADD (MONTH,-2,@InsFromDate) 
	
	SELECT S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
	INTO #L2MSales
	FROM 
	(
	SELECT R.CtgMainId,SUM(S.SalGrossAmount) Sales FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.CtgMainId
	UNION ALL
	SELECT F.CtgMainId,-1 * SUM(R.RtnGrossAmt) FROM ReturnHeader R (NOLOCK),
	#FilterRetailer F
	WHERE R.ReturnDate BETWEEN @InsFromDate AND @InsToDate AND R.Status = 0
	AND F.RtrId = R.RtrId
	GROUP BY F.CtgMainId
	) AS S GROUP BY S.CtgMainId
	
	UPDATE I SET I.CurMSales = C.Sales
	FROM #Institutions I (NOLOCK),
	#CurrentSales C (NOLOCK)
	WHERE I.CtgMainId = C.CtgMainId
	UPDATE I SET I.L2MSales = C.Sales / 2
	FROM #Institutions I (NOLOCK),
	#L2MSales C (NOLOCK)
	WHERE I.CtgMainId = C.CtgMainId
	UPDATE I SET I.Outlet = C.Outlet
	FROM #Institutions I (NOLOCK),
	#NoOfOutlet C (NOLOCK)
	WHERE I.CtgMainId = C.CtgMainId
	--Report 4
	--Nagarajan on 28.Aug.2017
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel1')
	BEGIN
		DROP TABLE RptDebitNoteTopSheet_Excel1	
	END	
	
	CREATE TABLE RptDebitNoteTopSheet_Excel1
	(
	CmpSchCode VARCHAR(100),
	[Scheme Description] VARCHAR(100),
	[From] VARCHAR(10),
	[To] VARCHAR(10),
	[Circular No] VARCHAR(100),
	[Date] NVARCHAR(10),
	[Scheme Budget] NUMERIC(18,6),
	[Sec Sales Qty] BIGINT,
	[Sec Sales Value] NUMERIC(18,6),
	[% Liability on Sec Sales] NUMERIC(18,6),
	[Claim Amount] NUMERIC(18,6)
	) 		
	UPDATE #SchemeDebit SET Liab = (Amount / SecSalesVal) * 100 WHERE Liab > 0


	SELECT CmpSchCode,S.SchDsc [Scheme Description],CONVERT(VARCHAR(10),S.SchValidFrom,103) [From],CONVERT(VARCHAR(10),S.SchValidTill,103) [To],ISNULL(S.CircularNo,'') [Circular No],
	CONVERT(VARCHAR(10),S.CircularDate,103)  [Date],S.SchemeBudget [Scheme Budget],[SecSalesQty] [Sec Sales Qty],[SecSalesVal] [Sec Sales Value],Liab [% Liability on Sec Sales],Amount [Claim Amount],'A' As Dummy
	INTO #RptDebitNoteTopSheet_Excel1
	FROM #SchemeDebit S (NOLOCK) --WHERE Amount > 0
	
	
	IF (SELECT COUNT(*) FROM #RptDebitNoteTopSheet_Excel1) > 0
	BEGIN
		INSERT INTO #RptDebitNoteTopSheet_Excel1
		SELECT '' CmpSchCode ,'Total' [Scheme Description],'' [From],'' [To],'' [Circular No],'' [Date], 0 [Scheme Budget],
        0 [Sec Sales Qty], 0 [Sec Sales Value],0 [% Liability on Sec Sales],SUM([Claim Amount]) [Claim Amount],'B' Dummy
		FROM  #RptDebitNoteTopSheet_Excel1 
	END
	
	SELECT * INTO #Excel1 FROM #RptDebitNoteTopSheet_Excel1 ORDER BY Dummy
	
	DECLARE @RecCount AS BIGINT
	SELECT @RecCount = COUNT(7) FROM #RptDebitNoteTopSheet_Excel1
	
	INSERT INTO RptDebitNoteTopSheet_Excel1
	SELECT CmpSchCode,[Scheme Description],Cast([From] As Varchar(10)) [From],Cast([To] As Varchar(10)) [To],[Circular No],[Date],[Scheme Budget],
	[Sec Sales Qty],[Sec Sales Value],[% Liability on Sec Sales],[Claim Amount]
	FROM #Excel1 ORDER BY Dummy

	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel2')
	BEGIN
		DROP TABLE RptDebitNoteTopSheet_Excel2	
	END		
	CREATE TABLE RptDebitNoteTopSheet_Excel2
	(
		[Name Of the Category] NVARCHAR(200),
		[From] VARCHAR(10),
		[TO] VARCHAR(10),
		[Circular No] VARCHAR(50),
		[Monthly Target] NUMERIC(38,6),
	    [Last 2 Months Avg Sales] NUMERIC(18,6),
	    [Current Month] NUMERIC(18,6),
	    [No of Incentive Outlets] NUMERIC(18,0),
	    [Total Discount Amount] NUMERIC(38,6)
	)
	
	SELECT CtgName [Name Of the Category],convert(varchar(10),FromDate,103) [From],convert(varchar(10),ToDate,103) [To],'' [Circular No],[Target] [Monthly Target],
	L2MSales [Last 2 Months Avg Sales],CurMSales [Current Month],Outlet [No of Incentive Outlets],DiscAmount [Total Discount Amount],'A' Dummy
	INTO #RptDebitNoteTopSheet_Excel2
	FROM #Institutions (NOLOCK)
	IF (SELECT COUNT(*) FROM #RptDebitNoteTopSheet_Excel2) > 0
	BEGIN
	----------------- modified by lakshman M on 04/10/2017----------------    
	 INSERT INTO #RptDebitNoteTopSheet_Excel2    
	 SELECT 0 As [Name Of the Category],0 As [From],0 As [To],0 As [Circular No],0 As [Monthly Target],    
	 0 As [Last 2 Months Avg Sales],0 As [Current Month],0 As [No of Incentive Outlets],sum([Total Discount Amount]) [Total Discount Amount],'B' Dummy    
	 FROM #RptDebitNoteTopSheet_Excel2 
	   
	 Update A set [Name Of the Category]= null ,[From]=null,[To]=null,[Monthly Target]=null,[Last 2 Months Avg Sales]=null  
	 ,[Current Month]=null,[No of Incentive Outlets]=null, [Total Discount Amount]=null,[Circular No]='' from #RptDebitNoteTopSheet_Excel2 A where Dummy ='B'  
    -------------------- Till here ----------------------------- 
	END
	
	SELECT * INTO #Excel2 FROM #RptDebitNoteTopSheet_Excel2 ORDER BY Dummy
	
	INSERT INTO RptDebitNoteTopSheet_Excel2
	SELECT [Name Of the Category],[From],[To],[Circular No],[Monthly Target],
	[Last 2 Months Avg Sales],[Current Month],[No of Incentive Outlets],[Total Discount Amount]
	FROM #Excel2
	----------------------------------------------------TOT CLAIM Added By Mohana-------------------------------------------------------------------
	DECLARE @RecCount1 INT
	SELECT @RecCount1  = COUNT(*) FROM RptDebitNoteTopSheet_Excel2
	
	CREATE Table #TotClaimFinal 
	(
	CtgName		NVARCHAR(100),
	Fromdate	DATETIME,
	Todate	DATETIME,
	NrmlRate NUMERIC (18,2),
	SecSalesTot NUMERIC (18,2),
	DiffClaims NUMERIC (18,2)	
	)
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,   
	B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue    
	INTO #BillingDetails1    
	FROM SalesInvoice S (NOLOCK)    
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId    
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1		 
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =3
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,  
	B.DefaultPriceId ActualPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue  
	INTO #ReturnDetails1    
	FROM ReturnHeader S (NOLOCK)    
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND StockTypeid in (select stocktypeid from  stocktype where systemstocktype =1)   
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId    
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =3
	SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName
	INTO #Retailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	
	SELECT tranid,Refid,Rtrid,CtgName,RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,SelRate,CAST(0 AS NUMERIC(18,2)) Nrmlrate,CAST(0 AS NUMERIC(18,2)) SplRate,CAST(0 AS NUMERIC(18,2)) Diff
	INTO #TotClaim FROM(
	SELECT 1 tranid,Salid Refid,A.Rtrid,CtgName,Salinvdate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate FROM #BillingDetails1 A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid 
	UNION 
	SELECT 2 Transid,ReturnID Refid,A.Rtrid,CtgName,ReturnDate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate FROM #ReturnDetails1  A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid 
	)A
	SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #TotClaim M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #TotClaim M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A
	
	 UPDATE A SET A.SplRate = (BaseQty*B.SplselRate) FROM  #TotClaim A INNER JOIN #ExistingSpecialPrice B ON A.Priceid = B.Priceid WHERE A.Priceid <>0
	
	 UPDATE A SET A.SplRate = (BaseQty*SelRate) FROM  #TotClaim A WHERE A.Priceid =0
	
	 UPDATE A SET A.NrmlRate = (BaseQty*SelRate) FROM  #TotClaim A  
	 
	 
	 UPDATE A SET A.Diff = (NrmlRate-SplRate) FROM  #TotClaim A  
	 
	 INSERT INTO #TotClaimFinal(CtgName,NrmlRate,SecSalesTot,DiffClaims)
	 SELECT CtgName,SUM(NrmlRate),SUM(SplRate),SUM(Diff) FROM #TotClaim
	 GROUP BY Ctgname
	 
	 UPDATE A SET Fromdate = B.Frmdt ,Todate = B.todt FROM #TotClaimFinal A  INNER JOIN (SELECT Ctgname,MIn(RefDate) Frmdt,Max(RefDate) todt FROM #TotClaim GROUP BY CtgName) B ON A.CtgName = B.Ctgname
	 
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel3')
	BEGIN
		DROP TABLE RptDebitNoteTopSheet_Excel3	
	END		
	CREATE TABLE RptDebitNoteTopSheet_Excel3
	(
		[Name Of the Category] NVARCHAR(200),
		[From] DATETIME,
		[TO] DATETIME,
		[Total Normal amount] NUMERIC(18,2),
	    [Total  Normal  Sec Sales As Per TOT] NUMERIC(18,2),
	    [TOT Diff claims] NUMERIC(18,2) 
	)
	 
 	INSERT INTO RptDebitNoteTopSheet_Excel3
 	SELECT * FROM #TotClaimFinal
 	
	SET @RecCount = @RecCount + 1
	
	SET @RecCount1 = @RecCount1 +@RecCount + 1
	 
	-- Till here
		
	TRUNCATE TABLE RptExcelDebitNote  
		 
	INSERT INTO RptExcelDebitNote(Row,Col,MergeCells,Value)
	SELECT 1,1,'A1:J1','PARLE - DEBIT NOTE / CREDIT NOTE'
	UNION ALL
	SELECT 2,1,'A2:J2',''   --ICRSTPAR6933 (Row Number Changed OlRowNo+1)
	UNION ALL
	SELECT 3,1,'A3:H3','Name of the Town : ' + ISNULL(@CityName,'')
	UNION ALL
	SELECT 3,9,'I3:J3','Passed by SO / SE :'
	UNION ALL
	SELECT 4,1,'A4:F4','Name of the Wholesaler : ' + ISNULL(@DistributorName,'')
	UNION ALL
	SELECT 4,7,'G4:H4','Debit Note No :' + CONVERT(NVARCHAR(10),@DBMonth)
	UNION ALL
	SELECT 4,9,'I4:J4','Verified by ASM :'
	UNION ALL
	SELECT 5,1,'A5:F5','Wholesaler Code : ' + ISNULL(@DistributorCode,'')
	UNION ALL
	SELECT 5,7,'G5:H5','Credit Note No :'
	UNION ALL
	SELECT 5,9,'I5:J5','Authorized by DSM :'
	UNION ALL
	SELECT 6,1,'A6:F6','Name of the Division :'
	UNION ALL
	SELECT 6,7,'G6:H6','Credit Note Date :'
	UNION ALL
	SELECT 6,9,'I6:J6','Value of Approved credit note :'
	UNION ALL
	SELECT 7,1,'A7:J7',''
	UNION ALL	
	SELECT 8,1,'A8:J8','1.SAMPLING'
	UNION ALL
	SELECT 9,1,'A9:E9','DSM Sanction Letter Date '
	UNION ALL
	SELECT 9,6,'F9:J9','Sampling Amount : ' + CAST(@SamplingAmount AS VARCHAR(30))
	UNION ALL
	SELECT 10,1,'A10:D10','Product Sampled during the period  '
	UNION ALL
	SELECT 10,5,'E10:G10','From : ' + CONVERT(VARCHAR(11),@FromDate,105)
	UNION ALL
	SELECT 10,8,'H10:J10','To : ' + CONVERT(VARCHAR(11),@ToDate,105)
	UNION ALL
	SELECT 11,1,'A11:J11',''	
	UNION ALL
	SELECT 12,1,'A12:J12','2.TRADE SCHEME'	
	UNION ALL
	SELECT 13,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel1'
	UNION ALL
	SELECT 14,1,'A14','1R'	
	UNION ALL
	SELECT 14 + @RecCount + 1,1,'A' + CAST(14 + @RecCount + 1 AS VARCHAR(10)) + ':J' + CAST(14 + @RecCount + 1 AS VARCHAR(10)) ,'3.INSTITUTIONAL SALES'	
	UNION ALL
	SELECT 14 + @RecCount + 2,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel2'
	UNION ALL
	SELECT 14 + @RecCount + 3,1,'A' + CAST(14 + @RecCount + 3 AS VARCHAR(10)),'2R'
	UNION ALL
	SELECT 14 + @RecCount,1,'A' + CAST(14 + @RecCount AS VARCHAR(10)) + ':' + 'J' + CAST(14 + @RecCount AS VARCHAR(10)),''	
	UNION ALL--Added By Mohana
	SELECT 15,1,'A15','1R'
	UNION ALL
	SELECT 15 + @RecCount1 + 2,1,'A' + CAST(15 + @RecCount1 + 2 AS VARCHAR(10)) + ':J' + CAST(15 + @RecCount1 + 2 AS VARCHAR(10)) ,'4.TOT DIFF CLAIMS'	
	UNION ALL
 	SELECT 15 + @RecCount1 + 4,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel3'
 	UNION ALL
 	SELECT 15 + @RecCount1 + 6,1,'A' + CAST(15 + @RecCount1 + 6 AS VARCHAR(10)),'3R'
	UNION ALL
	SELECT 15 + @RecCount1+5,1,'A' + CAST(15 + @RecCount1+5 AS VARCHAR(10)) + ':' + 'J' + CAST(15 + @RecCount1+5 AS VARCHAR(10)),''	
	UNION ALL--Till Here
	SELECT 0,10,'B14','ColumnWidth'		
	UNION ALL
	SELECT 0,10,'C14','ColumnWidth'	
	UNION ALL
	SELECT 1,1,'-4108','HorizontalAlignment'
	UNION ALL
	SELECT 2,25,'2:6','RowHeight'	--ICRSTPAR6933
	RETURN	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_SchUtilization_Report' AND TYPE='P')
DROP PROCEDURE Proc_SchUtilization_Report
GO
/*
--EXEC Proc_SchUtilization_Report '2018-05-01','2018-05-31'  
*/  
CREATE PROCEDURE Proc_SchUtilization_Report  
(   
 @Pi_FromDate DATETIME,  
 @Pi_Todate  DATETIME  
)  
AS  
/*********************************  
* PROCEDURE     : Proc_SchUtilization_Report  
* PURPOSE     : General Procedure To Get the Scheme Details into Scheme Temp Table  
* CREATED     : MOhana S  
* PMS      : ILCRSTPAR0546   
*********************************/  
/************************************************************************************************************************************************************
* VERSION |  DATE      |     PERSON      | USER STORY ID  |  CR/BZ |           REMARKS		                          | CODE REVIEW BY     | REVIEW DATE
***********************************************************************************************************************************************************
		| 2018-07-02 |  Deepak K		| (ILCRSTPAR1236) |  BZ   |  Optimization Done to generate the Report quickly  |
************************************************************************************************************************************************************/
SET NOCOUNT ON  
BEGIN  
   
 DELETE FROM Debitnote_Scheme    
 --Commented By Deepak K 
  --INSERT INTO Debitnote_Scheme (SchId,SlabId,SALid,FlatAmount,DiscountPer,FreeValue,GiftValue,SchemeBudget,BudgetUtilized,selected,linetype,salinvdate,PrdId)  
 --SELECT C.SchId,B.Slabid,A.SALid,ISNULL(SUM(B.FlatAmount),0) As FlatAmount,  
 -- ISNULL(SUM(B.DisCountPerAmount),0) as DiscountPer,  
 -- 0 as FreeValue,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(C.SchId),1 as Selected,  
 -- 1 as LineType,SalInvDate,B.PrdId  
 --FROM SalesInvoice A(NOLOCK) INNER JOIN SalesInvoiceSchemeLineWise B(NOLOCK) ON A.SalId = B.SalId  
 -- INNER JOIN SchemeMaster C(NOLOCK) ON B.SchId = C.SchId   
 -- WHERE  SalInvDate Between  @Pi_FromDate AND @Pi_Todate AND  
 -- A.Dlvsts >3  
 --GROUP BY C.SchId,B.SlabId,A.Salid,SalInvDate,Budget,B.PrdId  
 
 /*Added By Deepak K for Report Optimization PMS No : ILCRSTPAR1236 */
  SELECT Distinct C.SchId into #SchemeID
 FROM SalesInvoice A(NOLOCK) INNER JOIN SalesInvoiceSchemeLineWise B(NOLOCK) ON A.SalId = B.SalId  
  INNER JOIN SchemeMaster C(NOLOCK) ON B.SchId = C.SchId   
  WHERE  SalInvDate Between  @Pi_FromDate AND @Pi_Todate AND  
  A.Dlvsts >3  
 GROUP BY C.SchId,B.SlabId,A.Salid,SalInvDate,Budget,B.PrdId 
 
 SELECT Schid,dbo.Fn_ReturnBudgetUtilized(SchId) as SchemeUtilized INTO #SchemeUtilized from  #SchemeID
 
 INSERT INTO Debitnote_Scheme (SchId,SlabId,SALid,FlatAmount,DiscountPer,FreeValue,GiftValue,SchemeBudget,BudgetUtilized,selected,linetype,salinvdate,PrdId)  
 SELECT C.SchId,B.Slabid,A.SALid,ISNULL(SUM(B.FlatAmount),0) As FlatAmount,  
  ISNULL(SUM(B.DisCountPerAmount),0) as DiscountPer,  
  0 as FreeValue,0 as GiftValue,Budget as SchemeBudget,UT.SchemeUtilized,1 as Selected,  
  1 as LineType,SalInvDate,B.PrdId  
 FROM SalesInvoice A(NOLOCK) INNER JOIN SalesInvoiceSchemeLineWise B(NOLOCK) ON A.SalId = B.SalId  
  INNER JOIN SchemeMaster C(NOLOCK) ON B.SchId = C.SchId   
  inner join #SchemeUtilized UT on UT.SchId =C.SchId
  WHERE  SalInvDate Between  @Pi_FromDate AND @Pi_Todate AND  
  A.Dlvsts >3  
 GROUP BY C.SchId,B.SlabId,A.Salid,SalInvDate,Budget,B.PrdId,UT.SchemeUtilized 
 -- Till here PMS No : ILCRSTPAR1236
 INSERT INTO Debitnote_Scheme (SchId,SlabId,Salid,FlatAmount,DiscountPer,FreeValue,GiftValue,SchemeBudget,BudgetUtilized,selected,linetype,salinvdate,PrdId)  
 SELECT DISTINCT L.SchId,L.SlabId,A.Salid ,0 As FlatAmount,0 as DiscountPer,  
  (L.FreeQty * O.PrdBatDetailValue) as FreeValue,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(L.SchId),1 as Selected,  
  1 as LineType,SalInvDate,B.PrdId  
 FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId  
  AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE  
   B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)  
  INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN Product I ON B.PrdID = I.PrdId  
  INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId  
  INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId  
  AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId  
  INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId  
  INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId  
 INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo  
 AND P.ClmRte = 1  
 WHERE SalInvDate Between @Pi_FromDate AND @Pi_Todate  AND A.Dlvsts >3  
   
 INSERT INTO Debitnote_Scheme (SchId,SlabId,Salid,FlatAmount,DiscountPer,FreeValue,GiftValue,SchemeBudget,BudgetUtilized,selected,linetype,salinvdate,PrdId)  
 SELECT B.SchId,B.SlabId,A.Salid,0 As FlatAmount,0 as DiscountPer,  
 0 as FreeValue,(L.GiftQty * O.PrdBatDetailValue) as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),  
  1 as Selected,1 as LineType,SalInvDate,B.PrdId  
 FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId  
  AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE  
   B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)  
  INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN Product I ON B.PrdID = I.PrdId  
  INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId  
  INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId  
  AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId  
  INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId  
  INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId  
 INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo  
 AND P.ClmRte = 1  
 WHERE SalInvDate Between @Pi_FromDate AND @Pi_Todate  AND A.Dlvsts >3  
  
 INSERT INTO Debitnote_Scheme (SchId,SlabId,Salid,FlatAmount,DiscountPer,FreeValue,GiftValue,SchemeBudget,BudgetUtilized,selected,linetype,salinvdate,PrdId)  
 SELECT B.SchId,B.SlabId,A.Returnid,-1 * ISNULL(SUM(B.ReturnFlatAmount),0) As FlatAmount,  
  -1 * ISNULL(SUM(B.ReturnDiscountPerAmount),0) as DiscountPer,  
  0 as FreeValue,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,  
  2 as LineType,ReturnDate,B.PrdId  
 FROM ReturnHeader A INNER JOIN ReturnSchemeLineDt B ON A.ReturnId = B.ReturnId  
  INNER JOIN SchemeMaster C ON B.SchId = C.SchId   
 WHERE ReturnDate Between @Pi_FromDate AND @Pi_Todate  AND A.Status =0  
 GROUP BY B.SchId,B.SlabId,A.Returnid,ReturnDate,Budget,B.PrdId  
   
   
 INSERT INTO Debitnote_Scheme (SchId,SlabId,Salid,FlatAmount,DiscountPer,FreeValue,GiftValue,SchemeBudget,BudgetUtilized,selected,linetype,salinvdate,PrdId)  
 SELECT RSF.SchId,RSF.SlabId,RH.Returnid,0 AS FlatAmount,0 AS DiscountPer,  
  (-1 * (ISNULL(SUM(RSF.ReturnFreeQty),0) * PBD.PrdBatDetailValue)) AS FreeValue,0 AS GiftValue,SM.Budget AS SchemeBudget,dbo.Fn_ReturnBudgetUtilized(RSF.SchId),  
  1 AS Selected,2 AS LineType,ReturnDate,P.PrdId  
 FROM ReturnHeader RH   
  INNER JOIN ReturnSchemeFreePrdDt RSF ON  RH.ReturnId = RSF.ReturnId   
  INNER JOIN SchemeMaster SM ON  SM.SchId = RSF.SchId   
  INNER JOIN Product P ON RSF.FreePrdId = P.PrdId  
  INNER JOIN ProductBatch PB ON RSF.FreePrdBatId = PB.PrdBatId    
  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId = PBD.PrdBatID AND PBD.PriceId=RSF.FreePriceId  
  INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId = PBD.BatchSeqId AND PBD.SlNo = BC.SlNo AND BC.ClmRte = 1  
 WHERE ReturnDate Between @Pi_FromDate AND @Pi_Todate  AND RH.Status =0  
 GROUP BY RSF.SchId,RSF.SlabId,RH.Returnid,ReturnDate, PBD.PrdBatDetailValue,SM.Budget,P.PrdId  
   
 INSERT INTO Debitnote_Scheme (SchId,SlabId,Salid,FlatAmount,DiscountPer,FreeValue,GiftValue,SchemeBudget,BudgetUtilized,selected,linetype,salinvdate,PrdId)  
 SELECT RSF.SchId,RSF.SlabId,RH.Returnid,0 AS FlatAmount,0 AS DiscountPer,  
  0 as FreeValue, (-1 * ISNULL(SUM(RSF.ReturnGiftQty),0) * PBD.PrdBatDetailValue) as GiftValue,SM.Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(RSF.SchId),  
  1 as Selected,2 AS LineType,ReturnDate,P.PrdId  
 FROM ReturnHeader RH   
  INNER JOIN ReturnSchemeFreePrdDt RSF ON  RH.ReturnId = RSF.ReturnId   
  INNER JOIN SchemeMaster SM ON  SM.SchId = RSF.SchId   
  INNER JOIN Product P ON RSF.GiftPrdId = P.PrdId  
  INNER JOIN ProductBatch PB ON RSF.GiftPrdBatId = PB.PrdBatId    
  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId = PBD.PrdBatID AND PBD.PriceId=RSF.GiftPriceId  
  INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId = PBD.BatchSeqId AND PBD.SlNo = BC.SlNo AND BC.ClmRte = 1  
 WHERE ReturnDate Between @Pi_FromDate AND @Pi_Todate  AND RH.Status =0  
 GROUP BY RSF.SchId,RSF.SlabId,RH.Returnid,ReturnDate, PBD.PrdBatDetailValue,SM.Budget,P.PrdId  
   
 INSERT INTO Debitnote_Scheme (SchId,SlabId,salid,FlatAmount,DiscountPer,FreeValue,GiftValue,SchemeBudget,BudgetUtilized,selected,linetype,salinvdate,PrdId)  
 SELECT B.SchId,B.SlabId,A.salid,0 As FlatAmount,0 as DiscountPer,  
  0 as FreeValue,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),2 as Selected,  
  3 as LineType,SalInvDate,0  
 FROM SalesInvoice A INNER JOIN SalesInvoiceUnSelectedScheme B ON A.SalId = B.SalId  
  INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId  
  INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId  
  INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId  
  LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId  
  INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId  
  INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId  
  INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId  
  INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId  
 WHERE SalInvDate Between @Pi_FromDate AND @Pi_Todate  AND  
  A.dlvsts >3  
 GROUP BY B.SchId,B.SlabId,A.SAlid,SalInvDate,Budget   
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID =B.ID WHERE A.NAME ='Cs2Cn_Prk_DebitNoteTopSheet3' AND B.NAME IN('TargetMonth','TargetYear') AND A.Type ='U')
BEGIN
	ALTER TABLE Cs2Cn_Prk_DebitNoteTopSheet3 ADD  TargetMonth INT
	ALTER TABLE Cs2Cn_Prk_DebitNoteTopSheet3 ADD  TargetYear INT
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_DebitNoteTopSheet3]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_Cs2Cn_DebitNoteTopSheet3]
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_DebitNoteTopSheet3 0,'2018-07-27'
select * from Cs2Cn_Prk_DebitNoteTopSheet3 order by slno
Rollback Transaction
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_DebitNoteTopSheet3]
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DebitNoteTopSheet3 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*************************************************  
* [DATE]      [DEVELOPER]      [USER_STORY_ID]   [CR/BUG]       [DESCRIPTION]  
* 27/07/2018  Lakshman M       ILCRSTPAR1493       BZ       Report caluculation included for upload process debit note top sheet3 from CS.
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)
	DELETE FROM Cs2Cn_Prk_DebitNoteTopSheet3 WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT * FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	------------- Added By Lakshman M Dated ON 27/07/2018 PMS ID: ILCRSTPAR1493  ------------
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
	SELECT ROW_NUMBER() OVER (ORDER BY InsId) SlNo,InsId,H.InsRefNo,TargetMonth,TargetYear,Confirm,
	CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01' FromDate,
	DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01')) ToDate
	INTO #InstitutionToBeUpload	
	FROM InsTargetHD H (NOLOCK) WHERE H.[Status] = 1	
	DECLARE @RowNo AS INT
	SET @RowNo = 1
	
	DECLARE @TotalRow AS INT
	
	DECLARE @TargetNo	AS INT
	
	SELECT @TotalRow = COUNT(InsId) FROM #InstitutionToBeUpload D (NOLOCK)
	CREATE TABLE #Institutions
	(
	InsId INT,
	CtgMainId INT,
	FromDate DATETIME,
	ToDate DATETIME,
	[Target] NUMERIC(18,6),
	DiscAmount NUMERIC(18,6),
	L2MSales  NUMERIC(18,6),
	CurMSales  NUMERIC(18,6),
	Outlet NUMERIC(18,0),
	TargetMonth Int,
	TargetYear Int
	)	
	WHILE (@RowNo < = @TotalRow)
	BEGIN	
		TRUNCATE TABLE BilledPrdDtCalculatedTax
		TRUNCATE TABLE BilledPrdHdForTax
		DECLARE @Year	AS INT	
		DECLARE @Month  AS INT
		DECLARE @MonthName as Nvarchar(100)
		
		SELECT 	@TargetNo = InsId,@Year=TargetYear,@Month=TargetMonth FROM #InstitutionToBeUpload C (NOLOCK) WHERE SlNo = @RowNo
		
		SELECT @MonthName=MonthName FROM MonthDt (NOLOCK) WHERE MonthId=@Month
		
		--EXEC Proc_LoadingInstitutionsTarget @TargetNo,1
		
		EXEC Proc_LoadingInstitutionsTarget @Year,@Month,@MonthName,1
		
		INSERT INTO #Institutions (InsId,CtgMainId,FromDate,ToDate,[Target],DiscAmount,L2MSales,CurMSales,Outlet,TargetMonth,TargetYear)
		SELECT @TargetNo,CtgMainId,FromDate,ToDate,SUM([Target]) [Target],sum(ClmAmount) DiscAmount,
		0 L2MSales,0 CurMSales,0 Outlet,TargetMonth,TargetYear
		FROM InsTargetDetailsTrans T (NOLOCK),
		#InstitutionToBeUpload I
		WHERE UserId = 1 AND T.SlNo <> 0 
		AND I.InsId = @TargetNo AND CtgName <>''
		GROUP BY CtgMainId,FromDate,ToDate,TargetMonth,TargetYear
		
		SET @RowNo = @RowNo + 1
	END
	
	SELECT DISTINCT R.RtrId,RC.CtgMainId,I.InsId,I.FromDate,I.ToDate,TargetMonth,TargetYear
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK),
	#Institutions I (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND I.CtgMainId = RC.CtgMainId
	
	SELECT S.InsId,S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales,TargetMonth,TargetYear
	INTO #CurrentSales
	FROM 
	(
	SELECT R.InsId,R.CtgMainId,SUM(S.SalGrossAmount) Sales,TargetMonth,TargetYear FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN FromDate AND ToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.InsId,R.CtgMainId,TargetMonth,TargetYear
	UNION ALL
	SELECT F.InsId,F.CtgMainId,-1 * SUM(R.RtnGrossAmt),TargetMonth,TargetYear FROM ReturnHeader R (NOLOCK),
	#FilterRetailer F
	WHERE R.ReturnDate BETWEEN FromDate AND ToDate AND R.Status = 0
	AND F.RtrId = R.RtrId
	GROUP BY F.InsId,F.CtgMainId,TargetMonth,TargetYear
	) AS S GROUP BY S.InsId,S.CtgMainId,TargetMonth,TargetYear
	
	SELECT R.InsId,R.CtgMainId,COUNT(DISTINCT S.RtrId) Outlet,TargetMonth,TargetYear
	INTO #NoOfOutlet
	FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN FromDate AND ToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.InsId,R.CtgMainId,TargetMonth,TargetYear
		
	--Last Two Month Sales
	UPDATE F SET F.ToDate = DATEADD (D,-1,FromDate),
	F.FromDate = DATEADD (MONTH,-2,FromDate) 
	FROM #FilterRetailer F (NOLOCK)
	
	SELECT S.InsId,S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales,TargetMonth,TargetYear
	INTO #L2MSales
	FROM 
	(
	SELECT R.InsId,R.CtgMainId,SUM(S.SalGrossAmount) Sales,TargetMonth,TargetYear FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN FromDate AND ToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.InsId,R.CtgMainId,TargetMonth,TargetYear
	UNION ALL
	SELECT F.InsId,F.CtgMainId,-1 * SUM(R.RtnGrossAmt),TargetMonth,TargetYear FROM ReturnHeader R (NOLOCK),
	#FilterRetailer F
	WHERE R.ReturnDate BETWEEN FromDate AND ToDate AND R.Status = 0
	AND F.RtrId = R.RtrId
	GROUP BY F.InsId,F.CtgMainId,TargetMonth,TargetYear
	) AS S GROUP BY S.InsId,S.CtgMainId,TargetMonth,TargetYear
	
	UPDATE I SET I.CurMSales = C.Sales
	FROM #Institutions I (NOLOCK),
	#CurrentSales C (NOLOCK)
	WHERE I.InsId = C.InsId AND I.CtgMainId = C.CtgMainId
	
	UPDATE I SET I.L2MSales = C.Sales / 2
	FROM #Institutions I (NOLOCK),
	#L2MSales C (NOLOCK)
	WHERE I.InsId = C.InsId AND I.CtgMainId = C.CtgMainId
	
	UPDATE I SET I.Outlet = C.Outlet
	FROM #Institutions I (NOLOCK),
	#NoOfOutlet C (NOLOCK)
	WHERE I.InsId = C.InsId AND I.CtgMainId = C.CtgMainId
		
	INSERT INTO Cs2Cn_Prk_DebitNoteTopSheet3 (DistCode,ProgramCode,CtgCode,[Target],L2MSales,CurMSales,Outlet,DiscAmount,
	UploadFlag,SyncId,ServerDate,TargetMonth,TargetYear)
	SELECT @DistCode,U.InsRefNo,RC.CtgCode,[Target],L2MSales,CurMSales,Outlet,DiscAmount,
	'N' UploadFlag,NULL,@ServerDate,I.TargetMonth,I.TargetYear
	FROM #Institutions I (NOLOCK),
	#InstitutionToBeUpload U (NOLOCK),
	RetailerCategory RC (NOLOCK)
	WHERE I.InsId = U.InsId AND I.CtgMainId = RC.CtgMainId
	------------ Till Here ------------------
	--
	UPDATE S SET S.RptUpload = 1
	FROM UploadingReportTransaction U (NOLOCK),
	SalesInvoice S (NOLOCK) WHERE U.TransType = 1 AND U.TransId = S.SalId
	
	UPDATE S SET S.RptUpload = 1
	FROM UploadingReportTransaction U (NOLOCK),
	ReturnHeader S (NOLOCK) WHERE U.TransType = 2 AND U.TransId = S.ReturnID	
	
	RETURN			
END
GO
--Sync Changes
Update A Set  Setting = 1 from Tbl_syncConfiguration A Where Processname = 'ScriptUpdaterAfterDeploy'   
GO
Update A Set VersionId ='PV.2.8.0' from UtilityProcess A Where ProcessName ='Sync.Exe'
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SyncErrorDetails]') AND type in (N'U'))
DROP TABLE [dbo].[SyncErrorDetails]
GO
CREATE TABLE [dbo].[SyncErrorDetails](
	[Slno] [int] IDENTITY(1,1) NOT NULL,
	[Module] [varchar](200) NULL,
	[ProcessName] [varchar](100) NULL,
	[ErrorMsg] [varchar](max) NULL,
	[CreatedDate] [datetime] NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Console2CS_ConsolidatedDownload]') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Console2CS_ConsolidatedDownload
GO
/*
begin tran
delete from XML2CSPT_ErrorLog
exec Proc_Console2CS_ConsolidatedDownload
select * from XML2CSPT_ErrorLog
rollback tran
*/
CREATE PROCEDURE [dbo].[Proc_Console2CS_ConsolidatedDownload]
As
/*
**************************************************************************************************
* DATE       AUTHOR     CR/BZ USER STORY ID           DESCRIPTION                         
**************************************************************************************************
23/01/2018  Gowsalya S   Issue          ICONSWIP1888            SyncStatus has been updated as 1 for incomplete sync
*/
Begin  
BEGIN TRY    
SET XACT_ABORT ON    
BEGIN TRANSACTION
Declare @Lvar Int  
Declare @MaxId Int  
Declare @SqlStr Varchar(8000)  
Declare @Process Varchar(100)  
Declare @colcount Int  
Declare @Col Varchar(5000)  
Declare @Tablename Varchar(100)  
Declare @Sequenceno Int  
 Create Table #Col (ColId int)  
 CREATE TABLE #Console2CS_Consolidated  
 (  
  [SlNo] [numeric](38, 0) NULL, [DistCode] [VARCHAR](200) COLLATE Database_Default NULL, [SyncId] [numeric](38, 0) NULL,  
  [ProcessName] [VARCHAR](200) COLLATE Database_Default NULL, [ProcessDate] [datetime] NULL, 
  [Column1] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column2] [VARCHAR](200) COLLATE Database_Default NULL, [Column3] [VARCHAR](200) COLLATE Database_Default NULL, [Column4] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column5] [VARCHAR](200) COLLATE Database_Default NULL, [Column6] [VARCHAR](200) COLLATE Database_Default NULL, [Column7] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column8] [VARCHAR](200) COLLATE Database_Default NULL, [Column9] [VARCHAR](200) COLLATE Database_Default NULL, [Column10] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column11] [VARCHAR](200) COLLATE Database_Default NULL, [Column12] [VARCHAR](200) COLLATE Database_Default NULL, [Column13] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column14] [VARCHAR](200) COLLATE Database_Default NULL, [Column15] [VARCHAR](200) COLLATE Database_Default NULL, [Column16] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column17] [VARCHAR](200) COLLATE Database_Default NULL, [Column18] [VARCHAR](200) COLLATE Database_Default NULL, [Column19] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column20] [VARCHAR](200) COLLATE Database_Default NULL, [Column21] [VARCHAR](200) COLLATE Database_Default NULL, [Column22] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column23] [VARCHAR](200) COLLATE Database_Default NULL, [Column24] [VARCHAR](200) COLLATE Database_Default NULL, [Column25] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column26] [VARCHAR](200) COLLATE Database_Default NULL, [Column27] [VARCHAR](200) COLLATE Database_Default NULL, [Column28] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column29] [VARCHAR](200) COLLATE Database_Default NULL, [Column30] [VARCHAR](200) COLLATE Database_Default NULL, [Column31] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column32] [VARCHAR](200) COLLATE Database_Default NULL, [Column33] [VARCHAR](200) COLLATE Database_Default NULL, [Column34] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column35] [VARCHAR](200) COLLATE Database_Default NULL, [Column36] [VARCHAR](200) COLLATE Database_Default NULL, [Column37] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column38] [VARCHAR](200) COLLATE Database_Default NULL, [Column39] [VARCHAR](200) COLLATE Database_Default NULL, [Column40] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column41] [VARCHAR](200) COLLATE Database_Default NULL, [Column42] [VARCHAR](200) COLLATE Database_Default NULL, [Column43] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column44] [VARCHAR](200) COLLATE Database_Default NULL, [Column45] [VARCHAR](200) COLLATE Database_Default NULL, [Column46] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column47] [VARCHAR](200) COLLATE Database_Default NULL, [Column48] [VARCHAR](200) COLLATE Database_Default NULL, [Column49] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column50] [VARCHAR](200) COLLATE Database_Default NULL, [Column51] [VARCHAR](200) COLLATE Database_Default NULL, [Column52] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column53] [VARCHAR](200) COLLATE Database_Default NULL, [Column54] [VARCHAR](200) COLLATE Database_Default NULL, [Column55] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column56] [VARCHAR](200) COLLATE Database_Default NULL, [Column57] [VARCHAR](200) COLLATE Database_Default NULL, [Column58] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column59] [VARCHAR](200) COLLATE Database_Default NULL, [Column60] [VARCHAR](200) COLLATE Database_Default NULL, [Column61] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column62] [VARCHAR](200) COLLATE Database_Default NULL, [Column63] [VARCHAR](200) COLLATE Database_Default NULL, [Column64] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column65] [VARCHAR](200) COLLATE Database_Default NULL, [Column66] [VARCHAR](200) COLLATE Database_Default NULL, [Column67] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column68] [VARCHAR](200) COLLATE Database_Default NULL, [Column69] [VARCHAR](200) COLLATE Database_Default NULL, [Column70] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column71] [VARCHAR](200) COLLATE Database_Default NULL, [Column72] [VARCHAR](200) COLLATE Database_Default NULL, [Column73] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column74] [VARCHAR](200) COLLATE Database_Default NULL, [Column75] [VARCHAR](200) COLLATE Database_Default NULL, [Column76] [VARCHAR](200) COLLATE Database_Default NULL,   
  [Column77] [VARCHAR](200) COLLATE Database_Default NULL, [Column78] [VARCHAR](200) COLLATE Database_Default NULL, [Column79] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column80] [VARCHAR](200) COLLATE Database_Default NULL, [Column81] [VARCHAR](200) COLLATE Database_Default NULL, [Column82] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column83] [VARCHAR](200) COLLATE Database_Default NULL, [Column84] [VARCHAR](200) COLLATE Database_Default NULL, [Column85] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column86] [VARCHAR](200) COLLATE Database_Default NULL, [Column87] [VARCHAR](200) COLLATE Database_Default NULL, [Column88] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column89] [VARCHAR](200) COLLATE Database_Default NULL, [Column90] [VARCHAR](200) COLLATE Database_Default NULL, [Column91] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column92] [VARCHAR](200) COLLATE Database_Default NULL, [Column93] [VARCHAR](200) COLLATE Database_Default NULL, [Column94] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column95] [VARCHAR](200) COLLATE Database_Default NULL, [Column96] [VARCHAR](200) COLLATE Database_Default NULL, [Column97] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column98] [VARCHAR](200) COLLATE Database_Default NULL, [Column99] [VARCHAR](200) COLLATE Database_Default NULL, [Column100] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Remarks1] [VARCHAR](200) COLLATE Database_Default NULL, [Remarks2] [VARCHAR](200) COLLATE Database_Default NULL, [DownloadFlag] [VARCHAR](1) COLLATE Database_Default NULL,  
  DWNStatus INT
 )   
 INSERT INTO Console2CS_Consolidated_Trace 
 SELECT *,GETDATE() CREATEDATE from Console2CS_Consolidated A (Nolock) Where DownloadFlag='Y'
 DELETE FROM Console2CS_Consolidated_Trace where CONVERT (DATETIME,[Downloaded Date],121)<=Convert(DATETIME,GETDATE()-15,121)
 Delete A From Console2CS_Consolidated A (Nolock) Where DownloadFlag='Y' 
 ---------------------------------- added by Lakshman M on 03/01/2018 PMS ID: ICRSTPAR7277-----------
 	Create Table #SPLTBL (Id Int Identity(1,1),CId int,CName Varchar(200),CType Varchar(100))
	Insert into #SPLTBL
	Select A.column_id as CId,A.Name,C.name As CType From Sys.columns A (Nolock),Sys.objects B (Nolock),Sys.types C (Nolock) 
	where A.object_id = B.object_id and B.name = 'Console2CS_Consolidated'
	And A.system_type_id = C.system_type_id And C.name='varchar'
	Order by A.column_id 
	Declare @CName Varchar(100)
	Set @Lvar = 1
	Set @CName = ''
	Select @MaxId = IsNull(Count(CId),0) From #SPLTBL
	While @Lvar <= @MaxId
	Begin
		Select @CName = CName From #SPLTBL Where Id = @Lvar
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Console2CS_Consolidated  Set '+ @CName + ' = REPLACE(' + @CName + ','' amp;'',''&'')'
		exec (@SqlStr)
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Console2CS_Consolidated  Set '+ @CName + ' = REPLACE(' + @CName + ','' lt;'',''<'')'
		exec (@SqlStr)
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Console2CS_Consolidated  Set '+ @CName + ' = REPLACE(' + @CName + ','' gt;'',''>'')'
		exec (@SqlStr)
		Set @Lvar = @Lvar + 1
	End
 ----------------------------------
	
	SELECT Distinct DistCode, SyncId Into #IncompleteSync  FROM Console2CS_Consolidated (NOLOCK) WHERE DownloadFlag='N'  
	
	
	Select A.DistCode , A.SyncId , MAX(CreatedDate) CreatedDate Into #MaxDate
	 from SyncStatus_Download_Archieve A(Nolock), #IncompleteSync B
	Where A.DistCode = B.DistCode And A.SyncId = B.SyncId 
	Group by  A.DistCode , A.SyncId
	
	Update A Set SyncStatus =1 From
	SyncStatus_Download_Archieve A (Nolock) , 
	#MaxDate B
	Where A.DistCode = B.DistCode And A.Syncid = B.Syncid And A.CreatedDate = B.CreatedDate 
 ------------------------------------
	
 Insert Into #Console2CS_Consolidated  
 Select *,0 as DWNStatus from Console2CS_Consolidated (Nolock) Where DownloadFlag In ('D','N')
   Update A Set A.DWNStatus = 1  
   From  
    #Console2CS_Consolidated A (NOLOCK),  
    (  
     SELECT   
     DistCode,SyncId   
     FROM   
     SyncStatus_Download (NOLOCK)  
     WHERE       
     SyncStatus = 1 AND SyncId > 0  
     UNION  
     SELECT   
     DistCode,SyncId  
     FROM   
     SyncStatus_Download_Archieve (NOLOCK)  
     WHERE  
     SyncStatus = 1 AND SyncId > 0  
    ) B  
   Where   
    A.DistCode = B.DistCode AND   
    A.SyncId = B.SyncId   
-- Purchase trace starts here   
 Insert into Tbl_SchedulerInvoiceparle
 SELECT  DISTINCT SyncId,column2,DWNStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Purchase' And DWNStatus = 1   Union	
 SELECT  DISTINCT SyncId,column2+'-'+Column3+'-'+Column7+'-'+Column8+'-'+Column9+'-'+Column10,DwnStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Product Batch' And DWNStatus = 1 Union
 SELECT  DISTINCT SyncId,column26,DWNStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Product' And DWNStatus = 1  
 -- Purchase Trace Ends here
 Delete A From #Console2CS_Consolidated A (Nolock) Where DWNStatus = 0 
 Create Table #Process(ProcessName Varchar(100),PrkTableName Varchar(100), id Int Identity(1,1) )  
 Insert Into #Process(ProcessName , PrkTableName)   
 Select Distinct A.ProcessName , A.PrkTableName From Tbl_DownloadIntegration A,#Console2CS_Consolidated B   
 Where A.ProcessName = B.ProcessName And A.SequenceNo not in(100000) --Order By Sequenceno  
  Set @Lvar = 1  
  Select @MaxId = Max(id) From #Process  
  While @Lvar <= @MaxId  
   Begin  
    Select @Tablename = PrkTableName , @Process = ProcessName From #Process Where id  = @Lvar  
    Select @colcount = Count(Column_ID) From sys.columns Where object_id = (select object_id From sys.objects Where name = @Tablename)  
    Set @SqlStr = ''  
    Set @SqlStr = @SqlStr + ' Insert Into ' + @Tablename + ' '  
    Set @Col = ''  
    select @Col = @Col + '[' +name + '],' From sys.columns   
    where object_id = ( select object_id From sys.objects Where name = @Tablename) Order by Column_Id  
    Truncate Table #Col      
    Insert Into #Col     
    Select  a.column_id + 5 As ColId  
    From sys.columns a,sys.types b where a.user_type_id = b.user_type_id  
    and a.object_id = ( Select object_id From sys.objects Where name = @Tablename)  
    and b.name = 'datetime' --and a.name <> 'CreatedDate'  
    Set @SqlStr = @SqlStr + '(' + left(@Col,len(@Col)-1)  + ') '  
    Set @Col = ''  
    Select @Col = @Col + (Case when column_id In (Select ColId From #Col) then 'Convert(Datetime,'+name + ',121)' else name end) + ','   
    From sys.columns Where object_id = ( Select object_id From sys.objects Where name = 'Console2CS_Consolidated ')  
    and column_id  between 6 and 5 + @colcount 
    Order by column_id
    Set @SqlStr = @SqlStr + ' Select '+ left(@Col,len(@Col)-1)  + ' From #Console2CS_Consolidated (nolock) '  
    Set @SqlStr = @SqlStr + ' Where ProcessName = '''+ @Process +''' And DWNStatus = 1 '      
--    Print (@SqlStr) 
    Exec (@SqlStr)  
    Set @Lvar = @Lvar + 1  
   End  
-- Purchase trace starts here   
 Insert into Tbl_SchedulerInvoiceparle
 SELECT  DISTINCT SyncId,column2,DWNStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Purchase' And DWNStatus = 1   Union	
 SELECT  DISTINCT SyncId,column2+'-'+Column3+'-'+Column7+'-'+Column8+'-'+Column9+'-'+Column10,DwnStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Product Batch' And DWNStatus = 1 Union
 SELECT  DISTINCT SyncId,column26,DWNStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Product' And DWNStatus = 1  
  -- Purchase Trace Ends here
  Update A Set A.DownloadFlag = 'Y'   
   From   
    Console2CS_Consolidated A (nolock),  
    #Console2CS_Consolidated B (nolock)  
   Where   
    A.DistCode= B.DistCode And   
    A.SyncId = B.SyncId And   
    B.DWNStatus = 1  
   Update A Set A.SyncFlag = 1  
   From   
    Syncstatus_Download A (nolock),  
    #Console2CS_Consolidated B (nolock)  
   Where   
    A.DistCode= B.DistCode And   
    A.SyncId = B.SyncId And   
    B.DWNStatus = 1  
COMMIT TRANSACTION    
 END TRY    
 BEGIN CATCH    
  ROLLBACK TRANSACTION    
  INSERT INTO XML2CSPT_ErrorLog VALUES ('Proc_Console2CS_ConsolidatedDownload', ERROR_MESSAGE(), GETDATE())    
 END CATCH    
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE NAME='Proc_SyncValidation' AND TYPE='P')
DROP PROCEDURE Proc_SyncValidation
GO
CREATE PROCEDURE Proc_SyncValidation      
(              
@TypeId Int,              
@Code Varchar(100) = '', -- IP Address in Sync Attempt, DistCode in SyncStatus,              
@Val1 Numeric(18)=0, -- SubTypeId in SyncStatus,              
@Val2 Numeric(18)=0, -- SyncId in SyncStatus,              
@Val3 Numeric(18)=0, -- RecCnt in SyncStatus,              
@Val4 Varchar(100)='',              
@Val5 Varchar(100)='',              
@Val6 Varchar(100)='',
@Val7 Varchar(100)=''             
)              
As     
/*
***********************************************'**************************************************
* DATE			AUTHOR		CR/BZ		USER STORY ID           DESCRIPTION                         
**************************************************************************************************
* 16/07/2018   Gowsalya S   CR          ILCONSAML0906           Catch the SyncError in table level    
***************************************************************************************************
*/          
Begin    
--Added By Mohana  
BEGIN TRY          
BEGIN TRANSACTION  
--Till Here            
	
	Delete A From SyncErrorDetails A (Nolock) Where (Convert(Varchar(10),CreatedDate,121)) <= (Convert(Varchar(10),GETDATE()- 30,121))
  
 Declare @Sql Varchar(Max)            
 Declare @IntRetVal Int          
 IF @TypeId = 1 -- Distributor Code, Proc_SyncValidation  piTypeId              
 Begin              
  SELECT DistributorCode FROM Distributor WHERE Distributorid=1               
 End              
 IF @TypeId = 2 -- Upload And Download, Path Proc_SyncValidation  piTypeId              
 Begin              
  --SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44','DATATRANSFER45') AND ModuleName='DataTransfer' Order By ModuleId               
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44') AND ModuleName='DataTransfer'     
  Union       
  SELECT * FROM Configuration WHERE  ModuleName='DataTransfer' AND Description In ('Upload Path 2') Order By ModuleId     
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER45') AND ModuleName='DataTransfer'      
  Union          
  SELECT * FROM Configuration WHERE  ModuleName='DataTransfer' AND Description In ('Download Path 2') Order By ModuleId         
 End               
 IF @TypeId = 3 -- Sync Attempt Validation  Proc_SyncValidation  @TypeId,@Code              
 Begin              
  Declare @RetTemp Int          
  SET @RetTemp = 1          
  IF Not Exists (Select * From SyncStatus (Nolock) Where Syncid = (Select MAX(Syncid) From Sync_Master (Nolock)))          
  Begin          
 --SET @RetTemp = 0          
 IF Not Exists (Select * From SyncStatus (Nolock) Where SyncStatus = 1 And Syncid = (Select MAX(Syncid) -1 From Sync_Master (Nolock)))          
 Begin          
  SET @RetTemp = 0          
 End           
  End          
  IF (@RetTemp = 0)          
  Begin          
 Select 0          
 RETURN          
  End          
  IF Not Exists (Select * From CSyncStatus Where CONVERT(Varchar(10),CDate,121) = CONVERT(Varchar(10),GETDATE(),121) And SyncStatus = 1)          
 Begin          
  Truncate table CSyncStatus          
  Insert into CSyncStatus Select GETDATE(),0          
 End          
  Set @Code = (Select Top 1 HostName From Sys.sysprocesses where  status='RUNNABLE' Order By login_time desc)              
  IF ((SELECT Count(*) From SyncAttempt) < 1)              
   BEGIN              
 INSERT INTO SyncAttempt              
 SELECT @Code,1,Getdate()              
 SELECT 1              
   END               
  ELSE              
   BEGIN              
 IF (SELECT Status From SyncAttempt) = 0              
  BEGIN              
   UPDATE SyncAttempt SET IPAddress = @Code,Status = 1,StartTime = Getdate()               
   SELECT 1              
  END              
 ELSE              
  BEGIN              
   IF ((SELECT DatedIFf(hh,StartTime,Getdate()) From SyncAttempt) > 1)              
    BEGIN              
    UPDATE SyncAttempt SET IPAddress = @Code,Status = 1,StartTime = Getdate()               
    SELECT 1              
    END              
   ELSE              
  IF ((SELECT Count(*) From SyncAttempt WHERE IPAddress = @Code) = 1 )              
   BEGIN              
    UPDATE SyncAttempt SET Status = 1,StartTime = Getdate()               
    SELECT 1              
   END              
  ELSE              
   BEGIN              
    SELECT 0                       
   END              
  END              
   END                
 End              
 IF @TypeId = 4 -- Remove from Redownloadrequest,  Proc_SyncValidation   @TypeId              
 Begin              
  TRUNCATE TABLE ReDownLoadRequest              
 End              
 IF @TypeId = 5 -- Sync Process Validation,  Proc_SyncValidation   @TypeId,'',@Val1              
 Begin              
   IF @Val1 = 1               
   Begin              
 SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess='SyncProcess0' ORDER BY SyncProcess              
   End              
   IF @Val1 = 2               
   Begin              
 SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess<>'SyncProcess0' ORDER BY SyncProcess              
   End              
 End              
 IF @TypeId = 6 -- Sync Process Validation,  Proc_SyncValidation   @TypeId,'',@Val1              
 Begin              
  IF @Val1 = 1               
   Begin              
 SELECT DISTINCT SlNo,SlNo AS SeqNo,Module AS Process,TranType AS [Transaction Type],UpDownload AS [Exchange Type], 0 AS Count               
 FROM Customupdownload  ORDER BY  UpDownload Desc ,SlNo            
   End              
  IF @Val1 = 2               
   Begin              
 SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Upload'              
End              
  IF @Val1 = 3              
   Begin              
 SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Download'              
   End              
 End              
 IF @TypeId = 7 -- Sync Status Validation,  Proc_SyncValidation   @TypeId,@Code,@Val1,@Val2,@Val3              
 Begin              
  IF Exists(Select * from SyncStatus Where DistCode = @Code and SyncId = @Val2)                  
   Begin              
 IF @Val1 = 1                  
    Begin                  
   Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @Code and SyncId = @Val2                 
    End                  
 Else IF @Val1 = 2                  
  Begin                  
   Update SyncStatus Set DPEndTime = Getdate() where DistCode = @Code  and SyncId = @Val2                
  End              
 IF @Val1 = 3                  
  Begin                  
   Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @Code and SyncId = @Val2                 
  End                  
 Else IF @Val1 = 4                  
  Begin                  
   Update SyncStatus Set UpEndTime = Getdate() where DistCode = @Code and SyncId = @Val2                 
  End                  
 Else IF @Val1 = 5                  
  Begin                  
   Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @Code  and SyncId = @Val2                
  End                  
 Else IF @Val1 = 6                  
  Begin                  
   Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @Code and SyncId = @Val2                 
  End                  
 Else IF @Val1 = 7              
  Begin           
   IF @Val3 = 1              
    Begin              
  Update SyncStatus Set SyncStatus = 1 where DistCode = @Code and SyncId = @Val2                 
  Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @Code and SyncId = @Val2                   
    End              
    Else if @Val3 = 2-- Added on 2016-07-22          
    Begin           
   Update SyncStatus Set SyncStatus = 0 where DistCode = @Code and SyncId = @Val2            
   Update CS2Console_Consolidated Set UploadFlag = 'N' where DistCode = @Code and SyncId = @Val2            
    End          
  If (Select Count(1) from Tbl_syncConfiguration(Nolock) Where ProcessName ='SyncStatus Archieve' And Setting = 1) > 0        
  Begin         
   Insert into SyncStatus_History        
   Select *,GETDATE() As CreatedDate from SyncStatus (Nolock)        
  End           
  End                 
   End                  
  Else                  
   Begin                  
 Delete From SyncStatus Where DistCode = @Code and SyncStatus = 1            
 IF Not Exists (Select * From  SyncStatus (Nolock))          
 Begin            
  Insert into SyncStatus Select @Code,@Val2,Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),0,'N'          
 End          
 IF @Val1 = 1                  
    Begin                  
   Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @Code and SyncId = @Val2                 
    End                  
 Else IF @Val1 = 2                  
  Begin                  
   Update SyncStatus Set DPEndTime = Getdate() where DistCode = @Code  and SyncId = @Val2                
  End              
 IF @Val1 = 3                  
  Begin                  
   Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @Code and SyncId = @Val2                 
  End                  
 Else IF @Val1 = 4                  
  Begin                  
   Update SyncStatus Set UpEndTime = Getdate() where DistCode = @Code and SyncId = @Val2                 
  End                  
 Else IF @Val1 = 5                  
  Begin                  
   Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @Code  and SyncId = @Val2                
  End                  
 Else IF @Val1 = 6                  
  Begin                  
   Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @Code and SyncId = @Val2                 
  End                  
 Else IF @Val1 = 7              
  Begin                  
   IF @Val3 = 1              
    Begin              
  Update SyncStatus Set SyncStatus = 1 where DistCode = @Code and SyncId = @Val2                 
  Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @Code and SyncId = @Val2                   
    End           
    Else if @Val3 = 2-- Added on 2016-07-22          
    Begin           
   Update SyncStatus Set SyncStatus = 0 where DistCode = @Code and SyncId = @Val2            
   Update CS2Console_Consolidated Set UploadFlag = 'N' where DistCode = @Code and SyncId = @Val2            
    End          
  If (Select Count(1) from Tbl_syncConfiguration(Nolock) Where ProcessName ='SyncStatus Archieve' And Setting = 1) > 0        
  Begin         
   Insert into SyncStatus_History        
   Select *,GETDATE() As CreatedDate from SyncStatus (Nolock)        
  End             
  End                 
   End                
 End              
 IF @TypeId = 8 -- Select Current SyncId,  Proc_SyncValidation   @TypeId              
 Begin              
  Select IsNull(MAX(SyncId),0) From Sync_Master-- SyncStatus              
 End               
 IF @TypeId = 9 -- Select Syncstatus for this SyncId,  Proc_SyncValidation   @TypeId,@Code,@Val1              
 Begin              
  Select IsNull(Max(SyncStatus),0) From SyncStatus where DistCode = @Code And syncid = @Val1 And SyncStatus = 1              
 End                
 IF @TypeId = 10 -- DB Restoration Concept,  Proc_SyncValidation   @TypeId,'',@Val1              
 Begin              
  IF @Val1 = 1              
   Begin              
 Select Count(*) From DefendRestore              
   End               
  IF @Val1 = 2              
   Begin              
 update DefendRestore Set DbStatus = 1,ReqId = 1,CCLockStatus = 1              
   End                 
  IF @Val1 = 3              
   Begin              
 Insert into DefendRestore (AccessCode,LastModDate,DbStatus,ReqId,CCLockStatus)          
 Values('',GETDATE(),1,1,1)              
   End               
 End                 
 IF @TypeId = 11 -- AAD & Configuration Validation,  Proc_SyncValidation   @TypeId,'',@Val1              
 Begin              
  IF @Val1 = 1              
  Begin              
   SELECT * FROM Configuration WHERE ModuleId='BotreeSyncCheck'              
  End               
  IF @Val1 = 2              
  Begin              
   SELECT * FROM Configuration WHERE ModuleId LIKE 'BotreeSyncErrLog'              
  End                 
  IF @Val1 = 3              
  Begin              
   Select IsNull(Max(FixID),0) from Hotfixlog (NOLOCK)              
  End                 
 End                 
 IF @TypeId = 12 -- System Date is less than the Last Transaction Date Validation,  Proc_SyncValidation   @TypeId              
 Begin              
  SELECT ISNULL(MAX(TransDate),GETDATE()-1) AS TransDate FROM StockLedger              
 End               
 IF @TypeId = 13 -- DayEnd Process Updation,  Proc_SyncValidation   @TypeId,@Code              
 Begin              
  UPDATE DayEndProcess SET NextUpDate=@Code WHERE ProcId=13              
 End               
 IF @TypeId = 14 -- Update Sync Attempt Status ,  Proc_SyncValidation   @TypeId,@Code              
 Begin              
  Select @Code =  HostName From Sys.sysprocesses where  status='RUNNABLE'              
  Update SyncAttempt Set Status=0 where IPAddress = @Code              
 End                
 IF @TypeId = 15 -- Latest SyncId from Sync_Master ,  Proc_SyncValidation   @TypeId              
 Begin              
  --Select ISNull(Max(SyncId),0) From Sync_Master               
  IF Exists(Select * From SyncStatus (Nolock) Where SyncStatus = 1)          
  Begin          
   Select ISNull(Max(SyncId),0) From Sync_Master (Nolock)          
  End          
  Else          
  Begin          
   Select ISNull(Max(SyncId),0) From SyncStatus (Nolock)          
  End                  
 End               
 IF @TypeId = 16 -- Update the Flag as Y for all lesser than the latest Serial No ,  Proc_SyncValidation   @TypeId,@Code,@Val1,@Val2              
 Begin              
  IF ((Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @Code And SyncId = @Val1 And SlNo <= @Val2 And UploadFlag='N') > 0)                  
   Begin                  
 Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @Code and SyncId = @Val1 And SlNo >=             
 (Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @Code And SyncId = @Val1 And SlNo <= @Val2 And UploadFlag='N')                   
   End                  
   Else                  
   Begin                  
 Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @Code and SyncId = @Val1 And SlNo <= @Val2           
 Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @Code and SyncId = @Val1 And SlNo > @Val2              
   End           
 End                
 IF @TypeId = 17 -- Record Count ,  Proc_SyncValidation   @TypeId,@Code,@Val1,@Val2              
 Begin              
  IF @Val1 = 1               
  Begin              
   Select Count(*) From CS2Console_Consolidated where DistCode = @Code and syncid =@Val2 and UploadFlag = 'N'              
  End              
  IF @Val1 = 2               
  Begin              
   Select Count(Distinct Slno) From CS2Console_Consolidated where DistCode = @Code and syncid =@Val2               
  End                 
  IF @Val1 = 3               
  Begin              
   --Select IsNull(Count(*),0) From SyncStatus (Nolock) Where DistCode = @Code And SyncId = @Val2 And SyncFlag = 'Y'               
   Select IsNull(Count(Distinct Syncid),0) From SyncStatus (Nolock) Where DistCode = @Code And SyncId = @Val2 And SyncFlag = 'Y'               
  End              
 End                
 IF @TypeId = 18 -- Datapreperation Process and Split each 1000 rows for xml file ,  Proc_SyncValidation   @TypeId,@Code,@Val1,@Val2              
 Begin        IF @Val1 = 1               
  Begin              
   SELECT * FROM  CustomUpDownload  WHERE SlNo=@Val2  AND UpDownload='Upload' ORDER BY UpDownLoad,SlNo,SeqNo              
  End              
  IF @Val1 = 2               
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@Code) + ' WHERE UploadFlag=''N'''              
   Exec (@Sql)              
  End                 
  IF @Val1 = 3              
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM  ' + Convert(Varchar(100),@Code) + ' WHERE UploadFlag=''N'''              
   Exec (@Sql)              
  End                  
  IF @Val1 = 4              
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT * FROM  ' + Convert(Varchar(100),@Code) + ' WHERE SlNo= ' + Convert(Varchar(100),@Val2) + '  ORDER BY UpDownLoad,SlNo,SeqNo '              
   Exec (@Sql)              
  End                 
  IF @Val1 = 5              
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM   ' + Convert(Varchar(100),@Code) + '  '              
   Exec (@Sql)              
  End               
  IF @Val1 = 6              
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' DELETE  FROM   ' + Convert(Varchar(100),@Code) + ' WHERE Downloadflag = ''D'' '              
   Exec (@Sql)              
  End                 
  IF @Val1 = 7              
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT COUNT(*) FROM   ' + Convert(Varchar(100),@Code) + ' WHERE DownloadFlag = ''D'' '              
   Exec (@Sql)              
  End                 
  IF @Val1 = 8              
  Begin              
   Set @Sql = ''              
  Set @Sql = @Sql + ' SELECT TRowCount FROM Tbl_DownloadIntegration_Process WHERE PrkTableName =''' + Convert(Varchar(100),@Code) + ''' '              
   Exec (@Sql)              
  End                
  IF @Val1 = 9              
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = 0  WHERE ProcessName=''' + Convert(Varchar(100),@Code) + ''' '              
   Exec (@Sql)              
  End               
  IF @Val1 = 10              
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = ' + Convert(Varchar(100),@Val2) + ' where ProcessName=''' + Convert(Varchar(100),@Code) + ''' '              
   Exec (@Sql)              
  End                 
  IF @Val1 = 11               
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT ISNULL(MAX(SlNo),0) AS Cnt FROM ' + Convert(Varchar(100),@Code) + ' WHERE SyncId =' + Convert(Varchar(100),@Val2) + ' And UploadFlag=''N'''              
   Exec (@Sql)              
  End                 
  IF @Val1 = 12               
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM ' + Convert(Varchar(100),@Code) + ' WHERE SyncId =' + Convert(Varchar(100),@Val2) + ' And UploadFlag=''N'''              
   Exec (@Sql)              
  End                
  IF @Val1 = 13               
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@Code) + ' WHERE SyncId =' + Convert(Varchar(100),@Val2) + ' And UploadFlag=''N'' '              
   Exec (@Sql)              
  End                
  IF @Val1 = 14               
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM ' + Convert(Varchar(100),@Code) + ' WHERE UpDownload=''Upload'' '              
   Exec (@Sql)              
  End                   
  IF @Val1 = 15               
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS DownloadCount FROM ' + Convert(Varchar(100),@Code) + ' WHERE UpDownload=''Download'' '              
   Exec (@Sql)              
  End               
  IF @Val1 = 16               
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus (nolock) Where DistCode =''' + Convert(Varchar(100),@Code) + ''' And  SyncStatus = 0 '              
   Exec (@Sql)              
  End               
  IF @Val1 = 17               
  Begin              
   Set @Sql = ''              
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus_Download (nolock) Where DistCode =''' + Convert(Varchar(100),@Code) + ''''-- And  SyncStatus = 0 '              
   Exec (@Sql)              
  End               
  IF @Val1 = 18          
 Begin          
  Set @Sql = ''          
  Set @Sql = @Sql + ' SELECT * FROM ' + Convert(Varchar(100),@Code) + ' As DU WHERE UploadFlag=''N'' AND SlNo BETWEEN  '          
  Set @Sql = @Sql + '  ' + Convert(Varchar(100),@Val2) + ' And ' + Convert(Varchar(100),@Val3) + ' ORDER BY SlNo  ' --FOR XML AUTO '          
  Select @Sql          
 End           
  IF @Val1 = 19          
 Begin          
  Set @Sql = ''          
  Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@Code) + ' SET UploadFlag=''X'' WHERE UploadFlag=''N'' AND SlNo BETWEEN '          
  Set @Sql = @Sql + '  ' + Convert(Varchar(100),@Val2) + ' And ' + Convert(Varchar(100),@Val3) + ' '          
  Exec (@Sql)          
 End     
  IF @Val1 = 20          
 Begin          
  Set @Sql = ''          
  Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@Code) + ' SET UploadFlag=''Y'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '          
  Set @Sql = @Sql + '  ' + Convert(Varchar(100),@Val2) + ' And ' + Convert(Varchar(100),@Val3) + ' '          
  Exec (@Sql)          
 End           
  IF @Val1 = 21          
 Begin          
  Set @Sql = ''          
  Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@Code) + ' SET UploadFlag=''N'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '          
  Set @Sql = @Sql + '  ' + Convert(Varchar(100),@Val2) + ' And ' + Convert(Varchar(100),@Val3) + ' '          
  Exec (@Sql)          
 End             
  IF @Val1 = 22          
 Begin          
 SET @Sql = ''              
 SET @Sql = @Sql + ' SELECT COUNT(SlNo) AS SlNo FROM ' + Convert(VARCHAR(100),@Code) + ' WHERE UploadFlag=''Y'' And  SyncId =' + Convert(VARCHAR(100),@Val2) + ' '              
 --Exec (@Sql)            
 --SET @Sql = ''              
 SET @Sql = @Sql + 'UNION ALL SELECT COUNT(SlNo) AS SlNo FROM ' + Convert(VARCHAR(100),@Code) + ' WHERE SyncId =' + Convert(VARCHAR(100),@Val2) + ' '              
 Exec (@Sql)               
 End             
  IF @Val1 = 23          
 Begin          
 SET @Sql = ''              
 --SET @Sql = @Sql + ' SELECT COUNT(SlNo) AS SlNo FROM ' + Convert(VARCHAR(100),@Code) + ' WHERE SyncId =' + Convert(VARCHAR(100),@Val2) + ' '              
 --Added on 2018-01-09  
 SET @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS SlNo FROM ' + Convert(VARCHAR(100),@Code) + ' WHERE SyncId =' + Convert(VARCHAR(100),@Val2) + ' '              
 Exec (@Sql)              
 End            
 IF @Val1 = 24          
 Begin          
 SET @Sql = ''              
 SET @Sql = @Sql + ' SELECT COUNT(DistCode) AS SlNo FROM ' + Convert(VARCHAR(100),@Code) + ' '          
 Exec (@Sql)               
 End           
 End                
 IF @TypeId = 19 -- View Error Log Details ,  Proc_SyncValidation   @TypeId              
 Begin              
  SELECT * FROM ErrorLog WITH (NOLOCK)              
 End              
 IF @TypeId = 20 -- Remove Error Log Details ,  Proc_SyncValidation   @TypeId              
 Begin               
  DELETE FROM ErrorLog               
 End               
 IF @TypeId = 21 -- Download Notification Details Error Log Details ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT * FROM  CustomUpDownloadCount WHERE UpDownload='Download' ORDER BY SlNo              
 End               
 IF @TypeId = 22 -- Download Details to xml file ,  Proc_SyncValidation   @TypeId              
Begin               
  SELECT * FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='N'              
 End               
 IF @TypeId = 23 -- Download Integration Details  ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT * FROM Tbl_DownloadIntegration_Process ORDER BY SequenceNo              
 End               
 IF @TypeId = 24 -- Reset TRow Count  ,  Proc_SyncValidation   @TypeId              
 Begin               
  UPDATE Tbl_DownloadIntegration_Process SET TRowCount=0              
 End                
 IF @TypeId = 25 -- Download Process   ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT PrkTableName,SPName FROM Tbl_DownloadIntegration_Process WHERE ProcessName = @Code              
 End                
 IF @TypeId = 26 -- Upload Consolidated Process   ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT * FROM Tbl_UploadIntegration_Process ORDER BY SequenceNo              
 End                
 IF @TypeId = 27 -- Download Details   ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT DISTINCT Module,DownloadedCount FROM CustomUpDownloadCount WHERE UpDownload='Download' AND DownloadedCount>0              
 End                
 IF @TypeId = 28 -- ReDownload Request   ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT * FROM Configuration WHERE ModuleId='BotreeReDownload'              
 End               
 IF @TypeId = 29 -- ReDownload Request   ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT * FROM ReDownLoadRequest             
 End               
 IF @TypeId = 30 -- Showboard    ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT * FROM Configuration WHERE ModuleId='BotreeBBOardOnSync' AND Status=1              
 End               
 IF @TypeId = 31 -- Update sync status if disconnect    ,  Proc_SyncValidation   @TypeId,@Code,@Val1              
 Begin               
  IF Not Exists (Select * From CS2Console_Consolidated (nolock) Where DistCode = @Code And Syncid = @Val1 And UploadFlag='N')              
  Begin              
   Update Syncstatus Set Syncstatus = 1 Where DistCode = @Code And Syncid = @Val1              
   Select IsNull(Max(SyncStatus),0) From SyncStatus (nolock) Where DistCode = @Code And Syncid = @Val1              
  End              
 End               
 IF @TypeId = 32 -- Update sync status if disconnect,Proc_SyncValidation @TypeId,@Code,@Val1              
 Begin               
  Declare @RETVAL Varchar(Max)              
  Set @RETVAL = ''              
  IF EXISTS (Select * From Chk_MainSalesIMEIUploadCnt (NOLOCK))              
  Begin                
  Select @RETVAL = Cast(COALESCE(@RETVAL + ', ', '') + Convert(Varchar(40),MainTblBillNo) as ntext) From Chk_MainSalesIMEIUploadCnt                 
  Select @RETVAL              
  End              
 End              
 IF @TypeId = 33 -- Update DB Restore request status  ,  Proc_SyncValidation   @TypeId                
 Begin                 
   Select 'Request given for approval so please approve from Central Help Desk.'                
 End                
 IF @TypeId = 34 -- Update DB Restore request status  ,  Proc_SyncValidation   @TypeId                
 Begin                 
   Select IsNull(LTrim(RTrim(CmpCode)),'') From Company (Nolock) Where DefaultCompany = 1                
 End                
 IF @TypeId = 35 -- Select Download Sync status  ,  Proc_SyncValidation   @TypeId,@Code,@Val1              
 Begin                 
  Select IsNull(SyncStatus,0) from Syncstatus_Download (nolock) Where Distcode = @Code and Syncid = @Val1              
 End                
 IF @TypeId = 36 -- Select Max(Syncid) in Download Sync Status  ,  Proc_SyncValidation   @TypeId                
 Begin                 
  Select IsNull(Max(SyncId),0) From SyncStatus_Download (Nolock)              
 End                
 IF @TypeId = 37 -- Select Max(SlNo) in Console2CS_Consolidated  ,  Proc_SyncValidation   @TypeId                
 Begin                 
  Select IsNull(Max(SlNo),0) From Console2CS_Consolidated (Nolock) Where Distcode = @Code and Syncid = @Val1              
 End                 
 IF @TypeId = 38 -- Syncstatus  ,  Proc_SyncValidation   @TypeId,@Code,@Val1,@Val2              
 Begin              
 Declare @RetState Int              
 Update CSyncStatus Set SyncStatus = 1 Where CONVERT(Varchar(10),CDate,121) = CONVERT(Varchar(10),GETDATE(),121) And SyncStatus = 0          
 IF Exists (Select * From SyncStatus (Nolock) where DistCode = @Code And syncid = @Val1 And SyncStatus = 1)              
  Begin              
 If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0          
  Begin          
  IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @Code And syncid = @Val2 And SyncStatus = 1)              
   Begin              
 Set @RetState = 1 -- Upload and Download Completed Successfully                  
   End              
  Else              
   Begin              
 Set @RetState = 2 -- Upload Completed, Download Incomplete               
   End              
  End          
 Else          
  Begin          
  Set @RetState = 1 -- Upload and Download Completed Successfully           
  End          
  End              
  Else              
  Begin              
   If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0          
  Begin          
 IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @Code And syncid = @Val2 And SyncStatus = 1)              
   Begin              
 Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully                    
   End              
  Else              
   Begin              
 Set @RetState = 4 -- Upload and Download Incomplete!!!                     
   End              
  End          
 Else          
  Begin          
  Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully           
  End          
  End              
  Select @RetState              
 End                 
 IF @TypeId = 39 -- Update Download Sync Status  ,  Proc_SyncValidation   @TypeId,@Code,@Val1,@Val2,@Val3                
 Begin                 
 -------              
  IF Exists(SELECT * FROM SyncStatus_Download WHERE DistCode = @Code and SyncId = @Val2)                          
   Begin              
 IF @Val1 = 1                          
 Begin                        
 If Exists (Select * from SyncStatus_Download(Nolock)  Where DistCode = @Code and SyncId = @Val2 And SyncStatus =1 And SyncFlag =0) --Added on 2016-10-04                 
 Begin        
  IF Exists(SELECT * FROM Console2CS_Consolidated (NOLOCK) WHERE DistCode = @Code and SyncId = @Val2 And DownloadFlag Not in ('N','D'))  --Added on 2016-07-25                 
  Begin                  
   DELETE A FROM Console2CS_Consolidated A (NOLOCK)  WHERE DistCode = @Code and SyncId = @Val2 And DownloadFlag ='Y'                  
  End         
   End                
   else         
   Begin        
  DELETE A FROM Console2CS_Consolidated A (NOLOCK)  WHERE DistCode = @Code and SyncId = @Val2            
   End           
  --Update SyncStatus_Download Set SyncStatus=0,SyncFlag=0 Where DistCode = @Code and SyncId = @Val2   -- Added to Parameter S                 
  UPDATE SyncStatus_Download SET DwnStartTime = Getdate(),DwnEndTime = Getdate() WHERE DistCode = @Code  and SyncId = @Val2                        
 End                          
 IF @Val1 = 2                          
  Begin                          
 UPDATE SyncStatus_Download SET DwnEndTime = Getdate() WHERE DistCode = @Code and SyncId = @Val2                         
  End                      
 IF @Val1 = 3                          
  Begin                          
  --IF (@Val3 = (SELECT COUNT(Distinct SlNo) FROM Console2CS_Consolidated (NOLOCK) WHERE DistCode = @Code and SyncId = @Val2 And DownloadFlag='N'))                    
  IF (@Val3 = 1)                    
   Begin                    
 UPDATE SyncStatus_Download SET SyncStatus = 1 WHERE DistCode = @Code and SyncId = @Val2                       
   End                   
  Else                
   Begin                    
  If @Val3 > 0 -- Added on 2016-07-25          
  Begin                
   DELETE A FROM Console2CS_Consolidated A (NOLOCK)  WHERE DistCode = @Code and SyncId = @Val2             
  End                     
   End                  
  End                       
   End                          
  Else                          
   Begin                          
 INSERT INTO SyncStatus_Download_Archieve  SELECT *,Getdate() FROM SyncStatus_Download WHERE DistCode = @Code                     
 DELETE FROM SyncStatus_Download WHERE DistCode = @Code            
  --  INSERT INTO SyncStatus_Download SELECT @Code,@Val2,Getdate(),Getdate(),0,0          
 -----------Added on 2016-07-25-------------          
 if  @Val3 = 0          
 Begin          
  Insert into SyncStatus_Download Select @Code,@Val2,Getdate(),Getdate(),1,1                          
 End          
 Else          
 Begin                      
  Insert into SyncStatus_Download Select @Code,@Val2,Getdate(),Getdate(),0,0                          
 End            
 -----------Added on 2016-07-25-------------            
 INSERT INTO SyncStatus_Download_Archieve SELECT @Code,@Val2,Getdate(),Getdate(),0,0,GETDATE()                           
 IF @Val1 = 1                          
 Begin                          
 UPDATE SyncStatus_Download SET DwnStartTime = Getdate(),DwnEndTime = Getdate() WHERE DistCode = @Code  and SyncId = @Val2                        
 End                          
 IF @Val1 = 2                          
  Begin                          
 UPDATE SyncStatus_Download SET DwnEndTime = Getdate() WHERE DistCode = @Code and SyncId = @Val2                         
  End                      
 IF @Val1 = 3                          
  Begin                          
--     IF (@Val3 = (SELECT COUNT(Distinct SlNo) FROM Console2CS_Consolidated (NOLOCK) WHERE DistCode = @Code and SyncId = @Val2 And DownloadFlag='N'))                    
  IF (@Val3 = 1)          
   Begin                    
 UPDATE SyncStatus_Download SET SyncStatus = 1 WHERE DistCode = @Code and SyncId = @Val2                       
   End                   
  Else                
   Begin           
    IF @Val3 > 0 -- Added on 2016-07-25          
  BEGIN                    
   DELETE A FROM Console2CS_Consolidated A (NOLOCK) WHERE DistCode = @Code and SyncId = @Val2                       
  END           
   End                   
  End                       
   End                
 ------              
 END          
  IF @TypeId = 40 -- Download Integration Details  ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT * FROM Tbl_Customdownloadintegration ORDER BY SequenceNo              
 End               
 IF @TypeId = 41 -- Reset TRow Count  ,  Proc_SyncValidation   @TypeId              
 Begin               
  UPDATE Tbl_Customdownloadintegration SET TRowCount=0              
 End           
 IF @TypeId = 42 -- Download Process   ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT PrkTableName,SPName FROM Tbl_Downloadintegration WHERE ProcessName = @Code              
 End           
 IF @TypeId = 43 -- Download Process   ,  Proc_SyncValidation   @TypeId              
 Begin               
  SELECT TRowCount FROM Tbl_Customdownloadintegration WHERE PrkTableName = @Code              
 End           
 IF @TypeId = 44 -- Download Process   ,  Proc_SyncValidation   @TypeId       
 Begin               
  Update Tbl_Customdownloadintegration Set TRowCount = @Val1 WHERE ProcessName = @Code              
 End           
 IF @TypeId = 45 -- Update DB Restore request status  ,  Proc_SyncValidation   @TypeId            
 Begin             
 Set @IntRetVal = 0            
 IF @Val1 = 1          
 Begin          
  If Exists (Select * From sys.Objects where TYPE='U' and name ='UtilityProcess')            
   Begin            
 IF Exists (Select * from UtilityProcess where ProcId = 3)            
 Begin            
  IF ((Select Convert(Varchar(100),VersionId) from UtilityProcess where ProcId = 3) <> @Code)            
  Begin            
   Set @IntRetVal = 1                
  End               
 End            
   End            
 End             
 IF @Val1 = 2          
 Begin          
  If Not Exists (Select * From AppTitle (Nolock) Where  SynVersion = @Code)            
   Begin            
   Set @IntRetVal = 1          
   End          
 End          
 Select @IntRetVal           
 End             
 IF @TypeId = 46 -- Data Purge  ,  Proc_SyncValidation   @TypeId            
 Begin            
 Set @IntRetVal = 1          
 IF Exists (Select * From Sys.objects Where name = 'DataPurgeDetails' and TYPE='U')          
 Begin          
  IF EXISTS (Select * From DataPurgeDetails)          
  Begin          
   Set @IntRetVal = 0          
  End          
 End          
 Select @IntRetVal           
 End          
 IF @TypeId = 47 -- Update In Active Distributor  ,  Proc_SyncValidation   @TypeId            
 Begin            
 Set @IntRetVal = 1          
 --IF Exists (Select * From Sys.objects Where name = 'Distributor' and TYPE='U')          
 --Begin          
 -- Update Distributor Set DistStatus = 0 Where DistributorCode = @Code          
 --End          
 End          
 IF @TypeId = 48 -- Unregistered Database  ,  Proc_SyncValidation   @TypeId            
 Begin            
 Set @IntRetVal = 0          
 IF Not Exists (Select * From SyncStatus (Nolock))          
 Begin          
  Set @IntRetVal = 1 -- Unregistered Database          
 End          
 Else          
 Begin          
  IF Exists (Select * From SyncStatus (Nolock) Where DistCode Is Null or DistCode = '')          
  Begin          
   Set @IntRetVal = 2 -- Distributor Code is not found          
  End          
 End          
 IF (@IntRetVal > 0)          
 Begin          
  Select @IntRetVal          
  RETURN          
 End          
 IF Not Exists (Select * from SyncStatus (Nolock) where SyncId = 0)          
 Begin          
  IF Not Exists (Select * From SyncStatus (Nolock) Where Syncid = (Select MAX(Syncid) From Sync_Master (Nolock)))          
  Begin          
   IF Not Exists (Select * From SyncStatus (Nolock) Where SyncStatus = 1 And Syncid = (Select MAX(Syncid) -1 From Sync_Master (Nolock)))          
   Begin          
 SET @IntRetVal = 3            
   End          
  End          
 End          
 Else          
 Begin          
  SET @IntRetVal = 4          
 End          
 Select @IntRetVal           
 End          
 IF @TypeId = 49 -- DB Restoration  ,  Proc_SyncValidation   @TypeId            
 Begin            
 Set @IntRetVal = 0           
 --If Exists (Select * From Cs2Cn_Prk_DBUnlockDetails (Nolock) Where DistCode = @Code And DBUnlockStatus > 0)          
 --Begin          
 -- Set @IntRetVal = 1          
 --End          
 If Exists (Select * From DefendRestore (Nolock) Where ReqId > 0)          
 Begin          
  Set @IntRetVal = 1          
 End           
 Select @IntRetVal          
 End           
 IF @TypeId = 50 -- Upload And Download, Path Proc_SyncValidation  piTypeId              
 BEGIN              
  --SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44','DATATRANSFER47') AND ModuleName='DataTransfer' And Description ='Upload Path'  Order By ModuleId             
  --SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER45','DATATRANSFER48') AND ModuleName='DataTransfer' And Description ='Download Path'  Order By ModuleId               
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44') AND ModuleName='DataTransfer'  And Description ='Upload Path'     
  Union       
  SELECT * FROM Configuration WHERE  ModuleName='DataTransfer' AND Description In ('Upload Path 2') Order By ModuleId     
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER45') AND ModuleName='DataTransfer'  And Description ='Download Path'     
  Union          
  SELECT * FROM Configuration WHERE  ModuleName='DataTransfer' AND Description In ('Download Path 2') Order By ModuleId     
 END           
 IF @TypeId = 51 -- Update In Active Distributor  ,  Proc_SyncValidation   @TypeId            
 Begin            
 Select * From Tbl_UploadIntegration_Process (Nolock) Where ProcessName='DB_Restore'          
 End          
 IF @TypeId = 52 -- Update In Active Distributor  ,  Proc_SyncValidation   @TypeId            
 Begin            
 Set @Sql = ''          
 Set @Sql = @Sql + ' SELECT * FROM ' + Convert(Varchar(100),@Code) + ' As DU WHERE UploadFlag=''N'' AND SlNo BETWEEN  '          
 Set @Sql = @Sql + '  ' + Convert(Varchar(100),@Val2) + ' And ' + Convert(Varchar(100),@Val3) + ' ORDER BY SlNo  ' --FOR XML AUTO '          
 Print (@Sql)          
 Exec (@Sql)          
 End           
 IF @TypeId = 53 -- Update In Active Distributor  ,  Proc_SyncValidation   @TypeId            
 Begin            
 Select * From Tbl_DownloadIntegration_Process (Nolock) Where ProcessName='DB_Restore'          
 End           
 IF @TypeId = 54   -- Added on 2016-07-23 for Partial data upload             
 Begin                    
 IF @Val1 = 1                       
 Begin                      
  Select Count(1) From CS2Console_Consolidated where DistCode = @Code and syncid =@Val2               
 End                      
 IF @Val1 = 2              
 Begin                      
  Update  A Set UploadFlag='N' From CS2Console_Consolidated A (Nolock)  Where DistCode = @Code and SyncId = @Val2                                
 End         
  IF @Val1 = 3              
 Begin                
 Update SyncStatus Set SyncStatus = 0, SyncFlag ='N' where DistCode = @Code and SyncId = @Val2                      
  Update  A Set UploadFlag='N' From CS2Console_Consolidated A (Nolock)  Where DistCode = @Code and SyncId = @Val2                                
 End               
 End            
 IF @TypeId = 55   -- Added on 2016-08-31 for Auto Quick Sync           
 Begin              
 Select Distinct Setting from Tbl_syncConfiguration Where Processname = 'AutoQuickSync'          
 End          
 IF @TypeId = 56   -- Added on 2016-08-31 for SyncExe Minimized Mode            
 Begin              
 Select Distinct Setting from Tbl_syncConfiguration Where Processname = 'SyncExeMinimized'          
 End       
 IF @TypeId = 57   -- Added on 2016-08-31 for SuccessMsgShow          
 Begin              
 Select Distinct Setting from Tbl_syncConfiguration Where Processname = 'SuccessMsgShow'          
 End          
  IF @TypeId = 58        
 Begin              
 Select Distinct Setting from Tbl_syncConfiguration Where Processname = 'PartialUploadDataDelete'          
 End          
 IF @TypeId = 59         
 Begin              
 Select Distinct Setting from Tbl_syncConfiguration Where Processname = 'ScriptUpdaterAfterDeploy'          
 End      
 IF @TypeId = 60   -- Added on 2017-09-12 for MultiIntegrationPath          
 Begin              
 Select Distinct Setting from Tbl_syncConfiguration Where Processname = 'HotFixMsg'          
 End    
IF @TypeId = 61              
Begin                  
 Select Distinct Setting from Tbl_syncConfiguration Where Processname = 'ScriptUpdaterHotfixId'              
End    
IF @TypeId = 62       
Begin                  
 SELECT IsNull(Max(FixID),0) FROM Hotfixlog (NOLOCK) WHERE fixid < 1000      
End    
IF @TypeId = 63              
Begin       
 IF @Val1 = 1     
 Begin                
  Select Distinct Setting from Tbl_syncConfiguration Where Processname = 'SyncVersionInUI'         
 End    
 IF @Val1 = 2    
 Begin              
  If Exists (Select * From sys.Objects where TYPE='U' and name ='UtilityProcess')                
  Begin     
   IF Exists (Select * from UtilityProcess where ProcId = 3)                
   Begin                
    Select ISNULL(Versionid,'') from UtilityProcess where ProcId = 3    
   End    
  End    
 End                  
End  
  
IF @TypeId = 64  
Begin  
 Insert into SyncErrorDetails    
 (  
  Module, 	
  ProcessName,  
  ErrorMsg,  
  CreatedDate,  
  ServerDate  
 )   
 Values   
 (  
  @Val4,  
  @Val5, 
  @Val6, 
  GetDate(),  
  CONVERT(DateTime, @Val7, 121)  
 )  
     
End  
COMMIT TRANSACTION          
END TRY          
BEGIN CATCH          
ROLLBACK TRANSACTION       
INSERT INTO Sync_ErrorLog VALUES ('Proc_SyncValidation', ERROR_MESSAGE(), GETDATE())             
END CATCH          
--till Here  
----------Additional Validation----------              
END
GO
--Sync Till Here
UPDATE UtilityProcess SET VersionId = '3.1.0.13' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.13',436
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 436)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(436,'D','2018-08-01',GETDATE(),1,'Core Stocky Service Pack 436')
GO