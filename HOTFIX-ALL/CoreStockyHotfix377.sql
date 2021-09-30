--[Stocky HotFix Version]=377
Delete from Versioncontrol where Hotfixid='377'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('377','2.0.0.5','D','2011-05-13','2011-05-13','2011-05-13',convert(varchar(11),getdate()),'Parle;Major:-J&J Changes;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 377' ,'377'
GO

--SRF-Nanda-237-001

if exists (select * from dbo.sysobjects where id = object_id(N'[ClaimFreePrdSettlement]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ClaimFreePrdSettlement]
GO

CREATE TABLE [dbo].[ClaimFreePrdSettlement]
(
	[SettlementNo] [nvarchar](200) NOT NULL,
	[SettlementDate] [datetime] NULL,
	[CmpInvNo] [nvarchar](200) NOT NULL,
	[CmpInvDate] [datetime] NOT NULL,
	[ClaimSheetNo] [nvarchar](200) NOT NULL,
	[ClaimRefNo] [nvarchar](200) NOT NULL,
	[CreditNoteNo] [nvarchar](100) NOT NULL,
	[CreditNoteDate] [datetime] NOT NULL,
	[CreditNoteAmt] [numeric](38, 6) NOT NULL,
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[Qty] [numeric](38, 0) NOT NULL,
	[Rate] [numeric](38, 6) NOT NULL,
	[Amount] [numeric](38, 6) NOT NULL,
	[Status] [int] NOT NULL,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

--SRF-Nanda-237-002

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_ClaimFreePrdSettlement]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_ClaimFreePrdSettlement]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_ClaimFreePrdSettlement]
(
	[DistCode] [nvarchar](50) NULL,
	[CmpInvNo] [nvarchar](200) NULL,
	[CmpInvDate] [datetime] NULL,
	[ClaimSheetNo] [nvarchar](200) NULL,
	[ClaimRefNo] [nvarchar](200) NULL,
	[CreditNoteNo] [nvarchar](100) NULL,	
	[CreditNoteDate] [datetime] NULL,
	[CreditNoteAmt] [numeric](38, 6) NULL,
	[PrdCCode] [nvarchar](100) NULL,	
	[PrdBatCode] [nvarchar](100) NULL,	
	[Qty] [numeric](38,0) NULL,
	[Rate] [numeric](38, 6) NULL,
	[Amount] [numeric](38, 6) NULL,
	[Status] [nvarchar](100) NULL,
	[DownLoadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-237-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_ClaimFreePrdSettlement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_ClaimFreePrdSettlement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Import_ClaimFreePrdSettlement '<Root></Root>'

CREATE   PROCEDURE [dbo].[Proc_Import_ClaimFreePrdSettlement]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_ClaimFreePrdSettlement
* PURPOSE		: To Insert the records from xml file in the Table Claim Free Product Settlement
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/05/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Cn2Cs_Prk_ClaimFreePrdSettlement(DistCode,CmpInvNo,CmpInvDate,ClaimSheetNo,ClaimRefNo,CreditNoteNo,
	CreditNoteDate,CreditNoteAmt,PrdCCode,PrdBatCode,Qty,Rate,Amount,Status,DownLoadFlag)
	SELECT DistCode,CmpInvNo,CmpInvDate,ClaimSheetNo,ClaimRefNo,CreditNoteNo,
	CreditNoteDate,CreditNoteAmt,PrdCCode,PrdBatCode,Qty,Rate,Amount,Status,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2CS_ClaimFreePrdSettlement',1)
	WITH (
				[DistCode]				NVARCHAR(50),
				[CmpInvNo]				NVARCHAR(200),
				[CmpInvDate]			DATETIME,
				[ClaimSheetNo]			NVARCHAR(200),
				[ClaimRefNo]			NVARCHAR(200),
				[CreditNoteNo]			NVARCHAR(100),
				[CreditNoteDate]		DATETIME,
				[CreditNoteAmt]			NUMERIC(38,6),
				[PrdCCode]				NVARCHAR(200),
				[PrdBatCode]			NVARCHAR(200),
				[Qty]					NUMERIC(38,0),
				[Rate]					NUMERIC(38,6),
				[Amount]				NUMERIC(38,6),
				[Status]				NUMERIC(38,6),			
				[DownLoadFlag]			NVARCHAR(10)
	     ) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-237-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClaimFreePrdSettlement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClaimFreePrdSettlement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
DELETE FROM ErrorLog
--SELECT * FROM Cn2Cs_Prk_ClaimFreePrdSettlement
--UPDATE Cn2Cs_Prk_ClaimFreePrdSettlement SET ClaimRefNo='SCH1000379' WHERE ClaimRefNo='SCH1000418'
EXEC Proc_Cn2Cs_ClaimFreePrdSettlement 0
SELECT * FROM ErrorLog
--SELECT * FROM Cn2Cs_Prk_ClaimFreePrdSettlement
--SELECT * FROM ClaimSheetDetail
--SELECT * FROM ClaimSheetHd
SELECT * FROM StockLedger WHERE TransDate='2011-05-12'
SELECT * FROM CreditNoteSupplier
--SELECT * FROM ClaimFreePrdSettlement
--SELECT * FROM ProductBatchLOcation WHERE PrdBatId=1120
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ClaimFreePrdSettlement]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClaimFreePrdSettlement
* PURPOSE		: To Download the Claim Free Product Settlement details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/05/2011
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
	DECLARE @CrNoteDate			DATETIME
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
	DECLARE @CrNoteAmount		NUMERIC(38,6)
	DECLARE @CmpId				INT
	DECLARE @VocNo				NVARCHAR(500)

	DECLARE @ClaimSheetNo		NVARCHAR(500)
	DECLARE @CmpInvNo			NVARCHAR(500)
	DECLARE @CmpInvDate			DATETIME
	DECLARE @Status				NVARCHAR(100)
	DECLARE @SettlementNo		NVARCHAR(500)
	DECLARE @PrdId				INT
	DECLARE @PrdBatId			INT
	DECLARE @LcnId				INT
	DECLARE @Qty				INT
	DECLARE @Date				DATETIME
	DECLARE @Po_StkPosting		INT 
	

	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimFreePrdSettleToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimFreePrdSettleToAvoid	
	END
	CREATE TABLE ClaimFreePrdSettleToAvoid
	(
		ClaimSheetNo NVARCHAR(50),
		ClaimRefNo	 NVARCHAR(50),
		CreditNoteNo NVARCHAR(50)
	)
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')='')
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','ClaimRefNo','Claim Ref No should not be empty for :'+CreditNoteNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE ISNULL(CmpInvNo,'')='' OR ISNULL(CmpInvDate,'')='')
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CmpInvNo,'')='' OR ISNULL(CmpInvDate,'')=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','CmpInvNo','Company Inv No/Date should not be empty for :'+CreditNoteNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CmpInvNo,'')='' OR ISNULL(CmpInvDate,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE CreditNoteAmt<0)
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE CreditNoteAmt<0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Amount','Amount should be greater than zero for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE CreditNoteAmt<0
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE ISNULL(CreditNoteNo,'')='')
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CreditNoteNo,'')=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Credit Note No','Credit Note No should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CreditNoteNo,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE ISNULL(CreditNoteDate,'')='')
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CreditNoteDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Date','Date should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CreditNoteDate,'')=''
	END

	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
	(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId AND B.SelectMode=1))
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','ClaimRefNo','Claim Reference Number :'+ClaimRefNo+'does not exists'
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)
	END

	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT DISTINCT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)

		SELECT DISTINCT 1,'Claim Free Product Settlement','Product','Product:'+PrdCCode+' Not Available for Claim:'+ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)

		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Claim Free Product Settlement',ClaimRefNo,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
	END

	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE PrdCCode+'~'+PrdBatCode
	NOT IN
	(SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId))
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT DISTINCT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode+'~'+PrdBatCode
		NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Product Batch','Product Batch:'+PrdBatCode+'Not Available for Product:'+PrdCCode+' in Claim:'+ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode+'~'+PrdBatCode
		NOT IN
		(SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)

		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Claim Free Product Settlement',ClaimRefNo,'Product Batch',PrdCCode,PrdBatCode,'N' FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode+'~'+PrdBatCode
		NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
	END

	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1

	SET @Date=CONVERT(NVARCHAR(10),GETDATE(),121)

	DECLARE Cur_ClaimSettlement CURSOR	
	FOR SELECT ISNULL(CmpInvNo,''),ISNULL(CmpInvDate,GETDATE()),ISNULL([ClaimSheetNo],''),ISNULL([ClaimRefNo],''),ISNULL([CreditNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CreditNoteDate],121),CAST(ISNULL([CreditNoteAmt],0)AS NUMERIC(38,6)),ISNULL(Status,'Partial')
	FROM Cn2Cs_Prk_ClaimFreePrdSettlement WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CreditNoteNo NOT IN
	(SELECT ClaimRefNo+'~'+CreditNoteNo FROM ClaimFreePrdSettleToAvoid)	
	OPEN Cur_ClaimSettlement
	FETCH NEXT FROM Cur_ClaimSettlement INTO @CmpInvNo,@CmpInvDate,@ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@CrNoteDate,@CrNoteAmount,@Status
	WHILE @@FETCH_STATUS=0
	BEGIN
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
			INSERT INTO Errorlog VALUES (8,'Claim Free Product Settlement','Supplier',@ErrDesc)
			SET @Po_ErrNo=1	
		END
		
		IF @Po_ErrNo=0
		BEGIN		
			SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteSupplier','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SELECT @SettlementNo=dbo.Fn_GetPrimaryKeyString('ClaimFreePrdSettlement','SettlementNo',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))

			INSERT INTO CreditNoteSupplier(CrNoteNumber,CrNoteDate,SpmId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
			PostedFrom,TransId,PostedRefNo,CrNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			VALUES(@CreditNo,@CrNoteDate,@SpmId,@AccCoaId,9,@CrNoteAmount,0,1,@ClmGroupNumber,16,
			'Cmp-'+@CreditNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')

			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteSupplier' AND Fldname = 'CrNoteNumber'

			INSERT INTO ClaimFreePrdSettlement(SettlementNo,SettlementDate,CmpInvNo,CmpInvDate,ClaimSheetNo,ClaimRefNo,CreditNoteNo,CreditNoteDate,
			CreditNoteAmt,PrdId,PrdBatId,Qty,Rate,Amount,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT @SettlementNo,CONVERT(NVARCHAR(10),GETDATE(),121),@CmpInvNo,@CmpInvDate,@ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@CrNoteDate,
			@CrNoteAmount,P.PrdId,PB.PrdBatId,Prk.Qty,Prk.Rate,Prk.Amount,(CASE Prk.Status WHEN 'Settled' THEN 1 ELSE 0 END),
			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
			FROM Cn2Cs_Prk_ClaimFreePrdSettlement Prk,Product P,ProductBatch PB
			WHERE P.PrdId=PB.PrdId AND P.PrdCCOde=Prk.PrdCCOde AND PB.PrdBatCode=Prk.PrdBatCode AND Prk.CmpInvNo=@CmpInvNo AND
			ClaimSheetNo=@ClaimSheetNo AND ClaimRefNo=@ClaimNumber

			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'ClaimFreePrdSettlement' AND Fldname = 'SettlementNo'

			DECLARE Cur_ClaimSettlementPrd CURSOR	
			FOR SELECT P.PrdId,PB.PrdBatId,Prk.Qty
			FROM Cn2Cs_Prk_ClaimFreePrdSettlement Prk,Product P,ProductBatch PB
			WHERE P.PrdId=PB.PrdId AND P.PrdCCOde=Prk.PrdCCOde AND PB.PrdBatCode=Prk.PrdBatCode AND Prk.CmpInvNo=@CmpInvNo AND
			ClaimSheetNo=@ClaimSheetNo AND ClaimRefNo=@ClaimNumber AND DownLoadFlag='D'
			OPEN Cur_ClaimSettlementPrd
			FETCH NEXT FROM Cur_ClaimSettlementPrd INTO @PrdId,@PrdBatId,@Qty
			WHILE @@FETCH_STATUS=0
			BEGIN
				Exec Proc_UpdateStockLedger 12,1,@PrdId,@PrdBatId,@LcnId,@Date,@Qty,1,@Pi_ErrNo = @Po_StkPosting OUTPUT

				IF @Po_StkPosting = 0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 3,1,@PrdId,@PrdBatId,@LcnId,@Date,@Qty,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				END

				FETCH NEXT FROM Cur_ClaimSettlementPrd INTO @PrdId,@PrdBatId,@Qty
			END
			CLOSE Cur_ClaimSettlementPrd
			DEALLOCATE Cur_ClaimSettlementPrd

			UPDATE ClaimSheetDetail SET ReceivedAmount=ReceivedAmount+@CrNoteAmount,CrDbmode=2,CrDbStatus=1,CrDbNotenumber=@CreditNo,Status=2
			WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

			UPDATE Cn2Cs_Prk_ClaimFreePrdSettlement SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber AND ClaimSheetNo=@ClaimSheetNo			
		END

		FETCH NEXT FROM Cur_ClaimSettlement INTO @CmpInvNo,@CmpInvDate,@ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@CrNoteDate,@CrNoteAmount,@Status
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

--SRF-Nanda-237-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ComputeTax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ComputeTax]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     Procedure [dbo].[Proc_ComputeTax]      
(      
 @Pi_RowId  INT,      
 @Pi_CalledFrom  INT,        
 @Pi_UserId  INT      
      
)      
AS      
/*********************************      
* PROCEDURE : Proc_ComputeTax      
* PURPOSE : To Calculate the Line Level Tax      
* CREATED : Thrinath      
* CREATED DATE : 22/03/2007      
* MODIFIED
* DATE      AUTHOR     DESCRIPTION 
24/05/2009	MURUGAN	   OID CalCulation For Nestle	
------------------------------------------------      
* {date} {developer}  {brief modification description}            
       
@Pi_CalledFrom  2  For Sales      
@Pi_CalledFrom  3  For Sales Return       
@Pi_CalledFrom  5  For Purchase      
@Pi_CalledFrom  7  For Purchase Return      
@Pi_CalledFrom  20 For Replacement      
@Pi_CalledFrom  23  For Market Return       
@Pi_CalledFrom  24 For Return And Replacement      
@Pi_CalledFrom  25 For Sales Panel      
      
*********************************/       
SET NOCOUNT ON      
BEGIN      
	DECLARE @PrdBatTaxGrp   INT      
	DECLARE @RtrTaxGrp   INT      
	DECLARE @TaxSlab  INT      
	DECLARE @MRP   NUMERIC(28,10)      
	DECLARE @SellingRate  NUMERIC(28,10)      
	DECLARE @PurchaseRate  NUMERIC(28,10)      
	DECLARE @TaxableAmount  NUMERIC(28,10)      
	DECLARE @ParTaxableAmount NUMERIC(28,10)      
	DECLARE @TaxPer   NUMERIC(38,6)      
	DECLARE @TaxId   INT      
	DECLARE	@ApplyOn INT

	DECLARE @TaxSetting TABLE       
	(      
		TaxSlab   INT,      
		ColNo   INT,      
		SlNo   INT,      
		BillSeqId  INT,      
		TaxSeqId  INT,      
		ColType   INT,       
		ColId   INT,      
		ColVal   NUMERIC(38,6)      
	)      
      
	--To Take the Batch TaxGroup Id      
	SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) INNER JOIN      
	BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
	AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      

	--To Take the Batch MRP      
	SELECT @MRP = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
	BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
	AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
	INNER JOIN ProductBatchDetails C (NOLOCK)      
	ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
	INNER JOIN BatchCreation D (NOLOCK)      
	ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
	AND D.MRP = 1       
      
	--To Take the Batch Selling Rate      
	IF @Pi_CalledFrom = 2 OR @Pi_CalledFrom = 25 OR @Pi_CalledFrom = 3 OR @Pi_CalledFrom = 23      
	BEGIN      
		SELECT @SellingRate = ColValue FROM BilledPrddtForTax WHERE TransId = @Pi_CalledFrom       
		AND UsrId = @Pi_UserId AND RowId = @Pi_RowId AND ColId = -2      
	END      
	ELSE      
	BEGIN      
		IF @Pi_CalledFrom = 20
		BEGIN 
			SELECT @SellingRate = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
			BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
			INNER JOIN ProductBatchDetails C (NOLOCK)      
			ON A.PrdBatId = C.PrdBatID AND C.PriceId IN (SELECT max(PBD.priceid) FROM productbatchdetails PBD WHERE pbd.prdbatid=b.PrdBatId)    
			INNER JOIN BatchCreation D (NOLOCK)      
			ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
			AND D.SelRte = 1      
		END      
		ELSE      
		BEGIN      
			SELECT @SellingRate = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
			BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
			INNER JOIN ProductBatchDetails C (NOLOCK)      
			ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
			INNER JOIN BatchCreation D (NOLOCK)      
			ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
			AND D.SelRte = 1      
		END      
	END 

	--To Take the Batch List Price 
	--Added by Murugan For OID Calculation
	IF (@Pi_CalledFrom = 5 OR @Pi_CalledFrom = 7 OR @Pi_CalledFrom = 37)
	BEGIN   
		IF  EXISTS(SELECT Status FROM Configuration WHERE ModuleId = 'PURCHASERECEIPT16' and Status=1)   
		BEGIN  
			SELECT  @PurchaseRate = Isnull(ColValue,0) FROM BilledPrdDtForTax B  
			WHERE  B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom 
			and COLID=3	   
		END  
		ELSE  
		BEGIN 
			SELECT @PurchaseRate =ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
			BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
			INNER JOIN ProductBatchDetails C (NOLOCK)      
			ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
			INNER JOIN BatchCreation D (NOLOCK)      
			ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
			AND D.ListPrice = 1     
		END  

		--->Added By Nanda on 2011/05/12
		IF @Pi_CalledFrom = 37
		BEGIN
			IF EXISTS(SELECT * FROM CONFIGURATION WHERE MODULEID='RTNTOCOMPANY7' AND Status=1)
			BEGIN
				SELECT @PurchaseRate =ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
				BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
				AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
				INNER JOIN ProductBatchDetails C (NOLOCK)      
				ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
				INNER JOIN BatchCreation D (NOLOCK)      
				ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
				AND LTRIM(RTRIM(D.RefCode)) IN (SELECT LEFT(Condition,1) FROM CONFIGURATION WHERE MODULEID='RTNTOCOMPANY7' AND Status=1)
			END
		END
		--->Till Here
	END
	ELSE
	BEGIN
		SELECT @PurchaseRate =ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
		BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
		AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
		INNER JOIN ProductBatchDetails C (NOLOCK)      
		ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
		INNER JOIN BatchCreation D (NOLOCK)      
		ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
		AND D.ListPrice = 1  
	END
      
	IF (@Pi_CalledFrom = 2 OR @Pi_CalledFrom = 3 OR @Pi_CalledFrom = 20 OR @Pi_CalledFrom = 23 OR       
	@Pi_CalledFrom = 24 OR @Pi_CalledFrom = 25)      
	BEGIN      
		--To Take the Retailer TaxGroup Id      
		SELECT @RtrTaxGrp = TaxGroupId FROM Retailer A (NOLOCK) INNER JOIN      
		BilledPrdHdForTax B (NOLOCK) On A.RtrId = B.RtrId      
		AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId       
		AND B.TransId = @Pi_CalledFrom      
	END      

	IF (@Pi_CalledFrom = 5 OR @Pi_CalledFrom = 7 OR @Pi_CalledFrom = 37)      
	BEGIN      
		--To Take the Supplier TaxGroup Id      
		SELECT @RtrTaxGrp = TaxGroupId FROM Supplier A (NOLOCK) INNER JOIN      
		BilledPrdHdForTax B (NOLOCK) On A.SpmId = B.RtrId      
		AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId      
		AND B.TransId = @Pi_CalledFrom      
	END      
       
	--Store the Tax Setting for the Corresponding Retailer and Batch      
	INSERT INTO @TaxSetting (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
	SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
	FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
	TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
	INNER JOIN BilledPrdHdForTax C (NOLOCK) ON C.BillSeqId = B.BillSeqId      
	WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp AND C.UsrId = @Pi_UserId      
	AND C.RowId = @Pi_RowId AND C.TransId = @Pi_CalledFrom      
	AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
	RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)    
    
	--Delete the OLD Details From the BilledPrdDtCalculatedTax For the Row and User      
	DELETE FROM BilledPrdDtCalculatedTax WHERE RowId = @Pi_RowId AND UsrId = @Pi_UserId       
	AND TransId = @Pi_CalledFrom      

	--Cursor For Taking Each Slab and Calculate Tax      
	DECLARE  CurTax CURSOR FOR      
	SELECT DISTINCT TaxSlab FROM @TaxSetting      
	OPEN CurTax        
	FETCH NEXT FROM CurTax INTO @TaxSlab      
      
	WHILE @@FETCH_STATUS = 0        
	BEGIN      

		SET @TaxableAmount = 0      
		--To Filter the Records Which Has Tax Percentage (>=0)      
		IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0 and ColVal >= 0)      
		BEGIN
			--To Get the Tax Percentage for the selected slab      
			SELECT @TaxPer = ColVal FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1      
			AND ColId = 0      

			--To Get the TaxId for the selected slab      
			SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1      
			AND ColId > 0      
	         
			--To Get the Adjustable amount from Other Columns      
			SELECT @TaxableAmount = ISNULL(SUM(ColValue),0) FROM       
			(SELECT CASE B.ColVal WHEN 1 THEN A.ColValue WHEN 2 THEN -1 * A.ColValue END       
			AS ColValue FROM BilledPrdDtForTax A INNER JOIN @TaxSetting B      
			ON A.ColId = B.ColId AND A.RowId =  @Pi_RowId AND A.UsrId = @Pi_UserId       
			AND A.TransId = @Pi_CalledFrom      
			WHERE TaxSlab = @TaxSlab AND B.ColType = 2 and B.ColId>3      
			And B.ColVal >0) as C      

			SET @ApplyOn=0

			--To add MRP to Taxable Amount if MRP Is Selected for the Slab      
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2      
			AND ColId = 1 and ColVal > 0)       
			BEGIN
				SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP      
				SET @ApplyOn=1 
			END

			--To add Selling Rate to Taxable Amount if Selling Rate Is Selected for the Slab      
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2      
			AND ColId = 2 and ColVal > 0)       
			SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @SellingRate      
	      
			--To add Purchase Rate to Taxable Amount if Purchase Rate Is Selected for the Slab      
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2      
			AND ColId = 3 and ColVal > 0)       
			SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @PurchaseRate      

			--To Get the Parent Taxable Amount for the Tax Slab      
			SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM BilledPrdDtCalculatedTax A      
			INNER JOIN @TaxSetting B ON A.TaxId = B.ColVal AND A.RowId = @Pi_RowId      
			AND A.UsrId = @Pi_UserId AND B.ColType = 3 AND B.TaxSlab = @TaxSlab      
			AND A.TransId = @Pi_CalledFrom      

			Set @TaxableAmount = @TaxableAmount + @ParTaxableAmount      
	      
			--Insert the New Tax Amounts        
			INSERT INTO BilledPrdDtCalculatedTax (RowId,PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,      
			TaxableAmount,TaxAmount,Usrid,TransId)      
			SELECT @Pi_RowId,B.PrdId,B.PrdBatId,@TaxId,@TaxSlab,@TaxPer,      
		    @TaxableAmount, CASE @ApplyOn 
			WHEN 0 THEN	cast(@TaxableAmount * (@TaxPer / 100 ) AS NUMERIC(38,6))
			WHEN 1 THEN cast(@TaxableAmount * (@TaxPer / (100 +@TaxPer)) AS NUMERIC(38,6)) END,      
			@Pi_UserId,@Pi_CalledFrom FROM BilledPrdHdForTax B (NOLOCK) WHERE       
			B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
		END      
		FETCH NEXT FROM CurTax INTO @TaxSlab      
	END        
	CLOSE CurTax        
	DEALLOCATE CurTax           
END      

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-237-006

IF NOT EXISTS(SELECT * FROM Counters WHERE TabName='ClaimFreePrdSettlement')
BEGIN
	INSERT INTO Counters(TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,
	Availability,LastModBy,LastModDate,AuthId,AuthDate)
	VALUES('ClaimFreePrdSettlement','SettlementNo','CFS',5,1,0,'Claim',1,2011,1,1,GETDATE(),1,GETDATE())
END
GO

--SRF-Nanda-237-007

DELETE FROM CustomCaptions WHERE TransId=268

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,1,1,'CoreHeaderTool','Free Product Settlement','','',1,1,1,GETDATE(),1,GETDATE(),'Free Product Settlement','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,1,2,'CoreHeaderTool','Stocky','','',1,1,1,GETDATE(),1,GETDATE(),'Stocky','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,2,1,'lblSettlementNo','Settlement No...','','',1,1,1,GETDATE(),1,GETDATE(),'Settlement No...','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,3,1,'lblSettlementDate','Settlement Date','','',1,1,1,GETDATE(),1,GETDATE(),'Settlement Date','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,4,1,'lblCmpInvNo','Company Inv No','','',1,1,1,GETDATE(),1,GETDATE(),'Company Inv No','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,5,1,'lblCmpInvDate','Company Inv Date','','',1,1,1,GETDATE(),1,GETDATE(),'Company Inv Date','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,6,1,'lblClaimSheetNo','Claim Sheet No','','',1,1,1,GETDATE(),1,GETDATE(),'Claim Sheet No','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,7,1,'lblClaimRefNo','Claim Ref No','','',1,1,1,GETDATE(),1,GETDATE(),'Claim Ref No','','',1,1)


INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,1,'DgCommon-268-8-1','Credit Note No','','',1,1,1,GETDATE(),1,GETDATE(),'Credit Note No','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,2,'DgCommon-268-8-2','Credit Note Date','','',1,1,1,GETDATE(),1,GETDATE(),'Credit Note Date','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,3,'DgCommon-268-8-3','Credit Note Amt','','',1,1,1,GETDATE(),1,GETDATE(),'Credit Note Amt','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,5,'DgCommon-268-8-5','Product Code','','',1,1,1,GETDATE(),1,GETDATE(),'Product Code','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,6,'DgCommon-268-8-6','Product Name','','',1,1,1,GETDATE(),1,GETDATE(),'Product Name','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,8,'DgCommon-268-8-8','Batch Code','','',1,1,1,GETDATE(),1,GETDATE(),'Batch Code','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,9,'DgCommon-268-8-9','Qty','','',1,1,1,GETDATE(),1,GETDATE(),'Qty','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,10,'DgCommon-268-8-10','Rate','','',1,1,1,GETDATE(),1,GETDATE(),'Rate','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(268,8,11,'DgCommon-268-8-11','Amt','','',1,1,1,GETDATE(),1,GETDATE(),'Amt','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES(268,9,0,'btnOperation','&New','','',1,1,1,GETDATE(),1,GETDATE(),'&New','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES(268,9,1,'btnOperation','&Edit','','',1,1,1,GETDATE(),1,GETDATE(),'&Edit','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES(268,9,2,'btnOperation','&Save','','',1,1,1,GETDATE(),1,GETDATE(),'&Save','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES(268,9,3,'btnOperation','&Delete','','',1,1,1,GETDATE(),1,GETDATE(),'&Delete','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES(268,9,4,'btnOperation','&Cancel','','',1,1,1,GETDATE(),1,GETDATE(),'&Cancel','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES(268,9,5,'btnOperation','E&xit','','',1,1,1,GETDATE(),1,GETDATE(),'E&xit','','',1,1)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES(268,9,6,'btnOperation','&Print','','',1,1,1,GETDATE(),1,GETDATE(),'&Print','','',1,1)

--SRF-Nanda-237-008

IF NOT EXISTS(SELECT * FROM menuDef where MenuName='mnuClaimFreePrdSettlement' and ParentId='mClm')
BEGIN
	Declare @Srno as Int
	Declare @menuId as Varchar(50)
	Declare @Srno1 as Int
	Declare @maxrow as int
	Declare @OldSrNo as int
	Declare @Newmaxrow as int
	Select TOP 1 @Srno= Srlno from MenuDef  where MenuId like 'mClm%' Order by Srlno Desc
	SET @Srno1=@Srno+1
	select @maxrow=Max(srlNo) from Menudef
	set @Newmaxrow=@maxrow+1
	set @OldSrNo= @maxrow
	While @Srno<=@maxrow
	begin	
		
		Update Menudef set Srlno=@Newmaxrow where srlno=@OldSrNo
		set @Newmaxrow= @Newmaxrow -1
		Set @OldSrNo=@OldSrNo-1
		Set @Srno=@Srno+1

	End

	SET @menuId= 'mClm'+Cast(@Srno1 as Varchar(5))
	DELETE FROM Menudef WHERE MenuId=@menuId

	INSERT INTO Menudef (SrlNo,MenuId,MenuName,ParentId,Caption,MenuStatus,FormName) 
	VALUES (@Srno1,@menuId,'mnuClaimFreePrdSettlement','mClm','Free Product Settlement',0,'frmClaimSettlement')


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
	VALUES(1,@menuId,6,'Print',0,1,1,GETDATE(),1,GETDATE())


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
	VALUES(2,@menuId,6,'Print',0,1,1,GETDATE(),1,GETDATE())

END
GO

--UPDATE ProfileDt SET BtnStatus=0 WHERE PrfId=2 AND MenuId='mClm169'

if not exists (select * from hotfixlog where fixid = 377)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(377,'D','2011-05-13',getdate(),1,'Core Stocky Service Pack 377')
