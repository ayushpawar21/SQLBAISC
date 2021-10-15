IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE Name='Proc_YEGetOpenTrans' and Type='P')
DROP PROC Proc_YEGetOpenTrans
GO
CREATE PROCEDURE [dbo].[Proc_YEGetOpenTrans]
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
*************************************************************************************************************************************        
* DATE		AUTHOR		CR/BZ   USER STORY ID           DESCRIPTION                                 
*************************************************************************************************************************************        
15/10/2019  Lakshman   BZ		ILCRSTPAR6197			Year End skip Purchase Process
02-01-2020  Deepak Philip BZ    PARLECS/0121/008        To cancel the salesinvoiceproduct-Salesinvoice mismatch bills for month end.
*********************************/
SET NOCOUNT ON
BEGIN
	TRUNCATE TABLE YearEndOpenTrans
	TRUNCATE TABLE YearEndLog

	--PARLECS/0121/008
	IF EXISTS(SELECT * FROM Salesinvoice A(NOLOCK) WHERE Salid not in (SELECT Salid FROM Salesinvoiceproduct B (NOLOCK)))
	BEGIN
		UPDATE A SET Dlvsts=3 FROM Salesinvoice A(NOLOCK)  WHERE Salid not in (SELECT Salid FROM Salesinvoiceproduct B(NOLOCK))
	END

	---------- commented by lakshma M Dated ON 04/10/2019 PMS ID: ILCRSTPAR6197-----------
	--INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	--SELECT 1,'mCmp9','Purchase','PurchaseReceipt',ISNULL(COUNT(*),0),@Pi_UsrId
	--FROM PurchaseReceipt
	--WHERE Status=0 AND GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	--SELECT 1,'Purchase',PurRcptRefNo
	--FROM PurchaseReceipt
	--WHERE Status=0 AND GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--INSERT INTO YearEndOpenTrans(SlNo,MenuId,ScreenName,TabName,OpenTrans,UsrId)	
	--SELECT 2,'mCmp11','Purchase Return','PurchaseReturn',ISNULL(COUNT(*),0),@Pi_UsrId
	--FROM PurchaseReturn
	--WHERE Status=0 AND PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	--SELECT 2,'Purchase Return',PurRetRefNo
	--FROM PurchaseReturn
	--WHERE Status=0 AND PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	-----------------Till here ----------------------
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