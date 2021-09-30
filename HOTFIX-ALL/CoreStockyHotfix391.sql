--[Stocky HotFix Version]=391
Delete from Versioncontrol where Hotfixid='391'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('391','2.0.0.5','D','2011-10-03','2011-10-03','2011-10-03',convert(varchar(11),getdate()),'Major: Product Release')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 391' ,'391'
GO
DELETE FROM RptExcelHeaders WHERE RptExcelHeaders.RptId=215
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,1,'Date','Date',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,2,'NoOfPrimInv','NoOfPrimInv',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,3,'NoOfProdinvoice','NoOfProdinvoice',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,4,'TotInvoiceQty','TotInvoiceQty',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,5,'TotRecvQty','TotRecvQty',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,6,'NoOfGrnInv','NoOfGrnInv',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,7,'NoOfSalInv','NoOfSalInv',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,8,'NoofOLInv','NoofOLInv',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,9,'NoOfProdSold','NoOfProdSold',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,10,'TotSalQty','TotSalQty',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,11,'TotSalInvVal','TotSalInvVal',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,12,'TotNoLines','TotNoLines',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,13,'AvgNoofBill','AvgNoofBill',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,14,'AvgLinesPerCall','AvgLinesPerCall',1,1)

INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES (215,15,'UsrId','UsrId',1,1)
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptSummaryDet_Excel')
DROP TABLE RptSummaryDet_Excel
GO
CREATE TABLE [dbo].[RptSummaryDet_Excel](
	[Date] [datetime] NULL,
	[NoOfPrimInv] [int] NULL,
	[NoOfProdinvoice] [int] NULL,
	[TotInvoiceQty] [int] NULL,
	[TotRecvQty] [int] NULL,
	[NoOfGrnInv] [int] NULL,
	[NoOfSalInv] [int] NULL,
	[NoofOLInv] [int] NULL,
	[NoOfProdSold] [int] NULL,
	[TotSalQty] [int] NULL,
	[TotSalInvVal] [numeric](38, 6) NULL,
	[TotNoLines] [int] NULL,
	[AvgNoofBill] [numeric](38, 6) NULL,
	[AvgLinesPerCall] [numeric](38, 6) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptSummarryDetail')
DROP PROCEDURE Proc_RptSummarryDetail 
GO
CREATE PROCEDURE [dbo].[Proc_RptSummarryDetail]
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
* Procedure Name : Proc_RptSummarryDetail
* CREATED BY	 : Panneerselvam.K
* CREATED DATE	 : 16.07.2010 
* NOTE		     : Report Purpose
------------------------------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}
******************************************************************************************************/
BEGIN
SET NOCOUNT ON
--Filter Variable
DECLARE @FromDate	DATETIME
DECLARE @ToDate	 	DATETIME
DECLARE @StDate		DATETIME
DECLARE @EndDate	DATETIME
--Assgin Value for the Filter Variable
SET @FromDate =(SELECT   TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate   = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
CREATE TABLE #TempRptSummaryDet( Date DateTime,NoOfPrimInv INT,NoOfProdinvoice INT,TotInvoiceQty INT,
							TotRecvQty INT,NoOfGrnInv INT,NoOfSalInv INT,NoofOLInv INT,
							NoOfProdSold INT,TotSalQty INT,TotSalInvVal Numeric(38,6),TotNoLines INT,
							AvgNoofBill Numeric(38,6),AvgLinesPerCall Numeric(38,6),UsrId INT)
SET @StDate = @FromDate
SET @EndDate = @ToDate
	DELETE FROM RptSummaryDet WHere UsrId = @Pi_UsrId
	DELETE FROM #TempRptSummaryDet
	WHILE @EndDate >= @StDate
	BEGIN
		INSERT INTO RptSummaryDet
		SELECT @StDate,0,0,0,0,0,0,0,0,0,0.00,0,0.00,0.00,@Pi_UsrId
		SET @StDate = DateAdd(Day,1,@StDate)
	END
	INSERT INTO #TempRptSummaryDet
	SELECT 
			SalInvDate,0,0,0,0,0,
			Count(Distinct A.SalId) NoOfSalInv,Count(Distinct RtrId) NoofOLInv,
			Count(Distinct PrdId) NoOfProdSold,Sum(BaseQty) TotSalQty,
			Sum(PrdGrossAmount)TotSalInvVal,Count(PrdId) TotNoLines,
			0.00 AvgNoofBill,
		    0.00 AvgLinesPerCall,@Pi_UsrId
	FROM 
			SalesInvoice A,SalesInvoiceProduct B
	WHERE 
			A.SalId = B.SalId AND Dlvsts > 3
			AND SalInvDate Between @FromDate and @ToDate
	GROUP By SalInvDate 
	Update RptSummaryDet SET 
			NoOfSalInv	 = B.NoOfSalInv,	NoofOLInv   =  B.NoofOLInv,
			NoOfProdSold = B.NoOfProdSold,	TotSalQty	=  B.TotSalQty,
			TotSalInvVal = B.TotSalInvVal,  TotNoLines  =  B.TotNoLines ,
			AvgNoofBill  = 0.00,   AvgLinesPerCall = 0.00
	From   RptSummaryDet A,#TempRptSummaryDet B
	WHERE  A.Date = B.Date  AND A.UsrId = B.UsrId 
			/* Calculate No GRN  */
	SELECT GoodsRcvdDate,Count(PurRcptId) NoGRN,@Pi_UsrId UsrId INTO #TmpPR001
	FROM PurchaseReceipt WHERE GoodsRcvdDate Between @FromDate AND @ToDate AND Status=1
	GROUP BY GoodsRcvdDate
	Update RptSummaryDet SET NoOfGrnInv = NoGRN
	From RptSummaryDet a,#TmpPR001 b
	WHERE Date = GoodsRcvdDate and GoodsRcvdDate Between @FromDate AND @ToDate AND A.UsrId = B.UsrId 
			/* Calculate No Invoice  */
	SELECT InvDate,Count(PurRcptId) NoInv, @Pi_UsrId UsrId INTO #TmpPR002
	FROM PurchaseReceipt WHERE InvDate Between @FromDate AND @ToDate AND Status=1
	GROUP BY InvDate
	Update RptSummaryDet SET NoOfPrimInv = NoInv
	From RptSummaryDet a,#TmpPR002 b
	WHERE Date = InvDate and InvDate Between @FromDate AND @ToDate  AND A.UsrId = B.UsrId 
		
			/* Calcualte No Of Product Invoice and Total invoice Qty */
	SELECT	InvDate,Count(DISTINCT PrdId) NoInvProd,SUM(InvBaseQty) NoOfInvQty,
			Sum(RcvdGoodBaseQty) NoOfRecvQty ,@Pi_UsrId UsrId  INTO #TmpPR003
	FROM PurchaseReceipt A,PurchaseReceiptProduct B
	WHERE InvDate Between @FromDate AND @ToDate AND Status=1
		  AND A.PurRcptId = B.PurRcptId
	GROUP BY InvDate
	Update RptSummaryDet SET NoOfProdinvoice = NoInvProd,
							 TotInvoiceQty = NoOfInvQty,TotRecvQty = NoOfRecvQty
	From RptSummaryDet a,#TmpPR003 b
	WHERE Date = InvDate and InvDate Between @FromDate AND @ToDate  AND A.UsrId = B.UsrId 
		/* Update Avg No of Bill AND Avg No of Per Call */
	Update RptSummaryDet SET  
		AvgNoOfBill = ISNULL( Nullif(Cast(TotNoLines  As Numeric(18,6)),0)
								/ Nullif(Cast(NoOfSalInv  As Numeric(18,6)),0),0)  ,
		AvgLinesPerCall = ISNULL( Nullif(Cast(TotNoLines  As Numeric(18,6)),0)
								/ Nullif(Cast(NoOfOLInv  As Numeric(18,6)),0),0) 
								
	SELECT * FROM RptSummaryDet ---Where (NoOfPrimInv > 0 or NoOfGrnInv > 0 Or TotSalInvVal > 0 )
	Order BY Date

	INSERT INTO [RptSummaryDet_Excel]
				(Date,
				NoOfPrimInv,
				NoOfProdinvoice,
				TotInvoiceQty,
				TotRecvQty,
				NoOfGrnInv,
				NoOfSalInv,
				NoofOLInv,
				NoOfProdSold,
				TotSalQty,
				TotSalInvVal,
				TotNoLines,
				AvgNoofBill,
				AvgLinesPerCall,
				UsrId)
	SELECT Date,NoOfPrimInv,NoOfProdinvoice,TotInvoiceQty,TotRecvQty,NoOfGrnInv,NoOfSalInv,NoofOLInv,NoOfProdSold,
	TotSalQty,TotSalInvVal,TotNoLines,AvgNoofBill,AvgLinesPerCall,UsrId FROM RptSummaryDet
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AutoDBCDCreation')
DROP PROCEDURE Proc_AutoDBCDCreation
GO
/*
BEGIN TRANSACTION
exec Proc_AutoDBCDCreation 'a','2011-09-05'
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_AutoDBCDCreation
(
	@Pi_RefNo		nVarchar(10),
	@Pi_TransDate   DATETIME 
)
AS

SET NOCOUNT ON
BEGIN

	DECLARE @Slabid AS int 
	DECLARE @CreditPeriod AS int 
	DECLARE @Discount AS numeric(18,6)
	DECLARE @salinvno AS varchar(50)
	DECLARE @salid AS int 
	DECLARE @SalCDPer AS numeric(18,6)
	DECLARE @CashDis AS numeric(18,6)
	DECLARE @DiffAmt AS numeric(18,6)
	DECLARE @CollectionAmt AS  numeric(18,6)
	DECLARE @CashDis1 AS numeric(18,6)
	DECLARE @Rtrid AS int
	DECLARE @DateDiff AS Int
	DECLARE @DebitCreditNo AS nvarchar(100)
	DECLARE @CrDbNoteDate AS DATETIME
	DECLARE @AccCoaId	AS INT
	DECLARE @DBCRRtrID AS Int 
	DECLARE @CRDBName AS nVarchar(20)
	DECLARE @CRDBSalid AS BigInt
	DECLARE @DBCRCollectionAmt numeric(28,6)
	DECLARE @DBCDRtrCode AS nVarchar(20)
	DECLARE @DBCDRtrName AS nVarchar(200)
	DECLARE @DBCDSalInvNo AS nVarchar(100)
	DECLARE @DBCDSalInvDate AS datetime 
	DECLARE @FindReasoId AS INT
	DECLARE @TobeCalAmt numeric(28,6)
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS Int 
	DECLARE @Slno AS INT
	DECLARE @Row AS INT 
	DECLARE @DiffIntAmt AS numeric(28,6)
	DECLARE @MaxTaxPerc AS numeric(15,6)
	DECLARE @MaxCRDVBPerc AS numeric(15,6)
	DECLARE @ErrStatus			INT
	DECLARE @FStatus AS INT
	DECLARE @MAxCreditPeriod AS INT
	DECLARE @MaxSlabid AS INT
	DECLARE @FFromDate AS datetime 	

-- To be commented
	TRUNCATE TABLE  RaiseCreditDebit
	TRUNCATE TABLE AutoRaisedCreditDebit
-- end here
	SET @DiffIntAmt=0
	SET @MaxTaxPerc=0

	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='DBCRNOTE15' AND Status=1)
		BEGIN 
			 SET @FStatus=1
		END 
    ELSE
		BEGIN 
			SET @FStatus=0
		END 

	SET @ErrStatus=1

	SELECT @FFromDate=FixedOn FROM HotFixLog WHERE FixId=387
	
	DECLARE cur_CreditSlab CURSOR
	FOR SELECT Slabid,CreditPeriod,Discount FROM AutoDbCrSlabConfig ORDER BY slabid
	OPEN cur_CreditSlab
	FETCH next FROM cur_CreditSlab INTO @Slabid,@CreditPeriod,@Discount
	WHILE @@Fetch_status=0
	BEGIN 
		SET @DiffIntAmt=0
		SET @MaxTaxPerc=0
		DECLARE cur_Salinvno CURSOR
		FOR SELECT salinvno,SalId,PrdId,PrdBatId,Slno,SalCDPer,(sum(ActPrdGross)-sum(OrgGrossAmt))DiffAmt,isnull(sum(OrgGrossAmt),0)CollectionAmt,Rtrid
			FROM (
				SELECT DISTINCT SIP.Slno,SIP.PrdId,sip.Prdbatid,salinvno,SI.SalId,SalCDPer,si.SalGrossAmount,A.SalInvAmt CollectionAmt,
					sum((PrdGrossAmount - ISnull(PrdGrossAmt,0))*(isnull(A.SalInvAmt,0)/(SalNetAmt))) OrgGrossAmt,SI.RtrId,sum(PrdGrossAmount) ActPrdGross
				FROM salesinvoice SI INNER JOIN salesinvoiceproduct SIP ON SI.salid=SIP.salid 
				LEFT OUTER JOIN (SELECT SalId,sum(SalInvAmt)SalInvAmt FROM ReceiptInvoice RI INNER JOIN Receipt R ON R.InvRcpNo=RI.InvRcpNo
			    WHERE datediff(day,RI.SalInvDate,R.InvRcpDate)<=@CreditPeriod 
			    GROUP BY SalId)A ON A.salid=SI.salid AND A.salid=SIP.SalId
			    LEFT OUTER JOIN (SELECT RH.Salid,RP.PrdId,Rp.PrdBatId,sum(PrdGrossAmt) PrdGrossAmt FROM ReturnHeader RH INNER JOIN ReturnProduct RP ON RH.returnid=RP.ReturnId
					GROUP BY RH.Salid,RP.PrdId,Rp.PrdBatId) B ON B.SalId=SI.SalId AND B.PrdId=SIP.PrdId AND B.PrdBatId=SIP.PrdBatId
			    WHERE DlvSts>=4  AND AutoDBCD=0 AND SalInvDate>=CONVERT(NVARCHAR(10),@FFromDate,121) --AND SI.SalId=6
			    GROUP BY SIP.Slno,SIP.PrdId,sip.Prdbatid,SI.SalId,SI.RtrId,SalCDPer,SalInvNo,si.SalGrossAmount,A.SalInvAmt,Rtrid)A
			    GROUP BY salinvno,SalId,PrdId,PrdBatId,Slno,SalCDPer,Rtrid
		OPEN cur_Salinvno
		FETCH next FROM cur_Salinvno INTO @salinvno,@salid,@PrdId,@PrdBatId,@Row,@SalCDPer,@DiffAmt,@CollectionAmt,@Rtrid
		WHILE @@Fetch_status=0
		BEGIN 
		SET @DiffIntAmt=0
		SET @MaxTaxPerc=0
		SELECT @DateDiff=datediff(day,Si.SalInvDate,isnull(InvRcpDate,getdate())) FROM Salesinvoice SI 
			LEFT OUTER JOIN (SELECT SalId,max(InvRcpDate) InvRcpDate FROM ReceiptInvoice RI INNER JOIN Receipt R ON R.InvRcpNo=RI.InvRcpNo GROUP BY SalId) B
			ON SI.SalId=B.SalId
			WHERE SI.SalId=@SalId
	   
		--SELECT @DateDiff,@CreditPeriod,@DiffAmt
		IF NOT EXISTS (SELECT * FROM AutoDBCDPrdSlabAchieved WHERE SalId=@salid AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND SlabId=@Slabid)
			BEGIN 
				IF @DateDiff>@CreditPeriod AND @DiffAmt>0
					BEGIN 
						INSERT INTO AutoDBCDPrdSlabAchieved
							SELECT @salid,@PrdId,@PrdBatId,@Slabid,@DiffAmt,@CollectionAmt

						IF 	@Slabid=1 
							BEGIN 		
								SELECT @CashDis=SalCDPer FROM salesinvoice WHERE SalId=@salid     
							END 
						ELSE 
							BEGIN
								SET @CashDis=0
							END 
						IF @CashDis=0
							BEGIN 
								IF exists (SELECT  * FROM salesinvoice WHERE SalCDPer>0 AND SalId=@salid)
									BEGIN 
										SET @CashDis1=@Discount-@CashDis

										SET @TobeCalAmt= ((@DiffAmt*@CashDis1)/100) 	

										--SELECT 'a',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
										IF @TobeCalAmt>=5
										BEGIN 
											IF @FStatus=1
												BEGIN 
													EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid							
													
													SELECT @DiffIntAmt= sum(TaxAmount) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													SELECT @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
												END
										END  
										INSERT INTO RaiseCreditDebit
										SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
									END 
								ELSE
									BEGIN 
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														--SELECT 'b1',@DiffAmt,@CashDis,@Row
														--SELECT 'b',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																	BEGIN
																		EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																		
																		SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																		SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
										ELSE
											BEGIN 
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid
												SET @CashDis=@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																BEGIN
																	EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																	
																	SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END
											END 
									END 
							END
						ELSE
							BEGIN 
								IF @CashDis-@Discount=0 
									BEGIN 
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1

												SET @TobeCalAmt= ((@DiffAmt*@CashDis)/100)
												--SELECT 'd',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @TobeCalAmt>=5
												BEGIN
													IF @FStatus=1
														BEGIN
															EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid

															SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
															SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														END 
												END 
												INSERT INTO RaiseCreditDebit
												SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
											END 
										ELSE
											BEGIN 

												SET @TobeCalAmt= ((@DiffAmt*@Discount)/100)
												--SELECT 'e',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @TobeCalAmt>=5
												BEGIN
												IF @FStatus=1
													BEGIN
														EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid

														SELECT  @DiffIntAmt=sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													END 
												END 
												INSERT INTO RaiseCreditDebit
												SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@Discount,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
											END 
									END 
								ELSE 
									BEGIN
										IF 	@CollectionAmt >0 
											BEGIN 
												SET @CashDis1=@Discount-@CashDis
												SET @TobeCalAmt= ((@CollectionAmt*@CashDis1)/100)
												--SELECT 'f',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @TobeCalAmt>=5
												BEGIN
												IF @FStatus=1
													BEGIN
														EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
														
														SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													END 
												END 
													INSERT INTO RaiseCreditDebit
													SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc	
											END 	
										ELSE
											BEGIN 
												SELECT @MaxSlabid=max(Slabid) FROM AutoDbCrSlabConfig
												IF @Slabid = @MaxSlabid
													BEGIN 
														SELECT @CashDis1 = SalCDPer FROM salesinvoice WHERE SalCDPer>0 AND SalId=@salid
														SET @TobeCalAmt= ((@DiffAmt*@CashDis1)/100) 	
														--SELECT 'a',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																	BEGIN 
																		EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid							
																		
																		SELECT @DiffIntAmt= sum(TaxAmount) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																		SELECT @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
									END 
							END 
					END 	
				ELSE
					BEGIN 
						IF @DateDiff<=@CreditPeriod AND @CollectionAmt>0
							BEGIN 		
								IF NOT exists (SELECT  * FROM salesinvoice WHERE SalCDPer>0 AND SalId=@salid)
									BEGIN 
										INSERT INTO AutoDBCDPrdSlabAchieved
											SELECT @salid,@PrdId,@PrdBatId,@Slabid,@DiffAmt,@CollectionAmt
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														--SELECT 'b1',@DiffAmt,@CashDis,@Row
														--SELECT 'b',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																	BEGIN
																		EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																		
																		SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																		SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
										ELSE
											BEGIN 
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid
												SET @CashDis=@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @TobeCalAmt>=5
															BEGIN
															IF @FStatus=1
																BEGIN
																	EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																	
																	SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																END 
														END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END
											END 
									END 
								ELSE
									BEGIN 
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																	BEGIN
																		EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																		
																		SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																		SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
										ELSE
											BEGIN 
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid
												SET @CashDis=@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																BEGIN
																	EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																	
																	SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END
											END 
									END
							END 
					END 
			END 
		SELECT @MAxCreditPeriod=CreditPeriod FROM AutoDbCrSlabConfig WHERE SlabId IN (SELECT max(Slabid) FROM AutoDbCrSlabConfig)
		IF @MAxCreditPeriod<@DateDiff
			BEGIN 
				IF NOT EXISTS (SELECT * FROM AutoDBCDSlabAchieved WHERE SalId=@salid)
					BEGIN 
						INSERT INTO AutoDBCDSlabAchieved
							SELECT @salid,@salinvno
					END 
			END 
		
		FETCH next FROM cur_Salinvno INTO @salinvno,@salid,@PrdId,@PrdBatId,@Row,@SalCDPer,@DiffAmt,@CollectionAmt,@Rtrid
		END 
		CLOSE cur_Salinvno
		DEALLOCATE cur_Salinvno
	FETCH next FROM cur_CreditSlab INTO @Slabid,@CreditPeriod,@Discount
	END 
	CLOSE cur_CreditSlab
	DEALLOCATE cur_CreditSlab


	DECLARE cur_CreditDebtitGen CURSOR
		FOR SELECT CrDr,Salid,Rtrid,MaxPerc,sum(CrAmt+CRDBInt) CRDBAmt FROM RaiseCreditDebit GROUP BY CrDr,Salid,Rtrid,MaxPerc

		OPEN cur_CreditDebtitGen
		FETCH next FROM cur_CreditDebtitGen INTO @CRDBName,@CRDBSalid,@DBCRRtrID,@MaxCRDVBPerc,@DBCRCollectionAmt
		WHILE @@Fetch_status=0
		BEGIN 
			IF @CRDBName='Debit'
				BEGIN 
					SELECT @DebitCreditNo=dbo.Fn_GetPrimaryKeyString('DebitNoteRetailer','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
					SET @CrDbNoteDate=GETDATE()
					SELECT @AccCoaId=CoaId FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId=@DBCRRtrID)
					SELECT @FindReasoId= ReasonId FROM ReasonMaster WHERE ReasonCode='R022'
					SELECT @DBCDRtrCode=RtrCode FROM Retailer WHERE RtrId=@DBCRRtrID
					SELECT @DBCDRtrName=RtrName FROM Retailer WHERE RtrId=@DBCRRtrID
					SELECT @DBCDSalInvNo=SalInvNo FROM SalesInvoice WHERE SalId=@CRDBSalid
					SELECT @DBCDSalInvDate=SalInvDate FROM SalesInvoice WHERE SalId=@CRDBSalid
									
					INSERT INTO DebitNoteRetailer(DbNoteNumber,DbNoteDate,RtrId,CoaId,ReasonId,Amount,DbAdjAmount,
						Status,PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
					VALUES(@DebitCreditNo,CONVERT(DATETIME,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),121),@DBCRRtrID,@AccCoaId,@FindReasoId,@DBCRCollectionAmt,0,
						1,'Auto Debit Note',19,'AUTO DB/CD',1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'From Auto Debit Note ' + @Pi_RefNo + '  ' + @DBCDSalInvNo)
					
					IF @FStatus=1
						BEGIN 
							INSERT INTO CrDbNoteTaxBreakUp
							SELECT @DebitCreditNo AS Debitno,19 AS Transid,TaxID,TaxPerc,sum(TaxableAmount) TaxableAmount,sum(TaxAmount) TaxAmount,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)  FROM AutoDBCDProductTax WHERE SalId=@CRDBSalid AND MaxTaxPerc=@MaxCRDVBPerc
								GROUP BY TaxId,Taxperc
								ORDER BY TaxId
						END 
					UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteRetailer' AND Fldname = 'DbNoteNumber'

					EXEC Proc_VoucherPosting 19,1,@DebitCreditNo,3,6,1,@Pi_TransDate,@Po_ErrNo= @ErrStatus OUTPUT
					
														
					INSERT INTO AutoRaisedCreditDebit(RtrId,RtrCode,RtrName,Salid,SalInvNo,SalInvDate,DBCRNoteNo,DBCRNoteAmt)
						VALUES (@DBCRRtrID,@DBCDRtrCode,@DBCDRtrName,@CRDBSalid,@DBCDSalInvNo,@DBCDSalInvDate,@DebitCreditNo,@DBCRCollectionAmt)			

				END 
			ELSE
				IF @CRDBName='Credit'
					BEGIN 
						SELECT @DebitCreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
										
						SET @CrDbNoteDate=GETDATE()
						SELECT @AccCoaId=CoaId FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrID=@DBCRRtrID)
						SELECT @FindReasoId= ReasonId FROM ReasonMaster WHERE ReasonCode='R022'
						SELECT @DBCDRtrCode=RtrCode FROM Retailer WHERE RtrId=@DBCRRtrID
						SELECT @DBCDRtrName=RtrName FROM Retailer WHERE RtrId=@DBCRRtrID
						SELECT @DBCDSalInvNo=SalInvNo FROM SalesInvoice WHERE SalId=@CRDBSalid
						SELECT @DBCDSalInvDate=SalInvDate FROM SalesInvoice WHERE SalId=@CRDBSalid

							INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,
							Status,PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
							VALUES(@DebitCreditNo,CONVERT(DATETIME,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),121),@DBCRRtrID,@AccCoaId,@FindReasoId,@DBCRCollectionAmt,0,
							1,'Auto Credit Note',18,'AUTO DB/CD',1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'From Auto Credit Note ' + @Pi_RefNo+ ' ' + @DBCDSalInvNo)
						
						IF @FStatus=1
							BEGIN 
								INSERT INTO CrDbNoteTaxBreakUp
								SELECT @DebitCreditNo AS Debitno,18 AS Transid,TaxID,TaxPerc,sum(TaxableAmount) TaxableAmount,sum(TaxAmount) TaxAmount,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)  FROM AutoDBCDProductTax WHERE SalId=@CRDBSalid AND MaxTaxPerc=@MaxCRDVBPerc
								GROUP BY TaxId,Taxperc
								ORDER BY TaxId				
							END 
						UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteRetailer' AND Fldname = 'CrNoteNumber'
						
						EXEC Proc_VoucherPosting 18,1,@DebitCreditNo,3,6,1,@Pi_TransDate,@Po_ErrNo= @ErrStatus OUTPUT

						
										
						INSERT INTO AutoRaisedCreditDebit(RtrId,RtrCode,RtrName,Salid,SalInvNo,SalInvDate,DBCRNoteNo,DBCRNoteAmt)
							VALUES (@DBCRRtrID,@DBCDRtrCode,@DBCDRtrName,@CRDBSalid,@DBCDSalInvNo,@DBCDSalInvDate,@DebitCreditNo,@DBCRCollectionAmt)		

					END 
			FETCH next FROM cur_CreditDebtitGen INTO @CRDBName,@CRDBSalid,@DBCRRtrID,@MaxCRDVBPerc,@DBCRCollectionAmt
		END 
	CLOSE cur_CreditDebtitGen
	DEALLOCATE cur_CreditDebtitGen
	
	UPDATE SalesInvoice SET AutoDBCD=1 WHERE SalId IN (SELECT SalId FROM AutoDBCDSlabAchieved)
END 
GO


IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AutoTAXDBCDCreation')
DROP PROCEDURE Proc_AutoTAXDBCDCreation
GO
/*
BEGIN TRANSACTION
exec Proc_AutoTAXDBCDCreation 6,45,1304,4,1
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_AutoTAXDBCDCreation
(
	@SalId int,
	@PrdId int,
	@PrdBaId int,
	@Row int,
	@TobeCalAmt numeric(28,6),
	@Slabid int
	
)
AS
SET NOCOUNT ON
BEGIN
		DECLARE @Pi_TransId AS int 
		DECLARE @Pi_UsrId  AS int
		SET @Pi_TransId=2
		select  @Pi_UsrId=min(userid) from users
		DELETE FROM BilledPrdHdForTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		DELETE FROM BilledPrdDtForTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId

		INSERT INTO BilledPrdHdForTax
		SELECT B.Slno,A.RtrId,B.PrdId,B.PrdBatId,B.BaseQty,A.BillSeqId,@Pi_UsrId,@Pi_TransId,B.PriceId
		FROM SalesInvoiceProduct B INNER JOIN SalesInvoice A ON A.SalId=B.SalId 
		WHERE A.SalId=@SalId AND B.PrdId=@PrdId AND B.PrdBatId=@PrdBaId 

		INSERT INTO BilledPrdDtForTax
		SELECT @Row,-2 AS ColId,@TobeCalAmt AS ColValue,@Pi_UsrId AS Usrid,@Pi_TransId AS TransId 

		DECLARE CalCulateTax CURSOR FOR
		SELECT Slno FROM SalesinvoiceProduct WHERE SalId=@SalId AND PrdId=@PrdId AND PrdBatId=@PrdBaId  ORDER BY Slno
		OPEN CalCulateTax
		FETCH next FROM CalCulateTax INTO @Row
		WHILE @@fetch_status= 0
		BEGIN
			DELETE FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
			EXEC Proc_ComputeTax @Row,@Pi_TransId,@Pi_UsrId
			IF EXISTS (SELECT * FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
			BEGIN
				DELETE FROM AutoDBCDProductTax WHERE SalId=@SalId AND PrdSlno=@Row AND SlabId=@Slabid
				INSERT INTO AutoDBCDProductTax(SalId,PrdSlNo,TaxId,TaxPerc,TaxableAmount,TaxAmount,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxTaxPerc,SlabId)
				SELECT DISTINCT @SalId,RowId,TaxId,TaxPercentage,TaxableAmount,TaxAmount,1,1,GETDATE(),1,GETDATE(),0,@Slabid
				FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND RowId=@Row
				UPDATE AutoDBCDProductTax SET MaxTaxPerc=(SELECT max(TaxPercentage) FROM BilledPrdDtCalculatedTax WHERE  TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND RowId=@Row)  WHERE  SalId=@SalId AND PrdSlno=@Row AND SlabId=@Slabid
			END
			FETCH next FROM CalCulateTax INTO @Row
		END
		CLOSE CalCulateTax
		DEALLOCATE CalCulateTax
END 
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptProductPurchase')
DROP PROCEDURE Proc_RptProductPurchase
GO
--  exec [Proc_RptProductPurchase] 24,1,0,'BL',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptProductPurchase]
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
	DECLARE @ToDate		AS	DATETIME
	DECLARE @CmpId	 	AS	INT
	DECLARE @CmpInvNo 	AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdBatId	AS	INT
	DECLARE @PrdId		AS	INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @CmpInvNo=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	Create TABLE #RptProductPurchase
	(
			CmpId 			INT,
			CmpName  		NVARCHAR(50),		
			PurRcptId 		BIGINT,
			PurRcptRefNo 		NVARCHAR(50),
			InvDate 		DATETIME,		
			PrdId  			INT,
			PrdDCode 		NVARCHAR(100),
			PrdName 		NVARCHAR(100),
			InvBaseQty 		INT,
			PrdGrossAmount 		NUMERIC(38,6),
			CmpInvNo 		nVarchar(100)
	)
	SET @TblName = 'RptProductPurchase'
	SET @TblStruct = 'CmpId 			INT,
			CmpName  		NVARCHAR(50),		
			PurRcptId 		BIGINT,
			PurRcptRefNo 		NVARCHAR(50),
			InvDate 		DATETIME,		
			PrdId  			INT,
			PrdDCode 		NVARCHAR(100),
			PrdName 		NVARCHAR(100),
			InvBaseQty 		INT,
			PrdGrossAmount 		NUMERIC(38,6),
			CmpInvNo 		nVarchar(100)'
			
	SET @TblFields = 'CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,InvBaseQty
			 ,PrdGrossAmount,CmpInvNo'
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
	if exists (select * from dbo.sysobjects where id = object_id(N'[UOMIdWise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [UOMIdWise]
	CREATE TABLE [UOMIdWise] 
	(
		SlNo	INT IDENTITY(1,1),
		UOMId	INT
	) 
	INSERT INTO UOMIdWise(UOMId)
	SELECT UOMId FROM UOMMaster ORDER BY UOMId	
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		EXEC Proc_GRNListing @Pi_UsrId
		INSERT INTO #RptProductPurchase(CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,InvBaseQty
		 ,PrdGrossAmount,CmpInvNo)
		SELECT DISTINCT CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate, PrdId,PrdDCode,PrdName,
			dbo.Fn_ConvertCurrency(InvBaseQty,@Pi_CurrencyId) as InvBaseQty  ,
			dbo.Fn_ConvertCurrency(PrdGrossAmount,@Pi_CurrencyId) as PrdGrossAmount,CmpInvNo
		FROM ( SELECT  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,
			SUM(InvBaseQty) AS InvBaseQty  , SUM(PrdGrossAmount) AS PrdGrossAmount,SlNo,CmpInvNo FROM 
			TempGrnListing
			WHERE
				( CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND
				( PurRcptId = (CASE @CmpInvNo WHEN 0 THEN PurRcptId ELSE 0 END) OR
					PurRcptId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId)))
				AND
			
--				(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
--					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
--			
--				AND 
--				(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR
--					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
--		 		AND
				( INVDATE BETWEEN @FromDate AND @ToDate AND Usrid = @Pi_UsrId)  	
				AND ( PrdId <> 0)
	
			GROUP BY  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,SlNo,CmpInvNo
		) A
		ORDER BY  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,CmpInvNo
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptProductPurchase ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
				' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
				+ '(PurRcptId = (CASE ' + CAST(@CmpInvNo AS nVarchar(10)) + ' WHEN 0 THEN PurRcptID ELSE 0 END) OR ' +
				' PurRcptID in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',194,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
				+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') AND ( PrdId <> 0) ' 	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptProductPurchase'
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
			SET @SSQL = 'INSERT INTO #RptProductPurchase ' +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptProductPurchase
/* Grid View Output Query  09-July-2009   */
	SELECT  a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,
			a.InvDate,a.PrdId,a.PrdDCode,a.PrdName,	a.InvBaseQty,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(a.InvBaseQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
					(CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
					CASE 
						WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
							Case When 
									CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
					ELSE
						CASE 
							WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
								Case
									When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
										CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor2,0)
									Else CAST(Sum(a.InvBaseQty) AS INT) End
							WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
								Case
									When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
										CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor3,0)
									Else CAST(Sum(a.InvBaseQty) AS INT) End			
						ELSE CAST(Sum(a.InvBaseQty) AS INT) END
					END as Uom4,
			a.PrdGrossAmount INTO #TEMPRptProductPurchaseGrid
	FROM 
			#RptProductPurchase A, View_ProdUOMDetails B 
	WHERE 
			a.prdid=b.prdid 
	Group By a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,ConversionFactor1,
			a.InvDate,a.PrdId,a.PrdDCode,a.PrdName,	a.InvBaseQty,a.PrdGrossAmount,ConverisonFactor2,
			ConverisonFactor3,ConverisonFactor4
	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
	INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,Rptid,Usrid)
	SELECT CmpName,CmpInvNo,PurRcptRefNo,InvDate,PrdDCode,
	PrdName,InvBaseQty,Uom1,Uom2,Uom3,Uom4,
	PrdGrossAmount,@Pi_RptId,@Pi_UsrId FROM #TEMPRptProductPurchaseGrid
/*  End here  */
-- Added on 09-July-2009 
SELECT 
		a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,a.InvDate,
		a.PrdId,a.PrdDCode,a.PrdName,a.InvBaseQty,
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(a.InvBaseQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
					CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
					CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
					(CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
					CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
					CASE 
						WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
							Case When 
									CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
					ELSE
						CASE 
							WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
								Case
									When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
										CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor2,0)
									Else CAST(Sum(a.InvBaseQty) AS INT) End
							WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
								Case
									When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
										CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor3,0)
									Else CAST(Sum(a.InvBaseQty) AS INT) End			
						ELSE CAST(Sum(a.InvBaseQty) AS INT) END
					END as Uom4,
				a.PrdGrossAmount
		FROM 
				#RptProductPurchase A, View_ProdUOMDetails B 
		WHERE 
				a.prdid=b.prdid 
		Group By a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,ConversionFactor1,
			a.InvDate,a.PrdId,a.PrdDCode,a.PrdName,	a.InvBaseQty,a.PrdGrossAmount,ConverisonFactor2,
			ConverisonFactor3,ConverisonFactor4
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptProductPurchase_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
			DROP TABLE RptProductPurchase_Excel
			SELECT CmpId, CmpName,CmpInvNo,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,
				PrdName,InvBaseQty,0 AS Uom1,0 AS  Uom2,0 AS  Uom3,0 AS  Uom4,PrdGrossAmount INTO RptProductPurchase_Excel FROM #RptProductPurchase
		END 
-- End Here
RETURN
END
GO
if not exists (Select Id,name from Syscolumns where name = 'SalInvLvlDiscPer' and id in (Select id from 
	Sysobjects where name ='SalesInvoice'))
begin
	ALTER TABLE [dbo].[SalesInvoice]
	ADD SalInvLvlDiscPer NUMERIC(18,2) NOT NULL DEFAULT 0 WITH VALUES
END
GO
if not exists (Select Id,name from Syscolumns where name = 'InvLvlConfig' and id in (Select id from 
	Sysobjects where name ='SalesInvoice'))
begin
	ALTER TABLE [dbo].[SalesInvoice]
	ADD InvLvlConfig Int NOT NULL DEFAULT 0 WITH VALUES
END
GO
if exists (Select Id,name from Syscolumns where name = 'InvLvlConfig' and id in (Select id from 
	Sysobjects where name ='SalesInvoice'))
begin
	UPDATE SalesInvoice SET InvLvlConfig= 
	CASE 
		WHEN (SalInvLvlDisc>0 AND SalInvLvlDiscPer=0) THEN 2 ELSE 0 END		
END
GO
DELETE FROM Configuration WHERE ModuleId='DISTAXCOLL9' AND SeqNo=9
INSERT INTO Configuration
SELECT 'DISTAXCOLL9','Discount & Tax Collection','Treat Invoice Level Discount as',1,'',1,9
GO
if not exists (Select Id,name from Syscolumns where name = 'SalInvLvlDiscPer' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_DailySales'))
begin
	ALTER TABLE [dbo].Cs2Cn_Prk_DailySales
	ADD SalInvLvlDiscPer NUMERIC(18,2) NOT NULL DEFAULT 0 WITH VALUES
END
GO
if not exists (Select Id,name from Syscolumns where name = 'SalInvLvlDiscPer' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_DailySales_Archive'))
begin
	ALTER TABLE [dbo].Cs2Cn_Prk_DailySales_Archive
	ADD SalInvLvlDiscPer NUMERIC(18,2) NOT NULL DEFAULT 0 WITH VALUES
END
GO
if not exists (Select Id,name from Syscolumns where name = 'SRNInvDiscount' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_SalesReturn'))
begin
	ALTER TABLE [dbo].Cs2Cn_Prk_SalesReturn
	ADD SRNInvDiscount NUMERIC(38,6) NOT NULL DEFAULT 0 WITH VALUES
END
GO
if not exists (Select Id,name from Syscolumns where name = 'SRNInvDiscount' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_SalesReturn_Archive'))
begin
	ALTER TABLE [dbo].Cs2Cn_Prk_SalesReturn_Archive
	ADD SRNInvDiscount NUMERIC(38,6) NOT NULL DEFAULT 0 WITH VALUES
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_DailySales]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_DailySales]
GO
/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DailySales
UPDATE SalesInvoice SET Upload=0
EXEC Proc_Cs2Cn_DailySales 0
SELECT * FROM Cs2Cn_Prk_DailySales
SELECT * FROM SalesInvoice WHERE DlvSts IN (4,5)
SELECT SIP.* FROM SalesInvoice SI,SalesInvoiceProduct SIP WHERE SI.SAlId=SIP.SalId AND SI.DlvSts IN (4,5)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_DailySales]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DailySales
* PURPOSE		: To Extract Daily Sales Details from CoreStocky to upload to Console
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
	DECLARE @CmpId 			AS INT
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @DefCmpAlone	AS INT
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'Y'
	SELECT @DefCmpAlone=Status FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1	
	INSERT INTO Cs2Cn_Prk_DailySales
	(
		DistCode		,
		SalInvNo		,
		SalInvDate		,
		SalDlvDate		,
		SalInvMode		,
		SalInvType		,
		SalGrossAmt		,
		SalSplDiscAmt	,
		SalSchDiscAmt	,
		SalCashDiscAmt	,
		SalDBDiscAmt	,
		SalTaxAmt		,
		SalWDSAmt		,
		SalDbAdjAmt		,
		SalCrAdjAmt		,
		SalOnAccountAmt	,
		SalMktRetAmt	,
		SalReplaceAmt	,
		SalOtherChargesAmt,
		SalInvLevelDiscAmt,
		SalTotDedn		,
		SalTotAddn		,
		SalRoundOffAmt	,
		SalNetAmt		,
		LcnId			,
		LcnCode			,
		SalesmanCode	,
		SalesmanName	,	
		SalesRouteCode	,
		SalesRouteName	,
		RtrId			,
		RtrCode			,
		RtrName			,
		VechName		,
		DlvBoyName		,
		DeliveryRouteCode	,	
		DeliveryRouteName	,	
		PrdCode				,
		PrdBatCde			,
		PrdQty				,
		PrdSelRateBeforeTax	,
		PrdSelRateAfterTax	,
		PrdFreeQty		,
		PrdGrossAmt		,
		PrdSplDiscAmt	,
		PrdSchDiscAmt	,
		PrdCashDiscAmt	,
		PrdDBDiscAmt	,
		PrdTaxAmt		,
		PrdNetAmt		,
		UploadFlag		,
		SalInvLineCount ,
		SalInvLvlDiscPer
	)
	SELECT 	@DistCode,A.SalInvNo,A.SalInvDate,A.SalDlvDate,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,
	A.OtherCharges,A.SalInvLvlDisc AS InvLevelDiscAmt,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,A.LcnId,L.LcnCode,
	B.SMCode,B.SMName,C.RMCode,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,
	ISNULL(E.VehicleRegNo,'') AS VehicleName,D.DlvBoyName,F.RMCode,F.RMName,H.PrdCCode,I.CmpBatCode,
	G.BaseQty AS SalInvQty ,G.PrdUom1EditedSelRate,G.PrdUom1EditedNetRate,G.SalManFreeQty AS SalInvFree ,
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount,
	'N' AS UploadFlag,0,A.SalInvLvlDiscPer
	FROM SalesInvoice A  (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID
	INNER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId AND H.PrdId=I.PrdId
	INNER JOIN Location L (NOLOCK)	ON L.LcnId=A.LcnId
	WHERE A.Dlvsts IN (4,5)  AND A.Upload=0
		
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where ProcId = 1

	UPDATE A SET SalInvLineCount=B.SalInvLineCount
	FROM Cs2Cn_Prk_DailySales A,(SELECT SI.SalInvNo,COUNT(SIP.PrdId) AS SalInvLineCount 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP WHERE 
	SI.DlvSts IN (4,5) AND SI.UPload=0 AND SI.SalId=SIP.SalId
	GROUP BY SI.SalInvNo) B
	WHERE A.SalInvNo=B.SalInvNo

	--->Added By Nanda on 17/08/2010
	INSERT INTO Cs2Cn_Prk_SalesInvoiceOrders(DistCode,SalInvNo,OrderNo,OrderDate,UploadFlag)
	SELECT DISTINCT @DistCode,SI.SalInvNo,OB.OrderNo,OB.OrderDate,'N'
	FROM SalesInvoice SI,SalesinvoiceOrderBooking SIOB,OrderBooking OB
	WHERE SI.SalId=SIOB.SalId AND SIOB.OrderNo=OB.OrderNo AND SI.Upload=0 AND SI.DlvSts>3
	--->Till Here

	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'N') AND Dlvsts IN (4,5)
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Proc_Cs2Cn_UploadArchiving') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Proc_Cs2Cn_UploadArchiving
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
				IF @PrkTable='Cs2Cn_Prk_DailySales'
				BEGIN
					INSERT INTO Cs2Cn_Prk_DailySales_Archive(SlNo,DistCode,SalInvNo,SalInvDate,SalDlvDate,SalInvMode,SalInvType,SalGrossAmt,SalSplDiscAmt,
					SalSchDiscAmt,SalCashDiscAmt,SalDBDiscAmt,SalTaxAmt,SalWDSAmt,SalDbAdjAmt,SalCrAdjAmt,SalOnAccountAmt,SalMktRetAmt,SalReplaceAmt,
					SalOtherChargesAmt,SalInvLevelDiscAmt,SalTotDedn,SalTotAddn,SalRoundOffAmt,SalNetAmt,LcnId,LcnCode,SalesmanCode,SalesmanName,SalesRouteCode,
					SalesRouteName,RtrId,RtrCode,RtrName,VechName,DlvBoyName,DeliveryRouteCode,DeliveryRouteName,PrdCode,PrdBatCde,PrdQty,PrdSelRateBeforeTax,
					PrdSelRateAfterTax,PrdFreeQty,PrdGrossAmt,PrdSplDiscAmt,PrdSchDiscAmt,PrdCashDiscAmt,PrdDBDiscAmt,PrdTaxAmt,PrdNetAmt,UploadFlag,SalInvLineCount,
					SalInvLvlDiscPer,UploadedDate)
					SELECT *,GETDATE() FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'Y'
				END
				ELSE IF @PrkTable='Cs2Cn_Prk_SalesReturn'
				BEGIN
					INSERT INTO Cs2Cn_Prk_SalesReturn_Archive (SlNo,DistCode,SRNRefNo,SRNRefType,SRNDate,SRNMode,SRNType,SRNGrossAmt,SRNSplDiscAmt,SRNSchDiscAmt,
					SRNCashDiscAmt,SRNDBDiscAmt,SRNTaxAmt,SRNRoundOffAmt,SRNNetAmt,SalesmanName,SalesRouteName,RtrId,RtrCode,RtrName,PrdSalInvNo,PrdLcnId,PrdLcnCode,
					PrdCode,PrdBatCde,PrdSalQty,PrdUnSalQty,PrdOfferQty,PrdSelRate,PrdGrossAmt,PrdSplDiscAmt,PrdSchDiscAmt,PrdCashDiscAmt,PrdDBDiscAmt,PrdTaxAmt,
					PrdNetAmt,UploadFlag,SRNInvDiscount,UploadedDate)
					SELECT *,GETDATE() FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'Y'
				END
				ELSE
				BEGIN				
					SET @StrQry = 'INSERT INTO '+@PrkTable+'_Archive SELECT *,GETDATE() FROM ' + @PrkTable + ' WHERE UploadFlag = ''Y'''
					SELECT @StrQry
					EXEC(@StrQry)		
				END
			END
		END
		SET @SeqNo = @SeqNo - 1
	END
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND Name='Proc_Cs2Cn_SalesReturn')
DROP PROCEDURE Proc_Cs2Cn_SalesReturn
GO
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_SalesReturn]  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS
--EXEC Proc_Cs2Cn_SalesReturn 0   
/*********************************  
* PROCEDURE  : Proc_Cs2Cn_SalesReturn  
* PURPOSE  : To Extract Sales Return Details from CoreStocky to upload to Console  
* CREATED BY : Nandakumar R.G  
* CREATED DATE : 21/03/2010  
* NOTE   :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
   
*********************************/  
SET NOCOUNT ON  
BEGIN  
   
 DECLARE @CmpId    AS INT  
 DECLARE @DistCode  As nVarchar(50)  
 DECLARE @DefCmpAlone AS INT  
 SET @Po_ErrNo=0  
 SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'  
 DELETE FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'Y'  
 SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
 INSERT INTO [Cs2Cn_Prk_SalesReturn]  
 (  
  DistCode  ,  
  SRNRefNo  ,  
  SRNRefType  ,  
  SRNDate   ,  
  SRNMode   ,  
  SRNType   ,   
  SRNGrossAmt  ,  
  SRNSplDiscAmt ,   
  SRNSchDiscAmt ,  
  SRNCashDiscAmt ,  
  SRNDBDiscAmt ,  
  SRNTaxAmt  ,  
  SRNRoundOffAmt ,
  SRNInvDiscount,  
  SRNNetAmt  ,  
  SalesmanName ,  
  SalesRouteName ,  
  RtrId   ,  
  RtrCode   ,  
  RtrName   ,  
  PrdSalInvNo  ,  
  PrdLcnId  ,  
  PrdLcnCode  ,  
  PrdCode   ,  
  PrdBatCde  ,  
  PrdSalQty  ,  
  PrdUnSalQty  ,  
  PrdOfferQty  ,  
  PrdSelRate  ,  
  PrdGrossAmt  ,  
  PrdSplDiscAmt ,  
  PrdSchDiscAmt ,  
  PrdCashDiscAmt ,  
  PrdDBDiscAmt ,  
  PrdTaxAmt  ,  
  PrdNetAmt  ,  
  UploadFlag  
 )  
 SELECT  
  @DistCode ,  
  A.ReturnCode ,  
  (CASE ReturnType WHEN 1 THEN 'Market Return' ELSE 'Sales Return' END),  
  A.ReturnDate ,  
  (CASE A.ReturnMode WHEN 0 THEN '' WHEN 1 THEN 'Full' ELSE 'Partial' END),  
  (CASE A.InvoiceType WHEN 1 THEN 'Single Invoice' ELSE 'Multi Invoice' END),  
  A.RtnGrossAmt,A.RtnSplDisAmt,A.RtnSchDisAmt,A.RtnCashDisAmt,A.RtnDBDisAmt,  
  A.RtnTaxAmt,A.RtnRoundOffAmt,A.RtnInvLvlDisc,A.RtnNetAmt,  
  SM.SMName,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,  
  ISNULL(G.SalInvno,B.SalCode) AS SalInvNo,  
  L.LcnId,L.LcnCode,    
  D.PrdCCode,F.CmpBatCode,  
  (CASE ST.SystemStockType WHEN 1 THEN BaseQty ELSE 0 END)AS SalQty,  
  (CASE ST.SystemStockType WHEN 2 THEN BaseQty ELSE 0 END)AS UnSalQty,  
  (CASE ST.SystemStockType WHEN 3 THEN BaseQty ELSE 0 END)AS OfferQty,  
  B.PrdEditSelRte ,  
  B.PrdGrossAmt,B.PrdSplDisAmt,B.PrdSchDisAmt,B.PrdCDDisAmt,B.PrdDBDisAmt,  
  B.PrdTaxAmt,B.PrdNetAmt,  
  'N' AS UploadFlag  
 FROM ReturnHeader A INNER JOIN ReturnProduct B ON A.ReturnId = B.ReturnId  
  INNER JOIN RouteMaster C ON A.RMID = C.RMID  
  INNER JOIN Product D ON B.PrdId = D.PrdId  
  INNER JOIN Company E ON D.CmpId = E.CmpId  
  INNER JOIN ProductBatch F ON B.PrdBatId = F.PrdBatId  
  INNER JOIN Retailer R ON R.RtrId=A.RtrId  
  LEFT OUTER JOIN SalesInvoice G ON B.SalId = G.SalId  
  INNER JOIN Salesman SM ON A.SMId=SM.SMId  
  INNER JOIN StockType ST ON B.StockTypeId=ST.StockTypeId  
  INNER JOIN Location L ON L.LcnId=ST.LcnId  
 WHERE A.Status = 0 AND E.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE E.CmpId END)  
 AND A.Upload=0  
 UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),  
 ProcDate = CONVERT(nVarChar(10),GetDate(),121)  
 Where ProcId = 4  
 UPDATE ReturnHeader SET Upload=1 WHERE Upload=0 AND ReturnCode IN (SELECT DISTINCT  
 SRNRefNo FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'N') AND Status=0  
   
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_PurchaseReceipt')
DROP PROCEDURE Proc_Cn2Cs_PurchaseReceipt
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PurchaseReceipt 0
--SELECT * FROM Cn2Cs_Prk_BLPurchaseReceipt 
--Cn2Cs_Prk_BLPurchaseReceipt_Temp 
--SELECT * FROM InvToAvoid
--SELECT * FROM ErrorLog
SELECT * FROM ETLTempPurchaseReceipt where cmpinvno='MMINV00013'
SELECT * FROM ETLTempPurchaseReceiptProduct where cmpinvno='MMINV00013'
SELECT * FROM ETLTempPurchaseReceiptPrdLineDt where cmpinvno='MMINV00013'
SELECT * FROM ETLTempPurchaseReceiptClaimScheme where cmpinvno='MMINV00013'
SELECT * FROM ETL_Prk_PurchaseReceiptPrdLineDt where compinvno='MMINV00013'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_PurchaseReceipt]
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
	DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)	
	DELETE FROM ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1
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
	DECLARE @QtyInKg			NUMERIC(38,6)
	DECLARE @ExistCompInvNo		NVARCHAR(25)
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
	--->Till Here
	SET @ExistCompInvNo=0
	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT DISTINCT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,Qty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	ORDER BY CompInvNo,ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,UOMCode,Qty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
	@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
	@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @ExistCompInvNo<>@CompInvNo
		BEGIN
			SET @ExistCompInvNo=@CompInvNo
			SET @RowId=2
		END
		--To insert into ETL_Prk_PurchaseReceiptPrdDt
		IF(@FreeSchemeFlag='0')
		BEGIN
			INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount])
			VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@LineLvlAmt,
			@PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty)
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
		SET @RowId=@RowId+1
		FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
		@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg
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
					SET @ErrStatus=@ErrStatus
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
	SET @Po_ErrNo= @ErrStatus
	RETURN
END
GO
IF NOT Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='BillBookRefNo')
BEGIN
	ALTER TABLE RptBillTemplateFinal ADD BillBookRefNo   VARCHAR(100) NULL
END
GO
IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
DROP TABLE [RptBillTemplateFinal_Group]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL_BILLTEMPLATE'
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
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
* Removed Userid mapping for supreports on 30-08-2011 By Boopathy.P
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
	SELECT @DeliveredBill=Status FROM  Configuration  (NOLOCK) WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'
	IF @DeliveredBill=1
	BEGIN		
		DELETE FROM RptBillToPrint WHERE [Bill Number] IN(
		SELECT SalInvNo FROM SalesInvoice  (NOLOCK) WHERE DlvSts NOT IN(4,5))  AND UsrId=@Pi_UsrId
	END
	--Till Here
	--Added By Murugan 04/09/2009
	SET @FieldCount=0
	SELECT @UomStatus=Isnull(Status,0) FROM configuration  (NOLOCK)  WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22
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
		FOR SELECT UOMID,UOMCODE FROM UOMMASTER  (NOLOCK)  Order BY UOMID
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
--	if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
--	drop table [RptBillTemplateFinal]
--	IF @UomStatus=1
--	BEGIN	
--		Exec('CREATE TABLE RptBillTemplateFinal
--		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')
--	END
--	ELSE
--	BEGIN
--		Exec('CREATE TABLE RptBillTemplateFinal
--		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500))')
--	END
	DELETE FROM RptBillTemplateFinal WHERE Usrid=@Pi_UsrId
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
			'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND T.UsrId='+@Pi_UsrId)
		END
		ELSE
		BEGIN
			--SELECT 'Nanda002'	
			Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +
			'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND  T.UsrId='+ @Pi_UsrId)
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +
				'(' + @TblFields + ')' +
			' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + '  (NOLOCK) Where UsrId = ' +  CAST(@Pi_UsrId AS VARCHAR(10))
		
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
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
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
		AND [RptBillTemplateFinal].[Batch Code] =ProductBatch.[PrdBatCode] AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))
		EXEC (@SSQL1)
	END
--- End Sl No

--	BillBookRefNo

	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='BillBookRefNo')
	BEGIN
		UPDATE A SET BillBookRefNo=B.BillBookNo FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN 
		SalesInvoice B (NOLOCK) ON A.SalId=B.SalId WHERE A.UsrId=@Pi_UsrId

--		(SELECT SalId,BillBookNo FROM SalesInvoice (NOLOCK) WHERE 
--		SalId IN (SELECT DISTINCT SalId FROM RptBillTemplateFinal (NOLOCK) WHERE UsrId=@Pi_UsrId)) B
--		ON A.SalId=B.SalId WHERE A.UsrId=@Pi_UsrId
	END
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
	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI  (NOLOCK) , TaxConfiguration T (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
	End
	------------------------------ Other
	Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI (NOLOCK) ,PurSalAccConfig P (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
		AND B.UsrId = @Pi_UsrId
	End
	---------------------------------------Replacement
	Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H (NOLOCK) , ReplacementOut D (NOLOCK) , Product P (NOLOCK) , ProductBatch PB (NOLOCK) ,SalesInvoice SI (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
		AND B.UsrId = @Pi_UsrId
	End
	----------------------------------Credit Debit Adjustment
	SELECT @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	IF @Sub_Val = 1
	BEGIN
		INSERT INTO RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		SELECT A.SalId,S.SalInvNo,A.CrNoteNumber,A.CrAdjAmount,A.AdjSoFar,CNR.Remarks,@Pi_UsrId
		FROM SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B,CreditNoteRetailer CNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND CNR.CrNoteNumber=A.CrNoteNumber  AND B.UsrId=@Pi_UsrId
		UNION ALL
		SELECT A.SalId,S.SalInvNo,A.DbNoteNumber,A.DbAdjAmount,A.AdjSoFar,DNR.Remarks,@Pi_UsrId
		FROM SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B,DebitNoteRetailer DNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND DNR.DbNoteNumber=A.DbNoteNumber AND B.UsrId=@Pi_UsrId
	END

	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId)
		Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId
		From ReturnHeader H (NOLOCK) ,ReturnProduct D (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) 
		Where returntype = 1
		and H.ReturnID = D.ReturnID
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId
		From ReturnPrdHdForScheme D (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK) ,ReturnHeader H (NOLOCK) ,ReturnProduct T (NOLOCK) 
		WHERE returntype = 1 AND
		D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = T.SalId
		and H.ReturnID = T.ReturnID
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
	End
	------------------------------ SampleIssue
	Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
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
		WHERE I.UsrId = @Pi_UsrId
	End
	--->Added By Nanda on 10/03/2010
	------------------------------ Scheme
	Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,19,LEN(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeLineWise SISL (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) 
		WHERE SISL.SchId=SM.SchId AND SI.SalId=SISL.SalId AND RBT.[Bill Number]=SI.SalInvNo AND RBT.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc
		HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,
		ProductBatchDetails PBD (NOLOCK) ,BatchCreation BC (NOLOCK) 
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.FreePrdId=P.PrdId AND SISFP.FreePrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND RBT.UsrId = @Pi_UsrId

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) ,Product P (NOLOCK) ,ProductBatch PB (NOLOCK) ,
		ProductBatchDetails PBD (NOLOCK) ,BatchCreation BC (NOLOCK) 
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.GiftPrdId=P.PrdId AND SISFP.GiftPrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND RBT.UsrId = @Pi_UsrId

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SIWD.AdjAmt),0,0,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) ,SalesInvoiceWindowDisplay SIWD (NOLOCK) ,SchemeMaster SM (NOLOCK) ,RptBillToPrint RBT (NOLOCK) 
		WHERE SIWD.SchId=SM.SchId AND SI.SalId=SIWD.SalId AND RBT.[Bill Number]=SI.SalInvNo AND RBT.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc

		UPDATE RPT SET SalInvSchemevalue=A.SalInvSchemevalue
		FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemevalue FROM RptBillTemplate_Scheme WHERE UsrId = @Pi_UsrId GROUP BY SalId)A
		WHERE A.SAlId=RPT.SalId AND RPT.UsrId = @Pi_UsrId

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
	IF EXISTS(SELECT * FROM Configuration  (NOLOCK) WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
		DROP TABLE [RptBillTemplateFinal_Group]

		SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal  (NOLOCK) WHERE UsrId = @Pi_UsrId
		DELETE FROM RptBillTemplateFinal WHERE UsrId = @Pi_UsrId

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
			[UsrId],[Visibility],[AmtInWrd],BillBookRefNo
		)		
		SELECT DISTINCT
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
		[Uom 1 Desc] AS [Uom 1 Desc],SUM([Uom 1 Qty]) AS [Uom 1 Qty],'' AS [Uom 2 Desc],0 AS [Uom 2 Qty],[Vehicle Name],
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
		[UsrId],[Visibility],[AmtInWrd],BillBookRefNo
		FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK) 
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId
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
		[Uom 1 Desc],	
		[UsrId],[Visibility],[AmtInWrd],BillBookRefNo
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
		[UsrId],[Visibility],[AmtInWrd],BillBookRefNo
		FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK) 
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId
	END	

	--->Till Here
	IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
				ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId)
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
		INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)
		SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
		ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId
	END
	ELSE
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
	END
	RETURN
END
GO
DELETE FROM ScreenDefaultValues WHERE TransId=45 AND CtrlId=118
INSERT INTO ScreenDefaultValues 
SELECT 45,118,0,'ALL',1,1,1,1,GETDATE(),1,GETDATE(),'ALL'
UNION
SELECT 45,118,1,'Value',2,1,1,1,GETDATE(),1,GETDATE(),'Value'
UNION
SELECT 45,118,2,'Product',3,1,1,1,GETDATE(),1,GETDATE(),'Product'
GO
Update SchemeMaster SET SettlementType=0 WHERE ISNULL(SettlementType,0)=0
GO
DELETE FROM HotSearchEditorHd WHERE FormId=211
INSERT INTO HotSearchEditorHd
SELECT 211,'Sales Return','Bill No','select',
'SELECT SalId,SalInvNo,SalInvDate,BillSeqId,SalRoundOff,SalRoundOffAmt,RtrName FROM   
(Select DISTINCT A.SalId,SalInvNo,SalInvDate,BillSeqId,SalRoundOff,SalRoundOffAmt,RtrName 
From SalesInvoice A (NOLOCK) INNER JOIN Retailer B (NOLOCK) ON A.RtrId = B.RtrId  
INNER JOIN SalesInvoiceProduct C (NOLOCK) ON A.SalId=C.SalId  Where  A.DlvSts in (4,5) 
AND (C.BaseQty-C.ReturnedQty)>0) MainSql'
GO
DELETE FROM HotSearchEditorHd WHERE FormId=190
INSERT INTO HotSearchEditorHd
SELECT 190,'Market Return','Bill No','select','
SELECT Salid,SalinvNo,LcnId,SalInvDate,RtrId,RtrName,BillSeqId,SalRoundOff,SalRoundOffAmt FROM     
(Select DISTINCT A.Salid,A.SalinvNo,A.LcnId,A.SalInvDate,B.RtrId,B.RtrName,A.BillSeqId,A.SalRoundOff,
A.SalRoundOffAmt       From SalesInvoice A (NOLOCK) INNER JOIN Retailer B (NOLOCK) ON A.RtrId = B.RtrId    
INNER JOIN SalesInvoiceProduct C (NOLOCK) ON A.SalId=C.SalId      And A.RtrId =''vFParam'' and A.RMId=''vSParam'' 
and A.SMId=''vTParam''   AND A.CmpId = Case vFOParam WHEN 0 THEN A.CmpId   ELSE vFOParam END 
AND A.DlvSts in (4,5) AND (C.BaseQty-C.ReturnedQty)>0  ) MainSql'
GO
DELETE FROM Configuration WHERE ModuleId='DISTAXCOLL9' AND SeqNo=9
INSERT INTO Configuration
SELECT 'DISTAXCOLL9','Discount & Tax Collection','Treat Invoice Level Discount as',1,'',1,9
GO
DELETE FROM Configuration WHERE ModuleId IN ('SALESRTN18','SALESRTN19')
INSERT INTO Configuration
SELECT 'SALESRTN18','Sales Return','Based on Slab Applied',1,'',0,1
UNION
SELECT 'SALESRTN19','Sales Return','Based on Slab Eligible',0,'',0,1
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBillSchemeDetails]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBillSchemeDetails]
GO
-- SELECT * FROM DBO.Fn_ReturnBillSchemeDetails(2,2)
CREATE  FUNCTION dbo.Fn_ReturnBillSchemeDetails (@Pi_UserId AS INT,@Pi_TransId AS INT)
RETURNS @ReturnBillSchemeDetails TABLE
	(
		SchId			INT,
		SchCode			VARCHAR(50),
		FlexiSch		INT,
		FlexiSchType	INT,
		SlabId			INT,
        SchemeAmount	NUMERIC(18,6),
		SchemeDiscount	NUMERIC(18,2),
		Points			INT,
		FlxDisc			INT,
        FlxValueDisc	INT,
		FlxFreePrd		INT,
		FlxGiftPrd		INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
        FreeToBeGiven	INT,
		EditScheme		INT,
		NoOfTimes		NUMERIC(18,6),
		Usrid			INT,
		FlxPoints		INT,
        GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftToBeGiven	INT,
		SchType			INT
	)
AS
/*********************************
* FUNCTION: Fn_ReturnBillSchemeDetails
* PURPOSE: Return Billed Scheme Details
* NOTES:
* CREATED: Boopathy.P 0n 14/07/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 06-08-2011 Boopathy.P Wrongly added prdbatid in Group by
*********************************/
BEGIN
		INSERT INTO @ReturnBillSchemeDetails
		SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=1 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount --ORDER BY A.SchId Asc,A.SlabId Asc
		UNION
		SELECT DISTINCT  A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset)=0 
		AND B.CombiSch=0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId 
		UNION
		SELECT DISTINCT  A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=0 AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset) >0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId,A.PrdBatId ORDER BY A.SchId Asc,A.SlabId Asc
RETURN
END
GO
DELETE FROM SalesInvoiceBookNoSettings
INSERT INTO SalesInvoiceBookNoSettings(RtrTaxType,Prefix,PrefixRunningNo,PrefixZpad,Suffix,SuffixZpad,ResetCount,
Availability,LastModBy,LastModDate,AuthId,AuthDate) 
VALUES(0,'VAT',1,2,0,5,50,1,1,GETDATE(),1,GETDATE())
INSERT INTO SalesInvoiceBookNoSettings(RtrTaxType,Prefix,PrefixRunningNo,PrefixZpad,Suffix,SuffixZpad,ResetCount,
Availability,LastModBy,LastModDate,AuthId,AuthDate) 
VALUES(1,'NVAT',2,2,0,5,50,1,1,GETDATE(),1,GETDATE())
GO
IF EXISTS (Select * From SysObjects Where Xtype = 'V' AND Name = 'View_ProdUOMDetails')
DROP VIEW View_ProdUOMDetails
GO
CREATE VIEW [dbo].[View_ProdUOMDetails]
AS
SELECT DISTINCT PrdId,PrdCcode,PrdDcode,
	MAX(Uomid) AS Uomid1,max(Uomgroupid) AS Uomgroupid1,Max(Uomcode) AS Uomcode1,MAX(ConversionFactor) AS ConversionFactor1,
	MAX(UOMID1) AS Uomid2,mAX(UOMGRPID2) AS Uomgroupid2,Max(Uomcode1) AS Uomcode2 ,mAX(ConverisonFactor2) AS ConverisonFactor2,
	MAX(UOMID3) AS Uomid3,mAX(UOMGRPID3) AS Uomgroupid3,Max(Uomcode3) AS Uomcode3 ,mAX(ConverisonFactor3) AS ConverisonFactor3,
	MAX(UOMID4) AS Uomid4,mAX(UOMGRPID4) AS Uomgroupid4,Max(Uomcode4) AS Uomcode4 ,mAX(ConverisonFactor4) AS ConverisonFactor4

	FROM(
	SELECT DISTINCT Prdid,Prdccode,PrdDcode,X.Uomid,X.Uomgroupid,X.Uomcode,(SELECT MAX(ConversionFactor) FROM UomGroup U where U.UomGroupId=X.UomGroupId AND UomId=1) AS ConversionFactor
	,0 AS UOMID1,0 AS UOMGRPID2 ,'' As Uomcode1,0 AS ConverisonFactor2 ,0 AS UOMID3,0 AS UOMGRPID3 ,'' As Uomcode3,0 AS ConverisonFactor3,
	0 AS UOMID4,0 AS UOMGRPID4 ,'' As Uomcode4,0 AS ConverisonFactor4
	FROM(SELECT prdid,prdccode,PrdDcode,ug.ConversionFactor,P.UomGroupId,UM.UomId,Um.UomCode FROM Product P
	INNER JOIN UomGroup ug ON ug.UomGroupId=p.UomGroupId
	INNER JOIN uommaster UM ON um.uomid=ug.uomid WHERE Um.UomId=1)X
	UNION ALL
	SELECT DISTINCT Prdid,Prdccode,PrdDcode,0 AS UOMID,0 AS Uomgroupid ,'' As Uomcode,0 AS ConversionFactor,X.Uomid,X.Uomgroupid,X.Uomcode,(SELECT MAX(ConversionFactor) FROM UomGroup U where U.UomGroupId=X.UomGroupId AND UomId=2) AS ConverisonFactor
	,0 AS UOMID3,0 AS UOMGRPID3 ,'' As Uomcode3,0 AS ConverisonFactor3,0 AS UOMID4,0 AS UOMGRPID4 ,'' As Uomcode4,0 AS ConverisonFactor4
	FROM(SELECT prdid,prdccode,PrdDcode,ug.ConversionFactor,P.UomGroupId,UM.UomId,Um.UomCode FROM Product P
	INNER JOIN UomGroup ug ON ug.UomGroupId=p.UomGroupId
	INNER JOIN uommaster UM ON um.uomid=ug.uomid WHERE Um.UomId=2)X
	UNION ALL
	SELECT DISTINCT Prdid,Prdccode,PrdDcode,0 AS UOMID,0 AS Uomgroupid ,'' As Uomcode,0 AS ConversionFactor,
	0 AS UOMID1,0 AS Uomgroupid1 ,'' As Uomcode1,0 AS ConversionFactor2,X.Uomid AS UOMID3,X.Uomgroupid AS UOMGRP3,X.Uomcode AS UOMCODE3,(SELECT MAX(ConversionFactor) FROM UomGroup U where U.UomGroupId=X.UomGroupId AND UomId=3) AS ConverisonFactor3,
	0 AS UOMID4,0 AS UOMGRPID4 ,'' As Uomcode4,0 AS ConverisonFactor4 FROM(SELECT prdid,prdccode,PrdDcode,ug.ConversionFactor,P.UomGroupId,UM.UomId,Um.UomCode FROM Product P
	INNER JOIN UomGroup ug ON ug.UomGroupId=p.UomGroupId
	INNER JOIN uommaster UM ON um.uomid=ug.uomid WHERE Um.UomId=3)X
	UNION ALL
	SELECT DISTINCT Prdid,Prdccode,PrdDcode,0 AS UOMID,0 AS Uomgroupid ,'' As Uomcode,0 AS ConversionFactor,
	0 AS UOMID1,0 AS Uomgroupid1 ,'' As Uomcode1,0 AS ConversionFactor2,0 AS UOMID3,0 AS UOMGRPID3 ,'' As Uomcode3,0 AS ConverisonFactor3,
	X.Uomid AS UOMID4,X.Uomgroupid AS UOMGRP4,X.Uomcode AS UOMCODE4,(SELECT MAX(ConversionFactor) FROM UomGroup U where U.UomGroupId=X.UomGroupId AND UomId=4) AS ConverisonFactor4
	FROM(SELECT prdid,prdccode,PrdDcode,ug.ConversionFactor,P.UomGroupId,UM.UomId,Um.UomCode FROM Product P
	INNER JOIN UomGroup ug ON ug.UomGroupId=p.UomGroupId
	INNER JOIN uommaster UM ON um.uomid=ug.uomid WHERE Um.UomId=4)X)y
	GROUP BY PRDID,Prdccode,PrdDcode
GO
IF Not Exists (select * from counters where TabName = 'ContractPricingMaster' and Fldname = 'ConRefNo') 
Begin
Insert into counters (TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT'ContractPricingMaster','ConRefNo','CPM',6,1,(Select Currvalue from counters where TabName = 'ContractPricingMaster' and Fldname = 'ContractId') ,
'Contract Pricing Master',1,2011,1,1,'2009-09-05 08:13:37.473',1,'2009-09-05 08:13:37.473'
End
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[Fn_ReturnContractPricingDetails]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Fn_ReturnContractPricingDetails]
GO
--Select * FROM Fn_ReturnContractPricingDetails(1,73,0)
CREATE FUNCTION [dbo].[Fn_ReturnContractPricingDetails]
(
	@Pi_CmpId INT,
	@Pi_CmpPrdId INT,
	@Pi_PrdCtgValMainId INT,
	@Pi_ContractId INT,
	@Pi_Mode INT,
	@Pi_DicMode INT
)    
RETURNS @ContractDetails TABLE    
 (    
	  PrdId   INT,    
	  PrdDCode NVARCHAR(100),    
	  PrdName  NVARCHAR(100),    
	  PrdBatId  INT,    
	  PrdBatCode NVARCHAR(100),    
	  PriceId  INT,    
	  PriceCode NVARCHAR(400),    
	  Discount NUMERIC(38,6),    
	  FlatAmtDisc NUMERIC(38,6),
	  ClaimablePercOnMRP NUMERIC(38,6)    
 )    
AS
BEGIN    
/*********************************    
* FUNCTION: Fn_ReturnContractPricingDetails    
* PURPOSE: Returns the Product and Batch Details for the Selected Contract Pricing    
* NOTES:     
* CREATED: NandaKumar R.G On 29-11-2007    
* MODIFIED     
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
*     
*********************************/    
IF @Pi_Mode=0  
BEGIN  
	IF @Pi_DicMode=0 
	BEGIN
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)    
		SELECT DISTINCT B.PrdId,B.PrdDCode,B.PrdName,A.PrdBatId,PB.PrdBatCode,A.PriceId,PBD.PriceCode,    
		ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc ,
		ISNULL(A.ClaimablePercOnMRP,0) AS ClaimablePercOnMRP      
		FROM ProductBatch PB WITH(NoLock),ProductBatchDetails PBD WITH(NoLock),ProductCategoryValue C WITH(NoLock)     
		INNER JOIN ProductCategoryValue D WITH(NoLock) ON D.PrdCtgValLinkCode     
		LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'    
		INNER JOIN Product B WITH(NoLock) On D.PrdCtgValMainId = B.PrdCtgValMainId     
		LEFT OUTER JOIN  ContractPricingDetails A WITH(NoLock) ON A.PrdId = B.PrdId AND A.ContractId= @Pi_ContractId    
		WHERE PB.PrdBatId=A.PrdBatId AND A.PriceId=PBD.PriceId AND     
		C.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END AND     
		B.CmpId = Case @Pi_CmpId WHEN 0  THEN B.CmpId ELSE @Pi_CmpId END AND B.PrdStatus=1 AND PrdType<>4 AND PrdType<>3    
	      
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)    
		SELECT DISTINCT P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,    
		PB.DefaultPriceId AS PriceId,PBD.PriceCode,0 AS Discount,0 AS FlatAmtDisc,0   
		FROM ProductCategoryValue PCV WITH(NoLock)   
		INNER JOIN  ProductCategoryValue PCV1 WITH(NoLock) ON  PCV1.PrdCtgValLinkCode     
		LIKE CAST(PCV.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'     
		INNER JOIN Product P WITH(NoLock) On PCV1.PrdCtgValMainId = P.PrdCtgValMainId     
		INNER JOIN ProductBatch PB WITH(NoLock) ON P.PrdId=PB.PrdId    
		INNER JOIN ProductBatchDetails PBD WITH(NoLock) ON PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=1    
		WHERE  P.CmpId= CASE @Pi_CmpId WHEN 0 THEN P.CmpId ELSE @Pi_CmpId END AND P.PrdStatus=1 AND P.PrdType NOT IN (3,4) AND    
		PCV.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN P.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END    
		--AND P.PrdId NOT IN (SELECT PrdId FROM ContractPricingDetails WHERE ContractId=@Pi_ContractId)  --Code commented and added by Vinayaga Raj for the bug id 17399     
		AND PB.PrdBatId NOT IN (SELECT PrdBatId FROM ContractPricingDetails WHERE ContractId=@Pi_ContractId)    
	END
	ELSE
	BEGIN
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)    
		SELECT DISTINCT B.PrdId,B.PrdDCode,B.PrdName,0,'',0,'',    
		ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc,
		ISNULL(A.ClaimablePercOnMRP,0) AS ClaimablePercOnMRP   
		FROM ProductCategoryValue C     
		INNER JOIN ProductCategoryValue D WITH(NoLock) ON D.PrdCtgValLinkCode     
		LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'    
		INNER JOIN Product B On D.PrdCtgValMainId = B.PrdCtgValMainId     
		INNER JOIN   ContractPricingDetails A ON A.PrdId = B.PrdId AND A.ContractId= @Pi_ContractId    
		WHERE C.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END AND     
		B.CmpId = Case @Pi_CmpId WHEN 0  THEN B.CmpId ELSE @Pi_CmpId END AND B.PrdStatus=1 AND PrdType<>4 AND PrdType<>3    
	      
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)    
		SELECT DISTINCT P.PrdId,P.PrdDCode,P.PrdName,0,'',    
		0 AS PriceId,'',0 AS Discount,0 AS FlatAmtDisc,0    
		FROM ProductCategoryValue PCV WITH(NoLock)   
		INNER JOIN  ProductCategoryValue PCV1 WITH(NoLock) ON  PCV1.PrdCtgValLinkCode     
		LIKE CAST(PCV.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'     
		INNER JOIN Product P On PCV1.PrdCtgValMainId = P.PrdCtgValMainId     
		WHERE  P.CmpId= CASE @Pi_CmpId WHEN 0 THEN P.CmpId ELSE @Pi_CmpId END AND P.PrdStatus=1 AND P.PrdType NOT IN (3,4) AND    
		PCV.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN P.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END    
		AND P.PrdId NOT IN (SELECT PrdId FROM ContractPricingDetails WHERE ContractId=@Pi_ContractId)    
	END 
END  
ELSE  
BEGIN  
	INSERT INTO @ContractDetails    
	(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP) 
	SELECT DISTINCT C.PrdCtgValMainId AS PrdId,C.PrdCtgValCode AS PrdDCode,
	C.PrdCtgValName AS PrdName,0 AS PrdBatId,'' AS PrdBatCode,0 AS PriceId,'' AS PriceCode,   
	ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc,
	ISNULL(A.ClaimablePercOnMRP,0) AS ClaimablePercOnMRP    
	FROM ProductCategoryValue C INNER JOIN ProductCategoryLevel G 
	ON C.CmpPrdCtgId=G.CmpPrdCtgId,ContractPricingDetails A WITH(NoLock),ContractPricingMaster E WITH(NoLock)
	WHERE  A.ContractId=E.ContractId AND C.PrdCtgValMainId=A.CtgValMainId AND
	C.CmpPrdCtgId = Case E.CmpPrdCtgId WHEN 0 THEN C.CmpPrdCtgId ELSE E.CmpPrdCtgId END  
	AND C.PrdCtgValMainId = A.CtgValMainId
	AND A.ContractId= @Pi_ContractId  AND E.DisplayMode=@Pi_Mode
	INSERT INTO @ContractDetails    
	(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)   
	SELECT DISTINCT PCV1.PrdCtgValMainId AS PrdId,PCV1.PrdCtgValCode AS PrdDCode,  
	PCV1.PrdCtgValName AS PrdName,0 AS PrdBatId, '' AS PrdBatCode,    
	0  AS PriceId,'' AS PriceCode,0 AS Discount,0 AS FlatAmtDisc,0    
	FROM ProductCategoryValue PCV WITH(NoLock)   
	INNER JOIN  ProductCategoryValue PCV1 WITH(NoLock) ON  PCV1.PrdCtgValLinkCode     
	LIKE CAST(PCV.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'     
	INNER JOIN ProductCategoryLevel PV WITH(NoLock) ON PV.CmpPrdCtgId=PCV.CmpPrdCtgId AND PV.CmpPrdCtgId=PCV1.CmpPrdCtgId  
	WHERE  PV.CmpId= CASE @Pi_CmpId WHEN 0 THEN PV.CmpId ELSE @Pi_CmpId END   
	AND PCV.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN PCV.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END    
	AND PV.CmpPrdCtgId = CASE @Pi_CmpPrdId WHEN 0 THEN PV.CmpPrdCtgId ELSE @Pi_CmpPrdId END  
	AND PV.CmpPrdCtgId NOT IN (SELECT CmpPrdCtgId FROM ContractPricingMaster WHERE ContractId=@Pi_ContractId AND DisplayMode=@Pi_Mode)    
	AND PCV.PrdCtgValMainId NOT IN (SELECT PrdCtgValMainId FROM ContractPricingMaster WHERE ContractId=@Pi_ContractId AND DisplayMode=@Pi_Mode)    
	AND PCV.PrdCtgValMainId NOT IN (SELECT CtgValMainId FROM ContractPricingDetails WHERE ContractId=@Pi_ContractId)    
END  
RETURN    
END
GO
--Select * from RptGroup where Rptid = 217
Delete from RptGroup where Rptid in(216,217)
GO
Insert into RptGroup (PId,RptId,GrpCode,GrpName)
Values ('DailyReports',217,'RetailerAccountStatement','Retailer Accounts Statement')
--select * from rptheader where rptid in (216,217)
Delete from Rptheader Where rptid in (216,217)
GO
Insert into Rptheader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
Values ('RetailerAccountStatement','Retailer Accounts Statement',217,'Retailer Accounts Statement','Proc_RptRetailerAccountStatement','RptRetailerAccountStatement','RptRetailerAccountStatement.rpt','')	
GO
--Select * from Rptdetails Where Rptid = 217 order by Rptid
Delete From Rptdetails where Rptid in (216,217)
GO
Insert into Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (217,1,'FromDate',-1,'','','From Date*','',1,'',10,1,1,'Enter From Date',0)
Insert into Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (217,2,'ToDate',-1,'','','To Date*','',1,'',11,1,1,'Enter To Date',0)
Insert into Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (217,3,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer*...','',1,'',3,1,1,'Press F4/Double Click to Select Retailer',0)
GO
--Select * from Rptformula where Rptid = 217
Delete From Rptformula where Rptid in (216,217)
GO
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	1,	'InvDate',	'Date',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	2,	'DocumentNo',	'Document No',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	3,	'Particulars',	'Particulars',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	4,	'ReferenceNo',	'Reference No',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	5,	'DebitAmt',	'Debit Amt',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	6,	'CreditAmt',	'Credit Amt',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	7,	'BalanceAmt',	'Balance Amt',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	8,	'RetailerName',	'Retailer Name',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	9,	'RetailerAddress',	'Retailer Address',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	10,	'VATTINNo',	'VAT/TINNo',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	11,	'Period',	'Period',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	12,	'Dis_FromDate',	'FromDate',	1,	10)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	13,	'Dis_ToDate',	'ToDate',	1,	11)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	14,	'Cap_UserName',	'User Name',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	15,	'Cap_PrintDate',	'Date',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	16,	'Cap_To',	'to',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	17,	'RtrCode',	'Retailer Code',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	18,	'PhNo',	'Ph-',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	19,	'RetailerCode',	'Retailer Code',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	217,	20,	'PhoneNo',	'Ph-',	1,	0)
GO
--Select * from RptExcelheaders where rptid = 216
Delete from RptExcelheaders where Rptid in (216,217)
GO
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	1,	'SlNo',	'SlNo',	0,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	2,	'RtrId',	'RtrId',	0,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	3,	'CoaId',	'CoaId',	0,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	4,	'RtrName',	'RtrName',	0,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	5,	'RtrAddress',	'RtrAddress',	0,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	6,	'RtrTINNo',	'RtrTINNo',	0,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	7,	'InvDate',	'Date',	1,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	8,	'DocumentNo',	'Document No',	1,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	9,	'Details',	'Particulars',	1,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	10,	'RefNo',	'Reference No',	1,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	11,	'DbAmount',	'Debit Amt',	1,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	12,	'CrAmount',	'Credit Amt',	1,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	13,	'BalanceAmount',	'Balance Amt',	1,	1)
Insert into RptExcelheaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	217,	15,	'RtrTINNo',	'UOM4',	0,	1)
GO
--Select * from RptGroup where Rptid = 168
Delete from RptGroup Where Rptid = 168
GO
Insert into RptGroup (PId,RptId,GrpCode,GrpName)
Values ('CollectionReports',168,'RptSalesRegisterReport','Billwise Collection Summary Report')
--Select * from rptheader where rptid = 168 
Delete from Rptheader where Rptid = 168
GO
Insert into Rptheader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
Values ('Billwise Collection Summary Report','Billwise Collection Summary Report',168,'Billwise Collection Summary Report','Proc_RptSalesReport','RptSalesReport','RptBillwiseCollectionSummaryReport.rpt','')	
Delete From RptDetails where Rptid = 168
GO
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	1,	'FromDate',	-1,	' ',	' ',	'From Date*...',	NULL,	1,	NULL,	10,	NULL,	1,	'Enter From Date',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	2,	'ToDate',	-1,	' ',	' ',	'To Date*...',	NULL,	1,	NULL,	11,	NULL,	1,	'Enter To Date',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	3,	'SalesInvoice',	-1,	NULL,	'SalId,SalInvRef,SalInvNo',	'From Bill No...',	NULL,	1,	NULL,	14,	1,	0,	'Press F4/Double Click to select From Bill',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	4,	'SalesInvoice',	-1,	NULL,	'SalId,SalInvRef,SalInvNo',	'To Bill No...',	NULL,	1,	NULL,	15,	1,	0,	'Press F4/Double Click to select To Bill',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	5,	'Company',	-1,	NULL,	'CmpId,CmpCode,CmpName',	'Company...',	NULL,	1,	NULL,	4,	1,	NULL,	'Press F4/Double Click to select Company',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	6,	'SalesMan',	-1,	NULL,	'SMId,SMCode,SMName',	'SalesMan...',	NULL,	1,	NULL,	1,	0,	0,	'Press F4/Double Click to select Salesman',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	7,	'RouteMaster',	-1,	NULL,	'RMId,RMCode,RMName',	'Route...',	NULL,	1,	NULL,	2,	NULL,	NULL,	'Press F4/Double Click to select Route',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	8,	'RetailerCategoryLevel',	5,	'CmpId',	'CtgLevelId,CtgLevelName,CtgLevelName',	'Retailer Category Level...',	'Company',	1,	'CmpId',	29,	1,	NULL,	'Press F4/Double Click to select Retailer Category Level',	1)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	9,	'RetailerCategory',	8,	'CtgLevelId',	'CtgMainId,CtgName,CtgName',	'Retailer Category Level Value...',	'RetailerCategoryLevel',	1,	'CtgLevelId',	30,	1,	NULL,	'Press F4/Double Click to select Retailer Category Level Value',	1)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	12,	'Retailer',	-1,	NULL,	'RtrId,RtrCode,RtrName',	'Retailer...',	NULL,	1,	NULL,	3,	NULL,	NULL,	'Press F4/Double Click to select Retailer',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	13,	'RptFilter',	-2,	NULL,	'FilterId,FilterDesc,FilterDesc',	'Include PDC..*',	NULL,	1,	NULL,	223,	1,	1,	'Press F4/Double Click to select PDC',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	10,	'RetailerValueClass',	9,	'CtgMainId',	'RtrClassId,ValueClassName,ValueClassName',	'Retailer Value Classification...',	'RetailerCategory',	1,	'CtgMainId',	31,	1,	NULL,	'Press F4/Double Click to select Retailer Value Classification',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	168,	11,	'Retailer',	-1,	NULL,	'RtrId,RtrCode,RtrName',	'Retailer Group...',	NULL,	1,	NULL,	215,	NULL,	NULL,	'Press F4/Double Click to select Retailer Group',	0)
Delete from RptFilter Where rptid =168
GO
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (168,223,1,'Yes')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (168,223,2,'No')
Delete from Rptformula Where Rptid = 168
GO
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	1,	'BillNo',	'Bill Number',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	2,	'BillDate',	'Bill Date',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	3,	'RtrCode',	'Retailer Code',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	4,	'RtrName',	'Retailer Name',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	5,	'GrossAmt',	'Gross Amount',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	6,	'SchDisc',	'Scheme Discount',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	7,	'Discount',	'Discount',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	8,	'TaxAmt',	'Tax Amount',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	9,	'BillAdj',	'Bill Adjustments',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	10,	'NetAmt',	'Net Amount',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	11,	'CashRec',	'Cash Receipt',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	13,	'CollAdjustment',	'Collection Adjustment',1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	14,	'Balance',	'Balance',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	15,	'ValFromBillNo',	'From Bill No',	1,	14)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	16,	'ValFromDate',	'From Date',	1,	10)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	17,	'ValRetailer',	'Retailer',	1,	3)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	18,	'ValRoute',	'Route',	1,	2)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	19,	'ValSalesman',	'Salesman',	1,	1)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	20,	'ValToBillNo',	'To Bill No',	1,	15)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	21,	'ValToDate',	'To Date',	1,	11)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	22,	'ValToCompany',	'Company',	1,	4)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	23,	'ValToRtrCatLvl',	'Retailer Category Level',	1,	29)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	24,	'ValToRtrCatLvlVal',	'Retailer Category Level Valur',	1,	30)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	25,	'ValToValClass',	'Retailer Value Classification',	1,	31)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	26,	'CapFromBillNo',	'From Bill No',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	27,	'CapFromDate',	'From Date',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	28,	'CapRetailer',	'Retailer',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	29,	'CapRoute',	'Route',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	30,	'CapSalesman',	'Salesman',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	31,	'CapToBillNo',	'To Bill No',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	32,	'CapToDate',	'To Date',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	33,	'Cap Page',	'Page',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	34,	'Cap User Name',	'User Name',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	35,	'Cap Print Date',	'Date',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	36,	'Total',	'Total',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	37,	'CatLevel',	'Retailer Category Level',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	38,	'CatVal',	'Retailer Category Level Value',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	39,	'ValClass',	'Retailer Value Classification',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	40,	'Cap_RetailerGroup',	'Retailer Group',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	41,	'Disp_RetailerGroup',	'Retailer Group',	1,	215)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	43,	'Disp_Company',	'Company',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	44,	'Cap_PDC',	'PDC',	1,	0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	45,	'Disp_PDC',	'PDC',	1,	223)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	168,	12,	'ChequeRec',	'Cheque/DD/RTGS',	1,	0)
GO
Delete From RptExcelHeaders Where Rptid = 168
GO
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	1,	'Bill Number',	'Bill Number',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	2,	'Bill Date',	'Bill Date',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	3,	'Retailer Code',	'Retailer Code',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	4,	'Retailer Name',	'Retailer Name',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	5,	'Shipping Address',	'Shipping Address',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	6,	'RtrId',	'RtrId',	0,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	7,	'SMId',	'SMId',	0,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	8,	'RMId',	'RMId',	0,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	9,	'Gross Amount',	'Gross Amount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	10,	'Scheme Disc',	'Scheme Discount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	11,	'Discount',	'Discount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	12,	'Tax Amount',	'Tax Amount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	14,	'Net Amount',	'Net Amount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	13,	'Bill Adjustment',	'Bill Adjustment',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	15,	'Cash Receipt',	'Cash Receipt',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	16,	'Cheque Receipt',	'Cheque/DD Receipt',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	17,	'RTGS Receipt',	'RTGS Receipt',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	18,	'Adjustment',	'Collection Adjustment',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	168,	19,	'Balance',	'Balance',	1,	1)
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'U' And Name = 'RptSalesReportSubTab')
DROP TABLE RptSalesReportSubTab
GO
CREATE TABLE [dbo].[RptSalesReportSubTab](
	[SalId] [int] NOT NULL,
	[Bill Number] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Bill Date] [datetime] NOT NULL,
	[Retailer Code] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Retailer Name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RtrId] [int] NOT NULL,
	[SMId] [int] NOT NULL,
	[RMId] [int] NOT NULL,
	[Gross Amount] [numeric](18, 6) NOT NULL,
	[Market Return] [numeric](18, 6) NOT NULL,
	[Replacement] [numeric](18, 6) NOT NULL,
	[Sch Discount] [numeric](18, 6) NOT NULL,
	[Discount] [numeric](18, 6) NOT NULL,
	[Tax Amount] [numeric](18, 6) NOT NULL,
	[Net Amount] [numeric](18, 6) NOT NULL,
	[Bill Adjustments] [numeric](18, 6) NOT NULL,
	[CollCashAmt] [numeric](18, 2) NULL,
	[CollCheque] [numeric](18, 2) NULL,
	[CollCredit] [numeric](18, 2) NULL,
	[CollDebit] [numeric](18, 2) NULL,
	[CollOnAcc] [numeric](18, 2) NULL,
	[CollDisc] [numeric](18, 2) NULL,
	[CollDate] [datetime] NULL,
	[InvRcpMode] [int] NOT NULL,
	[Adjustment] [numeric](18, 2) NULL,
	) ON [PRIMARY]
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'U' And Name = 'RptBillWiseCollectionExcel')
DROP TABLE RptBillWiseCollectionExcel
GO
CREATE TABLE [dbo].[RptBillWiseCollectionExcel](
	[Bill Number] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Bill Date] [datetime] NULL,
	[Retailer Code] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Retailer Name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Shipping Address] [nvarchar](600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[SMID] [int] NULL,
	[RMID] [int] NULL,
	[Gross Amount] [numeric](38, 6) NULL,
	[Scheme Disc] [numeric](38, 6) NULL,
	[Discount] [numeric](38, 6) NULL,
	[Tax Amount] [numeric](38, 6) NULL,
	[Bill Adjustment] [numeric](38, 6) NULL,
	[Net Amount] [numeric](38, 6) NULL,
	[Cash Receipt] [numeric](38, 6) NULL,
	[Cheque Receipt] [numeric](38, 6) NULL,
	[Adjustment] [numeric](38, 6) NULL,
	[Balance] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_RptSalesReport')
DROP PROCEDURE Proc_RptSalesReport
GO
---- EXEC Proc_RptSalesReport 168,1,0,'dfs',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptSalesReport]
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
/****************************************************************************
* PROCEDURE  : Proc_RptSalesBillWise
* PURPOSE    : To Generate Sales Report
* CREATED BY : Aarthi
* CREATED ON : 14/09/2009
* MODIFICATION
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 30.09.2009	Thiruvengadam		Bug No:20725
* 17.12.2009    Panneerselvam.k		Added Vehicle and VehicleAllocation Filter
*****************************************************************************/
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
DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate	 	AS	DATETIME
DECLARE @FromBillNo AS  BIGINT
DECLARE @TOBillNo   AS  BIGINT
DECLARE @CmpId      AS  INT
DECLARE @SMId 		AS	INT
DECLARE @RMId	 	AS	INT
DECLARE @RtrId	 	AS	INT
DECLARE @CtgLevelId	AS 	INT
DECLARE @RtrClassId	AS 	INT
DECLARE @CtgMainId 	AS 	INT
--DECLARE @VehicleAllocId	AS	BIGINT
--DECLARE @VehicleId	AS	BIGINT
DECLARE @PDC	AS	INT
--Till Here
--Assgin Value for the Filter Variable
SET @FromDate	=(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate		= (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId		=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId		=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
SET @ToBillNo	=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
SET @CtgMainId	=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
SET @PDC		=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,223,@Pi_UsrId))
--SET @VehicleId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
--SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
--Till Here
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
CREATE TABLE #RptSalesReport
		(
	    [Bill Number]         NVARCHAR(50),
		[Bill Date]           DATETIME,
		[Retailer Code]       NVARCHAR(50),
		[Retailer Name]       NVARCHAR(100),
		[RtrId]				  INT,
		[SMID]				  INT,
		[RMId]				  INT,
		[Gross Amount]        NUMERIC (38,6),
		[Scheme Disc]         NUMERIC (38,6),
		[Discount]            NUMERIC (38,6),
		[Tax Amount]          NUMERIC (38,6),
		[Net Amount]		  NUMERIC (38,6),	
		[Bill Adjustment]     NUMERIC (38,6),
		[Cash Receipt]		  NUMERIC (38,6),
		[Cheque Receipt]	  NUMERIC (38,6),
--		[RTGS Receipt]	  NUMERIC (38,6),
		[Adjustment]          NUMERIC (38,6),
		[Balance]             NUMERIC (38,6)
)
SET @TblName = 'RptSalesReportSubTab'
SET @TblStruct = '
	    [Bill Number]         NVARCHAR(50),
		[Bill Date]           DATETIME,
		[Retailer Code]       NVARCHAR(50),
		[Retailer Name]       NVARCHAR(100),
		[RtrId]				  INT,
		[SMID]				  INT,
		[RMId]				  INT,
		[Gross Amount]        NUMERIC (38,6),
		[Scheme Disc]         NUMERIC (38,6),
		[Discount]            NUMERIC (38,6),
		[Tax Amount]          NUMERIC (38,6),
		[Net Amount]		  NUMERIC (38,6),	
		[Bill Adjustment]     NUMERIC (38,6),
		[Cash Receipt]		  NUMERIC (38,6),
		[Cheque Receipt]	  NUMERIC (38,6),
		[Adjustment]          NUMERIC (38,6),
		[Balance]             NUMERIC (38,6)'
SET @TblFields = '[Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
		[RtrId],[SMID],[RMId],[Gross Amount],[Scheme Disc],[Discount],[Tax Amount],
		[Net Amount],[Bill Adjustment],[Cash Receipt],[Cheque Receipt],[Adjustment],[Balance]'
EXEC [Proc_SalesReport] 1	
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
	
	IF @PDC=1
	BEGIN
		IF @FromBillNo <> 0 AND @TOBillNo <> 0
		BEGIN
			INSERT INTO #RptSalesReport([Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
						[RtrId],[SMID],[RMId],[Gross Amount],[Scheme Disc],[Discount],[Tax Amount],
						[Net Amount],[Bill Adjustment],[Cash Receipt],[Cheque Receipt],[Adjustment],[Balance])
			SELECT DISTINCT
					[Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
					A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Sch Discount],[Discount],[Tax Amount],
					[Net Amount],[Bill Adjustments],SUM([CollCashAmt])AS[Cash Receipt],(SUM([CollCheque])) AS [Cheque Receipt],
					SUM([Adjustment]) AS [Adjustment],
					[Net Amount]-(SUM([CollCashAmt]))-(SUM([CollCheque]))+SUM([Adjustment]) AS [Balance]
			FROM RptSalesReportSubTab A
						INNER JOIN (
							SELECT DISTINCT 
									R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),
									RetailerValueClass RVC WITH (NOLOCK),RetailerCategory RC WITH (NOLOCK),
									RetailerCategoryLevel RCL WITH (NOLOCK)
									WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
									AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
									AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
									RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
									AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
									RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
									AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
									RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
									AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
									RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
											)X On  X.Rtrid=A.RTRId		
				 WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				 AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
							RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							
				 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
				 AND ([Bill Date] Between @FromDate and @ToDate)
		
				 AND (SalId Between @FromBillNo and @TOBillNo)
--				AND (VehicleId=(CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
--									VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)))
--				AND (AllotmentId=(CASE @VehicleAllocId WHEN 0 THEN AllotmentId ELSE 0 END) OR
--									AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)))
			GROUP BY	[Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
						A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Sch Discount],[Discount],[Tax Amount],
						[Net Amount],[Bill Adjustments],[Net Amount]
		END
		ELSE
		BEGIN
			INSERT INTO #RptSalesReport([Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
							A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Scheme Disc],[Discount],[Tax Amount],
							[Net Amount],[Bill Adjustment],[Cash Receipt],[Cheque Receipt],[Adjustment],[Balance])
			SELECT DISTINCT
						[Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
						A.[RtrId],[SMID],[RMId],[Gross Amount],[Sch Discount],[Discount],[Tax Amount],
						[Net Amount],[Bill Adjustments],SUM([CollCashAmt]) AS [Cash Receipt],(SUM([CollCheque])) AS [Cheque Receipt],
						SUM([Adjustment])AS [Adjustment],
						[Net Amount]-(SUM([CollCashAmt]))-(SUM([CollCheque]))+SUM([Adjustment]) AS [Balance]
			FROM RptSalesReportSubTab A
			INNER JOIN (
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
						AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
						RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
								)X On  X.Rtrid=A.RTRId			
				 WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
							
				 AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
							RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				 AND ([Bill Date] Between @FromDate and @ToDate)
--				 AND (VehicleId=(CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
--									VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)))
--				 AND (AllotmentId=(CASE @VehicleAllocId WHEN 0 THEN AllotmentId ELSE 0 END) OR
--									AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)))
				GROUP BY [Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
						A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Sch Discount],[Discount],[Tax Amount],
						[Net Amount],[Bill Adjustments],[Net Amount]
		END
	END
	ELSE IF @PDC=2
	BEGIN
		IF @FromBillNo <> 0 AND @TOBillNo <> 0
		BEGIN
			INSERT INTO #RptSalesReport([Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
					A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Scheme Disc],[Discount],[Tax Amount],
					[Net Amount],[Bill Adjustment],[Cash Receipt],[Cheque Receipt],[Adjustment],[Balance])
			SELECT DISTINCT
					[Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
					A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Sch Discount],[Discount],[Tax Amount],
					[Net Amount],[Bill Adjustments],SUM([CollCashAmt])AS[Cash Receipt],(SUM([CollCheque])) AS [Cheque Receipt],
					SUM([Adjustment])AS [Adjustment],
					[Net Amount]-(SUM([CollCashAmt]))-(SUM([CollCheque]))+SUM([Adjustment]) AS [Balance]
			FROM RptSalesReportSubTab A
					INNER JOIN (
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
					AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
					RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
							)X On  X.Rtrid=A.RTRId		
			WHERE A.CollDate<=GETDATE() AND
				(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				 AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
							RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							
				 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
				 AND ([Bill Date] Between @FromDate and @ToDate)
		
				 AND (SalId Between @FromBillNo and @TOBillNo)
				
--				AND (VehicleId=(CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
--									VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)))
--				AND (AllotmentId=(CASE @VehicleAllocId WHEN 0 THEN AllotmentId ELSE 0 END) OR
--									AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)))
			GROUP BY [Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
					A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Sch Discount],[Discount],[Tax Amount],
					[Net Amount],[Bill Adjustments],[Net Amount]
		END
		ELSE
		BEGIN
			INSERT INTO #RptSalesReport([Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
					A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Scheme Disc],[Discount],[Tax Amount],
					[Net Amount],[Bill Adjustment],[Cash Receipt],[Cheque Receipt],[Adjustment],[Balance])
			SELECT DISTINCT
					[Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
					A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Sch Discount],[Discount],[Tax Amount],
					[Net Amount],[Bill Adjustments],SUM([CollCashAmt])AS[Cash Receipt],(SUM([CollCheque])) AS [Cheque Receipt],
					SUM([Adjustment])AS [Adjustment],
					[Net Amount]-(SUM([CollCashAmt]))-(SUM([CollCheque]))+SUM([Adjustment]) AS [Balance]
			FROM RptSalesReportSubTab A
					INNER JOIN (
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
					AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR 					RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
							)X On  X.Rtrid=A.RTRId			
			WHERE A.CollDate<=GETDATE() AND
				(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))			
				AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
							RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND ([Bill Date] Between @FromDate and @ToDate)
--				AND (VehicleId=(CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
--									VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)))
--				AND (AllotmentId=(CASE @VehicleAllocId WHEN 0 THEN AllotmentId ELSE 0 END) OR
--									AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)))
			GROUP BY [Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
				A.[RtrId],A.[SMID],A.[RMId],[Gross Amount],[Sch Discount],[Discount],[Tax Amount],
				[Net Amount],[Bill Adjustments],[Net Amount]
		END
	END
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptSalesReport ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
			
			'WHERE (RtrId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))
					
			AND (RMId=(CASE ' + CAST(@RMId AS INTEGER) + ' WHEN 0 THEN RMId ELSE 0 END) OR
								RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) +')))
								
			AND (SMId=(CASE '+ CAST(@SMId AS INTEGER) + 'WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) + ')))
			AND ([Bill Date] Between ' + @FromDate +' and ' + @ToDate + ')
			AND (SalId Between ' + @FromBillNo +' and ' + @TOBillNo +')'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSalesReport'
	
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
		SET @SSQL = 'INSERT INTO #RptSalesReport ' +
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSalesReport
-- Till Here
	DECLARE @ExcelFlag INT
	SELECT @ExcelFlag = Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @ExcelFlag = 1
	BEGIN
		DELETE FROM RptBillWiseCollectionExcel
		INSERT INTO RptBillWiseCollectionExcel
		SELECT 
				[Bill Number],[Bill Date],[Retailer Code],[Retailer Name],
				(RtrShipAdd1+' --> '+RtrShipAdd2+' --> '+RtrShipAdd3),A.[RtrId],
				A.SMID,A.RMID,[Gross Amount],[Scheme Disc],[Discount],[Tax Amount],
				[Bill Adjustment],[Net Amount],
				[Cash Receipt],([Cheque Receipt]) [Cheque Receipt],Adjustment,Balance
		FROM 
				#RptSalesReport A 
				INNER JOIN RetailerShipAdd B ON A.RtrId=B.RtrId
				INNER JOIN SalesInvoice SI ON  SI.SalInvNo = [Bill Number]	
											  and A.[RtrId]   = SI.RtrId AND SI.RtrShipId = B.RtrShipId					
		ORDER BY [Bill Number]			
	END
	SELECT * FROM #RptSalesReport ORDER BY [Bill Number]
RETURN
END
GO
--Select * from RptGroup where Rptid = 183
Delete from RptGroup Where Rptid = 183
GO
Insert into RptGroup (PId,RptId,GrpCode,GrpName)
Values ('DailyReports',183,'BillWiseProductWiseSales','BillWise ProductWise Sales Report')
--Select * from rptheader where rptid = 183 
Delete from Rptheader where Rptid = 183
GO
Insert into Rptheader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
Values ('BillWiseProductWiseSales','BillWise ProductWise Sales Report',183,'BillWise ProductWise Sales Report','Proc_RptBillWisePrdWiseOutPut','RptBillWisePrdWise','RptBillWisePrdWise',' ')	

--Select * from RptDetails where rptid = 183
Delete From RptDetails where Rptid = 183
GO
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	183,1,'FromDate',-1,NULL,' ','From Date*...',NULL,1,NULL,10,NULL,1,'Enter From Date',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	183,3,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company...',NULL,1,NULL,4,1,NULL,'Press F4/Double Click to select Company',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,7,'RetailerValueClass',6,'CtgMainId','RtrClassId,ValueClassName,ValueClassName','Value Clasification...','RetailerCategory',1,'CtgMainId',31,1,NULL,'Press F4/Double Click to select Value Clasification',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	183,11,'ProductBatch',-1,NULL,'PrdBatId,PrdBatCode,PrdBatCode','Batch...',NULL,1,NULL,7,NULL,NULL,'Press F4/Double Click to select Batch',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,12,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','Bill No...',NULL,1,NULL,14,NULL,NULL,'Press F4/Double Click to select Bill No',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,4,'Location',-1,NULL,'LcnId,LcnCode,LcnName','Location...',NULL,1,NULL,22,NULL,NULL,'Press F4/Double Click to select Company',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,2,'ToDate',-1,NULL,' ','To Date*',NULL,1,NULL,11,NULL,NULL,'Enter To Date',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,5,'RetailerCategoryLevel',3,'CmpId','CtgLevelId,CtgLevelName,CtgLevelName','Category Level...','Company',1,'CmpId',29,1,NULL,'Press F4/Double Click to Category Level',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,8,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierachy Level...','Company',1,'CmpId',16,1,NULL,'Press F4/Double Click to select Product Hierachy Level',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,9,'ProductCategoryValue',8,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierachy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,NULL,NULL,'Press F4/Double Click to select Product Hierachy Level Value',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,13,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Display Quantity Breakup*...',NULL,1,NULL,240,1,1,'Press F4/Double Click to Quantity Breakup',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,14,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Display Tax Breakup*...',NULL,1,NULL,241,1,1,'Press F4/Double Click to select Tax Breakup',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,16,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Display Cancelled Bills*...',NULL,1,NULL,243,1,1,'Press F4/Double Click to select Cancelled Bills',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,6,'RetailerCategory',5,'CtgLevelId','CtgMainId,CtgName,CtgName','Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,1,NULL,'Press F4/Double Click to Category Level Value',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,10,'Product',9,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,NULL,NULL,'Press F4/Double Click to select Product',0)

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(183,15,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Display Discount Breakup*...',NULL,1,NULL,242,1,1,'Press F4/Double Click to select Discount Breakup',0)

--Select * from RptFilter Where rptid =183
Delete from RptFilter Where rptid =183
GO
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (183,240,1,'Yes')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (183,240,2,'No')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (183,241,1,'Yes')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (183,241,2,'No')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (183,242,1,'Yes')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (183,242,2,'No')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (183,243,1,'Yes')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
VALUES (183,243,2,'No')
GO
--Select * from Rptformula Where Rptid = 183
Delete from Rptformula Where Rptid = 183
GO
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,1,'FromDate','From Date',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,2,'ToDate','To Date',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,3,'Company','Company',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,4,'Location','Location',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,5,'CatLevel','Category Level',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,6,'CatValue','Category Level Value',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,7,'ValClass','Value Clasification',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,8,'PrdLevel','Product Hierarchy Level',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,9,'ProductCategoryValue','Product Hierarchy Level Value',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,10,'ProductName','Product Name',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,11,'Batch','Batch Code',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,12,'BillNo','Bill No',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,13,'DisQty','Display Quantity Breakup',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,14,'DisTax','Display Tax Breakup',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,15,'DisDiscount','Display Discount Breakup',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,16,'DisBills','Display Cancelled Bills',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,17,'CapPrintDate','Print Date',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,18,'CapUserName','User Name',1,0)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,19,'Dis_FromDate','01-01-2011',1,10)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,20,'is_ToDate','13-01-2011',1,11)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,21,'Dis_Company','Henkel Marketing India Ltd.',1,4)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,22,'Dis_Location','Main Godown',1,22)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,23,'Disp_ValueClassification','ALL',1,31)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,24,'Disp_CategoryLevel','ALL',1,29)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,25,'Disp_CategoryLevelValue','ALL',1,30)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,26,'Dis_PrdLevel','ALL',1,	16)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,27,'Dis_PrdLvlValue','ALL',1,21)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,28,'Dis_Batch','ALL',1,7)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,29,'Dis_BillNo','ALL',1,14)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,30,'Dis_TaxBreakup','No',1,241)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,31,'Dis_DisBreakup',' ',1,242)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,32,'Dis_CancelledBill',' ',1,243)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,33,'Dis_Prdouct','MARGO   32 G (FW) (5)',1,5)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(183,34,'Dis_QtyBreakup',' ',1,240)

--Select * from RptExcelHeaders Where Rptid = 183
Delete From RptExcelHeaders Where Rptid = 183
GO
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	1,	'Bill Number',	'Bill Number',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	2,	'Bill Date',	'Bill Date',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	3,	'Retailer Code',	'Retailer Code',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	4,	'Retailer Name',	'Retailer Name',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	5,	'Shipping Address',	'Shipping Address',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	6,	'RtrId',	'RtrId',	0,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	7,	'SMId',	'SMId',	0,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	8,	'RMId',	'RMId',	0,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	9,	'Gross Amount',	'Gross Amount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	10,	'Scheme Disc',	'Scheme Discount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	11,	'Discount',	'Discount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	12,	'Tax Amount',	'Tax Amount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	14,	'Net Amount',	'Net Amount',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	13,	'Bill Adjustment',	'Bill Adjustment',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	15,	'Cash Receipt',	'Cash Receipt',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	16,	'Cheque Receipt',	'Cheque/DD Receipt',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	17,	'RTGS Receipt',	'RTGS Receipt',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	18,	'Adjustment',	'Collection Adjustment',	1,	1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(	183,	19,	'Balance',	'Balance',	1,	1)
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'U' And Name = 'RptBillWisePrdWiseTaxBreakup')
DROP TABLE RptBillWisePrdWiseTaxBreakup
GO
CREATE TABLE [dbo].[RptBillWisePrdWiseTaxBreakup](
	[SlNo] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[SalinvNo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Salid] [int] NULL,
	[Rtrid] [int] NULL,
	[RtrCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Lcnid] [int] NULL,
	[Cmpid] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[Prdid] [int] NULL,
	[Prdccode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Prdbatid] [int] NULL,
	[PrdBatCode] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Rate] [numeric](36, 4) NULL,
	[SalesQty] [int] NULL,
	[FreeQty] [int] NULL,
	[TotQty] [int] NULL,
	[GrossAmt] [numeric](36, 4) NULL,
	[SchemeAmt] [numeric](36, 4) NULL,
	[SplDiscount] [numeric](36, 4) NULL,
	[CashDiscount] [numeric](36, 4) NULL,
	[TotalDiscount] [numeric](36, 4) NULL,
	[TaxPer] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TaxAmount] [numeric](36, 4) NULL,
	[TotalTax] [numeric](36, 4) NULL,
	[NetAmount] [numeric](36, 4) NULL,
	[DiscBreakup] [int] NULL,
	[QtyBreakup] [int] NULL,
	[TaxBreakup] [int] NULL,
	[Usrid] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'U' And Name = 'RptWithOutTaxBreakup_Excel')
DROP TABLE RptWithOutTaxBreakup_Excel
GO
CREATE TABLE [dbo].[RptWithOutTaxBreakup_Excel](
	[Bill Date] [datetime] NULL,
	[Bill No] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Retailer Code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Retailer Name] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Name] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Batch Code] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Selling Rate] [numeric](36, 4) NULL,
	[Sales Qty] [int] NULL,
	[Offer Qty] [int] NULL,
	[Total Qty] [int] NULL,
	[Gross Amt] [numeric](36, 4) NULL,
	[Scheme Amt] [numeric](36, 4) NULL,
	[SplDiscount] [numeric](36, 4) NULL,
	[Cash Discount] [numeric](36, 4) NULL,
	[Total Discount] [numeric](36, 4) NULL,
	[Total Tax Amount] [numeric](36, 4) NULL,
	[NetAmount] [numeric](36, 4) NULL
) ON [PRIMARY]
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_RptBillWisePrdWiseOutPut')
DROP PROCEDURE Proc_RptBillWisePrdWiseOutPut
GO
 -- exec [Proc_RptBillWisePrdWiseOutPut] 183,2,0,'Henkel',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptBillWisePrdWiseOutPut]
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
* PROCEDURE : [Proc_RptBillWisePrdWiseOutPut]
* PURPOSE : To get the Product details
* CREATED BY : Murugan.R
* CREATED DATE : 30/09/2009
* NOTE  :
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*************************************************************/
BEGIN
SET NOCOUNT ON
DECLARE @NewSnapId  AS INT
DECLARE @DBNAME  AS  NVARCHAR(50)
DECLARE @TblName  AS NVARCHAR(500)
DECLARE @TblStruct  AS NVARCHAR(4000)
DECLARE @TblFields  AS NVARCHAR(4000)
DECLARE @sSql  AS  NVARCHAR(4000)
DECLARE @ErrNo   AS INT
DECLARE @PurDBName AS NVARCHAR(50)
DECLARE @FromDate AS DATETIME
DECLARE @ToDate   AS DATETIME
DECLARE @CmpId   AS INT
DECLARE @LcnId   AS INT
DECLARE @SMId   AS INT
DECLARE @RMId   AS INT
DECLARE @RtrId   AS INT
DECLARE @PrdCatId AS INT
DECLARE @PrdBatId AS INT
DECLARE @PrdId  AS INT
DECLARE @SalId   AS BIGINT
DECLARE @CancelValue AS INT
DECLARE @BillStatus AS INT
DECLARE @TaxBreakup AS INT	
DECLARE @DiscBreakup AS INT
DECLARE @QtyBreakup AS INT	
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
SET @PrdBatId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
SET @TaxBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,241,@Pi_UsrId))
EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
CREATE TABLE #RptWithOutTaxBreakup
	(
		SalInvDate datetime,
		SalinvNo Varchar(50),		
		RtrCode Varchar(50),
		RtrName VarChar(200),			
		Prdccode Varchar(50),
		PrdName Varchar(200),
		PrdBatCode Varchar(75),
		Rate Numeric(36,4),
		SalesQty Int,
		FreeQty Int,
		TotQty Int,
		GrossAmt Numeric(36,4),
		SchemeAmt Numeric(36,4),
		SplDiscount Numeric(36,4),
		CashDiscount Numeric(36,4),
		TotalDiscount Numeric(36,4),
		TotalTax Numeric(36,4),
		NetAmount Numeric(36,4),		
		DiscBreakup Int,
		QtyBreakup  Int,
		TaxBreakup Int
		
	)
	IF @TaxBreakup=2
	BEGIN
	 SET @TblName = 'RptBillWisePrdWiseTaxBreakup'
	
	 SET @TblStruct = 'SalInvDate datetime,
		SalinvNo Varchar(50),		
		RtrCode Varchar(50),
		RtrName VarChar(200),			
		Prdccode Varchar(50),
		PrdName Varchar(200),
		PrdBatCode Varchar(75),
		Rate Numeric(36,4),
		SalesQty Int,
		FreeQty Int,
		TotQty Int,
		GrossAmt Numeric(36,4),
		SchemeAmt Numeric(36,4),
		SplDiscount Numeric(36,4),
		CashDiscount Numeric(36,4),
		TotalDiscount Numeric(36,4),
		TotalTax Numeric(36,4),
		NetAmount Numeric(36,4),		
		DiscBreakup Int,
		QtyBreakup  Int,
		TaxBreakup Int'
	
	 SET @TblFields = 'SalInvDate,SalinvNo,RtrCode,RtrName,Prdccode,
		 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
		 SplDiscount,CashDiscount,TotalDiscount,TotalTax,NetAmount,DiscBreakup,QtyBreakup,TaxBreakup'
	END
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
EXEC Proc_RptBillWisePrdWise @Pi_RptId,@Pi_UsrId
SET @TaxBreakup=2	
SELECT DISTINCT @DiscBreakup=DiscBreakup FROM RptBillWisePrdWise WHERE UsrId=@Pi_UsrId
SELECT DISTINCT @QtyBreakup=QtyBreakup FROM RptBillWisePrdWise WHERE UsrId=@Pi_UsrId
INSERT INTO #RptWithOutTaxBreakup (SalInvDate,SalinvNo,RtrCode,RtrName,Prdccode,
		 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
		 SplDiscount,CashDiscount,TotalDiscount,TotalTax,NetAmount,DiscBreakup,QtyBreakup,TaxBreakup)
	SELECT SalInvDate,SalinvNo,RtrCode,RtrName,Prdccode,
		PrdName,PrdBatCode, dbo.Fn_ConvertCurrency(Rate,@Pi_CurrencyId),SalesQty,FreeQty,TotQty,
		dbo.Fn_ConvertCurrency(GrossAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(SchemeAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(SplDiscount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(TotalDiscount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(TotalTax,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId),DiscBreakup,QtyBreakup,TaxBreakup
FROM RptBillWisePrdWise
WHERE  UsrId=@Pi_UsrId
AND  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
AND
(LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
AND
(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
AND
(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR
PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
AND
(PrdBatId = (CASE @PrdBatId WHEN 0 THEN PrdBatId Else 0 END) OR
PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
IF LEN(@PurDBName) > 0
BEGIN
EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
SET @SSQL = 'INSERT INTO #RptWithOutTaxBreakup ' +
'(' + @TblFields + ')' +
' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
+ ' WHERE UsrId=' + CAST(@Pi_UsrId AS nVarchar(10)) + ''
+ 'AND  (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR '
+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
+ 'AND (PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
+ 'AND (PrdBatId = (CASE ' + CAST(@PrdBatId AS nVarchar(10)) + ' WHEN 0 THEN PrdBatId Else 0 END) OR '
+ 'PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(' +
+ CAST(@Pi_RptId AS nVarchar(10)) + ',7,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
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
' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptWithOutTaxBreakup'
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
SET @SSQL = 'INSERT INTO #RptWithOutTaxBreakup ' +
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
IF @TaxBreakup=2
BEGIN	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptWithOutTaxBreakup 	
END
DELETE FROM RptWithOutTaxBreakup_Excel
DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
IF EXISTS (SELECT *	FROM RptDataCount WHERE RptId=183 and RecCount>0)
BEGIN
--Excel Report
	DELETE FROM RptExcelHeaders Where RptId=@Pi_RptId
	INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)	
	SELECT @Pi_RptId,ColId ,Name,Name,1,1 FROM SYSCOLUMNS S WHERE Id In (Select Id From SysObjects where Xtype='U' and Name='RptWithOutTaxBreakup_Excel')	
	IF (@DiscBreakup=2 AND @QtyBreakup=2)
	BEGIN	
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN(9,10,13,14,15)	and RptId=@Pi_RptId			
	END	
	IF (@DiscBreakup=1  AND @QtyBreakup=2)
	BEGIN		
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN(9,10) and RptId=@Pi_RptId				
	END	
	IF (@DiscBreakup=2  AND @QtyBreakup=1)
	BEGIN		
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno  In(13,14,15) and RptId=@Pi_RptId
	END
INSERT INTO RptWithOutTaxBreakup_Excel([Bill Date],[Bill No],[Retailer Code],[Retailer Name],[Product Code],[Product Name],
				[Batch Code],[Selling Rate],[Sales Qty],[Offer Qty],[Total Qty],[Gross Amt],[Scheme Amt],[SplDiscount],
				[Cash Discount],[Total Discount],[Total Tax Amount],[NetAmount ])
SELECT SalInvDate,SalinvNo,RtrCode,RtrName,Prdccode,
		 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
		 SplDiscount,CashDiscount,TotalDiscount,TotalTax,NetAmount from #RptWithOutTaxBreakup
SELECT * FROM RptWithOutTaxBreakup_Excel
--End
	--Grid Report
	
	DELETE FROM SpreadDisplayColumns WHERE MasterId=@Pi_RptId
	INSERT INTO SpreadDisplayColumns
	select @Pi_RptId,
	(select count(*) from RptExcelHeaders where slno <= t.slno and DisplayFlag=1 and RptId=@Pi_RptId),
	FieldName,1,1,1,GetDate(),1,Getdate() from RptExcelHeaders t where RptId=@Pi_RptId and DisplayFlag=1
	order by slno
	
	DECLARE @ColName as Varchar(4000)
	DECLARE @ColName1 as Varchar(4000)
	DECLARE @Gsql as Varchar(8000)
	DECLARE @Colcnt as INT
	SET @ColName=''
	SET @ColName1=''
	SELECT @ColName=@ColName+'['+ColumnName +'],'  FROM SpreadDisplayColumns WHERe MasterId=@Pi_RptId
	SELECT @Colcnt=Count(*) FROM SpreadDisplayColumns S WHERE MasterId=@Pi_RptId
	SET @ColName=SUBSTRING(@ColName,1,Len(@ColName)-1)
	SELECT @ColName1=@ColName1+'['+Name +'],' FROM SYSCOLUMNS S WHERE Id In (Select Id From SysObjects where Xtype='U' and Name='RptColvalues') and ColId<=@Colcnt
	SET @ColName1=SUBSTRING(@ColName1,1,Len(@ColName1)-1)
	SET @Gsql= 'INSERT INTO RptColvalues ( '+@ColName1+',Rptid,Usrid)
	SELECT '+@ColName+ ','+
	CAST(@Pi_RptId AS nVarchar(10))+','+ CAST(@Pi_UsrId AS nVarchar(10)) +'FROM RptWithOutTaxBreakup_Excel Order By [Bill Date],[Bill No]'
	EXEC (@Gsql)
--END Grid Report
END
RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBillSchemeDetails]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBillSchemeDetails]
GO
CREATE  FUNCTION dbo.Fn_ReturnBillSchemeDetails (@Pi_UserId AS INT,@Pi_TransId AS INT)
RETURNS @ReturnBillSchemeDetails TABLE
	(
		SchId			INT,
		SchCode			VARCHAR(50),
		FlexiSch		INT,
		FlexiSchType	INT,
		SlabId			INT,
        SchemeAmount	NUMERIC(18,6),
		SchemeDiscount	NUMERIC(18,2),
		Points			INT,
		FlxDisc			INT,
        FlxValueDisc	INT,
		FlxFreePrd		INT,
		FlxGiftPrd		INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
        FreeToBeGiven	INT,
		EditScheme		INT,
		NoOfTimes		NUMERIC(18,6),
		Usrid			INT,
		FlxPoints		INT,
        GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftToBeGiven	INT,
		SchType			INT
	)
AS
/*********************************
* FUNCTION: Fn_ReturnBillSchemeDetails
* PURPOSE: Return Billed Scheme Details
* NOTES:
* CREATED: Boopathy.P 0n 14/07/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 06-08-2011 Boopathy.P Wrongly added prdbatid in Group by
*********************************/
BEGIN
		INSERT INTO @ReturnBillSchemeDetails
		SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=1 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount --ORDER BY A.SchId Asc,A.SlabId Asc
		UNION ALL
		SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset)=0 
		AND B.CombiSch=0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId 
		UNION ALL
		SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=0 AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset) >0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId,A.PrdBatId ORDER BY A.SchId Asc,A.SlabId Asc
RETURN
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_GR_RetailerWiseBillWiseTax')
DROP PROCEDURE Proc_GR_RetailerWiseBillWiseTax
GO
--Exec Proc_GR_RetailerWiseBillWiseTax '','','',0,0,0,0,0,0
CREATE PROCEDURE [dbo].[Proc_GR_RetailerWiseBillWiseTax]
(  
	 @Pi_RptName  NVARCHAR(100),  
	 @Pi_FromDate DATETIME,  
	 @Pi_ToDate   DATETIME,  
	 @Pi_Filter1  NVARCHAR(100),  
	 @Pi_Filter2  NVARCHAR(100),  
	 @Pi_Filter3  NVARCHAR(100),  
	 @Pi_Filter4  NVARCHAR(100),  
	 @Pi_Filter5  NVARCHAR(100),  
	 @Pi_Filter6  NVARCHAR(100)  
)  
AS   
BEGIN  
  SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'          
  SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'          
  SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'          
  SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'          
  SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'    
  SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'
PRINT @Pi_FILTER1
--DELETE FROM RptRetailerWiseTax
DELETE FROM TempRetialerWiseTax
--Taxable Amount for Sales  
 Insert INTO TempRetialerWiseTax (RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTinNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId)  
 Select distinct SI.SalInvNo AS RefNo,SI.SalInvDate as InvDate,  
 R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo,
 'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(TaxableAmount) as TaxableAmount,  
 'Sales' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,SPT.TaxId 
 From SalesInvoice SI WITH (NOLOCK)  
 INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
 INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo  
 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = SI.RtrId   AND RtrName LIKE @Pi_FILTER4 
 INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = SI.SmId   AND SMName LIKE @Pi_FILTER2
 INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = SI.RmId  AND RMName LIKE @Pi_FILTER3  
 INNER JOIN Company C ON C.CmpId = SI.CmpId AND C.CmpId LIKE @Pi_FILTER1
 WHERE SI.DlvSts in (4,5) AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
 Group By TaxPerc,SI.SalInvDate,SI.SalInvNo,R.RtrId,SPT.TaxId,R.RtrCode,R.RtrName,r.RtrTINNo  
 Having Sum(TaxableAmount) > 0  AND sum(TaxAmount)>0
 --Tax Amount for Sales  
 Insert INTO TempRetialerWiseTax (RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTinNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId)  
 Select distinct  SI.SalInvNo AS RefNo,SI.SalInvDate as InvDate,  
 R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo, 
 'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(SPT.TaxAmount) as TaxableAmount,  
 'Sales' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,SPT.TaxId 
 From SalesInvoice SI WITH (NOLOCK)  
 INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
 INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo  
 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = SI.RtrId AND RtrName LIKE @Pi_FILTER4     
 INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = SI.SmId AND SMName LIKE @Pi_FILTER2  
 INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = SI.RmId  AND RMName LIKE @Pi_FILTER3   
 INNER JOIN Company C ON C.CmpId = SI.CmpId AND C.CmpId LIKE @Pi_FILTER1
 WHERE SI.DlvSts in (4,5) AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
 Group By TaxPerc,SI.SalInvDate,SI.SalInvNo,R.RtrId,SPT.TaxId ,R.RtrCode,R.RtrName,r.RtrTINNo  
 Having Sum(SPT.TaxAmount) > 0  AND Sum(spt.TaxableAmount) > 0
 --Taxable Amount for SalesReturn  
 Insert INTO TempRetialerWiseTax (RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTinNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId)  
 SELECT RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTINNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId FROM (  
  Select distinct RH.ReturnCode AS RefNo,Rh.ReturnDate as InvDate,  
  R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo,  
  'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,1 * Sum(TaxableAmt) as TaxableAmount,  
  'SalesReturn' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId
  From ReturnHeader RH WITH (NOLOCK)  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId AND RtrName LIKE @Pi_FILTER4   
  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId AND SMName LIKE @Pi_FILTER2  
  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId AND RMName LIKE @Pi_FILTER3      
  WHERE RH.Status = 0 AND rh.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
  Group By TaxPerc,RH.ReturnDate,RH.ReturnCode,R.RtrId,RPT.TaxId ,R.RtrCode,R.RtrName,r.RtrTINNo 
  Having Sum(TaxableAmt) > 0 AND Sum(RPT.TaxAmt)>0
 UNION  
  Select distinct RH.ReturnCode AS RefNo,Rh.ReturnDate as InvDate,  
  R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo,  
  'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,1 * Sum(TaxableAmt) as TaxableAmount,  
  'SalesReturn' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId
  From ReturnHeader RH WITH (NOLOCK)  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId AND RtrName LIKE @Pi_FILTER4
  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId AND SMName LIKE @Pi_FILTER2    
  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId AND RMName LIKE @Pi_FILTER3      
  WHERE RH.Status = 0  AND rh.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
  Group By TaxPerc,RH.ReturnDate,RH.ReturnCode,R.RtrId,RPT.TaxId,R.RtrCode,R.RtrName,r.RtrTINNo  
  Having Sum(TaxableAmt) > 0  AND Sum(RPT.TaxAmt)>0
 ) A  
 --Tax Amount for SalesReturn  
 Insert INTO TempRetialerWiseTax (RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTinNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId)  
 SELECT RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTINNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId FROM  (  
  Select distinct RH.ReturnCode AS RefNo,Rh.ReturnDate as InvDate,  
  R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo,  
  'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,1 * Sum(RPT.TaxAmt) as TaxableAmount,  
  'SalesReturn' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId
  From ReturnHeader RH WITH (NOLOCK)  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId AND RtrName LIKE @Pi_FILTER4 
  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId AND SMName LIKE @Pi_FILTER2 
  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId AND RMName LIKE @Pi_FILTER3   
  WHERE RH.Status = 0   AND rh.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
  Group By TaxPerc,RH.ReturnDate,RH.ReturnCode,R.RtrId,RPT.TaxId,R.RtrCode,R.RtrName,r.RtrTINNo  
  Having Sum(RPT.TaxAmt) > 0  AND Sum(TaxableAmt) > 0
 UNION  
  Select distinct RH.ReturnCode AS RefNo,Rh.ReturnDate as InvDate,  
  R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo,
 'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,1 * Sum(RPT.TaxAmt) as TaxableAmount,  
  'SalesReturn' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId
  From ReturnHeader RH WITH (NOLOCK)  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
  INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RP.PrdId    
  INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RP.PrdId AND PB.PrdBatId = RP.PrdBatId AND PB.PrdId = P.PrdId  
  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId AND RtrName LIKE @Pi_FILTER4  
  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId AND SMName LIKE @Pi_FILTER2 
  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId AND RMName LIKE @Pi_FILTER3   
  LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
  WHERE RH.Status = 0  AND rh.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
  Group By TaxPerc,RH.ReturnDate,RH.ReturnCode,R.RtrId,RPT.TaxId,R.RtrCode,R.RtrName,r.RtrTINNo   
  Having Sum(RPT.TaxAmt) > 0  AND Sum(TaxableAmt) > 0
 ) A  
--Credit Note TaxableAmount
 Insert INTO TempRetialerWiseTax (RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTinNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId)  
 Select distinct  C.CrNoteNumber AS RefNo,C.CrNoteDate as InvDate,  
 R.RtrId AS RtrId ,R.RtrCode,R.RtrName,r.RtrTINNo,
 'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(GrossAmt) as TaxableAmount,  
 'Credit' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,CT.TaxId   
 From CreditNoteRetailer C WITH (NOLOCK)  
 INNER JOIN CrDbNoteTaxBreakUp CT ON C.CrNoteNumber=CT.RefNo
 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = C.RtrId AND RtrName LIKE @Pi_FILTER4  
 WHERE  c.Status=1  AND C.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
 Group By TaxPerc,C.CrNoteDate,C.CrNoteNumber,R.RtrId,ct.TaxId,R.RtrCode,R.RtrName,r.RtrTINNo  
 Having Sum(GrossAmt) > 0 AND  Sum(CT.TaxAmt)>0
--Credit Note TaxAmt
Insert INTO TempRetialerWiseTax (RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTinNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId)  
 Select distinct  C.CrNoteNumber  AS RefNo,C.CrNoteDate as InvDate,  
 R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo,
 'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(CT.TaxAmt) as TaxableAmount,  
 'Credit' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,CT.TaxId 
 FROM CreditNoteRetailer C WITH (NOLOCK)  
 INNER JOIN CrDbNoteTaxBreakUp CT ON C.CrNoteNumber=CT.RefNo
 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = C.RtrId AND RtrName LIKE @Pi_FILTER4  
 WHERE  c.Status=1  AND C.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
 Group By TaxPerc,C.CrNoteDate,C.CrNoteNumber,R.RtrId,ct.TaxId,R.RtrCode,R.RtrName,r.RtrTINNo  
 Having Sum(CT.TaxAmt) > 0  AND Sum(GrossAmt) > 0 
--Debit Note TaxableAmount
 Insert INTO TempRetialerWiseTax (RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTinNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId)  
 Select distinct C.DbNoteNumber AS RefNo,C.DbNoteDate as InvDate,  
 R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo,
 'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(GrossAmt) as TaxableAmount,  
 'Debit' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,CT.TaxId   
 FROM DebitNoteRetailer C WITH (NOLOCK)  
 INNER JOIN CrDbNoteTaxBreakUp CT ON C.DbNoteNumber=CT.RefNo
 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = C.RtrId AND RtrName LIKE @Pi_FILTER4 
 WHERE  c.Status=1 AND c.DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
 Group By TaxPerc,C.DbNoteDate,C.DbNoteNumber,R.RtrId,ct.TaxId ,R.RtrCode,R.RtrName,r.RtrTINNo 
 Having Sum(GrossAmt) > 0  AND Sum(CT.TaxAmt)>0
--Debit Note TaxAmt
Insert INTO TempRetialerWiseTax (RefNo,InvDate,RtrId,RtrCode,RtrName,RtrTinNo,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId)  
 Select distinct  C.DbNoteNumber  AS RefNo,C.DbNoteDate as InvDate,  
 R.RtrId AS RtrId,R.RtrCode,R.RtrName,r.RtrTINNo,
 'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(CT.TaxAmt) as TaxableAmount,  
 'Debit' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,CT.TaxId 
 FROM DebitNoteRetailer C WITH (NOLOCK)  
 INNER JOIN CrDbNoteTaxBreakUp CT ON C.DbNoteNumber=CT.RefNo
 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = C.RtrId AND RtrName LIKE @Pi_FILTER4 
 WHERE  c.Status=1  AND c.DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
 Group By TaxPerc,C.DbNoteDate,C.DbNoteNumber,R.RtrId,ct.TaxId ,R.RtrCode,R.RtrName,r.RtrTINNo 
 Having Sum(CT.TaxAmt) > 0  AND Sum(GrossAmt) > 0
 IF EXISTS (SELECT * FROM sysobjects where name='RptRetailerWiseTax'AND xtype='U' )
  DROP TABLE RptRetailerWiseTax
  CREATE TABLE RptRetailerWiseTax (Rtrid int,RetailerCode nvarchar(100),RetailerName NVARCHAR(200),TransactionRefNo NVARCHAR(100),TransactionDate DATETIME,RetailerTinNo NVARCHAR(100))  
  DECLARE  @TaxPerc   NVARCHAR(100)  
  DECLARE  @TaxableAmount NUMERIC(38,6)  
  DECLARE  @IOTaxType    NVARCHAR(100)  
  DECLARE  @SlNo INT    
  DECLARE  @TaxFlag      INT  
  DECLARE  @Column VARCHAR(80)  
  DECLARE  @C_SSQL VARCHAR(4000)  
  DECLARE  @RtrId INT  
  DECLARE  @RefNo NVARCHAR(100)  
  DECLARE  @Name   NVARCHAR(100)  
  DECLARE Column_Cur CURSOR FOR  
  SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM TempRetialerWiseTax ORDER BY TaxPercent ,TaxFlag  
  OPEN Column_Cur  
      FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='ALTER TABLE RptRetailerWiseTax  ADD ['+ @Column +'] NUMERIC(38,6)'  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag  
    END  
  CLOSE Column_Cur  
  DEALLOCATE Column_Cur  
DELETE FROM RptRetailerWiseTax  
INSERT INTO RptRetailerWiseTax(Rtrid,RetailerCode,RetailerName,TransactionRefNo,TransactionDate,RetailerTinNo)  
SELECT DISTINCT Rtrid,RtrCode,RtrName,RefNo,InvDate,RtrTinNo FROM TempRetialerWiseTax  
DECLARE Values_Cur CURSOR FOR  
  SELECT DISTINCT RefNo,RtrId,TaxPerc,TaxableAmount FROM TempRetialerWiseTax  
  OPEN Values_Cur  
      FETCH NEXT FROM Values_Cur INTO @RefNo,@RtrId,@TaxPerc,@TaxableAmount  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptRetailerWiseTax  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL+ ' WHERE  '
     +'   TransactionRefNo =''' + CAST(@RefNo AS VARCHAR(1000)) +''' AND  RtrId=' + CAST(@RtrId AS VARCHAR(1000))  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM Values_Cur INTO @RefNo,@RtrId,@TaxPerc,@TaxableAmount  
    END  
  CLOSE Values_Cur  
  DEALLOCATE Values_Cur  
  -- To Update the Null Value as 0  
  DECLARE NullCursor_Cur CURSOR FOR  
  SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptRetailerWiseTax]')  
  OPEN NullCursor_Cur  
      FETCH NEXT FROM NullCursor_Cur INTO @Name  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptRetailerWiseTax SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM NullCursor_Cur INTO @Name  
    END  
  CLOSE NullCursor_Cur  
  DEALLOCATE NullCursor_Cur  
SELECT * FROM RptRetailerWiseTax
END 
GO
IF EXISTS (Select * From Sysobjects where Xtype = 'P' And Name = 'Proc_GR_BillPrdSales')
DROP PROCEDURE Proc_GR_BillPrdSales
GO
CREATE PROCEDURE [dbo].[Proc_GR_BillPrdSales]
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
BEGIN
--EXEC Proc_GR_BillPrdSales 'Billwise Productwise Sales','2011-01-01','2011-03-22','ARUN KUMAR','IN C&B : Instant Tea - Retail','','','Old II',''
--EXEC Proc_GR_BillPrdSales 'Billwise Productwise Sales','2010-01-17','2010-05-17','','','','','',''
		SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'        
		SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'        
		SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'        
		SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'        
		SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'  
		SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'    
	SELECT a.*,HIERARCHY3CAP L1,HIERARCHY2CAP L2,HIERARCHY1CAP L3 INTO #SALINV FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D ,TBL_GR_BUILD_RH E
	WHERE SALINVDATE BETWEEN @PI_fROMDATE AND @PI_TODATE AND A.RMID=B.RMID AND B.RMNAME LIKE @PI_FILTER5 and
    C.SMID=A.SMID AND C.SMNAME LIKE @PI_FILTER1 AND A.SALINVNO LIKE @PI_FILTER3 AND A.RTRID=D.RTRID AND D.RTRNAME LIKE @PI_FILTER4 AND E.RTRID=D.RTRID AND E.HASHPRODUCTS LIKE @PI_FILTER6
    SELECT A.*,C.Brand_Caption INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID AND 	HASHPRODUCTS LIKE @PI_FILTER2 
	
	    
	SELECT				'Detail ' SheetCaption,Salesman.SMName AS Salesman, 
						 L1 [Retailer Hierarchy 1],
						L2 [Retailer Hieararchy 2],						 
						L3 [Retailer Hierarchy 3],
						 Retailer.RtrCode AS [Retailer Code],
						 Retailer.RtrName AS [Retailer Name],
						 Retailer.RtrAdd1 AS [Address 1],
						 #SALINV.SalInvNo AS [Sales Invoice Number],
						 CONVERT(VARCHAR(10),#SALINV.SalInvDate,121) AS [Sales Invoice Date],
						 CONVERT(VARCHAR(10),#SALINV.SalDlvDate,121) as [Actual Delivery Date],
						 CASE #SALINV.DlvSts  when 1 then 'Saved' 
											  when 2 then 'Vehicle Allocated' 
											  when 3 then 'Cancelled' 
											  when 4 then 'Delivered' 
											  when 5 then 'Fully Settled' 
						 end AS [Delivery Status], 
						 Product.PrdcCode as [Company Product Code],
                         #SALESINVOICEPRODUCT.Brand_Caption,
						 Product.PrdDCode AS [Dist. Product Code],
						 Product.PrdName AS [Product Name], 
						 'Batch '+ProductBatch.CmpBatCode AS Batch, 
						 #SALESINVOICEPRODUCT.PrdUnitMRP AS MRP, 
						 #SALESINVOICEPRODUCT.PrdUnitSelRate AS [Selling Rate],
						 CAST(#SALESINVOICEPRODUCT.BaseQty AS INT) AS [Quantity Billed],
						 #SALESINVOICEPRODUCT.PrdGrossAmount AS [Gross Amount], 
						 #SALESINVOICEPRODUCT.SplDiscAmount AS [Special Discount],
						 #SALESINVOICEPRODUCT.PrdSplDiscAmount AS [Product Special Discount], 
						 #SALESINVOICEPRODUCT.PrdSchDiscAmount AS [Product Scheme Discount],
						 #SALESINVOICEPRODUCT.PrdDBDiscAmount AS [Distributor Discount], 
						 #SALESINVOICEPRODUCT.PrdCDAmount AS [Cash Discount],
						 #SALESINVOICEPRODUCT.PrdTaxAmount AS [Tax Amount], 
						 #SALESINVOICEPRODUCT.PrdNetAmount AS [Net Amount]
	INTO #DETAIL FROM	  ProductBatch INNER JOIN
						  Product ON ProductBatch.PrdId = Product.PrdId
						  INNER JOIN #SALESINVOICEPRODUCT ON ProductBatch.PrdId = #SALESINVOICEPRODUCT.PrdId 
						  AND ProductBatch.PrdBatId = #SALESINVOICEPRODUCT.PrdBatId
						  AND Product.PrdId = #SALESINVOICEPRODUCT.PrdId
						  INNER JOIN #SALINV
						  INNER JOIN Salesman ON #SALINV.SMId = Salesman.SMId ON #SALESINVOICEPRODUCT.SalId = #SALINV.SalId
						  INNER JOIN Retailer ON #SALINV.RtrId = Retailer.RtrId
	INSERT INTO #DETAIL SELECT ' Detail','Totals','','','','','','','','','','','','','','','',0,0,isnull(sum([Quantity Billed]),0),isnull(SUM([Gross Amount]),0),isnull(SUM([Special Discount]),0),
						isnull(SUM([Product Special Discount]),0),isnull(Sum([Product Scheme Discount]),0),isnull(Sum([Distributor Discount]),0),isnull(Sum([Cash Discount]),0),isnull(Sum([Tax Amount]),0),
						isnull(Sum([Net Amount]),0)
	FROM #DETAIL
	SELECT * FROM #DETAIL ORDER BY SHEETCAPTION
	DELETE FROM #DETAIL WHERE SHEETCAPTION=' Detail'
	
	SELECT     			'Datewise-Productwise ' SheetCaption,	
						[Sales Invoice Date], 
						[Delivery Status], 
						[Company Product Code],
                        Brand_Caption,
						[Dist. Product Code],
						[Product Name], 
						Batch, 
						MRP, 
						[Selling Rate],
						SUM([Quantity Billed]) [Quantity Billed],
						SUM([Gross Amount]) [Gross Amount],
						SUM([Special Discount]) [Special Discount],
						SUM([Product Special Discount]) [Product Special Discount],
						SUM([Product Scheme Discount]) [Product Scheme Discount],
						SUM([Distributor Discount]) [Distributor Discount],
						SUM([Cash Discount]) [Cash Discount],
						SUM([Tax Amount]) [Tax Amount],
						SUM([Net Amount]) [Net Amount]
	INTO #DETAIL2		FROM #DETAIL
	GROUP BY			[Sales Invoice Date], 
						[Delivery Status], 
						[Company Product Code],
                        Brand_Caption,
						[Dist. Product Code],
						[Product Name], 
						Batch, 
						MRP, 
						[Selling Rate]
	INSERT INTO #DETAIL2 SELECT ' Datewise-Productwise','Totals','','','','','','',0,0,isnull(sum([Quantity Billed]),0),isnull(SUM([Gross Amount]),0),isnull(SUM([Special Discount]),0),
						isnull(SUM([Product Special Discount]),0),isnull(Sum([Product Scheme Discount]),0),isnull(Sum([Distributor Discount]),0),isnull(Sum([Cash Discount]),0),isnull(Sum([Tax Amount]),0),
						isnull(Sum([Net Amount]),0)
	FROM #DETAIL2
	SELECT				* FROM #DETAIL2 ORDER BY SHEETCAPTION
	
	SELECT     			'Product Summary ' SheetCaption,	
						[Delivery Status],
						[Company Product Code],
                        Brand_Caption,
						[Dist. Product Code],
						[Product Name], 
						Batch, 
						MRP, 
						[Selling Rate],
						SUM([Quantity Billed]) [Quantity Billed],
						SUM([Gross Amount]) [Gross Amount],
						SUM([Special Discount]) [Special Discount],
						SUM([Product Special Discount]) [Product Special Discount],
						SUM([Product Scheme Discount]) [Product Scheme Discount],
						SUM([Distributor Discount]) [Distributor Discount],
						SUM([Cash Discount]) [Cash Discount],
						SUM([Tax Amount]) [Tax Amount],
						SUM([Net Amount]) [Net Amount]
						FROM #DETAIL
	GROUP BY			
						[Delivery Status],
						[Company Product Code],
                        Brand_Caption,
						[Dist. Product Code],
						[Product Name], 
						Batch, 
						MRP, 
						[Selling Rate]
	UNION
	SELECT     			' Product Summary' SheetCaption,	
						' Totals',
						'',
						'',
						'', 
						'', 
                        '',
						0, 
						0,
						SUM([Quantity Billed]) [Quantity Billed],
						SUM([Gross Amount]) [Gross Amount],
						SUM([Special Discount]) [Special Discount],
						SUM([Product Special Discount]) [Product Special Discount],
						SUM([Product Scheme Discount]) [Product Scheme Discount],
						SUM([Distributor Discount]) [Distributor Discount],
						SUM([Cash Discount]) [Cash Discount],
						SUM([Tax Amount]) [Tax Amount],
						SUM([Net Amount]) [Net Amount]
						FROM #DETAIL 	ORDER BY SHEETCAPTION
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AutoDBCDCreation')
DROP PROCEDURE Proc_AutoDBCDCreation
GO
/*
BEGIN TRANSACTION
exec Proc_AutoDBCDCreation 'a','2011-09-05'
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_AutoDBCDCreation
(
	@Pi_RefNo		nVarchar(10),
	@Pi_TransDate   DATETIME 
)
AS

SET NOCOUNT ON
BEGIN

	DECLARE @Slabid AS int 
	DECLARE @CreditPeriod AS int 
	DECLARE @Discount AS numeric(18,6)
	DECLARE @salinvno AS varchar(50)
	DECLARE @salid AS int 
	DECLARE @SalCDPer AS numeric(18,6)
	DECLARE @CashDis AS numeric(18,6)
	DECLARE @DiffAmt AS numeric(18,6)
	DECLARE @CollectionAmt AS  numeric(18,6)
	DECLARE @CashDis1 AS numeric(18,6)
	DECLARE @Rtrid AS int
	DECLARE @DateDiff AS Int
	DECLARE @DebitCreditNo AS nvarchar(100)
	DECLARE @CrDbNoteDate AS DATETIME
	DECLARE @AccCoaId	AS INT
	DECLARE @DBCRRtrID AS Int 
	DECLARE @CRDBName AS nVarchar(20)
	DECLARE @CRDBSalid AS BigInt
	DECLARE @DBCRCollectionAmt numeric(28,6)
	DECLARE @DBCDRtrCode AS nVarchar(20)
	DECLARE @DBCDRtrName AS nVarchar(200)
	DECLARE @DBCDSalInvNo AS nVarchar(100)
	DECLARE @DBCDSalInvDate AS datetime 
	DECLARE @FindReasoId AS INT
	DECLARE @TobeCalAmt numeric(28,6)
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS Int 
	DECLARE @Slno AS INT
	DECLARE @Row AS INT 
	DECLARE @DiffIntAmt AS numeric(28,6)
	DECLARE @MaxTaxPerc AS numeric(15,6)
	DECLARE @MaxCRDVBPerc AS numeric(15,6)
	DECLARE @ErrStatus			INT
	DECLARE @FStatus AS INT
	DECLARE @MAxCreditPeriod AS INT
	DECLARE @MaxSlabid AS INT
	DECLARE @FFromDate AS datetime 	

-- To be commented
	TRUNCATE TABLE  RaiseCreditDebit
	TRUNCATE TABLE AutoRaisedCreditDebit
-- end here
	SET @DiffIntAmt=0
	SET @MaxTaxPerc=0

	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='DBCRNOTE15' AND Status=1)
		BEGIN 
			 SET @FStatus=1
		END 
    ELSE
		BEGIN 
			SET @FStatus=0
		END 

	SET @ErrStatus=1

	SELECT @FFromDate=FixedOn FROM HotFixLog WHERE FixId=387
	
	DECLARE cur_CreditSlab CURSOR
	FOR SELECT Slabid,CreditPeriod,Discount FROM AutoDbCrSlabConfig ORDER BY slabid
	OPEN cur_CreditSlab
	FETCH next FROM cur_CreditSlab INTO @Slabid,@CreditPeriod,@Discount
	WHILE @@Fetch_status=0
	BEGIN 
		SET @DiffIntAmt=0
		SET @MaxTaxPerc=0
		DECLARE cur_Salinvno CURSOR
		FOR SELECT salinvno,SalId,PrdId,PrdBatId,Slno,SalCDPer,(sum(ActPrdGross)-sum(OrgGrossAmt))DiffAmt,isnull(sum(OrgGrossAmt),0)CollectionAmt,Rtrid
			FROM (
				SELECT DISTINCT SIP.Slno,SIP.PrdId,sip.Prdbatid,salinvno,SI.SalId,SalCDPer,si.SalGrossAmount,A.SalInvAmt CollectionAmt,
					sum((PrdGrossAmount - ISnull(PrdGrossAmt,0))*(isnull(A.SalInvAmt,0)/(SalNetAmt))) OrgGrossAmt,SI.RtrId,sum(PrdGrossAmount) ActPrdGross
				FROM salesinvoice SI INNER JOIN salesinvoiceproduct SIP ON SI.salid=SIP.salid 
				LEFT OUTER JOIN (SELECT SalId,sum(SalInvAmt)SalInvAmt FROM ReceiptInvoice RI INNER JOIN Receipt R ON R.InvRcpNo=RI.InvRcpNo
			    WHERE datediff(day,RI.SalInvDate,R.InvRcpDate)<=@CreditPeriod 
			    GROUP BY SalId)A ON A.salid=SI.salid AND A.salid=SIP.SalId
			    LEFT OUTER JOIN (SELECT RH.Salid,RP.PrdId,Rp.PrdBatId,sum(PrdGrossAmt) PrdGrossAmt FROM ReturnHeader RH INNER JOIN ReturnProduct RP ON RH.returnid=RP.ReturnId
					GROUP BY RH.Salid,RP.PrdId,Rp.PrdBatId) B ON B.SalId=SI.SalId AND B.PrdId=SIP.PrdId AND B.PrdBatId=SIP.PrdBatId
			    WHERE DlvSts>=4  AND AutoDBCD=0 AND SalInvDate>=CONVERT(NVARCHAR(10),@FFromDate,121) --AND SI.SalId=6
			    GROUP BY SIP.Slno,SIP.PrdId,sip.Prdbatid,SI.SalId,SI.RtrId,SalCDPer,SalInvNo,si.SalGrossAmount,A.SalInvAmt,Rtrid)A
			    GROUP BY salinvno,SalId,PrdId,PrdBatId,Slno,SalCDPer,Rtrid
		OPEN cur_Salinvno
		FETCH next FROM cur_Salinvno INTO @salinvno,@salid,@PrdId,@PrdBatId,@Row,@SalCDPer,@DiffAmt,@CollectionAmt,@Rtrid
		WHILE @@Fetch_status=0
		BEGIN 
		SET @DiffIntAmt=0
		SET @MaxTaxPerc=0
		SELECT @DateDiff=datediff(day,Si.SalInvDate,isnull(InvRcpDate,getdate())) FROM Salesinvoice SI 
			LEFT OUTER JOIN (SELECT SalId,max(InvRcpDate) InvRcpDate FROM ReceiptInvoice RI INNER JOIN Receipt R ON R.InvRcpNo=RI.InvRcpNo GROUP BY SalId) B
			ON SI.SalId=B.SalId
			WHERE SI.SalId=@SalId
	   
		--SELECT @DateDiff,@CreditPeriod,@DiffAmt
		IF NOT EXISTS (SELECT * FROM AutoDBCDPrdSlabAchieved WHERE SalId=@salid AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND SlabId=@Slabid)
			BEGIN 
				IF @DateDiff>@CreditPeriod AND @DiffAmt>0
					BEGIN 
						INSERT INTO AutoDBCDPrdSlabAchieved
							SELECT @salid,@PrdId,@PrdBatId,@Slabid,@DiffAmt,@CollectionAmt

						IF 	@Slabid=1 
							BEGIN 		
								SELECT @CashDis=SalCDPer FROM salesinvoice WHERE SalId=@salid     
							END 
						ELSE 
							BEGIN
								SET @CashDis=0
							END 
						IF @CashDis=0
							BEGIN 
								IF exists (SELECT  * FROM salesinvoice WHERE SalCDPer>0 AND SalId=@salid)
									BEGIN 
										SET @CashDis1=@Discount-@CashDis

										SET @TobeCalAmt= ((@DiffAmt*@CashDis1)/100) 	

										--SELECT 'a',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
										IF @TobeCalAmt>=5
										BEGIN 
											IF @FStatus=1
												BEGIN 
													EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid							
													
													SELECT @DiffIntAmt= sum(TaxAmount) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													SELECT @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
												END
										END  
										INSERT INTO RaiseCreditDebit
										SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
									END 
								ELSE
									BEGIN 
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														--SELECT 'b1',@DiffAmt,@CashDis,@Row
														--SELECT 'b',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																	BEGIN
																		EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																		
																		SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																		SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
										ELSE
											BEGIN 
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid
												SET @CashDis=@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																BEGIN
																	EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																	
																	SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END
											END 
									END 
							END
						ELSE
							BEGIN 
								IF @CashDis-@Discount=0 
									BEGIN 
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1

												SET @TobeCalAmt= ((@DiffAmt*@CashDis)/100)
												--SELECT 'd',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @TobeCalAmt>=5
												BEGIN
													IF @FStatus=1
														BEGIN
															EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid

															SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
															SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														END 
												END 
												INSERT INTO RaiseCreditDebit
												SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
											END 
										ELSE
											BEGIN 

												SET @TobeCalAmt= ((@DiffAmt*@Discount)/100)
												--SELECT 'e',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @TobeCalAmt>=5
												BEGIN
												IF @FStatus=1
													BEGIN
														EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid

														SELECT  @DiffIntAmt=sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													END 
												END 
												INSERT INTO RaiseCreditDebit
												SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@Discount,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
											END 
									END 
								ELSE 
									BEGIN
										IF 	@CollectionAmt >0 
											BEGIN 
												SET @CashDis1=@Discount-@CashDis
												SET @TobeCalAmt= ((@CollectionAmt*@CashDis1)/100)
												--SELECT 'f',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
												IF @TobeCalAmt>=5
												BEGIN
												IF @FStatus=1
													BEGIN
														EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
														
														SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
														SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
													END 
												END 
													INSERT INTO RaiseCreditDebit
													SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc	
											END 	
										ELSE
											BEGIN 
												SELECT @MaxSlabid=max(Slabid) FROM AutoDbCrSlabConfig
												IF @Slabid = @MaxSlabid
													BEGIN 
														SELECT @CashDis1 = SalCDPer FROM salesinvoice WHERE SalCDPer>0 AND SalId=@salid
														SET @TobeCalAmt= ((@DiffAmt*@CashDis1)/100) 	
														--SELECT 'a',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																	BEGIN 
																		EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid							
																		
																		SELECT @DiffIntAmt= sum(TaxAmount) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																		SELECT @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Debit',@salid,@Rtrid,@TobeCalAmt,@CashDis1,@DiffAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
									END 
							END 
					END 	
				ELSE
					BEGIN 
						IF @DateDiff<=@CreditPeriod AND @CollectionAmt>0
							BEGIN 		
								IF NOT exists (SELECT  * FROM salesinvoice WHERE SalCDPer>0 AND SalId=@salid)
									BEGIN 
										INSERT INTO AutoDBCDPrdSlabAchieved
											SELECT @salid,@PrdId,@PrdBatId,@Slabid,@DiffAmt,@CollectionAmt
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														--SELECT 'b1',@DiffAmt,@CashDis,@Row
														--SELECT 'b',@salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																	BEGIN
																		EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																		
																		SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																		SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
										ELSE
											BEGIN 
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid
												SET @CashDis=@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @TobeCalAmt>=5
															BEGIN
															IF @FStatus=1
																BEGIN
																	EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																	
																	SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																END 
														END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END
											END 
									END 
								ELSE
									BEGIN 
										IF EXISTS (SELECT * FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1)
											BEGIN
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid+1
												SET @CashDis=@Discount-@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																	BEGIN
																		EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																		
																		SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																		SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END 
											END 
										ELSE
											BEGIN 
												SELECT @CashDis1=Discount FROM AutoDbCrSlabConfig WHERE slabid=@Slabid
												SET @CashDis=@CashDis1
												IF @CollectionAmt>0
													BEGIN 	
														SET @TobeCalAmt= ((@CollectionAmt*@CashDis)/100)
														IF @TobeCalAmt>=5
															BEGIN
																IF @FStatus=1
																BEGIN
																	EXEC Proc_AutoTAXDBCDCreation @salid,@PrdId,@PrdbatId,@Row,@TobeCalAmt,@Slabid
																	
																	SELECT  @DiffIntAmt= sum(TaxAmount)  FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																	SELECT  @MaxTaxPerc= max(MaxTaxPerc) FROM AutoDBCDProductTax  WHERE SalId=@salid AND PrdSlNo=@Row AND SlabId=@Slabid
																END 
															END 
														INSERT INTO RaiseCreditDebit
														SELECT 'Credit',@salid,@Rtrid,@TobeCalAmt,@CashDis,@CollectionAmt,@DiffIntAmt,@MaxTaxPerc
													END
											END 
									END
							END 
					END 
			END 
		SELECT @MAxCreditPeriod=CreditPeriod FROM AutoDbCrSlabConfig WHERE SlabId IN (SELECT max(Slabid) FROM AutoDbCrSlabConfig)
		IF @MAxCreditPeriod<@DateDiff
			BEGIN 
				IF NOT EXISTS (SELECT * FROM AutoDBCDSlabAchieved WHERE SalId=@salid)
					BEGIN 
						INSERT INTO AutoDBCDSlabAchieved
							SELECT @salid,@salinvno
					END 
			END 
		
		FETCH next FROM cur_Salinvno INTO @salinvno,@salid,@PrdId,@PrdBatId,@Row,@SalCDPer,@DiffAmt,@CollectionAmt,@Rtrid
		END 
		CLOSE cur_Salinvno
		DEALLOCATE cur_Salinvno
	FETCH next FROM cur_CreditSlab INTO @Slabid,@CreditPeriod,@Discount
	END 
	CLOSE cur_CreditSlab
	DEALLOCATE cur_CreditSlab


	DECLARE cur_CreditDebtitGen CURSOR
		FOR SELECT CrDr,Salid,Rtrid,MaxPerc,sum(CrAmt+CRDBInt) CRDBAmt FROM RaiseCreditDebit GROUP BY CrDr,Salid,Rtrid,MaxPerc

		OPEN cur_CreditDebtitGen
		FETCH next FROM cur_CreditDebtitGen INTO @CRDBName,@CRDBSalid,@DBCRRtrID,@MaxCRDVBPerc,@DBCRCollectionAmt
		WHILE @@Fetch_status=0
		BEGIN 
			IF @CRDBName='Debit'
				BEGIN 
					SELECT @DebitCreditNo=dbo.Fn_GetPrimaryKeyString('DebitNoteRetailer','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
					SET @CrDbNoteDate=GETDATE()
					SELECT @AccCoaId=CoaId FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId=@DBCRRtrID)
					SELECT @FindReasoId= ReasonId FROM ReasonMaster WHERE ReasonCode='R022'
					SELECT @DBCDRtrCode=RtrCode FROM Retailer WHERE RtrId=@DBCRRtrID
					SELECT @DBCDRtrName=RtrName FROM Retailer WHERE RtrId=@DBCRRtrID
					SELECT @DBCDSalInvNo=SalInvNo FROM SalesInvoice WHERE SalId=@CRDBSalid
					SELECT @DBCDSalInvDate=SalInvDate FROM SalesInvoice WHERE SalId=@CRDBSalid
									
					INSERT INTO DebitNoteRetailer(DbNoteNumber,DbNoteDate,RtrId,CoaId,ReasonId,Amount,DbAdjAmount,
						Status,PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
					VALUES(@DebitCreditNo,CONVERT(DATETIME,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),121),@DBCRRtrID,@AccCoaId,@FindReasoId,@DBCRCollectionAmt,0,
						1,'Auto Debit Note',19,'AUTO DB/CD',1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'From Auto Debit Note ' + @Pi_RefNo + '  ' + @DBCDSalInvNo)
					
					IF @FStatus=1
						BEGIN 
							INSERT INTO CrDbNoteTaxBreakUp
							SELECT @DebitCreditNo AS Debitno,19 AS Transid,TaxID,TaxPerc,sum(TaxableAmount) TaxableAmount,sum(TaxAmount) TaxAmount,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)  FROM AutoDBCDProductTax WHERE SalId=@CRDBSalid AND MaxTaxPerc=@MaxCRDVBPerc
								GROUP BY TaxId,Taxperc
								ORDER BY TaxId
						END 
					UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteRetailer' AND Fldname = 'DbNoteNumber'

					EXEC Proc_VoucherPosting 19,1,@DebitCreditNo,3,6,1,@Pi_TransDate,@Po_ErrNo= @ErrStatus OUTPUT
					
														
					INSERT INTO AutoRaisedCreditDebit(RtrId,RtrCode,RtrName,Salid,SalInvNo,SalInvDate,DBCRNoteNo,DBCRNoteAmt)
						VALUES (@DBCRRtrID,@DBCDRtrCode,@DBCDRtrName,@CRDBSalid,@DBCDSalInvNo,@DBCDSalInvDate,@DebitCreditNo,@DBCRCollectionAmt)			

				END 
			ELSE
				IF @CRDBName='Credit'
					BEGIN 
						SELECT @DebitCreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
										
						SET @CrDbNoteDate=GETDATE()
						SELECT @AccCoaId=CoaId FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrID=@DBCRRtrID)
						SELECT @FindReasoId= ReasonId FROM ReasonMaster WHERE ReasonCode='R022'
						SELECT @DBCDRtrCode=RtrCode FROM Retailer WHERE RtrId=@DBCRRtrID
						SELECT @DBCDRtrName=RtrName FROM Retailer WHERE RtrId=@DBCRRtrID
						SELECT @DBCDSalInvNo=SalInvNo FROM SalesInvoice WHERE SalId=@CRDBSalid
						SELECT @DBCDSalInvDate=SalInvDate FROM SalesInvoice WHERE SalId=@CRDBSalid

							INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,
							Status,PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
							VALUES(@DebitCreditNo,CONVERT(DATETIME,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),121),@DBCRRtrID,@AccCoaId,@FindReasoId,@DBCRCollectionAmt,0,
							1,'Auto Credit Note',18,'AUTO DB/CD',1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'From Auto Credit Note ' + @Pi_RefNo+ ' ' + @DBCDSalInvNo)
						
						IF @FStatus=1
							BEGIN 
								INSERT INTO CrDbNoteTaxBreakUp
								SELECT @DebitCreditNo AS Debitno,18 AS Transid,TaxID,TaxPerc,sum(TaxableAmount) TaxableAmount,sum(TaxAmount) TaxAmount,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)  FROM AutoDBCDProductTax WHERE SalId=@CRDBSalid AND MaxTaxPerc=@MaxCRDVBPerc
								GROUP BY TaxId,Taxperc
								ORDER BY TaxId				
							END 
						UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteRetailer' AND Fldname = 'CrNoteNumber'
						
						EXEC Proc_VoucherPosting 18,1,@DebitCreditNo,3,6,1,@Pi_TransDate,@Po_ErrNo= @ErrStatus OUTPUT

						
										
						INSERT INTO AutoRaisedCreditDebit(RtrId,RtrCode,RtrName,Salid,SalInvNo,SalInvDate,DBCRNoteNo,DBCRNoteAmt)
							VALUES (@DBCRRtrID,@DBCDRtrCode,@DBCDRtrName,@CRDBSalid,@DBCDSalInvNo,@DBCDSalInvDate,@DebitCreditNo,@DBCRCollectionAmt)		

					END 
			FETCH next FROM cur_CreditDebtitGen INTO @CRDBName,@CRDBSalid,@DBCRRtrID,@MaxCRDVBPerc,@DBCRCollectionAmt
		END 
	CLOSE cur_CreditDebtitGen
	DEALLOCATE cur_CreditDebtitGen
	
	UPDATE SalesInvoice SET AutoDBCD=1 WHERE SalId IN (SELECT SalId FROM AutoDBCDSlabAchieved)
END 
GO


IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AutoTAXDBCDCreation')
DROP PROCEDURE Proc_AutoTAXDBCDCreation
GO
/*
BEGIN TRANSACTION
exec Proc_AutoTAXDBCDCreation 6,45,1304,4,1
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_AutoTAXDBCDCreation
(
	@SalId int,
	@PrdId int,
	@PrdBaId int,
	@Row int,
	@TobeCalAmt numeric(28,6),
	@Slabid int
	
)
AS
SET NOCOUNT ON
BEGIN
		DECLARE @Pi_TransId AS int 
		DECLARE @Pi_UsrId  AS int
		SET @Pi_TransId=2
		select  @Pi_UsrId=min(userid) from users
		DELETE FROM BilledPrdHdForTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		DELETE FROM BilledPrdDtForTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId

		INSERT INTO BilledPrdHdForTax
		SELECT B.Slno,A.RtrId,B.PrdId,B.PrdBatId,B.BaseQty,A.BillSeqId,@Pi_UsrId,@Pi_TransId,B.PriceId
		FROM SalesInvoiceProduct B INNER JOIN SalesInvoice A ON A.SalId=B.SalId 
		WHERE A.SalId=@SalId AND B.PrdId=@PrdId AND B.PrdBatId=@PrdBaId 

		INSERT INTO BilledPrdDtForTax
		SELECT @Row,-2 AS ColId,@TobeCalAmt AS ColValue,@Pi_UsrId AS Usrid,@Pi_TransId AS TransId 

		DECLARE CalCulateTax CURSOR FOR
		SELECT Slno FROM SalesinvoiceProduct WHERE SalId=@SalId AND PrdId=@PrdId AND PrdBatId=@PrdBaId  ORDER BY Slno
		OPEN CalCulateTax
		FETCH next FROM CalCulateTax INTO @Row
		WHILE @@fetch_status= 0
		BEGIN
			DELETE FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
			EXEC Proc_ComputeTax @Row,@Pi_TransId,@Pi_UsrId
			IF EXISTS (SELECT * FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
			BEGIN
				DELETE FROM AutoDBCDProductTax WHERE SalId=@SalId AND PrdSlno=@Row AND SlabId=@Slabid
				INSERT INTO AutoDBCDProductTax(SalId,PrdSlNo,TaxId,TaxPerc,TaxableAmount,TaxAmount,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxTaxPerc,SlabId)
				SELECT DISTINCT @SalId,RowId,TaxId,TaxPercentage,TaxableAmount,TaxAmount,1,1,GETDATE(),1,GETDATE(),0,@Slabid
				FROM BilledPrdDtCalculatedTax WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND RowId=@Row
				UPDATE AutoDBCDProductTax SET MaxTaxPerc=(SELECT max(TaxPercentage) FROM BilledPrdDtCalculatedTax WHERE  TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND RowId=@Row)  WHERE  SalId=@SalId AND PrdSlno=@Row AND SlabId=@Slabid
			END
			FETCH next FROM CalCulateTax INTO @Row
		END
		CLOSE CalCulateTax
		DEALLOCATE CalCulateTax
END 
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_RptSupplierCreditNote')
DROP PROCEDURE Proc_RptSupplierCreditNote 

GO

--EXEC Proc_RptSupplierCreditNote 84,1,0,'',0,0,1,0
CREATE   PROCEDURE [dbo].[Proc_RptSupplierCreditNote]
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
/************************************************
* PROCEDURE  : Proc_RptCreditNoteSupplier
* PURPOSE    : To Generate  Credit Note Supplier Report
* CREATED BY : Mahalakshmi.A
* CREATED ON : 20/02/2008  
* MODIFICATION 
*************************************************   
* DATE       AUTHOR      DESCRIPTION    
*************************************************/       
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	NVARCHAR(50)
	DECLARE @TblName 			AS	NVARCHAR(500)
	DECLARE @TblStruct 			AS	NVARCHAR(4000)
	DECLARE @TblFields 			AS	NVARCHAR(4000)
	DECLARE @sSql				AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	NVARCHAR(50)
	--Filter Variable
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @SpmId				AS INT
	DECLARE @CrNoteNumber		AS NVARCHAR(50)
	DECLARE @Status				AS INT
	DECLARE @EXLFlag AS INT 
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SpmId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId))
	SET @CrNoteNumber = (SElect  TOP 1 sCountid FRom Fn_ReturnRptFilterString(@Pi_RptId,102,@Pi_UsrId))
	SET @Status = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId))
	--Till Here
	Create TABLE #RptSupplierCreditNote
	(
			SpmId 				 INT,
			SpmCode				 NVARCHAR(50),
			SpmName 			 NVARCHAR(50),
			CrNoteNo			 NVARCHAR(50),
			CrNoteDate			 DATETIME,
			Reason				 NVARCHAR(50),
			CrAmount			 Numeric(38,2),
			CrAdjAmount			 Numeric(38,2),
			BalanceAmount		 Numeric(38,2),
			Status				 NVARCHAR(50),
			TaxName NVARCHAR(100),
			TaxPerc NUMERIC (38,2) ,
			TaxAmt NUMERIC (38,2)
			
	)
	SET @TblName = 'RptSupplierCreditNote'
	SET @TblStruct ='SpmId 				 INT,
					 SpmCode			 NVARCHAR(50),
					 SpmName 			 NVARCHAR(50),
					 CrNoteNo			 NVARCHAR(50),
					 CrNoteDate			 DATETIME,
					 Reason				 NVARCHAR(50),
					 CrAmount			 Numeric(38,2),
					 CrAdjAmount			 Numeric(38,2),
					 BalanceAmount		 Numeric(38,2),
					 Status				 NVARCHAR(50),
					TaxName NVARCHAR(100),
					TaxPerc NUMERIC (38,2) ,
					TaxAmt NUMERIC (38,2)'
	SET @TblFields = 'SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,CrAdjAmount,
					BalanceAmount,Status,TaxName,TaxPerc,TaxAmt'
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
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
-- 		INSERT INTO #RptSupplierCreditNote (SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
--				CrAdjAmount,BalanceAmount,Status,TaxName,TaxPerc,TaxAmt)
-- 			SELECT DISTINCT B.SpmId,B.SpmCode,B.SpmName,A.CrNoteNumber,A.CrNoteDate,C.Description,
--				A.Amount,A.CrAdjAmount,(ISNULL(A.Amount,0)-ISNULL(A.CrAdjAmount,0)) as BalanceAmount,
--					(CASE A.Status WHEN 1 THEN 'Active' ELSE 'InActive' END),
--					ISNULL(TC.TaxName,'')+' Tax Amt',ISNULL(CTB.TaxPerc,0),ISNULL(CTB.TaxAmt,0)
--				FROM CreditNoteSupplier A
--			INNER JOIN Supplier B ON A.SpmId=B.SpmId
--			INNER JOIN reasonMaster C ON A.ReasonId=C.ReasonId
--			LEFT OUTER JOIN CrDbNoteTaxBreakUp CTB ON CTB.RefNo=A.CrNoteNumber AND CTB.TransId=32
--			LEFT OUTER JOIN TaxConfiguration TC ON TC.TaxId=CTB.TaxId
-- 			WHERE 	(B.SpmId = (CASE @SpmID WHEN 0 THEN B.SpmID ELSE 0 END) OR
--							B.SpmId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
--					AND
--						(A.CrNoteNumber=(CASE @CrNoteNumber WHEN '0' THEN A.CrNoteNumber ELSE '' END)OR
-- 							A.CrNoteNumber IN (SELECT sCountid FROM Fn_ReturnRptFilterString(84,102,1)))
--					AND
-- 						(A.Status = (CASE @Status WHEN 0 THEN A.Status ELSE 3 END) OR
-- 							A.Status IN (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))
--					AND
--						 A.CrNoteDate BETWEEN @FromDate AND @ToDate 
			INSERT INTO #RptSupplierCreditNote (SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status,TaxName,TaxPerc,TaxAmt)
 			SELECT DISTINCT B.SpmId,B.SpmCode,B.SpmName,A.CrNoteNumber,A.CrNoteDate,C.Description,
				A.Amount,A.CrAdjAmount,(ISNULL(A.Amount,0)-ISNULL(A.CrAdjAmount,0)) as BalanceAmount,
			(CASE A.Status WHEN 1 THEN 'Active' ELSE 'InActive' END),
				ISNULL(TC.TaxName,'')+' Gross Amt' AS TaxName,ISNULL(CTB.TaxPerc,0),ISNULL(CTB.GrossAmt,0)
				FROM CreditNoteSupplier A
			INNER JOIN Supplier B ON A.SpmId=B.SpmId
			INNER JOIN reasonMaster C ON A.ReasonId=C.ReasonId
			LEFT OUTER JOIN CrDbNoteTaxBreakUp CTB ON CTB.RefNo=A.CrNoteNumber AND CTB.TransId=32
			LEFT OUTER JOIN TaxConfiguration TC ON TC.TaxId=CTB.TaxId
 			WHERE 	(B.SpmId = (CASE @SpmID WHEN 0 THEN B.SpmID ELSE 0 END) OR
							B.SpmId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
					AND
						(A.CrNoteNumber=(CASE @CrNoteNumber WHEN '0' THEN A.CrNoteNumber ELSE '' END)OR
 							A.CrNoteNumber IN (SELECT sCountid FROM Fn_ReturnRptFilterString(84,102,1)))
					AND
 						(A.Status = (CASE @Status WHEN 0 THEN A.Status ELSE 3 END) OR
 							A.Status IN (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))
					AND
						 A.CrNoteDate BETWEEN @FromDate AND @ToDate 
		 
    		IF LEN(@PurDBName) > 0
 		BEGIN
 			SET @SSQL = 'INSERT INTO #RptSupplierCreditNote ' +
 				'(' + @TblFields + ')' +
 				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
 				 +' WHERE (SpmId=  (CASE @SpmId WHEN 0 THEN SpmId ELSE 0 END ) OR
 					SpmId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))'
				 +' AND
					(A.CrNoteNumber=(CASE @CrNoteNumber WHEN ''0'' THEN A.CrNoteNumber ELSE '' END))OR
 						A.CrNoteNumber IN (SELECT iCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,102,@Pi_UsrId)))'
				 +' AND
 					(A.Status = (CASE @StatusID WHEN 0 THEN A.Status ELSE 0 END) OR
 						A.Status IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))'
				 +'AND
					 A.CrNoteDate BETWEEN @FromDate AND @ToDate '
				
 			EXEC (@SSQL)
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSupplierCreditNote'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
			END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		PRINT @Pi_DbName
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO #RptSupplierCreditNote ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
				' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
				' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			PRINT @SSQL
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptSupplierCreditNote
	PRINT 'Data Executed'
	SELECT * FROM #RptSupplierCreditNote
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
	/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @InvId BIGINT
		--DECLARE  @RtrId INT
		DECLARE	 @RefNo	NVARCHAR(100)
		DECLARE  @PurRcptRefNo NVARCHAR(50)
		DECLARE	 @TaxPerc 		NVARCHAR(100)
		DECLARE	 @TaxableAmount NUMERIC(38,6)
		DECLARE  @IOTaxType    NVARCHAR(100)
		DECLARE  @SlNo INT		
		DECLARE	 @TaxFlag      INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @TaxPercent NUMERIC(38,6)
		DECLARE  @Name   NVARCHAR(100)
		--DROP TABLE RptOUTPUTVATSummary_Excel
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSupplierCreditNote_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptSupplierCreditNote_Excel]
		DELETE FROM RptExcelHeaders Where RptId=@Pi_RptId AND SlNo>10
		CREATE TABLE [RptSupplierCreditNote_Excel] (SpmId INT,SpmCode	NVARCHAR(50),SpmName NVARCHAR(50),
					CrNoteNo NVARCHAR(50),CrNoteDate DATETIME,Reason	NVARCHAR(50),CrAmount NUMERIC(38,2),
					CrAdjAmount	NUMERIC(38,2),BalanceAmount NUMERIC(38,2),Status NVARCHAR(50))
		SET @iCnt=11
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT TaxName FROM #RptSupplierCreditNote --ORDER BY CrNoteNumber 
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptSupplierCreditNote_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
				FETCH NEXT FROM Column_Cur INTO @Column
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		--Insert table values
		DELETE FROM [RptSupplierCreditNote_Excel]
		INSERT INTO [RptSupplierCreditNote_Excel](SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status)
		SELECT DISTINCT SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status FROM #RptSupplierCreditNote --WHERE UsrId=@Pi_UsrId
		--Select * from RptOUTPUTVATSummary_Excel
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT CrNoteNo,SpmId,TaxName,TaxAmt FROM #RptSupplierCreditNote
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @RefNo,@SpmId,@TaxPerc,@TaxableAmount
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSupplierCreditNote_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL+ ' WHERE CrNoteNo =''' + CAST(@RefNo AS VARCHAR(1000)) +''' AND  SpmId=' + CAST(@SpmId AS VARCHAR(1000))
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @RefNo,@SpmId,@TaxPerc,@TaxableAmount
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSupplierCreditNote_Excel]')
		OPEN NullCursor_Cura
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSupplierCreditNote_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
	END
RETURN
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_ApplyQPSSchemeInBill')
DROP PROCEDURE  Proc_ApplyQPSSchemeInBill
GO
/*
	BEGIN TRANSACTION
	DELETE FROM BillAppliedSchemeHd
	EXEC Proc_ApplyQPSSchemeInBill 33,3,0,1,2
	SELECT * FROM BillAppliedSchemeHd
	ROLLBACK TRANSACTION
*/
CREATE Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT,
	@Pi_Mode		INT =0	
)
AS
/*********************************
* PROCEDURE	: Proc_ApplyQPSSchemeInBill
* PURPOSE	: To Apply the QPS Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 31/05/2007
* NOTE		: General SP for Returning the Scheme Details for the Selected QPS Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 27-07-2011	Boopathy.P		Sales Return is not reduced for Data based QPS Scheme (Commented fetching data from table SalesInvoiceQPSCumulative)
* 02-08-2011    Boopathy.P		QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
* 08-08-2011    Boopathy.P      Bug Ref no : 23364
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
		FlxValueDisc		TINYINT,
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
	DECLARE  @BillAppliedSchemeHd TABLE
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
	DECLARE @TempBillAppliedSchemeHd TABLE
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
	END
	
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		IF @QPSBasedOn=2
		BEGIN
			IF @Pi_Mode=1
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE IF @Pi_Mode=2
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
		END
		ELSE
		BEGIN
			-- Commented by Boopathy 27-07-2011 (Sales Return is not reduced for Data based QPS Scheme)
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
				SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
				(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
					) AS A 
					INNER JOIN 
					(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
						ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
					) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill   AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
					) AS A 
					INNER JOIN 
					(
						SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
						WHERE A.SchId=@Pi_SchId
					) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
									(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
									AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill  AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						
					) AS A 
				)AS A GROUP BY PrdId,PrdBatId,SchId
		END
	
		IF @Pi_Mode=0
		BEGIN
			--To Subtract Non Deliverbill
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				Select SIP.Prdid,SIP.Prdbatid,
				-1 *ISNULL(SUM(SIP.BaseQty),0) AS SchemeOnQty,
				-1 *ISNULL(SUM(SIP.BaseQty *PrdUom1EditedSelRate),0) AS SchemeOnAmount,
				-1 *ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchemeOnKg,
				-1 *ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
				WHEN 5 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId
				From SalesInvoice SI (NOLOCK)
				INNER JOIN SalesInvoiceProduct SIP (NOLOCK)	ON SI.Salid=SIP.Salid AND SI.SalInvdate BETWEEN @SchValidFrom AND @SchValidTill
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON SIP.PrdId = B.PrdId
				AND SIP.PrdBatId = CASE B.PrdBatId WHEN 0 THEN SIP.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C (NOLOCK) ON SIP.PrdId = C.PrdId
				INNER JOIN ProductUnit D (NOLOCK) ON C.PrdUnitId = D.PrdUnitId,SchemeMaster H
				WHERE Dlvsts in(1,2) and Rtrid=@Pi_RtrId and SI.Salid <>@Pi_SalId
				and SI.Salid Not in(Select Salid from SalesInvoiceSchemeQPSGiven (NOLOCK) where Salid<>@Pi_SalId and  schid=@Pi_SchId)
				AND SI.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
				Group by SIP.Prdid,SIP.Prdbatid,D.PrdUnitId
		END
		IF @Pi_Mode<>2
		BEGIN
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
					WHERE A.SalId = @Pi_SalId AND A.SalId NOT IN (SELECT SalId FROM SalesInvoice WHERE DlvSts>3)
					GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
			
			END
			IF @QPSBasedOn=1 
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
			END
		END
	END
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
		
	DELETE FROM @TempBilled WHERE (SchemeOnQty+SchemeOnAmount+SchemeOnKG+SchemeOnLitre)<=0		

	--->Added By Nanda on 26/11/2010
	IF @QPSBasedOn<>1 AND @FlexiSch=1
	BEGIN
		DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG<=0	
	END
	ELSE
	BEGIN
		DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG=0	
	END
	--->Till Here	
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
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
	--->Added By Boo and Nanda on 29/11/2010
	IF @SchType = 3 AND @QPSReset=1
	BEGIN
		CREATE TABLE  #TemAppQPSSchemes
		(
			SchId		INT,
			SlabId		INT,
			NoOfTime	INT
		)
		
		DECLARE @NewNoOfTimes AS INT
		DECLARE @NewSlabId AS INT
		DECLARE @NewTotalValue AS NUMERIC(38,6)
		SET @NewTotalValue=@TotalValue
		SET @NewSlabId=@SlabId
		WHILE @NewTotalValue>0 AND @NewSlabId>0
		BEGIN
			SELECT @NewNoOfTimes=FLOOR(@NewTotalValue/(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabId AND SchId=@Pi_SchId
			IF @NewNoOfTimes>0
			BEGIN
				SELECT @NewTotalValue=@NewTotalValue-(@NewNoOfTimes*(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabId AND SchId=@Pi_SchId
				INSERT INTO #TemAppQPSSchemes
				SELECT @Pi_SchId,@NewSlabId,@NewNoOfTimes
			END
			SET @NewSlabId=@NewSlabId-1
		END
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here
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
		
		INSERT INTO BilledPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,
			SumInLitre,UserId,TransId)
		SELECT @Pi_RtrId,@Pi_SchId,PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,
			SchemeOnLitre,@Pi_UsrId,@Pi_TransId FROM @TempRedeem
		--To Store the Gross amount for the Scheme billed Product
		SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempRedeem
		--To Calculate the Scheme Flat Amount and Discount Percentage
		--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
		--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
		INSERT INTO @BILLAPPLIEDSCHEMEHD(SCHID,SCHCODE,FLEXISCH,FLEXISCHTYPE,SLABID,SCHEMEAMOUNT,SCHEMEDISCOUNT,
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
				FlatAmt * @NoOfTimes
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
		INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
			BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
		SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
			@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
			0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
			CASE @SchType 
				WHEN 1 THEN 
					(CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END )
				WHEN 2 THEN 
					(CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
				WHEN 3 THEN
					(CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
			END
			as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
			0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
			0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId
			FROM @TempBilled , @TempSchSlabFree
			GROUP BY FreePrdId,FreeQty,ForEveryQty
		--To Calculate the Gift Qty to be given
		INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
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
	--->Added By Boo and Nanda on 29/11/2010	
	IF @SchType = 3 AND @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillApplied FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillApplied
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here
	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,SUM(SchemeDiscount) AS SchemeDiscount,
		SUM(Points) AS Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,(FreePrdId) as FreePrdId ,
		FreePrdBatId,SUM(FreeToBeGiven) As FreeToBeGiven,GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven) As GiftToBeGiven,SUM(NoOfTimes) AS NoOfTimes,
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,MAX(PrdBatId),0 FROM @BillAppliedSchemeHd
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
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
--	IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--	AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--	AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
--	AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
--	BEGIN
--		UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
--		PrdId IN (
--			SELECT A.PrdId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--		PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--		(FreeToBeGiven+GiftToBeGiven) > 0 AND FlexiSch<>1
--		AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
--	END
--	ELSE
--	BEGIN
--		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
--			COUNT(DISTINCT PrdBatId) FROM BillAppliedSchemeHd
--			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId
--			HAVING COUNT(DISTINCT PrdBatId)> 1
--		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
--		BEGIN
--			INSERT INTO @TempBillAppliedSchemeHd
--			SELECT A.* FROM BillAppliedSchemeHd A INNER JOIN @MoreBatch B
--			ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId
--			WHERE A.SchId=@Pi_SchId AND A.SlabId=@SlabId
--			AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND A.FlexiSch<>1
--			AND A.PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
--			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
--			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
--			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
--			AND SchemeAmount =0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
--		END
--	END
	SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId
	IF @FlexiSch=0
	BEGIN
		INSERT INTO @QPSGivenFlat
		SELECT SchId,SUM(FlatAmount)
		FROM
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId ) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
		) A
		WHERE SchId=@Pi_SchId
		GROUP BY A.SchId	
		
		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenFlat A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId 
		INSERT INTO @QPSGivenFlat
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenFlat)
		AND B.SchId IN (SELECT DISTINCT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchemeDiscount=0)
		AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId
	END
	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat
	--->Added By Nanda on 21/02/2011
	UPDATE A SET SchemeAmount=B.SchemeAmount
	FROM BillAppliedSchemeHd A,
	(
		SELECT SchId,SlabId,MAX(SchemeAmount) AS SchemeAmount FROM BillAppliedSchemeHd
		WHERE TransID=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
		GROUP BY SchId,SlabId 
	) B
	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SchId=@Pi_SchId
	--->Till Here
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	--->For QPS Reset
	DECLARE @MSSchId AS INT
	DECLARE @MaxSlabId AS INT
	DECLARE @AmtToReduced AS NUMERIC(38,6)
	SET @AmtToReduced=0
	DECLARE Cur_QPSSlabs CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
				SELECT @AmtToReduced=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@MSSchId
				UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND SchemeAmount<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)		
				BEGIN
					
					SELECT @AmtToReduced=ABS(SchemeAmount) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND SchemeAmount<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
					UPDATE BillAppliedSchemeHd SET SchemeAmount=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @AmtToReduced=0
				END
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0
	IF @QPSReset<>0
	BEGIN
		UPDATE B SET B.NoOfTimes=A.NoOfTimes,B.SchemeAmount=A.SchemeAmount
		FROM BillAppliedSchemeHd B,
		(
			SELECT SchId,SlabId,MAX(NoOfTimes) AS NoOfTimes,MAX(SchemeAmount) AS SchemeAmount
			FROM BillAppliedSchemeHd GROUP BY SchId,SlabId
		) AS A
		WHERE B.SchId=A.SchId AND B.SlabId=A.SlabId AND B.SchId=@Pi_SchId AND B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId 
	END
	--Added By Murugan
	IF @QPS<>0
	BEGIN
		DELETE FROM BilledPrdHdForQPSScheme WHERE Transid=@Pi_TransId and Usrid=@Pi_UsrId AND SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT RowId,@Pi_RtrId,BP.PrdId,BP.Prdbatid,SelRate,BaseQty,BaseQty*SelRate AS SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,ListPrice,0,@Pi_SchId
		From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
		From @TempBilled TB 		
	END
	--Till Here	
	--->Added By Nanda on 25/01/2011
	IF @QPS=1
	BEGIN
		INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,PrdId,PrdBatId,SchType)
		SELECT DISTINCT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,PrdId,PrdBatId,SchType FROM 
		(SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,SchType FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId) A
		CROSS JOIN 
		(
			SELECT A.PrdId,A.PrdBatId FROM BilledPrdHdForQPSScheme A (NOLOCK) 
			INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON A.RowId=10000 AND 
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End		
			AND CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatId AS NVARCHAR(10)) 
			NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId
			AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId
		)
		)B
		WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		NOT IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
	END
	--->Till Here
	-- Added By Boopathy.P on 08-08-2011 for Bug Ref no : 23364
	UPDATE B SET B.PrdBatId=A.PrdBatId FROM BillAppliedSchemeHd B INNER JOIN 
	(SELECT SchId,SlabId,PrdId,Max(PrdbatId) AS PrdBatId,TransId,UsrId FROM @BillAppliedSchemeHd WHERE 
	(FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd > 0) AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	AND SchId=@Pi_SchId GROUP BY SchId,SlabId,PrdId,TransId,UsrId) AS A ON A.SchId=B.SchId
	AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId AND A.TransId=B.TransId AND A.UsrId=B.UsrId 
	WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId AND B.SchId=@Pi_SchId

	SELECT DISTINCT * INTO #BillAppliedSchemeHd  FROM BillAppliedSchemeHd
	WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId

	DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
	INSERT INTO BillAppliedSchemeHd
	SELECT A.* FROM #BillAppliedSchemeHd A INNER JOIN BilledPrdHdForScheme B ON A.TransId=B.TransId AND 
	A.UsrId=B.UsrId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId WHERE B.RtrId=@Pi_RtrId AND
	A.SchId=@Pi_SchId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	--->Till Here
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_ApplyCombiSchemeInBill')
DROP PROCEDURE  Proc_ApplyCombiSchemeInBill
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApplyCombiSchemeInBill 37,3,0,1,2
ROLLBACK TRANSACTION
*/
CREATE Procedure [dbo].[Proc_ApplyCombiSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
)
AS
/*********************************
* PROCEDURE	: Proc_ApplyCombiSchemeInBill
* PURPOSE	: To Apply the Combi Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 17/04/2007
* NOTE		: General SP for Returning the Scheme Details for the Selected Combi Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		  {brief modification description}
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme	
* 02-08-2011    Boopathy.P		  QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
* 11-08-2011    Boopathy.P        A Product with different Batch Issue
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
	DECLARE @QpsReset		INT
	DECLARE @QpsResetAvail		INT
	DECLARE @PurOfEveryReq		INT
	DECLARE @SchemeBudget		NUMERIC(38,6)
	DECLARE @SlabId			INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @GrossAmount		NUMERIC(38,6)
	DECLARE @SchemeLvlMode		INT
	DECLARE @PrdId			INT
	DECLARE @PrdBatId		INT
	DECLARE @PrdCtgValMainId	INT
	DECLARE @FrmSchAch		NUMERIC(38,6)
	DECLARE @FrmUomAch		INT
	DECLARE @FromQty		NUMERIC(38,6)
	DECLARE @UomId			INT
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
	DECLARE @SchValidTill	DATETIME
	DECLARE @SchValidFrom	DATETIME
	DECLARE @QPSBasedOn		INT
	DECLARE @CombiType			INT
	DECLARE @NoofLines			INT
	DECLARE @TransMode			INT
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
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempBilledCombiAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempBilledQpsReset TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempSchSlabAmt TABLE
	(
		ForEveryQty		NUMERIC(38,6),
		ForEveryUomId		INT,
		DiscPer			NUMERIC(10,6),
		FlatAmt			NUMERIC(38,6),
		Points			INT,
		FlxDisc			TINYINT,
		FlxValueDisc		TINYINT,
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
	DECLARE  @BillAppliedSchemeHd TABLE
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
		PrdbatId		INT
	)
	DECLARE @MoreBatch TABLE
	(
		SchId		INT,
		SlabId		INT,
		PrdId		INT,
		PrdCnt		INT,
		PrdBatCnt	INT
	)
	DECLARE @TempBillAppliedSchemeHd TABLE
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
		NoOfTimes	numeric(38,6),
		IsSelected	tinyint,
		SchBudget	numeric(32,6),
		BudgetUtilized	numeric(32,6),
		TransId		tinyint,
		Usrid		int,
		PrdId		int,
		PrdBatId	int,
		SchType		int
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @TempBilledFinal TABLE
	(
		PrdMode			INT,
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId	INT,
		SchemeOnQty		NUMERIC(18,0),
		SchemeOnAmount	NUMERIC(18,6),
		SchemeOnKG		NUMERIC(18,6),
		SchemeOnLitre	NUMERIC(18,6),
		SchId			BIGINT,
		MinAmount		NUMERIC(18,6),
		DiscPer			NUMERIC(18,2),
		FlatAmt			NUMERIC(18,6),
		Points			NUMERIC(18,0)
	)
	DECLARE @QPSGivenFlatAmt AS NUMERIC(38,6)
	SELECT @SchCode = SchCode,@SchType = SchType,@BatchLevel = BatchLevel,@FlexiSch = FlexiSch,
		@FlexiSchType = FlexiSchType,@CombiScheme = CombiSch,@SchLevelId = SchLevelId,@ProRata = ProRata,
		@Qps = QPS,@QpsReset = QPSReset,@QPSBasedOn=ApyQPSSch,@SchemeBudget = Budget,@PurOfEveryReq = PurofEvery,
		@SchemeLvlMode = SchemeLvlMode,@CombiType=CombiType,@SchValidTill=SchValidTill,@SchValidFrom=SchValidFrom
	FROM SchemeMaster WHERE SchId = @Pi_SchId AND MasterType=1
	IF @CombiType=1
	BEGIN
		SET @TransMode=-1
		-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
		INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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
			SELECT @SchLevelId = SUBSTRING(LevelName,6,LEN(LevelName)) from ProductCategoryLevel
			WHERE CmpPrdCtgId = @SchLevelId
			
			INSERT INTO @TempHier (PrdId,PrdBatId,PrdCtgValMainId)
			SELECT DISTINCT D.PrdId,E.PrdBatId,C.PrdCtgValMainId FROM ProductCategoryValue C
			INNER JOIN ( Select LEFT(PrdCtgValLinkCode,@SchLevelId*5) as PrdCtgValLinkCode,A.Prdid from Product A
			INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId
			INNER JOIN @TempBilled F ON A.PrdId = F.PrdId) AS D ON
			D.PrdCtgValLinkCode = C.PrdCtgValLinkCode INNER JOIN ProductBatch E
			ON D.PrdId = E.PrdId
			SELECT @NoofLines=NoofLines FROM SchemeCombiCriteria WHERE SchId=@Pi_SchId
			IF @Pi_SalId<>0
			BEGIN
				IF NOT EXISTS (SELECT A.SalId FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B
							ON A.SalId=B.SalId WHERE B.SchId=@Pi_SchId AND A.RtrId=@Pi_RtrId AND A.SalId<>@Pi_SalId AND A.DlvSts>3)
				BEGIN
					SET @TransMode=0
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					
				END
				ELSE
				BEGIN
					SET @TransMode=1
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END					
				END
			END
			ELSE
			BEGIN
				IF NOT EXISTS (SELECT A.SalId FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B
				ON A.SalId=B.SalId WHERE B.SchId=@Pi_SchId AND A.RtrId=@Pi_RtrId AND A.SalId<>@Pi_SalId  AND A.DlvSts>3)
				BEGIN
					SET @TransMode=0
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
				END
				ELSE
				BEGIN
					SET @TransMode=1
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END	
				END
			END
			IF @TransMode=1
			BEGIN
				IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
						0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
						0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
						0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,B.PrdId,B.PrdBatId,0
						FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdCtgValMainId=B.PrdCtgValMainId
						INNER JOIN BilledPrdHdForScheme C (NOLOCK) ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) D ON C.PrdId = D.PrdId AND 
						C.PrdBatId = CASE D.PrdBatId WHEN 0 THEN C.PrdBatId ELSE D.PrdBatId End
						WHERE C.Usrid = @Pi_UsrId AND C.TransId = @Pi_TransId
				END
				ELSE
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
						0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
						0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
						0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,A.PrdId,A.PrdBatId,0
						FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
				END
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
				BEGIN
					IF EXISTS(SELECT A.SchId,COUNT(A.PrdCtgValMainId) AS Cnt FROM	@TempBilledFinal A
					INNER JOIN SchemeCombiCriteria B ON A.SchId=B.SchId AND A.PrdCtgValMainId=B.PrdCtgValMainId
					WHERE A.SchId=@Pi_SchId AND A.SchemeOnAmount>=B.MinAmount AND B.PrdMode=1 GROUP BY A.SchId
					HAVING COUNT(A.PrdCtgValMainId)>=@NoofLines)
					BEGIN
						INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
						Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
						FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
						BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
						SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
							1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
							0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
							0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
							0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
							0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,B.PrdId,B.PrdBatId,0
							FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdCtgValMainId=B.PrdCtgValMainId
							INNER JOIN BilledPrdHdForScheme C (NOLOCK) ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
							INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) D ON C.PrdId = D.PrdId AND 
							C.PrdBatId = CASE D.PrdBatId WHEN 0 THEN C.PrdBatId ELSE D.PrdBatId End
							WHERE C.Usrid = @Pi_UsrId AND C.TransId = @Pi_TransId
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT A.SchId,COUNT(A.PrdId) AS Cnt FROM	@TempBilledFinal A
					INNER JOIN SchemeCombiCriteria B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.SchId=@Pi_SchId AND A.SchemeOnAmount>=B.MinAmount AND B.PrdMode<>1 GROUP BY A.SchId
					HAVING COUNT(A.PrdId)>=@NoofLines)
					BEGIN
						INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
						Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
						FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
						BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
						SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
							1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
							0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
							0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
							0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
							0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,A.PrdId,A.PrdBatId,0
							FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					END
				END
			END
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM SalesInvoice WHERE SalId = @Pi_SalId)
		BEGIN
			SELECT @BillDate = SalInvDate FROM SalesInvoice WHERE SalId = @Pi_SalId
		END
		ELSE
		BEGIN
			SET @BillDate = CONVERT(VARCHAR(10),GETDATE(),121)
		END
		IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId = @Pi_SchId AND SchValidTill >= @BillDate)
		BEGIN
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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
		END
		IF @QPS <> 0
		BEGIN
		--		--To Add the Cumulative Qty
			IF @QPSBasedOn=2
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE
			BEGIN -- Added by Boopathy on 02-08-2011 for QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill   AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			--To Subtract Non Deliverbill
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				Select SIP.Prdid,SIP.Prdbatid,
				-1 *ISNULL(SUM(SIP.BaseQty),0) AS SchemeOnQty,
				-1 *ISNULL(SUM(SIP.BaseQty *PrdUom1EditedSelRate),0) AS SchemeOnAmount,
				-1 *ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchemeOnKg,
				-1 *ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
				WHEN 5 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId
				From SalesInvoice SI (NOLOCK)
				INNER JOIN SalesInvoiceProduct SIP (NOLOCK)	ON SI.Salid=SIP.Salid AND SI.SalInvdate BETWEEN @SchValidFrom AND @SchValidTill
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON SIP.PrdId = B.PrdId
				AND SIP.PrdBatId = CASE B.PrdBatId WHEN 0 THEN SIP.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C (NOLOCK) ON SIP.PrdId = C.PrdId
				INNER JOIN ProductUnit D (NOLOCK) ON C.PrdUnitId = D.PrdUnitId
				WHERE Dlvsts in(1,2) and Rtrid=@Pi_RtrId and SI.Salid <>@Pi_SalId
				and SI.Salid Not in(Select Salid from SalesInvoiceSchemeQPSGiven (NOLOCK) where Salid<>@Pi_SalId and  schid=@Pi_SchId)
				Group by SIP.Prdid,SIP.Prdbatid,D.PrdUnitId
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
				IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
				BEGIN
					INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
					SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
						-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
						-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
						FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
						AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
				END
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					GROUP BY PrdId,PrdBatId
		END
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
		INSERT INTO @TempBilledAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
		SELECT F.PrdId,F.PrdBatId,F.PrdCtgValMainId,ISNULL(CASE @SchType
			WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			WHEN 2 THEN SUM(SchemeOnAmount)
			WHEN 3 THEN (CASE A.UomId
					WHEN 2 THEN SUM(SchemeOnKg)* 1000
					WHEN 3 THEN SUM(SchemeOnKg)
					WHEN 4 THEN SUM(SchemeOnLitre) * 1000
					WHEN 5 THEN SUM(SchemeOnLitre)	END)
				END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
			A.Slabid,F.SlabValue as FromQty,A.UomId
			FROM SchemeSlabs A
			INNER JOIN SchemeSlabCombiPrds F ON A.SchId = F.SchId AND F.SchId = @Pi_SchId
			AND A.SlabId = F.SlabId
			INNER JOIN @TempBilled B ON A.SchId = B.SchId AND A.SchId = @Pi_SchId
			INNER JOIN Product C ON B.PrdId = C.PrdId
			INNER JOIN @TempHier G ON G.PrdId = CASE F.PrdId WHEN 0 THEN G.PrdId ELSE F.PrdId END
			AND G.PrdBatId = CASE F.PrdBatId WHEN 0 THEN G.PrdBatId ELSE F.PrdBatId END
			AND G.PrdCtgValMainId = CASE F.PrdCtgValMainId WHEN 0 THEN G.PrdCtgValMainId ELSE F.PrdCtgValMainId END
			AND B.PrdId = G.PrdId AND B.PrdBatId = G.PrdBatId
			LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
			GROUP BY F.PrdId,F.PrdBatId,F.PrdCtgValMainId,A.UomId,A.Slabid,A.PurQty,F.SlabValue,A.UomId
		SET @QpsResetAvail = 0
		IF @QpsReset <> 0
		BEGIN
			INSERT INTO @TempBilledQpsReset(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledAch A
				INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId
			
			--Select the Applicable Slab for the Scheme
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledQpsReset GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			SET @QpsResetAvail = 1
		END
		IF @QpsResetAvail = 1
		BEGIN
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,B.SlabValue,A.FrmUomAch,@SlabId,B.SlabValue,A.FrmUomAch
				FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				AND B.SlabId = @SlabId WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId
				AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
				AND B.SchId = @Pi_SchId
		END
		ELSE
		BEGIN
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId AND B.SchId = @Pi_SchId
		END

SELECT * FROM @TempBilledCombiAch

		WHILE (SELECT ISNULL(SUM(FrmSchAch),0) FROM @TempBilledCombiAch) > 0
		BEGIN
			DELETE FROM @TempRedeem
			--Select the Applicable Slab for the Scheme
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledCombiAch GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			
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
--			SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
--				(SELECT ROUND((FrmSchAch / (CASE FromQty WHEN 0 THEN 1 ELSE FROMQTY END)),0) AS NoOfTimes
--				FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A

			IF @QPS=0 AND @CombiScheme=1
			BEGIN
				IF @PurOfEveryReq=0
				BEGIN
					SET @NoOfTimes=1
				END
				ELSE
				BEGIN
					SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
					(SELECT ROUND((SUM(FrmSchAch) / (CASE SUM(FromQty) WHEN 0 THEN 1 ELSE SUM(FromQty) END)),0) AS NoOfTimes
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A
				END
			END
			ELSE
			BEGIN
				SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
					(SELECT ROUND((FrmSchAch / (CASE FromQty WHEN 0 THEN 1 ELSE FROMQTY END)),0) AS NoOfTimes
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A
			END

			IF @SchType = 1
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			IF @SchType = 2
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			IF @SchType = 3
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
								SET @AssignQty = (SELECT CASE PrdUnitId
									WHEN 2 THEN
										(@AssignKG /(CASE PrdWgt WHEN 0 THEN 1 ELSE
											PrdWgt END / 1000))
									WHEN 3 THEN
										(@AssignKG/(CASE PrdWgt WHEN 0 THEN 1 ELSE PrdWgt END))
									WHEN 4 THEN
										(@AssignLitre /(CASE PrdWgt WHEN 0 THEN 1 ELSE
											PrdWgt END / 1000))
									WHEN 5 THEN								(@AssignLitre/(CASE PrdWgt WHEN 0 THEN 1
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,					
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END				CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			--To Store the Gross amount for the Scheme billed Product
			SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempRedeem
			INSERT INTO BilledPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,
				SumInLitre,UserId,TransId)
			SELECT @Pi_RtrId,@Pi_SchId,PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,
				SchemeOnLitre,@Pi_UsrId,@Pi_TransId FROM @TempRedeem
			--->Added By Nanda on 29/10/2010
			IF EXISTS(SELECT * FROM @TempSchSlabAmt WHERE DiscPer=0)
			BEGIN
				INSERT INTO @QPSGivenFlat
				SELECT SchId,SUM(FlatAmount)
				FROM
				(
					SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0)-ISNULL(ReturnFlatAmount,0) AS FlatAmount
					FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM,SalesInvoice SI
					WHERE SM.QPS=1 AND FlexiSch=0 
					AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3			
				) A
				GROUP BY A.SchId	
			END
			UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
			FROM @QPSGivenFlat A,
			(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
			WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND SI.SalId=B.SalId AND SI.DlvSts>3
			GROUP BY B.SchId) C
			WHERE A.SchId=C.SchId 
			IF @FlexiSch=0
			BEGIN
				INSERT INTO @QPSGivenFlat
				SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
				WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenFlat)
				AND B.SchId IN (SELECT DISTINCT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchemeDiscount=0)
				AND SI.SalId=B.SalId AND SI.DlvSts>3
				GROUP BY B.SchId
			END
			SELECT @QPSGivenFlatAmt=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@Pi_SchId
			DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
			INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
			SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat
			--->Till Here
			--To Calculate the Scheme Flat Amount and Discount Percentage
			--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
			--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
			
			IF @QPS=0
			BEGIN
				INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
				SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
					SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
					IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
					FROM
					(
						SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						@SlabId as SlabId,PrdId,PrdBatId,
						(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
						((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
						As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
						FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
						0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
						@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
						WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
					) AS B
					GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
					GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
			END
			ELSE
			BEGIN
				UPDATE @TempSchSlabAmt SET FlatAmt=FlatAmt-@QPSGivenFlatAmt
				INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
				SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
					SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
					IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
					FROM
					(
						SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						@SlabId as SlabId,PrdId,PrdBatId,
						(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
						((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
						As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
						FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
						0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
						@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
						WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
					) AS B
					GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
					GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
			END
			--To Calculate the Free Qty to be given
			INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
				Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
				FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
				BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
			SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
				@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
				0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
				CASE @SchType 
					WHEN 1 THEN 
						(CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END )
					WHEN 2 THEN 
						(CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
					WHEN 3 THEN
						(CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
				END
				as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
				0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
				0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId
				FROM @TempBilled , @TempSchSlabFree
				GROUP BY FreePrdId,FreeQty,ForEveryQty
			--To Calculate the Gift Qty to be given
			INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
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
			UPDATE @TempBilledQPSReset Set FrmSchach = A.FrmSchAch - B.FrmSchAch
				FROM @TempBilledQPSReset A INNER JOIN @TempBilledCombiAch B
				ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId AND
				A.PrdCtgValMainId = B.PrdCtgValMainId
			DELETE FROM @TempBilledCombiAch
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledQPSReset A
				INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId  AND B.SchId = @Pi_SchId
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledCombiAch GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			DELETE FROM @TempBilledCombiAch
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,B.SlabValue,A.FrmUomAch,@SlabId,B.SlabValue,A.FrmUomAch
				FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				AND B.SlabId = @SlabId WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId
				AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
				AND B.SchId = @Pi_SchId
			
			DELETE FROM @TempSchSlabAmt
			DELETE FROM @TempSchSlabFree
		END
		INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
			BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
		SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount),SUM(SchemeDiscount),
			SUM(Points),FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,SUM(FreeToBeGiven),GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven),SUM(NoOfTimes),
			IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0 FROM @BillAppliedSchemeHd
			GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
			FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
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
			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
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
				COUNT(DISTINCT PrdBatId) FROM BillAppliedSchemeHd
				WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId
				HAVING COUNT(DISTINCT PrdBatId)> 1
			IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
			BEGIN
				INSERT INTO @TempBillAppliedSchemeHd
				SELECT A.* FROM BillAppliedSchemeHd A INNER JOIN @MoreBatch B
				ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId
				WHERE A.SchId=@Pi_SchId AND A.SlabId=@SlabId
				AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND A.FlexiSch<>1
				AND A.PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
				WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 )
				UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
				PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
				PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
				AND SchemeAmount =0
			END
		END

		DECLARE @TotalGross		AS	NUMERIC(18,6)
		IF @QPS=0 AND @CombiScheme=1
		BEGIN
			IF EXISTS (SELECT * FROM SchemeSlabCombiPrds WHERE PrdId>0 AND SchId=@Pi_SchId)
			BEGIN
				DELETE FROM @BillAppliedSchemeHd
				DECLARE @PrdWiseSch TABLE
				(
					SchId			INT,
					PrdCtgValMainId	INT,
					PrdId			INT,
					PrdbatId		INT
				)
				DECLARE @PrdWiseSchTemp TABLE
				(
					SchId			INT,
					PrdId			INT,
					PrdbatId		INT
				)
				INSERT INTO @PrdWiseSch
				SELECT DISTINCT A.SchId,B.PrdCtgValMainId,A.PrdId,A.PrdBatId FROM BillAppliedSchemeHd A INNER JOIN @TempHier B ON A.PrdId=B.PrdId 
				AND A.PrdbatId=B.PrdBatId WHERE A.SchId=@Pi_SchId AND A.TransId= @Pi_TransId AND Usrid = @Pi_UsrId

				INSERT INTO @PrdWiseSchTemp
				SELECT DISTINCT A.SchId,B.PrdId,B.PrdBatId FROM @PrdWiseSch A,BilledPrdHdForScheme B (NOLOCK) 
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) C ON
				B.PrdId = C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE B.PrdBatId End
				WHERE B.TransId = @Pi_TransId AND B.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId

				DELETE FROM @PrdWiseSchTemp
				WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) IN
				(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillAppliedSchemeHd
				WHERE TransId = @Pi_TransId AND Usrid = @Pi_UsrId AND SchId=@Pi_SchId)
				SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
				AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId

				IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (FlatAmt+FlxValueDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,A.PrdId,B.PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					INNER JOIN @PrdWiseSchTemp B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId
					SELECT @TotalGross=SUM(B.GrossAmount) FROM BillAppliedSchemeHd A
					INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId
					UPDATE A SET SchemeAmount=  (((SELECT (FlatAmt+FlxValueDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)*( B.GrossAmount/@TotalGross)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
				ELSE IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (DiscPer+FlxDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,A.PrdId,B.PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					INNER JOIN @PrdWiseSchTemp B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId

					UPDATE A SET SchemeDiscount=  (((SELECT (DiscPer+FlxDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
			END
			ELSE
			BEGIN
				DELETE FROM BillAppliedSchemeHd WHERE PrdId=0
				DELETE FROM @BillAppliedSchemeHd
				DECLARE @BrandWiseSch TABLE
				(
					SchId			INT,
					PrdCtgValMainId	INT,
					PrdId			INT,
					PrdbatId		INT
				)
				DECLARE @BrandWiseSchTemp TABLE
				(
					SchId			INT,
					PrdId			INT,
					PrdbatId		INT
				)
				INSERT INTO @BrandWiseSch
				SELECT DISTINCT A.SchId,B.PrdCtgValMainId,A.PrdId,A.PrdBatId FROM BillAppliedSchemeHd A INNER JOIN @TempHier B ON A.PrdId=B.PrdId 
				AND A.PrdbatId=B.PrdBatId WHERE A.SchId=@Pi_SchId AND A.TransId= @Pi_TransId AND Usrid = @Pi_UsrId
				INSERT INTO @BrandWiseSchTemp
				SELECT DISTINCT A.SchId,B.PrdId,B.PrdBatId FROM @BrandWiseSch A,BilledPrdHdForScheme B (NOLOCK) 
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) C ON
				B.PrdId = C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE B.PrdBatId End
				WHERE B.TransId = @Pi_TransId AND B.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
				DELETE FROM @BrandWiseSchTemp
				WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) IN
				(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillAppliedSchemeHd
				WHERE TransId = @Pi_TransId AND Usrid = @Pi_UsrId AND SchId=@Pi_SchId)
				SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
				AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
				IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (FlatAmt+FlxValueDisc)>0)
				BEGIN
				INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,B.PrdId,B.PrdBatId,A.SchType FROM
					(SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,0 AS SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,0 AS PrdId,0 AS PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId) A
					INNER JOIN @BrandWiseSchTemp B ON A.SchId=B.SchId
					
					SELECT @TotalGross=SUM(B.GrossAmount) FROM BillAppliedSchemeHd A
					INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId

					UPDATE A SET SchemeAmount=  (((SELECT (FlatAmt+FlxValueDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)*( B.GrossAmount/@TotalGross)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
				ELSE IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (DiscPer+FlxDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
						SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
						A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
						A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
						A.BudgetUtilized,A.TransId,A.Usrid,B.PrdId,B.PrdBatId,A.SchType FROM
						(SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,0 AS SchemeAmount,A.SchemeDiscount,A.Points,
						A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
						A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
						A.BudgetUtilized,A.TransId,A.Usrid,0 AS PrdId,0 AS PrdBatId,A.SchType FROM BillAppliedSchemeHd A
						WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId) A
						INNER JOIN @BrandWiseSchTemp B ON A.SchId=B.SchId

					UPDATE A SET SchemeDiscount=  (((SELECT (DiscPer+FlxDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
			END
		END
		SELECT DISTINCT * INTO #BillAppliedSchemeHd FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		DELETE FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		INSERT INTO BillAppliedSchemeHd
		SELECT * FROM #BillAppliedSchemeHd
		SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
		AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
		UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
		SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
		TransId = @Pi_TransId AND Usrid = @Pi_UsrId
		--Added By Murugan
		IF @QPS<>0
		BEGIN
			DELETE FROM BilledPrdHdForQPSScheme WHERE Transid=@Pi_TransId and Usrid=@Pi_UsrId AND SchId=@Pi_SchId
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT RowId,@Pi_RtrId,BP.PrdId,BP.Prdbatid,SelRate,BaseQty,BaseQty*SelRate AS SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,ListPrice,0,@Pi_SchId
			From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB 	
		END
		--Till Here
	END
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBillSchemeDetails]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBillSchemeDetails]
GO
CREATE  FUNCTION [dbo].[Fn_ReturnBillSchemeDetails] (@Pi_UserId AS INT,@Pi_TransId AS INT)
RETURNS @ReturnBillSchemeDetails TABLE
	(
		SchId			INT,
		SchCode			VARCHAR(50),
		FlexiSch		INT,
		FlexiSchType	INT,
		SlabId			INT,
        SchemeAmount	NUMERIC(18,6),
		SchemeDiscount	NUMERIC(18,2),
		Points			INT,
		FlxDisc			INT,
        FlxValueDisc	INT,
		FlxFreePrd		INT,
		FlxGiftPrd		INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
        FreeToBeGiven	INT,
		EditScheme		INT,
		NoOfTimes		NUMERIC(18,6),
		Usrid			INT,
		FlxPoints		INT,
        GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftToBeGiven	INT,
		SchType			INT
	)
AS
/*********************************
* FUNCTION: Fn_ReturnBillSchemeDetails
* PURPOSE: Return Billed Scheme Details
* NOTES:
* CREATED: Boopathy.P 0n 14/07/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 06-08-2011 Boopathy.P Wrongly added prdbatid in Group by
*********************************/
BEGIN
		INSERT INTO @ReturnBillSchemeDetails
		SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=1 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount --ORDER BY A.SchId Asc,A.SlabId Asc
		UNION ALL
		SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset)=0 
		AND B.CombiSch=0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId 
		UNION ALL
		SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=0 AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset) >0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount ORDER BY A.SchId Asc,A.SlabId Asc
RETURN
END
GO
Delete From HotSearchEditorHd Where Formid in (519,520,521,522)
GO
Insert Into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values (519,'frmBillingFreeProduct','BillingFreeProduct','select','SELECT PrdId,PrdDcode,PrdName,FreeQty FROM (SELECT DISTINCT A.PrdId,A.PrdDcode,A.PrdName,0 AS FreeQty FROM Product A WITH (NOLOCK),ProductBatchLocation B WITH (NOLOCK),  SchemeMaster C WITH (NOLOCK) WHERE A.PrdStatus=1 AND A.Prdid = B.PrdId AND A.CmpId = C.CmpId AND ((B.PrdBatLcnSih-B.PrdBatLcnResSih) +   (B.PrdBatLcnFre-B.PrdBatLcnResFre))>0 AND PrdType <> 4 AND B.LcnId=vFParam AND C.Schid=vSParam) MainSql')
Insert Into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values (520,'frmBillingFreeProduct','BillingFreeProduct','select','SELECT PrdId,PrdDcode,PrdName,FreeQty FROM (SELECT DISTINCT A.PrdId,A.PrdDcode,A.PrdName,D.FreeQty FROM Product A WITH (NOLOCK),ProductBatchLocation B WITH (NOLOCK),  SchemeMaster C WITH (NOLOCK),SchemeSlabMultiFrePrds D WITH (NOLOCK) WHERE A.PrdStatus=1 AND A.Prdid = B.PrdId AND A.CmpId = C.CmpId AND C.SchId = D.SchId   AND A.PrdId = D.PrdId AND ((B.PrdBatLcnSih-B.PrdBatLcnResSih) +  (B.PrdBatLcnFre-B.PrdBatLcnResFre))>0 AND PrdType <> 4 AND B.LcnId=vFParam AND   C.Schid =vSParam And D.SlabId=vTParam AND D.Type=1) MainSql')
Insert Into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values (521,'frmBillingFreeProduct','BillingFreeProduct','select','SELECT PrdId,PrdDcode,PrdName,FreeQty FROM (SELECT DISTINCT A.PrdId,A.PrdDcode,A.PrdName,0 AS FreeQty FROM Product A WITH (NOLOCK),ProductBatchLocation B WITH (NOLOCK),  SchemeMaster C WITH (NOLOCK) WHERE A.PrdStatus=1 AND A.Prdid = B.PrdId AND A.CmpId = C.CmpId AND ((B.PrdBatLcnSih-B.PrdBatLcnResSih) +   (B.PrdBatLcnFre-B.PrdBatLcnResFre))>0 AND PrdType = 4 AND B.LcnId=vFParam AND C.Schid = vSParam) MainSql')
Insert Into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values (522,'frmBillingFreeProduct','BillingFreeProduct','select','SELECT PrdId,PrdDcode,PrdName,FreeQty FROM (SELECT DISTINCT A.PrdId,A.PrdDcode,A.PrdName,D.FreeQty FROM Product A WITH (NOLOCK),ProductBatchLocation B WITH (NOLOCK),  SchemeMaster C WITH (NOLOCK),SchemeSlabMultiFrePrds D WITH (NOLOCK) WHERE A.PrdStatus=1 AND A.Prdid = B.PrdId AND A.CmpId = C.CmpId AND C.SchId = D.SchId   AND A.PrdId = D.PrdId AND ((B.PrdBatLcnSih-B.PrdBatLcnResSih) + (B.PrdBatLcnFre-B.PrdBatLcnResFre))>0 AND PrdType = 4   AND B.LcnId=vFParam AND C.Schid =vSParam And D.SlabId=vTParam AND D.Type=2) MainSql')
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_RptCollectionFormatLS')
DROP PROCEDURE Proc_RptCollectionFormatLS
GO
CREATE PROCEDURE [dbo].[Proc_RptCollectionFormatLS]
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
					
		AND [SalInvDate] Between @Pi_FromDate and @Pi_ToDate  AND BillMode = 2	
	) X
	INNER JOIN
	(SELECT VM.AllotmentId,VM.AllotmentNumber,VM.VehicleId,SaleInvNo FROM VehicleAllocationMaster VM,
	VehicleAllocationDetails VD
	WHERE VM.AllotmentNumber = VD.AllotmentNumber) V
	ON X.VehicleId  = V.VehicleId and X.SalInvNo = V.SaleInvNo
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_ApplyQPSSchemeInBill')
DROP PROCEDURE  Proc_ApplyQPSSchemeInBill
GO
/*
	BEGIN TRANSACTION
	DELETE FROM BillAppliedSchemeHd
	EXEC Proc_ApplyQPSSchemeInBill 35,137,0,1,2
	SELECT * FROM BillAppliedSchemeHd
	ROLLBACK TRANSACTION
*/
CREATE Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT,
	@Pi_Mode		INT =0	
)
AS
/*********************************
* PROCEDURE	: Proc_ApplyQPSSchemeInBill
* PURPOSE	: To Apply the QPS Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 31/05/2007
* NOTE		: General SP for Returning the Scheme Details for the Selected QPS Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 27-07-2011	Boopathy.P		Sales Return is not reduced for Data based QPS Scheme (Commented fetching data from table SalesInvoiceQPSCumulative)
* 02-08-2011    Boopathy.P		QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
* 08-08-2011    Boopathy.P      Bug Ref no : 23364
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
		FlxValueDisc		TINYINT,
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
	DECLARE  @BillAppliedSchemeHd TABLE
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
	DECLARE @TempBillAppliedSchemeHd TABLE
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
	END
	
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		IF @QPSBasedOn=2
		BEGIN
			IF @Pi_Mode=1
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE IF @Pi_Mode=2
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
		END
		ELSE
		BEGIN
			-- Commented by Boopathy 27-07-2011 (Sales Return is not reduced for Data based QPS Scheme)
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
				SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
				(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
					) AS A 
					INNER JOIN 
					(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
						ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
					) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill   AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
					) AS A 
					INNER JOIN 
					(
						SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
						WHERE A.SchId=@Pi_SchId
					) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
									(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
									AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill  AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						
					) AS A 
				)AS A GROUP BY PrdId,PrdBatId,SchId
		END
	
		IF @Pi_Mode=0
		BEGIN
			--To Subtract Non Deliverbill
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				Select SIP.Prdid,SIP.Prdbatid,
				-1 *ISNULL(SUM(SIP.BaseQty),0) AS SchemeOnQty,
				-1 *ISNULL(SUM(SIP.BaseQty *PrdUom1EditedSelRate),0) AS SchemeOnAmount,
				-1 *ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchemeOnKg,
				-1 *ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
				WHEN 5 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId
				From SalesInvoice SI (NOLOCK)
				INNER JOIN SalesInvoiceProduct SIP (NOLOCK)	ON SI.Salid=SIP.Salid AND SI.SalInvdate BETWEEN @SchValidFrom AND @SchValidTill
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON SIP.PrdId = B.PrdId
				AND SIP.PrdBatId = CASE B.PrdBatId WHEN 0 THEN SIP.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C (NOLOCK) ON SIP.PrdId = C.PrdId
				INNER JOIN ProductUnit D (NOLOCK) ON C.PrdUnitId = D.PrdUnitId,SchemeMaster H
				WHERE Dlvsts in(1,2) and Rtrid=@Pi_RtrId and SI.Salid <>@Pi_SalId
				and SI.Salid Not in(Select Salid from SalesInvoiceSchemeQPSGiven (NOLOCK) where Salid<>@Pi_SalId and  schid=@Pi_SchId)
				AND SI.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
				Group by SIP.Prdid,SIP.Prdbatid,D.PrdUnitId
		END
		IF @Pi_Mode<>2
		BEGIN
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
					WHERE A.SalId = @Pi_SalId AND A.SalId NOT IN (SELECT SalId FROM SalesInvoice WHERE DlvSts>3)
					GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
			
			END
			IF @QPSBasedOn=1 
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
			END
		END
	END
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
		
	DELETE FROM @TempBilled WHERE (SchemeOnQty+SchemeOnAmount+SchemeOnKG+SchemeOnLitre)<=0		
	--->Added By Nanda on 26/11/2010
	IF @QPSBasedOn<>1 AND @FlexiSch=1
	BEGIN
		DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG<=0	
	END
	ELSE
	BEGIN
		DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG=0	
	END
	--->Till Here	
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
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
	--->Added By Boo and Nanda on 29/11/2010
	IF @SchType = 3 AND @QPSReset=1
	BEGIN
		CREATE TABLE  #TemAppQPSSchemes
		(
			SchId		INT,
			SlabId		INT,
			NoOfTime	INT
		)
		
		DECLARE @NewNoOfTimes AS INT
		DECLARE @NewSlabId AS INT
		DECLARE @NewTotalValue AS NUMERIC(38,6)
		SET @NewTotalValue=@TotalValue
		SET @NewSlabId=@SlabId
		WHILE @NewTotalValue>0 AND @NewSlabId>0
		BEGIN
			SELECT @NewNoOfTimes=FLOOR(@NewTotalValue/(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabId AND SchId=@Pi_SchId
			IF @NewNoOfTimes>0
			BEGIN
				SELECT @NewTotalValue=@NewTotalValue-(@NewNoOfTimes*(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabId AND SchId=@Pi_SchId
				INSERT INTO #TemAppQPSSchemes
				SELECT @Pi_SchId,@NewSlabId,@NewNoOfTimes
			END
			SET @NewSlabId=@NewSlabId-1
		END
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here
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
		
		INSERT INTO BilledPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,
			SumInLitre,UserId,TransId)
		SELECT @Pi_RtrId,@Pi_SchId,PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,
			SchemeOnLitre,@Pi_UsrId,@Pi_TransId FROM @TempRedeem

		--To Store the Gross amount for the Scheme billed Product
		SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempRedeem
		--To Calculate the Scheme Flat Amount and Discount Percentage
		--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
		--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
		INSERT INTO @BILLAPPLIEDSCHEMEHD(SCHID,SCHCODE,FLEXISCH,FLEXISCHTYPE,SLABID,SCHEMEAMOUNT,SCHEMEDISCOUNT,
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
--				FlatAmt * @NoOfTimes
				((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
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
		INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
			BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
		SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
			@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
			0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
			CASE @SchType 
				WHEN 1 THEN 
					(CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END )
				WHEN 2 THEN 
					(CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
				WHEN 3 THEN
					(CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
			END
			as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
			0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
			0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId
			FROM @TempBilled , @TempSchSlabFree
			GROUP BY FreePrdId,FreeQty,ForEveryQty
		--To Calculate the Gift Qty to be given
		INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
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
	--->Added By Boo and Nanda on 29/11/2010	
	IF @SchType = 3 AND @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillApplied FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillApplied
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here
	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,SUM(SchemeDiscount) AS SchemeDiscount,
		SUM(Points) AS Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,(FreePrdId) as FreePrdId ,
		FreePrdBatId,SUM(FreeToBeGiven) As FreeToBeGiven,GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven) As GiftToBeGiven,SUM(NoOfTimes) AS NoOfTimes,
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,MAX(PrdBatId),0 FROM @BillAppliedSchemeHd
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
		SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId

SELECT 'ere',* FROM BillAppliedSchemeHd
		
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
--	IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--	AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--	AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
--	AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
--	BEGIN
--		UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
--		PrdId IN (
--			SELECT A.PrdId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--		PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--		(FreeToBeGiven+GiftToBeGiven) > 0 AND FlexiSch<>1
--		AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
--	END
--	ELSE
--	BEGIN
--		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
--			COUNT(DISTINCT PrdBatId) FROM BillAppliedSchemeHd
--			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId
--			HAVING COUNT(DISTINCT PrdBatId)> 1
--		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
--		BEGIN
--			INSERT INTO @TempBillAppliedSchemeHd
--			SELECT A.* FROM BillAppliedSchemeHd A INNER JOIN @MoreBatch B
--			ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId
--			WHERE A.SchId=@Pi_SchId AND A.SlabId=@SlabId
--			AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND A.FlexiSch<>1
--			AND A.PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
--			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
--			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
--			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
--			AND SchemeAmount =0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
--		END
--	END
	SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId

	IF @FlexiSch=0
	BEGIN
		INSERT INTO @QPSGivenFlat
		SELECT SchId,SUM(FlatAmount)
		FROM
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId ) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
		) A
		WHERE SchId=@Pi_SchId
		GROUP BY A.SchId	
		
		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenFlat A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId 

		INSERT INTO @QPSGivenFlat
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenFlat)
		AND B.SchId IN (SELECT DISTINCT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchemeDiscount=0)
		AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId
	END
	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat

	--->Added By Nanda on 21/02/2011
--	UPDATE A SET SchemeAmount=B.SchemeAmount
--	FROM BillAppliedSchemeHd A,
--	(
--		SELECT SchId,SlabId,MAX(SchemeAmount) AS SchemeAmount FROM BillAppliedSchemeHd
--		WHERE TransID=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
--		GROUP BY SchId,SlabId 
--	) B
--	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SchId=@Pi_SchId
--	AND A.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	
	--->Till Here
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 


	--->For QPS Reset
	DECLARE @MSSchId AS INT
	DECLARE @MaxSlabId AS INT
	DECLARE @AmtToReduced AS NUMERIC(38,6)
	SET @AmtToReduced=0
	DECLARE Cur_QPSSlabs CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
				SELECT @AmtToReduced=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@MSSchId
				UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND SchemeAmount<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)		
				BEGIN
					
					SELECT @AmtToReduced=ABS(SchemeAmount) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND SchemeAmount<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
					UPDATE BillAppliedSchemeHd SET SchemeAmount=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @AmtToReduced=0
				END
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0
--	IF @QPSReset<>0
--	BEGIN
--		UPDATE B SET B.NoOfTimes=A.NoOfTimes,B.SchemeAmount=A.SchemeAmount
--		FROM BillAppliedSchemeHd B,
--		(
--			SELECT SchId,SlabId,MAX(NoOfTimes) AS NoOfTimes,MAX(SchemeAmount) AS SchemeAmount
--			FROM BillAppliedSchemeHd GROUP BY SchId,SlabId
--		) AS A
--		WHERE B.SchId=A.SchId AND B.SlabId=A.SlabId AND B.SchId=@Pi_SchId AND B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId 
--	END
	--Added By Murugan
	IF @QPS<>0
	BEGIN
		DELETE FROM BilledPrdHdForQPSScheme WHERE Transid=@Pi_TransId and Usrid=@Pi_UsrId AND SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT RowId,@Pi_RtrId,BP.PrdId,BP.Prdbatid,SelRate,BaseQty,BaseQty*SelRate AS SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,ListPrice,0,@Pi_SchId
		From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
		From @TempBilled TB 		
	END
	--Till Here	
	--->Added By Nanda on 25/01/2011
	IF @QPS=1
	BEGIN
		INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,PrdId,PrdBatId,SchType)
		SELECT DISTINCT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,PrdId,PrdBatId,SchType FROM 
		(SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,SchType FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId) A
		CROSS JOIN 
		(
			SELECT A.PrdId,A.PrdBatId FROM BilledPrdHdForQPSScheme A (NOLOCK) 
			INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON A.RowId=10000 AND 
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End		
			AND CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatId AS NVARCHAR(10)) 
			NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId
			AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId
		)
		)B
		WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		NOT IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
	END
	--->Till Here
	-- Added By Boopathy.P on 08-08-2011 for Bug Ref no : 23364
	UPDATE B SET B.PrdBatId=A.PrdBatId FROM BillAppliedSchemeHd B INNER JOIN 
	(SELECT SchId,SlabId,PrdId,Max(PrdbatId) AS PrdBatId,TransId,UsrId FROM @BillAppliedSchemeHd WHERE 
	(FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd > 0) AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	AND SchId=@Pi_SchId GROUP BY SchId,SlabId,PrdId,TransId,UsrId) AS A ON A.SchId=B.SchId
	AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId AND A.TransId=B.TransId AND A.UsrId=B.UsrId 
	WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId AND B.SchId=@Pi_SchId
	SELECT DISTINCT * INTO #BillAppliedSchemeHd  FROM BillAppliedSchemeHd
	WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
	IF @QPS=1 and @QPSReset=0
	BEGIN
		DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
		INSERT INTO BillAppliedSchemeHd
		SELECT A.* FROM #BillAppliedSchemeHd A INNER JOIN BilledPrdHdForScheme B ON A.TransId=B.TransId AND 
		A.UsrId=B.UsrId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId WHERE B.RtrId=@Pi_RtrId AND
		A.SchId=@Pi_SchId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_ApportionSchemeAmountInLine')
DROP PROCEDURE  Proc_ApportionSchemeAmountInLine
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApportionSchemeAmountInLine 1,2,0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ApportionSchemeAmountInLine]
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT,
	@Pi_Mode	INT =0
)
AS
/*********************************
* PROCEDURE		: Proc_ApportionSchemeAmountInLine
* PURPOSE		: To Apportion the Scheme amount line wise
* CREATED		: Thrinath
* CREATED DATE	: 25/04/2007
* NOTE			: General SP for Returning Scheme amount line wise
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}       {developer}        {brief modification description}
* 28/04/2009    Nandakumar R.G    Modified for Discount Calculation on MRP with Tax
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme
* 04-08-2011    Boopathy.P        Update the Discount percentage for Flexi Scheme 
* 05-08-2011    Boopathy.P		  Previous Adjusted Value will not reduce for Flexi QPS Based Scheme
* 09-08-2011    Boopathy.P		  Bug No:23402
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchId   INT
	DECLARE @SlabId  INT
	DECLARE @RefCode nVarChar(10)
	DECLARE @RtrId  INT
	DECLARE @PrdCnt  INT
	DECLARE @PrdBatCnt INT
	DECLARE @PrdId  INT
	DECLARE @MRP  INT
	DECLARE @WithTax INT
	DECLARE @BillSeqId  INT
	DECLARE @QPS  INT
	DECLARE @QPSDateQty  INT
	DECLARE @Combi  INT
	DECLARE @RtrQPSId  INT
	DECLARE @TempSchGross TABLE
	(
		SchId   INT,
		GrossAmount  NUMERIC(38,6),
		QPSGrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6),
		QPSGrossAmount  NUMERIC(38,6)
	)
	DECLARE @FreeQtyDt TABLE
	(
		FreePrdid  INT,
		FreePrdBatId  INT,
		FreeQty   INT
	)
	DECLARE @FreeQtyRow TABLE
	(
		RowId   INT,
		PrdId   INT,
		PrdBatId  INT
	)
	DECLARE @PDSchID TABLE
	(
		PrdId   INT,
		PrdBatId  INT,
		PDSchId   INT,
		PDSlabId  INT
	)
	DECLARE @SchFlatAmt TABLE
	(
		SchId  INT,
		SlabId  INT,
		FlatAmt  NUMERIC(18,6),
		DiscPer  NUMERIC(18,6),
		SchType  INT
	)
	DECLARE @MoreBatch TABLE
	(
		SchId  INT,
		SlabId  INT,
		PrdId  INT,
		PrdCnt  INT,
		PrdBatCnt INT,
		SchType  INT
	)
	DECLARE @QPSGivenDisc TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @RtrQPSIds TABLE
	(
		RtrId   INT,		
		SchId   INT
	)
	DECLARE @QPSNowAvailable TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)	
	
    -- Added by Boopathy for QPS Quantitiy based checking
	DELETE FROM BillQPSSchemeAdj WHERE CrNoteAmount<=0 
	UPDATE SalesInvoiceQPSSchemeAdj SET AdjAmount=0 WHERE CrNoteAmount=0 AND AdjAmount>=0 	
	DELETE FROM ApportionSchemeDetails WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	-- End here 
	SELECT @RtrQPSId=RtrId FROM BilledPrdHdForQPSScheme WHERE TransId= @Pi_TransId AND UsrId=@Pi_UsrId
	if exists (select * from dbo.sysobjects where id = object_id(N'TP') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TP
	if exists (select * from dbo.sysobjects where id = object_id(N'TG') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TG
	if exists (select * from dbo.sysobjects where id = object_id(N'TPQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TPQ
	if exists (select * from dbo.sysobjects where id = object_id(N'TGQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TGQ
	if exists (select * from dbo.sysobjects where id = object_id(N'SchMaxSlab') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table SchMaxSlab
	SET @RtrId = (SELECT TOP 1 RtrId FROM BilledPrdHdForScheme WHERE TransID = @Pi_TransId
	AND UsrId = @Pi_Usrid)
	DECLARE  CurSchid CURSOR FOR
	SELECT DISTINCT Schid,SlabId FROM BillAppliedSchemeHd WHERE IsSelected = 1
	AND TransID = @Pi_TransId AND UsrId = @Pi_Usrid
	OPEN CurSchid
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @QPS =QPS,@Combi=CombiSch,@QPSDateQty=ApyQPSSch	FROM SchemeMaster WHERE Schid=@SchId	
		SELECT @MRP=ApplyOnMRPSelRte,@WithTax=ApplyOnTax FROM SchemeMaster WHERE --MasterType=2 AND
		SchId=@SchId
		
		IF NOT EXISTS(SELECT * FROM @TempSchGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF  @QPS<>0 
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 
			BEGIN			
				
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 
			BEGIN
				IF @Combi=1 
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,PrdId,PrdBatId,SchType FROM 
					(SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,SchType FROM BillApplieDSchemeHd WHERE SchId=@SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId) A
					CROSS JOIN 
					(
						SELECT A.PrdId,A.PrdBatId FROM BilledPrdHdForQPSScheme A (NOLOCK) 
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON A.RowId=10000 AND 
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End		
						AND CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatId AS NVARCHAR(10)) 
						NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillApplieDSchemeHd WHERE SchId=@SchId
						AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId
					)
					)B
					WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
					NOT IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
					FROM BillAppliedSchemeHd WHERE SchId=@SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
				END
				INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
				SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
				CASE @MRP
				WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
				WHEN 2 THEN A.GrossAmount
				WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
				AS GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
				UNION ALL
				SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
				CASE @MRP
				WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
				WHEN 2 THEN A.GrossAmount
				WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
				AS GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
				IF @QPSDateQty=2 
				BEGIN
					UPDATE TPGS SET TPGS.RowId=BP.RowId
					FROM @TempPrdGross TPGS,BilledPrdHdForQPSScheme BP
					WHERE TPGS.PrdId=BP.PrdId AND TPGS.PrdBatId=BP.PrdBatId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND BP.RowId<>10000
					AND TPGS.SchId=BP.SchId
					UPDATE C SET C.GrossAmount=C.GrossAmount+A.OtherGross
					FROM @TempPrdGross C,
					(SELECT SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
					GROUP BY SchID) A,
					(SELECT SchId,ISNULL(MIN(RowId),2)  AS RowId FROM @TempPrdGross WHERE RowId<>10000 
					GROUP BY SchId) B
					WHERE A.SchId=B.SchId AND B.SchId=C.SchId AND B.RowId=C.RowId
					DELETE FROM @TempPrdGross WHERE RowId=10000
				END
				ELSE
				BEGIN
					UPDATE TPGS SET TPGS.RowId=BP.RowId
					FROM @TempPrdGross  TPGS,
					(
						SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
						WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
						GROUP BY SchId
					) AS BP
					WHERE TPGS.SchId=BP.SchId 
				END	
			END
		END
		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
		COUNT(DISTINCT PrdBatId),SchType FROM BillAppliedSchemeHd
		WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId,SchType
		HAVING COUNT(DISTINCT PrdBatId)> 1
		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@SchId AND SlabId=@SlabId)
		BEGIN
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,0 FROM SchemeSlabs
			WHERE SchId=@SchId AND SlabId=@SlabId
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,1 FROM SchemeAnotherPrdDt
			WHERE SchId=@SchId AND SlabId=@SlabId
		END
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	END
	CLOSE CurSchid
	DEALLOCATE CurSchid
	----->
	SELECT DISTINCT * INTO TG FROM @TempSchGross
	SELECT DISTINCT * INTO TP FROM @TempPrdGross
	DELETE FROM @TempPrdGross
	
	INSERT INTO @TempPrdGross
	SELECT * FROM TP 
	
	---->For Scheme on Another Product QPS	
	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
	@TempSchGross TSG1,SchemeMaster SM ,SchemeAnotherPrdHd SMA
	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId AND SM.SchId=SMA.SchId
	UPDATE T1 SET QPSGrossAmount=A.GrossAmount
	FROM @TempPrdGross T1,BilledPrdHdForQPSScheme A
	WHERE T1.RowId=A.RowID AND T1.PrdId=A.PrdId AND T1.PrdBatId=A.PrdBatId AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	AND A.QPSPrd=0 AND A.SchId=T1.SchId 
	UPDATE S1 SET S1.QPSGrossAmount=A.QPSGross	
	FROM @TempSchGross S1,(SELECT SchId,SUM(QPSGrossAmount) AS QPSGross FROM @TempPrdGross GROUP BY SchId) AS A
	WHERE A.SchId=S1.SchId
	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1
		INSERT INTO @PDSchID (PrdId,PrdBatId,PDSchId,PDSlabId)
		SELECT SP.PrdId,SP.PrdBatId,BAS.SchId AS PDSchId,MIN(BAS.SlabId) AS PDSlabId
		FROM @TempPrdGross SP
		INNER JOIN BillAppliedSchemeHd BAS ON SP.SchId=BAS.SchId AND SchemeDiscount>0
		INNER JOIN (SELECT DISTINCT SP1.PrdId,SP1.PrdBatId,MIN(BAS1.SchId) AS MinSchId
		FROM BillAppliedSchemeHd BAS1,@TempPrdGross SP1
		WHERE SP1.SchId=BAS1.SchId
		AND SchemeDiscount >0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
		GROUP BY SP1.PrdId,SP1.PrdBatId) AS A ON A.MinSchId=BAS.SchId AND A.PrdId=SP.PrdId
		AND A.PrdBatId=SP.PrdBatId AND BAS.UsrId = @Pi_Usrid AND BAS.TransId = @Pi_TransId
		GROUP BY SP.PrdId,SP.PrdBatId,BAS.SchId
		IF @Pi_TransId=2
		BEGIN
			DECLARE @DiscPer TABLE
			(
				PrdId  INT,
				PrdBatId INT,
				DiscPer  NUMERIC(18,6),
				GrossAmount NUMERIC(18,6),
				RowId  INT
			)
			INSERT INTO @DiscPer
			SELECT SP1.PrdId,SP1.PrdBatId,ISNULL(SUM(BAS1.SchemeDiscount),0),SP1.GrossAmount,SP1.RowId
			FROM BillAppliedSchemeHd BAS1 LEFT OUTER JOIN @TempPrdGross SP1
			ON SP1.SchId=BAS1.SchId AND SP1.PrdId=BAS1.PrdId AND SP1.PrdBatId=BAS1.PrdBatId WHERE IsSelected=1 AND
			SchemeDiscount>0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
			GROUP BY SP1.PrdId,SP1.PrdBatId,SP1.RowId,SP1.GrossAmount
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			CASE 
				WHEN QPS=1 THEN
					(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
				ELSE  
					SchemeAmount 
				END  
			As SchemeAmount,
			C.GrossAmount - (C.GrossAmount / (1  +
			(
			(
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second Case Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second Case End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId INNER JOIN @TempPrdGross C ON A.Schid = C.SchId
			AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId and B.SchId = C.SchId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 		
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			AND PD.PDSchId=A.SchId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND (A.SchemeAmount + A.SchemeDiscount) > 0
			SELECT  A.RowId,A.PrdId,A.PrdBatId,D.PrdBatDetailValue,
			C.GrossAmount - (C.GrossAmount / (1  +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			 D.PrdBatDetailValue  END     --Second Case End
			ELSE 0 END) + DiscPer)/100)) AS SchAmt,F.SchId,F.SlabId
			INTO #TempFinal
			FROM @DiscPer A
			INNER JOIN @TempPrdGross C ON  A.PrdId = C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId AND D.PrdbatId=A.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON A.PrdId= PD.PrdId AND PD.PDSchId=C.SchId AND
			(CASE PD.PrdBatId WHEN 0 THEN A.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			INNER JOIN BillAppliedSchemeHd F ON F.SchId=PD.PDSCHID AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
			
			SELECT A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,
			(A.DiscPer+isnull(PrdbatDetailValue,0))
			as DISC,
			isnull(SUM(A.DiscPer+PrdbatDetailValue),SUM(A.DiscPer)) AS DiscSUM,ISNULL(B.SchAmt,0) AS SchAmt,
			CASE  WHEN (ISNULL(PrdbatDetailValue,0)>0 AND A.DiscPer > 0 )THEN 1
			  WHEN (ISNULL(PrdbatDetailValue,0)=0 AND A.DiscPer > 0) THEN 2
			  ELSE 3 END as Status
			INTO #TempSch1
			FROM ApportionSchemeDetails A LEFT OUTER JOIN #TempFinal B ON
			A.RowId =B.RowId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId
			AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.DiscPer > 0 AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
			GROUP BY A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,B.PrdbatDetailValue,B.SchAmt
			UPDATE #TempSch1 SET SchAmt=B.SchAmt
			FROM #TempFinal B
			WHERE  #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			SELECT A.RowId,A.PrdId,A.PrdBatId,ISNULL(SUM(Disc),0) AS SUMDisc
			INTO #TempSch2
			FROM #TempSch1 A
			GROUP BY A.RowId,A.PrdId,A.PrdBatId
			UPDATE #TempSch1 SET DiscSUM=ISNULL((Disc/NULLIF(SUMDisc,0)),0)*SchAmt
			FROM #TempSch2 B
			WHERE #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			UPDATE ApportionSchemeDetails SET SchemeDiscount=DiscSUM
			FROM #TempSch1 B,ApportionSchemeDetails A
			WHERE A.RowId=B.RowId AND A.PrdId = B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId AND
			A.SlabId= B.SlabId AND B.Status<3  AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
		END
		ELSE
		BEGIN
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			D.PrdBatDetailValue  ELSE 0 END     --Second Case End
			ELSE 0 END) + SchemeDiscount)/100))       --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId AND
			A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 	
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		END
	END
	ELSE
	BEGIN
		---->For Scheme on Another Product QPS
		IF EXISTS(SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		BEGIN
			SELECT DISTINCT TP.SchId,BA.SlabId,TP.PrdId,TP.PrdBatId,TP.RowId,TP.GrossAmount 
			INTO TPQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempPrdGross TP ON TP.SchId=BA.SchId
			SELECT DISTINCT TG.SchId,BA.SlabId,TG.GrossAmount 
			INTO TGQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempSchGross TG ON TG.SchId=BA.SchId
			
			SELECT A.SchId,A.MaxSlabId,SS.PurQty
			INTO SchMaxSlab FROM
			(SELECT SM.SchId,MAX(SS.SlabId) AS MaxSlabId
			FROM SchemeMaster SM,SchemeSlabs SS
			WHERE SM.SchId=SS.SchId AND SM.QPSReset=1 
			GROUP BY SM.SchId) A,
			SchemeSlabs SS
			WHERE A.SchId=SS.SchId AND A.MaxSlabId=SS.SlabId 
			DECLARE @MSSchId AS INT
			DECLARE @MaxSlabId AS INT
			DECLARE @MSPurQty AS NUMERIC(38,6)
			DECLARE Cur_QPSSlabs CURSOR FOR 
			SELECT SchId,MaxSlabId,PurQty
			FROM SchMaxSlab
			OPEN Cur_QPSSlabs
			FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			WHILE @@FETCH_STATUS=0
			BEGIN		
				UPDATE TGQ SET GrossAmount=@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId=@MaxSlabId
				UPDATE TGQ SET GrossAmount=GrossAmount-@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId<@MaxSlabId
				FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			END
			CLOSE Cur_QPSSlabs
			DEALLOCATE Cur_QPSSlabs
			UPDATE T SET T.GrossAmount=(T.GrossAmount/TG.GrossAmount)*TGQ.GrossAmount
			FROM TPQ T,TG,TGQ
			WHERE T.SchId=TG.SchId AND TG.SchId=TGQ.SchId AND TGQ.SlabId=T.SlabId 	
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
			SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount
			,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
			@Pi_TransId AS TransId,@Pi_UsrId AS UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A 
			INNER JOIN TGQ B ON	A.SchId = B.SchId AND A.SlabId=B.SlabId
			INNER JOIN TPQ C ON A.Schid = C.SchId and B.SchId = C.SchId  AND B.SlabId=C.SlabId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid AND QPS=1 AND QPSReset=1	
			WHERE A.UsrId = @Pi_UsrId AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)	
			AND SM.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		END

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId		
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid and SM.QPS=1 	  		
		INNER JOIN SchemeAnotherPrdDt SOP ON SM.SchId=SOP.SchId AND A.SchId=SOP.SchId AND A.SlabId=SOP.SlabId
		AND A.PrdId=SOP.PrdId AND SOP.Prdid=C.PrdId 
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1 
		AND SM.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)


		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (CAST(CAST(C.GrossAmount AS NUMERIC(30,10))/CAST(B.GrossAmount AS NUMERIC(30,10)) AS NUMERIC(38,6))) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		SchemeAmount --(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (CAST(CAST(C.GrossAmount AS NUMERIC(30,10))/CAST(B.GrossAmount AS NUMERIC(30,10)) AS NUMERIC(38,6))) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
		AND SM.CombiSch=0
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)


		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN  (QPS=1 AND CombiSch=0) OR (QPS=0 AND CombiSch=1) THEN
		SchemeAmount 
		ELSE  (
				CASE   WHEN SM.FlexiSch=1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
					   WHEN SM.CombiSch=1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100  
				ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)

	END

	--Added by Boopathy.P  on 04-08-2011 
	IF EXISTS(SELECT * FROM SalesinvoiceTrackFlexiScheme WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
	BEGIN
		UPDATE A SET A.DiscPer=B.DiscPer FROM ApportionSchemeDetails A INNER JOIN SalesinvoiceTrackFlexiScheme B
		ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.UsrId=B.UsrId AND A.TransId=B.TransId
		WHERE A.UsrId=@Pi_UsrId AND A.TransID=@Pi_TransId
	END

	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	SELECT FreePrdId,FreePrdBatId,Sum(DISTINCT FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY FreePrdId,FreePrdBatId
	INSERT INTO @FreeQtyRow (RowId,PrdId,PrdBatId)
	SELECT MIN(A.RowId) as RowId,A.Prdid,MAX(A.PrdBatId) FROM BilledPrdHdForScheme A
	INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.PrdId AND
	A.PrdBatid = B.PrdBatId
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND
	B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY A.Prdid
	UPDATE ApportionSchemeDetails SET FreeQty = A.FreeQty FROM
	@FreeQtyDt A INNER JOIN @FreeQtyRow B ON
	A.FreePrdId  = B.PrdId
	WHERE ApportionSchemeDetails.RowId = B.RowId AND  ApportionSchemeDetails.PrdId = B.PrdId 
	AND ApportionSchemeDetails.UsrId = @Pi_UsrId AND ApportionSchemeDetails.TransId = @Pi_TransId
	AND CAST(ApportionSchemeDetails.SchId AS NVARCHAR(10))+'~'+CAST(ApportionSchemeDetails.SlabId AS NVARCHAR(10)) 
	IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10)) FROM BillAppliedSchemeHd WHERE FreeToBeGiven>0)
	--->Added the SchId+SlabId Concatenation By Nanda on 15/12/2010 in the above statement
	--->Added By Nanda on 20/09/2010
	SELECT * INTO #TempApp FROM ApportionSchemeDetails	
	DELETE FROM ApportionSchemeDetails
	INSERT INTO ApportionSchemeDetails
	SELECT DISTINCT * FROM #TempApp

	SELECT 'rr', * FROM ApportionSchemeDetails

	--->Till Here
	SELECT DISTINCT * FROM #TempApp
	UPDATE ApportionSchemeDetails SET SchemeAmount=0 WHERE DiscPer>0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
	FROM 
	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
	WHERE RowId=10000 GROUP BY SchId) A,
	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId
	GROUP BY SchId) B
	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
	AND ApportionSchemeDetails.RowId=B.RowId AND ApportionSchemeDetails.TransId=@Pi_TransId AND ApportionSchemeDetails.UsrId=@Pi_UsrId  
	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	INSERT INTO @RtrQPSIds
	SELECT DISTINCT RtrId,SchId FROM BilledPrdHdForQPSScheme WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	IF @Pi_Mode=0
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,
		SISL.DiscountPerAmount-SISL.ReturnDiscountPerAmount AS DiscountPerAmount,SISL.FlatAmount-SISL.ReturnFlatAmount AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE DiscPer>0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId
		) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
		) A	
		GROUP BY A.SchId
		UNION  -- Added by Boopathy.P on 09-08-2011 for Bug No:23402
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,
		SISL.DiscountPerAmount-SISL.ReturnDiscountPerAmount AS DiscountPerAmount,SISL.FlatAmount-SISL.ReturnFlatAmount AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE DiscPer>0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId
		) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND (SM.FlexiSch=1 AND SM.FlexiSchType=1 AND SM.QPS=1) 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
		) A	
		GROUP BY A.SchId
		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
		WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId
		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId
	END
	ELSE IF @Pi_Mode=1
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount,SISL.FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL INNER JOIN
		(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE SchemeAmount=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		) A ON A.SchId=SISL.SchId AND A.SlabId=SISL.SlabId  INNER JOIN SchemeMaster SM 
		ON A.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 
		INNER JOIN SalesInvoice SI ON SISL.SalId=SI.SalId AND Si.DlvSts>3
		INNER JOIN @RtrQPSIds RQPS ON RQPS.RtrId=Si.RtrId AND SI.RtrId=@RtrId
		WHERE SISL.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		AND SISL.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		) A	GROUP BY A.SchId
		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI,
		SchemeMAster SM	
		WHERE B.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 AND 
		B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		AND B.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		AND B.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId
		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI,
		SchemeMAster SM	
		WHERE B.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 AND 
		B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		AND B.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		GROUP BY B.SchId
	END
	ELSE 
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount,SISL.FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL INNER JOIN
		(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE SchemeAmount=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		) A ON A.SchId=SISL.SchId AND A.SlabId=SISL.SlabId  INNER JOIN SchemeMaster SM 
		ON A.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 
		INNER JOIN SalesInvoice SI ON SISL.SalId=SI.SalId AND Si.DlvSts>3
		INNER JOIN @RtrQPSIds RQPS ON RQPS.RtrId=Si.RtrId AND SI.RtrId=@RtrId
		WHERE SISL.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		) A	GROUP BY A.SchId
		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
		WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId
		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId
	END	
	
	--->Added By Nanda on 04/03/2011 for Flexi Sch
	DELETE FROM @QPSGivenDisc WHERE SchId IN (SELECT SchId FROM SchemeMaster WHERE FlexiSch=1 AND FlexiSchType=2)
	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) 
	FROM ApportionSchemeDetails A
	INNER JOIN SchemeMaster	SM ON A.SchId=SM.SchId AND SM.QPS=1 AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId 
	GROUP BY A.SchId,B.Amount 
	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=2
	
	UPDATE A SET A.Contri=100*(B.GrossAmount/CASE C.GrossAmount WHEN 0 THEN 1 ELSE C.GrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=1
	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId )	
	AND ApportionSchemeDetails.TransId=@Pi_TransID AND ApportionSchemeDetails.UsrId=@Pi_UsrId
	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId )	
	AND ApportionSchemeDetails.TransId=@Pi_TransID AND ApportionSchemeDetails.UsrId=@Pi_UsrId
	-->Till Here
	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId AND ASD.SlabId=A.SlabId
	AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId
	UPDATE ASD SET SchemeAmount=SchemeAmount*SC.Contri
	FROM ApportionSchemeDetails ASD,
	(SELECT A.RowId,A.PrdId,A.PrdBatId,(A.GrossAmount/B.GrossAmount) AS Contri FROM BilledPrdHdForScheme A,
	(SELECT PrdId,PrdBatId,SUM(GrossAmount) AS GrossAmount FROM BilledPrdHdForScheme WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId
	GROUP BY PrdId,PrdBatId
	HAVING COUNT(*)>1) B
	WHERE A.PrdID=B.PrdID AND A.PrdBatId=B.PrdBatId) SC
	WHERE ASD.RowId=SC.RowId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId IN 
	(SELECT SchId FROM SchemeMAster WHERE QPS=0 AND CombiSch=0 AND FlexiSch=0)
END
GO
if not exists (select * from hotfixlog where fixid = 391)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(391,'D','2011-10-03',getdate(),1,'Core Stocky Service Pack 391')
GO