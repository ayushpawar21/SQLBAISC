--[Stocky HotFix Version]=378
Delete from Versioncontrol where Hotfixid='378'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('378','2.0.0.5','D','2011-05-17','2011-05-17','2011-05-17',convert(varchar(11),getdate()),'Parle;Major:-Changes;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 378' ,'378'
GO
IF EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'RefNO' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='RptClaimReportAll'))
BEGIN
	ALTER TABLE RptClaimReportAll ALTER COLUMN RefNO VARCHAR(200)
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptClaimReport')
DROP PROCEDURE Proc_RptClaimReport
GO 
CREATE PROCEDURE [dbo].[Proc_RptClaimReport]
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

EXEC Proc_RptClaimReportAll @Pi_RptId ,@Pi_UsrId

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
CREATE TABLE #RptClaimReportAll
(
  [RefNo] varchar(200) ,
  [Claim Code] nvarchar(20) ,
  [Claim Desc] nvarchar(50) ,
  [Claim Group] nvarchar(50) ,
  [Total Spent] numeric(38,2),
  [Claim Percentage] numeric(38,2),
  [Claim Amount] numeric(38,2),
  [Recommended Amount] numeric(38,2),
  [Received Amount] numeric(38,2),
  [Pending Amount] numeric(38,2),
  [Status] nvarchar(20)
)

SET @TblName = 'RptClaimReportAll'

SET @TblStruct = '  [RefNo] varchar(200) ,
  [Claim Code] nvarchar(20) ,
  [Claim Desc] nvarchar(50) ,
  [Claim Group] nvarchar(50) ,
  [Total Spent] numeric(38,2),
  [Claim Percentage] numeric(38,2),
  [Claim Amount] numeric(38,2),
  [Recommended Amount] numeric(38,2),
  [Received Amount] numeric(38,2),
  [Pending Amount] numeric(38,2),
  [Status] nvarchar(20)'

SET @TblFields = '  [RefNo] ,
  [Claim Code]  ,
  [Claim Desc] ,
  [Claim Group] ,
  [Total Spent],
  [Claim Percentage] ,
  [Claim Amount],
  [Recommended Amount],
  [Received Amount],
  [Pending Amount],
  [Status] '

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
	INSERT INTO #RptClaimReportAll(  [RefNo] ,
  [Claim Code]  ,   [Claim Desc] ,   [Claim Group] ,
  [Total Spent],  [Claim Percentage] ,  [Claim Amount],
  [Recommended Amount],  [Received Amount],  [Pending Amount],  [Status])
    		
	SELECT
      [RefNo],  [ClaimCode] ,  [ClaimDesc],  [ClaimGrpName] ,  [TotalSpent],
  [ClaimPercentage],  [ClaimAmount] ,  [RecommendedAmount] ,  [ReceivedAmount],
    [PendingAmount],  [Status]
    FROM RptClaimReportAll
	     WHERE
	     UsrId = @Pi_UsrId and
         (ClaimId=(CASE @ClmId WHEN 0 THEN ClaimId ELSE 0 END) OR
					ClaimId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,41,@Pi_UsrId)) )

         AND (ClaimGrpId=(CASE @ClmGrpId WHEN 0 THEN ClaimGrpId ELSE 0 END) OR
					ClaimGrpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,42,@Pi_UsrId)) )

         AND (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )
					
         AND (StatusId = (CASE @Status WHEN 0 THEN StatusId ELSE 0 END) OR
					StatusId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,83,@Pi_UsrId)) )
         
         AND [ClaimDate] Between @FromDate and @ToDate

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

         AND (ClaimGrpId=(CASE ' + @ClmGrpId + ' WHEN 0 THEN ClaimGrpId ELSE 0 END) OR
					ClaimGrpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',42,' + @Pi_UsrId + ')) )

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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClaimReportAll
-- Till Here

SELECT * FROM #RptClaimReportAll

RETURN
END
GO
DELETE FROM RptDetails where rptid=54
DELETE FROM RptFormula WHERE RPTID=54 AND SLNO IN(30,31)
DELETE FROM RptExcelHeaders where rptid=54
GO
INSERT INTO RptDetails VALUES(54,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails VALUES(54,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails VALUES(54,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company*...','',1,'',4,1,0,'Press F4/Double Click to Select Company',0)
INSERT INTO RptDetails VALUES(54,4,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,'','','Press F4/Double Click to select Salesman',0)
INSERT INTO RptDetails VALUES(54,5,'RouteMaster',-1,'','RMId,RMCode,RMName','Route...','',1,'',2,'','','Press F4/Double Click to select Route',0)
INSERT INTO RptDetails VALUES(54,6,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'',3,'','','Press F4/Double Click to select Retailer',0)
INSERT INTO RptDetails VALUES(54,7,'RetailerCategoryLevel',3,'CmpId','CtgLevelId,CtgLevelName,CtgLevelName','Category Level...','Company',1,'CmpId',29,1,'','Press F4/Double Click to select Category Level',1)
INSERT INTO RptDetails VALUES(54,8,'RetailerCategory',6,'CtgLevelID','CtgMainId,CtgCode,CtgName','Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,1,'','Press F4/Double Click to select Category Level Value',1)
INSERT INTO RptDetails VALUES(54,9,'RetailerValueClass',7,'CtgMainID','RtrClassID,ValueClassCode,ValueClassName','Value Classification...','RetailerCategory',1,'CtgMainId',31,1,'','Press F4/Double Click to select Value Classification',0)
INSERT INTO RptDetails VALUES(54,10,'ProductCategoryLevel',5,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,'','Press F4/Double Click to select Product Hierarchy Level',1)
INSERT INTO RptDetails VALUES(54,11,'ProductCategoryValue',9,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,'','','Press F4/Double Click to select Product Hierarchy Level Value',0)
GO
INSERT INTO RptFormula VALUES(54,30,'Retailer','Retailer',1,0)
INSERT INTO RptFormula VALUES(54,31,'Disp_Retailer','Retailer',1,3)
GO
INSERT INTO RptExcelHeaders VALUES(54,1,'SMId','SMId',0,1)
INSERT INTO RptExcelHeaders VALUES(54,2,'SMName','Salesman',1,1)
INSERT INTO RptExcelHeaders VALUES(54,3,'RMId','RMId',0,1)
INSERT INTO RptExcelHeaders VALUES(54,4,'RMName','Route',1,1)
INSERT INTO RptExcelHeaders VALUES(54,5,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders VALUES(54,6,'RtrName','Retailer',1,1)
INSERT INTO RptExcelHeaders VALUES(54,7,'OutletCategory','Outlet Category',1,1)
INSERT INTO RptExcelHeaders VALUES(54,8,'OutletClass','Outlet Class',1,1)
INSERT INTO RptExcelHeaders VALUES(54,9,'TotalBillCuts','No of Bill Cuts',1,1)
INSERT INTO RptExcelHeaders VALUES(54,10,'TLSD','TLSD',1,1)
INSERT INTO RptExcelHeaders VALUES(54,11,'Value','Gross Value',1,1)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE NAME ='View_TLSDReport' AND xtype='V')
DROP VIEW View_TLSDReport
GO
CREATE VIEW View_TLSDReport
/************************************************************
* VIEW	: View_TLSDReport
* PURPOSE	: To get the TLSD details
* CREATED BY	: MahaLakshmi
* CREATED DATE	: 13/12/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT A.SMNAME,B.SMID,B.RMID,B.SALID,R.RTRID,B.SALINVNO,B.SALINVDATE,P.CMPID,
		G.PRDGROSSAMOUNT,
		C.RMNAME,R.RTRNAME,F.CTGNAME,F.CtgLevelID ,E.VALUECLASSNAME,G.PRDID,E.CtgMainID,E.RtrClassID FROM SALESMAN A
	INNER JOIN SALESINVOICE B ON A.SMID=B.SMID
	INNER JOIN ROUTEMASTER C ON C.RMID=B.RMID
	INNER JOIN RETAILERVALUECLASSMAP D ON D.RTRID=B.RTRID
	INNER JOIN RETAILERVALUECLASS E ON D.RTRVALUECLASSID=E.RTRCLASSID
	INNER JOIN RETAILERCATEGORY F ON F.CTGMAINID=E.CTGMAINID
	INNER JOIN SALESINVOICEPRODUCT G ON G.SALID=B.SALID
	INNER JOIN PRODUCT P ON G.PRDID=P.PRDID
    INNER JOIN RETAILER R ON R.RTRID=B.RTRID
	WHERE B.DlvSts IN(4,5)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE name='Proc_RptTLSDReport' AND xtype='p')
DROP PROCEDURE Proc_RptTLSDReport
GO
CREATE PROC Proc_RptTLSDReport
--EXEC Proc_RptTLSDReport 54,2,0,'Claimmgt',0,0,1
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
* VIEW	: Proc_RptTLSDReport
* PURPOSE	: To get the Total Line Sold During the period
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 12/12/2007
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
	DECLARE @SMId 		AS	INT
	DECLARE @RMId 		AS	INT
    DECLARE @RtrId 		AS	INT        
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @CtgLevelId	AS 	INT
	DECLARE @RtrClassId	AS 	INT
	DECLARE @CtgMainId 	AS 	INT
----Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
    SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	---Till Here
	Create TABLE #RptTLSDReport
	(
				SmId			BIGINT,
				SmName			NVARCHAR(50),
				RmId			BIGINT,
				RmName			NVARCHAR(50),
                RtrId			BIGINT,
				RtrName			NVARCHAR(50),
	      		OutletCategory	NVARCHAR(50),
	       		OutletClass		NVARCHAR(50),
				TotalBillCuts	INT,
				TLSD			INT,
				Value			NUMERIC(38,2)
	)
	SET @TblName = 'RptTLSDReport'
	SET @TblStruct = '	SmId	BIGINT,
						SmName	NVARCHAR(50),
						RmId	BIGINT,
						RmName	NVARCHAR(50),
                        RtrId			BIGINT,
				        RtrName			NVARCHAR(50),
						OutletCategory	NVARCHAR(50),
						OutletClass		NVARCHAR(50),
						TotalBillCuts	INT,
						TLSD			INT,
						Value			NUMERIC(38,2)'
	SET @TblFields = 'SmID,SmName,RmId,RmName,OutletCategory,OutletClass,TotalBillCuts,TLSD,Value'
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
		
		INSERT INTO #RptTLSDReport (SmID,SmName,RmId,RmName,RtrId,RtrName,OutletCategory,OutletClass,TotalBillCuts,TLSD,Value)
				SELECT DISTINCT SmID,SmName,RmId,RmName,RtrId,RtrName,ctgName,valueclassname,Count(DISTINCT SalId) AS BillCuts,Count(PrdId) AS TLSD,Sum(PrdGrossAmount)
					FROM View_TLSDreport
                    retailer      
				WHERE 	(CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
						CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND
					(SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
						SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
					AND
					(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
						RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
					AND
					(CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR
						CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
					AND
					(RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR
						RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
					AND
					(CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR
						CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
                    AND
				    (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					     RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						
						AND SalInvDate BETWEEN @FromDate AND @ToDate		
					GROUP BY SmID,SmName,RmId,RmName,RtrId,RtrName,ctgName,valueclassname
				
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptTLSDReport ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE BillStatus=1  AND (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '
				+ 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptTLSDReport'
		
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
			SET @SSQL = 'INSERT INTO #RptTLSDReport ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptTLSDReport
	-- Till Here
	SELECT * FROM #RptTLSDReport
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptTLSD_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptTLSD_Excel
		SELECT * INTO RptTLSD_Excel FROM #RptTLSDReport 
	END 
RETURN
END
GO
UPDATE rptdetails SET singlemulti=0 WHERE rptid=18 AND slno=10
GO
DELETE FROM RptExcelHeaders WHERE RptId=29 
GO
INSERT INTO RptExcelHeaders VALUES (29,1,'InvId','InvId',	0,1)
INSERT INTO RptExcelHeaders VALUES (29,2,'RefNo','Transaction No',1,1)
INSERT INTO RptExcelHeaders VALUES (29,3,'BillBookBo','Buill Book Bo',1,1)
INSERT INTO RptExcelHeaders VALUES (29,4,'InvDate','Transaction Date',1,1)
INSERT INTO RptExcelHeaders VALUES (29,5,'BaseTransNo','Base Transaction Ref No',1,1)
INSERT INTO RptExcelHeaders VALUES (29,6,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders VALUES (29,7,'RtrName','Retailer',1,1)
INSERT INTO RptExcelHeaders VALUES (29,8,'RtrTINNo','TIN No',1,1)
INSERT INTO RptExcelHeaders VALUES (29,9,'UsrId','UsrId',0,1)
GO
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptOUTPUTVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [RptOUTPUTVATSummary_Excel]
GO
DELETE FROM RptDetails WHERE RptId=29 AND Slno=7
INSERT INTO RptDetails
SELECT 29,7,'RptFilter',-1,'','FilterId,FilterId,FilterDesc','Display Net Amount*...','',1,'',
264,1,1,'Press F4/Double Click to Select Display Net Amount',0
GO
DELETE FROM RptDetails WHERE RptId=29 AND Slno=8
INSERT INTO RptDetails
SELECT 29,8,'RptFilter',-1,'','FilterId,FilterId,FilterDesc','Display Base Transaction No*...','',1,'',
273,1,1,'Press F4/Double Click to Select Display Base Transaction No',0
GO

DELETE FROM RptFilter WHERE RptId=29 AND SelcId=264
INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
SELECT 29,264,1,'Yes'
UNION
SELECT 29,264,2,'No'
GO 

DELETE FROM RptFilter WHERE RptId=29 AND SelcId=273
INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
SELECT 29,273,1,'Yes'
UNION
SELECT 29,273,2,'No'
GO 

DELETE FROM RptSelectionHd WHERE SelcId=264
INSERT INTO RptSelectionHd(SelcId,SelcName,TblName,Condition)
SELECT 264,'Sel_DispNetAmt','RptFilter',1
GO

DELETE FROM RptSelectionHd WHERE SelcId=273
INSERT INTO RptSelectionHd(SelcId,SelcName,TblName,Condition)
SELECT 273,'Sel_DispBaseTransNo','RptFilter',1
GO

DELETE FROM RptFormula WHERE RptId=29 AND Slno=24 AND Formula='Disp_NetAmt'
INSERT INTO RptFormula
SELECT 29,24,'Disp_NetAmt','',1,264
GO

DELETE FROM RptFormula WHERE RptId=29 AND Slno=25 AND Formula='Disp_BillBookNo'
INSERT INTO RptFormula
SELECT 29,25,'Disp_BillBookNo','',1,0
GO

DELETE FROM RptFormula WHERE RptId=29 AND Slno=26 AND Formula='Disp_BaseTransNo'
INSERT INTO RptFormula
SELECT 29,26,'Disp_BaseTransNo','',1,0
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptOUTPUTVATSummary')
DROP PROCEDURE Proc_RptOUTPUTVATSummary
GO
--EXEC Proc_RptOUTPUTVATSummary 29,2,0,'CoreStockyTempReport',0,0,1,0
CREATE    PROCEDURE [dbo].[Proc_RptOUTPUTVATSummary]
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
DECLARE @SMId	 	AS	INT
DECLARE @RMId	 	AS	INT
DECLARE @RtrId	 	AS	INT
DECLARE @TransNo	AS	NVARCHAR(100)
DECLARE @EXLFlag	AS 	INT
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
		InvId 			BIGINT,
		RefNo	  		NVARCHAR(100),	
		BillBookNo	  	NVARCHAR(100),	
		InvDate 		DATETIME,
		BaseTransNo		NVARCHAR(100),	
		RtrId 			INT,
		RtrName			NVARCHAR(100),
		RtrTINNo 		NVARCHAR(100),
		IOTaxType 		NVARCHAR(100),
		TaxPerc 		NVARCHAR(100),
		TaxableAmount 		NUMERIC(38,6),		
		TaxFlag 		INT,
		TaxPercent 		NUMERIC(38,6)
	)
SET @TblName = 'RptOUTPUTVATSummary'
SET @TblStruct = 'InvId 		BIGINT,
		RefNo	  		NVARCHAR(100),		
		BillBookNo	  	NVARCHAR(100),
		InvDate 		DATETIME,	
		BaseTransNo		NVARCHAR(100),	
		RtrId 			INT,
		RtrName			NVARCHAR(100),
		RtrTINNo 		NVARCHAR(100),
		IOTaxType 		NVARCHAR(100),
		TaxPerc 		NVARCHAR(100),
		TaxableAmount 		NUMERIC(38,6),		
		TaxFlag 		INT,
		TaxPercent 		NUMERIC(38,6)'
			
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
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN
	EXEC Proc_IOTaxSummary  @Pi_UsrId
	INSERT INTO #RptOUTPUTVATSummary (InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent)
		Select InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,sum(TaxableAmount),
--		case IOTaxType when 'Sales' then TaxableAmount when 'SalesReturn' then -1 * TaxableAmount end as TaxableAmount ,
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
ELSE				--To Retrieve Data From Snap Data
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
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptOUTPUTVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptOUTPUTVATSummary_Excel]
		DELETE FROM RptExcelHeaders Where RptId=29 AND SlNo>9
		CREATE TABLE RptOUTPUTVATSummary_Excel (InvId BIGINT,RefNo NVARCHAR(100),BillBookNo	NVARCHAR(100),InvDate DATETIME,BaseTransNo NVARCHAR(100),RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)
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
		INSERT INTO RptOUTPUTVATSummary_Excel(InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId)
		SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId
				FROM #RptOUTPUTVATSummary
		--Select * from RptOUTPUTVATSummary_Excel
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT InvId,RefNo,RtrId,TaxPerc,TaxableAmount FROM #RptOUTPUTVATSummary
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptOUTPUTVATSummary_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnFiltersValue]') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION  [dbo].[Fn_ReturnFiltersValue]
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
	IF @Pi_ScreenId = 217 OR @Pi_ScreenId = 241 OR @Pi_ScreenId = 260 OR @Pi_ScreenId =  261 OR @Pi_ScreenId =  262
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

	IF @Pi_ScreenId = 272 OR @Pi_ScreenId=273
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	RETURN(@RetValue)

END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
if not exists (select * from hotfixlog where fixid = 378)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(378,'D','2011-05-17',getdate(),1,'Core Stocky Service Pack 378')