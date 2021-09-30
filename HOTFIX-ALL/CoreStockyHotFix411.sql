--[Stocky HotFix Version]=411
DELETE FROM Versioncontrol WHERE Hotfixid='411'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('411','3.1.0.0','D','2013-12-19','2013-12-19','2013-12-19',CONVERT(VARCHAR(11),GETDATE()),'PARLE-Major: Product Release Dec CR')
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
DELETE FROM HotSearchEditorDt WHERE FormId=10091 AND FielDName='Bill No'
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10091,'Bill No','Bill No','SalInvNo',4500,0,'HotSch-23-2000-1',23
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
GO
IF EXISTS(SELECT * FROM TaxConfiguration WHERE TaxCode='VAT') 
BEGIN
	DECLARE @InAcCode AS BIGINT
	DECLARE @OutAcCode AS BIGINT
	DECLARE @Coaid AS INT
	DECLARE @AcName AS NVARCHAR(50)
	DECLARE @InPutTaxId AS BIGINT
	DECLARE @OutPutTaxId AS BIGINT

	SELECT @Coaid=currvalue FROM Counters WHERE TabName='COAMaster' AND FldName='CoaId'

	SELECT @OutAcCode=MAX(Cast(Accode as Numeric(36,0))) 
	FROM COAMaster WHERE AcCode like (SELECT SUBSTRING(accode,1,3)+'%' from coamaster where ACNAME ='output tax')

	SELECT @InAcCode=MAX(Cast(Accode as Numeric(36,0)))
	FROM COAMaster WHERE AcCode like (SELECT SUBSTRING(accode,1,3)+'%' from coamaster where ACNAME ='input tax')

	SELECT @InPutTaxId=InputTaxId,@OutPutTaxId=OutPutTaxId FROM TaxConfiguration WHERE TaxCode='VAT'

		IF NOT EXISTS(SELECT * FROM COAMaster WHERE AcName='VAT Input') 
		BEGIN
			SET @Coaid=@Coaid+1
			SET @InAcCode=@InAcCode+1
			SET @AcName='VAT Input'
			INSERT INTO COAMASTER
			SELECT @Coaid,@InAcCode,@AcName,4,2,0,1,1,GETDATE(),1,GETDATE()
			UPDATE TaxConfiguration SET INPUTTAXID=@Coaid WHERE INPUTTAXID=@InPutTaxId AND TaxCode='VAT'
		END
		
		IF NOT EXISTS(SELECT * FROM COAMaster WHERE AcName='VAT Output') 
		BEGIN
			SET @Coaid=@Coaid+1
			SET @OutAcCode=@OutAcCode+1
			SET @AcName='VAT Output'
			INSERT INTO COAMASTER
			SELECT @Coaid,@OutAcCode,@AcName,4,1,0,1,1,GETDATE(),1,GETDATE()
			UPDATE TaxConfiguration SET OUTPUTTAXID=@Coaid WHERE OUTPUTTAXID=@OutPutTaxId AND TaxCode='VAT'
		END
		UPDATE Counters SET Currvalue=@Coaid  WHERE TabName='COAMaster' AND FldName='CoaId'
END
GO
DELETE FROM CustomCaptions WHERE TransId = 2 AND CtrlId = 1000 AND SubCtrlId = 266
INSERT INTO CustomCaptions
SELECT 2,1000,266,'Msgbox-2-1000-266','','','Tax not Calculated Row No:',1,1,1,GETDATE(),1,GETDATE(),'','','Tax not Calculated Row No:',1,1
GO
DELETE FROM Configuration WHERE ModuleId='LGV1' AND ModuleName='LoginValidation'
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('LGV1','LoginValidation','Check Console Date While Login',0,'',0.00,1)
--Till Here Sathishkumar Veeramani
GO
DELETE FROM PurchaseSequenceDetail
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,1,'A','Default','LSP','',-1,0,0,1,0,0,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,2,'B','Default','Gross Amount','',-1,0,0,1,0,0,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,4,'C','Default','Disc','',-1,0,0,1,1,2,1,250,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,5,'E','Default','FreightCharges','',-1,0,0,1,1,1,1,311,1,1,'2012-12-31',1,'2012-12-31')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,6,'F','KG','Qty in Kg','',-1,0,0,0,0,0,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,7,'G','Default','CD Disc','',-1,0,0,0,1,2,0,250,1,1,'2009-10-07',1,'2009-10-07')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,8,'D','Default','Tax','',-1,0,0,1,0,1,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,9,'H','BED','BED','',-1,0,0,0,0,1,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,10,'I','CESS','CESS','{H}*(3/100)',-1,0,0,0,0,1,1,0,1,1,'2009-06-20',1,'2009-06-20')
GO
INSERT INTO PurchaseReceiptHdAmount
SELECT DISTINCT PurRcptId,'G',0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) FROM PurchaseReceiptHdAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'G')
GO
INSERT INTO PurchaseReceiptLineAmount (PurRcptId,PrdSlNo,RefCode,LineDefValue,LineUnitAmount,LineBaseQtyAmount,LineUnitPerc,LineBaseQtyPerc,
LineEffectAmount,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PurRcptId,PrdSlNo,'G',0,0,0,0,0,0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) 
FROM PurchaseReceiptLineAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'G')
GO
---Moorthi CR No:CRCRSTHAM0002
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='TempSalvageProduct' AND XTYPE='U')
DROP TABLE TempSalvageProduct
GO
CREATE TABLE TempSalvageProduct(
	[Prdid] [int] NULL,
	[Prdbatid] [int] NULL
) 
GO
DELETE FROM CustomCaptions WHERE TransId=21 AND CtrlId=11
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,0,'btnOperation','&New','','',1,1,1,'2009-04-28',1,'2009-04-28','&New','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,1,'btnOperation','&Edit','','',1,1,1,'2009-04-28',1,'2009-04-28','&Edit','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,2,'btnOperation','&Save','','',1,1,1,'2009-04-28',1,'2009-04-28','&Save','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,3,'btnOperation','&Delete','','',1,1,1,'2009-04-28',1,'2009-04-28','&Delete','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,4,'btnOperation','&Cancel','','',1,1,1,'2009-04-28',1,'2009-04-28','&Cancel','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,5,'btnOperation','E&xit','','',1,1,1,'2009-04-28',1,'2009-04-28','E&xit','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,6,'btnOperation','&Print','','',1,1,1,'2009-04-28',1,'2009-04-28','&Print','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,7,'btnOperation','Save && C&onfirm','','',1,1,1,'2009-04-28',1,'2009-04-28','Save && C&onfirm','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (21,11,8,'btnOperation','&Load','','',1,1,1,'2013-11-29',1,'2013-11-29','&Load','','',1,1)
GO
DELETE FROM ProfileDt WHERE MenuId='mInv7' AND BtnIndex=8
INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,'mInv7',8,'Load',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK)
GO
--Hamdard Only Akzonobel-->Status LGV1=1 & LGV2=0 Others Both '0'
DELETE FROM Configuration WHERE ModuleId='LGV2'
INSERT INTO Configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('LGV2','LoginValidation','Salvage Claim Auto Generate When JC Month Will Close',0,'',0.00,2)
GO
IF NOT EXISTS (SELECT * FROM ClaimNormDefinition WHERE CmpId In (SELECT CmpId FROM Company WHERE DefaultCompany = 1))
BEGIN
	DECLARE @ClmNormID AS INT
	DECLARE @CmpId AS INT
	
	SELECT @ClmNormID = CurrValue+1 FROM Counters WHERE TabName = 'ClaimNormDefinition'
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1
	INSERT INTO ClaimNormDefinition(ClmNormId,CmpId,ClmGrpId,Claimable,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT @ClmNormID,@CmpId,CGM.ClmGrpId,CASE ISNULL(CND.Claimable,0) WHEN 0 THEN 100 ELSE CND.Claimable END AS Claimable,
	1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)
	FROM ClaimNormDefinition CND 
	RIGHT OUTER JOIN ClaimGroupMaster CGM ON CND.ClmGrpId = CGM.ClmGrpId AND CND.CmpId = @CmpId	
	UPDATE Counters SET CurrValue=@ClmNormID WHERE TabName='ClaimNormDefinition'
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_AutoPopulateSalvageClaim' AND XTYPE='P')
DROP PROCEDURE Proc_AutoPopulateSalvageClaim
GO
--EXEC Proc_AutoPopulateSalvageClaim 1
CREATE PROCEDURE Proc_AutoPopulateSalvageClaim
(
	@pUsrID INT
)
AS
BEGIN
	DECLARE @CurrMntSDate AS DATETIME
	DECLARE @ClmFrmDate AS DATETIME
	DECLARE @ClmToDate AS DATETIME
	DECLARE @CurrDate AS DATETIME
	DECLARE @ClmGrpId AS INT
	DECLARE @ClmGrmName AS VARCHAR(100)
	DECLARE @ClmDesc AS VARCHAR(100)
	DECLARE @ClmKeyNumber AS VARCHAR(50)
	DECLARE @ClmId AS INT
	DECLARE @CmpId AS INT
	DECLARE @CurrValue as BIGINT
	
	SELECT @CurrMntSDate = JcmSdt FROM JCMast J,JCMonth JM WHERE J.JcmId = JM.JcmId AND JcmJc = MONTH(GETDATE()) AND J.JcmYr = YEAR(GETDATE())
	
	DECLARE @ClmDate as DATETIME
	SELECT @ClmDate =CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(MONTH,-1,GETDATE()),121),121)
	SELECT @ClmDate
	
	SELECT @ClmFrmDate = JcmSdt,@ClmToDate = JcmEdt,@CurrDate = CONVERT(VARCHAR(10),GETDATE(),121)		
	FROM JCMast J,JCMonth JM WHERE J.JcmId = JM.JcmId AND JcmJc = MONTH(@ClmDate) AND J.JcmYr = YEAR(@ClmDate)
	
	SELECT @ClmGrpId = ClmGrpId,@ClmGrmName = ClmGrpName FROM ClaimGroupMaster WHERE ClmGrpCode = 'CG08'
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1
	
	SET @ClmDesc = 'Salvage Claim ' + UPPER(LEFT(DATENAME(MONTH, GETDATE()),3)) + CAST(YEAR(GETDATE()) AS VARCHAR(10))
	IF EXISTS (SELECT * FROM ClaimSheetHd WHERE ClmDesc = @ClmDesc)
	BEGIN
		SET @ClmDesc = 'Salvage Claim ' + UPPER(LEFT(DATENAME(MONTH, GETDATE()),3)) + CAST(YEAR(GETDATE()) AS VARCHAR(10)) + CAST(GETDATE() AS VARCHAR(20))
	END
	
	SELECT DISTINCT Refcode INTO #Claim FROM ClaimSheethd H 
	INNER JOIN ClaimSheetDetail C ON H.ClmId=C.ClmId
	and SelectMode=1 and ClmGrpId=@ClmGrpId 
	
	
	IF EXISTS(SELECT SalvageRefNo FROM Salvage A (NOLOCK) WHERE NOT EXISTS(SELECT RefCode FROM #Claim B(NOLOCK) WHERE  A.SalvageRefNo=B.RefCode)  AND A.Status=1)
	BEGIN
--SELECT @CurrMntSDate ,@CurrDate	
		IF @CurrDate >= @CurrMntSDate
		BEGIN
		
			SELECT @ClmKeyNumber=PreFix+CAST(SUBSTRING(CAST(CurYear as Varchar(10)),3,LEN(CurYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(CurrValue)>ZPad THEN (ZPad+1)-LEN(CurrValue) ELSE (ZPad)-LEN(CurrValue)END)+CAST(CurrValue+1 as Varchar(10)) 
					   ,@CurrValue=CurrValue+1 FROM Counters WHERE TabName='ClaimSheetHd' AND FldName='ClmCode'
			SELECT @ClmId= CurrValue+1 FROM Counters WHERE TabName = 'ClaimSheetHd' AND FldName='ClmId'                   
			
			INSERT INTO ClaimSheetHd (ClmId,ClmCode,ClmDesc,ClmDate,CmpId,ClmGrpId,FromDate,ToDate,ClmType,Confirm,Upload,Availability,LastModBy,LastModDate,AuthId,AuthDate,SettlementType) 
			SELECT @ClmId,@ClmKeyNumber,@ClmDesc,@CurrDate,@CmpId,@ClmGrpId,@ClmFrmDate,@ClmToDate,2,1,'N',1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),0
			
			INSERT INTO ClaimSheetDetail (ClmId,Slno,RefCode,SelectMode,Discount,FreePrdVal,GiftPrdVal,TotalSpent,ClmPercentage,ClmAmount,
			RecommendedAmount,ReceivedAmount,Status,CrDbStatus,CrDbMode,CrDbNoteNumber,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			SELECT @ClmId,ROW_NUMBER() OVER (ORDER BY SC.SalvageRefNo),SC.SalvageRefNo,1,0.00,0.00,0.00,SC.Amount,ISNULL(CND.Claimable,0),SC.Amount,SC.Amount,0.00,1,0,0,'',
			1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'' AS Remarks
			FROM (
				SELECT S.SalvageRefNo,S.SalvageDate,P.CmpId,SUM(AmtForClaim) Amount FROM SalvageProduct SP WITH (NOLOCK),Salvage S WITH (NOLOCK),
				Product P WITH (NOLOCK) WHERE S.SalvageRefNo = SP.SalvageRefNo AND SP.PrdId = P.PrdId AND S.Status=1 
				Group By S.SalvageRefNo,S.SalvageDate,P.CmpId 
				) SC 
				LEFT OUTER JOIN ClaimNormDefinition CND WITH (NOLOCK) ON SC.CmpId = CND.CmpId AND CND.ClmGrpId = @ClmGrpId 
				WHERE SC.CmpId = ISNULL(@CmpId,SC.CmpId) AND SC.SalvageDate <= @ClmToDate AND SC.SalvageRefNo NOT IN
				(SELECT RefCode FROM #Claim )
			UPDATE Counters SET CurrValue=@ClmId WHERE TabName='ClaimSheetHd' AND FldName='ClmId'
			UPDATE Counters SET CurrValue= @CurrValue WHERE TabName='ClaimSheetHd' AND FldName='ClmCode'			
			EXEC Proc_VoucherPosting 16,1,@ClmKeyNumber,3,5,@pUsrID,@CurrDate,0			
		END
	END	
END
GO
DELETE FROM Configuration WHERE ModuleId IN ('DATATRANSFER41','DATATRANSFER42')
INSERT INTO Configuration
SELECT 'DATATRANSFER41','DataTransfer','Perform Sync Process during',1,'',2.00,41 UNION
SELECT 'DATATRANSFER42','DataTransfer','Perform Automatic Sync Process after the  grace period  of                       days',0,'',0.00,42
GO
DECLARE @SyncDate AS DATETIME
IF EXISTS (SELECT SyncDate FROM Cs2Cn_Prk_SyncDetails WITH(NOLOCK))
BEGIN
   SELECT @SyncDate = SyncDate FROM Cs2Cn_Prk_SyncDetails WITH(NOLOCK)
END
ELSE
BEGIN
   SET @SyncDate = CONVERT(NVARCHAR(10),GETDATE(),121)   
END
UPDATE DayEndProcess SET NextUpDate = @SyncDate,ProcDate = @SyncDate WHERE ProcId = 13
GO
DELETE FROM Configuration WHERE ModuleId IN ('DAYENDPROCESS7','DAYENDPROCESS8')
INSERT INTO configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('DAYENDPROCESS7','Day End Process','Enable Day and Month End Process',0,'0',0.00,7)
INSERT INTO configuration([ModuleId],[ModuleName],[Description],[Status],[Condition],[ConfigValue],[SeqNo]) 
VALUES ('DAYENDPROCESS8','Day End Process','Restrict transactions on distributor off day',0,'0',0.00,8)
GO
DELETE FROM HotSearchEditorHd WHERE FormId=530
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (530,'Purchase Receipt','Product with Distributor Code','select','SELECT PrdSeqDtId,PrdId,PrdCCode,PrdShrtName,PrdDCode,PrdName,ERPPrdCode FROM (SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,PrdShrtName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),Product A WITH (NOLOCK)    LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE B.TransactionId=vSParam AND A.PrdStatus=1   AND A.PrdType<> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam UNION   SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,PrdShrtName AS PrdShrtName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode      FROM  Product A WITH (NOLOCK)LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE PrdStatus = 1 AND A.PrdType <>3     AND A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK)   WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId)AND A.CmpId = vFParam) A ORDER BY PrdSeqDtId')
GO
DELETE FROM HotSearchEditorDt WHERE FormId=530
INSERT INTO HotSearchEditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,530,'Product with Distributor Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-23',5)
INSERT INTO HotSearchEditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,530,'Product with Distributor Code','Product Invoice Name','PrdShrtName',1000,0,'HotSch-5-2000-24',5)
INSERT INTO HotSearchEditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,530,'Product with Distributor Code','Product Code','PrdDCode',1500,0,'HotSch-5-2000-25',5)
INSERT INTO HotSearchEditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,530,'Product with Distributor Code','Product Name','PrdName',1500,0,'HotSch-5-2000-103',5)
INSERT INTO HotSearchEditordt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (5,530,'Product with Distributor Code','Product Invoice Code','ERPPrdCode',1000,0,'HotSch-5-2000-104',5)
GO
DELETE FROM customcaptions WHERE CtrlName IN ('HotSch-5-2000-23','HotSch-5-2000-24','HotSch-5-2000-25','HotSch-5-2000-104','HotSch-5-2000-103')
INSERT INTO customcaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (5,2000,23,'HotSch-5-2000-23','Sequence No','','',1,1,1,'2009-09-06',1,'2009-09-06','Sequence No','','',1,1)
INSERT INTO customcaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (5,2000,24,'HotSch-5-2000-24','Product Invoice Name','','',1,1,1,'2009-09-06',1,'2009-09-06','Product Invoice Name','','',1,1)
INSERT INTO customcaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (5,2000,25,'HotSch-5-2000-25','Product Code','','',1,1,1,'2013-09-21',1,'2013-09-21','Product Code','','',1,1)
INSERT INTO customcaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (5,2000,103,'HotSch-5-2000-103','Product Name','','',1,1,1,'2013-09-21',1,'2013-09-21','Product Name','','',1,1)
INSERT INTO customcaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (5,2000,104,'HotSch-5-2000-104','Product Invoice Code','','',1,1,1,'2013-09-21',1,'2013-09-21','Product Invoice Code','','',1,1)
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',411
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 411)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(411,'D','2013-12-19',GETDATE(),1,'Core Stocky Service Pack 411')