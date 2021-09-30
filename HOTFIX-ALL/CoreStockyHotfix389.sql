--[Stocky HotFix Version]=389
Delete from Versioncontrol where Hotfixid='389'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('389','2.0.0.5','D','2011-09-16','2011-09-16','2011-09-16',convert(varchar(11),getdate()),'Major: Product Release FOR J&J Upgrade')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 389' ,'389'
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_AutoDBCDCreation')
DROP PROCEDURE Proc_AutoDBCDCreation
GO
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
										IF @TobeCalAmt>=10
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
														IF @TobeCalAmt>=10
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
														IF @TobeCalAmt>=10
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
												IF @TobeCalAmt>=10
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
												IF @TobeCalAmt>=10
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
												IF @TobeCalAmt>=10
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
														IF @TobeCalAmt>=10
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
														IF @TobeCalAmt>=10
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
														IF @TobeCalAmt>=10
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
		SET @Pi_UsrId=1
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

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_RptSalesVatReport') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_RptSalesVatReport
GO
CREATE PROCEDURE [dbo].[Proc_RptSalesVatReport]
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
--exec Proc_RptSalesVatReport 232,1,0,'jnj',0,0,1
/*******************************************************************************************************
* VIEW	: Proc_RptSalesVatReport
* PURPOSE	: To get sales tax Details
* CREATED BY	: Karthick.K.J
* CREATED DATE	: 25/05/2011
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
	DECLARE @CmpId 		AS	INT
	DECLARE @InvoiceType AS  INT 
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,274,@Pi_UsrId))
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_SalesTaxSummary @FromDate,@ToDate,@Pi_UsrId,@InvoiceType,@CmpId
		INSERT INTO TempRptSalestaxsumamry 
		  SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Cash Discount',(cashDiscount),IOTaxType,4 TaxFlag,0 TaxPercent,0 TaxId,7,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
		 UNION ALL  
		 SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Visibility Amount',(visibilityAmount),IOTaxType,5 TaxFlag,0 TaxPercent,0 TaxId,8,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
	UNION ALL
		 SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Net Amount',(NetAmount),IOTaxType,6 TaxFlag,0 TaxPercent,0 TaxId,9,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
	END 
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM TempRptSalestaxsumamry  
  DECLARE  @InvId BIGINT  
  DECLARE  @RefNo NVARCHAR(100)  
  DECLARE  @PurRcptRefNo NVARCHAR(50)  
  DECLARE  @TaxPerc   NVARCHAR(100)  
  DECLARE  @TaxableAmount NUMERIC(38,6)  
  DECLARE  @IOTaxType    NVARCHAR(100)  
  DECLARE  @SlNo INT    
  DECLARE  @TaxFlag      INT  
  DECLARE  @Column VARCHAR(80)  
  DECLARE  @C_SSQL VARCHAR(4000)  
  DECLARE  @iCnt INT  
  DECLARE  @TaxPercent NUMERIC(38,6)  
  DECLARE  @Name   NVARCHAR(100)  
  DECLARE  @RtrId INT  
  --DROP TABLE [RptSalesVatDetails_Excel]  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesVatDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE RptSalesVatDetails_Excel  
  DELETE FROM RptExcelHeaders Where RptId=232 AND SlNo>7  
  CREATE TABLE RptSalesVatDetails_Excel (
				InvId BIGINT,RefNo NVARCHAR(100),InvDate DATETIME,
				RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)  
  SET @iCnt=8  
  DECLARE Column_Cur CURSOR FOR  
  SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag FROM TempRptSalestaxsumamry  ORDER BY TaxFlag,TaxPercent
  OPEN Column_Cur  
      FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='ALTER TABLE RptSalesVatDetails_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'  
     SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))  
     SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'  
     EXEC (@C_SSQL)  
    SET @iCnt=@iCnt+1  
     FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag  
    END  
  CLOSE Column_Cur  
  DEALLOCATE Column_Cur  
  --Insert table values  
  DELETE FROM RptSalesVatDetails_Excel  
  INSERT INTO RptSalesVatDetails_Excel(InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId)  
  SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId  
    FROM TempRptSalestaxsumamry  
  --Select * from [RptSalesVatDetails_Excel]  
  DECLARE Values_Cur CURSOR FOR  
  SELECT DISTINCT InvId,RefNo,RtrId,TaxPerc,TaxableAmount FROM TempRptSalestaxsumamry  
  OPEN Values_Cur  
      FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptSalesVatDetails_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL+ ' WHERE InvId='+ CAST(@InvId AS VARCHAR(1000))  
     +' AND RefNo =''' + CAST(@RefNo AS VARCHAR(1000)) +''' AND  RtrId=' + CAST(@RtrId AS VARCHAR(1000))  
     +' AND UsrId='+ CAST(@Pi_UsrId AS NVARCHAR(1000))+''  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount  
    END  
  CLOSE Values_Cur  
  DEALLOCATE Values_Cur  
-- To Update the Null Value as 0  
DECLARE NullCursor_Cur CURSOR FOR  
  SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSalesVatDetails_Excel]')  
  OPEN NullCursor_Cur  
      FETCH NEXT FROM NullCursor_Cur INTO @Name  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptSalesVatDetails_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM NullCursor_Cur INTO @Name  
    END  
  CLOSE NullCursor_Cur  
  DEALLOCATE NullCursor_Cur  
select * from TempRptSalestaxsumamry
RETURN  
END 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Fn_ReturnFiltersValue') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].Fn_ReturnFiltersValue
GO
CREATE FUNCTION [dbo].[Fn_ReturnFiltersValue](@Pi_RecordId Bigint,@Pi_ScreenId INT,@Pi_ReturnId INT)
RETURNS nVarchar(1000)
AS
/*********************************
* FUNCTION: Fn_ReturnFiltersValue
* PURPOSE: Returns the Code or Name for the MasterId
* NOTES:
* CREATED: Thrinath Kola	31-07-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
@Pi_ReturnId		1		Code
@Pi_ReturnId		2		Name
*********************************/
BEGIN
	DECLARE @RetValue as nVarchar(1000)
	IF @Pi_ScreenId = 1
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SMCode ELSE SMName END
			FROM SalesMan WHERE SMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 2
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RMCode ELSE RMName END
			FROM RouteMaster WHERE RMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 3
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtrCode ELSE RtrName END
			FROM Retailer WHERE RtrID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 4
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpCode ELSE CmpName END
			FROM Company WHERE CmpId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 5
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdDCode ELSE PrdName END
			FROM Product WHERE PrdId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 7
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 8
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SchCode ELSE SchDsc END
			FROM SchemeMaster WHERE SchID  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 9
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SpmCode ELSE SpmName END
			FROM Supplier WHERE SpmID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 14
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SALESINVOICE WHERE SALID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 15
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SALESINVOICE WHERE SALID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 16 OR  @Pi_ScreenId = 251
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpPrdCtgName ELSE CmpPrdCtgName END
			FROM ProductCategoryLevel WHERE CmpPrdCtgId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 17
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 18
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 19
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 21
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdCtgValCode ELSE PrdCtgValName END
			FROM ProductCategoryValue WHERE PrdCtgValMainId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 22
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 23
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 24
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 25
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptId IN(7,13)
	END
	IF @Pi_ScreenId = 28
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 29
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CtgLevelName ELSE CtgLevelName END
			FROM RetailerCategoryLevel WHERE CtgLevelId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 30
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CtgName ELSE CtgName END
			FROM RetailerCategory WHERE CtgMainId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 31
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ValueClassCode ELSE ValueClassName END
			FROM RetailerValueClass WHERE RtrClassId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 32
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ReturnCode ELSE ReturnCode END
			FROM ReturnHeader WHERE ReturnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 33
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 34
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SalesInvoice WHERE SalId  = @Pi_RecordId
	END		
	IF @Pi_ScreenId = 35
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RMCode ELSE RMName END
			FROM RouteMaster WHERE RMId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 36
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCode ELSE VehicleRegNo END
			FROM Vehicle WHERE VehicleId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 37
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AllotmentNumber ELSE AllotmentNumber END
			FROM VehicleAllocationMaster WHERE AllotmentId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 38
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(67) AND SelId =38)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		ELSE
		BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM StockManagementType WHERE StkMgmtTypeId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 39
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 40
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 41
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ClmCode ELSE ClmDesc END
			FROM ClaimSheetHD WHERE ClmId  = @Pi_RecordId
	END        	
	IF @Pi_ScreenId = 42
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ClmGrpCode ELSE ClmGrpName END
			FROM ClaimGroupMaster WHERE ClmGrpId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 43
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 44
	--Added by Thiru on 03/09/09
	IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =4 AND SelId =44)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=4
		END
	ELSE
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 45
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 46
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 47
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE CoaId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 48
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 49
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE AcCode  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 50
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE AcCode  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 51
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	---Adde By Murugan
	IF @Pi_ScreenId = 53
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=53)
			BEGIN
				SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
					FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
			END
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=54)
			BEGIN
				SELECT @RetValue = UomDescription  FROM UomMaster WHERE Uomid in( SELECT SelValue FROM
					Reportfilterdt WHERE Rptid in(44,43) AND SelId=54)
			END
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=55)
			BEGIN
				SELECT @RetValue = PrdUnitCode  FROM productUnit WHERE PrdUnitId in( SELECT SelValue FROM
					Reportfilterdt WHERE Rptid in(44,43) AND SelId=55)
			END
	END
	IF @Pi_ScreenId = 56
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(44,59) AND SelId =56)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		
	END
	IF @Pi_ScreenId = 66
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 64
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Cast(FilterDesc as Varchar(20)) ELSE Cast(FilterDesc as Varchar(20)) END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 63
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 65
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VillageName ELSE VillageName END
			FROM RouteVillage WHERE VillageId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 67
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 68
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 69
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	
	IF @Pi_ScreenId = 70
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkCode ELSE BnkName END
			FROM Bank WHERE BnkId  = @Pi_RecordId
		END
	
	IF @Pi_ScreenId = 71
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkBrCode ELSE BnkBrName END
			FROM BankBranch WHERE BnkBrId  = @Pi_RecordId
		END
	IF @Pi_ScreenId = 77
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	IF @Pi_ScreenId = 75
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	IF @Pi_ScreenId = 52
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UOMCode ELSE UOMDescription END
			FROM UomMaster WHERE UOMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 12
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN JcmYr ELSE JcmYr END
			FROM JCMast WHERE JcmId  = @Pi_RecordId
		END
	IF @Pi_ScreenId = 79
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(63) AND SelId =79)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		
	END
	IF @Pi_ScreenId = 80
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(63) AND SelId =80)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 88
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM StockManagementType WHERE StkMgmtTypeId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 84
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DistributorName ELSE DistributorName END
			FROM Distributor WHERE DistributorId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 85
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransporterName ELSE TransporterName END
			FROM Transporter WHERE TransporterId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 86
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCtgName ELSE VehicleCtgName END
			FROM VehicleCategory WHERE VehicleCtgId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 87
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCode ELSE VehicleCode END
			FROM Vehicle WHERE VehicleId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 83
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(33) AND SelId =83)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	
	IF @Pi_ScreenId = 89
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 90
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 92
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrfCode ELSE PrfName END
			FROM ProfileHd WHERE PrfId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 93
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserName ELSE UserName END
			FROM Users WHERE UserId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 94
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 95
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrfName ELSE PrfName END
			FROM ProfileHd WHERE PrfId = @Pi_RecordId
	END
	IF @Pi_ScreenId = 96  --User Profile Master
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(80) AND SelId =96)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	
	IF @Pi_ScreenId = 99
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ColumnDataType ELSE ColumnName END
			FROM UdcMaster WHERE UdcMasterId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 100
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MasterName ELSE MasterName END
			FROM UdcHd WHERE MasterId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 101
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 102 --Credit Note Supplier
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CrNoteNumber ELSE CrNoteNumber END
			FROM CreditNoteSupplier WHERE CrNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 103 --Debit Note Retailer
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DbNoteNumber ELSE DbNoteNumber END
			FROM DebitNoteRetailer WHERE DbNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 108 --Credit Note Retailer
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CrNoteNumber ELSE CrNoteNumber END
			FROM CreditNoteRetailer WHERE CrNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 104
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =90 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=90
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =81 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=81
		END
		ELSE IF  EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =82 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=82
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =84 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=84
		END
		ELSE IF  EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =85 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=85
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =87 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=87
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =88 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=88
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =89 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=89
		END
		ELSE
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 91  --TaxConfiguration
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(78) AND SelId =91)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxCode ELSE TaxName END
			FROM TaxConfiguration WHERE TaxId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 97  --TaxGroupSetting
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(79) AND SelId =97)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 98  --TaxGroupSetting
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(79) AND SelId =98)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 109  --SalesForce Level
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =109)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LevelName ELSE LevelName END
			FROM SalesForcelevel WHERE SalesForceLevelId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 110  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =110)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalesForceCode ELSE SalesForceName END
			FROM SalesForce WHERE SalesForceMainId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 111  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(89) AND SelId =111)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DlvBoyCode ELSE DlvBoyName END
			FROM DeliveryBoy WHERE DlvBoyId  = @Pi_RecordId
		END
	END
---
	IF @Pi_ScreenId = 106 --Vehicle Subsidy Master
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(86) AND SelId =106)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptId in (86)
		END
		ELSE
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
---
	IF @Pi_ScreenId = 107  --Van Subsidy Master
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(86) AND SelId =107)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleSubCode ELSE VehicleSubCode END
			FROM VehicleSubsidy WHERE VehicleSubId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 109  --SalesForce Level
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =109)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LevelName ELSE LevelName END
			FROM SalesForcelevel WHERE SalesForceLevelId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 110  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =110)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalesForceCode ELSE SalesForceName END
			FROM SalesForce WHERE SalesForceMainId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 111  --Delivery Boy
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(89,97) AND SelId =111)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DlvBoyCode ELSE DlvBoyName END
			FROM DeliveryBoy WHERE DlvBoyId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 112  --Retailer Potential Class
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(93) AND SelId =112)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PotentialClassCode ELSE PotentialClassName END
			FROM RetailerPotentialClass WHERE RtrClassId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 113
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 114
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 115  --SalesMan Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(96) AND SelId =115)
		BEGIN
			
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ScmRefNo ELSE ScmRefNo END
			FROM SalesmanClaimMaster WHERE scmRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 96 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
		END
	END
	IF @Pi_ScreenId = 116  --Delivery Boy Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(97) AND SelId =116)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DbcRefNo ELSE DbcRefNo END
			FROM DeliveryBoyClaimMaster WHERE DlvBoyClmId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 117 --Transporter Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TrcRefNo ELSE TrcRefNo END
			FROM TransporterClaimMaster WHERE TrcRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 118  --Purchase Shortage Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(99) AND SelId =118)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurShortRefNo ELSE PurShortRefNo END
			FROM PurShortageClaim WHERE PurShortId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 119 --Purchase Excess Refusal Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM PurchaseExcessClaimMaster WHERE RefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 121  --Special Discount Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(102) AND SelId =121)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SdcRefNo ELSE SdcRefNo END
			FROM SpecialDiscountMaster WHERE SplDiscClaimId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 122  --Van Subsidy Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(103) AND SelId =122)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM VanSubsidyHD WHERE VanSubsidyId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 126 --Manual Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MacRefNo ELSE MacRefNo END
			FROM ManualClaimMaster WHERE MacRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 120  --Rate Difference Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(101) AND SelId =120)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM RateDifferenceClaim WHERE RateDiffClaimId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 123
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 124
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 125
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 127
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(106) AND SelId =127)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SicRefNo ELSE SicRefNo END
			FROM SMIncentiveCalculatorMaster WHERE SicRefNo  IN
			( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 106 AND SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
		END
	END
	IF @Pi_ScreenId = 128
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 129
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UOMCode ELSE UOMDescription END
			FROM UOMMaster WHERE UOMId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 130
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 131
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ChequeNo ELSE ChequeNo END
			FROM ChequeInventoryRtrDt WHERE ChequeNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 132
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 134
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
			FROM StockType WHERE UserStockType  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 135
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
			FROM StockType WHERE UserStockType  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 136
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM ReasonMaster WHERE ReasonId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 137
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN StkJournalRefNo ELSE StkJournalRefNo END
			FROM StockJournal WHERE StkJournalRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 138
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN NormDescription ELSE NormDescription END
			FROM Norms WHERE NormId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 141
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkBrCode ELSE BnkBrName END
		FROM BankBranch WHERE BnkBrId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 142 OR  @Pi_ScreenId = 143 OR  @Pi_ScreenId = 144 OR  @Pi_ScreenId = 145
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AttrName ELSE AttrName END
		FROM PurInvSeriesAttribute WHERE AttributeId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 146
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 147
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 148
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN InstrumentNo ELSE InstrumentNo END
			FROM ChequeInventorySuppDt WHERE InstrumentNo  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 149
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcmYr ELSE AcmYr END
		FROM AcMaster WHERE AcmYr  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 150
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 151
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 152
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN OrderNo ELSE OrderNo END
			FROM OrderBooking WHERE OrderNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 153
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionDescription ELSE TransactionDescription END
			FROM TransactionMaster WHERE TransactionId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 154
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 155
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 156
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 157
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VocRefNo ELSE VocRefNo END
			FROM StdVocMaster WHERE VocRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 158
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN StkMngRefNo ELSE StkMngRefNo END
			FROM StockManagement WHERE StkMngRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 127 AND
						SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 159
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN [Description] ELSE [Description] END
			FROM ReasonMaster WHERE ReasonId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 160
	BEGIN
	SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ReDamRefNo ELSE ReDamRefNo END
			FROM ResellDamageMaster WHERE ReDamRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 113 AND
						SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 161
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurOrderRefNo ELSE PurOrderRefNo END
			FROM PurchaseorderMaster WHERE PurOrderRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 162
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefCode ELSE RefCode END
			FROM BatchCreationMaster WHERE BatchSeqId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 163 --Van Load Unload
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VanLoadRefNo ELSE VanLoadRefNo END
			FROM VanLoadUnloadMaster WHERE VanLoadRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 164
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
		FROM StockType WHERE StockTypeId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 165
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtnCmpRefNo ELSE RtnCmpRefNo END
			FROM ReturnToCompany WHERE RtnCmpRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 166
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ModuleName ELSE ModuleName END
			FROM Counters WHERE ModuleName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 116 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 167
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 168
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 169
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 170
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 171 --Payment
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PayAdvNo ELSE PayAdvNo END
			FROM PurchasePayment WHERE PayAdvNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 172
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 173 --GRN Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRcptRefNo ELSE PurRcptRefNo END
			FROM PurchaseReceipt WHERE PurRcptRefNo  = @Pi_RecordId
	END	
	
	IF @Pi_ScreenId = 174 --Company Invoice Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpInvNo ELSE CmpInvNo END
			FROM PurchaseReceipt WHERE CmpInvNo  = @Pi_RecordId
	END
		
	IF @Pi_ScreenId = 175 --Purchase Return Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 176--Purchase Return Type
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 177 --From Product Batch
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 178 --To Product Batch
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 179
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 180
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BatRefNo ELSE BatRefNo END
			FROM BatchTRansfer WHERE BatRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 181
	BEGIN
			
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalvageRefNo ELSE SalvageRefNo END
			FROM Salvage WHERE SalvageRefNo  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 182
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 183
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 184
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FocusRefNo ELSE FocusRefNo END
			FROM FocusBrandHd WHERE FocusRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 140 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 185 OR @Pi_ScreenId = 186 OR @Pi_ScreenId = 187 OR @Pi_ScreenId = 188 OR @Pi_ScreenId = 189 OR @Pi_ScreenId = 192 OR @Pi_ScreenId = 193
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 190
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FormName ELSE FormName END
			FROM HotSearchEditorHd WHERE FormName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 144 AND
			SelId = @Pi_ScreenId )	
	END
	IF @Pi_ScreenId = 191
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ControlName ELSE ControlName END
			FROM HotSearchEditorHd WHERE ControlName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 144 AND
			SelId = @Pi_ScreenId )	
	END
	
	IF @Pi_ScreenId = 194
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpInvNo ELSE CmpInvNo END
			FROM PurchaseReceipt WHERE PurRcptId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 195
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionNo1 ELSE TransactionNo1 END
			FROM (SELECT DISTINCT SalInvNo AS TransactionNo1
			FROM SalesInvoice  UNION  SELECT DISTINCT ReturnCode AS TransactionNo1 FROM ReturnHeader
			UNION  SELECT DISTINCT RepRefNo AS TransactionNo1 FROM ReplacementHd) A WHERE TransactionNo1
			IN ( SELECT CAST(SelDate AS VARCHAR(25)) FROM ReportFilterDt WHERE Rptid= 29 AND
			SelId = @Pi_ScreenId)
	END
	IF @Pi_ScreenId = 196
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 197
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRcptRefNo ELSE PurRcptRefNo END
			FROM PurchaseReceipt WHERE PurRcptId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 199
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalvageRefNo ELSE SalvageRefNo END
			FROM sALVAGE WHERE SalvageRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 21 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 200
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 201
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionNo1 ELSE TransactionNo1 END
			FROM (SELECT DISTINCT PurRcptRefNo AS TransactionNo1
			FROM PurchaseReceipt  UNION  SELECT DISTINCT PurRetRefNo AS TransactionNo1 FROM PurchaseReturn) A WHERE TransactionNo1
			IN ( SELECT CAST(SelDate AS VARCHAR(25)) FROM ReportFilterDt WHERE Rptid= 29 AND
			SelId = @Pi_ScreenId)
	END
	IF @Pi_ScreenId = 202
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 203
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 204
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 205
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 206
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 208
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 209
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 210
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 211
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptID=153
	END
	IF @Pi_ScreenId = 215
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtrName ELSE RtrName END
			FROM Retailer WHERE RtrId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 216
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN IssueRefNo ELSE IssueRefNo END
			FROM SampleIssueHd WHERE IssueId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 217 OR @Pi_ScreenId = 241 OR @Pi_ScreenId = 260 OR @Pi_ScreenId =  261 OR @Pi_ScreenId =  262 OR @Pi_ScreenId = 246
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF  @Pi_ScreenId = 232
	BEGIN
		SELECT @RetValue = FilterDesc
		FROM RptFilter INNER JOIN ReportFilterDt ON SelId=SelcId
		AND ReportFilterDt.RptId=RptFilter.RptId  AND FilterId=SelValue
		WHERE  SelcId=@Pi_ScreenId	AND UsrId=@Pi_ReturnId
	END
	IF @Pi_ScreenId = 240 
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptID=5
	END
	IF @Pi_ScreenId = 255  --Mordern Trade Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid IN(213) AND SelId =255)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MTCRefNo ELSE MTCRefNo END
			FROM ModernTradeMaster WHERE MTCSplDiscClaimId  = @Pi_RecordId
		END
	END
	--------- JNJ Eff.Cov.Anlaysis Report
	IF @Pi_ScreenId = 270
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END	
	IF @Pi_ScreenId = 272 OR @Pi_ScreenId=273 OR @Pi_ScreenId=274
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	RETURN(@RetValue)
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_StockManagement_StkMgmtTypeId]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [dbo].[StockManagement] DROP CONSTRAINT [FK_StockManagement_StkMgmtTypeId]
GO
if not exists (Select Id,name from Syscolumns where name = 'StkMgmtTypeId' and id in (Select id from 
	Sysobjects where name ='StockManagementProduct'))
begin
	ALTER TABLE [dbo].[StockManagementProduct]
	ADD [StkMgmtTypeId] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_StockManagementProduct_StockTypeId]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
begin
	ALTER TABLE [dbo].[StockManagementProduct] ADD 
		CONSTRAINT [FK_StockManagementProduct_StockTypeId] FOREIGN KEY 
		(
			[StockTypeId]
		) REFERENCES [dbo].[StockType] (
			[StockTypeId]
		)
end
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[TrigStockManagementProduct_Track]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
DROP TRIGGER [TrigBatchTransfer_Track]
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' and Name = 'Proc_Cn2Cs_PurchaseReceipt')
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

			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
			VALUES(@CompInvNo,@RowId,'E',@QtyInKg)
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
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_ApplyCombiSchemeInBill') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_ApplyCombiSchemeInBill
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApplyCombiSchemeInBill 629,42,0,1,2
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
			SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
				(SELECT ROUND((FrmSchAch / (CASE FromQty WHEN 0 THEN 1 ELSE FROMQTY END)),0) AS NoOfTimes
				FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A
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
SELECT * FROM BillAppliedSchemeHd
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
IF EXISTS (Select * from Sysobjects where Xtype = 'P' and Name = 'Proc_RptSchemeUtilizationWithOutPrimary')
DROP PROCEDURE Proc_RptSchemeUtilizationWithOutPrimary
GO
--EXEC Proc_RptSchemeUtilizationWithOutPrimary 152,1,0,'LOREAL',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptSchemeUtilizationWithOutPrimary]
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
/*********************************
* PROCEDURE: Proc_RptSchemeUtilizationWithOutPrimary
* PURPOSE: Procedure To Return the Scheme Utilization for the Selected Filters
* NOTES:
* CREATED: Boopathy	08-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
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
	DECLARE @CtgLevelId      AS    INT
	DECLARE @CtgMainId  AS    INT
	DECLARE @RtrClassId       AS    INT
	DECLARE @fRtrId		      AS	INT
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
	SET @fRtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	--Till Here
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	Create TABLE #RptSchemeUtilization
	(
		SchId		Int,
		SchCode		nVarChar(100),
		SchDesc		nVarChar(100),
		SlabId		nVarChar(10),
		BaseQty		INT,
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
		Total		Numeric(38,6),
		Type		INT
	)
	SET @TblName = 'RptSchemeUtilization'
	SET @TblStruct = '	SchId		Int,
				SchCode		nVarChar(100),
				SchDesc		nVarChar(100),
				SlabId		nVarChar(10),
				BaseQty		INT,
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
				Total		Numeric(38,6),
				Type		INT'
	SET @TblFields = 'SchId,SchCode,SchDesc,SlabId,BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,FreeValue,Total,Type'
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
		EXEC Proc_SchemeUtilization @Pi_RptId,@Pi_UsrId
		DELETE FROM RtpSchemeWithOutPrimary WHERE PrdId=0 AND Type<>4
		UPDATE RtpSchemeWithOutPrimary SET selected=0,SlabId=0

		INSERT INTO #RptSchemeUtilization(SchId,SchCode,SchDesc,SlabId,BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,FreeValue,Total,Type)
		SELECT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.BaseQty,B.SchemeBudget,ISNULL(dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId)+
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId),0),Count(Distinct B.RtrId),
		Count(Distinct B.ReferNo),1 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId) as DiscountPer,
		ISNULL(SUM(Points),0) as Points,'' AS FreePrdName,0 AS FreeQty,0 AS FreeValue,
		ISNULL(dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId)+
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId),0),B.Type
		FROM SchemeMaster A INNER JOIN RtpSchemeWithOutPrimary B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
		A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		B.LineType <> 3 AND B.Userid = @Pi_UsrId AND B.Type=1
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,B.BaseQty,B.Type
		UNION 
		SELECT A.SchId,A.SchCode,A.SchDsc,B.SlabId,0,B.SchemeBudget,0,0,
		0,0 as UnSelectedCnt,0 as FlatAmount,0 as DiscountPer,
		ISNULL(SUM(Points),0) as Points,
		CASE ISNULL(SUM(FreeQty),0) WHEN 0 THEN '' ELSE FreePrdName END AS FreePrdName,
		ISNULL(SUM(FreeQty),0) as FreeQty,ISNULL(SUM(FreeValue),0) as FreeValue,
		ISNULL(SUM(FreeValue),0),B.Type
		FROM SchemeMaster A INNER JOIN RtpSchemeWithOutPrimary B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
		A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		B.LineType <> 3 AND B.Userid = @Pi_UsrId AND B.Type=2
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,FreePrdName,B.Type
		UNION
		SELECT A.SchId,A.SchCode,A.SchDsc,B.SlabId,0,B.SchemeBudget,0,0,
		0,0 as UnSelectedCnt,0 as FlatAmount,0 as DiscountPer,
		0 as Points,CASE ISNULL(SUM(GiftValue),0) WHEN 0 THEN '' ELSE GiftPrdName END AS FreePrdName,
		ISNULL(SUM(GiftQty),0) as FreeQty,ISNULL(SUM(GiftValue),0) as FreeValue,
		ISNULL(SUM(GiftValue),0),B.Type
		FROM SchemeMaster A INNER JOIN RtpSchemeWithOutPrimary B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
		A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		B.LineType <> 3 AND B.Userid = @Pi_UsrId AND B.Type=3
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,GiftPrdName,B.Type
		--->Added By Nanda on 09/02/2011
		UNION 
		
		SELECT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.BaseQty,B.SchemeBudget,ISNULL(dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId)+
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId),0),Count(Distinct B.RtrId),
		Count(Distinct B.ReferNo),1 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId) as DiscountPer,
		ISNULL(SUM(Points),0) as Points,'' AS FreePrdName,0 AS FreeQty,0 AS FreeValue,
		ISNULL(dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId)+
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId),0),B.Type
		FROM SchemeMaster A INNER JOIN RtpSchemeWithOutPrimary B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
		A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		B.LineType <> 3 AND B.Userid = @Pi_UsrId AND B.Type=4
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,B.BaseQty,B.Type
		--->Till Here
		SELECT SchId, CASE LineType WHEN 1 THEN Count(Distinct B.RtrId)
		ELSE Count(Distinct B.RtrId)*-1 END AS RtrCnt ,	CASE LineType WHEN 1 THEN Count(Distinct ReferNo)
		ELSE Count(Distinct ReferNo)*-1 END AS BillCnt
		INTO #TmpCnt FROM RtpSchemeWithOutPrimary B
		WHERE ReferDate Between @FromDate AND @ToDate  AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId AND
		(B.SchId = (CASE @fSchId WHEN 0 THEN B.SchId Else 0 END) OR
		B.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND --B.LineType = 2 AND
		B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		GROUP BY B.SchId,LineType
		DELETE FROM @TempData
		INSERT INTO @TempData(SchId,RtrCnt,BillCnt)
		SELECT SchId, SUM(RtrCnt),SUM(BillCnt) FROM #TmpCnt
		WHERE (SchId = (CASE @fSchId WHEN 0 THEN SchId Else 0 END) OR
		SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) 
		GROUP BY SchId
		UPDATE #RptSchemeUtilization SET NoOfRetailer = NoOfRetailer - CASE  WHEN RtrCnt <0 THEN RtrCnt ELSE 0 END,
		NoOfBills = BillCnt FROM @TempData B WHERE B.SchId = #RptSchemeUtilization.SchId
		--->Added By Nanda on 09/02/2011
		DECLARE @SchIId INT
		CREATE TABLE #SchemeProducts
		(
			SchID	INT,
			PrdID	INT
		)
		DECLARE Cur_SchPrd CURSOR FOR
		SELECT SchId FROM #RptSchemeUtilization
		OPEN Cur_SchPrd  
		FETCH NEXT FROM Cur_SchPrd INTO @SchIId
		WHILE @@FETCH_STATUS=0  
		BEGIN  
			INSERT INTO #SchemeProducts		
			SELECT @SchIId,PrdId FROM Fn_ReturnSchemeProductBatch(@SchIId)
			FETCH NEXT FROM Cur_SchPrd INTO @SchIId
		END  
		CLOSE Cur_SchPrd  
		DEALLOCATE Cur_SchPrd  
		--->Till Here
		SELECT SchId,PrdId,SUM(BaseQty) AS BaseQty INTO #TmpFinal FROM
		(SELECT C.SchId,A.PrdId, A.BaseQty-ReturnedQty AS BaseQty  FROM SalesInvoice D 
		INNER JOIN SalesInvoiceProduct A ON A.SalId=D.SalId
		INNER JOIN SalesInvoiceSchemeHd C ON A.SalId=C.SalId
		INNER JOIN #SchemeProducts E ON E.SchId =C.SchId AND A.PrdId=E.PrdId
		WHERE D.Dlvsts >3 AND SalInvDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) 
		) tmp
		GROUP BY SchId,PrdId 


		SELECT SchId,SUM(BaseQty) As BaseQty INTO #TempFinal1 FROM #TmpFinal 
		GROUP BY #TmpFinal.SchId
 		UPDATE #RptSchemeUtilization SET BaseQty = A.BaseQty FROM #TempFinal1 A 
 		WHERE A.SchId = #RptSchemeUtilization.SchId AND #RptSchemeUtilization.Type in (1,2)
		UPDATE #RptSchemeUtilization SET NoOfRetailer=0 WHERE NoOfRetailer<0
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptSchemeUtilization ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
				' WHERE ReferDate Between ''' + @FromDate + ''' AND ''' + @ToDate + '''AND '+
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSchemeUtilization'
				EXEC (@SSQL)
				PRINT 'Saved Data Into SnapShot Table'
			END
		END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptSchemeUtilization ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSchemeUtilization

	UPDATE RPT SET RPT.SchCode=S.CmpSchCode  FROM #RptSchemeUtilization RPT INNER JOIN SchemeMaster S ON RPT.SchId=S.SchId 

		
	DELETE FROM #RptSchemeUtilization WHERE BaseQty=0 AND SchemeBudget=0 AND BudgetUtilized=0 AND FlatAmount=0 AND DiscountPer=0 AND Points=0 AND FreeQty=0 AND FreeValue=0 AND Total=0
	SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
	FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total FROM #RptSchemeUtilization
	GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,Points,FreePrdName


	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSchemeUtilizationWithOutPrimary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationWithOutPrimary_Excel
		SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,NoOfBills,NoOfRetailer,BudgetUtilized,
		UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
		FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total  
		INTO RptSchemeUtilizationWithOutPrimary_Excel FROM #RptSchemeUtilization 
		GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,Points,FreePrdName
	END 
	RETURN
END 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_DownloadNotification')
DROP PROCEDURE Proc_DownloadNotification
GO
/*
BEGIN TRANSACTION
EXEC Proc_DownloadNotification 1,2
--SELECT SelectQuery,* FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SelectQuery<>''
--ORDER BY SlNo
--SELECT * FROM Cs2Cn_Prk_DownloadedDetails
ROLLBACK TRANSACTION 
*/
create PROCEDURE [Proc_DownloadNotification]
(
		@Pi_UpDownload  INT,
		@Pi_Mode  INT				
)
AS
/*********************************
* PROCEDURE		: Proc_DownloadNotification
* PURPOSE		: To get the Download Notification
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/01/2010
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON

	/*
	@Pi_UpDownload	= 1 -->Download
	@Pi_UpDownload	= 2 -->Upload
	@Pi_Mode		= 1 -->Before
	@Pi_Mode		= 2 -->After
	*/

	DECLARE @Str	NVARCHAR(4000)
	DECLARE @SlNo	INT
	DECLARe @Module		NVARCHAR(200)
	DECLARE @MainTable	NVARCHAR(200)
	DECLARE @KeyField1	NVARCHAR(200)
	DECLARE	@KeyField2	NVARCHAR(200)
	DECLARE @KeyField3	NVARCHAR(200)
	DECLARE @DistCode	NVARCHAR(100)


	SELECT @DistCode=DistributorCode FROM Distributor

	DELETE FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='Y'

	IF @Pi_UpDownload =1
	BEGIN	
		DECLARE Cur_DwCount	 Cursor
		FOR SELECT DISTINCT SlNo,Module,MainTable,KeyField1,KeyField2,KeyField3 FROM CustomUpDownloadCount (NOLOCK)	
		WHERE UpDownload='Download'		
		ORDER BY SlNo		
		OPEN Cur_DwCount
		FETCH NEXT FROM Cur_DwCount INTO @SlNo,@Module,@MainTable,@KeyField1,@KeyField2,@KeyField3
		WHILE @@FETCH_STATUS=0
		BEGIN
			
			IF @Pi_Mode=1
			BEGIN		
				IF @KeyField1='DownloadFlag'
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=0,OldCount=0 WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3=''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=A.OldMax,OldCount=A.OldCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS OldMax,ISNULL(COUNT('+@KeyField1+'),0) AS OldCount FROM '+@MainTable+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3<>''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=A.OldMax ,OldCount=A.OldCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS OldMax,ISNULL(COUNT('+@KeyField1+'),0) AS OldCount FROM '+@MainTable+' WHERE '+@KeyField3+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
			END
			ELSE IF @Pi_Mode=2
			BEGIN		
				IF @KeyField1='DownloadFlag'
				BEGIN
					IF @Module<>'Purchase Order'
					BEGIN
						SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A
						WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo
					END
					ELSE
					BEGIN
						SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT(DISTINCT '+@KeyField3+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A
						WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo
					END
				END

				ELSE IF @KeyField1<>'' AND @KeyField3=''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3<>''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax ,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE '+@KeyField3+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
			END

			EXEC (@Str)

			IF @Pi_Mode=2
			BEGIN		
				UPDATE CustomUpDownloadCount SET DownloadedCount=NewCount-OldCount WHERE UpDownload='Download'

				SET @Str=''

				SELECT @Str=REPLACE(SelectQuery,'OldMax',OldMax) FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SlNo=@SlNo

				IF @Str<>''
				BEGIN

					SET @Str=REPLACE(@Str,'SELECT ',' SELECT '''+@DistCode+''','''+@Module+''',')

					IF @SlNo=218 OR @SlNo=214
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2,Detail3) '+@Str
					END
					ELSE
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2)'+@Str
					END
					print @SlNo
					print @Str
					EXEC (@Str)
				
					UPDATE Cs2Cn_Prk_DownloadedDetails SET DownLoadedDate=GETDATE(),UploadFlag='N' WHERE UploadFlag IS NULL

					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail1=''  WHERE Detail1  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail2=''  WHERE Detail2  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail3=''  WHERE Detail3  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail4=''  WHERE Detail4  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail5=''  WHERE Detail5  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail6=''  WHERE Detail6  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail7=''  WHERE Detail7  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail8=''  WHERE Detail8  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail9=''  WHERE Detail9  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail10='' WHERE Detail10 IS NULL
				END

			END

			FETCH NEXT FROM Cur_DwCount INTO @SlNo,@Module,@MainTable,@KeyField1,@KeyField2,@KeyField3
		END

		CLOSE Cur_DwCount
		DEALLOCATE Cur_DwCount
	END
END
GO 
Delete from Rptdetails where rptid = 4 and SelcId = 243
Delete from Rptfilter where rptid = 4 and SelcId = 243
Delete from RptFormula where rptid = 4 and SelcId = 243
GO
 -- DEFAULT VALUES SCRIPT FOR AutoBackupConfiguration
DELETE FROM AutoBackupConfiguration
GO
INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP1','AutomaticBackup','Take Full Backup of the database Every time',1,'',0,'2011-Aug-02 00:00:00',1)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP2','AutomaticBackup','Take Backup/Extract Log while Logging on to the application',0,'',0,'2011-Aug-02 00:00:00',2)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP3','AutomaticBackup','Take Backup/Extract Log while Logging out of the application',1,'',0,'2011-Aug-02 00:00:00',3)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP4','AutomaticBackup','Take Compulsary Backup',1,'',1,'2011-Sep-09 00:00:00',4)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP5','AutomaticBackup','Clear Temporary tables while taking backup',1,'',0,'2011-Aug-02 00:00:00',5)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP6','AutomaticBackup','Compact database while taking backup',1,'',0,'2011-Aug-02 00:00:00',6)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP7','AutomaticBackup','Remove Backup Files',1,'',15,'2011-Aug-02 00:00:00',7)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP8','AutomaticBackup','Take Backup in the following path…',1,'d:\CoreStockyBackup',0,'2011-Aug-02 00:00:00',8)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP9','AutomaticBackup','Full Extract',0,'',0,'2011-Aug-02 00:00:00',9)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP10','AutomaticBackup','Incremental Extract',1,'',0,'2011-Aug-02 00:00:00',10)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP11','AutomaticBackup','Extract and Retain Data',1,'',0,'2011-Aug-02 00:00:00',11)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP12','AutomaticBackup','Extract and Delete Data',0,'',0,'2011-Aug-02 00:00:00',12)

INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES ('AUTOBACKUP13','AutomaticBackup','Max Value',1,'',0,'2011-Aug-02 00:00:00',13)

-- DEFAULT VALUES SCRIPT FOR Configuration

 DELETE FROM Configuration
 GO
 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBOY1','Delivery Boy','Allow Route Sharing by Delivery Boy',1,'',0,1)
GO
 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBOY2','Delivery Boy','Allow Automatic Route attachment if no Routes are selected',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('JC1','JC Calendar','Populate dates automatically based on the first entry',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('JC3','JC Calendar','Restrict no of days based on No of Days in Calendar year',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET1','Retailer','Make TIN Number as Mandatory if Tax Type is VAT',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET2','Retailer','Set Cash Discount Maximum Limit As',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET3','Retailer','Set Cash Discount Condition as',0,'1',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET4','Retailer','Make Expiry date as Mandatory if Licence Number is entered',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET5','Retailer','Make Expiry date as Mandatory if Drug Licence Number is entered',1,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET6','Retailer','Make Expiry date as Mandatory if Pesticide Licence Number is entered',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET7','Retailer','Allow attaching multiple sales routes for same company',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET19','Retailer','Treat Retailer TaxGroup as Mandatory',1,'',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET9','Retailer','Always display default Coverage Mode as',1,'1',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET10','Retailer','Always display default Retailer Day Off as',1,'0',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET11','Retailer','Set the default Retailer Status as while adding a new retailer',1,'1',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET12','Retailer','Set the default Retailer Tax Group as... while adding a new retailer',1,'Sales RDS',20,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET13','Retailer','Always display default Coverage Frequency as',1,'0',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET8','Retailer','Always use default Geography Level as...',1,'Zone',6,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET26','Retailer','Automatically Populate Retailer Code based on  Counter Settings for Retailer Code Creation',0,'',0,26)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET14','Retailer','Credit Bills',0,'0',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET15','Retailer','Credit Limit',0,'0',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE10','Salvage','Allow Creating new Product by pressing Insert Key',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE11','Salvage','Allow Creating new Batches Type by pressing Insert Key',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SAL1','Salesman','Allow Route Sharing By Salesman as',1,'',0,1)
 
 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SAL2','Salesman','Allow Automatic Route Attatchment if no routes are selected',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD1','VanLoadUnload','Follow FIFO for Automatic Van Load',1,'FIFO',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD2','VanLoadUnload','Alllow Van To Van Transfer',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD3','VanLoadUnload','Use Month Default Value',1,'',3,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD4','VanLoadUnload','Raise a debit Note against Salesman for the Shortage Qty',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD5','VanLoadUnload','Set Focus On UOM 1 Automatically',1,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD6','VanLoadUnload','Display UOM 2 Option in the screen',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('VANLOAD7','VanLoadUnload','Use Default Option For VanLoading',1,'LastSales',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL1','Collection Register','From Date as',1,'',7,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL3','Collection Register','Delivery Route Based on',1,'1',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL5','Collection Register','Retailer Based on',1,'3',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL7','Collection Register','Salesman',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE12','Salvage','Allow Creating new Reason by pressing Insert Key',1,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE14','Salvage','Purchase Receipt',0,'Salvage Track',1,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE17','Salvage','Stock Journal',0,'Salvage Track',4,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE18','Salvage','Batch Transfer',0,'Salvage Track',5,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE19','Salvage','Location Transfer',0,'Salvage Track',6,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE20','Salvage','Sales Return',0,'Salvage Track',7,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE21','Salvage','Resell Damage Goods',0,'Salvage Track',8,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE22','Salvage','Salvage',0,'Salvage Track',9,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE23','Salvage','Return to Company',0,'Salvage Track',10,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE24','Salvage','Return and Replacement',0,'Salvage Track',11,24)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE25','Salvage','Sample Receipt',0,'Salvage Track',12,25)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT1','Stock Management','Manual Selection for Batches',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT2','Stock Management','Follow FIFO for Loading Batches',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT5','Stock Management','Repeat the first selected reason for all the lines',1,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT8','Stock Management','Allow Creating new Location by pressing Insert Key',1,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT11','Stock Management','Allow Creating new Reason by pressing Insert Key',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE26','Salvage','Raise the claim base on',1,'E/Damage Claim Rate',5,26)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET16','Retailer','Credit Days',0,'0',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT3','Stock Management','Follow LIFO for Loading Batches',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT6','Stock Management','Make the reason as mandatory if the stock type is :',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT9','Stock Management','Allow Creating Stock Adjustment Type by pressing Insert Key',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT10','Stock Management','Allow Creating new Product by pressing Insert Key',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT1','Batch Transfer','Allow Selection of Batches of any Stock Type',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY2','ReturnToCompany','Repeat the first selected reason for all the lines',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY3','ReturnToCompany','Make the reason Mandatory of the stock Type is >',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY4','ReturnToCompany','Allow Editing of Claim Amount Field',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY5','ReturnToCompany','Allow Edited to be higher than the Actual Amount',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY6','ReturnToCompany','Include Tax on Product Value',1,'',0,6)
GO
 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY7','ReturnToCompany','Raise the claim based on',1,'E/Damage Claim Rate',5,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRDSALBUNDLE1','ProductSalesBundle','Allow Salesman selection Irrespective of Company selection',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO5','Purchase Order','Allow Creating new Product by pressing Insert Key',0,'0',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO13','Purchase Order','Use Company Product Code for reference in Purchase Order Screen',1,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT2','Batch Transfer','Allow Selection only of Stock Type',0,' ',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT5','Batch Transfer','Rules for treatment of Difference Amount',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT6','Batch Transfer','Allow Creating new Product by pressing Insert Key',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT7','Batch Transfer','Allow Creating new Batches by pressing Insert Key',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BAT8','Batch Transfer','Allow Creating new Reason by Pressing Insert Key',1,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('IRA1','IRA','Display the Batch Details',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('IRA2','IRA','Perform Stock Addition Automatically',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('IRA3','IRA','Perform Stock Out Automatically',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL2','Collection Register','Salesman Based on Date',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL4','Collection Register','Sales Route Based on',1,'2',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL6','Collection Register','Collected By',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL8','Collection Register','Delivery Route',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL9','Collection Register','Sales Route',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL10','Collection Register','Retailer',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL11','Collection Register','Bank',1,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL12','Collection Register','Branch',1,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL13','Collection Register','ExcessCollection',1,'1',NULL,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('COLL14','Collection Register','Perform Account Posting for Cheques',1,'0',NULL,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE15','Salvage','Purchase Return',0,'Salvage Track',2,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REP1','Replacement','Allow user to select only the same product  for Replacement',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RETREP1','RetReplacement','Allow user to select only the same product  for Replacement',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN4','Market Return','Allow both addition and reduction',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN3','Stock Journal','Allow Creating new Batches by pressing Insert Key',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN4','Stock Journal','Allow Creating new Reason by pressing Insert Key',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET17','Retailer','Seek approval for retailer classification && category change',0,'0',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE16','Salvage','Stock Management',0,'Salvage Track',3,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT1','Payment Register','Allow partial payment for an Invoice',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT2','Payment Register','Allow creation of new Credit Note by pressing Insert key',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT3','Payment Register','Allow creation of new Debit Note by pressing Insert key',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT4','Payment Register','Allow creation of new Cheque/DD  by pressing Insert key',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PAYMENT5','Payment Register','Allow multiple mode of pay for a single payment',1,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE2','DebitNoteCreditNote','Allow to enter tax breakup for Debit Note (Supplier)',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE4','DebitNoteCreditNote','Allow to enter tax breakup for Debit Note (Retailer)',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE7','DebitNoteCreditNote','Supplier Credit Note',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE8','DebitNoteCreditNote','Supplier Debit Note',1,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE9','DebitNoteCreditNote','Retailer Credit Note',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('IRA4','IRA','Variance Price',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO14','Purchase Order','Use Ditributor Product Code for reference in Purchase Order Screen',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE4','Cheque Payment','Allow bulk updation of Banked Cheques to Settled',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE8','Cheque Payment','Enable Re- Presenting of Bounced Cheque',1,'',10,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN1','Stock Journal','Allow Creating new Stock Type by pressing Insert Key',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN10','Market Return','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN14','Market Return','Make reason as mandatory if the Stock Type is',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT1','Alert Management','Action on Credit Days Limit',1,'1',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT2','Alert Management','Action on Allowed Credit Amount Limit',1,'1',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT3','Alert Management','Action on Credit Bills Limit',1,'1',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT4','Alert Management','Allow Billing on Distributors off Day',0,'0',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT5','Alert Management','Allow Billing on Retailers off Day',0,'0',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT6','Alert Management','Allow Billing on Weekend Days - JC Calendar',0,'0',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT7','Alert Management','Allow Billing on Holidays defined',0,'0',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT8','Alert Management','Restrict Billing if TIN number is not filling in the Retailer master for VAT Retailers',0,'0',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG7','Schemes OrderSelection','Popup the reason for non billing while changing the route or closing the billing screen',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG14','Schemes OrderSelection','Include Primary Scheme Amount with Secondary Scheme',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG15','Schemes OrderSelection','Consider Edited Selling rate for Scheme Calculation',0,'',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL5','Discount & Tax Collection','Perform auto confirmation of bill',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL6','Discount & Tax Collection','Automatically perform Vehicle allocation while saving the bill',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLQPS2','Billing QPS Scheme','Enable conversion of Quantity based QPS Scheme as Credit Note',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT7','Purchase Receipt','Allow Refuse Sale in Purchase',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER1','DataTransfer','Automatic check for Internet Connection',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD1','BillConfig_Display','Enable automatic Popup of Salesman and Route in the Bill Tag',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD2','BillConfig_Display','Allow direct Retailer Selection',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD3','BillConfig_Display','Display Retailer based on Coverage Mode in the hotsearch',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD4','BillConfig_Display','Display Retailer based on Route Coverage plan in hotsearch',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD5','BillConfig_Display','Display Messages for Retailer Birthday / Anniversary / Registration - On Retailer Selection',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD6','BillConfig_Display','Populate Products automatically based on the Product sequencing screen settings',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD7','BillConfig_Display','Automatically popup the hotsearch window if the user types in the Product code',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLQPS3','Billing QPS Scheme','Enable conversion of Date based QPS Scheme as Credit Note',1,'1',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD3','Product Master','Update EAN code when downloaded from central server',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD6','Product Master','Allow creation of products manually only under ...',0,'0',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER2','DataTransfer','Time Interval for Net Connection Check -in minute',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER3','DataTransfer','FileFormatSelectionFTP',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER4','DataTransfer','Zip the file while sendingFTP',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT1','BillConfig_RateEdit','Allow Editing of Selling Rate in the billing screen',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT2','BillConfig_RateEdit','Allow Editing of Net Rate in the billing screen',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT3','BillConfig_RateEdit','Allow the user to reduce the amount from batch rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT4','BillConfig_RateEdit','Allow the user to add the amount from batch rate',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT5','BillConfig_RateEdit','Allow both addition and reduction',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT6','BillConfig_RateEdit','Make reason as mandatory if the user is reducing the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER5','DataTransfer','Upload Server Path',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER6','DataTransfer','Download Server Path',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT9','Alert Management','Restrict Billing if CST number is not filling in the Retailer master',0,'0',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT7','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT8','BillConfig_RateEdit','Treat the difference amount as Distributor Discount',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT9','BillConfig_RateEdit','Add the difference amount to Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT10','BillConfig_RateEdit','Make reason as mandatory if the user is adding the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT11','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT12','BillConfig_RateEdit','Add the difference amount to Gross Profit',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT13','BillConfig_RateEdit','Treat the difference amount in Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT14','BillConfig_RateEdit','Allow the user to reduce the amount of Net Rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT15','BillConfig_RateEdit','Allow the user to add the amount of Net Rate',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT16','BillConfig_RateEdit','Allow both addition and reduction',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT17','BillConfig_RateEdit','Make reason as mandatory if the user is reducing the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT18','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT19','BillConfig_RateEdit','Treat the difference amount as Distributor Discount',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT20','BillConfig_RateEdit','Add the difference amount to Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT31','BillConfig_RateEdit','Recalculate Selling rate based on edited Net Rate',0,'',0,31)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT21','BillConfig_RateEdit','Make reason as mandatory if the user is adding the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT22','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT23','BillConfig_RateEdit','Add the difference amount to Gross Profit',0,'',0,1)
GO
 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG10','Schemes OrderSelection','Allow Creation of new Shipping Address by pressing Insert Key',1,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG13','Schemes OrderSelection','Adjust Window Display Schemes only once',0,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL1','Discount & Tax Collection','Allow Editing of Cash Discount in the billing screen',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL3','Discount & Tax Collection','Calculate Tax in Line Level',1,'LEVEL',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SAMPLE3','Sample Maintenance','Create claim for Saleable stock used in Sample Issue',0,'0',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE1','Cheque Payment','Allow bulk updation of Pending Cheques to Banked',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE2','Cheque Payment','Allow bulk updation of Pending Cheques to Settled',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE3','Cheque Payment','Allow bulk updation of Pending Cheques to Bounced',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE5','Cheque Payment','Allow bulk updation of Banked Cheques to Bounced',1,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE7','Cheque Payment','Alert Regarding CDC Cheques at the time of Logging in',1,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN5','Stock Journal','Create Reason as Mantatory',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER9','DataTransfer','Download Server Username',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE6','DebitNoteCreditNote','Not Allow Retailer Details in Account Type Hotsearch Debit Note (Retailer)',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE1','Salvage','Fill Batches automatically when Product is selected',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE6','Salvage','Allow editing of Claim Amount field',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE13','Salvage','Treat Destroy Quantity as Claim Qty',1,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT4','Purchase Receipt','Allow Creation of new Product by Pressing Insert Key',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT5','Purchase Receipt','Allow Creation of new Batch by Pressing Insert Key',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT8','Purchase Receipt','Allow selection of saleable quantity for refusal',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT9','Purchase Receipt','Allow selection of UnSaleable quantity for refusal',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT11','Purchase Receipt','Use Company Product Code for reference in Purchase Receipt',1,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT13','Purchase Receipt','Populate Products Automatically based on the Product Sequencing Screen Settings',0,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER10','DataTransfer','Download Server Password',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT4','Stock Management','Display Vans while searching the Location Name',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('STKMGNT7','Stock Management','Allow Creating new Batches by pressing Insert Key',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT10','Purchase Receipt','Allow saving of Purchase Receipt even if there is a rate difference',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT12','Purchase Receipt','Use Distributor Product Code for reference in Purchase Receipt',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT14','Purchase Receipt','Allow Duplicate Rows',1,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT15','Purchase Receipt','Enable Sample Receipt option through Purchase Receipt Screen',0,'',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT17','Purchase Receipt','Automatically display the default supplier while downloading purchase',1,'',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT16','Purchase Receipt','Allow OID Calculation',0,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT19','Purchase Receipt','Allow Editing of Gross Amount in Purchase Receipt Screen',1,'',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT21','Purchase Receipt','Display Pending Sales Order Servicing Notification while confirming the purchase receipt',0,'',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT22','Purchase Receipt','Allow Manual Calculation while Donwloading Purchase',0,'',0,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS1','Target Analysis','Automatic',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS2','Target Analysis','Company',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS3','Target Analysis','Prd Hier',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS4','Target Analysis','Target Type',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS5','Target Analysis','Auto Confirm Target when',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS6','Target Analysis','Allow Target Saving in',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS7','Target Analysis','Sales between',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS8','Target Analysis','Previous',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS9','Target Analysis','Target Split',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS10','Target Analysis','Allow user to set the Target on Distributors Holidays',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS11','Target Analysis','Display Distributors Holidays in Different Colours',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS12','Target Analysis','Allow user to set the Target on Distributors  Off days',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS13','Target Analysis','Display Distributors Off days in Different Colours',0,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('TARGETANALYSIS14','Target Analysis','Display Retailers Off days in Different Colours',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN1','Sales Return','Allow Editing of Selling Rates in the Sales Return Screen  When no Bill Reference is Selected',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN2','Sales Return','Allow the user to reduce the amount from batch rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN3','Sales Return','Allow the user to add the amount from batch rate',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN4','Sales Return','Allow both addition and reduction',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN5','Sales Return','Make reason as mandatory if the user is reducing the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN6','Sales Return','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN7','Sales Return','Treat the difference amount as Distributor Discount',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN8','Sales Return','Add the difference amount to S R Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN9','Sales Return','Make reason as mandatory if the user is Adding the rate',0,'',0,1)
GO
 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN10','Sales Return','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN11','Sales Return','Add the difference amount to Gross Profit',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN12','Sales Return','Treat the difference amount in S R Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN13','Sales Return','Automatically pop up the hot search window if the user types in the product code',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN14','Sales Return','Make reason as mandatory if the Stock Type is',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN2','Market Return','Allow the user to reduce the amount from batch rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN3','Market Return','Allow the user to add the amount from batch rate',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN11','Market Return','Add the difference amount to Gross Profit',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN12','Market Return','Treat the difference amount in S R Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN13','Market Return','Automatically pop up the hot search window if the user types in the product code',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRDSALBUNDLE2','ProductSalesBundle','Allow Route selection Irrespective of Company selection',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRDSALBUNDLE3','ProductSalesBundle','Display Total Number of Routes attached Irrespective of Company selection',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN1','Market Return','Allow Editing of Selling Rate in the Market Return Screen',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN5','Market Return','Make reason as mandatory if the user is reducing the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN6','Market Return','Raise Claims Based on Reasons Attached',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN7','Market Return','Treat the difference amount as Distributor Discount',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN8','Market Return','Add the difference amount to S R Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('MARKETRTN9','Market Return','Make reason as mandatory if the user is Adding the rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG1','General Configuration','Allow Multi Company Operation',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG2','General Configuration','Run Retailer Class Update Tool at Month End',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG3','General Configuration','Display Dash Board while opening the application',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG4','General Configuration','Connect to Website:',1,'www.botree.co.in',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD8','BillConfig_Display','Fill Batches automatically based on',1,'FIFO',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD9','BillConfig_Display','Set the Tab focus on UOM 1 Once the Batch is selected',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT10','Alert Management','Restrict Billing for Drug Products if Drug Product License Number is not filled in Retailer master',0,'0',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT11','Alert Management','Restrict Billing if License Number is not filled in Retailer master',0,'0',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG2','Schemes OrderSelection','Restrict the user from unchecking the claimable schemes',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG3','Schemes OrderSelection','Allow Selection of Multiple orders',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG11','Schemes OrderSelection','Allow Creation of new reasons by pressing Insert Key',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO10','Purchase Order','Previous',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO11','Purchase Order','Previous',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO16','Purchase Order','Download Suggested PO From Console',1,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO17','Purchase Order','Auto generate PO Based On Company Defined Norms',0,'',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO18','Purchase Order','Enable only addition of quantity',1,'',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO19','Purchase Order','Enable addition and reduction',0,'',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO20','Purchase Order','Enable only reduction of quantity',0,'',0,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO21','Purchase Order','Do not display alert on pending POs',1,'',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO22','Purchase Order','Display daily alert on number of pending POs',0,'',0,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO23','Purchase Order','Display alert on due date on number of pending POs',0,'',0,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO24','Purchase Order','Both Events',0,'',0,24)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO25','Purchase Order','While Logging Out',0,'',0,25)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO28','Purchase Order','Auto Convert at Log Out',1,'',0,28)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO29','Purchase Order','Allow Editing of auto generated quantity',1,'',0,29)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION1','Password Protection','Set the minimum number of digits as                     for Password',1,'',8,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION2','Password Protection','Ask for new password in every                     days',1,'',90,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION3','Password Protection','Password should not be repeated for                    times',1,'',5,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION4','Password Protection','Password should be different from user name',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION5','Password Protection','Make alphanumeric password (cgk123) as mandatory',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION6','Password Protection','Allow special characters (%#$@^) in password field',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION7','Password Protection','Make special characters as mandatory in password field',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION8','Password Protection','Allow keyboard sequence (asdf) and sequential numbers (123)',1,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION9','Password Protection','Allow the password with all numbers, uppercase letters or lowercase letters',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PWDPROTECTION10','Password Protection','Allow using repeating character (aa11)',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER1','Reminder','From Time(HH:MM)',1,'09',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER2','Reminder','From Time(HH:MM)',1,'00',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER3','Reminder','ToTime(HH:MM))',1,'09',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO30','Purchase Order','Alert the user to confirm && Upload open PO',1,'5',0,30)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO31','Purchase Order','Enable PO Confirmation based on user selection',0,'',0,31)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO32','Purchase Order','Automatically confirm all the pending POs on the due date',0,'',0,32)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER4','Reminder','From Time(HH:MM)',1,'00',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER5','Reminder','Set the duration between times(MM)',1,'30',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER6','Reminder','From Time(HH:MM)',1,'0',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('REMINDER7','Reminder','ToTime(HH:MM)',1,'1',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG5','Schemes OrderSelection','Allow partial settlement of Orders in multiple bills',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG9','Schemes OrderSelection','Allow Creation of new Retailers by pressing Insert Key',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE5','DebitNoteCreditNote','Not Allow Supplier Details in Account Type Hotsearch Credit Note (Supplier)',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE10','DebitNoteCreditNote','Retailer Debit Note',1,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE12','DebitNoteCreditNote','Supplier Debit Note',1,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE13','DebitNoteCreditNote','Retailer Credit Note',1,'',0,13)
GO
 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG6','General Configuration','Screen Color',1,'Stocky Default',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG10','General Configuration','Consider Post Dated Cheque for Credit check',0,'Billing/Purchase/Sales Return/Purchase Return',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS1','Day End Process','Allow Modification of Pending Bills up to',0,'0',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BL1','BL Configuration','Automatically create price batches based on selling rate received from Console',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD10','BillConfig_Display','Hide the columns for UOM2 and Qty2',1,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD11','BillConfig_Display','Popup a screen for entering the Batch Number for drug products while billing the drug products',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD12','BillConfig_Display','Display all the Debit Notes while pressing the Debit Note adjustment button',1,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BL2','BL Configuration','Automatically create contract price entry based on new price batch creation',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BL3','BL Configuration','Perform Cheque Bounce based on data received from Console',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD1','Order Booking','Enable Delivery Challan Option',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD2','Order Booking','Focus on Delivery Challan Tab while opening the screen',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD3','Order Booking','Perform Tax Calculation in Delivery Challan',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD4','Order Booking','Prompt the user to convert open DCs to Bill after',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD5','Order Booking','Enable DC to Bill conversion based on user selection',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD6','Order Booking','Automatically bill all the pending DCs on the due date',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD7','Order Booking','Auto Convert the DCs based on individual DC date',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD8','Order Booking','Does not allow transaction if DC is not converted after due date',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD9','Order Booking','Allow deleting Unbilled DCs',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('ORD10','Order Booking','Do not display alert on pending DCs',0,'',0,10)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SAMPLE2','Sample Maintenance','Use Saleable stock for Sample Issue',1,'0',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('JC2','JC Calendar','Allow Manual Entry of Week Start and End dates',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO1','Purchase Order','Auto generates purchase order qty based on norm settings by populating all products automatically based on product sequencing screen settings',0,'0',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO3','Purchase Order','Populate products automatically based on the product sequencing screen settings but not auto generate Purchase Order Qty',0,'0',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO6','Purchase Order','Make Supplier Selection Compulsory in Purchase Order Screen',0,'0',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO7','Purchase Order','Purchase Between',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO8','Purchase Order','Sales Between',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO9','Purchase Order','Purchase Order Between',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO12','Purchase Order','Previous',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO14','Purchase Order','Use Ditributor Product Code for reference in Purchase Order Screen',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO26','Purchase Order','While Logging In',1,'',0,26)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO27','Purchase Order','Auto Confirm at Log In',0,'',0,27)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO33','Purchase Order','Does not allow transaction if PO is not confirmed after due date',0,'',0,33)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO34','Purchase Order','Make Product Hierarchy selection compulsory In Purchase Order Screen',0,'',0,34)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO35','Purchase Order','Display Purchase Order Value',1,'',0,35)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT1','Purchase Receipt','Allow Creation of Purchase Receipt only with or without Purchase Order',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT6','Purchase Receipt','Include provision for entering handling charges in Purchase Receipt',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO2','Purchase Order','Auto generates purchase order qty based on norm settings by manually selecting products',0,'0',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PO4','Purchase Order','Manually select products and not auto generate Purchase Order Qty',1,'0',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT2','Purchase Receipt','Allow Creation of Purchase Receipt only with Purchase Order',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE1','DebitNoteCreditNote','Allow to enter tax breakup for Credit Note (Supplier)',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SJN2','Stock Journal','Allow Creating new Product by pressing Insert Key',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG12','General Configuration','Display default Company,Supplier and Location',1,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD1','Product Master','Treat EAN code field as Mandatory',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD2','Product Master','Allow manual editing of the EAN code even after transactions made for the product',1,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD8','Product Master','Allow manual creation of batches for',1,'~2~3',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD9','Product Master','Don''t allow to edit Product Type',1,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG16','General Configuration','Download the schemes even though the products does not exists in product master',1,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD13','BillConfig_Display','Display all the Credit Notes while pressing the Credit Note adjustment button',1,'',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON1','Scheme Master','Make Retailer Status as Inactive by default for the selected type of schemes',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE3','DebitNoteCreditNote','Allow to enter tax breakup for Credit Note (Retailer)',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE11','DebitNoteCreditNote','Supplier Credit Note',1,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DBCRNOTE14','DebitNoteCreditNote','Retailer Debit Note',1,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRN1','PurchaseReturn','Seek approval from Central System to confirm Purchase Return',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE2','Salvage','Display only UnSaleable Location in the Location search',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE3','Salvage','Display only UnSaleable Stock Types in the Stock Type search',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE4','Salvage','Repeat the first selected reason for all the lines',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CHEQUE6','Cheque Payment','Alert Regarding CDC Cheques at the time of Logging out',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON2','Scheme Master','Get the approval from Central System',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER11','DataTransfer','Archive In Folder FTP',0,'',0,11)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER12','DataTransfer','Archive Out Folder FTP',0,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER13','DataTransfer','No of Days for Deleting Archiving FTP',0,'',30,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER14','DataTransfer','Error Log Folder Ftp',0,'',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER15','DataTransfer','FileFormatSelection HTTP',0,'',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER16','DataTransfer','Zip the file while sending HTTP',1,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER17','DataTransfer','Upload URL Path',0,'',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RTNTOCOMPANY1','ReturnToCompany','Fill Batches automatically once product is selected',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE5','Salvage','Make Reason as mandatory if the Stock Type is :',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE7','Salvage','Allow the edited Amount to be higher than the Actual Amount',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE8','Salvage','Allow Creating new Location by pressing Insert Key',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALVAGE9','Salvage','Allow Creating Stock Type by pressing Insert Key',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN15','Sales Return','Perform automatic Credit Note / Replacement selection entry based on the rule setting',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT3','Purchase Receipt','Allow Creation of Purchase Receipt only without Purchase Order',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG17','General Configuration','Enable Advanced Search Option',1,'0',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN16','Sales Return','Enable Delivery Return Option in Sales Return',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN17','Sales Return','Allow User to Make Direct Sales Return',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeNewBatch','BotreeNewBatch','Allow to create Product Batches only for Industrial Packs',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG18','General Configuration','Show HotSearch in Standard Width',0,'0',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG19','General Configuration','Include Scheme Claims in  Claim Top Sheet',1,'0',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG20','General Configuration','Enable tracking of Unsalable quantity based on transaction reference number',0,'0',0,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeSplRateReCalc','BotreeSplRateReCalc','Recalculate Special Selling Rate for Tax Change',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreePDRate','BotreePDRate','Show PD Rate in Special Rate Module',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeRateDiffOnPDRate','BotreeRateDiffOnPDRate','Raise Rate Diff Claim based on PD Rate',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeUpload01','Botree Upload','Upload Default Company Product details alone',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeBillPrinting01','Botree Bill Printing','Group the batches based on the rate for non drug products',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeRateForOldBatch','Botree Product Batch Download','Update New Rate for Old Batches also',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER18','DataTransfer','Download URL Path',0,'',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG9','General Configuration','Display Batch automatically when single batch is available in the attached screens',1,'Billing/Purchase/Sales Return/Purchase Return',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG21','General Configuration','Display MRP in Product Hot Search Screen',0,'',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG22','General Configuration','Display Quantity in UOM based',0,'0',0,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG23','General Configuration','Treat Special Rate as Default Selling Rate',0,'0',0,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG24','General Configuration','Treat Supplier Tax Group as Manadatory',1,'0',0,24)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG28','General Configuration','Show Dash Board',1,'',3,28)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG7','General Configuration','1.00',1,'5',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG8','General Configuration','Nearest',1,'0',1,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG13','General Configuration','Currency',1,'Rupees',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG14','General Configuration','Coin',1,'Paise',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG15','General Configuration','Currency Display Format',1,'0',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG25','General Configuration','Allow conversion of claim as credit/debit note',1,'0',0,25)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS2','Day End Process','Block the user to perform transaction if day end is not done for',0,'0',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS3','Day End Process','Perform automatic delivery of pending Bills with Day End',0,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS4','Day End Process','Perform automatic delivery of pending Bills after                     day(s)',1,'4',1,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS5','Day End Process','Perform automatic delivery of pending Bills while extracting data',0,'0',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DAYENDPROCESS6','Day End Process','Allow Automatic Delivery',1,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER19','DataTransfer','Server Webservice Path',0,'',0,19)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER20','DataTransfer','Archive In Folder HTTP',0,'',0,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER21','DataTransfer','Archive Out Folder HTTP',0,'',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER22','DataTransfer','No of Days for Deleting Archiving HTTP',0,'',30,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER23','DataTransfer','Error Log Folder Ftp',0,'',0,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT12','Alert Management','Restrict Billing if Pesticide License Number is not filled in Retailer master',0,'0',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT13','Alert Management','Alert if Shelf Life of the selected Batch is',0,'0',0,13)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILALERTMGNT14','Alert Management','Alert if Expiry Date of the selected Batch is',0,'0',0,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG1','Schemes OrderSelection','Automatically apply the schemes other than flexi scheme',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG4','Schemes OrderSelection','Treat the order as closed once selected in the Bill',0,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG6','Schemes OrderSelection','Hide retailer details in the Order Selection screen if user selects the order after selecting the re',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG8','Schemes OrderSelection','Set the default reason as',1,'1',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHEMESTNG12','Schemes OrderSelection','Display all Window Dispaly Schemes by pressing Insert Key',1,'',0,12)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DISTAXCOLL4','Discount & Tax Collection','Post Vouchers on Delivery date',1,'1',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLQPS1','Billing QPS Scheme','Enable conversion of QPS Scheme as Credit Note',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD4','Product Master','Allow same EAN code for multiple products',1,'',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD5','Product Master','Set Default Product Tax Group as',0,'',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PRD7','Product Master','Allow manual creation of products as',1,'~2~3',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SAMPLE1','Sample Maintenance','Allow Sample Issue without rule setting',1,'0',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG26','General Configuration','Save excel reports in',0,'',0,26)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG27','General Configuration','Enable Database restoration check',0,'',0,27)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER24','DataTransfer','FileFormatSelection Email',0,'',0,24)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreePrdBatEff','Botree PrdBat Download','Botree Product Batch based on Effective Date',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET18','Retailer','Enable Retailer Status Update Lock',0,'0',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET20','Retailer','Automatically inactivate the retailer if not approved                      Days',0,'0',0,20)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET21','Retailer','Change retailer status inactive if the norm is violater for',0,'0',0,21)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET22','Retailer','Credit Norm - Credit Bills',0,'0',0,22)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET23','Retailer','Credit Norm - Credit Limit',0,'0',0,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET24','Retailer','Credit Norm - Credit Days',0,'0',0,24)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET25','Retailer','Automatically activate the retailer once the norm is reinstated',0,'0',0,25)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET27','Retailer','Change the Retailer Status as Inactive if the following Credit Norm is Violated Before Approval',0,'0',0,27)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET28','Retailer','Credit Norm Approval - Credit Bills',0,'0',0,28)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET29','Retailer','Credit Norm Approval - Credit Limit',0,'0',0,29)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET30','Retailer','Credit Norm Approval - Credit Days',0,'0',0,30)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET31','Retailer','Automattically Activate the Retailer once the Pre-Approval Norm is Reinstated',0,'0',0,31)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET32','Retailer','Allow Billing for unapproved retailers up to Number of bills',0,'0',0,32)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET33','Retailer','Display Company Retailer Code',1,'',0,33)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RET34','Retailer','Does not allow editing of Key Account after approval',0,'',0,34)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER7','DataTransfer','Upload Server Username',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER25','DataTransfer','Zip the file while sending Email',0,'',0,25)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER26','DataTransfer','POP3 Server Username',0,'',0,26)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER27','DataTransfer','POP3 Server Password',0,'',0,27)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER28','DataTransfer','From Email ID',0,'',0,28)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER29','DataTransfer','Allow Automatic Deployment',1,'',0,29)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER30','DataTransfer','Dowload files from',2,'',0,30)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER31','DataTransfer','Server Path',0,'http://124.153.94.28/JNJLive/',0,31)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER32','DataTransfer','Deployment Server Path',0,'LATEST_RELEASE/',0,32)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER33','DataTransfer','User Name',0,'',0,33)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER34','DataTransfer','Password',0,'',0,34)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER35','DataTransfer','Updates Folder',0,'C:\Program Files\Core Stocky\New Release',0,35)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER36','DataTransfer','LAN Server Path',0,'\\Gemini-1\New Release',0,36)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER37','DataTransfer','Deploy Error Log Folder',0,'C:\Program Files\Core Stocky\Deploy ErrorLog',0,37)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER38','DataTransfer','Out Master',0,'OUT_MAST/',0,38)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER39','DataTransfer','Out Trans',0,'OUT_TRANS/',0,39)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER40','DataTransfer','WebService',0,'CoreStockyWS/CoreStocky',0,40)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER41','DataTransfer','Perform Sync Process during',1,'',0,41)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER42','DataTransfer','Perform Automatic Sync Process after the  grace period  of                       days',0,'',0,42)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER43','DataTransfer','Alert user to do Sync Process for every                      minute(s) after the grace period of                       day(s)',0,'0',0,43)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER44','DataTransfer','Upload Path',1,'http://124.153.94.28/JNJIntegration3.0/Pos2Console.asmx',0,44)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER45','DataTransfer','Download Path',1,'http://124.153.94.28/JNJIntegration3.0/Console2Pos.asmx',0,45)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD14','BillConfig_Display','Display Retailer Based On',1,'Name',1,14)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD15','BillConfig_Display','Enable bill to bill copying option',1,'',0,15)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD16','BillConfig_Display','Invoke sample issue screen by pressing key combination',1,'',0,16)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD17','BillConfig_Display','Enable DC Option in Billing',0,'',0,17)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BCD18','BillConfig_Display','Display total saleable quantity in product hotsearch',1,'',0,18)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN18','Sales Return','Based on Slab Applied',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SALESRTN19','Sales Return','Based on Slab Eligible',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeFBM','Botree FBM','Track FBM on Purchase,Sales for Scheme',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeRefNo','BotreeCounters','Seperate Prefix and Suffix by -',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER46','DataTransfer','Sync Check Path',1,'',0,46)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('DATATRANSFER8','DataTransfer','Upload Server Password',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('GENCONFIG5','General Configuration','Calculation Decimal Digit Value',1,'',3,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('PURCHASERECEIPT23','Purchase Receipt','Populate Net Amount as Net Payable Amount',0,'',0,23)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeAllowZeroTax','BotreeAllowZeroTax','Allow 0% Tax in Reports',1,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('CONPRICE','Contract Pricing','Show Claimable % on MRP',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeAttendance','BotreeAttendance','Upload Attendance Register at end of Calendar Month or JC Month',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeSyncErrLog','BotreeSyncErrLog','Delete the Error Log file on every Sync',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeSyncCheck','BotreeSyncCheck','Perform Sync Check',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BotreeReDownload','BotreeReDownload','Perform Redownload',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT24','BillConfig_RateEdit','Treat the difference amount in Rate Difference Claim',0,'',0,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT30','BillConfig_RateEdit','Recalculate Selling rate based on edited Net Rate',0,'',0,30)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('BILLRTEDIT25','BillConfig_RateEdit','Allow Editing Selling Rate > MRP',0,'',0,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON3','Scheme Master','Apply only discount when both Scheme and Discount are applicable',1,'',0,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON4','Scheme Master','Allow user to create',0,'-1',0,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON5','Scheme Master','Treat budget amount as mandatory if claimable condition is set as',0,'-1',0,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON6','Scheme Master','While budget exceed,allow billing',0,'',0,6)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON7','Scheme Master','Prompt message for budget exceeded schemes',0,'',0,7)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON8','Scheme Master','Allow user to define the same slab using combination of products',0,'',0,8)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('SCHCON9','Scheme Master','Allow to edit downloaded scheme',0,'',0,9)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RCS1','RetailerClassShift','Perform class shift automatically during login',1,'',1,1)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RCS2','RetailerClassShift','Consider last                      month(s) sales',1,'',3,2)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RCS3','RetailerClassShift','Calculate Turnover based on',1,'',2,3)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RCS4','RetailerClassShift','Consider salesreturn for calculation',1,'',1,4)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RCS5','RetailerClassShift','Perform class shift on',1,'',1,5)

 INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) VALUES ('RCS6','RetailerClassShift','Perform class shift',1,'',1,6)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('BILLQPS4','Billing QPS Scheme','Alert if QPS scheme is applicable with Pending Bills',0,'',0.00,4)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('COLL15','Collection Register','Perform Account Posting for Cheques',0,'',NULL,15)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('DISTAXCOLL7','Discount & Tax Collection','Enable Bill Book Number Tracking in Billing Screen',	1,'',0,7)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('DISTAXCOLL8','Discount & Tax Collection','Enable Invoice Level Discount field in the Billing Screen',1,'',0,8)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('PO36','Purchase Order','Display total volume of order (KG + Ltr + Unit)',0,'',0,36)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('PURCHASERECEIPT26','Purchase Receipt','Display MRP column in Purchase Receipt Screen',1,0,0,26)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('PURCHASERECEIPT27','Purchase Receipt','Alert user when tax is not calculated',	1,0,0,27)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('RET36','Retailer',	'Set VAT as default ''Tax'' Type',1,0,0,36)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('SCHCON13','Scheme Master','Enable Settlement Type in Scheme Master',0,'',0,13)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('SCHCON14','Scheme Master','Restrict the user from un-checking the claimable schemes during billing process',1,0,0,14)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('STKMGNT12','Stock Management','Enable selection of transaction type at grid level',0,'',0,12)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('BotreeMultiUser','BotreeMultiUser','Enable Multi User Validation',0,'',0.00,1)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('RET37','Retailer','Enable Selection of Discount % in retailer master',0,'0',0.00,37)

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)  VALUES ('RETREP2','RetReplacement','Allow user to save Replacement without Return Product(s)',0,'0',0.00,2)

GO

  -- DEFAULT VALUES SCRIPT FOR Tbl_DownloadIntegration

 DELETE FROM Tbl_DownloadIntegration
 GO
 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (1,'Hierarchy Level','Cn2Cs_Prk_HierarchyLevel','Proc_Import_HierarchyLevel',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (2,'Hierarchy Level Value','Cn2Cs_Prk_HierarchyLevelValue','Proc_Import_HierarchyLevelValue',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (3,'Retailer Hierarchy','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (4,'Retailer Classification','Cn2Cs_Prk_BLRetailerValueClass','Proc_ImportBLRetailerValueClass',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (5,'Prefix Master','Cn2Cs_Prk_PrefixMaster','Proc_Import_PrefixMaster',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (6,'Retailer Approval','Cn2Cs_Prk_RetailerApproval','Proc_Import_RetailerApproval',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (7,'UOM','Cn2Cs_Prk_BLUOM','Proc_ImportBLUOM',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (8,'Tax Configuration Group Setting','Etl_Prk_TaxConfig_GroupSetting','Proc_ImportTaxMaster',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (9,'Tax Settings','Etl_Prk_TaxSetting','Proc_ImportTaxConfigGroupSetting',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (10,'Product Hierarchy Change','Cn2Cs_Prk_BLProductHiereachyChange','Proc_ImportBLProductHiereachyChange',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (11,'Product','Cn2Cs_Prk_Product','Proc_Import_Product',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (12,'Product Batch','Cn2Cs_Prk_ProductBatch','Proc_Import_ProductBatch',7,200,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (13,'Product Tax Mapping','Etl_Prk_TaxMapping','Proc_ImportTaxGrpMapping',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (14,'Special Rate','Cn2Cs_Prk_SpecialRate','Proc_Import_SpecialRate',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (15,'Scheme Header Slabs Rules','Etl_Prk_SchemeHD_Slabs_Rules','Proc_ImportSchemeHD_Slabs_Rules',0,100,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (16,'Scheme Products','Etl_Prk_SchemeProducts_Combi','Proc_ImportSchemeProducts_Combi',0,100,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (17,'Scheme Attributes','Etl_Prk_Scheme_OnAttributes','Proc_ImportScheme_OnAttributes',0,100,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (18,'Scheme Free Products','Etl_Prk_Scheme_Free_Multi_Products','Proc_ImportScheme_Free_Multi_Products',0,100,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (19,'Scheme On Another Product','Etl_Prk_Scheme_OnAnotherPrd','Proc_ImportScheme_OnAnotherPrd',0,100,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (20,'Scheme Retailer Validation','Etl_Prk_Scheme_RetailerLevelValid','Proc_ImportScheme_RetailerLevelValid',0,100,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (21,'Purchase','Cn2Cs_Prk_BLPurchaseReceipt','Proc_ImportBLPurchaseReceipt',7,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (22,'Purchase Return','Cn2Cs_Prk_PurchaseReturnApproval','Proc_ImportPurchaseReturnApproval',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (23,'Scheme Master Control','Cn2Cs_Prk_NVSchemeMasterControl','Proc_ImportNVSchemeMasterControl',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (24,'Claim Norm','Cn2Cs_Prk_ClaimNorm','Proc_Import_ClaimNorm',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (25,'Reason Master','Cn2Cs_Prk_ReasonMaster','Proc_Import_ReasonMaster',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (26,'Bulletin Board','Cn2Cs_Prk_BulletinBoard','Proc_Import_BulletinBoard',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (27,'ReUpload','Cn2Cs_Prk_ReUpload','Proc_Import_ReUpload',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (28,'Configuration','Cn2Cs_Prk_Configuration','Proc_Import_Configuration',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (29,'UDC Master','Cn2Cs_Prk_UDCMaster','Proc_Import_UDCMaster',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (30,'Retailer Migration','Cn2Cs_Prk_RetailerMigration','Proc_Import_RetailerMigration',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (31,'UDC Details','Cn2Cs_Prk_UDCDetails','Proc_Import_UDCDetails',3672,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (32,'UDC Defaults','Cn2Cs_Prk_UDCDefaults','Proc_Import_UDCDefaults',0,500,'2011-Aug-01 18:58:52')

 INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) VALUES (33,'Scheme Combi Criteria','Etl_Prk_Scheme_CombiCriteria','Proc_ImportBLSchemeCombiCriteria',0,500,'2011-09-15 15:18:35.687')

GO
 -- DEFAULT VALUES SCRIPT FOR Tbl_UploadIntegration

 DELETE FROM Tbl_UploadIntegration
 GO
 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (1,'Upload Record Check','UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (2,'Retailer','Retailer','Cs2Cn_Prk_Retailer','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (3,'Daily Sales','Daily_Sales','Cs2Cn_Prk_DailySales','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (4,'Stock','Stock','Cs2Cn_Prk_Stock','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (5,'Sales Return','Sales_Return','Cs2Cn_Prk_SalesReturn','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (6,'Purchase Confirmation','Purchase_Confirmation','Cs2Cn_Prk_PurchaseConfirmation','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (7,'Purchase Return','Purchase_Return','Cs2Cn_Prk_PurchaseReturn','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (8,'Claims','Claims','Cs2Cn_Prk_ClaimAll','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (9,'Scheme Utilization','Scheme_Utilization','Cs2Cn_Prk_SchemeUtilization','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (10,'Sample Issue','Sample_Issue','Cs2Cn_Prk_SampleIssue','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (11,'Sample Receipt','Sample_Receipt','Cs2Cn_Prk_SampleReceipt','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (12,'Sample Return','Sample_Return','Cs2Cn_Prk_SampleReturn','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (13,'Download Tracing','DownloadTracing','Cs2Cn_Prk_DownLoadTracing','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (14,'Upload Tracing','UploadTracing','Cs2Cn_Prk_UpLoadTracing','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (15,'Daily Retailer Details','Daily_Retailer_Details','Cs2Cn_Prk_DailyRetailerDetails','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (16,'Daily Product Details','Daily_Product_Details','Cs2Cn_Prk_DailyProductDetails','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (17,'Salesman','Salesman','Cs2Cn_Prk_Salesman','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (18,'Route','Route','Cs2Cn_Prk_Route','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (19,'Route Coverage Plan','Route_Coverage_Plan','Cs2Cn_Prk_RouteCoveragePlan','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (20,'Attendance Register','Attendance_Register','Cs2Cn_Prk_AttendanceRegister','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (21,'FBM Track','FBM_Track','Cs2Cn_Prk_FBMTrack','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (22,'UDC Details','UDC_Details','Cs2Cn_Prk_UDCDetails','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (23,'Retailer Route','Retailer_Route','Cs2Cn_Prk_RetailerRoute','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (24,'Order Booking','Order_Booking','Cs2Cn_Prk_OrderBooking','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (25,'Sales Invoice Orders','Sales_Invoice_Orders','Cs2Cn_Prk_SalesInvoiceOrders','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (26,'Scheme Claim Details','Scheme_Claim_Details','Cs2Cn_Prk_Claim_SchemeDetails','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (27,'Daily Business Details','Daily_Business_Details','Cs2Cn_Prk_DailyBusinessDetails','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (28,'DB Details','DB_Details','Cs2Cn_Prk_DBDetails','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (29,'ProductWiseStock','ProductWiseStock','Cs2Cn_Prk_ProductWiseStock','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (1001,'ReUpload Initiate','ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','2011-Aug-01 18:58:52')

 INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) VALUES (1002,'Downloaded Details','Downloaded_Details','Cs2Cn_Prk_DownloadedDetails','2011-Aug-01 18:58:52')

GO
 -- DEFAULT VALUES SCRIPT FOR CustomUpDownload

 DELETE FROM CustomUpDownload
 GO
 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (101,1,'Retailer','Retailer','Proc_Cs2Cn_Retailer','Proc_ImportRetailer','Cs2Cn_Prk_Retailer','Proc_CN2CSRetailer','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (102,1,'Daily Sales','Daily Sales','Proc_Cs2Cn_DailySales','Proc_ImportBLDailySales','Cs2Cn_Prk_DailySales','Proc_ValidateDailySales','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (103,1,'Stock','Stock','Proc_Cs2Cn_Stock','Proc_ImportStock','Cs2Cn_Prk_Stock','Proc_ValidateStock','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (104,1,'Sales Return','Sales Return','Proc_Cs2Cn_SalesReturn','Proc_ImportBLSalesReturn','Cs2Cn_Prk_SalesReturn','Proc_CN2CSBLSalesReturn','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (105,1,'Purchase Confirmation','Purchase Confirmation','Proc_Cs2Cn_PurchaseConfirmation','Proc_ImportPurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','Proc_CN2CSBLPurchaseConfirmation','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (106,1,'Purchase Return','Purchase Return','Proc_Cs2Cn_PurchaseReturn','Proc_ImportPurchaseReturn','Cs2Cn_Prk_PurchaseReturn','Proc_CN2CSPurchaseReturn','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (107,1,'Claims','Claims','Proc_Cs2Cn_ClaimAll','Proc_ImportBLClaimAll','Cs2Cn_Prk_ClaimAll','Proc_Cn2Cs_BLClaimAll','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (108,1,'Sample Issue','Sample Issue','Proc_Cs2Cn_SampleIssue','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleIssue','Proc_ValidateSampleIssue','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (109,1,'Sample Receipt','Sample Receipt','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReceipt','Proc_ValidateSampleIssue','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (110,1,'Sample Return','Sample Return','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReturn','Proc_ValidateSampleIssue','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (111,1,'Scheme Utilization','Scheme Utilization','Proc_Cs2Cn_SchemeUtilization','Proc_Import_SchemeUtilization','Cs2Cn_Prk_SchemeUtilization','Proc_Cn2Cs_SchemeUtilization','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (112,1,'Download Trace','DownloadTracing','Proc_Cs2Cn_DownLoadTracing','Proc_ImportDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','Proc_Cn2CsDownLoadTracing','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (113,1,'Upload Trace','UploadTracing','Proc_Cs2Cn_UpLoadTracing','Proc_ImportUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','Proc_Cn2CsUpLoadTracing','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (114,1,'Daily Retailer Details','Daily Retailer Details','Proc_Cs2Cn_DailyRetailerDetails','','Cs2Cn_Prk_DailyRetailerDetails','','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (115,1,'Daily Product Details','Daily Product Details','Proc_Cs2Cn_DailyProductDetails','','Cs2Cn_Prk_DailyProductDetails','','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (116,1,'Salesman','Salesman','Proc_Cs2Cn_Salesman','Proc_Import_Salesman','Cs2Cn_Prk_Salesman','Proc_Cn2Cs_Salesman','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (117,1,'Route','Route','Proc_Cs2Cn_Route','Proc_Import_Route','Cs2Cn_Prk_Route','Proc_Cn2Cs_Route','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (118,1,'Route Coverage Plan','Route Coverage Plan','Proc_Cs2Cn_RouteCoveragePlan','Proc_Import_RouteCoveragePlan','Cs2Cn_Prk_RouteCoveragePlan','Proc_Cn2Cs_RouteCoveragePlan','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (119,1,'Attendance Register','Attendance Register','Proc_Cs2Cn_AttendanceRegister','Proc_Import_AttendanceRegister','Cs2Cn_Prk_AttendanceRegister','Proc_Cn2Cs_AttendanceRegister','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (120,1,'FBM Track','FBM Track','Proc_Cs2Cn_FBMTrack','Proc_Import_FBMTrack','Cs2Cn_Prk_FBMTrack','Proc_Cn2Cs_FBMTrack','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (121,1,'UDC Details','UDC Details','Proc_Cs2Cn_UDCDetails','Proc_Import_UDCDetails','Cs2Cn_Prk_UDCDetails','Proc_Cn2Cs_UDCDetails','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (122,1,'Retailer Route','Retailer Route','Proc_Cs2Cn_RetailerRoute','Proc_Import_RetailerRoute','Cs2Cn_Prk_RetailerRoute','Proc_Cn2Cs_RetailerRoute','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (123,1,'Order Booking','Order Booking','Proc_Cs2Cn_OrderBooking','Proc_Import_OrderBooking','Cs2Cn_Prk_OrderBooking','Proc_Cn2Cs_OrderBooking','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (124,1,'Sales Invoice Orders','Sales Invoice Orders','Proc_Cs2Cn_Dummy','Proc_Import_SalesInvoiceOrders','Cs2Cn_Prk_SalesInvoiceOrders','Proc_Cn2Cs_SalesInvoiceOrders','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (125,1,'Scheme Claim Details','Scheme Claim Details','Proc_Cs2Cn_Dummy','Proc_Import_SchemeClaimDetails','Cs2Cn_Prk_Claim_SchemeDetails','Proc_Cn2Cs_SchemeClaimDetails','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (126,1,'Daily Business Details','Daily Business Details','Proc_Cs2Cn_DailyBusinessDetails','Proc_Import_DailyBusinessDetails','Cs2Cn_Prk_DailyBusinessDetails','Proc_Cn2Cs_DailyBusinessDetails','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (127,1,'DB Details','DB Details','Proc_Cs2Cn_DBDetails','Proc_Import_DBDetails','Cs2Cn_Prk_DBDetails','Proc_Cn2Cs_DBDetails','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (128,1,'ProductWiseStock','ProductWiseStock','Proc_Cs2Cn_ProductWiseStock','Proc_Import_ProductWiseStock','Cs2Cn_Prk_ProductWiseStock','Proc_Cn2Cs_ProductWiseStock','Master','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (130,1,'ReUpload Initiate','ReUploadInitiate','Proc_Cs2Cn_ReUploadInitiate','','Cs2Cn_Prk_ReUploadInitiate','','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (131,1,'For Integration','ForIntegration','Proc_IntegrationHouseKeeping','','Cs2Cn_Prk_IntegrationHouseKeeping','','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (201,1,'Hierarchy Level','Hieararchy Level','Proc_Cs2Cn_HierarchyLevel','Proc_Import_HierarchyLevel','Cn2Cs_Prk_HierarchyLevel','Proc_Cn2Cs_HierarchyLevel','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (202,1,'Hierarchy Level Value','Hieararchy Level Value','Proc_Cs2Cn_HierarchyLevelValue','Proc_Import_HierarchyLevelValue','Cn2Cs_Prk_HierarchyLevelValue','Proc_Cn2Cs_HierarchyLevelValue','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (203,1,'Retailer Category Level Value','Retailer Category Level Value','Proc_CS2CNBLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_Cn2Cs_BLRetailerCategoryLevelValue','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (204,1,'Retailer Value Classification','Retailer Value Classification','Proc_CS2CNBLRetailerValueClass','Proc_ImportBLRetailerValueClass','Cn2Cs_Prk_BLRetailerValueClass','Proc_Cn2Cs_BLRetailerValueClass','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (205,1,'Prefix Master','Prefix Master','Proc_Cs2Cn_PrefixMaster','Proc_Import_PrefixMaster','Cn2Cs_Prk_PrefixMaster','Proc_Cn2Cs_PrefixMaster','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (206,1,'Retailer Aproval','Retailer Approval','Proc_Cs2Cn_RetailerApproval','Proc_Import_RetailerApproval','Cn2Cs_Prk_RetailerApproval','Proc_Cn2Cs_RetailerApproval','Master','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (207,1,'UOM','UOM','Proc_Cn2Cs_BLUOM','Proc_ImportBLUOM','Cn2Cs_Prk_BLUOM','Proc_Cn2Cs_BLUOM','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (208,1,'Tax Configuration','Tax Configuration','Proc_ValidateTaxConfig_Group','Proc_ImportTaxMaster','Etl_Prk_TaxConfig_GroupSetting','Proc_ValidateTaxConfig_Group','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (209,1,'Tax Setting','Tax Setting','Proc_CN2CS_TaxSetting','Proc_ImportTaxConfigGroupSetting','Etl_Prk_TaxSetting','Proc_CN2CS_TaxSetting','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (210,1,'Product Hierarchy Change','Product Hierarchy Change','Proc_CS2CNBLProductHierarchyChange','Proc_ImportBLProductHiereachyChange','Cn2Cs_Prk_BLProductHiereachyChange','Proc_Cn2Cs_BLProductHiereachyChange','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (211,1,'Product','Product','Proc_Cs2Cn_Product','Proc_Import_Product','Cn2Cs_Prk_Product','Proc_Cn2Cs_Product','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (212,1,'Product Batch','Product Batch','Proc_Cs2Cn_ProductBatch','Proc_Import_ProductBatch','Cn2Cs_Prk_ProductBatch','Proc_Cn2Cs_ProductBatch','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (213,1,'Tax Group Mapping','Tax Group Mapping','Proc_ValidateTaxMapping','Proc_ImportTaxGrpMapping','Etl_Prk_TaxMapping','Proc_ValidateTaxMapping','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (214,1,'Special Rate','Special Rate','Proc_Cs2Cn_SpecialRate','Proc_Import_SpecialRate','Cn2Cs_Prk_SpecialRate','Proc_Cn2Cs_SpecialRate','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (215,1,'Scheme','Scheme Master','Proc_CS2CNBLSchemeMaster','Proc_ImportBLSchemeMaster','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeMaster','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (215,2,'Scheme','Scheme Attributes','Proc_CS2CNBLSchemeAttributes','Proc_ImportBLSchemeAttributes','Etl_Prk_Scheme_OnAttributes','Proc_CN2CS_BLSchemeAttributes','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (215,3,'Scheme','Scheme Products','Proc_CS2CNBLSchemeProducts','Proc_ImportBLSchemeProducts','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeProducts','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (215,4,'Scheme','Scheme Slabs','Proc_CS2CNBLSchemeSlab','Proc_ImportBLSchemeSlab','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeSlab','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (215,5,'Scheme','Scheme Rule Setting','Proc_CS2CNBLSchemeRulesetting','Proc_ImportBLSchemeRulesetting','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeRulesetting','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (215,6,'Scheme','Scheme Free Products','Proc_CS2CNBLSchemeFreeProducts','Proc_ImportBLSchemeFreeProducts','Etl_Prk_Scheme_Free_Multi_Products','Proc_CN2CS_BLSchemeFreeProducts','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (129,1,'Upload Record Check','UploadRecordCheck','Proc_Cs2Cn_UploadRecordCheck','','Cs2Cn_Prk_UploadRecordCheck','','Transaction','Upload',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (215,7,'Scheme','Scheme Combi Products','Proc_CS2CNBLSchemeCombiPrd','Proc_ImportBLSchemeCombiPrd','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeCombiPrd','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (215,8,'Scheme','Scheme On Another Product','Proc_CS2CNBLSchemeOnAnotherPrd','Proc_ImportBLSchemeOnAnotherPrd','Etl_Prk_Scheme_OnAnotherPrd','Proc_CN2CS_BLSchemeOnAnotherPrd','Transaction','Download',0)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (216,1,'Purchase Receipt','Purchase Receipt','Proc_CS2CNBLPurchaseReceipt','Proc_ImportBLPurchaseReceipt','Cn2Cs_Prk_BLPurchaseReceipt','Proc_Cn2Cs_PurchaseReceipt','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (217,1,'Purchase Return Approval','Purchase Return Approval','Proc_Cs2Cn_PurchaseReturnApproval','Proc_Import_PurchaseReturnApproval','Cn2Cs_Prk_PurchaseReturnApproval','Proc_Cn2Cs_PurchaseReturnApproval','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (218,1,'Scheme Master Control','Scheme Master Control','Proc_CS2CNNVSchemeMasterControl','Proc_ImportNVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','Proc_Cn2Cs_NVSchemeMasterControl','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (219,1,'Claim Norm Mapping','Claim Norm Mapping','Proc_Cs2Cn_ClaimNorm','Proc_Import_ClaimNorm','Cn2Cs_Prk_ClaimNorm','Proc_Cn2Cs_ClaimNorm','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (220,1,'Reason Master','Reason Master','Proc_Cs2Cn_ReasonMaster','Proc_Import_ReasonMaster','Cn2Cs_Prk_ReasonMaster','Proc_Cn2Cs_ReasonMaster','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (222,1,'Bulletin Board','BulletingBoard','Proc_Cs2Cn_BulletinBoard','Proc_Import_BulletinBoard','Cn2Cs_Prk_BulletinBoard','Proc_Cn2Cs_BulletinBoard','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (223,1,'ReUpload','ReUpload','Proc_Cs2Cn_ReUpload','Proc_Import_ReUpload','Cn2Cs_Prk_ReUpload','Proc_Cn2Cs_ReUpload','Transaction','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (224,1,'Configuration','Configuration','Proc_Cs2Cn_Configuration','Proc_Import_Configuration','Cn2Cs_Prk_Configuration','Proc_Cn2Cs_Configuration','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (225,1,'UDC Master','UDC Master','Proc_Cs2Cn_UDCMaster','Proc_Import_UDCMaster','Cn2Cs_Prk_UDCMaster','Proc_Cn2Cs_UDCMaster','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (226,1,'Retailer Migration','Retailer Migration','Proc_Cs2Cn_RetailerMigration','Proc_Import_RetailerMigration','Cn2Cs_Prk_RetailerMigration','Proc_Cn2Cs_RetailerMigration','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (227,1,'UDC Details','UDC Details','Proc_Cs2Cn_UDCDetailss','Proc_Import_UDCDetails','Cn2Cs_Prk_UDCDetails','Proc_Cn2Cs_UDCDetails','Master','Download',1)

 INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) VALUES (228,1,'UDC Defaults','UDC Defaults','Proc_Cs2Cn_UDCDefaults','Proc_Import_UDCDefaults','Cn2Cs_Prk_UDCDefaults','Proc_Cn2Cs_UDCDefaults','Master','Download',1)

GO
 -- DEFAULT VALUES SCRIPT FOR CustomUpDownloadCount

 DELETE FROM CustomUpDownloadCount
 GO
 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (101,1,'Retailer','Retailer','Cs2Cn_Prk_Retailer','Cs2Cn_Prk_Retailer','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (102,1,'Daily Sales','Daily Sales','Cs2Cn_Prk_DailySales','Cs2Cn_Prk_DailySales','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (103,1,'Stock','Stock','Cs2Cn_Prk_Stock','Cs2Cn_Prk_Stock','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (104,1,'Sales Return','Sales Return','Cs2Cn_Prk_SalesReturn','Cs2Cn_Prk_SalesReturn','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (105,1,'Purchase Confirmation','Purchase Confirmation','Cs2Cn_Prk_PurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (106,1,'Purchase Return','Purchase Return','Cs2Cn_Prk_PurchaseReturn','Cs2Cn_Prk_PurchaseReturn','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (107,1,'Claims','Claims','Cs2Cn_Prk_ClaimAll','Cs2Cn_Prk_ClaimAll','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (108,1,'Sample Issue','Sample Issue','Cs2Cn_Prk_SampleIssue','Cs2Cn_Prk_SampleIssue','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (109,1,'Sample Receipt','Sample Receipt','Cs2Cn_Prk_SampleReceipt','Cs2Cn_Prk_SampleReceipt','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (110,1,'Sample Return','Sample Return','Cs2Cn_Prk_SampleReturn','Cs2Cn_Prk_SampleReturn','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (111,1,'Scheme Utilization','Scheme Utilization','Cs2Cn_Prk_SchemeUtilization','Cs2Cn_Prk_SchemeUtilization','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (112,1,'Download Trace','DownloadTracing','ETL_PRK_CS2CNDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (113,1,'Upload Trace','UploadTracing','ETL_PRK_CS2CNUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (114,1,'Upload Record Check','UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (115,1,'ReUpload Initiate','ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (116,1,'For Integration','ForIntegration','Cs2Cn_Prk_IntegrationHouseKeeping','Cs2Cn_Prk_IntegrationHouseKeeping','','','','Upload','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (201,1,'Hierarchy Level','Hieararchy Level','Cn2Cs_Prk_HierarchyLevel','Cn2Cs_Prk_HierarchyLevel','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (202,1,'Hierarchy Level Value','Hieararchy Level Value','Cn2Cs_Prk_HierarchyLevelValue','Cn2Cs_Prk_HierarchyLevelValue','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (203,1,'Retailer Category Level Value','Retailer Category Level Value','Cn2Cs_Prk_BLRetailerCategoryLevelValue','RetailerCategory','CtgMainId','','','Download','29',29,'29',29,0,'SELECT CtgCode AS [Category Code],CtgName AS [Category Name] FROM RetailerCategory WHERE CtgMainId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (204,1,'Retailer Value Classification','Retailer Value Classification','Cn2Cs_Prk_BLRetailerValueClass','RetailerValueClass','RtrClassId','','','Download','177',104,'177',104,0,'SELECT ValueClassCode AS [Class Code],ValueClassName AS [Class Name] FROM RetailerValueClass WHERE RtrClassId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (205,1,'Prefix Master','Prefix Master','Cn2Cs_Prk_PrefixMaster','Cn2Cs_Prk_PrefixMaster','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (206,1,'Retailer Aproval','Retailer Approval','Cn2Cs_Prk_RetailerApproval','Cn2Cs_Prk_RetailerApproval','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (207,1,'UOM','UOM','Cn2Cs_Prk_BLUOM','UOMMaster','UOMId','','','Download','5',5,'5',5,0,'SELECT UomCode AS [UOM Code],UomDescription AS [UOM Desc] FROM UOMMaster WHERE UomId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (208,1,'Tax Configuration','Tax Configuration','Etl_Prk_TaxConfig_GroupSetting','TaxConfiguration','TaxId','','','Download','4',4,'4',4,0,'SELECT TaxCode AS [Tax Code],TaxName AS [Tax Name] FROM TaxConfiguration WHERE TaxId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (209,1,'Tax Setting','Tax Setting','Etl_Prk_TaxSetting','Etl_Prk_TaxSetting','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (211,1,'Product','Product','Cn2Cs_Prk_Product','Product','PrdId','','','Download','332',332,'332',332,0,'SELECT PrdCCode AS [Product Code],PrdName AS [Product Name] FROM Product WHERE PrdId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (215,1,'Scheme','Scheme Master','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','139',139,'139',139,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (215,3,'Scheme','Scheme Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','139',139,'139',139,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (215,4,'Scheme','Scheme Slabs','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','139',139,'139',139,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (210,1,'Product Hierarchy Change','Product Hierarchy Change','Cn2Cs_Prk_BLProductHiereachyChange','Cn2Cs_Prk_BLProductHiereachyChange','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT BusinessCode AS [Business Code],CategoryCode AS [Category Code] FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag=''Y''')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (212,1,'Product Batch','Product Batch','Cn2Cs_Prk_ProductBatch','ProductBatch','PrdBatId','','','Download','6178',5434,'6182',5438,4,'SELECT PrdCCode AS [Product Code],PrdBatCode AS [Batch Code] FROM ProductBatch PB,Product P   WHERE P.PrdId=PB.PrdId AND PrdBatId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (213,1,'Tax Group Mapping','Tax Group Mapping','Etl_Prk_TaxMapping','Etl_Prk_TaxMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT PrdCode AS [Product Code],TaxGroupCode AS [Tax Group Code] FROM Etl_Prk_TaxMapping WHERE DownLoadFlag=''Y''')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (214,1,'Special Rate','Special Rate','Cn2Cs_Prk_SpecialRate','Cn2Cs_Prk_SpecialRate','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT CtgCode AS [Hierarchy],PrdCCode AS [Product Company Code],SpecialSellingRate AS [Special Selling Rate] FROM Cn2Cs_Prk_SpecialRate WHERE DownLoadFlag=''Y''')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (215,2,'Scheme','Scheme Attributes','Etl_Prk_Scheme_OnAttributes','SchemeMaster','SchId','','','Download','139',139,'139',139,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (215,5,'Scheme','Scheme Rule Setting','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','139',139,'139',139,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (215,6,'Scheme','Scheme Free Products','Etl_Prk_Scheme_Free_Multi_Products','SchemeMaster','SchId','','','Download','139',139,'139',139,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (215,8,'Scheme','Scheme On Another Product','Etl_Prk_Scheme_OnAnotherPrd','SchemeMaster','SchId','','','Download','139',139,'139',139,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (216,1,'Purchase Receipt','Purchase Receipt','Cn2Cs_Prk_BLPurchaseReceipt','ETLTempPurchaseReceipt','CmpInvNo','','DownLoadStatus=0','Download','0',0,'528097726',1,1,'SELECT CmpInvNo AS [Invoice No],InvDate AS [Invoice Date] FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (217,1,'Purchase Return Approval','Purchase Return Approval','Cn2Cs_Prk_PurchaseReturnApproval','Cn2Cs_Prk_PurchaseReturnApproval','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (218,1,'Scheme Master Control','Scheme Master Control','Cn2Cs_Prk_NVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],ChangeType AS [Change Type],Description FROM Cn2Cs_Prk_NVSchemeMasterControl WHERE DownLoadFlag=''Y''')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (219,1,'Claim Norm Mapping','Claim Norm Mapping','Cn2Cs_Prk_ClaimNorm','Cn2Cs_Prk_ClaimNorm','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (220,1,'Reason Master','Reason Master','Cn2Cs_Prk_ReasonMaster','ReasonMaster','ReasonId','','','Download','12',12,'12',12,0,'SELECT ReasonCode AS [Reason Code],Description FROM ReasonMaster WHERE ReasonId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (222,1,'Bulletin Board','BulletingBoard','Cn2Cs_Prk_BulletingBoard','Cn2Cs_Prk_BulletingBoard','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (223,1,'ReUpload','ReUpload','Cn2Cs_Prk_ReUpload','Cn2Cs_Prk_ReUpload','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (224,1,'Configuration','Configuration','Cn2Cs_Prk_Configuration','Cn2Cs_Prk_Configuration','DownLoadFlag','','','Download','0',0,'0',0,0,'')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (225,1,'UDC Master','UDCMaster','Cn2Cs_Prk_UDCMaster','UDCMaster','UDCMAsterId','','','Download','15',13,'15',13,0,'SELECT UH.MasterName AS [Master Name],UM.ColumnName AS [Column Name] FROM UDCMaster UM,UDCHd UH WHERE UM.MasterId=UM.MasterId AND UM.UdcMasterId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (215,7,'Scheme','Scheme Combi Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','139',139,'139',139,0,'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

 INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) VALUES (227,1,'Purchase Order','Purchase Order','Cn2Cs_Prk_BLPurchaseOrder','Cn2Cs_Prk_BLPurchaseOrder','DownLoadFlag','','PORefNo','Download','0',0,'Y',2,2,'')	
GO
-- Prepared by Boopthy on 25-08-2011 for bill Print Issue
-- Removed Userid mapping for supreports on 30-08-2011
-- UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'RptSELECTedBills') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
DROP TABLE RptSELECTedBills
CREATE TABLE RptSELECTedBills
(
	SalId	BIGINT,
	UsrId	INT
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptBTBillTemplate')
DROP PROCEDURE Proc_RptBTBillTemplate
GO
CREATE PROCEDURE [dbo].[Proc_RptBTBillTemplate]
(
	@Pi_UsrId Int = 1,
	@Pi_Type INT,
	@Pi_InvDC INT
)
AS
/*********************************
* PROCEDURE		: Proc_RptBTBillTemplate
* PURPOSE		: To Get the Bill Details 
* CREATED		: Nandakumar R.G
* CREATED DATE	: 29/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FROMBillId AS  VARCHAR(25)
	DECLARE @ToBillId   AS  VARCHAR(25)
	DECLARE @Cnt AS INT
	DECLARE @TempSalId TABLE
	(
		SalId	INT,
		UsrId	INT
	)
	DECLARE  @RptBillTemplate Table
	(
		[Base Qty] numeric(38,0),
		[Batch Code] nvarchar(50),
		[Batch Expiry Date] datetime,
		[Batch Manufacturing Date] datetime,
		[Batch MRP] numeric(38,2),
		[Batch Selling Rate] numeric(38,2),
		[Bill Date] datetime,
		[Bill Doc Ref. Number] nvarchar(50),
		[Bill Mode] tinyint,
		[Bill Type] tinyint,
		[CD Disc Base Qty Amount] numeric(38,2),
		[CD Disc Effect Amount] numeric(38,2),
		[CD Disc Header Amount] numeric(38,2),
		[CD Disc LineUnit Amount] numeric(38,2),
		[CD Disc Qty Percentage] numeric(38,2),
		[CD Disc Unit Percentage] numeric(38,2),
		[CD Disc UOM Amount] numeric(38,2),
		[CD Disc UOM Percentage] numeric(38,2),
		[Company Address1] nvarchar(50),
		[Company Address2] nvarchar(50),
		[Company Address3] nvarchar(50),
		[Company Code] nvarchar(20),
		[Company Contact Person] nvarchar(100),
		[Company EmailId] nvarchar(50),
		[Company Fax Number] nvarchar(50),
		[Company Name] nvarchar(100),
		[Company Phone Number] nvarchar(50),
		[Contact Person] nvarchar(50),
		[CST Number] nvarchar(50),
		[DB Disc Base Qty Amount] numeric(38,2),
		[DB Disc Effect Amount] numeric(38,2),
		[DB Disc Header Amount] numeric(38,2),
		[DB Disc LineUnit Amount] numeric(38,2),
		[DB Disc Qty Percentage] numeric(38,2),
		[DB Disc Unit Percentage] numeric(38,2),
		[DB Disc UOM Amount] numeric(38,2),
		[DB Disc UOM Percentage] numeric(38,2),
		[DC DATE] DATETIME,
		[DC NUMBER] nvarchar(100),
		[Delivery Boy] nvarchar(50),
		[Delivery Date] datetime,
		[Deposit Amount] numeric(38,2),
		[Distributor Address1] nvarchar(50),
		[Distributor Address2] nvarchar(50),
		[Distributor Address3] nvarchar(50),
		[Distributor Code] nvarchar(20),
		[Distributor Name] nvarchar(50),
		[Drug Batch Description] nvarchar(50),
		[Drug Licence Number 1] nvarchar(50),
		[Drug Licence Number 2] nvarchar(50),
		[Drug1 Expiry Date] DateTime,
		[Drug2 Expiry Date] DateTime,
		[EAN Code] varchar(50),
		[EmailID] nvarchar(50),
		[Geo Level] nvarchar(50),
		[Interim Sales] tinyint,
		[Licence Number] nvarchar(50),
		[Line Base Qty Amount] numeric(38,2),
		[Line Base Qty Percentage] numeric(38,2),
		[Line Effect Amount] numeric(38,2),
		[Line Unit Amount] numeric(38,2),
		[Line Unit Percentage] numeric(38,2),
		[Line UOM1 Amount] numeric(38,2),
		[Line UOM1 Percentage] numeric(38,2),
		[LST Number] nvarchar(50),
		[Manual Free Qty] int,
		[Order Date] datetime,
		[Order Number] nvarchar(50),
		[Pesticide Expiry Date] DateTime,
		[Pesticide Licence Number] nvarchar(50),
		[PhoneNo] nvarchar(50),
		[PinCode] int,
		[Product Code] nvarchar(50),
		[Product Name] nvarchar(200),
		[Product Short Name] nvarchar(100),
		[Product SL No] Int,
		[Product Type] int,
		[Remarks] nvarchar(200),
		[Retailer Address1] nvarchar(100),
		[Retailer Address2] nvarchar(100),
		[Retailer Address3] nvarchar(100),
		[Retailer Code] nvarchar(50),
		[Retailer ContactPerson] nvarchar(100),
		[Retailer Coverage Mode] tinyint,
		[Retailer Credit Bills] int,
		[Retailer Credit Days] int,
		[Retailer Credit Limit] numeric(38,2),
		[Retailer CSTNo] nvarchar(50),
		[Retailer Deposit Amount] numeric(38,2),
		[Retailer Drug ExpiryDate] datetime,
		[Retailer Drug License No] nvarchar(50),
		[Retailer EmailId] nvarchar(100),
		[Retailer GeoLevel] nvarchar(50),
		[Retailer License ExpiryDate] datetime,
		[Retailer License No] nvarchar(50),
		[Retailer Name] nvarchar(150),
		[Retailer OffPhone1] nvarchar(50),
		[Retailer OffPhone2] nvarchar(50),
		[Retailer OnAccount] numeric(38,2),
		[Retailer Pestcide ExpiryDate] datetime,
		[Retailer Pestcide LicNo] nvarchar(50),
		[Retailer PhoneNo] nvarchar(50),
		[Retailer Pin Code] nvarchar(50),
		[Retailer ResPhone1] nvarchar(50),
		[Retailer ResPhone2] nvarchar(50),
		[Retailer Ship Address1] nvarchar(100),
		[Retailer Ship Address2] nvarchar(100),
		[Retailer Ship Address3] nvarchar(100),
		[Retailer ShipId] int,
		[Retailer TaxType] tinyint,
		[Retailer TINNo] nvarchar(50),
		[Retailer Village] nvarchar(100),
		[Route Code] nvarchar(50),
		[Route Name] nvarchar(50),
		[Sales Invoice Number] nvarchar(50),
		[SalesInvoice ActNetRateAmount] numeric(38,2),
		[SalesInvoice CDPer] numeric(9,6),
		[SalesInvoice CRAdjAmount] numeric(38,2),
		[SalesInvoice DBAdjAmount] numeric(38,2),
		[SalesInvoice GrossAmount] numeric(38,2),
		[SalesInvoice Line Gross Amount] numeric(38,2),
		[SalesInvoice Line Net Amount] numeric(38,2),
		[SalesInvoice MarketRetAmount] numeric(38,2),
		[SalesInvoice NetAmount] numeric(38,2),
		[SalesInvoice NetRateDiffAmount] numeric(38,2),
		[SalesInvoice OnAccountAmount] numeric(38,2),
		[SalesInvoice OtherCharges] numeric(38,2),
		[SalesInvoice RateDiffAmount] numeric(38,2),
		[SalesInvoice ReplacementDiffAmount] numeric(38,2),
		[SalesInvoice RoundOffAmt] numeric(38,2),
		[SalesInvoice TotalAddition] numeric(38,2),
		[SalesInvoice TotalDeduction] numeric(38,2),
		[SalesInvoice WindowDisplayAmount] numeric(38,2),
		[SalesMan Code] nvarchar(50),
		[SalesMan Name] nvarchar(50),
		[SalId] int,
		[Sch Disc Base Qty Amount] numeric(38,2),
		[Sch Disc Effect Amount] numeric(38,2),
		[Sch Disc Header Amount] numeric(38,2),
		[Sch Disc LineUnit Amount] numeric(38,2),
		[Sch Disc Qty Percentage] numeric(38,2),
		[Sch Disc Unit Percentage] numeric(38,2),
		[Sch Disc UOM Amount] numeric(38,2),
		[Sch Disc UOM Percentage] numeric(38,2),
		[Scheme Points] numeric(38,2),
		[Spl. Disc Base Qty Amount] numeric(38,2),
		[Spl. Disc Effect Amount] numeric(38,2),
		[Spl. Disc Header Amount] numeric(38,2),
		[Spl. Disc LineUnit Amount] numeric(38,2),
		[Spl. Disc Qty Percentage] numeric(38,2),
		[Spl. Disc Unit Percentage] numeric(38,2),
		[Spl. Disc UOM Amount] numeric(38,2),
		[Spl. Disc UOM Percentage] numeric(38,2),
		[Tax 1] numeric(38,2),
		[Tax 2] numeric(38,2),
		[Tax 3] numeric(38,2),
		[Tax 4] numeric(38,2),
		[Tax Amount1] numeric(38,2),
		[Tax Amount2] numeric(38,2),
		[Tax Amount3] numeric(38,2),
		[Tax Amount4] numeric(38,2),
		[Tax Amt Base Qty Amount] numeric(38,2),
		[Tax Amt Effect Amount] numeric(38,2),
		[Tax Amt Header Amount] numeric(38,2),
		[Tax Amt LineUnit Amount] numeric(38,2),
		[Tax Amt Qty Percentage] numeric(38,2),
		[Tax Amt Unit Percentage] numeric(38,2),
		[Tax Amt UOM Amount] numeric(38,2),
		[Tax Amt UOM Percentage] numeric(38,2),
		[Tax Type] tinyint,
		[TIN Number] nvarchar(50),
		[Uom 1 Desc] nvarchar(50),
		[Uom 1 Qty] int,
		[Uom 2 Desc] nvarchar(50),
		[Uom 2 Qty] int,
		[Vehicle Name] nvarchar(50),
		UsrId int,
		Visibility tinyint
	)
	IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplate]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
	DROP TABLE [RptBillTemplate]
	TRUNCATE TABLE RptSELECTedBills
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @TempSalId
/* Added Distinct Shyam-Boopathy 24082011 16:*/
		SELECT Distinct SelValue,UsrId FROM ReportFilterDt WHERE RptId = 16 AND SelId = 34 AND UsrId=@Pi_UsrId

		INSERT INTO RptSELECTedBills
		SELECT SalId,UsrId FROM @TempSalId
	END
	ELSE
	BEGIN
		IF @Pi_InvDC=1
		BEGIN
			DECLARE @FROMId INT
			DECLARE @ToId INT
			DECLARE @FROMSeq INT
			DECLARE @ToSeq INT
			SELECT @FROMId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=14 AND UsrId=@Pi_UsrId
			SELECT @ToId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=15 AND UsrId=@Pi_UsrId
			SELECT @FROMSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@FROMId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@ToId
			
			INSERT INTO RptSELECTedBills
/* Added Distinct Shyam-Boopathy 24082011 16:*/

			SELECT Distinct SalId,@Pi_UsrId FROM SalInvoiceDeliveryChallan WHERE SeqNo BETWEEN @FROMSeq AND @ToSeq
		END
		ELSE
		BEGIN
			SELECT @FROMBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 14 AND UsrId=@Pi_UsrId
			SELECT @ToBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 15 AND UsrId=@Pi_UsrId
			INSERT INTO RptSELECTedBills
/* Added Distinct Shyam-Boopathy 24082011 16:*/

			SELECT Distinct SalId,@Pi_UsrId FROM SalesINvoice(NOLOCK) WHERE SalId BETWEEN @FROMBillId AND @ToBillId
		END
	END
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,
		[CD Disc_Amount_Dt],[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],
		[CD Disc_UomPerc_Dt],Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,
		[DB Disc_Amount_Dt],[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],
		[DB Disc_UomPerc_Dt],DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,
		DistributorName,DrugBatchDesc,DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,
		LineBaseQtyAmount,LineBaseQtyPerc,LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,
		OrderKeyNo,PestExpiryDate,PestLicNo,PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,
		RtrContactPerson,RtrCovMode,RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,
		GeoLevelName,RtrLicExpiryDate,RtrLicNo,RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,
		RtrResPhone1,RtrResPhone2,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,
		SalActNetRateAmount,SalCDPer,CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,
		SalNetRateDiffAmount,OnAccountAmount,OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,
		WindowDisplayamount,SMCode,SMName,SalId,[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],
		[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],
		[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],
		Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],
		[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,
		Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,
						SalRateDiffAmount,SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,
						Replacementdiffamount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
						SalRoundOffAmt,V.VehicleId,V.VehicleCode,D.DlvBoyId , D.DlvBoyName FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,
						R.RtrCrLimit,R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,
						GL.GeoLevelName,RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2 , R.RtrOffPhone1, R.RtrOffPhone2, R.RtrOnAcc FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK) WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,BPT.Tax3Perc,
							BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId AND BPT.UsrId=@Pi_UsrId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId AND LW.SchId = PO.SchId AND
								--LW.SlabId = PO.SlabId
								LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId 
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId) 
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
--							'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
							'0' UOM2,'0' Uom2Qty,SUM(SIP.FreeQty) BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
							GROUP BY SIP.SalId,SIP.FreePrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.FreePriceId
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
--							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SUM(SIP.GiftQty) AS BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
							GROUP BY SIP.SalId,SIP.GiftPrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.GiftPriceId
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
					AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
						) MRP
						LEFT OUTER JOIN
						(
						SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
						FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
						WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId
						AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM @TempSalId)
	END
	ELSE
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,[CD Disc_Amount_Dt],
		[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],[CD Disc_UomPerc_Dt],
		Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,[DB Disc_Amount_Dt],
		[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],[DB Disc_UomPerc_Dt],
		DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,DistributorName,DrugBatchDesc,
		DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,LineBaseQtyAmount,LineBaseQtyPerc,
		LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,OrderKeyNo,PestExpiryDate,PestLicNo,
		PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,RtrContactPerson,RtrCovMode,
		RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,GeoLevelName,RtrLicExpiryDate,RtrLicNo,
		RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,RtrResPhone1,RtrResPhone2,
		RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,SalActNetRateAmount,SalCDPer,
		CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,SalNetRateDiffAmount,OnAccountAmount,
		OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,SalId,
		[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],
		[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],
		[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,
		Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],
		[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,SalRateDiffAmount,
						SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,Replacementdiffamount,
						TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,SalRoundOffAmt,V.VehicleId,V.VehicleCode,
						D.DlvBoyId,D.DlvBoyName
						FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,R.RtrCrLimit,
						R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,GL.GeoLevelName,
						RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrOnAcc
						FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK)
						WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,
						C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,
							P.PrdName,P.PrdShrtName,P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,
							BPT.Tax3Perc,BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId AND BPT.UsrId=@Pi_UsrId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId) 
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1 AND
					SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
						) MRP
						LEFT OUTER JOIN
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
							FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
						) SelRtr ON MRP.PrdId = SelRtr.PrdId
						AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId)
	END
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[RptBTBillTemplate]')
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [RptBTBillTemplate]
	SELECT DISTINCT * INTO RptBTBillTemplate FROM @RptBillTemplate WHERE UsrId=@Pi_UsrId
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_BillPrintingTax')
DROP PROCEDURE Proc_BillPrintingTax
GO
--EXEC Proc_BillPrintingTax 2,1,1000
CREATE PROCEDURE [dbo].[Proc_BillPrintingTax] 
(
	@Pi_UsrId		INT,
	@Pi_FromBillNo	INT,
	@Pi_ToBillNo	INT
)
AS 
SET NOCOUNT ON
/***************************************************************************************************
* PROCEDURE		: Proc_BillPrintingTax
* PURPOSE		: General Procedure get the tax details 
* NOTES			:
* CREATED		: Nandakumar R.G
* CREATED ON	: 12/11/2010
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
*UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
****************************************************************************************************/
BEGIN
	DECLARE @TaxId	AS INT	
	DECLARE @iIdx	AS INT
	DECLARE @sSql	AS NVARCHAR(4000)

	SELECT @Pi_FromBillNo=MIN(SalId) FROM RptSelectedBills WHERE UsrId = @Pi_UsrId
	SELECT @Pi_ToBillNo=MAX(SalId) FROM RptSelectedBills WHERE UsrId = @Pi_UsrId

	DELETE FROM BillPrintTaxTemp WHERE UsrId=@Pi_UsrId	  

	INSERT INTO BillPrintTaxTemp(SalId,PrdId,PrdCode,PrdBatId,BatchCode,Tax1Id,Tax2Id,Tax3Id,Tax4Id,Tax5Id,
	Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax5Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,Tax5Amount,UsrId)	
	SELECT	SIP.SalId,SIP.PrdId,P.PrdCCode,SIP.PrdBatId,PB.PrdBatCode,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,@Pi_UsrId
	FROM SalesInvoiceProduct SIP
	INNER JOIN Product P ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdBatId=SIP.PrdBatId AND P.PrdId=PB.PrdId
	WHERE SIP.SalId BETWEEN @Pi_FromBillNo AND @Pi_ToBillNo 	 
	ORDER BY SIP.SalId,SIP.PrdId,SIP.PrdBatId
	
	SELECT	SIP.SalId,SIP.PrdId,P.PrdCCode,SIP.PrdBatId,PB.PrdBatCode,ISNULL(SIPT.TaxId,0) AS TaxId,
	ISNULL(SIPT.TaxPerc,0) AS TaxPerc,ISNULL(SIPT.TaxAmount,0) AS TaxAmount,@Pi_UsrId As UsrId
	INTO #SalesTaxDetails
	FROM SalesInvoiceProduct SIP
	INNER JOIN Product P ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdBatId=SIP.PrdBatId AND P.PrdId=PB.PrdId
	LEFT OUTER JOIN SalesInvoiceProductTax SIPT ON SIP.SlNo=SIPT.PrdSlNo AND SIP.SalId=SIPT.SalId 	
	WHERE SIP.SalId BETWEEN @Pi_FromBillNo AND @Pi_ToBillNo
	AND ISNULL(SIPT.TaxPerc,0)+ISNULL(SIPT.TaxAmount,0)>0
	ORDER BY SIP.SalId,SIP.PrdId,SIP.PrdBatId,SIPT.TaxId
	
	SET @iIdx=1
	DECLARE Cur_Tax CURSOR FOR
	SELECT DISTINCT TaxId FROM #SalesTaxDetails  WHERE UsrId = @Pi_UsrId ORDER BY TaxId
	OPEN Cur_Tax
	FETCH NEXT FROM Cur_Tax INTO @TaxId
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT @iIdx>5
		BEGIN
			SET @sSql='UPDATE BPT SET BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id=ST.TaxId,
					   BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc=ST.TaxPerc,
					   BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount=ST.TaxAmount
					   FROM BillPrintTaxTemp BPT,
					   (
				    		SELECT SalId,PrdId,PrdCCode,PrdBatId,PrdBatCode,TaxId,TaxPerc,TaxAmount
							FROM #SalesTaxDetails WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND TaxId='+CAST(@TaxId AS NVARCHAR(10))+'			
					   )ST
					   WHERE BPT.UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND BPT.SalId=ST.SalId AND BPT.PrdId=ST.PrdId AND BPT.PrdBatId=ST.PrdBatId' 
			EXEC (@sSql)
			IF @iIdx>1
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount=0
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id'
				EXEC (@sSql)
			END
			IF @iIdx>2
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount=0
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id'
				EXEC (@sSql)
			END
			IF @iIdx>3
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount=0
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id'
				EXEC (@sSql)
			END
			IF @iIdx>4
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount=0
						   WHERE UsrId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id'
				EXEC (@sSql)
			END
		END
		SET @iIdx=@iIdx+1
		FETCH NEXT FROM Cur_Tax INTO @TaxId
	END
	CLOSE Cur_Tax
	DEALLOCATE Cur_Tax
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptReportToBill')
DROP PROCEDURE Proc_RptReportToBill
GO
-- EXEC Proc_RptReportToBill 2,16,0,1
CREATE PROCEDURE [dbo].[Proc_RptReportToBill]
(
	@Pi_UsrId INT,
	@Pi_RptId INT,
	@Pi_Sel INT,
	@Pi_InvDC INT
)
AS
/***************************************************************************************************
* PROCEDURE: Proc_RptReportToBill
* PURPOSE: General Procedure
* NOTES:
* CREATED: Nanda	 
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
* 01.10.2009		Panneer	   Checked in Invoice Type Condition
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	--Filter Variable
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SelBillNo  AS  BIGINT
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	--Assgin Value for the Filter Variable
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @FromBillNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SelBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId))
	SET @FromDate =(SELECT  TOP 1 dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	IF @Pi_Sel = 1
	BEGIN
		 SELECT @FromBillNo = Min(SalId) FROM SalesInvoice
		 SELECT @ToBillNo = Max(SalId) FROM SalesInvoice
	END

	DELETE from RptBillToPrint where [UsrId] = @Pi_UsrId

	IF @Pi_InvDC=2
	BEGIN	
		INSERT INTO  RptBillToPrint
		SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
		WHERE
		 (SalId=(CASE @SelBillNo WHEN 0 THEN SalId ELSE 0 END) OR
							SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
		AND
		 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND
		 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
		AND (SalId BETWEEN @FromBillNo AND @ToBillNo)
		AND (SalInvDate BETWEEN @FromDate AND @ToDate)
		AND InvType=0
	END
	ELSE
	BEGIN
		--->Added By Nanda on 24/09/2009
		IF @Pi_Sel = 0
		BEGIN

			DECLARE @FromId INT
			DECLARE @ToId INT
			DECLARE @StartBill AS nvarchar(100)
			DECLARE @EndBill AS nvarchar(500)
			DECLARE @FromSeq INT
			DECLARE @ToSeq INT
			SELECT @FromId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=14 AND UsrId = @Pi_UsrId
			SELECT @ToId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=15 AND UsrId = @Pi_UsrId
			
			PRINT @FromId
			PRINT @ToId
			
			SELECT  @StartBill= SalInvno FROM SalesInvoice WHERE SalId=@FromId
			SELECT  @EndBill=	SalInvno FROM SalesInvoice WHERE SalId=@ToId		
			SELECT @FromSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@FromId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@ToId	
		
			INSERT INTO  RptBillToPrint		
			SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
			WHERE
			 (SalId IN (SELECT SalId FROM SalesInvoice WHERE SalId BETWEEN @FromId AND @ToId))	
			AND
			 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND
			 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
								RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
								DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
			AND (SalInvDate BETWEEN @FromDate AND @ToDate)
			AND InvType=1			
		END
		ELSE--->Till Here
		BEGIN
			INSERT INTO  RptBillToPrint		
			SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
			WHERE
			 (SalId=(CASE @SelBillNo WHEN 0 THEN SalId ELSE 0 END) OR
								SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
			AND
			 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND
			 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
								RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
								DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
			AND (SalId BETWEEN @FromBillNo AND @ToBillNo)
			AND (SalInvDate BETWEEN @FromDate AND @ToDate)
			AND InvType=1
		END
	END
END
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
	SELECT @DeliveredBill=Status FROM  Configuration WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'
	IF @DeliveredBill=1
	BEGIN		
		DELETE FROM RptBillToPrint WHERE [Bill Number] IN(
		SELECT SalInvNo FROM SalesInvoice WHERE DlvSts NOT IN(4,5))  AND UsrId=@Pi_UsrId
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
			'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V,RptBillToPrint T Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND T.UsrId='+@Pi_UsrId)
		END
		ELSE
		BEGIN
			--SELECT 'Nanda002'	
			Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +
			'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V,RptBillToPrint T Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND  T.UsrId='+ @Pi_UsrId)
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +
				'(' + @TblFields + ')' +
			' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + ' Where UsrId = ' +  CAST(@Pi_UsrId AS VARCHAR(10))
		
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
	---------------------------------TAX (SubReport)
	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
	End
	------------------------------ Other
	Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
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
		AND B.UsrId = @Pi_UsrId
	End
	---------------------------------------Replacement
	Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
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
		AND B.UsrId = @Pi_UsrId
	End
	----------------------------------Credit Debit Adjus
	Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,UsrId)
		Select A.SalId,S.SalInvNo,CrNoteNumber,A.CrAdjAmount,@Pi_UsrId
		from SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
		Union All
		Select A.SalId,S.SalInvNo,DbNoteNumber,A.DbAdjAmount,@Pi_UsrId
		from SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number]AND B.UsrId = @Pi_UsrId
	End
	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
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
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId
		From ReturnPrdHdForScheme D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B,ReturnHeader H,ReturnProduct T
		WHERE returntype = 1 AND
		D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = T.SalId
		and H.ReturnID = T.ReturnID
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId
	End
	------------------------------ SampleIssue
	Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
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
	Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,18,LEN(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId
	If @Sub_Val = 1
	Begin
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeLineWise SISL,SchemeMaster SM,RptBillToPrint RBT
		WHERE SISL.SchId=SM.SchId AND SI.SalId=SISL.SalId AND RBT.[Bill Number]=SI.SalInvNo AND RBT.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc
		HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeDtFreePrd SISFP,SchemeMaster SM,RptBillToPrint RBT,Product P,ProductBatch PB,
		ProductBatchDetails PBD,BatchCreation BC
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.FreePrdId=P.PrdId AND SISFP.FreePrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND RBT.UsrId = @Pi_UsrId

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeDtFreePrd SISFP,SchemeMaster SM,RptBillToPrint RBT,Product P,ProductBatch PB,
		ProductBatchDetails PBD,BatchCreation BC
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.GiftPrdId=P.PrdId AND SISFP.GiftPrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND RBT.UsrId = @Pi_UsrId

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SIWD.AdjAmt),0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceWindowDisplay SIWD,SchemeMaster SM,RptBillToPrint RBT
		WHERE SIWD.SchId=SM.SchId AND SI.SalId=SIWD.SalId AND RBT.[Bill Number]=SI.SalInvNo AND RBT.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc

		UPDATE RPT SET SalInvSchemevalue=A.SalInvSchemevalue
		FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemevalue FROM RptBillTemplate_Scheme WHERE UsrId = @Pi_UsrId GROUP BY SalId)A
		WHERE A.SAlId=RPT.SalId AND RPT.UsrId = @Pi_UsrId
	End
	--->Till Here	
	--->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
		DROP TABLE [RptBillTemplateFinal_Group]

		SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal WHERE UsrId = @Pi_UsrId
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
			[UsrId],[Visibility],[AmtInWrd]
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
		[UsrId],[Visibility],[AmtInWrd]
		FROM RptBillTemplateFinal_Group,Product P
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
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId
	END	


--	SELECT * FROM RptBillTemplateFinal
--	SELECT * FROM SalesInvoiceProduct A INNER JOIN Product

	--->Till Here
	IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A INNER JOIN SalesInvoice B
				ON A.SalId=B.SalId INNER JOIN RptBillToPrint C ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId)
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
		INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)
		SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A INNER JOIN SalesInvoice B
		ON A.SalId=B.SalId INNER JOIN RptBillToPrint C ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId
	END
	ELSE
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
	END
	RETURN
END
GO
UPDATE Configuration SET Condition='http://124.153.94.26/JNJTest/' 
WHERE ModuleId='DATATRANSFER31'
UPDATE Configuration SET Condition='http://124.153.94.26/JandJIntegration3.0/Pos2Console.asmx' 
WHERE ModuleId='DATATRANSFER44'
UPDATE Configuration SET Condition='http://124.153.94.26/JandJIntegration3.0/Console2Pos.asmx' 
WHERE ModuleId='DATATRANSFER45'
GO

--SRF-Nanda-265-001-From Praveen

UPDATE RptExcelHeaders SET SlNo=12 WHERE FieldName='Rate' AND RptExcelHeaders.RptId=21
UPDATE RptExcelHeaders SET SlNo=13 WHERE FieldName='Amount' AND RptExcelHeaders.RptId=21
UPDATE RptExcelHeaders SET SlNo=14 WHERE FieldName='Amount For Claim' AND RptExcelHeaders.RptId=21
UPDATE RptExcelHeaders SET SlNo=15,DisplayFlag=1 WHERE FieldName='ReasonId' AND RptExcelHeaders.RptId=21
UPDATE RptExcelHeaders SET SlNo=16 WHERE FieldName='Reason' AND RptExcelHeaders.RptId=21
UPDATE RptExcelHeaders SET SlNo=17,DisplayFlag=0 WHERE FieldName='Uom1' AND RptExcelHeaders.RptId=21
UPDATE RptExcelHeaders SET SlNo=18,DisplayFlag=0 WHERE FieldName='Uom2' AND RptExcelHeaders.RptId=21
UPDATE RptExcelHeaders SET SlNo=19,DisplayFlag=0 WHERE FieldName='Uom3' AND RptExcelHeaders.RptId=21
UPDATE RptExcelHeaders SET SlNo=20,DisplayFlag=0 WHERE FieldName='Uom4' AND RptExcelHeaders.RptId=21
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptSalavageAll_Excel')
DROP TABLE RptSalavageAll_Excel
GO
CREATE TABLE [dbo].[RptSalavageAll_Excel](
	[Reference Number] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Salvage Date] [datetime] NULL,
	[LocationId] [int] NULL,
	[Location Name] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocRefNo] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StkTypeId] [int] NULL,
	[StkType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,	
	[Product Code] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Batch Code] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qty] [numeric](38, 0) NULL,
	[Rate] [numeric](38, 6) NULL,
	[Amount] [numeric](38, 6) NULL,
	[Amount For Claim] [numeric](38, 6) NULL,
	[ReasonId] [int] NULL,
	[Reason] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

--SRF-Nanda-265-002-From Praveen
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptOUTPUTVATSummary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptOUTPUTVATSummary]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

  
--EXEC Proc_RptOUTPUTVATSummary 29,2,0,'CoreStockyTempReport',0,0,1,0  
CREATE PROCEDURE [dbo].[Proc_RptOUTPUTVATSummary]  
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
DECLARE @SMId   AS INT  
DECLARE @RMId   AS INT  
DECLARE @RtrId   AS INT  
DECLARE @TransNo AS NVARCHAR(100)  
DECLARE @EXLFlag AS  INT  
DECLARE @DispNet    AS  INT  
DECLARE @DispBaseTransNo    AS  INT  
--select * from reportfilterdt  
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))  
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))  
SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))  
SET @TransNo =(SELECT TOP 1 SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId))  
SET @DispNet = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,264,@Pi_UsrId))  
SET @DispBaseTransNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,273,@Pi_UsrId))  
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
Create TABLE #RptOUTPUTVATSummary  
(  
  InvId    BIGINT,  
  RefNo     NVARCHAR(100),   
  BillBookNo    NVARCHAR(100),   
  InvDate   DATETIME,  
  BaseTransNo  NVARCHAR(100),   
  RtrId    INT,  
  RtrName   NVARCHAR(100),  
  RtrTINNo   NVARCHAR(100),  
  IOTaxType   NVARCHAR(100),  
  TaxPerc   NVARCHAR(100),  
  TaxableAmount   NUMERIC(38,6),    
  TaxFlag   INT,  
  TaxPercent   NUMERIC(38,6)  
 )  
SET @TblName = 'RptOUTPUTVATSummary'  
SET @TblStruct = 'InvId   BIGINT,  
  RefNo     NVARCHAR(100),    
  BillBookNo    NVARCHAR(100),  
  InvDate   DATETIME,   
  BaseTransNo  NVARCHAR(100),   
  RtrId    INT,  
  RtrName   NVARCHAR(100),  
  RtrTINNo   NVARCHAR(100),  
  IOTaxType   NVARCHAR(100),  
  TaxPerc   NVARCHAR(100),  
  TaxableAmount   NUMERIC(38,6),    
  TaxFlag   INT,  
  TaxPercent   NUMERIC(38,6)'  
     
 SET @TblFields = 'InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent'  
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
 EXEC Proc_IOTaxSummary  @Pi_UsrId  
 INSERT INTO #RptOUTPUTVATSummary (InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent)  
  Select InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,sum(TaxableAmount),  
--  case IOTaxType when 'Sales' then TaxableAmount when 'SalesReturn' then -1 * TaxableAmount end as TaxableAmount ,  
  TaxFlag,TaxPerCent From TmpRptIOTaxSummary T,Retailer R  
  where T.RtrId = R.RtrId and IOTaxType in ('Sales','SalesReturn')  
  AND ( T.SmId = (CASE @SmId WHEN 0 THEN T.SmId ELSE 0 END) OR  
   T.SmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
  AND ( T.RmId = (CASE @RmId WHEN 0 THEN T.RmId ELSE 0 END) OR  
   T.RmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
  AND ( T.RtrId = (CASE @RtrId WHEN 0 THEN T.RtrId ELSE 0 END) OR  
   T.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
    
  AND  (RefNo = (CASE @TransNo WHEN '0' THEN RefNo ELSE '' END) OR  
    RefNo in (SELECT SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId)))  
  AND  
  ( INVDATE between @FromDate and @ToDate and Userid = @Pi_UsrId)  
  Group By InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,TaxFlag,TaxPerCent  
-- Bill book reference and Base transaction no ---  
IF EXISTS (SELECT * FROM Configuration WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL7' AND Status=1)  
 BEGIN   
  UPDATE RPT SET RPT.BillBookNo=isnull(SI.BillBookNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN SalesInvoice SI ON RPT.InvId=SI.SalId  
  UPDATE RptFormula SET FormulaValue='Bill Book No' WHERE RptId=29 AND Slno=25 AND Formula='Disp_BillBookNo'  
  UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=29 AND SlNo=3  
 END   
ELSE  
 BEGIN   
  UPDATE #RptOUTPUTVATSummary SET BillBookNo=''  
  UPDATE RptFormula SET FormulaValue='' WHERE RptId=29 AND Slno=25 AND Formula='Disp_BillBookNo'  
  UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE RptId=29 AND SlNo=3  
 END   
IF @DispBaseTransNo=1   
 BEGIN   
  UPDATE RPT SET RPT.BaseTransNo=isnull(SI.SalInvNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN ReturnHeader RH ON RPT.InvId=RH.ReturnID INNER JOIN SalesInvoice SI ON SI.SalId=RH.SalId AND RH.InvoiceType=1  
  UPDATE RPT SET RPT.BaseTransNo=isnull(SI.SalInvNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN SalesInvoiceMarketReturn RH ON RPT.InvId=RH.ReturnID INNER JOIN SalesInvoice SI ON SI.SalId=RH.SalId   
  UPDATE RptFormula SET FormulaValue='Base Trans Ref No.' WHERE RptId=29 AND Slno=26 AND Formula='Disp_BaseTransNo'  
  UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=29 AND SlNo=5  
 END   
ELSE  
 BEGIN   
  UPDATE #RptOUTPUTVATSummary SET BaseTransNo=''  
  UPDATE RptFormula SET FormulaValue='' WHERE RptId=29 AND Slno=26 AND Formula='Disp_BaseTransNo'  
  UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE RptId=29 AND SlNo=5  
 END   
-- End here   
--select * from rptselectionhd  
 IF LEN(@PurDBName) > 0  
 BEGIN  
  SET @SSQL = 'INSERT INTO #RptOUTPUTVATSummary ' +  
   '(' + @TblFields + ')' +  
   ' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName    
   + ' T.RtrId = R.RtrId and IOTaxType in (''Sales'',''SalesReturn'')'  
   + ' WHERE (T.SmId = (CASE ' + CAST(@SmId AS nVarchar(10)) + ' WHEN 0 THEN T.SmId ELSE 0 END) OR ' +  
   ' T.SmId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '   
   + '(T.RmId = (CASE ' + CAST(@RmId AS nVarchar(10)) + ' WHEN 0 THEN T.RmId ELSE 0 END) OR ' +  
   ' T.RmId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
   + '(T.RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN T.RtrId ELSE 0 END) OR ' +  
   ' T.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '    
   + ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') '  
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
   ' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptOUTPUTVATSummary'  
  EXEC (@SSQL)  
  PRINT 'Saved Data Into SnapShot Table'  
    END  
END  
ELSE    --To Retrieve Data From Snap Data  
BEGIN  
 EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
   @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
 PRINT @ErrNo  
 IF @ErrNo = 0  
    BEGIN  
  SET @SSQL = 'INSERT INTO #RptOUTPUTVATSummary' +  
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
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptOUTPUTVATSummary  
--UPDATE #RptOUTPUTVATSummary SET TaxFlag=0  
IF @DispNet=1  
BEGIN  
 INSERT INTO #RptOUTPUTVATSummary  
 SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,  
 'Total Taxable Amount',SUM(TaxableAmount),0,1000.000000  
 FROM #RptOUTPUTVATSummary  
 WHERE TaxFlag=0  
 GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType  
 UNION ALL  
 SELECT InvId,RefNo,A.BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType,  
 'Net Amount',SUM(SalNetAmt),0,2000.000000  
 FROM #RptOUTPUTVATSummary A INNER JOIN SalesInvoice B ON A.InvId=B.SalId AND   
 A.RefNo=B.SalInvNo WHERE TaxFlag=0 AND A.IoTaxType='Sales'  
 GROUP BY InvId,RefNo,A.BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType  
 UNION ALL  
 SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType,  
 'Net Amount',-1*SUM(RtnNetAmt),0,2000.000000  
 FROM #RptOUTPUTVATSummary A INNER JOIN ReturnHeader B ON A.InvId=B.ReturnId AND   
 A.RefNo=B.ReturnCode WHERE TaxFlag=0 AND A.IoTaxType='SalesReturn'  
 GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType  
END  
ELSE  
BEGIN  
 INSERT INTO #RptOUTPUTVATSummary  
 SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,  
 'Total Taxable Amount',SUM(TaxableAmount),0,1000.000000  
 FROM #RptOUTPUTVATSummary  
 WHERE TaxFlag=0  
 GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType  
END  
INSERT INTO #RptOUTPUTVATSummary  
SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,  
'Total Tax Amount',SUM(TaxableAmount),1,1000.000000  
FROM #RptOUTPUTVATSummary  
WHERE TaxFlag=1  
GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType  
SELECT * FROM #RptOUTPUTVATSummary  
SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId  
 IF @EXLFlag=1  
 BEGIN  
  --ORDER BY InvId,TaxFlag ASC  
  /***************************************************************************************************************************/  
  --Create Table in Dynamic Cols  
  --Cursors  
  DECLARE  @InvId BIGINT  
  --DECLARE  @RtrId INT  
  DECLARE  @RefNo NVARCHAR(100)  
  DECLARE  @PurRcptRefNo NVARCHAR(50)  
  DECLARE  @TaxPerc   NVARCHAR(100)  
  DECLARE  @TaxableAmount NUMERIC(38,6)  
  DECLARE  @IOTaxType    NVARCHAR(100)  
  DECLARE  @SlNo INT    
  DECLARE  @TaxFlag      INT  
  DECLARE  @Column VARCHAR(80)  
  DECLARE  @C_SSQL VARCHAR(4000)  
  DECLARE  @iCnt INT  
  DECLARE  @TaxPercent NUMERIC(38,6)  
  DECLARE  @Name   NVARCHAR(100)
  DECLARE @BaseTransNo NVARCHAR(100)
  DECLARE @BillBookNo NVARCHAR(100)
  --DROP TABLE RptOUTPUTVATSummary_Excel  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptOUTPUTVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE [RptOUTPUTVATSummary_Excel]  
  DELETE FROM RptExcelHeaders Where RptId=29 AND SlNo>9  
  CREATE TABLE RptOUTPUTVATSummary_Excel (InvId BIGINT,RefNo NVARCHAR(100),BillBookNo NVARCHAR(100),InvDate DATETIME,BaseTransNo NVARCHAR(100),RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)  
  SET @iCnt=10  
  DECLARE Column_Cur CURSOR FOR  
  SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptOUTPUTVATSummary ORDER BY TaxPercent ,TaxFlag  
  OPEN Column_Cur  
      FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='ALTER TABLE RptOUTPUTVATSummary_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'  
     SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))  
     SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'  
      
     EXEC (@C_SSQL)  
    SET @iCnt=@iCnt+1  
     FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag  
    END  
  CLOSE Column_Cur  
  DEALLOCATE Column_Cur  
  --Insert table values  
  DELETE FROM RptOUTPUTVATSummary_Excel  
--SELECT * FROM RptOUTPUTVATSummary_Excel
--------Added For BaseTransNo,BillBookNo,Display In Excel by PraveenRaj.B 
 INSERT INTO RptOUTPUTVATSummary_Excel(InvId,RefNo,BaseTransNo,BillBookNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId)  
  SELECT DISTINCT InvId,RefNo,BaseTransNo,BillBookNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId  
    FROM #RptOUTPUTVATSummary  
  --Select * from RptOUTPUTVATSummary_Excel  
  DECLARE Values_Cur CURSOR FOR  
----Praveenraj
  SELECT DISTINCT InvId,RefNo,BaseTransNo,BillBookNo,RtrId,TaxPerc,TaxableAmount FROM #RptOUTPUTVATSummary  
  OPEN Values_Cur  
      FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@BaseTransNo,@BillBookNo,@RtrId,@TaxPerc,@TaxableAmount  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptOUTPUTVATSummary_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL+ ' WHERE InvId='+ CAST(@InvId AS VARCHAR(1000))  
     +' AND RefNo =''' + CAST(@RefNo AS VARCHAR(1000)) +''' AND  RtrId=' + CAST(@RtrId AS VARCHAR(1000))  
     +' AND UsrId='+ CAST(@Pi_UsrId AS NVARCHAR(1000))+''  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@BaseTransNo,@BillBookNo,@RtrId,@TaxPerc,@TaxableAmount  
    END  
  CLOSE Values_Cur  
  DEALLOCATE Values_Cur  
--Till Here
  -- To Update the Null Value as 0  
  DECLARE NullCursor_Cur CURSOR FOR  
  SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptOUTPUTVATSummary_Excel]')  
  OPEN NullCursor_Cur  
      FETCH NEXT FROM NullCursor_Cur INTO @Name  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptOUTPUTVATSummary_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM NullCursor_Cur INTO @Name  
    END  
  CLOSE NullCursor_Cur  
  DEALLOCATE NullCursor_Cur  
  /***************************************************************************************************************************/  
 END  
RETURN  
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

UPDATE RptExcelHeaders SET DisplayName='BillBookNo' WHERE RptId=29 AND SlNo=3 
Go

--SRF-Nanda-265-003-From Sathis Veeramani

--*******************************Collection Report Issue Fixed In JNJ*******************------------
Delete from Rptdetails where rptid = 4 and SelcId = 243
Delete from Rptfilter where rptid = 4 and SelcId = 243
Delete from RptFormula where rptid = 4 and SelcId = 243

--SRF-Nanda-265-004-From Sathis Veeramani

----*******************JNJ Default Configuration Issue Fixed*************************----
Delete From Configuration where Moduleid = 'SAL2'
Go
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) 
VALUES ('SAL2','Salesman','Allow Automatic Route Attatchment if no routes are selected',0,'',0,2)


if not exists (select * from hotfixlog where fixid = 389)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(389,'D','2011-09-16',getdate(),1,'Core Stocky Service Pack 389')
GO
