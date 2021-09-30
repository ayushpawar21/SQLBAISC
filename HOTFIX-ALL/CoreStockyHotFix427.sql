--[Stocky HotFix Version]=427
DELETE FROM Versioncontrol WHERE Hotfixid='427'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('427','3.1.0.4','D','2016-03-22','2016-03-22','2016-03-22',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
DELETE FROM Configuration WHERE MODULEID='BotreeAutoBatchTransfer'
INSERT INTO Configuration
SELECT 'BotreeAutoBatchTransfer','Product Batch Download','Transfer Stock Automatically from old batch to new batch on new batch download',1,'',0,1
GO
DELETE FROM RptHeader where RPTID=286
INSERT INTO RptHeader
SELECT 'ParleClaimReport','Parle Claim Report',286,'Parle Claim Report','Proc_RptParleClaimReport','RptParleClaimReportAll','RptParleClaimReport.rpt',''
GO
DELETE FROM RptFilter where RPTID=286
INSERT INTO RptFilter
SELECT 286,Selcid,Filterid,FilterDesc from RptFilter where RPTID=33
GO
DELETE FROM RptDetails where RPTID=286
INSERT INTO Rptdetails
SELECT 286,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0
UNION
SELECT 286,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0
UNION
SELECT 286,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to Select Company',0
UNION
SELECT 286,4,'ClaimSheetHD',3,'Cmpid','ClmId,ClmCode,ClmDesc','Claim Description...','Company',1,'Cmpid',41,0,0,'Press F4/Double Click to Select Claim',0
UNION
SELECT 286,5,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Status...','',1,'',83,1,0,'Press F4/Double Click to Select Status',0
GO
DELETE FROM RptGroup where RPTID=286
INSERT INTO RptGroup
SELECT 'SchemeNClaimReport',286,'ParleClaimReport','Parle Claim Report',1
GO
DELETE FROM RptGridView where RPTID=286
INSERT INTO RptGridView
SELECT 286,'RptParleClaimReport.rpt',1,0,1,0
GO
IF Exists (SELECT * FROM Sysobjects Where name='RptParleClaimReportAll' and XTYPE='U')
DROP TABLE RptParleClaimReportAll
GO
CREATE TABLE RptParleClaimReportAll
(
	[CmpId] [int] NULL,
	[RefNo] [varchar](200) NULL,
	[ClaimCode] [nvarchar](20) NULL,
	[CircularNo] [nvarchar](100),
	[ClaimDate] [datetime] NULL,
	[ClaimId] [int] NULL,
	[ClaimDesc] [nvarchar](50) NULL,
	[ClaimGrpId] [int] NULL,
	[ClaimGrpName] [nvarchar](50) NULL,
	[SchValue] [numeric](38,2),
	[NonSchValue] [numeric](38,2),
	[TotalValue] [numeric](38,2),
	[TotalSpent] [numeric](38, 2) NULL,
	[ClaimPercentage] [numeric](38, 2) NULL,
	[ClaimAmount] [numeric](38, 2) NULL,
	[RecommendedAmount] [numeric](38, 2) NULL,
	[ReceivedAmount] [numeric](38, 2) NULL,
	[PendingAmount] [numeric](38, 2) NULL,
	[Status] [nvarchar](20) NULL,
	[UsrId] [int] NULL,
	[StatusId] [tinyint] NULL,
	[BillsCut] [Int],
	[Outlet] [Int],
	[OutletPer] [Numeric](38,2),
	[Schid] [Int]
)
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_RptParleClaimReportAll' and XTYPE='P')
DROP PROCEDURE Proc_RptParleClaimReportAll
GO
CREATE PROCEDURE Proc_RptParleClaimReportAll
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT
)
AS
SET NOCOUNT ON
BEGIN
	DELETE FROM RptparleClaimReportAll WHERE UsrId = @Pi_UsrId
	
	INSERT INTO RptParleClaimReportAll (CmpId,RefNo,ClaimCode,CircularNo,ClaimDate,ClaimId,ClaimDesc,ClaimGrpId,ClaimGrpName,SchValue,NonSchValue,TotalValue,
	TotalSpent,ClaimPercentage,ClaimAmount,RecommendedAmount,ReceivedAmount,PendingAmount,Status,UsrId,StatusId,BillsCut,Outlet,OutletPer,Schid)
    SELECT CM.CmpId,(CASE LEN(ISNULL(SM.CmpSchCode,'')) WHEN 0 THEN ISNULL(SM.SchCode,'')+' - '+SM.SchDsc ELSE ISNULL(SM.CmpSchCode,'')+' - '+SM.SchDsc END) AS RefCode,
    CM.ClmCode,SM.BudgetAllocationNo,
    CM.ClmDate,CM.ClmId,CM.ClmDesc,CM.ClmGrpId,CG.ClmGrpName,0 as SchValue,0 as NonSchValue,0 as totalValue,
    CD.TotalSpent,CD.ClmPercentage,
	CD.ClmAmount,CD.RecommendedAmount,CD.ReceivedAmount,CD.RecommendedAmount - CD.ReceivedAmount PendingAmount,
	Case CD.Status When 1 Then 'Pending' When 2 Then 'Settled' When 3 Then 'Rejected' When 4 Then 'Cancelled' End Status,
	@Pi_UsrId,CD.Status AS StatusId,0 as BillsCut,0 as Outlet,0 as OutletPer,SM.Schid
	FROM ClaimSheetHD CM
	LEFT OUTER JOIN ClaimSheetDetail CD ON CM.ClmId = CD.ClmId
	LEFT OUTER JOIN ClaimGroupMaster CG ON CM.ClmGrpId = CG.ClmGrpId
	INNER JOIN SchemeMaster SM ON CD.RefCode=SM.SchCode
	WHERE CM.[Confirm] = 1 AND CG.ClmGrpId=17 and SelectMode=1
	
	CREATE Table #RptParleClaim
	(
	Schid Int,
	Clmid int,
	SchValue Numeric(38,2),
	NonSchValue Numeric(38,2),
	Bills Int,
	Outlet Numeric(38,2),
	OutletPer Numeric(38,2),
	TotOut Numeric(38,2),
	)
	
	CREATE Table #RptSchValue
	(
	 Schid Int,
	 Value Numeric(38,2)
	 )
	 
	 CREATE Table #Prdwise
	 (
	 Schid int,
	 Salid Int,
	 Prdid Int,
	 Gross Numeric(38,2),
	 TaxPerc Numeric(38,6),
	 Tax Numeric(38,2),
	 Amt Numeric(38,2),
	 Type Nvarchar(100),
	 )
	 
	 CREATE Table #Prdwise1
	 (
	 Schid int,
	 Salid Int,
	 Prdid Int,
	 Gross Numeric(38,2),
	 TaxPerc Numeric(38,6),
	 Tax Numeric(38,2),
	 Amt Numeric(38,2),
	 Type Nvarchar(100),
	 )
	 
	 CREATE Table #Tax
	 (
	 Prdid Int,
	 Taxperc numeric(38,6),
	 Salid int,
	 SlNo Int
	 )
	 
	 Insert Into #RptParleClaim
	 SELECT Distinct Schid,ClaimId,0,0,0,0,0,0 from RptParleClaimReportAll
	 
	 INSERT Into #Prdwise
	 SELECT Distinct Schid,Salid,Prdid,0,0,0,0,TYPE from 
	 (SELECT Distinct B.Schid,Salid,Prdid,'Sales' as Type from SalesInvoiceSchemeLineWise A (Nolock) ,#RptParleClaim B (Nolock)
	 WHERE A.SchClmId=B.Clmid AND A.SchId=B.Schid
	 Union
	 SELECT Distinct B.Schid,ReturnID,Prdid,'SalesReturn' as Type from ReturnSchemeLineDt A (Nolock) ,#RptParleClaim B (Nolock)
	 WHERE A.SchClmId=B.Clmid AND A.SchId=B.Schid
	 Union
	 SELECT Distinct B.Schid,Salid,Prdid,'Sales' as Type from SalesInvoiceSchemeDtBilled A (Nolock) ,#RptParleClaim B (Nolock)
	 WHERE A.SchId=B.Schid AND A.SchId In (Select Distinct Schid from SalesInvoiceSchemeDtFreePrd(Nolock))
	 )A
	 
	 
	 Update B set Gross=(PrdUnitselRate * baseQty) from SalesInvoiceProduct A ,#Prdwise B
	 WHERE A.SalId=B.Salid and A.PrdId=B.Prdid  and B.Type='Sales'
	 

    Insert into #Tax
    SELECT B.Prdid,SUM(A.TaxPerc),a.SalId,PrdSlno from SalesInvoiceProductTax A (Nolock),SalesInvoiceProduct B (Nolock),#Prdwise C
    WHERE A.PrdSlNo=B.SlNo and A.SalId=B.SalId AND A.SalId=C.Salid and B.SalId=C.Salid and B.PrdId=C.Prdid 
    AND C.Type='Sales' gROUP BY b.PrdId,a.SalId,PrdSlno 
	 
	 Update B set TaxPerc=A.Taxperc from #Tax A ,#Prdwise B
	 WHERE A.SalId=B.Salid and A.PrdId=B.Prdid  and B.Type='Sales'
	 
	  Update B set Gross=(PrdUnitSelRte * baseQty) from Returnproduct A ,#Prdwise B
	 WHERE A.ReturnID=B.Salid and A.PrdId=B.Prdid  and B.Type='SalesReturn'
	 
	 Delete from #Tax
	 
	Insert into #Tax
    SELECT B.Prdid,SUM(A.TaxPerc),a.ReturnId,PrdSlno  from ReturnProductTax A (Nolock),ReturnProduct B (Nolock),#Prdwise C
    WHERE A.PrdSlNo=B.SlNo and A.ReturnId=B.ReturnId AND A.ReturnId=C.Salid and B.ReturnId=C.Salid and B.PrdId=C.Prdid 
    AND C.Type='SalesReturn' gROUP BY b.PrdId,a.ReturnId,PrdSlno
	 
	 Update B set TaxPerc=A.Taxperc from #Tax A ,#Prdwise B
	 WHERE A.SalId=B.Salid and A.PrdId=B.Prdid  and B.Type='SalesReturn'
	 
	 Update #Prdwise set Tax=(Gross *(TaxPerc/100))
	 
	 Update #Prdwise set Amt=Gross+tax
	 
	 Update #Prdwise set Amt=-1*Amt where Type='SalesReturn'
	 
	 Insert into #RptSchValue 
	 select Schid,SUM(Amt) from #Prdwise Group by schid
	 
	 Update B set SchValue=Value from #RptSchValue A,#RptParleClaim b where A.Schid=B.Schid
	 

	 
	 
	 Insert into #Prdwise1
	 SELECT Distinct A.Schid,A.Salid,B.PrdId,0,0,0,0,'Sales' from #Prdwise A,SalesInvoiceProduct B (Nolock) 
	 WHERE A.Salid=B.SalId and (CAST(B.Salid AS nVarChar(10)))+'~'+(CAST(B.Prdid AS nVarChar(10)))
	  Not in (select (CAST(Salid AS nVarChar(10)))+'~'+(CAST(Prdid AS nVarChar(10))) from #Prdwise WHERE Type='Sales') AND A.Type='Sales'
	 Union
	 SELECT Distinct A.Schid,A.Salid,B.PrdId,0,0,0,0,'SalesReturn' from #Prdwise A,ReturnSchemeLineDt B (Nolock)
	 WHERE A.Salid=B.ReturnID AND (CAST(B.ReturnID AS nVarChar(10)))+'~'+(CAST(B.Prdid AS nVarChar(10)))
	  Not in (select (CAST(Salid AS nVarChar(10)))+'~'+(CAST(Prdid AS nVarChar(10))) from #Prdwise WHERE Type='SalesReturn') AND A.Type='SalesReturn'
	  
	  
	  Update B set Gross=(PrdUnitselRate * baseQty) from SalesInvoiceProduct A ,#Prdwise1 B
	 WHERE A.SalId=B.Salid and A.PrdId=B.Prdid  and B.Type='Sales'
	 

    Insert into #Tax
    SELECT B.Prdid,SUM(A.TaxPerc),a.SalId,PrdSlno from SalesInvoiceProductTax A (Nolock),SalesInvoiceProduct B (Nolock),#Prdwise1 C
    WHERE A.PrdSlNo=B.SlNo and A.SalId=B.SalId AND A.SalId=C.Salid and B.SalId=C.Salid and B.PrdId=C.Prdid 
    AND C.Type='Sales' gROUP BY b.PrdId,a.SalId,PrdSlno 
	 
	 Update B set TaxPerc=A.Taxperc from #Tax A ,#Prdwise1 B
	 WHERE A.SalId=B.Salid and A.PrdId=B.Prdid  and B.Type='Sales'
	 
	  Update B set Gross=(PrdUnitSelRte * baseQty) from Returnproduct A ,#Prdwise1 B
	 WHERE A.ReturnID=B.Salid and A.PrdId=B.Prdid  and B.Type='SalesReturn'
	 
	 Delete from #Tax
	 
	Insert into #Tax
    SELECT B.Prdid,SUM(A.TaxPerc),a.ReturnId,PrdSlno  from ReturnProductTax A (Nolock),ReturnProduct B (Nolock),#Prdwise1 C
    WHERE A.PrdSlNo=B.SlNo and A.ReturnId=B.ReturnId AND A.ReturnId=C.Salid and B.ReturnId=C.Salid and B.PrdId=C.Prdid 
    AND C.Type='SalesReturn' gROUP BY b.PrdId,a.ReturnId,PrdSlno 
	 
	 Update B set TaxPerc=A.Taxperc from #Tax A ,#Prdwise1 B
	 WHERE A.SalId=B.Salid and A.PrdId=B.Prdid  and B.Type='SalesReturn'
	 
	 Update #Prdwise1 set Tax=(Gross *(TaxPerc/100))
	 
	 Update #Prdwise1 set Amt=Gross+tax
	 
	 Update #Prdwise1 set Amt=-1*Amt where Type='SalesReturn'
	 
	 Delete from #RptSchValue
	 
	 Insert into #RptSchValue 
	 select Schid,SUM(Amt) from #Prdwise1 Group by schid
	 
	 Update B set NonSchValue=Value from #RptSchValue A,#RptParleClaim b where A.Schid=B.Schid
	 
	 
	 select Count(Distinct Salid) as Bill,Schid into #BillCutDet from SalesInvoiceSchemeDtBilled
	  where SchId In (select SchId from #RptParleClaim)
	  and SalId In (select SalId from Salesinvoice where DlvSts>3)
      Group by SchId 

	 
	 
	 select Count(Distinct Rtrid) as Bill,Schid into #BillDetails
	 from SalesInvoiceSchemeDtBilled A,Salesinvoice B where A.Salid=B.Salid and 
	 SchId In (select SchId from #RptParleClaim) and DlvSts>3
	 Group by SchId 
	 
	 Update B set Bills=Bill from #BillCutDet A,#RptParleClaim b where A.Schid=B.Schid
	 
	 Update B set Outlet=Bill from #BillDetails A,#RptParleClaim b where A.Schid=B.Schid
	   
	 select Count(Distinct Rtrid) as Id into #TotRet from Retailer 

     Update #RptParleClaim set TotOut=Id from #TotRet 

	 
	Update #RptParleClaim set OutletPer=(Outlet/TotOut)
	
	
	Update B set SchValue=A.SchValue,NonSchValue=A.NonSchValue,BillsCut=A.Bills,Outlet=A.Outlet,OutletPer=A.OutletPer FROM #RptParleClaim A,
	RptParleClaimReportAll B where A.Schid=B.Schid and A.Clmid=B.ClaimId
	
	Update RptParleClaimReportAll set TotalValue=SchValue + NonSchValue

END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_RptParleClaimReport' and XTYPE='P')
DROP PROCEDURE Proc_RptParleClaimReport
GO
--EXEC Proc_RptParleClaimReport 286,2,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptParleClaimReport
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
DECLARE @CmpId         	AS  	INT
DECLARE @ClmId	   	AS	INT
DECLARE @ClmGrpId	AS	INT
DECLARE @Status	   	AS	INT
--Till Here
EXEC Proc_RptParleClaimReportAll @Pi_RptId ,@Pi_UsrId
--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @ClmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,41,@Pi_UsrId))
SET @ClmGrpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,42,@Pi_UsrId))
SET @Status = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,83,@Pi_UsrId))
--Till Here
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--Till Here
CREATE TABLE #RptparleClaimReportAll
(
	[ClaimCode] [nvarchar](20),
	[CircularNo] [nvarchar](100),
	[ClaimDesc] [nvarchar](50),
	[ClaimGrpName] [nvarchar](50),
	[SchValue] [numeric](38,2),
	[NonSchValue] [numeric](38,2),
	[TotalValue] [numeric](38,2),
	[TotalSpent] [numeric](38, 2),
	[ClaimPercentage] [numeric](38, 2),
	[ClaimAmount] [numeric](38, 2),
	[RecommendedAmount] [numeric](38, 2),
	[ReceivedAmount] [numeric](38, 2),
	[PendingAmount] [numeric](38, 2),
	[Status] [nvarchar](20),
	[BillsCut] [Int],
	[Outlet] [Int],
	[OutletPer] [Numeric](38,2)
)
SET @TblName = 'RptparleClaimReportAll'
SET @TblStruct = '  [ClaimCode] [nvarchar](20),
	[CircularNo] [nvarchar](100),
	[ClaimDesc] [nvarchar](50),
	[ClaimGrpName] [nvarchar](50),
	[SchValue] [numeric](38,2),
	[NonSchValue] [numeric](38,2),
	[TotalValue] [numeric](38,2),
	[TotalSpent] [numeric](38, 2),
	[ClaimPercentage] [numeric](38, 2),
	[ClaimAmount] [numeric](38, 2),
	[RecommendedAmount] [numeric](38, 2),
	[ReceivedAmount] [numeric](38, 2),
	[PendingAmount] [numeric](38, 2),
	[Status] [nvarchar](20),
	[BillsCut] [Int],
	[Outlet] [Int],
	[OutletPer] [Numeric](38,2)'
SET @TblFields = ' [ClaimCode],
	[CircularNo],
	[ClaimDesc],
	[ClaimGrpName],
	[SchValue],
	[NonSchValue],
	[TotalValue],
	[TotalSpent],
	[ClaimPercentage],
	[ClaimAmount],
	[RecommendedAmount],
	[ReceivedAmount],
	[PendingAmount],
	[Status],
	[BillsCut],
	[Outlet],
	[OutletPer]'
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
	INSERT INTO #RptparleClaimReportAll([ClaimCode],[CircularNo],[ClaimDesc],[ClaimGrpName],[SchValue],[NonSchValue],[TotalValue],
	[TotalSpent],[ClaimPercentage],[ClaimAmount],[RecommendedAmount],[ReceivedAmount],[PendingAmount],[Status],
	[BillsCut],[Outlet],[OutletPer] )
    		
	SELECT
     [ClaimCode],[CircularNo],[ClaimDesc],[ClaimGrpName],[SchValue],[NonSchValue],[TotalValue],
	[TotalSpent],[ClaimPercentage],[ClaimAmount],[RecommendedAmount],[ReceivedAmount],[PendingAmount],[Status],
	[BillsCut],[Outlet],[OutletPer] 
    FROM RptParleClaimReportAll
	     WHERE
	     UsrId = @Pi_UsrId and
         (ClaimId=(CASE @ClmId WHEN 0 THEN ClaimId ELSE 0 END) OR
					ClaimId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,41,@Pi_UsrId)) )
     --    AND (ClaimGrpId=(CASE @ClmGrpId WHEN 0 THEN ClaimGrpId ELSE 0 END) OR
					--ClaimGrpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,42,@Pi_UsrId)) )
         AND (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )
	      AND (StatusId = (CASE @Status WHEN 0 THEN StatusId ELSE 0 END) OR
					StatusId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,83,@Pi_UsrId)) )
         AND [ClaimDate] Between @FromDate and @ToDate
	
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptClaimReportAll ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
         + '         WHERE
                     UsrId = ' + @Pi_UsrId + ' and
         (ClaimId=(CASE ' + @ClmId + ' WHEN 0 THEN ClaimId ELSE 0 END) OR
					ClaimId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',41,' + @Pi_UsrId + ')) )
         AND (CmpId = (CASE ' + @CmpId + ' WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',4,' + @Pi_UsrId + ')) )
		 AND [ClaimDate] Between ' + @FromDate + ' and ' + @ToDate
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptClaimReportAll'
	
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
		SET @SSQL = 'INSERT INTO #RptClaimReportAll ' +
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptParleClaimReportAll
-- Till Here
SELECT * FROM #RptParleClaimReportAll Order By ClaimCode
RETURN
END
GO
Delete from RptExcelHeaders where RPTID=286
GO
Insert into RptExcelHeaders
select 286,1,'ClaimCode','Claim Code',1,1
Union
select 286,2,'CircularNo','Circular No',1,1
Union
select 286,3,'ClaimDesc','Claim Description',1,1
Union
select 286,4,'ClaimGrpName','Claim Group',1,1
Union
select 286,5,'SchValue','SalesValue - Scheme',1,1
Union
select 286,6,'NonSchValue','SalesValue - NonScheme',1,1
Union
select 286,7,'TotalValue','SalesValue - Total',1,1
Union
select 286,8,'TotalSpent','Total Spent Amount',1,1
Union
select 286,9,'ClaimPercentage','Claimable%',1,1
Union
select 286,10,'ClaimAmount','Claimable Amount',1,1
Union
select 286,11,'RecommendedAmount','Recommended Amount',1,1
Union
select 286,12,'ReceivedAmount','Received Amount',1,1
Union
select 286,13,'PendingAmount','Pending Amount',1,1
Union
select 286,14,'Status','Status',1,1
Union
select 286,15,'BillsCut','BillsCut',1,1
Union
select 286,16,'Outlet','Outlet participation in	Nos',1,1
Union
select 286,17,'Outletper','Outlet participation in %',1,1
GO
Delete from RptFormula where RPTID=286
GO
INSERT INTO RptFormula
select 286,SlNo,Formula,FormulaValue,Lcid,Selcid from RptFormula where RPTID=33
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Proc_RptRetailerwiseSchemeUtilization' and XTYPE='P')
DROP PROCEDURE Proc_RptRetailerwiseSchemeUtilization
GO
-----  EXEC [Proc_RptRetailerwiseSchemeUtilization] 215,2,0,'Nestle',0,0,1
CREATE PROCEDURE Proc_RptRetailerwiseSchemeUtilization
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(100),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
AS
/****************************************************************************************************************
* PROCEDURE  : Proc_RptRetailerwiseSchemeUtilization
* PURPOSE    : To Generate Retailerwise SchemeUtilization Report 
* CREATED BY : Panneerselvam.k
* CREATED ON : 12/11/2009  
* MODIFICATION 
*****************************************************************************************************************   
* DATE			AUTHOR				DESCRIPTION   
* 18.11.2009	Panneerselvam		ValueMismatch
* 26.11.2009    Panneerselvam.k		ValueMismatch
* 19-10-2015    Gopi                SchemeCode,NetAmt,Liability Columns added
*****************************************************************************************************************/ 
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
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId 		AS	INT
	DECLARE @RtrId 		AS	INT
	DECLARE @CtgLevelId	AS 	INT
	DECLARE @RtrClassId	AS 	INT
	DECLARE @CtgMainId 	AS 	INT
	DECLARE @FromBillNo	AS	INT
	DECLARE @ToBillNo	AS	INT
	DECLARE @Status		AS	INT
	DECLARE @CmpId		AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE	@SchNo		AS	INT
			/*	Till Here	*/
			/*  Assgin Value for the Filter Variable  */
	SELECT	@FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT	@ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET	@SMId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))	
	SET @RtrId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @CtgMainId	=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @CtgLevelId =0
	SET @RtrClassId =0
	SET @CtgMainId	=0
IF @FromBillNo = 0 
BEGIN
	SET @FromBillNo =(SELECT Min(SalId) FROM SalesInvoice WHERE SalInvDate Between @FromDate AND @ToDate)
	SET @TOBillNo	=(SELECT Max(SalId) FROM SalesInvoice WHERE SalInvDate Between @FromDate AND @ToDate )
END 
	SET @CmpId	=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SchNo	=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,258,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
			/*  Table Structure  */
	Create TABLE #RptRtrWiseSchUtilization
	(
				SalId			BigInt,
				SalInvNo		NVARCHAR(100),
				SalInvDate		DATETIME,
				RtrId			INT,
				RtrCode			NVARCHAR(200),
				RtrName			NVARCHAR(200),
				SchId			INT,
				SchDsc			NVARCHAR(200),
				PrdId			INT,
				PrdDCode		NVARCHAR(200),
				PrdName			NVARCHAR(200),
				BilledQty		INT,
				PrdUnitSelRate	NUMERIC(38,2),
				PrdUnitMRP		NUMERIC(38,2),		
				GrossValue      NUMERIC(38,2),
				FreeQty			NUMERIC(38,2),
				SchemeValue		NUMERIC(38,6),
				FlatAmount		NUMERIC(38,6),
				DiscountPerAmount	 NUMERIC(38,6),
				PrimarySchemeAmt	  NUMERIC(38,6),
				NetAmt	  NUMERIC(38,6),  ---Gopi at 19-10-2015
				Liability	  NUMERIC(38,2)
	)
	SET @TblName = 'RptRtrWiseSchUtilization'
	SET @TblStruct = '	
				SalId			BigInt,
				SalInvNo		NVARCHAR(100),
				SalInvDate		DATETIME,
				RtrId			INT,
				RtrCode			NVARCHAR(200),
				RtrName			NVARCHAR(200),
				SchId			INT,
				SchDsc			NVARCHAR(200),
				PrdId			INT,
				PrdDCode		NVARCHAR(200),
				PrdName			NVARCHAR(200),
				BilledQty		INT,
				PrdUnitSelRate	NUMERIC(38,2),
				PrdUnitMRP		NUMERIC(38,2),		
				GrossValue      NUMERIC(38,2),
				FreeQty			NUMERIC(38,2),
				SchemeValue		NUMERIC(38,6),
				FlatAmount		NUMERIC(38,6),
				DiscountPerAmount	 NUMERIC(38,6),
				PrimarySchemeAmt	  NUMERIC(38,6),
				NetAmt	  NUMERIC(38,6),
				Liability	  NUMERIC(38,2)'
	SET @TblFields =   'SalId,SalInvNo,SalInvDate,RtrId,RtrCode,RtrName,SchId,SchDsc,PrdId,PrdDCode,PrdName,
						BilledQty,PrdUnitSelRate,PrdUnitMRP,GrossValue,FreeQty,SchemeValue,FlatAmount,
						DiscountPerAmount,PrimarySchemeAmt,NetAmt,Liability'
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
					
						/*	Calculate Free Quantity  */
					INSERT INTO #RptRtrWiseSchUtilization
					SELECT    
							SI.SalId,SI.SalInvNo,SI.SalInvDate,
							SI.RtrId,R.RtrCode,R.RtrName,
							SM.SchId,SM.SchDsc,
							A.PrdId,PrdCCode,PrdName,
							0 BilledQty,
							0 PrdUnitSelRate, 0 PrdUnitMRP,
							0 GrossValue,
							(FreeQty) FreeQty,
							0 AS SchemeValue,
							0 AS FlatAmount,
							0 AS DiscountPerAmount,
							0 AS PrimarySchemeAmt,
							0 as NetAmt, ---Gopi at 19-10-2015
							0 as Liability 
							
					FROM 
							SalesInvoice SI WITH (NOLOCK),SchemeMaster SM WITH (NOLOCK),
							Retailer R WITH (NOLOCK),Product P WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),
							SalesInvoiceSchemeDtFreePrd SISDF WITH (NOLOCK),SalesInvoiceSchemeDtBilled A WITH (NOLOCK),
							RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK), 
							RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL WITH (NOLOCK)
					WHERE 
							SI.SalId = SISDF.SalId 		AND SI.SalId  = A.SalId AND A.SchId = SISDF.SchId
							AND P.PrdId = Pb.PrdId		AND PB.PrdId = A.PrdId	AND PB.PrdBatId = A.PrdbatId
							AND SI.RtrId = R.RtrId		AND a.SalId = SI.SalId  AND SISDF.SchId  = SM.SchId
							AND A.PrdId = P.PrdId		AND  R.Rtrid = RVCM.RtrId	
							AND RVCM.RtrValueClassId = RVC.RtrClassId
							AND A.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
														a.SalId = B1.SalId AND a.SchId = B1.SchID AND a.SlabId = B1.SlabId)
							AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
							AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
							AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
											RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
							AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
											RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
							AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
											RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
							AND(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
											SI.RtrId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
							AND(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId  ELSE 0 END) OR
											SI.SMId  IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))	
							AND	(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
											SI.RMId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))	
							AND (SI.SalId Between @FromBillNo and @TOBillNo)							
							AND	(SI.CmpId = (CASE @CmpId WHEN 0 THEN SI.CmpId ELSE 0 END) OR
											SI.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
							AND	(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId ELSE 0 END) OR
											A.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							AND(SM.SchId = (CASE @SchNo WHEN 0 THEN SM.SchId ELSE 0 END) OR
											SM.SchId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,258,@Pi_UsrId)))
							AND	 SI.SalInvDate Between @FromDate AND @ToDate 		
							AND SI.Dlvsts in(4,5)
							
								/*	Calculate Window Display Scheme Amount  */
					INSERT INTO #RptRtrWiseSchUtilization
					SELECT  Distinct
							SI.SalId,SI.SalInvNo,SI.SalInvDate,
							SI.RtrId,R.RtrCode,R.RtrName,
							SM.SchId,SM.SchDsc,
							0 PrdId, '' PrdDCode,
							'' PrdName,
							0 BilledQty,
							0 PrdUnitSelRate, 0 PrdUnitMRP,
							0 GrossValue,
							0 FreeQty,			 
							WD.AdjAmt AS SchemeValue,
							0	FlatAmount,
							0  DiscountPerAmount,
							0  PrimarySchemeAmt,
							0 as NetAmt, ---Gopi at 19-10-2015
							0 as Liability 
					FROM 
							SalesInvoice SI WITH (NOLOCK),SalesInvoiceProduct SIP WITH (NOLOCK),
							SalesInvoiceWindowDisplay WD WITH (NOLOCK),
							Product P WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),Retailer R WITH (NOLOCK),
							SchemeMaster SM WITH (NOLOCK),
							RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK), 
							RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL WITH (NOLOCK)
					WHERE 
							SI.SalId = WD.SalId	AND SI.SalId = WD.SalId		AND WD.SchId	= SM.SchId		
							AND SI.RtrId	= R.RtrId		AND SI.RtrId	= WD.RtrId													
							AND R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
							AND RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
							AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
											RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
							AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
											RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
							AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
										RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
							AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
										SI.RtrId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
							AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId  ELSE 0 END) OR
										SI.SMId  IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))	
							AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
										SI.RMId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))	
							AND (SI.SalId Between @FromBillNo and @TOBillNo)							
							AND	(SI.CmpId = (CASE @CmpId WHEN 0 THEN SI.CmpId ELSE 0 END) OR
										SI.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
--							AND	(SIP.PrdId = (CASE @PrdId WHEN 0 THEN SIP.PrdId ELSE 0 END) OR
--										SIP.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))							
							AND(SM.SchId = (CASE @SchNo WHEN 0 THEN SM.SchId ELSE 0 END) OR
										SM.SchId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,258,@Pi_UsrId)))
							AND SI.SalInvDate Between @FromDate AND @ToDate 		
							AND SI.Dlvsts in(4,5)
								/*	Calculate Free Amount  */
				INSERT INTO #RptRtrWiseSchUtilization
				SELECT  
							SI.SalId,SI.SalInvNo,SI.SalInvDate,
							SI.RtrId,R.RtrCode,R.RtrName,
							SM.SchId,SM.SchDsc,
							SISLW.PrdId,PrdCCode,
							PrdName,
							0 BilledQty,
							0 PrdUnitSelRate, 0 PrdUnitMRP,
							0 GrossValue,
							0 FreeQty,				
							Sum(SISLW.FlatAmount+SISLW.DiscountPerAmount) AS SchemeValue,
							Sum(SISLW.FlatAmount)	FlatAmount,
							Sum(DiscountPerAmount)  DiscountPerAmount,
							SUM(SISLW.PrimarySchemeAmt)   PrimarySchemeAmt,
							0 as NetAmt, ---Gopi at 19-10-2015
							0 as Liability 
					FROM 
							SalesInvoice SI,SchemeMaster SM,
							Retailer R,Product P,ProductBatch PB,SalesInvoiceSchemeLineWise SISLW,
							RetailerValueClassMap RVCM ,RetailerValueClass RVC, 
							RetailerCategory RC,RetailerCategoryLevel RCL
					WHERE 
							SISLW.SalId = SI.SalId				AND SISLW.SchId = SM.SchId
							AND P.PrdId = SISLW.PrdId			AND PB.PrdId    = SISLW.PrdId		
							AND PB.PrdBatId = SISLW.PrdBatId	AND Si.RtrId = R.RtrId							
							AND  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
							AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
							AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
												RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
							AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
												RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
							AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
												RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
							AND(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
												SI.RtrId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
							AND(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId  ELSE 0 END) OR
												SI.SMId  IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))	
							AND	(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
												SI.RMId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))	
							AND (SI.SalId Between @FromBillNo and @TOBillNo)							
							AND (SI.CmpId = (CASE @CmpId WHEN 0 THEN SI.CmpId ELSE 0 END) OR
										SI.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
							AND	(SISLW.PrdId = (CASE @PrdId WHEN 0 THEN SISLW.PrdId ELSE 0 END) OR
										SISLW.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							AND (SM.SchId = (CASE @SchNo WHEN 0 THEN SM.SchId ELSE 0 END) OR
										SM.SchId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,258,@Pi_UsrId)))		
							AND	SI.SalInvDate Between @FromDate AND @ToDate 	
							AND SI.Dlvsts in(4,5)
					GROUP BY 
							SI.SalId,SI.SalInvNo,SI.SalInvDate,	SI.RtrId,R.RtrCode,R.RtrName,SM.SchId,SM.SchDsc,
							SISLW.PrdId,PrdCCode,PrdName
		IF LEN(@PurDBName) > 0
			BEGIN
				EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
				
				SET @SSQL = 'INSERT INTO #RptRtrWiseSchUtilization ' +
					'(' + @TblFields + ')' +
					' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
					'WHERE (RCL.CtgLevelId = (CASE ' +  CAST(@CtgLevelId AS INTEGER) + ' WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
							RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',29,' + CAST(@Pi_UsrId as INTEGER) +')))
					
						AND (RC.CtgMainId = (CASE ' +  CAST(@CtgMainId AS INTEGER) + ' WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',30,' + CAST(@Pi_UsrId as INTEGER) +')))
						
						AND (RVC.RtrClassId = (CASE ' +  CAST(@RtrClassId AS INTEGER) + ' WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
							RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',31,' + CAST(@Pi_UsrId as INTEGER) +')))
						AND (SI.RtrId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))
						AND (SI.SMId = (CASE ' +  CAST(@SMId AS INTEGER) + ' WHEN 0 THEN SI.SMId ELSE 0 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',1,' + CAST(@Pi_UsrId as INTEGER) +')))
						AND (SI.RMId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN SI.RMId ELSE 0 END) OR
							SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',8,' + CAST(@Pi_UsrId as INTEGER) +')))
						AND (SI.CmpId = (CASE ' +  CAST(@CmpId AS INTEGER) + ' WHEN 0 THEN SI.CmpId ELSE 0 END) OR
							SI.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',4,' + CAST(@Pi_UsrId as INTEGER) +')))
						AND (SIP.PrdId = (CASE ' +  CAST(@PrdId AS INTEGER) + ' WHEN 0 THEN SIP.PrdId ELSE 0 END) OR
							SIP.PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',5,' + CAST(@Pi_UsrId as INTEGER) +')))
						AND (SM.SchId = (CASE ' +  CAST(@SchNo AS INTEGER) + ' WHEN 0 THEN SM.SchId ELSE 0 END) OR
							SM.SchId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',258,' + CAST(@Pi_UsrId as INTEGER) +')))
						AND (SI.SalInvDate Between ' + @FromDate +' and ' + @ToDate + ')
						AND (SI.SalId Between ' + @FromBillNo +' and ' + @TOBillNo +')'
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
						' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRtrWiseSchUtilization'
			
					EXEC (@SSQL)
					PRINT 'Saved Data Into SnapShot Table'
				   END
			   END
		end
		ELSE				--To Retrieve Data From Snap Data
		BEGIN
			EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
					@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			PRINT @ErrNo
			IF @ErrNo = 0
			   BEGIN
				SET @SSQL = 'INSERT INTO #RptRtrWiseSchUtilization ' +
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
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptRtrWiseSchUtilization
			-- Till Here
	
				UPDATE #RptRtrWiseSchUtilization SET BilledQty = B.BaseQty,PrdUnitMRP = B.PrdUnitMRP,PrdUnitSelRate = B.PrdUnitSelRate
				FROM #RptRtrWiseSchUtilization a,SalesInvoiceProduct B
				WHERE B.SalId = A.SalId AND B.PrdId = A.PrdId
				
				SELECT SalId,SalInvNo,SalInvDate,RtrId,RtrCode,RtrName,R.SchId,SchCode,
				R.SchDsc,PrdId,PrdDCode,PrdName,
				BilledQty,PrdUnitSelRate,PrdUnitMRP,
				BilledQty*PrdUnitSelRate AS Grossvalue,
				Sum(FreeQty) FreeQty,Sum(SchemeValue) SchemeValue,
				Sum(FlatAmount) AS FlatAmount,
				Sum(DiscountPerAmount) AS DiscountPerAmount,
				Sum(PrimarySchemeAmt) AS PrimarySchemeAmt,CmpSchCode AS CompSchCode,
				NetAmt,Liability,0 as Tax  ---Gopi at 19-10-2015
			    INTO #TmpFinOpShemem
				FROM #RptRtrWiseSchUtilization R INNER JOIN SchemeMaster S ON  R.SchId=S.SchId
				GROUP BY SalId,SalInvNo,SalInvDate,RtrId,RtrCode,RtrName,R.SchId,SchCode,R.SchDsc,PrdId,PrdDCode,PrdName,
				BilledQty,PrdUnitSelRate,PrdUnitMRP,CmpSchCode,NetAmt,Liability
				ORDER BY SalId
				
				SELECT DISTINCT D.SalId,D.SchId,D.PrdId,PrdBatDetailValue,
						E.FreePrdId,
						E.FreeQty FreeQty,
						E.FreeQty * PrdBatDetailValue FreeQtyValue INTO #TmpFre1111
						FROM  BatchCreation  A WITH (NOLOCK),ProductBatchDetails B WITH (NOLOCK),
							  ProductBatch C WITH (NOLOCK),
							  #TmpFinOpShemem D,SalesInvoiceSchemeDtFreePrd E WITH (NOLOCK)
						WHERE A.BatchSeqId = B.BatchSeqId AND A.SlNo = B.SLNo
						AND A.SlNo =4  AND A.ClmRte = 1 AND B.PrdBatId = C.PrdBatId AND D.FreeQty > 0
						AND D.SalId = E.SalId AND D.SchId = E.SchId	AND E.FreePrdId = C.PrdId
						AND E.FreePrdBatId = C.PrdBatId
						
				SELECT SalId,SchId,PrdId,Sum(FreeQty) FreeQty,
						Sum(FreeQtyValue) FreeQtyValue INTO #TmpFinFreeVal
						FROM #TmpFre1111
				GROUP BY SalId,SchId,PrdId
				
				UPDATE #TmpFinOpShemem SET Tax=B.PrdTaxAmount  ---Gopi at 19-10-2015
				FROM #TmpFinOpShemem a,SalesInvoiceProduct B
				WHERE B.SalId = A.SalId AND B.PrdId = A.PrdId
				
				UPDATE #TmpFinOpShemem  SET SchemeValue = SchemeValue + FreeQtyValue
								FROM #TmpFinOpShemem A,#TmpFinFreeVal  B
								WHERE A.SalId = B.SalId AND A.SchId = B.SchId 
								AND A.PrdId = B.PrdId   
								
				Update #TmpFinOpShemem set NetAmt=Grossvalue+Tax  ---Gopi at 19-10-2015
				Update #TmpFinOpShemem set Liability=(DiscountPerAmount/NetAmt)  ---Gopi at 19-10-2015
			
				SELECT SalId,SalInvNo,SalInvDate,RtrId,RtrCode,RtrName,SchId,SchCode,SchDsc,PrdId,PrdDCode,PrdName,
				BilledQty,PrdUnitSelRate,PrdUnitMRP,
				BilledQty*PrdUnitSelRate AS Grossvalue,
				Sum(FreeQty) FreeQty,Sum(SchemeValue) SchemeValue,
				Sum(FlatAmount) AS FlatAmount,
				Sum(DiscountPerAmount) AS DiscountPerAmount,
				Sum(PrimarySchemeAmt) AS PrimarySchemeAmt,CompSchCode,
				SUM(NetAmt) AS NetAmt,Liability ---Gopi at 19-10-2015
				FROM #TmpFinOpShemem 
				GROUP BY SalId,SalInvNo,SalInvDate,RtrId,RtrCode,RtrName,SchId,SchCode,SchDsc,PrdId,PrdDCode,PrdName,
				BilledQty,PrdUnitSelRate,PrdUnitMRP,CompSchCode,Liability
				ORDER BY SalId,SalInvNo
RETURN
END
GO
DELETE FROM RptExcelHeaders where RPTID=215
GO
INSERT INTO RptExcelHeaders
SELECT 215,1,'Salid','SalId',0,1
UNION
SELECT 215,2,'SalInvNo','Invoice No',1,1
UNION
SELECT 215,3,'SalInvDate','Invoice Date',1,1
UNION
SELECT 215,4,'RtrId','RtrId',0,1
UNION
SELECT 215,5,'RtrCode','Retailer Code',1,1
UNION
SELECT 215,6,'RtrName','Retailer Name',1,1
UNION
SELECT 215,7,'SchId','Schid',0,1
UNION
SELECT 215,8,'SchCode','Scheme Code',1,1
UNION
SELECT 215,9,'SchDsc','Scheme Description',1,1
UNION
SELECT 215,10,'PrdId','PrdId',0,1
UNION
SELECT 215,11,'PrdDCode','Product Code',1,1
UNION
SELECT 215,12,'PrdName','Product Name',1,1
UNION
SELECT 215,13,'BilledQty','BilledQty',1,1
UNION
SELECT 215,14,'PrdUnitSelRate','Selling Rate',1,1
UNION
SELECT 215,15,'PrdUnitMRP','MRP',1,1
UNION
SELECT 215,16,'Grossvalue','Grossvalue',1,1
UNION
SELECT 215,17,'FreeQty','FreeQty',1,1
UNION
SELECT 215,18,'SchemeValue','SchemeValue',1,1
UNION
SELECT 215,19,'FlatAmount','FlatAmount',1,1
UNION
SELECT 215,20,'DiscountPerAmount','DiscountPerAmount',1,1
UNION
SELECT 215,21,'PrimarySchemeAmt','PrimarySchemeAmt',1,1
UNION
SELECT 215,22,'CompSchCode','CompSchCode',1,1
UNION
SELECT 215,23,'NetAmt','Net Amount',1,1
UNION
SELECT 215,24,'Liability','% Liability',1,1
GO
--Praveenraj Changes
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id AND A.name='Cs2Cn_Prk_DailySales' AND B.NAME='LCTRAmount')
BEGIN
	ALTER TABLE Cs2Cn_Prk_DailySales ADD LCTRAmount NUMERIC(38,6) DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cs2Cn_DailySales')
DROP PROCEDURE Proc_Cs2Cn_DailySales
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_DailySales 0,'2014-09-26'
--UPDATE SALESINVOICE SET UPLOAD=0 WHERE SALID=25
SELECT * FROM Cs2Cn_Prk_DailySales (NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_DailySales]
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
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
21/10/2014 Jisha Mathew Included Undelivered bills New Column Added BillStatus,UploadedDate	
12/12/2015 PRAVEENRAJ BHASKARAN LCTRAmount ADDED FOR CCRSTPAR0118
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 			AS INT
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @DefCmpAlone	AS INT
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'Y'
	IF EXISTS (SELECT * FROM Cs2Cn_Prk_DailySales WHERE UploadFlag='N' AND Billstatus<=2)
	BEGIN
		DELETE FROM Cs2Cn_Prk_DailySales WHERE UploadFlag='N' AND Billstatus<=2
	END
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
		SalInvLvlDiscPer,
		BillStatus,
		UploadedDate,
		OrderRefNo,
		SFAOrderRefNo
	)
	SELECT 	@DistCode,A.SalInvNo,A.SalInvDate,A.SalDlvDate,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,
	A.OtherCharges,A.SalInvLvlDisc AS InvLevelDiscAmt,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,A.LcnId,L.LcnCode,
	B.SMCode,B.SMName,C.RMCode,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,
	ISNULL(E.VehicleRegNo,'') AS VehicleName,ISNULL(D.DlvBoyName,''),F.RMCode,F.RMName,H.PrdCCode,I.CmpBatCode,
	G.BaseQty AS SalInvQty ,G.PrdUom1EditedSelRate,G.PrdUom1EditedNetRate,G.SalManFreeQty AS SalInvFree ,
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount,
	'N' AS UploadFlag,0,A.SalInvLvlDiscPer,Dlvsts AS BillStatus,
	GETDATE(),ISNULL(O.OrderNo,''),ISNULL(O.DocRefNo,'')	
	FROM SalesInvoice A  (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID
	LEFT OUTER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId AND H.PrdId=I.PrdId
	INNER JOIN Location L (NOLOCK)	ON L.LcnId=A.LcnId
	LEFT OUTER JOIN OrderBooking O(NOLOCK) ON O.OrderNo=A.OrderKeyNo
	WHERE A.Upload=0 ORDER BY A.SalId
	
	--UPDATE A SET A.LCTRAmount=ISNULL(Z.LCTRAmt,0)
	--FROM Cs2Cn_Prk_DailySales A (NOLOCK)
	--INNER JOIN (
	--SELECT SalId,SalInvNo,PrdCCode,CmpBatCode,ISNULL(GrossAmt,0) AS GrossAmt,ISNULL(TaxAmount,0) AS TaxAmount,ISNULL(GrossAmt+TaxAmount,0) AS LCTRAmt 
	--FROM(
	--SELECT S.SALID,S.SALINVNO,P.PRDID,P.PRDCCODE,PB.CmpBatCode,SP.BASEQTY,SP.PrdUom1EditedSelRate,ISNULL((SP.BASEQTY*SP.PrdUom1EditedSelRate),0) AS GrossAmt,
	--ISNULL(Tax.TaxAmount,0) AS TaxAmount
	--FROM SalesInvoice S (NOLOCK)
	--INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.SALID
	--INNER JOIN (
	--SELECT SalId,PrdSlno,SUM(TaxAmount) TaxAmount FROM SalesInvoiceProductTax (NOLOCK)
	--GROUP BY SalId,PrdSlno
	--)Tax ON Tax.SalId=S.SalId AND SP.SalId=Tax.SalId AND SP.SlNo=Tax.PrdSlNo
	--INNER JOIN Product P (NOLOCK) ON P.PrdId=SP.PrdId
	--INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND PB.PrdBatId=SP.PrdBatId
	--) X
	--WHERE EXISTS (SELECT SalInvNo,PrdCode,PrdBatCde FROM Cs2Cn_Prk_DailySales Y WHERE 
	--X.SalInvNo=Y.SalInvNo AND X.PrdCCode=Y.PrdCode AND X.CmpBatCode=Y.PrdBatCde)
	--) Z ON Z.SalInvNo=A.SalInvNo AND Z.PrdCCode=A.PrdCode AND Z.CmpBatCode=A.PrdBatCde
	
	UPDATE A SET A.LCTRAmount=ISNULL(Z.LCTRAmt,0)
	FROM Cs2Cn_Prk_DailySales A (NOLOCK)
	INNER JOIN (
		SELECT A.SalId,A.SalInvNo,B.PrdId,P.PrdCCode,PB.CmpBatCode,C.TaxPerc,
		SUM(C.TaxableAmount) AS TaxableAmount,
		(SUM(B.BASEQTY)*B.PrdUom1EditedSelRate)+(SUM(B.BaseQty)*B.PrdUom1EditedSelRate)*(C.TaxPerc/100) AS LCTRAmt
		FROM SalesInvoice A (NOLOCK)
		INNER JOIN SalesInvoiceProduct B (NOLOCK) ON A.SALID=B.SALID
		INNER JOIN SalesInvoiceProductTax C (NOLOCK) ON A.SalId=C.SalId AND B.SalId=C.SalId AND B.SlNo=C.PrdSlNo
		INNER JOIN PRODUCT P (NOLOCK) ON B.PrdId=P.PrdId
		INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId AND PB.PrdId=B.PrdId AND PB.PrdBatId=B.PrdBatId
		INNER JOIN Cs2Cn_Prk_DailySales PRK (NOLOCK)
		ON PRK.SalInvNo=A.SalInvNo AND PRK.PrdCode=P.PrdCCode AND PRK.PrdBatCde=PB.CmpBatCode
		GROUP BY A.SalId,A.SalInvNo,B.PrdId,B.PrdUom1EditedSelRate,C.TaxPerc,P.PrdCCode,PB.CmpBatCode
		HAVING (SUM(C.TaxableAmount))>0
	) Z ON Z.SalInvNo=A.SalInvNo AND Z.PrdCCode=A.PrdCode AND Z.CmpBatCode=A.PrdBatCde
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where ProcId = 1
	UPDATE A SET SalInvLineCount=B.SalInvLineCount
	FROM Cs2Cn_Prk_DailySales A,(SELECT SI.SalInvNo,COUNT(SIP.PrdId) AS SalInvLineCount 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP WHERE 
	SI.UPload=0 AND SI.SalId=SIP.SalId
	GROUP BY SI.SalInvNo) B
	WHERE A.SalInvNo=B.SalInvNo
	--->Added By Nanda on 17/08/2010
	INSERT INTO Cs2Cn_Prk_SalesInvoiceOrders(DistCode,SalInvNo,OrderNo,OrderDate,UploadFlag)
	SELECT DISTINCT @DistCode,SI.SalInvNo,OB.OrderNo,OB.OrderDate,'N'
	FROM SalesInvoice SI,SalesinvoiceOrderBooking SIOB,OrderBooking OB
	WHERE SI.SalId=SIOB.SalId AND SIOB.OrderNo=OB.OrderNo AND SI.Upload=0 AND SI.DlvSts>3
	--->Till Here
	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'N') AND Dlvsts IN (3,4,5)
	UPDATE Cs2Cn_Prk_DailySales SET ServerDate=@ServerDate
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.ID WHERE A.NAME='Cs2Cn_Prk_SalesReturn' AND B.NAME='LCTRAmount')
BEGIN
	ALTER TABLE Cs2Cn_Prk_SalesReturn ADD LCTRAmount NUMERIC (38,6) DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cs2Cn_SalesReturn')
DROP PROCEDURE Proc_Cs2Cn_SalesReturn
GO
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_SalesReturn]  
(  
 @Po_ErrNo INT OUTPUT,
 @ServerDate DATETIME  
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
 
 UPDATE PRK SET PRK.LCTRAmount=ISNULL(LCTRAmt,0)
 FROM Cs2Cn_Prk_SalesReturn PRK (NOLOCK)
 INNER JOIN 
 (
	SELECT R.ReturnId,R.ReturnCode,P.PrdCCode,PB.CmpBatCode,
	(SUM(RP.BaseQty)*RP.PrdEditSelRte)+(SUM(RP.BaseQty)*RP.PrdEditSelRte)*(RPT.TaxPerc/100) AS LCTRAmt,
	SUM(RPT.TaxableAmt) AS TaxableAmt,RPT.TaxPerc  
	FROM ReturnHeader R (NOLOCK)
	INNER JOIN ReturnProduct RP (NOLOCK) ON R.RETURNID=RP.RETURNID
	INNER JOIN ReturnProductTax RPT (NOLOCK) ON R.RETURNID=RPT.RETURNID AND RP.RETURNID=RPT.RETURNID AND RP.SlNO=RPT.PrdSlNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=RP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId AND PB.PrdId=RP.PrdId AND RP.PrdBatId=PB.PrdBatId
	INNER JOIN Cs2Cn_Prk_SalesReturn Prk (NOLOCK) ON Prk.PrdCode=P.PrdCCode AND Prk.PrdBatCde=PB.CmpBatCode
	GROUP BY R.ReturnId,R.ReturnCode,P.PrdCCode,PB.CmpBatCode,RPT.TaxPerc,RP.PrdEditSelRte
	HAVING (SUM(RPT.TaxableAmt))>0
 ) Z ON Z.ReturnCode=PRK.SRNRefNo AND Z.PrdCCode=PRK.PrdCode AND Z.CmpBatCode=PRK.PrdBatCde
  
 UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),  
 ProcDate = CONVERT(nVarChar(10),GetDate(),121)  
 Where ProcId = 4  
 UPDATE ReturnHeader SET Upload=1 WHERE Upload=0 AND ReturnCode IN (SELECT DISTINCT  
 SRNRefNo FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'N') AND Status=0   
 UPDATE Cs2Cn_Prk_SalesReturn SET ServerDate=@ServerDate
END
GO
IF NOT EXISTS(SELECT PrfCode FROM ProfileHd WHERE PrfCode='PURADMIN')
BEGIN
	DECLARE @CurrValue as INT
	SELECT @CurrValue =MAX(PrfId)+1 from ProfileHd
	INSERT INTO ProfileHd(PrfId,PrfCode,PrfName,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT @CurrValue,'PURADMIN','PURADMIN',1,1,GETDATE(),1,GETDATE()
	UPDATE Counters SET CurrValue=@CurrValue WHERE TabName='ProfileHd'
END
GO
IF NOT EXISTS(SELECT * FROM USERS WHERE UserName='PURADMIN')
BEGIN
	Declare @CurrVal as INT 
	SELECT @CurrVal =MAX(UserId)+1 from Users
	INSERT INTO Users (UserId,UserName,UserPassword,LoggedStatus,BgColor,TxtColor,HltColor,HltTxtColor,PrfId,Color,Availability,LastModBy,LastModDate,Authid,AuthDate,HostName) 
	SELECT @CurrVal,'PURADMIN','œÞÙ¨ØÅdÖß¾¼·­´±Â',2,'&H8000000F','&H80000012','&HFF0000','&HFFFFFF',PrfId,'DefaultGreen',1,1,GETDATE(),1,GETDATE(),'' FROM  ProfileHd WHERE PrfCode='PURADMIN'
	Update Counters Set CurrValue=@CurrVal where TabName='Users'	
END
GO
DELETE FROM ProfileDT WHERE PrfId IN(SELECT PrfId FROM ProfileHd WHERE PrfCode='PURADMIN')
INSERT INTO ProfileDT(PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,
LastModBy,LastModDate,AuthId,AuthDate)
SELECT (SELECT PrfId FROM ProfileHd WHERE PrfCode='PURADMIN'),MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,
LastModBy,LastModDate,AuthId,AuthDate FROM ProfileDT WHERE PrfId=(SELECT PrfId FROM Users WHERE Username='USER')
GO
DELETE FROM FieldLevelAccessDt WHERE PrfId IN (SELECT PrfId FROM ProfileHd WHERE PrfCode='PURADMIN')
INSERT INTO FieldLevelAccessDt(PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT (SELECT PrfId FROM ProfileHd WHERE PrfCode='PURADMIN'),TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate
FROM FieldLevelAccessDt WHERE PrfId=(SELECT PrfId FROM Users WHERE Username='USER')
GO
DELETE FROM FIELDLEVELACCESSDT WHERE TRANSID=5 AND CTRLID=100015
INSERT INTO FIELDLEVELACCESSDT(PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT PrfId,5,100015,0,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode='ADMIN'
UNION
SELECT PrfId,5,100015,0,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode='USER'
UNION
SELECT PrfId,5,100015,1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode='PURADMIN'
GO
DELETE FROM CustomCaptions WHERE TransId=5 AND CTRLID=100015 AND SubCtrlId=2
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 5,100015,2,'FpData-5-2','Product Code','','',1,1,1,GETDATE(),1,GETDATE(),'Product Code','','',1,1
GO
DELETE FROM FIELDLEVELACCESSDT WHERE TRANSID=5 AND CTRLID=100003
INSERT INTO FIELDLEVELACCESSDT(PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT PrfId,5,100003,0,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode='ADMIN'
UNION
SELECT PrfId,5,100003,0,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode='USER'
UNION
SELECT PrfId,5,100003,1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode='PURADMIN'
GO
DELETE FROM CustomCaptions WHERE TransId=5 AND CTRLID=100003 AND SubCtrlId=1
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 5,100003,1,'fxtPurOrderRefNo','Purchase Receipt Order No','','',1,1,1,GETDATE(),1,GETDATE(),'Purchase Receipt Order No','','',1,1
GO
DELETE FROM CUSTOMCAPTIONS WHERE TRANSID=48 AND CTRLID=4000
INSERT INTO CUSTOMCAPTIONS(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 48,4000,1,'DgCommonKit-48-4000-1','Product Code','','',1,1,1,GETDATE(),1,GETDATE(),'Product Code','','',1,1 UNION
SELECT 48,4000,2,'DgCommonKit-48-4000-2','Product Name','','',1,1,1,GETDATE(),1,GETDATE(),'Product Name','','',1,1 UNION
SELECT 48,4000,3,'DgCommonKit-48-4000-3','Kit Actual Qty','','',1,1,1,GETDATE(),1,GETDATE(),'Kit Actual Qty','','',1,1 UNION
SELECT 48,4000,4,'DgCommonKit-48-4000-4','Kit Base Qty','','',1,1,1,GETDATE(),1,GETDATE(),'Kit Base Qty','','',1,1 UNION
SELECT 48,4000,5,'DgCommonKit-48-4000-5','Slab','','',1,1,1,GETDATE(),1,GETDATE(),'Slab','','',1,1 UNION
SELECT 48,4000,6,'DgCommonKit-48-4000-6','Condition','','',1,1,1,GETDATE(),1,GETDATE(),'Condition','','',1,1 UNION
SELECT 48,4000,7,'DgCommonKit-48-4000-7','Kit Qty','','',1,1,1,GETDATE(),1,GETDATE(),'Kit Qty','','',1,1 UNION
SELECT 48,4000,8,'DgCommonKit-48-4000-8','Select','','',1,1,1,GETDATE(),1,GETDATE(),'Select','','',1,1 UNION
SELECT 48,4000,9,'DgCommonKit-48-4000-9','Kit Batch Code','','',1,1,1,GETDATE(),1,GETDATE(),'Kit Batch Code','','',1,1 UNION
SELECT 48,4000,10,'DgCommonKit-48-4000-10','Available Qty','','',1,1,1,GETDATE(),1,GETDATE(),'Available Qty','','',1,1
GO
DELETE FROM CUSTOMCAPTIONS WHERE TRANSID=48 AND CTRLID=3000 AND SubCtrlId IN (13,14,15,16,17,18,19,20,21,22,23)
INSERT INTO CUSTOMCAPTIONS(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 48,3000,13,'PnlMsg-48-3000-13','','Product Code','',1,1,1,GETDATE(),1,GETDATE(),'','Product Code','',1,1 UNION
SELECT 48,3000,14,'PnlMsg-48-3000-14','','Product Name','',1,1,1,GETDATE(),1,GETDATE(),'','Product Name','',1,1 UNION
SELECT 48,3000,15,'PnlMsg-48-3000-15','','Kit Actual Qty','',1,1,1,GETDATE(),1,GETDATE(),'','Kit Actual Qty','',1,1 UNION
SELECT 48,3000,16,'PnlMsg-48-3000-16','','Kit Base Qty','',1,1,1,GETDATE(),1,GETDATE(),'','Kit Base Qty','',1,1 UNION
SELECT 48,3000,17,'PnlMsg-48-3000-17','','Slab','',1,1,1,GETDATE(),1,GETDATE(),'','Slab','',1,1 UNION
SELECT 48,3000,18,'PnlMsg-48-3000-18','','Condition','',1,1,1,GETDATE(),1,GETDATE(),'','Condition','',1,1 UNION
SELECT 48,3000,19,'PnlMsg-48-3000-19','','Kit Quantity','',1,1,1,GETDATE(),1,GETDATE(),'','Kit Quantity','',1,1 UNION
SELECT 48,3000,20,'PnlMsg-48-3000-20','','Select','',1,1,1,GETDATE(),1,GETDATE(),'','Select','',1,1 UNION
SELECT 48,3000,21,'PnlMsg-48-3000-21','','Kit Batch Code','',1,1,1,GETDATE(),1,GETDATE(),'','Kit Batch Code','',1,1 UNION
SELECT 48,3000,22,'PnlMsg-48-3000-22','','Available Qty','',1,1,1,GETDATE(),1,GETDATE(),'','Available Qty','',1,1 UNION
SELECT 48,3000,23,'PnlMsg-48-3000-23','','Select any one of "Or" Condition Product, For Slab No -- ','',1,1,1,GETDATE(),1,GETDATE(),'','Available Qty','',1,1
GO
DELETE FROM CUSTOMCAPTIONS WHERE TransId=2 AND CTRLID=1000 AND SUBCTRLID=276
INSERT INTO CUSTOMCAPTIONS (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 2,1000,276,'MsgBox-2-1000-276','','','Please Select Kit Item To Proceed For Product -- ',1,1,1,GETDATE(),1,GETDATE(),'','','Please Select Kit Item To Proceed For Product ',1,1
GO
DELETE FROM CUSTOMCAPTIONS WHERE TransId=2 AND CTRLID=1000 AND SUBCTRLID=8
INSERT INTO CUSTOMCAPTIONS (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,
DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 2,1000,8,'PnlMsg-2-1000-8','','Enter the Product Code or Press F4/DblClick to Select the Product,Click Ctrl+P to Select Kit Item(s)','',1,1,1,GETDATE(),1,GETDATE(),'','Enter the Product Code or Press F4/DblClick to Select the Product,Click Ctrl+P to Select Kit Item(s)','',1,1
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='FN_RETURNKITPRODUTS_FORBILLING')
DROP FUNCTION FN_RETURNKITPRODUTS_FORBILLING
GO
--SELECT * FROM FN_RETURNKITPRODUTS_FORBILLING(3583,2,29351,2)
CREATE FUNCTION [dbo].[FN_RETURNKITPRODUTS_FORBILLING](@KITPRDID INT,@TRANSQTY BIGINT,@SALID INT,@IMODE TINYINT)
RETURNS @KITPRODUCT TABLE
(
	KITPRDID	INT,
	KitPrdCode	VARCHAR(50),
	KitPrdName	VARCHAR(100),
	PRDID		INT,
	PrdCCode	VARCHAR(50),
	PrdName		VARCHAR(100),
	PrdBatId	BIGINT,
	BatchCode	VARCHAR(100),
	Qty			BIGINT,
	SlabId		INT,
	Mandatory	INT,
	Slab		VARCHAR(50),
	Condition	VARCHAR(50),
	RequiredQty	BIGINT,
	Stock		BIGINT,
	BaseQty		BIGINT
)
AS
/*********************************
* FUNCTION: FN_RETURNKITPRODUTS_FORBILLING
* PURPOSE: Returns the Billed Kit Items Details
* NOTES: 
* CREATED: PRAVEENRAJ BHASKARAN	12/12/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
	IF @IMODE=1
	BEGIN
		INSERT INTO @KITPRODUCT(KITPRDID,KitPrdCode,KitPrdName,PRDID,PrdCCode,PrdName,PrdBatId,BatchCode,Qty,SlabId,Mandatory,Slab,Condition,RequiredQty,Stock,BaseQty)
		SELECT DISTINCT A.KITPRDID,P1.PrdCCode,P1.PrdName,A.PRDID,P.PrdCCode,P.PrdName,0 AS PrdBatId,'' AS BatchCode,A.Qty,A.SlabId,A.Mandatory,'Slab -- '+CAST(A.SLABID AS VARCHAR(5)) AS Slab,
		CASE A.Mandatory WHEN 1 THEN 'And' ELSE 'Or' END AS Condition,@TRANSQTY*A.Qty AS RequiredQty,ISNULL(D.STOCK,0),0
		FROM KitProduct A (NOLOCK)
		INNER JOIN PRODUCT P (NOLOCK) ON A.PrdId=P.PrdId
		INNER JOIN PRODUCT P1 (NOLOCK) ON A.KitPrdId=P1.PrdId
		INNER JOIN  (
		SELECT PRDID,LCNID,SUM(STOCK) AS STOCK FROM (
			SELECT A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode,SUM(PrdBatLcnSih-PrdBatLcnRessih) AS STOCK FROM PRODUCTBATCHLOCATION A
			INNER JOIN PRODUCTBATCH B ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId
			INNER JOIN KITPRODUCTBATCH KBP ON A.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN A.PrdBatID ELSE KBP.PrdBatID END  
			AND B.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN B.PrdBatID ELSE KBP.PrdBatID END
			AND A.PRDID=KBP.PRDID AND B.PRDID=KBP.PRDID
			WHERE KBP.KitPrdId=@KITPRDID
			GROUP BY A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>0)X GROUP BY PRDID,LCNID
			
		) D ON D.PrdId=A.PrdId AND A.PrdId=P.PrdId
		WHERE A.KITPRDID=@KITPRDID ORDER BY A.SlabId,A.Mandatory
	END
	ELSE
	BEGIN
		
		INSERT INTO @KITPRODUCT(KITPRDID,KitPrdCode,KitPrdName,PRDID,PrdCCode,PrdName,PrdBatId,BatchCode,Qty,SlabId,Mandatory,Slab,Condition,RequiredQty,Stock,BaseQty)
		SELECT DISTINCT A.KITPRDID,P1.PrdCCode,P1.PrdName,A.PRDID,P.PrdCCode,P.PrdName,0 AS PrdBatId,'' AS BatchCode,A.Qty,A.SlabId,A.Mandatory,'Slab -- '+CAST(A.SLABID AS VARCHAR(5)) AS Slab,
		CASE A.Mandatory WHEN 1 THEN 'And' ELSE 'Or' END AS Condition,@TRANSQTY*A.Qty AS RequiredQty,ISNULL(D.STOCK,0)+ISNULL(SK.BaseQty,0),ISNULL(SK.BaseQty,0)
		FROM KitProduct A (NOLOCK)
		INNER JOIN PRODUCT P (NOLOCK) ON A.PrdId=P.PrdId
		INNER JOIN PRODUCT P1 (NOLOCK) ON A.KitPrdId=P1.PrdId
		LEFT OUTER JOIN  (
		SELECT PRDID,LCNID,SUM(STOCK) AS STOCK FROM (
			SELECT A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode,SUM(PrdBatLcnSih-PrdBatLcnRessih) AS STOCK FROM PRODUCTBATCHLOCATION A
			INNER JOIN PRODUCTBATCH B ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId
			INNER JOIN KITPRODUCTBATCH KBP ON A.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN A.PrdBatID ELSE KBP.PrdBatID END  
			AND B.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN B.PrdBatID ELSE KBP.PrdBatID END
			AND A.PRDID=KBP.PRDID AND B.PRDID=KBP.PRDID
			WHERE KBP.KitPrdId=@KITPRDID
			GROUP BY A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>0)X GROUP BY PRDID,LCNID
			
		) D ON D.PrdId=A.PrdId AND A.PrdId=P.PrdId
		LEFT OUTER JOIN SalesInvoiceKitItemDt SK ON A.PrdId=SK.PrdId AND A.KitPrdId=SK.KitPrdId AND SK.SALID=@SALID AND A.SlabId=SK.SlabId
		WHERE A.KITPRDID=@KITPRDID ORDER BY A.SlabId,A.Mandatory
		
		
		
		--INSERT INTO @KITPRODUCT(KITPRDID,KitPrdCode,KitPrdName,PRDID,PrdCCode,PrdName,PrdBatId,BatchCode,Qty,SlabId,Mandatory,Slab,Condition,RequiredQty,Stock,BaseQty)
		--SELECT DISTINCT A.KITPRDID,P1.PrdCCode,P1.PrdName,A.PRDID,P.PrdCCode,P.PrdName,0 AS PrdBatId,'' AS BatchCode,A.Qty,A.SlabId,
		--CASE A.Mandatory WHEN 1 THEN 1 ELSE (CASE ISNULL(SK.Condition,2) WHEN 2 THEN 2 ELSE 3 END) END AS Mandatory,
		----A.Mandatory,
		--'Slab -- '+CAST(A.SLABID AS VARCHAR(5)) AS Slab,
		--CASE A.Mandatory WHEN 1 THEN 'And' ELSE 'Or' END AS Condition,@TRANSQTY*A.Qty AS RequiredQty,		
		--ISNULL(D.STOCK,0),ISNULL(SK.BaseQty,0)
		--FROM KitProduct A (NOLOCK)
		--INNER JOIN PRODUCT P (NOLOCK) ON A.PrdId=P.PrdId
		--INNER JOIN PRODUCT P1 (NOLOCK) ON A.KitPrdId=P1.PrdId
		--INNER JOIN  (
		--	SELECT PRDID,LCNID,SUM(STOCK) AS STOCK FROM (
		--	SELECT A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode,SUM(PrdBatLcnSih-PrdBatLcnRessih) AS STOCK FROM PRODUCTBATCHLOCATION A
		--	INNER JOIN PRODUCTBATCH B ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId
		--	INNER JOIN KITPRODUCTBATCH KBP ON A.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN A.PrdBatID ELSE KBP.PrdBatID END  
		--	AND B.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN B.PrdBatID ELSE KBP.PrdBatID END
		--	AND A.PRDID=KBP.PRDID AND B.PRDID=KBP.PRDID
		--	WHERE KBP.KitPrdId=@KITPRDID
		--	GROUP BY A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>0)X GROUP BY PRDID,LCNID
			
		--) D ON D.PrdId=A.PrdId AND A.PrdId=P.PrdId
		--LEFT OUTER JOIN SalesInvoiceKitItemDt SK ON A.PrdId=SK.PrdId AND A.KitPrdId=SK.KitPrdId AND SK.SALID=@SALID AND A.SlabId=SK.SlabId
		--WHERE A.KITPRDID=@KITPRDID ORDER BY A.SlabId--,A.Mandatory
	END
	--SELECT K.KitPrdid,P1.PrdCCode AS [Kit PrdCode],P1.PRDNAME AS [Kit PrdName],K.PrdId,P.PrdCCode,P.PrdName,
	--ISNULL(PBP.PrdBatId,0) PrdBatId,ISNULL(PBP.CmpBatCode,'ALL') as CmpBatCode,
	--K.Qty,K.SlabId,K.Mandatory,'Slab -- '+CAST(K.SLABID AS VARCHAR(5)) AS Slab,
	--CASE K.Mandatory WHEN 1 THEN 'And' ELSE 'Or' END AS Condition,@TRANSQTY*K.Qty AS RequiredQty,
	--ISNULL(PBP.STOCK,0) AS STOCK 
	--FROM KITPRODUCT K 
	--INNER JOIN KITPRODUCTBATCH KP ON K.KITPRDID=KP.KITPRDID AND K.PrdId=KP.PrdId
	--LEFT OUTER JOIN (
	--	SELECT A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode,SUM(PrdBatLcnSih-PrdBatLcnRessih) AS STOCK FROM PRODUCTBATCHLOCATION A
	--	INNER JOIN PRODUCTBATCH B ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId
	--	GROUP BY A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>0
	--	) PBP ON KP.PrdId=PBP.PrdId AND PBP.PrdBatID=CASE KP.PrdBatID WHEN 0 THEN PBP.PrdBatID ELSE KP.PrdBatID END AND K.PRDID=PBP.PrdId
	--INNER JOIN PRODUCT P ON P.PRDID=K.PRDID AND P.PrdId=KP.PrdId
	--INNER JOIN PRODUCT P1 ON P1.PRDID=K.KitPrdid AND P1.PrdId=KP.KitPrdid	
	--WHERE K.KitPrdid=@KITPRDID
	RETURN
END
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='BilledKitItemDt')
BEGIN
	CREATE TABLE BilledKitItemDt
	(
		SalId		BIGINT,
		RtrId		INT,
		KitPrdId	INT,
		PrdId		INT,
		KitQty		INT,
		BaseQty		INT,
		SlabId		INT,
		Condition	INT,
		[Select]	INT,
		TransId		INT,
		UsrId		INT
	)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnKitValidation')
DROP FUNCTION Fn_ReturnKitValidation
GO
--SELECT DBO.Fn_ReturnKitValidation(810,0,953,1) AS Kit 
CREATE FUNCTION Fn_ReturnKitValidation(@RtrId INT,@SalId INT,@PrdId INT,@UsrId INT)
RETURNS TINYINT
AS
/*********************************
* FUNCTION: FN_RETURNKITPRODUTS_FORBILLING
* PURPOSE: Returns the Billed Kit Items Validations
* NOTES: 
* CREATED: PRAVEENRAJ BHASKARAN	12/12/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
	DECLARE @EXISTS TINYINT
	SET @EXISTS=0
	IF EXISTS (SELECT * FROM BILLEDKITITEMDT WHERE RtrId=@RtrId AND KitPrdId=@PrdId AND [Select]=1 AND UsrId=@UsrId)
	BEGIN
		SET @EXISTS=1
	END
	ELSE
	BEGIN
		SET @EXISTS=0
	END
RETURN @EXISTS
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='Temp_BilledKitItemDt')
DROP TABLE Temp_BilledKitItemDt
GO
CREATE TABLE Temp_BilledKitItemDt
(
	KitPrdId	INT,
	PrdId		BIGINT,
	SlabId		INT,
	Mandatory	INT,
	KitQty		INT,
	KitActualQty INT,
	BaseQty		INT,
	Selection	INT,
	UsrId		INT,
	TransId		INT
)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnBilledKitItemDt_Validation')
DROP FUNCTION Fn_ReturnBilledKitItemDt_Validation
GO
--SELECT * FROM Fn_ReturnBilledKitItemDt_Validation(2,2)
CREATE FUNCTION Fn_ReturnBilledKitItemDt_Validation(@UsrId INT,@TransId INT)
RETURNS @KitQty TABLE
(
	ValExists	TINYINT,
	Msg			VARCHAR(1000)
)
AS
BEGIN
		IF EXISTS (SELECT SlabId,KitQty,KitActualQty,Mandatory,SUM(BaseQty) AS BaseQty FROM Temp_BilledKitItemDt
			WHERE MANDATORY=0 AND UsrId=@UsrId AND TransId=@TransId
			GROUP BY SlabId,KitQty,KitActualQty,Mandatory
			HAVING SUM(BaseQty)<>KitActualQty)
		BEGIN
			INSERT INTO @KitQty (ValExists,Msg)
			SELECT 1,'Kit Quantity is Not Matched With Base Quantity For Slab Id '+ CAST (SlabId AS VARCHAR(5))
			FROM (
			SELECT SlabId,KitQty,KitActualQty,Mandatory,SUM(BaseQty) AS BaseQty FROM Temp_BilledKitItemDt
			WHERE MANDATORY=0 AND UsrId=@UsrId AND TransId=@TransId
			GROUP BY SlabId,KitQty,KitActualQty,Mandatory
			HAVING SUM(BaseQty)<>KitActualQty ) X
		END
		ELSE
		BEGIN
			INSERT INTO @KitQty (ValExists,Msg)
			SELECT 0,''
		END
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnKitItemMandatory')
DROP FUNCTION Fn_ReturnKitItemMandatory
GO
--SELECT * FROM Fn_ReturnKitItemMandatory(2706,2)
CREATE FUNCTION [dbo].[Fn_ReturnKitItemMandatory] (@PI_PRDID INT,@Pi_TranQty INT)
RETURNS @KITPRDUCT_DT TABLE
(
	PrdId		INT,
	PrdBatId	INT,
	Qty			INT,
	MANDATORY	INT,
	SLABID		INT,
	TRANQTY		INT,
	STOCKQTY	INT
)
AS
/*********************************
* PROCEDURE	: Fn_ReturnKitItemMandatory
* PURPOSE	: To Return Kit Products based on Mandatory,Non Mandatory
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 15/07/2015
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {Date} {Developer}  {Brief modification description}
*********************************/
BEGIN
	--Commented By PRAVEENRAJ BHASKARAN FOR NEW CR -- CCRSTPAR0123
	--DECLARE @KITPRDUCT_MANDATORY TABLE
	--(
	--	PrdId		INT,
	--	PrdBatId	INT,
	--	Qty			INT,
	--	MANDATORY	INT,
	--	SLABID		INT
	--)
	--DECLARE @SLABDETAILS TABLE 
	--(
	--	SLNO INT IDENTITY(1,1),
	--	SLABID INT
	--)
	--DECLARE @KITPRDUCT_NONMANDATORY TABLE
	--(
	--	PrdId		INT,
	--	PrdBatId	INT,
	--	Qty			INT,
	--	MANDATORY	INT,
	--	SlabId		INT
	--)
	
	--DECLARE @CNTSLABDT INT
	--DECLARE @SLABID INT
	--DECLARE @SLNO INT
	--DECLARE @PrdId INT
	--DECLARE @PrdBatId INT
	--DECLARE @Qty INT
	
	--INSERT INTO @KITPRDUCT_MANDATORY
	--SELECT KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY,KP.SLABID
	--FROM KitProduct KP (NOLOCK)
	--INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	--WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=1
	
	--INSERT INTO @KITPRDUCT_NONMANDATORY(PrdId,PrdBatId,Qty,MANDATORY,SlabId)
	--SELECT KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY,KP.SLABID
	--FROM KitProduct KP (NOLOCK)
	--INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	--WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=0
	
	--INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
	--SELECT PrdId,PrdBatId,Qty,MANDATORY,SLABID,@Pi_TranQty,@Pi_TranQty*QTY FROM @KITPRDUCT_MANDATORY	
	
	--INSERT INTO @SLABDETAILS(SLABID)
	--SELECT DISTINCT SLABID FROM @KITPRDUCT_NONMANDATORY
	
	--SET @SLNO=1
	--SELECT @CNTSLABDT=COUNT(DISTINCT SLABID) FROM @KITPRDUCT_NONMANDATORY
	
	--WHILE @CNTSLABDT>=@SLNO
	--BEGIN
	--		SELECT @SLABID=SLABID FROM @SLABDETAILS WHERE SLNO=@SLNO	
	--		DECLARE CUR_KIT CURSOR FOR SELECT PrdId,PrdBatId,Qty FROM @KITPRDUCT_NONMANDATORY WHERE SLABID=@SLABID
	--		OPEN CUR_KIT
	--		FETCH NEXT FROM CUR_KIT INTO @PrdId,@PrdBatId,@Qty
	--		WHILE @@FETCH_STATUS=0
	--		BEGIN
	--			IF NOT EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0 AND SlabId=@SLABID)
	--			BEGIN
	--				IF @PrdBatId=0
	--				BEGIN
	--					INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
	--					SELECT TOP 1 K.PrdId,K.PrdBatId,K.Qty,K.MANDATORY,K.SlabId,@Pi_TranQty,@Pi_TranQty*QTY FROM TEMP_KitProductBatch_Mandatory T
	--					INNER JOIN @KITPRDUCT_NONMANDATORY K ON K.PRDID=T.PRDID  WHERE K.PrdId=@PRDID AND K.SlabId=@SLABID AND T.Stock>=(@Qty*@Pi_TranQty)
	--				END
	--				ELSE
	--				BEGIN
	--					INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
	--					SELECT TOP 1 K.PrdId,K.PrdBatId,K.Qty,K.MANDATORY,K.SlabId,@Pi_TranQty,@Pi_TranQty*QTY FROM TEMP_KitProductBatch_Mandatory T
	--					INNER JOIN @KITPRDUCT_NONMANDATORY K ON K.PRDID=T.PRDID AND K.PrdBatId=T.PRDBATID  
	--					WHERE K.PrdId=@PRDID AND K.PRDBATID=@PrdBatId AND K.SlabId=@SLABID AND T.Stock>=(@Qty*@Pi_TranQty)
	--				END
	--			END
	--			--IF EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0)
	--			--BEGIN
	--			--	CLOSE CUR_KIT
	--			--	DEALLOCATE CUR_KIT
	--			--	RETURN
	--			--END
	--		FETCH NEXT FROM CUR_KIT INTO @PrdId,@PrdBatId,@Qty
	--		END
	--		CLOSE CUR_KIT
	--		DEALLOCATE CUR_KIT
			
	--		IF EXISTS (SELECT * FROM KITPRODUCT (NOLOCK) WHERE MANDATORY=0 AND KitPrdid=@PI_PRDID AND SLABID=@SLABID)
	--		BEGIN
	--			IF NOT EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0 AND SLABID=@SLABID)
	--			BEGIN
	--				INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
	--				SELECT TOP 1 KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY,KP.SLABID,@PI_TRANQTY,@Pi_TranQty*QTY
	--				FROM KitProduct KP (NOLOCK)
	--				INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	--				WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=0 AND KP.SLABID=@SLABID
	--			END
	--		END
	--		--IF EXISTS (SELECT * FROM KITPRODUCT (NOLOCK) WHERE MANDATORY=0 AND KitPrdid=@PI_PRDID)
	--		--BEGIN
	--		--	IF NOT EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0)
	--		--	BEGIN
	--		--		INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY)
	--		--		SELECT TOP 1 KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY
	--		--		FROM KitProduct KP (NOLOCK)
	--		--		INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	--		--		WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=0
	--		--	END
	--		--END	
	--	SET @SLNO=@SLNO+1
	--END
	--END HERE

	--INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
	--SELECT KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY,KP.SLABID,@PI_TRANQTY,@Pi_TranQty*QTY
	--FROM KitProduct KP (NOLOCK)
	--INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	--INNER JOIN BilledKitItemDt BT (NOLOCK) ON BT.KitPrdId=KP.KitPrdId AND KPB.KitPrdId=BT.KitPrdId AND KP.PrdId=BT.PrdId AND BT.PrdId=KPB.PrdId
	--WHERE KP.KitPrdId=@PI_PRDID AND BT.[SELECT]=1
	
	INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
	SELECT KP.PrdId,KPB.PrdBatId,BT.BaseQty,--KP.Qty
	KP.MANDATORY,KP.SLABID,@PI_TRANQTY,@Pi_TranQty*QTY
	FROM KitProduct KP (NOLOCK)
	INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	INNER JOIN BilledKitItemDt BT (NOLOCK) ON BT.KitPrdId=KP.KitPrdId AND KPB.KitPrdId=BT.KitPrdId AND KP.PrdId=BT.PrdId AND BT.PrdId=KPB.PrdId
	AND BT.SlabId=KP.SlabId
	WHERE KP.KitPrdId=@PI_PRDID AND BT.[SELECT]=1 AND BT.BaseQty>0
	
RETURN
END
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='SalesInvoiceKitItemDt')
BEGIN
	CREATE TABLE SalesInvoiceKitItemDt
	(
		SalId			BIGINT,
		RtrId			INT,
		KitPrdId		INT,
		PrdId			INT,
		KitQty			INT,
		BaseQty			INT,
		SlabId			INT,
		Condition		INT,
		Availability	DATETIME,
		LastModBy		INT,
		LastModDate		DATETIME,
		AuthId			INT,
		AuthDate		DATETIME,
		CONSTRAINT FK_SalesInvoiceKitItemDt_SalId FOREIGN KEY (SalId) REFERENCES SalesInvoice(SalId),
		CONSTRAINT FK_SalesInvoiceKitItemDt_RtrId FOREIGN KEY (RtrId) REFERENCES Retailer(RtrId)
	)
END
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SalesInvoiceKitItemDt_SalId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SalesInvoiceKitItemDt]'))
BEGIN
	ALTER TABLE [dbo].[SalesInvoiceKitItemDt] CHECK CONSTRAINT [FK_SalesInvoiceKitItemDt_SalId]
END
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SalesInvoiceKitItemDt_RtrId]') AND parent_object_id = OBJECT_ID(N'[dbo].[SalesInvoiceKitItemDt]'))
BEGIN
	ALTER TABLE [dbo].[SalesInvoiceKitItemDt] CHECK CONSTRAINT [FK_SalesInvoiceKitItemDt_RtrId]
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='FN_RETURNSALESINVOICEKITITEM')
DROP FUNCTION FN_RETURNSALESINVOICEKITITEM
GO
--SELECT * FROM FN_RETURNSALESINVOICEKITITEM(29360,767,1,2,2,3583)
CREATE FUNCTION FN_RETURNSALESINVOICEKITITEM(@SALID BIGINT,@RTRID INT,@USRID INT, @TRANSID INT,@TRANSQTY INT,@KITPRDID INT)
RETURNS @SALESINVOICEKITITEMDT TABLE
(
		SalId			BIGINT,
		RtrId			INT,
		KitPrdId		INT,
		PrdId			INT,
		KitQty			INT,
		BaseQty			INT,
		SlabId			INT,
		Condition		INT,
		[Select]		INT,
		TransId			INT,
		UsrId			INT
)
AS
/*********************************
* PROCEDURE	: FN_RETURNSALESINVOICEKITITEM
* PURPOSE	: To Return Kit Products based on Mandatory,Non Mandatory
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 12/12/2015
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {Date} {Developer}  {Brief modification description}
*********************************/
BEGIN
	INSERT INTO @SALESINVOICEKITITEMDT(SalId,RtrId,KitPrdId,PrdId,KitQty,BaseQty,SlabId,Condition,[SELECT],TransId,UsrId)
	SELECT SalId,RtrId,KitPrdId,PrdId,KitQty,@TRANSQTY*KitQty,SlabId,Condition,1 AS [Select],@TRANSID,@USRID
	FROM SALESINVOICEKITITEMDT (NOLOCK) WHERE SALID=@SALID AND RTRID=@RTRID AND KitPrdId=@KITPRDID
RETURN
END
GO
DELETE FROM CustomUpDownload WHERE UpDownload='Download' AND SlNo=247
INSERT INTO CustomUpDownload(SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
SELECT 247,1,'KitProductCategory','KitProductCategory','','Proc_Import_KitProductCategory','Cn2Cs_Prk_KitItemRetailerCategory','Proc_ValiDate_KitProductCategory',
'Master','Download',1
GO
DELETE FROM Tbl_DownloadIntegration WHERE SequenceNo=55
INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
SELECT 55,'KitProductCategory','Cn2Cs_Prk_KitItemRetailerCategory','Proc_Import_KitProductCategory',0,500,GETDATE()
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='KitProductCategory')
BEGIN
	CREATE TABLE KitProductCategory
	(
		KitPrdId		INT,
		CtgMainId		INT,
		Availability	INT,
		LastModBy		INT,
		LastModDate		DATETIME,
		AuthId			INT,
		AuthDate		DATETIME,
		CONSTRAINT PK_KitProductCategory_KitPrdId_CtgMainId PRIMARY KEY (KitPrdId,CtgMainId),
		CONSTRAINT FK_KitProductCategory_KitPrdId FOREIGN KEY (KitPrdId) REFERENCES PRODUCT(PrdId),
		CONSTRAINT FK_KitProductCategory_CtgMainId FOREIGN KEY (CtgMainId) REFERENCES RETAILERCATEGORY(CtgMainId)
	)
END
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_KitProductCategory_KitPrdId]') AND parent_object_id = OBJECT_ID(N'[dbo].[KitProductCategory]'))
BEGIN
	ALTER TABLE [dbo].[KitProductCategory] CHECK CONSTRAINT [FK_KitProductCategory_KitPrdId]
END
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_KitProductCategory_CtgMainId]') AND parent_object_id = OBJECT_ID(N'[dbo].[KitProductCategory]'))
BEGIN
	ALTER TABLE [dbo].[KitProductCategory] CHECK CONSTRAINT [FK_KitProductCategory_CtgMainId]
END
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='Cn2Cs_Prk_KitItemRetailerCategory')
BEGIN
	CREATE TABLE Cn2Cs_Prk_KitItemRetailerCategory
	(
		DistCode			VARCHAR(50),
		KitPrdCode			VARCHAR(50),
		CtgCode				VARCHAR(50),
		[Type]				VARCHAR(50),
		DownloadFlag		VARCHAR(1),
		CreatedDate			DATETIME
	)
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Import_KitProductCategory')
DROP PROCEDURE Proc_Import_KitProductCategory
GO
CREATE PROCEDURE Proc_Import_KitProductCategory
(
	@Pi_Records NTEXT 
)
AS
/*********************************
* PROCEDURE	: Proc_Import_KitProductCategory
* PURPOSE	: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_KitItemRetailerCategory 
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 12/12/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_KitItemRetailerCategory(DistCode,KitPrdCode,CtgCode,[Type],DownloadFlag,CreatedDate)
	SELECT DistCode,KitPrdCode,CtgCode,[Type],ISNULL(DownloadFlag,'D'),ISNULL(CreatedDate,GETDATE()) FROM
	OPENXML (@hdoc,'/Root/Console2CS_KitItemRetailerCategory',1)                              
			WITH 
			(  
				DistCode			VARCHAR(50),
				KitPrdCode			VARCHAR(50),
				CtgCode				VARCHAR(50),
				[Type]				VARCHAR(50),
				DownloadFlag		VARCHAR(1),
				CreatedDate			DATETIME
			) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ValiDate_KitProductCategory')
DROP PROCEDURE Proc_ValiDate_KitProductCategory
GO
CREATE PROCEDURE Proc_ValiDate_KitProductCategory
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValiDate_KitProductCategory
* PURPOSE	: To Validate Cn2Cs_Prk_KitItemRetailerCategory  and mnove to main
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 12/12/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
BEGIN
		SET @Po_ErrNo=0
		DELETE PRK FROM Cn2Cs_Prk_KitItemRetailerCategory PRK (NOLOCK) WHERE DownloadFlag='Y'
		SELECT DISTINCT * INTO #Cn2Cs_Prk_KitItemRetailerCategory FROM Cn2Cs_Prk_KitItemRetailerCategory (NOLOCK) WHERE DownloadFlag='D'
		IF NOT EXISTS (SELECT * FROM #Cn2Cs_Prk_KitItemRetailerCategory (NOLOCK)) RETURN
		
		CREATE TABLE #KITPRDTOAVOID
		(
			KitPrdCode VARCHAR(50)
		)
		CREATE TABLE #KITADD
		(
			KitPrdId	INT,
			KitPrdCode	VARCHAR(50),
			CtgMainId	INT,
			CtgCode		VARCHAR(50)
		)
		CREATE TABLE #KITREMOVE
		(
			KitPrdId	INT,
			KitPrdCode	VARCHAR(50),
			CtgMainId	INT,
			CtgCode		VARCHAR(50)
		)
		
		INSERT INTO #KITPRDTOAVOID (KitPrdCode)
		SELECT DISTINCT Prk.KitPrdCode FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) WHERE NOT EXISTS
		(SELECT * FROM Product P INNER JOIN KitProduct K ON K.KitPrdid=P.PrdId WHERE P.PrdType=3 AND P.PrdCCode=Prk.KitPrdCode)
		
		INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cn2Cs_Prk_KitItemRetailerCategory','KitPrdCode','Kit Product Not Available --> '+
		Prk.KitPrdCode FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) WHERE NOT EXISTS
		(SELECT * FROM Product P INNER JOIN KitProduct K ON K.KitPrdid=P.PrdId WHERE P.PrdType=3 AND P.PrdCCode=Prk.KitPrdCode)
		
		DELETE Prk FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) INNER JOIN #KITPRDTOAVOID K (NOLOCK) ON K.KitPrdCode=Prk.KitPrdCode
		
		INSERT INTO #KITPRDTOAVOID (KitPrdCode)
		SELECT DISTINCT Prk.KitPrdCode FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) WHERE NOT EXISTS
		(SELECT RC.CtgCode FROM RetailerCategory RC WHERE RC.CtgCode=Prk.CtgCode)
		
		INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'Cn2Cs_Prk_KitItemRetailerCategory','CtgCode','Retailer Category Not Available For The Kit Product --> '+
		Prk.KitPrdCode FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) WHERE NOT EXISTS
		(SELECT RC.CtgCode FROM RetailerCategory RC WHERE RC.CtgCode=Prk.CtgCode)
		
		DELETE Prk FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) INNER JOIN #KITPRDTOAVOID K (NOLOCK) ON K.KitPrdCode=Prk.KitPrdCode
		
		INSERT INTO #KITPRDTOAVOID(KitPrdCode)
		SELECT DISTINCT Prk.KitPrdCode FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) WHERE UPPER(LTRIM(RTRIM([TYPE]))) NOT IN ('ADD','REMOVE')
		
		INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 3,'Cn2Cs_Prk_KitItemRetailerCategory','CtgCode','Type Should be Add/Remove For The Kit Product --> '+
		Prk.KitPrdCode FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) WHERE UPPER(LTRIM(RTRIM([TYPE]))) NOT IN ('ADD','REMOVE')
		
		DELETE Prk FROM #Cn2Cs_Prk_KitItemRetailerCategory Prk (NOLOCK) INNER JOIN #KITPRDTOAVOID K (NOLOCK) ON K.KitPrdCode=Prk.KitPrdCode
		
		INSERT INTO #KITADD(KitPrdId,KitPrdCode,CtgMainId,CtgCode)
		SELECT DISTINCT K.KitPrdid,P.PrdCCode,RC.CtgMainId,RC.CtgCode FROM KitProduct K (NOLOCK)
		INNER JOIN PRODUCT P (NOLOCK) ON P.PrdId=K.KitPrdid
		INNER JOIN #Cn2Cs_Prk_KitItemRetailerCategory PRK (NOLOCK) ON PRK.KitPrdCode=P.PrdCCode
		INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CTGCODE=PRK.CTGCODE
		WHERE P.PRDTYPE=3 AND UPPER(LTRIM(RTRIM([TYPE])))='ADD'
		AND NOT EXISTS (SELECT KitPrdCode FROM #KITPRDTOAVOID E (NOLOCK) WHERE E.KitPrdCode=PRK.KitPrdCode AND PRK.KitPrdCode=P.PrdCCode)
		
		INSERT INTO #KITREMOVE(KitPrdId,KitPrdCode,CtgMainId,CtgCode)
		SELECT DISTINCT K.KitPrdid,P.PrdCCode,RC.CtgMainId,RC.CtgCode FROM KitProduct K (NOLOCK)
		INNER JOIN PRODUCT P (NOLOCK) ON P.PrdId=K.KitPrdid
		INNER JOIN #Cn2Cs_Prk_KitItemRetailerCategory PRK (NOLOCK) ON PRK.KitPrdCode=P.PrdCCode
		INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CTGCODE=PRK.CTGCODE
		WHERE P.PRDTYPE=3 AND UPPER(LTRIM(RTRIM([TYPE])))='REMOVE'
		AND NOT EXISTS (SELECT KitPrdCode FROM #KITPRDTOAVOID E (NOLOCK) WHERE E.KitPrdCode=PRK.KitPrdCode AND PRK.KitPrdCode=P.PrdCCode)
		
		IF EXISTS (SELECT * FROM #KITADD (NOLOCK))
		BEGIN
			INSERT INTO KitProductCategory (KitPrdId,CtgMainId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT DISTINCT KitPrdId,CtgMainId,1 AS Availability,1 AS LastModBy,GETDATE() AS LastModDate,1 AS AuthId,GETDATE() AS AuthDate 
			FROM #KITADD (NOLOCK) WHERE NOT EXISTS
			(SELECT KitPrdId,CtgMainId FROM KitProductCategory (NOLOCK) WHERE KitProductCategory.KitPrdId=#KITADD.KitPrdId
			AND KitProductCategory.CtgMainId=#KITADD.CtgMainId)			
		END
		IF EXISTS (SELECT * FROM #KITREMOVE (NOLOCK))
		BEGIN
			DELETE KitProductCategory FROM KitProductCategory (NOLOCK) 
			INNER JOIN #KITREMOVE (NOLOCK)
			ON KitProductCategory.KitPrdId=#KITREMOVE.KitPrdId
			AND KitProductCategory.CtgMainId=#KITREMOVE.CtgMainId
		END
		
		UPDATE PRK SET PRK.DownloadFlag='Y'
		FROM Cn2Cs_Prk_KitItemRetailerCategory PRK (NOLOCK) 
		INNER JOIN #Cn2Cs_Prk_KitItemRetailerCategory TMP (NOLOCK)  ON PRK.KITPRDCODE=TMP.KITPRDCODE AND PRK.CTGCODE=TMP.CTGCODE
		INNER JOIN #KITADD KA (NOLOCK)  ON KA.KITPRDCODE=PRK.KITPRDCODE AND KA.CtgCode=PRK.CtgCode
		AND KA.KITPRDCODE=TMP.KITPRDCODE AND KA.CtgCode=TMP.CtgCode
		
		UPDATE PRK SET PRK.DownloadFlag='Y'
		FROM Cn2Cs_Prk_KitItemRetailerCategory PRK (NOLOCK) 
		INNER JOIN #Cn2Cs_Prk_KitItemRetailerCategory TMP (NOLOCK)  ON PRK.KITPRDCODE=TMP.KITPRDCODE AND PRK.CTGCODE=TMP.CTGCODE
		INNER JOIN #KITREMOVE KR (NOLOCK)  ON KR.KITPRDCODE=PRK.KITPRDCODE AND KR.CtgCode=PRK.CtgCode
		AND KR.KITPRDCODE=TMP.KITPRDCODE AND KR.CtgCode=TMP.CtgCode
		
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnRetailerApplicableKitItems')
DROP FUNCTION Fn_ReturnRetailerApplicableKitItems
GO
--SELECT * FROM Fn_ReturnRetailerApplicableKitItems(2,0,3583)
CREATE FUNCTION Fn_ReturnRetailerApplicableKitItems(@RtrId INT,@SalId INT,@KitPrdId INT)
RETURNS @KITRETAILER TABLE
(
	[Status] INT,
	Msg		 VARCHAR(500)
)
AS
/*********************************
* FUNCTION 	: Fn_ReturnRetailerApplicableKitItems
* PURPOSE	: To RETURN APPLIABLE RETAILERS FOR KIT PRODUCT AS RETAILER CATEGORY WISE
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 15/12/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
BEGIN
	DECLARE @RETAILER TABLE 
	(
		RTRID				INT,
		CTGMAINID	INT
	)
		
	DECLARE @KITPRODUCT TABLE 
	(
		KITPRDID	INT,
		CTGMAINID	INT
	)
	
	DECLARE @PRDNAME AS VARCHAR (100)
	SELECT @PRDNAME=PrdName FROM Product WHERE PrdId=@KitPrdId
	
	INSERT INTO @KITPRODUCT(KITPRDID,CTGMAINID)
	SELECT A.KitPrdid,B.CtgMainId FROM KitProduct A (NOLOCK)
	INNER JOIN KitProductCategory B (NOLOCK) ON A.KitPrdId=B.KitPrdId
	 WHERE A.KITPRDID=@KitPrdId
	
	INSERT INTO @RETAILER(RTRID,CTGMAINID)
	SELECT R.RTRID,C.CTGMAINID
	FROM RETAILER R (NOLOCK)
	INNER JOIN RETAILERVALUECLASSMAP M (NOLOCK) ON R.RTRID=M.RTRID
	INNER JOIN RETAILERVALUECLASS V (NOLOCK) ON V.RTRCLASSID=M.RTRVALUECLASSID
	INNER JOIN RETAILERCATEGORY C (NOLOCK) ON C.CTGMAINID=V.CTGMAINID
	INNER JOIN RETAILERCATEGORYLEVEL L (NOLOCK) ON L.CtgLevelId=C.CtgLevelId
	WHERE R.RtrId=@RtrId
	
	IF EXISTS (SELECT A.KITPRDID,A.CTGMAINID FROM @KITPRODUCT A INNER JOIN @RETAILER B ON B.CTGMAINID=A.CTGMAINID)
	BEGIN
		INSERT INTO @KITRETAILER([Status],Msg)
		SELECT 1,''
	END
	ELSE
	BEGIN
		INSERT INTO @KITRETAILER([Status],Msg)
		SELECT 0,'Product --> '+@PRDNAME+' <-- Does not Contains Kit Items For This Retailer '
	END
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_ReturnKitStock')
DROP PROCEDURE Proc_ReturnKitStock
GO
--select * from product where prdccode='KIT201500025'
--select * from productbatchlocation where prdid in (select PrdId from Kitproduct where KitPrdid=2714)
--EXEC Proc_ReturnKitStock '2015-12-24',1,0,2,2
--select * from KitProductStock where kitprdid=2713
CREATE PROCEDURE [dbo].[Proc_ReturnKitStock]
(  
	@Pi_TransDate  		DateTime,
	@Pi_LcnId		INT,
	@Pi_CmpId		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT	
)  
AS  
/*********************************
* PROCEDURE	: Proc_ReturnKitStock
* PURPOSE	: To Return the Kit Product Stock Availability
* CREATED	: Thrinath
* CREATED DATE	: 10/08/2007
* NOTE		: General SP for Returning the Kit Product Stock Availability
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/  
SET NOCOUNT ON  
Begin 
DECLARE @TotalStock TABLE
(
	LcnId		INT,
	KitPrdId	INT,
	Qty		INT,
	PrdId		INT,
	Saleable	INT,
	UnSaleable	INT,
	Offer		INT
)
DECLARE @TotalAvailStock TABLE
(
	KitPrdId	INT,
	Saleable	INT,
	UnSaleable	INT,
	Offer		INT
)
DECLARE @FinalStock TABLE
(
	KitPrdId	INT,
	Qty		INT,
	PrdId		INT,
	KitSaleable	INT,
	KitUnSaleable	INT,
	KitOffer	INT,
	RemSaleable	INT,
	RemUnSaleable	INT,
	RemOffer	INT
)
	INSERT INTO @TotalStock (LcnId,KitPrdId,Qty,PrdId,Saleable,UnSaleable,Offer)
	SELECT @Pi_LcnId AS LcnId,C.KitPrdId,C.Qty,C.PrdId,
		ISNULL(SUM((PrdBatLcnSih - PrdBatLcnRessih)),0) As Saleable,
		ISNULL(SUM((PrdBatLcnUih - PrdBatLcnResUih)),0) AS UnSaleable,
		ISNULL(SUM((PrdBatLcnFre - PrdBatLcnResFre)),0) As Offer
		FROM KitProductBatch A INNER JOIN ProductBatchLocation B ON
		A.PrdId = B.PrdId AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
		AND B.LcnId = CASE @Pi_LcnId WHEN 0 THEN B.LcnId ELSE @Pi_LcnId END
		INNER JOIN KitProduct C ON C.KitPrdId = A.KitPrdId AND A.PrdId = C.PrdId
		INNER JOIN Product D ON D.PrdId = C.KitPrdId 
		AND D.CmpId = CASE @Pi_CmpId WHEN 0 THEN D.CmpId ELSE @Pi_CmpId END
		--AND @Pi_TransDate Between D.EffectiveFrom AND D.EffectiveTo
		AND D.PrdStatus = 1 
	GROUP BY C.KitPrdId,C.Qty,C.PrdId
	INSERT INTO @TotalAvailStock (KitPrdId,Saleable,UnSaleable,Offer)
	SELECT KitPrdId,MIN(Saleable) AS Saleable,MIN(UnSaleable) AS UnSaleable,MIN(Offer) AS Offer
	FROM ( SELECT KitPrdId,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(Saleable/Qty) END AS Saleable,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(UnSaleable/Qty) END AS UnSaleable,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(Offer/Qty) END AS Offer
		FROM @TotalStock) AS A
	GROUP BY KitPrdId
	
	INSERT INTO @FinalStock (KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer)
	SELECT A.KitPrdId,A.Qty,A.PrdId,B.Saleable,B.UnSaleable,B.Offer,
		A.Saleable - (B.Saleable*A.Qty),A.UnSaleable - (B.UnSaleable*A.Qty),
		A.Offer - (B.Offer*A.Qty) FROM @TotalStock A INNER JOIN @TotalAvailStock B
		ON A.KitPrdId = B.KitPrdId
		
	
	DELETE FROM KitProductStock WHERE UsrId = @Pi_UsrId AND TransId = @Pi_TransId
	INSERT INTO KitProductStock (KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer,UsrId,TransId)
	SELECT KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer,@Pi_UsrId,@Pi_TransId
	FROM @FinalStock
	
	
	--UPDATE KitProductStock SET KitProductStock.KitSaleable=KitQty
	--FROM  KitProductStock 
	--INNER JOIN (
	--SELECT KitPrdId,Qty,FLOOR(SUM(RemSaleable)/Qty) AS KitQty from KitProductStock 
	--GROUP BY KitPrdId,Qty ) X ON KitProductStock.KitPrdId=X.KitPrdId
	
		DECLARE @KIT_PRD TABLE
	(
		Num			INT,
		KitPrdid	INT,
		PrdId		INT,
		Qty			INT,
		TransQty	BIGINT,
		Mandatory	INT,
		SlabId		INT
	)
	DECLARE @KIT_STOCK TABLE
	(
		KitPrdid	INT,
		PrdId		INT,
		LcnId		INT,
		Stock		BIGINT
	)
	
	INSERT INTO @KIT_STOCK (KitPrdid,PrdId,LcnId,Stock)
	SELECT KitPrdId,PRDID,LCNID,SUM(STOCK) AS STOCK FROM (
	SELECT KBP.KitPrdId,A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode,SUM(PrdBatLcnSih-PrdBatLcnRessih) AS STOCK FROM PRODUCTBATCHLOCATION A (NOLOCK)
	INNER JOIN PRODUCTBATCH B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId
	INNER JOIN KITPRODUCTBATCH KBP (NOLOCK) ON A.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN A.PrdBatID ELSE KBP.PrdBatID END  
	AND B.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN B.PrdBatID ELSE KBP.PrdBatID END
	AND A.PRDID=KBP.PRDID AND B.PRDID=KBP.PRDID
	--WHERE KBP.KitPrdId=@KITPRDID
	GROUP BY A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode,KBP.KitPrdId HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>0)X GROUP BY PRDID,LCNID,KitPrdId
	
	INSERT INTO @KIT_PRD(Num,KitPrdid,PrdId,Qty,TransQty,Mandatory,SlabId)
	SELECT ROW_NUMBER() OVER (ORDER BY PrdId),KitPrdid,PrdId,Qty,Qty,Mandatory,SlabId FROM KITPRODUCT (NOLOCK) --WHERE KITPRDID=@KITPRDID

	UPDATE KitProductStock SET KitSaleable=ISNULL(X.Available,0)
	FROM KitProductStock K
	INNER JOIN (
	SELECT KitPrdid,MIN(Available) AS Available FROM (
	SELECT A.KitPrdid,A.SlabId,A.PrdId,A.Qty,SUM(B.STOCK) AS STOCK,FLOOR(SUM(B.STOCK)/A.Qty) AS Available
	FROM @KIT_PRD A INNER JOIN @KIT_STOCK B ON A.KitPrdid=B.KitPrdid AND A.PrdId=B.PrdId WHERE A.Mandatory=1
	GROUP BY A.KitPrdid,A.SlabId,A.PrdId,A.Qty
	UNION ALL
	SELECT A.KitPrdid,A.SlabId,0 AS PrdId,A.Qty,SUM(B.STOCK)AS STOCK ,FLOOR(SUM(B.STOCK)/A.Qty) AS Available
	FROM @KIT_PRD A INNER JOIN @KIT_STOCK B ON A.KitPrdid=B.KitPrdid AND A.PrdId=B.PrdId WHERE A.Mandatory=0
	GROUP BY A.KitPrdid,A.SlabId,A.Qty ) Y GROUP BY KitPrdid 
	) X ON X.KitPrdid=K.KitPrdId
	
END
GO
IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id WHERE A.name='KitProduct' AND B.NAME='SlabId')
BEGIN
	UPDATE KitProduct SET SlabId=0 WHERE SlabId IS NULL
END
GO
IF EXISTS (
SELECT B.NAME FROM SYSOBJECTS A INNER JOIN sys.key_constraints B ON A.ID=B.PARENT_OBJECT_ID WHERE A.NAME='KitProduct' AND B.TYPE='PK'
AND B.name='PK_KitProduct_KitPrdId_PrdId')
BEGIN
	ALTER TABLE KitProduct DROP CONSTRAINT PK_KitProduct_KitPrdId_PrdId
END
GO
IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id WHERE A.name='KitProduct' AND B.NAME='SlabId')
BEGIN
	ALTER TABLE KitProduct ALTER COLUMN SlabId INT NOT NULL
END
GO
IF NOT EXISTS (
SELECT B.NAME FROM SYSOBJECTS A INNER JOIN sys.key_constraints B ON A.ID=B.PARENT_OBJECT_ID WHERE A.NAME='KitProduct' AND B.TYPE='PK'
AND B.name='PK_KitProduct_KitPrdId_PrdId_SlabId')
BEGIN
	ALTER TABLE KitProduct ADD CONSTRAINT PK_KitProduct_KitPrdId_PrdId_SlabId PRIMARY KEY CLUSTERED 
	(
		KitPrdid,
		PrdId,
		SlabId
	)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnKitProductCondition')
DROP FUNCTION Fn_ReturnKitProductCondition
GO
CREATE FUNCTION [dbo].[Fn_ReturnKitProductCondition](@KITPRDID INT,@SLABID INT)
RETURNS TINYINT
AS
BEGIN
	DECLARE @EXISTS TINYINT
	SET @EXISTS=0
	IF EXISTS (SELECT * FROM KITPRODUCT (NOLOCK) WHERE KITPRDID=@KITPRDID AND SlabId=@SLABID AND Mandatory=0)
	BEGIN
		SET @EXISTS=0
	END
	ELSE
	BEGIN
		SET @EXISTS=1
	END
RETURN @EXISTS
END
GO
IF EXISTS(SELECT Name FROM SYSOBJECTS WHERE NAME='Proc_ImpSetupDetails' AND XTYPE='P')
DROP PROCEDURE Proc_ImpSetupDetails
GO
CREATE PROCEDURE Proc_ImpSetupDetails
(  
@pRecords Text      
)     
AS     
  
--select * from Setup_Details

 
SET NOCOUNT ON  
BEGIN     
	DECLARE @hDoc INTEGER,       
		@InsertCount INTEGER  
	Declare @File_Names as Varchar(50)
	Declare @File_CrDate as datetime
	Declare @File_Path as Varchar(100)
	Declare @Status as Int
	Declare @RegRequired as int
	Declare @HotfixNo as int
	Declare @VersionNo as int
	Declare @DistCode as Varchar(50)
	Declare @DCode as Varchar(50)
	TRUNCATE TABLE SetupDetails
	EXEC sp_xml_preparedocument @hDoc OUTPUT, @pRecords 
      	SELECT 	File_Names as File_Names,
		Convert(Datetime,File_CrDate,101) as File_CrDate,
		File_Path as File_Path,
		Status as Status,
		RegRequired as RegRequired,
		HotfixNo as HotfixNo,
		VersionNo as VersionNo,
		COnVert(Datetime,File_UnZipDate,101) as File_UnZipDate,
		UploadFileSize as UploadFileSize,
		DownloadFileSize as DownloadFileSize,
		FileExtension as FileExtension,
		FileSplitStatus as FileSplitStatus
		INTO #Setup_Details   
       		FROM  OPENXML (@hdoc, '/MAST/SETUPDETAILS',1)                            
       		WITH ( 	
			File_Names Varchar(50),
			File_CrDate Varchar(10),
			File_Path Varchar(100),
			Status int,   
			RegRequired int,
			HotfixNo int,
			VersionNo Varchar(100),
			File_UnZipDate Varchar(10),
			UploadFileSize BigInt,
			DownloadFileSize Bigint,
			FileExtension  VarChar(5),
			FileSplitStatus Int
			


	    	 ) XMLGodown   
		   
		INSERT INTO SetupDetails 
		SELECT File_Names,File_CrDate,File_Path,Status,RegRequired,HotfixNo,
		VersionNo,File_UnZipDate ,UploadFileSize,DownloadFileSize,FileExtension,FileSplitStatus 
		FROM #Setup_Details
		
		UPDATE SetupDetails SET File_Path = 'C:\Program Files\Common Files\Crystal Decisions\2.0\bin' WHERE [File_Names] like 'Craxdrt%'
		DELETE A FROM SetupDetails A (NOLOCK) WHERE File_Names = 'CSUpdates Alert.exe' AND FileExtension = 'EXE'

EXECUTE sp_xml_removedocument @hDoc 

END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_SellingTaxCalCulation' AND XTYPE='P')
DROP PROC Proc_SellingTaxCalCulation
GO
--Exec Proc_SellingTaxCalCulation 2556,19944
CREATE PROCEDURE Proc_SellingTaxCalCulation
(
	@Prdid AS INT,
	@Prdbatid AS INT
	
)
AS
BEGIN
		DECLARE @TaxSettingDet TABLE       
		(      
		TaxSlab   INT,      
		ColNo   INT,      
		SlNo   INT,      
		BillSeqId  INT,      
		TaxSeqId  INT,      
		ColType   INT,       
		ColId   INT,      
		ColVal   NUMERIC(38,2)      
		) 
		DECLARE @PrdBatTaxGrp AS INT
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT    
		--To Take the Batch TaxGroup Id      
		SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) WHERE Prdid=@Prdid and  Prdbatid=@Prdbatid
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		-- Added by Mahesh on 19/10/2015
		--SELECT @RtrTaxGrp = MAX(Distinct RTRID) from TaxSettingMaster
		SELECT @RtrTaxGrp = MAX(Distinct RTRID) from TaxSettingMaster A,TaxGroupSetting B Where A.Rtrid=B.TaxGroupid and B.TaxGroup=1
		
		
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
		TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
		WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
		AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)  
	
	--select * from @TaxSettingDet
		SET @MRP=1
		TRUNCATE TABLE TempProductTax
		DECLARE  CurTax CURSOR FOR      
			SELECT DISTINCT TaxSlab FROM @TaxSettingDet      
		OPEN CurTax        
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		WHILE @@FETCH_STATUS = 0        
		BEGIN      
		SET @TaxableAmount = 0      
		--To Filter the Records Which Has Tax Percentage (>=0)      
		IF EXISTS (SELECT * FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0 and ColVal >= 0)      
		BEGIN      
		--To Get the Tax Percentage for the selected slab      
		SELECT @TaxPer = ColVal FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0      
		--To Get the TaxId for the selected slab      
		SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId > 0      
		SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP 
		--To Get the Parent Taxable Amount for the Tax Slab      
		SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM TempProductTax A      
		INNER JOIN @TaxSettingDet B ON A.TaxId = B.ColVal and  
		B.ColType = 3 AND B.TaxSlab = @TaxSlab 
		If @ParTaxableAmount>0
		BEGIN
			Set @TaxableAmount=@ParTaxableAmount
		END 
		ELSE
		BEGIN
			Set @TaxableAmount = @TaxableAmount
		END    
		--PRINT @ParTaxableAmount
		--PRINT @TaxableAmount      
		INSERT INTO TempProductTax (PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,      
		TaxAmount)      
		SELECT @Prdid,@Prdbatid,@TaxId,@TaxSlab,@TaxPer,      
		cast(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
		END      
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		END        
		CLOSE CurTax        
		DEALLOCATE CurTax      
		SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
		FROM TempProductTax WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		--PRINT @TaxPercentage
		IF EXISTS(SELECT * FROM ProductBatchTaxPercent WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
		BEGIN			
			UPDATE ProductBatchTaxPercent  SET TaxPercentage=@TaxPercentage
			WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		END	
		ELSE
		BEGIN			
			INSERT INTO ProductBatchTaxPercent(Prdid,Prdbatid,TaxPercentage)
			SELECT @Prdid,@Prdbatid,@TaxPercentage
		END
END
GO
IF EXISTS(SELECT Name FROM Sysobjects WHERE Name='Proc_Cn2Cs_SpecialDiscount' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_SpecialDiscount
GO
CREATE PROCEDURE Proc_Cn2Cs_SpecialDiscount
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SpecialDiscount
* PURPOSE		: To insert SpecialRateDetails in Productbatchdetails table
* CREATED		:  Muthukrishnan.G.P
* CREATED DATE	:  31-12-2012
* MODIFIED      :   
* DATE AUTHOR   : DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 2013-03-01	Vijendra Kumar	CR(PM)-CCRSTPVM0001
* 05-10-2015	Mahesh Babu D	Tax Not Attached for Product		ICRSTPAR1798
* 28-12-2015	Mahesh Babu D	Selling Rate Spl Rate Calc			ICRSTPAR1960 
*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @RtrHierLevelCode 		AS  NVARCHAR(100)
	DECLARE @RtrHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @RtrCode				AS 	NVARCHAR(100)
	
	DECLARE @PrdCCode				AS 	NVARCHAR(100)
	DECLARE @PrdBatCode				AS 	NVARCHAR(100)
	DECLARE @PrdBatCodeAll			AS 	NVARCHAR(100)
	DECLARE @PriceCode				AS 	NVARCHAR(4000)
	DECLARE @Disperc                AS 	NUMERIC(38,6)
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
	DECLARE @RtrTaxGrp AS INT
	SET @Po_ErrNo=0
	SET @ErrStatus=0
	SET @RtrTaxGrp=0
	
	EXEC Proc_CalculateSpecialDiscountAftRate
	
    SET @ContractReq=1
	SET @SRReCalc=2
	
    TRUNCATE TABLE ETL_Prk_BLContractPricing	
	CREATE TABLE #SpecialRateToAvoid
	(
		Slno				BIGINT,
		RtrHierLevel		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		RtrHierValue		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		RtrCode				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		PrdCCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		PrdBatCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		EffectiveFromDate	DATETIME
	)

		SELECT DISTINCT CtgCode INTO #RetailerCategory 
		FROM RetailerCategory RC 
		INNER JOIN RetailerValueClass RVC ON  RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerValueClassMap RCM ON RCM.RtrValueClassId=RVC.RtrClassId
	
		---Retailer Class Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT T.SlNo,CtgLevelName,T.CtgCode,RtrCode,PrdCCode,PrdBatCode,T.EffectiveFromDate
		FROM TempSpecialRateDiscountProduct T
		WHERE NOT EXISTS(SELECT CtgCode FROM #RetailerCategory R WHERE R.CtgCode=T.CtgCode)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer','Retailer Not Attached to Category:'+RtrHierLevel+' Not Available' FROM #SpecialRateToAvoid

		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno and A.CtgCode=B.RtrHierValue and A.Prdccode=B.Prdccode--Modified by Raja.C

		--Product Batch Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT 1,RetCategoryLevel,RetCatLevelValue,'ALL',PrdCategoryLevelValue,'ALL',EffFromDate 
		FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) WHERE DownLoadFlag = 'D' AND PrdCategoryLevel = 'Product'
		AND NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) 
		INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId WHERE A.PrdCategoryLevelValue = B.PrdCCode)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product','Product & ProductBatch','Product or Product Batch Not Available-'+PrdCategoryLevelValue
		FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) WHERE DownLoadFlag = 'D' AND PrdCategoryLevel = 'Product' 
		AND NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) 
		INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId WHERE A.PrdCategoryLevelValue = B.PrdCCode)
		--Till Here	
			
		---Retailer Category Level Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level','Retailer Category Level:'+CtgLevelName+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
		
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno and A.CtgCode=B.RtrHierValue and A.Prdccode=B.Prdccode--Modified by Raja.C
		----
        
        --ProductTaxGroup Validation 		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'Tax Group','TaxGroup Not Attached','Tax Group for :'+PrdCCode+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE PrdCCode  IN (SELECT PrdCCode FROM Product(NOLOCK) WHERE TaxGroupId=0)		
	
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN Product B(NOLOCK)  ON A.PrdCCode=B.PrdCCode and B.TaxGroupId=0 
		--Till here
		
		---Retailer Category Code Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level Value','Retailer Category Level Value:'+CtgCode+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)		
	
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno and A.CtgCode=B.RtrHierValue and A.Prdccode=B.Prdccode--Modified by Raja.C 

		--Eeffective From Date Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE EffectiveFromDate>GETDATE()
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Effective From Date','Effective Date :'+CAST(EffectiveFromDate AS NVARCHAR(12))+' is greater ' 
		FROM TempSpecialRateDiscountProduct
		WHERE EffectiveFromDate>GETDATE()

		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno and A.CtgCode=B.RtrHierValue  and A.Prdccode=B.Prdccode --Modified by Raja.C
			
		IF NOT EXISTS(SELECT * FROM TempSpecialRateDiscountProduct)
		BEGIN
			RETURN
		END
		
		SELECT @CmpId=ISNULL(CmpId,0) FROM Company C WHERE DefaultCompany=1
		Select @RtrTaxGrp=MIN(Distinct RtriD) FROM TaxSettingMaster (NOLOCK)
	
	
		SELECT DISTINCT ISNULL(Prk.CtgLevelName,'') as RtrHierLevelCode,ISNULL(Prk.CtgCode,'') as RtrHierLevelValueCode,
		RtrCode,ISNULL(Prk.PrdCCode,'') as PrdCCode,ISNULL(Prk.PrdBatCode,'') as PrdBatCodeAll,
		ISNULL(DiscPer,0) as Disperc,ISNULL(SpecialSellingRate,0) as SplRate,
		ISNULL(Prk.EffectiveFromDate,GETDATE()) as EffFromDate,ISNULL(Prk.EffectiveToDate,'2013-12-31') as EffToDate,
		ISNULL(CreatedDate,GETDATE()) as CreatedDate,ISNULL(P.PrdId,0) AS PrdId,
		ISNULL(RCL.CtgLevelId,0) AS CtgLevelId,ISNULL(RC.CtgMainId,0) AS CtgMainId,
		Prdbatid,PCV.PrdCtgValMainId,CmpPrdCtgId,ISNULL(Prk.ApplyOn,0) AS ApplyOn,ISNULL(Prk.[Type],0) AS [Type]
		INTO #SplPriceDetails
		FROM TempSpecialRateDiscountProduct Prk 
		INNER JOIN Product P ON Prk.PrdCCode=P.PrdCCode 
		INNER JOIN Productbatch PB ON PB.prdid=P.Prdid and PB.PrdBatCode=Prk.PrdBatCode
		INNER JOIN ProductCategoryValue PCV ON P.PrdCtgValMainId=PCV.PrdCtgValMainId
		INNER JOIN RetailerCategoryLevel RCL ON Prk.CtgLevelName=RCL.CtgLevelName 
		INNER JOIN RetailerCategory RC ON Prk.CtgCode=RC.CtgCode	
		WHERE  Prk.EffectiveFromDate<=GETDATE()	
	
		---Tax Calculation
		DECLARE @PrdIdTax as BIGINT
		DECLARE @PrdbatIdTax AS BIGINT
		DECLARE Cur_Tax CURSOR
		FOR 
		SELECT DISTINCT PrdId,PrdbatId FROM #SplPriceDetails		
		OPEN Cur_Tax	
		FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax
		WHILE @@FETCH_STATUS=0
		BEGIN	
				EXEC Proc_SellingTaxCalCulation @PrdIdTax,@PrdbatIdTax
		FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax		
		END		
		CLOSE Cur_Tax
		DEALLOCATE Cur_Tax	
	
		DECLARE @MaxPriceId as BIGINT
		SELECT @MaxPriceId=ISNULL(MAX(PriceId),0) from ProductBatchDetails
	
		--SELECT A.*,CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) AS NewSellRate
		
		SELECT A.*,CASE A.ApplyOn WHEN 1 THEN 
											(CASE [Type] WHEN 1 THEN (SplRate*100)/(100+TaxPercentage)
											 WHEN 2 THEN (SplRate*100)/(100+TaxPercentage)	END)
		--ELSE CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) END AS NewSellRate
		ELSE CAST(SplRate AS NUMERIC(38,6)) END AS NewSellRate			-- MODIFIED FOR ICRSTPAR1960 
		,@MaxPriceId+ROW_NUMBER() OVER(Order by A.PrdId,A.PrdBatId,CtgLevelId,CtgMainId,PrdCtgValMainId,CmpPrdCtgId)
		as NewPriceId
		INTO #PriceMaster
		FROM #SplPriceDetails A INNER JOIN ProductBatchTaxPercent B ON A.PrdId=B.PrdId
		AND A.PrdBatId=b.PrdBatId
		  
		--SELECT A.*,CASE A.ApplyOn WHEN 1 THEN 
		--									(CASE [Type] WHEN 1 THEN SplRate-(SplRate*(TaxPercentage/100))
		--									 WHEN 2 THEN SplRate-(SplRate*(TaxPercentage/100))	END)
		--ELSE CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) END AS NewSellRate
		--,@MaxPriceId+ROW_NUMBER() OVER(Order by A.PrdId,A.PrdBatId,CtgLevelId,CtgMainId,PrdCtgValMainId,CmpPrdCtgId)
		--as NewPriceId
		--INTO #PriceMaster
		--FROM #SplPriceDetails A INNER JOIN ProductBatchTaxPercent B ON A.PrdId=B.PrdId
		--AND A.PrdBatId=b.PrdBatId
	
		--SELECT * FROM ProductBatchTaxPercent WHERE PRDID=2556
		
		SELECT PrdbatId,MAX(PriceId) as PriceId 
		INTO #ProductbatchDetails 
		FROM ProductBatchDetails GROUP BY PrdbatId
	
		INSERT INTO ProductBatchDetails(
		PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
		SELECT DISTINCT 
		NewPriceId,A.PrdBatId,PrdBatCode+'-Spl Rate-'+CAST(NewSellRate AS NVARCHAR(100))
						+CAST(GETDATE() AS NVARCHAR(20)) ,
		
		D.BatchSeqId,D.SlNo,
				(CASE BC.SelRte WHEN 1 THEN NewSellRate ELSE D.PrdBatDetailValue END) AS SelRte,
				0,1,1,1,GETDATE(),1,GETDATE(),0 
		FROM #PriceMaster A 
		INNER JOIN #ProductbatchDetails B ON A.PrdBatId=B.PrdBatId
		INNER JOIN ProductBatchDetails D ON D.PrdBatId=A.PrdBatId and D.PrdBatId=B.PrdBatId and D.PriceId=B.PriceId
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=D.BatchSeqId AND D.SlNo=BC.SlNo
		INNER JOIN ProductBatch C ON C.PrdBatId=A.PrdBatId and C.PrdBatId=B.PrdBatId and C.PrdId=A.PRdId
		and D.PrdBatId=C.PrdBatId
		ORder by NewPriceId,A.PrdBatId,D.SlNo
		
		UPDATE Counters SET CurrValue=(SELECT ISNULL(Max(PriceId),0) FROM ProductBatchDetails) WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
		UPDATE A SET EnableCloning=1 FROM ProductBatch A
		INNER JOIN #PriceMaster B ON B.Prdbatid=A.PrdbatId
		
		--Contract Price Praking Table insert
		INSERT INTO Cn2Cs_Prk_ContractPricing(CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,
		RtrId,PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount,EffectiveDate,ToDate,CreatedDate,RtrTaxGroupId)
		SELECT DISTINCT @CmpId,CtgLevelId,CtgMainId,0,0,0,CASE WHEN RtrCode='ALL' THEN '0' ELSE ISNULL(RtrCode,'') END,
		Prdid,Prdbatid,NewPriceId,0,0,EffFromDate,EffToDate,CreatedDate,@RtrTaxGrp
		FROM #PriceMaster
		
		---Special Rate Screen Table Insert and Update
		INSERT INTO SpecialRateAftDownLoad(RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,
		SplSelRate,FromDate,CreatedDate,DownloadedDate,ContractPriceIds,DiscountPerc)		
		SELECT DISTINCT RtrHierLevelCode,RtrHierLevelValueCode,RtrCode,PrdCCode,PrdBatCodeAll,
		NewSellRate,EffFromDate,CreatedDate,GETDATE(),'-'+CAST(NewPriceId AS NVARCHAR(10))+'-',Disperc 
		FROM #PriceMaster A
		WHERE NOT EXISTS(		
			SELECT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode, FromDate 
			FROM 
			SpecialRateAftDownLoad B WHERE B.RtrCtgCode=A.RtrHierLevelCode
			and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
			And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll
			and FromDate<=EffFromDate and B.SplSelRate=A.SplRate
						)
		
		UPDATE B  SET SplSelRate=NewSellRate,ContractPriceIds='-'+CAST(NewPriceId AS NVARCHAR(10))+'-',DiscountPerc=Disperc
		FROM #PriceMaster A INNER JOIN SpecialRateAftDownLoad B ON 
		B.RtrCtgCode=A.RtrHierLevelCode
		and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
		And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll 
		AND B.DiscountPerc=A.DisPerc  -- Added FOR ICRSTPAR1960
		WHERE  FromDate<=EffFromDate
		---
	
	
		EXEC Proc_Validate_ContractPricing @Po_ErrNo=@ErrStatus
		SET @Po_ErrNo=@ErrStatus
	
		--IF @Po_ErrNo=0
		--BEGIN	
			UPDATE A SET A.DownLoadFlag='Y' FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) 
			INNER JOIN SpecialRateAftDownload B (NOLOCK) ON A.PrdCategoryLevelValue = B.PrdCCode 
			AND A.RetCategoryLevel = B.RtrCtgCode AND A.RetCatLevelValue = B.RtrCtgValueCode
		--END
		RETURN
END
--Till Here Praveenraj Changes
GO
--Script Updater Files
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Name = 'SyncAttempt' AND Xtype = 'U')
BEGIN
CREATE TABLE SyncAttempt(
	[IPAddress] [varchar](300) NULL,
	[Status] [int] NULL,
	[StartTime] [datetime] NULL
) ON [PRIMARY]
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_ClosingStockTaxCalCulation')
DROP PROCEDURE Proc_ClosingStockTaxCalCulation
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_ClosingStockTaxCalCulation
  SELECT * FROM ClosingStockProductTaxPercent (NOLOCK)
  ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ClosingStockTaxCalCulation]
AS
BEGIN
		DECLARE @TaxSettingDet TABLE       
		(      
			TaxSlab    INT,      
			ColNo      INT,      
			SlNo       INT,      
			BillSeqId  INT,      
			TaxSeqId   INT,      
			ColType    INT,       
			ColId      INT,      
			ColVal     NUMERIC(38,2),
			PrdId      NUMERIC(18,0)      
		) 
		
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT
		
		--To Take the Batch TaxGroup Id      
		--SELECT @PrdBatTaxGrp = TaxGroupId FROM Product A (NOLOCK) INNER JOIN TempClosingStock B (NOLOCK) ON A.PrdId = B.PrdId
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		SELECT @RtrTaxGrp = MAX(DISTINCT RtrId) FROM TaxSettingMaster A (NOLOCK) 
		INNER JOIN TaxGroupSetting B (NOLOCK) ON A.RtrId = B.TaxGroupId WHERE B.TaxGroup = 1
		
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,PrdId)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal,C.PrdId      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN	TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId AND Coltype IN(1,3) 
		INNER JOIN 
		(SELECT DISTINCT A.PrdId,TaxGroupId FROM Product A (NOLOCK) INNER JOIN TempClosingStock B (NOLOCK) ON A.PrdId = B.PrdId) C 
		ON A.PrdId = C.TaxGroupId  WHERE A.RtrId = @RtrTaxGrp     
		AND A.TaxSeqId IN (SELECT ISNULL(MAX(TaxSeqId),0) FROM TaxSettingMaster 
		WHERE RtrId = @RtrTaxGrp AND PrdId = C.TaxGroupId)  
		TRUNCATE TABLE ClosingStockProductTaxPercent   
		      
		--To Get the Tax Percentage for the selected slab      
		SELECT PrdId,ColVal AS TaxPerc,TaxSlab INTO #TaxPercentage FROM @TaxSettingDet 
		WHERE ColType = 1 AND ColId = 0 AND ColVal > 0
		
		--Addtional Tax
		SELECT DISTINCT A.PrdId,A.TaxSlab,B.TaxPerc,CAST(1*(B.TaxPerc/100) AS NUMERIC(28,10)) AS TaxAmount
		INTO #ClosingStockAddTax FROM @TaxSettingDet A INNER JOIN #TaxPercentage B ON A.TaxSlab = B.TaxSlab 
		AND A.PrdId = B.PrdId WHERE ColType = 3 AND ColVal > 0 	
		
		SELECT DISTINCT A.PrdId,A.TaxSlab,B.TaxPerc,CAST(1*(B.TaxPerc/100) AS NUMERIC(28,10)) AS TaxAmount
		INTO #ClosingStockTax FROM @TaxSettingDet A INNER JOIN #TaxPercentage B ON A.TaxSlab = B.TaxSlab AND A.PrdId = B.PrdId
		WHERE ColVal > 0 AND NOT EXISTS (SELECT PrdId FROM #ClosingStockAddTax C WHERE A.PrdId = C.PrdId 
		AND A.TaxSlab = C.TaxSlab)
		
		INSERT INTO #ClosingStockTax (PrdId,TaxSlab,TaxPerc,TaxAmount)
		SELECT DISTINCT A.PrdId,A.TaxSlab,A.TaxPerc,CAST((B.TaxAmount * A.TaxAmount) AS NUMERIC(28,10)) AS TaxAmount
		FROM #ClosingStockAddTax A INNER JOIN #ClosingStockTax B ON A.PrdId = B.PrdId
		
		INSERT INTO ClosingStockProductTaxPercent(PrdId,TaxPercentage)
		SELECT DISTINCT PrdId,ISNULL(SUM(TaxAmount)*100,0) FROM #ClosingStockTax (NOLOCK) GROUP BY PrdId
		
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptCurrentStockParle')
DROP PROCEDURE Proc_RptCurrentStockParle
GO
--Exec Proc_RptCurrentStockParle 249,1,0,'PARLE',0,0,1,0
CREATE PROCEDURE [dbo].[Proc_RptCurrentStockParle]
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

	INSERT Into #PrdUomBox		
	SELECT DISTINCT Prdid,U.ConversionFactor
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	INNER JOIN UomMaster UM On U.UomId=Um.UomId
	Where  P.PrdId Not In (Select PrdId From #PrdUomBox) AND U.ConversionFactor > 1
			
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
			
			--select 'A',* from #PrdWeight
			
	Create TABLE #RptCurrentStock
	(
		PrdId            INT,
		PrdDcode         NVARCHAR(100),
		PrdName      NVARCHAR(200),
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
				FROM dbo.View_CurrentStockReportParle VC LEFT OUTER JOIN #PrdWeight P ON VC.PrdId = P.PrdId 
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
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
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_CN2CS_ProductCodeUnification' AND xtype='P')
DROP PROCEDURE Proc_CN2CS_ProductCodeUnification
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_CN2CS_ProductCodeUnification 0
  SELECT * FROM Errorlog (NOLOCK)
  select * from ProductBatch (Nolock) where PrdId in (473,799,971)
  select * from ProductBatchDetails A (Nolock) INNER JOIN  ProductBatch B (Nolock) ON A.PrdBatId = B.PrdBatId where PrdId in (473,799,971)
  select * from ProductBatchLocation (Nolock) where PrdId in (473,799,971)
  SELECT * FROM CN2CS_Prk_ProductCodeUnification (NOLOCK) 
  ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CN2CS_ProductCodeUnification
(
       @Po_ErrNo INT OUTPUT
)
AS
/*****************************************************************************
* PROCEDURE      : Proc_CN2CS_ProductCodeUnification
* PURPOSE        : To Mapped the Sub Products to Main Products
* CREATED BY     : Sathishkumar Veeramani 18-11-2014
* MODIFIED       :
* DATE      AUTHOR     DESCRIPTION
* {DATE} {DEVELOPER}  {BRIEF MODIFICATION DESCRIPTION}
*******************************************************************************/
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo = 0
DECLARE @ToPrdId     AS NUMERIC(18,0)
DECLARE @PrdId       AS NUMERIC(18,0)
DECLARE @PrdBatId    AS NUMERIC(18,0)
DECLARE @ToPrdBatId  AS NUMERIC(18,0)
DECLARE @LcnId       AS BIGINT
DECLARE @SalTotQty   AS NUMERIC(18,0)
DECLARE @UnSalTotQty AS NUMERIC(18,0)
DECLARE @OfferTotQty AS NUMERIC(18,0)
DECLARE @SalQty      AS NUMERIC(18,0)
DECLARE @UnSalQty    AS NUMERIC(18,0)
DECLARE @OfferQty    AS NUMERIC(18,0)
DECLARE @InvDate     AS DATETIME
DELETE FROM CN2CS_Prk_ProductCodeUnification WHERE DownLoadFlag = 'Y'

	CREATE TABLE #ToAvoidProducts
	(
	  ProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
	  MapProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS
	)
	
	--Product Validations
	INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
	SELECT DISTINCT ProductCode,MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.ProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
	
	INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Product','PrdCCode',ProductCode+'-Product Or ProductBatch Not Available' 
	FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.ProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
	
	INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
	SELECT DISTINCT ProductCode,MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.MapProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
	
	INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Product','PrdCCode',MapProductCode+'-Product Code Not Available' 
	FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.MapProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
	
	--Main Product Code Unique Validation
	INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
	SELECT DISTINCT ProductCode,A.MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) INNER JOIN
	(SELECT COUNT(DISTINCT ProductCode) AS Counts,MapProductCode FROM CN2CS_Prk_ProductCodeUnification (NOLOCK)
	GROUP BY MapProductCode HAVING COUNT(DISTINCT ProductCode) > 1)B ON A.MapProductCode = B.MapProductCode
	WHERE DownLoadFlag = 'D'
	
	INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'CN2CS_Prk_ProductCodeUnification','ProductCode',ProductCode+'-Mapped More than One Products' 
     FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) INNER JOIN
	(SELECT COUNT(DISTINCT ProductCode) AS Counts,MapProductCode FROM CN2CS_Prk_ProductCodeUnification (NOLOCK)
	GROUP BY MapProductCode HAVING COUNT(DISTINCT ProductCode) > 1)B ON A.MapProductCode = B.MapProductCode
	WHERE DownLoadFlag = 'D'
	
	--Unification Product Batch Creation
	--Parent Product & Child Product 
	SELECT DISTINCT B.PrdId AS PPrdId,B.TaxGroupId,C.PrdId AS CPrdId INTO #ProductCodeUnification 
	FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK)
	INNER JOIN Product B (NOLOCK) ON A.ProductCode = B.PrdCCode
	INNER JOIN Product C (NOLOCK) ON A.MapProductCode = C.PrdCCode
	WHERE NOT EXISTS (SELECT DISTINCT ProductCode,MapProductCode FROM #ToAvoidProducts D WHERE A.ProductCode = D.ProductCode 
	AND A.MapProductCode = D.MapProductCode) AND NOT EXISTS (SELECT DISTINCT PrdId FROM ProductBatch E (NOLOCK) WHERE B.PrdId = E.PrdId)
	AND DownLoadFlag = 'D' ORDER BY PPrdId,CPrdId ASC
	
	--Child Product Latest Batch
	SELECT DISTINCT PPrdId,TaxGroupId,MAX(CPrdBatId) AS CPrdBatId INTO #ProductBatch FROM (
	SELECT DISTINCT PPrdId,TaxGroupId,CPrdId,CPrdBatId FROM #ProductCodeUnification A INNER JOIN
	(SELECT PrdId,MAX(PrdBatId) AS CPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.CPrdId = B.PrdId)Qry
	GROUP BY PPrdId,TaxGroupId
	
	--Child Product Latest Batch Details
    SELECT PPrdId,TaxGroupId,CPrdBatId,CPriceId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue
    INTO #ProductBatchDetails FROM #ProductBatch A INNER JOIN
    (SELECT DISTINCT PrdBatId,MAX(PriceId) AS CPriceId FROM ProductBatchDetails (NOLOCK) GROUP BY PrdBatId)B ON A.CPrdBatId = B.PrdBatId
    INNER JOIN ProductBatchDetails C (NOLOCK) ON A.CPrdBatId = C.PrdBatId AND B.PrdBatId = C.PrdBatId AND B.CPriceId = C.PriceId
    
    DECLARE @UPrdBatId AS NUMERIC(18,0)
	DECLARE @UPriceId  AS NUMERIC(18,0)
	SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
	SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
    
    SELECT DISTINCT A.PPrdId,(DENSE_RANK()OVER (ORDER BY PPrdId ASC)+@UPrdBatId) AS PPrdBatId,A.TaxGroupId,PrdBatCode,
    CmpBatCode,MnfDate,ExpDate,BatchSeqId,DecPoints,EnableCloning,CPrdBatId INTO #ParentProductBatch 
    FROM #ProductBatch A INNER JOIN ProductBatch B (NOLOCK) ON A.CPrdBatId = B.PrdBatId 

    SELECT DISTINCT A.PPrdId,PPrdBatId,(DENSE_RANK()OVER(ORDER BY A.PPrdId,PPrdBatId ASC)+@UPriceId) AS PPriceId,
    PriceCode,B.BatchSeqId,SLNo,PrdBatDetailValue INTO #ParentProductBatchDetails 
    FROM #ParentProductBatch A INNER JOIN #ProductBatchDetails B ON A.PPrdId = B.PPrdId AND A.CPrdBatId = B.CPrdBatId
    
    --To Insert Product Batch & ProductBatchDetails
    INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,[Status],TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,
    EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
	SELECT DISTINCT A.PPrdId,A.PPrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,1 AS [Status],TaxGroupId,A.BatchSeqId,DecPoints,
	PPriceId,EnableCloning,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
	FROM #ParentProductBatch A INNER JOIN #ParentProductBatchDetails B ON A.PPrdId = B.PPrdId AND A.PPrdBatId = B.PPrdBatId
	ORDER BY A.PPrdId,A.PPrdBatId,PPriceId
	
	INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
    LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
    SELECT PPriceId,PPrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
    CONVERT(NVARCHAR(10),GETDATE(),121),0 FROM #ParentProductBatchDetails ORDER BY PPriceId,PPrdBatId
    
    --Current Stock Reports
    IF EXISTS (SELECT DISTINCT PPriceId FROM #ParentProductBatchDetails)
    BEGIN
        EXEC Proc_DefaultPriceHistory 0,0,@UPriceId,2,1
    END	
	--Till Here

	SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
	UPDATE Counters SET CurrValue = @UPrdBatId WHERE TabName = 'ProductBatch' AND FldName = 'PrdBatId'
	SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
    UPDATE Counters SET CurrValue = @UPriceId WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
	
	--Mapped Products Stock Posting
	SELECT DISTINCT D.PrdId AS ToPrdId,A.PrdId,PrdBatId,LcnId,(PrdBatLcnSih-PrdBatLcnRessih) AS SalStock,
	(PrdBatLcnUih-PrdBatLcnResUih) AS UnSalStock,(PrdBatLcnFre-PrdBatLcnResFre) AS OfferStock INTO #ProductBatchLocation
	FROM ProductBatchLocation A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId
	INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
	INNER JOIN Product D (NOLOCK) ON C.ProductCode = D.PrdCCode 
	WHERE (PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre) > 0 AND DownLoadFlag = 'D' AND
	NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
	    	
	SELECT DISTINCT ToPrdId,ToPrdBatId INTO #ParentProductLatestBatch FROM #ProductBatchLocation A INNER JOIN
	(SELECT DISTINCT PrdId,MAX(PrdBatId) AS ToPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.ToPrdId = B.PrdId
	ORDER BY ToPrdId
	
	SELECT DISTINCT A.ToPrdId,ToPrdBatId,PrdId,PrdBatId,LcnId,SalStock,UnSalStock,OfferStock INTO #ManualStockPosting
	FROM #ProductBatchLocation A INNER JOIN #ParentProductLatestBatch B ON A.ToPrdId = B.ToPrdId
	ORDER BY A.ToPrdId,ToPrdBatId,PrdId,PrdBatId
		
	--Main Product Stock Posting IN
	DECLARE CUR_STOCKADJIN CURSOR
	FOR SELECT DISTINCT ToPrdId,ToPrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
	SUM(UnSalStock) AS UnSalTotStock,SUM(OfferStock) AS OfferTotStock FROM #ManualStockPosting WITH (NOLOCK) 
	GROUP BY ToPrdId,ToPrdBatId,LcnId ORDER BY ToPrdId,ToPrdBatId
	OPEN CUR_STOCKADJIN		
	FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	        IF @SalTotQty > 0
	        BEGIN
	            --SALEABLE STOCK IN									
				EXEC Proc_UpdateStockLedger 10,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 1,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0		
			END
			IF @UnSalTotQty > 0
			BEGIN
			   --UNSALEABLE STOCK IN									
				EXEC Proc_UpdateStockLedger 11,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 2,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
			END
			IF @OfferTotQty > 0
			BEGIN
			    --OFFER STOCK IN									
				EXEC Proc_UpdateStockLedger 12,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 3,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
			END
					
	FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
	END
	CLOSE CUR_STOCKADJIN
	DEALLOCATE CUR_STOCKADJIN
	--Till Here
	
	--Mapped Product Stock Posting OUT
	DECLARE CUR_STOCKADJOUT CURSOR
	FOR SELECT DISTINCT PrdId,PrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalStock,
	SUM(UnSalStock) AS UnSalStock,SUM(OfferStock) AS OfferStock FROM #ManualStockPosting WITH (NOLOCK) 
	GROUP BY PrdId,PrdBatId,LcnId ORDER BY PrdId,PrdBatId
	OPEN CUR_STOCKADJOUT		
	FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	        IF @SalQty > 0
	        BEGIN
				--SALEABLE STOCK OUT
				EXEC Proc_UpdateStockLedger 13,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0
				EXEC Proc_UpdateProductBatchLocation 1,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0				
			END
			IF @UnSalQty > 0
			BEGIN
				--UNSALEABLE STOCK OUT
				EXEC Proc_UpdateStockLedger 14,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
				EXEC Proc_UpdateProductBatchLocation 2,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
			END
			IF @OfferQty > 0
			BEGIN
				--OFFER STOCK OUT
				EXEC Proc_UpdateStockLedger 15,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
				EXEC Proc_UpdateProductBatchLocation 3,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
			END
					
	FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
	END
	CLOSE CUR_STOCKADJOUT
	DEALLOCATE CUR_STOCKADJOUT	
	--Till Here
	
	SELECT DISTINCT A.PrdId,(SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih)) AS SalStock,(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih)) AS UnSalStock,
	(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) AS OfferStock INTO #FinalStockAvailable FROM ProductBatchLocation A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId 
	INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
	WHERE NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
	GROUP BY A.PrdId
	HAVING (SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih))+(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih))+(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) > 0
	
	--Mapped Products and Product Batches are Inactivate Validation
	UPDATE A SET A.PrdCtgValMainId = C.PrdCtgValMainId FROM Product A (NOLOCK) 
	INNER JOIN CN2CS_Prk_ProductCodeUnification B (NOLOCK) ON A.PrdCCode = B.MapProductCode
	INNER JOIN Product C (NOLOCK) ON B.ProductCode = C.PrdCCode
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts C (NOLOCK)
	WHERE B.ProductCode = C.ProductCode AND B.MapProductCode = C.MapProductCode)
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable D WHERE A.PrdId = D.PrdId)
	
	UPDATE A SET A.[Status] = 0 FROM ProductBatch A (NOLOCK) INNER JOIN 
	(SELECT PrdId FROM Product B (NOLOCK) INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK)
	WHERE C.ProductCode = D.ProductCode AND C.MapProductCode = D.MapProductCode)) B ON A.PrdId = B.PrdId
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable E WHERE A.PrdId = E.PrdId) 
	
	UPDATE A SET A.[PrdStatus] = 0 FROM Product A (NOLOCK) INNER JOIN CN2CS_Prk_ProductCodeUnification B (NOLOCK) ON A.PrdCCode = B.MapProductCode
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts C (NOLOCK)
	WHERE B.ProductCode = C.ProductCode AND B.MapProductCode = C.MapProductCode)
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable D WHERE A.PrdId = D.PrdId) 
	--Till Here
	
	--Moorthi Start Here
	DECLARE @RefNo AS INT
	SELECT @RefNo=ISNULL(MAX(RefNo),0)+1 FROM ProductUnification_Track (NOLOCK)
	
	INSERT INTO ProductUnification_Track(RefNo,ProductCode,ProductName,MapProductCode,CreatedDate)
	SELECT @RefNo,A.ProductCode,A.ProductName,A.MapProductCode,GETDATE() FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
	NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
	AND A.MapProductCode = D.MapProductCode)	
	--Till Here	
	
	UPDATE A SET A.DownloadFlag = 'Y' FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
	NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
	AND A.MapProductCode = D.MapProductCode)	
	    
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_UpdateStockLedger' AND TYPE='P')
DROP PROCEDURE Proc_UpdateStockLedger
GO
/*
BEGIN TRAN
EXEC Proc_UpdateStockLedger 7,1,5078,35664,1,'2015-03-27',1,1,0
ROLLBACK TRAN
*/
CREATE Procedure Proc_UpdateStockLedger
(
	@Pi_ColId   INT,
	@Pi_Type  INT,
	@Pi_PrdId  INT,
	@Pi_PrdBatId  INT,
	@Pi_LcnId  INT,
	@Pi_TranDate  DateTime,
	@Pi_TranQty  Numeric(38,0),
	@Pi_UsrId  INT,
	@Pi_ErrNo  INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateStockLedger
* PURPOSE	: To Update StockLedger
* CREATED	: Thrinath
* CREATED DATE	: 05/01/2007
* NOTE		: General SP for Updating StockLedger
* MODIFIED BY : Boopathy On 23/03/2009 For Updating the Con
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	Declare @sSql as VARCHAR(2500)
	Declare @FldName as VARCHAR(100)
	Declare @ErrNo as INT
	DECLARE @LastTranDate  DATETIME
	DECLARE @OldValue	AS NUMERIC(38,6)
	DECLARE @MaxDate AS DATETIME
	DECLARE @CurVal	 AS NUMERIC(38,6)
	IF EXISTS (SELECT PrdId FROM Product Where PrdId = @Pi_PrdId and PrdType = 3)
	BEGIN
		--IF Product is a KIT Item Return True
		Set @Pi_ErrNo = 0
		RETURN
	END
	BEGIN TRY --Code added by Muthuvel for Inventory check
		SELECT @OldValue=SUM(((B.SalPurchase+B.UnsalPurchase)-(B.SalSales+B.UnSalSales)+
				(-B.SalPurReturn-B.UnsalPurReturn+B.SalStockIn+B.UnSalStockIn-
				B.SalStockOut-B.UnSalStockOut+B.SalSalesReturn+B.UnSalSalesReturn+
				B.SalStkJurIn+B.UnSalStkJurIn-B.SalStkJurOut-B.UnSalStkJurOut+
				B.SalBatTfrIn+B.UnSalBatTfrIn-B.SalBatTfrOut-B.UnSalBatTfrOut+
				B.SalLcnTfrIn+B.UnSalLcnTfrIn-B.SalLcnTfrOut-B.UnSalLcnTfrOut+
				B.SalReplacement+B.DamageIn-B.DamageOut)) * PrdBatDetailValue) --AS StkValue
				FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
				WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
				AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
				AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
				AND B.LcnId=@Pi_LcnId
		SET @OldValue =ISNULL(@OldValue,0)
		IF NOT EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
		and PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
		and TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121))
		BEGIN
			INSERT INTO StockLedger
			(
			TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,
			OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,
			SalPurReturn,UnsalPurReturn,OfferPurReturn,
			SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,
			OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,
			DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,
			SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
			UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,
			OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
			SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,
			UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
			SalClsStock,UnSalClsStock,OfferClsStock,Availability,
			LastModBy,LastModDate,AuthId,AuthDate
			) VALUES
			(
			@Pi_TranDate,@Pi_LcnId,@Pi_PrdId,@Pi_PrdBatId,0,0,
			0,0,0,0,
			0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,1,
			@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
			)
		 END
		 EXEC Proc_UpdateOpeningStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@ErrNo
		 IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 2)
		 BEGIN
			UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 2
		 END
		
		 IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 11)
		 BEGIN
			UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 11
		 END
		 IF @Pi_ColId BETWEEN 7 AND 9
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 1)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 1
			END
		 END
		 IF @Pi_ColId BETWEEN 1 AND 3
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 3)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 3
			END
		 END
		 IF @Pi_ColId BETWEEN 18 AND 20
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 4)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 4
			END
		 END
		 Select @FldName = CASE @Pi_ColId
			  WHEN 1 THEN 'SalPurchase'
			  WHEN 2 THEN 'UnsalPurchase'
			  WHEN 3 THEN 'OfferPurchase'
			  WHEN 4 THEN 'SalPurReturn'
			  WHEN 5 THEN 'UnsalPurReturn'
			  WHEN 6 THEN 'OfferPurReturn'
			  WHEN 7 THEN 'SalSales'
			  WHEN 8 THEN 'UnSalSales'
			  WHEN 9 THEN 'OfferSales'
			  WHEN 10 THEN 'SalStockIn'
			  WHEN 11 THEN 'UnSalStockIn'
			  WHEN 12 THEN 'OfferStockIn'
			  WHEN 13 THEN 'SalStockOut'
			  WHEN 14 THEN 'UnSalStockOut'
			  WHEN 15 THEN 'OfferStockOut'
			  WHEN 16 THEN 'DamageIn'
			  WHEN 17 THEN 'DamageOut'
			  WHEN 18 THEN 'SalSalesReturn'
			  WHEN 19 THEN 'UnSalSalesReturn'
			  WHEN 20 THEN 'OfferSalesReturn'
			  WHEN 21 THEN 'SalStkJurIn'
			  WHEN 22 THEN 'UnSalStkJurIn'
			  WHEN 23 THEN 'OfferStkJurIn'
			  WHEN 24 THEN 'SalStkJurOut'
			  WHEN 25 THEN 'UnSalStkJurOut'
			  WHEN 26 THEN 'OfferStkJurOut'
			  WHEN 27 THEN 'SalBatTfrIn'
			  WHEN 28 THEN 'UnSalBatTfrIn'
			  WHEN 29 THEN 'OfferBatTfrIn'
			  WHEN 30 THEN 'SalBatTfrOut'
			  WHEN 31 THEN 'UnSalBatTfrOut'
			  WHEN 32 THEN 'OfferBatTfrOut'
			  WHEN 33 THEN 'SalLcnTfrIn'
			  WHEN 34 THEN 'UnSalLcnTfrIn'
			  WHEN 35 THEN 'OfferLcnTfrIn'
			  WHEN 36 THEN 'SalLcnTfrOut'
			  WHEN 37 THEN 'UnSalLcnTfrOut'
			  WHEN 38 THEN 'OfferLcnTfrOut'
			  WHEN 39 THEN 'SalReplacement'
			  WHEN 40 THEN 'OfferReplacement' END
		 SET @Pi_ErrNo = 0
		 IF (@Pi_ColId = 4  OR @Pi_ColId = 7  OR @Pi_ColId = 13
			 OR @Pi_ColId = 24 OR @Pi_ColId = 30 OR @Pi_ColId = 36 OR @Pi_ColId = 39) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (SalOpenStock    +
					SalPurchase     +
					SalStockIn    +
					SalSalesReturn   +
					SalStkJurIn   +
					SalBatTfrIn   +
					SalLcnTfrIn   -
					SalPurReturn   -
					SalSales     -
					SalStockOut  -	
					SalStkJurOut   -
					SalBatTfrOut   -
					SalLcnTfrOut   -
					SalReplacement) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF (@Pi_ColId = 5 OR @Pi_ColId = 8 OR @Pi_ColId = 14 OR @Pi_ColId = 17
			 OR @Pi_ColId = 25 OR @Pi_ColId = 31 OR @Pi_ColId = 37) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (UnSalOpenStock    +
					UnSalPurchase   +
					UnSalStockIn    +
					DamageIn      +
					UnSalSalesReturn  +
					UnSalStkJurIn    +
					UnSalBatTfrIn   +
					UnSalLcnTfrIn    -
					UnsalPurReturn  -
					UnSalSales   -
					UnSalStockOut   -
					DamageOut    -
					UnSalStkJurOut   -
					UnSalBatTfrOut   -
					UnSalLcnTfrOut) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF (@Pi_ColId = 6 OR @Pi_ColId = 9 OR @Pi_ColId = 15 OR @Pi_ColId = 26
			  OR @Pi_ColId = 32 OR @Pi_ColId = 38 OR @Pi_ColId = 40) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (OfferOpenStock    +
					OfferPurchase    +
					OfferStockIn     +
					OfferSalesReturn   +
					OfferStkJurIn   +
					OfferBatTfrIn   +
					OfferLcnTfrIn   -
					OfferPurReturn   -
					OfferSales      -
					OfferStockOut   -
					OfferStkJurOut   -
					OfferBatTfrOut   -
					OfferLcnTfrOut   -
					OfferReplacement) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF @Pi_ErrNo = 0
		 BEGIN
			  SET @sSql = 'Update StockLedger Set ' + @FldName + ' = ' + @FldName + ' + '
			  SET @sSql = @sSql + CASE @Pi_Type WHEN 2 Then '-1' Else '1' End + '* '
			  SET @sSql = @sSql + CAST(@Pi_TranQty as VARCHAR(10))
			  SET @sSql = @sSql + ', LastModDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
			  SET @sSql = @sSql + ', AuthDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
			  SET @sSql = @sSql + ', LastModBy = ' + CAST(@Pi_UsrId as VARCHAR(10))
			  SET @sSql = @sSql + ', AuthId = ' + CAST(@Pi_UsrId as VARCHAR(10)) + ' Where'
			  SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND TransDate = ''' + CONVERT(VARCHAR(10),@Pi_TranDate,121) + ''''
			  Exec (@sSql)
		
			  EXEC Proc_UpdateClosingStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@Pi_ClsErrNo = @ErrNo OutPut
			  IF @Pi_ErrNo = 0 AND @ErrNo = 1
			  BEGIN
				   Set @Pi_ErrNo = 1
			  END
			  Select @LastTranDate = ISNULL(MAX(TransDate),CONVERT(VARCHAR(10),'1981-05-30',121)) from
			   StockLedger where PrdId=@Pi_PrdId and PrdBatId=@Pi_PrdBatId
			   and LcnId=@Pi_LcnId and TransDate > @Pi_TranDate
			  IF @LastTranDate <> '1981-05-30'
			  BEGIN
				   SELECT @Pi_TranDate = DATEADD(DAY,1,@Pi_TranDate)
				   WHILE @Pi_TranDate <= @LastTranDate
				   BEGIN
						EXEC Proc_UpdateOpeningStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@Pi_OpnErrNo = @ErrNo OutPut
						SELECT @Pi_TranDate = DATEADD(DAY,1,@Pi_TranDate)
						IF @Pi_ErrNo = 0 AND @ErrNo = 1
						BEGIN
							 Set @Pi_ErrNo = 1
						END
				   END
			  END
	 			IF EXISTS (SELECT TransDate FROM ConsolidateStockLedger WHERE 
							TransDate=@Pi_TranDate)
				BEGIN
							SELECT @CurVal=SUM(((B.SalPurchase+B.UnsalPurchase)-(B.SalSales+B.UnSalSales)+
							(-B.SalPurReturn-B.UnsalPurReturn+B.SalStockIn+B.UnSalStockIn-
							B.SalStockOut-B.UnSalStockOut+B.SalSalesReturn+B.UnSalSalesReturn+
							B.SalStkJurIn+B.UnSalStkJurIn-B.SalStkJurOut-B.UnSalStkJurOut+
							B.SalBatTfrIn+B.UnSalBatTfrIn-B.SalBatTfrOut-B.UnSalBatTfrOut+
							B.SalLcnTfrIn+B.UnSalLcnTfrIn-B.SalLcnTfrOut-B.UnSalLcnTfrOut+
							B.SalReplacement+B.DamageIn-B.DamageOut)) * PrdBatDetailValue) --AS StkValue
							FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
							WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
							AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
							AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
							AND B.LcnId=@Pi_LcnId
							UPDATE ConsolidateStockLedger SET StockValue=  StockValue + ABS(@OldValue) - ABS(@CurVal) ---(@CurStkVal*-1)
							WHERE TransDate=@Pi_TranDate
				
							UPDATE ConsolidateStockLedger SET StockValue=  StockValue + ABS(@OldValue)  - ABS(@CurVal) --(@CurStkVal*-1)
							WHERE TransDate>@Pi_TranDate
				END
				ELSE
				BEGIN
					INSERT INTO ConsolidateStockLedger
						SELECT @Pi_TranDate,ISNULL((@Pi_TranQty * PrdBatDetailValue),0) AS StkValue
						FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
						WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
						AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
						AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
						AND B.LcnId=@Pi_LcnId
						SELECT @CurVal=StockValue FROM ConsolidateStockLedger WHERE TransDate=@Pi_TranDate
						SELECT @MaxDate=MAX(TransDate) FROM ConsolidateStockLedger WHERE TransDate<@Pi_TranDate
						UPDATE ConsolidateStockLedger SET StockValue=  @CurVal + (SELECT DISTINCT StockValue FROM
						ConsolidateStockLedger WHERE TransDate=@MaxDate) WHERE TransDate=@Pi_TranDate
				END
		END
	/*Code added by Muthuvel for Inventory check begins here*/
	END TRY
	BEGIN CATCH
		SET @Pi_ErrNo = 1
	END CATCH
	/*Code added by Muthuvel for Inventory check ends here*/
	IF @Pi_ErrNo = 0
	BEGIN
		IF NOT EXISTS(SELECT * FROM StockLedgerDateCheck WHERE LastTransDate>=@Pi_TranDate)
		BEGIN
			TRUNCATE TABLE StockLedgerDateCheck 
			INSERT INTO StockLedgerDateCheck(LastColId,LastTransDate)
			VALUES(@Pi_ColId,@Pi_TranDate)
		END	
	END
	RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ProductBatch' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ProductBatch
Go
/*   
   BEGIN TRANSACTION  
   EXEC Proc_Cn2Cs_ProductBatch 0  
   SELECT * FROM Productbatch WITH(NOLOCK) WHERE PrdBatId = 29809  
   SELECT * FROM Productbatchdetails WITH(NOLOCK) WHERE PrdBatId = 29809  
   SELECT * FROM ProductBatch (NOLOCK) WHERE PrdId = 1741  
   SELECT * FROM Errorlog WITH(NOLOCK)  
   ROLLBACK TRANSACTION  
*/  
CREATE PROCEDURE Proc_Cn2Cs_ProductBatch  
(  
       @Po_ErrNo INT OUTPUT  
)  
AS  
/***************************************************************************************************  
* PROCEDURE  : Proc_Cn2Cs_ProductBatch  
* PURPOSE  : To Insert and Update records in the Tables ProductBatch and ProductBatchDetails  
* CREATED BY : Nandakumar R.G  
* CREATED DATE : 12/04/2010  
* MODIFIED      : Sathishkumar Veeramani  
* PURPOSE  : New Product Batch - Special Rate Created  
* MODIFIED DATE : 13/09/2012  
* MODIFIED      : Murugan.R  
* PURPOSE  : Batch Optimization  and Akzonabal Price change  
* MODIFIED DATE : 13/09/2012  
* DATE      AUTHOR     DESCRIPTION  
-----------------------------------------------------------------------------------------------------  
* {date} {developer}  {brief modification description}  
*****************************************************************************************************/  
SET NOCOUNT ON  
BEGIN  
 SET @Po_ErrNo =0  
 IF NOT EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK) WHERE DownLoadFlag='D') RETURN  
   
 --Product batch configuration  For Aznoble Client  
 IF EXISTS(SELECT Status FROM Configuration where ModuleId='GENCONFIG33' and Status=1)  
  BEGIN  
   DELETE FROM ProductBatchEeffectiveDate WHERE UpdateFlag='Y'  
     
   INSERT INTO ProductBatchEeffectiveDate(PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,  
   EffectiveDate,MRP,ListPrice,SellingRate,ClaimRate,AddRate1,AddRate2,  
   AddRate3,AddRate4,AddRate5,AddRate6,UpdateFlag)      
   SELECT PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,EffectiveDate,  
   MRP,ListPrice,SellingRate,ClaimRate,AddRate1,AddRate2,AddRate3,  
   AddRate4,AddRate5,AddRate6,'N'   
   FROM Cn2Cs_Prk_ProductBatch WHERE DownLoadFlag='D' AND EffectiveDate>CONVERT(DATETIME ,CONVERT(VARCHAR(10),GETDATE(),121),121)  
   ORDER BY ManufacturingDate ASC --Muthuvel  
       
   DELETE FROM Cn2Cs_Prk_ProductBatch  WHERE DownLoadFlag='D' AND EffectiveDate>CONVERT(DATETIME ,CONVERT(VARCHAR(10),GETDATE(),121),121)  
   --Product Batch and Price Insert For Aznoble Client  
   EXEC Proc_ValidateBatchLDEeffectiveDate  
     
   RETURN  
  END  
   
 IF EXISTS (SELECT * FROM SysObjects WHERE Name = 'PrdBatToAvoid' AND XTYPE = 'U')  
 BEGIN  
  DROP TABLE PrdBatToAvoid   
 END  
 CREATE TABLE PrdBatToAvoid  
 (  
  PrdCCode NVARCHAR(200),  
  PrdBatCode NVARCHAR(200)  
 )  
 DECLARE @ExistingBatchDetails TABLE  
 (  
  PrdId  NUMERIC(18,0),  
  PrdCCode VARCHAR(100),  
  PrdBatCode VARCHAR(100),  
  PriceCode VARCHAR(500),  
  OldLSP  NUMERIC(18,0),  
  PrdBatId NUMERIC(18,0),  
  PriceId  NUMERIC(18,0)  
 )  
 DECLARE @ProductBatchWithCounter TABLE  
 (  
  Slno   NUMERIC(18,0) IDENTITY(1,1),  
  TransNo   NUMERIC(18,0),  
  PrdId   NUMERIC(18,0),  
  PrdCCode  VARCHAR(100),  
  PrdBatCode  VARCHAR(100),  
  MnfDate   DATETIME,  
  ExpDate   DATETIME    
 )   
 DECLARE @ProductBatchPriceWithCounter TABLE  
 (  
  Slno   NUMERIC(18,0) IDENTITY(1,1),  
  TransNo   NUMERIC(18,0),  
  PrdId   NUMERIC(18,0),  
  PrdBatId  NUMERIC(18,0),  
  PriceCode  NVARCHAR(1000),  
  MRP    NUMERIC(18,6),  
  ListPrice  NUMERIC(18,6),  
  SellingRate  NUMERIC(18,6),  
  ClaimRate  NUMERIC(18,6),  
  AddRate1  NUMERIC(18,6)  
 )  
 DECLARE @ContractPrice TABLE  
 (  
    PrdId NUMERIC(18,0),  
    PrdBatId NUMERIC(18,0)  
 )  
   
 DECLARE @ContractBatchPrice TABLE  
    (  
    ContractId       NUMERIC(18,0),  
    CtgMainId        NUMERIC(18,0),  
    PrdId            NUMERIC(18,0),  
    PrdBatId         NUMERIC(18,0),  
    PriceId          NUMERIC(18,0),  
    PriceCode        NVARCHAR(500)  
    )  
    DECLARE @ProductBatchDetails TABLE  
 (  
    PrdId                NUMERIC(18,0),  
    PrdBatId      NUMERIC(18,0),  
    PriceId              NUMERIC(18,0),  
    PriceCode            NVARCHAR(500),  
    NewBatchId           NUMERIC(18,0),  
    Slno                 INT,  
    PrdBatDetailValue    NUMERIC(36,4),  
    NewPriceId           NUMERIC(18,0)  
 )  
 --Added By Sathishkumar Veeramani 2015/01/08  
 DECLARE @ExistingSellingPriceDetails TABLE  
 (  
     PrdId        NUMERIC(18,0),  
     PrdBatId     NUMERIC(18,0),  
     PriceId      NUMERIC(18,0)  
 )  
 DECLARE @ExistingListPriceDetails TABLE  
 (  
     PrdId        NUMERIC(18,0),  
     PrdBatId     NUMERIC(18,0),  
     PriceId      NUMERIC(18,0)  
 )  
 --Till Here    
   
 DECLARE @BatSeqId   AS INT  
 DECLARE @ValDiffRefNo  AS VARCHAR(100)  
 DECLARE @ExistPrdBatMaxId AS  INT  
 DECLARE @NewPrdBatMaxId  AS  INT   
 DECLARE @ContPriceId  AS  NUMERIC(18,0)  
 DECLARE @OldPriceIdExt   AS  NUMERIC(18,0)  
 DECLARE @OldPriceId   AS  NUMERIC(18,0)  
 DECLARE @NewPriceId   AS  INT  
 DECLARE @ContPrdId          AS  INT  
    DECLARE @ContPrdBatId       AS  INT  
    DECLARE @ContPriceId1       AS  INT  
    DECLARE @PriceId            AS  INT   
    DECLARE @PriceBatch         AS  INT  
    DECLARE @BatchTransfer  AS INT  
 DECLARE @Po_BatchTransfer AS INT  
   
 SELECT @OldPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails WITH (NOLOCK)    
 SELECT @BatSeqId=MAX(BatchSeqId) FROM BatchCreationMaster WITH (NOLOCK)  
 SELECT @ExistPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch WITH (NOLOCK)  
 SET @Po_ErrNo =0  
 IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)  
 WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D')  
 BEGIN  
  INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)  
  SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)  
  WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D'  
    
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Product Batch','PrdCCode','Product :'+PrdCCode+' not available'  
  FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK) WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK))   
  AND DownLoadFlag='D'  
    
  --->Added By Nanda on 05/05/2010  
  INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)  
  SELECT DISTINCT DistCode,'Product Batch',PrdBatCode,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)   
  WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D'  
  --->Till Here      
 END  
 IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)  
 WHERE LEN(ISNULL(PrdBatCode,''))=0  AND DownLoadFlag='D')  
 BEGIN  
  INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)  
  SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)  
  WHERE LEN(ISNULL(PrdBatCode,''))=0 AND DownLoadFlag='D'  
    
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Product Batch','PrdBatCode','Batch Code should not be empty for Product:'+PrdCCode  
  FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)  
  WHERE LEN(ISNULL(PrdBatCode,''))=0 AND DownLoadFlag='D'  
 END  
    
 INSERT INTO @ExistingBatchDetails (PrdId,PrdCCode,PrdBatCode,PriceCode,OldLSP,PrdBatId,PriceId)  
 SELECT DISTINCT B.PrdId,B.PrdCCode,A.PrdBatCode,A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+  
 CAST(SellingRate AS NVARCHAR(25))+'-'+CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)) AS PriceCode,  
 ISNULL(D.PrdBatDetailValue,0) AS OldLSP,C.PrdBatId,D.PrdBatId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK)   
 INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode  
 INNER JOIN ProductBatch C (NOLOCK)ON A.PrdBatCode=C.PrdBatCode AND B.PrdId=C.PrdId  
 INNER JOIN ProductBatchDetails D (NOLOCK) ON  D.PrdBatId=C.PrdBatId AND D.DefaultPrice=1 AND D.SlNo=2  
 WHERE A.PrdBatCode NOT IN (SELECT PrdBatCode FROM PrdBatToAvoid) AND DownLoadFlag='D'  
   
 --Added By Sathishkumar Veeramani 2015/01/08  
 --Selling Rate Validation  
 INSERT INTO @ExistingSellingPriceDetails (PrdId,PrdBatId,PriceId)  
 SELECT DISTINCT PrdId,B.PrdBatId,C.PriceId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK)   
 INNER JOIN @ExistingBatchDetails B ON A.PrdCCode = B.PrdCCode AND A.PrdBatCode = B.PrdBatCode  
 INNER JOIN ProductBatchDetails C (NOLOCK) ON B.PrdBatId = C.PrdBatId AND A.SellingRate = C.PrdBatDetailValue  
 WHERE C.SLNo = 3  
   
 --List Price Validation  
 INSERT INTO @ExistingListPriceDetails (PrdId,PrdBatId,PriceId)  
 SELECT DISTINCT PrdId,B.PrdBatId,C.PriceId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK)   
 INNER JOIN @ExistingBatchDetails B ON A.PrdCCode = B.PrdCCode AND A.PrdBatCode = B.PrdBatCode  
 INNER JOIN ProductBatchDetails C (NOLOCK) ON B.PrdBatId = C.PrdBatId AND A.ListPrice = C.PrdBatDetailValue  
 WHERE C.SLNo = 2  
   
 SELECT DISTINCT A.PrdId,A.PrdBatId,MAX(A.PriceId) AS PriceId INTO #ExistinPriceCloning   
 FROM @ExistingSellingPriceDetails A   
 INNER JOIN @ExistingListPriceDetails B ON A.PrdId = B.PrdId  
 AND A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId GROUP BY A.PrdId,A.PrdBatId  
   
 IF EXISTS (SELECT DISTINCT PrdId,PrdBatId,PriceId FROM #ExistinPriceCloning)  
 BEGIN  
     UPDATE A SET A.DefaultPrice = 0 FROM ProductBatchDetails A (NOLOCK)   
     INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId  
       
     UPDATE A SET A.DefaultPrice = 1 FROM ProductBatchDetails A (NOLOCK)  
     INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId  
       
     UPDATE A SET A.DefaultPriceId = B.PriceId FROM ProductBatch A (NOLOCK)   
     INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId       
 END  
 --Till Here  
   
 --Added By Sathishkumar Veeramani 2015/01/08  
 --Batch Cloning Details  
    DECLARE @BatchPriceId AS NUMERIC(18,0)  
    SELECT @BatchPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)  
 SELECT DISTINCT CAST(DENSE_RANK() OVER (ORDER BY MAX(PrdBatId),MRP,ListPrice,SellingRate,ClaimRate) AS NUMERIC(18,0))+@BatchPriceId AS PriceId,  
 MAX(PrdBatId) AS PrdBatId,A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+CAST(SellingRate AS NVARCHAR(25))+'-'+  
 CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)) AS PriceCode,MRP,ListPrice,  
 SellingRate,ClaimRate,AddRate1 INTO #BatchCloningDetails FROM Cn2Cs_Prk_ProductBatch A (NOLOCK)  
 INNER JOIN Product B (NOLOCK) ON A.PrdCCode = B.PrdCCode   
 INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId AND A.PrdBatCode = C.PrdBatCode WHERE DownloadFlag = 'D'  
 AND NOT EXISTS (SELECT DISTINCT PrdId,PrdBatId FROM #ExistinPriceCloning D WHERE C.PrdId = D.PrdId AND C.PrdBatId = D.PrdBatId)   
 GROUP BY A.PrdBatCode,MRP,ListPrice,SellingRate,ClaimRate,AddRate1  
   
 IF EXISTS (SELECT DISTINCT PrdBatId FROM #BatchCloningDetails)  
 BEGIN  
     UPDATE A SET DefaultPrice = 0 FROM ProductBatchDetails A WITH(NOLOCK)   
  INNER JOIN #BatchCloningDetails B ON A.PrdBatId = B.PrdBatId  
         
  INSERT INTO ProductBatchDetails (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,  
  Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)  
  SELECT DISTINCT PriceId,PrdBatId,PriceCode,1,SlNo,Rate,1,1,1,1,GETDATE(),1,GETDATE(),0 FROM(  
  SELECT DISTINCT PriceId,PrdBatId,PriceCode,1 AS SlNo,MRP AS Rate FROM #BatchCloningDetails UNION  
  SELECT DISTINCT PriceId,PrdBatId,PriceCode,2 AS SlNo,ListPrice AS Rate FROM #BatchCloningDetails UNION  
  SELECT DISTINCT PriceId,PrdBatId,PriceCode,3 AS SlNo,SellingRate AS Rate FROM #BatchCloningDetails UNION  
  SELECT DISTINCT PriceId,PrdBatId,PriceCode,4 AS SlNo,ClaimRate AS Rate FROM #BatchCloningDetails)Qry ORDER BY PrdBatId  
  SELECT @BatchPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)  
  UPDATE Counters SET CurrValue = @BatchPriceId WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'  
    
        UPDATE A SET DefaultPriceId = B.PriceId FROM ProductBatch A WITH(NOLOCK)   
  INNER JOIN #BatchCloningDetails B ON A.PrdBatId = B.PrdBatId  
    END  
 --Till Here  
    
 IF EXISTS (SELECT * FROM @ExistingBatchDetails)  
 BEGIN  
  UPDATE A SET MnfDate=C.ManufacturingDate,ExpDate=ExpiryDate  
  FROM ProductBatch A (NOLOCK) INNER JOIN @ExistingBatchDetails B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId  
  INNER JOIN Cn2Cs_Prk_ProductBatch C (NOLOCK) ON A.PrdBatCode=C.PrdBatCode  AND B.PrdCCode=C.PrdCCode  
  WHERE C.DownLoadFlag='D'  
   
  UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y'   
  WHERE PrdCCode+'~'+PrdBatCode IN (SELECT PrdCCode+'~'+PrdBatCode FROM @ExistingBatchDetails) AND DownLoadFlag='D'   
 END  
   
 DECLARE @Count1 NUMERIC(18,0)  
 DECLARE @Count2 NUMERIC(18,0)  
 SELECT @Count1=COUNT(*) FROM Cn2Cs_Prk_ProductBatch  
 SELECT @Count2=COUNT(*) FROM @ExistingBatchDetails  
 IF @Count1<>@Count2  
  BEGIN  
 --IF NOT EXISTS (SELECT * FROM @ExistingBatchDetails)  
 --BEGIN  
 ---New ProductBatch    
  INSERT INTO @ProductBatchWithCounter  
  SELECT DISTINCT (SELECT CurrValue FROM Counters (NOLOCK) WHERE TabName='ProductBatch' AND FldName='PrdBatId'),  
  B.PrdId,A.PrdCCode,A.PrdBatCode,ManufacturingDate,ExpiryDate FROM Cn2Cs_Prk_ProductBatch A (NOLOCK)   
  INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode WHERE NOT EXISTS (SELECT PrdBatCode FROM ProductBatch C (NOLOCK)   
  WHERE C.PrdBatCode=A.PrdBatCode AND B.PrdId=C.PrdId)AND   
  A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND A.DownLoadFlag='D'  
  ORDER BY ManufacturingDate ASC --Muthuvel  
    
     
  UPDATE @ProductBatchWithCounter SET TransNo=TransNo+Slno  
 --Existing ProductBatch   
   INSERT INTO @ProductBatchWithCounter  
   SELECT DISTINCT C.PrdBatId,B.PrdId,A.PrdCCode,A.PrdBatCode,  
   ManufacturingDate,ExpiryDate FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode  
   INNER JOIN ProductBatch C ON B.PrdId = C.PrdId AND C.PrdBatCode = A.PrdBatCode WHERE   
   NOT EXISTS (SELECT PrdBatId FROM ProductBatchDetails D(NOLOCK) WHERE D.PrdBatId = C.PrdBatId AND D.PriceId = C.DefaultPriceId)   
   AND  A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND A.DownLoadFlag='D'  
   AND  A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM @ProductBatchWithCounter)  
   
  --Product Batch     
  INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,  
  TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
  SELECT DISTINCT A.PrdId,TransNo,PrdBatCode,PrdBatCode,MnfDate,ExpDate,1,B.TaxGroupId,@BatSeqId,  
  6,0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchWithCounter A   
  INNER JOIN Product B ON A.PrdId=B.PrdId WHERE NOT EXISTS (SELECT PrdBatCode FROM ProductBatch C WHERE A.PrdId = C.PrdId   
  AND A.PrdBatCode = C.PrdBatCode)  
    --END   
  END  
 IF EXISTS (SELECT * FROM @ProductBatchWithCounter)   
 BEGIN  
  UPDATE Counters SET CurrValue = (SELECT MAX(PrdBatId) FROM ProductBatch) WHERE TabName = 'ProductBatch' AND FldName = 'prdbatid'  
   
  INSERT INTO @ProductBatchPriceWithCounter  
  SELECT DISTINCT (SELECT CurrValue FROM Counters (NOLOCK) WHERE TabName='ProductBatchDetails' AND FldName='PriceId'),A.PrdId,A.TransNo,  
  A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+  
  CAST(SellingRate AS NVARCHAR(25))+'-'+CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)),MRP,ListPrice,  
  SellingRate,ClaimRate,AddRate1 FROM @ProductBatchWithCounter A INNER JOIN Cn2Cs_Prk_ProductBatch B WITH (NOLOCK)  
  ON A.PrdCCode=B.PrdCCode AND A.PrdBatCode=B.PrdBatCode WHERE B.DownLoadFlag='D'  
    
  UPDATE @ProductBatchPriceWithCounter SET TransNo=TransNo+Slno  
      
  UPDATE A SET A.DefaultPrice=0 FROM ProductBatchDetails A WITH (NOLOCK),@ProductBatchPriceWithCounter B    
     WHERE A.PrdBatId = B.PrdBatId  
    
 END     
   
 IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=4  
 BEGIN  
  INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,  
  DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,1,MRP,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
  UNION  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,2,ListPrice,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
  UNION  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,3,SellingRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
  UNION  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,4,ClaimRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
  
  -- Added by Mahesh on 27.05.2015 for Duplicate Prices downloading from console
		 select prdid,prdbatid,max(transno)TransNo into #DefaltPrice2update from @ProductBatchPriceWithCounter
	     Group by PrdId,PrdBatId
   
		 UPDATE A SET A.DefaultPrice=0 FROM ProductBatchDetails A WITH (NOLOCK),@ProductBatchPriceWithCounter B    
		 WHERE A.PrdBatId = B.PrdBatId 

		 UPDATE A SET A.DefaultPrice=1 FROM ProductBatchDetails A WITH (NOLOCK),#DefaltPrice2update B    
		 WHERE A.PrdBatId = B.PrdBatId  and A.Priceid=B.TransNo
-- Till here

 END  
 ELSE IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=5  
 BEGIN  
  INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,  
  DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,1,MRP,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
  UNION  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,2,ListPrice,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
  UNION  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,3,SellingRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
  UNION  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,4,ClaimRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
  UNION  
  SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,5,AddRate1,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter  
 END   
 UPDATE A SET DefaultPriceId=C.TransNo FROM ProductBatch A INNER JOIN @ProductBatchPriceWithCounter C ON C.PrdBatId=A.PrdBatId AND A.PrdId=C.PrdId   
   
 IF EXISTS(SELECT * FROM @ProductBatchPriceWithCounter)   
 BEGIN  
  UPDATE Counters SET CurrValue = (SELECT MAX(PriceId) FROM ProductBatchDetails)  WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'   
 END  
   
 --Batch Cloning Price Details  
   
 IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRateForOldBatch' AND ModuleName='Botree Product Batch Download' AND Status=1)  
 BEGIN  
  IF EXISTS(SELECT * FROM @ProductBatchPriceWithCounter A INNER JOIN @ExistingBatchDetails B ON A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId  
  WHERE (B.OldLSP-A.ListPrice)<>0 AND Slno=2)  
  BEGIN  
   SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))  
     
   INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,  
   ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
     
   SELECT @ValDiffRefNo,GETDATE(),A.PrdId,A.PrdBatID,B.PriceId,C.TransNo,B.OldLsp,C.ListPrice,  
   ISNULL(SUM(A.PrdBatLcnSih+A.PrdBatLcnUih-A.PrdBatLcnRessih-A.PrdBatLcnResUih),0),B.OldLsp-C.ListPrice,  
   ISNULL(SUM(A.PrdBatLcnSih+A.PrdBatLcnUih-A.PrdBatLcnRessih-A.PrdBatLcnResUih),0)*(B.OldLsp-C.ListPrice),  
   1,1,GETDATE(),1,GETDATE() FROM ProductBatchLocation A INNER JOIN @ExistingBatchDetails B ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId   
   INNER JOIN @ProductBatchPriceWithCounter C ON A.PrdBatId=C.PrdBatId AND A.PrdId=C.PrdId  
   WHERE C.Slno=2 GROUP BY A.PrdId,A.PrdBatID,B.PriceId,C.TransNo,B.OldLsp,C.ListPrice  
     
   UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'  
  END  
 END  
 UPDATE ProductBatch SET ProductBatch.DefaultPriceId=PBD.PriceId,ProductBatch.BatchSeqId=PBD.BatchSeqId  
 FROM ProductBatchDetails PBD WITH (NOLOCK) WHERE ProductBatch.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1  
   
 UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId IN  
 (  
  SELECT PrdBatId FROM ProductBatchDetails WITH (NOLOCK) GROUP BY PrdBatId  HAVING(COUNT(DISTINCT PriceId)>1)  
 )  
   
 SELECT PrdBatId INTO #ZeroBatches FROM ProductBatchDetails WITH (NOLOCK)  
 GROUP BY PrdBatId HAVING SUM(DefaultPrice)=0  
   
 SELECT B.PrdId,B.PrdBatId,MAX(PriceId) As PriceId INTO #ZeroMaxPrices  
 FROM ProductBatchDetails A INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId  
 INNER JOIN #ZeroBatches C ON A.PrdBatId=C.PrdBatId  
 WHERE A.DefaultPrice=0 AND NOT EXISTS  
 (SELECT DISTINCT PriceId FROM #BatchCloningDetails D WHERE A.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId)  
 AND NOT EXISTS (SELECT DISTINCT PriceId FROM #ExistinPriceCloning E WHERE A.PrdBatId = E.PrdBatId AND A.PriceId = E.PriceId)  
 GROUP BY B.PrdId,B.PrdBatId   
   
   
 UPDATE ProductBatch Set DefaultPriceId=B.PriceId FROM ProductBatch A,#ZeroMaxPrices B  
 WHERE A.PrdBatId=B.PrdbatId and A.PrdId=B.PrdId   
   
 UPDATE ProductBatchDetails Set DefaultPrice=1 FROM #ZeroMaxPrices A  
 WHERE ProductBatchDetails.PrdbatId=A.PrdBatId AND ProductBatchDetails.PriceId=A.PriceId  
   
 SET @Po_ErrNo=0  
 SELECT @OldPriceIdExt=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails  
 IF @ExistPrdBatMaxId>0  
 BEGIN  
  SELECT @NewPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch  
  IF @NewPrdBatMaxId>@ExistPrdBatMaxId  
  BEGIN  
        
      --Existing Contract Pricing Percentage Updated to New Batch Download  
          SELECT DISTINCT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,MAX(CreatedDate) AS CreatedDate INTO #SpecialRateCreatedDate  
      FROM SpecialRateAftDownload WITH(NOLOCK) GROUP BY RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode ORDER BY PrdCCode  
           
   SELECT DISTINCT C.PrdId,E.PrdBatId,TransNo AS PriceId,A.RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,  
   D.PrdBatCode,DiscountPerc,(MRP-(MRP*(DiscountPerc/100))) AS SplRate INTO #SpecialRateDetails   
   FROM SpecialRateAftDownload A WITH(NOLOCK)  
   INNER JOIN #SpecialRateCreatedDate B ON A.RtrCtgCode = B.RtrCtgCode AND A.RtrCtgValueCode = B.RtrCtgValueCode   
   AND A.RtrCode = B.RtrCode AND A.PrdCCode = B.PrdCCode AND A.CreatedDate = B.CreatedDate  
   INNER JOIN Product C WITH(NOLOCK) ON A.PrdCCode = C.PrdCCode     
   INNER JOIN ProductBatch D WITH(NOLOCK) ON C.PrdId = D.PrdId  
   INNER JOIN @ProductBatchPriceWithCounter E ON C.PrdId = E.PrdId AND D.PrdBatId = E.PrdBatId  
   ORDER BY A.PrdCCode     
   
   SELECT DISTINCT MAX(E.ContractId) AS ContractId,A.PrdId,A.PrdBatId,A.PriceId,B.CtgLevelId,C.CtgMainId,SplRate,RtrCtgValueCode   
   INTO #SpecialContractDetails FROM #SpecialRateDetails A WITH(NOLOCK)   
   INNER JOIN RetailerCategoryLevel B WITH(NOLOCK) ON A.RtrCtgCode = B.CtgLevelName   
   INNER JOIN RetailerCategory C WITH(NOLOCK) ON A.RtrCtgValueCode = C.CtgCode AND B.CtgLevelId = C.CtgLevelId  
   INNER JOIN ContractPricingMaster D WITH(NOLOCK) ON B.CtgLevelId = D.CtgLevelId AND C.CtgMainId = D.CtgMainId   
   INNER JOIN ContractPricingDetails E WITH(NOLOCK) ON D.ContractId = E.ContractId AND A.PrdId = E.PrdId   
   GROUP BY A.PrdId,A.PrdBatId,A.PriceId,B.CtgLevelId,C.CtgMainId,SplRate,RtrCtgValueCode  
     
   ---Tax Calculation  
   DECLARE @PrdIdTax as BIGINT  
   DECLARE @PrdbatIdTax AS BIGINT  
   DECLARE Cur_Tax CURSOR  
   FOR   
   SELECT DISTINCT PrdId,PrdbatId FROM #SpecialContractDetails    
   OPEN Cur_Tax   
   FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax  
   WHILE @@FETCH_STATUS=0  
   BEGIN   
     EXEC Proc_SellingTaxCalCulation @PrdIdTax,@PrdbatIdTax  
   FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax    
   END    
   CLOSE Cur_Tax  
   DEALLOCATE Cur_Tax   
     
   SELECT DISTINCT A.PrdId,A.PrdBatId,PriceId,RtrCtgValueCode,DENSE_RANK ()OVER (ORDER BY A.PriceId,A.PrdbatId,RtrCtgValueCode)+ @OldPriceIdExt AS NewPriceId,  
   CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) AS NewSelRate INTO #SplProductBatchDetails  
   FROM #SpecialContractDetails A WITH(NOLOCK) INNER JOIN ProductBatchTaxPercent B WITH(NOLOCK) ON A.PrdId = B.PrdId  
   AND A.PrdBatId = B.PrdBatId ORDER BY A.PrdId,A.PrdBatId,PriceId,RtrCtgValueCode  
     
     
   --Product Batch Details Value Added     
   INSERT INTO ProductBatchDetails (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,  
            Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)              
            SELECT DISTINCT NewPriceId,A.PrdBatId,PriceCode+'SplRate'+CONVERT(NVARCHAR(200),NewSelRate)+CONVERT(NVARCHAR(10),GETDATE(),121),  
            A.BatchSeqId,A.SLNo,(CASE SelRte WHEN 1 THEN NewSelRate ELSE PrdBatDetailValue END),0,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,  
            CONVERT(NVARCHAR(10),GETDATE(),121),0  
            FROM ProductBatchDetails A WITH(NOLOCK)   
            INNER JOIN #SplProductBatchDetails B ON A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId  
            INNER JOIN ProductBatch C WITH(NOLOCK) ON A.PrdBatId = C.PrdBatId  
            INNER JOIN BatchCreation D WITH(NOLOCK) ON C.BatchSeqId = D.BatchSeqId AND A.SLNo = D.SlNo ORDER BY A.PrdBatId,NewPriceId   
            UPDATE Counters SET CurrValue =(SELECT MAX(PriceId) FROM ProductBatchDetails) WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'  
               
            --Contract Pricing Details Added  
            INSERT INTO ContractPricingDetails (ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,Availability,LastModBy,LastModDate,AuthId,  
            AuthDate,CtgValMainId,ClaimablePercOnMRP)              
            SELECT DISTINCT ContractId,A.PrdId,A.PrdBatId,B.NewPriceId,0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0,0  
            FROM #SpecialContractDetails A INNER JOIN #SplProductBatchDetails B ON A.PrdId = B.PrdID AND A.PrdBatId = B.PrdBatId AND A.RtrCtgValueCode=B.RtrCtgValueCode  
            WHERE NOT EXISTS (SELECT ContractId FROM ContractPricingDetails C WITH(NOLOCK) WHERE A.ContractId = C.ContractId   
            AND A.PrdId = C.PrdID AND A.PrdBatId = C.PrdBatId) ORDER BY ContractId,A.PrdId,A.PrdBatId,B.NewPriceId  
            --Special Rate Updated  
            INSERT INTO SpecialRateAftDownload (RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,SplSelRate,FromDate,CreatedDate,DownloadedDate,  
            ContractPriceIds,DiscountPerc,SplrateId)  
            SELECT DISTINCT RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,A.PrdBatCode,A.SplRate,CONVERT(NVARCHAR(10),GETDATE(),121),GETDATE(),GETDATE(),  
            '-'+CONVERT(NVARCHAR(50),NewPriceId)+'-',DiscountPerc,0  
            FROM #SpecialRateDetails A INNER JOIN #SplProductBatchDetails B ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId   
            and A.RtrCtgValueCode=B.RtrCtgValueCode  
            ORDER BY PrdCCode,PrdBatCode  
                 
   --SELECT PrdId,PrdBatId,TransNo, FROM @ProductBatchPriceWithCounter INNER JOIN   
     
      --SELECT A.PrdId,MAX(A.PrdBatId) AS PrdBatId INTO #ContractPrice FROM ProductBatch A (NOLOCK),@ProductBatchWithCounter B  
   --WHERE  A.PrdId = B.PrdId AND A.PrdBatId < @ExistPrdBatMaxId AND EXISTS  
   --(SELECT CPD.PrdBatId FROM ContractPricingDetails CPD (NOLOCK)  
   --INNER JOIN ProductBatch PB1 (NOLOCK) ON CPD.PrdId=PB1.PrdId AND CPD.PrdBatId=PB1.PrdBatId AND A.PrdBatId=CPD.PrdBatId  
   --AND CPD.PrdID IN (SELECT DISTINCT PrdId FROM @ProductBatchWithCounter))GROUP BY A.PrdId   
     
  -- INSERT INTO @ContractPrice (PrdId,PrdBatId)  
  -- SELECT A.PrdId,MAX(A.PrdBatId) AS PrdBatId FROM ProductBatch A (NOLOCK),  
  -- ContractPricingDetails B (NOLOCK),@ProductBatchWithCounter C  
  --          WHERE A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId AND A.PrdId = C.Prdid AND B.PrdId = C.Prdid   
  --          GROUP BY A.PrdId ORDER BY A.PrdId  
             
  -- IF EXISTS(SELECT * FROM @ContractPrice)  
  -- BEGIN  
        
  --  SELECT DISTINCT PrdbatId,PriceId,Max(PriceCode) as PriceCode INTO #ProductBatchDetails   
  --  FROM ProductBatchDetails  
  --  GROUP BY PrdbatId,PriceId  
  --  INSERT INTO @ContractBatchPrice (ContractId,CtgMainId,PrdId,PrdBatId,PriceId,PriceCode)   
  --  SELECT Max(C.ContractId) as ContractId,D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId AS PriceId,  
  --  --CAST('' AS NVARCHAR(4000)) AS PriceCode  
  --  PriceCode  
  --  FROM  ContractPricingMaster D (NOLOCK)   
  --  INNER JOIN  ContractPricingDetails C (NOLOCK)   ON C.ContractId = D.ContractId  
  --  INNER JOIN  #ProductBatchDetails A (NOLOCK) ON A.PrdBatId = C.PrdBatId AND A.PriceId = C.PriceId  
  --  INNER JOIN @ContractPrice E  ON E.PrdBatId = C.PrdBatId AND E.PrdId = C.PrdId   
  --  GROUP BY D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId ,PriceCode  
     
  --     --INSERT INTO @ContractBatchPrice (ContractId,CtgMainId,PrdId,PrdBatId,PriceId,PriceCode)  
  --     --SELECT DISTINCT MAX(D.ContractId) AS ContractId,D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId AS PriceId,  
  --     --CAST('' AS NVARCHAR(4000)) AS PriceCode FROM ProductBatchDetails A (NOLOCK),  
  --     --ContractPricingDetails C (NOLOCK),ContractPricingMaster D (NOLOCK),@ContractPrice E   
  --     --WHERE A.PrdBatId = C.PrdBatId AND A.PriceId = C.PriceId AND C.ContractId = D.ContractId AND E.PrdId = C.PrdId   
  --     --AND E.PrdBatId = C.PrdBatId GROUP BY D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId      
     
  --     --UPDATE A SET A.PriceCode = D.PriceCode FROM @ContractBatchPrice A,ContractPricingDetails B WITH(NOLOCK),  
  --     --ContractPricingMaster C WITH(NOLOCK),ProductBatchDetails D WITH(NOLOCK) WHERE A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId   
  --     --AND A.CtgMainId = C.CtgMainId AND D.PrdBatId = A.PrdBatId AND A.ContractId = C.ContractId AND B.ContractId = C.ContractId   
  --     --UPDATE A SET A.PriceCode = D.PriceCode  
  --     --FROM @ContractBatchPrice A   
  --     --INNER JOIN ContractPricingDetails B WITH(NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId   
  --     --INNER JOIN ContractPricingMaster C WITH(NOLOCK) ON   A.CtgMainId = C.CtgMainId  AND A.ContractId = C.ContractId AND B.ContractId = C.ContractId and A.ContractId=B.ContractId  
  --     --INNER JOIN #ProductBatchDetails D WITH(NOLOCK) ON D.PrdBatId = A.PrdBatId   
         
  --     --select 'Botree',* from @ProductBatchPriceWithCounter  
  --     --select 'Software',* from @ContractBatchPrice  
  --  SELECT DISTINCT SlNo INTO #BatchCreation FROM BatchCreation A (NOLOCK)  
  --  INNER JOIN (SELECT MAX(BatchseqId)  as BatchseqId FROM BatchCreationMaster (NOLOCK))X  
  --  ON A.BatchSeqId=X.BatchSeqId  
     
  --     INSERT INTO @ProductBatchDetails (PrdId,PrdBatId,PriceId,PriceCode,NewBatchId,Slno,PrdBatDetailValue,NewPriceId)   
  --  SELECT DISTINCT A.PrdId,A.PrdBatId,A.PriceId,A.PriceCode,B.PrdBatId AS NewBatchId,PBD.Slno,PrdBatDetailValue,  
  --  DENSE_RANK ()OVER (ORDER BY A.PriceId,A.PrdbatId,B.PrdBatId)+ @OldPriceId AS NewPriceId   
  --  FROM @ContractBatchPrice A INNER JOIN @ProductBatchPriceWithCounter B   
  --  ON A.PrdId = B.PrdId  
  --  INNER JOIN ProductBatchDetails PBD WITH(NOLOCK) ON PBD.PrdBatId=A.PrdBatId and PBD.PriceId=A.PriceId   
  --  INNER JOIN #BatchCreation C WITH(NOLOCK) ON C.SlNo=PBD.Slno  
  --  ORDER BY A.PrdId,A.PrdBatId,A.PriceId,B.PrdBatId  
                             
  --  IF(SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=4  
  --  BEGIN  
  --   INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,  
  --      PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
  --   SELECT DISTINCT NewPriceId,NewBatchId,PriceCode,@BatSeqId,SlNo,PrdBatDetailValue,0,1,  
  --   1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)   
  --   FROM @ProductBatchDetails  
       
  --   UPDATE A SET A.PrdBatDetailValue = B.MRP FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B  
  --   WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 1  
       
  --   UPDATE A SET A.PrdBatDetailValue = B.ListPrice FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B  
  --   WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 2  
       
  --   UPDATE A SET A.PrdBatDetailValue = B.ClaimRate FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B  
  --   WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 4   
  --  END  
  --  ELSE IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=5  
  --  BEGIN  
  --   INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,  
  --   PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
  --   SELECT DISTINCT NewPriceId,NewBatchId,PriceCode,@BatSeqId,SlNo,PrdBatDetailValue,0,1,  
  --   1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)   
  --                  FROM @ProductBatchDetails  
  --                  UPDATE A SET A.PrdBatDetailValue = B.MRP FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B  
  --   WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 1  
       
  --   UPDATE A SET A.PrdBatDetailValue = B.ListPrice FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B  
  --   WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 2  
       
  --   UPDATE A SET A.PrdBatDetailValue = B.ClaimRate FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B  
  --   WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 4  
       
  --   UPDATE A SET A.PrdBatDetailValue = B.AddRate1 FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B  
  --   WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 5  
       
  --  END   
      
  --      IF EXISTS (SELECT * FROM @ProductBatchDetails)  
  --      BEGIN  
  --    INSERT INTO ContractPricingDetails(ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,  
  --    Availability,LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId)  
  --    SELECT DISTINCT ContractId,A.PrdId,NewBatchId,NewPriceId,Discount,FlatAmtDisc,  
  --    Availability,LastModBy,GETDATE(),AuthId,GETDATE(),CtgValMainId  
  --    FROM ContractPricingDetails A,@ProductBatchDetails B WHERE A.PrdId = B.PrdId   
  --    AND A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId  
  --   END   
      --UPDATE Counters SET CurrValue = (SELECT MAX(PriceId) FROM ProductBatchDetails)   
      --WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'       
  -- END  
  END  
 END  
   
 SELECT @NewPriceId=CurrValue FROM Counters (NOLOCK) WHERE TabName='ProductBatchDetails' AND FldName='PriceId'     
 IF @NewPriceId>@OldPriceId  
 BEGIN  
  IF EXISTS(SELECT * FROM Configuration(NOLOCK) WHERE ModuleId='BotreeRateForOldBatch'  
  AND ModuleName='Botree Product Batch Download' AND Status=1)  
  BEGIN  
   EXEC Proc_DefaultPriceUpdation @ExistPrdBatMaxId,@OldPriceId,1  
  END  
 END  
 IF EXISTS(SELECT * FROM ProductBatchDetails WHERE PriceId>=@OldPriceId)  
 BEGIN  
  EXEC Proc_DefaultPriceHistory 0,0,@NewPriceId,2,1  
 END  
 ---MOORTHI  START  
 IF @ExistPrdBatMaxId>0  
 BEGIN    
  SET @BatchTransfer=0  
  SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='BotreeAutoBatchTransfer'  
  IF @BatchTransfer=1  
  BEGIN  
   EXEC Proc_AutoBatchTransfer @ExistPrdBatMaxId,@Po_ErrNo = @Po_BatchTransfer OUTPUT  
   IF @Po_BatchTransfer=1  
   BEGIN  
    INSERT INTO Errorlog VALUES (1,'Cn2Cs_Prk_BLProductBatch','Product Batch-Auto Batch Transfer',  
    'Auto Batch Transfer is not done properly')              
    SET @Po_ErrNo=1      
   END  
  END  
 END   
 --END  
   
 UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y'   
 WHERE PrdCCode+'~'+PrdBatCode IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode  
 FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)  
 
-- Added By Mahesh on  17-02-2016
	IF EXISTS
	(
		select prdbatid,count(prdbatid)cnt from productbatchdetails where DefaultPrice=1
		group by prdbatid
		having count(prdbatid)>4
	)
	BEGIN		  
		select prdbatid,count(prdbatid)cnt into #abc from productbatchdetails where DefaultPrice=1
		group by prdbatid
		having count(prdbatid)>4
		select B.PrdBatId,MAX(Priceid)Priceid into #minPriceid from #abc A inner join ProductBatchDetails B ON A.PrdBatId=B.PrdBatId
		WHERE B.PriceCode not LIke '%SPL%'
		group by B.PrdBatId
		update A set DefaultPriceId=B.Priceid from ProductBatch A Inner JOin #minPriceid B ON A.PrdBatId=B.PrdBatId
		UPdate A set DefaultPrice=0 from ProductBatchDetails A Inner JOin #minPriceid B ON A.PrdBatId=B.PrdBatId
		UPdate A set DefaultPrice=1 from ProductBatchDetails A Inner JOin #minPriceid B ON A.PrdBatId=B.PrdBatId and A.PriceId=B.Priceid
	END
-- Till here	
 RETURN    
END
GO
IF EXISTS(SELECT * FROM Sysobjects WHERE Name = 'Proc_AutoBatchTransfer_Parle' AND Type = 'P')
DROP PROC Proc_AutoBatchTransfer_Parle
GO
/*
BEGIN TRANSACTION
select *from stockledger a where prdid = 2058 and TransDate = (select MAX(TransDate) from StockLedger where PrdId = a.PrdId and PrdBatId = a.PrdBatId)
EXEC Proc_AutoBatchTransfer_Parle 0
select *from stockledger a where prdid = 2058 and TransDate = (select MAX(TransDate) from StockLedger where PrdId = a.PrdId and PrdBatId = a.PrdBatId)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_AutoBatchTransfer_Parle
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_AutoBatchTransfer
* PURPOSE		: To do Batch Transfer automatically while downloading New Batch for Existing Product
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/02/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 				AS 	INT
	DECLARE @Trans				AS 	INT
	DECLARE @Tabname 			AS  NVARCHAR(100)
	DECLARE @DestTabname 		AS 	NVARCHAR(100)
	DECLARE @Fldname 			AS  NVARCHAR(100)
	
	DECLARE @PrdDCode 	        AS 	NVARCHAR(100)
	DECLARE @BatchCode			AS 	NVARCHAR(100)
	DECLARE @CmpBatchCode		AS 	NVARCHAR(100)	
	DECLARE @PriceCode			AS 	NVARCHAR(4000)		
	DECLARE @MnfDate			AS 	NVARCHAR(100)
	DECLARE @ExpDate			AS 	NVARCHAR(100)
	DECLARE @TaxGroupCode		AS 	NVARCHAR(100)
	DECLARE @Status				AS 	NVARCHAR(100)
	DECLARE	@BatchSeqCode 		AS 	NVARCHAR(100)
	DECLARE @RefCode           	AS 	NVARCHAR(100)
	DECLARE @PriceValue         AS 	NVARCHAR(100)	
	DECLARE @DefaultPrice       AS 	NVARCHAR(100)	  	
	DECLARE @ExistPrdDCode		AS 	NVARCHAR(100)  	
	DECLARE @ExistBatchCode		AS 	NVARCHAR(100)
	DECLARE @ExistPriceCode		AS 	NVARCHAR(100)  	
	
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
	DECLARE @SlNo	 			AS 	INT
	DECLARE @NoOfPrices 		AS 	INT
	DECLARE @ExistPrices 		AS 	INT
	DECLARE @DefaultPriceId 	AS 	INT
	DECLARE @ExistPriceId 		AS 	INT
	DECLARE @TransStr 			AS 	NVARCHAR(4000)
	DECLARE @ExistPrdBatMaxId	AS 	INT
	DECLARE @NewPrdBatMaxId		AS 	INT
	DECLARE @ContPrdId 			AS 	INT
	DECLARE @ContPrdBatId 		AS 	INT
	DECLARE @ContExistPrdBatId 	AS 	INT
	DECLARE @ContPriceId 		AS 	INT
	DECLARE @ContractId 		AS 	INT
	DECLARE @ContPriceCode		AS NVARCHAR(100)
	DECLARE @ContPrdBatId1		AS INT
	DECLARE @ContPriceId1		AS INT
	DECLARE @BatchTransfer		AS INT
	DECLARE @SalStock			AS INT
	DECLARE @UnSalStock			AS INT
	DECLARE @OfferStock			AS INT
	DECLARE @FromPrdBatId		AS INT
	DECLARE @FromPrdBatCode		AS NVARCHAR(200)
	DECLARE @ToPrdBatId			AS INT
	DECLARE @LcnId				AS INT
	DECLARE @Po_StkPosting		AS INT
	DECLARE @TransDate			AS DATETIME
	SET @BatchTransfer=0
	SELECT @TransDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	---->Needs to be changed
	SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='GENConfig000001'
	SET @Po_ErrNo=0
	SET @Exist=0
	SET @ExistPrdDCode=''	
	SET @ExistBatchCode=''
	SET @ExistPriceCode=''
	
	SET @Exist=0
	
	DECLARE Cur_ProductBatch CURSOR
	FOR 
	SELECT PrdId,MAX(PrdBatId) PrdBatId FROM ProductBatch GROUP BY PrdId
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	WHILE @@FETCH_STATUS=0
	BEGIN
		--SELECT @PrdId,@PrdBatId,@BatchCode
		DECLARE Cur_BatchTransfer CURSOR
		FOR SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
		FROM ProductBatchLocation PBL WHERE PBL.PrdId=@PrdId AND PBL.PrdBatId<>@PrdBatId
		AND ((PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih)+(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih)+(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre))>0
		OPEN Cur_BatchTransfer
		FETCH NEXT FROM Cur_BatchTransfer INTO @LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
		WHILE @@FETCH_STATUS=0
		BEGIN
			--SELECT @PrdId,@PrdBatId,@LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
			
			SET @Po_ErrNo=0
			
			IF @SalStock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 1,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 1,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 30,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 27,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END													
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
			
			IF @UnSalStock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 2,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 2,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 31,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 28,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END						
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
				
			IF @Offerstock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 3,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 3,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 32,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 29,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END						
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
			IF @Po_ErrNo>0
			BEGIN
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				VALUES(@FromPrdBatId,'','Error','Error')
			END
			FETCH NEXT FROM Cur_BatchTransfer INTO @LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
		END
		CLOSE Cur_BatchTransfer
		DEALLOCATE Cur_BatchTransfer
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	RETURN	
END
GO
IF NOT EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND B.xtype = 'U' 
AND B.name = 'Cn2Cs_Prk_SpecialDiscount' AND A.Name = 'ApplyOn')
BEGIN
    ALTER TABLE Cn2Cs_Prk_SpecialDiscount ADD ApplyOn VARCHAR(50) DEFAULT '' WITH VALUES
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'TempSpecialRateDiscountProduct')
DROP TABLE TempSpecialRateDiscountProduct
GO
CREATE TABLE [dbo].[TempSpecialRateDiscountProduct](
	[SlNo] [BIGINT] IDENTITY(1,1) NOT NULL,
	[CtgLevelName] [NVARCHAR](100) NULL,
	[CtgCode] [NVARCHAR](100) NULL,
	[RtrCode] [NVARCHAR](100) NULL,
	[PrdCCode] [NVARCHAR](100) NULL,
	[PrdBatCode] [NVARCHAR](100) NULL,
	[DiscPer] [NUMERIC](18, 2) NULL,
	[SpecialSellingRate] [NUMERIC](38, 6) NULL,
	[EffectiveFromDate] [DATETIME] NULL,
	[EffectiveToDate] [DATETIME] NULL,
	[CreatedDate] [DATETIME] NULL,
	[ApplyOn] [TINYINT] NULL,
	[TYPE] INT
) ON [PRIMARY]
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CalculateSpecialDiscountAftRate')
DROP PROCEDURE Proc_CalculateSpecialDiscountAftRate
GO
--EXEC Proc_CalculateSpecialDiscountAftRate
CREATE PROCEDURE [dbo].[Proc_CalculateSpecialDiscountAftRate]
AS  
BEGIN
     --Added by SAthishkumar Veeramani 2015/04/01
	 DECLARE @SplDiscountToAvoid TABLE
	 (
	   RetCategoryLevel       NVARCHAR(100),
	   RetCatLevelValue       NVARCHAR(100),
	   PrdCategoryLevel       NVARCHAR(100),
	   PrdCategoryLevelValue  NVARCHAR(100)
	 )    
     INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE (ApplyOn = '' OR ApplyOn IS NULL)
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Apply On','Apply On Should Not be Empty or Null-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE (ApplyOn = '' OR ApplyOn IS NULL)
     
     INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) NOT IN ('MRP','SELLINGRATE','PURCHASERATE')
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Apply On','Apply On Should Not be in MRP Or SELLINGRATE Or PURCHASERATE-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) NOT IN ('MRP','SELLINGRATE','PURCHASERATE')
     --Till Here
	 INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) IN ('MRP') AND ISNULL([Type],'')=''
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Type','Type Should Not be Empty For Appy On MRP-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) IN ('MRP') AND ISNULL([Type],'')=''
     
     INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) IN ('MRP') AND 
     UPPER(LTRIM(RTRIM(ISNULL([Type],'')))) NOT IN ('MARK DOWN','MARK UP')
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Type','Type Should be Mark Up/Mark Down For Appy On MRP-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) IN ('MRP') AND 
     UPPER(LTRIM(RTRIM(ISNULL([Type],'')))) NOT IN ('MARK DOWN','MARK UP')
     
     
	 EXEC Proc_GR_Build_PH  
	 TRUNCATE TABLE TempSpecialRateDiscountProduct
	 DELETE FROM Cn2Cs_Prk_SpecialDiscount where DownLoadFlag='Y'   
	 INSERT INTO TempSpecialRateDiscountProduct (CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,DiscPer,SpecialSellingRate,EffectiveFromDate,
     EffectiveToDate,CreatedDate,ApplyOn,[Type])
	 SELECT DISTINCT A.RetCategoryLevel,A.RetCatLevelValue,'ALL',ProductCode,PrdBatCode,DiscPer,
	 --PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100)) SplRate,
	 (CASE ApplyOn WHEN 1 THEN 
		 (CASE [Type] WHEN 1 THEN (PrdBatDetailValue*100/(100+DiscPer)) WHEN 2 THEN PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100))
			ELSE PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100))  END)	 
	 ELSE PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100)) END) AS SplRate,	 
	 EffFromDate,EffToDate,CreatedDate,ApplyOn,[Type]	 
	 FROM (  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.COMPANY_Code  
	 WHERE CP.PrdCategoryLevel='COMPANY' and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION   
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type] 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Category_Code  
	 WHERE CP.PrdCategoryLevel='Category'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Brand_Code  
	 WHERE CP.PrdCategoryLevel='Brand'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type] 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.PriceSlot_Code  
	 WHERE CP.PrdCategoryLevel='PriceSlot'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)  
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn ,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Flavor_Code  
	 WHERE CP.PrdCategoryLevel='Flavor'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.ProductCode  
	 WHERE CP.PrdCategoryLevel='Product'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)
	 UNION
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.ProductCode  
	 WHERE CP.DownloadFlag='D' AND NOT EXISTS (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
	 FROM @SplDiscountToAvoid SA WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue 
	 AND CP.PrdCategoryLevel = SA.PrdCategoryLevel AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue))A  
	 INNER JOIN Product P (NOLOCK) ON P.PrdId=A.PrdId and A.ProductCode=P.PrdCCode  
	 INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId  
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PB.PrdBatId  
	 INNER JOIN BatchCreation BC (NOLOCK) ON BC.SlNo=PBD.SLNo AND BC.SlNo = A.ApplyOn
	 --INNER JOIN Configuration C (NOLOCK) ON BC.SlNo = ISNULL(CAST(C.ConfigValue AS INT),0)
	 WHERE PBD.DefaultPrice=1 --AND C.ModuleId = 'SPLDISC'
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND name = 'Proc_ValidateTaxMapping')
DROP PROCEDURE Proc_ValidateTaxMapping
GO
--EXEC Proc_ValidateTaxMapping 0
CREATE PROCEDURE Proc_ValidateTaxMapping
(
	@Po_ErrNo INT OUTPUT
)
AS
/*************************************************************************************************
* PROCEDURE  : Proc_ValidateTaxMapping
* PURPOSE    : To Update the Taxgroup Code Product and Product Batch
* CREATED    : Sathishkumar Veeramani 2014/11/26
***************************************************************************************************
*
**************************************************************************************************/
BEGIN
SET NOCOUNT ON
	SET @Po_ErrNo=0
	DELETE FROM Etl_Prk_TaxMapping WHERE DownloadFlag = 'Y'
	
	CREATE TABLE #ToAvoidTaxGroup
	(
	  PrdCCode     NVARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AS,
	  TaxGrpCode   NVARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AS
	)
	
	--Product Code Validation
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) WHERE A.PrdCode = B.PrdCCode)
	AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Product','PrdCCode','Product Code Not Available-'+PrdCode FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) WHERE A.PrdCode = B.PrdCCode)
	AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping (NOLOCK) WHERE LTRIM(RTRIM(ISNULL(PrdCode,''))) = ''
	AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Product','PrdCCode','Product Code Should not be Empty or Null'+PrdCode
	FROM Etl_Prk_TaxMapping (NOLOCK) WHERE LTRIM(RTRIM(ISNULL(PrdCode,''))) = '' AND DownloadFlag = 'D'
	
	--Tax Group Code Validation
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT DISTINCT PrdGroup FROM TaxGroupSetting B (NOLOCK) WHERE A.TaxGroupCode = B.PrdGroup AND TaxGroup = 2)
	AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'TaxGroupSetting','PrdGroup','Product Tax Group Code Not Available-'+TaxGroupCode FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT DISTINCT PrdGroup FROM TaxGroupSetting B (NOLOCK) WHERE A.TaxGroupCode = B.PrdGroup AND TaxGroup = 2)
	AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping (NOLOCK) WHERE LTRIM(RTRIM(ISNULL(TaxGroupCode,''))) = ''
	AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'TaxGroupSetting','PrdGroup','Product Tax Group Code Should not be Empty or Null'+TaxGroupCode
	FROM Etl_Prk_TaxMapping (NOLOCK) WHERE LTRIM(RTRIM(ISNULL(TaxGroupCode,''))) = '' AND DownloadFlag = 'D'
	
	--Duplcate Check Multiple Tax Group Code in Single Product
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT A.PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping A (NOLOCK) INNER JOIN 
	(SELECT DISTINCT PrdCode,COUNT(DISTINCT TaxGroupCode) AS Counts FROM Etl_Prk_TaxMapping A (NOLOCK) WHERE
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup B WHERE A.PrdCode = B.PrdCCode AND A.TaxGroupCode = B.TaxGrpCode) 
	GROUP BY PrdCode HAVING COUNT(DISTINCT TaxGroupCode) > 1) B ON A.PrdCode = B.PrdCode
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Etl_Prk_TaxMapping','PrdCode','Same Product Should not Allow Multiple TaxGroup Code-'+A.PrdCode
	FROM Etl_Prk_TaxMapping A (NOLOCK) INNER JOIN (SELECT DISTINCT PrdCode,COUNT(DISTINCT TaxGroupCode) AS Counts 
	FROM Etl_Prk_TaxMapping A (NOLOCK) WHERE NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup B 
	WHERE A.PrdCode = B.PrdCCode AND A.TaxGroupCode = B.TaxGrpCode) GROUP BY PrdCode 
	HAVING COUNT(DISTINCT TaxGroupCode) > 1) B ON A.PrdCode = B.PrdCode	 	
	
	--Product Tax Group Code Updated
	UPDATE A SET A.TaxGroupId  = C.TaxGroupId FROM Product A (NOLOCK) 
	INNER JOIN Etl_Prk_TaxMapping B (NOLOCK) ON A.PrdCCode = B.PrdCode
	INNER JOIN TaxGroupSetting C (NOLOCK) ON B.TaxGroupCode = C.PrdGroup
	WHERE C.TaxGroup = 2 AND DownloadFlag = 'D' AND MapStatus = 1 AND
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup D WHERE B.PrdCode = D.PrdCCode AND B.TaxGroupCode = D.TaxGrpCode)
	
	--Product Batch Tax Group Code Updated
	UPDATE PB SET PB.TaxGroupId  = C.TaxGroupId FROM ProductBatch PB (NOLOCK)
	INNER JOIN Product A (NOLOCK) ON PB.PrdId = A.PrdId 
	INNER JOIN Etl_Prk_TaxMapping B (NOLOCK) ON A.PrdCCode = B.PrdCode
	INNER JOIN TaxGroupSetting C (NOLOCK) ON B.TaxGroupCode = C.PrdGroup
	WHERE C.TaxGroup = 2 AND DownloadFlag = 'D' AND MapStatus = 1 AND
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup D WHERE B.PrdCode = D.PrdCCode AND B.TaxGroupCode = D.TaxGrpCode)
		
	--Download Flag Change
	UPDATE A SET A.DownloadFlag = 'Y' FROM Etl_Prk_TaxMapping A (NOLOCK) 
	INNER JOIN TaxGroupSetting B (NOLOCK) ON A.TaxGroupCode = B.PrdGroup 
	INNER JOIN Product C (NOLOCK) ON A.PrdCode = C.PrdCCode AND B.TaxGroupId = C.TaxGroupId 
	WHERE TaxGroup = 2 AND DownloadFlag = 'D'
	
RETURN
END
GO
IF EXISTS(SELECT * FROM Sys.objects where name='Proc_RptLoadSheetItemWiseParle' and type='P')
DROP PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
--EXEC Proc_RptLoadSheetItemWiseParle 251,1,0,'Parle',0,0,1    
CREATE PROCEDURE Proc_RptLoadSheetItemWiseParle    
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
* CREATED BY : Gunasekaran    
* CREATED DATE : 18/07/2007    
* NOTE  :    
* MODIFIED :    
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
* {date} {developer}  {brief modification description}    
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012    
* 02/07/2013 Jisha Mathew PARLECS/0613/008     
* 11/11/2013 Jisha Mathew Bug No:30616    
*************************************************************/    
SET NOCOUNT ON    
BEGIN    
 DECLARE @NewSnapId  AS INT    
 DECLARE @DBNAME  AS  nvarchar(50)    
 DECLARE @TblName  AS nvarchar(500)    
 DECLARE @TblStruct  AS nVarchar(4000)    
 DECLARE @TblFields  AS nVarchar(4000)    
 DECLARE @sSql  AS  nVarChar(4000)    
 DECLARE @ErrNo   AS INT    
 DECLARE @PurDBName AS nVarChar(50)    
 --Added by Sathishkumar Veeramani 2013/04/25    
 DECLARE @Prdid AS INT    
 DECLARE @PrdCode AS Varchar(50)    
 DECLARE @PrdBatchCode AS Varchar(50)    
 DECLARE @UOMSalId AS INT    
 DECLARE @BaseQty AS INT    
 DECLARE @FUOMID AS INT    
 DECLARE @FCONVERSIONFACTOR AS INT    
 DECLARE @StockOnHand AS INT    
 DECLARE @Converted AS INT    
 DECLARE @Remainder AS INT    
 DECLARE @COLUOM AS VARCHAR(50)    
 DECLARE @Sql AS VARCHAR(5000)    
 DECLARE @SlNo AS INT    
 --Till Here    
 --Jisha    
 DECLARE @TotConverted AS INT    
 DECLARE @TotRemainder AS INT     
 DECLARE @TotalQty as INT     
 --    
     
 --Filter Variable    
 DECLARE @FromDate    AS DATETIME    
 DECLARE @ToDate      AS DATETIME    
 DECLARE @VehicleId     AS  INT    
 DECLARE @VehicleAllocId AS INT    
 DECLARE @SMId   AS INT    
 DECLARE @DlvRouteId AS INT    
 DECLARE @RtrId   AS INT    
 DECLARE @UOMId   AS INT    
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
     
 CREATE TABLE #RptLoadSheetItemWiseParle1    
 (    
   [SalId]      INT,    
   [BillNo]     NVARCHAR (100),    
   [PrdId]               INT,    
   [PrdBatId]     INT,    
   [Product Code]        NVARCHAR (100),    
   [Product Description] NVARCHAR(150),    
  [PrdCtgValMainId]   INT,     
   [CmpPrdCtgId]    INT,    
   [Batch Number]        NVARCHAR(50),    
   [MRP]      NUMERIC (38,6) ,    
   [Selling Rate]    NUMERIC (38,6) ,    
   [Billed Qty]          NUMERIC (38,0),    
   [Free Qty]            NUMERIC (38,0),    
   [Return Qty]          NUMERIC (38,0),    
   [Replacement Qty]     NUMERIC (38,0),    
   [Total Qty]           NUMERIC (38,0),    
   [PrdWeight]     NUMERIC (38,4),    
   [PrdSchemeDisc]    NUMERIC (38,2),    
   [GrossAmount]    NUMERIC (38,2),    
   [TaxAmount]     NUMERIC (38,2),    
   [NetAmount]     NUMERIC (38,2),    
   [TotalBills]    NUMERIC (38,0),    
   [TotalDiscount]    NUMERIC (38,2),    
   [OtherAmt]     NUMERIC (38,2),    
   [AddReduce]     NUMERIC (38,2),    
   [Damage]              NUMERIC (38,2),    
   [BX]                  NUMERIC (38,0),    
   [PB]                  NUMERIC (38,0),    
   [JAR]      NUMERIC (38,0),    
   [PKT]                 NUMERIC (38,0),    
   [CN]      NUMERIC (38,0),    
   [GB]                  NUMERIC (38,0),    
   [ROL]                 NUMERIC (38,0),    
   [TOR]                 NUMERIC (38,0),    
   [CTN]         NUMERIC (38,0),    
   [TN]         NUMERIC (38,0),    
   [CAR]         NUMERIC (38,0),    
   [PC]         NUMERIC (38,0),    
   [TotalQtyBX]          NUMERIC (38,0),    
   [TotalQtyPB]          NUMERIC (38,0),    
   [TotalQtyPKT]         NUMERIC (38,0),    
   [TotalQtyJAR]         NUMERIC (38,0),    
   [TotalQtyCN]    NUMERIC (38,0),    
   [TotalQtyGB]          NUMERIC (38,0),    
   [TotalQtyROL]         NUMERIC (38,0),    
   [TotalQtyTOR]         NUMERIC (38,0),    
   [TotalQtyCTN]         NUMERIC (38,0),    
   [TotalQtyTN]         NUMERIC (38,0),    
   [TotalQtyCAR]         NUMERIC (38,0),    
   [TotalQtyPC]         NUMERIC (38,0),       
 )    
     
 --IF @Pi_GetFromSnap = 0  --To Generate For New Report Data    
 --BEGIN    
  IF @FromBillNo <> 0 Or @ToBillNo <> 0    
  BEGIN    
   INSERT INTO #RptLoadSheetItemWiseParle1([SalId],[BillNo],[PrdId],[PrdBatId],[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],    
    [Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],    
    [TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TN],[CAR],[PC],    
    [TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],[TotalQtyCTN],    
    [TotalQtyTN],[TotalQtyCAR],[TotalQtyPC])--select * from RtrLoadSheetItemWise    
     
   SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,    
   [PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],    
   dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],    
   Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,    
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM RtrLoadSheetItemWise RI    
   LEFT OUTER JOIN SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId    
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
--       RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))    
     
 GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],    
 NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId    
  END     
  ELSE    
  BEGIN    
   INSERT INTO #RptLoadSheetItemWiseParle1([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],    
     [Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],    
     [TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TN],[CAR],[PC],    
     [TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],    
     [TotalQtyCTN],[TotalQtyTN],[TotalQtyCAR],[TotalQtyPC])    
       
   SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),    
   BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,    
   dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],    
   ISNULL((SUM([TaxAmount])+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,    
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM RtrLoadSheetItemWise RI --select * from RtrLoadSheetItemWise    
   LEFT OUTER JOIN SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId    
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
   AND [SalInvDate] BETWEEN @FromDate AND @ToDate    
      
   GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,    
   GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId    
   ORDER BY PrdDCode    
       
         
  END      
     
  UPDATE #RptLoadSheetItemWiseParle1 SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle1)    
-----Added By Sathishkumar Veeramani OtherCharges    
      ---Changed By Jisha for Bug No:30616    
               --SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2    
               SELECT @OtherCharges = ISNULL((SUM(B.TaxAmount)+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0)     
               FROM SalesInvoice A WITH (NOLOCK),RtrLoadSheetItemWise B WITH (NOLOCK)    
               LEFt OUTER JOIN SalesInvoiceProduct C WITH (NOLOCK) ON B.SalId = C.SalId     
    AND B.PrdId=C.PrdId And B.PrdBatId=C.PrdBatId    
               WHERE A.SalId = B.SalId AND B.SalInvDate Between @FromDate and @ToDate AND DlvSts = 2 AND UsrID = @Pi_UsrId AND RptId = @Pi_RptId    
               AND                  
   (B.VehicleId = (CASE @VehicleId WHEN 0 THEN B.VehicleId ELSE 0 END) OR    
       B.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )    
       
    AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR    
       Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )    
       
    AND (B.SMId=(CASE @SMId WHEN 0 THEN B.SMId ELSE 0 END) OR    
       B.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))    
       
    AND (B.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN B.DlvRMId ELSE 0 END) OR    
       B.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )    
       
    AND (B.RtrId = (CASE @RtrId WHEN 0 THEN B.RtrId ELSE 0 END) OR    
       B.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )    
   AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR    
     B.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )    
           
      
               UPDATE #RptLoadSheetItemWiseParle1 SET AddReduce = @OtherCharges     
-------Added By Sathishkumar Veeramani Damage Goods Amount---------     
   UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle1 R INNER JOIN    
  (SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP     
   WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B    
   ON R.SalId = B.SalId AND R.PrdId = B.PrdId     
  AND R.PrdBatId = B.PrdBatId    
      
  Update #RptLoadSheetItemWiseParle1 Set [Batch Number] = '',PrdBatId = 0 --Code Added by Muthuvelsamy R for DCRSTPAR0510    
------Till Here--------------------      
----Added By Jisha On 02/07/2013 for PARLECS/0613/008     
SELECT 0 AS [SalId],'' AS BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],    
[Batch Number] AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],SUM([Billed Qty]) as [Billed Qty],SUM([Free Qty]) as [Free Qty],SUM([Return Qty]) as [Return Qty],    
SUM([Replacement Qty]) AS [Replacement Qty],SUM([Total Qty]) AS [Total Qty],SUM(PrdWeight) AS PrdWeight,SUM(PrdSchemeDisc) AS PrdSchemeDisc,    
SUM(GrossAmount) AS GrossAmount,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,TotalBills,SUM(TotalDiscount) AS TotalDiscount,    
SUM(OtherAmt) AS OtherAmt,SUM(DISTINCT AddReduce) AS Addreduce,SUM([Damage])AS [Damage],0 AS[BX],0 AS [PB],0 AS [JAR],0 AS [PKT],0 AS [CN],    
0 AS [GB],0 AS [ROL],0 AS [TOR],0 AS [CTN],0 AS [TN],0 AS [CAR],0 AS [PC],    
0 AS TotalQtyBX,0 AS TotalQtyPB,0 AS TotalQtyPKT,0 AS TotalQtyJAR,0 AS [TotalQtyCN],0 AS [TotalQtyGB],0 AS [TotalQtyROL],0 AS [TotalQtyTOR],    
0 AS [TotalQtyCTN],0 AS [TotalQtyTN],0 AS [TotalQtyCAR],0 AS [TotalQtyPC]    
INTO #RptLoadSheetItemWiseParle FROM #RptLoadSheetItemWiseParle1    
GROUP BY PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],TotalBills    
-----    
--Added by Sathishkumar Veeramani 2013/04/25      
 DECLARE CUR_UOMQTY CURSOR     
 FOR    
  SELECT P.PrdId,Rpt.[Product Code],[Batch Number],SUM([Billed Qty]) AS [Billed Qty],SUM([Total Qty]) AS [Total Qty] FROM #RptLoadSheetItemWiseParle Rpt WITH (NOLOCK)    
  INNER JOIN Product P WITH (NOLOCK) ON  Rpt.PrdId=P.PrdId GROUP BY P.PrdId,Rpt.[Product Code],[Batch Number]      
 OPEN CUR_UOMQTY    
 FETCH NEXT FROM CUR_UOMQTY INTO @PrdId,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty    
 WHILE @@FETCH_STATUS=0    
 BEGIN     
   SET @Converted=0    
   SET @Remainder=0       
   SET @TotConverted=0    
   SET @TotRemainder=0        
   DECLARE CUR_UOMGROUP CURSOR    
   FOR     
   SELECT DISTINCT UOMID,CONVERSIONFACTOR FROM (    
   SELECT A.UOMID,CONVERSIONFACTOR FROM UOMMASTER A WITH (NOLOCK)     
   INNER JOIN UOMGROUP B WITH (NOLOCK) ON A.UomId = B.UomId INNER JOIN PRODUCT C WITH (NOLOCK)    
   ON C.UOMGROUPID=B.UOMGROUPID WHERE PRDID=@PrdId AND A.UOMCODE IN ('BX','GB','CN','PB','JAR','TOR','PKT','ROL','CTN','TN','PC','CAR')) UOM ORDER BY CONVERSIONFACTOR DESC     
   OPEN CUR_UOMGROUP    
   FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR    
   WHILE @@FETCH_STATUS=0    
   BEGIN     
     SELECT @COLUOM=UOMCODE FROM UomMaster WITH (NOLOCK) WHERE UOMID=@FUOMID    
     IF @BaseQty >= @FCONVERSIONFACTOR    
     BEGIN    
      SET @Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)    
      SET @Remainder=CAST(@BaseQty%@FCONVERSIONFACTOR AS INT)    
      SET @BaseQty=@Remainder           
          
      SET @Sql='UPDATE #RptLoadSheetItemWiseParle  SET [' + @COLUOM +']='+ CAST(ISNULL(@Converted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+''''     
      EXEC(@Sql)    
     END     
     ELSE      
     BEGIN    
      SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [' + @COLUOM +']='+ CAST(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+''''     
      EXEC(@Sql)    
     END    
     ----Added By Jisha On 02/07/2013 for PARLECS/0613/008     
     IF @TotalQty >= @FCONVERSIONFACTOR    
     BEGIN          
      SET @TotConverted=CAST(@TotalQty/@FCONVERSIONFACTOR as INT)    
      SET @TotRemainder=CAST(@TotalQty%@FCONVERSIONFACTOR AS INT)    
      SET @TotalQty=@TotRemainder            
     
      SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM + ']= '+ CAST(ISNULL(@TotConverted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+''''     
      EXEC(@Sql)    
     END     
     ELSE      
     BEGIN    
      SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM +']='+ Cast(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+''''     
      EXEC(@Sql)    
     END         
     --         
   FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR    
   END     
   CLOSE CUR_UOMGROUP    
   DEALLOCATE CUR_UOMGROUP    
   SET @BaseQty=0    
   SET @TotalQty=0    
 FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty    
 END     
 CLOSE CUR_UOMQTY    
 DEALLOCATE CUR_UOMQTY    
------SELECT [PrdId],[PrdBatId],[Product Code],[Product Description],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],    
------[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR]    
------FROM #RptLoadSheetItemWiseParle    
 ---Commented By Jisha on 02/07/2013 for PARLECS/0613/008    
 ----UPDATE A SET A.TotalQtyBX = Z.TotalBox,A.TotalQtyPB = Z.TotalPouch,A.TotalQtyPKT = Z.TotalPacks FROM #RptLoadSheetItemWiseParle A WITH (NOLOCK)    
 ----INNER JOIN (SELECT PrdID,PrdBatId,SUM(BX) AS TotalBox,SUM(PB)+SUM(JAR) AS TotalPouch,SUM(PKT) AS TotalPacks     
 ----FROM #RptLoadSheetItemWiseParle WITH (NOLOCK)GROUP BY PrdID,PrdBatId) Z    
 ----ON A.PrdId = Z.PrdId AND A.PrdBatId = Z.PrdBatId    
--Till Here    
 --Check for Report Data    
    SELECT 0 AS [SalId],'' AS BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],    
    0 AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],([BX]+[GB]) AS BilledQtyBox,(([PB])+([JAR]+[CN]+[TOR]+[TN]+[CAR])) AS BilledQtyPouch,    
    ([PKT]+[ROL]+[CTN]+[PC]) AS BilledQtyPack,SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBX+TotalQtyGB) AS TotalQtyBOX,    
    SUM(TotalQtyPB+TotalQtyJAR+TotalQtyCN+TotalQtyTOR+TotalQtyTN+TotalQtyCAR) AS TotalQtyPouch,SUM(TotalQtyPKT+TotalQtyROL+TotalQtyCTN+TotalQtyPC) AS TotalQtyPack,    
 SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM([PrdWeight]) AS [PrdWeight],    
 SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) As PrdSchemeDisc,    
 SUM(TaxAmount) AS TaxAmount,SUM(NETAMOUNT) as NETAMOUNT,TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],    
 SUM([OtherAmt]) AS [OtherAmt],SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage] INTO #Result    
 FROM #RptLoadSheetItemWiseParle GROUP BY PrdId,[Product Code],[Product Description],[MRP],TotalBills,[PrdCtgValMainId],[CmpPrdCtgId],    
 [BX],[PB],[JAR],[PKT],[GB],[CN],[TOR],[ROL],[TN],[CAR],[CTN],[PC]    
 ORDER BY [Product Description]    
     
     
         
 Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId    
 INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)    
 SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result    
 SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],    
  MRP,MAX([Selling Rate]) AS [Selling Rate],    
  SUM(BilledQtyBox) AS BilledQtyBox,SUM(BilledQtyPouch) AS BilledQtyPouch,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],    
  SUM(TotalQtyBox) AS TotalQtyBox,SUM(TotalQtyPouch) AS TotalQtyPouch,SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],    
  SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],    
  SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,    
  SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage]     
  INTO #TempLoadingSheet FROM #Result GROUP BY [SalId],BillNo,PrdId,[Product Code],[PRoduct Description],MRP,TotalBills    
  ORDER BY [Product Code]    
  SELECT * FROM #TempLoadingSheet    
 IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)      
 BEGIN    
  IF EXISTS (Select [Name] From SysObjects Where [Name]='RptLoadSheetItemWiseParle_Excel' And XTYPE='U')    
  Drop Table RptLoadSheetItemWiseParle_Excel    
     SELECT * INTO RptLoadSheetItemWiseParle_Excel FROM #TempLoadingSheet ORDER BY [Product Code]    
     select * from RptLoadSheetItemWiseParle_Excel  
 END     
END
GO
If Exists (select * from Sysobjects where name='Fn_ReturnBilledProductDt'  and Xtype in ('TF','F'))
Drop Function Fn_ReturnBilledProductDt
Go
Create FUNCTION Fn_ReturnBilledProductDt(@Pi_SchId INT,@Pi_SlabId INT,@Pi_SchType INT,@Pi_UserId INT,@Pi_TransId INT)  
RETURNS @BilledProduct TABLE  
 (  
  PrdDcode  nVarChar(100),  
  PrdBatCode  nVarChar(100),  
  SchemeOnQty Numeric(38,0),  
  SchemeOnAmount Numeric(38,2),  
  SchemeOnKg Numeric(38,2),  
  SchemeOnLitre Numeric(38,2),  
  PrdId  Int,  
  PrdBatId Int  
 )  
AS  
BEGIN  
/*********************************  
* FUNCTION: Fn_ReturnBilledProduct  
* PURPOSE: Returns the Billed Product Details for the Selected Scheme  
* NOTES:  
* CREATED: Thrinath Kola 24-04-2007  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
IF @Pi_SchType=0 OR @Pi_SchType=5  
BEGIN  
 INSERT INTO @BilledProduct (PrdDcode,PrdBatCode,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,PrdId,PrdBatId)  
 SELECT c.PrdDcode,E.PrdBatCode,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,  
  ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000  
  WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,  
  ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000  
  WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,  
  C.PrdId,A.PrdBatId  
  FROM BilledPrdHdForScheme A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON  
  A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End  
  INNER JOIN Product C ON A.PrdId = C.PrdId  
  INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId  
  INNER JOIN ProductBatch E ON E.PrdId = C.PrdId AND E.PrdBatId = A.PrdBatId  
  WHERE A.Usrid = @Pi_UserId AND A.TransId = @Pi_TransId  
  GROUP BY C.PrdDcode,E.PrdBatCode,D.PrdUnitId,C.PrdId,A.PrdBatId  
END  
ELSE IF @Pi_SchType=1   
BEGIN  
 INSERT INTO @BilledProduct (PrdDcode,PrdBatCode,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,PrdId,PrdBatId)  
 SELECT c.PrdDcode,E.PrdBatCode,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,  
  ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000  
  WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,  
  ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000  
  WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,  
  C.PrdId,A.PrdBatId  
  FROM BilledPrdHdForScheme A (NOLOCK) INNER JOIN Fn_ReturnSchemeAnotherProduct(@Pi_SchId,@Pi_SlabId) B ON  
  A.PrdId = B.PrdId --AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End  
  INNER JOIN Product C ON A.PrdId = C.PrdId  
  INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId  
  INNER JOIN ProductBatch E ON E.PrdId = C.PrdId AND E.PrdBatId = A.PrdBatId  
  WHERE A.Usrid = @Pi_UserId AND A.TransId = @Pi_TransId  
  GROUP BY C.PrdDcode,E.PrdBatCode,D.PrdUnitId,C.PrdId,A.PrdBatId  
END  
RETURN  
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Cn2Cs_PurchaseReceipt' and Xtype='P')
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
* PROCEDURE : Proc_Cn2Cs_PurchaseReceipt  
* PURPOSE : To Insert the records FROM Console into Temp Tables  
* SCREEN : Console Integration-PurchaseReceipt  
* CREATED BY: Nandakumar R.G On 03-05-2010  
* MODIFIED :  
* DATE      AUTHOR     DESCRIPTION  
14/08/2013 Murugan.R Logistic Material Management  
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
 DECLARE @ErrStatus   INT  
 DECLARE @BatchNo   NVARCHAR(200)  
 DECLARE @ProductCode  NVARCHAR(100)  
 DECLARE @ListPrice   NUMERIC(38,6)  
 DECLARE @FreeSchemeFlag  NVARCHAR(5)  
 DECLARE @CompInvNo   NVARCHAR(25)  
 DECLARE @UOMCode   NVARCHAR(25)  
 DECLARE @Qty    INT  
 DECLARE @PurchaseDiscount NUMERIC(38,6)  
 DECLARE @VATTaxValue  NUMERIC(38,6)  
 DECLARE @SchemeRefrNo  NVARCHAR(25)  
 DECLARE @SupplierCode  NVARCHAR(30)  
 DECLARE @TransporterCode NVARCHAR(30)  
 DECLARE @POUOM    INT  
 DECLARE @RowId    INT  
 DECLARE @LineLvlAmt   NUMERIC(38,6)  
 DECLARE @QtyInKg   NUMERIC(38,6)  
 DECLARE @ExistCompInvNo  NVARCHAR(25)  
 DECLARE @FreightCharges  NUMERIC(38,6)  
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
 -- INSERT INTO InvToAvoid(CmpInvNo)  
 -- SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 -- WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))  
    
 -- INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
 -- SELECT DISTINCT 1,'Purchase Receipt','Invoice UOM','UOM:'+UOMCode+' is not available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 -- WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))  
 --END  
 IF EXISTS (SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode NOT IN (SELECT PrdCCode+'~'+UomCode    
 FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId))  
 BEGIN  
   INSERT INTO InvToAvoid(CmpInvNo)  
   SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode NOT IN (SELECT PrdCCode+'~'+UomCode    
   FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId)  
     
   INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT 1,'Purchase Receipt',PRODUCTCODE+'Product UOM','UOMCode:'+UOMCode+' is not available for Invoice:'+CompInvNo   
   FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode  NOT IN (SELECT PrdCCode+'~'+UomCode    
   FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId)  
 END   
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
 -- Eliminated Duplicate records insertion on 02/03/2015
 SET @ExistCompInvNo=0  
 DECLARE Cur_Purchase CURSOR  
 FOR  
 SELECT DISTINCT ProductCode,BatchNo,ListPriceNSP,  
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
--  IF @ExistCompInvNo<>@CompInvNo  
--  BEGIN  
--   SET @ExistCompInvNo=@CompInvNo  
--   SET @RowId=2  
--  END  
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
--   INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])  
--   VALUES(@CompInvNo,@RowId,'E',@QtyInKg)  
  END  
  --To insert into ETL_Prk_PurchaseReceiptClaim  
  IF(@FreeSchemeFlag='1')  
  BEGIN  
   INSERT INTO ETL_Prk_PurchaseReceiptClaim([Company Invoice No],[Type],[Ref No],[Product Code],  
   [Batch Code],[Qty],[Stock Type],[Amount],FreightAmt)  
   VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0,@FreightCharges)  
  END  
--  SET @RowId=@RowId+1  
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
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptStockandSalesVolumeParle' AND XTYPE='P')
DROP PROCEDURE Proc_RptStockandSalesVolumeParle
Go
--EXEC Proc_RptStockandSalesVolumeParle 236,2,0,'CKProduct',0,0,1
CREATE PROCEDURE Proc_RptStockandSalesVolumeParle
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
		PrdDCode			NVARCHAR(50),  
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
		If Exists (Select [Name] From SysObjects Where [Name]='RptStockandSalesVolumeParle_Excel' And XTYPE='U')
		Drop Table RptStockandSalesVolumeParle_Excel
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
					INTO RptStockandSalesVolumeParle_Excel FROM #RptStockandSalesVolume_Parle RV 
					INNER JOIN #PrdUomAll P On RV.PrdId=P.PrdId
					Group By RV.PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
							 LcnName Order By PrdDcode
		END 
		
	RETURN  
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Cn2Cs_Prk_RetailerApproval' and Xtype='U')
DROP TABLE Cn2Cs_Prk_RetailerApproval
GO
CREATE TABLE Cn2Cs_Prk_RetailerApproval(
	[DistCode]		NVARCHAR(200),
	[RtrCode]		NVARCHAR(100),
	[CmpRtrCode]	NVARCHAR(100),
	[RtrChannelCode]NVARCHAR(100),
	[RtrGroupCode]	NVARCHAR(100),
	[RtrClassCode]	NVARCHAR(100),
	[Status]		NVARCHAR(100),
	[KeyAccount]	NVARCHAR(100),
	[DownLoadFlag]	NVARCHAR(10),
	[Approved]		NVARCHAR(100),
	[CreatedDate]	DATETIME
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_RetailerApproval' and XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_RetailerApproval
GO
/*
BEGIN TRANSACTION
delete from errorlog
EXEC Proc_Cn2Cs_RetailerApproval 0
select Approved,rtrStatus,* from retailer where rtrCode in ('1')
select * from Retailermarket where RtrId=35
select * from Cn2Cs_Prk_RetailerApproval
Select * from Retailer_history
--select * from Retailer_history_track
Select * from Errorlog
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_RetailerApproval
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_RetailerApproval
* PURPOSE		: To Change the Retailer Status,Classification
* CREATED		: Nandakumar R.G
* CREATED DATE	: 05/03/2010
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
	DECLARE @CmpRtrCode  	NVARCHAR(200)
	DECLARE @RtrClassCode  	NVARCHAR(200)
	DECLARE @RtrChannelCode	NVARCHAR(200)
	DECLARE @RtrGroupCode	NVARCHAR(200)
	DECLARE @Status  		NVARCHAR(200)
	DECLARE @KeyAcc  		NVARCHAR(200)
	DECLARE @StatusId  		INT
	DECLARE @RtrId  		INT
	DECLARE @RtrClassId  	INT
	DECLARE @CtgLevelId  	INT
	DECLARE @CtgMainId  	INT	
	DECLARE @KeyAccId		INT
	DECLARE @Pi_UserId  	INT	
	DECLARE @CtgClassMainId INT
	-- Approved
	DECLARE @Approved       NVARCHAR(200)
	DECLARE @ApprovedId		INT
	-- Till here
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_RetailerApproval'
	SET @Pi_UserId=1
	
	
	DECLARE Cur_RetailerApproval CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([RtrCode])),''),ISNULL(LTRIM(RTRIM([CmpRtrCode])),''),ISNULL(LTRIM(RTRIM([RtrChannelCode])),''),ISNULL(LTRIM(RTRIM([RtrGroupCode])),''),
	ISNULL(LTRIM(RTRIM([RtrClassCode])),''),ISNULL(LTRIM(RTRIM([Status])),'Active'),ISNULL(LTRIM(RTRIM([KeyAccount])),'Yes'),
	CASE WHEN LEN(ISNULL(LTRIM(RTRIM(UPPER(Approved))),''))=0 THEN 'PENDING' ELSE UPPER(Approved) END
	FROM Cn2Cs_Prk_RetailerApproval WHERE [DownLoadFlag] ='D'
	OPEN Cur_RetailerApproval
	FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,@Status,@KeyAcc,@Approved
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Po_ErrNo=0
		IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode)
		BEGIN
			SET @ErrDesc = 'Retailer Code:'+@RtrCode+'does not exists'
			INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
			SET @RtrId=0
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode			
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
		IF UPPER(LTRIM(RTRIM(@KeyAcc)))=UPPER('YES')
		BEGIN
			SET @KeyAccId=1	
		END
		ELSE
		BEGIN
			SET @KeyAccId=0
		END

		-- Approved 		
		IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('PENDING')
		BEGIN
			SET @ApprovedId=0	
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('APPROVED')
		BEGIN
			SET @ApprovedId=1
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Approved)))=UPPER('REJECTED')
		BEGIN
		    SET @ApprovedId=2
		END
		-- Till here
			
		IF @Po_ErrNo=0
		BEGIN
			IF @ApprovedID <>2
				Begin
				--UPDATE Retailer SET RtrStatus=@Status,Approved=1,RtrKeyAcc=@KeyAccId WHERE RtrId=@RtrId
				UPDATE Retailer SET RtrStatus=@Status,Approved=@ApprovedId,RtrKeyAcc=@KeyAccId WHERE RtrId=@RtrId
				
				SET @sSql='UPDATE Retailer SET RtrStatus='+CAST(@Status AS NVARCHAR(100))+',RtrKeyAcc='+CAST(@KeyAccId AS NVARCHAR(100))+
				',Approved = '+CAST(@Approved As NVARCHAR(300))+'WHERE RtrId='+CAST(@RtrId AS NVARCHAR(100))+''
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
				--Delete from Retailer_history where RtrId= @RtrId
			END
			--Else
			--Begin
				--Declare @Cnt INT
				
				--Select @Cnt = Count(*) from Retailer_history(NOLOCK) Where RtrId = @RtrId
				--If (@Cnt >= 1)
				--Begin
					
					--if object_id('tempdb..#R') is not null
					--drop table #R
					
					--With Dup
					--as
					--(
					--	Select Row_Number() Over (Order by LModDate)SLNO,*  From Retailer_history(NOLOCK) Where RtrId = @Rtrid
					--)Select Top 1 * Into #R from Dup 
					
					
					--Update Retailer Set RtrName	=	A.RtrName,  RtrAdd1	=	A.RtrAdd1, RtrAdd2	=	A.RtrAdd2, RtrAdd3	=	A.RtrAdd3, RtrPinNo	=	A.RtrPinNo,
					--RtrPhoneNo	=	A.RtrPhoneNo, RtrEmailId	=	A.RtrEmailId, RtrContactPerson	=	A.RtrContactPerson, RtrKeyAcc	=	A.RtrKeyAcc,
					--RtrCovMode	=	A.RtrCovMode, RtrRegDate	=	A.RtrRegDate, RtrDayOff	=	A.RtrDayOff, RtrTaxable	=	A.RtrTaxable,
					--RtrTaxType	=	A.RtrTaxType, RtrTINNo	=	A.RtrTINNo, RtrCSTNo	=	A.RtrCSTNo, RtrDepositAmt	=	A.RtrDepositAmt, RtrCrBills	=	A.RtrCrBills,
					--RtrCrLimit	=	A.RtrCrLimit, RtrCrDays	=	A.RtrCrDays, RtrCashDiscPerc	=	A.RtrCashDiscPerc, RtrCashDiscCond	=	A.RtrCashDiscCond, RtrCashDiscAmt	=	A.RtrCashDiscAmt,
					--RtrLicNo	=	A.RtrLicNo, RtrLicExpiryDate	=	A.RtrLicExpiryDate, RtrDrugLicNo	=	A.RtrDrugLicNo, RtrDrugExpiryDate	=	A.RtrDrugExpiryDate, 
					--RtrPestLicNo	=	A.RtrPestLicNo, RtrPestExpiryDate	=	A.RtrPestExpiryDate, GeoMainId	=	A.GeoMainId, RMId	=	A.RMId, VillageId	=	A.VillageId,
					--RtrShipId	=	A.RtrShipId, TaxGroupId	=	A.TaxGroupId, RtrResPhone1	=	A.RtrResPhone1, RtrResPhone2	=	A.RtrResPhone2, RtrOffPhone1	=	A.RtrOffPhone1,
					--RtrOffPhone2	=	A.RtrOffPhone2, RtrDOB	=	A.RtrDOB, RtrAnniversary	=	A.RtrAnniversary, RtrRemark1	=	A.RtrRemark1, RtrRemark2	=	A.RtrRemark2,
					--RtrRemark3	=	A.RtrRemark3, CoaId	=	A.CoaId, RtrOnAcc	=	A.RtrOnAcc, RtrType	=	A.RtrType, RtrFrequency	=	A.RtrFrequency, RtrCrBillsAlert	=	A.RtrCrBillsAlert,
					--RtrCrLimitAlert	=	A.RtrCrLimitAlert, RtrCrDaysAlert	=	A.RtrCrDaysAlert, RtrRlStatus	=	A.RtrRlStatus, Availability	=	A.Availability,
					--LastModBy	=	A.LastModBy, LastModDate	=	A.LastModDate, AuthId	=	A.AuthId, AuthDate	=	A.AuthDate, XMLUpload	=	A.XMLUpload, Approved = A.Approved,
					--RtrPayment	=	A.RtrPayment, RtrStatus = A.RtrStatus
					--from #R A Where A.Rtrid=Retailer.Rtrid
				
					--DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId
					
					--SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(100))+''
					--INSERT INTO Translog(strSql1) VALUES (@sSql)
					
					--INSERT INTO RetailerValueClassMap
					--(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					--Select @RtrId,RtrValueClassId,1,@Pi_UserId,CONVERT(NVARCHAR(10),GETDATE(),121),@Pi_UserId,CONVERT(NVARCHAR(10),GETDATE(),121) From #R
					
					--DELETE FROM RetailerMarket where Rtrid=@Rtrid
					
					--INSERT INTO RetailerMarket
					--Select @Rtrid,Srte,1,@Pi_UserId,CONVERT(NVARCHAR(10),GETDATE(),121),@Pi_UserId,CONVERT(NVARCHAR(10),GETDATE(),121),0 from #R
									
					--Insert into Retailer_history_Track
					--Select * from Retailer_history where Rtrid = @Rtrid
					
					--Delete from Retailer_history where RtrId= @RtrId
				--END
				--ELSE
				--BEGIN
				--	UPDATE Retailer SET RtrStatus=@Status,Approved=@ApprovedId,RtrKeyAcc=@KeyAccId WHERE RtrId=@RtrId		
				--	Delete from Retailer_history where RtrId= @RtrId		
				--END
				
			--END
			
		UPDATE Cn2Cs_Prk_RetailerApproval SET DownLoadFlag='Y' WHERE DownLoadFlag ='D' and cmprtrcode=@CmpRtrCode
		END
		FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,@Status,@KeyAcc,@Approved
	END
	CLOSE Cur_RetailerApproval
	DEALLOCATE Cur_RetailerApproval
		
	RETURN
END
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE Name='Tbl_SchedulerInvoiceparle' and XTYPE='U')
CREATE TABLE Tbl_SchedulerInvoiceparle(
	[SyncId] [numeric](38, 0) NULL,
	[CmpInvNo] [varchar](3000) NULL,
	[SyncStatus] [int] NULL,
	[Createddate] [datetime] NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_Console2CS_ConsolidatedDownload' and xtype='P')
DROP PROCEDURE Proc_Console2CS_ConsolidatedDownload
GO
CREATE PROCEDURE [dbo].[Proc_Console2CS_ConsolidatedDownload]
As  
Begin  
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
 Select *,0 as DWNStatus from Console2CS_Consolidated (Nolock) Where DownloadFlag In ('D','N')
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
    
       
-- Purchase trace starts here   
   Insert into Tbl_SchedulerInvoiceparle
 SELECT  DISTINCT SyncId,column2,DWNStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Purchase' And DWNStatus = 1   Union	
 SELECT  DISTINCT SyncId,column2+'-'+Column3+'-'+Column7+'-'+Column8+'-'+Column9+'-'+Column10,DwnStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Product Batch' And DWNStatus = 1 Union
 SELECT  DISTINCT SyncId,column26,DWNStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Product' And DWNStatus = 1  
 -- Purchase Trace Ends here

    
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
   
-- Purchase trace starts here   
 Insert into Tbl_SchedulerInvoiceparle
 SELECT  DISTINCT SyncId,column2,DWNStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Purchase' And DWNStatus = 1   Union	
 SELECT  DISTINCT SyncId,column2+'-'+Column3+'-'+Column7+'-'+Column8+'-'+Column9+'-'+Column10,DwnStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Product Batch' And DWNStatus = 1 Union
 SELECT  DISTINCT SyncId,column26,DWNStatus,getdate() From #Console2CS_Consolidated (NOLOCK) Where Processname = 'Product' And DWNStatus = 1  
  -- Purchase Trace Ends here
   
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
IF EXISTS (SELECT *FROM SYSOBJECTS WHERE NAME='PROC_PRODUCTDELETION' and XTYPE='P')
DROP PROCEDURE PROC_PRODUCTDELETION
GO
--EXEC PROC_PRODUCTDELETION
CREATE PROCEDURE PROC_PRODUCTDELETION
AS
BEGIN
BEGIN TRY
BEGIN TRAN
--WithOut Transaction Product Batch Details to be Deleted 
TRUNCATE TABLE Product_Backup
TRUNCATE TABLE ProductBatch_BackUp
TRUNCATE TABLE ProductBatchDetails_BackUp
SELECT DISTINCT PrdId,PrdBatId  INTO #StockLedger FROM (
SELECT DISTINCT PrdId,PrdBatId  FROM StockLedger (NOLOCK) UNION 
SELECT DISTINCT PrdId,PrdBatId FROM PurchaseReceipt P (NOLOCK) INNER JOIN PurchaseReceiptProduct PP (NOLOCK) 
ON P.PurRcptId=PP.PurRcptId WHERE Status=0 UNION
SELECT DISTINCT PrdId,PrdBatId FROM ETLTempPurchaseReceiptProduct (NOLOCK) UNION
SELECT DISTINCT PrdId,PrdBatId FROM ReturnHeader R (NOLOCK) INNER JOIN ReturnProduct RP (NOLOCK) 
ON R.ReturnID = RP.ReturnID WHERE R.Status = 1 )X
SELECT DISTINCT PrdCCode INTO #SingleCode FROM Product (NOLOCK) GROUP BY PrdCCode HAVING COUNT(PrdCCode)<=1
SELECT PrdId,PrdCCode INTO #Product FROM Product A  
WHERE  NOT EXISTS(SELECT DISTINCT PrdId FROM #StockLedger B WHERE A.PrdId=B.PrdId) ORDER BY PrdId
DELETE A FROM #Product A INNER JOIN #SingleCode B ON A.PrdCCode=B.PrdCCode
SELECT MIN(PrdId) AS PrdId,PrdCCode INTO  #DuplicateProduct FROM #Product GROUP BY PrdCCode HAVING  COUNT(PrdCCode)>=1
DELETE A FROM ContractPricingDetails A (NOLOCK) INNER JOIN #DuplicateProduct B ON A.PrdId=B.PrdId
DELETE A FROM TargetNormMappingDt A (NOLOCK) INNER JOIN #DuplicateProduct B ON A.PrdId=B.PrdId
DELETE A FROM SchemeProducts A (NOLOCK) INNER JOIN #DuplicateProduct B ON A.PrdId=B.PrdId
DELETE A FROM SchemeSlabFrePrds A (NOLOCK) INNER JOIN #DuplicateProduct B ON A.PrdId=B.PrdId --Added
DELETE B FROM StockManagement A (NOLOCK) INNER JOIN StockManagementProduct B (NOLOCK) ON A.StkMngRefNo=B.StkMngRefNo
INNER JOIN #DuplicateProduct C ON B.PrdId=C.PrdId WHERE Status=0
INSERT INTO ProductBatchDetails_BackUp (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus)
SELECT DISTINCT PriceId,A.PrdBatId,PriceCode,A.BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus 
FROM ProductBatchDetails A (NOLOCK) 
INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PriceId FROM ProductBatchDetails_BackUp D (NOLOCK) WHERE A.PriceId = D.PriceId)
INSERT INTO ProductBatch_BackUp (PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning)
SELECT DISTINCT B.PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,B.TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning 
FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PrdBatId FROM ProductBatch_BackUp E (NOLOCK) WHERE B.PrdBatId = E.PrdBatId) 
INSERT INTO Product_Backup (PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,IMEIEnabled,IMEILength,EANCode)
SELECT DISTINCT C.PrdId,PrdName,PrdShrtName,PrdDCode,C.PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,IMEIEnabled,IMEILength,EANCode 
FROM Product C (NOLOCK) INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PrdId FROM Product_Backup E (NOLOCK) WHERE C.PrdId = E.PrdId) 
DELETE A FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
DELETE B FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
DELETE C FROM Product C (NOLOCK) INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId
--
SELECT DISTINCT PrdCCode INTO #SingleCode1 FROM Product (NOLOCK) GROUP BY PrdCCode HAVING  COUNT(PrdCCode)<=1
SELECT PrdId,PrdCCode INTO #Product1 FROM Product A (NOLOCK) 
WHERE  NOT EXISTS(SELECT DISTINCT PrdId FROM #StockLedger B WHERE A.PrdId=B.PrdId) ORDER BY PrdId
DELETE A FROM #Product1 A INNER JOIN #SingleCode1 B ON A.PrdCCode=B.PrdCCode
SELECT MIN(PrdId) AS PrdId ,PrdCCode INTO #DuplicateProduct1 FROM #Product GROUP BY PrdCCode HAVING  COUNT(PrdCCode)>=1
DELETE A FROM ContractPricingDetails A (NOLOCK) INNER JOIN #DuplicateProduct1 B ON A.PrdId=B.PrdId
DELETE A FROM TargetNormMappingDt A (NOLOCK) INNER JOIN #DuplicateProduct1 B ON A.PrdId=B.PrdId
DELETE A FROM SchemeProducts A (NOLOCK) INNER JOIN #DuplicateProduct1 B ON A.PrdId=B.PrdId
DELETE A FROM SchemeSlabFrePrds A (NOLOCK) INNER JOIN #DuplicateProduct1 B ON A.PrdId=B.PrdId --Added
DELETE B FROM StockManagement A (NOLOCK) INNER JOIN StockManagementProduct B (NOLOCK) ON A.StkMngRefNo=B.StkMngRefNo
INNER JOIN #DuplicateProduct1 C ON B.PrdId=C.PrdId WHERE Status=0
INSERT INTO ProductBatchDetails_BackUp (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus)
SELECT DISTINCT PriceId,A.PrdBatId,PriceCode,A.BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus 
FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PriceId FROM ProductBatchDetails_BackUp D (NOLOCK) WHERE A.PriceId = D.PriceId)
INSERT INTO ProductBatch_BackUp (PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning)
SELECT DISTINCT B.PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,B.TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning 
FROM ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PrdBatId FROM ProductBatch_BackUp E (NOLOCK) WHERE B.PrdBatId = E.PrdBatId) 
INSERT INTO Product_Backup (PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,IMEIEnabled,IMEILength,EANCode)
SELECT DISTINCT C.PrdId,PrdName,PrdShrtName,PrdDCode,C.PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,IMEIEnabled,IMEILength,EANCode 
FROM Product C (NOLOCK) INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PrdId FROM Product_Backup E (NOLOCK) WHERE C.PrdId = E.PrdId)
DELETE A FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
DELETE B FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
DELETE C FROM Product C (NOLOCK) INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId
SELECT MIN(PrdId) AS PrdId ,PrdCCode INTO #Product2 FROM product  A
WHERE EXISTS(SELECT DISTINCT PrdId FROM #StockLedger B WHERE A.PrdId=B.PrdId)
GROUP BY PrdCCode HAVING  COUNT(PrdCCode)>1
UPDATE PP SET PP.PrdCCode='Dup_'+P.PrdCCode FROM #Product2 P INNER JOIN Product PP (NOLOCK) ON P.PrdId=PP.PrdId
--BATCH DELETE
SELECT PrdId,PrdBatId,DefaultPriceId INTO #ProductBatch  FROM ProductBatch A (NOLOCK) WHERE 
NOT EXISTS(SELECT B.PrdId,B.PrdBatId FROM #StockLedger B WHERE A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId)
SELECT PrdId,MAX(PrdBatId) PrdBatId INTO #Maxbatch FROM #ProductBatch GROUP BY PrdId
DELETE P FROM #ProductBatch P INNER JOIN #Maxbatch PP ON P.PrdId=PP.PrdId AND P.PrdBatId=PP.PrdBatId
INSERT INTO ProductBatchDetails_BackUp (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus)
SELECT DISTINCT PriceId,A.PrdBatId,PriceCode,A.BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus 
FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #ProductBatch D ON D.PrdId=C.PrdId
AND B.PrdId=D.PrdId AND D.PrdBatId=B.PrdBatId AND D.PrdBatId=A.PrdBatId AND A.PriceId=D.DefaultPriceId
WHERE NOT EXISTS (SELECT DISTINCT PriceId FROM ProductBatchDetails_BackUp D (NOLOCK) WHERE A.PriceId = D.PriceId) 
INSERT INTO ProductBatch_BackUp (PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning)
SELECT DISTINCT B.PrdId,B.PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,B.TaxGroupId,BatchSeqId,DecPoints,B.DefaultPriceId,EnableCloning
FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #ProductBatch D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId AND D.PrdBatId=B.PrdBatId
WHERE NOT EXISTS (SELECT DISTINCT PrdBatId FROM ProductBatch_BackUp E (NOLOCK) WHERE B.PrdBatId = E.PrdBatId) 
DELETE A FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #ProductBatch D ON D.PrdId=C.PrdId
AND B.PrdId=D.PrdId AND D.PrdBatId=B.PrdBatId AND D.PrdBatId=A.PrdBatId AND A.PriceId=D.DefaultPriceId 
DELETE B FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #ProductBatch D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId AND D.PrdBatId=B.PrdBatId 
--SELECT DISTINCT PrdCCode FROM Product (NOLOCK) GROUP BY PrdCCode HAVING  COUNT(PrdCCode)>1
--SELECT COUNT(PrdId) FROM Product (NOLOCK)
UPDATE ProductBatchDetails SET DefaultPrice = 0
UPDATE A SET A.DefaultPrice = 1 FROM ProductBatchDetails A (NOLOCK) INNER JOIN (
SELECT DISTINCT PrdBatId,MAX(PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK) Where PriceCode not like '%SPL%'GROUP BY PrdBatId)B 
ON A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId

UPDATE A SET A.DefaultPriceId = B.PriceId FROM ProductBatch A (NOLOCK) INNER JOIN (
SELECT DISTINCT PrdBatId,MAX(PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK) Where PriceCode not like '%SPL%' GROUP BY PrdBatId)B 
ON A.PrdBatId = B.PrdBatId
UPDATE DayEndProcess SET ProcDate = CONVERT(NVARCHAR(10),GETDATE(),121),NextUpDate = CONVERT(NVARCHAR(10),GETDATE(),121)
WHERE ProcDesc = 'Remove Product Batch'
COMMIT TRAN
END TRY
BEGIN CATCH
	SELECT 'ERROR WHILE EXCUTE' ,ERROR_MESSAGE()
	ROLLBACK TRAN
END CATCH
END
GO
IF EXISTS(SELECT * FROM Sysobjects WHERE Name = 'Proc_AutoBatchTransfer_Parle' AND Type = 'P')
DROP PROC Proc_AutoBatchTransfer_Parle
GO
/*
BEGIN TRANSACTION
select *from stockledger a where prdid = 2058 and TransDate = (select MAX(TransDate) from StockLedger where PrdId = a.PrdId and PrdBatId = a.PrdBatId)
EXEC Proc_AutoBatchTransfer_Parle 0
select *from stockledger a where prdid = 2058 and TransDate = (select MAX(TransDate) from StockLedger where PrdId = a.PrdId and PrdBatId = a.PrdBatId)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_AutoBatchTransfer_Parle
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_AutoBatchTransfer
* PURPOSE		: To do Batch Transfer automatically while downloading New Batch for Existing Product
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/02/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 				AS 	INT
	DECLARE @Trans				AS 	INT
	DECLARE @Tabname 			AS  NVARCHAR(100)
	DECLARE @DestTabname 		AS 	NVARCHAR(100)
	DECLARE @Fldname 			AS  NVARCHAR(100)
	
	DECLARE @PrdDCode 	        AS 	NVARCHAR(100)
	DECLARE @BatchCode			AS 	NVARCHAR(100)
	DECLARE @CmpBatchCode		AS 	NVARCHAR(100)	
	DECLARE @PriceCode			AS 	NVARCHAR(4000)		
	DECLARE @MnfDate			AS 	NVARCHAR(100)
	DECLARE @ExpDate			AS 	NVARCHAR(100)
	DECLARE @TaxGroupCode		AS 	NVARCHAR(100)
	DECLARE @Status				AS 	NVARCHAR(100)
	DECLARE	@BatchSeqCode 		AS 	NVARCHAR(100)
	DECLARE @RefCode           	AS 	NVARCHAR(100)
	DECLARE @PriceValue         AS 	NVARCHAR(100)	
	DECLARE @DefaultPrice       AS 	NVARCHAR(100)	  	
	DECLARE @ExistPrdDCode		AS 	NVARCHAR(100)  	
	DECLARE @ExistBatchCode		AS 	NVARCHAR(100)
	DECLARE @ExistPriceCode		AS 	NVARCHAR(100)  	
	
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
	DECLARE @SlNo	 			AS 	INT
	DECLARE @NoOfPrices 		AS 	INT
	DECLARE @ExistPrices 		AS 	INT
	DECLARE @DefaultPriceId 	AS 	INT
	DECLARE @ExistPriceId 		AS 	INT
	DECLARE @TransStr 			AS 	NVARCHAR(4000)
	DECLARE @ExistPrdBatMaxId	AS 	INT
	DECLARE @NewPrdBatMaxId		AS 	INT
	DECLARE @ContPrdId 			AS 	INT
	DECLARE @ContPrdBatId 		AS 	INT
	DECLARE @ContExistPrdBatId 	AS 	INT
	DECLARE @ContPriceId 		AS 	INT
	DECLARE @ContractId 		AS 	INT
	DECLARE @ContPriceCode		AS NVARCHAR(100)
	DECLARE @ContPrdBatId1		AS INT
	DECLARE @ContPriceId1		AS INT
	DECLARE @BatchTransfer		AS INT
	DECLARE @SalStock			AS INT
	DECLARE @UnSalStock			AS INT
	DECLARE @OfferStock			AS INT
	DECLARE @FromPrdBatId		AS INT
	DECLARE @FromPrdBatCode		AS NVARCHAR(200)
	DECLARE @ToPrdBatId			AS INT
	DECLARE @LcnId				AS INT
	DECLARE @Po_StkPosting		AS INT
	DECLARE @TransDate			AS DATETIME
	SET @BatchTransfer=0
	SELECT @TransDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	---->Needs to be changed
	SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='GENConfig000001'
	SET @Po_ErrNo=0
	SET @Exist=0
	SET @ExistPrdDCode=''	
	SET @ExistBatchCode=''
	SET @ExistPriceCode=''
	
	SET @Exist=0
	
	DECLARE Cur_ProductBatch CURSOR
	FOR 
	SELECT PrdId,MAX(PrdBatId) PrdBatId FROM ProductBatch GROUP BY PrdId
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	WHILE @@FETCH_STATUS=0
	BEGIN
		--SELECT @PrdId,@PrdBatId,@BatchCode
		DECLARE Cur_BatchTransfer CURSOR
		FOR SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
		FROM ProductBatchLocation PBL WHERE PBL.PrdId=@PrdId AND PBL.PrdBatId<>@PrdBatId
		AND ((PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih)+(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih)+(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre))>0
		OPEN Cur_BatchTransfer
		FETCH NEXT FROM Cur_BatchTransfer INTO @LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
		WHILE @@FETCH_STATUS=0
		BEGIN
			--SELECT @PrdId,@PrdBatId,@LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
			
			SET @Po_ErrNo=0
			
			IF @SalStock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 1,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 1,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 30,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 27,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END													
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
			
			IF @UnSalStock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 2,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 2,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 31,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 28,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END						
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
				
			IF @Offerstock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 3,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 3,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 32,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 29,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END						
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
			IF @Po_ErrNo>0
			BEGIN
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				VALUES(@FromPrdBatId,'','Error','Error')
			END
			FETCH NEXT FROM Cur_BatchTransfer INTO @LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
		END
		CLOSE Cur_BatchTransfer
		DEALLOCATE Cur_BatchTransfer
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	RETURN	
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_Cs2Cn_Retailer')
DROP PROCEDURE Proc_Cs2Cn_Retailer
GO
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_Retailer]
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_CS2CN_BLRetailer
* PURPOSE	: Extract Retailer Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 09-01-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*Added AutoRetailerApproval for Parle ICRSTPAR1505
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	--CHANGED BY MAHESH FOR ICRSTPAR1505
	IF EXISTS (SELECT * FROM RETAILER WHERE APPROVED=0)
	BEGIN
		UPDATE RETAILER SET Approved=1 WHERE Approved=0
	END
	--Till Here
	DELETE FROM Cs2Cn_Prk_Retailer WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Retailer
	(
		DistCode ,
		RtrId ,
		RtrCode ,
		CmpRtrCode ,
		RtrName ,
		RtrAddress1,
		RtrAddress2,
		RtrAddress3,
		RtrPINCode,
		RtrChannelCode ,
		RtrGroupCode ,
		RtrClassCode ,
		Status,
		KeyAccount,
		RelationStatus,
		ParentCode,
		RtrRegDate,
		GeoLevel,
		GeoLevelValue,
		VillageId,
		VillageCode,
		VillageName,
		Mode,
        DrugLNo,
        RtrTaxGroupCode,		
		UploadFlag
	)
	SELECT
		@DistCode ,
		R.RtrId ,
		R.RtrCode ,
		R.CmpRtrCode ,
		R.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode ,
		'' CtgCode ,
		'' ValueClassCode ,
		RtrStatus,	
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New',R.RtrDrugLicNo,ISNULL(TGS.RtrGroup,''),'N'				
	FROM		
		Retailer R
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
	WHERE			
		R.Upload = 'N'
	UNION
	SELECT
		@DistCode ,
		RCC.RtrId,
		RCC.RtrCode,
		R.CmpRtrCode,
		RCC.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode,
		'' CtgCode,
		'' ValueClassCode,
		RtrStatus,
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','CR',R.RtrDrugLicNo,ISNULL(TGS.RtrGroup,''),'N'			
	FROM
		RetailerClassficationChange RCC			
		INNER JOIN Retailer R ON R.RtrId=RCC.RtrId
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
	WHERE 	
		UpLoadFlag=0
	UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,ETL.RtrClassCode=RVC.ValueClassCode
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode ,RVC.ValueClassCode
		FROM
		RetailerValueClassMap RVCM ,
		RetailerValueClass RVC	,
		RetailerCategory RC ,
		RetailerCategoryLevel RCL,
		RetailerCategory RC1,
		Retailer R  		
	WHERE
		R.Rtrid = RVCM.RtrId
		AND	RVCM.RtrValueClassId = RVC.RtrClassId
		AND	RVC.CtgMainId=RC.CtgMainId
		AND	RCL.CtgLevelId=RC.CtgLevelId
		AND	RC.CtgLinkId = RC1.CtgMainId
	) AS RVC
	WHERE ETL.RtrId=RVC.RtrId
	
	UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoLevelValue=Geo.GeoName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
		ISNULL(G.GeoName,'') AS GeoName
		FROM			
		Retailer R  		
		LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
		LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId
	) AS Geo
	WHERE ETL.RtrId=Geo.RtrId	
	UPDATE ETL SET ETL.VillageId=V.VillageId,ETL.VillageCode=V.VillageCode,ETL.VillageName=V.VillageName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,R.VillageId,V.VillageCode,V.VillageName
		FROM			
		Retailer R  		
		INNER JOIN RouteVillage V ON R.VillageId=V.VillageId
	) V
	WHERE ETL.RtrId=V.RtrId	
	UPDATE Retailer SET Upload='Y' WHERE Upload='N'
	AND CmpRtrCode IN(SELECT CmpRtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='New')
	UPDATE RetailerClassficationChange SET UpLoadFlag=1 WHERE UpLoadFlag=0
	AND RtrCode IN(SELECT RtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='CR')
	UPDATE Cs2Cn_Prk_Retailer SET ServerDate=@ServerDate
END
GO
DELETE FROM HOTSEARCHEDITORHD WHERE Formid=10207
INSERT INTO HOTSEARCHEDITORHD (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10207,'Billing','Display Product [MRP,NETWGT AND Saleable Qty] without Company','select',
'SELECT PrdId,PrdName,MRP,PrdDCode,PrdCcode,PrdShrtName,PrdWgt,SaleableQty,PrdSeqDtId,PrdType,BatchId FROM 
(SELECT DISTINCT A.PrdId,C.PrdSeqDtId,  A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,CAST (PBD.PrdBatDetailValue AS NUMERIC(18,2)) AS MRP,  
(D.PrdBatLcnSih - D.PrdBatLcnRessih) AS [SaleableQty],A.PrdType,D.PrdBatId as BatchId,A.PrdWgt  FROM Product A WITH (NOLOCK),  
ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),  
ProductBatchLocation D WITH (NOLOCK),  ProductBatch E WITH (NOLOCK)   WHERE B.TransactionId=2 AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId   
AND A.PrdId = C.PrdId AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0   AND PrdType <> 4    AND D.LcnId=vFParam AND D.PrdBatId = E.PrdBatId 
AND  E.Status = 1 AND E.PrdId = A.PrdId   AND D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   
AND  PBD.BatchSeqId=BC.BatchSeqId  
Union 
SELECT DISTINCT A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,A.PrdCcode,  
A.PrdName,A.PrdShrtName,CAST (PBD.PrdBatDetailValue AS NUMERIC(18,2)) AS MRP,(D.PrdBatLcnSih - D.PrdBatLcnRessih) AS SaleableQty,A.PrdType,  
D.PrdBatId as BatchId,A.PrdWgt  FROM  Product A WITH (NOLOCK), ProductBatchLocation D WITH (NOLOCK),   
ProductBatch E WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)    
WHERE PrdStatus = 1  AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND PrdType <> 4   
AND D.LcnId=vFParam  AND  A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  
ProductSeqDetails C WITH (NOLOCK)  WHERE B.TransactionId=2 AND B.PrdSeqId=C.PrdSeqId)   
AND D.PrdBatId = E.PrdBatId AND  E.Status = 1  AND E.PrdId = A.PrdId and D.PrdBatId=PBD.PrdBatId   
AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND PBD.BatchSeqId=BC.BatchSeqId ) a ORDER BY PrdSeqDtId'
GO
DELETE FROM HOTSEARCHEDITORHD WHERE FormId=10208
INSERT INTO HOTSEARCHEDITORHD (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10208,'Billing','Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Select',
'SELECT PrdId,PrdName,MRP,PrdDCode,PrdCcode,PrdShrtName,PrdWgt,SaleableQty,PrdSeqDtId,PrdType,BatchId FROM 
(SELECT DISTINCT B.PrdId,B.PrdSNo As PrdSeqDtId,  C.PrdDcode,C.PrdCcode,C.PrdName,C.PrdShrtName,CAST(PBD.PrdBatDetailValue AS NUMERIC(18,2))AS MRP,
(D.PrdBatLcnSih-D.PrdBatLcnResSih) AS SaleableQty,  C.PrdType,E.PrdBatId as BatchId,C.PrdWgt FROM PrdSalesBundle A WITH (NOLOCK) 
INNER JOIN PrdSalesBundleProducts B WITH (NOLOCK)  ON A.PRdSlsBdleId = B.PrdSlsBdleId   INNER JOIN Product C WITH (NOLOCK) 
ON B.PrdId = C.PrdId    INNER JOIN ProductBatchLocation D WITH (NOLOCK)  ON C.PrdStatus = 1   AND C.PrdId=D.PrdId    
AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND C.PrdType <> 4 AND D.LcnId=vFParam     
INNER JOIN  ProductBatch E ON D.PrdBatId = E.PrdBatId   INNER JOIN  ProductBatchDetails PBD WITH (NOLOCK)   
ON E.PrdBatId=PBD.PrdBatId  INNER JOIN  BatchCreation BC WITH (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo  
AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId  WHERE  A.PrdSlsBdleId IN (SELECT ISNULL(MAX(PrdSlsBdleId),0)    
FROM PrdSalesBundle   WHERE SmId = vTParam AND vFOParam = (CASE RmId WHEN 0 THEN vFOParam ELSE RmId END))   
AND E.Status = 1   AND E.PrdId = C.PrdId ) a ORDER BY PrdSeqDtId'
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_ReturnSchMultiFree' AND XTYPE='P')
DROP PROCEDURE Proc_ReturnSchMultiFree
GO
/*
Begin Tran
 Exec Proc_ReturnSchMultiFree 2,2,1,77,2,0
RollBack Tran
*/
CREATE PROCEDURE [dbo].[Proc_ReturnSchMultiFree]
(
	@Pi_UsrId 		INT,
	@Pi_TransId		INT,
	@Pi_LcnId		INT,
	@Pi_SchId		INT,
	@Pi_SlabId		INT,
	@Pi_SalId		INT			
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSchMultiFree
* PURPOSE	: To Return the Free Product Details for Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 25/04/2007
* NOTE		: General SP for Returning the Free Product Details for Selected Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
Modified by Mahesh Babu D ON 2015-10-	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FreeQty As INT
	DECLARE @NoOfTimes As NUMERIC(38,6)
	DECLARE @AvailableQty TABLE
	(
		PrdId		INT,
		AvailQty	INT
	)
	DECLARE @NetAvailableQty TABLE
	(
		PrdId		INT,
		AvailQty	INT
	)
	DECLARE @FreePrdQty TABLE
	(
		PrdId		INT,
		AvailQty	INT,
		ToGive		INT,
		SeqId		INT
	)
	DECLARE @NetFreePrdQty TABLE
	(
		PrdId		INT,
		AvailQty	INT,
		ToGive		INT,
		SeqId		INT
	)
	IF EXISTS (SELECT OpnAndOR FROM SchemeSlabFrePrds WHERE SchId = @Pi_SchId AND SlabId = @Pi_SlabId AND OpnAndOR = 1)
	BEGIN
		IF NOT EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtFreePrd WHERE SalId = @Pi_SalId AND
				SchId = @Pi_SchId AND SlabId = @Pi_SlabId)
		BEGIN
			
			SELECT @FreeQty = FreeToBeGiven FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND
				TransId = @Pi_TransId AND SchId = @Pi_SchId AND SlabId = @Pi_SlabId
			
			
			INSERT INTO @AvailableQty(PrdId,AvailQty)
			SELECT A.PrdId,ISNULL(SUM((PrdBatLcnFre - PrdBatLcnResFre) + (PrdBatLcnSih - PrdBatLcnResSih)),0)
				FROM ProductBatchLocation A INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.FreePrdId
				WHERE A.LcnId = @Pi_LcnId AND B.Usrid = @Pi_Usrid AND B.TransId = @Pi_TransId AND
				B.SchId = @Pi_SchId AND B.SlabId = @Pi_SlabId GROUP BY A.PrdId
			
			
			INSERT INTO @AvailableQty(PrdId,AvailQty)
			SELECT A.PrdId,-1 * ISNULL(SUM(BaseQty),0) As AvailQty FROM BilledPrdHdForScheme A
				INNER JOIN @AvailableQty B ON A.PrdId = B.PrdId
				WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
				GROUP BY A.PrdId
			
			
			INSERT INTO @AvailableQty(PrdId,AvailQty)
			SELECT A.FreePrdId,-1 * ISNULL(SUM(FreeToBeGiven),0) As AvailQty FROM BillAppliedSchemeHd A
				INNER JOIN @AvailableQty B ON A.FreePrdId = B.PrdId
				WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId AND A.FreePrdBatId > 0
				GROUP BY A.FreePrdId
			
			
			INSERT INTO @NetAvailableQty(PrdId,AvailQty)
			SELECT PrdId,ISNULL(SUM(AvailQty),0) As AvailQty FROM @AvailableQty
				GROUP BY PrdId
				HAVING ISNULL(SUM(AvailQty),0) > @FreeQty
				
			IF NOT EXISTS (SELECT * FROM @NetAvailableQty)
			BEGIN

				SELECT @NoOfTimes = NoOfTimes FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND
				TransId = @Pi_TransId AND SchId = @Pi_SchId AND SlabId = @Pi_SlabId

				INSERT INTO @FreePrdQty (PrdId,AvailQty,ToGive,SeqId)
				SELECT A.PrdId,ISNULL(SUM((PrdBatLcnFre - PrdBatLcnResFre) + (PrdBatLcnSih - PrdBatLcnResSih)),0),
				(FreeQty * @NoOfTimes) As ToGive,SeqId FROM ProductBatchLocation A INNER JOIN
				SchemeSlabMultiFrePrds B ON A.PrdId = B.PrdId
				WHERE A.LcnId = @Pi_LcnId AND B.SchId = @Pi_SchId AND B.SlabId = @Pi_SlabId
				GROUP BY A.PrdId,B.SeqId,FreeQty ORDER BY B.SeqId

				INSERT INTO @FreePrdQty (PrdId,AvailQty,ToGive,SeqId)
				SELECT A.PrdId,-1 * ISNULL(SUM(BaseQty),0) As AvailQty,0,B.SeqId FROM BilledPrdHdForScheme A
				INNER JOIN SchemeSlabMultiFrePrds B ON A.PrdId = B.PrdId 
				WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
				AND B.SchId = @Pi_SchId AND B.SlabId = @Pi_SlabId
				GROUP BY A.PrdId,B.SeqId ORDER BY B.SeqId

				INSERT INTO @FreePrdQty (PrdId,AvailQty,ToGive,SeqId)
				SELECT A.FreePrdId,-1 * ISNULL(SUM(FreeToBeGiven),0) As AvailQty,0,B.SeqId
				FROM BillAppliedSchemeHd A
				INNER JOIN SchemeSlabMultiFrePrds B ON A.FreePrdId = B.PrdId
				WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId AND A.FreePrdBatId > 0
				AND B.SchId = @Pi_SchId AND B.SlabId = @Pi_SlabId
				GROUP BY A.FreePrdId,B.SeqId ORDER BY B.SeqId

				INSERT INTO @NetFreePrdQty (PrdId,AvailQty,ToGive,SeqId)
				SELECT TOP 1 A.PrdId,ISNULL(SUM(AvailQty),0) As AvailQty,
				ISNULL(SUM(ToGive),0) As ToGive,A.SeqId FROM @FreePrdQty A
				GROUP BY A.PrdId,A.SeqId
				HAVING ISNULL(SUM(AvailQty),0) > ISNULL(SUM(ToGive),0)
				ORDER BY A.SeqId

				UPDATE BillAppliedSchemeHd SET FreePrdId = A.PrdId,FreeToBeGiven = A.ToGive
					FROM @NetFreePrdQty A WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
					AND BillAppliedSchemeHd.SchId = @Pi_SchId AND
					BillAppliedSchemeHd.SlabId = @Pi_SlabId

			END
			
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET FreePrdId = A.FreePrdId, FreePrdBatId = A.FreePrdBatId
				FROM SalesInvoiceSchemeDtFreePrd A WHERE A.SalId = @Pi_SalId AND
				A.SchId = @Pi_SchId AND A.SlabId = @Pi_SlabId AND BillAppliedSchemeHd.SchId = @Pi_SchId
				AND BillAppliedSchemeHd.SlabId = @Pi_SlabId AND Usrid = @Pi_UsrId AND
				TransId = @Pi_TransId 
				--AND BillAppliedSchemeHd.FreePrdId = A.FreePrdId AND BillAppliedSchemeHd.FreePrdBatId = A.FreePrdBatId
		END	
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_GR_Build_PH' AND XTYPE='P')
DROP PROCEDURE Proc_GR_Build_PH
GO
--EXEC [Proc_GR_Build_PH]
CREATE PROCEDURE Proc_GR_Build_PH
AS
/*********************************
* PROCEDURE	: Proc_GR_Build_PH
* PURPOSE	: House Keeping for Product Hierarchy
* CREATED	: ShyamSundar.N
* CREATED DATE	: 09/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 22/09/2010	Nanda		 Changes done for Default company and Product category level with space	
*********************************/
BEGIN
	IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TBL_GR_BUILD_PH') DROP TABLE TBL_GR_BUILD_PH
	DECLARE @SqlStr1	VARCHAR(1000)
	DECLARE @SqlMain	VARCHAR(3000)
	DECLARE @PHLevel	INT
	DECLARE @ILoop2		INT
	DECLARE @DefCmpId	INT
	SET @ILoop2=1
	
	SELECT @DefCmpId=ISNULL(CmpId,1) FROM Company WHERE DefaultCompany=1
	SELECT @PHLevel=MAX(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId =@DefCmpId
	SET @SqlMain = 'CREATE TABLE TBL_GR_BUILD_PH  (PrdId INT,ProductCode NVARCHAR(100),	ProductDescription NVARCHAR(200),'
	WHILE @ILoop2<=@PHLevel
	BEGIN
		SET @SqlStr1=''
		IF EXISTS(SELECT * FROM ProductCategoryLevel WHERE CmpPrdCtgId=@ILoop2 AND CmpId=@DefCmpId)
		BEGIN
			SELECT @SqlStr1='['+CmpPrdCtgName +'_Id] INT,['+CmpPrdCtgName+'_Code] VARCHAR(200),['+CmpPrdCtgName+'_Caption] VARCHAR(200),' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@ILoop2
			SET @SqlMain=@SqlMain+@SqlStr1
		END
		SET @ILoop2=@ILoop2+1
	END
	SET @SqlMain=@SqlMain + 'HashProducts NVARCHAR(3800))'
	EXECUTE (@SqlMain)
	SET @ILoop2=1
	SET @SqlStr1=''
	SET @SqlMain=''
	SELECT @SqlStr1='INSERT INTO TBL_GR_BUILD_PH (PrdId,ProductCode,ProductDescription,['+CmpPrdCtgName +'_Id],['+CmpPrdCtgName+'_Code],['+CmpPrdCtgName +'_Caption])' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@PHLevel
	SET @SqlStr1=@SqlStr1+' SELECT PrdId,PrdCCode,PrdName,A.PrdCtgValMainId,PrdCtgValCode,PrdCtgValName '
	SET @SqlStr1=@SqlStr1+' FROM Product A,ProductCategoryValue B WHERE A.PrdCtgValMainId=B.PrdCtgValMainId AND A.CmpId='+CAST(@DefCmpId AS VARCHAR(10))
	SET @SqlMain=@SqlStr1
	EXECUTE (@SqlMain)
	--SET @PHLevel=@PHLevel-1
	WHILE @ILoop2<@PHLevel
	BEGIN
		SET @SqlStr1=''
		SELECT @SqlStr1='UPDATE C SET ['+CmpPrdCtgName+'_Id]=A.PrdCtgValMainId,['+CmpPrdCtgName+'_Code]=A.PrdCtgValCode,['+CmpPrdCtgName+'_Caption]=A.PRDCTGVALNAME ' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@PHLevel-@ILoop2
		SELECT @SqlStr1=@SqlStr1+' FROM ProductCategoryValue A,ProductCategoryValue B,TBL_GR_BUILD_PH C WHERE ' FROM ProductCategoryLevel WHERE CmpPrdCtgId=(@PHLevel-@ILoop2)
		SELECT @SqlStr1=@SqlStr1+' B.PrdCtgValMainId=C.['+CmpPrdCtgName+'_Id] AND A.PrdCtgValMainId=B.PRDCTGVALLINKID ' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@PHLevel-@ILoop2+1
		SET @SqlMain=@SqlStr1
		EXECUTE (@SqlMain)
		SET @ILoop2=@ILoop2+1
	END
	SET @ILoop2=1
	SET @SqlStr1='UPDATE TBL_GR_BUILD_PH SET HashProducts='
	WHILE @ILoop2<=@PHLevel
	BEGIN
		SELECT @SqlStr1=@SqlStr1+'['+CmpPrdCtgName+'_Caption]+' FROM ProductCategoryLevel WHERE CmpPrdCtgId=@ILoop2
		SET @ILoop2=@ILoop2+1
	END
	SET @SqlStr1=@SqlStr1+'ProductCode+ProductDescription'
	EXECUTE (@SqlStr1)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnBillingKitProduct')
DROP FUNCTION Fn_ReturnBillingKitProduct
GO
--SELECT * FROM Fn_ReturnBillingKitProduct(2,2,3330)
CREATE FUNCTION Fn_ReturnBillingKitProduct(@USERID INT,@TRANSID INT,@RTRID INT)
RETURNS @KITPRODUCT TABLE
(
	KitPrdId	BIGINT,
	PrdDCode	VARCHAR(100),
	PrdName		VARCHAR(300)
)
AS
BEGIN
		DECLARE @RETAILER TABLE 
		(
			RTRID				INT,
			CTGMAINID	INT
		)
	
		INSERT INTO @RETAILER(RTRID,CTGMAINID)
		SELECT R.RTRID,C.CTGMAINID
		FROM RETAILER R (NOLOCK)
		INNER JOIN RETAILERVALUECLASSMAP M (NOLOCK) ON R.RTRID=M.RTRID
		INNER JOIN RETAILERVALUECLASS V (NOLOCK) ON V.RTRCLASSID=M.RTRVALUECLASSID
		INNER JOIN RETAILERCATEGORY C (NOLOCK) ON C.CTGMAINID=V.CTGMAINID
		INNER JOIN RETAILERCATEGORYLEVEL L (NOLOCK) ON L.CtgLevelId=C.CtgLevelId
		WHERE R.RtrId=@RTRID
		
		INSERT INTO @KITPRODUCT(KitPrdId,PrdDCode,PrdName)
		SELECT DISTINCT A.KitPrdId,B.PrdDCode,B.PrdName 
		FROM KitProductStock A  (NOLOCK)
		INNER JOIN Product B (NOLOCK) ON A.KitPrdId = B.PrdID
		INNER JOIN KitProductCategory C (NOLOCK) ON A.KitPrdId = C.KitPrdId AND C.KitPrdId = B.PrdID
		INNER JOIN @RETAILER R ON R.CTGMAINID=C.CtgMainId
		WHERE A.UsrId = @USERID AND  TransId = @TRANSID
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_UpdateKitItemDt')
DROP PROCEDURE Proc_UpdateKitItemDt
GO
/*
BEGIN TRANSACTION
--EXEC Proc_UpdateKitItemDt 1,18,1,1,1,16798,1,'2015-08-19',1,2,8,'979',1,2,0
EXEC Proc_UpdateKitItemDt 4,7,2,2,3583,19479,1,'2015-12-09',2,1,1,'29351',2,2,0
--select * from ProductBatchLocation where Prdid IN (895,1010)
--select * from StockLedger where Prdid IN (895,1010) and TransDate = '2013-01-18' 
select * from ProductBatchLocation where PrdId in (178,340,275,108,177) and (PrdBatLcnSih-PrdBatLcnRessih)>0
select * from kitproducttransdt
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_UpdateKitItemDt]
(
	@Pi_ColId   		INT,
	@Pi_SLColId		INT,
	@Pi_Type  		INT,
	@Pi_SLType		INT,
	@Pi_PrdId  		INT,
	@Pi_PrdBatId  		INT,
	@Pi_LcnId  		INT,
	@Pi_TranDate  		DATETIME,
	@Pi_TranQty  		NUMERIC(38,0),
	@Pi_UsrId  		INT,
	@Pi_TransId		INT,
	@Pi_TransNo		nVARCHAR(50),
	@Pi_TransType		INT,
	@Pi_SlNo		INT,
	@Po_KsErrNo  		INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateKitItemDt
* PURPOSE	: General SP for Updating Kit Item Stock
* CREATED	: Thrinath 
* CREATED DATE	: 28/08/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @sSql AS VARCHAR(2500)
	DECLARE @ErrNo AS INT
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @Qty AS INT
	DECLARE @TotalQty AS INT
	DECLARE @ExistQty AS INT
	DECLARE @FieldName AS VARCHAR(200)
	DECLARE @FieldName1 AS VARCHAR(200)
	DECLARE @ExistPrdId AS INT
	DECLARE @ExistPrdBatId AS INT
	DECLARE @PrdBatLcnStock AS INT
	SET @Po_KsErrNo=0
	DECLARE @SALID BIGINT
	
	SELECT @FieldName = CASE @Pi_ColId
		WHEN 1 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 2 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 3 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' 
		WHEN 4 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 5 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 6 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' END
		
   SELECT @FieldName1 = CASE @Pi_ColId
		WHEN 1 THEN 'PrdBatLcnResSih'
		WHEN 2 THEN 'PrdBatLcnResUih'
		WHEN 3 THEN 'PrdBatLcnResFre' 
		WHEN 4 THEN 'PrdBatLcnResSih'
		WHEN 5 THEN 'PrdBatLcnResUih'
		WHEN 6 THEN 'PrdBatLcnResFre' END				
	
	CREATE  TABLE #KitProduct(PrdId INT,PrdBatId INT,Qty NUMERIC(38,0))
	CREATE  TABLE #KitBatch(PrdId INT,PrdBatId INT,Stock NUMERIC(38,0))
	IF @Pi_TransType = 1  --For Taking In The Stock
	BEGIN
		SELECT @SALID=ISNULL(SALID,0) FROM ReturnHeader (NOLOCK) WHERE ReturnID=@Pi_TransNo
		IF @Pi_TransId=8
		BEGIN
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT DISTINCT KP.PrdId,KPB.PrdBatId,KP.Qty 
			FROM KitProduct KP
			INNER JOIN KitProductBatch KPB
			ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
			INNER JOIN KitProductTransDt T ON T.KitPrdId=KP.KitPrdid AND T.PRDID=KP.PrdId AND T.PrdId=KPB.PrdId
			WHERE KP.KitPrdId = @Pi_PrdId AND T.TransId=1 AND T.TransNo=@SALID
			ORDER BY KP.PrdId,KPB.PrdBatId
		END
		ELSE
		BEGIN
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT KP.PrdId,KPB.PrdBatId,KP.Qty 
			FROM KitProduct KP,KitProductBatch KPB
			WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
			KP.KitPrdId = @Pi_PrdId 
			ORDER BY KP.PrdId,KPB.PrdBatId
		END
		--SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		
		DECLARE Cur_KitProduct CURSOR FOR 	
			SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		
		OPEN Cur_KitProduct
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
			DELETE FROM #KitBatch
			SET @TotalQty=@Qty*@Pi_TranQty		
			IF @PrdBatId=0
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT PrdId,PrdBatId,1 AS Qty FROM ProductBatch
				WHERE PrdId= @PrdId  AND PrdBatId IN (SELECT MIN(PrdBatId)
				FROM ProductBatch WHERE PrdId=@PrdId) ORDER BY PrdBatId
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT PB.PrdId,PB.PrdBatId,1 FROM ProductBatch PB,KitProductBatch KPB
				WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB.PrdBatId AND 
				KPB.PrdBatId IN(SELECT MIN(KPB1.PrdBatId)FROM ProductBatch PB,KitProductBatch KPB1
				WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB1.PrdBatId) ORDER BY KPB.PrdBatId
			END
				
			SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
				
			DECLARE Cur_KitPrdBatch CURSOR FOR 	
				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
			OPEN Cur_KitPrdBatch
			FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			WHILE @@FETCH_STATUS=0
			BEGIN
				DELETE FROM KitProductTransDt 
					WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
					PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
					SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
					AND TransNo = @Pi_TransNo 
				INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,PrdBatId,LcnId,
					SalTransQty,UnSalTransQty,OfferTransQty,KitQty,Availability,LastModBy,
					LastModDate,AuthId,AuthDate) VALUES
				(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,@ExistPrdBatId,@Pi_LcnId,
					CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
 					CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
					CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
					@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
					
				--SELECT * FROM KitProductTransDt
				
				EXEC Proc_UpdateProductBatchLocation @Pi_ColId,@Pi_Type,@ExistPrdId,@ExistPrdBatId,
					@Pi_LcnId,@Pi_TranDate,@TotalQty,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
				IF @ErrNo = 1
				BEGIN
					SET @Po_KsErrNo = 1
					CLOSE Cur_KitPrdBatch
					DEALLOCATE Cur_KitPrdBatch
					CLOSE Cur_KitProduct
					DEALLOCATE Cur_KitProduct
					
					RETURN 
				END
				EXEC Proc_UpdateStockLedger @Pi_SLColId,@Pi_SLType,@ExistPrdId,@ExistPrdBatId,
					@Pi_LcnId,@Pi_TranDate,@TotalQty,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
				IF @ErrNo = 1
				BEGIN
					SET @Po_KsErrNo = 1
					CLOSE Cur_KitPrdBatch
					DEALLOCATE Cur_KitPrdBatch
					CLOSE Cur_KitProduct
					DEALLOCATE Cur_KitProduct
					
					RETURN 
				END
				FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			END
			CLOSE Cur_KitPrdBatch
			DEALLOCATE Cur_KitPrdBatch		
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
		SET @Po_KsErrNo = 0
		RETURN @Po_KsErrNo
	END
	ELSE	--For Taking Out the Stock
	BEGIN		
		IF @Pi_Type=2 AND @Pi_TransId=1
		BEGIN
			INSERT INTO #KitProduct (PrdId,PrdBatId,Qty)
			SELECT DISTINCT KP.PrdId,KP.PrdBatId,SalTransQty FROM KitProductTransDt KP
			WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
			KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
			AND TransNo = @Pi_TransNo ORDER BY KP.PrdId,KP.PrdBatId
		END
		ELSE IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/09
		BEGIN
			EXEC Proc_GetKitItemMandatory @Pi_ColId,@Pi_SLColId,@Pi_Type,@Pi_SLType,@Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,
										  @Pi_TranQty,@Pi_UsrId,@Pi_TransId,@Pi_TransNo,@Pi_TransType,@Pi_SlNo
			INSERT INTO #KitProduct (PrdId,PrdBatId,Qty)
			SELECT DISTINCT PrdId,PrdBatId,Qty FROM Fn_ReturnKitItemMandatory(@Pi_PrdId,@Pi_TranQty)
			
			--SELECT KP.PrdId,KPB.PrdBatId,KP.Qty FROM KitProduct KP,
			--	KitProductBatch KPB WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
			--	KP.KitPrdId = @Pi_PrdId ORDER BY KP.PrdId,KPB.PrdBatId
			--select 'k1'
		END
		ELSE
		BEGIN
			--PRINT 'B'
--			--->Added By Nanda on 21/01/2010
--			DELETE FROM KitProductTransDt
--
--			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
--			SELECT KP.PrdId,KPB.PrdBatId,KP.Qty 
--				FROM KitProduct KP,KitProductBatch KPB
--  				WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
--				KP.KitPrdId = @Pi_PrdId 
--				ORDER BY KP.PrdId,KPB.PrdBatId
--
--			SELECT PrdId,PrdBatId,Qty FROM #KitProduct
--
--			DECLARE Cur_KitProductNew CURSOR FOR 	
--				SELECT PrdId,PrdBatId,Qty FROM #KitProduct
--			
--			OPEN Cur_KitProductNew
--				FETCH NEXT FROM Cur_KitProductNew
--				INTO @PrdId,@PrdBatId,@Qty
--
--			WHILE @@FETCH_STATUS=0
--			BEGIN
--				DELETE FROM #KitBatch
--
--				SET @TotalQty=@Qty*@Pi_TranQty		
--
--				IF @PrdBatId=0
--				BEGIN
--					INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
--					SELECT PrdId,PrdBatId,1 AS Qty FROM ProductBatch
--						WHERE PrdId= @PrdId  AND PrdBatId IN (SELECT Max(PrdBatId)
--						FROM ProductBatch WHERE PrdId=@PrdId) 
--				END
--				ELSE
--				BEGIN
--					INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
--						SELECT PB.PrdId,PB.PrdBatId,1 FROM ProductBatch PB,KitProductBatch KPB
--						WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB.PrdBatId AND 
--						KPB.PrdBatId IN(SELECT MAX(KPB1.PrdBatId)FROM ProductBatch PB,KitProductBatch KPB1
--						WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB1.PrdBatId)
--				END	
--
--				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
--					ORDER BY PrdBatId
--
--				DECLARE Cur_KitPrdBatchNew CURSOR FOR 	
--					SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
--					ORDER BY PrdBatId
--
--				OPEN Cur_KitPrdBatchNew
--				FETCH NEXT FROM Cur_KitPrdBatchNew
--					INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
--
--				WHILE @@FETCH_STATUS=0
--				BEGIN
--					DELETE FROM KitProductTransDt 
--					WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
--					PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
--					SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
--					AND TransNo = @Pi_TransNo 
--
--					INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,PrdBatId,LcnId,
--					SalTransQty,UnSalTransQty,OfferTransQty,KitQty,Availability,LastModBy,
--					LastModDate,AuthId,AuthDate) VALUES
--					(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,@ExistPrdBatId,@Pi_LcnId,
--					CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
--					CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
--					CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
--					@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
--
--					SELECT 'Nanda2'
--					SELECT * FROM KitProductTransDt
--
--					FETCH NEXT FROM Cur_KitPrdBatchNew
--					INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
--				END
--				CLOSE Cur_KitPrdBatchNew
--				DEALLOCATE Cur_KitPrdBatchNew		
--
--				FETCH NEXT FROM Cur_KitProductNew
--				INTO @PrdId,@PrdBatId,@Qty
--			
--			END
--			CLOSE Cur_KitProductNew
--			DEALLOCATE Cur_KitProductNew
--
--			DELETE FROM #KitProduct
--			--->Till Here
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT DISTINCT KP.PrdId,KP.PrdBatId,KitQty FROM KitProductTransDt KP
				WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
				KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
				AND TransNo = @Pi_TransNo ORDER BY KP.PrdId,KP.PrdBatId
				--select 'k2'
		END
		
		SELECT '#KitProduct',PrdId,PrdBatId,Qty FROM #KitProduct
		IF @Pi_Type=2 AND @Pi_TransId=1
		BEGIN
			SELECT 'F1'
		END
		ELSE IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6
		BEGIN
			IF @Pi_ColId > 0 AND @Pi_SLColId > 0
			BEGIN
				DELETE FROM KitProductTransDt 
				WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
				--PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
				SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
				AND TransNo = @Pi_TransNo
			END
		END
	
		DECLARE Cur_KitProduct CURSOR FOR 	
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct		
		OPEN Cur_KitProduct
		FETCH NEXT FROM Cur_KitProduct
		INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
		   -- SELECT @PrdId,@PrdBatId,@Qty
			DELETE FROM #KitBatch
			--SET @TotalQty=@Qty*@Pi_TranQty
			SET @TotalQty=@Qty--*@Pi_TranQty
			IF @Pi_Type=2 AND @Pi_TransId=1
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT DISTINCT KP.PrdId,KP.PrdBatId,
					CASE @Pi_ColId 	WHEN 1 THEN SalTransQty
							WHEN 2 THEN UnSalTransQty
							WHEN 3 THEN OfferTransQty
							WHEN 4 THEN SalTransQty
							WHEN 5 THEN UnSalTransQty
							WHEN 6 THEN OfferTransQty 
							WHEN 0 THEN 
								CASE @Pi_SLColId WHEN 7 THEN SalTransQty
									WHEN 9 THEN OfferTransQty END
							END
					FROM KitProductTransDt KP
					WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
						KP.PrdId=@PrdId AND KP.PrdBatId=@PrdBatId AND 
						KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
						AND TransNo = @Pi_TransNo 
					ORDER BY KP.PrdId,KP.PrdBatId
			END
			ELSE IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/10
			BEGIN
			    IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId <> 0--Cash Bill
					BEGIN
					SELECT 'A'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName1 AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					--PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 4 AND @Pi_SLColId = 0 AND @Pi_SLType = 2
				BEGIN
				    SELECT 'B'
				    	SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId AND PrdBatLcnResSih > 0'
					--PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId = 0 AND @Pi_ColId <> 4--Delivery Bill
					BEGIN
					SELECT 'C'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						Having SUM(PrdBatLcnSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,(PrdBatLcnSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId'
					--PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 0 AND @Pi_SLType = 2 --Cancel Bill
				BEGIN
				SELECT 'D'
				    	SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih - PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnSih - PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnSih - PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					--PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType <> 2 --Credit Bill
				BEGIN
				SELECT 'E'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT Exists(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					--PRINT @sSql
					EXEC(@sSql)				
				END---------------------------------Till Here 2013/01/10
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT DISTINCT KP.PrdId,KP.PrdBatId,
					CASE @Pi_ColId 	WHEN 1 THEN SalTransQty
							WHEN 2 THEN UnSalTransQty
							WHEN 3 THEN OfferTransQty
							WHEN 4 THEN SalTransQty
							WHEN 5 THEN UnSalTransQty
							WHEN 6 THEN OfferTransQty 
							WHEN 0 THEN 
								CASE @Pi_SLColId WHEN 7 THEN SalTransQty
									WHEN 9 THEN OfferTransQty END
							END
					FROM KitProductTransDt KP
					WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
						KP.PrdId=@PrdId AND KP.PrdBatId=@PrdBatId AND 
						KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
						AND TransNo = @Pi_TransNo 
					ORDER BY KP.PrdId,KP.PrdBatId
			END
			
			--SELECT 'Botree',PrdId,PrdBatId,Stock FROM #KitBatch 
			--ORDER BY PrdBatId
			
			 
				--SELECT '#KitProduct',* FROM #KitProduct
				SELECT '#KitBatch',* FROM #KitBatch					 
			DECLARE Cur_KitPrdBatch CURSOR FOR 	
				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
			OPEN Cur_KitPrdBatch
			FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF @TotalQty > 0
				BEGIN
				IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added by Sathishkumar Veeramani 2012/01/09
				BEGIN
					IF @PrdBatLcnStock>=@TotalQty
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							
							DELETE FROM KitProductTransDt 
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo 
		
							INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,
								PrdBatId,LcnId,SalTransQty,UnSalTransQty,OfferTransQty,KitQty,
								Availability,LastModBy,LastModDate,AuthId,AuthDate)
							VALUES(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								   @ExistPrdBatId,@Pi_LcnId,
								   CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
			 					   CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
								   CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
								   @Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
								
							 --   SELECT @Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								--@ExistPrdBatId,@Pi_LcnId,
								--CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
			 				--	CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
								--CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
								--@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
								--Select 'Software',* from KitProductTransDt
						END
						SET @PrdBatLcnStock = @TotalQty
						SET @TotalQty = 0
					END
					ELSE
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							
							DELETE FROM KitProductTransDt 
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo 
		
							INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,
								PrdBatId,LcnId,SalTransQty,UnSalTransQty,OfferTransQty,KitQty,
								Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
							(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								@ExistPrdBatId,@Pi_LcnId,
								CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock WHEN 4 THEN @PrdBatLcnStock ELSE 0 END,
			 					CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock WHEN 5 THEN @PrdBatLcnStock ELSE 0 END,
								CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock WHEN 6 THEN @PrdBatLcnStock ELSE 0 END,
								@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
							--select @Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
							--	@ExistPrdBatId,@Pi_LcnId,
							--	CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock WHEN 4 THEN @PrdBatLcnStock ELSE 0 END,
			 			--		CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock WHEN 5 THEN @PrdBatLcnStock ELSE 0 END,
							--	CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock WHEN 6 THEN @PrdBatLcnStock ELSE 0 END,
							--	@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
						END
						SET @TotalQty = @TotalQty - @PrdBatLcnStock
					END
				END
				ELSE
				BEGIN
					IF @PrdBatLcnStock>=@TotalQty
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							
							UPDATE KitProductTransDt SET 
								SalTransQty = SalTransQty - (CASE @Pi_ColId WHEN 1 THEN @TotalQty 
									WHEN 4 THEN @TotalQty ELSE 0 END),
								UnSalTransQty = UnSalTransQty - (CASE @Pi_ColId WHEN 2 THEN @TotalQty 
									WHEN 5 THEN @TotalQty ELSE 0 END),
								OfferTransQty = OfferTransQty - (CASE @Pi_ColId WHEN 3 THEN @TotalQty 
									WHEN 6 THEN @TotalQty ELSE 0 END)
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@PrdId AND PrdBatId=@PrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo
						END
						SET @PrdBatLcnStock = @TotalQty
						SET @TotalQty = 0
					END
					ELSE
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							
							UPDATE KitProductTransDt SET 
								SalTransQty = SalTransQty - (CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock 
									WHEN 4 THEN @PrdBatLcnStock ELSE 0 END),
								UnSalTransQty = UnSalTransQty - (CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock 
									WHEN 5 THEN @PrdBatLcnStock ELSE 0 END),
								OfferTransQty = OfferTransQty - (CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock 
									WHEN 6 THEN @PrdBatLcnStock ELSE 0 END)
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@PrdId AND PrdBatId=@PrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo
						END
						SET @TotalQty = @TotalQty - @PrdBatLcnStock
					END
				END
				--select 'KitProductTransDt',* from KitProductTransDt
				IF @Pi_ColId > 0 
				BEGIN
					EXEC Proc_UpdateProductBatchLocation @Pi_ColId,@Pi_Type,@ExistPrdId,@ExistPrdBatId,
						@Pi_LcnId,@Pi_TranDate,@PrdBatLcnStock,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
		
					IF @ErrNo = 1
					BEGIN
						SET @Po_KsErrNo = 1
		
						CLOSE Cur_KitPrdBatch
						DEALLOCATE Cur_KitPrdBatch
		
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
				END
				IF @Pi_SLColId > 0
				BEGIN
					EXEC Proc_UpdateStockLedger @Pi_SLColId,@Pi_SLType,@ExistPrdId,@ExistPrdBatId,
						@Pi_LcnId,@Pi_TranDate,@PrdBatLcnStock,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
		
					IF @ErrNo = 1
					BEGIN
						SET @Po_KsErrNo = 1
		
						CLOSE Cur_KitPrdBatch
						DEALLOCATE Cur_KitPrdBatch
		
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
				END
				END
				FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			END
			CLOSE Cur_KitPrdBatch
			DEALLOCATE Cur_KitPrdBatch		
		
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		END
		IF @TotalQty > 0
		BEGIN 
			SET @Po_KsErrNo = 1
			CLOSE Cur_KitProduct
			DEALLOCATE Cur_KitProduct
					
			RETURN 
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
		
		DELETE FROM KitProductTransDt WHERE (SalTransQty + UnSalTransQty + OfferTransQty) = 0
		SET @Po_KsErrNo = 0
		RETURN @Po_KsErrNo
	END
	print @Po_KsErrNo
	RETURN @Po_KsErrNo
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnKitStockEligiblity')
DROP FUNCTION Fn_ReturnKitStockEligiblity
GO
--SELECT * FROM Fn_ReturnKitStockEligiblity(2706,3) AS KIT
CREATE FUNCTION [dbo].[Fn_ReturnKitStockEligiblity] (@KITPRDID INT,@TRANSQTY BIGINT)
RETURNS @KIT TABLE
(
	KIT TINYINT,
	MSG	VARCHAR(1000)
)
AS
BEGIN
	DECLARE @EXISTSAND TINYINT
	DECLARE @EXISTSOR TINYINT
	DECLARE @KIT_PRD TABLE
	(
		Num			INT,
		KitPrdid	INT,
		PrdId		INT,
		Qty			INT,
		TransQty	BIGINT,
		Mandatory	INT,
		SlabId		INT
	)
	DECLARE @KIT_STOCK TABLE
	(
		KitPrdid	INT,
		PrdId		INT,
		LcnId		INT,
		Stock		BIGINT
	)
	INSERT INTO @KIT_STOCK (KitPrdid,PrdId,LcnId,Stock)
	SELECT KitPrdId,PRDID,LCNID,SUM(STOCK) AS STOCK FROM (
	SELECT KBP.KitPrdId,A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode,SUM(PrdBatLcnSih-PrdBatLcnRessih) AS STOCK FROM PRODUCTBATCHLOCATION A (NOLOCK)
	INNER JOIN PRODUCTBATCH B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId
	INNER JOIN KITPRODUCTBATCH KBP (NOLOCK) ON A.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN A.PrdBatID ELSE KBP.PrdBatID END  
	AND B.PrdBatID=CASE KBP.PrdBatID WHEN 0 THEN B.PrdBatID ELSE KBP.PrdBatID END
	AND A.PRDID=KBP.PRDID AND B.PRDID=KBP.PRDID
	WHERE KBP.KitPrdId=@KITPRDID
	GROUP BY A.PrdId,A.PrdBatID,A.LcnId,B.CmpBatCode,KBP.KitPrdId HAVING SUM(PrdBatLcnSih-PrdBatLcnRessih)>=0)X GROUP BY PRDID,LCNID,KitPrdId
	INSERT INTO @KIT_PRD(Num,KitPrdid,PrdId,Qty,TransQty,Mandatory,SlabId)
	SELECT ROW_NUMBER() OVER (ORDER BY PrdId),KitPrdid,PrdId,Qty,@TRANSQTY*Qty,Mandatory,SlabId FROM KITPRODUCT (NOLOCK) WHERE KITPRDID=@KITPRDID
	SET @EXISTSAND=1
	SET @EXISTSOR=1
	
	IF EXISTS (SELECT KitPrdid FROM @KIT_PRD)
	BEGIN
		IF EXISTS (SELECT * FROM @KIT_PRD A WHERE NOT EXISTS (SELECT * FROM ProductBatchLocation B WHERE A.PrdId=B.PrdId)
			AND A.MANDATORY=1)
		BEGIN
			SET @EXISTSAND=0
		END		
		IF EXISTS (SELECT A.KitPrdid,A.PrdId,A.Qty,A.Qty,A.TransQty,B.STOCK
		FROM @KIT_PRD A INNER JOIN @KIT_STOCK B ON A.KitPrdid=B.KitPrdid AND A.PrdId=B.PrdId WHERE A.Mandatory=1
		AND B.STOCK<A.TransQty)
		BEGIN
			SET @EXISTSAND=0
		END
		IF EXISTS (SELECT A.KitPrdid,A.SlabId,A.TransQty,SUM(B.STOCK) AS STOCK ,SUM(B.STOCK)-A.TransQty AS Remaining
		FROM @KIT_PRD A INNER JOIN @KIT_STOCK B ON A.KitPrdid=B.KitPrdid AND A.PrdId=B.PrdId WHERE A.Mandatory=0
		GROUP BY A.KitPrdid,A.SlabId,A.TransQty HAVING (SUM(B.STOCK)-A.TransQty)<0)
		BEGIN
			SET @EXISTSOR=0
		END
	END
	IF @EXISTSAND=1 AND @EXISTSOR=1
	BEGIN
		INSERT INTO @KIT
		SELECT 0,''
	END
	ELSE
	BEGIN
		INSERT INTO @KIT
		SELECT 1,'Stock Not Available For Attached Kit Item(s)'
	END
	RETURN 
END
GO
--Till Here Script Updater Files
--Added By S.Moorthi
IF NOT EXISTS(SELECT PrfCode FROM ProfileHd WHERE PrfCode='SMADMIN')
BEGIN
	DECLARE @CurrValue as INT
	SELECT @CurrValue =MAX(PrfId)+1 from ProfileHd
	INSERT INTO ProfileHd(PrfId,PrfCode,PrfName,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT @CurrValue,'SMADMIN','SMADMIN',1,1,GETDATE(),1,GETDATE()
	UPDATE Counters SET CurrValue=@CurrValue WHERE TabName='ProfileHd'
END
GO
IF NOT EXISTS(SELECT * FROM USERS WHERE UserName='SMADMIN')
BEGIN
	Declare @CurrVal as INT 
	SELECT @CurrVal =MAX(UserId)+1 from Users
	INSERT INTO Users (UserId,UserName,UserPassword,LoggedStatus,BgColor,TxtColor,HltColor,HltTxtColor,PrfId,Color,Availability,LastModBy,LastModDate,Authid,AuthDate,HostName) 
	SELECT @CurrVal,'SMADMIN','¿Ö§Ìáy±æ´»¨©™²µ',2,'&H8000000F','&H80000012','&HFF0000','&HFFFFFF',PrfId,'DefaultGreen',1,1,GETDATE(),1,GETDATE(),'' FROM  ProfileHd WHERE PrfCode='SMADMIN'
	Update Counters Set CurrValue=@CurrVal where TabName='Users'	
END
GO
DELETE FROM ProfileDT WHERE PrfId IN(SELECT PrfId FROM ProfileHd WHERE PrfCode='SMADMIN')
INSERT INTO ProfileDT(PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,
LastModBy,LastModDate,AuthId,AuthDate)
SELECT (SELECT PrfId FROM ProfileHd WHERE PrfCode='SMADMIN'),MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,
LastModBy,LastModDate,AuthId,AuthDate FROM ProfileDT WHERE PrfId=(SELECT PrfId FROM Users WHERE Username='USER')
GO
DELETE FROM ProfileDt WHERE MenuId='mInv4'
INSERT INTO ProfileDt([PrfId],[MenuId],[BtnIndex],[BtnDescription],[BtnStatus],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
SELECT PrfId,'mInv4',0,'New',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',1,'Edit',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',2,'Save',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',6,'Print',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',7,'Save & Confirm',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',0,'New',0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode NOT IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',1,'Edit',0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode NOT IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',2,'Save',0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode NOT IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',6,'Print',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode NOT IN ('SMADMIN','ADMIN') UNION
SELECT PrfId,'mInv4',7,'Save & Confirm',0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM ProfileHD WHERE PrfCode NOT IN ('SMADMIN','ADMIN')
GO
DELETE FROM FieldLevelAccessDt WHERE PrfId IN (SELECT PrfId FROM ProfileHd WHERE PrfCode='SMADMIN')
INSERT INTO FieldLevelAccessDt(PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT (SELECT PrfId FROM ProfileHd WHERE PrfCode='SMADMIN'),TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate
FROM FieldLevelAccessDt WHERE PrfId=(SELECT PrfId FROM Users WHERE Username='USER')
GO
DELETE FROM CustomCaptions WHERE TransId=13 AND CTRLID=100009 AND SubCtrlId=5
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 13,100009,5,'DgCommon-13-5','Product Name','','',1,1,1,GETDATE(),1,GETDATE(),'Product Name','','',1,1
GO
DELETE FROM FIELDLEVELACCESSDT WHERE TRANSID=13 AND CTRLID=100009
INSERT INTO FIELDLEVELACCESSDT(PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT PrfId,13,100009,0,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode NOT IN ('SMADMIN','ADMIN') 
UNION
SELECT PrfId,13,100009,1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode IN ('SMADMIN','ADMIN') 
GO
DELETE FROM FIELDLEVELACCESSDT WHERE TRANSID=13 AND CTRLID=100003
INSERT INTO FIELDLEVELACCESSDT(PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT PrfId,13,100003,0,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode NOT IN ('SMADMIN','ADMIN') 
UNION
SELECT PrfId,13,100003,1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WHERE PrfCode IN ('SMADMIN','ADMIN') 
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Validate_Product' AND xtype='P')
DROP PROCEDURE Proc_Validate_Product
GO
--EXEC Proc_Validate_Product 0
CREATE PROCEDURE Proc_Validate_Product
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_Product
* PURPOSE		: To Insert and Update records in the Table Product
* CREATED		: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist     AS  INT
	DECLARE @Tabname    AS  NVARCHAR(100)
	DECLARE @DestTabname   AS  NVARCHAR(100)
	DECLARE @Fldname    AS  NVARCHAR(100)
	DECLARE @PrdDCode    AS NVARCHAR(100)
	DECLARE @PrdName   AS NVARCHAR(100)
	DECLARE @PrdShortName  AS NVARCHAR(100)
	DECLARE @PrdCCode   AS NVARCHAR(100)
	DECLARE @PrdCtgValCode  AS NVARCHAR(100)
	DECLARE @StkCoverDays  AS NVARCHAR(100)
	DECLARE @UnitPerSKU   AS NVARCHAR(100)
	DECLARE @TaxGroupCode  AS NVARCHAR(100)
	DECLARE @Weight    AS NVARCHAR(100)
	DECLARE @UnitCode   AS NVARCHAR(100)
	DECLARE @UOMGroupCode  AS NVARCHAR(100)
	DECLARE @PrdType   AS NVARCHAR(100)
	DECLARE @EffectiveFromDate AS NVARCHAR(100)
	DECLARE @EffectiveToDate AS NVARCHAR(100)
	DECLARE @ShelfLife   AS NVARCHAR(100)
	DECLARE @Status    AS NVARCHAR(100)
	DECLARE @Vending   AS NVARCHAR(100)
	DECLARE @PrdVending   AS INT
	DECLARE @EANCode  AS NVARCHAR(100)
	DECLARE @CmpId   AS  INT
	DECLARE @PrdId   AS  INT
	DECLARE @CmpPrdCtgId  AS  INT
	DECLARE @PrdCtgMainId  AS  INT
	DECLARE @SpmId   AS  INT
	DECLARE @PrdUnitId AS  INT
	DECLARE @TaxGroupId AS  INT
	DECLARE @UOMGroupId AS  INT
	DECLARE @PrdTypeId AS  INT
	DECLARE @PrdStatus AS  INT
	SET @Po_ErrNo=0
	SET @Exist=0
	SET @DestTabname='Product'
	SET @Fldname='PrdId'
	SET @Tabname = 'ETL_Prk_Product'
	SET @Exist=0
	SELECT @SpmId=SpmId FROM Supplier WITH (NOLOCK) WHERE SpmDefault=1
	DECLARE Cur_Product CURSOR
	FOR SELECT ISNULL([Product Distributor Code],''),ISNULL([Product Name],''),ISNULL([Product Short Name],''),ISNULL([Product Company Code],''),
	ISNULL([Product Hierarchy Level Value Code],''),ISNULL([Stock Cover Days],0),ISNULL([Unit Per SKU],1),
	ISNULL([Tax Group Code],''),ISNULL([Weight],0),[Unit Code],[UOM Group Code],[Product Type],CONVERT(NVARCHAR(12),[Effective From Date],121),
	CONVERT(NVARCHAR(12),[Effective To Date],121),ISNULL([Shelf Life],0),ISNULL([Status],'ACTIVE'),ISNULL([EAN Code],''),ISNULL([Vending],'NO')
	FROM ETL_Prk_Product
	OPEN Cur_Product
	FETCH NEXT FROM Cur_Product INTO @PrdDCode,@PrdName,@PrdShortName,@PrdCCode,@PrdCtgValCode,
	@StkCoverDays,@UnitPerSKU,@TaxGroupCode,@Weight,@UnitCode,@UOMGroupCode,@PrdType,@EffectiveFromDate,
	@EffectiveToDate,@ShelfLife,@Status,@EANCode,@Vending
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @Exist=0
		IF NOT EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK) WHERE PrdCtgValCode=@PrdCtgValCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Category Level',
			'Product Category Level:'+@PrdCtgValCode+' is not available for the Product Code: '+@PrdDCode)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CmpId=PCL.CmpId FROM ProductCategoryLevel PCL WITH (NOLOCK),
			ProductCategoryValue PCV WITH (NOLOCK)
			WHERE PCV.PrdCtgValCode=@PrdCtgValCode AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId
			IF(SELECT ISNULL(PC.LevelName,'') FROM ProductCategoryValue PCV
			WITH (NOLOCK),ProductCategoryLevel PC WITH (NOLOCK)
			WHERE PCV.PrdCtgValCode=@PrdCtgValCode AND PC.CmpPrdCtgId=PCV.CmpPrdCtgId)<>
			(SELECT TOP 1 PC.LevelName FROM ProductCategoryLevel PC
			WHERE CmpId=@CmpId AND CmpPrdCtgId NOT IN (SELECT MAX(CmpPrdCtgId) FROM  ProductCategoryLevel PC WHERE CmpId=@CmpId)
			ORDER BY PC.CmpPrdCtgId DESC)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Category Level',
				'Product Category Level:'+@PrdCtgValCode+' is not last level in the hierarchy')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdCtgMainId=PrdCtgValMainId FROM ProductCategoryValue WITH (NOLOCK)
				WHERE PrdCtgValCode=@PrdCtgValCode
			END
		END
	
--		IF @Po_ErrNo=0
--		BEGIN
--			IF @TaxGroupCode<>''
--			BEGIN
--				IF NOT EXISTS(SELECT * FROM TaxGroupSetting WITH (NOLOCK)
--				WHERE PrdGroup=@TaxGroupCode)
--				BEGIN
--					INSERT INTO Errorlog VALUES (1,@TabName,'Tax Group',
--					'Tax Group:'+@TaxGroupCode+' is not available for the Product Code: '+@PrdDCode)
--					SET @Po_ErrNo=1
--				END
--				ELSE
--				BEGIN
--					SELECT @TaxGroupId=TaxGroupId FROM TaxGroupSetting WITH (NOLOCK)
--					WHERE PrdGroup=@TaxGroupCode
--				END
--			END
--			ELSE
--			BEGIN
				SET @TaxGroupId=0
--			END
--		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM UOMGroup WITH (NOLOCK) WHERE UOMGroupCode=@UOMGroupCode)
				BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'UOM Group',
				'UOM Group:'+@UOMGroupCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @UOMGroupId=UOMGroupId FROM UOMGroup WITH (NOLOCK) WHERE UOMGroupCode=@UOMGroupCode
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @PrdType='Normal'
			BEGIN
				SET @PrdTypeId=1
			END
			ELSE IF @PrdType='Pesticide'
			BEGIN
				SET @PrdTypeId=2
			END
			ELSE IF @PrdType='Kit Product'
			BEGIN
				SET @PrdTypeId=3
			END
			ELSE IF @PrdType='Gift'
			BEGIN
				SET @PrdTypeId=4
			END
			ELSE IF @PrdType='Drug'
			BEGIN
				SET @PrdTypeId=5
			END
			ELSE IF @PrdType='Food'
			BEGIN
				SET @PrdTypeId=6
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Type',
				'Product Type'+@PrdType+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @PrdTypeId=3 OR @PrdTypeId=5
			BEGIN
				IF ISDATE(@EffectiveFromDate)=1 AND ISDATE(@EffectiveToDate)=1
				BEGIN
					IF DATEDIFF(DD,@EffectiveFromDate,@EffectiveToDate)<0 OR DATEDIFF(DD,GETDATE(),@EffectiveToDate)<0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Effective From Date:' + @EffectiveFromDate + 'should be less than Effective To Date:' +@EffectiveToDate +' for the Product Code: '+@PrdDCode)
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Date',
					'Effective From or To Date is wrong for the Product Code: '+@PrdDCode)
					SET @Po_ErrNo=1
				END
			END
			ELSE
			BEGIN
				IF NOT ISDATE(@EffectiveFromDate)=1
				BEGIN
					SET @EffectiveFromDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				END
	
				IF NOT ISDATE(@EffectiveFromDate)=1
				BEGIN
					SET @EffectiveToDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				END
			END
		END
	
		IF @PrdTypeId=3
		BEGIN
			SET @EffectiveToDate=DATEADD(yy,3,@EffectiveFromDate)
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM ProductUnit WITH (NOLOCK)
			WHERE PrdUnitCode=@UnitCode)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Unit',
				'Product Unit'+@UnitCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdUnitId=PrdUnitId FROM ProductUnit WITH (NOLOCK)
				WHERE PrdUnitCode=@UnitCode
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(@Status)='ACTIVE' OR @Status='1'
			BEGIN
				SET @PrdStatus=1
			END
			ELSE
			BEGIN
			   SET @PrdStatus=2
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(@Vending)='YES'
			BEGIN
				SET @PrdVending=1
			END
			ELSE IF UPPER(@Vending)='NO'
			BEGIN
				SET @PrdVending=0
			END
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode)
			BEGIN
				SET @Exist=0
			END
			ELSE
			BEGIN
				SET @Exist=1
				SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode
				
				--Added By S.Moorthi 19-02-2016 PMS No.: CCRSTPAR0128
				IF EXISTS(SELECT A.PrdId FROM Product A (NOLOCK) INNER JOIN ProductBatchLocation B (NOLOCK) ON A.PrdId=B.PrdId 
				WHERE A.PrdCCode=@PrdCCode AND B.PrdBatLcnSih+B.PrdBatLcnUih+B.PrdBatLcnFre+B.PrdBatLcnRessih+B.PrdBatLcnResUih+B.PrdBatLcnResFre>0)
				BEGIN
					SET @PrdStatus=1
				END
				--Till Here			
			END
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				SELECT @PrdId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
				
				IF @PrdId>(SELECT ISNULL(MAX(PrdId),0) FROM Product(NOLOCK))
				BEGIN
					INSERT INTO Product(PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,
					PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,
					CmpId,PrdCtgValMainId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
					IMEIEnabled,IMEILength,EANCode,Vending,XmlUpload)
					VALUES(@PrdId,@PrdName,@PrdShortName,@PrdDCode,@PrdCCode,@SpmId,@StkCoverDays,@UnitPerSKU,@Weight,
					@PrdUnitId,@UOMGroupId,@TaxGroupId,@PrdTypeId,@EffectiveFromDate,@EffectiveToDate,@ShelfLife,
					@PrdStatus,@CmpId,@PrdCtgMainId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),
					GETDATE(),121),0,0,@EANCode,ISNULL(@PrdVending,0),0)
					UPDATE Counters SET CurrValue=@PrdId WHERE TabName=@DestTabname AND FldName=@FldName
					
					--Added By Sathishkumar Veeramani 2014/07/14 ContractPricing Details Updated
					DELETE A FROM ContractPricingDetails A (NOLOCK) INNER JOIN ContractPricingMaster B (NOLOCK) ON A.ContractId = B.ContractId
					WHERE B.DisplayMode = 1 AND A.PrdId = @PrdId
					
					INSERT INTO ContractPricingDetails (ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,Availability,
					LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId,ClaimablePercOnMRP)
					SELECT DISTINCT ContractId,PrdId,0 AS PrdBatId,0 AS PriceId,Discount,FlatAmtDisc,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),
					1,CONVERT(NVARCHAR(10),GETDATE(),121),CtgValMainId,0 AS ClaimablePercOnMRP FROM (
					SELECT DISTINCT MAX(A.ContractId) AS ContractId,CtgLevelId,CtgMainId,RtrClassId,E.PrdId,Discount,
					FlatAmtDisc,B.CtgValMainId FROM ContractPricingMaster A (NOLOCK) 
					INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId = B.ContractId
					INNER JOIN ProductCategoryValue C (NOLOCK) ON A.CmpPrdCtgId = C.CmpPrdCtgId AND B.CtgValMainId = C.PrdCtgValMainId
					INNER JOIN ProductCategoryValue D (NOLOCK) ON D.PrdCtgValLinkCode LIKE C.PrdCtgValLinkCode+'%'
					INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
					WHERE A.DisplayMode = 1 AND E.PrdId = @PrdId GROUP BY CtgLevelId,CtgMainId,RtrClassId,E.PrdId,Discount,FlatAmtDisc,B.CtgValMainId)Qry
					--Added By Sathishkumar Veeramani 2014/07/14 Till Here
				END
				ELSE
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'System Date',
					'System is showing Date as :'+GETDATE()+'. Please change the System Date/Reset the Counters')
					SET @Po_ErrNo=1
				END
			END
			ELSE
			BEGIN
				EXEC Proc_DependencyCheck 'Product',@PrdId
				IF (SELECT COUNT(*) FROM TempDepCheck)>0
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,PrdShelfLife=@ShelfLife,
					PrdStatus=@PrdStatus,EanCode=@EANCode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
				END
				ELSE
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					UOMGroupId=@UOMGroupId,PrdType=@PrdTypeId,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,
					PrdShelfLife=@ShelfLife,PrdStatus=@PrdStatus,EanCode=@EANcode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
				END
			END
		END
	
		FETCH NEXT FROM Cur_Product INTO @PrdDCode,@PrdName,@PrdShortName,@PrdCCode,@PrdCtgValCode,
		@StkCoverDays,@UnitPerSKU,@TaxGroupCode,@Weight,@UnitCode,@UOMGroupCode,@PrdType,@EffectiveFromDate,
		@EffectiveToDate,@ShelfLife,@Status,@EANCode,@Vending
	END
	CLOSE Cur_Product
	DEALLOCATE Cur_Product
	SET @Po_ErrNo=0
	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateProduct' AND xtype='P')
DROP PROCEDURE Proc_ValidateProduct
GO
CREATE PROCEDURE Proc_ValidateProduct
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE : Proc_ValidateProduct
* PURPOSE : To Insert and Update records in the Table Product
* CREATED : Nandakumar R.G
* CREATED DATE : 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist     AS  INT
	DECLARE @Tabname    AS  NVARCHAR(100)
	DECLARE @DestTabname   AS  NVARCHAR(100)
	DECLARE @Fldname    AS  NVARCHAR(100)
	DECLARE @PrdDCode    AS NVARCHAR(100)
	DECLARE @PrdName   AS NVARCHAR(100)
	DECLARE @PrdShortName  AS NVARCHAR(100)
	DECLARE @PrdCCode   AS NVARCHAR(100)
	DECLARE @PrdCtgValCode  AS NVARCHAR(100)
	DECLARE @SpmCode   AS NVARCHAR(100)
	DECLARE @StkCoverDays  AS NVARCHAR(100)
	DECLARE @UnitPerSKU   AS NVARCHAR(100)
	DECLARE @TaxGroupCode  AS NVARCHAR(100)
	DECLARE @Weight    AS NVARCHAR(100)
	DECLARE @UnitCode   AS NVARCHAR(100)
	DECLARE @UOMGroupCode  AS NVARCHAR(100)
	DECLARE @PrdType   AS NVARCHAR(100)
	DECLARE @EffectiveFromDate AS NVARCHAR(100)
	DECLARE @EffectiveToDate AS NVARCHAR(100)
	DECLARE @ShelfLife   AS NVARCHAR(100)
	DECLARE @Status    AS NVARCHAR(100)
	DECLARE @Vending   AS NVARCHAR(100)
	DECLARE @PrdVending   AS INT
	DECLARE @EANCode  AS NVARCHAR(100)
	DECLARE @CmpId   AS  INT
	DECLARE @PrdId   AS  INT
	DECLARE @CmpPrdCtgId  AS  INT
	DECLARE @PrdCtgMainId  AS  INT
	DECLARE @SpmId   AS  INT
	DECLARE @PrdUnitId AS  INT
	DECLARE @TaxGroupId AS  INT
	DECLARE @UOMGroupId AS  INT
	DECLARE @PrdTypeId AS  INT
	DECLARE @PrdStatus AS  INT
	DECLARE @TransStr  AS  NVARCHAR(4000)
	SET @Po_ErrNo=0
	SET @Exist=0
	SET @DestTabname='Product'
	SET @Fldname='PrdId'
	SET @Tabname = 'ETL_Prk_Product'
	SET @Exist=0
	DECLARE Cur_Product CURSOR
	FOR SELECT ISNULL([Product Distributor Code],''),ISNULL([Product Name],''),ISNULL([Product Short Name],''),ISNULL([Product Company Code],''),
	ISNULL([Product Hierarchy Level Value Code],''),ISNULL([Supplier Code],''),ISNULL([Stock Cover Days],0),[Unit Per SKU],
	ISNULL([Tax Group Code],''),[Weight],[Unit Code],[UOM Group Code],[Product Type],CONVERT(NVARCHAR(12),[Effective From Date],121),
	CONVERT(NVARCHAR(12),[Effective To Date],121),ISNULL([Shelf Life],0),ISNULL([Status],'Active'),ISNULL([EAN Code],''),ISNULL([Vending],'NO')
	FROM ETL_Prk_Product
	OPEN Cur_Product
	FETCH NEXT FROM Cur_Product INTO @PrdDCode,@PrdName,@PrdShortName,@PrdCCode,@PrdCtgValCode,@SpmCode,
	@StkCoverDays,@UnitPerSKU,@TaxGroupCode,@Weight,@UnitCode,@UOMGroupCode,@PrdType,@EffectiveFromDate,
	@EffectiveToDate,@ShelfLife,@Status,@EANCode,@Vending
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @Exist=0
		IF NOT EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK) WHERE PrdCtgValCode=@PrdCtgValCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Category Level',
			'Product Category Level:'+@PrdCtgValCode+' is not available for the Product Code: '+@PrdDCode)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CmpId=PCL.CmpId FROM ProductCategoryLevel PCL WITH (NOLOCK),
			ProductCategoryValue PCV WITH (NOLOCK)
			WHERE PCV.PrdCtgValCode=@PrdCtgValCode AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId
			IF(SELECT ISNULL(PC.LevelName,'') FROM ProductCategoryValue PCV
			WITH (NOLOCK),ProductCategoryLevel PC WITH (NOLOCK)
			WHERE PCV.PrdCtgValCode=@PrdCtgValCode AND PC.CmpPrdCtgId=PCV.CmpPrdCtgId)<>
			(SELECT TOP 1 PC.LevelName FROM ProductCategoryLevel PC
			WHERE CmpId=@CmpId AND CmpPrdCtgId NOT IN (SELECT MAX(CmpPrdCtgId) FROM  ProductCategoryLevel PC WHERE CmpId=@CmpId)
			ORDER BY PC.CmpPrdCtgId DESC)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Category Level',
				'Product Category Level:'+@PrdCtgValCode+' is not last level in the hierarchy')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdCtgMainId=PrdCtgValMainId FROM ProductCategoryValue WITH (NOLOCK)
				WHERE PrdCtgValCode=@PrdCtgValCode
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Supplier WITH (NOLOCK)
			WHERE SpmCode=@SpmCode)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Supplier',
				'Supplier:'+@SpmCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @SpmId=SpmId FROM Supplier WITH (NOLOCK)
				WHERE SpmCode=@SpmCode
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @TaxGroupCode<>''
			BEGIN
				IF NOT EXISTS(SELECT * FROM TaxGroupSetting WITH (NOLOCK)
				WHERE PrdGroup=@TaxGroupCode)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Tax Group',
					'Tax Group:'+@TaxGroupCode+' is not available for the Product Code: '+@PrdDCode)
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @TaxGroupId=TaxGroupId FROM TaxGroupSetting WITH (NOLOCK)
					WHERE PrdGroup=@TaxGroupCode
				END
			END
			ELSE
			BEGIN
				SET @TaxGroupId=0
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM UOMGroup WITH (NOLOCK)
			WHERE UOMGroupCode=@UOMGroupCode)
				BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'UOM Group',
				'UOM Group:'+@UOMGroupCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @UOMGroupId=UOMGroupId FROM UOMGroup WITH (NOLOCK)
				WHERE UOMGroupCode=@UOMGroupCode
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@PrdDCode))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',
				'Product Code should not be empty')
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@PrdName))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Name',
				'Product Name should not be empty for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@Vending))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Vending',
				'Vending should not be empty for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@PrdShortName))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Short Name',
				'Product Short Name should not be empty for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@PrdCCode))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Company Code',
				'Product Company Code should not be empty for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF NOT ISNUMERIC(@StkCoverDays)=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Stock Cover Days',
				'Stock Cover Days should be in numeric for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF NOT ISNUMERIC(@UnitPerSKU)=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Unit per SKU',
				'Unit per SKU should be in numeric for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF NOT ISNUMERIC(@Weight)=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Weight',
				'Weight should be in numeric for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @PrdType='Normal'
			BEGIN
				SET @PrdTypeId=1
			END
			ELSE IF @PrdType='Pesticide'
			BEGIN
				SET @PrdTypeId=2
			END
			ELSE IF @PrdType='Kit Product'
			BEGIN
				SET @PrdTypeId=3
			END
			ELSE IF @PrdType='Gift'
			BEGIN
				SET @PrdTypeId=4
			END
			ELSE IF @PrdType='Drug'
			BEGIN
				SET @PrdTypeId=5
			END
			ELSE IF @PrdType='Food'
			BEGIN
				SET @PrdTypeId=6
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Type',
				'Product Type'+@PrdType+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @PrdTypeId=3 OR @PrdTypeId=5
			BEGIN
				IF ISDATE(@EffectiveFromDate)=1 AND ISDATE(@EffectiveToDate)=1
				BEGIN
					IF DATEDIFF(DD,@EffectiveFromDate,@EffectiveToDate)<0 OR DATEDIFF(DD,GETDATE(),@EffectiveToDate)<0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Effective From Date:' + @EffectiveFromDate + 'should be less than Effective To Date:' +@EffectiveToDate +' for the Product Code: '+@PrdDCode)
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Date',
					'Effective From or To Date is wrong for the Product Code: '+@PrdDCode)
					SET @Po_ErrNo=1
				END
			END
			ELSE
			BEGIN
				IF NOT ISDATE(@EffectiveFromDate)=1
				BEGIN
					SET @EffectiveFromDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				END
	
				IF NOT ISDATE(@EffectiveFromDate)=1
				BEGIN
					SET @EffectiveToDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				END
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM ProductUnit WITH (NOLOCK)
			WHERE PrdUnitCode=@UnitCode)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Unit',
				'Product Unit'+@UnitCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdUnitId=PrdUnitId FROM ProductUnit WITH (NOLOCK)
				WHERE PrdUnitCode=@UnitCode
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF @Status='Active' OR @Status='1'
			BEGIN
				SET @PrdStatus=1
			END
			ELSE
			BEGIN
				SET @PrdStatus=2
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(@Vending)='YES'
			BEGIN
				SET @PrdVending=1
			END
			ELSE IF UPPER(@Vending)='NO'
			BEGIN
				SET @PrdVending=0
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode)
			BEGIN
				SET @Exist=0
			END
			ELSE
			BEGIN
				SET @Exist=1
				SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode
				
				--Added By S.Moorthi 19-02-2016 PMS No.: CCRSTPAR0128
				IF EXISTS(SELECT A.PrdId FROM Product A (NOLOCK) INNER JOIN ProductBatchLocation B (NOLOCK) ON A.PrdId=B.PrdId 
				WHERE A.PrdCCode=@PrdCCode AND B.PrdBatLcnSih+B.PrdBatLcnUih+B.PrdBatLcnFre+B.PrdBatLcnRessih+B.PrdBatLcnResUih+B.PrdBatLcnResFre>0)
				BEGIN
					SET @PrdStatus=1
				END
				--Till Here	
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				SELECT @PrdId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
				
				IF @PrdId>0
				BEGIN
					INSERT INTO Product
					(PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,
					PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
					EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,
					Availability,LastModBy,LastModDate,AuthId,AuthDate,IMEIEnabled,IMEILength,EANCode,Vending)
					VALUES(@PrdId,@PrdName,@PrdShortName,@PrdDCode,@PrdCCode,
					@SpmId,@StkCoverDays,@UnitPerSKU,@Weight,@PrdUnitId,@UOMGroupId,@TaxGroupId,
					@PrdTypeId,@EffectiveFromDate,@EffectiveToDate,@ShelfLife,@PrdStatus,
					@CmpId,@PrdCtgMainId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0,0,@EANCode,ISNULL(@PrdVending,0))
					SET @TransStr='INSERT INTO Product
					(PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,
					PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
					EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,
					Availability,LastModBy,LastModDate,AuthId,AuthDate,IMEIEnabled,IMEILength,EANCode,Vending)
					VALUES('+CAST(@PrdId AS NVARCHAR(10))+','''+@PrdName+''','''+@PrdShortName+''','''+
					@PrdDCode+''','''+@PrdCCode+''','+CAST(@SpmId AS NVARCHAR(10))+','+CAST(@StkCoverDays AS NVARCHAR(10))+','+CAST(@UnitPerSKU AS NVARCHAR(10))+','+
					CAST(@Weight AS NVARCHAR(10))+','+CAST(@PrdUnitId AS NVARCHAR(10))+','+CAST(@UOMGroupId AS NVARCHAR(10))+','+
					CAST(@TaxGroupId AS NVARCHAR(10))+','+CAST(@PrdTypeId AS NVARCHAR(10))+','''+CONVERT(NVARCHAR(10),@EffectiveFromDate,121)+''','''+CONVERT(NVARCHAR(10),@EffectiveToDate,121)+''','+
					CAST(@ShelfLife AS NVARCHAR(10))+','+CAST(@PrdStatus AS NVARCHAR(10))+','+
					CAST(@CmpId AS NVARCHAR(10))+','+CAST(@PrdCtgMainId AS NVARCHAR(10))+',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+
					''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',0,0'+CAST(@EANCode AS NVARCHAR(10))+ ',' +CAST(@PrdVending AS NVARCHAR(10))+')'
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
					UPDATE Counters SET CurrValue=@PrdId WHERE TabName=@DestTabname AND FldName=@FldName
					SET @TransStr='UPDATE Counters SET CurrValue='+CAST(@PrdId AS NVARCHAR(10))+
					' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
				END
				ELSE
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'System Date',
					'System is showing Date as :'+GETDATE()+'. Please change the System Date')
					SET @Po_ErrNo=1
				END
			END
			ELSE
			BEGIN
				EXEC Proc_DependencyCheck 'Product',@PrdId
				IF (SELECT COUNT(*) FROM TempDepCheck)>0
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,PrdShelfLife=@ShelfLife,
					PrdStatus=@PrdStatus,EanCode=@EANCode,Vending=ISNULL(@PrdVending,0)
					WHERE PrdId=@PrdId
					SET @TransStr='UPDATE Product SET SpmId='+CAST(@SpmId AS NVARCHAR(10))+',StkCovDays='+
					CAST(@StkCoverDays AS NVARCHAR(10))+',PrdUpSKU='+CAST(@UnitPerSKU AS NVARCHAR(10))+
					',TaxGroupId='+CAST(@TaxGroupId AS NVARCHAR(10))+',EffectiveFrom='''+CONVERT(NVARCHAR(10),@EffectiveFromDate,121)+''','
					+'EffectiveTo='''+CONVERT(NVARCHAR(10),@EffectiveToDate,121)+''',PrdShelfLife='+CAST(@ShelfLife AS NVARCHAR(10))+
					',PrdStatus='+CAST(@PrdStatus AS NVARCHAR(10))+',EanCode='+ @EanCode + ',Vending='+ CAST(@PrdVending AS NVARCHAR(10)) +' WHERE PrdId='+CAST(@PrdId AS NVARCHAR(10))+''
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
				END
				ELSE
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					UOMGroupId=@UOMGroupId,PrdType=@PrdTypeId,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,
					PrdShelfLife=@ShelfLife,PrdStatus=@PrdStatus,EanCode=@EANcode,Vending=ISNULL(@PrdVending,0)
					WHERE PrdId=@PrdId
					SET @TransStr='UPDATE Product SET SpmId='+CAST(@SpmId AS NVARCHAR(10))+
					',StkCovDays='+CAST(@StkCoverDays AS NVARCHAR(10))+',PrdUpSKU='+CAST(@UnitPerSKU AS NVARCHAR(10))+
					',UOMGroupId='+CAST(@UOMGroupId AS NVARCHAR(10))+',TaxGroupId='+CAST(@TaxGroupId AS NVARCHAR(10))+
					',PrdType='+CAST(@PrdTypeId AS NVARCHAR(10))+',EffectiveFrom='''+CONVERT(NVARCHAR(10),@EffectiveFromDate,121)+''',EffectiveTo='''
					+CONVERT(NVARCHAR(10),@EffectiveToDate,121)+''',PrdShelfLife='+CAST(@ShelfLife AS NVARCHAR(10))+',PrdStatus='+CAST(@PrdStatus AS NVARCHAR(10))+
					',EanCode='+ @EanCode + ',Vending='+ CAST(@PrdVending AS NVARCHAR(10)) +
					' WHERE PrdId='+CAST(@PrdId AS NVARCHAR(10))+''
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
				END
			END
		END
	
		FETCH NEXT FROM Cur_Product INTO @PrdDCode,@PrdName,@PrdShortName,@PrdCCode,@PrdCtgValCode,@SpmCode,
		@StkCoverDays,@UnitPerSKU,@TaxGroupCode,@Weight,@UnitCode,@UOMGroupCode,@PrdType,@EffectiveFromDate,
		@EffectiveToDate,@ShelfLife,@Status,@EANCode,@Vending
	END
	CLOSE Cur_Product
	DEALLOCATE Cur_Product
	SET @Po_ErrNo=0
	RETURN
END
GO
DELETE FROM RptGroup where RptId=287
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'SchemeNClaimReport',287,'SchemeUtilizationDetailsReport','Scheme Utilization Details Report',1
GO
DELETE FROM RptGridView where RptId=287
INSERT INTO RptGridView(RptId,RptName,CrystalView,GridView,ExcelView,PDFView)
SELECT 287,'RptParleClaimReport.rpt',1,0,1,0
GO
DELETE FROM RptHeader where RptId=287
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'SchemeUtilizationDetailsReport','Scheme Utilization Details Report',287,'Scheme Utilization Details Report','Proc_RptSchemeUtilizationDetailsReport','RptSchemeUtilizationDetailsReport','RptSchemeUtilizationDetailsReport.rpt',''
GO
DELETE FROM RptDetails where RptId=287
INSERT INTO Rptdetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
SELECT 287,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0 UNION
SELECT 287,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0 UNION
SELECT 287,3,'SchemeMaster',-1,NULL,'SchId,SchCode,SchDsc','Scheme...',NULL,1,'',8,1,0,'Press F4/Double Click to select Scheme',0 
GO
DELETE FROM RptFormula WHERE RptId=287
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) 
SELECT 287,1,'Disp_FromDate','From Date',1,0 UNION
SELECT 287,2,'Disp_ToDate','To Date',1,0 UNION
SELECT 287,3,'Fil_FromDate','From Date',1,10 UNION
SELECT 287,4,'Fil_ToDate','To Date',1,11 UNION
SELECT 287,5,'Disp_SchCode','Scheme Code :',1,0 UNION
SELECT 287,6,'Disp_SchDesc','Scheme Desc :',1,0 UNION
SELECT 287,7,'Disp_SchPeriod','Scheme Period :',1,0 UNION
SELECT 287,8,'Disp_SchSlab','Slab As per circular',1,0 UNION
SELECT 287,9,'Disp_Retailer','Retailer Name',1,0 UNION
SELECT 287,10,'Disp_Route','Route Name',1,0 UNION
SELECT 287,11,'Disp_BillDetails','Bill Details',1,0 UNION
SELECT 287,12,'Disp_BillNo','No.',1,0 UNION
SELECT 287,13,'Disp_SchemeSale','Scheme Sale in',1,0 UNION
SELECT 287,14,'Disp_QtyinKgs','Qty in Kgs',1,0 UNION
SELECT 287,15,'Disp_ValueinLctr','Value in Lctr',1,0 UNION
SELECT 287,16,'Disp_Liability','Liability in ',1,0 UNION
SELECT 287,17,'Disp_LiabilityValue','Value',1,0 UNION
SELECT 287,18,'Disp_LiabilityPerc','%',1,0 UNION
SELECT 287,19,'Disp_FreeProduct','Free Products',1,0 UNION
SELECT 287,20,'Disp_FPName','Name',1,0 UNION
SELECT 287,21,'Disp_FreeQty','Qty',1,0 UNION
SELECT 287,22,'CapUserName','User Name',1,0 UNION
SELECT 287,23,'Disp_BillDate','Date',1,0 UNION
SELECT 287,24,'Disp_Total','Total',1,0 UNION
SELECT 287,25,'Disp_GrandTotal','Grand Total',1,0 UNION
SELECT 287,26,'Disp_Scheme','Scheme..',1,0 UNION
SELECT 287,27,'Fill_Scheme','Scheme',1,8 
GO
DELETE FROM RptExcelHeaders WHERE RptId=287
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
SELECT 287,1,'SchId','SchId',0,0 UNION
SELECT 287,2,'SchCode','Scheme Code',1,1 UNION
SELECT 287,3,'CmpSchCode','Company Scheme Code',1,1 UNION
SELECT 287,4,'SchDesc','Scheme Desc',1,1 UNION
SELECT 287,5,'SchPeriod','Scheme Period',1,1 UNION
SELECT 287,6,'SchSlab','Scheme Slab',1,1 UNION
SELECT 287,7,'RtrCode','Retailer Code',0,0 UNION
SELECT 287,8,'RtrName','Retailer Name',1,1 UNION
SELECT 287,9,'RMCode','Route Code',0,0 UNION
SELECT 287,10,'RMCode','Route Name',1,1 UNION
SELECT 287,11,'SalInvNo','Bill No',1,1 UNION
SELECT 287,12,'SalInvDate','Bill Date',1,1 UNION
SELECT 287,13,'SchQtyinKG','Scheme Sale Qty in KG',1,1 UNION
SELECT 287,14,'SchValueinLctr','Scheme Sale in Value Lctr',1,1 UNION
SELECT 287,15,'LiabilityValue','Liability in Value',1,1 UNION
SELECT 287,16,'LiabilityPerc','Liability in Perc',1,1 UNION
SELECT 287,17,'FreePrdCode','Free Product Code',1,1 UNION
SELECT 287,18,'FreePrdName','Free Product Name',1,1 UNION
SELECT 287,19,'FreeQty','FreeQty',1,1 
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_RptSchemeUtilizationDetailsReport' AND XTYPE='P')
DROP PROCEDURE Proc_RptSchemeUtilizationDetailsReport
GO
--EXEC Proc_RptSchemeUtilizationDetailsReport 287,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptSchemeUtilizationDetailsReport
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptSchemeUtilizationDetailsReport
* PURPOSE	: To Return the Scheme Utilization Details
* CREATED	: S.Moorthi
* CREATED DATE	: 24/02/2016
* NOTE		: Parle SP for Scheme Utilization Details
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/  
BEGIN
	SET NOCOUNT ON
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @SchId		AS	INT
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SchId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))
	
	CREATE TABLE #RptSchemeUtilizationDetailsReport
	(
			SchId				BIGINT,
			SchCode				NVARCHAR(50)  COLLATE DATABASE_DEFAULT,
			CmpSchCode			NVARCHAR(50)  COLLATE DATABASE_DEFAULT,
			SchDesc				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			SchPeriod			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			SchSlab				INT,
			RtrCode				VARCHAR(50),
			Rtrname				VARCHAR(200),
			RMCode				VARCHAR(50),
			RMname				VARCHAR(200),
			SalInvNo			NVARCHAR(50)  COLLATE DATABASE_DEFAULT,
			SalInvDate			DATETIME,
			SchQtyinKG			NUMERIC(18,2),
			SchValueinLctr		NUMERIC(18,3),
			LiabilityValue		NUMERIC(18,3),
			LiabilityPerc		NUMERIC(18,2),
			FreePrdCode			VARCHAR(100),
			FreePrdName			VARCHAR(200),
			FreeQty					INT
	  )
	    
	  
		CREATE TABLE #TempSalesFreeProduct
		(
			SalId				INT,
			ReturnId			INT,
			SchId				INT,
			SchQtyinKG			NUMERIC(18,3),
			SchValueinLctr		NUMERIC(18,3),
			RefType				INT
		)
	
	
		INSERT INTO #TempSalesFreeProduct(SalId,ReturnId,SchId,SchQtyinKG,SchValueinLctr,RefType)
		SELECT SalId,0,SchId,SUM(SchQtyinKG) AS SchQtyinKG,SUM(SchValueinLctr) AS SchValueinLctr,0
		FROM (
				SELECT A.SalId,C.SchId,B.PrdId,
				ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * B.BaseQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * B.BaseQty),0) END,0) AS SchQtyinKG,	  
				SUM(PrdGrossAmount+PrdTaxAmount) as SchValueinLctr FROM SalesInvoice A (NOLOCK)
				INNER JOIN SalesInvoiceProduct B (NOLOCK) ON A.SalId=B.SalId
				INNER JOIN SalesInvoiceSchemeDtBilled C (NOLOCK) ON A.SalId=C.SalId AND C.SalId=B.SalId AND C.PrdId=B.PrdId AND B.PrdBatId=C.PrdBatId
				INNER JOIN Product D (NOLOCK) ON D.PrdId=C.PrdId AND D.PrdId=B.PrdId
				INNER JOIN (SELECT DISTINCT SchId FROM SalesInvoiceSchemeDtFreePrd (NOLOCK))N ON N.SCHID=C.SCHID
				WHERE A.SalInvDate Between @FromDate and @ToDate AND A.DlvSts>=4
					AND C.SCHID=(CASE @SchId WHEN 0 THEN C.SCHID ELSE @SchId END)	  
				GROUP BY A.SalId,C.SchId,B.PrdId,D.PrdUnitId
		)X GROUP BY SalId,SchId
			
		INSERT INTO #TempSalesFreeProduct(SalId,ReturnId,SchId,SchQtyinKG,SchValueinLctr,RefType)
		SELECT SalId,ReturnId,SchId,SUM(SchQtyinKG) AS SchQtyinKG,SUM(SchValueinLctr) AS SchValueinLctr,1
		FROM (
				SELECT B.SalId,A.ReturnId,C.SchId,B.PrdId,
				ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * B.BaseQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * B.BaseQty),0) END,0) AS SchQtyinKG,	  
				SUM(PrdGrossAmt+PrdTaxAmt) as SchValueinLctr FROM ReturnHeader A (NOLOCK)
				INNER JOIN ReturnProduct B (NOLOCK) ON A.ReturnId=B.ReturnId
				INNER JOIN SalesInvoice S (NOLOCK) ON S.SalId=B.SalId
				INNER JOIN ReturnSchemeLineDt C (NOLOCK) ON C.ReturnId=A.ReturnId AND C.ReturnId=B.ReturnId AND C.PrdId=B.PrdId AND C.PrdBatId=B.PrdBatId
				INNER JOIN Product D (NOLOCK) ON D.PrdId=C.PrdId AND D.PrdId=B.PrdId	  
				INNER JOIN (SELECT DISTINCT SchId FROM ReturnSchemeFreePrdDt (NOLOCK))N ON N.SCHID=C.SCHID
				WHERE A.ReturnDate Between @FromDate and @ToDate AND A.STATUS=0 
					AND C.SCHID=(CASE @SchId WHEN 0 THEN C.SCHID ELSE @SchId END)
				GROUP BY B.SalId,A.ReturnId,C.SchId,B.PrdId,D.PrdUnitId
		)X GROUP BY SalId,ReturnId,SchId
		
		INSERT INTO #RptSchemeUtilizationDetailsReport(SchId,SchCode,CmpSchCode,SchDesc,SchPeriod,SchSlab,RtrCode,Rtrname,
		RMCode,RMname,SalInvNo,SalInvDate,SchQtyinKG,SchValueinLctr,LiabilityValue,LiabilityPerc,FreePrdCode,FreePrdName,FreeQty)
		SELECT SchId,SchCode,CmpSchCode,SchDesc,SchPeriod,SchSlab,RtrCode,Rtrname,
		RMCode,RMname,SalInvNo,SalInvDate,SUM(ISNULL(SchQtyinKG,0)) AS SchQtyinKG,SUM(ISNULL(SchValueinLctr,0)) AS SchValueinLctr,
		LiabilityValue,LiabilityPerc,FreePrdCode,FreePrdName,FreeQty FROM
		(	  
			SELECT SM.SchId,SM.SchCode,SM.CmpSchCode,SM.SchDsc AS SchDesc,CONVERT(VARCHAR(10),SM.SchValidFrom,105)+' - '+CONVERT(VARCHAR(10),SM.SchValidTill,105) AS SchPeriod,
			SS.SlabId AS SchSlab,R.RtrCode,R.RtrName,RM.RmCode,RM.RmName,SI.SalInvNo,SI.SalInvDate,0 As PrdId,
			SUM(TSF.SchQtyinKG) AS SchQtyinKG,SUM(TSF.SchValueinLctr) as SchValueinLctr,0 as LiabilityValue,0 LiabilityPerc,P.PrdDCode FreePrdCode,P.PrdName FreePrdName,SUM(FreeQty+GiftQty) as  FreeQty
			FROM SALESINVOICE SI (NOLOCK)
			INNER JOIN Retailer R (NOLOCK) ON R.RtrId=SI.RtrId 
			INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=SI.RmId
			INNER JOIN SalesInvoiceSchemeDtFreePrd SISL (NOLOCK) ON SISL.SalId=SI.SalId 	
			INNER JOIN Product P (NOLOCK) ON P.PrdId=(CASE SISL.FreePrdId WHEN 0 THEN SISL.GiftPrdId ELSE SISL.FreePrdId END)
			INNER JOIN SchemeMaster SM(NOLOCK) ON SM.SCHID=SISL.SCHID
			INNER JOIN SchemeSlabs SS(NOLOCK) ON SS.SchId=SM.SchId AND SS.SchId=SISL.SchId AND SS.SlabId=SISL.SlabId
			INNER JOIN #TempSalesFreeProduct TSF ON TSF.SalId=SI.SalId AND TSF.SalId=SISL.SalId AND TSF.SchId=SM.SCHID AND TSF.SchId=SS.SchId 
										AND TSF.SchId=SISL.SchId AND TSF.RefType=0
			WHERE SI.SalInvDate Between @FromDate and @ToDate AND SI.DlvSts>=4
			AND SM.SCHID=(CASE @SchId WHEN 0 THEN SM.SCHID ELSE @SchId END)
			GROUP BY SM.SchId,SM.SchCode,SM.CmpSchCode,SM.SchDsc,SM.SchValidFrom,SM.SchValidTill,
			SS.SlabId,R.RtrCode,R.RtrName,RM.RmCode,RM.RmName,SI.SalInvNo,SI.SalInvDate,P.PrdDCode,P.PrdName
			UNION ALL 
			SELECT SM.SchId,SM.SchCode,SM.CmpSchCode,SM.SchDsc AS SchDesc,CONVERT(VARCHAR(10),SM.SchValidFrom,105)+' - '+CONVERT(VARCHAR(10),SM.SchValidTill,105) AS SchPeriod,
			SS.SlabId AS SchSlab,R.RtrCode,R.RtrName,RM.RmCode,RM.RmName,S.SalInvNo,S.SalInvDate,0 As PrdId,
			-1*SUM(TSF.SchQtyinKG) AS SchQtyinKG,-1*SUM(TSF.SchValueinLctr) as SchValueinLctr,0 as LiabilityValue,0 LiabilityPerc,P.PrdDCode FreePrdCode,P.PrdName FreePrdName,-1*SUM(ReturnFreeQty+ReturnGiftQty) as  FreeQty
			FROM ReturnHeader SI (NOLOCK)
			INNER JOIN Retailer R (NOLOCK) ON R.RtrId=SI.RtrId 
			INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=SI.RmId
			INNER JOIN ReturnSchemeFreePrdDt SISL (NOLOCK) ON SISL.ReturnId=SI.ReturnId
			INNER JOIN SalesInvoice S(NOLOCK) ON S.SalId=SISL.SalId AND S.RtrId=R.RtrId AND S.RMId=RM.RMId AND S.RtrId=SI.RtrId AND S.RMId=SI.RMId
			INNER JOIN Product P (NOLOCK) ON P.PrdId=(CASE SISL.FreePrdId WHEN 0 THEN SISL.GiftPrdId ELSE SISL.FreePrdId END)
			INNER JOIN SchemeMaster SM(NOLOCK) ON SM.SCHID=SISL.SCHID
			INNER JOIN SchemeSlabs SS(NOLOCK) ON SS.SchId=SM.SchId AND SS.SchId=SISL.SchId AND SS.SlabId=SISL.SlabId
			INNER JOIN #TempSalesFreeProduct TSF ON TSF.ReturnID=SI.ReturnID AND TSF.ReturnID=SISL.ReturnId AND TSF.SchId=SM.SCHID AND TSF.SchId=SS.SchId 
										AND TSF.SalId=SISL.SalId AND TSF.SalId=S.SalId AND TSF.SchId=SISL.SchId AND TSF.RefType=1 
			WHERE SI.ReturnDate Between @FromDate and @ToDate AND SI.STATUS=0 
			AND SM.SCHID=(CASE @SchId WHEN 0 THEN SM.SCHID ELSE @SchId END)
			GROUP BY SM.SchId,SM.SchCode,SM.CmpSchCode,SM.SchDsc,SM.SchValidFrom,SM.SchValidTill,
			SS.SlabId,R.RtrCode,R.RtrName,RM.RmCode,RM.RmName,S.SalInvNo,S.SalInvDate,P.PrdDCode,P.PrdName
		)X GROUP BY SchId,SchCode,CmpSchCode,SchDesc,SchPeriod,SchSlab,
		RtrCode,RtrName,RmCode,RmName,SalInvNo,SalInvDate,LiabilityValue,LiabilityPerc,FreePrdCode,FreePrdName,FreeQty

	  INSERT INTO #RptSchemeUtilizationDetailsReport(SchId,SchCode,CmpSchCode,SchDesc,SchPeriod,SchSlab,RtrCode,Rtrname,
	  RMCode,RMname,SalInvNo,SalInvDate,SchQtyinKG,SchValueinLctr,LiabilityValue,LiabilityPerc,FreePrdCode,FreePrdName,FreeQty)
	  SELECT SchId,SchCode,CmpSchCode,SchDesc,SchPeriod,SchSlab,RtrCode,Rtrname,
	  RMCode,RMname,SalInvNo,SalInvDate,SUM(ISNULL(SchQtyinKG,0)) AS SchQtyinKG,SUM(ISNULL(SchValueinLctr,0)) AS SchValueinLctr,
	  LiabilityValue,LiabilityPerc,FreePrdCode,FreePrdName,FreeQty FROM
	  (
			SELECT SM.SchId,SM.SchCode,SM.CmpSchCode,SM.SchDsc AS SchDesc,CONVERT(VARCHAR(10),SM.SchValidFrom,105)+' - '+CONVERT(VARCHAR(10),SM.SchValidTill,105) AS SchPeriod,
			SS.SlabId AS SchSlab,R.RtrCode,R.RtrName,RM.RmCode,RM.RmName,SI.SalInvNo,SI.SalInvDate,SIP.PrdId,
			ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchQtyinKG,	  
			SUM(PrdGrossAmount+PrdTaxAmount) as SchValueinLctr,0 as LiabilityValue,0 LiabilityPerc,'' FreePrdCode,'' FreePrdName,0 FreeQty
			FROM SALESINVOICE SI (NOLOCK)
			INNER JOIN Retailer R (NOLOCK) ON R.RtrId=SI.RtrId 
			INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=SI.RmId
			INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SIP.SalId=SI.SalId
			INNER JOIN Product D (NOLOCK) ON D.PrdId=SIP.PrdId
			INNER JOIN SalesInvoiceSchemeLineWise SISL (NOLOCK) ON SISL.SalId=SIP.SalId AND SISL.SalId=SI.SalId AND SISL.PrdId=SIP.PrdId and D.PrdId=SISL.PrdId AND SISL.PrdBatId=SIP.PrdBatId	  			
			INNER JOIN SchemeMaster SM(NOLOCK) ON SM.SCHID=SISL.SCHID
			INNER JOIN SchemeSlabs SS(NOLOCK) ON SS.SchId=SM.SchId AND SS.SchId=SISL.SchId AND SS.SlabId=SISL.SlabId
			WHERE SI.SalInvDate Between @FromDate and @ToDate AND SI.DlvSts>=4
			AND SM.SCHID=(CASE @SchId WHEN 0 THEN SM.SCHID ELSE @SchId END)
			GROUP BY SM.SchId,SM.SchCode,SM.CmpSchCode,SM.SchDsc,SM.SchValidFrom,SM.SchValidTill,
			SS.SlabId,R.RtrCode,R.RtrName,RM.RmCode,RM.RmName,SI.SalInvNo,SI.SalInvDate,SIP.PrdId,D.PrdUnitId
			UNION ALL
			SELECT SM.SchId,SM.SchCode,SM.CmpSchCode,SM.SchDsc AS SchDesc,CONVERT(VARCHAR(10),SM.SchValidFrom,105)+' - '+CONVERT(VARCHAR(10),SM.SchValidTill,105) AS SchPeriod,
			SS.SlabId AS SchSlab,R.RtrCode,R.RtrName,RM.RmCode,RM.RmName,S.SalInvNo,S.SalInvDate,SIP.PrdId,
			-1*ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchQtyinKG,	  
			-1*SUM(SIP.PrdGrossAmt+PrdTaxAmt) as SchValueinLctr,0 as LiabilityValue,0 LiabilityPerc,'' FreePrdCode,'' FreePrdName,0 FreeQty
			FROM ReturnHeader SI (NOLOCK)
			INNER JOIN Retailer R (NOLOCK) ON R.RtrId=SI.RtrId 
			INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=SI.RmId
			INNER JOIN ReturnProduct SIP (NOLOCK) ON SIP.ReturnId=SI.ReturnId
			INNER JOIN SalesInvoice S (NOLOCK) ON S.SalId=SIP.SalId AND S.RtrId=R.RtrId AND S.RMId=RM.RMId AND S.RtrId=SI.RtrId AND S.RMId=SI.RMId
			INNER JOIN Product D (NOLOCK) ON D.PrdId=SIP.PrdId
			INNER JOIN ReturnSchemeLineDt SISL (NOLOCK) ON SISL.ReturnId=SIP.ReturnId AND SISL.ReturnId=SI.ReturnId AND SISL.PrdId=SIP.PrdId and D.PrdId=SISL.PrdId AND SISL.PrdBatId=SIP.PrdBatId
			INNER JOIN SchemeMaster SM(NOLOCK) ON SM.SCHID=SISL.SCHID
			INNER JOIN SchemeSlabs SS(NOLOCK) ON SS.SchId=SM.SchId AND SS.SchId=SISL.SchId AND SS.SlabId=SISL.SlabId
			WHERE SI.ReturnDate Between @FromDate and @ToDate AND SI.STATUS=0 
			AND SM.SCHID=(CASE @SchId WHEN 0 THEN SM.SCHID ELSE @SchId END)
			GROUP BY SM.SchId,SM.SchCode,SM.CmpSchCode,SM.SchDsc,SM.SchValidFrom,SM.SchValidTill,
			SS.SlabId,R.RtrCode,R.RtrName,RM.RmCode,RM.RmName,S.SalInvNo,S.SalInvDate,SIP.PrdId,D.PrdUnitId			
	  )X GROUP BY SchId,SchCode,CmpSchCode,SchDesc,SchPeriod,SchSlab,
	  RtrCode,RtrName,RmCode,RmName,SalInvNo,SalInvDate,LiabilityValue,LiabilityPerc,FreePrdCode,FreePrdName,FreeQty
	 
	SELECT SchId,Count(Distinct RtrCode) as SchemeRtr INTO #TempRtrCount 
	FROM #RptSchemeUtilizationDetailsReport GROUP BY SchId

	DECLARE @TotalRtrCount AS NUMERIC(18,3)
	SELECT @TotalRtrCount=Count(RtrId) FROM Retailer A(NOLOCK)

	UPDATE A SET A.LiabilityPerc=(B.SchemeRtr/@TotalRtrCount)*100,A.LiabilityValue=SchValueinLctr-((B.SchemeRtr/@TotalRtrCount)*100) FROM #RptSchemeUtilizationDetailsReport A 
	INNER JOIN #TempRtrCount B ON A.SchId=B.SchId
	  	  
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId

	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM #RptSchemeUtilizationDetailsReport

	SELECT * FROM #RptSchemeUtilizationDetailsReport ORDER BY SchCode ASC

	RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_RptMonthlyStockStatement' AND XTYPE='P')
DROP PROCEDURE Proc_RptMonthlyStockStatement
GO
CREATE PROCEDURE Proc_RptMonthlyStockStatement
(
	@Pi_RptId		    INT,
	@Pi_UsrId		    INT,
	@Pi_SnapId		    INT,
	@Pi_DbName		    NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/********************************************************************
* PROCEDURE	    : Proc_RptMonthlyStockStatement
* PURPOSE	    : To Generate the Monthly Stock Statement Details
* CREATED	    : Sathishkumar Veeramani
* CREATED DATE	: 04/07/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------
* {date}		{developer}		  {brief modification description}
*01-03-2016       Raja.C          Bug Fix Id:ICRSTPAR2215
*********************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @ErrNo	 	AS	INT 
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
			
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	CREATE TABLE #RptMonthlyStockStatement
	(   
	    [Product Code]                    NVARCHAR(200),
		[Product Name] 			          NVARCHAR(200),
		[PKT]	                          NUMERIC(18,0),
		[MRP]                             NUMERIC(18,2),
		[OpeningStockCase] 		          NUMERIC(18,0),
		[OpeningStockUnits] 		      NUMERIC(18,0),
		[PurchaseStockCase] 		      NUMERIC(18,0),
		[PurchaseStockUnits] 		      NUMERIC(18,0),
		[SalesStockCase] 		          NUMERIC(18,0),
		[SalesStockUnits] 		          NUMERIC(18,0),
		[ClosingStockCase] 		          NUMERIC(18,0),
		[ClosingStockUnits] 		      NUMERIC(18,0),
		[UsrId]	                          NUMERIC(18,0)
	)
	
/*Code Commented and Added by Raja.C for PMS No:ICRSTPAR2215 Begins Here */	
	--SELECT DISTINCT A.PrdId,PrdDCode,PrdName,PrdBatId,SUM(SalOpenStock) AS OpeningStock,(SUM(SalPurchase)-SUM(SalPurReturn)) AS PurchaseStock,
 --   (SUM(SalSales)-SUM(SalSalesReturn)) AS SalesStock,SUM(SalClsStock) AS SalClsStock
 --   INTO #SalabelStockDetails FROM StockLedger A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId 
 --   WHERE TransDate BETWEEN @FromDate AND @ToDate AND
 --         (A.PrdId = (CASE @PrdCatId WHEN 0 THEN A.PrdId Else 0 END) OR
	--		  A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND 
	--      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else 0 END) OR
	--		  A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  GROUP BY A.PrdId,PrdBatId,PrdDCode,PrdName 
 --   HAVING (SUM(SalOpenStock)+(SUM(SalPurchase)-SUM(SalPurReturn))+(SUM(SalSales)-SUM(SalSalesReturn))+SUM(SalClsStock)) <> 0 
 --   ORDER BY A.PrdId,PrdBatId
	
	SELECT PrdId,PrdBatId,MIN(TransDate) TransDate INTO #OpnStk from StockLedger (NOLOCK) WHERE  TransDate BETWEEN @FromDate AND @ToDate 
	GROUP BY PrdId,PrdBatId
	SELECT PrdId,PrdBatId,MAX(TransDate) TransDate INTO #ClsStk from StockLedger (NOLOCK) WHERE  TransDate BETWEEN @FromDate AND @ToDate 
	GROUP BY PrdId,PrdBatId	
	SELECT DISTINCT A.PrdId,PrdDCode,PrdName,PrdBatId,0 AS OpeningStock,(SUM(SalPurchase)-SUM(SalPurReturn)) AS PurchaseStock,
    (SUM(SalSales)-SUM(SalSalesReturn)) AS SalesStock,0 AS SalClsStock
    INTO #SalabelStockDetails FROM StockLedger A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId 
    WHERE TransDate BETWEEN @FromDate AND @ToDate AND
          (A.PrdId = (CASE @PrdCatId WHEN 0 THEN A.PrdId Else 0 END) OR
			  A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND 
	      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else 0 END) OR
			  A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  GROUP BY A.PrdId,PrdBatId,PrdDCode,PrdName 
    HAVING ((SUM(SalPurchase)-SUM(SalPurReturn))+(SUM(SalSales)-SUM(SalSalesReturn))) <> 0 
    ORDER BY A.PrdId,PrdBatId    
    UPDATE  A  SET  OpeningStock = SalOpenStock FROM #SalabelStockDetails A INNER JOIN StockLedger B (NOLOCK) ON A.Prdid=B.PrdId and A.Prdbatid=B.PrdBatId
    INNER JOIN #OpnStk C ON B.PrdId=C.Prdid and B.PrdBatId=C.Prdbatid and B.TransDate=C.Transdate    
    UPDATE  A  SET  SalClsStock = B.SalClsStock FROM #SalabelStockDetails A INNER JOIN StockLedger B (NOLOCK) ON A.Prdid=B.PrdId and A.Prdbatid=B.PrdBatId
    INNER JOIN #ClsStk C ON B.PrdId=C.Prdid and B.PrdBatId=C.Prdbatid and B.TransDate=C.Transdate
    /*Code Commented and Added by Raja.C for PMS No:ICRSTPAR2215 Ends Here */
    
    SELECT DISTINCT A.PrdId,A.PrdBatId,C.PrdBatDetailValue AS MRP INTO #ProductBatchDetails FROM #SalabelStockDetails A
    INNER JOIN ProductBatch B (NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
    INNER JOIN ProductBatchDetails C (NOLOCK) ON A.PrdBatId = C.PrdBatId AND B.PrdBatId = C.PrdBatId
    INNER JOIN (SELECT DISTINCT PrdBatId,MAX(PriceId) AS PriceId FROM ProductBatchDetails D (NOLOCK) GROUP BY PrdBatId) D 
    ON C.PrdBatId = D.PrdBatId AND C.PriceId = D.PriceId
    INNER JOIN BatchCreation BC (NOLOCK) ON B.BatchSeqId = BC.BatchSeqId AND C.SlNo = BC.SlNo AND MRP = 1
    ORDER BY A.PrdId,A.PrdBatId
    
    SELECT A.PrdId,B.ConversionFactor AS PKT INTO #UomGroup FROM Product A (NOLOCK) 
    INNER JOIN UomGroup B (NOLOCK) ON A.UomGroupId = B.UomGroupId
    INNER JOIN (SELECT DISTINCT UomGroupId,MAX(ConversionFactor) AS ConversionFactor FROM UomGroup A (NOLOCK) GROUP BY UomGroupId) C
    ON B.UomGroupId = C.UomGroupId AND B.ConversionFactor = C.ConversionFactor
    INNER JOIN #SalabelStockDetails D ON A.PrdID = D.PrdId ORDER BY A.PrdId
    
    SELECT DISTINCT A.PrdId,PrdDCode,PrdName,PKT,MRP,OpeningStock,PurchaseStock,SalesStock,SalClsStock INTO #RptMonthlyStock
    FROM #SalabelStockDetails A INNER JOIN #ProductBatchDetails B ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
    INNER JOIN #UomGroup C ON A.PrdId = C.PrdId ORDER BY A.PrdId
    
    
    INSERT INTO #RptMonthlyStockStatement ([Product Code],[Product Name],[PKT],[MRP],[OpeningStockCase],[OpeningStockUnits],
    [PurchaseStockCase],[PurchaseStockUnits],[SalesStockCase],[SalesStockUnits],[ClosingStockCase],[ClosingStockUnits],[UsrId])
    SELECT DISTINCT PrdDCode,PrdName,PKT,MRP,CAST(CASE WHEN SUM(OpeningStock)<PKT THEN 0 ELSE SUM(OpeningStock)/PKT END AS BIGINT) AS OpeningStockCase,
    CAST(CASE WHEN SUM(OpeningStock)<PKT THEN SUM(OpeningStock) ELSE SUM(OpeningStock)%PKT END AS BIGINT )AS OpeningStockUnits,
    CAST(CASE WHEN SUM(PurchaseStock)<PKT THEN 0 ELSE SUM(PurchaseStock)/PKT END AS BIGINT) AS PurchaseStockCase,
    CAST(CASE WHEN SUM(PurchaseStock)<PKT THEN SUM(PurchaseStock) ELSE SUM(PurchaseStock)%PKT END AS BIGINT )AS PurchaseStockUnits,
    CAST(CASE WHEN SUM(SalesStock)<PKT THEN 0 ELSE SUM(SalesStock)/PKT END AS BIGINT) AS SalesStockCase,
    CAST(CASE WHEN SUM(SalesStock)<PKT THEN SUM(SalesStock) ELSE SUM(SalesStock)%PKT END AS BIGINT )AS SalesStockUnits,
    CAST(CASE WHEN SUM(SalClsStock)<PKT THEN 0 ELSE SUM(SalClsStock)/PKT END AS BIGINT) AS ClosingStockCase,
    CAST(CASE WHEN SUM(SalClsStock)<PKT THEN SUM(SalClsStock) ELSE SUM(SalClsStock)%PKT END AS BIGINT )AS ClosingStockUnits,@Pi_UsrId            
    FROM #RptMonthlyStock GROUP BY PrdDCode,PrdName,PKT,MRP
    		
	--Check for Report Data
	DELETE FROM RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,COUNT(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptMonthlyStockStatement WHERE UsrId = @Pi_UsrId
	-- Till Here
	
	SELECT DISTINCT [Product Code],[Product Name],[PKT],[MRP],[OpeningStockCase],[OpeningStockUnits],[PurchaseStockCase],[PurchaseStockUnits],
	[SalesStockCase],[SalesStockUnits],[ClosingStockCase],[ClosingStockUnits] FROM #RptMonthlyStockStatement WHERE UsrId = @Pi_UsrId
	
RETURN
END
GO
--Till Here
UPDATE UtilityProcess SET VersionId = '3.1.0.4' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.4',427
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 427)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(427,'D','2016-03-22',GETDATE(),1,'Core Stocky Service Pack 427')