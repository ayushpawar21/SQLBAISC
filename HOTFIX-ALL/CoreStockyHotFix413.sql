--[Stocky HotFix Version]=413
DELETE FROM Versioncontrol WHERE Hotfixid='413'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('413','3.1.0.0','D','2014-03-28','2014-03-28','2014-03-28',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
IF NOT EXISTS (SELECT * FROM Syscolumns A WITH(NOLOCK),Sysobjects B WITH(NOLOCK) WHERE A.id = B.id AND B.XTYPE = 'U' 
AND B.name = 'ETLTempPurchaseReceiptCrDbAdjustments' AND A.name = 'DownloadStatus')
BEGIN
   ALTER TABLE ETLTempPurchaseReceiptCrDbAdjustments ADD DownloadStatus INT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT * FROM SyncStatus)
BEGIN
	INSERT INTO SyncStatus (DistCode,SyncId,DPStartTime,DPEndTime,UpStartTime,UpEndTime,DwnStartTime,DwnEndTime,SyncStatus,SyncFlag)
	SELECT DistributorCode,1,GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),0,'N' FROM Distributor
END
GO
DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG35'
INSERT INTO Configuration
SELECT 'GENCONFIG35','General Configuration','Search by any character in Hotsearch Screen',0,'',0.00,35
GO
DELETE FROM CustomCaptions WHERE TransId = 2 AND CtrlId = 2000 AND SubCtrlId IN (12,13) AND CtrlName IN ('HotSch-2-2000-12','HotSch-2-2000-13')
INSERT INTO CustomCaptions
SELECT 2,2000,12,'HotSch-2-2000-12','Salesman Code','','',1,1,1,GETDATE(),1,GETDATE(),'Salesman Code','','',1,1 UNION
SELECT 2,2000,13,'HotSch-2-2000-13','Salesman Name','','',1,1,1,GETDATE(),1,GETDATE(),'Salesman Name','','',1,1
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
--CK Changes Script
IF NOT EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.ID=SC.ID
WHERE S.NAME='SalesInvoice' AND SC.NAME='SaldlvDateWithTime')
BEGIN
	ALTER TABLE SalesInvoice ADD SaldlvDateWithTime DATETIME  
END
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'ETLTempPurchaseReceiptProduct' 
AND ID IN (SELECT ID FROM Syscolumns WHERE name = 'AddDiscAmt'))
BEGIN
   ALTER TABLE ETLTempPurchaseReceiptProduct ADD AddDiscAmt NUMERIC(18,6)
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='ClaimSheetInvoiceWiseDetails')
BEGIN
CREATE TABLE [ClaimSheetInvoiceWiseDetails](
	[ClmId] [int] NOT NULL,
	[ClmCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ClmDesc] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ClmDate] [datetime] NOT NULL,
	[FromDate] [datetime] NOT NULL,
	[Todate] [datetime] NOT NULL,
	[CmpId]		INT,
	[Schcode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CmpSchCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchDsc] [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Salid] [bigint] NOT NULL,
	[BillNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BillDate] [datetime] NOT NULL,
	[Rtrcode] [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Retailer] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Prdccode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProductName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GrossAmount] [numeric](38, 6) NULL,
	[Discounts] [numeric](38, 6) NULL,
	[ApportionFreeValue] [numeric](38, 6) NULL,	
	[Upload] [int] NOT NULL
) ON [PRIMARY]
END
GO
UPDATE SalesInvoice SET SaldlvDateWithTime=GETDATE() WHERE SaldlvDateWithTime IS NULL
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'NoofRetailers' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='SchemeMaster'))
BEGIN
	ALTER TABLE SchemeMaster ADD NoofRetailers INT NOT NULL DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'RtrCount' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='SchemeMaster'))
BEGIN
	ALTER TABLE SchemeMaster ADD RtrCount INT NOT NULL DEFAULT 0 WITH VALUES
END
GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Fn_ReturnSchemeProductWithSlabWise]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Fn_ReturnSchemeProductWithSlabWise]
GO
--SELECT DBO.Fn_ReturnSchemeProductWithSlabWise(66)
CREATE   FUNCTION [dbo].[Fn_ReturnSchemeProductWithSlabWise](@Pi_SchId INT)
RETURNS VARCHAR(8000)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnSchemeProductWithSlabWise
* PURPOSE: Returns the Scheme Product with Salb Wise
* NOTES: 
* CREATED: Boopathy.P    15/11/2010
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 

*********************************/
	DECLARE @CntVal AS INT
	DECLARE @sSQL AS VARCHAR(8000)
	DECLARE @MaxSchLevelId  INT
	DECLARE @SchLevelId  INT
	DECLARE @TempStr AS VARCHAR(8000)
	DECLARE @TempStr1 AS VARCHAR(8000)

	SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE SchId=@Pi_SchId

	SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=1

	IF @MaxSchLevelId=@SchLevelId
	BEGIN
		SET @CntVal=0
	END
	ELSE
	BEGIN
		SET @CntVal=1
	END
	SET @sSQL=''
	SET @TempStr=''
	SET @TempStr1=''
	IF @CntVal=(@MaxSchLevelId-@SchLevelId)
	BEGIN
		SET @sSQL='SELECT S.SchId,S.SlabId,A.PrdId,A.PrdCCode,A.PrdName,A.PrdctgValMainId FROM Product A INNER JOIN SchemeSlabCombiPrds S 
				   ON A.PrdId=S.PrdId WHERE SchId=''' +  CAST(@Pi_SchId AS VARCHAR(10)) + ''''
	END
	ELSE
	BEGIN
		WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
		BEGIN
			IF @CntVal=1
			BEGIN
				SET @sSQL='SELECT DISTINCT B.SchId,B.SlabId,A.PrdId,A.PrdCCode,A.PrdName,A.PrdctgValMainId FROM Product A CROSS JOIN SchemeSlabCombiPrds B 
							WHERE B.SchId=''' + CAST(@Pi_SchId AS VARCHAR(10)) + ''' AND A.PrdctgValMainId IN('
			END

				SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
				SET @TempStr1=@TempStr1+ ')'
				SET @CntVal=@CntVal+1	
			IF @CntVal=(@MaxSchLevelId-@SchLevelId)
			BEGIN
				SET @sSQL=@sSQL + @TempStr +'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeSlabCombiPrds S INNER JOIN
				ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=''' + CAST(@Pi_SchId AS VARCHAR(10)) + ''')'+@TempStr1
				
			END
			
		END	
	END	
	RETURN (@sSQL)		
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fn_ReturnApplicableRetailer]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Fn_ReturnApplicableRetailer]
GO
-- SELECT * FROM DBO.Fn_ReturnApplicableRetailer(5,1,7)  
CREATE  FUNCTION [dbo].[Fn_ReturnApplicableRetailer] (@Pi_SchId AS INT,@Pi_RtrId AS INT,@Pi_SalId AS INT)  
RETURNS @ApplicableRetailer TABLE  
 (  
  SchId    INT ,  
  CheckOption   INT,  
  RealCount   INT,  
  NoofTimesApplied INT   
 )  
AS  
/*********************************  
* FUNCTION: [Fn_ReturnApplicableRetailer]  
* PURPOSE: Return No of times retailer applied for particular scheme  
* NOTES:  
* CREATED: Boopathy.P 0n 02-02-2012  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
BEGIN  
 INSERT INTO @ApplicableRetailer  
 SELECT A.SchId,A.NoofRetailers,A.RtrCount,COUNT(DISTINCT B.SalId) FROM  SalesInvoice B   
 INNER JOIN SalesInvoiceSchemeLineWise C ON B.SalId=C.SalId  
 INNER JOIN SchemeMaster A  ON A.SchId=C.SchId  
 WHERE A.NoofRetailers=1 AND A.RtrCount>0 AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId AND B.SalId<>@Pi_SalId AND B.DlvSts <>3
 GROUP BY  A.SchId,A.NoofRetailers,A.RtrCount   
 UNION  
 SELECT A.SchId,A.NoofRetailers,A.RtrCount,COUNT(DISTINCT B.SalId) FROM  SalesInvoice B   
 INNER JOIN SalesInvoiceSchemeDtFreePrd C ON B.SalId=C.SalId  
 INNER JOIN SchemeMaster A  ON A.SchId=C.SchId  
 WHERE A.NoofRetailers=1 AND A.RtrCount>0 AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId AND B.SalId<>@Pi_SalId AND B.DlvSts <>3
 GROUP BY  A.SchId,A.NoofRetailers,A.RtrCount   
RETURN   
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Fn_ReturnPrdBatchDetailsWithActStock' AND XTYPE='TF')
DROP FUNCTION Fn_ReturnPrdBatchDetailsWithActStock
GO
-- SELECT * FROM DBO.Fn_ReturnPrdBatchDetailsWithActStock(2,2,1)
CREATE FUNCTION [Fn_ReturnPrdBatchDetailsWithActStock] (@PrdId AS BIGINT,@PrdBatId AS BIGINT,@LcnId AS	INT)
RETURNS @PrdBatchDetailsWithActStock TABLE
	(
		PrdId		INT,
		PrdBatID	INT,
		StockAvail	NUMERIC(18,0),
		PriceId		INT
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnPrdBatchDetailsWithStock
* PURPOSE: Returns the Product details with stock
* NOTES:
* CREATED: Kar.thick.k.j
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/

		INSERT INTO @PrdBatchDetailsWithActStock
		SELECT PB.PrdId,PB.PrdBatID,(PrdBatLcnSih-PrdBatLcnRessih),PB.DefaultPriceId FROM Product P (NOLOCK) 
		INNER JOIN ProductBatch PB (NOLOCK) on P.PrdId=PB.PrdId
		INNER JOIN ProductBatchLocation PBL on PBL.PrdId=P.PrdId and PBL.PrdId=PB.PrdId and PBL.PrdBatID=PB.PrdBatId
		where PB.PrdId=@PrdId and PB.PrdBatId=@PrdBatId and LcnId = @LcnId 
RETURN
END
GO
DELETE FROM CustomCaptions WHERE TransId=2 AND CtrlId =1000 AND SubCtrlId=264
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES 
(2,1000,264,'MsgBox-2-1000-264','','','Please enter invoice quantity to select TaxDetails',1,1,1,'2012-02-14',1,'2012-02-14','','','Please enter invoice quantity to select TaxDetails',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId=2 AND CtrlId =1000 AND SubCtrlId=265
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES 
(2,1000,265,'MsgBox-2-1000-265','','','No record Found',1,1,1,'2012-02-14',1,'2012-02-14','','','No record Found',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId=23 AND CtrlId =1000 AND SubCtrlId=42
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES 
(23,1000,42,'MsgBox-23-1000-42','','','Please enter invoice quantity to select TaxDetails',1,1,1,'2012-02-14',1,'2012-02-14','','','Please enter invoice quantity to select TaxDetails',1,1)
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='SalesInvoice' AND  ID IN (SELECT ID FROM SYSCOLUMNS WHERE NAME='SalinvDateWithtime'))
BEGIN
     ALTER TABLE SalesInvoice ADD SalinvDateWithtime  DATETIME
END
GO
IF EXISTS(SELECT NAME FROM SysObjects WHERE name='CN2CS_BillPrintMsgHeader' AND XTYPE='U')
DROP TABLE CN2CS_BillPrintMsgHeader
GO
CREATE TABLE CN2CS_BillPrintMsgHeader
(
	DistCode	 NVarChar(100),
	MsgCode		 NVarChar(100),
	MsgDesc		 NVarChar(MAX),
	FromDate	 DATETIME,
	ToDate		 DATETIME,
	DownloadFlag VarChar(1)
)
GO
IF EXISTS(SELECT NAME FROM SysObjects WHERE name='CN2CS_BillPrintMsgDetails' AND XTYPE='U')
DROP TABLE CN2CS_BillPrintMsgDetails
GO
CREATE TABLE CN2CS_BillPrintMsgDetails
(
	DistCode	 NVarChar(100),
	MsgCode		 NVarChar(100),
	[Type]		 NVarChar(100),
	CatLevel	 NVarChar(100),
	CatCode		 NVarChar(100),
	RtrClass	 NVarChar(100),
	RtrCode		 NVarChar(100),
	DownLoadFlag VarChar(1)
)
GO
IF EXISTS(SELECT NAME FROM SysObjects WHERE name='BillPrintMsg' AND XTYPE='U')
DROP TABLE BillPrintMsg
GO
CREATE TABLE BillPrintMsg
(
	SlNo		INT IDENTITY(1,1),
	FromDate	DATETIME,
	ToDate		DATETIME,
	CtgLevel	NVARCHAR(100),
	CtgCode		NVARCHAR(100),
	ValueClass	NVARCHAR(100),
	RtrCode		NVARCHAR(100),
	MsgCode		NVarChar(100),
	[Message]	NVARCHAR(MAX)
)
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE Xtype='P' And NAME='Proc_Import_BillPrintMsgHeader')
DROP PROCEDURE Proc_Import_BillPrintMsgHeader  
GO
CREATE PROCEDURE Proc_Import_BillPrintMsgHeader
(  
 @Pi_Records TEXT  
)  
AS  
SET NOCOUNT ON  
BEGIN  
 DECLARE @hDoc INTEGER  
 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
  
 INSERT INTO CN2CS_BillPrintMsgHeader(DistCode,MsgCode,MsgDesc,FromDate,ToDate,DownloadFlag)  
 SELECT DistCode,MsgCode,MsgDesc,FromDate,ToDate,DownloadFlag
 FROM OPENXML (@hdoc,'/Root/Console2CS_BillPrintMsg_Header',1)  
 WITH   
 (  
		DistCode	 NVarChar(100),
		MsgCode		 NVarChar(100),
		MsgDesc		 NVarChar(MAX),
		FromDate	 DATETIME,
		ToDate		 DATETIME,
		DownloadFlag VarChar(1)
 ) XMLObj  
  
 EXEC sp_xml_removedocument @hDoc  
END  
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE Xtype='P' And NAME='Proc_Import_BillPrintMsgDetails')
DROP PROCEDURE Proc_Import_BillPrintMsgDetails  
GO
CREATE PROCEDURE Proc_Import_BillPrintMsgDetails
(  
 @Pi_Records TEXT  
)  
AS  
SET NOCOUNT ON  
BEGIN  
 DECLARE @hDoc INTEGER  
 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
  
 INSERT INTO CN2CS_BillPrintMsgDetails(DistCode,MsgCode,[Type],CatLevel,CatCode,RtrClass,RtrCode,DownLoadFlag)  
 SELECT DistCode,MsgCode,[Type],CatLevel,CatCode,RtrClass,RtrCode,DownLoadFlag
 FROM OPENXML (@hdoc,'/Root/Console2CS_BillPrintMsg_Details',1)  
 WITH   
 (  
			DistCode	 NVarChar(100),
			MsgCode		 NVarChar(100),
			[Type]		 NVarChar(100),
			CatLevel	 NVarChar(100),
			CatCode		 NVarChar(100),
			RtrClass	 NVarChar(100),
			RtrCode		 NVarChar(100),
			DownLoadFlag VarChar(1)
 ) XMLObj  
  
 EXEC sp_xml_removedocument @hDoc  
END  
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE Xtype='P' And NAME='Proc_Validate_BillPrintMsgDetails')
DROP PROCEDURE Proc_Validate_BillPrintMsgDetails  
GO
--EXEC Proc_Validate_BillPrintMsgDetails 0
CREATE PROCEDURE Proc_Validate_BillPrintMsgDetails
(
@Po_ErrNo AS INT OUTPUT
)
AS
SET NOCOUNT ON
/*************************************************************
* PROCEDURE	: Proc_Validate_BillPrintMsgDetails
* PURPOSE	: To Validate Bill Print Message 
* CREATED BY	: Praveenraj B 
* CREATED DATE	: 22/02/2012
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
		DECLARE @TYPE AS INT
		DECLARE @TableName AS NVarChar(50)
		SET @TableName='CN2CS_BillPrintMsgDetails'

		SELECT RTRCODE INTO #NORETAILER FROM CN2CS_BillPrintMsgDetails CN2CS WHERE NOT EXISTS 
		(SELECT RTRCODE FROM Retailer R WHERE R.RtrCode=CN2CS.RtrCode) AND UPPER([TYPE])=UPPER('Retailer')
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,@TableName,'Retailer Code','RetailerCode:'+RtrCode+'Does Not Exists' FROM #NORETAILER
		
		INSERT INTO BillPrintMsg(FromDate,ToDate,CtgLevel,CtgCode,ValueClass,RtrCode,MsgCode,[Message])
		SELECT CONVERT(VARCHAR(10),HED.FromDate,121) AS FromDate,CONVERT(VARCHAR(10),HED.ToDate,121) AS ToDate,
		'','','',DET.RtrCode,DET.MsgCode,HED.MsgDesc
		FROM CN2CS_BillPrintMsgHeader HED 
		INNER JOIN CN2CS_BillPrintMsgDetails DET ON HED.MsgCode=DET.MsgCode
		WHERE RtrCode NOT IN (SELECT RtrCode FROM #NORETAILER) AND UPPER([TYPE])= UPPER('Retailer')
	
		SELECT CatLevel INTO #NOCatLevel FROM CN2CS_BillPrintMsgDetails CN2CS WHERE NOT EXISTS
		(SELECT CtgLevelName FROM RetailerCategoryLevel RCL WHERE RCL.CtgLevelName=CN2CS.CatLevel) 
		AND UPPER([TYPE]) NOT IN (UPPER('Retailer'))
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,@TableName,'Category Level Name','CategoryLevel:'+CatLevel+'Does Not Exists' FROM #NOCatLevel
		
		SELECT CatCode INTO #NOCategory FROM CN2CS_BillPrintMsgDetails CN2CS WHERE NOT EXISTS
		(SELECT CtgCode FROM RetailerCategory RC WHERE RC.CtgCode=CN2CS.CatCode)
		AND UPPER([TYPE]) NOT IN (UPPER('Retailer'))
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,@TableName,'Category Code','CategoryCode:'+CatCode+'Does Not Exists' FROM #NOCategory	
		
		SELECT RtrClass INTO #NORtrClass FROM CN2CS_BillPrintMsgDetails CN2CS WHERE NOT EXISTS
		(SELECT ValueClassCode FROM RetailerValueClass RV WHERE RV.ValueClassCode=CN2CS.RtrClass)
		AND UPPER([TYPE]) NOT IN (UPPER('Retailer'))
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,@TableName,'ValueClassCode','ValueClass:'+RtrClass+'Does Not Exists' FROM #NORtrClass
		
		--SELECT RTRCODE INTO #NORETAILER1 FROM CN2CS_BillPrintMsgDetails CN2CS WHERE NOT EXISTS 
		--(SELECT RTRCODE FROM Retailer R WHERE R.RtrCode=CN2CS.RtrCode)
		--AND UPPER([TYPE]) NOT IN (UPPER('Retailer'))
		--INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		--SELECT 1,@TableName,'Retailer Code','RetailerCode:'+RtrCode+'Does Not Exists' FROM #NORETAILER1
		
		INSERT INTO BillPrintMsg(FromDate,ToDate,CtgLevel,CtgCode,ValueClass,RtrCode,MsgCode,[Message])
		SELECT CONVERT(VARCHAR(10),HED.FromDate,121) AS FromDate,CONVERT(VARCHAR(10),HED.ToDate,121) AS ToDate,
		DET.CatLevel,DET.CatCode,DET.RtrClass,X.RtrCode,DET.MsgCode,HED.MsgDesc FROM CN2CS_BillPrintMsgHeader HED
		INNER JOIN CN2CS_BillPrintMsgDetails DET ON HED.MsgCode=DET.MsgCode
		INNER JOIN 
		(
			SELECT R.RtrCode,RV.ValueClassCode,RC.CtgCode,RC.CtgName,RCL.CtgLevelName FROM Retailer R
			INNER JOIN RetailerValueClassMap RM ON R.RtrId=RM.RtrId
			INNER JOIN RetailerValueClass RV ON RV.RtrClassId=RM.RtrValueClassId
			INNER JOIN RetailerCategory RC ON RV.CtgMainId=RC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId=RCL.CtgLevelId
			WHERE R.RtrStatus=1 AND CtgCode NOT IN (SELECT CatCode FROM #NOCategory) AND ValueClassName NOT IN (SELECT RtrClass FROM  #NORtrClass)
			AND CtgLevelName NOT IN (SELECT CatLevel FROM #NOCatLevel) 
		) X ON DET.CatCode=X.CtgCode AND DET.CatLevel=X.CtgLevelName
		AND DET.RtrClass=X.ValueClassCode AND UPPER(DET.[Type]) NOT IN (UPPER('Retailer'))-- AND DET.RtrCode=X.RTRCODE
	
		UPDATE HED SET HED.DownloadFlag='Y' FROM CN2CS_BillPrintMsgHeader HED 
		INNER JOIN BillPrintMsg BILL ON HED.MsgCode=BILL.MsgCode
		UPDATE DET SET DET.DownLoadFlag='Y' FROM CN2CS_BillPrintMsgDetails DET 
		INNER JOIN BillPrintMsg BILL ON DET.RtrCode=BILL.RtrCode AND UPPER(DET.[Type])='RETAILER'
		UPDATE DET SET DET.DownLoadFlag='Y' FROM CN2CS_BillPrintMsgDetails DET 
		INNER JOIN BillPrintMsg BILL ON DET.CatCode=BILL.CtgCode AND DET.CatLevel=BILL.CtgLevel AND DET.RtrClass=BILL.ValueClass
		AND UPPER(DET.[Type]) NOT IN ('RETAILER')
		AND DET.CatLevel NOT IN (SELECT CatLevel FROM #NOCatLevel) AND DET.RtrClass NOT IN (SELECT RtrClass FROM #NORtrClass)
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='U' AND name='CN2CS_RtrAttributeChange')
DROP TABLE CN2CS_RtrAttributeChange
GO
CREATE TABLE CN2CS_RtrAttributeChange
(
	DistCode		NVARCHAR(100),
	RtrCode			NVARCHAR(100),
	RtrChannelCode	NVARCHAR(100),
	RtrGroupCode	NVARCHAR(100),
	RtrClassCode    NVARCHAR(100),
	[Status]		NVARCHAR(50),
	[DownloadFlag]	VARCHAR(1)
)
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_Import_RtrAttributeChange')
DROP PROCEDURE Proc_Import_RtrAttributeChange
GO
CREATE PROCEDURE Proc_Import_RtrAttributeChange
(
	@Pi_Records TEXT
)
AS
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO CN2CS_RtrAttributeChange(DistCode,RtrCode,RtrChannelCode,RtrGroupCode,RtrClassCode,[Status],DownloadFlag)
		SELECT  DistCode,RtrCode,RtrChannelCode,RtrGroupCode,RtrClassCode,[Status],ISNULL(DownloadFlag,'D')
		FROM 	OPENXML (@hdoc,'/Root/Console2CS_RtrAttributeChange',1)
		WITH (
				DistCode		NVARCHAR(100),
				RtrCode			NVARCHAR(100),
				RtrChannelCode	NVARCHAR(100),
				RtrGroupCode	NVARCHAR(100),
				RtrClassCode    NVARCHAR(100),
				[Status]		NVARCHAR(50),
				[DownloadFlag]	VARCHAR(1)		
			) XMLObj
		EXECUTE sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE name='Proc_CN2CS_RtrAttributeChange' AND XTYPE='P')
DROP PROCEDURE Proc_CN2CS_RtrAttributeChange
GO
/*
BEGIN TRANSACTION
EXEC Proc_CN2CS_RtrAttributeChange 0
SELECT * FROM CN2CS_RtrAttributeChange
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CN2CS_RtrAttributeChange
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_CN2CS_RtrAttributeChange
* PURPOSE		: To Change the Retailer Status,Classification
* CREATED		: Praveenraj B
* CREATED DATE	: 23/02/2012
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @sSql			NVARCHAR(2000)
	DECLARE @Taction  		INT
	DECLARE @ErrDesc  		NVARCHAR(1000)
	DECLARE @Tabname  		NVARCHAR(50)
	DECLARE @RtrCode  		NVARCHAR(200)
	DECLARE @RtrClassCode  	NVARCHAR(200)
	DECLARE @RtrChannelCode	NVARCHAR(200)
	DECLARE @RtrGroupCode	NVARCHAR(200)
	DECLARE @Status  		NVARCHAR(200)
	DECLARE @StatusId  		INT
	DECLARE @RtrId  		INT
	DECLARE @RtrClassId  	INT
	DECLARE @CtgLevelId  	INT
	DECLARE @CtgMainId  	INT	
	DECLARE @Pi_UserId  	INT	
	DECLARE @CtgClassMainId INT
	SET @Po_ErrNo=0
	SET @Tabname = 'CN2CS_RtrAttributeChange'
	SET @Pi_UserId=1
	
	
	DECLARE Cur_RtrAttributeChange CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([RtrCode])),''),ISNULL(LTRIM(RTRIM([RtrChannelCode])),''),ISNULL(LTRIM(RTRIM([RtrGroupCode])),''),
	ISNULL(LTRIM(RTRIM([RtrClassCode])),''),ISNULL(LTRIM(RTRIM([Status])),'Active')
	FROM CN2CS_RtrAttributeChange WHERE [DownLoadFlag] ='D'
	OPEN Cur_RtrAttributeChange
	FETCH NEXT FROM Cur_RtrAttributeChange INTO @RtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,@Status
	WHILE @@FETCH_STATUS=0
	BEGIN
		PRINT @RtrCode
		SET @Po_ErrNo=0
		IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrCode=@RtrCode)
		BEGIN
			SET @ErrDesc = 'Retailer Code:'+@RtrCode+'does not exists'
			INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
			SET @RtrId=0
		END
		ELSE
		BEGIN
			SELECT @RtrId=RtrId FROM Retailer WHERE RtrCode=@RtrCode			
		END
		
		IF NOT EXISTS (SELECT CtgMainId FROM RetailerCategory WHERE CtgCode=@RtrGroupCode)
		BEGIN
			SET @ErrDesc = 'Retailer Category Level Value:'+@RtrGroupCode+' does not exists'
			INSERT INTO Errorlog VALUES (3,@TabName,'Retailer Category Level Value',@ErrDesc)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CtgClassMainId=CtgMainId FROM RetailerCategory
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
			SET @Status=1	
		END
		ELSE
		BEGIN
			SET @Status=0
		END
		--IF UPPER(LTRIM(RTRIM(@KeyAcc)))=UPPER('YES')
		--BEGIN
		--	SET @KeyAccId=1	
		--END
		--ELSE
		--BEGIN
		--	SET @KeyAccId=0
		--END
			
		IF @Po_ErrNo=0
		BEGIN
			UPDATE Retailer SET RtrStatus=@Status,Approved=1 WHERE RtrId=@RtrId
			
			SET @sSql='UPDATE Retailer SET RtrStatus='+CAST(@Status AS NVARCHAR(100))+'WHERE RtrId='+CAST(@RtrId AS NVARCHAR(100))+''
			INSERT INTO Translog(strSql1) VALUES (@sSql)


			DECLARE @OldCtgMainId	NUMERIC(38,0)
			DECLARE @OldCtgLevelId	NUMERIC(38,0)
			DECLARE @OldRtrClassId	NUMERIC(38,0)
			DECLARE @NewCtgMainId	NUMERIC(38,0)
			DECLARE @NewCtgLevelId	NUMERIC(38,0)
			DECLARE @NewRtrClassId	NUMERIC(38,0)

			SELECT @OldCtgMainId=A.CtgMainId,@OldCtgLevelId=B.CtgLevelId,@OldRtrClassId=C.RtrClassId 
			FROM RetailerCategory A INNER JOIN RetailerCategoryLevel B ON A.CtgLevelId=B.CtgLevelId
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
			FROM RetailerCategory A INNER JOIN RetailerCategoryLevel B ON A.CtgLevelId=B.CtgLevelId
			INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
			INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
			WHERE D.RtrId=@RtrId


			INSERT INTO Track_RtrCategoryandClassChange
			SELECT -3000,@RtrId,@OldCtgLevelId,@OldCtgMainId,@OldRtrClassId,@NewCtgLevelId,@NewCtgMainId, 
			@NewRtrClassId,CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(23),GETDATE(),121),4
			

			SET @sSql='INSERT INTO RetailerValueClassMap
			(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RtrClassId AS VARCHAR(10))+',
			1,'+CAST(@Pi_UserId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',
			'+CAST(@Pi_UserId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
		
			INSERT INTO Translog(strSql1) VALUES (@sSql)			


		END
		FETCH NEXT FROM Cur_RtrAttributeChange INTO @RtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,@Status
	END
	CLOSE Cur_RtrAttributeChange
	DEALLOCATE Cur_RtrAttributeChange
	UPDATE CN2CS_RtrAttributeChange SET DownLoadFlag='Y' WHERE DownLoadFlag ='D'
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='FN' AND NAME='Fn_ReturnRestrictHolidayDates')
DROP FUNCTION Fn_ReturnRestrictHolidayDates
GO
--SELECT DBO.Fn_ReturnRestrictHolidayDates  ('2012-02-15','2012-02-01','2012-02-16') AS CNT
CREATE FUNCTION Fn_ReturnRestrictHolidayDates(@CurrDate AS DATETIME,@FromDate AS DATETIME,@ToDate AS DATETIME)
RETURNS TINYINT
AS
BEGIN
	DECLARE @DateExists AS TINYINT
	SET @DateExists=0
	SELECT @DateExists= ISNULL(SUM(DISTINCT CNT),0)
	FROM (
			SELECT CASE WHEN DATEDIFF(D,@CurrDate,@FromDate)=0 THEN 1 ELSE 0 END AS CNT
			UNION ALL
			SELECT CASE WHEN DATEDIFF(D,@CurrDate,@ToDate)=0 THEN 1 ELSE 0 END AS CNT
			UNION ALL
			SELECT CASE WHEN ISNULL(COUNT(TRANSDATE),0)>0 THEN 1 ELSE 0 END AS CNT FROM StockLedger (NOLOCK) WHERE TransDate Between @FromDate and @ToDate
	)X	
RETURN(@DateExists)
END
GO
DELETE FROM  CustomCaptions WHERE TransId=103 and CtrlId=1000 and SubCtrlId=50
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (103,1000,50,'PnlMsg-103-1000-50','','The given holiday date range should not  be in current date or transaction exists date','',1,1,1,'2009-04-28',1,'2009-04-28','','The given holiday date range should not to be in current date or transaction exists date','',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId=104 AND CtrlId=1000 AND SubCtrlId=23
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 104,1000,23,'MsgBox-104-1000-23','','','Back Dated Transaction Not Allowed',1,1,1,GETDATE(),1,GETDATE(),'','','Back Dated Transaction Not Allowed',1,1
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='TEMPFILLPRODUCTBATCH' AND XTYPE='U')
DROP TABLE TEMPFILLPRODUCTBATCH
GO
--SELECT * FROM TEMPFILLPRODUCTBATCH
CREATE TABLE TEMPFILLPRODUCTBATCH
(
Prdid int ,
PrdName nvarchar(100),
PrdCCode nvarchar(100),
PrdDCode nvarchar(100),
PrdBatID nvarchar(100),
BatchCode nvarchar(100),
MRP numeric(18,6),
PurchaseRate numeric(18,6),
SellRate numeric(18,6),
StockAvail int,
PriceId int
)
GO
--EXEC Proc_ValidateBatchSplit 257,285,1,10
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ValidateBatchSplit' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateBatchSplit
GO
CREATE PROCEDURE Proc_ValidateBatchSplit
 (
 @Prdid as int,
 @Prdbatid as int,
 @Lcnid as int,
 @Quantity as int,
 @Orderby as int

  )
  AS
  BEGIN
  DECLARE @PPrdId int
  DECLARE @Pprdbatid int
  DECLARE @stock int
  DECLARE @ActStock AS INT
  DECLARE @FilledStock AS INT
  DECLARE @AscDesc as varchar(20)
  
	DELETE FROM TEMPFILLPRODUCTBATCH

	SET @ActStock=@Quantity
	IF EXISTS (select * from ProductBatchLocation where PrdId=@Prdid and PrdBatID=@Prdbatid and LcnId=@Lcnid and (PrdBatLcnSih-PrdBatLcnRessih)>=@Quantity)
		BEGIN
		  INSERT INTO 	TEMPFILLPRODUCTBATCH
		  SELECT A.Prdid,G.PrdName,G.PrdCCode,G.PrdDCode,A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,  
		  @Quantity as StockAvail, B.PriceId FROM ProductBatch A (NOLOCK)   
		  INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   
		  INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1   
		  INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1   
		  INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   
		  INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1   
		  INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1   
		  INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId   
		  INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId WHERE A.Status = 1   
		  AND A.PrdId=@PrdId AND F.LcnId = @LcnId and F.PrdBatID=@Prdbatid
		  AND CAST(B.PrdBatDetailValue AS NUMERIC(18,6)) >= CAST(D.PrdBatDetailValue AS NUMERIC(18,6))
		END 
	ELSE
		IF EXISTS (SELECT PrdId FROM ProductBatchLocation WHERE PrdId=@Prdid AND LcnId=@Lcnid group by prdid having SUM(PrdBatLcnSih-PrdBatLcnRessih)>0 )
		BEGIN
		SET @FilledStock=0
		
	DECLARE @TempNetSales TABLE
	(		
		slno int identity(1,1),
		PrdId	int,
		prdbatid INT,
		stock INT
	)	
	IF @Orderby=1 or @Orderby=0
	 BEGIN 
		INSERT INTO @TempNetSales
		SELECT PrdId,prdbatid,stock FROM (
		SELECT PrdId,prdbatid,(PrdBatLcnSih-PrdBatLcnRessih)stock FROM ProductBatchLocation WHERE PrdId=@Prdid AND LcnId=@Lcnid and (PrdBatLcnSih-PrdBatLcnRessih)>0)A
		ORDER BY prdbatid  Asc
	 END 
	 ELSE
	 BEGIN 
		INSERT INTO @TempNetSales
		SELECT PrdId,prdbatid,stock FROM (
		SELECT PrdId,prdbatid,(PrdBatLcnSih-PrdBatLcnRessih)stock FROM ProductBatchLocation WHERE PrdId=@Prdid AND LcnId=@Lcnid and (PrdBatLcnSih-PrdBatLcnRessih)>0)A
		ORDER BY prdbatid  Desc	
	 END 	

		DECLARE Cur_FillProductbatch CURSOR 
		FOR 
		SELECT PrdId,prdbatid,stock FROM @TempNetSales order by slno
		OPEN Cur_FillProductbatch
		FETCH NEXT FROM Cur_FillProductbatch into  @PPrdId,@Pprdbatid,@stock
		WHILE @@FETCH_STATUS =0
		BEGIN
		 IF @FilledStock<@ActStock  AND @Quantity>0
		  BEGIN  
				IF EXISTS (SELECT PrdId,prdbatid,(PrdBatLcnSih-PrdBatLcnRessih)stock FROM ProductBatchLocation WHERE PrdId=@PPrdId 
				AND PrdBatID=@Pprdbatid AND LcnId=@Lcnid and (PrdBatLcnSih-PrdBatLcnRessih)>=@Quantity)
				 BEGIN
			 		  INSERT INTO 	TEMPFILLPRODUCTBATCH
					  SELECT A.Prdid,G.PrdName,G.PrdCCode,G.PrdDCode,A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,  
					  @Quantity as StockAvail, B.PriceId FROM ProductBatch A (NOLOCK)   
					  INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   
					  INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1   
					  INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1   
					  INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   
					  INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1   
					  INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1   
					  INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId   
					  INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId WHERE A.Status = 1   
					  AND A.PrdId=@PPrdId AND F.LcnId = @LcnId and F.PrdBatID=@Pprdbatid
					  AND CAST(B.PrdBatDetailValue AS NUMERIC(18,6)) >= CAST(D.PrdBatDetailValue AS NUMERIC(18,6))
					  
					  SET @Quantity=@Quantity-@stock
					  SET @FilledStock=@FilledStock+@stock
					  
				 END 
				ELSE
				BEGIN
					  INSERT INTO 	TEMPFILLPRODUCTBATCH
					  SELECT A.Prdid,G.PrdName,G.PrdCCode,G.PrdDCode,A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,  
					  (PrdBatLcnSih-PrdBatLcnRessih) as StockAvail, B.PriceId FROM ProductBatch A (NOLOCK)   
					  INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   
					  INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1   
					  INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1   
					  INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   
					  INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1   
					  INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1   
					  INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId   
					  INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId WHERE A.Status = 1   
					  AND A.PrdId=@PPrdId AND F.LcnId = @LcnId and F.PrdBatID=@Pprdbatid
					  AND CAST(B.PrdBatDetailValue AS NUMERIC(18,6)) >= CAST(D.PrdBatDetailValue AS NUMERIC(18,6))
					  SET @Quantity=@Quantity-@stock
					  SET @FilledStock=@FilledStock+@stock
				END 
			END
		
		 
		FETCH NEXT FROM Cur_FillProductbatch into  @PPrdId,@Pprdbatid,@stock
		END 
		CLOSE Cur_FillProductbatch
		DEALLOCATE Cur_FillProductbatch
		END   
	ELSE
	   IF EXISTS (SELECT PrdId FROM ProductBatchLocation WHERE PrdId=@Prdid AND LcnId=@Lcnid group by prdid having SUM(PrdBatLcnSih-PrdBatLcnRessih)=0)	
	   BEGIN
		  INSERT INTO 	TEMPFILLPRODUCTBATCH
		  SELECT A.Prdid,G.PrdName,G.PrdCCode,G.PrdDCode,A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,  
		  (PrdBatLcnSih-PrdBatLcnRessih) as StockAvail, B.PriceId FROM ProductBatch A (NOLOCK)   
		  INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   
		  INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1   
		  INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1   
		  INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   
		  INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1   
		  INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1   
		  INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId   
		  INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId WHERE A.Status = 1   
		  AND A.PrdId=@PrdId AND F.LcnId = @LcnId and F.PrdBatID=@Prdbatid
		  AND CAST(B.PrdBatDetailValue AS NUMERIC(18,6)) >= CAST(D.PrdBatDetailValue AS NUMERIC(18,6))
	   END 
  END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Fn_ReturnActStock' AND XTYPE='TF')
DROP FUNCTION Fn_ReturnActStock
GO
--select sum(StockAvail) from dbo.Fn_ReturnActStock ('ORD1100001')
CREATE FUNCTION Fn_ReturnActStock (@OrderNo varchar(50))
RETURNS @PrdBatchDetailsWithActStock TABLE
	(
		PrdId		INT,
		StockAvail	NUMERIC(18,0)
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnPrdBatchDetailsWithStock
* PURPOSE: Returns the Product details with stock
* NOTES:
* CREATED: Kar.thick.k.j
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
declare @LcnId as int

		SELECT @LcnId=LcnId  FROM Location WHERE DefaultLocation=1
		INSERT INTO @PrdBatchDetailsWithActStock
		SELECT 11,AVstock from 
		(SELECT PBL.PrdId,sum(PrdBatLcnSih-PrdBatLcnRessih)AVstock from productbatchlocation PBL inner join 
		productbatch PB on PBL.PrdId=PB.PrdId and PBL.PrdBatID=PB.PrdBatId
		where PB.Status=1 and LcnId=@LcnId group by pbl.PrdId)A inner join
		(select PrdId,sum(OP.Qty1)Qty from OrderBooking OB inner join OrderBookingProducts OP
		on OB.OrderNo=OP.OrderNo WHERE ob.OrderNo=@OrderNo GROUP BY PrdId)B on A.prdid=B.prdid

RETURN
END
GO
IF EXISTS(SELECT Name FROM SysObjects WHERE name='CnCs_CategoryApproval' And XTYPE='U')
DROP TABLE CnCs_CategoryApproval
GO
CREATE TABLE CnCs_CategoryApproval
(
	DistributorCode NVarChar(40),
	CtgLevel NVarChar(40),
	CtgCode NvarChar(100),
	ConfigStatus NvarChar(10),
	ApprovalStatus NvarChar(1),
	DownloadFlag NvarChar(1)
)
GO
IF EXISTS(SELECT Name FROM SysObjects WHERE name='CategoryApproval' And XTYPE='U')
DROP TABLE CategoryApproval
GO
CREATE TABLE CategoryApproval
(
	Slno INT IDENTITY(1,1),
	CtgCode NVARCHAR(40),
	CtgName NVARCHAR(100),
)
GO
IF EXISTS (SELECT Name From SysObjects Where Xtype='P' And name='Proc_Import_Categoryapproval')
DROP PROCEDURE Proc_Import_Categoryapproval  
GO
CREATE PROCEDURE Proc_Import_Categoryapproval
(  
 @Pi_Records TEXT  
)  
AS  
SET NOCOUNT ON  
BEGIN  
 DECLARE @hDoc INTEGER  
 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
  
 INSERT INTO CnCs_CategoryApproval(DistributorCode,CtgLevel,CtgCode,ApprovalStatus,DownloadFlag)  
 SELECT [DistCode],[RetCatLvl],[RetCatCode],[ApprovalRequired],ISNULL(DownloadFlag,'D')
 FROM OPENXML (@hdoc,'/Root/Console2CS_RetHierApprovalConfig',1)  
 WITH   
 (  
	[DistCode] [nvarchar](100) ,
	[RetCatLvl] [nvarchar](100) ,
	[RetCatCode] [nvarchar](100) ,
	--[ConfigStatus] [NVarchar](10),
	[ApprovalRequired] [nvarchar](1),
	[DownLoadFlag] [nvarchar](1) 
 
 ) XMLObj  
  
 EXEC sp_xml_removedocument @hDoc  
END  
GO
IF EXISTS(SELECT Name FROM SysObjects WHERE name='Proc_CnCs_Categoryapproval' And XTYPE='P')
DROP PROCEDURE Proc_CnCs_Categoryapproval
GO
--EXEC Proc_CnCs_Categoryapproval 0
CREATE PROCEDURE Proc_CnCs_Categoryapproval
(
@Po_ErrNo AS INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
	DECLARE @Config AS INT
	DECLARE @TabName AS NVARCHAR(20)
	SELECT @Config=CASE UPPER(LTRIM(RTRIM(ConfigStatus))) WHEN 'YES' THEN 1 ELSE 0 END FROM CnCs_CategoryApproval 
	SET @TabName='CnCs_CategoryApproval'
	SET @Po_ErrNo=0
	DELETE FROM CnCs_CategoryApproval WHERE DownloadFlag='Y'
	IF @Config=1 
	BEGIN
		DELETE FROM Configuration Where ModuleId='RET39' And ModuleName='Retailer'
		INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
		SELECT 'RET39','Retailer','Seek Approval for selected categories and attached classes',1,'',0.00,39
			
			SELECT DISTINCT CtgCode INTO #Category
			FROM CnCs_CategoryApproval CN2CS WHERE NOT EXISTS (SELECT CtgCode FROM RetailerCategory RC WHERE RC.CtgCode=CN2CS.CtgCode)

			INSERT INTO ErrorLog
			SELECT 1,@TabName,'Category Code','CategoryCode:'+CtgCode+'does not exists' FROM #Category
			INSERT INTO CategoryApproval(CtgCode ,CtgName)
			SELECT CR.CtgCode,RC.CtgName FROM CnCs_CategoryApproval CR
			INNER JOIN RetailerCategory RC ON CR.CtgCode=RC.CtgCode AND CR.CtgCode NOT IN (SELECT CtgCode FROM #Category)
			AND CR.ApprovalStatus=1
	END
	ELSE
	BEGIN
		DELETE FROM Configuration Where ModuleId='RET39' And ModuleName='Retailer'
		INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
		SELECT 'RET39','Retailer','Seek Approval for selected categories and attached classes',0,'',0.00,39
	END
END
GO
IF EXISTS(SELECT NAME FROM Sysobjects WHERE NAME='Fn_ReturnActStock' AND XTYPE='TF')
DROP FUNCTION Fn_ReturnActStock
GO
--select sum(StockAvail) from dbo.Fn_ReturnActStock ('ORD1100001')  
CREATE FUNCTION Fn_ReturnActStock (@OrderNo varchar(50))  
RETURNS @PrdBatchDetailsWithActStock TABLE  
 (  
  PrdId  INT,  
  StockAvail NUMERIC(18,0)  
 )  
AS  
BEGIN  
/*********************************  
* FUNCTION: Fn_ReturnPrdBatchDetailsWithStock  
* PURPOSE: Returns the Product details with stock  
* NOTES:  
* CREATED: Kar.thick.k.j  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
declare @LcnId as int  
  
  SELECT @LcnId=LcnId  FROM Location WHERE DefaultLocation=1  
  INSERT INTO @PrdBatchDetailsWithActStock  
  SELECT 11,ISNULL(AVstock,0) from   
  (SELECT PBL.PrdId,ISNULL(sum(PrdBatLcnSih-PrdBatLcnRessih),0)AVstock from productbatchlocation PBL inner join   
  productbatch PB on PBL.PrdId=PB.PrdId and PBL.PrdBatID=PB.PrdBatId  
  where PB.Status=1 and LcnId=@LcnId group by pbl.PrdId)A Right Outer join  
  (select PrdId,sum(OP.Qty1)Qty from OrderBooking OB inner join OrderBookingProducts OP  
  on OB.OrderNo=OP.OrderNo WHERE ob.OrderNo=@OrderNo GROUP BY PrdId)B on A.prdid=B.prdid  
  
RETURN  
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE name='Cn2Cs_CategoryApproval' AND XType='U' )
DROP TABLE Cn2Cs_CategoryApproval
GO
CREATE TABLE Cn2Cs_CategoryApproval
	(
	[DistributorCode] [nvarchar](40) NULL,
	[CtgLevel] [nvarchar](40) NULL,
	[CtgCode] [nvarchar](100) NULL,
	[ConfigStatus] [nvarchar](10) NULL,
	[ApprovalStatus] [nvarchar](1) NULL,
	[DownloadFlag] [nvarchar](1) NULL
	) ON [PRIMARY]

GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE name='Proc_Import_Categoryapproval' AND XType='P' )
DROP PROCEDURE Proc_Import_Categoryapproval
GO
CREATE PROCEDURE Proc_Import_Categoryapproval
(  
 @Pi_Records TEXT  
)  
AS  
SET NOCOUNT ON  
BEGIN  
 DECLARE @hDoc INTEGER  
 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
  
 INSERT INTO CnCs_CategoryApproval(DistributorCode,CtgLevel,CtgCode,ApprovalStatus,DownloadFlag)  
 SELECT [DistCode],[RetCatLvl],[RetCatCode],[ApprovalRequired],ISNULL(DownloadFlag,'D')
 FROM OPENXML (@hdoc,'/Root/Console2CS_RetHierApprovalConfig',1)  
 WITH   
 (  
	[DistCode] [nvarchar](100) ,
	[RetCatLvl] [nvarchar](100) ,
	[RetCatCode] [nvarchar](100) ,
	--[ConfigStatus] [NVarchar](10),
	[ApprovalRequired] [nvarchar](1),
	[DownLoadFlag] [nvarchar](1) 
 
 ) XMLObj  
  
 EXEC sp_xml_removedocument @hDoc  
END  
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE name='Proc_CnCs_Categoryapproval' AND XType='P' )
DROP PROCEDURE Proc_CnCs_Categoryapproval
GO
--EXEC Proc_CnCs_CategoryApproval 0
CREATE PROCEDURE Proc_CnCs_Categoryapproval
(
@Po_ErrNo AS INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
	DECLARE @Config AS INT
	DECLARE @TabName AS NVARCHAR(20)
	SELECT @Config=CASE UPPER(LTRIM(RTRIM(ConfigStatus))) WHEN 'YES' THEN 1 ELSE 0 END FROM Cn2Cs_CategoryApproval 
	SET @TabName='Cn2Cs_CategoryApproval'
	SET @Po_ErrNo=0
	DELETE FROM Cn2Cs_CategoryApproval WHERE DownloadFlag='Y'
	IF @Config=1 
	BEGIN
		DELETE FROM Configuration Where ModuleId='RET39' And ModuleName='Retailer'
		INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
		SELECT 'RET39','Retailer','Seek Approval for selected categories and attached classes',1,'',0.00,39
			
			SELECT DISTINCT CtgCode INTO #Category
			FROM Cn2Cs_CategoryApproval CN2CS WHERE NOT EXISTS (SELECT CtgCode FROM RetailerCategory RC WHERE RC.CtgCode=CN2CS.CtgCode)

			INSERT INTO ErrorLog
			SELECT 1,@TabName,'Category Code','CategoryCode:'+CtgCode+'does not exists' FROM #Category
			INSERT INTO CategoryApproval(CtgCode ,CtgName)
			SELECT CR.CtgCode,RC.CtgName FROM Cn2Cs_CategoryApproval CR
			INNER JOIN RetailerCategory RC ON CR.CtgCode=RC.CtgCode AND CR.CtgCode NOT IN (SELECT CtgCode FROM #Category)
			AND CR.ApprovalStatus=1
	END
	ELSE
	BEGIN
		DELETE FROM Configuration Where ModuleId='RET39' And ModuleName='Retailer'
		INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
		SELECT 'RET39','Retailer','Seek Approval for selected categories and attached classes',0,'',0.00,39
	END
END
GO
EXECUTE SP_CONFIGURE 'show advanced options', 1
RECONFIGURE WITH OVERRIDE
GO
EXECUTE SP_CONFIGURE 'xp_cmdshell', 1
RECONFIGURE WITH OVERRIDE
GO
EXECUTE SP_CONFIGURE 'show advanced options', 0
RECONFIGURE WITH OVERRIDE
GO
IF EXISTS(SELECT NAME FROM SysObjects WHERE name='Fn_ReturnHolidays' AND XTYPE='FN')
DROP FUNCTION Fn_ReturnHolidays
GO
CREATE FUNCTION Fn_ReturnHolidays (@CurrDate AS DATETIME)  
RETURNS TINYINT  
AS  
/*********************************  
* FUNCTION: Fn_ReturnHolidays  
* PURPOSE: To Return Holidays  
* CREATED: Murugan.R 02/02/2012  
*********************************/  
BEGIN  
 DECLARE @ReturnHolidays AS INT  
 SET @ReturnHolidays=0  
 SELECT @ReturnHolidays=ISNULL(SUM(DISTINCT CNT),0)   
 FROM(  
   SELECT ISNULL(COUNT(JcmId),0) AS CNT   
   FROM JCHoliday WHERE @CurrDate BETWEEN HoliDaySdt AND HolidayEdt  
   UNION ALL  
   SELECT ISNULL(COUNT(DistributorCode),0) AS CNT  
   FROM DISTRIBUTOR  
   WHERE UPPER(DATENAME(DW,@CurrDate))=UPPER(CASE DayOff WHEN 0 THEN 'Sunday'  
              WHEN 1 THEN 'Monday'  
              WHEN 2 THEN 'Tuesday'  
              WHEN 3 THEN 'Wednesday'  
              WHEN 4 THEN 'Thursday'  
              WHEN 5 THEN 'Friday'  
              WHEN 6 THEN 'Saturday' END)  
  )X  
 RETURN(@ReturnHolidays)  
END
GO
IF EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.ID=SC.ID AND S.NAME='TaxGroupSetting' and SC.NAME='RtrGroup')
BEGIN
	ALTER TABLE TaxGroupSetting ALTER COLUMN RtrGroup NVARCHAR(200)
END
GO
IF  EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.ID=SC.ID AND S.NAME='TaxGroupSetting' and SC.NAME='PrdGroup')
BEGIN
	ALTER TABLE TaxGroupSetting ALTER COLUMN PrdGroup NVARCHAR(200)
END
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='DOCREFNO' AND ID IN (
SELECT ID FROM SYSOBJECTS WHERE NAME='RECEIPT' AND XTYPE='U') )
BEGIN 
	ALTER TABLE Receipt ADD DocRefNo Varchar(100)
END 
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='PDAReceipt' AND ID IN (
SELECT ID FROM SYSOBJECTS WHERE NAME='RECEIPT' AND XTYPE='U') )
BEGIN 
	ALTER TABLE Receipt ADD PDAReceipt int
END 
GO
DELETE FROM CustomCaptions  WHERE TransId=9 AND CtrlId=2000 AND SubCtrlId=14
INSERT INTO CustomCaptions 
SELECT 9,2000,14,'HotSch-9-2000-14','Receipt No','','',1,1,1,getdate(),1,getdate(),'Receipt No','','',1,1
DELETE FROM CustomCaptions  WHERE TransId=9 AND CtrlId=2000 AND SubCtrlId=15
INSERT INTO CustomCaptions 
SELECT 9,2000,15,'HotSch-9-2000-15','Collection Date','','',1,1,1,getdate(),1,getdate(),'Collected Date','','',1,1
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE IN ('TF','FN') And name = 'Fn_PurchaseSequenceDetails')
DROP FUNCTION Fn_PurchaseSequenceDetails
GO
CREATE FUNCTION Fn_PurchaseSequenceDetails(@Pi_PurRcpId INT,@Pi_PurDate DateTime)
RETURNS @PurchaseSequenceDetails TABLE
(
	[PurSeqId] [int] NOT NULL,
	[SequenceDate] [datetime] NOT NULL,
	[SlNo] [int] NOT NULL, 
	[RefCode] [nvarchar](25) NOT NULL,
	[ColumnName] [nvarchar](25) NOT NULL,
	[FieldDesc] [nvarchar](100) NOT NULL,
	[Calculation] [nvarchar](200) NOT NULL,
	[MasterID] [int] NOT NULL,
	[BatchSeqId] [int] NOT NULL,
	[DefaultValue] [int] NOT NULL,
	[DisplayIn] [int] NOT NULL,
	[Editable] [int] NOT NULL,
	[EffectInNetAmount] [int] NOT NULL,
	[Visibility] [int] NOT NULL,
	[CoaId] [int] NOT NULL
)
AS
BEGIN
IF EXISTS (SELECT * FROM Configuration WHERE ModuleId = 'PURCHASERECEIPT16' AND Status = 1)
BEGIN
    IF @Pi_PurRcpId > 0
    BEGIN
	  INSERT INTO @PurchaseSequenceDetails (PurSeqId,SequenceDate,SlNo,RefCode,ColumnName,FieldDesc,Calculation,MasterID,BatchSeqId,DefaultValue,DisplayIn,Editable,
                                   EffectInNetAmount,Visibility,CoaId )
      SELECT A.PurSeqId,A.SequenceDate,SlNo,RefCode,ColumnName,FieldDesc,Calculation,MasterID, BatchSeqId,DefaultValue,
      DisplayIn , Editable, EffectInNetAmount, Visibility,CoaId FROM PurchaseSequenceMaster A (NOLOCK) 
      INNER JOIN PurchaseSequenceDetail B (NOLOCK) ON A.PurSeqId = B.PurSeqId INNER JOIN PurchaseReceipt PR ON PR.PurSeqId=A.PurSeqId 
      AND PR.PurSeqId=B.PurSeqId AND PR.PurRcptId = @Pi_PurRcpId ORDER BY SlNo
    END
    ELSE
    BEGIN
	  INSERT INTO @PurchaseSequenceDetails (PurSeqId,SequenceDate,SlNo,RefCode,ColumnName,FieldDesc,Calculation,MasterID,BatchSeqId,DefaultValue,DisplayIn,Editable,
                                   EffectInNetAmount,Visibility,CoaId )
	  SELECT A.PurSeqId,A.SequenceDate,SlNo,RefCode,ColumnName,FieldDesc,Calculation,MasterID,
      BatchSeqId , DefaultValue, DisplayIn, Editable, EffectInNetAmount, Visibility, CoaId FROM PurchaseSequenceMaster A (NOLOCK)
      INNER JOIN PurchaseSequenceDetail B (NOLOCK) ON A.PurSeqId = B.PurSeqId WHERE A.PurSeqId IN (SELECT Top 1 PurSeqId FROM PurchaseSequenceMaster (NOLOCK) 
      WHERE SequenceDate <= CONVERT(Varchar(10),@Pi_PurDate,121) ORDER BY PurSeqId DESC) ORDER BY SlNo
   END
END
ELSE
BEGIN
    IF @Pi_PurRcpId > 0
    BEGIN
	  INSERT INTO @PurchaseSequenceDetails (PurSeqId,SequenceDate,SlNo,RefCode,ColumnName,FieldDesc,Calculation,MasterID,BatchSeqId,DefaultValue,DisplayIn,Editable,
                                   EffectInNetAmount,Visibility,CoaId )
      SELECT A.PurSeqId,A.SequenceDate,SlNo,RefCode,ColumnName,FieldDesc,Calculation,MasterID, BatchSeqId,DefaultValue,
      DisplayIn , Editable, EffectInNetAmount, Visibility,CoaId FROM PurchaseSequenceMaster A (NOLOCK) 
      INNER JOIN PurchaseSequenceDetail B (NOLOCK) ON A.PurSeqId = B.PurSeqId INNER JOIN PurchaseReceipt PR ON PR.PurSeqId=A.PurSeqId 
      AND PR.PurSeqId=B.PurSeqId AND PR.PurRcptId = @Pi_PurRcpId AND B.RefCode <> 'E' ORDER BY SlNo
    END
    ELSE
    BEGIN
	  INSERT INTO @PurchaseSequenceDetails (PurSeqId,SequenceDate,SlNo,RefCode,ColumnName,FieldDesc,Calculation,MasterID,BatchSeqId,DefaultValue,DisplayIn,Editable,
                                   EffectInNetAmount,Visibility,CoaId )
	  SELECT A.PurSeqId,A.SequenceDate,SlNo,RefCode,ColumnName,FieldDesc,Calculation,MasterID,
      BatchSeqId , DefaultValue, DisplayIn, Editable, EffectInNetAmount, Visibility, CoaId FROM PurchaseSequenceMaster A (NOLOCK)
      INNER JOIN PurchaseSequenceDetail B (NOLOCK) ON A.PurSeqId = B.PurSeqId WHERE A.PurSeqId IN (SELECT Top 1 PurSeqId FROM PurchaseSequenceMaster (NOLOCK) 
      WHERE SequenceDate <= CONVERT(Varchar(10),@Pi_PurDate,121) AND B.RefCode <> 'E' ORDER BY PurSeqId DESC) ORDER BY SlNo
    END 
END         
RETURN
END
GO
IF EXISTS (Select * From Sysobjects Where XTYPE = 'P' And name = 'PROC_RPTPurchaseDiscountReport')
DROP PROCEDURE PROC_RPTPurchaseDiscountReport
GO
--EXEC PROC_RPTPurchaseDiscountReport 252,2,0,'PP',0,0,1
CREATE PROCEDURE PROC_RPTPurchaseDiscountReport
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
BEGIN
/*********************************    
* PROCEDURE: PROC_RPTPurchaseDiscountReport    
* PURPOSE: To Generate Purchase Discount Report
* NOTES:    
* CREATED: Praveenraj B    
* ON DATE: 2012-03-05    
* MODIFIED    
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
*    
*********************************/  
SET NOCOUNT ON
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate AS DATETIME 
	DECLARE @CmpId AS INT
	DECLARE @PrdCatId AS INT 
	DECLARE @PrdCatValId AS INT
	
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) 
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCatValId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	PRINT @PrdCatId
	PRINT @PrdCatValId

	IF @PrdCatId=0 AND @PrdCatValId=0 
	BEGIN
		SELECT CmpInvNo,InvDate,PurRcptRefNo,GoodsRcvdDate,PRP.PrdId,PRP.PrdBatId,PrdCCode,PrdName,(SUM(PrdDiscount)+ SUM(OIDEntVal)) AS Discount
		INTO #RptPurchaseDiscountReportAll FROM PurchaseReceipt PR 
		INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId=PRP.PurRcptId 
		INNER JOIN Product P ON P.PrdId=PRP.PrdId
		WHERE InvDate BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) AND P.PrdStatus=1 AND PR.[Status]=1 
		AND (PR.CmpId=  (CASE @CmpId WHEN 0 THEN PR.CmpId ELSE 0 END ) OR
		PR.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		GROUP BY CmpInvNo,InvDate,PurRcptRefNo,GoodsRcvdDate,PRP.PrdId,PRP.PrdBatId,PrdCCode,PrdName 
		HAVING (SUM(PrdDiscount)+ SUM(OIDEntVal)) > 0 
		
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptPurchaseDiscountReportAll
		SELECT * FROM #RptPurchaseDiscountReportAll
	END
	ELSE 
	BEGIN
		SELECT  PRDID INTO #SELECTED FROM Product P 
		INNER JOIN ProductCategoryValue Val ON P.PrdCtgValMainId=Val.PrdCtgValMainId
		INNER JOIN ProductCategoryLevel Lev ON Val.CmpPrdCtgId=Lev.CmpPrdCtgId  
		WHERE Lev.CmpPrdCtgId IN (SELECT DISTINCT SelValue FROM ReportFilterDt WHERE RPTID=252 AND SelId=16 AND UsrId=@Pi_UsrId)
		AND VAl.PrdCtgValMainId IN (SELECT DISTINCT SelValue FROM ReportFilterDt WHERE RptId=252 AND SelId=21 AND UsrId=@Pi_UsrId)
		
		SELECT CmpInvNo,InvDate,PurRcptRefNo,GoodsRcvdDate,PRP.PrdId,PRP.PrdBatId,PrdCCode,PrdName,(SUM(PrdDiscount)+ SUM(OIDEntVal)) AS Discount 
		INTO #RptPurchaseDiscountReport FROM PurchaseReceipt PR 
		INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId=PRP.PurRcptId 
		INNER JOIN Product P ON P.PrdId=PRP.PrdId
		INNER JOIN #SELECTED ON PRP.PrdId=#SELECTED.PrdId
		WHERE InvDate BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) AND P.PrdStatus=1 AND PR.[Status]=1 
		AND 
		(PR.CmpId=  (CASE @CmpId WHEN 0 THEN PR.CmpId ELSE 0 END ) OR
		PR.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		GROUP BY CmpInvNo,InvDate,PurRcptRefNo,GoodsRcvdDate,PRP.PrdId,PRP.PrdBatId,PrdCCode,PrdName 
		HAVING (SUM(PrdDiscount)+ SUM(OIDEntVal))> 0 
		
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptPurchaseDiscountReport
		SELECT * FROM #RptPurchaseDiscountReport
	END
END
GO
UPDATE SalesInvoice SET SalinvDateWithtime = SalinvDate Where SalinvDateWithtime IS NULL
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='Temp_PurchaseReturn')
DROP TABLE Temp_PurchaseReturn
GO
CREATE TABLE Temp_PurchaseReturn
(
	Slno int,
	LCnid int,	
	CmpId int,
	SpmId int,
	CmpInvoiceno nVarchar(100),
	Remarks nVarchar(500),
	SRSPRNType nVarchar(10),
	ReferenceType nVarchar(10),
	ReturnMode nVarchar(10),
	Prdccode nVarchar(100),
	CmpBatchcode nVarchar(100),
	MRP Numeric(18,6),
	ListPrice Numeric(18,6),
	StockType nVarchar(20),
	PurchaseQty Numeric(18,0),
	ReturnQty  Numeric(18,0),
	GrossAmount Numeric(36,6),
	LessDiscount Numeric(36,6),
	LessSchemeAmount Numeric(36,6),
	TotalTaxAmount Numeric(36,6),
	NetAmount Numeric(36,6),
	SchemeRefrNo Varchar(50),
	RowId INT,
	PurRcptId int,
	Invdate datetime,
	PurRcptRefNo nvarchar(50),
	Prdid int,
	Prdbatid int,
	Priceid int,
	UomId int,
	DownloadFlag nVarchar(1)
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempPurchaseReturnBreakUp')
DROP TABLE TempPurchaseReturnBreakUp
GO
CREATE TABLE TempPurchaseReturnBreakUp
(
	Slno int,
	CmpInvoiceno nVarchar(100),
	PurRcptId bigint NOT NULL,
	Rowid int NOT NULL,
	BreakUpType tinyint NOT NULL,
	StockTypeId int NOT NULL,
	UserStockType nvarchar(50)not null,
	UomId int NOT NULL,
	UomCode nvarchar(50)not null,
	ConFact int NOT NULL,
	Quantity int NOT NULL,
	ReturnQty numeric(18, 0) NOT NULL,
	BaseQty numeric(18, 0) NOT NULL,
	ReturnBsQty numeric(18,0) not null,
	LCnid int  not null,
	SystemStockType int  not null,
	DownloadFlag nVarchar(1)
	)
GO
DELETE FROM CustomCaptions WHERE TransId=103 AND CtrlId=1000 AND SubCtrlId=51
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 103,1000,51,'PnlMsg-103-1000-51',11,'DayOffDate should not be CurrentDateName','',1,1,1,GETDATE(),1,GETDATE(),'','DayOffDate should not be CurrentDateName','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=103 AND CtrlId=1000 AND SubCtrlId=52
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 103,1000,52,'PnlMsg-103-1000-52',11,'Holidaydaye should not be MonthEndDate','',1,1,1,GETDATE(),1,GETDATE(),'','Holidaydaye should not be MonthEndDate','',1,1
GO
IF EXISTS(SELECT * FROM SysObjects WHERE name='Fn_ReturnHolidays' AND XTYPE='FN')
DROP FUNCTION Fn_ReturnHolidays 
GO
CREATE FUNCTION Fn_ReturnHolidays (@CurrDate AS DATETIME)    
RETURNS TINYINT    
AS    
/*********************************    
* FUNCTION: Fn_ReturnHolidays    
* PURPOSE: To Return Holidays    
* CREATED: Murugan.R 02/02/2012    
*********************************/    
BEGIN    
 DECLARE @ReturnHolidays AS INT    
 SET @ReturnHolidays=0    
 SELECT @ReturnHolidays=ISNULL(SUM(DISTINCT CNT),0)     
 FROM(    
   SELECT ISNULL(COUNT(JcmId),0) AS CNT     
   FROM JCHoliday WHERE @CurrDate BETWEEN HoliDaySdt AND HolidayEdt    
   UNION ALL    
   SELECT ISNULL(COUNT(DistributorCode),0) AS CNT    
   FROM DISTRIBUTOR    
   WHERE UPPER(DATENAME(DW,@CurrDate))=UPPER(CASE DayOff WHEN 0 THEN 'Sunday'    
              WHEN 1 THEN 'Monday'    
              WHEN 2 THEN 'Tuesday'    
              WHEN 3 THEN 'Wednesday'    
              WHEN 4 THEN 'Thursday'    
              WHEN 5 THEN 'Friday'    
              WHEN 6 THEN 'Saturday' END)    
  UNION ALL
  SELECT ISNULL(JcmId,0) AS CNT 
   FROM JCMast 
   WHERE JcmYr=YEAR(GETDATE())
   AND UPPER(DATENAME(DW,@CurrDate))=UPPER(CASE WkEndDay WHEN 1 THEN 'Sunday'    
              WHEN 2 THEN 'Monday'    
              WHEN 3 THEN 'Tuesday'    
              WHEN 4 THEN 'Wednesday'    
              WHEN 5 THEN 'Thursday'    
              WHEN 6 THEN 'Friday'    
              WHEN 7 THEN 'Saturday' END)
  )X    
 RETURN(@ReturnHolidays)    
END
GO
Delete From CustomCaptions Where TransId=5 And CtrlId=1000 And SubCtrlId in (107,108)
GO
Insert Into CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
							DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Select 5,1000,107,'MsgBox-5-1000-107','','','Please enter invoice quantity to select TaxDetails',1,1,1,GETDATE(),1,GETDATE(),'',
'','Please enter invoice quantity to select TaxDetails',1,1 Union All
Select 5,1000,108,'MsgBox-5-1000-108','','','No record Found',1,1,1,GETDATE(),1,GETDATE(),'',
'','No record Found',1,1 
GO
Delete From CustomCaptions Where TransId=5 And CtrlId In (100015,100016,100017) And SubCtrlId=1
GO
Insert Into CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
							DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Select 5,100015,1,'PnlMsg-5-100015-1','','Description','',1,1,1,GETDATE(),1,GETDATE(),'','Description','',1,1
Union All
Select 5,100016,1,'PnlMsg-5-100015-2','','Taxable Amount','',1,1,1,GETDATE(),1,GETDATE(),'','Taxable Amount','',1,1
Union All
Select 5,100017,1,'PnlMsg-5-100015-3','','Tax Amount','',1,1,1,GETDATE(),1,GETDATE(),'','Tax Amount','',1,1
GO
Delete From CustomCaptions Where TransId=78 And CtrlId=1000 And SubCtrlId=5
GO
Insert Into CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
						   DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Select 78,1000,5,'MsgBox-78-1000-5','','','Cannot edit Routename transaction exists do you want to continue',1,1,1,GETDATE(),1,GETDATE(),
	   '','','Cannot edit Routename transaction exists do you want to continue',1,1
GO
Delete From CustomCaptions Where TransId=68 And SubCtrlId=25
GO
Insert Into CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Select 68,1000,25,'Msgbox-68-1000-25','','','Cannot Edit SalesmanName Transaction Exists Do You Want To Continue',1,1,1,GETDATE(),1,GETDATE(),
'','','Cannot Edit SalesmanName Transaction Exists Do You Want To Continue',1,1
GO
Delete From Configuration Where ModuleName='Stock Journal' And ModuleId='SJN6'
GO
Insert Into Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
Select 'SJN6','Stock Journal','Restrict selections of Unsalable Stock Type in the Available Stock Type column',0,0,0.00,6
GO
Delete From CustomCaptions Where TransId=5 And SubCtrlId=109 And CtrlId=1000
GO
Insert Into CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Select 5,1000,109,'Msgbox-5-1000-109','','','Do You Want To Continue',1,1,1,GETDATE(),1,GETDATE(),
'','','Do You Want To Continue',1,1
GO
IF NOT EXISTS(SELECT Name FROM SysColumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND Name='Distributor') AND Name = 'PDADistributor')
BEGIN
	ALTER TABLE Distributor	ADD PDADistributor INT 
END
GO
UPDATE Distributor SET PDADistributor=0 WHERE PDADistributor IS NULL
GO
IF EXISTS (Select * From Sysobjects Where Name = 'SchemeBudget' And XTYPE = 'U')
DROP TABLE SchemeBudget
GO
CREATE TABLE SchemeBudget
(
SchId INT,
BudgetUtilized NUMERIC(18,6)
)
GO
IF EXISTS (Select * From Sysobjects Where Name = 'Proc_ReturnBudgetUtilized' And XTYPE = 'P')
DROP PROCEDURE Proc_ReturnBudgetUtilized
GO
--Exec Proc_ReturnBudgetUtilized 0
CREATE PROCEDURE Proc_ReturnBudgetUtilized
(
	@Pi_Error INT
)
AS
/***********************************************
* FUNCTION: Fn_ReturnBudgetUtilized
* PURPOSE: Returns the Budget Utilized for the Selected Scheme
* NOTES:
* CREATED: Sathishkumar Veeramani	21-02-2012
* MODIFIED
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 22/04/2010	Nanda	   Added FBM Scheme	
************************************************/
BEGIN
	DELETE FROM SchemeBudget 
	INSERT INTO SchemeBudget (Schid,BudgetUtilized)
SELECT SchId,SUM(Budget) AS BudgetUtilized FROM (
	SELECT A.Schid,(ISNULL(SUM(FlatAmount - ReturnFlatAmount),0) +
		ISNULL(SUM(DiscountPerAmount - ReturnDiscountPerAmount),0)) AS Budget
		FROM SalesInvoiceSchemeLineWise A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE DlvSts <> 3 Group By A.Schid
    UNION ALL		
	SELECT A.Schid,ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0)AS Budget
		FROM SalesInvoiceSchemeDtFreePrd A (NOLOCK)INNER JOIN SalesInvoice B (NOLOCK)ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE DlvSts <> 3 Group By A.Schid
   UNION ALL		
	SELECT A.SchId,ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0)AS Budget
		FROM SalesInvoiceSchemeDtFreePrd A (NOLOCK)
		INNER JOIN SalesInvoice B (NOLOCK)ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster S (NOLOCK) ON A.SchId=S.SchId AND S.FBM=0
		WHERE DlvSts <> 3 GROUP BY A.SchId
   UNION ALL
    SELECT SchId,SUM(BudGet)AS BudGet FROM(
	SELECT SchId,ISNULL(SUM(AdjAmt),0)AS BudGet FROM SalesInvoiceWindowDisplay A(NOLOCK)
		INNER JOIN SalesInvoice B (NOLOCK)ON A.SalId = B.SalId
		WHERE DlvSts <> 3 GROUP BY SchId
	UNION ALL	
	SELECT 0 AS SchId,ISNULL(SUM(Amount),0) AS BudGet FROM ChequeDisbursalMaster A
		INNER JOIN ChequeDisbursalDetails B (NOLOCK)ON A.ChqDisRefNo = B.ChqDisRefNo
		WHERE TransType = 1)B GROUP BY SchId
	UNION ALL	
	SELECT SchId,ISNULL(SUM(DiscAmt),0) AS Budget FROM FBMSchDetails (NOLOCK)WHERE TransId IN (2)
	AND SchId IN(SELECT SchId FROM SchemeMaster (NOLOCK)WHERE FBM=1) Group By SchId
	UNION ALL
	--->Added By Nanda on 27/10/2010
	SELECT SchId,ISNULL(SUM(CrNoteAmount),0)AS Budget FROM SalesInvoiceQPSSchemeAdj SIQ (NOLOCK)
	INNER JOIN SalesInvoice SI ON SI.SalId=SIQ.SalId AND SI.DlvSts>3
	WHERE SIQ.SchId IN(SELECT SchId FROM SchemeMaster (NOLOCK)WHERE FBM=0) Group By SchId ) Z Group By SchId
	
END
GO
IF EXISTS(SELECT NAME FROM SysObjects WHERE name='CS2CN_PDADetails' AND XTYPE='U')
DROP TABLE CS2CN_PDADetails
CREATE TABLE CS2CN_PDADetails
	(
	[SlNo] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[CFACode] [nvarchar](50) NULL,
	[DistCode] [nvarchar](50) NULL,
	[BillDate] [datetime] NULL,
	[DfsName] [nvarchar](100) NULL,
	[Tot_No_Ord] [int] NULL,
	[PDA_No_Ord] [int] NULL,
	[Tot_Ord_Val] [numeric](38, 6) NULL,
	[PDA_Ord_Val] [numeric](38, 6) NULL,
	[PDA_Bill_Val] [numeric](38, 6) NULL,
	[Tot_Ord_Ln] [int] NULL,
	[PDA_Ord_Ln] [int] NULL,
	[PDA_Bill_Ln] [int] NULL,
	[UploadFlag] [nvarchar](5) NULL
	)
GO
IF EXISTS(SELECT NAME FROM SysObjects WHERE name='CS2CN_RtrSalesDetails' AND XTYPE='U')
DROP TABLE CS2CN_RtrSalesDetails
GO
CREATE TABLE CS2CN_RtrSalesDetails
	(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[CFACode] [nvarchar](50) NULL,
	[DistCode] [nvarchar](50) NULL,
	[DistName] [nvarchar](200) NULL,
	[Retailercode] [nvarchar](50) NULL,
	[RetailerName] [nvarchar](100) NULL,
	[Class] [nvarchar](50) NULL,
	[Category] [nvarchar](50) NULL,
	[BillDate] [datetime] NULL,
	[BillRefrNo] [nvarchar](50) NULL,
	[BatchCode] [nvarchar](50) NULL,
	[BillQty] [numeric](18, 0) NULL,
	[BillRate] [numeric](38, 6) NULL,
	[SellVatPerc] [numeric](38, 6) NULL,
	[SurChargePerc] [numeric](38, 6) NULL,
	[BillTaxAmt] [numeric](38, 6) NULL,
	[BillSurTaxAmt] [numeric](38, 6) NULL,
	[BillNetAmt] [numeric](38, 6) NULL,
	[BillStatus] [int] NULL,
	[Hinonhi] [nvarchar](50) NULL,
	[PGTyn] [int] NULL,
	[BillEdited] [int] NULL,
	[ItemMRP] [numeric](38, 6) NULL,
	[SchemePerc] [numeric](38, 6) NULL,
	[SchemeAmt] [numeric](38, 6) NULL,
	[DistDiscPerc] [numeric](38, 6) NULL,
	[DistDiscAmt] [numeric](38, 6) NULL,
	[CashDiscAmt] [numeric](38, 6) NULL,
	[SpecialDisc] [numeric](38, 6) NULL,
	[PaidAmt] [numeric](38, 6) NULL,
	[DfsName] [nvarchar](100) NULL,
	[MarketName] [nvarchar](100) NULL,
	[ItemName] [nvarchar](100) NULL,
	[PDA] [nvarchar](5) NULL,
	[DFS_Id] [nvarchar](10) NULL,
	[MKT_Id] [nvarchar](10) NULL,
	[UpdatedOn] [datetime] NULL,
	[UploadFlag] [nvarchar](5) NULL
	)
GO
UPDATE Supplier SET SpmTinNo=0 WHERE SpmTinNo IS NULL
UPDATE Supplier SET SpmSupplier=0 WHERE SpmSupplier IS NULL
GO
DELETE FROM  CustomCaptions WHERE TransId=45 and CtrlId=1000 AND  SubCtrlId=108
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (45,1000,108,'PnlMsg-45-1000-108','','Select to reduce tax for flat scheme','',1,1,1,'2009-10-09',1,'2009-10-09','','Select to reduce tax for flat scheme','',1,1)
GO
DELETE FROM  CustomCaptions WHERE TransId=45 and CtrlId=1000 AND  SubCtrlId=109
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (45,1000,109,'Msgbox-45-1000-109','','','Reduce Tax Only applicable for flat amount',1,1,1,'2009-11-17',1,'2009-11-17','','','Reduce Tax Only applicable for flat amount',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId=206 AND CtrlName='MsgBox-206-1000-11' AND SubCtrlId=11
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 206,1000,11,'MsgBox-206-1000-11','','','Back Dated Transactions not Allowed,Last transaction date is ',1,1,1,GETDATE(),1,GETDATE(),'','','Back Dated Transactions not Allowed,Last transaction date is',1,1
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='OutputTaxPercentage')
DROP TABLE OutputTaxPercentage
GO
CREATE TABLE OutputTaxPercentage
(
	TransId TinyInt,
	Salid NUMERIC(36,0),
	PrdSlno INT,
	TaxPerc NUMERIC(36,4)
)
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='SalesInvoiceSchemeClaimDt')
BEGIN
CREATE TABLE SalesInvoiceSchemeClaimDt
(
Salid NUMERIC(36,0),
SchId INT,
SlabId INT,
RowId INT,
PrdId INT,
Prdbatid INT,
FlatAmount NUMERIC(36,4),
DisCountAmt NUMERIC(36,4),
SchClmId	INT
)	
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='ReturnSchemeClaimDt')
BEGIN
CREATE TABLE ReturnSchemeClaimDt
(
ReturnId NUMERIC(36,0),
SchId INT,
SlabId INT,
RowId INT,
PrdId INT,
Prdbatid INT,
FlatAmount NUMERIC(36,4),
DisCountAmt NUMERIC(36,4),
SchClmId	INT
)	
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE ='U'AND name = 'ETLTempPurchaseFreeProduct')
DROP TABLE ETLTempPurchaseFreeProduct
GO
CREATE TABLE ETLTempPurchaseFreeProduct
(
	[CmpId] NVARCHAR(10) null,
	[CmpInvno] NVARCHAR(200) NULL,
	[InvDate] DATETIME NULL,
	[TransTypeId] NVARCHAR(10) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[StockTypeId] NVARCHAR(50) NULL,
	[LcnId] [int] NULL,
	[UomId] NVARCHAR(10) NULL,
	[InvQty] INT NULL,
	[TypeId] INT NULL,
	[ReasonId] NVARCHAR(50) NULL,
	[Status] INT
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_ManualFreeStockAdjusment')
DROP PROCEDURE Proc_ManualFreeStockAdjusment
GO
/* BEGIN TRANSACTION
   EXEC Proc_ManualFreeStockAdjusment 79
   ROLLBACK TRANSACTION */
CREATE PROCEDURE Proc_ManualFreeStockAdjusment
(
  @Pi_PurRcptId INT
)
AS
/*********************************
* PROCEDURE	: Proc_ManualFreeStockAdjusment
* PURPOSE	: To Add Free Prdouct Automatically in Stock Management
* CREATED	: Sathishkumar Veeramani
* CREATED DATE	: 20/03/2013
* MODIFIED BY : 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
SET NOCOUNT ON

DECLARE @Transdate AS DATETIME 
DECLARE @PrdId AS INT
DECLARE @PrdBatId AS INT
DECLARE @LcnId AS INT
DECLARE @Status AS INT
DECLARE @InvDate AS DATETIME
DECLARE @InvQty AS NUMERIC(18,0)
DECLARE @GetKeyStr AS NVARCHAR(50)
DECLARE @CmpInvNo AS NVARCHAR(100)
SELECT @Status= ISNULL([Status],0) FROM Configuration WHERE ModuleId='RET40' AND ModuleName='Retailer' AND [Status]=1
    
	IF EXISTS (SELECT * FROM PurchaseReceipt WHERE PurRcptId = @Pi_PurRcptId AND [Status] = 1)
	BEGIN
			IF @Status = 1
			BEGIN
					  SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('StockManagement','StkMngRefNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					  
	          
					  SELECT @InvDate = GoodsRcvdDate,@CmpInvNo = CmpInvNo FROM PurchaseReceipt WITH (NOLOCK) WHERE PurRcptId = @Pi_PurRcptId
			          
					  SELECT Z.PrdId,A.PrdBatId,A.PriceId,ISNULL(PrdBatDetailValue,0) AS Rate INTO #PurchaseFreeStockRate 
					  FROM ProductBatchDetails A WITH (NOLOCK) INNER JOIN (
					  SELECT DISTINCT A.PrdId,A.PrdBatId,MAX(PriceId) AS PriceId FROM ETLTempPurchaseFreeProduct A WITH (NOLOCK)
					  INNER JOIN ProductBatchDetails B WITH (NOLOCK) ON A.PrdBatId = B.PrdBatId 
					  WHERE A.CmpInvno = @CmpInvNo AND A.[Status] = 0 GROUP BY A.PrdId,A.PrdBatId) Z ON
					  A.PrdBatId = Z.PrdBatId AND A.PriceId = Z.PriceId WHERE A.SLNo = 2 
			          
					  INSERT INTO StockManagement (StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,DecPoints,OpenBal,
					  [Status],Availability,LastModBy,LastModDate,AuthId,AuthDate,ConfigValue,XMLUpload)
					  SELECT DISTINCT @GetKeyStr,@InvDate,LcnId,TransTypeId,0,0,@CmpInvNo,'Posted From Purchase Receipt FreeStock-'+CAST(@CmpInvNo AS NVARCHAR(50)),
					  3,0,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0,0 
					  FROM ETLTempPurchaseFreeProduct WITH (NOLOCK) WHERE CmpInvNo = @CmpInvNo AND [Status] = 0
			          
					  INSERT INTO StockManagementProduct (StkMngRefNo,PrdId,PrdBatId,StockTypeId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,
					  Availability,LastModBy,LastModDate,AuthId,AuthDate,TaxAmt,StkMgmtTypeId)
					  SELECT DISTINCT @GetKeyStr,A.PrdId,A.PrdBatId,StockTypeId,UOMId,InvQty,0,0,InvQty,Rate,(InvQty*Rate),ReasonId,0 AS PriceId,1,1,
					  CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0.00 AS TaxAmt,TransTypeId
					  FROM ETLTempPurchaseFreeProduct A WITH (NOLOCK)
					  INNER JOIN #PurchaseFreeStockRate B WITH (NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
					  WHERE A.CmpInvNo = @CmpInvNo AND A.[Status] = 0
			          
					  EXEC Proc_VoucherPosting 13,1,@GetKeyStr,5,0,2,@InvDate,0
			          
					  UPDATE COUNTERS SET CurrValue = CurrValue + 1 WHERE Tabname = 'StockManagement'
								
					DECLARE CUR_STOCKADJ CURSOR
					FOR SELECT PrdId,PrdBatId,LcnId,StkMngDate,TotalQty	FROM StockManagement A WITH (NOLOCK),
					StockManagementProduct B WITH (NOLOCK) WHERE A.StkMngRefNo = B.StkMngRefNo AND A.StkMngRefNo = @GetKeyStr
					OPEN CUR_STOCKADJ		
					FETCH NEXT FROM CUR_STOCKADJ INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@InvQty
					WHILE @@FETCH_STATUS = 0
					BEGIN										
							EXEC Proc_UpdateStockLedger 1,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@InvQty,1,0
							EXEC Proc_UpdateProductBatchLocation 1,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@InvQty,1,0
									
					FETCH NEXT FROM CUR_STOCKADJ INTO  @PrdId,@PrdBatId,@LcnId,@InvDate,@InvQty
					END
					CLOSE CUR_STOCKADJ
					DEALLOCATE CUR_STOCKADJ	
					UPDATE ETLTempPurchaseFreeProduct SET [Status] = 1 WHERE CmpInvNo IN 
				    (SELECT CmpInvNo FROM PurchaseReceipt WITH (NOLOCK) WHERE [Status] = 1)
		 END
	END   
END
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE XTYPE='U' AND NAME='Specialrate')
BEGIN
	CREATE TABLE Specialrate
	(
		SplrateId		BIGINT,
		SplrateRefNo	VARCHAR(50),
		SplrateDate		DATETIME,
		CmpId			INT,
		CtglevelId		INT,
		CtgMainId		INT,
		RtrId			INT,
		PrdCtgLevelId	INT,
		PrdCtgValMainId	INT,
		PrdId			INT,
		Availability	TINYINT,
		LastModBy		TINYINT,
		LastModDate		DATETIME,
		AuthId			TINYINT,
		AuthDate		DATETIME,
		Upload			TINYINT,
		Populate		TINYINT
		CONSTRAINT PK_Specialrate_SplrateId PRIMARY KEY (SplrateId ASC),
		CONSTRAINT UQ_SpecialRate_SplrateRefNo UNIQUE(SplrateRefNo),
		--CONSTRAINT FK_Specialrate_CmpId FOREIGN KEY(CmpId) REFERENCES Company(CmpId),
		--CONSTRAINT FK_Specialrate_CtglevelId FOREIGN KEY(CtglevelId) REFERENCES RetailerCategorylevel(CtgLevelId),
		--CONSTRAINT FK_Specialrate_CtgMainId FOREIGN KEY(CtgMainId) REFERENCES RetailerCategory(CtgMainId),
		--CONSTRAINT FK_Specialrate_RtrId FOREIGN KEY(RtrId) REFERENCES Retailer(RtrId)
	)
END
GO
IF NOT EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='U' AND name='SpecialrateProducts')
BEGIN
	CREATE TABLE SpecialrateProducts
	(
		SplrateId		BIGINT,
		CtglevelId		INT,
		CtgMainId		INT,
		RtrId			INT,
		PrdId			INT,
		PrdCCode		VARCHAR(100),
		SpecialRate		NUMERIC(38,6),
		EffFromDate		DATETIME,
		CreatedDate		DATETIME,
		Availability	TINYINT,
		LastModBy		TINYINT,
		LastModDate		DATETIME,
		AuthId			TINYINT,
		AuthDate		DATETIME,
		CONSTRAINT FK_SpecialrateProducts_SplrateId FOREIGN KEY (SplrateId) REFERENCES Specialrate(SplrateId),
		CONSTRAINT FK_SpecialrateProducts_CtglevelId FOREIGN KEY(CtglevelId) REFERENCES RetailerCategorylevel(CtgLevelId),
		CONSTRAINT FK_SpecialrateProducts_CtgMainId FOREIGN KEY(CtgMainId) REFERENCES RetailerCategory(CtgMainId),
		--CONSTRAINT FK_SpecialrateProducts_RtrId FOREIGN KEY(RtrId) REFERENCES Retailer(RtrId),
		CONSTRAINT FK_SpecialrateProducts_PrdId	FOREIGN KEY (PrdId) REFERENCES Product(PrdId),
		CONSTRAINT CHK_SpecialRate CHECK(SpecialRate>0)
	)
END
GO
IF NOT EXISTS (SELECT * FROM Counters WHERE TabName='Specialrate' AND FldName='SplrateId')
BEGIN
	INSERT INTO Counters (TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT 'Specialrate','SplrateId','',0,1,0,'Special Rate',0,YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE()
END
GO
IF NOT EXISTS (SELECT * FROM Counters WHERE TabName='Specialrate' AND FldName='SplrateRefNo')
BEGIN
	INSERT INTO Counters (TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT 'Specialrate','SplrateRefNo','SPL',5,1,0,'Special Rate',1,YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE()
END
GO
DELETE FROM CustomCaptions WHERE TransId=252 AND CtrlId IN (14,15) AND SubCtrlId IN (1)  
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
							DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 252,14,1,'fxtCtgLevelId','Retailer Category Level','Press F4/Double click to select Retailer Hierarchy Level','',1,1,1,GETDATE(),1,GETDATE(),
'Hierarchy Level','Press F4/Double click to select Retailer Hierarchy Level','',1,1
UNION
SELECT 252,15,1,'fxtCtgMainId','Retailer Category Level Value','Press F4/Double click to select Retailer Hierarchy Value','',1,1,1,GETDATE(),1,GETDATE(),
'Hierarchy Level','Press F4/Double click to select Retailer Hierarchy Value','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=252 AND CtrlId IN (17) AND SubCtrlId IN (2) AND CtrlName='DgCommon-252-17-2' 
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
							DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 252,17,2,'DgCommon-252-17-2','Category Level Value','','',1,1,1,GETDATE(),1,GETDATE(),
'Category Level Value','','',1,1
GO
DELETE FROM CustomCaptions WHERE  TransId=252 AND CtrlId=17 AND SubCtrlId IN (1,2,3,4,5,6,7,8)
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
							DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 252,17,1,'DgCommon-252-17-1','Category Level','Press F4/Double click to select Retailer Hierarchy Level','',1,1,1,GETDATE(),1,GETDATE(),
'Category Level','Press F4/Double click to select Retailer Hierarchy Level','',1,1
UNION
SELECT 252,17,2,'DgCommon-252-17-2','Category Level Value','Press F4/Double click to select Retailer Hierarchy Level Value','',1,1,1,GETDATE(),1,GETDATE(),
'Category Level','Press F4/Double click to select Retailer Hierarchy Level Value','',1,1
UNION
SELECT 252,17,3,'DgCommon-252-17-3','Retailer Code','Press F4/Double click to select Retailer Code','',1,1,1,GETDATE(),1,GETDATE(),
'Retailer Code','Press F4/Double click to select Retailer Code','',1,1
UNION
SELECT 252,17,4,'DgCommon-252-17-4','Product Code','Press F4/Double click to select Product Code','',1,1,1,GETDATE(),1,GETDATE(),
'Retailer Code','Press F4/Double click to select Product Code','',1,1
UNION
SELECT 252,17,5,'DgCommon-252-17-5','Product Name','','',1,1,1,GETDATE(),1,GETDATE(),
'Product Name','','',1,1
UNION
SELECT 252,17,6,'DgCommon-252-17-6','Special Rate','Enter Special Rate','',1,1,1,GETDATE(),1,GETDATE(),
'Special Rate','Enter Special Rate','',1,1
UNION
SELECT 252,17,7,'DgCommon-252-17-7','Effective From','Press F4/Double click to select Effective From Date','',1,1,1,GETDATE(),1,GETDATE(),
'Special Rate','Press F4/Double click to select Effective From Date','',1,1
UNION
SELECT 252,17,8,'DgCommon-252-17-8','Downloaded On','Press F4/Double click to select Downloaded On Date','',1,1,1,GETDATE(),1,GETDATE(),
'Downloaded On','Press F4/Double click to select Downloaded On Date','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=252 AND CtrlId=2000 AND SubCtrlId=13
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
							DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 252,2000,13,'MsgBox-252-2000-13','','','with reference number ',1,1,1,GETDATE(),1,GETDATE(),
'','','with reference number ',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=252 AND CtrlId=2000 AND SubCtrlId=14
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
							DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 252,2000,14,'MsgBox-252-2000-14','','','Cannot edit,transaction exists',1,1,1,GETDATE(),1,GETDATE(),
'','','Cannot edit,transaction exists',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=252 AND CtrlId=2000 AND SubCtrlId=15
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
							DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 252,2000,15,'MsgBox-252-2000-15','','','Duplicate Rows not Allowed',1,1,1,GETDATE(),1,GETDATE(),
'','','Duplicate Rows not Allowed',1,1
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='U' AND name='TempPopulateSpecialrateProduct')
DROP TABLE TempPopulateSpecialrateProduct
GO
CREATE TABLE TempPopulateSpecialrateProduct
(
	CtgLevelId			INT,
	CtgMainId			INT,
	CtgLevelName		VARCHAR(100),
	CtgCode				VARCHAR(100),
	RtrId				INT,
	RtrCode				VARCHAR(200),
	CmpPrdCtgId			INT,
	CmpPrdCtgName		VARCHAR(200),
	PrdCtgValMainId		INT,
	PrdCtgValLinkCode	VARCHAR(200),
	PrdCtgValName		VARCHAR(200),
	PrdId				INT,
	PrdCCode			VARCHAR(200),
	PrdName				VARCHAR(500)
)
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_PopulateSpecialrareProduct')
DROP PROCEDURE Proc_PopulateSpecialrareProduct
GO
/*
	BEGIN TRAN
		EXEC Proc_PopulateSpecialrareProduct 1,5,0,0,'0000100003',438,0
		SELECT * FROM TempPopulateSpecialrateProduct
	ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_PopulateSpecialrareProduct
(
	@Pi_CtgLevelId			INT,
	@Pi_CtgMainId			INT,
	@Pi_RtrId				INT,
	@Pi_CmpPrdCtgId			INT,
	@Pi_PrdCtgLinkCode		VARCHAR(500),
	@Pi_PrdCtgValMainId		INT,
	@Pi_PrdId				INT
)
AS
/*********************************
* PROCEDURE		: Proc_PopulateSpecialrareProduct
* PURPOSE		: To Populate the product based on selection in special rate screen
* CREATED		: Praveenraj B
* CREATED DATE	: 04/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
SET NOCOUNT ON
BEGIN
		DELETE Q FROM TempPopulateSpecialrateProduct Q (NOLOCK)
			
		DECLARE @TempPopulateSpecialrateProduct TABLE
		(
			CtgLevelId			INT,
			CtgMainId			INT,
			CtgLevelName		VARCHAR(100),
			CtgCode				VARCHAR(100),
			RtrId				INT,
			RtrCode				VARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		VARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValLinkCode	VARCHAR(200),
			PrdCtgValName		VARCHAR(200),
			PrdId				INT,
			PrdCCode			VARCHAR(200),
			PrdName				VARCHAR(500)
		)
		
		SET @Pi_PrdCtgLinkCode=@Pi_PrdCtgLinkCode+'%'
		IF ISNULL(@Pi_CtgMainId,0)=0
		BEGIN
			INSERT INTO TempPopulateSpecialrateProduct (CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName)
			SELECT DISTINCT E.CtgLevelId,D.CtgMainId,E.CtgLevelName,D.CtgCode,0 RtrId,'ALL' RtrCode,AA.CmpPrdCtgId,'' CmpPrdCtgName, 
			AA.PrdCtgValMainId,AA.PrdCtgValLinkCode,AA.PrdCtgValName,AA.PrdId,AA.PrdCCode,AA.PrdName
			FROM RetailerValueClassMap B 
			INNER JOIN RetailerValueClass C ON B.RtrValueClassId=C.RtrClassId 
			INNER JOIN RetailerCategory D ON D.CtgMainId=C.CtgMainId
			INNER JOIN RetailerCategoryLevel E ON E.CtgLevelId=D.CtgLevelId
			CROSS JOIN (
			
			SELECT DISTINCT A.PrdId,A.PrdCCode,A.PrdName,B.CmpPrdCtgId,B.PrdCtgValMainId,B.PrdCtgValLinkCode,B.PrdCtgValName FROM Product A
			INNER JOIN ProductBatch PB ON A.PrdId=PB.PrdID 
			INNER JOIN ProductCategoryValue B ON B.PrdCtgValMainId=A.PrdCtgValMainId
			WHERE PrdStatus=1 
			) AA
		END
		IF ISNULL(@Pi_CtgMainId,0)<>0
		BEGIN
			INSERT INTO TempPopulateSpecialrateProduct (CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName)
			SELECT DISTINCT E.CtgLevelId,D.CtgMainId,E.CtgLevelName,D.CtgCode,0 RtrId,'ALL' RtrCode,AA.CmpPrdCtgId,'' CmpPrdCtgName, 
			AA.PrdCtgValMainId,AA.PrdCtgValLinkCode,AA.PrdCtgValName,AA.PrdId,AA.PrdCCode,AA.PrdName
			FROM RetailerValueClassMap B 
			INNER JOIN RetailerValueClass C ON B.RtrValueClassId=C.RtrClassId 
			INNER JOIN RetailerCategory D ON D.CtgMainId=C.CtgMainId
			INNER JOIN RetailerCategoryLevel E ON E.CtgLevelId=D.CtgLevelId
			CROSS JOIN (
			SELECT DISTINCT A.PrdId,A.PrdCCode,A.PrdName,B.CmpPrdCtgId,B.PrdCtgValMainId,B.PrdCtgValLinkCode,B.PrdCtgValName FROM Product A
			INNER JOIN ProductBatch PB ON A.PrdId=PB.PrdID 
			INNER JOIN ProductCategoryValue B ON B.PrdCtgValMainId=A.PrdCtgValMainId
			WHERE PrdStatus=1 ) AA WHERE D.CtgMainId=ISNULL(@Pi_CtgMainid,0) AND E.CtgLevelId=ISNULL(@Pi_CtgLevelId,0)
		END
		IF ISNULL(@Pi_CtgMainId,0)<>0 AND @Pi_RtrId<>0
		BEGIN
			INSERT INTO TempPopulateSpecialrateProduct (CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName)
			SELECT DISTINCT E.CtgLevelId,D.CtgMainId,E.CtgLevelName,D.CtgCode,A.RtrId,A.RtrCode,AA.CmpPrdCtgId,'' CmpPrdCtgName, 
			AA.PrdCtgValMainId,AA.PrdCtgValLinkCode,AA.PrdCtgValName,AA.PrdId,AA.PrdCCode,AA.PrdName
			FROM Retailer A INNER JOIN RetailerValueClassMap B ON A.RtrId=B.RtrId 
			INNER JOIN RetailerValueClass C ON B.RtrValueClassId=C.RtrClassId 
			INNER JOIN RetailerCategory D ON D.CtgMainId=C.CtgMainId
			INNER JOIN RetailerCategoryLevel E ON E.CtgLevelId=D.CtgLevelId
			CROSS JOIN (
			SELECT DISTINCT A.PrdId,A.PrdCCode,A.PrdName,B.CmpPrdCtgId,B.PrdCtgValMainId,B.PrdCtgValLinkCode,B.PrdCtgValName FROM Product A
			INNER JOIN ProductBatch PB ON A.PrdId=PB.PrdID 
			INNER JOIN ProductCategoryValue B ON B.PrdCtgValMainId=A.PrdCtgValMainId
			WHERE PrdStatus=1 ) AA WHERE D.CtgMainId=ISNULL(@Pi_CtgMainid,0) AND E.CtgLevelId=ISNULL(@Pi_CtgLevelId,0) AND A.RtrId=ISNULL(@Pi_RtrId,0)
		END
		IF ISNULL(@Pi_CmpPrdCtgId,0)=0 AND ISNULL(@Pi_PrdCtgValMainId,0)=0 AND ISNULL(@Pi_PrdId,0)=0
		BEGIN
			DELETE FROM @TempPopulateSpecialrateProduct
			INSERT INTO @TempPopulateSpecialrateProduct(CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName)
			SELECT CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
				   PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName 
			FROM TempPopulateSpecialrateProduct
		END
		ELSE IF ISNULL(@Pi_CmpPrdCtgId,0)<>0 AND ISNULL(@Pi_PrdCtgValMainId,0)=0 AND ISNULL(@Pi_PrdId,0)=0
		BEGIN
			DELETE FROM @TempPopulateSpecialrateProduct
			INSERT INTO @TempPopulateSpecialrateProduct(CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName)
			SELECT CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
				   PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName 
			FROM TempPopulateSpecialrateProduct
		END
		ELSE IF ISNULL(@Pi_PrdCtgValMainId,0)<>0 AND ISNULL(@Pi_PrdId,0)=0
		BEGIN
			DELETE FROM @TempPopulateSpecialrateProduct
			INSERT INTO @TempPopulateSpecialrateProduct(CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName)
			SELECT CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
				   PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName 
			FROM TempPopulateSpecialrateProduct WHERE PrdCtgValLinkCode LIKE @Pi_PrdCtgLinkCode
			
		END
		ELSE IF ISNULL(@Pi_PrdCtgValMainId,0)<>0 AND ISNULL(@Pi_PrdId,0)<>0
		BEGIN
			DELETE FROM @TempPopulateSpecialrateProduct
			INSERT INTO @TempPopulateSpecialrateProduct(CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName)
			SELECT CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
				   PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName 
			FROM TempPopulateSpecialrateProduct WHERE PrdId IN (ISNULL(@Pi_PrdId,0))
			AND PrdCtgValLinkCode LIKE @Pi_PrdCtgLinkCode
		END
		DELETE A FROM TempPopulateSpecialrateProduct A  (NOLOCK)
		
		INSERT INTO TempPopulateSpecialrateProduct (CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName)
		SELECT CtgLevelId,CtgMainId,CtgLevelName,CtgCode,RtrId,RtrCode,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
														PrdCtgValLinkCode,PrdCtgValName,PrdId,PrdCCode,PrdName FROM @TempPopulateSpecialrateProduct
RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE name='Fn_ReturnSplrateProducts' AND XTYPE='TF')
DROP FUNCTION Fn_ReturnSplrateProducts
GO
--SELECT * FROM Fn_ReturnSplrateProducts (0,0,0,0,'01mxgja200k1')
CREATE FUNCTION Fn_ReturnSplrateProducts
(
	@Pi_CmpPrdCtgId			INT,
	@Pi_PrdCtgValMainId		INT,
	@Pi_PrdCtgValLinkCode	VARCHAR(200),
	@Pi_PrdId				INT,
	@Pi_PrdCCode			VARCHAR(100)
)
RETURNS @Product TABLE
(
	PrdId		INT,
	PrdCCode	VARCHAR(100),
	PrdName		VARCHAR(200)
)
AS
/*********************************
* PROCEDURE		: Fn_ReturnSplrateProducts
* PURPOSE		: To Populate the product based on selection in special rate screen
* CREATED		: Praveenraj B
* CREATED DATE	: 04/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
		SET @Pi_PrdCtgValLinkCode=@Pi_PrdCtgValLinkCode+'%'
		IF @Pi_PrdCtgValMainId<>0 AND @Pi_PrdId<>0
		BEGIN
			INSERT INTO @Product(PrdId,PrdCCode,PrdName)
			SELECT DISTINCT A.PrdId,PrdCCode,PrdName FROM Product A 
			INNER JOIN ProductBatch B ON A.PrdId=B.PrdId 
			INNER JOIN ProductCategoryValue C ON C.PrdCtgValMainId=A.PrdCtgValMainId
			WHERE PrdStatus=1 AND C.PrdCtgValLinkCode LIKE @Pi_PrdCtgValLinkCode AND A.PrdId=@Pi_PrdId AND A.PrdCCode=@Pi_PrdCCode
			ORDER BY PrdName
		END
		ELSE IF @Pi_PrdCtgValMainId<>0 AND @Pi_PrdId=0
		BEGIN
			INSERT INTO @Product(PrdId,PrdCCode,PrdName)
			SELECT DISTINCT A.PrdId,PrdCCode,PrdName FROM Product A 
			INNER JOIN ProductBatch B ON A.PrdId=B.PrdId 
			INNER JOIN ProductCategoryValue C ON C.PrdCtgValMainId=A.PrdCtgValMainId
			WHERE PrdStatus=1 AND C.PrdCtgValLinkCode LIKE @Pi_PrdCtgValLinkCode AND A.PrdCCode=@Pi_PrdCCode
			ORDER BY PrdName
		END
		ELSE IF @Pi_PrdCtgValMainId=0 AND @Pi_PrdId<>0
		BEGIN
			INSERT INTO @Product(PrdId,PrdCCode,PrdName)
			SELECT DISTINCT A.PrdId,PrdCCode,PrdName FROM Product A 
			INNER JOIN ProductBatch B ON A.PrdId=B.PrdId 
			INNER JOIN ProductCategoryValue C ON C.PrdCtgValMainId=A.PrdCtgValMainId
			WHERE PrdStatus=1 AND A.PrdId=@Pi_PrdId AND A.PrdCCode=@Pi_PrdCCode
			ORDER BY PrdName
		END
		ELSE IF @Pi_PrdCtgValMainId=0 AND @Pi_PrdId=0
		BEGIN
			INSERT INTO @Product(PrdId,PrdCCode,PrdName)
			SELECT DISTINCT A.PrdId,PrdCCode,PrdName FROM Product A 
			INNER JOIN ProductBatch B ON A.PrdId=B.PrdId 
			INNER JOIN ProductCategoryValue C ON C.PrdCtgValMainId=A.PrdCtgValMainId
			WHERE PrdStatus=1 AND A.PrdCCode=@Pi_PrdCCode
			ORDER BY PrdName
		END
RETURN
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='SpecialRateAftDownLoad' AND B.name='SplrateId')
BEGIN
	ALTER TABLE SpecialRateAftDownLoad ADD SplrateId INT DEFAULT 0 WITH VALUES 
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_ValidateSpecialRateManual')
DROP PROCEDURE Proc_ValidateSpecialRateManual
GO
/*
BEGIN TRAN
EXEC Proc_ValidateSpecialRateManual 1,0
--SELECT * FROM SpecialRateAftDownLoad
--SELECT * FROM ContractPricingDetails
--SELECT * FROM ContractPricingMaster
--SELECT * FROM Specialrate
--SELECT * FROM SpecialrateProducts
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_ValidateSpecialRateManual
(
	@Pi_SplrateId INT,
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ValidateSpecialRateManual
* PURPOSE		: To Insert and Update Special Rate records From Special rate screen
* CREATED		: Praveenraj B
* CREATED DATE	: 04/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
SET NOCOUNT ON
/*
	BEGIN TRAN
		EXEC Proc_ValidateSpecialRateDetails 0
		SELECT * FROM ContractPricingMaster
		SELECT * FROM ContractPricingDetails
		--SELECT * FROM SpecialRateAftDownLoad
		--SELECT * FROM ProductBatchDetails (NOLOCK)--32295
		--SELECT * FROM Errorlog
		SELECT * FROM TEMPSpecialRateProductDet
		Select * from SpecialRateAftDownLoad
	ROLLBACK TRAN
*/
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
	DECLARE @ErrNo					AS	INT
	SET @Po_ErrNo=0
	SET @ErrStatus=0
	SET @ErrNo=0
	
	
	DELETE A FROM ErrorLog A (NOLOCK) WHERE A.TableName='Special Rate'
	
	SELECT @ContractReq=ISNULL(Status,0) FROM Configuration (NOLOCK) WHERE ModuleId In ('BL2')
	SELECT @SRReCalc=ISNULL(Status,0) FROM Configuration (NOLOCK) WHERE ModuleId In ('BL1')
	SET @ContractReq=1
	DELETE A FROM Cn2Cs_Prk_ContractPricing A (NOLOCK)
	IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='U' AND name='SplRateToAvoid_Manual')
	BEGIN
		DROP TABLE SplRateToAvoid_Manual
	END
	CREATE TABLE SplRateToAvoid_Manual
	(
		RtrHierLevel	NVARCHAR(100),
		RtrHierValue	NVARCHAR(100),
		RtrCode			NVARCHAR(100),
		PrdCCode		NVARCHAR(100),
		PrdBatCode		NVARCHAR(100)
	)
			--IF NOT EXISTS (SELECT Distinct ISNULL(RtrId,0) AS Rtrid  FROM SpecialrateProducts T (NOLOCK) INNER JOIN RetailerCategory RC (NOLOCK) on T.ctgcode=RC.ctgcode 
			--				INNER JOIN  RetailerValueClass RVC (NOLOCK) on RC.CtgMainId=RVC.CtgMainId
			--				LEFT OUTER JOIN RetailerValueClassMap RVCM (NOLOCK)  on RVCM.RtrValueClassId=RVC.RtrClassId WHERE RtrId>0) 
			--BEGIN
			--	SET @Po_ErrNo=1
			--	INSERT INTO SplRateToAvoid_Manual(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
			--	SELECT DISTINCT CtgLevelName,T.CtgCode,RtrCode,PrdCCode,PrdBatCode  FROM TEMPSpecialRateProductDet T (NOLOCK) INNER JOIN RetailerCategory RC (NOLOCK) on T.ctgcode=RC.ctgcode 
			--	INNER JOIN  RetailerValueClass RVC (NOLOCK) on RC.CtgMainId=RVC.CtgMainId
			--	WHERE NOT EXISTS (SELECT RtrValueClassId,rtrid FROM  RetailerValueClassMap RVCM (NOLOCK) WHERE RVCM.RtrValueClassId=RVC.RtrClassId)
			--	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			--	SELECT DISTINCT 1,'Special Rate','Retailer','Retailer Not Attached to Category:'+RtrHierLevel+' Not Available' FROM SplRateToAvoid (NOLOCK)
			--	DELETE A FROM TEMPSpecialRateProductDet A  (NOLOCK) WHERE CtgLevelName+CtgCode+RtrCode+PrdCCode in
			--	(SELECT RtrHierLevel+RtrHierValue+RtrCode+PrdCCode from SplRateToAvoid_Manual)
			--END
	--IF EXISTS(SELECT * FROM TEMPSpecialRateProductDet(NOLOCK) WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product (NOLOCK)))
	--BEGIN
	--	SET @Po_ErrNo=1
	--	INSERT INTO SplRateToAvoid_Manual(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
	--	SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
	--	FROM TEMPSpecialRateProductDet (NOLOCK)
	--	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product (NOLOCK))
	--	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	--	SELECT DISTINCT 1,'Special Rate','ProductCode','Product Code: '+PrdCCode+' Not Available' FROM TEMPSpecialRateProductDet (NOLOCK)
	--	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product (NOLOCK))
	--END
	--IF EXISTS(SELECT * FROM TEMPSpecialRateProductDet (NOLOCK)
	--WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P (NOLOCK),ProductBatch PB (NOLOCK) WHERE P.PrdId=PB.PrdId))
	--BEGIN
	--	SET @Po_ErrNo=1
	--	INSERT INTO SplRateToAvoid_Manual(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
	--	SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
	--	FROM TEMPSpecialRateProductDet (NOLOCK)
	--	WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P (NOLOCK),ProductBatch PB (NOLOCK) WHERE P.PrdId=PB.PrdId)
	--	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	--	SELECT DISTINCT 1,'Special Rate','ProductCode','Batch is not available for Product Code:'+PrdCCode FROM TEMPSpecialRateProductDet (NOLOCK)
	--	WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P (NOLOCK),ProductBatch PB (NOLOCK) WHERE P.PrdId=PB.PrdId)
	--END
	--IF EXISTS(SELECT * FROM TEMPSpecialRateProductDet (NOLOCK)
	--WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel (NOLOCK)))
	--BEGIN
	--	SET @Po_ErrNo=1
	--	INSERT INTO SplRateToAvoid_Manual(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
	--	SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
	--	FROM TEMPSpecialRateProductDet
	--	WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel (NOLOCK))
	--	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	--	SELECT DISTINCT 1,'Special Rate','Retailer Category Level','Retailer Category Level:'+CtgLevelName+' Not Available' FROM TEMPSpecialRateProductDet (NOLOCK)
	--	WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel (NOLOCK))
	--END
	--IF EXISTS(SELECT * FROM TEMPSpecialRateProductDet (NOLOCK)
	--WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory (NOLOCK)))
	--BEGIN
	--	SET @Po_ErrNo=1
	--	INSERT INTO SplRateToAvoid_Manual(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
	--	SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
	--	FROM TEMPSpecialRateProductDet (NOLOCK)
	--	WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory (NOLOCK))
	--	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	--	SELECT DISTINCT 1,'Special Rate','Retailer Category Level Value','Retailer Category Level Value:'+CtgCode+' Not Available' FROM TEMPSpecialRateProductDet (NOLOCK)
	--	WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory (NOLOCK))
	--END

	SELECT @CmpId=ISNULL(CmpId,0) FROM Company C  (NOLOCK) WHERE DefaultCompany=1
	DECLARE Cur_SpecialRate CURSOR
	FOR SELECT ISNULL(RCL.CtgLevelName,''),ISNULL(RC.CtgCode,''),
		ISNULL(R.RtrCode,'ALL'),ISNULL(P.PrdCCode,''),ISNULL(PB.PrdBatCode,''),ISNULL(B.SpecialRate,0),
		ISNULL(B.EffFromDate,GETDATE()),'2013-12-31',ISNULL(CreatedDate,GETDATE()),ISNULL(P.PrdId,0) AS PrdId,
		ISNULL(RCL.CtgLevelId,0) AS CtgLevelId,ISNULL(RC.CtgMainId,0) AS CtgMainId
		FROM Specialrate Prk (NOLOCK) 
		INNER JOIN SpecialrateProducts B (NOLOCK) ON Prk.SplrateId=B.SplrateId
		INNER JOIN Product P  (NOLOCK) ON B.PrdId=P.PrdId
		INNER JOIN ProductBatch PB ON P.PrdId=PB.PrdId 
		INNER JOIN RetailerCategoryLevel RCL (NOLOCK) ON B.CtglevelId=RCL.CtgLevelId 
		INNER JOIN RetailerCategory RC (NOLOCK) ON B.CtgMainId=RC.CtgMainId
		LEFT OUTER JOIN Retailer R ON R.RtrId=B.RtrId
		WHERE Prk.SplrateId=@Pi_SplRateId AND
		RCL.CtgLevelName+'~'+RC.CtgCode
		+'~'+ISNULL(R.RtrCode,'ALL')+'~'+P.PrdCCode+'~'+PB.PrdBatCode
		NOT IN(SELECT RtrHierLevel+'~'+RtrHierValue+'~'+RtrCode+'~'+PrdCCode+'~'+PrdBatCode FROM SplRateToAvoid_Manual (NOLOCK))
		ORDER BY RCL.CtgLevelName,RC.CtgCode,ISNULL(R.RtrCode,'ALL'),P.PrdCCode,
		PB.PrdBatCode,SpecialRate,EffFromDate,CreatedDate
	OPEN Cur_SpecialRate	
	FETCH NEXT FROM Cur_SpecialRate INTO @RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
	@PrdCCode,@PrdBatCodeAll,@SplRate,@EffFromDate,@EffToDate,@CreatedDate,@PrdId,@CtgLevelId,@CtgMainId
	WHILE @@FETCH_STATUS=0
	BEGIN
	SET @ContractPriceIds=''
	SELECT @PrdCtgValMainId=ISNULL(P.PrdCtgValMainId,0)
		FROM Product P (NOLOCK),ProductCategoryValue PCV (NOLOCK)
		WHERE P.PrdCtgValMainId=PCV.PrdCtgValMainId AND P.PrdId=@PrdId
	SELECT @CmpPrdCtgId=ISNULL(PCL.CmpPrdCtgId,0) FROM ProductCategoryLevel PCL (NOLOCK),ProductCategoryValue PCV (NOLOCK)
		WHERE PCL.CmpPrdCtgId=PCV.CmpPrdCtgId AND PCV.PrdCtgValMainId=@PrdCtgValMainId
	IF UPPER(LTRIM(RTRIM(@RtrCode)))<>'ALL'
	BEGIN
		IF NOT EXISTS (SELECT RtrCode FROM Retailer A INNER JOIN RetailerValueClassMap B ON A.RtrId=B.RtrId INNER JOIN RetailerValueClass C ON B.RtrValueClassId=C.RtrClassId
		INNER JOIN RetailerCategory D ON D.CtgMainId=C.CtgMainId INNER JOIN RetailerCategoryLevel E ON E.CtgLevelId=D.CtgLevelId
		WHERE RtrCode=@RtrCode AND D.CtgCode=@RtrHierLevelValueCode AND E.CtgLevelName=@RtrHierLevelCode)
		BEGIN
			SET @Po_ErrNo=1
			INSERT INTO SplRateToAvoid_Manual(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
			SELECT @RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,@PrdCCode,@PrdBatCode
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Special Rate','Retailer','Retailer not attached to mentioned category/level:'+@RtrCode+' Not Available'
		END
	END
	
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
		FROM ProductBatch (NOLOCK) WHERE PrdId=@PrdId AND
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
						FROM RetailerValueClass RVC (NOLOCK),RetailerValueClassMap RVCM (NOLOCK),Retailer R (NOLOCK)
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
					FROM RetailerValueClass RVC (NOLOCK),RetailerValueClassMap RVCM (NOLOCK),Retailer R (NOLOCK)
					WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
					AND CtgMainId=@CtgMainId
					GROUP BY R.TaxGroupId					
									
					SELECT @RtrId=RtrId,@TaxGroupId=R.TaxGroupId FROM Retailer R (NOLOCK),TempRtrs TR (NOLOCK) WHERE R.TaxGroupId=TR.TaxGroupId
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
				SELECT @RefPriceId=ISNULL(PriceId,0) FROM ProductBatchDetails (NOLOCK) WHERE PrdBatId=@PrdBatId AND SlNo=1 AND DefaultPrice=1
				IF @RefPriceId=0
				BEGIN
					SELECT @RefPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK) WHERE PrdBatId=@PrdBatId 
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
				FROM ProductBatchDetails PBD (NOLOCK),BatchCreation BC (NOLOCK)
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
					SELECT @RefRtrId=ISNULL(RtrId,0) FROM Retailer  (NOLOCK)WHERE CmpRtrCode=@RtrCode
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
					FROM Retailer R (NOLOCK),RetailerValueClass RVC (NOLOCK),RetailerValueClassMap RVCM (NOLOCK)
					WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
					AND RVC.CtgMainId=@CtgMainId AND R.TaxGroupId<>@TaxGroupId
					OPEN Cur_MulTaxGroup	
					FETCH NEXT FROM Cur_MulTaxGroup INTO @MulTaxGroupId
					WHILE @@FETCH_STATUS=0
					BEGIN						
						SELECT @MulRtrId=MAX(R.RtrId)
						FROM Retailer R (NOLOCK),RetailerValueClass RVC (NOLOCK),RetailerValueClassMap RVCM (NOLOCK)
						WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
						AND RVC.CtgMainId=@CtgMainId AND R.TaxGroupId=@MulTaxGroupId
			
						SET @ReCalculatedSR=0
						EXEC Proc_SellingRateReCalculation @MulRtrId,@PrdBatId,@DownldSplRate,@Pi_SellingRate=@ReCalculatedSR OUTPUT
						IF @ReCalculatedSR<>0
						BEGIN
							SET @SplRate=@ReCalculatedSR
						END
		
						SET @RefPriceId=0
						SELECT @RefPriceId=ISNULL(PriceId,0) FROM ProductBatchDetails (NOLOCK) WHERE PrdBatId=@PrdBatId AND SlNo=1 AND DefaultPrice=1
						
						IF @RefPriceId=0
						BEGIN
							SELECT @RefPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK) WHERE PrdBatId=@PrdBatId 
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
						FROM ProductBatchDetails PBD (NOLOCK),BatchCreation BC (NOLOCK)
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
		--SELECT 'A',* FROM SpecialRateAftDownLoad  (NOLOCK) WHERE RtrCtgCode=@RtrHierLevelCode AND
		--RtrCtgValueCode=@RtrHierLevelValueCode AND RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND
		--PrdBatCCode=@PrdBatCodeAll AND SplSelRate=@SplRate AND FromDate<=@EffFromDate AND SplrateId=@Pi_SplrateId
		
		--SELECT 'B',@RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,@PrdCCode,@PrdBatCodeAll,@SplRate,@Pi_SplrateId
		
		IF NOT EXISTS(SELECT * FROM SpecialRateAftDownLoad  (NOLOCK) WHERE RtrCtgCode=@RtrHierLevelCode AND
		RtrCtgValueCode=@RtrHierLevelValueCode AND RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND
		PrdBatCCode=@PrdBatCodeAll AND SplSelRate=@SplRate AND FromDate<=@EffFromDate AND SplrateId=@Pi_SplrateId)
		BEGIN
			SET @ContHistExist=0
		END
		ELSE
		BEGIN	
		
			SET @ContHistExist=1
		END
		PRINT @ContHistExist
		IF @ContHistExist=0	
		BEGIN	
			IF NOT EXISTS(SELECT * FROM SpecialRateAftDownLoad  (NOLOCK) WHERE RtrCtgCode=@RtrHierLevelCode AND
			RtrCtgValueCode=@RtrHierLevelValueCode AND RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND
			PrdBatCCode=@PrdBatCodeAll AND FromDate<=@EffFromDate AND SplSelRate=@SplRate AND SplrateId=@Pi_SplrateId)
			BEGIN
				INSERT INTO SpecialRateAftDownLoad(RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,
				SplSelRate,FromDate,CreatedDate,DownloadedDate,ContractPriceIds,SplrateId)
				VALUES(@RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
				@PrdCCode,@PrdBatCodeAll,@DownldSplRate,@EffFromDate,@CreatedDate,GETDATE(),@ContractPriceIds,@Pi_SplrateId)		
			END
			ELSE
			BEGIN
				UPDATE SpecialRateAftDownLoad SET SplSelRate=@DownldSplRate,ContractPriceIds=@ContractPriceIds,SplrateId=@Pi_SplrateId
				WHERE RtrCtgCode=@RtrHierLevelCode AND RtrCtgValueCode=@RtrHierLevelValueCode AND
				RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND PrdBatCCode=@PrdBatCodeAll
				AND FromDate<=@EffFromDate AND SplrateId=@Pi_SplrateId
			END
		END
		FETCH NEXT FROM Cur_SpecialRate INTO @RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
		@PrdCCode,@PrdBatCodeAll,@SplRate,@EffFromDate,@EffToDate,@CreatedDate,@PrdId,@CtgLevelId,@CtgMainId
	END
	CLOSE Cur_SpecialRate
	DEALLOCATE Cur_SpecialRate
	IF @ContHistExist=0
	BEGIN
		IF @ContractReq=1
		BEGIN
			EXEC Proc_Validate_ContractPricing @Po_ErrNo=@ErrStatus
			SET @ErrNo=@ErrStatus
		END
	END
	IF @ErrNo=1 
	BEGIN
		SET @Po_ErrNo=1
	END
	--IF @Po_ErrNo=0
	--BEGIN	
	--	UPDATE A  SET DownLoadFlag='Y'  FROM TEMPSpecialRateProductDet A (NOLOCK)
	--	WHERE CtgLevelName+'~'+CtgCode 
	--	NOT IN(SELECT RtrHierLevel+'~'+RtrHierValue FROM SplRateToAvoid_Manual)
	--END
	RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE name='Fn_ReturnSplratetransactions' AND XTYPE='FN')
DROP FUNCTION Fn_ReturnSplratetransactions
GO
--SELECT DBO.Fn_ReturnSplratetransactions(2) AS TransExists
CREATE FUNCTION Fn_ReturnSplratetransactions (@Pi_SplrateId AS INT)
RETURNS INT
AS
/*********************************
* PROCEDURE		: Fn_ReturnSplratetransactions
* PURPOSE		: To return transaction special rates
* CREATED		: Praveenraj B
* CREATED DATE	: 04/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
	DECLARE @EXISTS AS INT
	SET @EXISTS=0
	
		IF EXISTS	(SELECT A.SplrateId,C.SplSelRate,SP.PriceId,S.SalId FROM SpecialRate A  (NOLOCK)
						INNER JOIN SpecialrateProducts B (NOLOCK) ON A.SplrateId=B.SplrateId
						INNER JOIN SpecialRateAftDownLoad C (NOLOCK) ON A.SplrateId=C.SplrateId AND B.SplrateId=C.SplrateId AND B.PrdCCode=C.PrdCCode
						INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON SP.PriceId=SUBSTRING(C.ContractPriceIds,CHARINDEX('-',C.ContractPriceIds)+1,(LEN(C.ContractPriceIds))-2)
						INNER JOIN SalesInvoice S (NOLOCK) ON SP.SalId=S.SalId WHERE A.SplrateId=@Pi_SplrateId)
		BEGIN
			SET @EXISTS=1
		END
		ELSE
		BEGIN
			SET @EXISTS=0
		END
	RETURN(@EXISTS)
END
GO
DELETE FROM CustomCaptions WHERE TransId=252 AND CtrlId=2000 AND SubCtrlId=16
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
							DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 252,2000,16,'MsgBox-252-2000-16','','','Select Product Details to save',1,1,1,GETDATE(),1,GETDATE(),
'','','Select Product Details to save',1,1
GO
IF NOT EXISTS (select * from syscolumns where name = 'Upload' and id in (select id from sysobjects where name = 'AutoRetailerClassShift' and xtype = 'U'))
ALTER TABLE AutoRetailerClassShift ADD  Upload tinyint not null default  0 with values
GO
IF NOT EXISTS (select * from syscolumns where name = 'XMLUpload' and id in (select id from sysobjects where name = 'ClaimGroupMaster' and xtype = 'U'))
ALTER TABLE ClaimGroupMaster ADD  XMLUpload int not null default  0 with values
GO
IF NOT EXISTS (select * from syscolumns where name = 'Remarks' and id in (select id from sysobjects where name = 'ClaimSheetDetail' and xtype = 'U'))
ALTER TABLE ClaimSheetDetail ADD  Remarks nvarchar(500)
GO
IF NOT EXISTS (select * from syscolumns where name = 'SettlementType' and id in (select id from sysobjects where name = 'ClaimSheetHD' and xtype = 'U'))
ALTER TABLE ClaimSheetHD ADD  SettlementType int
--Till Here CK Changes Script
GO
--Product Version Configuration
DELETE FROM Configuration WHERE ModuleId IN ('BILL1','BILL2','BILL3','BILL4','BAT3','BAT4','BL1','BL2','BL3','BILLRTEDIT19','BILLRTEDIT8','BotreeSyncDateCheck',
'LGV1','MARKRET1','MARKRET2','MARKRET3','PRN2','PRN3','PURCHASERECEIPT16','PURCHASERECEIPT24','PURCHASERECEIPT25','PURCHASERECEIPT28',
'RET35','RET40','ROUTE2','SALESRTN17','SALPAN1','SALPAN2','SALRET1','SALRET2','SALRET3','SALRET4','SCHCON14','SCHCON14','SCHCON15','SCHCON16',
'SCHCON17','SCHCON18','SCHCON19','SJN6')
INSERT INTO Configuration
SELECT 'BILL1','Billing','Create Bills with available quantity in case of partial stock availability',0,'',0.00,1 UNION
SELECT 'BILL2','Billing','Exclude lines with zero stock while generating bills',0,'',0.00,2 UNION
SELECT 'BILL3','Billing','Allow to Enter Distributor discount in % when discount type is in value',0,'',0.00,3 UNION
SELECT 'BILL4','Billing','Consider Holiday Calendar and Distributor Day Off In AutoDelivery',0,'',0.00,4 UNION
SELECT 'BAT3','Batch Transfer','Raise Supplier Credit Note',0,'Rate for Claim/Greater than/Rate for Claim',0.00,3 UNION
SELECT 'BAT4','Batch Transfer','Raise Supplier Debit Note',0,'Rate for Claim/Greater than/Rate for Claim',0.00,4 UNION
SELECT 'BL1','BL Configuration','Automatically create price batches based on selling rate received from Console',1,'',0.00,1 UNION
SELECT 'BL2','BL Configuration','Automatically create contract price entry based on new price batch creation',1,'',0.00,2 UNION
SELECT 'BL3','BL Configuration','Perform Cheque Bounce based on data received from Console',1,'',0.00,3 UNION
SELECT 'BILLRTEDIT19','BillConfig_RateEdit','Treat the difference amount as Distributor Discount',0,'',0.00,1 UNION
SELECT 'BILLRTEDIT8','BillConfig_RateEdit','Treat the difference amount as Distributor Discount',0,'',0.00,1 UNION
SELECT 'BotreeSyncDateCheck','BotreeSynDateCheck','Check Sync Server Date',0,'',0.00,1 UNION
SELECT 'LGV1','LoginValidation','Check Server Date While Login',0,'',0.00,1 UNION
SELECT 'MARKRET1','MarketReturn','Restrict Users from returning bills older than',0,'',180.00,1 UNION
SELECT 'MARKRET2','MarketReturn','Apply Present rate,tax and scheme if the return is done  without  invoice Reference',0,'',0.00,2 UNION
SELECT 'MARKRET3','MarketReturn','Do not allow selection of Unsaleable stock type in market return',0,'',0.00,3 UNION
SELECT 'PRN2','PurchaseReturn','Enable SRS and PRN',0,'',0.00,2 UNION
SELECT 'PRN3','PurchaseReturn','Display alert message while confirming purchase return',0,'',0.00,3 UNION
SELECT 'PURCHASERECEIPT16','Purchase Receipt','Enable ''Additional Discount'' Column in Purchase Transactions',0,'',0.00,16 UNION
SELECT 'PURCHASERECEIPT24','Purchase Receipt','Display the Credit Note option in Purchase receipt screen',0,'',0.00,24 UNION
SELECT 'PURCHASERECEIPT25','Purchase Receipt','Display the Debit Note option in Purchase receipt screen',0,'',0.00,25 UNION
SELECT 'PURCHASERECEIPT28','Purchase Receipt','Display Alert message while confirming the Purchase',0,'',0.00,28 UNION
SELECT 'RET35','Retailer','Set the maximum transaction value as                        before approval',0,'',0.00,35 UNION
SELECT 'RET40','Retailer','Auto XML Stock Adjustment',0,'',0.00,40 UNION
SELECT 'ROUTE2','Route Master','Restrict editing of route name if any transaction is done',0,'',0.00,2 UNION
SELECT 'SALESRTN17','Sales Return','Allow User to Make Direct Sales Return',0,'',0.00,2 UNION
SELECT 'SALPAN1','SalesPanel','Create Bills with available quantity in case of partial stock availability',0,'',0.00,1 UNION
SELECT 'SALPAN2','SalesPanel','Exclude lines with zero stock while generating bills',0,'',0.00,2 UNION
SELECT 'SALRET1','SalesReturn','Enable SRS and SRN in Sales Return',0,'',0.00,1 UNION
SELECT 'SALRET2','SalesReturn','Restrict Users from returning bills older than',0,'',180.00,2 UNION
SELECT 'SALRET3','SalesReturn','Apply Present rate,tax and scheme if the return is done  without  invoice Reference',0,'',0.00,3 UNION
SELECT 'SALRET4','SalesReturn','Do not apply Scheme for SRS Return',0,'',0.00,4 UNION
SELECT 'SCHCON14','Scheme Master','Set the default value in the claimable field as NO',0,'',0.00,15 UNION
SELECT 'SCHCON15','Scheme Master','Restrict user from editing the default value in the claimable field',0,'',0.00,16 UNION
SELECT 'SCHCON16','Scheme Master','Restrict the user from un-checking the claimable schemes during billing process',1,'',0.00,14 UNION
SELECT 'SCHCON17','Scheme Master','Apply this configuration for all claimable schemes',0,'',0.00,17 UNION
SELECT 'SCHCON18','Scheme Master','Apply this configuration based on user selection in the scheme master – against individual schemes',1,'',0.00,18 UNION
SELECT 'SCHCON19','Scheme Master','Apply this configuration for all claimable schemes (Yes/No)',0,'',0.00,19 UNION
SELECT 'SJN6','Stock Journal','Restrict selections of Unsalable Stock Type in the ''Available Stock Type''  column',0,'',0.00,6
GO
DELETE FROM Menudef WHERE MenuId IN ('mInv11','MClm21','mSal8','mStk25','mStk26','mStk27','mStk31')
INSERT INTO Menudef 
SELECT 184,'MClm21','mnuPrdClaimNormMap','mClm','Product Claim Norm Definition',0,'frmClaimNormPrdDefinition','Product Claim Norm Definition' UNION
SELECT 185,'mStk31','mnuSync','mStk','Sync',0,'C:\CoreStocky-CITRIX\CSSourceCitrix\CoreStocky\Export\Sync.exe','Sync' UNION
SELECT 186,'mSal8','MnuSFATargetSetting','mSal','SFA Target Setting',0,'frmSFATargetSetting','SFA Target Setting' UNION
SELECT 187,'mStk25','mnuClusterMaster','mStk','Cluster Master',0,'frmClusterMaster','Cluster Master' UNION
SELECT 188,'mStk26','mnuClusterGroup','mStk','Cluster Group',0,'frmClusterGroup','Cluster Group' UNION
SELECT 189,'mStk27','mnuClusterAssign','mStk','Cluster Assign',0,'frmClusterAssign','Cluster Assign' UNION
SELECT 190,'mInv11','mnuCratesManagement','mInv','Crates Management',0,'frmCratesManagement','Crates Management'
GO
DELETE FROM ProfileDt WHERE MenuId IN ('MClm21','mSal8','mStk25','mStk26','mStk27','mStk31','mInv11')
INSERT INTO ProfileDt
SELECT DISTINCT PrfId,'MSTK31',0,'Sync',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'MCLM21',0,'New',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'MCLM21',1,'Edit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'MCLM21',2,'Save',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'MCLM21',3,'Delete',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'MCLM21',4,'Cancel',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'MCLM21',5,'Print',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'MCLM21',6,'Exit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mSal8',0,'New',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mSal8',1,'Edit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mSal8',2,'Save',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mSal8',3,'Delete',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mSal8',4,'Cancel',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mSal8',5,'Exit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk25',0,'New',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk25',1,'Edit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk25',2,'Save',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk25',3,'Delete',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk25',4,'Cancel',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk25',5,'Exit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk25',6,'Print',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk26',0,'New',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk26',1,'Edit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk26',2,'Save',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk26',3,'Delete',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk26',4,'Cancel',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk26',5,'Exit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk26',6,'Print',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk27',0,'New',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk27',1,'Edit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk27',2,'Save',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk27',3,'Delete',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk27',4,'Cancel',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk27',5,'Exit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mStk27',6,'Print',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv11',0,'New',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv11',1,'Save',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv11',2,'Cancel',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv11',3,'Exit',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH (NOLOCK)
GO
DELETE FROM Rptgroup WHERE RptId=258
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) 
VALUES ('PMReports',258,'UnLoading Sheet Report','UnLoading Sheet Report',0)
GO
DELETE FROM RptHeader WHERE RptId=258
INSERT INTO RptHeader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds]) 
VALUES ('UnLoading Sheet Report','UnLoading Sheet Report','258','UnLoadingSheetReport','Proc_RptUnloadingSheetPM',
'RptUnloadingSheetPM','RptUnloadingSheetPM.rpt','')
GO
DELETE FROM HotSearchEditorHD WHERE FormId IN (10062,10072)
INSERT INTO HotSearchEditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10062,'Supplier Master','IDTTaxGroup','select','Select TaxGroupId,  TaxGroupName,RtrGroup From TaxGroupSetting WITH (Nolock) WHERE Taxgroup = 4 and Availability=1')
INSERT INTO HotSearchEditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10072,'Special Rates','Retailer Category Level','select','SELECT CtgLevelId,CtgLevelName FROM RetailerCategoryLevel')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10062,10072)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10062,'IDTTaxGroup','TaxGroup Name','TaxGroupName',2000,0,'HotSch-69-2000-5',69)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,10062,'IDTTaxGroup','TaxGroup Code','RtrGroup',2500,0,'HotSch-69-2000-6',69)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10072,'Retailer Category Level','CtgLevelId','CtgLevelId',1500,0,'HotSch-252-2000-9',252)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,10072,'Retailer Category Level','CtgLevelName','CtgLevelName',1500,0,'HotSch-252-2000-4',252)
GO
DELETE FROM HotsearcheditorHd WHERE FormId IN (469,471,481,483,10014,10054,10055,10056,10089,10090,10091,10092,10093,10094,10095,10096,10097,10098,10099,10100,10101,10102)
INSERT INTO HotsearcheditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString])
VALUES (469,'Purchase Shortage Claim','JCYear','select','SELECT DISTINCT JcmId,JcmYr FROM JCMast WITH (NOLOCK)')
INSERT INTO HotsearcheditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString])
VALUES (471,'Purchase Shortage Claim','ToJCMonth','select','SELECT DISTINCT JcmJc,JcmSdt,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam Order By JcmJc ASC')
INSERT INTO HotsearcheditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (481,'Purchase Excess Quantity Refusal Claim','JCYear','select','SELECT DISTINCT JcmId,JcmYr FROM JCMast WITH (NOLOCK)')
INSERT INTO HotsearcheditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (483,'Purchase Excess Quantity Refusal Claim','ToJCMonth','select','SELECT DISTINCT JcmJc,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId=vFParam')
INSERT INTO HotsearcheditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10014,'Loyalty Program','Reference No','select','SELECT LoyalRefNo,LoyalDesc FROM LoyaltyHeader (NOLOCK)')
INSERT INTO HotsearchEditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10054,'Launch Product Target','SalesMan','Select','SELECT RMId, RMCode, RMName FROM RouteMaster WHERE RMSRouteType=1 ORDER BY RMName')
INSERT INTO HotSearchEditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10055,'Mass Update Tool','SMRoute','Select','SELECT RMId,RMCode,RMName FROM (SELECT RM.RMId,RM.RMCode,RM.RMName FROM RouteMaster RM LEFT OUTER JOIN SalesManMarket SM (NOLOCK) ON SM.RMId=RM.RMId WHERE SM.SMId=vFParam AND RM.RMId NOT IN(vSParam))a')
INSERT INTO HotSearchEditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10056,'Mass Update Tool','AllSMRoute','Select','SELECT RMId,RMCode,RMName FROM RouteMaster (NOLOCK) WHERE RMId NOT IN (vFParam)')
INSERT INTO HotsearchEditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10092,'Claim Top Sheet','ClaimGroup','select','SELECT ClmGrpId,ClmGrpCode,ClmGrpName FROM ClaimGroupMaster WHERE CmpId in (vFParam,0)  AND ClmGrpId NOT IN (11,17)')
INSERT INTO HotSearchEditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString])
VALUES (10093,'Claim Top Sheet','ClaimGroup','select','SELECT ClmGrpId,ClmGrpCode,ClmGrpName  FROM ClaimGroupMaster WHERE CmpId in (vFParam,0)  AND ClmGrpId NOT IN (10002,17)')
INSERT INTO HotSearchEditorHD([FormId],[FormName],[ControlName],[SltString],[RemainsltString])
VALUES (10094,'Purchase Return','DownLoaded Invoice','Select','SELECT DISTINCT PurRcptRefNo,CmpInvoiceno as CmpInvNo,PurRcptId,InvDate,0 as TaxAmount,0 as LessScheme,SpmId,CmpId,LcnId,0 as OtherCharges,0 as GrossAmount,  0 as NetAmount,1 as PurSeqId,SRSPRNType,ReferenceType,ReturnMode  from Temp_PurchaseReturn')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (469,471,481,483,10014,10054,10055,10056,10089,10090,10091,10092,10093,10094,10095,10096,10097,10098,
10099,10100,10101,10102)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,469,'JCYear','JC Year','JcmYr',4250,0,'HotSch-99-2000-5',99)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,471,'FromJCMonth','Start Date','JcmSdt',4500,0,'HotSch-99-2000-6',99)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,481,'JCYear','JC Year','JcmYr',4500,0,'HotSch-105-2000-5',105)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,483,'FromJCMonth','Date','JcmJc',4500,0,'HotSch-105-2000-6',105)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10014,'Reference No','Reference No','LoyalRefNo',4500,0,'HotSch-254-2000-6',254)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10014,'Reference No','Description','LoyalDesc',4500,0,'HotSch-254-2000-7',254)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10092,'ClaimGroup','Code','ClmGrpCode',1500,0,'HotSch-16-2000-5',16)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,10092,'ClaimGroup','Name','ClmGrpName',3000,0,'HotSch-16-2000-6',16)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10093,'ClaimGroup','Code','ClmGrpCode',1500,0,'HotSch-16-2000-5',16)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,10093,'ClaimGroup','Name','ClmGrpName',3000,0,'HotSch-16-2000-6',16)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10094,'DownLoaded Invoice','Invoice No','CmpInvNo',2500,0,'HotSch-7-2000-34',7)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,10094,'DownLoaded Invoice','Invoice Date','InvDate',2000,0,'HotSch-7-2000-35',7)
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10095 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10095,'Special Rates','Retailer Category Level','select','SELECT CtgLevelId,CtgLevelName FROM RetailerCategoryLevel'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10095 AND FieldName='Retailer Category Level' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10095,'Retailer Category Level','CtgLevelId','CtgLevelId',1500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10095,'Retailer Category Level','CtgLevelName','CtgLevelName',1500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10096 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10096,'Special Rates','Retailer Category','select','SELECT CtgMainId,CtgCode,CtgName FROM RetailerCategory WHERE CtgLevelId =vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10096 AND FieldName='Retailer Category' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10096,'Retailer Category','Ctg Code','CtgCode',1500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10096,'Retailer Category','Ctg Name','CtgName',4500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10097 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10097,'Special Rates','Retailer','select','SELECT R.RtrId,RtrCode,CmpRtrCode,RtrName,RC.CtgMainId,CtgCode,CtgName,L.CtgLevelId,L.CtgLevelName FROM Retailer R INNER JOIN RetailerValueClassMap M ON R.RtrId=M.RtrId 
INNER JOIN RetailerValueClass C ON C.RtrClassId=M.RtrValueClassId
INNER JOIN RetailerCategory RC ON RC.CtgMainId=C.CtgMainId
INNER JOIN RetailerCategoryLevel L ON L.CtgLevelId=RC.CtgLevelId
WHERE RtrStatus=1 AND L.CtgLevelId=vFParam AND RC.CtgMainId=vSParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10097 AND FieldName='Retailer' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10097,'Retailer','Dist RetailerCode','RtrCode',1500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10097,'Retailer','Cmp RetailerCode','CmpRtrCode',2500,0,'HotSch-252-2000-4',252
UNION
SELECT 3,10097,'Retailer','Retailer Name','RtrName',4500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10098 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10098,'Special Rates','Retailer','select','SELECT R.RtrId,RtrCode,CmpRtrCode,RtrName,RC.CtgMainId,CtgCode,CtgName,L.CtgLevelId,L.CtgLevelName FROM Retailer R INNER JOIN RetailerValueClassMap M ON R.RtrId=M.RtrId 
INNER JOIN RetailerValueClass C ON C.RtrClassId=M.RtrValueClassId
INNER JOIN RetailerCategory RC ON RC.CtgMainId=C.CtgMainId
INNER JOIN RetailerCategoryLevel L ON L.CtgLevelId=RC.CtgLevelId
WHERE RtrStatus=1'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10098 AND FieldName='Retailer' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10098,'Retailer','DistributorRetailerCode','RtrCode',3000,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10098,'Retailer','CmpanyRetailerCode','CmpRtrCode',3000,0,'HotSch-252-2000-4',252
UNION
SELECT 3,10098,'Retailer','Retailer Name','RtrName',4500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10099 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10099,'Special Rates','Retailer Category Level','select','SELECT CtgLevelId,CtgLevelName FROM RetailerCategoryLevel WHERE CtglevelId=vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10099 AND FieldName='Retailer Category Level' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10099,'Retailer Category Level','CtgLevelId','CtgLevelId',1500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10099,'Retailer Category Level','CtgLevelName','CtgLevelName',1500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10100 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10100,'Special Rates','Retailer Category','select','SELECT CtgMainId,CtgCode,CtgName FROM RetailerCategory WHERE CtgLevelId =vFParam AND CtgMainId=vSParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10100 AND FieldName='Retailer Category' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10100,'Retailer Category','Ctg Code','CtgCode',1500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10100,'Retailer Category','Ctg Name','CtgName',4500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10101 AND FieldName='Retailer Category' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10101,'Retailer Category','Ctg Code','CtgCode',1500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10101,'Retailer Category','Ctg Name','CtgName',4500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10101 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10101,'Special Rates','Retailer','select','SELECT R.RtrId,RtrCode,CmpRtrCode,RtrName,RC.CtgMainId,CtgCode,CtgName,L.CtgLevelId,L.CtgLevelName FROM Retailer R INNER JOIN RetailerValueClassMap M ON R.RtrId=M.RtrId 
INNER JOIN RetailerValueClass C ON C.RtrClassId=M.RtrValueClassId
INNER JOIN RetailerCategory RC ON RC.CtgMainId=C.CtgMainId
INNER JOIN RetailerCategoryLevel L ON L.CtgLevelId=RC.CtgLevelId
WHERE RtrStatus=1 AND L.CtgLevelId=vFParam AND RC.CtgMainId=vSParam'
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10102 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10102,'Special Rates','Product','select','SELECT DISTINCT A.PrdId,PrdCCode,PrdDCode,PrdName,PrdShrtName FROM Product A INNER JOIN ProductBatch B
ON A.PrdId=B.PrdId WHERE PrdStatus=1
ORDER BY PrdName'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10102 AND FieldName='Product' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10102,'Product','Company ProductCode','PrdCCode',2500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10102,'Product','Distributor ProductCode','PrdDCode',2500,0,'HotSch-252-2000-4',252
UNION
SELECT 3,10102,'Product','Product Name','PrdName',4500,0,'HotSch-252-2000-4',252
UNION
SELECT 4,10102,'Product','Product Short Name','PrdShrtName',3500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10103 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10103,'Special Rates','Product with company','select','SELECT DISTINCT A.PrdId,PrdCCode,PrdDCode,PrdName,PrdShrtName FROM Product A 
INNER JOIN ProductBatch B ON A.PrdId=B.PrdId
INNER JOIN ProductCategoryValue C ON C.PrdCtgValMainId=A.PrdCtgValMainId
WHERE PrdStatus=1 AND C.PrdCtgValLinkCode LIKE ''%vFParam%'' AND CmpId=vSParam
ORDER BY PrdName '
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10103 AND FieldName='Product with company' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10103,'Product with company','Company ProductCode','PrdCCode',2500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10103,'Product with company','Distributor ProductCode','PrdDCode',2500,0,'HotSch-252-2000-4',252
UNION
SELECT 3,10103,'Product with company','Product Name','PrdName',4500,0,'HotSch-252-2000-4',252
UNION
SELECT 4,10103,'Product with company','Product Short Name','PrdShrtName',3500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10104 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10104,'Special Rates','Product without company','select','SELECT DISTINCT A.PrdId,PrdCCode,PrdDCode,PrdName,PrdShrtName FROM Product A
INNER JOIN ProductBatch B ON A.PrdId=B.PrdId  
INNER JOIN ProductCategoryValue C ON C.PrdCtgValMainId=A.PrdCtgValMainId
WHERE PrdStatus=1 AND C.PrdCtgValLinkCode LIKE ''%vFParam%''
ORDER BY PrdName '
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10104 AND FieldName='Product without company' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10104,'Product without company','Company ProductCode','PrdCCode',2500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10104,'Product without company','Distributor ProductCode','PrdDCode',2500,0,'HotSch-252-2000-4',252
UNION
SELECT 3,10104,'Product without company','Product Name','PrdName',4500,0,'HotSch-252-2000-4',252
UNION
SELECT 4,10104,'Product without company','Product Short Name','PrdShrtName',3500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10105 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10105,'Special Rates','Product','select','SELECT DISTINCT A.PrdId,PrdCCode,PrdDCode,PrdName,PrdShrtName FROM Product A 
INNER JOIN ProductBatch B ON A.PrdId=B.PrdId 
INNER JOIN ProductCategoryValue C ON C.PrdCtgValMainId=A.PrdCtgValMainId
WHERE PrdStatus=1 AND C.PrdCtgValLinkCode LIKE ''%vFParam%'' AND A.PrdId=vSParam
ORDER BY PrdName '
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10105 AND FieldName='Product' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10105,'Product','Company ProductCode','PrdCCode',2500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10105,'Product','Distributor ProductCode','PrdDCode',2500,0,'HotSch-252-2000-4',252
UNION
SELECT 3,10105,'Product','Product Name','PrdName',4500,0,'HotSch-252-2000-4',252
UNION
SELECT 4,10105,'Product','Product Short Name','PrdShrtName',3500,0,'HotSch-252-2000-4',252
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10106 AND FormName='Special Rates'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10106,'Special Rates','SplrateRefNo','select','SELECT SplrateId,SplrateRefNo,SplrateDate FROM Specialrate'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10106 AND FieldName='SplrateRefNo' AND TransId=252
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10106,'SplrateRefNo','Specialrate Refno','SplrateRefNo',2500,0,'HotSch-252-2000-9',252
UNION
SELECT 2,10106,'SplrateRefNo','Specialrate Date','SplrateDate',2500,0,'HotSch-252-2000-4',252
--Till Here Product Version Configuration
GO
--Product Version Claim Changes
--Claim Changes
DELETE FROM Configuration WHERE ModuleId = 'LGV3'
INSERT INTO Configuration
SELECT 'LGV3','LoginValidation','Generate Claims based on Accounts Calendar',0,'',0.00,3
GO
--Manual Claim 
DELETE FROM HotSearchEditorHd WHERE FormId IN (269,270,271)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString])
VALUES (269,'Manual Claim','JCYear','select','select JcmId,JcmYr from JCMast WITH (NOLOCK) WHERE CmpId =vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (270,'Manual Claim','JCFromMonth','select','select JcmSdt,JcmJc from jcmonth WITH (NOLOCK) where JcmId=vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (271,'Manual Claim','JCToMonth','select','select JcmEdt,JcmJc from jcmonth WITH (NOLOCK) where JcmId=vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (269,270,271)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,269,'JCYear','JCYear','JcmYr',4250,0,'HotSch-104-2000-4',104)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,270,'JCFromMonth','From Month','JcmSdt',4500,0,'HotSch-104-2000-5',104)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,271,'JCToMonth','To Month','JcmEdt',4500,0,'HotSch-104-2000-6',104)
GO
DELETE FROM CustomCaptions WHERE TransId = 104 AND CtrlId IN (2000,1000) AND SubCtrlId IN (4,5,10)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (104,1000,4,'MsgBox-104-1000-4','','','Do You Want to Delete Row?',1,1,1,'2009-04-28',1,'2009-04-28','','','Do You Want to Delete Row?',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (104,1000,5,'MsgBox-104-1000-5','','','From JC Month Should not be greater than To JC Month',1,1,1,'2009-04-28',1,'2009-04-28','','','From JC Month Should not be greater than To JC Month',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (104,1000,10,'MsgBox-104-1000-10','','','JC Month ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Month ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (104,2000,4,'HotSch-104-2000-4','JC Year','','',1,1,1,'2009-04-28',1,'2009-04-28','JC Year','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (104,2000,5,'HotSch-104-2000-5','Start Date','','',1,1,1,'2009-04-28',1,'2009-04-28','Start Date','','',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10107,10108,10109)
INSERT INTO HotSearchEditorHd
SELECT 10107,'Manual Claim','ACYear','select','SELECT AcmId,AcmYr from ACMaster WITH (NOLOCK)' UNION
SELECT 10108,'Manual Claim','ACFromMonth','select','SELECT AcmSdt,ACMonth from ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam' UNION
SELECT 10109,'Manual Claim','ACToMonth','select','SELECT AcmEdt,ACMonth from ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10107,10108,10109)
INSERT INTO HotSearchEditorDt
SELECT 1,10107,'ACYear','ACYear','AcmYr',4250,0,'HotSch-104-2000-7',104 UNION
SELECT 1,10108,'ACFromMonth','From Month','AcmSdt',4500,0,'HotSch-104-2000-5',104 UNION
SELECT 1,10109,'ACToMonth','To Month','AcmEdt',4500,0,'HotSch-104-2000-6',104
GO
DELETE FROM CustomCaptions WHERE TransId = 104 AND CtrlId IN (1000,2000) AND SubCtrlId IN (7,24,25,26) 
AND CtrlName IN ('HotSch-104-2000-7','MsgBox-104-1000-24','MsgBox-104-1000-25','MsgBox-104-1000-26')
INSERT INTO CustomCaptions
SELECT 104,2000,7,'HotSch-104-2000-7','AC Year','','',1,1,1,GETDATE(),1,GETDATE(),'AC Year','','',1,1 UNION
SELECT 104,1000,24,'MsgBox-104-1000-24','','','From AC Month Should not be greater than To AC Month',1,1,1,GETDATE(),1,GETDATE(),'','',
'From AC Month Should not be greater than To AC Month',1,1 UNION
SELECT 104,1000,25,'MsgBox-104-1000-25','','','AC Year',1,1,1,GETDATE(),1,GETDATE(),'','','AC Year',1,1 UNION
SELECT 104,1000,26,'MsgBox-104-1000-26','','','AC Month',1,1,1,GETDATE(),1,GETDATE(),'','','AC Month',1,1
GO
--SalesMan Incentive
DELETE FROM HotSearchEditorHd WHERE FormId IN (229,230,231)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (229,'Salesman Incentive Calculator','JCYear','select','SELECT JcmId,JcmYr FROM JCMast WITH (NOLOCK) WHERE CmpId = vFParam ORDER BY JcmYr')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (230,'Salesman Incentive Calculator','FromJCMonth','select','SELECT JcmJc,JcmSdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (231,'Salesman Incentive Calculator','TOJCMonth','select','SELECT JcmJc,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (229,230,231)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,229,'JcmYr','JC Year','JcmYr',4500,0,'HotSch-66-2000-4',66)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,230,'JcmSdt','JC Month','JcmSdt',4500,0,'HotSch-66-2000-5',66)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,231,'JcmEdt','JC Month','JcmEdt',4500,0,'HotSch-66-2000-6',66)
GO
DELETE FROM CustomCaptions WHERE TransId = 66 AND CtrlId IN (2000,1000) AND SubCtrlId IN(4,5,6,7,8) 
AND CtrlName IN('Msgbox-66-1000-4','Msgbox-66-1000-5','Msgbox-66-1000-6','Msgbox-66-1000-7','Msgbox-66-1000-8','HotSch-66-2000-4')
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (66,1000,4,'Msgbox-66-1000-4','','','From date should not be greater than To date',1,1,1,'2008-03-19',1,'2008-03-19','','','From date should not be greater than To date',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (66,1000,5,'Msgbox-66-1000-5','','','Company ',1,1,1,'2008-03-19',1,'2008-03-19','','','Company ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (66,1000,6,'Msgbox-66-1000-6','','',' does not exists ',1,1,1,'2008-03-19',1,'2008-03-19','','',' does not exists ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (66,1000,7,'Msgbox-66-1000-7','','','JC Year ',1,1,1,'2008-03-19',1,'2008-03-19','','','JC Year ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (66,1000,8,'Msgbox-66-1000-8','','','JC Month ',1,1,1,'2008-03-19',1,'2008-03-19','','','JC Month ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (66,2000,4,'HotSch-66-2000-4','JC Year','','',1,1,1,'2008-03-19',1,'2008-03-19','JC Year','','',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10110,10111,10112)
INSERT INTO HotSearchEditorHd 
SELECT 10110,'Salesman Incentive Calculator','ACYear','select','SELECT DISTINCT AcmId,AcmYr FROM ACMaster WITH (NOLOCK) ORDER BY AcmYr' UNION
SELECT 10111,'Salesman Incentive Calculator','FromACMonth','select','SELECT DISTINCT ACMonth,AcmSdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId = vFParam' UNION
SELECT 10112,'Salesman Incentive Calculator','TOACMonth','select','SELECT DISTINCT ACMonth,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId = vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10110,10111,10112)
INSERT INTO HotSearchEditorDt
SELECT 1,10110,'AcmYr','AC Year','AcmYr',4500,0,'HotSch-66-2000-7',66 UNION
SELECT 1,10111,'AcmSdt','Start Date','AcmSdt',4500,0,'HotSch-66-2000-5',66 UNION
SELECT 1,10112,'AcmEdt','End Date','AcmEdt',4500,0,'HotSch-66-2000-6',66
GO
DELETE FROM CustomCaptions WHERE TransId = 66 AND CtrlId IN (2000,1000) AND SubCtrlId IN(7,5,6,14,15) 
AND CtrlName IN ('HotSch-66-2000-7','HotSch-66-2000-5','HotSch-66-2000-6','Msgbox-66-1000-14','Msgbox-66-1000-15')
INSERT INTO CustomCaptions
SELECT 66,2000,7,'HotSch-66-2000-7','AC Year','','',1,1,1,GETDATE(),1,GETDATE(),'AC Year','','',1,1 UNION
SELECT 66,2000,5,'HotSch-66-2000-5','Start Date','','',1,1,1,GETDATE(),1,GETDATE(),'Start Date','','',1,1 UNION
SELECT 66,2000,6,'HotSch-66-2000-6','End Date','','',1,1,1,GETDATE(),1,GETDATE(),'End Date','','',1,1 UNION
SELECT 66,1000,14,'Msgbox-66-1000-14','','','AC Year',1,1,1,GETDATE(),1,GETDATE(),'','','AC Year',1,1 UNION
SELECT 66,1000,15,'Msgbox-66-1000-15','','','AC Month',1,1,1,GETDATE(),1,GETDATE(),'','','AC Month',1,1
GO
--Salesman Salary/DA claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (225,226,227)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (225,'Salesman Salary and DA Claim','JCYear','select','select JcmId,JcmYr from JCMast WITH (NOLOCK) WHERE CmpId =vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (226,'Salesman Salary and DA Claim','JCFromMonth','select','select JcmSdt,JcmJc from jcmonth WITH (NOLOCK) where JcmId=vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (227,'Salesman Salary and DA Claim','JCToMonth','select','select JcmEdt,JcmJc from jcmonth WITH (NOLOCK) where JcmId=vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (225,226,227)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,225,'JCYear','JCYear','JcmYr',4250,0,'HotSch-96-2000-4',96)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,226,'JCFromMonth','FromMonth','JcmSdt',4500,0,'HotSch-96-2000-5',96)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,227,'JCToMonth','ToMonth','JcmEdt',4500,0,'HotSch-96-2000-6',96)
GO
DELETE FROM CustomCaptions WHERE TransId = 96 AND CtrlId IN(2000,1000) AND SubCtrlId IN(4,1,10,11)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (96,1000,1,'MsgBox-96-1000-1','','','FromMonth Should not be greater than ToMonth',1,1,1,'2009-04-28',1,'2009-04-28','','','FromMonth Should not be greater than ToMonth',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (96,1000,4,'MsgBox-96-1000-4','','','Failed to Lock Record',1,1,1,'2009-04-28',1,'2009-04-28','','','Failed to Lock Record',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (96,1000,10,'MsgBox-96-1000-10','','','JC Year ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Year ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (96,1000,11,'MsgBox-96-1000-11','','','JC Month ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Month ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (96,2000,1,'HotSch-96-2000-1','Refrence No','','',1,1,1,'2009-04-28',1,'2009-04-28','Refrence No','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (96,2000,4,'HotSch-96-2000-4','JC Year','','',1,1,1,'2009-04-28',1,'2009-04-28','JC Year','','',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10113,10114,10115)
INSERT INTO HotSearchEditorHd
SELECT	10113,'Salesman Salary and DA Claim','ACYear','select','SELECT DISTINCT AcmId,AcmYr FROM ACMaster WITH (NOLOCK)'	UNION
SELECT	10114,'Salesman Salary and DA Claim','ACFromMonth','select','SELECT DISTINCT AcmSdt,ACMonth FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam' UNION
SELECT	10115,'Salesman Salary and DA Claim','ACToMonth','select','SELECT DISTINCT AcmEdt,ACMonth FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10113,10114,10115)
INSERT INTO HotSearchEditorDt
SELECT	1,10113,'ACYear','ACYear','AcmYr',4250,0,'HotSch-96-2000-7',96 UNION
SELECT	1,10114,'ACFromMonth','FromMonth','AcmSdt',4500,0,'HotSch-96-2000-5',96 UNION
SELECT	1,10115,'ACToMonth','ToMonth','AcmEdt',4500,0,'HotSch-96-2000-6',96
GO
DELETE FROM CustomCaptions WHERE TransId = 96 AND CtrlId IN(2000,1000) AND SubCtrlId IN(7,23,24) 
AND CtrlName IN ('HotSch-96-2000-7','MsgBox-96-1000-23','MsgBox-96-1000-24')
INSERT INTO CustomCaptions
SELECT 96,2000,7,'HotSch-96-2000-7','AC Year','','',1,1,1,GETDATE(),1,GETDATE(),'AC Year','','',1,1 UNION
SELECT 96,1000,23,'MsgBox-96-1000-23','','','AC Year',1,1,1,GETDATE(),1,GETDATE(),'','','AC Year',1,1 UNION
SELECT 96,1000,24,'MsgBox-96-1000-24','','','AC Month',1,1,1,GETDATE(),1,GETDATE(),'','','AC Month',1,1
GO
--Delivery Boy Salary and DA Claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (215,216,217)
INSERT INTO HotsearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (215,'Delivery Boy Salary and DA Claim','JCYear','select','SELECT JcmId,JcmYr FROM JCMast WITH (NOLOCK) WHERE CmpId = vFParam ORDER BY JcmYr')
INSERT INTO HotsearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (216,'Delivery Boy Salary and DA Claim','FromJCMonth','select','SELECT JcmJc,JcmSdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam')
INSERT INTO HotsearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (217,'Delivery Boy Salary and DA Claim','ToJCMonth','select','SELECT JcmJc,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (215,216,217)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,215,'JcmYr','JCYear','JcmYr',4250,0,'HotSch-217-2000-3',217)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,216,'JcmSdt','JC Month','JcmSdt',4500,0,'HotSch-217-2000-4',217)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,217,'JcmEdt','JC Month','JcmEdt',4500,0,'HotSch-217-2000-5',217)
GO
DELETE FROM CustomCaptions WHERE TransId = 217 AND CtrlId IN (1000,2000) AND SubCtrlId IN (2,3,4,5)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (217,1000,2,'PnlMsg-217-1000-2','','Press F4/Double click to select JC Year','',1,1,1,'2009-06-07',1,'2009-06-07','','Press F4/Double click to select JC Year','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (217,1000,3,'PnlMsg-217-1000-3','','Press F4/Double click to select From JC Month','',1,1,1,'2009-06-07',1,'2009-06-07','','Press F4/Double click to select From JC Month','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (217,1000,4,'PnlMsg-217-1000-4','','Press F4/Double click to select To JC Month','',1,1,1,'2009-06-07',1,'2009-06-07','','Press F4/Double click to select To JC Month','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (217,1000,5,'PnlMsg-217-1000-5','','Enter Approved Amount','',1,1,1,'2009-06-07',1,'2009-06-07','','Enter Approved Amount','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (217,2000,2,'HotSch-217-2000-2','Name','','',1,1,1,'2009-06-07',1,'2009-06-07','Name','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (217,2000,3,'HotSch-217-2000-3','JCYear','','',1,1,1,'2009-06-07',1,'2009-06-07','JCYear','','',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10116,10117,10118)
INSERT INTO HotSearchEditorHd
SELECT	10116,'Delivery Boy Salary and DA Claim','ACYear','select','SELECT DISTINCT AcmId,AcmYr FROM ACMaster WITH (NOLOCK) ORDER BY AcmYr'	UNION
SELECT	10117,'Delivery Boy Salary and DA Claim','FromACMonth','select','SELECT DISTINCT ACMonth,AcmSdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId = vFParam' UNION
SELECT	10118,'Delivery Boy Salary and DA Claim','ToACMonth','select','SELECT DISTINCT ACMonth,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId = vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10116,10117,10118)
INSERT INTO HotSearchEditorDt
SELECT	1,10116,'AcmYr','ACYear','AcmYr',4250,0,'HotSch-217-2000-3',217	UNION
SELECT	1,10117,'AcmSdt','Start Date','AcmSdt',4500,0,'HotSch-217-2000-4',217	UNION
SELECT	1,10118,'AcmEdt','End Date','AcmEdt',4500,0,'HotSch-217-2000-5',217
GO
DELETE FROM CustomCaptions WHERE TransId = 217 AND CtrlId IN (1000,2000) AND SubCtrlId IN (3,4,5,20,21,22) AND CtrlName IN ('HotSch-217-2000-3','HotSch-217-2000-4','HotSch-217-2000-5',
'PnlMsg-217-1000-20','PnlMsg-217-1000-21','PnlMsg-217-1000-22')
INSERT INTO CustomCaptions
SELECT 217,2000,3,'HotSch-217-2000-7','ACYear','','',1,1,1,GETDATE(),1,GETDATE(),'ACYear','','',1,1 UNION
SELECT 217,2000,4,'HotSch-217-2000-4','Start Date','','',1,1,1,GETDATE(),1,GETDATE(),'Start Date','','',1,1 UNION
SELECT 217,2000,5,'HotSch-217-2000-5','End Date','','',1,1,1,GETDATE(),1,GETDATE(),'End Date','','',1,1 UNION
SELECT 217,1000,20,'PnlMsg-217-1000-20','','Press F4/Double click to select AC Year','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double click to select AC Year','',1,1 UNION
SELECT 217,1000,21,'PnlMsg-217-1000-21','','Press F4/Double click to select From AC Month','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double click to select From AC Month','',1,1 UNION
SELECT 217,1000,22,'PnlMsg-217-1000-22','','Press F4/Double click to select To AC Month','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double click to select To AC Month','',1,1
GO
--Purchase Shortage Claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (469,470,471)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (469,'Purchase Shortage Claim','JCYear','select','SELECT DISTINCT JcmId,JcmYr FROM JCMast WITH (NOLOCK)')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (470,'Purchase Shortage Claim','FromJCMonth','select','SELECT JcmJc,JcmSdt,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam Order By JcmJc ASC')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (471,'Purchase Shortage Claim','ToJCMonth','select','SELECT DISTINCT JcmJc,JcmSdt,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam Order By JcmJc ASC')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (469,470,471)
INSERT INTO HotSearchEditorDt
SELECT	1,469,'JCYear','JC Year','JcmYr',4250,0,'HotSch-99-2000-5',99	UNION
SELECT	1,470,'FromJCMonth','Start Date','JcmSdt',4500,0,'HotSch-99-2000-6',99	UNION
SELECT	1,471,'ToJCMonth','End Date','JcmEdt',4500,0,'HotSch-99-2000-7',99
GO
DELETE FROM CustomCaptions WHERE TransId = 99 AND CtrlId IN (1000,2000) AND CtrlName IN ('HotSch-99-2000-5','MsgBox-99-1000-7','MsgBox-99-1000-8')
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (99,1000,7,'MsgBox-99-1000-7','','','JC Year ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Year ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (99,1000,8,'MsgBox-99-1000-8','','','JC Month ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Month ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (99,2000,5,'HotSch-99-2000-5','JC Year','','',1,1,1,'2009-04-28',1,'2009-04-28','JC Year','','',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10119,10120,10121)
INSERT INTO HotSearchEditorHd
SELECT	10119,'Purchase Shortage Claim','ACYear','select','SELECT DISTINCT AcmId,AcmYr FROM ACMaster WITH (NOLOCK)'	UNION
SELECT	10120,'Purchase Shortage Claim','FromACMonth','select','SELECT DISTINCT ACMonth,ACmSdt,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE ACMID =vFParam ORDER BY ACMonth Asc' UNION
SELECT	10121,'Purchase Shortage Claim','ToACMonth','select','SELECT DISTINCT ACMonth,ACmSdt,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE ACMID = vFParam Order By ACMonth Asc'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10119,10120,10121)
INSERT INTO HotSearchEditorDt
SELECT	1,10119,'ACYear','AC Year','AcmYr',4250,0,'HotSch-99-2000-8',99	UNION
SELECT	1,10120,'FromACMonth','Start Date','AcmSdt',4500,0,'HotSch-99-2000-6',99	UNION
SELECT	1,10121,'ToACMonth','End Date','AcmEdt',4500,0,'HotSch-99-2000-7',99
GO
DELETE FROM CustomCaptions WHERE TransId = 99 AND CtrlId IN (1000,2000) AND CtrlName IN ('HotSch-99-2000-8','MsgBox-99-1000-11','MsgBox-99-1000-12')
INSERT INTO CustomCaptions
SELECT 99,2000,8,'HotSch-99-2000-8','AC Year','','',1,1,1,GETDATE(),1,GETDATE(),'JC Year','','',1,1 UNION
SELECT 99,1000,11,'MsgBox-99-1000-11','','','AC Year',1,1,1,GETDATE(),1,GETDATE(),'','','AC Year',1,1 UNION
SELECT 99,1000,12,'MsgBox-99-1000-12','','','AC Month',1,1,1,GETDATE(),1,GETDATE(),'','','AC Month',1,1
GO
--Rate Difference Claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (513,514,515)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (513,'RateDifferenceClaim','RateDifference','select','SELECT JcmId,JcmYr FROM JCMast WITH (NOLOCK) WHERE CmpId=vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (514,'RateDifferenceClaim','RateDifference','select','SELECT JcmJc,JcmSdt FROM JCMonth WITH (NOLOCK) WHERE JcmId=vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (515,'RateDifferenceClaim','RateDifference','select','SELECT JcmJc,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId=vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (513,514,515)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,513,'RateDifference','JC Year','JcmYr',4500,0,'HotSch-97-2000-5',97)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,514,'RateDifference','Start Date','JcmSdt',4500,0,'HotSch-97-2000-6',97)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,515,'RateDifference','End Date','JcmEdt',4500,0,'HotSch-97-2000-7',97)
GO
DELETE FROM CustomCaptions WHERE TransId = 97 AND CtrlId IN (1000,2000) 
AND CtrlName IN ('HotSch-97-2000-5','MsgBox-97-1000-14','MsgBox-97-1000-15')
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (97,2000,5,'HotSch-97-2000-5','JC Year','','',1,1,1,'2009-04-28',1,'2009-04-28','JC Year','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (97,1000,14,'MsgBox-97-1000-14','','','JC Year ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Year ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (97,1000,15,'MsgBox-97-1000-15','','','JC Month ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Month ',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10122,10123,10124)
INSERT INTO HotSearchEditorHd
SELECT	10122,'RateDifferenceClaim','RateDifference','select','SELECT DISTINCT AcmId,AcmYr FROM ACMaster WITH (NOLOCK)' UNION
SELECT	10123,'RateDifferenceClaim','RateDifference','select','SELECT DISTINCT ACMonth,AcmSdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam' UNION
SELECT	10124,'RateDifferenceClaim','RateDifference','select','SELECT DISTINCT ACMonth,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10122,10123,10124)
INSERT INTO HotSearchEditorDt
SELECT	1,10122,'RateDifference','AC Year','AcmYr',4500,0,'HotSch-97-2000-9',97	UNION
SELECT	1,10123,'RateDifference','Start Date','AcmSdt',4500,0,'HotSch-97-2000-6',97	UNION
SELECT	1,10124,'RateDifference','End Date','AcmEdt',4500,0,'HotSch-97-2000-7',97
GO
DELETE FROM CustomCaptions WHERE TransId = 97 AND CtrlId IN (1000,2000) 
AND CtrlName IN ('HotSch-97-2000-9','MsgBox-97-1000-9','MsgBox-97-1000-16','MsgBox-97-1000-17','MsgBox-97-1000-18')
INSERT INTO CustomCaptions
SELECT 97,2000,9,'HotSch-97-2000-9','AC Year','','',1,1,1,GETDATE(),1,GETDATE(),'AC Year','','',1,1 UNION
SELECT 97,1000,9,'MsgBox-97-1000-9','','','To Month should be greater than From Month',1,1,1,GETDATE(),1,GETDATE(),'','','To Month should be greater than From Month',1,1 UNION
SELECT 97,1000,16,'MsgBox-97-1000-16','','','From date should not be greater than To date',1,1,1,GETDATE(),1,GETDATE(),'','','From date should not be greater than To date',1,1 UNION
SELECT 97,1000,17,'MsgBox-97-1000-17','','','AC Year',1,1,1,GETDATE(),1,GETDATE(),'','','AC Year',1,1 UNION
SELECT 97,1000,18,'MsgBox-97-1000-18','','','AC Month',1,1,1,GETDATE(),1,GETDATE(),'','','AC Month',1,1
GO
--Purchase Excess Claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (481,482,483)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (481,'Purchase Excess Quantity Refusal Claim','JCYear','select','SELECT DISTINCT JcmId,JcmYr FROM JCMast WITH (NOLOCK)')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (482,'Purchase Excess Quantity Refusal Claim','JCYear','select','SELECT JcmId,JcmYr FROM JCMast  WHERE CmpId =vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (483,'Purchase Excess Quantity Refusal Claim','ToJCMonth','select','SELECT DISTINCT JcmJc,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId=vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (481,482,483)
INSERT INTO HotSearchEditorDt
SELECT	1,481,'JCYear','JC Year','JcmYr',4500,0,'HotSch-105-2000-5',105	UNION
SELECT	1,482,'FromJCMonth','Start Date','JcmSdt',4500,0,'HotSch-105-2000-6',105	UNION
SELECT	1,483,'ToJCMonth','End Date','JcmEdt',4500,0,'HotSch-105-2000-7',105
GO
DELETE FROM CustomCaptions WHERE TransId = 105 AND CtrlId IN (1000,2000) AND CtrlName IN ('MsgBox-105-1000-6','MsgBox-105-1000-7')
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (105,1000,6,'MsgBox-105-1000-6','','','JC Year ',1,1,1,'2008-03-19',1,'2008-03-19','','','JC Year ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (105,1000,7,'MsgBox-105-1000-7','','','JC Month ',1,1,1,'2008-03-19',1,'2008-03-19','','','JC Month ',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10125,10126,10127)
INSERT INTO HotSearchEditorHd
SELECT	10125,'Purchase Excess Quantity Refusal Claim','ACYear','select','SELECT DISTINCT AcmId,AcmYr FROM ACMaster WITH (NOLOCK)' UNION
SELECT	10126,'Purchase Excess Quantity Refusal Claim','FromACMonth','select','SELECT DISTINCT ACMonth,AcmSdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam' UNION
SELECT	10127,'Purchase Excess Quantity Refusal Claim','ToACMonth','select','SELECT DISTINCT ACMonth,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10125,10126,10127)
INSERT INTO HotSearchEditorDt
SELECT	1,10125,'ACYear','AC Year','AcmYr',4500,0,'HotSch-105-2000-8',105	UNION
SELECT	1,10126,'FromACMonth','Start Date','AcmSdt',4500,0,'HotSch-105-2000-6',105	UNION
SELECT	1,10127,'ToACMonth','End Date','AcmEdt',4500,0,'HotSch-105-2000-7',105
GO
DELETE FROM CustomCaptions WHERE TransId = 105 AND CtrlId IN (1000,2000) AND CtrlName IN ('HotSch-105-2000-8','MsgBox-105-1000-10','MsgBox-105-1000-11','MsgBox-105-1000-12')
INSERT INTO CustomCaptions
SELECT 105,2000,8,'HotSch-105-2000-8','AC Year','','',1,1,1,GETDATE(),1,GETDATE(),'AC Year','','',1,1 UNION
SELECT 105,1000,10,'MsgBox-105-1000-10','','','To Month should be greater than From Month',1,1,1,GETDATE(),1,GETDATE(),'','','To Month should be greater than From Month',1,1 UNION
SELECT 105,1000,11,'MsgBox-105-1000-11','','','AC Year',1,1,1,GETDATE(),1,GETDATE(),'','','AC Year',1,1 UNION
SELECT 105,1000,12,'MsgBox-105-1000-12','','','AC Month',1,1,1,GETDATE(),1,GETDATE(),'','','AC Month',1,1
GO
--Transporter Claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (263,264,265)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (263,'Transporter Claim','JCYear','select','SELECT JcmId,JcmYr FROM JCMast WITH (NOLOCK) WHERE CmpId = vFParam ORDER BY JcmYr')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (264,'Transporter Claim','FromJCMonth','select','SELECT JcmJc,JcmSdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (265,'Transporter Claim','ToJCMonth','select','SELECT JcmJc,JcmEdt FROM JCMonth WITH (NOLOCK) WHERE JcmId = vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (263,264,265)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,263,'JcmYr','JC Year','JcmYr',4250,0,'HotSch-136-2000-4',136)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,264,'JcmSdt','JC Month','JcmSdt',4500,0,'HotSch-136-2000-5',136)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,265,'JcmEdt','JC Month','JcmEdt',4500,0,'HotSch-136-2000-6',136)
GO
DELETE FROM CustomCaptions WHERE TransId = 136 AND CtrlId IN (1000,2000) AND CtrlName IN ('HotSch-136-2000-4','HotSch-136-2000-5','HotSch-136-2000-6',
'Msgbox-136-1000-6','Msgbox-136-1000-7','PnlMsg-136-1000-10','PnlMsg-136-1000-11','PnlMsg-136-1000-12')
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (136,1000,6,'Msgbox-136-1000-6','','','Selected Year does not exists ',1,1,1,'2009-04-28',1,'2009-04-28','','','Selected Year does not exists ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (136,1000,7,'Msgbox-136-1000-7','','','Selected Month does not exists ',1,1,1,'2009-04-28',1,'2009-04-28','','','Selected Month does not exists ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (136,1000,10,'PnlMsg-136-1000-10','','Press F4/Double click to select Year','',1,1,1,'2009-04-28',1,'2009-04-28','','Press F4/Double click to select Year','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (136,1000,11,'PnlMsg-136-1000-11','','Press F4/Double click to select From Month','',1,1,1,'2009-04-28',1,'2009-04-28','','Press F4/Double click to select From Month','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (136,1000,12,'PnlMsg-136-1000-12','','Press F4/Double click to select To Month','',1,1,1,'2009-04-28',1,'2009-04-28','','Press F4/Double click to select To Month','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (136,2000,4,'HotSch-136-2000-4','JC Year','','',1,1,1,'2009-04-28',1,'2009-04-28','JC Year','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (136,2000,5,'HotSch-136-2000-5','StartDate','','',1,1,1,'2009-04-28',1,'2009-04-28','StartDate','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled])
VALUES (136,2000,6,'HotSch-136-2000-6','EndDate','','',1,1,1,'2009-04-28',1,'2009-04-28','EndDate','','',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10128,10129,10130)
INSERT INTO HotSearchEditorHd
SELECT	10128,'Transporter Claim','ACYear','select','SELECT DISTINCT AcmId,AcmYr FROM ACMaster WITH (NOLOCK)' UNION
SELECT	10129,'Transporter Claim','FromACMonth','select','SELECT DISTINCT ACMonth,AcmSdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam' UNION
SELECT	10130,'Transporter Claim','ToACMonth','select','SELECT DISTINCT ACMonth,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10128,10129,10130)
INSERT INTO HotSearchEditorDt
SELECT	1,10128,'ACYear','AC Year','AcmYr',4500,0,'HotSch-136-2000-7',136	UNION
SELECT	1,10129,'FromACMonth','Start Date','AcmSdt',4500,0,'HotSch-136-2000-5',136	UNION
SELECT	1,10130,'ToACMonth','End Date','AcmEdt',4500,0,'HotSch-136-2000-6',136
GO
DELETE FROM CustomCaptions WHERE TransId = 136 AND CtrlId = 2000 AND CtrlName = 'HotSch-136-2000-7'
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (136,2000,7,'HotSch-136-2000-7','AC Year','','',1,1,1,'2009-04-28',1,'2009-04-28','AC Year','','',1,1)
GO
--VAT Claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (491,492,493)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (491,'VAT Claim','JC Year','select','SELECT JcmId,JcmYr FROM JCMast WITH(NOLOCK) WHERE CmpId =vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (492,'VAT Claim','From JC Month','select',' SELECT JCmJC,JCmSdt,JcmEdt  FROM JCMonth WHERE JCMID = vFParam Order By JcmJc asc')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString])
VALUES (493,'VAT Claim','To JC Month','select',' SELECT JCmJC,JCmSdt,JcmEdt FROM JCMonth  WHERE JCMID = vFParam Order By JcmJc asc')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (491,492,493)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,491,'JC Year','Year','JcmYr',4500,0,'HotSch-98-2000-5',98)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,492,'From JC Month','JCMonth','JCmSdt',4500,0,'HotSch-98-2000-6',98)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,493,'To JC Month','JCMonth','JCmSdt',4500,0,'HotSch-98-2000-6',98)
GO
DELETE FROM CustomCaptions WHERE TransId = 98 AND CtrlId IN (1000,2000) AND CtrlName IN ('HotSch-98-2000-5','MsgBox-98-1000-10','MsgBox-98-1000-11')
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (98,2000,5,'HotSch-98-2000-5','JC Year','','',1,1,1,'2009-04-28',1,'2009-04-28','JC Year','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (98,1000,10,'MsgBox-98-1000-10','','','JC Year ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Year ',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (98,1000,11,'MsgBox-98-1000-11','','','JC Month ',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Month ',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10131,10132,10133)
INSERT INTO HotSearchEditorHd
SELECT	10131,'VAT Claim','ACYear','select','SELECT DISTINCT AcmId,AcmYr FROM ACMaster WITH (NOLOCK)' UNION
SELECT	10132,'VAT Claim','FromACMonth','select','SELECT DISTINCT ACMonth,AcmSdt,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam' UNION
SELECT	10133,'VAT Claim','ToACMonth','select','SELECT DISTINCT ACMonth,AcmSdt,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10131,10132,10133)
INSERT INTO HotSearchEditorDt
SELECT	1,10131,'ACYear','AC Year','AcmYr',4500,0,'HotSch-98-2000-8',98	UNION
SELECT	1,10132,'FromACMonth','Start Date','AcmSdt',4500,0,'HotSch-98-2000-6',98	UNION
SELECT	1,10133,'ToACMonth','End Date','AcmEdt',4500,0,'HotSch-98-2000-7',98
GO
DELETE FROM CustomCaptions WHERE TransId = 98 AND CtrlId IN (1000,2000) AND CtrlName IN ('HotSch-98-2000-8','MsgBox-98-1000-14','MsgBox-98-1000-15')
INSERT INTO CustomCaptions
SELECT 98,2000,8,'HotSch-98-2000-8','AC Year','','',1,1,1,GETDATE(),1,GETDATE(),'AC Year','','',1,1 UNION
SELECT 98,1000,14,'MsgBox-98-1000-14','','','AC Year',1,1,1,GETDATE(),1,GETDATE(),'','','AC Year',1,1 UNION
SELECT 98,1000,15,'MsgBox-98-1000-15','','','AC Month',1,1,1,GETDATE(),1,GETDATE(),'','','AC Month',1,1
GO
--Van Subsidy Claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (200,201,202)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (200,'Van Subsidy Claim','JCYear','select','SELECT JCMId,JCMYr FROM JCMast WHERE CmpId = vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (201,'Van Subsidy Claim','JCFromMonth','select','SELECT JCMJc,JCMSDt FROM JCMonth WHERE JCMId = vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (202,'Van Subsidy Claim','JCToMonth','select','SELECT JCMJc,JCMEDt FROM JCMonth WHERE JCMId = vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (200,201,202)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,200,'JCYear','JC Year','JCMYr',4250,0,'HotSch-178-2000-3',178)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,201,'JCFromMonth','From JC Month','JCMSDt',4500,0,'HotSch-178-2000-4',178)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,202,'JCToMonth','To JC Month','JCMEDt',4500,0,'HotSch-178-2000-5',178)
GO
DELETE FROM CustomCaptions WHERE TransId = 178 AND CtrlId IN(2000,1000)
AND CtrlName IN ('HotSch-178-2000-3','HotSch-178-2000-4','HotSch-178-2000-5','MsgBox-178-1000-13','MsgBox-178-1000-14')
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (178,2000,3,'HotSch-178-2000-3','JCYear','','',1,1,1,'2009-04-28',1,'2009-04-28','JCYear','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (178,2000,4,'HotSch-178-2000-4','StartDate ','','',1,1,1,'2009-04-28',1,'2009-04-28','StartDate ','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (178,2000,5,'HotSch-178-2000-5','EndDate ','','',1,1,1,'2009-04-28',1,'2009-04-28','EndDate ','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (178,1000,13,'MsgBox-178-1000-13','','','JC Year',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Year',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (178,1000,14,'MsgBox-178-1000-14','','','JC Month',1,1,1,'2009-04-28',1,'2009-04-28','','','JC Month',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10134,10135,10136)
INSERT INTO HotSearchEditorHd
SELECT 10134,'Van Subsidy Claim','ACYear','select','SELECT AcmId,AcmYr FROM ACMaster WITH (NOLOCK)' UNION
SELECT 10135,'Van Subsidy Claim','ACFromMonth','select','SELECT ACMonth,AcmSdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam' UNION
SELECT 10136,'Van Subsidy Claim','ACToMonth','select','SELECT ACMonth,AcmEdt FROM ACPeriod WITH (NOLOCK) WHERE AcmId=vFParam'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10134,10135,10136)
INSERT INTO HotSearchEditorDt
SELECT 1,10134,'ACYear','ACYear','AcmYr',4250,0,'HotSch-178-2000-7',178 UNION
SELECT 1,10135,'ACFromMonth','From Month','AcmSdt',4500,0,'HotSch-178-2000-4',178 UNION
SELECT 1,10136,'ACToMonth','To Month','AcmEdt',4500,0,'HotSch-178-2000-5',178
GO
DELETE FROM CustomCaptions WHERE TransId = 178 AND CtrlId IN(2000,1000)
AND CtrlName IN ('HotSch-178-2000-7','MsgBox-178-1000-43','MsgBox-178-1000-44')
INSERT INTO CustomCaptions
SELECT 178,2000,7,'HotSch-178-2000-7','AC Year','','',1,1,1,GETDATE(),1,GETDATE(),'AC Year','','',1,1 UNION
SELECT 178,1000,43,'MsgBox-178-1000-43','','','AC Year',1,1,1,GETDATE(),1,GETDATE(),'','','AC Year',1,1 UNION
SELECT 178,1000,44,'MsgBox-178-1000-44','','','AC Month',1,1,1,GETDATE(),1,GETDATE(),'','','AC Month',1,1
GO
--JC Year & JC Month
DELETE FROM HotSearcheditorHd WHERE FormId IN(219,233,235,266,272,478,496,511)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (219,'Delivery Boy Salary and DA Claim','RefNo','select','SELECT DlvBoyClmId,DbcRefNo,DbcDate,CmpId,CmpName,JcmId,JcmYr,FromJcmJc,JcmSdt,ToJcmJc,JcmEdt,TotSalAmt,TotSalSugClm,TotDays,TotDailyAlw,TotSugDailyAlw,TotSugClm,TotApproveAmt FROM  (SELECT DISTINCT DBM.DlvBoyClmId,DBM.DbcRefNo,DBM.DbcDate, CMP.CmpId, CMP.CmpName,JCY.JcmId,JCY.JcmYr,DBM.FromJcmJc,JCM1.JcmSdt,DBM.ToJcmJc,  JCM2.JcmEdt,DBM.TotSalAmt,DBM.TotSalSugClm,DBM.TotDays,DBM.TotDailyAlw,DBM.TotSugDailyAlw,DBM.TotSugClm,DBM.TotApproveAmt  FROM DeliveryBoyClaimMaster DBM, Company CMP, JCMast JCY, JCMonth JCM1, JCMonth JCM2 WITH (NOLOCK)  WHERE DBM.JcmId=JCY.JcmId AND DBM.CmpId=CMP.CmpId AND DBM.FromJcmJc=JCM1.JcmJc AND DBM.JcmId=JCM1.JcmId  AND DBM.ToJcmJc=JCM2.JcmJc AND DBM.JcmId=JCM2.JcmId) Mainsql')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (233,'Salesman Incentive Calculator','RefNo','select','SELECT SmIncCalcId,SicRefNo,SicDate,CmpId,CmpName,JcmId,JcmYr,FromJcmJc,JcmSdt,ToJcmJc,JcmEdt FROM   (SELECT DISTINCT SMI.SmIncCalcId,SMI.SicRefNo,SMI.SicDate, CMP.CmpId, CMP.CmpName,JCY.JcmId,JCY.JcmYr,SMI.FromJcmJc,JCM1.JcmSdt,SMI.ToJcmJc,JCM2.JcmEdt  FROM SMIncentiveCalculatorMaster SMI, Company CMP, JCMast JCY, JCMonth JCM1, JCMonth JCM2 WITH (NOLOCK)  WHERE SMI.JcmId=JCY.JcmId AND SMI.CmpId=CMP.CmpId AND SMI.FromJcmJc=JCM1.JcmJc AND SMI.JcmId=JCM1.JcmId  AND SMI.ToJcmJc=JCM2.JcmJc AND SMI.JcmId=JCM2.JcmId) MAinsql')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (235,'Salesman Salary and DA Claim','ReferenceNo','select','SELECT ScmRefNo,ScmDate,CmpId,JcmId,FromJcmJcId,ToJcmJcId,TotalSalAmt,TotalSuggClaimScmSal,TotalNoOfDays,TotalDailyAllow,TotalSuggClaimDailyAllow,TotalSuggClaim,TotalApprovedAmt,JcmSdt,JcmEdt,JcmYr,CmpName,SmDAClaimId  FROM  (Select SMC.ScmRefNo,SMC.ScmDate,SMC.CmpId,SMC.JcmId,SMC.FromJcmJcId,   SMC.ToJcmJcId,SMC.TotalSalAmt,SMC.TotalSuggClaimScmSal,SMC.TotalNoOfDays,SMC.TotalDailyAllow,  SMC.TotalSuggClaimDailyAllow,SMC.TotalSuggClaim,  SMC.TotalApprovedAmt,  JMN1.JcmSdt,JMN2.JcmEdt,JMT.JcmYr,CMP.CmpName,SMC.SmDAClaimId  From SalesmanClaimMaster SMC,  JcMast JMT,JCMonth JMN1,JCMonth JMN2,Company CMP  Where JMT.Jcmid=SMC.JcmId    and SMC.FromJcmJcId=JMN1.JcmJc AND SMC.JCMId = JMN1.JcmId  AND SMC.ToJcmJcId=JMN2.JcmJc   AND SMC.JCMId = JMN2.JcmId and SMC.CmpId=CMP.CmpId)MainSql')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (266,'Transporter Claim','RefNo','select','SELECT TrcRefNo,TrcDate,CmpId,CmpName,JcmId,JcmYr,FromJcmJc,JcmSdt,ToJcmJc,JcmEdt,TotalSpentAmt,TotalRecAmt  FROM (SELECT DISTINCT TCM.TrcRefNo,TCM.TrcDate, CMP.CmpId, CMP.CmpName,JCY.JcmId,JCY.JcmYr,TCM.FromJcmJc,  JCM1.JcmSdt,TCM.ToJcmJc,JCM2.JcmEdt,TCM.TotalSpentAmt,TCM.TotalRecAmt  FROM TransporterClaimMaster TCM, Company CMP, JCMast JCY, JCMonth JCM1, JCMonth JCM2 WITH (NOLOCK)  WHERE TCM.JcmId=JCY.JcmId AND TCM.CmpId=CMP.CmpId AND TCM.FromJcmJc=JCM1.JcmJc AND TCM.JcmId=JCM1.JcmId  AND TCM.ToJcmJc=JCM2.JcmJc AND TCM.JcmId=JCM2.JcmId) MainQry')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (272,'Manual Claim','ReferenceNo','select','Select MacRefNo,MacDate,CmpId,JcmId,FromJcmJcId,ToJcmJcId,TotalClaimAmt,Description,  Remarks,JcmSdt,JcmEdt,JcmYr,CmpName,MacRefId From  (Select MAC.MacRefNo,MAC.MacDate,MAC.CmpId,MAC.JcmId,MAC.FromJcmJcId,  MAC.ToJcmJcId,MAC.TotalClaimAmt,MAC.Description,MAC.Remarks,JMN1.JcmSdt,  JMN2.JcmEdt,JMT.JcmYr,CMP.CmpName,MAC.MacRefId  From ManualClaimMaster MAC,JcMast JMT,  JCMonth JMN1,JCMonth JMN2,Company CMP  Where JMT.Jcmid=MAC.JcmId  and MAC.FromJcmJcId=JMN1.JcmJc AND MAC.JCMId = JMN1.JcmId  AND MAC.ToJcmJcId=JMN2.JcmJc AND MAC.JCMId = JMN2.JcmId  and MAC.CmpId=CMP.CmpId) MainQry')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (478,'Purchase Excess Quantity Refusal Claim','ReferenceNumber','select','SELECT RefNo,Date,Status,CmpId,CmpName,JcmId,JcmYr,FromJcMonth,ToJcMonth FROM (SELECT PEC.RefNo,  PEC.Date,PEC.Status,PEC.CmpId,C.CmpName,PEC.JcmId,J.JcmYr,PEC.FromJcMonth,PEC.ToJcMonth  FROM PurchaseExcessClaimMaster PEC WITH (NOLOCK),Company C  WITH (NOLOCK),JCMast J WITH (NOLOCK)  WHERE PEC.CmpId=C.CmpId AND J.JcmId=PEC.JcmId)A')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (496,'VAT Claim','Reference No','select','SELECT VTC.SvatNo, VTC.RefNo, VTC.VatDate, VTC.Status,CMP.CmpId,  CMP.CmpName,JCY.JcmId , JCY.JcmYr, VTC.FromJcmJc, JCM1.JcmSdt,  VTC.ToJcmJc, JCM2.JcmEdt  FROM VatTaxClaim VTC, Company CMP, JCMast JCY,  JCMonth JCM1, JCMonth JCM2  Where VTC.JcmId = JCY.JcmId And VTC.CmpId = CMP.CmpId  And VTC.FromJcmJc = JCM1.JcmJc AND VTC.JcmId=JCM1.JcmId  AND VTC.ToJcmJc=JCM2.JcmJc AND VTC.JcmId=JCM2.JcmId')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (511,'RateDifferenceClaim','RateDifference','select','SELECT RDC.RefNo,RDC.Date,RDC.Status,RDC.CmpId,C.CmpName,RDC.JcmId,J.JcmYr,RDC.FromJcMonth,RDC.ToJcMonth,RDC.TotSpentAmt,RDC.TotNegClaimAmt,RDC.TotClaimAmt,             RDC.RecSpentAmt , RDC.RecNegClaimAmt, RDC.RecClaimAmt,RDC.RateDiffClaimId              FROM RateDifferenceClaim RDC WITH (NOLOCK),Company C  WITH (NOLOCK),JCMast J WITH (NOLOCK) WHERE RDC.CmpId=C.CmpId AND J.JcmId=RDC.JcmId')
GO
--AC Year & AC Month
DELETE FROM HotSearcheditorHd WHERE FormId IN(10137,10138,10139,10140,10141,10142,10143,10144)
INSERT INTO HotSearcheditorHd
SELECT 10137,'Delivery Boy Salary and DA Claim','RefNo','select',
'SELECT DISTINCT DlvBoyClmId,DbcRefNo,DbcDate,CmpId,CmpName,AcmId,AcmYr,FromJcmJc,AcmSdt,
ToJcmJc,AcmEdt,TotSalAmt,TotSalSugClm,TotDays,TotDailyAlw,TotSugDailyAlw,TotSugClm,TotApproveAmt FROM 
(SELECT DISTINCT DBM.DlvBoyClmId,DBM.DbcRefNo,DBM.DbcDate, CMP.CmpId, CMP.CmpName,JCY.AcmId,JCY.AcmYr,DBM.FromJcmJc,JCM1.AcmSdt,DBM.ToJcmJc,
JCM2.AcmEdt,DBM.TotSalAmt,DBM.TotSalSugClm,DBM.TotDays,DBM.TotDailyAlw,DBM.TotSugDailyAlw,DBM.TotSugClm,DBM.TotApproveAmt  
FROM DeliveryBoyClaimMaster DBM, Company CMP, ACMaster JCY, ACPeriod JCM1, ACPeriod JCM2 WITH (NOLOCK) WHERE DBM.JcmId=JCY.AcmId AND DBM.CmpId=CMP.CmpId 
AND DBM.FromJcmJc=JCM1.ACMonth AND DBM.JcmId=JCM1.AcmId  AND DBM.ToJcmJc=JCM2.ACMonth AND DBM.JcmId=JCM2.AcmId) Mainsql' UNION
SELECT	10138,'Salesman Incentive Calculator','RefNo','select','SELECT SmIncCalcId,SicRefNo,SicDate,CmpId,CmpName,AcmId,AcmYr,FromJcmJc,AcmSdt,ToJcmJc,AcmEdt FROM   
(SELECT DISTINCT SMI.SmIncCalcId,SMI.SicRefNo,SMI.SicDate, CMP.CmpId, CMP.CmpName,JCY.AcmId,JCY.AcmYr,SMI.FromJcmJc,JCM1.AcmSdt,SMI.ToJcmJc,JCM2.AcmEdt  
FROM SMIncentiveCalculatorMaster SMI, Company CMP, ACMaster JCY, ACPeriod JCM1, ACPeriod JCM2 WITH (NOLOCK) WHERE SMI.JcmId=JCY.AcmId AND SMI.CmpId=CMP.CmpId AND SMI.FromJcmJc=JCM1.ACMonth AND SMI.JcmId=JCM1.AcmId  
AND SMI.ToJcmJc=JCM2.ACMonth AND SMI.JcmId=JCM2.AcmId) MAinsql'	UNION
SELECT	10139,'Salesman Salary and DA Claim','ReferenceNo','select','SELECT ScmRefNo,ScmDate,CmpId,JcmId,FromJcmJcId,ToJcmJcId,TotalSalAmt,TotalSuggClaimScmSal,TotalNoOfDays,TotalDailyAllow,
TotalSuggClaimDailyAllow,TotalSuggClaim,TotalApprovedAmt,AcmSdt,AcmEdt,AcmYr,CmpName,SmDAClaimId FROM (Select SMC.ScmRefNo,SMC.ScmDate,
SMC.CmpId,SMC.JcmId,SMC.FromJcmJcId,SMC.ToJcmJcId,SMC.TotalSalAmt,SMC.TotalSuggClaimScmSal,SMC.TotalNoOfDays,SMC.TotalDailyAllow,
SMC.TotalSuggClaimDailyAllow,SMC.TotalSuggClaim,  SMC.TotalApprovedAmt,  JMN1.AcmSdt,JMN2.AcmEdt,JMT.AcmYr,CMP.CmpName,SMC.SmDAClaimId  
FROM SalesmanClaimMaster SMC,ACMaster JMT,ACPeriod JMN1,ACPeriod JMN2,Company CMP  Where JMT.Acmid=SMC.JcmId AND SMC.FromJcmJcId=JMN1.ACMonth 
AND SMC.JCMId = JMN1.AcmId  AND SMC.ToJcmJcId=JMN2.AcMonth AND SMC.JCMId = JMN2.AcmId and SMC.CmpId=CMP.CmpId)MainSql' UNION
SELECT	10140,'Transporter Claim','RefNo','select','SELECT TrcRefNo,TrcDate,CmpId,CmpName,AcmId,AcmYr,FromJcmJc,AcmSdt,ToJcmJc,AcmEdt,TotalSpentAmt,TotalRecAmt 
FROM (SELECT DISTINCT TCM.TrcRefNo,TCM.TrcDate, CMP.CmpId, CMP.CmpName,JCY.AcmId,JCY.AcmYr,TCM.FromJcmJc,  
JCM1.AcmSdt,TCM.ToJcmJc,JCM2.AcmEdt,TCM.TotalSpentAmt,TCM.TotalRecAmt FROM TransporterClaimMaster TCM, Company CMP, 
ACMaster JCY, ACPeriod JCM1, ACPeriod JCM2 WITH (NOLOCK)  WHERE TCM.JcmId=JCY.AcmId AND TCM.CmpId=CMP.CmpId 
AND TCM.FromJcmJc=JCM1.ACMonth AND TCM.JcmId=JCM1.AcmId  AND TCM.ToJcmJc=JCM2.ACMonth AND TCM.JcmId=JCM2.AcmId) MainQry' UNION
SELECT	10141,'Manual Claim','ReferenceNo','select','SELECT MacRefNo,MacDate,CmpId,JcmId,FromJcmJcId,ToJcmJcId,TotalClaimAmt,DESCRIPTION,Remarks,
AcmSdt,AcmEdt,AcmYr,CmpName,MacRefId FROM (SELECT MAC.MacRefNo,MAC.MacDate,MAC.CmpId,MAC.JcmId,MAC.FromJcmJcId,    
MAC.ToJcmJcId,MAC.TotalClaimAmt,MAC.Description,MAC.Remarks,JMN1.AcmSdt, JMN2.AcmEdt,JMT.AcmYr,CMP.CmpName,MAC.MacRefId  
FROM ManualClaimMaster MAC,ACMaster JMT,ACPeriod JMN1,ACPeriod JMN2,Company CMP  WHERE JMT.AcmId=MAC.JcmId 
AND MAC.FromJcmJcId=JMN1.ACMonth AND MAC.JCMId = JMN1.AcmId  AND MAC.ToJcmJcId=JMN2.ACMonth 
AND MAC.JCMId = JMN2.AcmId   and MAC.CmpId=CMP.CmpId) MainQry' UNION
SELECT	10142,'Purchase Excess Quantity Refusal Claim','ReferenceNumber','select',
'SELECT RefNo,Date,Status,CmpId,CmpName,JcmId,AcmYr,FromJcMonth,ToJcMonth FROM (SELECT PEC.RefNo,PEC.Date,PEC.Status,PEC.CmpId,C.CmpName,
PEC.JcmId,J.AcmYr,PEC.FromJcMonth,PEC.ToJcMonth FROM PurchaseExcessClaimMaster PEC WITH (NOLOCK),Company C  WITH (NOLOCK),
ACMaster J WITH (NOLOCK) WHERE PEC.CmpId=C.CmpId AND J.AcmId=PEC.JcmId)A' UNION
SELECT	10143,'VAT Claim','Reference No','select','SELECT VTC.SvatNo, VTC.RefNo,VTC.VatDate,VTC.Status,CMP.CmpId,CMP.CmpName,JCY.AcmId , 
JCY.AcmYr, VTC.FromJcmJc, JCM1.AcmSdt,VTC.ToJcmJc, JCM2.AcmEdt FROM VatTaxClaim VTC,Company CMP,
ACMaster JCY,ACPeriod JCM1,ACPeriod JCM2 Where VTC.JcmId = JCY.AcmId And VTC.CmpId = CMP.CmpId And 
VTC.FromJcmJc = JCM1.ACMonth AND VTC.JcmId=JCM1.AcmId AND VTC.ToJcmJc=JCM2.ACMonth AND VTC.JcmId=JCM2.AcmId' UNION
SELECT	10144,'RateDifferenceClaim','RateDifference','select',
'SELECT RDC.RefNo,RDC.Date,RDC.Status,RDC.CmpId,C.CmpName,RDC.JcmId,J.AcmYr,RDC.FromJcMonth,RDC.ToJcMonth,RDC.TotSpentAmt,RDC.TotNegClaimAmt,
RDC.TotClaimAmt,RDC.RecSpentAmt,RDC.RecNegClaimAmt,RDC.RecClaimAmt,RDC.RateDiffClaimId FROM RateDifferenceClaim RDC WITH (NOLOCK),
Company C  WITH (NOLOCK),ACMaster J WITH (NOLOCK)WHERE RDC.CmpId=C.CmpId AND J.AcmId=RDC.JcmId'
GO
--Special Discount Claim
DELETE FROM HotSearchEditorHd WHERE FormId IN (240,241,242)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (240,'Special Discount Claim','JCYear','select','select JcmId,JcmYr from JCMast WITH (NOLOCK) WHERE CmpId =vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (241,'Special Discount Claim','JCFromMonth','select','select JcmSdt,JcmJc from jcmonth WITH (NOLOCK) where JcmId=vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (242,'Special Discount Claim','JCToMonth','select','select JcmEdt,JcmJc from jcmonth WITH (NOLOCK) where JcmId=vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (240,241,242)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,240,'JCYear','JCYear','JcmYr',4500,0,'HotSch-143-2000-4',143)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,241,'JCFromMonth','FromMonth','JcmSdt',4500,0,'HotSch-143-2000-5',143)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,242,'JCToMonth','ToMonth','JcmEdt',4500,0,'HotSch-143-2000-6',143)
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (10145,10146,10147)
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10145,'Special Discount Claim','ACYear','select','select AcmId,AcmYr from ACMaster WITH (NOLOCK)')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10146,'Special Discount Claim','ACFromMonth','select','select AcmSdt,ACmonth from ACPeriod WITH (NOLOCK) where AcmId=vFParam')
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10147,'Special Discount Claim','ACToMonth','select','select AcmEdt,ACmonth from ACPeriod WITH (NOLOCK) where AcmId=vFParam')
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (10145,10146,10147)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10145,'ACYear','Year','AcmYr',4500,0,'HotSch-143-2000-4',143)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10146,'ACFromMonth','FromMonth','AcmSdt',4500,0,'HotSch-143-2000-5',143)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,10147,'ACToMonth','ToMonth','AcmEdt',4500,0,'HotSch-143-2000-6',143)
GO
DELETE FROM CustomCaptions WHERE TransId = 143 AND CtrlId = 2000 AND SubCtrlId IN (5,6)
INSERT INTO CustomCaptions
SELECT 143,2000,5,'HotSch-143-2000-5','StartDate','','',1,1,1,GETDATE(),1,GETDATE(),'StartDate','','',1,1 UNION
SELECT 143,2000,6,'HotSch-143-2000-6','EndDate','','',1,1,1,GETDATE(),1,GETDATE(),'EndDate','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId = 143 AND CtrlId = 1000 AND SubCtrlId IN (8,10,11,14,15,16)
INSERT INTO CustomCaptions
SELECT 143,1000,8,'Msgbox-143-1000-8','','','From Month Should not be greater than To Month',1,1,1,GETDATE(),1,GETDATE(),'','',
'From Month Should not be greater than To Month',1,1 UNION
SELECT 143,1000,10,'Msgbox-143-1000-10','','','Year does not exists',1,1,1,GETDATE(),1,GETDATE(),'','','Year does not exists',1,1 UNION
SELECT 143,1000,11,'Msgbox-143-1000-11','','','Month does not exists',1,1,1,GETDATE(),1,GETDATE(),'','','Month does not exists',1,1 UNION
SELECT 143,1000,14,'PnlMsg-143-1000-14','','Press F4/Double click to select Year','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double click to select Year','',1,1 UNION
SELECT 143,1000,15,'PnlMsg-143-1000-15','','Press F4/Double click to select From Month','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double click to select From Month','',1,1 UNION
SELECT 143,1000,16,'PnlMsg-143-1000-16','','Press F4/Double click to select To Month','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double click to select To Month','',1,1
GO
DELETE FROM HotSearchEditorHd WHERE formId IN (248,10148)
INSERT INTO HotSearchEditorHd
SELECT 248,'Special Discount Claim','ReferenceNo','select',
'SELECT SdcRefNo,SdcDate,CmpId,JcmId,FromJcmJcId,ToJcmJcId,TotalSpentAmt,TotalRecAmt,Status,JcmSdt,JcmEdt,JcmYr,CmpName,SplDiscClaimId FROM  
(SELECT SDM.SdcRefNo,SDM.SdcDate,SDM.CmpId,SDM.JcmId,SDM.FromJcmJcId,SDM.ToJcmJcId,SDM.TotalSpentAmt,SDM.TotalRecAmt,SDM.Status,JMN1.JcmSdt,
JMN2.JcmEdt,JMT.JcmYr,CMP.CmpName,SplDiscClaimId FROM SpecialDiscountMaster SDM,JcMast JMT,JCMonth JMN1,JCMonth JMN2,Company CMP 
WHERE JMT.Jcmid=SDM.JcmId AND SDM.FromJcmJcId=JMN1.JcmJc AND SDM.JCMId = JMN1.JcmId AND SDM.ToJcmJcId=JMN2.JcmJc AND SDM.JCMId = JMN2.JcmId 
AND SDM.CmpId=CMP.CmpId)Mainsql' UNION
SELECT 10148,'Special Discount Claim','ReferenceNo','select',
'SELECT SdcRefNo,SdcDate,CmpId,JcmId,FromJcmJcId,ToJcmJcId,TotalSpentAmt,TotalRecAmt,Status,AcmSdt,AcmEdt,AcmYr,CmpName,SplDiscClaimId FROM  
(SELECT SDM.SdcRefNo,SDM.SdcDate,SDM.CmpId,SDM.JcmId,SDM.FromJcmJcId,SDM.ToJcmJcId,SDM.TotalSpentAmt,SDM.TotalRecAmt,SDM.Status,JMN1.AcmSdt,
JMN2.AcmEdt,JMT.AcmYr,CMP.CmpName,SplDiscClaimId FROM SpecialDiscountMaster SDM,AcMaster JMT,ACPeriod JMN1,ACPeriod JMN2,Company CMP 
WHERE JMT.Acmid=SDM.JcmId AND SDM.FromJcmJcId=JMN1.AcMonth AND SDM.JCMId = JMN1.AcmId AND SDM.ToJcmJcId=JMN2.AcMonth AND SDM.JCMId = JMN2.AcmId 
AND SDM.CmpId=CMP.CmpId)Mainsql'
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype IN ('TF','FN') AND Name = 'Fn_RetrunClaimDetails')
DROP FUNCTION [dbo].[Fn_RetrunClaimDetails]
GO
CREATE FUNCTION [dbo].[Fn_RetrunClaimDetails](@Pi_ClaimGrpId AS INT,@Pi_CmpId AS INT,@Pi_FromDate AS DATETIME,@Pi_ToDate AS DATETIME,
@Pi_ClaimCode AS INT,@Pi_UsrId AS INT,@Pi_TransId AS INT) RETURNS
@RetrunClaimDetails TABLE
(
[Reference] NVARCHAR(200),
[Select] INT,
[Total Spent Amount] NUMERIC(36,6),
[% Claimable] NUMERIC(36,6),
[Claimable Amount] NUMERIC(36,6),
[Recommended Amount] NUMERIC(36,6),
[Received Amount] NUMERIC(36,6),
[Db/Cr Note Selection] INT,
[Status] NVARCHAR(100),
[Remarks] NVARCHAR(500)
)
/*********************************	
* FUNCTION: Fn_RetrunClaimDetails
* PURPOSE: Returns Claim Details
* NOTES:
* CREATED: Sathishkumar Veeramani on 08-04-2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
AS
BEGIN
  IF @Pi_ClaimGrpId = 1 --Salesman Salary / DA Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT SC.ScmRefNo as 'Reference' , 0 as 'Select', SC.Amount as 'Total Spent Amount',ISNULL(CND.Claimable,0) as '% Claimable',
		0.00 as 'Claimable Amount',0 'Recommended Amount', 0 'Received Amount' ,0 AS 'Db/Cr Note Selection', 'Cancelled' as 'Status','' AS Remarks  
		FROM (SELECT SCM.ScmRefNo , SCM.ScmDate , SCM.CmpId, TotalApprovedAmt Amount FROM  SalesmanClaimMaster SCM WITH (NOLOCK) WHERE SCM.Status = 1) SC  
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON SC.CmpId = CND.CmpId and  CND.ClmGrpId = @Pi_ClaimGrpId WHERE SC.CmpId = @Pi_CmpId 
		AND SC.ScmDate  BETWEEN @Pi_ToDate AND @Pi_ToDate AND SC.ScmRefNo  NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId)AND SelectMode=1)
  END
  ELSE IF @Pi_ClaimGrpId = 2 --DeliveryBoy Salary / DA Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT DC.DbcRefNo AS 'Reference',0 AS 'Select',  DC.TotApproveAmt AS 'Total Spent Amount',  isNull(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount',  0 'Recommended Amount' , 0 'Received Amount' ,0 AS 'Db/Cr Note Selection', 'Cancelled' AS 'Status','' AS Remarks  
		FROM (SELECT DbcDate,DbcRefNo,CmpId,TotApproveAmt FROM  DeliveryBoyClaimMaster  WITH (NOLOCK) WHERE Status = 1 ) DC  
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON DC.CmpId = CND.CmpId AND  CND.ClmGrpId = @Pi_ClaimGrpId WHERE DC.CmpId = @Pi_CmpId  
		AND DC.DbcDate BETWEEN @Pi_ToDate AND @Pi_ToDate AND DC.DbcRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId) AND SelectMode=1)
  END  
  ELSE IF @Pi_ClaimGrpId = 3 --Salesman Incentive Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT SIC.SicRefNo as 'Reference',0 AS 'Select',  SIC.TotAppInc AS 'Total Spent Amount', ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount',  0 'Recommended Amount' , 0 'Received Amount' ,0 AS 'Db/Cr Note Selection', 'Cancelled' AS 'Status','' AS Remarks 
		FROM  (SELECT SicDate,SicRefNo,CmpId,TotAppInc FROM  SMIncentiveCalculatorMaster WITH (NOLOCK) WHERE Status = 1 ) SIC  
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON SIC.CmpId = CND.CmpId and  CND.ClmGrpId = @Pi_ClaimGrpId WHERE SIC.CmpId = @Pi_CmpId  
		AND SIC.SicDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SIC.SicRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId) AND SelectMode=1)
  END
  ELSE IF @Pi_ClaimGrpId = 4 --Van Subsidy Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT VS.RefNo as 'Reference' , 0 as 'Select', VS.Amount as 'Total Spent Amount' ,ISNULL(CND.Claimable,0) as '% Claimable',
		0.00 as 'Claimable Amount',0 'Recommended Amount' , 0 'Received Amount' , 0 AS 'Db/Cr Note Selection', 'Cancelled' as 'Status','' AS Remarks 
		FROM (SELECT SCM.RefNo , SCM.SubsidyDt , SCM.CmpId, SCM.ApprovedClaimAmt Amount FROM VanSubsidyHD SCM WHERE SCM.Confirm = 1) VS  
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON VS.CmpId = CND.CmpId AND  CND.ClmGrpId = @Pi_ClaimGrpId WHERE VS.CmpId = @Pi_CmpId 
		AND VS.SubsidyDt BETWEEN @Pi_FromDate AND @Pi_ToDate AND VS.RefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId) AND SelectMode=1)
  END  
  ELSE IF @Pi_ClaimGrpId = 5 --Transporter Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT TC.TrcRefNo as 'Reference' , 0 as 'Select', TC.TotalRecAmt as 'Total Spent Amount' ,ISNULL(CND.Claimable,0) as '% Claimable',
		0.00 as 'Claimable Amount' ,0 'Recommended Amount', 0 'Received Amount' , 0 AS 'Db/Cr Note Selection','Cancelled' as 'Status','' AS Remarks 
		FROM (SELECT TrcRefNo,TotalRecAmt,CmpId,TrcDate FROM TransporterClaimMaster WITH (NOLOCK) WHERE Status = 1 ) TC  
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON TC.CmpId = CND.CmpId and  CND.ClmGrpId = @Pi_ClaimGrpId WHERE TC.CmpId = @Pi_CmpId  
		AND TC.TrcDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND TC.TrcRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId ) AND SelectMode=1)
  END
  ELSE IF @Pi_ClaimGrpId = 6 --Return To Company
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT RTC.RtnCmpRefNo AS 'Reference',0 AS 'Select',  RTC.Amount AS 'Total Spent Amount',ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount',  0 'Recommended Amount' , 0 'Received Amount' , 0 AS 'Db/Cr Note Selection','Cancelled' AS 'Status','' AS Remarks 
		FROM (SELECT RTCM.RtnCmpRefNo,RTCM.RtncmpDate,S.CmpId,SUM(RTCD.AmtForClaim) Amount FROM ReturnToCompany RTCM WITH (NOLOCK),
		ReturnToCompanyDt RTCD WITH (NOLOCK),Supplier S  WITH (NOLOCK) WHERE RTCM.RtnCmpRefNo = RTCD.RtnCmpRefNo AND S.SpmId = RTCM.SpmId 
		AND RTCM.Status=1  GROUP BY RTCM.RtnCmpRefNo,RTCM.RtncmpDate,S.CmpId)RTC  LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON RTC.CmpId = CND.CmpId 
		AND CND.ClmGrpId = @Pi_ClaimGrpId WHERE RTC.Amount <> 0 AND RTC.CmpId = 1 and RTC.RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
		AND RTC.RtnCmpRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) 
		WHERE ClmGrpId  = @Pi_ClaimGrpId AND ClmId <>0 ) AND SelectMode=1)
  END
  ELSE IF @Pi_ClaimGrpId = 7 --Batch Transfer Value difference Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT BTC.BatRefNo AS 'Reference',0 AS 'Select', BTC.Amount AS 'Total Spent Amount' ,ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount',  0 'Recommended Amount' , 0 'Received Amount' , 0 AS 'Db/Cr Note Selection','Cancelled'  AS 'Status','' AS Remarks 
		FROM(SELECT BatRefNo,BatTrfDate,P.CmpId,ClmAmt Amount FROM BatchTransferClaim BT WITH (NOLOCK), Product P WITH (NOLOCK) WHERE BT.PrdId = P.PrdId) BTC 
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON BTC.CmpId = CND.CmpId AND CND.ClmGrpId = @Pi_ClaimGrpId WHERE BTC.CmpId = @Pi_CmpId 
		AND BTC.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate  AND BTC.BatRefNo NOT IN (SELECT RefCode FROM  ClaimSheetDetail 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WHERE ClmGrpId  = @Pi_ClaimGrpId AND ClmId <>0) AND SelectMode=1) 
  END
  ELSE IF @Pi_ClaimGrpId = 8 --Salvage Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
        SELECT SC.SalvageRefNo as 'Reference' , 0 as 'Select', SC.Amount as 'Total Spent Amount',ISNULL(CND.Claimable,0) AS '% Claimable',
        0.00 as 'Claimable Amount',0 'Recommended Amount' , 0 'Received Amount' ,0 AS 'Db/Cr Note Selection','Cancelled' AS 'Status','' AS Remarks 
        FROM(SELECT S.SalvageRefNo,S.SalvageDate,P.CmpId,SUM(AmtForClaim) Amount FROM SalvageProduct SP WITH (NOLOCK),Salvage S WITH (NOLOCK),
        Product P WITH (NOLOCK) WHERE S.SalvageRefNo = SP.SalvageRefNo and SP.PrdId = P.PrdId AND S.Status=1 GROUP BY S.SalvageRefNo,S.SalvageDate,P.CmpId) SC 
        LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON SC.CmpId = CND.CmpId AND CND.ClmGrpId = @Pi_ClaimGrpId WHERE SC.CmpId = @Pi_CmpId
        AND SC.SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SC.SalvageRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH(NOLOCK)
        WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WHERE ClmGrpId = @Pi_ClaimGrpId AND ClmId <> @Pi_CmpId) AND SelectMode=1)
  END  
  ELSE IF @Pi_ClaimGrpId = 9 --Sample Issued
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT SC.StkJournalRefNo AS 'Reference' , 0 AS 'Select', SC.Amount AS 'Total Spent Amount' ,ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount' ,  0 'Recommended Amount' ,0 'Received Amount' ,0 AS 'Db/Cr Note Selection',  'Cancelled' AS 'Status','' AS Remarks 
		FROM (SELECT StkJournalRefNo,StkJournalDate,P.CmpId,ClmAmt Amount FROM StkJournalClaim SJC  WITH (NOLOCK),Product P WITH (NOLOCK)WHERE SJC.PrdId = P.PrdId) SC  
		LEFT OUTER JOIN ClaimNormDefinition CND ON SC.CmpId = CND.CmpId AND CND.ClmGrpId = @Pi_ClaimGrpId WHERE SC.CmpId = @Pi_CmpId 
		AND SC.StkJournalDate  BETWEEN @Pi_FromDate AND @Pi_ToDate AND SC.StkJournalRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WHERE ClmGrpId  = @Pi_ClaimGrpId AND ClmId <>0) AND SelectMode=1) 
  END
  ELSE IF @Pi_ClaimGrpId = 10 --Resell Damage Goods Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT RSC.ClaimRefNo AS 'Reference' , 0 AS 'Select', RSC.ClaimAmt AS 'Total Spent Amount' ,ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount' ,0 'Recommended Amount', 0 'Received Amount' ,0 AS 'Db/Cr Note Selection', 'Cancelled' AS 'Status','' AS Remarks 
		FROM (SELECT ClaimRefNo,ClaimAmt,CmpId,ResellDate FROM ReSellDamageMaster WITH (NOLOCK) WHERE Status = 1) RSC 
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON  RSC.CmpId = CND.CmpId and CND.ClmGrpId = @Pi_ClaimGrpId WHERE RSC.CmpId = @Pi_CmpId 
		AND RSC.ResellDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND RSC.ClaimRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId AND ClmId <>0) AND SelectMode=1)  
  END
  ELSE IF @Pi_ClaimGrpId = 11 --Special Discount Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT DC.SdcRefNo as 'Reference',0 as 'Select',DC.TotalRecAmt as 'Total Spent Amount',ISNULL(CND.Claimable,0) as '% Claimable',
		0.00 as 'Claimable Amount',0 'Recommended Amount',0 'Received Amount' ,0 AS 'Db/Cr Note Selection','Cancelled' as 'Status','' AS Remarks 
		FROM (SELECT SdcDate,SdcRefNo,CmpId,TotalRecAmt FROM SpecialDiscountMaster WITH (NOLOCK) WHERE Status = 1) DC  
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON DC.CmpId = CND.CmpId and CND.ClmGrpId =  @Pi_ClaimGrpId WHERE DC.CmpId = @Pi_CmpId 
		AND DC.SdcDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DC.SdcRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH(NOLOCK)
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WHERE ClmGrpId  =  @Pi_ClaimGrpId) AND SelectMode=1)
  END            
  ELSE IF @Pi_ClaimGrpId = 12 --Rate Difference Claim
  BEGIN  
         INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		 SELECT RDC.RefNo AS 'Reference' , 0 AS 'Select', RDC.Amount AS 'Total Spent Amount' , ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount' ,  0 'Recommended Amount' , 0 'Received Amount' , 0 AS 'Db/Cr Note Selection', 'Cancelled' AS 'Status','' AS Remarks 
		FROM (SELECT RefNo,Date,CmpId,RecClaimAmt Amount FROM RateDifferenceClaim WITH (NOLOCK)  WHERE Status = 1) RDC  
		LEFT OUTER JOIN ClaimNormDefinition CND ON RDC.CmpId = CND.CmpId AND CND.ClmGrpId = @Pi_ClaimGrpId WHERE RDC.CmpId = @Pi_CmpId  
		AND RDC.Date BETWEEN @Pi_FromDate AND @Pi_ToDate AND RDC.RefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId) AND SelectMode=1)
  END
  ELSE IF @Pi_ClaimGrpId = 13 --VAT Claim
  BEGIN  
         INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT VC.RefNo AS 'Reference' , 0 AS 'Select', VC.RecVatTax AS 'Total Spent Amount' ,ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount' ,  0 'Recommended Amount' , 0 'Received Amount' ,0 AS 'Db/Cr Note Selection', 'Cancelled' AS 'Status','' AS Remarks 
		FROM (SELECT RefNo,RecVatTax,CmpId,VatDate FROM VatTaxClaim WITH (NOLOCK) WHERE Status = 1) VC  
		LEFT OUTER JOIN ClaimNormDefinition CND ON VC.CmpId = CND.CmpId and CND.ClmGrpId = @Pi_ClaimGrpId WHERE VC.CmpId = @Pi_CmpId  
		AND VC.VatDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND VC.RefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId) AND SelectMode=1)
  END  
  ELSE IF @Pi_ClaimGrpId = 14 --Purchase Shortage Claim
  BEGIN  
         INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT PSC.PurShortRefNo AS 'Reference' , 0 AS 'Select', PSC.Amount AS 'Total Spent Amount' ,ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount' , 0 'Recommended Amount' , 0 'Received Amount' ,0 AS 'Db/Cr Note Selection', 'Cancelled' AS 'Status','' AS Remarks 
		FROM  (SELECT PurShortRefNo,ClaimDate,CmpId,RecClaimAmt Amount FROM PurShortageClaim WITH  (NOLOCK) WHERE Status = 1) PSC  
		LEFT OUTER JOIN ClaimNormDefinition CND ON PSC.CmpId = CND.CmpId AND CND.ClmGrpId = @Pi_ClaimGrpId WHERE PSC.CmpId = @Pi_CmpId  
		AND PSC.ClaimDate BETWEEN @Pi_FromDate AND @Pi_ToDate and PSC.PurShortRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId) AND SelectMode=1)
  END
  ELSE IF @Pi_ClaimGrpId = 15 --Purchase Excess Quantity Refusal Claim
  BEGIN  
         INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
		SELECT PEC.RefNo AS 'Reference' , 0 AS 'Select', PEC.Amount AS 'Total Spent Amount' ,  ISNULL(CND.Claimable,0) AS '% Claimable',
		0.00 AS 'Claimable Amount' , 0 'Recommended Amount',0 'Received Amount' ,0 AS 'Db/Cr Note Selection','Cancelled' AS 'Status','' AS Remarks 
		FROM (SELECT RefNo,Date,CmpId,TotRecAmt Amount FROM PurchaseExcessClaimMaster WITH (NOLOCK) WHERE Status = 1) PEC  
		LEFT OUTER JOIN ClaimNormDefinition CND ON PEC.CmpId = CND.CmpId and CND.ClmGrpId = @Pi_ClaimGrpId WHERE PEC.CmpId = @Pi_CmpId  
		AND PEC.Date BETWEEN @Pi_FromDate AND @Pi_ToDate AND PEC.RefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId) AND SelectMode=1)
  END    				
  ELSE IF @Pi_ClaimGrpId = 16 --Manual Claim
  BEGIN
        INSERT INTO @RetrunClaimDetails ([Reference],[Select],[Total Spent Amount],[% Claimable],[Claimable Amount],[Recommended Amount],
        [Received Amount],[Db/Cr Note Selection],[Status],[Remarks])
        
        SELECT DISTINCT MC.MacRefNo AS 'Reference' , 0 AS 'Select',SUM(MCD.ClaimAmt) AS 'Total Spent Amount' ,ISNULL(CND.Claimable,0) AS '% Claimable',
        0.00 AS 'Claimable Amount' ,0 'Recommended Amount', 0 'Received Amount' , 0 AS 'Db/Cr Note Selection','Cancelled' AS 'Status',MCD.Description -- MC.Remarks Was Changed For CR- CCRSTCK0015
        FROM  (SELECT MacRefNo,0 AS ClaimAmt,CmpId,MacDate,Remarks FROM ManualClaimMaster WITH (NOLOCK)  WHERE Status = 1) MC  
        INNER JOIN ManualClaimDetails MCD WITH (NOLOCK) ON MCD.MacRefNo =MC.MacRefNo 
		LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON MC.CmpId = CND.CmpId AND  CND.ClmGrpId = @Pi_ClaimGrpId WHERE MC.CmpId = @Pi_CmpId  
		AND MC.MacDate BETWEEN @Pi_FromDate AND @Pi_ToDate and MC.MacRefNo NOT IN (SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
		WHERE ClmId IN (SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = @Pi_ClaimGrpId)AND SelectMode=1)
		GROUP BY MC.MacRefNo,CND.Claimable,MCD.Description
  END
RETURN
END
--Till Here Product Version Claim Changes
GO
--Amul Changes
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_RptSalesReturn')
DROP PROCEDURE Proc_RptSalesReturn
GO
----EXEC Proc_RptSalesReturn 9,2,0,'CoreStockyTempReport',0,0,1
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
SET NOCOUNT ON
BEGIN
/*****************************************************************************************************
* PROCEDURE: Proc_RptSalesReturn
* PURPOSE	: Sales Return Report
* NOTES:
* CREATED	: Boopathy.P			30-07-2007
* DATE			AUTHOR				DESCRIPTION
----------------------------------------------------------------------------------------------------
* 01.03.2010	Panneerselvam.k		Added InvoiceType and ProductFilter
* 29.04.2010	G.Md Bahurudeen		Added the Grand Total in Excel Reports
******************************************************************************************************/
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
DECLARE @InvType	AS 	INT
DECLARE @PrdId 		AS 	INT
DECLARE @PrdCatId 	AS 	INT
DECLARE @EXLFlag    AS  INT
--Till Here
--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @RMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @SMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @SalesRtn = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,32,@Pi_UsrId))
---Till Here
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
SET @TblFields = '  [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No],
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
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN
	INSERT INTO #RptSalesReturn ([SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No],
				[Product Code],[Product Description],[Stock Type],[Quantity (Base Qty)],SeqId,
				[Gross Amount],FieldDesc,LineBaseQtyAmt,[Net Amount],[UsrId])
	SELECT [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
	       [Bill No],[Product Code],[Product Description],
	       [Stock Type],[Quantity (Base Qty)],SeqId,
	       [Gross Amount],FieldDesc,LineBaseQtyAmt,[Net Amount],CAST(@Pi_UsrId as INT)
	FROM view_SalesReturn a, ReturnHeader b (Nolock)
	WHERE 
		A.ReturnID = B.ReturnID
		AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
			  A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						
		AND (A.RMId=(CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
				A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							
		AND (A.SMId=(CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
				 A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND (A.CmpId=(CASE @CmpId WHEN 0 THEN A.CmpId ELSE 0 END) OR
				 A.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			
		AND ([SR Date] Between @FromDate and @ToDate)
		AND (A.ReturnId=(CASE @SalesRtn WHEN 0 THEN A.ReturnId ELSE 0 END) OR
				 A.ReturnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,32,@Pi_UsrId)))
		AND A.Status = 0
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
	IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[RptSalesReturn_Excel]') AND type in (N'U'))
	BEGIN
		DROP TABLE [RptSalesReturn_Excel]
	END
	
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		/******************************************************************************************************/
		/*-----  Create Table in Dynamic Cols ---- */
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
		DECLARE @BaseQty BIGINT
		/*-----------------------------------------*/
		
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesReturn_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [dbo].[RptSalesReturn_Excel]
		CREATE TABLE [RptSalesReturn_Excel](
			[SRNNumber] [nvarchar](100) NULL,
			[SRDate] [datetime]			NULL,
			[SMName] [nvarchar](100)	NULL,
			[RMName] [nvarchar](100)	NULL,
			[RtrName] [nvarchar](100)	NULL,
			[BillNo] [nvarchar](100)	NULL,
			[PrdCode] [nvarchar](100)	NULL,
			[PrdName] [nvarchar](500)	NULL,
			[StockType] [nvarchar](100) NULL,
			[Qty] [bigint] NULL,
			[UsrId] [int] NULL
		) ON [PRIMARY]
	
		DELETE FROM RptExcelHeaders WHERE Rptid = 9 AND SlNo > 11
		SET @iCnt = 12
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
		
	/*-------------------------*/
		DELETE FROM RptSalesReturn_Excel
		INSERT INTO RptSalesReturn_Excel (SRNNumber,SRDate,SMName,RMName,RtrName,BillNo,PrdCode,
										  PrdName,StockType,Qty,UsrId)
		SELECT DISTINCT A.[SRN Number],A.[SR Date],[Salesman],[Route Name],A.[Retialer Name],
						A.[Bill No], A.[Product Code],A.[Product Description],A.[Stock Type],
						A.[Quantity (Base Qty)],@Pi_UsrId
		FROM #RptSalesReturn A LEFT OUTER JOIN View_ProdUOMDetails B ON a.[Product Code]=b.PrdCcode
		GROUP BY A.[SRN Number],A.[SR Date],A.[Salesman],A.[Route Name],A.[Retialer Name],A.[Bill No],
				 A.[Product Code],A.[Product Description],A.[Stock Type],A.[Quantity (Base Qty)]
		DECLARE Values_Cur CURSOR FOR
			SELECT DISTINCT  [SRN Number],[SR Date],[Product Code],[Bill No],[Stock Type], 
							 FieldDesc,LineBaseQtyAmt,[Quantity (Base Qty)] 
			FROM #RptSalesReturn
			
			
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @SrnNo,@SRNDate,@PrdCode,@BillNo,@StkType,@Desc,@VALUES,@BaseQty
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSalesReturn_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE SRNNumber='''+ CAST(@SrnNo AS VARCHAR(1000)) + ''' AND SRDate=''' + CAST(@SRNDate AS VARCHAR(1000)) + '''
					AND PrdCode=''' + CAST(@PrdCode AS VARCHAR(1000))+''' AND  BillNo=''' + CAST(@BillNo As VARCHAR(1000)) + ''' AND StockType='''+ CAST(@StkType AS VARCHAR(100))+ ''' AND Qty=' + CAST(@BaseQty  AS VARCHAR(10))+ ' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @SrnNo,@SRNDate,@PrdCode,@BillNo,@StkType,@Desc,@VALUES,@BaseQty
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
		--Add the Grand Total in Excel Reports--		
--		SET @sSql='INSERT INTO RptSalesReturn_Excel (UsrId,StockType,[Gross Amount],[Sch Disc],[Tax Amt],[Net Amount])
--					SELECT 9999,''Total'',sum([Gross Amount]),sum([Sch Disc]),sum([Tax Amt]),sum([Net Amount]) FROM RptSalesReturn_Excel'
--		PRINT @sSql
--		EXEC (@sSql)
		--Till here--
		IF EXISTS (SELECT * FROM RptExcelHeaders WHERE RptId=9  AND DisplayName IN ('DB Disc','CD Disc'))
		BEGIN 
			UPDATE RptExcelHeaders SET DisplayFlag=0  WHERE RptId=9  AND DisplayName IN ('DB Disc','CD Disc')
		END 
			
		DECLARE @RecCount AS BIGINT 
		SET @RecCount =(SELECT count(*) FROM #RptSalesReturn)
		IF @RecCount > 0
		BEGIN
            DECLARE @SsqlStr as Varchar(4000)
			SET @SsqlStr=''
			SELECT @SsqlStr=@SsqlStr+'SUM(['+Name+']),' FROM dbo.sysColumns where id = object_id(N'[RptSalesReturn_Excel]') and Name NOT IN(
			Select TOP 11 Name FROM dbo.sysColumns where id = object_id(N'[RptSalesReturn_Excel]') ORDER BY ColID)
			SELECT @SsqlStr =substring( @SsqlStr,1,len(@SsqlStr)-1)    
            PRINT @SsqlStr
			
			DECLARE @SsqlFieldStr as Varchar(4000)
            SET @SsqlFieldStr=''
            SELECT @SsqlFieldStr=@SsqlFieldStr+'['+Name+'],' FROM dbo.sysColumns where id = object_id(N'[RptSalesReturn_Excel]') and Name NOT IN(
			Select TOP 11 Name FROM dbo.sysColumns where id = object_id(N'[RptSalesReturn_Excel]') ORDER BY ColID)
            SELECT @SsqlFieldStr =substring( @SsqlFieldStr,1,len(@SsqlFieldStr)-1)
            PRINT @SsqlFieldStr
			
              IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='FTMRptRptSalesReturn_Excel')
				BEGIN 
					DROP TABLE FTMRptRptSalesReturn_Excel
					SELECT * INTO FTMRptRptSalesReturn_Excel FROM RptSalesReturn_Excel WHERE 1=2
				END 
			 ELSE
				BEGIN 
					SELECT * INTO FTMRptRptSalesReturn_Excel FROM RptSalesReturn_Excel WHERE 1=2
				END 
            SET @sSql='INSERT INTO FTMRptRptSalesReturn_Excel (UsrId,StockType,' + @SsqlFieldStr + ')
				SELECT 999999,''Total'',' + @SsqlStr + ' FROM RptSalesReturn_Excel'
            PRINT @sSql
            EXEC (@sSql)
			SET @sSql='INSERT INTO RptSalesReturn_Excel (UsrId,StockType,' + @SsqlFieldStr + ')
				SELECT 999999,''Total'',' + @SsqlFieldStr + ' FROM FTMRptRptSalesReturn_Excel'
            PRINT @sSql
            EXEC (@sSql)
            --UPDATE RptRtrWiseBillWiseVatReport_Excel SET InvDate='' WHERE RtrId=999999
		END
	
	END
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnProductUDC')
DROP FUNCTION Fn_ReturnProductUDC
GO
--SELECT Dbo.Fn_ReturnProductUDC(1) AS UDCEXISTS
CREATE FUNCTION Fn_ReturnProductUDC (@Pi_PrdId BIGINT)
RETURNs INT
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnProductUDC
* PURPOSE: Returns the Product Rate Edit UDC Details
* NOTES:
* CREATED: Praveenraj B
* MODIFIED
* DATE : 05-Dec-2013
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------*/
	DECLARE @Exists INT
	SET @Exists=0
	IF EXISTS(SELECT * FROM UdcHD H (NOLOCK)
				INNER JOIN UdcMaster M (NOLOCK) ON H.MasterId=M.MasterId
				INNER JOIN UdcDetails C (NOLOCK) ON C.UdcMasterId=M.UdcMasterId AND C.MasterId=H.MasterId AND C.MasterId=M.MasterId
				INNER JOIN Product P (NOLOCK) ON P.PrdId=C.MasterRecordId
				WHERE UPPER(LTRIM(RTRIM(H.MasterName)))='PRODUCT MASTER' AND UPPER(LTRIM(RTRIM(M.ColumnName)))='RATE EDIT [Y/N]'
				AND UPPER(LTRIM(RTRIM(C.ColumnValue)))='YES' AND P.PrdId=ISNULL(@Pi_PrdId,0))
	BEGIN
			SET @Exists=1
	END
	ELSE
	BEGIN
			SET @Exists=0
	END
RETURN(@Exists)
END
GO
DELETE FROM CustomCaptions WHERE TransId=104 AND CtrlId=17 AND SubCtrlId=5
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
							DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 104,17,5,'DgManualClaim-104-17-5','Remarks*','','',1,1,1,GETDATE(),1,GETDATE(),'Remarks*','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=21 AND CtrlId=1000 AND SubCtrlId=14
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
							DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 21,1000,14,'MsgBox-21-1000-14','','','Please close the pending records and proceed',1,1,1,GETDATE(),1,GETDATE(),'','',
'Please close the pending records and proceed',1,1
GO
IF NOT EXISTS (SELECT NAME FROM SysObjects WHERE Xtype='U' AND name='TempSalvageProduct')
BEGIN
CREATE TABLE TempSalvageProduct
(
	Prdid		INT,
	Prdbatid	INT
)
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnClaimValidation')
DROP FUNCTION Fn_ReturnClaimValidation
GO
--SELECT Dbo.Fn_ReturnClaimValidation(1,1,'MANUAL CLAIM') AS ClaimValid
CREATE FUNCTION Fn_ReturnClaimValidation(@Pi_ClmGrpId INT,@Pi_ClmCode VARCHAR(10),@Pi_ClmGrpName VARCHAR(100))
RETURNS INTEGER
AS
BEGIN
		DECLARE @Exists AS INT
		SET @Exists=0
		IF UPPER(LTRIM(RTRIM(@Pi_ClmGrpName)))='MANUAL CLAIM'
		BEGIN
			SET @Exists=1
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Pi_ClmGrpName)))='SALVAGE CLAIM'
		BEGIN
			SET @Exists=1
		END
		ELSE
		BEGIN
			SET @Exists=0
		END
RETURN(@Exists)
END
GO
DELETE FROM CustomCaptions Where TransId=16 AND CtrlId=1000 AND SubCtrlId=53
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 16,1000,53,'Msgbox-16-1000-53','','','Claim load option available only SO login',1,1,1,GETDATE(),1,GETDATE(),'','','Claim load option available only SO login',1,1
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE XTYPE='U' AND name='Hotsearchleneditor')
BEGIN
CREATE TABLE [dbo].[Hotsearchleneditor](
	[FormId] [int] NULL,
	[FormName] [varchar](50) NULL,
	[FrmWidth] [int] NULL,
	[FrameWidth] [int] NULL
)
END
GO
DELETE FROM Hotsearchleneditor WHERE FormId IN (1,2)
INSERT INTO Hotsearchleneditor (FormId,FormName,FrmWidth,FrameWidth)
SELECT 1,'Billing',7515,7425 UNION
SELECT 2,'Purchase Receipt',7515,7425
GO
IF NOT EXISTS (SELECT * FROM Counters WHERE TabName='ClaimSuperstockistMarginHD' AND FldName='ClmRefNo')
BEGIN
	INSERT INTO Counters (TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT 'ClaimSuperstockistMarginHD','ClmRefNo','CMR',5,1,0,'ClaimSuperstockistMarginHD',1,YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE()
END
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE XTYPE='U' AND name='TempClaimSuperstockistMarginReimbursement')
BEGIN
		CREATE TABLE TempClaimSuperstockistMarginReimbursement
		(
			SalId		BIGINT,
			BillNo		VARCHAR(50),
			PrdId		BIGINT,
			PrdCCode	NVARCHAR(200)	COLLATE DATABASE_DEFAULT,
			PrdName		NVARCHAR(500)	COLLATE DATABASE_DEFAULT,
			Qty			BIGINT,
			GrossAmt	NUMERIC(38,6),
			ClaimPer	INT,
			ClaimAmt	NUMERIC(38,6),
			UsrId		INT
		)
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_TaxNotAppliedProduct')
DROP FUNCTION Fn_TaxNotAppliedProduct
GO
CREATE FUNCTION [dbo].[Fn_TaxNotAppliedProduct](@Salid AS BIGINT)
RETURNS @NonTaxProduct TABLE (Salid BIGINT ,Slno INT)
AS
BEGIN
	INSERT INTO @NonTaxProduct(Salid,Slno)
	SELECT Salid,Slno-1 FROM SalesInvoiceProduct A (Nolock) 
	WHERE 
	NOT EXISTS(SELECT Salid,Prdslno FROM SalesInvoiceProductTax B (Nolock) where A.Salid=B.Salid and A.Slno=B.Prdslno)
	AND SalId=@Salid
	RETURN
END
GO
DELETE FROM MenuDef WHERE SrlNo=184 AND MenuName='mnuClaimReimbursement' AND MenuId='mClm19'
INSERT INTO MenuDef (SrlNo,MenuId,MenuName,ParentId,Caption,MenuStatus,FormName,DefaultCaption)
SELECT 191,'mClm19','mnuClaimReimbursement','mClm','Superstockist  Margin Reimbursement Claim',0,'frmClaimReimpursment','Superstockist  Margin Reimbursement Claim'
GO
DELETE FROM ProfileDt WHERE MenuId='mClm19'
INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT PrfId,'mClm19',0,'New',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION
SELECT PrfId,'mClm19',1,'Edit',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION
SELECT PrfId,'mClm19',2,'Save',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION
SELECT PrfId,'mClm19',3,'Delete',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION
SELECT PrfId,'mClm19',4,'Cancel',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION
SELECT PrfId,'mClm19',5,'Exit',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION
SELECT PrfId,'mClm19',6,'Print',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION
SELECT PrfId,'mClm19',7,'LoadDetails',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
UNION
SELECT PrfId,'mClm19',8,'Save&Confirm',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD
GO
DELETE FROM CustomCaptions WHERE TransId=278
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
							DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 278,1,0,'fxtRefNo','','Press F4/Double Click to Reference Number','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double Click to Reference Number','',1,1
UNION
SELECT 278,2,0,'fxtCompany','','Press F4/Double Click to Select Company','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double Click to Select Company','',1,1
UNION
SELECT 278,3,0,'fxtJcYear','','Press F4/Double Click to Select JCYear','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double Click to Select JCYear','',1,1
UNION
SELECT 278,4,0,'btnOperation','&New','','',1,1,1,GETDATE(),1,GETDATE(),'&New','','',1,1
UNION
SELECT 278,4,1,'btnOperation','&Edit','','',1,1,1,GETDATE(),1,GETDATE(),'&Edit','','',1,1
UNION
SELECT 278,4,2,'btnOperation','&Save','','',1,1,1,GETDATE(),1,GETDATE(),'&Save','','',1,1
UNION
SELECT 278,4,3,'btnOperation','&Delete','','',1,1,1,GETDATE(),1,GETDATE(),'&Delete','','',1,1
UNION
SELECT 278,4,4,'btnOperation','&Cancel','','',1,1,1,GETDATE(),1,GETDATE(),'&Cancel','','',1,1
UNION
SELECT 278,4,5,'btnOperation','E&xit','','',1,1,1,GETDATE(),1,GETDATE(),'E&xit','','',1,1
UNION
SELECT 278,4,6,'btnOperation','&Print','','',1,1,1,GETDATE(),1,GETDATE(),'&Print','','',1,1
UNION
SELECT 278,4,7,'btnOperation','&Load','','',1,1,1,GETDATE(),1,GETDATE(),'&Load','','',1,1
UNION
SELECT 278,4,8,'btnOperation','Save && C&onfirm','','',1,1,1,GETDATE(),1,GETDATE(),'Save && C&onfirm','','',1,1
UNION
SELECT 278,5,1,'CoreHeaderTool','Superstockist  Margin Reimbursement Claim','','',1,1,1,GETDATE(),1,GETDATE(),'Superstockist  Margin Reimbursement Claim','','',1,1
UNION
SELECT 278,5,2,'CoreHeaderTool','Stocky','','',1,1,1,GETDATE(),1,GETDATE(),'Stocky','','',1,1
UNION
SELECT 278,5,1,'CoreHeaderTool','Superstockist  Margin Reimbursement Claim','','',1,1,1,GETDATE(),1,GETDATE(),'Superstockist  Margin Reimbursement Claim','','',1,1
UNION
SELECT 278,5,2,'CoreHeaderTool','Stocky','','',1,1,1,GETDATE(),1,GETDATE(),'Stocky','','',1,1
UNION
SELECT 278,6,0,'lbRefNo','Ref No...','','',1,1,1,GETDATE(),1,GETDATE(),'Ref No...','','',1,1
UNION
SELECT 278,7,0,'lblClaimDate','Date...','','',1,1,1,GETDATE(),1,GETDATE(),'Date...','','',1,1
UNION
SELECT 278,8,0,'lblCmp','Company *...','','',1,1,1,GETDATE(),1,GETDATE(),'Company *...','','',1,1
UNION
SELECT 278,9,0,'lblJCYear','JC Year*...','','',1,1,1,GETDATE(),1,GETDATE(),'JC Year*...','','',1,1
UNION
SELECT 278,10,0,'lblFromDate','From JCMonth*...','','',1,1,1,GETDATE(),1,GETDATE(),'From JCMonth*...','','',1,1
UNION
SELECT 278,11,0,'lblToDate','To JcMonth*...','','',1,1,1,GETDATE(),1,GETDATE(),'To JcMonth*...','','',1,1
UNION
SELECT 278,12,1,'DgMargin-278-12-1','Bill Ref.No','','',1,1,1,GETDATE(),1,GETDATE(),'Bill Ref.No','','',1,1
UNION
SELECT 278,12,2,'DgMargin-278-12-2','Product Code','','',1,1,1,GETDATE(),1,GETDATE(),'Product Code','','',1,1
UNION
SELECT 278,12,3,'DgMargin-278-12-3','Product Name','','',1,1,1,GETDATE(),1,GETDATE(),'Product Name','','',1,1
UNION
SELECT 278,12,4,'DgMargin-278-12-4','Sold Qty','','',1,1,1,GETDATE(),1,GETDATE(),'Sold Qty','','',1,1
UNION
SELECT 278,12,5,'DgMargin-278-12-5','Gross Amount','','',1,1,1,GETDATE(),1,GETDATE(),'Gross Amount','','',1,1
UNION
SELECT 278,12,6,'DgMargin-278-12-6','Claim Percentage','','',1,1,1,GETDATE(),1,GETDATE(),'Claim Percentage','','',1,1
UNION
SELECT 278,12,7,'DgMargin-278-12-7','Claim Amount','','',1,1,1,GETDATE(),1,GETDATE(),'Claim Amount','','',1,1
UNION
SELECT 278,1000,1,'HotSch-278-1000-1','Company Code','','',1,1,1,GETDATE(),1,GETDATE(),'Company Code','','',1,1
UNION
SELECT 278,1000,2,'HotSch-278-1000-2','Company Name','','',1,1,1,GETDATE(),1,GETDATE(),'Company Name','','',1,1
UNION
SELECT 278,1000,3,'HotSch-278-1000-3','Jc Year','','',1,1,1,GETDATE(),1,GETDATE(),'Jc Year','','',1,1
UNION
SELECT 278,1000,4,'HotSch-278-1000-4','From JcMonth','','',1,1,1,GETDATE(),1,GETDATE(),'From JcMonth','','',1,1
UNION
SELECT 278,1000,5,'HotSch-278-1000-5','To JcMonth','','',1,1,1,GETDATE(),1,GETDATE(),'To JcMonth','','',1,1
UNION
SELECT 278,2000,1,'PnlMsg-278-2000-1','','Please clear record(s) and Proceed','',1,1,1,GETDATE(),1,GETDATE(),'','Please clear Grid and Proceed','',1,1
UNION
SELECT 278,2000,2,'PnlMsg-278-2000-2','','Press F4/Double Click to Select Company','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double Click to Select Company','',1,1
UNION
SELECT 278,2000,3,'PnlMsg-278-2000-3','','Press F4/Double Click to Select JCYear','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double Click to Select JCYear','',1,1
UNION
SELECT 278,2000,4,'PnlMsg-278-2000-4','','Press F4/Double Click to Select From JcMonth','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double Click to Select From JcMonth','',1,1
UNION
SELECT 278,2000,5,'MsgBox-278-2000-5','','','Unable to Excute SP Proc_ClaimSuperstockistMarginReimbursement',1,1,1,GETDATE(),1,GETDATE(),'','','Unable to Excute SP Proc_ClaimSuperstockistMarginReimbursement',1,1
UNION
SELECT 278,2000,6,'MsgBox-278-2000-6','','','Do you want clear the Record(s)',1,1,1,GETDATE(),1,GETDATE(),'','','Do you want clear the grid',1,1
UNION
SELECT 278,2000,7,'PnlMsg-278-2000-7','','Press F4/Double Click to Select To JcMonth','',1,1,1,GETDATE(),1,GETDATE(),'','Press F4/Double Click to Select To JcMonth','',1,1
UNION
SELECT 278,2000,8,'PnlMsg-278-2000-8','','No Record To Save','',1,1,1,GETDATE(),1,GETDATE(),'','No Record To Save','',1,1
UNION
SELECT 278,2000,9,'MsgBox-278-2000-9','','','Failed to Lock Record',1,1,1,GETDATE(),1,GETDATE(),'','','Failed to Lock Record',1,1
UNION
SELECT 278,2000,10,'MsgBox-278-2000-10','','','Saved Succesfully With Reference Number ',1,1,1,GETDATE(),1,GETDATE(),'','','Saved Succesfully With Reference Number ',1,1
UNION
SELECT 278,1000,6,'HotSch-278-1000-6','Claim RefNo','','',1,1,1,GETDATE(),1,GETDATE(),'Claim RefNo','','',1,1
UNION
SELECT 278,1000,7,'HotSch-278-1000-7','Claim Date','','',1,1,1,GETDATE(),1,GETDATE(),'Claim Date','','',1,1
GO
--Amul
DELETE FROM HotSearchEditorHd WHERE FormId=10094 AND FormName='Superstockist  Margin Reimbursement Claim'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10151,'Superstockist  Margin Reimbursement Claim','Company','Select','SELECT CmpId,CmpCode,CmpName   FROM Company WHERE CmpId <> 0'
GO
DELETE FROM HotSearchEditorDT WHERE FormId=10094 AND TransId=278
INSERT INTO HotSearchEditorDT
SELECT 1,10151,'Company','Company Code','CmpCode',1500,0,'HotSch-278-1000-1',278
UNION
SELECT 2,10151,'Company','Company Name','CmpName',3000,0,'HotSch-278-1000-2',278
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10095 AND FormName='Superstockist  Margin Reimbursement Claim'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10152,'Superstockist  Margin Reimbursement Claim','JcYear','Select','SELECT JcmId,JcmYr FROM JcMast'
GO
DELETE FROM HotSearchEditorDT WHERE FormId=10095 AND TransId=278
INSERT INTO HotSearchEditorDT
SELECT 1,10152,'JcYear','Jc Year','JcmYr',1500,0,'HotSch-278-1000-3',278
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10096 AND FormName='Superstockist  Margin Reimbursement Claim'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10153,'Superstockist  Margin Reimbursement Claim','From JcMonth','Select','SELECT JcmJc,JcmSdt FROM JcMonth WHERE JcmId=vFParam'
GO
DELETE FROM HotSearchEditorDT WHERE FormId=10096 AND TransId=278
INSERT INTO HotSearchEditorDT
SELECT 1,10153,'From JcMonth','From JcMonth','JcmSdt',2000,0,'HotSch-278-1000-4',278
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10092 AND FormName='Superstockist  Margin Reimbursement Claim'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10149,'Superstockist  Margin Reimbursement Claim','To JcMonth','Select','SELECT JcmJc,JcmEdt FROM JcMonth WHERE JcmId=vFParam AND MONTH(JcmEdt)>=MONTH(''vSParam'')'
GO
DELETE FROM HotSearchEditorDT WHERE FormId=10092 AND TransId=278
INSERT INTO HotSearchEditorDT
SELECT 1,10149,'To JcMonth','To JcMonth','JcmEdt',1500,0,'HotSch-278-1000-5',278
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10093 AND FormName='Superstockist  Margin Reimbursement Claim'
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10150,'Superstockist  Margin Reimbursement Claim','ClmRefNo','Select',
'SELECT ClmRefNo,CONVERT(VARCHAR(10),ClmDate,103) ClmDate FROM ClaimSuperstockistMarginHD'
GO
DELETE FROM HotSearchEditorDT WHERE FormId=10093 AND FieldName='ClmRefNo'
INSERT INTO HotSearchEditorDT (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10150,'ClmRefNo','ClaimRefNo','ClmRefNo',1500,0,'HotSch-278-1000-6',278
UNION
SELECT 2,10150,'ClmRefNo','ClaimDate','ClmDate',1500,0,'HotSch-278-1000-7',278
--Till Here Amul
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND NAME='ClaimSuperstockistMarginHD')
BEGIN
	CREATE TABLE ClaimSuperstockistMarginHD
	(
		ClmRefNo			VARCHAR(20),
		ClmDate				DATETIME,
		CmpId				INT,
		JCYear				INT,
		FromMonth			DATETIME,
		ToMonth				DATETIME,
		TotalClaimAmt		NUMERIC(38,2),
		[Status]			TINYINT,
		Upload				TINYINT,
		Availability		TINYINT,
		LastModBy			INT,
		LastModDate			DATETIME ,
		AuthId				INT,
		AuthDate			DATETIME,
		CONSTRAINT PK_ClaimSuperstockistMarginHD_ClmRefNo PRIMARY KEY CLUSTERED
		(ClmRefNo ASC)		
	)
END
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND NAME='ClaimSuperstockistMarginDT')
BEGIN
	CREATE TABLE ClaimSuperstockistMarginDT
	(
		ClmRefNo			VARCHAR(20),
		SalId				BIGINT,
		BillNo				NVARCHAR(50),
		PrdId				INT,
		PrdCCode			VARCHAR(20),
		PrdName				VARCHAR(100),
		Qty					BIGINT,
		GrossAmt			NUMERIC(38,6),
		ClmPerc				INT,
		ClaimAmt			NUMERIC(38,6),
		Availability		TINYINT,
		LastModBy			INT,
		LastModDate			DATETIME ,
		AuthId				INT,
		AuthDate			DATETIME,
	
	CONSTRAINT FK_ClaimSuperstockistMarginDT_ClmRefNo FOREIGN KEY(ClmRefNo)
	REFERENCES ClaimSuperstockistMarginHD (ClmRefNo),
	
	--CONSTRAINT FK_ClaimSuperstockistMarginDT_SalId FOREIGN KEY(SalId)
	--REFERENCES SalesInvoice (SalId),
	
	--CONSTRAINT FK_ClaimSuperstockistMarginDT_BillNo FOREIGN KEY(BillNo)
	--REFERENCES SalesInvoice (SalInvNo),
	
	CONSTRAINT FK_ClaimSuperstockistMarginDT_PrdId FOREIGN KEY(PrdId)
	REFERENCES Product (PrdId),
	
	
	CONSTRAINT [ClmPerc<=100] CHECK  (([ClmPerc]<=100))
	)
END
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE XTYPE='U' AND name='TempClaimSuperstockistMarginReimbursement')
BEGIN
		CREATE TABLE TempClaimSuperstockistMarginReimbursement
		(
			SalId		BIGINT,
			BillNo		VARCHAR(50),
			PrdId		BIGINT,
			PrdCCode	NVARCHAR(200)	COLLATE DATABASE_DEFAULT,
			PrdName		NVARCHAR(500)	COLLATE DATABASE_DEFAULT,
			Qty			BIGINT,
			GrossAmt	NUMERIC(38,6),
			ClaimPer	INT,
			ClaimAmt	NUMERIC(38,6),
			UsrId		INT
		)
END
GO
IF NOT EXISTS (SELECT B.name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.xtype='U' AND A.name='ClaimSuperstockistMarginDT' AND B.name='ClmId')
BEGIN
		ALTER TABLE ClaimSuperstockistMarginDT ADD ClmId INT DEFAULT 0 WITH VALUES 
END
GO
IF NOT EXISTS (SELECT * FROM COAMaster WHERE AcName='Superstockist Margin Reimbursement Claim')
BEGIN
	INSERT INTO COAMaster (CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT CurrValue+1,(SELECT AcCode+1 FROM COAMaster WHERE CoaId=(SELECT MAX(A.CoaId) FROM COAMaster A Where A.MainGroup=4 and A.AcCode LIKE '421%')),
	'Superstockist Margin Reimbursement Claim',4,4,0,1,1,GETDATE(),1,GETDATE()
	FROM Counters WHERE TabName ='CoaMaster' AND FldName='CoaId' 
	UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName ='CoaMaster' AND FldName='CoaId' 
END
GO
IF NOT EXISTS (SELECT * FROM ClaimGroupMaster WHERE ClmGrpName='Superstockist Margin Reimbursement Claim')
BEGIN
	INSERT INTO ClaimGroupMaster (ClmGrpId,CmpId,ClmGrpCode,ClmGrpName,AutoClaim,CoaId,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT 10003,0,'CG10003','Superstockist Margin Reimbursement Claim',0,
	(SELECT ISNULL(CoaId,0) FROM COAMaster WHERE AcName='Superstockist Margin Reimbursement Claim'),1,1,GETDATE(),1,GETDATE(),0

	
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('FN','TF') AND name='Fn_ReturnSuperStockistMargin')
DROP FUNCTION Fn_ReturnSuperStockistMargin
GO
--SELECT * FROM Fn_ReturnSuperStockistMargin (20, 1, '2013-12-01', '2013-12-31', 0, 1, 16, 0)
CREATE FUNCTION Fn_ReturnSuperStockistMargin (@Pi_ClmGrpId INT,@Pi_CmpId INT,@Pi_FromDate DATETIME,@Pi_ToDate DATETIME,@Pi_ClmId INT,
											  @Pi_UsrId INT,@Pi_TransId INT,@Pi_SettlementType INT)
RETURNS @ReturnSuperStockistMargin TABLE
		(
			Reference				VARCHAR(50),
			[Select]				TINYINT,
			[Total Spent Amount]	NUMERIC(38,2),
			[% Claimable]			NUMERIC(18,2),
			[Claimable Amount]		NUMERIC(38,2),
			[Recommended Amount]	NUMERIC(38,2),
			[Received Amount]		NUMERIC(38,2),
			[Db/Cr Note Selection]	INT,
			[Status]				VARCHAR(50),
			Remarks					VARCHAR(50)
		)
AS
BEGIN
		IF @Pi_ClmGrpId=10003
		BEGIN
			INSERT INTO @ReturnSuperStockistMargin (Reference,
			[Select],		
			[Total Spent Amount],
			[% Claimable],
			[Claimable Amount],
			[Recommended Amount],
			[Received Amount],
			[Db/Cr Note Selection],
			[Status],
			Remarks)
			SELECT DD.ClmRefNo as 'Reference' , 
			0 as 'Select', DD.TotalClaimAmt as 'Total Spent Amount' ,  
			isNull(DD.Claimable,0) as '% Claimable',0.00 as 'Claimable Amount' ,
			0 'Recommended Amount', 0 'Received Amount' , 0 AS 'Db/Cr Note Selection',
			'Cancelled' as 'Status','' AS Remarks FROM (

			SELECT A.ClmRefNo,B.TotalClmAmt AS TotalClaimAmt,A.CmpId,A.ClmDate,CND.Claimable FROM ClaimSuperstockistMarginHD A (NOLOCK) INNER JOIN (
			SELECT ClmRefNo,ISNULL(SUM(ClaimAmt),0) TotalClmAmt FROM  ClaimSuperstockistMarginDT (NOLOCK) WHERE ISNULL(ClmId,0)=0 GROUP BY ClmRefNo ) B ON A.ClmRefNo=B.ClmRefNo
			LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON A.CmpId = CND.CmpId and  CND.ClmGrpId = ISNULL(@Pi_ClmGrpId,0) WHERE A.CmpId = ISNULL(@Pi_CmpId,0)
			AND A.Status=1 
			and A.ClmDate between CONVERT(VARCHAR(10),@Pi_FromDate,121) and CONVERT(VARCHAR(10),@Pi_ToDate,121) and A.ClmRefNo Not In 
			(SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
			WHERE ClmId in (  SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = ISNULL(@Pi_ClmGrpId,0) )AND SelectMode=1 )) DD
		END
RETURN
END
GO
IF NOT EXISTS (SELECT B.Name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='SalesInvoice' AND B.name='CPBSyncFlag')
BEGIN
	ALTER TABLE SalesInvoice ADD CPBSyncFlag TINYINT DEFAULT 0 WITH VALUES
END
GO
DELETE FROM CustomCaptions WHERE TransId=2 AND CtrlId=1000 AND SubCtrlId=272
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 2,1000,272,'Msgbox-2-1000-272','','','Sync not done for the day. Please do sync process for scheme to get applied, do you want to continue ',1,1,1,
GETDATE(),1,GETDATE(),'','','Sync not done for the day. Please do sync process for scheme to get applied, do you want to continue ',1,1
GO
IF NOT EXISTS (SELECT B.Name FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='SchemeMaster' AND B.name='CPB')
BEGIN
		ALTER TABLE SchemeMaster ADD CPB TINYINT DEFAULT 0 WITH VALUES
END
GO
DELETE FROM CustomCaptions WHERE TransId=278 AND CtrlId=2000 AND SubCtrlId=6 
INSERT INTO CustomCaptions  (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 278,2000,6,'MsgBox-278-2000-6','','','Do you want Reload the Record(s)',1,1,1,GETDATE(),1,GETDATE(),'','','Do you want Reload the Record(s)',1,1
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND NAME='Proc_Cs2Cn_Claim_SuperStockistMargin')
DROP PROCEDURE Proc_Cs2Cn_Claim_SuperStockistMargin
GO
--SELECT *  FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Salvage
CREATE PROCEDURE Proc_Cs2Cn_Claim_SuperStockistMargin
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

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Super Stockist Margin Claim'

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
		UploadFlag,
		BillNo
	)
		SELECT
			@DistCode,
			CmpName,
			'Super Stockist Margin Claim',
			DATENAME(MM,CS.ClmDate),
			DATEPART(YYYY,CS.ClmDate),
			CD.RefCode,
			CS.ClmDate,
			CS.FromDate,
			CS.ToDate,
			SD.ClaimAmt,
			SD.ClaimAmt,
			CD.ClmPercentage,
			CD.ClmAmount,
			CD.RecommendedAmount,
			'',
			'',
			0,
			P.PrdCCode,
			'',
			SD.Qty,
			0,
			0,
			SD.ClaimAmt,
			--SD.AmtForClaim,
			ROUND((SD.ClaimAmt/SDC.TotAmtForClaim)*CD.RecommendedAmount,2),
			CS.ClmCode,
			'N',BillNo
		FROM ClaimSuperstockistMarginHD SM
			INNER JOIN ClaimSuperstockistMarginDT SD  WITH (NOLOCK) ON SD.ClmRefNo=SM.ClmRefNo
			INNER JOIN (SELECT ClmRefNo,SUM(ClaimAmt) AS TotAmtForClaim FROM ClaimSuperstockistMarginDT GROUP BY ClmRefNo
			HAVING SUM(ClaimAmt)<>0) SDC ON SD.ClmRefNo=SDC.ClmRefNo
			INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=SD.PrdID
			INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON SD.ClmRefNo=CD.RefCode
			INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 10003
			INNER JOIN Company C  WITH (NOLOCK) ON CS.CmpId=C.CmpId
			WHERE SM.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CD.SelectMode=1 AND SD.ClaimAmt<>0
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND NAME='Proc_Cs2Cn_ClaimAll')
DROP PROCEDURE Proc_Cs2Cn_ClaimAll
GO
/*
BEGIN TRANSACTION
TRUNCATE TABLE Cs2Cn_Prk_ClaimAll
TRUNCATE TABLE Cs2Cn_Prk_Claim_SchemeDetails
EXEC Proc_Cs2Cn_ClaimAll 0,'2014-04-04'
SELECT * FROM Cs2Cn_Prk_ClaimAll
SELECT * FROM Cs2Cn_Prk_Claim_SchemeDetails
SELECT * FROM ClaimSheetHd
ROLLBACK TRANSACTION	
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_ClaimAll]
(
	@Po_ErrNo  INT OUTPUT,
	@ServerDate DATETIME
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_ClaimAll
* PURPOSE	: Extract Claim sheet details from CoreStocky to Console-->Nivea
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 13/11/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag='Y'
	SET @Po_ErrNo  =0
	EXEC Proc_Cs2Cn_Claim_RateDiffernece
	EXEC Proc_Cs2Cn_Claim_Scheme
	EXEC Proc_Cs2Cn_Claim_Manual
	EXEC Proc_Cs2Cn_Claim_BatchTransfer
	EXEC Proc_Cs2Cn_Claim_DeliveryBoy
	EXEC Proc_Cs2Cn_Claim_PurchaseExcess
	EXEC Proc_Cs2Cn_Claim_PurchaseShortage
	EXEC Proc_Cs2Cn_Claim_ResellDamage
	EXEC Proc_Cs2Cn_Claim_ReturnToCompany
	EXEC Proc_Cs2Cn_Claim_Salesman
	EXEC Proc_Cs2Cn_Claim_SalesmanIncentive
	EXEC Proc_Cs2Cn_Claim_Salvage
	EXEC Proc_Cs2Cn_Claim_SpecialDiscount
	EXEC Proc_Cs2Cn_Claim_Transporter
	EXEC Proc_Cs2Cn_Claim_VanSubsidy
	EXEC Proc_Cs2Cn_Claim_Vat	
	EXEC Proc_Cs2Cn_Claim_StockJournal
	EXEC Proc_Cs2Cn_Claim_RateChange
	EXEC Proc_Cs2Cn_Claim_ModernTrade
	EXEC Proc_Cs2Cn_Claim_SuperStockistMargin
	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH,ClaimSheetDetail CD
	WHERE CH.ClmId=CD.ClmId AND CD.RefCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll) 
	AND CH.Confirm=1 AND Status=1
	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH
	WHERE CH.ClmCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll WHERE ClaimType='Scheme Claim') 
	AND CH.Confirm=1
	
	UPDATE Cs2Cn_Prk_ClaimAll SET BillDate = CONVERT(NVARCHAR(10),GETDATE(),121) WHERE BillDate IS NULL
	UPDATE Cs2Cn_Prk_ClaimAll SET Date2 = CONVERT(NVARCHAR(10),GETDATE(),121) WHERE Date2 IS NULL
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(NVARCHAR(10),GETDATE(),121),
	ProcDate = CONVERT(NVARCHAR(10),GETDATE(),121)
	Where ProcId = 12
	
	UPDATE Cs2Cn_Prk_ClaimAll SET ServerDate=@ServerDate
	
	RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnSuperStockistMargin')
DROP FUNCTION Fn_ReturnSuperStockistMargin
GO
--SELECT * FROM Fn_ReturnSuperStockistMargin (20, 1, '2013-12-01', '2013-12-31', 0, 1, 16, 0)
CREATE FUNCTION [dbo].[Fn_ReturnSuperStockistMargin] (@Pi_ClmGrpId INT,@Pi_CmpId INT,@Pi_FromDate DATETIME,@Pi_ToDate DATETIME,@Pi_ClmId INT,
											  @Pi_UsrId INT,@Pi_TransId INT,@Pi_SettlementType INT)
RETURNS @ReturnSuperStockistMargin TABLE
		(
			Reference				VARCHAR(50),
			[Select]				TINYINT,
			[Total Spent Amount]	NUMERIC(38,2),
			[% Claimable]			NUMERIC(18,2),
			[Claimable Amount]		NUMERIC(38,2),
			[Recommended Amount]	NUMERIC(38,2),
			[Received Amount]		NUMERIC(38,2),
			[Db/Cr Note Selection]	INT,
			[Status]				VARCHAR(50),
			Remarks					VARCHAR(50)
		)
AS
BEGIN
		IF @Pi_ClmGrpId=10003
		BEGIN
			INSERT INTO @ReturnSuperStockistMargin (Reference,
			[Select],		
			[Total Spent Amount],
			[% Claimable],
			[Claimable Amount],
			[Recommended Amount],
			[Received Amount],
			[Db/Cr Note Selection],
			[Status],
			Remarks)
			SELECT DD.ClmRefNo as 'Reference' , 
			0 as 'Select', DD.TotalClaimAmt as 'Total Spent Amount' ,  
			isNull(DD.Claimable,0) as '% Claimable',0.00 as 'Claimable Amount' ,
			0 'Recommended Amount', 0 'Received Amount' , 0 AS 'Db/Cr Note Selection',
			'Cancelled' as 'Status','' AS Remarks FROM (
			SELECT A.ClmRefNo,B.TotalClmAmt AS TotalClaimAmt,A.CmpId,A.ClmDate,CND.Claimable FROM ClaimSuperstockistMarginHD A (NOLOCK) INNER JOIN (
			SELECT ClmRefNo,ISNULL(SUM(ClaimAmt),0) TotalClmAmt FROM  ClaimSuperstockistMarginDT (NOLOCK) WHERE ISNULL(ClmId,0)=0 GROUP BY ClmRefNo HAVING ISNULL(SUM(ClaimAmt),0)<>0  ) B ON A.ClmRefNo=B.ClmRefNo
			LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON A.CmpId = CND.CmpId and  CND.ClmGrpId = ISNULL(@Pi_ClmGrpId,0) WHERE A.CmpId = ISNULL(@Pi_CmpId,0)
			AND A.Status=1 
			and A.ClmDate between CONVERT(VARCHAR(10),@Pi_FromDate,121) and CONVERT(VARCHAR(10),@Pi_ToDate,121) and A.ClmRefNo Not In 
			(SELECT RefCode FROM ClaimSheetDetail WITH (NOLOCK) 
			WHERE ClmId in (  SELECT ClmId FROM ClaimSheethd WITH (NOLOCK) WHERE ClmGrpId  = ISNULL(@Pi_ClmGrpId,0) )AND SelectMode=1 )) DD
		END
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE='P' AND name='Proc_ClaimSuperstockistMarginReimbursement')
DROP PROCEDURE Proc_ClaimSuperstockistMarginReimbursement
GO
CREATE PROCEDURE [dbo].[Proc_ClaimSuperstockistMarginReimbursement]
(
	@Pi_CmpId		AS INT,
	@Pi_JcYr		AS INT,
	@Pi_FromJcMth	AS DATETIME,
	@Pi_ToJcMth		AS DATETIME,
	@Pi_UsrId		AS INT,
	@Pi_RefNo		AS VARCHAR(50)
)
AS
/*********************************
* PROCEDURE	:	Proc_ClaimSuperstockistMarginReimbursement
* PURPOSE	:	To Generate SuperstockistMarginReimbursement Claim
* CREATED	:	Praveenraj B ON 11-Dec-2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
		DELETE A FROM TempClaimSuperstockistMarginReimbursement A (NOLOCK) WHERE UsrId=ISNULL(@Pi_UsrId,0)
		CREATE TABLE #TempClaimSuperstockistMarginReimbursement
		(
			SalId		BIGINT,
			BillNo		VARCHAR(50),
			PrdId		BIGINT,
			PrdCCode	NVARCHAR(200)	COLLATE DATABASE_DEFAULT,
			PrdName		NVARCHAR(500)	COLLATE DATABASE_DEFAULT,
			Qty			BIGINT,
			GrossAmt	NUMERIC(38,6),
			ClaimPer	INT,
			ClaimAmt	NUMERIC(38,6)
		)
		DECLARE @BilledPrdDt AS TABLE
		(
			SalId		BIGINT,
			BillNo		VARCHAR(50),
			PrdId		BIGINT,
			PrdBatId	BIGINT,
			PriceId		BIGINT,
			Qty			BIGINT,
			GrossAmt	NUMERIC(38,6)
		)
		DECLARE @PrdWiseClaimPer AS TABLE
		(
			PrdId		BIGINT,
			PrdCCode	NVARCHAR(200)	COLLATE DATABASE_DEFAULT,
			PrdName		NVARCHAR(500)	COLLATE DATABASE_DEFAULT,
			PrdBatId	BIGINT,
			PriceId		BIGINT,
			ClmPerc		INT
		)
		INSERT INTO @BilledPrdDt (SalId,BillNo,PrdId,PrdBatId,PriceId,Qty,GrossAmt)
		SELECT SalId,SalInvNo,PrdId,PrdBatId,PriceId,ISNULL(SUM(BaseQty),0) AS BaseQty,ISNULL(SUM(PrdGrossAmount),0) AS PrdGrossAmount FROM (		
		SELECT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.PrdBatId,SIP.PriceId,SUM(SIP.BaseQty) AS BaseQty,SUM(SIP.PrdGrossAmount) AS PrdGrossAmount FROM SalesInvoice SI (NOLOCK)
		INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SI.SalId=SIP.SalId
		WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@Pi_FromJcMth,121) AND CONVERT(VARCHAR(10),@Pi_ToJcMth,121) AND SI.DlvSts>3 --AND YEAR(SI.SalInvDate)=@Pi_JcYr
		GROUP BY SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.PrdBatId,SIP.PriceId
		UNION
		SELECT RP.ReturnID SalId,RH.ReturnCode AS SalInvNo,RP.PrdId,RP.PrdBatId,RP.PriceId,-1*SUM(RP.BaseQty) AS BaseQty,-1*SUM(RP.PrdGrossAmt) AS PrdGrossAmount FROM ReturnHeader RH 
		INNER JOIN ReturnProduct RP ON RH.ReturnID=RP.ReturnID
		INNER JOIN SalesInvoice SI ON SI.SalId=RP.SalId
		WHERE RH.ReturnDate BETWEEN CONVERT(VARCHAR(10),@Pi_FromJcMth,121) AND CONVERT(VARCHAR(10),@Pi_ToJcMth,121) AND RH.Status=0 --AND YEAR(RH.ReturnDate)=@Pi_JcYr
		GROUP BY RP.ReturnID,RH.ReturnCode,RP.PrdId,RP.PrdBatId,RP.PriceId
		) X	GROUP BY SalId,SalInvNo,PrdId,PrdBatId,PriceId
		
		INSERT INTO @PrdWiseClaimPer(PrdId,PrdCCode,PrdName,PrdBatId,PriceId,ClmPerc)
		SELECT DISTINCT P.PrdId,P.PrdCCode,P.PrdName,PB.PrdBatId,PBD.PriceId,PBD.PrdBatDetailValue AS ClmPerc FROM Product P
		INNER JOIN ProductBatch PB ON P.PrdId=PB.PrdId
		INNER JOIN ProductBatchDetails PBD ON PBD.PrdBatId=PB.PrdBatId
		INNER JOIN BatchCreation BC ON BC.SlNo=PBD.SlNo AND PB.BatchSeqId=BC.BatchSeqId AND BC.SlNo=5
		
		INSERT INTO #TempClaimSuperstockistMarginReimbursement(SalId,BillNo,PrdId,PrdCCode,PrdName,Qty,GrossAmt,ClaimPer,ClaimAmt)
		SELECT SalId,BillNo,PrdId,PrdCCode,PrdName,Qty,GrossAmt,ClaimPer,ISNULL(SUM(ClaimAmt),0) ClaimAmt FROM (
		SELECT DT.SalId,DT.BillNo,DT.PrdId,DT.PrdBatId,CLM.PrdCCode,CLM.PrdName,DT.Qty,DT.GrossAmt,ClM.ClmPerc AS ClaimPer
		,ISNULL((DT.GrossAmt*ClM.ClmPerc)/100,0) AS ClaimAmt
		FROM @BilledPrdDt DT LEFT JOIN @PrdWiseClaimPer CLM ON DT.PrdId=CLM.PrdId
		AND DT.PrdBatId=CLM.PrdBatId AND DT.PriceId=CLM.PriceId
		) Y GROUP BY SalId,BillNo,PrdId,PrdCCode,PrdName,Qty,GrossAmt,ClaimPer
		
		--SELECT  DISTINCT CAST(SalId AS VARCHAR(20))+'~'+CAST(PrdId AS VARCHAR(20)) FROM ClaimSuperstockistMarginDT B WHERE ClmRefNo<>@Pi_RefNo 
		
		--SELECT 	SalId,BillNo,PrdId,PrdCCode,PrdName,Qty,GrossAmt,ClaimPer,ClaimAmt,@Pi_UsrId AS UsrId FROM #TempClaimSuperstockistMarginReimbursement A (NOLOCK)
		--	WHERE NOT EXISTS (SELECT  DISTINCT CAST(SalId AS VARCHAR(20))+'~'+CAST(PrdId AS VARCHAR(20)) FROM ClaimSuperstockistMarginDT B WHERE ClmRefNo<>@Pi_RefNo 
		--	AND CAST(B.SalId AS VARCHAR(20))+'~'+CAST(B.PrdId AS VARCHAR(20))=CAST(A.SalId AS VARCHAR(20))+'~'+CAST(A.PrdId AS VARCHAR(20)))
			
		--IF ISNULL(@Pi_RefNo,'')<>''
		--BEGIN
			INSERT INTO TempClaimSuperstockistMarginReimbursement(SalId,BillNo,PrdId,PrdCCode,PrdName,Qty,GrossAmt,ClaimPer,ClaimAmt,UsrId)
			SELECT 	SalId,BillNo,PrdId,PrdCCode,PrdName,Qty,GrossAmt,ClaimPer,ClaimAmt,@Pi_UsrId AS UsrId FROM #TempClaimSuperstockistMarginReimbursement A (NOLOCK)
			WHERE NOT EXISTS (SELECT  DISTINCT CAST(BillNo AS VARCHAR(20))+'~'+CAST(PrdId AS VARCHAR(20)) FROM ClaimSuperstockistMarginDT B WHERE ClmRefNo<>@Pi_RefNo 
			AND CAST(B.BillNo AS VARCHAR(20))+'~'+CAST(B.PrdId AS VARCHAR(20))=CAST(A.BillNo AS VARCHAR(20))+'~'+CAST(A.PrdId AS VARCHAR(20)))
			ORDER BY GrossAmt DESC
		--END
		--ELSE
		--BEGIN
		--	INSERT INTO TempClaimSuperstockistMarginReimbursement(SalId,BillNo,PrdId,PrdCCode,PrdName,Qty,GrossAmt,ClaimPer,ClaimAmt,UsrId)
		--	SELECT 	SalId,BillNo,PrdId,PrdCCode,PrdName,Qty,GrossAmt,ClaimPer,ClaimAmt,@Pi_UsrId AS UsrId FROM #TempClaimSuperstockistMarginReimbursement A (NOLOCK)
		--	WHERE NOT EXISTS (SELECT  DISTINCT CAST(SalId AS VARCHAR(20))+'~'+CAST(PrdId AS VARCHAR(20)) FROM ClaimSuperstockistMarginDT B WHERE 
		--	CAST(B.SalId AS VARCHAR(20))+'~'+CAST(B.PrdId AS VARCHAR(20))=CAST(A.SalId AS VARCHAR(20))+'~'+CAST(A.PrdId AS VARCHAR(20)))
		--END
END
GO
DELETE FROM Configuration WHERE ModuleId IN ('DAYENDPROCESS7','DAYENDPROCESS8','DAYMONTHEND1','DAYMONTHEND2')
INSERT INTO Configuration
SELECT 'DAYMONTHEND1','Month End Process','Enable Day and Month End Process',0,'',0.00,1 UNION
SELECT 'DAYMONTHEND2','Month End Process','Restrict transactions on distributor off day',0,'',0.00,2
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('FN','TF') AND name='Fn_ReturnRetailerApproval')
DROP FUNCTION Fn_ReturnRetailerApproval
GO
--SELECT * FROM Fn_ReturnRetailerApproval(1) AS Approval
CREATE FUNCTION Fn_ReturnRetailerApproval (@Pi_RtrId INT)
RETURNS @RtrCRDt TABLE (RtrId INT,RtrCrDays INT,RtrCrDaysAlert INT,Approval INT)
AS
/*********************************
* FUNCTION	: Fn_ReturnRetailerApproval
* PURPOSE	: To return Retailer credit days details
* CREATED	: Praveenraj B
* CREATED DATE	: 10-01-2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
	IF ISNULL(@Pi_RtrId,0)>0
	BEGIN
		IF EXISTS (SELECT * FROM Retailer (NOLOCK) WHERE RtrId=@Pi_RtrId)
		BEGIN
			INSERT INTO @RtrCRDt(RtrId,RtrCrDays,RtrCrDaysAlert,Approval)
			SELECT RtrId,RtrCrDays,RtrCrDaysAlert,Approved FROM Retailer (NOLOCK) WHERE RtrId=@Pi_RtrId
		END
	END
RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype IN ('TF','FN') AND name='Fn_ReturnDlvConfigStatus')
DROP FUNCTION Fn_ReturnDlvConfigStatus
GO
--SELECT DBO.Fn_ReturnDlvConfigStatus () Holiday
CREATE FUNCTION Fn_ReturnDlvConfigStatus ()
RETURNS INT
AS
/*********************************
* FUNCTION		: Fn_ReturnDlvConfigStatus
* PURPOSE		: To Return Pending Delivery Days For Auto Delivery Process
* CREATED		: Praveenraj B 
* CREATED DATE	: 10/01/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
		DECLARE @PendingDays INT
		DECLARE @Count AS INT
		SELECT @PendingDays=ISNULL(Condition,0) FROM Configuration WHERE ModuleName='Day End Process' AND ModuleId='DAYENDPROCESS4' AND Status=1
		DECLARE @WKENDDAY AS VARCHAR(10)
		DECLARE @FROMDATE AS DATETIME
		DECLARE @TODATE AS DATETIME
		SELECT @TODATE=CONVERT(VARCHAR(10),GETDATE(),121)
		SELECT @FROMDATE=MAX(SALINVDATE) FROM SalesInvoice WHERE DlvSts>3

		SELECT @WKENDDAY=UPPER(CASE WkEndDay WHEN 1 THEN 'Sunday'    
              WHEN 2 THEN 'Monday'    
              WHEN 3 THEN 'Tuesday'    
              WHEN 4 THEN 'Wednesday'    
              WHEN 5 THEN 'Thursday'    
              WHEN 6 THEN 'Friday'    
              WHEN 7 THEN 'Saturday' END) FROM JCMast WHERE JcmYr=YEAR(GETDATE())
		SET @Count=0	

		IF EXISTS (
		SELECT day_name,1 + DATEDIFF(wk, @FROMDATE, @TODATE) -CASE WHEN DATEPART(weekday, @FROMDATE) > day_number THEN 1 ELSE 0 END - 
		CASE WHEN DATEPART(weekday, @TODATE)   < day_number THEN 1 ELSE 0 END AS DDD FROM (
		SELECT 1 AS day_number, 'Monday' AS day_name UNION ALL
		SELECT 2 AS day_number, 'Tuesday' AS day_name UNION ALL
		SELECT 3 AS day_number, 'Wednesday' AS day_name UNION ALL
		SELECT 4 AS day_number, 'Thursday' AS day_name UNION ALL
		SELECT 5 AS day_number, 'Friday' AS day_name UNION ALL
		SELECT 6 AS day_number, 'Saturday' AS day_name UNION ALL
		SELECT 7 AS day_number, 'Sunday' AS day_name ) A WHERE UPPER(day_name)=UPPER(@WKENDDAY)
		AND (1 + DATEDIFF(wk, @FROMDATE, @TODATE) -CASE WHEN DATEPART(weekday, @FROMDATE) > day_number THEN 1 ELSE 0 END - 
		CASE WHEN DATEPART(weekday, @TODATE)   < day_number THEN 1 ELSE 0 END)>=1 )
		BEGIN
					SELECT @Count=1 + DATEDIFF(wk, @FROMDATE, @TODATE) -CASE WHEN DATEPART(weekday, @FROMDATE) > day_number THEN 1 ELSE 0 END - 
					CASE WHEN DATEPART(weekday, @TODATE)   < day_number THEN 1 ELSE 0 END  FROM (
					SELECT 1 AS day_number, 'Monday' AS day_name UNION ALL
					SELECT 2 AS day_number, 'Tuesday' AS day_name UNION ALL
					SELECT 3 AS day_number, 'Wednesday' AS day_name UNION ALL
					SELECT 4 AS day_number, 'Thursday' AS day_name UNION ALL
					SELECT 5 AS day_number, 'Friday' AS day_name UNION ALL
					SELECT 6 AS day_number, 'Saturday' AS day_name UNION ALL
					SELECT 7 AS day_number, 'Sunday' AS day_name ) A WHERE UPPER(day_name)=UPPER(@WKENDDAY)
					AND (1 + DATEDIFF(wk, @FROMDATE, @TODATE) -CASE WHEN DATEPART(weekday, @FROMDATE) > day_number THEN 1 ELSE 0 END - 
					CASE WHEN DATEPART(weekday, @TODATE)   < day_number THEN 1 ELSE 0 END)>=1
		END
	RETURN(@Count)
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnColFromDate')
DROP FUNCTION Fn_ReturnColFromDate
GO
--SELECT Dbo.Fn_ReturnColFromDate() CollFromDate
CREATE FUNCTION [dbo].[Fn_ReturnColFromDate]()
RETURNS DATETIME
AS
/*********************************
* PROCEDURE		: Fn_ReturnColFromDate
* PURPOSE		: To Return Collection Date
* CREATED		: Praveenraj B
* CREATED DATE	: 2014-01-08
* NOTE			: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
	DECLARE @COLFROMDATE DATETIME
	DECLARE @YEAR AS INT
	SELECT @YEAR=M.ACMYR FROM ACMASTER M 
	LEFT OUTER JOIN ACPERIOD P ON M.AcmId = P.AcmId 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN P.AcmSdt AND P.AcmEdt
	
	IF EXISTS (SELECT TOP 1 B.AcmSdt FROM ACMaster A INNER JOIN ACPeriod B ON A.AcmId=B.AcmId WHERE A.AcmYr=@YEAR)
	BEGIN
		SELECT TOP 1 @COLFROMDATE=B.AcmSdt FROM ACMaster A INNER JOIN ACPeriod B ON A.AcmId=B.AcmId WHERE A.AcmYr=@YEAR
	END
	ELSE
	BEGIN
		SET @COLFROMDATE=GETDATE()
	END
	SET @COLFROMDATE=CONVERT(VARCHAR(10),@COLFROMDATE,121)
	RETURN(@COLFROMDATE)
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_ProductWiseSalesOnly')
DROP PROCEDURE Proc_ProductWiseSalesOnly
GO
--EXEC Proc_ProductWiseSalesOnly 2,2
--SELECT * FROM RptProductWise (NOLOCK)
CREATE PROCEDURE Proc_ProductWiseSalesOnly
(
@Pi_RptId   INT,
@Pi_UsrId   INT
)
/************************************************************
* PROC			: Proc_ProductWiseSalesOnly
* PURPOSE		: To get the Product details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 18/02/2010
* NOTE			:
* MODIFIED		:
* DATE        AUTHOR   DESCRIPTION
14-09-2009   Mahalakshmi.A     BugFixing for BugNo : 20625
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 18/11/2013	Jisha Mathew	Bug No : 29578
*************************************************************/
AS
BEGIN
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate   AS DATETIME
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	DELETE FROM RptProductWise WHERE RptId= @Pi_RptId And UsrId IN(0,@Pi_UsrId)
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		SIP.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SIP.SalManFreeQty AS FreeQty,0 AS RepQty,0 AS ReturnQty,
		SIP.BaseQty AS SalesQty,SIP.PrdGrossAmount,SIP.PrdTaxAmount,0 AS ReturnGrossValue,DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,PrdNetAmount,((P.PrdWgt*SIP.BaseQty)/1000),((P.PrdWgt*SIP.SalManFreeQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceProduct SIP WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SIP.SalId=SI.SalId AND P.PrdId=SIP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SIP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId  AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.FreeQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts---@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.FreeQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SSF.SalId=SI.SalId  AND P.PrdId=SSF.FreePrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.FreePrdBatId
		AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.GiftQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.GiftQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SSF.SalId=SI.SalId AND P.PrdId=SSF.GiftPrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.GiftPrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementOut REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo <>'RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		0 AS RepQty,REO.RtnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,REO.RtnAmount AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,0,((P.PrdWgt*REO.RtnQty)/1000)
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementIn REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,REO.RepAmount AS SalesGrossValue,REO.Tax AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID ,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementOut REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Return Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		0 AS FreeQty,0 AS RepQty,RP.BaseQty AS ReturnQty,
		0 AS SalesQty,-1 * (RP.PrdGrossAmt) AS SalesGrossValue,0 AS TaxAmount,RP.PrdGrossAmt,SI.DlvSts--@
		,@Pi_RptId AS RptId,@Pi_UsrId AS UsrId,-1*PrdNetAmt,0,0,0,((P.PrdWgt*RP.BaseQty)/1000)
		FROM SalesInvoice SI WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK),
		ReturnHeader RH WITH (NOLOCK),
		ReturnProduct RP WITH (NOLOCK)
		WHERE SI.SalId=RH.SalId AND RH.ReturnId=RP.ReturnId AND P.PrdId=RP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=RP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
END
--Till Here Amul Changes
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND name = 'MonthEndClosingStockSnapShot')
DROP TABLE MonthEndClosingStockSnapShot
GO
CREATE TABLE MonthEndClosingStockSnapShot(
	[StkMonth] [nvarchar](50) NULL,
	[StkYear] [int] NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdBatchCode] [nvarchar](100) NULL,
	[MRP] [numeric](36, 6) NULL,
	[CLP] [numeric](36, 6) NULL,
	[OpeningSales] [numeric](36, 0) NULL,
	[OpeningUnSaleable] [numeric](36, 0) NULL,
	[OpenignOffer] [numeric](36, 0) NULL,
	[PurchaseSales] [numeric](36, 0) NULL,
	[PurchaseUnSaleable] [numeric](36, 0) NULL,
	[PurchaseOffer] [numeric](36, 0) NULL,
	[InvoiceSales] [numeric](36, 0) NULL,
	[InvoiceUnSaleable] [numeric](36, 0) NULL,
	[InvoiceOffer] [numeric](36, 0) NULL,
	[SalPurReturn] [numeric](18, 0) NULL,
	[UnsalPurReturn] [numeric](18, 0) NULL,
	[OfferPurReturn] [numeric](18, 0) NULL,
	[SalStockIn] [numeric](18, 0) NULL,
	[UnSalStockIn] [numeric](18, 0) NULL,
	[OfferStockIn] [numeric](18, 0) NULL,
	[SalStockOut] [numeric](18, 0) NULL,
	[UnSalStockOut] [numeric](18, 0) NULL,
	[OfferStockOut] [numeric](18, 0) NULL,
	[DamageIn] [numeric](18, 0) NULL,
	[DamageOut] [numeric](18, 0) NULL,
	[SalSalesReturn] [numeric](18, 0) NULL,
	[UnSalSalesReturn] [numeric](18, 0) NULL,
	[OfferSalesReturn] [numeric](18, 0) NULL,
	[SalStkJurIn] [numeric](18, 0) NULL,
	[UnSalStkJurIn] [numeric](18, 0) NULL,
	[OfferStkJurIn] [numeric](18, 0) NULL,
	[SalStkJurOut] [numeric](18, 0) NULL,
	[UnSalStkJurOut] [numeric](18, 0) NULL,
	[OfferStkJurOut] [numeric](18, 0) NULL,
	[SalBatTfrIn] [numeric](18, 0) NULL,
	[UnSalBatTfrIn] [numeric](18, 0) NULL,
	[OfferBatTfrIn] [numeric](18, 0) NULL,
	[SalBatTfrOut] [numeric](18, 0) NULL,
	[UnSalBatTfrOut] [numeric](18, 0) NULL,
	[OfferBatTfrOut] [numeric](18, 0) NULL,
	[SalLcnTfrIn] [numeric](18, 0) NULL,
	[UnSalLcnTfrIn] [numeric](18, 0) NULL,
	[OfferLcnTfrIn] [numeric](18, 0) NULL,
	[SalLcnTfrOut] [numeric](18, 0) NULL,
	[UnSalLcnTfrOut] [numeric](18, 0) NULL,
	[OfferLcnTfrOut] [numeric](18, 0) NULL,
	[SalReplacement] [numeric](18, 0) NULL,
	[OfferReplacement] [numeric](18, 0) NULL,
	[ClosingSales] [numeric](36, 0) NULL,
	[ClosingUnSaleable] [numeric](36, 0) NULL,
	[ClosingOffer] [numeric](36, 0) NULL,
	[SecondarySales] [numeric](36, 6) NULL,
	[LastInvoiceNumber] [varchar](50) NULL,
	[LastInvoiceDate] [datetime] NULL,
	[StockInTrans] [numeric](36, 0) NULL,
	[UploadFlag] [varchar](1) NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND name = 'CS2CN_Prk_CurrentStockSnapshot')
DROP TABLE CS2CN_Prk_CurrentStockSnapshot
GO
CREATE TABLE CS2CN_Prk_CurrentStockSnapshot(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[StkYear] [nvarchar](50) NULL,
	[StkMonth] [nvarchar](50) NULL,
	[PrdCode] [nvarchar](200) NULL,
	[PrdName] [nvarchar](500) NULL,
	[BatchCode] [nvarchar](200) NULL,
	[LcnName] [nvarchar](200) NULL,
	[MRP] [numeric](18, 2) NULL,
	[ListPrice] [numeric](18, 2) NULL,
	[SalClsStock] [numeric](18, 0) NULL,
	[UnSalClsStock] [numeric](18, 0) NULL,
	[OfferClsStock] [numeric](18, 0) NULL,
	[UploadFlag] [nvarchar](2) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND name = 'CS2CN_Prk_MonthEndClosingStock')
DROP TABLE CS2CN_Prk_MonthEndClosingStock
GO
CREATE TABLE CS2CN_Prk_MonthEndClosingStock (
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) NULL,
	[StkMonth] [nvarchar](50) NULL,
	[StkYear] [int] NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdBatchCode] [nvarchar](100) NULL,
	[MRP] [numeric](36, 6) NULL,
	[CLP] [numeric](36, 6) NULL,
	[OpeningSales] [numeric](36, 0) NULL,
	[OpeningUnSaleable] [numeric](36, 0) NULL,
	[OpenignOffer] [numeric](36, 0) NULL,
	[PurchaseSales] [numeric](36, 0) NULL,
	[PurchaseUnSaleable] [numeric](36, 0) NULL,
	[PurchaseOffer] [numeric](36, 0) NULL,
	[InvoiceSales] [numeric](36, 0) NULL,
	[InvoiceUnSaleable] [numeric](36, 0) NULL,
	[InvoiceOffer] [numeric](36, 0) NULL,
	[SalPurReturn] [numeric](18, 0) NULL,
	[UnsalPurReturn] [numeric](18, 0) NULL,
	[OfferPurReturn] [numeric](18, 0) NULL,
	[SalStockIn] [numeric](18, 0) NULL,
	[UnSalStockIn] [numeric](18, 0) NULL,
	[OfferStockIn] [numeric](18, 0) NULL,
	[SalStockOut] [numeric](18, 0) NULL,
	[UnSalStockOut] [numeric](18, 0) NULL,
	[OfferStockOut] [numeric](18, 0) NULL,
	[DamageIn] [numeric](18, 0) NULL,
	[DamageOut] [numeric](18, 0) NULL,
	[SalSalesReturn] [numeric](18, 0) NULL,
	[UnSalSalesReturn] [numeric](18, 0) NULL,
	[OfferSalesReturn] [numeric](18, 0) NULL,
	[SalStkJurIn] [numeric](18, 0) NULL,
	[UnSalStkJurIn] [numeric](18, 0) NULL,
	[OfferStkJurIn] [numeric](18, 0) NULL,
	[SalStkJurOut] [numeric](18, 0) NULL,
	[UnSalStkJurOut] [numeric](18, 0) NULL,
	[OfferStkJurOut] [numeric](18, 0) NULL,
	[SalBatTfrIn] [numeric](18, 0) NULL,
	[UnSalBatTfrIn] [numeric](18, 0) NULL,
	[OfferBatTfrIn] [numeric](18, 0) NULL,
	[SalBatTfrOut] [numeric](18, 0) NULL,
	[UnSalBatTfrOut] [numeric](18, 0) NULL,
	[OfferBatTfrOut] [numeric](18, 0) NULL,
	[SalLcnTfrIn] [numeric](18, 0) NULL,
	[UnSalLcnTfrIn] [numeric](18, 0) NULL,
	[OfferLcnTfrIn] [numeric](18, 0) NULL,
	[SalLcnTfrOut] [numeric](18, 0) NULL,
	[UnSalLcnTfrOut] [numeric](18, 0) NULL,
	[OfferLcnTfrOut] [numeric](18, 0) NULL,
	[SalReplacement] [numeric](18, 0) NULL,
	[OfferReplacement] [numeric](18, 0) NULL,
	[ClosingSales] [numeric](36, 0) NULL,
	[ClosingUnSaleable] [numeric](36, 0) NULL,
	[ClosingOffer] [numeric](36, 0) NULL,
	[SecondarySales] [numeric](36, 6) NULL,
	[LastInvoiceNumber] [varchar](50) NULL,
	[LastInvoiceDate] [datetime] NULL,
	[StockInTrans] [numeric](36, 0) NULL,
	[UploadFlag] [nvarchar](1) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND name = 'Proc_CS2CN_CurrentStockSnapShot')
DROP PROCEDURE Proc_CS2CN_CurrentStockSnapShot
GO
/*
BEGIN TRANSACTION
EXEC Proc_CS2CN_CurrentStockSnapShot 0
SELECT * FROM CS2CN_Prk_CurrentStockSnapshot
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CS2CN_CurrentStockSnapShot
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
SET NOCOUNT ON  
BEGIN  
/********************************************************************* 
* PROCEDURE : Proc_CS2CN_CurrentStockSnapShot  
* PURPOSE : Extract Current Stock Details from CoreStocky to Console  
* NOTES  :  
* CREATED : Sathishkumar Veeramani 12-06-2013  
* MODIFIED  
* DATE			AUTHOR				DESCRIPTION  
**********************************************************************/
 SET @Po_ErrNo = 0  
 DECLARE @CmpID   AS INTEGER  
 DECLARE @SyncId AS NUMERIC(18,0)
 DECLARE @ServerDate AS DATETIME
 DECLARE @DistCode AS NVARCHAR(50)
 DELETE FROM CS2CN_Prk_CurrentStockSnapshot WHERE UploadFlag = 'Y'  
 SELECT @DistCode = DistributorCode FROM Distributor 
 
	IF EXISTS(SELECT StkMonth,StkYear FROM MonthEndClosing WHERE UploadFlag='N')	
	BEGIN
		SELECT DISTINCT P.Prdid,X.PrdbatId,PriceId,Prdccode,PrdName,CmpBatCode,ISNULL(SUM(MRP),0) as MRP ,
		ISNULL(SUM(ListPrice),0) as ListPrice
		INTO #ProductBatchMaster
		FROM(
			SELECT P.Prdid,P.PrdbatId ,CmpBatCode,PriceId,PrdBatDetailValue as MRP,0 as ListPrice
			FROM Productbatch P INNER JOIN Batchcreation B ON P.BatchSeqId=B.BatchSeqId
			INNER JOIN ProductBatchDetails PBD ON PBD.PrdBatId=P.PrdBatId
			and PBD.SLNo=B.SlNo WHERE DefaultPrice=1 and MRP=1
			UNION ALL
			SELECT P.Prdid,P.PrdbatId ,CmpBatCode,PriceId,0 as MRP,PrdBatDetailValue as ListPrice
			FROM Productbatch P INNER JOIN Batchcreation B ON P.BatchSeqId=B.BatchSeqId
			INNER JOIN ProductBatchDetails PBD ON PBD.PrdBatId=P.PrdBatId
			and PBD.SLNo=B.SlNo WHERE DefaultPrice=1 and ListPrice=1		
		) X
		INNER JOIN Product P ON X.PrdId=P.PrdId
		GROUP BY P.Prdid,X.PrdbatId,X.PriceId,Prdccode,CmpBatCode ,PrdName
 	
		
		 INSERT INTO CS2CN_Prk_CurrentStockSnapshot  
		  (  
			DistCode,
			StkYear,
			StkMonth,					
			PrdCode,
			PrdName,
			BatchCode,
			LcnName,
			MRP,
			ListPrice,
			SalClsStock,
			UnSalClsStock,
			OfferClsStock,						
			UploadFlag
		
		  )  
		  SELECT @DistCode,StkYear,StkMonth,D.PrdCCode,D.PrdName,D.CmpBatCode,
		  LcnName,D.MRP,D.ListPrice,(SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih)) AS SalableStock,(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih)) AS  UnSalableStock,
		  (SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) AS OfferStock,'N' AS UploadFlag
		  FROM ProductBatchLocation B WITH (NOLOCK) 
		  INNER JOIN Location C WITH (NOLOCK) ON B.LcnId = C.LcnId 
		  INNER JOIN #ProductBatchMaster D ON D.PrdId=B.PrdId and D.PrdBatId=B.PrdbatId
		  CROSS JOIN MonthEndClosing M WHERE M.UploadFlag='N'
		  GROUP BY D.PrdCCode,D.PrdName,D.CmpBatCode,LcnName,D.MRP,D.ListPrice,StkYear,StkMonth
		  HAVING (SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih))+(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih))+(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre))> 0
	END	  
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND name = 'Proc_CS2CNMonthEndClosingStock')
DROP PROCEDURE Proc_CS2CNMonthEndClosingStock
GO
--EXEC Proc_CS2CNMonthEndClosingStock 0
CREATE PROCEDURE Proc_CS2CNMonthEndClosingStock
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_CS2CNMonthEndClosingStock
* PURPOSE	: To Get Stock Ledger Detail
* CREATED	: Murugan.R
* CREATED DATE	: 17/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
    SET @Po_ErrNo = 0
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME	
	DECLARE @Pi_ToDate AS DATETIME
	DECLARE @Pi_ToDate1 AS DATETIME
	DECLARE @Pi_FromDate AS DATETIME
	
	
	SELECT @DistCode = DistributorCode FROM Distributor
	DELETE FROM CS2CN_Prk_MonthEndClosingStock WHERE UploadFlag='Y'
	IF EXISTS(SELECT StkMonth,StkYear FROM MonthEndClosing WHERE UploadFlag='N')	
	BEGIN
		EXEC Proc_CS2CN_CurrentStockSnapShot 0
		SELECT @Pi_ToDate1=CONVERT(DATETIME,CONVERT(VARCHAR(10),DBO.Fn_ReturnLastMonthEndDate(Getdate()),121),121)
		
		SET @Pi_ToDate=@Pi_ToDate1
		
		SELECT @Pi_FromDate =DATEADD(mm, DATEDIFF(mm,0,@Pi_ToDate1), 0)

	
	
	CREATE TABLE #CS2CN_Prk_MonthEndClosingStock(
	Transdate Datetime,
	[PrdId] [int] NULL,
	[PrdCode] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
	[PrdName] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
	[PrdBatId] [int] NULL,
	[PrdBatchCode] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
	[MRP] Numeric(36,6),
	[CLP] Numeric (36,6),
	OpeningSales Numeric(36,0),
	OpeningUnSaleable Numeric(36,0),
	OpenignOffer Numeric(36,0),
	PurchaseSales	Numeric(36,0),
	PurchaseUnSaleable Numeric(36,0),
	PurchaseOffer Numeric(36,0),
	InvoiceSales Numeric(36,0),
	InvoiceUnSaleable Numeric(36,0),
	InvoiceOffer Numeric(36,0),
	[SalPurReturn] [numeric](18, 0) NULL,
	[UnsalPurReturn] [numeric](18, 0) NULL,
	[OfferPurReturn] [numeric](18, 0) NULL,
	[SalStockIn] [numeric](18, 0) NULL,
	[UnSalStockIn] [numeric](18, 0) NULL,
	[OfferStockIn] [numeric](18, 0) NULL,
	[SalStockOut] [numeric](18, 0) NULL,
	[UnSalStockOut] [numeric](18, 0) NULL,
	[OfferStockOut] [numeric](18, 0) NULL,
	[DamageIn] [numeric](18, 0) NULL,
	[DamageOut] [numeric](18, 0) NULL,
	[SalSalesReturn] [numeric](18, 0) NULL,
	[UnSalSalesReturn] [numeric](18, 0) NULL,
	[OfferSalesReturn] [numeric](18, 0) NULL,
	[SalStkJurIn] [numeric](18, 0) NULL,
	[UnSalStkJurIn] [numeric](18, 0) NULL,
	[OfferStkJurIn] [numeric](18, 0) NULL,
	[SalStkJurOut] [numeric](18, 0) NULL,
	[UnSalStkJurOut] [numeric](18, 0) NULL,
	[OfferStkJurOut] [numeric](18, 0) NULL,
	[SalBatTfrIn] [numeric](18, 0) NULL,
	[UnSalBatTfrIn] [numeric](18, 0) NULL,
	[OfferBatTfrIn] [numeric](18, 0) NULL,
	[SalBatTfrOut] [numeric](18, 0) NULL,
	[UnSalBatTfrOut] [numeric](18, 0) NULL,
	[OfferBatTfrOut] [numeric](18, 0) NULL,
	[SalLcnTfrIn] [numeric](18, 0) NULL,
	[UnSalLcnTfrIn] [numeric](18, 0) NULL,
	[OfferLcnTfrIn] [numeric](18, 0) NULL,
	[SalLcnTfrOut] [numeric](18, 0) NULL,
	[UnSalLcnTfrOut] [numeric](18, 0) NULL,
	[OfferLcnTfrOut] [numeric](18, 0) NULL,
	[SalReplacement] [numeric](18, 0) NULL,
	[OfferReplacement] [numeric](18, 0) NULL,
	ClosingSales Numeric(36,0),
	ClosingUnSaleable Numeric(36,0),
	ClosingOffer Numeric(36,0),
	SecondarySales  Numeric(36,6),
	LastInvoiceNumber Varchar(50),
	LastInvoiceDate Datetime,
	StockInTrans Numeric(36,0)
	)
	
	SELECT Prdid,Prdbatid,LcnId,Max(Transdate) as TransDate INTO #Stock1 FROM STOCKLEDGER
	WHERE TransDate < @Pi_FromDate
	GROUP BY Prdid,Prdbatid,LcnId

	SELECT Prdid,Prdbatid,LcnId,Max(Transdate) as TransDate INTO #Stock2 FROM STOCKLEDGER
	WHERE TransDate <= @Pi_ToDate
	GROUP BY Prdid,Prdbatid,LcnId


	SELECT Transdate,Prdid,Prdbatid,
	SUM(SalesOpening) as SalesOpening,SUM(UnSaleableOpening) as UnSaleableOpening,SUM(OfferOpening) as OfferOpening,
	SUM(SalPurchase) as SalPurchase,SUM(UnsalPurchase) as UnsalPurchase,SUM(OfferPurchase) as OfferPurchase,
	SUM(SalSales) as SalSales, SUM(UnSalSales) as UnSalSales , SUM(OfferSales) as OfferSales,
	SUM([SalPurReturn]) as [SalPurReturn] ,SUM([UnsalPurReturn]) as [UnsalPurReturn] ,SUM([OfferPurReturn] ) as [OfferPurReturn],
	SUM([SalStockIn] ) as [SalStockIn],SUM([UnSalStockIn] ) as [UnSalStockIn],SUM([OfferStockIn] ) as [OfferStockIn],
	SUM([SalStockOut] ) as [SalStockOut],SUM([UnSalStockOut] ) as [UnSalStockOut],SUM([OfferStockOut] ) as [OfferStockOut],
	SUM([DamageIn] ) as [DamageIn],SUM([DamageOut] ) as [DamageOut],
	SUM([SalSalesReturn] ) as [SalSalesReturn],SUM([UnSalSalesReturn] ) as [UnSalSalesReturn],SUM([OfferSalesReturn] ) as [OfferSalesReturn],
	SUM([SalStkJurIn] ) as [SalStkJurIn],SUM([UnSalStkJurIn] ) as [UnSalStkJurIn],SUM([OfferStkJurIn] ) as [OfferStkJurIn],
	SUM([SalStkJurOut] ) as [SalStkJurOut],SUM([UnSalStkJurOut] ) as [UnSalStkJurOut],SUM([OfferStkJurOut] ) as [OfferStkJurOut],
	SUM([SalBatTfrIn] ) as [SalBatTfrIn],SUM([UnSalBatTfrIn] ) as [UnSalBatTfrIn],SUM([OfferBatTfrIn] ) as [OfferBatTfrIn],
	SUM([SalBatTfrOut] ) as [SalBatTfrOut],SUM([UnSalBatTfrOut] ) as [UnSalBatTfrOut],SUM([OfferBatTfrOut] ) as [OfferBatTfrOut],
	SUM([SalLcnTfrIn] ) as [SalLcnTfrIn],SUM([UnSalLcnTfrIn] ) as [UnSalLcnTfrIn],SUM([OfferLcnTfrIn] ) as [OfferLcnTfrIn],
	SUM([SalLcnTfrOut] ) as [SalLcnTfrOut],SUM([UnSalLcnTfrOut] ) as [UnSalLcnTfrOut],SUM([OfferLcnTfrOut] ) as [OfferLcnTfrOut],
	SUM([SalReplacement] ) as [SalReplacement],SUM([OfferReplacement] ) as [OfferReplacement],
	SUM(SalClsStock) as SalClsStock,SUM(UnSalClsStock) as UnSalClsStock,
	SUM(OfferClsStock) as OfferClsStock,0 as MRP,0 as CLP
	INTO #StockSummary 
	FROM(
		SELECT @Pi_ToDate  as TransDate,
		ST.PrdId,St.Prdbatid,SUM(SalClsStock) as SalesOpening,SUM(UnSalClsStock) as UnSaleableOpening,
		SUM(OfferClsStock) as OfferOpening,0 as SalPurchase,0 as UnsalPurchase,0 as  OfferPurchase,
		0 as SalSales,0 as UnSalSales ,0 as OfferSales,
		0 as [SalPurReturn] ,
		0 as [UnsalPurReturn] ,
		0 as [OfferPurReturn] ,
		0 as [SalStockIn] ,
		0 as [UnSalStockIn] ,
		0 as [OfferStockIn] ,
		0 as [SalStockOut] ,
		0 as [UnSalStockOut] ,
		0 as [OfferStockOut] ,
		0 as [DamageIn] ,
		0 as [DamageOut] ,
		0 as [SalSalesReturn] ,
		0 as [UnSalSalesReturn] ,
		0 as [OfferSalesReturn] ,
		0 as [SalStkJurIn] ,
		0 as [UnSalStkJurIn] ,
		0 as [OfferStkJurIn] ,
		0 as [SalStkJurOut] ,
		0 as [UnSalStkJurOut] ,
		0 as [OfferStkJurOut] ,
		0 as [SalBatTfrIn] ,
		0 as [UnSalBatTfrIn] ,
		0 as [OfferBatTfrIn] ,
		0 as [SalBatTfrOut] ,
		0 as [UnSalBatTfrOut] ,
		0 as [OfferBatTfrOut] ,
		0 as [SalLcnTfrIn] ,
		0 as [UnSalLcnTfrIn] ,
		0 as [OfferLcnTfrIn] ,
		0 as [SalLcnTfrOut] ,
		0 as [UnSalLcnTfrOut] ,
		0 as [OfferLcnTfrOut] ,
		0 as [SalReplacement] ,
		0 as [OfferReplacement] ,		
		0 as SalClsStock,0 as UnSalClsStock,0 as OfferClsStock
		FROM STOCKLEDGER ST
		INNER JOIN #Stock1 X ON X.Prdid=ST.Prdid and X.Prdbatid=ST.Prdbatid
		and X.Lcnid=ST.LcnId and X.Transdate=ST.Transdate		
		GROUP BY ST.PrdId,St.Prdbatid
				
		UNION ALL	
			
		SELECT @Pi_ToDate as TransDate,
		ST.PrdId,ST.Prdbatid,0 as SalesOpening,0 as UnSaleableOpening,0 as OfferOpening,
		0 as SalPurchase,0 as UnsalPurchase,0 as  OfferPurchase,
		0 as SalSales,0 as UnSalSales ,0 as OfferSales,
		0 as [SalPurReturn] ,
		0 as [UnsalPurReturn] ,
		0 as [OfferPurReturn] ,
		0 as [SalStockIn] ,
		0 as [UnSalStockIn] ,
		0 as [OfferStockIn] ,
		0 as [SalStockOut] ,
		0 as [UnSalStockOut] ,
		0 as [OfferStockOut] ,
		0 as [DamageIn] ,
		0 as [DamageOut] ,
		0 as [SalSalesReturn] ,
		0 as [UnSalSalesReturn] ,
		0 as [OfferSalesReturn] ,
		0 as [SalStkJurIn] ,
		0 as [UnSalStkJurIn] ,
		0 as [OfferStkJurIn] ,
		0 as [SalStkJurOut] ,
		0 as [UnSalStkJurOut] ,
		0 as [OfferStkJurOut] ,
		0 as [SalBatTfrIn] ,
		0 as [UnSalBatTfrIn] ,
		0 as [OfferBatTfrIn] ,
		0 as [SalBatTfrOut] ,
		0 as [UnSalBatTfrOut] ,
		0 as [OfferBatTfrOut] ,
		0 as [SalLcnTfrIn] ,
		0 as [UnSalLcnTfrIn] ,
		0 as [OfferLcnTfrIn] ,
		0 as [SalLcnTfrOut] ,
		0 as [UnSalLcnTfrOut] ,
		0 as [OfferLcnTfrOut] ,
		0 as [SalReplacement] ,
		0 as [OfferReplacement] ,
		--0 as Adjustments,
		SUM(SalClsStock) as SalClsStock,SUM(UnSalClsStock) as UnSalClsStock,
		SUM(OfferClsStock) as OfferClsStock 
		FROM STOCKLEDGER ST
		INNER JOIN  #Stock2 X ON X.Prdid=ST.Prdid and X.Prdbatid=ST.Prdbatid
		and X.Lcnid=ST.LcnId and X.Transdate=ST.Transdate
		GROUP BY ST.PrdId,St.Prdbatid
		
		UNION ALL
		
		SELECT @Pi_ToDate as TransDate,Sl.PrdId,Sl.PrdBatId,
		0 as SalesOpening,0 as UnSaleableOpening,0 as OfferOpening,
		SUM(Sl.SalPurchase) as SalPurchase,SUM(Sl.UnsalPurchase) as UnsalPurchase,SUM(Sl.OfferPurchase) as OfferPurchase,
		SUM(Sl.SalSales) as SalSales,SUM(Sl.UnSalSales) as UnSalSales,SUM(Sl.OfferSales) as OfferSales,		
		SUM([SalPurReturn]) ,
		SUM([UnsalPurReturn]) ,
		SUM([OfferPurReturn] ),
		SUM([SalStockIn] ),
		SUM([UnSalStockIn] ),
		SUM([OfferStockIn] ),
		SUM([SalStockOut] ),
		SUM([UnSalStockOut] ),
		SUM([OfferStockOut] ),
		SUM([DamageIn] ),
		SUM([DamageOut] ),
		SUM([SalSalesReturn] ),
		SUM([UnSalSalesReturn] ),
		SUM([OfferSalesReturn] ),
		SUM([SalStkJurIn] ),
		SUM([UnSalStkJurIn] ),
		SUM([OfferStkJurIn] ),
		SUM([SalStkJurOut] ),
		SUM([UnSalStkJurOut] ),
		SUM([OfferStkJurOut] ),
		SUM([SalBatTfrIn] ),
		SUM([UnSalBatTfrIn] ),
		SUM([OfferBatTfrIn] ),
		SUM([SalBatTfrOut] ),
		SUM([UnSalBatTfrOut] ),
		SUM([OfferBatTfrOut] ),
		SUM([SalLcnTfrIn] ),
		SUM([UnSalLcnTfrIn] ),
		SUM([OfferLcnTfrIn] ),
		SUM([SalLcnTfrOut] ),
		SUM([UnSalLcnTfrOut] ),
		SUM([OfferLcnTfrOut] ),
		SUM([SalReplacement] ),
		SUM([OfferReplacement] ),	
		0 as SalClsStock,0 as UnSalClsStock,0 as OfferClsStock
	
		--SUM((-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		--Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		--Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		--Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		--Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		--Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut)) AS Adjustments,
		--0 as SalClsStock,0 as UnSalClsStock,0 as OfferClsStock
		FROM StockLedger Sl WHERE Sl.TransDate BETWEEN @Pi_FromDate AND  @Pi_ToDate	
		GROUP BY Sl.PrdId,Sl.PrdBatId
		)X GROUP BY  Transdate,Prdid,Prdbatid
	
	
			
		DELETE FROM #CS2CN_Prk_MonthEndClosingStock 
	
	--      Stocks for the given date---------
		INSERT INTO #CS2CN_Prk_MonthEndClosingStock
		(Transdate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatchCode,
		MRP,CLP,OpeningSales,OpeningUnSaleable,OpenignOffer,
		PurchaseSales,PurchaseUnSaleable,PurchaseOffer,
		InvoiceSales,InvoiceUnSaleable,InvoiceOffer,
		[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
		[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
		[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
		[DamageIn] ,[DamageOut] ,
		[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
		[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
		[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
		[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
		[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
		[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
		[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
		[SalReplacement] ,[OfferReplacement] ,ClosingSales,ClosingUnSaleable,
		ClosingOffer,SecondarySales,
		LastInvoiceNumber,LastInvoiceDate,StockInTrans)
					
		SELECT Transdate,P.PrdId,PrdcCode,PrdName,pb.PrdBatId,PrdBatCode,
		MRP,CLP,SalesOpening,UnSaleableOpening,OfferOpening,
		SalPurchase,UnsalPurchase,OfferPurchase,
		SalSales,UnSalSales,OfferSales,[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
		[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
		[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
		[DamageIn] ,[DamageOut] ,
		[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
		[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
		[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
		[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
		[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
		[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
		[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
		[SalReplacement] ,[OfferReplacement],
		SalClsStock,UnSalClsStock,OfferClsStock,0 as SecondarySales,'' as LastInvoiceNumber,
		Getdate() as LastInvoiceDate,0 as StockInTrans
		FROM #StockSummary S INNER JOIN Product P ON S.Prdid=P.PrdId
		INNER JOIN ProductBatch PB ON P.PrdId=PB.PrdId and S.PrdBatId=PB.PrdBatId
		
	
	SELECT Prdid,Prdbatid,PriceId,Status,SUM(SelRte) as SelRte,SUM(ListPrice) as ListPrice,SUM(MRP) as MRP
	INTO #Productbatch
	FROM(
		SELECT Prdid,P.Prdbatid,PriceId,Status,PrdBatDetailValue as SelRte,0 as ListPrice,0 as MRP   FROM BatchCreation BC 
		INNER JOIN ProductBatch P  ON BC.BatchSeqId=P.BatchSeqId
		INNER JOIN ProductBatchDetails PB ON P.PrdBatId=PB.PrdBatId and P.DefaultPriceId=PB.PriceId
		and BC.SlNo=pb.SLNo WHERE DefaultPrice=1 and Bc.SelRte=1
		UNION ALL
		SELECT Prdid,P.Prdbatid,PriceId,Status, 0 as SelRte,PrdBatDetailValue as ListPrice,0 as MRP  FROM BatchCreation BC 
		INNER JOIN ProductBatch P  ON BC.BatchSeqId=P.BatchSeqId
		INNER JOIN ProductBatchDetails PB ON P.PrdBatId=PB.PrdBatId and P.DefaultPriceId=PB.PriceId
		and BC.SlNo=pb.SLNo WHERE DefaultPrice=1 and Bc.ListPrice=1
		UNION ALL
		SELECT Prdid,P.Prdbatid,PriceId,Status,0 as SelRte,0 as ListPrice,PrdBatDetailValue as MRP  FROM BatchCreation BC 
		INNER JOIN ProductBatch P  ON BC.BatchSeqId=P.BatchSeqId
		INNER JOIN ProductBatchDetails PB ON P.PrdBatId=PB.PrdBatId and P.DefaultPriceId=PB.PriceId
		and BC.SlNo=pb.SLNo WHERE DefaultPrice=1 and Bc.MRP=1
	) X GROUP BY 	Prdid,Prdbatid,PriceId,Status
	
	Update A Set A.MRP=B.MRP, A.CLP=b.ListPrice,SecondarySales=(InvoiceSales*b.ListPrice)
	FROM #CS2CN_Prk_MonthEndClosingStock A INNER JOIN #Productbatch B
	ON A.PrdId=B.PrdId and A.PrdBatId=B.PrdBatId
	
	
	SELECT Prdid,PrdbatId,SUM(InvBaseQty) as  InvBaseQty INTO #StkTransIn 
	FROM(
		SELECT Prdid,Prdbatid, SUM(InvBaseQty) as InvBaseQty
		FROM PurchaseReceipt P INNER JOIN PurchaseReceiptProduct PR ON P.PurRcptId=PR.PurRcptId
		WHERE InvDate Between @Pi_FromDate AND  @Pi_ToDate and Status=0
		GROUP BY Prdid,Prdbatid
		UNION ALL
		SELECT PR.Prdid,Prdbatid, SUM(InvQty*U.ConversionFactor) as InvBaseQty
		FROM ETLTempPurchaseReceipt P INNER JOIN ETLTempPurchaseReceiptProduct PR ON P.CmpInvNo=PR.CmpInvNo
		INNER JOIN Product Pd ON Pd.PrdId=Pr.Prdid
		INNER JOIN UomGroup U ON U.UomGroupId=Pd.UomGroupId and U.UomId=Pr.InvUOMId
		WHERE InvDate Between @Pi_FromDate AND  @Pi_ToDate and DownLoadStatus=0
		and P.CmpInvNo NOT IN(SELECT CmpInvNo FROM PurchaseReceipt )
		GROUP BY PR.Prdid,Prdbatid
	)X GROUP  BY Prdid,PrdbatId
	
	
	Update CS  SET StockInTrans=InvBaseQty 
	FROM #CS2CN_Prk_MonthEndClosingStock CS INNER JOIN #StkTransIn St ON CS.Prdid=St.PrdId
	and Cs.PrdBatId=St.PrdBatId
	
	
	SELECT P.CmpInvno,P.Invdate INTO #Purchase
	FROM PurchaseReceipt P INNER JOIN ( 
	Select MAX(PurRcptId)  as  PurRcptId 
	FROM  PurchaseReceipt WHERE InvDate Between @Pi_FromDate AND  @Pi_ToDate  and Status=1)X
	ON P.PurRcptId=X.PurRcptId
	
	Update CS set LastInvoiceDate=Invdate,LastInvoiceNumber=CmpInvno
	FROM #Purchase,#CS2CN_Prk_MonthEndClosingStock CS
	
	INSERT INTO CS2CN_Prk_MonthEndClosingStock(DistCode,StkMonth,StkYear,
	PrdCode,PrdName,PrdBatchCode,MRP,CLP,OpeningSales,OpeningUnSaleable,
	OpenignOffer,PurchaseSales,PurchaseUnSaleable,PurchaseOffer,InvoiceSales,
	InvoiceUnSaleable,InvoiceOffer,[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
	[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
	[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
	[DamageIn] ,[DamageOut] ,
	[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
	[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
	[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
	[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
	[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
	[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
	[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
	[SalReplacement] ,[OfferReplacement],ClosingSales,ClosingUnSaleable,
	ClosingOffer,SecondarySales,LastInvoiceNumber,LastInvoiceDate,StockInTrans,UploadFlag)
	SELECT @DistCode as DistCode,StkMonth,StkYear,
	PrdCode,PrdName,PrdBatchCode,MRP,CLP,OpeningSales,OpeningUnSaleable,
	OpenignOffer,PurchaseSales,PurchaseUnSaleable,PurchaseOffer,InvoiceSales,
	InvoiceUnSaleable,InvoiceOffer,[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
	[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
	[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
	[DamageIn] ,[DamageOut] ,
	[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
	[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
	[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
	[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
	[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
	[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
	[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
	[SalReplacement] ,[OfferReplacement],ClosingSales,ClosingUnSaleable,
	ClosingOffer,SecondarySales,LastInvoiceNumber,LastInvoiceDate,StockInTrans,'N' as UploadFlag
	FROM #CS2CN_Prk_MonthEndClosingStock  CROSS JOIN MonthEndClosing  
	WHERE (OpeningSales+OpeningUnSaleable+OpenignOffer+PurchaseSales+PurchaseUnSaleable+PurchaseOffer+InvoiceSales+
			InvoiceUnSaleable+InvoiceOffer+[SalPurReturn]+[UnsalPurReturn]+[OfferPurReturn] +
			[SalStockIn] +[UnSalStockIn] +[OfferStockIn] +
			[SalStockOut] +	[UnSalStockOut]+[OfferStockOut] +
			[DamageIn]+[DamageOut] +
			[SalSalesReturn] +[UnSalSalesReturn] +[OfferSalesReturn]+
			[SalStkJurIn] +	[UnSalStkJurIn] +[OfferStkJurIn]+
			[SalStkJurOut] +[UnSalStkJurOut] +[OfferStkJurOut] +
			[SalBatTfrIn] +	[UnSalBatTfrIn] +[OfferBatTfrIn] +
			[SalBatTfrOut] +[UnSalBatTfrOut] +[OfferBatTfrOut] +
			[SalLcnTfrIn] +	[UnSalLcnTfrIn] +[OfferLcnTfrIn] +
			[SalLcnTfrOut] +[UnSalLcnTfrOut] +[OfferLcnTfrOut] +
		[SalReplacement] +[OfferReplacement]+ClosingSales+ClosingUnSaleable+ClosingOffer+StockInTrans)>0
	AND UploadFlag='N'
		
	UPDATE MonthEndClosing SET UploadFlag='Y'
	
	DELETE A FROM MonthEndClosingStockSnapShot A WHERE EXISTS(SELECT StkMonth,StkYear FROM CS2CN_Prk_MonthEndClosingStock B WHERE A.StkMonth=B.StkMonth and A.StkYear=B.StkYear)
	
	INSERT INTO MonthEndClosingStockSnapShot
	(StkMonth,StkYear,PrdCode,PrdName,
	PrdBatchCode,MRP,CLP,
	OpeningSales,OpeningUnSaleable,OpenignOffer,
	PurchaseSales,PurchaseUnSaleable,PurchaseOffer,
	InvoiceSales,InvoiceUnSaleable,InvoiceOffer,
	[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
	[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
	[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
	[DamageIn] ,[DamageOut] ,
	[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
	[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
	[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
	[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
	[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
	[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
	[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
	[SalReplacement] ,[OfferReplacement],ClosingSales,ClosingUnSaleable,ClosingOffer,
	SecondarySales,LastInvoiceNumber,LastInvoiceDate,StockInTrans,
	UploadFlag,UploadedDate)
	SELECT StkMonth,StkYear,
	PrdCode,PrdName,PrdBatchCode,MRP,CLP,OpeningSales,OpeningUnSaleable,
	OpenignOffer,PurchaseSales,PurchaseUnSaleable,PurchaseOffer,InvoiceSales,
	InvoiceUnSaleable,InvoiceOffer,[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
	[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
	[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
	[DamageIn] ,[DamageOut] ,
	[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
	[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
	[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
	[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
	[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
	[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
	[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
	[SalReplacement] ,[OfferReplacement],ClosingSales,ClosingUnSaleable,
	ClosingOffer,SecondarySales,LastInvoiceNumber,LastInvoiceDate,StockInTrans,
	0 as UploadFlag ,GETDATE() as UploadedDate
	FROM CS2CN_Prk_MonthEndClosingStock WHERE UploadFlag='N'
	
	
	END
END
--Till Here Murugan Sir
GO
--Nivea MonthEnd Process on 2014-02-07 by B.suganya
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'EnableYearEndOpenTrans')
DROP TABLE EnableYearEndOpenTrans
GO
CREATE TABLE EnableYearEndOpenTrans(
	[SlNo] [int] NULL,
	[MenuId] [nvarchar](100) NULL,
	[ScreenName] [nvarchar](100) NULL,
	[TabName] [nvarchar](100) NULL,
	[OpenTrans] [int] NULL
) ON [PRIMARY]
GO
DELETE FROM EnableYearEndOpenTrans
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (1,'mCmp9','Purchase','PurchaseReceipt',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (2,'mCmp11','Purchase Return','PurchaseReturn',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (3,'mCmp12','Return To Company','ReturnToCompany',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (4,'mInv4','Stock Management','StockManagement',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (5,'mInv7','Salvage','Salvage',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (6,'mCus18','Billing','SalesInvoice',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (7,'mCus20','Sales Return','Sales Return',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (8,'mCus23','Resell Damage Goods','ResellDamageMaster',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (22,'mCus29','Point Redemption Product','PntRetSchemeHD',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (23,'mCus34','Coupon Redemption','CouponRedHd',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (24,'mCmp20','SIT Purchase Confirmation','SITPurchaseConfirmation',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (25,'mCmp18','IDT Management','IDTManagement',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (26,'mCus36','Sample Management','SampleManagement',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (27,'mCus36','Sample Management','SampleManagement',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (28,'mCus36','Sample Receipt','SampleReceipt',0)
INSERT INTO EnableYearEndOpenTrans([SlNo],[MenuId],[ScreenName],[TabName],[OpenTrans]) 
VALUES (29,'mInv6','Batch Transfer','BatchTransfer',0)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'YearEndOpenTrans')
DROP TABLE YearEndOpenTrans
GO
CREATE TABLE YearEndOpenTrans(
	[SlNo] [INT] NULL,
	[MenuId] [NVARCHAR](100) NULL,
	[ScreenName] [NVARCHAR](100) NULL,
	[TabName] [NVARCHAR](100) NULL,
	[OpenTrans] [INT] NULL,
	[UsrId]   [INT] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE IN ('TF','FN') AND name = 'Fn_PendingTransactionMenuEnabled')
DROP FUNCTION Fn_PendingTransactionMenuEnabled
GO
--SELECT * FROM Fn_PendingTransactionMenuEnabled (1,1)
CREATE FUNCTION [dbo].[Fn_PendingTransactionMenuEnabled](@Pi_Flag AS INT,@Pi_UsrId AS INT) 
RETURNS @PendingTransactionMenuEnabled TABLE
(
	MenuId NVARCHAR(100),
	MenuName NVARCHAR(100)
)
/****************************************************	
* FUNCTION: Fn_PendingTransactionMenuEnabled
* PURPOSE: Pending Transaction Screens only Enabled
* NOTES:
* CREATED: Sathishkumar Veeramani ON 19-12-2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------

****************************************************/
AS
BEGIN
	IF @Pi_Flag = 1
	BEGIN
		  INSERT INTO @PendingTransactionMenuEnabled(MenuId,MenuName)
		  SELECT DISTINCT MenuId,MenuName FROM Menudef WITH(NOLOCK)  
		  WHERE MenuId NOT IN (SELECT MenuId FROM YearEndOpenTrans WITH(NOLOCK) WHERE OpenTrans>0 AND UsrId = @Pi_UsrId)
		  AND ParentId <> 'AAA' AND MenuId NOT IN ('mRot4','mStk30')
		  IF NOT EXISTS (SELECT MenuId FROM @PendingTransactionMenuEnabled WHERE MenuId = 'mCus18')
		  BEGIN
		      DELETE FROM @PendingTransactionMenuEnabled WHERE MenuId = 'mLog5'
		  END
	END
	IF @Pi_Flag = 2
	BEGIN
		  INSERT INTO @PendingTransactionMenuEnabled(MenuId,MenuName)
		  SELECT DISTINCT A.MenuId,MenuName FROM Menudef A WITH(NOLOCK)INNER JOIN ProfileDt B WITH(NOLOCK)
		  ON A.MenuId = B.MenuId AND B.BtnStatus = 1 AND ParentId <> 'AAA' AND PrfId = @Pi_UsrId
		  AND A.MenuId NOT IN ('mRot4','mStk30') AND A.MenuId NOT IN (SELECT MenuId FROM MenuDefToAvoid WHERE Status=0)
	END         
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_YEGetOpenTrans' AND XTYPE='P')
DROP PROCEDURE Proc_YEGetOpenTrans
GO
--EXEC Proc_YEGetOpenTrans '2008-04-01','2009-03-31'
--SELECT * FROM YearEndOpenTrans
CREATE PROCEDURE Proc_YEGetOpenTrans
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		    DATETIME,
	@Pi_UsrId           INT
)
AS
/*********************************
* PROCEDURE	: Proc_YEGetOpenTrans
* PURPOSE	: To get the Open transactions for Year End
* CREATED	: Nandakumar R.G
* CREATED DATE	: 09/03/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	TRUNCATE TABLE YearEndOpenTrans
	TRUNCATE TABLE YearEndLog
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 1,'mCmp9','Purchase','PurchaseReceipt',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM PurchaseReceipt
	WHERE Status=0 AND GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 1,'Purchase',PurRcptRefNo
	FROM PurchaseReceipt
	WHERE Status=0 AND GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 2,'mCmp11','Purchase Return','PurchaseReturn',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM PurchaseReturn
	WHERE Status=0 AND PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 2,'Purchase Return',PurRetRefNo
	FROM PurchaseReturn
	WHERE Status=0 AND PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 3,'mCmp12','Return To Company','ReturnToCompany',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM ReturnToCompany
	WHERE Status=0 AND RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 3,'Return To Company',RtnCmpRefNo
	FROM ReturnToCompany
	WHERE Status=0 AND RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 4,'mInv4','Stock Management','StockManagement',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM StockManagement
	WHERE Status=0 AND StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 4,'Stock Management',StkMngRefNo
	FROM StockManagement
	WHERE Status=0 AND StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 5,'mInv7','Salvage','Salvage',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM Salvage
	WHERE Status=0 AND SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 5,'Salvage',SalvageRefNo
	FROM Salvage
	WHERE Status=0 AND SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 6,'mCus18','Billing','SalesInvoice',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM SalesInvoice
	WHERE DlvSts NOT IN(5,3,4) AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 6,'Billing',SalInvNo
	FROM SalesInvoice
	WHERE DlvSts NOT IN(5,3,4) AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--->Added By Nanda on 15/03/2011
--	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
--	SELECT 7,'Sales Return','ReturnHeader',ISNULL(COUNT(*),0),0
--	FROM ReturnHeader
--	WHERE Status=1 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
--	SELECT 7,'Sales Return',ReturnCode
--	FROM ReturnHeader
--	WHERE Status=1 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 7,'mCus20','Sales Return','Sales Return',A.Counts+B.Counts,@Pi_UsrId
	FROM 
	(
		SELECT ISNULL(COUNT(*),0) AS Counts 
		FROM ReturnHeader
		WHERE Status=1 AND ReturnType=2 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	) A	,
	(
		SELECT ISNULL(COUNT(*),0) AS Counts 
		FROM ReturnHeader RH,SalesInvoice SI
		WHERE RH.Status=1 AND RH.ReturnType=1 
		AND RH.SalId=SI.SalId AND SI.DlvSts<3
		AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	) B
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 7,'Sales Return',ReturnCode
	FROM ReturnHeader
	WHERE Status=1 AND ReturnType=2 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 7,'Sales Return',ReturnCode
	FROM ReturnHeader RH,SalesInvoice SI
	WHERE RH.Status=1 AND RH.ReturnType=1 AND RH.SalId=SI.SalId AND SI.DlvSts<3
	AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--->Till Here
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 8,'mCus23','Resell Damage Goods','ResellDamageMaster',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM ResellDamageMaster
	WHERE Status=0 AND ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 8,'Resell Damage Goods',ReDamRefNo
	FROM ResellDamageMaster
	WHERE Status=0 AND ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 9,'mClm6','Salesman Salary And DA Claim','SalesmanClaimMaster',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM SalesmanClaimMaster
	WHERE Status=0 AND ScmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 9,'Salesman Salary And DA Claim',ScmRefNo
	FROM SalesmanClaimMaster
	WHERE Status=0 AND ScmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 10,'mClm7','Delivery Boy Salary And DA Claim','DeliveryBoyClaimMaster',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM DeliveryBoyClaimMaster
	WHERE Status=0 AND DbcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 10,'Delivery Boy Salary And DA Claim',DbcRefNo
	FROM DeliveryBoyClaimMaster
	WHERE Status=0 AND DbcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 11,'mClm5','Salesman Incentive Calculator','SMIncentiveCalculatorMaster',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM SMIncentiveCalculatorMaster
	WHERE Status=0 AND SicDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 11,'Salesman Incentive Calculator',SicRefNo
	FROM SMIncentiveCalculatorMaster
	WHERE Status=0 AND SicDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 12,'mClm13','Van Subsidy Claim','VanSubsidyHD',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM VanSubsidyHD
	WHERE [Confirm]=0 AND SubsidyDt BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 12,'Van Subsidy Claim',RefNo
	FROM VanSubsidyHD
	WHERE [Confirm]=0 AND SubsidyDt BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 13,'mClm11','Transporter Claim','TransporterClaimMaster',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM TransporterClaimMaster
	WHERE Status=0 AND TrcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 13,'Transporter Claim',TrcRefNo
	FROM TransporterClaimMaster
	WHERE Status=0 AND TrcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 14,'mClm4','Special Discount Claim','SpecialDiscountMaster',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM SpecialDiscountMaster
	WHERE Status=0 AND SdcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 14,'Special Discount Claim',SdcRefNo
	FROM SpecialDiscountMaster
	WHERE Status=0 AND SdcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 15,'mClm8','Rate Difference Claim','RateDifferenceClaim',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM RateDifferenceClaim
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 15,'Rate Difference Claim',RefNo
	FROM RateDifferenceClaim
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 16,'mClm9','Purchase Shortage Claim','PurShortageClaim',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM PurShortageClaim
	WHERE Status=0 AND ClaimDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 16,'Purchase Shortage Claim',PurShortRefNo
	FROM PurShortageClaim
	WHERE Status=0 AND ClaimDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 17,'mClm10','Purchase Excess Claim','PurchaseExcessClaimMaster',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM PurchaseExcessClaimMaster
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 17,'Purchase Excess Claim',RefNo
	FROM PurchaseExcessClaimMaster
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 18,'mClm3','Manual Claim','ManualClaimMaster',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM ManualClaimMaster
	WHERE Status=0 AND MacDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 18,'Manual Claim',MacRefNo
	FROM ManualClaimMaster
	WHERE Status=0 AND MacDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 19,'mClm16','VAT Claim','VatTaxClaim',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM VatTaxClaim
	WHERE Status=0 AND VatDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 19,'VAT Claim',SvatNo
	FROM VatTaxClaim
	WHERE Status=0 AND VatDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	--SELECT 20,'Claim Top Sheet','ClaimSheetHD',ISNULL(COUNT(*),0),@Pi_UsrId
	--FROM ClaimSheetHD
	--WHERE [Confirm]=0 --AND ClmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	--SELECT 20,'Claim Top Sheet',ClmCode
	--FROM ClaimSheetHD
	--WHERE [Confirm]=0 --AND ClmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 21,'mClm15','Spent and Received','SpentReceivedHD',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM SpentReceivedHD
	WHERE Status=0 AND SRDDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 21,'Spent and Received',SRDRefNo
	FROM SpentReceivedHD
	WHERE Status=0 AND SRDDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 22,'mCus29','Point Redemption Product','PntRetSchemeHD',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM PntRetSchemeHD
	WHERE Status=0 AND TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 22,'Point Redemption Product',PntRedRefNo
	FROM PntRetSchemeHD
	WHERE Status=0 AND TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	SELECT 23,'mCus34','Coupon Redemption','CouponRedHd',ISNULL(COUNT(*),0),@Pi_UsrId
	FROM CouponRedHd
	WHERE Status=0 AND CpnRedDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 23,'Coupon Redemption',CpnRedCode
	FROM CouponRedHd
	WHERE Status=0 AND CpnRedDate BETWEEN @Pi_FromDate AND @Pi_ToDate	
    INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)
	SELECT 25,'mCmp18','IDT Management','IDTManagement',ISNULL(COUNT(*),0),@Pi_UsrId
    FROM IDTManagement WITH(NOLOCK) WHERE Status = 0 AND IDTMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate    
    INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
    SELECT 25,'IDT Management',IDTMngRefNo FROM IDTManagement WITH(NOLOCK) 
    WHERE Status = 0 AND IDTMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
    INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)
	SELECT 26,'mCus36','Sample Issue','SampleIssue',ISNULL(COUNT(*),0),@Pi_UsrId
    FROM SampleIssueHd WITH(NOLOCK) WHERE Status = 0 AND IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
    INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
    SELECT 26,'Sample Issue',IssueRefNo FROM SampleIssueHd WITH(NOLOCK) 
    WHERE Status = 0 AND IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
    INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)
	SELECT 27,'mCus36','Sample Issue','SampleIssue',ISNULL(COUNT(*),0),@Pi_UsrId
    FROM FreeIssueHd WITH(NOLOCK) WHERE Status = 0 AND IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
    INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
    SELECT 27,'Sample Issue',IssueRefNo FROM FreeIssueHd WITH(NOLOCK) 
    WHERE Status = 0 AND IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
    INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)
	SELECT 28,'mCus36','Sample Receipt','SampleReceipt',ISNULL(COUNT(*),0),@Pi_UsrId
    FROM SamplePurchaseReceipt WITH(NOLOCK) WHERE Status = 0 AND InvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
    INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
    SELECT 28,'Sample Receipt',PurRcptRefNo FROM SamplePurchaseReceipt WITH(NOLOCK) 
    WHERE Status = 0 AND InvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
 --   INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)
	--SELECT 29,'mInv6','Batch Transfer','BatchTransfer',ISNULL(COUNT(*),0),@Pi_UsrId
 --   FROM BatchTransferHD WITH(NOLOCK) WHERE Status = 0 AND BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
 --   INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
 --   SELECT 29,'Batch Transfer',BatRefNo FROM BatchTransferHD WITH(NOLOCK) 
 --   WHERE Status = 0 AND BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate              
END
GO
UPDATE Configuration SET Status=1,Condition=1,ConfigValue='0.00' WHERE ModuleId='DAYENDPROCESS7'
GO
--JC Month End
INSERT INTO JCMonthEnd (JcmId,JcmJc,JcmSdt,JcmEdt,JcmMontEnddate,Status,LastModBy,Upload)
SELECT DISTINCT A.JcmId,JcmJc,JcmSdt,JcmEdt,GETDATE(),1,1,1 FROM JCMonth A WITH(NOLOCK) INNER JOIN JCMast B WITH(NOLOCK) ON A.JcmId = B.JcmId WHERE JcmEdt NOT IN 
(SELECT JcmEdt FROM JCMonth WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN JcmSdt AND JcmEdt)
AND JcmEdt < (SELECT JcmEdt FROM JCMonth WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN JcmSdt AND JcmEdt)
AND NOT EXISTS (SELECT JcmId,JcmJc,JcmSdt,JcmEdt FROM JCMonthEnd C WHERE A.JcmId = C.JcmId AND A.JcmJc = C.JcmJc 
AND A.JcmSdt = C.JcmSdt AND A.JcmEdt = C.JcmEdt)
GO
--Month End Cloning
INSERT INTO MonthEndClosing (StkMonth,StkYear,UploadFlag)
SELECT DISTINCT DATENAME(MM,JcmSdt),JcmYr,'Y' FROM JCMonth A WITH(NOLOCK) INNER JOIN JCMast B WITH(NOLOCK) ON A.JcmId = B.JcmId WHERE JcmEdt NOT IN 
(SELECT JcmEdt FROM JCMonth WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN JcmSdt AND JcmEdt)
AND JcmEdt < (SELECT JcmEdt FROM JCMonth WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN JcmSdt AND JcmEdt)
AND NOT EXISTS (SELECT StkMonth,StkYear FROM MonthEndClosing C WHERE C.StkMonth = DATENAME(MM,A.JcmSdt)
AND C.StkYear = B.JcmYr)
GO
--Day End Validation
DELETE FROM DayEndValidation
INSERT INTO DayEndValidation (DayEndType,DayEndStartDate,Status)
SELECT DISTINCT 2,JcmSdt,1 FROM JCMonth A WITH(NOLOCK) INNER JOIN JCMast B WITH(NOLOCK) ON A.JcmId = B.JcmId WHERE JcmSdt IN 
(SELECT JcmSdt FROM JCMonth WHERE CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN JcmSdt AND JcmEdt)
AND NOT EXISTS (SELECT DayEndStartDate FROM DayEndValidation C WHERE A.JcmSdt = C.DayEndStartDate)
GO
DECLARE @CurDate as DATETIME
SELECT @CurDate=MAX(JCMEdt) FROM JCMonthEnd WHERE STATUS=1
UPDATE DayEndDates Set Status=1 WHERE DayEndStartDate<=@CurDate
--Till Here
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='ETL_Prk_BLClaimSettlement')
DROP TABLE ETL_Prk_BLClaimSettlement
GO
CREATE TABLE ETL_Prk_BLClaimSettlement(
	[DistCode] [varchar](100) NULL,
	[ClaimSheetNo] [nvarchar](200) NULL,
	[ClaimRefNo] [nvarchar](200) NOT NULL,
	[CreditNoteNo] [nvarchar](100) NOT NULL,
	[DebitNoteNo] [nvarchar](100) NOT NULL,
	[CreditDebitNoteDate] [nvarchar](50) NOT NULL,
	[CreditDebitNoteAmt] [nvarchar](50) NOT NULL,
	[CreditDebitNoteReason] [nvarchar](250) NOT NULL,
	[DownloadFlag] [nvarchar](1) NOT NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_BLValidateClaimSettlement')
DROP PROCEDURE Proc_BLValidateClaimSettlement
GO
/*
BEGIN TRANSACTION
EXEC Proc_BLValidateClaimSettlement 0
ROLLBACK TRANSACTION
*/
CREATE    PROCEDURE [Proc_BLValidateClaimSettlement]
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


	BEGIN TRY
	
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
	IF EXISTS(SELECT ClaimRefNo FROM ETL_Prk_BLClaimSettlement
	WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM ETL_Prk_BLClaimSettlement
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','ClaimRefNo','Claim Ref No should not be empty for :'+CreditNoteNo
		FROM ETL_Prk_BLClaimSettlement
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM ETL_Prk_BLClaimSettlement
	WHERE Cast(CreditDebitNoteAmt as Numeric(36,6))<0)
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM ETL_Prk_BLClaimSettlement
		WHERE CreditDebitNoteAmt<0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Amount','Amount should be greater than zero for :'+ClaimRefNo
		FROM ETL_Prk_BLClaimSettlement
		WHERE CreditDebitNoteAmt<0
	END

	IF EXISTS(SELECT ClaimRefNo FROM ETL_Prk_BLClaimSettlement
	WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM ETL_Prk_BLClaimSettlement
		WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Credit/Debite Note No','Credit/Debite Note No should not be empty for :'+ClaimRefNo
		FROM ETL_Prk_BLClaimSettlement
		WHERE ISNULL(CreditNoteNo,'')+ISNULL(DebitNoteNo,'')=''
	END

--	IF EXISTS(SELECT ClaimRefNo FROM ETL_Prk_BLClaimSettlement
--	WHERE ISNULL(CreditDebitNoteReason,'')='')
--	BEGIN
--		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
--		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM ETL_Prk_BLClaimSettlement
--		WHERE ISNULL(CreditDebitNoteReason,'')=''
--		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
--		SELECT DISTINCT 1,'Claim Settlement','Reason','Reason should not be empty for :'+ClaimRefNo
--		FROM ETL_Prk_BLClaimSettlement
--		WHERE ISNULL(CreditDebitNoteReason,'')=''
--	END

	IF EXISTS(SELECT ClaimRefNo FROM ETL_Prk_BLClaimSettlement
	WHERE ISNULL(CreditDebitNoteDate,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM ETL_Prk_BLClaimSettlement
		WHERE ISNULL(CreditDebitNoteDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Date should not be empty for :'+ClaimRefNo
		FROM ETL_Prk_BLClaimSettlement
		WHERE ISNULL(CreditDebitNoteDate,'')=''
	END

	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM ETL_Prk_BLClaimSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
	(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId))
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM ETL_Prk_BLClaimSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Claim Reference Number :'+ClaimRefNo+'does not exists'
		FROM ETL_Prk_BLClaimSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)
	END
	
	DECLARE Cur_ClaimSettlement CURSOR	
	FOR SELECT  ISNULL([ClaimSheetNo],''),ISNULL([ClaimRefNo],''),ISNULL([CreditNoteNo],'0'),ISNULL([DebitNoteNo],'0'),
	CONVERT(NVARCHAR(11),[CreditDebitNoteDate],121),
	CAST(ISNULL([CreditDebitNoteAmt],0)AS NUMERIC(38,6)),
	ISNULL([CreditDebitNoteReason],'')
	FROM ETL_Prk_BLClaimSettlement WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CreditNoteNo NOT IN
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
						IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster'  AND Xtype = 'F') 
						BEGIN  
							ALTER TABLE [StdVocDetails] DROP CONSTRAINT [FK_StdVocDetails_StdVocMaster] 
						END
						IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND Xtype = 'PK')
						BEGIN 
							ALTER TABLE [StdVocMaster] DROP CONSTRAINT [PK_StdVocMaster] 
						END
												
						EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
						
						IF NOT EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND Xtype = 'PK') 
						BEGIN 
							ALTER TABLE [StdVocMaster] ADD CONSTRAINT [PK_StdVocMaster] 
							PRIMARY KEY  CLUSTERED ([VocRefno])  ON [PRIMARY] 
						END
						IF NOT EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster' AND Xtype = 'F') 
						BEGIN 
							ALTER TABLE [dbo].[StdVocDetails] ADD CONSTRAINT [FK_StdVocDetails_StdVocMaster] FOREIGN KEY ([VocRefno]) 
							REFERENCES [StdVocMaster]  ([VocRefno]) 
						END
						
					END

					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,CrDbmode=2,CrDbStatus=1,CrDbNotenumber=@CreditNo,Status=2
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE ETL_Prk_BLClaimSettlement SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber AND ClaimSheetNo=@ClaimSheetNo
				END
			END					
			ELSE IF @DebitNoteNumber <> '0' AND @CreditNoteNumber= '0'
			BEGIN

				SELECT @DebitNo=dbo.Fn_GetPrimaryKeyString('DebitNoteSupplier','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))

				INSERT INTO DebitNoteSupplier(DbNoteNumber,DbNoteDate,SpmId,CoaId,ReasonId,Amount,DbAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,DbNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@DebitNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,33,
				'Cmp-'+@DebitNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')

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
						IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster'  AND Xtype = 'F') 
						BEGIN  
							ALTER TABLE [StdVocDetails] DROP CONSTRAINT [FK_StdVocDetails_StdVocMaster] 
						END
						IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND Xtype = 'PK')
						BEGIN 
							ALTER TABLE [StdVocMaster] DROP CONSTRAINT [PK_StdVocMaster] 
						END
					
						EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
						
						IF NOT EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND Xtype = 'PK') 
						BEGIN 
							ALTER TABLE [StdVocMaster] ADD CONSTRAINT [PK_StdVocMaster] 
							PRIMARY KEY  CLUSTERED ([VocRefno])  ON [PRIMARY] 
						END
						IF NOT EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster' AND Xtype = 'F') 
						BEGIN 
							ALTER TABLE [dbo].[StdVocDetails] ADD CONSTRAINT [FK_StdVocDetails_StdVocMaster] FOREIGN KEY ([VocRefno]) 
							REFERENCES [StdVocMaster]  ([VocRefno]) 
						END
					END


					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,RecommendedAmount=@CrDbNoteAmount,
					CrDbmode=1,CrDbStatus=1,CrDbNotenumber=@DebitNo,Status=2
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber



					UPDATE ETL_Prk_BLClaimSettlement SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber AND ClaimSheetNo=@ClaimSheetNo
				END
			END	
		END
		FETCH NEXT FROM Cur_ClaimSettlement INTO @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
	END
	CLOSE Cur_ClaimSettlement
	DEALLOCATE Cur_ClaimSettlement

	SET @Po_ErrNo=0
	END TRY
	BEGIN CATCH
		SET @Po_ErrNo=1
		CLOSE Cur_ClaimSettlement
		DEALLOCATE Cur_ClaimSettlement
	END CATCH		
	RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_Stock' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Stock
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
BEGIN TRANSACTION
SELECT * FROM DayEndProcess
UPDATE DayEndProcess Set NextUpDate = '2008-12-01' Where procId = 11
DELETE FROM Cs2Cn_Prk_Stock
SELECT * FROM ETL_PrkCS2CNStkInventory WHERE [PRODUCTCODE]='701016' ORDER BY salInvDate
EXEC Proc_Cs2Cn_StkInventory
SELECT * FROM StockLedger WHERE TransDate>='2008/12/01'
SELECT * FROM Cs2Cn_Prk_Stock
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_Stock
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_CS2CNStkInventoryNew
* PURPOSE		: To Extract Stock Ledger Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 19/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @DefCmpAlone	AS INT
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Stock WHERE UploadFlag = 'Y'
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 11
	INSERT INTO Cs2Cn_Prk_Stock(DistCode,TransDate,LcnId,LcnCode,PrdId,PrdCode,PrdBatId,PrdBatCode,SalOpenStock,UnSalOpenStock,
	OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,
	SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
	OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,
	OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,
	OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,UploadFlag)
	SELECT @DistCode,TransDate,SL.LcnId,L.LcnCode,SL.PrdId,P.PrdCCode,SL.PrdBatId,PB.CmpBatCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,
	UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,
	SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,
	SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
	UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
	OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,
	SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,'N'
	FROM StockLedger SL (NOLOCK),Product P (NOLOCK),ProductBatch PB (NOLOCK),Location L (NOLOCK)
	WHERE SL.PrdId=P.PrdId AND SL.PrdBatId=PB.PrdBatId AND P.PrdId=PB.PrdId
	AND P.CmpId=(CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE P.CmpId END)
	AND SL.LcnId=L.LcnId AND Sl.TransDate>=@ChkDate	AND (SalPurchase+UnsalPurchase+OfferPurchase+SalPurReturn+UnsalPurReturn+
	OfferPurReturn+SalSales+UnSalSales+OfferSales+SalStockIn+UnSalStockIn+OfferStockIn+SalStockOut+UnSalStockOut+OfferStockOut+
	DamageIn+DamageOut+SalSalesReturn+UnSalSalesReturn+OfferSalesReturn+SalStkJurIn+UnSalStkJurIn+OfferStkJurIn+SalStkJurOut+
	UnSalStkJurOut+OfferStkJurOut+SalBatTfrIn+UnSalBatTfrIn+OfferBatTfrIn+SalBatTfrOut+UnSalBatTfrOut+OfferBatTfrOut+SalLcnTfrIn+
	UnSalLcnTfrIn+OfferLcnTfrIn+SalLcnTfrOut+UnSalLcnTfrOut+OfferLcnTfrOut+SalReplacement+OfferReplacement+
	SalOpenStock+UnSalOpenStock+OfferOpenStock+SalClsStock+UnSalClsStock+offerClsStock)>0
	
	---SalOpenStock,UnSalOpenStock,OfferOpenStock,SalClsStock,UnSalClsStock,offerClsStock
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GETDATE(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	WHERE ProcId = 11
	UPDATE Cs2Cn_Prk_Stock SET ServerDate=@ServerDate
END
GO
IF NOT EXISTS (SELECT A.Name FROM Syscolumns A WITH(NOLOCK) INNER JOIN Sysobjects B WITH(NOLOCK) ON A.id = B.id and b.xtype = 'U'
AND B.name = 'PurchaseOrderMaster' AND A.name= 'Remarks') 
BEGIN
    ALTER TABLE PurchaseOrderMaster ADD Remarks NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
DELETE FROM Configuration WHERE ModuleId = 'BCD7'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'BCD7','BillConfig_Display','Automatically popup the hotsearch window if the user types in the Product code',1,'',0.00,7
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnPrdHotSearch_TabSelc')
DROP FUNCTION Fn_ReturnPrdHotSearch_TabSelc
GO
--SELECT DBO.Fn_ReturnPrdHotSearch_TabSelc() bPrdSer
CREATE FUNCTION Fn_ReturnPrdHotSearch_TabSelc()
RETURNS TINYINT
AS
/*********************************
* PROCEDURE: Fn_ReturnPrdHotSearch_TabSelc
* PURPOSE: General function
* NOTES:
* CREATED: Praveenraj B 10/03/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
	DECLARE @PRDHOTSEARCH TINYINT
	SET @PRDHOTSEARCH=0
	IF EXISTS (SELECT CmpCode FROM Company WITH(NOLOCK) WHERE CmpCode = 'HTN')
	BEGIN
		IF EXISTS (SELECT * FROM Configuration (NOLOCK) WHERE ModuleId='BCD7' AND Status=1)	
		BEGIN
			SET @PRDHOTSEARCH=1
		END
		ELSE
		BEGIN
			SET @PRDHOTSEARCH=0
		END
	END
RETURN(@PRDHOTSEARCH)
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND NAME='Proc_Cs2Cn_PurchaseConfirmation')
DROP PROCEDURE Proc_Cs2Cn_PurchaseConfirmation
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_PurchaseConfirmation 0,'2013-03-01'
SELECT * FROM Cs2Cn_Prk_PurchaseConfirmation ORDER BY GRNRefNo
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_PurchaseConfirmation
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_PurchaseConfirmation
* PURPOSE		: To Extract Purchase Details from CoreStocky to upload to Console
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
	DECLARE @CmpID 		AS INT
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @DefCmpAlone	AS INT
	SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_PurchaseConfirmation WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_PurchaseConfirmation
	(
		DistCode				,
		GRNCmpInvNo				,
		GRNRefNo				,
		GRNRcvdDate				,
		GRNInvDate				,
		GRNPORefNo				,
		SupplierCode			,
		TransporterCode			,
		LRNo					,
		LRDate					,
		GRNGrossAmt				,
		GRNDiscAmt				,
		GRNTaxAmt				,
		GRNSchAmt				,
		GRNOtherChargesAmt		,
		GRNHandlingChargesAmt	,
		GRNTotDedn				,
		GRNTotAddn				,
		GRNRoundOffAmt			,
		GRNNetAmt				,
		GRNNetPayableAmt		,
		GRNDiffAmt				,
		PrdRowId				,
		PrdSchemeFlag			,
		PrdCmpSchCode			,	
		PrdLcnId				,
		PrdLcnCode				,
		PrdCode					,
		PrdBatCode				,
		PrdInvQty				,
		PrdRcvdQty				,
		PrdUnSalQty				,
		PrdShortQty				,
		PrdExcessQty			,
		PrdExcessRefusedQty		,
		PrdLSP					,
		PrdGrossAmt				,
		PrdDiscAmt				,
		PrdTaxAmt				,
		PrdNetRate				,
		PrdNetAmt				,
		PrdLineBreakUpType		,
		PrdLineLcnId			,
		PrdLineLcnCode			,
		PrdLineStockType		,
		PrdLineQty				,
		UploadFlag			    
		
	)
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GOodsRcvdDate AS GrnRcvDt ,
		PR.InvDate,PR.PurOrderRefNo,S.SpmCode,T.TransporterCode,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,PRP.PrdSlNo,'No','',PR.LcnId,L.LcnCode,
		P.PrdCCode AS ProdCode ,PB.CmpBatCode AS PrdBatCde ,
		PRP.InvBaseQty,PRP.RcvdGOodBaseQty,UnSalBaseQty,ShrtBaseQty,
		(CASE PRP.RefuseSale WHEN 0 THEN ExsBaseQty ELSE 0 END),
		(CASE PRP.RefuseSale WHEN 1 THEN ExsBaseQty ELSE 0 END),
		PRP.PrdLSP,PRP.PrdGrossAmount,PRP.PrdDiscount,PRP.PrdTaxAmount,PRP.PrdUnitNetRate,PRP.PrdNetAmount,
		ISNULL((CASE PRB.BreakUpType WHEN 1 THEN 'UnSaleable' WHEN 2 THEN 'Excess' END),''),
		ISNULL(PRBL.LcnId,0),ISNULL(PRBL.LcnCode,''),
		ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
		ISNULL(PRB.BaseQty,0),
		'N'					
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 AND
		PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END) AND PR.Upload=0
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN Location L ON L.LcnId=PR.LcnId
		LEFT OUTER JOIN PurchaseReceiptBreakUp PRB ON PRP.PurRcptId=PRB.PurRcptId AND PRP.PrdSlNo=PRB.PrdSlNo
		LEFT OUTER JOIN StockType ST ON PRB.StockTypeId=ST.StockTypeId
		LEFT OUTER JOIN Location PRBL ON PRBL.LcnId=ST.LcnId
	UNION ALL
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GOodsRcvdDate AS GrnRcvDt ,
		PR.InvDate,PR.PurOrderRefNo,S.SpmCode,T.TransporterCode,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,PRP.SlNo,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),
		ISNULL(Sch.CmpSchCode,Sch.SchCode),L.LcnId,L.LcnCode,
		P.PrdCCode AS ProdCode ,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'',0,'',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0,
		'N'					
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 AND
		PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END) AND PR.Upload=0 AND PRP.TypeId=2
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId
		LEFT OUTER JOIN SchemeMaster Sch ON Sch.SchId=RefId
	UNION ALL
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GOodsRcvdDate AS GrnRcvDt ,
		PR.InvDate,PR.PurOrderRefNo,S.SpmCode,T.TransporterCode,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,PRP.SlNo,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),
		ISNULL(CSD.RefCode,''),L.LcnId,L.LcnCode,
		P.PrdCCode AS ProdCode ,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'',0,'',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0,
		'N'					
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 AND
		PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END) AND PR.Upload=0 AND PRP.TypeId=1
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId
		INNER JOIN ClaimSheetHd CSH ON CSH.ClmId=PRP.RefId
		INNER JOIN ClaimSheetDetail CSD ON CSH.ClmId=CSD.ClmId AND PRP.SlNo=CSD.SlNo
	UNION ALL
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GOodsRcvdDate AS GrnRcvDt ,
		PR.InvDate,PR.PurOrderRefNo,S.SpmCode,T.TransporterCode,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,PRP.SlNo,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' WHEN 1 THEN 'Claim' Else 'Free' END),
		ISNULL(Sch.CmpSchCode,''),L.LcnId,L.LcnCode,
		P.PrdCCode AS ProdCode ,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'',0,'',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0,
		'N'					
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 AND
		PR.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE PR.CmpId END) AND PR.Upload=0 AND PRP.TypeId=3
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId
		LEFT OUTER JOIN SchemeMaster Sch ON Sch.SchId=RefId
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where procId = 3
	UPDATE PurchaseReceipt SET Upload=1 WHERE Upload=0 AND PurRcptRefNo IN (SELECT DISTINCT
	GRNRefNo FROM Cs2Cn_Prk_PurchaseConfirmation WHERE UploadFlag = 'N')
	UPDATE Cs2Cn_Prk_PurchaseConfirmation SET ServerDate=@ServerDate
END
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE XTYPE='U' AND name='SchemeProductErrorlog')
BEGIN
		CREATE TABLE SchemeProductErrorlog
		(
			Slno NUMERIC (38,0) IDENTITY (1,1),
			CmpSchCode	VARCHAR(50),
			ProductCode	VARCHAR(50),
			BatchCode	VARCHAR(50),
			PrdType		VARCHAR(20),
			SchType		VARCHAR(20),
			Error		VARCHAR(500)	
		)		
END
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE XTYPE='U' AND NAME='Cn2Cs_Prk_PurSuggestedOrder')
BEGIN
	CREATE TABLE Cn2Cs_Prk_PurSuggestedOrder
	(
		DistCode		VARCHAR(50) ,
		ProductCode		VARCHAR(50) ,
		PurOrdNo		VARCHAR(100) ,
		ApprovedQty		INT ,
		ApprovedStatus	VARCHAR(50) ,
		DownloadFlag	VARCHAR(1) ,
		CreatedDate		DATETIME 
	)
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_Import_PurSuggestedOrder')
DROP PROCEDURE Proc_Import_PurSuggestedOrder
GO
--EXEC Proc_Import_PurSuggestedOrder '<Root></Root>'
CREATE PROCEDURE Proc_Import_PurSuggestedOrder
(
	@Pi_Records NTEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_PurSuggestedOrder
* PURPOSE		: To dowload and insert into purchase order parking table from console
* CREATED BY	: Praveenraj B
* CREATED DATE	: 21-01-2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_PurSuggestedOrder
			(DistCode,
			ProductCode,
			PurOrdNo,
			ApprovedQty,
			ApprovedStatus,
			DownloadFlag,
			CreatedDate)
	SELECT	DistCode,
			ProductCode,
			PurOrdNo,
			ApprovedQty,
			ApprovedStatus,
			DownloadFlag,
			CreatedDate
	FROM OPENXML (@hdoc,'/Root/Console2CS_SuggestedOrder',1)
	WITH
	(
			DistCode		VARCHAR(50) ,
			ProductCode		VARCHAR(50) ,
			PurOrdNo		VARCHAR(100) ,
			ApprovedQty		INT ,
			ApprovedStatus	VARCHAR(50) ,
			DownloadFlag	VARCHAR(1) ,
			CreatedDate		DATETIME 
	) XMLObj
	EXEC sp_xml_removedocument @hDoc
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id =B.id AND A.name='PurchaseOrderDetails' AND B.name='ApprovedQty')
BEGIN
	ALTER TABLE PurchaseOrderDetails ADD ApprovedQty INT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id =B.id AND A.name='PurchaseOrderDetails' AND B.name='ApprovedStatus')
BEGIN
	ALTER TABLE PurchaseOrderDetails ADD ApprovedStatus VARCHAR(20) DEFAULT '' WITH VALUES
END
GO
DELETE FROM CustomCaptions WHERE TransId=26 AND CtrlId=100021 AND SubCtrlId=21
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 26,100021,21,'SprPrdDetails-26-5-21','Approved Qty','','',1,1,1,GETDATE(),1,GETDATE(),'Approved Qty','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=26 AND CtrlId=100022 AND SubCtrlId=22
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 26,100022,22,'SprPrdDetails-26-5-22','Approved Status','','',1,1,1,GETDATE(),1,GETDATE(),'Approved Status','','',1,1
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE='U' AND name='IDTBillPrint')
DROP TABLE IDTBillPrint
GO
CREATE TABLE [dbo].[IDTBillPrint](
	[IDT Reference No] [nvarchar](100) NULL,
	[IDT Reference Date] [datetime] NULL,
	[LcnId] [int] NULL,
	[Location] [nvarchar](100) NULL,
	[StkMgmtTypeId] [int] NULL,
	[StockManagement Type] [varchar](100) NULL,
	[DocRefNo] [nvarchar](100) NULL,
	[LR No] [nvarchar](100) NULL,
	[LR Date] [datetime] NULL,
	[Remarks] [nvarchar](100) NULL,
	[IDTHeader GrossAmt] [numeric](38, 2) NULL,
	[IDHeader TaxAmt] [numeric](38, 2) NULL,
	[IDTHeader NetAmt] [numeric](38, 2) NULL,
	[IDT PaidAmt] [numeric](38, 2) NULL,
	[From Distributor Id] [int] NULL,
	[From Distributor Code] [nvarchar](100) NULL,
	[From Distributor Name] [nvarchar](100) NULL,
	[From Distributor Address1] [nvarchar](100) NULL,
	[From Distributor Address2] [nvarchar](100) NULL,
	[From Distributor Address3] [nvarchar](100) NULL,
	[From Distributor Phone] [nvarchar](100) NULL,
	[From Distributor Contact] [nvarchar](100) NULL,
	[From Distributor Email] [nvarchar](100) NULL,
	[To Distributor Id] [int] NULL,
	[To Distributor Code] [varchar](100) NULL,
	[To Distributor Name] [varchar](100) NULL,
	[To Distributor Address1] [varchar](100) NULL,
	[To Distributor Address2] [varchar](100) NULL,
	[To Distributor Address3] [varchar](100) NULL,
	[To Distributor Phone] [varchar](100) NULL,
	[To Distributor Contact] [varchar](100) NULL,
	[To Distributor Email] [varchar](100) NULL,
	[PrdId] [int] NULL,
	[Prroduct Distributor Code] [nvarchar](100) NULL,
	[Qty] [int] NULL,
	[Product Company Code] [nvarchar](100) NULL,
	[Product Name] [nvarchar](100) NULL,
	[Product Short Name] [nvarchar](100) NULL,
	[PrdBatId] [int] NULL,
	[Product Batch Code] [nvarchar](100) NULL,
	[MRP] [numeric](38, 2) NULL,
	[ListPrice] [numeric](38, 2) NULL,
	[Line GrossAmount] [numeric](38, 2) NULL,
	[Line TaxAmount] [numeric](38, 2) NULL,
	[Line NetAmount] [numeric](38, 2) NULL,
	[PrdSlNo] [int] NULL,
	[PriceId] [bigint] NULL,
	[IDT Charges] [numeric](38, 2) NULL,
	[Tax Percent] [numeric](38, 2) NULL,
	[Tax Amount] [numeric](38, 2) NULL,
	[Taxable Amount] [numeric](38, 2) NULL,
	[Add TaxPercent] [numeric](38, 2) NULL,
	[Add TaxAmount] [numeric](38, 2) NULL,
	[AmountInWord] [varchar](3000) NULL,
	[UserId] [int] NULL
)
GO
IF NOT EXISTS (SELECT B.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id WHERE A.name='IDTBillPrint' AND B.Name='Total IDT Charges')
BEGIN
	ALTER TABLE IDTBillPrint ADD [Total IDT Charges] numeric(38, 2) DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE='P' AND name='Proc_IDTBillPrint')
DROP PROCEDURE Proc_IDTBillPrint
GO
CREATE PROCEDURE [dbo].[Proc_IDTBillPrint]
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
/****************************************************************************************
* PROCEDURE	: Proc_IDTBillPrint
* PURPOSE	: General Procedure
* NOTES		:
* CREATED	:  
* MODIFIED
* DATE			AUTHOR		  DESCRIPTION
------------------------------------------------------------------------------------------
* 2013-05-31    Alphonse J    Incorrect join updated ICRSTJNJ0113
****************************************************************************************/
SET NOCOUNT ON
DECLARE @FromDate		DateTime
DECLARE @ToDate			DateTime
DECLARE @LcnId			INT
DECLARE @FromDistId		INT
DECLARE @ToDistId		INT
DECLARE @IDTRefNo nVarchar(100)
DECLARE @StockTypeId		INT
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT   TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
set @StockTypeId = (Select Distinct StockType From RptIDTToPrint where UsrId = @Pi_UsrId)
BEGIN
						/* Stock In  - 1  Stock Out  - 2 */
DELETE FROM IDTBillPrint Where UserId = @Pi_UsrId
	IF @StockTypeId = 1
	BEGIN
		INSERT INTO IDTBillPrint([IDT Reference No],[IDT Reference Date],LcnId,Location,StkMgmtTypeId,
								[StockManagement Type],
								DocRefNo,[LR No],[LR Date],Remarks,[IDTHeader GrossAmt],[IDHeader TaxAmt],
								[IDTHeader NetAmt],[IDT PaidAmt],[From Distributor Id],[From Distributor Code],
								[From Distributor Name],[From Distributor Address1],
								[From Distributor Address2],[From Distributor Address3],[From Distributor Phone],
								[From Distributor Contact],[From Distributor Email],[To Distributor Id],
								[To Distributor Code],[To Distributor Name],[To Distributor Address1],
								[To Distributor Address2],[To Distributor Address3],[To Distributor Phone],
								[To Distributor Contact],[To Distributor Email],PrdId,[Prroduct Distributor Code],
								Qty,[Product Company Code],[Product Name],[Product Short Name],
								PrdBatId,[Product Batch Code],MRP,ListPrice,[Line GrossAmount],[Line TaxAmount],
								[Line NetAmount],PrdSlNo,PriceId,
								[IDT Charges],[Tax Percent],[Tax Amount],[Taxable Amount],[Add TaxPercent],
								[Add TaxAmount],UserId)
		SELECT  DISTINCT
				A.IDTMngRefNo,IDTMngDate,A.LcnId,LcnName,
				StkMgmtTypeId,Case StkMgmtTypeId When 1 Then 'IDT IN' ELSE 'IDT OUT' END AS StockManagementType,
				Isnull(DocRefNo,'') DocRefNo,Isnull(LRNo,'') LRNo,LRDate,Isnull(Remarks,'') Remarks,
				IDTGrossAmt IDTHeaderGrossAmt,IDTTaxAmt  IDHeaderTaxAmt,
				IDTNetAmt	IDTHeaderNetAmt,  IDTPaidAmt IDTPaidAmt,
				A.FromSpmId FromDistId,C.SpmCode FromDistCode,
				C.SpmName FromDistName,C.SpmAdd1 FromDistAddress1,C.SpmAdd2 FromDistAddress2,
				C.SpmAdd3 FromDistAddress3,C.SpmPhone FromDistPhone,
				C.SpmContact FromDistContact,C.SpmEmail FromDistEmail, 
				DistributorId ToDistId,DistributorCode ToDistCode,DistributorName ToDistName,
				DistributorAdd1 ToDistAddress1,DistributorAdd2 ToDistAddress2,DistributorAdd3 ToDistAddress3,			
				PhoneNo ToDistPhine,ContactPerson ToDistContact,EmailId ToDistEmail,
				E.PrdId,PrdDCode PrdDistCode,Qty,PrdCcode PrdComCode,PrdName,PrdShrtName,
				E.PrdBatId,	PrdBatCode,PrdMRPRate MRP,PrdUnitRate ListPrice,
				PrdGrossAmount LineGrossAmount,PrdTaxAmount LineTaxAmount,
				PrdNetAmount LineNetAmount,E.PrdSlNo,PriceId,
				LineBaseQtyAmount IDTCharges,
				IDTTax.TaxPerc,IDTTax.TaxAmount,IDTTax.TaxableAmount,
				IDTTax.AddTaxPer,IDTTax.AddTaxAmt,
				@Pi_UsrId UserId
		FROM 
				IDTManagement A (Nolock)
					INNER JOIN Location B (Nolock) ON  A.LcnId = B.LcnId
					LEFT OUTER JOIN  IDTMaster C (Nolock) ON A.FromSpmId = C.SpmId
					LEFT OUTER JOIN  Distributor D (Nolock) ON A.ToSpmId = D.DistributorId
					INNER JOIN IDTManagementProduct E (Nolock) ON A.IDTMngRefNo = E.IDTMngRefNo
					INNER JOIN Product P (Nolock) ON E.PrdId = P.PrdId
					INNER JOIN ProductBatch PB (Nolock) ON E.PrdBatId = PB.PrdBatId 
												  and E.PrdId = PB.PrdId and P.PrdId = PB.PrdId
					INNER JOIN IDTManagementLineAmount F (Nolock) ON A.IDTMngRefNo = F.IDTMngRefNo and  E.PrdSlNo = F.PrdSlNo
															AND RefCode = 'E'
					LEFT OUTER JOIN (SELECT	A.IDTMngRefNo,A.PrdId,A.PrdBatId,A.TaxPerc Taxperc,A.TaxAmount,A.TaxableAmount ,  --ICRSTJNJ0113
											ISNULL(B.TaxPerc,0) AddTaxPer ,ISNULL(B.TaxAmount,0) AddTaxAmt
									FROM(
										(	Select	TT.IDTMngRefNo,TT.PrdId,TT.PrdBatId,TT.PrdSlNo,TaxPerc,
													TaxAmount,TaxableAmount
											FROM    IDTManagementProductTax TT  (Nolock)
													INNER JOIN IDTManagementProduct T (Nolock) ON T.IDTMngRefNo=TT.IDTMngRefNo		
													and T.PrdId	= TT.PrdId  and T.PrdBatId = TT.PrdBatId 
											WHERE TaxableAmount > 0 and TaxId = 1 
										 ) A 
									LEFT OUTER JOIN 
										(	Select	A.IDTMngRefNo,A.PrdId,A.PrdBatId,A.PrdSlNo,TaxPerc,
													TaxAmount,TaxableAmount
											FROM    IDTManagementProductTax A (Nolock)
													INNER JOIN IDTManagementProduct B (Nolock) ON A.IDTMngRefNo=B.IDTMngRefNo		
													and B.PrdId	= A.PrdId  and A.PrdBatId = B.PrdBatId 
											WHERE TaxableAmount > 0 and TaxId > 1					
										)B  
										ON A.IDTMngRefNo=B.IDTMngRefNo and A.PrdId=B.PrdId and A.PrdBatId = B.PrdbatId)
									)  as IDTTax ON A.IDTMngRefNo = IDTTax.IDTMngRefNo and IDTTax.PrdId = E.PrdId
									   AND IDTTax.PrdBatId = E.PrdBatId		
					INNER JOIN RptIDTToPrint R ON A.IDTMngRefNo = R.IDTRefNumber and UsrId = @Pi_UsrId
		WHERE 
				StkMgmtTypeId = 1   
		ORDER BY A.IDTMngRefNo
	END 
	ELSE
	BEGIN		
			INSERT INTO IDTBillPrint([IDT Reference No],[IDT Reference Date],LcnId,Location,StkMgmtTypeId,
								[StockManagement Type],
								DocRefNo,[LR No],[LR Date],Remarks,[IDTHeader GrossAmt],[IDHeader TaxAmt],
								[IDTHeader NetAmt],[IDT PaidAmt],[From Distributor Id],[From Distributor Code],
								[From Distributor Name],[From Distributor Address1],
								[From Distributor Address2],[From Distributor Address3],[From Distributor Phone],
								[From Distributor Contact],[From Distributor Email],[To Distributor Id],
								[To Distributor Code],[To Distributor Name],[To Distributor Address1],
								[To Distributor Address2],[To Distributor Address3],[To Distributor Phone],
								[To Distributor Contact],[To Distributor Email],PrdId,[Prroduct Distributor Code],
								Qty,[Product Company Code],[Product Name],[Product Short Name],
								PrdBatId,[Product Batch Code],MRP,ListPrice,[Line GrossAmount],[Line TaxAmount],
								[Line NetAmount],PrdSlNo,PriceId,
								[IDT Charges],[Tax Percent],[Tax Amount],[Taxable Amount],[Add TaxPercent],
								[Add TaxAmount],UserId)
			SELECT  DISTINCT
					A.IDTMngRefNo,IDTMngDate,A.LcnId,LcnName,
					StkMgmtTypeId,Case StkMgmtTypeId When 1 Then 'IDT IN' ELSE 'IDT OUT' END AS StockManagementType,
					Isnull(DocRefNo,'') DocRefNo,Isnull(LRNo,'') LRNo,LRDate,Isnull(Remarks,'') Remarks,
					IDTGrossAmt IDTHeaderGrossAmt,IDTTaxAmt  IDHeaderTaxAmt,
					IDTNetAmt	IDTHeaderNetAmt,  IDTPaidAmt IDTPaidAmt,
					DistributorId FromDistId,DistributorCode FromDistCode,DistributorName FromDistName,
					DistributorAdd1 FromDistAddress1,	DistributorAdd2 FromDistAddress2,DistributorAdd3 FromDistAddress3,
					PhoneNo FromDistPhone,ContactPerson FromDistContact,EmailId FromDistEmail,
					A.FromSpmId ToDistId,C.SpmCode ToDistCode,
					C.SpmName ToDistName,C.SpmAdd1 ToDistAddress1,C.SpmAdd2 ToDistAddress2,
					C.SpmAdd3 ToDistAddress3,	C.SpmPhone ToDistPhone,
					C.SpmContact ToDistContact,C.SpmEmail ToDistEmail,			 
					E.PrdId,PrdDCode PrdDistCode,Qty,PrdCcode PrdComCode,PrdName,PrdShrtName,
					E.PrdBatId,	PrdBatCode,PrdMRPRate MRP,PrdUnitRate ListPrice,
					PrdGrossAmount LineGrossAmount,PrdTaxAmount LineTaxAmount,
					PrdNetAmount LineNetAmount,E.PrdSlNo,PriceId,
					LineBaseQtyAmount IDTCharges,
					IDTTax.TaxPerc,IDTTax.TaxAmount,IDTTax.TaxableAmount,
					IDTTax.AddTaxPer,IDTTax.AddTaxAmt,
					@Pi_UsrId UserId
			FROM 
					IDTManagement A (Nolock)
						INNER JOIN Location B (Nolock) ON  A.LcnId = B.LcnId
						LEFT OUTER JOIN  IDTMaster C (Nolock) ON A.ToSpmId = C.SpmId
						LEFT OUTER JOIN  Distributor D (Nolock) ON A.FromSpmId = D.DistributorId
						INNER JOIN IDTManagementProduct E (Nolock) ON A.IDTMngRefNo = E.IDTMngRefNo
						INNER JOIN Product P (Nolock) ON E.PrdId = P.PrdId
						INNER JOIN ProductBatch PB (Nolock) ON E.PrdBatId = PB.PrdBatId 
													  and E.PrdId = PB.PrdId and P.PrdId = PB.PrdId
						INNER JOIN IDTManagementLineAmount F (Nolock) ON A.IDTMngRefNo = F.IDTMngRefNo and  E.PrdSlNo = F.PrdSlNo
																AND RefCode = 'E'
						LEFT OUTER JOIN (SELECT	A.IDTMngRefNo,A.PrdId,A.PrdBatId,A.TaxPerc Taxperc,A.TaxAmount,A.TaxableAmount ,  --ICRSTJNJ0113
											ISNULL(B.TaxPerc,0) AddTaxPer ,ISNULL(B.TaxAmount,0) AddTaxAmt
									FROM(
										(	Select	TT.IDTMngRefNo,TT.PrdId,TT.PrdBatId,TT.PrdSlNo,TaxPerc,
													TaxAmount,TaxableAmount
											FROM    IDTManagementProductTax TT (Nolock)
													INNER JOIN IDTManagementProduct T (Nolock) ON T.IDTMngRefNo=TT.IDTMngRefNo		
													and T.PrdId	= TT.PrdId  and T.PrdBatId = TT.PrdBatId 
											WHERE TaxableAmount > 0 and TaxId = 1 
										 ) A 
									LEFT OUTER JOIN 
										(	Select	A.IDTMngRefNo,A.PrdId,A.PrdBatId,A.PrdSlNo,TaxPerc,
													TaxAmount,TaxableAmount
											FROM    IDTManagementProductTax A  (Nolock)
													INNER JOIN IDTManagementProduct B (Nolock) ON A.IDTMngRefNo=B.IDTMngRefNo		
													and B.PrdId	= A.PrdId  and A.PrdBatId = B.PrdBatId 
											WHERE TaxableAmount > 0 and TaxId > 1					
										)B  
										ON A.IDTMngRefNo=B.IDTMngRefNo and A.PrdId=B.PrdId and A.PrdBatId = B.PrdbatId)
									)  as IDTTax ON A.IDTMngRefNo = IDTTax.IDTMngRefNo and IDTTax.PrdId = E.PrdId
									   AND IDTTax.PrdBatId = E.PrdBatId	
							INNER JOIN RptIDTToPrint R ON A.IDTMngRefNo = R.IDTRefNumber and UsrId = @Pi_UsrId			
			WHERE 
				StkMgmtTypeId = 2 
			ORDER BY A.IDTMngRefNo
	END
	UPDATE A SET A.[Total Idt Charges]=X.[IDT Charges] FROM IDTBillPrint A INNER JOIN (
	SELECT [IDT Reference No],SUM([IDT Charges]) [IDT Charges] FROM IDTBillPrint (NOLOCK) WHERE UserId=@Pi_UsrId  GROUP BY [IDT Reference No] ) X
	ON X.[IDT Reference No]=A.[IDT Reference No]
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_Console2CS_ConsolidatedDownload')
DROP PROCEDURE Proc_Console2CS_ConsolidatedDownload
GO
CREATE PROCEDURE [dbo].[Proc_Console2CS_ConsolidatedDownload]  
AS  
BEGIN  
  
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
  
 Delete A From Console2CS_Consolidated A (Nolock) Where DownloadFlag='Y'  
  
 Insert Into #Console2CS_Consolidated  
 Select *,0 as DWNStatus from Console2CS_Consolidated (Nolock) Where DownloadFlag='N'  
   
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
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnPrdMaxUom')
DROP FUNCTION Fn_ReturnPrdMaxUom
GO
--SELECT * FROM Fn_ReturnPrdMaxUom()
CREATE FUNCTION Fn_ReturnPrdMaxUom()
RETURNS @ProductUom TABLE (PrdId BIGINT,UomId INT,UomGroupId INT,ConversionFactor BIGINT,UomDesc VARCHAR(20),UomCode VARCHAR(10))
AS
BEGIN
	INSERT INTO @ProductUom (PrdId,UomId,UomGroupId,ConversionFactor,UomDesc,UomCode)
	SELECT P.PrdId,UM.UomId,UM.UomGroupId,UM.ConversionFactor,Uo.UomDescription,UO.UomCode FROM UomGroup UM INNER JOIN 
	UOMMaster UO ON Uo.UomId=UM.UomId INNER JOIN 
	(SELECT UomGroupId,MAX(ConversionFactor) ConversionFactor FROM UomGroup GROUP BY UomGroupId) MAXUOM 
	ON MAXUOM.UomGroupId=UM.UomGroupId AND MAXUOM.ConversionFactor=UM.ConversionFactor
	INNER JOIN Product P ON P.UomGroupId=UM.UomGroupId
RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnPrdUom')
DROP FUNCTION Fn_ReturnPrdUom
GO
--SELECT * FROM Fn_ReturnPrdUom(0)
CREATE FUNCTION Fn_ReturnPrdUom(@PrdId BIGINT,@BaseUom TINYINT)
RETURNS @ProductUom TABLE (UomId INT,UomCode VARCHAR(10),ConversionFactor BIGINT,PrdId BIGINT)
AS
BEGIN
	IF ISNULL(@BaseUom,0)=1
	BEGIN
		INSERT INTO @ProductUom (UomId,UomCode,ConversionFactor,PrdId)
		SELECT UM.UomId, UM.UomCode, UG.ConversionFactor, PrdId from UomMaster UM,UomGroup UG, Product P 
		WHERE P.UomGroupId = UG.UomGroupId and UM.UomId = UG.UomId and P.PrdId = ISNULL(@PrdId,0) ORDER BY UG.ConversionFactor ASC
	END
	ELSE
	BEGIN
		INSERT INTO @ProductUom (UomId,UomCode,ConversionFactor,PrdId)
		SELECT UM.UomId, UM.UomCode, UG.ConversionFactor, PrdId from UomMaster UM,UomGroup UG, Product P 
		WHERE P.UomGroupId = UG.UomGroupId and UM.UomId = UG.UomId and P.PrdId = ISNULL(@PrdId,0) ORDER BY UG.ConversionFactor DESC
	END
	
RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnPOProductRate')
DROP FUNCTION Fn_ReturnPOProductRate
GO
--SELECT * FROM Fn_ReturnPOProductRate(1,2)
CREATE FUNCTION Fn_ReturnPOProductRate(@PrdId BIGINT,@UomId BIGINT)
RETURNS @ProductRate TABLE (PrdBatId BIGINT,PrdBatCode VARCHAR(500),ListPrice NUMERIC(38,6),PriceId BIGINT,ConversionFactor BIGINT)
AS
BEGIN
	INSERT INTO @ProductRate (PrdBatId,PrdBatCode,ListPrice,PriceId,ConversionFactor)
	SELECT DISTINCT PB.PrdBatId,PB.PrdBatCode,(PBD.PrdBatDetailValue * UG.ConversionFactor) AS ListPrice,PB.DefaultPriceId As PriceId,UG.ConversionFactor 
	FROM Product P,ProductBatch PB,ProductBatchDetails PBD,BatchCreation BC,UomGroup UG WHERE P.Prdid = PB.Prdid And PB.PrdBatId=PBD.PrdBatId AND 
	BC.BatchSeqId=PBD.BatchSeqId AND BC.SlNo=PBD.SlNo AND PBD.PriceId=PB.DefaultPriceId  AND BC.ListPrice=1 AND PB.PrdId=@PrdId AND UG.UomId = @UomId AND 
	P.UomGroupId = UG.UomGroupId 
	AND PB.PrdBatId IN (SELECT MAX(PrdBatId) FROM ProductBatch WHERE PrdId=@PrdId AND Status=1)
RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnPODate')
DROP FUNCTION Fn_ReturnPODate
GO
--SELECT DBO.Fn_ReturnPODate('AMUL') POEXPIRYDATE
CREATE FUNCTION Fn_ReturnPODate(@CompName VARCHAR(20))
RETURNS DATETIME
AS
BEGIN
		DECLARE @POEXPIRYDATE DATETIME
		SET @POEXPIRYDATE=CONVERT(VARCHAR(10),GETDATE(),121)
		IF UPPER(LTRIM(RTRIM(@CompName)))='GCMMF LTD'
		BEGIN
			SET @POEXPIRYDATE =CONVERT(VARCHAR(10),GETDATE()+3,121)
		END
		ELSE
		BEGIN
			SET @POEXPIRYDATE =CONVERT(VARCHAR(10),GETDATE(),121)
		END
RETURN (@POEXPIRYDATE)
END
GO
DELETE FROM HotSearchEditorHd WHERE FormId=569
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 569,'Purchase Order','Product with Supplier','select','
SELECT DISTINCT PrdSeqDtId,PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,UomId,UomDescription,SysQty,UomId2,UomDescription2,OrderQty FROM  
(SELECT Distinct C.PrdSeqDtId, P.PrdId,P.PrdDCode,P.PrdCCode,P.PrdName,P.PrdShrtName,U.UomId,U.UomCode UomDescription,0 as SysQty,  U.UomId UomId2,
U.UomCode UomDescription2,0 as OrderQty FROM Product P,UomMaster U ,UomGroup UG,ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK),
ProductCategoryValue PCV (NOLOCK),Fn_ReturnPrdMaxUom() MAXUOM  
WHERE P.UomGroupId = UG.UomGroupId  and UG.UomId = U.UomId AND P.UomGroupId=MAXUOM.UomGroupId AND UG.UomId=MAXUOM.UomId AND MAXUOM.PrdId=P.PrdId   AND CmpId = vFParam AND SpmId =vSParam AND B.TransactionId = 26 
AND P.PrdStatus=1 AND P.PrdType <> 3 AND B.PrdSeqId = C.PrdSeqId       AND P.PrdId = C.PrdId  AND P.PrdCtgValMainId=PCV.PrdCtgValMainId AND 
PCV.PrdCtgValLinkCode LIKE ''vTParam%''       UNION 
SELECT DISTINCT 100000 AS PrdSeqDtId,P.PrdId,P.PrdDCode,P.PrdCCode,P.PrdName,P.PrdShrtName,U.UomId,U.UomCode UomDescription,0 as SysQty,  
U.UomId UomId2,U.UomCode UomDescription2,0 as OrderQty FROM Product P,UomMaster U,UomGroup UG,ProductCategoryValue PCV (NOLOCK),
Fn_ReturnPrdMaxUom() MAXUOM  
WHERE P.UomGroupId = UG.UomGroupId AND UG.UomId = U.UomId AND P.UomGroupId=MAXUOM.UomGroupId AND UG.UomId=MAXUOM.UomId AND MAXUOM.PrdId=P.PrdId AND CmpId = vFParam and SpmId =vSParam AND PrdStatus = 1 
AND PrdType<> 3   AND P.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=26 
AND B.PrdSeqId=C.PrdSeqId)  AND P.PrdCtgValMainId=PCV.PrdCtgValMainId   
AND PCV.PrdCtgValLinkCode LIKE ''vTParam%'') A  ORDER BY PrdSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId=570
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 570,'Purchase Order','Product without Supplier','select','
SELECT PrdSeqDtId,PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,UomId,UomDescription,SysQty,UomId2,UomDescription2,OrderQty   FROM
(SELECT Distinct C.PrdSeqDtId,P.PrdId,P.PrdDCode,P.PrdCCode,P.PrdName,P.PrdShrtName,U.UomId,U.UomCode UomDescription,  0 as SysQty,U.UomId UomId2,
U.UomCode UomDescription2,  0 as OrderQty FROM Product P, UomMaster U ,   UomGroup UG,ProductSequence B WITH (NOLOCK),    
ProductSeqDetails C WITH (NOLOCK),ProductCategoryValue PCV (NOLOCK),Fn_ReturnPrdMaxUom() MAXUOM  
WHERE P.UomGroupId = UG.UomGroupId  and UG.UomId = U.UomId AND P.UomGroupId=MAXUOM.UomGroupId AND UG.UomId=MAXUOM.UomId AND MAXUOM.PrdId=P.PrdId   and  
CmpId = vFParam    and B.TransactionId = 26    AND P.PrdStatus=1 AND P.PrdType <> 3 AND B.PrdSeqId = C.PrdSeqId   AND P.PrdId = C.PrdId    
AND P.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.PrdCtgValLinkCode LIKE ''vSParam%''     Union      
SELECT Distinct 100000 AS PrdSeqDtId,P.PrdId,P.PrdDCode,P.PrdCCode,P.PrdName,P.PrdShrtName,U.UomId,U.UomCode UomDescription,0 as SysQty,U.UomId UomId2,  
U.UomCode UomDescription2,0 as OrderQty    FROM Product P, UomMaster U , UomGroup UG,  ProductCategoryValue PCV (NOLOCK),Fn_ReturnPrdMaxUom() MAXUOM     
WHERE P.UomGroupId = UG.UomGroupId  and UG.UomId = U.UomId  AND P.UomGroupId=MAXUOM.UomGroupId AND UG.UomId=MAXUOM.UomId AND MAXUOM.PrdId=P.PrdId   and  CmpId = vFParam   and PrdStatus = 1 and PrdType<> 3 and P.PrdId NOT IN  
( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),    ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=26 AND B.PrdSeqId=C.PrdSeqId)     
AND P.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.PrdCtgValLinkCode LIKE ''vSParam%'') a  ORDER BY PrdSeqDtId'
GO
DELETE FROM HotSearchEditorHd WHERE FormId=567
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 567,'Purchase Order','Product without Norm','Select','
SELECT PrdSeqDtId,PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,UomId,UomDescription,SysQty,UomId2,UomDescription2,OrderQty   FROM
(  SELECT 0 PrdSeqDtId,PO.PrdId,P.PrdDCode,PO.PrdCCode,PO.PrdName,P.PrdShrtName,PO.UomId,MAXUOM.UomCode UomDescription,PO.SysQty,PO.UomId2,    
MAXUOM.UomCode UomDescription2, PO.[Order Qty] as ''OrderQty''  FROM ProductOrd PO,Product P,ProductCategoryValue PCV,Fn_ReturnPrdMaxUom() MAXUOM      
WHERE PO.PrdId=P.PrdId AND P.PrdCtgValMainId=PCV.PrdCtgValMainId AND  MAXUOM.UomDesc=PO.UomDescription2 AND PO.PrdId=MAXUOM.PrdId   AND  PCV.PrdCtgValLinkCode LIKE ''vFParam%'') A'
GO
DELETE FROM HotSearchEditorHd WHERE FormId=568
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 568,'Purchase Order','Product with Norm','Select','
SELECT PrdSeqDtId,PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,UomId,UomDescription,SysQty,UomId2,UomDescription2,OrderQty   FROM
(SELECT 0 PrdSeqDtId,PO.PrdId,P.PrdDCode,PO.PrdCCode,PO.PrdName,P.PrdShrtName,PO.UomId,MAXUOM.UomCode UomDescription,PO.SysQty,PO.UomId2,  
MAXUOM.UomCode UomDescription2,PO.SysQty as ''OrderQty'' FROM ProductOrd PO,Product P,ProductCategoryValue PCV,Fn_ReturnPrdMaxUom() MAXUOM  
WHERE PO.PrdId=P.PrdId AND P.PrdCtgValMainId=PCV.PrdCtgValMainId AND  MAXUOM.UomDesc=PO.UomDescription2 AND PO.PrdId=MAXUOM.PrdId AND PCV.PrdCtgValLinkCode LIKE ''vFParam%'')a'
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE='P' AND name='Proc_ProductNormCalc')
DROP PROCEDURE Proc_ProductNormCalc
GO
--EXEC Proc_ProductNormCalc 1,0
CREATE  Procedure [dbo].[Proc_ProductNormCalc]
(
	@Pi_CmpId INT,
	@Pi_SpmId INT,
	@Pi_ReduceStkInHand	INT
)
AS
BEGIN
	DECLARE @PStatus INT
	DECLARE @PCond VARCHAR(50)
	DECLARE @PFromDt DateTime
	DECLARE @PToDt DateTime
	DECLARE @SStatus INT
	DECLARE @SCond VARCHAR(50)
	DECLARE @SFromDt DateTime
	DECLARE @SToDt DateTime
	DECLARE @POStatus INT
	DECLARE @POCond VARCHAR(50)
	DECLARE @POFromDt DateTime
	DECLARE @POToDt DateTime
	DECLARE @PDStatus INT
	DECLARE @PDCond INT
	DECLARE @PDFromDt DateTime
	DECLARE @PDToDt DateTime
	DECLARE @SDStatus INT
	DECLARE @SDCond INT
	DECLARE @SDFromDt DateTime
	DECLARE @SDToDt DateTime
	DECLARE @PODStatus INT
	DECLARE @PODCond INT
	DECLARE @PODFromDt DateTime
	DECLARE @PODToDt DateTime


	TRUNCATE TABLE ProductOrd

	-- Delete Temp table
	if exists (SELECT * from dbo.sysobjects where id = object_id(N'[TempNorm]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [TempNorm]
	if exists (SELECT * from dbo.sysobjects where id = object_id(N'[TempQty]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [TempQty]
	if exists (SELECT * from dbo.sysobjects where id = object_id(N'[PrdOrderQty]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [PrdOrderQty]
	if exists (SELECT * from dbo.sysobjects where id = object_id(N'[UOMHave]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [UOMHave]
	if exists (SELECT * from dbo.sysobjects where id = object_id(N'[UOMNotHave]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [UOMNotHave]
	if exists (SELECT * from dbo.sysobjects where id = object_id(N'[ProductOrdWithoutBatch]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [ProductOrdWithoutBatch]

	if exists (SELECT * from dbo.sysobjects where id = object_id(N'[PrdBatRate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [PrdBatRate]

	if exists (SELECT * from dbo.sysobjects where id = object_id(N'[ProductStock]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [ProductStock]

	-- SELECT Configuration Values
	SELECT @PStatus = Status ,@PCond = Condition FROM Configuration WHERE ModuleName Like 'Purchase Order' and ModuleId in ('PO7')
	IF @PStatus = 1
	BEGIN
		SET @PFromDt = Convert(DateTime,SubString(@PCond , 1 , 10),103)
		SET @PToDt = Convert(DateTime,SubString(@PCond , 12,21 ),103)
	END
	ELSE
	BEGIN
		SET @PFromDt = Convert(DateTime,'',103)
		SET @PToDt = Convert(DateTime,'',103)
	END

	SELECT @SStatus = Status ,@SCond = Condition FROM Configuration WHERE ModuleName Like 'Purchase Order' and ModuleId in ('PO8')
	IF @SStatus = 1
	BEGIN
		SET @SFromDt = Convert(DateTime,SubString(@SCond , 1 , 10),103)
		SET @SToDt = Convert(DateTime,SubString(@SCond , 12,21 ),103)
	END
	ELSE
	BEGIN
		SET @SFromDt = Convert(DateTime,'',103)
		SET @SToDt = Convert(DateTime,'',103)
	END

	SELECT @POStatus = Status ,@POCond = Condition FROM Configuration WHERE ModuleName Like 'Purchase Order' and ModuleId in ('PO9')
	IF @POStatus = 1
	BEGIN
		SET @POFromDt = Convert(DateTime,SubString(@POCond , 1 , 10),103)
		SET @POToDt = Convert(DateTime,SubString(@POCond , 12,21 ),103)
	END
	ELSE
	BEGIN
		SET @POFromDt = Convert(DateTime,'',103)
		SET @POToDt = Convert(DateTime,'',103)
	END

	SELECT @PDStatus = Status ,@PDCond = Condition FROM Configuration WHERE ModuleName Like 'Purchase Order' and ModuleId in ('PO10')
	IF @PDStatus = 1
	BEGIN
		SET @PDFromDt = DateAdd( d,@PDCond * -1,getDate())
		SET @PDToDt = getDate()
	END
	ELSE
	BEGIN
		SET @PDFromDt = Convert(DateTime,'',103)
		SET @PDToDt = Convert(DateTime,'',103)
	END

	SELECT @SDStatus = Status ,@SDCond = Condition FROM Configuration WHERE ModuleName Like 'Purchase Order' and ModuleId in ('PO11')
	IF @SDStatus = 1
	BEGIN
		SET @SDFromDt = DateAdd( d,@SDCond * -1,getDate())
		SET @SDToDt = getDate()
	END
	ELSE
	BEGIN
		SET @SDFromDt = Convert(DateTime,'',103)
		SET @SDToDt = Convert(DateTime,'',103)
	END

	SELECT @PODStatus = Status ,@PODCond = Condition FROM Configuration WHERE ModuleName Like 'Purchase Order' and ModuleId in ('PO12')
	IF @PODStatus = 1
	BEGIN
		SET @PODFromDt = DateAdd( d,@PODCond * -1,getDate())
		SET @PODToDt = getDate()
	END
	ELSE
	BEGIN
		SET @PODFromDt = Convert(DateTime,'',103)
		SET @PODToDt = Convert(DateTime,'',103)
	END

	-- Norm detail
	SELECT PN.PrdId,Pn.UomId,PN.VariationId,PN.NormId,
	CASE PN.VariationPerc WHEN 0 THEN PN.Qty ELSE PN.VariationPerc END Qty,
	CASE PN.VariationPerc WHEN 0 THEN 'Qty' ELSE 'Perc' END Mode
	INTO TempNorm
	FROM
	POPrdNormMappingDt PN
	WHERE
	PN.POPrdNormId in (SELECT MAX(POPrdNormId) FROM POPrdNormMappingHd
	WHERE CmpId = @Pi_CmpId)
	-- Get previous Qty

	SELECT
	P.PrdId ,
	ISNULL(LYSMS.BaseQty,0) 'Norm1' ,
	ISNULL(LYSMP.BaseQty,0) 'Norm2' ,
	ISNULL(LYSMPO.BaseQty,0) 'Norm3' ,
	ISNULL(LMS.BaseQty,0) 'Norm4',
	ISNULL(LMP.BaseQty,0) 'Norm5',
	ISNULL(LMPO.BaseQty,0) 'Norm6',
	ISNULL(LP.BaseQty,0) 'Norm7',
	ISNULL(LPO.BaseQty,0) 'Norm8',
	ISNULL(LTMS.BaseQty,0) 'Norm9',
	ISNULL(LTMP.BaseQty,0) 'Norm10',
	ISNULL(LTMPO.BaseQty,0) 'Norm11',
	ISNULL(LTMSA.BaseQty,0) 'Norm12',
	ISNULL(LTMPA.BaseQty,0) 'Norm13',
	ISNULL(LTMPOA.BaseQty,0) 'Norm14',
	ISNULL(SDP.BaseQty,0) 'Norm16',
	ISNULL(PDP.BaseQty,0) 'Norm17',
	ISNULL(PODP.BaseQty,0) 'Norm18',
	ISNULL(SDD.BaseQty,0) 'Norm19',
	ISNULL(PDD.BaseQty,0) 'Norm20',
	ISNULL(PODD.BaseQty,0) 'Norm21'
	INTO TempQty
	FROM
	Product P
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(BaseQty) BaseQty FROM SalesInvoiceProduct SP
	WHERE SalId in (SELECT SalId FROM SalesInvoice
	WHERE Month(SalInvDate) = Month(getDate()) and
	Year(SalInvDate) = CAST(YEAR(GETDATE()) AS INT)-1) Group By PrdId) LYSMS
	ON P.PrdId = LYSMS.PrdId --1
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(InvBaseQty) BaseQty FROM PurchaseReceiptProduct PR
	WHERE PurRcptId in (SELECT PurRcptId FROM PurchaseReceipt
	WHERE Month(InvDate) = Month(getDate()) and
	Year(InvDate) = CAST(YEAR(GETDATE()) AS INT)-1) Group By PrdId) LYSMP
	ON P.PrdId = LYSMP.PrdId --2
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(OrdQty) BaseQty FROM PurchaseOrderDetails PO
	WHERE PurOrderRefNo in (SELECT PurOrderRefNo FROM PurchaseOrderMaster
	WHERE Month(PurOrderDate) = Month(getDate()) and
	Year(PurOrderDate) = CAST(YEAR(GETDATE()) AS INT)-1) Group By PrdId) LYSMPO
	ON P.PrdId = LYSMPO.PrdId --3
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(BaseQty) BaseQty FROM SalesInvoiceProduct SP
	WHERE SalId in (SELECT SalId FROM SalesInvoice
	WHERE Month(SalInvDate) = Month(getDate())-1 and
	Year(SalInvDate) = CAST(YEAR(GETDATE()) AS INT)) Group By PrdId) LMS
	ON P.PrdId = LMS.PrdId -- 4
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(InvBaseQty) BaseQty FROM PurchaseReceiptProduct PR
	WHERE PurRcptId in (SELECT PurRcptId FROM PurchaseReceipt
	WHERE Month(InvDate) = Month(getDate())-1 and
	Year(InvDate) = CAST(YEAR(GETDATE()) AS INT))
	Group By PrdId) LMP ON P.PrdId = LMP.PrdId -- 5
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(OrdQty) BaseQty FROM PurchaseOrderDetails PO
	WHERE PurOrderRefNo in (SELECT PurOrderRefNo FROM PurchaseOrderMaster
	WHERE Month(PurOrderDate) = Month(getDate())-1 and
	Year(PurOrderDate) = CAST(YEAR(GETDATE()) AS INT))
	Group By PrdId) LMPO ON P.PrdId = LMPO.PrdId -- 6
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(InvBaseQty) BaseQty FROM PurchaseReceiptProduct PR
	WHERE PurRcptId in (SELECT MAX(PurRcptId) FROM PurchaseReceipt)
	Group By PrdId) LP ON P.PrdId = LP.PrdId -- 7
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(OrdQty) BaseQty FROM PurchaseOrderDetails PO
	WHERE PurOrderRefNo in (SELECT MAX(PurOrderRefNo) FROM PurchaseOrderMaster)
	Group By PrdId) LPO ON P.PrdId = LPO.PrdId -- 8
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(BaseQty) BaseQty FROM SalesInvoiceProduct SP
	WHERE SalId in (SELECT SalId FROM SalesInvoice
	WHERE SalInvDate Between DATEADD(M,-3,getdate()) and (getDate()-1))
	Group By PrdId) LTMS ON P.PrdId = LTMS.PrdId -- 9
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(InvBaseQty) BaseQty FROM PurchaseReceiptProduct PR
	WHERE PurRcptId in (SELECT PurRcptId FROM PurchaseReceipt
	WHERE InvDate Between DATEADD(M,-3,getdate()) and (getDate()-1))
	Group By PrdId) LTMP ON P.PrdId = LTMP.PrdId -- 10
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(OrdQty) BaseQty FROM PurchaseOrderDetails PO
	WHERE PurOrderRefNo in (SELECT PurOrderRefNo FROM PurchaseOrderMaster
	WHERE PurOrderDate Between DATEADD(M,-3,getdate()) and (getDate()-1))
	Group By PrdId) LTMPO ON P.PrdId = LTMPO.PrdId -- 11
	LEFT OUTER JOIN
	(SELECT PrdId,Round(Sum(BaseQty)/Count(BaseQty),0) BaseQty FROM SalesInvoiceProduct SP
	WHERE SalId in (SELECT SalId FROM SalesInvoice
	WHERE SalInvDate Between DATEADD(M,-3,getdate()) and (getDate()-1))
	Group By PrdId) LTMSA ON P.PrdId = LTMSA.PrdId -- 12
	LEFT OUTER JOIN
	(SELECT PrdId,Round(Sum(InvBaseQty)/Count(InvBaseQty),0) BaseQty FROM PurchaseReceiptProduct PR
	WHERE PurRcptId in (SELECT PurRcptId FROM PurchaseReceipt
	WHERE InvDate Between DATEADD(M,-3,getdate()) and (getDate()-1))
	Group By PrdId) LTMPA ON P.PrdId = LTMPA.PrdId -- 13
	LEFT OUTER JOIN
	(SELECT PrdId,Round(Sum(OrdQty)/Count(OrdQty),0) BaseQty FROM PurchaseOrderDetails PO
	WHERE PurOrderRefNo in (SELECT PurOrderRefNo FROM PurchaseOrderMaster
	WHERE PurOrderDate Between DATEADD(M,-3,getdate()) and (getDate()-1))
	Group By PrdId) LTMPOA ON P.PrdId = LTMPOA.PrdId -- 14
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(BaseQty) BaseQty FROM SalesInvoiceProduct SP
	WHERE SalId in (SELECT SalId FROM SalesInvoice
	WHERE SalInvDate Between @SFromDt and @SToDt )
	Group By PrdId) SDP ON P.PrdId = SDP.PrdId -- 16
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(InvBaseQty) BaseQty FROM PurchaseReceiptProduct PR
	WHERE PurRcptId in (SELECT PurRcptId FROM PurchaseReceipt
	WHERE InvDate Between @PFromDt and @PToDt )
	Group By PrdId) PDP ON P.PrdId = PDP.PrdId -- 17
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(OrdQty) BaseQty FROM PurchaseOrderDetails PO
	WHERE PurOrderRefNo in (SELECT PurOrderRefNo FROM PurchaseOrderMaster
	WHERE PurOrderDate Between @POFromDt and @POToDt )
	Group By PrdId) PODP ON P.PrdId = PODP.PrdId -- 18
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(BaseQty) BaseQty FROM SalesInvoiceProduct SP
	WHERE SalId in (SELECT SalId FROM SalesInvoice
	WHERE SalInvDate Between @SDFromDt and @SDToDt )
	Group By PrdId) SDD ON P.PrdId = SDD.PrdId -- 19
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(InvBaseQty) BaseQty FROM PurchaseReceiptProduct PR
	WHERE PurRcptId in (SELECT PurRcptId FROM PurchaseReceipt
	WHERE InvDate Between @PDFromDt and @PDToDt )
	Group By PrdId) PDD ON P.PrdId = PDD.PrdId -- 20
	LEFT OUTER JOIN
	(SELECT PrdId,Sum(OrdQty) BaseQty FROM PurchaseOrderDetails PO
	WHERE PurOrderRefNo in (SELECT PurOrderRefNo FROM PurchaseOrderMaster
	WHERE PurOrderDate Between @PODFromDt and @PODToDt )
	Group By PrdId) PODD ON P.PrdId = PODD.PrdId -- 21
	WHERE P.CmpId = @Pi_CmpId  and P.SpmId = CASE @Pi_SpmId WHEN 0 THEN P.SpmId else @Pi_SpmId END

	--Final
	SELECT
	TN.PrdId,TN.UOMId,TN.VariationId,
	TN.NormId,
	CASE TN.NormId WHEN 1 THEN TQ.Norm1 WHEN 2 THEN TQ.Norm2
	WHEN 3 THEN TQ.Norm3 WHEN 4 THEN TQ.Norm4
	WHEN 5 THEN TQ.Norm5 WHEN 6 THEN TQ.Norm6
	WHEN 7 THEN TQ.Norm7 WHEN 8 THEN TQ.Norm8
	WHEN 9 THEN TQ.Norm9 WHEN 10 THEN TQ.Norm10
	WHEN 11 THEN TQ.Norm11 WHEN 12 THEN TQ.Norm12
	WHEN 13 THEN TQ.Norm13 WHEN 14 THEN TQ.Norm14
	WHEN 16 THEN TQ.Norm16 WHEN 17 THEN TQ.Norm17
	WHEN 18 THEN TQ.Norm18 WHEN 19 THEN TQ.Norm19
	WHEN 20 THEN TQ.Norm20 WHEN 21 THEN TQ.Norm21
	END BaseQty,
	TN.Qty,TN.Mode
	INTO
	PrdOrderQty
	FROM
	TempNorm TN,TempQty TQ
	WHERE
	TN.PrdId = TQ.PrdId
	SELECT * INTO UOMHave FROM PrdOrderQty WHERE UOMId > 0
	SELECT * INTO UOMNotHave FROM PrdOrderQty WHERE UOMId = 0

	SELECT Prd.* INTO ProductOrdWithoutBatch
	FROM (
	SELECT
	P.PrdId,Pt.PrdcCode,Pt.PrdName,P.UomId,UOM.UomDescription,
	CASE P.VariationId WHEN 1 THEN
	CASE P.Mode WHEN 'Perc' THEN CASE Sign(P.BaseQty + (P.BaseQty * (P.Qty/100))) WHEN -1 THEN 0 Else P.BaseQty + (P.BaseQty * (P.Qty/100)) END  Else CASE Sign(P.BaseQty + P.Qty) WHEN -1  THEN 0 Else P.BaseQty + P.Qty END END --'SysQty',
	WHEN 2 THEN
	CASE P.Mode WHEN 'Perc' THEN CASE Sign(P.BaseQty - (P.BaseQty * (P.Qty/100))) WHEN -1 THEN 0 Else P.BaseQty - (P.BaseQty * (P.Qty/100)) END  Else CASE Sign(P.BaseQty - P.Qty) WHEN -1  THEN 0 Else P.BaseQty - P.Qty END END
	WHEN 0 THEN
	CASE P.Mode WHEN 'Perc' THEN CASE Sign(P.BaseQty + (P.BaseQty * (P.Qty/100))) WHEN -1 THEN 0 Else P.BaseQty + (P.BaseQty * (P.Qty/100)) END  Else CASE Sign(P.BaseQty + P.Qty) WHEN -1  THEN 0 Else P.BaseQty + P.Qty END END --'SysQty',
	END 'SysQty',
	P.UomId UomId2,UOM.UomDescription UomDescription2,0 as 'OrderQty'
	FROM
	UOMHave P,Product Pt ,UOMMaster UOM
	WHERE
	P.PrdId= Pt.PrdId
	and P.UomId = UOM.UomId
	UNION
	SELECT
	P.PrdId,Pt.PrdcCode,Pt.PrdName,X.UomId,X.UomDescription,
	CASE P.VariationId WHEN 1 THEN
	CASE P.Mode WHEN 'Perc' THEN CASE Sign(P.BaseQty + (P.BaseQty * (P.Qty/100))) WHEN -1 THEN 0 Else P.BaseQty + (P.BaseQty * (P.Qty/100)) END  Else CASE Sign(P.BaseQty + P.Qty) WHEN -1  THEN 0 Else P.BaseQty + P.Qty END END --'SysQty',
	WHEN 2 THEN
	CASE P.Mode WHEN 'Perc' THEN CASE Sign(P.BaseQty - (P.BaseQty * (P.Qty/100))) WHEN -1 THEN 0 Else P.BaseQty - (P.BaseQty * (P.Qty/100)) END  Else CASE Sign(P.BaseQty - P.Qty) WHEN -1  THEN 0 Else P.BaseQty - P.Qty END END
	WHEN 0 THEN
	CASE P.Mode WHEN 'Perc' THEN CASE Sign(P.BaseQty + (P.BaseQty * (P.Qty/100))) WHEN -1 THEN 0 Else P.BaseQty + (P.BaseQty * (P.Qty/100)) END  Else CASE Sign(P.BaseQty + P.Qty) WHEN -1  THEN 0 Else P.BaseQty + P.Qty END END --'SysQty',
	END 'SysQty',
	X.UomId UomId2,X.UomDescription UomDescription2,0 as 'OrderQty'
	FROM
	UOMNotHave P,Product Pt ,
	(SELECT P.PrdId,g.UomgroupId,g.UomId,u.UomDescription
	from product P,Uomgroup g,uommaster u
	where
	p.UomGroupId = g.UomGroupId
	--and g.BaseUom = 'Y'
	and g.uomid = u.uomid) X
	WHERE
	P.PrdId= Pt.PrdId
	and P.PrdId = X.PrdId ) Prd

	--SELECT * FROM ProductOrdWithoutBatch	

	IF (SELECT COUNT(*) FROM ProductOrdWithoutBatch)=0
	BEGIN
		INSERT INTO ProductOrdWithoutBatch
		SELECT Prd.PrdId,Prd.PrdCCode,Prd.PrdName,UG.UOMId,U.UOMDescription,0,UG.UOMId,U.UOMDescription,0  FROM Product Prd(NOLOCK),UOMGroup UG(NOLOCK),UOMMaster U
		WHERE Prd.UOMGroupId=UG.UOMGroupId AND UG.UOMId=U.UOMId --AND UG.BaseUOM='Y'
		AND Prd.PrdStatus=1 AND Prd.CmpId=@Pi_CmpId
	END

	SELECT PO.PrdId,ISNULL(MAX(PB.PrdBatId),0) AS PrdBatId,0 AS PriceId,0.000000 AS Rate
	INTO PrdBatRate
	FROM ProductOrdWithoutBatch PO
	LEFT OUTER JOIN ProductBatch PB ON PO.PrdId=PB.PrdId 	
	GROUP BY PO.PrdId
	ORDER BY PO.PrdId

	ALTER TABLE PrdBatRate
	ALTER COLUMN Rate NUMERIC(38,6)

	UPDATE PrdBatRate SET PrdBatRate.Rate= PBD.PrdBatDetailValue,PrdBatRate.PriceId= PBD.PriceId
	FROM ProductBatchDetails PBD,BatchCreation BC 
	WHERE PrdBatRate.PrdBatId=PBD.PrdbatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND
	BC.ListPrice=1 AND BC.BatchSeqId=PBD.BatchSeqId

	INSERT INTO ProductOrd(PrdId,PrdcCode,PrdName,UomId,UomDescription,SysQty,UomId2,UomDescription2,[Order Qty],PrdBatId,PrdBatCode,PriceId,PurRate,Amount)
	SELECT PO.PrdId,PO.PrdCCode,PO.PrdName,PO.UomId,PO.UomDescription,PO.SysQty,PO.UomId2,PO.UomDescription2,PO.[OrderQty],
	ISNULL(PR.PrdBatId,0),ISNULL(PB.PrdBatCode,''),ISNULL(PR.PriceId,0),ISNULL(PR.Rate,0),0 
	FROM ProductOrdWithoutBatch PO
	LEFT OUTER JOIN PrdBatRate PR ON PO.PrdId=PR.PrdId
	LEFT OUTER JOIN ProductBatch PB ON PB.PrdBatId=PR.PrdBatId 
	ORDER BY PO.PrdId,PO.PrdCCode,PB.PrdBatCode

	IF @Pi_ReduceStkInHand=1 
	BEGIN
		SELECT PrdId,SUM((PrdbatLcnSih-PrdbatLcnResSih)) AS StkAvl
		INTO ProductStock
		FROM ProductBatchLocation
		GROUP BY PrdId
		
		UPDATE ProductOrd SET ProductOrd.[Order Qty]=ProductOrd.[Order Qty]-PS.StkAvl,
		ProductOrd.SysQty=ProductOrd.SysQty-PS.StkAvl
		FROM ProductStock PS WHERE ProductOrd.PrdId=PS.PrdId
	END

	UPDATE ProductOrd SET [Order Qty]=0 WHERE [Order Qty]<0
	UPDATE ProductOrd SET SysQty=0 WHERE SysQty<0

	UPDATE ProductOrd SET Amount=[Order Qty]*PurRate
END
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10106
INSERT INTO HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10106,'Special rate','SplrateRefNo','Select','SELECT * FROM Distributor Where DistributorCode='''''
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE Xtype='P' AND name='Proc_ValidateStockTransfer')
DROP PROCEDURE Proc_ValidateStockTransfer
GO
--    begin transaction SA
--    exec Proc_ValidateStockTransfer 0
--    rollback transaction SA
CREATE PROCEDURE [dbo].[Proc_ValidateStockTransfer]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_ValidateStockTransfer
* PURPOSE: To Insert and Update records
* CREATED: Boopathy.P on 18/09/2007
*********************************/
--EXCEL IMPORT STOCK MANAGEMENT TYPE ADDED BY PRAVEENRAJ B ON 31-01-2014
SET NOCOUNT ON
BEGIN
	DECLARE @ErrDesc AS VARCHAR(1000)
	DECLARE @rno AS INT
	DECLARE @TabName AS VARCHAR(50)
	DECLARE @DocRefNo As VARCHAR(100)
	DECLARE @TransType As VARCHAR(50)
	DECLARE @PrdCode As VARCHAR(50)
	DECLARE @PrdBat As VARCHAR(50)
	DECLARE @StkType AS VARCHAR(50)
	DECLARE @LocCode AS VARCHAR(50)
	DECLARE @UomCode AS VARCHAR(50)
	DECLARE @Qty AS VARCHAR(20)
	DECLARE @Po_StkPosting INT
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @PriceId AS INT
	DECLARE @LcnId AS INT
	DECLARE @UomId AS INT
	DECLARE @StkId AS INT
	DECLARE @StkTypeId AS INT
	DECLARE @StockLegdStkTypeId AS INT
	DECLARE @GetKey AS VARCHAR(20)
	DECLARE @Taction AS INT
	DECLARE @TransId AS INT
	DECLARE @SelRte AS NUMERIC(18,6)
	DECLARE @Amount AS NUMERIC(18,2)
	DECLARE @Pi_Date DATETIME
	DECLARE @sSQL AS VARCHAR(4000)
	DECLARE @TypeDesc AS NVARCHAR(10)
	DECLARE @Type AS INT
	DECLARE @ChkDate AS DATETIME
	DECLARE @iCnt AS INT
	DECLARE @iOpnDebit AS NUMERIC(18,2)
	DECLARE @iOpnCredit AS NUMERIC(18,2)
	DECLARE @ErrStatus		INT
	DECLARE @iVocDate	NVARCHAR(10)
	
	DECLARE @StkMgmtTypeId INT
	
	SET @iVocDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	SET @TabName = 'ETL_Prk_StockTransfer'

	DECLARE Cur_StkTransHd CURSOR
	FOR SELECT DISTINCT ISNULL([Location],'') AS [Location],ISNULL([Trans Type],''),
		ISNULL([Document Reference Number],'')AS [Reference Number],ISNULL([Type],'') AS [Type]
		FROM ETL_Prk_StockTransfer Order By [Location]
	OPEN Cur_StkTransHd
	FETCH NEXT FROM Cur_StkTransHd INTO @LocCode,@TransType,@DocRefNo,@TypeDesc
	SET @Rno = 0
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Taction = 2

		IF LTRIM(RTRIM(@LocCode))= ''
		BEGIN
			SET @ErrDesc = 'Location should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Location',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END

		IF LTRIM(RTRIM(@TransType))= ''
		BEGIN
			SET @ErrDesc = 'Transaction Type should not be blank'
			INSERT INTO Errorlog VALUES (2,@TabName,'Transaction Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END

		IF LTRIM(RTRIM(@Type))= ''
		BEGIN
			SET @ErrDesc = 'Type should not be blank'
			INSERT INTO Errorlog VALUES (3,@TabName,'Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		
		IF @TypeDesc= '0'
			SET @Type=0
		ELSE IF @TypeDesc= '1'
			SET @Type=1

		IF LTRIM(RTRIM(@TransType)) = 'REDUCE'
			SET @TransId=1
		ELSE IF LTRIM(RTRIM(@TransType)) = 'ADD'
			SET @TransId=0

		IF NOT EXISTS(SELECT StkMgmtTypeId FROM StockManagementType WHERE TransactionType=@TransId)
		BEGIN
			SET @ErrDesc = 'Transaction Not Found'
			INSERT INTO Errorlog VALUES (4,@TabName,'Transaction',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
			SET @TransId=0
		END
		ELSE
		BEGIN
			SELECT @TransId=StkMgmtTypeId FROM StockManagementType WHERE TransactionType=@TransId
		END

		IF NOT EXISTS(SELECT LcnId FROM Location WHERE LcnCode=@LocCode)
		BEGIN
			SET @ErrDesc = 'Location Not Found'
			INSERT INTO Errorlog VALUES (5,@TabName,'Location',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
			SET @TransId=0
		END
		ELSE
		BEGIN
			SELECT @LcnId=LcnId FROM Location WHERE LcnCode=@LocCode
		END

		SELECT @GetKey= dbo.Fn_GetPrimaryKeyString('StockManagement','StkMngRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
		IF @Taction = 2
		BEGIN
			INSERT INTO StockManagement(StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,DecPoints,Availability,LAstModBy,LastModDate,AuthId,AuthDate,OpenBal,Status)
			VALUES(@GetKey,convert(varchar(10),getdate(),121),@LcnId,@TransId,0,0,@DocRefNo,'',4,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@Type,1)
			SET @sSQL ='INSERT INTO StockManagement(StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,DecPoints,Availability,LAstModBy,LastModDate,AuthId,AuthDate,OpenBal) VALUES(''' +
					CAST(@GetKey AS VARCHAR(50)) + ''',''' + convert(varchar(10),getdate(),121) + ''',' + CAST(@LcnId AS VARCHAR(10)) + ',' +
					CAST(@TransId AS VARCHAR(10)) + ',0,0,''' + CAST(@DocRefNo AS VARCHAR(50)) + ''','''',4,1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',' + CAST(@Type AS VARCHAR(10)) + ',1)'
			INSERT INTO Translog(strSql1) Values (@sSQL)
			UPDATE counters SET currvalue = currvalue+1  WHERE tabname = 'StockManagement' and fldname = 'StkMngRefNo'
			SET @sSQL ='UPDATE counters SET currvalue = currvalue+1  WHERE tabname = ''StockManagement'' and fldname = ''StkMngRefNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			IF @Po_ErrNo =1
				SET @Po_ErrNo =1
			ELSE
				SET @Po_ErrNo =0
		END

		DECLARE  Cur_StkTransDt CURSOR
		FOR SELECT [Product Code],[Batch Code],[System Stock Type],[Uom Code],[Qty]
		FROM ETL_Prk_StockTransfer WHERE [Trans Type] = @TransType AND [Location]=@LocCode
		ORDER BY [Product Code],[Batch Code],[Location]
		OPEN Cur_StkTransDt

		FETCH NEXT FROM Cur_StkTransDt INTO @PrdCode,@PrdBat,@StkType,@UomCode,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
			IF LTRIM(RTRIM(@PrdCode))= ''
			BEGIN
				SET @ErrDesc = 'Product should not be blank'
				INSERT INTO Errorlog VALUES (7,@TabName,'Product',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END

			IF LTRIM(RTRIM(@PrdBat))= ''
			BEGIN
				SET @ErrDesc = 'Product Batch should not be blank'
				INSERT INTO Errorlog VALUES (7,@TabName,'Product Batch',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END			

			IF LTRIM(RTRIM(@StkType))= ''
			BEGIN
				SET @ErrDesc = 'System Stock Type should not be blank'
				INSERT INTO Errorlog VALUES (7,@TabName,'System Stock Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END

			IF LTRIM(RTRIM(@UomCode))= ''
			BEGIN
				SET @ErrDesc = 'Uom Code should not be blank'
				INSERT INTO Errorlog VALUES (7,@TabName,'Uom Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END

			IF LTRIM(RTRIM(@Qty))= ''
			BEGIN
				SET @ErrDesc = 'Quantity should not be blank'
				INSERT INTO Errorlog VALUES (7,@TabName,'Quantity',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END

			IF ISNUMERIC(LTRIM(RTRIM(@Qty)))= 0
			BEGIN
				SET @ErrDesc = 'Quantity should be numeric'
				INSERT INTO Errorlog VALUES (7,@TabName,'Quantity',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END

			IF LTRIM(RTRIM(@Qty))<= 0
			BEGIN
				SET @ErrDesc = 'Quantity should be greater than Zero'
				INSERT INTO Errorlog VALUES (7,@TabName,'Quantity',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			IF @TransType='ADD'
			BEGIN
				SELECT @StkMgmtTypeId=ISNULL(StkMgmtTypeId,0) FROM StockManagementType WHERE Description='IRA Adjustment In'
			END
			ELSE IF @TransType='REDUCE'
			BEGIN
				SELECT @StkMgmtTypeId=ISNULL(StkMgmtTypeId,0) FROM StockManagementType WHERE Description='IRA Adjustment Out'
			END
			IF ISNULL(@StkMgmtTypeId,0)=0
			BEGIN
				SET @ErrDesc = 'Trans Type Should ADD/REDUCE'
				INSERT INTO Errorlog VALUES (7,@TabName,'Trans Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			IF @StkType='Saleable'
			BEGIN
			
				SET @StkTypeId =1
				IF @TransType='ADD'
					BEGIN
						
						SET @StockLegdStkTypeId=10
					END
				ELSE
					BEGIN
						SET @StockLegdStkTypeId=13
					END
			END	
			ELSE IF @StkType='Unsaleable'
			BEGIN
				SET @StkTypeId =2
				IF @TransType='ADD'
					BEGIN
						SET @StockLegdStkTypeId=11
					END
				ELSE
					BEGIN
						SET @StockLegdStkTypeId=14
					END
			END
			ELSE IF @StkType='Offer'
			BEGIN
				SET @StkTypeId =3
				IF @TransType='ADD'
					BEGIN
						SET @StockLegdStkTypeId=12
					END
				ELSE
					BEGIN
						SET @StockLegdStkTypeId=15
					END
			END

			IF NOT EXISTS(SELECT PrdId FROM Product WHERE PrdDCode=LTRIM(RTRIM(@PrdCode)) OR PrdCCode=LTRIM(RTRIM(@PrdCode)))
			BEGIN
				SET @ErrDesc = 'Product:'+@PrdCode+' Not Found'
				INSERT INTO Errorlog VALUES (8,@TabName,'Product',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
				SET @PrdId = 0
			END
			ELSE
			BEGIN
				SELECT @PrdId=PrdId FROM Product WHERE PrdDCode=LTRIM(RTRIM(@PrdCode)) OR PrdCCode=LTRIM(RTRIM(@PrdCode))
			END

			IF NOT EXISTS(SELECT PrdBatId FROM ProductBatch WHERE PrdBatCode=LTRIM(RTRIM(@PrdBat)))
			BEGIN
				SET @ErrDesc = 'Product Batch:'+@PrdBat+' Not Found For Product:'+@PrdCode
				INSERT INTO Errorlog VALUES (8,@TabName,'Product Batch',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
				SET @PrdId = 0
				SET @PrdBatId = 0
			END
			ELSE
			BEGIN
				SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdBatCode=LTRIM(RTRIM(@PrdBat)) AND PrdId=@PrdId
			END		
			
			SELECT @PriceId=PriceId FROM ProductBatchDetails WHERE DefaultPrice=1 AND PrdBatId=@PrdBatId AND SlNo=1
			
			
			IF NOT EXISTS(SELECT StockTypeId FROM StockType WHERE LcnId=@LcnId AND SystemStockType=@StkTypeId)
			BEGIN
				SET @ErrDesc = 'Stock Type Not Found'
				INSERT INTO Errorlog VALUES (8,@TabName,'Stock Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE
			BEGIN
				SELECT @StkId=StockTypeId FROM StockType WHERE LcnId=@LcnId AND SystemStockType=@StkTypeId
			END	
			
			IF NOT EXISTS(SELECT UomId FROM UomMaster WHERE UomCode=@UomCode)
			BEGIN
				SET @ErrDesc = 'Uom:'+@UomCode+' Not Found'
				INSERT INTO Errorlog VALUES (8,@TabName,'Uom',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE
			BEGIN
				SELECT @UomId=UomId FROM UomMaster WHERE UomCode=@UomCode
			END

			IF @PrdId <> 0 AND @PrdBatId <> 0 AND @PriceId <> 0
			BEGIN
				SELECT @SelRte=CONVERT(NUMERIC(18,2),C.PrdBatDetailValue) FROM ProductBatch A (NOLOCK)
				INNER JOIN ProductBatchDetails C (NOLOCK)ON A.PrdBatId = C.PrdBatID AND C.PriceId=@PriceId
				INNER JOIN Product P ON A.PrdId = P.PrdId
				INNER JOIN BatchCreation D (NOLOCK)
				ON D.BatchSeqId = C.BatchSeqId AND D.SlNo = C.SlNo
				AND D.SelRte = 1 WHERE P.PrdId = @PrdId AND A.PrdBatId = @PrdBatId
				SET @Amount = (CONVERT(NUMERIC(18,2),@SelRte) * CONVERT(INT,REPLACE(@Qty,'	','')))
			END
			ELSE
			BEGIN
				SET @ErrDesc = 'Selling Rate Not Found for Product:'+@PrdCode+' for Batch:'+@PrdBat
				INSERT INTO Errorlog VALUES (8,@TabName,'Selling Rate',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END

			--Added By Maha on 15/06/2009
			SET @iOpnDebit=0
			SET @iOpnCredit=0
			SELECT @iCnt=Count(CoaId) FROM COAOpeningBalance Where CoaId=291
			SELECT @iOpnDebit=ISNULL(OpeningDebit,0),@iOpnCredit=ISNULL(OpeningCredit,0) FROM COAOpeningBalance Where CoaId=74
			SET @iOpnDebit=@iOpnDebit+@Amount
			SET @iOpnCredit=@iOpnCredit
			IF @Type = 1	--Opening Balance
			BEGIN
				SELECT @ChkDate=ISNULL(MIN(TransDate),GETDATE())  FROM StockLedger WITH (NOLOCK)
				IF CONVERT(NVARCHAR(10),GETDATE(),121)=CONVERT(NVARCHAR(10),@ChkDate,121)
				BEGIN			
					IF @iCnt=0
					BEGIN
						INSERT INTO CoaOpeningBalance(CoaId,OpeningDebit,OpeningCredit,Availability,LastModBy,LastModDate,AuthId,AuthDate)
								VALUES(291,@iOpnDebit,@iOpnCredit,1,1,GETDATE(),1,GETDATE())
				
						SET @sSQL = 'INSERT INTO CoaOpeningBalance (CoaId,OpeningDebit,OpeningCredit,Availability,LastModBy,LastModDate,AuthId,AuthDate)'
						SET @sSQL = @sSQL + ' VALUES(291,' + CAST(@iOpnDebit AS NVARCHAR(100))+ ',' + CAST(@iOpnCredit AS NVARCHAR(100))+ ',1,1,GETDATE(),1,GETDATE())'
						INSERT INTO Translog(strSql1) Values (@sSQL)
			
						SELECT * FROM CoaOpeningBalance
					END
					ELSE
					BEGIN
						UPDATE CoaOpeningBalance SET OpeningDebit=@iOpnDebit WHERE CoaId=291
					
						SET @sSQL='UPDATE CoaOpeningBalance SET OpeningDebit=' + CAST(@iOpnDebit AS NVARCHAR(100)) + ' WHERE CoaId=291'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END
				ELSE
				BEGIN
					SET @ErrDesc = 'Transaction Exists'
					INSERT INTO Errorlog VALUES (3,@TabName,'Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END	
			--Till Here

			IF @Taction =2
			BEGIN
				INSERT INTO StockManagementProduct(StkMngRefNo,PrdId,PrdBatId,PriceId,StockTypeId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,Availability,LastModBy,LastModDate,AuthId,AuthDate,TaxAmt,StkMgmtTypeId)
				VALUES (@GetKey,@PrdId,@PrdBatId,@PriceId,@StkId,@UomId,@Qty,0,0,@Qty,CONVERT(NUMERIC(18,2),@SelRte),@Amount,0,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),0,@StkMgmtTypeId)
				
				SET @sSQL ='INSERT INTO StockManagementProduct(StkMngRefNo,PrdId,PrdBatId,PriceId,StockTypeId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES(''' +
					   CAST(@GetKey AS VARCHAR(50)) + ''',' + CAST(@PrdId AS VARCHAR(10)) + ',' + CAST(@PrdBatId AS VARCHAR(10)) + ',' + CAST(@PriceId AS VARCHAR(10)) + ','+
							   CAST(@StkId AS VARCHAR(10)) + ',' +CAST(@UomId AS VARCHAR(10)) + ',' + CAST(@Qty AS VARCHAR(10)) +
							   ',0,0,' + CAST(@Qty AS VARCHAR(10)) + ',' + CAST(@SelRte AS VARCHAR(24)) + ',' + CAST(@Amount AS VARCHAR(24)) + ',0,1,1,''' +
							   convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
				INSERT INTO Translog(strSql1) Values (@sSQL)
				SET @Pi_Date = CONVERT(NVARCHAR(10),GETDATE(),121)
				Exec Proc_UpdateStockLedger @StockLegdStkTypeId,1,@PrdId,@PrdBatId,@LcnId,@Pi_Date,@Qty,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				SET @sSQL ='Exec Proc_UpdateStockLedger ' + CAST(@StockLegdStkTypeId AS VARCHAR(10)) + ',1,' + CAST(@PrdId AS VARCHAR(10)) + ',' + CAST(@PrdBatId AS VARCHAR(10)) + ',' + CAST(@LcnId AS VARCHAR(10)) + ',''' +
						CAST(@Pi_Date AS VARCHAR(20)) + ''',' + CAST(@Qty AS VARCHAR(10)) + ',1,' + CAST( @Po_StkPosting AS VARCHAR(10)) + ''
				INSERT INTO Translog(strSql1) Values (@sSQL)
				IF @Po_StkPosting = 1
				BEGIN
					 SET @ErrDesc = 'Stock Posting Error'
					 INSERT INTO Errorlog VALUES (8,@TabName,'Stock Posting Error',@ErrDesc)
					 SET @Taction = 0
					 SET @Po_ErrNo =1
				END

				IF @TransType='ADD'
				BEGIN
					Exec Proc_UpdateProductBatchLocation @StkTypeId,1,@PrdId,@PrdBatId,@LcnId,@Pi_Date,@Qty,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					SET @sSQL ='Exec Proc_UpdateProductBatchLocation ' + CAST(@StkTypeId AS VARCHAR(10)) + ',1,' + CAST(@PrdId AS VARCHAR(10)) + ',' +CAST(@PrdBatId AS VARCHAR(10)) + ',' + CAST(@LcnId AS VARCHAR(10)) + ',''' +
							CAST(@Pi_Date AS VARCHAR(20)) + ''',' + CAST(@Qty AS VARCHAR(10)) + ',1,' + CAST( @Po_StkPosting AS VARCHAR(10)) + ''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE
				BEGIN
					Exec Proc_UpdateProductBatchLocation @StkTypeId,2,@PrdId,@PrdBatId,@LcnId,@Pi_Date,@Qty,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					SET @sSQL ='Exec Proc_UpdateProductBatchLocation ' + CAST(@StkTypeId AS VARCHAR(10)) + ',2,' + CAST(@PrdId AS VARCHAR(10)) + ',' +CAST(@PrdBatId AS VARCHAR(10)) + ',' + CAST(@LcnId AS VARCHAR(10)) + ',''' +
							CAST(@Pi_Date AS VARCHAR(20)) + ''',' + CAST(@Qty AS VARCHAR(10)) + ',1,' + CAST( @Po_StkPosting AS VARCHAR(10)) + ''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END

				--Voucher Posting	Added By Maha on 15-03-2009
				IF @Type=0
				BEGIN
					IF @TransType='ADD'
					BEGIN
						EXEC Proc_VoucherPosting 13,1,@GetKey ,5,0,1,@iVocDate,@Po_ErrNo = @ErrStatus OUTPUT
						SET @sSQL='EXEC Proc_VoucherPosting 13,1,'''+ CAST(@GetKey AS VARCHAR(10))+ ''' ,5,0,1,GETDATE(),@Po_PurErrNo = @ErrStatus OUTPUT'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF @TransType='REDUCE'
					BEGIN
						EXEC Proc_VoucherPosting 13,0,@GetKey ,5,0,1,@iVocDate,@Po_ErrNo = @ErrStatus OUTPUT
						SET @sSQL='EXEC Proc_VoucherPosting 13,0,'''+ CAST(@GetKey AS VARCHAR(10)) + ',5,0,1,GETDATE(),@Po_PurErrNo = @ErrStatus OUTPUT'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END

				IF @ErrStatus < 0
				BEGIN
					 SET @ErrDesc = 'Voucher Posting Error'
					 INSERT INTO Errorlog VALUES (8,@TabName,'Voucher posting Error',@ErrDesc)
					 SET @Taction = 0
					 SET @Po_ErrNo =1
				END
				IF @Po_ErrNo =1
				BEGIN
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SET @Po_ErrNo =0
				END
				--Till Here

				IF @Po_StkPosting = 1
				BEGIN
					 SET @ErrDesc = 'Product batch location posting Error'
					 INSERT INTO Errorlog VALUES (8,@TabName,'Product batch location posting Error',@ErrDesc)
					 SET @Taction = 0
					 SET @Po_ErrNo =1
				END
				
				IF @Po_ErrNo =1
					SET @Po_ErrNo =1
				ELSE
					SET @Po_ErrNo =0
				END
				SET @PrdId = 0
				SET @PrdBatId = 0
			FETCH NEXT FROM Cur_StkTransDt INTO @PrdCode,@PrdBat,@StkType,@UomCode,@Qty
		END
		CLOSE Cur_StkTransDt
		DEALLOCATE Cur_StkTransDt
		SET @GetKey=''
		FETCH NEXT FROM Cur_StkTransHd INTO @LocCode,@TransType,@DocRefNo,@Type
	END
	CLOSE Cur_StkTransHd
	DEALLOCATE Cur_StkTransHd
END
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
		FROM PurchaseReceipt A,(SELECT SUM(Amount) AS Amount FROM #PurTaxForDiff)B,#PurTotAdd C
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
DELETE FROM Configuration WHERE ModuleId = 'PURCHASERECEIPT25' AND ModuleName = 'Purchase Receipt'
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('PURCHASERECEIPT25','Purchase Receipt','Display the Debit Note option in Purchase receipt screen',1,'',0.00,25)
DELETE FROM Configuration WHERE ModuleId = 'PURCHASERECEIPT29' AND ModuleName = 'Purchase Receipt'
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('PURCHASERECEIPT29','Purchase Receipt','Allow Creation of Purchase Receipt without net amount',1,'',0.00,29)
DELETE FROM Configuration WHERE ModuleId = 'BILL5' AND ModuleName = 'Billing'
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('BILL5','Billing','Disable Batch creation Details in billing screen',1,'',0.00,5)
GO
IF EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_NetAmount>0]') AND parent_object_id = OBJECT_ID(N'[dbo].[PurchaseReceipt]'))
ALTER TABLE [dbo].[PurchaseReceipt] DROP CONSTRAINT [CK_NetAmount>0]
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_SupplierPaymentForZeroNetAmount')
DROP PROCEDURE Proc_SupplierPaymentForZeroNetAmount
GO
--EXEC Proc_SupplierPaymentForZeroNetAmount 75
CREATE PROCEDURE Proc_SupplierPaymentForZeroNetAmount
(
	@Pi_PurRcptId  		BIGINT
)
AS
/*********************************
* PROCEDURE		: Proc_SupplierPaymentForZeroNetAmount
* PURPOSE		: To populate supplier payment for zero net amount from purchase receipt
* CREATED BY	: Muthuvelsamy R
* CREATED DATE	: 17/02/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @PreFix			VARCHAR(10)
	DECLARE @Zpad			INT
	DECLARE @CurrValue		INT 
	DECLARE @CurYear		INT
	DECLARE @PayAdvNo		NVARCHAR(50)
	DECLARE @CmpId 			INT	
	DECLARE @PurRcptRefNo	NVARCHAR(100)
	DECLARE @SpmId			INT
	DECLARE	@PurOrderRefNo	NVARCHAR(50)
	DECLARE @CmpInvNo		NVARCHAR(100)
	DECLARE @InvDate		DATETIME
	DECLARE @LcnId			INT
	DECLARE	@TransporterId	INT
	DECLARE @GrossAmount	NUMERIC(18, 6)
	DECLARE @PurSeqId		INT
	DECLARE	@AuthId			INT
	DECLARE	@AuthDate		DATETIME
	DECLARE	@CrAdjustAmt	NUMERIC(18, 6)
	DECLARE	@DbAdjustAmt	NUMERIC(18, 6)
	
	SELECT	@CmpId			= Cmpid,
			@PurRcptRefNo	= PurRcptRefNo,
			@SpmId			= SpmId,
			@PurOrderRefNo	= PurOrderRefNo,
			@CmpInvNo		= CmpInvNo,
			@InvDate		= InvDate,
			@LcnId			= LcnId,
			@TransporterId	= TransporterId,
			@GrossAmount	= GrossAmount,
			@PurSeqId		= PurSeqId,
			@AuthId			= AuthId,
			@AuthDate		= AuthDate,
			@CrAdjustAmt	= CrAdjustAmt,
			@DbAdjustAmt	= DbAdjustAmt			
	FROM	PurchaseReceipt 
	WHERE	purrcptid		=  @Pi_PurRcptId
	--AND		Status			= 1
	--AND		PaidStatus		= 0

	SELECT @PreFix=Prefix, @Zpad=Zpad,@CurrValue=CurrValue,@CurYear=CurYear FROM Counters WHERE Tabname='PURCHASEPAYMENT' and FldName='PAYADVNO'

	SELECT @PayAdvNo = @PreFix+CAST(SUBSTRING(CAST(@CurYear as Varchar(10)),3,LEN(@CurYear)) AS Varchar(10)) + REPLICATE('0', CASE WHEN LEN(@CurrValue)>@ZPad THEN (@ZPad+1)-LEN(@CurrValue) ELSE (@ZPad)-LEN(@CurrValue)END)+CAST(@CurrValue+1 as Varchar(10))
	INSERT INTO PurchasePayment (PAYADVNO,PAYMENTDATE,PAYMENTAMOUNT,SPMID,LCNID,CMPREFNO,PAYMENTNO,AVAILABILITY,LASTMODBY,LASTMODDATE,AUTHID,AUTHDATE) 
	VALUES (@PayAdvNo,@AuthDate,@GrossAmount,@SpmId,@LcnId,@CmpInvNo,'','1',@AuthId,@AuthDate,@AuthId,@AuthDate)

	UPDATE PurchaseReceipt SET PaidAmount=0 ,PaidStatus=1 WHERE PurRcptId=@Pi_PurRcptId
	
	DELETE FROM PurchasePaymentGRN WHERE PayAdvNo = @PayAdvNo 
	Insert into PurchasePaymentGRN (PAYADVNO,PURRCPTID,PAYAMOUNT,AVAILABILITY,LASTMODBY,LASTMODDATE,AUTHID,AUTHDATE) 
	VALUES (@PayAdvNo,@Pi_PurRcptId,@GrossAmount,1,@AuthId,@AuthDate,@AuthId,@AuthDate)
	
	--SELECT	@DbNoteNumber = DbNoteNumber, 
	--FROM	DebitNoteSupplier 
	--WHERE	Remarks LIKE '%'+@CmpInvNo+'%'

	--UPDATE DebitNoteSupplier SET DbAdjAmount=@GrossAmount WHERE DbNoteNumber= @DbNoteNumber

	--delete from CRDBNotePayAdjustment where CRDBId='1' 
	--Insert into CRDBNotePayAdjustment (CRDBID,SPMID,PAYADVNO,NOTENO,ADJAMOUNT,ADJMODE,PREVADJAMOUNT,AVAILABILITY,LASTMODBY,LASTMODDATE,AUTHID,AUTHDATE) 
	--VALUES (1,@SpmId,@PayAdvNo,@DbNoteNumber,@GrossAmount,'1',@GrossAmount,'1',@AuthId,@AuthDate,@AuthId,@AuthDate)

	delete from PurchasePaymentDetails where PayAdvNo=@PayAdvNo 
	Insert into PurchasePaymentDetails (PAYADVNO,PAYMODE,BNKID,BNKBRID,PAYINSNO,PAYINSDATE,PAYINSCLRDATE,PAYINSAMT,AVAILABILITY,LASTMODBY,LASTMODDATE,AUTHID,AUTHDATE) 
	Values (@PayAdvNo,'1',0,0,'0','','',@GrossAmount,1,@AuthId,@AuthDate,@AuthId,@AuthDate)

	EXEC Proc_VoucherPosting 22,1,@PayAdvNo,1,1,@AuthId,@AuthDate,0
	--EXEC Proc_VoucherPosting 22,2,@PayAdvNo,1,2,1,@AuthDate,0
	UPDATE Supplier SET SpmOnAcc = (SpmOnAcc+@GrossAmount) WHERE SpmId = @SpmId

	Update PurchasePaymentDetails SET Availability = 1 Where Availability = 1

	UPDATE	Counters SET CurrValue=@CurrValue+1 WHERE TabName='PURCHASEPAYMENT' AND FldName='PAYADVNO'
END
GO
DELETE FROM CustomCaptions WHERE TransId = 26 AND CtrlId = 2000 AND SubCtrlId = 40
INSERT INTO CustomCaptions
SELECT 26,2000,40,'HotSch-26-2000-40','Status','','',1,1,1,GETDATE(),1,GETDATE(),'Status','','',1,1
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 238
INSERT INTO HotSearchEditorHd
SELECT 238,'Purchase Order','ReferenceNo','Select',
'SELECT PurOrderRefNo,CmpId,CmpName,SpmId,SpmName,PurOrderDate,CmpPoNo,CmpPoDate,PurOrderExpiryDate, 
FillAllPrds,GenQtyAuto,PurOrderStatus,  ConfirmSts,DownLoad,Upload,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,
PrdCtgValName,PrdCtgValLinkCode,SiteId,SiteCode,  PurOrderValue,DispOrdVal,POType,Status,Remarks 
FROM (
SELECT A.PurOrderRefNo,A.CmpId,B.CmpName,A.SpmId,C.SpmName,A.PurOrderDate,A.CmpPoNo,A.CmpPoDate,  
A.PurOrderExpiryDate,A.FillAllPrds,A.GenQtyAuto, A.PurOrderStatus,A.ConfirmSts,A.DownLoad,A.Upload, 
ISNULL(A.CmpPrdCtgId,0) AS CmpPrdCtgId,  ISNULL(PCL.CmpPrdCtgName,'''') AS CmpPrdCtgName,ISNULL(A.PrdCtgValMainId,0) AS PrdCtgValMainId, 
ISNULL(PCV.PrdCtgValName,'''') AS PrdCtgValName,  ISNULL(PCV.PrdCtgValLinkCode,0) AS PrdCtgValLinkCode,
SCM.SiteId,SCM.SiteCode,A.PurOrderValue,A.DispOrdVal,(CASE A.Download WHEN 1 THEN ''System Generated''  ELSE ''Manual'' END) AS POType,
ISNULL(A.Remarks,'''') AS Remarks,status 
FROM PurchaseOrderMaster A 
LEFT OUTER JOIN Company B ON B.CmpId=A.CmpId  LEFT OUTER JOIN Supplier C ON A.SpmId=C.SpmId  
LEFT JOIN ProductCategoryLevel PCL   ON PCL.CmpPrdCtgId=A.CmpPrdCtgId 
LEFT JOIN ProductCategoryValue PCV ON PCV.PrdCtgValMainId=A.PrdCtgValMainId  
LEFT OUTER JOIN SiteCodeMaster SCM   ON PCV.PrdCtgValMainId=SCM.PrdCtgValMainId AND SCM.SiteId=A.SiteID 
INNER JOIN(SELECT purorderrefno,''Settled'' as Status   from PurchaseOrderMaster 
WHERE Purorderrefno in (Select PurOrderRefNo FROM PurchaseReceipt) And PurOrderStatus = 1  
UNION ALL SELECT purorderrefno,''Cancelled'' as Status from PurchaseOrderMaster WHERE Purorderstatus = 2 UNION ALL 
SELECT purorderrefno,''Expired'' as Status from PurchaseOrderMaster 
WHERE PurOrderExpiryDate < CONVERT(varchar(10),GETDATE(),121) And purorderstatus = 0      
UNION ALL Select purorderrefno,''Pending'' as Status  
from PurchaseOrderMaster WHERE Confirmsts = 1 And PurOrderStatus = 0 And convert(varchar(10),  
getdate(),121) between purorderdate and PurOrderExpiryDate
And Purorderrefno in (Select PurOrderRefNo FROM PurchaseReceipt) UNION ALL   
SELECT purorderrefno,''Open'' as Status from PurchaseOrderMaster 
WHERE Purorderstatus = 0 And Confirmsts = 0 And   convert(varchar(10),getdate(),121)
between purorderdate and PurOrderExpiryDate And Purorderrefno Not In (Select PurOrderRefNo FROM PurchaseReceipt) 
UNION ALL   Select purorderrefno,''Confirmed'' as Status from PurchaseOrderMaster 
WHERE Confirmsts = 1 And PurOrderStatus = 0     And convert(varchar(10),getdate(),121) 
between purorderdate and PurOrderExpiryDate And Purorderrefno Not In (Select PurOrderRefNo FROM PurchaseReceipt))Z  
on Z.purorderrefno=A.purorderrefno ) AS A Order by PurOrderRefNo'
GO
DELETE FROM Configuration WHERE ModuleId IN ('PURCHASERECEIPT10','PURCHASERECEIPT24','PURCHASERECEIPT25')
INSERT INTO Configuration
SELECT 'PURCHASERECEIPT10','Purchase Receipt','Allow saving of Purchase Receipt even if there is a rate difference',1,'1',900000000.00,10 UNION
SELECT 'PURCHASERECEIPT24','Purchase Receipt','Display the Credit Note option in Purchase receipt screen',1,'',0.00,24 UNION
SELECT 'PURCHASERECEIPT25','Purchase Receipt','Display the Debit Note option in Purchase receipt screen',1,'',0.00,25
GO
IF NOT EXISTS (SELECT * FROM Billtemplatehd WHERE TempName='SALESRETURN')
BEGIN
INSERT INTO Billtemplatehd
SELECT 'SALESRETURN',1,GETDATE(),0,0,0,0,0,15,1,0,2,0
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='RptBt_View_Final_SALESRETURN' AND XTYPE='V')
DROP View RptBt_View_Final_SALESRETURN
GO
CREATE View RptBt_View_Final_SALESRETURN 
AS
SELECT DISTINCT * FROM RptSRNSALESRETURN 
WHERE [Sales Return Date] BETWEEN '2013-02-15' AND '2013-03-15'
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptSRNTemplateLineNo' AND XTYPE='P')
DROP PROCEDURE Proc_RptSRNTemplateLineNo
GO
CREATE PROCEDURE [dbo].[Proc_RptSRNTemplateLineNo] 
(@Pi_Type    INT) As 
Begin      Declare @ReturnCode varchar(25)      Declare @Prdcnt int      Declare @PrdAva int 
declare @prdChk int      declare @PrdLine int DECLARE @FromReturnId AS  VARCHAR(25)  DECLARE @ToReturnId   AS  VARCHAR(25)
DECLARE @TempReturnId TABLE (ReturnId INT) DECLARE @TmpReturn TABLE (ReturnId INT)
Set @Prdline = (Select LineNumber from BillTemplateHD where PrintType =2 AND UsrId=1 and tempName ='SALESRETURN') 
If @Prdline = 1         set @Prdline = 15      Else          Set @Prdline = 10 
IF @Pi_Type=1 BEGIN   INSERT INTO @TmpReturn SELECT SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 32 End
ELSE   BEGIN SELECT @FromReturnId=SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 14 
SELECT @ToReturnId=SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 15 END
IF @Pi_Type=1 BEGIN  INSERT INTO @TempReturnId(ReturnId) SELECT DISTINCT ReturnId FROM RptSRNSALESRETURN with (nolock) WHERE usrid = 3 
AND ReturnId IN( SELECT ReturnId FROM @TmpReturn) END ELSE BEGIN INSERT INTO @TempReturnId(ReturnId) SELECT DISTINCT ReturnId FROM RptSRNSALESRETURN with (nolock) 
WHERE usrid = 3 AND ReturnId Between @FromReturnId AND @ToReturnId  END DECLARE Cur_Salno Cursor For 
SELECT DISTINCT A.ReturnId FROM RptSRNSALESRETURN A with (nolock) INNER JOIN @TempReturnId B ON A.ReturnId= B.ReturnId
WHERE usrid = 3    OPEN Cur_Salno 
FETCH NEXT FROM Cur_Salno INTO @ReturnCode 
WHILE @@FETCH_STATUS =0 
begin     select @prdcnt = count(DISTINCT [Product Short Code]) from RptSRNSALESRETURN A with (nolock) WHERE usrid = 3 and  [ReturnId] = @ReturnCode 
set @prdChk =  @prdcnt/@Prdline 
if @prdchk = 0         set @PrdAva = @Prdline - @prdcnt      
Else 
	begin 
	set @PrdAva =  @prdcnt - (@prdChk*@Prdline) 
	set @PrdAva = @Prdline - @PrdAva     
	End 
if @prdAva = @Prdline    set @PrdAva = 0 
while @prdAva > 0 
begin 
insert into RptSRNSALESRETURN( [Distributor Code],
[Distributor Name],
[Distributor Address1],
[Distributor Address2],
[Distributor Address3],
[PinCode],
[PhoneNo],
[Tax Type],
[TIN Number],
[Deposit Amount],
[CST Number],
[LST Number],
[Licence Number],
[Drug Licence Number 1],
[Drug1 Expiry Date],
[Drug Licence Number 2],
[Drug2 Expiry Date],
[Pesticide Licence Number],
[Pesticide Expiry Date],
[SalId],
[Invoice Number],
[Invoice Date],
[ReturnId],
[Sales Return Number],
[Sales Return Date],
[Sales Man],
[Route],
[Retailer Code],
[Retailer Name],
[Retailer Phone Number],
[Retailer CST Number],
[Retailer Drug Lic  Number],
[Retailer Lic Number],
[Retailer Tin Number],
[Retailer Address],
[Product Company Code],
[Product Company Name],
[Product Short Code],
[Product Short Name],
[Product Name],
[Stock Type],
[Return Quantity],
[Selling Rate],
[Gross Amount],
[Special Discount],
[Scheme Discount],
[Distributor Discount],
[Cash Discount],
[Tax Percentage],
[Tax Amount Line Level],
[Line level Net Amount],
[Reason],
[Type],
[Mode],
[Total Gross Amount],
[Total Special Discount],
[Total Scheme Discount],
[Total Distributor Discount],
[Total Cash Discount],
[Total Tax Amount],
[Total Net Amount],
[Total Discount],
[RtrId],
[RMID],
[SMID],
[MRP],
[Credit Note/Replacement Reference No],
[Credit Note Reference No],UsrId ,Visibility  )
select TOP 1 [Distributor Code],
[Distributor Name],
[Distributor Address1],
[Distributor Address2],
[Distributor Address3],
[PinCode],
[PhoneNo],
[Tax Type],
[TIN Number],
[Deposit Amount],
[CST Number],
[LST Number],
[Licence Number],
[Drug Licence Number 1],
[Drug1 Expiry Date],
[Drug Licence Number 2],
[Drug2 Expiry Date],
[Pesticide Licence Number],
[Pesticide Expiry Date],
[SalId],
[Invoice Number],
[Invoice Date],
[ReturnId],
[Sales Return Number],
[Sales Return Date],
[Sales Man],
[Route],
[Retailer Code],
[Retailer Name],
[Retailer Phone Number],
[Retailer CST Number],
[Retailer Drug Lic  Number],
[Retailer Lic Number],
[Retailer Tin Number],
[Retailer Address],
[Product Company Code],
[Product Company Name],
[Product Short Code],
[Product Short Name],
[Product Name],
[Stock Type],
[Return Quantity],
[Selling Rate],
[Gross Amount],
[Special Discount],
[Scheme Discount],
[Distributor Discount],
[Cash Discount],
[Tax Percentage],
[Tax Amount Line Level],
[Line level Net Amount],
[Reason],
[Type],
[Mode],
[Total Gross Amount],
[Total Special Discount],
[Total Scheme Discount],
[Total Distributor Discount],
[Total Cash Discount],
[Total Tax Amount],
[Total Net Amount],
[Total Discount],
[RtrId],
[RMID],
[SMID],
[MRP],
[Credit Note/Replacement Reference No],
[Credit Note Reference No],3,1  from RptSRNSALESRETURN
where [ReturnId] = @ReturnCode and usrid = 3
set @prdAva = @prdAva - 1     End 
FETCH NEXT FROM Cur_Salno into @ReturnCode 
End 
Close Cur_Salno 
deallocate Cur_Salno 
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptSRNSALESRETURN' AND XTYPE='P')
DROP PROCEDURE Proc_RptSRNSALESRETURN
GO
--Exec Proc_RptSRNSALESRETURN 1,1
CREATE PROCEDURE Proc_RptSRNSALESRETURN  
(
	@Pi_UsrId Int = 1,
	@Pi_Type INT 
) 
As SET NOCOUNT ON 
Begin  
 DECLARE @FromReturnId AS  VARCHAR(25)  
 DECLARE @ToReturnId   AS  VARCHAR(25) 
 DECLARE @Cnt AS INT 
 DECLARE @TempReturnId TABLE (ReturnId INT) 
 DECLARE  @RptSRNTemplate Table 
( 
	[Credit Note Reference No] nvarchar(50),
	[Distributor Code] nvarchar(20),
	[Distributor Name] nvarchar(50),
	[Distributor Address1] nvarchar(50),
	[Distributor Address2] nvarchar(50),
	[Distributor Address3] nvarchar(50),
	[PinCode] int,
	[PhoneNo] nvarchar(50),
	[Tax Type] tinyint,
	[TIN Number] nvarchar(50),
	[Deposit Amount] numeric(38,2),
	[CST Number] nvarchar(50),
	[LST Number] nvarchar(50),
	[Licence Number] nvarchar(50),
	[Drug Licence Number 1] nvarchar(50),
	[Drug1 Expiry Date] DateTime,
	[Drug Licence Number 2] nvarchar(50),
	[Drug2 Expiry Date] DateTime,
	[Pesticide Licence Number] nvarchar(50),
	[Pesticide Expiry Date] DateTime,
	[SalId] INT,
	[Invoice Number] nvarchar(50),
	[Invoice Date] DATETIME,
	[ReturnId] INT,
	[Sales Return Number] nvarchar(50),
	[Sales Return Date] DATETIME,
	[Sales Man] nvarchar(50),
	[Route] nvarchar(50),
	[Retailer Code] nvarchar(50),
	[Retailer Name] nvarchar(150),
	[Retailer Phone Number] nvarchar(50),
	[Retailer CST Number] nvarchar(50),
	[Retailer Drug Lic  Number] nvarchar(50),
	[Retailer Lic Number] nvarchar(50),
	[Retailer Tin Number] nvarchar(50),
	[Retailer Address] nvarchar(50),
	[Product Company Code] nvarchar(20),
	[Product Company Name] nvarchar(150),
	[Product Short Code] nvarchar(100),
	[Product Short Name] nvarchar(150),
	[Product Name] nvarchar(150),
	[Stock Type] nvarchar(100),
	[Return Quantity] NUMERIC(18,0),
	[Selling Rate] NUMERIC(18,6),
	[Gross Amount] NUMERIC(18,6),
	[Special Discount] NUMERIC(18,6),
	[Scheme Discount] NUMERIC(18,6),
	[Distributor Discount] NUMERIC(18,6),
	[Cash Discount] NUMERIC(18,6),
	[Tax Percentage] NUMERIC(18,6),
	[Tax Amount Line Level] NUMERIC(18,6),
	[Line level Net Amount] NUMERIC(18,6),
	[Reason] nvarchar(100),
	[Type] nvarchar(50),
	[Mode] nvarchar(50),
	[Total Gross Amount] NUMERIC(18,6),
	[Total Special Discount] NUMERIC(18,6),
	[Total Scheme Discount] NUMERIC(18,6),
	[Total Distributor Discount] NUMERIC(18,6),
	[Total Cash Discount] NUMERIC(18,6),
	[Total Tax Amount] NUMERIC(18,6),
	[Total Net Amount] NUMERIC(18,6),
	[Total Discount] NUMERIC(18,6),
	[RtrId] INT,
	[RMID] INT,
	[SMID] INT,
	[MRP] NUMERIC(18,6),
	[Credit Note/Replacement Reference No] nvarchar(50),
	UsrId int,Visibility tinyint 
) 
	IF @Pi_Type=1 
	BEGIN   
		INSERT INTO @TempReturnId SELECT SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 32  AND UsrId=@Pi_UsrId
	END
	ELSE   
	BEGIN 
		SELECT @FromReturnId=SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 14 AND UsrId=@Pi_UsrId
		SELECT @ToReturnId=SelValue FROM ReportFilterDt Where RptId = 16 And SelId = 15  AND UsrId=@Pi_UsrId
	END
	IF @Pi_Type=1 BEGIN 
		Insert into @RptSRNTemplate  
		SELECT CreditNoteRetailer.CrNoteNumber,	DistributorCode,	DistributorName,	DistributorAdd1,
		DistributorAdd2,	DistributorAdd3,	PinCode,	PhoneNo,	TaxType,	TINNo,	DepositAmt,
		CSTNo,	LSTNo,	LicNo,	DrugLicNo1,	Drug1ExpiryDate,	DrugLicNo2,	Drug2ExpiryDate,	PestLicNo,
		PestExpiryDate,	SalesInvoice.SalId,	SalInvNo,	SalInvDate,	ReturnProduct.ReturnId,	ReturnCode,
		ReturnDate,	SMCode,	RMCode,	RtrCode,	RtrName,	RtrPhoneNo,	RtrCstNo,	RtrDrugLicNo,	RtrLicNo,
		RtrTINNo,	RtrAdd1,	CmpCode,	CmpName,	Product.PrdDCode,	Product.PrdShrtName,	Product.PrdName,
		UserStockType,	BaseQty,	PrdEditSelRte,	PrdGrossAmt,	PrdSplDisAmt,	PrdSchDisAmt,	PrdDBDisAmt,
		PrdCDDisAmt,	SUM(TaxPerc),	SUM(TaxAmt),	PrdNetAmt,	Description,	InvoiceType,	ReturnMode,	RtnGrossAmt,
		RtnSplDisAmt,	RtnSchDisAmt,	RtnDBDisAmt,	RtnCashDisAmt,	RtnTaxAmt,	RtnNetAmt,	RtnNetAmt,	Retailer.RtrId,
		RouteMaster.RMId,	SalesMan.SMId,	ReturnProduct.PrdUnitMRP,	CreditNoteReplacementHd.CNRRefNo,
		@Pi_UsrId,1 Visibility FROM  Distributor,ReturnProduct INNER JOIN ReturnHeader ON ReturnHeader.ReturnId=ReturnProduct.ReturnId
		INNER JOIN Retailer ON ReturnHeader.RtrId=Retailer.RtrId
		INNER JOIN SalesMan ON ReturnHeader.SMId=SalesMan.SMId
		INNER JOIN RouteMaster ON ReturnHeader.RMId=RouteMaster.RMId 
		LEFT OUTER JOIN SalesInvoice ON SalesInvoice.SalId=ReturnProduct.SalId
		LEFT OUTER JOIN CreditNoteReplacementHd ON CreditNoteReplacementHd.SrNo=ReturnHeader.ReturnCode 
		LEFT OUTER JOIN CreditNoteRetailer ON CreditNoteRetailer.PostedFrom=ReturnHeader.ReturnCode AND CreditNoteRetailer.TransId = 30 
		INNER JOIN Product ON ReturnProduct.PrdId=Product.PrdId
		INNER JOIN Company ON Product.CmpId=Company.CmpId
		INNER JOIN StockType ON StockType.StockTypeId=ReturnProduct.StockTypeId
		LEFT OUTER JOIN ReturnProductTax ON ReturnProductTax.ReturnId=ReturnProduct.ReturnId
		AND ReturnProduct.Slno=ReturnProductTax.PrdSlNo
		LEFT OUTER JOIN ReasonMaster ON ReasonMaster.ReasonId=ReturnProduct.ReasonId WHERE ReturnHeader.ReturnId IN (SELECT ReturnId FROM @TempReturnId)  
		GROUP BY CREDITNOTERETAILER.CRNOTENUMBER,	DISTRIBUTORCODE,	DISTRIBUTORNAME,
		DISTRIBUTORADD1,	DISTRIBUTORADD2,	DISTRIBUTORADD3,	PINCODE,	PHONENO,	TAXTYPE,	TINNO,	DEPOSITAMT,
		CSTNO,	LSTNO,	LICNO,	DRUGLICNO1,	DRUG1EXPIRYDATE,	DRUGLICNO2,	DRUG2EXPIRYDATE,	PESTLICNO,	PESTEXPIRYDATE,
		SALESINVOICE.SALID,	SALINVNO,	SALINVDATE,	RETURNPRODUCT.RETURNID,	RETURNCODE,	RETURNDATE,	SMCODE,	RMCODE,
		RTRCODE,	RTRNAME,	RTRPHONENO,	RTRCSTNO,	RTRDRUGLICNO,	RTRLICNO,	RTRTINNO,	RTRADD1,	CMPCODE,
		CMPNAME,	PRODUCT.PRDDCODE,	PRODUCT.PRDSHRTNAME,	PRODUCT.PRDNAME,	USERSTOCKTYPE,	BASEQTY,	PRDEDITSELRTE,
		PRDGROSSAMT,	PRDSPLDISAMT,	PRDSCHDISAMT,	PRDDBDISAMT,	PRDCDDISAMT,	PRDNETAMT,	DESCRIPTION,	INVOICETYPE,
		RETURNMODE,	RTNGROSSAMT,	RTNSPLDISAMT,	RTNSCHDISAMT,	RTNDBDISAMT,	RTNCASHDISAMT,	RTNTAXAMT,	RTNNETAMT,
		RTNNETAMT,	RETAILER.RTRID,	ROUTEMASTER.RMID,	SALESMAN.SMID,	RETURNPRODUCT.PRDUNITMRP,	CREDITNOTEREPLACEMENTHD.CNRREFNO 
	END  
	ELSE 
	BEGIN 
		Insert into @RptSRNTemplate  
		SELECT CreditNoteRetailer.CrNoteNumber,	DistributorCode,	DistributorName,	DistributorAdd1,	DistributorAdd2,
		DistributorAdd3,	PinCode,	PhoneNo,	TaxType,	TINNo,	DepositAmt,	CSTNo,	LSTNo,	LicNo,	DrugLicNo1,
		Drug1ExpiryDate,	DrugLicNo2,	Drug2ExpiryDate,	PestLicNo,	PestExpiryDate,	SalesInvoice.SalId,	SalInvNo,
		SalInvDate,	ReturnProduct.ReturnId,	ReturnCode,	ReturnDate,	SMCode,	RMCode,	RtrCode,	RtrName,	RtrPhoneNo,
		RtrCstNo,	RtrDrugLicNo,	RtrLicNo,	RtrTINNo,	RtrAdd1,	CmpCode,	CmpName,	Product.PrdDCode,
		Product.PrdShrtName,	Product.PrdName,	UserStockType,	BaseQty,	PrdEditSelRte,	PrdGrossAmt,	PrdSplDisAmt,
		PrdSchDisAmt,	PrdDBDisAmt,	PrdCDDisAmt,	SUM(TaxPerc),	SUM(TaxAmt),	PrdNetAmt,	Description,	InvoiceType,
		ReturnMode,	RtnGrossAmt,	RtnSplDisAmt,	RtnSchDisAmt,	RtnDBDisAmt,	RtnCashDisAmt,	RtnTaxAmt,	RtnNetAmt,	RtnNetAmt,
		Retailer.RtrId,	RouteMaster.RMId,	SalesMan.SMId,	ReturnProduct.PrdUnitMRP,	CreditNoteReplacementHd.CNRRefNo,
		@Pi_UsrId,1 Visibility FROM  Distributor,ReturnProduct INNER JOIN ReturnHeader ON ReturnHeader.ReturnId=ReturnProduct.ReturnId
		INNER JOIN Retailer ON ReturnHeader.RtrId=Retailer.RtrId
		INNER JOIN SalesMan ON ReturnHeader.SMId=SalesMan.SMId
		INNER JOIN RouteMaster ON ReturnHeader.RMId=RouteMaster.RMId
		LEFT OUTER JOIN SalesInvoice ON SalesInvoice.SalId=ReturnProduct.SalId
		LEFT OUTER JOIN CreditNoteReplacementHd ON CreditNoteReplacementHd.SrNo=ReturnHeader.ReturnCode
		LEFT OUTER JOIN CreditNoteRetailer ON CreditNoteRetailer.PostedFrom=ReturnHeader.ReturnCode  AND CreditNoteRetailer.TransId=30
		INNER JOIN Product ON ReturnProduct.PrdId=Product.PrdId
		INNER JOIN Company ON Product.CmpId=Company.CmpId
		INNER JOIN StockType ON StockType.StockTypeId=ReturnProduct.StockTypeId
		LEFT OUTER JOIN ReturnProductTax ON ReturnProductTax.ReturnId=ReturnProduct.ReturnId
		AND ReturnProduct.Slno=ReturnProductTax.PrdSlNo
		LEFT OUTER JOIN ReasonMaster ON ReasonMaster.ReasonId=ReturnProduct.ReasonId WHERE ReturnHeader.ReturnId BETWEEN  @FromReturnId  AND  @ToReturnId  
		GROUP BY CREDITNOTERETAILER.CRNOTENUMBER,	DISTRIBUTORCODE,	DISTRIBUTORNAME,	DISTRIBUTORADD1,	DISTRIBUTORADD2,
		DISTRIBUTORADD3,	PINCODE,	PHONENO,	TAXTYPE,	TINNO,	DEPOSITAMT,	CSTNO,	LSTNO,	LICNO,	DRUGLICNO1,	DRUG1EXPIRYDATE,
		DRUGLICNO2,	DRUG2EXPIRYDATE,	PESTLICNO,	PESTEXPIRYDATE,	SALESINVOICE.SALID,	SALINVNO,	SALINVDATE,	RETURNPRODUCT.RETURNID,
		RETURNCODE,	RETURNDATE,	SMCODE,	RMCODE,	RTRCODE,	RTRNAME,	RTRPHONENO,	RTRCSTNO,	RTRDRUGLICNO,	RTRLICNO,	RTRTINNO,
		RTRADD1,	CMPCODE,	CMPNAME,	PRODUCT.PRDDCODE,	PRODUCT.PRDSHRTNAME,	PRODUCT.PRDNAME,	USERSTOCKTYPE,	BASEQTY,
		PRDEDITSELRTE,	PRDGROSSAMT,	PRDSPLDISAMT,	PRDSCHDISAMT,	PRDDBDISAMT,	PRDCDDISAMT,	PRDNETAMT,	DESCRIPTION,
		INVOICETYPE,	RETURNMODE,	RTNGROSSAMT,	RTNSPLDISAMT,	RTNSCHDISAMT,	RTNDBDISAMT,	RTNCASHDISAMT,	RTNTAXAMT,
		RTNNETAMT,	RTNNETAMT,	RETAILER.RTRID,	ROUTEMASTER.RMID,	SALESMAN.SMID,	RETURNPRODUCT.PRDUNITMRP,	CREDITNOTEREPLACEMENTHD.CNRREFNO 
	END  
	INSERT INTO RptSRNSALESRETURN SELECT * FROM @RptSRNTemplate 
	SELECT * FROM RptSRNSALESRETURN
END
GO
DELETE FROM Configuration where ModuleName='Retailer' and ModuleId='RET35'
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'RET35','Retailer','Set the maximum transaction value as          before approval',0,'',0.00,35
GO
UPDATE MenuDefToAvoid SET Status=1 WHERE MenuId='mCmp6'
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ReturnSplDiscount')
DROP PROCEDURE Proc_ReturnSplDiscount
GO
--  EXEC Proc_ReturnSplDiscount 4,3,6,'2014-03-18',0,0,0,0,0,0
CREATE  PROCEDURE Proc_ReturnSplDiscount
(
	@Pi_PrdId		INT,
	@Pi_PrdBatId		INT,
	@Pi_RtrId		INT,
	@Pi_InvDate			DATETIME,
	@Po_SplDiscount		NUMERIC(38,6) 	OUTPUT,
	@Po_SplFlatAmount	NUMERIC(38,6) 	OUTPUT,
	@Po_SplPriceId		INT 		OUTPUT,
	@Po_MRP			NUMERIC(38,6) 	OUTPUT,
	@Po_SellRate		NUMERIC(38,6) 	OUTPUT,
	@Po_ClaimablePercOnMRP	NUMERIC(38,6) 	OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSplDiscount
* PURPOSE	: To Return the Special Discount for the Selected Retailer and Product
* CREATED	: Thrinath
* CREATED DATE	: 29/04/2007
* NOTE		: General SP for Returning the Special Discount for the Selected Retailer and Product
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}      {developer}       {brief modification description}
* 24/03/2009  Nandakumar R.G	Addition of Tax Group
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ContractId AS INT
	DECLARE @RtrTaxGroupId AS INT
	DECLARE @PrdCtgValMainId	AS INT
	DECLARE @DiscAlone			AS INT
	SET @ContractId = 0
	SET @Po_SplDiscount = 0
	SET @Po_SplFlatAmount = 0
	SET @Po_SplPriceId = 0
	SET @Po_MRP = 0
	SET @Po_SellRate = 0
	SET @DiscAlone=0
	SELECT @RtrTaxGroupId=TaxGroupId FROM Retailer WHERE RtrId=@Pi_RtrId
	SELECT @PrdCtgValMainId=PrdCtgValMainId FROM Product WHERE PrdId=@Pi_PrdId	
	--Return Contract Price Id if set at Retailer Level
	SELECT @ContractId = ISNULL(MAX(ContractId),0) FROM ContractPricingMaster CP WHERE RtrId = @Pi_RtrId
	AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId	
	
	--SELECT '1',@ContractId,@DiscAlone
	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '2',@ContractId,@DiscAlone
	--Return Contract Price Id if set at Retailer Value Class Level with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.RtrClassId = RVCM.RtrValueClassId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId	ELSE CPD.PrdBatId END) 		 
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0 AND CP.RtrtaxGroupId=R.TaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	
	--SELECT '3',@ContractId,@DiscAlone
	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '4',@ContractId,@DiscAlone
	--Return Contract Price Id if set at Retailer Value Class Level without Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.RtrClassId = RVCM.RtrValueClassId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId	ELSE CPD.PrdBatId END)
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '5',@ContractId,@DiscAlone	
	
	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '6',@ContractId,@DiscAlone
	--Return Contract Price Id if set at Retailer Category Level Value with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgMainId = RVC.CtgMainId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.RtrtaxGroupId=R.TaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '7',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '8',@ContractId,@DiscAlone
	--Return Contract Price Id if set at Retailer Category Level Value without Tax Group-Group Level
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId AND R.RtrId=@Pi_RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgMainId = RVC.CtgMainId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			WHERE (CP.RtrId = @Pi_RtrId OR CP.RtrId = 0) AND CP.RtrClassId = 0 AND CP.PrdCtgValMainId IN (0,@PrdCtgValMainId)
			--Retailer Categorly Level updated By Alphonse J on 2014-03-18
			IF @ContractId = 0
			BEGIN
				SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
				INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId AND R.RtrId=@Pi_RtrId
				INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
				INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
				INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
				INNER JOIN ContractPricingMaster CP ON CP.CtgMainId = RVC.CtgMainId
				AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
				INNER JOIN ProductCategoryValue PCV ON CP.PrdCtgValMainId=PCV.PrdCtgValMainId 
				INNER JOIN ProductCategoryValue PCV1 ON PCV1.PrdCtgValLinkCode LIKE PCV.PrdCtgValLinkCode+'%'
				INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
				AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
				WHERE (CP.RtrId = @Pi_RtrId OR CP.RtrId = 0) AND CP.RtrClassId = 0 AND PCV1.PrdCtgValMainId IN (@PrdCtgValMainId)
			END
		--SELECT * FROM ContractPricingMaster
	END	
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT  '9',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '10',@ContractId,@DiscAlone


	--Return Contract Price Id if set at Retailer Category Level Value without Tax Group-Channel Level
	IF @ContractId = 0
	BEGIN
			SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId AND R.RtrId=@Pi_RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RCG ON RCG.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategory RCC ON RCC.CtgMainId = RCG.CtgLinkId
			INNER JOIN RetailerCategoryLevel RCL ON RCC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgMainId = RCC.CtgMainId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			WHERE (CP.RtrId = @Pi_RtrId OR CP.RtrId = 0) AND CP.RtrClassId = 0 AND CP.PrdCtgValMainId IN (0,@PrdCtgValMainId)

		--SELECT * FROM ContractPricingMaster
	END	
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT  '9-1',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '10-1',@ContractId,@DiscAlone


	--Return Contract Price Id if set at Retailer Category Level with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgLevelId = RCL.CtgLevelId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0 AND CP.RtrClassId = 0
			AND CP.CtgMainId = 0 AND CP.RtrtaxGroupId=R.TaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '11',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '12',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Retailer Category Level without Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgLevelId = RCL.CtgLevelId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '13',@ContractId,@DiscAlone
	
	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '14',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Company Level For all Retailer with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Product P 
			INNER JOIN ContractPricingMaster CP ON CP.CmpId = P.CmpId 
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			WHERE P.PrdId =@Pi_PrdId AND CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
			AND CP.CtgLevelId = 0 AND CP.RtrtaxGroupId=@RtrTaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '15',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	----SELECT '16',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Company Level For all Retailer without Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Product P
			INNER JOIN ContractPricingMaster CP ON CP.CmpId = P.CmpId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			WHERE P.PrdId =@Pi_PrdId AND CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
			AND CP.CtgLevelId = 0
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '17',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END	
	--SELECT '18',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Company Level For all Retailer with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM ContractPricingMaster CP
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			WHERE CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
			AND CP.CtgLevelId = 0 AND CP.CmpId = 0 AND CP.RtrtaxGroupId=@RtrTaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '19',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId)
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '20',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Company Level For all Retailer without Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM ContractPricingMaster CP
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId
			AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			WHERE CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
			AND CP.CtgLevelId = 0 AND CP.CmpId = 0
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '21',@ContractId,@DiscAlone

	IF @ContractId = 0
	BEGIN
		SET @Po_SplDiscount = 0
		SET @Po_SplFlatAmount = 0
		SET @Po_SplPriceId = 0
		SET @Po_MRP = 0
		SET @Po_SellRate = 0
		SET @Po_ClaimablePercOnMRP = 0
	END
	ELSE
	BEGIN
		SELECT @Po_SplDiscount = Discount, @Po_SplFlatAmount = FlatAmtDisc,
			@Po_SplPriceId = PriceId, @Po_ClaimablePercOnMRP = ClaimablePercOnMRP 
			FROM ContractPricingDetails
			WHERE ContractId = @ContractId AND PrdId =@Pi_PrdId AND
			PrdBatId = (CASE @DiscAlone WHEN 1 THEN PrdBatId ELSE @Pi_PrdBatId END)

		IF Exists (Select PrdBatId From ProductBatchDetails WHERE PriceId = @Po_SplPriceId
			AND PrdBatId = @Pi_PrdBatId AND DefaultPrice=1)
		BEGIN
			SET @Po_SplPriceId = 0
			SET @Po_MRP = 0
			SET @Po_SellRate = 0
		END
		ELSE
		BEGIN
			SELECT @Po_MRP = B.PrdBatDetailValue , @Po_SellRate = D.PrdBatDetailValue
				FROM ProductBatch A (NOLOCK)
				INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID
				INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = B.BatchSeqId
				AND B.SlNo = C.SlNo AND C.MRP = 1 INNER JOIN ProductBatchDetails D (NOLOCK) ON
				A.PrdBatId = D.PrdBatID INNER JOIN BatchCreation E (NOLOCK) ON
				E.BatchSeqId = D.BatchSeqId AND D.SlNo = E.SlNo AND E.SelRte = 1
				WHERE A.Status = 1 AND A.PrdId=@Pi_PrdId AND B.PriceId = @Po_SplPriceId
				AND D.PriceID = @Po_SplPriceId AND A.PrdBatId = @Pi_PrdBatId
		END
	END

RETURN
END
GO
DELETE FROM RptGroup WHERE RptId = 104
INSERT INTO RptGroup
SELECT 'ParleReports',104,'PurchaseAgeingReport','Purchase Ageing Report',1
GO
DELETE FROM RptGroup WHERE RptId = 43
INSERT INTO RptGroup
SELECT 'ParleReports',43,'RSPSalesanalysisReport','RSP Sales Analysis Report',1
DELETE FROM RptHeader WHERE RptId = 43
INSERT INTO RptHeader
SELECT 'ParleReports','Rsp Sales Analysis Report',43,'Rsp Sales Analysis Report','Proc_RptRspSalesAnalysisReport','RptRspSalesAnalysis',
'RptRspSalesAnalysis.rpt',''
GO
DELETE FROM RptGroup WHERE RptId =217 AND GrpName='Retailer Accounts Statement' 
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',217,'RetailerAccountStatement','Retailer Accounts Statement',1 
DELETE FROM RptGroup WHERE RptId =243 AND GrpName='Business Summary Report' 
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',243,'BusinessSummaryReport','Business Summary Report',1
DELETE FROM RptGroup WHERE RptId =115 AND GrpName='Cheque Payment Report' 
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',115,'ChequePaymentReport','Cheque Payment Report',1
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN(98,405)
INSERT INTO HotSearchEditorDt
SELECT 1,405,'Invoice.Ref.No','Purchase Reference No.','PurRcptRefNo',2000,0,'HotSch-5-2000-26',5 UNION
SELECT 2,405,'Invoice.Ref.No','Invoice Date','InvDate',2000,0,'HotSch-5-2000-27',5
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,98,'VoucherRef','Voucher Date','VocDate',1500,0,'HotSch-39-2000-1',39)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,98,'VoucherRef','Voucher Type','VocType',1000,0,'HotSch-39-2000-2',39)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,98,'VoucherRef','Reference No','VocRefNo',1500,0,'HotSch-39-2000-6',39)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,98,'VoucherRef','Remarks','Remarks',3000,0,'HotSch-39-2000-35',39)
GO
TRUNCATE TABLE ETL_Prk_PurchaseReceiptOtherCharges
TRUNCATE TABLE ETLTempPurchaseReceiptOtherCharges
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Validate_PurchaseReceipt')
DROP PROCEDURE Proc_Validate_PurchaseReceipt
GO
/*
BEGIN TRANSACTION
Exec Proc_Validate_PurchaseReceipt 0
SELECT * FROM ETL_Prk_PurchaseReceipt
SELECT * FROM ETLTempPurchaseReceipt
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Validate_PurchaseReceipt
(
@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_PurchaseReceipt
* PURPOSE		: To Insert and Update records in the Table PurchaseReceipt
* CREATED		: Nandakumar R.G
* CREATED DATE	: 03/05/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist   AS  INT
	
	DECLARE @CmpCode  AS  NVARCHAR(100)
	DECLARE @SpmCode AS  NVARCHAR(100)
	DECLARE @CmpInvNo AS  NVARCHAR(100)
	DECLARE @PONo  AS  NVARCHAR(100)
	DECLARE @InvoiceDate AS  DATETIME
	DECLARE @TransCode AS  NVARCHAR(100)
	DECLARE @PurRcptNo AS  NVARCHAR(100)
	
	DECLARE @CmpId   AS  INT
	DECLARE @SpmId   AS  INT
	DECLARE @TransId  AS  INT
	DECLARE @NetAmt  AS  NUMERIC(18,2)	
	DECLARE @LcnId   AS  INT
	
	DECLARE @TransStr  AS  NVARCHAR(4000)	
	
	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @Exist=0
	DECLARE Cur_PurchaseReceipt CURSOR
	FOR SELECT DISTINCT ISNULL([Company Code],''),ISNULL([Supplier Code],''),ISNULL([Company Invoice No],''),
	ISNULL([PO Number],''),ISNULL([Invoice Date],GETDATE()),ISNULL([Transporter Code],''),ISNULL([NetPayable Amount],0)
	FROM ETL_Prk_PurchaseReceipt
	
	OPEN Cur_PurchaseReceipt
	FETCH NEXT FROM Cur_PurchaseReceipt INTO @CmpCode,@SpmCode,@CmpInvNo,@PONo,@InvoiceDate,@TransCode,@NetAmt
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0	
		SET @Exist=0
		
		SELECT @CmpId=ISNULL(CmpId,0) FROM Company WITH (NOLOCK) WHERE CmpCode=@CmpCode  											
		SELECT @SpmId=ISNULL(SpmId,0) FROM Supplier WITH (NOLOCK) WHERE SpmCode=@SpmCode
		SELECT @TransId=ISNULL(TransporterId,0) FROM Transporter WITH (NOLOCK) WHERE TransporterCode=@TransCode
		SELECT @LcnId=ISNULL(LcnId,0) FROM Location WHERE DefaultLocation=1		
		IF EXISTS(SELECT * FROM ETLTempPurchaseReceipt WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)
		BEGIN
			DELETE FROM dbo.ETLTempPurchaseReceipt WHERE CmpInvNo=@CmpInvNo
			DELETE FROM dbo.ETLTempPurchaseReceiptProduct WHERE CmpInvNo=@CmpInvNo
			DELETE FROM dbo.ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo=@CmpInvNo
			DELETE FROM dbo.ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo=@CmpInvNo
			DELETE FROM dbo.ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo=@CmpInvNo			 		
		END		
		
		IF @Po_ErrNo=0
		BEGIN
			INSERT INTO ETLTempPurchaseReceipt(CmpId,SpmId,PONo,CmpInvNo,InvDate,LcnId,TransporterId,NetAmt,DownLoadStatus)
			VALUES(@CmpId,@SpmId,@PONo,@CmpInvNo,@InvoiceDate,@LcnId,@TransId,@NetAmt,0)
			DELETE FROM ETL_Prk_PurchaseReceipt where [Company Invoice No]=@CmpInvno
		END
		FETCH NEXT FROM Cur_PurchaseReceipt INTO @CmpCode,@SpmCode,@CmpInvNo,@PONo,@InvoiceDate,@TransCode,@NetAmt	
	END
	CLOSE Cur_PurchaseReceipt
	DEALLOCATE Cur_PurchaseReceipt
			
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND name='InvProductToAvoid')
DROP TABLE InvProductToAvoid	
GO
CREATE TABLE InvProductToAvoid
(
CmpInvNo NVARCHAR(50)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_Validate_PurchaseReceiptProduct')
DROP PROCEDURE Proc_Validate_PurchaseReceiptProduct
GO
-- EXEC Proc_Validate_PurchaseReceiptProduct 0
CREATE PROCEDURE Proc_Validate_PurchaseReceiptProduct
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
/*********************************  
* PROCEDURE		: Proc_Validate_PurchaseReceiptProduct  
* PURPOSE		: To Insert and Update records in the Table PurchaseReceiptProduct 
* CREATED		: Nandakumar R.G  
* CREATED DATE	: 03/05/2010  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
SET NOCOUNT ON  
BEGIN
	
	DECLARE @Exist			AS  INT  
	DECLARE @Tabname		AS  NVARCHAR(100)  
	DECLARE @Fldname		AS  NVARCHAR(100)  
	DECLARE @CmpInvNo		AS  NVARCHAR(100)   
	DECLARE @RowId			AS  INT
	DECLARE @PrdCode		AS  NVARCHAR(100)  
	DECLARE @PrdBatCode		AS  NVARCHAR(100)  
	DECLARE @InvUOMCode		AS  NVARCHAR(100)  
	DECLARE @InvQty			AS  NUMERIC(38,0)
	DECLARE @PRRate			AS  NUMERIC(38,6)
	DECLARE @GrossAmt		AS  NUMERIC(38,6)
	DECLARE @DiscAmt		AS  NUMERIC(38,6)  
	DECLARE @TaxAmt			AS  NUMERIC(38,6)  
	DECLARE @NetAmt			AS  NUMERIC(38,6)
	DECLARE @FreightCharges AS  NUMERIC(38,6)   
	
	DECLARE @PrdId			AS  INT  
	DECLARE @PrdBatId		AS  INT  
	DECLARE @InvUOMId		AS  INT  
	DECLARE @NewPrd			AS  INT  
	DECLARE @SubFlag		AS	INT
	
	SET @Po_ErrNo=0  
	SET @Exist=0  
	SET @SubFlag=0
	
	SET @Fldname='CmpInvNo'  
	SET @Tabname = 'ETL_Prk_PurchaseReceiptPrdDt'  
	SET @Exist=0  
	
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'InvProductToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE InvProductToAvoid	
	END
	CREATE TABLE InvProductToAvoid
	(
		CmpInvNo NVARCHAR(50)
	)
	
	DECLARE Cur_PurchaseReceiptProduct CURSOR  
	FOR SELECT ISNULL([Company Invoice No],''),ISNULL([RowId],0),ISNULL([Product Code],''),  
	ISNULL([Batch Code],''),ISNULL([UOM],''),ISNULL([Invoice Qty],0),ISNULL([Purchase Rate],0),ISNULL([Gross],0),ISNULL([Discount In Amount],0),  
	ISNULL([Tax In Amount],0),ISNULL([Net Amount],0), ISNULL([NewPrd],0),ISNULL([FreightCharges],0)
	FROM ETL_Prk_PurchaseReceiptPrdDt  
	
	OPEN Cur_PurchaseReceiptProduct  	
	FETCH NEXT FROM Cur_PurchaseReceiptProduct INTO @CmpInvNo,@RowId,@PrdCode,@PrdBatCode,  
	@InvUOMCode,@InvQty,@PRRate,@GrossAmt,@DiscAmt,@TaxAmt,@NetAmt,@NewPrd,@FreightCharges  
	
	WHILE @@FETCH_STATUS=0  
	BEGIN
	
		SET @PrdId =0
		SET @PrdBatId=0
		SET @InvUOMId=0
		SET @Po_ErrNo=0 
		
		SET @Exist=0  
		
		IF NOT EXISTS(SELECT * FROM ETLTempPurchaseReceipt WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)  
		BEGIN  
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Invoice No',  
			'Company Invoice No:'+ CAST(@CmpInvNo AS NVARCHAR(100)) +' is not available')    
			SET @Po_ErrNo=1  
		END  		
		
		SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCode  		
		SELECT @PrdBatId=PrdBatId FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@PrdBatCode AND PrdId=@PrdId  
		SELECT @InvUOMId=UOMId FROM UOMMaster WITH (NOLOCK) WHERE UOMCode=@InvUOMCode  
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT UM.UomId,um.UomCode,UG.ConversionFactor
			FROM UomGroup UG,UomMaster UM ,Product P
			WHERE UG.UomId = UM.UomId AND P.UomGroupId = UG.UomGroupId AND
			P.PrdId = @PrdId AND UG.UomId = @InvUOMId)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Invoice UOM',
				'Invoice UOM:'+ CAST(@InvUOMCode AS NVARCHAR(100)) +' is not available for the product:'+ CAST(@PrdCode  AS NVARCHAR(100)))
				
				INSERT INTO InvProductToAvoid
				SELECT @CmpInvNo
				SET @Po_ErrNo=1
			END
		END
		
		IF @Po_ErrNo=0  
		BEGIN  
			INSERT INTO ETLTempPurchaseReceiptProduct   
			(CmpInvNo,RowId,PrdId,PrdBatId,POUOMId,POQty,InvUOMId,InvQty,GrossAmt,DiscAmt,TaxAmt,NetAmt,NewPrd,FreightCharges)  
			VALUES(@CmpInvNo,@RowId,@PrdId,@PrdBatId,0,0,@InvUOMId,@InvQty,@GrossAmt,@DiscAmt,@TaxAmt,@NetAmt,@NewPrd,@FreightCharges)  
		END  		
		
		IF @Po_ErrNo<>0  
		BEGIN   
			SET @SubFlag=1
		END
		
		--To capture all the missing UOM
		--IF @Po_ErrNo<>0  
		--BEGIN  
		--	CLOSE Cur_PurchaseReceiptProduct  
		--	DEALLOCATE Cur_PurchaseReceiptProduct  
		--	DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo IN (SELECT DISTINCT CmpInvNo FROM InvProductToAvoid)
		--	RETURN  
		--END  
		
		FETCH NEXT FROM Cur_PurchaseReceiptProduct INTO @CmpInvNo,@RowId,@PrdCode,@PrdBatCode,  
		@InvUOMCode,@InvQty,@PRRate,@GrossAmt,@DiscAmt,@TaxAmt,@NetAmt,@NewPrd,@FreightCharges
	
	END  
	CLOSE Cur_PurchaseReceiptProduct  
	DEALLOCATE Cur_PurchaseReceiptProduct  
	
	IF @SubFlag<>0  
	BEGIN  
		SET @Po_ErrNo=1
		DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo IN (SELECT DISTINCT CmpInvNo FROM InvProductToAvoid)
		RETURN  
	END
	
	IF @Po_ErrNo=0  
	BEGIN  
		TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	END
	
	RETURN   
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_PurchaseReceipt')
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
	DECLARE @BatchNo			NVARCHAR(200)
	DECLARE @ProductCode		NVARCHAR(100)
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
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Date','Invoice Date:'+CAST(CompInvDate AS NVARCHAR(10))+' is greater than current date in Invoice:'+CompInvNo 
		FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK) WHERE CompInvDate>GETDATE()
	END
	--Commented and Added By Mohana.S PMS NO: DCRSTKAL0012
	--IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	--WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK)))	
	--BEGIN
	--	INSERT INTO InvToAvoid(CmpInvNo)
	--	SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	--	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
		
	--	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	--	SELECT DISTINCT 1,'Purchase Receipt','Invoice UOM','UOM:'+UOMCode+' is not available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	--	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
	--END
	IF EXISTS (SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode NOT IN (SELECT PrdCCode+'~'+UomCode  
	FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId))
	BEGIN
		 INSERT INTO InvToAvoid(CmpInvNo)
		 SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode NOT IN (SELECT PrdCCode+'~'+UomCode  
		 FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId)
		 
		 INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		 SELECT DISTINCT 1,'Purchase Receipt','Invoice UOM','UOM:'+UOMCode+' is not available for Invoice:'+CompInvNo 
		 FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode  NOT IN (SELECT PrdCCode+'~'+UomCode  
		 FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId)
	END			
	--->Till Here	
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK)))	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK))
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Supplier','Supplier:'+SupplierCode+' is not available for Invoice:'+CompInvNo
		FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK) WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK))
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
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter WITH(NOLOCK))
	
	IF @TransporterCode=''
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Purchase Download','Transporter','Transporter not available')
	END
	
	INSERT INTO ETL_Prk_PurchaseReceipt([Company Code],[Supplier Code],[Company Invoice No],[PO Number],
	[Invoice Date],[Transporter Code],[NetPayable Amount])
	SELECT DISTINCT C.CmpCode,SupplierCode,P.CompInvNo,'',P.CompInvDate,@TransporterCode,P.NetValue
	FROM Company C,Cn2Cs_Prk_BLPurchaseReceipt P
	WHERE  C.DefaultCompany=1 AND DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	
	--Added By Sathishkumar Veeramani 2013/08/13
	--INSERT INTO ETL_Prk_PurchaseReceiptOtherCharges ([Company Invoice No],[OC Description],Amount)
	--SELECT DISTINCT CompInvNo,'Cash Discounts' AS [OC Description],CashDiscRs FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK)
	--WHERE CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid) AND DownLoadFlag='D'
	
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
DELETE FROM HotSearchEditorDt WHERE FormId=10091 AND FielDName='Bill No'
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10091,'Bill No','Bill No','SalInvNo',4500,0,'HotSch-23-2000-1',23
GO
DELETE FROM FieldLevelAccessDt WHERE Transid = 91 and CtrlId IN(100001,100002,100003)
INSERT INTO FieldLevelAccessDt(PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,91,100001,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH(NOLOCK) UNION
SELECT DISTINCT PrfId,91,100002,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH(NOLOCK) UNION
SELECT DISTINCT PrfId,91,100003,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD WITH(NOLOCK)
GO
DELETE FROM Configuration WHERE ModuleId IN('GENCONFIG31','BILL6')
INSERT INTO Configuration
SELECT 'GENCONFIG31','General Configuration','Display selected UOM in Order',0,'',0.00,31 UNION 
SELECT 'BILL6','Billing','Enable Apply Scheme in Sync Date Validation',0,'',0.00,6
GO
DELETE FROM CustomCaptions WHERE TransId = 91 AND CtrlId = 1000 AND SubCtrlId = 20
INSERT INTO CustomCaptions
SELECT 91,1000,20,'MsgBox-91-1000-20','','','Not Allowed to Edit',1,1,1,GETDATE(),1,GETDATE(),'','','Not Allowed to Edit',1,1
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_ReturnSchemeApplicable')
DROP PROCEDURE Proc_ReturnSchemeApplicable
GO
CREATE PROCEDURE Proc_ReturnSchemeApplicable
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
	
	--Added by Sathishkumar Veeramani 2014/03/28
	IF EXISTS (SELECT Status FROM Configuration WHERE Status = 1 AND ModuleId = 'BILL6')
	BEGIN
		--Added by Praveenraj B ON 18-12-2013 For CRCRSTAML0008
		IF EXISTS(SELECT Schid FROM SchemeMaster where CPB=1 and Schid=@Pi_SchId)
		BEGIN
			IF NOT EXISTS(SELECT SyncStatus FROM SYNCSTATUS where SyncStatus=1 and CONVERT(VARCHAR(10),dwnendtime,121)=CONVERT(VARCHAR(10),GETDATE(),121))
			 BEGIN
				SET @Po_Applicable = 0
				RETURN
			 END	
		END
	END
	--Till Here
	
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
END
GO
DELETE FROM HotsearchEditorHd WHERE Formid=677
INSERT INTO HotsearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 677,'OrderBooking','Product without Company','select',
'SELECT PrdId,PrdDcode,PrdCcode,PrdName,PrdShrtName,UomGroupId,PrdSeqDtId,PrdType   
FROM (SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,c.PrdSeqDtId ,A.PrdType
FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK),ProductBatch D 
WHERE B.TransactionId=vFParam AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId   AND A.PrdId=D.PrdId AND A.PrdType IN (1,2,5,6) 
UNION  
SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,    100000 AS PrdSeqDtId,A.PrdType 
FROM  Product A WITH (NOLOCK) INNER JOIN ProductBatch D ON A.PrdId=D.PrdId AND D.Status=1 WHERE PrdStatus = 1 
AND   A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=vFParam 
AND B.PrdSeqId=C.PrdSeqId)  AND A.PrdType IN (1,2,5,6) ) a ORDER BY PrdSeqDtId'
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_SyncValidation')
DROP PROCEDURE Proc_SyncValidation
GO
--EXEC Proc_SyncValidation 0,'',0,0,0,'','',''
CREATE PROCEDURE Proc_SyncValidation
(    
@piTypeId Int,    
@piCode Varchar(100) = '', -- IP Address in Sync Attempt, DistCode in SyncStatus,    
@piVal1 Numeric(18)=0, -- SubTypeId in SyncStatus,    
@piVal2 Numeric(18)=0, -- SyncId in SyncStatus,    
@piVal3 Numeric(18)=0, -- RecCnt in SyncStatus,    
@piVal4 Varchar(100)='',    
@piVal5 Varchar(100)='',    
@piVal6 Varchar(100)=''    
)    
As    
Begin    
 Declare @Sql Varchar(Max)  
 Declare @IntRetVal Int
   
 IF @piTypeId = 1 -- Distributor Code, Proc_SyncValidation  piTypeId    
 Begin    
  SELECT DistributorCode FROM Distributor WHERE Distributorid=1     
 End    
 IF @piTypeId = 2 -- Upload And Download, Path Proc_SyncValidation  piTypeId    
 Begin    
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44','DATATRANSFER45') AND ModuleName='DataTransfer' Order By ModuleId     
 End     
 IF @piTypeId = 3 -- Sync Attempt Validation  Proc_SyncValidation  @piTypeId,@piCode    
 Begin    
 
  Declare @RetTemp Int
  SET @RetTemp = 1
  IF Not Exists (Select * From SyncStatus (Nolock) Where Syncid = (Select MAX(Syncid) From Sync_Master (Nolock)))
  Begin
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
 
  Set @piCode = (Select Top 1 HostName From Sys.sysprocesses where  status='RUNNABLE' Order By login_time desc)    
  IF ((SELECT Count(*) From SyncAttempt) < 1)    
   BEGIN    
    INSERT INTO SyncAttempt    
    SELECT @piCode,1,Getdate()    
    SELECT 1    
   END     
  ELSE    
   BEGIN    
    IF (SELECT Status From SyncAttempt) = 0    
     BEGIN    
      UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
      SELECT 1    
     END    
    ELSE    
     BEGIN    
      IF ((SELECT DatedIFf(hh,StartTime,Getdate()) From SyncAttempt) > 1)    
       BEGIN    
          UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
          SELECT 1    
       END    
      ELSE    
        IF ((SELECT Count(*) From SyncAttempt WHERE IPAddress = @piCode) = 1 )    
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
 IF @piTypeId = 4 -- Remove from Redownloadrequest,  Proc_SyncValidation   @piTypeId    
 Begin    
  TRUNCATE TABLE ReDownLoadRequest    
 End    
 IF @piTypeId = 5 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
   IF @piVal1 = 1     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess='SyncProcess0' ORDER BY SyncProcess    
   End    
   IF @piVal1 = 2     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess<>'SyncProcess0' ORDER BY SyncProcess    
   End    
 End    
 IF @piTypeId = 6 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1     
   Begin    
    SELECT DISTINCT SlNo,SlNo AS SeqNo,Module AS Process,TranType AS [Transaction Type],UpDownload AS [Exchange Type], 0 AS Count     
    FROM Customupdownload ORDER BY SlNo     
   End    
  IF @piVal1 = 2     
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Upload'    
   End    
  IF @piVal1 = 3    
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Download'    
   End    
 End    
 IF @piTypeId = 7 -- Sync Status Validation,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3    
 Begin    
 
  IF Exists(Select * from SyncStatus Where DistCode = @piCode and SyncId = @piVal2)        
   Begin        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End        
  Else        
   Begin        
    Delete From SyncStatus Where DistCode = @piCode and SyncStatus = 1  
    IF Not Exists (Select * From  SyncStatus (Nolock))
    Begin  
		Insert into SyncStatus Select @piCode,@piVal2,Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),0,'N'
    End        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End      
 End    
 IF @piTypeId = 8 -- Select Current SyncId,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select IsNull(MAX(SyncId),0) From SyncStatus    
 End     
 IF @piTypeId = 9 -- Select Syncstatus for this SyncId,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin    
  Select IsNull(Max(SyncStatus),0) From SyncStatus where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1    
 End      
 IF @piTypeId = 10 -- DB Restoration Concept,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
   Begin    
    Select Count(*) From DefendRestore    
   End     
  IF @piVal1 = 2    
   Begin    
    update DefendRestore Set DbStatus = 1,ReqId = 1,CCLockStatus = 1    
   End       
  IF @piVal1 = 3    
   Begin    
    Insert into DefendRestore (AccessCode,LastModDate,DbStatus,ReqId,CCLockStatus)
    Values('',GETDATE(),1,1,1)    
   End     
 End       
 IF @piTypeId = 11 -- AAD & Configuration Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId='BotreeSyncCheck'    
  End     
  IF @piVal1 = 2    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId LIKE 'BotreeSyncErrLog'    
  End       
  IF @piVal1 = 3    
  Begin    
   Select IsNull(Max(FixID),0) from Hotfixlog (NOLOCK)    
  End       
 End       
 IF @piTypeId = 12 -- System Date is less than the Last Transaction Date Validation,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT ISNULL(MAX(TransDate),GETDATE()-1) AS TransDate FROM StockLedger    
 End     
 IF @piTypeId = 13 -- DayEnd Process Updation,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  UPDATE DayEndProcess SET NextUpDate=@piCode WHERE ProcId=13    
 End     
 IF @piTypeId = 14 -- Update Sync Attempt Status ,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  Select @piCode =  HostName From Sys.sysprocesses where  status='RUNNABLE'    
  Update SyncAttempt Set Status=0 where IPAddress = @piCode    
 End      
 IF @piTypeId = 15 -- Latest SyncId from Sync_Master ,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select ISNull(Max(SyncId),0) From Sync_Master    
 End     
 IF @piTypeId = 16 -- Update the Flag as Y for all lesser than the latest Serial No ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
	 IF ((Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N') > 0)        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo >=   
	   (Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N')         
	  End        
	  Else        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal1 And SlNo <= @piVal2 
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo > @piVal2    
	  End 
 End      
 IF @piTypeId = 17 -- Record Count ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   Select Count(*) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2 and UploadFlag = 'N'    
  End    
  IF @piVal1 = 2     
  Begin    
   Select Count(Distinct Slno) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2     
  End       
  IF @piVal1 = 3     
  Begin    
   Select IsNull(Count(*),0) From SyncStatus (Nolock) Where DistCode = @piCode And SyncId = @piVal2 And SyncFlag = 'Y'     
  End    
 End      
 IF @piTypeId = 18 -- Datapreperation Process and Split each 1000 rows for xml file ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   SELECT * FROM  CustomUpDownload  WHERE SlNo=@piVal2  AND UpDownload='Upload' ORDER BY UpDownLoad,SlNo,SeqNo    
  End    
  IF @piVal1 = 2     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 3    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End        
  IF @piVal1 = 4    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT * FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE  SlNo= ' + Convert(Varchar(100),@piVal2) + '  ORDER BY UpDownLoad,SlNo,SeqNo '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 5    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM   ' + Convert(Varchar(100),@piCode) + '  '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 6    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' DELETE  FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE Downloadflag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 7    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE DownloadFlag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 8    
  Begin    
   Set @Sql = ''    
  Set @Sql = @Sql + ' SELECT TRowCount FROM Tbl_DownloadIntegration_Process WHERE PrkTableName =''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 9    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = 0  WHERE ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 10    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = ' + Convert(Varchar(100),@piVal2) + ' where ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 11     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MAX(SlNo),0) AS Cnt FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 12     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End      
  IF @piVal1 = 13     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 14     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Upload'' '    
   Exec (@Sql)    
  End         
  IF @piVal1 = 15     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS DownloadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Download'' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 16     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 17     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus_Download (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 18
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' SELECT * FROM ' + Convert(Varchar(100),@piCode) + ' As DU WHERE UploadFlag=''N'' AND SlNo BETWEEN  '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' ORDER BY SlNo  FOR XML AUTO '
		Select @Sql
	End	
  IF @piVal1 = 19
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''X'' WHERE UploadFlag=''N'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 20
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''Y'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 21
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''N'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	  

 End      
 IF @piTypeId = 19 -- View Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT * FROM ErrorLog WITH (NOLOCK)    
 End    
 IF @piTypeId = 20 -- Remove Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  DELETE FROM ErrorLog     
 End     
 IF @piTypeId = 21 -- Download Notification Details Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM  CustomUpDownloadCount WHERE UpDownload='Download' ORDER BY SlNo    
 End     
 IF @piTypeId = 22 -- Download Details to xml file ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='N'    
 End     
 IF @piTypeId = 23 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_DownloadIntegration_Process ORDER BY SequenceNo    
 End     
 IF @piTypeId = 24 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_DownloadIntegration_Process SET TRowCount=0    
 End      
 IF @piTypeId = 25 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_DownloadIntegration_Process WHERE ProcessName = @piCode    
 End      
 IF @piTypeId = 26 -- Upload Consolidated Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_UploadIntegration_Process ORDER BY SequenceNo    
 End      
 IF @piTypeId = 27 -- Download Details   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT DISTINCT Module,DownloadedCount FROM CustomUpDownloadCount WHERE UpDownload='Download' AND DownloadedCount>0    
 End      
 IF @piTypeId = 28 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeReDownload'    
 End     
 IF @piTypeId = 29 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM ReDownLoadRequest    
 End     
 IF @piTypeId = 30 -- Showboard    ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeBBOardOnSync' AND Status=1    
 End     
 IF @piTypeId = 31 -- Update sync status if disconnect    ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin     
  IF Not Exists (Select * From CS2Console_Consolidated (nolock) Where DistCode = @piCode And Syncid = @piVal1 And UploadFlag='N')    
  Begin    
   Update Syncstatus Set Syncstatus = 1 Where DistCode = @piCode And Syncid = @piVal1    
   Select IsNull(Max(SyncStatus),0) From SyncStatus (nolock) Where DistCode = @piCode And Syncid = @piVal1    
  End    
 End     
 IF @piTypeId = 32 -- Update sync status if disconnect,Proc_SyncValidation @piTypeId,@piCode,@piVal1    
 Begin     
  Declare @RETVAL Varchar(Max)    
  Set @RETVAL = ''    
  IF EXISTS (Select * From Chk_MainSalesIMEIUploadCnt (NOLOCK))    
  Begin      
  Select @RETVAL = Cast(COALESCE(@RETVAL + ', ', '') + Convert(Varchar(40),MainTblBillNo) as ntext) From Chk_MainSalesIMEIUploadCnt       
  Select @RETVAL    
  End    
 End    
 IF @piTypeId = 33 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select 'Request given for approval so please approve from Central Help Desk.'      
 End      
 IF @piTypeId = 34 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select IsNull(LTrim(RTrim(CmpCode)),'') From Company (Nolock) Where DefaultCompany = 1      
 End      
 IF @piTypeId = 35 -- Select Download Sync status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin       
  Select IsNull(SyncStatus,0) from Syncstatus_Download (nolock) Where Distcode = @picode and Syncid = @pival1    
 End      
 IF @piTypeId = 36 -- Select Max(Syncid) in Download Sync Status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SyncId),0) From SyncStatus_Download (Nolock)    
 End      
 IF @piTypeId = 37 -- Select Max(SlNo) in Console2CS_Consolidated  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SlNo),0) From Console2CS_Consolidated (Nolock) Where Distcode = @picode and Syncid = @pival1    
 End       
 IF @piTypeId = 38 -- Syncstatus  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin       
 Declare @RetState Int    
 IF Exists (Select * From SyncStatus (Nolock) where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1)    
  Begin    
	If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0
	 Begin
		IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
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
  		IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
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
 IF @piTypeId = 39 -- Update Download Sync Status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3      
 Begin       
 -------    
  IF Exists(Select * from SyncStatus_Download Where DistCode = @piCode and SyncId = @piVal2)                
   Begin                
    IF @piVal1 = 1                
    Begin              
     IF Exists(Select * From Console2CS_Consolidated (Nolock) Where DistCode = @piCode and SyncId = @piVal2)        
     Begin        
     Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2        
     End        
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2             
      End        
     End             
   End                
  Else                
   Begin                
    Insert into SyncStatus_Download_Archieve  Select *,Getdate() from SyncStatus_Download Where DistCode = @piCode           
    Delete From SyncStatus_Download Where DistCode = @piCode               
    Insert into SyncStatus_Download Select @piCode,@piVal2,Getdate(),Getdate(),0,0                
    Insert into SyncStatus_Download_Archieve Select @piCode,@piVal2,Getdate(),Getdate(),0,0,GETDATE()                 
    IF @piVal1 = 1                
    Begin                
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock) Where DistCode = @piCode and SyncId = @piVal2             
      End         
     End             
   End      
 ------    
 END      
  IF @piTypeId = 40 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_Customdownloadintegration ORDER BY SequenceNo    
 End     
 IF @piTypeId = 41 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_Customdownloadintegration SET TRowCount=0    
 End 
 IF @piTypeId = 42 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_Downloadintegration WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 43 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT TRowCount FROM Tbl_Customdownloadintegration WHERE PrkTableName = @piCode    
 End 
 IF @piTypeId = 44 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  Update Tbl_Customdownloadintegration Set TRowCount = @piVal1 WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 45 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId  
 Begin   
	Set @IntRetVal = 0  
	IF @piVal1 = 1
	Begin
		If Exists (Select * From sys.Objects where TYPE='U' and name ='UtilityProcess')  
		 Begin  
		  IF Exists (Select * from UtilityProcess where ProcId = 3)  
		  Begin  
		   IF ((Select Convert(Varchar(100),VersionId) from UtilityProcess where ProcId = 3) <> @piCode)  
		   Begin  
			Set @IntRetVal = 1      
		   End     
		  End  
		 End  
	End   
	IF @piVal1 = 2
	Begin
		If Not Exists (Select * From AppTitle (Nolock) Where  SynVersion = @piCode)  
		 Begin  
			Set @IntRetVal = 1
		 End
	End
	Select @IntRetVal 
 End  	
 IF @piTypeId = 46 -- Data Purge  ,  Proc_SyncValidation   @piTypeId  
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
 IF @piTypeId = 47 -- Update In Active Distributor  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	--IF Exists (Select * From Sys.objects Where name = 'Distributor' and TYPE='U')
	--Begin
	--	Update Distributor Set DistStatus = 0 Where DistributorCode = @piCode
	--End
 END

----------Additional Validation----------    
------------------------------------------    
END
GO
DELETE FROM Configuration WHERE ModuleId IN('BILL3','DATATRANSFER41')
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'BILL3','Billing','Allow to Enter Distributor discount in % when discount type is in value',1,'',0.00,3 UNION
SELECT 'DATATRANSFER41','DataTransfer','Perform Sync Process during',1,'',0.00,41
GO
DELETE FROM AutoBackupConfiguration WHERE ModuleId IN ('AUTOBACKUP1','AUTOBACKUP2','AUTOBACKUP3')
INSERT INTO AutoBackupConfiguration
SELECT 'AUTOBACKUP1','AutomaticBackup','Take Full Backup of the database Every time',1,'',0.00,CONVERT(NVARCHAR(10),GETDATE(),121),1 UNION
SELECT 'AUTOBACKUP2','AutomaticBackup','Take Backup/Extract Log while Logging on to the application',0,'',0.00,CONVERT(NVARCHAR(10),GETDATE(),121),2 UNION
SELECT 'AUTOBACKUP3','AutomaticBackup','Take Backup/Extract Log while Logging out of the application',1,'',0.00,CONVERT(NVARCHAR(10),GETDATE(),121),3
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',413
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 413)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(413,'D','2014-03-28',GETDATE(),1,'Core Stocky Service Pack 413')