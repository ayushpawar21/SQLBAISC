--[Stocky HotFix Version]=410
DELETE FROM Versioncontrol WHERE Hotfixid='410'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('410','3.1.0.0','D','2013-11-27','2013-11-27','2013-11-27',CONVERT(VARCHAR(11),GETDATE()),'PARLE-Major: Product Release Dec CR')
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='CN2CS_Prk_JcMonthEndOpen')
DROP TABLE CN2CS_Prk_JcMonthEndOpen
GO
CREATE TABLE [CN2CS_Prk_JcMonthEndOpen](
	DistCode Varchar(50),
	JcmId INT,
	JcmJc INT,		
	JcmYr NUMERIC(36,0),
	JcmSdt DATETIME,
	JcmEdt DATETIME,
	DownloadFlag Varchar(2)
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='CS2CN_Prk_JcMonthEndClosingDt')
DROP TABLE CS2CN_Prk_JcMonthEndClosingDt
GO
CREATE TABLE [CS2CN_Prk_JcMonthEndClosingDt](
	[SlNo] Numeric (38,0) IDENTITY (1,1),
	[DistCode] Varchar(50),
	JcmId INT,
	JcmJc INT,		
	JcmYr NUMERIC(36,0),
	JcmSdt DATETIME,
	JcmEdt DATETIME,
	JcmMontEnddate DATETIME,
	UploadFlag  Nvarchar(1),
	SyncId Numeric(36,0),
	ServerDate Datetime
)
GO
UPDATE DayEndDates Set Status=1 WHERE DayEndStartDate<=(SELECT CONVERT(Varchar(10),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, MAX(transdate)),0)),121) FROM StockLedger)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CS2CNJcMonthEndClosingDt')
DROP PROCEDURE Proc_CS2CNJcMonthEndClosingDt
GO
CREATE	PROCEDURE [Proc_CS2CNJcMonthEndClosingDt]
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)	
AS
/*********************************
* PROCEDURE	: Proc_CS2CNJcMonthEndClosingDt
* PURPOSE	: To Upload Jc Month end Details
* CREATED	: Murugan.R
* CREATED DATE	: 27/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0
	DECLARE @DistCode	As nVarchar(50)
	
	SELECT @DistCode = DistributorCode FROM Distributor
	
	DELETE FROM CS2CN_Prk_JcMonthEndClosingDt WHERE UploadFlag='Y'
	
	INSERT INTO CS2CN_Prk_JcMonthEndClosingDt(DistCode,JcmId,JcmJc,JcmYr,JcmSdt,JcmEdt,JcmMontEnddate,UploadFlag,SyncId,ServerDate)
	SELECT @DistCode,J.JcmId,J.JcmJc,JcmYr,J.JcmSdt,J.JcmEdt,J.JcmMontEnddate,'N' ,0,@ServerDate
	FROM jcmonthend J INNER JOIN JCMonth JC ON J.JcmJc=JC.JcmJc
	INNER JOIN JCMast JM ON J.JcmId=Jm.JcmId and Jc.JcmId=JM.JcmId
	WHERE Status=1 and Upload=0
	
	UPDATE jcmonthend SET Upload=1 WHERE  Status=1 and Upload=0
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CN2CSJcMonthEndOpen')
DROP PROCEDURE Proc_CN2CSJcMonthEndOpen
GO
CREATE	PROCEDURE Proc_CN2CSJcMonthEndOpen
(
	@Po_ErrNo INT OUTPUT
)	
AS
/*********************************
* PROCEDURE	: Proc_CN2CSJcMonthEndOpen
* PURPOSE	: To download to open Jc montend
* CREATED	: Murugan.R
* CREATED DATE	: 17/10/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0	
	DECLARE @MaxTransdate as DateTime
	DECLARE @JcmEdt as DateTime
	DECLARE @JcmSdt as DateTime

	DELETE FROM CN2CS_Prk_JcMonthEndOpen WHERE DownloadFlag='Y'
	
	SELECT @MaxTransdate=MAX(Transdate) FROM StockLedger (NOLOCK)
	
	SELECT TOP 1 @JcmEdt=JcmEdt,@JcmSdt=JcmSdt FROM  CN2CS_Prk_JcMonthEndOpen WHERE DownloadFlag='D'
	
	IF @MaxTransdate<=@JcmEdt
	BEGIN
		Update DayEndDates Set Status=0 WHERE DayEndStartDate >=@JcmSdt
		Update JCMonthEnd Set Status=0 WHERE JcmSdt>=@JcmSdt
		DELETE FROM MonthEndClosing WHERE StkMonth=DateName(Month,@JcmSdt) and StkYear=YEAR(@JcmSdt)		
	END
	UPDATE CN2CS_Prk_JcMonthEndOpen SET DownloadFlag='Y'
END
--Till Here Murugan Sir
GO
DELETE FROM RptSelectionHD WHERE SelcId=289
INSERT INTO RptSelectionHD([SelcId],[SelcName],[TblName],[Condition]) VALUES (289,'Sel_Bill Status','RptFilter',1)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='FN' AND name='Fn_ReturnRptFiltersValue')
DROP FUNCTION Fn_ReturnRptFiltersValue
GO
CREATE FUNCTION Fn_ReturnRptFiltersValue
(
	@iRptid INT,
	@iSelid INT,
	@iUsrId INT
)
RETURNS nVarChar(1000)
AS
/*********************************
* FUNCTION: Fn_ReturnRptFiltersValue
* PURPOSE: Returns the Filters Value For the Selected Report and Selection Id
* NOTES: 
* CREATED: Thrinath Kola	31-07-2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
*********************************/
BEGIN
	DECLARE @iCnt 		AS	INT
	DECLARE @SCnt 		AS      NVARCHAR(1000)
	DECLARE	@ReturnValue	AS	nVarchar(1000)
	DECLARE @iRtr 		AS	INT
	SELECT @iCnt = Count(*) FROM ReportFilterDt WHERE Rptid= @iRptid AND
	SelId = @iSelid AND usrid = @iUsrId
	IF @iCnt > 1
	BEGIN
		IF @iSelid=3 AND ( @iRptid=1 OR @iRptid=2 OR @iRptid=3 OR @iRptid=4 OR @iRptid=9 OR @iRptid=17 OR @iRptid=18
		OR @iRptid=19 OR @iRptid=30 OR @iRptid=12 ) 
		BEGIN
			SELECT @iRtr=SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
			SelId = 215 AND Usrid = @iUsrId
			IF @iRtr>0 
			BEGIN
				SELECT @iRtr=COUNT(*) FROM ReportFilterDt WHERE Rptid= @iRptid AND
				SelId = @iSelid AND Usrid = @iUsrId AND SelValue  IN
				(SELECT SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
				SelId = 215 AND Usrid = @iUsrId
				)
				IF @iRtr>0  
				BEGIN
					SET @ReturnValue = 'ALL'
				END
				ELSE
				BEGIN
					SET @ReturnValue = 'Multiple'
				END 
			END
			ELSE
			BEGIN
				SET @ReturnValue = 'Multiple'
			END
		END
		
		--Praveenraj B For Parle Salesman Multiple Selection
		 Else if @iCnt>1 And @iSelid=1   
		 Begin  
		 Set @ReturnValue=''
		  Select  @ReturnValue=@ReturnValue+SMName+',' From Salesman Where SMId In (SELECT Top 4 SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND    
			SelId =1 AND Usrid = @iUsrId  )   
			SET @ReturnValue=LEFT(@ReturnValue,LEN(@ReturnValue)-1)
		 End  
		 
   --Till Here
   -->Added By Mohana For Parle Multiple Route Selection
--		Else if @iCnt>1 And @iSelid IN (2,35) AND @iRptid IN (3,242)
-->Added By Aravindh Deva C For Parle Multiple Route Selection for the reports 17,18,19
		ELSE IF @iCnt>1 And @iSelid IN (2,35) AND @iRptid IN (3,242,17,18,19)		
		 BEGIN  
		 SET @ReturnValue=''
		  SELECT  @ReturnValue=@ReturnValue+RMname+',' From RouteMaster  Where rmid In (SELECT Top 5 SelValue FROM ReportFilterDt WHERE Rptid=@iRptid AND    
			SelId IN (2,35) AND Usrid = @iUsrId  )
			SET @ReturnValue=LEFT(@ReturnValue,LEN(@ReturnValue)-1)   
		 END
	-->Till Here   
		ELSE
		BEGIN
			SET @ReturnValue = 'Multiple'
		END 
	END
	ELSE
	BEGIN
		--->Added By Nanda on 25/03/2011-->(Same Selection Id is used for Collection Report-Show Based on with Suppress Zero Stock)
		IF @iSelid=44 AND (@iRptid<>4)
		BEGIN
			SELECT @ReturnValue = ISNULL(FilterDesc,'') FROM RptFilter WHERE FilterId IN 
			( 
				SELECT SelValue FROM ReportFilterDt WHERE RptId=@iRptid AND SelId=@iSelid AND usrid = @iUsrId
			)
			AND RptId=@iRptid AND SelcId=@iSelid		
		END
		ELSE IF @iSelid=289 OR @iSelid=290 -- Moorthi For Nivea Filter (Delivered,Undelivered,Cancelled Bills)
		BEGIN
			SELECT @ReturnValue = ISNULL(FilterDesc,'') FROM RptFilter WHERE FilterId IN 
			( 
				SELECT SelValue FROM ReportFilterDt WHERE RptId=@iRptid AND SelId=@iSelid AND usrid = @iUsrId
			)
			AND RptId=@iRptid AND SelcId=@iSelid		
		END
		--->Till Here
		ELSE
		BEGIN
			If @iSelid <> 10 AND @iSelid <> 11  And @iSelid <>66 and @iSelid<>64 AND @iSelid <> 13 AND @iSelid <> 20 
			AND @iSelid <> 102 AND @iSelid <> 103 AND @iSelid <> 105  AND @iSelid <> 108 AND @iSelid <> 115 AND @iSelid <> 117 AND 
			@iSelid <> 119 AND @iSelid <> 126  AND @iSelid <> 139 AND @iSelid <> 140 AND @iSelid <> 152 AND @iSelid <> 157 AND @iSelid <> 158 AND @iSelid <> 161 
			AND @iSelid <> 163 AND @iSelid <> 165 AND @iSelid <> 171  AND @iSelid <> 173 AND @iSelid <> 174 AND @iSelid <> 180 AND @iSelid <> 181
			AND @iSelid <> 195 AND @iSelid <> 199 AND @iSelid <> 201 and @iSelid <> 278
			BEGIN			
				SELECT @iCnt = SelValue From ReportFilterDt Where Rptid= @iRptid AND
				SelId = @iSelid AND usrid = @iUsrId			
				
				IF @iCnt = 0
				BEGIN
					IF @iSelid=53 and (@iRptid=43 Or @iRptid=44)
					BEGIN
						IF Not Exists(SELECT * FROM ReportFilterDt WHERE Rptid In(43,44) and Selid=54)
						BEGIN
							SELECT @iCnt = SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
							SelId = 55 AND usrid = @iUsrId
							SELECT @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
						END
						ELSE
						BEGIN
							SELECT @iCnt = SelValue From ReportFilterDt Where Rptid= @iRptid AND
							SelId = 54 AND usrid = @iUsrId
							SELECT @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
						END
					END
					ELSE 
					BEGIN
						SET @ReturnValue = 'ALL'
					END
				END
				ELSE
				BEGIN
					If @iSelid=232 
					BEGIN
						Select @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
					END
					ELSE
					BEGIN
						Select @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,2)
					END
			   END
			END
			ELSE
			BEGIN	
				If @iSelid=10 or @iSelid=11	or @iSelid=20 or @iSelid=13 or @iSelid=139 or @iSelid=140
				BEGIN
					SELECT @ReturnValue = Convert(nVarChar(10),FilterDate,121) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId
				End
				If  @iSelid=66 
				BEGIN
					SELECT @ReturnValue = Cast(SelValue as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End
				If  @iSelid=64
					BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=115 
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=152 
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End			
				If  @iSelid=157 or @iSelid=158
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=161
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End
				If  @iSelid=199
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				IF @iSelid=102 OR @iSelid=103 OR @iSelid=105 OR  @iSelid=108 OR @iSelid = 117 OR @iSelid = 119 OR @iSelid = 126 OR @iSelid = 159 OR @iSelid = 163  OR @iSelid = 165 OR @iSelid = 180 OR @iSelid = 181
				OR @iSelid = 173 OR @iSelid = 174 OR @iSelid=195 OR @iSelid=201 OR @iSelid = 171 OR @iSelid = 278
				BEGIN
					SELECT @SCnt = NULLIF(ISNULL(SelDate,'0'),SelDate) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId
					IF @SCnt='0' 
					BEGIN
						Set @ReturnValue = 'ALL'
					END 
					ELSE
					BEGIN
						SELECT @ReturnValue = Cast(SelDate as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
						SelId = @iSelid AND usrid = @iUsrId	
					END
				END			
			END	
		END			
	END
	RETURN(@ReturnValue)
END
GO
--Sathishkumar Veeramani Junk Character
IF EXISTS(SELECT * FROM Sysobjects WHERE Xtype IN ('TF','FN') AND Name ='Fn_Removejunk')
DROP FUNCTION dbo.Fn_Removejunk
GO
CREATE FUNCTION dbo.Fn_Removejunk(@StrIn AS VARCHAR(MAX))     
RETURNS VARCHAR(MAX)     
AS
BEGIN    
    
DECLARE @I INT      
SET @I=0      
    
WHILE @I<256 --check entire extended ascii set      
    
BEGIN      
 --IF(@I NOT IN (64,136,46,44,43,58,59,40,42,41,95,38,45,47,92,63,6)) --Allowed Char Ascii values    
 -- Begin    
    IF((@I BETWEEN 1 AND 8) OR (@I BETWEEN 14 AND 31) OR (@I BETWEEN 126 AND 149) OR (@I BETWEEN 152 AND 255) OR (@I IN(96,39)))    
    BEGIN      
        SET @StrIn=REPLACE(@StrIn,CHAR(@I),'') --this replaces the current char with a space      
    END      
  --End    
    
SET @I = @I + 1    
END    
RETURN @StrIn     
END
GO
--Retailer Master Junk Character Removed
IF EXISTS (SELECT * FROM Retailer WITH (NOLOCK))
BEGIN
	UPDATE A SET A.RtrCode = Z.RtrCode,A.RtrName = Z.RtrName,A.RtrAdd1 = Z.RtrAdd1,A.RtrAdd2 = Z.RtrAdd2,A.RtrAdd3 = Z.RtrAdd3 
	FROM Retailer A WITH(NOLOCK) INNER JOIN (SELECT DISTINCT RtrId,dbo.Fn_Removejunk (ISNULL(RtrCode,'')) AS RtrCode,
	dbo.Fn_Removejunk(ISNULL(RtrName,'')) AS RtrName,dbo.Fn_Removejunk(ISNULL(RtrAdd1,'')) AS RtrAdd1,dbo.Fn_Removejunk(ISNULL(RtrAdd2,'')) AS RtrAdd2,
	dbo.Fn_Removejunk(ISNULL(RtrAdd3,'')) AS RtrAdd3 FROM Retailer WITH(NOLOCK)) Z ON A.RtrId = Z.RtrId
END
GO
--Retailer Shipping Address Junk Character Removed
IF EXISTS (SELECT * FROM RetailerShipAdd WITH (NOLOCK))
BEGIN
	UPDATE A SET A.RtrShipAdd1 = Z.RtrShipAdd1,A.RtrShipAdd2 = Z.RtrShipAdd2,A.RtrShipAdd3 = Z.RtrShipAdd3 FROM RetailerShipAdd A WITH (NOLOCK) INNER JOIN ( 
	SELECT DISTINCT RtrId,dbo.Fn_Removejunk (ISNULL(RtrShipAdd1,'')) AS RtrShipAdd1,dbo.Fn_Removejunk(ISNULL(RtrShipAdd2,'')) AS RtrShipAdd2,
	dbo.Fn_Removejunk(ISNULL(RtrShipAdd3,'')) AS RtrShipAdd3 FROM RetailerShipAdd WITH(NOLOCK)) Z ON A.RtrId = Z.RtrId
END
GO
--Product Master Junk Character Removed
IF EXISTS (SELECT * FROM Product WITH (NOLOCK))
BEGIN
	UPDATE A SET A.PrdCCode = Z.PrdCCode,A.PrdDCode = Z.PrdDCode,A.PrdName = Z.PrdName,A.PrdShrtName = Z.PrdShrtName FROM Product A WITH (NOLOCK) INNER JOIN ( 
	SELECT DISTINCT PrdId,dbo.Fn_Removejunk (ISNULL(PrdCCode,'')) AS PrdCCode,dbo.Fn_Removejunk(ISNULL(PrdDCode,'')) AS PrdDCode,
	dbo.Fn_Removejunk(ISNULL(PrdName,'')) AS PrdName,dbo.Fn_Removejunk(ISNULL(PrdShrtName,'')) AS PrdShrtName FROM Product WITH(NOLOCK))Z ON A.PrdId = Z.PrdId
END
GO
--Product Batch Junk Character Removed
IF EXISTS (SELECT * FROM ProductBatch WITH (NOLOCK))
BEGIN
	UPDATE A SET A.PrdBatCode = Z.PrdBatCode,A.CmpBatCode = Z.CmpBatCode FROM ProductBatch A WITH (NOLOCK) INNER JOIN ( 
	SELECT DISTINCT PrdId,PrdBatId,dbo.Fn_Removejunk (ISNULL(PrdBatCode,'')) AS PrdBatCode,dbo.Fn_Removejunk(ISNULL(CmpBatCode,'')) AS CmpBatCode
	FROM ProductBatch WITH(NOLOCK))Z ON A.PrdId = Z.PrdId AND A.PrdBatId = Z.PrdBatId
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ValidateRetailerMaster')
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
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ValidateRetailerValueClassMap')
DROP PROCEDURE Proc_ValidateRetailerValueClassMap
GO
--Exec Proc_ValidateRetailerValueClassMap 0 
--select * from errorlog
--delete from errorlog
--delete from RetailerValueClassMap
--select * from RetailerValueClassMap order by rtrid
--select * from ETL_Prk_RetailerValueClassMap order by RetailerCode
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
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------
* {Date}         {Developer}             {Brief modification description}
  2013/10/10   Sathishkumar Veeramani     Junk Characters Removed  
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
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ValidateRetailerRoute')
DROP PROCEDURE Proc_ValidateRetailerRoute
GO
----EXEC Proc_ValidateRetailerRoute 0
----ROLLBACK TRANSACTION
CREATE PROCEDURE Proc_ValidateRetailerRoute
(

	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateRetailer
* PURPOSE	: To Insert and Update records  from xml file in the Table Retailer 
* CREATED	: MarySubashini.S
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
	DECLARE @RouteCode AS NVARCHAR(100)
	DECLARE @RtrId AS INT
	DECLARE @RMId AS INT
	DECLARE @Taction AS INT
	DECLARE @Tabname AS NVARCHAR(100)
	DECLARE @TransType AS INT
	DECLARE @SelectionType AS NVARCHAR(100)
	DECLARE @ErrDesc AS NVARCHAR(1000)
	DECLARE @sSql AS NVARCHAR(4000)
	
	SET @Taction=1
	SET @TransType=0
	SET @Tabname='ETL_Prk_RetailerRoute'

	DECLARE Cur_RetailerRoute CURSOR 
	FOR SELECT dbo.Fn_Removejunk(ISNULL([Retailer Code],'')),dbo.Fn_Removejunk(ISNULL([Route Code],'')),ISNULL([Selection Type],'')
	FROM ETL_Prk_RetailerRoute WITH(NOLOCK) ORDER BY [Retailer Code]

	OPEN Cur_RetailerRoute
	FETCH NEXT FROM Cur_RetailerRoute INTO @RetailerCode,@RouteCode,@SelectionType
	WHILE @@FETCH_STATUS=0		
	BEGIN			
		SET @Po_ErrNo=0
		
		IF NOT EXISTS  (SELECT * FROM Retailer WHERE RtrCode = @RetailerCode )    
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


		IF NOT EXISTS  (SELECT * FROM RouteMaster WHERE  RMCode=@RouteCode AND RMSRouteType<>2)    
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Route Code ' + @RouteCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (2,@Tabname,'RouteCode',@ErrDesc)
		END
		ELSE
		BEGIN				
			SELECT @RMId =RMId FROM RouteMaster WITH (NOLOCK)WHERE RMCode=@RouteCode
		END
		
		IF EXISTS  (SELECT * FROM RetailerMarket WHERE  RMId=@RMId AND RtrId=@RtrId)    
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
			SET @ErrDesc = 'Route Selection Type should not be empty'  		 
			INSERT INTO Errorlog VALUES (3,@Tabname,'SelectionType',@ErrDesc)
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
				SET @ErrDesc = 'Route Selection Type '+@SelectionType+'is not available'  		 
				INSERT INTO Errorlog VALUES (4,@Tabname,'SelectionType',@ErrDesc)
			END
		END

		IF @TransType=1 
		BEGIN
			IF  @Taction=1 AND @Po_ErrNo=0 
			BEGIN
				INSERT INTO RetailerMarket 
				(RtrId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
				VALUES(@RtrId,@RMId,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0)
				SET @sSql='INSERT INTO RetailerMarket 
				(RtrId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
				VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RMId AS VARCHAR(10))+',
				1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',0)'
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
			
		IF @TransType=2 
		BEGIN
			IF @Po_ErrNo=0
			BEGIN
				DELETE FROM RetailerMarket WHERE RtrId=@RtrId AND RMId=@RMId
				SET @sSql='DELETE FROM RetailerMarket WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+' AND RMId='+CAST(@RMId AS VARCHAR(10))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
			
		FETCH NEXT FROM Cur_RetailerRoute INTO @RetailerCode,@RouteCode,@SelectionType
	END
	CLOSE Cur_RetailerRoute
	DEALLOCATE Cur_RetailerRoute

	--->Added By Nanda 04/03/2010
	IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Route','Route is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerMarket)

		DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerMarket))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)

		SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerMarket))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	--->Till Here

	RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ValidateRetailerShippingAddress')
DROP PROCEDURE Proc_ValidateRetailerShippingAddress
GO
CREATE PROCEDURE Proc_ValidateRetailerShippingAddress
(

	@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************************************************
* PROCEDURE	: Proc_ValidateRetailerShippingAddress
* PURPOSE	: To Insert and Update records  from xml file in the Table RetailerShippingAddress 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------------------------------
* {Date}       {Developer}               {brief modification description}      
* 21/07/2009   Nanda	                 Modified for Default Shipping Address Validation
  2013/10/10   Sathishkumar Veeramani    Junk Characters Removed  
*************************************************************************************************/ 
SET NOCOUNT ON
BEGIN

	DECLARE @RetailerCode AS NVARCHAR(100)
	DECLARE @Address1 AS NVARCHAR(100)
	DECLARE @Address2 AS NVARCHAR(100)
	DECLARE @Address3 AS NVARCHAR(100)
	DECLARE @RtrShipPinNo AS NVARCHAR(100)
	DECLARE @RtrShipPhoneNo AS NVARCHAR(100)
	DECLARE @DefaultShippingAddress AS NVARCHAR(100)
	DECLARE @RtrId AS INT
	DECLARE @RtrShipId AS INT
	DECLARE @SNewRtrId AS INT
	DECLARE @SOldRtrId AS INT
	DECLARE @DefCount AS INT 
	DECLARE @Tabname AS NVARCHAR(100)
	DECLARE @CntTabname AS NVARCHAR(100)
	DECLARE @FldName AS NVARCHAR(100)
	DECLARE @SRetailerCode AS NVARCHAR(100)
	DECLARE @ErrDesc AS NVARCHAR(1000)
	DECLARE @sSql AS NVARCHAR(4000)
	DECLARE @NewShipAddr AS NVARCHAR(4000)	

	DECLARE @ShipSlNo TABLE
	(
		SlNo		 INT IDENTITY,
		ErrorDesc	NVARCHAR(1000)
	)
	
	SET @DefCount=0
	SET @Po_ErrNo=0
	SET @CntTabname='RetailerShipAdd'
	SET @Tabname='ETL_Prk_RetailerShippingAddress'
	SET @FldName='RtrShipId'
	SET @SRetailerCode=''

	DECLARE Cur_RetailerShippingAddress CURSOR 
	FOR SELECT dbo.Fn_Removejunk(ISNULL([Retailer Code],'')),dbo.Fn_Removejunk(ISNULL(Address1,'')),dbo.Fn_Removejunk(ISNULL(Address2,'')),
	dbo.Fn_Removejunk(ISNULL(Address3,'')),dbo.Fn_Removejunk(ISNULL([Retailer Shipping Pin Code],'0')),
	ISNULL([Retailer Shipping Phone No],''),dbo.Fn_Removejunk(ISNULL([Default Shipping Address],''))
	FROM ETL_Prk_RetailerShippingAddress WITH(NOLOCK) ORDER BY [Retailer Code],[Default Shipping Address]
	
	OPEN Cur_RetailerShippingAddress
	FETCH NEXT FROM Cur_RetailerShippingAddress INTO @RetailerCode,@Address1,@Address2,@Address3,
				@RtrShipPinNo,@RtrShipPhoneNo,@DefaultShippingAddress
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT EXISTS  (SELECT * FROM Retailer WHERE RtrCode = @RetailerCode)    
  		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'Retailer Code ' + @RetailerCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (1,@Tabname,'RetailerCode',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @RtrId =RtrId FROM Retailer WHERE RtrCode = @RetailerCode
		END

		IF LTRIM(RTRIM(@Address1))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'Retailer Shipping Address should not be empty'  		 
			INSERT INTO Errorlog VALUES (2,@Tabname,'Address',@ErrDesc)
		END

		IF LEN(@RtrShipPinNo)<>0
		BEGIN
			IF ISNUMERIC(@RtrShipPinNo)=0
			BEGIN
				SET @Po_ErrNo=1	
				SET @ErrDesc = 'PinCode is not in correct format'		 
				INSERT INTO Errorlog VALUES (3,@Tabname,'RtrShipPinNo',@ErrDesc)
			END	
		END					

		IF LTRIM(RTRIM(@RtrShipPhoneNo))<>'' 
		BEGIN		
			SET @Po_ErrNo=0	
		END	
	
		SET @DefCount=0
		
		IF LTRIM(RTRIM(@DefaultShippingAddress))='YES' 
		BEGIN
			IF NOT EXISTS (SELECT * FROM RetailerShipAdd WHERE RtrId=@RtrId AND 
			RtrShipDefaultAdd=1)
			BEGIN
				SET @DefCount=1
			END
			ELSE
			BEGIN
				SET @DefaultShippingAddress='NO'
				SET @DefCount=1
			END
		END
		ELSE
		BEGIN
			SET @DefCount=1
		END

		IF @DefCount=2
		BEGIN
			SET @Po_ErrNo=1		
			SET @ErrDesc = 'Default Shipping Address already exists for the Retailer '+@RetailerCode		 
			INSERT INTO Errorlog VALUES (6,@Tabname,'DefaultShippingAddress',@ErrDesc)
		END

		IF @DefCount=0 
		BEGIN
			SET @Po_ErrNo=1		
			SET @ErrDesc = 'Default Shipping Address is not available for the Retailer '+@RetailerCode		 
			INSERT INTO Errorlog VALUES (7,@Tabname,'DefaultShippingAddress',@ErrDesc)
		END
			
		SELECT @RtrShipId=dbo.Fn_GetPrimaryKeyInteger(@CntTabname,@FldName,CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
	
		IF @RtrShipId=0 
		BEGIN
			SET @Po_ErrNo=1		
			SET @ErrDesc = 'Reset the Counter value '+@RetailerCode		 
			INSERT INTO Errorlog VALUES (8,@Tabname,'Counter Value',@ErrDesc)
		END
			
		SELECT @NewShipAddr=@Address1+@Address2+@Address3+@RtrShipPinNo+@RtrShipPhoneNo

		IF NOT EXISTS(SELECT LTRIM(RTRIM(RtrShipAdd1))+LTRIM(RTRIM(RtrShipAdd2))+LTRIM(RTRIM(RtrShipAdd3))+
		LTRIM(RTRIM(CAST(RtrShipPinNo AS NVARCHAR(10))))+LTRIM(RTRIM(RtrShipPhoneNo))
		FROM RetailerShipAdd WHERE RtrId=@RtrId AND LTRIM(RTRIM(RtrShipAdd1))+LTRIM(RTRIM(RtrShipAdd2))+LTRIM(RTRIM(RtrShipAdd3))+
		LTRIM(RTRIM(CAST(RtrShipPinNo AS NVARCHAR(10))))+LTRIM(RTRIM(RtrShipPhoneNo))=LTRIM(RTRIM(@NewShipAddr)))
		BEGIN
			IF  @Po_ErrNo=0
			BEGIN	
				INSERT INTO RetailerShipAdd VALUES(@RtrShipId,@RtrId,@Address1,@Address2,@Address3,@RtrShipPinNo,@RtrShipPhoneNo,
				(CASE @DefaultShippingAddress WHEN 'YES' THEN 1 ELSE 0 END),
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
		
				SET @sSql='INSERT INTO RetailerShipAdd(RtrShipId,RtrId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo,RtrShipDefaultAdd,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
				VALUES('+CAST(@RtrShipId AS VARCHAR(10))+','+CAST(@RtrId AS VARCHAR(10))+','''+@Address1+''','''+@Address2+''','''+@Address3+''','''','''','+CAST(@RtrShipPinNo AS VARCHAR(10))+','''+@RtrShipPhoneNo+''',
				'+CAST((CASE @DefaultShippingAddress WHEN 'YES' THEN 1 ELSE 0 END)AS VARCHAR(10))+',
				1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				INSERT INTO Translog(strSql1) VALUES (@sSql)
		
				UPDATE Retailer SET RtrShipId=@RtrShipId WHERE RtrId=@RtrId
		
				SET @sSql='UPDATE Retailer SET RtrShipId='+CAST(@RtrShipId AS VARCHAR(10))+' WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
	
			IF EXISTS (SELECT * FROM RetailerShipAdd WHERE RtrShipId=@RtrShipId)
			BEGIN
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName=@CntTabname AND FldName=@FldName
		
				SET @sSql='UPDATE Counters SET CurrValue=CurrValue'+'+1'+' WHERE TabName='''+@CntTabname+''' AND FldName='''+@FldName+''''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
			
		FETCH NEXT FROM Cur_RetailerShippingAddress INTO @RetailerCode,@Address1,@Address2,@Address3,@RtrShipPinNo,@RtrShipPhoneNo,@DefaultShippingAddress
	END
	CLOSE Cur_RetailerShippingAddress
	DEALLOCATE Cur_RetailerShippingAddress

	SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd WHERE RtrShipDefaultAdd=1)

	IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd WHERE RtrShipDefaultAdd=1))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 1,@Tabname,'Default Shipping Address','Default Shipping Address not available for '+CAST(RtrCode AS NVARCHAR(50)) FROM Retailer
		WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)
		SET @Po_ErrNo=1
	END

	--->Added By Nanda on 04/03/2010
	IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Shipping Address','Shipping Address is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerShipAdd)

		DELETE FROM RetailerMarket WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)
		DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)		
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerShipAdd))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)

		SET @sSql='DELETE FROM RetailerMarket WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)
		DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)		
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerShipAdd))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerShipAdd)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	ELSE IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Route','Route is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerMarket)

		DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerMarket))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)

		SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerMarket))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerMarket)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	ELSE IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerValueClassMap))
	BEGIN
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Value Class','Value Class is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap)

		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerValueClassMap))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerValueClassMap)

		SET @sSql='DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerValueClassMap))
		DELETE FROM Retailer WHERE RtrId NOT IN(SELECT RtrId FROM RetailerValueClassMap)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	--->Till Here

	RETURN
END
--Till Here Sathishkumar Veeramani
GO
DELETE FROM RptFilter WHERE RptId=18 AND SelcId=257
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc)
SELECT 18,257,0,'YES'
UNION
SELECT 18,257,1,'NO'
GO
DELETE FROM RptFormula WHERE RptId=18
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,1,'Fil_FromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,2,'Fil_ToDate','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,3,'Fil_Vehicle','Vehicle',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,4,'Fil_VehAllNo','Vehicle Allocation No',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,5,'Fil_Salesman','Salesman',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,6,'Fil_DlvRoute','Delivery Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,7,'Fil_Retailer','Retailer',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,8,'FilDisp_FromDate','',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,9,'FilDisp_ToDate','',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,10,'FilDisp_Vehicle','ALL',1,36)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,11,'FilDisp_VehAllNo','ALL',1,37)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,12,'FilDisp_Salesman','ALL',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,13,'FilDisp_DlvRoute','ALL',1,35)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,14,'FilDisp_Retailer','ALL',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,15,'PrdCode','Product Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,16,'PrdName','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,17,'BatCode','Bat Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,18,'BilledQty','Billed Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,19,'FreeQty','Free Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,20,'RtnQty','Return Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,21,'RepQty','Replacement Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,22,'TotQty','Total Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,23,'GrandTotal','Grand Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,24,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,25,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,26,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,27,'Fil_DisplayIn','Display In',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,28,'FilDisp_DisplayIn','Display In',1,129)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,29,'Cap_RetailerGroup','Retailer Group',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,30,'Disp_RetailerGroup','Retailer Group',1,215)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,31,'MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,32,'Dis_AllBillCount','1',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,33,'Dis_LastBillNo','',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (18,34,'FillDisBillNo','Bill No(s).      :',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId=18
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,1,'PrdId','PrdId',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,2,'Product Code','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,3,'Product Description','Product Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,4,'Batch Number','Batch Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,5,'MRP','MRP',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,6,'Selling Rate','Selling Rate',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,7,'BillCase','Billed Qty in Selected UOM',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,8,'BillPiece','Billed Qty in Piece',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,9,'Free Qty','Free Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,10,'Return Qty','Return Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,11,'Replacement Qty','Replacement Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,12,'TotalCase','Total Qty in Selected UOM',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,13,'TotalPiece','Total Qty in Piece',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,14,'Total Qty','Total Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,15,'Billed Qty','Billed Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (18,16,'NetAmount','Net Amount',1,1)
GO
DELETE FROM RptExcelHeaders WHERE RptId=17
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,1,'Bill Number','Bill Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,2,'Bill Date','Bill Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,3,'Retailer Name','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,4,'PrdId ','PrdId',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,5,'Product Code','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,6,'Product Description','Product Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,7,'BillCase','Billed Qty in Selected UOM',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,8,'BillPiece','Billed Qty in Pieces',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,9,'Free Qty','Free Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,10,'Return Qty','Return Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,11,'Replacement Qty','Replacement Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,12,'TotalCase','Total Qty in Selected UOM',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,13,'TotalPiece','Total Qty in Piece',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,14,'Total Qty','Total Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,15,'Billed Qty','Billed Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (17,16,'NetAmount','Net Amount',1,1)
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND NAME='Proc_RptVatSummary_Parle')
DROP PROCEDURE Proc_RptVatSummary_Parle
GO
--Exec Proc_RptVatSummary_Parle 250,1,0,'eeeee',0,0,0
CREATE PROCEDURE [dbo].[Proc_RptVatSummary_Parle]
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
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	
	print @InvoiceType
	delete from RptVatsummary
		
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_IOTaxSummary_Parle @FromDate,@ToDate,@InvoiceType
	select 'Temp_IOTaxDetails_Parle',* from 	Temp_IOTaxDetails_Parle
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
IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')
BEGIN
	ALTER TABLE RptBillTemplateFinal ADD InvDisc NUMERIC (18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')
BEGIN
	ALTER TABLE RptBillTemplateFinal ADD InvDiscPer NUMERIC (18,2) DEFAULT 0 WITH VALUES 
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--exec PROC_RptBillTemplateFinal 16,1,0,'Parle',0,0,1,'RptBt_View_Final1_BillTemplate'
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
	--print @Pi_BTTblName
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
	--Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
	    Delete From RptBillTemplate_Other Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
	--End
	---------------------------------------Replacement
	--Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
		Delete From RptBillTemplate_Replacement Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
	--End
	----------------------------------Credit Debit Adjus
	--Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
	    Delete From RptBillTemplate_CrDbAdjustment Where UsrId = @Pi_UsrId
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
	--End
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
	--Added By Sathishkumar Veeramani 2012/12/13
	IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')
	BEGIN
	     ALTER TABLE RptBillTemplateFinal ADD [Payment Mode] NVARCHAR(20)
	     UPDATE A SET A.[Payment Mode] = Z.[Payment Mode] FROM RptBillTemplateFinal A INNER JOIN 
	    (SELECT SalId,(CASE RtrPayMode WHEN 1 THEN 'Cash' ELSE 'Cheque' END) AS [Payment Mode] FROM SalesInvoice WITH (NOLOCK)) Z ON A.Salid = Z.SalId 
	END
	--Till Here
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
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD InvDisc NUMERIC (18,2) DEFAULT 0 WITH VALUES 
		END
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD InvDiscPer NUMERIC (18,2) DEFAULT 0 WITH VALUES 
		END
	
	UPDATE A SET A.InvDisc=B.SalInvLvlDisc,A.InvDiscPer=B.SalInvLvlDiscPer FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
	ON A.[Sales Invoice Number]=B.SalInvNo
	
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
--Select * from HotSearchEditorHd Where FormId=810
DELETE FROM HotSearchEditorHd WHERE FormId=810 AND FormName='Billing' AND ControlName='Batch Without MRP'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 810,'Billing','Batch Without MRP','select',
'SELECT PrdBatID,MRP,PrdBatCode,PurchaseRate,SellRate,PriceId,ShelfDay,ExpiryDay 
FROM( SELECT A.PrdBatID,A.PrdBatCode,F.PrdBatDetailValue AS SellRate,B.PrdBatDetailValue AS MRP, 
D.PrdBatDetailValue AS PurchaseRate,B.PriceId,DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),
DATEADD(Day,Prd.PrdShelfLife,A.MnfDate)) as ShelfDay,DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),A.ExpDate) as ExpiryDay  
FROM  ProductBatch A (NOLOCK)   INNER JOIN Product Prd  (NOLOCK) ON A.PrdId = Prd.PrdId   
INNER JOIN ProductBatchDetails B  
(NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   
INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId   AND B.SlNo = C.SlNo AND C.MRP = 1   
INNER JOIN ProductBatchDetails D  (NOLOCK)  ON A.PrdBatId = D.PrdBatID   AND D.DefaultPrice=1   
INNER JOIN BatchCreation E (NOLOCK)    ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   
INNER JOIN ProductBatchDetails F (NOLOCK)  ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1   
INNER JOIN BatchCreation G (NOLOCK)  ON G.BatchSeqId = A.BatchSeqId   AND F.SlNo = G.SlNo  AND G.SelRte = 1  
INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId AND A.PrdBatId=PBL.PrdBatId AND (PBL.PrdBatLcnSih-PBL.PrdbatLcnResSih)>0   
WHERE  A.PrdId=vFParam  AND A.Status = 1  )   MainQry order by PrdBatId ASC'
GO
IF NOT EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='U' AND name='Hotsearchleneditor')
BEGIN
CREATE TABLE Hotsearchleneditor
(
	FormId		INT,
	FormName	VARCHAR(50),
	FrmWidth	INT,
	FrameWidth	INT
)
END
GO
DELETE FROM Hotsearchleneditor WHERE FormId IN (1,2)
INSERT INTO Hotsearchleneditor (FormId,FormName,FrmWidth,FrameWidth)
SELECT 1,'Billing',7515,7425
UNION
SELECT 2,'Purchase Receipt',7515,7425
GO
DELETE FROM Configuration WHERE ModuleId='LGV1' AND ModuleName='LoginValidation'
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('LGV1','LoginValidation','Check Console Date While Login',0,'',0.00,1)
GO
--Parle_issues_Suganya
DELETE FROM RptExcelHeaders WHERE RptId=38
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,1,'SlNo','SlNo',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,2,'Date','Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,3,'Voucher No','Voucher No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,4,'Details','Details',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,5,'Particular','Ledger',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,6,'Debit','Debit',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,7,'Credit','Credit',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,8,'Balance','Balance',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,9,'CoaId','CoaId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,10,'AcCode','AcCode',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (38,11,'AcName','AcName',0,1)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME ='Proc_RptAccountsBook' AND XTYPE='P')
DROP PROCEDURE Proc_RptAccountsBook
GO
-- EXEC Proc_RptAccountsBook 38,1,0,'BIDCO',0,0,1
CREATE PROCEDURE Proc_RptAccountsBook
(
	@Pi_RptId INT,
	@Pi_UsrId INT,
	@Pi_SnapId INT,
	@Pi_DbName nvarchar(50),
	@Pi_SnapRequired INT,
	@Pi_GetFromSnap INT,
	@Pi_CurrencyId INT
	
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_RptAccountsBook
* PURPOSE: Cash Book
* NOTES:
* CREATED: Boopathy.P 16-08-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @NewSnapId  AS INT
	DECLARE @DBNAME AS  nvarchar(50)
	DECLARE @TblName  AS nvarchar(500)
	DECLARE @TblStruct  AS nVarchar(4000)
	DECLARE @TblFields  AS nVarchar(4000)
	DECLARE @sSql AS  nVarChar(4000)
	DECLARE @ErrNo   AS INT
	DECLARE @PurDBName AS nVarChar(50)
	
	--Filter Variable
	DECLARE @FromDate AS  DateTime
	DECLARE @ToDate AS DateTime
	DECLARE @CoaId    AS Int
	DECLARE @SecLvl as nVarchar(50)
	DECLARE @ThdLvl as nVarchar(50)
	DECLARE @Level    AS Int
	DECLARE @Option as INT
	DECLARE @TreeLevel as nVarchar(50)
	
	--Till Here
	SET @TreeLevel= NULL
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CoaId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,47,@Pi_UsrId))
	SET @Level = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,48,@Pi_UsrId))
	SET @SecLvl = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,49,@Pi_UsrId))
	SET @ThdLvl = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId))
	--Till Here

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	IF not @SecLvl = 0
	BEGIN
		SET @TreeLevel=Left(@SecLvl,2)
	END
	IF not @ThdLvl = 0
	BEGIN
		SET @TreeLevel=Left(@ThdLvl,3)	
	END
	IF @CoaId <> 0
	BEGIN
		SET @Option=1
	END
	ELSE
	BEGIN
		SET @Option =2
	END
	Create TABLE #RptAccountsBook
	(
		[Slno]	INT,
		[Date]  DateTime,
		[Voucher No] nVarchar(50),
		[Details] nVarchar(4000),
		[Particular]     nVarchar(4000),
		[Debit]     NUMERIC(38,6),
		[Credit] NUMERIC(38,6),
		[Balance] NUMERIC(38,6),
		[CoaId]   INT,
		[AcCode]  nVarChar(50)
	)
	SET @TblName = 'RptAccountsBook'
	
	SET @TblStruct = '[Slno]	INT,
		  [Date]  DateTime,
	          [Voucher No] nVarchar(50),
	          [Details] nVarchar(4000),
	          [Particular]     nVarchar(4000),
	          [Debit]     NUMERIC(38,6),
	          [Credit] NUMERIC(38,6),
	          [Balance] NUMERIC(38,6),
	          [CoaId]   INT,
		  [AcCode]  nVarChar(50)'
	
	SET @TblFields = '[Slno],[Date],[Voucher No],[Details],
	          [Particular],[Debit],[Credit],[Balance],[CoaId],[AcCode]'
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	End
	Else
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	End
	IF @Pi_GetFromSnap = 0 --To Generate For New Report Data
	BEGIN
		IF @Option =1
		BEGIN
			EXEC Proc_COALIST @Pi_RptId,@FromDate,@ToDate,@CoaId,@Level,'',@Pi_UsrId
			INSERT INTO #RptAccountsBook ([Slno],[Date],[Voucher No],[Details],[Particular],[Debit],[Credit],[Balance],[CoaId],[AcCode])
			SELECT * FROM FinalCoaOP ORDER By CoaId,Date,VocRefNo,Details Desc
		END
		ELSE
		BEGIN
			EXEC Proc_COALIST @Pi_RptId,@FromDate,@ToDate,0,@Level,@TreeLevel,@Pi_UsrId
			INSERT INTO #RptAccountsBook ([Slno],[Date],[Voucher No],[Details],[Particular],[Debit],[Credit],[Balance],[CoaId],[AcCode])
			SELECT * FROM FinalCoaOP ORDER By CoaId,Date,VocRefNo,Details Desc
		END

		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
			IF @Option =1
			BEGIN
				SET @SSQL = ' EXEC Proc_COALIST('+ @Pi_RptId + ','+ @FromDate +',' + @ToDate +','+ @CoaId +',' + @Level +','''',' + @Pi_UsrId +')'+		
				'INSERT INTO #RptAccountsBook ' +
				'(' + @TblFields + ')' +
				'SELECT * FROM FinalCoaOP ORDER By CoaId,Date,VocRefNo,Details Desc'
				
			END
			ELSE
			BEGIN
				SET @SSQL = ' EXEC Proc_COALIST('+ @Pi_RptId + ',' + @FromDate +',' + @ToDate +',0,' + @Level +','+ @TreeLevel + ',' + @Pi_UsrId +')'+
				'INSERT INTO #RptAccountsBook ' +
				'(' + @TblFields + ')' +
				'SELECT * FROM FinalCoaOP ORDER By CoaId,Date,VocRefNo,Details Desc'
				
			END
			EXEC (@SSQL)
			Print 'Retrived Data From Purged Table'
		End

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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptAccountsBook'
				PRINT @sSql
				EXEC (@SSQL)
				Print 'Saved Data Into SnapShot Table'
			END
		END
	END
	ELSE --To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptAccountsBook ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
			' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
			' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
			' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			
			EXEC (@SSQL)
			Print 'Retrived Data From Snap Shot Table'
		END
		ELSE
		BEGIN
			Print 'DataBase or Table not Found'
		END
	END

	--Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	UPDATE #RptAccountsBook SET Balance=0 WHERE Particular='CLOSING BALANCE'
	-- Till Here
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptAccountsBook
	IF @Level=1
	BEGIN
		SELECT SlNo,[Date],[Voucher No],[Details],[Particular],[Debit],[Credit],
		(CASE WHEN [Credit]>0 AND Debit=0 THEN (-1)*[Balance] ELSE [Balance] END) AS [Balance]--[Balance]
		,A.[CoaId],A.[AcCode],[AcName]
		FROM #RptAccountsBook A JOIN CoaMaster B ON A.CoaId=B.CoaId
		ORDER BY A.[CoaId],DATE,[Slno],[Voucher No] DESC--,Details
	END
	ELSE
	BEGIN
		SELECT SlNo,[Date],[Voucher No],[Details],[Particular],[Debit],[Credit],
		(CASE WHEN [Credit]>0 AND Debit=0 THEN (-1)*[Balance] ELSE [Balance] END) AS [Balance]
		--(CASE WHEN [Balance]>0 THEN [Balance] ELSE ABS([Balance]) END) AS [Balance]
		,A.[CoaId],A.[AcCode],[AcName]
		--[Balance],[CoaId],[AcCode]
		FROM #RptAccountsBook A JOIN CoaMaster B ON A.CoaId=B.CoaId
		ORDER BY A.[CoaId],DATE,[Slno],[Balance],[Voucher No] DESC
		
	END

	Return
End
GO
DELETE FROM RptExcelHeaders WHERE RptId=40
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,1,'SlNo','SlNo',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,2,'Date','Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,3,'Voucher No','Voucher No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,4,'Details','Details',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,5,'Particular','Ledger',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,6,'Debit','Debit',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,7,'Credit','Credit',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,8,'Balance','Balance',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,9,'CoaId','CoaId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (40,10,'AcCode','AcCode',0,1)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptCashBook' AND XTYPE='P')
DROP PROCEDURE Proc_RptCashBook
GO
--EXEC Proc_RptCashBook 40,2,0,'BIDCO',0,0,1
CREATE  PROCEDURE Proc_RptCashBook
(
	@Pi_RptId INT,
	@Pi_UsrId INT,
	@Pi_SnapId INT,
	@Pi_DbName nvarchar(50),
	@Pi_SnapRequired INT,
	@Pi_GetFromSnap INT,
	@Pi_CurrencyId INT
)
AS
SET NOCOUNT ON

/*********************************
* PROCEDURE: Proc_RptCashBook
* PURPOSE: Cash Book
* NOTES:
* CREATED: Boopathy.P 16-08-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @NewSnapId  AS INT
	DECLARE @DBNAME AS  nvarchar(50)
	DECLARE @TblName  AS nvarchar(500)
	DECLARE @TblStruct  AS nVarchar(4000)
	DECLARE @TblFields  AS nVarchar(4000)
	DECLARE @sSql AS  nVarChar(4000)
	DECLARE @ErrNo   AS INT
	DECLARE @PurDBName AS nVarChar(50)

	--Filter Variable
	DECLARE @FromDate AS  DateTime
	DECLARE @ToDate AS DateTime
	DECLARE @CoaId    AS Int
	DECLARE @Level    AS Int
	DECLARE @Option as INT
	DECLARE @Pi_TreeLevel as nVarchar(50)
	--Till Here
	
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CoaId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,47,@Pi_UsrId))
	SET @Level = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,48,@Pi_UsrId))
	Set @Pi_TreeLevel = Null
	--Till Here


	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	IF @CoaId <> 0
	BEGIN
		SET @Option=1
	END
	ELSE
	BEGIN
		SET @Option =2
		Set @Pi_TreeLevel ='212'
	END

	Create TABLE #RptCashBook
	(
		[Slno]  INT,
		[Date]  DateTime,
		[Voucher No] nVarchar(50),
		[Details] nVarchar(4000),
		[Particular]     nVarchar(4000),
		[Debit]     NUMERIC(38,6),
		[Credit] NUMERIC(38,6),
		[Balance] NUMERIC(38,6),
		[CoaId]   INT,
		[AcCode]  nVarChar(50)
	)

	SET @TblName = 'RptCashBook'

	SET @TblStruct = '[Slno]  INT,
			  [Date]  DateTime,
			  [Voucher No] nVarchar(50),
			  [Details] nVarchar(100),
			  [Particular]     nVarchar(50),
			  [Debit]     NUMERIC(38,6),
			  [Credit] NUMERIC(38,6),
		          [Balance] NUMERIC(38,6),
			  [CoaId]   INT,
		  	  [AcCode]  nVarChar(50)'

	SET @TblFields = '[Slno],[Date],[Voucher No],[Details],
	[Particular],[Debit],[Credit],[Balance],[CoaId],[AcCode]'

	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	End
	Else
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	End

	IF @Pi_GetFromSnap = 0 --To Generate For New Report Data
	BEGIN
		IF @Option =1
		BEGIN
			EXEC Proc_COALIST @Pi_RptId,@FromDate,@ToDate,@CoaId,@Level,'',@Pi_UsrId
			INSERT INTO #RptCashBook ([Slno],[Date],[Voucher No],[Details],[Particular],[Debit],[Credit],[Balance],[CoaId],[AcCode])
			SELECT * FROM FinalCoaOP ORDER By CoaId,Date,VocRefNo,Details Desc
		END
		ELSE
		BEGIN
			EXEC Proc_COALIST @Pi_RptId,@FromDate,@ToDate,0,@Level,@Pi_TreeLevel,@Pi_UsrId
			INSERT INTO #RptCashBook ([Slno],[Date],[Voucher No],[Details],[Particular],[Debit],[Credit],[Balance],[CoaId],[AcCode])
			SELECT * FROM FinalCoaOP ORDER By CoaId,Date,VocRefNo,Details Desc
		END
	
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			IF @Option =1
			BEGIN
				SET @SSQL = ' EXEC Proc_COALIST('+ @Pi_RptId +','+ @FromDate +',' + @ToDate +','+ @CoaId +','+ @Level +','''''','+ @Pi_UsrId +')'+
				'INSERT INTO #RptCashBook ' +
				'(' + @TblFields + ')' +
				'SELECT * FROM FinalCoaOP ORDER By CoaId,Date,VocRefNo,Details Desc'
				
			END
			ELSE
			BEGIN
				SET @SSQL = ' EXEC Proc_COALIST('+ @Pi_RptId +','+ @FromDate +',' + @ToDate +',0,' + @Level + ','+ @Pi_TreeLevel +',' + @Pi_UsrId +')'+
				'INSERT INTO #RptCashBook ' +
				'(' + @TblFields + ')' +
				'SELECT * FROM FinalCoaOP ORDER By CoaId,Date,VocRefNo,Details Desc'
			END
			EXEC (@SSQL)
			Print 'Retrived Data From Purged Table'
		End

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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCashBook'
				EXEC (@SSQL)
				Print 'Saved Data Into SnapShot Table'
			END
		END
	END
	ELSE --To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo

		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCashBook ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
			' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
			' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
			' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			EXEC (@SSQL)
			Print 'Retrived Data From Snap Shot Table'
		END
		ELSE
		BEGIN
			Print 'DataBase or Table not Found'
		END
	END

	

	--Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	UPDATE #RptCashBook SET Balance=0 WHERE [Particular]='CLOSING BALANCE'

	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCashBook
	-- Till Here




-- 	SELECT CoaId,Credit-Debit AS Balance 
-- 	INTO #OpenBal
-- 	FROM
-- 	(
-- 		SELECT SVD.CoaId,SUM((CASE DebitCredit WHEN 1 THEN Amount ELSE 0 END)) AS Debit,
-- 		SUM((CASE DebitCredit WHEN 2 THEN Amount ELSE 0 END)) AS Credit
-- 		FROM StdVocDetails SVD,StdVocMaster SVM,CoaMaster COA
-- 		WHERE SVD.VocRefNo=SVM.VocRefNo AND SVM.VocDate<@FromDate AND
-- 		SVD.CoaId=COA.CoaId AND COA.AcCode LIKE '212%'	
-- 		GROUP BY SVD.CoaId	
-- 	) A
-- 
-- 
-- 	UPDATE #RptCashBook SET #RptCashBook.Balance=Opn.Balance
-- 	FROM #OpenBal Opn WHERE #RptCashBook.CoaId=Opn.CoaId AND #RptCashBook.Particular='OPENING BALANCE'

	IF @Level=1
	BEGIN
		SELECT SlNo,[Date],[Voucher No],[Details],[Particular],[Debit],[Credit],(CASE 
		WHEN [Credit]>0 THEN (-1)*Balance ELSE [Balance] END) AS [Balance],[CoaId],[AcCode]
		FROM #RptCashBook
		--ORDER BY [CoaId],[DATE],[Slno],[Voucher No] 
		ORDER BY [CoaId],[DATE],[Slno] ASC,[Voucher No] DESC 
	END
	ELSE
	BEGIN
		DELETE FROM #RptCashBook WHERE Debit=0 AND Credit=0 
			AND [Particular] NOT IN ('CLOSING BALANCE','OPENING BALANCE')


		SELECT SlNo,[Date],[Voucher No],[Details],[Particular],[Debit],[Credit],
		(CASE WHEN [Credit]>0 THEN (-1)*Balance ELSE [Balance] END) AS [Balance],
		--Balance,
		[CoaId],[AcCode]
		FROM #RptCashBook
		--ORDER BY [CoaId],[DATE],[Slno],[Voucher No]
		ORDER BY [CoaId],[DATE],[Slno] ASC,[Voucher No] DESC 
	END
Return
End
GO
DELETE FROM RptExcelHeaders WHERE RptId=52
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (52,1,'SalesDate','Invoice Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (52,2,'GroupId','GroupId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (52,3,'GroupName','Group By',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (52,4,'GrossAmount','Gross Sales',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (52,5,'NetAmount','Net Sales',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (52,6,'RptType','RptType',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (52,7,'ShowBy','ShowBy',0,1)
GO
DELETE FROM RptExcelHeaders WHERE RptID=56
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,1,'SMId','SMId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,2,'SMName','SMName',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,3,'RMId','RMId',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,4,'RMName','RMName',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,5,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,6,'RtrCode','RtrCode',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,7,'RtrName','RtrName',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,8,'NetSales','NetSales',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,9,'PercBusConDB','%Bus. Con On DB',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,10,'TotBills','TotBillsCut',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,11,'PrdCnt','PrdCnt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,12,'TotSelNetSales','TotSelNetSales',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,13,'TotSelBills','TotSelBills',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,14,'SelPrdCnt','SelPrdCnt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,15,'TotDBNetSales','TotDBNetSales',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,16,'TotDBBills','TotDBBills',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,17,'DBPrdCnt','DBPrdCnt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,18,'UsrId','UsrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,19,'TOTNetSales','TOTNetSales',0,1)
GO
IF  EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='RPTTOPOUTLET_Excel' AND XTYPE='U')
DROP TABLE RPTTOPOUTLET_Excel
GO
CREATE TABLE RPTTOPOUTLET_Excel(
	[SMId] [int] NULL,
	[SMName] [nvarchar](100) NULL,
	[RMId] [int] NULL,
	[RMName] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](50) NULL,
	[RtrName] [nvarchar](100) NULL,
	[NetSales] [numeric](38, 4) NULL,
	[PercBusConDB] [numeric](38, 4) NULL,
	[TotBills] [int] NULL,
	[PrdCnt] [int] NULL,
	[TotSelNetSales] [numeric](38, 2) NULL,
	[TotSelBills] [int] NULL,
	[SelPrdCnt] [int] NULL,
	[TotDBNetSales] [numeric](38, 2) NULL,
	[TotDBBills] [int] NULL,
	[DBPrdCnt] [int] NULL,
	[UsrId] [int] NULL,
	[TOTNetSales] [numeric](38, 4) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptTopOutLet' AND XTYPE='P')
DROP PROCEDURE Proc_RptTopOutLet
GO
--EXEC Proc_RptTopOutLet 56,1,0,'',0,0,1,0
CREATE PROCEDURE Proc_RptTopOutLet
/************************************************************
* PROCEDURE	: Proc_RptTopOutLet
* PURPOSE	: To get Top Outlet
* CREATED BY	: Jisha Mathew
* CREATED DATE	: 12/12/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT,
	@Po_Errno		INT OUTPUT
	
)
AS
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @SSQL		AS 	VarChar(8000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	DECLARE @SelNetSales TABLE
	(	
		TotSelNetSales NUMERIC(38,2),
		TotSelBills INT,
		SelPrdCnt INT,
		Usrid INT
	)
	DECLARE @DBNetSales TABLE
	(	
		TotDBNetSales NUMERIC(38,2),
		TotDBBills INT,
		DBPrdCnt INT,
		Rtrid INT,
		Usrid INT
	)
	CREATE TABLE #TopOutlet
	(	
		SMId INT,
		SMName NVARCHAR(100),
		RMId INT,
		RMName NVARCHAR(100),
		RtrId INT,
		RtrCode NVARCHAR(50),
		RtrName NVARCHAR(100),
		CtgName NVARCHAR(100),
		ClassName NVARCHAR(100),
		NetSales NUMERIC(38,4),
		TotBills INT,
		PrdCnt INT,		
		TotSelNetSales NUMERIC(38,2),
		TotSelBills INT,
		SelPrdCnt INT,
		TotDBNetSales NUMERIC(38,2),
		TotDBBills INT,
		DBPrdCnt INT,
		UsrId INT	
	)
	CREATE  TABLE #RPTTOPOUTLET
	(
		SMId INT,
		SMName NVARCHAR(100),
		RMId INT,
		RMName NVARCHAR(100),
		RtrId INT,
		RtrCode NVARCHAR(50),
		RtrName NVARCHAR(100),
		CtgName NVARCHAR(100),
		ClassName NVARCHAR(100),
		NetSales NUMERIC(38,4),
		TotBills INT,
		PrdCnt INT,	
		TotSelNetSales NUMERIC(38,2),
		TotSelBills INT,
		SelPrdCnt INT,
		TotDBNetSales NUMERIC(38,2),
		TotDBBills INT,
		DBPrdCnt INT,
		UsrId INT	
	)
	DECLARE @TEMPRTRID TABLE
	(
		RTRID  INT
	)
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @PrdCatValId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @CmpId	 	AS	INT
	DECLARE @SMId           AS	INT
	DECLARE @RMId           AS	INT
	DECLARE @Basedon        AS	INT
	DECLARE @RtrId		AS 	INT
	DECLARE @CtgLevelId	AS 	INT
	DECLARE @RtrClassId	AS 	INT
	DECLARE @NoOfOutlets 	AS 	INT
	DECLARE @CtgMainId	AS 	INT	
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @NoOfOutlets = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,66,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	DELETE FROM #TopOutlet Where Usrid=@Pi_UsrId	
	DELETE FROM @SelNetSales Where Usrid=@Pi_UsrId
	DELETE FROM @DBNetSales Where Usrid=@Pi_UsrId
	DELETE FROM #RPTTOPOUTLET Where Usrid=@Pi_UsrId
	DELETE FROM @TEMPRTRID
	
	INSERT INTO @TEMPRTRID (RTRID)
	SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)
	,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL
	WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
		RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
		RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
	AND (RCL.CmpId = (CASE @CmpId WHEN 0 THEN RCL.CmpId ELSE 0 END) OR
		RCL.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	AND (RVC.CmpId = (CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
		RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		
	SET @TblName = 'RptTopOutLet'
	SET @TblStruct ='SMId INT,
			SMName NVARCHAR(100),
			RMId INT,
			RMName NVARCHAR(100),
			RtrId INT,
			RtrCode NVARCHAR(50),
			RtrName NVARCHAR(100),
			CtgName NVARCHAR(100),
			ClassName NVARCHAR(100),
			NetSales NUMERIC(38,4),
			TotBills INT,
			PrdCnt INT,		
			TotSelNetSales NUMERIC(38,2),
			TotSelBills INT,
			SelPrdCnt INT,
			TotDBNetSales NUMERIC(38,2),
			TotDBBills INT,
			DBPrdCnt INT'		
			
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,CtgName,ClassName,NetSales,
					  TotBills,PrdCnt,TotSelNetSales,TotSelBills,SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt'
			
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
		INSERT INTO #TopOutlet (SMId,SMName,RMID,RMName,Rtrid,RtrCode,RtrName,CtgName,ClassName,Netsales,TotBills,PrdCnt,
		TotSelNetSales,TotSelBills,SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt,UsrId)
		Select Distinct A.SMId,A.SMName,A.RMID,A.RMName,A.Rtrid,A.RtrCode,A.RtrName,CtgName,ValueClassName,SUM(Netsales) as Netsales,SUM(TotBills) AS TotBills,
		SUM(PrdCnt) AS PrdCnt,0 AS TotSelNetSales,0 AS TotSelBills,0 AS SelPrdCnt,
		0 AS TotDBNetSales,0 AS TotDBBills,0 AS DBPrdCnt,@Pi_UsrId as UsrId
		From
		(
			Select Distinct S.SMId,S.SMName,RM.RMID,RM.RMName,R.RtrId,R.RtrCode,R.RtrName,CtgName,ValueClassName,
			Isnull(Sum(SIP.PrdNetAmount),0) as Netsales,isnull(Count(Distinct SI.SalId),0) AS TotBills,
			Isnull(Count(Distinct SIP.Prdid),0) AS PrdCnt
			FROM Salesinvoice SI WITH (NOLOCK)
			INNER JOIN SalesinvoiceProduct  SIP WITH (NOLOCK) on SI.SalId=SIP.SalId
			INNER JOIN PRODUCT P ON SIP.Prdid=P.Prdid
			AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
				P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
				P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
			AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR
				p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN Salesman S WITH (NOLOCK) ON SI.SMid=S.SMid
			AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId Else 0 END) OR
				SI.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			INNER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMid=RM.RMid
			AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId Else 0 END) OR
			    	SI.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			INNER JOIN Retailer R WITH (NOLOCK) ON   SI.Rtrid=R.Rtrid
			INNER JOIN @TEMPRTRID TP ON TP.RTRID= SI.Rtrid AND TP.RTRID=R.Rtrid
			INNER JOIN RetailerValueClassMap RVM WITH (NOLOCK)ON  RVM.rtrid=SI.rtrid AND RVM.rtrid=R.rtrid
									AND RVM.rtrid=TP.rtrid
			INNER JOIN RetailerValueClass RV WITH (NOLOCK) ON RV.RtrClassId = RVM.RtrValueClassId
		    INNER JOIN RetailerCategory RC WITH (NOLOCK) ON RV.CtgMainId = RC.CtgMainId
    		WHERE
				Salinvdate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121) AND   RM.RMSRouteType=1
					AND Dlvsts In(4,5)
			GROUP BY S.SMId,S.SMName,RM.RMID,RM.RMName,R.Rtrid,R.RtrCode,R.RtrName,CtgName,ValueClassName		
			UNION ALL
			Select Distinct S.SMId,S.SMName,RM.RMID,RM.RMName,R.Rtrid,R.RtrCode,R.RtrName,CtgName,ValueClassName,
			-1*Isnull(Sum(PrdNetAmt),0) as Netsales,0 as TotBills,0 AS PrdCnt
			FROM ReturnHeader RH WITH (NOLOCK)
			INNER JOIN ReturnProduct  RHP WITH (NOLOCK) on RH.ReturnId=RHP.ReturnId
			INNER JOIN PRODUCT P ON RHP.PrdId=P.PrdId
			AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
				P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
				P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
			AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR
				p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN Salesman S WITH (NOLOCK) ON RH.SMId=S.SMId
			AND (RH.SMId = (CASE @SMId WHEN 0 THEN RH.SMId Else 0 END) OR
				RH.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			INNER JOIN RouteMaster RM WITH (NOLOCK) ON RH.RMid=RM.RMid
			AND (RH.RMId = (CASE @RMId WHEN 0 THEN RH.RMId Else 0 END) OR
			    	RH.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			INNER JOIN Retailer R WITH (NOLOCK) ON RH.RtrId=R.RtrId
			INNER JOIN @TEMPRTRID TP ON TP.RTRID= RH.Rtrid AND TP.RTRID=R.RtrId
			INNER JOIN RetailerValueClassMap RVM WITH (NOLOCK)ON  RVM.rtrid=RH.rtrid AND RVM.rtrid=R.rtrid
									AND RVM.rtrid=TP.rtrid
			INNER JOIN RetailerValueClass RV WITH (NOLOCK) ON RV.RtrClassId = RVM.RtrValueClassId
		    INNER JOIN RetailerCategory RC WITH (NOLOCK) ON RV.CtgMainId = RC.CtgMainId
			WHERE
				ReturnDate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121) AND   RM.RMSRouteType=1
			GROUP BY S.SMId,S.SMName,RM.RMID,RM.RMName,R.Rtrid,R.RtrCode,R.RtrName,CtgName,ValueClassName
		)A GROUP BY A.SMId,A.SMName,A.RMID,A.RMName,A.Rtrid,A.RtrCode,A.RtrName,CtgName,ValueClassName
		
		INSERT INTO @SelNetSales(TotSelNetSales,TotSelBills,SelPrdCnt,UsrId)
		SELECT SUM(Netsales) as TotSelNetSales,SUM(Totalbillcuts)  as TotSelBills ,SUM(TotalPrdCount) as SelPrdCnt,
		@Pi_UsrId  as Usrid From(
		SELECT SUM(SI.SalNetAmt) as Netsales,COUNT(Distinct si.salinvno) as Totalbillcuts,COUNT(Distinct SIP.PrdId) AS TotalPrdCount
		From Salesinvoice SI
		INNER JOIN SalesinvoiceProduct SIP ON SI.SalId = SIP.SalId
		INNER JOIN PRODUCT P ON SIP.Prdid=P.Prdid
		AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
		AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR
			p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE
			SI.Salinvdate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
			AND SI.Dlvsts In(4,5)
		Union all
		SELECT	-1 * SUM(PrdNetAmt) as Netsales,0 as TotalBillCut,0 as TotalPrdCount	
		From ReturnHeader RH
		INNER JOIN ReturnProduct RHP ON RH.ReturnId = RHP.ReturnId
		INNER JOIN PRODUCT P ON RHP.PrdId=P.PrdId
		AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
		AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR
			p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE ReturnDate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
		)y
		UPDATE #TopOutlet SET TotSelNetSales = A.TotSelNetSales,
					TotSelBills = A.TotSelBills,
					SelPrdCnt = A.SelPrdCnt
		From  @SelNetSales A,#TopOutlet B Where B.UsrId = @Pi_UsrId
		SET @SSQL='Insert INTO #RPTTOPOUTLET SELECT Distinct Top '+Cast(@NoOfOutlets as Varchar(5))+' SMId,SMName,RT.RMID,'+
			    'RMName,RT.RtrId,RT.RtrCode,RT.RtrName,CtgName,ClassName,Netsales,TotBills,PrdCnt,TotSelNetSales,TotSelBills, '+
			    ' SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt,UsrId From #TopOutlet Rt,Retailer R where '+
			    ' UsrId='+ Cast(@Pi_UsrId as Varchar(15))+' And RT.RtrId=R.RtrId Order by Netsales Desc '
		EXEC (@SSQL)
		INSERT INTO @DBNetSales(TotDBNetSales,TotDBBills,DBPrdCnt,UsrId)
		SELECT SUM(Netsales) as TotDBNetSales,SUM(Totalbillcuts)  as TotDBBills ,SUM(TotalPrdCount) as DBPrdCnt,
		@Pi_UsrId  as Usrid From(
		SELECT SUM(SI.SalNetAmt) as Netsales,COUNT(Distinct si.salinvno) as Totalbillcuts,COUNT(Distinct SIP.PrdId) AS TotalPrdCount
		From Salesinvoice SI
		INNER JOIN SalesinvoiceProduct SIP ON SI.SalId = SIP.SalId
		WHERE
			SI.Salinvdate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
			AND SI.Dlvsts In(4,5)
		Union all
		SELECT	-1 * SUM(PrdNetAmt) as Netsales,0 as TotalBillCut,0 as TotalPrdCount	
		From ReturnHeader RH,ReturnProduct RHP
		WHERE ReturnDate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
		and RH.ReturnId = RHP.ReturnId )x
		
		Update #RPTTOPOUTLET SET TotDBNetSales= A.TotDBNetSales,
					TotDBBills=A.TotDBBills,
					DBPrdCnt = A.DBPrdCnt
		From @DBNetSales A, #RPTTOPOUTLET B WHERE B.Usrid=@Pi_UsrId
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RPTTOPOUTLET' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				
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
					'(SnapId,RptId,' + @TblFields + ',UserId)' +
					' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
					--' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RPTTOPOUTLET'
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
			SET @SSQL = 'INSERT INTO #RPTTOPOUTLET ' +
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
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RPTTOPOUTLET
	SELECT * FROM #RPTTOPOUTLET
--IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
-- BEGIN  
--  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptTopOutLet_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
--  DROP TABLE RptTopOutLet_Excel  
--  SELECT * INTO RptTopOutLet_Excel FROM #RPTTOPOUTLET   
-- END   
--RETURN
--END
--Commented and added for BugNo:30561
DECLARE @RecCount AS BIGINT 
		SET @RecCount =(SELECT count(*) FROM #RPTTOPOUTLET)
    	IF @RecCount > 0
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RPTTOPOUTLET_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					BEGIN					
						DROP TABLE [RPTTOPOUTLET_Excel]
						CREATE TABLE RPTTOPOUTLET_Excel (SMId INT,SMName NVARCHAR(100),RMId INT,RMName NVARCHAR(100),RtrId INT,RtrCode NVARCHAR(50),RtrName NVARCHAR(100),NetSales NUMERIC(38,4),PercBusConDB NUMERIC(38,4),TotBills INT,
						PrdCnt INT,TotSelNetSales NUMERIC(38,2),TotSelBills INT,SelPrdCnt INT,TotDBNetSales NUMERIC(38,2),TotDBBills INT,DBPrdCnt INT,UsrId INT,TOTNetSales NUMERIC(38,4))
					END			
                IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TbpRPTTOPOUTLET')
					BEGIN 
						DROP TABLE TbpRPTTOPOUTLET
						SELECT * INTO TbpRPTTOPOUTLET FROM RPTTOPOUTLET_Excel WHERE 1=2
					END 
				 ELSE
					BEGIN 
						SELECT * INTO TbpRPTTOPOUTLET FROM RPTTOPOUTLET_Excel WHERE 1=2
					END 
				INSERT INTO TbpRPTTOPOUTLET (SMId ,SMName,NetSales)
					SELECT 999997,'Top Outlet Level',sum(NetSales) 
				FROM 
						#RPTTOPOUTLET
				INSERT INTO TbpRPTTOPOUTLET (SMId ,SMName,NetSales,TotBills,PrdCnt,TotSelNetSales,TotDBNetSales)
					SELECT DISTINCT 999998,'Selection Level',TotSelNetSales ,TotSelBills,SelPrdCnt,TotSelNetSales,TotDBNetSales
				FROM 
						#RPTTOPOUTLET
				INSERT INTO TbpRPTTOPOUTLET (SMId ,SMName,NetSales,TotBills,PrdCnt,TotSelNetSales,TotDBNetSales)
					SELECT DISTINCT 999999,'DB Level',TotDBNetSales,TotDBBills , DBPrdCnt,TotSelNetSales,TotDBNetSales
				FROM 
						#RPTTOPOUTLET
				INSERT INTO RPTTOPOUTLET_Excel (SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,NetSales,TotBills,PrdCnt,
							TotSelNetSales,TotSelBills,SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt)
                  SELECT SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,NetSales,TotBills,PrdCnt,
							TotSelNetSales,TotSelBills,SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt 
					FROM #RPTTOPOUTLET
				
				INSERT INTO RPTTOPOUTLET_Excel (SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,NetSales,TotBills,PrdCnt,
							TotSelNetSales,TotSelBills,SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt)
				SELECT SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,NetSales,TotBills,PrdCnt,
					TotSelNetSales,TotSelBills,SelPrdCnt,TotDBNetSales,TotDBBills,DBPrdCnt  
					FROM TbpRPTTOPOUTLET 
				UPDATE RPTTOPOUTLET_Excel SET TotSelNetSales=(SELECT TotSelNetSales FROM RPTTOPOUTLET_Excel WHERE SMID=999999)
				UPDATE RPTTOPOUTLET_Excel SET TotDBNetSales=(SELECT TotDBNetSales FROM RPTTOPOUTLET_Excel WHERE SMID=999999)
                UPDATE RPTTOPOUTLET_Excel SET TOTNetSales= (SELECT sum(NetSales) FROM #RPTTOPOUTLET WHERE SMId NOT IN (999997,999998,999999)) --WHERE SMId NOT IN (999997,999998,999999)
                UPDATE RPTTOPOUTLET_Excel SET PercBusConDB=(NetSales/TOTNetSales)*100 WHERE SMId NOT IN (999997,999998,999999)
				UPDATE RPTTOPOUTLET_Excel SET PercBusConDB=(TOTNetSales/TotSelNetSales)*100	 WHERE SMId=999997
				UPDATE RPTTOPOUTLET_Excel SET PercBusConDB=(TOTNetSales/TotDBNetSales)*100	 WHERE SMId=999998
			END			
RETURN
END
GO
DELETE FROM RptExcelHeaders WHERE Rptid=211
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (211,1,'Code','Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (211,2,'Name','Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (211,3,'Unit','Unit',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (211,4,'SalesValue','Sales Value',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (211,5,'EC','Effective Coverage',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (211,6,'TLS','Total Lines Sold',1,1)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='RptECAnalysisExcel' AND XTYPE='U')
DROP TABLE RptECAnalysisExcel
GO
CREATE TABLE RptECAnalysisExcel
(
		Code			NVARCHAR(200),
		Name	        NVARCHAR(200),		
		Unit 		    NUMERIC(38,6),
		SalesValue 		NUMERIC(38,6),		
		EC				INT,
		TLS				INT	
)
GO
DELETE FROM RptExcelHeaders WHERE RptId=210
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,1,'RtrId','Retailer ID',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,2,'RtrCode','Retailer Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,3,'RtrName','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,4,'RetailerCatName','Retailer Category',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,5,'RetailerCatLevelName','Retailer Classification',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,6,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,7,'PrdCcode','Short Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,8,'PrdName','Product Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,9,'SalesQuantity','Quantity',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,10,'SalesValue','Value',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (210,11,'SlNo','SlNo',0,1)
GO
--Parle_issues_Moorthi
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=251 and SlNo IN(22,23,24,26,27,29,30)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=251 and SlNo=32
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=1 and SlNo IN(1,6,12,13,15)
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=2 and SlNo IN(2,3,5,6,7,8,14,16,18,20)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=2 and SlNo NOT IN(2,3,5,6,7,8,14,16,18,20)
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=30 and SlNo<>1
GO
DELETE FROM RptExcelHeaders WHERE Rptid=60
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,1,'CmpId','CmpId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,2,'SMId','SMId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,3,'RMId','RMId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,4,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,5,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,6,'SMName','Salesman',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,7,'RMName','Route',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,8,'RtrCode','Retailer Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,9,'RtrName','Retailer',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,10,'PrdName','Product ',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,11,'Received','Order Received',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,12,'Serviced','Order Serviced',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,13,'Type','Type',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,14,'QtyFillRatio','Qty Fill Ratio',1,1)
GO
DELETE FROM RptFilter WHERE rptid=18 and SelcId=257 
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (18,257,0,'YES')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (18,257,1,'NO')
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=18 and SlNo IN(2,3,5,6,7,8,9,10,11,12,13,16)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=18 and SlNo NOT IN(2,3,5,6,7,8,9,10,11,12,13,16)
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=17 and SlNo IN(1,2,3,5,6,7,8,9,10,11,12,13)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=17 and SlNo NOT IN(1,2,3,5,6,7,8,9,10,11,12,13)
GO
UPDATE RptGroup SET VISIBILITY=1 where PId='DailyReports' and RPTID=216 and GrpCode='NetsalesReport'
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=216 and SlNo IN(3,4,6,7,8,10,11,12,13,15,16,17,18)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=216 and SlNo NOT IN(3,4,6,7,8,10,11,12,13,15,16,17,18)
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=51 and SlNo IN(2,4,5,6)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=51 and SlNo NOT IN(2,4,5,6)
GO
UPDATE RptExcelHeaders SET Displayname='Route' where rptid=51 and SlNo=4
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=54 and SlNo IN(2,4,6,7,8,9,10,11)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=54 and SlNo NOT IN(2,4,6,7,8,9,10,11)
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=233 and SlNo IN(2,3,5,6,8,9,10,11,12,13,14,15,16,17,18,19)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=233 and SlNo NOT IN(2,3,5,6,8,9,10,11,12,13,14,15,16,17,18,19)
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=19 
GO
DELETE FROM RptExcelHeaders WHERE RptId=182
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,1,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,2,'RtrCode','Retailer Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,3,'RtrName','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,4,'CrDays','Credit Days Allowed',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,5,'Bucket1','100-0',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,6,'Bucket2','4-5',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,7,'Bucket3','6-0',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,8,'Bucket4','22-00',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,9,'Bucket5','Bucket5',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,10,'NoBills','Number of Outstanding Bills',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,11,'BillOutStd','Outstanding Bill Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,14,'OnAccount','Total On Account Available',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,12,'Credit','Total Credit Note Available',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,13,'Debit','Total Debit Note Available',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,15,'NetOtStd','Net Outstanding',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,16,'Suppress','MonthCount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (182,17,'SalPayAmt','SalPayAmt',0,1)
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=4 and SlNo IN(5,6,8,9,10,11,12,13,14,15,16,18)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=4 and SlNo NOT IN(5,6,8,9,10,11,12,13,14,15,16,18)
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=3 and SlNo IN(2,4,7,9,10,12,13,14,15,16,17)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=3 and SlNo NOT IN(2,4,7,9,10,12,13,14,15,16,17)
GO
DELETE FROM RptExcelHeaders WHERE Rptid=53
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,1,'RtrBankId','RtrBankId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,3,'RtrBnkName','Drawee Bank',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,4,'RtrBnkBrID','RtrBnkBrID',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,5,'RtrBnkBrName','Drawee Branch',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,6,'DisBnkId','DisBnkId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,7,'DisBranchId','DisBranchId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,2,'DistributorBnkName','Retailer ',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,8,'DistributorBnkBrName','Invoice No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,9,'InvInsNo','Cheque No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,10,'InvInsDate','Cheque Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,11,'DepDate','Deposit Date',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (53,12,'InvInsAmt','Cheque Amount',1,1)
GO
UPDATE RptGroup SET VISIBILITY=1 where PId='DailyReports' and RPTID=169 and GrpCode='RptRtrWiseBrandWiseSales'
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=9 and SlNo IN(1,2,3,4,5,6,7,8,9,10,16,18,19,20,21,22)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=9 and SlNo NOT IN(1,2,3,4,5,6,7,8,9,10,16,18,19,20,21,22)
GO
UPDATE RptExcelHeaders SET DisplayName='Quantity' WHERE Rptid=9 and SlNo=10
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Rptid=12 and SlNo IN(1,2,4,6,7,9,11,12,13,15,16,18,20,21,22,23)
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=12 and SlNo NOT IN(1,2,4,6,7,9,11,12,13,15,16,18,20,21,22,23)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='RptReplacement_Excel' AND XTYPE='U')
DROP TABLE RptReplacement_Excel
GO
CREATE TABLE RptReplacement_Excel(
	[RepRefNo] [nvarchar](50) NULL,
	[RepDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](50) NULL,
	[PrdId] [int] NULL,
	[PrdDcode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[UserStockType] [nvarchar](50) NULL,
	[RtnQty] [int] NULL,
	[RtnRate] [numeric](38, 6) NULL,
	[RtnAmount] [numeric](38, 6) NULL,
	[RPrdId] [int] NULL,
	[RPrdDcode] [nvarchar](50) NULL,
	[RPrdName] [nvarchar](200) NULL,
	[RPrdBatId] [int] NULL,
	[RPrdBatCode] [nvarchar](50) NULL,
	[RUserStockType] [nvarchar](50) NULL,
	[RepQty] [int] NULL,
	[RepRate] [numeric](38, 6) NULL,
	[RepAmount] [numeric](38, 6) NULL,
	[RValue] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptReplacement' AND XTYPE='P')
DROP PROCEDURE Proc_RptReplacement
GO
--EXEC Proc_RptReplacement 12,1,0,'parlebug',0,0,1,0
CREATE PROCEDURE Proc_RptReplacement      
(      
	@Pi_RptId  INT,      
	@Pi_UsrId  INT,      
	@Pi_SnapId  INT,      
	@Pi_DbName  nvarchar(50),      
	@Pi_SnapRequired INT,      
	@Pi_GetFromSnap  INT,      
	@Pi_CurrencyId  INT,      
	@Po_Errno  INT OUTPUT      
)      
AS
/*********************************      
* PROCEDURE		: Proc_RptReplacement      
* PURPOSE		: To get the Replacement details for Report      
* CREATED		: Nandakumar R.G      
* CREATED DATE	: 30/07/2007      
* MODIFIED      
* DATE      AUTHOR     DESCRIPTION      
------------------------------------------------      
* {date} {developer}  {brief modification description}      
*********************************/      
BEGIN      
SET NOCOUNT ON       
	DECLARE @NewSnapId  AS INT      
	DECLARE @DBNAME  AS  nvarchar(50)      
	DECLARE @TblName  AS nvarchar(500)      
	DECLARE @TblStruct  AS nVarchar(4000)      
	DECLARE @TblFields  AS nVarchar(4000)      
	DECLARE @sSql  AS  nVarChar(4000)      
	DECLARE @ErrNo   AS INT      
	DECLARE @PurDBName AS nVarChar(50)      
	  
	DECLARE @RtnCnt   AS INT      
	DECLARE @RepCnt   AS INT      
	DECLARE @RepRefNo AS  NVARCHAR(50)      
	  
	   
	--Filter Variable       
	DECLARE @RtrId          AS Int      
	DECLARE @FromDate         AS DATETIME      
	DECLARE @ToDate           AS DATETIME      
	--Till Here      
	--Assgin Value for the Filter Variable      
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))      
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)      
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)      
	--Till Here    
	--Moorthi PrdName,RPrdName size change 50 to 200  
	Create TABLE #RptReplacement      
	(      
		RepRefNo             NVARCHAR(50),      
		RepDate              DATETIME,      
		RtrId                INT,      
		RtrName              NVARCHAR(50),      
		PrdId         INT,      
		PrdDcode       NVARCHAR(50),      
		PrdName        NVARCHAR(200),         
		PrdBatId             INT,      
		PrdBatCode        NVARCHAR(50),      
		UserStockType        NVARCHAR(50),      
		RtnQty               INT,      
		RtnRate              NUMERIC (38,6),      
		RtnAmount            NUMERIC (38,6),      
		RPrdId         INT,      
		RPrdDcode       NVARCHAR(50),      
		RPrdName        NVARCHAR(200),      
		RPrdBatId            INT,      
		RPrdBatCode    NVARCHAR(50),      
		RUserStockType       NVARCHAR(50),      
		RepQty               INT,      
		RepRate              NUMERIC (38,6),      
		RepAmount            NUMERIC (38,6),      
		RValue               NUMERIC (38,6)      
	)      
	SET @TblName = 'RptReplacement'      
	   
	SET @TblStruct = ' RepRefNo             NVARCHAR(50),      
			   RepDate              DATETIME,      
			   RtrId                INT,      
			   RtrName              NVARCHAR(50),      
			   PrdId         INT,      
			   PrdDcode       NVARCHAR(50),      
			   PrdName        NVARCHAR(200),      
			   PrdBatId             INT,      
			   PrdBatCode        NVARCHAR(50),      
			   UserStockType        NVARCHAR(50),      
			   RtnQty               INT,      
			   RtnRate              NUMERIC (38,6),      
			   RtnAmount            NUMERIC (38,6),      
			   RPrdId         INT,      
			   RPrdDcode       NVARCHAR(50),      
			   RPrdName        NVARCHAR(200),      
			   RPrdBatId            INT,      
			   RPrdBatCode    NVARCHAR(50),      
			   RUserStockType       NVARCHAR(50),      
			   RepQty               INT,      
			   RepRate              NUMERIC (38,6),      
			   RepAmount            NUMERIC (38,6),      
			   RValue               NUMERIC (38,6)'      
	SET @TblFields = 'RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,      
				   UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,      
				   RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue'      
	IF @Pi_GetFromSnap = 1      
	BEGIN      
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId      
		SET @DBNAME = @DBNAME      
	END      
	ELSE      
	BEGIN      
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3    SET @DBNAME = @PI_DBNAME + @DBNAME      
	END      
	  
	SET @Po_Errno = 0      
	   
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data      
	BEGIN      
		DECLARE Cur_Replacement      
		CURSOR FOR      
		SELECT RepRefNo FROM ReplacementHd WHERE RepDate BETWEEN @FromDate AND @ToDate      
		    
		OPEN Cur_Replacement      
		FETCH NEXT FROM Cur_Replacement      
		INTO @RepRefNo      
		WHILE @@FETCH_STATUS=0      
		BEGIN        
			SELECT Ret.RepRefNo,RH.RepDate,RH.RtrId,Rt.RtrName,Ret.SlNo,Ret.PrdId,Prd.PrdDcode,Prd.PrdName,Ret.PrdBatId,PrdBat.PrdBatCode,      
			Ret.StockTypeId,ST.UserStockType,ST.SystemStockType,Ret.RtnQty,Ret.SelRte,(Ret.Tax/Ret.RtnQty) AS Tax,Ret.RtnAmount      
			INTO #TempRtnDetails      
			FROM ReplacementIn Ret,Product Prd,ProductBatch PrdBat,StockType ST,ReplacementHd RH,Retailer Rt      
			WHERE Ret.PrdId=Prd.PrdId AND Ret.PrdBatId=PrdBat.PrdBatId AND Ret.StockTypeId=ST.StockTypeId AND      
			RH.RtrId=Rt.RtrId AND Ret.RepRefNo=RH.RepRefNo AND      
			(RH.RtrId=  (CASE @RtrId WHEN 0 THEN RH.RtrId ELSE 0 END ) OR      
			RH.RtrId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))      
			AND Ret.RepRefNo=@RepRefNo      
			SELECT Rep.RepRefNo,RH.RepDate,RH.RtrId,Rt.RtrName,Rep.SlNo AS RSlNo,Rep.PrdId AS RPrdId,Prd.PrdDcode AS RPrdDcode,Prd.PrdName AS RPrdName,Rep.PrdBatId AS RPrdBatId,PrdBat.PrdBatCode AS RPrdBatCode,      
			Rep.StockTypeId AS RStockTypeId,ST.UserStockType AS RUserStockType,ST.SystemStockType AS RSystemStockType,Rep.RepQty,Rep.SelRte AS RSelRte,(Rep.Tax/Rep.RepQty) AS RTax,Rep.RepAmount      
			INTO #TempRepDetails      
			FROM ReplacementOut Rep,Product Prd,ProductBatch PrdBat,StockType ST,ReplacementHd RH,Retailer Rt      
			WHERE Rep.PrdId=Prd.PrdId AND Rep.PrdBAtId=PrdBat.PrdBatId AND Rep.StockTypeId=ST.StockTypeId AND      
			RH.RtrId=Rt.RtrId AND Rep.RepRefNo=RH.RepRefNo AND      
			(RH.RtrId=  (CASE @RtrId WHEN 0 THEN RH.RtrId ELSE 0 END ) OR      
			RH.RtrId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))      
			AND Rep.RepRefNo=@RepRefNo      
			SELECT @RtnCnt=COUNT(*) FROM #TempRtnDetails      
			SELECT @RepCnt=COUNT(*) FROM #TempRepDetails         
			IF @RtnCnt<@RepCnt       
			BEGIN      
				INSERT INTO #RptReplacement(RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,      
				PrdName,PrdBatId,PrdBatCode,UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,      
				RPrdDcode,RPrdName,RPrdBatId,RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue)      
				SELECT Rpl.RepRefNo,Rpl.RepDate,Rpl.RtrId,Rpl.RtrName,ISNULL(Rtn.PrdId,0),ISNULL(Rtn.PrdDcode,''),      
				ISNULL(Rtn.PrdName,''),ISNULL(Rtn.PrdBatId,0),ISNULL(Rtn.PrdBatCode,''),ISNULL(Rtn.UserStockType,''),ISNULL(Rtn.RtnQty,0),      
				(ISNULL(Rtn.SelRte,0)+ISNULL(Rtn.Tax,0)) AS RtnRate,      
				Rtn.RtnAmount,Rpl.RPrdId,Rpl.RPrdDcode,Rpl.RPrdName,Rpl.RPrdBatId,Rpl.RPrdBatCode,      
				Rpl.RUserStockType,Rpl.RepQty,(Rpl.RSelRte+Rpl.RTax) AS RepRate,Rpl.RepAmount,      
				(ISNULL(Rtn.RtnAmount,0)-Rpl.RepAmount)AS RValue      
				FROM #TempRtnDetails Rtn       
				RIGHT OUTER JOIN #TempRepDetails Rpl ON Rtn.SlNo=Rpl.RSlNo AND       
				Rtn.RepRefNo=Rpl.RepRefNo      
			END      
			ELSE      
			BEGIN    
				
				INSERT INTO #RptReplacement(RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,      
				PrdName,PrdBatId,PrdBatCode,UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,      
				RPrdDcode,RPrdName,RPrdBatId,RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue)      
				SELECT Rtn.RepRefNo,Rtn.RepDate,Rtn.RtrId,Rtn.RtrName,Rtn.PrdId,Rtn.PrdDcode,      
				Rtn.PrdName,Rtn.PrdBatId,Rtn.PrdBatCode,Rtn.UserStockType,Rtn.RtnQty,      
				(Rtn.SelRte+Rtn.Tax) AS RtnRate,      
				Rtn.RtnAmount,ISNULL(Rpl.RPrdId,0),ISNULL(Rpl.RPrdDcode,''),ISNULL(Rpl.RPrdName,''),ISNULL(Rpl.RPrdBatId,0),ISNULL(Rpl.RPrdBatCode,''),      
				ISNULL(Rpl.RUserStockType,''),ISNULL(Rpl.RepQty,0),(ISNULL(Rpl.RSelRte,0)+ISNULL(Rpl.RTax,0)) AS RepRate,ISNULL(Rpl.RepAmount,0),      
				(Rtn.RtnAmount-ISNULL(Rpl.RepAmount,0))AS RValue      
				FROM #TempRtnDetails Rtn       
				LEFT OUTER JOIN #TempRepDetails Rpl ON Rtn.SlNo=Rpl.RSlNo AND       
				Rtn.RepRefNo=Rpl.RepRefNo    
				
			END        
			DROP TABLE #TempRtnDetails      
			DROP TABLE #TempRepDetails      
			FETCH NEXT FROM Cur_Replacement      
			INTO @RepRefNo      
		END      
		CLOSE Cur_Replacement      
		DEALLOCATE Cur_Replacement      
		IF LEN(@PurDBName) > 0      
		BEGIN      
			SET @SSQL = 'INSERT INTO #RptReplacement ' + '(' + @TblFields + ')' +      
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName      
			+' WHERE (RtrId=  (CASE '+CAST(@RtrId AS VARCHAR(10))+' WHEN 0 THEN RtrId ELSE 0 END ) OR      
			RtrId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters( '+CAST(@Pi_RptId AS VARCHAR(10))+',3,'+CAST(@Pi_UsrId AS VARCHAR(10))+')))      
			AND RepDate BETWEEN '+CAST(@FromDate AS VARCHAR(10))+' AND '+CAST(@ToDate AS VARCHAR(10))+''      
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptReplacement'      
			EXEC (@SSQL)      
			PRINT 'Saved Data Into SnapShot Table'      
		END      
	END      
	ELSE    --To Retrieve Data From Snap Data      
	BEGIN      
		PRINT @Pi_DbName      
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,      
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT      
		PRINT @ErrNo      
		IF @ErrNo = 0      
		BEGIN      
			SET @SSQL = 'INSERT INTO #RptReplacement ' +      
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
			SET @Po_Errno = 1      
			PRINT 'DataBase or Table not Found'      
			RETURN      
		END      
	END      
	   
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId      
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)      
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptReplacement      
	--->Added By Nanda on 24/12/2010
	select * from #RptReplacement
	
	DELETE FROM RptReplacement_Excel
	INSERT INTO RptReplacement_Excel(RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,UserStockType,
	RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue)
	SELECT RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,UserStockType,
	RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue FROM #RptReplacement
	--->Till Here
	-- SELECT * FROM #RptReplacement  CAST(RtnQty AS INT) CAST(RepQty AS INT)  
	-- Added on 25-Jun-2009
	SELECT RepRefNo,RepDate,RtrId,RtrName,A.PrdId,A.PrdDcode,PrdName,PrdBatId,      
	PrdBatCode,UserStockType,RtnQty,    
	---
	--Case When CAST(RtnQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As Uom1,
	--Case When (CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as Uom2,
	--Case When (CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	--(CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as Uom3,
	--Case When CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
	--CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as Uom4,
	---- Modified on 09-Jul-2009
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RtnQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(RtnQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(RtnQty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(RtnQty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(RtnQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(RtnQty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(RtnQty) AS INT) End			
		ELSE CAST(Sum(RtnQty) AS INT) END
	END as Uom4,
	--- Modified end here on 09-Jul-2009
	RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,    
	RPrdBatCode,RUserStockType,RepQty,    
	--Case When CAST(RepQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(RepQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As RepUom1,
	--Case When (CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as RepUom2,
	--Case When (CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	--(CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as RepUom3,
	--Case When CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
	--CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as RepUom4,    
	--- Modified  on 09-Jul-2009
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RepQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RepQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As RepUom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as RepUom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as RepUom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(RepQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(RepQty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(RepQty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(RepQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(RepQty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(RepQty) AS INT) End			
		ELSE CAST(Sum(RepQty) AS INT) END
	END as RepUom4,
	--- Modified end here on 09-Jul-2009
	RepRate,RepAmount,RValue  INTO #RptReplacementGrid
	FROM #RptReplacement A,View_ProdUOMDetails B WHERE a.PrdId=b.PrdId    
	GROUP BY RepRefNo,RepDate,RtrId,RtrName,A.PrdId,A.PrdDcode,PrdName,PrdBatId,      
	PrdBatCode,UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,    
	RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1
	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId  
	INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,C19,C20,C21,C22,C23,c24,c25,c26,Rptid,Usrid)  
	SELECT RepRefNo,RepDate,RtrName,PrdDcode,PrdName,PrdBatCode,UserStockType,RtnQty,Uom1,Uom2,Uom3,Uom4,RtnRate,RtnAmount,RPrdDcode,RPrdName,RPrdBatCode,RUserStockType,RepQty,RepUom1,RepUom2,RepUom3,RepUom4,RepRate,RepAmount,RValue,@Pi_RptId,@Pi_UsrId  
	FROM #RptReplacementGrid  
	--- End here 25-Jun-2009  
	-- Added on 20-Jun-2009    
	SELECT RepRefNo,RepDate,RtrId,RtrName,A.PrdId,A.PrdDcode,PrdName,PrdBatId,      
	PrdBatCode,UserStockType,RtnQty,    
	--Case When CAST(RtnQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As Uom1,    
	--Case When (CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as Uom2,    
	--Case When (CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then    
	--(CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as Uom3,    
	--Case When CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))  
	--*nullif(ConverisonFactor3,0))+(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then    
	--CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+    
	--(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as Uom4,    
	---- Modified on 09-Jul-2009
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RtnQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(RtnQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(RtnQty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(RtnQty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(RtnQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(RtnQty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(RtnQty) AS INT) End			
		ELSE CAST(Sum(RtnQty) AS INT) END
	END as Uom4,
	--- Modified end here on 09-Jul-2009
	RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,    
	RPrdBatCode,RUserStockType,RepQty,    
	--
	--Case When CAST(RepQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(RepQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As RepUom1,
	--Case When (CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as RepUom2,
	--Case When (CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	--(CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as RepUom3,
	--Case When CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
	--CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as RepUom4,    
	--- Modified  on 09-Jul-2009
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RepQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RepQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As RepUom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as RepUom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as RepUom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(RepQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(RepQty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(RepQty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(RepQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(RepQty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(RepQty) AS INT) End			
		ELSE CAST(Sum(RepQty) AS INT) END
	END as RepUom4,
	--- Modified end here on 09-Jul-2009
	RepRate,RepAmount,RValue    
	FROM #RptReplacement A LEFT OUTER JOIN View_ProdUOMDetails B ON a.PrdId=b.PrdId    
	GROUP BY RepRefNo,RepDate,RtrId,RtrName,A.PrdId,A.PrdDcode,PrdName,PrdBatId,      
	PrdBatCode,UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,    
	RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1
	-- End here      
	RETURN      
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptSalesReturn' AND XTYPE='P')
DROP PROCEDURE Proc_RptSalesReturn
GO
--EXEC Proc_RptSalesReturn 9,2,0,'VER2.5-REPORTS',0,0,1
CREATE PROCEDURE Proc_RptSalesReturn
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
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_RptSalesReturn
* PURPOSE: Sales Return Report
* NOTES:
* CREATED: Boopathy.P	30-07-2007
* MODIFIED: Aarthi	09-09-2009
* DESCRIPTION: Added Salesman Name and Route Name fields
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	--Filter Variable
	DECLARE @FromDate	AS 	DateTime
	DECLARE @ToDate		AS	DateTime
	DECLARE @CmpId   	AS	Int
	DECLARE @RtrId   	AS	Int
	DECLARE @SMId   	AS	Int
	DECLARE @RMId   	AS	Int
	DECLARE @SalesRtn  	AS	Int
	DECLARE @ETLFlag 	AS 	INT
	DECLARE @GridFlag 	AS 	INT
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @RMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @SMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @SalesRtn = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,32,@Pi_UsrId))
	--Till Here
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	Create TABLE #RptSalesReturn
		(	
			[SRN Number] 		nVarchar(50),
			[SR Date]			DATETIME,
			[Salesman]			nVarchar(100),
			[Route Name]		nVarchar(100),
			[Retialer Name]		nVarchar(100),
			[Bill No]		    nVarchar(50),
			[Product Code]	    nVarchar(50),
			[Product Description]	nVarchar(100),
			[Stock Type]		nVarchar(50),
			[Quantity (Base Qty)]	INT,
			Uom1	INT,
			Uom2	INT,
			Uom3	INT,
			Uom4	INT,
			SeqId			INT,
			[Gross Amount]		NUMERIC(38,6),
			FieldDesc	        nVarchar(100),
			LineBaseQtyAmt	    NUMERIC(38,6),
			[Net Amount]		NUMERIC(38,6),
			[UsrId]		INT
		)
	SET @TblName = 'RptSalesReturn'
	SET @TblStruct = '	[SRN Number] 		nVarchar(50),
	           			[SR Date]			DATETIME,
					[Salesman]			nVarchar(100),
					[Route Name]		nVarchar(100),
					[Retialer Name]		nVarchar(100),
					[Bill No]		    nVarchar(50),
	           		[Product Code]	    nVarchar(50),
	   				[Product Description]	nVarchar(100),
	           		[Stock Type]		nVarchar(50),
					[Quantity (Base Qty)]	INT,
	          		 SeqId			INT,
	           		[Gross Amount]		NUMERIC(38,6),
					[FieldDesc]	        nVarchar(100),
					[LineBaseQtyAmt]	    NUMERIC(38,6),
					[Net Amount]		NUMERIC(38,6),
					[UsrId]		INT'
	SET @TblFields = '[SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No],
				   [Product Code],[Product Description],[Stock Type],
	[Quantity (Base Qty)],SeqId,[Gross Amount],FieldDesc,
	LineBaseQtyAmt,[Net Amount],[UsrId]'
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
	EXEC Proc_ReportSalesReturnValues @Pi_RptId,@Pi_UsrId
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptSalesReturn ([SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No],
				   [Product Code],[Product Description],[Stock Type],[Quantity (Base Qty)],SeqId,[Gross Amount],FieldDesc,
			   LineBaseQtyAmt,[Net Amount],[UsrId])
SELECT [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
			   [Bill No],[Product Code],[Product Description], [Stock Type],sum([Quantity (Base Qty)]) qty,SeqId,
			   sum([Gross Amount]) as[Gross Amount],FieldDesc,sum(LineBaseQtyAmt),sum([Net Amount])[Net Amount],CAST(@Pi_UsrId as INT)
FROM 
(SELECT [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
			   [Bill No],[Product Code],[Product Description],
			   [Stock Type],[Quantity (Base Qty)],SeqId,
			   [Gross Amount],FieldDesc,LineBaseQtyAmt,[Net Amount],[prdbatid]
			   FROM TempReportSalesReturnValues
		WHERE (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
			  RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						
			AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
					 RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								
			AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					 SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (CmpId=(CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
					 CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				
			AND ([SR Date] Between @FromDate and @ToDate)
			AND (ReturnId=(CASE @SalesRtn WHEN 0 THEN ReturnId ELSE 0 END) OR
					 ReturnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,32,@Pi_UsrId)))
			AND Status = 0)A
GROUP BY [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
			   [Bill No],[Product Code],[Product Description],
			   [Stock Type],SeqId,FieldDesc
	--AND (ReturnId =@SalesRtn)
		
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptSalesReturn ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
			
		' WHERE (RtrId = (CASE ' + CAST(@RtrId as INTEGER) + ' WHEN 0 THEN RtrId ELSE 0 END) OR
			      RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))
							
		AND (RMId=(CASE ' + CAST(@RMId as INTEGER) + ' WHEN 0 THEN RMId ELSE 0 END) OR
			      RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) + ')))
							
		AND (SMId=(CASE ' + CAST(@SMId as INTEGER) + ' WHEN 0 THEN SMId ELSE 0 END) OR
			      SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) +')))
		AND (CmpId=(CASE '+ CAST(@CmpId as INTEGER) + ' WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters('+ CAST(@Pi_RptId as INTEGER) +',4,'+ CAST(@Pi_UsrId as INTEGER) +')))
			
		AND ([SR Date] Between ' + @FromDate + ' and  ' + @ToDate + ')
		AND (ReturnId=(CASE ''@SalesRtn'' WHEN 0 THEN ReturnId ELSE 0 END) OR
			      ReturnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId +',32,' + @Pi_UsrId +')))'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
	       [Bill No],[Product Code],[Product Description],
	       [Stock Type],[Quantity (Base Qty)],SeqId,
	       [Gross Amount],FieldDesc,LineBaseQtyAmt,[Net Amount],UsrId FROM #RptSalesReturn'
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
			SET @SSQL = 'INSERT INTO #RptSalesReturn ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSalesReturn
	-- Till Here
	SELECT * FROM #RptSalesReturn
	SELECT @GridFlag=GridFlag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	SELECT @ETLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @ETLFlag=1 OR @GridFlag=1
	BEGIN
		--EXEC Proc_RptSalesReturn 9,1,0,'CoreStocky',0,0,1
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @SRNDate DATETIME
		DECLARE  @PrdCode NVARCHAR(100)
		DECLARE  @SrnNo NVARCHAR(100)
		DECLARE  @BillNo NVARCHAR(100)	
		DECLARE  @StkType NVARCHAR(100)
		DECLARE  @SeqId INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
/*-----------------*/
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesReturn_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [dbo].[RptSalesReturn_Excel]
		DELETE FROM RptExcelHeaders Where RptId=9 AND SlNo>15
		CREATE TABLE RptSalesReturn_Excel (SRNNumber NVARCHAR(100),SRDate DATETIME,SMName NVARCHAR(100),RMName NVARCHAR(100), RtrName NVARCHAR(100),
						BillNo NVARCHAR(100),PrdCode NVARCHAR(100),PrdName NVarchar(500),
				  		StockType NVARCHAR(100),Qty BIGINT,UsrId INT,Uom1 BIGINT,Uom2 BIGINT,Uom3 BIGINT,Uom4 BIGINT)
		
		SET @iCnt=16
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT(Fielddesc),SeqId FROM #RptSalesReturn ORDER BY SeqId
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@SeqId
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptSalesReturn_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@SeqId
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur
		
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Rptid=9 and SlNo=17   ---Moorthi For Bug id :30528 Excel Spl disc
		
	/*-------------------------*/
		DELETE FROM RptSalesReturn_Excel
		INSERT INTO RptSalesReturn_Excel (SRNNumber ,SRDate ,SMName,RMName,RtrName ,BillNo ,PrdCode ,PrdName ,StockType ,Qty  ,UsrId,Uom1,Uom2,Uom3,Uom4)
		select [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No], [Product Code],[Product Description],[Stock Type],SUM(DISTINCT [Quantity (Base Qty)]),@Pi_UsrId,
		0 AS Uom1,0 AS Uom2,0 AS Uom3,0 AS Uom4 from (
		SELECT DISTINCT A.[SRN Number],A.[SR Date],[Salesman],[Route Name],A.[Retialer Name],A.[Bill No], A.[Product Code],A.[Product Description],A.[Stock Type],A.[Quantity (Base Qty)],
		0 AS Uom1,0 AS Uom2,0 AS Uom3,0 AS Uom4 FROM #RptSalesReturn A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
		)A GROUP BY A.[SRN Number],A.[SR Date],A.[Salesman],A.[Route Name],A.[Retialer Name],A.[Bill No], A.[Product Code],A.[Product Description],A.[Stock Type] 
		DECLARE Values_Cur CURSOR FOR
		select distinct [SRN Number],[SR Date],[Product Code],[Bill No],[Stock Type],FieldDesc,sum(LineBaseQtyAmt) from (
		SELECT DISTINCT  [SRN Number],[SR Date],[Product Code],[Bill No],[Stock Type],FieldDesc,LineBaseQtyAmt FROM #RptSalesReturn)A
		group by [SRN Number],[SR Date],[Product Code],[Bill No],[Stock Type],FieldDesc
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @SrnNo,@SRNDate,@PrdCode,@BillNo,@StkType,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSalesReturn_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE SRNNumber='''+ CAST(@SrnNo AS VARCHAR(1000)) + ''' AND SRDate=''' + CAST(@SRNDate AS VARCHAR(1000)) + '''
					AND PrdCode=''' + CAST(@PrdCode AS VARCHAR(1000))+''' AND  BillNo=''' + CAST(@BillNo As VARCHAR(1000)) + ''' AND StockType='''+ CAST(@StkType AS VARCHAR(100))+ ''' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @SrnNo,@SRNDate,@PrdCode,@BillNo,@StkType,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSalesReturn_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSalesReturn_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/******************************************************************************************************/
	END
	IF @GridFlag=1
	BEGIN
		SELECT DISTINCT
			SRNNumber,SRDate,SMName,RMName,RtrName,BillNo,PrdCode,PrdName,StockType,Qty,UsrId,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Qty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(Qty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Qty AS INT)-((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
				(CAST(Qty AS INT)-((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
			CASE
				WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN
				Case When
					CAST(Qty AS INT)-(((CAST(Qty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Qty AS INT)-((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(Qty AS INT)-(((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Qty AS INT)-((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
					ELSE
						CASE
							WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
								Case
									When CAST(Sum(Qty) AS INT)>=Isnull(ConverisonFactor2,0) Then
										CAST(Sum(Qty) AS INT)%nullif(ConverisonFactor2,0)
									Else CAST(Sum(Qty) AS INT) End
							WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
								Case
									When CAST(Sum(Qty) AS INT)>=Isnull(ConverisonFactor3,0) Then
										CAST(Sum(Qty) AS INT)%nullif(ConverisonFactor3,0)
									Else CAST(Sum(Qty) AS INT) End			
						ELSE CAST(Sum(Qty) AS INT) END
				END as Uom4
						--,[Gross Amount],[Spl. Disc],[Sch Disc],[DB Disc],[CD Disc],[Tax Amt],[Net Amount]
				INTO #TEMP1234
			FROM RptSalesReturn_Excel A, View_ProdUOMDetails B WHERE PrdCode=b.PrdDcode AND UsrId  = @Pi_UsrId
			GROUP BY ConverisonFactor3,ConverisonFactor4,ConverisonFactor2,ConversionFactor1,
					 SRNNumber,SRDate,RtrName,BillNo,PrdCode,PrdName,StockType,Qty,UsrId,SMName,RMName
						--,[Gross Amount],[Spl. Disc],[Sch Disc],[DB Disc],[CD Disc],[Tax Amt],[Net Amount]
		UPDATE RptSalesReturn_Excel SET Uom1 = b.Uom1 , Uom2 = b.Uom2 , uom3 = b.uom3 , uom4 = b.uom4
		FROM RptSalesReturn_Excel a ,#TEMP1234 B
		WHERE a.SRNNumber = b.SRNNumber AND a.BillNo = b.BillNo AND a.PrdCode = B.PrdCode
	---- Added on 25-Jun-2009
		SELECT * INTO #RptSalesReturnGrid
		FROM RptSalesReturn_Excel A
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,c15,C16,c17,C18,C19,C20,C21,Rptid,Usrid)
		SELECT SRNNumber,SRDate,SMName,RMName,RtrName,BillNo,PrdCode,PrdName,StockType,Qty,Uom1,Uom2,Uom3,Uom4,[Gross Amount],[Spl. Disc],[Sch Disc],[DB Disc],[CD Disc],[Tax Amt],[Net Amount],@Pi_RptId,@Pi_UsrId
		FROM #RptSalesReturnGrid
		--- End here on 25-Jun-2009
		INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
		VALUES(9,@iCnt,'Uom1','Case',1,1)
		SET @iCnt=@iCnt+1
		INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
		VALUES(9,@iCnt,'Uom2','Box',1,1)
		SET @iCnt=@iCnt+1
		INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
		VALUES(9,@iCnt,'Uom3','Strips',1,1)
		SET @iCnt=@iCnt+1
		INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
		VALUES(9,@iCnt,'Uom3','Piece',1,1)
		--Till Here
	END
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptQuantityRatioReport' AND XTYPE='P')
DROP PROCEDURE Proc_RptQuantityRatioReport
GO
--EXEC Proc_RptQuantityRatioReport 60,1,0,'ParleBug',0,0,1  
CREATE PROCEDURE Proc_RptQuantityRatioReport
(  
 @Pi_RptId  INT,  
 @Pi_UsrId  INT,  
 @Pi_SnapId  INT,  
 @Pi_DbName  nvarchar(50),  
 @Pi_SnapRequired INT,  
 @Pi_GetFromSnap  INT,  
 @Pi_CurrencyId  INT  
)  
AS  
/************************************************************  
* VIEW : Proc_RptQuantityRatioReport  
* PURPOSE : To get the Order Quantity Details  
* CREATED BY : Mahalakshmi.A  
* CREATED DATE : 17/12/2007  
* NOTE  :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*************************************************************/  
BEGIN  
SET NOCOUNT ON  
 DECLARE @NewSnapId  AS INT  
 DECLARE @DBNAME  AS  nvarchar(50)  
 DECLARE @TblName  AS nvarchar(500)  
 DECLARE @TblStruct  AS nVarchar(4000)  
 DECLARE @TblFields  AS nVarchar(4000)  
 DECLARE @sSql  AS  nVarChar(4000)  
 DECLARE @ErrNo   AS INT  
 DECLARE @PurDBName AS nVarChar(50)  
 --Filter Variables  
 DECLARE @FromDate AS DATETIME  
 DECLARE @ToDate   AS DATETIME  
 DECLARE @CmpId   AS INT  
 DECLARE @SMId   AS INT  
 DECLARE @RMId   AS INT  
 DECLARE @RtrId   AS INT  
 DECLARE @PrdCatId AS INT  
 DECLARE @PrdId  AS INT  
 DECLARE @CtgLevelId AS  INT  
 DECLARE @RtrClassId AS  INT  
 DECLARE @CtgMainId  AS  INT  
 DECLARE @TypeId  AS INT  
 ----Till Here  
 --Assgin Value for the Filter Variable  
 SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
 SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
 SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))  
 SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
 SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))  
 SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))  
 SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))  
 SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))  
 SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))  
 SET @TypeId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,73,@Pi_UsrId))  
 EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
 SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
 SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
 SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
 EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
 ---Till Here  
 Create TABLE #RptQuantityRatioReport  
 (  
    CMPID  INT,  
    SMID  INT,  
    RMID  INT,  
    RTRID  INT,  
    PRDID  INT,  
    SMNAME  NVARCHAR(100),  
    RMNAME  NVARCHAR(100),  
    RTRNAME  NVARCHAR(100),  
    RTRCODE  NVARCHAR(100),  
    PRDNAME  NVARCHAR(100),  
    RECEIVED Numeric(18,6),  
    SERVICED Numeric(18,6),  
    Type  INT  
 )  
 SET @TblName = 'RptQuantityRatioReport'  
 SET @TblStruct = ' CMPID  INT,  
    SMID  INT,  
    RMID  INT,  
    RTRID  INT,  
    PRDID  INT,  
    SMNAME  NVARCHAR(100),  
    RMNAME  NVARCHAR(100),  
    RTRNAME  NVARCHAR(100),  
    RTRCODE  NVARCHAR(100),  
    PRDNAME  NVARCHAR(100),  
    RECEIVED Numeric(18,6),  
    SERVICED Numeric(18,6),  
    Type  INT'  
 SET @TblFields = 'CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type'  
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
 IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
 BEGIN  
  Execute Proc_QuantityFillRatio @Pi_RptId,@Pi_UsrId,@TypeId  
  IF @TypeID=1  
  BEGIN  
   INSERT INTO #RptQuantityRatioReport (CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type )  
   SELECT DISTINCT CMPID,SMID,RMID,RTRID,'',SMNAME,RMNAME,RTRNAME,RTRCODE,'',SUM(RECEIVED) AS RECEIVED,SUM(SERVICED)AS SERVICED,Type  
    FROM TempOrderChange   
   WHERE  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
     CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
    AND  
    (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
     SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
    AND  
    (RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
     RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND  
    (CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR  
     CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
    AND  
    (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR  
     RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))   
    AND  
    (RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR  
     RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
    AND  
    (CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR  
     CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
    AND   
    (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
    PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
    GROUP BY CMPID,SMID,RMID,RTRID,SMNAME,RMNAME,RTRNAME,RTRCODE,Type  
  END  
  IF @TypeID=2  
  BEGIN  
   INSERT INTO #RptQuantityRatioReport (CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type )  
   SELECT DISTINCT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED ,SERVICED,Type  
   FROM TempOrderChange   
   WHERE  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
    CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
   AND  
   (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
    SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
   AND  
   (RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
    RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
   AND  
   (CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR  
    CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
   AND  
   (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR  
    RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))   
   AND  
   (RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR  
    RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND  
   (CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR  
    CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND   
   (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
   PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
   GROUP BY CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type  
  END  
IF @TypeID=3 --Value Fill
	INSERT INTO #RptQuantityRatioReport (CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type )  
	SELECT DISTINCT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED ,SERVICED,Type  
	FROM TempOrderChange   
	WHERE  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
    CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
   AND  
   (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
    SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
   AND  
   (RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
    RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
   AND  
   (CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR  
    CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
   AND  
   (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR  
    RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))   
   AND  
   (RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR  
    RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND  
   (CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR  
    CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND   
   (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
   PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
   GROUP BY CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type 
  IF LEN(@PurDBName) > 0  
  BEGIN  
   EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT  
   SET @SSQL = 'INSERT INTO #RptQuantityRatioReport ' +  
    '(' + @TblFields + ')' +  
    ' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName   
    + 'WHERE BillStatus=1  AND (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '  
    + 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '  
    + 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'  
    + 'AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '  
    + 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'  
    + 'AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '  
    + 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND(CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR'  
    + 'CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters('+  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',29,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'  
    + 'AND(RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR '  
    + 'RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters('+  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',31,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND(CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR '  
    + 'CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters('+  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',30,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR '  
    + 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND OrderDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''  
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
     ' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptQuantityRatioReport'  
    EXEC (@SSQL)  
    PRINT 'Saved Data Into SnapShot Table'  
   END  
  END  
 END  
 ELSE    --To Retrieve Data From Snap Data  
 BEGIN  
  EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
    @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
  PRINT @ErrNo  
  IF @ErrNo = 0  
  BEGIN  
   SET @SSQL = 'INSERT INTO #RptQuantityRatioReport ' +  
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
 SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptQuantityRatioReport  
 -- Till Here  
 --SELECT * FROM #RptQuantityRatioReport  
 --SELECT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRCODE,RTRNAME,PRDNAME,RECEIVED,SERVICED,Type  
 --FROM #RptQuantityRatioReport  
 -- CHANGES MADE BY MOORTHI  FOR EXCEL COL FILL RATIO
 SELECT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRCODE,RTRNAME,PRDNAME,RECEIVED,SERVICED,Type,((SERVICED/RECEIVED)*100) as FillRate  
 FROM #RptQuantityRatioReport 
 RETURN  
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptCollectionReport' AND XTYPE='P')
DROP PROCEDURE Proc_RptCollectionReport
GO
--EXEC Proc_RptCollectionReport 4,1,0,'CoreStocky',0,0,1
 CREATE PROCEDURE Proc_RptCollectionReport
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
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @DlvRId		AS  INT
	DECLARE @SColId		AS  INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @TypeId		AS	INT
	DECLARE @TotBillAmount	AS	NUMERIC(38,6)
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @DlvRId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	SET @SColId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))	
	IF @SColId=1
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo IN (2,3) AND RptId = @Pi_RptId   --- RptId = @Pi_UsrId  --MOORTHI
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo IN (5,6) AND RptId = @Pi_RptId    ---RptId = @Pi_UsrId  --MOORTHI
	END
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo IN (2,3) AND RptId = @Pi_RptId    --RptId = @Pi_UsrId --MOORTHI
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo IN (5,6) AND RptId = @Pi_RptId     --RptId = @Pi_UsrId --MOORTHI
	END
	CREATE TABLE #RptCollectionDetail
	(
		SalId 			BIGINT,
		SalInvNo		NVARCHAR(50) collate database_default,
		SalInvDate              DATETIME,
		SalInvRef 		NVARCHAR(50),
		RtrId 			INT,
		RtrName                 NVARCHAR(50) collate database_default,
		BillAmount              NUMERIC (38,6),
		CrAdjAmount             NUMERIC (38,6),
		DbAdjAmount             NUMERIC (38,6),
		CashDiscount		NUMERIC (38,6),
		CollectedAmount         NUMERIC (38,6),
		BalanceAmount           NUMERIC (38,6),
		PayAmount           	NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		AmtStatus 			NVARCHAR(10) collate database_default,
		InvRcpDate			DATETIME,
		CurPayAmount        NUMERIC (38,6),
		CollCashAmt			NUMERIC (38,6),
		CollChqAmt			NUMERIC (38,6),
		CollDDAmt			NUMERIC (38,6),
		CollRTGSAmt			NUMERIC (38,6),
		[CashBill]			[numeric](38, 0) NULL,
		[ChequeBill]		[numeric](38, 0) NULL,
		[DDbill]			[numeric](38, 0) NULL,
		[RTGSBill]			[numeric](38, 0) NULL,
		[TotalBills]		[numeric](38, 0) NULL,		
		InvRcpNo			nvarchar(50) 
		
	)
	SET @TblName = 'RptCollectionDetail'
	SET @TblStruct = '	SalId 			BIGINT,
				SalInvNo		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				RtrId 			INT,
				RtrName                 NVARCHAR(50),
				BillAmount              NUMERIC (38,6),
				CrAdjAmount             NUMERIC (38,6),
				DbAdjAmount             NUMERIC (38,6),
				CashDiscount		NUMERIC (38,6),
				CollectedAmount         NUMERIC (38,6),
				BalanceAmount           NUMERIC (38,6),
				PayAmount           	NUMERIC (38,6),
				TotalBillAmount		NUMERIC (38,6),
				AmtStatus 		NVARCHAR(10),
				InvRcpDate		DATETIME,
				CurPayAmount           	NUMERIC (38,6),
				CollCashAmt NUMERIC (38,6),
				CollChqAmt NUMERIC (38,6),
				CollDDAmt  NUMERIC (38,6),
				CollRTGSAmt NUMERIC (38,6),
				[CashBill] [numeric](38, 0) NULL,
				[ChequeBill] [numeric](38, 0) NULL,
				[DDbill] [numeric](38, 0) NULL,
				[RTGSBill] [numeric](38, 0) NULL,
				[TotalBills]		[numeric](38, 0) NULL,
				InvRcpNo nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
				'
	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,[CashBill],[ChequeBill],[DDbill],[RTGSBill],[TotalBills],InvRcpNo'
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
	IF @TypeId=1 
	BEGIN
		EXEC Proc_CollectionValues 4
		
	END
	ELSE
	BEGIN	
		EXEC Proc_CollectionValues 1
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN 
		INSERT INTO #RptCollectionDetail (SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt
		,InvRcpNo)
		SELECT SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId))
		--dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)
		AS BalanceAmount,dbo.Fn_ConvertCurrency(PayAmount,@Pi_CurrencyId),0 AS TotalBillAmount,
		(	--Commented and Added by Thiru on 20/11/2009
--			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
--			THEN 'Db' 
--			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
--			THEN 'Cr' 
--			ELSE '' END
			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
			THEN 'Db' 
			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
			THEN 'Cr' 
			ELSE '' END
--Till Here
		) AS AmtStatus,
		R.InvRcpDate,dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollCashAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollChqAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollDDAmt,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),R.InvRcpNo
		FROM RptCollectionValue R
		WHERE (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
		SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 
		AND 
		(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
		RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
		AND
		(DlvRMId=(CASE @DlvRId WHEN 0 THEN DlvRMId ELSE 0 END) OR
		DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		AND 
		(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
		RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		(SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
		SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
		AND InvRcpDate BETWEEN @FromDate AND @ToDate 
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+  ' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '+
				'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@DlvRId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',35,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '+
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR ' +
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND INvRcpDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
	
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCollectionDetail'
				
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
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCollectionDetail
	-- Till Here
	
	CREATE TABLE #Tempbalance
	(
		Billamt numeric(18,4),
		CurPayAmt numeric(18,4),
		Balance numeric(18,4),
		RtrId int,
		Salesinvoice nvarchar(50),
		Receiptinvoice nvarchar(50)
	)
	DECLARE @BillAmount NUMERIC (38,6)
	DECLARE @CurPayAmount NUMERIC (38,6)
	DECLARE @BalanceAmount NUMERIC (38,6)
	DECLARE @InvRcpNo nvarchar(50)
	DECLARE @SalinvNo nvarchar(50)
	DECLARE @TempInvoiceRcpNo nvarchar(50)
	DECLARE @CurPayAmountbal NUMERIC (38,6)
	DECLARE @BalRtrId int
	DECLARE Cur_BalanceAmt CURSOR FOR
	SELECT BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	OPEN Cur_BalanceAmt
	FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT into #Tempbalance(BillAmt,CurPayAmt,RtrId,Salesinvoice,Receiptinvoice) VALUES (@BillAmount,@CurPayAmount,@BalRtrId,@SalinvNo,@InvRcpNo)
        SELECT @CurPayAmountbal=sum(CurPayAmt) FROM #Tempbalance WHERE RtrId=@BalRtrId AND Salesinvoice=@SalinvNo --AND Receiptinvoice=@InvRcpNo
        UPDATE #RptCollectionDetail SET BalanceAmount=BillAmount-@CurPayAmountbal WHERE CurPayAmount=@CurPayAmount
		AND SalInvNo=@SalinvNo AND InvRcpNo=@InvRcpNo AND RtrId=@BalRtrId
		FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	END
	CLOSE Cur_BalanceAmt
	DEALLOCATE Cur_BalanceAmt
	
	UPDATE #RptCollectionDetail SET  [CashBill]=(CASE WHEN CollCashAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [ChequeBill]=(CASE WHEN CollChqAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [DDbill]=(CASE WHEN BalanceAmount<>0 THEN 1 ELSE 0 END) WHERE  AmtStatus='DB'
	UPDATE #RptCollectionDetail SET  [RTGSBill]=(CASE WHEN  CollRTGSAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [TotalBills]=(SELECT Count(Salid) FROM #RptCollectionDetail)
	
	SELECT SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,
	CashBill,Chequebill,DDBill,RTGSBill,InvRcpNo,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCollectionDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptCollectionDetail_Excel
		SELECT  SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
			BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
			ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,
			ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus INTO RptCollectionDetail_Excel FROM #RptCollectionDetail
	END

RETURN
END
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='RptUnloadingSheet' AND XTYPE='U')
DROP TABLE RptUnloadingSheet
GO
CREATE TABLE RptUnloadingSheet(
	[PrdId] [int] NULL,
	[PrdDcode] [varchar](100) NULL,
	[PrdName] [varchar](100) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](100) NULL,
	[PrdUnitMRP] [numeric](38, 2) NULL,
	[PrdUnitSelRate] [numeric](38, 2) NULL,
	[LoadBilledQty] [bigint] NULL,
	[LoadFreeQty] [bigint] NULL,
	[LoadReplacementQty] [bigint] NULL,
	[UnLoadSalQty] [bigint] NULL,
	[UnLoadUnSalQty] [bigint] NULL,
	[UnLoadFreeQty] [bigint] NULL,
	[UserId] [int] NULL
) ON [PRIMARY]
GO
--Parle_issues_Jisha
UPDATE RptDetails SET FldCaption = 'Stock Value as per*...' WHERE RptId = 6 AND SlNo = 13
GO
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RptID = 153 AND SlNo = 5
GO
UPDATE RptExcelHeaders SET DisplayFlag = 0 WHERE RptID = 25 AND SlNo = 2
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RptID = 25 AND SlNo = 5
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RptID = 25 AND SlNo = 6
GO
UPDATE RptExcelHeaders SET DisplayFlag = 0 WHERE RptID = 27 AND SlNo = 2
UPDATE RptExcelHeaders SET DisplayFlag = 0 WHERE RptID = 27 AND SlNo = 3
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RptID = 27 AND SlNo = 1
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RptID = 27 AND SlNo = 5
GO
UPDATE RptExcelHeaders SET DisplayFlag = 0 WHERE RptID = 32 AND SlNo = 3
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RptID = 32 AND SlNo = 1
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RptID = 32 AND SlNo = 5
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RptID = 32 AND SlNo = 6
GO
UPDATE RptGroup SET VISIBILITY = 0 WHERE RptId = 100
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name = 'RptStockManagementAll' AND Xtype = 'U')
DROP TABLE RptStockManagementAll
GO
CREATE TABLE RptStockManagementAll
(
	RefNo NVARCHAR(20) NULL,
	StkMngDate DATETIME NULL,
	LcnId INT NULL,
	LocationName NVARCHAR(50) NULL,
	CmpId INT NULL,
	PrdCode NVARCHAR(50) NULL,
	PrdName NVARCHAR(200) NULL,
	PrdBatCode NVARCHAR(50) NULL,
	StkMngtId INT NULL,
	StkMngtDesc NVARCHAR(50) NULL,
	Qty NUMERIC(38, 0) NULL,
	Rate NUMERIC(38, 2) NULL,
	Amount NUMERIC(38, 2) NULL,
	UsrId INT NULL
) 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name = 'RptSalvageAll' AND Xtype = 'U')
DROP TABLE RptSalvageAll
GO
CREATE TABLE RptSalvageAll
(
	[RefNo] [nvarchar](20) NULL,
	[SalvageDate] [datetime] NULL,
	[LcnId] [int] NULL,
	[LocationName] [nvarchar](50) NULL,
	[StockTypeId] [int] NULL,
	[UserStockType] [nvarchar](50) NULL,
	[DocRefNo] [nvarchar](20) NULL,
	[CmpId] [int] NULL,
	[PrdCode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[Qty] [numeric](38, 0) NULL,
	[Rate] [numeric](38, 6) NULL,
	[Amount] [numeric](38, 6) NULL,
	[AmountForClaim] [numeric](38, 6) NULL,
	[ReasonId] [int] NULL,
	[Description] [nvarchar](50) NULL,
	[UsrId] [int] NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name = 'Proc_RptStockandSalesVolume' AND Xtype = 'P')
DROP PROCEDURE Proc_RptStockandSalesVolume
GO
--EXEC Proc_RptStockandSalesVolume 6,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptStockandSalesVolume
(  
	 @Pi_RptId  INT,  
	 @Pi_UsrId  INT,  
	 @Pi_SnapId  INT,  
	 @Pi_DbName  NVARCHAR(50),  
	 @Pi_SnapRequired INT,  
	 @Pi_GetFromSnap  INT,  
	 @Pi_CurrencyId  INT  
)  
AS
/************************************************************
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 08/11/2013	Jisha MathewBug No : 30530
*************************************************************/
BEGIN  
SET NOCOUNT ON  
	DECLARE @NewSnapId  AS INT  
	DECLARE @DBNAME  AS  nvarchar(50)  
	DECLARE @TblName  AS nvarchar(500)  
	DECLARE @TblStruct  AS nVarchar(4000)  
	DECLARE @TblFields  AS nVarchar(4000)  
	DECLARE @sSql  AS  nVarChar(4000)  
	DECLARE @ErrNo   AS INT  
	DECLARE @PurDBName AS nVarChar(50)  
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate  AS DATETIME  
	DECLARE @LcnId   AS INT  
	DECLARE @PrdCatValId AS INT  
	DECLARE @PrdId  AS INT  
	DECLARE @CmpId   AS INT  
	DECLARE @DisplayBatch  AS INT  
	DECLARE @PrdStatus  AS INT  
	DECLARE @BatStatus  AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @IncOffStk  AS INT  
	DECLARE @StockValue 	AS	INT
	DECLARE @SupzeroStock AS INT
	DECLARE @RptDispType	AS INT
	--select *  from TempRptStockNSales  
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
	SET @DisplayBatch =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))  
	SET @PrdStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))  
	SET @BatStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))  
	SET @PrdBatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))  
	SET @IncOffStk =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,202,@Pi_UsrId))
	SET @StockValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))  
	SET @SupZeroStock =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))  
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
	IF @IncOffStk=1  
	BEGIN  
		Exec Proc_GetStockNSalesDetailsWithOffer @FromDate,@ToDate,@Pi_UsrId  
	END  
	ELSE  
	BEGIN  
		Exec Proc_GetStockNSalesDetails @FromDate,@ToDate,@Pi_UsrId  
	END  
	IF @DisplayBatch = 1 
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	--Create TABLE #RptPendingBillsDetails  
	CREATE TABLE #RptStockandSalesVolume  
	(  
		PrdId			INT,  
		PrdDCode			NVARCHAR(50),  
		PrdName			NVARCHAR(200),  
		PrdBatId			INT,  
		PrdBatCode		NVARCHAR(50),  
		CmpId			INT,  
		CmpName			NVARCHAR(50),  
		LcnId			INT,  
		LcnName			NVARCHAR(50),   
		OpeningStock		NUMERIC(38,0),    
		Purchase			NUMERIC (38,0),  
		Sales			NUMERIC (38,0),  
		AdjustmentIn		NUMERIC (38,0),  
		AdjustmentOut    NUMERIC (38,0),  
		PurchaseReturn   NUMERIC (38,0),  
		SalesReturn		NUMERIC (38,0),    
		ClosingStock		NUMERIC (38,0),  
		DispBatch        INT  ,
		ClosingStkValue	NUMERIC (38,6),
		PrdWeight	NUMERIC (38,6)
	)  
	SELECT * INTO #RptStockandSalesVolume1 FROM #RptStockandSalesVolume  
	SET @TblName = 'RptStockandSalesVolume'  
	SET @TblStruct = 'PrdId    INT,  
					  PrdDCode			NVARCHAR(50),  
					  PrdName			NVARCHAR(200),  
					  PrdBatId			INT,  
					  PrdBatCode		NVARCHAR(50),  
					  CmpId				INT,  
					  CmpName			NVARCHAR(50),  
					  LcnId				INT,  
					  LcnName			NVARCHAR(50),   
					  OpeningStock		NUMERIC(38,0),  
					  Purchase			NUMERIC (38,0),  
					  Sales				NUMERIC (38,0),     
					  AdjustmentIn		NUMERIC (38,0),  
					  AdjustmentOut		NUMERIC (38,0),  
					  PurchaseReturn	NUMERIC (38,0),  
					  SalesReturn		NUMERIC (38,0),     
					  ClosingStock		NUMERIC (38,0),  
					  DispBatch         INT,
					  ClosingStkValue	NUMERIC (38,6),
					  PrdWeight	NUMERIC (38,6)'  
	SET @TblFields = 'PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
   					  LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,  
					  PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue,PrdWeight'  
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
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
----SELECT 
----	PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,TempRptStockNSales.CmpId,CmpName,LcnId,LcnName,  
----	Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,@DisplayBatch,
----	dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId),0
----FROM 
----	TempRptStockNSales INNER JOIN  Company  C ON C.CmpId = TempRptStockNSales.CmpId  
----WHERE 
----	( TempRptStockNSales.CmpId = (CASE @CmpId WHEN 0 THEN TempRptStockNSales.CmpId ELSE 0 END) OR  
----			TempRptStockNSales.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
----	AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
----			LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
----	AND (PrdStatus = (CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END) OR  
----			PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))  
----	AND (BatStatus = (CASE @BatStatus WHEN 0 THEN BatStatus ELSE 2 END) OR  
----			BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))  
----	AND (PrdId = (CASE @PrdCatValId WHEN 0 THEN PrdId Else 0 END) OR  
----			PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
----	AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
----			PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
----	AND UserId=@Pi_UsrId  
				
		INSERT INTO #RptStockandSalesVolume1 (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,
												AdjustmentOut,PurchaseReturn,SalesReturn,
												ClosingStock,DispBatch,ClosingStkValue,PrdWeight)  
		SELECT 
			PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,TempRptStockNSales.CmpId,CmpName,LcnId,LcnName,  
			Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,@DisplayBatch,
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId),0
		FROM 
			TempRptStockNSales INNER JOIN  Company  C ON C.CmpId = TempRptStockNSales.CmpId  
		WHERE 
			( TempRptStockNSales.CmpId = (CASE @CmpId WHEN 0 THEN TempRptStockNSales.CmpId ELSE 0 END) OR  
					TempRptStockNSales.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
			AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
					LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
			AND (PrdStatus = (CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END) OR  
					PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))  
			AND (BatStatus = (CASE @BatStatus WHEN 0 THEN BatStatus ELSE 2 END) OR  
					BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdCatValId WHEN 0 THEN PrdId Else 0 END) OR  
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
			AND UserId=@Pi_UsrId  
			
		IF @DisplayBatch = 1  
		BEGIN  
			INSERT INTO #RptStockandSalesVolume (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												 LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
												 PurchaseReturn,SalesReturn,ClosingStock,DispBatch,
												 ClosingStkValue,PrdWeight)  
			SELECT 
				PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,0,'',  			
				SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
				SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
				SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
				SUM(ClosingStock) AS ClosingStock,@DisplayBatch,SUM(ClosingStkValue),0
			FROM #RptStockandSalesVolume1   
			WHERE 
				(PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR  
						PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))      
			GROUP BY PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName  
		END  
		ELSE  
		BEGIN  
			INSERT INTO #RptStockandSalesVolume (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
												PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue,PrdWeight)  
			SELECT 
				PrdId,PrdDCode,PrdName,0,'',CmpId,CmpName,0,'',  
				SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
				SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
				SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
				SUM(ClosingStock) AS ClosingStock,@DisplayBatch,SUM(ClosingStkValue),0
			FROM #RptStockandSalesVolume1   
			WHERE  
				(PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR  
						PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))      
			GROUP BY PrdId,PrdDCode,PrdName,CmpId,CmpName  
		END		 
		--->Added By Nanda on 25/02/2011
		UPDATE Rpt SET Rpt.PrdWeight=P.PrdWgt*(CASE P.PrdUnitId WHEN 2 THEN Rpt.ClosingStock/1000000 ELSE Rpt.ClosingStock/1000 END)
		FROM Product P,#RptStockandSalesVolume Rpt WHERE P.PrdId=Rpt.PrdId AND P.PrdUnitId IN (2,3)
		--->Till Here
		IF LEN(@PurDBName) > 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume ' +  
			'(' + @TblFields + ')' +  
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +  
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( LcnId = (CASE ' + CAST(@LcnId AS nVarChar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR ' +  
			' LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE 0 END) OR ' +  
			' PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',24,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '  
			+ '( BatStatus = (CASE ' + CAST(@BatStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE 0 END) OR ' +  
			' BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',25,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
			+ '( PrdId = (CASE ' + CAST(@PrdCatValId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +  
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
			+ ' (R.PrdId = (CASE ' + CAST(@PrdId AS nVarChar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +  
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS  nVarchar(10)) + ',5,' +  CAST(@Pi_UsrId AS nVarchar(10)) + ' )))'  
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptStockandSalesVolume'  
			EXEC (@SSQL)  
			PRINT 'Saved Data Into SnapShot Table'  
		END  
	END  
	ELSE    --To Retrieve Data From Snap Data  
	BEGIN  
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
		IF @ErrNo = 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume ' +  
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
			RETURN  
		END  
	END  
	IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND  GridFlag=1 AND UsrId=@Pi_UsrId)
	BEGIN
		SELECT a.PrdId,a.PrdDCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.CmpId,a.CmpName,a.LcnId,a.LcnName,
		a.OpeningStock,a.Purchase,Sales,CASE WHEN ConverisonFactor2>0 THEN Case When 
		CAST(Sales AS INT)>nullif(ConverisonFactor2,0) Then CAST(Sales AS INT)/nullif(ConverisonFactor2,0) Else 0 End 
		ELSE 0 END As Uom1,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When 
		(CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then 
		isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case 
		When (CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*
		nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*
		nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
		(CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + 
		isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/Isnull(ConverisonFactor2,0)*
		Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*
		ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
		CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
		CASE 
			WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
				Case 
				When 
					CAST(Sales AS INT)-(((CAST(Sales AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(Sales AS INT)-(((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
				ELSE
					CASE 
						WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
					Case
						When CAST(Sum(Sales) AS INT)>Isnull(ConverisonFactor2,0) Then
							CAST(Sum(Sales) AS INT)%nullif(ConverisonFactor2,0)
						Else CAST(Sum(Sales) AS INT) End
						WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
					Case
					When CAST(Sum(Sales) AS INT)>Isnull(ConverisonFactor3,0) Then
					CAST(Sum(Sales) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(Sales) AS INT) 
				End			
			ELSE CAST(Sum(Sales) AS INT) END
		END AS Uom4,a.AdjustmentIn,a.AdjustmentOut,a.PurchaseReturn,a.SalesReturn,a.ClosingStock,a.DispBatch INTO #RptColDetails
		FROM #RptStockandSalesVolume A INNER JOIN View_ProdUOMDetails B ON a.prdid=b.prdid WHERE OpeningStock > 0 OR ClosingStock > 0  
		GROUP BY a.PrdId,a.PrdDCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.CmpId,a.CmpName,a.LcnId,a.LcnName,a.OpeningStock,a.Purchase,Sales,
		a.AdjustmentIn,a.AdjustmentOut,a.PurchaseReturn,a.SalesReturn,a.ClosingStock,a.DispBatch,
		ConversionFactor1,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4
		ORDER BY A.CmpId,A.PrdId,A.PrdBatId,A.LcnId 
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,Rptid,Usrid)
		SELECT 
			PrdDCode,PrdName,PrdBatCode,CmpName,LcnName,OpeningStock,Purchase,Sales,Uom1,Uom2,Uom3,Uom4,
			AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,ClosingStock,DispBatch,
			@Pi_RptId,@Pi_UsrId 
		FROM #RptColDetails
	END
	IF @SupZeroStock=1
	BEGIN 
		SELECT  * FROM #RptStockandSalesVolume
		WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			TRUNCATE TABLE RptStockandSalesVolume_Excel
			INSERT INTO RptStockandSalesVolume_Excel(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName,OpeningStock,OpeningStockInVolume,
			Purchase,PurchaseStockInVolume,Sales,SalesStockInVolume,AdjustmentIn,AdjustmentInStockVolume,AdjustmentOut,AdjustmentOutStockVolume,PurchaseReturn,
			PurchaseReturnStockInVolume,SalesReturn,SalesReturnStockInVolume,ClosingStock,ClosingStockInVolume,DispBatch,ClosingStkValue,PrdWeight)
			SELECT	PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,
					LcnId,LcnName,
					OpeningStock,0.00 as OpeningStockInVolume,
					Purchase,0.00 as PurchaseStockInVolume,
					Sales, 0.00 as SalesStockInVolume,
					AdjustmentIn,0.00 as AdjustmentInStockVolume,
					AdjustmentOut,0.00 as AdjustmentOutStockVolume,
					PurchaseReturn,0.00 As PurchaseReturnStockInVolume,
					SalesReturn,0.00 SalesReturnStockInVolume,
					ClosingStock,0.00 ClosingStockInVolume,
					DispBatch,ClosingStkValue,PrdWeight
			FROM #RptStockandSalesVolume
			WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
			Update RptStockandSalesVolume_Excel SET
					OpeningStockInVolume = ((OpeningStock * PrdWgt)/1000),
					PurchaseStockInVolume = ((Purchase * PrdWgt)/1000),
					SalesStockInVolume = ((Sales * PrdWgt)/1000),
					AdjustmentInStockVolume = ((AdjustmentIn * PrdWgt)/1000),
					AdjustmentOutStockVolume = ((AdjustmentOut * PrdWgt)/1000),
					SalesReturnStockInVolume = ((SalesReturn * PrdWgt)/1000),
					ClosingStockInVolume = ((ClosingStock * PrdWgt)/1000)		
			From RptStockandSalesVolume_Excel A,Product B
			WHERE A.PrdId = B.PrdId
		END
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume   
		WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
	END
	ELSE
	BEGIN
		SELECT * FROM #RptStockandSalesVolume
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			TRUNCATE TABLE RptStockandSalesVolume_Excel
			INSERT INTO RptStockandSalesVolume_Excel(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName,OpeningStock,OpeningStockInVolume,
			Purchase,PurchaseStockInVolume,Sales,SalesStockInVolume,AdjustmentIn,AdjustmentInStockVolume,AdjustmentOut,AdjustmentOutStockVolume,PurchaseReturn,
			PurchaseReturnStockInVolume,SalesReturn,SalesReturnStockInVolume,ClosingStock,ClosingStockInVolume,DispBatch,ClosingStkValue,PrdWeight)
			SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,
					LcnId,LcnName,
					OpeningStock,0.00 as OpeningStockInVolume,
					Purchase,0.00 as PurchaseStockInVolume,
					Sales, 0.00 as SalesStockInVolume,
					AdjustmentIn,0.00 as AdjustmentInStockVolume,
					AdjustmentOut,0.00 as AdjustmentOutStockVolume,
					PurchaseReturn,0.00 As PurchaseReturnStockInVolume,
					SalesReturn,0.00 SalesReturnStockInVolume,
					ClosingStock,0.00 ClosingStockInVolume,
					DispBatch,ClosingStkValue,PrdWeight 
			FROM #RptStockandSalesVolume		
			Update RptStockandSalesVolume_Excel SET
					OpeningStockInVolume = ((OpeningStock * PrdWgt)/1000),
					PurchaseStockInVolume = ((Purchase * PrdWgt)/1000),
					SalesStockInVolume = ((Sales * PrdWgt)/1000),
					AdjustmentInStockVolume = ((AdjustmentIn * PrdWgt)/1000),
					AdjustmentOutStockVolume = ((AdjustmentOut * PrdWgt)/1000),
					SalesReturnStockInVolume = ((SalesReturn * PrdWgt)/1000),
					ClosingStockInVolume = ((ClosingStock * PrdWgt)/1000)		
			From RptStockandSalesVolume_Excel A,Product B
			WHERE A.PrdId = B.PrdId
		END
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume   
	END
	RETURN  
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name = 'Proc_RptClosingStockReport' AND Xtype = 'P')
DROP PROCEDURE Proc_RptClosingStockReport
GO

--EXEC Proc_RptClosingStockReport 153,2,0,'',0,0,1
CREATE PROCEDURE Proc_RptClosingStockReport
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
/************************************************************
* VIEW	: Proc_RptClosingStockReport
* PURPOSE	: To get the Closing Stock Details
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 17/09/2008
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 08/11/2013	Jisha MathewBug No : 30534
*************************************************************/
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
	
	--Filter Variables
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @LcnId 		AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @DispValue	AS	INT
	DECLARE @PrdStatus	AS	INT
	DECLARE @BatchStatus	AS	INT
	DECLARE @SupZeroStock   AS INT
	DECLARE @PrdUnit	AS INT
	----Till Here
	--Assgin Value for the Filter Variable
--	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @DispValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,209,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,210,@Pi_UsrId))
	SET @BatchStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,211,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	
	SELECT @PrdUnit=PrdUnitId FROM ProductUnit WHERE UPPER(PrdUnitName) IN('KILO GRAM','KILOGRAM','KILO GRAMS','KILOGRAMS')
	---Till Here
	--PRINT @DispValue
	CREATE TABLE #RptClosingStock
	(
				PrdId		INT,
				PrdName		NVARCHAR(100),
				MRP		NUMERIC(38,6),
				Cases		NUMERIC(38,0),
				BoxStrip	NUMERIC(38,0),
				Piece		NUMERIC(38,0),
				StockValue	NUMERIC(38,6),
				KiloGrams   NUMERIC(38,6)				
	)
	SET @TblName = 'RptClosingStock'
	SET @TblStruct = ' PrdId		INT,
		PrdName		NVARCHAR(100),
		MRP		    NUMERIC(38,6),
		Cases		NUMERIC(38,0),
		BoxStrip	NUMERIC(38,0),
		Piece		NUMERIC(38,0),
		StockValue	NUMERIC(38,6),
		KiloGrams   NUMERIC(38,6)'
	SET @TblFields = 'PrdId,PrdName,MRP,Cases,BoxStrip,Piece,StockValue,KiloGrams'
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
	EXEC Proc_ClosingStock @Pi_RptID,@Pi_UsrId,@ToDate
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptClosingStock (PrdId,PrdName,MRP,Cases,BoxStrip,Piece,StockValue,KiloGrams)
		SELECT DISTINCT T.PrdId,T.PrdName,MRP,ISNULL(SUM(Cases),0),ISNULL(SUM(BoxStrip),0),ISNULL(SUM(Pieces),0),
		--SUM((CASE @DispValue WHEN 1 THEN CloSelRte ELSE CloPurRte END)) As StockValue
		SUM((CASE @DispValue WHEN 1 THEN (BaseQty*SellingRate) ELSE (BaseQty*ListPrice) END)) As StockValue,0
		FROM TempClosingStock T
		WHERE 	(T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))				
		AND
		(T.LcnId = (CASE @LcnId WHEN 0 THEN T.LcnId ELSE 0 END) OR
			T.LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
		AND
		(T.PrdStatus = (CASE @PrdStatus WHEN 0 THEN T.PrdStatus ELSE -1 END) OR
			T.PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,210,@Pi_UsrId)))
		AND
		(T.BatStatus = (CASE @BatchStatus WHEN 0 THEN T.BatStatus ELSE -1 END) OR
			T.BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,211,@Pi_UsrId)))
		AND
		(T.PrdId = (CASE @PrdCatId WHEN 0 THEN T.PrdId Else 0 END) OR
			T.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND
		(T.PrdId = (CASE @PrdId WHEN 0 THEN T.PrdId Else 0 END) OR
			T.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND UsrId=@Pi_UsrId 
		GROUP BY T.PrdId,T.PrdName,MRP
		ORDER BY T.PrdId,T.PrdName,MRP
		UPDATE T SET KiloGrams=(PrdWgt*BaseQty) FROM #RptClosingStock T,Product P,ProductUnit PU,TempClosingStock TT
		WHERE P.PrdId=T.PrdId AND T.PrdId=TT.PrdId AND PU.PrdUnitId=TT.PrdUnitId AND TT.PrdUnitId=@PrdUnit
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptClosingStock ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR '
				+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId ELSE 0 END) OR '
				+ 'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND(PrdId=(CASE @PrdId WHEN 0 THEN PrdId ELSE 0 END) OR'
				+ 'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE -1 END) OR '
				+ 'PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',210,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (BatStatus = (CASE ' + CAST(@BatchStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE -1 END) OR '
				+ 'BatStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',211,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				--+ 'AND TransDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptClosingStock'
				
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
			SET @SSQL = 'INSERT INTO #RptClosingStock ' +
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
----SELECT *FROM #RptClosingStock		
	IF @SupZeroStock=1 
	BEGIN
		SELECT *FROM #RptClosingStock WHERE (ISNULL([Cases],0)+ISNULL([Piece],0)+ISNULL([BoxStrip],0))<>0
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock WHERE ([Cases]+[Piece]+[BoxStrip])<>0
		-- Till Here
	END
	ELSE
	BEGIN
		SELECT *FROM #RptClosingStock
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock 
		-- Till Here
	END
--SELECT *FROM #RptClosingStock	
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptClosingStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptClosingStock_Excel
		IF @SupZeroStock=1 
		BEGIN
			SELECT PrdId,PrdName,MRP,Cases,Piece,KiloGrams,StockValue INTO RptClosingStock_Excel FROM #RptClosingStock WHERE (ISNULL([Cases],0)+ISNULL([Piece],0)+ISNULL([BoxStrip],0))<>0
		END
		ELSE
		BEGIN
			SELECT PrdId,PrdName,MRP,Cases,Piece,KiloGrams,StockValue INTO RptClosingStock_Excel FROM #RptClosingStock
		END
	END 
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name = 'Proc_RptRetailerMasterDetReport' AND Xtype = 'P')
DROP PROCEDURE Proc_RptRetailerMasterDetReport
GO
---- EXEC Proc_RptRetailerMasterDetReport 206,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptRetailerMasterDetReport
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
* PROCEDURE  : Proc_RptProductMasterDetReport
* PURPOSE    : To Generate Retailer Master Details Report 
* CREATED BY : Panneerselvam.k
* CREATED ON : 07/01/2010
* MODIFICATION 
*****************************************************************************************************************   
* DATE       AUTHOR      DESCRIPTION   
*****************************************************************************************************************/ 
BEGIN
SET NOCOUNT ON
	/* Get the Filter Values  */		
		DECLARE @CmpId	 				AS	INT
		DECLARE @SMId      				AS	INT
		DECLARE @RMId					AS	INT
		DECLARE @RetCatLevelId      	AS	INT
		DECLARE @RetCatLevelValId    	AS	INT
		DECLARE @RetLevelClassId		AS	INT
		DECLARE @RetailerId      		AS	INT
		DECLARE @RetStatusId    		AS	INT
		DECLARE @RetOrderBy    			AS	INT
		
		SET @CmpId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @SMId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
		SET @RMId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
		SET @RetCatLevelId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
		SET @RetCatLevelValId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
		SET @RetLevelClassId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
		SET @RetailerId			= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
		SET @RetStatusId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
		SET @RetOrderBy			= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,90,@Pi_UsrId))
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
		SET @TblName = 'RptRetailerMasterDetReport'
		
		SET @TblStruct ='	RtrId INT,RtrCode Varchar(100),
							RtrName Varchar(100),RtrAdd1 Varchar(100),
							RtrAdd2 Varchar(100) ,RtrAdd3 Varchar(100),
							RtrPinNo Varchar(100),RtrPhoneNo Varchar(100),
							RtrEmailId Varchar(100) ,RtrKeyAcc Varchar(100),
							RtrTINNo Varchar(100),RtrCovMode Varchar(100),							
							RtrStatus Varchar(100),RtrCrBills INT,RtrCrLimit Numeric(18,3),
							RtrCrDays INT,GeoName Varchar(100),SalesRoute Varchar(100),
							DelvRoute Varchar(100),MerRoute Varchar(100),
							CategoryLevel Varchar(100),Category  Varchar(100),Class  Varchar(100),
							UDCColumn Varchar(100),UDCValue  Varchar(100)	'		
											
		SET @TblFields =	'RtrId,RtrCode,RtrName ,RtrAdd1,RtrAdd2,RtrAdd3,
							 RtrPinNo,RtrPhoneNo,RtrEmailId,RtrKeyAcc,
							 RtrTINNo ,RtrCovMode,RtrStatus,RtrCrBills ,RtrCrLimit,
							 RtrCrDays ,GeoName,SalesRoute,DelvRoute ,MerRoute ,
							 CategoryLevel ,Category ,Class '
		CREATE TABLE #TmpRptRetailerMasterDetReport(RtrId INT,RtrCode Varchar(100),
							RtrName Varchar(100),RtrAdd1 Varchar(100),
							RtrAdd2 Varchar(100) ,RtrAdd3 Varchar(100),
							RtrPinNo Varchar(100),RtrPhoneNo Varchar(100),
							RtrEmailId Varchar(100) ,RtrKeyAcc Varchar(100),
							RtrTINNo Varchar(100),RtrCovMode Varchar(100),							
							RtrStatus Varchar(100),RtrCrBills INT,RtrCrLimit Numeric(18,3),
							RtrCrDays INT,GeoName Varchar(100),SalesRoute Varchar(100),
							DelvRoute Varchar(100),MerRoute Varchar(100),
							CategoryLevel Varchar(100),Category  Varchar(100),Class  Varchar(100),
							UDCColumn Varchar(100),UDCValue  Varchar(100))
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
			
			INSERT INTO #TmpRptRetailerMasterDetReport
			SELECT  Distinct
				R.RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,
				RtrPinNo,RtrPhoneNo,RtrEmailId,
				CASE RtrKeyAcc  WHEN 1 THEN 'Yes' ELSE 'No' END AS RtrKeyAcc,
				RtrTINNo,
				CASE RtrCovMode WHEN 1 THEN 'Order Booking' 
								WHEN 2 THEN 'Van Sales'
								WHEN 3 THEN 'Counter Sales'  END AS RtrCovMode,
				CASE RtrStatus  WHEN 1 THEN 'Active' ELSE 'InActive' END AS RtrStatus,
				RtrCrBills,RtrCrLimit,RtrCrDays,
				G.GeoName,RMName AS SalesRoute,	'' AS DelvRoute,'' AS MerRoute,
				RCL.CtgLevelName CategoryLevel, RC.CtgName AS Category,	RVC.ValueClassName AS Class,
				B.ColumnName  UDCColumn,C.ColumnValue UDCValue
			FROM  Retailer R WITH (NOLOCK)
				  LEFT OUTER JOIN UdcDetails C ON R.RtrId = C.MasterRecordId AND MAsterId = 2
				  LEFT OUTER JOIN UdcMaster B  ON C.MasterId = B.MasterId AND C.UdcMasterId = B.UdcMasterId,
						----Inner JOIN UdcHD A ON C.MasterId = A.MasterId AND A.MasterName = 'Retailer Master' 
						----LEFT OUTER JOIN UdcMaster B  ON A.MasterId = B.MasterId AND C.UdcMasterId = B.UdcMasterId ,
				  RetailerMarket RM,
				  RetailerCategoryLevel RCL WITH (NOLOCK),
				  RetailerCategory RC WITH (NOLOCK),
				  RetailerValueClass RVC WITH (NOLOCK),
				  RetailerValueClassMap RVCM WITH (NOLOCK) ,
				  RouteMaster Rot,Geography G,
				  SalesMan S,SalesmanMarket SM
			WHERE	RVCM.RtrValueClassId = RVC.RtrClassId
					AND RVCM.RtrId = R.RtrId 		AND RCL.CtgLevelId=RC.CtgLevelId
					AND RVC.CtgMainId=RC.CtgMainId  AND  R.RtrId = RM.RtrId	
					AND ROT.RMId = RM.RMId			AND Rot.RMSRouteType = 1
					AND R.GeoMainId = G.GeoMainId	AND S.SMId = SM.SMId AND RM.RMId = SM.RMId
					--- Company  
					AND (S.CmpId =  (CASE @CmpId WHEN 0 THEN S.CmpId ELSE 0 END) OR 
								S.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				--- SalesMan
					And (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
							    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route 
					AND (ROT.RMId = (CASE @RMId WHEN 0 THEN ROT.RMId Else 0 END) OR
		    						ROT.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
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
				---- Product Status
				AND   (R.RtrStatus  =(CASE @RetStatusId WHEN 0 THEN R.RtrStatus  ELSE 0 END ) OR
							R.RtrStatus  IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
					/*   Sales Route Update */
			SELECT DISTINCT R.RtrId,RtrCode,ROT.RMName  INTO #TmpSalRoute
			FROM RouteMaster ROT,Retailer R 
			WHERE RMSRouteType = 2
				  AND R.RtrId IN ( SELECT DISTINCT  RtrId FROM #TmpRptRetailerMasterDetReport)
				  AND R.RMId = ROt.RMId
			UPDATE #TmpRptRetailerMasterDetReport  SET DelvRoute = RMName
			FROM #TmpRptRetailerMasterDetReport a,#TmpSalRoute B
			WHERE A.RtrId = B.RtrId
					/*   Merchandising Route Update */
			SELECT DISTINCT R.RtrId,RtrCode,ROT.RMName INTO #TmpMerRoute
			FROM RouteMaster ROT,Retailer R,RetailerMarket RM 
			WHERE RMSRouteType = 3
				  AND R.RtrId IN( SELECT DISTINCT  RtrId FROM #TmpRptRetailerMasterDetReport)
				  AND R.RtrId = RM.RtrId AND RM.RMId = ROt.RMId	
			UPDATE #TmpRptRetailerMasterDetReport  SET MerRoute = RMName
					FROM #TmpRptRetailerMasterDetReport a,#TmpMerRoute B
					WHERE A.RtrId = B.RtrId
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #TmpRptRetailerMasterDetReport
		IF @RetOrderBy = 1
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY RtrCode
		END
		IF @RetOrderBy = 2
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY RtrName
		END
		IF @RetOrderBy = 3
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY SalesRoute
		END
		IF @RetOrderBy = 4
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY Category
		END
		IF @RetOrderBy = 5
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY Class
		END
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name = 'Proc_RptStockManagement' AND Xtype = 'P')
DROP PROCEDURE Proc_RptStockManagement
GO
-- EXEC Proc_RptStockManagement 20,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptStockManagement
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
DECLARE @sSql		AS 	nVarChar(4000)
DECLARE @ErrNo	 	AS	INT
DECLARE @PurDBName	AS	nVarChar(50)

--Filter Variable
DECLARE @FromDate	   AS	DATETIME
DECLARE @ToDate	 	   AS	DATETIME
DECLARE @CmpId         AS  INT
DECLARE @LcnId	   AS	INT
DECLARE @TransId	   AS	INT
--Till Here

EXEC Proc_RptStockManagementAll @Pi_RptId ,@Pi_UsrId

--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
SET @TransId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,38,@Pi_UsrId))

--Till Here

SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
if exists (select * from dbo.sysobjects where id = object_id(N'[UOMIdWise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [UOMIdWise]
	CREATE TABLE [UOMIdWise] 
	(
		SlNo	INT IDENTITY(1,1),
		UOMId	INT
	) 
	INSERT INTO UOMIdWise(UOMId)
	SELECT UOMId FROM UOMMaster ORDER BY UOMId	
--Till Here
CREATE TABLE #RptStockManagementAll
(
  [Reference Number] nvarchar(20),
  [Stock Management Date]datetime,
  [Location Id]int ,
  [Location Name]nvarchar(50) ,
  [Company Id]int ,
  [Product Code]nvarchar(50) ,
  [Product Name]nvarchar(200) ,
  [Product Batch Code]nvarchar(50) ,
  [Stock Mangement Id] int,
  [Stock Mangement Description] nvarchar(50),
  [Qty]numeric(38, 0) ,
  [Rate]numeric(38, 2) ,
  [Amount]numeric(38, 2)
)

SET @TblName = 'RptStockManagementAll'

SET @TblStruct = '  [Reference Number] nvarchar(20),
  [Stock Management Date]datetime,
  [Location Id]int ,
  [Location Name]nvarchar(50) ,
  [Company Id]int ,
  [Product Code]nvarchar(50) ,
  [Product Name]nvarchar(200) ,
  [Product Batch Code]nvarchar(50) ,
  [Stock Mangement Id] int,
  [Stock Mangement Description] nvarchar(50),
  [Qty]numeric(38, 0) ,
  [Rate]numeric(38, 2) ,
  [Amount]numeric(38, 2) '

SET @TblFields = '    [Reference Number] ,
  [Stock Management Date],
  [Location Id] ,
  [Location Name] ,
  [Company Id] ,
  [Product Code] ,
  [Product Name],
  [Product Batch Code],
  [Stock Mangement Id] ,
  [Stock Mangement Description] ,
  [Qty] ,
  [Rate],
  [Amount] '

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
	INSERT INTO #RptStockManagementAll([Reference Number],[Stock Management Date],[Location Id] , [Location Name] ,[Company Id] ,
		  [Product Code] ,[Product Name],[Product Batch Code],[Stock Mangement Id] ,
		  [Stock Mangement Description],[Qty],[Rate],[Amount])
	SELECT
		RefNo,StkMngDate,LcnId,LocationName,CmpId,PrdCode,PrdName,PrdBatCode,
		StkMngtId,StkMngtDesc,Qty,Rate,Amount
	FROM RptStockManagementAll
	WHERE UsrId = @Pi_UsrId AND
		(LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
		LcnId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) )
		AND (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )
		AND (StkMngtId = (CASE @TransId WHEN 0 THEN StkMngtId ELSE 0 END) OR
		StkMngtId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,38,@Pi_UsrId)))
		AND [StkMngDate] BETWEEN @FromDate AND @ToDate

	/*		
		For ProductCategory Value and Product Filter

		R.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN R.PrdId Else 0 END) OR
		R.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
		AND R.PrdId = (CASE @fPrdId WHEN 0 THEN R.PrdId Else 0 END) OR
		R.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	*/
		
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptStockManagementAll ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
         + '         WHERE
	     UsrId = '  + @Pi_UsrId + ' and
         (LcnId=(CASE ' + @LcnId + ' WHEN 0 THEN LcnId ELSE 0 END) OR
					LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',22,' + @Pi_UsrId + ')) )

         AND (CmpId = (CASE ' + @CmpId + ' WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ' ,4,' + @Pi_UsrId + ' )) )
					
         AND (StkMgmtTypeId = (CASE ' + @TransId + ' WHEN 0 THEN StkMgmtTypeId ELSE 0 END) OR
					StkMgmtTypeId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ' ,38,' + @Pi_UsrId + ')) )

         AND [StkMngDate] Between ' + @FromDate + ' and ' + @ToDate


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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptStockManagementAll'
	
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
		SET @SSQL = 'INSERT INTO #RptStockManagementAll ' +
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptStockManagementAll
-- Till Here
--COMMENTED ON 16.06.2009
--SELECT * FROM #RptStockManagementAll ORDER BY [Reference Number]

	--Added on 25.06.2009
	SELECT a.*,CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.Qty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(A.Qty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(A.Qty) AS INT) End			
		ELSE CAST(Sum(A.Qty) AS INT) END
	END as Uom4 
	INTO #RptColDetails

	FROM #RptStockManagementAll A,View_ProdUOMDetails B where a.[Product Code]=b.prddcode
	GROUP BY [Reference Number] ,  [Stock Management Date],  [Location Id] ,  [Location Name] ,  [Company Id] ,
	  [Product Code] ,  [Product Name],  [Product Batch Code],  [Stock Mangement Id] ,  [Stock Mangement Description] ,
	  [Qty] ,  [Rate],  [Amount],ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,
	ConversionFactor1

	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
	INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,Rptid,Usrid)
	SELECT [Reference Number],[Stock Management Date],[Location Name],[Product Code],
	[Product Name],[Product Batch Code],[Stock Mangement Description],Qty,Uom1,Uom2,Uom3,Uom4,Rate,Amount,@Pi_RptId,@Pi_UsrId
	FROM #RptColDetails
	--Till Here

	-- Added on 21-Jun-2009
	SELECT A.[Reference Number],A.[Stock Management Date],A.[Location Id],A.[Location Name],A.[Company Id],A.[Product Code],
	A.[Product Name],A.[Product Batch Code],A.[Stock Mangement Id],A.[Stock Mangement Description],A.Qty ,
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.Qty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(A.Qty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(A.Qty) AS INT) End			
		ELSE CAST(Sum(A.Qty) AS INT) END
	END as Uom4,
	A.Rate,A.Amount
	FROM #RptStockManagementAll A,View_ProdUOMDetails B where a.[Product Code]=b.prddcode
	GROUP BY A.[Reference Number],A.[Stock Management Date],A.[Location Id],A.[Location Name],A.[Company Id],A.[Product Code],
	A.[Product Name],A.[Product Batch Code],A.[Stock Mangement Id],A.[Stock Mangement Description],A.Qty ,A.Rate,A.Amount,
	ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptStockManagementAll_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptStockManagementAll_Excel
		SELECT [Reference Number],[Stock Management Date],[Location Id] , [Location Name] ,[Company Id] ,
		  [Product Code] ,[Product Name],[Product Batch Code],[Stock Mangement Id] ,
		  [Stock Mangement Description],[Qty],0 AS Uom1 ,0 AS Uom2 ,0 AS Uom3 ,0 AS Uom4 ,[Rate],[Amount] INTO [RptStockManagementAll_Excel] FROM #RptStockManagementAll
	END 
--Till Here
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name = 'Proc_RptSalvage' AND Xtype = 'P')
DROP PROCEDURE Proc_RptSalvage
GO
--EXEC Proc_RptSalvage 21,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptSalvage
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
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	
	--Filter Variable
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @CmpId		   AS   INT
	DECLARE @LcnId	 	   AS	INT
	DECLARE @StkId	 	   AS	INT
	DECLARE @ReasonId	 	   AS	INT
	DECLARE @ReferenceId	   AS	NVarchar(100)
	--Till Here
	EXEC Proc_RptSalvageAll @Pi_RptId ,@Pi_UsrId
	
	--Assgin Value for the Filter Variable
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StkId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,164,@Pi_UsrId))
	SET @ReasonId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,159,@Pi_UsrId))
	SET @ReferenceId = (SELECT  TOP 1 sCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,199,@Pi_UsrId))
	--Till Here
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	--Till Here
	CREATE TABLE #RptSalvageAll
	(
	       [Reference Number] nVArchar(20),
	       [Salvage Date] datetime,
	       [LocationId] int,
	       [Location Name] nvarchar(50),
	       [DocRefNo] nvarchar(20),
	       [Product Code] nvarchar(50),
	       [Product Name] nvarchar(200),
	       [Product Batch Code] nvarchar(50),
	       [Qty] numeric(38,0),
	       [Rate] numeric(38,6),
	       [Amount] numeric(38,6),
	       [Amount For Claim] numeric(38,6),
	       [StkTypeId] int,
	       [StkType]nvarchar(100),
	       [ReasonId]int,
	       [Reason]nvarchar(100)
	)
	SET @TblName = 'RptSalageAll'
	
	SET @TblStruct = '       [Reference Number] nVArchar(20),
	       [Salvage Date] datetime,
	       [LocationId] int,
	       [Location Name] nvarchar(50),
	       [DocRefNo] nvarchar(20),
	       [Product Code] nvarchar(50),
	       [Product Name] nvarchar(200),
	       [Product Batch Code] nvarchar(50),
	       [Qty] numeric(38,0),
	       [Rate] numeric(38,6),
	       [Amount] numeric(38,6),
	       [Amount For Claim] numeric(38,6),
	       [StkTypeId] int,
	       [StkType]nvarchar(100),
	       [ReasonId]int,
	       [Reason]nvarchar(100)'
	
	SET @TblFields = '[Reference Number] ,[Salvage Date] ,
	       [LocationId] , [Location Name] ,
	       [DocRefNo] , [Product Code] ,
	       [Product Name] , [Product Batch Code] ,
	       [Qty] ,  [Rate] ,
	       [Amount] ,  [Amount For Claim] ,
	       [StkTypeId],
	       [StkType],
	       [ReasonId],
	       [Reason]'
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
		INSERT INTO #RptSalvageAll([Reference Number] ,[Salvage Date] ,
		[LocationId] , [Location Name] ,
		[DocRefNo] , [Product Code] ,
		[Product Name] , [Product Batch Code] ,
		[Qty] ,  [Rate] ,
		[Amount] ,  [Amount For Claim],[StkTypeId], [StkType],
		[ReasonId], [Reason])
		
		SELECT RefNo, SalvageDate, LcnId, LocationName, DocRefNo,
		PrdCode,PrdName,PrdBatCode,Qty,Rate,Amount,AmountForClaim,StockTypeId,UserStockType,ReasonId,Description
		FROM RptSalvageAll
		WHERE UsrId = @Pi_UsrId
		AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
		LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) )
		AND (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )		
		AND (StockTypeId = (CASE @StkId WHEN 0 THEN StockTypeId ELSE 0 END) OR
		StockTypeId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,164,@Pi_UsrId)) )		
		AND (ReasonId = (CASE @ReasonId WHEN 0 THEN ReasonId ELSE -1 END) OR
		ReasonId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,159,@Pi_UsrId)) )		
		AND (RefNo = (CASE @ReferenceId WHEN '0' THEN RefNo ELSE '0' END) OR
		RefNo in (SELECT sCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,199,@Pi_UsrId)) )
		AND [SalvageDate] Between @FromDate and @ToDate
			
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
			SET @SSQL = 'INSERT INTO #RptSalvageAll ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ 'WHERE
			UsrId = ' + @Pi_UsrId + ' and
			(LcnId=(CASE ' + @LcnId + ' WHEN 0 THEN LcnId ELSE 0 END) OR
			LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ' ,22,' + @Pi_UsrId + ')) )
			
			AND (CmpId = (CASE ' + @CmpId + ' WHEN 0 THEN CmpId ELSE 0 END) OR
			CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ' ,4, ' + @Pi_UsrId + ')) )
			
			AND SalvageDate Between ' + @FromDate + ' and ' + @ToDate
	
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSalvageAll'
				
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
			SET @SSQL = 'INSERT INTO #RptSalvageAll ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSalvageAll
	-- Till Here
	--->Added By Nanda on 23/12/2010 for Excel Reports
	DELETE FROM RptSalavageAll_Excel 	
	INSERT INTO RptSalavageAll_Excel ([Reference Number],[Salvage Date],[LocationId],[Location Name],[DocRefNo],[Product Code],
	[Product Name],[Product Batch Code],[Qty],[Rate],[Amount],[Amount For Claim],[StkTypeId],[StkType],[ReasonId],[Reason])
	SELECT [Reference Number],[Salvage Date],[LocationId],[Location Name],[DocRefNo],[Product Code],[Product Name],
	[Product Batch Code],[Qty],[Rate],[Amount],[Amount For Claim],[StkTypeId],[StkType],[ReasonId],[Reason] FROM #RptSalvageAll
	--->Till Here
	
	--Added on 16.06.2009
	-- CAST(Qty AS INT)
	--SELECT A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	--A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],
	--ISNULL(Cast(CAST(Qty AS INT)/NULLIF(ConverisonFactor2,0) AS Int),0)AS Uom1, --Cases
	--ISNULL(Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)/NULLIF(ConverisonFactor3,0),0) AS Uom2, --Boxes
	----ISNULL(Cast(((Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)/NULLIF(ConverisonFactor3,0))%NULLIF(ConverisonFactor3,0))/NULLIF(ConverisonFactor4,0) AS Int),0) AS Uom3, --Strips
	----CASE ISNULL(Cast(((Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)/NULLIF(ConverisonFactor3,0))%NULLIF(ConverisonFactor3,0))/NULLIF(ConverisonFactor4,0) AS Int),0)
	--ISNULL(Cast((Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)%NULLIF(ConverisonFactor3,0))/NULLIF(ConverisonFactor4,0) AS Int),0) AS Uom3, --Strips
	--CASE ISNULL(Cast((Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)%NULLIF(ConverisonFactor3,0))/NULLIF(ConverisonFactor4,0) AS Int),0)
	--
	--WHEN 0 THEN CASE ISNULL(Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)/NULLIF(ConverisonFactor3,0),0)
	--WHEN 0 THEN CASE ISNULL(Cast(CAST(Qty AS INT)/NULLIF(ConverisonFactor2,0) AS Int),0)
	--WHEN 0 THEN ISNULL(Qty,0) ELSE ISNULL((CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0)) ,0) END
	--ELSE ISNULL((CAST(Qty AS INT)%NULLIF(ConverisonFactor4,0)),0) END
	--ELSE ISNULL((CAST(Qty AS INT)%NULLIF(ConverisonFactor4,0)),0) END AS Uom4,
	--A.Rate,A.Amount,A.[Amount For Claim],A.ReasonId,A.Reason
	--FROM #RptSalvageAll A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode ORDER BY A.[Reference Number]
	----	SELECT * FROM #RptSalvageAll
	--	SELECT [Reference Number],[Salvage Date],[LocationId],[Location Name],
	--	[DocRefNo],[StkTypeId],[StkType],[Product Code],[Product Name],[Product Batch Code],
	--	[Qty],[Rate],[Amount],[Amount For Claim],[ReasonId],[Reason]
	--	FROM #RptSalvageAll ORDER BY [Reference Number]
	-- Added on 20-Jun-2009  CAST(Qty AS INT)
	SELECT A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.Qty AS INT)>nullif(ConverisonFactor2,0) Then CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>Isnull(ConverisonFactor2,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(A.Qty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>Isnull(ConverisonFactor3,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(A.Qty) AS INT) End			
		ELSE CAST(Sum(A.Qty) AS INT) END
	END as Uom4,A.Rate,A.Amount,A.[Amount For Claim],A.ReasonId,A.Reason
	FROM #RptSalvageAll A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
	Group by A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,
	ConversionFactor1,Rate,Amount,A.[Amount For Claim],A.ReasonId,A.Reason
	ORDER BY A.[Reference Number]
	-- End Here
	--------- Added on 26-Jun-2009
	SELECT A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.Qty AS INT)>nullif(ConverisonFactor2,0) Then CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>Isnull(ConverisonFactor2,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(A.Qty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>Isnull(ConverisonFactor3,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(A.Qty) AS INT) End			
		ELSE CAST(Sum(A.Qty) AS INT) END
	END as Uom4,
	A.Rate,A.Amount,A.[Amount For Claim],A.ReasonId,A.Reason INTO #RptSalvageAllGrid
	FROM #RptSalvageAll A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
	Group by A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,
	ConversionFactor1,Rate,Amount,A.[Amount For Claim],A.ReasonId,A.Reason
	ORDER BY A.[Reference Number]
	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
	INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,Rptid,Usrid)
	SELECT [Reference Number],[Salvage Date],[Location Name],[StkType],[Product Name],[Product Batch Code],[Qty],Uom1,Uom2,Uom3,Uom4,Rate,Amount,[Amount For Claim],Reason,@Pi_RptId,@Pi_UsrId
	FROM #RptSalvageAllGrid
	-- select * from RptColValues WHERE RptId=21 AND Usrid=1
	--- End here on 26-Jun-2009
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name = 'Proc_RptSampleIssue' AND Xtype = 'P')
DROP PROCEDURE Proc_RptSampleIssue
GO
-- EXEC Proc_RptSampleIssue 159,1,1,'Parle',0,0,1
CREATE PROCEDURE Proc_RptSampleIssue
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
* VIEW		: Proc_RptSampleIssue
* PURPOSE	: To get the Sample Issue Products Details
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 02/12/2008
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}	
* 16.02.2010	Panneer		 Added Product Hierarchy Filter
* 18.03.2010      Panneer		 Added Comp.Code/Dist.Code Filter
* 07.09.2010      Panneer            Added Retailer Shipping Address in Excel
********************************************************************************************************/
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
	
	--Filter Variables
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId 		AS	INT
	DECLARE @RtrId 		AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @CtgLevelId	AS 	INT
	DECLARE @RtrClassId	AS 	INT
	DECLARE @CtgMainId 	AS 	INT
	DECLARE @IssueRefId	AS	INT
	DECLARE @SalId		AS	INT
	DECLARE @Status		AS	INT
	DECLARE @ReasonId	AS	INT
	DECLARE @PrdTypeId	AS	INT
	----Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @IssueRefId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,216,@Pi_UsrId))
	SET @SalId = (SElect TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId))
	SET @Status = (SElect TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	--- 16.02.2010
	SET @ReasonId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,159,@Pi_UsrId))
	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (Select TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (Select TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @PrdTypeId = (Select TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,276,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	IF @IssueRefId=''
	SET @IssueRefId=0
	---Till Here
	Create TABLE #RptSampleIssue
	(
				RtrCode		NVARCHAR(100),
				RtrName		NVARCHAR(100),
				IssueRefNo	NVARCHAR(100),
				IssueDate	DATETIME,
				BillRefNo	NVARCHAR(100),
				SchemeCode	NVARCHAR(100),
				SKUName		NVARCHAR(100),
				UOM		NVARCHAR(100),
				Qty		NUMERIC(38,0),
				Status		NVARCHAR(100),
				Returnable	NVARCHAR(25),
				DueDate		DateTime,
				PrdId	INT,
				PrdDCode NVARCHAR(100),
				Reason  NVARCHAR(100),
				MRP NUMERIC(18,2)
	)
	SET @TblName = 'RptSampleIssue'
	SET @TblStruct = '	RtrCode		NVARCHAR(100),
				RtrName		NVARCHAR(100),
				IssueRefNo	NVARCHAR(100),
				IssueDate	DATETIME,
				BillRefNo	NVARCHAR(100),
				SchemeCode	NVARCHAR(100),
				SKUName		NVARCHAR(100),
				UOM		NVARCHAR(100),
				Qty		NUMERIC(38,0),
				Status		NVARCHAR(100),
				Returnable	NVARCHAR(25),
				DueDate		DateTime,
				PrdId	INT,
				PrdDCode NVARCHAR(100),
				Reason  NVARCHAR(100),
				MRP NUMERIC(18,2)'
	SET @TblFields = 'RtrCode,RtrName,IssueRefNo,IssueDate,BillRefNo,SchemeCode,SKUName,
					  UOM,Qty,Status,Returnable,DueDate,PrdId,PrdDCode,Reason,MRP'
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
	EXECUTE PROC_SAMPLEISSUE @PI_RPTID,@PI_USRID,@FromDate,@ToDate
	INSERT INTO #RptSampleIssue (	RtrCode,RtrName,IssueRefNo,IssueDate,BillRefNo,
									SchemeCode,SKUName,UOM,Qty,Status,Returnable,DueDate,PrdId,PrdDCode,Reason,MRP)
	SELECT DISTINCT RtrCode,RtrName,A.IssueRefNo,A.IssueDate,SalInvNo,SchCode,SKUName,UomCode,UomBaseQty,
					DlvStsDesc,Returnable,DueDate,SKUPrdId,PrdDCode,'',0.0 MRP
	FROM 
			TempSampleIssue a,FreeIssueHD b,Product P
	WHERE 	
			P.PrdId = A.SkuPrdId
			AND (A.CmpId = (CASE @CmpId WHEN 0 THEN A.CmpId ELSE 0 END) OR
							A.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			
			AND	(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE -1 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
			AND	(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE -1 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
		
			AND	(CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR
							CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
		
			AND	(A.RtrId=(CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
		
			AND	(RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR
							RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
		
			AND	(CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR
							CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
		
			AND	(A.SalId = (CASE @SalId WHEN 0 THEN A.SalId Else -1 END) OR
							A.SalId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))

			AND (A.IssueId = (CASE @IssueRefId WHEN 0 THEN A.IssueId Else 0 END) OR
							A.IssueId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,216,@Pi_UsrId)))
		
--			AND	(DlvSts = (CASE @Status WHEN 0 THEN DlvSts Else 0 END) OR
--							DlvSts in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,217,@Pi_UsrId)))
			
			AND A.IssueDate Between @FromDate AND @ToDate
--			AND [Status] = 1
	--Commented By Jisha on 08/11/2013
			----AND	(A.SKUPrdId = (CASE @PrdCatId WHEN 0 THEN A.SKUPrdId Else 0 END) OR
			----				A.SKUPrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			----AND (A.SKUPrdId = (CASE @PrdId WHEN 0 THEN A.SKUPrdId Else 0 END) OR
			----				A.SKUPrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
----SELECT * FROM #RptSampleIssue				
	SELECT DISTINCT 
		A.PrdId,PrdBatDetailValue INTO #TempMrp 
	FROM 
		#RptSampleIssue a,ProductBatch b (NoLock),ProductBatchDetails C (NoLock)
	WHERE 
		b.PrdId = A.PrdId  and C.PrdbatId = B.PrdbatId and DefaultPrice = 1
		AND SlNo in (SELECT SlNo FROM Batchcreation (NoLock) WHERE FieldDesc = 'MRP')
	UPDATE #RptSampleIssue SET MRP = PrdBatDetailValue 	FROM #RptSampleIssue a,#TempMrp b WHERE A.PrdId  = B.PrdId 
	IF @PrdTypeId = 2
	BEGIN
		Update #RptSampleIssue SET PrdDcode = PrdCcode
		From #RptSampleIssue  a,Product b
		WHere A.PrdId = B.PrdId
	END
	IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptSampleIssue ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE BillStatus=1  AND (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '
				+ 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '
				+ 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND(CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR'
				+ 'CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',29,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND(RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR '
				+ 'RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',31,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND(CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR '
				+ 'CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',30,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (SalId = (CASE @SalId WHEN 0 THEN SalId Else -1 END) OR '
				+ 'SalId in (SELECT iCountid from Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',34,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (IssueId = (CASE @IssueRefId WHEN 0 THEN IssueId Else 0 END) OR '
				+ 'IssueId in (SELECT iCountid from Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',216,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (DlvSts = (CASE @Status WHEN 0 THEN DlvSts Else 0 END) OR '
				+ 'DlvSts in (SELECT iCountid from Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',217,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND IssueDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSampleIssue'
				
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
			SET @SSQL = 'INSERT INTO #RptSampleIssue ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSampleIssue
	-- Till Here
	SELECT  RtrCode,RtrName,IssueRefNo,IssueDate,BillRefNo,SchemeCode,
			PrdDCode,SKUName,MRP,UOM,Qty,Status,Returnable,DueDate,Reason,PrdId 
	FROM #RptSampleIssue
--SELECT * FROM TEMPSAMPLEISSUE
-- EXEC [Proc_RptSampleIssue] 233,1,1,'Loreal',0,0,1
	DELETE FROM RptSampleIssue_Excel 
	INSERT INTO RptSampleIssue_Excel 
	SELECT DISTINCT  C.RtrCode,C.RtrName,
			RtrShipAdd1 + ' --> ' + RtrShipAdd2 + ' --> ' + RtrShipAdd3 as RtrShipAddress,
			C.IssueRefNo,C.IssueDate,BillRefNo,SchemeCode,PrdDCode,C.SKUName,
			MRP,UOM,Qty,C.Status,C.Returnable,C.DueDate,PrdId,@Pi_UsrId
	FROM TEMPSAMPLEISSUE A 
			Left Outer JOIN FreeIssueHD B ON A.IssueId = B.IssueId
			INNER JOIN #RptSampleIssue C On A.IssueRefNo = C.IssueRefNo 
										    AND C.IssueRefNo = B.IssueRefNo
			INNER JOIN Retailer D ON C.RtrCode = D.RtrCode
			LEFT OUTER JOIN RetailerShipAdd E ON D.RtrId = E.RtrId --and B.RtrShipId = E.RtrShipId		
	RETURN 
END
GO
DELETE FROM RptGroup WHERE PId='TaxReports' AND RptId IN (28,29)
DELETE FROM RptGroup WHERE PId='ParleReports' AND RptId IN (28,29)
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',28,'InputVatSummary','Input VAT Summary',1
UNION
SELECT 'ParleReports',29,'OutputVatSummary','Output VAT Summary',1
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_ReturnSchemeApplicable')
DROP PROCEDURE Proc_ReturnSchemeApplicable
GO
CREATE PROCEDURE [dbo].[Proc_ReturnSchemeApplicable]
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
* PROCEDURE	: Proc_ReturnSchemeApplicable
* PURPOSE	: To Return whether the Scheme is applicable for the Retailer or Not
* CREATED	: Thrinath
* CREATED DATE	: 12/04/2007
* NOTE		: General SP for Returning the whether the Scheme is applicable for the Retailer or Not
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
		CtgLinkId			INT,
		CtgLevelId			INT,
		RtrPotentialClassId	INT,
		RtrKeyAcc			INT,
		VillageId			INT
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
		AttrType		INT,
		AttrId			INT
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
	SET @Applicable_RtrLvl=0
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
-- Commented by Boopathy for applying Channel Level Scheme on 31122010
	INSERT INTO @RetDet(RtrId,RtrValueClassId,CtgMainId,CtgLinkId,CtgLevelId,RtrPotentialClassId,RtrKeyAcc,VillageId)
	SELECT R.RtrId,RVCM.RtrValueClassId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId,
		ISNULL(RPCM.RtrPotentialClassId,0) AS RtrPotentialClassId,R.RtrKeyAcc,R.VillageId
		FROM Retailer  R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
		LEFT OUTER JOIN RetailerPotentialClassmap RPCM on R.RtrId = RPCM.RtrId
		LEFT OUTER JOIN RetailerPotentialClass [RPC] on RPCM.RtrPotentialClassId = [RPC].RtrClassId
--		SELECT DISTINCT RtrId,RtrValueClassId,A.CtgMainId,A.CtgLinkId,A.CtgLevelId,RtrPotentialClassId,RtrKeyAcc,VillageId 
--		FROM RetailerCategory A INNER JOIN
--		(SELECT A.CtgLinkCode As CtgLinkCode,A.CtgMainId,RtrId,RtrValueClassId,RtrPotentialClassId,
--			RtrKeyAcc,VillageId FROM RetailerCategory A INNER JOIN 
--		(SELECT R.RtrId,RVCM.RtrValueClassId,ISNULL(RPCM.RtrPotentialClassId,0) AS RtrPotentialClassId,
--				R.RtrKeyAcc,R.VillageId,RVC.CtgMainId,RC.CtgLinkCode FROM Retailer  R 
--				INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
--				INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
--				LEFT OUTER JOIN RetailerPotentialClassmap RPCM on R.RtrId = RPCM.RtrId
--				LEFT OUTER JOIN RetailerPotentialClass [RPC] on RPCM.RtrPotentialClassId = [RPC].RtrClassId
--				INNER JOIN RetailerCategory RC ON RC.CtgMainId=RVC.CtgMainId) B
--		ON 
--		A.CtgLinkCode LIKE '%' + CASE LEN(B.CtgLinkCode)/3 WHEN LEFT(B.CtgLinkCode,3)  +'%' ) B ON A.CtgLinkCode LIKE '%' + B.CtgLinkCode + '%'
	
--	SELECT DISTINCT RtrId,RtrValueClassId,A.CtgMainId,A.CtgLinkId,A.CtgLevelId,RtrPotentialClassId,RtrKeyAcc,VillageId 
--	FROM RetailerCategory A INNER JOIN
--	(
--		SELECT A.CtgLinkCode As CtgLinkCode,A.CtgMainId,RtrId,RtrValueClassId,RtrPotentialClassId,
--		RtrKeyAcc,VillageId,A.CtgLevelId FROM RetailerCategory A INNER JOIN 
--		(
--			SELECT R.RtrId,RVCM.RtrValueClassId,ISNULL(RPCM.RtrPotentialClassId,0) AS RtrPotentialClassId,
--			R.RtrKeyAcc,R.VillageId,RVC.CtgMainId,RC.CtgLinkCode FROM Retailer  R 
--			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
--			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
--			LEFT OUTER JOIN RetailerPotentialClassmap RPCM on R.RtrId = RPCM.RtrId
--			LEFT OUTER JOIN RetailerPotentialClass [RPC] on RPCM.RtrPotentialClassId = [RPC].RtrClassId
--			INNER JOIN RetailerCategory RC ON RC.CtgMainId=RVC.CtgMainId
--		) B	ON A.CtgLinkCode LIKE '%' + 
--			CASE 
--			WHEN (LEN(A.CtgLinkCode)/A.CtgLevelId) >0  THEN	LEFT(B.CtgLinkCode,LEN(B.CtgLinkCode)-(LEN(A.CtgLinkCode)/A.CtgLevelId )) ELSE B.CtgLinkCode END  + '%' 
--
--	) B ON A.CtgLinkCode LIKE  B.CtgLinkCode + '%'
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
	SET @Applicable_PC=1
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
		--ELSE IF @AttrType =21  
		--    SET @Applicable_Cluster=1  
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
		IF @AttrType = 4 AND @Applicable_RtrLvl=0		--Retailer Category Level
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.CtgLevelId  AND A.AttrType = @AttrType)
				SET @Applicable_RtrLvl = 1
		END
		IF @AttrType = 5 AND @Applicable_RtrVal=0		--Retailer Category Level Value
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
				SET @Applicable_RtrVal = 1
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
		--IF @AttrType = 21 AND @Applicable_Cluster=0  --Cluster  
		--BEGIN     
		--	IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND  
		--		AttrId IN(SELECT DISTINCT ClusterId FROM ClusterAssign WHERE MasterId=79
		--				 AND MAsterRecordId=@Pi_RtrId))  --   AND Status=0
		--	SET @Applicable_Cluster = 1  
		--END
		SET @Applicable_Cluster = 1
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	END
	CLOSE CurSch
	DEALLOCATE CurSch
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
	IF @Applicable_SM=1 AND @Applicable_RM=1 AND @Applicable_Vill=1 AND @Applicable_RtrLvl=1 AND
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
	--PRINT @Po_Applicable
	RETURN
End
GO
---CLOSING STOCK REPORT30530
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='RptStockandSalesVolume_Excel' AND XTYPE='U') 
DROP TABLE RptStockandSalesVolume_Excel
GO
CREATE TABLE RptStockandSalesVolume_Excel(
	[PrdId] [int] NULL,
	[PrdDCode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[CmpId] [int] NULL,
	[CmpName] [nvarchar](50) NULL,
	[LcnId] [int] NULL,
	[LcnName] [nvarchar](50) NULL,
	[OpeningStock] [numeric](38, 0) NULL,
	[OpeningStockInVolume] [numeric](38, 6) NULL,
	[Purchase] [numeric](38, 0) NULL,
	[PurchaseStockInVolume] [numeric](38, 6) NULL,
	[Sales] [numeric](38, 0) NULL,
	[SalesStockInVolume] [numeric](38, 6) NULL,
	[AdjustmentIn] [numeric](38, 0) NULL,
	[AdjustmentInStockVolume] [numeric](38, 6) NULL,
	[AdjustmentOut] [numeric](38, 0) NULL,
	[AdjustmentOutStockVolume] [numeric](38, 6) NULL,
	[PurchaseReturn] [numeric](38, 0) NULL,
	[PurchaseReturnStockInVolume] [numeric](38, 6) NULL,
	[SalesReturn] [numeric](38, 0) NULL,
	[SalesReturnStockInVolume] [numeric](38, 6) NULL,
	[ClosingStock] [numeric](38, 0) NULL,
	[ClosingStockInVolume] [numeric](38, 6) NULL,
	[DispBatch] [int] NULL,
	[ClosingStkValue] [numeric](38, 6) NULL,
	[PrdWeight] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
--CLOSING STOCK REPORT PARLE BUGID:30534
DELETE FROM RptExcelHeaders WHERE RPTID=254
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,1,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,2,'PrdDCode','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,3,'PrdName','Product Description',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,4,'MRP','MRP',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,5,'RATE','RATE',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,6,'BOXES','BOXES',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,7,'PKTS','PKTS',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,8,'StockValue','Stock Value',1,1)
GO
DELETE FROM RptDetails WHERE RptId=51
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,1,'From Date',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,2,'To Date',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,3,'Company',-1,'','CmpID,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to Select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,4,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,0,0,'Press F4/Double click to select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,5,'RouteMaster',-1,'','RMId,RMCode,RMName','Route...','',1,'',2,0,0,'Press F4/Double click to select Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,6,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double click to select Hierarchy Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,7,'ProductCategoryValue',6,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to select Product Hierarchy Level Value',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,8,'Product',7,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,0,'Press F4/Double click to select Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (51,9,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','No.of Days to be Consider*','',1,'',66,0,0,'Enter No of Days to be Consider',0)
GO
UPDATE RptGroup SET VISIBILITY=0 WHERE RPTID=217 AND GRPCODE='RetailerAccountStatement' 
GO
UPDATE RptGroup SET VISIBILITY=0 WHERE RPTID=243 AND GRPCODE='BusinessSummaryReport' 
GO
UPDATE RptGroup SET VISIBILITY=0 WHERE RPTID=9 AND GRPCODE='SalesReturnReport' 
GO
UPDATE RptGroup SET VISIBILITY=0 WHERE RPTID=52 AND GRPCODE='SalesAnalysisReport' 
GO
UPDATE RptGroup SET VISIBILITY=0 WHERE RPTID=207 AND GRPCODE='PSREfficiencyDatewiseReport' 
GO
UPDATE RptGroup SET VISIBILITY=0 WHERE RPTID=242 AND GRPCODE='SubStockistClaimDetails' 
GO
UPDATE RptGroup SET VISIBILITY=0 WHERE RPTID=219 AND GRPCODE='StockReportHieararchy'
GO
UPDATE RptGroup SET VISIBILITY=1 WHERE RPTID=215 AND GRPCODE='RetailerWiseSchemeUtilizationReport' 
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptStockandSalesVolumeParle' AND XTYPE='P')
DROP PROCEDURE Proc_RptStockandSalesVolumeParle
GO
--EXEC Proc_RptStockandSalesVolumeParle 236,2,0,'CKProduct',0,0,1
CREATE PROCEDURE Proc_RptStockandSalesVolumeParle  
(  
	 @Pi_RptId  INT,  
	 @Pi_UsrId  INT,  
	 @Pi_SnapId  INT,  
	 @Pi_DbName  nvarchar(50),  
	 @Pi_SnapRequired INT,  
	 @Pi_GetFromSnap  INT,  
	 @Pi_CurrencyId  INT  
)  
AS
/**************************************************************************
* PROCEDURE : Proc_RptStockandSalesVolume_Parle
* PURPOSE : To get the Stock and Sales Volume details Uom Wise for Report
* CREATED : Praveen Raj B
* CREATED DATE : 24/01/2012
* MODIFIED
***************************************************************************/
BEGIN  
SET NOCOUNT ON  
	DECLARE @NewSnapId  AS INT  
	DECLARE @DBNAME  AS  nvarchar(50)  
	DECLARE @TblName  AS nvarchar(500)  
	DECLARE @TblStruct  AS nVarchar(4000)  
	DECLARE @TblFields  AS nVarchar(4000)  
	DECLARE @sSql  AS  nVarChar(4000)  
	DECLARE @ErrNo   AS INT  
	DECLARE @PurDBName AS nVarChar(50)  
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate  AS DATETIME  
	DECLARE @LcnId   AS INT  
	DECLARE @PrdCatValId AS INT  
	DECLARE @PrdId  AS INT  
	DECLARE @CmpId   AS INT  
	DECLARE @PrdStatus  AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @StockValue 	AS	INT
	DECLARE @RptDispType	AS INT
	--select *  from TempRptStockNSales  
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
	SET @PrdStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))  
	SET @PrdBatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))  
	SET @StockValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))  
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
Print @PrdStatus
 --IF @IncOffStk=1    
 --BEGIN    
  Exec Proc_GetStockNSalesDetailsWithOffer @FromDate,@ToDate,@Pi_UsrId    
 --END    
 --ELSE    
 --BEGIN    
 -- Exec Proc_GetStockNSalesDetails @FromDate,@ToDate,@Pi_UsrId    
 --END  
	CREATE TABLE #RptStockandSalesVolume_Parle  
	(  
		PrdId			INT,  
		PrdDCode			NVARCHAR(40),  
		PrdName			NVARCHAR(100),  
		PrdBatId			INT,  
		PrdBatCode		NVARCHAR(50),  
		CmpId			INT,  
		CmpName			NVARCHAR(50),  
		LcnId			INT,  
		LcnName			NVARCHAR(50),   
		OpeningStock		Int,    
		Purchase			Int,  
		Sales			INT,  
		Adjustment      Int,
		PurchaseReturn   INT,  
		SalesReturn		INT,    
		ClosingStock		INT,  
		ClosingStkValue	NUMERIC (38,6),
		OpenWeight	NUMERIC (38,6),
		PurchaseWeight NUMERIC (38,6),
		SalesWeight NUMERIC (38,6),
		AdjustmentWeight NUMERIC (38,6),
		PurchaseReturnWeight NUMERIC (38,6),
		SalesReturnWeight NUMERIC (38,6),
		ClosingStockWeight NUMERIC (38,6),
		OpeningStkValue NUMERIC (38,6),
		PurchaseStkValue NUMERIC (38,6),
		SalesStkValue NUMERIC (38,6),
		AdjustmentStkValue NUMERIC (38,6),
		ClosingStockkValue NUMERIC (38,6)
	)  
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
	
	SELECT Prdid,
			Case PrdUnitId 
			When 2 Then (PrdWgt/1000)/1000
			When 3 Then PrdWgt/1000 END AS PrdWgt
			Into #PrdWeight  From Product
	
	SELECT * INTO #RptStockandSalesVolume_Parle1 FROM #RptStockandSalesVolume_Parle  
	SET @TblName = 'RptStockandSalesVolume'  
	SET @TblStruct = 'PrdId    INT,  
					  PrdDCode			NVARCHAR(40),  
					  PrdName			NVARCHAR(100),  
					  PrdBatId			INT,  
					  PrdBatCode		NVARCHAR(50),  
					  CmpId				INT,  
					  CmpName			NVARCHAR(50),  
					  LcnId				INT,  
					  LcnName			NVARCHAR(50),   
					  OpeningStock		Int,  
					  Purchase			Int,  
					  Sales				INT,     
					  Adjustment		Int,
					  PurchaseReturn	INT,  
					  SalesReturn		INT,     
					  ClosingStock		INT,  
					  ClosingStkValue	NUMERIC (38,6),
					  OpenWeight		NUMERIC (38,6),
					  PurchaseWeight	NUMERIC (38,6),
					  SalesWeight		NUMERIC (38,6),
					  AdjustmentWeight	NUMERIC (38,6),
					  PurchaseReturnWeight	NUMERIC (38,6),
					  SalesReturnWeight		NUMERIC (38,6),
					  ClosingStockWeight	NUMERIC (38,6)  
					  OpeningStkValue		NUMERIC (38,6),
					  PurchaseStkValue		NUMERIC (38,6),
					  SalesStkValue			NUMERIC (38,6),
					  AdjustmentStkValue	NUMERIC (38,6),
					  ClosingStockkValue		NUMERIC (38,6)'
	SET @TblFields = 'PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
   					  LcnName,OpeningStock,Purchase,Sales,Adjustment,  
					  PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue,OpenWeight,PurchaseWeight
					  SalesWeight,AdjustmentWeight,PurchaseReturnWeight,SalesReturnWeight,ClosingStockWeight,
					  OpeningStkValue,PurchaseStkValue,SalesStkValue,AdjustmentStkValue,ClosingStockkValue'  
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
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
			INSERT INTO #RptStockandSalesVolume_Parle (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												 LcnName,OpeningStock,Purchase,Sales,Adjustment,PurchaseReturn,SalesReturn,
												 ClosingStock,ClosingStkValue,OpenWeight,PurchaseWeight,
												 SalesWeight,AdjustmentWeight,PurchaseReturnWeight,SalesReturnWeight,ClosingStockWeight
												 ,OpeningStkValue,PurchaseStkValue,SalesStkValue,AdjustmentStkValue,ClosingStockkValue)  
			SELECT PrdId,PrdDcode,PrdName,0,0,TempRptStockNSales.CmpId,CmpName,LcnId,LcnName,  
			Opening,(Purchase-PurchaseReturn),(Sales-SalesReturn),(AdjustmentIn-AdjustmentOut),PurchaseReturn,SalesReturn,Closing,
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId),0,0,0,0,0,0,0,
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN OpnSelRte WHEN 2 THEN OpnPurRte WHEN 3 THEN OpnMRPRte END,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN PurSelRte WHEN 2 THEN PurPurRte WHEN 3 THEN PurMRPRte END,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN SalSelRte WHEN 2 THEN SalPurRte WHEN 3 THEN SalMRPRte END,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN (AdjInSelRte-AdjOutSelRte) WHEN 2 THEN (AdjInPurRte+AdjOutPurRte) WHEN 3 THEN 
			(AdjInMRPRte+AdjOutMRPRte) END,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId)
			FROM TempRptStockNSales 
			INNER JOIN  Company  C ON C.CmpId = TempRptStockNSales.CmpId 
			WHERE 
			( TempRptStockNSales.CmpId = (CASE @CmpId WHEN 0 THEN TempRptStockNSales.CmpId ELSE 0 END) OR  
			TempRptStockNSales.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
			AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
			LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
			AND (PrdStatus = (CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END) OR  
			PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))  
			--AND (BatStatus = (CASE @BatStatus WHEN 0 THEN BatStatus ELSE 2 END) OR  
			--BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdCatValId WHEN 0 THEN PrdId Else 0 END) OR  
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
			AND UserId=@Pi_UsrId 
			And Opening+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+Closing <>0 Order By PrdDcode
			Update R Set OpenWeight=(OpeningStock*PrdWgt),
			PurchaseWeight=(Purchase*PrdWgt),
			SalesWeight=(Sales*PrdWgt),
			AdjustmentWeight=(Adjustment*PrdWgt),
			PurchaseReturnWeight=(PurchaseReturn*PrdWgt),
			SalesReturnWeight=(SalesReturn*PrdWgt),
			ClosingStockWeight=(ClosingStock*PrdWgt)
			From #PrdWeight PW 
			Inner Join #RptStockandSalesVolume_Parle R On R.PrdId=PW.PrdId
		
		IF LEN(@PurDBName) > 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume_Parle ' +  
			'(' + @TblFields + ')' +  
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +  
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( LcnId = (CASE ' + CAST(@LcnId AS nVarChar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR ' +  
			' LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE 0 END) OR ' +  
			' PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',24,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '  
			--+ '( BatStatus = (CASE ' + CAST(@BatStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE 0 END) OR ' +  
			--' BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',25,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
			+ '( PrdId = (CASE ' + CAST(@PrdCatValId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +  
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
			+ ' (R.PrdId = (CASE ' + CAST(@PrdId AS nVarChar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +  
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS  nVarchar(10)) + ',5,' +  CAST(@Pi_UsrId AS nVarchar(10)) + ' )))'  
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptStockandSalesVolume_Parle'  
			EXEC (@SSQL)  
			PRINT 'Saved Data Into SnapShot Table'  
		END  
	END  
	ELSE    --To Retrieve Data From Snap Data  
	BEGIN  
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
		IF @ErrNo = 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume_Parle ' +  
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
			RETURN  
		END  
	END  
	
			SELECT	RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName, 
					Cast(Case When SUM(OpeningStock)<MAX(ConversionFactor) Then 0 Else SUM(OpeningStock)/MAX(ConversionFactor) End As VarChar(25)) As OpeneningBox,
					Cast(Case When SUM(OpeningStock)<MAX(ConversionFactor) Then SUM(OpeningStock) Else SUM(OpeningStock)%MAX(ConversionFactor) End As VarChar(25)) As OpeneningPack,
					Cast(Case When SUM(Purchase)<MAX(ConversionFactor) Then 0 Else SUM(Purchase)/MAX(ConversionFactor) End As VarChar(25)) As PurchaseBox,
					Cast(Case When SUM(Purchase)<MAX(ConversionFactor) Then SUM(Purchase) Else SUM(Purchase)%MAX(ConversionFactor) End As VarChar(25)) As PurchasePack,
					Cast(Case When SUM(Sales)<MAX(ConversionFactor) Then 0 Else SUM(Sales)/MAX(ConversionFactor) End As VarChar(25)) As SalesBox,
					Cast(Case When SUM(Sales)<MAX(ConversionFactor) Then SUM(Sales) Else SUM(Sales)%MAX(ConversionFactor) End As VarChar(25)) As SalesPack,
					Cast(Case When SUM(Adjustment)<MAX(ConversionFactor) Then 0 Else SUM(Adjustment)/MAX(ConversionFactor) End As VarChar(25)) As AdjustmentBox,
					Cast(Case When SUM(Adjustment)<MAX(ConversionFactor) Then SUM(Adjustment) Else SUM(Adjustment)%MAX(ConversionFactor) End As VarChar(25)) As AdjustmentPack,
					--Cast(Case When AdjustmentIn<MAX(ConversionFactor) Then 0 Else AdjustmentIn/MAX(ConversionFactor) End As Int) -
					--Cast(Case When AdjustmentOut<MAX(ConversionFactor) Then 0 Else AdjustmentOut/MAX(ConversionFactor) End As Int)AdjustmentBox,
					--Cast(Case When AdjustmentIn<MAX(ConversionFactor) Then AdjustmentIn Else AdjustmentIn%MAX(ConversionFactor) End As Int)-
					--Cast(Case When AdjustmentOut<MAX(ConversionFactor) Then AdjustmentOut Else AdjustmentOut%MAX(ConversionFactor) End As Int) As AdjustmentPack,
					--Cast(Case When PurchaseReturn<MAX(ConversionFactor) Then 0 Else PurchaseReturn/MAX(ConversionFactor) End As VarChar(25)) As PurchaseReturnBox,
					--Cast(Case When PurchaseReturn<MAX(ConversionFactor) Then PurchaseReturn Else PurchaseReturn%MAX(ConversionFactor) End As VarChar(25)) As PurchaseReturnPack,
					--Cast(Case When SalesReturn<MAX(ConversionFactor) Then 0 Else SalesReturn/MAX(ConversionFactor) End As VarChar(25)) As SalesReturnBox,
					--Cast(Case When SalesReturn<MAX(ConversionFactor) Then SalesReturn Else SalesReturn%MAX(ConversionFactor) End As VarChar(25)) As SalesReturnPack,
					Cast(Case When SUM(ClosingStock)<MAX(ConversionFactor) Then 0 Else SUM(ClosingStock)/MAX(ConversionFactor) End As VarChar(25)) As ClosingStockBox,
					Cast(Case When SUM(ClosingStock)<MAX(ConversionFactor) Then SUM(ClosingStock) Else SUM(ClosingStock)%MAX(ConversionFactor) End As VarChar(25)) As ClosingStockPack,
					SUM(ClosingStkValue) AS ClosingStkValue,SUM(OpenWeight) AS OpenWeight,SUM(PurchaseWeight) AS PurchaseWeight,SUM(SalesWeight) AS SalesWeight,
					SUM(AdjustmentWeight) As AdjustmentWeight,
					--PurchaseReturnWeight,SalesReturnWeight,
					SUM(ClosingStockWeight) AS ClosingStockWeight,SUM(OpeningStkValue)AS OpeningStkValue,SUM(PurchaseStkValue) AS PurchaseStkValue,
					SUM(SalesStkValue)AS SalesStkValue,SUM(AdjustmentStkValue) AS AdjustmentStkValue,SUM(ClosingStockkValue) As ClosingStockkValue
					FROM #RptStockandSalesVolume_Parle RV 
					INNER JOIN #PrdUomAll P On RV.PrdId=P.PrdId
					Group By RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
							 LcnName Order By PrdDcode
						 --PurchaseReturnWeight,SalesReturnWeight,
							  
					DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
					INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
					SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume_Parle   
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN  
		If Exists (Select [Name] From SysObjects Where [Name]='RptStockandSalesVolumeParle_Excel' And XTYPE='U')
		Drop Table RptStockandSalesVolumeParle_Excel
			        SELECT RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName, 
					Cast(Case When SUM(OpeningStock)<MAX(ConversionFactor) Then 0 Else SUM(OpeningStock)/MAX(ConversionFactor) End As VarChar(25)) As OpeneningBox,
					Cast(Case When SUM(OpeningStock)<MAX(ConversionFactor) Then SUM(OpeningStock) Else SUM(OpeningStock)%MAX(ConversionFactor) End As VarChar(25)) As OpeneningPack,
					Cast(Case When SUM(Purchase)<MAX(ConversionFactor) Then 0 Else SUM(Purchase)/MAX(ConversionFactor) End As VarChar(25)) As PurchaseBox,
					Cast(Case When SUM(Purchase)<MAX(ConversionFactor) Then SUM(Purchase) Else SUM(Purchase)%MAX(ConversionFactor) End As VarChar(25)) As PurchasePack,
					Cast(Case When SUM(Sales)<MAX(ConversionFactor) Then 0 Else SUM(Sales)/MAX(ConversionFactor) End As VarChar(25)) As SalesBox,
					Cast(Case When SUM(Sales)<MAX(ConversionFactor) Then SUM(Sales) Else SUM(Sales)%MAX(ConversionFactor) End As VarChar(25)) As SalesPack,
					Cast(Case When SUM(Adjustment)<MAX(ConversionFactor) Then 0 Else SUM(Adjustment)/MAX(ConversionFactor) End As VarChar(25)) As AdjustmentBox,
					Cast(Case When SUM(Adjustment)<MAX(ConversionFactor) Then SUM(Adjustment) Else SUM(Adjustment)%MAX(ConversionFactor) End As VarChar(25)) As AdjustmentPack,
					--Cast(Case When AdjustmentIn<MAX(ConversionFactor) Then 0 Else AdjustmentIn/MAX(ConversionFactor) End As Int) -
					--Cast(Case When AdjustmentOut<MAX(ConversionFactor) Then 0 Else AdjustmentOut/MAX(ConversionFactor) End As Int)AdjustmentBox,
					--Cast(Case When AdjustmentIn<MAX(ConversionFactor) Then AdjustmentIn Else AdjustmentIn%MAX(ConversionFactor) End As Int)-
					--Cast(Case When AdjustmentOut<MAX(ConversionFactor) Then AdjustmentOut Else AdjustmentOut%MAX(ConversionFactor) End As Int) As AdjustmentPack,
					--Cast(Case When PurchaseReturn<MAX(ConversionFactor) Then 0 Else PurchaseReturn/MAX(ConversionFactor) End As VarChar(25)) As PurchaseReturnBox,
					--Cast(Case When PurchaseReturn<MAX(ConversionFactor) Then PurchaseReturn Else PurchaseReturn%MAX(ConversionFactor) End As VarChar(25)) As PurchaseReturnPack,
					--Cast(Case When SalesReturn<MAX(ConversionFactor) Then 0 Else SalesReturn/MAX(ConversionFactor) End As VarChar(25)) As SalesReturnBox,
					--Cast(Case When SalesReturn<MAX(ConversionFactor) Then SalesReturn Else SalesReturn%MAX(ConversionFactor) End As VarChar(25)) As SalesReturnPack,
					Cast(Case When SUM(ClosingStock)<MAX(ConversionFactor) Then 0 Else SUM(ClosingStock)/MAX(ConversionFactor) End As VarChar(25)) As ClosingStockBox,
					Cast(Case When SUM(ClosingStock)<MAX(ConversionFactor) Then SUM(ClosingStock) Else SUM(ClosingStock)%MAX(ConversionFactor) End As VarChar(25)) As ClosingStockPack,
					SUM(ClosingStkValue) AS ClosingStkValue,SUM(OpenWeight) AS OpenWeight,SUM(PurchaseWeight) AS PurchaseWeight,SUM(SalesWeight) AS SalesWeight,
					SUM(AdjustmentWeight) As AdjustmentWeight,
					--PurchaseReturnWeight,SalesReturnWeight,
					SUM(ClosingStockWeight) AS ClosingStockWeight,SUM(OpeningStkValue)AS OpeningStkValue,SUM(PurchaseStkValue) AS PurchaseStkValue,
					SUM(SalesStkValue)AS SalesStkValue,SUM(AdjustmentStkValue) AS AdjustmentStkValue,SUM(ClosingStockkValue) As ClosingStockkValue
					INTO RptStockandSalesVolumeParle_Excel FROM #RptStockandSalesVolume_Parle RV 
					INNER JOIN #PrdUomAll P On RV.PrdId=P.PrdId
					Group By RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
							 LcnName Order By PrdDcode
		END 
		
	RETURN  
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='RptLocationTransferAll' AND XTYPE='U') 
DROP TABLE RptLocationTransferAll
GO
CREATE TABLE RptLocationTransferAll(
	[RefNo] [nvarchar](20) NULL,
	[TransferDate] [datetime] NULL,
	[FromLcnId] [int] NULL,
	[FromLocation] [nvarchar](50) NULL,
	[ToLcnId] [int] NULL,
	[ToLocation] [nvarchar](50) NULL,
	[DocRefNo] [nvarchar](20) NULL,
	[CmpId] [int] NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[TrfQty] [int] NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptLocationTransfer' AND XTYPE='P')
DROP PROCEDURE Proc_RptLocationTransfer
GO
---   Exec [Proc_RptLocationTransfer] 22,1,0,'parletest',0,0,1
CREATE PROCEDURE Proc_RptLocationTransfer
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
--Filter Variable
DECLARE @FromDate	   AS	DATETIME
DECLARE @ToDate	 	   AS	DATETIME
DECLARE @CmpId         AS  INT
DECLARE @FromLcnId	   AS	INT
DECLARE @ToLcnId	   AS	INT
--Till Here
EXEC Proc_RptLocationTransferAll @Pi_RptId ,@Pi_UsrId
--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @FromLcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,39,@Pi_UsrId))
SET @ToLcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,40,@Pi_UsrId))
--Till Here
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--Till Here
CREATE TABLE #RptLocationTransferAll
(
[Reference Number] nvarchar(20),
[Transfer Date] datetime,
[From Location] nvarchar(50),
[To Location] nvarchar(50),
[DocRefNo] nvarchar(20),
[Product Code] nvarchar(100),
[Product Name] nvarchar(200),
[Product Batch Code] nvarchar(100),
[Transfer Qty] int
)
SET @TblName = 'RptLocationTransferAll'
SET @TblStruct = '       [Reference Number] nvarchar(20),
[Transfer Date] datetime,
[From Location] nvarchar(50),
[To Location] nvarchar(50),
[DocRefNo] nvarchar(20),
[Product Code] nvarchar(100),
[Product Name] nvarchar(200),
[Product Batch Code] nvarchar(100),
[Transfer Qty] int'
SET @TblFields = ' [Reference Number],
[Transfer Date] ,
[From Location] ,
[To Location] ,
[DocRefNo] ,
[Product Code] ,
[Product Name] ,
[Product Batch Code] ,
[Transfer Qty] '
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
	INSERT INTO #RptLocationTransferAll([Reference Number],
[Transfer Date] ,
[From Location] ,
[To Location] ,
[DocRefNo] ,
[Product Code] ,
[Product Name] ,
[Product Batch Code] ,
[Transfer Qty])
		
	SELECT RefNo,TransferDate,FromLocation,ToLocation,DocRefNo,PrdCode,PrdName,PrdBatCode,TrfQty
FROM RptLocationTransferAll
	     WHERE
	     UsrId = @Pi_UsrId and
(FromLcnId=(CASE @FromLcnId WHEN 0 THEN FromLcnId ELSE 0 END) OR
					FromLcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,39,@Pi_UsrId)) )
AND (ToLcnId=(CASE @ToLcnId WHEN 0 THEN ToLcnId ELSE 0 END) OR
					ToLcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,40,@Pi_UsrId)) )
AND (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )
					
AND [TransferDate] Between @FromDate and @ToDate
	/*
		
		For ProductCategory Value and Product Filter
		R.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN R.PrdId Else 0 END) OR
		R.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
		AND R.PrdId = (CASE @fPrdId WHEN 0 THEN R.PrdId Else 0 END) OR
		R.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	*/
		
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptLocationTransferAll ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
+ '         WHERE
UsrId = ' + @Pi_UsrId + ' and
(FromLcnId=(CASE ' + @FromLcnId + ' WHEN 0 THEN FromLcnId ELSE 0 END) OR
					FromLcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ' ,39,' + @Pi_UsrId + ')) )
AND (ToLcnId=(CASE ' + @ToLcnId + ' WHEN 0 THEN ToLcnId ELSE 0 END) OR
					ToLcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',40,' + @Pi_UsrId + ')) )
AND (CmpId = (CASE ' + @CmpId + ' WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ' ,4, ' + @Pi_UsrId + ')) )
					
AND TransferDate Between ' + @FromDate + ' and ' + @ToDate
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLocationTransferAll'
	
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
		SET @SSQL = 'INSERT INTO #RptLocationTransferAll ' +
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLocationTransferAll


/*  Excel Output  */

SELECT A.*,
CASE WHEN ConverisonFactor2>0 THEN Case When CAST([Transfer Qty] AS INT)>=nullif(ConverisonFactor2,0) Then CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST([Transfer Qty] AS INT)-((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
(CAST([Transfer Qty] AS INT)-((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
CASE
	WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN
		Case When
				CAST([Transfer Qty] AS INT)-(((CAST([Transfer Qty] AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
(((CAST([Transfer Qty] AS INT)-((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
CAST([Transfer Qty] AS INT)-(((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
(((CAST([Transfer Qty] AS INT)-((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
ELSE
	CASE
		WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
			Case
				When CAST(Sum([Transfer Qty]) AS INT)>=Isnull(ConverisonFactor2,0) Then
					CAST(Sum([Transfer Qty]) AS INT)%nullif(ConverisonFactor2,0)
				Else CAST(Sum([Transfer Qty]) AS INT) End
		WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
			Case
				When CAST(Sum([Transfer Qty]) AS INT)>=Isnull(ConverisonFactor3,0) Then
					CAST(Sum([Transfer Qty]) AS INT)%nullif(ConverisonFactor3,0)
				Else CAST(Sum([Transfer Qty]) AS INT) End			
	ELSE CAST(Sum([Transfer Qty]) AS INT) END
END as Uom4
FROM #RptLocationTransferAll A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
GROUP BY [Reference Number],[Transfer Date],[From Location],[To Location],DocRefNo,[Product Code],[Product Name],[Product Batch Code],
[Transfer Qty],ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1

/*  Grid Output  */

SELECT A.*,
CASE WHEN ConverisonFactor2>0 THEN Case When CAST([Transfer Qty] AS INT)>=nullif(ConverisonFactor2,0) Then CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST([Transfer Qty] AS INT)-((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
(CAST([Transfer Qty] AS INT)-((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
CASE
	WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN
		Case When
				CAST([Transfer Qty] AS INT)-(((CAST([Transfer Qty] AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
(((CAST([Transfer Qty] AS INT)-((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
CAST([Transfer Qty] AS INT)-(((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
(((CAST([Transfer Qty] AS INT)-((CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST([Transfer Qty] AS INT)-(CAST([Transfer Qty] AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
ELSE
	CASE
		WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
			Case
				When CAST(Sum([Transfer Qty]) AS INT)>=Isnull(ConverisonFactor2,0) Then
					CAST(Sum([Transfer Qty]) AS INT)%nullif(ConverisonFactor2,0)
				Else CAST(Sum([Transfer Qty]) AS INT) End
		WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
			Case
				When CAST(Sum([Transfer Qty]) AS INT)>=Isnull(ConverisonFactor3,0) Then
					CAST(Sum([Transfer Qty]) AS INT)%nullif(ConverisonFactor3,0)
				Else CAST(Sum([Transfer Qty]) AS INT) End			
	ELSE CAST(Sum([Transfer Qty]) AS INT) END
END as Uom4   INTO #TEMPLOCTRANS
FROM #RptLocationTransferAll A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
GROUP BY [Reference Number],[Transfer Date],[From Location],[To Location],DocRefNo,[Product Code],[Product Name],[Product Batch Code],
[Transfer Qty],ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1


	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
	INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,Rptid,Usrid)
	SELECT
		[Reference Number],[Transfer Date],[From Location],
		[To Location],[DocRefNo],[Product Code],[Product Name],
		[Product Batch Code],[Transfer Qty],Uom1,Uom2,Uom3,Uom4,
		@Pi_RptId,@Pi_UsrId
	FROM #TEMPLOCTRANS 
/*  End Here  */
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptDayEndCollection' AND XTYPE='P')
DROP PROCEDURE Proc_RptDayEndCollection
GO
--exec Proc_RptDayEndCollection 239,1,0,'',0,0,1
CREATE PROCEDURE Proc_RptDayEndCollection
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
BEGIN
	
	SET NOCOUNT ON 
		DECLARE @ErrNo	 	AS	INT
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @TotBillAmount	AS	NUMERIC(38,6)
	
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	Create TABLE #RptCollectionDetail
	(
		vehNo				varchar(100),
		SalId 				BIGINT,
		SalInvNo			NVARCHAR(50),
		SalInvDate			DATETIME,
		SalInvRef 			NVARCHAR(50),
		RtrId 				INT,
		RtrName				NVARCHAR(50),
		BillAmount			NUMERIC (38,6),
		CrAdjAmount			NUMERIC (38,6),
		DbAdjAmount			NUMERIC (38,6),
		CashDiscount		NUMERIC (38,6),
		CollectedAmount		NUMERIC (38,6),
		BalanceAmount		NUMERIC (38,6),
		PayAmount			NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		--AmtStatus 			NVARCHAR(10),
		InvRcpDate			DATETIME,
		CurPayAmount        NUMERIC (38,6),
		CollCashAmt			NUMERIC (38,6),
		CollChqAmt			NUMERIC (38,6),
		CollDDAmt			NUMERIC (38,6),
		CollRTGSAmt			NUMERIC (38,6),
		[CashBill]			[numeric](38, 0) NULL,
		[ChequeBill]		[numeric](38, 0) NULL,
		[DDbill]			[numeric](38, 0) NULL,
		[RTGSBill]			[numeric](38, 0) NULL,
		[TotalBills]		[numeric](38, 0) NULL,	
		[AdjustedAmt]		NUMERIC (38,6),
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Remarks				VARCHAR(1000)
	)
	EXEC Proc_CollectionValues_Parle @FromDate,@ToDate
		
		INSERT INTO #RptCollectionDetail (vehNo,SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
		BalanceAmount,PayAmount,TotalBillAmount,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,AdjustedAmt
		,InvRcpNo,Remarks)
		SELECT VehicleCode,SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId))
		AS BalanceAmount,dbo.Fn_ConvertCurrency(PayAmount,@Pi_CurrencyId),0 AS TotalBillAmount,
		R.InvRcpDate,dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollCashAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollChqAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollDDAmt,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId))
		,R.InvRcpNo,R.Remarks
		FROM RptCollectionValue_Parle R
		INNER JOIN VehicleAllocationDetails VD on VD.SaleInvNo=R.SalInvNo
		INNER JOIN VehicleAllocationMaster VM on VM.AllotmentNumber=VD.AllotmentNumber
		INNER JOIN VEhicle V on V.VehicleId=VM.VehicleId
		WHERE 
		(V.VehicleId = (CASE @VehicleId WHEN 0 THEN V.VehicleId ELSE 0 END) OR
					V.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
		
		AND (AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN AllotmentId ELSE 0 END) OR
					AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		AND 
		(SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
		SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 
		AND 
		(DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
		DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		AND 
		(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
		RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		
	--Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCollectionDetail
	-- Till Here
	
	CREATE TABLE #Tempbalance
	(
		Billamt numeric(18,4),
		CurPayAmt numeric(18,4),
		Balance numeric(18,4),
		RtrId int,
		Salesinvoice nvarchar(50),
		Receiptinvoice nvarchar(50)
	)
	DECLARE @BillAmount NUMERIC (38,6)
	DECLARE @CurPayAmount NUMERIC (38,6)
	DECLARE @BalanceAmount NUMERIC (38,6)
	DECLARE @InvRcpNo nvarchar(50)
	DECLARE @SalinvNo nvarchar(50)
	DECLARE @TempInvoiceRcpNo nvarchar(50)
	DECLARE @CurPayAmountbal NUMERIC (38,6)
	DECLARE @BalRtrId int
--SELECT 'ddd', BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	DECLARE Cur_BalanceAmt CURSOR FOR
	SELECT BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	OPEN Cur_BalanceAmt
	FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT into #Tempbalance(BillAmt,CurPayAmt,RtrId,Salesinvoice,Receiptinvoice) VALUES (@BillAmount,@CurPayAmount,@BalRtrId,@SalinvNo,@InvRcpNo)
        SELECT @CurPayAmountbal=sum(CurPayAmt) FROM #Tempbalance WHERE RtrId=@BalRtrId AND Salesinvoice=@SalinvNo --AND Receiptinvoice=@InvRcpNo
        UPDATE #RptCollectionDetail SET BalanceAmount=BillAmount-@CurPayAmountbal WHERE CurPayAmount=@CurPayAmount
		AND SalInvNo=@SalinvNo AND InvRcpNo=@InvRcpNo AND RtrId=@BalRtrId
		FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	END
	CLOSE Cur_BalanceAmt
	DEALLOCATE Cur_BalanceAmt
	
	UPDATE #RptCollectionDetail SET  [CashBill]=(CASE WHEN CollCashAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [ChequeBill]=(CASE WHEN CollChqAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [DDbill]=(CASE WHEN CollDDAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [RTGSBill]=(CASE WHEN  CollRTGSAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [TotalBills]=(SELECT Count(Salid) FROM #RptCollectionDetail)
	
	SELECT vehno,SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,
	CashBill,Chequebill,DDBill,RTGSBill,AdjustedAmt,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptDayEndCollection_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptDayEndCollection_Excel
		SELECT vehno,SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
		BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
		ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,
		CashBill,Chequebill,DDBill,RTGSBill,AdjustedAmt,[TotalBills] into RptDayEndCollection_Excel FROM #RptCollectionDetail 
		ORDER BY vehno,InvRcpDate		
	END
RETURN
END
GO
DELETE FROM RptExcelHeaders WHERE Rptid=248
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,22,'TotalBillAmount','TotalBillAmount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,1,'vehno','vehno',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,2,'SalId','SalId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,3,'SalInvNo','Bill Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,4,'SalInvDate','Bill Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,5,'SalInvRef','SalInvRef',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,6,'InvRcpNo','InvRcpNo',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,7,'InvRcpDate','Collection Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,8,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,9,'RtrName','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,10,'BillAmount','Bill Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,11,'CurPayAmount','Paid Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,12,'AdjustedAmt','Adjusted Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,13,'CashDiscount','Cash Discount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,14,'CrAdjAmount','CrAdjAmount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,15,'DbAdjAmount','DbAdjAmount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,16,'CollCashAmt','Cash ',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,17,'CollChqAmt','Cheque',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,18,'CollDDAmt','CollDDAmt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,19,'CollRTGSAmt','CollRTGSAmt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,20,'BalanceAmount','Balance Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,21,'CollectedAmount','CollectedAmount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,23,'PayAmount','PayAmount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,24,'CashBill','CashBill',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,25,'Chequebill','Chequebill',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,26,'DDBill','DDBill',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,27,'RTGSBill','RTGSBill',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (248,28,'TotalBills','TotalBills',0,1)
GO
DELETE FROM RptExcelHeaders WHERE Rptid=22
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,1,'Reference Number','Ref. Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,2,'Transfer Date','Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,3,'From Location','From Location',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,4,'To Location','To Location',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,5,'DocRefNo','Doc Ref No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,6,'Product Code','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,7,'Product Name','Product Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,8,'Product Batch Code','Batch Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,9,'Transfer Qty','Transfer Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,10,'Uom1','Cases',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,11,'Uom2','Boxes',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,12,'Uom3','Strips',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,13,'Uom4','Pieces',0,1)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_DBDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_DBDetails
GO
/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DBDetails
EXEC Proc_Cs2Cn_DBDetails 0
SELECT * FROM Cs2Cn_Prk_DBDetails
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_DBDetails
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DBDetails
* PURPOSE		: To Extract DataBase Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 02/10/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN

--	DECLARE @CmpId 			AS INT
--	DECLARE @DistCode		AS nVarchar(50)
--	DECLARE @DefCmpAlone	AS INT
--	DECLARE @Idx			AS INT
--	DECLARE @IP				AS VARCHAR(40)
--	DECLARE @DBName			AS nVarchar(50)
--	SET @Po_ErrNo=0
--	DELETE FROM Cs2Cn_Prk_DBDetails WHERE UploadFlag = 'Y'
--	SELECT @DistCode=DistributorCode FROM Distributor
--	SELECT @DBName=DBName FROM CurrentDB
	
--	--EXEC Proc_Get_IP_Address @IP OUT
----	INSERT INTO Cs2Cn_Prk_DBDetails(DistCode,IPAddress,MachineName,DBId,DBName,DBCreatedDate,DBRestoredDate,DBRestoreId,DBFileName,UploadFlag)
----	SELECT @DistCode,@IP,@@ServerName,DBId,Name,CrDate,CrDate,0,FileName,'N' FROM Master.dbo.SysDataBases SD,CurrentDB CD
----	WHERE SD.Name=CD.DBName
--	INSERT INTO Cs2Cn_Prk_DBDetails(DistCode,IPAddress,MachineName,DBId,DBName,DBCreatedDate,DBRestoredDate,DBRestoreId,DBFileName,UploadFlag)
--	SELECT @DistCode+'~'+C.CmpCode+'~'+ISNULL(PrdKey,'') ,@IP,@@ServerName,DBId,Name,CrDate,CrDate,0,FileName,'N' 
--	FROM Master.dbo.SysDataBases SD,CurrentDB CD,Company C
--	LEFT OUTER JOIN RegInfo ON 1=1 
--	WHERE SD.Name=CD.DBName AND C.DefaultCompany=1	
--	UPDATE B SET B.DBRestoredDate=A.Restore_Date,B.DBRestoreId=A.Restore_History_Id
--	FROM Cs2Cn_Prk_DBDetails B,
--	(SELECT * FROM MSDB..RestoreHistory RS
--	WHERE RS.Destination_DataBase_Name=@DBName
--	AND RS.Restore_Date IN (SELECT MAX(Restore_Date) FROM MSDB..RestoreHistory WHERE Destination_DataBase_Name= @DBName)) A
--	WHERE B.DBName=A.Destination_DataBase_Name
--	UPDATE Cs2Cn_Prk_DBDetails SET ServerDate=@ServerDate
	SET @Po_ErrNo=0
	RETURN @Po_ErrNo

END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_UDCMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_UDCMaster
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_UDCMaster
EXEC Proc_Cn2Cs_UDCMaster 0
SELECT * FROM UDCMaster
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_UDCMaster
(
       @Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_UDCMaster
* PURPOSE		: To validate the downloaded UDC Master Details 
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 22/06/2010
* NOTE			: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @InsertCount INT
	DECLARE @Exist  INT
	DECLARE @Trans  INT
	DECLARE @MasterName  nVarchar(100)
	DECLARE @ColumnName  nVarchar(100)
	DECLARE @ColumnDataType  nVarchar(100)
	DECLARE @ColumnSize  nVarchar(50)
	DECLARE @ColumnPrecision  nVarchar(20)
	DECLARE @Editable  nVarchar(20)
	DECLARE @EditId  TINYINT
	DECLARE @MasterId  INT
	DECLARE @PickFromDefault  nVarchar(20)
	DECLARE @PickDefaultId  TINYINT
	DECLARE @UdcMasterId  INT
	DECLARE @MandatoryId  INT
	DECLARE @Mandatory AS NVARCHAR(100)
	DECLARE @sStr	nVarchar(4000)
	
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'UDCToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE UDCToAvoid	
	END
	CREATE TABLE UDCToAvoid
	(
		MasterName NVARCHAR(200),
		ColumnName NVARCHAR(200)
	)
	IF EXISTS(SELECT DISTINCT ColumnName FROM Cn2Cs_Prk_UDCMaster
	WHERE MasterName NOT IN (SELECT MasterName FROM UDCHd))
	BEGIN
		INSERT INTO UDCToAvoid(MasterName,ColumnName)
		SELECT DISTINCT MasterName,ColumnName FROM Cn2Cs_Prk_UDCMaster
		WHERE MasterName NOT IN (SELECT MasterName FROM UDCHd)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'UDC Master','MasterName','Master :'+MasterName+'is not available'
		FROM Cn2Cs_Prk_UDCMaster
		WHERE MasterName NOT IN (SELECT MasterName FROM UDCHd)		
	END
	IF EXISTS(SELECT DISTINCT ColumnName FROM Cn2Cs_Prk_UDCMaster
	WHERE ISNULL(ColumnName,'') ='')
	BEGIN
		INSERT INTO UDCToAvoid(MasterName,ColumnName)
		SELECT DISTINCT MasterName,ColumnName FROM Cn2Cs_Prk_UDCMaster
		WHERE ISNULL(ColumnName,'') =''
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'UDC Master','ColumnName','Column Name should not be empty for :'+MasterName
		FROM Cn2Cs_Prk_UDCMaster
		WHERE ISNULL(ColumnName,'') =''
	END
	DECLARE Cur_UDCMaster CURSOR
	FOR SELECT DISTINCT MasterName,ColumnName,ColumnDataType,ColumnSize,ColumnPrecision,Editable,Mandatory,PickFromDefault
	FROM Cn2Cs_Prk_UDCMaster --P INNER JOIN UDCToAvoid A ON P.MasterName=A.MasterName AND P.ColumnName=A.ColumnName
	WHERE MasterName+'~'+ColumnName NOT IN (SELECT MasterName+'~'+ColumnName FROM UDCToAvoid)
	
	OPEN Cur_UDCMaster
	FETCH NEXT FROM Cur_UDCMaster INTO @MasterName,@ColumnName,@ColumnDataType,@ColumnSize,
	@ColumnPrecision,@Editable,@Mandatory,@PickFromDefault
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist = 0 
		SET @Trans = 0
		SELECT @MasterId = MasterId FROM UDCHd WHERE MasterName = @MasterName
		IF @ColumnDataType <> 'Numeric'
		BEGIN
			SET @ColumnPrecision=0			
		END
		IF EXISTS (SELECT * FROM UdcMaster WHERE MasterId = @MasterId AND ColumnName = @ColumnName)
		BEGIN
			SELECT @UdcMasterId=UdcMasterId FROM UdcMaster WHERE MasterId = @MasterId AND ColumnName = @ColumnName
			SET @Exist=1
		END
		ELSE
		BEGIN
			SET @UdcMasterId = 0	
		END
		IF EXISTS (SELECT UdcMasterId FROM UDcDetails WHERE UdcMasterId=@UdcMasterId)
		BEGIN
			INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
			VALUES (1,'Cn2Cs_Prk_UDCMaster','UdcMasterId','Transaction Exists for column:' + CAST(@ColumnName AS VARCHAR) +' for :'+@MasterName)
			SET @Trans = 1
		END
		IF @Editable = 'No'
		BEGIN
			SET @EditId = 0
		END
		ELSE
		BEGIN
			SET @EditId = 1
		END
		IF @PickFromDefault = 'No'
		BEGIN
			SET @PickDefaultId = 0
		END
		ELSE
		BEGIN
			SET @PickDefaultId = 1
		END
		IF @Mandatory = 'No'
		BEGIN
			SET @MandatoryId = 0
		END
		ELSE
		BEGIN
			SET @MandatoryId = 1
		END
		IF @Exist = 1 AND @Trans = 0 
		BEGIN
			UPDATE UdcMaster SET ColumnName = @ColumnName,ColumnDataType = @ColumnDataType,
			ColumnSize= @ColumnSize,ColumnPrecision = @ColumnPrecision,
			Editable = @EditId,PickFromDefault = @PickDefaultId,ColumnMandatory=@MandatoryId
			WHERE ColumnName = @ColumnName AND UdcMaster.MasterId = @MasterId
		END
		ELSE 
		IF @Exist = 0
		BEGIN
			SET @UdcMasterId = dbo.Fn_GetPrimaryKeyInteger('UdcMaster','UdcMasterId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			INSERT INTO UdcMaster(UdcMasterId,MasterId,ColumnName,ColumnDataType,ColumnSize,ColumnPrecision,
			ColumnMandatory,Availability,LastModBy,LastModDate,AuthId,AuthDate,Editable,PickFromDefault) 
			VALUES(@UdcMasterId,@MasterId,@ColumnName,@ColumnDataType,@ColumnSize,@ColumnPrecision,@MandatoryId,
			1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),@EditId,@PickDefaultId)
			UPDATE Counters SET currvalue = @UDCMasterId WHERE TabName = 'UdcMaster' and FldName = 'UdcMasterId'
		END
		FETCH NEXT FROM Cur_UDCMaster INTO @MasterName,@ColumnName,@ColumnDataType,@ColumnSize,
		@ColumnPrecision,@Editable,@Mandatory,@PickFromDefault
	END
	CLOSE Cur_UDCMaster
	DEALLOCATE Cur_UDCMaster
	UPDATE Cn2Cs_Prk_UDCMaster SET DownLoadFlag='Y' WHERE MasterName+'~'+ColumnName IN 
	(SELECT MasterName+'~'+ColumnName FROM UDCMaster U,UDCHd H WHERE U.MasterId=H.MasterId)
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptSchemeUtilization' AND XTYPE='P')
DROP PROCEDURE Proc_RptSchemeUtilization
GO
--EXEC PROC_RptSchemeUtilization 15,2,0,'Henkel',0,0,1
CREATE PROCEDURE Proc_RptSchemeUtilization
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
*
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
	
	Create TABLE #RptSchemeUtilizationDet
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
		FreePrdName	nVarchar(200),
		FreeQty		Int,
		FreeValue	Numeric(38,6),
		GiftPrdName	nVarchar(200),
		GiftQty		Int,
		GiftValue	Numeric(38,6)
	)
	SET @TblName = 'RptSchemeUtilizationDet'
	
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
				FreeValue	Numeric(38,6),
				GiftPrdName	nVarchar(50),
				GiftQty		Int,
				GiftValue	Numeric(38,6)'
	SET @TblFields = 'SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,FreeValue,
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
		INSERT INTO #RptSchemeUtilizationDet(SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
			NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,FreeValue,
			GiftPrdName,GiftQty,GiftValue)
		SELECT DISTINCT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,Count(Distinct B.RtrId),
			Count(Distinct B.ReferNo),0 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
			dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId) as DiscountPer,
			ISNULL(SUM(Points),0) as Points,CASE ISNULL(SUM(FreeQty),0) WHEN 0 THEN '-' ELSE FreePrdName END AS FreePrdName,
			ISNULL(SUM(FreeQty),0) as FreeQty,ISNULL(SUM(FreeValue),0) as FreeValue,
			CASE ISNULL(SUM(GiftValue),0) WHEN 0 THEN '-' ELSE GiftPrdName END AS GiftPrdName,ISNULL(SUM(GiftQty),0) as FreeQty,
			ISNULL(SUM(GiftValue),0) as GiftValue
		FROM SchemeMaster A INNER JOIN RPTStoreSchemeDetails B On A.SchId= B.SchId
			AND B.Userid = @Pi_UsrId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
			(B.SMId = (CASE @fSMId WHEN 0 THEN B.SMId Else 0 END) OR
			B.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
			(B.RMId = (CASE @fRMId WHEN 0 THEN B.RMId Else 0 END) OR
			B.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
			(B.CtgLevelId = (CASE @TempCtgLevelId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
			B.CtgLevelId in (@TempCtgLevelId)) AND
--			(B.CtgLevelId = (CASE @CtgMainId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
--			B.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.CtgMainId = (CASE @CtgMainId WHEN 0 THEN B.CtgMainId Else 0 END) OR
			B.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.RtrClassId = (CASE @RtrClassId WHEN 0 THEN B.RtrClassId Else 0 END) OR
			B.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
			(B.RtrID = (CASE @fRtrId WHEN 0 THEN B.RtrID Else 0 END) OR
			B.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
			(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
			A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
			B.LineType <> 3
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,
			FreePrdName,GiftPrdName
		--SELECT * FROM #RptSchemeUtilizationDet
		
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
			B.LineType = 2
		GROUP BY B.SchId
		UPDATE #RptSchemeUtilizationDet SET NoOfRetailer = NoOfRetailer - RtrCnt,
			NoOfBills = BillCnt FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet.SchId
	
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
		GROUP BY B.SchId
		UPDATE #RptSchemeUtilizationDet SET UnselectedCnt = RtrCnt
			FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet.SchId
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptSchemeUtilizationDet ' +
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSchemeUtilizationDet'
				
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
			SET @SSQL = 'INSERT INTO #RptSchemeUtilizationDet ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSchemeUtilizationDet
	-- Till Here
	
	--SELECT * FROM #RptSchemeUtilizationDet
	UPDATE RPT SET RPT.SchCode=S.CmpSchCode FROM #RptSchemeUtilizationDet RPT INNER JOIN SchemeMaster S ON RPT.SchId=S.SchId 
	SELECT SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,DiscountPer,FlatAmount,Points,FreePrdName,FreeQty,FreeValue,
	GiftPrdName,GiftQty,GiftValue
	FROM #RptSchemeUtilizationDet
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSchemeUtilization_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilization_Excel
		SELECT SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
			NoOfBills,UnselectedCnt,DiscountPer,FlatAmount,Points,FreePrdName,FreeQty,FreeValue,
			GiftPrdName,GiftQty,GiftValue INTO RptSchemeUtilization_Excel FROM #RptSchemeUtilizationDet 
	END 
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptINPUTVATSummary' AND XTYPE='P')
DROP PROCEDURE Proc_RptINPUTVATSummary
GO
--Select Flag from RptExcelFlag WITH (NOLOCK) WHERE RptID=28
--EXEC Proc_RptINPUTVATSummary 28,1,0,'CoreStocky',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptINPUTVATSummary]
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
	DECLARE @SpmId	 	AS	INT
	DECLARE @TransNo	AS	NVARCHAR(100)
	DECLARE @EXLFlag	AS 	INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SpmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId))
	SET @TransNo =(SELECT TOP 1 SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,201,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	Create TABLE #RptINPUTVATSummary
	(
		InvId 			BIGINT,
		RefNo	  		NVARCHAR(100),		
		InvDate 		DATETIME,		
		PrdId 			INT,
		PrdDCode 		NVARCHAR(100),
		PrdName			NVARCHAR(200),
		IOTaxType 		NVARCHAR(100),
		TaxPerc 		NVARCHAR(50),
		TaxableAmount 		NUMERIC(38,6),		
		TaxFlag 		INT,
		TaxPercent 		NUMERIC(38,6),
		CmpInvNo 		NVARCHAR(100)
	)
	
	SET @TblName = 'RptINPUTVATSummary'
	SET @TblStruct = 'InvId 			BIGINT,
			RefNo	  		NVARCHAR(100),		
			InvDate 		DATETIME,		
			PrdId 			INT,
			PrdDCode 		NVARCHAR(20),
			PrdName			NVARCHAR(100),
			IOTaxType 		NVARCHAR(100),
			TaxPerc 		NVARCHAR(50),
			TaxableAmount 		NUMERIC(38,6),		
			TaxFlag 		INT,
			TaxPercent 		NUMERIC(38,6),
			CmpInvNo 		NVARCHAR(100)'
			
	SET @TblFields = 'InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,TaxableAmount,TaxFlag
	,TaxPercent,CmpInvNo'
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
		Exec Proc_IOTaxSummary  @Pi_UsrId		
		
		
		INSERT INTO #RptINPUTVATSummary (InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,
		TaxableAmount,TaxFlag,TaxPercent,CmpInvNo)
	
		Select InvId,RefNo,InvDate,T.PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,
		case IOTaxType when 'Purchase' then TaxableAmount when 'PurchaseReturn' then TaxableAmount
		end as TaxableAmount ,TaxFlag,TaxPerCent,CmpInvNo From TmpRptIOTaxSummary T,Product P,Company C,
		Supplier S where T.PrdId = P.PrdId and S.SpmId = T.SpmId and C.CmpId = T.CmpId and
		IOTaxType in ('Purchase','PurchaseReturn') and t.spmid > 0
		and ( T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND
		( T.SpmId = (CASE @SpmId WHEN 0 THEN T.SpmId ELSE 0 END) OR
		T.SpmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
	
		AND  (RefNo = (CASE @TransNo WHEN '0' THEN RefNo ELSE '' END) OR
		RefNo in (SELECT SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,201,@Pi_UsrId)))
		AND
		( INVDATE between @FromDate and @ToDate and Userid = @Pi_UsrId)
		INSERT INTO #RptINPUTVATSummary (InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,
								 TaxableAmount,TaxFlag,TaxPercent,CmpInvNo)	
		SELECT 
			InvId,RefNo,InvDate,T.PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,
			case IOTaxType 	when 'IDT IN' then TaxableAmount 
							when 'IDT OUT' then TaxableAmount End as TaxableAmount ,
			TaxFlag,TaxPerCent,CmpInvNo 
		From 
			TmpRptIOTaxSummary T,Product P,Company C,
			IDTMaster S 
		where T.PrdId = P.PrdId and S.SpmId = T.SpmId and C.CmpId = T.CmpId and
			  IOTaxType in ('IDT IN','IDT OUT') and t.spmid > 0
		and ( T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND
		( T.SpmId = (CASE @SpmId WHEN 0 THEN T.SpmId ELSE 0 END) OR
		T.SpmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
	
		AND  (RefNo = (CASE @TransNo WHEN '0' THEN RefNo ELSE '' END) OR
				RefNo in (SELECT SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,201,@Pi_UsrId)))
		AND
		( INVDATE between @FromDate and @ToDate and Userid = @Pi_UsrId) 
		
	
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptINPUTVATSummary ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ ' WHERE (T.CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN T.CmpId ELSE 0 END) OR ' +
				' T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
				+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') AND '
				+ ' WHERE (T.SpmId = (CASE ' + CAST(@SpmId AS nVarchar(10)) + ' WHEN 0 THEN T.SpmId ELSE 0 END) OR ' +
				' T.SpmId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',9,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) '
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptINPUTVATSummary'
			
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
			@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
	
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptINPUTVATSummary' +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptINPUTVATSummary
	
	INSERT INTO #RptINPUTVATSummary
	SELECT InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,
	'Total Taxable Amount',SUM(TaxableAmount),0,1000.000000,CmpInvNo
	FROM #RptINPUTVATSummary
	WHERE TaxFlag=0
	GROUP BY InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,CmpInvNo
	
	INSERT INTO #RptINPUTVATSummary
	SELECT InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,
	'Total Tax Amount',SUM(TaxableAmount),1,1000.000000,CmpInvNo
	FROM #RptINPUTVATSummary
	WHERE TaxFlag=1
	GROUP BY InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,CmpInvNo
	SELECT * FROM #RptINPUTVATSummary
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	
	IF @EXLFlag=1
	BEGIN
		--SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptINPUTVATSummary ORDER BY TaxPercent ,TaxFlag
		--EXEC Proc_RptINPUTVATSummary 28,1,0,'CoreStocky',0,0,1
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @PrdId BIGINT
		DECLARE  @InvId BIGINT
		DECLARE  @IOTaxType NVARCHAR(100)	
		DECLARE  @TaxFlag INT
		DECLARE  @TaxPercent INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptINPUTVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptINPUTVATSummary_Excel]
		DELETE FROM RptExcelHeaders Where RptId=28 AND SlNo>9
		CREATE TABLE RptINPUTVATSummary_Excel (InvId BIGINT,RefNo NVARCHAR(100),InvDate DATETIME,CmpInvNo NVARCHAR(100),PrdId BIGINT,
						PrdCode NVARCHAR(100),PrdName NVARCHAR(500),IOTaxType NVARCHAR(100),UsrId INT)
		SET @iCnt=10
		DECLARE Crosstab_Cur CURSOR FOR
			SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptINPUTVATSummary ORDER BY TaxPercent ,TaxFlag
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@TaxPercent,@TaxFlag
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptINPUTVATSummary_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@TaxPercent,@TaxFlag
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur
		--Insert table values
		DELETE FROM RptINPUTVATSummary_Excel
		--Select Column_Name sp_Columns RptINPUTVATSummary_Excel
		INSERT INTO RptINPUTVATSummary_Excel (InvId ,RefNo ,InvDate ,CmpInvNo,PrdId ,PrdCode,PrdName,IOTaxType,UsrId)
		SELECT DISTINCT InvId ,RefNo ,InvDate ,CmpInvNo,PrdId,PrdDCode,PrdName,IOTaxType,@Pi_UsrId
				FROM #RptINPUTVATSummary
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT  InvId,PrdId,IOTaxType,TaxPerc,TaxableAmount FROM #RptINPUTVATSummary
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @InvId,@PrdId,@IOTaxType,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptINPUTVATSummary_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE InvId='+ CAST(@InvId AS VARCHAR(1000)) + ' AND PrdId=' + CAST(@PrdId AS VARCHAR(1000)) + '
					AND IOTaxType=''' + CAST(@IOTaxType AS VARCHAR(1000))+''' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @InvId,@PrdId,@IOTaxType,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptINPUTVATSummary_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptINPUTVATSummary_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
	END
RETURN
END
GO
DELETE FROM RptFilter WHERE RptId=250
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (250,275,1,'Sales')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (250,275,2,'Purchase')
GO
DELETE FROM RptFilter WHERE RptId=253
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (253,275,1,'Sales')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (253,275,2,'Purchase')
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ReturnRptFiltersValue' AND XTYPE='FN')
DROP FUNCTION Fn_ReturnRptFiltersValue
GO
CREATE FUNCTION [dbo].[Fn_ReturnRptFiltersValue]
(
	@iRptid INT,
	@iSelid INT,
	@iUsrId INT
)
RETURNS nVarChar(1000)
AS
/*********************************
* FUNCTION: Fn_ReturnRptFiltersValue
* PURPOSE: Returns the Filters Value For the Selected Report and Selection Id
* NOTES: 
* CREATED: Thrinath Kola	31-07-2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
*********************************/
BEGIN
	DECLARE @iCnt 		AS	INT
	DECLARE @SCnt 		AS      NVARCHAR(1000)
	DECLARE	@ReturnValue	AS	nVarchar(1000)
	DECLARE @iRtr 		AS	INT
	SELECT @iCnt = Count(*) FROM ReportFilterDt WHERE Rptid= @iRptid AND
	SelId = @iSelid AND usrid = @iUsrId
	IF @iCnt > 1
	BEGIN
		IF @iSelid=3 AND ( @iRptid=1 OR @iRptid=2 OR @iRptid=3 OR @iRptid=4 OR @iRptid=9 OR @iRptid=17 OR @iRptid=18
		OR @iRptid=19 OR @iRptid=30 OR @iRptid=12 ) 
		BEGIN
			SELECT @iRtr=SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
			SelId = 215 AND Usrid = @iUsrId
			IF @iRtr>0 
			BEGIN
				SELECT @iRtr=COUNT(*) FROM ReportFilterDt WHERE Rptid= @iRptid AND
				SelId = @iSelid AND Usrid = @iUsrId AND SelValue  IN
				(SELECT SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
				SelId = 215 AND Usrid = @iUsrId
				)
				IF @iRtr>0  
				BEGIN
					SET @ReturnValue = 'ALL'
				END
				ELSE
				BEGIN
					SET @ReturnValue = 'Multiple'
				END 
			END
			ELSE
			BEGIN
				SET @ReturnValue = 'Multiple'
			END
		END
		
		--Praveenraj B For Parle Salesman Multiple Selection
		 Else if @iCnt>1 And @iSelid=1   
		 Begin  
		 Set @ReturnValue=''
		  Select  @ReturnValue=@ReturnValue+SMName+',' From Salesman Where SMId In (SELECT Top 4 SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND    
			SelId =1 AND Usrid = @iUsrId  )   
			SET @ReturnValue=LEFT(@ReturnValue,LEN(@ReturnValue)-1)
		 End  
		 
   --Till Here
   -->Added By Mohana For Parle Multiple Route Selection
--		Else if @iCnt>1 And @iSelid IN (2,35) AND @iRptid IN (3,242)
-->Added By Aravindh Deva C For Parle Multiple Route Selection for the reports 17,18,19
		ELSE IF @iCnt>1 And @iSelid IN (2,35) AND @iRptid IN (3,242,17,18,19)		
		 BEGIN  
		 SET @ReturnValue=''
		  SELECT  @ReturnValue=@ReturnValue+RMname+',' From RouteMaster  Where rmid In (SELECT Top 5 SelValue FROM ReportFilterDt WHERE Rptid=@iRptid AND    
			SelId IN (2,35) AND Usrid = @iUsrId  )
			SET @ReturnValue=LEFT(@ReturnValue,LEN(@ReturnValue)-1)   
		 END
	-->Till Here   
		ELSE
		BEGIN
			SET @ReturnValue = 'Multiple'
		END 
	END
	ELSE
	BEGIN
		--->Added By Nanda on 25/03/2011-->(Same Selection Id is used for Collection Report-Show Based on with Suppress Zero Stock)
		IF @iSelid=44 AND (@iRptid<>4)
		BEGIN
			SELECT @ReturnValue = ISNULL(FilterDesc,'') FROM RptFilter WHERE FilterId IN 
			( 
				SELECT SelValue FROM ReportFilterDt WHERE RptId=@iRptid AND SelId=@iSelid AND usrid = @iUsrId
			)
			AND RptId=@iRptid AND SelcId=@iSelid		
		END
		ELSE IF @iSelid=289 OR @iSelid=290 -- Moorthi For Nivea Filter (Delivered,Undelivered,Cancelled Bills)
		BEGIN
			SELECT @ReturnValue = ISNULL(FilterDesc,'') FROM RptFilter WHERE FilterId IN 
			( 
				SELECT SelValue FROM ReportFilterDt WHERE RptId=@iRptid AND SelId=@iSelid AND usrid = @iUsrId
			)
			AND RptId=@iRptid AND SelcId=@iSelid		
		END
		--->Till Here
		ELSE
		BEGIN
			If @iSelid <> 10 AND @iSelid <> 11  And @iSelid <>66 and @iSelid<>64 AND @iSelid <> 13 AND @iSelid <> 20 
			AND @iSelid <> 102 AND @iSelid <> 103 AND @iSelid <> 105  AND @iSelid <> 108 AND @iSelid <> 115 AND @iSelid <> 117 AND 
			@iSelid <> 119 AND @iSelid <> 126  AND @iSelid <> 139 AND @iSelid <> 140 AND @iSelid <> 152 AND @iSelid <> 157 AND @iSelid <> 158 AND @iSelid <> 161 
			AND @iSelid <> 163 AND @iSelid <> 165 AND @iSelid <> 171  AND @iSelid <> 173 AND @iSelid <> 174 AND @iSelid <> 180 AND @iSelid <> 181
			AND @iSelid <> 195 AND @iSelid <> 199 AND @iSelid <> 201 AND @iSelid <> 278 AND @iSelid <> 275
			BEGIN			
				SELECT @iCnt = SelValue From ReportFilterDt Where Rptid= @iRptid AND
				SelId = @iSelid AND usrid = @iUsrId			
				
				IF @iCnt = 0
				BEGIN
					IF @iSelid=53 and (@iRptid=43 Or @iRptid=44)
					BEGIN
						IF Not Exists(SELECT * FROM ReportFilterDt WHERE Rptid In(43,44) and Selid=54)
						BEGIN
							SELECT @iCnt = SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
							SelId = 55 AND usrid = @iUsrId
							SELECT @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
						END
						ELSE
						BEGIN
							SELECT @iCnt = SelValue From ReportFilterDt Where Rptid= @iRptid AND
							SelId = 54 AND usrid = @iUsrId
							SELECT @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
						END
					END
					ELSE 
					BEGIN
						SET @ReturnValue = 'ALL'
					END
				END
				ELSE
				BEGIN
					If @iSelid=232 
					BEGIN
						Select @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
					END
					ELSE
					BEGIN
						Select @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,2)
					END
			   END
			END
			ELSE
			BEGIN	
				If @iSelid=10 or @iSelid=11	or @iSelid=20 or @iSelid=13 or @iSelid=139 or @iSelid=140
				BEGIN
					SELECT @ReturnValue = Convert(nVarChar(10),FilterDate,121) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId
				End
				If  @iSelid=66 
				BEGIN
					SELECT @ReturnValue = Cast(SelValue as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End
				If  @iSelid=64
					BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=115 
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=152 
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End			
				If  @iSelid=157 or @iSelid=158
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=161
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End
				If  @iSelid=199
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				IF @iSelid=102 OR @iSelid=103 OR @iSelid=105 OR  @iSelid=108 OR @iSelid = 117 OR @iSelid = 119 OR @iSelid = 126 OR @iSelid = 159 OR @iSelid = 163  OR @iSelid = 165 OR @iSelid = 180 OR @iSelid = 181
				OR @iSelid = 173 OR @iSelid = 174 OR @iSelid=195 OR @iSelid=201 OR @iSelid = 171 OR @iSelid = 278 OR @iSelid = 275
				BEGIN
					SELECT @SCnt = NULLIF(ISNULL(SelDate,'0'),SelDate) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId
					IF @SCnt='0' 
					BEGIN
						Set @ReturnValue = 'ALL'
					END 
					ELSE
					BEGIN
						SELECT @ReturnValue = Cast(SelDate as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
						SelId = @iSelid AND usrid = @iUsrId	
					END
				END			
			END	
		END			
	END
	RETURN(@ReturnValue)
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptMonthlyVatSummary_Parle' AND XTYPE='P')
DROP PROCEDURE Proc_RptMonthlyVatSummary_Parle
GO
--Exec Proc_RptMonthlyVatSummary_Parle 253,1,0,'eeeee',0,0,0
CREATE PROCEDURE Proc_RptMonthlyVatSummary_Parle
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
* VIEW	: Proc_RptMonthlyVatSummary_Parle
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
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	--SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,278,@Pi_UsrId))
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	
	delete from RptMonthlyVatsummary
		
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_IOTaxSummary_Parle @FromDate,@ToDate,@InvoiceType
	--select * from 	Temp_IOTaxDetails_Parle
		 
		SELECT InvDate,Year(InvDate)AS JCYear,sum(GrossAmount)as GrossAmount,sum(Discount) as Discount,TaxPerc,sum(TaxableAmount) as TaxableAmount,TaxFlag,TaxPercent,TaxId,
		sum(Scheme)as Scheme,sum(Damage) as Damage,sum(AddLess) as AddLess,sum(FinalAmount) as FinalAmount,colno into #RptMonthlyVatsummary from Temp_IOTaxDetails_Parle
		GROUP BY InvDate,TaxPerc,TaxFlag,TaxPercent,TaxId,colno
		
		INSERT INTO RptMonthlyVatsummary
		select MonthId,(CAST(JCYear AS Varchar(4))+'-'+ VatMonth) AS VatMonth,JCYear,sum(GrossAmount)GrossAmount,sum(Discount)Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,TaxFlag,TaxPercent,TaxId,
		sum(Scheme)Scheme,sum(Damage),sum(AddLess)AddLess,sum(FinalAmount)FinalAmount,ColNo from (
		select DATENAME(MM,InvDate)	as VatMonth,month(InvDate)MonthId ,JCYear,GrossAmount,Discount,TaxPerc,TaxableAmount,TaxFlag,TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,ColNo
		from #RptMonthlyVatsummary
		)A
		group by VatMonth,JCyear,TaxPerc,TaxFlag,TaxPercent,TaxId,ColNo,MonthId
		order by MonthId
		--GrossAmount	
		insert into RptMonthlyVatsummary 
		select distinct MonthId,VatMonth,JCyear,GrossAmount,Discount,'Gross Amount',GrossAmount,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,1 from RptMonthlyVatsummary
		--Discount	
		insert into RptMonthlyVatsummary 
		select distinct MonthId,VatMonth,JCyear,GrossAmount,Discount,'Discount',Discount,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,2 from RptMonthlyVatsummary
		
		--Scheme	
		insert into RptMonthlyVatsummary 
		select distinct MonthId,VatMonth,JCyear,GrossAmount,Discount,'Scheme',Scheme,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,3 from RptMonthlyVatsummary
		
		--Damage	
		insert into RptMonthlyVatsummary 
		select distinct MonthId,VatMonth,JCyear,GrossAmount,Discount,'Damage',Damage,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,4 from RptMonthlyVatsummary
		
		----Other Charges	
		insert into RptMonthlyVatsummary 
		select distinct MonthId,VatMonth,JCyear,GrossAmount,Discount,'Add/less',AddLess,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,7 from RptMonthlyVatsummary
		----Final Amount
		insert into RptMonthlyVatsummary 
		select distinct MonthId,VatMonth,JCyear,GrossAmount,Discount,'Final Amount',FinalAmount,0 TaxFlag,0 TaxPercent,TaxId,Scheme,Damage,AddLess,FinalAmount,8 from RptMonthlyVatsummary
		
	END 
	
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM RptMonthlyVatsummary  
	
	--update ReportFilterDt set SelDate='Sales' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=278 and SelValue=0
	--update ReportFilterDt set SelDate='Purchase' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=278 and SelValue=1
	update ReportFilterDt set SelDate='Sales' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=275 and SelValue=1
	update ReportFilterDt set SelDate='Purchase' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=275 and SelValue=2
	
--  DECLARE  @InvId BIGINT  
--  DECLARE  @RefNo NVARCHAR(100)  
--  DECLARE  @PurRcptRefNo NVARCHAR(50)  
--  DECLARE  @TaxPerc   NVARCHAR(100)  
--  DECLARE  @TaxableAmount NUMERIC(38,6)  
--  DECLARE  @IOTaxType    NVARCHAR(100)  
--  DECLARE  @SlNo INT    
--  DECLARE  @TaxFlag      INT  
--  DECLARE  @Column VARCHAR(80)  
--  DECLARE  @C_SSQL VARCHAR(4000)  
--  DECLARE  @iCnt INT  
--  DECLARE  @TaxPercent NUMERIC(38,6)  
--  DECLARE  @Name   NVARCHAR(100)  
--  DECLARE  @RtrId INT  
--  DECLARE  @ColNo INT 
--  DECLARE  @InvDate nvarchar(100)
--IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptMonthlyVatSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
--  DROP TABLE RptMonthlyVatSummary_Excel  
--  DELETE FROM RptExcelHeaders Where RptId=244 AND SlNo>1 
--  CREATE TABLE RptMonthlyVatSummary_Excel (
--				VatMonth varchar(100),UsrId INT)  
--  SET @iCnt=2
--	DELETE FROM RptExcelHeaders WHERE RptId=241
--	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
--	VALUES(241,	1,	'VatMonth',	'Month',	0,	1)
	
-- IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'TempRptMonthlyVatSumamry1') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
--	 DROP TABLE TempRptMonthlyVatSumamry1  
--	 CREATE TABLE TempRptMonthlyVatSumamry1 (
--				TaxPerc VARCHAR(100),
--				TaxPercent NUMERIC(38,2),
--				TaxFlag INT,ColNo int)  
				
--	INSERT INTO TempRptMonthlyVatSumamry1
--	SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag,ColNo FROM RptMonthlyVatsummary 
--	SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag,ColNo INTO #TempRptSalestaxsumamry FROM RptMonthlyVatsummary  --ORDER BY ColNo,TaxFlag,TaxPercent
--  DECLARE Column_Cur CURSOR FOR  
--  SELECT  TaxPerc,TaxPercent,TaxFlag FROM #TempRptSalestaxsumamry  ORDER BY  ColNo,TaxFlag,TaxPercent DESC
--  OPEN Column_Cur  
--      FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag
--      WHILE @@FETCH_STATUS = 0  
--    BEGIN  
--     SET @C_SSQL='ALTER TABLE RptMonthlyVatSummary_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'  
--     EXEC (@C_SSQL)  
--     SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'  
--     SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))  
--     SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'  
--     EXEC (@C_SSQL)  
--    SET @iCnt=@iCnt+1
--     FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag 
--    END  
--  CLOSE Column_Cur  
--  DEALLOCATE Column_Cur  
--  --Insert table values  
--  DELETE FROM RptMonthlyVatSummary_Excel  
--  INSERT INTO RptMonthlyVatSummary_Excel(VatMonth,UsrId)  
--  SELECT DISTINCT VatMonth,@Pi_UsrId   FROM RptMonthlyVatsummary  
--  --Select * from [RptSalesVatDetails_Excel]  
--  DECLARE Values_Cur CURSOR FOR  
--  SELECT DISTINCT VatMonth,taxperc, TaxableAmount FROM RptMonthlyVatsummary  
--  OPEN Values_Cur                                      
--      FETCH NEXT FROM Values_Cur INTO @InvDate,@taxperc,@TaxableAmount
--      WHILE @@FETCH_STATUS = 0  
--    BEGIN  
--     SET @C_SSQL='UPDATE RptMonthlyVatSummary_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))  
--     SET @C_SSQL=@C_SSQL+ ' WHERE VatMonth='''+ cast(@InvDate as varchar(100))  +''''
--     EXEC (@C_SSQL)  
--     PRINT @C_SSQL  
--     FETCH NEXT FROM Values_Cur INTO @InvDate,@taxperc,@TaxableAmount  
--    END  
--  CLOSE Values_Cur  
--  DEALLOCATE Values_Cur 
	
	
	SELECT * FROM 	RptMonthlyVatsummary order by JCYear,MonthId
  RETURN 
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_IOTaxSummary_Parle' AND XTYPE='P')
DROP PROCEDURE Proc_IOTaxSummary_Parle
GO
--Exec Proc_IOTaxSummary_Parle '2011-12-01','2011-12-30',1
CREATE PROCEDURE Proc_IOTaxSummary_Parle
(  
 @FromDate datetime,
 @ToDate datetime,
 @TransType int
)  
AS  
BEGIN  
 Delete from Temp_IOTaxDetails_Parle 
 --Sales TaxableAmount
If @TransType=1
	BEGIN 
		INSERT INTO Temp_IOTaxDetails_Parle
		SELECT InvDate,sum(GrossAmount)GrossAmount,sum(Discount)Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId ,
		 sum(Scheme)as Scheme,0 as Damage,0 as AddLess,sum(FinalAmount)FinalAmount,5
		FROM (
		SELECT DISTINCT  SI.SalInvNo AS RefNo,SI.SalInvDate as InvDate,  
				P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,Sum(SIP.PrdGrossAmount) AS GrossAmount,
				sum(SplDiscAmount+PrdSplDiscAmount+PrdDBDiscAmount+PrdCDAmount)Discount,SUM(PrdSchDiscAmount)Scheme,
				'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(TaxableAmount) as TaxableAmount,  
				'Sales' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,SPT.TaxId,sum(TaxableAmount+TaxAmount) as FinalAmount
		 From SalesInvoice SI WITH (NOLOCK)  
		 INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
		 INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo  
		 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = SIP.PrdId    
		 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = SIP.PrdId AND PB.PrdBatId = SIP.PrdBatId AND PB.PrdId = P.PrdId  
		 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = SI.RtrId   
		 INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = SI.SmId   
		 INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = SI.RmId    
		 WHERE SI.DlvSts in (4,5)  and SI.SalInvDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		 Group By TaxPerc,SI.SalInvDate,P.PrdId,SI.SalInvNo,R.RtrId,PB.PrdBatId,  
		 SIP.BaseQty,SIP.PrdUnitSelRate,SPT.TaxId  
		 )A group by InvDate,TaxPerc,IOTaxType,TaxFlag,TaxPercent,TaxId
		 --Sales TaxAmount
		 INSERT INTO Temp_IOTaxDetails_Parle
		 SELECT InvDate,sum(GrossAmount)GrossAmount,sum(Discount)Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,
		 sum(Scheme) as Scheme,0 as Damage,0 as AddLess,SUM(FinalAmount),6
		 FROM (
		 SELECT DISTINCT  SI.SalInvNo AS RefNo,SI.SalInvDate as InvDate,  
				 P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,Sum(SIP.PrdGrossAmount) AS GrossAmount,  
				 sum(SplDiscAmount+PrdSplDiscAmount+PrdDBDiscAmount+PrdCDAmount)Discount,SUM(PrdSchDiscAmount)Scheme,
				 'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(SPT.TaxAmount) as TaxableAmount,  
				 'Sales' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,SPT.TaxId,sum(TaxableAmount+TaxAmount) as FinalAmount
		 From SalesInvoice SI WITH (NOLOCK)  
		 INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
		 INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo  
		 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = SIP.PrdId    
		 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = SIP.PrdId AND PB.PrdBatId = SIP.PrdBatId AND PB.PrdId = P.PrdId  
		 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = SI.RtrId    
		 INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = SI.SmId   
		 INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = SI.RmId   
		 WHERE SI.DlvSts in (4,5)  and SI.SalInvDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		 Group By TaxPerc,SI.SalInvDate,P.PrdId,SI.SalInvNo,PB.PrdBatId,SPT.TaxId  
		 )A GROUP BY InvDate,TaxPerc,IOTaxType,TaxFlag,TaxPercent,TaxId
		 
		 --SalesReturn TaxableAmount
		 INSERT INTO Temp_IOTaxDetails_Parle
		 SELECT InvDate,sum(GrossAmount)GrossAmount,SUM(Discount) as Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,
		 sum(Scheme) as Scheme,0 as Damage,0 as AddLess,SUM(FinalAmount)FinalAmount,5
		 FROM (
		 Select distinct RH.ReturnCode AS RefNo,Rh.ReturnDate as InvDate,  
		  P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,  
		  -1 * Sum(RP.PrdGrossAmt) AS GrossAmount,  
		  'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(TaxableAmt) as TaxableAmount,  
		  'SalesReturn' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId,-1*sum(TaxableAmt+TaxAmt) as FinalAmount,
		  sum(PrdSplDisAmt+PrdDBDisAmt+PrdCDDisAmt)Discount,SUM(PrdSchDisAmt)Scheme
		  From ReturnHeader RH WITH (NOLOCK)  
		  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
		  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
		  INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RP.PrdId    
		  INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RP.PrdId AND PB.PrdBatId = RP.PrdBatId AND PB.PrdId = P.PrdId  
		  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId  
		  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId   
		  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId    
		  LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		  WHERE RH.Status = 0   and ReturnDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		  Group By TaxPerc,RH.ReturnDate,C.CmpId,P.PrdId,RH.ReturnId,RH.ReturnCode,R.RtrId,PB.PrdBatId,  
		  RP.BaseQty,RP.PrdUnitSelRte,SM.SmId,RM.RmId,RPT.TaxId  
		  Having Sum(TaxableAmt) >= 0 
		 )A GROUP BY InvDate,TaxPerc,IOTaxType,TaxFlag,TaxPercent,TaxId
		 
		  --SalesReturn TaxAmount
		  INSERT INTO Temp_IOTaxDetails_Parle
		 SELECT InvDate,sum(GrossAmount)GrossAmount,SUM(Discount) as Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,
		 sum(Scheme) as Scheme,0 as Damage,0 as AddLess,SUM(FinalAmount)FinalAmount,6
		 FROM (
		  Select distinct RH.ReturnCode AS RefNo,Rh.ReturnDate as InvDate,  
		  P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,  
		  -1 * Sum(RP.PrdGrossAmt) AS GrossAmount,  
		  'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(RPT.TaxAmt) as TaxableAmount,  
		  'SalesReturn' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId,-1*sum(TaxableAmt+TaxAmt) as FinalAmount,
		   sum(PrdSplDisAmt+PrdDBDisAmt+PrdCDDisAmt)Discount,SUM(PrdSchDisAmt)Scheme
		  From ReturnHeader RH WITH (NOLOCK)  
		  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
		  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
		  INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RP.PrdId    
		  INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RP.PrdId AND PB.PrdBatId = RP.PrdBatId AND PB.PrdId = P.PrdId  
		  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId   
		  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId   
		  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId   
		  LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		  WHERE RH.Status = 0   and ReturnDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		  Group By TaxPerc,RH.ReturnDate,C.CmpId,P.PrdId,RH.ReturnId,RH.ReturnCode,R.RtrId,PB.PrdBatId,  
		  RP.BaseQty,RP.PrdUnitSelRte,SM.SmId,RM.RmId,RPT.TaxId  
		  Having Sum(RPT.TaxAmt) >= 0  
		 )A GROUP BY InvDate,TaxPerc,IOTaxType,TaxFlag,TaxPercent,TaxId
		 
		SELECT salinvdate,sum(MarketRetAmount)MarketRetAmount,sum(OtherCharges)OtherCharges into #TempOtherCharges from SalesInvoice WHERE DlvSts in(4,5)
		AND SalInvDate between  CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
		GROUP BY salinvdate
		
		update  T set Damage=MarketRetAmount,AddLess=OtherCharges from Temp_IOTaxDetails_Parle T inner join #TempOtherCharges T1 on T.InvDate=T1.salinvdate
		where IOTaxType ='Sales'
		 
	END 
	
	If @TransType=2
	BEGIN
	 --Purchase Taxable amount	
		INSERT INTO Temp_IOTaxDetails_Parle
		 SELECT InvDate,sum(GrossAmount)GrossAmount,0 as Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,
		 0 as Scheme,0 as Damage,0 as AddLess,SUM(FinalAmount)FinalAmount,5	 from 	
		 ( 
		 Select distinct PR.PurRcptRefNo AS RefNo,PR.InvDate as InvDate, P.PrdId as Prdid,PRP.PrdBatId AS PrdBatId,  
		 Sum(PRP.PrdGrossAmount) AS GrossAmount,'Taxable Amount '+Cast(Left(TaxPerc,4) as Varchar(10))+'%' as TaxPerc ,Sum(TaxableAmount) as TaxableAmount,  
		 'Purchase' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,PT.TaxId,sum(TaxableAmount+PT.TaxAmount)FinalAmount
		 From PurchaseReceipt PR WITH (NOLOCK)  --Select * from PurchaseReceipt
		 INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK) ON PR.PurRcptId = PRP.PurRcptId  
		 INNER JOIN PurchaseReceiptProductTax PT WITH (NOLOCK) ON PR.PurRcptId = PT.PurRcptId AND PRP.PrdSlNo = PT.PrdSlNo AND PRP.PurRcptId = PT.PurRcptId  
		 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId  
		 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
		 INNER jOIN Supplier S WITH (NOLOCK) ON PR.SpmId = S.SpmId  
		 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		 WHERE PR.Status = 1    and InvDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		 Group By TaxPerc,PR.InvDate,P.PrdId,PR.PurRcptId,PR.PurRcptRefNo,  
		 PRP.PrdBatId,PRP.PrdLSP,PT.TaxId  
		 Having Sum(TaxableAmount) >= 0  )A
		GROUP BY InvDate,TaxPerc,IOTaxType,TaxFlag,TaxPercent,TaxId
 --Purchase Tax amount
		INSERT INTO Temp_IOTaxDetails_Parle
 		 SELECT InvDate,sum(GrossAmount)GrossAmount,0 as Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,
		 0 as Scheme,0 as Damage,0 as AddLess,SUM(FinalAmount)FinalAmount,6	 from 	
		 ( 
		 Select distinct PR.PurRcptRefNo AS RefNo,PR.InvDate as InvDate,  
		 P.PrdId as Prdid,PRP.PrdBatId AS PrdBatId,Sum(PRP.PrdGrossAmount) AS GrossAmount,
		 'Tax Amount '+Cast(Left(TaxPerc,4) as Varchar(10))+'%' as TaxPerc ,Sum(PT.TaxAmount) as TaxableAmount,  
		 'Purchase' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,PT.TaxId ,sum(TaxableAmount+PT.TaxAmount)FinalAmount
		 From PurchaseReceipt PR WITH (NOLOCK)  
		 INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK) ON PR.PurRcptId = PRP.PurRcptId  
		 INNER JOIN PurchaseReceiptProductTax PT WITH (NOLOCK) ON PR.PurRcptId = PT.PurRcptId AND PRP.PrdSlNo = PT.PrdSlNo AND PRP.PurRcptId = PT.PurRcptId  
		 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId  
		 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
		 INNER jOIN Supplier S WITH (NOLOCK) ON PR.SpmId = S.SpmId  
		 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		 WHERE PR.Status = 1     and InvDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		 Group By TaxPerc,PR.InvDate,C.CmpId,P.PrdId,PR.PurRcptId,PR.PurRcptRefNo,PR.CmpInvNo,  
		  S.SpmId,PRP.PrdBatId,PRP.PrdLSP,PT.TaxId  
		 Having Sum(PT.TaxAmount) >= 0  )A
			GROUP BY InvDate,TaxPerc,IOTaxType,TaxFlag,TaxPercent,TaxId	 
	--PurchaseReturn Taxable amount
		INSERT INTO Temp_IOTaxDetails_Parle		 
  		 SELECT InvDate,sum(GrossAmount)GrossAmount,0 as Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,
		 0 as Scheme,0 as Damage,0 as AddLess,SUM(FinalAmount)FinalAmount,5	 from 	
		 ( 
		 Select distinct PR.PurRetRefNo AS RefNo,PR.PurRetDate as InvDate,  
			P.PrdId as Prdid,PRP.PrdBatId AS PrdBatId, -1 * Sum(PRP.PrdGrossAmount) AS GrossAmount,  
		 'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(TaxableAmount) as TaxableAmount,  
		 'PurchaseReturn' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,PT.TaxId,sum(TaxableAmount+PT.TaxAmount)FinalAmount
		 From PurchaseReturn PR WITH (NOLOCK) 
		 INNER JOIN PurchaseReturnProduct PRP WITH (NOLOCK) ON PR.PurRetId = PRP.PurRetId  
		 INNER JOIN PurchaseReturnProductTax PT WITH (NOLOCK) ON PR.PurRetId = PT.PurRetId AND PRP.PrdSlNo = PT.PrdSlNo AND PRP.PurRetId = PT.PurRetId  
		 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId  
		 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
		 INNER jOIN Supplier S WITH (NOLOCK) ON PR.SpmId = S.SpmId  
		 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		 WHERE PR.Status = 1   and PurRetDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		 Group By TaxPerc,PR.PurRetDate,C.CmpId,P.PrdId,PR.PurRetId,PR.PurRetRefNo,PR.CmpInvNo,  
		 S.SpmId,PRP.PrdBatId,PRP.RetSalBaseQty,PRP.PrdLSP,PT.TaxId  
		 Having Sum(TaxableAmount) >= 0  )A
		 GROUP BY InvDate,TaxPerc,IOTaxType,TaxFlag,TaxPercent,TaxId	 
			
 --Tax Amount for Purchase Return  
 		INSERT INTO Temp_IOTaxDetails_Parle		 
   		 SELECT InvDate,sum(GrossAmount)GrossAmount,0 as Discount,TaxPerc,sum(TaxableAmount)TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,
		 0 as Scheme,0 as Damage,0 as AddLess,SUM(FinalAmount)FinalAmount,6	 from 	
		 ( 
		 Select distinct PR.PurRetRefNo AS RefNo,PR.PurRetDate as InvDate,  
		 P.PrdId as Prdid,PRP.PrdBatId AS PrdBatId, -1 * Sum(PRP.PrdGrossAmount) AS GrossAmount,
		 'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(PT.TaxAmount) as TaxableAmount,  
		 'PurchaseReturn' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,PT.TaxId,sum(TaxableAmount+PT.TaxAmount)FinalAmount
		 From PurchaseReturn PR WITH (NOLOCK)  
		 INNER JOIN PurchaseReturnProduct PRP WITH (NOLOCK) ON PR.PurRetId = PRP.PurRetId  
		 INNER JOIN PurchaseReturnProductTax PT WITH (NOLOCK) ON PR.PurRetId = PT.PurRetId AND PRP.PrdSlNo = PT.PrdSlNo AND PRP.PurRetId = PT.PurRetId  
		 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId  
		 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
		 INNER jOIN Supplier S WITH (NOLOCK) ON PR.SpmId = S.SpmId  
		 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		 WHERE PR.Status = 1   and PurRetDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		 Group By TaxPerc,PR.PurRetDate,C.CmpId,P.PrdId,PR.PurRetId,PR.PurRetRefNo,PR.CmpInvNo,  
		 S.SpmId,PRP.PrdBatId,PRP.RetSalBaseQty,PRP.PrdLSP,PT.TaxId  
		 Having Sum(PT.TaxAmount) >= 0   )A
		GROUP BY InvDate,TaxPerc,IOTaxType,TaxFlag,TaxPercent,TaxId	 
		
		SELECT InvDate,sum(Discount)Discount,sum(OtherCharges)OtherCharges into #TempPurchaseCharges from PurchaseReceipt WHERE Status=1
		AND InvDate between  CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
		GROUP BY InvDate
		
		update  T set Discount=T1.Discount,AddLess=T1.OtherCharges from Temp_IOTaxDetails_Parle T inner join #TempPurchaseCharges T1 on T.InvDate=T1.InvDate
		where IOTaxType='Purchase' 
 END 
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptVatSummary_Parle' AND XTYPE='P')
DROP PROCEDURE Proc_RptVatSummary_Parle
GO
--Exec Proc_RptVatSummary_Parle 250,1,0,'eeeee',0,0,0
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
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	
	DELETE FROM RptVatsummary
		
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_IOTaxSummary_Parle @FromDate,@ToDate,@InvoiceType
	select 'Temp_IOTaxDetails_Parle',* from 	Temp_IOTaxDetails_Parle
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
	
	--update ReportFilterDt set SelDate='Sales' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=278 and SelValue=0
	--update ReportFilterDt set SelDate='Purchase' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=278 and SelValue=1
	update ReportFilterDt set SelDate='Sales' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=275 and SelValue=1
	update ReportFilterDt set SelDate='Purchase' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=275 and SelValue=2	
	
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
		--DELETE FROM RptExcelHeaders Where RptId=241 and slno>6
		DELETE FROM RptExcelHeaders Where RptId=250 and slno>6
		
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
		INSERT INTO RptExcelHeaders 
		SELECT 250,(select MAX(slno)+1 from RptExcelHeaders where RptId=250),'Final Amount','Final Amount',1,1
		--SELECT 241,(select MAX(slno)+1 from RptExcelHeaders where RptId=241),'Final Amount','Final Amount',1,1
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
	
	SELECT * FROM 	RptVatsummary ORDER BY InvDate
	
  RETURN 
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptSchemeUtilization_Parle')
DROP PROCEDURE Proc_RptSchemeUtilization_Parle
GO
--EXEC Proc_RptSchemeUtilization_Parle 246,2,0,'Henkel',0,0,1
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
		FreePrdName	nVarchar(200),
		FreeQty		Int,
		[BaseQty] [Int],
		BaseQtyBox	Int,
		BaseQtyPack Int,
		FreeValue	Numeric(38,6),
		GiftPrdName	nVarchar(200),
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
DELETE FROM RptGroup WHERE Pid='DailyReports' AND RptId=223
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'DailyReports',223,'SalesReturnSummary','Sales Return Summary',0
GO
DELETE FROM RptGroup WHERE Pid='DailyReports' AND RptId=9
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'DailyReports',9,'SalesReturnReport','Sales Return Report',1
GO
DELETE FROM RptGroup WHERE Pid='Other transaction Reports' AND RptId=113
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'Other transaction Reports',113,'ResellDamageGOodsReport','Resell Damage GOods Report',0
GO
DELETE FROM RptGroup WHERE Pid='Other transaction Reports' AND RptId=213
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'Other transaction Reports',213,'ModernTradeClaim','Modern Trade Claim Master Report',0
GO
DELETE FROM RptGroup WHERE Pid='RspReport' AND RptId=52
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'RspReport',52,'SalesAnalysisReport','Sales Analysis Report',1
GO
UPDATE MenuDefToAvoid SET Status=1 WHERE MenuId IN ('mStk25','mStk26','mStk27')
GO
DELETE FROM RptExcelHeaders WHERE RptId=56 
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,1,'SMId','SMId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,2,'SMName','SMName',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,3,'RMId','RMId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,4,'RMName','RMName',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,5,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,6,'RtrCode','RtrCode',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,7,'RtrName','RtrName',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,8,'NetSales','NetSales',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,9,'PercBusConDB','%Bus. Con On DB',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,10,'TotBills','TotBillsCut',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,11,'PrdCnt','PrdCnt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,12,'TotSelNetSales','TotSelNetSales',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,13,'TotSelBills','TotSelBills',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,14,'SelPrdCnt','SelPrdCnt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,15,'TotDBNetSales','TotDBNetSales',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,16,'TotDBBills','TotDBBills',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,17,'DBPrdCnt','DBPrdCnt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,18,'UsrId','UsrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (56,19,'TOTNetSales','TOTNetSales',0,1)
GO
DELETE FROM HotSearchEditorDT where FormId = 810
INSERT INTO HotSearchEditorDT VALUES
(1,810,'Batch Without MRP','MRP','MRP',1000,0,'HotSch-2-2000-180',2)
INSERT INTO HotSearchEditorDT VALUES
(2,810,'Batch Without MRP','Batch Code','PrdBatCode',1000,0,'HotSch-2-2000-181',2)               
INSERT INTO HotSearchEditorDT VALUES
(3,810,'Batch Without MRP','Purchase Rate','PurchaseRate',1000,0,'HotSch-2-2000-182',2)  
INSERT INTO HotSearchEditorDT VALUES
(4,810,'Batch Without MRP','Selling Rate','SellRate',1000,0,'HotSch-2-2000-183',2)    
GO
DELETE FROM CustomCaptions WHERE TransID = 2 AND CtrlId = 2000 AND SubCtrlId IN (180,181)     
INSERT INTO CustomCaptions VALUES
(2,2000,180,'HotSch-2-2000-180','MRP','','',1,1,1,'2009-10-30 18:15:52.303',1,'2009-10-30 18:15:52.303','MRP','','',1,1)
INSERT INTO CustomCaptions VALUES
(2,2000,181,'HotSch-2-2000-181','Batch Code','','',1,1,1,'2009-10-30 18:15:52.303',1,'2009-10-30 18:15:52.303','Batch Code','','',1,1)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE name = 'Proc_RptLoadSheetItemWiseParle' AND XType = 'P')
DROP PROCEDURE Proc_RptLoadSheetItemWiseParle
GO

--Exec Proc_RptLoadSheetItemWiseParle 251,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptLoadSheetItemWiseParle
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
/************************************************************
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012
* 02/07/2013	Jisha Mathew	PARLECS/0613/008	
* 11/11/2013	Jisha Mathew	Bug No:30616
*************************************************************/
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
	--Added by Sathishkumar Veeramani 2013/04/25
	DECLARE @Prdid AS INT
	DECLARE @PrdCode AS Varchar(50)
	DECLARE @PrdBatchCode AS Varchar(50)
	DECLARE @UOMSalId AS INT
	DECLARE @BaseQty AS INT
	DECLARE @FUOMID AS INT
	DECLARE @FCONVERSIONFACTOR AS INT
	DECLARE @StockOnHand AS INT
	DECLARE @Converted AS INT
	DECLARE @Remainder AS INT
	DECLARE @COLUOM AS VARCHAR(50)
	DECLARE @Sql AS VARCHAR(5000)
	DECLARE @SlNo AS INT
	--Till Here
	--Jisha
	DECLARE @TotConverted AS INT
	DECLARE @TotRemainder AS INT	
	DECLARE @TotalQty as INT	
	--
	
	--Filter Variable
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @UOMId	 	AS	INT
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
	DECLARE @SalId   AS     BIGINT
    DECLARE @OtherCharges AS NUMERIC(18,2)   
	--DECLARE @BillNoDisp   AS INT
	--DECLARE @DispOrderby AS INT
	--Till Here
	
	EXEC Proc_RptItemWise @Pi_RptId ,@Pi_UsrId
	
	--Assgin Value for the Filter Variable
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @UOMId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,129,@Pi_UsrId))
	SET @FromBillNo =(SELECT  MIN(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	--SET @DispOrderby=(SELECT TOP 1 iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	--Till Here
	--DECLARE @RPTBasedON AS INT
	--SET @RPTBasedON =0
	--SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	
	CREATE TABLE #RptLoadSheetItemWiseParle1
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[PrdBatId]			  INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
            [PrdCtgValMainId]	  INT, 
			[CmpPrdCtgId]		  INT,
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[PrdSchemeDisc]		  NUMERIC (38,2),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0),
			[TotalDiscount]		  NUMERIC (38,2),
			[OtherAmt]			  NUMERIC (38,2),
			[AddReduce]			  NUMERIC (38,2),
			[Damage]              NUMERIC (38,2),
			[BX]                  NUMERIC (38,0),
			[PB]                  NUMERIC (38,0),
			[JAR]				  NUMERIC (38,0),
			[PKT]                 NUMERIC (38,0),
			[CN]				  NUMERIC (38,0),
			[GB]                  NUMERIC (38,0),
			[ROL]                 NUMERIC (38,0),
			[TOR]                 NUMERIC (38,0),			
			[TotalQtyBX]          NUMERIC (38,0),
			[TotalQtyPB]          NUMERIC (38,0),
			[TotalQtyPKT]         NUMERIC (38,0),
			[TotalQtyJAR]         NUMERIC (38,0),
			[TotalQtyCN]		  NUMERIC (38,0),
			[TotalQtyGB]          NUMERIC (38,0),
			[TotalQtyROL]         NUMERIC (38,0),
			[TotalQtyTOR]         NUMERIC (38,0)			
	)
	
	--IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	--BEGIN
		IF @FromBillNo <> 0 Or @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle1([SalId],[BillNo],[PrdId],[PrdBatId],[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
				[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],
				[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR])--select * from RtrLoadSheetItemWise
	
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			 from RtrLoadSheetItemWise RI
			Left Outer Join SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
			WHERE
	RptId = @Pi_RptId and UsrId = @Pi_UsrId and
	(VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
	
	 AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
	
	 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
	
	 AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
	
	 AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
					
	 AND [SalInvDate] Between @FromDate and @ToDate
			 AND RI.SalId Between @FromBillNo and @ToBillNo
----	
-- AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR 
--			    RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))
	
	GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle1([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
					[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],
					[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR])
			
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),
			BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],
			ISNULL((SUM([TaxAmount])+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			FROM RtrLoadSheetItemWise RI --select * from RtrLoadSheetItemWise
			Left Outer Join SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
			WHERE
			RptId = @Pi_RptId and UsrId = @Pi_UsrId and
			(VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
							VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
			
			 AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
							Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
			
			 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			
			 AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
			
			 AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
			AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR
					RI.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
							
		 AND [SalInvDate] BETWEEN @FromDate AND @ToDate
		
			GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId
			ORDER BY PrdDCode
		END 	
	
		UPDATE #RptLoadSheetItemWiseParle1 SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle1)
-----Added By Sathishkumar Veeramani OtherCharges
			   ---Changed By Jisha for Bug No:30616
               --SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2
               SELECT @OtherCharges = ISNULL((SUM(B.TaxAmount)+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) 
               FROM SalesInvoice A WITH (NOLOCK),RtrLoadSheetItemWise B WITH (NOLOCK)
               LEFt OUTER JOIN SalesInvoiceProduct C WITH (NOLOCK) ON B.SalId = C.SalId 
				AND B.PrdId=C.PrdId And B.PrdBatId=C.PrdBatId
               WHERE A.SalId = B.SalId AND B.SalInvDate Between @FromDate and @ToDate AND DlvSts = 2 AND UsrID = @Pi_UsrId AND RptId = @Pi_RptId
               UPDATE #RptLoadSheetItemWiseParle1 SET AddReduce = @OtherCharges 
-------Added By Sathishkumar Veeramani Damage Goods Amount---------	
		 UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle1 R INNER JOIN
		(SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP 
		 WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B
		 ON R.SalId = B.SalId AND R.PrdId = B.PrdId 
		AND R.PrdBatId = B.PrdBatId
------Till Here--------------------		
----Added By Jisha On 02/07/2013 for PARLECS/0613/008 
SELECT 0 AS [SalId],'' AS BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
[Batch Number] AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],SUM([Billed Qty]) as [Billed Qty],SUM([Free Qty]) as [Free Qty],SUM([Return Qty]) as [Return Qty],
SUM([Replacement Qty]) AS [Replacement Qty],SUM([Total Qty]) AS [Total Qty],SUM(PrdWeight) AS PrdWeight,SUM(PrdSchemeDisc) AS PrdSchemeDisc,
SUM(GrossAmount) AS GrossAmount,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,TotalBills,SUM(TotalDiscount) AS TotalDiscount,
SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS Addreduce,SUM([Damage])AS [Damage],0 AS[BX],0 AS [PB],0 AS [JAR],0 AS [PKT],0 AS [CN],0 AS [GB],0 AS [ROL],0 AS [TOR],
0 AS TotalQtyBX,0 AS TotalQtyPB,0 AS TotalQtyPKT,0 AS TotalQtyJAR,0 AS [TotalQtyCN],0 AS [TotalQtyGB],0 AS [TotalQtyROL],0 AS [TotalQtyTOR]
INTO #RptLoadSheetItemWiseParle FROM #RptLoadSheetItemWiseParle1
GROUP BY PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],TotalBills
-----
--Added by Sathishkumar Veeramani 2013/04/25		
	DECLARE CUR_UOMQTY CURSOR 
	FOR
		SELECT P.PrdId,Rpt.[Product Code],[Batch Number],SUM([Billed Qty]) AS [Billed Qty],SUM([Total Qty]) AS [Total Qty] FROM #RptLoadSheetItemWiseParle Rpt WITH (NOLOCK)
		INNER JOIN Product P WITH (NOLOCK) ON  Rpt.PrdId=P.PrdId GROUP BY P.PrdId,Rpt.[Product Code],[Batch Number]		
	OPEN CUR_UOMQTY
	FETCH NEXT FROM CUR_UOMQTY INTO @PrdId,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty
	WHILE @@FETCH_STATUS=0
	BEGIN	
			SET	@Converted=0
			SET @Remainder=0			
			SET	@TotConverted=0
			SET @TotRemainder=0				
			DECLARE CUR_UOMGROUP CURSOR
			FOR 
			SELECT DISTINCT UOMID,CONVERSIONFACTOR FROM (
			SELECT A.UOMID,CONVERSIONFACTOR FROM UOMMASTER A WITH (NOLOCK) 
			INNER JOIN UOMGROUP B WITH (NOLOCK) ON A.UomId = B.UomId INNER JOIN PRODUCT C WITH (NOLOCK)
			ON C.UOMGROUPID=B.UOMGROUPID WHERE PRDID=@PrdId AND A.UOMCODE IN ('BX','GB','CN','PB','JAR','TOR','PKT','ROL')) UOM ORDER BY CONVERSIONFACTOR DESC 
			OPEN CUR_UOMGROUP
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			WHILE @@FETCH_STATUS=0
			BEGIN	
					SELECT @COLUOM=UOMCODE FROM UomMaster WITH (NOLOCK) WHERE UOMID=@FUOMID
					IF @BaseQty >= @FCONVERSIONFACTOR
					BEGIN
						SET	@Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)
						SET @Remainder=CAST(@BaseQty%@FCONVERSIONFACTOR AS INT)
						SET @BaseQty=@Remainder							
						
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle  SET [' + @COLUOM +']='+ CAST(ISNULL(@Converted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE 	
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [' + @COLUOM +']='+ CAST(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END
					----Added By Jisha On 02/07/2013 for PARLECS/0613/008 
					IF @TotalQty >= @FCONVERSIONFACTOR
					BEGIN						
						SET	@TotConverted=CAST(@TotalQty/@FCONVERSIONFACTOR as INT)
						SET @TotRemainder=CAST(@TotalQty%@FCONVERSIONFACTOR AS INT)
						SET @TotalQty=@TotRemainder								
	
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM + ']= '+ CAST(ISNULL(@TotConverted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE 	
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM +']='+ Cast(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END					
					--					
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			END	
			CLOSE CUR_UOMGROUP
			DEALLOCATE CUR_UOMGROUP
			SET @BaseQty=0
			SET @TotalQty=0
	FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty
	END	
	CLOSE CUR_UOMQTY
	DEALLOCATE CUR_UOMQTY
------SELECT [PrdId],[PrdBatId],[Product Code],[Product Description],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],
------[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR]
------FROM #RptLoadSheetItemWiseParle
	---Commented By Jisha on 02/07/2013 for PARLECS/0613/008
	----UPDATE A SET A.TotalQtyBX = Z.TotalBox,A.TotalQtyPB = Z.TotalPouch,A.TotalQtyPKT = Z.TotalPacks FROM #RptLoadSheetItemWiseParle A WITH (NOLOCK)
	----INNER JOIN (SELECT PrdID,PrdBatId,SUM(BX) AS TotalBox,SUM(PB)+SUM(JAR) AS TotalPouch,SUM(PKT) AS TotalPacks 
	----FROM #RptLoadSheetItemWiseParle WITH (NOLOCK)GROUP BY PrdID,PrdBatId) Z
	----ON A.PrdId = Z.PrdId AND A.PrdBatId = Z.PrdBatId
--Till Here
	--Check for Report Data
    SELECT 0 AS [SalId],'' AS BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
    0 AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],([BX]+[GB]) AS BilledQtyBox,(([PB])+([JAR]+[CN]+[TOR])) AS BilledQtyPouch,([PKT]+[ROL]) AS BilledQtyPack,
	SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBX+TotalQtyGB) AS TotalQtyBOX,SUM(TotalQtyPB+TotalQtyJAR+TotalQtyCN+TotalQtyTOR) AS TotalQtyPouch,SUM(TotalQtyPKT+TotalQtyROL) AS TotalQtyPack,
	SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM([PrdWeight]) AS [PrdWeight],
	SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) As PrdSchemeDisc,
	SUM(TaxAmount) AS TaxAmount,SUM(NETAMOUNT) as NETAMOUNT,TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],
	SUM([OtherAmt]) AS [OtherAmt],SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage] INTO #Result
	FROM #RptLoadSheetItemWiseParle GROUP BY PrdId,[Product Code],[Product Description],[MRP],TotalBills,[PrdCtgValMainId],[CmpPrdCtgId],
	[BX],[PB],[JAR],[PKT],[GB],[CN],[TOR],[ROL]
	ORDER BY [Product Description]				
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result
	SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],
	 MRP,MAX([Selling Rate]) AS [Selling Rate],
	 SUM(BilledQtyBox) AS BilledQtyBox,SUM(BilledQtyPouch) AS BilledQtyPouch,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],
	 SUM(TotalQtyBox) AS TotalQtyBox,SUM(TotalQtyPouch) AS TotalQtyPouch,SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],
	 SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],
	 SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,
	 SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage] 
	 INTO #TempLoadingSheet FROM #Result GROUP BY [SalId],BillNo,PrdId,[Product Code],[PRoduct Description],MRP,TotalBills
	 ORDER BY [Product Code]
	 SELECT * FROM #TempLoadingSheet
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
		IF EXISTS (Select [Name] From SysObjects Where [Name]='RptLoadSheetItemWiseParle_Excel' And XTYPE='U')
		Drop Table RptLoadSheetItemWiseParle_Excel
	    SELECT * INTO RptLoadSheetItemWiseParle_Excel FROM #TempLoadingSheet ORDER BY [Product Code]
	END 
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_Import_RetailerMigration')
DROP PROCEDURE Proc_Import_RetailerMigration
GO
--EXEC Proc_Import_RetailerMigration '<Root></Root>'
CREATE PROCEDURE [dbo].[Proc_Import_RetailerMigration]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_ImportConfiguration
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_RetailerMigration
* CREATED		: Nandakumar R.G
* CREATED DATE	: 24/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_RetailerMigration WHERE DownLoadFlag='Y'

	INSERT INTO Cn2Cs_Prk_RetailerMigration(DistCode,RtrId,RtrCode,CmpRtrCode,RtrName,
	RtrAddress1,RtrAddress2,RtrAddress3,RtrPINCode,RtrChannelCode,RtrGroupCode,RtrClassCode,
	KeyAccount,RelationStatus,ParentCode,RtrRegDate,Status,DownLoadFlag)
	SELECT DistCode,RtrId,RtrCode,CmpRtrCode,RtrName,
	ISNULL(RtrAddress1,''),ISNULL(RtrAddress2,''),ISNULL(RtrAddress3,''),ISNULL(RtrPINCode,''),ISNULL(RtrChannelCode,''),ISNULL(RtrGroupCode,''),
	ISNULL(RtrClassCode,''),
	ISNULL(KeyAccount,''),ISNULL(RelationStatus,''),ISNULL(ParentCode,''),ISNULL(RtrRegDate,''),ISNULL(Status,0),ISNULL(DownLoadFlag,'D')
	FROM OPENXML (@hdoc,'/Root/Console2Cs_RetailerMigration',1)
	WITH 
	(	
			[DistCode]			NVARCHAR(100), 
			[RtrId]				INT,
			[RtrCode]			NVARCHAR(100),
			[CmpRtrCode]		NVARCHAR(100),
			[RtrName]			NVARCHAR(100),
			[RtrAddress1]		NVARCHAR(100),			
			[RtrAddress2]		NVARCHAR(100),			
			[RtrAddress3]		NVARCHAR(100),			
			[RtrPINCode]		NVARCHAR(20),			
			[RtrChannelCode]	NVARCHAR(100),			
			[RtrGroupCode]		NVARCHAR(100),			
			[RtrClassCode]		NVARCHAR(100),		
			[KeyAccount]		NVARCHAR(20),
			[RelationStatus]	NVARCHAR(100),
			[ParentCode]		NVARCHAR(100),
			[RtrRegDate]		NVARCHAR(100),
			[Status]			TINYINT,
			[DownLoadFlag]		NVARCHAR(10)
	) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_Product' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_Product
GO
/*
Begin transaction
EXEC Proc_Cn2Cs_Product 0
Rollback transaction
*/
CREATE PROCEDURE Proc_Cn2Cs_Product  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
/*********************************  
* PROCEDURE  : Proc_Cn2Cs_Product  
* PURPOSE  : To validate the downloaded Products   
* CREATED BY : Nandakumar R.G  
* CREATED DATE : 03/04/2010  
* NOTE   :   
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @CmpCode nVarChar(50)  
 DECLARE @SpmCode nVarChar(50)  
 DECLARE @PrdUpc  INT    
 DECLARE @ErrStatus INT  
 TRUNCATE TABLE ETL_Prk_ProductHierarchyLevelvalue  
 TRUNCATE TABLE ETL_Prk_Product  
 DELETE FROM Cn2Cs_Prk_Product WHERE DownLoadFlag='Y'  
 
	IF NOT EXISTS (SELECT CmpCode FROM Company WHERE DefaultCompany = 1)
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Company','Company Code','DefaultCompany Not available')
		Return
	END
	IF NOT EXISTS (SELECT S.SpmCode FROM Supplier S,Company C
	WHERE C.CmpId=S.CmpId AND S.SpmDefault = 1 AND C.DefaultCompany = 1)
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Supplier','Supplier Code','DefaultSupplier Not available')
		Return
	END		
	 
 SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany = 1 
  
 SELECT @SpmCode=ISNULL(S.SpmCode,0) FROM Supplier S,Company C  
 WHERE C.CmpId=S.CmpId AND S.SpmDefault = 1 AND C.DefaultCompany = 1  
 
 --TO INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
--SELECT * FROM ETL_Prk_ProductHierarchyLevelvalue
--select * from productcategorylevel
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Category',@CmpCode,BusinessCode,BusinessName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Taste',BusinessCode,CategoryCode,CategoryName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Brand',CategoryCode,FamilyCode,FamilyName,@CmpCode
  FROM Cn2Cs_Prk_Product
 INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Pack',FamilyCode,GroupCode,GroupName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
 INSERT INTO ETL_Prk_Product  
 ([Product Distributor Code],[Product Name],[Product Short Name],[Product Company Code],  
 [Product Hierarchy Level Value Code],[Supplier Code],[Stock Cover Days],  
 [Unit Per SKU],[Tax Group Code],[Weight],[Unit Code],[UOM Group Code],  
 [Product Type],[Effective From Date],[Effective To Date],[Shelf Life],[Status],[EAN Code],[Vending])  
 SELECT DISTINCT C.PrdCCode,C.PrdName,left(C.PrdName,20) AS ProductShortName,  
 C.PrdCCode,C.GroupCode,@SpmCode,0,1,'',C.PrdWgt,ISNULL(C.ProductUnit,'Unit'),C.UOMGroupCode,  
 C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,C.ProductStatus,  
 C.[EANCode],C.Vending
 FROM Cn2Cs_Prk_Product C  
 EXEC Proc_ValidateProductHierarchyLevelValue @Po_ErrNo= @ErrStatus OUTPUT  
 IF @ErrStatus =0  
 BEGIN     
  EXEC Proc_Validate_Product @Po_ErrNo= @ErrStatus OUTPUT  
  IF @ErrStatus =0  
  BEGIN   
   UPDATE A SET DownLoadFlag='Y' FROM Product P INNER JOIN Cn2Cs_Prk_Product A ON A.PrdCCode=P.PrdCCode       
  END  
 END  
 SET @Po_ErrNo= @ErrStatus  
 RETURN  
END
GO
--Praveen Raj
DELETE FROM HotSearchEditorHd WHERE FormId=10089 AND FormName='Sales Return'
INSERT INTO HotSearchEditorHd 
SELECT 10089,'Sales Return','WithReference WithOutBill Product Selection','select',
'SELECT PrdId,PrdDCode,PrdCcode,  PrdName,PrdShrtName,0 SlNo,0 SalId FROM (Select P.PrdId,P.PrdDCode,P.PrdCcode,  
P.PrdName,P.PrdShrtName From Product P (NOLOCK) where P.PrdStatus=1  and P.PrdType <> 3   
AND P.CmpId = Case vFParam WHEN 0  then P.CmpId ELSE vFParam END  ) MainSQl Order by PrdId'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10089 AND FieldName='WithReference WithOutBill Product Selection'
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10089,'WithReference WithOutBill Product Selection','Dist Code','PrdDCode',1500,0,'HotSch-3-2000-19',3)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,10089,'WithReference WithOutBill Product Selection','Comp Code','PrdCcode',1500,0,'HotSch-3-2000-20',3)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,10089,'WithReference WithOutBill Product Selection','Name','PrdName',2500,0,'HotSch-3-2000-27',3)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,10089,'WithReference WithOutBill Product Selection','Short Name','PrdShrtName',2000,0,'HotSch-3-2000-28',3)
GO
DELETE FROM HotSearchEditorHD WHERE FormId=10090 AND FormName='Sales Return'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10090,'Sales Return','WithReference WithoutBill Batch','select','
SELECT PrdBatID,  PrdBatCode,MRP,SellRate,PriceId,  SplPriceId  FROM   
(Select A.PrdBatID,A.PrdBatCode,  B.PrdBatDetailValue as MRP,     D.PrdBatDetailValue as SellRate,A.DefaultPriceId as PriceId,  
0 as SplPriceId       from ProductBatch A (NOLOCK)  INNER JOIN ProductBatchDetails B (NOLOCK)     
ON A.PrdBatId = B.PrdBatID  AND B.DefaultPrice=1     INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId      
AND B.SlNo = C.SlNo   AND   C.MRP = 1     INNER JOIN ProductBatchDetails D (NOLOCK)     
ON A.PrdBatId = D.PrdBatID  AND D.DefaultPrice=1    
INNER JOIN BatchCreation E (NOLOCK)   ON E.BatchSeqId = A.BatchSeqId    
AND D.SlNo = E.SlNo   AND   E.SelRte = 1   WHERE A.PrdId=vFParam)   MainSql'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10090 AND FieldName='WithReference WithoutBill Batch'
INSERT INTO HotSearchEditorDt
SELECT 1,10090,'WithReference WithoutBill Batch','Batch No','PrdBatCode',1500,0,'HotSch-3-2000-18',3
UNION
SELECT 1,10090,'WithReference WithoutBill Batch','MRP','MRP',1500,0,'HotSch-3-2000-32',3
UNION
SELECT 1,10090,'WithReference WithoutBill Batch','Selling Rate','SellRate',1500,0,'HotSch-3-2000-34',3
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10091 AND FormName='Sales Return'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10091,'Sales Return','Bill No','select',
'SELECT DISTINCT SalId,SalInvNo,LcnId,SalInvDate,RtrId,RtrName,BillSeqId,SalRoundOff,SalRoundOffAmt,0 AS ReturnSalId 
FROM   (SELECT DISTINCT A.SalId,A.SalinvNo,A.LcnId,A.SalInvDate,B.RtrId,B.RtrName,A.BillSeqId,A.SalRoundOff,A.SalRoundOffAmt 
FROM SalesInvoice A (NOLOCK)   INNER JOIN Retailer B (NOLOCK) ON A.RtrId = B.RtrId INNER JOIN SalesInvoiceProduct C (NOLOCK) 
ON A.SalId=C.SalId   WHERE A.RtrId =''vFParam'' AND A.RMId=''vSParam'' AND A.SMId=''vTParam'' 
AND CAST(C.PrdId AS VARCHAR(10))+''~''+CAST(C.PrdBatId AS VARCHAR(10)) IN (''vFOParam'') AND
A.DlvSts in (4,5) AND (C.BaseQty-C.ReturnedQty)>0 AND A.SalId NOT IN 
(SELECT SalId FROM PercentageWiseSchemeFreeProducts WITH (NOLOCK))  ) MainSql'
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 677
INSERT INTO HotSearchEditorHd
SELECT 677,'Order Booking','Product without Company','select','SELECT PrdId,PrdDcode,PrdCcode,PrdName,PrdShrtName,UomGroupId,PrdSeqDtId 
FROM (SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,c.PrdSeqDtId FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),
ProductSeqDetails C WITH (NOLOCK),ProductBatch D WHERE B.TransactionId=vFParam AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId 
AND A.PrdId=D.PrdId AND A.PrdType IN (1,2,5,6) UNION  SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,  
100000 AS PrdSeqDtId FROM  Product A WITH (NOLOCK) INNER JOIN ProductBatch D ON A.PrdId=D.PrdId AND D.Status=1 WHERE PrdStatus = 1 AND 
A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=vFParam AND B.PrdSeqId=C.PrdSeqId)
AND A.PrdType IN (1,2,5,6) ) a ORDER BY PrdSeqDtId'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10091 AND FielDName='Bill No'
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10091,'Bill No','Bill No','SalInvNo',4500,0,'HotSch-23-2000-1',23
GO
DELETE FROM Configuration WHERE ModuleId='DISTAXCOLL6' AND ModuleName='Discount & Tax Collection'
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'DISTAXCOLL6','Discount & Tax Collection','Automatically perform Vehicle allocation while saving the bill',0,'',0,6
GO
DELETE FROM ProfileDt WHERE MenuId='mLog5'
INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT PrfId,'mLog5',0,'New',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION ALL
SELECT PrfId,'mLog5',1,'Edit',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION ALL
SELECT PrfId,'mLog5',2,'Save',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION ALL
SELECT PrfId,'mLog5',3,'Delete',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION ALL
SELECT PrfId,'mLog5',4,'Cancel',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION ALL
SELECT PrfId,'mLog5',5,'Exit',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
GO
DELETE FROM CustomCaptions WHERE TransId=28 AND CtrlId=1000 AND SubCtrlId=3
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
							DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 28,1000,3,'Msgbox-28-1000-3','','','Invoice Already Delivered,Invoice No :',1,1,1,GETDATE(),1,GETDATE(),'','','Invoice Already Delivered,Invoice No :',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=28 AND CtrlId=1000 AND SubCtrlId IN (18,19)
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
							DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 28,1000,18,'Msgbox-28-1000-18','','','Please allocate bills and proceed',1,1,1,GETDATE(),1,GETDATE(),'','','Please allocate bills and proceed',1,1
UNION ALL
SELECT 28,1000,19,'PnlMsg-28-1000-19','','Delivered bills not allowed to delete','',1,1,1,GETDATE(),1,GETDATE(),'','Delivered bills not allowed to delete','',1,1
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('FN','TF') AND name='Fn_ReturnReturnProdDetails')
DROP FUNCTION Fn_ReturnReturnProdDetails
GO
--SELECT * FROM Fn_ReturnReturnProdDetails(8172,585,2)
CREATE FUNCTION Fn_ReturnReturnProdDetails (@Pi_SalId BIGINT,@Pi_PrdId BIGINT,@Pi_SlNo INT)
RETURNS @ReturnDetails TABLE 
(
PrdBatId				BIGINT,
PrdbatCode				VARCHAR(50),
StockType				VARCHAR(50),
BaseQty					BIGINT,
PreRtnQty				BIGINT,
PrdUnitMRP				NUMERIC (18,6),
PrdUnitSelRate			NUMERIC (18,6),
PrdUom1EditedSelRate	NUMERIC (18,6),    
PrdGrossAmount			NUMERIC (18,6), 
PrdGrossAmountAftEdit	NUMERIC (18,6),
PrdNetRateDiffAmount	NUMERIC (18,6),
PriceId					BIGINT,
SplPriceId				BIGINT
)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnReturnProdDetails
* PURPOSE: Returns the Product Details
* NOTES:
* CREATED: Praveenraj B	21-11-2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	INSERT INTO @ReturnDetails(PrdBatId,PrdbatCode,StockType,BaseQty,PreRtnQty,PrdUnitMRP,PrdUnitSelRate,PrdUom1EditedSelRate,    
							   PrdGrossAmount,  PrdGrossAmountAftEdit,PrdNetRateDiffAmount,PriceId,SplPriceId)
	SELECT PrdBatId,PrdbatCode,StockType,BaseQty,PreRtnQty,PrdUnitMRP,PrdUnitSelRate,PrdUom1EditedSelRate,    
	PrdGrossAmount,  PrdGrossAmountAftEdit,PrdNetRateDiffAmount,PriceId,SplPriceId FROM
	(SELECT DISTINCT P.PrdBatId,  P.PrdbatCode,'Saleable' AS StockType,(S.BaseQty - ISNULL(S.ReturnedQty,0)) AS BaseQty, ISNULL(S.ReturnedQty,0) AS  
	PreRtnQty,S.PrdUnitMRP,S.PrdUnitSelRate,CAST(S.PrdUom1EditedSelRate/Uom1ConvFact AS NUMERIC(18,6))  as PrdUom1EditedSelRate,      
	S.PrdGrossAmount,  S.PrdGrossAmountAftEdit,(S.PrdRateDiffAmount/S.BaseQty)  AS PrdNetRateDiffAmount,     
	S.PriceId,S.SplPriceId  
	FROM ProductBatch P (NOLOCK),SalesInvoiceProduct S  (NOLOCK) WHERE P.Status=1  
	AND P.PrdBatId =S.PrdBatId   AND  (S.BaseQty - ISNULL(S.ReturnedQty,0)) >0 AND S.SalId = ISNULL(@Pi_SalId,0) AND S.PrdId=ISNULL(@Pi_PrdId,0)  And S.Slno = ISNULL(@Pi_SlNo,0)    
	UNION ALL      
	SELECT DISTINCT P.PrdBatId, P.PrdbatCode,'Offer' AS  StockType,(S.SalManFreeQty - ISNULL(S.ReturnedManFreeQty,0))  AS BaseQty,      
	ISNULL(S.ReturnedManFreeQty,0) as PreRtnQty,S.PrdUnitMRP,S.PrdUnitSelRate,
	CAST(S.PrdUom1EditedSelRate/Uom1ConvFact AS NUMERIC(18,6)) AS PrdUom1EditedSelRate,      
	S.PrdGrossAmount,S.PrdGrossAmountAftEdit,S.PrdRateDiffAmount AS PrdNetRateDiffAmount,      S.PriceId,0  AS SplPriceId  
	FROM ProductBatch P (NOLOCK),SalesInvoiceProduct S (NOLOCK)      WHERE P.Status=1 and  P.PrdBatId =S.PrdBatId And  
	S.SalId = ISNULL(@Pi_SalId,0) and  S.PrdId=ISNULL(@Pi_PrdId,0)      and  S.SalManFreeQty > 0  And S.Slno = ISNULL(@Pi_SlNo,0)
	) M
RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('FN','TF') AND name='Fn_PrdCategory')
DROP FUNCTION Fn_PrdCategory
GO
CREATE FUNCTION Fn_PrdCategory(@Pi_CmpId INT)
RETURNS @PrdCtg TABLE
(
CmpPrdCtgId int,
CmpPrdCtgName nvarchar(100),
PrdCtgValMainId int,
PrdCtgValName nvarchar(100)
)
AS
BEGIN
/*********************************
* FUNCTION: Fn_PrdCategory
* PURPOSE: Returns Product Category Id and Name
* NOTES: 
* CREATED: Aravindh Deva C	12.01.2013
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
*********************************/
INSERT INTO @PrdCtg
SELECT CmpPrdCtgId,CmpPrdCtgName,0,'ALL' FROM ProductCategoryLevel WHERE CmpPrdCtgName='Category' AND CmpId=@Pi_CmpId
RETURN
END
--Till here
GO
--Sathishkumar Veeramani
--PARLE Purchase Supplier Credit Note & Debit Note Downloaded,Purchase Receipt Include Credit Note & Debit Note
IF NOT EXISTS (SELECT * FROM Syscolumns A WITH(NOLOCK),Sysobjects B WITH(NOLOCK) WHERE A.id = B.id AND B.XTYPE = 'U' 
AND B.name = 'ETLTempPurchaseReceiptCrDbAdjustments' AND A.name = 'DownloadStatus')
BEGIN
   ALTER TABLE ETLTempPurchaseReceiptCrDbAdjustments ADD DownloadStatus INT DEFAULT 0 WITH VALUES
END
GO
DELETE FROM Tbl_DownloadIntegration WHERE SequenceNo IN (47,48)
INSERT INTO Tbl_DownloadIntegration
SELECT 47,'SupplierCreditNote','ETL_Prk_CreditNoteSupplier','Proc_ImportCreditNoteSupplier',0,500,CONVERT(NVARCHAR(10),GETDATE(),121) UNION
SELECT 48,'SupplierDebitNote','ETL_Prk_DebitNoteSupplier','Proc_ImportDebitNoteSupplier',0,500,CONVERT(NVARCHAR(10),GETDATE(),121)
GO
DELETE FROM CustomUpDownload WHERE UpDownload = 'Download'
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (201,1,'Hierarchy Level','Hieararchy Level','Proc_Cs2Cn_HierarchyLevel','Proc_Import_HierarchyLevel','Cn2Cs_Prk_HierarchyLevel','Proc_Cn2Cs_HierarchyLevel','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (202,1,'Hierarchy Level Value','Hieararchy Level Value','Proc_Cs2Cn_HierarchyLevelValue','Proc_Import_HierarchyLevelValue','Cn2Cs_Prk_HierarchyLevelValue','Proc_Cn2Cs_HierarchyLevelValue','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (203,1,'Retailer Category Level Value','Retailer Category Level Value','Proc_CS2CNBLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_Cn2Cs_BLRetailerCategoryLevelValue','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (204,1,'Retailer Value Classification','Retailer Value Classification','Proc_CS2CNBLRetailerValueClass','Proc_ImportBLRetailerValueClass','Cn2Cs_Prk_BLRetailerValueClass','Proc_Cn2Cs_BLRetailerValueClass','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (205,1,'Prefix Master','Prefix Master','Proc_Cs2Cn_PrefixMaster','Proc_Import_PrefixMaster','Cn2Cs_Prk_PrefixMaster','Proc_Cn2Cs_PrefixMaster','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (206,1,'Retailer Aproval','Retailer Approval','Proc_Cs2Cn_RetailerApproval','Proc_Import_RetailerApproval','Cn2Cs_Prk_RetailerApproval','Proc_Cn2Cs_RetailerApproval','Master','Download',0)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (207,1,'UOM','UOM','Proc_Cn2Cs_BLUOM','Proc_ImportBLUOM','Cn2Cs_Prk_BLUOM','Proc_Cn2Cs_BLUOM','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (208,1,'Tax Configuration','Tax Configuration','Proc_ValidateTaxConfig_Group','Proc_ImportTaxMaster','Etl_Prk_TaxConfig_GroupSetting','Proc_ValidateTaxConfig_Group','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (209,1,'Tax Setting','Tax Setting','Proc_CN2CS_TaxSetting','Proc_ImportTaxConfigGroupSetting','Etl_Prk_TaxSetting','Proc_CN2CS_TaxSetting','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (210,1,'Product Hierarchy Change','Product Hierarchy Change','Proc_CS2CNBLProductHierarchyChange','Proc_ImportBLProductHiereachyChange','Cn2Cs_Prk_BLProductHiereachyChange','Proc_Cn2Cs_BLProductHiereachyChange','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (211,1,'Product','Product','Proc_Cs2Cn_Product','Proc_Import_Product','Cn2Cs_Prk_Product','Proc_Cn2Cs_Product','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (212,1,'Product Batch','Product Batch','Proc_Cs2Cn_ProductBatch','Proc_Import_ProductBatch','Cn2Cs_Prk_ProductBatch','Proc_Cn2Cs_ProductBatch','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (213,1,'Tax Group Mapping','Tax Group Mapping','Proc_ValidateTaxMapping','Proc_ImportTaxGrpMapping','Etl_Prk_TaxMapping','Proc_ValidateTaxMapping','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (214,1,'Special Rate','Special Rate','Proc_Cs2Cn_SpecialRate','Proc_Import_SpecialRate','Cn2Cs_Prk_SpecialRate','Proc_Cn2Cs_SpecialRate','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (215,1,'Cluster Master','Cluster Master','Proc_Cs2Cn_ClusterMaster','Proc_Import_ClusterMaster','Cn2Cs_Prk_ClusterMaster','Proc_Cn2Cs_ClusterMaster','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (216,1,'Cluster Group','Cluster Group','Proc_Cs2Cn_ClusterGroup','Proc_Import_ClusterGroup','Cn2Cs_Prk_ClusterGroup','Proc_Cn2Cs_ClusterGroup','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,1,'Scheme','Scheme Master','Proc_CS2CNBLSchemeMaster','Proc_ImportBLSchemeMaster','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeMaster','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,2,'Scheme','Scheme Attributes','Proc_CS2CNBLSchemeAttributes','Proc_ImportBLSchemeAttributes','Etl_Prk_Scheme_OnAttributes','Proc_CN2CS_BLSchemeAttributes','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,3,'Scheme','Scheme Products','Proc_CS2CNBLSchemeProducts','Proc_ImportBLSchemeProducts','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeProducts','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,4,'Scheme','Scheme Slabs','Proc_CS2CNBLSchemeSlab','Proc_ImportBLSchemeSlab','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeSlab','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,5,'Scheme','Scheme Rule Setting','Proc_CS2CNBLSchemeRulesetting','Proc_ImportBLSchemeRulesetting','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeRulesetting','Transaction','Download',0)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,6,'Scheme','Scheme Free Products','Proc_CS2CNBLSchemeFreeProducts','Proc_ImportBLSchemeFreeProducts','Etl_Prk_Scheme_Free_Multi_Products','Proc_CN2CS_BLSchemeFreeProducts','Transaction','Download',0)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,7,'Scheme','Scheme Combi Products','Proc_CS2CNBLSchemeCombiPrd','Proc_ImportBLSchemeCombiPrd','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeCombiPrd','Transaction','Download',0)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,8,'Scheme','Scheme On Another Product','Proc_CS2CNBLSchemeOnAnotherPrd','Proc_ImportBLSchemeOnAnotherPrd','Etl_Prk_Scheme_OnAnotherPrd','Proc_CN2CS_BLSchemeOnAnotherPrd','Transaction','Download',0)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (218,1,'Scheme Master Control','Scheme Master Control','Proc_CS2CNNVSchemeMasterControl','Proc_ImportNVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','Proc_Cn2Cs_NVSchemeMasterControl','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (219,1,'Claim Settlement','Claim Settlement','Proc_Cs2Cn_ClaimSettlementDetails','Proc_Import_ClaimSettlementDetails','Cn2Cs_Prk_ClaimSettlementDetails','Proc_Cn2Cs_ClaimSettlementDetails','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (220,1,'SupplierCreditNote','SupplierCreditNote','Proc_ValidateCreditNoteSupplier','Proc_ImportCreditNoteSupplier','ETL_Prk_CreditNoteSupplier','Proc_ValidateCreditNoteSupplier','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (221,1,'SupplierDebitNote','SupplierDebitNote','Proc_ValidateDebitNoteSupplier','Proc_ImportDebitNoteSupplier','ETL_Prk_DebitNoteSupplier','Proc_ValidateDebitNoteSupplier','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (222,1,'Purchase Receipt','Purchase Receipt','Proc_Cs2Cn_PurchaseReceipt','Proc_ImportBLPurchaseReceipt','Cn2Cs_Prk_BLPurchaseReceipt','Proc_Cn2Cs_PurchaseReceipt','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (223,1,'Purchase Receipt Mapping','Purchase Receipt Mapping','Proc_Cs2Cn_PurchaseReceiptMapping','Proc_Import_PurchaseReceiptMapping','Cn2Cs_Prk_PurchaseReceiptMapping','Proc_Cn2Cs_PurchaseReceiptMapping','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (224,1,'Claim Norm Mapping','Claim Norm Mapping','Proc_Cs2Cn_ClaimNorm','Proc_Import_ClaimNorm','Cn2Cs_Prk_ClaimNorm','Proc_Cn2Cs_ClaimNorm','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (225,1,'Reason Master','Reason Master','Proc_Cs2Cn_ReasonMaster','Proc_Import_ReasonMaster','Cn2Cs_Prk_ReasonMaster','Proc_Cn2Cs_ReasonMaster','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (226,1,'Bulletin Board','BulletingBoard','Proc_Cs2Cn_BulletinBoard','Proc_Import_BulletinBoard','Cn2Cs_Prk_BulletinBoard','Proc_Cn2Cs_BulletinBoard','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (227,1,'ERP Product Mapping','ERP Product Mapping','Proc_Cs2Cn_ERPPrdCCodeMapping','Proc_Import_ERPPrdCCodeMapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Proc_Cn2Cs_ERPPrdCCodeMapping','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (228,1,'Configuration','Configuration','Proc_Cs2Cn_Configuration','Proc_Import_Configuration','Cn2Cs_Prk_Configuration','Proc_Cn2Cs_Configuration','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (229,1,'Cluster Assign Approval','Cluster Assign Approval','Proc_Cs2Cn_ClusterAssignApproval','Proc_Import_ClusterAssignApproval','Cn2Cs_Prk_ClusterAssignApproval','Proc_Cn2Cs_ClusterAssignApproval','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (230,1,'Supplier Master','Supplier Master','Proc_Cs2Cn_SupplierMaster','Proc_Import_SupplierMaster','Cn2Cs_Prk_SupplierMaster','Proc_Cn2Cs_SupplierMaster','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (231,1,'UDC Master','UDC Master','Proc_Cs2Cn_UDCMaster','Proc_Import_UDCMaster','Cn2Cs_Prk_UDCMaster','Proc_Cn2Cs_UDCMaster','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (232,1,'UDC Details','UDC Details','Proc_Cs2Cn_UDCDetailss','Proc_Import_UDCDetails','Cn2Cs_Prk_UDCDetails','Proc_Cn2Cs_UDCDetails','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (233,1,'UDC Defaults','UDC Defaults','Proc_Cs2Cn_UDCDefaults','Proc_Import_UDCDefaults','Cn2Cs_Prk_UDCDefaults','Proc_Cn2Cs_UDCDefaults','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (234,1,'Retailer Migration','Retailer Migration','Proc_Cs2Cn_RetailerMigration','Proc_Import_RetailerMigration','Cn2Cs_Prk_RetailerMigration','Proc_Cn2Cs_RetailerMigration','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (235,1,'Point Redemption Rules','Point Redemption Rules','Proc_Cs2Cn_PointsRulesSetting','Proc_Import_PointsRulesSetting','Cn2Cs_Prk_PointsRulesHeader','Proc_Cn2Cs_PointsRulesSetting','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (236,1,'Village Master','Village Master','Proc_Cs2Cn_VillageMaster','Proc_Import_VillageMaster','Cn2Cs_Prk_VillageMaster','Proc_Cn2Cs_Dummy','Master','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (237,1,'Scheme Payout','Scheme Payout','Proc_Cs2Cn_SchemePayout','Proc_Import_SchemePayout','Cn2Cs_Prk_SchemePayout','Proc_Cn2Cs_SchemePayout','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (238,1,'ReUpload','ReUpload','Proc_Cs2Cn_ReUpload','Proc_Import_ReUpload','Cn2Cs_Prk_ReUpload','Proc_Cn2Cs_ReUpload','Transaction','Download',1)
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (239,1,'KitItem','KitItem','Proc_Cn2Cs_KitProduct','Proc_ImportKitProduct','Cn2Cs_Prk_KitProducts','Proc_Cn2Cs_KitProduct','Master','Download',1)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name ='ETL_Prk_CreditNoteSupplier')
DROP TABLE ETL_Prk_CreditNoteSupplier
GO
CREATE TABLE ETL_Prk_CreditNoteSupplier(
    [DistCode] [Nvarchar](20) NULL,
    [CreditRefNumber] [nvarchar](100) NULL,
	[CreditDate] [nvarchar](100) NULL,
	[SupplierCode] [nvarchar](100) NULL,
	[CreditAccount] [nvarchar](100) NULL,
	[ReasonCode] [nvarchar](100) NULL,
	[CreditAmount] [nvarchar](100) NULL,
	[Status] [nvarchar](100) NULL,
	[DownloadFlag] [nvarchar](2) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name ='Proc_ImportCreditNoteSupplier')
DROP PROCEDURE Proc_ImportCreditNoteSupplier
GO
CREATE PROCEDURE Proc_ImportCreditNoteSupplier
(
	@Pi_Records TEXT 
)
AS
/*********************************
* PROCEDURE	: Proc_ImportCreditNoteSupplier
* PURPOSE	: To Insert and Update records  from xml file in the Table CreditNoteSupplier 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
BEGIN

	DECLARE @hDoc INTEGER
	TRUNCATE TABLE ETL_Prk_CreditNoteSupplier
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO ETL_Prk_CreditNoteSupplier (DistCode,CreditRefNumber,CreditDate,SupplierCode,CreditAccount,ReasonCode,CreditAmount,Status,DownloadFlag)
			SELECT DistCode,CreditRefNumber,CreditDate,SupplierCode,CreditAccount,ReasonCode,CreditAmount,Status,DownloadFlag
			FROM 	OPENXML (@hdoc,'/Root/Console2CS_CreditNoteSupplier',1)                              
			WITH 
			( 	
			    [DistCode]        NVARCHAR(20),
			    [CreditRefNumber] NVARCHAR(100), 		     
			    [CreditDate]      NVARCHAR(100),
				[SupplierCode]	  NVARCHAR(100),
				[CreditAccount]   NVARCHAR(100),
				[ReasonCode]      NVARCHAR(100),
				[CreditAmount]	  NVARCHAR(100),
				[Status]          NVARCHAR(100),
				[DownloadFlag]    NVARCHAR(2)         
			) XMLObj

EXECUTE sp_xml_removedocument @hDoc
SELECT * FROM ETL_Prk_CreditNoteSupplier
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name ='Proc_ValidateCreditNoteSupplier')
DROP PROCEDURE Proc_ValidateCreditNoteSupplier
GO
/*
BEGIN TRANSACTION
EXEC Proc_ValidateCreditNoteSupplier 0 
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_ValidateCreditNoteSupplier
(

	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateCreditNoteSupplier
* PURPOSE	: To Insert and Update records  from xml file in the Table CreditNoteSupplier 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo = 0
DECLARE @CreditRefNo AS NVARCHAR(50)
DECLARE @CreditDate AS NVARCHAR(12)
DECLARE @SupplierCode AS NVARCHAR(100)
DECLARE @CreditAccount AS NVARCHAR(100)
DECLARE @ReasonCode AS NVARCHAR(100)
DECLARE @CreditAmount AS NVARCHAR(100)
DECLARE @Status AS NVARCHAR(100)
DECLARE @CrNoteNumber AS NVARCHAR(50)
DECLARE @SpmId AS INT
DECLARE @CoaId AS INT
DECLARE @ReasonId AS INT
DECLARE @Taction AS INT
DECLARE @Tabname AS NVARCHAR(100)
DECLARE @CntTabname AS NVARCHAR(100)
DECLARE @Fldname AS NVARCHAR(100)
DECLARE @ErrDesc AS NVARCHAR(1000)
DECLARE @sSql AS NVARCHAR(4000)
DECLARE @ErrStatus		INT
DELETE FROM ETL_Prk_CreditNoteSupplier WHERE DownloadFlag = 'Y'
	SET @CntTabname='CreditNoteSupplier'
	SET @Fldname='CrNoteNumber'
	SET @Tabname = 'ETL_Prk_CreditNoteSupplier'
	SET @Taction=1
	DECLARE Cur_CreditNoteSupplier CURSOR 
	FOR SELECT DISTINCT ISNULL([CreditRefNumber],''),ISNULL([CreditDate],GETDATE()),ISNULL([SupplierCode],''),ISNULL([CreditAccount],''),
    	ISNULL([ReasonCode],''),ISNULL([CreditAmount],'0'),ISNULL(Status,'')
	FROM ETL_Prk_CreditNoteSupplier
	
	OPEN Cur_CreditNoteSupplier
	FETCH NEXT FROM Cur_CreditNoteSupplier INTO @CreditRefNo,@CreditDate,@SupplierCode,@CreditAccount,@ReasonCode,@CreditAmount,@Status
	WHILE @@FETCH_STATUS=0
		
		BEGIN
			
	        IF EXISTS (SELECT DISTINCT [CreditRefNumber] FROM ETL_Prk_CreditNoteSupplier A WITH(NOLOCK),CreditNoteSupplier B WITH(NOLOCK)
	                   WHERE A.[CreditRefNumber] = @CreditRefNo AND A.[CreditRefNumber] = B.PostedRefNo AND ([CreditRefNumber] <> '' OR [CreditRefNumber] IS NOT NULL))
	        BEGIN
	             	SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Credit RefNumber:  ' + @CreditRefNo + ' Already available in CreditNote Supplier' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'CreditRefNumber',@ErrDesc)
	        END
	        IF EXISTS (SELECT DISTINCT [CreditRefNumber] FROM ETL_Prk_CreditNoteSupplier WITH(NOLOCK) WHERE [CreditRefNumber] = @CreditRefNo AND 
	                   ([CreditRefNumber] = '' OR [CreditRefNumber] IS NULL))
	        BEGIN
	             	SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Credit RefNumber:  ' + @CreditRefNo + ' Should not be Empty' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'CreditRefNumber',@ErrDesc)
	        END            
	          
			IF NOT EXISTS  (SELECT * FROM Supplier WHERE SpmCode = @SupplierCode )    
		  		BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Supplier Code:  ' + @SupplierCode + ' is not available' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'SupplierCode',@ErrDesc)
				END
			
			SELECT @SpmId =SpmId FROM  Supplier WHERE SpmCode = @SupplierCode

			IF NOT EXISTS  (SELECT * FROM CoaMaster WHERE AcName = @CreditAccount )    
		  		BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Credit Account:  ' + @CreditAccount + ' is not available' 		 
					INSERT INTO Errorlog VALUES (2,@Tabname,'CreditAccount',@ErrDesc)
				END
			
			SELECT @CoaId =CoaId FROM  CoaMaster WHERE AcName = @CreditAccount

			IF NOT EXISTS  (SELECT * FROM ReasonMaster WHERE ReasonCode = @ReasonCode )    
		  		BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Reason Code:  ' + @ReasonCode + ' is not available' 	 
					INSERT INTO Errorlog VALUES (3,@Tabname,'ReasonCode',@ErrDesc)
				END
			
			SELECT @ReasonId =ReasonId FROM  ReasonMaster WHERE ReasonCode = @ReasonCode
			

			IF ISDATE(CONVERT(NVARCHAR(12),REPLACE(REPLACE(@CreditDate,'T','  '),'oc ','oct'),121))=0
				BEGIN
					SET @Po_ErrNo=1	
					SET @Taction=0
					SET @ErrDesc = 'Credit Date not in Date format'		 
					INSERT INTO Errorlog VALUES (4,@Tabname,'CreditDate',@ErrDesc)
				END	
			IF DATEDIFF(dd,CONVERT(NVARCHAR(12),REPLACE(REPLACE(@CreditDate,'T','  '),'oc ','oct'),121),CONVERT(NVARCHAR(10),GETDATE(),121))<0
				BEGIN
					SET @Po_ErrNo=1	
					SET @Taction=0
					SET @ErrDesc = 'Credit Date Sholud not be greater than Current date'		 
					INSERT INTO Errorlog VALUES (5,@Tabname,'CreditDate',@ErrDesc)
				END	
			
			IF ISNUMERIC(@CreditAmount)=0
				BEGIN
					SET @Po_ErrNo=1	
					SET @Taction=0
					SET @ErrDesc = 'Credit Amount should not be empty'		 
					INSERT INTO Errorlog VALUES (6,@Tabname,'CreditAmount',@ErrDesc)
	
				END	
			ELSE
				BEGIN
					IF CAST(@CreditAmount AS NUMERIC(18,2))<=0
						BEGIN
							SET @Po_ErrNo=1	
							SET @Taction=0
							SET @ErrDesc = 'Credit Amount should be greater than zero'		 
							INSERT INTO Errorlog VALUES (7,@Tabname,'CreditAmount',@ErrDesc)
						END
				END
									
			IF LTRIM(RTRIM(@Status))='' 
				BEGIN
					SET @Po_ErrNo=0
					SET @Taction=0
					SET @ErrDesc = 'Status should not be empty'		 
					INSERT INTO Errorlog VALUES (8,@Tabname,'Status',@ErrDesc)
				END
			ELSE
				BEGIN
					IF LTRIM(RTRIM(@Status))='Active' OR LTRIM(RTRIM(@Status))='InActive'
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
							INSERT INTO Errorlog VALUES (9,@Tabname,'Status',@ErrDesc)
						END
				END
				SELECT @CrNoteNumber=dbo.Fn_GetPrimaryKeyString(@CntTabname,@FldName,CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			IF @CrNoteNumber=''
				BEGIN
					SET @Po_ErrNo=1		
					SET @Taction=0
					SET @ErrDesc = 'Reset the Counter value'		 
					INSERT INTO Errorlog VALUES (10,@Tabname,'Counter Value',@ErrDesc)
				END
			IF  @Taction=1 AND @Po_ErrNo=0
				BEGIN	
					INSERT INTO CreditNoteSupplier (CrNoteNumber,CrNoteDate,SpmId,CoaId,ReasonId,Amount,CrAdjAmount,Status,PostedFrom,TransId,PostedRefNo,CrNoteReason,Remarks,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
					VALUES(@CrNoteNumber,CONVERT(NVARCHAR(12),REPLACE(REPLACE(@CreditDate,'T','  '),'oc ','oct'),121),@SpmId,@CoaId,@ReasonId,CAST(@CreditAmount AS NUMERIC(18,2)),0,
					(CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END),@CrNoteNumber,32,@CreditRefNo,'','',
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))

					SET @sSql='INSERT INTO CreditNoteSupplier (CrNoteNumber,CrNoteDate,SpmId,CoaId,ReasonId,Amount,CrAdjAmount,Status,PostedFrom,TransId,PostedRefNo,CrNoteReason,Remarks,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
					VALUES('''+@CrNoteNumber+''','''+CONVERT(NVARCHAR(12),REPLACE(REPLACE(@CreditDate,'T','  '),'oc ','oct'),121)+''','+CAST(@SpmId AS VARCHAR(10))+','+CAST(@CoaId AS VARCHAR(10))+','+CAST(@ReasonId AS VARCHAR(10))+','+CAST(CAST(@CreditAmount AS NUMERIC(18,2)) AS VARCHAR(20))+',0,
					'+CAST((CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END) AS VARCHAR(10))+','''+ @CrNoteNumber +''',32,'''+ @CreditRefNo +''','','',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
					INSERT INTO Translog(strSql1) VALUES (@sSql)

					UPDATE Counters SET CurrValue =CurrValue+1 WHERE Tabname =  @CntTabname AND Fldname = @FldName

					SET @sSql='UPDATE Counters SET CurrValue =CurrValue'+'+1'+' WHERE Tabname ='''+@CntTabname+''' AND Fldname ='''+@FldName+''''
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					EXEC Proc_VoucherPosting 32,1,@CrNoteNumber,3,6,1,@CreditDate,@Po_ErrNo=@ErrStatus OUTPUT
					SET @sSql='EXEC Proc_VoucherPosting 32,1,'''+@CrNoteNumber+''',3,6,'+CAST(1 AS NVARCHAR(100))+','''+CONVERT(NVARCHAR(20),@CreditDate,121)+''''
					INSERT INTO Translog(strSql1) VALUES (@sSql)
									
					IF @ErrStatus<>1
					BEGIN
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=0
					END
				END
			IF  @Taction=2 AND @Po_ErrNo=0
				BEGIN
					UPDATE CreditNoteSupplier SET Status=(CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END)
					WHERE CrNoteNumber=@CrNoteNumber 
					SET @sSql='UPDATE CreditNoteSupplier SET Status='+CAST((CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END) AS VARCHAR(10))+'
					WHERE CrNoteNumber='''+@CrNoteNumber+''''
					INSERT INTO Translog(strSql1) VALUES (@sSql)
				END
		FETCH NEXT FROM Cur_CreditNoteSupplier INTO @CreditRefNo,@CreditDate,@SupplierCode,@CreditAccount,@ReasonCode,@CreditAmount,@Status
	END
	CLOSE Cur_CreditNoteSupplier
	DEALLOCATE Cur_CreditNoteSupplier
    UPDATE ETL_Prk_CreditNoteSupplier SET DownloadFlag = 'Y' WHERE CreditRefNumber IN (SELECT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK))
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name ='ETL_Prk_DebitNoteSupplier')
DROP TABLE ETL_Prk_DebitNoteSupplier
GO
CREATE TABLE ETL_Prk_DebitNoteSupplier(
    [DistCode] [Nvarchar](20) NULL,
    [DebitRefNumber] [nvarchar](100) NULL,
	[DebitDate] [nvarchar](100) NULL,
	[SupplierCode] [nvarchar](100) NULL,
	[DebitAccount] [nvarchar](100) NULL,
	[ReasonCode] [nvarchar](100) NULL,
	[DebitAmount] [nvarchar](100) NULL,
	[Status] [nvarchar](100) NULL,
	[DownloadFlag] [nvarchar](2) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name ='Proc_ImportDebitNoteSupplier')
DROP PROCEDURE Proc_ImportDebitNoteSupplier
GO
CREATE PROCEDURE Proc_ImportDebitNoteSupplier
(
	@Pi_Records TEXT 
)
AS
/*********************************
* PROCEDURE	: Proc_ImportDebitNoteSupplier
* PURPOSE	: To Insert and Update records  from xml file in the Table DebitNoteSupplier 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      

*********************************/ 
SET NOCOUNT ON
BEGIN

	DECLARE @hDoc INTEGER
	TRUNCATE TABLE ETL_Prk_DebitNoteSupplier
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO ETL_Prk_DebitNoteSupplier (DistCode,DebitRefNumber,DebitDate,SupplierCode,DebitAccount,ReasonCode,DebitAmount,[Status],DownloadFlag)
			SELECT DistCode,DebitRefNumber,DebitDate,SupplierCode,DebitAccount,ReasonCode,DebitAmount,[Status],DownloadFlag
			FROM 	OPENXML (@hdoc,'/Root/Console2CS_DebitNoteSupplier',1)                              
			WITH 
			(  
			    [DistCode]        NVARCHAR(20),
			    [DebitRefNumber]  NVARCHAR(100), 
			    [DebitDate]       NVARCHAR(100),
				[SupplierCode]	  NVARCHAR(100),
				[DebitAccount]	  NVARCHAR(100),
				[ReasonCode]      NVARCHAR(100),
				[DebitAmount]	  NVARCHAR(100),
				[Status]          NVARCHAR(100),
				[DownloadFlag]    NVARCHAR(2)         
			) XMLObj

EXECUTE sp_xml_removedocument @hDoc
SELECT * FROM ETL_Prk_DebitNoteSupplier
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND NAME='Proc_ValidateDebitNoteSupplier')
DROP PROCEDURE Proc_ValidateDebitNoteSupplier
GO
/*
BEGIN TRANSACTION
EXEC Proc_ValidateDebitNoteSupplier 0 
Select * from debitnotesupplier order by dbnotenumber desc
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_ValidateDebitNoteSupplier
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateDebitNoteSupplier
* PURPOSE	: To Insert and Update records  from xml file in the Table DebitNoteSupplier 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
DECLARE @DebitRefNo AS NVARCHAR(50)
DECLARE @DebitDate AS NVARCHAR(12)
DECLARE @SupplierCode AS NVARCHAR(100)
DECLARE @DebitAccount AS NVARCHAR(100)
DECLARE @ReasonCode AS NVARCHAR(100)
DECLARE @DebitAmount AS NVARCHAR(100)
DECLARE @Status AS NVARCHAR(100)
DECLARE @DbNoteNumber AS NVARCHAR(50)
DECLARE @SpmId AS INT
DECLARE @CoaId AS INT
DECLARE @ReasonId AS INT
DECLARE @Taction AS INT
DECLARE @Tabname AS NVARCHAR(100)
DECLARE @CntTabname AS NVARCHAR(100)
DECLARE @Fldname AS NVARCHAR(100)
DECLARE @ErrDesc AS NVARCHAR(1000)
DECLARE @sSql AS NVARCHAR(4000)
DECLARE @ErrStatus		INT
DELETE FROM ETL_Prk_DebitNoteSupplier WHERE DownloadFlag = 'Y'
	SET @CntTabname='DebitNoteSupplier'
	SET @Fldname='DbNoteNumber'
	SET @Tabname = 'ETL_Prk_DebitNoteSupplier'
	SET @Taction=1
	SET @Po_ErrNo=0
	DECLARE Cur_DebitNoteSupplier CURSOR 
	FOR SELECT DISTINCT ISNULL([DebitRefNumber],''),ISNULL([DebitDate],GETDATE()),ISNULL([SupplierCode],''),ISNULL([DebitAccount],''),
    	ISNULL([ReasonCode],''),ISNULL([DebitAmount],'0'),ISNULL(Status,'')
	FROM ETL_Prk_DebitNoteSupplier
	
	OPEN Cur_DebitNoteSupplier
	FETCH NEXT FROM Cur_DebitNoteSupplier INTO @DebitRefNo,@DebitDate,@SupplierCode,@DebitAccount,@ReasonCode,@DebitAmount,@Status
	WHILE @@FETCH_STATUS=0
		
		BEGIN
			
		    IF EXISTS (SELECT DISTINCT [DebitRefNumber] FROM ETL_Prk_DebitNoteSupplier A WITH(NOLOCK),DebitNoteSupplier B WITH(NOLOCK)
	                   WHERE A.[DebitRefNumber]=@DbNoteNumber AND A.[DebitRefNumber] = B.PostedRefNo AND ([DebitRefNumber] <> '' OR [DebitRefNumber] IS NOT NULL))
	        BEGIN
					SELECT @DebitRefNo
	             	SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Debit RefNumber:  ' + @DebitRefNo + ' Already available in CreditNote Supplier' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'CreditRefNumber',@ErrDesc)
	        END
	        IF EXISTS (SELECT DISTINCT [DebitRefNumber] FROM ETL_Prk_DebitNoteSupplier WITH(NOLOCK) WHERE [DebitRefNumber]=@DbNoteNumber AND ([DebitRefNumber] = '' OR [DebitRefNumber] IS NULL))
	        BEGIN
	             	SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Credit RefNumber:  ' + @DebitRefNo + ' Should not be Empty' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'CreditRefNumber',@ErrDesc)
	        END
	        
			IF NOT EXISTS  (SELECT * FROM Supplier WHERE SpmCode = @SupplierCode )    
		  		BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Supplier Code: ' + @SupplierCode + ' is not available' 		 
					INSERT INTO Errorlog VALUES (1,@Tabname,'SupplierCode',@ErrDesc)
				END
			
			SELECT @SpmId =SpmId FROM  Supplier WHERE SpmCode = @SupplierCode
			IF NOT EXISTS  (SELECT * FROM CoaMaster WHERE AcName = @DebitAccount )    
		  		BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Debit Account: ' + @DebitAccount + ' is not available' 		 
					INSERT INTO Errorlog VALUES (2,@Tabname,'DebitAccount',@ErrDesc)
				END
			
			SELECT @CoaId =CoaId FROM  CoaMaster WHERE AcName = @DebitAccount
			IF NOT EXISTS  (SELECT * FROM ReasonMaster WHERE ReasonCode = @ReasonCode )    
		  		BEGIN
					SET @Po_ErrNo=1
					SET @Taction=0
					SET @ErrDesc = 'Reason Code: ' + @ReasonCode + ' is not available' 	 
					INSERT INTO Errorlog VALUES (3,@Tabname,'ReasonCode',@ErrDesc)
				END
			
			SELECT @ReasonId =ReasonId FROM  ReasonMaster WHERE ReasonCode = @ReasonCode
			IF ISDATE(CONVERT(NVARCHAR(12),REPLACE(REPLACE(@DebitDate,'T','  '),'oc ','oct'),121))=0
				BEGIN
					SET @Po_ErrNo=1	
					SET @Taction=0
					SET @ErrDesc = 'Debit Date not in Date format'		
					INSERT INTO Errorlog VALUES (4,@Tabname,'DebitDate',@ErrDesc)
				END	
			IF DATEDIFF(dd,CONVERT(NVARCHAR(12),REPLACE(REPLACE(@DebitDate,'T','  '),'oc ','oct'),121),CONVERT(NVARCHAR(10),GETDATE(),121))<0
				BEGIN
					SET @Po_ErrNo=1	
					SET @Taction=0
					SET @ErrDesc = 'Debit Date Sholud not be greater than Current date'		
					INSERT INTO Errorlog VALUES (5,@Tabname,'DebitDate',@ErrDesc)
				END
			
			IF ISNUMERIC(@DebitAmount)<=0
				BEGIN
					SET @Po_ErrNo=1	
					SET @Taction=0
					SET @ErrDesc = 'Debit Amount should not be empty'		 
					INSERT INTO Errorlog VALUES (6,@Tabname,'DebitAmount',@ErrDesc)
	
				END	
			ELSE
				BEGIN
					IF CAST(@DebitAmount AS NUMERIC(18,2))<=0
						BEGIN
							SET @Po_ErrNo=1	
							SET @Taction=0
							SET @ErrDesc = 'Debit Amount should be greater than zero'		 
							INSERT INTO Errorlog VALUES (7,@Tabname,'DebitAmount',@ErrDesc)
						END
				END
									
			IF LTRIM(RTRIM(@Status))='' 
				BEGIN
					SET @Po_ErrNo=0
					SET @Taction=0
					SET @ErrDesc = 'Status should not be empty'		 
					INSERT INTO Errorlog VALUES (8,@Tabname,'Status',@ErrDesc)
				END
			ELSE
				BEGIN
					IF LTRIM(RTRIM(@Status))='Active' OR LTRIM(RTRIM(@Status))='InActive'
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
							INSERT INTO Errorlog VALUES (9,@Tabname,'Status',@ErrDesc)
						END
				END
	
			SELECT @DbNoteNumber=dbo.Fn_GetPrimaryKeyString(@CntTabname,@FldName,CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
			IF @DbNoteNumber=''
				BEGIN
					SET @Po_ErrNo=1		
					SET @Taction=0
					SET @ErrDesc = 'Reset the Counter Value'		 
					INSERT INTO Errorlog VALUES (9,@Tabname,'Counter Value',@ErrDesc)
				END
			IF  @Taction=1 AND @Po_ErrNo=0
				BEGIN	
					INSERT INTO DebitNoteSupplier(DbNoteNumber,DbNoteDate,SpmId,CoaId,ReasonId,Amount,DbAdjAmount,Status,PostedFrom,TransId,PostedRefno,DbNoteReason,Remarks,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					 VALUES(@DbNoteNumber,CONVERT(NVARCHAR(12),REPLACE(REPLACE(@DebitDate,'T','  '),'oc ','oct'),121),@SpmId,@CoaId,@ReasonId,CAST(@DebitAmount AS NUMERIC(18,2)),0,
					(CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END),@DbNoteNumber,33,@DebitRefNo,'','',1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
					SET @sSql='INSERT INTO DebitNoteSupplier (DbNoteNumber,DbNoteDate,SpmId,CoaId,ReasonId,Amount,DbAdjAmount,Status,PostedFrom,TransId,PostedRefno,DbNoteReason,Remarks,PostedFrom,TransId,PostedRefno,DbNoteReason,Remarks,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
					VALUES('''+@DbNoteNumber+''','''+CONVERT(NVARCHAR(12),@DebitDate,121)+''','+CAST(@SpmId AS VARCHAR(10))+','+CAST(@CoaId AS VARCHAR(10))+','+CAST(@ReasonId AS VARCHAR(10))+','+CAST(CAST(@DebitAmount AS NUMERIC(18,2)) AS VARCHAR(20))+',0,
					'+CAST((CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END) AS VARCHAR(10))+','''+ @DbNoteNumber +''',33,'''+ @DebitRefNo +''','','',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET CurrValue =CurrValue+1 WHERE Tabname =  @CntTabname AND Fldname = @FldName
					SET @sSql='UPDATE Counters SET CurrValue =CurrValue'+'+1'+' WHERE Tabname ='''+@CntTabname+''' AND Fldname ='''+@FldName+''''
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					EXEC Proc_VoucherPosting 33,1,@DbNoteNumber,3,7,1,@DebitDate,@Po_ErrNo=@ErrStatus OUTPUT
					SET @sSql='EXEC Proc_VoucherPosting 33,1,'''+@DbNoteNumber+''',3,7,'+CAST(1 AS NVARCHAR(100))+','''+CONVERT(NVARCHAR(20),@DebitDate,121)+''''
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					
					IF @ErrStatus<>1
					BEGIN
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=0
					END
				END
			IF  @Taction=2 AND @Po_ErrNo=0
				BEGIN
					UPDATE DebitNoteSupplier SET Status=(CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END)
					WHERE DbNoteNumber=@DbNoteNumber 
					SET @sSql='UPDATE DebitNoteSupplier SET Status='+CAST((CASE @Status WHEN 'Active' THEN 1 WHEN 'InActive' THEN 2  END) AS VARCHAR(10))+'
					WHERE DbNoteNumber='''+@DbNoteNumber+''''
					INSERT INTO Translog(strSql1) VALUES (@sSql)
				END
		FETCH NEXT FROM Cur_DebitNoteSupplier INTO @DebitRefNo,@DebitDate,@SupplierCode,@DebitAccount,@ReasonCode,@DebitAmount,@Status
	END
	CLOSE Cur_DebitNoteSupplier
	DEALLOCATE Cur_DebitNoteSupplier
	UPDATE ETL_Prk_DebitNoteSupplier SET DownloadFlag = 'Y' WHERE DebitRefNumber IN (SELECT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK))
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name ='Proc_Cn2Cs_PurchaseReceipt')
DROP PROCEDURE Proc_Cn2Cs_PurchaseReceipt
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PurchaseReceipt 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_PurchaseReceipt
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
14/08/2013 Murugan.R	Logistic Material Management
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
	-- For Clearing the Prking/Temp Table -----	
	DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)	
	DELETE FROM ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
    DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)	
	DELETE FROM Etl_LogisticMaterialStock WHERE InvoiceNumber IN 
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1
	DELETE FROM ETLTempPurchaseReceiptCrDbAdjustments WHERE CmpInvNo 
	IN (SELECT CmpInvNo FROM PurchaseReceipt WHERE Status = 1) AND DownloadStatus = 1
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim
	TRUNCATE TABLE ETL_Prk_PurchaseReceipt
    TRUNCATE TABLE ETLTempPurchaseReceiptPrdLineDt
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptOtherCharges
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptCrDbAdjustments
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
	DECLARE @QtyInKg			NUMERIC(38,6)
	DECLARE @ExistCompInvNo		NVARCHAR(25)
	DECLARE @FreightCharges		NUMERIC(38,6)
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
	WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already downloaded and ready for invoicing' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt)
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
	--Supplier Credit Note Validations 
	IF EXISTS(SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN
	(SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit')
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
        SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN
	   (SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'CreditNoteSupplier','PostedRefNo','Supplier Credit Note Not Available'+[CompInvNo]
		FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN 
		(SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit'		
	END
	--Supplier Debit Note Validations 
	IF EXISTS(SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN
	(SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit')
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
        SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN
	   (SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'DebitNoteSupplier','PostedRefNo','Supplier Debit Note Not Available'+[CompInvNo]
		FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN 
		(SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit'		
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
	--->Till Here
	SET @ExistCompInvNo=0
	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,PurQty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs,0 AS BundleDeal,
	ISNULL(FreightCharges,0) AS FreightCharges
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	ORDER BY CompInvNo,ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,UOMCode,PurQty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs,FreightCharges
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
	@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
	@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId,@FreightCharges	
	WHILE @@FETCH_STATUS = 0
	BEGIN
--		IF @ExistCompInvNo<>@CompInvNo
--		BEGIN
--			SET @ExistCompInvNo=@CompInvNo
--			SET @RowId=2
--		END
		--To insert into ETL_Prk_PurchaseReceiptPrdDt
		IF(@FreeSchemeFlag='0')
		BEGIN
			INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount],FreightCharges)
			VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@LineLvlAmt,
			@PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty,@FreightCharges)
			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
			VALUES(@CompInvNo,@RowId,'C',@PurchaseDiscount)
			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
			VALUES(@CompInvNo,@RowId,'D',@VATTaxValue)
--			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
--			VALUES(@CompInvNo,@RowId,'E',@QtyInKg)
		END
		--To insert into ETL_Prk_PurchaseReceiptClaim
		IF(@FreeSchemeFlag='1')
		BEGIN
			INSERT INTO ETL_Prk_PurchaseReceiptClaim([Company Invoice No],[Type],[Ref No],[Product Code],
			[Batch Code],[Qty],[Stock Type],[Amount])
			VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0)
		END
--		SET @RowId=@RowId+1
		FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
		@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId,@FreightCharges
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase
	--To insert into ETL_Prk_PurchaseReceipt
	SELECT @SupplierCode=SpmCode FROM Supplier WHERE SpmDefault=1
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter)
	
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
	
	--Added By Sathishkumar Veeramani 2013/08/13
	INSERT INTO ETL_Prk_PurchaseReceiptOtherCharges ([Company Invoice No],[OC Description],Amount)
	SELECT DISTINCT CompInvNo,'Cash Discounts' AS [OC Description],CashDiscRs FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK)
	WHERE CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid) AND DownLoadFlag='D'
	
	--Added by Sathishkumar Veeramani 2013/11/22
	INSERT INTO ETL_Prk_PurchaseReceiptCrDbAdjustments([Company Invoice No],[Adjustment Type],[Ref No],[Amount])
	SELECT DISTINCT CompInvNo,AdjType,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WITH (NOLOCK)
	WHERE CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid) AND DownLoadFlag='D'
	
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
	--Proc_Validate_PurchaseReceiptCrDbAdjustments
	--->Added By Nanda on 17/09/2009
	DELETE FROM ETLTempPurchaseReceipt WHERE CmpInvNo NOT IN
	(SELECT DISTINCT CmpInvNo FROM ETLTempPurchaseReceiptProduct)
	UPDATE Cn2Cs_Prk_BLPurchaseReceipt SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceipt)
	--->Till Here
	SET @Po_ErrNo= @ErrStatus
	RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name ='Proc_Validate_PurchaseReceiptCrDbAdjustments')
DROP PROCEDURE Proc_Validate_PurchaseReceiptCrDbAdjustments
GO
/*
BEGIN TRANSACTION
Exec Proc_Validate_PurchaseReceiptCrDbAdjustments 0
SELECT * FROM ETLTempPurchaseReceiptCrDbAdjustments
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Validate_PurchaseReceiptCrDbAdjustments
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_PurchaseReceiptCrDbAdjustments
* PURPOSE		: To Insert and Update records in the Table PurchaseReceiptCrDbAdjustments
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Tabname 	AS     	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	
	DECLARE @CmpInvNo	AS 	NVARCHAR(100)	
	DECLARE @AdjType	AS 	NVARCHAR(100)
	DECLARE @CmpRefNo	AS 	NVARCHAR(100)
	DECLARE @RefNo	AS 	NVARCHAR(100)
	DECLARE @Amt		AS 	NVARCHAR(100)	
	
	SET @Po_ErrNo=0
	
	SET @DestTabname='ETLTempPurchaseReceiptCrDbAdjustments'
	SET @Fldname='CmpInvNo'
	SET @Tabname = 'ETL_Prk_PurchaseReceiptCrDbAdjustments'
	
	DECLARE Cur_PurchaseReceiptCrDbAdj CURSOR
	FOR SELECT DISTINCT ISNULL([Company Invoice No],''),ISNULL([Adjustment Type],''),ISNULL([Ref No],''),ISNULL([Amount],0)
	FROM ETL_Prk_PurchaseReceiptCrDbAdjustments WHERE Amount>0
	OPEN Cur_PurchaseReceiptCrDbAdj

	FETCH NEXT FROM Cur_PurchaseReceiptCrDbAdj INTO @CmpInvNo,@AdjType,@CmpRefNo,@Amt

	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Po_ErrNo=0

		IF NOT EXISTS(SELECT * FROM ETLTempPurchaseReceipt WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Invoice No',
			'Company Invoice No:'+@CmpInvNo+' is not available')  
         	
			SET @Po_ErrNo=1
		END				

		IF @Po_ErrNo=0
		BEGIN
			IF NOT ISNUMERIC(@Amt)=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Amount',
				'Amount:'+@Amt+' should be in numeric in Company Invoice No:'+@CmpInvNo) 

				SET @Po_ErrNo=1
			END			
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@AdjType)))='CREDITNOTE'
			BEGIN
				SELECT @RefNo=ISNULL(CrNoteNumber,'') FROM CreditNoteSupplier WHERE UPPER(LTRIM(RTRIM(PostedRefNo)))=UPPER(LTRIM(RTRIM(@CmpRefNo)))
			END
			ELSE
			BEGIN
				SELECT @RefNo=ISNULL(DbNoteNumber,'') FROM DebitNoteSupplier WHERE UPPER(LTRIM(RTRIM(PostedRefNo)))=UPPER(LTRIM(RTRIM(@CmpRefNo)))
			END
		END

		IF @RefNo IS NULL
		BEGIN
			SET @RefNo=''
		END
		
		IF @RefNo=''
		BEGIN
			SET @Po_ErrNo=1			
		END

		IF @Po_ErrNo=0
		BEGIN
			INSERT INTO ETLTempPurchaseReceiptCrDbAdjustments(CmpInvNo,AdjType,CrDbNo,Amount) 
			SELECT @CmpInvNo,(CASE @AdjType WHEN 'CreditNote' THEN 1 ELSE 2 END),@RefNo,@Amt
		END
			
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_PurchaseReceiptCrDbAdj
			DEALLOCATE Cur_PurchaseReceiptCrDbAdj
			RETURN
		END

		FETCH NEXT FROM Cur_PurchaseReceiptCrDbAdj INTO @CmpInvNo,@AdjType,@CmpRefNo,@Amt

	END
	CLOSE Cur_PurchaseReceiptCrDbAdj
	DEALLOCATE Cur_PurchaseReceiptCrDbAdj

	IF @Po_ErrNo=0
	BEGIN
		TRUNCATE TABLE ETL_Prk_PurchaseReceiptCrDbAdjustments
	END

	SET @Po_ErrNo=0

	RETURN	
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name ='Proc_RptBillTemplateLineNo')
DROP PROCEDURE Proc_RptBillTemplateLineNo
GO
CREATE PROCEDURE Proc_RptBillTemplateLineNo  
(
	@Pi_UsrId	INT,
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
RETURN
	
	DECLARE @TempSalId TABLE 
	(
		SalId INT
	) 
	DECLARE @TmpSalInvoice TABLE 
	(
		SalId INT
	)
	SET @Prdline = (SELECT LineNumber FROM BillTemplateHD WHERE  PrINTType =1  AND UsrId=@Pi_UsrId and tempName ='BillTemplate') 
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
		INSERT INTO @TempSalId(SalId) SELECT DISTINCT SalId FROM RptBTBillTemplate WITH (nolock) WHERE UsrId = @Pi_UsrId 
		AND SalId IN( SELECT SalId FROM @TmpSalInvoice) 
	END 
	ELSE 
	BEGIN 
		INSERT INTO @TempSalId(SalId) SELECT DISTINCT SalId FROM RptBTBillTemplate WITH (nolock) 
		WHERE UsrId = @Pi_UsrId AND SalId Between @FROMBillId AND @ToBillId  
	END
	DECLARE Cur_Salno CURSOR FOR 
	SELECT DISTINCT A.SalId FROM RptBTBillTemplate A WITH (nolock) INNER JOIN @TempSalId B ON A.SalId= B.SalId
	WHERE UsrId = @Pi_UsrId 
	OPEN Cur_Salno 
	FETCH NEXT FROM Cur_Salno INTO @Salinvno 
	WHILE @@FETCH_STATUS =0 
	BEGIN     
		SELECT @prdcnt = count(DISTINCT [Product Code]) FROM RptBTBillTemplate A WITH (nolock) WHERE UsrId = @Pi_UsrId and  [SalId] = @Salinvno 
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
			[Tax Amt UOM Percentage],[Tax Type],[TIN Number],[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name] ,UsrId ,Visibility )  
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
			[Tax Amt UOM Percentage],[Tax Type],[TIN Number],[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name],@Pi_UsrId,0  
			FROM RptBTBillTemplate
			WHERE [SalId] = @Salinvno and UsrId = @Pi_UsrId
			SET @PrdAva = @PrdAva - 1     
		END 
		FETCH NEXT FROM Cur_Salno INTo @Salinvno
	END 
	CLOSE Cur_Salno 
	DEALLOCATE Cur_Salno 
END
GO
DELETE FROM HotsearcheditorHD WHERE FormId = 405
INSERT INTO HotsearcheditorHD
SELECT 405,'Purchase Receipt','Invoice.Ref.No','select',
'SELECT DISTINCT PurRcptRefNo,InvDate,PurRcptId,A.DownloadStatus,ISNULL(B.CmpInvNo,'''') AS CrDbCmpInvNo FROM PurchaseReceipt A WITH (NOLOCK)
LEFT OUTER JOIN ETLTempPurchaseReceiptCrDbAdjustments B WITH (NOLOCK) ON A.CmpInvNo = B.CmpInvNo'
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_VoucherPostingPurchase')
DROP PROCEDURE Proc_VoucherPostingPurchase
GO
/*
BEGIN TRANSACTION
EXEC Proc_VoucherPostingPurchase 5,1,'GRN13000461',5,0,1,'2013-11-26',0
select * from Stdvocmaster with(Nolock) where VocDate = '2013-11-26' and remarks like 'Posted From GRN GRN13000461%'
select * from StdvocDetails with(Nolock) where VocrefNo = 'PUR1300461'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_VoucherPostingPurchase
(
	@Pi_TransId		Int,
	@Pi_SubTransId		Int,
	@Pi_ReferNo		nVarChar(100),
	@Pi_VocType		INT,
	@Pi_SubVocType		INT,	
	@Pi_UserId		Int,
	@Pi_VocDate		DateTime,
	@Po_PurErrNo		Int OutPut
)
AS
/*********************************
* PROCEDURE	: Proc_VoucherPostingPurchase
* PURPOSE	: General SP for posting Purchase Voucher
* CREATED	: Thrinath
* CREATED DATE	: 25/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @AcmId 		INT
	DECLARE @AcpId		INT
	DECLARE @CoaId		INT
	DECLARE @VocRefNo	nVarChar(100)
	DECLARE @sStr		nVarChar(4000)
	DECLARE @Amt		Numeric(25,6)
	DECLARE @DCoaId		INT
	DECLARE @CCoaId		INT
	DECLARE @DiffAmt	Numeric(25,6)
	DECLARE @sSql           VARCHAR(4000)
	SET @Po_PurErrNo = 1
	IF @Pi_TransId = 5 AND @Pi_SubTransId = 1
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		--For Posting Purchase Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From GRN ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		--For Posting Purchase Account in Details Table on Debit(Gross Amount)
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110001')
		BEGIN
			SET @Po_PurErrNo = -2
			Return
		END
		
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110001'
		SELECT @Amt = SUM(PrdGrossAmount) FROM PurchaseReceiptProduct
		WHERE PurRcptId IN (SELECT PurRcptId FROM
		PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo)
		
		DECLARE @Amt1 AS NUMERIC(38,6)
		SELECT @Amt1=LessScheme FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt-@Amt1,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
		--For Posting Supplier Account in Details Table to Credit(Net Payable)
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
			WHERE C.PurRcptRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
			WHERE C.PurRcptRefNo = @Pi_ReferNo
		--->Modified By Nanda on 29/10/2010
		--SELECT @Amt = NetPayable FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
		SELECT @Amt = NetPayable+DbAdjustAmt-CrAdjustAmt FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		--For Posting Purchase Discount Account in Details Table to Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptHdAmount B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0
		--For Posting Purchase Addition Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,D.CoaId,1 AS DebitCredit,B.BaseQtyAmount AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,
			@Pi_UserId AS AuthId,Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurTotAdd
		FROM PurchaseReceipt A INNER JOIN PurchaseReceiptHdAmount B ON
			A.PurRcptId = B.PurRcptId
		INNER JOIN PurchaseSequenceMaster C ON
			A.PurSeqId = C.PurSeqId
		INNER JOIN PurchaseSequenceDetail D ON
			C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
		WHERE A.PurRcptRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
			EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
			
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurTotAdd
		
		--For Posting Purchase Tax Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,C.InputTaxId,1 AS DebitCredit,ISNULL(SUM(B.TaxAmount),0) AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,@Pi_UserId AS AuthId,
			Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurTaxForDiff
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptProductTax B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRcptRefNo = @Pi_ReferNo
			Group By C.InputTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0
		
		--Added by Sathishkumar Veeramani 2013/11/26	
		SELECT @DiffAmt=ISNULL((SUM(A.TotalAddition)-(SUM(B.Amount)+SUM(C.Amount)+SUM(A.CrAdjustAmt))),0)
		FROM PurchaseReceipt A,#PurTaxForDiff B,#PurTotAdd C
		WHERE A.PurRcptRefNo = @Pi_ReferNo
		
		UPDATE #PurTaxForDiff SET Amount=Amount+@DiffAmt
		WHERE InputTaxId IN (SELECT MIN(InputTaxId) FROM #PurTaxForDiff)
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurTaxForDiff
		--For Posting Scheme Discount in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210002')
		BEGIN
			SET @Po_PurErrNo = -9
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210002'
		SET @Amt = 0
		SELECT @Amt = LessScheme FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND LessScheme > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END
		--For Posting Other Charges Add in Details Table For Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,B.CoaId,1,ISNULL(SUM(B.Amount),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptOtherCharges B ON
				A.PurRcptId = B.PurRcptId
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 0
			Group By B.CoaId
			HAVING ISNULL(SUM(B.Amount),0) > 0
		--For Posting Other Charges Reduce in Details Table To Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,B.CoaId,2,ISNULL(SUM(B.Amount),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptOtherCharges B ON
				A.PurRcptId = B.PurRcptId
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 1
			Group By B.CoaId
			HAVING ISNULL(SUM(B.Amount),0) > 0
		--For Posting Round Off Account reduce in Details Table to Debit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3220001')
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3220001'
		SET @Amt = 0
		SELECT @Amt = DifferenceAmount FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND DifferenceAmount > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,2,Abs(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END
		--For Posting Round Off Account Add in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4210001')
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4210001'
		SET @Amt = 0
		SELECT @Amt = DifferenceAmount FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND DifferenceAmount < 0
		
		IF @Amt < 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END
		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END
	IF @Pi_TransId = 7 AND @Pi_SubTransId = 1	--Purchase Return
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		--For Posting Purchase Return Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Purchase Return ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		--For Posting Purchase Return Account in Details Table on Debit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110002')
		BEGIN
			SET @Po_PurErrNo = -22
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110002'
		SELECT @Amt = GrossAmount FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Supplier Account in Details Table to Credit
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReturn C ON B.SpmId = C.SpmId
			WHERE C.PurRetRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReturn C ON B.SpmId = C.SpmId
			WHERE C.PurRetRefNo = @Pi_ReferNo
		SELECT @Amt = NetAmount FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Discount Account in Details Table to Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,1,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = @Pi_ReferNo AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',D.CoaId,1,B.BaseQtyAmount,1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Addition Account in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
				EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',D.CoaId,2,B.BaseQtyAmount,1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND B.RefCode <> ''' + 'D' + ''' AND
				EffectInNetAmount = 1 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Tax Account in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
				A.PurRetId = B.PurRetId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRetRefNo = @Pi_ReferNo
			Group By C.InPutTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
				A.PurRetId = B.PurRetId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + '''
			Group By C.InPutTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Scheme Discount in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210002')
		BEGIN
			SET @Po_PurErrNo = -9
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210002'
		SET @Amt = 0
		SELECT @Amt = LessScheme FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
			AND LessScheme > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'
			--INSERT INTO Translog(strSql1) Values (@sstr)
		END
		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END	
	IF @Pi_TransId = 13 AND @Pi_SubTransId = 0  -- Stock Out
	BEGIN
		IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.Coaid=299)	
		BEGIN	
			SELECT @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
		END
		ELSE
		BEGIN
			SELECT @Amt=SUM(Amount) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
		END
				
		
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		
		--For Posting StockAdjustment StockAdd Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
			(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Adjustment ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
				
			
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -26
			Return
		END
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -27
			Return
		END
		SELECT @DCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
		SELECT @CCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND SMT.Coaid<>299
			
		
		--For Posting Default Sales Account details on Debit
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
			--For Posting Default Debtor Account details on Debit
			SELECT @Amt=SUM(Amount) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
			
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'
			IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.Coaid=299)	
			BEGIN	
				SET @CCoaid=299
				SELECT @Amt=SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
				IF @Amt > 0
				BEGIN
					INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
					(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
						@Pi_UserId,Convert(varchar(10),Getdate(),121))
					SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
					(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
						',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
						+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
						Convert(nvarchar(10),Getdate(),121) + ''')'
				END
			END
		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			RETURN
		END
	END
	IF @Pi_TransId = 13 AND @Pi_SubTransId = 1   -- Stock In
	BEGIN
		
		Select @Amt=SUM(Amount) FROM StockManagement SM
		INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=SMP.StkMgmtTypeId AND SMT.TransactionType=0
		WHERE SM.StkMngRefNo=@Pi_ReferNo
			
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		
		--For Posting StockAdjustment StockAdd Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
			(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Adjustment ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
				
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -26
			Return
		END
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -27
			Return
		END
				
		SELECT @DCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.CoaId<>298
		SELECT @CCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
			
		
		--For Posting Default Purchase Account details on Debit
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
				(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'
		IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1 AND SMT.Coaid=298)	
		BEGIN
--			Select @Amt=SUM(TaxAmt) FROM StockManagement SM
--			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
--			WHERE SM.StkMngRefNo=@Pi_ReferNo
			SELECT @Amt=SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1
			SET @DCoaid=298
			IF @Amt >0 
			BEGIN
				INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
					LastModDate,AuthId,AuthDate) VALUES
					(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
					@Pi_UserId,Convert(varchar(10),Getdate(),121))
				SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
						(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
						',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
						+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
						Convert(nvarchar(10),Getdate(),121) + ''')'
			END
		END
--		Select @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagement SM
--			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
--			WHERE SM.StkMngRefNo=@Pi_ReferNo
			SELECT @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1
			
		--For Posting Default Purchase Account details on Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			RETURN
		END
	END
	IF @Po_PurErrNo=1
	BEGIN
			EXEC Proc_PostStdDetails @Pi_VocDate,@VocRefNo,1
	END
	RETURN
END
GO
DELETE FROM RptGroup WHERE RptId IN (61,64,67,69,73,74,78,79,88,91,92,94,118,126,133,137,138,150,183,165,168,232,202,237)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',61,'CreditEvaluation','Credit Evaluation Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',64,'CompanyMasterReport','Company Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',67,'StockManagementTypeMasterReport','Stock Management Type Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',69,'SupplierMasterReport','Supplier Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',73,'BankMasterReport','Bank Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',74,'BankBranchMasterReport','Bank Branch Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',78,'TaxConfigurationMasterReport','Tax Configuration Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',79,'TaxGroupMasterReport','Tax Group Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',88,'RouteMasterReport','Route Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',91,'ClaimGroupMasterReport','Claim Group Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',92,'ClaimNormMasterReport','Claim Norm Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',94,'ValueClassMasterReport','Value Classification Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',118,'OpeningBalance','Opening Balance Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',126,'StandardVoucher','Standard Voucher',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',133,'BatchTransferReport','Batch Transfer Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',137,'ContractPricingReport','Contract Pricing Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',138,'KitProductReport','KIT Product Master Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',150,'DatewiseProductwiseSales','Datewise Productwise Sales',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',165,'PendingBillsShippReport','Pending Bills Report-Shipping Address wise',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',168,'RptSalesRegisterReport','Billwise Collection Summary Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',183,'BillWiseProductWiseSales','BillWise ProductWise Sales Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',202,'PriceDifferenceClaimReport','Price Difference Claim Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',232,'SalesVatReport','Sales Vat Report',1)
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',237,'BrandWiseTargetAnlaysisReport','Brand wise Report - Target Anlaysis',1)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptBGRwiseTargetAnalysis' AND XTYPE='P')
DROP PROCEDURE Proc_RptBGRwiseTargetAnalysis
GO
--EXEC Proc_RptBGRwiseTargetAnalysis 237,1,0,'',0,0,1
--SELECT * FROM BRANDTARGET WHERE 
CREATE PROCEDURE Proc_RptBGRwiseTargetAnalysis
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
/************************************************************
* VIEW	: Proc_RptBrandwiseTargetAnalysis
* PURPOSE	: Brand wise Report - Target Analysis
* CREATED BY	: Mohana S
* CREATED DATE	: 16.01.2013
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @JcmId	 	AS	INT
	DECLARE @JcMonth	AS	DATETIME
	DECLARE @Brand 		AS	INT
	
	SET @JcmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId))
	
	SELECT  @JcMonth = ISNULL(dSelected,0) FROM Fn_ReturnRptFilterDate(@Pi_RptId,13,@Pi_UsrId)
	
	SET @Brand = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,274,@Pi_UsrId))
	
	SELECT J.JcmId[JcYear],J.JcmJc[JcMonth],JcmSdt,JcmEdt 
	INTO #JC 
	FROM JcMonth J INNER JOIN TargetAnalysisHd T ON J.JcmId=T.JcmId AND J.JcmJc=T.JcmJc
	WHERE (JcmSdt=(CASE @JcMonth WHEN '1900-01-01' THEN JcmSdt ELSE '1900-01-01' END) OR
	JcmSdt IN (SELECT dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,13,@Pi_UsrId)))
	AND J.JcmId=@JcmId AND T.TargetType=2 AND T.TargetLevel=1
	
	SELECT JcYear,JcMonth,SalId,RtrId 
	INTO #SR
	FROM SalesInvoice S
	INNER JOIN #JC J ON SalInvDate BETWEEN JcmSdt AND JcmEdt
	WHERE S.DlvSts IN (4,5)
	
	SELECT JcYear,JcMonth,SP.SalId,RtrId,SP.PrdId,SUM(SP.PrdGrossAmount) PrdGrossAmount
	INTO #SRP
	FROM SalesInvoiceProduct SP
	INNER JOIN #SR SR ON SP.SalId=SR.SalId
	GROUP BY JcYear,JcMonth,SP.SalId,RtrId,SP.PrdId	
--select  * from #ReturnProduct		
	SELECT JcYear,JcMonth,RH.SalId,RHP.PrdId,SUM(RHP.PrdGrossAmt)[ReturnGross] 
	INTO #ReturnProduct
	FROM ReturnHeader RH
	INNER JOIN ReturnProduct RHP ON RH.ReturnID=RHP.ReturnID
	INNER JOIN #SRP S ON S.SalId = RH.SalId AND S.PrdId = RHP.PrdId
	WHERE RH.Status=0
	GROUP BY JcYear,JcMonth,RH.SalId,RHP.PrdId
		
	SELECT C.PrdCtgValMainId,C.PrdCtgValName,E.PrdId,E.PrdName--,SUM(CURMONTHTARGET) [SalesPlan]
	INTO #ProductBrand
	FROM ProductCategoryValue C  INNER JOIN ProductCategoryValue D ON
	D.PrdCtgValLinkCode LIKE CAST(c.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	AND c.cmpprdctgid in (SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName IN ('Category','BrandGroup'))
	INNER JOIN Product E ON D.PrdCtgValMainId = E.PrdCtgValMainId	
	--Inner join targetanalysisdt TA WITH  (NOLOCK)on ta.PrdCtgValMainId =C.PrdCtgValMainId 
	WHERE c.prdctgvallinkcode in (SELECT PrdCtgValLinkCode  FROM ProductCategoryValue
	WHERE 
	--PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,274,@Pi_UsrId)))
	--Group by c.PrdCtgValMainId,E.Prdid,E.PrdName,c.PrdCtgValName
	(PrdCtgValMainId = (CASE @Brand WHEN 0 THEN PrdCtgValMainId ELSE 0 END) OR
	PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,274,@Pi_UsrId))))
	
	SELECT SP.JcYear,SP.JcMonth,PrdCtgValMainId,PrdCtgValName,COUNT(DISTINCT(SP.SalId))[BillsCut],COUNT(DISTINCT(RtrId))[ECO],
	COUNT(SP.PrdId)[LineSold],
	(ISNULL(SUM(SP.PrdGrossAmount),0)-ISNULL(SUM(ReturnGross),0))[SalesActual]
	INTO #Brand
	FROM #SRP SP
	INNER JOIN #ProductBrand PB ON SP.PrdId=PB.PrdId
	LEFT OUTER JOIN #ReturnProduct RP ON SP.PrdId=RP.PrdId AND SP.SalId=RP.SalId AND SP.JcMonth=RP.JcMonth AND SP.JcYear=SP.JcYear
	GROUP BY SP.JcYear,SP.JcMonth,PrdCtgValMainId,PrdCtgValName
	
	--INSERT INTO RptBrandwiseTargetAnalysis
	SELECT DISTINCT CONVERT(NVARCHAR(10),J.JcmSdt,103)[JCMonth],B.PrdCtgValName[Brand],TD.ProductivityCalls[Planned BillsCut],B.[BillsCut],
	TD.ECO [Planned ECO],B.[ECO],TD.LineSold [Planned LineSold],B.[LineSold],
	(TD.CurMonthPlan)[SalesPlan],
	ROUND([SalesActual],2)[SalesActual],
	CASE (TD.CurMonthPlan) WHEN 0 THEN 0 ELSE CAST(ROUND(ROUND([SalesActual],0)/((TD.CurMonthPlan))*100,2) AS NUMERIC(18,2)) END [Achievement%],
	@Pi_UsrId[UserId]		
	INTO #RptBrandwiseTargetAnalysis
	FROM #Brand B
	INNER JOIN TargetAnalysisHd TH ON B.JcYear=TH.JcmId AND B.JcMonth=TH.JcmJc
	INNER JOIN BrandTarget TD ON TH.TargetAnalysisId=TD.TargetAnalysisId AND TD.PrdCtgValMainId=B.PrdCtgValMainId
	INNER JOIN #JC J ON J.JcYear=TH.JcmId AND J.JcMonth=TH.JcmJc AND B.JcYear=J.JcYear AND B.JcMonth=J.JcMonth
	WHERE TH.TargetType=2
	--GROUP BY J.JcmSdt,B.PrdCtgValMainId,B.PrdCtgValName,TD.ProductivityCalls,[BillsCut],TD.ECO,B.[ECO],TD.LineSold,B.[LineSold],[SalesActual]
	--ORDER BY J.JcmSdt,B.PrdCtgValName
	
	
	DELETE FROM RptBrandwiseTargetAnalysis WHERE UserId=@Pi_UsrId
	
	INSERT INTO RptBrandwiseTargetAnalysis
	SELECT [JCMonth],[Brand],[Planned BillsCut],[BillsCut],[Planned ECO],[ECO],
	[Planned LineSold],[LineSold],[SalesPlan],[SalesActual],CAST([Achievement%]AS NVARCHAR(20))+'%' [Achievement%],[UserId]
	FROM #RptBrandwiseTargetAnalysis
	--
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM RptBrandwiseTargetAnalysis WHERE UserId=@Pi_UsrId
	
	SELECT * FROM RptBrandwiseTargetAnalysis WHERE UserId=@Pi_UsrId	
	ORDER BY [JCMonth],[Brand]
END
GO
DELETE FROM CustomCaptions WHERE TransId = 2 AND CtrlId = 1000 AND SubCtrlId = 266
INSERT INTO CustomCaptions
SELECT 2,1000,266,'Msgbox-2-1000-266','','','Tax not Calculated Row No:',1,1,1,GETDATE(),1,GETDATE(),'','','Tax not Calculated Row No:',1,1
--Till Here Sathishkumar Veeramani
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',410
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 410)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(410,'D','2013-11-27',GETDATE(),1,'Core Stocky Service Pack 410')