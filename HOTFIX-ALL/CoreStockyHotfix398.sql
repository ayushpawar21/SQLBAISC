--[Stocky HotFix Version]=398
DELETE FROM Versioncontrol WHERE Hotfixid='398'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('398','2.0.0.5','D','2012-01-19','2012-01-19','2012-01-19',convert(varchar(11),getdate()),'JNJ-Major: Product Release Dec CR')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 398' ,'398'
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptCollectionValue')
DROP TABLE RptCollectionValue
GO
CREATE TABLE [dbo].[RptCollectionValue](
	[SalId] [bigint] NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvRef] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[SMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvRcpDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RMId] [int] NULL,
	[RMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DlvRMId] [int] NULL,
	[DelRMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BillAmount] [numeric](38, 6) NULL,
	[CrAdjAmount] [numeric](38, 6) NULL,
	[DbAdjAmount] [numeric](38, 6) NULL,
	[CashDiscount] [numeric](38, 6) NULL,
	[CollectedAmount] [numeric](38, 6) NULL,
	[PayAmount] [numeric](38, 6) NULL,
	[CurPayAmount] [numeric](38, 6) NULL,
	[CollCashAmt] [numeric](38, 6) NULL,
	[CollChqAmt] [numeric](38, 6) NULL,
	[CollDDAmt] [numeric](38, 6) NULL,
	[CollRTGSAmt] [numeric](38, 6) NULL,
	[InvRcpNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	
	
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_CollectionValues')
DROP PROCEDURE Proc_CollectionValues
GO
--EXEC Proc_CollectionValues 1
CREATE PROCEDURE [dbo].[Proc_CollectionValues]
(
	@Pi_TypeId INT
)
/**********************************************************************************
* PROCEDURE		: Proc_CollectionValues
* PURPOSE		: To Display the Collection details
* CREATED		: MarySubashini.S
* CREATED DATE	: 01/06/2007
* NOTE			: General SP for Returning the Collection details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 01-09-2009	Thiruvengadam.L		CR changes
* 08-12-2009	Thiruvengadam.L		Cheque and DD are displayed in single column	
************************************************************************************/
AS
BEGIN	
SET NOCOUNT ON
	DECLARE @SalId AS BIGINT
	DECLARE @InvRcpDate AS DATETIME
	DECLARE @CrAdjAmount AS NUMERIC (38, 6)
	DECLARE @DbAdjAmount AS NUMERIC (38, 6)
	DECLARE @SalNetAmt AS NUMERIC (38, 6)
	DECLARE @CollectedAmount AS NUMERIC (38, 6)
	DECLARE @Count AS INT
	DECLARE @Prevamount AS NUMERIC (38, 6)
	DECLARE @CurPrevamount AS NUMERIC (38, 6)
	DECLARE @PrevSalId AS BIGINT
	DELETE FROM RptCollectionValue	
	
	INSERT INTO RptCollectionValue (SalId ,SalInvDate,SalInvNo,SalInvRef,
				SMId ,SMName,InvRcpDate,RtrId ,
				RtrName ,RMId ,RMName ,DlvRMId ,
				DelRMName ,BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollectedAmount,PayAmount,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo)
	SELECT SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,
	 SalNetAmt AS BillAmount,
	 SUM(CrAdjAmount) AS CrAdjAmount,SUM(DbAdjAmount) AS DbAdjAmount,
	 SUM(CashDiscount) AS CashDiscount,
	 SUM(CollectedAmount) AS CollectedAmount,
	 SUM(PayAmount) AS PayAmount, SUM(PayAmount) AS CurPayAmount,
	 SUM(CollCashAmt) AS CollCashAmt,SUM(CollChqAmt) AS CollChqAmt,SUM(CollDDAmt) AS CollDDAmt,SUM(CollRTGSAmt) AS CollRTGSAmt,InvRcpNo
	FROM(
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (1) --AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				SUM(RI.DebitAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (1) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
		    SUM(RI.SalInvAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,SUM(RI.DebitAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
					AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    SUM(RI.SalInvAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (4)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,SUM(RI.DebitAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (4) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    0 AS CollDDAmt,SUM(RI.SalInvAmt) AS  CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (8)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,SUM(RI.DebitAmt) AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (8) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			SUM(RI.SalInvAmt) AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=5 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				SUM(RI.DebitAmt) AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (5) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			SUM(RI.SalInvAmt) AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=6 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpMode,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,SUM(RI.SalInvAmt) AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=2 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,SUM(RI.DebitAmt) AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (2) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
--->Commented By Nanda to Remove On Account(Need to check thoroughly on Exccess Collections)
--	UNION
--		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,
--			RMD.RMName as DelRMName,0 AS CrAdjAmount,0 AS DbAdjAmount,
--			0 AS CashDiscount,0 AS SalNetAmt,
--			ISNULL(ROA.Amount,0) AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
--			0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
--		FROM ReceiptInvoice RI WITH (NOLOCK),
--			Receipt RE WITH (NOLOCK),
--			Retailer R WITH (NOLOCK),
--		        Salesman SM WITH (NOLOCK),
--			RouteMaster RM WITH (NOLOCK),
--			RouteMaster RMD WITH (NOLOCK),
--			RetailerOnAccount ROA WITH (NOLOCK),
--			SalesInvoice SI WITH (NOLOCK)
--		WHERE ROA.RtrId=R.RtrId AND SI.SMId=SM.SMId
--		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
--			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo
--			AND ROA.LastModDate=RE.InvRcpDate
--			AND ROA.TransactionType=0 AND ROA.OnAccType=0 AND ROA.RtrId=SI.RtrId
--		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--		 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
--		 ROA.Amount,RI.InvRcpNo
--->Till Here
			) A
	GROUP BY SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 	InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,SalNetAmt,InvRcpNo
	IF NOT EXISTS (SELECT SalId FROM RptCollectionValue WHERE SalId<>0)
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalId,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalId=B.SalId AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalId,A.InvRcpDate) A WHERE A.SalId=RptCollectionValue.SalId
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	ELSE
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalInvNo,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate) A WHERE A.SalInvNo=RptCollectionValue.SalInvNo
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	
--	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollectedAmount+CashDiscount+CrAdjAmount-DbAdjAmount-PayAmount) WHERE BillAmount>0
	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollCashAmt+CollChqAmt+CollDDAmt+CollRTGSAmt+CashDiscount+CrAdjAmount-DbAdjAmount) WHERE BillAmount>0

END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptCollectionReport')
DROP PROCEDURE Proc_RptCollectionReport
GO
--EXEC Proc_RptCollectionReport 4,1,0,'CoreStocky',0,0,1
 CREATE PROCEDURE [dbo].[Proc_RptCollectionReport]
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
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (5,6)
	END
	ELSE
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (5,6)
	END 
	Create TABLE #RptCollectionDetail
	(
		SalId 			BIGINT,
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
		AmtStatus 			NVARCHAR(10),
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
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		
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
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptProductWise')
DROP TABLE RptProductWise
GO
CREATE TABLE [dbo].[RptProductWise](
	[SalId] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[CmpId] [int] NULL,
	[LcnId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdUnitMRP] [numeric](38, 6) NULL,
	[PrdUnitSelRate] [numeric](38, 6) NULL,
	[FreeQty] [int] NULL,
	[RepQty] [int] NULL,
	[ReturnQty] [int] NULL,
	[SalesQty] [int] NULL,
	[SalesGrossValue] [numeric](38, 6) NULL,
	[TaxAmount] [numeric](38, 6) NULL,
	[ReturnGrossValue] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[DlvSts] [int] NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL,
	[SalesPrdWeight] [numeric](38, 6) NULL,
	[FreePrdWeight] [numeric](38, 6) NULL,
	[RepPrdWeight] [numeric](38, 6) NULL,
	[RetPrdWeight] [numeric](38, 6) NULL
) ON [PRIMARY]

GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_ProductWiseSalesOnly')
DROP PROCEDURE Proc_ProductWiseSalesOnly
GO
--EXEC Proc_ProductWiseSalesOnly 2,2
--SELECT * FROM RptProductWise (NOLOCK)
CREATE PROCEDURE [dbo].[Proc_ProductWiseSalesOnly]
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
* {date} {developer}  {brief modification description}
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
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
		0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,RP.PrdGrossAmt,SI.DlvSts--@
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
END
GO
If Exists (Select [Name] From SysObjects Where Xtype='P' And [Name]='Proc_RptPendingBillReport')
Drop Procedure Proc_RptPendingBillReport
GO
--EXEC Proc_RptPendingBillReport 3,1,0,'Dabur1',0,0,1
Create PROCEDURE Proc_RptPendingBillReport
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
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
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
			SELECT * FROM #RptPendingBillsDetails ORDER BY SMName 
		END 
	IF @Orderby=1 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY RMName 
		END
	IF @Orderby=2 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY RtrName 
		END
	IF @Orderby=3 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY SalInvNo 
		END
	ELSE 
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
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
Delete from RptExcelHeaders Where RptId=3
Go
Insert Into RptExcelHeaders
Select 3,1,'SMID','SMID',0,1 Union All
Select 3,2,'SmName','Sales man',1,1 Union All
Select 3,3,'RmId','RmId',0,1 Union All
Select 3,4,'RmName','Route Name',1,1 Union All
Select 3,5,'RtrId','RtrId',0,1 Union All
Select 3,6,'RtrCode','Retailer Code',1,1 Union All
Select 3,7,'RtrName','Retailer Name',1,1 Union All
Select 3,8,'SalId','SalId',0,1 Union All
Select 3,9,'SalInvNo','Bill Number',1,1 Union All
Select 3,10,'SalInvDate','Bill Date',1,1 Union All
Select 3,11,'SalInvRef','DocRefNo',0,1 Union All
Select 3,12,'BillAmount','Bill Amount',1,1 Union All
Select 3,13,'Cash','Cash',1,1 Union All
Select 3,14,'ChequeAmt','Cheque Amount',1,1 Union all
Select 3,15,'ChequeNo','Cheque Number',1,1 Union All
Select 3,16,'CollectedAmount','Collected Amount',1,1 Union All
Select 3,17,'BalanceAmount','Balance Amount',1,1 Union All
Select 3,18,'ArDays','AR Days',1,1 Union All
Select 3,19,'OrderBy','Order By',0,1
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'U' And Name = 'TempDatewiseProductwiseSales')
DROP TABLE TempDatewiseProductwiseSales
GO
CREATE TABLE TempDatewiseProductwiseSales(
	[SalId] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[PrdId] [bigint] NULL,
	[PrdCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CmpId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[SellingRate] [numeric](38, 6) NULL,
	[BaseQty] [int] NULL,
	[FreeQty] [int] NULL,
	[GrossAmount] [numeric](38, 6) NULL,
	[SplDiscAmount] [numeric](38, 6) NULL,
	[SchDiscAmount] [numeric](38, 6) NULL,
	[DBDiscAmount] [numeric](38, 6) NULL,
	[CDDiscAmount] [numeric](38, 6) NULL,
	[TaxAmount] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[UsrId] [int] NULL,
	[DlvSts] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'U' And Name = 'RptBillTemplate_Scheme')
DROP TABLE RptBillTemplate_Scheme
GO
CREATE TABLE [dbo].[RptBillTemplate_Scheme](
	[SalId] [int] NULL,
	[SalInvNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchId] [int] NULL,
	[SchType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CmpSchCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdId] [int] NULL,
	[PrdCCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdDCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdShrtName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qty] [numeric](38, 0) NULL,
	[Rate] [numeric](38, 6) NULL,
	[SchemeValueInAmt] [numeric](38, 6) NULL,
	[SchemeValueInPoints] [numeric](38, 0) NULL,
	[SalInvSchemevalue] [numeric](38, 0) NULL,
	[SchemeCumulativePoints] [numeric](38, 0) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
Update Product Set PrdShelfLife=180
GO
Update Configuration SET Status=0,condition=0 WHERE ModuleId='GENCONFIG18'
GO
Update Uomgroup Set ConversionFactor = 20 Where UOMGroupDescription = 'GR-112' And UomGroupId = 16 And Uomid = 1
GO
--Current Stock Report Parle
Delete From RptGroup Where Rptid = 240
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName]) 
VALUES ('ParleReports',240,'CurrentStockReportParle','Current Stock Report')
GO
Delete from RptHeader Where RptId = 240
INSERT INTO RptHeader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds]) 
VALUES ('CurrentStockReportParle','Current Stock Report','240','Current Stock Report','Proc_RptCurrentStockParle','RptCurrentStockParle','RptCurrentStockParle.rpt',' ')
GO
Delete From RptDetails Where RptId = 240
INSERT INTO RptDetails SELECT	240,	1,	'Company',	-1,	NULL,	'CmpId,CmpCode,CmpName',	'Company...',	NULL,	1,	NULL,	4,	1,	NULL,	'Press F4/Double Click to select Company',0
INSERT INTO RptDetails SELECT	240,	2,	'Location',	-1,	NULL,	'LcnId,LcnCode,LcnName',	'Location...',	NULL,	1,	NULL,	22,	NULL,	NULL,	'Press F4/Double Click to select Location',0
INSERT INTO RptDetails SELECT	240,	3,	'ProductCategoryLevel',	1,	'CmpId',	'CmpPrdCtgId,CmpPrdCtgName,LevelName',	'Product Hierarchy Level...',	'Company',	1,	'CmpId',	16,	1,	NULL,	'Press F4/Double Click to select Product Hierarchy Level',0
INSERT INTO RptDetails SELECT	240,	4,	'ProductCategoryValue',	3,	'CmpPrdCtgId',	'PrdCtgValMainId,PrdCtgValCode,PrdCtgValName',	'Product Hierarchy Level Value...',	'ProductCategoryLevel',	1,	'CmpPrdCtgId',	21,	NULL,	NULL,	'Press F4/Double Click to select Product Hierarchy Level Value',1
INSERT INTO RptDetails SELECT	240,	5,	'Product',	4,	'PrdCtgValMainId',	'PrdId,PrdDCode,PrdName',	'Product...',	'ProductCategoryValue',	1,	'PrdCtgValMainId',	5,	NULL,	NULL,	'Press F4/Double Click to select Product',0
INSERT INTO RptDetails SELECT	240,	6,	'RptFilter',	-1,	NULL,	'FilterId,FilterDesc,FilterDesc',	'Stock Value as per*...',	NULL,	1,	NULL,	23,	1,	1,	'Press F4/Double Click to select Stock Value',0
INSERT INTO RptDetails SELECT	240,	7,	'RptFilter',	-1,	NULL,	'FilterId,FilterDesc,FilterDesc',	'Product Status...',	NULL,	1,	NULL,	24,	1,	NULL,	'Press F4/Double Click to select Product Status',0
INSERT INTO RptDetails SELECT	240,	8,	'RptFilter',	-1,	NULL,	'FilterId,FilterDesc,FilterDesc',	'Batch Status...',	NULL,	1,	NULL,	25,	1,	NULL,	'Press F4/Double Click to select Batch Status',0
INSERT INTO RptDetails SELECT	240,	9,	'ProductBatch',	-1,	NULL,	'PrdBatId,PrdBatCode,PrdBatCode',	'Batch...',	NULL,	1,	NULL,	7,	0,	NULL,	'Press F4/Double Click to select Batch ',0
INSERT INTO RptDetails SELECT	240,	10,	'RptFilter',	-1,	NULL,	'FilterId,FilterDesc,FilterDesc',	'Suppress Zero Stock*...',	NULL,	1,	NULL,	44,	1,	1,	'Press F4/Double Click to Select the Supress Zero Stock',0
INSERT INTO RptDetails SELECT	240,	11,	'RptFilter',	-1,	NULL,	'FilterId,FilterDesc,FilterDesc',	'Stock Type...',	NULL,	1,	NULL,	240,	1,	0,	'Press F4/Double Click to Select Stock Type',0
GO
Delete From RptFilter Where RptId = 240
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,24,0,'ALL')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,24,1,'Active')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,24,2,'InActive')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,25,0,'ALL')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,25,2,'Active')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,25,1,'InActive')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,23,1,'Selling Rate')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,23,2,'List Price')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,23,3,'MRP')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,28,1,'Yes')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,28,2,'No')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,44,1,'Yes')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,44,2,'No')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,240,1,'Saleable')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,240,2,'UnSaleable')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (240,240,3,'Offer')
GO
Delete From RptFormula Where RptId = 240
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,1,'Product Code','Product Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,2,'Product Name','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,3,'Batch Code','Batch Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,4,'MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,5,'Saleable Stock','Saleable Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,6,'Unsaleable Stock','Unsaleable Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,7,'Offer Stock','Offer Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,8,'Sal Stock Value','Salable',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,9,'Unsal Stock Value','UnSalable',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,10,'Tot Stock Value','TotalValue',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,11,'Fil_Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,12,'Fil_Location','Location',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,13,'Fil_PrdCtgLvl','Product Category Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,14,'Fil_PrdCtgValue','Product Category Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,15,'Fil_Prd','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,16,'Fil_StockValue','Stock Value as per',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,17,'Fil_PrdStatus','Product Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,18,'Fil_BatStatus','Batch Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,19,'FilDisp_Company','ALL',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,20,'FilDisp_Location','ALL',1,22)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,21,'FilDisp_PrdCtgLvl','ALL',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,21,'FilDisp_PrdCtgValue','ALL',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,23,'FilDisp_Prd','ALL',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,24,'FilDisp_StockValue','Selling Rate with Tax',1,23)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,25,'FilDisp_PrdStatus','ALL',1,24)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,26,'FilDisp_BatStatus','ALL',1,25)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,27,'DisplayRate','Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,28,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,29,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,30,'Hd_Total','Grand Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,31,'Cap_Batch','Batch',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,32,'Disp_Batch','Batch',1,7)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,33,'Disp_SupZeroStock','Suppress Zero Stock',1,44)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,34,'Fill_SupZeroStock','Suppress Zero Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,35,'Disp_StockType','Stock Type',1,240)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (240,36,'Fill_StockType','Stock Type',1,0)
GO
Delete From RptExcelHeaders Where RptId = 240
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,1,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,2,'PrdDcode','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,3,'PrdName','Product Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,4,'PrdBatId','PrdBatId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,5,'PrdBatCode','Batch Code',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,6,'MRP','MRP',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,7,'DisplayRate','Rate',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,8,'SaleableBOX','Saleable BOX',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,9,'SaleablePKT','Saleable PKT',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,10,'UnSaleableBOX','Unsaleable BOX',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,11,'UnSaleablePKT','Unsaleable PKT',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,12,'OfferBOX','Offer BOX',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,13,'OfferPKT','Offer PKT',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,14,'DisplaySalRate','Saleable',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,15,'DisplayUnSalRate','UnSaleable',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,16,'DisplayTotRate','TotaleValue',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (240,17,'StockType','StockType',0,1)
GO
IF EXISTS (Select * From Sysobjects Where Name = 'View_CurrentStockReportParle' And Type = 'V')
DROP VIEW View_CurrentStockReportParle
GO
CREATE  VIEW View_CurrentStockReportParle
/************************************************************
* VIEW	: View_CurrentStockReport
* PURPOSE	: To get the Current Stock of the Products with Batch details
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 26/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,sum(MRP)MRP,sum(SelRate)SelRate,sum(ListPrice)ListPrice,
	Saleable,Unsaleable,Offer,Total,sum(SalMRP)SalMRP,sum(UnSalMRP)UnSalMRP,sum(TotMRP)TotMRP,sum(SalSelRate)SalSelRate,
	sum(UnSalSelRate)UnSalSelRate,sum(TotSelRate)TotSelRate,sum(SalListPrice)SalListPrice,sum(UnSalListPrice)UnSalListPrice,
	sum(TotListPrice)TotListPrice,PrdStatus,Status,CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode
FROM (
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,PBDM.PrdBatDetailValue AS MRP,
		0 AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		(PrdBatLcnSih-PrdBatLcnResSih)* PBDM.PrdBatDetailValue  AS SalMRP,
		(PrdBatLcnUih-PrdBatLcnResUih)* PBDM.PrdBatDetailValue  AS UnSalMRP,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* PBDM.PrdBatDetailValue ) AS TotMRP,
		0 AS SalSelRate,
		0 AS UnSalSelRate,
		0 AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		 ProductBatchDetails PBDM (NOLOCK),BatchCreation BCM (NOLOCK),
		 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId AND PrdBat.BatchSeqId=BCM.BatchSeqId
		AND BCM.MRP=1 AND BCM.SlNo=PBDM.SLNo AND PBDM.PrdBatId=PrdBat.PrdBatId  
		AND PrdBat.DefaultPriceId=PBDM.PriceId   
UNION ALL 
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
		PBDR.PrdBatDetailValue AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		0 AS SalMRP,
		0 AS UnSalMRP,
		0 AS TotMRP,
		(PrdBatLcnSih-PrdBatLcnResSih)* PBDR.PrdBatDetailValue  AS SalSelRate,
		(PrdBatLcnUih-PrdBatLcnResUih)* PBDR.PrdBatDetailValue  AS UnSalSelRate,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* PBDR.PrdBatDetailValue AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode--,TxRpt.UsrId
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		ProductBatchDetails PBDR (NOLOCK),BatchCreation BCR (NOLOCK),
		ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
		AND PrdBat.BatchSeqId=BCR.BatchSeqId
		AND BCR.SelRte=1 AND BCR.SlNo=PBDR.SLNo AND PBDR.PrdBatId=PrdBat.PrdBatId
		AND PrdBat.DefaultPriceId=PBDR.PriceId 
UNION ALL 
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
		0 AS SelRate,
		PBDL.PrdBatDetailValue AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		0 AS SalMRP,
		0 AS UnSalMRP,
		0 AS TotMRP,
		0 AS SalSelRate,
		0 AS UnSalSelRate,
		0 AS TotSelRate,
		(PrdBatLcnSih-PrdBatLcnResSih)* PBDL.PrdBatDetailValue  AS SalListPrice,
		(PrdBatLcnUih-PrdBatLcnResUih)* PBDL.PrdBatDetailValue  AS UnSalListPrice,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* PBDL.PrdBatDetailValue AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		ProductBatchDetails PBDL (NOLOCK),BatchCreation BCL (NOLOCK),
		ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId  
		AND PrdBat.BatchSeqId=BCL.BatchSeqId
		AND BCL.ListPrice=1 AND BCL.SlNo=PBDL.SLNo AND PBDL.PrdBatId=PrdBat.PrdBatId
		AND PrdBat.DefaultPriceId=PBDL.PriceId
)A GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Saleable,Unsaleable,Offer,Total,
			CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode,PrdStatus,Status
GO
IF EXISTS (Select * From SysObjects Where Name ='Proc_RptCurrentStockParle' And XTYPE = 'P')
DROP PROCEDURE Proc_RptCurrentStockParle
GO
--Exec Proc_RptCurrentStockParle 240,1,0,'PARLECR',0,0,1,0 
CREATE PROCEDURE Proc_RptCurrentStockParle
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
* PROCEDURE : Proc_RptCurrentStock
* PURPOSE : To get the Current Stock details for Report
* CREATED : Nandakumar R.G
* CREATED DATE : 01/08/2007
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
24/07/2009	MarySubashini.S		To add the Tax Validation
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
	--Filter Variable
	DECLARE @CmpId          AS Int
	DECLARE @LcnId          AS Int
	DECLARE @CmpPrdCtgId  AS Int
	DECLARE @PrdCtgMainId  AS Int
	DECLARE @StockValue      AS Int
	DECLARE @DispBatch  AS Int
	DECLARE @PrdStatus       AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @PrdBatStatus       AS Int
	DECLARE @SupTaxGroupId      AS Int
	DECLARE @RtrTaxFroupId      AS Int
	DECLARE @fPrdCatPrdId       AS Int
	DECLARE @fPrdId        AS Int
	DECLARE @SupZeroStock	AS INT
	DECLARE @StockType	AS INT
	DECLARE @RptDispType	AS INT
	--Till Here
	--Assgin Value for the Filter Variable
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	SET @PrdBatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @SupTaxGroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,18,@Pi_UsrId))
	SET @RtrTaxFroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,19,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
		--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
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
	Create TABLE #RptCurrentStock
	(
		PrdId            INT,
		PrdDcode         NVARCHAR(100),
		PrdName          NVARCHAR(200),
		PrdBatId         INT,
		PrdBatCode       NVARCHAR(100),
		MRP              NUMERIC (38,6),
		DisplayRate      NUMERIC (38,6),
		Saleable         INT,
		SaleableWgt	     NUMERIC (38,6),
		Unsaleable       INT,
		UnsaleableWgt	 NUMERIC (38,6),
		Offer            INT,
		OfferWgt		 NUMERIC (38,6),
		DisplaySalRate   NUMERIC (38,6),
		DisplayUnSalRate NUMERIC (38,6),
		DisplayTotRate   NUMERIC (38,6),
		StockType	     INT
		
	)
	SET @TblName = 'RptCurrentStock'
	SET @TblStruct = '  PrdId      INT,
						PrdDcode    NVARCHAR(100),
						PrdName     NVARCHAR(200),
						PrdBatId       INT,
						PrdBatCode     NVARCHAR(100),
						MRP            NUMERIC (38,6),
						DisplayRate    NUMERIC (38,6),
						Saleable       INT,
						SaleableWgt	    NUMERIC (38,6),
						Unsaleable		INT,
						UnsaleableWgt	 NUMERIC (38,6),
						Offer           INT,
						OfferWgt		 NUMERIC (38,6),
						DisplaySalRate    NUMERIC (38,6),
						DisplayUnSalRate   NUMERIC (38,6),
						DisplayTotRate     NUMERIC (38,6),
						StockType		   INT'
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,StockType'
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
	SET @Po_Errno = 0
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
	     INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,StockType)
								SELECT VC.PrdId,PrdDcode,PrdName,0,0,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,1) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,(SUM(Saleable)* P.PrdWgt),
				SUM(Unsaleable) AS Unsaleable,(SUM(Unsaleable)* P.PrdWgt),
				SUM(Offer) AS Offer,(SUM(Offer)* P.PrdWgt),
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@StockType
				FROM dbo.View_CurrentStockReportParle VC,#PrdWeight P -- Select * from View_CurrentStockReport
				WHERE VC.PrdId = P.PrdId AND
				(CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (VC.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN VC.PrdId Else 0 END) OR
				VC.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (VC.PrdId = (CASE @fPrdId WHEN 0 THEN VC.PrdId Else 0 END) OR
				VC.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))) 
				--AND	UsrId = @Pi_UsrId
				GROUP BY VC.PrdId,PrdDcode,PrdName,MRP,ListPrice,SelRate,P.PrdWgt Order By PrdDcode
				
				--UPDATE #RptCurrentStock 
				
	IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStock ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+' WHERE (CmpId=(CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
			CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',4,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (LcnId=(CASE '+CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN LcnId ELSE 0 END ) OR
			LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',22,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE '+CAST(@fPrdCatPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',26,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE'+CAST(@fPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdStatus=(CASE '+CAST(@PrdStatus AS NVARCHAR(10))+' WHEN 0 THEN PrdStatus ELSE 0 END ) OR
			PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',24,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (Status=(CASE '+CAST(@PrdBatStatus AS NVARCHAR(10))+' WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',25,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate'
			EXEC (@SSQL)
			UPDATE #RptCurrentStock SET DispBatch=@DispBatch
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCurrentStock'
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
			SET @SSQL = 'INSERT INTO #RptCurrentStock ' +
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
	IF @SupZeroStock = 1
		BEGIN
        SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
        Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
		Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
		Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
		Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
		Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
		Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
        SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
		FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
	    GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Having SUM(A.Saleable + A.UnSaleable + A.Offer)<>0 Order By A.PrdDcode
			IF EXISTS(SELECT * FROM Sysobjects WHERE Name = 'RptCurrentStockReportParle_Excel' And XTYPE = 'U')
	        DROP TABLE RptCurrentStockReportParle_Excel
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
			Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
			Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
			SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
			INTO RptCurrentStockReportParle_Excel FROM #RptCurrentStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId
			GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Having SUM(A.Saleable + A.UnSaleable + A.Offer)<>0 Order By A.PrdDcode
		    DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0

		END
		ELSE
		BEGIN
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
			Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
			Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
            SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
			FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
            GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Order By A.PrdDcode
				IF EXISTS(SELECT * FROM Sysobjects WHERE Name = 'RptCurrentStockReportParle_Excel' And XTYPE = 'U')
				DROP TABLE RptCurrentStockReportParle_Excel
				SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
				Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
				Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
				Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
				Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
				Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
				Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
				SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
				INTO RptCurrentStockReportParle_Excel FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
				GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Order By A.PrdDcode
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock
			
		END
		RETURN
END
GO
--Effective Coverage AnalysisReport
Delete From RptGroup Where RptId = 243
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName]) 
VALUES ('ParleReports',243,'EFFECTIVECOVERAGEANALYSISREPORTPARLE','Effective Coverage Analysis Report')
GO
Delete From RptHeader Where Rptid = 243
INSERT INTO RptHeader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds])
VALUES ('EFFECTIVECOVERAGEANALYSISREPORTPARLE','Effective Coverage Analysis Report','243','Effective Coverage Analysis Report','Proc_RptECAnalysisReportParle','RptECAnalysisReportParle','RptECAnalysisRouteReportParle.rpt','')
GO
Delete From RptDetails Where RptId = 243
Insert into RptDetails Select 	243,	1,	'FromDate',	-1,	'',	'',	'From Date*',	'',	1,	'',	10,	0,	1,	'Enter From Date',	0
Insert into RptDetails Select 	243,	2,	'ToDate',	-1,	'',	'',	'To Date*',	'',	1,	'',	11,	0,	1,	'Enter To Date',	0
Insert into RptDetails Select 	243,	3,	'Company',	-1,	'',	'CmpId,CmpCode,CmpName',	'Company*...',	'',	1,	'',	4,	1,	1,	'Press F4/Double Click to select Company',	0
Insert into RptDetails Select 	243,	4,	'SalesMan',	-1,	'',	'SMId,SMCode,SMName',	'SalesMan...',	'',	1,	'',	1,	1,	0,	'Press F4/Double Click to select Salesman',	0
Insert into RptDetails Select 	243,	5,	'RouteMaster',	-1,	'',	'RMId,RMCode,RMName',	'Route...',	'',	1,	'',	2,	0,	0,	'Press F4/Double Click to select Route',	0
Insert into RptDetails Select 	243,	6,	'RetailerCategoryLevel',	3,	'CmpId',	'CtgLevelId,CtgLevelName,CtgLevelName',	'Retailer Category Level...',	'Company',	1,	'CmpId',	29,	1,	0,	'Press F4/Double Click to Retailer Category Level',	0
Insert into RptDetails Select 	243,	7,	'RetailerCategory',	6,	'CtgLevelId',	'CtgMainId,CtgName,CtgName',	'Retailer Category Level Value...',	'RetailerCategoryLevel',	1,	'CtgLevelId',	30,	1,	NULL,	'Press F4/Double Click to Retailer Category Level Value',	0
Insert into RptDetails Select 	243,	8,	'RetailerValueClass',	7,	'CtgMainId',	'RtrClassId,ValueClassName,ValueClassName',	'Retailer Value Classification...',	'RetailerCategory',	1,	'CtgMainId',	31,	1,	NULL,	'Press F4/Double Click to select Retailer Value Classification',	0
Insert into RptDetails Select 	243,	9,	'Retailer',	-1,'',	'RtrId,RtrCode,RtrName',	'Retailer Group...',	'',	1,	'',	215,	0,	NULL,	'Press F4/Double Click to select Retailer Group',	0
Insert into RptDetails Select 	243,	10,	'Retailer',	-1,'',	'RtrId,RtrCode,RtrName',	'Retailer...',	'',	1,	'',	3,	0,	NULL,	'Press F4/Double Click to select Retailer',	0
Insert into RptDetails Select 	243,	11,	'ProductCategoryLevel',	3,	'CmpId',	'CmpPrdCtgId,CmpPrdCtgName,LevelName',	'Product Hierarchy Level...',	'Company',	1,	'CmpId',	16,	1,	NULL,	'Press F4/Double Click to select Product Hierarchy Level',	0
Insert into RptDetails Select 	243,	12,	'ProductCategoryValue',	11,	'CmpPrdCtgId',	'PrdCtgValMainId,PrdCtgValCode,PrdCtgValName',	'Product Hierarchy Level Value...',	'ProductCategoryLevel',	1,	'CmpPrdCtgId',	21,	NULL,	NULL,	'Press F4/Double Click to select Product Hierarchy Level Value',	0
Insert into RptDetails Select 	243,	13,	'Product',	12,	'PrdCtgValMainId',	'PrdId,PrdDCode,PrdName',	'Product...',	'ProductCategoryValue',	1,	'PrdCtgValMainId',	5,	NULL,	NULL,	'Press F4/Double Click to select Product',	0
Insert into RptDetails Select   243,	14,	'RptFilter',-1, '', 'FilterId,FilterDesc,FilterDesc','Display Based On*...','',1,'',246,1,1,'Press F4/Double Click to select Display Based on',1 
GO
Delete From RptFilter Where RptId = 243
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (243,246,1,'Product')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (243,246,2,'Route')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (243,246,3,'Retailer')
GO
Delete From RptFormula Where RptId = 243
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,1,'FromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,2,'ToDate','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,3,'Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,4,'Salesman','Salesman Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,5,'Route','Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,6,'CatLevel','Retailer Category Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,7,'CatVal','Retailer Category Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,8,'ValClass','Retailer Value Classification',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,9,'Cap_RetailerGroup','Retailer Group',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,10,'Cap_Retailer','Retailer',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,11,'PrdLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,12,'ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,13,'Cap_Product','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,14,'Dis_FromDate','From Date',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,15,'Dis_ToDate','To Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,16,'Dis_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,17,'Dis_SalesMan','Salesman',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,18,'Dis_Route','Route',1,2)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,19,'Disp_CategoryLevel','Retailer Category Level',1,29)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,20,'Disp_CategoryLevelValue','Retailer Category Level Value',1,30)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,21,'Disp_ValueClassification','Retailer Value Classification',1,31)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,22,'Disp_RetailerGroup','Retailer Group',1,215)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,23,'Disp_Retailer','Retailer',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,24,'Dis_PrdLevel','Product Hierarchy Level',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,25,'Dis_PrdLvlValue','Product Hierarchy Level Value',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,26,'Disp_Product','Product',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,27,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,28,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,25,'Fill_BasedOn','Display Based On',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (243,25,'Dis_BasedOn','Display Based On',1,246)
GO
Delete From RptExcelHeaders Where RptId = 243
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,1,'Code','Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,2,'Name','Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,3,'TotalOutlets','TotalOutlets',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,4,'TotalOutletBilled','TotalOutletBilled',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,5,'SaleableBOX','SaleableBOX',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,6,'SaleablePKT','SaleablePKT',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,7,'SalesValue','SalesValue',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,8,'EC','Effective Coverage',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,9,'TLS','Total Line Sold',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (243,10,'BasedOn','BasedOn',0,1)
GO
IF EXISTS (Select * From Sysobjects Where XTYPE = 'P' And name = 'Proc_RptECAnalysisReportParle')
DROP PROCEDURE Proc_RptECAnalysisReportParle
GO
--EXEC Proc_RptECAnalysisReportParle 243,1,0,'Dabur1',0,0,1 
CREATE PROCEDURE Proc_RptECAnalysisReportParle
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
/**********************************************************************************
* PROCEDURE		: Proc_RptECAnalysisReport
* PURPOSE		: To Generate Effective Coverage Analysis Report
* CREATED		: Thiruvengadam.L
* CREATED DATE	: 10/09/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 30.09.2009	Thiruvengadam		Bug No:20729
* 11.03.2010   	Panneer			Added Excel Table
**********************************************************************************/
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
	
	DECLARE @RtId		AS  INT
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @SMId	 	AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @BasedOn	AS  INT
	DECLARE @CmpId		AS	INT
	DECLARE @RtrCtgLvl	AS	INT
	DECLARE @RtrCtgLvlVal	AS INT
	DECLARE @RtrValClass	AS INT
	DECLARE @RtrGroup		AS INT
	DECLARE @PrdHieLvl		AS INT
	DECLARE @PrdHieLvlVal	AS INT
	DECLARE @PrdId			AS INT
	DECLARE @PrdCatId		AS INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrCtgLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrCtgLvlVal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @RtrValClass = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @RtrGroup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,215,@Pi_UsrId))
	SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @PrdHieLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdHieLvlVal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @BasedOn = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,246,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	PRINT @BasedOn
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
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
	CREATE TABLE #AnalysisReportRoute
	(
		RMId INT,
		RMName NVarchar(100),
		TotalOutlet INT,
	)
	INSERT INTO #AnalysisReportRoute (RMId,RMName,TotalOutlet)
	SELECT Distinct C.RMId,C.RmName,Count(A.RtrId) FROM Retailer A,RetailerMarket B,RouteMaster C 
	WHERE A.RtrId = B.RtrId AND B.RmId = C.RmId And A.RtrStatus = 1	
	GROUP BY C.RmId,C.RmName Order By C.RMName
	CREATE TABLE #AnalysisReportSales
	(
		RMId INT,
		RMName NVarchar(100),
		TotalBilled INT,
	)
	IF @BasedOn = 1 OR @BasedOn = 3
	BEGIN
	 UPDATE RptExcelHeaders Set DisplayFlag = 0 Where RptId = 243 And SlNo in (3,4) 
	END
	IF @BasedOn = 2
	BEGIN  
	 UPDATE RptExcelHeaders Set DisplayFlag = 1 Where RptId = 243 And Slno in (3,4)
	END 
	Create TABLE #RptECAnalysis
	(
	        PrdId               INT,
			Code			NVARCHAR(200),
			Name	        NVARCHAR(200),		
			TotalOutlets 		INT,
			TotalOutletBilled   INT,
			SalableQty          INT,
			SalesValue 		    NUMERIC(38,6),		
			EC				    INT,
			TLS				    INT,
			BasedOn             INT	
	)
	SET @TblName = 'RptECAnalysis'
	
	SET @TblStruct = 'RouteCode				NVARCHAR(200),
					  RouteName	            NVARCHAR(200),		
					  TotalOutlets 		    INT,
					  TotalOutletBilled     INT,
					  SalableQty            INT, 		
					  EC				    INT,
					  TLS				    INT'
				
	SET @TblFields = 'RouteCode,RouteName,TotalOutlets,TotalOutletBilled,SalableQty,EC,TLS'
	
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
	IF @Pi_GetFromSnap = 0
	BEGIN 
	    IF @BasedOn = 1
	    BEGIN
    		INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)
			SELECT P.PrdId,P.PrdDCode as Code,P.PrdName AS Name,'','',SUM(SIP.BaseQty) AS Unit,SUM(SIP.PrdGrossAmount) AS SalesValue,Count(Distinct(SI.RtrId)) AS EC,COUNT(SIP.Prdid) AS TLS,@BasedOn 
			FROM Product P,ProductBatch PB,SalesInvoice SI,SalesInvoiceProduct SIP,Company C,Salesman S,RouteMaster RM,Retailer R,RetailerValueClass RVC,RetailerCategory RC,
			RetailerCategorylevel RCL,RetailerValueClassMap RVCM,ProductCategoryValue PCV,RetailerCategorylevel RCV,ProductCategoryLevel PCL
			WHERE SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId AND PB.PrdId=P.PrdId
			AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND RCV.CtgLevelId=RC.CtgLevelId
			AND SI.SalInvDate BETWEEN @FromDate AND @ToDate AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
			AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND RVC.CtgMainId=RC.CtgMainId
			AND RC.CtgLevelId=RCL.CtgLevelId AND RVCM.RtrValueClassId=RVC.RtrClassId
			AND RVCM.RtrId=SI.RtrId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId AND SI.DlvSts NOT IN (1,3) --Added by Thiru on 30.09.2009 for Bug No:20729
			
			AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
			P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
			SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
			SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
			SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR
			RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
			AND (RC.CtgMainId = (CASE @RtrCtgLvlVal WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
			AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
			RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
			AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			GROUP BY P.PrdDCode,P.PrdName,P.PrdId
	   END		
       ELSE IF @BasedOn = 2
       BEGIN 
            INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)
			SELECT P.Prdid,RM.RMCode as Code,RM.RMName AS Name,'','',SUM(SIP.BaseQty),SUM(SIP.PrdGrossAmount) AS SalesValue,
			 SI.rtrid AS EC,Count(SI.rmid) AS TLS,@BasedOn FROM Product P,ProductBatch PB,SalesInvoice SI,
			SalesInvoiceProduct SIP,Company C,Salesman S,RouteMaster RM,Retailer R,RetailerValueClass RVC,RetailerCategory RC,
			RetailerCategorylevel RCL,RetailerValueClassMap RVCM,ProductCategoryValue PCV,RetailerCategorylevel RCV,ProductCategoryLevel PCL
			WHERE SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId AND PB.PrdId=P.PrdId
			AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND RCV.CtgLevelId=RC.CtgLevelId
			AND SI.SalInvDate BETWEEN @FromDate AND @ToDate AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
			AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND RVC.CtgMainId=RC.CtgMainId
			AND RC.CtgLevelId=RCL.CtgLevelId AND RVCM.RtrValueClassId=RVC.RtrClassId
			AND RVCM.RtrId=SI.RtrId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId AND SI.DlvSts NOT IN (1,3)	--Added by Thiru on 30.09.2009 for Bug No:20729
			AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
			P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
			SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
			SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
			SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR
			RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
			AND (RC.CtgMainId = (CASE @RtrCtgLvlVal WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
			AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
			RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
			AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			GROUP BY RM.RMCode,RM.RMName,P.Prdid,SI.rtrid
       END
       ELSE IF @BasedOn = 3
       BEGIN
           INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)
           SELECT P.PrdId,R.RtrCode As Code,R.RtrName AS Name,'','',SUM(SIP.BaseQty),SUM(SIP.PrdGrossAmount) AS SalesValue, SI.SalId AS EC,Count(SI.RtrId) AS TLS,@BasedOn
		   FROM	Product P (Nolock) ,ProductBatch PB (Nolock),SalesInvoice SI (Nolock),
				SalesInvoiceProduct SIP (Nolock),Company C (Nolock),Salesman S (Nolock),
				Retailer R (Nolock),RetailerValueClass RVC (Nolock),RouteMaster RM (Nolock),
				RetailerCategory RC,RetailerCategorylevel RCL,RetailerValueClassMap RVCM,
				ProductCategoryValue PCV (Nolock),RetailerCategorylevel RCV (Nolock),
				ProductCategoryLevel PCL (Nolock)
		   WHERE SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId
				AND PB.PrdId=P.PrdId AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND RCV.CtgLevelId=RC.CtgLevelId
				AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
				AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
				AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND RVC.CtgMainId=RC.CtgMainId
				AND RC.CtgLevelId=RCL.CtgLevelId AND RVCM.RtrValueClassId=RVC.RtrClassId
				AND RVCM.RtrId=SI.RtrId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId
				AND SI.DlvSts NOT IN (1,3)	--Added by Thiru on 30.09.2009 for Bug No:20729
				AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
						P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR
						RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				AND (RC.CtgMainId = (CASE @RtrCtgLvlVal WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
						RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
						RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))			
				AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
							P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			GROUP BY
				R.RtrCode,R.RtrName,P.PrdId,SI.SalId
       END    
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptECAnalysis ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'AND 	CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'
				+ 'AND RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '
				+ 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '
				+ 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND CtgLevelId = (CASE ' + CAST(@RtrCtgLvl AS nVarchar(10)) + ' WHEN 0 THEN CtgLevelId ELSE 0 END) OR '
				+ 'CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',29,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND CtgMainId = (CASE ' + CAST(@RtrCtgLvlVal AS nVarchar(10)) + ' WHEN 0 THEN CtgMainId ELSE 0 END) OR '
				+ 'CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',30,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND RtrClassId = (CASE ' + CAST(@RtrValClass AS nVarchar(10)) + ' WHEN 0 THEN RtrClassId Else 0 END) OR '
				+ 'RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',31,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'+
				+ 'AND P.PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN P.PrdId Else 0 END) OR '
				+ 'P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'
				+ 'AND P.PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN P.PrdId Else 0 END) OR '
				+ 'P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'
				+' Salinvdate BETWEEN ''' + Convert(Varchar(10),@FromDate,121) + ''' AND ''' + Convert(Varchar(10),@ToDate,121) + ''''
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptECAnalysis'
			
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
			@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptECAnalysis ' +
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
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptECAnalysis
	     SELECT DISTINCT A.Prdid,Code,Name,TotalOutlets,TotalOutletBilled,
	     Case When SUM(SalableQty) < MAX(ConversionFactor) Then 0 Else SUM(SalableQty) / MAX(ConversionFactor) End  As SaleableBOX,
	     Case When SUM(SalableQty) < MAX(ConversionFactor) Then SUM(SalableQty) Else SUM(SalableQty) % MAX(ConversionFactor) End As SaleablePKT,
	     SUM(SalesValue)AS SalesValue,EC,TLS,BasedOn INTO #EffectiveRoute FROM #RptECAnalysis A,#PrdUomAll B WHERE A.PrdId = B.PrdId  
	     GROUP BY A.Prdid,Code,Name,TotalOutlets,TotalOutletBilled,EC,TLS,BasedOn HAVING SUM(SalableQty) <> 0 ORDER BY Name
    
    IF @BasedOn = 1
    BEGIN
	      SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,
		  EC,TLS,BasedOn FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn,EC,TLS Order By Name
   	      IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')
	      DROP TABLE RptECAnalysisReportParle_Excel
		  SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,
		  EC,TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn,EC,TLS Order By Code   
	END	
	ELSE	     
	IF @BasedOn = 2
	BEGIN 
	     SELECT DISTINCT Code,Name,B.TotalOutlet AS TotalOutlets,Count(Distinct (EC))As TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) AS SaleablePKT,SUM(SalesValue) AS SalesValue,
	     Count(Distinct (EC)) AS EC,SUM(TLS) AS TLS,BasedOn from #EffectiveRoute A,#AnalysisReportRoute B 
	     WHERE A.Name = B.RMName 
	     GROUP BY Code,Name,B.TotalOutlet,BasedOn ORDER BY Code   
         IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')
	     DROP TABLE RptECAnalysisReportParle_Excel
	     SELECT DISTINCT Code,Name,B.TotalOutlet AS TotalOutlets,Count(Distinct (EC)) As TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) AS SaleablePKT,SUM(SalesValue) AS SalesValue,
	     Count(Distinct (EC)) AS EC,SUM(TLS) AS TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute A,#AnalysisReportRoute B 
	     WHERE A.Name = B.RMName GROUP BY Code,Name,B.TotalOutlet,BasedOn ORDER BY Code
			
	END
	ELSE 
	BEGIN
	      SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,
		  Count(Distinct(EC)) AS EC,SUM(TLS) AS TLS,BasedOn FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn Order By Name
   	      IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')
	      DROP TABLE RptECAnalysisReportParle_Excel
		  SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,
		  Count(Distinct(EC)) AS EC,SUM(TLS) AS TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn Order By Code   
	END		    
  	RETURN
END
GO
--Product wise sales report RptId = 238
Delete From RptGroup Where PId='CORESTOCKY' And GrpCode='ParleReports' And RptId=0
Insert Into RptGroup
Select 'CORESTOCKY',0,'ParleReports','Parle Reports'
Go
Delete From RptGroup Where PId = 'ParleReports' And RptId = 238
Insert Into RptGroup Select 'ParleReports',238,'ProductWiseSalesReportParle','Product Wise Sales Report'
GO
--Rptheader  
DELETE FROM RptHeader WHERE RptId = 238
INSERT INTO RptHeader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds]) 
VALUES ('ProductWiseSalesReportParle','Product Wise Sales Report','238','Product Wise Sales Report','Proc_RptProductWiseSalesParle','RptProductWiseDetailParle','RptProductWiseSalesParle.rpt','')
GO
--RptDetails 
DELETE FROM RptDetails WHERE RptId = 238
Insert Into RptDetails Select 	238,	1,	'FromDate',	-1,	NULL,	'',	'From Date*',	NULL,	1,	NULL,	10,	NULL,	NULL,	'Enter From Date',	0
Insert Into RptDetails Select 	238,	2,	'ToDate',	-1,	NULL,	'',	'To Date*',	NULL,	1,	NULL,	11,	NULL,	NULL,	'Enter To Date',	0
Insert Into RptDetails Select 	238,	3,	'Company',	-1,	NULL,	'CmpId,CmpCode,CmpName',	'Company...',	NULL,	1,	NULL,	4,	1,	NULL,	'Press F4/Double Click to select Company',	0
Insert Into RptDetails Select 	238,	4,	'Location',	-1,	NULL,	'LcnId,LcnCode,LcnName',	'Location...',	NULL,	1,	NULL,	22,	NULL,	NULL,	'Press F4/Double Click to select Location',	0
Insert Into RptDetails Select 	238,	5,	'Salesman',	-1,	NULL,	'SMId,SMCode,SMName',	'Salesman...',	NULL,	1,	NULL,	1,	NULL,	NULL,	'Press F4/Double Click to select Salesman',	0
Insert Into RptDetails Select 	238,	6,	'RouteMaster',	-1,	NULL,	'RMId,RMCode,RMName',	'Route...',	NULL,	1,	NULL,	2,	NULL,	NULL,	'Press F4/Double Click to select Route',	0
Insert Into RptDetails Select 	238,	7,	'Retailer',	-1,	NULL,	'RtrId,RtrCode,RtrName',	'Retailer Group...',	NULL,	1,	NULL,	215,	NULL,	NULL,	'Press F4/Double Click to select Retailer Group',	0
Insert Into RptDetails Select 	238,	8,	'Retailer',	-1,	NULL,	'RtrId,RtrCode,RtrName',	'Retailer...',	NULL,	1,	NULL,	3,	NULL,	NULL,	'Press F4/Double Click to select Retailer',	0
Insert Into RptDetails Select 	238,	9,	'ProductCategoryLevel',	3,	'CmpId',	'CmpPrdCtgId,CmpPrdCtgName,LevelName',	'Product Hierarchy Level...',	'Company',	1,	'CmpId',	16,	1,	NULL,	'Press F4/Double Click to select Product Hierarchy Level',	1
Insert Into RptDetails Select 	238,	10,	'ProductCategoryValue',	9,	'CmpPrdCtgId',	'PrdCtgValMainId,PrdCtgValCode,PrdCtgValName',	'Product Hierarchy Level Value...',	'ProductCategoryLevel',	1,	'CmpPrdCtgId',	21,	NULL,	NULL,	'Press F4/Double Click to select Product Hierarchy Level Value',	1
Insert Into RptDetails Select 	238,	11,	'Product',	10,	'PrdCtgValMainId',	'PrdId,PrdDCode,PrdName',	'Product...',	'ProductCategoryValue',	1,	'PrdCtgValMainId',	5,	NULL,	NULL,	'Press F4/Double Click to select Product',	0
Insert Into RptDetails Select 	238,	12,	'ProductBatch',	-1,	NULL,	' PrdBatId,PrdBatCode,PrdBatCode',	'Batch...',	NULL,	1,	NULL,	7,	0,	NULL,	'Press F4/Double Click to select Batch ',	0
Insert Into RptDetails Select 	238,	13,	'SalesInvoice',	-1,	NULL,	'SalId,SalInvRef,SalInvNo',	'Bill No...',	NULL,	1,	NULL,	14,	NULL,	NULL,	'Press F4/Double Click to select Bill No',	0
Insert Into RptDetails Select 	238,	14,	'RptFilter',	-1,	NULL,	'FilterId,FilterDesc,FilterDesc ',	'Display Cancelled Product Value*...',	NULL,	1,	NULL,	193,	1,	1,	'Press F4/Double Click to select Display Cancelled Product Values',	0
Insert Into RptDetails Select 	238,	15,	'Vehicle',-1,	'',	'VehicleId,VehicleCode,VehicleRegNo',	'Vehicle...',	'',	1,	'',	36,	0,	0,	'Press F4/Double Click to Select Vehicle',0
Insert Into RptDetails Select 	238,	16,	'VehicleAllocationMaster',-1,	'',	'AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...',	'',	1,	'',	37,	0,	0,	'Press F4/Double Click to Select Vehicle Allocation Number',0
GO
--RptFilter
DELETE FROM RptFilter WHERE RptId = 238
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (238,193,1,'NO')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (238,193,2,'YES')
GO
--RptFormula
Delete From RptFormula Where RptId = 238
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,1,'ProductCode','Product Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,2,'ProductName','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,3,'BatchNo','Batch Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,4,'MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,5,'SellingRate','Selling Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,6,'SalesQuantity','Sales Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,7,'FreeQuantity','Free Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,8,'ReplacementQuantity','Rep. Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,9,'SalesValue','Gross Amt',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,10,'FromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,11,'ToDate','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,12,'Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,13,'Salesman','Salesman',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,14,'Route','Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,15,'Retailer','Retailer',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,16,'ProductCategoryLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,17,'ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,18,'BillNumber','Bill Number',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,19,'Total','Grand Total ',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,20,'Disp_FromDate','FromDate',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,21,'Disp_ToDate','ToDate',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,22,'Disp_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,23,'Disp_Salesman','Salesman',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,24,'Disp_Route','Route',1,2)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,25,'Disp_Retailer','Retailer',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,26,'Disp_ProductCategoryLevel','ProductCategoryLevel',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,27,'Disp_ProductCategoryValue','ProductCategoryLevelValue',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,28,'Disp_BillNumber','BillNumber',1,14)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,29,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,30,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,31,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,32,'Cap_Product','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,33,'Disp_Product','Product',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,34,'Disp_Cancelled','Display Cancelled Bill Value',1,193)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,35,'Fill_Cancelled','Display Cancelled Product Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,36,'Cap_RetailerGroup','Retailer Group',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,37,'Disp_RetailerGroup','Retailer Group',1,215)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,38,'Cap_Location','Location',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,39,'Disp_Location','Location',1,22)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,40,'Cap_Batch','Batch',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,41,'Disp_Batch','Batch',1,7)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,42,'ReturnQuantity','Ret.Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,43,'Disp_Vehicle','Vehicle',1,36)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,44,'Disp_VehicleAlloNumber','Vehicle Allocation No',1,37)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,45,'Fill_Vehicle','Vehicle Number',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,46,'Fill_VehicleAlloNumber','Vehicle Allocation Number',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (238,47,'SchValue','Sch Amount',1,0)
GO
Delete From RptexcelHeaders Where RptId = 238
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,1,'PrdId','PrdId',0,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,2,'PrdDCode','Product Code',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,3,'PrdName','Product Name',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,4,'PrdBatId','PrdBatId',0,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,5,'PrdBatCode','Batch Code',0,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,6,'MrpRate','MRP',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,7,'SellingRate','Selling Rate',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,8,'SalesQty','Sales Qty',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,9,'FreeQty','Free Qty',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,10,'ReplaceQty','Replace Qty',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,11,'ReturnQty','Return Qty',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,12,'SchValue','Scheme Value',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,13,'SalesValue','Sales Value',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,14,'SalesPrdWeight','Sales PrdWeight',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,15,'FreePrdWeight','FreeQty PrdWeight',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,16,'RepPrdWeight','ReplacementQty PrdWeight',1,1)
INSERT INTO rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (238,17,'RetPrdWeight','ReturnQty PrdWeight',1,1)
GO
IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptProductWise')
DROP TABLE RptProductWise
GO
CREATE TABLE RptProductWise(
	[SalId] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[CmpId] [int] NULL,
	[LcnId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [varchar](100) NULL,
	[PrdName] [varchar](200) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](50) NULL,
	[PrdUnitMRP] [numeric](38, 6) NULL,
	[PrdUnitSelRate] [numeric](38, 6) NULL,
	[FreeQty] [int] NULL,
	[RepQty] [int] NULL,
	[ReturnQty] [int] NULL,
	[SalesQty] [int] NULL,
	[SalesGrossValue] [numeric](38, 6) NULL,
	[TaxAmount] [numeric](38, 6) NULL,
	[ReturnGrossValue] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[DlvSts] [int] NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL,
	[SalesPrdWeight] [numeric](38, 6) NULL,
	[FreePrdWeight] [numeric](38, 6) NULL,
	[RepPrdWeight] [numeric](38, 6) NULL,
	[RetPrdWeight] [numeric](38, 6) NULL,
	[SchemeValue] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
IF EXISTS (Select * From Sysobjects Where XTYPE = 'P' And name = 'Proc_ProductWiseSalesOnlyParle')
DROP PROCEDURE Proc_ProductWiseSalesOnlyParle
GO
--EXEC Proc_ProductWiseSalesOnlyParle 238,1 --select * from RptProductWise
--SELECT * FROM RptProductWise (NOLOCK)
CREATE PROCEDURE Proc_ProductWiseSalesOnlyParle
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
* {date} {developer}  {brief modification description}
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
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)
		SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		SIP.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SIP.SalManFreeQty AS FreeQty,0 AS RepQty,0 AS ReturnQty,
		SIP.BaseQty AS SalesQty,SIP.PrdGrossAmount,SIP.PrdTaxAmount,0 AS ReturnGrossValue,DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,PrdNetAmount,((P.PrdWgt*SIP.BaseQty)/1000),((P.PrdWgt*SIP.SalManFreeQty)/1000),0,0,
		ISNULL(SUM(SIP.SplDiscAmount + SIP.PrdSplDiscAmount+SIP.PrdSchDiscAmount+SIP.PrdDBDiscAmount+SIP.PrdCDAmount),0) As Schemevalue
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		SIP.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,PSD.PrdBatDetailValue,PBD.PrdBatDetailValue,SIP.SalManFreeQty,	
		SIP.BaseQty,SIP.PrdGrossAmount,SIP.PrdTaxAmount,Dlvsts,SIP.BaseQty,P.PrdWgt,SIP.SalManFreeQty,PrdNetAmount
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)
		SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.FreeQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts---@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.FreeQty)/1000),0,0,
		0 As Schemevalue
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SSF.SalId=SI.SalId AND P.PrdId=SSF.FreePrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.FreePrdBatId
		AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.GiftQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.GiftQty)/1000),0,0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SSF.SalId=SI.SalId  AND P.PrdId=SSF.GiftPrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.GiftPrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0,0
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		0 AS RepQty,REO.RtnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,REO.RtnAmount AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,0,((P.PrdWgt*REO.RtnQty)/1000),0
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,REO.RepAmount AS SalesGrossValue,REO.Tax AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID ,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0,0
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
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Return Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		0 AS FreeQty,0 AS RepQty,RP.BaseQty AS ReturnQty,
		0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,RP.PrdGrossAmt,SI.DlvSts--@
		,@Pi_RptId AS RptId,@Pi_UsrId AS UsrId,-1*PrdNetAmt,0,0,0,((P.PrdWgt*RP.BaseQty)/1000),0
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
		WHERE SI.SalId=RH.SalId  AND RH.ReturnId=RP.ReturnId AND P.PrdId=RP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=RP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
END
GO
IF EXISTS (Select * From Sysobjects Where XTYPE = 'P' And name = 'Proc_RptProductWiseSalesParle')
DROP PROCEDURE Proc_RptProductWiseSalesParle
GO
--EXEC Proc_RptProductWiseSalesParle 238,1,0,'DB',0,0,1
CREATE PROCEDURE Proc_RptProductWiseSalesParle
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
/********************************************************************
* VIEW	: Proc_RptProductWiseSales
* PURPOSE	: To get the Product details 
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
* 24-11-2009	Thiruvengadam	Added new SP Proc_LSProductWiseSales
**********************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	NVARCHAR(50)
	DECLARE @TblName 	AS	NVARCHAR(500)
	DECLARE @TblStruct 	AS	NVARCHAR(4000)
	DECLARE @TblFields 	AS	NVARCHAR(4000)
	DECLARE @sSql		AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	NVARCHAR(50)
	DECLARE @VehicleId AS INT
	DECLARE @VehicleAllocId AS	INT
	
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @LcnId 		AS	INT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId 		AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdBatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @CancelValue	AS	INT
	DECLARE @BillStatus	AS	INT
	DECLARE @GridFlag AS INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @PrdBatId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))
	SET @BillStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId))
	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	Create TABLE #RptProductWiseDetail
	(
				PrdId 			BIGINT,
				PrdDcode		NVARCHAR(50),
				PrdName			NVARCHAR(100),
				PrdBatId 		INT,
				PrdBatCode              NVARCHAR(50),
				MrpRate           	NUMERIC (38,6),
				SellingRate  		NUMERIC (38,6),
				SalesQty      	 	INT,
				FreeQty  		INT,
				ReplaceQty		INT,
				ReturnQty       INT,
				SchValue        NUMERIC (38,6),
				SalesValue		NUMERIC (38,6),	
				[SalesPrdWeight] NUMERIC(38,6),
				[FreePrdWeight] NUMERIC(38,6),
				[RepPrdWeight] NUMERIC(38,6),
				[RetPrdWeight] NUMERIC(38,6)
	)
	SET @TblName = 'RptProductWiseDetail'
	
	SET @TblStruct = '	PrdId 			BIGINT,
				PrdDcode		NVARCHAR(50),
				PrdName			NVARCHAR(100),
				PrdBatId 		INT,
				PrdBatCode              NVARCHAR(50),
				MrpRate          	NUMERIC (38,6),
				SellingRate  		NUMERIC (38,6),
				SalesQty      	 	INT,
				FreeQty  		INT,
				ReplaceQty		INT,
				ReturnQty       INT,
				SchValue        NUMERIC (38,6),
				SalesValue		NUMERIC (38,6),
				[SalesPrdWeight] NUMERIC(38,6),
				[FreePrdWeight] NUMERIC(38,6),
				[RepPrdWeight] NUMERIC(38,6),
				[RetPrdWeight] NUMERIC(38,6)'
	
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
			  MrpRate,SellingRate,SalesQty,FreeQty,
			  ReplaceQty,ReturnQty,SchValue,SalesValue,SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight'
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
		EXEC Proc_ProductWiseSalesOnlyParle @Pi_RptId,@Pi_UsrId
		IF @CancelValue=2 
		BEGIN
			INSERT INTO #RptProductWiseDetail (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MrpRate,SellingRate,SalesQty,FreeQty,ReplaceQty,ReturnQty,SalesValue,
					SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchValue)
			SELECT A.PrdId,A.PrdDcode,A.PrdName,0,'0',dbo.Fn_ConvertCurrency(A.PrdUnitMrp,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CAST(A.PrdUnitSelRate AS NUMERIC(38,2)),@Pi_CurrencyId),
			SUM(A.SalesQty),SUM(A.FreeQty),SUM(A.RepQty)AS ReplaceQty,SUM(A.ReturnQty)AS ReturnQty,
			dbo.Fn_ConvertCurrency(SUM(A.SalesGrossValue),@Pi_CurrencyId),
			SUM(A.SalesPrdWeight),SUM(A.FreePrdWeight),SUM(A.RepPrdWeight),SUM(A.RetPrdWeight),
			dbo.Fn_ConvertCurrency(SUM(A.SchemeValue),@Pi_CurrencyId)
			FROM RptProductWise A,SalesInvoice SI,VehicleAllocationDetails VD,VehicleAllocationMaster VM  
			WHERE A.SalId = SI.SalId AND SI.SalInvNo = VD.SaleInvNo AND VD.AllotmentNumber = VM.AllotmentNumber 
			AND  Rptid = @Pi_RptId AND UsrId = @Pi_UsrId
			AND 	(A.CmpId = (CASE @CmpId WHEN 0 THEN A.CmpId ELSE 0 END) OR
					A.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			
				AND 
				(A.LcnId = (CASE @LcnId WHEN 0 THEN A.LcnId ELSE 0 END) OR
					A.LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND 
				(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
					A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND 
				(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
					A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
				AND
				(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
					A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND
			
				(A.PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
					A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND 
				(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else 0 END) OR
					A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND 
				(A.PrdBatId = (CASE @PrdBatId WHEN 0 THEN A.PrdBatId Else 0 END) OR
					A.PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND
				(A.SalId = (CASE @SalId WHEN 0 THEN A.SalId ELSE 0 END) OR
					A.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
                AND
                (VM.VehicleId = (CASE @VehicleId WHEN 0 THEN VM.VehicleId ELSE 0 END) OR
					VM.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
	
	            AND 
	            (VM.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN VM.AllotmentId ELSE 0 END) OR
					VM.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
				AND A.SalInvDate BETWEEN @FromDate AND @ToDate 
				
			GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.PrdUnitMrp,A.PrdUnitSelRate ORDER BY A.PrdDcode
				     --SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight
		END
		ELSE IF @CancelValue=1
		BEGIN
			INSERT INTO #RptProductWiseDetail (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MrpRate,SellingRate,SalesQty,FreeQty,ReplaceQty,ReturnQty,SalesValue,
					SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchValue)
			SELECT A.PrdId,A.PrdDcode,A.PrdName,0,'0',dbo.Fn_ConvertCurrency(A.PrdUnitMrp,@Pi_CurrencyId),
			dbo.Fn_ConvertCurrency(CAST(A.PrdUnitSelRate AS NUMERIC(38,2)),@Pi_CurrencyId),
			SUM(A.SalesQty),SUM(A.FreeQty),	SUM(A.RepQty)AS ReplaceQty,SUM(A.ReturnQty)AS ReturnQty,
			dbo.Fn_ConvertCurrency(SUM(A.SalesGrossValue),@Pi_CurrencyId),SUM(A.SalesPrdWeight),SUM(A.FreePrdWeight),SUM(A.RepPrdWeight),SUM(A.RetPrdWeight),
			dbo.Fn_ConvertCurrency(SUM(A.SchemeValue),@Pi_CurrencyId)
			FROM RptProductWise A,SalesInvoice SI,VehicleAllocationDetails VD,VehicleAllocationMaster VM  
			WHERE A.SalId = SI.SalId AND SI.SalInvNo = VD.SaleInvNo AND VD.AllotmentNumber = VM.AllotmentNumber
			AND RptId=@Pi_RptId AND UsrId=@Pi_UsrId
			AND 	(A.CmpId = (CASE @CmpId WHEN 0 THEN A.CmpId ELSE 0 END) OR
				A.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND 
				(A.LcnId = (CASE @LcnId WHEN 0 THEN A.LcnId ELSE 0 END) OR
					A.LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND 
			(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
				A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND 
			(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
				A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
			AND
			(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR	
				A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			
			(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
			AND 
			(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND 
			(PrdBatId = (CASE @PrdBatId WHEN 0 THEN PrdBatId Else 0 END) OR
				PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
			AND
			(A.SalId = (CASE @SalId WHEN 0 THEN A.SalId ELSE 0 END) OR
				A.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
			   AND (A.DlvSts=(CASE @BillStatus WHEN 0 THEN A.DlvSts ELSE 0 END) OR
					A.DlvSts NOT IN(3))
			    AND		
                (VM.VehicleId = (CASE @VehicleId WHEN 0 THEN VM.VehicleId ELSE 0 END) OR
					VM.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
		        AND 
	            (VM.AllotmentId = (CASE @VehicleAllocId  WHEN 0 THEN VM.AllotmentId ELSE 0 END) OR
					VM.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
				AND A.SalInvDate BETWEEN @FromDate AND @ToDate 
			
			GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.PrdUnitMrp,A.PrdUnitSelRate ORDER BY A.PrdDcode
			--SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight
		END	
	
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptProductWiseDetail ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+ ' WHERE RptId=' + CAST(@Pi_RptId AS nVarchar(10)) + ' AND UsrId=' + CAST(@Pi_UsrId AS nVarchar(10)) + '' 
				+ 'AND 	(CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR ' 
				+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR ' 
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '
				+ 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '
				+ 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdBatId = (CASE ' + CAST(@PrdBatId AS nVarchar(10)) + ' WHEN 0 THEN PrdBatId Else 0 END) OR '
				+ 'PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',7,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR '
				+ 'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+'AND (VM.VehicleId = (CASE '+ CAST(@VehicleId AS nVarchar(100))+' WHEN 0 THEN VM.VehicleId ELSE 0 END) OR'
				+'VM.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10))+',36,'+ CAST(@Pi_UsrId AS nVarchar(100))+ ')))'
				+'AND (VM.AllotmentId = (CASE '+ CAST(@VehicleAllocId AS nVarchar(100))+' WHEN 0 THEN VM.AllotmentId ELSE 0 END) OR'
				+'VM.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10))+',36,'+ CAST(@Pi_UsrId AS nVarchar(100))+ ')))' 
				+ 'AND SalInvDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptProductWiseDetail'
				
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
			SET @SSQL = 'INSERT INTO #RptProductWiseDetail ' + 
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptProductWiseDetail
	WHERE (SalesQty>0 OR FreeQty>0 OR ReplaceQty>0)
	SELECT DISTINCT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MrpRate,MAX(SellingRate) AS SellingRate,SUM(SalesQty) As SalesQty,SUM(FreeQty) AS FreeQty,
	SUM(ReplaceQty) As ReplaceQty,SUM(ReturnQty) As ReturnQty,SUM(SchValue) AS SchValue,SUM(SalesValue) AS SalesValue,SUM(SalesPrdWeight) AS SalesPrdWeight,
	SUM(FreePrdWeight) As FreePrdWeight,SUM(RepPrdWeight) AS RepPrdWeight,SUM(RetPrdWeight) AS  RetPrdWeight FROM #RptProductWiseDetail
	GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MrpRate Order By PrdDcode

-- Till Here		
	SELECT @GridFlag=GridFlag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @GridFlag=1
	BEGIN
			--	SELECT * FROM #RptProductWiseDetail   
			-- Added on 20-Jun-2009
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MrpRate,A.SellingRate,A.SalesQty,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.SalesQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
			CASE 
				WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
					Case When 
							CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
			CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
			ELSE
				CASE 
					WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
						Case
							When CAST(Sum(A.SalesQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
								CAST(Sum(A.SalesQty) AS INT)%nullif(ConverisonFactor2,0)
							Else CAST(Sum(A.SalesQty) AS INT) End
					WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
						Case
							When CAST(Sum(A.SalesQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
								CAST(Sum(A.SalesQty) AS INT)%nullif(ConverisonFactor3,0)
							Else CAST(Sum(A.SalesQty) AS INT) End			
				ELSE CAST(Sum(A.SalesQty) AS INT) END
			END as Uom4,
			--Case When CAST(A.SalesQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As Uom1,
			--Case When (CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as Uom2,
			--Case When (CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			--(CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as Uom3,
			--Case When CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			--(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			--CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			--(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as Uom4,
			A.FreeQty,A.ReplaceQty,A.SalesValue
			FROM #RptProductWiseDetail A, View_ProdUOMDetails B WHERE a.prdid=b.prdid 
			GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MrpRate,A.SellingRate,A.SalesQty,
			ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1,A.FreeQty,A.ReplaceQty,A.SalesValue Order By A.PrdDcode
			--- Added on 26-Jun-2009
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MrpRate,A.SellingRate,A.SalesQty,
			Case When CAST(A.SalesQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As Uom1,
			Case When (CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as Uom2,
			Case When (CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as Uom3,
			Case When CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as Uom4,
			A.FreeQty,A.ReplaceQty,A.SalesValue INTO #RptProductWiseDetailGrid
			FROM #RptProductWiseDetail A, View_ProdUOMDetails B WHERE a.prdid=b.prdid Order By A.PrdDcode
			DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId  
			INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,Rptid,Usrid)  
			SELECT PrdDcode,PrdName,PrdBatCode,MrpRate,SellingRate,SalesQty,Uom1,Uom2,Uom3,Uom4,FreeQty,ReplaceQty,SalesValue,@Pi_RptId,@Pi_UsrId  
			FROM #RptProductWiseDetailGrid  
			--- End here on 26-Jun-2009
			-- End Here
	END
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptProductWiseDetailParle_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptProductWiseDetailParle_Excel 
			SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MrpRate,MAX(SellingRate) AS SellingRate,SUM(SalesQty) As SalesQty,SUM(FreeQty) AS FreeQty,
			SUM(ReplaceQty) As ReplaceQty,SUM(ReturnQty) As ReturnQty,SUM(SchValue) AS SchValue,SUM(SalesValue) AS SalesValue,SUM(SalesPrdWeight) AS SalesPrdWeight,
			SUM(FreePrdWeight) As FreePrdWeight,SUM(RepPrdWeight) AS RepPrdWeight,SUM(RetPrdWeight) AS  RetPrdWeight 
			INTO RptProductWiseDetailParle_Excel FROM #RptProductWiseDetail
			GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MrpRate Order By PrdDcode
RETURN
END
GO
Delete From RptGroup Where PId='CORESTOCKY' And GrpCode='ParleReports' And RptId=0
Go
Insert Into RptGroup
Select 'CORESTOCKY',0,'ParleReports','Parle Reports'
Go
Delete from RptGroup Where PId='ParleReports' And RptId=236
GO
Insert Into RptGroup 
Select 'ParleReports',236,'StockandSalesReport-VolumeWise','Stock and Sales Report - Volume Wise'
Delete from RptHeader Where RptId=236
Go
Insert Into RptHeader 
Select 'ParleReports','Stock and Sales Report - Volume Wise',236,'Stock and Sales Report - Volume Wise','Proc_RptStockandSalesVolumeParle','RptStockandSalesVolumeParle',
'RptStockandSalesVolume_Parle.rpt',''
GO
Delete From RptDetails Where RptId=236
Go
--select * from RptDetails Where RptId=6
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,1,'FromDate',-1,'','','From Date*','',1,'0',10,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,2,'ToDate',-1,'','','To Date*','',1,'0',11,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'0',4,0,0,'Press F4/Double Click to Select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,4,'Location',-1,'0','LcnId,LcnCode,LcnName','Location...','',1,'0',22,0,0,'Press F4/Double Click to Select Location',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,6,'ProductCategoryValue',5,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to Select Product Hierarchy Level Value',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,8,'RptFilter',-1,'0','FilterId,FilterId,FilterDesc','Product Status','',1,'0',24,1,0,'Press F4/Double Click to Product Status',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,5,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,LevelName,CmpPrdCtgName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double Click to Select Product Hierarchy Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,7,'Product',6,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,0,'Press F4/Double Click to Select Product',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (236,9,'RptFilter',-1,'0','FilterId,FilterDesc,FilterDesc','Closing Stock Value Based On*...','',1,'0',23,1,1,'Press F4/Double Click to Select the Stock Value as per',0)
Go
Go
Delete From RptFilter Where RptId=236
Go
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (236,24,0,'ALL')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (236,24,1,'Active')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (236,24,2,'InActive')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (236,23,1,'Selling Rate')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (236,23,2,'List Price')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (236,23,3,'MRP')
GO
Delete from RptFormula Where RptId=236
Go
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,1,'Cap From Date','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,2,'From Date','From Date',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,3,'Cap To Date','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,4,'To Date','To Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,5,'Cap Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,6,'Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,7,'Cap Location','Location',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,8,'Location','Location',1,22)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,9,'Cap Product Hierarchy Level','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,10,'Product Hierarchy Level','Product Hierarchy Level',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,11,'Cap Product Hierarchy Level Value','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,12,'Product Hierarchy Level Value','Product Hierarchy Level Value',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,13,'Cap Product','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,14,'Product','Product',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,17,'Cap Product Status','Product Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,18,'Product Status','Product Status',1,24)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,36,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,37,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,38,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (236,44,'Fill_Stockasper','Stock Value as per',1,23)
GO
Delete From RptExcelHeaders Where RptId=236
Insert Into RptExcelHeaders
Select 236,1,'PrdId','PrdId',0,1 Union All
Select 236,2,'PrdDCode','Product Code',1,1 Union All
Select 236,3,'PrdName','Product Name',1,1 Union All
Select 236,4,'PrdBatId','PrdBatId',0,1 Union All
Select 236,5,'PrdBatCode','Batch Code',0,1 Union All
Select 236,6,'CmpId','CmpId',0,1 Union All
Select 236,7,'CmpName','Company Name',0,1 Union All
Select 236,8,'LcnId','LcnId',0,1 Union All
Select 236,9,'LcnName','Location Name',0,1 Union All
Select 236,10,'OpeneningBox','Opening Stock Box',1,1 Union All
Select 236,11,'OpeneningPack','Opening Stock Pack',1,1 Union All
Select 236,12,'PurchaseBox','Purchase Box',1,1 Union All
Select 236,13,'PurchasePack','Purchase Pack',1,1 Union All
Select 236,14,'SalesBox','Sales Box',1,1 Union All
Select 236,15,'SalesPack','Sales Pack',1,1 Union All
Select 236,16,'AdjustmentBox','Adjustment Box',1,1 Union All
Select 236,17,'AdjustmentPack','Adjustment Pack',1,1 Union All
Select 236,18,'ClosingStockBox','Closing Stock Box',1,1 Union All
Select 236,19,'ClosingStockPack','Closing Stock Pack',1,1 Union All
Select 236,20,'ClosingStkValue','Closing Stock Value',1,1 Union All
Select 236,21,'OpenWeight','OpenWeight',0,1 Union All
Select 236,22,'PurchaseWeight','PurchaseWeight',0,1 Union All
Select 236,23,'SalesWeight','SalesWeight',0,1 Union All
Select 236,24,'AdjustmentWeight','AdjustmentWeight',0,1 Union All
Select 236,25,'ClosingStockWeight','ClosingStockWeight',0,1 Union All
Select 236,26,'OpeningStkValue','OpeningStkValue',0,1 Union All
Select 236,27,'PurchaseStkValue','PurchaseStkValue',0,1 Union All
Select 236,28,'SalesStkValue','SalesStkValue',0,1 Union All
Select 236,29,'AdjustmentStkValue','AdjustmentStkValue',0,1 Union All
Select 236,30,'ClosingStockkValue','ClosingStockkValue',0,1
GO
If Exists (Select [Name] From SysObjects Where [Name]='Proc_RptStockandSalesVolumeParle' And XTYPE='P')
Drop Procedure Proc_RptStockandSalesVolumeParle
GO
--EXEC Proc_RptStockandSalesVolumeParle 236,2,0,'CKProduct',0,0,1
Create PROCEDURE Proc_RptStockandSalesVolumeParle  
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
		If Exists (Select [Name] From SysObjects Where [Name]='RptStockandSalesVolume_Parle_Excel' And XTYPE='U')
		Drop Table RptStockandSalesVolume_Parle_Excel
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
					INTO RptStockandSalesVolume_Parle_Excel FROM #RptStockandSalesVolume_Parle RV 
					INNER JOIN #PrdUomAll P On RV.PrdId=P.PrdId
					Group By RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
							 LcnName Order By PrdDcode
		END 
		
	RETURN  
END
GO
Delete From RptGroup Where RptId=237
GO
Insert Into RptGroup
Select 'ParleReports',237,'SchemeUtilizationReportparle','Scheme Utilization Report'
GO
Delete From RptHeader Where RptId=237
GO
Insert Into RptHeader
Select 'ParleReports','Scheme Utilization Report Parle',237,'Scheme Utilization Report ','Proc_RptSchemeUtilization_Parle','RptSchemeUtilizationDet_Parle',
'RptSchemeUtilizationDet_Parle.rpt',''
GO
Delete From RptDetails Where RptId=237
GO
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,1,'FromDate',-1,'0','','From Date*','',1,'0',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,2,'ToDate',-1,'0','','To Date*','',1,'0',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,3,'SchemeMaster',-1,'0','SchId,SchCode,SchDsc','Scheme Master...','',1,'0',8,0,0,'Press F4/Double Click to select Scheme',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,4,'Salesman',-1,'0','SMId,SMCode,SMName','Salesman...','',1,'0',1,0,0,'Press F4/Double Click to select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,5,'RouteMaster',-1,'0','RMId,RMCode,RMName','Route...','',1,'0',2,0,0,'Press F4/Double Click to select Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,6,'RetailerCategoryLevel',-1,'','CtgLevelId,CtgLevelName,CtgLevelName','Category Level...','',1,'NULL',29,0,0,'Press F4/Double Click to select Category Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,7,'RetailerCategory',6,'CtgLevelId','CtgMainId,CtgCode,CtgName','Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,0,0,'Press F4/Double Click to select Category Level Value',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,8,'RetailerValueClass',7,'CtgMainId','RtrClassId,ValueClassCode,ValueClassName','Value Classification...','RetailerCategory',1,'CtgMainId',31,0,0,'Press F4/Double Click to select Value Classification',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (237,9,'Retailer',-1,'0','RtrId,RtrCode,RtrName','Retailer...','',1,'0',3,0,0,'Press F4/Double Click to select Retailer',0)
GO
Delete From RptFormula Where RptId=237
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,1,'Applied','Applied',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,2,'Budget Amount','Budget Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,3,'Budget Utilized','Budget Utilized',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,4,'Discount %','Discount % (Amount)',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,5,'Flat Amount Discount','Flat Amount Disc.',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,6,'Free Product','Free Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,7,'Free Product Value','Free Product Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,8,'Free Qty','Free Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,9,'From Date','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,10,'From Date Value','',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,11,'Gift Product','Gift Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,12,'Gift Qty','Gift Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,13,'Gift Value','Gift Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,14,'Grand Total','Grand Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,15,'No Of Bills','No Of Bills',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,16,'No Of Retailers Billed','No Of Retailers Billed',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,17,'Not Applied','Not',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,18,'Points','Points',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,19,'Retailer','Retailer',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,20,'Retailer Value','',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,21,'Route','Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,22,'Route Value','',1,2)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,23,'SalesMan','SalesMan',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,24,'Salesman Value','',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,25,'Scheme','Scheme',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,26,'Scheme Description','Scheme Description',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,27,'Scheme Value','',1,8)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,28,'Slab','Slab',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,29,'To Date','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,30,'To Date Value','',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,31,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,32,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,33,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,34,'Fil_CategoryLevel','Category Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,35,'Fil_CategoryLevelValue','Category Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,36,'Fil_Value Classification','Value Classification',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,34,'Disp_CategoryLevel','Category Level',1,29)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,35,'Disp_CategoryLevelValue','Category Level Value',1,30)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (237,36,'Disp_Value Classification','Value Classification',1,31)
GO
Delete From Rptexcelheaders Where RptId = 237
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,1,'SchId','SchId',0,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,2,'SchCode','SchCode',0,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,3,'SchDesc','SchDesc',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,4,'SlabId','Slab',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,5,'SchemeBudget','Scheme Budget',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,6,'BudgetUtilized','BudgetUtilized',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,7,'NoOfRetailer','NoOfRetailerBilled',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,8,'NoOfBills','NoOfBillsApplied',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,9,'UnselectedCnt','NoOfBillsNotApplied',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,10,'BaseQtyBox','BaseQtyBox',0,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,11,'BaseQtyPack','BaseQtyPack',0,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,12,'DiscountPer','Scheme Amount',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,13,'FreePrdName','Free ProductName',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,14,'FreeQty','Free Qty',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,15,'FreeValue','Free Qty Value',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,16,'FlatAmount','FlatAmount',0,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,17,'Points','Points',0,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,18,'BaseQty','BaseQty',1,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,19,'GiftPrdName','GiftPrdName',0,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,20,'GiftQty','GiftQty',0,1)
INSERT INTO Rptexcelheaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (237,21,'GiftValue','GiftValue',0,1)
GO
IF EXISTS (Select * From Sysobjects Where Name = 'Fn_ReturnSchemeProductWithScheme' And XTYPE in ('TF','FN'))
DROP FUNCTION Fn_ReturnSchemeProductWithScheme
GO
--SELECT * FROM DBO.Fn_ReturnSchemeProductWithScheme()
CREATE FUNCTION Fn_ReturnSchemeProductWithScheme()
RETURNS @ApplicableSchemePrdid TABLE
	(
		SchId		INT,
		Prdid		INT
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnSchemeProductBatchWithScheme
* PURPOSE: Returns the SchemeProduct
* NOTES:
* CREATED: Murugan.R	19-06-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	INSERT INTO @ApplicableSchemePrdid
		SELECT DISTINCT A.SchId,B.Prdid FROM SchemeMaster A  
		   INNER JOIN SchemeProducts B ON A.Schid = B.Schid  
		   INNER JOIN Product C On B.Prdid = C.PrdId  
		   WHERE A.Schid In (Select Distinct Schid From SchemeMaster WHERE  SchemeLvlMode=0) 
		  UNION  
		  SELECT DISTINCT A.SchId,E.Prdid FROM SchemeMaster A  
		   INNER JOIN SchemeProducts B ON A.Schid = B.Schid  
		   INNER JOIN ProductCategoryValue C ON   
		   B.PrdCtgValMainId = C.PrdCtgValMainId   
		   INNER JOIN ProductCategoryValue D ON  
		   D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'  
		   INNER JOIN Product E On  
		   D.PrdCtgValMainId = E.PrdCtgValMainId   
		   --INNER JOIN ProductBatch F On  
		   --F.PrdId = E.Prdid  
		   WHERE A.Schid In (Select Distinct Schid From SchemeMaster WHERE  SchemeLvlMode=0) 
RETURN
END
GO
IF EXISTS (Select * From Sysobjects Where XTYPE = 'P' And name = 'Proc_RptSchemeUtilization_Parle')
DROP PROCEDURE Proc_RptSchemeUtilization_Parle
GO
--EXEC Proc_RptSchemeUtilization_Parle 237,2,0,'Henkel',0,0,1
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
		FreePrdName	nVarchar(50),
		FreeQty		Int,
		[BaseQty] [Int],
		BaseQtyBox	Int,
		BaseQtyPack Int,
		FreeValue	Numeric(38,6),
		GiftPrdName	nVarchar(50),
		GiftQty		Int,
		GiftValue	Numeric(38,6)
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
			GiftPrdName,GiftQty,GiftValue)
		SELECT DISTINCT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,Count(Distinct B.RtrId),
			Count(Distinct B.ReferNo),0 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
			CASE FreePrdId WHEN 0 THEN dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId) ELSE '0.00' END as DiscountPer,
			ISNULL(SUM(Points),0) as Points,CASE ISNULL(SUM(FreeQty),0) WHEN 0 THEN '' ELSE FreePrdName END AS FreePrdName,
			CASE FreePrdName WHEN '' THEN 0 ELSE ISNULL(SUM(FreeQty),0)  END as FreeQty,ISNULL(Sum(BaseQty),0) as BaseQty,
			Case When Isnull(Sum(BaseQty),0)<MAX(ConversionFactor) Then 0 Else Isnull(Sum(BaseQty),0)/MAX(ConversionFactor) End As BaseQtyBox,
			Case When Isnull(Sum(BaseQty),0)<MAX(ConversionFactor) Then Isnull(Sum(BaseQty),0) Else Isnull(Sum(BaseQty),0)%MAX(ConversionFactor) End As BaseQtyPack,
			ISNULL(SUM(FreeValue),0) as FreeValue,
			CASE ISNULL(SUM(GiftValue),0) WHEN 0 THEN '' ELSE GiftPrdName END AS GiftPrdName,ISNULL(SUM(GiftQty),0) as FreeQty,
			ISNULL(SUM(GiftValue),0) as GiftValue
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
			FreePrdName,GiftPrdName--,B.PrdID 
			
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
	SELECT DISTINCT SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,
	UnselectedCnt,(BaseQtyBox) AS BaseQtyBox,(BaseQtyPack) AS BaseQtyPack,
	DiscountPer,(CASE FreeQty WHEN 0 THEN '-' ELSE FreePrdName END) AS FreePrdName,FreeQty,
    (CASE FreeQty WHEN 0 THEN '0.00' ELSE FreeValue END) AS FreeValue,FlatAmount,Points,(BaseQty) AS BaseQty,
	GiftPrdName,GiftQty,GiftValue
	FROM #RptSchemeUtilizationDet_Parle 
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'RptSchemeUtilizationDet_Parle_Excel') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationDet_Parle_Excel
			SELECT DISTINCT SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,
			UnselectedCnt,(BaseQtyBox) AS BaseQtyBox,(BaseQtyPack) AS BaseQtyPack,
			DiscountPer,(CASE FreeQty WHEN 0 THEN '-' ELSE FreePrdName END) AS FreePrdName,FreeQty,
			(CASE FreeQty WHEN 0 THEN '0.00' ELSE FreeValue END) AS FreeValue,FlatAmount,Points,(BaseQty) AS BaseQty,
			GiftPrdName,GiftQty,GiftValue
			INTO RptSchemeUtilizationDet_Parle_Excel FROM #RptSchemeUtilizationDet_Parle Order By SchId
	END 
RETURN
END
GO
Delete From RptGroup Where RptId=242
GO
Insert Into RptGroup 
Select 'ParleReports',242,'ProductWiseLoadingSheetParle','Loading Sheet Item-Wise'
GO
Delete From RptHeader Where RptId=242
GO
Insert Into RptHeader
Select 'ParleReports','Loading Sheet Item-Wise',242,'Loading Sheet - Item Wise','Proc_RptLoadSheetItemWiseParle','RptLoadSheetItemWiseParle',
	   'RptLoadSheetItemWiseParle.rpt',''
GO
Delete From RptDetails Where RptId=242
GO
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,3,'Vehicle',-1,'','VehicleId,VehicleCode,VehicleRegNo','Vehicle...','',1,'',36,0,0,'Press F4/Double Click to Select Vehicle',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,4,'VehicleAllocationMaster',-1,'','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','',1,'',37,0,0,'Press F4/Double Click to Select Vehicle Allocation Number',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,6,'RouteMaster',-1,'','RMId,RMCode,RMName','Delivery Route...','',1,'',35,0,0,'Press F4/Double Click to Select Delivery Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,7,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer Group...','',1,'',215,0,0,'Press F4/Double Click to select Retailer Group',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,8,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'',3,0,0,'Press F4/Double Click to select Retailer',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,5,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,0,0,'Press F4/Double Click to Select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,9,'SalesInvoice',-1,'','SalId,SalInvRef,SalInvNo','From Bill No...','',1,'',14,1,0,'Press F4/Double Click to select From Bill No',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (242,10,'SalesInvoice',-1,'','SalId,SalInvRef,SalInvNo','To Bill No...','',1,'',15,1,0,'Press F4/Double Click to select To Bill No',0)
GO
Delete From RptFormula Where RptId=242
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,1,'Fil_FromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,2,'Fil_ToDate','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,3,'Fil_Vehicle','Vehicle',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,4,'Fil_VehAllNo','Vehicle Allocation No',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,5,'Fil_Salesman','Salesman',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,6,'Fil_DlvRoute','Delivery Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,7,'Fil_Retailer','Retailer',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,8,'FilDisp_FromDate','',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,9,'FilDisp_ToDate','',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,10,'FilDisp_Vehicle','ALL',1,36)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,11,'FilDisp_VehAllNo','ALL',1,37)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,12,'FilDisp_Salesman','ALL',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,13,'FilDisp_DlvRoute','ALL',1,35)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,14,'FilDisp_Retailer','ALL',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,15,'PrdCode','Product Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,16,'PrdName','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,17,'BatCode','Bat Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,18,'BilledQty','Billed Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,19,'FreeQty','Free Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,20,'RtnQty','Return Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,21,'RepQty','Replacement Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,22,'TotQty','Total Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,23,'GrandTotal','Grand Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,24,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,25,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,26,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,27,'Fil_DisplayIn','Display In',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,28,'FilDisp_DisplayIn','Display In',1,129)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,29,'Cap_RetailerGroup','Retailer Group',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,30,'Disp_RetailerGroup','Retailer Group',1,215)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,31,'MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,32,'Fill_FromBill','1',1,14)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,33,'Dis_ToBill','P11035407',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (242,34,'Fill_ToBill','Bill No(s).      :',1,15)
GO
Delete From RptExcelHeaders Where RptId=242
GO
Insert Into RptExcelHeaders 
Select 242,1,'SalId','SalId',0,1 Union All
Select 242,2,'BillNo','BillNo',0,1 Union All
Select 242,3,'PrdId','PrdId',0,1 Union All
Select 242,4,'PrdBatId','PrdBatId',0,1 Union All
Select 242,5,'Product Code','Product Code',1,1 Union All
Select 242,6,'Product Description','Product Description',1,1 Union All
Select 242,7,'PrdCtgValMainId','PrdCtgValMainId',0,1 Union All
Select 242,8,'CmpPrdCtgId','CmpPrdCtgId',0,1 Union All
Select 242,9,'Batch Number','Batch Number',0,1 Union All
Select 242,10,'MRP','MRP',1,1 Union All
Select 242,11,'Selling Rate','Selling Rate',1,1 Union All
Select 242,12,'BilledQtyBox','BilledQtyBox',1,1 Union All
Select 242,13,'BilledQtyPack','BilledQtyPack',1,1 Union All
Select 242,14,'Total Qty','Total Qty(in PKTS)',1,1 Union All
Select 242,15,'TotalQtyBox','TotalQtyBox',1,1 Union All
Select 242,16,'TotalQtyPack','TotalQtyPack',1,1 Union All
Select 242,17,'Free Qty','Free Qty in(PKTS)',1,1 Union All
Select 242,18,'Return Qty','Return Qty in(PKTS)',1,1 Union All
Select 242,19,'Replacement Qty','Replacement Qty in(PKTS)',1,1 Union All
Select 242,20,'PrdWeight','PrdWeight',0,1 Union All
Select 242,21,'Billed Qty','Billed Qty',0,1 Union All
Select 242,22,'GrossAmount','GrossAmount',0,1 Union All
Select 242,23,'PrdSchemeDisc','Scheme Discount',1,1 Union All
Select 242,24,'TaxAmount','Tax Amount',0,1 Union All
Select 242,25,'NETAMOUNT','NETAMOUNT',0,1 Union All
Select 242,26,'TotalBills','TotalBills',0,1 Union All
Select 242,27,'TotalDiscount','TotalDiscount',0,1 Union All
Select 242,28,'OtherAmt','OtherAmt',0,1 Union All
Select 242,29,'AddReduce','AddReduce',0,1 Union All
Select 242,30,'Damage','Damage',1,1
GO
IF EXISTS (Select * From Sysobjects Where XTYPE = 'P' And name = 'Proc_RptLoadSheetItemWiseParle')
DROP PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
--Exec Proc_RptLoadSheetItemWiseParle 242,1,0,'',0,0,1
CREATE Procedure Proc_RptLoadSheetItemWiseParle
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
	
	
	
	--Till Here
	
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
	
	CREATE TABLE #RptLoadSheetItemWiseParle
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[PrdBatId]			  Int,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
            [PrdCtgValMainId]	  int, 
			[CmpPrdCtgId]		  int,
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
			[Damage]              NUMERIC (38,2)
	)
	
	SET @TblName = 'RptLoadSheetItemWiseParle'
	
	SET @TblStruct = '
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),		
			[PrdId]        	      INT,  
			[PrdBatId]			  Int,  	
			[Product Code]        VARCHAR (100),
			[Product Description] VARCHAR(200),
            [PrdCtgValMainId]	  int, 
			[CmpPrdCtgId]		  int, 
			[Batch Number]        VARCHAR(50),		
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
			[AddReduce]			  NUMERIC (38,2)'
	
	SET @TblFields = '	
			[SalId]
			[BillNo]
			[PrdId]        	      ,
			[PrdBatId]			  ,
			[Product Code]        ,
			[Product Description] ,
            [PrdCtgValMainId]	  ,
			[CmpPrdCtgId]		  ,
			[Batch Number],
			[MRP]				  ,
			[Selling Rate]
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],
			[PrdWeight],
			[PrdSchemeDisc],
			[GrossAmount],
			[TaxAmount],[NetAmount],[TotalBills],[TotalDiscount],[OtherAmt],[AddReduce]'
	
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
	Print @FromBillNo
	Print @TOBillNo
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		IF @FromBillNo <> 0 Or @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
				[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage])--select * from RtrLoadSheetItemWise
	
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0
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
	---Other Charges Added By Sathishkumar Veeramani			 
	 SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice 
     WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2 AND SalId Between @FromBillNo and @ToBillNo
     AND
     (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
	 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
     AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
     AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
     UPDATE #RptLoadSheetItemWiseParle SET AddReduce = @OtherCharges 
---End Here  
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
					[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage])
			
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),
			BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) As [OtherAmt],0,0
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
							
		 AND [SalInvDate] Between @FromDate and @ToDate
		
			GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId
			ORDER BY PrdDCode
---Other Charges Added By Sathishkumar Veeramani			 
	 SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice 
     WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2 AND
     (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
	 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
     AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
     AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
     UPDATE #RptLoadSheetItemWiseParle SET AddReduce = @OtherCharges 
---End Here 			
		END 
		
		UPDATE #RptLoadSheetItemWiseParle SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle)
		
-------Added By Sathishkumar Veeramani Damage Goods Amount---------	
		 UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle R INNER JOIN
		(SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP 
		 WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B
		 ON R.SalId = B.SalId AND R.PrdId = B.PrdId 
		AND R.PrdBatId = B.PrdBatId
------Till Here-------------------- select * From salesinvoiceproduct where salid = 2254		
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
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWiseParle ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
	 + '         WHERE
	 RptId = ' + @Pi_RptId + ' and UsrId = ' + @Pi_UsrId + ' and
	  (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
	
	 AND (Allotmentnumber = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
	
	 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
	
	 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
	
	 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
					
	 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetItemWiseParle'
	
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
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWiseParle ' +
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
			SELECT 0 AS [SalId],'' AS BillNo,LSB.PrdId,0 AS PrdBatId,LSB.[Product Code],LSB.[Product Description],LSB.[PrdCtgValMainId],LSB.[CmpPrdCtgId],
			    0 AS [Batch Number],LSB.[MRP],MAX([Selling Rate]) AS [Selling Rate],
				Cast (Case When SUM([Billed Qty])<MAX(ConversionFactor) Then 0 Else SUM([Billed Qty])/MAX(ConversionFactor) End As Int) As BilledQtyBox,
				Case When SUM([Billed Qty])<MAX(ConversionFactor) Then SUM([Billed Qty]) Else SUM([Billed Qty])%MAX(ConversionFactor)  End As BilledQtyPack,
				SUM(LSB.[Total Qty]) AS [Total Qty],
				Cast(Case When SUM([Total Qty])<MAX(ConversionFactor) Then 0 Else SUM([Total Qty])/MAX(ConversionFactor) End As Int)  As TotalQtyBox,
				Case When SUM([Total Qty])<MAX(ConversionFactor) Then SUM([Total Qty]) Else SUM([Total Qty])%MAX(ConversionFactor)  End As TotalQtyPack,
				SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],Sum([PrdWeight]) AS [PrdWeight],
				SUM(LSB.[Billed Qty]) AS [Billed Qty],
				SUM(LSB.GrossAmount) AS GrossAmount,
				Sum(LSB.PrdSchemeDisc) As PrdSchemeDisc,
				SUM(LSB.TaxAmount) AS TaxAmount,
				SUM(LSB.NETAMOUNT) as NETAMOUNT,LSB.TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],SUM([OtherAmt]) AS [OtherAmt],
				SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage]INTO #Result
				FROM #RptLoadSheetItemWiseParle LSB Inner Join #PrdUomAll PU On PU.PrdId=LSB.PrdId
				GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[MRP],
				LSB.TotalBills,LSB.[PrdCtgValMainId],LSB.[CmpPrdCtgId]
				Order by LSB.[Product Description]
		Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result
		SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[PRoduct Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],MRP,MAX([Selling Rate]) AS [Selling Rate],
		 SUM(BilledQtyBox) AS BilledQtyBox ,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBox) AS TotalQtyBox,
		 SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],
		 SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,
		 SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage] 
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
delete from RptGroup where RptId=239
Insert Into RptGroup 
Select 'ParleReports',239,'DayEndCollection','Day End Collection Report'
Go
DELETE FROM RptHeader WHERE RptId=239
INSERT INTO RptHeader 
SELECT 'DAY End Collection','Day End Collection Report',239,'Day End Collection Report','Proc_RptDayEndCollection','RptDayEndCollection','RptDayEndCollection.rpt',''
GO
DELETE FROM RptDetails WHERE RptId=239
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (239,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (239,2,'ToDate',-1,'','','To Date*','',1,'',11,0,1,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (239,3,'Vehicle',-1,'','VehicleId,VehicleCode,VehicleRegNo','Vehicle...','',1,'',36,0,0,'Press F4/Double Click to Select Vehicle',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (239,4,'VehicleAllocationMaster',-1,'','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','',1,'',37,0,0,'Press F4/Double Click to Select Vehicle Allocation Number',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (239,5,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,0,0,'Press F4/Double Click to Select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (239,6,'RouteMaster',-1,'','RMId,RMCode,RMName','Delivery Route...','',1,'',35,0,0,'Press F4/Double Click to Select Delivery Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (239,7,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'0',3,0,0,'Press F4/Double Click to select Retailer',0)
GO
delete from RptFormula where RptId=239
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,1,'Fil_FromDate','From Date',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,2,'FilDisp_FromDate','FromDate',1,10)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,3,'Fil_ToDate','To Date',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,4,'FilDisp_ToDate','ToDate',1,11)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,5,'Fil_Vehicle','Vehicle',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,6,'FilDisp_Vehicle','Vehicle',1,36)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,7,'Fil_VehAllNo','Vehicle Allocation No',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,8,'FilDisp_VehAllNo','Vehicle Allocation No',1,37)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,9,'Fil_Salesman','Salesman',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,10,'FilDisp_Salesman','Salesman',1,1)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,11,'Fil_DlvRoute','Route',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,12,'FilDisp_DlvRoute','Route',1,35)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,13,'Fil_Retailer','Retailer',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(239,14,'FilDisp_Retailer','Retailer',1,3)
GO
delete from RptExcelHeaders where RptId=239
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,1,'vehno','vehno',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,2,'SalId','SalId',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,3,'SalInvNo','Bill Number',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,4,'SalInvDate','Bill Date',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,5,'SalInvRef','SalInvRef',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,6,'InvRcpNo','InvRcpNo',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,7,'InvRcpDate','Collection Date',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,8,'RtrId','RtrId',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,9,'RtrName','Retailer Name',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,10,'BillAmount','Bill Amount',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,11,'CurPayAmount','Paid Amount',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,12,'CrAdjAmount','CrAdjAmount',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,13,'DbAdjAmount','DbAdjAmount',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,14,'CashDiscount','Cash Discount',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,15,'CollCashAmt','Cash ',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,16,'CollChqAmt','Cheque',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,17,'CollDDAmt','CollDDAmt',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,18,'CollRTGSAmt','CollRTGSAmt',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,19,'BalanceAmount','Balance Amount',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,20,'CollectedAmount','CollectedAmount',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,21,'PayAmount','PayAmount',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,22,'TotalBillAmount','TotalBillAmount',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,23,'CashBill','CashBill',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,24,'Chequebill','Chequebill',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,25,'DDBill','DDBill',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,26,'RTGSBill','RTGSBill',0,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,27,'AdjustedAmt','Adjusted Amount',1,1)
insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)values(239,28,'TotalBills','TotalBills',0,1)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='RptCollectionValue_Parle' AND XTYPE ='U')
DROP table RptCollectionValue_Parle
GO
CREATE TABLE RptCollectionValue_Parle
(
	[SalId] [bigint] NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvNo] [nvarchar](100) NULL,
	[SalInvRef] [nvarchar](500) NULL,
	[SMId] [int] NULL,
	[SMName] [nvarchar](100) NULL,
	[InvRcpDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) NULL,
	[RMId] [int] NULL,
	[RMName] [nvarchar](100) NULL,
	[DlvRMId] [int] NULL,
	[DelRMName] [nvarchar](100) NULL,
	[BillAmount] [numeric](38, 6) NULL,
	[CrAdjAmount] [numeric](38, 6) NULL,
	[DbAdjAmount] [numeric](38, 6) NULL,
	[CashDiscount] [numeric](38, 6) NULL,
	[CollectedAmount] [numeric](38, 6) NULL,
	[PayAmount] [numeric](38, 6) NULL,
	[CurPayAmount] [numeric](38, 6) NULL,
	[CollCashAmt] [numeric](38, 6) NULL,
	[CollChqAmt] [numeric](38, 6) NULL,
	[CollDDAmt] [numeric](38, 6) NULL,
	[CollRTGSAmt] [numeric](38, 6) NULL,
	[InvRcpNo] [nvarchar](50) NULL,
	[OnAccValue] [numeric](38, 6) NULL,
	[CollectedDate] [datetime] NULL,
	[CollectedBy] [varchar](50) NULL,
	[Remarks] [varchar](1000) NULL
)  
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_CollectionValues_Parle' AND XTYPE ='P')
DROP PROCEDURE Proc_CollectionValues_Parle
GO
--EXEC Proc_CollectionValues_Parle '2012-01-01','2012-01-30'
CREATE PROCEDURE Proc_CollectionValues_Parle
(
@FromDate datetime,
@ToDate Datetime
)
AS
BEGIN	
SET NOCOUNT ON
	DECLARE @SalId AS BIGINT
	DECLARE @InvRcpDate AS DATETIME
	DECLARE @CrAdjAmount AS NUMERIC (38, 6)
	DECLARE @DbAdjAmount AS NUMERIC (38, 6)
	DECLARE @SalNetAmt AS NUMERIC (38, 6)
	DECLARE @CollectedAmount AS NUMERIC (38, 6)
	DECLARE @Count AS INT
	DECLARE @Prevamount AS NUMERIC (38, 6)
	DECLARE @CurPrevamount AS NUMERIC (38, 6)
	DECLARE @PrevSalId AS BIGINT
	DELETE FROM RptCollectionValue_Parle	

	INSERT INTO RptCollectionValue_Parle (SalId ,SalInvDate,SalInvNo,SalInvRef,
				SMId ,SMName,InvRcpDate,RtrId ,
				RtrName ,RMId ,RMName ,DlvRMId ,
				DelRMName ,BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollectedAmount,PayAmount,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo,OnAccValue,CollectedDate,CollectedBy,Remarks)
	SELECT SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,
	 SalNetAmt AS BillAmount,
	 SUM(CrAdjAmount) AS CrAdjAmount,SUM(DbAdjAmount) AS DbAdjAmount,
	 SUM(CashDiscount) AS CashDiscount,
	 SUM(CollectedAmount) AS CollectedAmount,
	 SUM(PayAmount) AS PayAmount, SUM(PayAmount) AS CurPayAmount,
	 SUM(CollCashAmt) AS CollCashAmt,SUM(CollChqAmt) AS CollChqAmt,SUM(CollDDAmt) AS CollDDAmt,SUM(CollRTGSAmt) AS CollRTGSAmt,InvRcpNo,SUM(OnAccValue),CollectedDate,CollectedBy,Remarks
	FROM(
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
		RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (1) AND RE.CollectedById = CASE CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				SUM(RI.DebitAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK),SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (1) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
		    SUM(RI.SalInvAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)		
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (3) AND
			RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END	
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,SUM(RI.DebitAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (3) 
					AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    SUM(RI.SalInvAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,	
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (4) AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,SUM(RI.DebitAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (4) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    0 AS CollDDAmt,SUM(RI.SalInvAmt) AS  CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (8) AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,SUM(RI.DebitAmt) AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (8) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			SUM(RI.SalInvAmt) AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=5 AND RI.CancelStatus=1
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				SUM(RI.DebitAmt) AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (5) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			SUM(RI.SalInvAmt) AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=6 AND RI.CancelStatus=1
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpMode,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,SUM(RI.SalInvAmt) AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=2 AND RI.CancelStatus=1
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,SUM(RI.DebitAmt) AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN SM.SMName WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (2) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
		UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,SUM(RI.SalInvAmt) AS OnAccValue,
		RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=7 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			RI.InvRcpNo,SI.SalNetAmt,RE.CollectedMode,DL.DlvBoyName,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
			) A
	GROUP BY SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,SalNetAmt,
	 	InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,InvRcpNo,CollectedBy,CollectedDate,Remarks

	IF NOT EXISTS (SELECT SalId FROM RptCollectionValue_Parle WHERE SalId<>0)
	BEGIN
		UPDATE RptCollectionValue_Parle SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalId,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount+B.OnAccValue-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue_Parle A
			LEFT OUTER JOIN RptCollectionValue_Parle B ON A.SalId=B.SalId AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalId,A.InvRcpDate) A WHERE A.SalId=RptCollectionValue_Parle.SalId
			AND A.InvRcpDate=RptCollectionValue_Parle.InvRcpDate AND BillAmount>0
	END
	ELSE
	BEGIN
		UPDATE RptCollectionValue_Parle SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalInvNo,A.InvRcpDate,A.InvRcpNo,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount+B.OnAccValue-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue_Parle A
			LEFT OUTER JOIN RptCollectionValue_Parle B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate,A.InvRcpNo) A WHERE A.SalInvNo=RptCollectionValue_Parle.SalInvNo
			AND A.InvRcpDate=RptCollectionValue_Parle.InvRcpDate AND a.InvRcpNo=RptCollectionValue_Parle.InvRcpNo and BillAmount>0

		UPDATE RptCollectionValue_Parle SET RptCollectionValue_Parle.CollCashAmt=RptCollectionValue_Parle.CollCashAmt-A.PayAmount
			FROM (
			SELECT A.invrcpno,A.SalInvNo,A.InvRcpDate,ISNULL(SUM(B.OnAccValue),0) AS PayAmount
			FROM RptCollectionValue_Parle A
			LEFT OUTER JOIN RptCollectionValue_Parle B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate,A.InvRcpNo) A WHERE A.SalInvNo=RptCollectionValue_Parle.SalInvNo
			AND A.InvRcpDate=RptCollectionValue_Parle.InvRcpDate and A.InvRcpNo=RptCollectionValue_Parle.InvRcpNo AND BillAmount>0
	END
	
	UPDATE RptCollectionValue_Parle SET CurPayAmount=ABS(CollCashAmt+CollChqAmt+CollDDAmt+CollRTGSAmt+CashDiscount+CrAdjAmount+OnAccValue-DbAdjAmount) WHERE BillAmount>0

END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptDayEndCollection' AND XTYPE ='P')
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
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCollectionDetailParle_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptCollectionDetailParle_Excel
		SELECT vehno,SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
		BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
		ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,
		CashBill,Chequebill,DDBill,RTGSBill,AdjustedAmt,[TotalBills] into RptCollectionDetailParle_Excel FROM #RptCollectionDetail 
		ORDER BY vehno,InvRcpDate
	END
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='RptCollectionValue_Parle' AND XTYPE ='U')
DROP table RptCollectionValue_Parle
GO
CREATE TABLE RptCollectionValue_Parle
(
	[SalId] [bigint] NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvNo] [nvarchar](100) NULL,
	[SalInvRef] [nvarchar](500) NULL,
	[SMId] [int] NULL,
	[SMName] [nvarchar](100) NULL,
	[InvRcpDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) NULL,
	[RMId] [int] NULL,
	[RMName] [nvarchar](100) NULL,
	[DlvRMId] [int] NULL,
	[DelRMName] [nvarchar](100) NULL,
	[BillAmount] [numeric](38, 6) NULL,
	[CrAdjAmount] [numeric](38, 6) NULL,
	[DbAdjAmount] [numeric](38, 6) NULL,
	[CashDiscount] [numeric](38, 6) NULL,
	[CollectedAmount] [numeric](38, 6) NULL,
	[PayAmount] [numeric](38, 6) NULL,
	[CurPayAmount] [numeric](38, 6) NULL,
	[CollCashAmt] [numeric](38, 6) NULL,
	[CollChqAmt] [numeric](38, 6) NULL,
	[CollDDAmt] [numeric](38, 6) NULL,
	[CollRTGSAmt] [numeric](38, 6) NULL,
	[InvRcpNo] [nvarchar](50) NULL,
	[OnAccValue] [numeric](38, 6) NULL,
	[CollectedDate] [datetime] NULL,
	[CollectedBy] [varchar](50) NULL,
	[Remarks] [varchar](1000) NULL
)  
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_CollectionValues_Parle' AND XTYPE ='P')
DROP PROCEDURE Proc_CollectionValues_Parle
GO
--EXEC Proc_CollectionValues_Parle '2012-01-01','2012-01-30'
CREATE PROCEDURE Proc_CollectionValues_Parle
(
@FromDate datetime,
@ToDate Datetime
)
/**********************************************************************************
* PROCEDURE		: Proc_CollectionValues
* PURPOSE		: To Display the Collection details
* CREATED		: MarySubashini.S
* CREATED DATE	: 01/06/2007
* NOTE			: General SP for Returning the Collection details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 01-09-2009	Thiruvengadam.L		CR changes
* 08-12-2009	Thiruvengadam.L		Cheque and DD are displayed in single column	
************************************************************************************/
AS
BEGIN	
SET NOCOUNT ON
	DECLARE @SalId AS BIGINT
	DECLARE @InvRcpDate AS DATETIME
	DECLARE @CrAdjAmount AS NUMERIC (38, 6)
	DECLARE @DbAdjAmount AS NUMERIC (38, 6)
	DECLARE @SalNetAmt AS NUMERIC (38, 6)
	DECLARE @CollectedAmount AS NUMERIC (38, 6)
	DECLARE @Count AS INT
	DECLARE @Prevamount AS NUMERIC (38, 6)
	DECLARE @CurPrevamount AS NUMERIC (38, 6)
	DECLARE @PrevSalId AS BIGINT
	DELETE FROM RptCollectionValue_Parle	

	INSERT INTO RptCollectionValue_Parle (SalId ,SalInvDate,SalInvNo,SalInvRef,
				SMId ,SMName,InvRcpDate,RtrId ,
				RtrName ,RMId ,RMName ,DlvRMId ,
				DelRMName ,BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollectedAmount,PayAmount,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo,OnAccValue,CollectedDate,CollectedBy,Remarks)
	SELECT SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,
	 SalNetAmt AS BillAmount,
	 SUM(CrAdjAmount) AS CrAdjAmount,SUM(DbAdjAmount) AS DbAdjAmount,
	 SUM(CashDiscount) AS CashDiscount,
	 SUM(CollectedAmount) AS CollectedAmount,
	 SUM(PayAmount) AS PayAmount, SUM(PayAmount) AS CurPayAmount,
	 SUM(CollCashAmt) AS CollCashAmt,SUM(CollChqAmt) AS CollChqAmt,SUM(CollDDAmt) AS CollDDAmt,SUM(CollRTGSAmt) AS CollRTGSAmt,InvRcpNo,SUM(OnAccValue),CollectedDate,CollectedBy,Remarks
	FROM(
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
		RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (1) AND RE.CollectedById = CASE CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				SUM(RI.DebitAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK),SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (1) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
		    SUM(RI.SalInvAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)		
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (3) AND
			RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END	
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,SUM(RI.DebitAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (3) 
					AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    SUM(RI.SalInvAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,	
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (4) AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,SUM(RI.DebitAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (4) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    0 AS CollDDAmt,SUM(RI.SalInvAmt) AS  CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (8) AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,SUM(RI.DebitAmt) AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (8) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			SUM(RI.SalInvAmt) AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=5 AND RI.CancelStatus=1
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				SUM(RI.DebitAmt) AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (5) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			SUM(RI.SalInvAmt) AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=6 AND RI.CancelStatus=1
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpMode,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,SUM(RI.SalInvAmt) AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=2 AND RI.CancelStatus=1
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,SUM(RI.DebitAmt) AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN SM.SMName WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (2) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
					and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
		UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,SUM(RI.SalInvAmt) AS OnAccValue,
		RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=7 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			and RE.InvRcpDate between convert(varchar(10),@FromDate,121) and convert(varchar(10),@ToDate,121)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			RI.InvRcpNo,SI.SalNetAmt,RE.CollectedMode,DL.DlvBoyName,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
--->Commented By Nanda to Remove On Account(Need to check thoroughly on Exccess Collections)
--	UNION
--		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,
--			RMD.RMName as DelRMName,0 AS CrAdjAmount,0 AS DbAdjAmount,
--			0 AS CashDiscount,0 AS SalNetAmt,
--			ISNULL(ROA.Amount,0) AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
--			0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
--		FROM ReceiptInvoice RI WITH (NOLOCK),
--			Receipt RE WITH (NOLOCK),
--			Retailer R WITH (NOLOCK),
--		        Salesman SM WITH (NOLOCK),
--			RouteMaster RM WITH (NOLOCK),
--			RouteMaster RMD WITH (NOLOCK),
--			RetailerOnAccount ROA WITH (NOLOCK),
--			SalesInvoice SI WITH (NOLOCK)
--		WHERE ROA.RtrId=R.RtrId AND SI.SMId=SM.SMId
--		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
--			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo
--			AND ROA.LastModDate=RE.InvRcpDate
--			AND ROA.TransactionType=0 AND ROA.OnAccType=0 AND ROA.RtrId=SI.RtrId
--		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--		 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
--		 ROA.Amount,RI.InvRcpNo
--->Till Here
			) A
	GROUP BY SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,SalNetAmt,
	 	InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,InvRcpNo,CollectedBy,CollectedDate,Remarks

	IF NOT EXISTS (SELECT SalId FROM RptCollectionValue_Parle WHERE SalId<>0)
	BEGIN
		UPDATE RptCollectionValue_Parle SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalId,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount+B.OnAccValue-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue_Parle A
			LEFT OUTER JOIN RptCollectionValue_Parle B ON A.SalId=B.SalId AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalId,A.InvRcpDate) A WHERE A.SalId=RptCollectionValue_Parle.SalId
			AND A.InvRcpDate=RptCollectionValue_Parle.InvRcpDate AND BillAmount>0
	END
	ELSE
	BEGIN
		UPDATE RptCollectionValue_Parle SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalInvNo,A.InvRcpDate,A.InvRcpNo,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount+B.OnAccValue-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue_Parle A
			LEFT OUTER JOIN RptCollectionValue_Parle B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate,A.InvRcpNo) A WHERE A.SalInvNo=RptCollectionValue_Parle.SalInvNo
			AND A.InvRcpDate=RptCollectionValue_Parle.InvRcpDate AND a.InvRcpNo=RptCollectionValue_Parle.InvRcpNo and BillAmount>0

		UPDATE RptCollectionValue_Parle SET RptCollectionValue_Parle.CollCashAmt=RptCollectionValue_Parle.CollCashAmt-A.PayAmount
			FROM (
			SELECT A.invrcpno,A.SalInvNo,A.InvRcpDate,ISNULL(SUM(B.OnAccValue),0) AS PayAmount
			FROM RptCollectionValue_Parle A
			LEFT OUTER JOIN RptCollectionValue_Parle B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate,A.InvRcpNo) A WHERE A.SalInvNo=RptCollectionValue_Parle.SalInvNo
			AND A.InvRcpDate=RptCollectionValue_Parle.InvRcpDate and A.InvRcpNo=RptCollectionValue_Parle.InvRcpNo AND BillAmount>0
	END
	
	UPDATE RptCollectionValue_Parle SET CurPayAmount=ABS(CollCashAmt+CollChqAmt+CollDDAmt+CollRTGSAmt+CashDiscount+CrAdjAmount+OnAccValue-DbAdjAmount) WHERE BillAmount>0

END
GO
----PDA Changes
IF NOT EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.ID=SC.ID AND S.NAME='OrderBooking' and SC.NAME='PDADownLoadFlag')
BEGIN
	ALTER TABLE OrderBooking ADD PDADownLoadFlag TinyInt DEFAULT 0 WITH values
END
GO
DELETE FROM HotsearchEditorHD WHERE FormId=10051
INSERT INTO HotsearchEditorHD(FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10051,'Sales Return','DocRefNo','Select','SELECT R.RtrId,Srno,RtrCode,RtrName,SMID,SMName,RM.RMID,RMNAME FROM PDA_SalesReturn  PD (NOLOCK)  INNER JOIN Retailer R (NOLOCK) ON R.Rtrid=Pd.Rtrid INNER JOIN RetailerMarket RTM (NOLOCK) ON RTM.RMID=PD.MktId AND RTM.Rtrid=R.Rtrid INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=RTM.RMID and RM.RMID=PD.MktId INNER JOIN SalesMan SM (NOLOCK) ON SM.SMID=PD.SrpID WHERE PD.Status=0' 
GO
DELETE FROM HotsearchEditorDT WHERE FormId=10051
INSERT INTO HotsearchEditorDT(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10051,'Doc Reference No','Reference No','Srno',4500,0,'HotSch-3-2000-36',3
UNION ALL
SELECT 1,10051,'Retailer Code','Retailer Code','RtrCode',4500,0,'HotSch-3-2000-37',3
UNION ALL
SELECT 1,10051,'Retailer Name','Retailer Name','RtrName',4500,0,'HotSch-3-2000-38',3
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10053
INSERT INTO HotSearchEditorDt
SELECT 1,10053,'RetailerCode','Code','CustomerCode',1000,0,'HotSch-79-2000-23',79
UNION 
SELECT 2,10053,'RetailerCode','Name','CustomerName',3500,0,'HotSch-79-2000-24',79
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10053
INSERT INTO HotSearchEditorHd
SELECT 10053,'Retailer Master','RetailerCode','select','SELECT distinct CustomerCode,CustomerName FROM PDA_NewRetailer where CustomerCode not in (select RtrCode from Retailer)'
GO
DELETE FROM CustomCaptions WHERE TransId=79 AND CtrlId=2000 AND SubCtrlId IN(24,25)
INSERT INTO CustomCaptions
SELECT 79,2000,24,'HotSch-79-2000-24','Code','','',1,1,1,getdate(),1,GETDATE(),'Code','','',1,1
UNION
SELECT 79,2000,25,'HotSch-79-2000-25','Name','','',1,1,1,getdate(),1,GETDATE(),'Name','','',1,1
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
DELETE FROM HotSearchEditorHd WHERE FormId=10052
INSERT INTO HotSearchEditorHd 
SELECT 10052,'Collection Register','CollectionRefNo','Select','SELECT ReceiptNo,ReceiptDate FROM PDA_ReceiptInvoice'
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10052
INSERT INTO HotSearchEditorDt 
SELECT 1,10052,'CollectionRefNo','Receipt No','ReceiptNo',1500,0,'HotSch-9-2000-14',9
UNION 
SELECT 1,10052,'CollectionRefNo','Collected Date','ReceiptDate',1500,0,'HotSch-9-2000-15',9
GO
-------Till here
delete from RptGroup where RptId=241
Insert Into RptGroup 
Select 'ParleReports',241,'VatSummaryReport','Vat Summary Report'
Go
DELETE FROM RptHeader WHERE RptId=241
INSERT INTO RptHeader 
SELECT 'Vat Summary','Vat Summary Report',241,'Vat Summary Report','Proc_RptVatSummary_Parle','RptVatsummary','RptVatSummary.rpt',''
GO
DELETE FROM RptDetails WHERE RptId=241
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (241,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (241,2,'ToDate',-1,'','','To Date*','',1,'',11,0,1,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (241,3,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Vat Type*...','',1,'',278,1,1,'Press F4/Double Click to Select Type',0)
GO
delete from RptFormula where RptId=241
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(241,1,'Disp_Fromdate','From Date',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(241,2,'Fill_Fromdate','FromDate',1,10)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(241,3,'Disp_Todate','To Date',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(241,4,'Fill_Todate','ToDate',1,11)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(241,5,'Disp_InvoiceType','Invoice Type',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(241,6,'Fill_InvoiceType','Invoice Type',1,278)
GO
delete from RptSelectionHD where SelcId=278
insert into RptSelectionHD
select 278,'Sel_VatType','RptFilter',1
GO
delete from RptFilter where RptId=241
insert into RptFilter
select 241,278,0,'Sales'
union
select 241,278,1,'Purchase'
GO
delete from RptGroup where RptId=244
Insert Into RptGroup 
Select 'ParleReports',244,'MonthlyVatSummaryReport','Monthly Vat Summary Report'
Go
DELETE FROM RptHeader WHERE RptId=244
INSERT INTO RptHeader 
SELECT 'Monthly Vat Summary','Monthly Vat Summary Report',244,'Monthly Vat Summary Report','Proc_RptMonthlyVatSummary_Parle','RptMonthlyVatSummary','RptMonthlyVatSummary.rpt',''
GO
DELETE FROM RptDetails WHERE RptId=244
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (244,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (244,2,'ToDate',-1,'','','To Date*','',1,'',11,0,1,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (244,3,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Vat Type*...','',1,'',278,1,1,'Press F4/Double Click to Select Type',0)
GO
delete from RptFormula where RptId=244
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(244,1,'Disp_Fromdate','From Date',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(244,2,'Fill_Fromdate','FromDate',1,10)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(244,3,'Disp_Todate','To Date',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(244,4,'Fill_Todate','ToDate',1,11)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(244,5,'Disp_InvoiceType','Invoice Type',1,0)
insert into RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)values(244,6,'Fill_InvoiceType','Invoice Type',1,278)
GO
delete from RptFilter where RptId=244
insert into RptFilter
select 244,278,0,'Sales'
union
select 244,278,1,'Purchase'
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Temp_IOTaxDetails_Parle' and xtype='U')
DROP TABLE Temp_IOTaxDetails_Parle
GO
CREATE TABLE Temp_IOTaxDetails_Parle
(
InvDate datetime,
GrossAmount numeric(18,6),
Discount numeric(18,6),
TaxPerc nvarchar(100),
TaxableAmount numeric(18,6),
IOTaxType varchar(50),
TaxFlag int,
TaxPercent numeric(18,6),
TaxId int,
Scheme numeric(18,6),
Damage numeric(18,6),
AddLess numeric(18,6),
FinalAmount numeric(18,6),
ColNo int
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_IOTaxSummary_Parle' and xtype='P')
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
 
If @TransType=0
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
	
	If @TransType=1
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
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='RptVatsummary' and xtype='U')
DROP TABLE RptVatsummary
GO
CREATE TABLE RptVatsummary
(
	InvDate datetime,
	GrossAmount numeric(18,6),
	Discount numeric(18,6),
	TaxPerc nvarchar(100),
	TaxableAmount numeric(18,6),
	TaxFlag int,
	TaxPercent numeric(18,6),
	TaxId int,
	Scheme numeric(18,6),
	Damage numeric(18,6),
	AddLess numeric(18,6),
	FinalAmount numeric(18,6),
	ColNo int
)
GO
if exists (select * from sysobjects where name='Proc_RptVatSummary_Parle' and xtype='P')
drop procedure Proc_RptVatSummary_Parle
GO
--Exec Proc_RptVatSummary_Parle 241,1,0,'eeeee',0,0,0
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
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,278,@Pi_UsrId))
	
	print @InvoiceType

	delete from RptVatsummary
		
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_IOTaxSummary_Parle @FromDate,@ToDate,@InvoiceType
	--select * from 	Temp_IOTaxDetails_Parle
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
	
	select * from 	RptVatsummary order by InvDate
  RETURN 
END 
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='RptMonthlyVatsummary' and xtype='U')
DROP TABLE RptMonthlyVatsummary
GO
CREATE TABLE RptMonthlyVatsummary
( 
	MonthId int,
	VatMonth varchar(100),
	JCyear varchar(100),
	GrossAmount numeric(18,6),
	Discount numeric(18,6),
	TaxPerc nvarchar(100),
	TaxableAmount numeric(18,6),
	TaxFlag int,
	TaxPercent numeric(18,6),
	TaxId int,
	Scheme numeric(18,6),
	Damage numeric(18,6),
	AddLess numeric(18,6),
	FinalAmount numeric(18,6),
	ColNo int
)
GO
IF exists (select * from sysobjects where name='Proc_RptMonthlyVatSummary_Parle' and xtype='P')
drop procedure Proc_RptMonthlyVatSummary_Parle
GO
--Exec Proc_RptMonthlyVatSummary_Parle 244,1,0,'eeeee',0,0,0
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
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,278,@Pi_UsrId))
	
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
	
	update ReportFilterDt set SelDate='Sales' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=278 and SelValue=0
	update ReportFilterDt set SelDate='Purchase' WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId and SelId=278 and SelValue=1
	
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Fn_ReturnRptFiltersValue' AND XTYPE='FN')
DROP FUNCTION Fn_ReturnRptFiltersValue
GO
CREATE  FUNCTION Fn_ReturnRptFiltersValue
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
		 End  
   --Till Here 
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
--Closing Stock Report 
Delete From RptGroup Where Rptid = 245
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName]) 
VALUES ('ParleReports',245,'ClosingStockReportParle','Closing Stock Report')
GO
DELETE FROM Rptheader Where RptId = 245
INSERT INTO Rptheader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds]) 
VALUES ('ClosingStockReportParle','ClosingStockReportParle',245,'Closing Stock Report','Proc_RptClosingStockReportParle','RptClosingStockParle','RptClosingStockParle.rpt','0')
GO
Delete From RptDetails Where RptId = 245
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,1,'ToDate',-1,NULL,'','As On Date*',NULL,1,NULL,11,0,0,'Enter the  Date',0)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,2,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company*...',NULL,1,NULL,4,1,1,'Press F4/Double Click to select Company',0)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,3,'Location',-1,NULL,'LcnId,LcnCode,LcnName','Location...',NULL,1,NULL,22,0,0,'Press F4/Double Click to select Location',0)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,4,'ProductCategoryLevel',2,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double click to select Hierarchy Level',1)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,5,'ProductCategoryValue',4,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to select Product Hierarchy Level Value',0)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,6,'Product',5,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,0,'Press F4/Double click to select Product',0)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,7,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Stock Value as per*...',NULL,1,NULL,209,1,1,'Press F4/Double Click to select Stock Value as per',0)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,8,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Product Status...',NULL,1,NULL,210,1,0,'Press F4/Double Click to select Product Status',0)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,9,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Batch Status...',NULL,1,NULL,211,1,0,'Press F4/Double Click to select Batch Status',0)
INSERT INTO Rptdetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,10,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Suppress Zero Stock*...',NULL,1,NULL,44,1,1,'Press F4/Double Click to Select the Supress Zero Stock',0)
GO
Delete from RptFilter Where RptId = 245
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,209,1,'Selling Rate')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,209,2,'List Price')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,210,0,'ALL')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,210,1,'Active')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,210,2,'InActive')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,211,0,'ALL')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,211,2,'Active')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,211,1,'InActive')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,44,1,'Yes')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (245,44,2,'No')
GO
Delete From RptFormula Where RptId = 245
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,1,'Disp_ToDate','As On Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,2,'Fill_ToDate','As On Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,3,'Disp_Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,4,'Fill_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,5,'Disp_Location','Location',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,6,'Fill_Location','Location',1,22)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,7,'Disp_ProductCategoryLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,8,'Fill_ProductCategoryLevel','ProductCategoryLevel',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,9,'Disp_ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,10,'Fill_ProductCategoryValue','ProductCategoryLevelValue',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,11,'Disp_Product','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,12,'Fill_Product','Product',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,13,'Disp_Batch','Stock Value as per',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,14,'Fill_Batch','Stock Value as per',1,209)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,15,'Disp_ProductStatus','Product Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,16,'Fill_ProductStatus','Product Status',1,210)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,17,'Disp_BatchStatus','Batch Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,18,'Fill_BatchStatus','Batch Status',1,211)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,19,'Disp_ProductDes','Product Description',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,20,'Disp_BatchT','Batch',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,21,'Disp_MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,22,'Disp_RATE','Display Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,23,'BOXES','BOXES',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,24,'Disp_StockValues','Gross Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,25,'PKTS','PKTS',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,26,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,27,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,28,'Disp_SupZeroStock','Suppress Zero Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,29,'Fill_SupZeroStock','Suppress Zero Stock',1,44)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,30,'Product Name','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,30,'Disp_Total','Grand Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,31,'ProductCode','Product Code',1,0)
GO
Delete From RptExcelHeaders Where RptId = 245
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (245,1,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (245,2,'PrdDCode','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (245,3,'PrdName','Product Description',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (245,4,'MRP','MRP',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (245,5,'RATE','RATE',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (245,6,'BOXES','BOXES',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (245,7,'PKTS','PKTS',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (245,8,'StockValue','Stock Value',1,1)
GO
IF EXISTS (Select * From sysobjects Where XTYPE = 'U' And name = 'TempClosingStock')
DROP TABLE TempClosingStock
GO
CREATE TABLE TempClosingStock(
	[CmpId] [int] NOT NULL,
	[PrdId] [int] NOT NULL,
	[LcnId] [int] NOT NULL,
	[PrdName] [nvarchar](100) NOT NULL,
	[Sellingrate] [numeric](38, 6) NOT NULL,
	[ListPrice] [numeric](38, 6) NOT NULL,
	[MRP] [numeric](38, 6) NOT NULL,
	[Cases] [int] NULL,
	[BoxStrip] [int] NULL,
	[Pieces] [int] NULL,
	[BaseQty] [Int]NULL,
	[BaseQtyWgt][numeric](38, 0),
	[PrdStatus] [int] NULL,
	[BatStatus] [int] NULL,
	[UsrId] [int] NULL,
	[CloPurRte] [numeric](38, 6) NULL,
	[CloSelRte] [numeric](38, 6) NULL,
	[UomId1] [tinyint] NULL,
	[UomId2] [tinyint] NULL,
	[UomId3] [tinyint] NULL,
	[ConversionFactor1] [int] NULL,
	[ConversionFactor2] [int] NULL,
	[ConversionFactor3] [int] NULL,
	[PrdUnitId] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempClosingStock] ADD  DEFAULT ((0)) FOR [UomId1]
GO
ALTER TABLE [dbo].[TempClosingStock] ADD  DEFAULT ((0)) FOR [UomId2]
GO
ALTER TABLE [dbo].[TempClosingStock] ADD  DEFAULT ((0)) FOR [UomId3]
GO
ALTER TABLE [dbo].[TempClosingStock] ADD  DEFAULT ((0)) FOR [ConversionFactor1]
GO
ALTER TABLE [dbo].[TempClosingStock] ADD  DEFAULT ((0)) FOR [ConversionFactor2]
GO
ALTER TABLE [dbo].[TempClosingStock] ADD  DEFAULT ((0)) FOR [ConversionFactor3]
GO
ALTER TABLE [dbo].[TempClosingStock] ADD  DEFAULT ((0)) FOR [PrdUnitId]
GO
IF EXISTS (Select * From SysObjects Where Name ='Proc_ClosingStock' And XTYPE = 'P')
DROP PROCEDURE Proc_ClosingStock
GO
--EXEC Proc_ClosingStock 153,2,'2008-11-06'
CREATE PROCEDURE Proc_ClosingStock
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
	EXEC Proc_GetStockLedgerSummaryDatewise @Pi_ToDate, @Pi_ToDate,@Pi_UsrId,0,0,0
	
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
		--AND LSB.UserId =@Pi_UsrId
	) A
END
GO
IF EXISTS (Select * From SysObjects Where Name ='Proc_RptClosingStockReportParle' And XTYPE = 'P')
DROP PROCEDURE Proc_RptClosingStockReportParle
GO
--EXEC Proc_RptClosingStockReport 245,1,0,'',0,0,1
CREATE PROCEDURE Proc_RptClosingStockReportParle
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
* {date} {developer}  {brief modification description}
	
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
	--Product UOM Details
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
 --Till Here			
	CREATE TABLE #RptClosingStock
	(
				PrdId		INT,
				PrdDCode     NVARCHAR(200),
				PrdName		NVARCHAR(200),
				MRP		    NUMERIC(38,6),
				RATE        NUMERIC(38,6),
				Qty		INT,
				StockValue	NUMERIC(38,6)				
	)
	SET @TblName = 'RptClosingStock'
	SET @TblStruct = 'PrdId		INT,
	            PrdDCode     NVARCHAR(200),
				PrdName		NVARCHAR(100),
				MRP		    NUMERIC(38,6),
				RATE        NUMERIC(38,6),
				Qty		INT,
				StockValue	NUMERIC(38,6)'
	SET @TblFields = 'PrdId,PrdDCode,PrdName,MRP,RATE,Qty,StockValue'
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
		INSERT INTO #RptClosingStock (PrdId,PrdDCode,PrdName,MRP,RATE,Qty,StockValue)
		SELECT DISTINCT T.PrdId,P.PrdDCode,T.PrdName,MRP,CASE @DispValue WHEN 1 THEN T.Sellingrate ELSE ListPrice END,
		SUM(BaseQty),SUM((CASE @DispValue WHEN 1 THEN (BaseQty * SellingRate) ELSE (BaseQty*ListPrice) END)) As StockValue
		FROM TempClosingStock T WITH (NOLOCK),Product P WITH (NOLOCK) 
		WHERE T.PrdId = P.PrdId And
		(T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
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
		GROUP BY T.PrdId,T.PrdName,MRP,SellingRate,ListPrice,P.PrdDCode Order By P.PrdDCode

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
	
	IF @SupZeroStock=1 
	BEGIN
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
	    SUM(StockValue) AS StockValue FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    Group By A.PrdId,PrdName,MRP,PrdDCode Having SUM(Qty) <> 0 Order By PrdDCode
	    IF EXISTS (SELECT * FROM Sysobjects Where XTYPE = 'U' And name = 'RptClosingStockReportParle_Excel')
		DROP TABLE RptClosingStockReportParle_Excel
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
	    SUM(StockValue) AS StockValue INTO RptClosingStockReportParle_Excel FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    Group By A.PrdId,PrdName,MRP,PrdDCode Having SUM(Qty) <> 0 Order By PrdDCode
	    
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock WHERE Qty <> 0
		-- Till Here
	END
	ELSE
	BEGIN
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
	    SUM(StockValue) AS StockValue FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    Group By A.PrdId,PrdName,MRP,PrdDCode Order By PrdDCode
	    IF EXISTS (SELECT * FROM Sysobjects Where XTYPE = 'U' And name = 'RptClosingStockReportParle_Excel')
		DROP TABLE RptClosingStockReportParle_Excel
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
	    SUM(StockValue) AS StockValue INTO RptClosingStockReportParle_Excel FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    Group By A.PrdId,PrdName,MRP,PrdDCode Order By PrdDCode
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock 
		 --Till Here
	END
	RETURN
END
GO
Delete From Configuration Where ModuleId = 'GENCONFIG29'
Insert into Configuration Select 'GENCONFIG29','General Configuration','Display selected UOM in Purchase Receipt',1,0,'0.00',29
GO
Delete From UomConfig
Insert into UomConfig Select 'GENCONFIG18',1,1,1,1,GETDATE(),1,GETDATE()
GO
If Exists (Select [Name] From SysObjects Where [Name]='RptUnloadingSheet' And XType='U')
Drop Table RptUnloadingSheet
GO
CREATE TABLE RptUnloadingSheet
(
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
If Exists (Select [Name] From SysObjects Where [Name]='RptUnloadingSheet_Excel' And XType='U')
Drop Table RptUnloadingSheet_Excel
GO
CREATE TABLE RptUnloadingSheet_Excel
	(
	[SalId] [int] NOT NULL,
	[SalInvNo] [varchar](50) NOT NULL,
	[RtrId] [int] NOT NULL,
	[RtrCode] [nvarchar](50) NOT NULL,
	[RtrName] [nvarchar](100) NOT NULL,
	[RtrShippingAddress] [nvarchar](600) NOT NULL,
	[PrdId] [int] NULL,
	[PrdDcode] [varchar](100) NULL,
	[PrdName] [varchar](100) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](100) NULL,
	[PrdUnitMRP] [numeric](38, 6) NULL,
	[PrdUnitSelRate] [numeric](38, 6) NULL,
	[LoadBilledQty] [bigint] NULL,
	[LoadFreeQty] [bigint] NULL,
	[LoadReplacementQty] [bigint] NULL,
	[UnLoadSalQty] [bigint] NULL,
	[UnLoadUnSalQty] [bigint] NULL,
	[UnLoadFreeQty] [bigint] NULL,
	[Reason] [nvarchar](200) NOT NULL,
	[UserId] [int] NULL
) ON [PRIMARY]
GO
If Exists (Select [Name] From SysObjects Where [Name]='SalesInvoiceModificationHistory' And XType='U')
Drop Table SalesInvoiceModificationHistory
GO
CREATE TABLE SalesInvoiceModificationHistory
	(
	[SalId] [bigint] NULL,
	[SalInvNo] [varchar](50) NULL,
	[SalInvDate] [datetime] NULL,
	[SalNetAmount] [numeric](38, 6) NULL,
	[LcnId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[BaseQty] [int] NULL,
	[PrdUnitMRP] [numeric](38, 6) NULL,
	[PrdUnitSelRate] [numeric](38, 6) NULL,
	[PrdGrossAmount] [numeric](38, 6) NULL,
	[SplDiscAmount] [numeric](38, 6) NULL,
	[PrdSchDiscAmount] [numeric](38, 6) NULL,
	[PrdDBDiscAmount] [numeric](38, 6) NULL,
	[PrdCdAmount] [numeric](38, 6) NULL,
	[PrimarySchemeAmount] [numeric](38, 6) NULL,
	[PrdTaxAmount] [numeric](38, 6) NULL,
	[PrdNetAmount] [numeric](38, 6) NULL,
	[StockType] [int] NULL,
	[TransactionFlag] [int] NULL,
	[AllotmentId] [int] NULL,
	[VersionNo] [int] NULL,
	[DlvSts] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[VehicleStstus] [int] NULL,
	[VehicleId] [int] NULL
) ON [PRIMARY]
GO
If Exists (Select [Name] From SysObjects Where [Name]='Proc_SalesInvoiceModificationHistory' And XType='P')
Drop Procedure Proc_SalesInvoiceModificationHistory
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
					 
	END
END
GO
Delete from RptGroup Where RptId=233
GO
Insert into RptGroup 
Select 'DailyReports',233,'UnLoadingSheetReport','UnLoadingSheetReport'
Go
Delete from RptHeader Where RptId=233
GO
Insert Into Rptheader
Select 'UnLoadingSheetReport','UnLoadingSheetReport',233,'UnLoadingSheetReport','Proc_RptUnloadingSheet','RptUnloadingSheet','RptUnloadingSheet.rpt',''
GO
Delete from RptFormula Where rptId=233
GO
Insert Into RptFormula
Select 233,1,'Disp_FromDate','From Date',1,0 Union All 
Select 233,2,'Fill_FromDate','FromDate',1,10 Union All 
Select 233,3,'Disp_ToDate','To Date',1,0 Union All 
Select 233,4,'Fill_ToDate','ToDate',1,11 Union All 
Select 233,5,'Disp_Vehicle','Vehicle',1,0 Union All 
Select 233,6,'Fill_Vehicle','Vehicle',1,36 Union All 
Select 233,7,'Disp_VehicleAlloc','Vehicle Allocation Number',1,0 Union All 
Select 233,8,'Fill_VehicleAlloc','VehicleAllocationNumber',1,37 Union All 
Select 233,9,'Disp_Salesman','Salesman',1,0 Union All 
Select 233,10,'Fill_Salesman','Salesman',1,1 Union All 
Select 233,11,'Disp_Route','Route',1,0 Union All 
Select 233,12,'Fill_Route','Route',1,35 Union All 
Select 233,13,'Disp_Retailer','Retailer',1,0 Union All
Select 233,14,'Fill_Retailer','Retailer',1,3 Union All
Select 233,15,'Disp_Product','Product Code',1,0 Union All
Select 233,16,'Disp_PrdouctName','Product Name',1,0 Union All
Select 233,17,'Disp_Batch','Batch No',1,0 Union All
Select 233,18,'Disp_MRP','MRP',1,0 Union All
Select 233,19,'Disp_Loaded','Loaded Qty',1,0 Union All
Select 233,20,'Disp_UnLoaded','UnLoaded Qty',1,0 Union All
Select 233,21,'Disp_BilledQty','Billed',1,0 Union All
Select 233,22,'Disp_FreeQty','Free',1,0 Union All 
Select 233,23,'Disp_ReplaceQty','Replacement',1,0 Union All
Select 233,24,'Disp_Saleable','Saleable',1,0 Union All
Select 233,25,'Disp_UnSaleable','UnSaleable',1,0 Union All
Select 233,26,'Disp_Offer','Offer',1,0 Union All
Select 233,27,'Cap Page','Page',1,0 Union All
Select 233,28,'Cap User Name','User Name',1,0 Union All
Select 233,29,'Cap Print Date','Date',1,0
GO
Delete From RptDetails Where RptId=233
GO
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (233,1,'FromDate',-1,'','','From Date*','',1,'',10,1,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (233,2,'ToDate',-1,'','','To Date*','',1,'',11,1,1,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (233,3,'Vehicle',-1,'','VehicleID,VehicleCode,VehicleRegNo','Vehicle ...','',1,'',36,1,0,'Press F4/Double Click to select Vehicle',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (233,4,'VehicleAllocationMaster',-1,'','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','',1,'',37,1,0,'Press F4/Double Click to Select Vehicle Allocation Number',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (233,5,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,1,0,'Press F4/Double Click to select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (233,6,'RouteMaster',-1,'','RMId,RMCode,RMName','Delivery Route...','',1,'',35,1,0,'Press F4/Double Click to Select Delivery Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (233,7,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'',3,1,0,'Press F4/Double Click to select Retailer',0)
GO
Delete from RptExcelHeaders Where RptId = 233
Insert Into RptExcelHeaders
Select 233,1,'PrdId','PrdId',0,1 Union All
Select 233,2,'PrdDcode','Product code',1,1 Union All
Select 233,3,'PrdName','Product Name',1,1 Union All
Select 233,4,'PrdBatId','PrdBatId',0,1 Union All
Select 233,5,'PrdBatCode','PrdBatCode',1,1 Union All
Select 233,6,'PrdUnitMRP','PrdUnitMRP',1,1 Union All
Select 233,7,'PrdUnitSelRate','PrdUnitSelRate',0,1 Union All
Select 233,8,'LoadBilledQtyBOX','LoadBilledQtyBOX',1,1 Union All
Select 233,9,'LoadBilledQtyPKTS','LoadBilledQtyPKTS',1,1 Union All
Select 233,10,'LoadFreeQtyBOX','LoadFreeQtyBOX',1,1 Union All
Select 233,11,'LoadFreeQtyPKTS','LoadFreeQtyPKTS',1,1 Union All
Select 233,12,'LoadReplacementQtyBOX','LoadReplacementQtyBOX',1,1 Union All
Select 233,13,'LoadReplacementQtyPKTS','LoadReplacementQtyPKTS',1,1 Union All
Select 233,14,'UnLoadSalQtyBOX','UnLoadSalableQtyBOX',1,1 Union All
Select 233,15,'UnLoadSalQtyPKTS','UnLoadSalableQtyPKTS',1,1 Union All
Select 233,16,'UnLoadUnSalQtyBOX','UnLoadUnSalableQtyBOX',1,1 Union All
Select 233,17,'UnLoadUnSalQtyPKTS','UnLoadUnSalableQtyPKTS',1,1 Union All
Select 233,18,'UnLoadFreeQtyBOX','UnLoadFreeQtyBOX',1,1 Union All
Select 233,19,'UnLoadFreeQtyPKTS','UnLoadFreeQtyPKTS',1,1 Union All
Select 233,20,'UserId','UserId',0,1 
GO
If Exists (Select [Name] From SysObjects Where [name]='Proc_RptUnloadingSheet' And XTYPE='P')
Drop Procedure Proc_RptUnloadingSheet
GO
-----Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
Create Procedure Proc_RptUnloadingSheet
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
/******************************************************************************************************
* CREATED BY	: PanneerSelvam.k
* CREATED DATE	: 05.11.2009 
* NOTE		    :
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}
* 12.11.2009	 	Panneer		 Added Cancel Transaction Details
* 14.11.2009       	Panneer		 Replacement Qty Value Mismatch
* 26.12.2009	 	Panneer		 Cancel Bill Qty Value Mismatch
* 01.02.2010       	Panneer		 Include Dlvsts 5
* 10-Jun-2010		Jayakumar.N	 BillWise RetailerWise is added
* 27.08.2010        Panneer      Shipping Address Duplicate Issue
* 17/01/2012		Praveenraj B Added Uom For Parle CR
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
	
			/*	Filter Variables  */
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate	 			AS	DATETIME
	DECLARE @VehicleId 			AS	INT
	DECLARE @VehicleAllocId 	AS	INT
	DECLARE @SMId 				AS	INT
	DECLARE @DlvRouteId 		AS	INT
	DECLARE @RtrId 				AS	INT
	Declare @UomId				As  Int
	Declare @UomCode			As VarChar(20)
		/*  Assgin Value for the Filter Variable  */
	SELECT	@FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT	@ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)	
	SET @VehicleId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))	
	SET @VehicleAllocId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET	@SMId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId  	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))	
	SET @RtrId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	Set @UomId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,52,@Pi_UsrId))
	Select @UomCode=UomDescription From UomMaster Where UomId=@UomId
	
	Print @UomId
	Print @UomCode
--	exec PROC_UNLOAD
	Create TABLE #RptUnLoadingSheetReport
	(
				PrdId			INT,
				PrdDcode		NVARCHAR(100),
				PrdName			NVARCHAR(100),
				PrdBatId		INT,
				PrdBatCode		NVARCHAR(100),
				PrdUnitMRP		NUMERIC(38,2),
				PrdUnitSelRate	NUMERIC(38,2),
				LoadBilledQty	NUMERIC(38,2),
				LoadFreeQty 	NUMERIC(38,2),
				LoadReplacementQty NUMERIC(38,2),
				UnLoadSalQty	NUMERIC(38,2),
				UnLoadUnSalQty  NUMERIC(38,2),
				UnLoadFreeQty   NUMERIC(38,2)
	)
	SET @TblName = 'RptUnloadingSheet'
	SET @TblStruct = '	
				PrdId			INT,
				PrdDcode		NVARCHAR(100),
				PrdName			NVARCHAR(100),
				PrdBatId		INT,
				PrdBatCode		NVARCHAR(100),
				PrdUnitMRP		NUMERIC(38,2),
				PrdUnitSelRate	NUMERIC(38,2),
				LoadBilledQty	NUMERIC(38,2),
				LoadFreeQty 	NUMERIC(38,2),
				LoadReplacementQty NUMERIC(38,2),
				UnLoadSalQty	NUMERIC(38,2),
				UnLoadUnSalQty  NUMERIC(38,2),
				UnLoadFreeQty   NUMERIC(38,2)'
	
	SET @TblFields =   'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
							LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId'
				/*  Till Here  */
				/* Snap Shot Required  */
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
			/* Till Here  */
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
	CREATE TABLE #RptUnloadingSheet(SalId INT,PrdId INT,PrdDcode Varchar(100),PrdName Varchar(100),
									PrdBatId INT,PrdBatCode Varchar(100),PrdUnitMRP Numeric(38,2),
									PrdUnitSelRate Numeric(38,2),
									LoadBilledQty BigInt,LoadFreeQty BigInt,LoadReplacementQty BigInt,
									UnLoadSalQty BigInt,UnLoadUnSalQty BigInt,UnLoadOfferQty INT,UserId INT)
				/* ----------  LoadBilledQty  and Saleable Qty  in Temp Table ----------------------------*/
	DELETE FROM RptUnloadingSheet  
	DELETE FROM #RptUnloadingSheet 
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
			Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
			Sum(LoadReplacementQty) LoadReplacementQty,
			0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty, UserId
	FROM (
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				Max(BaseQty)  LoadBilledQty,0 AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 1	
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId  ) X
		GROUP BY 
				SalId,PrdId,PrdDcode,PrdName,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,UserId,PrdBatId
		
				/* ----------  Loaded Free Qty  in Temp Table ----------------------------*/
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
		Sum(LoadReplacementQty) LoadReplacementQty,
		0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,UserId
	FROM (		
					/* Sales Free */
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,Max(BaseQty) AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 2
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId  
	  ) X
	GROUP BY 
			SalId,PrdId,PrdDcode,PrdName,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,UserId,PrdBatId
		
				/* ----------  Loaded Replacement Qty  in Temp Table ----------------------------*/
		
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
		MAX(LoadReplacementQty) LoadReplacementQty,
		0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty, @Pi_UsrId UserId
	FROM (		
					
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,Sum(BaseQty) AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId,
				VersionNo   
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 4 AND S.StockType = 1
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo 
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId ,VersionNo
		UNION ALL
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,sUM(BaseQty) AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId,VersionNo
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 4 AND S.StockType = 3
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )	
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId ,VersionNo 
	  ) X
	GROUP BY SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
				LoadBilledQty,LoadFreeQty
					
				/*  Loaded Market Return Qty */
		INSERT INTO #RptUnloadingSheet
		SELECT	DISTINCT
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 3 
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
	
-- Added on 10-Jun-2010
	--DELETE FROM RptUnloadingSheet_Excel WHERE UserId=@Pi_UsrId
	--INSERT INTO RptUnloadingSheet_Excel
	--SELECT 
	--		A.SalId,SalInvNo,SI.RtrId,RtrCode,RtrName,(RSA.RtrShipAdd1+' --> '+RSA.RtrShipAdd2+' --> '+RSA.RtrShipAdd3),
	--		A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,
	--		Sum(LoadBilledQty) LoadBilledQty,
	--		SUm(LoadFreeQty) LoadFreeQty,
	--		SUm(LoadReplacementQty) LoadReplacementQty,
	--		Sum(UnLoadSalQty) UnLoadSalQty,
	--		Sum(UnLoadUnSalQty) UnLoadUnSalQty,
	--		Sum(UnLoadOfferQty) UnLoadOfferQty,
	--		'' [Description],UserId
	--FROM 
	--		#RptUnloadingSheet A
	--		INNER JOIN SalesInvoice SI ON A.SalId=SI.SalId 
	--		INNER JOIN Retailer R ON SI.RtrId=R.RtrId
	--		Left Outer JOIN RetailerShipAdd RSA ON R.RtrId=RSA.RtrId 
	--						       and SI.RtrShipId = RSA.RtrShipId
	--WHERE 
	--		UserId = @Pi_UsrId
	--GROUP BY 
	--		A.SalId,SalInvNo,SI.RtrId,RtrCode,RtrName,RSA.RtrShipAdd1,RSA.RtrShipAdd2,RSA.RtrShipAdd3,
	--		A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,UserId
-- End here
		/*  Final Output Table */
	INSERT INTO RptUnloadingSheet  
	SELECT 
			PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP, 0 As PrdUnitSelRate,
			Sum(LoadBilledQty) LoadBilledQty,
			SUm(LoadFreeQty) LoadFreeQty,
			SUm(LoadReplacementQty) LoadReplacementQty,
			Sum(UnLoadSalQty) UnLoadSalQty,
			Sum(UnLoadUnSalQty) UnLoadUnSalQty,
			Sum(UnLoadOfferQty) UnLoadOfferQty,
			UserId
	FROM 
			#RptUnloadingSheet
	WHERE 
			UserId = @Pi_UsrId
	GROUP BY 
			PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,UserId
			/* ---------- Update UnLoaded Saleable Qty  in RptUnloadingSheet Table ----------*/
					/*  Latest  Version  */
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #Tmp1000
	FROM (
					/* SalesInvoiceProduct table */
			SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty
			FROM SalesInvoiceProduct 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId,SalId
					/* Replacement table */
			UNION ALL
			SELECT SalId,PrdId,PrdBatId,Sum(RepQty) BaseQty
			FROM ReplacementHd R,ReplacementOut  Ro 
			WHERE  R.RepRefNo = RO.RepRefNo 
				   AND Ro.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 1) 
				   AND  SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				   AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId	,SalId	)  X 
	GROUP BY PrdId,PrdBatId,SalId

--
--
--SELECT B.SalId,B.PrdId,B.PrdBatId,SUM(BaseQty) BaseQty, VersionNo
--			FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
--			WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
--				   AND UserId  = @Pi_UsrId	AND TransactionFlag = 4 
--				   AND StockType = 1 
--				   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
--										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
--			GROUP BY B.SalId,B.PrdId,B.PrdBatId,VersionNo

				/*  Base  Version  */
	SELECT SalId,PrdId,PrdBatId,BaseQty INTO #Tmp1001
	FROM (
		SELECT A.SalId,A.PrdId,A.PrdBatId,Max(BaseQty) BaseQty 
		FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
		WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
			   AND UserId  = @Pi_UsrId	AND TransactionFlag = 1 And A.VehicleId>0
			   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
		GROUP BY A.SalId,A.PrdId,A.PrdBatId
		UNION ALL
		SELECT SalId,PrdId,PrdBatId,mAX(BaseQty) BaseQty
		FROM (
			SELECT A.SalId,A.PrdId,A.PrdBatId,SUM(BaseQty) BaseQty, VersionNo
			FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
			WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
				   AND UserId  = @Pi_UsrId	AND TransactionFlag = 4  
				   AND StockType = 1 AND B.LoadReplaceMentQty>0
				   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdBatId,VersionNo ) C
		GROUP BY SalId,PrdId,PrdBatId ) X			  
	GROUP BY SalId,PrdId,PrdBatId,BaseQty

		/*	Compare Base AND Latest Version */
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #FinalUnLoadSal
	FROM (
			SELECT PrdId,PrdBatId,Sum(BaseQty)BaseQty
			FROM #Tmp1000
			GROUP BY PrdId,PrdBatId
			UNION ALL	
			SELECT PrdId,PrdBatId,Sum(-BaseQty) BaseQty
			FROM #Tmp1001
			GROUP BY PrdId,PrdBatId ) X
	GROUP BY PrdId,PrdBatId
	--Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1

-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #FinalUnLoadSal_New
	FROM (
			SELECT SalId,PrdId,PrdBatId,Sum(BaseQty)BaseQty
			FROM #Tmp1000
			GROUP BY SalId,PrdId,PrdBatId
			UNION ALL	
			SELECT SalId,PrdId,PrdBatId,Sum(-BaseQty) BaseQty
			FROM #Tmp1001
			GROUP BY SalId,PrdId,PrdBatId ) X
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadSalQty =  Abs(BaseQty)
	--FROM  RptUnloadingSheet_Excel A,#FinalUnLoadSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- End here
	UPDATE RptUnloadingSheet SET UnLoadSalQty =  Abs(BaseQty)
			FROM  RptUnloadingSheet a,#FinalUnLoadSal B
			WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId -------AND BaseQty >= 0 
	
--Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
			/*  Update Market Return Saleable  */
	SELECT DISTINCT SR.SalId,Rp.PrdId,RP.PrdBatId,Rp.BaseQty INTO #Tmp1003
	FROM SalesInvoiceMarketReturn SR,#RptUnloadingSheet A,
	     ReturnHeader RH,ReturnProduct RP
	WHERE A.SalId = SR.SalID AND SR.ReturnId = RH.ReturnID
			AND RH.ReturnID = RP.ReturnID  AND A.PrdId = RP.PrdId AND A.PrdBatId = Rp.PrdBatId
			AND RP.StockTypeId in (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 1)
			AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
					WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRSal
	FROM #Tmp1003
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadSalQty = UnLoadSalQty + BaseQty
	FROM  RptUnloadingSheet a,#TempMRSal B
	WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRSal_New
	FROM #Tmp1003
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadSalQty = UnLoadSalQty + BaseQty
	--FROM RptUnloadingSheet_Excel A,#TempMRSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- End here
			/*	Till Here  */
		/* ---------- Update UnLoaded UnSaleable Qty in RptUnloadingSheet Table ----------*/
			/*  Update Market Return UnSaleable  */
	SELECT DISTINCT SR.SalId,Rp.PrdId,RP.PrdBatId,Rp.BaseQty INTO #Tmp1004
	FROM SalesInvoiceMarketReturn SR,#RptUnloadingSheet A,
			ReturnHeader RH,ReturnProduct RP
	WHERE A.SalId = SR.SalID AND SR.ReturnId = RH.ReturnID
			AND RH.ReturnID = RP.ReturnID  AND A.PrdId = RP.PrdId AND A.PrdBatId = Rp.PrdBatId
			AND RP.StockTypeId in (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2)
			AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
					WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRUnSal
	FROM #Tmp1004
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadUnSalQty = UnLoadUnSalQty + BaseQty
	FROM  RptUnloadingSheet a,#TempMRUnSal B
	WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRUnSal_New
	FROM #Tmp1004
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadUnSalQty = UnLoadUnSalQty + BaseQty
	--FROM  RptUnloadingSheet_Excel A,#TempMRUnSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
-- End here
		/*	Till Here  */
		/* ---------- Update UnLoaded Free Qty  in RptUnloadingSheet Table ----------*/
			
						/* SalesInvoiceProduct table Manual Free */
		SELECT SalId,PrdId,PrdbatId,Sum(BaseQty) BaseQty INTO #TempLat1006
		FROM (
			SELECT DISTINCT SalId,PrdId,PrdBatId,Sum(SalManFreeQty) BaseQty
			FROM SalesInvoiceProduct 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
			AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId,SalId
			UNION ALL
							/* SalesInvoiceFree table Free */
			SELECT DISTINCT SalId,FreePrdId,FreePrdBatId,Sum(FreeQty)  FreeQty
			FROM SalesInvoiceSchemeDtFreePrd 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY FreePrdId,FreePrdBatId,SalId	
			UNION ALL
							/* Market Return Table Scheme Free */
			SELECT DISTINCT SR.SalId,RF.FreePrdId,RF.FreePrdBatId,Sum(RF.ReturnFreeQty) BaseQty
			FROM 	ReturnSchemeFreePrdDt RF,ReturnHeader RH,SalesInvoiceMarketReturn SR
			WHERE	SR.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
					AND RH.ReturnID = RF.ReturnId  AND RH.ReturnID = SR.ReturnId
					AND SR.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY SR.SalId,RF.FreePrdId,RF.FreePrdBatId
			UNION ALL
							/* Market Return Offer  */
			SELECT DISTINCT SR.SalId,RF.PrdId,RF.PrdBatId,Sum(RF.BaseQty) BaseQty
			FROM 	ReturnProduct RF,ReturnHeader RH,SalesInvoiceMarketReturn SR
			WHERE	SR.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
					AND RH.ReturnID = RF.ReturnId  AND RH.ReturnID = SR.ReturnId
					AND RF.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 3)
				    AND SR.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY SR.SalId,RF.PrdId,RF.PrdBatId
			UNION ALL
							/* Replacement Offer */
			SELECT DISTINCT RH.SalId,Ro.PrdId,Ro.PrdBatId,Sum(Ro.RepQty) BaseQty
			FROM ReplacementHd RH,ReplacementOut RO
			WHERE RH.RepRefNo = RO.RepRefNo
				  AND RH.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND Ro.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 3)
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY RH.SalId,Ro.PrdId,Ro.PrdBatId	) y
		GROUP BY SalId,PrdId,PrdBatId		
					/*  Base  Version  */
					/* Scheme */
		SELECT SalId,PrdId,PrdbatId,Sum(BaseQty) BaseQty INTO #Tmpbase1007
		FROM (
			SELECT DISTINCT A.SalId,A.PrdId,A.PrdbatId,Max(BaseQty) BaseQty
			FROM SalesInvoiceModificationHistory  a, #RptUnloadingSheet B
			WHERE TransactionFlag = 2 AND A.SalId = B.SalId
				  AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
				  AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdbatId		
			UNION All
			SELECT DISTINCT A.SalId,A.PrdId,A.PrdbatId,Max(BaseQty) BaseQty
			FROM SalesInvoiceModificationHistory  a, #RptUnloadingSheet B
			WHERE TransactionFlag = 4 AND A.SalId = B.SalId
					AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
					AND StockType = 3
					AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdbatId		) Z
		GROUP BY SalId,PrdId,PrdbatId	
		/* Update Free in RptUnLoadingSheet Table */
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempUnLFree
	FROM (
		SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty 
		FROM #TempLat1006
		GROUP BY PrdId,PrdBatId
		UNION All
		SELECT PrdId,PrdBatId,Sum(-BaseQty) BaseQty  
		FROM #Tmpbase1007
		GROUP BY PrdId,PrdBatId ) h
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadFreeQty = Abs(UnLoadFreeQty) + Abs(BaseQty)
			FROM  RptUnloadingSheet a,#TempUnLFree B
			WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempUnLFree_New
	FROM (
		SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty 
		FROM #TempLat1006
		GROUP BY SalId,PrdId,PrdBatId
		UNION All
		SELECT SalId,PrdId,PrdBatId,Sum(-BaseQty) BaseQty  
		FROM #Tmpbase1007
		GROUP BY SalId,PrdId,PrdBatId 
	     ) h
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadFreeQty = Abs(UnLoadFreeQty) + Abs(BaseQty)
	--FROM RptUnloadingSheet_Excel A, #TempUnLFree_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
-- End here
					/*   Update Cancel Bill Saleable - */
							/* Saleable Qty */
		SELECT PrdId,PrdBatId,Sum(BilledQty) BilledQty INTO #TempCancelBilledQty
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadBilledQty) AS BilledQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY  PrdId,PrdBatId
		UPDATE RptUnloadingSheet SET UnLoadSalQty =  UnLoadSalQty + BilledQty
						FROM RptUnloadingSheet a, #TempCancelBilledQty B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(BilledQty) BilledQty INTO #TempCancelBilledQty_New
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadBilledQty) AS BilledQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY SalId,PrdId,PrdBatId
		--UPDATE A SET UnLoadSalQty =  UnLoadSalQty + BilledQty
		--FROM RptUnloadingSheet_Excel A, #TempCancelBilledQty_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
-- End here
							
				/*   Update Cancel Bill Offer - */
							/* Offer Qty */
		SELECT PrdId,PrdBatId,Sum(FreeQty) FreeQty INTO #TempCancelFree
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadFreeQty) AS FreeQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY  PrdId,PrdBatId				
		UPDATE RptUnloadingSheet SET UnLoadFreeQty = UnLoadFreeQty + FreeQty
						FROM RptUnloadingSheet a, #TempCancelFree B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(FreeQty) FreeQty INTO #TempCancelFree_New
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadFreeQty) AS FreeQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY SalId,PrdId,PrdBatId	
			
		--UPDATE A SET UnLoadFreeQty = UnLoadFreeQty + FreeQty
		--FROM RptUnloadingSheet_Excel a, #TempCancelFree_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
-- Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
-- End here
						/*   Update Cancel Bill UnSaleable - */
					/*	Canceled Bill -- Market UnSaleable  */
		SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempCancelUnSal
				FROM (	
					SELECT 	D.PrdId,D.PrdBatId,Sum(BaseQty) BaseQty  
					FROM	SalesInvoice A ,SalesInvoiceMarketReturn B, #RptUnloadingSheet C,
							ReturnProduct D,ReturnHeader E
					WHERE	 DlvSts = 3 AND A.SalId = B.SalId	AND B.SalId = C.SalId
							 AND A.SalId = C.SalId  AND B.ReturnId = E.ReturnID  AND D.ReturnID = E.ReturnID
							 AND D.PrdId = C.PrdId  AND D.PrdBatId = C.PrdBatId
							 AND D.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2) 
							 AND UserId  = @Pi_UsrId 
					GROUP BY D.PrdId,D.PrdBatId 
					) v
				GROUP By	PrdId,PrdbatId
				/* Update in Calcel Bill Qty UnSaleable */
				UPDATE RptUnloadingSheet SET UnLoadUnSalQty = 0 ------UnLoadUnSalQty - BaseQty
						FROM RptUnloadingSheet a, #TempCancelUnSal B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempCancelUnSal_New
		FROM (	
			SELECT C.SalId,D.PrdId,D.PrdBatId,Sum(BaseQty) BaseQty  
			FROM SalesInvoice A ,SalesInvoiceMarketReturn B, #RptUnloadingSheet C,
					ReturnProduct D,ReturnHeader E
			WHERE DlvSts = 3 AND A.SalId = B.SalId	AND B.SalId = C.SalId
					 AND A.SalId = C.SalId  AND B.ReturnId = E.ReturnID  AND D.ReturnID = E.ReturnID
					 AND D.PrdId = C.PrdId  AND D.PrdBatId = C.PrdBatId
					 AND D.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2) 
					 AND UserId  = @Pi_UsrId 
			GROUP BY C.SalId,D.PrdId,D.PrdBatId 
			) v
		GROUP By SalId,PrdId,PrdbatId
		/* Update in Calcel Bill Qty UnSaleable */
		--UPDATE A SET UnLoadUnSalQty = 0 ------UnLoadUnSalQty - BaseQty
		--FROM RptUnloadingSheet_Excel A, #TempCancelUnSal_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
		--UPDATE A SET Reason=[Description] FROM RptUnloadingSheet_Excel A,ReturnProduct RP,ReasonMaster R 
		--WHERE A.SalId=RP.SalId AND RP.ReasonId=R.ReasonId AND A.PrdId=RP.PrdId AND A.PrdBatId=RP.PrdBatId
-- End here
--Added by Praveenraj B for Parle CR--Display in Qty
	
					Create Table #PrdUom1 
					(
					PrdId Int,
					ConversionFactor Int
					)
					
					SELECT Prdid,Conversionfactor Into #PrdUom from Product P 
						INNER JOIN UomGroup UG ON UG.UomgroupId=P.UomgroupId
						INNER JOIN UomMaster U ON U.UomId=UG.UOMId
						WHERE U.UomCode='BX'
	--Select * from UomMaster				
					SELECT Prdid,Conversionfactor Into #PrdUom2 from Product P 
						INNER JOIN UomGroup UG ON UG.UomgroupId=P.UomgroupId
						INNER JOIN UomMaster U ON U.UomId=UG.UOMId
						WHERE U.UomCode<>'BX' And PrdId Not In (Select PrdId From #PrdUom) And BaseUom='Y'
					Insert Into #PrdUom1
					Select Distinct Prdid,Conversionfactor From #PrdUom
					Union All
					Select Distinct Prdid,Conversionfactor From #PrdUom2
	
					Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
					INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
					SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptUnloadingSheet WHERE UserId =@Pi_UsrId
					SELECT ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
					CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN 0 ELSE LoadBilledQty/MAX(ConversionFactor) END As LoadBilledQtyBOX,
				    CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN LoadBilledQty ELSE LoadBilledQty%MAX(ConversionFactor) END As LoadBilledQtyPKTS,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE LoadFreeQty/MAX(ConversionFactor)END As LoadFreeQtyBOX,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN LoadFreeQty ELSE LoadFreeQty%MAX(ConversionFactor) END As LoadFreeQtyPKTS,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN 0 ELSE LoadReplacementQty/MAX(ConversionFactor)END LoadReplacementQtyBOX,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN LoadReplacementQty ELSE LoadReplacementQty%MAX(ConversionFactor) END As LoadReplacementQtyPKTS,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadSalQty/MAX(ConversionFactor)END AS UnLoadSalQtyBOX,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN UnLoadSalQty ELSE UnLoadSalQty%MAX(ConversionFactor) END As UnLoadSalQtyPKTS,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadUnSalQty/MAX(ConversionFactor)END AS UnLoadUnSalQtyBOX,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN UnLoadUnSalQty ELSE UnLoadUnSalQty%MAX(ConversionFactor) END As UnLoadUnSalQtyPKTS,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadFreeQty/MAX(ConversionFactor)END AS UnLoadFreeQtyBOX,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN UnLoadFreeQty ELSE UnLoadFreeQty%MAX(ConversionFactor) END As UnLoadFreeQtyPKTS,
					UserId
					FROM RptUnloadingSheet ST INNER JOIN #PrdUom1 P ON P.Prdid=ST.Prdid
					Where UserId=@Pi_UsrId And 
					(LoadBilledQty+LoadFreeQty+LoadReplacementQty+UnLoadSalQty+UnLoadUnSalQty+UnLoadFreeQty)>0
					GROUP BY  ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
					LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId
					Order By PrdDcode
					
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
				Begin
					If Exists (Select [Name] From SysObjects Where [Name]='RptUnloadingSheet_Excel' And XTYPE='U')
					Drop Table RptUnloadingSheet_Excel
					SELECT ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
					CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN 0 ELSE LoadBilledQty/MAX(ConversionFactor) END As LoadBilledQtyBOX,
				    CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN LoadBilledQty ELSE LoadBilledQty%MAX(ConversionFactor) END As LoadBilledQtyPKTS,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE LoadFreeQty/MAX(ConversionFactor)END As LoadFreeQtyBOX,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN LoadFreeQty ELSE LoadFreeQty%MAX(ConversionFactor) END As LoadFreeQtyPKTS,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN 0 ELSE LoadReplacementQty/MAX(ConversionFactor)END LoadReplacementQtyBOX,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN LoadReplacementQty ELSE LoadReplacementQty%MAX(ConversionFactor) END As LoadReplacementQtyPKTS,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadSalQty/MAX(ConversionFactor)END AS UnLoadSalQtyBOX,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN UnLoadSalQty ELSE UnLoadSalQty%MAX(ConversionFactor) END As UnLoadSalQtyPKTS,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadUnSalQty/MAX(ConversionFactor)END AS UnLoadUnSalQtyBOX,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN UnLoadUnSalQty ELSE UnLoadUnSalQty%MAX(ConversionFactor) END As UnLoadUnSalQtyPKTS,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadFreeQty/MAX(ConversionFactor)END AS UnLoadFreeQtyBOX,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN UnLoadFreeQty ELSE UnLoadFreeQty%MAX(ConversionFactor) END As UnLoadFreeQtyPKTS,
					UserId INTO RptUnloadingSheet_Excel
					FROM RptUnloadingSheet ST INNER JOIN #PrdUom1 P ON P.Prdid=ST.Prdid
					Where UserId=@Pi_UsrId And 
					(LoadBilledQty+LoadFreeQty+LoadReplacementQty+UnLoadSalQty+UnLoadUnSalQty+UnLoadFreeQty)>0
					GROUP BY  ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
					LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId
					Order By PrdDcode
					  
				End	
		-- Till Here
	END
END
GO
delete from hotsearcheditorhd where formid= 238
insert into hotsearcheditorhd  
select 238,'Purchase Order','ReferenceNo','Select','SELECT PurOrderRefNo,CmpId,CmpName,SpmId,SpmName,PurOrderDate,CmpPoNo,CmpPoDate,PurOrderExpiryDate,FillAllPrds,GenQtyAuto,PurOrderStatus,  
ConfirmSts,DownLoad,Upload,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValName,PrdCtgValLinkCode,SiteId,SiteCode,PurOrderValue,DispOrdVal,POType,Status      
FROM (SELECT A.PurOrderRefNo,A.CmpId,B.CmpName,A.SpmId,C.SpmName,A.PurOrderDate,A.CmpPoNo,A.CmpPoDate,A.PurOrderExpiryDate,A.FillAllPrds,A.GenQtyAuto, 
A.PurOrderStatus,A.ConfirmSts,A.DownLoad,A.Upload, ISNULL(A.CmpPrdCtgId,0) AS CmpPrdCtgId,  ISNULL(PCL.CmpPrdCtgName,'''') AS CmpPrdCtgName,     
ISNULL(A.PrdCtgValMainId,0) AS PrdCtgValMainId,  ISNULL(PCV.PrdCtgValName,'''') AS PrdCtgValName,  ISNULL(PCV.PrdCtgValLinkCode,0) AS PrdCtgValLinkCode ,    
SCM.SiteId,SCM.SiteCode,A.PurOrderValue,A.DispOrdVal,(CASE A.Download WHEN 1 THEN ''System Generated'' ELSE ''Manual'' END) AS POType,status      
FROM PurchaseOrderMaster A LEFT OUTER JOIN Company B ON B.CmpId=A.CmpId  LEFT OUTER JOIN Supplier C ON A.SpmId=C.SpmId  LEFT JOIN ProductCategoryLevel PCL ON PCL.CmpPrdCtgId=A.CmpPrdCtgId        
LEFT JOIN ProductCategoryValue PCV ON PCV.PrdCtgValMainId=A.PrdCtgValMainId  LEFT OUTER JOIN SiteCodeMaster SCM ON PCV.PrdCtgValMainId=SCM.PrdCtgValMainId AND SCM.SiteId=A.SiteID   
inner join(SELECT purorderrefno,''Closed'' as Status from PurchaseOrderMaster WHERE  confirmsts=1 UNION ALL SELECT purorderrefno,''Cancelled'' as Status from PurchaseOrderMaster  
WHERE purorderstatus =2 UNION ALL SELECT purorderrefno,''Expired'' as Status from PurchaseOrderMaster where PurOrderExpiryDate<convert(varchar(10),getdate(),121) and confirmsts=0  
and purorderstatus =0 UNION ALL select purorderrefno,''Pending'' as Status from PurchaseOrderMaster where purorderrefno in (select PurOrderRefNo FROM PurchaseReceipt) 
UNION ALL SELECT purorderrefno,''Open'' as Status from PurchaseOrderMaster where convert(varchar(10),getdate(),121) between purorderdate and PurOrderExpiryDate and confirmsts=0 and purorderstatus =0)Z 
on Z.purorderrefno=A.purorderrefno ) AS A'
GO
delete from hotsearcheditordt where formid= 238
insert into hotsearcheditordt  
select 1,238,'ReferenceNo','Reference No','PurOrderRefNo',1100,2,'HotSch-26-2000-3',26
union
select 2,238,'ReferenceNo','Date','PurOrderDate',1100,1,'HotSch-26-2000-4',26
union
select 3,238,'ReferenceNo','PO Type','POType',1600,3,'HotSch-26-2000-39',26
union
select 4,238,'ReferenceNo','status','Satus',1400,3,'HotSch-26-2000-40',26
GO
Delete from customcaptions where transid=26 and ctrlid=2000 and subctrlid=40
Insert into customcaptions
Select 26,2000,40,'HotSch-26-2000-40','Satus','','',1,1,1,'2010-04-21 12:21:38.990',1,'2010-04-21 12:21:38.990','Satus','','',1,1
GO
UPDATE CustomCaptions set Caption='Confirmed Qty',DefaultCaption='Confirmed Qty' Where TransId=26 and CtrlId=5 and SubCtrlId=10
GO
--Retailer Selection Without Route Attached Retailer is not Reflecting in billing Screen
Delete From HotSearchEditorHd Where FormId = 556
INSERT INTO HotSearchEditorHd SELECT 556,'Billing','Direct Retailer Based on Sequence','Select',
'SELECT RtrId,RtrSeqDtId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,RtrTINNo,  
RtrCSTNo,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,  RtrCrLimitAlert FROM (SELECT D.RtrId,100000 as RtrSeqDtId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrTaxType,
D.RMId AS DelvRMId,  D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,  ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrLicExpiryDate,  D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,
ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,  ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,
ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121))   AS RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) Where D.RtrStatus = 1 And RtrId in (Select RtrId From RetailerMarket)) a ORDER BY RtrSeqDtId'
GO
Delete From HotSearchEditorHd Where FormId = 557
INSERT INTO HotSearchEditorHd SELECT 557,'Billing','Direct Retailer Based on Name','Select',
'SELECT RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
RtrTINNo,RtrCSTNo,RtrLicNo,  RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,
RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert   FROM (SELECT D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscAmt,
D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,  D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,  
ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,  ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,
D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),  GetDate(),121)) AS RtrPestExpiryDate,ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,
ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,  ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) Where D.RtrStatus = 1 And RtrId in (Select RtrId From RetailerMarket)) a ORDER BY RtrName'
GO
Delete From HotSearchEditorHd Where FormId = 558
INSERT INTO HotSearchEditorHd SELECT 558,'Billing','Direct Retailer Based on Code','Select',
'SELECT RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,RtrTINNo,
RtrCSTNo,RtrLicNo,  RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert   FROM (SELECT D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscAmt,D.RtrTaxType,
D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,  D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo,D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,
D.RtrDrugLicNo,  ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),  
GetDate(),121)) AS RtrPestExpiryDate,ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,  
ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert 
FROM Retailer D (NOLOCK) Where D.RtrStatus = 1 And RtrId in (Select RtrId From RetailerMarket)) a ORDER BY RtrCode'
GO
DELETE FROM Tbl_Uploadintegration
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (1,'Upload Record Check','UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (2,'Retailer','Retailer','Cs2Cn_Prk_Retailer','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (3,'Daily Sales','Daily_Sales','Cs2Cn_Prk_DailySales','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (4,'Stock','Stock','Cs2Cn_Prk_Stock','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (5,'Sales Return','Sales_Return','Cs2Cn_Prk_SalesReturn','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (6,'Purchase Confirmation','Purchase_Confirmation','Cs2Cn_Prk_PurchaseConfirmation','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (7,'Purchase Return','Purchase_Return','Cs2Cn_Prk_PurchaseReturn','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (8,'Claims','Claims','Cs2Cn_Prk_ClaimAll','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (9,'Scheme Utilization','Scheme_Utilization','Cs2Cn_Prk_SchemeUtilizationDetails','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (10,'Sample Issue','Sample_Issue','Cs2Cn_Prk_SampleIssue','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (11,'Sample Receipt','Sample_Receipt','Cs2Cn_Prk_SampleReceipt','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (12,'Sample Return','Sample_Return','Cs2Cn_Prk_SampleReturn','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (13,'Salesman','Salesman','Cs2Cn_Prk_Salesman','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (14,'Route','Route','Cs2Cn_Prk_Route','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (15,'Retailer Route','Retailer_Route','Cs2Cn_Prk_RetailerRoute','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (16,'Order Booking','Order_Booking','Cs2Cn_Prk_OrderBooking','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (17,'Sales Invoice Orders','Sales_Invoice_Orders','Cs2Cn_Prk_SalesInvoiceOrders','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (18,'Scheme Claim Details','Scheme_Claim_Details','Cs2Cn_Prk_Claim_SchemeDetails','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (19,'Daily Business Details','Daily_Business_Details','Cs2Cn_Prk_DailyBusinessDetails','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (20,'DB Details','DB_Details','Cs2Cn_Prk_DBDetails','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (21,'Download Tracing','DownloadTracing','Cs2Cn_Prk_DownLoadTracing','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (22,'Upload Tracing','UploadTracing','Cs2Cn_Prk_UpLoadTracing','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (23,'Daily Retailer Details','Daily_Retailer_Details','Cs2Cn_Prk_DailyRetailerDetails','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (24,'Daily Product Details','Daily_Product_Details','Cs2Cn_Prk_DailyProductDetails','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (25,'Cluster Assign','Cluster_Assign','Cs2Cn_Prk_ClusterAssign','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (26,'Purchase Order','Purchase_Order','Cs2Cn_Prk_PurchaseOrder','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (27,'Route Village','Route_Village','Cs2Cn_Prk_RouteVillage','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (1001,'ReUpload Initiate','ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','2011-03-22')
INSERT INTO Tbl_Uploadintegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) VALUES (1002,'Downloaded Details','Downloaded_Details','Cs2Cn_Prk_DownloadedDetails','2011-03-22')
GO
DELETE FROM Tbl_Downloadintegration
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (1,'Hierarchy Level','Cn2Cs_Prk_HierarchyLevel','Proc_Import_HierarchyLevel',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (2,'Hierarchy Level Value','Cn2Cs_Prk_HierarchyLevelValue','Proc_Import_HierarchyLevelValue',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (3,'Retailer Hierarchy','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (4,'Retailer Classification','Cn2Cs_Prk_BLRetailerValueClass','Proc_ImportBLRetailerValueClass',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (5,'Prefix Master','Cn2Cs_Prk_PrefixMaster','Proc_Import_PrefixMaster',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (6,'Retailer Approval','Cn2Cs_Prk_RetailerApproval','Proc_Import_RetailerApproval',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (7,'UOM','Cn2Cs_Prk_BLUOM','Proc_ImportBLUOM',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (8,'Tax Configuration Group Setting','Etl_Prk_TaxConfig_GroupSetting','Proc_ImportTaxMaster',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (9,'Tax Settings','Etl_Prk_TaxSetting','Proc_ImportTaxConfigGroupSetting',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (10,'Product Hierarchy Change','Cn2Cs_Prk_BLProductHiereachyChange','Proc_ImportBLProductHiereachyChange',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (11,'Product','Cn2Cs_Prk_Product','Proc_Import_Product',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (12,'Product Batch','Cn2Cs_Prk_ProductBatch','Proc_Import_ProductBatch',0,200,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (13,'Product Tax Mapping','Etl_Prk_TaxMapping','Proc_ImportTaxGrpMapping',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (14,'Special Rate','Cn2Cs_Prk_SpecialRate','Proc_Import_SpecialRate',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (15,'Scheme Header Slabs Rules','Etl_Prk_SchemeHD_Slabs_Rules','Proc_ImportSchemeHD_Slabs_Rules',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (16,'Scheme Products','Etl_Prk_SchemeProducts_Combi','Proc_ImportSchemeProducts_Combi',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (17,'Scheme Attributes','Etl_Prk_Scheme_OnAttributes','Proc_ImportScheme_OnAttributes',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (18,'Scheme Free Products','Etl_Prk_Scheme_Free_Multi_Products','Proc_ImportScheme_Free_Multi_Products',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (19,'Scheme On Another Product','Etl_Prk_Scheme_OnAnotherPrd','Proc_ImportScheme_OnAnotherPrd',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (20,'Scheme Retailer Validation','Etl_Prk_Scheme_RetailerLevelValid','Proc_ImportScheme_RetailerLevelValid',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (21,'Purchase','Cn2Cs_Prk_BLPurchaseReceipt','Proc_ImportBLPurchaseReceipt',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (22,'Purchase Receipt Mapping','Cn2Cs_Prk_PurchaseReceiptMapping','Proc_Import_PurchaseReceiptMapping',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (23,'Scheme Master Control','Cn2Cs_Prk_NVSchemeMasterControl','Proc_ImportNVSchemeMasterControl',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (24,'Claim Norm','Cn2Cs_Prk_ClaimNorm','Proc_Import_ClaimNorm',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (25,'Reason Master','Cn2Cs_Prk_ReasonMaster','Proc_Import_ReasonMaster',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (26,'Bulletin Board','Cn2Cs_Prk_BulletinBoard','Proc_Import_BulletinBoard',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (27,'ERP Product Mapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Proc_Import_ERPPrdCCodeMapping',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (28,'Configuration','Cn2Cs_Prk_Configuration','Proc_Import_Configuration',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (29,'Claim Settlement','Cn2Cs_Prk_ClaimSettlementDetails','Proc_Import_ClaimSettlementDetails',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (30,'Cluster Master','Cn2Cs_Prk_ClusterMaster','Proc_Import_ClusterMaster',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (31,'Cluster Group','Cn2Cs_Prk_ClusterGroup','Proc_Import_ClusterGroup',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (32,'Cluster Assign Approval','Cn2Cs_Prk_ClusterAssignApproval','Proc_Import_ClusterAssignApproval',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (33,'Supplier','Cn2Cs_Prk_SupplierMaster','Proc_Import_SupplierMaster',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (34,'UDC Master','Cn2Cs_Prk_UDCMaster','Proc_Import_UDCMaster',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (35,'UDC Details','Cn2Cs_Prk_UDCDetails','Proc_Import_UDCDetails',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (36,'UDC Defaults','Cn2Cs_Prk_UDCDefaults','Proc_Import_UDCDefaults',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (37,'Retailer Migration','Cn2Cs_Prk_RetailerMigration','Proc_Import_RetailerMigration',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (38,'Points Rules Header','Cn2Cs_Prk_PointsRulesHeader','Proc_Import_PointsRulesHeader',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (39,'Points Rules Retailer','Cn2Cs_Prk_PointsRulesRetailer','Proc_Import_PointsRulesRetailer',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (40,'Points Rules Slab','CN2CS_Prk_PointsRulesSlab','Proc_Import_PointsRulesSlab',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (41,'Points Rules Slab Product','Cn2Cs_Prk_PointsRulesProduct','Proc_Import_PointsRulesSlabProduct',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (42,'ReUpload','Cn2Cs_Prk_ReUpload','Proc_Import_ReUpload',0,500,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (43,'Purchase Receipt Adjustments','Cn2Cs_Prk_PurchaseReceiptAdjustments','Proc_Import_PurchaseReceiptAdjustments',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (44,'Village Master','Cn2Cs_Prk_VillageMaster','Proc_Import_VillageMaster',0,100,'2011-03-22')
INSERT INTO Tbl_Downloadintegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) VALUES (45,'Scheme Payout','Cn2Cs_Prk_SchemePayout','Proc_Import_SchemePayout',0,100,'2011-03-22')
GO
DELETE FROM Customupdownload
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (101,1,'Retailer','Retailer','Proc_Cs2Cn_Retailer','Proc_ImportRetailer','Cs2Cn_Prk_Retailer','Proc_CN2CSRetailer','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (102,1,'Daily Sales','Daily Sales','Proc_Cs2Cn_DailySales','Proc_ImportBLDailySales','Cs2Cn_Prk_DailySales','Proc_ValidateDailySales','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (103,1,'Stock','Stock','Proc_Cs2Cn_Stock','Proc_ImportStock','Cs2Cn_Prk_Stock','Proc_ValidateStock','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (104,1,'Sales Return','Sales Return','Proc_Cs2Cn_SalesReturn','Proc_ImportBLSalesReturn','Cs2Cn_Prk_SalesReturn','Proc_CN2CSBLSalesReturn','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (105,1,'Purchase Confirmation','Purchase Confirmation','Proc_Cs2Cn_PurchaseConfirmation','Proc_ImportPurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','Proc_CN2CSBLPurchaseConfirmation','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (106,1,'Purchase Return','Purchase Return','Proc_Cs2Cn_PurchaseReturn','Proc_ImportPurchaseReturn','Cs2Cn_Prk_PurchaseReturn','Proc_CN2CSPurchaseReturn','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (107,1,'Claims','Claims','Proc_Cs2Cn_ClaimAll','Proc_ImportBLClaimAll','Cs2Cn_Prk_ClaimAll','Proc_Cn2Cs_BLClaimAll','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (108,1,'Scheme Utilization','Scheme Utilization','Proc_Cs2Cn_SchemeUtilizationDetails','Proc_Import_SchemeUtilizationDetails','Cs2Cn_Prk_SchemeUtilizationDetails','Proc_Cn2Cs_SchemeUtilizationDetails','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (109,1,'Sample Issue','Sample Issue','Proc_Cs2Cn_SampleIssue','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleIssue','Proc_ValidateSampleIssue','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (110,1,'Sample Receipt','Sample Receipt','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReceipt','Proc_ValidateSampleIssue','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (111,1,'Sample Return','Sample Return','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReturn','Proc_ValidateSampleIssue','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (112,1,'Purchase Order','Purchase Order','Proc_Cs2Cn_PurchaseOrder','Proc_Import_PurchaseOrder','Cs2Cn_Prk_PurchaseOrder','Proc_Cn2Cs_PurchaseOrder','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (113,1,'Order Booking','Order Booking','Proc_Cs2Cn_OrderBooking','Proc_Import_OrderBooking','Cs2Cn_Prk_OrderBooking','Proc_Cn2Cs_OrderBooking','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (114,1,'Sales Invoice Orders','Sales Invoice Orders','Proc_Cs2Cn_Dummy','Proc_Import_SalesInvoiceOrders','Cs2Cn_Prk_SalesInvoiceOrders','Proc_Cn2Cs_SalesInvoiceOrders','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (115,1,'Salesman','Salesman','Proc_Cs2Cn_Salesman','Proc_Import_Salesman','Cs2Cn_Prk_Salesman','Proc_Cn2Cs_Salesman','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (116,1,'Route','Route','Proc_Cs2Cn_Route','Proc_Import_Route','Cs2Cn_Prk_Route','Proc_Cn2Cs_Route','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (117,1,'Retailer Route','Retailer Route','Proc_Cs2Cn_RetailerRoute','Proc_Import_RetailerRoute','Cs2Cn_Prk_RetailerRoute','Proc_Cn2Cs_RetailerRoute','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (118,1,'Route Village','Route Village','Proc_Cs2Cn_RouteVillage','Proc_Import_RouteVillage','Cs2Cn_Prk_RouteVillage','Proc_Cn2Cs_RouteVillage','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (119,1,'Cluster Assign','Cluster Assign','Proc_Cs2Cn_ClusterAssign','Proc_Import_ClusterAssign','Cs2Cn_Prk_ClusterAssign','Proc_Cn2Cs_ClusterAssign','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (120,1,'Daily Business Details','Daily Business Details','Proc_Cs2Cn_DailyBusinessDetails','Proc_Import_DailyBusinessDetails','Cs2Cn_Prk_DailyBusinessDetails','Proc_Cn2Cs_DailyBusinessDetails','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (121,1,'DB Details','DB Details','Proc_Cs2Cn_DBDetails','Proc_Import_DBDetails','Cs2Cn_Prk_DBDetails','Proc_Cn2Cs_DBDetails','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (122,1,'Download Trace','DownloadTracing','Proc_Cs2Cn_DownLoadTracing','Proc_ImportDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','Proc_Cn2CsDownLoadTracing','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (123,1,'Upload Trace','UploadTracing','Proc_Cs2Cn_UpLoadTracing','Proc_ImportUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','Proc_Cn2CsUpLoadTracing','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (124,1,'Daily Retailer Details','Daily Retailer Details','Proc_Cs2Cn_DailyRetailerDetails','','Cs2Cn_Prk_DailyRetailerDetails','','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (125,1,'Daily Product Details','Daily Product Details','Proc_Cs2Cn_DailyProductDetails','','Cs2Cn_Prk_DailyProductDetails','','Master','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (126,1,'Upload Record Check','UploadRecordCheck','Proc_Cs2Cn_UploadRecordCheck','','Cs2Cn_Prk_UploadRecordCheck','','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (127,1,'ReUpload Initiate','ReUploadInitiate','Proc_Cs2Cn_ReUploadInitiate','','Cs2Cn_Prk_ReUploadInitiate','','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (128,1,'For Integration','ForIntegration','Proc_IntegrationHouseKeeping','','Cs2Cn_Prk_IntegrationHouseKeeping','','Transaction','Upload',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (201,1,'Hierarchy Level','Hieararchy Level','Proc_Cs2Cn_HierarchyLevel','Proc_Import_HierarchyLevel','Cn2Cs_Prk_HierarchyLevel','Proc_Cn2Cs_HierarchyLevel','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (202,1,'Hierarchy Level Value','Hieararchy Level Value','Proc_Cs2Cn_HierarchyLevelValue','Proc_Import_HierarchyLevelValue','Cn2Cs_Prk_HierarchyLevelValue','Proc_Cn2Cs_HierarchyLevelValue','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (203,1,'Retailer Category Level Value','Retailer Category Level Value','Proc_CS2CNBLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_Cn2Cs_BLRetailerCategoryLevelValue','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (204,1,'Retailer Value Classification','Retailer Value Classification','Proc_CS2CNBLRetailerValueClass','Proc_ImportBLRetailerValueClass','Cn2Cs_Prk_BLRetailerValueClass','Proc_Cn2Cs_BLRetailerValueClass','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (205,1,'Prefix Master','Prefix Master','Proc_Cs2Cn_PrefixMaster','Proc_Import_PrefixMaster','Cn2Cs_Prk_PrefixMaster','Proc_Cn2Cs_PrefixMaster','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (206,1,'Retailer Aproval','Retailer Approval','Proc_Cs2Cn_RetailerApproval','Proc_Import_RetailerApproval','Cn2Cs_Prk_RetailerApproval','Proc_Cn2Cs_RetailerApproval','Master','Download',0)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (207,1,'UOM','UOM','Proc_Cn2Cs_BLUOM','Proc_ImportBLUOM','Cn2Cs_Prk_BLUOM','Proc_Cn2Cs_BLUOM','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (208,1,'Tax Configuration','Tax Configuration','Proc_ValidateTaxConfig_Group','Proc_ImportTaxMaster','Etl_Prk_TaxConfig_GroupSetting','Proc_ValidateTaxConfig_Group','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (209,1,'Tax Setting','Tax Setting','Proc_CN2CS_TaxSetting','Proc_ImportTaxConfigGroupSetting','Etl_Prk_TaxSetting','Proc_CN2CS_TaxSetting','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (210,1,'Product Hierarchy Change','Product Hierarchy Change','Proc_CS2CNBLProductHierarchyChange','Proc_ImportBLProductHiereachyChange','Cn2Cs_Prk_BLProductHiereachyChange','Proc_Cn2Cs_BLProductHiereachyChange','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (211,1,'Product','Product','Proc_Cs2Cn_Product','Proc_Import_Product','Cn2Cs_Prk_Product','Proc_Cn2Cs_Product','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (212,1,'Product Batch','Product Batch','Proc_Cs2Cn_ProductBatch','Proc_Import_ProductBatch','Cn2Cs_Prk_ProductBatch','Proc_Cn2Cs_ProductBatch','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (213,1,'Tax Group Mapping','Tax Group Mapping','Proc_ValidateTaxMapping','Proc_ImportTaxGrpMapping','Etl_Prk_TaxMapping','Proc_ValidateTaxMapping','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (214,1,'Special Rate','Special Rate','Proc_Cs2Cn_SpecialRate','Proc_Import_SpecialRate','Cn2Cs_Prk_SpecialRate','Proc_Cn2Cs_SpecialRate','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (215,1,'Cluster Master','Cluster Master','Proc_Cs2Cn_ClusterMaster','Proc_Import_ClusterMaster','Cn2Cs_Prk_ClusterMaster','Proc_Cn2Cs_ClusterMaster','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (216,1,'Cluster Group','Cluster Group','Proc_Cs2Cn_ClusterGroup','Proc_Import_ClusterGroup','Cn2Cs_Prk_ClusterGroup','Proc_Cn2Cs_ClusterGroup','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,1,'Scheme','Scheme Master','Proc_CS2CNBLSchemeMaster','Proc_ImportBLSchemeMaster','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeMaster','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,2,'Scheme','Scheme Attributes','Proc_CS2CNBLSchemeAttributes','Proc_ImportBLSchemeAttributes','Etl_Prk_Scheme_OnAttributes','Proc_CN2CS_BLSchemeAttributes','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,3,'Scheme','Scheme Products','Proc_CS2CNBLSchemeProducts','Proc_ImportBLSchemeProducts','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeProducts','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,4,'Scheme','Scheme Slabs','Proc_CS2CNBLSchemeSlab','Proc_ImportBLSchemeSlab','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeSlab','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,5,'Scheme','Scheme Rule Setting','Proc_CS2CNBLSchemeRulesetting','Proc_ImportBLSchemeRulesetting','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeRulesetting','Transaction','Download',0)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,6,'Scheme','Scheme Free Products','Proc_CS2CNBLSchemeFreeProducts','Proc_ImportBLSchemeFreeProducts','Etl_Prk_Scheme_Free_Multi_Products','Proc_CN2CS_BLSchemeFreeProducts','Transaction','Download',0)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,7,'Scheme','Scheme Combi Products','Proc_CS2CNBLSchemeCombiPrd','Proc_ImportBLSchemeCombiPrd','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeCombiPrd','Transaction','Download',0)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (217,8,'Scheme','Scheme On Another Product','Proc_CS2CNBLSchemeOnAnotherPrd','Proc_ImportBLSchemeOnAnotherPrd','Etl_Prk_Scheme_OnAnotherPrd','Proc_CN2CS_BLSchemeOnAnotherPrd','Transaction','Download',0)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (218,1,'Scheme Master Control','Scheme Master Control','Proc_CS2CNNVSchemeMasterControl','Proc_ImportNVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','Proc_Cn2Cs_NVSchemeMasterControl','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (219,1,'Claim Settlement','Claim Settlement','Proc_Cs2Cn_ClaimSettlementDetails','Proc_Import_ClaimSettlementDetails','Cn2Cs_Prk_ClaimSettlementDetails','Proc_Cn2Cs_ClaimSettlementDetails','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (220,1,'Purchase Receipt','Purchase Receipt','Proc_Cs2Cn_PurchaseReceipt','Proc_ImportBLPurchaseReceipt','Cn2Cs_Prk_BLPurchaseReceipt','Proc_Cn2Cs_PurchaseReceipt','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (221,1,'Purchase Receipt Mapping','Purchase Receipt Mapping','Proc_Cs2Cn_PurchaseReceiptMapping','Proc_Import_PurchaseReceiptMapping','Cn2Cs_Prk_PurchaseReceiptMapping','Proc_Cn2Cs_PurchaseReceiptMapping','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (222,1,'Claim Norm Mapping','Claim Norm Mapping','Proc_Cs2Cn_ClaimNorm','Proc_Import_ClaimNorm','Cn2Cs_Prk_ClaimNorm','Proc_Cn2Cs_ClaimNorm','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (223,1,'Reason Master','Reason Master','Proc_Cs2Cn_ReasonMaster','Proc_Import_ReasonMaster','Cn2Cs_Prk_ReasonMaster','Proc_Cn2Cs_ReasonMaster','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (224,1,'Bulletin Board','BulletingBoard','Proc_Cs2Cn_BulletinBoard','Proc_Import_BulletinBoard','Cn2Cs_Prk_BulletinBoard','Proc_Cn2Cs_BulletinBoard','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (225,1,'ERP Product Mapping','ERP Product Mapping','Proc_Cs2Cn_ERPPrdCCodeMapping','Proc_Import_ERPPrdCCodeMapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Proc_Cn2Cs_ERPPrdCCodeMapping','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (226,1,'Configuration','Configuration','Proc_Cs2Cn_Configuration','Proc_Import_Configuration','Cn2Cs_Prk_Configuration','Proc_Cn2Cs_Configuration','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (227,1,'Cluster Assign Approval','Cluster Assign Approval','Proc_Cs2Cn_ClusterAssignApproval','Proc_Import_ClusterAssignApproval','Cn2Cs_Prk_ClusterAssignApproval','Proc_Cn2Cs_ClusterAssignApproval','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (228,1,'Supplier Master','Supplier Master','Proc_Cs2Cn_SupplierMaster','Proc_Import_SupplierMaster','Cn2Cs_Prk_SupplierMaster','Proc_Cn2Cs_SupplierMaster','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (229,1,'UDC Master','UDC Master','Proc_Cs2Cn_UDCMaster','Proc_Import_UDCMaster','Cn2Cs_Prk_UDCMaster','Proc_Cn2Cs_UDCMaster','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (230,1,'UDC Details','UDC Details','Proc_Cs2Cn_UDCDetailss','Proc_Import_UDCDetails','Cn2Cs_Prk_UDCDetails','Proc_Cn2Cs_UDCDetails','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (231,1,'UDC Defaults','UDC Defaults','Proc_Cs2Cn_UDCDefaults','Proc_Import_UDCDefaults','Cn2Cs_Prk_UDCDefaults','Proc_Cn2Cs_UDCDefaults','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (232,1,'Retailer Migration','Retailer Migration','Proc_Cs2Cn_RetailerMigration','Proc_Import_RetailerMigration','Cn2Cs_Prk_RetailerMigration','Proc_Cn2Cs_RetailerMigration','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (233,1,'Point Redemption Rules','Point Redemption Rules','Proc_Cs2Cn_PointsRulesSetting','Proc_Import_PointsRulesSetting','Cn2Cs_Prk_PointsRulesHeader','Proc_Cn2Cs_PointsRulesSetting','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (234,1,'Village Master','Village Master','Proc_Cs2Cn_VillageMaster','Proc_Import_VillageMaster','Cn2Cs_Prk_VillageMaster','Proc_Cn2Cs_Dummy','Master','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (235,1,'Scheme Payout','Scheme Payout','Proc_Cs2Cn_SchemePayout','Proc_Import_SchemePayout','Cn2Cs_Prk_SchemePayout','Proc_Cn2Cs_SchemePayout','Transaction','Download',1)
INSERT INTO Customupdownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) VALUES (236,1,'ReUpload','ReUpload','Proc_Cs2Cn_ReUpload','Proc_Import_ReUpload','Cn2Cs_Prk_ReUpload','Proc_Cn2Cs_ReUpload','Transaction','Download',1)
GO
DELETE FROM CustomupdownloadCount
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (101,1,'Retailer','Retailer','Cs2Cn_Prk_Retailer','Cs2Cn_Prk_Retailer','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (102,1,'Daily Sales','Daily Sales','Cs2Cn_Prk_DailySales','Cs2Cn_Prk_DailySales','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (103,1,'Stock','Stock','Cs2Cn_Prk_Stock','Cs2Cn_Prk_Stock','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (104,1,'Sales Return','Sales Return','Cs2Cn_Prk_SalesReturn','Cs2Cn_Prk_SalesReturn','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (105,1,'Purchase Confirmation','Purchase Confirmation','Cs2Cn_Prk_PurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (106,1,'Purchase Return','Purchase Return','Cs2Cn_Prk_PurchaseReturn','Cs2Cn_Prk_PurchaseReturn','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (107,1,'Claims','Claims','Cs2Cn_Prk_ClaimAll','Cs2Cn_Prk_ClaimAll','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (108,1,'Scheme Utilization','Scheme Utilization','Cs2Cn_Prk_SchemeUtilizationDetails','Cs2Cn_Prk_SchemeUtilizationDetails','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (109,1,'Sample Issue','Sample Issue','Cs2Cn_Prk_SampleIssue','Cs2Cn_Prk_SampleIssue','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (110,1,'Sample Receipt','Sample Receipt','Cs2Cn_Prk_SampleReceipt','Cs2Cn_Prk_SampleReceipt','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (111,1,'Sample Return','Sample Return','Cs2Cn_Prk_SampleReturn','Cs2Cn_Prk_SampleReturn','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (112,1,'Purchase Order','Purchase Order','Cs2Cn_Prk_PurchaseOrder','Cs2Cn_Prk_PurchaseOrder','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (113,1,'Order Booking','Order Booking','Cs2Cn_Prk_OrderBooking','Cs2Cn_Prk_OrderBooking','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (114,1,'Sales Invoice Orders','Sales Invoice Orders','Cs2Cn_Prk_SalesInvoiceOrders','Cs2Cn_Prk_SalesInvoiceOrders','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (115,1,'Salesman','Salesman','Cs2Cn_Prk_Salesman','Cs2Cn_Prk_Salesman','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (116,1,'Route','Route','Cs2Cn_Prk_Route','Cs2Cn_Prk_Route','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (117,1,'Retailer Route','Retailer Route','Cs2Cn_Prk_RetailerRoute','Cs2Cn_Prk_RetailerRoute','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (118,1,'Route Village','Route Village','Cs2Cn_Prk_RouteVillage','Cs2Cn_Prk_RouteVillage','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (119,1,'Cluster Assign','Cluster Assign','Cs2Cn_Prk_ClusterAssign','Cs2Cn_Prk_ClusterAssign','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (120,1,'Daily Business Details','Daily Business Details','Cs2Cn_Prk_DailyBusinessDetails','Cs2Cn_Prk_DailyBusinessDetails','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (121,1,'DB Details','DB Details','Cs2Cn_Prk_DBDetails','Cs2Cn_Prk_DBDetails','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (122,1,'Download Trace','DownloadTracing','ETL_PRK_CS2CNDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (123,1,'Upload Trace','UploadTracing','ETL_PRK_CS2CNUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (124,1,'Daily Retailer Details','Daily Retailer Details','Cs2Cn_Prk_DailyRetailerDetails','Cs2Cn_Prk_DailyRetailerDetails','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (125,1,'Daily Product Details','Daily Product Details','Cs2Cn_Prk_DailyProductDetails','Cs2Cn_Prk_DailyProductDetails','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (126,1,'Upload Record Check','UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (127,1,'ReUpload Initiate','ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (128,1,'For Integration','ForIntegration','Cs2Cn_Prk_IntegrationHouseKeeping','Cs2Cn_Prk_IntegrationHouseKeeping','','','','Upload','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (201,1,'Hierarchy Level','Hieararchy Level','Cn2Cs_Prk_HierarchyLevel','Cn2Cs_Prk_HierarchyLevel','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (202,1,'Hierarchy Level Value','Hieararchy Level Value','Cn2Cs_Prk_HierarchyLevelValue','Cn2Cs_Prk_HierarchyLevelValue','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (203,1,'Retailer Category Level Value','Retailer Category Level Value','Cn2Cs_Prk_BLRetailerCategoryLevelValue','RetailerCategory','CtgMainId','','','Download','34',34,'34',34,0,'SELECT CtgCode AS [Category Code],CtgName AS [Category Name] FROM RetailerCategory WHERE CtgMainId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (204,1,'Retailer Value Classification','Retailer Value Classification','Cn2Cs_Prk_BLRetailerValueClass','RetailerValueClass','RtrClassId','','','Download','90',90,'90',90,0,'SELECT ValueClassCode AS [Class Code],ValueClassName AS [Class Name] FROM RetailerValueClass WHERE RtrClassId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (205,1,'Prefix Master','Prefix Master','Cn2Cs_Prk_PrefixMaster','Cn2Cs_Prk_PrefixMaster','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (206,1,'Retailer Aproval','Retailer Approval','Cn2Cs_Prk_RetailerApproval','Cn2Cs_Prk_RetailerApproval','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (207,1,'UOM','UOM','Cn2Cs_Prk_BLUOM','UOMMaster','UOMId','','','Download','7',7,'7',7,0,'SELECT UomCode AS [UOM Code],UomDescription AS [UOM Desc] FROM UOMMaster WHERE UomId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (208,1,'Tax Configuration','Tax Configuration','Etl_Prk_TaxConfig_GroupSetting','TaxConfiguration','TaxId','','','Download','1',1,'1',1,0,'SELECT TaxCode AS [Tax Code],TaxName AS [Tax Name] FROM TaxConfiguration WHERE TaxId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (209,1,'Tax Setting','Tax Setting','Etl_Prk_TaxSetting','Etl_Prk_TaxSetting','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (210,1,'Product Hierarchy Change','Product Hierarchy Change','Cn2Cs_Prk_BLProductHiereachyChange','Cn2Cs_Prk_BLProductHiereachyChange','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT BusinessCode AS [Business Code],CategoryCode AS [Category Code] FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag=''Y''')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (211,1,'Product','Product','Cn2Cs_Prk_Product','Product','PrdId','','','Download','633',633,'633',633,0,'SELECT PrdCCode AS [Product Code],PrdName AS [Product Name] FROM Product WHERE PrdId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (212,1,'Product Batch','Product Batch','Cn2Cs_Prk_ProductBatch','ProductBatch','PrdBatId','','','Download','959',959,'959',959,0,'SELECT PrdCCode AS [Product Code],PrdBatCode AS [Batch Code] FROM ProductBatch PB,Product P   WHERE P.PrdId=PB.PrdId AND PrdBatId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (213,1,'Tax Group Mapping','Tax Group Mapping','Etl_Prk_TaxMapping','Etl_Prk_TaxMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT PrdCode AS [Product Code],TaxGroupCode AS [Tax Group Code] FROM Etl_Prk_TaxMapping WHERE DownLoadFlag=''Y''')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (214,1,'Special Rate','Special Rate','Cn2Cs_Prk_SpecialRate','Cn2Cs_Prk_SpecialRate','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT CtgCode AS [Hierarchy],PrdCCode AS [Product Company Code],SpecialSellingRate AS [Special Selling Rate] FROM Cn2Cs_Prk_SpecialRate WHERE DownLoadFlag=''Y''')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (215,1,'Cluster Master','Cluster Master','Cn2Cs_Prk_ClusterMaster','ClusterMaster','ClusterId','','','Download','4',4,'4',4,0,'SELECT ClusterCode AS [Cluster Code],ClusterName AS [Cluster Name] FROM ClusterMaster WHERE ClusterId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (216,1,'Cluster Group','Cluster Group','Cn2Cs_Prk_ClusterGroup','ClusterGroupMaster','ClsGroupId','','','Download','1',1,'1',1,0,'SELECT ClsGroupCode AS [Cluster Group Code],ClsGroupName AS [Cluster Group Name] FROM ClusterGroupMaster WHERE ClsGroupId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (217,1,'Scheme','Scheme Master','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','18',18,'18',18,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (217,2,'Scheme','Scheme Attributes','Etl_Prk_Scheme_OnAttributes','SchemeMaster','SchId','','','Download','18',18,'18',18,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (217,3,'Scheme','Scheme Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','18',18,'18',18,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (217,4,'Scheme','Scheme Slabs','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','18',18,'18',18,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (217,5,'Scheme','Scheme Rule Setting','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','18',18,'18',18,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (217,6,'Scheme','Scheme Free Products','Etl_Prk_Scheme_Free_Multi_Products','SchemeMaster','SchId','','','Download','18',18,'18',18,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (217,7,'Scheme','Scheme Combi Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','18',18,'18',18,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (217,8,'Scheme','Scheme On Another Product','Etl_Prk_Scheme_OnAnotherPrd','SchemeMaster','SchId','','','Download','18',18,'18',18,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (218,1,'Scheme Master Control','Scheme Master Control','Cn2Cs_Prk_NVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],ChangeType AS [Change Type],Description FROM Cn2Cs_Prk_NVSchemeMasterControl WHERE DownLoadFlag=''Y''')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (219,1,'Claim Settlement','Claim Settlement','Cn2Cs_Prk_ClaimSettlementDetails','Cn2Cs_Prk_ClaimSettlementDetails','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (220,1,'Purchase Receipt','Purchase Receipt','Cn2Cs_Prk_BLPurchaseReceipt','ETLTempPurchaseReceipt','CmpInvNo','','DownLoadStatus=0','Download','0',0,'0',0,0,'SELECT CmpInvNo AS [Invoice No],InvDate AS [Invoice Date] FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (221,1,'Purchase Receipt Mapping','Purchase Receipt Mapping','Cn2Cs_Prk_PurchaseReceiptMapping','Cn2Cs_Prk_PurchaseReceiptMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (222,1,'Claim Norm Mapping','Claim Norm Mapping','Cn2Cs_Prk_ClaimNorm','Cn2Cs_Prk_ClaimNorm','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (223,1,'Reason Master','Reason Master','Cn2Cs_Prk_ReasonMaster','ReasonMaster','ReasonId','','','Download','16',16,'16',16,0,'SELECT ReasonCode AS [Reason Code],Description FROM ReasonMaster WHERE ReasonId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (224,1,'Bulletin Board','BulletingBoard','Cn2Cs_Prk_BulletingBoard','Cn2Cs_Prk_BulletingBoard','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (225,1,'ERP Product Mapping','ERP Product Mapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Cn2Cs_Prk_ERPPrdCCodeMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (226,1,'Configuration','Configuration','Cn2Cs_Prk_Configuration','Cn2Cs_Prk_Configuration','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (227,1,'Cluster Assign Approval','Cluster Assign Approval','Cn2Cs_Prk_ClusterAssignApproval','Cn2Cs_Prk_ClusterAssignApproval','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (228,1,'Supplier Master','Supplier Master','Cn2Cs_Prk_SupplierMaster','Supplier','SpmId','','','Download','4',3,'4',3,0,'SELECT SpmCode AS [Supplier Code],SpmName AS [Supplier Name] FROM Supplier WHERE SpmId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (229,1,'UDC Master','UDC Master','Cn2Cs_Prk_UDCMaster','UDCMaster','UdcMasterId','','','Download','0',0,'0',0,0,'SELECT MasterName AS [Master Name],ColumnName AS [Column Name] FROM UDCMaster UM,UDCHd UH WHERE UM.MasterId=UH.MasterId AND UM.UDCMasterId>OldMax')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (230,1,'UDC Details','UDC Details','Cn2Cs_Prk_UDCDetails','Cn2Cs_Prk_UDCDetails','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (231,1,'UDC Defaults','UDC Defaults','Cn2Cs_Prk_UDCDefaults','Cn2Cs_Prk_UDCDefaults','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (232,1,'Retailer Migration','Retailer Migration','Cn2Cs_Prk_RetailerMigration','Cn2Cs_Prk_RetailerMigration','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (233,1,'Point Redemption Rules','Point Redemption Rules','Cn2Cs_Prk_PointsRulesHeader','Cn2Cs_Prk_PointsRulesHeader','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (234,1,'Village Master','Village Master','Cn2Cs_Prk_VillageMaster','Cn2Cs_Prk_VillageMaster','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (235,1,'Scheme Payout','Scheme Payout','Cn2Cs_Prk_SchemePayout','Cn2Cs_Prk_SchemePayout','DownLoadFlag','','','Download','0',0,'0',0,0,'')
INSERT INTO Customupdownloadcount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery]) VALUES (236,1,'ReUpload','ReUpload','Cn2Cs_Prk_ReUpload','Cn2Cs_Prk_ReUpload','DownLoadFlag','','','Download','0',0,'0',0,0,'')
GO
Update Configuration set Condition = 'http://220.226.206.19/PRLLive/' Where ModuleId = 'Datatransfer31'
Update Configuration set Condition = 'http://220.226.206.19/ParleIntegration/POS2Console.asmx' Where ModuleId = 'Datatransfer44'
Update Configuration set Condition = 'http://220.226.206.19/ParleIntegration/Console2POS.asmx' Where ModuleId = 'Datatransfer45'
GO
Delete from Rptgroup Where PId = 'J and J Reports'
Delete from Rptgroup Where GrpCode = 'J and J Reports'
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_Cn2Cs_Product')
DROP PROCEDURE Proc_Cn2Cs_Product
GO
--select * from Cn2Cs_Prk_Product
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
 SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany = 1  
 SELECT @SpmCode=S.SpmCode FROM Supplier S,Company C  
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
 C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,'Active',  
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
UPDATE Configuration Set Status = 0 Where ModuleId IN ('BILALERTMGNT2','BILLQPS2','BILALERTMGNT4','BILALERTMGNT5','BILALERTMGNT6','BILALERTMGNT7','BILLQPS3',
'BCD2','BCD7','BILLRTEDIT1','BILLRTEDIT5','BILLRTEDIT8','BILLRTEDIT12','DISTAXCOLL6','GENCONFIG1','PURCHASERECEIPT11','SALESRTN6','SALESRTN6','SALESRTN7','MARKETRTN6',
'MARKETRTN7','PO4','RET26','RET17','RET18','GENCONFIG16','PRD9','DISTAXCOLL9','SCHCON14','SCHCON16','SCHCON11','BotreeRateForOldBatch','GENCONFIG25','BILLQPS1',
'DATATRANSFER41','BotreeFBM','SCHCON3','RCS1','RCS2','RCS3','RCS4','RCS5','RCS6','DISTAXCOLL7','DISTAXCOLL8','PURCHASERECEIPT26','PURCHASERECEIPT27','RET36','PO34',
'PO35','DAYENDPROCESS1','BILLRTEDIT25','BotreeAutoBatchTransfer','RETREP2','BotreeMultiUser','PRD7','PRD8')
GO
DELETE FROM Configuration WHERE ModuleId In('DBOY1','DBOY2','VANLOAD2','VANLOAD3','BCD3','SALESRTN4','PURCHASERECEIPT1','SCHEMESTNG1','PURCHASERECEIPT9','PURCHASERECEIPT24',
'SCHCON6','SCHCON7','VANLOAD4','VANLOAD7','BAT1','RET8','IRA1','PWDPROTECTION9','RET9','GENCONFIG5','SAMPLE2','SAMPLE3','SCHCON8','DATATRANSFER1','SALVAGE14','SALVAGE18',
'BotreeERPCCode','SAMPLE1','RTNTOCOMPANY6','MARKETRTN1','MARKETRTN14','DAYENDPROCESS4','BCD15','BCD16','CHEQUE1','CHEQUE2','SJN1','SJN2','SJN3','SJN4','PAYMENT1',
'PAYMENT5','PURCHASERECEIPT8','PURCHASERECEIPT10','PURCHASERECEIPT19','GENCONFIG9','GENCONFIG19','SALVAGE16','SALVAGE22','SALVAGE23','SALVAGE24','GENCONFIG22','GENCONFIG24',
'GENCONFIG28','BCD12','BCD13','GENCONFIG7','SALESRTN14','DATATRANSFER16','CHEQUE3','DISTAXCOLL3','DISTAXCOLL4','RET1','RET6','GENCONFIG4','GENCONFIG12','GENCONFIG17',
'GENCONFIG8','GENCONFIG13','GENCONFIG15','GENCONFIG27','SJN5','RET4','BotreePDRate','PURCHASERECEIPT7','TARGETANALYSIS1','TARGETANALYSIS9','BotreePrdBatEff','GEO1',
'PWDPROTECTION10','ROUTE1','GENCONFIG6','GENCONFIG18','STKMGNT6','GENCONFIG14','MARKETRTN8','SALESRTN11','PURCHASERECEIPT12','PRD4','BCD18','PO1','PO13','PWDPROTECTION6',
'PWDPROTECTION8','SCHEMESTNG9','REMINDER1','REMINDER2','REMINDER3','SALVAGE17','REMINDER4','REMINDER5','REMINDER6','REMINDER7','SCHEMESTNG10','SCHEMESTNG12','RET10',
'PURCHASERECEIPT4','BL1','BL2','BL3','RET13','CHEQUE4','CHEQUE5','CHEQUE6','PO15','PO16','PO18','PO21','PO25','PO26','PO28','PO29','PO30','PO31','PO32','PO33',
'CHEQUE7','CHEQUE8','SALVAGE19','SALVAGE21','SALVAGE25','PURCHASERECEIPT6','PURCHASERECEIPT14','BotreeAllowZeroTax','PURCHASERECEIPT15','BotreeVillage','SALVAGE5',
'SALVAGE6','RTNTOCOMPANY3','RTNTOCOMPANY4','MARKETRTN11','BotreeRtrUpload','IRA2','IRA3','PURCHASERECEIPT25','COLL3','COLL4','COLL5','COLL6','COLL11','COLL12','COLL13',
'COLL14','STKMGNT1','STKMGNT8','MARKETRTN4','SALESRTN1','PURCHASERECEIPT5','SALVAGE20','SCHEMESTNG7','SCHEMESTNG8','RET33','BCD1','DATATRANSFER29','RET19','BotreePurchaseClaim',
'JC1','PURCHASERECEIPT17','SAL1','SAL2','RET5','SALVAGE15','RET11','SALESRTN8','IRA4','VANLOAD1','DAYENDPROCESS6','BCD8','DISTAXCOLL1','SCHCON4','DATATRANSFER44',
'DATATRANSFER45','DATATRANSFER46','BILALERTMGNT15','SALESRTN18','SCHCON12','STKMGNT12')
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DBOY1','Delivery Boy','Allow Route Sharing by Delivery Boy',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DBOY2','Delivery Boy','Allow Automatic Route attatchment if no Routes are selected',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('VANLOAD2','VanLoadUnload','Alllow Van To Van Transfer',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('VANLOAD3','VanLoadUnload','Use Month Default Value',1,'',1.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BCD3','BillConfig_Display','Display Retailer based on Coverage Mode in the hotsearch',1,'',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALESRTN4','Sales Return','Allow both addition and reduction',1,'',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT1','Purchase Receipt','Allow Creation of Purchase Receipt only with or without Purchase Order',1,'Allow Addition of More Products',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHEMESTNG1','Schemes OrderSelection','Automatically apply the schemes other than flexi scheme',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT9','Purchase Receipt','Allow selection of UnSaleable quantity for refusal',1,'',0.00,9)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT24','Purchase Receipt','Display the Credit Note option in Purchase receipt screen',1,'',1.00,24)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHCON6','Scheme Master','While budget exceed,allow billing',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHCON7','Scheme Master','Prompt message for budget exceeded schemes',1,'',0.00,7)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('VANLOAD4','VanLoadUnload','Raise a debit Note against Salesman for the Shortage Qty',1,'',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('VANLOAD7','VanLoadUnload','Use Default Option For VanLoading',1,'LastSales',0.00,7)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BAT1','Batch Transfer','Allow Selection of Batches of any Stock Type',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET8','Retailer','Always use default Geography Level as...',1,'City',5.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('IRA1','IRA','Display the Batch Details',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PWDPROTECTION9','Password Protection','Allow the password with all numbers, uppercase letters or lowercase letters',1,'',0.00,9)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET9','Retailer','Always display default Coverage Mode as',1,'1',0.00,9)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG5','General Configuration','Calculation Decimal Digit Value',1,'',2.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SAMPLE2','Sample Maintenance','Use Saleable stock for Sample Issue',1,'0',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SAMPLE3','Sample Maintenance','Create claim for Saleable stock used in Sample Issue',1,'0',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHCON8','Scheme Master','Allow user to define the same slab using combination of products',1,'',0.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DATATRANSFER1','DataTransfer','Automatic check for Internet Connection',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE14','Salvage','Purchase Receipt',1,'Salvage Track',1.00,14)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE18','Salvage','Batch Transfer',1,'Salvage Track',5.00,18)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BotreeERPCCode','BotreeERPCCode','Display ERP Product in HotSearch',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SAMPLE1','Sample Maintenance','Allow Sample Issue without rule setting',1,'0',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RTNTOCOMPANY6','ReturnToCompany','Include Tax on Product Value',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('MARKETRTN1','Market Return','Allow Editing of Selling Rate in the Market Return Screen',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('MARKETRTN14','Market Return','Make reason as mandatory if the Stock Type is',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DAYENDPROCESS4','Day End Process','Perform automatic delivery of pending Bills after                     day(s)',1,'3',1.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BCD15','BillConfig_Display','Enable bill to bill copying option',1,'',0.00,15)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BCD16','BillConfig_Display','Invoke sample issue screen by pressing key combination',1,'',0.00,16)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('CHEQUE1','Cheque Payment','Allow bulk updation of Pending Cheques to Banked',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('CHEQUE2','Cheque Payment','Allow bulk updation of Pending Cheques to Settled',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SJN1','Stock Journal','Allow Creating new Stock Type by pressing Insert Key',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SJN2','Stock Journal','Allow Creating new Product by pressing Insert Key',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SJN3','Stock Journal','Allow Creating new Batches by pressing Insert Key',1,'',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SJN4','Stock Journal','Allow Creating new Reason by pressing Insert Key',1,'',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PAYMENT1','Payment Register','Allow partial payment for an Invoice',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PAYMENT5','Payment Register','Allow creation of new Cheque/DD  by pressing Insert key',1,'',0.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT8','Purchase Receipt','Allow selection of saleable quantity for refusal',1,'',0.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT10','Purchase Receipt','Allow saving of Purchase Receipt even if there is a rate difference',1,'',0.00,10)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT19','Purchase Receipt','Allow Editing of Gross Amount in Purchase Receipt Screen',1,'',0.00,19)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG9','General Configuration','Display Batch automatically when single batch is available in the attached screens',1,'Purchase',0.00,9)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG19','General Configuration','Include Scheme Claims in  Claim Top Sheet',1,'0',0.00,19)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE16','Salvage','Stock Management',1,'Salvage Track',3.00,16)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE22','Salvage','Salvage',1,'Salvage Track',9.00,22)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE23','Salvage','Return to Company',1,'Salvage Track',10.00,23)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE24','Salvage','Return and Replacement',1,'Salvage Track',11.00,24)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG22','General Configuration','Display Quantity in UOM based',1,'0',0.00,22)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG24','General Configuration','Treat Supplier Tax Group as Manadatory',1,'0',0.00,24)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG28','General Configuration','Show Dash Board',1,'',3.00,28)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BCD12','BillConfig_Display','Display all the Debit Notes while pressing the Debit Note adjustment button',1,'',0.00,12)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BCD13','BillConfig_Display','Display all the Credit Notes while pressing the Credit Note adjustment button',1,'',0.00,13)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG7','General Configuration','0.50',1,'4',0.00,7)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALESRTN14','Sales Return','Make reason as mandatory if the Stock Type is',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DATATRANSFER16','DataTransfer','Zip the file while sending HTTP',1,'',0.00,16)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('CHEQUE3','Cheque Payment','Allow bulk updation of Pending Cheques to Bounced',1,'',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DISTAXCOLL3','Discount & Tax Collection','Calculate Tax in Line Level',1,'LEVEL',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DISTAXCOLL4','Discount & Tax Collection','Post Vouchers on Delivery date',1,'1',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET1','Retailer','Make TIN Number as Mandatory if Tax Type is VAT',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET6','Retailer','Make Expiry date as Mandatory if Pesticide Licence Number is entered',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG4','General Configuration','Connect to Website:',1,'www.botree.co.in',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG12','General Configuration','Display default Company,Supplier and Location',1,'',0.00,12)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG17','General Configuration','Enable Advanced Search Option',1,'0',0.00,17)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG8','General Configuration','Nearest',1,'0',1.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG13','General Configuration','Currency',1,'Rupees',0.00,13)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG15','General Configuration','Currency Display Format',1,'0',0.00,15)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG27','General Configuration','Enable Database restoration check',1,'',0.00,27)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SJN5','Stock Journal','Create Reason as Mantatory',1,'0',0.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET4','Retailer','Make Expiry date as Mandatory if Licence Number is entered',1,'',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BotreePDRate','BotreePDRate','Show PD Rate in Special Rate Module',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT7','Purchase Receipt','Allow Refuse Sale in Purchase',1,'',0.00,7)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('TARGETANALYSIS1','Target Analysis','Automatic',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('TARGETANALYSIS9','Target Analysis','Target Split',1,'',0.00,9)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BotreePrdBatEff','Botree PrdBat Download','Botree Product Batch based on Effective Date',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GEO1','Geography','Display population in the grid',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PWDPROTECTION10','Password Protection','Allow using repeating character (aa11)',1,'',0.00,10)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('ROUTE1','Route Master','Always use default geography level as ...',1,'City',5.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG6','General Configuration','Screen Color',1,'Stocky Default',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG18','General Configuration','Show HotSearch in Standard Width',1,'0',0.00,18)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('STKMGNT6','Stock Management','Make the reason as mandatory if the stock type is :',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('GENCONFIG14','General Configuration','Coin',1,'Paise',0.00,14)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('MARKETRTN8','Market Return','Add the difference amount to S R Rate Difference Claim',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALESRTN11','Sales Return','Add the difference amount to Gross Profit',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT12','Purchase Receipt','Use Distributor Product Code for reference in Purchase Receipt',1,'',0.00,12)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PRD4','Product Master','Allow same EAN code for multiple products',1,'',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BCD18','BillConfig_Display','Display total saleable quantity in product hotsearch',1,'',0.00,18)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO1','Purchase Order','Auto generates purchase order qty based on norm settings by populating all products automatically based on product sequencing screen settings',1,'0',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO13','Purchase Order','Use Company Product Code for reference in Purchase Order Screen',1,'',0.00,13)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PWDPROTECTION6','Password Protection','Allow special characters (%#$@^) in password field',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PWDPROTECTION8','Password Protection','Allow keyboard sequence (asdf) and sequential numbers (123)',1,'',0.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHEMESTNG9','Schemes OrderSelection','Allow Creation of new Retailers by pressing Insert Key',1,'',0.00,9)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('REMINDER1','Reminder','From Time(HH:MM)',1,'09',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('REMINDER2','Reminder','From Time(HH:MM)',1,'00',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('REMINDER3','Reminder','ToTime(HH:MM))',1,'09',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE17','Salvage','Stock Journal',1,'Salvage Track',4.00,17)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('REMINDER4','Reminder','From Time(HH:MM)',1,'00',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('REMINDER5','Reminder','Set the duration between times(MM)',1,'30',0.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('REMINDER6','Reminder','From Time(HH:MM)',1,'0',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('REMINDER7','Reminder','ToTime(HH:MM)',1,'1',0.00,7)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHEMESTNG10','Schemes OrderSelection','Allow Creation of new Shipping Address by pressing Insert Key',1,'',0.00,10)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHEMESTNG12','Schemes OrderSelection','Display all Window Dispaly Schemes by pressing Insert Key',1,'',0.00,12)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET10','Retailer','Always display default Retailer Day Off as',1,'0',0.00,10)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT4','Purchase Receipt','Allow Creation of new Product by Pressing Insert Key',1,'',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BL1','BL Configuration','',1,'Automatically create price batches based on selling rate received from Console',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BL2','BL Configuration','',1,'Automatically create contract price entry based on new price batch creation',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BL3','BL Configuration','',1,'Perform Cheque Bounce based on data received from Console',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET13','Retailer','Always display default Coverage Frequency as',1,'0',0.00,13)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('CHEQUE4','Cheque Payment','Allow bulk updation of Banked Cheques to Settled',1,'',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('CHEQUE5','Cheque Payment','Allow bulk updation of Banked Cheques to Bounced',1,'',0.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('CHEQUE6','Cheque Payment','Alert Regarding CDC Cheques at the time of Logging out',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO15','Purchase Order','Allow Entering quantity break up against(+)',1,'1',0.00,15)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO16','Purchase Order','Download Suggested PO From Console',1,'',0.00,16)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO18','Purchase Order','Enable only addition of quantity',1,'',0.00,18)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO21','Purchase Order','Do not display alert on pending POs',1,'',0.00,21)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO25','Purchase Order','While Logging Out',1,'',0.00,25)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO26','Purchase Order','While Logging In',1,'',0.00,26)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO28','Purchase Order','Auto Convert at Log Out',1,'',0.00,28)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO29','Purchase Order','Allow Editing of auto generated quantity',1,'',0.00,29)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO30','Purchase Order','Alert the user to confirm && Upload open PO',1,'5',0.00,30)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO31','Purchase Order','Enable PO Confirmation based on user selection',1,'',0.00,31)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO32','Purchase Order','Automatically confirm all the pending POs on the due date',1,'',0.00,32)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PO33','Purchase Order','Does not allow transaction if PO is not confirmed after due date',1,'',0.00,33)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('CHEQUE7','Cheque Payment','Alert Regarding CDC Cheques at the time of Logging in',1,'',0.00,7)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('CHEQUE8','Cheque Payment','Enable Re- Presenting of Bounced Cheque',1,'',10.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE19','Salvage','Location Transfer',1,'Salvage Track',6.00,19)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE21','Salvage','Resell Damage Goods',1,'Salvage Track',8.00,21)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE25','Salvage','Sample Receipt',1,'Salvage Track',12.00,25)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT6','Purchase Receipt','Include provision for entering handling charges in Purchase Receipt',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT14','Purchase Receipt','Allow Duplicate Rows',1,'',0.00,14)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BotreeAllowZeroTax','BotreeAllowZeroTax','Allow 0% Tax in Reports',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT15','Purchase Receipt','Enable Sample Receipt option through Purchase Receipt Screen',1,'',0.00,15)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BotreeVillage','Botree Village','Treat Company Village Code as Village Code',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE5','Salvage','Make Reason as mandatory if the Stock Type is :',1,'',0.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE6','Salvage','Allow editing of Claim Amount field',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RTNTOCOMPANY3','ReturnToCompany','Make the reason Mandatory of the stock Type is >',1,'',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RTNTOCOMPANY4','ReturnToCompany','Allow Editing of Claim Amount Field',1,'',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('MARKETRTN11','Market Return','Add the difference amount to Gross Profit',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BotreeRtrUpload','BotreeRtrUpload','Daily Retailer Upload',1,'',1.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('IRA2','IRA','Perform Stock Addition Automatically',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('IRA3','IRA','Perform Stock Out Automatically',1,'',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT25','Purchase Receipt','Display the Debit Note option in Purchase receipt screen',1,'',1.00,25)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('COLL3','Collection Register','Delivery Route Based on',1,'1',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('COLL4','Collection Register','Sales Route Based on',1,'2',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('COLL5','Collection Register','Retailer Based on',1,'3',0.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('COLL6','Collection Register','Collected By',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('COLL11','Collection Register','Bank',1,'',0.00,11)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('COLL12','Collection Register','Branch',1,'',0.00,12)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('COLL13','Collection Register','ExcessCollection',1,'1',0.00,14)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('COLL14','Collection Register','Perform Account Posting for Cheques',1,'0',0.00,14)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('STKMGNT1','Stock Management','Manual Selection for Batches',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('STKMGNT8','Stock Management','Allow Creating new Location by pressing Insert Key',1,'',0.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('MARKETRTN4','Market Return','Allow both addition and reduction',1,'',0.00,3)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALESRTN1','Sales Return','Allow Editing of Selling Rates in the Sales Return Screen  When no Bill Reference is Selected',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT5','Purchase Receipt','Allow Creation of new Batch by Pressing Insert Key',1,'',0.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE20','Salvage','Sales Return',1,'Salvage Track',7.00,20)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHEMESTNG7','Schemes OrderSelection','Popup the reason for non billing while changing the route or closing the billing screen',1,'',0.00,7)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHEMESTNG8','Schemes OrderSelection','Set the default reason as',1,'1',0.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET33','Retailer','Display Company Retailer Code',1,'',0.00,33)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BCD1','BillConfig_Display','Enable automatic Popup of Salesman and Route in the Bill Tag',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DATATRANSFER29','DataTransfer','Allow Automatic Deployment',1,'',0.00,29)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET19','Retailer','Treat Retailer TaxGroup as Mandatory',1,'',0.00,19)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BotreePurchaseClaim','BotreePurchaseClaim','Check for Claim Settlement on Purchase',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('JC1','JC Calendar','Populate dates automatically based on the first entry',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('PURCHASERECEIPT17','Purchase Receipt','Automatically display the default supplier while downloading purchase',1,'',0.00,17)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SAL1','Salesman','Allow Route Sharing By Salesman',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SAL2','Salesman','Allow Automatic Route Attachment if no routes are selected',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET5','Retailer','Make Expiry date as Mandatory if Drug Licence Number is entered',1,'',0.00,5)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALVAGE15','Salvage','Purchase Return',1,'Salvage Track',2.00,15)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('RET11','Retailer','Set the default Retailer Status as while adding a new retailer',1,'1',0.00,11)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALESRTN8','Sales Return','Add the difference amount to S R Rate Difference Claim',1,'',0.00,2)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('IRA4','IRA','Variance Price',1,'',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('VANLOAD1','VanLoadUnload','Follow FIFO for Automatic Van Load',1,'FIFO',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DAYENDPROCESS6','Day End Process','Allow Automatic Delivery',1,'',0.00,6)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BCD8','BillConfig_Display','Fill Batches automatically based on',1,'FIFO',0.00,8)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DISTAXCOLL1','Discount & Tax Collection','Allow Editing of Cash Discount in the billing screen',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHCON4','Scheme Master','Allow user to create',1,'0',0.00,4)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DATATRANSFER44','DataTransfer','Upload Path',1,'http://220.226.206.19/ParleIntegration/POS2Console.asmx',0.00,44)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DATATRANSFER45','DataTransfer','Download Path',1,'http://220.226.206.19/ParleIntegration/Console2POS.asmx',0.00,45)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('DATATRANSFER46','DataTransfer','Sync Check Path',1,'',0.00,46)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('BILALERTMGNT15','Alert Management','Apply Alert Management Configurations for Order Booking also',1,'0',0.00,15)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SALESRTN18','Sales Return','Based on Slab Applied',1,'',0.00,1)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('SCHCON12','Scheme Master','Enable Retailer Cluster in Scheme Master',1,'',0.00,12)
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) VALUES ('STKMGNT12','Stock Management','Enable selection of transaction type at grid level',1,'',0.00,12)
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL1_BILLTEMPLATE'
CREATE PROCEDURE Proc_RptBillTemplateFinal
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
		if len(@FieldTypeList) > 3000
		begin
			Set @FieldTypeList2 = @FieldTypeList
			Set @FieldTypeList = ''
		end
		--->Added By Nanda on 12/03/2010
		IF LEN(@FieldList)>3000
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
	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
	End
	------------------------------ Other
	Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
	End
	---------------------------------------Replacement
	Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
	End
	----------------------------------Credit Debit Adjus
	Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
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
	End
	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
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
	End
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
			[UsrId],[Visibility],[AmtInWrd]
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
		[UsrId],[Visibility],[AmtInWrd]
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
		[UsrId],[Visibility],[AmtInWrd]
		FROM RptBillTemplateFinal_Group,Product P
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5
	END	
	--->Till Here
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
Delete From HotSearchEditorHd Where FormId=10051
Insert Into HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString)
Select 10051,'Sales Return','DocRefNo','Select','SELECT R.RtrId,Srno,RtrCode,RtrName,SMID,SMName,RM.RMID,RMNAME FROM PDA_SalesReturn  
PD (NOLOCK)  INNER JOIN Retailer R (NOLOCK) ON R.Rtrid=Pd.Rtrid INNER JOIN RetailerMarket RTM (NOLOCK) ON RTM.RMID=PD.MktId AND RTM.Rtrid=R.Rtrid 
INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=RTM.RMID and RM.RMID=PD.MktId INNER JOIN SalesMan SM (NOLOCK) ON SM.SMID=PD.SrpID WHERE PD.Status=0'
GO
Delete From HotSearchEditorDT Where FormId=10051
Insert Into HotSearchEditorDT
Select 1,10051,'Doc Reference No','Reference No','Srno',4500,0,'HotSch-3-2000-36',3 Union All
Select 2,10051,'Retailer Code','Retailer Code','RtrCode',4500,0,'HotSch-3-2000-37',3 Union All
Select 3,10051,'Retailer Name','Retailer Name','RtrName',4500,0,'HotSch-3-2000-38',3
GO
Delete From hotsearcheditorHd Where Formid = 171
INSERT INTO hotsearcheditorhd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (171,'Scheme Master','PrdName','select',
'SELECT PrdDCode,PrdCCode,PrdName,PrdShrtName,PrdSeqDtId,PrdId,chkdup FROM (SELECT D.PrdSeqDtId,  A.PrdDcode,A.prdCcode,A.PrdName,A.PrdShrtName,A.PrdId,A.prdid as chkdup   
FROM Product A   WITH (NOLOCK),ProductSequence C  WITH (NOLOCK),  ProductSeqDetails D   WHERE C.TransactionId= vFParam  AND A.PrdStatus = 1 AND C.PrdSeqId = D.PrdSeqId   And a.PrdId = D.PrdId   and A.CmpId = vSParam  and prdtype NOT IN (4)   UNION   SELECT  100000 AS PrdSeqDtId,A.PrdDcode,  A.PrdCcode,A.PrdName,PrdShrtName,A.PrdId,a.prdid as chkdup   FROM  Product A WITH (NOLOCK)   WHERE A.PrdStatus = 1   and prdtype NOT IN (4) and A.CmpId = vSParam   and A.PrdId NOT  IN (   SELECT PrdId FROM   ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK)       WHERE B.TransactionId= vFParam AND prdid in  (Select prdid from product Where  CmpId = vSParam     and prdtype NOT IN (4)) and  B.PrdSeqId=C.PrdSeqId) ) MainSql ORDER BY PrdSeqDtId ASC')
GO
Delete From hotsearcheditordt Where Formid = 171
INSERT INTO hotsearcheditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,171,'PrdName','Dist Code','PrdDCode',500,0,'HotSch-45-2000-21',45)
INSERT INTO hotsearcheditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,171,'PrdName','Comp Code','PrdCCode',800,0,'HotSch-45-2000-22',45)
INSERT INTO hotsearcheditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,171,'PrdName','Name','PrdName',800,0,'HotSch-45-2000-23',45)
INSERT INTO hotsearcheditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,171,'PrdName','Short Name','PrdShrtName',1500,0,'HotSch-45-2000-37',45)
INSERT INTO hotsearcheditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (5,171,'PrdName','Sequence Id','PrdSeqDtId',1500,0,'HotSch-45-2000-38',45)
GO
IF EXISTS (Select * From Sysobjects Where XTYPE = 'P' And name = 'Proc_RptCollectionFormatLS')
DROP PROCEDURE Proc_RptCollectionFormatLS
GO
CREATE PROCEDURE Proc_RptCollectionFormatLS
(
	@Pi_RptId 			INT,
	@Pi_FromDate		DateTime,
	@Pi_ToDate			DateTime,
	@Pi_VehicleId		INT,
	@Pi_VehicleAllocId	INT,
	@Pi_SMId			INT,
	@Pi_@DlvRouteId     INT,
	@Pi_RtrId			INT,
	@Pi_UsrId 			INT
)
/*******************************************************************************
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}
* 26.02.2010	Panneer		 Added Date and Vehicle Filter
*********************************************************************************/
AS
SET NOCOUNT ON
BEGIN	
	DELETE FROM RtrLoadSheetCollectionFormat WHERE UsrId IN (@Pi_UsrId,0)
	INSERT INTO RtrLoadSheetCollectionFormat
	SELECT X.* ,V.allotmentid,@Pi_RptId RptId,@Pi_UsrId UsrId
	FROM
	(
		SELECT SI.SalId,SI.SalInvNo,SI.SalInvDate,SI.DlvRMId,SI.VehicleId,
		SI.SMId,SI.RtrId,R.RtrName,SI.salnetamt,(SI.salnetamt-SI.salpayamt) OutstandAmt
		FROM SalesInvoice SI
		LEFT OUTER JOIN Retailer R on SI.RtrId = R.RtrId
		WHERE SI.DlvSts IN (2,4,5)
		AND  (VehicleId = (CASE @Pi_VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )		
		AND (SMId=(CASE @Pi_SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
		AND (DlvRMId=(CASE @Pi_@DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		
		AND (SI.RtrId = (CASE @Pi_RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
					SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
					
		AND [SalInvDate] Between @Pi_FromDate and @Pi_ToDate  AND BillMode = 2 AND DlvSts <> 5	
	) X
	INNER JOIN
	(SELECT VM.AllotmentId,VM.AllotmentNumber,VM.VehicleId,SaleInvNo FROM VehicleAllocationMaster VM,
	VehicleAllocationDetails VD
	WHERE VM.AllotmentNumber = VD.AllotmentNumber) V
	ON X.VehicleId  = V.VehicleId and X.SalInvNo = V.SaleInvNo
END
GO
DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG7'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('GENCONFIG7','General Configuration','1.00',1,5,'0.00',7)
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 398)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(398,'D','2012-01-19',getdate(),1,'Core Stocky Service Pack 398')
GO