--[Stocky HotFix Version]=370
Delete from Versioncontrol where Hotfixid='370'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('370','2.0.0.5','D','2011-04-02','2011-04-02','2011-04-02',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 370' ,'370'
GO

--SRF-Nanda-223-001

UPDATE RptDetails SET FldCaption='Retailer...',Mandatory=0 WHERE RptId=222 AND SlNo=3

--SRF-Nanda-223-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RetailerAccountStment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RetailerAccountStment]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RetailerAccountStment '2011-03-31','2011-03-31',0

CREATE  PROCEDURE [dbo].[Proc_RetailerAccountStment]
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate DATETIME,
	@Pi_RtrId INT
)
AS
/*********************************
* PROCEDURE	: Proc_RetailerAccountStment
* PURPOSE	: To Return the Retailer wise bill details
* CREATED	: MarySubashini.S
* CREATED DATE	: 23-06-2010
* NOTE		: General SP Returning the Retailer wise Account details 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 14-OCT-2010	Jayakumar N		Reference with SLR is not taken from CreditNoteRetailer	
* 20-OCT-2010	Jayakumar N		Changes done after discussion made with kanagaraj regarding CreditNote & DebitNote posting	
*********************************/
SET NOCOUNT ON
BEGIN
-- AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL
	DECLARE @SLRHD AS NVARCHAR(50)
	DECLARE @RTNHD AS NVARCHAR(50)
	SELECT @SLRHD=Prefix FROM Counters WHERE TabName='ReturnHeader' and FldName = 'ReturnCode'
	SET @SLRHD=@SLRHD + '%'
	SELECT @RTNHD=Prefix FROM Counters WHERE TabName='ReplacementHd' and FldName = 'RepRefNo'
	SET @RTNHD=@RTNHD + '%'
	DECLARE @TempRetailerAccountStatement TABLE
		(
			[SlNo] [int] NULL,
			[RtrId] [int] NULL,
			[CoaId] [int] NULL,
			[RtrName] [nvarchar](100) NULL,
			[RtrAddress] [nvarchar](600) NULL,
			[RtrTINNo] [nvarchar](50) NULL,
			[InvDate] [datetime] NULL,
			[DocumentNo] [nvarchar](100) NULL,
			[Details] [nvarchar](400) NULL,
			[RefNo] [nvarchar](100) NULL,
			[DbAmount] [numeric](38, 6) NULL,
			[CrAmount] [numeric](38, 6) NULL,
			[BalanceAmount] [numeric](38, 6) NULL
		)
	INSERT INTO @TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
	SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				SI.SalInvDate,SI.SalInvNo,'Sales','',
				(SI.SalNetAmt + SI.OnAccountAmount + SI.MarketRetAmount + SI.CrAdjAmount-SI.ReplacementDiffAmount - SI.DBAdjAmount),0,0
			FROM SalesInvoice SI (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE SI.DlvSts  IN (4,5) AND SI.SalInvDate <@Pi_FromDate  AND SI.RtrId=CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE @Pi_RtrId END
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Sales Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=2 AND RH.ReturnDate<@Pi_FromDate AND  RH.RtrId=CASE @Pi_RtrId WHEN 0 THEN RH.RtrId ELSE @Pi_RtrId END
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Market Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=1 AND RH.ReturnDate<@Pi_FromDate AND  RH.RtrId=CASE @Pi_RtrId WHEN 0 THEN RH.RtrId ELSE @Pi_RtrId END
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
----		UNION ALL
----			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
----					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
----				FROM ReplacementHd RH (NOLOCK)
----					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
----					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
----					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
----				WHERE RH.RepDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
----				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Replacement',ISNULL(SI.SalInvNo,''),ROUND(SUM(RP.RepAmount),2),0,0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementOut RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate<@Pi_FromDate AND  RH.RtrId=CASE @Pi_RtrId WHEN 0 THEN RH.RtrId ELSE @Pi_RtrId END
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL  -- Added by Jay on 21-OCT-2010
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate<@Pi_FromDate AND RH.RtrId=CASE @Pi_RtrId WHEN 0 THEN RH.RtrId ELSE @Pi_RtrId END
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
				   -- End here
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection',ISNULL(SI.SalInvNo,''),0,SUM(RE.SalInvAmt),0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2,3,4,8) AND 
					RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE @Pi_RtrId END
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				RH.InvRcpDate,RH.InvRcpNo,'Collection-Cheque Bounce',ISNULL(SI.SalInvNo,''),(SUM(RE.SalInvAmt)+SUM(RE.Penalty)),0,0
			FROM Receipt RH (NOLOCK)
				INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
				INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE RE.InvRcpMode IN (3) AND InvInsSta=4 AND 
				RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE @Pi_RtrId END
			GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection-Cash Cancellation',ISNULL(SI.SalInvNo,''),SUM(RE.SalInvAmt),0,0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2) AND CancelStatus=0  AND 
					RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE @Pi_RtrId END
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,DR.Amount,0 -- DR.Amount
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId=R.CoaId
			WHERE DR.DbNoteDate<@Pi_FromDate AND DR.RtrId=CASE @Pi_RtrId WHEN 0 THEN DR.RtrId ELSE @Pi_RtrId END 
			AND DR.PostedFrom NOT LIKE @RTNHD AND DR.PostedFrom NOT LIKE @SLRHD OR DR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,0,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId<>R.CoaId AND DR.TransId<>11
			WHERE DR.DbNoteDate<@Pi_FromDate AND DR.RtrId=CASE @Pi_RtrId WHEN 0 THEN DR.RtrId ELSE @Pi_RtrId END 
			AND DR.PostedFrom NOT LIKE @RTNHD AND DR.PostedFrom NOT LIKE @SLRHD OR DR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),CR.Amount,CR.Amount,0  -- CR.Amount
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId=R.CoaId
			WHERE CR.CrNoteDate<@Pi_FromDate AND CR.RtrId=CASE @Pi_RtrId WHEN 0 THEN CR.RtrId ELSE @Pi_RtrId END 
			AND CR.PostedFrom NOT LIKE @RTNHD AND CR.PostedFrom NOT LIKE @SLRHD OR CR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),0,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId<>R.CoaId
			WHERE CR.CrNoteDate<@Pi_FromDate AND CR.RtrId=CASE @Pi_RtrId WHEN 0 THEN CR.RtrId ELSE @Pi_RtrId END 
			AND CR.PostedFrom NOT LIKE @RTNHD AND CR.PostedFrom NOT LIKE @SLRHD OR CR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,ROA.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				ROA.ChequeDate,ROA.RtrAccRefNo,'Retailer On Account','',0,Amount,0
			FROM RetailerOnAccount ROA (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON ROA.RtrId=R.RtrId
			WHERE ROA.ChequeDate<@Pi_FromDate AND ROA.RtrId=CASE @Pi_RtrId WHEN 0 THEN ROA.RtrId ELSE @Pi_RtrId END

-- Added by Jay on 21-OCT-2010
	DELETE FROM @TempRetailerAccountStatement WHERE Rtrid<>CASE @Pi_RtrId WHEN 0 THEN RtrId ELSE @Pi_RtrId END
	TRUNCATE TABLE TempRetailerAccountStatement
	INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
	
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				SI.SalInvDate,SI.SalInvNo,'Sales','',
				(SI.SalNetAmt + SI.OnAccountAmount + SI.MarketRetAmount + SI.CrAdjAmount- SI.DBAdjAmount),0,0
			FROM SalesInvoice SI (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE SI.DlvSts  IN (4,5) AND SI.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE @Pi_RtrId END
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Sales Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=2 AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate  AND  RH.RtrId=CASE @Pi_RtrId WHEN 0 THEN RH.RtrId ELSE @Pi_RtrId END
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Market Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=1 AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=CASE @Pi_RtrId WHEN 0 THEN RH.RtrId ELSE @Pi_RtrId END
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
----		UNION ALL
----			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
----					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
----				FROM ReplacementHd RH (NOLOCK)
----					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
----					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
----					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
----				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
----				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Replacement',ISNULL(SI.SalInvNo,''),ROUND(SUM(RP.RepAmount),2),0,0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementOut RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=CASE @Pi_RtrId WHEN 0 THEN RH.RtrId ELSE @Pi_RtrId END
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL  -- Added by Jay on 20-OCT-2010
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=CASE @Pi_RtrId WHEN 0 THEN RH.RtrId ELSE @Pi_RtrId END
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
				   -- End here
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection',ISNULL(SI.SalInvNo,''),0,SUM(RE.SalInvAmt),0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2,3,4,8) AND 
					RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE @Pi_RtrId END
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				RH.InvRcpDate,RH.InvRcpNo,'Collection-Cheque Bounce',ISNULL(SI.SalInvNo,''),(SUM(RE.SalInvAmt)+SUM(RE.Penalty)),0,0
			FROM Receipt RH (NOLOCK)
				INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
				INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE RE.InvRcpMode IN (3) AND InvInsSta=4 AND 
				RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE @Pi_RtrId END
			GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection-Cash Cancellation',ISNULL(SI.SalInvNo,''),SUM(RE.SalInvAmt),0,0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2) AND CancelStatus=0  AND 
					RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE @Pi_RtrId END
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,DR.Amount,0 --DR.Amount,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId=R.CoaId
			WHERE DR.DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DR.RtrId=CASE @Pi_RtrId WHEN 0 THEN DR.RtrId ELSE @Pi_RtrId END --AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,0,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId<>R.CoaId
			WHERE DR.DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate  AND DR.TransId<>11
			AND DR.RtrId=CASE @Pi_RtrId WHEN 0 THEN DR.RtrId ELSE @Pi_RtrId END --AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),CR.Amount,CR.Amount,0 --CR.Amount,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId=R.CoaId
			WHERE CR.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND CR.RtrId=CASE @Pi_RtrId WHEN 0 THEN CR.RtrId ELSE @Pi_RtrId END --AND PostedFrom NOT LIKE @RTNHD AND PostedFrom NOT LIKE @SLRHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),0,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId<>R.CoaId
			WHERE CR.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND CR.RtrId=CASE @Pi_RtrId WHEN 0 THEN CR.RtrId ELSE @Pi_RtrId END --AND PostedFrom NOT LIKE @RTNHD AND PostedFrom NOT LIKE @SLRHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,ROA.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				ROA.ChequeDate,ROA.RtrAccRefNo,'Retailer On Account','',0,Amount,0
			FROM RetailerOnAccount ROA (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON ROA.RtrId=R.RtrId
			WHERE ROA.ChequeDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND ROA.RtrId=CASE @Pi_RtrId WHEN 0 THEN ROA.RtrId ELSE @Pi_RtrId END


			CREATE Table #DelRtrAccStmt(SlNo INT,RtrId Int,CoaId INT,InvDate DateTime,DocumentNo nVarchar(50),
							RefNo nVarchar(50),DBAmount Numeric(18,6),CRAmount Numeric(18,6),
							BalAmt Numeric(18,6))

			INSERT INTO #DelRtrAccStmt
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			From TempRetailerAccountStatement Where Details  like  'Credit Note Retailer' 
			and RefNo like @SLRHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Credit Note Retailer' 
			and RefNo like @RTNHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Debit Note Retailer' 
			and RefNo like @SLRHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Debit Note Retailer' 
			and RefNo like @RTNHD

			Delete  From  @TempRetailerAccountStatement 
			Where  (SlNo in (Select SlNo From #DelRtrAccStmt)
				    ANd  RtrId in (Select RtrId From #DelRtrAccStmt)
					ANd  CoaId in (Select CoaId From #DelRtrAccStmt)
					ANd  InvDate in (Select InvDate From #DelRtrAccStmt)
					ANd  DocumentNo in (Select DocumentNo From #DelRtrAccStmt)
					ANd  RefNo in (Select RefNo From #DelRtrAccStmt)
					ANd  DBAmount in (Select DBAmount From #DelRtrAccStmt)
					ANd  CRAmount in (Select CRAmount From #DelRtrAccStmt)
					ANd  BalanceAmount in (Select BalAmt From #DelRtrAccStmt) )
 

			Delete  From  TempRetailerAccountStatement 
			Where  (SlNo in (Select SlNo From #DelRtrAccStmt)
				    ANd  RtrId in (Select RtrId From #DelRtrAccStmt)
					ANd  CoaId in (Select CoaId From #DelRtrAccStmt)
					ANd  InvDate in (Select InvDate From #DelRtrAccStmt)
					ANd  DocumentNo in (Select DocumentNo From #DelRtrAccStmt)
					ANd  RefNo in (Select RefNo From #DelRtrAccStmt)
					ANd  DBAmount in (Select DBAmount From #DelRtrAccStmt)
					ANd  CRAmount in (Select CRAmount From #DelRtrAccStmt)
					ANd  BalanceAmount in (Select BalAmt From #DelRtrAccStmt) )


-- EXEC Proc_RetailerAccountStment '2011-03-31','2011-03-31',0


	IF EXISTS (SELECT * FROM @TempRetailerAccountStatement)
	BEGIN
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT 1,R.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_FromDate,'','Opening Balance','',0,0,(SUM(Det.DbAmount)-SUM(Det.CrAmount))
			FROM @TempRetailerAccountStatement Det ,Retailer R 
			WHERE R.RtrId=Det.RtrId
			GROUP BY R.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo

		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT  DISTINCT 3,R.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_ToDate,'','Closing Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=CASE @Pi_RtrId WHEN 0 THEN R.RtrId ELSE @Pi_RtrId END
	END 
--	ELSE
--	BEGIN
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT DISTINCT  1,R.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_FromDate,'','Opening Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=CASE @Pi_RtrId WHEN 0 THEN R.RtrId ELSE @Pi_RtrId END
				AND R.RtrId NOT IN (SELECT DISTINCT RtrId FROM @TempRetailerAccountStatement)

		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT  DISTINCT 3,R.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_ToDate,'','Closing Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=CASE @Pi_RtrId WHEN 0 THEN R.RtrId ELSE @Pi_RtrId END
				AND R.RtrId NOT IN (SELECT DISTINCT RtrId FROM @TempRetailerAccountStatement)
--	END 
-- Added by Jay on 20-OCT-2010
	INSERT INTO TempRetailerAccountStatement
	SELECT 2,B.CoaId,B.CoaId,AcName,'','',VocDate,'',AcName,NULL,Amount,0,0
	FROM StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo 
	INNER JOIN CoaMaster C ON B.CoaId=C.CoaId
	AND A.VocDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
	AND A.VocType=0 AND A.VocSubType=0 AND A.AutoGen=0 AND DebitCredit=1
	UNION ALL
	SELECT 2,B.CoaId,B.CoaId,AcName,'','',VocDate,'',AcName,NULL,0,Amount,0
	FROM StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo 
	INNER JOIN CoaMaster C ON B.CoaId=C.CoaId
	AND A.VocDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.VocType=0 AND A.VocSubType=0 AND A.AutoGen=0 AND DebitCredit=2

	SELECT DISTINCT * INTO #TempRetailerAccountStatement FROM TempRetailerAccountStatement
	TRUNCATE TABLE TempRetailerAccountStatement
	INSERT INTO TempRetailerAccountStatement
	SELECT * FROM #TempRetailerAccountStatement
-- End here	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-223-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptAkzoRetAccStatement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptAkzoRetAccStatement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----EXEC Proc_RptAkzoRetAccStatement 222,2,0,'hh',0,0,1

CREATE  Procedure [dbo].[Proc_RptAkzoRetAccStatement]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/****************************************************************************
* PROCEDURE: Proc_RptAkzoRetAccStatement
* PURPOSE: General Procedure
* NOTES:
* CREATED: Panneer	14.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
* 22.03.2011   Panneer    BugFixing
* 29.03.2011   
*****************************************************************************/
Begin
SET NOCOUNT ON
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	NVARCHAR(50)
	DECLARE @TblName 			AS	NVARCHAR(500)
	DECLARE @TblStruct 			AS	VARCHAR(8000)
	DECLARE @TblFields 			AS	VARCHAR(8000)
	DECLARE @sSql				AS 	VARCHAR(8000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	NVARCHAR(50)

	DECLARE @SMId				AS	INT
	DECLARE @RMId				AS	INT
	DECLARE @RtrId				AS	INT
	DECLARE @RtrId1				AS	INT

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @RtrId1 =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @RtrId=0

	CREATE TABLE #RptAkzoRetAccStatement
	(
			[Description]       NVARCHAR(200),
			[RtrId]				INT,
			[RtrCode]           NVARCHAR(200),
			[RtrName]           NVARCHAR(200),
			[DocRefNo]          NVARCHAR(200),
			[Date]				NVARCHAR(10),
			[Debit]				NUMERIC (38,6),
			[Credit]			NUMERIC (38,6),
			[Balance]			NUMERIC (38,6),
			[TransactionDet]    NVARCHAR(200),
			[CheqorDueDate]     NVARCHAR(10),
			[SeqNo]				INT,
			[UserId]			INT
	)

	SET @TblName = 'RptAkzoRetAccStatement'
	SET @TblStruct = '	[Description]       NVARCHAR(200),
						[RtrId]				INT,
						[RtrCode]           NVARCHAR(200),
						[RtrName]           NVARCHAR(200),
						[DocRefNo]          NVARCHAR(200),
						[Date]				NVARCHAR(10),
						[Debit]				NUMERIC (38,6),
						[Credit]			NUMERIC (38,6),
						[Balance]			NUMERIC (38,6),
						[TransactionDet]    NVARCHAR(200),
						[CheqorDueDate]     NVARCHAR(10),
						[SeqNo]				INT
						[UserId]			INT'
	SET @TblFields = '  [Description],[RtrId],[RtrCode],[RtrName],[DocRefNo],[Date],[Debit],[Credit],
						[Balance],[TransactionDet],[CheqorDueDate],[SeqNo],[UserId]'

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
		Exec Proc_RetailerAccountStment @FromDate,@ToDate,@RtrId

		INSERT INTO #RptAkzoRetAccStatement ([Description],[RtrId],DocRefNo,Date,Debit,Credit,Balance,
											 TransactionDet,CheqorDueDate,SeqNo,UserId)
			/*	Calculate Opening Balance Details  */	
		Select  
				'Opening Balance'   [Description],RtrId, '' DocRefNo, convert(Varchar(10),@FromDate,121) Date,
				 0 as Debit,0 As Credit,BalanceAmount as balance,
				'' as TransactionDet,'' CheqorDueDate,1 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement  (NoLock) 
		Where	Details = 'Opening Balance'
				
 				 
				/*	Calculate Sales Details  */ 
		UNION ALL 
		Select  
				'Invoice' [Description],B.RtrId,SalInvNo DocRefNo,convert(Varchar(10),SalInvDate,121)  Date,
				DbAmount Debit,0 as Credit,0 Balance,'' as TransactionDet,
				convert(Varchar(10),SalDlvDate,121) CheqorDueDate,2 SeqNo, @Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 
		UNION ALL
		Select  
				'Total Invoice IN' [Description],B.RtrId,'' DocRefNo,'' Date,
				0 Debit,0 as Credit, Isnull(SUM(DbAmount),0) Balance,'' as TransactionDet,
				'' CheqorDueDate,3 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 
		GROUP BY B.RtrId
					/*	Calculate Cheque Details  */
		UNION ALL		
		Select  
				'Cheque Received' [Description],SI.RtrId,RI.InvRcpNo DocRefNo,convert(Varchar(10),InvRcpDate,121)  Date,
				0 Debit,Sum(RI.SalInvAmt)  as Credit, 0 Balance,InvInsNo as TransactionDet,
				Isnull(convert(Varchar(10),InvInsDate,121),'') CheqorDueDate,4 SeqNo, @Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock),		SalesInvoice SI (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
				AND T.Rtrid  = CASE @RtrId WHEN 0 THEN T.RtrId ELSE @RtrId END And RI.SalId = SI.SalId 
				And T.RtrId = SI.RtrId		AND SI.SalInvNo = T.Refno
				AND  CancelStatus = 1
		Group By
				SI.RtrId,RI.InvRcpNo,InvRcpDate,InvInsNo,InvInsDate 
		UNION ALL
		Select  
				'Total Receipt Received' [Description],SI.RtrId,'' DocRefNo,'' Date,
				0 Debit,0  as Credit, (-1) * Isnull(Sum(RI.SalInvAmt),0) Balance,'' as TransactionDet,
				'' CheqorDueDate,5 SeqNo,@Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock),		SalesInvoice SI (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
				AND T.Rtrid  = @RtrId       And RI.SalId = SI.SalId 
				And T.RtrId = SI.RtrId		AND SI.SalInvNo = T.Refno
				AND  CancelStatus = 1
		GROUP BY SI.RtrId

				/*	Calculate Debit Note Details  */
		UNION ALL
		Select 'Debit Note - CD' AS [Description],A.RtrId,DBNoteNumber DocRefNo,convert(Varchar(10),DBNoteDate,121)  Date,
				Isnull(DbAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'' CheqorDueDate,6 SeqNo,@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'	
		UNION ALL
		Select 'Total Debit Notes' AS [Description],A.RtrId,'' DocRefNo,'' Date,
				0 Debit,0 as Credit, Isnull(Sum(DbAmount - CRAmount),0) Balance,'' as TransaonDet,
				'' CheqorDueDate,7 SeqNo,@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'
		GROUP BY A.RtrId
				
				/*  Calculate Return  Details  */
		UNION ALL
		Select  'Credit Invoice',A.RtrId,ReturnCode DocRefNo,convert(Varchar(10),ReturnDate,121)  Date,
				0 as Debit,CrAmount as Credit,0 as  Balance,Isnull(DocRefNo,'') as TransaonDet,
				'' CheqorDueDate,8 SeqNo,@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
		UNION ALL
		Select  'Total Credit Invoice',A.RtrId,'' DocRefNo,'' Date,
				0 as Debit,0 as Credit,Isnull(Sum(CrAmount),0) * (-1) as  Balance,
				'' as TransaonDet,
				'' CheqorDueDate,9 SeqNo,@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
		GROUP BY A.RtrId
	
 				/*  Calculate Credit Note  Details  */
		UNION ALL
		Select 'Credit Note' AS [Description],A.RtrId,CRNoteNumber DocRefNo,convert(Varchar(10),CRNoteDate,121)  Date,
				Isnull(DBAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'' CheqorDueDate,10 SeqNo,@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'	
		UNION ALL
		Select 'Total Credit Notes' AS [Description],A.RtrId,'' DocRefNo,'' Date,
				0 Debit,0 as Credit,-(1) * Isnull(Sum(CRAmount-DBAmount),0) Balance,'' as TransaonDet,
				'' CheqorDueDate,11 SeqNo,@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'
		GROUP BY A.RtrId
					/*  Calculate Return & Replacement  Details  */
		Union ALL
		Select 
				'Return & Replacement-Replacement' AS [Description],A.RtrId,RepRefNo DocRefNo,convert(Varchar(10),RepDate,121)   Date,
				DBAmount Debit,0 Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'' CheqorDueDate,12 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Replacement'
		Union ALL
		Select 
				'Total Return & Replacement-Replacement' AS [Description],A.RtrId,'' DocRefNo,''  Date,
				0 Debit,0 Credit,Isnull(Sum(DBAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,13 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Replacement'
		GROUP BY A.RtrId

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Return' AS [Description],A.RtrId,RepRefNo DocRefNo,convert(Varchar(10),RepDate,121)  Date,
				0 Debit,CRAmount Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'' CheqorDueDate,14 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Return'
		Union ALL
		Select 
				'Total Return & Replacement-Return' AS [Description],A.RtrId,'' DocRefNo,''  Date,
				0 Debit,0 Credit,(-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,15 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Return'
		GROUP BY A.RtrId
					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cheque Bounce' AS [Description],RtrId,InvRcpNo, convert(Varchar(10),InvRcpDate,121)     Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'' CheqorDueDate,16 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cheque Bounce'
		Union ALL
		Select 
				'Total Collection-Cheque Bounce' AS [Description],RtrId,'' DocRefNo,''  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,17 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cheque Bounce'
		GROUP BY RtrId

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cash Cancellation' AS [Description],RtrId,InvRcpNo, convert(Varchar(10),InvRcpDate,121)  Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'' CheqorDueDate,18 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cash Cancellation'
		Union ALL
		Select 
				'Total Collection-Cash Cancellation' AS [Description],RtrId,'' DocRefNo,''  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,19 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cash Cancellation'
		GROUP BY RtrId

				/*  Calculate Retailer On Account Details  */
		Union ALl
		Select 
				'Retailer On Account' AS [Description],A.RtrId,RtrAccRefNo,  convert(Varchar(10),ChequeDate,121)   Date,
				DbAmount Debit,0 Credit,0 Balance ,Remarks DocRefNo,
				'' CheqorDueDate,20 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , RetailerOnAccount A (Nolock)
		WHERE
				A.RtrAccRefNo = T.DocumentNo AND Details = 'Retailer On Account'
		Union ALL
		Select 
				'Total Retailer On Account' AS [Description],RtrId,'' DocRefNo,''  Date,
				0 Debit,0 Credit, (-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,21 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Retailer On Account'
		GROUP BY RtrId

				/*  Calculate Closing Balance Details  */
		UNION ALL
		Select  
				'Closing Balance' [Description],RtrId, '' DocRefNo,convert(Varchar(10),@ToDate,121)  Date,
				0 as Debit,0 Credit, 0  Balance,
				'' as TransactionDet,'' CheqorDueDate,22 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement 
		Where
				Details = 'Closing Balance'	

--		DECLARE @ClBal Numeric(18,4)
--		Select RtrId,Sum(Balance) AS BalAmt  From  #RptAkzoRetAccStatement 
--		Where SeqNo in (1,3,5,7,9,11,13,15,17,19,21) GROUP BY RtrId
				
		Update A Set Balance = BalAmt FROM #RptAkzoRetAccStatement A INNER JOIN
		(Select RtrId,Sum(Balance) AS BalAmt  From  #RptAkzoRetAccStatement 
		 Where SeqNo in (1,3,5,7,9,11,13,15,17,19,21) GROUP BY RtrId) B
		ON A.RtrId=B.RtrId Where SeqNo = 22


	END

	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptAkzoRetAccStatement

	Delete From #RptAkzoRetAccStatement 
	WHere Balance  = 0 and SeqNo  in (3,5,7,9,11,13,15,17,19,21)

	UPDATE A SET A.RtrCode=B.RtrCode,A.Rtrname=B.RtrName FROM #RptAkzoRetAccStatement A
	INNER JOIN Retailer B ON A.RtrId=B.RtrId

	IF @RtrId1>0
	BEGIN
		DELETE FROM #RptAkzoRetAccStatement WHERE RtrId NOT IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) 				
	END

--	IF @RtrId>0
--	BEGIN
--		Select * from #RptAkzoRetAccStatement Order by SeqNo,[Description],RtrId
--	END
--	ELSE
--	BEGIN
--		DELETE FROM #RptAkzoRetAccStatement WHERE RtrId NOT IN
--		(SELECT DISTINCT RtrId FROM #RptAkzoRetAccStatement WHERE SeqNo BETWEEN 2 AND 21 AND UserId = @Pi_UsrId)
--		Select * from #RptAkzoRetAccStatement Order by RtrId,SeqNo,[Description]
--	END

	Select * from #RptAkzoRetAccStatement Order by SeqNo,[Description],RtrId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-223-004-From Vasanth

IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptCurrentStockAN' AND Xtype='P')
DROP procedure [Proc_RptCurrentStockAN] 
GO
-- EXEC [Proc_RptCurrentStockAN] 221,2,0,'PARLEFRESHDB',0,0,1,0
CREATE PROC [dbo].[Proc_RptCurrentStockAN]
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
BEGIN
-- =============================================
-- Author:		R.Vasantharaj
-- Create date: 17/03/2011
-- Description:	Current Stock Report
-- =============================================
SET NOCOUNT ON
	DECLARE @NewSnapId  AS INT
	DECLARE @DBNAME  AS  nvarchar(50)
	DECLARE @TblName  AS nvarchar(500)
	DECLARE @TblStruct  AS nVarchar(4000)
	DECLARE @TblFields  AS nVarchar(4000)
	DECLARE @sSql  AS  nVarChar(4000)
	DECLARE @ErrNo   AS INT
	DECLARE @PurDBName AS nVarChar(50)
	--Filter Variable
	DECLARE @CmpId          AS Int
	DECLARE @LcnId          AS Int
	DECLARE @CmpPrdCtgId  AS Int
	DECLARE @PrdCtgMainId  AS Int
	DECLARE @StockValue      AS Int
	DECLARE @PrdCatId  AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @CtgValue      AS Int
	DECLARE @PrdCatValId      AS Int
	DECLARE @DisplayLevel       AS Int
	DECLARE @PrdId        AS Int
	DECLARE @SupZeroStock	AS INT
	DECLARE @StockType	AS INT
	            
	--Till Here
	--Assgin Value for the Filter Variable
    SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
    SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
    SET @PrdCatValId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
--    SET @PrdCatValId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
    SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @DisplayLevel = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,260,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
    --SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(221,260,2)
    EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
--    select @CtgValue,@PrdCatValId 
	CREATE TABLE #RPTCURRENTSTOCKAN
	(
		[CmpPrdCtgId]						INT,
		[Product Hierarchy Level Value]     NVARCHAR(200),
		[PrdCtgValMainId]					INT,
		[PrdCtgValCode]						NVARCHAR(300),
		[Description]						NVARCHAR(300),
		[PrdId]								INT,
		[Product Code]						NVARCHAR(200),
		[Product Name]						NVARCHAR(300),
		[LcnId]								INT,
		[Location Name]						NVARCHAR(300),
		[SystemStockType]					TINYINT,
		[Stock Type]						NVARCHAR(100),
		[Quantity Packs]					INT,
		[PrdUnitId]							INT,
		[Quantity In Volume(Unit)]			NUMERIC(18,2),
		[Quantity In Volume(KG)]            NUMERIC(18,2),
		[Quantity In Volume(Litre)]         NUMERIC(18,2),
		[Value]								NUMERIC(18,2)
	)
	SET @TblName = 'RPTCURRENTSTOCK'
	SET @TblStruct = '  [CmpPrdCtgId]						INT,
						[Product Hierarchy Level Value]     NVARCHAR(200),
						[PrdCtgValMainId]					INT,
						[PrdCtgValCode]						NVARCHAR(300),
						[Description]						NVARCHAR(300),
						[PrdId]								INT,
						[Product Code]						NVARCHAR(200),
						[Product Name]						NVARCHAR(300),
						[LcnId]								INT,
						[Location Name]						NVARCHAR(300),
						[SystemStockType]					TINYINT,
						[Stock Type]						NVARCHAR(100),
						[Quantity Packs]					INT,
						[PrdUnitId]							INT,
						[Quantity In Volume(Unit)]			NUMERIC(18,2),
						[Quantity In Volume(KG)]            NUMERIC(18,2),
						[Quantity In Volume(Litre)]         NUMERIC(18,2),
						[Value]								NUMERIC(18,2)'
	SET @TblFields = '[CmpPrdCtgId],[Product Hierarchy Level Value],[PrdCtgValMainId],[PrdCtgValCode],[Description],[PrdId],[Product Code],
					  [Product Name],[LcnId],[Location Name],[SystemStockType],[Stock Type],[Quantity Packs],[PrdUnitId],
					  [Quantity In Volume(Unit)],[Quantity In Volume(KG)],[Quantity In Volume(Litre)],[Value]'
IF @DisplayLevel=2
BEGIN
	INSERT INTO #RPTCURRENTSTOCKAN ([CmpPrdCtgId],[Product Hierarchy Level Value],[PrdCtgValMainId],[PrdCtgValCode],[Description],
									[LcnId],[Location Name],[SystemStockType],[Stock Type],[Quantity Packs],[PrdUnitId],
									[Quantity In Volume(Unit)],[Quantity In Volume(KG)],[Quantity In Volume(Litre)],[Value])
	SELECT DISTINCT G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
	/*F.PrdId,F.PrdCCode,F.PrdName,*/F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,sum(BaseQty),PrdUnitId,sum(PrdOnUnit),sum(PrdOnKg),
	sum(PrdOnLitre),sum(SumValue)
		FROM ProductCategoryValue C
		INNER JOIN(Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
				A.Prdid from Product A
		INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
			      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
			       A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		INNER JOIN 
	              (SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,0 AS BaseQty,
	               B.PrdUnitId,0 AS PrdOnUnit,0 AS PrdOnKg,0 AS PrdOnLitre,0 as SumValue
	               FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId 

		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)))) F ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 	
		INNER JOIN 
		(SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,
		CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END AS BaseQty,
		B.PrdUnitId,0 AS PrdOnUnit,
		ISNULL(CASE B.PrdUnitId WHEN 2 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 3 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnKg,
		ISNULL(CASE B.PrdUnitId WHEN 4 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 5 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnLitre,
		(CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)* G.SellingRate as SumValue
		FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId  
		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		INNER JOIN DefaultPriceHistory G ON A.PrdId=G.PrdId AND G.CurrentDefault=1 AND A.PrdBatId=G.PrdbatId

		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))) GROUP BY 
		A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,B.PrdUnitId,B.PrdWgt,G.SellingRate) F ON D.PrdId=F.PrdId 
		INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
		WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
		ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
		AND ( F.PrdId = (CASE @PrdCatValId WHEN 0 THEN F.PrdId ELSE @PrdCatValId END) OR
		F.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND
		(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
		G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	   GROUP BY G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
		/*F.PrdId,F.PrdCCode,F.PrdName,*/F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,PrdUnitId
END
ELSE
BEGIN
	INSERT INTO #RPTCURRENTSTOCKAN
	SELECT DISTINCT G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
	F.PrdId,F.PrdCCode,F.PrdName,F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,BaseQty,PrdUnitId,PrdOnUnit,PrdOnKg,
	PrdOnLitre,SumValue
		FROM ProductCategoryValue C
		INNER JOIN(Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
				A.Prdid from Product A
		INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
			      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
			      A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		INNER JOIN 
	              (SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,0 AS BaseQty,
	              B.PrdUnitId,0 AS PrdOnUnit,0 AS PrdOnKg,0 AS PrdOnLitre,0 as SumValue
	              FROM ProductBatchLocation A 
	    INNER JOIN Product B ON A.PrdId=B.PrdId 

		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)))) F ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 	
		INNER JOIN 
		(SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,
		CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END AS BaseQty,
		B.PrdUnitId,0 AS PrdOnUnit,
		ISNULL(CASE B.PrdUnitId WHEN 2 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 3 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnKg,
		ISNULL(CASE B.PrdUnitId WHEN 4 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 5 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnLitre,
		(CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)* G.SellingRate as SumValue
		FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId  
		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		INNER JOIN DefaultPriceHistory G ON A.PrdId=G.PrdId AND G.CurrentDefault=1 AND A.PrdBatId=G.PrdbatId

		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))) GROUP BY 
		A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,B.PrdUnitId,B.PrdWgt,G.SellingRate) F ON D.PrdId=F.PrdId 
		INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
		WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
		ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
		AND ( F.PrdId = (CASE @PrdCatValId WHEN 0 THEN F.PrdId ELSE @PrdCatValId END) OR
		F.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND
		(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
		G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))

END

--      Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RPTCURRENTSTOCKAN
--	 Till Here

IF @SupZeroStock=1
	BEGIN 
		SELECT  * FROM #RPTCURRENTSTOCKAN WHERE [Quantity Packs]<>0 
    END
	ELSE
		SELECT * FROM #RPTCURRENTSTOCKAN 

    END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptRtrPrdWiseSales' AND Xtype='P')
DROP procedure [Proc_RptRtrPrdWiseSales]
GO
--select * from ReportfilterDt where rptid = 90 And selid = 66
--EXEC Proc_RptRtrPrdWiseSales 220,2,0,'ASKO',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptRtrPrdWiseSales]
/************************************************************
* PROCEDURE	: Proc_RptRtrPrdWiseSales
* PURPOSE	: Retailer and Product Wise Sales Volume
* CREATED BY	: Boopathy.P
* CREATED DATE	: 14/03/2011
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
	@Pi_CurrencyId		INT	
)
AS
SET NOCOUNT ON
BEGIN
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	nvarchar(50)
	DECLARE @TblName 		AS	nvarchar(500)
	DECLARE @TblStruct 		AS	nVarchar(4000)
	DECLARE @TblFields 		AS	nVarchar(4000)
	DECLARE @SSQL			AS 	VarChar(8000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @RMId			AS	INT
	DECLARE @SMId			AS	INT
	DECLARE @RtrId 			AS 	INT
	DECLARE @CmpId 			AS 	INT
	DECLARE @PrdCatLvlId 	AS 	INT
	DECLARE @PrdCatValId 	AS 	INT
	DECLARE @PrdId 			AS 	INT
	DECLARE @Display		AS 	INT
    DECLARE @PrdCatId       AS  INT

	CREATE  TABLE #RptRtrPrdWiseSales
		(
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			BaseQty				NUMERIC(18,0),
			PrdUnitId			INT,
			PrdOnUnit			NUMERIC(18,0),
			PrdOnKg				NUMERIC(18,6),
			PrdOnLitre			NUMERIC(18,6),
			PrdNetAmount		NUMERIC(18,6),
			DispMode			INT
		)


	SET @SMId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CmpId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdCatLvlId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
--	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
    SET @PrdCatValId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @Display = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,260,@Pi_UsrId))

    EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	IF @CmpId=0
	BEGIN
		SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
	END
	

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	
	SET @TblName = 'RptRtrPrdWiseSales'
	
	SET @TblStruct ='		
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			PrdUnitId			INT,
			PrdOnUnit			NUMERIC(18,0),
			PrdOnKg				NUMERIC(18,6),
			PrdOnLitre			NUMERIC(18,6),
			PrdNetAmount		NUMERIC(18,6),
			DispMode			INT'					
	
	SET @TblFields = 'RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
			PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode'
			
	IF @Display=2
	BEGIN
		IF (@PrdCatLvlId=0 AND @PrdCatValId=0 AND @PrdId=0) OR 
			(@PrdCatLvlId>0 AND @PrdCatValId=0 AND @PrdId=0) OR
			(@PrdCatLvlId>0 AND @PrdCatValId>0 AND @PrdId=0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   0,'','',PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( F.PrdId = (CASE @PrdCatValId WHEN 0 THEN F.PrdId ELSE @PrdCatValId END) OR					
					F.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,-1*F.PrdOnUnit,-1*F.PrdOnKg,-1*F.PrdOnLitre,-1*F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( F.PrdId= (CASE @PrdCatValId WHEN 0 THEN F.PrdId ELSE @PrdCatValId END) OR					
					F.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdUnitId
		END
		ELSE --IF (@PrdCatLvlId>0 AND @PrdCatValId>0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   PrdId,PrdCCode,Prdname,PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),1 FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE 0 END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( F.PrdId = (CASE @PrdCatValId WHEN 0 THEN F.PrdId ELSE @PrdCatValId END) OR					
					F.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,-1*F.PrdOnUnit,-1*F.PrdOnKg,-1*F.PrdOnLitre,-1*F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( F.PrdId= (CASE @PrdCatValId WHEN 0 THEN F.PrdId ELSE @PrdCatValId END) OR					
					F.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdId,PrdCCode,Prdname,PrdUnitId
		END
	END
	ELSE
	BEGIN
		INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
				PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
		SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			   PrdId,PrdCCode,Prdname,PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
			(
			SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
						WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
						ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
							FROM salesInvoice A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
							FROM salesInvoice A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( F.PrdId = (CASE @PrdCatValId WHEN 0 THEN F.PrdId  ELSE @PrdCatValId END) OR					
				F.PrdId  IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			UNION
			SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,-1*F.PrdOnUnit,-1*F.PrdOnKg,-1*F.PrdOnLitre,-1*F.PrdNetAmount 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
						WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
						ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( F.PrdId = (CASE @PrdCatValId WHEN 0 THEN F.PrdId ELSE @PrdCatValId END) OR					
				F.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ) A
				GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			    PrdId,PrdCCode,Prdname,PrdUnitId
	END
	UPDATE #RptRtrPrdWiseSales SET BaseQty=PrdOnUnit
	UPDATE #RptRtrPrdWiseSales SET PrdOnUnit=0 WHERE PrdUnitId>1
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptRtrPrdWiseSales
	SELECT * FROM #RptRtrPrdWiseSales 

	DELETE FROM RptRtrPrdWiseSales_Excel
	INSERT INTO RptRtrPrdWiseSales_Excel(RtrCode,RtrName,CmpPrdCtgName,PrdCtgValName,PrdCCode,PrdName,BaseQty,SalVolume,PrdNetAmount)
	SELECT RtrCode,RtrName,CmpPrdCtgName,PrdCtgValName,PrdCCode,PrdName,BaseQty,PrdOnUnit+PrdOnKg+PrdOnLitre,PrdNetAmount from #RptRtrPrdWiseSales 

RETURN
END
GO

if not exists (select * from hotfixlog where fixid = 370)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(370,'D','2011-04-02',getdate(),1,'Core Stocky Service Pack 370')
