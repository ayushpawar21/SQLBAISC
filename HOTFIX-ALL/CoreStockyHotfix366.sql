--[Stocky HotFix Version]=366
Delete from Versioncontrol where Hotfixid='366'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('366','2.0.0.5','D','2011-03-21','2011-03-21','2011-03-21',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel and Henkel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 366' ,'366'
GO

--SRF-Nanda-215-001

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_ClaimSettlementDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_ClaimSettlementDetails]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_ClaimSettlementDetails]
(
	[DistCode] [nvarchar](50) NULL,
	[ClaimSheetNo] [nvarchar](200) NULL,
	[ClaimRefNo] [nvarchar](200) NULL,
	[CreditNoteNo] [nvarchar](100) NULL,
	[DebitNoteNo] [nvarchar](100) NULL,
	[CreditDebitNoteDate] [nvarchar](50) NULL,
	[CreditDebitNoteAmt] [numeric](38, 6) NULL,
	[CreditDebitNoteReason] [nvarchar](250) NULL,
	[DownLoadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-215-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_ClaimSettlementDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_ClaimSettlementDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Import_ClaimSettlementDetails '<Root></Root>'

CREATE   PROCEDURE [dbo].[Proc_Import_ClaimSettlementDetails]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_ClaimSettlementDetails
* PURPOSE		: To Insert the records from xml file in the Table Claim Settlement
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Cn2Cs_Prk_ClaimSettlementDetails(DistCode,ClaimSheetNo,ClaimRefNo,CreditNoteNo,DebitNoteNo,CreditDebitNoteDate,
	CreditDebitNoteAmt,CreditDebitNoteReason,DownLoadFlag)
	SELECT DistCode,ClaimSheetNo,ClaimRefNo,CreditNoteNo,DebitNoteNo,CreditDebitNoteDate,CreditDebitNoteAmt,
	CreditDebitNoteReason,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2CS_ClaimStatus',1)
	WITH (
				[DistCode]				NVARCHAR(50),
				[ClaimSheetNo]			NVARCHAR(200),
				[ClaimRefNo]			NVARCHAR(200),
				[CreditNoteNo]			NVARCHAR(100),
				[DebitNoteNo]			NVARCHAR(100),
				[CreditDebitNoteDate]	NVARCHAR(50),
				[CreditDebitNoteAmt]	NUMERIC(38,6),
				[CreditDebitNoteReason] NVARCHAR(250),
				[DownLoadFlag]			NVARCHAR(10)
	     ) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClaimSettlementDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClaimSettlementDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
DELETE FROM ErrorLog
SELECT * FROM Cn2Cs_Prk_ClaimSettlementDetails
UPDATE Cn2Cs_Prk_ClaimSettlementDetails SET DownLOadFlag='D'
EXEC Proc_Cn2Cs_ClaimSettlementDetails 0
SELECT * FROM ErrorLog
SELECT * FROM Cn2Cs_Prk_ClaimSettlementDetails
--SELECT * FROM ClaimSheetDetail
--SELECT * FROM ClaimSheetHd
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ClaimSettlementDetails]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClaimSettlementDetails
* PURPOSE		: To Download the Claim Settlement details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
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

	DECLARE @ClaimSheetNo		NVARCHAR(500)

	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimSettleToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimSettleToAvoid	
	END
	CREATE TABLE ClaimSettleToAvoid
	(
		ClaimSheetNo NVARCHAR(50),
		ClaimRefNo	 NVARCHAR(50),
		CreditNoteNo NVARCHAR(50)
	)
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','ClaimRefNo','Claim Ref No should not be empty for :'+CreditNoteNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE CreditDebitNoteAmt<0)
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE CreditDebitNoteAmt<0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Amount','Amount should be greater than zero for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE CreditDebitNoteAmt<0
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Credit/Debite Note No','Credit/Debite Note No should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')=''
	END

--	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
--	WHERE ISNULL(CreditDebitNoteReason,'')='')
--	BEGIN
--		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
--		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
--		WHERE ISNULL(CreditDebitNoteReason,'')=''
--		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
--		SELECT DISTINCT 1,'Claim Settlement','Reason','Reason should not be empty for :'+ClaimRefNo
--		FROM Cn2Cs_Prk_ClaimSettlementDetails
--		WHERE ISNULL(CreditDebitNoteReason,'')=''
--	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(CreditDebitNoteDate,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditDebitNoteDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Date should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditDebitNoteDate,'')=''
	END

	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
	(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId))
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Claim Reference Number :'+ClaimRefNo+'does not exists'
		FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)
	END

	DECLARE Cur_ClaimSettlement CURSOR	
	FOR SELECT  ISNULL([ClaimSheetNo],''),ISNULL([ClaimRefNo],''),ISNULL([CreditNoteNo],'0'),ISNULL([DebitNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CreditDebitNoteDate],121),
	CAST(ISNULL([CreditDebitNoteAmt],0)AS NUMERIC(38,6)),
	ISNULL([CreditDebitNoteReason],'')
	FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CreditNoteNo NOT IN
	(SELECT ClaimRefNo+'~'+CreditNoteNo FROM ClaimSettleToAvoid)	
	OPEN Cur_ClaimSettlement
	FETCH NEXT FROM Cur_ClaimSettlement INTO @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,
	@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
	WHILE @@FETCH_STATUS=0
	BEGIN

		IF @CreditNoteNumber=''
		BEGIN
			SET @CreditNoteNumber='0'
		END

		IF @DebitNoteNumber=''
		BEGIN
			SET @DebitNoteNumber='0'
		END

--		SELECT @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,
--		@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason

		SET @Po_ErrNo=0
		SET @ErrStatus=1

		SELECT @ClmId=B.ClmId FROM ClaimSheetDetail B INNER JOIN ClaimSheetHd A ON A.ClmId=B.ClmId
		WHERE B.RefCode=@ClaimNumber AND A.ClmCode=@ClaimSheetNo

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
--				SELECT 'Db',@DebitNoteNumber,@CreditNoteNumber
				SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteSupplier','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
				
				INSERT INTO CreditNoteSupplier(CrNoteNumber,CrNoteDate,SpmId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,CrNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@CreditNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,16,
				'Cmp-'+@CreditNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')

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

					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,CrDbmode=2,CrDbStatus=1,CrDbNotenumber=@CreditNo,Status=2
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE Cn2Cs_Prk_ClaimSettlementDetails SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber AND ClaimSheetNo=@ClaimSheetNo
				END
			END					
			ELSE IF @DebitNoteNumber <> '0' AND @CreditNoteNumber= '0'
			BEGIN
--				SELECT 'Db',@DebitNoteNumber,@CreditNoteNumber

				SELECT @DebitNo=dbo.Fn_GetPrimaryKeyString('DebitNoteSupplier','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))

				INSERT INTO DebitNoteSupplier(DbNoteNumber,DbNoteDate,SpmId,CoaId,ReasonId,Amount,DbAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,DbNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@DebitNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,33,
				'Cmp-'+@DebitNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')

				UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteSupplier' AND Fldname = 'DbNoteNumber'
			
				EXEC Proc_VoucherPosting 33,1,@DebitNo,3,7,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
				
				SELECT * FROM DebitNoteSupplier

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

--					SELECT * FROM ClaimSheetDetail WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,RecommendedAmount=@CrDbNoteAmount,
					CrDbmode=1,CrDbStatus=1,CrDbNotenumber=@DebitNo,Status=2
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

--					SELECT * FROM ClaimSheetDetail WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE Cn2Cs_Prk_ClaimSettlementDetails SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber AND ClaimSheetNo=@ClaimSheetNo
				END
			END	
		END
		FETCH NEXT FROM Cur_ClaimSettlement INTO @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
	END
	CLOSE Cur_ClaimSettlement
	DEALLOCATE Cur_ClaimSettlement

	SET @Po_ErrNo=0

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SchemePayout]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SchemePayout]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_SchemePayout
EXEC Proc_Cn2Cs_SchemePayout 0
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_SchemePayout]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SchemePayout
* PURPOSE		: To Download the Scheme Payout details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
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
	DECLARE @CrDbNoteDate		DATETIME
	DECLARE @DebitNo			NVARCHAR(500)
	DECLARE @CreditNo			NVARCHAR(500)
	DECLARE @CoaId				INT
	DECLARE @VocNo				NVARCHAR(500)
	DECLARE @CmpSchCode			NVARCHAR(200)
	DECLARE @CmpRtrCode			NVARCHAR(200)
	DECLARE @CrDbType			NVARCHAR(200)
	DECLARE @CrDbNoteNo			NVARCHAR(200)
	DECLARE @CrDbDate			DATETIME
	DECLARE @CrDbAmt			NUMERIC(38,6)
	DECLARE @ResField1			NVARCHAR(200)
	DECLARE @ResField2			NVARCHAR(200)
	DECLARE @ResField3			NVARCHAR(200)
	DECLARE @RtrId				INT
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchPayToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SchPayToAvoid	
	END
	CREATE TABLE SchPayToAvoid
	(
		CmpSchCode	 NVARCHAR(50),
		CmpRtrCode	 NVARCHAR(50)
	)
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpSchCode,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CmpSchCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','CmpSchCode','Company Scheme Code should not be empty for :'+CmpRtrCode
		FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpSchCode,'')=''
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpRtrCode,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CmpRtrCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','CmpRtrCode','Company Retailer Code should not be empty for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpRtrCode,'')=''
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE CrDbAmt<0)
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE CrDbAmt<0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Amount','Amount should be greater than zero for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout
		WHERE CrDbAmt<0
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout
	WHERE ISNULL(CrDbDate,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CrDbDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Date','Date should not be empty for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CrDbDate,'')=''
	END	
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout
	WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer))
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout WHERE
		CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Retailer','Retailer:'+CmpRtrCode+' for Scheme:'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
	END
	SET @CrDbNoteDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	DECLARE Cur_SchemePayout CURSOR	
	FOR SELECT  ISNULL([CmpSchCode],''),ISNULL([CmpRtrCode],''),ISNULL([CrDbType],''),ISNULL([CrDbNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CrDbDate],121),CAST(ISNULL([CrDbAmt],0)AS NUMERIC(38,6)),
	ISNULL([ResField1],''),ISNULL([ResField2],''),ISNULL([ResField3],'')
	FROM Cn2Cs_Prk_SchemePayout WHERE DownloadFlag='D' AND CmpSchCode+'~'+CmpRtrCode NOT IN
	(SELECT CmpSchCode+'~'+CmpRtrCode FROM SchPayToAvoid)	
	OPEN Cur_SchemePayout
	FETCH NEXT FROM Cur_SchemePayout INTO @CmpSchCode,@CmpRtrCode,@CrDbType,@CrDbNoteNo,@CrDbDate,@CrDbAmt,@ResField1,@ResField2,@ResField3
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @ErrStatus=1
		SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode
		SELECT @CoaId=CoaId FROM ClaimGroupMaster WHERE ClmGrpId=17
		
		IF @CrDbType='Credit'
		BEGIN
			SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			
			INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
			PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			VALUES(@CreditNo,@CrDbNoteDate,@RtrId,@CoaId,9,@CrDbAmt,0,1,18,18,
			@CmpSchCode,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Payout for Scheme:'+@CmpSchCode)
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteRetailer' AND Fldname = 'CrNoteNumber'
			EXEC Proc_VoucherPosting 18,1,@CreditNo,3,6,1,@CrDbNoteDate,@Po_ErrNo=@ErrStatus OUTPUT
			IF @ErrStatus<>1
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Credit Note Voucher Posting Failed for Scheme Ref No:' + @CmpSchCode
				INSERT INTO Errorlog
				VALUES (9,'Scheme Payout','Credit Note Voucher Posting',@ErrDesc)
			END
--			IF @Po_ErrNo=0
--			BEGIN
--				SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=6
--				AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)
--
--				IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
--				BEGIN
--					EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
--				END
--			END
			UPDATE Cn2Cs_Prk_SchemePayout SET DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode AND CmpRtrCode=@CmpRtrCode
		END					
		ELSE IF @CrDbType='Debit'
		BEGIN
			SELECT @DebitNo=dbo.Fn_GetPrimaryKeyString('DebitNoteRetailer','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			INSERT INTO DebitNoteRetailer(DbNoteNumber,DbNoteDate,RtrId,CoaId,ReasonId,Amount,DbAdjAmount,Status,
			PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			VALUES(@DebitNo,@CrDbNoteDate,@RtrId,@CoaId,9,@CrDbAmt,0,1,19,19,
			@CmpSchCode,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Payout for Scheme:'+@CmpSchCode)
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteRetailer' AND Fldname = 'DbNoteNumber'
		
			EXEC Proc_VoucherPosting 19,1,@DebitNo,3,7,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
			
			IF @ErrStatus<>1
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Debit Note Voucher Posting Failed'
				INSERT INTO Errorlog VALUES (10,'Scheme Payout','Debit Note Voucher Posting',@ErrDesc)
			END
	
--			IF @Po_ErrNo=0
--			BEGIN
--				SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=7
--				AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)
--
--				IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
--				BEGIN
--					EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
--				END
--			END
			UPDATE Cn2Cs_Prk_SchemePayout SET DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode AND CmpRtrCode=@CmpRtrCode
		END	
		FETCH NEXT FROM Cur_SchemePayout INTO @CmpSchCode,@CmpRtrCode,@CrDbType,@CrDbNoteNo,@CrDbDate,@CrDbAmt,@ResField1,@ResField2,@ResField3
	END
	CLOSE Cur_SchemePayout
	DEALLOCATE Cur_SchemePayout
	SET @Po_ErrNo=0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_PurchaseReceipt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_PurchaseReceipt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PurchaseReceipt 0
--SELECT * FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE CompInvNo='7083240274'--'7083240274'
--SELECT MIN(TransDate) FROM StockLedger
SELECT * FROM ErrorLog
SELECT * FROM ETLTempPurchaseReceipt
SELECT * FROM ETLTempPurchaseReceiptProduct
SELECT * FROM ETLTempPurchaseReceiptPrdLineDt
SELECT * FROM ETLTempPurchaseReceiptClaimScheme
SELECT * FROM ETLTempPurchaseReceiptOtherCharges
SELECT * FROM ETLTempPurchaseReceiptCrDbAdjustments
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_PurchaseReceipt]
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
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN

	-- For Clearing the Prking/Temp Table -----	
	DELETE FROM ETLTempPurchaseReceiptCrDbAdjustments WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)	
	DELETE FROM ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1

	TRUNCATE TABLE ETL_Prk_PurchaseReceiptCrDbAdjustments
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptOtherCharges
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim
	TRUNCATE TABLE ETL_Prk_PurchaseReceipt	
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
	DECLARE @VatBatch			INT
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
	WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already downloaded and ready for invoicing' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0)
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

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0)	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Qty','Invoice Qty should be gretaer than zero for Product:'+ProductCode+
		' for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0
	END			
	--->Till Here

	--->Added By Nanda on 10/11/2010
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreePurchaseClaim' AND Status=1)
	BEGIN
		IF NOT EXISTS(SELECT * FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
		WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote')
		BEGIN
			INSERT INTO InvToAvoid(CmpInvNo)
			SELECT DISTINCT CompInvNo FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote'
			
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Purchase Receipt',' Debit Note',' Debit Note:'+Prk.RefNo+
			' not adjusted agains claim for Invoice:'+CompInvNo 
			FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote'
		END

		IF NOT EXISTS(SELECT * FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
		WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote')
		BEGIN
			INSERT INTO InvToAvoid(CmpInvNo)
			SELECT DISTINCT CompInvNo FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote'
			
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Purchase Receipt','Credit Note',' Credit Note:'+Prk.RefNo+
			' not available for Invoice:'+CompInvNo 
			FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote'
		END
	END

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE NetValue<=0)
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE NetValue<=0

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','NetValue','NetValue<=0 for Company Invoice No:'+CompInvNo+' ' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE NetValue<=0
	END
	--->Till Here

	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT DISTINCT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,Qty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,ISNULL(VatBatch,0)
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
	@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
	@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@VatBatch
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--To insert into ETL_Prk_PurchaseReceiptPrdDt
		IF(@FreeSchemeFlag='0')
		BEGIN
			INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount],[NewPrd])
			VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@Qty*@ListPrice,
			@PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty,@VatBatch)
		END

		--To insert into ETL_Prk_PurchaseReceiptClaim
		IF(@FreeSchemeFlag='1')
		BEGIN
			INSERT INTO ETL_Prk_PurchaseReceiptClaim([Company Invoice No],[Type],[Ref No],[Product Code],
			[Batch Code],[Qty],[Stock Type],[Amount])
			VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0)
		END

		SET @RowId=@RowId+1

		FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
		@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@VatBatch
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase

	--To insert into ETL_Prk_PurchaseReceipt
	SELECT @SupplierCode=SpmCode FROM Supplier WHERE SpmDefault=1
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter)

	--->Added By Nanda on 10/11/2010
	--To insert into ETL_Prk_PurchaseReceiptOtherCharges
	INSERT INTO ETL_Prk_PurchaseReceiptOtherCharges([Company Invoice No],[OC Description],Amount)
	SELECT CompInvNo,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE CompInvNo IN 
	(SELECT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid))
	AND DownLoadFlag='D' AND AdjType='OtherCharges'
	
	--To insert into ETL_Prk_PurchaseReceiptCrDbAdjustement
	INSERT INTO ETL_Prk_PurchaseReceiptCrDbAdjustments([Company Invoice No],[Adjustment Type],[Ref No],[Amount])
	SELECT CompInvNo,AdjType,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE CompInvNo IN 
	(SELECT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid))
	AND DownLoadFlag='D' AND AdjType<>'OtherCharges'
	--->Till Here

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

	--->Added By Nanda on 17/09/2009
	DELETE FROM ETLTempPurchaseReceipt WHERE CmpInvNo NOT IN
	(SELECT DISTINCT CmpInvNo FROM ETLTempPurchaseReceiptProduct)

	UPDATE Cn2Cs_Prk_BLPurchaseReceipt SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceipt)
	--->Till Here

	--->Added By Nanda on 10/11/2010
	UPDATE Cn2Cs_Prk_PurchaseReceiptAdjustments SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceiptOtherCharges)
	AND AdjType='OtherCharges'	

	UPDATE Cn2Cs_Prk_PurchaseReceiptAdjustments SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceiptCrDbAdjustments)
	AND AdjType<>'OtherCharges'
	--->Till Here

	SET @Po_ErrNo= @ErrStatus	
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-215-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Validate_PurchaseReceiptCrDbAdjustments]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Validate_PurchaseReceiptCrDbAdjustments]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
Exec Proc_Validate_PurchaseReceiptCrDbAdjustments 0
SELECT * FROM ETLTempPurchaseReceiptCrDbAdjustments
SELECT * FROM ETL_Prk_PurchaseReceiptCrDbAdjustments
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE PROCEDURE [dbo].[Proc_Validate_PurchaseReceiptCrDbAdjustments]
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
	FOR SELECT ISNULL([Company Invoice No],''),ISNULL([Adjustment Type],''),ISNULL([Ref No],''),ISNULL([Amount],0)
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
			IF @AdjType='CreditNote'
			BEGIN
				SELECT @RefNo=ISNULL(CrNoteNumber,'') FROM CreditNoteSupplier WHERE PostedRefNo='Cmp-'+@CmpRefNo
			END
			ELSE
			BEGIN
				SELECT @RefNo=ISNULL(DbNoteNumber,'') FROM DebitNoteSupplier WHERE PostedRefNo='Cmp-'+@CmpRefNo
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_BatchTransfer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_BatchTransfer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_BatchTransfer

CREATE           PROCEDURE [dbo].[Proc_Cs2Cn_Claim_BatchTransfer]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_BatchTransfer
* PURPOSE: Extract Batch Transfer Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A  06-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Batch Transfer Value difference Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,
		'Batch Transfer Value difference Claim',
		DATENAME(MONTH,CH.ClmDate),
		YEAR(CH.ClmDate),
		BTC.BatRefNo,
		CH.ClmDate,
		CH.FromDate,
		CH.ToDate,
		BTC.ClmAmt,
		BTC.ClmAmt,
		CD.ClmPercentage,
		CD.ClmAmount,
		CD.RecommendedAmount,
		BT.Remarks,
		'',
		0,
		P.PrdCCode,
		'',
		0,
		0,
		0,
		0,
		--BTC.ClmAmt,
		CD.RecommendedAmount,
		CH.ClmCode,
		'N'
		FROM BatchTransfer BT WITH (NOLOCK)
		INNER JOIN BatchTransferClaim BTC WITH (NOLOCK) ON BT.BatRefNo=BTC.BatRefNo
		INNER JOIN Product P WITH (NOLOCK)  ON P.PrdId=BTC.PrdId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=BTC.BatRefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=7
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=CH.CmpId AND CH.Confirm=1
		WHERE CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_DeliveryBoy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_DeliveryBoy]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_DeliveryBoy

CREATE            PROCEDURE [dbo].[Proc_Cs2Cn_Claim_DeliveryBoy]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_DeliveryBoy
* PURPOSE: Extract DeliveryBoy Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE uploadflag = 'Y' AND ClaimType='Delivery boy Salary & DA Claim'
	
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
	)
	SELECT @DistCode,
		CmpName,
		'Delivery boy Salary & DA Claim',
		DATENAME(MM,CS.ClmDate),
		DATEPART(YYYY,CS.ClmDate),
		DM.DbcRefNo,
		ClmDate,
		CS.FromDate,
		CS.ToDate,
		DM.TotSugClm,
		DM.TotApproveAmt,
		CD.ClmPercentage,
		CD.ClmAmount,
		CD.RecommendedAmount,
		'',
		DB.DlvBoyName,
		0,
		'',
		'',
		0,
		0,
		0,
		0,
		--DD.TotalSuggestClm,
		ROUND(DD.TotalSuggestClm*(CD.RecommendedAmount/DM.TotSugClm),2),
		CS.ClmCode,
		'N'
	FROM DeliveryBoyClaimMaster DM
		INNER JOIN DeliveryboyClaimDetails DD  WITH (NOLOCK) ON DD.DbcRefNo=DM.DbcRefNo AND DD.Claimable=1
		INNER JOIN Company C  WITH (NOLOCK) ON DM.CmpId=C.CmpId
		INNER JOIN DeliveryBoy DB  WITH (NOLOCK) ON DD.DlvBoyId=DB.DlvBoyId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON DD.DbcRefNo=CD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 2
	WHERE DM.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Manual]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Manual]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Manual

CREATE    PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Manual]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_Manual
* PURPOSE: Extract ManualClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Manual Claim'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode ,
		CmpName ,
		ClaimType ,
		ClaimMonth ,
		ClaimYear ,
		ClaimRefNo ,
		ClaimDate ,
		ClaimFromDate ,
		ClaimToDate ,
		DistributorClaim,
		DistributorRecommended,
		ClaimnormPerc,
		SuggestedClaim,
		TotalClaimAmt ,
		Remarks ,
		Description ,
		Amount1 ,
		ProductCode ,
		Batch ,
		Quantity1 ,
		Quantity2 ,
		Amount2 ,
		Amount3 ,
		TotalAmount ,
		Remark2			,
		UploadFlag
	)
	SELECT @DistCode  AS DistCode,
		CmpName,'Manual Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		CM.MacRefNo AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate AS ClaimFromDate,
		ToDate AS ClaimToDate,
		TotalClaimAmt,
		TotalClaimAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		CD.Remarks,
		CD.Description,
		0 AS Amount1,
		ISNULL(UDC.ColumnValue,'')AS ProductCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantity2,
		0 AS Amount2,
		0 AS Amount3,
		--ClaimAmt AS TotalAmount,
		ROUND((CD.ClaimAmt/CM.TotalClaimAmt)*CDD.RecommendedAmount,2) AS TotalAmount,
		CS.ClmCode,
		'N' AS UploadFlag
		FROM Company C WITH (NOLOCK)
		INNER JOIN ManualClaimMaster CM WITH (NOLOCK)  ON CM.CmpID=C.CmpID
		INNER JOIN ManualClaimDetails CD WITH (NOLOCK) ON CD.MacRefNo=CM.MacRefNo
		INNER JOIN ClaimSheetDetail CDD WITH (NOLOCK) ON CM.MacRefNo =CDD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CDD.ClmId AND CS.ClmGrpId= 16
		LEFT OUTER JOIN UDCDetails UDC WITH (NOLOCK) ON UDC.MasterRecordId=CM.MacRefId
		AND UDC.MasterId= 35 AND UDCMasterId IN(SELECT MIN(UDCMasterId) FROM UDCMaster WHERE MasterId=36)
		WHERE CM.Status=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_ModernTrade]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_ModernTrade]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--SELECT * FROM Cs2Cn_Prk_ClaimAll
--Select * from ClaimSheetDetail
--Select * from ClaimSheetHd
--EXEC Proc_Cs2Cn_Claim_ModernTrade
CREATE           PROCEDURE [dbo].[Proc_Cs2Cn_Claim_ModernTrade]
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_ModernTrade
* PURPOSE: Extract Special Discount Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @CmpID 		AS INT
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE uploadflag = 'Y'
	AND ClaimType='Special Discount Claim'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
	)
		SELECT
			@DistCode,
			CmpName,
			'Modern Trade Claim',
			DATENAME(MM,CS.ClmDate),
			DATEPART(YYYY,CS.ClmDate),
			CS.ClmCode,
			ClmDate,
			CS.FromDate,
			CS.ToDate,
			MM.TotalSpentAmt,
			MM.TotalRecAmt,
			CD.ClmPercentage,
			CD.ClmAmount,
			CD.RecommendedAmount,
			'',
			'',
			0,
			P.PrdCCode,
			'',
			SP.BaseQty,
			0,
			0,
			0,
			MD.SpentAmt,
			CS.ClmCode,
			'N'
		FROM ModernTradeMaster MM
			INNER JOIN ModernTradeDetails MD  WITH (NOLOCK) ON MD.MTCRefNo=MM.MTCRefNo
			INNER JOIN Company C  WITH (NOLOCK) ON MM.CmpId=C.CmpId
			INNER JOIN SalesInvoiceProduct SP WITH (NOLOCK) ON SP.SalId=MD.SalId
			INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=SP.PrdID
			INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON MD.MTCRefNo=CD.RefCode
			INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 10002
		WHERE MM.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_PurchaseExcess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_PurchaseExcess]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Cs2Cn_Claim_PurchaseExcess
CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_Claim_PurchaseExcess]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_PurchaseExcess
* PURPOSE: Extract Purchase shortage Claim Details from CoreStocky to Console
* NOTES:
* CREATED: MarySubashini.S  05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Purchase Excess Quantity Refusal Claim'
	
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
		
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,'Purchase Excess Quantity Refusal Claim',
		DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),
		PSM.RefNo,CH.ClmDate,CH.FromDate,CH.ToDate,
		PSM.TotRecAmt,AMT.TotalClaimAmt,
		CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount,
		'',PR.PurRcptRefNo,PRP.PrdUnitLSP,P.PrdName,'',		
		--PRP.ExsBaseQty,0,0,0,((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ExsBaseQty),'N'
		PRP.ExsBaseQty,0,0,0,
		ROUND(((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ExsBaseQty)/TC.TotClaimAmount*CD.RecommendedAmount*(PSD.RecommenedAmt/PSM.TotRecAmt),2),CH.ClmCode,'N'
		FROM PurchaseExcessClaimMaster PSM WITH (NOLOCK)
		INNER JOIN PurchaseExcessClaimDetails PSD WITH (NOLOCK) ON PSM.RefNo=PSD.RefNo AND PSD.Claimable=1
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=PSM.CmpId
		INNER JOIN PurchaseReceipt PR WITH (NOLOCK)  ON PR.PurRcptId=PSD.PurRcptId
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK)  ON PRP.PurRcptId=PR.PurRcptId

		INNER JOIN (SELECT PR.PurRcptId,PR.PurRcptRefNo,SUM((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ExsBaseQty) AS TotClaimAmount
		FROM PurchaseReceipt PR WITH (NOLOCK) 
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK)  ON PRP.PurRcptId=PR.PurRcptId AND ExsBaseQty>0
		GROUP BY PR.PurRcptId,PR.PurRcptRefNo) TC ON TC.PurRcptId=PR.PurRcptId AND PR.PurRcptRefNo=TC.PurRcptRefNo

		INNER JOIN Product P WITH (NOLOCK)  ON P.PrdId=PRP.PrdId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=PSM.RefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=15
		AND CH.Confirm=1
		INNER JOIN (SELECT SUM(TotalClaimAmt) AS TotalClaimAmt,RefNo
		FROM PurchaseExcessClaimDetails GROUP BY RefNo) AMT ON AMT.RefNo=PSD.RefNo
		WHERE PSM.Status=1 AND CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-012

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_PurchaseShortage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_PurchaseShortage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_Cs2Cn_Claim_PurchaseShortage
CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_Claim_PurchaseShortage]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_PurchaseShortage
* PURPOSE: Extract Purchase shortage Claim Details from CoreStocky to Console
* NOTES:
* CREATED: MarySubashini.S  05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Purchase Shortage Claim'
	
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
		
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,'Purchase Shortage Claim',
		DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),
		PSM.PurShortRefNo,CH.ClmDate,CH.FromDate,CH.ToDate,
		PSM.TotalClaim,PSM.RecClaimAmt,
		CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount,
		'',PR.PurRcptRefNo,PRP.PrdUnitLSP,P.PrdCCode,'',
		PRP.ShrtBaseQty,0,0,0,
		--((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ShrtBaseQty),
		ROUND(((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ShrtBaseQty)/TC.TotClaimAmount*CD.RecommendedAmount*(PSD.RecAmount/PSM.RecClaimAmt),2),
		CH.ClmCode,
		'N'
		FROM PurShortageClaim PSM WITH (NOLOCK)
		INNER JOIN PurShortageClaimDetails PSD WITH (NOLOCK) ON PSM.PurShortId=PSD.PurShortId AND PSD.[Select]=1
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=PSM.CmpId
		INNER JOIN PurchaseReceipt PR WITH (NOLOCK)  ON PR.PurRcptId=PSD.PurRcptId
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK)  ON PRP.PurRcptId=PR.PurRcptId

		INNER JOIN (SELECT PR.PurRcptId,PR.PurRcptRefNo,SUM((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ShrtBaseQty) AS TotClaimAmount
		FROM PurchaseReceipt PR WITH (NOLOCK) 
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK)  ON PRP.PurRcptId=PR.PurRcptId AND ShrtBaseQty>0
		GROUP BY PR.PurRcptId,PR.PurRcptRefNo) TC ON TC.PurRcptId=PR.PurRcptId AND PR.PurRcptRefNo=TC.PurRcptRefNo

		INNER JOIN Product P WITH (NOLOCK)  ON P.PrdId=PRP.PrdId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=PSM.PurShortRefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=14
		AND CH.Confirm=1
		WHERE PSM.Status=1 AND CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-013

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_RateChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_RateChange]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_RateChange

CREATE           PROCEDURE [dbo].[Proc_Cs2Cn_Claim_RateChange]
AS
/*********************************
* PROCEDURE	: Proc_Cs2Cn_Claim_RateChange
* PURPOSE	: Extract Rate Change Claim Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 13/04/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Rate Change Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,
		'Rate Change Claim',
		DATENAME(MONTH,CH.ClmDate),
		YEAR(CH.ClmDate),
		VDC.ValDiffRefNo,
		CH.ClmDate,
		CH.FromDate,
		CH.ToDate,
		VDC.ClaimAmt,
		VDC.ClaimAmt,
		CD.ClmPercentage,
		CD.ClmAmount,
		CD.RecommendedAmount,
		'',
		'',
		0,
		P.PrdCCode,
		PB.PrdBatCode,
		VDC.Qty,
		0,
		VDC.ValueDiff,
		0,
		VDC.ClaimAmt,
		CH.ClmCode,
		'N'
		FROM ValueDifferenceClaim VDC WITH (NOLOCK) 
		INNER JOIN Product P WITH (NOLOCK)  ON P.PrdId=VDC.PrdId
		INNER JOIN ProductBatch PB WITH (NOLOCK)  ON PB.PrdbatId=VDC.PrdBatId AND P.PrdId=PB.PrdId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=VDC.ValDiffRefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=10001
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=CH.CmpId AND CH.Confirm=1
		WHERE CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_RateDiffernece]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_RateDiffernece]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_Cs2Cn_Claim_RateDiffernece
--SELECT * FROM Cs2Cn_Prk_ClaimAll

CREATE PROCEDURE [dbo].[Proc_Cs2Cn_Claim_RateDiffernece]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_RateDiffernece
* PURPOSE: Extract Rate Difference Claim Details from CoreStocky to Console
* NOTES:
* CREATED: MarySubashini.S  05-08-2008
* MODIFIED
* DATE         AUTHOR        DESCRIPTION
------------------------------------------------
* 17-Dec-2009  Kalaichezhian To display Product wise ratediffClaim Display
************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Price Difference Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
	)
	SELECT 	@DistCode,CM.CmpName,'Price Difference Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),
	RDC.RefNo,CH.ClmDate,CH.FromDate,CH.ToDate,RDC.TotSpentAmt,RDC.RecSpentAmt,CD.ClmPercentage,CD.ClmAmount,
	--CD.RecommendedAmount,SI.Remarks,SI.SalInvNo,0,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,0,SIP.PrdUom1EditedSelRate,0,RDC.TotSpentAmt,'N'
	CD.RecommendedAmount,SI.Remarks,SI.SalInvNo,0,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,0,SIP.PrdUom1EditedSelRate,0,SIP.PrdRateDiffAmount*CD.RecommendedAmount/ABS(CD.ClmAmount),
	CH.ClmCode,'N'
	FROM SalesInvoice SI WITH (NOLOCK)
	INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SIP.SalId=SI.SalId
	INNER JOIN RateDifferenceClaim RDC WITH (NOLOCK) ON RDC.RateDiffClaimId=SIP.RateDiffClaimId
	INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=RDC.CmpId
	INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=RDC.RefNo
	INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=12
	INNER JOIN Product P ON P.PrdId = SIP.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId = P.PrdId AND PB.PrdBatId=SIP.PrdBatId
	WHERE RDC.Status=1 AND CH.Upload='N'
	ORDER BY RDC.RefNo
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-015

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_ResellDamage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_ResellDamage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT *  FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_ResellDamage

CREATE            PROCEDURE [dbo].[Proc_Cs2Cn_Claim_ResellDamage]
AS 

SET NOCOUNT ON
BEGIN
 /*********************************
 * PROCEDURE: Proc_Cs2Cn_Claim_ResellDamage
 * PURPOSE: Extract Resell Damage Claim Details from CoreStocky to Console
 * NOTES:
 * CREATED: Mahalakshmi.A 06-08-2008
 * MODIFIED
 * DATE      AUTHOR     DESCRIPTION
 ------------------------------------------------
 *
 *********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Resell Damage Goods Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())


	INSERT INTO Cs2Cn_Prk_ClaimAll 
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		BillNo			,
		Remark2			,
		UploadFlag						
	)
	SELECT @DistCode,
		CmpName,
		'Resell Damage Goods Claim',
		DATENAME(MM,CS.ClmDate),
		DATEPART(YYYY,CS.ClmDate),
		CD.RefCode,
		ClmDate,
		CS.FromDate,
		CS.ToDate,
		RM.ClaimAmt,
		RM.ClaimAmt,
		CD.ClmPercentage,
		CD.ClmAmount,
		CD.RecommendedAmount,
		'',
		R.RtrName,
		RD.SelRate,
		P.PrdCCode,
		PB.PrdBatCode,
		RD.Quantity,
		(RD.Quantity*RD.SelRate)AS ResellAmt,		
		0,
		0,
		--(RD.Quantity*RD.SelRate)AS TotAmt,
		ROUND(((RD.Quantity*RD.SelRate)/RM.TotValue)*CD.RecommendedAmount,2) AS ResellAmt,
		RM.ReDamRefNo,
		CS.ClmCode,
		'N'
	FROM ResellDamageMaster RM
		INNER JOIN ResellDamageDetails RD  WITH (NOLOCK) ON RD.ReDamRefNo=RM.ReDamRefNo
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=RD.PrdID
		INNER JOIN ProductBatch PB WITh (NOLOCK) ON PB.PrdID= RD.PrdID AND PB.PrdBatId=RD.PrdBatId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON RM.ClaimRefNo=CD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 10
		INNER JOIN Company C  WITH (NOLOCK) ON CS.CmpId=C.CmpId
		INNER JOIN Retailer R WITH (NOLOCK) ON RM.RtrID=R.RtrId
	WHERE RM.Status=1 AND CD.Status=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-016

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_ReturnToCompany]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_ReturnToCompany]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Select * from Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_ReturnToCompany

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_ReturnToCompany]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_ReturnToCompany
* PURPOSE: Extract ReturnToCompanyClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Return To Company'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode ,
		CmpName ,
		ClaimType ,
		ClaimMonth ,
		ClaimYear ,
		ClaimRefNo ,
		ClaimDate ,
		ClaimFromDate ,
		ClaimToDate ,
		DistributorClaim,
		DistributorRecommended,
		ClaimnormPerc,
		SuggestedClaim,
		TotalClaimAmt ,
		Remarks ,
		Description ,
		Amount1 ,
		ProductCode ,
		Batch ,
		Quantity1 ,
		Quantity2 ,
		Amount2 ,
		Amount3 ,
		TotalAmount ,
		Remark2			,
		UploadFlag
	)
	SELECT @DistCode  AS DistCode,
		CmpName,'Return To Company' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		--ClmDate AS  ClaimYear,
		RH.RtnCmpRefNo AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate,
		ToDate,
		AmtForClaim,
		AmtForClaim,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		RC.Remarks,
		ISNULL(Description,''),
		Rate AS Amount1,
		PrdCCode,
		PrdBatCode AS Batch,
		RtnQty AS Quantity1,
		0 AS Quantity2 ,
		0 AS Amount2,
		0 AS Amount3,
		--Amount,
		ROUND((RH.AmtForClaim/RCA.TotAmtForClaim)*CD.RecommendedAmount,2),
		CM.ClmCode,
		'N' AS UploadFlag
		FROM Company C WITH (NOLOCK)
		INNER JOIN ClaimSheetHd CM WITH (NOLOCK)
		ON CM.CmpID=C.CmpID
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON CD.ClmId=CM.ClmId AND CM.ClmGrpId= 6
		INNER JOIN ReturnToCompanyDt RH WITH (NOLOCK) ON RH.RtnCmpRefNo=CD.RefCode
		INNER JOIN (SELECT RtnCmpRefNo,SUM(AmtForClaim) AS TotAmtForClaim FROM ReturnToCompanyDt GROUP BY RtnCmpRefNo) AS RCA ON RCA.RtnCmpRefNo=RH.RtnCmpRefNo
		LEFT OUTER JOIN ReasonMaster RM WITH (NOLOCK) ON RM.ReasonId=RH.ReasonId
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=RH.PrdId
		INNER JOIN ProductBatch PB WITH(NOLOCK) ON PB.PrdBatId=RH.PrdBatId
		INNER JOIN ReturnToCompany RC WITH(NOLOCK) ON RC.RtnCmpRefNo=RH.RtnCmpRefNo
		WHERE RC.Status=1 AND CD.Status=1 AND CM.Confirm=1 AND CM.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-017

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Salesman]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Salesman]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Salesman

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Salesman]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_Salesman
* PURPOSE: Extract SalesmanClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Salesman Salary & DA Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode ,
		CmpName ,
		ClaimType ,
		ClaimMonth ,
		ClaimYear ,
		ClaimRefNo ,
		ClaimDate ,
		ClaimFromDate ,
		ClaimToDate ,
		DistributorClaim,
		DistributorRecommended,
		ClaimnormPerc,
		SuggestedClaim,
		TotalClaimAmt ,
		Remarks ,
		Description ,
		Amount1 ,
		ProductCode ,
		Batch ,
		Quantity1 ,
		Quantity2 ,
		Amount2 ,
		Amount3 ,
		TotalAmount ,
		Remark2			,
		UploadFlag
	)
	SELECT @DistCode  AS DistCode,
		CmpName,'Salesman Salary & DA Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		SM.ScmRefNo  AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate AS ClaimFromDate,
		ToDate AS ClaimToDate,
		SM.TotalSuggClaim,
		SM.TotalApprovedAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		'' AS Remarks,
		SMName AS Description,
		0 AS Amount1,
		''AS ProductCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantuty2,
		0 AS Amount2,
		0 AS Amount3,
		--SD.TotalSuggClaim AS TotalAmount,
		ROUND(SD.TotalSuggClaim*(RecommendedAmount/SM.TotalSuggClaim),2) AS TotalAmount,		
		CS.ClmCode,
		'N' AS UploadFlag
		 FROM Company C WITH (NOLOCK)
		INNER JOIN SalesmanClaimMaster SM WITH (NOLOCK) ON SM.CmpID=C.CmpID
		INNER JOIN SalesmanClaimDetail SD WITH (NOLOCK) ON SD.ScmRefNo=SM.ScmRefNo AND SD.Claimable=1
		INNER JOIN Salesman S ON SD.SMId=S.SMId
		INNER JOIN ClaimSheetDetail CDD WITH (NOLOCK) ON SM.ScmRefNo  =CDD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CDD.ClmId AND CS.ClmGrpId= 1
		WHERE SM.Status=1 AND CDD.Status=1  AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_SalesmanIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_SalesmanIncentive]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Cs2Cn_Claim_SalesmanIncentive

CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_Claim_SalesmanIncentive]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_SalesmanIncentive
* PURPOSE: Extract Salesman Incentive Claim Details from CoreStocky to Console
* NOTES:
* CREATED: MarySubashini.S  05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Salesman Incentive Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag		
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,
		'Salesman Incentive Claim',
		DATENAME(MONTH,CH.ClmDate),
		YEAR(CH.ClmDate),
		SIM.SicRefNo,
		CH.ClmDate,CH.FromDate,CH.ToDate,SIM.TotInc,SIM.TotAppInc,
		CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount,
		'',SM.SMName,0,'','',0,0,0,0,
		--SID.TotalInc,
		ROUND(SID.TotalInc*(CD.RecommendedAmount/SIM.TotInc),2),
		CH.ClmCode,
		'N'
		FROM SMIncentiveCalculatorMaster SIM WITH (NOLOCK)
		INNER JOIN SMIncentiveCalculatorDetails SID WITH (NOLOCK) ON SIM.SicRefNo=SID.SicRefNo AND SID.Claimable=1
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=SIM.CmpId
		INNER JOIN Salesman SM WITH (NOLOCK)  ON SM.SMId=SID.SMId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=SIM.SicRefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=3 AND CH.Confirm=1
		WHERE SIM.Status=1 AND CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-019

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Salvage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Salvage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT *  FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Salvage

CREATE             PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Salvage]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_Salvage
* PURPOSE: Extract Salvage Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 06-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Salvage Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
	)
		SELECT
			@DistCode,
			CmpName,
			'Salvage Claim',
			DATENAME(MM,CS.ClmDate),
			DATEPART(YYYY,CS.ClmDate),
			CD.RefCode,
			ClmDate,
			CS.FromDate,
			CS.ToDate,
			SD.AmtForClaim,
			SD.AmtForClaim,
			CD.ClmPercentage,
			CD.ClmAmount,
			CD.RecommendedAmount,
			'',
			'',
			0,
			P.PrdCCode,
			'',
			SD.SalvageQty,
			0,
			SD.Rate,
			SD.Amount,
			--SD.AmtForClaim,
			ROUND((SD.AmtForClaim/SDC.TotAmtForClaim)*CD.RecommendedAmount,2),
			CS.ClmCode,
			'N'
		FROM salvage SM
			INNER JOIN SalvageProduct SD  WITH (NOLOCK) ON SD.SalvageRefNo=SM.SalvageRefNo
			INNER JOIN (SELECT SalvageRefNo,SUM(AmtForClaim) AS TotAmtForClaim FROM SalvageProduct GROUP BY SalvageRefNo) SDC ON SD.SalvageRefNo=SDC.SalvageRefNo
			INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=SD.PrdID
			INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON SD.SalvageRefNo=CD.RefCode
			INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 8
			INNER JOIN Company C  WITH (NOLOCK) ON CS.CmpId=C.CmpId
		WHERE SM.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Scheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Scheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM DayEndProcess	WHERE ProcId = 12
--UPDATE DayEndProcess SET NextUpDate='2009-12-28' WHERE ProcId = 12
--DELETE FROM  Cs2Cn_Prk_ClaimAll
EXEC Proc_Cs2Cn_Claim_Scheme
--UPDATE ClaimSheetHd SET Upload='N'
SELECT * FROM Cs2Cn_Prk_ClaimAll
SELECT * FROM Cs2Cn_Prk_Claim_SchemeDetails
ROLLBACK TRANSACTION
*/

CREATE       PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Scheme]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_Claim_Scheme
* PURPOSE		: Extract Scheme Claim Details from CoreStocky to Console
* NOTES:
* CREATED		: Mahalakshmi.A  19-08-2008
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* 13/11/2009 Nandakumar R.G    Added WDS Claim
*********************************/
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType IN('Scheme Claim','Window Display Claim')

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode,CmpName,ClaimType,ClaimMonth,ClaimYear,ClaimRefNo,ClaimDate,ClaimFromDate,ClaimToDate,DistributorClaim,
		DistributorRecommended,ClaimnormPerc,SuggestedClaim,TotalClaimAmt,Remarks,Description,Amount1,ProductCode,Batch,
		Quantity1,Quantity2,Amount2,Amount3,TotalAmount,SchemeCode,BillNo,BillDate,RetailerCode,RetailerName,
		TotalSalesInValue,PromotedSalesinValue,OID,Discount,FromStockType,ToStockType,Remark2,Remark3,PrdCode1,
		PrdCode2,PrdName1,PrdName2,Date2,UploadFlag		
	)
--	SELECT 	@DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,CH.FromDate,CH.ToDate,
--	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount AS TotAmt,
--	'',SM.SchDsc,(CASE SM.SchType WHEN 2 THEN SL.PurQty ELSE 0 END) AS SchemeOnAmt,ISNULL(P.PrdDCode,'') AS PrdDCode,
--	ISNULL(P.PrdName,'') AS PrdName,(CASE SM.SchType WHEN 1 THEN CAST(SL.PurQty AS INT) ELSE 0 END) AS SchemeOnQty,
--	ISNULL(SF.FreeQty,0) As SchemeQty,CD.FreePrdVal+GiftPrdVal as FGQtyValue,Cd.Discount AS SchemeAmt,
--	(CD.FreePrdVal+GiftPrdVal+CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),'','',0,0,0,0,'','','','','','','','',GETDATE(),'N'
--	FROM SchemeMaster SM
--	INNER JOIN SchemeSlabs SL ON SM.SchId=SL.SchId
--	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
--	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
--	INNER JOIN Company CM ON CM.CmpId=CH.CmpId	
--	LEFT OUTER JOIN SchemeSlabFrePrds SF ON SM.SchId=SF.SchId
--	LEFT OUTER JOIN Product P ON SF.PrdId=P.PrdId
--	WHERE CH.Confirm=1 AND CH.Upload='N'

	SELECT @DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CD.RefCode,CH.ClmDate,CH.FromDate,CH.ToDate,
	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CSCA.RecommendedAmount,CD.ClmPercentage,CD.ClmAmount,CSCA.RecommendedAmount,
	--CD.RecommendedAmount AS TotAmt,
	'',SM.SchDsc,0,'',
	'' AS PrdName,0,0,
	ROUND((CD.FreePrdVal+GiftPrdVal)/CD.ClmAmount*CD.RecommendedAmount,2) AS FGQtyValue,
	ROUND(Cd.Discount/CD.ClmAmount*CD.RecommendedAmount,2) AS SchemeAmt,
	ROUND((CD.FreePrdVal+CD.GiftPrdVal+CD.Discount)/CD.ClmAmount*CD.RecommendedAmount,2) AS Amount,SM.CmpSchCode,'',GETDATE(),
	'','',0,0,0,0,'','',CH.ClmCode,'','','','','',GETDATE(),'N'
	FROM SchemeMaster SM	
	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
	INNER JOIN 
	(
		SELECT CD.ClmId,SUM(RecommendedAmount) AS RecommendedAmount FROM ClaimSheetDetail CD 
		INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16 AND CH.Confirm=1 AND CH.Upload='N'
		GROUP BY CD.ClmId
	) AS CSCA ON CSCA.ClmId=CD.ClmId
	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
	INNER JOIN Company CM ON CM.CmpId=CH.CmpId --AND SM.SchType<>4 
	WHERE CH.Confirm=1 AND CH.Upload='N' AND CD.SelectMode=1

--	UNION	
--
--	--SELECT 	@DistCode,CM.CmpName,'Window Display Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,
--	SELECT 	@DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CD.RefCode,CH.ClmDate,	
--	CH.FromDate,CH.ToDate,
--	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,SUM(CD.ClmAmount),SUM(CD.RecommendedAmount) AS TotAmt,
--	'',SM.SchDsc,0 AS SchemeOnAmt,'WDS' AS PrdDCode,'Window Display Claim' AS PrdName,0 AS SchemeOnQty,
--	0 As SchemeQty,AdjAmt,SUM(Cd.Discount) AS SchemeAmt,
--	SUM(CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),R.RtrCode,R.RtrName,0,0,0,0,
--	'','',CH.ClmCode,'','','','','',GETDATE(),'N'
--	FROM SchemeMaster SM
--	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
--	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
--	INNER JOIN Company CM ON CM.CmpId=CH.CmpId
--	INNER JOIN SalesInvoiceWindowDisplay SIW ON SIW.SchId=SM.SchId AND CH.ClmId=SIW.SchClmId
--	INNER JOIN SalesInvoice SI ON SI.SalId=SIW.SalId 	
--	INNER JOIN Retailer R ON SI.RtrId=R.RtrId 	
--	WHERE CH.Confirm=1 AND SM.SchType=4 AND CH.Upload='N' AND CD.SelectMode=1
--	GROUP BY CM.CmpName,CH.ClmDate,CH.ClmCode,SM.CmpSchCode,CH.ClmDate,CH.FromDate,CH.ToDate,
--	SM.SchId,CD.RecommendedAmount,CD.ClmPercentage,SM.SchDsc,AdjAmt,R.RtrCode,R.RtrName,CD.RefCode

	--->Added By Nanda on 13/10/2010 for Claim Details
	DELETE FROM Cs2Cn_Prk_Claim_SchemeDetails WHERE UploadFlag='Y'

	INSERT INTO Cs2Cn_Prk_Claim_SchemeDetails(DistCode,ClaimRefNo,CmpSchCode,SlabId,SalInvNo,PrdCCode,BilledQty,
	ClaimAmount,SchCode,SchDesc,ClaimDate,UploadedDate,UploadFlag)
	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISL.SlabId,SI.SalInvNo,P.PrdCCode,SUM(SIP.BaseQty),SUM(SISL.FlatAmount+SISL.DiscountPerAmount),
	SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeLinewise SISL,SchemeMaster SM,
	SalesInvoice SI,Product P,SalesInvoiceProduct SIP
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND
	SISL.SchClmId=CD.ClmId AND SISL.SchId=SM.SchId AND SISL.SalId=Si.SalId AND SISl.PrdId=P.PrdId
	AND SISL.RowId =SIP.SlNo AND SISL.SalId=SIP.SalId AND SI.SalId = SIP.SalId 
	GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISL.SlabId,SI.SalInvNo,P.PrdCCode
	HAVING SUM(SISL.FlatAmount+SISL.DiscountPerAmount)>0

	UNION

	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISF.SlabId,SI.SalInvNo,'Free Product' AS PrdCCode,
	0 AS BaseQty,ROUND(SUM(SISF.FreeQty*PBD.PrdBatDetailValue),2),SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeDtFreePrd SISF,SchemeMaster SM,
	SalesInvoice SI,ProductBatchDetails PBD,BatchCreation BC
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND CD.SelectMode=1 AND
	SISF.SchClmId=CD.ClmId AND SISF.SchId=SM.SchId AND SISF.SalId=Si.SalId 
	AND SISF.FreePrdBatId =PBD.PrdBatId AND SISf.FreePriceId=PBD.PriceId AND PBD.SlNo=BC.SlNo AND BC.ClmRte=1 AND
	PBD.BatchSeqId=BC.BatchSeqId
	GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISF.SlabId,SI.SalInvNo
	
	UNION

	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,0 AS SlabId,SI.SalInvNo,'Window Display' AS PrdCCode,
	0 AS BaseQty,SUM(SIW.AdjAmt),SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceWindowDisplay SIW,SchemeMaster SM,
	SalesInvoice SI
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND CD.SelectMode=1 AND
	SIW.SchClmId=CD.ClmId AND SIW.SchId=SM.SchId AND SIW.SalId=Si.SalId 	
	GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SI.SalInvNo
	--->Till Here
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-021

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_SpecialDiscount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_SpecialDiscount]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--Select * from ClaimSheetDetail
--Select * from ClaimSheetHd
--EXEC Proc_Cs2Cn_Claim_SpecialDiscount

CREATE	PROCEDURE [dbo].[Proc_Cs2Cn_Claim_SpecialDiscount]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_SpecialDiscount
* PURPOSE: Extract Special Discount Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE uploadflag = 'Y' AND ClaimType='Special Discount Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
	)
		SELECT
			@DistCode,
			CmpName,
			'Special Discount Claim',
			DATENAME(MM,CS.ClmDate),
			DATEPART(YYYY,CS.ClmDate),
			SM.SdcRefNo,
			ClmDate,
			CS.FromDate,
			CS.ToDate,
			SM.TotalSpentAmt,
			SM.TotalRecAmt,
			CD.ClmPercentage,
			CD.ClmAmount,
			CD.RecommendedAmount,
			'',
			'',
			0,
			P.PrdCCode,
			'',
			SP.BaseQty,
			0,
			0,
			0,
			--SD.SpentAmt,
			ROUND((PrdSplDiscAmount+(Sp.BaseQty * (PBD.PrdBatDetailValue-PBDS.PrdBatDetailValue)))*(CD.RecommendedAmount/SM.TotalSpentAmt),2),
			CS.ClmCode,
			'N'
		FROM SpecialDiscountMaster SM
			INNER JOIN SpecialDiscountDetails SD  WITH (NOLOCK) ON SD.SdcRefNo=SM.SdcRefNo AND SD.Status=1
			INNER JOIN Company C  WITH (NOLOCK) ON SM.CmpId=C.CmpId
			INNER JOIN SalesInvoiceProduct SP WITH (NOLOCK) ON SP.SalId=SD.SalId
			INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=SP.PrdID

			INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId = PB.PrdID
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PB.PrdBatId = PBD.PrdBatID
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId = PBD.BatchSeqId And PBD.SlNo = BC.SlNo And BC.SelRte = 1
			AND PBD.PriceId=SP.SplPriceId

			INNER JOIN ProductBatch PBS (NOLOCK) ON P.PrdId = PBS.PrdID
			INNER JOIN ProductBatchDetails PBDS (NOLOCK) ON PBS.PrdBatId = PBDS.PrdBatID
			INNER JOIN BatchCreation BCS (NOLOCK) ON BCS.BatchSeqId = PBDS.BatchSeqId And PBDS.SlNo = BCS.SlNo And BCS.SelRte = 1
			AND PBDS.PriceId=SP.PriceId

			INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON SD.SdcRefNo=CD.RefCode
			INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 11
		WHERE SM.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_StockJournal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_StockJournal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Select * from Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_StockJournal

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_StockJournal]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_StockJournal
* PURPOSE: Extract StockJournalClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Stock Journal Value Difference Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode ,
		CmpName ,
		ClaimType ,
		ClaimMonth ,
		ClaimYear ,
		ClaimRefNo ,
		ClaimDate ,
		ClaimFromDate ,
		ClaimToDate ,
		DistributorClaim,
		DistributorRecommended,
		ClaimnormPerc,
		SuggestedClaim,
		TotalClaimAmt ,
		Remarks ,
		Description ,
		Amount1 ,
		ProductCode ,
		Batch ,
		Quantity1 ,
		Quantity2 ,
		Amount2 ,
		Amount3 ,
		TotalAmount ,
		Remark2			,
		UploadFlag
	)
	SELECT @DistCode  AS DistCode,
		CmpName,'Stock Journal Value Difference Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		RefCode AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate,
		ToDate,
		ClmAmt,
		ClmAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		'' AS Remarks,
		'' AS Description,
		0 AS Amount1,
		PrdCCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantity2,
		0 AS Amount2,
		0 AS Amount3,
		--ClmAmount,
		RecommendedAmount,
		CM.ClmCode,
		'N' AS UploadFlag
		FROM Company C WITH (NOLOCK)
		INNER JOIN ClaimSheetHd CM WITH (NOLOCK)
		ON CM.CmpID=C.CmpID
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)
		ON CD.ClmID=CM.ClmID AND CM.ClmGrpId= 9
		INNER JOIN StkJournalClaim SJ WITH (NOLOCK)
		ON CD.RefCode=SJ.StkJournalRefNo
		INNER JOIN Product P WITH (NOLOCK)
		ON P.PrdId=SJ.PrdId
		WHERE Status=1 AND CM.Confirm=1 AND CM.Upload='N'		
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-023

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Transporter]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Transporter]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_CS2CNTransporterClaim

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Transporter]
AS
/*********************************
* PROCEDURE: Proc_CS2CNTransporterClaim
* PURPOSE: Extract TransporterClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Transporter Claim'
	
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode ,
		CmpName ,
		ClaimType ,
		ClaimMonth ,
		ClaimYear ,
		ClaimRefNo ,
		ClaimDate ,
		ClaimFromDate ,
		ClaimToDate ,
		DistributorClaim,
		DistributorRecommended,
		ClaimnormPerc,
		SuggestedClaim,
		TotalClaimAmt ,
		Remarks ,
		Description ,
		Amount1 ,
		ProductCode ,
		Batch ,
		Quantity1 ,
		Quantity2,
		Amount2 ,
		Amount3 ,
		TotalAmount ,
		Remark2			,
		UploadFlag
	)	
	SELECT @DistCode  AS DistCode,
		CmpName,'Transporter Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		TM.TrcRefNo AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate AS ClaimFromDate,
		ToDate AS ClaimToDate,
		TM.TotalSpentAmt,
		TM.TotalRecAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		'' AS Remarks,
		TransporterName AS Description,
		0 AS Amount1,
		''AS ProductCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantity2,
		0 AS Amount2,
		0 AS Amount3,
		--TD.SpentAmount AS TotalAmount,
		ROUND(TD.SpentAmount*(RecommendedAmount/TM.TotalSpentAmt),2) AS TotalAmount,
		CS.ClmCode,
		'N' AS UploadFlag
		 FROM Company C WITH (NOLOCK)
		INNER JOIN TransporterClaimMaster TM WITH (NOLOCK)  ON TM.CmpID=C.CmpID
		INNER JOIN TransporterClaimDetails TD WITH (NOLOCK) ON TD.TrcRefNo=TM.TrcRefNo AND TD.[Select]=1
		INNER JOIN Transporter T WITH (NOLOCK)  ON T.TransporterId= TD.TransporterId
		INNER JOIN ClaimSheetDetail CDD WITH (NOLOCK) ON TM.TrcRefNo  =CDD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CDD.ClmId AND CS.ClmGrpId= 5
		WHERE TM.Status=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N'	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-024

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_VanSubsidy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_VanSubsidy]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Select * from Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_VanSubsidy

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_VanSubsidy]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_VanSubsidy
* PURPOSE: Extract VanSubsidyClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Van Subsidy Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode ,
		CmpName ,
		ClaimType ,
		ClaimMonth ,
		ClaimYear ,
		ClaimRefNo ,
		ClaimDate ,
		ClaimFromDate ,
		ClaimToDate ,
		DistributorClaim,
		DistributorRecommended,
		ClaimnormPerc,
		SuggestedClaim,
		TotalClaimAmt ,
		Remarks ,
		Description ,
		Amount1 ,
		ProductCode ,
		Batch ,
		Quantity1 ,
		Quantity2,
		Amount2 ,
		Amount3 ,
		TotalAmount ,
		Remark2			,
		UploadFlag
	)
	
	SELECT @DistCode  AS DistCode,
		CmpName,'Van Subsidy Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		VM.RefNo AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate AS ClaimFromDate,
		ToDate AS ClaimToDate,
		TotalClaimAmount,
		VM.ApprovedClaimAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount ,	
		'' AS Remarks,
		VehicleCtgName AS Description,
		0 AS Amount1,
		''AS ProductCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantity2,
		0 AS Amount2,
		0 AS Amount3,
		--VD.ApprovedAmt AS TotalAmount,
		ROUND(VD.ApprovedAmt*(RecommendedAmount/VM.ApprovedClaimAmt),2) AS TotalAmount,
		CS.ClmCode,
		'N' AS UploadFlag
		 FROM Company C WITH (NOLOCK)
		INNER JOIN VanSubsidyHD VM WITH (NOLOCK)  ON VM.CmpID=C.CmpID
		INNER JOIN (Select SUM(DaySuggAmt)+ SUM(SalSuggAmt) + SUM(KMSuggAmt)+ SUM(TonneSuggAmt)
		AS TotalClaimAmount,RefNo FROM VanSubsidyDetail VD GROUP BY RefNo) A ON A.RefNo=VM.RefNo
		INNER JOIN VanSubsidyDetail VD WITH (NOLOCK) ON VM.RefNo=VD.RefNo
		INNER JOIN VehicleCategory VC WITH (NOLOCK)  ON VC.VehicleCtgId= VD.VehicleCtgId
		INNER JOIN  VehicleSubsidy VS WITH (NOLOCK) ON VS.VehicleCtgId=VC.VehicleCtgId
		INNER JOIN ClaimSheetDetail CDD WITH (NOLOCK) ON VM.RefNo  =CDD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CDD.ClmId AND CS.ClmGrpId= 4
		WHERE VS.VehicleStatus=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-215-025

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Vat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Vat]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Vat

CREATE             PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Vat]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_Vat
* PURPOSE: Extract VAT Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE uploadflag = 'Y' AND ClaimType='VAT Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		Remark2			,
		UploadFlag
	)
	SELECT 	@DistCode,
			CmpName,
			'VAT Claim',
			DATENAME(MM,CS.ClmDate),
			DATEPART(YYYY,CS.ClmDate),
			VM.RefNo,
			ClmDate,
			CS.FromDate,
			CS.ToDate,
			VM.TotVatTax,		
			VM.RecVatTax,
			CD.ClmPercentage,
			CD.ClmAmount,
			CD.RecommendedAmount,
			'',
			'',
			0,
			P.PrdCCode,
			'',
			0,
			0,
			--VD.InputTax,VD.OutputTax,VD.VatPayTax,
			ROUND(VD.InputTax*(CD.RecommendedAmount/CD.ClmAmount),2),
			ROUND(VD.OutputTax*(CD.RecommendedAmount/CD.ClmAmount),2),
			ROUND(VD.VatPayTax*(CD.RecommendedAmount/CD.ClmAmount),2),
			CS.ClmCode,
			'N'
		FROM VatTaxClaim VM
			INNER JOIN VatTaxClaimDet VD  WITH (NOLOCK) ON VD.SVatNo=VM.SVatNo
			INNER JOIN Company C  WITH (NOLOCK) ON VM.CmpId=C.CmpId
			INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON VM.RefNo=CD.RefCode
			INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 13
			INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=VD.PrdID
		WHERE VM.Status=1 AND VD.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 366)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(366,'D','2011-03-21',getdate(),1,'Core Stocky Service Pack 366')
