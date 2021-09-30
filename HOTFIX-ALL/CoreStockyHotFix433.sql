--[Stocky HotFix Version]=433
DELETE FROM Versioncontrol WHERE Hotfixid='433'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('433','3.1.0.10','D','2017-09-01','2017-09-01','2017-09-01',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product GST Issue Fix')
GO
DELETE FROM HotSearchEditorDT WHERE FormId=7004
INSERT INTO HotSearchEditorDT 
SELECT 1,7004,'Retailer','Name','RtrName',1500,0,'HotSch-502-2000-1',502  UNION
SELECT 2,7004,'Retailer','Code','RtrCode',1500,0,'HotSch-502-2000-2',502
GO
DELETE FROM CustomCaptions WHERE TRANSID=502 AND CtrlId=1000 and SubCtrlId IN (8,9)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 502,1000,8,'MsgBox-502-1000-8','','','Reference No. Mandatory for Registered Retailer.',1,1,1,GETDATE(),1,GETDATE(),'','','Reference No. Mandatory for Registered Retailer.',1,1 UNION
SELECT 502,1000,9,'MsgBox-502-1000-9','','','Service Amount should be Greater than Zero, Row Number : ',1,1,1,GETDATE(),1,GETDATE(),'','','Service Amount should be Greater than Zero, Row Number :',1,1
GO
DELETE FROM HotSearchEditorHd WHERE FormId=7004
INSERT INTO  HotSearchEditorHd 
SELECT 7004,'Service Invoice','Retailer','Select' ,'Select Rtrid,RtrName,RtrCode,CASE ISNULL(ColumnValue,'''') WHEN ''Registered'' THEN 1 WHEN ''Unregistered'' THEN 2 ELSE 0 END RetailerType 
From Retailer R LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD
INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId AND U.MasterId=2 AND ColumnName=''Retailer Type'')A
ON A.MasterRecordId=R.RtrId
 WHERE R.RTRID NOT IN (SELECT MASTERRECORDID  FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
AND U.MasterId=2 AND UPPER(ColumnName)=''COMPOSITION'' AND UPPER(ColumnValue)=''YES'')'
GO
DELETE A FROM Gst_FieldLevelConfiguration A (NOLOCK) 
WHERE TransId=2 and CtrlName IN ('fxtWindowDisplayAmount','chkWindowDisplay')
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_GSTUserLogInValidation')
DROP PROCEDURE Proc_GSTUserLogInValidation
GO
CREATE PROCEDURE [Proc_GSTUserLogInValidation](@ServerDate AS DATETIME)
AS
/*********************************
* PROCEDURE		: Proc_UserLogInValidation
* PURPOSE		: To Validate User Log in Proc_UserLogInValidation
* CREATED		: S.Moorthi
* CREATED DATE	: 17-04-2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

DECLARE @GstEnabled AS INT
SET @GstEnabled=0

	IF EXISTS(SELECT * FROM GSTConfiguration (NOLOCK) WHERE ActivationStatus=1 AND 
	AcknowledgeStatus=1 and ConsoleAckStatus=1 AND ModuleId='GSTCONFIG' )
	BEGIN
		SET @GstEnabled=1
	END
	
	DECLARE @VatTaxGroupId AS INT
	SET @VatTaxGroupId=0
	IF EXISTS(SELECT * FROM VATDefaultSupplierGST (NOLOCK))
	BEGIN		
		DECLARE @CmpId AS INT
		SET @CmpId=0
		SELECT @CmpId=CmpId FROM COMPANY WHERE DefaultCompany=1
		SELECT @VatTaxGroupId=MAX(ISNULL(TaxGroupId,0)) FROM VATDefaultSupplierGST (NOLOCK)
		UPDATE Supplier SET VATTaxGroupId=@VatTaxGroupId --WHERE ISNULL(VATTaxGroupId,0)=0
		UPDATE Supplier SET CmpId=@CmpId WHERE ISNULL(CmpId,0)=0
	END

	IF @GstEnabled=0
	BEGIN
		---NESTLE EDITABLE=1
		UPDATE A SET A.Editable=0,ColumnMandatory=0 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='PRODUCT MASTER' AND ColumnName IN ('HSN Code','HSN Description')
		
		UPDATE A SET A.Editable=1,ColumnMandatory=0 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='RETAILER MASTER' AND 
		ColumnName IN ('State Name','GSTIN','PAN Number','Retailer Type','Composition','Related Party')
		
		UPDATE A SET A.Editable=1,ColumnMandatory=0 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='SUPPLIER MASTER' AND 
		ColumnName IN ('State Name','GSTIN','Status')
		
		UPDATE A SET A.Editable=1,ColumnMandatory=0 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='DISTRIBUTOR INFO MASTER' AND 
		ColumnName IN ('State Name','GSTIN','PAN Number','Distributor Type')


		UPDATE A SET A.Editable=1,ColumnMandatory=0 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='COMPANY MASTER' AND 
		ColumnName IN ('State Name','GSTIN','PAN Number')
		
	END
	ELSE
	BEGIN
	
		UPDATE A SET A.Editable=0,ColumnMandatory=1 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='PRODUCT MASTER' AND ColumnName IN ('HSN Code','HSN Description')
		
		UPDATE A SET A.Editable=1,ColumnMandatory=1 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='RETAILER MASTER' AND 
		ColumnName IN ('State Name','GSTIN','PAN Number','Retailer Type','Composition','Related Party')
		
		UPDATE A SET A.Editable=1,ColumnMandatory=1 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='SUPPLIER MASTER' AND 
		ColumnName IN ('State Name','GSTIN','Status')

		UPDATE A SET A.Editable=1,ColumnMandatory=1 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='COMPANY MASTER' AND 
		ColumnName IN ('State Name','GSTIN','PAN Number')
		
		UPDATE A SET A.Editable=1,ColumnMandatory=1 FROM UdcMaster A (NOLOCK)
		INNER JOIN UdcHD B(NOLOCK) ON A.MasterId=B.MasterId 
		WHERE UPPER(B.MasterName)='DISTRIBUTOR INFO MASTER' AND 
		ColumnName IN ('State Name','GSTIN','PAN Number','Distributor Type')

		IF NOT EXISTS(SELECT * FROM Gst_FieldLevelConfiguration WHERE Transid=2)
		BEGIN
			INSERT INTO Gst_FieldLevelConfiguration
			SELECT 2,1,'fxtInvDisc',0,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,2,'fxtInvDiscAmt',0,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			--SELECT 2,3,'fxtWindowDisplayAmount',0,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,4,'chkInvoiceDisc',0,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,5,'fxtOnAccountAmount',0,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,6,'btnOperation',12,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,7,'btnOperation',9,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,8,'btnOperation',8,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,9,'btnOperation',10,1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,10,'btnOperation',11,1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) UNION
			SELECT 2,11,'chkOnAccount',0,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) --UNION
			--SELECT 2,12,'chkWindowDisplay',0,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)
		END
		----Retailer Taxgroup Update Post GST Migrate
		UPDATE  B SET B.TaxGroupId=C.TaxGroupId 
		FROM RetailerGSTTaxGroupUpdate A 
		INNER JOIN Retailer B ON A.RetailerCode=B.RtrCode
		INNER JOIN TaxGroupSetting C ON C.RtrGroup=A.TaxGroup 
		WHERE C.TaxGroup=1 and A.UpdateFlag=0

		UPDATE  D SET D.TaxGroupId=C.TaxGroupId 
		FROM RetailerGSTTaxGroupUpdate A 
		INNER JOIN Retailer B ON A.RetailerCode=B.RtrCode
		INNER JOIN RetailerShipAdd D ON D.RtrId=B.RtrId
		INNER JOIN TaxGroupSetting C ON C.RtrGroup=A.TaxGroup 
		WHERE C.TaxGroup=1 and A.UpdateFlag=0 and RtrShipDefaultAdd=1

		DELETE A FROM RetailerGSTTaxGroupUpdate A 
		INNER JOIN Retailer B ON A.RetailerCode=B.RtrCode 
		INNER JOIN TaxGroupSetting C ON C.RtrGroup=A.TaxGroup  and B.TaxGroupId=C.TaxGroupId
		WHERE C.TaxGroup=1 and A.UpdateFlag=0

		--DECLARE @VatTaxGroupId AS INT
		SET @VatTaxGroupId=0
		IF EXISTS(SELECT * FROM VATDefaultSupplier (NOLOCK))
		BEGIN
			SELECT @VatTaxGroupId=MAX(ISNULL(TaxGroupId,0)) FROM VATDefaultSupplier (NOLOCK)
			UPDATE Supplier SET VATTaxGroupId=@VatTaxGroupId WHERE ISNULL(VATTaxGroupId,0)=0
		END
		
		----Supplier TaxGroup Update Post GST Migrate
		UPDATE  B SET B.TaxGroupId=C.TaxGroupId 
		FROM SupplierGSTTaxGroupUpdate A 
		INNER JOIN Supplier B ON A.SpmCode=B.SpmCode
		INNER JOIN TaxGroupSetting C ON C.RtrGroup=A.TaxGroup 
		WHERE C.TaxGroup=3 and A.UpdateFlag=0
		
		DELETE A FROM SupplierGSTTaxGroupUpdate A 
		INNER JOIN Supplier B ON A.SpmCode=B.SpmCode 
		INNER JOIN TaxGroupSetting C ON C.RtrGroup=A.TaxGroup  and B.TaxGroupId=C.TaxGroupId
		WHERE C.TaxGroup=3 and A.UpdateFlag=0
		
	END
	
RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ReturnAvService' AND XTYPE='P')
DROP PROCEDURE Proc_ReturnAvService
GO
/*
BEGIN TRANSACTION
EXEC Proc_ReturnAvService 3,10012,53,'2017-07-01','2017-07-31',2,502
SELECT * FROM Temp_RettoCompanyClaimDetails
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ReturnAvService]
(
	@ServiceId	AS INT,
	@ClmGrpid	AS INT,
	@RtrId		AS INT,
	@FromDate   AS DATETIME,
	@ToDate		AS DATETIME,
	@Usrid		AS INT,
	@Tranid		AS INT
)
AS
BEGIN
SET NOCOUNT ON
	DECLARE @Schid AS INT
	DECLARE @MaxSlno AS INT
	DECLARE @Slno AS INT
	DECLARE @Date AS DATETIME  
	DECLARE @SchError AS INT
	DECLARE @RuleError AS INT
	DECLARE @Budget AS NUMERIC(18,6)
	DECLARE @RetailerBudget AS NUMERIC(18,6)
	DECLARE @AdjustedAmount AS NUMERIC(18,6)	
	DECLARE @ServiceAmount AS NUMERIC(18,6)
	DECLARE @ServiceTaxAmt AS NUMERIC(18,6)		
	DECLARE @DistState AS VARCHAR(100)
	DECLARE @RetState AS VARCHAR(100)
	DECLARE @StateId AS INT
	DECLARE @StateType AS VARCHAR(50)
	DECLARE @TaxGroupId AS INT
	DECLARE @ServiceTaxSeqid AS INT
	DECLARE @SchDesc AS NVARCHAR(200)
	DECLARE @WinClmId AS INT
	DECLARE @PrgClmId AS INT
	DECLARE @SanctionNo AS NVARCHAR(100)
	
	CREATE TABLE #SchemeList
	(
		Id INT IDENTITY(1,1),
		Schid INT,
		SchDsc NVARCHAR(200),
		Budget	NUMERIC(18,6)
	)
	
	CREATE TABLE #SchemeApplicable
	(
		Id INT IDENTITY(1,1),
		Schid INT,
		Budget NUMERIC(18,6)
	)
	
	DELETE FROM Temp_RettoCompanyClaimDetails WHERE Usrid=@Usrid AND Transid=@Tranid AND clmGrpid=@ClmGrpid	AND ServiceId=@ServiceId
	DELETE FROM Temp_RettoCompanyTaxDetails WHERE Usrid=@Usrid AND Transid=@Tranid AND clmGrpid=@ClmGrpid AND ServiceId=@ServiceId
	DELETE FROM Temp_RettoCompanyInvoiceDetails WHERE Usrid=@Usrid AND Transid=@Tranid AND clmGrpid=@ClmGrpid AND ServiceId=@ServiceId
	
	SET @Date=CONVERT(VARCHAR(10),GETDATE(),121)
	SELECT TOP 1 @DistState=ColumnValue FROM UdcMaster U (NOLOCK) 
	INNER JOIN UdcDetails UD (NOLOCK) ON U.MasterId=UD.MasterId and U.UdcMasterId=UD.UdcMasterId
	INNER JOIN Distributor D (NOLOCK) ON D.DistributorId=UD.MasterRecordId
	WHERE U.MasterId=16 and ColumnName='State Name' 
	
	--SELECT @RetState=ColumnValue FROM UdcMaster U (NOLOCK) 
	--INNER JOIN UdcDetails UD (NOLOCK) ON U.MasterId=UD.MasterId and U.UdcMasterId=UD.UdcMasterId
	--INNER JOIN Retailer D (NOLOCK) ON D.RtrId=UD.MasterRecordId
	--WHERE U.MasterId=7 and ColumnName='State Name' 
	
	SELECT @RetState = C.StateName from Retailer A (NOLOCK)
	Inner JOIN RetailerShipAdd B (NOLOCK) ON A.RtrId = B.RtrId 
	Inner JOIN StateMaster C (NOLOCK) ON B.StateId = C.StateId
	where A.RtrId = @RtrId and B.RtrShipDefaultAdd = 1
	
	SELECT @StateId=StateId FROM StateMaster WHERE StateName=@RetState
	SELECT @WinClmId= ClmGrpId FROM claimgroupmaster WHERE ClmGrpCode='CG21'---Window Display Claim
	
	--SELECT @PrgClmId  = ClmGrpId FROM claimgroupmaster WHERE ClmGrpCode='CG28'---Window Display Claim
	
	IF @DistState=@RetState 
	BEGIN
		SET @StateType='State'
	END
	ELSE
	BEGIN
		SET @StateType='InterState'
	END
	
	SELECT @TaxGroupId=TaxGroupId FROM ServiceMaster WHERE ServiceId=@ServiceId
	
IF @WinClmId=@ClmGrpid
BEGIN			
	INSERT INTO #SchemeList 
	SELECT DISTINCT WinDispSchId,SchDsc,WDSCapAmount FROM (
	SELECT SM.Schid as WinDispSchId,SchDsc,Budget WDSCapAmount FROM schememaster SM (NOLOCK) , SchemeRetAttr SA  
	(NOLOCK) WHERE  SchType = 4 AND  Sm.Schid = SA.Schid AND  setWindowDisp = 1 
	AND AdjWinDispOnlyOnce = 0 AND schstatus = 1 AND  ((@FromDate between SchValidFrom and SchValidTill) OR 
	(@ToDate between SchValidFrom and SchValidTill) OR (SchValidFrom between @FromDate and @ToDate)
	OR (SchValidTill between @FromDate and @ToDate)) --Issue Fix Condition Failed in Date Validation add () 
	)A
	
	SELECT @MaxSlno=MAX(Id) from #SchemeList
	
	SET @Slno=1
	WHILE @Slno<=@MaxSlno
	BEGIN
		SET @SchError=0
		SET @RuleError=0
		SET @RetailerBudget=0
		SET @AdjustedAmount=0
		SET @Budget=0
		SET @ServiceAmount=0
		SET @ServiceTaxAmt=0
		
		SELECT @Schid=Schid,@Budget=Budget,@SchDesc=SchDsc FROM #SchemeList WHERE id=@Slno
		
		EXEC Proc_ReturnSchemeApplicable 0,0,@RtrId,1,2,@Schid,@SchError
		
		IF @SchError=0
		BEGIN			
			EXEC Proc_ApplySchemeRuleSetting @Schid,@RtrId,0,@Usrid,2,@RuleError
			
			IF @RuleError=0
			BEGIN
				SELECT @RetailerBudget =BudgetAllocated FROM SchemeRtrLevelValidation WHERE SchId=@Schid AND RTRID=@RtrId
				
				IF @RetailerBudget>0 
				BEGIN
					SELECT @AdjustedAmount=ISNULL(SUM(SD.ServiceAmount),0) FROM ServiceInvoiceHd SH INNER JOIN ServiceInvoiceDT SD ON SH.ServiceInvId=SD.ServiceInvId
					WHERE ServiceInvFor=1 AND Refid=@Schid AND SH.ServiceFromId=@RtrId
				END
				ELSE
				BEGIN
				
					SELECT @AdjustedAmount=ISNULL(SUM(ServiceAmount),0) FROM
					(
					SELECT SUM(SD.ServiceAmount) AS ServiceAmount FROM ServiceInvoiceHd SH INNER JOIN ServiceInvoiceDT SD ON SH.ServiceInvId=SD.ServiceInvId
					WHERE ServiceInvFor=1 AND Refid=@Schid 		
					UNION ALL
					SELECT SUM(AdjAmt) AS ServiceAmount FROM SalesInvoiceWindowDisplay SW INNER JOIN SalesInvoice SI ON SI.SalId=SW.SalId 
					WHERE SchId=@Schid AND SW.RtrId=SI.RtrId and SW.RtrId= @RtrId AND DlvSts IN(4,5) AND SALINVDATE<'2017-07-01'
					)A
					
				END
		
				
				IF @Budget>isnull(@AdjustedAmount,0)
				BEGIN
					IF @RetailerBudget>0
					BEGIN
						IF @RetailerBudget>@AdjustedAmount
						BEGIN
							SET @ServiceAmount=@RetailerBudget-@AdjustedAmount
						END
					END				
					ELSE
					BEGIN
						SET @ServiceAmount=@Budget-@AdjustedAmount
					END
					
					SELECT @ServiceTaxSeqid=MAX(ServiceTaxSeqid) FROM ServiceTaxGroupMaster SM INNER JOIN ServiceTaxGroupSetting SD ON SM.ServiceGroupId=SD.ServiceGroupId
					WHERE SM.ServiceGroupId=@TaxGroupId
					
					IF @StateType='State'   -----GST12
					BEGIN					
						INSERT INTO Temp_RettoCompanyTaxDetails(ServiceId,ClmGrpId,Schid,Rtrid,ServiceGroupId,ServiceTaxSeqid,taxid,ServiceTaxCode,ServiceTaxPer,
														ServiceAmount,ServiceTaxAmt,Usrid,Transid)
						SELECT @ServiceId,@ClmGrpid,@schid,@Rtrid,SM.ServiceGroupId,ServiceTaxSeqid,taxid,ServiceTaxCode,ServiceTaxPer,
							@ServiceAmount,0,@Usrid,@Tranid
						FROM ServiceTaxGroupMaster SM INNER JOIN ServiceTaxGroupSetting SD ON SM.ServiceGroupId=SD.ServiceGroupId
						WHERE SM.ServiceGroupId=@TaxGroupId	and ServiceTaxSeqid=@ServiceTaxSeqid AND StateId=@StateId AND Statetype='State'
						AND SD.ServiceTaxPer>0 --Issue Fix Nivea
					END
					
					IF @StateType='InterState'
					BEGIN
						INSERT INTO Temp_RettoCompanyTaxDetails(ServiceId,ClmGrpId,Schid,Rtrid,ServiceGroupId,ServiceTaxSeqid,taxid,ServiceTaxCode,ServiceTaxPer,
														ServiceAmount,ServiceTaxAmt,Usrid,Transid)
						SELECT @ServiceId,@ClmGrpid,@schid,@Rtrid,SM.ServiceGroupId,ServiceTaxSeqid,taxid,ServiceTaxCode,ServiceTaxPer,
							   @ServiceAmount,0,@Usrid,@Tranid 
						FROM ServiceTaxGroupMaster SM INNER JOIN ServiceTaxGroupSetting SD ON SM.ServiceGroupId=SD.ServiceGroupId
						WHERE SM.ServiceGroupId=@TaxGroupId	and ServiceTaxSeqid=@ServiceTaxSeqid AND StateId=@StateId AND Statetype='InterState'
						AND SD.ServiceTaxPer>0 --Issue Fix Nivea
					END
					
					UPDATE Temp_RettoCompanyTaxDetails SET ServiceTaxAmt=CAST(@ServiceAmount * (ServiceTaxPer / 100 ) AS NUMERIC(38,6)) WHERE Schid = @Schid
					
					SELECT @ServiceTaxAmt=SUM(ServiceTaxAmt) FROM Temp_RettoCompanyTaxDetails  WHERE Usrid=@Usrid AND Transid=@Tranid AND clmGrpid=@ClmGrpid	AND ServiceId=@ServiceId
					and Schid = @Schid
					
					IF @ServiceTaxAmt>0
					BEGIN
						INSERT INTO Temp_RettoCompanyClaimDetails(ServiceId,ClmGrpId,Schid,SchDesc,Rtrid,TotAmount,AdjAmount,AvAmount,GstAmount,TotSerAmount,Usrid,Transid)
						SELECT @ServiceId,@ClmGrpid,@Schid,@SchDesc,@RtrId,@Budget,@AdjustedAmount,@ServiceAmount,@ServiceTaxAmt,@ServiceAmount+@ServiceTaxAmt,@Usrid,@Tranid
					END
				END				
			END
		END
			
		SET @Slno=@Slno+1
	END		
END
RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ReturnServiceTaxDt' AND XTYPE in ('TF','FN'))
DROP FUNCTION Fn_ReturnServiceTaxDt
GO
--Select * FROM Fn_ReturnServiceTaxDt(2,502,0, 0,1,1, 0,0) 
CREATE FUNCTION Fn_ReturnServiceTaxDt( @Usrid AS INT ,@Tranid AS INT,@ClmGrpid AS INT,
@ServiceId AS INT,@SerRefId AS INT,@RowId AS INT,@Imode AS INT,@RefId AS INT )
RETURNS @ServiceGroupDt TABLE
(
	ServiceType		 VARCHAR(100),
	ServiceTaxCode   VARCHAR(100),
	ServiceAmount    NUMERIC(18,3),	
	ServiceTaxPer    NUMERIC(18,3),
	ServiceTaxAmt	 NUMERIC(18,6)
)
AS
BEGIN
	IF @Imode=1 
	BEGIN
		INSERT INTO @ServiceGroupDt
		SELECT sername,ServiceTaxCode,ServiceAmount,ServiceTaxPer,ServiceTaxAmt 
		FROM Temp_RettoCompanyTaxDetails T INNER JOIN ServiceMaster SM ON SM.SERVICEID=T.ServiceId 
		WHERE Usrid=@Usrid AND Transid=@Tranid AND T.ClmGrpId=@ClmGrpid AND T.ServiceId=@ServiceId AND Schid=@RefId
	END
	
	IF @Imode=0
	BEGIN
		INSERT INTO @ServiceGroupDt		
		SELECT  sername,ServiceTaxCode,TaxableAmount,S.TaxPerc,TaxAmount  
		FROM ServiceInvoiceHD A --Issue Fix ServiceId Map
		INNER JOIN  ServiceInvoiceTaxDetails S ON A.ServiceInvId=S.ServiceInvId	
		INNER JOIN ServiceTaxGroupMaster ST ON S.ServiceGroupId=ST.ServiceGroupId
		INNER JOIN ServiceTaxGroupSetting SS ON SS.ServiceGroupId=ST.ServiceGroupId AND SS.ServiceGroupId=S.ServiceGroupId 
			AND S.ServiceTaxSeqId=SS.ServiceTaxSeqid AND S.Taxid=SS.TaxId
		INNER JOIN ServiceMaster SM ON SM.TaxGroupId=ST.ServiceGroupId AND SM.ServiceId=A.ServiceId
		WHERE S.RowNo=@RowId AND A.ServiceInvId=@SerRefId
	END
	
RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_InvoiceWiseGrnTrack' AND XTYPE='P')
DROP PROCEDURE Proc_InvoiceWiseGrnTrack
GO
/*
--exec Proc_InvoiceWiseGrnTrack 3,3,1,1,778,'SLR17000778'
 SELECT * FROM BilledPrdGRNTrack(nolock)
*/
CREATE PROCEDURE Proc_InvoiceWiseGrnTrack
(
	 @Pi_TransId	 INT,
	 @Pi_CalledFrom  INT,        
	 @Pi_UserId		 INT,
	 @Pi_LcnId		 INT,
	 @Pi_RefId		 INT,
	 @Pi_RefNo		 NVARCHAR(50)
)
AS
/************************
* PROCEDURE		: Proc_InvoiceWiseGrnTrack
* PURPOSE		: GST Changes To Track Product wise GRN Details
* CREATED		: Karthick
* CREATED DATE	: 2017-04-12
* MODIFIED
* DATE      AUTHOR     DESCRIPTION

***************************/
BEGIN
	DECLARE @MinRowid AS INT
	DECLARE @MaxRowid AS INT
 	DECLARE @Prdid AS INT
	DECLARE @PrdBatid AS INT
	DECLARE @BilledQty AS INT 
	DECLARE @MinSlno AS INT
	DECLARE @MaxSlno AS INT
	DECLARE @PurRcptId AS INT
	DECLARE @PurRcptRefNo AS VARCHAR(50)
	DECLARE @GrnQty AS INT
	DECLARE @RemainingQty AS INT
	DECLARE @GrnDate AS DATETIME
	DECLARE @PrdSlNo AS INT
	DECLARE @RefId AS INT 
	
	CREATE TABLE #GRNDETAILS
	(
		PurRcptId			INT,
		PurRcptRefNo		VARCHAR(50),
		PurRcptDate			DATETIME,
		PrdSlNo				INT,
		GrnQty				INT,
		Slno				INT	
	)

	CREATE TABLE #AdjustedPurchase
	(
		PurRcptId			INT,
		PurRcptRefNo		VARCHAR(50),
		PurRcptDate			DATETIME,
		Prdid				INT,
		Prdbatid			INT,
		PrdSlNo				INT,
		GrnQty				INT,
		LcnId				INT
	)
	
	CREATE TABLE #BilledDetails
	(
		Refid		INT,
		Prdid		INT,
		PrdBatId	INT,
		BaseQty		INT,
		RowId		INT
	)

 
/*
	CalledFrom-2 Billing
	CalledFrom-38 StockJournal
	CalledFrom-3 Sales Return
*/

	
	DELETE FROM BilledPrdGRNTrack WHERE UsrId = @Pi_UserId AND TransId = @Pi_TransId  
	
	IF @Pi_TransId=2
	BEGIN	
		INSERT INTO #BilledDetails
		SELECT 0,PrdId,PrdBatId,BaseQty,SlNo FROM Salesinvoiceproduct(NOLOCK) WHERE SalId=@Pi_RefId
			
		SELECT @MinRowid=MIN(ISNULL(RowId,0)) FROM #BilledDetails 
		SELECT @MaxRowid=MAX(ISNULL(RowId,0)) FROM #BilledDetails 
	END

	IF @Pi_TransId=3
	BEGIN		
		INSERT INTO #BilledDetails
		SELECT RP.salid,PrdId,PrdBatId,BaseQty,Slno 
		FROM Returnheader RH(NOLOCK) INNER JOIN Returnproduct RP(NOLOCK) ON RH.returnid=RP.returnid
		WHERE BillRef=1 AND ReturnCode=@Pi_RefNo
		
		SELECT @MinRowid=MIN(ISNULL(RowId,0)) FROM #BilledDetails
		SELECT @MaxRowid=MAX(ISNULL(RowId,0)) FROM #BilledDetails		
	END

	IF @Pi_TransId=38
	BEGIN		
		INSERT INTO #BilledDetails
		SELECT 0,Prdid,Prdbatid,StkTransferQty,ROW_NUMBER() OVER(ORDER BY Prdid) 
		FROM StockJournal S(NOLOCK) INNER JOIN StockJournalDt SD(NOLOCK)  ON S.StkJournalRefNo=SD.StkJournalRefNo
		WHERE s.StkJournalRefNo=@Pi_RefNo AND StockTypeId=1 
		
		SELECT @MinRowid=MIN(ISNULL(RowId,0)) FROM #BilledDetails
		SELECT @MaxRowid=MAX(ISNULL(RowId,0)) FROM #BilledDetails
	END
 
 --select * from #BilledDetails
	WHILE @MinRowid<=@MaxRowid
	BEGIN
	
		SELECT @Prdid=PrdId,@PrdBatid=PrdBatId,@BilledQty=BaseQty,@RefId=Refid FROM #BilledDetails WHERE RowId= @MinRowid
		
	IF (@Pi_TransId=2) OR (@Pi_TransId=38) 		
	BEGIN
		DELETE FROM #GRNDETAILS
		INSERT INTO #GRNDETAILS
		SELECT PurRcptId,PurRcptRefNo,InvDate,PrdSlNo,GrnQty,ROW_NUMBER() OVER(ORDER BY PurRcptId ASC) Slno
		FROM
		(
		SELECT PurRcptId,PurRcptRefNo,InvDate,PrdSlNo,SUM(GrnQty-AdjustedQty) AS GrnQty
		FROM
		(
			SELECT pr.PurRcptId,pr.PurRcptRefNo,(RcvdGoodBaseQty-RetRcvdBaseQty-BilledSalQty) AS GrnQty,0 AS AdjustedQty,PR.InvDate,PrdSlNo
			FROM PurchaseReceipt PR(NOLOCK) INNER JOIN PurchaseReceiptProduct PRP(NOLOCK) ON PR.PurRcptId=PRP.PurRcptId
			WHERE  PrdId=@Prdid and PrdBatId=@PrdBatid ANd Lcnid=@Pi_LcnId AND (RcvdGoodBaseQty-RetRcvdBaseQty-BilledSalQty)>0 --AND CancelInvoice=0
			UNION
			SELECT PurRcptId,PurRcptRefNo,0 AS GrnQty,GrnQty AS AdjustedQty,PurRcptDate,PrdSlNo FROM #AdjustedPurchase WHERE Prdid=@Prdid AND Prdbatid=@PrdBatid 
			AND LcnId=@Pi_LcnId
			UNION
			SELECT PurRcptId,PurRcptRefNo,0 AS GrnQty,GrnQty AS AdjustedQty,PurRcptDate,PrdSlNo FROM BilledPrdGRNTrack WHERE Prdid=@Prdid AND Prdbatid=@PrdBatid 
			AND Lcnid=@Pi_LcnId	AND UsrId = @Pi_UserId 
		)A 
		GROUP BY PurRcptId,PurRcptRefNo,InvDate,PrdSlNo
		HAVING SUM(GrnQty-AdjustedQty)>0 
		)B
     END
     
	IF (@Pi_TransId=3) 		
	BEGIN
		DELETE FROM #GRNDETAILS
		INSERT INTO #GRNDETAILS 
		SELECT PurRcptId,PurRcptRefNo,InvDate,PrdSlNo,GrnQty,ROW_NUMBER() OVER(ORDER BY PurRcptId ASC) Slno
		FROM
		(
		SELECT PurRcptId,PurRcptRefNo,InvDate,PrdSlNo,SUM(GrnQty-AdjustedQty) AS GrnQty
		FROM
		(
			SELECT PurRcptId,T.PurRcptRefNo,GrnQty ,0 AS AdjustedQty,GrnDate AS InvDate,GrnPrdSlNo AS PrdSlNo
			FROM TransactionWiseGrnTracking T(NOLOCK) INNER JOIN PurchaseReceipt P(NOLOCK) ON T.PurRcptRefNo=P.PurRcptRefNo
			WHERE Prdid=@Prdid AND PrdBatid=@PrdBatid AND RefId=@RefId AND TRANSID=2
		)A 
		GROUP BY PurRcptId,PurRcptRefNo,InvDate,PrdSlNo
		HAVING SUM(GrnQty-AdjustedQty)>0 
		)B
     END
	--select * from #GRNDETAILS
		
		SELECT @MinSlno =MIN(Slno) FROM #GRNDETAILS
		SELECT @MaxSlno =MAX(Slno) FROM #GRNDETAILS
			
			SET @RemainingQty=@BilledQty
			
			WHILE @MinSlno<=@MaxSlno
			BEGIN
				SELECT @PurRcptId= PurRcptId,@PurRcptRefNo =PurRcptRefNo,@GrnQty=GrnQty,@GrnDate=PurRcptDate,@PrdSlNo=PrdSlNo 
						FROM #GRNDETAILS WHERE Slno=@MinSlno
			
				IF @RemainingQty>0
				 BEGIN
					 IF @GrnQty>=@RemainingQty
					 BEGIN
						INSERT INTO BilledPrdGRNTrack(RowId,Refid,RefNo,Lcnid,Prdid,PrdBatid,BaseQty,FreeQty,PurRcptId,PurRcptRefNo,PurRcptDate,PrdSlNo,GrnQty,FreeGrnQty,Usrid,Transid,CalledFrom)
						SELECT  @MinRowid,@Pi_RefId,@Pi_RefNo,@Pi_LcnId,@Prdid,@PrdBatid,@BilledQty,0,@PurRcptId,@PurRcptRefNo,@GrnDate,@PrdSlNo,@RemainingQty,0,@Pi_UserId,@Pi_TransId,@Pi_CalledFrom
						
						INSERT INTO #AdjustedPurchase
						SELECT @PurRcptId,@PurRcptRefNo,@GrnDate,@Prdid,@PrdBatid,@PrdSlNo,@RemainingQty,@Pi_LcnId
						
						BREAK 
					 END 
					 ELSE
					 BEGIN
						INSERT INTO BilledPrdGRNTrack(RowId,Refid,RefNo,Lcnid,Prdid,PrdBatid,BaseQty,FreeQty,PurRcptId,PurRcptRefNo,PurRcptDate,PrdSlNo,GrnQty,FreeGrnQty,Usrid,Transid,CalledFrom)
						SELECT  @MinRowid,@Pi_RefId,@Pi_RefNo,@Pi_LcnId,@Prdid,@PrdBatid,@BilledQty,0,@PurRcptId,@PurRcptRefNo,@GrnDate,@PrdSlNo,@GrnQty,0,@Pi_UserId,@Pi_TransId,@Pi_CalledFrom

						INSERT INTO #AdjustedPurchase
						SELECT @PurRcptId,@PurRcptRefNo,@GrnDate,@Prdid,@PrdBatid,@PrdSlNo,@GrnQty,@Pi_LcnId
						
						SET @RemainingQty=@RemainingQty-@GrnQty
					 END
				  END					
				
				SET @MinSlno=@MinSlno+1
			END
		
		SET @MinRowid=@MinRowid+1
	END	
 
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_SalesInvoiceModificationHistory' AND XTYPE='P')
DROP PROCEDURE Proc_SalesInvoiceModificationHistory
GO
Create Procedure Proc_SalesInvoiceModificationHistory
(
	@Pi_TransId INT,
	@Pi_SalId BigInt
)
AS
/****************************************************************************************
Procedure Name  :Proc_SalesInvoiceModificationHistory
Purpose			:To Maintain the SalesInvoiceHistoryDetials
Created by		:Panneerselvam.k
Created on		:03/11/2009	
****************************************************************************************/
BEGIN
SET NOCOUNT ON
/*  Note :-
	TransId         1 :- Billing
					2 :- Vehicle Allocation
					3 :- Auto Delivery Procress
	TransactionFlag	1 :- Billing
					2 :- Free
					3 :- MarketReturn
					4 :- Replacement
*/
DECLARE @MaxVersionNo INT
DECLARE @VehicleStatus INT
DECLARE @VanDlvSts INT
SELECT @MaxVersionNo =  Isnull(VersionNo,1)  FROM SalesInvoiceModificationHistory 
											 WHERE SalId = @Pi_SalId
SET @MaxVersionNo = Isnull(@MaxVersionNo,0) + 1
			
SELECT @VehicleStatus = Dlvsts FROM SalesInvoiceModificationHistory 
											 WHERE SalId = @Pi_SalId
SELECT @VanDlvSts = Dlvsts FROM SalesInvoice WHERE SalId = @Pi_SalId
	IF @Pi_TransId = 1
	BEGIN
				/*	Sales  */
		INSERT INTO SalesInvoiceModificationHistory	
		SELECT 
				SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
				SIP.PrdId,SIP.PrdBatId,BaseQty,PrdUnitMRP,PrdUnitSelRate,
				PrdGrossAmount,SplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,
				PrdCDAmount,PrimarySchemeAmt,PrdTaxAmount,PrdNetAmount,
				1 StockType,1 TransactionFlag,0 AllotmentId,@MaxVersionNo VersionNo,
				DlvSts,GetDate() ModifiedDate,0 VehicleStatus,0 AS VehicleId
		FROM 
			SalesInvoice SI (NoLock),SalesInvoiceProduct SIP (NoLock)
		WHERE
			SI.SalId = SIP.SalId
			AND SI.SalId =  @Pi_SalId
				/*	Sales Manual Free and Sales Invoice Free */
		INSERT INTO SalesInvoiceModificationHistory	
		SELECT  SalId,SalInvNo,SalInvDate,SalNetAmt,LcnId,
				PrdId,PrdBatId,Sum(FreeQty) FreeQty,PrdUnitMRP,PrdUnitSelRate,
				PrdGrossAmount,SplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,PrdCDAmount,
				PrimarySchemeAmt,PrdTaxAmount,PrdNetAmount,StockType,TransactionFlag,AllotmentId,
				VersionNo,DlvSts,ModifiedDate,VehicleStatus,VehicleId
		FROM (
				SELECT 
						SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
						SIP.PrdId,SIP.PrdBatId,SIP.SalManFreeQty AS FreeQty,0 PrdUnitMRP, 0 PrdUnitSelRate,
						0 PrdGrossAmount,0 SplDiscAmount,0 PrdSchDiscAmount,0 PrdDBDiscAmount,
						0 PrdCDAmount,0 PrimarySchemeAmt,0 PrdTaxAmount,0 PrdNetAmount,
						3 StockType,2 TransactionFlag,0 AllotmentId,@MaxVersionNo VersionNo,
						DlvSts,GetDate()  ModifiedDate ,0 VehicleStatus,0 AS VehicleId
				FROM 
					SalesInvoice SI (NoLock),SalesInvoiceProduct SIP (NoLock)
				WHERE
					SI.SalId = SIP.SalId
					AND SI.SalId = @Pi_SalId
					AND SIP.SalManFreeQty > 0
				UNION ALL
				SELECT 
						SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
						SIF.FreePrdId,SIF.FreePrdBatId,SIF.FreeQty AS FreeQty,0 PrdUnitMRP, 0 PrdUnitSelRate,
						0 PrdGrossAmount,0 SplDiscAmount,0 PrdSchDiscAmount,0 PrdDBDiscAmount,
						0 PrdCDAmount,0 PrimarySchemeAmt,0 PrdTaxAmount,0 PrdNetAmount,
						3 StockType,2 TransactionFlag,0 AllotmentId,@MaxVersionNo VersionNo,
						DlvSts,GetDate() ModifiedDate , 0 VehicleStatus,0 AS VehicleId
				FROM 
					SalesInvoice SI,SalesInvoiceSchemeDtFreePrd SIF
				WHERE
					SI.SalId = SIF.SalId
					AND SI.SalId = @Pi_SalId ) AS X
		GROUP BY 
				SalId,SalInvNo,SalInvDate,SalNetAmt,PrdId,PrdBatId,PrdUnitMRP,PrdUnitSelRate,LcnId,
				PrdGrossAmount,SplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,PrdCDAmount,
				PrimarySchemeAmt,PrdTaxAmount,PrdNetAmount,StockType,TransactionFlag,AllotmentId,
				VersionNo,DlvSts,ModifiedDate,VehicleStatus,VehicleId
				/*  Market Return  */
		INSERT INTO SalesInvoiceModificationHistory	
		SELECT  SalId,SalInvNo,SalInvDate,SalNetAmt,LcnId,
				PrdId,PrdBatId,Sum(BaseQty) BaseQty,PrdUnitMRP,PrdUnitSelRte,
				PrdGrossAmt,PrdSplDisAmt,PrdSchDisAmt,PrdDBDisAmt,PrdCDDisAmt,
				PrimarySchAmt,PrdTaxAmt,PrdNetAmt,StockTypeId,TransactionFlag,AllotmentId,
				VersionNo,DlvSts,ModifiedDate,VehicleStatus,VehicleId
		FROM  (
				SELECT  
						SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
						RP.PrdId,RP.PrdBatId ,RP.BaseQty,RP.PrdUnitMRP,RP.PrdUnitSelRte,
						RP.PrdGrossAmt,RP.PrdSplDisAmt,RP.PrdSchDisAmt,RP.PrdDBDisAmt,
						RP.PrdCDDisAmt,RP.PrimarySchAmt,RP.PrdTaxAmt,RP.PrdNetAmt,
						RP.StockTypeId,3 TransactionFlag,0 AllotmentId,
						@MaxVersionNo VersionNo,DlvSts,GetDate() ModifiedDate,0 VehicleStatus,0 AS VehicleId
				FROM 
						SalesInvoice SI (NoLock),SalesInvoiceMarketReturn SIMR (NoLock),
						ReturnHeader RH (NoLock),ReturnProduct RP (NoLock)
				WHERE
							SI.SalId = SIMR.SalId
							AND RH.ReturnID = SIMR.ReturnId
							AND RH.ReturnID = RP.ReturnID
							AND SI.SalId = @Pi_SalId
				UNION All
				SELECT   
						SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
						RPF.FreePrdId AS PrdId,RPF.FreePrdBatId AS PrdBatId,
						RPF.ReturnFreeQty BaseQty, 
						0 PrdUnitMRP,0 PrdUnitSelRte,
						0 PrdGrossAmt,0 PrdSplDisAmt,0 PrdSchDisAmt,0 PrdDBDisAmt,
						0 PrdCDDisAmt,0 PrimarySchAmt,0 PrdTaxAmt,0 PrdNetAmt,
						RPF.FreeStockTypeId,3 TransactionFlag,0 AllotmentId,
						@MaxVersionNo VersionNo,DlvSts,GetDate() ModifiedDate,0 VehicleStatus,VehicleId
				FROM 
						SalesInvoice SI (NoLock),SalesInvoiceMarketReturn SIMR (NoLock),
						ReturnHeader RH (NoLock),ReturnSchemeFreePrdDt RPF (NoLock)
				WHERE
							SI.SalId = SIMR.SalId
							AND RH.ReturnID = SIMR.ReturnId
							AND RH.ReturnID = RPF.ReturnID
							AND SI.SalId = @Pi_SalId ) AS Y
		GROUP BY 
				SalId,SalInvNo,SalInvDate,SalNetAmt,PrdId,PrdBatId,PrdUnitMRP,PrdUnitSelRte,LcnId,
				PrdGrossAmt,PrdSplDisAmt,PrdSchDisAmt,PrdDBDisAmt,PrdCDDisAmt,
				PrimarySchAmt,PrdTaxAmt,PrdNetAmt,StockTypeId,TransactionFlag,AllotmentId,
				VersionNo,DlvSts,ModifiedDate,VehicleStatus,VehicleId
			/* Replacement Out  */
		INSERT INTO SalesInvoiceModificationHistory
		SELECT  
				SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
				RO.PrdId,RO.PrdBatId,RO.RepQty,0 PrdUnitMRP,SelRte PrdUnitSelRte,
				RepAmount PrdGrossAmt,0 PrdSplDisAmt,0 PrdSchDisAmt,0 PrdDBDisAmt,
				0 PrdCDDisAmt,0 PrimarySchAmt,Tax PrdTaxAmt,0 PrdNetAmt,
				RO.StockTypeId,4 TransactionFlag,0 AllotmentId,
				@MaxVersionNo VersionNo,DlvSts,GetDate() ModifiedDate,0 VehicleStatus,VehicleId
		FROM 
				SalesInvoice SI (NoLock),ReplacementHd RHD (NoLock),ReplacementOut RO (NoLock)
		WHERE
					SI.SalId = RHD.SalId
					AND RHD.RepRefNo = RO.RepRefNo
					AND SI.SalId = @Pi_SalId
				/* Vehicle Status and Allotment Id */
		IF @VehicleStatus = 2 
		BEGIN
			UPDATE SalesInvoiceModificationHistory SET VehicleStstus = 1  
						WHERE VersionNo = @MaxVersionNo AND SalId = @Pi_SalId	
			UPDATE SalesInvoiceModificationHistory SET AllotmentId = B.AllotmentId,VehicleId = B.VehicleId
						FROM  SalesInvoiceModificationHistory a,VehicleAllocationMaster b,
							  VehicleAllocationDetails C
						WHERE VersionNo = @MaxVersionNo AND SalId = @Pi_SalId
							  AND A.SalInvNo = C.SaleInvNo  AND B.AllotmentNumber = C.AllotmentNumber
		END
		IF @VanDlvSts = 2 OR @VanDlvSts = 3 OR  @VanDlvSts = 4 OR  @VanDlvSts = 5
		BEGIN
			UPDATE SalesInvoiceModificationHistory SET VehicleStstus = 1  
						WHERE VersionNo = @MaxVersionNo AND SalId = @Pi_SalId	
			UPDATE SalesInvoiceModificationHistory SET AllotmentId = B.AllotmentId,VehicleId = B.VehicleId
						FROM  SalesInvoiceModificationHistory a,VehicleAllocationMaster b,
							  VehicleAllocationDetails C
						WHERE VersionNo = @MaxVersionNo AND SalId = @Pi_SalId
							  AND A.SalInvNo = C.SaleInvNo  AND B.AllotmentNumber = C.AllotmentNumber
		END
				/*  Update MRP  in  History table */
		SELECT Distinct
				SalId,C.PrdId,A.PrdBatId,A.PrdBatDetailValue  INTO #TEMPMRPDET 
		FROM 
				ProductBatchDetails A ,BatchCreation B, 
				SalesInvoiceModificationHistory C
		WHERE 
				A.BatchSeqId = B.BatchSeqId AND A.SLNo = B.SlNo
				AND FieldDesc = 'MRP' AND B.SlNo = 1
				AND A.PrdBatId = C.PrdBatId 
				AND C.SalId =  @Pi_SalId
		UPDATE SalesInvoiceModificationHistory SET PrdUnitMRP = PrdBatDetailValue
				FROM SalesInvoiceModificationHistory A,#TEMPMRPDET B
				WHERE	A.SalId = B.SalId
						AND A.PrdBatId = B.PrdBatId
						AND TransactionFlag IN(2,3,4)
						AND A.SalId =  @Pi_SalId
				/*  Update Selling Rate  in  History table */
		SELECT Distinct
				SalId,C.PrdId,A.PrdBatId,A.PrdBatDetailValue INTO #TEMPMRPDETLSP 
		FROM 
				ProductBatchDetails A ,BatchCreation B, 
				SalesInvoiceModificationHistory C
		WHERE 
				A.BatchSeqId = B.BatchSeqId AND A.SLNo = B.SlNo
				AND FieldDesc = 'Selling Rate' AND B.SlNo = 3
				AND A.PrdBatId = C.PrdBatId 
				AND C.SalId = @Pi_SalId
		UPDATE SalesInvoiceModificationHistory SET PrdUnitSelRate= PrdBatDetailValue
				FROM SalesInvoiceModificationHistory A,#TEMPMRPDETLSP B
				WHERE	A.SalId = B.SalId
						AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						AND TransactionFlag IN(2,3,4)
						AND A.SalId = @Pi_SalId
				/* End Here */
	END
	IF @Pi_TransId = 2
	BEGIN
			SELECT 
					A.AllotmentId,A.AllotmentNumber,A.VehicleId,A.LcnId,
					B.SaleInvNo AS SalInvNo,Max(VersionNo) VersionNo INTO #TEMPVALLOC
			FROM	VehicleAllocationMaster A,
					VehicleAllocationDetails B,
					SalesInvoiceModificationHistory C
			WHERE 
					A.AllotmentNumber = B.AllotmentNumber
					AND B.SaleInvNo = C.SalInvNo
					AND A.AllotmentId = @Pi_SalId
			GROUP BY
					A.AllotmentId,A.AllotmentNumber,A.VehicleId,A.LcnId,
					B.SaleInvNo
			UPDATE	SalesInvoiceModificationHistory 
					SET VehicleStstus = 1,AllotmentId = @Pi_SalId,DlvSts = 2,
								VehicleId = B.VehicleId
					FROM	SalesInvoiceModificationHistory a,#TEMPVALLOC B
					Where	A.SalInvNo = B.SalInvNo AND B.AllotmentId = @Pi_SalId
							AND A.VersionNo = B.VersionNo
	END 
	IF @Pi_TransId = 3
	BEGIN
		DECLARE @MaxVer AS INT
		SELECT @MaxVer = Max(VersionNo) FROM SalesInvoiceModificationHistory WHERE SalId = @Pi_SalId
		UPDATE  SalesInvoiceModificationHistory 
				SET AllotmentId = b.AllotmentId,VehicleStstus = 1,VehicleId =B.VehicleId,DlvSts = 2
				FROM SalesInvoiceModificationHistory a,VehicleAllocationMaster B,
					 VehicleAllocationDetails C
				WHERE A.SalInvNo = C.SaleInvNo AND C.AllotmentNumber = B.AllotmentNumber
					  AND A.SalId = @Pi_SalId  AND VersionNo = @MaxVer
					  
		UPDATE PP SET PP.BilledSalQty= PP.BilledSalQty-A.GrnQty 
		FROM PurchaseReceiptProduct PP WITH (ROWLOCK) INNER JOIN PurchaseReceipt PR(NOLOCK) ON PP.PurRcptId=PR.PurRcptId
		INNER JOIN 
		(SELECT RefId,Prdid,PrdBatid,GrnPrdSlNo,PurRcptRefNo,SUM(GrnQty)GrnQty 
		From TransactionWiseGrnTracking T(NOLOCK) INNER JOIN SalesInvoice SI(NOLOCK) ON SI.SalId=T.RefId AND SI.SalInvNo=T.RefNo 
		WHERE RefId=@Pi_SalId AND Transid in(2) AND SI.DLVSTS IN (3)
		GROUP BY RefId,Prdid,PrdBatid,GrnPrdSlNo,PurRcptRefNo)A ON A.Prdid=PP.prdid and A.PrdBatid=PP.PrdBatId AND A.GrnPrdSlNo=PP.PrdSlNo 
		AND A.PurRcptRefNo=PR.PurRcptRefNo	WHERE (PP.BilledSalQty-A.GrnQty )>=0
					 
	END
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_Prk_ServiceTaxSetting' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_Prk_ServiceTaxSetting
GO
--exec Proc_Cn2Cs_Prk_ServiceTaxSetting 0
CREATE PROCEDURE Proc_Cn2Cs_Prk_ServiceTaxSetting
(
	@Po_ErrNo INT OUTPUT
)
AS
/*******************************************************
* PROCEDURE		: Proc_Cn2Cs_Prk_ServiceTaxSetting
* PURPOSE		: To validate the downloaded ServiceTaxSetting
* CREATED BY	: Karthick KJ
* CREATED DATE	: 2017/04/27
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------
* {date} {developer}  {brief modification description}
	
*******************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Tabname AS VARCHAR(100)
	DECLARE @ServiceTaxGroupCode AS VARCHAR(100)
	DECLARE @ServiceGroupId AS INT
	DECLARE @ServiceTaxSeqid AS INT
	
	SET @Po_ErrNo=0
	SET @Tabname='Cn2Cs_Prk_ServiceTaxSetting'
	
	DELETE FROM Cn2Cs_Prk_ServiceTaxSetting WHERE DownLoadFlag='Y'
	
	CREATE TABLE #Avoid 
	( 
		ServiceTaxGroupCode varchar(100)
	)
	
	SELECT DISTINCT ServiceTaxGroupCode,ServiceTaxCode,ServiceTaxPer,StateType,StateCode,DownLoadFlag INTO #Cn2Cs_Prk_ServiceTaxSetting
	FROM Cn2Cs_Prk_ServiceTaxSetting WHERE DownLoadFlag='D'
	
	INSERT INTO #Avoid
	SELECT DISTINCT ServiceTaxGroupCode FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND ISNULL(ServiceTaxGroupCode,'')='' UNION
	SELECT DISTINCT ServiceTaxGroupCode FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND StateCode NOT IN (SELECT StateCode FROM StateMaster(NOLOCK)) UNION
	SELECT DISTINCT ServiceTaxGroupCode FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND  ServiceTaxCode NOT IN (SELECT TaxCode FROM TaxConfiguration(NOLOCK)) UNION
	SELECT DISTINCT ServiceTaxGroupCode FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' GROUP BY ServiceTaxGroupCode HAVING SUM(ServiceTaxPer)=0 UNION
	SELECT DISTINCT ServiceTaxGroupCode FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND ISNULL(StateType,'')=''  UNION
	SELECT DISTINCT ServiceTaxGroupCode FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND UPPER(StateType) NOT IN ('STATE','INTERSTATE','UT')
	
	INSERT INTO Errorlog 
	SELECT 1,@Tabname,'ServiceTaxGroupCode','Service Tax Group Codee Does not Exists' FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND ISNULL(ServiceTaxGroupCode,'')='' UNION
	SELECT 2,@Tabname,'StateCode','State Code Does not Exists' FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND StateCode NOT IN (SELECT StateCode FROM StateMaster(NOLOCK))	UNION
	SELECT 3,@Tabname,'ServiceTaxCode','ServiceTaxCode Does not Exists' FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND  ServiceTaxCode NOT IN (SELECT TaxCode FROM TaxConfiguration(NOLOCK)) UNION
	SELECT 4,@Tabname,'ServiceTaxPer','ServiceTaxPer Cannot be Zero' FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' GROUP BY ServiceTaxGroupCode HAVING SUM(ServiceTaxPer)=0 UNION
	SELECT 5,@Tabname,'StateType','StateType Cannot be NULL' FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND ISNULL(StateType,'')='' UNION
	SELECT 6,@Tabname,'StateType','StateType Not in Proper Format' FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' AND UPPER(StateType) NOT IN ('STATE','INTERSTATE','UT')
			
	SELECT @ServiceGroupId=Currvalue+1 FROM Counters WHERE TabName='ServiceTaxGroupMaster' AND FldName='ServiceGroupId'
	SELECT @ServiceTaxSeqid=Currvalue+1 FROM Counters WHERE TabName='ServiceTaxGroupSetting' AND FldName='ServiceTaxSeqid'
	
	DECLARE Cur_TaxSetting CURSOR	 
	FOR
	SELECT DISTINCT ServiceTaxGroupCode  FROM #Cn2Cs_Prk_ServiceTaxSetting(NOLOCK) WHERE DownLoadFlag='D' 
			AND  ServiceTaxGroupCode NOT IN (SELECT ServiceTaxGroupCode FROM #Avoid)
	OPEN Cur_TaxSetting
	FETCH NEXT FROM Cur_TaxSetting INTO @ServiceTaxGroupCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ServiceTaxGroupMaster(NOLOCK) WHERE ServiceGroupCode=@ServiceTaxGroupCode)
		BEGIN
			INSERT INTO ServiceTaxGroupMaster
			SELECT @ServiceGroupId,@ServiceTaxGroupCode,1,1,GETDATE(),1,CONVERT(VARCHAR(10),GETDATE(),121)
		END
		ELSE
		BEGIN
			SELECT @ServiceGroupId=ServiceGroupId FROM ServiceTaxGroupMaster WHERE ServiceGroupCode=@ServiceTaxGroupCode
		END
		
		INSERT INTO ServiceTaxGroupSetting(ServiceTaxSeqid,ServiceGroupId,TaxId,ServiceTaxCode,ServiceTaxPer,StateType,StateId,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
		SELECT @ServiceTaxSeqid,@ServiceGroupId,T.TaxId,ServiceTaxCode,ServiceTaxPer,S.StateType,StateId,1,1,GETDATE(),1,CONVERT(VARCHAR(10),GETDATE(),121)
		FROM #Cn2Cs_Prk_ServiceTaxSetting S(NOLOCK) INNER JOIN TaxConfiguration T(NOLOCK) ON S.ServiceTaxCode=T.TAXCODE 
		INNER JOIN StateMaster SM(NOLOCK) ON SM.StateCode=S.StateCode --AND SM.StateType=s.StateType
		WHERE S.ServiceTaxGroupCode=@ServiceTaxGroupCode
		
			
		UPDATE C SET Currvalue=@ServiceGroupId  FROM Counters C(NOLOCK) WHERE TabName='ServiceTaxGroupMaster' AND FldName='ServiceGroupId'
		UPDATE C SET Currvalue=@ServiceTaxSeqid FROM Counters C(NOLOCK) WHERE TabName='ServiceTaxGroupSetting' AND FldName='ServiceTaxSeqid'
		
		UPDATE C SET DownLoadFlag='Y' FROM Cn2Cs_Prk_ServiceTaxSetting C(NOLOCK) WHERE ServiceTaxGroupCode=@ServiceTaxGroupCode
		
		SET @ServiceGroupId=@ServiceGroupId+1
		SET @ServiceTaxSeqid=@ServiceTaxSeqid+1
		
		FETCH NEXT FROM Cur_TaxSetting INTO @ServiceTaxGroupCode
	END
	CLOSE Cur_TaxSetting
	DEALLOCATE Cur_TaxSetting
	
 	RETURN
END
GO
IF EXISTS (SELECT  * FROM sys.objects where name='Proc_UpdateRetailerShipping' AND type='P')
Drop PROCEDURE Proc_UpdateRetailerShipping
GO
/*
Begin Tran
SELECT * FROM UdcDetails Where MasterId=2 AND MasterRecordId=117 AND UdcMasterId >77
EXEC Proc_UpdateRetailerShipping 117,21
Select * from  RetailerShipAdd where rtrid=117
Rollback Tran
*/  
CREATE PROCEDURE [Proc_UpdateRetailerShipping](@RtrId AS BIGINT,@RtrShipAddId AS INT)  
AS  
BEGIN  
DECLARE @StateId as INT  
DECLARE @GSTTin as VARCHAR(100)  
DECLARE @TaxGroupId AS INT  
DECLARE @GSTEnabled AS TINYINT  
SET @GSTEnabled=0  
SET @StateId=0  
SET @TaxGroupId=0  
SET @GSTTin=''  
  IF EXISTS(SELECT 'X' FROM GSTConfiguration WHERE ActivationStatus=1 and AcknowledgeStatus=1 and ConsoleAckStatus=1   
  and CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)>=ActivationDate)  
  BEGIN  
   SET @GSTEnabled=1  
  END  
  IF @RtrShipAddId=0  
  BEGIN  
   SELECT @RtrShipAddId=RtrShipId FROM RetailerShipAdd WHERE RtrId=@RtrId and RtrShipDefaultAdd=1   
  END  
  SELECT @StateId=SM.StateId FROM UdcHD A (NOLOCK)  
  INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId   
  INNER JOIN UdcDetails UD (NOLOCK) ON B.MasterId=UD.MasterId and B.UdcMasterId=UD.UdcMasterId   
  INNER JOIN Retailer R (NOLOCK) ON R.RtrId=UD.MasterRecordId   
  INNER JOIN StateMaster SM (NOLOCK) ON SM.StateName=UD.ColumnValue  
  WHERE A.MasterId=2 AND B.ColumnName='State Name' and ISNULL(ColumnValue,'')<>''  
  AND R.RtrId=@RtrId   
    
  SELECT @GSTTin=UD.ColumnValue FROM UdcHD A (NOLOCK)  
  INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId   
  INNER JOIN UdcDetails UD (NOLOCK) ON B.MasterId=UD.MasterId and B.UdcMasterId=UD.UdcMasterId   
  INNER JOIN Retailer R (NOLOCK) ON R.RtrId=UD.MasterRecordId     
  WHERE A.MasterId=2 AND B.ColumnName='GSTIN' and ISNULL(ColumnValue,'')<>'' AND ISNULL(ColumnValue,'')<>'NULL'
  AND R.RtrId=@RtrId  
    
  SELECT @TaxGroupId=ISNULL(TaxGroupId,0) FROM Retailer (NOLOCK) WHERE RtrId=@RtrId  
    
  IF ISNULL(@StateId,0)<>0  
  BEGIN  
   UPDATE A SET StateId=@StateId FROM RetailerShipAdd A WHERE RtrId=@RtrId and RtrShipId=@RtrShipAddId  
  END  
  
  UPDATE A SET GSTTinNo=ISNULL(@GSTTin,'') FROM RetailerShipAdd A WHERE RtrId=@RtrId and RtrShipId=@RtrShipAddId  --Added by Mohanakrishna A.B 
   /* No Valadation for GSTTINNo Commented by Mohanakrishna A.B
  IF ISNULL(@GSTTin,'')<>'' 
  BEGIN  
	  UPDATE A SET GSTTinNo=@GSTTin FROM RetailerShipAdd A WHERE RtrId=@RtrId and RtrShipId=@RtrShipAddId  
  END  
  */
  IF @GSTEnabled=1  
  BEGIN  
   IF ISNULL(@TaxGroupId,0)<>0  
   BEGIN  
    UPDATE A SET TaxGroupId=@TaxGroupId FROM RetailerShipAdd A WHERE RtrId=@RtrId and RtrShipId=@RtrShipAddId  
   END  
  END    
RETURN  
END
GO
--GSTR START
/*
	--> Billing,Billing Auto,Sales Panel,Sales Return,GST Sales Return
*/
--Added By Kishore
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='SalesInvoice' 
AND B.name='GSTIN')
BEGIN
	ALTER TABLE SalesInvoice ADD GSTIN VARCHAR(50) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='SalesInvoice' 
AND B.name='RtrType')
BEGIN
	ALTER TABLE SalesInvoice ADD RtrType Char(1) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='SalesInvoice' 
AND B.name='Composition')
BEGIN
	ALTER TABLE SalesInvoice ADD Composition Char(1) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='ReturnHeader' 
AND B.name='GSTIN')
BEGIN
	ALTER TABLE ReturnHeader ADD GSTIN VARCHAR(50) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='ReturnHeader' 
AND B.name='RtrType')
BEGIN
	ALTER TABLE ReturnHeader ADD RtrType Char(1) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='ReturnHeader' 
AND B.name='Composition')
BEGIN
	ALTER TABLE ReturnHeader ADD Composition Char(1) DEFAULT '' WITH VALUES
END
GO
IF EXISTS (SELECT '' FROM SYSOBJECTS WHERE NAME = 'FN_RetailerType' and xtype IN ('TF','FN'))
DROP FUNCTION FN_RetailerType
GO
--SELECT * FROM DBO.FN_RetailerType(174,1)
CREATE FUNCTION FN_RetailerType(@Id Int,@Type Int)
Returns @RetailerType Table
	(
		GSTIN		 VARCHAR(50),	 
		RetailerType Char(1),
		Composition  Char(1)
	
	)
AS
BEGIN
	DECLARE @GSTTinNo Varchar(50)
	DECLARE @RtrType Varchar(20)
	DECLARE @Composite Varchar(20)

IF @Type = 1
BEGIN
	--SELECT @GSTTinNo = ISNULL(GSTTinNo,'')  FROM RetailerShipAdd (NOLOCK) where RtrId = @Rtrid
	SELECT @GSTTinNo = CASE WHEN ISNULL(GSTTinNo,'NULL')='NULL' THEN '' ELSE GSTTinNo END 
	FROM RetailerShipAdd (NOLOCK) where RtrId = @Id
	
	select @RtrType = CASE UPPER(C.ColumnValue) WHEN UPPER('Registered') THEN 'R' WHEN UPPER('UN Registered') THEN 'U' 
	ELSE 'U' END
	FROM UdcHD A (NOLOCK)
	INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId = B.MasterId
	INNER JOIN UdcDetails C (NOLOCK) ON C.UdcMasterId = B.UdcMasterId
	WHERE A.MasterName = 'Retailer Master' AND B.ColumnName = 'Retailer Type' 
	AND C.MasterRecordid = @Id

	select @Composite = CASE UPPER(C.ColumnValue) WHEN UPPER('YES') THEN 'Y' WHEN UPPER('NO') THEN 'N' ELSE 'N' END  
	FROM UdcHD A (NOLOCK)
	INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId = B.MasterId
	INNER JOIN UdcDetails C (NOLOCK) ON C.UdcMasterId = B.UdcMasterId
	WHERE A.MasterName = 'Retailer Master' AND B.ColumnName = 'Composition'
	AND C.MasterRecordid = @Id
	
	Insert into @RetailerType
	select @GSTTinNo,ISNULL(@RtrType,''),ISNULL(@Composite,'')
END
IF @Type = 2
BEGIN	
	Insert into @RetailerType
	SELECT CASE WHEN ISNULL(GSTIN,'NULL')='NULL' THEN '' ELSE GSTIN END,ISNULL(RtrType,''),ISNULL(Composition,'') 
	FROM SalesInvoice (NOLOCK) WHERE SalId = @Id

END	
IF @Type = 3
BEGIN	
	Insert into @RetailerType
	SELECT CASE WHEN ISNULL(GSTIN,'NULL')='NULL' THEN '' ELSE GSTIN END,ISNULL(RtrType,''),ISNULL(Composition,'') 
	FROM ReturnHeader (NOLOCK) WHERE ReturnID = @Id

END	
  RETURN	
END
GO
--Running Scrpit
UPDATE A SET A.GSTIN = CASE WHEN ISNULL(B.GSTTinNo ,'NULL')='NULL' THEN '' ELSE B.GSTTinNo  END
FROM SalesInvoice A (NOLOCK)
INNER JOIN RetailerShipAdd B (NOLOCK) ON A.RtrId = B.RtrId AND A.RtrShipId=B.RtrShipId
WHERE ISNULL(A.GSTIN,'')='' AND VatGst = 'GST'
GO
UPDATE D SET D.RtrType =  CASE UPPER(C.ColumnValue) WHEN UPPER('Registered') THEN 'R' WHEN UPPER('UN Registered') THEN 'U' 
ELSE 'U' END
FROM UdcHD A (NOLOCK)
INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId = B.MasterId
INNER JOIN UdcDetails C (NOLOCK) ON C.UdcMasterId = B.UdcMasterId
INNER JOIN SalesInvoice D(NOLOCK) ON D.RtrId = C.MasterRecordId
WHERE A.MasterName = 'Retailer Master' AND B.ColumnName = 'Retailer Type'
AND ISNULL(D.RtrType,'')='' AND VatGst = 'GST'
GO
UPDATE D SET D.Composition = CASE UPPER(C.ColumnValue) WHEN UPPER('YES') THEN 'Y' WHEN UPPER('NO') THEN 'N' ELSE 'N' END  
FROM UdcHD A (NOLOCK)
INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId = B.MasterId
INNER JOIN UdcDetails C (NOLOCK) ON C.UdcMasterId = B.UdcMasterId
INNER JOIN SalesInvoice D(NOLOCK) ON D.RtrId = C.MasterRecordId
WHERE A.MasterName = 'Retailer Master' AND B.ColumnName = 'Composition'
AND ISNULL(D.Composition,'')='' AND VatGst = 'GST'
GO
DECLARE @SalId AS BIGINT
SET @SalId=0
SELECT @SalId=ISNULL(Min(SalId),0) FROM SalesInvoice WHERE VatGST='GST'
IF ISNULL(@SalId,0)<>0
BEGIN
	UPDATE SalesInvoice SET  VATGST='GST' WHERE SalId>=@SalId and VatGst='VAT'
	
	UPDATE A SET VatGst='GST' FROM ReturnHeader A INNER JOIN SalesInvoice B ON A.SalId=B.SalId
	WHERE A.VatGst='VAT' and B.VatGst='GST'
END
GO
UPDATE Configuration SET STATUS=1,Condition='Retailer Intra',configvalue=(SELECT taxgroupid FROM TaxGroupSetting where TaxGroupName='Retailer Intra') 
WHERE MODULEID='RET12' AND ModuleName='Retailer'
GO
--Kishore TillHere
--B3 STARTS
DELETE FROM RptGroup WHERE PID='GSTReports' and GrpCode='GSRT' and RptId=410
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSTReports',410,'GSRT','FORM GSTR',1
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and GrpCode='FORMGSTR3B' and RptId=411
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSRT 410',411,'FORMGSTR3B','FORM GSTR-3B',1
GO
DELETE FROM RptHeader WHERE RptId=411
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'FORMGSTR3B','FORM GSTR-3B',411,'FORM GSTR-3B','Proc_RptFORMGSTR_3B_GST','RptFORMGSTR_3B_1','RptFORMGSTR_3B_1.rpt',0
GO
DELETE FROM RptDetails where RPTID=411
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (411,2,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (411,3,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=411
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 411,208,1,'January' UNION
SELECT 411,208,2,'February' UNION
SELECT 411,208,3,'March' UNION
SELECT 411,208,4,'April' UNION
SELECT 411,208,5,'May' UNION
SELECT 411,208,6,'June' UNION
SELECT 411,208,7,'July' UNION
SELECT 411,208,8,'August' UNION
SELECT 411,208,9,'September' UNION
SELECT 411,208,10,'October' UNION
SELECT 411,208,11,'November' UNION
SELECT 411,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=411
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,411,'FORM GSTR-3B',1,'Nature Of Supplies',200,1,0,1,1,'Nature Of Supplies','','',0,GETDATE()
UNION ALL
SELECT 1,411,'FORM GSTR-3B',2,'Total Taxable',20,1,0,2,3,'Total Taxable','','',2,GETDATE()
UNION ALL
SELECT 1,411,'FORM GSTR-3B',3,'Integrated',20,1,0,2,3,'Integrated','','',2,GETDATE()
UNION ALL
SELECT 1,411,'FORM GSTR-3B',4,'Central',20,1,0,2,3,'Central','','',2,GETDATE()
UNION ALL
SELECT 1,411,'FORM GSTR-3B',5,'State_UT Tax',20,1,0,2,3,'State/UT Tax','','',2,GETDATE()
UNION ALL
SELECT 1,411,'FORM GSTR-3B',6,'Cess',20,1,0,2,3,'Cess','','',2,GETDATE()
GO
--DELETE FROM RptGridView WHERE RPTID=411
--INSERT INTO RptGridView 
--SELECT 411,'RptDistributorTurnOver.rpt',1,0,1,1 
--GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptFORMGSTR_3B_1')
DROP TABLE RptFORMGSTR_3B_1
GO
CREATE TABLE RptFORMGSTR_3B_1
(
slno Int IDENTITY(1,1),
[Nature Of Supplies] Varchar(200),
[Total Taxable]	Numeric(32,2),
[Integrated] Numeric(32,2),
Central	Numeric(32,2),
[State/UT Tax] Numeric(32,2),
[Cess] Numeric(32,2),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptFORMGSTR_3B_2')
DROP TABLE RptFORMGSTR_3B_2
GO
CREATE TABLE RptFORMGSTR_3B_2
(
slno Int IDENTITY(1,1),
[Nature Of Supplies] Varchar(200),
[Place of supply(State/UT)]	Varchar(200),
[Total Taxable Value] Numeric(32,2),
[Amount of Integrated]	Numeric(32,2),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptFORMGSTR_3B_3')
DROP TABLE RptFORMGSTR_3B_3
GO
CREATE TABLE RptFORMGSTR_3B_3
(
slno Int IDENTITY(1,1),
[Details] Varchar(200),
[Integrated Tax]	Varchar(30),
[Central Tax] Varchar(30),
[State/UT Tax] Varchar(30),
[Cess] Varchar(30),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptFORMGSTR_3B_4')
DROP TABLE RptFORMGSTR_3B_4
GO
CREATE TABLE RptFORMGSTR_3B_4
(
slno Int IDENTITY(1,1),
[Nature Of Supplies] Varchar(200),
[Inter-State Supplies]	Numeric(32,2),
[Intra-state Supplies] Numeric(32,2),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptFORMGSTR_3B_5')
DROP TABLE RptFORMGSTR_3B_5
GO
CREATE TABLE RptFORMGSTR_3B_5
(
slno Int IDENTITY(1,1),
[Description] Varchar(200),
[TaxPayable]	Numeric(32,2),
[ITC Integrate] Numeric(32,2),
[ITC Central] Numeric(32,2),
[ITC State/UT] Numeric(32,2),
[ITC Cess] Numeric(32,2),
[Tax Paid] Numeric(32,2),
[Tax/Cess paid] Numeric(32,2),
[Interest] Numeric(32,2),
[Late Fee] Numeric(32,2),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptFORMGSTR_3B_6')
DROP TABLE RptFORMGSTR_3B_6
GO
CREATE TABLE RptFORMGSTR_3B_6
(
slno Int IDENTITY(1,1),
[Details] Varchar(200),
[IntegratedTax]	Numeric(32,2),
[CentralTax] Numeric(32,2),
[State_UT Tax] Numeric(32,2),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptFORMGSTR_3B_1_GST')
DROP PROCEDURE Proc_RptFORMGSTR_3B_1_GST
GO
--EXEC Proc_RptFORMGSTR_3B_1_GST 411,1,0,'',0,0,0
--SELECT * FROM RptFORMGSTR_3B_1
CREATE PROCEDURE Proc_RptFORMGSTR_3B_1_GST
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT	
)
AS
/************************************************
* PROCEDURE  : Proc_RptFORMGSTR_3B
* PURPOSE    : To Generate Outward Supplies Tax Report
* CREATED BY : Murugan.R
* CREATED ON : 07/08/@Jcmyear
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON

		DECLARE @ErrNo	 			AS INT


---Find Zero Tax Product
		DECLARE @PrdBatTaxGrp AS INT
		DECLARE @RtrTaxGrp1 AS INT
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT 
		DECLARE @MaxSlno   INT
		DECLARE @MinSlno   INT
		DECLARE @Prdid INT
		SET @MinSlno=1
		
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		
		CREATE TABLE #ProductLst
		(
			Slno INT IDENTITY(1,1),	
			TaxSeqId INT,	
			Prdid INT,
			RtrId INT
		)	
		
		CREATE TABLE #ProductZeroTax(
		TaxGroupId [int] NULL,
		[TaxPercentage] [numeric](18, 5) NULL
		) 
		
			
		
		DECLARE @TaxSettingDet TABLE       
		(      
		TaxSlab   INT,      
		ColNo   INT,      
		SlNo   INT,      
		BillSeqId  INT,      
		TaxSeqId  INT,      
		ColType   INT,       
		ColId   INT,      
		ColVal   NUMERIC(38,2)      
		) 
		CREATE TABLE #TempProductTax
		(
			Prdid INT,
			TaxId INT,
			TaxSlabId INT,
			TaxPercentage Numeric(5,2),
			TaxAmount Numeric (18,5)
		)
	   
		SELECT @RtrTaxGrp=TaxGroupId FROM TaxGroupSetting (NOLOCK) WHERE RtrGroup='RTRINTRA'
	   
		SELECT * INTO #RtrGroup FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp 
		and CONVERT(DATETIME,CONVERT(VARCHAR(10),EffectiveFrom,121),121)<=CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)
		
		INSERT INTO #ProductLst (TaxSeqId,Prdid,RtrId)
		SELECT Max(A.TaxSeqId),A.Prdid,A.RtrId		
		FROM #RtrGroup A INNER JOIN TaxSettingMaster B ON A.RtrId=B.RtrId and A.Prdid=B.Prdid
		GROUP BY A.Prdid,A.RtrId

	    SELECT @MaxSlno=MAX(Slno) FROM #ProductLst
	    WHILE @MinSlno<=@MaxSlno
	    BEGIN
				
				DELETE FROM @TaxSettingDet	
				SELECT @PrdBatTaxGrp=Prdid, @RtrTaxGrp=RtrId FROM  #ProductLst WHERE Slno=@MinSlno
				--To Take the Batch TaxGroup Id      
								
				SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
				
						
				INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
				SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
				FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
				TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
				AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
				WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
				AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
				RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp
				and CONVERT(DATETIME,CONVERT(VARCHAR(10),EffectiveFrom,121),121)<=CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)
				)  
			
				SET @MRP=1
				TRUNCATE TABLE #TempProductTax
				DECLARE  CurTax CURSOR FOR      
					SELECT DISTINCT TaxSlab FROM @TaxSettingDet      
				OPEN CurTax        
				FETCH NEXT FROM CurTax INTO @TaxSlab      
				WHILE @@FETCH_STATUS = 0        
				BEGIN      
				SET @TaxableAmount = 0      
				--To Filter the Records Which Has Tax Percentage (>=0)      
				IF EXISTS (SELECT * FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId = 0 and ColVal >= 0)      
				BEGIN      
				--To Get the Tax Percentage for the selected slab      
				SELECT @TaxPer = ColVal FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId = 0      
				--To Get the TaxId for the selected slab      
				SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId > 0      
				SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP 
				--To Get the Parent Taxable Amount for the Tax Slab      
				SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM #TempProductTax A      
				INNER JOIN @TaxSettingDet B ON A.TaxId = B.ColVal and  
				B.ColType = 3 AND B.TaxSlab = @TaxSlab 
				If @ParTaxableAmount>0
				BEGIN
					Set @TaxableAmount=@ParTaxableAmount
				END 
				ELSE
				BEGIN
					Set @TaxableAmount = @TaxableAmount
				END    
				    
				INSERT INTO #TempProductTax (PrdId,TaxId,TaxSlabId,TaxPercentage,      
				TaxAmount)      
				SELECT @PrdBatTaxGrp,@TaxId,@TaxSlab,@TaxPer,      
				cast(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
				 
				  
				END      
				FETCH NEXT FROM CurTax INTO @TaxSlab      
				END        
				CLOSE CurTax        
				DEALLOCATE CurTax      
				SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
				FROM #TempProductTax WHERE Prdid=@PrdBatTaxGrp
									
				INSERT INTO #ProductZeroTax(TaxGroupId,TaxPercentage)
				SELECT @PrdBatTaxGrp,@TaxPercentage
				
				SET @MinSlno=@MinSlno+1	
	END	
	
	DELETE FROM #ProductZeroTax WHERE TaxPercentage>0
	
	SELECT DISTINCT B.PrdId INTO #ProductZeroTax1 
	FROM  #ProductZeroTax A INNER JOIN Product B ON A.TaxGroupId=B.TaxGroupId
	
	
	---EXEMPTED PRODUCT
	SELECT DISTINCT P.Prdid 
	INTO #ExemptProduct
	FROM UdcHD A (NOLOCK)
	INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
	INNER JOIN UdcDetails C (NOLOCK) ON C.MasterId=B.MasterId and C.MasterId=A.MasterId
	and C.UdcMasterId=B.UdcMasterId 
	INNER JOIN Product P (NOLOCK) ON P.PrdId=C.MasterRecordId
	WHERE A.MasterName='Product Master' and B.ColumnName='Exempt Product'
	and ColumnValue='Yes'
	
	SELECT DISTINCT PRDID INTO #ExemptAndZeroTax FROM(
	SELECT [PrdId] FROM #ProductZeroTax1
	UNION 
	SELECT PrdId FROM #ExemptProduct
	)X
	--Service Invoice UnRegistered Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerUnRegister
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue IN('UnRegistered')
	
		
	
	--WITH Tax
	
	TRUNCATE TABLE RptFORMGSTR_3B_1
	
	
	---OutWard Service
	
	
	SELECT PurRcptId  INTO #PurchaseReceipt FROM PurchaseReceipt (NOLOCK) WHERE GoodsRcvdDate Between '2017-01-01' and '2017-06-30' and Status=1
	and VatGst='VAT'
	
	INSERT INTO RptFORMGSTR_3B_1([Nature Of Supplies],[Total Taxable],[Integrated],[Central],[State/UT Tax],[Cess],UsrId,[Group Name],GroupType)
	SELECT '(a) Outward Taxable Supplies (other than zero rated,nil rated and exempted)' as [Nature Of Supplies],ISNULL(SUM(TaxableAmount),0) as [Total Taxable Amount],
	ISNULL(SUM(Integrated),0) as Integrated,ISNULL(SUM(Central),0) as Central,ISNULL(SUM([State/UTTax]),0) as [State/UTTax],ISNULL(SUM(CESS),0) as CESS,
	@Pi_UsrId,'',2
	FROM(
			SELECT  SUM(TaxableAmount) as TaxableAmount,SUM(TaxAmount) as Integrated,0 as Central,0 as [State/UTTax]  ,0 as CESS
			FROM SalesInvoice S (NOLOCK) 
			INNER JOIN SalesInvoiceProductTax SPT (NOLOCK)  ON S.Salid=SPT.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
			and TaxCode IN('OutputIGST','IGST') and VatGst='GST'
			AND TaxAmount>0
			UNION ALL
			SELECT SUM(TaxableAmount) as TaxableAmount,0 as Integrated,  SUM(TaxAmount) as Central,0 as [State/UTTax] ,0 as CESS 
			FROM SalesInvoice S (NOLOCK) 
			INNER JOIN SalesInvoiceProductTax SPT (NOLOCK) ON S.Salid=SPT.SalId
			INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
			WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
			and TaxCode IN('OutputCGST','CGST') and VatGst='GST'
			AND TaxAmount>0
			UNION ALL
			SELECT 0 as TaxableAmount,0 as Integrated,0 as Central,SUM(TaxAmount) as [State/UTTax] ,0 as CESS
			FROM SalesInvoice S (NOLOCK)  
			INNER JOIN SalesInvoiceProductTax SPT (NOLOCK)  ON S.Salid=SPT.SalId
			INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
			WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
			and TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') and VatGst='GST'
			AND TaxAmount>0
			UNION ALL
			---Sales Return
			SELECT  -1*SUM(TaxableAmt) as TaxableAmount,-1*SUM(TaxAmt) as Integrated,0 as Central,0 as [State/UTTax]  ,0 as CESS
			FROM ReturnHeader S (NOLOCK) 
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
			and TaxCode IN('OutputIGST','IGST') and SI.VatGst='GST'
			AND TaxAmt>0
			UNION ALL
			SELECT  -1*SUM(TaxableAmt) as TaxableAmount,0 as Integrated,-1*SUM(TaxAmt) as Central,0 as [State/UTTax] ,0 as CESS 
			FROM ReturnHeader S (NOLOCK) 
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
			and TaxCode IN('OutputCGST','CGST') and SI.VatGst='GST'
			AND TaxAmt>0
			UNION ALL
			SELECT  0 as TaxableAmount,0 as Integrated,0 as Central,-1*SUM(TaxAmt)  as [State/UTTax]  ,0 as CESS
			FROM ReturnHeader S (NOLOCK) 
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
			and TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') and SI.VatGst='GST'
			AND TaxAmt>0
			UNION ALL
			SELECT SUM(TaxableAmount) as TaxableAmount,SUM(PPT.TaxAmount) as Integrated,0 as Central,0 as [State/UTTax] ,0 as CESS 
			FROM PurchaseReturn P (NOLOCK) 
			INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId
			INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
			WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
			and TaxCode IN('InputIGST','IGST')
			AND PPT.TaxAmount>0
			UNION ALL
			SELECT SUM(TaxableAmount) as TaxableAmount,0 as Integrated,SUM(PPT.TaxAmount) as Central,0 as [State/UTTax]  ,0 as CESS
			FROM PurchaseReturn P (NOLOCK) 
			INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId
			INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
			WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
			and TaxCode IN('InputCGST','CGST')
			AND PPT.TaxAmount>0
			UNION ALL
			SELECT 0 as TaxableAmount,0 as Integrated,0 as Central,SUM(PPT.TaxAmount) as [State/UTTax] ,0 as CESS
			FROM PurchaseReturn P (NOLOCK) 
			INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId
			INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
			WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
			and TaxCode IN('InputSGST','InputUTGST','SGST','UTGST')
			AND PPT.TaxAmount>0
			UNION ALL
			SELECT 0 as TaxableAmount,0 as Integrated,0 as Central,0 as [State/UTTax] ,SUM(PPT.TaxAmount) as CESS
			FROM PurchaseReturn P (NOLOCK) 
			INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId
			INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
			WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
			and TaxCode IN('InputGSTCess')
			AND PPT.TaxAmount>0
			--UNION ALL
			----SERVICE OUTWard
			--SELECT SUM(ISNULL(DocAmount,0))  as TaxableAmount,SUM(ISNULL(IGST_AMT,0)) as Integrated,SUM(ISNULL(CGST_Amt,0)) as Central,
			--SUM(ISNULL(SGST_Amt,0)+ISNULL(UTGST_Amt,0)) as [State/UTTax],
			--0 as CESS  
			--FROM ClaimAcknowledgement WHERE ClaimType IN('Project1 Claim','Other Claim','Manual Claim',
			--'VAT Claim','Incentive Claim','ROI Subsidy Claim','VD ManPower Cost Claim','VD Subsidy Claim')
			--and CAST(ClaimMonth as INT)=@MonthStart and ClaimYear=@Jcmyear 
			--and LEN(ISNULL(DocNumber,''))>0 and Status='APPROVED'
			--HAVING SUM(ISNULL(IGST_AMT,0)+ISNULL(CGST_Amt,0)+ISNULL(SGST_Amt,0)+ISNULL(UTGST_Amt,0))>0
	
	)X 
	
		--NOT Applicable

		INSERT INTO RptFORMGSTR_3B_1([Nature Of Supplies],[Total Taxable],[Integrated],[Central],[State/UT Tax],[Cess],UsrId,[Group Name],GroupType)
		SELECT '(b) Outward Taxable Supplies(Zero Rated)' as [Nature Of Supplies],0 as [Total Taxable Amount],
		0 as Integrated,0 as Central,0 as [State/UTTax],0 as CESS,
		@Pi_UsrId,'',2
	
		--EXCEMPTED  AND ZERO Product	
		IF NOT EXISTS(SELECT 'X' FROM #ExemptAndZeroTax)
		BEGIN
			INSERT INTO RptFORMGSTR_3B_1([Nature Of Supplies],[Total Taxable],[Integrated],[Central],[State/UT Tax],[Cess],UsrId,[Group Name],GroupType)
			SELECT '(c) Other Outward Supplies(Nil Rated,Exempted)' as [Nature Of Supplies],0 as [Total Taxable Amount],
			0 as Integrated,0 as Central,0 as [State/UTTax],0 as CESS,
			@Pi_UsrId,'',2
		END
		ELSE
		BEGIN
			
			INSERT INTO RptFORMGSTR_3B_1([Nature Of Supplies],[Total Taxable],[Integrated],[Central],[State/UT Tax],[Cess],UsrId,[Group Name],GroupType)
			SELECT '(c) Other Outward Supplies(Nil Rated,Exempted)' as [Nature Of Supplies],ISNULL(SUM(TaxableAmount),0) as [Total Taxable Amount],
			ISNULL(SUM(Integrated),0) as Integrated,ISNULL(SUM(Central),0) as Central,ISNULL(SUM([State/UTTax]),0) as [State/UTTax],ISNULL(SUM(CESS),0) as CESS,
			@Pi_UsrId,'',2
			FROM(
				SELECT  SUM(TaxableAmount) as TaxableAmount,SUM(TaxAmount) as Integrated,0 as Central,0 as [State/UTTax],0 as CESS 
				FROM SalesInvoice S (NOLOCK)
				INNER JOIN SalesInvoiceProduct SIP ON S.SalId=SIP.SalId 
				INNER JOIN SalesInvoiceProductTax SPT (NOLOCK)  ON S.Salid=SPT.SalId and SPT.SalId=SIP.SalId and SIP.SlNo=SPT.PrdSlNo
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=SIP.PrdId
				WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
				and TaxCode IN('OutputIGST','IGST') and VatGst='GST'	
				AND TaxAmount=0			
				UNION ALL
				SELECT  SUM(TaxableAmount) as TaxableAmount,0 as Integrated,SUM(TaxAmount) as Central,0 as [State/UTTax] ,0 as CESS
				FROM SalesInvoice S (NOLOCK)
				INNER JOIN SalesInvoiceProduct SIP ON S.SalId=SIP.SalId 
				INNER JOIN SalesInvoiceProductTax SPT (NOLOCK)  ON S.Salid=SPT.SalId and SPT.SalId=SIP.SalId and SIP.SlNo=SPT.PrdSlNo
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=SIP.PrdId
				WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
				and TaxCode IN('OutputCGST','CGST') and VatGst='GST'	
				AND TaxAmount=0			
				UNION ALL
				SELECT  0 as TaxableAmount,0 as Integrated,0 as Central,SUM(TaxAmount) as [State/UTTax],0 as CESS 
				FROM SalesInvoice S (NOLOCK)
				INNER JOIN SalesInvoiceProduct SIP ON S.SalId=SIP.SalId 
				INNER JOIN SalesInvoiceProductTax SPT (NOLOCK)  ON S.Salid=SPT.SalId and SPT.SalId=SIP.SalId and SIP.SlNo=SPT.PrdSlNo
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=SIP.PrdId
				WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
				and TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') and VatGst='GST'
				AND TaxAmount=0			
				UNION ALL
				---Sales Return
				SELECT  -1*SUM(TaxableAmt) as TaxableAmount,-1*SUM(TaxAmt) as Integrated,0 as Central,0 as [State/UTTax] ,0 as CESS
				FROM ReturnHeader S (NOLOCK) 
				INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnID=S.ReturnID
				INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID and SPT.ReturnId=Rp.ReturnID and SPT.PrdSlno=Rp.Slno
				INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=RP.PrdId
				WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
				and TaxCode IN('OutputIGST','IGST') and SI.VatGst='GST'
				AND TaxAmt=0				
				UNION ALL
				SELECT  -1*SUM(TaxableAmt) as TaxableAmount,0 as Integrated,-1*SUM(TaxAmt) as Central,0 as [State/UTTax] ,0 as CESS
				FROM ReturnHeader S (NOLOCK) 
				INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnID=S.ReturnID
				INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID and SPT.ReturnId=Rp.ReturnID and SPT.PrdSlno=Rp.Slno
				INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=RP.PrdId
				WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
				and TaxCode IN('OutputCGST','CGST') and SI.VatGst='GST'	
				AND TaxAmt=0			
				UNION ALL
				SELECT  0 as TaxableAmount,0 as Integrated,0 as Central,-1*SUM(TaxAmt) as [State/UTTax] ,0 as CESS
				FROM ReturnHeader S (NOLOCK) 
				INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnID=S.ReturnID
				INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID and SPT.ReturnId=Rp.ReturnID and SPT.PrdSlno=Rp.Slno
				INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=RP.PrdId
				WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
				and TaxCode  IN('OutputSGST','OutputUTGST','SGST','UTGST') and SI.VatGst='GST'	
				AND TaxAmt=0				
				UNION ALL				
				SELECT SUM(TaxableAmount) as TaxableAmount,SUM(PPT.TaxAmount) as Integrated,0 as Central,0 as [State/UTTax] ,0 as CESS 
				FROM PurchaseReturn P (NOLOCK) 
				INNER JOIN PurchaseReturnProduct PRP ON PRP.PurRetId=P.PurRcptId
				INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId  and Prp.PurRetId=PPT.PurRetId and PRP.PrdSlNo=PPT.Prdslno
				INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=PRP.PrdId
				WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
				and TaxCode IN('InputIGST','IGST')
				AND PPT.TaxAmount=0
				UNION ALL
				SELECT SUM(TaxableAmount) as TaxableAmount,0 as Integrated,SUM(PPT.TaxAmount) as Central,0 as [State/UTTax]  ,0 as CESS
				FROM PurchaseReturn P (NOLOCK) 
				INNER JOIN PurchaseReturnProduct PRP ON PRP.PurRetId=P.PurRcptId
				INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId and Prp.PurRetId=PPT.PurRetId and PRP.PrdSlNo=PPT.Prdslno
				INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=PRP.PrdId
				WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
				and TaxCode IN('InputCGST','CGST')
				AND PPT.TaxAmount=0
				UNION ALL
				SELECT 0 as TaxableAmount,0 as Integrated,0 as Central,SUM(PPT.TaxAmount) as [State/UTTax] ,0 as CESS
				FROM PurchaseReturn P (NOLOCK) 
				INNER JOIN PurchaseReturnProduct PRP ON PRP.PurRetId=P.PurRcptId
				INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId  and Prp.PurRetId=PPT.PurRetId and PRP.PrdSlNo=PPT.Prdslno
				INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=PRP.PrdId
				WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
				and TaxCode IN('InputSGST','InputUTGST','SGST','UTGST')				
				AND PPT.TaxAmount=0
				UNION ALL
				SELECT 0 as TaxableAmount,0 as Integrated,0 as Central,0 as [State/UTTax] ,SUM(PPT.TaxAmount) as CESS
				FROM PurchaseReturn P (NOLOCK) 
				INNER JOIN PurchaseReturnProduct PRP ON PRP.PurRetId=P.PurRcptId
				INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId  and Prp.PurRetId=PPT.PurRetId and PRP.PrdSlNo=PPT.Prdslno
				INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
				INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
				INNER JOIN #ExemptAndZeroTax PT ON PT.PrdId=PRP.PrdId
				WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
				and TaxCode IN('InputGSTCess')
				AND PPT.TaxAmount=0			

			)X 
		END
		
		
		INSERT INTO RptFORMGSTR_3B_1([Nature Of Supplies],[Total Taxable],[Integrated],[Central],[State/UT Tax],[Cess],UsrId,[Group Name],GroupType)
		SELECT '(d) Inward supplies (liable to reverse charge)' as [Nature Of Supplies],ISNULL(SUM(TaxableAmount),0) as [Total Taxable Amount],
		ISNULL(SUM(Integrated),0) as Integrated,ISNULL(SUM(Central),0) as Central,ISNULL(SUM([State/UT Tax]),0) as [State/UT Tax],0 as CESS,
		@Pi_UsrId,'',2
		FROM(
			
			SELECT SUM(TaxableAmount) as  TaxableAmount ,SUM(TaxAmount) as [Integrated],0 as [Central], 0 as [State/UT Tax] 
			FROM ServiceInvoicehd S (NOLOCK)
			INNER JOIN #RetailerUnRegister R ON R.Rtrid=ServiceFromId
			INNER JOIN ServiceInvoiceTaxDetails SI (NOLOCK) ON SI.ServiceInvId=S.ServiceId 
			INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId=SI.TaxId
			WHERE ServiceInvFor=1 and TaxCode IN('OutputIGST','IGST')
			AND TaxAmount>0
			UNION ALL
			SELECT SUM(TaxableAmount) as  TaxableAmount ,0 as [Integrated],SUM(TaxAmount) as [Central],0 as [State/UT Tax] 
			FROM ServiceInvoicehd S (NOLOCK)
			INNER JOIN #RetailerUnRegister R ON R.Rtrid=ServiceFromId
			INNER JOIN ServiceInvoiceTaxDetails SI (NOLOCK) ON SI.ServiceInvId=S.ServiceId 
			INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId=SI.TaxId
			WHERE ServiceInvFor=1 and TaxCode IN('OutputCGST','CGST')
			AND TaxAmount>0
			UNION ALL
			SELECT 0 as  TaxableAmount ,0 as [Integrated],0 as [Central] ,SUM(TaxAmount) as [State/UT Tax] 
			FROM ServiceInvoicehd S (NOLOCK)
			INNER JOIN #RetailerUnRegister R ON R.Rtrid=ServiceFromId
			INNER JOIN ServiceInvoiceTaxDetails SI (NOLOCK) ON SI.ServiceInvId=S.ServiceId 
			INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId=SI.TaxId
			WHERE ServiceInvFor=1 and TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST')
			AND TaxAmount>0
		
			)X
		
		
		INSERT INTO RptFORMGSTR_3B_1([Nature Of Supplies],[Total Taxable],[Integrated],[Central],[State/UT Tax],[Cess],UsrId,[Group Name],GroupType)
		SELECT '(e) Non-GST Outward Supplies' as [Nature Of Supplies],0 as [Total Taxable Amount],
		0 as Integrated,0 as Central,0 as [State/UTTax],0 as CESS,
		@Pi_UsrId,'',2
		
		DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM RptFORMGSTR_3B_1
		WHERE UsrId=@Pi_UsrId
		SELECT * FROM RptFORMGSTR_3B_1 WHERE UsrId=@Pi_UsrId
	
END
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptFORMGSTR_3B_2_GST')
DROP PROCEDURE Proc_RptFORMGSTR_3B_2_GST
GO
--EXEC Proc_RptFORMGSTR_3B_2_GST 411,1--,0,'',0,0,0
--SELECT * FROM RptFORMGSTR_3B_2
CREATE PROCEDURE Proc_RptFORMGSTR_3B_2_GST
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT

	
)
AS
/************************************************
* PROCEDURE  : Proc_RptFORMGSTR_3B_2_GST
* PURPOSE    : To Generate Outward Supplies Tax Report
* CREATED BY : Murugan.R
* CREATED ON : 07/08/@Jcmyear
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON

		DECLARE @ErrNo	 			AS INT
		
	
	DECLARE @CmpId AS INT
	DECLARE @MonthStart INT
	DECLARE @JcmJc AS INT
	DECLARE @Jcmyear AS INT
	DECLARE @JcmFromId AS INT
	SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
	SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
	SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	
	SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
	
	--Service Invoice UnRegistered Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerUnRegister1
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue IN('UnRegistered')	
	
	--Composite Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerComposite
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Composition' and ColumnValue IN('Yes')
	
	
	SELECT DISTINCT RtrId,StateCode,TinFirst2Digit,StateName,TinFirst2Digit+'-'+StateName as StateAndTin
	INTO #RetailerState
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
	WHERE U.MasterId=2 and ColumnName='State Name' 
	
		
	DELETE A FROM #RetailerUnRegister1 A WHERE EXISTS(SELECT Rtrid FROM #RetailerComposite B WHERE A.RtrId=B.RtrId)

	
	TRUNCATE TABLE RptFORMGSTR_3B_2


	
	INSERT INTO RptFORMGSTR_3B_2([Nature Of Supplies],[Place of supply(State/UT)],[Total Taxable Value],[Amount of Integrated],UsrId,[Group Name],GroupType)
	SELECT 'Supplies made to UnRegistered person' as [Nature Of Supplies],[Place of supply(State/UT)] as [Place of supply(State/UT)],ISNULL(SUM(TaxableAmount),0) as [Total Taxable Amount],
	ISNULL(SUM([Integrated]),0) as [Integrated],
	@Pi_UsrId,'',2
	FROM(
			SELECT  ISNULL(StateAndTin,'') as  [Place of supply(State/UT)], SUM(TaxableAmount) as TaxableAmount,SUM(TaxAmount) as Integrated
			FROM SalesInvoice S (NOLOCK) 
			INNER JOIN #RetailerUnRegister1 R ON R.RtrId=S.Rtrid
			LEFT OUTER JOIN #RetailerState RS ON RS.RtrId=R.RtrId and RS.RtrId=S.Rtrid
			INNER JOIN SalesInvoiceProductTax SPT (NOLOCK)  ON S.Salid=SPT.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
			and TaxCode IN('OutputIGST','IGST') and VatGst='GST' and TaxAmount>0
			GROUP BY ISNULL(StateAndTin,'')
			
			UNION ALL
			---Sales Return
			SELECT  ISNULL(StateAndTin,'') as  [Place of supply(State/UT)],-1*SUM(TaxableAmt) as TaxableAmount,-1*SUM(TaxAmt) as Integrated
			FROM ReturnHeader S (NOLOCK) 
			INNER JOIN #RetailerUnRegister1 R ON R.RtrId=S.Rtrid
			LEFT OUTER JOIN #RetailerState RS ON RS.RtrId=R.RtrId and RS.RtrId=S.Rtrid
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
			and TaxCode IN('OutputIGST','IGST') and SI.VatGst='GST' and TaxAmt>0
			GROUP BY ISNULL(StateAndTin,'')
			
			
	)X GROUP BY [Place of supply(State/UT)]
	
	INSERT INTO RptFORMGSTR_3B_2([Nature Of Supplies],[Place of supply(State/UT)],[Total Taxable Value],[Amount of Integrated],UsrId,[Group Name],GroupType)
	SELECT 'Supplies made to composition taxable person' as [Nature Of Supplies],[Place of supply(State/UT)] as [Place of supply(State/UT)],
	ISNULL(SUM(TaxableAmount),0) as [Total Taxable Amount],
	ISNULL(SUM([Integrated]),0) as [Integrated],
	@Pi_UsrId,'',2
	FROM(
			SELECT  ISNULL(StateAndTin,'') as   [Place of supply(State/UT)], SUM(TaxableAmount) as TaxableAmount,SUM(TaxAmount) as Integrated
			FROM SalesInvoice S (NOLOCK) 
			INNER JOIN #RetailerComposite R ON R.RtrId=S.Rtrid
			LEFT OUTER JOIN #RetailerState RS ON RS.RtrId=R.RtrId and RS.RtrId=S.Rtrid
			INNER JOIN SalesInvoiceProductTax SPT (NOLOCK)  ON S.Salid=SPT.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
			and TaxCode IN('OutputIGST','IGST') and VatGst='GST' and TaxAmount>0
			GROUP BY ISNULL(StateAndTin,'')
						
			UNION ALL
			---Sales Return
			SELECT  ISNULL(StateAndTin,'') as   [Place of supply(State/UT)],-1*SUM(TaxableAmt) as TaxableAmount,-1*SUM(TaxAmt) as Integrated
			FROM ReturnHeader S (NOLOCK) 
			INNER JOIN #RetailerComposite R ON R.RtrId=S.Rtrid
			LEFT OUTER JOIN #RetailerState RS ON RS.RtrId=R.RtrId and RS.RtrId=S.Rtrid
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
			and TaxCode IN('OutputIGST','IGST') and SI.VatGst='GST' AND TaxAmt>0
			GROUP BY ISNULL(StateAndTin,'')
			
			
	)X 
	GROUP BY [Place of supply(State/UT)]
	
	IF NOT EXISTS(SELECT 'X' FROM RptFORMGSTR_3B_2 WHERE [Nature Of Supplies]='Supplies made to UnRegistered person')
	BEGIN
		INSERT INTO RptFORMGSTR_3B_2([Nature Of Supplies],[Place of supply(State/UT)],[Total Taxable Value],[Amount of Integrated],UsrId,[Group Name],GroupType)
		SELECT 'Supplies made to UnRegistered person' as [Nature Of Supplies],'' as [Place of supply(State/UT)],0.00 as [Total Taxable Amount],
		0.00 as [Integrated],
		@Pi_UsrId,'',2
	END
	
	IF NOT EXISTS(SELECT 'X' FROM RptFORMGSTR_3B_2 WHERE [Nature Of Supplies]='Supplies made to composition taxable person')
	BEGIN
		INSERT INTO RptFORMGSTR_3B_2([Nature Of Supplies],[Place of supply(State/UT)],[Total Taxable Value],[Amount of Integrated],UsrId,[Group Name],GroupType)
		SELECT 'Supplies made to composition taxable person' as [Nature Of Supplies],'' as [Place of supply(State/UT)],0.00 as [Total Taxable Amount],
		0.00 as [Integrated],
		@Pi_UsrId,'',2
	END
	
	---Not Applicable 
	INSERT INTO RptFORMGSTR_3B_2([Nature Of Supplies],[Place of supply(State/UT)],[Total Taxable Value],[Amount of Integrated],UsrId,[Group Name],GroupType)
	SELECT 'Supplies made to UIN holders' as [Nature Of Supplies],'' as [Place of supply(State/UT)],0 as [Total Taxable Amount],
	0 as [Integrated],@Pi_UsrId,'',2
END
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptFORMGSTR_3B_3_GST')
DROP PROCEDURE Proc_RptFORMGSTR_3B_3_GST
GO
--EXEC Proc_RptFORMGSTR_3B_3_GST 411,1--,0,'',0,0,0
--SELECT * FROM RptFORMGSTR_3B_3
CREATE PROCEDURE Proc_RptFORMGSTR_3B_3_GST
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT
)
AS
/************************************************
* PROCEDURE  : Proc_RptFORMGSTR_3B_3_GST
* PURPOSE    : To Generate Outward Supplies Tax Report
* CREATED BY : Murugan.R
* CREATED ON : 07/08/@Jcmyear
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON

		DECLARE @ErrNo	 			AS INT
		
	
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
	
	--Service Invoice UnRegistered Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerUnRegister1
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue IN('UnRegistered')
	
	--Registered Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerRegister
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue IN('Registered')
	
	----Composite Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerComposite
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Composition' and ColumnValue IN('Yes')
	
	DELETE A FROM #RetailerUnRegister1 A WHERE EXISTS(SELECT Rtrid FROM #RetailerComposite B WHERE A.RtrId=B.RtrId)

	
		TRUNCATE TABLE RptFORMGSTR_3B_3
	

	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(A) ITC Available (Whether in full or part)' as Details,'' as [Integrated Tax],'' as [Central Tax],'' as [State/UT Tax],
	'' as Cess,@Pi_UsrId,'',2

	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(1) Import of goods' as Details,'0.00' as [Integrated Tax],'0.00' as [Central Tax],'0.00' as [State/UT Tax],
	'0.00' as Cess,@Pi_UsrId,'',2
	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(2) Import of Services' as Details,'0.00' as [Integrated Tax],'0.00' as [Central Tax],'0.00' as [State/UT Tax],
	'0.00' as Cess,@Pi_UsrId,'',2

	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	--SELECT '(3) Inward supplies liable to reverse charge(Other than 1 & 2 above)' as Details,0 as [Integrated Tax],0 as [Central Tax],0 as [State/UT Tax],
	--0 as Cess,@Pi_UsrId,'',2
	SELECT '(3) Inward supplies liable to reverse charge(Other than 1 & 2 above)' as Details,ISNULL(SUM(Integrated),0) as Integrated,
	ISNULL(SUM(Central),0) as Central,ISNULL(SUM([State/UT Tax]),0) as [State/UT Tax],0.00 as CESS,
	@Pi_UsrId,'',2
	FROM(
			
			SELECT
			CAST(ISNULL(CASE  WHEN TaxCode  IN ('OutputIGST','IGST') THEN SUM(TaxAmount) END,0) as Numeric(18,2)) as Integrated,			
			CAST(ISNULL(CASE  WHEN TaxCode IN ('OutputCGST','CGST') THEN SUM(TaxAmount) END,0) as Numeric(18,2))as Central,
			CAST(ISNULL(CASE  WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(TaxAmount) END,0) as Numeric(18,2)) as [State/UT Tax],  
			0 as CESS			
			FROM ServiceInvoicehd S (NOLOCK)
			INNER JOIN #RetailerUnRegister1 R ON R.Rtrid=ServiceFromId
			INNER JOIN ServiceInvoiceTaxDetails SI (NOLOCK) ON SI.ServiceInvId=S.ServiceId 
			INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId=SI.TaxId
			WHERE ServiceInvFor=1 and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST')
			and Month(ServiceInvDate)=@MonthStart and YEAR(ServiceInvDate)=@Jcmyear and TaxAmount>0
			GROUP BY TaxCode
		
			
		
		)X
	
	
	
	
	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(4) Inward supplies from ISD' as Details,0.00 as [Integrated Tax],0.00 as [Central Tax],0.00 as [State/UT Tax],
	0.00 as Cess,@Pi_UsrId,'',2


	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(5) All other ITC' as Details,ISNULL(SUM(Integrated),0) as Integrated,
	ISNULL(SUM(Central),0) as Central,ISNULL(SUM([State/UTTax]),0) as [State/UT Tax],ISNULL(SUM(CESS),0) as CESS,
	@Pi_UsrId,'',2
	FROM(
	
			---Sales Return
			SELECT  
			CAST(ISNULL(CASE  WHEN TaxCode  IN ('OutputIGST','IGST') THEN SUM(TaxAmt) END,0) as Numeric(18,2)) as Integrated,			
			CAST(ISNULL(CASE  WHEN TaxCode IN ('OutputCGST','CGST') THEN SUM(TaxAmt) END,0) as Numeric(18,2)) as Central,
			CAST(ISNULL(CASE  WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(TaxAmt) END,0) as Numeric(18,2)) as [State/UTTax],  
			0 as CESS
			FROM ReturnHeader S (NOLOCK) 
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID
			INNER JOIN #RetailerRegister R ON R.RtrId=S.RtrId
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			WHERE Status=0 
			and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
			and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST') and S.GSTtag='DTVAT'
			and TaxAmt>0	
			GROUP BY TaxCode
						
			UNION ALL
			--Purchase Return
			SELECT 
			CAST(ISNULL(CASE  WHEN TaxCode IN ('InputIGST','IGST') THEN -1*SUM(PPT.TaxAmount) END,0) as Numeric(18,2)) as Integrated,			
			CAST(ISNULL(CASE  WHEN TaxCode IN ('InputCGST','CGST') THEN -1*SUM(PPT.TaxAmount) END,0) as Numeric(18,2)) as Central,
			CAST(ISNULL(CASE  WHEN TaxCode IN('InputSGST','InputUTGST','SGST','UTGST') THEN -1*SUM(PPT.TaxAmount) END,0) as Numeric(18,2)) as [State/UTTax],  
			CAST(ISNULL(CASE  WHEN TaxCode IN('InputGSTCess') THEN -1*SUM(PPT.TaxAmount) END,0) as Numeric(18,2)) as CESS			
			FROM PurchaseReturn P (NOLOCK) 
			INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId
			INNER JOIN PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
			WHERE P.Status=1 and Month(P.PurRetDate)=@MonthStart and Year(P.PurRetDate)=@Jcmyear
			and TaxCode  IN('InputIGST','InputCGST','InputSGST','InputUTGST','InputGSTCess','SGST','IGST','UTGST','CGST','CESS') and PR.VatGst='GST'
			and PPT.TaxAmount>0
			GROUP BY TaxCode
			
			UNION ALL
			--Purchase Receipt
			SELECT 
			CAST(ISNULL(CASE  WHEN TaxCode IN ('InputIGST','IGST') THEN SUM(PPT.TaxAmount) END,0) as Numeric(18,2)) as Integrated,			
			CAST(ISNULL(CASE  WHEN TaxCode IN ('InputCGST','CGST') THEN SUM(PPT.TaxAmount) END,0) as Numeric(18,2)) as Central,
			CAST(ISNULL(CASE  WHEN TaxCode IN('InputSGST','InputUTGST','SGST','UTGST') THEN SUM(PPT.TaxAmount) END,0) as Numeric(18,2)) as [State/UTTax],  
			CAST(ISNULL(CASE  WHEN TaxCode IN('InputGSTCess') THEN SUM(PPT.TaxAmount) END,0) as Numeric(18,2)) as CESS			
			FROM PurchaseReceipt P (NOLOCK) 
			INNER JOIN PurchaseReceiptProductTax PPT (NOLOCK) ON P.PurRcptId=PPT.PurRcptId			
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
			WHERE P.Status=1 and Month(P.GoodsRcvdDate)=@MonthStart and Year(P.GoodsRcvdDate)=@Jcmyear
			and TaxCode  IN('InputIGST','InputCGST','InputSGST','InputUTGST','InputGSTCess','SGST','IGST','UTGST','CGST','CESS') and P.VatGst='GST'
			and PPT.TaxAmount>0
			GROUP BY TaxCode
			
			
			UNION ALL
			SELECT
			CAST(ISNULL(CASE  WHEN TaxCode  IN ('OutputIGST','IGST') THEN SUM(TaxAmount) END,0) as Numeric(18,2)) as Integrated,			
			CAST(ISNULL(CASE  WHEN TaxCode IN ('OutputCGST','CGST') THEN SUM(TaxAmount) END,0) as Numeric(18,2))as Central,
			CAST(ISNULL(CASE  WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(TaxAmount) END,0) as Numeric(18,2)) as [State/UT Tax],  
			0 as CESS			
			FROM ServiceInvoicehd S (NOLOCK)
			INNER JOIN #RetailerRegister R ON R.Rtrid=ServiceFromId
			INNER JOIN ServiceInvoiceTaxDetails SI (NOLOCK) ON SI.ServiceInvId=S.ServiceId 
			INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId=SI.TaxId
			WHERE ServiceInvFor=1 and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST')
			and Month(ServiceInvDate)=@MonthStart and YEAR(ServiceInvDate)=@Jcmyear
			and TaxAmount>0
			GROUP BY TaxCode
			
					
	
	)X
	
	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(B) ITC Reversed' as Details,'' as [Integrated Tax],'' as [Central Tax],'' as [State/UT Tax],
	'' as Cess,@Pi_UsrId,'',2
	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(1) As per rules 42 & 43 of CGST rules' as Details,0.00 as [Integrated Tax],0.00 as CentralTax,0.00 as [State/UT Tax],
	0.00 as Cess,@Pi_UsrId,'',2
	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(2) Others' as Details,0.00 as [Integrated Tax],0.00 as [Central Tax],0.00 as [State/UT Tax],
	0.00 as Cess,@Pi_UsrId,'',2

	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(C) Net ITC Available (A)-(B)' as Details,	
	SUM(CAST([Integrated Tax] as Numeric(18,2))) as [Integrated Tax],SUM(CAST([Central Tax] as Numeric(18,2))) as [Central Tax],
	SUM(CAST([State/UT Tax] as Numeric(18,2))) as  [State/UT Tax],
	SUM(CAST(Cess as Numeric(18,2))) as Cess,@Pi_UsrId,'',2
	FROM RptFORMGSTR_3B_3 WHERE  Details IN('(5) All other ITC','(3) Inward supplies liable to reverse charge(Other than 1 & 2 above)')

	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(D) Ineligible ITC' as Details,'' as [Integrated Tax],'' as [Central Tax],'' as [State/UT Tax],
	'' as Cess,@Pi_UsrId,'',2
	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(1) As per Section 17(5)' as Details,0.00 as [Integrated Tax],0.00 as [Central Tax],0.00 as [State/UT Tax],
	0.00 as Cess,@Pi_UsrId,'',2
	--Not Applicable
	INSERT INTO RptFORMGSTR_3B_3(Details,[Integrated Tax],[Central Tax],[State/UT Tax],Cess,UsrId,[Group Name],GroupType)
	SELECT '(2) Others' as Details,0.00 as [Integrated Tax],0.00 as [Central Tax],0.00 as [State/UT Tax],
	0.00 as Cess,@Pi_UsrId,'',2
			
END
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptFORMGSTR_3B_4_GST')
DROP PROCEDURE Proc_RptFORMGSTR_3B_4_GST
GO
--EXEC Proc_RptFORMGSTR_3B_4_GST 411,1--,0,'',0,0,0
--SELECT * FROM RptFORMGSTR_3B_4
CREATE PROCEDURE Proc_RptFORMGSTR_3B_4_GST
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT
		
)
AS
/************************************************
* PROCEDURE  : Proc_RptFORMGSTR_3B_4_GST
* PURPOSE    : To Generate Outward Supplies Tax Report
* CREATED BY : Murugan.R
* CREATED ON : 07/08/@Jcmyear
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON

		DECLARE @ErrNo	 			AS INT
		
		DECLARE @PrdBatTaxGrp AS INT
		DECLARE @RtrTaxGrp1 AS INT
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT 
		DECLARE @MaxSlno   INT
		DECLARE @MinSlno   INT
		DECLARE @Prdid INT
		SET @MinSlno=1
	
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
	CREATE TABLE #ProductLst
		(
			Slno INT IDENTITY(1,1),	
			TaxSeqId INT,	
			Prdid INT,
			RtrId INT
		)	
		
		CREATE TABLE #ProductZeroTax(
		TaxGroupId [int] NULL,
		[TaxPercentage] [numeric](18, 5) NULL
		) 
		
			
		
		DECLARE @TaxSettingDet TABLE       
		(      
		TaxSlab   INT,      
		ColNo   INT,      
		SlNo   INT,      
		BillSeqId  INT,      
		TaxSeqId  INT,      
		ColType   INT,       
		ColId   INT,      
		ColVal   NUMERIC(38,2)      
		) 
		CREATE TABLE #TempProductTax
		(
			Prdid INT,
			TaxId INT,
			TaxSlabId INT,
			TaxPercentage Numeric(5,2),
			TaxAmount Numeric (18,5)
		)
	   
		SELECT @RtrTaxGrp=TaxGroupId FROM TaxGroupSetting (NOLOCK) WHERE RtrGroup='RTRINTRA'
	   
		SELECT * INTO #RtrGroup FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp 
		and CONVERT(DATETIME,CONVERT(VARCHAR(10),EffectiveFrom,121),121)<=CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)
		
		INSERT INTO #ProductLst (TaxSeqId,Prdid,RtrId)
		SELECT Max(A.TaxSeqId),A.Prdid,A.RtrId		
		FROM #RtrGroup A INNER JOIN TaxSettingMaster B ON A.RtrId=B.RtrId and A.Prdid=B.Prdid
		GROUP BY A.Prdid,A.RtrId

	    SELECT @MaxSlno=MAX(Slno) FROM #ProductLst
	    WHILE @MinSlno<=@MaxSlno
	    BEGIN
				
				DELETE FROM @TaxSettingDet	
				SELECT @PrdBatTaxGrp=Prdid, @RtrTaxGrp=RtrId FROM  #ProductLst WHERE Slno=@MinSlno
				--To Take the Batch TaxGroup Id      
								
				SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
				
						
				INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
				SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
				FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
				TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
				AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
				WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
				AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
				RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp
				and CONVERT(DATETIME,CONVERT(VARCHAR(10),EffectiveFrom,121),121)<=CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)
				)  
			
				SET @MRP=1
				TRUNCATE TABLE #TempProductTax
				DECLARE  CurTax CURSOR FOR      
					SELECT DISTINCT TaxSlab FROM @TaxSettingDet      
				OPEN CurTax        
				FETCH NEXT FROM CurTax INTO @TaxSlab      
				WHILE @@FETCH_STATUS = 0        
				BEGIN      
				SET @TaxableAmount = 0      
				--To Filter the Records Which Has Tax Percentage (>=0)      
				IF EXISTS (SELECT * FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId = 0 and ColVal >= 0)      
				BEGIN      
				--To Get the Tax Percentage for the selected slab      
				SELECT @TaxPer = ColVal FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId = 0      
				--To Get the TaxId for the selected slab      
				SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId > 0      
				SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP 
				--To Get the Parent Taxable Amount for the Tax Slab      
				SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM #TempProductTax A      
				INNER JOIN @TaxSettingDet B ON A.TaxId = B.ColVal and  
				B.ColType = 3 AND B.TaxSlab = @TaxSlab 
				If @ParTaxableAmount>0
				BEGIN
					Set @TaxableAmount=@ParTaxableAmount
				END 
				ELSE
				BEGIN
					Set @TaxableAmount = @TaxableAmount
				END    
				    
				INSERT INTO #TempProductTax (PrdId,TaxId,TaxSlabId,TaxPercentage,      
				TaxAmount)      
				SELECT @PrdBatTaxGrp,@TaxId,@TaxSlab,@TaxPer,      
				cast(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
				 
				  
				END      
				FETCH NEXT FROM CurTax INTO @TaxSlab      
				END        
				CLOSE CurTax        
				DEALLOCATE CurTax      
				SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
				FROM #TempProductTax WHERE Prdid=@PrdBatTaxGrp
									
				INSERT INTO #ProductZeroTax(TaxGroupId,TaxPercentage)
				SELECT @PrdBatTaxGrp,@TaxPercentage
				
				SET @MinSlno=@MinSlno+1	
	END	
	
	DELETE FROM #ProductZeroTax WHERE TaxPercentage>0
	
	SELECT DISTINCT B.PrdId INTO #ProductZeroTax1 
	FROM  #ProductZeroTax A INNER JOIN Product B ON A.TaxGroupId=B.TaxGroupId
	
	---EXEMPTED PRODUCT
	SELECT DISTINCT P.Prdid 
	INTO #ExemptProduct
	FROM UdcHD A (NOLOCK)
	INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
	INNER JOIN UdcDetails C (NOLOCK) ON C.MasterId=B.MasterId and C.MasterId=A.MasterId
	and C.UdcMasterId=B.UdcMasterId 
	INNER JOIN Product P (NOLOCK) ON P.PrdId=C.MasterRecordId
	WHERE A.MasterName='Product Master' and B.ColumnName='Exempt Product'
	and ColumnValue='Yes'
	
	SELECT DISTINCT PRDID INTO #ExemptAndZeroTax FROM(
	SELECT [PrdId] FROM #ProductZeroTax1
	UNION 
	SELECT PrdId FROM #ExemptProduct
	)X
	----Service Invoice UnRegistered Retailer
	--SELECT DISTINCT RtrId
	--INTO #RetailerComposite
	--FROM UDCHD U 
	--INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	--INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	--INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	--WHERE U.MasterId=2 and ColumnName='Composition' and ColumnValue IN('Yes')
	
	--Registered Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerRegister
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue IN('Registered')

	
	TRUNCATE TABLE RptFORMGSTR_3B_4





	INSERT INTO RptFORMGSTR_3B_4([Nature Of Supplies],[Inter-State Supplies],[Intra-state Supplies],UsrId,[Group Name],GroupType)
	SELECT 'From a Supplier under composition scheme,Exempted and Nil rated' as [Nature Of Supplies],
	ISNULL(SUM([Inter-State Supplies]),0) as [Inter-State Supplies],
	ISNULL(SUM([Intra-state Supplies]),0) as [Intra-state Supplies],
	@Pi_UsrId,'',2
	FROM
	(
			SELECT 
			CAST(ISNULL(CASE  WHEN TaxCode IN ('InputIGST','IGST') THEN SUM(PPT.TaxableAmount) END,0) as Numeric(18,2)) as [Inter-State Supplies],			
			CAST(ISNULL(CASE  WHEN TaxCode IN('InputCGST','CGST') THEN SUM(PPT.TaxableAmount) END,0) as Numeric(18,2)) as [Intra-state Supplies]
			FROM PurchaseReceipt P (NOLOCK) 
			INNER JOIN PurchaseReceiptProduct PR (NOLOCK) ON P.PurRcptId=PR.PurRcptId
			INNER JOIN #ExemptAndZeroTax ET ON ET.PrdId=PR.PrdId
			INNER JOIN PurchaseReceiptProductTax PPT (NOLOCK) ON P.PurRcptId=PPT.PurRcptId	 and PR.PurRcptId=PPT.PurRcptId	
			and PPT.PrdSlNo=PR.PrdSlNo	
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
			WHERE P.Status=1 and Month(P.GoodsRcvdDate)=@MonthStart and Year(P.GoodsRcvdDate)=@Jcmyear
			and TaxCode  IN('InputIGST','InputCGST','IGST','CGST') and P.VatGst='GST' and PPT.TaxAmount=0
			GROUP BY TaxCode
			UNION ALL
			SELECT 
			CAST(ISNULL(CASE  WHEN TaxCode IN ('InputIGST','IGST') THEN -1*SUM(PPT.TaxableAmount) END,0) as Numeric(18,2)) as [Inter-State Supplies],			
			CAST(ISNULL(CASE  WHEN TaxCode IN('InputCGST','CGST') THEN -1*SUM(PPT.TaxableAmount) END,0) as Numeric(18,2)) as [Intra-state Supplies]
			FROM PurchaseReturn P (NOLOCK) 
			INNER JOIN PurchaseReturnProduct PR (NOLOCK) ON P.PurRetId=PR.PurRetId
			INNER JOIN #ExemptAndZeroTax ET ON ET.PrdId=PR.PrdId
			INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId	 and PR.PurRetId=PPT.PurRetId	
			and PPT.PrdSlNo=PR.PrdSlNo	
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
			WHERE P.Status=1 and Month(P.PurRetDate)=@MonthStart and Year(P.PurRetDate)=@Jcmyear
			and TaxCode  IN('InputIGST','InputCGST','IGST','CGST') and P.VatGst='GST' and PPT.TaxAmount=0
			GROUP BY TaxCode						
			UNION ALL			
			SELECT  
			CAST(ISNULL(CASE  WHEN TaxCode  IN ('OutputIGST','IGST') THEN SUM(SPT.TaxableAmt) END,0) as Numeric(18,2)) as [Inter-State Supplies],			
			CAST(ISNULL(CASE  WHEN TaxCode IN('OutputCGST','CGST') THEN SUM(SPT.TaxableAmt) END,0) as Numeric(18,2)) as [Intra-state Supplies]
			FROM ReturnHeader S (NOLOCK) 
			INNER JOIN #RetailerRegister RC ON RC.RtrId=S.RtrId
			INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnID=S.ReturnID
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID and SPT.ReturnId=Rp.ReturnID and SPT.PrdSlno=Rp.Slno
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
			INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
			INNER JOIN #ExemptAndZeroTax ET ON ET.PrdId=RP.PrdId
			WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
			and TaxCode IN('OutputIGST','OutputCGST','IGST','CGST') and SI.VatGst='GST' AND SPT.TaxAmt=0
			GROUP BY TaxCode	
	)X

	INSERT INTO RptFORMGSTR_3B_4([Nature Of Supplies],[Inter-State Supplies],[Intra-state Supplies],UsrId,[Group Name],GroupType)
	SELECT 'Non GST Supply' as [Nature Of Supplies],0.00 as [Inter-State Supplies],0.00 as [Intra-state Supplies],
	@Pi_UsrId,'',2

		
END
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptFORMGSTR_3B_5_GST')
DROP PROCEDURE Proc_RptFORMGSTR_3B_5_GST
GO
--EXEC Proc_RptFORMGSTR_3B_5_GST 411,1--,0,'',0,0,0
--SELECT * FROM RptFORMGSTR_3B_5
CREATE PROCEDURE Proc_RptFORMGSTR_3B_5_GST
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT	
)
AS
/************************************************
* PROCEDURE  : Proc_RptFORMGSTR_3B_5_GST
* PURPOSE    : To Generate Outward Supplies Tax Report
* CREATED BY : Murugan.R
* CREATED ON : 07/08/@Jcmyear
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON

	DECLARE @ErrNo	 			AS INT


	DECLARE @CmpId AS INT
	DECLARE @MonthStart INT
	DECLARE @JcmJc AS INT
	DECLARE @Jcmyear AS INT
	DECLARE @JcmFromId AS INT
	SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
	SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
	SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	
	SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
	
	--Service Invoice UnRegistered Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerUnRegister1
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue IN('UnRegistered')
	
	
	----Composite Retailer
	--SELECT DISTINCT RtrId
	--INTO #RetailerComposite
	--FROM UDCHD U 
	--INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	--INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	--INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	--WHERE U.MasterId=2 and ColumnName='Composition' and ColumnValue IN('Yes')
	
	--DELETE A FROM #RetailerUnRegister1 A WHERE EXISTS(SELECT Rtrid FROM #RetailerComposite B WHERE A.RtrId=B.RtrId)

	
	TRUNCATE TABLE RptFORMGSTR_3B_5


	CREATE TABLE #RptFORMGSTR_3B
	(	
		[Integrated] Numeric(32,2),
		Central	Numeric(32,2),
		[State/UT Tax] Numeric(32,2),
		[Cess] Numeric(32,2)
	)



	INSERT INTO RptFORMGSTR_3B_5(Description,TaxPayable,[ITC Integrate],[ITC Central],[ITC State/UT],[ITC Cess],[Tax Paid],[Tax/Cess paid],Interest,[Late Fee],UsrId,[Group Name],GroupType)
	SELECT 'Integrated Tax' as Description,0 as TaxPayable,0 as [ITC Integrate],0 as [ITC Central],0 as [ITC State/UT],0 as [ITC Cess],0 as [Tax Paid],0 as [Tax/Cess paid],0 as Interest,0 as [Late Fee]
	,@Pi_UsrId,'',2

	INSERT INTO RptFORMGSTR_3B_5(Description,TaxPayable,[ITC Integrate],[ITC Central],[ITC State/UT],[ITC Cess],[Tax Paid],[Tax/Cess paid],Interest,[Late Fee],UsrId,[Group Name],GroupType)
	SELECT 'Central Tax' as Description,0 as TaxPayable,0 as [ITC Integrate],0 as [ITC Central],0 as [ITC State/UT],0 as [ITC Cess],0 as [Tax Paid],0 as [Tax/Cess paid],0 as Interest,0 as [Late Fee]
	,@Pi_UsrId,'',2
	
	INSERT INTO RptFORMGSTR_3B_5(Description,TaxPayable,[ITC Integrate],[ITC Central],[ITC State/UT],[ITC Cess],[Tax Paid],[Tax/Cess paid],Interest,[Late Fee],UsrId,[Group Name],GroupType)
	SELECT 'State/UT Tax' as Description,0 as TaxPayable,0 as [ITC Integrate],0 as [ITC Central],0 as [ITC State/UT],0 as [ITC Cess],0 as [Tax Paid],0 as [Tax/Cess paid],0 as Interest,0 as [Late Fee]
	,@Pi_UsrId,'',2

	INSERT INTO RptFORMGSTR_3B_5(Description,TaxPayable,[ITC Integrate],[ITC Central],[ITC State/UT],[ITC Cess],[Tax Paid],[Tax/Cess paid],Interest,[Late Fee],UsrId,[Group Name],GroupType)
	SELECT 'Cess' as Description,0 as TaxPayable,0 as [ITC Integrate],0 as [ITC Central],0 as [ITC State/UT],0 as [ITC Cess],0 as [Tax Paid],0 as [Tax/Cess paid],0 as Interest,0 as [Late Fee]
	,@Pi_UsrId,'',2
	
	
	--SELECT PurRcptId  INTO #PurchaseReceipt FROM PurchaseReceipt (NOLOCK) WHERE GoodsRcvdDate Between '2017-01-01' and '2017-06-30' and Status=1
	
	--INSERT INTO #RptFORMGSTR_3B(Integrated,Central,[State/UT Tax],[Cess])
	--SELECT ISNULL(SUM(Integrated),0) as Integrated,ISNULL(SUM(Central),0) as Central,
	--ISNULL(SUM([State/UTTax]),0) as [State/UTTax],ISNULL(SUM(CESS),0) as CESS
	--FROM(
	--		--Sales
	--		SELECT  
	--		ISNULL(CASE WHEN TaxCode  IN ('OutputIGST','IGST') THEN SUM(TaxAmount) END,0)  as Integrated,
	--		ISNULL(CASE WHEN TAXCODE ='OutputCGST' THEN SUM(TaxAmount) END,0) AS Central,
	--		ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(TaxAmount) END,0) as [State/UTTax], 
	--		0 as CESS
	--		FROM SalesInvoice S (NOLOCK) 
	--		INNER JOIN SalesInvoiceProductTax SPT (NOLOCK)  ON S.Salid=SPT.SalId
	--		INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
	--		WHERE DlvSts>3 and MONTH(SalInvDate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
	--		and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST') and VatGst='GST'
	--		GROUP BY TAXCODE
	--		HAVING SUM(TaxAmount)>0
	--		UNION ALL
	--		---Sales Return
	--		SELECT  
	--		ISNULL(CASE WHEN TaxCode  IN ('OutputIGST','IGST') THEN -1*SUM(TaxAmt) END,0)  as Integrated,
	--		ISNULL(CASE WHEN TAXCODE ='OutputCGST' THEN -1*SUM(TaxAmt) END,0) AS Central,
	--		ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN -1*SUM(TaxAmt) END,0) as [State/UTTax], 
	--		0 as CESS		
	--		FROM ReturnHeader S (NOLOCK) 
	--		INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID
	--		INNER JOIN SalesInvoice SI (NOLOCK) ON SI.Salid=S.SalId
	--		INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=SPT.TaxId
	--		WHERE Status=0 and MONTH(ReturnDate)=@MonthStart and Year(ReturnDate)=@Jcmyear 
	--		and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST') and SI.VatGst='GST'
	--		GROUP BY TAXCODE
	--		HAVING SUM(TaxAmt)>0
	--		--Purchase Return
	--		UNION ALL
	--		SELECT
	--		ISNULL(CASE WHEN TaxCode IN ('InputIGST','IGST') THEN SUM(PPT.TaxAmount) END,0)  as Integrated,
	--		ISNULL(CASE WHEN TAXCODE ='InputCGST' THEN SUM(PPT.TaxAmount) END,0) AS Central,
	--		ISNULL(CASE WHEN TaxCode IN('InputSGST','InputUTGST','SGST','UTGST') THEN SUM(PPT.TaxAmount) END,0) as [State/UTTax], 
	--		ISNULL(CASE WHEN TAXCODE IN('InputGSTCess') THEN SUM(PPT.TaxAmount) END,0) as CESS			
	--		FROM PurchaseReturn P (NOLOCK) 
	--		INNER JOIN PurchaseReturnProductTax PPT (NOLOCK) ON P.PurRetId=PPT.PurRetId
	--		INNER JOIN #PurchaseReceipt PR (NOLOCK) ON PR.PurRcptId=P.PurRcptId
	--		INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=PPT.TaxId
	--		WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
	--		and TaxCode IN('InputIGST','InputCGST','InputSGST','InputUTGST','InputGSTCess')
	--		GROUP BY TAXCODE
	--		HAVING SUM(PPT.TaxAmount)>0
	--		UNION ALL
	--		SELECT 
	--		ISNULL(CASE WHEN TaxCode  IN ('OutputIGST','IGST') THEN SUM(TaxAmount) END,0)  as Integrated,
	--		ISNULL(CASE WHEN TAXCODE ='OutputCGST' THEN SUM(TaxAmount) END,0) AS Central,
	--		ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(TaxAmount) END,0) as [State/UTTax], 
	--		0 as CESS
	--		FROM ServiceInvoicehd S (NOLOCK)
	--		INNER JOIN #RetailerUnRegister1 R ON R.Rtrid=ServiceFromId
	--		INNER JOIN ServiceInvoiceTaxDetails SI (NOLOCK) ON SI.ServiceInvId=S.ServiceId 
	--		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId=SI.TaxId
	--		WHERE ServiceInvFor=1 and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST')
	--		GROUP BY TAXCODE
	--		HAVING SUM(TaxAmount)>0			
			
	--)X 
	
	--UPDATE RptFORMGSTR_3B_5 SET TaxPayable= (SELECT SUM(Integrated) FROM #RptFORMGSTR_3B)
	--WHERE  Description='Integrated Tax'
	
	--UPDATE RptFORMGSTR_3B_5 SET TaxPayable= (SELECT SUM(Central) FROM #RptFORMGSTR_3B)
	--WHERE  Description='Central Tax'
	
	--UPDATE RptFORMGSTR_3B_5 SET TaxPayable= (SELECT SUM([State/UT Tax]) FROM #RptFORMGSTR_3B)
	--WHERE  Description='State/UT Tax'
	
	--UPDATE RptFORMGSTR_3B_5 SET TaxPayable= (SELECT SUM(CESS) FROM #RptFORMGSTR_3B)
	--WHERE  Description='Cess'
		

END
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptFORMGSTR_3B_6_GST')
DROP PROCEDURE Proc_RptFORMGSTR_3B_6_GST
GO
--EXEC Proc_RptFORMGSTR_3B_6_GST 411,1--,0,'',0,0,0
--SELECT * FROM RptFORMGSTR_3B
CREATE PROCEDURE Proc_RptFORMGSTR_3B_6_GST
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT	
)
AS
/************************************************
* PROCEDURE  : Proc_RptFORMGSTR_3B_6_GST
* PURPOSE    : To Generate Outward Supplies Tax Report
* CREATED BY : Murugan.R
* CREATED ON : 07/08/@Jcmyear
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON

		DECLARE @ErrNo	 			AS INT


		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc

		TRUNCATE TABLE RptFORMGSTR_3B_6

		INSERT INTO RptFORMGSTR_3B_6(Details,IntegratedTax,CentralTax,[State_UT Tax],UsrId,[Group Name],GroupType)
		SELECT 'TDS' as Details,0 as IntegratedTax,0 as CentralTax,0 as [State_UT Tax]
		,@Pi_UsrId,'',2

		INSERT INTO RptFORMGSTR_3B_6(Details,IntegratedTax,CentralTax,[State_UT Tax],UsrId,[Group Name],GroupType)
		SELECT 'TCS' as Details,0 as IntegratedTax,0 as CentralTax,0 as [State_UT Tax]
		,@Pi_UsrId,'',2

		
END
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptFORMGSTR_3B_GST')
DROP PROCEDURE Proc_RptFORMGSTR_3B_GST
GO
--EXEC Proc_RptFORMGSTR_3B_GST 411,1,0,'',0,0,0
--SELECT * FROM RptFORMGSTR_3B
CREATE PROCEDURE Proc_RptFORMGSTR_3B_GST
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
/************************************************
* PROCEDURE  : Proc_RptFORMGSTR_3B_GST
* PURPOSE    : To Generate Outward Supplies Tax Report
* CREATED BY : Murugan.R
* CREATED ON : 07/08/@Jcmyear
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON

		DECLARE @ErrNo	 			AS INT
		
		EXEC Proc_RptFORMGSTR_3B_1_GST @Pi_RptId,@Pi_UsrId
		EXEC Proc_RptFORMGSTR_3B_2_GST @Pi_RptId,@Pi_UsrId
		EXEC Proc_RptFORMGSTR_3B_3_GST @Pi_RptId,@Pi_UsrId
		EXEC Proc_RptFORMGSTR_3B_4_GST @Pi_RptId,@Pi_UsrId
		EXEC Proc_RptFORMGSTR_3B_5_GST @Pi_RptId,@Pi_UsrId
		EXEC Proc_RptFORMGSTR_3B_6_GST @Pi_RptId,@Pi_UsrId
		
		SELECT * FROM RptFORMGSTR_3B_1 WHERE UsrId=@Pi_UsrId
END
GO
--B3 END
----Kishore Till Here
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Fn_ReturnGSTRColCntAndColName' AND XTYPE IN ('TF','FN'))
DROP FUNCTION Fn_ReturnGSTRColCntAndColName
GO
--SELECT * FROM DBO.Fn_ReturnGSTRColCntAndColName(413,1) order by Tblid
CREATE FUNCTION [Fn_ReturnGSTRColCntAndColName](@iRptId AS INT,@UsrId AS INT)        
RETURNS @pTempTbl TABLE         
 (        
	ColId  INT IDENTITY(1,1),
	ColCnt INT,
	tblId INT,
	HeaderId TINYINT,
	HeaderCaption Varchar(100),
	FieldName Varchar(100),
	RowCounts INT,
	tblCnt INT,
	ColCntTblWise INT,
	RptTblName Varchar(100),
	HeaderText Varchar(200),
	RoundOff INT ,
	ColNumber INT   
 )        
AS         
 BEGIN    
		DECLARE @ColCnt AS INT
		DECLARE @RowCnt AS INT		 
	   
		/*
			Table having Maximum Columns Set Max Col
		*/	
	   
	IF @iRptId=411
	BEGIN
		SET @ColCnt=7
	
		SELECT @RowCnt=COUNT(*)+1 FROM RptFORMGSTR_3B_1 (NOLOCK) WHERE UsrId=@UsrId
		
		INSERT INTO @pTempTbl(ColCnt,tblId,HeaderId,HeaderCaption,FieldName,RowCounts,tblCnt,ColCntTblWise,RptTblName,HeaderText,RoundOff,Colnumber)
		SELECT @ColCnt,1,1,SS.Name,QuoteName(SS.Name),ISNULL(@RowCnt,1),6,7, 'RptFORMGSTR_3B_1',
		'3.1 Details of Outward Supplies and inward supplies liable to reverse charge',
		CASE WHEN SS.Xtype=108 THEN 2 ELSE 0 END as RoundOff ,SS.colid 
		FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.ID 
		WHERE S.XTYPE='U' and S.name='RptFORMGSTR_3B_1' and SS.Name NOT IN('UsrId','Group Name','GroupType')
		ORDER BY colid
		SELECT @RowCnt=COUNT(*)+1 FROM RptFORMGSTR_3B_2 (NOLOCK) WHERE UsrId=@UsrId
		
		INSERT INTO @pTempTbl(ColCnt,tblId,HeaderId,HeaderCaption,FieldName,RowCounts,tblCnt,ColCntTblWise,RptTblName,HeaderText,RoundOff,Colnumber)
		SELECT @ColCnt,2,1,SS.Name,QuoteName(SS.Name),ISNULL(@RowCnt,1),6,5,'RptFORMGSTR_3B_2',
		'3.2 Of the supplies Shown in 3.1(a) above, details of inter-state supplies made to unregistered person, composition taxable person and UIN holders' ,
		CASE WHEN SS.Xtype=108 THEN 2 ELSE 0 END as RoundOff ,SS.colid
		FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.ID 
		WHERE S.XTYPE='U' and S.name='RptFORMGSTR_3B_2' and SS.Name NOT IN('UsrId','Group Name','GroupType')
		ORDER BY colid
		SELECT @RowCnt=COUNT(*)+1 FROM RptFORMGSTR_3B_3 (NOLOCK) WHERE UsrId=@UsrId
		
		INSERT INTO @pTempTbl(ColCnt,tblId,HeaderId,HeaderCaption,FieldName,RowCounts,tblCnt,ColCntTblWise,RptTblName,HeaderText,RoundOff,Colnumber)
		SELECT @ColCnt,3,1,SS.Name,QuoteName(SS.Name),ISNULL(@RowCnt,1),6,6,'RptFORMGSTR_3B_3',
		'4 Eligible ITC',
		CASE WHEN SS.Xtype=108 THEN 2 ELSE 0 END as RoundOff ,SS.colid
		FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.ID 
		WHERE S.XTYPE='U' and S.name='RptFORMGSTR_3B_3' and SS.Name NOT IN('UsrId','Group Name','GroupType')
		ORDER BY colid
		
		SELECT @RowCnt=COUNT(*)+1 FROM RptFORMGSTR_3B_4 (NOLOCK) WHERE UsrId=@UsrId
		
		INSERT INTO @pTempTbl(ColCnt,tblId,HeaderId,HeaderCaption,FieldName,RowCounts,tblCnt,ColCntTblWise,RptTblName,HeaderText,RoundOff,Colnumber)
		SELECT @ColCnt,4,1,SS.Name,QuoteName(SS.Name),ISNULL(@RowCnt,1),6,4,'RptFORMGSTR_3B_4',
		'5 Values of exempt, nill-dated and non-GST inward supplies',
		CASE WHEN SS.Xtype=108 THEN 2 ELSE 0 END as RoundOff ,SS.colid
		FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.ID 
		WHERE S.XTYPE='U' and S.name='RptFORMGSTR_3B_4' and SS.Name NOT IN('UsrId','Group Name','GroupType')
		ORDER BY colid
		SELECT @RowCnt=COUNT(*)+1 FROM RptFORMGSTR_3B_5 (NOLOCK) WHERE UsrId=@UsrId
		
		INSERT INTO @pTempTbl(ColCnt,tblId,HeaderId,HeaderCaption,FieldName,RowCounts,tblCnt,ColCntTblWise,RptTblName,HeaderText,RoundOff,Colnumber)
		SELECT @ColCnt,5,1,SS.Name,QuoteName(SS.Name),ISNULL(@RowCnt,1),6,11,'RptFORMGSTR_3B_5', 
		'6.1 Payment of tax',
		CASE WHEN SS.Xtype=108 THEN 2 ELSE 0 END as RoundOff ,SS.colid
		FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.ID 
		WHERE S.XTYPE='U' and S.name='RptFORMGSTR_3B_5' and SS.Name NOT IN('UsrId','Group Name','GroupType')
		ORDER BY colid
		SELECT @RowCnt=COUNT(*)+1 FROM RptFORMGSTR_3B_6 (NOLOCK) WHERE UsrId=@UsrId
		
		INSERT INTO @pTempTbl(ColCnt,tblId,HeaderId,HeaderCaption,FieldName,RowCounts,tblCnt,ColCntTblWise,RptTblName,HeaderText,RoundOff,Colnumber)
		SELECT @ColCnt,6,1,SS.Name,QuoteName(SS.Name),ISNULL(@RowCnt,1),6,5,'RptFORMGSTR_3B_6',
		'6.2 TDS/TCS Credit',
		CASE WHEN SS.Xtype=108 THEN 2 ELSE 0 END as RoundOff ,SS.colid
		FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.ID 
		WHERE S.XTYPE='U' and S.name='RptFORMGSTR_3B_6' and SS.Name NOT IN('UsrId','Group Name','GroupType')
		ORDER BY colid
	END
	
	IF @iRptId=413
	BEGIN
		SET @ColCnt=10
	
		SELECT @RowCnt=COUNT(*)+1 FROM RptGSTR_TRANS2_CGST (NOLOCK) WHERE UsrId=@UsrId
		
		INSERT INTO @pTempTbl(ColCnt,tblId,HeaderId,HeaderCaption,FieldName,RowCounts,tblCnt,ColCntTblWise,RptTblName,RoundOff,Colnumber)
		SELECT @ColCnt,1,1,SS.Name,QuoteName(SS.Name),ISNULL(@RowCnt,1),2,10, 'RptGSTR_TRANS2_CGST' ,CASE WHEN SS.Xtype=108 THEN 2 ELSE 0 END as RoundOff,SS.colid FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.ID 
		WHERE S.XTYPE='U' and S.name='RptGSTR_TRANS2_CGST' and SS.Name NOT IN('UsrId','Group Name','GroupType')
		ORDER BY colid
		
		SELECT @RowCnt=COUNT(*)+1 FROM RptGSTR_TRANS2_SGST (NOLOCK) WHERE UsrId=@UsrId
		
		INSERT INTO @pTempTbl(ColCnt,tblId,HeaderId,HeaderCaption,FieldName,RowCounts,tblCnt,ColCntTblWise,RptTblName,RoundOff,Colnumber)
		SELECT @ColCnt,2,1,SS.Name,QuoteName(SS.Name),ISNULL(@RowCnt,1),2,9,'RptGSTR_TRANS2_SGST',CASE WHEN SS.Xtype=108 THEN 2 ELSE 0 END as RoundOff,SS.colid  FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.ID 
		WHERE S.XTYPE='U' and S.name='RptGSTR_TRANS2_SGST' and SS.Name NOT IN('UsrId','Group Name','GroupType')
		ORDER BY colid 
			
	END	
 RETURN     
END
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Fn_ReturnExcelReportFilter' AND XTYPE IN('TF','FN'))
DROP FUNCTION Fn_ReturnExcelReportFilter
GO
--SELECT dbo.Fn_ReturnExcelReportFilter(411) as status
CREATE FUNCTION Fn_ReturnExcelReportFilter(@RptId AS INT,@RefType AS INT)
RETURNS INT
AS
BEGIN

DECLARE @ReturnVal AS INT
SET @ReturnVal=0
	
	IF @RefType=0
	BEGIN
		IF @RptId in (268 ,291 ,292,411,413,414,415,416,417,418,419,420,421,422,423)
		BEGIN
			SET @ReturnVal=1
		END
	END
	ELSE IF @RefType=1
	BEGIN
		IF @RptId in (411,413)
		BEGIN
			SET @ReturnVal=1
		END
		IF @RptId in (424)
		BEGIN
			SET @ReturnVal=2
		END				
	END	
RETURN @ReturnVal
END
GO
--Kishore Till
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='FN_ReturnRetailerUDCDetails' AND XTYPE='TF')
DROP FUNCTION FN_ReturnRetailerUDCDetails
GO
CREATE FUNCTION FN_ReturnRetailerUDCDetails()
RETURNS @RetailerUDC TABLE
(
	Rtrid			INT,
	RtrName			NVARCHAR(200),
	RtrCode			NVARCHAR(100),
	StateName		NVARCHAR(200),
	StateCode		VARCHAR(40),
	StateTinFirst2Digit NVARCHAR(20),
	RetailerType	INT,
	GSTIN			NVARCHAR(50),
	PanNumber		NVARCHAR(25),
	Composition		INT,
	RelatedParty	INT
)

AS
BEGIN
	INSERT INTO @RetailerUDC	
	SELECT Rtrid,RtrName,RtrCode,A.StateName,S.StateCode,S.TinFirst2Digit,RetailerType,GSTIN,PanNumber,Composition,RelatedParty
	FROM
	(
	SELECT Rtrid,RtrName,RtrCode,
	CASE ISNULL(A.ColumnValue,'') WHEN '' THEN '' ELSE A.ColumnValue END StateName,
	CASE ISNULL(F.ColumnValue,'') WHEN 'Registered' THEN 1 WHEN 'Unregistered' THEN 2 ELSE 0 END RetailerType,	
	CASE ISNULL(B.ColumnValue,'') WHEN '' THEN '' ELSE CASE WHEN LEN(B.ColumnValue)<10 THEN '' ELSE B.ColumnValue END END GSTIN,
	CASE ISNULL(C.ColumnValue,'') WHEN '' THEN '' ELSE C.ColumnValue END PanNumber,	 
	CASE ISNULL(D.ColumnValue,'') WHEN 'YES' THEN 1 WHEN 'NO' THEN 0 ELSE 0 END Composition,	 
	CASE ISNULL(E.ColumnValue,'') WHEN 'YES' THEN 1 WHEN 'NO' THEN 0 ELSE 0 END RelatedParty	 
	FROM Retailer R 
	LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
				AND U.MasterId=2 AND UPPER(ColumnName)='STATE NAME')A ON A.MasterRecordId=R.RtrId
	LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
				AND U.MasterId=2 AND ColumnName='Retailer Type')F ON F.MasterRecordId=R.RtrId
	LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
				AND U.MasterId=2 AND UPPER(ColumnName)='GSTIN')B ON B.MasterRecordId=R.RtrId
	LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
				AND U.MasterId=2 AND UPPER(ColumnName)='PAN NUMBER')C ON C.MasterRecordId=R.RtrId	
	LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
				AND U.MasterId=2 AND UPPER(ColumnName)='COMPOSITION')D ON D.MasterRecordId=R.RtrId	
	LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
				AND U.MasterId=2 AND UPPER(ColumnName)='RELATED PARTY')E ON E.MasterRecordId=R.RtrId
	)A
	LEFT OUTER JOIN StateMaster S ON S.StateName=A.StateName				
RETURN
END
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and GrpCode='FORMGSTR1B2B' and RptId=414
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'GSRT 410',414,'FORMGSTR1B2B','FORM GSTR1-B2B'
GO
DELETE FROM RptHeader WHERE RptId=414
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'FORMGSTR1B2B','FORM GSTR1-B2B',414,'FORM GSTR1-B2B','Proc_RptGSTR1_B2B','RptGSTR1_B2B','RptGSTR1_B2B.rpt',0
GO
DELETE FROM RptDetails where RPTID=414
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (414,1,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (414,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=414
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 414,208,1,'January' UNION
SELECT 414,208,2,'February' UNION
SELECT 414,208,3,'March' UNION
SELECT 414,208,4,'April' UNION
SELECT 414,208,5,'May' UNION
SELECT 414,208,6,'June' UNION
SELECT 414,208,7,'July' UNION
SELECT 414,208,8,'August' UNION
SELECT 414,208,9,'September' UNION
SELECT 414,208,10,'October' UNION
SELECT 414,208,11,'November' UNION
SELECT 414,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=414
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,414,'FORM GSTR1-B2B',1,'GSTIN/UIN of Recipient',50,1,0,1,1,'GSTIN/UIN ','of Recipient','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',2,'Recipient Code in application',50,1,0,1,1,'Recipient Code ','in application','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',3,'Recipient Name',50,1,0,1,1,'Recipient Name','','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',4,'Recipient Type',50,1,0,1,1,'Recipient Type','','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',5,'Kind of transaction',50,1,0,1,1,'Kind of ','transaction','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',6,'Invoice Number',50,1,0,1,1,'Invoice Number','','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',7,'Invoice date',20,1,0,1,1,'Invoice date','','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',8,'Invoice Value',20,1,0,2,3,'Invoice Value','','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',9,'Place Of Supply',30,1,0,1,1,'Place Of Supply','','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',10,'Reverse Charge',200,1,0,1,1,'Reverse','Charge','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',11,'Invoice Type',50,1,0,1,1,'Invoice Type','','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',12,'Identifier if Goods or Services',50,1,0,1,1,'Identifier if ','Goods or Services','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',13,'E-Commerce GSTIN',50,1,0,1,1,'E-Commerce','GSTIN','',0,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',14,'Rate',20,1,0,2,3,'Rate','','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',15,'Taxable Value',20,1,0,2,3,'Taxable','Value','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',16,'Cess Amount',20,1,0,2,3,'Cess','Amount','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',17,'IGST rate',20,1,0,2,3,'IGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',18,'IGST Amount',20,1,0,2,3,'IGST','Amount','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',19,'CGST rate',20,1,0,2,3,'CGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',20,'CGST amount',20,1,0,2,3,'CGST','Amount','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',21,'SGST/UTGST rate',20,1,0,2,3,'SGST/UTGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,414,'FORM GSTR1-B2B',22,'SGST/UTGST amount',20,1,0,2,3,'SGST/UTGST','Amount','',2,GETDATE()
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='RptGSTR1_B2B')
DROP TABLE RptGSTR1_B2B
GO
CREATE TABLE RptGSTR1_B2B
(
[Slno]							BIGINT IDENTITY(1,1),
[GSTIN/UIN of Recipient]		Varchar(50),
[Recipient Code in application]	NVarchar(50),
[Recipient Name]				NVarchar(100),
[Recipient Type]				Varchar(50),
[Invoice Number]				Varchar(50),
[Invoice date]					Varchar(25),
[Invoice Value]					Numeric(32,2),
[Place Of Supply]				Varchar(125),
[Reverse Charge]				Varchar(10),
[Invoice Type]					Varchar(50),
[Kind of transaction]			Varchar(50),
[Identifier if Goods or Services]	Varchar(50),
[E-Commerce GSTIN]				Varchar(50),
[Rate]							Numeric(10,2),
[Taxable Value]					Numeric(32,2),
[Cess Amount]					Numeric(32,2),
[IGST rate]						Numeric(32,2),
[IGST amount]					Numeric(32,2),
[CGST rate]						Numeric(32,2),
[CGST amount]					Numeric(32,2),
[SGST/UTGST rate]				Numeric(32,2),
[SGST/UTGST amount]				Numeric(32,2),
UsrId							INT,
[Group Name]					Varchar(100),
GroupType						TINYINT
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='RptGSTR1_B2CL')
DROP TABLE RptGSTR1_B2CL
GO
CREATE TABLE RptGSTR1_B2CL
(
	[Slno]						BIGINT IDENTITY(1,1),
	[Invoice Number]			VARCHAR(50),
	[Invoice date]				VARCHAR(20),
	[Recipient Code in application]	NVarchar(50),
	[Recipient Name]				NVarchar(100),
	[Invoice Value]				NUMERIC(32,4),
	[Place Of Supply]			VARCHAR(120),
	[Rate]						NUMERIC(10,2),
	[Taxable Value]				NUMERIC(32,4),
	[Cess Amount]				NUMERIC(32,4),
	[E-Commerce GSTIN]			VARCHAR(50),
	[IGST rate]					NUMERIC(32,2),
	[IGST amount]				NUMERIC(32,2),
	 UsrId						INT,
	[Group Name]				VARCHAR(100),
	GroupType					TINYINT
)
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and GrpCode='FORMGSTR1B2CL' and RptId=415
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'GSRT 410',415,'FORMGSTR1B2CL','FORM GSTR1-B2CL'
GO
DELETE FROM RptHeader WHERE RptId=415
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'FORMGSTR1B2CL','FORM GSTR1-B2CL',415,'FORM GSTR1-B2CL','Proc_RptGSTR1_B2CL','RptGSTR1_B2CL','RptGSTR1_B2CL.rpt',0
GO
DELETE FROM RptDetails where RPTID=415
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (415,1,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (415,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=415
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 415,208,1,'January' UNION
SELECT 415,208,2,'February' UNION
SELECT 415,208,3,'March' UNION
SELECT 415,208,4,'April' UNION
SELECT 415,208,5,'May' UNION
SELECT 415,208,6,'June' UNION
SELECT 415,208,7,'July' UNION
SELECT 415,208,8,'August' UNION
SELECT 415,208,9,'September' UNION
SELECT 415,208,10,'October' UNION
SELECT 415,208,11,'November' UNION
SELECT 415,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=415
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,415,'FORM GSTR1-B2CL',1,'Invoice Number',50,1,0,1,1,'Invoice','Number','',0,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',2,'Invoice date',20,1,0,1,1,'Invoice','date','',0,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',3,'Recipient Code in application',20,1,0,1,1,'Recipient Code','in application date','',0,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',4,'Recipient Name',20,1,0,1,1,'Recipient Name','','',0,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',5,'Invoice Value',20,1,0,2,3,'Invoice','Value','',2,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',6,'Place Of Supply',30,1,0,1,1,'Place Of Supply','','',0,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',7,'Rate',20,1,0,2,3,'Rate','','',2,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',8,'Taxable Value',20,1,0,2,3,'Taxable','Value','',2,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',9,'Cess Amount',20,1,0,2,3,'Cess','Amount','',2,GETDATE()
UNION ALL
SELECT 1,415,'FORM GSTR1-B2CL',10,'E-Commerce GSTIN',50,1,0,1,1,'E-Commerce',' GSTIN','',0,GETDATE()
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='RptGSTR1_B2CS')
DROP TABLE RptGSTR1_B2CS
GO
CREATE TABLE RptGSTR1_B2CS
(
[Slno] BIGINT IDENTITY(1,1),
[Type]	Varchar(10),
[Place Of Supply]	Varchar(120),
[Rate]	Numeric(10,2),
[Taxable Value]	Numeric(32,4),
[Cess Amount]	Numeric(32,4),
[E-Commerce GSTIN]	Varchar(50),
[IGST rate]			Numeric(32,2),
[IGST amount]		Numeric(32,2),
[CGST rate]			Numeric(32,2),
[CGST amount]		Numeric(32,2),
[SGST/UTGST rate]	Numeric(32,2),
[SGST/UTGST amount]	Numeric(32,2),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and GrpCode='FORMGSTR1B2CS' and RptId=416
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'GSRT 410',416,'FORMGSTR1B2CS','FORM GSTR1-B2CS'
GO
DELETE FROM RptHeader WHERE RptId=416
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'FORMGSTR1B2CS','FORM GSTR1-B2CS',416,'FORM GSTR1-B2CS','Proc_RptGSTR1_B2CS','RptGSTR1_B2CS','RptGSTR1_B2CS.rpt',0
GO
DELETE FROM RptDetails where RPTID=416
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (416,1,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (416,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=416
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 416,208,1,'January' UNION
SELECT 416,208,2,'February' UNION
SELECT 416,208,3,'March' UNION
SELECT 416,208,4,'April' UNION
SELECT 416,208,5,'May' UNION
SELECT 416,208,6,'June' UNION
SELECT 416,208,7,'July' UNION
SELECT 416,208,8,'August' UNION
SELECT 416,208,9,'September' UNION
SELECT 416,208,10,'October' UNION
SELECT 416,208,11,'November' UNION
SELECT 416,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=416
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,416,'FORM GSTR1-B2CS',1,'Type',50,1,0,1,1,'Type','','',0,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CS',2,'Place Of Supply',30,1,0,1,1,'Place Of Supply','','',0,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CL',3,'E-Commerce GSTIN',50,1,0,1,1,'E-Commerce','GSTIN','',0,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CS',4,'Rate',20,1,0,2,3,'Rate','','',2,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CS',5,'Taxable Value',20,1,0,2,3,'Taxable','Value','',2,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CS',6,'Cess Amount',20,1,0,2,3,'Cess','Amount','',2,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CL',7,'IGST rate',50,1,0,2,3,'IGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CL',8,'IGST amount',50,1,0,2,3,'IGST','Amount','',2,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CL',9,'CGST rate',50,1,0,2,3,'CGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CL',10,'CGST amount',50,1,0,2,3,'CGST','Amount','',2,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CL',11,'SGST/UTGST rate',50,1,0,2,3,'SGST/UTGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,416,'FORM GSTR1-B2CL',12,'SGST/UTGST amount',50,1,0,2,3,'SGST/UTGST','Amount','',2,GETDATE()
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and GrpCode='FORMGSTR1DOCS' and RptId=420
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'GSRT 410',420,'FORMGSTR1DOCS','FORM GSTR1-DOCS'
GO
DELETE FROM RptHeader WHERE RptId=420
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'FORMGSTR1DOCS','FORM GSTR1-DOCS',420,'FORM GSTR1-DOCS','Proc_RptGSTR1_Docs','RptGSTR1_Docs','RptGSTR1_Docs.rpt',0
GO
DELETE FROM RptDetails where RPTID=420
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (420,1,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (420,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=420
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 420,208,1,'January' UNION
SELECT 420,208,2,'February' UNION
SELECT 420,208,3,'March' UNION
SELECT 420,208,4,'April' UNION
SELECT 420,208,5,'May' UNION
SELECT 420,208,6,'June' UNION
SELECT 420,208,7,'July' UNION
SELECT 420,208,8,'August' UNION
SELECT 420,208,9,'September' UNION
SELECT 420,208,10,'October' UNION
SELECT 420,208,11,'November' UNION
SELECT 420,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=420
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,420,'FORM GSTR1-DOCS',1,'Nature  of Document',50,1,0,1,1,'Nature  of Document','','',0,GETDATE()
UNION ALL
SELECT 1,420,'FORM GSTR1-DOCS',2,'Sr. No. From',20,1,0,1,1,'Sr. No. From','','',0,GETDATE()
UNION ALL
SELECT 1,420,'FORM GSTR1-DOCS',3,'Sr. No. To',20,1,0,1,1,'Sr. No. To','','',0,GETDATE()
UNION ALL
SELECT 1,420,'FORM GSTR1-DOCS',4,'Total Number',30,1,0,2,2,'Total Number','','',0,GETDATE()
UNION ALL
SELECT 1,420,'FORM GSTR1-DOCS',5,'Cancelled',20,1,0,2,2,'Cancelled','','',2,GETDATE()
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='RptGSTR1_Docs')
DROP TABLE RptGSTR1_Docs
GO
CREATE TABLE RptGSTR1_Docs
(
[Slno] INT IDENTITY(1,1),
[Nature  of Document]	Varchar(100),
[Sr. No. From]	Varchar(200),
[Sr. No. To]	Varchar(200),
[Total Number]	INT,
[Cancelled]	INT,
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF EXISTS(SELECT 'X' FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_RptGSTR1_Docs')
DROP PROCEDURE Proc_RptGSTR1_Docs
GO
/*
EXEC Proc_RptGSTR1_Docs 420,2,0,'',0,0,0
 */
CREATE PROCEDURE .[Proc_RptGSTR1_Docs]
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
* PROCEDURE		: Proc_RptGSTR1_Docs
* PURPOSE		: To Generate a report GSTR1 Docs
* CREATED		: Murugan.R
* CREATED DATE	: 13/04/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	TRUNCATE TABLE RptGSTR1_Docs
	
	CREATE TABLE #Docs
	(	
		[Nature  of Document]	Varchar(100),
		[Sr. No. From]	Varchar(200),
		[Sr. No. To]	Varchar(200),
		[Total Number]	INT,
		[Cancelled]	INT
	)	
		
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017
		
		CREATE TABLE #PreFixDT
		(
			SLNO INT IDENTITY(1,1),
			PreFix Varchar(50)
		)
		
		TRUNCATE TABLE #PreFixDT
			
		INSERT INTO #PreFixDT(PreFix)
		SELECT DISTINCT CASE WHEN LEN(SalInvno)<=6 THEN LEFT(Salinvno,1) 
					WHEN LEN(SalInvno)=7 THEN LEFT(Salinvno,2)
					WHEN LEN(SalInvno)=8 THEN LEFT(Salinvno,3)
					WHEN LEN(SalInvno)=9 THEN LEFT(Salinvno,4)
					WHEN LEN(SalInvno)>9 THEN LEFT(Salinvno,5)
					END
		FROM SalesInvoice (NOLOCK) WHERE Dlvsts>2 and Month(Salinvdate)=@MonthStart
		and YEAR(Salinvdate)=@Jcmyear and VatGST='GST'
		
		DECLARE @Minno AS INT
		DECLARE @Maxno as INT
		DECLARE @PreFix AS Varchar(20)
		
		SELECT @Maxno=MAX(Slno) FROM #PreFixDT
		SET @Minno=1
		WHILE @Minno<=@Maxno
		BEGIN
			SELECT @PreFix=PreFix FROM #PreFixDT WHERE SLNO=@Minno
			INSERT INTO #Docs([Nature  of Document],[Sr. No. From],[Sr. No. To],[Total Number],[Cancelled])
			SELECT 'Invoice for outward supply',MAX(FromBill),MAX(ToBill),SUM(TotalCnt) TotalCnt,SUM(Cancel) as Cancel
			FROM(
			
				SELECT MIN(SalInvno) as FromBill,Max(SalInvno) as ToBill,COUNT(SalId) as TotalCnt ,0 as Cancel
				FROM SalesInvoice (NOLOCK) WHERE Dlvsts>2 and Month(Salinvdate)=@MonthStart
				and YEAR(Salinvdate)=@Jcmyear and SalInvNo Like @PreFix +'%' and VatGST='GST'
				UNION ALL
				SELECT '' as FromBill,'' as ToBill,0 as TotalCnt,COUNT(SalId) as Cancel
				FROM SalesInvoice (NOLOCK) WHERE Dlvsts=3 and Month(Salinvdate)=@MonthStart
				and YEAR(Salinvdate)=@Jcmyear and SalInvNo Like @PreFix +'%' and VatGST='GST'
			)	X
		
			
			SET @Minno=@Minno+1
			
		END		
		
		
		-----Service Invoice
		TRUNCATE TABLE #PreFixDT
		
		INSERT INTO #PreFixDT(PreFix)
		SELECT DISTINCT CASE WHEN LEN(ServiceInvRefNo)<=6 THEN LEFT(ServiceInvRefNo,1) 
					WHEN LEN(ServiceInvRefNo)=7 THEN LEFT(ServiceInvRefNo,2)
					WHEN LEN(ServiceInvRefNo)=8 THEN LEFT(ServiceInvRefNo,3)
					WHEN LEN(ServiceInvRefNo)=9 THEN LEFT(ServiceInvRefNo,4)
					WHEN LEN(ServiceInvRefNo)>9 THEN LEFT(ServiceInvRefNo,5)
					END
		FROM ServiceInvoiceHD (NOLOCK) WHERE  Month(ServiceInvDate)=@MonthStart
		and YEAR(ServiceInvDate)=@Jcmyear and ServiceInvFor=2
		
		SELECT @Maxno=MAX(Slno) FROM #PreFixDT
		SET @Minno=1
		WHILE @Minno<=@Maxno
		BEGIN
			SELECT @PreFix=PreFix FROM #PreFixDT WHERE SLNO=@Minno
			INSERT INTO #Docs([Nature  of Document],[Sr. No. From],[Sr. No. To],[Total Number],[Cancelled])
			SELECT 'Invoice for outward supply',MIN(ServiceInvRefNo) as FromBill,Max(ServiceInvRefNo) as ToBill,COUNT(ServiceInvRefNo) as TotalCnt ,0 as Cancel
			FROM ServiceInvoiceHD (NOLOCK) WHERE  Month(ServiceInvDate)=@MonthStart
			and YEAR(ServiceInvDate)=@Jcmyear and ServiceInvRefNo Like @PreFix +'%'
			
			SET @Minno=@Minno+1
		END	
		
		-----Purchase Return
		SELECT PurRcptId 
		INTO #Purchareceipt
		FROM PurchaseReceipt (NOLOCK)
		WHERE GoodsRcvdDate Between '2017-01-01' and '2017-06-30' and VatGst='VAT'
		
		TRUNCATE TABLE #PreFixDT
		
		INSERT INTO #PreFixDT(PreFix)
		SELECT DISTINCT CASE WHEN LEN(PurRetRefNo)<=6 THEN LEFT(PurRetRefNo,1) 
					WHEN LEN(PurRetRefNo)=7 THEN LEFT(PurRetRefNo,2)
					WHEN LEN(PurRetRefNo)=8 THEN LEFT(PurRetRefNo,3)
					WHEN LEN(PurRetRefNo)=9 THEN LEFT(PurRetRefNo,4)
					WHEN LEN(PurRetRefNo)>9 THEN LEFT(PurRetRefNo,5)
					END
		FROM PurchaseReturn A (NOLOCK) INNER JOIN  #Purchareceipt B ON A.PurRcptId=B.PurRcptId
		WHERE  Month(PurRetDate)=@MonthStart
		and YEAR(PurRetDate)=@Jcmyear and Status=1
		
		SELECT @Maxno=MAX(Slno) FROM #PreFixDT
		SET @Minno=1
		WHILE @Minno<=@Maxno
		BEGIN
			SELECT @PreFix=PreFix FROM #PreFixDT WHERE SLNO=@Minno
			INSERT INTO #Docs([Nature  of Document],[Sr. No. From],[Sr. No. To],[Total Number],[Cancelled])
			SELECT 'Invoice for outward supply',MIN(PurRetRefNo) as FromBill,Max(PurRetRefNo) as ToBill,COUNT(PurRetRefNo) as TotalCnt ,0 as Cancel
			FROM PurchaseReturn A (NOLOCK) INNER JOIN  #Purchareceipt B ON A.PurRcptId=B.PurRcptId
			WHERE  Month(PurRetDate)=@MonthStart
			and YEAR(PurRetDate)=@Jcmyear and Status=1 and A.PurRetRefNo Like @PreFix +'%'	
			
			
			SET @Minno=@Minno+1		
		END	
		
		-------IDT
		TRUNCATE TABLE #PreFixDT
		
		INSERT INTO #PreFixDT(PreFix)
		SELECT DISTINCT CASE WHEN LEN(IDTMngRefNo)<=6 THEN LEFT(IDTMngRefNo,1) 
					WHEN LEN(IDTMngRefNo)=7 THEN LEFT(IDTMngRefNo,2)
					WHEN LEN(IDTMngRefNo)=8 THEN LEFT(IDTMngRefNo,3)
					WHEN LEN(IDTMngRefNo)=9 THEN LEFT(IDTMngRefNo,4)
					WHEN LEN(IDTMngRefNo)>9 THEN LEFT(IDTMngRefNo,5)
					END
		FROM IDTManagement A (NOLOCK)		
		WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear
		and StkMgmtTypeId=2 
		
		SELECT @Maxno=MAX(Slno) FROM #PreFixDT
		SET @Minno=1
		WHILE @Minno<=@Maxno
		BEGIN
			SELECT @PreFix=PreFix FROM #PreFixDT WHERE SLNO=@Minno
			INSERT INTO #Docs([Nature  of Document],[Sr. No. From],[Sr. No. To],[Total Number],[Cancelled])
			SELECT 'Invoice for outward supply',MIN(IDTMngRefNo) as FromBill,Max(IDTMngRefNo) as ToBill,COUNT(IDTMngRefNo) as TotalCnt ,0 as Cancel
			FROM IDTManagement A (NOLOCK)		
			WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear
			and StkMgmtTypeId=2  and A.IDTMngRefNo Like @PreFix +'%'	
			
			
			SET @Minno=@Minno+1		
		END	
		
		----Sales Return Credit Note		
		SELECT C.RtrId,CrNoteNumber,CrNoteDate,PostedFrom AS ReturnCode
		INTO #CREDITNOTEDETAILS
		FROM Creditnoteretailer C (NOLOCK) INNER JOIN (SELECT * FROM FN_ReturnRetailerUDCDetails()) R ON R.Rtrid=C.Rtrid
		WHERE TransId=30 AND MONTH(CrNoteDate)=@MonthStart AND YEAR(CrNoteDate)=@Jcmyear --AND R.RetailerType =1
		
		TRUNCATE TABLE #PreFixDT
		
		INSERT INTO #PreFixDT(PreFix)
		SELECT DISTINCT CASE WHEN LEN(C.CrNoteNumber)<=6 THEN LEFT(C.CrNoteNumber,1) 
					WHEN LEN(C.CrNoteNumber)=7 THEN LEFT(C.CrNoteNumber,2)
					WHEN LEN(C.CrNoteNumber)=8 THEN LEFT(C.CrNoteNumber,3)
					WHEN LEN(C.CrNoteNumber)=9 THEN LEFT(C.CrNoteNumber,4)
					WHEN LEN(C.CrNoteNumber)>9 THEN LEFT(C.CrNoteNumber,5)
					END
		FROM ReturnHeader RH (NOLOCK) 
		INNER JOIN #CREDITNOTEDETAILS C ON C.ReturnCode=RH.ReturnCode
		WHERE MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear 
		AND ReturnDate NOT BETWEEN '2017-01-01' AND '2017-06-30' AND InvoiceType=1 and VatGst='GST' 
		AND RH.Status=0
		
		
		SELECT DISTINCT CrNoteNumber
		INTO #CreditNoteNumber
		FROM ReturnHeader RH (NOLOCK) 
		INNER JOIN ReturnProduct RP (NOLOCK) ON RH.ReturnID=RP.ReturnID
		INNER JOIN ReturnProductTax RPT (NOLOCK) ON RPT.ReturnId=RP.ReturnID AND RPT.PrdSlno=RP.Slno
		INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=RPT.TaxId 
		INNER JOIN #CREDITNOTEDETAILS C ON C.ReturnCode=RH.ReturnCode
		WHERE MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear and TaxCode IN('OutputCGST','OutputSGST','CGST','SGST','OutputIGST','IGST')
		AND ReturnDate NOT BETWEEN '2017-01-01' AND '2017-06-30' AND InvoiceType=1 --and C.CrNoteNumber Like @PreFix +'%'	
		AND RH.Status=0		and VatGst='GST'	
				
	
		SELECT @Maxno=MAX(Slno) FROM #PreFixDT
		SET @Minno=1
		WHILE @Minno<=@Maxno
		BEGIN
			SELECT @PreFix=PreFix FROM #PreFixDT WHERE SLNO=@Minno
			
			INSERT INTO #Docs([Nature  of Document],[Sr. No. From],[Sr. No. To],[Total Number],[Cancelled])
			SELECT 'Credit Note',MIN(C.CrNoteNumber) as FromBill,Max(C.CrNoteNumber) as ToBill,COUNT(C.CrNoteNumber) as TotalCnt ,0 as Cancel
			FROM #CreditNoteNumber C WHERE CrNoteNumber Like @PreFix +'%'	
		
			
			
			SET @Minno=@Minno+1
		END	
		
		IF NOT EXISTS(SELECT 'X' FROM #Docs)
		BEGIN
			SELECT * FROM RptGSTR1_Docs WHERE 	UsrId=	@Pi_UsrId
			RETURN
		END
		
		INSERT INTO RptGSTR1_Docs([Nature  of Document],[Sr. No. From],[Sr. No. To],[Total Number],[Cancelled],
		UsrId,[Group Name],GroupType)
		SELECT [Nature  of Document],[Sr. No. From],[Sr. No. To],[Total Number],[Cancelled],@Pi_UsrId,'',2 FROM #Docs
		
		INSERT INTO RptGSTR1_Docs([Nature  of Document],[Sr. No. From],[Sr. No. To],[Total Number],[Cancelled],
		UsrId,[Group Name],GroupType)
		SELECT '' as [Nature  of Document],'' as [Sr. No. From],'' as [Sr. No. To],SUM([Total Number]),SUM([Cancelled]),@Pi_UsrId,'ZZZZZ',3 
		FROM #Docs
		
		SELECT * FROM RptGSTR1_Docs WHERE 	UsrId=	@Pi_UsrId
END
GO
----------Script Added BY Karthick
DELETE FROM RptGroup WHERE PID='GSRT 410' and GrpCode='GSTRTRANS2' and RptId=413
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSRT 410',413,'GSTRTRANS2','GSTR TRANS2',1
GO
DELETE FROM RptHeader WHERE RptId=413
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'GSTRTRANS2','GSTR TRANS2',413,'GSTR TRANS2','Proc_RptGSTR_TRANS2','RptGSTR_TRANS2_CGST','RptGSTR_TRANS2.rpt',0
GO
DELETE FROM RptDetails where RPTID=413
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (413,2,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (413,3,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=413
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,413,'GSTR TRANS2',1,'HSN',100,1,0,1,1,'HSN(at 6 digit level)','','',0,GETDATE()
UNION ALL
SELECT 1,413,'GSTR TRANS2',2,'Unit',20,1,0,2,3,'Unit','','',2,GETDATE()
UNION ALL
SELECT 1,413,'GSTR TRANS2',3,'OpeningQty',20,1,0,2,3,'Opening Qty','','',2,GETDATE()
UNION ALL
SELECT 1,413,'GSTR TRANS2',4,'OutwardQty',20,1,0,2,3,'Outward Qty','','',2,GETDATE()
UNION ALL
SELECT 1,413,'GSTR TRANS2',5,'Value',20,1,0,2,3,'Value','','',2,GETDATE()
UNION ALL
SELECT 1,413,'GSTR TRANS2',6,'CentralTax',20,1,0,2,3,'Central Tax','','',2,GETDATE()
UNION ALL
SELECT 1,413,'GSTR TRANS2',7,'IntegratedTax',20,1,0,2,3,'Integrated Tax','','',2,GETDATE()
UNION ALL
SELECT 1,413,'GSTR TRANS2',8,'ITCAllowed',20,1,0,2,3,'ITC allowed','','',2,GETDATE()
UNION ALL
SELECT 1,413,'GSTR TRANS2',9,'ClosingQty',20,1,0,2,3,'Qty','','',2,GETDATE()
GO
DELETE FROM RPTFILTER WHERE RptId=413
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 413,208,1,'January' UNION
SELECT 413,208,2,'February' UNION
SELECT 413,208,3,'March' UNION
SELECT 413,208,4,'April' UNION
SELECT 413,208,5,'May' UNION
SELECT 413,208,6,'June' UNION
SELECT 413,208,7,'July' UNION
SELECT 413,208,8,'August' UNION
SELECT 413,208,9,'September' UNION
SELECT 413,208,10,'October' UNION
SELECT 413,208,11,'November' UNION
SELECT 413,208,12,'December' 
GO
--DELETE FROM RptGridView WHERE RPTID=411
--INSERT INTO RptGridView 
--SELECT 411,'RptDistributorTurnOver.rpt',1,0,1,1 
--GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptGSTR_TRANS2_CGST')
DROP TABLE RptGSTR_TRANS2_CGST
GO
CREATE TABLE RptGSTR_TRANS2_CGST
(
	Slno			Int IDENTITY(1,1),
	[HSN]			NVARCHAR(50),
	[Unit]			VARCHAR(10),
	[OpeningQty]	INT,
	[OutwardQty]	INT,
	[Value]			NUMERIC(18,6),
	[CentralTax]	NUMERIC(18,6),
	[IntegratedTax] NUMERIC(18,6),
	[ITCAllowed]	NUMERIC(18,6),	
	[ClosingQty]	INT,
	UsrId			INT,
	[Group Name]	VARCHAR(100),
	GroupType		TINYINT
)
GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptGSTR_TRANS2_SGST')
DROP TABLE RptGSTR_TRANS2_SGST
GO
CREATE TABLE RptGSTR_TRANS2_SGST
(
	Slno			Int IDENTITY(1,1),
	[HSN]			NVARCHAR(50),
	[Unit]			VARCHAR(10),
	[OpeningQty]	INT,
	[OutwardQty]	INT,
	[Value]			NUMERIC(18,6),
	[StateTax]	NUMERIC(18,6),
	[ITCAllowed]	NUMERIC(18,6),	
	[ClosingQty]	INT,
	UsrId			INT,
	[Group Name]	VARCHAR(100),
	GroupType		TINYINT
)
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptGSTR_TRANS2')
DROP PROCEDURE Proc_RptGSTR_TRANS2
GO
--EXEC Proc_RptGSTR_TRANS2 413,2,0,'',0,0,0
--SELECT * FROM reportfilterdt where rptid=413
CREATE PROCEDURE Proc_RptGSTR_TRANS2
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
/************************************************
* PROCEDURE  : Proc_RptGSTR_TRANS2
* PURPOSE    : To Generate GSTR_TRANS2 Report
* CREATED BY : Karthick
* CREATED ON : 07/08/2017
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON
 
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @ITCStartDate DATETIME 
		DECLARE @LastMonthEndDate DATETIME
		DECLARE @Date DATETIME
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		DECLARE @MinNo AS INT
		DECLARE @MaxNo AS INT
		DECLARE @HSNCODE AS NVARCHAR(50)
		DECLARE @Prdid AS INT
		DECLARE @MRP AS NUMERIC(18,2)
		DECLARE @Lcnid AS INT
		DECLARE @ClosingStock AS INT
		DECLARE @MinTransNo AS INT
		DECLARE @MaxTransNo	AS INT
		DECLARE @Salid AS INT
		DECLARE @Baseqty AS INT
		DECLARE @FinalClosingStock AS INT		
		DECLARE @HSNClosingStock AS INT	
		
	CREATE TABLE #TAXPIVOT
	(
		 SLNO			INT IDENTITY(1,1),
		 Salid			INT,
		 HSNCODE		NVARCHAR(50),
		 PrdId			INT,
		 MRP			NUMERIC(18,2),	
		 BaseQty		INT,
		 TaxCode		NVARCHAR(50),
		 TaxPercAmt		NUMERIC(18,6)
	)

	CREATE TABLE #TAXDETAILS
	(
		Salid				INT,
		HSNCODE				NVARCHAR(50),
		PrdId				INT,
		MRP					NUMERIC(18,2),
		BaseQty				INT,
		[OutputCGSTPerc]	NUMERIC(18,2),
		[OutputCGST_Amt]	NUMERIC(18,6),
		[OutputCGST_Taxable]NUMERIC(18,6),		
		[OutputSGSTPerc]	NUMERIC(18,2),
		[OutputSGST_Amt]	NUMERIC(18,6),
		[OutputSGST_Taxable]NUMERIC(18,6),
		[OutputIGSTPerc]	NUMERIC(18,2),
		[OutputIGST_Amt]	NUMERIC(18,6),
		[OutputIGST_Taxable]NUMERIC(18,6),
		[OutputUTGSTPerc]	NUMERIC(18,2),
		[OutputUTGST_Amt]	NUMERIC(18,6),
		[OutputUTGST_Taxable]NUMERIC(18,6)
	)

	CREATE TABLE #FINALSTOCK
	(
		Salid				INT,
		HSNCODE				NVARCHAR(50),
		PrdId				INT,
		MRP					NUMERIC(18,2),
		ClosingQty			INT,
		BaseQty				INT,
		ActualQty			INT,
		[OutputCGSTPerc]	NUMERIC(18,2),
		[OutputCGST_Amt]	NUMERIC(18,6),
		[OutputCGST_Taxable]NUMERIC(18,6),		
		[OutputSGSTPerc]	NUMERIC(18,2),
		[OutputSGST_Amt]	NUMERIC(18,6),
		[OutputSGST_Taxable]NUMERIC(18,6),
		[OutputIGSTPerc]	NUMERIC(18,2),
		[OutputIGST_Amt]	NUMERIC(18,6),
		[OutputIGST_Taxable]NUMERIC(18,6),
		[OutputUTGSTPerc]	NUMERIC(18,2),
		[OutputUTGST_Amt]	NUMERIC(18,6),
		[OutputUTGST_Taxable]NUMERIC(18,6),
		Actual_CGST_Taxable	NUMERIC(18,6),	
		Actual_SGST_Taxable	NUMERIC(18,6),
		Actual_UTGST_Taxable NUMERIC(18,6),
		Actual_IGST_Taxable	NUMERIC(18,6),
		Actual_CGST_Tax		NUMERIC(18,6),	
		Actual_SGST_Tax		NUMERIC(18,6),
		Actual_UTGST_Tax	NUMERIC(18,6),
		Actual_IGST_Tax		NUMERIC(18,6),
		PresumptiveTax_CGST	NUMERIC(18,2),
		PresumptiveTax_IGST	NUMERIC(18,2),
		ITCAllowed_CGST		NUMERIC(18,6),	
		ITCAllowed_SGST		NUMERIC(18,6),	
		ITCAllowed_IGST		NUMERIC(18,6),	
		ITCAllowed			NUMERIC(18,6),
		HSNClosingStock		INT
	)	
			  
	CREATE TABLE #TRANSDETAILS
	(	
		Slno		INT IDENTITY(1,1),
		salid		INT,
		PrdId		INT,
		MRP			NUMERIC(18,2),
		BaseQty		INT
	)
 
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		SET @Date=CONVERT(DATETIME,CONVERT(Varchar(10),CAST(@Jcmyear as Varchar(5)) +'-'+CASE WHEN @MonthStart<10 THEN '0'+CAST(@MonthStart AS Varchar(4)) ELSE CAST(@MonthStart AS Varchar(4)) END +'-01',121),121)
	
		IF @Date<'2017-07-01'
		BEGIN
			RETURN
		END 
		
		SELECT @ITCStartDate=CONVERT(VARCHAR(10),MIN(AuthDate),121) FROM VatClosingStock (NOLOCK)
		SELECT @LastMonthEndDate= DATEADD(DAY,-1,DATEADD(MONTH,DATEDIFF(month,0,@Date),0))
 
		
		--SELECT @ITCStartDate,@LastMonthEndDate,@MonthStart,@Jcmyear
		
		SELECT DISTINCT ColumnValue as HSNCODE,E.PrdId INTO #HSNCode
		FROM UDCHD A (NOLOCK)
		INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
		INNER JOIN UdcDetails C (NOLOCK) ON B.MasterId=C.MasterId
			AND B.UdcMasterId=C.UdcMasterId
		INNER JOIN Product E (NOLOCK) ON E.Prdid=C.MasterRecordId
		WHERE MasterName='Product Master' and ColumnName='HSN Code'

		SELECT  H.HSNCODE,V.prdid,MRP,V.Lcnid,SUM(GrnQty)ClosingStock 
		INTO #VATCLOSINGSTOCK
		FROM VatClosingStock V 
		INNER JOIN PurchaseReceipt P ON V.GrnRefNo=P.PurRcptRefNo AND V.CmpInvNo=P.CmpInvNo AND P.LcnId=V.Lcnid
		INNER JOIN #HSNCode H ON H.PrdId=V.Prdid
		GROUP BY H.HSNCODE,V.prdid,MRP,V.Lcnid

---GET PURCHASE RETURN QUANTITY
		SELECT HSNCODE,Prdid,MRP,LcnId,SUM(RetSalBaseQty)RetSalBaseQty INTO #PurchaseReturnQty  
		FROM
		(
				SELECT H.HSNCODE,PRP.Prdid,PrdUnitMRP AS MRP,PR.LcnId,SUM(RetSalBaseQty)RetSalBaseQty 
				FROM PurchaseReturn PR 
				INNER JOIN PurchaseReturnProduct PRP ON PR.PurRetId=PRP.PurRetId
				INNER JOIN #HSNCode H ON H.PrdId=PRP.Prdid 
				WHERE PR.VatGst='GST' AND PurRcptId IN(SELECT PurRcptId FROM PurchaseReceipt(NOLOCK) WHERE  VatGst ='VAT')
				AND purretdate BETWEEN @ITCStartDate AND  @LastMonthEndDate
				GROUP BY H.HSNCODE,PRP.Prdid,PrdUnitMRP,PR.LcnId
				UNION ALL
				SELECT H.HSNCODE,IT.Prdid,PrdMRPRate AS MRP,I.LcnId,SUM(Qty)RetSalBaseQty
				FROM IDTManagement I (NOLOCK) 
				INNER JOIN IDTManagementProduct IT (NOLOCK) ON I.IDTMngRefNo=IT.IDTMngRefNo
				INNER JOIN #HSNCode H ON H.PrdId=IT.Prdid 
				WHERE Status=1 and IDTMngDate BETWEEN @ITCStartDate AND  @LastMonthEndDate
				and StkMgmtTypeId=2  
				GROUP BY H.HSNCODE,IT.Prdid,PrdMRPRate,I.LcnId
		)A		GROUP BY HSNCODE,Prdid,MRP,LcnId 
		
--GST TOTAL OPENING QTY		
		UPDATE V SET ClosingStock=(ClosingStock-RetSalBaseQty) FROM #VATCLOSINGSTOCK V LEFT OUTER JOIN #PurchaseReturnQty P ON 
		V.HSNCODE=P.HSNCODE AND V.Prdid=P.Prdid AND V.MRP=P.MRP AND P.LcnId=V.Lcnid
		WHERE (ClosingStock-RetSalBaseQty)>0
		
		SELECT PrdId,MRP,LcnId,SUM(BaseQty)BaseQty INTO #MONTHCLOSING
		FROM
		(
			SELECT SIP.PrdId,PrdUnitMRP AS MRP,BaseQty,LcnId 
			FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId   
			WHERE Salinvdate BETWEEN @ITCStartDate AND  @LastMonthEndDate AND DlvSts IN (4,5)
		UNION ALL
			SELECT RP.PrdId,RP.PrdUnitMRP  AS MRP,-1*RP.BaseQty,SI.LcnId
			FROM ReturnHeader R INNER JOIN ReturnProduct RP(NOLOCK) ON R.ReturnID=RP.ReturnID 
			INNER JOIN SALESINVOICE SI ON SI.SALID=R.SALID 
			WHERE ReturnDate BETWEEN @ITCStartDate AND @LastMonthEndDate AND STATUS IN(0) AND InvoiceType=1 AND SI.VATGST='GST' 
		)A
		GROUP BY PrdId,MRP,LcnId

		SELECT V.HSNCODE AS HSN_Code,V.prdid,V.MRP,V.Lcnid,(ClosingStock-ISNULL(BaseQty,0))ClosingStock,0 AS HSNWiseClosing,ROW_NUMBER() OVER(ORDER BY V.Prdid,V.MRP)RowNo
		INTO #OPENINGSTOCK
		FROM #VATCLOSINGSTOCK V LEFT OUTER JOIN #MONTHCLOSING M ON  V.Prdid=M.prdid AND V.MRP=M.MRP
		AND V.lcnid=M.lcnid  WHERE ClosingStock-ISNULL(BaseQty,0)>0

		SELECT HSN_Code,Lcnid,SUM(ClosingStock) AS HSNWiseClosing INTO #HsnWs_Closing FROM #OPENINGSTOCK GROUP BY HSN_Code,Lcnid
		
		UPDATE O SET O.HSNWiseClosing=H.HSNWiseClosing FROM #OPENINGSTOCK O INNER JOIN #HsnWs_Closing H ON O.HSN_Code=H.HSN_Code AND O.Lcnid=H.Lcnid
		
		--select * from #OPENINGSTOCK
		
		---SALES DETAILS
			SELECT   SI.salid,SI.LcnId,SIP.PrdId,SIP.PrdUnitMRP AS MRP,SIP.SlNo,BaseQty INTO #SALESDETAILS 
			FROM SalesInvoice SI(NOLOCK) INNER JOIN SalesInvoiceProduct SIP(NOLOCK) ON SI.SalId=SIP.SalId  
			WHERE MONTH(SALINVDATE)=@MonthStart AND YEAR(SALINVDATE)=@Jcmyear AND DlvSts IN (4,5)
			
			SELECT * INTO #SalesInvoiceProductTax FROM SalesInvoiceProductTax 
				WHERE SalId IN (SELECT DISTINCT salid FROM #SALESDETAILS)
		
		--RETURN DETAILS
			SELECT R.ReturnID,SI.salid,SI.LcnId,RP.PrdId,RP.PrdUnitMRP AS MRP,RP.Slno,RP.BaseQty AS BaseQty INTO #RETURNDETAILS
			FROM ReturnHeader R(NOLOCK) INNER JOIN ReturnProduct RP(NOLOCK) ON R.ReturnID=RP.ReturnID 
			INNER JOIN SalesInvoice SI ON SI.salid=R.salid 
			WHERE MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear  AND STATUS IN(0) AND InvoiceType=1 AND SI.VATGST='GST' 

			SELECT * INTO #ReturnProductTax FROM ReturnProductTax 
				WHERE ReturnID IN (SELECT DISTINCT ReturnID FROM #RETURNDETAILS)
			
		---CALCULTE TAX AND TAXABLE SPILT
			INSERT  INTO #TAXPIVOT
  			SELECT salid,HSNCODE,PrdId,MRP,BaseQty,TaxCode,TaxPercAmt 
			FROM
			(
			SELECT  H.HSNCODE,SI.salid,SI.PrdId,SI.MRP ,BaseQty,TaxCode+'Perc' AS TaxCode,TaxPerc AS TaxPercAmt 
				FROM #SALESDETAILS SI
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.SalId=SI.SalId AND ST.PrdSlNo=SI.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=ST.TaxId
				INNER JOIN #HSNCode H ON H.PrdId=SI.PrdId	
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=SI.PrdId AND O.MRP=SI.MRP AND O.Lcnid=SI.LcnId
				WHERE TaxableAmount>0			
			UNION 
			SELECT H.HSNCODE,SI.salid,SI.PrdId,SI.MRP,BaseQty,TaxCode+'_Amt' AS TaxCode,TaxAmount AS TaxPercAmt 
				FROM #SALESDETAILS SI 
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.SalId=SI.SalId AND ST.PrdSlNo=SI.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=ST.TaxId
				INNER JOIN #HSNCode H ON H.PrdId=SI.PrdId	
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=SI.PrdId AND O.MRP=SI.MRP AND O.Lcnid=SI.LcnId 
				WHERE TaxableAmount>0
			UNION
			SELECT H.HSNCODE,SI.salid,SI.PrdId,SI.MRP,BaseQty,TaxCode+'_Taxable' AS TaxCode,TaxableAmount AS TaxPercAmt 
				FROM #SALESDETAILS SI 
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.SalId=SI.SalId AND ST.PrdSlNo=SI.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=ST.TaxId
				INNER JOIN #HSNCode H ON H.PrdId=SI.PrdId	
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=SI.PrdId AND O.MRP=SI.MRP AND O.Lcnid=SI.LcnId 
				WHERE TaxableAmount>0
			UNION
				SELECT H.HSNCODE,RP.salid,RP.PrdId,RP.MRP,-1*SUM(RP.BaseQty) AS BaseQty,TaxCode+'Perc' AS TaxCode,TaxPerc AS TaxPercAmt 
				FROM #RETURNDETAILS RP
 				INNER JOIN #ReturnProductTax RPT(NOLOCK) ON RPT.ReturnID=RP.ReturnID AND RPT.ReturnId=RP.ReturnID AND RPT.PrdSlNo=RP.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode  
				IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=RPT.TaxID 
				INNER JOIN #HSNCode H ON H.PrdId=RP.PrdId 
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=RP.PrdId AND O.MRP=RP.MRP AND O.Lcnid=RP.LcnId 
				WHERE TaxableAmt>0
				GROUP BY H.HSNCODE,RP.salid,RP.PrdId,RP.MRP,TaxCode,TaxPerc
			UNION
				SELECT HSNCODE,RP.salid,RP.PrdId,RP.MRP,-1*SUM(RP.BaseQty)AS BaseQty,TaxCode+'_Amt' AS TaxCode,-1*SUM(TaxAmt) AS TaxPercAmt 
				FROM #RETURNDETAILS RP
 				INNER JOIN #ReturnProductTax RPT(NOLOCK) ON RPT.ReturnID=RP.ReturnID AND RPT.ReturnId=RP.ReturnID AND RPT.PrdSlNo=RP.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode  
				IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=RPT.TaxID 
				INNER JOIN #HSNCode H ON H.PrdId=RP.PrdId	 
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=RP.PrdId AND O.MRP=RP.MRP AND O.Lcnid=RP.LcnId
				WHERE TaxableAmt>0 
				GROUP BY H.HSNCODE,RP.salid,RP.PrdId,RP.MRP,TaxCode 
			UNION
				SELECT HSNCODE,RP.salid,RP.PrdId,RP.MRP,-1*SUM(RP.BaseQty)AS BaseQty,TaxCode+'_Taxable' AS TaxCode,-1*SUM(TaxableAmt) AS TaxPercAmt 
				FROM #RETURNDETAILS RP
 				INNER JOIN #ReturnProductTax RPT(NOLOCK) ON RPT.ReturnID=RP.ReturnID AND RPT.ReturnId=RP.ReturnID AND RPT.PrdSlNo=RP.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode  
				IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=RPT.TaxID 
				INNER JOIN #HSNCode H ON H.PrdId=RP.PrdId	
 				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=RP.PrdId AND O.MRP=RP.MRP AND O.Lcnid=RP.LcnId
 				WHERE TaxableAmt>0
 				GROUP BY H.HSNCODE,RP.salid,RP.PrdId,RP.MRP,TaxCode 
 			)A
 			ORDER BY salid
  
			INSERT INTO #TAXDETAILS
			SELECT salid,HSNCODE,PrdId,MRP,SUM(BaseQty),([OutputCGSTPerc]),
			SUM([OutputCGST_Amt]),SUM([OutputCGST_Taxable]),
			([OutputSGSTPerc]),SUM([OutputSGST_Amt]),SUM([OutputSGST_Taxable]),
			([OutputIGSTPerc]),SUM([OutputIGST_Amt]),SUM([OutputIGST_Taxable]),
			([OutputUTGSTPerc]),SUM([OutputUTGST_Amt]),SUM([OutputUTGST_Taxable])
			FROM(
			SELECT  salid,HSNCODE,PrdId,MRP, BaseQty,
			ISNULL([OutputCGSTPerc],0)[OutputCGSTPerc],ISNULL([OutputCGST_Amt],0)[OutputCGST_Amt],ISNULL([OutputCGST_Taxable],0)[OutputCGST_Taxable],
			ISNULL([OutputSGSTPerc],0)[OutputSGSTPerc],ISNULL([OutputSGST_Amt],0)[OutputSGST_Amt],ISNULL([OutputSGST_Taxable],0)[OutputSGST_Taxable],
			ISNULL([OutputIGSTPerc],0)[OutputIGSTPerc],ISNULL([OutputIGST_Amt],0)[OutputIGST_Amt],ISNULL([OutputIGST_Taxable],0)[OutputIGST_Taxable],
			ISNULL([OutputUTGSTPerc],0)[OutputUTGSTPerc],ISNULL([OutputUTGST_Amt],0)[OutputUTGST_Amt],ISNULL([OutputUTGST_Taxable],0)[OutputUTGST_Taxable]
			FROM (
			SELECT salid,HSNCODE,PrdId,MRP,BaseQty,TaxCode,TaxPercAmt
			FROM #TAXPIVOT) up
			PIVOT (SUM(TaxPercAmt) FOR TaxCode IN ([OutputCGST_Taxable],[OutputCGST_Amt],[OutputCGSTPerc],
													[OutputSGST_Taxable],[OutputSGST_Amt],[OutputSGSTPerc],
													[OutputIGST_Taxable],[OutputIGST_Amt],[OutputIGSTPerc],
													[OutputUTGST_Taxable],[OutputUTGST_Amt],[OutputUTGSTPerc]))  AS PVT 
			)A
			GROUP BY salid,HSNCODE,PrdId,MRP,[OutputCGSTPerc],[OutputSGSTPerc],[OutputIGSTPerc],[OutputUTGSTPerc]			

	--SELECT * FROM #TAXDETAILS where prdid=1
 
	IF EXISTS(SELECT * FROM #OPENINGSTOCK)
	BEGIN
 		SELECT @MaxNo=MAX(RowNo) FROM #OPENINGSTOCK 
		
		SET @MinNo=1 
		
		WHILE @MinNo<=@MaxNo
		BEGIN
			SELECT @Prdid=Prdid,@MRP=MRP,@FinalClosingStock=ClosingStock,@HSNClosingStock=HSNWiseClosing FROM #OPENINGSTOCK WHERE RowNo=@MinNo

 			   TRUNCATE TABLE #TRANSDETAILS	
			   INSERT INTO  #TRANSDETAILS	
			   SELECT salid,PrdId,MRP,BaseQty 
				  FROM #TAXDETAILS WHERE PrdId=@Prdid AND MRP=@MRP  ORDER BY Salid
 				
				SELECT @MaxTransNo=MAX(Slno) FROM #TRANSDETAILS 
				
				SET @MinTransNo=1
				SET @ClosingStock=@FinalClosingStock  
			     
				WHILE @MinTransNo<=@MaxTransNo
				BEGIN
					SELECT @Salid=salid,@Baseqty= BaseQty  FROM #TRANSDETAILS WHERE Slno=@MinTransNo 
 
					 IF @ClosingStock>0
					 BEGIN
						IF @Baseqty>=@ClosingStock
						BEGIN
							INSERT INTO #FINALSTOCK(Salid,HSNCODE,PrdId,MRP,ClosingQty,BaseQty,ActualQty,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,OutputSGSTPerc,
													OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
													OutputUTGST_Amt,OutputUTGST_Taxable,Actual_CGST_Taxable,Actual_SGST_Taxable,Actual_UTGST_Taxable,
													Actual_IGST_Taxable,Actual_CGST_Tax,Actual_SGST_Tax,Actual_UTGST_Tax,Actual_IGST_Tax,PresumptiveTax_CGST,
													PresumptiveTax_IGST,ITCAllowed_CGST,ITCAllowed_SGST,ITCAllowed_IGST,ITCAllowed,HSNClosingStock)
							SELECT Salid,HSNCODE,PrdId,MRP,@FinalClosingStock,BaseQty,@ClosingStock,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,OutputSGSTPerc,
									OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
									OutputUTGST_Amt,OutputUTGST_Taxable,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@HSNClosingStock
									FROM #TAXDETAILS
									WHERE Salid=@Salid AND PrdId=@Prdid AND MRP=@MRP 
													
							BREAK						
						END
						ELSE
						BEGIN
							INSERT INTO #FINALSTOCK(Salid,HSNCODE,PrdId,MRP,ClosingQty,BaseQty,ActualQty,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,OutputSGSTPerc,
													OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
													OutputUTGST_Amt,OutputUTGST_Taxable,Actual_CGST_Taxable,Actual_SGST_Taxable,Actual_UTGST_Taxable,
													Actual_IGST_Taxable,Actual_CGST_Tax,Actual_SGST_Tax,Actual_UTGST_Tax,Actual_IGST_Tax,
													PresumptiveTax_CGST,PresumptiveTax_IGST,ITCAllowed_CGST,ITCAllowed_SGST,ITCAllowed_IGST,ITCAllowed,HSNClosingStock)
							SELECT Salid,HSNCODE,PrdId,MRP,@FinalClosingStock,BaseQty,@Baseqty,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,
								   OutputSGSTPerc,OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
									OutputUTGST_Amt,OutputUTGST_Taxable ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@HSNClosingStock
									FROM #TAXDETAILS
									WHERE Salid=@Salid AND PrdId=@Prdid AND MRP=@MRP 
									
							SET @ClosingStock=@ClosingStock-@Baseqty
						END					
						
			    	  END
			    	  SET  @MinTransNo=@MinTransNo+1	
				END
			
			SET @MinNo=@MinNo+1	
		END
	END
	
		--SELECT  P.HSNCode,T.PrdId,ISNULL(P.PresumptiveRate,0) PresumptiveRate 
		--INTO #PresumptiveTax
		--FROM  TBL_GR_BUILD_PH T INNER JOIN PresumptiveTax_GSTR2 P ON P.Brand=T.Brand_Code 
		--INNER JOIN #hsncode h on h.hsncode=p.HSNCode and T.PrdId=H.PrdId
		--WHERE Eligibility='YES'

		--UPDATE T SET PresumptiveTax=P.PresumptiveRate FROM #FINALSTOCK  T INNER JOIN #PresumptiveTax P ON T.PrdId=T.PrdId 
		--AND P.HSNCode=T.HSNCode
		
		UPDATE #FINALSTOCK SET PresumptiveTax_CGST=CASE WHEN (OutputCGSTPerc+OutputSGSTPerc)>=18 THEN 60 ELSE 40 END
		UPDATE #FINALSTOCK SET PresumptiveTax_IGST=CASE WHEN OutputIGSTPerc>18 THEN 30 ELSE 20 END
			
	---UPDATE TAX AND TAXABLE FOR ACTUAL ITC CLOSING
		UPDATE #FINALSTOCK		
				SET Actual_CGST_Taxable=CASE BaseQty WHEN 0 THEN 0 ELSE (OutputCGST_Taxable/BaseQty)*ActualQty END ,
					Actual_SGST_Taxable=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputSGST_Taxable/BaseQty)*ActualQty END ,
					Actual_UTGST_Taxable=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputUTGST_Taxable/BaseQty)*ActualQty END,
					Actual_IGST_Taxable=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputIGST_Taxable/BaseQty)*ActualQty END,
					Actual_CGST_Tax=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputCGST_Amt/BaseQty)*ActualQty END,
					Actual_SGST_Tax=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputSGST_Amt/BaseQty)*ActualQty END,
					Actual_UTGST_Tax=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputUTGST_Amt/BaseQty)*ActualQty END,
					Actual_IGST_Tax=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputIGST_Amt/BaseQty)*ActualQty END
	
	-----UPDATE ITC ALLOWED VALUE				
	  UPDATE #FINALSTOCK SET ITCAllowed_CGST= CAST(Actual_CGST_Taxable AS NUMERIC(18,6))*((CAST(OutputCGSTPerc AS NUMERIC(18,6))*CAST(PresumptiveTax_CGST AS NUMERIC(18,6)))/CAST(100 AS NUMERIC(18,6))) /CAST(100 AS NUMERIC(18,6))				
	  UPDATE #FINALSTOCK SET ITCAllowed_SGST= CAST(Actual_SGST_Taxable+Actual_UTGST_Taxable AS NUMERIC(18,6))*((CAST(OutputSGSTPerc+OutputUTGSTPerc AS NUMERIC(18,6))*CAST(PresumptiveTax_CGST AS NUMERIC(18,6)))/CAST(100 AS NUMERIC(18,6))) /CAST(100 AS NUMERIC(18,6))				
	  UPDATE #FINALSTOCK SET ITCAllowed_IGST= CAST(Actual_IGST_Taxable AS NUMERIC(18,6))*((CAST(OutputIGSTPerc AS NUMERIC(18,6))*CAST(PresumptiveTax_IGST AS NUMERIC(18,6)))/CAST(100 AS NUMERIC(18,6))) /CAST(100 AS NUMERIC(18,6))
	--SELECT * FROM #FINALSTOCK

		--SELECT * FROM #HSNWISESTOCKDETAILS 	
		TRUNCATE TABLE RptGSTR_TRANS2_CGST
		TRUNCATE TABLE RptGSTR_TRANS2_SGST

---GSTR TRANS2 FOR CENTRAL 		
		INSERT INTO RptGSTR_TRANS2_CGST(HSN,Unit,OpeningQty,OutwardQty,Value,CentralTax,IntegratedTax,ITCAllowed,ClosingQty,UsrId,
						[Group Name],GroupType)
		SELECT 	HSNCODE,'Piece',HSNClosingStock,SUM(ActualQty),SUM(Actual_CGST_Taxable),SUM(Actual_CGST_Tax),SUM(Actual_IGST_Tax),
			    SUM(ITCAllowed_CGST+ITCAllowed_IGST),0,@Pi_UsrId,'',2			
		FROM(	 
		SELECT HSNCODE,PrdId,MRP,ClosingQty,SUM(ActualQty)ActualQty,SUM(Actual_CGST_Taxable)Actual_CGST_Taxable,SUM(Actual_CGST_Tax)Actual_CGST_Tax,
			SUM(Actual_IGST_Tax)Actual_IGST_Tax,SUM(ITCAllowed_CGST) ITCAllowed_CGST,SUM(ITCAllowed_IGST) ITCAllowed_IGST,HSNClosingStock
		FROM #FINALSTOCK 	
		GROUP BY HSNCODE,ClosingQty,PrdId,MRP,HSNClosingStock
		)A
		GROUP BY HSNCODE,HSNClosingStock
		
		UPDATE RptGSTR_TRANS2_CGST SET ClosingQty=OpeningQty-outwardQty

		INSERT INTO RptGSTR_TRANS2_CGST(HSN,Unit,OpeningQty,OutwardQty,Value,CentralTax,IntegratedTax,ITCAllowed,ClosingQty,UsrId,
						[Group Name],GroupType)
		SELECT 'Grand Total','',SUM(OpeningQty),SUM(OutwardQty),SUM(Value),SUM(CentralTax),SUM(IntegratedTax),SUM(ITCAllowed),
			 SUM(ClosingQty),@Pi_UsrId,'zzzzzz',3
		FROM RptGSTR_TRANS2_CGST


---GSTR TRANS2 FOR STATE 
		INSERT INTO RptGSTR_TRANS2_SGST(HSN,Unit,OpeningQty,OutwardQty,Value,StateTax,ITCAllowed,ClosingQty,UsrId,
						[Group Name],GroupType)
		SELECT 	HSNCODE,'Piece',HSNClosingStock,SUM(ActualQty),SUM(Actual_SGST_Taxable),SUM(Actual_SGST_Tax),SUM(ITCAllowed_SGST),
			 0,@Pi_UsrId,'',2			
		FROM(	 
		SELECT HSNCODE,PrdId,MRP,ClosingQty,SUM(ActualQty)ActualQty,SUM(Actual_SGST_Taxable+Actual_UTGST_Taxable)Actual_SGST_Taxable,SUM(Actual_SGST_Tax+Actual_UTGST_Tax)Actual_SGST_Tax,
			 SUM(ITCAllowed_SGST) ITCAllowed_SGST,HSNClosingStock
		FROM #FINALSTOCK 	
		GROUP BY HSNCODE,ClosingQty,PrdId,MRP,HSNClosingStock
		)A
		GROUP BY HSNCODE,HSNClosingStock
		
		UPDATE RptGSTR_TRANS2_SGST SET ClosingQty=OpeningQty-outwardQty

		INSERT INTO RptGSTR_TRANS2_SGST(HSN,Unit,OpeningQty,OutwardQty,Value,StateTax,ITCAllowed,ClosingQty,UsrId,
						[Group Name],GroupType)
		SELECT 'Grand Total','',SUM(OpeningQty),SUM(OutwardQty),SUM(Value),SUM(StateTax),SUM(ITCAllowed),SUM(ClosingQty),@Pi_UsrId,'zzzzzz',3
		FROM RptGSTR_TRANS2_SGST
		
		DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptGSTR_TRANS2_CGST
		WHERE UsrId=@Pi_UsrId
		
		SELECT * FROM RptGSTR_TRANS2_CGST WHERE UsrId=@Pi_UsrId
		SELECT * FROM RptGSTR_TRANS2_SGST WHERE UsrId=@Pi_UsrId
END
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and RptId=417
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSRT 410',417,'GSTRTRANS1_CDNR','FORM GSTR1-CNDR',1
GO
DELETE FROM RptHeader WHERE RptId=417
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'GSTRTRANS1_CDNR','FORM GSTR1-CNDR',417,'FORM GSTR1-CNDR','Proc_RptGSTRTRANS1_CDNR','RptGSTRTRANS1_CDNR','RptGSTRTRANS1_CDNR.rpt',0
GO
DELETE FROM RptDetails where RPTID=417
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (417,2,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (417,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=417
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 417,208,1,'January' UNION
SELECT 417,208,2,'February' UNION
SELECT 417,208,3,'March' UNION
SELECT 417,208,4,'April' UNION
SELECT 417,208,5,'May' UNION
SELECT 417,208,6,'June' UNION
SELECT 417,208,7,'July' UNION
SELECT 417,208,8,'August' UNION
SELECT 417,208,9,'September' UNION
SELECT 417,208,10,'October' UNION
SELECT 417,208,11,'November' UNION
SELECT 417,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=417
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,417,'FORM GSTR1-CNDR',1,'GSTIN/UIN of Recipient',20,1,0,1,1,'GSTIN/UIN','of Recipient','',0,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',2,'Recipient Code in application',20,1,0,1,1,'Recipient Code','in application','',0,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',3,'Recipient Name',20,1,0,1,1,'Recipient Name','','',0,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',4,'Invoice/Advance Receipt Number',50,1,0,2,3,'Invoice/Advance','Receipt Number','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',5,'Invoice/Advance Receipt date',20,1,0,2,3,'Invoice/Advance','Receipt date','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',6,'Note/Refund Voucher Number',50,1,0,2,3,'Note/Refund','Voucher Number','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',7,'Note/Refund Voucher date',20,1,0,2,3,'Note/Refund','Voucher date','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',8,'Document Type',50,1,0,2,3,'Document Type','','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',9,'Reason For Issuing document',50,1,0,2,3,'Reason For','Issuing document','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',10,'Place Of Supply',20,1,0,2,3,'Place Of Supply','','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',11,'Note/Refund Voucher Value',20,1,0,2,3,'Note/Refund','Voucher Value','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',12,'Rate',20,1,0,2,3,'Rate','','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',13,'Taxable Value',20,1,0,2,3,'Taxable','Value','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',14,'Cess Amount',20,1,0,2,3,'Cess','Amount','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',15,'Pre GST',20,1,0,2,3,'Pre GST','','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',16,'IGST rate',20,1,0,2,3,'IGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',17,'IGST amount',20,1,0,2,3,'IGST','Amount','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',18,'CGST rate',20,1,0,2,3,'CGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',19,'CGST amount',20,1,0,2,3,'CGST','Amount','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',20,'SGST/UTGST rate',20,1,0,2,3,'SGST/UTGST','Rate','',2,GETDATE()
UNION ALL
SELECT 1,417,'FORM GSTR1-CNDR',21,'SGST/UTGST amount',20,1,0,2,3,'SGST/UTGST','Amount','',2,GETDATE()
GO
--DELETE FROM RptGridView WHERE RPTID=411
--INSERT INTO RptGridView 
--SELECT 411,'RptDistributorTurnOver.rpt',1,0,1,1 
--GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptGSTRTRANS1_CDNR')
DROP TABLE RptGSTRTRANS1_CDNR
GO
CREATE TABLE RptGSTRTRANS1_CDNR
(
	Slno								Int IDENTITY(1,1),
	[GSTIN/UIN of Recipient]			NVARCHAR(20),
	[Recipient Code in application]		NVarchar(50),
	[Recipient Name]					NVarchar(100),
	[Invoice/Advance Receipt Number]	NVARCHAR(50),
	[Invoice/Advance Receipt date]		NVARCHAR(10),
	[Note/Refund Voucher Number]		NVARCHAR(50),
	[Note/Refund Voucher date]			NVARCHAR(10),
	[Document Type]						VARCHAR(10),
	[Reason For Issuing document]		VARCHAR(100),
	[Place Of Supply]					NVARCHAR(200),
	[Note/Refund Voucher Value]			NUMERIC(18,2),
	[Rate]								NUMERIC(18,2),	
	[Taxable Value]						NUMERIC(18,2),
	[Cess Amount]						NUMERIC(18,2),
	[Pre GST]							VARCHAR(10),
	[IGST rate]							Numeric(32,2),
	[IGST amount]						Numeric(32,2),
	[CGST rate]							Numeric(32,2),
	[CGST amount]						Numeric(32,2),
	[SGST/UTGST rate]					Numeric(32,2),
	[SGST/UTGST amount]					Numeric(32,2),			
	[UsrId]								INT,
	[Group Name]						VARCHAR(100),
	GroupType							TINYINT
)
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and RptId=418
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSRT 410',418,'GSTRTRANS1_CDNUR','FORM GSTR1-CDNUR',1
GO
DELETE FROM RptHeader WHERE RptId=418
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'GSTRTRANS1_CDNUR','FORM GSTR1-CDNUR',418,'FORM GSTR1-CDNUR','Proc_RptGSTRTRANS1_CDNUR','RptGSTRTRANS1_CDNUR','RptGSTRTRANS1_CDNUR.rpt',0
GO
DELETE FROM RptDetails where RPTID=418
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (418,2,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (418,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=418
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 418,208,1,'January' UNION
SELECT 418,208,2,'February' UNION
SELECT 418,208,3,'March' UNION
SELECT 418,208,4,'April' UNION
SELECT 418,208,5,'May' UNION
SELECT 418,208,6,'June' UNION
SELECT 418,208,7,'July' UNION
SELECT 418,208,8,'August' UNION
SELECT 418,208,9,'September' UNION
SELECT 418,208,10,'October' UNION
SELECT 418,208,11,'November' UNION
SELECT 418,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=418
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,418,'FORM GSTR1-CDNUR',1,'UR Type',20,1,0,1,1,'UR Type','','',0,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',2,'Note/Refund Voucher Number',50,1,0,2,3,'Note/Refund','Voucher Number','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',3,'Note/Refund Voucher date',20,1,0,2,3,'Note/Refund','Voucher date','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',4,'Document Type',50,1,0,2,3,'Document Type','','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',5,'Invoice/Advance Receipt Number',20,1,0,2,3,'Invoice/Advance','Receipt Number','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',6,'Invoice/Advance Receipt date',50,1,0,2,3,'Invoice/Advance','Receipt date','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',7,'Reason For Issuing document',50,1,0,2,3,'Reason For','Issuing document','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',8,'Place Of Supply',20,1,0,2,3,'Place Of Supply','','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',9,'Note/Refund Voucher Value',20,1,0,2,3,'Note/Refund','Voucher Value','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',10,'Rate',20,1,0,2,3,'Rate','','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',11,'Taxable Value',20,1,0,2,3,'Taxable ','Value','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',12,'Cess Amount',20,1,0,2,3,'Cess ','Amount','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',13,'Pre GST',20,1,0,2,3,'Pre GST','','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',14,'IGST rate',20,1,0,2,3,'IGST ','Rate','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',15,'IGST amount',20,1,0,2,3,'IGST ','Amount','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',16,'CGST rate',20,1,0,2,3,'CGST ','Rate','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',17,'CGST amount',20,1,0,2,3,'CGST ','Amount','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',18,'SGST/UTGST rate',20,1,0,2,3,'SGST/UTGST ','Rate','',2,GETDATE()
UNION ALL
SELECT 1,418,'FORM GSTR1-CDNUR',19,'SGST/UTGST amount',20,1,0,2,3,'SGST/UTGST ','Amount','',2,GETDATE()
GO
--DELETE FROM RptGridView WHERE RPTID=411
--INSERT INTO RptGridView 
--SELECT 411,'RptDistributorTurnOver.rpt',1,0,1,1 
--GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptGSTRTRANS1_CDNUR')
DROP TABLE RptGSTRTRANS1_CDNUR
GO
CREATE TABLE RptGSTRTRANS1_CDNUR
(
	[Slno]								INT IDENTITY(1,1),
	[UR Type]							VARCHAR(50),
	[Note/Refund Voucher Number]		NVARCHAR(50),
	[Note/Refund Voucher date]			NVARCHAR(10),
	[Document Type]						VARCHAR(50),
	[Invoice/Advance Receipt Number]	NVARCHAR(50),
	[Invoice/Advance Receipt date]		NVARCHAR(10),
	[Reason For Issuing document]		VARCHAR(100),
	[Place Of Supply]					NVARCHAR(200),
	[Note/Refund Voucher Value]			NUMERIC(18,2),
	[Rate]								NUMERIC(18,2),	
	[Taxable Value]						NUMERIC(18,2),
	[Cess Amount]						NUMERIC(18,2),
	[Pre GST]							VARCHAR(10),
	[IGST rate]							Numeric(32,2),
	[IGST amount]						Numeric(32,2),
	[CGST rate]							Numeric(32,2),
	[CGST amount]						Numeric(32,2),
	[SGST/UTGST rate]					Numeric(32,2),
	[SGST/UTGST amount]					Numeric(32,2),			
	[UsrId]								INT,
	[Group Name]						VARCHAR(100),
	GroupType							TINYINT
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ReturnExcelReportDynamic' and xtype in ('TF','FN'))
DROP FUNCTION Fn_ReturnExcelReportDynamic
GO
--SELECT dbo.Fn_ReturnExcelReportDynamic(409)
CREATE FUNCTION Fn_ReturnExcelReportDynamic(@RptId	AS INT)
RETURNS INT
AS
/************************************************
* PROCEDURE  : Fn_ReturnExcelReportDynamic
* PURPOSE    : To Validate and Return Dynamic Reports
* CREATED BY : S.Moorthi
* CREATED ON : 09/08/2017
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN

DECLARE @ReturnVal AS INT
SET @ReturnVal=0
	
	IF @RptId  in (401 ,402 ,403 ,404 ,405 ,406,407 ,409 ,411,413,414,415,416,417,418,419,420,421,422,423,424)
	BEGIN
		SET @ReturnVal=1
	END

RETURN @ReturnVal
END
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Fn_ReturnGSTRFooter' AND XTYPE IN('TF','FN'))
DROP FUNCTION Fn_ReturnGSTRFooter
GO
--SELECT * FROM DBO.Fn_ReturnGSTRFooter(413) 
CREATE FUNCTION Fn_ReturnGSTRFooter(@RptId AS INT)        
RETURNS @pTempTbl TABLE         
 (        
      HeaderFooter Varchar(200)    
 )        
AS         
 BEGIN   
	 IF @RptId IN (411)
	 BEGIN
		  Insert INTO @pTempTbl
		  select 'Verification (by Authorised signatory)' UNION ALL
		  SELECT 'I hereby solemnly affirm and decalre that the information given herein above is true and' UNION ALL
		  Select 'correct to the best of my knowledge and belief and nothing has been concealed there from.' UNION ALL 
		  select '' UNION ALL
		  SELECT 'Instructions:' UNION ALL
		  SELECT '1) Value of Taxable supplies = Value of invoice + value of Debit Notes - value of credit notes + value of addvances' UNION ALL
		  SELECT 'received for which invoices have not been issued in the same month - value of advances adjusted against invoices' UNION ALL
		  select '' UNION ALL
		  SELECT '2) Details of advances as well as adjusted of same against invoices to be adjusted and not shown separately' UNION ALL
		  SELECT '3) Amendment in any details to be adjusted and shown separately.'
     END
 RETURN        
END
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and GrpCode='FORMGSTR1HSN' and RptId=419
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSRT 410',419,'FORMGSTR1HSN','FORM GSTR1-HSN',1
GO
DELETE FROM RptHeader WHERE RptId=419
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'FORMGSTR1HSN','FORM GSTR1-HSN',419,'FORM GSTR1-HSN','Proc_RptGSTR1_HSNCODE','RptGSTR1_HSNCODE','RptGSTR1_HSNCODE.rpt',0
GO
DELETE FROM RptDetails where RPTID=419
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (419,1,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (419,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=419
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 419,208,1,'January' UNION
SELECT 419,208,2,'February' UNION
SELECT 419,208,3,'March' UNION
SELECT 419,208,4,'April' UNION
SELECT 419,208,5,'May' UNION
SELECT 419,208,6,'June' UNION
SELECT 419,208,7,'July' UNION
SELECT 419,208,8,'August' UNION
SELECT 419,208,9,'September' UNION
SELECT 419,208,10,'October' UNION
SELECT 419,208,11,'November' UNION
SELECT 419,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=419
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,419,'FORM GSTR1-HSN',1,'HSN',50,1,0,1,1,'HSN','','',0,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',2,'Description',20,1,0,1,1,'Description','','',0,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',3,'UQC',20,1,0,1,1,'UQC','','',0,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',4,'Total Quantity',30,1,0,2,2,'Total Quantity','','',0,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',5,'Total Value',20,1,0,2,3,'Total Value','','',2,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',6,'Taxable Value',20,1,0,2,3,'Taxable Value','','',2,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',8,'Integrated Tax Amount',20,1,0,2,3,'Integrated Tax Amount','','',2,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',9,'Central Tax Amount',20,1,0,2,3,'Central Tax Amount','','',2,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',10,'State/UT Tax Amount',20,1,0,2,3,'State/UT Tax Amount','','',2,GETDATE()
UNION ALL
SELECT 1,419,'FORM GSTR1-HSN',11,'Cess Amount',20,1,0,2,3,'Cess Amount','','',2,GETDATE()
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' and NAME='RptGSTR1_HSNCODE')
DROP TABLE RptGSTR1_HSNCODE
GO
CREATE TABLE RptGSTR1_HSNCODE
(
Slno INT IDENTITY(1,1),
[HSN]	Varchar(20),
[Description]	Varchar(200),
[UQC]	Varchar(20),
[Total Quantity]	BIGINT,
[Total Value]	Numeric(32,4),
[Taxable Value]	Numeric(32,4),
[Integrated Tax Amount]	Numeric(32,4),
[Central Tax Amount]	Numeric(32,4),
[State/UT Tax Amount]	Numeric(32,4),
[Cess Amount]	Numeric(32,4),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptGSTR1_HSNCODE')
DROP PROCEDURE Proc_RptGSTR1_HSNCODE
GO
/*
EXEC Proc_RptGSTR1_HSNCODE 419,2,1,'',0,1,1
 */
CREATE PROCEDURE [Proc_RptGSTR1_HSNCODE]
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
* PROCEDURE		: Proc_RptGSTR1_HSNCODE
* PURPOSE		: To Generate a report GSTR1 B2B
* CREATED		: Murugan.R
* CREATED DATE	: 13/04/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

		TRUNCATE TABLE RptGSTR1_HSNCODE
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017
		
		
		CREATE TABLE #RptGSTR1_HSNCODE
		(
			[HSN]	Varchar(20),
			[Description]	Varchar(200),
			[UQC]	Varchar(20),
			[Total Quantity]	BIGINT,
			[Total Value]	Numeric(32,4),
			[Taxable Value]	Numeric(32,4),
			[Integrated Tax Amount]	Numeric(32,4),
			[Central Tax Amount]	Numeric(32,4),
			[State/UT Tax Amount]	Numeric(32,4),
			[Cess Amount]	Numeric(32,4),
			UsrId INT,
			[Group Name] Varchar(100),
			GroupType TINYINT
		)
	
		SELECT DISTINCT Prdid,ColumnValue as HSNCode,Cast('' as Varchar(150)) as HSNDesc
		INTO #ProductHsnCode
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Product R ON R.Prdid=UT.MasterRecordId
		WHERE U.MasterId=1 and ColumnName='HSN Code' 
		
		SELECT DISTINCT Prdid,ColumnValue as HSNDesc
		INTO #ProductHsnDesc
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Product R ON R.Prdid=UT.MasterRecordId
		WHERE U.MasterId=1 and ColumnName='HSN Description' 
		
		Update A Set A.HSNdesc=B.HSNDesc FROM #ProductHsnCode A INNER JOIN #ProductHsnDesc B ON A.Prdid=B.Prdid
		
		SELECT PurRcptId 
		INTO #PurchaseReceipt
		FROM PurchaseReceipt WHERE VatGst='VAT' and GoodsRcvdDate Between '2017-01-01' and '2017-06-30'
		and Status=1
		
		SELECT Salid,Salinvno,SalInvdate,Prdslno,SUM(TaxableAmount) as TaxableAmount,SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
		INTO #Sales	
		FROM
		(		
			SELECT S.Salid,Salinvno,SalInvdate,Prdslno,
			ISNULL(CASE WHEN  TaxCode IN('OutputIGST','IGST','OutputCGST','CGST') THEN SUM(TaxableAmount) END,0) as TaxableAmount,
			ISNULL(CASE WHEN TaxCode IN('OutputIGST','IGST') THEN SUM(TaxAmount) END ,0) AS IGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputCGST','CGST') THEN SUM(TaxAmount) END ,0) AS CGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST') THEN SUM(TaxAmount) END ,0) AS SGSTUTTaxAmount
				
			FROM SalesInvoice S (NOLOCK) 
			INNER JOIN SalesInvoiceProductTax ST (NOLOCK) ON S.Salid=ST.SalId
			INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
			WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
			and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST')
			and ST.TaxableAmount>0
			GROUP BY S.Salid,Salinvno,SalInvdate,Prdslno,TaxCode
		)X GROUP BY Salid,Salinvno,SalInvdate,Prdslno
		
		SELECT  IDTMngRefNo,IDTMngDate,PrdSlNo,SUM(TaxableAmount) as TaxableAmount,SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
		INTO #IDTSales	
		FROM
		(		
			SELECT S.IDTMngRefNo,IDTMngDate,PrdSlNo,
			ISNULL(CASE WHEN  TaxCode IN('OutputIGST','IGST','InPutIGST','IDTIGST','OutputCGST','CGST','InPutCGST','IDTCGST') THEN SUM(TaxableAmount) END,0) as TaxableAmount,
			ISNULL(CASE WHEN TaxCode IN('OutputIGST','IGST','InPutIGST','IDTIGST') THEN SUM(TaxAmount) END ,0) AS IGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputCGST','CGST','InPutCGST','IDTCGST') THEN SUM(TaxAmount) END ,0) AS CGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST','InPutSGST','InPutUTGST','IDTSGST','IDTUTGST') THEN SUM(TaxAmount) END ,0) AS SGSTUTTaxAmount
				
			FROM IDTManagement S (NOLOCK) 
			INNER JOIN IDTManagementProductTax ST (NOLOCK) ON S.IDTMngRefNo=ST.IDTMngRefNo
			INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
			WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear 
			and TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST',
			'InPutIGST','InPutCGST','InPutSGST','InPutUTGST','IDTIGST','IDTCGST','IDTSGST','IDTUTGST')
			and ST.TaxableAmount>0
			GROUP BY  S.IDTMngRefNo,IDTMngDate,PrdSlNo,TaxCode
		)X GROUP BY  IDTMngRefNo,IDTMngDate,PrdSlNo
		
		SELECT  PurRetId,PurRetRefNo,PurRetDate,PrdSlNo,SUM(TaxableAmount) as TaxableAmount,SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
		INTO #PurchaseSales	
		FROM
		(		
			SELECT S.PurRetId,S.PurRetRefNo,PurRetDate,PrdSlNo,
			ISNULL(CASE WHEN  TaxCode IN('OutputIGST','IGST','InPutIGST','IDTIGST','OutputCGST','CGST','InPutCGST','IDTCGST') THEN SUM(ST.TaxableAmount) END,0) as TaxableAmount,
			ISNULL(CASE WHEN TaxCode IN('OutputIGST','IGST','InPutIGST','IDTIGST') THEN SUM(ST.TaxAmount) END ,0) AS IGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputCGST','CGST','InPutCGST','IDTCGST') THEN SUM(ST.TaxAmount) END ,0) AS CGSTTaxAmount ,
			ISNULL(CASE WHEN TaxCode IN('OutputSGST','OutputUTGST','SGST','UTGST','InPutSGST','InPutUTGST','IDTSGST','IDTUTGST') THEN SUM(ST.TaxAmount) END ,0) AS SGSTUTTaxAmount
				
			FROM PurchaseReturn S (NOLOCK) 
			INNER JOIN PurchaseReturnProductTax ST (NOLOCK) ON S.PurRetId=ST.PurRetId
			INNER JOIN #PurchaseReceipt PR ON PR.PurRcptId=S.PurRcptId
			INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
			WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear 
			and TaxCode IN('IGST','CGST','SGST','UTGST','InPutIGST','InPutCGST','InPutSGST','InPutUTGST')
			and ST.TaxableAmount>0
			GROUP BY  S.PurRetId,S.PurRetRefNo,PurRetDate,PrdSlNo,TaxCode
		)X GROUP BY  PurRetId,PurRetRefNo,PurRetDate,PrdSlNo

		INSERT INTO #RptGSTR1_HSNCODE([HSN],[Description],[UQC],[Total Quantity],[Total Value],[Taxable Value],[Integrated Tax Amount],
		[Central Tax Amount],[State/UT Tax Amount],[Cess Amount],UsrId,[Group Name],GroupType)
		SELECT HSNCode,HSNDesc,'NOS-Numbers' as [UQC],SUM(BaseQty) as BaseQty,SUM(SalesValue) as SalesValue,
		SUM(TaxableAmount) as TaxableAmount,
		SUM(IGSTTaxAmount) as IGSTTaxAmount,
		SUM(CGSTTaxAmount) as CGSTTaxAmount,
		SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount,
		0.00 as CessAmount,
		@Pi_UsrId,'' as [Group Type],2
		FROM
		(		
			SELECT ISNULL(HSNCode,'') as HSNCode,ISNULL(HSNDesc,'') as HSNDesc,SUM(BaseQty) as BaseQty,SUM(PrdNetAmount) as SalesValue,
			SUM(TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
			FROM #Sales S INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON S.Salid=SIP.Salid and S.Prdslno=SIP.Slno
			LEFT OUTER JOIN #ProductHsnCode P ON P.Prdid=SIP.Prdid
			GROUP BY 
			ISNULL(HSNCode,''),ISNULL(HSNDesc,'')
			UNION ALL
			SELECT ISNULL(HSNCode,'') as HSNCode,ISNULL(HSNDesc,'') as HSNDesc,SUM(Qty) as BaseQty,SUM(PrdNetAmount) as SalesValue,
			SUM(TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
			FROM #IDTSales S INNER JOIN IDTManagementProduct SIP (NOLOCK) ON S.IDTMngRefNo=SIP.IDTMngRefNo and S.Prdslno=SIP.Prdslno
			LEFT OUTER JOIN #ProductHsnCode P ON P.Prdid=SIP.Prdid
			GROUP BY 
			ISNULL(HSNCode,''),ISNULL(HSNDesc,'')
			UNION ALL
			SELECT ISNULL(HSNCode,'') as HSNCode,ISNULL(HSNDesc,'') as HSNDesc,SUM(RetSalBaseQty+RetUnSalBaseQty) as BaseQty,SUM(PrdNetAmount) as SalesValue,
			SUM(TaxableAmount) as TaxableAmount,
			SUM(IGSTTaxAmount) as IGSTTaxAmount,
			SUM(CGSTTaxAmount) as CGSTTaxAmount,
			SUM(SGSTUTTaxAmount) as SGSTUTTaxAmount
			FROM #PurchaseSales S INNER JOIN PurchaseReturnProduct SIP (NOLOCK) ON S.PurRetId=SIP.PurRetId and S.Prdslno=SIP.Prdslno
			LEFT OUTER JOIN #ProductHsnCode P ON P.Prdid=SIP.Prdid
			GROUP BY 
			ISNULL(HSNCode,''),ISNULL(HSNDesc,'')
		) X GROUP BY HSNCode,HSNDesc
		

			
		IF NOT EXISTS(SELECT 'X' FROM #RptGSTR1_HSNCODE)
		BEGIN
			SELECT * FROM RptGSTR1_HSNCODE (NOLOCK) WHERE UsrId=@Pi_UsrId
			RETURN
		END
		
		INSERT INTO RptGSTR1_HSNCODE([HSN],[Description],[UQC],[Total Quantity],[Total Value],[Taxable Value],[Integrated Tax Amount],
		[Central Tax Amount],[State/UT Tax Amount],[Cess Amount],UsrId,[Group Name],GroupType)		
		SELECT [HSN],[Description],[UQC],[Total Quantity],[Total Value],[Taxable Value],[Integrated Tax Amount],
		[Central Tax Amount],[State/UT Tax Amount],[Cess Amount],UsrId,[Group Name],GroupType
		FROM #RptGSTR1_HSNCODE ORDER BY [HSN]
		
		INSERT INTO RptGSTR1_HSNCODE([HSN],[Description],[UQC],[Total Quantity],[Total Value],
		[Taxable Value],[Integrated Tax Amount],[Central Tax Amount],[State/UT Tax Amount],
		[Cess Amount],UsrId,[Group Name],GroupType)
		SELECT '' as [HSN],'' as [Description],'' as [UQC],SUM([Total Quantity]),SUM([Total Value]) as [Total Value],
		SUM([Taxable Value]),SUM([Integrated Tax Amount]),SUM([Central Tax Amount]),SUM([State/UT Tax Amount]),
		SUM([Cess Amount]),
		@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
		FROM #RptGSTR1_HSNCODE
		
		
		SELECT * FROM RptGSTR1_HSNCODE WHERE UsrId=@Pi_UsrId
				
END
GO
DELETE FROM Tbl_Generic_Reports WHERE RPTNAME='GSTR TRANS 2 Details Report'
INSERT INTO Tbl_Generic_Reports
SELECT MAX(RPTID)+1,'GSTR TRANS 2 Details Report','Proc_GR_GSTRTrans2Report','GSTR TRANS 2 Details Report','Not Available' 
FROM Tbl_Generic_Reports
GO
DELETE FROM Tbl_Generic_Reports_Filters WHERE RPTNAME='GSTR TRANS 2 Details Report'
INSERT INTO Tbl_Generic_Reports_Filters
SELECT (SELECT RPTID FROM Tbl_Generic_Reports WHERE RPTNAME='GSTR TRANS 2 Details Report'),1,'Not Applicable','Proc_GR_GSTRTrans2Report_Values','GSTR TRANS 2 Details Report' UNION
SELECT (SELECT RPTID FROM Tbl_Generic_Reports WHERE RPTNAME='GSTR TRANS 2 Details Report'),2,'Not Applicable','Proc_GR_GSTRTrans2Report_Values','GSTR TRANS 2 Details Report' UNION
SELECT (SELECT RPTID FROM Tbl_Generic_Reports WHERE RPTNAME='GSTR TRANS 2 Details Report'),3,'Not Applicable','Proc_GR_GSTRTrans2Report_Values','GSTR TRANS 2 Details Report' UNION
SELECT (SELECT RPTID FROM Tbl_Generic_Reports WHERE RPTNAME='GSTR TRANS 2 Details Report'),4,'Not Applicable','Proc_GR_GSTRTrans2Report_Values','GSTR TRANS 2 Details Report' UNION
SELECT (SELECT RPTID FROM Tbl_Generic_Reports WHERE RPTNAME='GSTR TRANS 2 Details Report'),5,'Not Applicable','Proc_GR_GSTRTrans2Report_Values','GSTR TRANS 2 Details Report' UNION
SELECT (SELECT RPTID FROM Tbl_Generic_Reports WHERE RPTNAME='GSTR TRANS 2 Details Report'),6,'Not Applicable','Proc_GR_GSTRTrans2Report_Values','GSTR TRANS 2 Details Report'
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_GR_GSTRTrans2Report')
DROP PROCEDURE Proc_GR_GSTRTrans2Report
GO
--EXEC Proc_GR_GSTRTrans2Report '','2017-07-01','2017-07-01' ,'','','','','',''
CREATE PROCEDURE Proc_GR_GSTRTrans2Report
(
	@Pi_RptName		NVARCHAR(100),
	@Pi_FromDate	DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_Filter1		NVARCHAR(100),
	@Pi_Filter2		NVARCHAR(100),
	@Pi_Filter3		NVARCHAR(100),
	@Pi_Filter4		NVARCHAR(100),
	@Pi_Filter5		NVARCHAR(100),
	@Pi_Filter6		NVARCHAR(100)
)
AS
/************************************************
* PROCEDURE  : Proc_GR_GSTRTrans2Report
* PURPOSE    : To Generate GSTR_TRANS2 Report
* CREATED BY : Karthick
* CREATED ON : 07/08/2017
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON
 
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @ITCStartDate DATETIME 
		DECLARE @LastMonthEndDate DATETIME
		DECLARE @Date DATETIME
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		DECLARE @MinNo AS INT
		DECLARE @MaxNo AS INT
		DECLARE @HSNCODE AS NVARCHAR(50)
		DECLARE @Prdid AS INT
		DECLARE @MRP AS NUMERIC(18,2)
		DECLARE @Lcnid AS INT
		DECLARE @ClosingStock AS INT
		DECLARE @MinTransNo AS INT
		DECLARE @MaxTransNo	AS INT
		DECLARE @Salid AS INT
		DECLARE @Baseqty AS INT
		DECLARE @FinalClosingStock AS INT		
		DECLARE @HSNClosingStock AS INT	
		
	CREATE TABLE #TAXPIVOT
	(
		 SLNO			INT IDENTITY(1,1),
		 Salid			INT,
		 HSNCODE		NVARCHAR(50),
		 PrdId			INT,
		 MRP			NUMERIC(18,2),	
		 BaseQty		INT,
		 TaxCode		NVARCHAR(50),
		 TaxPercAmt		NUMERIC(18,6)
	)

	CREATE TABLE #TAXDETAILS
	(
		Salid				INT,
		HSNCODE				NVARCHAR(50),
		PrdId				INT,
		MRP					NUMERIC(18,2),
		BaseQty				INT,
		[OutputCGSTPerc]	NUMERIC(18,2),
		[OutputCGST_Amt]	NUMERIC(18,6),
		[OutputCGST_Taxable]NUMERIC(18,6),		
		[OutputSGSTPerc]	NUMERIC(18,2),
		[OutputSGST_Amt]	NUMERIC(18,6),
		[OutputSGST_Taxable]NUMERIC(18,6),
		[OutputIGSTPerc]	NUMERIC(18,2),
		[OutputIGST_Amt]	NUMERIC(18,6),
		[OutputIGST_Taxable]NUMERIC(18,6),
		[OutputUTGSTPerc]	NUMERIC(18,2),
		[OutputUTGST_Amt]	NUMERIC(18,6),
		[OutputUTGST_Taxable]NUMERIC(18,6)
	)

	CREATE TABLE #FINALSTOCK
	(
		Salid				INT,
		HSNCODE				NVARCHAR(50),
		PrdId				INT,
		MRP					NUMERIC(18,2),
		ClosingQty			INT,
		BaseQty				INT,
		ActualQty			INT,
		[OutputCGSTPerc]	NUMERIC(18,2),
		[OutputCGST_Amt]	NUMERIC(18,6),
		[OutputCGST_Taxable]NUMERIC(18,6),		
		[OutputSGSTPerc]	NUMERIC(18,2),
		[OutputSGST_Amt]	NUMERIC(18,6),
		[OutputSGST_Taxable]NUMERIC(18,6),
		[OutputIGSTPerc]	NUMERIC(18,2),
		[OutputIGST_Amt]	NUMERIC(18,6),
		[OutputIGST_Taxable]NUMERIC(18,6),
		[OutputUTGSTPerc]	NUMERIC(18,2),
		[OutputUTGST_Amt]	NUMERIC(18,6),
		[OutputUTGST_Taxable]NUMERIC(18,6),
		Actual_CGST_Taxable	NUMERIC(18,6),	
		Actual_SGST_Taxable	NUMERIC(18,6),
		Actual_UTGST_Taxable NUMERIC(18,6),
		Actual_IGST_Taxable	NUMERIC(18,6),
		Actual_CGST_Tax		NUMERIC(18,6),	
		Actual_SGST_Tax		NUMERIC(18,6),
		Actual_UTGST_Tax	NUMERIC(18,6),
		Actual_IGST_Tax		NUMERIC(18,6),
		PresumptiveTax_CGST	NUMERIC(18,2),
		PresumptiveTax_IGST	NUMERIC(18,2),
		ITCAllowed_CGST		NUMERIC(18,6),	
		ITCAllowed_SGST		NUMERIC(18,6),	
		ITCAllowed_IGST		NUMERIC(18,6),	
		ITCAllowed			NUMERIC(18,6),
		HSNClosingStock		INT
	)	
			  
	CREATE TABLE #TRANSDETAILS
	(	
		Slno		INT IDENTITY(1,1),
		salid		INT,
		PrdId		INT,
		MRP			NUMERIC(18,2),
		BaseQty		INT
	)
 
		SET @Jcmyear = YEAR(@Pi_FromDate)
		SET @MonthStart = MONTH(@Pi_FromDate)
		 
		
		SET @Date=CONVERT(DATETIME,CONVERT(Varchar(10),CAST(@Jcmyear as Varchar(5)) +'-'+CASE WHEN @MonthStart<10 THEN '0'+CAST(@MonthStart AS Varchar(4)) ELSE CAST(@MonthStart AS Varchar(4)) END +'-01',121),121)
	

		IF @Date<'2017-07-01'
		BEGIN
			RETURN
		END 
		
		SELECT @ITCStartDate=CONVERT(VARCHAR(10),MIN(AuthDate),121) FROM VatClosingStock (NOLOCK)
		SELECT @LastMonthEndDate= DATEADD(DAY,-1,DATEADD(MONTH,DATEDIFF(month,0,@Date),0))
 
		
		--SELECT @ITCStartDate,@LastMonthEndDate,@MonthStart,@Jcmyear
		
		SELECT DISTINCT ColumnValue as HSNCODE,E.PrdId INTO #HSNCode
		FROM UDCHD A (NOLOCK)
		INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
		INNER JOIN UdcDetails C (NOLOCK) ON B.MasterId=C.MasterId
			AND B.UdcMasterId=C.UdcMasterId
		INNER JOIN Product E (NOLOCK) ON E.Prdid=C.MasterRecordId
		WHERE MasterName='Product Master' and ColumnName='HSN Code'

		SELECT  H.HSNCODE,V.prdid,MRP,V.Lcnid,SUM(GrnQty)ClosingStock 
		INTO #VATCLOSINGSTOCK
		FROM VatClosingStock V 
		INNER JOIN PurchaseReceipt P ON V.GrnRefNo=P.PurRcptRefNo AND V.CmpInvNo=P.CmpInvNo AND P.LcnId=V.Lcnid
		INNER JOIN #HSNCode H ON H.PrdId=V.Prdid
		GROUP BY H.HSNCODE,V.prdid,MRP,V.Lcnid

---GET PURCHASE RETURN QUANTITY
		SELECT HSNCODE,Prdid,MRP,LcnId,SUM(RetSalBaseQty)RetSalBaseQty INTO #PurchaseReturnQty  
		FROM
		(
				SELECT H.HSNCODE,PRP.Prdid,PrdUnitMRP AS MRP,PR.LcnId,SUM(RetSalBaseQty)RetSalBaseQty 
				FROM PurchaseReturn PR 
				INNER JOIN PurchaseReturnProduct PRP ON PR.PurRetId=PRP.PurRetId
				INNER JOIN #HSNCode H ON H.PrdId=PRP.Prdid 
				WHERE PR.VatGst='GST' AND PurRcptId IN(SELECT PurRcptId FROM PurchaseReceipt(NOLOCK) WHERE  VatGst ='VAT')
				AND purretdate BETWEEN @ITCStartDate AND  @LastMonthEndDate
				GROUP BY H.HSNCODE,PRP.Prdid,PrdUnitMRP,PR.LcnId
				UNION ALL
				SELECT H.HSNCODE,IT.Prdid,PrdMRPRate AS MRP,I.LcnId,SUM(Qty)RetSalBaseQty
				FROM IDTManagement I (NOLOCK) 
				INNER JOIN IDTManagementProduct IT (NOLOCK) ON I.IDTMngRefNo=IT.IDTMngRefNo
				INNER JOIN #HSNCode H ON H.PrdId=IT.Prdid 
				WHERE Status=1 and IDTMngDate BETWEEN @ITCStartDate AND  @LastMonthEndDate
				and StkMgmtTypeId=2  
				GROUP BY H.HSNCODE,IT.Prdid,PrdMRPRate,I.LcnId
		)A		GROUP BY HSNCODE,Prdid,MRP,LcnId 
		
--GST TOTAL OPENING QTY		
		UPDATE V SET ClosingStock=(ClosingStock-RetSalBaseQty) FROM #VATCLOSINGSTOCK V LEFT OUTER JOIN #PurchaseReturnQty P ON 
		V.HSNCODE=P.HSNCODE AND V.Prdid=P.Prdid AND V.MRP=P.MRP AND P.LcnId=V.Lcnid
		WHERE (ClosingStock-RetSalBaseQty)>0
		
		SELECT PrdId,MRP,LcnId,SUM(BaseQty)BaseQty INTO #MONTHCLOSING
		FROM
		(
			SELECT SIP.PrdId,PrdUnitMRP AS MRP,BaseQty,LcnId 
			FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId   
			WHERE Salinvdate BETWEEN @ITCStartDate AND  @LastMonthEndDate AND DlvSts IN (4,5)
		UNION ALL
			SELECT RP.PrdId,RP.PrdUnitMRP  AS MRP,-1*RP.BaseQty,SI.LcnId
			FROM ReturnHeader R INNER JOIN ReturnProduct RP(NOLOCK) ON R.ReturnID=RP.ReturnID 
			INNER JOIN SALESINVOICE SI ON SI.SALID=R.SALID 
			WHERE ReturnDate BETWEEN @ITCStartDate AND @LastMonthEndDate AND STATUS IN(0) AND InvoiceType=1 AND SI.VATGST='GST' 
		)A
		GROUP BY PrdId,MRP,LcnId

		SELECT V.HSNCODE AS HSN_Code,V.prdid,V.MRP,V.Lcnid,(ClosingStock-ISNULL(BaseQty,0))ClosingStock,0 AS HSNWiseClosing,ROW_NUMBER() OVER(ORDER BY V.Prdid,V.MRP)RowNo
		INTO #OPENINGSTOCK
		FROM #VATCLOSINGSTOCK V LEFT OUTER JOIN #MONTHCLOSING M ON  V.Prdid=M.prdid AND V.MRP=M.MRP
		AND V.lcnid=M.lcnid  WHERE ClosingStock-ISNULL(BaseQty,0)>0

		SELECT HSN_Code,Lcnid,SUM(ClosingStock) AS HSNWiseClosing INTO #HsnWs_Closing FROM #OPENINGSTOCK GROUP BY HSN_Code,Lcnid
		
		UPDATE O SET O.HSNWiseClosing=H.HSNWiseClosing FROM #OPENINGSTOCK O INNER JOIN #HsnWs_Closing H ON O.HSN_Code=H.HSN_Code AND O.Lcnid=H.Lcnid
		
		--select * from #OPENINGSTOCK
		
		---SALES DETAILS
			SELECT   SI.salid,SI.LcnId,SIP.PrdId,SIP.PrdUnitMRP AS MRP,SIP.SlNo,BaseQty INTO #SALESDETAILS 
			FROM SalesInvoice SI(NOLOCK) INNER JOIN SalesInvoiceProduct SIP(NOLOCK) ON SI.SalId=SIP.SalId  
			WHERE MONTH(SALINVDATE)=@MonthStart AND YEAR(SALINVDATE)=@Jcmyear AND DlvSts IN (4,5)
			
			SELECT * INTO #SalesInvoiceProductTax FROM SalesInvoiceProductTax 
				WHERE SalId IN (SELECT DISTINCT salid FROM #SALESDETAILS)
		
		--RETURN DETAILS
			SELECT R.ReturnID,SI.salid,SI.LcnId,RP.PrdId,RP.PrdUnitMRP AS MRP,RP.Slno,RP.BaseQty AS BaseQty INTO #RETURNDETAILS
			FROM ReturnHeader R(NOLOCK) INNER JOIN ReturnProduct RP(NOLOCK) ON R.ReturnID=RP.ReturnID 
			INNER JOIN SalesInvoice SI ON SI.salid=R.salid 
			WHERE MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear  AND STATUS IN(0) AND InvoiceType=1 AND SI.VATGST='GST' 

			SELECT * INTO #ReturnProductTax FROM ReturnProductTax 
				WHERE ReturnID IN (SELECT DISTINCT ReturnID FROM #RETURNDETAILS)
			
		---CALCULTE TAX AND TAXABLE SPILT
			INSERT  INTO #TAXPIVOT
  			SELECT salid,HSNCODE,PrdId,MRP,BaseQty,TaxCode,TaxPercAmt 
			FROM
			(
			SELECT  H.HSNCODE,SI.salid,SI.PrdId,SI.MRP ,BaseQty,TaxCode+'Perc' AS TaxCode,TaxPerc AS TaxPercAmt 
				FROM #SALESDETAILS SI
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.SalId=SI.SalId AND ST.PrdSlNo=SI.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=ST.TaxId
				INNER JOIN #HSNCode H ON H.PrdId=SI.PrdId	
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=SI.PrdId AND O.MRP=SI.MRP AND O.Lcnid=SI.LcnId
				WHERE TaxableAmount>0			
			UNION 
			SELECT H.HSNCODE,SI.salid,SI.PrdId,SI.MRP,BaseQty,TaxCode+'_Amt' AS TaxCode,TaxAmount AS TaxPercAmt 
				FROM #SALESDETAILS SI 
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.SalId=SI.SalId AND ST.PrdSlNo=SI.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=ST.TaxId
				INNER JOIN #HSNCode H ON H.PrdId=SI.PrdId	
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=SI.PrdId AND O.MRP=SI.MRP AND O.Lcnid=SI.LcnId 
				WHERE TaxableAmount>0
			UNION
			SELECT H.HSNCODE,SI.salid,SI.PrdId,SI.MRP,BaseQty,TaxCode+'_Taxable' AS TaxCode,TaxableAmount AS TaxPercAmt 
				FROM #SALESDETAILS SI 
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.SalId=SI.SalId AND ST.PrdSlNo=SI.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=ST.TaxId
				INNER JOIN #HSNCode H ON H.PrdId=SI.PrdId	
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=SI.PrdId AND O.MRP=SI.MRP AND O.Lcnid=SI.LcnId 
				WHERE TaxableAmount>0
			UNION
				SELECT H.HSNCODE,RP.salid,RP.PrdId,RP.MRP,-1*SUM(RP.BaseQty) AS BaseQty,TaxCode+'Perc' AS TaxCode,TaxPerc AS TaxPercAmt 
				FROM #RETURNDETAILS RP
 				INNER JOIN #ReturnProductTax RPT(NOLOCK) ON RPT.ReturnID=RP.ReturnID AND RPT.ReturnId=RP.ReturnID AND RPT.PrdSlNo=RP.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode  
				IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=RPT.TaxID 
				INNER JOIN #HSNCode H ON H.PrdId=RP.PrdId 
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=RP.PrdId AND O.MRP=RP.MRP AND O.Lcnid=RP.LcnId 
				WHERE TaxableAmt>0
				GROUP BY H.HSNCODE,RP.salid,RP.PrdId,RP.MRP,TaxCode,TaxPerc
			UNION
				SELECT HSNCODE,RP.salid,RP.PrdId,RP.MRP,-1*SUM(RP.BaseQty)AS BaseQty,TaxCode+'_Amt' AS TaxCode,-1*SUM(TaxAmt) AS TaxPercAmt 
				FROM #RETURNDETAILS RP
 				INNER JOIN #ReturnProductTax RPT(NOLOCK) ON RPT.ReturnID=RP.ReturnID AND RPT.ReturnId=RP.ReturnID AND RPT.PrdSlNo=RP.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode  
				IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=RPT.TaxID 
				INNER JOIN #HSNCode H ON H.PrdId=RP.PrdId	 
				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=RP.PrdId AND O.MRP=RP.MRP AND O.Lcnid=RP.LcnId
				WHERE TaxableAmt>0 
				GROUP BY H.HSNCODE,RP.salid,RP.PrdId,RP.MRP,TaxCode 
			UNION
				SELECT HSNCODE,RP.salid,RP.PrdId,RP.MRP,-1*SUM(RP.BaseQty)AS BaseQty,TaxCode+'_Taxable' AS TaxCode,-1*SUM(TaxableAmt) AS TaxPercAmt 
				FROM #RETURNDETAILS RP
 				INNER JOIN #ReturnProductTax RPT(NOLOCK) ON RPT.ReturnID=RP.ReturnID AND RPT.ReturnId=RP.ReturnID AND RPT.PrdSlNo=RP.SlNo
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode  
				IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','UTGST','IGST')) T ON T.TaxId=RPT.TaxID 
				INNER JOIN #HSNCode H ON H.PrdId=RP.PrdId	
 				INNER JOIN #OPENINGSTOCK O ON O.Prdid=H.PRDID AND O.PRDID=RP.PrdId AND O.MRP=RP.MRP AND O.Lcnid=RP.LcnId
 				WHERE TaxableAmt>0
 				GROUP BY H.HSNCODE,RP.salid,RP.PrdId,RP.MRP,TaxCode 
 			)A
 			ORDER BY salid
  
			INSERT INTO #TAXDETAILS
			SELECT salid,HSNCODE,PrdId,MRP,SUM(BaseQty),([OutputCGSTPerc]),
			SUM([OutputCGST_Amt]),SUM([OutputCGST_Taxable]),
			([OutputSGSTPerc]),SUM([OutputSGST_Amt]),SUM([OutputSGST_Taxable]),
			([OutputIGSTPerc]),SUM([OutputIGST_Amt]),SUM([OutputIGST_Taxable]),
			([OutputUTGSTPerc]),SUM([OutputUTGST_Amt]),SUM([OutputUTGST_Taxable])
			FROM(
			SELECT  salid,HSNCODE,PrdId,MRP, BaseQty,
			ISNULL([OutputCGSTPerc],0)[OutputCGSTPerc],ISNULL([OutputCGST_Amt],0)[OutputCGST_Amt],ISNULL([OutputCGST_Taxable],0)[OutputCGST_Taxable],
			ISNULL([OutputSGSTPerc],0)[OutputSGSTPerc],ISNULL([OutputSGST_Amt],0)[OutputSGST_Amt],ISNULL([OutputSGST_Taxable],0)[OutputSGST_Taxable],
			ISNULL([OutputIGSTPerc],0)[OutputIGSTPerc],ISNULL([OutputIGST_Amt],0)[OutputIGST_Amt],ISNULL([OutputIGST_Taxable],0)[OutputIGST_Taxable],
			ISNULL([OutputUTGSTPerc],0)[OutputUTGSTPerc],ISNULL([OutputUTGST_Amt],0)[OutputUTGST_Amt],ISNULL([OutputUTGST_Taxable],0)[OutputUTGST_Taxable]
			FROM (
			SELECT salid,HSNCODE,PrdId,MRP,BaseQty,TaxCode,TaxPercAmt
			FROM #TAXPIVOT) up
			PIVOT (SUM(TaxPercAmt) FOR TaxCode IN ([OutputCGST_Taxable],[OutputCGST_Amt],[OutputCGSTPerc],
													[OutputSGST_Taxable],[OutputSGST_Amt],[OutputSGSTPerc],
													[OutputIGST_Taxable],[OutputIGST_Amt],[OutputIGSTPerc],
													[OutputUTGST_Taxable],[OutputUTGST_Amt],[OutputUTGSTPerc]))  AS PVT 
			)A
			GROUP BY salid,HSNCODE,PrdId,MRP,[OutputCGSTPerc],[OutputSGSTPerc],[OutputIGSTPerc],[OutputUTGSTPerc]			

	--SELECT * FROM #TAXDETAILS where prdid=1
 
	IF EXISTS(SELECT * FROM #OPENINGSTOCK)
	BEGIN
 		SELECT @MaxNo=MAX(RowNo) FROM #OPENINGSTOCK 
		
		SET @MinNo=1 
		
		WHILE @MinNo<=@MaxNo
		BEGIN
			SELECT @Prdid=Prdid,@MRP=MRP,@FinalClosingStock=ClosingStock,@HSNClosingStock=HSNWiseClosing FROM #OPENINGSTOCK WHERE RowNo=@MinNo

 			   TRUNCATE TABLE #TRANSDETAILS	
			   INSERT INTO  #TRANSDETAILS	
			   SELECT salid,PrdId,MRP,BaseQty 
				  FROM #TAXDETAILS WHERE PrdId=@Prdid AND MRP=@MRP  ORDER BY Salid
 				
				SELECT @MaxTransNo=MAX(Slno) FROM #TRANSDETAILS 
				
				SET @MinTransNo=1
				SET @ClosingStock=@FinalClosingStock  
			     
				WHILE @MinTransNo<=@MaxTransNo
				BEGIN
					SELECT @Salid=salid,@Baseqty= BaseQty  FROM #TRANSDETAILS WHERE Slno=@MinTransNo 
 
					 IF @ClosingStock>0
					 BEGIN
						IF @Baseqty>=@ClosingStock
						BEGIN
							INSERT INTO #FINALSTOCK(Salid,HSNCODE,PrdId,MRP,ClosingQty,BaseQty,ActualQty,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,OutputSGSTPerc,
													OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
													OutputUTGST_Amt,OutputUTGST_Taxable,Actual_CGST_Taxable,Actual_SGST_Taxable,Actual_UTGST_Taxable,
													Actual_IGST_Taxable,Actual_CGST_Tax,Actual_SGST_Tax,Actual_UTGST_Tax,Actual_IGST_Tax,PresumptiveTax_CGST,
													PresumptiveTax_IGST,ITCAllowed_CGST,ITCAllowed_SGST,ITCAllowed_IGST,ITCAllowed,HSNClosingStock)
							SELECT Salid,HSNCODE,PrdId,MRP,@FinalClosingStock,BaseQty,@ClosingStock,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,OutputSGSTPerc,
									OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
									OutputUTGST_Amt,OutputUTGST_Taxable,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@HSNClosingStock
									FROM #TAXDETAILS
									WHERE Salid=@Salid AND PrdId=@Prdid AND MRP=@MRP 
													
							BREAK						
						END
						ELSE
						BEGIN
							INSERT INTO #FINALSTOCK(Salid,HSNCODE,PrdId,MRP,ClosingQty,BaseQty,ActualQty,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,OutputSGSTPerc,
													OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
													OutputUTGST_Amt,OutputUTGST_Taxable,Actual_CGST_Taxable,Actual_SGST_Taxable,Actual_UTGST_Taxable,
													Actual_IGST_Taxable,Actual_CGST_Tax,Actual_SGST_Tax,Actual_UTGST_Tax,Actual_IGST_Tax,
													PresumptiveTax_CGST,PresumptiveTax_IGST,ITCAllowed_CGST,ITCAllowed_SGST,ITCAllowed_IGST,ITCAllowed,HSNClosingStock)
							SELECT Salid,HSNCODE,PrdId,MRP,@FinalClosingStock,BaseQty,@Baseqty,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,
								   OutputSGSTPerc,OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
									OutputUTGST_Amt,OutputUTGST_Taxable ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@HSNClosingStock
									FROM #TAXDETAILS
									WHERE Salid=@Salid AND PrdId=@Prdid AND MRP=@MRP 
									
							SET @ClosingStock=@ClosingStock-@Baseqty
						END					
						
			    	  END
			    	  SET  @MinTransNo=@MinTransNo+1	
				END
			
			SET @MinNo=@MinNo+1	
		END
	END
	
		--SELECT  P.HSNCode,T.PrdId,ISNULL(P.PresumptiveRate,0) PresumptiveRate 
		--INTO #PresumptiveTax
		--FROM  TBL_GR_BUILD_PH T INNER JOIN PresumptiveTax_GSTR2 P ON P.Brand=T.Brand_Code 
		--INNER JOIN #hsncode h on h.hsncode=p.HSNCode and T.PrdId=H.PrdId
		--WHERE Eligibility='YES'

		--UPDATE T SET PresumptiveTax=P.PresumptiveRate FROM #FINALSTOCK  T INNER JOIN #PresumptiveTax P ON T.PrdId=T.PrdId 
		--AND P.HSNCode=T.HSNCode
		
		UPDATE #FINALSTOCK SET PresumptiveTax_CGST=CASE WHEN (OutputCGSTPerc+OutputSGSTPerc)>=18 THEN 60 ELSE 40 END
		UPDATE #FINALSTOCK SET PresumptiveTax_IGST=CASE WHEN OutputIGSTPerc>18 THEN 30 ELSE 20 END
			
	---UPDATE TAX AND TAXABLE FOR ACTUAL ITC CLOSING
		UPDATE #FINALSTOCK		
				SET Actual_CGST_Taxable=CASE BaseQty WHEN 0 THEN 0 ELSE (OutputCGST_Taxable/BaseQty)*ActualQty END ,
					Actual_SGST_Taxable=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputSGST_Taxable/BaseQty)*ActualQty END ,
					Actual_UTGST_Taxable=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputUTGST_Taxable/BaseQty)*ActualQty END,
					Actual_IGST_Taxable=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputIGST_Taxable/BaseQty)*ActualQty END,
					Actual_CGST_Tax=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputCGST_Amt/BaseQty)*ActualQty END,
					Actual_SGST_Tax=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputSGST_Amt/BaseQty)*ActualQty END,
					Actual_UTGST_Tax=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputUTGST_Amt/BaseQty)*ActualQty END,
					Actual_IGST_Tax=CASE BaseQty WHEN 0 THEN 0 ELSE(OutputIGST_Amt/BaseQty)*ActualQty END
	
	-----UPDATE ITC ALLOWED VALUE				
	  UPDATE #FINALSTOCK SET ITCAllowed_CGST= CAST(Actual_CGST_Taxable AS NUMERIC(18,6))*((CAST(OutputCGSTPerc AS NUMERIC(18,6))*CAST(PresumptiveTax_CGST AS NUMERIC(18,6)))/CAST(100 AS NUMERIC(18,6))) /CAST(100 AS NUMERIC(18,6))				
	  UPDATE #FINALSTOCK SET ITCAllowed_SGST= CAST(Actual_SGST_Taxable+Actual_UTGST_Taxable AS NUMERIC(18,6))*((CAST(OutputSGSTPerc+OutputUTGSTPerc AS NUMERIC(18,6))*CAST(PresumptiveTax_CGST AS NUMERIC(18,6)))/CAST(100 AS NUMERIC(18,6))) /CAST(100 AS NUMERIC(18,6))				
	  UPDATE #FINALSTOCK SET ITCAllowed_IGST= CAST(Actual_IGST_Taxable AS NUMERIC(18,6))*((CAST(OutputIGSTPerc AS NUMERIC(18,6))*CAST(PresumptiveTax_IGST AS NUMERIC(18,6)))/CAST(100 AS NUMERIC(18,6))) /CAST(100 AS NUMERIC(18,6))
  

	SELECT 'GSTR TRANS 2 Details Report',SI.SalInvNo,SI.SALINVDATE,HSNCODE,PrdCCode,PrdName,MRP,HSNClosingStock,ClosingQty AS ITC_Closing,
	BaseQty,ActualQty,OutputCGSTPerc,OutputCGST_Amt,OutputCGST_Taxable,OutputSGSTPerc,
	OutputSGST_Amt,OutputSGST_Taxable,OutputIGSTPerc,OutputIGST_Amt,OutputIGST_Taxable,OutputUTGSTPerc,
	OutputUTGST_Amt,OutputUTGST_Taxable,Actual_CGST_Taxable,Actual_SGST_Taxable,Actual_UTGST_Taxable,
	Actual_IGST_Taxable,Actual_CGST_Tax,Actual_SGST_Tax,Actual_UTGST_Tax,Actual_IGST_Tax,
	PresumptiveTax_CGST,PresumptiveTax_IGST,ITCAllowed_CGST,ITCAllowed_SGST,ITCAllowed_IGST,ITCAllowed
	FROM #FINALSTOCK F INNER JOIN SalesInvoice SI ON SI.SalId=F.Salid
	INNER JOIN Product P ON P.PrdId=F.PrdId
END
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Proc_RptGSTR1_B2B' AND XTYPE = 'P')
DROP PROCEDURE Proc_RptGSTR1_B2B
GO
/*
EXEC Proc_RptGSTR1_B2B 414,1,0,'',0,0,0
 */
CREATE PROCEDURE [Proc_RptGSTR1_B2B]
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
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
		TRUNCATE TABLE RptGSTR1_B2B
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		
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
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
					IN ('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST')) T ON T.TaxId=ST.TaxId
			UNION ALL
			SELECT 2 AS BTYPE,SI.IDTMngRefNo  AS Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #IDTSales SI
				INNER JOIN #IDTManagementProductTax ST ON ST.IDTMngRefNo=SI.IDTMngRefNo AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN (SELECT TAXID,TAXCODE FROM  TaxConfiguration WHERE TaxCode 
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
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptGSTR1_B2CL')
DROP PROCEDURE Proc_RptGSTR1_B2CL
GO
/*
EXEC Proc_RptGSTR1_B2CL 415,1,0,'',0,0,1
 */
CREATE PROCEDURE [Proc_RptGSTR1_B2CL]
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
* PROCEDURE		: Proc_RptGSTR1_B2CL
* PURPOSE		: To Generate a report GSTR1 B2CL
* CREATED		: Murugan.R
* CREATED DATE	: 13/04/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

		TRUNCATE TABLE RptGSTR1_B2CL
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017
		
		
		CREATE TABLE #RptGSTR1_B2CL
		(
		TransId TinyInt,
		TranType Varchar(20),
		Refid BIGINT,
		RtrShipId INT,
		RtrId INT,
		RtrCode Varchar(50),
		RtrName Varchar(100),
		[GSTIN/UIN of Recipient]	 Varchar(50),
		[Invoice Number]	 Varchar(50),
		[Invoice date]	DateTime,
		[Invoice Value]	Numeric(32,2),
		[Place Of Supply]	Varchar(125),
		[Reverse Charge]	Varchar(10),
		[Invoice Type]	Varchar(50),
		[E-Commerce GSTIN]	Varchar(50),
		[Rate]	Numeric(10,2),	
		[Taxable Value]	Numeric(32,2),
		[Cess Amount]	Numeric(32,2),
		[IGST rate]					NUMERIC(32,2),
		[IGST amount]				NUMERIC(32,2),
		UsrId INT,
		[Group Name] Varchar(100),
		GroupType TINYINT
		)
		
			
		SELECT DISTINCT  R.RtrId as RtrId,TinFirst2Digit+'-'+StateName as StateName
		INTO #RetailerState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=2 and ColumnName='State Name'
 		
		SELECT DISTINCT  R.RtrId as RtrId,UT.ColumnValue
		INTO #RetailerGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='GSTIN'
		
		---Retailer Registered
		SELECT R.RtrId,ColumnValue
		INTO #RetailerUnRegister
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue='UnRegistered' 
		
		SELECT S.RtrId,S.RtrshipId,S.Salid,Salinvno,SalInvdate,Prdslno,OrgNetAmount,SUM(TaxPerc) as Taxperc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(TaxAmount) as TaxAmount
		INTO #Sales		
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProductTax ST (NOLOCK) ON S.Salid=ST.SalId
		INNER JOIN #RetailerUnRegister R ON R.RtrId=S.RtrId
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		AND TaxCode IN('OutputIGST','IGST') and OrgNetAmount>250000 and TaxableAmount>0
		GROUP BY S.RtrId,S.Salid,Salinvno,SalInvdate,Prdslno,S.RtrshipId,OrgNetAmount
		
		SELECT S.SalId,S.Rtrid,SUM(PrdNetAmount)PrdNetAmount INTO #SalesNetValue FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SI (NOLOCK) ON S.Salid=SI.SalId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		GROUP BY S.SalId,S.Rtrid

		UPDATE S SET OrgNetAmount=PrdNetAmount FROM #Sales S INNER JOIN #SalesNetValue SI ON S.Salid=SI.Salid
			
		---CALCULATE TAX SPLIT 
		SELECT * INTO #SalesInvoiceProductTax FROM SalesInvoiceProductTax 
			WHERE SalId IN (SELECT DISTINCT salid FROM #Sales) 	
						
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
		
		SELECT BTYPE,Salinvno,Prdslno,TaxCode,TaxPercAmt INTO #TAXPIVOT
		FROM
		(
		----SALES DATA
		SELECT 1 AS BTYPE,SI.Salinvno,SI.Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
			FROM #Sales SI
			INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.PrdSlNo=SI.Prdslno
			INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
		UNION ALL
		SELECT 1 AS BTYPE,SI.Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
			FROM #Sales SI
			INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId  AND ST.PrdSlNo=SI.Prdslno
			INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
		)A 

 			SELECT BTYPE,Salinvno,Prdslno,SUM([OutputIGSTPerc])[OutputIGSTPerc],SUM([OutputIGST_Amt])[OutputIGST_Amt]
			INTO #TAXDETAILS
			FROM(
			SELECT BTYPE,Salinvno,Prdslno,
			ISNULL([OutputIGSTPerc],0)[OutputIGSTPerc],ISNULL([OutputIGST_Amt],0)[OutputIGST_Amt]
			FROM (
			SELECT BTYPE,Salinvno,Prdslno,TaxCode,TaxPercAmt
			FROM #TAXPIVOT) up
			PIVOT (SUM(TaxPercAmt) FOR TaxCode IN ([OutputIGST_Amt],[OutputIGSTPerc]))  AS PVT 
			)A
			GROUP BY BTYPE,Salinvno,Prdslno 			
				
		
		INSERT INTO #RptGSTR1_B2CL(TransId,TranType,Refid ,RtrShipId,RtrId,RtrCode,RtrName,
		[GSTIN/UIN of Recipient],[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],
		[Reverse Charge],[Invoice Type]	,[E-Commerce GSTIN],[Rate],[Taxable Value],[Cess Amount],[IGST rate],[IGST amount],
		UsrId,[Group Name],GroupType)
		SELECT 1,'Sales',S.Salid,S.RtrShipId,R.RtrId,RtrCode,RtrName,'' as GSTTin,S.Salinvno,Salinvdate, OrgNetAmount as SalesValue,'' as PlaceOfSupply,
		'N' as ReverseCharge,'Regular' as InvoiceType,'' as [E-Commerce],Taxperc,SUM(TaxableAmount) as TaxableAmount,
		0.00 as CessAmount,[OutputIGSTPerc],sum([OutputIGST_Amt]) as [OutputIGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM #Sales S INNER JOIN Retailer R (NOLOCK) ON R.RtrId=S.RtrId
		INNER JOIN #TAXDETAILS T ON T.Salinvno=S.salinvno and T.prdslno=S.Prdslno
		WHERE OrgNetAmount>250000
		GROUP BY 
		S.Salid,R.RtrId,RtrCode,RtrName,S.SalInvNo,Salinvdate,Taxperc,S.RtrShipId,OrgNetAmount,[OutputIGSTPerc]
		
		
		UPDATE B Set B.[Place Of Supply]=A.StateName FROM #RetailerState A INNER JOIN #RptGSTR1_B2CL B ON A.Rtrid=B.RtrId
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=GSTTinNo FROM #RptGSTR1_B2CL R INNER JOIN RetailerShipAdd RS ON RS.RtrShipId=R.RtrShipId
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=ColumnValue FROM #RptGSTR1_B2CL R INNER JOIN #RetailerGSTIN RS ON RS.RtrId=R.RtrId
		WHERE LEN(ISNULL(R.[GSTIN/UIN of Recipient],''))=0
				
		IF NOT EXISTS(SELECT 'X' FROM #RptGSTR1_B2CL)
		BEGIN
			SELECT * FROM RptGSTR1_B2CL (NOLOCK) WHERE UsrId=@Pi_UsrId
			RETURN
		END
		
		INSERT INTO RptGSTR1_B2CL([Invoice Number],[Invoice date],[Recipient Code in application],
		[Recipient Name],[Invoice Value],[Place Of Supply],[Rate],[Taxable Value],[Cess Amount],[E-Commerce GSTIN],
		UsrId,[Group Name],GroupType)		
		SELECT [Invoice Number],REPLACE(REPLACE(CONVERT(VARCHAR,[Invoice date],106), ' ','-'), ',',''),RtrCode,RtrName,
		[Invoice Value],[Place Of Supply],
		[Rate],[Taxable Value],[Cess Amount],[E-Commerce GSTIN],
		UsrId,[Group Name],GroupType
		FROM #RptGSTR1_B2CL ORDER BY TransId,[Invoice date],[Invoice Number]
		
		INSERT INTO RptGSTR1_B2CL([Invoice Number],[Invoice date],[Recipient Code in application],
			[Recipient Name],[Invoice Value],[Place Of Supply],
			[Rate],[Taxable Value],[Cess Amount],[E-Commerce GSTIN],UsrId,[Group Name],GroupType)
		SELECT'' as [Invoice Number],'' as [Invoice date],'' as [Recipient Code in application],
		'' as [Recipient Name],SUM([Invoice Value]),'' as [Place Of Supply],
		0.00 as [Rate],SUM([Taxable Value]),SUM([Cess Amount]),'' as [E-Commerce GSTIN],
		@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
		FROM #RptGSTR1_B2CL
		
		
		SELECT DISTINCT TransId,[Invoice Number],[Invoice Value]
		INTO #GrandTotal
		FROM #RptGSTR1_B2CL
		
		
		--UPDATE RptGSTR1_B2B SET [Invoice Value]=(SELECT SUM([Invoice Value]) FROM #GrandTotal) WHERE GroupType=3
		
		
		SELECT * FROM RptGSTR1_B2CL (NOLOCK) WHERE UsrId=@Pi_UsrId
				
END
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Proc_RptGSTR1_B2CS' AND XTYPE = 'P')
DROP PROCEDURE Proc_RptGSTR1_B2CS
GO
/*
EXEC Proc_RptGSTR1_B2CS 416,1,0,'',0,0,1
 */
CREATE PROCEDURE [Proc_RptGSTR1_B2CS]
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
* PROCEDURE		: Proc_RptGSTR1_B2CS
* PURPOSE		: To Generate a report GSTR1 B2Consumar Small
* CREATED		: Murugan.R
* CREATED DATE	: 13/04/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
		TRUNCATE TABLE RptGSTR1_B2CS
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017
		
		
		CREATE TABLE #RptGSTR1_B2CS
		(
		TransId			TinyInt,
		TranType		Varchar(20),
		Refid			BIGINT,
		RtrShipId		INT,
		RtrId			INT,
		RtrCode			Varchar(50),	
		RtrName			Varchar(100),
		[GSTIN/UIN of Recipient]	 Varchar(50),
		[Invoice Number]	 Varchar(50),
		[Invoice date]	DateTime,
		[Invoice Value]	Numeric(32,2),
		[Place Of Supply]	Varchar(125),
		[Reverse Charge]	Varchar(10),
		[Invoice Type]	Varchar(50),
		[E-Commerce GSTIN]	Varchar(50),
		[Rate]			Numeric(10,2),
		[Taxable Value]	Numeric(32,2),
		[Cess Amount]	Numeric(32,2),
		[IGST rate]			Numeric(32,2),
		[IGST amount]		Numeric(32,2),
		[CGST rate]			Numeric(32,2),
		[CGST amount]		Numeric(32,2),
		[SGST/UTGST rate]	Numeric(32,2),
		[SGST/UTGST amount]	Numeric(32,2),
		UsrId INT,
		[Group Name] Varchar(100),
		GroupType TINYINT
		)
			
			
		---Retailer Registered
		SELECT R.RtrId,ColumnValue
		INTO #RetailerUnRegister
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue='UnRegistered' 
		
		
		SELECT DISTINCT  R.RtrId as RtrId,TinFirst2Digit+'-'+StateName as StateName
		INTO #RetailerState
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		INNER JOIN StateMaster S ON S.StateName=UT.ColumnValue
		WHERE U.MasterId=2 and ColumnName='State Name'
		
	
		
		
		SELECT DISTINCT  R.RtrId as RtrId,UT.ColumnValue
		INTO #RetailerGSTIN
		FROM UDCHD U 
		INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
		INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
		INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
		WHERE U.MasterId=2 and ColumnName='GSTIN'
				
		SELECT S.RtrId,S.RtrshipId,S.Salid,Salinvno,SalInvdate,Prdslno,OrgNetAmount,SUM(TaxPerc) as Taxperc,SUM(DISTINCT TaxableAmount) as TaxableAmount,SUM(TaxAmount) as TaxAmount
		INTO #Sales		
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProductTax ST (NOLOCK) ON S.Salid=ST.SalId
		INNER JOIN #RetailerUnRegister R ON R.RtrId=S.RtrId
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		AND  TaxCode IN('OutputIGST','OutputCGST','OutputSGST','OutputUTGST','IGST','CGST','SGST','UTGST') and TaxableAmount>0
		GROUP BY S.RtrId,S.Salid,Salinvno,SalInvdate,Prdslno,S.RtrshipId,OrgNetAmount
		
		SELECT S.SalId,S.Rtrid,SUM(PrdNetAmount)PrdNetAmount INTO #SalesNetValue FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SI (NOLOCK) ON S.Salid=SI.SalId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		GROUP BY S.SalId,S.Rtrid

		UPDATE S SET OrgNetAmount=PrdNetAmount FROM #Sales S INNER JOIN #SalesNetValue SI ON S.Salid=SI.Salid
		
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
			SELECT BTYPE,Salinvno,Prdslno,TaxCode,TaxPercAmt INTO #TAXPIVOT
			FROM
			(
			----SALES DATA
			SELECT 1 AS BTYPE,SI.Salinvno,SI.Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
				FROM #Sales SI
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId AND ST.PrdSlNo=SI.Prdslno
				INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			UNION ALL
			SELECT 1 AS BTYPE,SI.Salinvno,SI.Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmount AS TaxPercAmt 
				FROM #Sales SI
				INNER JOIN #SalesInvoiceProductTax ST ON ST.SalId=SI.SalId  AND ST.PrdSlNo=SI.Prdslno
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
					
		
		----IGST Invoice wise Net Value <250000
		SELECT DISTINCT S.Salid
		INTO #SalesIGST		
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProductTax ST (NOLOCK) ON S.Salid=ST.SalId
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=ST.TaxId
		INNER JOIN #RetailerunRegister R ON R.RtrId=S.RtrId
		WHERE Dlvsts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear and VatGST='GST'
		and TaxCode IN('OutputIGST','IGST') and TaxableAmount>0
			
		INSERT INTO #RptGSTR1_B2CS(TransId,TranType,Refid ,RtrShipId,RtrId,RtrCode,RtrName,
		[GSTIN/UIN of Recipient],[Invoice Number],[Invoice date],[Invoice Value],[Place Of Supply],
		[Reverse Charge],[Invoice Type]	,[E-Commerce GSTIN],[Rate],[Taxable Value],[Cess Amount],
		[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],
		UsrId,[Group Name],GroupType)
		SELECT 1,'Sales',S.Salid,S.RtrShipId,R.RtrId,RtrCode,RtrName,'' as GSTTin,S.Salinvno,Salinvdate, OrgNetAmount as SalesValue,'' as PlaceOfSupply,
			'N' as ReverseCharge,'Regular' as InvoiceType,'' as [E-Commerce],Taxperc,SUM(TaxableAmount) as TaxableAmount,0.00 as CessAmount,
			[OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			([OutputSGSTPerc]+[OutputUTGSTPerc]),SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM #Sales S INNER JOIN Retailer R (NOLOCK) ON R.RtrId=S.RtrId
		INNER JOIN #TAXDETAILS T ON T.SalInvNo=S.SalInvNo AND T.Prdslno=S.Prdslno
		GROUP BY 
		S.Salid,R.RtrId,RtrCode,RtrName,S.Salinvno,Salinvdate,Taxperc,S.RtrShipId,OrgNetAmount,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
						
		UPDATE B Set B.[Place Of Supply]=A.StateName FROM #RetailerState A INNER JOIN #RptGSTR1_B2CS B ON A.Rtrid=B.RtrId
		and TransId=1
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=GSTTinNo FROM #RptGSTR1_B2CS R INNER JOIN RetailerShipAdd RS ON RS.RtrShipId=R.RtrShipId
		and TransId=1
		
		UPDATE R Set R.[GSTIN/UIN of Recipient]=ColumnValue FROM #RptGSTR1_B2CS R INNER JOIN #RetailerGSTIN RS ON RS.RtrId=R.RtrId
		WHERE LEN(ISNULL(R.[GSTIN/UIN of Recipient],''))=0
		and TransId=1
	
		DELETE A FROM #RptGSTR1_B2CS A INNER JOIN #SalesIGST B ON A.Refid=B.SalId and TransId=1
		WHERE [Invoice Value]>250000
		
 		
		IF NOT EXISTS(SELECT 'X' FROM #RptGSTR1_B2CS)
		BEGIN
			SELECT * FROM RptGSTR1_B2CS (NOLOCK) WHERE UsrId=@Pi_UsrId
			RETURN
		END
		
		INSERT INTO RptGSTR1_B2CS([Type],[Place Of Supply],[Rate],[Taxable Value],[Cess Amount],[E-Commerce GSTIN],
		[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType)		
		SELECT 'OE',[Place Of Supply],[Rate],SUM([Taxable Value]),SUM([Cess Amount]),[E-Commerce GSTIN],
			[IGST rate],SUM([IGST amount]),[CGST rate],sum([CGST amount]),[SGST/UTGST rate],sum([SGST/UTGST amount]),
			@Pi_UsrId as UsrId,'' as [Group Name],2 as GroupType
		FROM #RptGSTR1_B2CS 
		GROUP BY [Rate],[Place Of Supply],[E-Commerce GSTIN],[IGST rate],[CGST rate],[SGST/UTGST rate]
		
		
		INSERT INTO RptGSTR1_B2CS([Type],[Place Of Supply],	[Rate],[Taxable Value],[Cess Amount],[E-Commerce GSTIN],
			[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],UsrId,[Group Name],GroupType)
		SELECT'' as [Type],'' as [Place Of Supply],0.00 as [Rate],SUM([Taxable Value]),SUM([Cess Amount]),'' as [E-Commerce GSTIN],
		0 as [IGST rate],SUM([IGST amount]),0 as [CGST rate],sum([CGST amount]),0 as [SGST/UTGST rate],SUM([SGST/UTGST amount]),
			@Pi_UsrId as UsrId,'ZZZZZ' as [Group Name],3 as GroupType
		FROM #RptGSTR1_B2CS
 		
		
		SELECT * FROM RptGSTR1_B2CS (NOLOCK) WHERE UsrId=@Pi_UsrId
				
END
GO
--DELETE FROM RptGridView WHERE RPTID=411
--INSERT INTO RptGridView 
--SELECT 411,'RptDistributorTurnOver.rpt',1,0,1,1 
--GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptGSTRTRANS1_CDNR')
DROP PROCEDURE Proc_RptGSTRTRANS1_CDNR
GO
--EXEC Proc_RptGSTRTRANS1_CDNR 417,1,0,'',0,0,0 
--SELECT * FROM reportfilterdt where rptid=417
CREATE PROCEDURE Proc_RptGSTRTRANS1_CDNR
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
/************************************************
* PROCEDURE  : Proc_RptGSTRTRANS1_CDNR
* PURPOSE    : To Generate GSTRTRANS1_CDNR Report
* CREATED BY : Karthick
* CREATED ON : 17/08/2017
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON
		
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		DECLARE @CmpId AS INT
		
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017

		SELECT C.RtrId,RtrCode,RtrName,GSTIN,R.StateTinFirst2Digit+'-'+StateName AS StateName,CrNoteNumber,CrNoteDate,PostedFrom AS ReturnCode,C.Amount 
		INTO #CREDITNOTEDETAILS
		FROM Creditnoteretailer C (NOLOCK) INNER JOIN (SELECT * FROM FN_ReturnRetailerUDCDetails()) R ON R.Rtrid=C.Rtrid
		WHERE TransId=30 AND MONTH(CrNoteDate)=@MonthStart AND YEAR(CrNoteDate)=@Jcmyear AND R.RetailerType =1


		SELECT ReturnID,PrdSlno,TaxPerc INTO #RETURNTAXDETAILS
		FROM
		(
		SELECT RH.ReturnID,PrdSlno,SUM(RPT.TaxPerc)TaxPerc 
		FROM ReturnHeader RH (NOLOCK) INNER JOIN ReturnProduct RP (NOLOCK) ON RH.ReturnID=RP.ReturnID
		INNER JOIN ReturnProductTax RPT (NOLOCK) ON RPT.ReturnId=RP.ReturnID AND RPT.PrdSlno=RP.Slno
		INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=RPT.TaxId 
		INNER JOIN #CREDITNOTEDETAILS C ON C.ReturnCode=RH.ReturnCode
		WHERE TaxCode IN('OutputCGST','OutputSGST','CGST','SGST') and VatGst='GST' 
			AND MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear AND TaxableAmt>0
			AND InvoiceType=1
		GROUP BY RH.ReturnID,PrdSlno
		UNION ALL
		SELECT RH.ReturnID,PrdSlno,SUM(RPT.TaxPerc)TaxPerc 
		FROM ReturnHeader RH (NOLOCK) INNER JOIN ReturnProduct RP (NOLOCK) ON RH.ReturnID=RP.ReturnID
		INNER JOIN ReturnProductTax RPT (NOLOCK) ON RPT.ReturnId=RP.ReturnID AND RPT.PrdSlno=RP.Slno
		INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=RPT.TaxId 
		INNER JOIN #CREDITNOTEDETAILS C ON C.ReturnCode=RH.ReturnCode
		WHERE TaxCode IN('OutputIGST','IGST') and VatGst='GST' 
			AND MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear AND TaxableAmt>0
			AND InvoiceType=1
		GROUP BY RH.ReturnID,PrdSlno
		)A  

		SELECT SalInvNo,Salinvdate,RH.ReturnID,rh.ReturnCode  INTO #INVOICEDETAILS
		FROM SalesInvoice SI(NOLOCK) INNER JOIN ReturnHeader RH (NOLOCK) ON RH.SalId=SI.Salid
		INNER JOIN #CREDITNOTEDETAILS  C ON C.ReturnCode=RH.ReturnCode
		WHERE RH.VatGst='GST' AND MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear 
			AND Salinvdate NOT BETWEEN '2017-01-01' AND '2017-06-30'  AND InvoiceType=1 

		SELECT * INTO #ReturnProductTax FROM ReturnProductTax 
			WHERE ReturnID IN (SELECT DISTINCT ReturnID FROM #INVOICEDETAILS) 	
			
					
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

 
		SELECT BTYPE,ReturnID,ReturnCode,Prdslno,TaxCode,TaxPercAmt INTO #TAXPIVOT
		FROM
		(
		----RETURN DATA
		SELECT 1 AS BTYPE,SI.ReturnID,ReturnCode,Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
			FROM #INVOICEDETAILS SI
			INNER JOIN #ReturnProductTax ST ON ST.ReturnID=SI.ReturnID 
			INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			WHERE TaxableAmt>0	
		UNION ALL
		SELECT 1 AS BTYPE,SI.ReturnID,ReturnCode,Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmt AS TaxPercAmt 
			FROM #INVOICEDETAILS SI
			INNER JOIN #ReturnProductTax ST ON ST.ReturnID=SI.ReturnID 
			INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId 
			WHERE TaxableAmt>0	
		UNION ALL
		SELECT 1 AS BTYPE,SI.ReturnID,ReturnCode,Prdslno,TaxCode+'_Taxable' AS TaxCode,ST.TaxableAmt AS TaxPercAmt 
			FROM #INVOICEDETAILS SI
			INNER JOIN #ReturnProductTax ST ON ST.ReturnID=SI.ReturnID 
			INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId 
			WHERE TaxableAmt>0	
		)A
		ORDER BY BTYPE 

		 
		SELECT BTYPE,ReturnID,ReturnCode,Prdslno,([OutputCGSTPerc]),
		SUM([OutputCGST_Amt])[OutputCGST_Amt],SUM([OutputCGST_Taxable]) as [OutputCGST_Taxable],
		([OutputSGSTPerc]),SUM([OutputSGST_Amt])as [OutputSGST_Amt],SUM([OutputSGST_Taxable]) as [OutputSGST_Taxable],
		([OutputIGSTPerc]),SUM([OutputIGST_Amt])as [OutputIGST_Amt],SUM([OutputIGST_Taxable]) as [OutputIGST_Taxable],
		([OutputUTGSTPerc]),SUM([OutputUTGST_Amt]) as [OutputUTGST_Amt],SUM([OutputUTGST_Taxable]) as [OutputUTGST_Taxable]  INTO #TAXDETAILS
		FROM(
		SELECT  BTYPE,ReturnID,ReturnCode,Prdslno,
		ISNULL([OutputCGSTPerc],0)[OutputCGSTPerc],ISNULL([OutputCGST_Amt],0)[OutputCGST_Amt],ISNULL([OutputCGST_Taxable],0)[OutputCGST_Taxable],
		ISNULL([OutputSGSTPerc],0)[OutputSGSTPerc],ISNULL([OutputSGST_Amt],0)[OutputSGST_Amt],ISNULL([OutputSGST_Taxable],0)[OutputSGST_Taxable],
		ISNULL([OutputIGSTPerc],0)[OutputIGSTPerc],ISNULL([OutputIGST_Amt],0)[OutputIGST_Amt],ISNULL([OutputIGST_Taxable],0)[OutputIGST_Taxable],
		ISNULL([OutputUTGSTPerc],0)[OutputUTGSTPerc],ISNULL([OutputUTGST_Amt],0)[OutputUTGST_Amt],ISNULL([OutputUTGST_Taxable],0)[OutputUTGST_Taxable]
		FROM (
		SELECT BTYPE,ReturnID,ReturnCode,Prdslno,TaxCode,TaxPercAmt
		FROM #TAXPIVOT) up
		PIVOT (SUM(TaxPercAmt) FOR TaxCode IN ([OutputCGST_Taxable],[OutputCGST_Amt],[OutputCGSTPerc],
												[OutputSGST_Taxable],[OutputSGST_Amt],[OutputSGSTPerc],
												[OutputIGST_Taxable],[OutputIGST_Amt],[OutputIGSTPerc],
												[OutputUTGST_Taxable],[OutputUTGST_Amt],[OutputUTGSTPerc]))  AS PVT 
		)A
		GROUP BY BTYPE,ReturnID,ReturnCode,Prdslno,[OutputCGSTPerc],[OutputSGSTPerc],[OutputIGSTPerc],[OutputUTGSTPerc]			
   
 		TRUNCATE TABLE RptGSTRTRANS1_CDNR
		INSERT INTO RptGSTRTRANS1_CDNR([GSTIN/UIN of Recipient],[Recipient Code in application],[Recipient Name],
						[Invoice/Advance Receipt Number],[Invoice/Advance Receipt date],
						[Note/Refund Voucher Number],[Note/Refund Voucher date],[Document Type],[Reason For Issuing document],
						[Place Of Supply],[Note/Refund Voucher Value],[Rate],[Taxable Value],[Cess Amount],[Pre GST],
						[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],
						[UsrId],[Group Name],[GroupType])
		SELECT C.GSTIN,Rtrcode,Rtrname,SalInvNo,CONVERT(VARCHAR(10),DAY(Salinvdate))+'-'+LEFT(DATENAME(month,Salinvdate),3)+'-'+RIGHT(CONVERT(VARCHAR(10),YEAR(Salinvdate),121),2) AS Salinvdate,
		CrNoteNumber,CONVERT(VARCHAR(10),DAY(CrNoteDate))+'-'+LEFT(DATENAME(month,CrNoteDate),3)+'-'+RIGHT(CONVERT(VARCHAR(10),YEAR(CrNoteDate),121),2) AS CrNoteDate,
		'C' AS DocumentType,'Sales Return' AS Reason,StateName,Amount,TaxPerc,SUM([OutputCGST_Taxable]+[OutputIGST_Taxable]) AS PrdNetAmt,0 AS Cess,'N' AS PreGst,
				[OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			   ([OutputSGSTPerc]+[OutputUTGSTPerc])as [OutputSGSTPerc],SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM ReturnHeader RH (NOLOCK) INNER JOIN ReturnProduct RP (NOLOCK) ON RH.ReturnID=RP.ReturnID
		INNER JOIN #RETURNTAXDETAILS RT ON RT.ReturnID=RH.ReturnID AND RT.PrdSlno=RP.Slno
		INNER JOIN #CREDITNOTEDETAILS C ON C.ReturnCode=RH.ReturnCode
		INNER JOIN #INVOICEDETAILS I ON I.ReturnID=RH.ReturnID AND I.ReturnID=RT.ReturnID
		INNER JOIN #TAXDETAILS T ON T.ReturnID=RH.ReturnID AND T.ReturnID=RH.ReturnID AND T.prdslno=RT.prdslno AND T.PrdSlno=RP.Slno
		WHERE MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear AND VatGst='GST' 
		AND ReturnDate NOT BETWEEN '2017-01-01' AND '2017-06-30'  AND InvoiceType=1
		GROUP BY C.GSTIN,SalInvNo,Salinvdate,CrNoteNumber,CrNoteDate,StateName,Amount,Prdid,TaxPerc,Rtrcode,Rtrname,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
 

		INSERT INTO RptGSTRTRANS1_CDNR([GSTIN/UIN of Recipient],[Recipient Code in application],[Recipient Name],
						[Invoice/Advance Receipt Number],[Invoice/Advance Receipt date],
						[Note/Refund Voucher Number],[Note/Refund Voucher date],[Document Type],[Reason For Issuing document],
						[Place Of Supply],[Note/Refund Voucher Value],[Rate],[Taxable Value],[Cess Amount],[Pre GST],
						[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],
						[UsrId],[Group Name],[GroupType])
		
		SELECT SUM([GSTIN/UIN of Recipient]) as [GSTIN/UIN of Recipient],''[Recipient Code in application],''[Recipient Name],SUM([Invoice/Advance Receipt Number]) as [Invoice/Advance Receipt Number],
		'' as[Invoice/Advance Receipt date],SUM([Note/Refund Voucher Number]) as [Note/Refund Voucher Number],'' as [Note/Refund Voucher date],'' as [Document Type],'' as [Reason For Issuing document],
				'' as [Place Of Supply],SUM([Note/Refund Voucher Value]) as [Note/Refund Voucher Value],0 [Rate],sum([Taxable Value]) as [Taxable Value],
				sum([Cess Amount]) as [Cess Amount] ,'' as [Pre GST],
				0 as [IGST rate],sum([IGST amount]),0 as [CGST rate],sum([CGST amount]),0 as [SGST/UTGST rate],sum([SGST/UTGST amount]),
				@Pi_UsrId AS [UsrId],'ZZZZZZ' AS [Group Name],3 AS [GroupType]
		FROM(			
		SELECT	COUNT(DISTINCT([GSTIN/UIN of Recipient])) AS [GSTIN/UIN of Recipient],COUNT(DISTINCT([Invoice/Advance Receipt Number])) as [Invoice/Advance Receipt Number],
		'' as[Invoice/Advance Receipt date],COUNT(DISTINCT([Note/Refund Voucher Number])) as [Note/Refund Voucher Number],'' as [Note/Refund Voucher date],
		'' as [Document Type],'' as [Reason For Issuing document],
				'' as [Place Of Supply],[Note/Refund Voucher Value],0 [Rate],sum([Taxable Value]) as [Taxable Value],
				sum([Cess Amount]) as [Cess Amount] ,'' as [Pre GST],
				sum([IGST amount]) as [IGST amount],SUM([CGST amount]) as [CGST amount],sum([SGST/UTGST amount]) as [SGST/UTGST amount],
				@Pi_UsrId AS [UsrId],'ZZZZZZ' AS [Group Name],3 AS [GroupType]
		FROM RptGSTRTRANS1_CDNR GROUP BY [Note/Refund Voucher Value])A
		
 
		DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptGSTRTRANS1_CDNR
		WHERE UsrId=@Pi_UsrId
		
		SELECT * FROM RptGSTRTRANS1_CDNR WHERE UsrId=@Pi_UsrId 
END
GO
--DELETE FROM RptGridView WHERE RPTID=411
--INSERT INTO RptGridView 
--SELECT 411,'RptDistributorTurnOver.rpt',1,0,1,1 
--GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptGSTRTRANS1_CDNUR')
DROP PROCEDURE Proc_RptGSTRTRANS1_CDNUR
GO
--EXEC Proc_RptGSTRTRANS1_CDNUR 418,1,0,'',0,0,0 
--SELECT * FROM reportfilterdt where rptid=418
CREATE PROCEDURE Proc_RptGSTRTRANS1_CDNUR
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
/************************************************
* PROCEDURE  : Proc_RptGSTRTRANS1_CDNUR
* PURPOSE    : To Generate GSTRTRANS1_CDNUR Report
* CREATED BY : Karthick
* CREATED ON : 17/08/2017
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
SET NOCOUNT ON
		
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		DECLARE @CmpId AS INT
		
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		--SET @MonthStart=7
		--SET @Jcmyear=2017

		SELECT C.RtrId,GSTIN,R.StateTinFirst2Digit+'-'+StateName AS StateName,CrNoteNumber,CrNoteDate,PostedFrom AS ReturnCode,C.Amount 
		INTO #CREDITNOTEDETAILS
		FROM Creditnoteretailer C (NOLOCK) INNER JOIN (SELECT * FROM FN_ReturnRetailerUDCDetails()) R ON R.Rtrid=C.Rtrid
		WHERE TransId=30 AND MONTH(CrNoteDate)=@MonthStart AND YEAR(CrNoteDate)=@Jcmyear AND R.RetailerType =2

		SELECT ReturnID,PrdSlno,TaxPerc INTO #RETURNTAXDETAILS
		FROM
		(
		SELECT RH.ReturnID,PrdSlno,SUM(RPT.TaxPerc)TaxPerc 
		FROM ReturnHeader RH (NOLOCK) INNER JOIN ReturnProduct RP (NOLOCK) ON RH.ReturnID=RP.ReturnID
		INNER JOIN ReturnProductTax RPT (NOLOCK) ON RPT.ReturnId=RP.ReturnID AND RPT.PrdSlno=RP.Slno
		INNER JOIN TaxConfiguration T (NOLOCK)  ON T.TaxId=RPT.TaxId 
		INNER JOIN #CREDITNOTEDETAILS C ON C.ReturnCode=RH.ReturnCode
		WHERE TaxCode IN('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST') and VatGst='GST' 
			AND MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear AND TaxableAmt>0 --and RtnNetAmt>250000 
			AND InvoiceType=1
		GROUP BY RH.ReturnID,PrdSlno
		)A  

		SELECT SalInvNo,Salinvdate,RH.ReturnID,rh.ReturnCode  INTO #INVOICEDETAILS
		FROM SalesInvoice SI(NOLOCK) INNER JOIN ReturnHeader RH (NOLOCK) ON RH.SalId=SI.Salid
		INNER JOIN #CREDITNOTEDETAILS  C ON C.ReturnCode=RH.ReturnCode
		WHERE RH.VatGst='GST' AND MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear 
			AND Salinvdate NOT BETWEEN '2017-01-01' AND '2017-06-30'  AND InvoiceType=1 
 
 		SELECT * INTO #ReturnProductTax FROM ReturnProductTax 
			WHERE ReturnID IN (SELECT DISTINCT ReturnID FROM #INVOICEDETAILS) 			

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
 
		SELECT BTYPE,ReturnID,ReturnCode,Prdslno,TaxCode,TaxPercAmt INTO #TAXPIVOT
		FROM
		(
		----RETURN DATA
		SELECT 1 AS BTYPE,SI.ReturnID,ReturnCode,Prdslno,TaxCode+'Perc' AS TaxCode,ST.TaxPerc AS TaxPercAmt 
			FROM #INVOICEDETAILS SI
			INNER JOIN #ReturnProductTax ST ON ST.ReturnID=SI.ReturnID 
			INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId
			WHERE TaxableAmt>0	
		UNION ALL
		SELECT 1 AS BTYPE,SI.ReturnID,ReturnCode,Prdslno,TaxCode+'_Amt' AS TaxCode,ST.TaxAmt AS TaxPercAmt 
			FROM #INVOICEDETAILS SI
			INNER JOIN #ReturnProductTax ST ON ST.ReturnID=SI.ReturnID 
			INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId 
			WHERE TaxableAmt>0	
		UNION ALL
		SELECT 1 AS BTYPE,SI.ReturnID,ReturnCode,Prdslno,TaxCode+'_Taxable' AS TaxCode,ST.TaxableAmt AS TaxPercAmt 
			FROM #INVOICEDETAILS SI
			INNER JOIN #ReturnProductTax ST ON ST.ReturnID=SI.ReturnID 
			INNER JOIN #TaxConfiguration T ON T.TaxId=ST.TaxId 
			WHERE TaxableAmt>0	
		)A
		ORDER BY BTYPE 
 
		 
		SELECT BTYPE,ReturnID,ReturnCode,Prdslno,([OutputCGSTPerc]),
		SUM([OutputCGST_Amt])[OutputCGST_Amt],SUM([OutputCGST_Taxable]) as [OutputCGST_Taxable],
		([OutputSGSTPerc]),SUM([OutputSGST_Amt])as [OutputSGST_Amt],SUM([OutputSGST_Taxable]) as [OutputSGST_Taxable],
		([OutputIGSTPerc]),SUM([OutputIGST_Amt])as [OutputIGST_Amt],SUM([OutputIGST_Taxable]) as [OutputIGST_Taxable],
		([OutputUTGSTPerc]),SUM([OutputUTGST_Amt]) as [OutputUTGST_Amt],SUM([OutputUTGST_Taxable]) as [OutputUTGST_Taxable]  INTO #TAXDETAILS
		FROM(
		SELECT  BTYPE,ReturnID,ReturnCode,Prdslno,
		ISNULL([OutputCGSTPerc],0)[OutputCGSTPerc],ISNULL([OutputCGST_Amt],0)[OutputCGST_Amt],ISNULL([OutputCGST_Taxable],0)[OutputCGST_Taxable],
		ISNULL([OutputSGSTPerc],0)[OutputSGSTPerc],ISNULL([OutputSGST_Amt],0)[OutputSGST_Amt],ISNULL([OutputSGST_Taxable],0)[OutputSGST_Taxable],
		ISNULL([OutputIGSTPerc],0)[OutputIGSTPerc],ISNULL([OutputIGST_Amt],0)[OutputIGST_Amt],ISNULL([OutputIGST_Taxable],0)[OutputIGST_Taxable],
		ISNULL([OutputUTGSTPerc],0)[OutputUTGSTPerc],ISNULL([OutputUTGST_Amt],0)[OutputUTGST_Amt],ISNULL([OutputUTGST_Taxable],0)[OutputUTGST_Taxable]
		FROM (
		SELECT BTYPE,ReturnID,ReturnCode,Prdslno,TaxCode,TaxPercAmt
		FROM #TAXPIVOT) up
		PIVOT (SUM(TaxPercAmt) FOR TaxCode IN ([OutputCGST_Taxable],[OutputCGST_Amt],[OutputCGSTPerc],
												[OutputSGST_Taxable],[OutputSGST_Amt],[OutputSGSTPerc],
												[OutputIGST_Taxable],[OutputIGST_Amt],[OutputIGSTPerc],
												[OutputUTGST_Taxable],[OutputUTGST_Amt],[OutputUTGSTPerc]))  AS PVT 
		)A
		GROUP BY BTYPE,ReturnID,ReturnCode,Prdslno,[OutputCGSTPerc],[OutputSGSTPerc],[OutputIGSTPerc],[OutputUTGSTPerc]			
 
 
		TRUNCATE TABLE RptGSTRTRANS1_CDNUR
		INSERT INTO RptGSTRTRANS1_CDNUR([UR Type],[Note/Refund Voucher Number],[Note/Refund Voucher date],[Document Type],
					[Invoice/Advance Receipt Number],[Invoice/Advance Receipt date],[Reason For Issuing document],
					[Place Of Supply],[Note/Refund Voucher Value],[Rate],[Taxable Value],[Cess Amount],[Pre GST],
					[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],
					[UsrId],[Group Name],[GroupType])
		SELECT 'B2CL',CrNoteNumber,CONVERT(VARCHAR(10),DAY(CrNoteDate))+'-'+LEFT(DATENAME(month,CrNoteDate),3)+'-'+RIGHT(CONVERT(VARCHAR(10),YEAR(CrNoteDate),121),2) AS CrNoteDate,
 		'C' AS DocumentType,SalInvNo,CONVERT(VARCHAR(10),DAY(Salinvdate))+'-'+LEFT(DATENAME(month,Salinvdate),3)+'-'+RIGHT(CONVERT(VARCHAR(10),YEAR(Salinvdate),121),2) AS Salinvdate,
 		'Sales Return' AS Reason,StateName,Amount,TaxPerc,SUM([OutputCGST_Taxable]+[OutputIGST_Taxable]) AS PrdNetAmt,0 AS Cess,'N' AS PreGst,
 			[OutputIGSTPerc],SUM([OutputIGST_Amt]) AS [OutputIGST_Amt],[OutputCGSTPerc],SUM([OutputCGST_Amt]) AS [OutputCGST_Amt],
			   ([OutputSGSTPerc]+[OutputUTGSTPerc])as [OutputSGSTPerc],SUM([OutputSGST_Amt]+[OutputUTGST_Amt])AS [OutputSGST_Amt],@Pi_UsrId,'' as [Group Type],2
		FROM ReturnHeader RH (NOLOCK) INNER JOIN ReturnProduct RP (NOLOCK) ON RH.ReturnID=RP.ReturnID
		INNER JOIN #RETURNTAXDETAILS RT ON RT.ReturnID=RH.ReturnID AND RT.PrdSlno=RP.Slno
		INNER JOIN #CREDITNOTEDETAILS C ON C.ReturnCode=RH.ReturnCode
		INNER JOIN #INVOICEDETAILS I ON I.ReturnID=RH.ReturnID AND I.ReturnID=RT.ReturnID
		INNER JOIN #TAXDETAILS T ON T.ReturnID=RH.ReturnID AND T.ReturnID=RH.ReturnID AND T.prdslno=RT.prdslno AND T.PrdSlno=RP.Slno
		WHERE MONTH(ReturnDate)=@MonthStart AND YEAR(ReturnDate)=@Jcmyear AND VatGst='GST' 
		AND ReturnDate NOT BETWEEN '2017-01-01' AND '2017-06-30'  AND InvoiceType=1
		GROUP BY C.GSTIN,SalInvNo,Salinvdate,CrNoteNumber,CrNoteDate,StateName,Amount,Prdid,TaxPerc,[OutputIGSTPerc],[OutputCGSTPerc],[OutputSGSTPerc],[OutputUTGSTPerc]
		
		IF NOT EXISTS(SELECT 'X' FROM RptGSTRTRANS1_CDNUR)
		BEGIN
			SELECT * FROM RptGSTRTRANS1_CDNUR WHERE UsrId=@Pi_UsrId 
			RETURN
		END


		INSERT INTO RptGSTRTRANS1_CDNUR([UR Type],[Note/Refund Voucher Number],[Note/Refund Voucher date],[Document Type],
					[Invoice/Advance Receipt Number],[Invoice/Advance Receipt date],[Reason For Issuing document],
					[Place Of Supply],[Note/Refund Voucher Value],[Rate],[Taxable Value],[Cess Amount],[Pre GST],
					[IGST rate],[IGST amount],[CGST rate],[CGST amount],[SGST/UTGST rate],[SGST/UTGST amount],
					[UsrId],[Group Name],[GroupType])
		
		SELECT '',SUM([Note/Refund Voucher Number]) as [Note/Refund Voucher Number],'' as [Note/Refund Voucher date],'' as [Document Type],
			SUM([Invoice/Advance Receipt Number]) as [Invoice/Advance Receipt Number],'' as[Invoice/Advance Receipt date],
			'' as [Reason For Issuing document],'' as [Place Of Supply],SUM([Note/Refund Voucher Value]) as [Note/Refund Voucher Value],0 [Rate],sum([Taxable Value]) as [Taxable Value],
				sum([Cess Amount]) as [Cess Amount] ,'' as [Pre GST],
				0 as [IGST rate],sum([IGST amount]),0 as [CGST rate],sum([CGST amount]),0 as [SGST/UTGST rate],sum([SGST/UTGST amount]),
				@Pi_UsrId AS [UsrId],'ZZZZZZ' AS [Group Name],3 AS [GroupType]
		FROM(			
		SELECT COUNT(DISTINCT([Invoice/Advance Receipt Number])) as [Invoice/Advance Receipt Number],
		'' as[Invoice/Advance Receipt date],COUNT(DISTINCT([Note/Refund Voucher Number])) as [Note/Refund Voucher Number],'' as [Note/Refund Voucher date],
		'' as [Document Type],'' as [Reason For Issuing document],
				'' as [Place Of Supply],[Note/Refund Voucher Value],0 [Rate],sum([Taxable Value]) as [Taxable Value],
				sum([Cess Amount]) as [Cess Amount] ,'' as [Pre GST],
				sum([IGST amount]) as [IGST amount],SUM([CGST amount]) as [CGST amount],sum([SGST/UTGST amount]) as [SGST/UTGST amount],
				@Pi_UsrId AS [UsrId],'ZZZZZZ' AS [Group Name],3 AS [GroupType]
		FROM RptGSTRTRANS1_CDNUR GROUP BY [Note/Refund Voucher Value])A
		
 
		DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptGSTRTRANS1_CDNUR
		WHERE UsrId=@Pi_UsrId
		
		SELECT * FROM RptGSTRTRANS1_CDNUR WHERE UsrId=@Pi_UsrId 
END
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Proc_RptPurchaseTaxGST' AND XTYPE ='P')
DROP PROCEDURE Proc_RptPurchaseTaxGST
GO
CREATE PROCEDURE [dbo].[Proc_RptPurchaseTaxGST]
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
* PROCEDURE	: Proc_RptPurchaseTaxGST
* PURPOSE	: To get the GST Purchase Tax details
* CREATED	: Raja C
* CREATED DATE	: 20/05/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId	        AS	INT
	DECLARE @ErrNo	 	AS	INT
		
	DECLARE @SQL as Varchar(MAX)
	DECLARE @MaxId as INT
	DECLARE @ReportId as INT
	DECLARE @start INT, @end INT 
	DECLARE @Str AS VARCHAR(100)
	DECLARE @CreateTable AS VARCHAR(7000)
		
	SET @ErrNo=0
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))	
	
	
	IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='RptPurchaseTaxGST')
	BEGIN
		DELETE FROM RptPurchaseTaxGST WHERE UsrId=@Pi_UsrId
	END
	
		CREATE TABLE #TmpRptIOTaxSummary
		(   
		    [GRN No] NVarchar(100),
            [GRN date] DateTime,
			[InvDate] DateTime,
			[InvId] [bigint] NULL,
			[RefNo] [varchar](100) NULL,
			[ODN Number] [varchar](100) NULL,
			[SupplierCode] Varchar(75),
			[SupplierName] Varchar(150),
			[SupplierAddress] Varchar(150),
			[Supplier GSTIN] Varchar(150),
			[Supplier State] Varchar(150),
			[Product Name] Varchar(150),			
			[Product Code] Varchar(75),
			[HSN Code] Varchar(75),
			[SpmId] [int] NULL,
			[Prdid] [int] NULL,
			[InvQty] [int] NULL,
			[CmpId] [int] NULL,
			[TaxPerc] [varchar](50) NULL,
			[TaxableAmount] [numeric](38, 6) NULL,
			[IOTaxType] [varchar](100) NULL,
			[TaxFlag] [int] NULL,
			[TaxPercent] [numeric](38, 6) NULL,
			[TaxId] [int] NULL,	
			[LineNetAmount] Numeric(36,6),
			[UPC] INT,
			[Group Name]  Varchar(200),
			[GroupType] INT,
			[UsrId] [int] NULL
		)
		
		SELECT Prdid,Max(ConversionFactor) as UPC 
		INTO #UOM
		FROM Product P (NOLOCK) INNER JOIN Uomgroup UG (NOLOCK) ON P.UomGroupId=UG.UomGroupId
		GROUP BY Prdid
		
		INSERT INTO #TmpRptIOTaxSummary([GRN No],[GRN date],[InvDate],[InvId],[RefNo],[ODN Number],[SupplierCode],[SupplierName],[SupplierAddress],
		[Supplier GSTIN],[Supplier State],[Product Name] ,[Product Code],[HSN Code],[SpmId],[Prdid],[InvQty],[CmpId],[TaxPerc],[TaxableAmount],[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],LineNetAmount,[UPC],[Group Name],[GroupType],[UsrId])
		SELECT PurRcptRefNo,GoodsRcvdDate,PR.InvDate AS InvDate,PR.PurRcptId AS InvId,CmpInvNo AS RefNo,PR.PurOrderRefNo,SpmCode,SpmName,SpmAdd1,'' as SupplierGSTIN,'' as SupplierState,
		PrdName,PrdCCode,'' as [HSN Code],S.SpmId AS SpmId,P.PrdId as Prdid,SUM(PRP.RcvdGoodBaseQty) AS InvQty,  
		C.CmpId AS CmpId,TC.TaxCode +' Rate' as TaxPerc,
		SUM(TaxableAmount) as TaxableAmount,'Purchase' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,PRPT.TaxId,
		SUM(PrdNetAmount) as [LineNetAmount],UPC,'' as [Group Name] ,2 as [GroupType],@Pi_UsrId AS UserId  
		FROM 
		PurchaseReceipt PR WITH (NOLOCK)  
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK) ON PR.PurRcptId=PRP.PurRcptId 
		INNER JOIN PurchaseReceiptProductTax PRPT WITH (NOLOCK) ON PR.PurRcptId=PRPT.PurRcptId AND  PRP.PurRcptId=PRPT.PurRcptId  AND PRP.PrdSlNo=PRPT.PrdSlNo 
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId   
		INNER JOIN #UOM U ON U.Prdid=P.Prdid and U.PrdId=PRP.PrdId 
		INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
		INNER JOIN Supplier S WITH (NOLOCK) ON S.SpmId = PR.SpmId
		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId =PRPT.TaxId    
		LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		WHERE PR.GoodsRcvdDate Between @FromDate and @ToDate and PR.Status=1
		AND (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
		C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		Group By PurRcptRefNo,GoodsRcvdDate,PR.PurRcptId,PR.InvDate,CmpInvNo,PR.PurOrderRefNo,SpmCode,SpmName,SpmAdd1,PrdName,PrdCCode,S.SpmId,P.PrdId,
		C.CmpId,TC.TaxCode,TaxPerc,PRPT.TaxId,[UPC]
		HAVING Sum(TaxableAmount) >0  
			
		INSERT INTO #TmpRptIOTaxSummary([GRN No],[GRN date],[InvDate],[InvId],[RefNo],[ODN Number],[SupplierCode],[SupplierName],[SupplierAddress],
		[Supplier GSTIN],[Supplier State],[Product Name] ,[Product Code],[HSN Code],[SpmId],[Prdid],[InvQty],[CmpId],[TaxPerc],[TaxableAmount],[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],LineNetAmount,[UPC],[Group Name],[GroupType],[UsrId]) 
		SELECT PurRcptRefNo,GoodsRcvdDate,PR.InvDate AS InvDate,PR.PurRcptId AS InvId,CmpInvNo AS RefNo,PR.PurOrderRefNo,SpmCode,SpmName,SpmAdd1,'' as SupplierGSTIN,'' as SupplierState,
		PrdName,PrdCCode,'' as [HSN Code],S.SpmId AS SpmId,P.PrdId as Prdid,SUM(PRP.RcvdGoodBaseQty) AS InvQty,  
		C.CmpId AS CmpId,TC.TaxCode +'Value' as TaxPerc,
		SUM(TaxableAmount) as TaxableAmount,'Purchase' as IOTaxType,1 as TaxFlag,SUM(PRPT.TaxAmount) as TaxPercent,PRPT.TaxId,
		SUM(PrdNetAmount) as [LineNetAmount],UPC,'' as [Group Name] ,2 as [GroupType],@Pi_UsrId AS UserId  
		FROM 
		PurchaseReceipt PR WITH (NOLOCK)  
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK) ON PR.PurRcptId=PRP.PurRcptId 
		INNER JOIN PurchaseReceiptProductTax PRPT WITH (NOLOCK) ON PR.PurRcptId=PRPT.PurRcptId AND  PRP.PurRcptId=PRPT.PurRcptId  AND PRP.PrdSlNo=PRPT.PrdSlNo 
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId 
		INNER JOIN #UOM U ON U.Prdid=P.Prdid and U.PrdId=PRP.PrdId    
		INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
		INNER JOIN Supplier S WITH (NOLOCK) ON S.SpmId = PR.SpmId
		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId =PRPT.TaxId    
		LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		AND (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
		C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE PR.GoodsRcvdDate Between @FromDate and @ToDate and PR.Status=1
		Group By PurRcptRefNo,GoodsRcvdDate,PR.PurRcptId,PR.InvDate,CmpInvNo,PR.PurOrderRefNo,SpmCode,SpmName,SpmAdd1,PrdName,PrdCCode,S.SpmId,P.PrdId,
		C.CmpId,TC.TaxCode,TaxPerc,PRPT.TaxId,[UPC]
		HAVING  SUM(PRPT.TaxAmount+PRPT.TaxableAmount) > 0 		
		
		
		INSERT INTO #TmpRptIOTaxSummary([GRN No],[GRN date],[InvDate],[InvId],[RefNo],[ODN Number],[SupplierCode],[SupplierName],[SupplierAddress],
		[Supplier GSTIN],[Supplier State],[Product Name] ,[Product Code],[HSN Code],[SpmId],[Prdid],[InvQty],[CmpId],[TaxPerc],[TaxableAmount],[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],LineNetAmount,[UPC],[Group Name],[GroupType],[UsrId]) 
		SELECT PurRcptRefNo,'' AS [GRN date],PurRetDate AS InvDate,PR.PurRetId AS InvId,PurRetRefNo AS RefNo,'',SpmCode,SpmName,SpmAdd1,'' as SupplierGSTIN,'' as SupplierState,
		PrdName,PrdCCode,'' as [HSN Code],S.SpmId AS SpmId,P.PrdId as Prdid,-1*SUM(PRP.RetInvBaseQty) AS InvQty,  
		C.CmpId AS CmpId,TC.TaxCode +' Rate' as TaxPerc,
		-1*SUM(TaxableAmount) as TaxableAmount,'PurchaseReturn' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,PRPT.TaxId,
		-1*SUM(PrdNetAmount) as [LineNetAmount],UPC,'' as [Group Name] ,2 as [GroupType],@Pi_UsrId AS UserId  
		FROM 
		PurchaseReturn  PR WITH (NOLOCK)  
		INNER JOIN PurchaseReturnProduct PRP WITH (NOLOCK) ON PR.PurRetId=PRP.PurRetId 
		INNER JOIN PurchaseReturnProductTax PRPT WITH (NOLOCK) ON PR.PurRetId=PRPT.PurRetId AND  PRP.PurRetId=PRPT.PurRetId  AND PRP.PrdSlNo=PRPT.PrdSlNo 
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId
		INNER JOIN #UOM U ON U.Prdid=P.Prdid and U.PrdId=PRP.PrdId     
		INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
		INNER JOIN Supplier S WITH (NOLOCK) ON S.SpmId = PR.SpmId
		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId =PRPT.TaxId    
		LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId  
		AND (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
		C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
		WHERE PR.PurRetDate Between @FromDate and @ToDate and PR.Status=1
		Group By PurRcptRefNo,PurRetDate,PR.PurRetId,PurRetRefNo,SpmCode,SpmName,SpmAdd1,PrdName,PrdCCode,S.SpmId,P.PrdId,
		C.CmpId,TC.TaxCode,TaxPerc,PRPT.TaxId,[UPC]
		HAVING SUM(TaxableAmount) >0 		
		
		
		INSERT INTO #TmpRptIOTaxSummary([GRN No],[GRN date],[InvDate],[InvId],[RefNo],[ODN Number],[SupplierCode],[SupplierName],[SupplierAddress],
		[Supplier GSTIN],[Supplier State],[Product Name] ,[Product Code],[HSN Code],[SpmId],[Prdid],[InvQty],[CmpId],[TaxPerc],[TaxableAmount],[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],LineNetAmount,[UPC],[Group Name],[GroupType],[UsrId]) 
		SELECT PurRcptRefNo,'' AS [GRN date],PurRetDate AS InvDate,PR.PurRetId AS InvId,PurRetRefNo AS RefNo,'',SpmCode,SpmName,SpmAdd1,'' as SupplierGSTIN,'' as SupplierState,
		PrdName,PrdCCode,'' as [HSN Code],S.SpmId AS SpmId,P.PrdId as Prdid,-1*SUM(PRP.RetInvBaseQty) AS InvQty,  
		C.CmpId AS CmpId,TC.TaxCode +' Value' as TaxPerc,
		-1*SUM(TaxableAmount) as TaxableAmount,'PurchaseReturn' as IOTaxType,1 as TaxFlag,-1*SUM(PRPT.TaxAmount) as TaxPercent,PRPT.TaxId,
		-1*SUM(PrdNetAmount) as [LineNetAmount],UPC,'' as [Group Name] ,2 as [GroupType],@Pi_UsrId AS UserId  
		FROM 
		PurchaseReturn  PR WITH (NOLOCK)  
		INNER JOIN PurchaseReturnProduct PRP WITH (NOLOCK) ON PR.PurRetId=PRP.PurRetId 
		INNER JOIN PurchaseReturnProductTax PRPT WITH (NOLOCK) ON PR.PurRetId=PRPT.PurRetId AND  PRP.PurRetId=PRPT.PurRetId  AND PRP.PrdSlNo=PRPT.PrdSlNo 
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId
		INNER JOIN #UOM U ON U.Prdid=P.Prdid and U.PrdId=PRP.PrdId     
		INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
		INNER JOIN Supplier S WITH (NOLOCK) ON S.SpmId = PR.SpmId
		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId =PRPT.TaxId    
		LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId 
		AND (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
		C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
		WHERE PR.PurRetDate Between @FromDate and @ToDate and PR.Status=1
		Group By PurRcptRefNo,PurRetDate,PR.PurRetId,PurRetRefNo,SpmCode,SpmName,SpmAdd1,PrdName,PrdCCode,S.SpmId,P.PrdId,
		C.CmpId,TC.TaxCode,TaxPerc,PRPT.TaxId,[UPC]
		HAVING Sum(TaxableAmount+PRPT.TaxAmount) >0 
		
		INSERT INTO #TmpRptIOTaxSummary([GRN No],[GRN date],[InvDate],[InvId],[RefNo],[ODN Number],[SupplierCode],[SupplierName],[SupplierAddress],
		[Supplier GSTIN],[Supplier State],[Product Name] ,[Product Code],[HSN Code],[SpmId],[Prdid],[InvQty],[CmpId],[TaxPerc],[TaxableAmount],[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],LineNetAmount,[UPC],[Group Name],[GroupType],[UsrId]) 
		SELECT  '' AS [GRN No],'' AS [GRN date],NULL, 0 [InvId],'' AS [RefNo],'' AS [ODN Number],'' AS [SupplierCode],'' AS [SupplierName],''AS [SupplierAddress],'' AS [Supplier GSTIN],
		'' AS [Supplier State],'' AS [Product Name] ,'' AS [Product Code],'' AS [HSN Code],0 [SpmId],0 as Prdid,0 as [InvQty],0 as[CmpId],  [TaxPerc] ,0 as [TaxableAmount],'' as [IOTaxType] ,
		100 as [TaxFlag],SUM([TaxPercent]) as [TaxPercent],0 as [TaxId],0 as  LineNetAmount,0 as [UPC],'ZZZZZZ' as [Group Name],3 as [GroupType],[UsrId]
		FROM #TmpRptIOTaxSummary WHERE TaxFlag=1		
		GROUP BY [UsrId],[TaxPerc]
		
		
		SELECT StateCode,StateName,TinFirst2Digit,MasterRecordId
		INTO #SupplierState 
		FROM UDCHD A (NOLOCK)
		INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
		INNER JOIN UdcDetails C (NOLOCK) ON B.MasterId=C.MasterId
		and B.UdcMasterId=C.UdcMasterId
		INNER JOIN UdcDefault D (NOLOCK) ON D.MasterId=C.MasterId and D.MasterId=B.MasterId
		and D.UdcMasterId=C.UdcMasterId and D.UdcMasterId=B.UdcMasterId
		INNER JOIN StateMaster E (NOLOCK) ON E.StateName=D.ColValue and E.StateName=C.ColumnValue
		WHERE MasterName='Supplier Master' and ColumnName='State Name'
		
					
		UPDATE A  SET A.[Supplier State]=B.StateName 
		FROM #TmpRptIOTaxSummary A 
		INNER JOIN  #SupplierState  B  ON A.Spmid=B.MasterRecordId
		
		SELECT MasterRecordId,ColumnName AS SupplierGSTIN
		INTO #SupplierGSTIN
		FROM UDCHD A (NOLOCK)
		INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
		INNER JOIN UdcDetails C (NOLOCK) ON B.MasterId=C.MasterId
		and B.UdcMasterId=C.UdcMasterId	
		WHERE MasterName='Supplier Master' and ColumnName='GSTIN'
		
        UPDATE A  SET A.[Supplier GSTIN]=B.SupplierGSTIN 
		FROM #TmpRptIOTaxSummary A 
		INNER JOIN  #SupplierGSTIN  B  ON A.Spmid=B.MasterRecordId
		
		
		UPDATE TR SET  [HSN Code]=C.ColumnValue
		FROM UDCHD A (NOLOCK)
		INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
		INNER JOIN UdcDetails C (NOLOCK) ON B.MasterId=C.MasterId
		and B.UdcMasterId=C.UdcMasterId
		INNER JOIN #TmpRptIOTaxSummary TR ON TR.Prdid=C.MasterRecordId
		WHERE MasterName='Product Master' and ColumnName='HSN Code'
		
		
		IF NOT EXISTS(SELECT 'X' FROM #TmpRptIOTaxSummary)
		BEGIN
			DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM RptProductWiseSalesTaxGST
			WHERE UsrId=@Pi_UsrId
			SELECT * FROM RptProductWiseSalesTaxGST WHERE UsrId=@Pi_UsrId
			RETURN
		END
		
		
--		--Remove Duplicate [TaxableAmount] and LinelevelNetAmount
        SELECT DISTINCT
		[GRN No],[GRN date],[InvDate],[InvId],[RefNo],[SupplierCode],[SupplierName],[SupplierAddress],
		[Supplier GSTIN],[Supplier State],[Product Name] ,[Product Code],[HSN Code],[SpmId],[Prdid],[InvQty],[CmpId],
		[TaxableAmount],[IOTaxType],[TaxFlag],LineNetAmount,[UsrId]
		INTO #LineLevelGross	
		FROM #TmpRptIOTaxSummary WHERE UsrId=@Pi_UsrId and TaxFlag=0
		DECLARE @ColSelect AS Varchar(MAX)
		DECLARE @ColSelectDataType AS Varchar(5000)
		DECLARE @TableCol AS Varchar(2000)
		DECLARE @Columns1 AS Varchar(7000)
		DECLARE @OrderBy AS VARCHAR(2000)
		DECLARE @PCSelect AS VARCHAR(3000)
		SET @PCSelect=''
		SET @ColSelect=''
		SET @ColSelectDataType=''
		SET @TableCol=''
		SET @Columns1=''
		SET @CreateTable=''
		SET @OrderBy=''
		
		CREATE TABLE #DynamicCol
		(
			Slno INT IDENTITY(1,1),
			Taxperc	Varchar(50),
			TaxId INT
		)
		INSERT INTO #DynamicCol(Taxperc,TaxId)
		SELECT DISTINCT Taxperc,TaxId FROM #TmpRptIOTaxSummary WHERE TaxFlag IN(0,1) and GroupType=2
		ORDER BY TaxId	
		SELECT @ColSelect=@ColSelect+'ISNULL('+QuoteName(Taxperc)+',0) as '+QuoteName(Taxperc)+',' FROM #DynamicCol ORDER BY Slno
		SELECT @PCSelect=@PCSelect+Quotename(Taxperc)+',' FROM #DynamicCol ORDER BY Slno
		SET @PCSelect=LEFT(@PCSelect,LEN(@PCSelect)-1)
		SELECT @ColSelectDataType=@ColSelectDataType+QuoteName(Taxperc)+' Numeric(36,2),' FROM #DynamicCol ORDER BY Slno
		SET @ColSelect='SELECT SupplierCode,SupplierName,SupplierAddress,[Supplier GSTIN],[Supplier State],IOTaxType,[GRN No],[GRN date],RefNo,'+
        'InvDate,[ODN Number],[Product Code],[Product Name],[HSN Code],[UPC],InvQty,TaxableAmount,'+@ColSelect+'LineNetAmount,[Group Name],[GroupType],[UsrId]'
		SET @TableCol= 'Slno BIGINT IDENTITY(1,1),[SupplierCode] Varchar(75),[SupplierName] Varchar(150),[SupplierAddress] Varchar(150),[Supplier GSTIN] Varchar(150),'+
        '[Supplier State] Varchar(150),[IOTaxType] [varchar](100) NULL,[GRN No] NVarchar(100),[GRN date] DateTime,[Invoice Number] NVarchar(100),[Invoice Date] Datetime,[ODN Number] Varchar(100),'+
        '[Product Code] Varchar(75),[Product Name] Varchar(150),[HSN Code] Varchar(50),UPC INT,[InvQty] [int] NULL,[TaxableAmount] [numeric](38, 6) NULL,'
		SET @Columns1='SELECT SupplierCode,SupplierName,SupplierAddress,[Supplier GSTIN],[Supplier State],IOTaxType,[GRN No],[GRN date],RefNo,'+
        'Invdate,[ODN Number],[Product Code],[Product Name],[HSN Code],UPC,[InvQty],[TaxableAmount],LineNetAmount,TaxPercent ,Taxperc,[Group Name],[GroupType],[UsrId] FROM #TmpRptIOTaxSummary'
		SET @OrderBy=' ORDER BY [Group Name],[GroupType],IOTaxType,Invdate,SupplierName,[Product Name]'
		SET @CreateTable=' IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME=''RptPurchaseTaxGST'' and XTYPE=''U'')'+
		' DROP TABLE RptPurchaseTaxGST'+
		' CREATE TABLE RptPurchaseTaxGST ('+@TableCol+@ColSelectDataType+' LineNetAmount Numeric(36,2),[Group Name] Varchar(100),Grouptype TINYINT,UsrId INT)'
		--PRINT @CreateTable
	    EXEC(@CreateTable)
		SET @SQL=' INSERT INTO RptPurchaseTaxGST '+ @ColSelect+ ' FROM'+
		'('+@Columns1+
		') PS'+
		' PIVOT'+
		'('+
			' SUM(TaxPercent) FOR Taxperc IN('+@PCSelect+')'+
		')PVTTax '+ @OrderBy
		--PRINT @SQL
		EXEC(@SQL)
		----GRAND TOTAL UPDATE
		SELECT 'ZZZZZZ' as [Group Name], 3 as GroupType ,SUM([InvQty]) as [InvQty],SUM(LineNetAmount) as LineNetAmount,SUM(TaxableAmount) as TaxableAmount
		INTO #GrandTotal
		FROM #LineLevelGross WHERE TaxFlag=0 and [UsrId]=@Pi_UsrId
		UPDATE Y SET  
		Y.[InvQty]=X.[InvQty] ,Y.LineNetAmount=X.[LineNetAmount],Y.[TaxableAmount]=X.TaxableAmount 
		FROM RptPurchaseTaxGST Y INNER JOIN #GrandTotal X ON X.[Group Name]=Y.[Group Name]
		AND X.GroupType=Y.GroupType WHERE Y.[UsrId]=@Pi_UsrId
		---TILL HERE
			DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=@Pi_RptId
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
			FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
			RoundOff,CreatedDate)
			SELECT 1,402,'Product Wise Input Tax',1,'Supplier State',20,1,0,1,1,'Supplier','State','Name',0,GETDATE()
			UNION ALL		
			SELECT 1,402,'Product Wise Input Tax',2,'SupplierCode',50,1,0,1,1,'Supplier','Code','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',3,'SupplierName',50,1,0,1,1,'Supplier','Name','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',4,'SupplierAddress',75,1,0,1,1,'Supplier','Address','',0,GETDATE()			
			UNION ALL		
			SELECT 1,402,'Product Wise Input Tax',5,'IOTaxType',75,1,0,1,1,'Purchase/','PurReturn','',0,GETDATE()
			UNION ALL			
			SELECT 1,402,'Product Wise Input Tax',6,'GRN No',75,1,0,1,1,'GRN.','Number','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',7,'GRN date',75,1,0,1,4,'GRN.','Date','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',8,'Invoice Number',75,1,0,1,1,'Comp InvoiceNo/','ReturnRefNo','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',9,'Invoice Date',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',10,'[ODN Number]',75,1,0,1,1,'Purchase Order','Number','',0,GETDATE()
			UNION ALL			
			SELECT 1,402,'Product Wise Input Tax',11,'Product Code',75,1,0,1,1,'Product Code','','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',12,'Product Name',75,1,0,1,1,'Product Name','','',0,GETDATE()
			UNION ALL			
			SELECT 1,402,'Product Wise Input Tax',13,'HSN Code',75,1,0,1,1,'HSN Code','','',0,GETDATE()
			UNION ALL		
			SELECT 1,402,'Product Wise Input Tax',14,'UPC',20,1,0,2,2,'UPC','','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',15,'InvQty',75,1,0,2,2,'Total','Quantity','',0,GETDATE()
			UNION ALL
			SELECT 1,402,'Product Wise Input Tax',16,'TaxableAmount',20,1,0,2,3,'Taxable','Amount','',2,GETDATE()
		
			SET @Str=''
			SELECT @MaxId=MAX(ColId)+1,@ReportId=ReportId FROM  Report_Template_GST (NOLOCK) WHERE RptId=@Pi_RptId
			GROUP BY ReportId
			SELECT @start = 1, @end = CHARINDEX(',', @PCSelect) 
			WHILE @start < LEN(@PCSelect) + 1 BEGIN 
				IF @end = 0  
				SET @end = LEN(@PCSelect) + 1
				SET @Str=SUBSTRING(@PCSelect, @start, @end - @start)
				INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
				FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
				CreatedDate)  
				SELECT TOP 1 ReportId,RptId,RptName,@MaxId,SUBSTRING(@PCSelect, @start, @end - @start),
				18,1,0,2,3,SUBSTRING(@PCSelect, @start, @end - @start)				
				,'','',2,Getdate()
				FROM Report_Template_GST WHERE RptId=@Pi_RptId
				
				SET @start = @end + 1 
				SET @end = CHARINDEX(',', @PCSelect, @start)
				SET @MaxId=@MaxId+1
			END 
			
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
			FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
			CreatedDate)  
			SELECT TOP 1 ReportId,RptId,RptName,@MaxId+1,'LineNetAmount',
			18,1,0,2,3,'Product','Level','NetAmount',2,Getdate()
			FROM Report_Template_GST WHERE RptId=@Pi_RptId	
			
			UPDATE Report_template_GST SET FieldName=REPLACE(REPLACE(FieldName,']',''),'[','')
			WHERE RptId=@Pi_RptId 
			DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM RptProductWiseSalesTaxGST
			WHERE UsrId=@Pi_UsrId
			SELECT * FROM RptPurchaseTaxGST WHERE UsrId=@Pi_UsrId
END
GO
DELETE FROM RptGroup WHERE RptId=407
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSTTaxReports 400',407,'ProductWiseInOutPutTax','Product wise Input output tax',1
GO
DELETE FROM RptHeader WHERE RptId=407
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'ProductWiseInOutPutTax','Product wise Input output tax',407,'Product wise Input output tax','Proc_RptInputOutputProductWiseGSTTax','RptInputOutPutGSTTax','RptInputOutPutGSTTax.rpt',0
GO
DELETE FROM RptDetails WHERE RptId=407
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (407,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (407,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (407,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to select Company',0)
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=407
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,407,'Product Wise Input Output Tax',1,'Product Name',50,1,0,1,1,'Product Name','','',0,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',2,'Product Code',20,1,0,1,1,'Product Code','','',0,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',3,'HSN Code',20,1,0,1,1,'HSN Code','','',0,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',4,'InPutQty',50,1,0,2,2,'Input','Total','Quantity',0,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',5,'OutPutQty',50,1,0,2,2,'Output','Total','Quantity',0,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',6,'InputCGST Rate',16,1,0,2,3,'Input','CGST%','',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',7,'InputSGST Rate',16,1,0,2,3,'Input','SGST%','',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',8,'InputIGST Rate',16,1,0,2,3,'Input','IGST%','',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',9,'InputUTGST Rate',16,1,0,2,3,'Input','UTGST%','',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',10,'InputCGST Value',16,1,0,2,3,'Input','CGST','Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',11,'InputSGST Value',16,1,0,2,3,'Input','SGST','Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',12,'InputIGST Value',16,1,0,2,3,'Input','IGST','Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',13,'InputUTGST Value',16,1,0,2,3,'Input','UTGST','Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',14,'OutPutCGST Rate',16,1,0,2,3,'OutPut','CGST%','',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',15,'OutPutSGST Rate',16,1,0,2,3,'OutPut','SGST%','',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',16,'OutPutIGST Rate',16,1,0,2,3,'OutPut','IGST%','',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',17,'OutPutUTGST Rate',16,1,0,2,3,'OutPut','UTGST%','',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',18,'OutPutCGST Value',16,1,0,2,3,'OutPut','CGST','Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',19,'OutPutSGST Value',16,1,0,2,3,'OutPut','SGST','Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',20,'OutPutIGST Value',16,1,0,2,3,'OutPut','IGST','Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',21,'OutPutUTGST Value',16,1,0,2,3,'OutPut','UTGST','Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',22,'OutPutCGST Value',16,1,0,2,3,'Differential of','CGST','Input OutPut Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',23,'OutPutSGST Value',16,1,0,2,3,'Differential of','SGST','Input OutPut Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',24,'OutPutIGST Value',16,1,0,2,3,'Differential of','IGST','Input OutPut Tax Amount',2,GETDATE()
UNION ALL
SELECT 1,407,'Product Wise Input Output Tax',25,'OutPutUTGST Value',16,1,0,2,3,'Differential of','UTGST','Input OutPut Tax Amount',2,GETDATE()
GO
IF EXISTS(SELECT 'X' FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='RptInputOutPutGSTTax')
DROP TABLE RptInputOutPutGSTTax
GO
CREATE TABLE [RptInputOutPutGSTTax](
	[SLNO] [bigint] IDENTITY(1,1) NOT NULL,
	[Product Name] [varchar](150) NULL,
	[Product Code] [varchar](75) NULL,
	[HSN Code] [varchar](50) NULL,
	[InPutQty] [int] NULL,
	[OutPutQty] [int] NULL,
	[TaxableAmount] [numeric](38, 6) NULL,
	[InputCGST Rate] [numeric](36, 2) NULL,
	[InputCGST Value] [numeric](36, 2) NULL,
	[InputSGST Rate] [numeric](36, 2) NULL,
	[InputSGST Value] [numeric](36, 2) NULL,
	[InputIGST Rate] [numeric](36, 2) NULL,
	[InputIGST Value] [numeric](36, 2) NULL,
	[InputUTGST Rate] [numeric](36, 2) NULL,
	[InputUTGST Value] [numeric](36, 2) NULL,
	[OutputCGST Rate] [numeric](36, 2) NULL,
	[OutputCGST Value] [numeric](36, 2) NULL,
	[OutputSGST Rate] [numeric](36, 2) NULL,
	[OutputSGST Value] [numeric](36, 2) NULL,
	[OutputIGST Rate] [numeric](36, 2) NULL,
	[OutputIGST Value] [numeric](36, 2) NULL,
	[OutputUTGST Rate] [numeric](36, 2) NULL,
	[OutputUTGST Value] [numeric](36, 2) NULL,
	[DiffCGST Value] [numeric](36, 2) NULL,
	[DiffSGST Value] [numeric](36, 2) NULL,
	[DiffIGST Value] [numeric](36, 2) NULL,
	[DiffUTGST Value] [numeric](36, 2) NULL,
	[Group Name] [varchar](100) NULL,
	[Grouptype] [tinyint] NULL,
	[UsrId] [int] NULL
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptInputOutputProductWiseGSTTax')
DROP PROCEDURE Proc_RptInputOutputProductWiseGSTTax
GO
--Select * from Users
---EXEC Proc_RptInputOutputProductWiseGSTTax 407,1,0,'',0,0,1
--Select * from RptInputOutPutGSTTax where [Product Code]='40017593'
--Select * from Purchasereturn
--Select * from ReturnProductTax order by LastModDate Desc
CREATE PROCEDURE [Proc_RptInputOutputProductWiseGSTTax]
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
* PROCEDURE	: Proc_RptInputOutputProductWiseGSTTax
* PURPOSE	: To get the Tax details
* CREATED	: Murugan.R
* CREATED DATE	: 12/05/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId	        AS	INT
	DECLARE @ErrNo	 	AS	INT
		
	DECLARE @SQL as Varchar(MAX)
	DECLARE @MaxId as INT
	DECLARE @ReportId as INT
	DECLARE @start INT, @end INT 
	DECLARE @Str AS VARCHAR(100)
	DECLARE @CreateTable AS VARCHAR(7000)
		
	SET @ErrNo=0
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	
	
	IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='RptInputOutPutGSTTax')
	BEGIN
		TRUNCATE TABLE RptInputOutPutGSTTax
	END
	
	IF EXISTS(SELECT NAME FROM Tempdb..SYSOBJECTS WHERE XTYPE='U' AND NAME='##RptInputOutPutGSTTax')
	BEGIN
		DROP TABLE ##RptInputOutPutGSTTax
	END
	
		CREATE TABLE #TmpRptIOTaxSummary
		(
			[Product Name] Varchar(150),			
			[Product Code] Varchar(75),
			[HSN Code] Varchar(75),
			[Prdid] [int] NULL,
			[CmpId] [int] NULL,
			[TaxPerc] [varchar](50) NULL,
			[TaxableAmount] [numeric](38, 6) NULL,
			InputQty INT,
			OutPutQty INT,
			[IOTaxType] [varchar](100) NULL,
			[TaxFlag] [int] NULL,
			[TaxPercent] [numeric](38, 6) NULL,
			[TaxId] [int] NULL,			
			[Group Name]  Varchar(200),
			[GroupType] INT,
			[UsrId] [int] NULL
		)
		
		CREATE TABLE #PurchaseVsSales
		(
			TransId TinyInt,
			PrdId INT,
			InOutPutQty INT,
			TaxableAmount Numeric(32,4),
			TaxAmount Numeric(25,4),
			TaxPerc Numeric(10,2),
			TaxId INT
		)
		
		
		CREATE TABLE ##RptInputOutPutGSTTax(
		[SLNO] [bigint] IDENTITY(1,1) NOT NULL,
		[Product Name] [varchar](150) NULL,
		[Product Code] [varchar](75) NULL,
		[HSN Code] [varchar](50) NULL,
		[InPutQty] [int] NULL,
		[OutPutQty] [int] NULL,
		[TaxableAmount] [numeric](38, 6) NULL,
		[InputCGST Rate] [numeric](36, 2) NULL,
		[InputCGST Value] [numeric](36, 2) NULL,
		[InputSGST Rate] [numeric](36, 2) NULL,
		[InputSGST Value] [numeric](36, 2) NULL,
		[InputIGST Rate] [numeric](36, 2) NULL,
		[InputIGST Value] [numeric](36, 2) NULL,
		[InputUTGST Rate] [numeric](36, 2) NULL,
		[InputUTGST Value] [numeric](36, 2) NULL,
		[OutputCGST Rate] [numeric](36, 2) NULL,
		[OutputCGST Value] [numeric](36, 2) NULL,
		[OutputSGST Rate] [numeric](36, 2) NULL,
		[OutputSGST Value] [numeric](36, 2) NULL,
		[OutputIGST Rate] [numeric](36, 2) NULL,
		[OutputIGST Value] [numeric](36, 2) NULL,
		[OutputUTGST Rate] [numeric](36, 2) NULL,
		[OutputUTGST Value] [numeric](36, 2) NULL,
		[Group Name] [varchar](100) NULL,
		[Grouptype] [tinyint] NULL,
		[UsrId] [int] NULL
		)
		CREATE TABLE #SalesInvoiceProductTax
		(
		[SalId] [bigint] NOT NULL,
		[PrdSlNo] [int] NOT NULL,
		[TaxId] [int] NOT NULL,
		[TaxPerc] [numeric](10, 6) NOT NULL,
		[TaxableAmount] [numeric](18, 6) NOT NULL,
		[TaxAmount] [numeric](18, 6) NOT NULL
		)
		INSERT INTO #PurchaseVsSales(TransId,PrdId,InOutPutQty,TaxableAmount,TaxAmount,TaxPerc,TaxId)		
		SELECT 1 as TransId ,Prdid,SUM(InputQty) as InputQty,
		SUM(TaxableAmount) as TaxableAmount,
		SUM(TaxAmount) as TaxAmount,TaxPerc,TaxId
		FROM
		(
			SELECT PrdId ,SUM(PRP.RcvdGoodBaseQty) as InputQty,
			SUM(TaxableAmount) as TaxableAmount,
			SUM(PRPT.TaxAmount) as TaxAmount,TaxPerc ,PRPT.TaxId		
			FROM 
			PurchaseReceipt PR WITH (NOLOCK)  
			INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK) ON PR.PurRcptId=PRP.PurRcptId 
			INNER JOIN PurchaseReceiptProductTax PRPT WITH (NOLOCK) ON PR.PurRcptId=PRPT.PurRcptId AND  PRP.PurRcptId=PRPT.PurRcptId  AND PRP.PrdSlNo=PRPT.PrdSlNo 
			WHERE PR.InvDate Between @FromDate and @ToDate and PR.Status=1 and VatGst='GST'
			GROUP BY PrdId,TaxPerc,PRPT.TaxId
			HAVING Sum(TaxableAmount) >0  
			UNION ALL
			SELECT Prdid,-1*SUM(RetSalBaseQty+RetUnSalBaseQty) as InputQty,
					-1*SUM(PRPT.TaxableAmount) as TaxableAmount,
					-1*SUM(PRPT.TaxAmount) as TaxAmount, TaxPerc ,PRPT.TaxId
			
			FROM 
			PurchaseReturn  PR WITH (NOLOCK)  
			INNER JOIN PurchaseReturnProduct PRP WITH (NOLOCK) ON PR.PurRetId=PRP.PurRetId 
			INNER JOIN PurchaseReturnProductTax PRPT WITH (NOLOCK) ON PR.PurRetId=PRPT.PurRetId AND  PRP.PurRetId=PRPT.PurRetId  AND PRP.PrdSlNo=PRPT.PrdSlNo 
			WHERE PR.PurRetDate Between @FromDate and @ToDate and PR.Status=1 and VatGst='GST'
			GROUP BY PrdId,TaxPerc,PRPT.TaxId
			HAVING SUM(TaxableAmount) >0 		
		)X GROUP BY Prdid,TaxPerc,TaxId
		
		
		
		
			
		
		INSERT INTO #PurchaseVsSales(TransId,PrdId,InOutPutQty,TaxableAmount,TaxAmount,TaxPerc,TaxId)
		SELECT 2 as TransId ,Prdid,SUM(OutPutQty) as OutPutQty,
		SUM(TaxableAmount) as TaxableAmount,
		SUM(TaxAmount) as TaxAmount,TaxPerc,TaxId
		FROM(
				SELECT Prdid,SUM(BaseQty) as OutPutQty,
				SUM(TaxableAmount)	AS TaxableAmount,
				SUM(TaxAmount) as TaxAmount,TaxPerc,SPT.TaxId
				FROM 
				SalesInvoice SI WITH (NOLOCK)  
				INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
				INNER JOIN SalesInvoiceProductTax SPT  ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo  
				WHERE SI.Salinvdate Between @FromDate and @ToDate 
				and SI.Dlvsts >3 and VatGst='GST' and SPT.TaxableAmount>0
				GROUP BY TaxPerc,PrdId,SPT.TaxId				
				UNION ALL
				Select Prdid,-1*SUM(BaseQty) as OutPutQty,	
				-1*SUM(TaxableAmt) AS TaxableAmount	,
				-1*SUM(RPT.TaxAmt),TaxPerc,RPT.TaxID
				FROM ReturnHeader RH WITH (NOLOCK)  
				INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId ---AND RP.LineType=1  
				INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
				WHERE RH.Status = 0  and RH.ReturnDate  Between @FromDate and @ToDate and VatGst='GST'
				and RPT.TaxableAmt>0
				GROUP BY TaxPerc,PrdId,RPT.TaxId
				 
		) X GROUP BY Prdid,TaxPerc,TaxId
			
		INSERT INTO #TmpRptIOTaxSummary([Product Name] ,[Product Code],[HSN Code],[Prdid],[CmpId],[TaxPerc],[TaxableAmount],InputQty,OutPutQty,[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],[Group Name],[GroupType],[UsrId])
		SELECT PrdName,PrdCCode,'' as [HSN Code],P.PrdId as Prdid,  
		C.CmpId AS CmpId,
		CASE	WHEN TaxCode IN('InputIGST','IGST') THEN 'InputIGST Rate'
				WHEN TaxCode IN ('InputCGST','CGST') Then 'InputCGST Rate'
				WHEN TaxCode IN ('InputSGST','SGST') Then 'InputSGST Rate'
				WHEN TaxCode IN ('InputUTGST','UTGST') Then 'InputUTGST Rate'
		END	 as TaxPerc,
		TaxableAmount as TaxableAmount,
		InOutPutQty as InputQty,0 as OutPutQty,'Purchase-Sales' as IOTaxType,1 as TaxFlag,PRP.TaxPerc as TaxPercent,PRP.TaxId,
		'' as [Group Name] ,2 as [GroupType],@Pi_UsrId AS UserId  
		FROM 
		#PurchaseVsSales PRP
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId 
		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId =PRP.TaxId    
		LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		AND (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
		C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE TaxCode IN('InputCGST','InputSGST','InputIGST','InputUTGST','CGST','SGST','IGST','UTGST')
		and TransId=1
		
		INSERT INTO #TmpRptIOTaxSummary([Product Name] ,[Product Code],[HSN Code],[Prdid],[CmpId],[TaxPerc],[TaxableAmount],InputQty,OutPutQty,[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],[Group Name],[GroupType],[UsrId])
		SELECT PrdName,PrdCCode,'' as [HSN Code],P.PrdId as Prdid,  
		C.CmpId AS CmpId,
		CASE	WHEN TaxCode IN('InputIGST','IGST') THEN 'InputIGST Value'
				WHEN TaxCode IN ('InputCGST','CGST') Then 'InputCGST Value'
				WHEN TaxCode IN ('InputSGST','SGST') Then 'InputSGST Value'
				WHEN TaxCode IN ('InputUTGST','UTGST') Then 'InputUTGST Value'
		END	 as TaxPerc,
		TaxableAmount as TaxableAmount,
		InOutPutQty,0 as OutPutQty,'Purchase-Sales' as IOTaxType,1 as TaxFlag,PRP.TaxAmount as TaxPercent,PRP.TaxId,
		'' as [Group Name] ,2 as [GroupType],@Pi_UsrId AS UserId  
		FROM 
		#PurchaseVsSales PRP
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId 
		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId =PRP.TaxId    
		LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		AND (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
		C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE TaxCode IN('InputCGST','InputSGST','InputIGST','InputUTGST','CGST','SGST','IGST','UTGST')
		and TransId=1
	
		
		INSERT INTO #TmpRptIOTaxSummary([Product Name] ,[Product Code],[HSN Code],[Prdid],[CmpId],[TaxPerc],[TaxableAmount],InputQty,OutPutQty,[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],[Group Name],[GroupType],[UsrId])
		SELECT PrdName,PrdCCode,'' as [HSN Code],P.PrdId as Prdid,  
		C.CmpId AS CmpId,
		CASE	WHEN TaxCode IN('OutputIGST','IGST') THEN 'OutputIGST Rate'
						WHEN TaxCode IN ('OutputCGST','CGST') Then 'OutputCGST Rate'
						WHEN TaxCode IN ('OutputSGST','SGST') Then 'OutputSGST Rate'
						WHEN TaxCode IN ('OutputUTGST','UTGST') Then 'OutputUTGST Rate'
				END	 as TaxPerc,
		TaxableAmount as TaxableAmount,
		0 as InputQty,InOutPutQty as OutPutQty,'Purchase-Sales' as IOTaxType,1 as TaxFlag,PRP.TaxPerc as TaxPercent,PRP.TaxId,
		'' as [Group Name] ,2 as [GroupType],@Pi_UsrId AS UserId  
		FROM 
		#PurchaseVsSales PRP
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId 
		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId =PRP.TaxId    
		LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		AND (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
		C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE TaxCode IN('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST')
		and TransId=2
		
		
		INSERT INTO #TmpRptIOTaxSummary([Product Name] ,[Product Code],[HSN Code],[Prdid],[CmpId],[TaxPerc],[TaxableAmount],InputQty,OutPutQty,[IOTaxType] ,
		[TaxFlag],[TaxPercent],[TaxId],[Group Name],[GroupType],[UsrId])
		SELECT PrdName,PrdCCode,'' as [HSN Code],P.PrdId as Prdid,  
		C.CmpId AS CmpId,
		CASE	WHEN TaxCode IN('OutputIGST','IGST') THEN 'OutputIGST Value'
						WHEN TaxCode IN ('OutputCGST','CGST') Then 'OutputCGST Value'
						WHEN TaxCode IN ('OutputSGST','SGST') Then 'OutputSGST Value'
						WHEN TaxCode IN ('OutputUTGST','UTGST') Then 'OutputUTGST Value'
				END	 as TaxPerc,
		TaxableAmount as TaxableAmount,
		0,InOutPutQty as OutPutQty,'Purchase-Sales' as IOTaxType,1 as TaxFlag,PRP.TaxAmount as TaxPercent,PRP.TaxId,
		'' as [Group Name] ,2 as [GroupType],@Pi_UsrId AS UserId  
		FROM 
		#PurchaseVsSales PRP
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId 
		INNER JOIN TaxConfiguration TC (NOLOCK) ON TC.TaxId =PRP.TaxId    
		LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
		AND (C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
		C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		WHERE TaxCode IN('OutputCGST','OutputSGST','OutputIGST','OutputUTGST','CGST','SGST','IGST','UTGST')
		and TransId=2
		
				
		UPDATE TR SET  [HSN Code]=C.ColumnValue
		FROM UDCHD A (NOLOCK)
		INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
		INNER JOIN UdcDetails C (NOLOCK) ON B.MasterId=C.MasterId
		and B.UdcMasterId=C.UdcMasterId
		INNER JOIN #TmpRptIOTaxSummary TR ON TR.Prdid=C.MasterRecordId
		WHERE MasterName='Product Master'  and ColumnName='HSN Code'
		
	
		
		IF NOT EXISTS(SELECT 'X' FROM #TmpRptIOTaxSummary)
		BEGIN		
			DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM RptInputOutPutGSTTax
			WHERE UsrId=@Pi_UsrId
			
			SELECT * FROM RptInputOutPutGSTTax	WHERE UsrId=@Pi_UsrId			
			RETURN
		END
				
		DECLARE @ColSelect AS Varchar(MAX)
		DECLARE @ColSelectDataType AS Varchar(5000)
		DECLARE @TableCol AS Varchar(2000)
		DECLARE @Columns1 AS Varchar(7000)
		DECLARE @OrderBy AS VARCHAR(2000)
		DECLARE @PCSelect AS VARCHAR(3000)
		SET @PCSelect=''
		SET @ColSelect=''
		SET @ColSelectDataType=''
		SET @TableCol=''
		SET @Columns1=''
		SET @CreateTable=''
		SET @OrderBy=''
		
		CREATE TABLE #DynamicCol
		(
			Slno INT IDENTITY(1,1),
			Taxperc	Varchar(50)		
		)
		
		INSERT INTO #DynamicCol
		SELECT 'OutputIGST Rate'
		UNION
		SELECT 'OutputCGST Rate'
		UNION
		SELECT 'OutputSGST Rate'
		UNION
		SELECT 'OutputUTGST Rate'
		UNION
		SELECT 'OutputIGST Value'
		UNION
		SELECT 'OutputCGST Value'
		UNION
		SELECT 'OutputSGST Value'
		UNION
		SELECT 'OutputUTGST Value'
		UNION
		SELECT 'InputIGST Rate'
		UNION
		SELECT 'InputCGST Rate'
		UNION
		SELECT 'InputSGST Rate'
		UNION
		SELECT 'InputUTGST Rate'
		UNION
		SELECT 'InputIGST Value'
		UNION
		SELECT 'InputCGST Value'
		UNION
		SELECT 'InputSGST Value'
		UNION
		SELECT 'InputUTGST Value'

	
	
		SELECT @ColSelect=@ColSelect+'ISNULL('+QuoteName(Taxperc)+',0) as '+QuoteName(Taxperc)+',' FROM #DynamicCol ORDER BY Slno
		SELECT @PCSelect=@PCSelect+Quotename(Taxperc)+',' FROM #DynamicCol ORDER BY Slno
		SET @PCSelect=LEFT(@PCSelect,LEN(@PCSelect)-1)
		SELECT @ColSelectDataType=@ColSelectDataType+QuoteName(Taxperc)+' Numeric(36,2),' FROM #DynamicCol ORDER BY Slno
		SET @ColSelect='SELECT [Product Name],[Product Code],[HSN Code],InPutQty,OutPutQty,[TaxableAmount],'+@ColSelect+'[Group Name],[GroupType],[UsrId]'
		SET @TableCol= 'SLNO BIGINT IDENTITY(1,1),'+
		'[Product Name] Varchar(150),[Product Code] Varchar(75),[HSN Code] varchar(50),'+		
		'InPutQty INT,OutPutQty INT,[TaxableAmount] [numeric](38, 6) NULL,'
	
		SET @Columns1='SELECT [Product Name],[Product Code],[HSN Code],InPutQty,OutPutQty,[TaxableAmount],TaxPercent ,Taxperc,[Group Name],[GroupType],[UsrId] FROM #TmpRptIOTaxSummary'
		SET @OrderBy=' ORDER BY [Group Name],[GroupType],[Product Name]'
		SET @CreateTable=' IF EXISTS(SELECT * FROM Tempdb..SYSOBJECTS WHERE NAME=''##RptInputOutPutGSTTax'' and XTYPE=''U'')'+
		' DROP TABLE ##RptInputOutPutGSTTax'+
		' CREATE TABLE ##RptInputOutPutGSTTax ('+@TableCol+@ColSelectDataType+' [Group Name] Varchar(100),Grouptype TINYINT,UsrId INT)'
		PRINT @CreateTable
		EXEC(@CreateTable)
		SET @SQL=' INSERT INTO ##RptInputOutPutGSTTax '+ @ColSelect+ ' FROM'+
		'('+@Columns1+
		') PS'+
		' PIVOT'+
		'('+
			' SUM(TaxPercent) FOR Taxperc IN('+@PCSelect+')'+
		')PVTTax '+ @OrderBy
		PRINT @SQL
		EXEC(@SQL)
		
		
		SELECT [Product Name],[Product Code],[HSN Code],SUM(ISNULL(InPutQty,0)) as InPutQty,SUM(ISNULL(OutPutQty,0)) as OutPutQty,
		SUM(ISNULL(TaxableAmount,0)) as TaxableAmount,
		SUM([InputCGST Rate]) as [InputCGST Rate],SUM([InputCGST Value]) as [InputCGST Value],
		SUM([InputSGST Rate]) as [InputSGST Rate],SUM([InputSGST Value]) as [InputSGST Value],
		SUM([InputIGST Rate]) as [InputIGST Rate],SUM([InputIGST Value]) as [InputIGST Value],
		SUM([InputUTGST Rate]) as  [InputUTGST Rate],SUM([InputUTGST Value]) as [InputUTGST Value],
		SUM([OutputCGST Rate]) as [OutputCGST Rate],SUM([OutputCGST Value]) as [OutputCGST Value],
		SUM([OutputSGST Rate]) as [OutputSGST Rate],SUM([OutputSGST Value]) as [OutputSGST Value],
		SUM([OutputIGST Rate]) as [OutputIGST Rate],SUM([OutputIGST Value]) as [OutputIGST Value],
		SUM([OutputUTGST Rate]) as [OutputUTGST Rate] ,SUM([OutputUTGST Value]) as [OutputUTGST Value] ,
		(SUM([InputCGST Value]-[OutputCGST Value])) as [DiffCGST Value],
		(SUM([InputSGST Value]-[OutputSGST Value])) as [DiffSGST Value],
		(SUM([InputIGST Value]-[OutputIGST Value])) as [DiffIGST Value],
		(SUM([InputUTGST Value]-[OutputUTGST Value])) as [DiffUTGST Value],
		[Group Name],Grouptype,UsrId
		INTO #RptProductTaxGroup
		FROM ##RptInputOutPutGSTTax		
		GROUP BY [Product Name],[Product Code],[HSN Code],[Group Name],Grouptype,UsrId
		
		
	
		

		INSERT INTO RptInputOutPutGSTTax([Product Name],[Product Code],[HSN Code],[InPutQty],
		[OutPutQty],[TaxableAmount],[InputCGST Rate],[InputCGST Value],
		[InputSGST Rate],[InputSGST Value],[InputIGST Rate],[InputIGST Value],
		[InputUTGST Rate],[InputUTGST Value],[OutputCGST Rate],[OutputCGST Value],
		[OutputSGST Rate],[OutputSGST Value],[OutputIGST Rate],[OutputIGST Value],
		[OutputUTGST Rate],[OutputUTGST Value],[DiffCGST Value],[DiffSGST Value],
		[DiffIGST Value],[DiffUTGST Value],[Group Name],[Grouptype],[UsrId]
)
		SELECT [Product Name],[Product Code],[HSN Code],SUM(ISNULL(InPutQty,0)) as InPutQty,SUM(ISNULL(OutPutQty,0)) as OutPutQty,
		SUM(ISNULL(TaxableAmount,0)) as TaxableAmount,
		[InputCGST Rate],SUM([InputCGST Value]) as [InputCGST Value],
		[InputSGST Rate],SUM([InputSGST Value]) as [InputSGST Value],
		[InputIGST Rate],SUM([InputIGST Value]) as [InputIGST Value],
		[InputUTGST Rate] ,SUM([InputUTGST Value]) as [InputUTGST Value],
		[OutputCGST Rate],SUM([OutputCGST Value]) as [OutputCGST Value],
		[OutputSGST Rate],SUM([OutputSGST Value]) as [OutputSGST Value],
		[OutputIGST Rate],SUM([OutputIGST Value]) as [OutputIGST Value],
		[OutputUTGST Rate],SUM([OutputUTGST Value]) as [OutputUTGST Value] ,
		(SUM([InputCGST Value]-[OutputCGST Value])) as [DiffCGST Value],
		(SUM([InputSGST Value]-[OutputSGST Value])) as [DiffSGST Value],
		(SUM([InputIGST Value]-[OutputIGST Value])) as [DiffIGST Value],
		(SUM([InputUTGST Value]-[OutputUTGST Value])) as [DiffUTGST Value],
		[Group Name],Grouptype,UsrId
		FROM #RptProductTaxGroup		
		GROUP BY [Product Name],[Product Code],[HSN Code],[Group Name],Grouptype,UsrId,
		[InputCGST Rate],[InputSGST Rate],[InputIGST Rate],[InputUTGST Rate],
		[OutputCGST Rate],[OutputSGST Rate],[OutputIGST Rate],[OutputUTGST Rate]
		ORDER BY [HSN Code], [Product Name]
		
		INSERT INTO RptInputOutPutGSTTax([Product Name],[Product Code],[HSN Code],[InPutQty],
		[OutPutQty],[TaxableAmount],[InputCGST Rate],[InputCGST Value],
		[InputSGST Rate],[InputSGST Value],[InputIGST Rate],[InputIGST Value],
		[InputUTGST Rate],[InputUTGST Value],[OutputCGST Rate],[OutputCGST Value],
		[OutputSGST Rate],[OutputSGST Value],[OutputIGST Rate],[OutputIGST Value],
		[OutputUTGST Rate],[OutputUTGST Value],[DiffCGST Value],[DiffSGST Value],
		[DiffIGST Value],[DiffUTGST Value],[Group Name],[Grouptype],[UsrId])
		
		SELECT '' as [Product Name],'' as [Product Code],'' as [HSN Code],SUM([InPutQty]) as [InPutQty],
		SUM([OutPutQty]) as [OutPutQty],
		SUM(ISNULL(TaxableAmount,0)) as TaxableAmount,
		0 as [InputCGST Rate],SUM([InputCGST Value]) as [InputCGST Value],
		0 as [InputSGST Rate],SUM([InputSGST Value]) as [InputSGST Value],
		0 as [InputIGST Rate],SUM([InputIGST Value]) as [InputIGST Value],
		0 as [InputUTGST Rate] ,SUM([InputUTGST Value]) as [InputUTGST Value],
		0 as [OutputCGST Rate],SUM([OutputCGST Value]) as [OutputCGST Value],
		0 as [OutputSGST Rate],SUM([OutputSGST Value]) as [OutputSGST Value],
		0 as [OutputIGST Rate],SUM([OutputIGST Value]) as [OutputIGST Value],
		0 as [OutputUTGST Rate],SUM([OutputUTGST Value]) as [OutputUTGST Value] ,
		ABS(SUM([InputCGST Value]-[OutputCGST Value])) as [DiffCGST Value],
		ABS(SUM([InputSGST Value]-[OutputSGST Value])) as [DiffSGST Value],
		ABS(SUM([InputIGST Value]-[OutputIGST Value])) as [DiffIGST Value],
		ABS(SUM([InputUTGST Value]-[OutputUTGST Value])) as [DiffUTGST Value],
		'ZZZZZZ' as [Group Name],3 as Grouptype,@Pi_UsrId as UsrId
		FROM RptInputOutPutGSTTax WHERE UsrId=@Pi_UsrId
		
		
		DELETE FROM RptInputOutPutGSTTax WHERE ([InPutQty]+[OutPutQty])=0
		AND UsrId=@Pi_UsrId
		

		DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=@Pi_RptId
		INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
		FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
		RoundOff,CreatedDate)
		SELECT 1,407,'Product Wise Input Output Tax',1,'Product Name',50,1,0,1,1,'Product Name','','',0,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',2,'Product Code',20,1,0,1,1,'Product Code','','',0,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',3,'HSN Code',20,1,0,1,1,'HSN Code','','',0,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',4,'InPutQty',50,1,0,2,2,'Input','Total','Quantity',0,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',5,'OutPutQty',50,1,0,2,2,'Output','Total','Quantity',0,GETDATE()
		--UNION ALL
		--SELECT 1,407,'Product Wise Input Output Tax',6,'TaxableAmount',16,1,0,2,3,'Taxable','Amount','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',6,'InputCGST Rate',16,1,0,2,3,'Input','CGST%','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',7,'InputSGST Rate',16,1,0,2,3,'Input','SGST%','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',8,'InputIGST Rate',16,1,0,2,3,'Input','IGST%','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',9,'InputUTGST Rate',16,1,0,2,3,'Input','UTGST%','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',10,'InputCGST Value',16,1,0,2,3,'Input','CGST','Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',11,'InputSGST Value',16,1,0,2,3,'Input','SGST','Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',12,'InputIGST Value',16,1,0,2,3,'Input','IGST','Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',13,'InputUTGST Value',16,1,0,2,3,'Input','UTGST','Tax Amount',2,GETDATE()

		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',14,'OutPutCGST Rate',16,1,0,2,3,'OutPut','CGST%','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',15,'OutPutSGST Rate',16,1,0,2,3,'OutPut','SGST%','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',16,'OutPutIGST Rate',16,1,0,2,3,'OutPut','IGST%','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',17,'OutPutUTGST Rate',16,1,0,2,3,'OutPut','UTGST%','',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',18,'OutPutCGST Value',16,1,0,2,3,'OutPut','CGST','Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',19,'OutPutSGST Value',16,1,0,2,3,'OutPut','SGST','Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',20,'OutPutIGST Value',16,1,0,2,3,'OutPut','IGST','Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',21,'OutPutUTGST Value',16,1,0,2,3,'OutPut','UTGST','Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',22,'DiffCGST Value',16,1,0,2,3,'Differential of','CGST','Input OutPut Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',23,'DiffSGST Value',16,1,0,2,3,'Differential of','SGST','Input OutPut Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',24,'DiffIGST Value',16,1,0,2,3,'Differential of','IGST','Input OutPut Tax Amount',2,GETDATE()
		UNION ALL
		SELECT 1,407,'Product Wise Input Output Tax',25,'DiffUTGST Value',16,1,0,2,3,'Differential of','UTGST','Input OutPut Tax Amount',2,GETDATE()
			
			UPDATE Report_template_GST SET FieldName=REPLACE(REPLACE(FieldName,']',''),'[','')
			WHERE RptId=@Pi_RptId 
			DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM RptInputOutPutGSTTax
			WHERE UsrId=@Pi_UsrId
			
			SELECT * FROM RptInputOutPutGSTTax WHERE UsrId=@Pi_UsrId
END
GO
DELETE FROM RptGroup WHERE PID='GSRT 410' and GrpCode='FORMGSTR1Exempt' and RptId=421
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSRT 410',421,'FORMGSTR1Exempt','FORM GSTR1-Exempt',1
GO
DELETE FROM RptHeader WHERE RptId=421
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'FORMGSTR1Exempt','FORM GSTR1-Exempt',421,'FORM GSTR1-Exempt','Proc_RptFORMGSTR1_Exempt','RptFORMGSTR1_Exempt','RptFORMGSTR1_Exempt.rpt',0
GO
DELETE FROM RptDetails where RPTID=421
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (421,1,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (421,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=421
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 421,208,1,'January' UNION
SELECT 421,208,2,'February' UNION
SELECT 421,208,3,'March' UNION
SELECT 421,208,4,'April' UNION
SELECT 421,208,5,'May' UNION
SELECT 421,208,6,'June' UNION
SELECT 421,208,7,'July' UNION
SELECT 421,208,8,'August' UNION
SELECT 421,208,9,'September' UNION
SELECT 421,208,10,'October' UNION
SELECT 421,208,11,'November' UNION
SELECT 421,208,12,'December' 
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=421
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,421,'FORM GSTR1-Exempt',1,'Description',50,1,0,1,1,'HSN','','',0,GETDATE()
UNION ALL
SELECT 1,421,'FORM GSTR1-Exempt',2,'NilRated',20,1,0,2,3,'Nil Rated Supplies','','',2,GETDATE()
UNION ALL
SELECT 1,421,'FORM GSTR1-Exempt',3,'Exempted',20,1,0,2,3,'Exempted ','Other than nil Rated','/Non GST Supply',2,GETDATE()
UNION ALL
SELECT 1,421,'FORM GSTR1-Exempt',4,'NonGST',30,1,0,2,3,'Non GST','Supplies','',2,GETDATE()
GO
IF Exists(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='U' and name='RptFORMGSTR1_Exempt')
DROP TABLE RptFORMGSTR1_Exempt
GO
CREATE TABLE RptFORMGSTR1_Exempt
(
slno Int IDENTITY(1,1),
[Description] Varchar(200),
[NilRated]	Numeric(32,2),
[Exempted] Numeric(32,2),
NonGST	Numeric(32,2),
UsrId INT,
[Group Name] Varchar(100),
GroupType TINYINT
)
GO
IF EXISTS(SELECT 'x' FROM SYSOBJECTS WHERE XTYPE='P' and name='Proc_RptFORMGSTR1_Exempt')
DROP PROCEDURE Proc_RptFORMGSTR1_Exempt
GO
--EXEC Proc_RptFORMGSTR1_Exempt 421,1,0,'',0,0,0
--SELECT * FROM RptFORMGSTR_3B_1
CREATE PROCEDURE Proc_RptFORMGSTR1_Exempt
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
/*********************************
* PROCEDURE		: Proc_RptFORMGSTR1_Exempt
* PURPOSE		: To Generate a report GSTR1  Exempt and Nil Rated Products
* CREATED		: Murugan.R
* CREATED DATE	: 13/04/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON

		DECLARE @ErrNo	 			AS INT


---Find Zero Tax Product
		DECLARE @PrdBatTaxGrp AS INT
		DECLARE @RtrTaxGrp1 AS INT
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT 
		DECLARE @MaxSlno   INT
		DECLARE @MinSlno   INT
		DECLARE @Prdid INT
		SET @MinSlno=1
		
		
		DECLARE @CmpId AS INT
		DECLARE @MonthStart INT
		DECLARE @JcmJc AS INT
		DECLARE @Jcmyear AS INT
		DECLARE @JcmFromId AS INT
		SET @JcmJc = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId)) 
		SET @MonthStart = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,208,@Pi_UsrId))
		SET @CmpId= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		
		SELECT @Jcmyear=JcmYr FROM JCMast MA WHERE MA.JcmId=@JcmJc
		
		--SET @MonthStart=7
		--SET @Jcmyear=2017
		TRUNCATE TABLE RptFORMGSTR1_Exempt

		CREATE TABLE #ProductLst
		(
			Slno INT IDENTITY(1,1),	
			TaxSeqId INT,	
			Prdid INT,
			RtrId INT
		)	
		
		CREATE TABLE #ProductZeroTax(
		TaxGroupId [int] NULL,
		[TaxPercentage] [numeric](18, 5) NULL
		) 
		
			
		
		DECLARE @TaxSettingDet TABLE       
		(      
		TaxSlab   INT,      
		ColNo   INT,      
		SlNo   INT,      
		BillSeqId  INT,      
		TaxSeqId  INT,      
		ColType   INT,       
		ColId   INT,      
		ColVal   NUMERIC(38,2)      
		) 
		CREATE TABLE #TempProductTax
		(
			Prdid INT,
			TaxId INT,
			TaxSlabId INT,
			TaxPercentage Numeric(5,2),
			TaxAmount Numeric (18,5)
		)
	   
		SELECT @RtrTaxGrp=TaxGroupId FROM TaxGroupSetting (NOLOCK) WHERE RtrGroup='RTRINTRA'
	   
		SELECT * INTO #RtrGroup FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp 
		and CONVERT(DATETIME,CONVERT(VARCHAR(10),EffectiveFrom,121),121)<=CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)
		
		INSERT INTO #ProductLst (TaxSeqId,Prdid,RtrId)
		SELECT Max(A.TaxSeqId),A.Prdid,A.RtrId		
		FROM #RtrGroup A INNER JOIN TaxSettingMaster B ON A.RtrId=B.RtrId and A.Prdid=B.Prdid
		GROUP BY A.Prdid,A.RtrId

	    SELECT @MaxSlno=MAX(Slno) FROM #ProductLst
	    WHILE @MinSlno<=@MaxSlno
	    BEGIN
				
				DELETE FROM @TaxSettingDet	
				SELECT @PrdBatTaxGrp=Prdid, @RtrTaxGrp=RtrId FROM  #ProductLst WHERE Slno=@MinSlno
				--To Take the Batch TaxGroup Id      
								
				SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
				
						
				INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
				SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
				FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
				TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
				AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
				WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
				AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
				RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp
				and CONVERT(DATETIME,CONVERT(VARCHAR(10),EffectiveFrom,121),121)<=CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)
				)  
			
				SET @MRP=1
				TRUNCATE TABLE #TempProductTax
				DECLARE  CurTax CURSOR FOR      
					SELECT DISTINCT TaxSlab FROM @TaxSettingDet      
				OPEN CurTax        
				FETCH NEXT FROM CurTax INTO @TaxSlab      
				WHILE @@FETCH_STATUS = 0        
				BEGIN      
				SET @TaxableAmount = 0      
				--To Filter the Records Which Has Tax Percentage (>=0)      
				IF EXISTS (SELECT * FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId = 0 and ColVal >= 0)      
				BEGIN      
				--To Get the Tax Percentage for the selected slab      
				SELECT @TaxPer = ColVal FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId = 0      
				--To Get the TaxId for the selected slab      
				SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId > 0      
				SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP 
				--To Get the Parent Taxable Amount for the Tax Slab      
				SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM #TempProductTax A      
				INNER JOIN @TaxSettingDet B ON A.TaxId = B.ColVal and  
				B.ColType = 3 AND B.TaxSlab = @TaxSlab 
				If @ParTaxableAmount>0
				BEGIN
					Set @TaxableAmount=@ParTaxableAmount
				END 
				ELSE
				BEGIN
					Set @TaxableAmount = @TaxableAmount
				END    
				    
				INSERT INTO #TempProductTax (PrdId,TaxId,TaxSlabId,TaxPercentage,      
				TaxAmount)      
				SELECT @PrdBatTaxGrp,@TaxId,@TaxSlab,@TaxPer,      
				cast(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
				 
				  
				END      
				FETCH NEXT FROM CurTax INTO @TaxSlab      
				END        
				CLOSE CurTax        
				DEALLOCATE CurTax      
				SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
				FROM #TempProductTax WHERE Prdid=@PrdBatTaxGrp
									
				INSERT INTO #ProductZeroTax(TaxGroupId,TaxPercentage)
				SELECT @PrdBatTaxGrp,@TaxPercentage
				
				SET @MinSlno=@MinSlno+1	
	END	
	
	DELETE FROM #ProductZeroTax WHERE TaxPercentage>0
	
	SELECT DISTINCT B.PrdId INTO #ProductZeroTax1 
	FROM  #ProductZeroTax A INNER JOIN Product B ON A.TaxGroupId=B.TaxGroupId
	
	
	---EXEMPTED PRODUCT
	SELECT DISTINCT P.Prdid 
	INTO #ExemptProduct
	FROM UdcHD A (NOLOCK)
	INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
	INNER JOIN UdcDetails C (NOLOCK) ON C.MasterId=B.MasterId and C.MasterId=A.MasterId
	and C.UdcMasterId=B.UdcMasterId 
	INNER JOIN Product P (NOLOCK) ON P.PrdId=C.MasterRecordId
	WHERE A.MasterName='Product Master' and B.ColumnName='Exempt Product'
	and ColumnValue='Yes'
	

	DELETE A FROM #ProductZeroTax1 A INNER JOIN #ExemptProduct B ON A.Prdid=B.PrdId
	
	--Service Invoice UnRegistered Retailer
	SELECT DISTINCT RtrId
	INTO #RetailerUnRegister
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue IN('UnRegistered')
	
	SELECT DISTINCT RtrId
	INTO #RetailerRegister
	FROM UDCHD U 
	INNER JOIN UDCMASTER UD ON U.MasterId=UD.MasterId
	INNER JOIN UdcDetails UT ON UT.MasterId=UD.MasterId and UT.UdcMasterId=UD.UdcMasterId
	INNER JOIN Retailer R ON R.RtrId=UT.MasterRecordId
	WHERE U.MasterId=2 and ColumnName='Retailer Type' and ColumnValue IN('Registered')
	
	SELECT PurRcptId 
	INTO #PurchaseReceipt
	FROM PurchaseReceipt WHERE VatGst='VAT' and GoodsRcvdDate Between '2017-01-01' and '2017-06-30'
	and Status=1
	

	INSERT INTO RptFORMGSTR1_Exempt([Description],[NilRated],[Exempted],NonGST,UsrId,[Group Name],GroupType)
	SELECT 'Inter-State supplies to registered person', SUM([NilRated]) as [NilRated],SUM([Exempted]) as [Exempted],0.00 as NonGST
	,@Pi_UsrId,'',2
	FROM(
		SELECT 0 as [NilRated],SUM(TaxableAmount) as [Exempted] 
		FROM SalesInvoice S (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.Salid
		INNER JOIN #ExemptProduct E ON E.PrdId=SP.PrdId
		INNER JOIN #RetailerRegister RG ON RG.RtrId=S.RtrId
		INNER JOIN SalesInvoiceProductTax SS (NOLOCK) ON SS.SalId=SP.SalId and S.SalId=SS.SalId and SP.SlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE DlvSts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear
		AND TaxCode IN('OutPutIGST','IGST') and TaxAmount=0  and VatGsT='GST' and SS.TaxableAmount > 0
		UNION ALL
		SELECT SUM(TaxableAmount) as [NilRated],0  as [Exempted] 
		FROM SalesInvoice S (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.Salid
		INNER JOIN #RetailerRegister RG ON RG.RtrId=S.RtrId
		INNER JOIN #ProductZeroTax1 E ON E.PrdId=SP.PrdId
		INNER JOIN SalesInvoiceProductTax SS (NOLOCK) ON SS.SalId=SP.SalId and S.SalId=SS.SalId and SP.SlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE DlvSts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear
		and TaxAmount=0  and VatGsT='GST' and SS.TaxableAmount > 0
		AND TaxCode IN('OutPutIGST','IGST')
		UNION ALL
		SELECT 0 as [NilRated],SUM(SS.TaxableAmount) as [Exempted] 
		FROM IDTManagement S (NOLOCK)
		INNER JOIN IDTManagementProduct SP (NOLOCK) ON S.IDTMngRefNo=SP.IDTMngRefNo
		INNER JOIN #ExemptProduct E ON E.PrdId=SP.PrdId
		INNER JOIN IDTManagementProductTax SS (NOLOCK) ON SS.IDTMngRefNo=SP.IDTMngRefNo and S.IDTMngRefNo=SS.IDTMngRefNo and SP.PrdSlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear
		AND TaxCode IN('OutPutIGST','InputIGST','IDTInputIGST','IGST','IDTOutPutIGST') and TaxAmount=0 AND SS.TaxableAmount > 0
		UNION ALL
		SELECT SUM(SS.TaxableAmount) as [NilRated],0  as [Exempted] 
		FROM IDTManagement S (NOLOCK)
		INNER JOIN IDTManagementProduct SP (NOLOCK) ON S.IDTMngRefNo=SP.IDTMngRefNo
		INNER JOIN #ProductZeroTax1 E ON E.PrdId=SP.PrdId
		INNER JOIN IDTManagementProductTax SS (NOLOCK) ON SS.IDTMngRefNo=SP.IDTMngRefNo and S.IDTMngRefNo=SS.IDTMngRefNo and SP.PrdSlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear
		and TaxAmount=0 AND SS.TaxableAmount > 0
		AND TaxCode IN('OutPutIGST','InputIGST','IDTInputIGST','IGST','IDTOutPutIGST') 
		UNION ALL
		SELECT 0 as [NilRated],SUM(SS.TaxableAmount) as [Exempted] 
		FROM PurchaseReturn S (NOLOCK)
		INNER JOIN PurchaseReturnProduct SP (NOLOCK) ON S.PurRetId=SP.PurRetId
		INNER JOIN #ExemptProduct E ON E.PrdId=SP.PrdId
		INNER JOIN PurchaseReturnProductTax SS (NOLOCK) ON SS.PurRetId=SP.PurRetId and S.PurRetId=SS.PurRetId and SP.PrdSlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear 
		AND TaxCode IN('InputIGST','IGST') and SS.TaxAmount=0 AND SS.TaxableAmount > 0
		UNION ALL
		SELECT SUM(SS.TaxableAmount) as [NilRated],0  as [Exempted] 
		FROM PurchaseReturn S (NOLOCK)
		INNER JOIN PurchaseReturnProduct SP (NOLOCK) ON S.PurRetId=SP.PurRetId
		INNER JOIN #ProductZeroTax1 E ON E.PrdId=SP.PrdId
		INNER JOIN PurchaseReturnProductTax SS (NOLOCK) ON SS.PurRetId=SP.PurRetId and S.PurRetId=SS.PurRetId and SP.PrdSlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
		and SS.TaxAmount=0 AND SS.TaxableAmount > 0
		AND TaxCode IN('InputIGST','IGST')
		
	)X
	INSERT INTO RptFORMGSTR1_Exempt([Description],[NilRated],[Exempted],NonGST,UsrId,[Group Name],GroupType)
	SELECT 'Intra-State supplies to registered person', SUM([NilRated]) as [NilRated],SUM([Exempted]) as [Exempted],0.00 as NonGST
	,@Pi_UsrId,'',2
	FROM(
		SELECT 0 as [NilRated],SUM(TaxableAmount) as [Exempted] 
		FROM SalesInvoice S (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.Salid
		INNER JOIN #ExemptProduct E ON E.PrdId=SP.PrdId
		INNER JOIN #RetailerRegister RG ON RG.RtrId=S.RtrId
		INNER JOIN SalesInvoiceProductTax SS (NOLOCK) ON SS.SalId=SP.SalId and S.SalId=SS.SalId and SP.SlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE DlvSts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear
		AND TaxCode IN('OutPutCGST','CGST') and TaxAmount=0  and VatGsT='GST' and SS.TaxableAmount > 0
		UNION ALL
		SELECT SUM(TaxableAmount) as [NilRated],0  as [Exempted] 
		FROM SalesInvoice S (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.Salid
		INNER JOIN #RetailerRegister RG ON RG.RtrId=S.RtrId
		INNER JOIN #ProductZeroTax1 E ON E.PrdId=SP.PrdId
		INNER JOIN SalesInvoiceProductTax SS (NOLOCK) ON SS.SalId=SP.SalId and S.SalId=SS.SalId and SP.SlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE DlvSts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear 
		and TaxAmount=0  and VatGsT='GST' and SS.TaxableAmount > 0
		AND TaxCode IN('OutPutCGST','CGST')
		UNION ALL
		SELECT 0 as [NilRated],SUM(SS.TaxableAmount) as [Exempted] 
		FROM IDTManagement S (NOLOCK)
		INNER JOIN IDTManagementProduct SP (NOLOCK) ON S.IDTMngRefNo=SP.IDTMngRefNo
		INNER JOIN #ExemptProduct E ON E.PrdId=SP.PrdId
		INNER JOIN IDTManagementProductTax SS (NOLOCK) ON SS.IDTMngRefNo=SP.IDTMngRefNo and S.IDTMngRefNo=SS.IDTMngRefNo and SP.PrdSlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear
		AND TaxCode IN('OutPutCGST','InputCGST','IDTInputCGST','CGST','IDTOutPutCGST') and TaxAmount=0 AND SS.TaxableAmount > 0
		UNION ALL
		SELECT SUM(SS.TaxableAmount) as [NilRated],0  as [Exempted] 
		FROM IDTManagement S (NOLOCK)
		INNER JOIN IDTManagementProduct SP (NOLOCK) ON S.IDTMngRefNo=SP.IDTMngRefNo
		INNER JOIN #ProductZeroTax1 E ON E.PrdId=SP.PrdId
		INNER JOIN IDTManagementProductTax SS (NOLOCK) ON SS.IDTMngRefNo=SP.IDTMngRefNo and S.IDTMngRefNo=SS.IDTMngRefNo and SP.PrdSlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE Status=1 and Month(IDTMngDate)=@MonthStart and Year(IDTMngDate)=@Jcmyear
		and TaxAmount=0 AND SS.TaxableAmount > 0
		AND TaxCode IN('OutPutCGST','InputCGST','IDTInputCGST','CGST','IDTOutPutCGST')
		UNION ALL
		SELECT 0 as [NilRated],SUM(SS.TaxableAmount) as [Exempted] 
		FROM PurchaseReturn S (NOLOCK)
		INNER JOIN PurchaseReturnProduct SP (NOLOCK) ON S.PurRetId=SP.PurRetId
		INNER JOIN #ExemptProduct E ON E.PrdId=SP.PrdId
		INNER JOIN PurchaseReturnProductTax SS (NOLOCK) ON SS.PurRetId=SP.PurRetId and S.PurRetId=SS.PurRetId and SP.PrdSlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
		AND TaxCode IN('InputCGST','CGST') and SS.TaxAmount=0 AND SS.TaxableAmount > 0
		UNION ALL
		SELECT SUM(SS.TaxableAmount) as [NilRated],0  as [Exempted] 
		FROM PurchaseReturn S (NOLOCK)
		INNER JOIN PurchaseReturnProduct SP (NOLOCK) ON S.PurRetId=SP.PurRetId
		INNER JOIN #ProductZeroTax1 E ON E.PrdId=SP.PrdId
		INNER JOIN PurchaseReturnProductTax SS (NOLOCK) ON SS.PurRetId=SP.PurRetId and S.PurRetId=SS.PurRetId and SP.PrdSlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE Status=1 and Month(PurRetDate)=@MonthStart and Year(PurRetDate)=@Jcmyear
		and SS.TaxAmount=0 AND SS.TaxableAmount > 0
		AND TaxCode IN('InputCGST','CGST')
	)X
	
	INSERT INTO RptFORMGSTR1_Exempt([Description],[NilRated],[Exempted],NonGST,UsrId,[Group Name],GroupType)
	SELECT 'Inter-State supplies to Unregistered person', SUM([NilRated]) as [NilRated],SUM([Exempted]) as [Exempted],0.00 as NonGST
	,@Pi_UsrId,'',2
	FROM(
		SELECT 0 as [NilRated],SUM(TaxableAmount) as [Exempted] 
		FROM SalesInvoice S (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.Salid
		INNER JOIN #ExemptProduct E ON E.PrdId=SP.PrdId
		INNER JOIN #RetailerUnRegister RG ON RG.RtrId=S.RtrId
		INNER JOIN SalesInvoiceProductTax SS (NOLOCK) ON SS.SalId=SP.SalId and S.SalId=SS.SalId and SP.SlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE DlvSts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear
		AND TaxCode IN('OutPutIGST','IGST') and TaxAmount=0  and VatGsT='GST' AND SS.TaxableAmount > 0
		UNION ALL
		SELECT SUM(TaxableAmount) as [NilRated],0  as [Exempted] 
		FROM SalesInvoice S (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.Salid
		INNER JOIN #RetailerUnRegister RG ON RG.RtrId=S.RtrId
		INNER JOIN #ProductZeroTax1 E ON E.PrdId=SP.PrdId
		INNER JOIN SalesInvoiceProductTax SS (NOLOCK) ON SS.SalId=SP.SalId and S.SalId=SS.SalId and SP.SlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid 
		WHERE DlvSts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear
		and TaxAmount=0  and VatGsT='GST' AND SS.TaxableAmount > 0
		AND TaxCode IN('OutPutIGST','IGST')
		
	)X
	
	INSERT INTO RptFORMGSTR1_Exempt([Description],[NilRated],[Exempted],NonGST,UsrId,[Group Name],GroupType)
	SELECT 'Intra-State supplies to Unregistered person', SUM([NilRated]) as [NilRated],SUM([Exempted]) as [Exempted],0.00 as NonGST
	,@Pi_UsrId,'',2
	FROM(
		SELECT 0 as [NilRated],SUM(TaxableAmount) as [Exempted] 
		FROM SalesInvoice S (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.Salid
		INNER JOIN #ExemptProduct E ON E.PrdId=SP.PrdId
		INNER JOIN #RetailerUnRegister RG ON RG.RtrId=S.RtrId
		INNER JOIN SalesInvoiceProductTax SS (NOLOCK) ON SS.SalId=SP.SalId and S.SalId=SS.SalId and SP.SlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE DlvSts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear
		AND TaxCode IN('OutPutCGST','CGST') and TaxAmount=0  and VatGsT='GST' AND SS.TaxableAmount > 0
		UNION ALL
		SELECT SUM(TaxableAmount) as [NilRated],0  as [Exempted] 
		FROM SalesInvoice S (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.Salid
		INNER JOIN #RetailerUnRegister RG ON RG.RtrId=S.RtrId
		INNER JOIN #ProductZeroTax1 E ON E.PrdId=SP.PrdId
		INNER JOIN SalesInvoiceProductTax SS (NOLOCK) ON SS.SalId=SP.SalId and S.SalId=SS.SalId and SP.SlNo=SS.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.Taxid=SS.Taxid
		WHERE DlvSts>3 and Month(SalInvdate)=@MonthStart and Year(Salinvdate)=@Jcmyear
		and TaxAmount=0  and VatGsT='GST' AND SS.TaxableAmount > 0
		AND TaxCode IN('OutPutCGST','CGST')
		
	)X
	
	IF NOT EXISTS(SELECT 'X' FROM RptFORMGSTR1_Exempt WHERE UsrId=@Pi_UsrId)
	BEGIN
		SELECT * FROM RptFORMGSTR1_Exempt WHERE UsrId=@Pi_UsrId
		RETURN
	END
	
	INSERT INTO RptFORMGSTR1_Exempt([Description],[NilRated],[Exempted],NonGST,UsrId,[Group Name],GroupType)
	SELECT '' as [Description],SUM([NilRated]) as [NilRated],SUM([Exempted]) as [Exempted],0,@Pi_UsrId,'ZZZZZ',3
	FROM RptFORMGSTR1_Exempt WHERE UsrId=@Pi_UsrId
	
	SELECT * FROM RptFORMGSTR1_Exempt WHERE UsrId=@Pi_UsrId


END
GO
--GSTR TILLHERE
--Bill Of Supply
DELETE FROM ManualConfiguration WHERE ProjectName='GST' and ModuleId='BILLOFSUPPLY'
INSERT INTO ManualConfiguration(ProjectName,ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'GST','BILLOFSUPPLY','BILLING','Enable bill of supply',1,'',0,1
GO
DELETE FROM ManualConfiguration WHERE ProjectName='GST' and ModuleId='BILLOFSUPPLY1'
INSERT INTO ManualConfiguration(ProjectName,ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'GST','BILLOFSUPPLY1','BILLING','Include Zero Tax Product',1,'',0,1
GO
DELETE FROM ManualConfiguration WHERE ProjectName='GST' and ModuleId='BILLOFSUPPLY2'
INSERT INTO ManualConfiguration(ProjectName,ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'GST','BILLOFSUPPLY2','BILLING','Enable bill of supply Counters',1,'',0,1
GO
IF NOT EXISTS(SELECT 'x' FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.id  and S.name='SalesInvoice' and SS.Name='SalBillOfSupply' and S.xtype='U')
BEGIN
	ALTER TABLE SalesInvoice ADD SalBillOfSupply TINYINT DEFAULT (0) WITH VALUES
END
GO
IF NOT EXISTS(sELECT * FROM SYSCOLUMNS WHERE NAME='SalBOSCounterFlag' AND ID IN (sELECT ID FROM SYSOBJECTS WHERE NAME='SALESINVOICE' AND XTYPE='U'))
BEGIN
	ALTER TABLE SALESINVOICE ADD SalBOSCounterFlag TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(sELECT * FROM SYSCOLUMNS WHERE NAME='GstUpload4' AND ID IN (sELECT ID FROM SYSOBJECTS WHERE NAME='SALESINVOICE' AND XTYPE='U'))
BEGIN
	ALTER TABLE SALESINVOICE ADD GstUpload4 TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(sELECT * FROM SYSCOLUMNS WHERE NAME='GstUpload5' AND ID IN (sELECT ID FROM SYSOBJECTS WHERE NAME='SALESINVOICE' AND XTYPE='U'))
BEGIN
	ALTER TABLE SALESINVOICE ADD GstUpload5 TINYINT DEFAULT 0 WITH VALUES
END
GO
UPDATE SalesInvoice SET SalBillOfSupply =1 WHERE SalTaxAmount=0 and VatGst='GST'
GO
IF NOT EXISTS(SELECT * FROM Counters WHERE TabName='BillOfSupply' and FldName='Salid')
BEGIN
	INSERT INTO Counters(TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,
	Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT 'BillOfSupply','Salid','BOS',5,1,0,'Billing',1,2017,1,1,GETDATE(),1,GETDATE()
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='ProductTaxBillOfSupply')
BEGIN
CREATE TABLE [ProductTaxBillOfSupply](
	[PrdId] [int] NULL,
	[TaxPercentage] [numeric](18, 5) NULL
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' and NAME='Proc_FindZeroTaxProduct')
DROP PROCEDURE Proc_FindZeroTaxProduct
GO
CREATE PROCEDURE [Proc_FindZeroTaxProduct]
(
	@GserverDate DATETIME
)
AS
BEGIN

		DECLARE @PrdBatTaxGrp AS INT
		DECLARE @RtrTaxGrp1 AS INT
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT 
		DECLARE @MaxSlno   INT
		DECLARE @MinSlno   INT
		DECLARE @Prdid INT
		SET @MinSlno=1
		
		
		
		CREATE TABLE #ProductLst
		(
			Slno INT IDENTITY(1,1),	
			TaxSeqId INT,	
			Prdid INT,
			RtrId INT
		)	
		
		CREATE TABLE #ProductZeroTax(
		TaxGroupId [int] NULL,
		[TaxPercentage] [numeric](18, 5) NULL
		) 
		
			
		
		DECLARE @TaxSettingDet TABLE       
		(      
		TaxSlab   INT,      
		ColNo   INT,      
		SlNo   INT,      
		BillSeqId  INT,      
		TaxSeqId  INT,      
		ColType   INT,       
		ColId   INT,      
		ColVal   NUMERIC(38,2)      
		) 
		CREATE TABLE #TempProductTax
		(
			Prdid INT,
			TaxId INT,
			TaxSlabId INT,
			TaxPercentage Numeric(5,2),
			TaxAmount Numeric (18,5)
		)
	   
		SELECT @RtrTaxGrp=TaxGroupId FROM TaxGroupSetting (NOLOCK) WHERE RtrGroup='RTRINTRA'
	   
		SELECT * INTO #RtrGroup FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp 
		and CONVERT(DATETIME,CONVERT(VARCHAR(10),EffectiveFrom,121),121)<=CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)
		
		INSERT INTO #ProductLst (TaxSeqId,Prdid,RtrId)
		SELECT Max(A.TaxSeqId),A.Prdid,A.RtrId		
		FROM #RtrGroup A INNER JOIN TaxSettingMaster B ON A.RtrId=B.RtrId and A.Prdid=B.Prdid
		GROUP BY A.Prdid,A.RtrId

	    SELECT @MaxSlno=MAX(Slno) FROM #ProductLst
	    WHILE @MinSlno<=@MaxSlno
	    BEGIN
				
				DELETE FROM @TaxSettingDet	
				SELECT @PrdBatTaxGrp=Prdid, @RtrTaxGrp=RtrId FROM  #ProductLst WHERE Slno=@MinSlno
				--To Take the Batch TaxGroup Id      
								
				SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
				
						
				INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
				SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
				FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
				TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
				AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
				WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
				AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
				RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp
				and CONVERT(DATETIME,CONVERT(VARCHAR(10),EffectiveFrom,121),121)<=CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121)
				)  
			
				SET @MRP=1
				TRUNCATE TABLE #TempProductTax
				DECLARE  CurTax CURSOR FOR      
					SELECT DISTINCT TaxSlab FROM @TaxSettingDet      
				OPEN CurTax        
				FETCH NEXT FROM CurTax INTO @TaxSlab      
				WHILE @@FETCH_STATUS = 0        
				BEGIN      
				SET @TaxableAmount = 0      
				--To Filter the Records Which Has Tax Percentage (>=0)      
				IF EXISTS (SELECT * FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId = 0 and ColVal >= 0)      
				BEGIN      
				--To Get the Tax Percentage for the selected slab      
				SELECT @TaxPer = ColVal FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId = 0      
				--To Get the TaxId for the selected slab      
				SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
				AND ColId > 0      
				SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP 
				--To Get the Parent Taxable Amount for the Tax Slab      
				SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM #TempProductTax A      
				INNER JOIN @TaxSettingDet B ON A.TaxId = B.ColVal and  
				B.ColType = 3 AND B.TaxSlab = @TaxSlab 
				If @ParTaxableAmount>0
				BEGIN
					Set @TaxableAmount=@ParTaxableAmount
				END 
				ELSE
				BEGIN
					Set @TaxableAmount = @TaxableAmount
				END    
				    
				INSERT INTO #TempProductTax (PrdId,TaxId,TaxSlabId,TaxPercentage,      
				TaxAmount)      
				SELECT @PrdBatTaxGrp,@TaxId,@TaxSlab,@TaxPer,      
				cast(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
				 
				  
				END      
				FETCH NEXT FROM CurTax INTO @TaxSlab      
				END        
				CLOSE CurTax        
				DEALLOCATE CurTax      
				SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
				FROM #TempProductTax WHERE Prdid=@PrdBatTaxGrp
									
				INSERT INTO #ProductZeroTax(TaxGroupId,TaxPercentage)
				SELECT @PrdBatTaxGrp,@TaxPercentage
				
				SET @MinSlno=@MinSlno+1	
	END	
	
	DELETE FROM #ProductZeroTax WHERE TaxPercentage>0
	DELETE FROM ProductTaxBillOfSupply
	INSERT INTO ProductTaxBillOfSupply(Prdid,TaxPercentage)
	SELECT DISTINCT B.PrdId ,TaxPercentage
	FROM  #ProductZeroTax A INNER JOIN Product B ON A.TaxGroupId=B.TaxGroupId
	
END
GO
IF EXISTS(SELECT 'X' FROM SYSOBJECTS WHERE XTYPE='FN' AND name='Fn_ZeroTaxProduct')
DROP FUNCTION Fn_ZeroTaxProduct
GO
--SELECT DBO.Fn_ZeroTaxProduct(1)
CREATE FUNCTION [Fn_ZeroTaxProduct] (@iBillOfSupply as INT)
RETURNS VARCHAR(7000)
AS
/*********************************
* FUNCTION: Fn_ZeroTaxProduct
* PURPOSE: Return Zero Tax Product
* NOTES:
* CREATED: Murugan.R 18/07/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*
*********************************/
BEGIN
	DECLARE @SSQL VARCHAR(7000)
	DECLARE @IncludeZeroTaxProduct as INT
	
	SET @IncludeZeroTaxProduct=0
	
	IF EXISTS(SELECT * FROM ManualConfiguration WHERE ProjectName='GST' and ModuleId='BILLOFSUPPLY1' and Status=1)
	BEGIN
		SET @IncludeZeroTaxProduct=1
	END
	
	DECLARE @TableExempted TABLE
	(
		Prdid INT
	)
	
	DECLARE @TableExemptedproduct TABLE
	(
		Prdid INT
	)
	
	INSERT INTO @TableExempted(Prdid)	
	SELECT P.Prdid FROM UdcHD A (NOLOCK)
	INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
	INNER JOIN UdcDetails C (NOLOCK) ON C.MasterId=B.MasterId and C.MasterId=A.MasterId
	and C.UdcMasterId=B.UdcMasterId 
	INNER JOIN Product P (NOLOCK) ON P.PrdId=C.MasterRecordId
	WHERE A.MasterName='Product Master' and B.ColumnName='Exempt Product'
	and ColumnValue='Yes'
	
	INSERT INTO @TableExemptedproduct(Prdid)
	SELECT Prdid FROM @TableExempted
	UNION
	SELECT Prdid FROM ProductTaxBillOfSupply

	
	SET @sSql=''
	IF EXISTS(SELECT 'X' FROM ProductTaxBillOfSupply (NOLOCK))
	BEGIN
		IF @iBillOfSupply=2 and @IncludeZeroTaxProduct=0
		BEGIN
			SELECT @sSql=@sSql+'Prdid='+Cast(Prdid as Varchar(15)) +' OR ' from @TableExemptedproduct 
			SET @sSql=SUBSTRING(@sSql,1,LEN(@sSql)-2)
		END
		ELSE IF @iBillOfSupply=1 
		BEGIN
			SELECT @sSql=@sSql+'Prdid<>'+Cast(Prdid as Varchar(15)) +' AND ' from @TableExemptedproduct
			SET @sSql=SUBSTRING(@sSql,1,LEN(@sSql)-3)
		END
	END
	RETURN (@sSql)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='FN_BillOfsupplyValidate' AND XTYPE='TF')
DROP FUNCTION FN_BillOfsupplyValidate
GO
--SELECT DBO.FN_ReturnDistributorType()
CREATE FUNCTION FN_BillOfsupplyValidate(@Salid AS BIGINT)
RETURNS @RtnBillOfSupply TABLE
(
	iError TINYINT,
	sErrorMessgage Varchar(300)
)
AS
/*********************************
* FUNCTION: FN_BillOfsupplyValidate
* PURPOSE: Tax Validation For bill of supply
* NOTES:
* CREATED: Murugan.R 18/07/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*
*********************************/
BEGIN
 IF EXISTS(SELECT 'X' FROM SalesInvoice (NOLOCK) WHERE SalId=@Salid and InvType=1 and SalBOSCounterFlag=0)
 BEGIN
	INSERT INTO @RtnBillOfSupply(iError,sErrorMessgage)
	SELECT 1,'Zero tax product not allow to save for tax Invoice'
 END
 ELSE
 BEGIN
	INSERT INTO @RtnBillOfSupply(iError,sErrorMessgage)
	SELECT 0,''
 END
 RETURN
END
GO
--BOP Till
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='FN_ReturnSupplierUDCDetails' AND XTYPE='TF')
DROP FUNCTION FN_ReturnSupplierUDCDetails
GO
CREATE FUNCTION FN_ReturnSupplierUDCDetails()
RETURNS @SupplierUDC TABLE
(
	SpmId			INT,
	SpmName			NVARCHAR(200),
	SpmCode			NVARCHAR(100),
	StateName		NVARCHAR(200),
	StateCode		VARCHAR(40),
	StateTinFirst2Digit NVARCHAR(20),
	GSTIN			NVARCHAR(50)	
	
)

AS
BEGIN
	INSERT INTO @SupplierUDC	
	SELECT SpmId,SpmName,SpmCode,A.StateName,ISNULL(S.StateCode,''),ISNULL(S.TinFirst2Digit,''),GSTIN
	FROM
	(
	SELECT SpmId,SpmName,SpmCode,
	CASE ISNULL(A.ColumnValue,'') WHEN '' THEN '' ELSE A.ColumnValue END StateName,		
	CASE ISNULL(B.ColumnValue,'') WHEN '' THEN '' ELSE CASE WHEN LEN(B.ColumnValue)<10 THEN '' ELSE B.ColumnValue END END GSTIN
	FROM Supplier R 
	LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
				AND U.MasterId=8 AND UPPER(ColumnName)='STATE NAME')A ON A.MasterRecordId=R.SpmId
	LEFT OUTER JOIN (SELECT MASTERRECORDID,ColumnValue FROM UDCDETAILS UD INNER JOIN UdcMaster U ON U.MasterId=UD.MasterId AND U.UdcMasterId=UD.UdcMasterId 
				AND U.MasterId=8 AND UPPER(ColumnName)='GSTIN')B ON B.MasterRecordId=R.SpmId

	)A
	LEFT OUTER JOIN StateMaster S ON S.StateName=A.StateName				
RETURN
END
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE NAME='RptHSNOutputTaxGST' AND XTYPE='U')
DROP TABLE RptHSNOutputTaxGST
GO
CREATE TABLE RptHSNOutputTaxGST
(
SLNO BIGINT IDENTITY(1,1),
StateCode Varchar(20),
StateName Varchar(100),
GSTin Varchar(50),
RetailerType Varchar(25),
RtrCode Varchar(50),
Rtrname Varchar(100),	
HsnCode Varchar(50),
Refid BIGINT,
RefNo Varchar(50),
RefDate DateTime,
RtrId INT,
TaxableAmount Numeric(18,4),
NetAmount numeric(24,2),
Taxname Varchar(100),
DynamicAmt Numeric(24,4),
TaxType Varchar(50),
TaxFlag TinyInt	,
Taxper Numeric(10,2),
TaxId INT,
[Group Name] varchar(50),
[GroupType] Tinyint,
[UsrId] INT
)
GO
DELETE FROM RptGroup WHERE RptId=422
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSTTaxReports 400',422,'HSNOutPutTax','HSN Code wise output tax',1
GO
DELETE FROM RptHeader WHERE RptId=422
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'HSNOutPutTax','HSN Code wise output tax',422,'HSN Code wise output tax','Proc_RptHSNOutPutTaxGST','RptHSNOutputTaxGST','RptHSNOutputTaxGST.rpt',0
GO
DELETE FROM RptDetails WHERE RptId=422
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (422,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (422,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (422,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to select Company',0)
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=422
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,422,'HSN Code Wise Output Tax',1,'StateCode',20,1,0,1,1,'Retailer','State','Code',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',2,'StateName',50,1,0,1,1,'Retailer','State','Name',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',3,'GSTin',20,1,0,1,1,'Retailer','GST Tin','',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',4,'RetailerType',20,1,0,1,1,'Retailer','Type','',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',5,'RtrCode',50,1,0,1,1,'Retailer','Code','',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',6,'Rtrname',50,1,0,1,1,'Retailer','Name','',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',7,'RefNo',75,1,0,1,1,'Invoice','Number','',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',8,'RefDate',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',9,'HSNCode',75,1,0,1,1,'HSN Code','','',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',10,'TaxType',75,1,0,1,1,'Sales/','Return','',0,GETDATE()
UNION ALL
SELECT 1,422,'HSN Code Wise Output Tax',11,'TaxableAmount',75,1,0,2,3,'Total','Taxable','Value',2,GETDATE()
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE NAME='Proc_RptHSNOutPutTaxGST' AND XTYPE='P')
DROP PROCEDURE Proc_RptHSNOutPutTaxGST
GO
/*
BEGIN tran
EXEC Proc_RptHSNOutPutTaxGST 422,1,0,'GSTTAX',0,0,1
Select * from RptInputtaxCreditGST
ROLLBACK tran 
*/
CREATE PROCEDURE [Proc_RptHSNOutPutTaxGST]
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
* PROCEDURE	: Proc_RptHSNOutPutTax
* PURPOSE	: To get the HSN Wise Tax Report
* CREATED	: Murugan.R
* CREATED DATE	: 25/08/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON

	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId	        AS	INT
	DECLARE @ErrNo	 	AS	INT
		

	DECLARE @SQL as Varchar(MAX)
	DECLARE @MaxId as INT
	DECLARE @ReportId as INT
	DECLARE @start INT, @end INT 
	DECLARE @Str AS VARCHAR(100)
	DECLARE @CreateTable AS VARCHAR(7000)

		
	SET @ErrNo=0
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))

	--SET @FromDate='2017-05-01'
	--SET @ToDate='2017-07-30'
	--select * from ReportFilterDt
	
		TRUNCATE TABLE RptHSNOutputTaxGST
	
	
		DECLARE @DynamicLineAmountFields as VARCHAR(300)
		DECLARE @DynamicLineAmountFields1 as VARCHAR(300)
		DECLARE @DynamicLineAmountFields2 as VARCHAR(300)

		

		SELECT DISTINCT P.Prdid,ColumnValue as HSNCODE 
		INTO #HSNCODE
		FROM UdcHD A (NOLOCK)
		INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
		INNER JOIN UdcDetails C (NOLOCK) ON C.MasterId=B.MasterId and C.MasterId=A.MasterId
		and C.UdcMasterId=B.UdcMasterId 
		INNER JOIN Product P (NOLOCK) ON P.PrdId=C.MasterRecordId
		WHERE A.MasterName='Product Master' and B.ColumnName='HSN CODE'
	
		CREATE TABLE #TaxHSNSummary
		(
			StateCode Varchar(20),
			StateName Varchar(100),
			GSTin Varchar(50),
			RetailerType Varchar(25),
			RtrCode Varchar(50),
			Rtrname Varchar(100),	
			HsnCode Varchar(50),
			Refid BIGINT,
			RefNo Varchar(50),
			RefDate DateTime,
			RtrId INT,
			GrossAmount Numeric(18,4),
			TaxableAmount Numeric(32,4),
			NetAmount numeric(24,4),
			Taxname Varchar(100),
			DynamicAmt Numeric(24,4),
			TaxType Varchar(50),
			SalesOrderType TinyInt,
			TaxFlag TinyInt	,
			Taxper Numeric(10,2),
			TaxId INT,
			[Group Name] varchar(50),
			[GroupType] Tinyint,
			[UsrId] INT
		)

		SELECT Salid,Prdslno,SUM(TaxableAmount) as TaxableAmount
		INTO #SalesTaxableAmount
		FROM(
		SELECT S.Salid,PrdSlno,SUM(DISTINCT TaxableAmount) as TaxableAmount
		FROM SalesInvoiceProductTax  S  (NOLOCK) INNER JOIN SalesInvoice SI (NOLOCK) ON S.SalId=SI.Salid
		WHERE  TaxableAmount>0 and DlvSts>3
		AND SI.SalInvDate  Between @FromDate AND @ToDate and VatGST='GST'
		GROUP BY S.Salid,PrdSlno 
		)X GROUP BY Salid,Prdslno
		
		SELECT ReturnID,Prdslno,SUM(TaxableAmount) as TaxableAmount
		INTO #RetunrTaxableAmount
		FROM(
		SELECT S.ReturnID,PrdSlno,SUM(DISTINCT TaxableAmt) as TaxableAmount
		FROM ReturnProductTax  S  (NOLOCK) INNER JOIN ReturnHeader SI (NOLOCK) ON S.ReturnID=SI.ReturnID
		WHERE  TaxableAmt>0 AND SI.ReturnDate  Between @FromDate AND @ToDate and Status=0
		GROUP BY S.ReturnID,PrdSlno
		)X GROUP BY  ReturnID,Prdslno

		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,RetailerType,RtrCode,Rtrname,HsnCode ,Refid,RefNo,
		RefDate,RtrId,GrossAmount,TaxableAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])
		SELECT '' as StateCode,'' as StateName,'' as GSTin,'' as RetailerType,RtrCode,Rtrname,ISNULL(HSNCODE,''),
		S.Salid as RefId,SalinvNo as RefNo,Salinvdate as RefDate,R.RtrId,SUM(PrdGrossAmount) as PrdGrossAmount,
		SUM(ST.TaxableAmount),SUM(PrdNetAmount) as NetAmount,TaxCode +'~TaxableAmount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		SUM(SPT.TaxableAmount) as DynamicAmt,'Sales of Goods' as TaxType,1 as SalesOrderType,
		0 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON S.Salid=SIP.SalId
		INNER JOIN SalesInvoiceProductTax SPT (NOLOCK) ON SPT.SalId=SIP.SalId and SPT.SalId=S.SalId and SIP.SlNo=SPT.PrdSlNo
		INNER JOIN #SalesTaxableAmount ST ON ST.SalId=SPT.SalId  and S.Salid=St.Salid and ST.SalId=SIP.SalId and SIP.SlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Retailer R ON R.RtrId=S.RtrId
		LEFT OUTER JOIN #HSNCODE A ON SIP.PrdId=A.PrdId
		WHERE Salinvdate	Between @FromDate and @ToDate and VatGST='GST'
		and SPT.TaxableAmount>0 and DlvSts>3
		GROUP BY HSNCODE,S.Salid,Salinvdate,R.RtrId,TaxCode,TaxPerc,SalinvNo,SPT.TaxId,RtrCode,Rtrname
		UNION ALL
		SELECT  '' as StateCode,'' as StateName,'' as GSTin,'' as RetailerType,RtrCode,Rtrname,ISNULL(HSNCODE,''),
		S.Salid as RefId,SalinvNo as RefNo,Salinvdate as RefDate,R.RtrId,SUM(PrdGrossAmount) as PrdGrossAmount,
		SUM(ST.TaxableAmount),SUM(PrdNetAmount) as NetAmount,
		TaxCode +'~Taxamount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		SUM(TaxAmount) as DynamicAmt,'Sales of Goods' as TaxType,1 as SalesOrderType,
		1 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON S.Salid=SIP.SalId
		INNER JOIN SalesInvoiceProductTax SPT (NOLOCK) ON SPT.SalId=SIP.SalId and SPT.SalId=S.SalId and SIP.SlNo=SPT.PrdSlNo
		INNER JOIN #SalesTaxableAmount ST ON ST.SalId=SPT.SalId  and S.Salid=St.Salid and ST.SalId=SIP.SalId and SIP.SlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Retailer R ON R.RtrId=S.RtrId
		LEFT OUTER JOIN #HSNCODE A ON SIP.PrdId=A.PrdId
		WHERE Salinvdate	Between @FromDate and @ToDate and VatGST='GST'
		and SPT.TaxableAmount>0  and DlvSts>3
		GROUP BY HSNCODE,S.Salid,Salinvdate,R.RtrId,TaxCode,TaxPerc,SalInvNo,SPT.TaxId,RtrCode,Rtrname
		
		
		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,RetailerType,RtrCode,Rtrname,HsnCode ,Refid,RefNo,
		RefDate,RtrId,GrossAmount,TaxableAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])
		SELECT '' as StateCode,'' as StateName,'' as GSTin,'' as RetailerType,RtrCode,Rtrname,ISNULL(HSNCODE,''),
		S.ReturnID as RefId,ReturnCode as RefNo,ReturnDate as RefDate,R.RtrId,-1*SUM(PrdGrossAmt) as PrdGrossAmount,
		-1*SUM(TaxableAmount),-1*SUM(PrdNetAmt) as NetAmount,TaxCode +'~TaxableAmount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		-1*SUM(TaxableAmt) as DynamicAmt,'Return of Goods from Retailer' as TaxType,2 as SalesOrderType,
		0 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM ReturnHeader S (NOLOCK) 
		INNER JOIN ReturnProduct SIP (NOLOCK) ON S.ReturnID=SIP.ReturnID
		INNER JOIN ReturnProductTax SPT (NOLOCK) ON SPT.ReturnID=SIP.ReturnID and SPT.ReturnID=S.ReturnID and SIP.SlNo=SPT.PrdSlNo
		INNER JOIN #RetunrTaxableAmount ST ON ST.ReturnID=SPT.ReturnID  and S.ReturnID=St.ReturnID and ST.ReturnID=SIP.ReturnID and SIP.SlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Retailer R ON R.RtrId=S.RtrId
		LEFT OUTER JOIN #HSNCODE A ON SIP.PrdId=A.PrdId
		WHERE ReturnDate	Between @FromDate and @ToDate and Status=0
		and TaxableAmt>0
		GROUP BY HSNCODE,S.ReturnID,ReturnDate,R.RtrId,TaxCode,TaxPerc,ReturnCode,SPT.TaxId,RtrCode,Rtrname
		UNION ALL
		SELECT  '' as StateCode,'' as StateName,'' as GSTin,'' as RetailerType,RtrCode,Rtrname,ISNULL(HSNCODE,''),
		S.ReturnID as RefId,ReturnCode as RefNo,ReturnDate as RefDate,R.RtrId,-1*SUM(PrdGrossAmt) as PrdGrossAmount,
		-1*SUM(TaxableAmount),-1*SUM(PrdNetAmt) as NetAmount,
		TaxCode +'~Taxamount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		-1*SUM(TaxAmt) as DynamicAmt,'Return of Goods from Retailer' as TaxType,2 as SalesOrderType,
		1 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM ReturnHeader S (NOLOCK) 
		INNER JOIN ReturnProduct SIP (NOLOCK) ON S.ReturnID=SIP.ReturnID
		INNER JOIN ReturnProductTax SPT (NOLOCK) ON SPT.ReturnID=SIP.ReturnID and SPT.ReturnID=S.ReturnID and SIP.SlNo=SPT.PrdSlNo
		INNER JOIN #RetunrTaxableAmount ST ON ST.ReturnID=SPT.ReturnID  and S.ReturnID=St.ReturnID and ST.ReturnID=SIP.ReturnID and SIP.SlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Retailer R ON R.RtrId=S.RtrId
		LEFT OUTER JOIN #HSNCODE A ON SIP.PrdId=A.PrdId
		WHERE ReturnDate between  @FromDate and @ToDate and Status=0
		and TaxableAmt>0
		GROUP BY HSNCODE,S.ReturnID,ReturnDate,R.RtrId,TaxCode,TaxPerc,ReturnCode,SPT.TaxId,RtrCode,Rtrname


	
		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,RetailerType,RtrCode,Rtrname,HsnCode ,
		Refid,RefNo,RefDate,RtrId,GrossAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])		
		SELECT  '','','','','','','', 0 as [InvId],'' as [RefNo],Null,0,0 as GrossAmount,0 as NetAmount,
		Taxname,SUM(DynamicAmt) as DynamicAmt,'' as TaxType,3 as SalesOrderType,100 as taxFlag,
		Taxper,TaxId,'ZZZZZ' as [Group Name],3 as [GroupType],@Pi_UsrId as [UsrId]
		FROM #TaxHSNSummary 
		GROUP BY Taxname,Taxper,TaxId
	

		UPDATE B SET B.StateCode= A.StateTinFirst2Digit ,
		B.Statename=A.StateName,
		B.GSTIN=A.GSTIN,
		B.RetailerType=CASE A.RetailerType WHEN 1 THEN 'Registered'
		WHEN 2 THEN 'Unregistered' END
		FROM DBO.FN_ReturnRetailerUDCDetails() A INNER JOIN #TaxHSNSummary B ON A.Rtrid=B.RtrId


		SET @DynamicLineAmountFields='0 as NetAmount,'
		SET @DynamicLineAmountFields1='NetAmount Numeric (36,2),'
		SET @DynamicLineAmountFields2='NetAmount,'
		
		IF NOT EXISTS(SELECT 'X' FROM #TaxHSNSummary)
		BEGIN
			SELECT * FROM RptHSNOutputTaxGST WHERE UsrId=@Pi_UsrId
			RETURN
		END


		DECLARE @ColSelect AS Varchar(MAX)
		DECLARE @ColSelectDataType AS Varchar(5000)
		DECLARE @TableCol AS Varchar(2000)
		DECLARE @Columns1 AS Varchar(7000)
		DECLARE @OrderBy AS VARCHAR(2000)
		DECLARE @PCSelect AS VARCHAR(3000)
		SET @PCSelect=''
		SET @ColSelect=''
		SET @ColSelectDataType=''
		SET @TableCol=''
		SET @Columns1=''
		SET @CreateTable=''
		SET @OrderBy=''

		CREATE TABLE #DynamicCol
		(
		Slno INT IDENTITY(1,1),
		Taxname	Varchar(50),
		TaxId INT,
		TaxPer Numeric(12,2),
		TaxFlag TinyInt		
		)
		INSERT INTO #DynamicCol		
		SELECT DISTINCT Taxname,TaxId,Taxper,TaxFlag FROM #TaxHSNSummary WHERE TaxFlag IN(1,0) ORDER BY TaxId,Taxper,TaxFlag,Taxname
	

		SELECT @ColSelect=@ColSelect+'ISNULL('+QuoteName(Taxname)+',0) as '+QuoteName(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SELECT @PCSelect=@PCSelect+Quotename(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SET @PCSelect=LEFT(@PCSelect,LEN(@PCSelect)-1)
		SELECT @ColSelectDataType=@ColSelectDataType+QuoteName(Taxname)+' Numeric(36,2),' FROM #DynamicCol ORDER BY Slno
		SET @ColSelect='SELECT StateCode,StateName,GSTin,RetailerType,RtrId,RtrCode,Rtrname,Refid,RefNo,RefDate,HsnCode,TaxType,SalesOrderType,TaxableAmount,'+@ColSelect+@DynamicLineAmountFields2+'[Group Name],[GroupType],[UsrId]'
		SET @TableCol= 'SLNO BIGINT IDENTITY(1,1),'+
		'StateCode Varchar(20),
		StateName Varchar(100),
		GSTin Varchar(50),
		RetailerType Varchar(25),
		RtrId INT,
		RtrCode Varchar(50),
		Rtrname Varchar(100),		
		Refid BIGINT,
		RefNo Varchar(50),
		RefDate DateTime,
		HsnCode Varchar(50),	
		TaxType Varchar(50),	
		SalesOrderType TinyInt,
		TaxableAmount Numeric(34,4),'

		SET @Columns1='SELECT StateCode,StateName,GSTin,RetailerType,RtrId,RtrCode,Rtrname,Refid,RefNo,RefDate,HsnCode,TaxType,SalesOrderType,TaxableAmount,NetAmount,DynamicAmt ,TaxName,[Group Name],[GroupType],[UsrId] FROM #TaxHSNSummary'
		SET @OrderBy=' ORDER BY [Group Name],[GroupType],SalesOrderType,TaxType,Refdate,Refno'
		SET @CreateTable=' IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME=''RptHSNOutputTaxGST'' and XTYPE=''U'')'+
		' DROP TABLE RptHSNOutputTaxGST'+
		' CREATE TABLE RptHSNOutputTaxGST ('+@TableCol+@ColSelectDataType+@DynamicLineAmountFields1+' [Group Name] Varchar(100),Grouptype TINYINT,UsrId INT)'
		PRINT @CreateTable
		EXEC(@CreateTable)
		SET @SQL=' INSERT INTO RptHSNOutputTaxGST '+ @ColSelect+ ' FROM'+
		'('+@Columns1+
		') PS'+
		' PIVOT'+
		'('+
		' SUM(DynamicAmt) FOR TaxName IN('+@PCSelect+')'+
		')PVTTax '+ @OrderBy
		PRINT @SQL
		EXEC(@SQL)

		SELECT DISTINCT
		StateCode,StateName,GSTin,RetailerType,RtrId,RtrCode,Rtrname,Refid,RefNo,RefDate,HsnCode,TaxableAmount,NetAmount
		INTO #LineLevelGross
		FROM #TaxHSNSummary WHERE UsrId=@Pi_UsrId and TaxFlag=0

		SELECT 'ZZZZZ' as [Group Name], 3 as GroupType ,SUM(TaxableAmount) as TaxableAmount,SUM(NetAmount) as NetAmount
		INTO #GrandTotal
		FROM #LineLevelGross 
		UPDATE Y SET  
		Y.TaxableAmount=X.TaxableAmount ,Y.NetAmount=X.NetAmount
		FROM RptHSNOutputTaxGST Y INNER JOIN #GrandTotal X ON X.[Group Name]=Y.[Group Name]
		AND X.GroupType=Y.GroupType 
		
		
			DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=@Pi_RptId
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
			FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
			RoundOff,CreatedDate)
			SELECT 1,422,'HSN Code Wise Output Tax',1,'StateCode',20,1,0,1,1,'Retailer','State','Code',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',2,'StateName',50,1,0,1,1,'Retailer','State','Name',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',3,'GSTin',20,1,0,1,1,'Retailer','GST Tin','',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',4,'RetailerType',20,1,0,1,1,'Retailer','Type','',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',5,'RtrCode',50,1,0,1,1,'Retailer','Code','',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',6,'Rtrname',50,1,0,1,1,'Retailer','Name','',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',7,'RefNo',75,1,0,1,1,'Invoice','Number','',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',8,'RefDate',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',9,'HSNCode',75,1,0,1,1,'HSN Code','','',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',10,'TaxType',75,1,0,1,1,'Sales/','Return','',0,GETDATE()
			UNION ALL
			SELECT 1,422,'HSN Code Wise Output Tax',11,'TaxableAmount',75,1,0,2,3,'Total','Taxable','Value',2,GETDATE()
			SET @Str=''
			SELECT @MaxId=MAX(ColId)+1,@ReportId=ReportId FROM  Report_Template_GST (NOLOCK) WHERE RptId=@Pi_RptId
			GROUP BY ReportId
			
			DECLARE @Caption1 as Varchar(30)
			DECLARE @Caption2 as Varchar(30)
			DECLARE @Caption3 as Varchar(30)
			SET @Caption1=''
			SET @Caption2=''
			SET @Caption3=''
			
			SELECT @start = 1, @end = CHARINDEX(',', @PCSelect) 
			WHILE @start < LEN(@PCSelect) + 1 BEGIN 
				IF @end = 0  
				SET @end = LEN(@PCSelect) + 1
				SET @Str=SUBSTRING(@PCSelect, @start, @end - @start)
				--SELECT @Str,'T'
				SET @Caption1=LEFT(@Str,CharIndex('~',@Str)-1)
				SET @Caption2=LEFT(SUBSTRING(@Str,CharIndex('~',@Str)+1,LEN(@Str)),CHARINDEX('~',SUBSTRING(@Str,CharIndex('~',@Str)+1,LEN(@Str)))-1)
				SET @Caption3= REPLACE(RIGHT(@Str,6),'~','')

				--SELECT @Caption1,@Caption2,@Caption3
				
				INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
				FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
				CreatedDate)  
				SELECT TOP 1 ReportId,RptId,RptName,@MaxId,SUBSTRING(@PCSelect, @start, @end - @start),
				18,1,0,2,3,@Caption1--SUBSTRING(@PCSelect, @start, @end - @start)				
				,@Caption2,@Caption3,2,Getdate()
				FROM Report_Template_GST WHERE RptId=@Pi_RptId
				
				SET @start = @end + 1 
				SET @end = CHARINDEX(',', @PCSelect, @start)
				SET @MaxId=@MaxId+1
			END 
			
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
			FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
			CreatedDate)  
			SELECT TOP 1 ReportId,RptId,RptName,@MaxId+1,'NetAmount',
			18,1,0,2,3,'Product','Level','NetAmount',2,Getdate()
			FROM Report_Template_GST WHERE RptId=@Pi_RptId	
			
			
			UPDATE Report_template_GST SET FieldName=REPLACE(REPLACE(FieldName,']',''),'[',''),
			HeaderCaption=REPLACE(REPLACE(HeaderCaption,']',''),'[',''),
			HeaderCaption1=REPLACE(REPLACE(HeaderCaption1,']',''),'[',''),
			HeaderCaption2=REPLACE(REPLACE(HeaderCaption2,']',''),'[','')
			WHERE RptId=@Pi_RptId 
			
			
			IF NOT EXISTS(SELECT 'X' FROM RptHSNOutputTaxGST)
			BEGIN
				SELECT * FROM RptHSNOutputTaxGST WHERE UsrId=@Pi_UsrId
				RETURN
			END
			
			SELECT * FROM RptHSNOutputTaxGST WHERE UsrId=@Pi_UsrId
END
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE NAME='RptHSNInputTaxGST' AND XTYPE='U')
DROP TABLE RptHSNInputTaxGST
GO
CREATE TABLE RptHSNInputTaxGST
(
SLNO BIGINT IDENTITY(1,1),
StateCode Varchar(20),
StateName Varchar(100),
GSTin Varchar(50),
SpmCode Varchar(50),
Spmname Varchar(100),	
HsnCode Varchar(50),
Refid BIGINT,
RefNo Varchar(50),
CmpInvno Varchar(50),
PurchaseOrderNo Varchar(50),
InvoiceDate Datetime,
RefDate DateTime,
SpmId INT,
TaxableAmount Numeric(18,4),
NetAmount numeric(24,2),
Taxname Varchar(100),
DynamicAmt Numeric(24,4),
TaxType Varchar(50),
TaxFlag TinyInt	,
Taxper Numeric(10,2),
TaxId INT,
[Group Name] varchar(50),
[GroupType] Tinyint,
[UsrId] INT
)
GO
DELETE FROM RptGroup WHERE RptId=423
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSTTaxReports 400',423,'HSNInPutTax','HSN Code wise Input tax',1
GO
DELETE FROM RptHeader WHERE RptId=423
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'HSNInPutTax','HSN Code wise Input tax',423,'HSN Code wise Input tax','Proc_RptHSNInputTaxGST','RptHSNInputTaxGST','RptHSNInputTaxGST.rpt',0
GO
DELETE FROM RptDetails WHERE RptId=423
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (423,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (423,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails(RptId,[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (423,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to select Company',0)
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=423
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,423,'HSN Code Wise Input Tax',1,'StateCode',20,1,0,1,1,'Supplier','State','Code',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',2,'StateName',50,1,0,1,1,'Supplier','State','Name',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',3,'GSTin',20,1,0,1,1,'Supplier','GST Tin','',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',4,'RetailerType',20,1,0,1,1,'Retailer','Type','',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',5,'SpmCode',50,1,0,1,1,'Supplier','Code','',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',6,'Spmname',50,1,0,1,1,'Supplier','Name','',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',7,'RefNo',75,1,0,1,1,'Invoice','Number','',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',8,'RefDate',75,1,0,1,4,'Goods','Received','Date',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',9,'Invoice',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',10,'HSNCode',75,1,0,1,1,'HSN Code','','',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',11,'TaxType',75,1,0,1,1,'Sales/','Return','',0,GETDATE()
UNION ALL
SELECT 1,423,'HSN Code Wise Input Tax',12,'TaxableAmount',75,1,0,2,3,'Total','Taxable','Value',2,GETDATE()
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE NAME='Proc_RptHSNInputTaxGST' AND XTYPE='P')
DROP PROCEDURE Proc_RptHSNInputTaxGST
GO
/*
BEGIN tran
EXEC Proc_RptHSNInputTaxGST 423,1,0,'GSTTAX',0,0,1
Select * from RptInputtaxCreditGST
ROLLBACK tran 
*/
CREATE PROCEDURE [Proc_RptHSNInputTaxGST]
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
* PROCEDURE	: Proc_RptHSNOutPutTax
* PURPOSE	: To get the HSN Wise Tax Report
* CREATED	: Murugan.R
* CREATED DATE	: 25/08/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON

	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId	        AS	INT
	DECLARE @ErrNo	 	AS	INT
		

	DECLARE @SQL as Varchar(MAX)
	DECLARE @MaxId as INT
	DECLARE @ReportId as INT
	DECLARE @start INT, @end INT 
	DECLARE @Str AS VARCHAR(100)
	DECLARE @CreateTable AS VARCHAR(7000)

		
	SET @ErrNo=0
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))

	--SET @FromDate='2017-05-01'
	--SET @ToDate='2017-07-30'
	--select * from ReportFilterDt
	
		TRUNCATE TABLE RptHSNInputTaxGST
	
	
		DECLARE @DynamicLineAmountFields as VARCHAR(300)
		DECLARE @DynamicLineAmountFields1 as VARCHAR(300)
		DECLARE @DynamicLineAmountFields2 as VARCHAR(300)

		

		SELECT DISTINCT P.Prdid,ColumnValue as HSNCODE 
		INTO #HSNCODE
		FROM UdcHD A (NOLOCK)
		INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId
		INNER JOIN UdcDetails C (NOLOCK) ON C.MasterId=B.MasterId and C.MasterId=A.MasterId
		and C.UdcMasterId=B.UdcMasterId 
		INNER JOIN Product P (NOLOCK) ON P.PrdId=C.MasterRecordId
		WHERE A.MasterName='Product Master' and B.ColumnName='HSN CODE'
	
		CREATE TABLE #TaxHSNSummary
		(
			StateCode Varchar(20),
			StateName Varchar(100),
			GSTin Varchar(50),
			SpmCode Varchar(50),
			Spmname Varchar(100),	
			HsnCode Varchar(50),
			Refid BIGINT,
			RefNo Varchar(50),
			CmpInvno Varchar(50),
			PurchaseOrderNo Varchar(50),
			InvoiceDate Datetime,
			RefDate DateTime,
			SpmId INT,
			GrossAmount Numeric(18,4),
			TaxableAmount Numeric(32,4),
			NetAmount numeric(24,4),
			Taxname Varchar(100),
			DynamicAmt Numeric(24,4),
			TaxType Varchar(50),
			SalesOrderType TinyInt,
			TaxFlag TinyInt	,
			Taxper Numeric(10,2),
			TaxId INT,
			[Group Name] varchar(50),
			[GroupType] Tinyint,
			[UsrId] INT
		)

		SELECT PurRcptId,Prdslno,SUM(TaxableAmount) as TaxableAmount
		INTO #PurchaseTaxableAmount
		FROM(
		SELECT S.PurRcptId,PrdSlno,SUM(DISTINCT TaxableAmount) as TaxableAmount
		FROM PurchaseReceiptProductTax  S  (NOLOCK) INNER JOIN PurchaseReceipt SI (NOLOCK) ON S.PurRcptId=SI.PurRcptId
		WHERE  TaxableAmount>0 and Status=1
		AND SI.GoodsRcvdDate  Between @FromDate AND @ToDate and VatGST='GST'
		GROUP BY S.PurRcptId,PrdSlno 
		)X GROUP BY PurRcptId,Prdslno
		
		SELECT PurRetId,Prdslno,SUM(TaxableAmount) as TaxableAmount
		INTO #PurchaseRtnTaxableAmount
		FROM(
		SELECT S.PurRetId,PrdSlno,SUM(DISTINCT TaxableAmount) as TaxableAmount
		FROM PurchaseReturnProductTax  S  (NOLOCK) INNER JOIN PurchaseReturn SI (NOLOCK) ON S.PurRetId=SI.PurRetId
		WHERE  TaxableAmount>0 AND SI.PurRetDate  Between @FromDate AND @ToDate and Status=1
		GROUP BY S.PurRetId,PrdSlno
		)X GROUP BY  PurRetId,Prdslno

		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,SpmCode,Spmname,HsnCode ,Refid,RefNo,CmpInvno,PurchaseOrderNo,
		InvoiceDate,RefDate,SpmId,GrossAmount,TaxableAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])
		SELECT '' as StateCode,'' as StateName,'' as GSTin,SpmCode,SpmName,ISNULL(HSNCODE,''),
		S.PurRcptId as RefId,PurRcptRefNo as RefNo,CmpInvNo,PurOrderRefNo,InvDate,GoodsRcvdDate as RefDate,R.SpmId,SUM(PrdGrossAmount) as PrdGrossAmount,
		SUM(ST.TaxableAmount),SUM(PrdNetAmount) as NetAmount,TaxCode +'~TaxableAmount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		SUM(SPT.TaxableAmount) as DynamicAmt,'Purchase of Goods' as TaxType,1 as SalesOrderType,
		0 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM PurchaseReceipt S (NOLOCK) 
		INNER JOIN PurchaseReceiptProduct SIP (NOLOCK) ON S.PurRcptId=SIP.PurRcptId
		INNER JOIN PurchaseReceiptProductTax SPT (NOLOCK) ON SPT.PurRcptId=SIP.PurRcptId and SPT.PurRcptId=S.PurRcptId and SIP.PrdSlNo=SPT.PrdSlNo
		INNER JOIN #PurchaseTaxableAmount ST ON ST.PurRcptId=SPT.PurRcptId  and S.PurRcptId=St.PurRcptId and ST.PurRcptId=SIP.PurRcptId and SIP.PrdSlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Supplier R ON R.SpmId=S.SpmId
		LEFT OUTER JOIN #HSNCODE A ON SIP.PrdId=A.PrdId
		WHERE GoodsRcvdDate	Between @FromDate and @ToDate and VatGST='GST'
		and SPT.TaxableAmount>0  and Status=1
		GROUP BY HSNCODE,S.PurRcptId,InvDate,GoodsRcvdDate,R.SpmId,TaxCode,TaxPerc,PurRcptRefNo,CmpInvNo,PurOrderRefNo,SPT.TaxId,SpmCode,SpmName
		UNION ALL
		SELECT '' as StateCode,'' as StateName,'' as GSTin,SpmCode,SpmName,ISNULL(HSNCODE,''),
		S.PurRcptId as RefId,PurRcptRefNo as RefNo,CmpInvNo,PurOrderRefNo,InvDate,GoodsRcvdDate as RefDate,R.SpmId,SUM(PrdGrossAmount) as PrdGrossAmount,
		SUM(ST.TaxableAmount),SUM(PrdNetAmount) as NetAmount,TaxCode +'~Taxamount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		SUM(SPT.TaxAmount) as DynamicAmt,'Purchase of Goods' as TaxType,1 as SalesOrderType,
		1 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM PurchaseReceipt S (NOLOCK) 
		INNER JOIN PurchaseReceiptProduct SIP (NOLOCK) ON S.PurRcptId=SIP.PurRcptId
		INNER JOIN PurchaseReceiptProductTax SPT (NOLOCK) ON SPT.PurRcptId=SIP.PurRcptId and SPT.PurRcptId=S.PurRcptId and SIP.PrdSlNo=SPT.PrdSlNo
		INNER JOIN #PurchaseTaxableAmount ST ON ST.PurRcptId=SPT.PurRcptId  and S.PurRcptId=St.PurRcptId and ST.PurRcptId=SIP.PurRcptId and SIP.PrdSlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Supplier R ON R.SpmId=S.SpmId
		LEFT OUTER JOIN #HSNCODE A ON SIP.PrdId=A.PrdId
		WHERE GoodsRcvdDate	Between @FromDate and @ToDate
		and SPT.TaxableAmount>0  and Status=1
		GROUP BY HSNCODE,S.PurRcptId,InvDate,GoodsRcvdDate,R.SpmId,TaxCode,TaxPerc,PurRcptRefNo,CmpInvNo,PurOrderRefNo,SPT.TaxId,SpmCode,SpmName
		
		
		
		
		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,SpmCode,Spmname,HsnCode ,Refid,RefNo,CmpInvno,PurchaseOrderNo,
		InvoiceDate,RefDate,SpmId,GrossAmount,TaxableAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])
		SELECT '' as StateCode,'' as StateName,'' as GSTin,SpmCode,SpmName,ISNULL(HSNCODE,''),
		S.PurRetId as RefId,PurRetRefNo as RefNo,'' as CmpInvno,'' as PurchaseOrderNo,PurRetDate ,PurRetDate as RefDate,R.SpmId,-1*SUM(PrdGrossAmount) as PrdGrossAmount,
		-1*SUM(ST.TaxableAmount),-1*SUM(PrdNetAmount) as NetAmount,TaxCode +'~TaxableAmount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		-1*SUM(SPT.TaxableAmount) as DynamicAmt,'Purchase Return of Goods' as TaxType,2 as SalesOrderType,
		0 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM PurchaseReturn S (NOLOCK) 
		INNER JOIN PurchaseReturnProduct SIP (NOLOCK) ON S.PurRetId=SIP.PurRetId
		INNER JOIN PurchaseReturnProductTax SPT (NOLOCK) ON SPT.PurRetId=SIP.PurRetId and SPT.PurRetId=S.PurRetId and SIP.PrdSlNo=SPT.PrdSlNo
		INNER JOIN #PurchaseRtnTaxableAmount ST ON ST.PurRetId=SPT.PurRetId  and S.PurRetId=St.PurRetId and ST.PurRetId=SIP.PurRetId and SIP.PrdSlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Supplier R ON R.SpmId=S.SpmId
		LEFT OUTER JOIN #HSNCODE A ON SIP.PrdId=A.PrdId
		WHERE PurRetDate	Between @FromDate and @ToDate and Status=0
		and SPT.TaxableAmount>0
		GROUP BY HSNCODE,S.PurRetId,PurRetDate,R.SpmId,TaxCode,TaxPerc,PurRetRefNo,SPT.TaxId,SpmCode,SpmName
		UNION ALL
		SELECT '' as StateCode,'' as StateName,'' as GSTin,SpmCode,SpmName,ISNULL(HSNCODE,''),
		S.PurRetId as RefId,PurRetRefNo as RefNo,'' as CmpInvno,'' as PurchaseOrderNo,PurRetDate,PurRetDate as RefDate,R.SpmId,-1*SUM(PrdGrossAmount) as PrdGrossAmount,
		-1*SUM(ST.TaxableAmount),-1*SUM(PrdNetAmount) as NetAmount,TaxCode +'~Taxamount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		-1*SUM(SPT.TaxAmount) as DynamicAmt,'Purchase Return of Goods' as TaxType,2 as SalesOrderType,
		1 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM PurchaseReturn S (NOLOCK) 
		INNER JOIN PurchaseReturnProduct SIP (NOLOCK) ON S.PurRetId=SIP.PurRetId
		INNER JOIN PurchaseReturnProductTax SPT (NOLOCK) ON SPT.PurRetId=SIP.PurRetId and SPT.PurRetId=S.PurRetId and SIP.PrdSlNo=SPT.PrdSlNo
		INNER JOIN #PurchaseRtnTaxableAmount ST ON ST.PurRetId=SPT.PurRetId  and S.PurRetId=St.PurRetId and ST.PurRetId=SIP.PurRetId and SIP.PrdSlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Supplier R ON R.SpmId=S.SpmId
		LEFT OUTER JOIN #HSNCODE A ON SIP.PrdId=A.PrdId
		WHERE PurRetDate	Between @FromDate and @ToDate and Status=0
		and SPT.TaxableAmount>0
		GROUP BY HSNCODE,S.PurRetId,PurRetDate,R.SpmId,TaxCode,TaxPerc,PurRetRefNo,SPT.TaxId,SpmCode,SpmName
		
		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,SpmCode,Spmname,HsnCode ,
		Refid,RefNo,CmpInvno,PurchaseOrderNo,InvoiceDate,RefDate,SpmId,GrossAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])		
		SELECT  '','','','','','', 0 as [InvId],'' as [RefNo],'' as CmpInvno,'' as PurchaseOrderNo,NUll,Null,0,0 as GrossAmount,0 as NetAmount,
		Taxname,SUM(DynamicAmt) as DynamicAmt,'' as TaxType,3 as SalesOrderType,100 as taxFlag,
		Taxper,TaxId,'ZZZZZ' as [Group Name],3 as [GroupType],@Pi_UsrId as [UsrId]
		FROM #TaxHSNSummary 
		GROUP BY Taxname,Taxper,TaxId
	

		UPDATE B SET B.StateCode= A.StateTinFirst2Digit ,
		B.Statename=A.StateName,
		B.GSTIN=A.GSTIN
		FROM DBO.FN_ReturnSupplierUDCDetails() A INNER JOIN #TaxHSNSummary B ON A.SpmId=B.SpmId
		
		SELECT B.PurRetId,A.PurRcptRefNo,A.CmpInvNo,A.PurOrderRefNo
		INTO #Refcode
		FROM PurchaseReceipt A INNER JOIN PurchaseReturn B ON A.PurRcptId=B.PurRcptId
		
		UPDATE A SET  A.CmpInvno=B.CmpInvNo,A.PurchaseOrderNo=B.PurOrderRefNo 
		FROM #TaxHSNSummary A INNER JOIN #Refcode B ON A.RefId=B.PurRetId WHERE SalesOrderType=2 


		SET @DynamicLineAmountFields='0 as NetAmount,'
		SET @DynamicLineAmountFields1='NetAmount Numeric (36,2),'
		SET @DynamicLineAmountFields2='NetAmount,'
		
		IF NOT EXISTS(SELECT 'X' FROM #TaxHSNSummary)
		BEGIN
			SELECT * FROM RptHSNInputTaxGST WHERE UsrId=@Pi_UsrId
			RETURN
		END


		DECLARE @ColSelect AS Varchar(MAX)
		DECLARE @ColSelectDataType AS Varchar(5000)
		DECLARE @TableCol AS Varchar(2000)
		DECLARE @Columns1 AS Varchar(7000)
		DECLARE @OrderBy AS VARCHAR(2000)
		DECLARE @PCSelect AS VARCHAR(3000)
		SET @PCSelect=''
		SET @ColSelect=''
		SET @ColSelectDataType=''
		SET @TableCol=''
		SET @Columns1=''
		SET @CreateTable=''
		SET @OrderBy=''

		CREATE TABLE #DynamicCol
		(
		Slno INT IDENTITY(1,1),
		Taxname	Varchar(50),
		TaxId INT,
		TaxPer Numeric(12,2),
		TaxFlag TinyInt		
		)
		INSERT INTO #DynamicCol		
		SELECT DISTINCT Taxname,TaxId,Taxper,TaxFlag FROM #TaxHSNSummary WHERE TaxFlag IN(1,0) ORDER BY TaxId,Taxper,TaxFlag,Taxname
	

		SELECT @ColSelect=@ColSelect+'ISNULL('+QuoteName(Taxname)+',0) as '+QuoteName(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SELECT @PCSelect=@PCSelect+Quotename(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SET @PCSelect=LEFT(@PCSelect,LEN(@PCSelect)-1)
		SELECT @ColSelectDataType=@ColSelectDataType+QuoteName(Taxname)+' Numeric(36,2),' FROM #DynamicCol ORDER BY Slno
		SET @ColSelect='SELECT StateCode,StateName,GSTin,SpmId,SpmCode,Spmname,Refid,RefNo,CmpInvno,PurchaseOrderNo,InvoiceDate,RefDate,HsnCode,TaxType,SalesOrderType,TaxableAmount,'+@ColSelect+@DynamicLineAmountFields2+'[Group Name],[GroupType],[UsrId]'
		SET @TableCol= 'SLNO BIGINT IDENTITY(1,1),'+
		'StateCode Varchar(20),
		StateName Varchar(100),
		GSTin Varchar(50),
		SpmId INT,
		SpmCode Varchar(50),
		Spmname Varchar(100),		
		Refid BIGINT,
		RefNo Varchar(50),
		CmpInvno Varchar(50),
		PurchaseOrderNo Varchar(50),
		InvoiceDate Datetime,
		RefDate DateTime,
		HsnCode Varchar(50),	
		TaxType Varchar(50),	
		SalesOrderType TinyInt,
		TaxableAmount Numeric(34,4),'

		SET @Columns1='SELECT StateCode,StateName,GSTin,SpmId,SpmCode,Spmname,Refid,RefNo,CmpInvno,PurchaseOrderNo,InvoiceDate,RefDate,HsnCode,TaxType,SalesOrderType,TaxableAmount,NetAmount,DynamicAmt ,TaxName,[Group Name],[GroupType],[UsrId] FROM #TaxHSNSummary'
		SET @OrderBy=' ORDER BY [Group Name],[GroupType],SalesOrderType,TaxType,Refdate,Refno'
		SET @CreateTable=' IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME=''RptHSNInputTaxGST'' and XTYPE=''U'')'+
		' DROP TABLE RptHSNInputTaxGST'+
		' CREATE TABLE RptHSNInputTaxGST ('+@TableCol+@ColSelectDataType+@DynamicLineAmountFields1+' [Group Name] Varchar(100),Grouptype TINYINT,UsrId INT)'
		PRINT @CreateTable
		EXEC(@CreateTable)
		SET @SQL=' INSERT INTO RptHSNInputTaxGST '+ @ColSelect+ ' FROM'+
		'('+@Columns1+
		') PS'+
		' PIVOT'+
		'('+
		' SUM(DynamicAmt) FOR TaxName IN('+@PCSelect+')'+
		')PVTTax '+ @OrderBy
		PRINT @SQL
		EXEC(@SQL)

		SELECT DISTINCT
		StateCode,StateName,GSTin,SpmId,SpmCode,Spmname,Refid,RefNo,RefDate,HsnCode,TaxableAmount,NetAmount
		INTO #LineLevelGross
		FROM #TaxHSNSummary WHERE UsrId=@Pi_UsrId and TaxFlag=0

		SELECT 'ZZZZZ' as [Group Name], 3 as GroupType ,SUM(TaxableAmount) as TaxableAmount,SUM(NetAmount) as NetAmount
		INTO #GrandTotal
		FROM #LineLevelGross 
		UPDATE Y SET  
		Y.TaxableAmount=X.TaxableAmount ,Y.NetAmount=X.NetAmount
		FROM RptHSNInputTaxGST Y INNER JOIN #GrandTotal X ON X.[Group Name]=Y.[Group Name]
		AND X.GroupType=Y.GroupType 
		
		
			DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=@Pi_RptId
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
			FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
			RoundOff,CreatedDate)
			SELECT 1,423,'HSN Code Wise Input Tax',1,'StateCode',20,1,0,1,1,'Supplier','State','Code',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',2,'StateName',50,1,0,1,1,'Supplier','State','Name',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',3,'GSTin',20,1,0,1,1,'Supplier','GST Tin','',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',4,'SpmCode',50,1,0,1,1,'Supplier','Code','',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',5,'Spmname',50,1,0,1,1,'Supplier','Name','',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',6,'RefNo',75,1,0,1,1,'Invoice','Number','',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',7,'CmpInvno',75,1,0,1,1,'Company','Invoice','Number',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',8,'PurchaseOrderNo',75,1,0,1,1,'Purchase','Order','Number',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',9,'RefDate',75,1,0,1,4,'Goods','Received','Date',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',10,'InvoiceDate',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',11,'HSNCode',75,1,0,1,1,'HSN Code','','',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',12,'TaxType',75,1,0,1,1,'Purchase/','Purchase Return','',0,GETDATE()
			UNION ALL
			SELECT 1,423,'HSN Code Wise Input Tax',13,'TaxableAmount',75,1,0,2,3,'Total','Taxable','Value',2,GETDATE()
			SET @Str=''
			SELECT @MaxId=MAX(ColId)+1,@ReportId=ReportId FROM  Report_Template_GST (NOLOCK) WHERE RptId=@Pi_RptId
			GROUP BY ReportId
	
			
			DECLARE @Caption1 as Varchar(30)
			DECLARE @Caption2 as Varchar(30)
			DECLARE @Caption3 as Varchar(30)
			SET @Caption1=''
			SET @Caption2=''
			SET @Caption3=''
			
			SELECT @start = 1, @end = CHARINDEX(',', @PCSelect) 
			WHILE @start < LEN(@PCSelect) + 1 BEGIN 
				IF @end = 0  
				SET @end = LEN(@PCSelect) + 1
				SET @Str=SUBSTRING(@PCSelect, @start, @end - @start)
				--SELECT @Str,'T'
				SET @Caption1=LEFT(@Str,CharIndex('~',@Str)-1)
				SET @Caption2=LEFT(SUBSTRING(@Str,CharIndex('~',@Str)+1,LEN(@Str)),CHARINDEX('~',SUBSTRING(@Str,CharIndex('~',@Str)+1,LEN(@Str)))-1)
				SET @Caption3= REPLACE(RIGHT(@Str,6),'~','')

				--SELECT @Caption1,@Caption2,@Caption3
				
				INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
				FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
				CreatedDate)  
				SELECT TOP 1 ReportId,RptId,RptName,@MaxId,SUBSTRING(@PCSelect, @start, @end - @start),
				18,1,0,2,3,@Caption1--SUBSTRING(@PCSelect, @start, @end - @start)				
				,@Caption2,@Caption3,2,Getdate()
				FROM Report_Template_GST WHERE RptId=@Pi_RptId
				
				SET @start = @end + 1 
				SET @end = CHARINDEX(',', @PCSelect, @start)
				SET @MaxId=@MaxId+1
			END 
			
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
			FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
			CreatedDate)  
			SELECT TOP 1 ReportId,RptId,RptName,@MaxId+1,'NetAmount',
			18,1,0,2,3,'Product','Level','NetAmount',2,Getdate()
			FROM Report_Template_GST WHERE RptId=@Pi_RptId	
			
			
			UPDATE Report_template_GST SET FieldName=REPLACE(REPLACE(FieldName,']',''),'[',''),
			HeaderCaption=REPLACE(REPLACE(HeaderCaption,']',''),'[',''),
			HeaderCaption1=REPLACE(REPLACE(HeaderCaption1,']',''),'[',''),
			HeaderCaption2=REPLACE(REPLACE(HeaderCaption2,']',''),'[','')
			WHERE RptId=@Pi_RptId 
			
			
			IF NOT EXISTS(SELECT 'X' FROM RptHSNInputTaxGST)
			BEGIN
				SELECT * FROM RptHSNInputTaxGST WHERE UsrId=@Pi_UsrId
				RETURN
			END
			
			SELECT * FROM RptHSNInputTaxGST WHERE UsrId=@Pi_UsrId
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='RptOutputSaleTaxGST' AND XTYPE='U')
DROP TABLE RptOutputSaleTaxGST
GO
CREATE TABLE [RptOutputSaleTaxGST](
	[SLNO] [bigint] IDENTITY(1,1) NOT NULL,
	[StateCode] [varchar](20) NULL,
	[StateName] [varchar](100) NULL,
	[GSTin] [varchar](50) NULL,
	[RetailerType] [varchar](25) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [varchar](50) NULL,
	[Rtrname] [varchar](100) NULL,
	[Refid] [bigint] NULL,
	[RefNo] [varchar](50) NULL,
	[RefDate] [datetime] NULL,
	[TaxType] [varchar](50) NULL,
	[SalesOrderType] [tinyint] NULL,
	[TaxableAmount] [numeric](34, 4) NULL,	
	[NetAmount] [numeric](36, 2) NULL,
	[Group Name] [varchar](100) NULL,
	[Grouptype] [tinyint] NULL,
	[UsrId] [int] NULL
)
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=404
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,404,'Output Tax Summary',1,'StateCode',20,1,0,1,1,'Retailer','State','Code',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',2,'StateName',50,1,0,1,1,'Retailer','State','Name',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',3,'GSTin',20,1,0,1,1,'Retailer','GST Tin','',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',4,'RetailerType',20,1,0,1,1,'Retailer','Type','',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',5,'RtrCode',50,1,0,1,1,'Retailer','Code','',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',6,'Rtrname',50,1,0,1,1,'Retailer','Name','',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',7,'RefNo',75,1,0,1,1,'Invoice','Number','',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',8,'RefDate',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',9,'TaxType',75,1,0,1,1,'Sales/','Return','',0,GETDATE()
UNION ALL
SELECT 1,404,'Output Tax Summary',10,'TaxableAmount',75,1,0,2,3,'Total','Taxable','Value',2,GETDATE()
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE NAME = 'Proc_RptOutputSaleTaxGST' AND XTYPE = 'P')
DROP PROCEDURE Proc_RptOutputSaleTaxGST
GO
/*
BEGIN tran
EXEC Proc_RptOutputSaleTaxGST 404,1,0,'GSTTAX',0,0,1
Select * from RptInputtaxCreditGST
ROLLBACK tran 
*/
CREATE PROCEDURE [Proc_RptOutputSaleTaxGST]
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
* PROCEDURE	: Proc_RptOutputSaleTaxGST
* PURPOSE	: To get the Output Tax
* CREATED	: Murugan.R
* CREATED DATE	: 25/08/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON

	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId	        AS	INT
	DECLARE @ErrNo	 	AS	INT
		

	DECLARE @SQL as Varchar(MAX)
	DECLARE @MaxId as INT
	DECLARE @ReportId as INT
	DECLARE @start INT, @end INT 
	DECLARE @Str AS VARCHAR(100)
	DECLARE @CreateTable AS VARCHAR(7000)

		
	SET @ErrNo=0
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))

	--SET @FromDate='2017-05-01'
	--SET @ToDate='2017-07-30'
	--select * from ReportFilterDt
	
		TRUNCATE TABLE RptOutputSaleTaxGST
	
	
		DECLARE @DynamicLineAmountFields as VARCHAR(300)
		DECLARE @DynamicLineAmountFields1 as VARCHAR(300)
		DECLARE @DynamicLineAmountFields2 as VARCHAR(300)

		
		CREATE TABLE #TaxHSNSummary
		(
			StateCode Varchar(20),
			StateName Varchar(100),
			GSTin Varchar(50),
			RetailerType Varchar(25),
			RtrCode Varchar(50),
			Rtrname Varchar(100),	
			Refid BIGINT,
			RefNo Varchar(50),
			RefDate DateTime,
			RtrId INT,
			GrossAmount Numeric(18,4),
			TaxableAmount Numeric(32,4),
			NetAmount numeric(24,4),
			Taxname Varchar(100),
			DynamicAmt Numeric(24,4),
			TaxType Varchar(50),
			SalesOrderType TinyInt,
			TaxFlag TinyInt	,
			Taxper Numeric(10,2),
			TaxId INT,
			[Group Name] varchar(50),
			[GroupType] Tinyint,
			[UsrId] INT
		)

		SELECT Salid,Prdslno,SUM(TaxableAmount) as TaxableAmount
		INTO #SalesTaxableAmount
		FROM(
		SELECT S.Salid,PrdSlno,SUM(DISTINCT TaxableAmount) as TaxableAmount
		FROM SalesInvoiceProductTax  S  (NOLOCK) INNER JOIN SalesInvoice SI (NOLOCK) ON S.SalId=SI.Salid
		WHERE  TaxableAmount>0 and DlvSts>3
		AND SI.SalInvDate  Between @FromDate AND @ToDate and VatGST='GST'
		GROUP BY S.Salid,PrdSlno 
		)X GROUP BY Salid,Prdslno
		
		SELECT ReturnID,Prdslno,SUM(TaxableAmount) as TaxableAmount
		INTO #RetunrTaxableAmount
		FROM(
		SELECT S.ReturnID,PrdSlno,SUM(DISTINCT TaxableAmt) as TaxableAmount
		FROM ReturnProductTax  S  (NOLOCK) INNER JOIN ReturnHeader SI (NOLOCK) ON S.ReturnID=SI.ReturnID
		WHERE  TaxableAmt>0 AND SI.ReturnDate  Between @FromDate AND @ToDate and Status=0
		GROUP BY S.ReturnID,PrdSlno
		)X GROUP BY  ReturnID,Prdslno

		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,RetailerType,RtrCode,Rtrname,Refid,RefNo,
		RefDate,RtrId,GrossAmount,TaxableAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])
		SELECT '' as StateCode,'' as StateName,'' as GSTin,'' as RetailerType,RtrCode,Rtrname,
		S.Salid as RefId,SalinvNo as RefNo,Salinvdate as RefDate,R.RtrId,SUM(PrdGrossAmount) as PrdGrossAmount,
		SUM(ST.TaxableAmount),SUM(PrdNetAmount) as NetAmount,TaxCode +'~TaxableAmount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		SUM(SPT.TaxableAmount) as DynamicAmt,'Sales of Goods' as TaxType,1 as SalesOrderType,
		0 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON S.Salid=SIP.SalId
		INNER JOIN SalesInvoiceProductTax SPT (NOLOCK) ON SPT.SalId=SIP.SalId and SPT.SalId=S.SalId and SIP.SlNo=SPT.PrdSlNo
		INNER JOIN #SalesTaxableAmount ST ON ST.SalId=SPT.SalId  and S.Salid=St.Salid and ST.SalId=SIP.SalId and SIP.SlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Retailer R ON R.RtrId=S.RtrId
		WHERE Salinvdate	Between @FromDate and @ToDate and VatGST='GST'
		and SPT.TaxableAmount>0 and DlvSts>3
		GROUP BY S.Salid,Salinvdate,R.RtrId,TaxCode,TaxPerc,SalinvNo,SPT.TaxId,RtrCode,Rtrname
		UNION ALL
		SELECT  '' as StateCode,'' as StateName,'' as GSTin,'' as RetailerType,RtrCode,Rtrname,
		S.Salid as RefId,SalinvNo as RefNo,Salinvdate as RefDate,R.RtrId,SUM(PrdGrossAmount) as PrdGrossAmount,
		SUM(ST.TaxableAmount),SUM(PrdNetAmount) as NetAmount,
		TaxCode +'~Taxamount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		SUM(TaxAmount) as DynamicAmt,'Sales of Goods' as TaxType,1 as SalesOrderType,
		1 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON S.Salid=SIP.SalId
		INNER JOIN SalesInvoiceProductTax SPT (NOLOCK) ON SPT.SalId=SIP.SalId and SPT.SalId=S.SalId and SIP.SlNo=SPT.PrdSlNo
		INNER JOIN #SalesTaxableAmount ST ON ST.SalId=SPT.SalId  and S.Salid=St.Salid and ST.SalId=SIP.SalId and SIP.SlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Retailer R ON R.RtrId=S.RtrId
		WHERE Salinvdate	Between @FromDate and @ToDate and VatGST='GST'
		and SPT.TaxableAmount>0  and DlvSts>3
		GROUP BY S.Salid,Salinvdate,R.RtrId,TaxCode,TaxPerc,SalInvNo,SPT.TaxId,RtrCode,Rtrname
		
		
		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,RetailerType,RtrCode,Rtrname,Refid,RefNo,
		RefDate,RtrId,GrossAmount,TaxableAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])
		SELECT '' as StateCode,'' as StateName,'' as GSTin,'' as RetailerType,RtrCode,Rtrname,
		S.ReturnID as RefId,ReturnCode as RefNo,ReturnDate as RefDate,R.RtrId,-1*SUM(PrdGrossAmt) as PrdGrossAmount,
		-1*SUM(TaxableAmount),-1*SUM(PrdNetAmt) as NetAmount,TaxCode +'~TaxableAmount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		-1*SUM(TaxableAmt) as DynamicAmt,'Return of Goods from Retailer' as TaxType,2 as SalesOrderType,
		0 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM ReturnHeader S (NOLOCK) 
		INNER JOIN ReturnProduct SIP (NOLOCK) ON S.ReturnID=SIP.ReturnID
		INNER JOIN ReturnProductTax SPT (NOLOCK) ON SPT.ReturnID=SIP.ReturnID and SPT.ReturnID=S.ReturnID and SIP.SlNo=SPT.PrdSlNo
		INNER JOIN #RetunrTaxableAmount ST ON ST.ReturnID=SPT.ReturnID  and S.ReturnID=St.ReturnID and ST.ReturnID=SIP.ReturnID and SIP.SlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Retailer R ON R.RtrId=S.RtrId
		WHERE ReturnDate	Between @FromDate and @ToDate and Status=0
		and TaxableAmt>0
		GROUP BY S.ReturnID,ReturnDate,R.RtrId,TaxCode,TaxPerc,ReturnCode,SPT.TaxId,RtrCode,Rtrname
		UNION ALL
		SELECT  '' as StateCode,'' as StateName,'' as GSTin,'' as RetailerType,RtrCode,Rtrname,
		S.ReturnID as RefId,ReturnCode as RefNo,ReturnDate as RefDate,R.RtrId,-1*SUM(PrdGrossAmt) as PrdGrossAmount,
		-1*SUM(TaxableAmount),-1*SUM(PrdNetAmt) as NetAmount,
		TaxCode +'~Taxamount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		-1*SUM(TaxAmt) as DynamicAmt,'Return of Goods from Retailer' as TaxType,2 as SalesOrderType,
		1 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM ReturnHeader S (NOLOCK) 
		INNER JOIN ReturnProduct SIP (NOLOCK) ON S.ReturnID=SIP.ReturnID
		INNER JOIN ReturnProductTax SPT (NOLOCK) ON SPT.ReturnID=SIP.ReturnID and SPT.ReturnID=S.ReturnID and SIP.SlNo=SPT.PrdSlNo
		INNER JOIN #RetunrTaxableAmount ST ON ST.ReturnID=SPT.ReturnID  and S.ReturnID=St.ReturnID and ST.ReturnID=SIP.ReturnID and SIP.SlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Retailer R ON R.RtrId=S.RtrId		
		WHERE ReturnDate between  @FromDate and @ToDate and Status=0
		and TaxableAmt>0
		GROUP BY S.ReturnID,ReturnDate,R.RtrId,TaxCode,TaxPerc,ReturnCode,SPT.TaxId,RtrCode,Rtrname


	
		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,RetailerType,RtrCode,Rtrname,
		Refid,RefNo,RefDate,RtrId,GrossAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])		
		SELECT  '','','','','','', 0 as [InvId],'' as [RefNo],Null,0,0 as GrossAmount,0 as NetAmount,
		Taxname,SUM(DynamicAmt) as DynamicAmt,'' as TaxType,3 as SalesOrderType,100 as taxFlag,
		Taxper,TaxId,'ZZZZZ' as [Group Name],3 as [GroupType],@Pi_UsrId as [UsrId]
		FROM #TaxHSNSummary 
		GROUP BY Taxname,Taxper,TaxId
		
		--select 'TTT',* from #TaxHSNSummary

		UPDATE B SET B.StateCode= A.StateTinFirst2Digit ,
		B.Statename=A.StateName,
		B.GSTIN=A.GSTIN,
		B.RetailerType=CASE A.RetailerType WHEN 1 THEN 'Registered'
		WHEN 2 THEN 'Unregistered' END
		FROM DBO.FN_ReturnRetailerUDCDetails() A INNER JOIN #TaxHSNSummary B ON A.Rtrid=B.RtrId


		SET @DynamicLineAmountFields='0 as NetAmount,'
		SET @DynamicLineAmountFields1='NetAmount Numeric (36,2),'
		SET @DynamicLineAmountFields2='SUM(NetAmount) as NetAmount,'
		
		IF NOT EXISTS(SELECT 'X' FROM #TaxHSNSummary)
		BEGIN
			SELECT * FROM RptOutputSaleTaxGST WHERE UsrId=@Pi_UsrId
			RETURN
		END


		DECLARE @ColSelect AS Varchar(MAX)
		DECLARE @ColSelectDataType AS Varchar(5000)
		DECLARE @TableCol AS Varchar(2000)
		DECLARE @Columns1 AS Varchar(7000)
		DECLARE @OrderBy AS VARCHAR(2000)
		DECLARE @SumCol AS VARCHAR(MAX)
		DECLARE @GroupByCol as VARCHAR(MAX)
		DECLARE @PCSelect AS VARCHAR(3000)
		SET @PCSelect=''
		SET @ColSelect=''
		SET @ColSelectDataType=''
		SET @TableCol=''
		SET @Columns1=''
		SET @CreateTable=''
		SET @OrderBy=''
		SET @SumCol=''
		SET @GroupByCol=''

		CREATE TABLE #DynamicCol
		(
		Slno INT IDENTITY(1,1),
		Taxname	Varchar(50),
		TaxId INT,
		TaxPer Numeric(12,2),
		TaxFlag TinyInt		
		)
		INSERT INTO #DynamicCol		
		SELECT DISTINCT Taxname,TaxId,Taxper,TaxFlag FROM #TaxHSNSummary WHERE TaxFlag IN(1,0) ORDER BY TaxId,Taxper,TaxFlag,Taxname
		

		SELECT @ColSelect=@ColSelect+'ISNULL('+QuoteName(Taxname)+',0) as '+QuoteName(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SELECT @PCSelect=@PCSelect+Quotename(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SET @PCSelect=LEFT(@PCSelect,LEN(@PCSelect)-1)
		SELECT @ColSelectDataType=@ColSelectDataType+QuoteName(Taxname)+' Numeric(36,2),' FROM #DynamicCol ORDER BY Slno
		SELECT @SumCol=@SumCol+'ISNULL(SUM('+QuoteName(Taxname)+'),0) as '+QuoteName(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		--SET @ColSelect='SELECT StateCode,StateName,GSTin,RetailerType,RtrId,RtrCode,Rtrname,Refid,RefNo,RefDate,TaxType,SalesOrderType,TaxableAmount,'+@ColSelect+@DynamicLineAmountFields2+'[Group Name],[GroupType],[UsrId]'
		SET @ColSelect='SELECT StateCode,StateName,GSTin,RetailerType,RtrId,RtrCode,Rtrname,Refid,RefNo,RefDate,TaxType,SalesOrderType,SUM(TaxableAmount) as TaxableAmount,'+@SumCol+@DynamicLineAmountFields2+'[Group Name],[GroupType],[UsrId]'
		SET @GroupByCol=' GROUP BY StateCode,StateName,GSTin,RetailerType,RtrId,RtrCode,Rtrname,Refid,RefNo,RefDate,TaxType,SalesOrderType,[Group Name],[GroupType],[UsrId]'
		SET @TableCol= 'SLNO BIGINT IDENTITY(1,1),'+
		'StateCode Varchar(20),
		StateName Varchar(100),
		GSTin Varchar(50),
		RetailerType Varchar(25),
		RtrId INT,
		RtrCode Varchar(50),
		Rtrname Varchar(100),		
		Refid BIGINT,
		RefNo Varchar(50),
		RefDate DateTime,	
		TaxType Varchar(50),	
		SalesOrderType TinyInt,
		TaxableAmount Numeric(32,2),
		'

		SET @Columns1='SELECT StateCode,StateName,GSTin,RetailerType,RtrId,RtrCode,Rtrname,Refid,RefNo,RefDate,TaxType,SalesOrderType,TaxableAmount,NetAmount,DynamicAmt ,TaxName,[Group Name],[GroupType],[UsrId] FROM #TaxHSNSummary'
		SET @OrderBy=' ORDER BY [Group Name],[GroupType],SalesOrderType,TaxType,Refdate,Refno'
		SET @CreateTable=' IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME=''RptOutputSaleTaxGST'' and XTYPE=''U'')'+
		' DROP TABLE RptOutputSaleTaxGST'+
		' CREATE TABLE RptOutputSaleTaxGST ('+@TableCol+@ColSelectDataType+@DynamicLineAmountFields1+' [Group Name] Varchar(100),Grouptype TINYINT,UsrId INT)'
		PRINT @CreateTable
		EXEC(@CreateTable)
		SET @SQL=' INSERT INTO RptOutputSaleTaxGST '+ @ColSelect+ ' FROM'+
		'('+@Columns1+
		') PS'+
		' PIVOT'+
		'('+
		' SUM(DynamicAmt) FOR TaxName IN('+@PCSelect+')'+
		')PVTTax '+@GroupByCol+ @OrderBy
		PRINT @SQL
		EXEC(@SQL)
		
				
		
		--EXEC Proc_RptOutputSaleTaxGST 404,1,0,'GSTTAX',0,0,1
		SELECT DISTINCT
		StateCode,StateName,GSTin,RetailerType,RtrId,RtrCode,Rtrname,Refid,RefNo,RefDate,
		TaxableAmount,
		NetAmount
		INTO #LineLevelGross
		FROM #TaxHSNSummary WHERE UsrId=@Pi_UsrId and TaxFlag=0

		SELECT 'ZZZZZ' as [Group Name], 3 as GroupType ,
		SUM(TaxableAmount) as TaxableAmount,
		SUM(NetAmount) as NetAmount
		INTO #GrandTotal
		FROM #LineLevelGross 
		UPDATE Y SET  
		Y.TaxableAmount=X.TaxableAmount ,
		Y.NetAmount=X.NetAmount
		FROM RptOutputSaleTaxGST Y INNER JOIN #GrandTotal X ON X.[Group Name]=Y.[Group Name]
		AND X.GroupType=Y.GroupType 
		
	
		
		
			DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=@Pi_RptId
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
			FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
			RoundOff,CreatedDate)
			SELECT 1,404,'Output Tax Summary',1,'StateCode',20,1,0,1,1,'Retailer','State','Code',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',2,'StateName',50,1,0,1,1,'Retailer','State','Name',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',3,'GSTin',20,1,0,1,1,'Retailer','GST Tin','',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',4,'RetailerType',20,1,0,1,1,'Retailer','Type','',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',5,'RtrCode',50,1,0,1,1,'Retailer','Code','',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',6,'Rtrname',50,1,0,1,1,'Retailer','Name','',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',7,'RefNo',75,1,0,1,1,'Invoice','Number','',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',8,'RefDate',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',9,'TaxType',75,1,0,1,1,'Sales/','Return','',0,GETDATE()
			UNION ALL
			SELECT 1,404,'Output Tax Summary',10,'TaxableAmount',75,1,0,2,3,'Total','Taxable','Value',2,GETDATE()
			SET @Str=''
			SELECT @MaxId=MAX(ColId)+1,@ReportId=ReportId FROM  Report_Template_GST (NOLOCK) WHERE RptId=@Pi_RptId
			GROUP BY ReportId
			
			DECLARE @Caption1 as Varchar(30)
			DECLARE @Caption2 as Varchar(30)
			DECLARE @Caption3 as Varchar(30)
			SET @Caption1=''
			SET @Caption2=''
			SET @Caption3=''
			
			SELECT @start = 1, @end = CHARINDEX(',', @PCSelect) 
			WHILE @start < LEN(@PCSelect) + 1 BEGIN 
				IF @end = 0  
				SET @end = LEN(@PCSelect) + 1
				SET @Str=SUBSTRING(@PCSelect, @start, @end - @start)
				--SELECT @Str,'T'
				SET @Caption1=LEFT(@Str,CharIndex('~',@Str)-1)
				SET @Caption2=LEFT(SUBSTRING(@Str,CharIndex('~',@Str)+1,LEN(@Str)),CHARINDEX('~',SUBSTRING(@Str,CharIndex('~',@Str)+1,LEN(@Str)))-1)
				SET @Caption3= REPLACE(RIGHT(@Str,6),'~','')

			
				
				INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
				FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
				CreatedDate)  
				SELECT TOP 1 ReportId,RptId,RptName,@MaxId,SUBSTRING(@PCSelect, @start, @end - @start),
				18,1,0,2,3,@Caption1--SUBSTRING(@PCSelect, @start, @end - @start)				
				,@Caption2,@Caption3,2,Getdate()
				FROM Report_Template_GST WHERE RptId=@Pi_RptId
				
				SET @start = @end + 1 
				SET @end = CHARINDEX(',', @PCSelect, @start)
				SET @MaxId=@MaxId+1
			END 
			
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
			FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
			CreatedDate)  
			SELECT TOP 1 ReportId,RptId,RptName,@MaxId+1,'NetAmount',
			18,1,0,2,3,'Product','Level','NetAmount',2,Getdate()
			FROM Report_Template_GST WHERE RptId=@Pi_RptId	
			
			
			UPDATE Report_template_GST SET FieldName=REPLACE(REPLACE(FieldName,']',''),'[',''),
			HeaderCaption=REPLACE(REPLACE(HeaderCaption,']',''),'[',''),
			HeaderCaption1=REPLACE(REPLACE(HeaderCaption1,']',''),'[',''),
			HeaderCaption2=REPLACE(REPLACE(HeaderCaption2,']',''),'[','')
			WHERE RptId=@Pi_RptId 
			
			
			IF NOT EXISTS(SELECT 'X' FROM RptOutputSaleTaxGST)
			BEGIN
				SELECT * FROM RptOutputSaleTaxGST WHERE UsrId=@Pi_UsrId
				RETURN
			END
			
			SELECT * FROM RptOutputSaleTaxGST WHERE UsrId=@Pi_UsrId
END
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE NAME='RptInputtaxCreditGST' AND XTYPE='U')
DROP TABLE RptInputtaxCreditGST
GO
CREATE TABLE [RptInputtaxCreditGST](
	[SLNO] [bigint] IDENTITY(1,1) NOT NULL,
	[StateCode] [varchar](20) NULL,
	[StateName] [varchar](100) NULL,
	[GSTin] [varchar](50) NULL,
	[SpmId] [int] NULL,
	[SpmCode] [varchar](50) NULL,
	[Spmname] [varchar](100) NULL,
	[Refid] [bigint] NULL,
	[RefNo] [varchar](50) NULL,
	[CmpInvno] [varchar](50) NULL,
	[PurchaseOrderNo] [varchar](50) NULL,
	[InvoiceDate] [datetime] NULL,
	[RefDate] [datetime] NULL,
	[TaxType] [varchar](50) NULL,
	[SalesOrderType] [tinyint] NULL,
	[TaxableAmount] [numeric](34, 4) NULL,
	[NetAmount] [numeric](36, 2) NULL,
	[Group Name] [varchar](100) NULL,
	[Grouptype] [tinyint] NULL,
	[UsrId] [int] NULL
)
GO
DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=405
INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
RoundOff,CreatedDate)
SELECT 1,405,'Input Tax Summary',1,'StateCode',20,1,0,1,1,'Supplier','State','Code',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',2,'StateName',50,1,0,1,1,'Supplier','State','Name',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',3,'GSTin',20,1,0,1,1,'Supplier','GST Tin','',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',4,'RetailerType',20,1,0,1,1,'Retailer','Type','',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',5,'SpmCode',50,1,0,1,1,'Supplier','Code','',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',6,'Spmname',50,1,0,1,1,'Supplier','Name','',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',7,'RefNo',75,1,0,1,1,'Invoice','Number','',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',8,'RefDate',75,1,0,1,4,'Goods','Received','Date',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',9,'Invoice',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',10,'TaxType',75,1,0,1,1,'Sales/','Return','',0,GETDATE()
UNION ALL
SELECT 1,405,'Input Tax Summary',11,'TaxableAmount',75,1,0,2,3,'Total','Taxable','Value',2,GETDATE()
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE NAME='Proc_RptInputtaxCreditGST' AND XTYPE='P')
DROP PROCEDURE Proc_RptInputtaxCreditGST
GO
/*
BEGIN tran
EXEC Proc_RptInputtaxCreditGST 405,1,0,'GSTTAX',0,0,1
Select * from RptInputtaxCreditGST
ROLLBACK tran 
*/
CREATE PROCEDURE [Proc_RptInputtaxCreditGST]
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
* PROCEDURE	: Proc_RptInputtaxCreditGST
* PURPOSE	: To get the Input Tax
* CREATED	: Murugan.R
* CREATED DATE	: 25/08/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON

	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId	        AS	INT
	DECLARE @ErrNo	 	AS	INT
		

	DECLARE @SQL as Varchar(MAX)
	DECLARE @MaxId as INT
	DECLARE @ReportId as INT
	DECLARE @start INT, @end INT 
	DECLARE @Str AS VARCHAR(100)
	DECLARE @CreateTable AS VARCHAR(7000)

		
	SET @ErrNo=0
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))

	--SET @FromDate='2017-05-01'
	--SET @ToDate='2017-07-30'
	--select * from ReportFilterDt
	
		TRUNCATE TABLE RptInputtaxCreditGST
	
	
		DECLARE @DynamicLineAmountFields as VARCHAR(300)
		DECLARE @DynamicLineAmountFields1 as VARCHAR(300)
		DECLARE @DynamicLineAmountFields2 as VARCHAR(300)

		

	
		CREATE TABLE #TaxHSNSummary
		(
			StateCode Varchar(20),
			StateName Varchar(100),
			GSTin Varchar(50),
			SpmCode Varchar(50),
			Spmname Varchar(100),	
			Refid BIGINT,
			RefNo Varchar(50),
			CmpInvno Varchar(50),
			PurchaseOrderNo Varchar(50),
			InvoiceDate Datetime,
			RefDate DateTime,
			SpmId INT,
			GrossAmount Numeric(18,4),
			TaxableAmount Numeric(32,4),
			NetAmount numeric(24,4),
			Taxname Varchar(100),
			DynamicAmt Numeric(24,4),
			TaxType Varchar(50),
			SalesOrderType TinyInt,
			TaxFlag TinyInt	,
			Taxper Numeric(10,2),
			TaxId INT,
			[Group Name] varchar(50),
			[GroupType] Tinyint,
			[UsrId] INT
		)

		SELECT PurRcptId,Prdslno,SUM(TaxableAmount) as TaxableAmount
		INTO #PurchaseTaxableAmount
		FROM(
		SELECT S.PurRcptId,PrdSlno,SUM(DISTINCT TaxableAmount) as TaxableAmount
		FROM PurchaseReceiptProductTax  S  (NOLOCK) INNER JOIN PurchaseReceipt SI (NOLOCK) ON S.PurRcptId=SI.PurRcptId
		WHERE  TaxableAmount>0 and Status=1
		AND SI.GoodsRcvdDate  Between @FromDate AND @ToDate and VatGST='GST'
		GROUP BY S.PurRcptId,PrdSlno 
		)X GROUP BY PurRcptId,Prdslno
		
		SELECT PurRetId,Prdslno,SUM(TaxableAmount) as TaxableAmount
		INTO #PurchaseRtnTaxableAmount
		FROM(
		SELECT S.PurRetId,PrdSlno,SUM(DISTINCT TaxableAmount) as TaxableAmount
		FROM PurchaseReturnProductTax  S  (NOLOCK) INNER JOIN PurchaseReturn SI (NOLOCK) ON S.PurRetId=SI.PurRetId
		WHERE  TaxableAmount>0 AND SI.PurRetDate  Between @FromDate AND @ToDate and Status=1
		GROUP BY S.PurRetId,PrdSlno
		)X GROUP BY  PurRetId,Prdslno

		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,SpmCode,Spmname,Refid,RefNo,CmpInvno,PurchaseOrderNo,
		InvoiceDate,RefDate,SpmId,GrossAmount,TaxableAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])
		SELECT '' as StateCode,'' as StateName,'' as GSTin,SpmCode,SpmName,
		S.PurRcptId as RefId,PurRcptRefNo as RefNo,CmpInvNo,PurOrderRefNo,InvDate,GoodsRcvdDate as RefDate,R.SpmId,SUM(PrdGrossAmount) as PrdGrossAmount,
		SUM(ST.TaxableAmount),SUM(PrdNetAmount) as NetAmount,TaxCode +'~TaxableAmount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		SUM(SPT.TaxableAmount) as DynamicAmt,'Purchase of Goods' as TaxType,1 as SalesOrderType,
		0 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM PurchaseReceipt S (NOLOCK) 
		INNER JOIN PurchaseReceiptProduct SIP (NOLOCK) ON S.PurRcptId=SIP.PurRcptId
		INNER JOIN PurchaseReceiptProductTax SPT (NOLOCK) ON SPT.PurRcptId=SIP.PurRcptId and SPT.PurRcptId=S.PurRcptId and SIP.PrdSlNo=SPT.PrdSlNo
		INNER JOIN #PurchaseTaxableAmount ST ON ST.PurRcptId=SPT.PurRcptId  and S.PurRcptId=St.PurRcptId and ST.PurRcptId=SIP.PurRcptId and SIP.PrdSlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Supplier R ON R.SpmId=S.SpmId
		WHERE GoodsRcvdDate	Between @FromDate and @ToDate and VatGST='GST'
		and SPT.TaxableAmount>0  and Status=1
		GROUP BY S.PurRcptId,InvDate,GoodsRcvdDate,R.SpmId,TaxCode,TaxPerc,PurRcptRefNo,CmpInvNo,PurOrderRefNo,SPT.TaxId,SpmCode,SpmName
		UNION ALL
		SELECT '' as StateCode,'' as StateName,'' as GSTin,SpmCode,SpmName,
		S.PurRcptId as RefId,PurRcptRefNo as RefNo,CmpInvNo,PurOrderRefNo,InvDate,GoodsRcvdDate as RefDate,R.SpmId,SUM(PrdGrossAmount) as PrdGrossAmount,
		SUM(ST.TaxableAmount),SUM(PrdNetAmount) as NetAmount,TaxCode +'~Taxamount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		SUM(SPT.TaxAmount) as DynamicAmt,'Purchase of Goods' as TaxType,1 as SalesOrderType,
		1 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM PurchaseReceipt S (NOLOCK) 
		INNER JOIN PurchaseReceiptProduct SIP (NOLOCK) ON S.PurRcptId=SIP.PurRcptId
		INNER JOIN PurchaseReceiptProductTax SPT (NOLOCK) ON SPT.PurRcptId=SIP.PurRcptId and SPT.PurRcptId=S.PurRcptId and SIP.PrdSlNo=SPT.PrdSlNo
		INNER JOIN #PurchaseTaxableAmount ST ON ST.PurRcptId=SPT.PurRcptId  and S.PurRcptId=St.PurRcptId and ST.PurRcptId=SIP.PurRcptId and SIP.PrdSlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Supplier R ON R.SpmId=S.SpmId		
		WHERE GoodsRcvdDate	Between @FromDate and @ToDate
		and SPT.TaxableAmount>0  and Status=1
		GROUP BY S.PurRcptId,InvDate,GoodsRcvdDate,R.SpmId,TaxCode,TaxPerc,PurRcptRefNo,CmpInvNo,PurOrderRefNo,SPT.TaxId,SpmCode,SpmName
		
		
		
		
		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,SpmCode,Spmname,Refid,RefNo,CmpInvno,PurchaseOrderNo,
		InvoiceDate,RefDate,SpmId,GrossAmount,TaxableAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])
		SELECT '' as StateCode,'' as StateName,'' as GSTin,SpmCode,SpmName,
		S.PurRetId as RefId,PurRetRefNo as RefNo,'' as CmpInvno,'' as PurchaseOrderNo,PurRetDate ,PurRetDate as RefDate,R.SpmId,-1*SUM(PrdGrossAmount) as PrdGrossAmount,
		-1*SUM(ST.TaxableAmount),-1*SUM(PrdNetAmount) as NetAmount,TaxCode +'~TaxableAmount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		-1*SUM(SPT.TaxableAmount) as DynamicAmt,'Purchase Return of Goods' as TaxType,2 as SalesOrderType,
		0 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM PurchaseReturn S (NOLOCK) 
		INNER JOIN PurchaseReturnProduct SIP (NOLOCK) ON S.PurRetId=SIP.PurRetId
		INNER JOIN PurchaseReturnProductTax SPT (NOLOCK) ON SPT.PurRetId=SIP.PurRetId and SPT.PurRetId=S.PurRetId and SIP.PrdSlNo=SPT.PrdSlNo
		INNER JOIN #PurchaseRtnTaxableAmount ST ON ST.PurRetId=SPT.PurRetId  and S.PurRetId=St.PurRetId and ST.PurRetId=SIP.PurRetId and SIP.PrdSlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Supplier R ON R.SpmId=S.SpmId		
		WHERE PurRetDate	Between @FromDate and @ToDate and Status=0
		and SPT.TaxableAmount>0
		GROUP BY S.PurRetId,PurRetDate,R.SpmId,TaxCode,TaxPerc,PurRetRefNo,SPT.TaxId,SpmCode,SpmName
		UNION ALL
		SELECT '' as StateCode,'' as StateName,'' as GSTin,SpmCode,SpmName,
		S.PurRetId as RefId,PurRetRefNo as RefNo,'' as CmpInvno,'' as PurchaseOrderNo,PurRetDate,PurRetDate as RefDate,R.SpmId,-1*SUM(PrdGrossAmount) as PrdGrossAmount,
		-1*SUM(ST.TaxableAmount),-1*SUM(PrdNetAmount) as NetAmount,TaxCode +'~Taxamount~' +CAST(CAST(TaxPerc as Numeric(10,2)) as Varchar(20)) as TaxName,
		-1*SUM(SPT.TaxAmount) as DynamicAmt,'Purchase Return of Goods' as TaxType,2 as SalesOrderType,
		1 as TaxFlag,TaxPerc,SPT.TaxId,'' [Group Name],2 as [GroupType],@Pi_UsrId as [UsrId]
		FROM PurchaseReturn S (NOLOCK) 
		INNER JOIN PurchaseReturnProduct SIP (NOLOCK) ON S.PurRetId=SIP.PurRetId
		INNER JOIN PurchaseReturnProductTax SPT (NOLOCK) ON SPT.PurRetId=SIP.PurRetId and SPT.PurRetId=S.PurRetId and SIP.PrdSlNo=SPT.PrdSlNo
		INNER JOIN #PurchaseRtnTaxableAmount ST ON ST.PurRetId=SPT.PurRetId  and S.PurRetId=St.PurRetId and ST.PurRetId=SIP.PurRetId and SIP.PrdSlNo=ST.PrdSlNo and SPT.PrdSlNo=ST.PrdSlNo
		INNER JOIN TaxConfiguration T (NOLOCK) ON T.TaxId=SPT.TaxId
		INNER JOIn Supplier R ON R.SpmId=S.SpmId		
		WHERE PurRetDate	Between @FromDate and @ToDate and Status=0
		and SPT.TaxableAmount>0
		GROUP BY S.PurRetId,PurRetDate,R.SpmId,TaxCode,TaxPerc,PurRetRefNo,SPT.TaxId,SpmCode,SpmName
		
		INSERT INTO #TaxHSNSummary (StateCode,StateName,GSTin,SpmCode,Spmname,
		Refid,RefNo,CmpInvno,PurchaseOrderNo,InvoiceDate,RefDate,SpmId,GrossAmount,NetAmount,Taxname,DynamicAmt,TaxType,SalesOrderType,taxFlag,
		Taxper,TaxId,[Group Name],[GroupType],[UsrId])		
		SELECT  '','','','','', 0 as [InvId],'' as [RefNo],'' as CmpInvno,'' as PurchaseOrderNo,NUll,Null,0,0 as GrossAmount,0 as NetAmount,
		Taxname,SUM(DynamicAmt) as DynamicAmt,'' as TaxType,3 as SalesOrderType,100 as taxFlag,
		Taxper,TaxId,'ZZZZZ' as [Group Name],3 as [GroupType],@Pi_UsrId as [UsrId]
		FROM #TaxHSNSummary 
		GROUP BY Taxname,Taxper,TaxId
	

		UPDATE B SET B.StateCode= A.StateTinFirst2Digit ,
		B.Statename=A.StateName,
		B.GSTIN=A.GSTIN
		FROM DBO.FN_ReturnSupplierUDCDetails() A INNER JOIN #TaxHSNSummary B ON A.SpmId=B.SpmId
		
		SELECT B.PurRetId,A.PurRcptRefNo,A.CmpInvNo,A.PurOrderRefNo
		INTO #Refcode
		FROM PurchaseReceipt A INNER JOIN PurchaseReturn B ON A.PurRcptId=B.PurRcptId
		
		UPDATE A SET  A.CmpInvno=B.CmpInvNo,A.PurchaseOrderNo=B.PurOrderRefNo 
		FROM #TaxHSNSummary A INNER JOIN #Refcode B ON A.RefId=B.PurRetId WHERE SalesOrderType=2 


		SET @DynamicLineAmountFields='0 as NetAmount,'
		SET @DynamicLineAmountFields1='NetAmount Numeric (36,2),'
		SET @DynamicLineAmountFields2='SUM(NetAmount) as NetAmount,'
		
		IF NOT EXISTS(SELECT 'X' FROM #TaxHSNSummary)
		BEGIN
			SELECT * FROM RptInputtaxCreditGST WHERE UsrId=@Pi_UsrId
			RETURN
		END


		DECLARE @ColSelect AS Varchar(MAX)
		DECLARE @ColSelectDataType AS Varchar(5000)
		DECLARE @TableCol AS Varchar(2000)
		DECLARE @Columns1 AS Varchar(7000)
		DECLARE @OrderBy AS VARCHAR(2000)
		DECLARE @PCSelect AS VARCHAR(3000)
		DECLARE @SumCol AS Varchar(Max)
		DECLARE @GroupByCol AS VARCHAR(Max)
		SET @GroupByCol=''
		SET @SumCol=''
		SET @PCSelect=''
		SET @ColSelect=''
		SET @ColSelectDataType=''
		SET @TableCol=''
		SET @Columns1=''
		SET @CreateTable=''
		SET @OrderBy=''

		CREATE TABLE #DynamicCol
		(
		Slno INT IDENTITY(1,1),
		Taxname	Varchar(50),
		TaxId INT,
		TaxPer Numeric(12,2),
		TaxFlag TinyInt		
		)
		INSERT INTO #DynamicCol		
		SELECT DISTINCT Taxname,TaxId,Taxper,TaxFlag FROM #TaxHSNSummary WHERE TaxFlag IN(1,0) ORDER BY TaxId,Taxper,TaxFlag,Taxname
	

		SELECT @ColSelect=@ColSelect+'ISNULL('+QuoteName(Taxname)+',0) as '+QuoteName(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SELECT @PCSelect=@PCSelect+Quotename(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SET @PCSelect=LEFT(@PCSelect,LEN(@PCSelect)-1)
		SELECT @ColSelectDataType=@ColSelectDataType+QuoteName(Taxname)+' Numeric(36,2),' FROM #DynamicCol ORDER BY Slno
		--SET @ColSelect='SELECT StateCode,StateName,GSTin,SpmId,SpmCode,Spmname,Refid,RefNo,CmpInvno,PurchaseOrderNo,InvoiceDate,RefDate,TaxType,SalesOrderType,TaxableAmount,'+@ColSelect+@DynamicLineAmountFields2+'[Group Name],[GroupType],[UsrId]'
		
		SELECT @SumCol=@SumCol+'ISNULL(SUM('+QuoteName(Taxname)+'),0) as '+QuoteName(Taxname)+',' FROM #DynamicCol ORDER BY Slno
		SET @ColSelect='SELECT StateCode,StateName,GSTin,SpmId,SpmCode,Spmname,Refid,RefNo,CmpInvno,PurchaseOrderNo,InvoiceDate,RefDate,TaxType,SalesOrderType,SUM(TaxableAmount) as TaxableAmount,'+@SumCol+@DynamicLineAmountFields2+'[Group Name],[GroupType],[UsrId]'
		SET @GroupByCol=' GROUP BY StateCode,StateName,GSTin,SpmId,SpmCode,Spmname,Refid,RefNo,CmpInvno,PurchaseOrderNo,InvoiceDate,RefDate,TaxType,SalesOrderType,[Group Name],[GroupType],[UsrId]'
	
		
		SET @TableCol= 'SLNO BIGINT IDENTITY(1,1),'+
		'StateCode Varchar(20),
		StateName Varchar(100),
		GSTin Varchar(50),
		SpmId INT,
		SpmCode Varchar(50),
		Spmname Varchar(100),		
		Refid BIGINT,
		RefNo Varchar(50),
		CmpInvno Varchar(50),
		PurchaseOrderNo Varchar(50),
		InvoiceDate Datetime,
		RefDate DateTime,
		TaxType Varchar(50),	
		SalesOrderType TinyInt,
		TaxableAmount Numeric(34,4),'

		SET @Columns1='SELECT StateCode,StateName,GSTin,SpmId,SpmCode,Spmname,Refid,RefNo,CmpInvno,PurchaseOrderNo,InvoiceDate,RefDate,TaxType,SalesOrderType,TaxableAmount,NetAmount,DynamicAmt ,TaxName,[Group Name],[GroupType],[UsrId] FROM #TaxHSNSummary'
		SET @OrderBy=' ORDER BY [Group Name],[GroupType],SalesOrderType,TaxType,Refdate,Refno'
		SET @CreateTable=' IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME=''RptInputtaxCreditGST'' and XTYPE=''U'')'+
		' DROP TABLE RptInputtaxCreditGST'+
		' CREATE TABLE RptInputtaxCreditGST ('+@TableCol+@ColSelectDataType+@DynamicLineAmountFields1+' [Group Name] Varchar(100),Grouptype TINYINT,UsrId INT)'
		PRINT @CreateTable
		EXEC(@CreateTable)
		SET @SQL=' INSERT INTO RptInputtaxCreditGST '+ @ColSelect+ ' FROM'+
		'('+@Columns1+
		') PS'+
		' PIVOT'+
		'('+
		' SUM(DynamicAmt) FOR TaxName IN('+@PCSelect+')'+
		')PVTTax '+ @GroupByCol+ @OrderBy
		PRINT @SQL
		EXEC(@SQL)

		SELECT DISTINCT
		StateCode,StateName,GSTin,SpmId,SpmCode,Spmname,Refid,RefNo,RefDate,TaxableAmount,NetAmount
		INTO #LineLevelGross
		FROM #TaxHSNSummary WHERE UsrId=@Pi_UsrId and TaxFlag=0

		SELECT 'ZZZZZ' as [Group Name], 3 as GroupType ,SUM(TaxableAmount) as TaxableAmount,SUM(NetAmount) as NetAmount
		INTO #GrandTotal
		FROM #LineLevelGross 
		UPDATE Y SET  
		Y.TaxableAmount=X.TaxableAmount ,Y.NetAmount=X.NetAmount
		FROM RptInputtaxCreditGST Y INNER JOIN #GrandTotal X ON X.[Group Name]=Y.[Group Name]
		AND X.GroupType=Y.GroupType 
		
		
			DELETE FROM Report_Template_GST WHERE ReportId=1 and RptId=@Pi_RptId
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName ,ColId,FieldName,FieldSize,FieldSelection,GroupField,
			FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,
			RoundOff,CreatedDate)
			SELECT 1,405,'Input Tax Summary',1,'StateCode',20,1,0,1,1,'Supplier','State','Code',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',2,'StateName',50,1,0,1,1,'Supplier','State','Name',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',3,'GSTin',20,1,0,1,1,'Supplier','GST Tin','',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',4,'SpmCode',50,1,0,1,1,'Supplier','Code','',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',5,'Spmname',50,1,0,1,1,'Supplier','Name','',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',6,'RefNo',75,1,0,1,1,'Invoice','Number','',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',7,'CmpInvno',75,1,0,1,1,'Company','Invoice','Number',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',8,'PurchaseOrderNo',75,1,0,1,1,'Purchase','Order','Number',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',9,'RefDate',75,1,0,1,4,'Goods','Received','Date',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',10,'InvoiceDate',75,1,0,1,4,'Invoice','Date','',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',11,'TaxType',75,1,0,1,1,'Purchase/','Purchase Return','',0,GETDATE()
			UNION ALL
			SELECT 1,405,'Input Tax Summary',12,'TaxableAmount',75,1,0,2,3,'Total','Taxable','Value',2,GETDATE()
			SET @Str=''
			SELECT @MaxId=MAX(ColId)+1,@ReportId=ReportId FROM  Report_Template_GST (NOLOCK) WHERE RptId=@Pi_RptId
			GROUP BY ReportId
	
			
			DECLARE @Caption1 as Varchar(30)
			DECLARE @Caption2 as Varchar(30)
			DECLARE @Caption3 as Varchar(30)
			SET @Caption1=''
			SET @Caption2=''
			SET @Caption3=''
			
			SELECT @start = 1, @end = CHARINDEX(',', @PCSelect) 
			WHILE @start < LEN(@PCSelect) + 1 BEGIN 
				IF @end = 0  
				SET @end = LEN(@PCSelect) + 1
				SET @Str=SUBSTRING(@PCSelect, @start, @end - @start)
				--SELECT @Str,'T'
				SET @Caption1=LEFT(@Str,CharIndex('~',@Str)-1)
				SET @Caption2=LEFT(SUBSTRING(@Str,CharIndex('~',@Str)+1,LEN(@Str)),CHARINDEX('~',SUBSTRING(@Str,CharIndex('~',@Str)+1,LEN(@Str)))-1)
				SET @Caption3= REPLACE(RIGHT(@Str,6),'~','')

				--SELECT @Caption1,@Caption2,@Caption3
				
				INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
				FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
				CreatedDate)  
				SELECT TOP 1 ReportId,RptId,RptName,@MaxId,SUBSTRING(@PCSelect, @start, @end - @start),
				18,1,0,2,3,@Caption1--SUBSTRING(@PCSelect, @start, @end - @start)				
				,@Caption2,@Caption3,2,Getdate()
				FROM Report_Template_GST WHERE RptId=@Pi_RptId
				
				SET @start = @end + 1 
				SET @end = CHARINDEX(',', @PCSelect, @start)
				SET @MaxId=@MaxId+1
			END 
			
			INSERT INTO Report_Template_GST(ReportId,RptId,RptName,ColId,FieldName,FieldSize,
			FieldSelection,GroupField,FieldType,Alignment,HeaderCaption,HeaderCaption1,HeaderCaption2,RoundOff,
			CreatedDate)  
			SELECT TOP 1 ReportId,RptId,RptName,@MaxId+1,'NetAmount',
			18,1,0,2,3,'Product','Level','NetAmount',2,Getdate()
			FROM Report_Template_GST WHERE RptId=@Pi_RptId	
			
			
			UPDATE Report_template_GST SET FieldName=REPLACE(REPLACE(FieldName,']',''),'[',''),
			HeaderCaption=REPLACE(REPLACE(HeaderCaption,']',''),'[',''),
			HeaderCaption1=REPLACE(REPLACE(HeaderCaption1,']',''),'[',''),
			HeaderCaption2=REPLACE(REPLACE(HeaderCaption2,']',''),'[','')
			WHERE RptId=@Pi_RptId 
			
			
			IF NOT EXISTS(SELECT 'X' FROM RptInputtaxCreditGST)
			BEGIN
				SELECT * FROM RptInputtaxCreditGST WHERE UsrId=@Pi_UsrId
				RETURN
			END
			
			SELECT * FROM RptInputtaxCreditGST WHERE UsrId=@Pi_UsrId
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_ReturnExcelReportDynamicMultiSheet' and xtype in ('TF','FN'))
DROP FUNCTION Fn_ReturnExcelReportDynamicMultiSheet
GO
--SELECT * FROM  dbo.Fn_ReturnExcelReportDynamicMultiSheet(424)
CREATE FUNCTION Fn_ReturnExcelReportDynamicMultiSheet(@RptId	AS INT)
RETURNS @MultiSheet TABLE
(
	RptId INT,
	Slno  INT,
	WorkSheetName Varchar(100),	
	RptName Varchar(100),
	RptHeaderName Varchar(100),
	RptTableName Varchar(100)
)
AS
/************************************************
* PROCEDURE  : Fn_ReturnExcelReportDynamicMultiSheet
* PURPOSE    : To Return Multiple Sheet Report Name and Table name
* CREATED BY : R.Murugan
* CREATED ON : 09/08/2017
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
BEGIN
	If @RptId =424
	BEGIN
		INSERT INTO @MultiSheet(RptId,Slno,WorkSheetName,RptName,RptHeaderName,RptTableName)
		SELECT 420,1,'Docs','GSTR1 Extract','FORM GSTR1-DOCS','RptGSTR1_Docs'
		UNION ALL
		SELECT 421,2,'Exempt','GSTR1 Extract','FORM GSTR1-Exempt','RptFORMGSTR1_Exempt'
		UNION ALL
		SELECT 419,3,'HSN','GSTR1 Extract','FORM GSTR1-HSN','RptGSTR1_HSNCODE'
		UNION ALL
		SELECT 418,4,'CDNUR','GSTR1 Extract','FORM GSTR1-CDNUR','RptGSTRTRANS1_CDNUR'
		UNION ALL
		SELECT 417,5,'CDNR','GSTR1 Extract','FORM GSTR1-CNDR','RptGSTRTRANS1_CDNR'
		UNION ALL
		SELECT 416,6,'B2CS','GSTR1 Extract','FORM GSTR1-B2CS','RptGSTR1_B2CS'
		UNION ALL
		SELECT 415,7,'B2CL','GSTR1 Extract','FORM GSTR1-B2CL','RptGSTR1_B2CL'
		UNION ALL
		SELECT 414,8,'B2B','GSTR1 Extract','FORM GSTR1-B2B','RptGSTR1_B2B'		
	END
	

RETURN
END
GO
DELETE FROM RptGroup WHERE RptId=424
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'GSRT 410',424,'GSTR1Extract','GSTR1 Extract',1
GO
DELETE FROM RptHeader WHERE RptId=424
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'GSTR1Extract','GSTR1 Extract',424,'GSTR1 Extract','Proc_RptGSTR1Extract','RptGSTR1_B2B','RptGSTR1_B2B.rpt',0
GO
DELETE FROM RptDetails where RPTID=424
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (424,1,'JCMast',-1,'','JcmId,JcmYr,JcmYr','Year*...','',1,'',12,1,1,'Press F4/Double Click to select JC Year',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (424,2,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Month...*',NULL,1,NULL,208,1,1,'Press F4/Double Click to select Month',0)
GO
DELETE FROM RPTFILTER WHERE RptId=424
INSERT INTO RPTFILTER(RptId,SelcId,FilterId,FilterDesc) 
SELECT 424,208,1,'January' UNION
SELECT 424,208,2,'February' UNION
SELECT 424,208,3,'March' UNION
SELECT 424,208,4,'April' UNION
SELECT 424,208,5,'May' UNION
SELECT 424,208,6,'June' UNION
SELECT 424,208,7,'July' UNION
SELECT 424,208,8,'August' UNION
SELECT 424,208,9,'September' UNION
SELECT 424,208,10,'October' UNION
SELECT 424,208,11,'November' UNION
SELECT 424,208,12,'December' 
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE NAME='Proc_RptGSTR1Extract' AND XTYPE='P')
DROP PROCEDURE Proc_RptGSTR1Extract
GO
/*
BEGIN tran
EXEC Proc_RptGSTR1Extract 424,1,0,'GSTTAX',0,0,1
Select * from RptInputtaxCreditGST
ROLLBACK tran 
*/
CREATE PROCEDURE [Proc_RptGSTR1Extract]
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
* PROCEDURE	: Proc_RptGSTR1Extract
* PURPOSE	: To get the Input Tax
* CREATED	: Murugan.R
* CREATED DATE	: 25/08/2017
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
		
	DELETE FROM  ReportFilterDt WHERE RptId IN(414,415,416,417,418,419,420,421)
	INSERT INTO ReportFilterDt(RptId,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate)
	SELECT 414,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT 415,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT 416,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT 417,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT 418,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId	
	UNION ALL
	SELECT 419,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT 420,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT 421,SelId,SelValue,SelDate,UsrId,LikeOn,LikeText,FilterDate
	FROM ReportFilterDt WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	
	DELETE FROM Report_txt_PageHeader_GST WHERE RptId IN(414,415,416,417,418,419,420,421)
	INSERT INTO Report_txt_PageHeader_GST(ColId,RptId,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId)
	SELECT ColId,414,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,415,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,416,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,417,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,418,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,419,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,420,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	UNION ALL
	SELECT ColId,421,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
	FROM Report_txt_PageHeader_GST WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
	
	
	EXEC Proc_RptGSTR1_B2B 414,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	EXEC Proc_RptGSTR1_B2CL 415,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	EXEC Proc_RptGSTR1_B2CS 416 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	EXEC Proc_RptGSTRTRANS1_CDNR 417 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	EXEC Proc_RptGSTRTRANS1_CDNUR 418 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	EXEC Proc_RptGSTR1_HSNCODE 419 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	EXEC Proc_RptGSTR1_Docs 420 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId
	EXEC Proc_RptFORMGSTR1_Exempt 421 ,@Pi_UsrId,@Pi_SnapId,@Pi_DbName,@Pi_SnapRequired,@Pi_GetFromSnap,@Pi_CurrencyId	
	
	
	SELECT * FROM RptGSTR1_B2B WHERE UsrId=@Pi_UsrId



END
GO
IF EXISTS (SELECT '*' FROM SYSOBJECTS WHERE name = 'Proc_RptExcelFilterCaption_GST' AND XTYPE = 'P')
DROP PROCEDURE Proc_RptExcelFilterCaption_GST
GO
--EXEC Proc_RptExcelFilterCaption_GST 424,2
--Select * from Report_txt_ExcelFilterCaption_GST
CREATE PROCEDURE [dbo].[Proc_RptExcelFilterCaption_GST]
(
	@RptId			AS INT,	
	@UsrId			AS INT
)
/************************************************
* PROCEDURE  : Proc_RptExcelFilterCaption_GST
* PURPOSE    : To Generate Excel Filter Caption
* CREATED BY : Murugan.R
* CREATED ON : 18/11/2014
* MODIFICATION
*************************************************
* DATE       AUTHOR      DESCRIPTION
*************************************************/
AS
BEGIN	

		DELETE FROM Report_txt_PageHeader_GST WHERE RptId IN(414,415,416,417,418,419,420,421)
		INSERT INTO Report_txt_PageHeader_GST(ColId,RptId,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId)
		SELECT ColId,414,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
		FROM Report_txt_PageHeader_GST WHERE RptId=424 and UsrId=@UsrId
		UNION ALL
		SELECT ColId,415,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
		FROM Report_txt_PageHeader_GST WHERE RptId=424 and UsrId=@UsrId
		UNION ALL
		SELECT ColId,416,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
		FROM Report_txt_PageHeader_GST WHERE RptId=424 and UsrId=@UsrId
		UNION ALL
		SELECT ColId,417,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
		FROM Report_txt_PageHeader_GST WHERE RptId=424 and UsrId=@UsrId
		UNION ALL
		SELECT ColId,418,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
		FROM Report_txt_PageHeader_GST WHERE RptId=424 and UsrId=@UsrId
		UNION ALL
		SELECT ColId,419,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
		FROM Report_txt_PageHeader_GST WHERE RptId=424 and UsrId=@UsrId
		UNION ALL
		SELECT ColId,420,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
		FROM Report_txt_PageHeader_GST WHERE RptId=424 and UsrId=@UsrId
		UNION ALL
		SELECT ColId,421,Filters,FilterValues,Fieldcaption1,Fieldcaption2,UsrId
		FROM Report_txt_PageHeader_GST WHERE RptId=424 and UsrId=@UsrId

		DELETE FROM Report_txt_ExcelFilterCaption_GST WHERE  Rptid=@RptId and UsrId=@UsrId
		DECLARE @NoOfColPerRow AS INT		
		SELECT @NoOfColPerRow=Ceiling(CAST(COUNT(Colid) AS NUMERIC(5,2))/CAST(2 AS NUMERIC(5,2)))
		FROM Report_txt_PageHeader_GST WHERE RptId=@RptId and UsrId=@UsrId
			
		SELECT Filters as Fieldcaption1,FilterValues,Colid   INTO #RptHeader FROM Report_txt_PageHeader_GST where ColId<=@NoOfColPerRow and Rptid=@RptId and UsrId=@UsrId
		SELECT Filters as Fieldcaption1,FilterValues,Colid-@NoOfColPerRow as  Colid  INTO #RptHeader1 FROM Report_txt_PageHeader_GST where ColId>@NoOfColPerRow  and Rptid=@RptId and UsrId=@UsrId
		INSERT INTO Report_txt_ExcelFilterCaption_GST(RptId,Fieldcaption1,FileterValue,Fieldcaption2,FileterValue1,UsrId)
		SELECT @RptId,S.Fieldcaption1,S.FilterValues,ISNULL(TS.Fieldcaption1,'') as Fieldcaption2,ISNULL(TS.FilterValues,''),@UsrId
		FROM  #RptHeader S
		LEFT OUTER JOIN #RptHeader1 TS ON S.ColId=TS.ColId  WHERE S.ColId<=@NoOfColPerRow 
END
GO
UPDATE RptGroup SET  VISIBILITY=0 WHERE RptId IN(414,415,416,417,418,419,420,421)
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.10' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.10',432
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 433)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(433,'D','2017-09-01',GETDATE(),1,'Core Stocky Service Pack 433')
GO