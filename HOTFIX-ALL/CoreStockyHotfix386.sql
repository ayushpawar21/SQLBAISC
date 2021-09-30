--[Stocky HotFix Version]=386
Delete from Versioncontrol where Hotfixid='386'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('386','2.0.0.5','D','2011-09-07','2011-09-07','2011-09-07',convert(varchar(11),getdate()),'Major: Product Release FOR PM,CK,B&L-Bug Fixing')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 386' ,'386'
GO
if exists (select * from dbo.sysobjects where id = object_id(N'Proc_RptSchemeUtilizationWithOutPrimary') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure Proc_RptSchemeUtilizationWithOutPrimary
GO
--EXEC Proc_RptSchemeUtilizationWithOutPrimary 152,2,0,'JnJCRFinal',0,0,1
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
			SELECT DISTINCT @SchIId,PrdId FROM Fn_ReturnSchemeProductBatch(@SchIId)
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
 		WHERE A.SchId = #RptSchemeUtilization.SchId AND #RptSchemeUtilization.Type=1
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
		WHERE CH.Upload='N' AND CD.SelectMode=1
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
	WHERE DM.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CD.SelectMode=1
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
		WHERE CM.Status=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CDD.SelectMode=1
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
		WHERE MM.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CD.SelectMode=1
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
		WHERE PSM.Status=1 AND CH.Upload='N' AND CD.SelectMode=1
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
		WHERE PSM.Status=1 AND CH.Upload='N' AND CD.SelectMode=1
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
		WHERE CH.Upload='N' AND CD.SelectMode=1
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

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Rate Difference Claim'

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
	SELECT 	@DistCode,CM.CmpName,'Rate Difference Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),
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
	WHERE RDC.Status=1 AND CH.Upload='N' AND CD.SelectMode=1
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
	WHERE RM.Status=1 AND CD.Status=1 AND CS.Upload='N' AND CD.SelectMode=1
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
		WHERE RC.Status=1 AND CD.Status=1 AND CM.Confirm=1 AND CM.Upload='N' AND CD.SelectMode=1
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
		WHERE SM.Status=1 AND CDD.Status=1  AND CS.Confirm=1 AND CS.Upload='N' AND CDD.SelectMode=1
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
		WHERE SIM.Status=1 AND CH.Upload='N' AND CD.SelectMode=1
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
		WHERE SM.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CD.SelectMode=1
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
		WHERE SM.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CD.SelectMode=1
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
		WHERE Status=1 AND CM.Confirm=1 AND CM.Upload='N' AND CD.SelectMode=1	
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
		WHERE TM.Status=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CDD.SelectMode=1
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
		WHERE VS.VehicleStatus=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CDD.SelectMode=1
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
		WHERE VM.Status=1 AND VD.Status=1 AND CS.Confirm=1 AND CS.Upload='N' AND CD.SelectMode=1
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
----*********BillWise Collection Summary Report(This Report Only for Loreal not in CK************------
Delete from Rptheader Where Rptid = 168
Delete from Rptdetails Where Rptid = 168
Delete from RptGroup where Rptid = 168 
Delete from Rptfilter Where Rptid = 168
Delete from Rptformula Where Rptid = 168
----------------************************END*********************************************-----------------
----************Collection Report Issue Fixed in CK*************----
Delete from RptDetails Where SelcId = 244 and RptId = 4
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (4,10,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Show Report Based On*...',NULL,1,NULL,243,1,1,'Press F4/Double Click to select Show Report Based On',0)

Delete from Rptfilter Where SelcId = 244 and Rptid = 4
Insert Into Rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values (4,243,1,'Collection Ref No.')
Insert Into Rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values (4,243,2,'Bill Ref No.')

Delete from Rptformula Where SelcId = 244 and RptId = 4
Insert Into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values (4,37,'Disp_Show','Show Report Based On',1,243)
----------------************************END*********************************************------------------
----------------****************************Stock and Sales Volume Report Issue Fixed in CK********************************-----------

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptStockandSalesVolume')
DROP PROCEDURE Proc_RptStockandSalesVolume
GO
--EXEC Proc_RptStockandSalesVolume 6,1,0,'CKProduct',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptStockandSalesVolume]  
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
	DECLARE @DisplayBatch  AS INT  
	DECLARE @PrdStatus  AS INT  
	DECLARE @BatStatus  AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @IncOffStk  AS INT  
	DECLARE @StockValue 	AS	INT
	DECLARE @SupzeroStock AS INT
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
	SET @DisplayBatch =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))  
	SET @PrdStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))  
	SET @BatStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))  
	SET @PrdBatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))  
	SET @IncOffStk =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,202,@Pi_UsrId))
	SET @StockValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))  
	SET @SupZeroStock =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))  
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
	IF @IncOffStk=1  
	BEGIN  
		Exec Proc_GetStockNSalesDetailsWithOffer @FromDate,@ToDate,@Pi_UsrId  
	END  
	ELSE  
	BEGIN  
		Exec Proc_GetStockNSalesDetails @FromDate,@ToDate,@Pi_UsrId  
	END  
	IF @DisplayBatch = 1 
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	--Create TABLE #RptPendingBillsDetails  
	CREATE TABLE #RptStockandSalesVolume  
	(  
		PrdId			INT,  
		PrdDCode			NVARCHAR(20),  
		PrdName			NVARCHAR(100),  
		PrdBatId			INT,  
		PrdBatCode		NVARCHAR(50),  
		CmpId			INT,  
		CmpName			NVARCHAR(50),  
		LcnId			INT,  
		LcnName			NVARCHAR(50),   
		OpeningStock		NUMERIC(38,0),    
		Purchase			NUMERIC (38,0),  
		Sales			NUMERIC (38,0),  
		AdjustmentIn		NUMERIC (38,0),  
		AdjustmentOut    NUMERIC (38,0),  
		PurchaseReturn   NUMERIC (38,0),  
		SalesReturn		NUMERIC (38,0),    
		ClosingStock		NUMERIC (38,0),  
		DispBatch        INT  ,
		ClosingStkValue	NUMERIC (38,6),
		PrdWeight	NUMERIC (38,6)
	)  
	SELECT * INTO #RptStockandSalesVolume1 FROM #RptStockandSalesVolume  
	SET @TblName = 'RptStockandSalesVolume'  
	SET @TblStruct = 'PrdId    INT,  
					  PrdDCode			NVARCHAR(20),  
					  PrdName			NVARCHAR(100),  
					  PrdBatId			INT,  
					  PrdBatCode		NVARCHAR(50),  
					  CmpId				INT,  
					  CmpName			NVARCHAR(50),  
					  LcnId				INT,  
					  LcnName			NVARCHAR(50),   
					  OpeningStock		NUMERIC(38,0),  
					  Purchase			NUMERIC (38,0),  
					  Sales				NUMERIC (38,0),     
					  AdjustmentIn		NUMERIC (38,0),  
					  AdjustmentOut		NUMERIC (38,0),  
					  PurchaseReturn	NUMERIC (38,0),  
					  SalesReturn		NUMERIC (38,0),     
					  ClosingStock		NUMERIC (38,0),  
					  DispBatch         INT,
					  ClosingStkValue	NUMERIC (38,6),
					  PrdWeight	NUMERIC (38,6)'  
	SET @TblFields = 'PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
   					  LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,  
					  PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue,PrdWeight'  
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
		INSERT INTO #RptStockandSalesVolume1 (	PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,
												AdjustmentOut,PurchaseReturn,SalesReturn,
												ClosingStock,DispBatch,ClosingStkValue,PrdWeight)  
		SELECT 
			PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,TempRptStockNSales.CmpId,CmpName,LcnId,LcnName,  
			Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,@DisplayBatch,
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId),0
		FROM 
			TempRptStockNSales INNER JOIN  Company  C ON C.CmpId = TempRptStockNSales.CmpId  
		WHERE 
			( TempRptStockNSales.CmpId = (CASE @CmpId WHEN 0 THEN TempRptStockNSales.CmpId ELSE 0 END) OR  
					TempRptStockNSales.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
			AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
					LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
			AND (PrdStatus = (CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END) OR  
					PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))  
			AND (BatStatus = (CASE @BatStatus WHEN 0 THEN BatStatus ELSE 2 END) OR  
					BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdCatValId WHEN 0 THEN PrdId Else 0 END) OR  
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
			AND UserId=@Pi_UsrId  
		IF @DisplayBatch = 1  
		BEGIN  
			INSERT INTO #RptStockandSalesVolume (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												 LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
												 PurchaseReturn,SalesReturn,ClosingStock,DispBatch,
												 ClosingStkValue,PrdWeight)  
			SELECT 
				PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,0,'',  			
				SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
				SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
				SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
				SUM(ClosingStock) AS ClosingStock,@DisplayBatch,SUM(ClosingStkValue),0
			FROM #RptStockandSalesVolume1   
			WHERE 
				(PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR  
						PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))      
			GROUP BY PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName  
		END  
		ELSE  
		BEGIN  
			INSERT INTO #RptStockandSalesVolume (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
												PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue,PrdWeight)  
			SELECT 
				PrdId,PrdDCode,PrdName,0,'',CmpId,CmpName,0,'',  
				SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
				SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
				SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
				SUM(ClosingStock) AS ClosingStock,@DisplayBatch,SUM(ClosingStkValue),0
			FROM #RptStockandSalesVolume1   
			WHERE  
				(PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR  
						PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))      
			GROUP BY PrdId,PrdDCode,PrdName,CmpId,CmpName  
		END		 
		--->Added By Nanda on 25/02/2011
		UPDATE Rpt SET Rpt.PrdWeight=P.PrdWgt*(CASE P.PrdUnitId WHEN 2 THEN Rpt.ClosingStock/1000000 ELSE Rpt.ClosingStock/1000 END)
		FROM Product P,#RptStockandSalesVolume Rpt WHERE P.PrdId=Rpt.PrdId AND P.PrdUnitId IN (2,3)
		--->Till Here
		IF LEN(@PurDBName) > 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume ' +  
			'(' + @TblFields + ')' +  
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +  
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( LcnId = (CASE ' + CAST(@LcnId AS nVarChar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR ' +  
			' LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE 0 END) OR ' +  
			' PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',24,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '  
			+ '( BatStatus = (CASE ' + CAST(@BatStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE 0 END) OR ' +  
			' BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',25,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptStockandSalesVolume'  
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
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume ' +  
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
	IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND  GridFlag=1 AND UsrId=@Pi_UsrId)
	BEGIN
		SELECT a.PrdId,a.PrdDCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.CmpId,a.CmpName,a.LcnId,a.LcnName,
		a.OpeningStock,a.Purchase,Sales,CASE WHEN ConverisonFactor2>0 THEN Case When 
		CAST(Sales AS INT)>nullif(ConverisonFactor2,0) Then CAST(Sales AS INT)/nullif(ConverisonFactor2,0) Else 0 End 
		ELSE 0 END As Uom1,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When 
		(CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then 
		isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case 
		When (CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*
		nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*
		nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
		(CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + 
		isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/Isnull(ConverisonFactor2,0)*
		Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*
		ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
		CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
		CASE 
			WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
				Case 
				When 
					CAST(Sales AS INT)-(((CAST(Sales AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(Sales AS INT)-(((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
				ELSE
					CASE 
						WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
					Case
						When CAST(Sum(Sales) AS INT)>Isnull(ConverisonFactor2,0) Then
							CAST(Sum(Sales) AS INT)%nullif(ConverisonFactor2,0)
						Else CAST(Sum(Sales) AS INT) End
						WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
					Case
					When CAST(Sum(Sales) AS INT)>Isnull(ConverisonFactor3,0) Then
					CAST(Sum(Sales) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(Sales) AS INT) 
				End			
			ELSE CAST(Sum(Sales) AS INT) END
		END AS Uom4,a.AdjustmentIn,a.AdjustmentOut,a.PurchaseReturn,a.SalesReturn,a.ClosingStock,a.DispBatch INTO #RptColDetails
		FROM #RptStockandSalesVolume A INNER JOIN View_ProdUOMDetails B ON a.prdid=b.prdid WHERE OpeningStock > 0 OR ClosingStock > 0  
		GROUP BY a.PrdId,a.PrdDCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.CmpId,a.CmpName,a.LcnId,a.LcnName,a.OpeningStock,a.Purchase,Sales,
		a.AdjustmentIn,a.AdjustmentOut,a.PurchaseReturn,a.SalesReturn,a.ClosingStock,a.DispBatch,
		ConversionFactor1,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4
		ORDER BY A.CmpId,A.PrdId,A.PrdBatId,A.LcnId 
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,Rptid,Usrid)
		SELECT 
			PrdDCode,PrdName,PrdBatCode,CmpName,LcnName,OpeningStock,Purchase,Sales,Uom1,Uom2,Uom3,Uom4,
			AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,ClosingStock,DispBatch,
			@Pi_RptId,@Pi_UsrId 
		FROM #RptColDetails
	END
	IF @SupZeroStock=1
	BEGIN 
		SELECT  * FROM #RptStockandSalesVolume
		WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			TRUNCATE TABLE RptStockandSalesVolume_Excel
			INSERT INTO RptStockandSalesVolume_Excel(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName,OpeningStock,OpeningStockInVolume,
			Purchase,PurchaseStockInVolume,Sales,SalesStockInVolume,AdjustmentIn,AdjustmentInStockVolume,AdjustmentOut,AdjustmentOutStockVolume,PurchaseReturn,
			PurchaseReturnStockInVolume,SalesReturn,SalesReturnStockInVolume,ClosingStock,ClosingStockInVolume,DispBatch,ClosingStkValue,PrdWeight)
			SELECT	PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,
					LcnId,LcnName,
					OpeningStock,0.00 as OpeningStockInVolume,
					Purchase,0.00 as PurchaseStockInVolume,
					Sales, 0.00 as SalesStockInVolume,
					AdjustmentIn,0.00 as AdjustmentInStockVolume,
					AdjustmentOut,0.00 as AdjustmentOutStockVolume,
					PurchaseReturn,0.00 As PurchaseReturnStockInVolume,
					SalesReturn,0.00 SalesReturnStockInVolume,
					ClosingStock,0.00 ClosingStockInVolume,
					DispBatch,ClosingStkValue,PrdWeight
			FROM #RptStockandSalesVolume
			WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
			Update RptStockandSalesVolume_Excel SET
					OpeningStockInVolume = ((OpeningStock * PrdWgt)/1000),
					PurchaseStockInVolume = ((Purchase * PrdWgt)/1000),
					SalesStockInVolume = ((Sales * PrdWgt)/1000),
					AdjustmentInStockVolume = ((AdjustmentIn * PrdWgt)/1000),
					AdjustmentOutStockVolume = ((AdjustmentOut * PrdWgt)/1000),
					SalesReturnStockInVolume = ((SalesReturn * PrdWgt)/1000),
					ClosingStockInVolume = ((ClosingStock * PrdWgt)/1000)		
			From RptStockandSalesVolume_Excel A,Product B
			WHERE A.PrdId = B.PrdId
		END
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume   
		WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
	END
	ELSE
	BEGIN
		SELECT * FROM #RptStockandSalesVolume
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			TRUNCATE TABLE RptStockandSalesVolume_Excel
			INSERT INTO RptStockandSalesVolume_Excel(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName,OpeningStock,OpeningStockInVolume,
			Purchase,PurchaseStockInVolume,Sales,SalesStockInVolume,AdjustmentIn,AdjustmentInStockVolume,AdjustmentOut,AdjustmentOutStockVolume,PurchaseReturn,
			PurchaseReturnStockInVolume,SalesReturn,SalesReturnStockInVolume,ClosingStock,ClosingStockInVolume,DispBatch,ClosingStkValue,PrdWeight)
			SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,
					LcnId,LcnName,
					OpeningStock,0.00 as OpeningStockInVolume,
					Purchase,0.00 as PurchaseStockInVolume,
					Sales, 0.00 as SalesStockInVolume,
					AdjustmentIn,0.00 as AdjustmentInStockVolume,
					AdjustmentOut,0.00 as AdjustmentOutStockVolume,
					PurchaseReturn,0.00 As PurchaseReturnStockInVolume,
					SalesReturn,0.00 SalesReturnStockInVolume,
					ClosingStock,0.00 ClosingStockInVolume,
					DispBatch,ClosingStkValue,PrdWeight 
			FROM #RptStockandSalesVolume		
			Update RptStockandSalesVolume_Excel SET
					OpeningStockInVolume = ((OpeningStock * PrdWgt)/1000),
					PurchaseStockInVolume = ((Purchase * PrdWgt)/1000),
					SalesStockInVolume = ((Sales * PrdWgt)/1000),
					AdjustmentInStockVolume = ((AdjustmentIn * PrdWgt)/1000),
					AdjustmentOutStockVolume = ((AdjustmentOut * PrdWgt)/1000),
					SalesReturnStockInVolume = ((SalesReturn * PrdWgt)/1000),
					ClosingStockInVolume = ((ClosingStock * PrdWgt)/1000)		
			From RptStockandSalesVolume_Excel A,Product B
			WHERE A.PrdId = B.PrdId
		END
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume   
	END
	RETURN  
END
GO
--Daily Reports->Bilwise Sales Report In excel report, B& C column hidden
Delete from RptExcelheaders where Rptid=1 
Insert into RptExcelheaders select 1	,1	,'Bill Number'	,'Bill Number',	1,	1
Insert into RptExcelheaders select 1	,2	,'Bill Type'	,'Bill Type'	,1	,1
Insert into RptExcelheaders select 1	,3	,'Bill Mode'	,'Bill Mode'	,1	,1
Insert into RptExcelheaders select 1	,4	,'Bill Date'	,'Bill Date'	,1	,1
Insert into RptExcelheaders select 1	,5	,'Retailer Code'	,'Retailer Code',	1	,1
Insert into RptExcelheaders select 1	,6	,'Retailer Name'	,'Retailer Name',	1	,1
Insert into RptExcelheaders select 1	,7	,'Gross Amount'	,'Gross Amount',	1	,1
Insert into RptExcelheaders select 1	,8	,'Scheme Disc'	,'Scheme Disc',	1	,1
Insert into RptExcelheaders select 1	,9	,'Sales Return'	,'Sales Return',	1	,1
Insert into RptExcelheaders select 1	,10	,'Replacement'	,'Replacement',	1	,1
Insert into RptExcelheaders select 1	,11	,'Discount'	,'Discount',	1	,1
Insert into RptExcelheaders select 1	,12	,'Tax Amount'	,'Tax Amount',	1	,1
Insert into RptExcelheaders select 1	,13	,'WindowDisplayAmount',	'Window Display Amount',	1	,1
Insert into RptExcelheaders select 1	,14	,'Credit Adjustmen't	,'Credit Adjustment',	1	,1
Insert into RptExcelheaders select 1	,15	,'Debit Adjustment'	,'Debit Adjustment',	1	,1
Insert into RptExcelheaders select 1	,16	,'Net Amount'	,'Net Amount'	,1	,1
Insert into RptExcelheaders select 1	,17	,'DlvStatus'	,'DlvStatus'	,0	,1
Go
--Sales Analysis Reports->Dead outlet Report Column A,B,C,D is hidden in excel report
Delete From RptExcelheaders where Rptid=50 
Insert Into RptExcelheaders select 50	,1	,'CmpId	','CmpId',	0	,1
Insert Into RptExcelheaders select 50	,2	,'SMId'	,'SMId'	,0	,1
Insert Into RptExcelheaders select 50	,3	,'SMName'	,'Salesman'	,1	,1
Insert Into RptExcelheaders select 50	,4	,'RMId'	,'RMId'	,0	,1
Insert Into RptExcelheaders select 50	,5	,'RMName'	,'Route'	,1	,1
Insert Into RptExcelheaders select 50	,6	,'CtgLevelId'	,'CtgLevelId'	,0	,1
Insert Into RptExcelheaders select 50	,7	,'CtgLevelName'	,'CtgLevelName'	,1	,1
Insert Into RptExcelheaders select 50	,8	,'CtgName'	,'Category'	,1	,1
Insert Into RptExcelheaders select 50	,9	,'RtrClassId'	,'RtrClassId'	,0	,1
Insert Into RptExcelheaders select 50	,10	,'ValueClassName'	,'Class'	,1	,1
Insert Into RptExcelheaders select 50	,11	,'RtrId'	,'RtrId'	,0	,1
Insert Into RptExcelheaders select 50	,12	,'RtrName'	,'Retailer',	1	,1
Insert Into RptExcelheaders select 50	,13	,'VillageId	','VillageId'	,0	,1
Insert Into RptExcelheaders select 50	,14	,'SalNetAmount'	,'Amount'	,1	,1
Insert Into RptExcelheaders select 50	,15	,'SalInvDate'	,'Last Invoice Date',	1	,1
Insert Into RptExcelheaders select 50	,16	,'SalInvNo'	,'Last Invoice No',	1	,1
Go
--Loading sheet-> Bilwise Report In excel report N,O column hidden
Delete From RptExcelheaders where Rptid=17
Insert into RptExcelheaders select  17	,1	,'Bill Number',	'Bill Number',	1	,1
Insert into RptExcelheaders select  17	,2	,'Bill Date'	,'Bill Date'	,1	,1
Insert into RptExcelheaders select  17	,3	,'Retailer Name',	'Retailer Name',	1	,1
Insert into RptExcelheaders select  17	,4	,'PrdId	','PrdId'	,1	,1
Insert into RptExcelheaders select  17	,5	,'Product Code',	'Product Code'	,1	,1
Insert into RptExcelheaders select  17	,6	,'Product Description',	'Product Name'	,1	,1
Insert into RptExcelheaders select  17	,7	,'BillCase'	,'Billed Qty in Selected UOM'	,1	,1
Insert into RptExcelheaders select  17	,8	,'BillPiece'	,'Billed Qty in Pieces'	,1	,1
Insert into RptExcelheaders select  17	,9	,'Free Qty'	,'Free Qty'	,1	,1
Insert into RptExcelheaders select  17	,10	,'Return Qty'	,'Return Qty'	,1	,1
Insert into RptExcelheaders select  17	,11	,'Replacement Qty'	,'Replacement Qty'	,1	,1
Insert into RptExcelheaders select  17	,12	,'TotalCase'	,'Total Qty in Selected UOM'	,1	,1
Insert into RptExcelheaders select  17	,13	,'TotalPiece'	,'Total Qty in Piece'	,1	,1
Insert into RptExcelheaders select  17	,14	,'Total Qty'	,'Total Qty'	,1	,1
Insert into RptExcelheaders select  17	,15	,'Billed Qty'	,'Billed Qty'	,1	,1
Insert into RptExcelheaders select  17	,16	,'NetAmount'	,'Net Amount'	,1	,1
Go
---Daily Reports->Productwise Sales Report In excel report I,J,K,L,M columns hidden
Delete from RptExcelheaders where Rptid=2 
insert into RptExcelheaders select 2,	1,	'PrdId'   ,	'PrdId',	0,	1
insert into RptExcelheaders select 2,	2,	'PrdDCode',	'Product Code',	1	,1
insert into RptExcelheaders select 2,	3,	'PrdName' ,	'Product Name',	1	,1
insert into RptExcelheaders select 2,	4,	'PrdBatId', 'PrdBatId'	,0	,1
insert into RptExcelheaders select 2,	5,	'PrdBatCode','Batch Code'	,1	,1
insert into RptExcelheaders select 2,	6,	'MrpRate'	,'MRP'	,1	,1
insert into RptExcelheaders select 2,	7,	'SellingRate','Selling Rate',	1	,1
insert into RptExcelheaders select 2,	8,	'SalesQty','Sales Qty'	,1	,1
insert into RptExcelheaders select 2,	9,	'SalesPrdWeight','Sales Qty in volume',	1	,1
insert into RptExcelheaders select 2,	10,	'Uom1','Cases'	,1	,1
insert into RptExcelheaders select 2,	11,	'Uom2','Boxes'	,1	,1
insert into RptExcelheaders select 2,	12,	'Uom3','Strips'	,1	,1
insert into RptExcelheaders select 2,	13,	'Uom4','Pieces'	,1	,1
insert into RptExcelheaders select 2,	14,	'FreeQty','Free Qty',1	,1
insert into RptExcelheaders select 2,	15,	'FreePrdWeight','Free Qty in volume',1	,1
insert into RptExcelheaders select 2,	16,	'ReplaceQty','Replace Qty',1	,1
insert into RptExcelheaders select 2,	17,	'RepPrdWeight',	'Replacement Qty in volume',0,	1
insert into RptExcelheaders select 2,	18,	'ReturnQty','Return Qty',1	,1
insert into RptExcelheaders select 2,	19,	'RetPrdWeight','Return Qty in volume',1	,1
insert into RptExcelheaders select 2,	20,	'SalesValue','Gross Amount',1,1
Go
--Daily Reports-> Sales Return Report In excel report, K,L,M,N,O columns hidden
Delete From RptExcelheaders where Rptid=9
Insert into RptExcelheaders select 9	,1	,'SRNNumber'	,'SRNNumber'	,1,	1
Insert into RptExcelheaders select 9	,2	,'SRDate'	,'SRDate'	,1	,1
Insert into RptExcelheaders select 9	,3	,'Salesman'	,'Salesman'	,1	,1
Insert into RptExcelheaders select 9	,4	,'RouteName'	,'Route Name'	,1	,1
Insert into RptExcelheaders select 9	,5	,'RtrName'	,'Retailer Name'	,1	,1
Insert into RptExcelheaders select 9	,6	,'BillNo'	,'Bill No'	,1	,1
Insert into RptExcelheaders select 9	,7	,'PrdCode'	,'Product Code'	,1	,1
Insert into RptExcelheaders select 9	,8	,'PrdName'	,'Product Description',	1	,1
Insert into RptExcelheaders select 9	,9	,'StockType	','Stock Type'	,1	,1
Insert into RptExcelheaders select 9	,10	,'Qty'	,'Qunatity'	,1	,1
Insert into RptExcelheaders select 9	,11	,'UsrId'	,'UsrId'	,0	,1
Insert into RptExcelheaders select 9	,12	,'UOM1'	,'UOM1'	,1	,1
Insert into RptExcelheaders select 9	,13	,'UOM2'	,'UOM2'	,1	,1
Insert into RptExcelheaders select 9	,14	,'UOM3'	,'UOM3'	,1	,1
Insert into RptExcelheaders select 9	,15	,'UOM4'	,'UOM4'	,1	,1
Insert into RptExcelheaders select 9	,16	,'[Gross Amount]',	'Gross Amount'	,1	,1
Insert into RptExcelheaders select 9	,17	,'[Spl. Disc]'	,'Spl. Disc'	,1	,1
Insert into RptExcelheaders select 9	,18	,'[Sch Disc]'	,'Sch Disc'	,1	,1
Insert into RptExcelheaders select 9	,19	,'[DB Disc]'	,'DB Disc'	,1	,1
Insert into RptExcelheaders select 9	,20	,'[CD Disc]'	,'CD Disc'	,1	,1
Insert into RptExcelheaders select 9	,21	,'[Tax Amt]'	,'Tax Amt'	,1	,1
Insert into RptExcelheaders select 9	,22	,'[Net Amount]'	,'Net Amount',	1,	1
GO
Delete From RptFormula where Rptid=2
insert into Rptformula select 2,1,'ProductCode','Product Code',	1,	0
insert into Rptformula select 2,2,	'ProductName',	'Product Name',	1,	0
insert into Rptformula select 2	,3	,'BatchNo'	,'Batch Code'	,1	,0
insert into Rptformula select 2	,4	,'MRP',	'MRP',	1	,0
insert into Rptformula select 2	,5	,'SellingRate',	'Selling Rate',	1	,0
insert into Rptformula select 2	,6	,'SalesQuantity',	'Sales Qty',	1	,0
insert into Rptformula select 2	,7	,'FreeQuantity',	'Free Qty'	,1	,0
insert into Rptformula select 2	,8	,'ReplacementQuantity',	'Rep. Qty'	,1,	0
insert into Rptformula select 2	,9	,'SalesValue'	,'Gross Amt'	,1	,0
insert into Rptformula select 2	,10	,'FromDate',	'From Date',	1,	0
insert into Rptformula select 2	,11	,'ToDate'	,'To Date'	,1	,0
insert into Rptformula select 2	,12	,'Company',	'Company',	1,	0
insert into Rptformula select 2	,13	,'Salesman'	,'Salesman'	,1	,0
insert into Rptformula select 2	,14	,'Route',	'Route',	1	,0
insert into Rptformula select 2	,15	,'Retailer'	,'Retailer',	1	,0
insert into Rptformula select 2	,16	,'ProductCategoryLevel',	'Product Hierarchy Level',	1,	0
insert into Rptformula select 2 ,17	,'ProductCategoryValue'	,'Product Hierarchy Level Value',	1	,0
insert into Rptformula select 2	,18	,'BillNumber',	'Bill Number',	1,	0
insert into Rptformula select 2	,19	,'Total'	,'Grand Total	',1	,0
insert into Rptformula select 2	,20	,'Disp_FromDate',	'FromDate',	1,	10
insert into Rptformula select 2	,21	,'Disp_ToDate'	,'ToDate'	,1	,11
insert into Rptformula select 2	,22,'Disp_Company',	'Company',	1,	4
insert into Rptformula select 2	,23	,'Disp_Salesman',	'Salesman',	1	,1
insert into Rptformula select 2	,24	,'Disp_Route'	,'Route'	,1	,2
insert into Rptformula select 2	,25	,'Disp_Retailer',	'Retailer'	,1,	3
insert into Rptformula select 2	,26	,'Disp_ProductCategoryLevel',	'ProductCategoryLevel',	1,	16
insert into Rptformula select 2	,27	,'Disp_ProductCategoryValue'	,'ProductCategoryLevelValue',	1,	21
insert into Rptformula select 2	,28	,'Disp_BillNumber',	'BillNumber',	1,	14
insert into Rptformula select 2	,29	,'Cap Page'	,'Page'	,1	,0
insert into Rptformula select 2	,30	,'Cap User Name',	'User Name',	1,	0
insert into Rptformula select 2	,31	,'Cap Print Date'	,'Date'	,1	,0
insert into Rptformula select 2	,32	,'Cap_Product'	,'Product',	1,	0
insert into Rptformula select 2	,33	,'Disp_Product'	,'Product',	1	,5
insert into Rptformula select 2	,34	,'Disp_Cancelled',	'Display Cancelled Bill Value',	1	,193
insert into Rptformula select 2	,35	,'Fill_Cancelled'	,'Display Cancelled Product Value'	,1	,0
insert into Rptformula select 2	,36	,'Cap_RetailerGroup',	'Retailer Group',	1,	0
insert into Rptformula select 2	,37	,'Disp_RetailerGroup'	,'Retailer Group'	,1	,215
insert into Rptformula select 2	,38	,'Cap_Location',	'Location',	1,	0
insert into Rptformula select 2	,39	,'Disp_Location'	,'Location',	1	,22
insert into Rptformula select 2	,40	,'Cap_Batch',	'Batch',	1	,0
insert into Rptformula select 2	,41	,'Disp_Batch',	'Batch',	1,	7
insert into Rptformula select 2	,42	,'ReturnQuantity'	,'Ret.Qty'	,1,	0
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_CS2CNStkInventory' AND xtype='P')
DROP PROCEDURE Proc_CS2CNStkInventory
GO
CREATE PROCEDURE Proc_CS2CNStkInventory
AS  
/*********************************  
* PROCEDURE : Proc_CS2CNStkInventory  
* PURPOSE : To Extract Stock Ledger Details from CoreStocky to upload to Console  
* CREATED : Nandakumar R.G  
* CREATED DATE : 02/08/2008  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
   
*********************************/  
SET NOCOUNT ON  
BEGIN  
 BEGIN TRAN  
 DECLARE @CmpId   AS INTEGER  
 DECLARE @DistCode As nVarchar(50)  
 DECLARE @ChkDate AS DATETIME  
 DECLARE @PrdId AS INT  
 DECLARE @TransDate AS DATETIME  
  
 DELETE FROM ETL_PrkCS2CNStkInventory WHERE UploadFlag = 'Y'  
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
 SELECT @ChkDate = NextUpDate FROM DayEndProcess Where procId = 2  
 SELECT @TransDate=CONVERT(NVARCHAR(10),GETDATE(),121)  
  
 WHILE @ChkDate<=@TransDate  
 BEGIN  
    
  DELETE FROM TempStockLedSummary  
  EXEC Proc_GetStockLedgerSummaryDatewise @ChkDate, @ChkDate,1,0,0,0  
  INSERT INTO ETL_PrkCS2CNStkInventory  
  SELECT @DistCode,PrdDCode,TransDate,SUM(Opening),SUM(Purchase),SUM(Adjustment),  
  SUM(Closing),SUM(Sales),'N' AS UploadFlag  
  FROM TempStockLedSummary T (NOLOCK)  
  WHERE UserId=1 AND CmpId=@CmpId   
  GROUP BY PrdDCode,TransDate  
  
  SET @ChkDate=DATEADD(D,1,@ChkDate)    
 END  
  
 --DELETE FROM ETL_PrkCS2CNStkInventory WHERE Sales=0 AND Adjustments=0 and Receipt=0  
  
 UPDATE DayEndProcess SET NextUpDate = CONVERT(NVARCHAR(10),GETDATE(),121),  
 ProcDate = CONVERT(NVARCHAR(10),GETDATE(),121)  
 WHERE ProcId = 2  
 COMMIT TRAN  
END  
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_CS2CNPurchaseConfirmation' AND xtype='P')
DROP PROCEDURE Proc_CS2CNPurchaseConfirmation
GO
Create  PROCEDURE Proc_CS2CNPurchaseConfirmation
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_CS2CNPurchaseConfirmation
* PURPOSE: Extract Purchase Confirmation Details from CoreStocky to Console
* NOTES:
* CREATED: JayaKumar.N 15-12-2007
* MODIFIED
* DATE			AUTHOR			DESCRIPTION
------------------------------------------------
* 07-OCT-2010	Jayakumar N		Default Company Id is linked with Product Compnay Id
* 12-OCT-2010	Jayakumar N		Change done as per front end
------------------------------------------------
*
*********************************/
--	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @DiffDate	AS INT
	DELETE FROM ETL_Prk_CS2CNPurchaseConfirmation WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where procId = 3
	SELECT @DiffDate = DATEDIFF(d,NextUpdate,GETDATE()) FROM DayEndProcess WITH(NOLOCK) WHERE ProcId=3
	--Added By Maha on 27-10-2009
	IF NOT EXISTS (SELECT * FROM sysobjects where id = object_id(N'[ExtractTracker]')
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
--		SELECT 3 AS ExtractType , CAST(PurRcptId AS NVARCHAR(200)) AS ExtractRefNo,GoodsRcvdDate AS ExtractDate,
--		CAST(Status AS NVARCHAR(200)) AS STATUS INTO ExtractTracker
--		FROM PurchaseReceipt WHERE Status=1 AND Upload=0 AND CmpId=@CmpId 		
		SELECT DISTINCT 3 AS ExtractType , CAST(PR.PurRcptId AS NVARCHAR(200)) AS ExtractRefNo,GoodsRcvdDate AS ExtractDate,
		CAST(Status AS NVARCHAR(200)) AS STATUS INTO ExtractTracker
		FROM PurchaseReceipt PR (NOLOCK),PurchaseReceiptProduct PRP (NOLOCK),Product P (NOLOCK)
		WHERE PR.Status=1 AND Upload=0 AND P.CmpId=@CmpId
		AND PR.PurRcptId=PRP.PurRcptId AND PRP.PrdId=P.PrdId
		AND GoodsRcvdDate BETWEEN CONVERT(NVARCHAR(10),DATEADD(d,-@DiffDate,GETDATE()),121) AND GETDATE()
	END
	ELSE
	BEGIN
		DELETE FROM ExtractTracker WHERE EXTRACTTYPE=3
		INSERT INTO ExtractTracker
--		SELECT 3,PR.PurRcptId,GoodsRcvdDate,Status FROM PurchaseReceipt PR (NOLOCK)
--		WHERE PR.Status=1 AND Upload=0 AND CmpId=@CmpId
		SELECT DISTINCT 3,PR.PurRcptId,GoodsRcvdDate,Status FROM PurchaseReceipt PR (NOLOCK),
		PurchaseReceiptProduct PRP (NOLOCK),Product P (NOLOCK)
		WHERE PR.Status=1 AND Upload=0 AND P.CmpId=@CmpId
		AND PR.PurRcptId=PRP.PurRcptId AND PRP.PrdId=P.PrdId
		AND GoodsRcvdDate BETWEEN CONVERT(NVARCHAR(10),DATEADD(d,-@DiffDate,GETDATE()),121) AND GETDATE()
	END
	--Till Here
	INSERT INTO ETL_Prk_CS2CNPurchaseConfirmation
	(
		DistCode ,
		ComInvNo ,
		GrnNo ,
		GrnRcvDt ,
		ProdCode ,
		PrdBatCde ,
		GrnQtyRcv ,
		GRNDBRSHTQTY ,
		GRNDBRDMGQTY ,
		GRNDBREXCESSQTY ,
		GRNDREFUSESALE ,
		UploadFlag
	)
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GoodsRcvdDate AS GrnRcvDt ,
		P.PrdCCode AS ProdCode ,
		PB.CmpBatCode AS PrdBatCde ,
		PRP.RcvdGoodBaseQty AS GrnQtyRcv ,
		PRP.ShrtBaseQty AS GRNDBRSHTQTY ,
		PRP.UnSalBaseQty AS GRNDBRDMGQTY ,
		CASE PRP.RefuseSale WHEN 0 THEN ExsBaseQty ELSE 0 END AS GRNDBREXCESSQTY ,
		CASE PRP.RefuseSale WHEN 1 THEN ExsBaseQty ELSE 0 END AS GRNDREFUSESALE ,
		'N'					
	FROM
		PurchaseReceipt PR , 		
		PurchaseReceiptProduct PRP ,
		Product P ,
		ProductBatch PB
	WHERE
		PR.PurRcptId = PRP.PurRcptId AND
		PR.Status = 1 AND
		P.CmpId = @CmpID AND
		P.PrdId = PB.PrdId AND
		P.PrdId = PRP.PrdId AND
		PB.PrdBatId = PRP.PrdBatId AND
		PR.Upload=0
		AND GoodsRcvdDate BETWEEN CONVERT(NVARCHAR(10),DATEADD(d,-@DiffDate,GETDATE()),121) AND GETDATE()
	
--	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
--	ProcDate = CONVERT(nVarChar(10),GetDate(),121) Where procId = 3
--	UPDATE PurchaseReceipt SET Upload=1 WHERE Upload=0 AND PurRcptRefNo IN (SELECT DISTINCT
--		GrnNo FROM ETL_Prk_CS2CNPurchaseConfirmation WHERE UploadFlag = 'N')
--	COMMIT TRAN
END
GO
--Exec Proc_ImportPurchasePrdDt '<Data></Data>'  
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_ImportPurchasePrdDt' AND xtype='P')
DROP PROCEDURE Proc_ImportPurchasePrdDt
GO
CREATE Procedure Proc_ImportPurchasePrdDt  
(  
 @Pi_Records TEXT  
)  
AS  
/*********************************  
* PROCEDURE : Proc_ImportPurchasePrdDt  
* PURPOSE : To Insert records from xml file in the Table ETL_Prk_PurchaseReceiptPrdDt  
* CREATED : Nandakumar R.G  
* CREATED DATE : 31/01/2008  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @hDoc INTEGER  
   
 EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records  
   
 INSERT INTO ETL_Prk_PurchaseReceiptPrdDt  
 SELECT [Company Invoice No],[RowId],[Product Code],[Batch Code],[PO UOM],[PO Qty],  
        [UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount],0 AS [NewPrd]
 FROM OPENXML (@hdoc,'/Data/Purchase_x0020_Receipt_x0020_Product ',1)  
 WITH (  
  [Company Invoice No]   NVARCHAR(100),    
  [RowId]                NVARCHAR(100),    
  [Product Code]         NVARCHAR(100),  
  [Batch Code]           NVARCHAR(100),  
  [PO UOM]               NVARCHAR(100),  
  [PO Qty]               NVARCHAR(100),  
  [UOM]                  NVARCHAR(100),  
  [Invoice Qty]          NVARCHAR(100),  
  [Purchase Rate]        NVARCHAR(100),  
  [Gross]                NVARCHAR(100),  
  [Discount In Amount]   NVARCHAR(100),    
  [Tax In Amount]        NVARCHAR(100),  
  [Net Amount]           NVARCHAR(100)
 ) XMLObj  
 SELECT * FROM ETL_Prk_PurchaseReceiptPrdDt  
   
 EXEC sp_xml_removedocument @hDoc   
END  
GO
Delete From customUpDownloadcount where Module='Purchase Order' And UpDownLoad='DownLoad'

Insert into customUpDownloadcount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,OldMax,
                                   OldCount,NewMax,NewCount,DownloadedCount,SelectQuery)
Values (227,1,'Purchase Order','Purchase Order','Cn2Cs_Prk_BLPurchaseOrder','Cn2Cs_Prk_BLPurchaseOrder','DownLoadFlag','','PORefNo','Download',0,0,'Y',2,2,'')
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_DownloadNotification')
DROP PROCEDURE Proc_DownloadNotification
GO
/*
BEGIN TRANSACTION
EXEC Proc_DownloadNotification 1,2
SELECT SelectQuery,* FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SelectQuery<>''
ORDER BY SlNo
SELECT * FROM Cs2Cn_Prk_DownloadedDetails
ROLLBACK TRANSACTION 
*/
CREATE PROCEDURE [dbo].[Proc_DownloadNotification]
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

					IF @SlNo=214 OR @SlNo=220
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2,Detail3) '+@Str
					END
					ELSE
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2)'+@Str
					END

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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CS2CNPurchaseOrder')
DROP PROCEDURE Proc_CS2CNPurchaseOrder
GO
--Exec Proc_CS2CNPurchaseOrder 0
CREATE PROCEDURE [dbo].[Proc_CS2CNPurchaseOrder]  
(  
	@Po_ErrNo INT OUTPUT  
)  
AS   
SET NOCOUNT ON  
BEGIN  
/*********************************  
* PROCEDURE: Proc_CS2CNPurchaseOrder  
* PURPOSE: Extract Purchase Order details from CoreStocky to Console  
* NOTES:  
* CREATED: MarySubashini.S 08-12-2008  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
 DECLARE @CmpID   AS INTEGER  
 DECLARE @DistCode AS NVARCHAR(50)  
 DECLARE @ChkDate AS DATETIME  
 DELETE FROM ETL_Prk_CS2CNPurchaseOrder WHERE UploadFlag='Y'   
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
 SELECT @ChkDate = NextUpDate FROM DayEndProcess WHERE ProcId = 6  
 SET @Po_ErrNo=0  
 INSERT INTO ETL_Prk_CS2CNPurchaseOrder   
 (   
  [DistCode]  ,  
  [PONumber]  ,  
  [CompanyPONumber] ,  
  [PODate]  ,  
  [POConfirmDate]  ,  
  [ProductHierarchyLevel] ,  
  [ProductHierarchyValue] ,  
  [ProductCode]   ,  
  [Quantity]  ,  
  [POType]    ,  
  [POExpiryDate]   ,  
  [SiteCode] ,  
  [UploadFlag]  
 )  
 SELECT @DistCode,PM.PurOrderRefNo,  
 (CASE PM.DownLoad WHEN 1 THEN PM.CmpPoNo ELSE '' END) AS CompanyPONumber,  
 PM.PurOrderDate,PM.PurOrderDate,ISNULL(PCL1.CmpPrdCtgName,''),ISNULL(PCV1.PrdCtgValCode,''),  
 P.PrdCCode,(PD.OrdQty*UG.ConversionFactor) AS Quantity,  
 (CASE PM.DownLoad WHEN 0 THEN 'Manual' ELSE 'Automatic' END ) AS POType,  
 (CASE PM.DownLoad WHEN 0 THEN PM.PurOrderExpiryDate ELSE PM.PurOrderExpiryDate END ) AS POExpiryDate,  
 ISNULL(SCM.SiteCode,''),'N'  
 FROM PurchaseOrderDetails PD  WITH (NOLOCK)   
 LEFT OUTER JOIN PurchaseOrderMaster PM WITH (NOLOCK)  ON PM.PurOrderRefNo=PD.PurOrderRefNo  
 LEFT OUTER JOIN Product P WITH (NOLOCK)  ON P.PrdId=PD.PrdId  
 LEFT OUTER JOIN UomGroup UG WITH (NOLOCK)  ON UG.UomGroupId=P.UomGroupId AND UG.UomId=PD.OrdUomId  
 LEFT OUTER JOIN ProductCategoryValue PCV WITH (NOLOCK)  ON PCV.PrdCtgValMainId=PM.PrdCtgValMainId   
 LEFT OUTER JOIN ProductCategoryValue PCV1 WITH (NOLOCK)  ON PCV1.PrdCtgValLinkCode=LEFT(PCV.PrdCtgValLInkCode,10)   
 LEFT OUTER JOIN ProductCategoryLevel PCL1 WITH (NOLOCK)  ON PCL1.CmpPrdCtgId=PCV1.CmpPrdCtgId   
 LEFT OUTER JOIN SiteCodeMaster SCM WITH (NOLOCK) ON PM.SiteId=SCM.SiteId   
 WHERE PM.ConfirmSts=1 AND PM.Upload=0  
 UPDATE PurchaseOrderMaster SET Upload=1 WHERE Upload=0 AND ConfirmSts=1  
 AND PurOrderRefNo IN (SELECT PONumber FROM ETL_Prk_CS2CNPurchaseOrder)   
END
GO
if not exists (select * from hotfixlog where fixid = 386)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(386,'D','2011-09-07',getdate(),1,'Core Stocky Service Pack 386')
GO  
