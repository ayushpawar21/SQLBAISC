--[Stocky HotFix Version]=364
Delete from Versioncontrol where Hotfixid='364'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('364','2.0.0.5','D','2011-03-18','2011-03-18','2011-03-18',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel and Henkel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 364' ,'364'
GO

--SRF-Nanda-212-001-From Boo

DELETE FROM RptExcelHeaders Where RptId = 220
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,1,'RtrId','RtrId',0,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,2,'RtrCode','Retailer Code',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,3,'RtrName','Retailer Name',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,4,'CmpPrdCtgId','CmpPrdCtgId',0,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,5,'CmpPrdCtgName','Product Category Level',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,6,'PrdCtgValMainId','PrdCtgValMainId',0,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,7,'PrdCtgValCode','PrdCtgValCode',0,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,8,'PrdCtgValName','Product Category Value',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,9,'PrdId','PrdId',0,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,10,'PrdCCode','Product Code',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,11,'PrdName','Product Name',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,12,'BaseQty','Sales Qty',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,13,'PrdUnitId','PrdUnitId',0,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,14,'PrdOnUnit','Product On Unit',0,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,15,'PrdOnKg','Prd in Kg',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,16,'PrdOnLitre','Prd In Litre',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,17,'PrdNetAmount','Sales Value',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,18,'DispMode','DispMode',0,1)
GO
DELETE FROM RptExcelHeaders WHERE RptId=223
INSERT INTO RptExcelHeaders
SELECT 223,1,'ReturnId','ReturnId',0,1 UNION
SELECT 223,2,'ReturnCode','Srn No',1,1 UNION
SELECT 223,3,'ReturnDate','Srn Date',1,1 UNION
SELECT 223,4,'RtrId','RtrId',0,1 UNION
SELECT 223,5,'RtrCode','Retailer Code',1,1 UNION
SELECT 223,6,'RtrName','Retailer Name',1,1 UNION
SELECT 223,7,'SalId','SalId',0,1 UNION
SELECT 223,8,'SalInvNo','Bill No',1,1 UNION
SELECT 223,9,'SalInvDate','Bill Date',1,1 UNION
SELECT 223,10,'CmpPrdCtgId','CmpPrdCtgId',0,1 UNION
SELECT 223,11,'CmpPrdCtgName','CmpPrdCtgName',0,1 UNION
SELECT 223,12,'PrdCtgValMainId','PrdCtgValMainId',0,1 UNION
SELECT 223,13,'PrdCtgValCode','PrdCtgValCode',0,1 UNION
SELECT 223,14,'PrdCtgValName','PrdCtgValName',0,1 UNION
SELECT 223,15,'PrdId','PrdId',0,1 UNION
SELECT 223,16,'PrdCCode','Product Code',1,1 UNION
SELECT 223,17,'PrdName','Product Name',1,1 UNION
SELECT 223,18,'PrdUnitId','PrdUnitId',0,1 UNION
SELECT 223,19,'BaseQty','Base Qty',1,1 UNION
SELECT 223,20,'PrdOnTones','Qty In Tones',1,1 UNION
SELECT 223,21,'PrdGrossAmt','Gross value',1,1
GO
DELETE FROM Configuration  WHERE ModuleId = 'STKMGNT12'
INSERT INTO Configuration  
SELECT 'STKMGNT12','Stock Management','Enable selection of transaction type at grid level',1,'',0,12
GO

--SRF-Nanda-212-002-From Boo

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptSalesReturnDt')
DROP PROCEDURE Proc_RptSalesReturnDt
GO 

--select * from ReportfilterDt where rptid = 90 And selid = 66
--EXEC Proc_RptSalesReturnDt 223,2,0,'ASKO',0,0,1
-- SELECT * FROM Temp_SalesReturnSubReport

CREATE     PROCEDURE [dbo].[Proc_RptSalesReturnDt]
/************************************************************
* PROCEDURE	: Proc_RptSalesReturnDt
* PURPOSE	: Sales Return Summary Report
* CREATED BY	: Boopathy.P
* CREATED DATE	: 17/03/2011
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
	DECLARE @SubTotal		AS 	INT
	DECLARE @SalesRtn  		AS	INT
	DECLARE @ETLFlag 		AS 	INT
	DECLARE @InvType		AS 	INT
	DECLARE @EXLFlag		AS  INT


	CREATE  TABLE #RptTempSalesReturn
		(
			ReturnId			BIGINT,
			ReturnCode			NVARCHAR(200),
			ReturnDate			DATETIME,
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			SalId				BIGINT,
			SalInvNo			NVARCHAR(200),
			SalInvDate			DATETIME,			
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			PrdUnitId			INT,
			BaseQty				NUMERIC(18,0),
			PrdOnTones			NUMERIC(18,6),
			PrdGrossAmt			NUMERIC(18,6)
		)

	CREATE  TABLE #RptSalesReturnDt
		(
			ReturnId			BIGINT,
			ReturnCode			NVARCHAR(200),
			ReturnDate			DATETIME,
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			SalId				BIGINT,
			SalInvNo			NVARCHAR(200),
			SalInvDate			DATETIME,			
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			PrdUnitId			INT,
			BaseQty				NUMERIC(18,0),
			PrdOnTones			NUMERIC(18,6),
			PrdGrossAmt			NUMERIC(18,6)
		)


	
	SET @RtrId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CmpId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdCatLvlId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SubTotal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,251,@Pi_UsrId))
	SET @InvType  = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,261,@Pi_UsrId))
	SET @SalesRtn = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,32,@Pi_UsrId))

	IF @CmpId=0
	BEGIN
		SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
	END
	

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	
	SET @TblName = 'RptSalesReturnDt'
	
	SET @TblStruct ='		
			ReturnId			BIGINT
			ReturnCode			NVARCHAR(200),
			ReturnDate			DATETIME
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			SalId				BIGINT,
			SalInvNo			NVARCHAR(200),
			SalInvDate			DATETIME,			
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			PrdUnitId			INT,
			BaseQty				NUMERIC(18,0),
			PrdOnTones			NUMERIC(18,6),
			PrdGrossAmt			NUMERIC(18,6)'					
	
	SET @TblFields = 'ReturnId,ReturnCode,ReturnDate,RtrId,RtrCode,RtrName,SalId,SalInvNo,SalInvDate,			
					  CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,PrdId,
					  PrdCCode,PrdName,PrdUnitId,BaseQty,PrdOnTones,PrdGrossAmt'
	
	INSERT INTO #RptTempSalesReturn
		SELECT DISTINCT F.ReturnId,F.ReturnCode,F.ReturnDate,F.RtrId,F.RtrCode,F.RtrName,SalId,[Bill No],[Bill Date],
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.BaseQty,F.PrdOnTones,F.PrdGrossAmt 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,
					(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN B.CmpPrdCtgId  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT C.PrdId FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE @RtrId END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT A.ReturnId,A.ReturnCode,A.ReturnDate,B.RtrId,B.RtrCode,B.RtrName,ISNULL(C.SalId,0) as SalId,
							Case ISNULL(C.SalId,0) When ISNULL(C.SalId,0) then ISNULL(Si.SalInvNo,C.SalCode) Else ISNULL(C.SalCode,'-') End as [Bill No],
							Case ISNULL(C.SalId,0) When ISNULL(C.SalId,0) then ISNULL(Si.SalInvDate,A.ReturnDate) Else ISNULL(A.ReturnDate,'-') End as [Bill Date],
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS BaseQty,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0)/1000 AS PrdOnTones,SUM(C.PrdGrossAmt) AS PrdGrossAmt
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							LEFT OUTER JOIN SalesInvoice SI On C.SalId = SI.SalId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							A.ReturnType=@InvType AND 
							(A.ReturnId = (CASE @SalesRtn WHEN 0 THEN A.ReturnId ELSE @SalesRtn END) OR
							A.ReturnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,32,@Pi_UsrId))) AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE @RtrId END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY A.ReturnId,A.ReturnCode,A.ReturnDate,C.SalId,B.RtrId,B.RtrCode,B.RtrName,
							D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId,Si.SalInvNo,C.SalCode,Si.SalInvDate) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId in (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN G.CmpPrdCtgId
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
				C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ORDER BY ReturnCode

	IF @PrdCatLvlId=0 AND @PrdCatValId=0 AND @PrdId=0
	BEGIN
		INSERT INTO #RptSalesReturnDt
		SELECT * FROM #RptTempSalesReturn WHERE CmpPrdCtgId= (SELECT MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId)
	END
	ELSE IF @PrdCatLvlId<>0 AND @PrdCatValId=0 AND @PrdId=0
	BEGIN
		INSERT INTO #RptSalesReturnDt
		SELECT * FROM #RptTempSalesReturn WHERE CmpPrdCtgId= @PrdCatLvlId
	END
	ELSE IF @PrdCatLvlId<>0 AND @PrdCatValId<>0 AND @PrdId=0
	BEGIN
		INSERT INTO #RptSalesReturnDt
		SELECT * FROM #RptTempSalesReturn WHERE CmpPrdCtgId= @PrdCatLvlId AND 
		PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	END
	ELSE IF @PrdCatLvlId<>0 AND @PrdCatValId<>0 AND @PrdId<>0
	BEGIN
		INSERT INTO #RptSalesReturnDt
		SELECT * FROM #RptTempSalesReturn WHERE CmpPrdCtgId= @PrdCatLvlId AND 
		PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
		AND PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	END
	ELSE IF @PrdCatLvlId=0 AND @PrdCatValId=0 AND @PrdId<>0
	BEGIN
		INSERT INTO #RptSalesReturnDt
		SELECT * FROM #RptTempSalesReturn WHERE 
		CmpPrdCtgId= (SELECT MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId) AND 
		PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	END
	ELSE IF @PrdCatLvlId<>0 AND @PrdCatValId=0 AND @PrdId<>0
	BEGIN
		INSERT INTO #RptSalesReturnDt
		SELECT * FROM #RptTempSalesReturn WHERE 
		CmpPrdCtgId= @PrdCatLvlId AND 
		PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	END

	DELETE FROM Temp_SalesReturnSubReport
	IF @SubTotal>0
	BEGIN
		
		IF @SubTotal<>@PrdCatLvlId
		BEGIN
			INSERT INTO Temp_SalesReturnSubReport
			SELECT B.PrdCtgValMainId,B.PrdCtgValCode,B.PrdCtgValName,
			SUM(BaseQty),SUM(PrdOnTones),SUM(PrdGrossAmt) FROM #RptTempSalesReturn A 
			INNER JOIN ProductCategoryValue B ON A.CmpPrdCtgId=B.CmpPrdCtgId
			WHERE B.CmpPrdCtgId=@SubTotal GROUP BY B.PrdCtgValMainId,B.PrdCtgValCode,B.PrdCtgValName

			DELETE FROM Temp_SalesReturnSubReport WHERE LvlId NOT IN (SELECT DISTINCT A.PrdCtgValMainId 
			FROM ProductCategoryValue A INNER JOIN 
			(SELECT RTRIM(LEFT(B.PrdCtgValLinkCode,@SubTotal*5)) AS PrdCtgLinkCode,
			SUM(BaseQty) AS BaseQty,SUM(PrdOnTones) AS PrdOnTones,SUM(PrdGrossAmt) AS PrdGrossAmt 
			FROM #RptTempSalesReturn A 
			INNER JOIN ProductCategoryValue B ON A.PrdCtgValMainId=B.PrdCtgValMainId
			WHERE A.CmpPrdCtgId=@SubTotal GROUP BY B.PrdCtgValLinkCode) B 
			ON B.PrdCtgLinkCode=A.PrdCtgValLinkCode)
			
			UPDATE A SET  A.BaseQty=B.BaseQty,A.Tone=B.PrdOnTones,A.Amount=PrdGrossAmt 
			FROM Temp_SalesReturnSubReport A INNER JOIN 
			(SELECT A.PrdCtgValMainId,SUM(B.BaseQty) AS BaseQty,SUM(B.PrdOnTones) AS PrdOnTones,SUM(B.PrdGrossAmt ) AS PrdGrossAmt
			FROM ProductCategoryValue A INNER JOIN 
			(SELECT RTRIM(LEFT(B.PrdCtgValLinkCode,@SubTotal*5)) AS PrdCtgLinkCode,
			SUM(BaseQty) AS BaseQty,SUM(PrdOnTones) AS PrdOnTones,SUM(PrdGrossAmt) AS PrdGrossAmt 
			FROM #RptTempSalesReturn A 
			INNER JOIN ProductCategoryValue B ON A.PrdCtgValMainId=B.PrdCtgValMainId
			WHERE A.CmpPrdCtgId=@SubTotal GROUP BY B.PrdCtgValLinkCode) B 
			ON B.PrdCtgLinkCode=A.PrdCtgValLinkCode GROUP BY PrdCtgValMainId) B ON A.LvlId=B.PrdCtgValMainId
		END
		ELSE
		BEGIN
			INSERT INTO Temp_SalesReturnSubReport
			SELECT PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			SUM(BaseQty),SUM(PrdOnTones),SUM(PrdGrossAmt) FROM #RptSalesReturnDt
			WHERE CmpPrdCtgId=@SubTotal	GROUP BY PrdCtgValMainId,PrdCtgValCode,PrdCtgValName
		END
	END

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptSalesReturnDt
	select * from #RptSalesReturnDt 



RETURN
END
GO

--SRF-Nanda-212-003-From Boo

DELETE FROM RptGroup WHERE  Rptid=223
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'DailyReports',223,'SalesReturnSummary','Sales Return Summary'
GO
DELETE FROM RptHeader WHERE Rptid=223
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'SalesReturnSummary','Sales Return Summary',223,'Sales Return Summary','Proc_RptSalesReturnDt','RptSalesReturnDt','RptSalesReturnDt.rpt',NULL
GO
DELETE FROM RptDetails WHERE RptId=223
INSERT INTO RptDetails
SELECT 223,1,'FromDate',-1,'','','From Date*','',1,'',10,'','','Enter From Date',0
UNION
SELECT 223,2,'ToDate',-1,'','','To Date*','',1,'',11,'','','Enter To Date',0
UNION
SELECT 223,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,'','Press F4/Double Click to select Company',0
--UNION
--SELECT 223,4,'SalesMan',-1,'','SMId,SMCode,SMName','SalesMan...','',1,'',1,1,'','Press F4/Double Click to select Salesman',0
--UNION
--SELECT 223,5,'RouteMaster',-1,'','RMId,RMCode,RMName','Route...','',1,'',2,1,'','Press F4/Double Click to select Route',0
--UNION 
--SELECT 223,6,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer Group...','',1,'',215,'','','Press F4/Double Click to select Retailer Group',0
UNION 
SELECT 223,4,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'',3,'','','Press F4/Double Click to select Retailer',0
UNION
SELECT 223,5,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,'','Press F4/Double Click to select Product Hierarchy Level',0
UNION
SELECT 223,6,'ProductCategoryValue',5,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,'','','Press F4/Double Click to select Product Hierarchy Level Value',0
UNION
SELECT 223,7,'Product',6,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,'','','Press F4/Double Click to select Product',0
UNION 
SELECT 223,8,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Return Type*...','',1,'',261,1,1,'Press F4/Double Click to select Return Type',0
UNION
SELECT 223,9,'ReturnHeader',-1,'','ReturnId,ReturnType,ReturnCode','SRN No...','',1,'',32,'','','Press F4/Double Click to Select SRN No',0
UNION
SELECT 223,10,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Sub Total In*...','Company',1,'CmpId',251,1,1,'Press F4/Double Click to select Sub Total Group',0

GO
DELETE FROM RptSelectionHd WHERE SelcId=261
INSERT INTO RptSelectionHd VALUES(261,'Sel_InvoiceType','RptFilter',1)
--GO
--DELETE FROM RptSelectionHd WHERE SelcId=263
--INSERT INTO RptSelectionHd VALUES(263,'Sel_SubTotal','ProductCategoryLevel',1)
GO
DELETE FROM RptFilter WHERE RptId=223 AND SelcId=261
INSERT INTO RptFilter VALUES(223,261,1,'Market Return')
INSERT INTO RptFilter VALUES(223,261,2,'Sales Return')
GO
DELETE FROM RptFormula WHERE RptId=223
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,1,'Rpt_SRNNo','Return Code',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,2,'Rpt_SRDate','Return Date',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,3,'Rpt_RtrCode','Retailer Code',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,4,'Rpt_RtrName','Retailer Name',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,5,'Rpt_BillNo','Bill No',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,6,'Rpt_BillDate','Bill Date',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,7,'Rpt_PrdCode','Product Code',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,8,'Rpt_PrdName','Product Name',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,9,'Rpt_BaseQty','Base Qty',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,10,'Rpt_PrdTones','Qty in Tones',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,11,'Rpt_Value','Gross Amount',1,0

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,12,'Disp_FromDate','',1,10
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,13,'Disp_ToDate','',1,11
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,14,'Disp_Company','',1,4
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,15,'Disp_Retailer','',1,3
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,16,'DispHd_InvType','',1,261
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,17,'Disp_ProductCategoryLevel','',1,16
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,18,'Disp_ProductCategoryValue','',1,21
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,19,'Disp_Product','',1,5
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,20,'ValSRNo','',1,32
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 223,21,'Disp_SubTotal','',1,251

--SRF-Nanda-212-004-From Panneer

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_CurrentStock]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_CurrentStock]
GO

CREATE TABLE [Cs2Cn_Prk_CurrentStock]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[LcnId] [int] NULL,
	[LcnName] [nvarchar](100) NULL,
	[PrdId] [int] NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatchCode] [nvarchar](100) NULL,
	[PrdBatLcnSih] [int] NULL,
	[PrdBatLcnUih] [int] NULL,
	[PrdBatLcnFre] [int] NULL,
	[PrdBatLcnRessih] [int] NULL,
	[PrdBatLcnResUih] [int] NULL,
	[PrdBatLcnResFre] [int] NULL,
	[UploadedDate] [datetime] NULL,
	[UploadFlag] [nvarchar](1) NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_CurrentStock]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_CurrentStock]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE   PROCEDURE [Proc_Cs2Cn_CurrentStock]     
(
	@Po_ErrNo INT OUTPUT
)
AS
SET NOCOUNT ON
/********************************************************************************************
* PROCEDURE		: Proc_Cs2Cn_CurrentStock
* PURPOSE		: Extract Current Stock Details from CoreStocky to Console
* NOTES			:
* CREATED		: PanneerSelvam.K 
* CREATED DATE	: 04/08/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
**************************************************************************************
*
**************************************************************************************/
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME

	SET @Po_ErrNo=0

	DELETE FROM Cs2Cn_Prk_CurrentStock WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor	
		
	INSERT INTO Cs2Cn_Prk_CurrentStock(DistCode,LcnId,LcnName,PrdId,PrdCode,PrdName,PrdBatId,PrdBatchCode,
	PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,PrdBatLcnRessih,PrdBatLcnResUih,PrdBatLcnResFre,UploadedDate,UploadFlag)
	SELECT @DistCode,PBL.LcnId,LcnName,PBL.PrdId,PrdCCode,PrdName,
	PBL.PrdBatId,CmpBatCode,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnFre,
	PrdBatLcnRessih,PrdBatLcnResUih,PrdBatLcnResFre,GETDATE(),'N'
	FROM Product P,ProductBatch PB,ProductBatchLocation PBL,Location L
	WHERE P.PrdId = PB.PrdId and P.PrdId = PBL.PrdId
	AND PB.PrdId = PBL.PrdId AND PB.PrdBatId = PBL.PrdBatId
	AND PBL.LcnId = L.LcnId
	AND (PrdBatLcnSih+PrdBatLcnUih+PrdBatLcnFre+PrdBatLcnRessih+PrdBatLcnResUih+PrdBatLcnResFre) > 0
	ORDER BY PBL.LcnId,PBL.PrdId,PBL.PrdBatId	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-212-005

UPDATE CustomCaptions SET Caption=REPLACE(Caption,'Alllow','Allow')

--SRF-Nanda-212-006-From Panneer

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_StockManagement')
DROP PROCEDURE  Proc_AN_StockManagement
GO
-- EXEC Proc_AN_StockManagement '2011-03-01','2011-03-20'
CREATE PROCEDURE Proc_AN_StockManagement
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
/****************************************************************************
* PROCEDURE: Proc_AN_StockJournal
* PURPOSE: Extract Data in SM Details -- Akso Nobel 
* NOTES:
* CREATED: Panneer	16.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
*****************************************************************************/
SET NOCOUNT ON
BEGIN
	DELETE FROM StockManagementExtractExcel
	INSERT INTO StockManagementExtractExcel ( DistCode,DistName,TransName,StkRefNumber,StkRefDate,
											  LocCode,LocName,StkMngtType,TransType,ProductCode,ProductName,
											  BatchCode,StockType,Qty,Rate,Amount,Reason,PrdId,PrdBatId )
	
	SELECT DISTINCT 
				'','','Stock Management',A.StkMngRefNo,StkMngDate,LcnCode,LcnName,
				Case OpenBal When 1 Then 'Opening Stock' Else 'Stock Management' End As StkMngtType,
				F.[Description],PrdCCode,PrdName,PrdBatCode,
				Case STockTypeId When 1 Then 'Saleable'
								 When 2 Then 'UnSaleable'
								 When 3 Then 'Offer' END AS StkMngtType,
				TotalQty,Rate,Amount,'' AS Reason,B.PrdId,B.PrdBatId
	From 
			StockManagement   A,StockManagementProduct B ,Location C,
			Product D,ProductBatch E,StockManagementType F
	Where
			A.StkMngRefNo = B.StkMngRefNo  AND A.LcnId = C.LcnId
			AND B.PrdId = D.PrdId  AND B.PrdId = E.PrdId  AND B.PrdBatId = E.PrdBatId
			AND B.StkMgmtTypeId = F.StkMgmtTypeId	AND A.Status = 1
			AND StkMngDate Between @Pi_FromDate  and @Pi_ToDate
	Order By 
			A.StkMngRefNo

	
	Select Distinct 
		A.StkMngRefNo,A.PrdId,A.PrdBatId,A.ReasonId,[Description] INTO  #UpdateStkMngt
	From 
		StockManagementProduct A,Product B,ProductBatch C,ReasonMaster D,
		StockManagement E
	WHere 
		A.PrdId = B.PrdId  And A.PrdId = C.PrdId AND  A.PrdBatId = C.PrdBatId 
		AND A.ReasonId = D.ReasonId and A.ReasonId <> 0 
		AND A.StkMngRefNo = E.StkMngRefNo
		AND StkMngDate Between @Pi_FromDate  and @Pi_ToDate
	
	UPDATE StockManagementExtractExcel SET Reason = [Description]
	From StockManagementExtractExcel A,#UpdateStkMngt B 
	Where A.StkRefNumber = B.StkMngRefNo  AND A.PrdId = B.PrdId  
		  and A.PrdBatId = B.PrdBatId 


	UPDATE StockManagementExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE StockManagementExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)

	Select * from StockManagementExtractExcel
END 
GO 
 

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptAkzoStockLedgerReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptAkzoStockLedgerReport]
GO
----  Exec [Proc_RptAkzoStockLedgerReport] 225,2,0,'Loreal',0,0,1
---- select *  from RptProductTrack
---- select * from users
CREATE  PROCEDURE [Proc_RptAkzoStockLedgerReport]
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
/***************************************************************************************************
* PROCEDURE : Proc_RptAkzoStockLedgerReport
* PURPOSE   : Product transaction details
* CREATED	: Panneer
* CREATED DATE : 16.03.2011
* NOTE		: General SP For Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------------------------------------
* {date}     {developer}  {brief modification description}
***************************************************************************************************/
BEGIN
SET NOCOUNT ON

	DECLARE @NewSnapId   AS INT
	DECLARE @DBNAME		 AS nvarchar(50)
	DECLARE @TblName	 AS nvarchar(500)
	DECLARE @TblStruct   AS nVarchar(4000)
	DECLARE @TblFields   AS nVarchar(4000)
	DECLARE @sSql		 AS nVarChar(4000)
	DECLARE @ErrNo		 AS INT
	DECLARE @PurDBName	 AS nVarChar(50)

	--Filter Variable
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @CmpId				AS Int
	DECLARE @CmpPrdCtgId		AS Int
	DECLARE @PrdCtgMainId		AS Int
	DECLARE @PrdId				AS INT
	DECLARE @PrdCatPrdId        AS  INT
	DECLARE @LcnId				AS INT
	DECLARE @SupZeroStock		AS INT
	DECLARE @ZeroStockRecCount  AS INT
	--Till Here

	--Assgin Value for the Filter Variable
	SET @FromDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate   = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @CmpId    = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId    = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))	
	SET @PrdId    = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SupZeroStock = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,262,@Pi_UsrId))

	EXEC Proc_AkzoProductTrackDetails @Pi_UsrId,@FromDate,@ToDate 

	CREATE TABLE #RptAkzoStockLedgerReport
	(
						TransactionDate		DATETIME,
						TransactionType		NVARCHAR(300),
						TransactionNumber   NVARCHAR(100),
						SalQty				NUMERIC(38,0),
						SalQtyVolume		NUMERIC(38,6),
						UnSalQty			NUMERIC(38,0),
						UnSalQtyVolume		NUMERIC(38,6),
						OfferQty   NUMERIC(38,0),
						OfferQtyVolume   NUMERIC(38,6),
						SlNo    INT,
						PrdId   INT
	)
	SET @TblName = 'RptAkzoStockLedgerReport'
	SET @TblStruct = '	TransactionDate		DATETIME,
						TransactionType		NVARCHAR(300),
						TransactionNumber   NVARCHAR(100),
						SalQty				NUMERIC(38,0),
						SalQtyVolume		NUMERIC(38,6),
						UnSalQty			NUMERIC(38,0),
						UnSalQtyVolume		NUMERIC(38,6),
						OfferQty   NUMERIC(38,0),
						OfferQtyVolume   NUMERIC(38,6),
						SlNo    INT,
						PrdId   INT'

	SET @TblFields = '	TransactionDate,TransactionType,TransactionNumber,SalQty,SalQtyVolume,
						UnSalQty,UnSalQtyVolume,OfferQty,OfferQtyVolume,SlNo,PrdId'

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
			  INSERT INTO #RptAkzoStockLedgerReport (	TransactionDate,TransactionType,TransactionNumber,
														SalQty,SalQtyVolume,UnSalQty,UnSalQtyVolume,
														OfferQty,OfferQtyVolume,SlNo,PrdId)
			  SELECT 
					TransactionDate,TransactionType,TransactionNumber,
					SUM(SalQty),SUM(SalQty * PrdWgt) SalQtyVolume,
					SUM(UnSalQty),SUM(UnSalQty * PrdWgt) UnSalQtyVolume,
					SUM(OfferQty),SUM(OfferQty * PrdWgt) OfferQtyVolume,
					SlNo,A.PrdId
			  FROM 
					RptProductTrack A, Product B
			  WHERE 
					A. PrdId = B.Prdid 
					AND (A.CmpId=  (CASE @CmpId WHEN 0 THEN A.CmpId ELSE 0 END ) OR
							A.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
										
					AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
							LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) )

					 AND (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId ELSE 0 END) OR
							A.PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) )

					AND  TransactionDate BETWEEN @FromDate AND  @ToDate AND UsrId=@Pi_UsrId

			  GROUP BY 
					TransactionDate,TransactionType,TransactionNumber,SlNo,A.PrdId
			  ORDER BY 
					TransactionDate,SlNo

		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptAkzoStockLedgerReport ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+'  WHERE (CmpId=  (CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+', 4, '+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND (LcnId = (CASE '+CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN LcnId ELSE 0 END) OR
				LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',22,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (LevelId =  (CASE '+CAST(@CmpPrdCtgId AS NVARCHAR(10))+' WHEN 0 THEN LevelId ELSE 0 END ) OR
				LevelId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',21,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (LevelValId = (CASE '+CAST(@PrdCtgMainId AS NVARCHAR(10))+' WHEN 0 THEN LevelValId Else 0 END) OR
				LevelValId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',16,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (PrdId = (CASE '+CAST(@PrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND TransactionDate Between '''+CAST(@FromDate AS NVARCHAR(10))+''' and '''+ CAST(@FromDate AS NVARCHAR(10))+''''
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptAkzoStockLedgerReport'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END
	ELSE    --To Retrieve Data From Snap Data
	BEGIN
		PRINT @Pi_DbName
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptAkzoStockLedgerReport ' +
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
		--  SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	END
	END

	IF @SupZeroStock = 2
	BEGIN
		DELETE FROM #RptAkzoStockLedgerReport WHERE (SalQty+UnSalQty+OfferQty)=0 AND 
		TransactionType NOT IN ('Opening Stock','Closing Stock') 
	END

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)

	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptAkzoStockLedgerReport
	PRINT 'Data Executed'
	SELECT * FROM #RptAkzoStockLedgerReport ORDER BY TransactionDate,SlNo ASC 

	RETURN
END
GO
 

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AkzoProductTrackDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AkzoProductTrackDetails]
GO
----  exec [Proc_ProductTrackDetails] 5,'2010-09-15','2010-09-15'
CREATE PROCEDURE [Proc_AkzoProductTrackDetails]
(
	 @Pi_UsrId INT,
	 @Pi_FromDate DATETIME,
	 @Pi_ToDate DATETIME
)
AS
/***************************************************************************************************
* PROCEDURE	: Proc_AkzoProductTrackDetails
* PURPOSE	: To Return the Product transaction details
* CREATED	: Panneer
* CREATED DATE	: 16.03.2011
* NOTE		: General SP For Generate Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
***************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @PrdId	AS INT
	SET @PrdId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(225,5,@Pi_UsrId))
	SELECT	TransDate,A.PrdId,A.PrdBatId,ISNULL(LcnId,0) AS LcnId,
			SUM(SalOpenStock) SalOpenStock,SUM(UnSalOpenStock) UnSalOpenStock,
			SUM(OfferOpenStock) OfferOpenStock INTO #OpenStk 
	FROM StockLedger A,
	(
		SELECT MAX(TransDate) AS MaxDate,PrdId,PrdBatId  FROM StockLedger WHERE TransDate <= @Pi_FromDate 
		AND PrdId=@PrdId GROUP BY PrdId,PrdBatId
	) B
	WHERE A.TransDate=B.MaxDate AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
	AND A.PrdId=@PrdId AND B.PrdId=@PrdId
	GROUP BY TransDate,A.PrdId,A.PrdBatId,LcnId
		
	SELECT TransDate,A.PrdId,A.PrdBatId,LcnId,SUM(SalClsStock) SalClsStock,SUM(UnSalClsStock) UnSalClsStock,
	SUM(OfferClsStock) OfferClsStock  INTO #CloseStk FROM StockLedger A ,
	(		SELECT MAX(TransDate) MaxDate,PrdId,PrdBatId FROM StockLedger WHERE TransDate <= @Pi_ToDate AND PrdId=@PrdId
			GROUP BY  PrdId,PrdBatId 
	) B 
	WHERE A.TransDate=B.MaxDate AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
	AND A.PrdId=@PrdId AND B.PrdId=@PrdId
	GROUP BY TransDate,A.PrdId,A.PrdBatId,LcnId

	TRUNCATE TABLE  RptProductTrack 
	INSERT INTO RptProductTrack(LevelValId,LevelValName,LevelId,LevelName,CmpId,CmpName,PrdId,
	PrdName,PrdBatId,PrdBatCode,SalQty,UnSalQty,OfferQty,TransactionType,
	TransactionNumber,TransactionDate,UsrId,SlNo,LcnId)
	--Opening Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(O.SalOpenStock,0),ISNULL(O.UnSalOpenStock,0),
		ISNULL(O.OfferOpenStock,0),
		'Opening Stock' ,'',@Pi_FromDate ,@Pi_UsrId,1,ISNULL(O.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #OpenStk O ON PH.PrdId = O.PrdId AND PH.PrdBatId = O.PrdBatId
		AND PH.PrdId=@PrdId
	UNION ALL
	--Stock Mng (In)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management - Add',M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,2,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
--		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=0
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		and D.StkMgmtTypeId = 1
	UNION ALL
	--Stock Mng (Out)	
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management - Reduce' ,M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,3,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
--		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=1
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND  M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		and D.StkMgmtTypeId = 0
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer Out' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,4,M.FromLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer In' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,5,M.ToLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Bat Tran (In)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer Out',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,6,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.FromBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	UNION ALL
----	--- Bat Trans In (New)
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		(CASE S.SystemStockType WHEN 1 THEN (-1)*T.TransferQty ELSE 0 END ) AS SalStock,
----		(CASE S.SystemStockType WHEN 2 THEN (-1)*T.TransferQty ELSE 0 END ) AS UnSalStock,
----		(CASE S.SystemStockType WHEN 3 THEN (-1)*T.TransferQty ELSE 0 END ) AS OfferStock,
----		'Batch Transfer Out',T.BatRefNo,A.BatTrfDate,@Pi_UsrId,6,S.LcnId
----		FROM
----			BatchTransferHD A 
----			INNER JOIN BatchTransferDT T ON A.BatRefNo = T.BatRefNo
----			INNER JOIN StockType S On T.StockType = S.StockTypeId
----			INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.FrmBatId = PH.PrdBatId
----		WHERE A.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Bat Tran (Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer In',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,7,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.ToBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	UNION ALL 
--	-- New Bat Tran (Out)
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN T.TransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN T.TransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN T.TransferQty ELSE 0 END ) AS OfferStock,
--		'Batch Transfer In',T.BatRefNo,A.BatTrfDate,@Pi_UsrId,7,S.LcnId
--		FROM
--			BatchTransferHD A 
--			INNER JOIN BatchTransferDT T ON A.BatRefNo = T.BatRefNo
--			INNER JOIN StockType S On T.StockType = S.StockTypeId
--			INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.ToBatId = PH.PrdBatId
--		WHERE A.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL 
	--Salvage
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.SalvageQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.SalvageQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.SalvageQty ELSE 0 END ) AS OfferStock,
		'Salvage' TransType ,M.SalvageRefNo,M.SalvageDate,@Pi_UsrId,8,S.LcnId
		FROM
		Salvage M
		INNER JOIN SalvageProduct D ON M.SalvageRefNo = D.SalvageRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Stock journal (Out)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	--  SJ New Out
--	UNION ALL 
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS OfferStock,
--		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
--		FROM
--		StockJournalHD M
--		INNER JOIN StockJournalDet D ON M.StkJournalRefNo = D.StkJournalRefNo
--		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
--		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
--		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	--Stock journal(In)	
	UNION ALL	
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.TransferStkTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	--  SJ New IN
--	UNION ALL	
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN D.StkTransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN D.StkTransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN D.StkTransferQty ELSE 0 END ) AS OfferStock,
--		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
--		FROM
--		StockJournalHD M
--		INNER JOIN StockJournalDet D ON M.StkJournalRefNo = D.StkJournalRefNo
--		INNER JOIN StockType S ON D.TransferStkTypeId = S.StockTypeId
--		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
--		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Ret to cmp
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS OfferStock,
		'Return To Company' TransType ,
		M.RtnCmpRefNo TransNo,M.RtnCmpDate TransDate,@Pi_UsrId,11,S.LcnId
		FROM
		ReturnToCompany M
		INNER JOIN ReturnToCompanyDt D ON M.RtnCmpRefNo = D.RtnCmpRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		AND M.Status=1
	UNION ALL
	--Ret and replacement
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.RtnQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.RtnQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.RtnQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement - Return',M.RepRefNo,M.RepDate,@Pi_UsrId,12,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementIn D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Ret and replacement(Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.RepQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.RepQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.RepQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement - Replacement',M.RepRefNo,M.RepDate,@Pi_UsrId,13,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementOut D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Resell Damage Goods
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*D.Quantity,0,
		'Resell Damage Goods',M.ReDamRefNo,M.ReSellDate,@Pi_UsrId,14,M.LcnId
		FROM
		ReSellDamageMaster M
		INNER JOIN ReSellDamageDetails D ON M.ReDamRefNo = D.ReDamRefNo
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		AND M.Status=1
	UNION ALL
	--VanLoad&Unload
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Load',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,15,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 0 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL 
	--VanLoad&Unload (Unload)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Unload',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,16,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 1 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Sales		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.BaseQty,0,0,
		'Sales',M.SalInvNo,M.SalInvDate,@Pi_UsrId,17,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.FreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,18,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.FreePrdId = PH.PrdId AND D.FreePrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.SalManFreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,19,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Gift
	SELECT 		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.GiftQty,
		'Sales Gift',M.SalInvNo,M.SalInvDate,@Pi_UsrId,20,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.GiftPrdId = PH.PrdId AND D.GiftPrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		D.RcvdGoodBaseQty,0,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,21,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,E.BaseQty,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,22,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (Excess)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*E.BaseQty ELSE 0 END),
		(CASE S.SystemStockType WHEN 2 THEN (-1)*E.BaseQty ELSE 0 END),0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,23,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=2
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND D.RefuseSale=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- pur Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.Quantity,
		'Purchase Free',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,24,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptClaimScheme D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur ret (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.RetSalBaseQty,0,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,25,M.LcnId
		FROM PurchaseReturn M INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur ret (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*E.ReturnBsQty,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,26,S.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PurchaseReturnBreakup E ON E.PurRetId = D.PurRetId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur Ret Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.RetQty,
		'Purchase Return Free',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,27,M.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnClaimScheme D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1	AND PH.PrdId=@PrdId	 
	UNION ALL
	-- Sales Ret
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE ST.SystemStockType WHEN 1 THEN D.BaseQty ELSE 0 END ) AS SalStock,
		(CASE ST.SystemStockType WHEN 2 THEN D.BaseQty ELSE 0 END ) AS UnSalStock,
		(CASE ST.SystemStockType WHEN 3 THEN D.BaseQty ELSE 0 END ) AS OfferStock,
		'Sales Return',M.ReturnCode,M.ReturnDate,@Pi_UsrId,28,ST.LcnId
		FROM ReturnHeader M
		INNER JOIN ReturnProduct D ON M.Returnid = D.ReturnId
		INNER JOIN StockType ST ON D.StockTypeId = ST.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=0 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Receipt
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.RcvdGoodBaseQty,
		'Sample Receipt',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,29,M.LcnId
		FROM
		SamplePurchaseReceipt M
		INNER JOIN SamplePurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Issue		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.IssueBaseQty,
		'Sample Issue',M.IssueRefNo,M.IssueDate,@Pi_UsrId,30,M.LcnId
		FROM
		SampleIssueHd M
		INNER JOIN  SampleIssueDt D ON M.IssueId = D.IssueId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Return		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.ReturnBaseQty,
		'Sample Return',M.ReturnRefNo,M.ReturnDate,@Pi_UsrId,31,M.LcnId
		FROM
		SampleReturnHd M
		INNER JOIN  SampleReturnDt D ON M.ReturnId = D.ReturnId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1	 AND PH.PrdId=@PrdId
	--- added by Panneer
	----Sample Issue Free	
	UNION ALL
		SELECT
			PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
			PH.CmpPrdCtgName,
			PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
			0,0,(-1)*D.IssueBaseQty,
			'Sample Issue',M.IssueRefNo,M.IssueDate,@Pi_UsrId,30,M.LcnId
		FROM
			FreeIssueHd M
			INNER JOIN FreeIssueDt D ON M.IssueId = D.IssueId
			INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE
			M.IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
			AND M.Status=1 AND PH.PrdId=@PrdId
----	UNION ALL
----	--IDT (In)		
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		D.Qty AS SalStock,
----		0 AS UnSalStock,
----		0 AS OfferStock,
----		'IDT - IN',M.IDTMngRefNo,M.IDTMngDate,@Pi_UsrId,2,M.LcnId
----		FROM
----		IDTManagement M
----		INNER JOIN IDTManagementProduct D ON M.IDTMngRefNo = D.IDTMngRefNo AND StkMgmtTypeId=1
----		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
----		WHERE M.Status=1 AND M.IDTMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
----	UNION ALL
----	--IDT  (Out)	
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		(-1)*D.Qty AS SalStock,
----		0 AS UnSalStock,
----		0 AS OfferStock,
----		'IDT -OUT ' ,M.IDTMngRefNo,M.IDTMngDate,@Pi_UsrId,3,M.LcnId
----		FROM
----		IDTManagement M
----		INNER JOIN IDTManagementProduct D ON M.IDTMngRefNo = D.IDTMngRefNo AND StkMgmtTypeId=2
----		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
----		WHERE M.Status=1 AND M.IDTMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL --Closing Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(C.SalClsStock,0),
		ISNULL(C.UnSalClsStock,0),ISNULL(C.OfferClsStock,0),
		'Closing Stock' ,'',@Pi_ToDate ,@Pi_UsrId,32,ISNULL(C.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #CloseStk C ON PH.PrdId = C.PrdId AND PH.PrdBatId = C.PrdBatId AND PH.PrdId=@PrdId
END
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptAkzoRetAccStatement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptAkzoRetAccStatement]
GO
----   exec  Proc_RptAkzoRetAccStatement 222,2,0,'hh',0,0,1
CREATE  Procedure Proc_RptAkzoRetAccStatement
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
Begin
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE: Proc_RptAkzoRetAccStatement
* PURPOSE: General Procedure
* NOTES:
* CREATED: Panneer	14.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
*****************************************************************************/

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

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))


	CREATE TABLE #RptAkzoRetAccStatement
	(
			[Description]       NVARCHAR(200),
			[DocRefNo]          NVARCHAR(200),
			[Date]				DATETIME,
			[Debit]				NUMERIC (38,6),
			[Credit]			NUMERIC (38,6),
			[Balance]			NUMERIC (38,6),
			[TransactionDet]    NVARCHAR(200),
			[CheqorDueDate]     DATETIME,
			[SeqNo]				INT,
			[UserId]			INT
	)

SET @TblName = 'RptAkzoRetAccStatement'
SET @TblStruct = '	[Description]       NVARCHAR(200),
					[DocRefNo]          NVARCHAR(200),
					[Date]				DATETIME,
					[Debit]				NUMERIC (38,6),
					[Credit]			NUMERIC (38,6),
					[Balance]			NUMERIC (38,6),
					[TransactionDet]    NVARCHAR(200),
					[CheqorDueDate]     DATETIME,
					[SeqNo]				INT
					[UserId]			INT'
SET @TblFields = '  [Description],[DocRefNo],[Date],[Debit],[Credit],
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

		INSERT INTO #RptAkzoRetAccStatement ([Description],DocRefNo,Date,Debit,Credit,Balance,
											 TransactionDet,CheqorDueDate,SeqNo,UserId)
			/*	Calculate Opening Balance Details  */	
		Select  
				'Opening Balance'   [Description], '' DocRefNo, @FromDate Date,
				 0 as Debit,0 As Credit,BalanceAmount as balance,
				'' as TransactionDet,'1900-01-01' CheqorDueDate,1 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement  (NoLock) 
		Where	Details = 'Opening Balance'
				
 				 
				/*	Calculate Sales Details  */ 
		UNION ALL 
		Select  
				'Invoice' [Description],SalInvNo DocRefNo,SalInvDate Date,
				DbAmount Debit,0 as Credit,0 Balance,'' as TransactionDet,
				SalDlvDate CheqorDueDate,2 SeqNo, @Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 
		UNION ALL
		Select  
				'Total Invoice IN' [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit, Isnull(SUM(DbAmount),0) Balance,'' as TransactionDet,
				'1900-01-01' CheqorDueDate,3 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 

					/*	Calculate Cheque Details  */
		UNION ALL		
		Select  
				'Cheque Received' [Description],RI.InvRcpNo DocRefNo,InvRcpDate Date,
				0 Debit,Sum(CRAmount)  as Credit, 0 Balance,InvInsNo as TransactionDet,
				Isnull(InvInsDate,'1900-01-01') CheqorDueDate,4 SeqNo, @Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
		Group By
				RI.InvRcpNo,InvRcpDate,InvInsNo,InvInsDate 
		UNION ALL
		Select  
				'Total Receipt Received' [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0  as Credit, (-1) * Isnull(Sum(CRAmount),0) Balance,'' as TransactionDet,
				'1900-01-01' CheqorDueDate,5 SeqNo,@Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
		 

				/*	Calculate Debit Note Details  */
		UNION ALL
		Select 'Debit Note - CD' AS [Description],DBNoteNumber DocRefNo,DBNoteDate Date,
				Isnull(DbAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,6 SeqNo,@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'	
		UNION ALL
		Select 'Total Debit Notes' AS [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit, Isnull(Sum(DbAmount - CRAmount),0) Balance,'' as TransaonDet,
				'1900-01-01' CheqorDueDate,7 SeqNo,@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'
				
				/*  Calculate Return  Details  */
		UNION ALL
		Select  'Credit Invoice',ReturnCode DocRefNo,ReturnDate Date,
				0 as Debit,CrAmount as Credit,0 as  Balance,Isnull(DocRefNo,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,8 SeqNo,@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
		UNION ALL
		Select  'Total Credit Invoice','' DocRefNo,'1900-01-01' Date,
				0 as Debit,0 as Credit,Isnull(Sum(CrAmount),0) * (-1) as  Balance,
				'' as TransaonDet,
				'1900-01-01' CheqorDueDate,9 SeqNo,@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
	
 				/*  Calculate Credit Note  Details  */
		UNION ALL
		Select 'Credit Note' AS [Description],CRNoteNumber DocRefNo,CRNoteDate Date,
				Isnull(DBAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,10 SeqNo,@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'	
		UNION ALL
		Select 'Total Credit Notes' AS [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit,-(1) * Isnull(Sum(CRAmount-DBAmount),0) Balance,'' as TransaonDet,
				'1900-01-01' CheqorDueDate,11 SeqNo,@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Replacement' AS [Description],RepRefNo DocRefNo,RepDate  Date,
				DBAmount Debit,0 Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'1900-01-01' CheqorDueDate,12 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Replacement'
		Union ALL
		Select 
				'Total Return & Replacement-Replacement' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit,Isnull(Sum(DBAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,13 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Replacement'

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Return' AS [Description],RepRefNo DocRefNo,RepDate  Date,
				0 Debit,CRAmount Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'1900-01-01' CheqorDueDate,14 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Return'
		Union ALL
		Select 
				'Total Return & Replacement-Return' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit,(-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,15 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Return'

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cheque Bounce' AS [Description],InvRcpNo,InvRcpDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'1900-01-01' CheqorDueDate,16 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cheque Bounce'
		Union ALL
		Select 
				'Total Collection-Cheque Bounce' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,17 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cheque Bounce'

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cash Cancellation' AS [Description],InvRcpNo,InvRcpDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'1900-01-01' CheqorDueDate,18 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cash Cancellation'
		Union ALL
		Select 
				'Total Collection-Cash Cancellation' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,19 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cash Cancellation'

				/*  Calculate Retailer On Account Details  */
		Union ALl
		Select 
				'Retailer On Account' AS [Description],RtrAccRefNo,ChequeDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,Remarks DocRefNo,
				'1900-01-01' CheqorDueDate,20 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , RetailerOnAccount A (Nolock)
		WHERE
				A.RtrAccRefNo = T.DocumentNo AND Details = 'Retailer On Account'
		Union ALL
		Select 
				'Total Retailer On Account' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, (-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,21 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Retailer On Account'

				/*  Calculate Closing Balance Details  */
		UNION ALL
		Select  
				'Closing Balance' [Description], '' DocRefNo,@ToDate Date,
				0 as Debit,0 Credit, 0  Balance,
				'' as TransactionDet,'1900-01-01' CheqorDueDate,22 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement 
		Where
				Details = 'Closing Balance'	

		DECLARE @ClBal Numeric(18,4)
		Select @ClBal = Sum(Balance)   From  #RptAkzoRetAccStatement 
		Where SeqNo in (1,3,5,7,9,11,13,15,17,19,21)
				
		Update #RptAkzoRetAccStatement Set Balance = @ClBal Where SeqNo = 22
		
	END

	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptAkzoRetAccStatement

	Delete From #RptAkzoRetAccStatement 
	WHere Balance  = 0 and SeqNo  in (3,5,7,9,11,13,15,17,19,21)
	Select * from #RptAkzoRetAccStatement Order by SeqNo,[Description]
END
GO
 
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_ProductTrackDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_ProductTrackDetails]
GO
--Exec Proc_ProductTrackDetails 1,'2008-01-01','2008-08-05'
--SELECT * FROM RptProductTrack WHERE Prdid=8576 ORDER BY Transactiondate
CREATE       PROCEDURE [dbo].[Proc_ProductTrackDetails]
(
	 @Pi_UsrId INT,
	 @Pi_FromDate DATETIME,
	 @Pi_ToDate DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_ProductTrackDetails
* PURPOSE	: To Return the Product transaction details
* CREATED	: MarySubashini.S
* CREATED DATE	: 01/08/2008
* NOTE		: General SP Returning the Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}     {developer}  {brief modification description}
* 03/02/2009 Nanda	  Added Sample management
*********************************/
SET NOCOUNT ON
BEGIN
	SELECT TransDate,PrdId,PrdBatId,ISNULL(LcnId,0) AS LcnId,SUM(SalOpenStock) SalOpenStock,
	SUM(UnSalOpenStock) UnSalOpenStock,SUM(OfferOpenStock) OfferOpenStock INTO #OpenStk FROM StockLedger
	WHERE TransDate in (SELECT MAX(TransDate) FROM StockLedger WHERE TransDate <= @Pi_FromDate)
	GROUP BY TransDate,PrdId,PrdBatId,LcnId
		
	SELECT TransDate,PrdId,PrdBatId,LcnId,SUM(SalClsStock) SalClsStock,SUM(UnSalClsStock) UnSalClsStock,
	SUM(OfferClsStock) OfferClsStock INTO #CloseStk FROM StockLedger
	WHERE TransDate in (SELECT MAX(TransDate) FROM StockLedger WHERE TransDate <= @Pi_ToDate)
	GROUP BY TransDate,PrdId,PrdBatId,LcnId
	
	DELETE FROM RptProductTrack WHERE UsrId IN(0,@Pi_UsrId)
	INSERT INTO RptProductTrack(LevelValId,LevelValName,LevelId,LevelName,CmpId,CmpName,PrdId,
	PrdName,PrdBatId,PrdBatCode,SalQty,UnSalQty,OfferQty,TransactionType,
	TransactionNumber,TransactionDate,UsrId,SlNo,LcnId)
	--Opening Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(O.SalOpenStock,0),ISNULL(O.UnSalOpenStock,0),
		ISNULL(O.OfferOpenStock,0),
		'Opening Stock' ,'',@Pi_FromDate ,@Pi_UsrId,1,ISNULL(O.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #OpenStk O ON PH.PrdId = O.PrdId AND PH.PrdBatId = O.PrdBatId
	UNION ALL
	--Stock Mng (In)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management – Add',M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,2,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
--		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=0
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		and D.StkMgmtTypeId = 1
	UNION ALL
	--Stock Mng (Out)	
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management – Reduce' ,M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,3,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
------		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=1
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND  M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		and D.StkMgmtTypeId = 0
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer Out' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,4,M.FromLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer In' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,5,M.ToLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	-- Bat Tran (In)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer Out',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,6,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.FromBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	-- Bat Tran (Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer In',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,7,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.ToBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Salvage
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.SalvageQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.SalvageQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.SalvageQty ELSE 0 END ) AS OfferStock,
		'Salvage' TransType ,M.SalvageRefNo,M.SalvageDate,@Pi_UsrId,8,S.LcnId
		FROM
		Salvage M
		INNER JOIN SalvageProduct D ON M.SalvageRefNo = D.SalvageRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Stock journal (Out)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Stock journal(In)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,10,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.TransferStkTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Ret to cmp
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS OfferStock,
		'Return To Company' TransType ,
		M.RtnCmpRefNo TransNo,M.RtnCmpDate TransDate,@Pi_UsrId,11,S.LcnId
		FROM
		ReturnToCompany M
		INNER JOIN ReturnToCompanyDt D ON M.RtnCmpRefNo = D.RtnCmpRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--Ret and replacement
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.RtnQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.RtnQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.RtnQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement – Return',M.RepRefNo,M.RepDate,@Pi_UsrId,12,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementIn D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Ret and replacement(Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.RepQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.RepQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.RepQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement – Replacement',M.RepRefNo,M.RepDate,@Pi_UsrId,13,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementOut D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Resell Damage Goods
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*D.Quantity,0,
		'Resell Damage Goods',M.ReDamRefNo,M.ReSellDate,@Pi_UsrId,14,M.LcnId
		FROM
		ReSellDamageMaster M
		INNER JOIN ReSellDamageDetails D ON M.ReDamRefNo = D.ReDamRefNo
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--VanLoad&Unload
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Load',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,15,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 0 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--VanLoad&Unload (Unload)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Unload',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,16,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 1 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	-- Sales		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.BaseQty,0,0,
		'Sales',M.SalInvNo,M.SalInvDate,@Pi_UsrId,17,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (4,5)
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.FreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,18,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.FreePrdId = PH.PrdId AND D.FreePrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (4,5)
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.SalManFreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,19,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (4,5)
	UNION ALL
	-- Gift
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.GiftQty,
		'Sales Gift',M.SalInvNo,M.SalInvDate,@Pi_UsrId,20,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.GiftPrdId = PH.PrdId AND D.GiftPrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (4,5)
	UNION ALL
	--Pur (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		D.RcvdGoodBaseQty,0,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,21,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--Pur (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,E.BaseQty,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,22,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--Pur (Excess)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*E.BaseQty ELSE 0 END),
		(CASE S.SystemStockType WHEN 2 THEN (-1)*E.BaseQty ELSE 0 END),0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,23,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=2
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND D.RefuseSale=1
	UNION ALL
	-- pur Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.Quantity,
		'Purchase Free',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,24,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptClaimScheme D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1
	UNION ALL
	-- Pur ret (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.RetSalBaseQty,0,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,25,M.LcnId
		FROM PurchaseReturn M INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	-- Pur ret (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*E.ReturnBsQty,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,26,S.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PurchaseReturnBreakup E ON E.PurRetId = D.PurRetId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	-- Pur Ret Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.RetQty,
		'Purchase Return Free',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,27,M.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnClaimScheme D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1		
	UNION ALL
	-- Sales Ret
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE ST.SystemStockType WHEN 1 THEN D.BaseQty ELSE 0 END ) AS SalStock,
		(CASE ST.SystemStockType WHEN 2 THEN D.BaseQty ELSE 0 END ) AS UnSalStock,
		(CASE ST.SystemStockType WHEN 3 THEN D.BaseQty ELSE 0 END ) AS OfferStock,
		'Sales Return',M.ReturnCode,M.ReturnDate,@Pi_UsrId,28,ST.LcnId
		FROM ReturnHeader M
		INNER JOIN ReturnProduct D ON M.Returnid = D.ReturnId
		INNER JOIN StockType ST ON D.StockTypeId = ST.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=0
	UNION ALL
	--Sample Receipt
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.RcvdGoodBaseQty,
		'Sample Receipt',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,29,M.LcnId
		FROM
		SamplePurchaseReceipt M
		INNER JOIN SamplePurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--Sample Issue		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.IssueBaseQty,
		'Sample Issue',M.IssueRefNo,M.IssueDate,@Pi_UsrId,30,M.LcnId
		FROM
		SampleIssueHd M
		INNER JOIN  SampleIssueDt D ON M.IssueId = D.IssueId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	
	UNION ALL
	--Sample Return		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.ReturnBaseQty,
		'Sample Return',M.ReturnRefNo,M.ReturnDate,@Pi_UsrId,31,M.LcnId
		FROM
		SampleReturnHd M
		INNER JOIN  SampleReturnDt D ON M.ReturnId = D.ReturnId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1	
	UNION ALL --Closing Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(C.SalClsStock,0),
		ISNULL(C.UnSalClsStock,0),ISNULL(C.OfferClsStock,0),
		'Closing Stock' ,'',@Pi_ToDate ,@Pi_UsrId,32,ISNULL(C.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #CloseStk C ON PH.PrdId = C.PrdId AND PH.PrdBatId = C.PrdBatId
END
GO
IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='PurchaseConfirmationExtractExcel')
	BEGIN
    CREATE TABLE PurchaseConfirmationExtractExcel
	(
	[DistCode] [nvarchar](50)  NULL,
    [DistName] [nvarchar](200)  NULL,
    [TransName] [NVarchar] (200),
    [GRNRefNo] [nvarchar](100)  NULL,
	[GRNInvDate] [datetime] NULL,
    [GRNCmpInvNo] [nvarchar](50)  NULL,
    [GRNRcvdDate] [datetime] NULL,
    [GRNPORefNo] [nvarchar](50)  NULL,
	[SupplierCode] [nvarchar](100)  NULL,
    [SupplierName] [Nvarchar] (200),
	[TransporterCode] [nvarchar](100)  NULL,
    [TransporterName] [nvarchar](200)  NULL,
	[LRNo] [nvarchar](100)  NULL,
	[LRDate] [datetime] NULL,
	[GRNGrossAmt] [numeric](38, 6) NULL,
	[GRNDiscAmt] [numeric](38, 6) NULL,
	[GRNTaxAmt] [numeric](38, 6) NULL,
	[GRNSchAmt] [numeric](38, 6) NULL,
	[GRNOtherChargesAmt] [numeric](38, 6) NULL,
	[GRNHandlingChargesAmt] [numeric](38, 6) NULL,
	[GRNTotDedn] [numeric](38, 6) NULL,
	[GRNTotAddn] [numeric](38, 6) NULL,
	[GRNRoundOffAmt] [numeric](38, 6) NULL,
	[GRNNetAmt] [numeric](38, 6) NULL,
	[GRNNetPayableAmt] [numeric](38, 6) NULL,
	[GRNDiffAmt] [numeric](38, 6) NULL,
	[PrdSchemeFlag] [nvarchar](10)  NULL,
	[PrdCmpSchCode] [nvarchar](100)  NULL,
	[PrdLcnCode] [nvarchar](100)  NULL,
    [PrdLcnName] [nvarchar](200)  NULL,
	[PrdCode] [nvarchar](550)  NULL,
    [PrdName] [nvarchar](550)  NULL,
	[PrdBatCode] [nvarchar](200)  NULL,
	[PrdInvQty] [int] NULL,
	[PrdRcvdQty] [int] NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdShortQty] [int] NULL,
	[PrdExcessQty] [int] NULL,
	[PrdExcessRefusedQty] [int] NULL,
	[PrdLSP] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetRate] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[PrdLineBreakUpType] [nvarchar](100)  NULL,
	[PrdLineLcnCode] [nvarchar](100)  NULL,
    [PrdLineLcnName] [nvarchar](100)  NULL,
	[PrdLineStockType] [nvarchar](100)  NULL,
	[PrdLineQty] [int] NULL
   )
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_PurchaseConfirmation')
DROP PROCEDURE  Proc_AN_PurchaseConfirmation
GO
CREATE   PROCEDURE Proc_AN_PurchaseConfirmation
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
BEGIN
	DECLARE @DistNm	As nVarchar(200)
    DECLARE @DistCode AS Nvarchar(100)
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @DistNm = Distributorname FROM Distributor	
    DELETE FROM PurchaseConfirmationExtractExcel
	INSERT INTO PurchaseConfirmationExtractExcel
	(
		DistCode				,
        DistName                ,
		TransName				,
		GRNRefNo				,
		GRNInvDate				,
		GRNCmpInvNo				,
		GRNRcvdDate				,
		GRNPORefNo				,
		SupplierCode			,
		SupplierName			,
		TransporterCode			,
		TransporterName			,
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
		PrdSchemeFlag			,
		PrdCmpSchCode			,	
		PrdLcnCode				,
        PrdLcnName				,
		PrdCode					,
        PrdName					,
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
		PrdLineLcnCode			,
        PrdLineLcnName			,
		PrdLineStockType		,
		PrdLineQty				
	)
	SELECT
		@DistCode ,@DistNm,'Purchase Confirmation',
        PR.PurRcptRefNo AS GrnRefNo,
        PR.InvDate as GrnInvdate,
		PR.CmpInvNo AS GrnCmpinvno ,
		PR.GoodsRcvdDate AS GrnRcvdDate,
		PR.PurOrderRefNo,S.SpmCode,S.SpmName,T.TransporterCode,T.TransporterName,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,'No','',L.LcnCode,L.LcnName,
		P.PrdCCode AS ProdCode ,P.Prdname AS Prdname,PB.CmpBatCode AS PrdBatCde ,
		PRP.InvBaseQty,PRP.RcvdGoodBaseQty,UnSalBaseQty,ShrtBaseQty,
		(CASE PRP.RefuseSale WHEN 0 THEN ExsBaseQty ELSE 0 END),
		(CASE PRP.RefuseSale WHEN 1 THEN ExsBaseQty ELSE 0 END),
		PRP.PrdLSP,PRP.PrdGrossAmount,PRP.PrdDiscount,PRP.PrdTaxAmount,PRP.PrdUnitNetRate,PRP.PrdNetAmount,
		ISNULL((CASE PRB.BreakUpType WHEN 1 THEN 'UnSaleable' WHEN 2 THEN 'Excess' END),''),
		ISNULL(PRBL.LcnCode,''),ISNULL(PRBL.LcnName,''),
		ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
		ISNULL(PRB.BaseQty,0)				
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1  
		INNER JOIN Product P ON P.PrdId = PRP.PrdId AND Pr.InvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN Location L ON L.LcnId=PR.LcnId AND PR.lcnid=L.lcnid
		LEFT OUTER JOIN PurchaseReceiptBreakUp PRB ON PRP.PurRcptId=PRB.PurRcptId AND PRP.PrdSlNo=PRB.PrdSlNo
		LEFT OUTER JOIN StockType ST ON PRB.StockTypeId=ST.StockTypeId
		LEFT OUTER JOIN Location PRBL ON PRBL.LcnId=ST.LcnId
	UNION ALL
	SELECT
		@DistCode ,@DistNm,'Purchase Confirmation',
        PR.PurRcptRefNo AS GrnRefNo,
        PR.InvDate as GrnInvdate,
		PR.CmpInvNo AS GrnCmpinvno ,
		PR.GoodsRcvdDate AS GrnRcvdDate,
        PR.PurOrderRefNo,S.SpmCode,S.SpmName,T.TransporterCode,T.TransporterName,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),
		ISNULL(Sch.CmpSchCode,Sch.SchCode),L.LcnCode,L.LcnName,
		P.PrdCCode AS ProdCode ,P.Prdname AS Prdname,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'','','',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 
		AND PRP.TypeId=2 AND Pr.InvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId AND PR.lcnid=L.lcnid
		LEFT OUTER JOIN SchemeMaster Sch ON Sch.SchId=RefId
	UNION ALL
	SELECT
		@DistCode ,@DistNm,'Purchase Confirmation',
        PR.PurRcptRefNo AS GrnRefNo,
        PR.InvDate as GrnInvdate,
		PR.CmpInvNo AS GrnCmpinvno ,
		PR.GoodsRcvdDate AS GrnRcvdDate,
		PR.PurOrderRefNo,S.SpmCode,S.SpmName,T.TransporterCode,T.TransporterName,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),
		ISNULL(CSD.RefCode,''),L.LcnCode,L.LcnName,
		P.PrdCCode AS ProdCode ,P.Prdname AS Prdname,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'','','',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0					
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 
		AND PRP.TypeId=1
        AND Pr.InvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId AND PR.lcnid=L.lcnid
		INNER JOIN ClaimSheetHd CSH ON CSH.ClmId=PRP.RefId
		INNER JOIN ClaimSheetDetail CSD ON CSH.ClmId=CSD.ClmId AND PRP.SlNo=CSD.SlNo
	
END
GO

DELETE FROM RptAKSOExcelHeaders WHERE Rptid=502
INSERT INTO RptAKSOExcelHeaders VALUES (502,1,'DistCode','Distributor Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,2,'DistName','Distributor Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,3,'TransName','Transaction Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,4,'GRNRefNo','GRN Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,5,'GRNInvDate','GRN Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,6,'GRNCmpInvNo','Company Invoice Number',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,7,'GRNRcvdDate','Company Invoice Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,8,'GRNPORefNo','Purchase Order Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,9,'SupplierCode','Supplier Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,10,'SupplierName','Supplier Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,11,'TransporterCode','Transporter Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,12,'TransporterName','Transporter Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,13,'LRNo','LRNo',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,14,'LRDate','LRDate',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,15,'GRNGrossAmt','Invoice Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,16,'GRNDiscAmt','Invoice Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,17,'GRNTaxAmt','Invoice tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,18,'GRNSchAmt','Invoice Scheme Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,19,'GRNOtherChargesAmt','Net - Other Charges',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,20,'GRNHandlingChargesAmt','Handling Charges',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,21,'GRNTotDedn','Total Deduction',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,22,'GRNTotAddn','Total Addition',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,23,'GRNRoundOffAmt','Round Off Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,24,'GRNNetAmt','Invoice Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,25,'GRNNetPayableAmt','Net Payable Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,26,'GRNDiffAmt','Difference Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,27,'PrdSchemeFlag','Scheme Flag',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,28,'PrdCmpSchCode','Company Scheme Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,29,'PrdLcnCode','Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,30,'PrdLcnName','Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,31,'PrdCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,32,'PrdName','Product Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,33,'PrdBatCode','Batch Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,34,'PrdInvQty','Invoice Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,35,'PrdRcvdQty','Received Good Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,36,'PrdUnSalQty','Unsalable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,37,'PrdShortQty','Shortage Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,38,'PrdExcessQty','Excess Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,39,'PrdExcessRefusedQty','Excess Refused Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,40,'PrdLSP','LSP',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,41,'PrdGrossAmt','Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,42,'PrdDiscAmt','Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,43,'PrdTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,44,'PrdNetRate','Net Rate',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,45,'PrdNetAmt','Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,46,'PrdLineBreakUpType','Line Break Up Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,47,'PrdLineLcnCode','Line Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,48,'PrdLineLcnName','Line Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,49,'PrdLineStockType','Line Stock Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,50,'PrdLineQty','Line Quantity',1,1)
GO

IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='PurchaseReturnExtractExcel')
BEGIN
CREATE TABLE PurchaseReturnExtractExcel
(
    [DistCode] [nvarchar](50)  NULL,
    [DistName] [nvarchar](200)  NULL,
    [TransName] [NVarchar] (200),
	[PRNRefNo] [nvarchar](100)  NULL,
	[PRNDate] [datetime] NULL,
	[SpmCode] [nvarchar](100)  NULL,
    [SpmName] [Nvarchar](250),
	[PRNMode] [nvarchar](100)  NULL,
	[PRNType] [nvarchar](100)  NULL,
	[GRNNo] [nvarchar](100)  NULL,
    [GRNDate] [datetime],
	[CmpInvNo] [nvarchar](100)  NULL,
    [InvRcpdate] [datetime],
	[PRNGrossAmt] [numeric](38, 6) NULL,
	[PRNDiscAmt] [numeric](38, 6) NULL,
	[PRNSchAmt] [numeric](38, 6) NULL,
	[PRNOtherChargesAmt] [numeric](38, 6) NULL,
	[PRNTaxAmt] [numeric](38, 6) NULL,
	[PRNTotDedn] [numeric](38, 6) NULL,
	[PRNTotAddn] [numeric](38, 6) NULL,
	[PRNRoundOffAmt] [numeric](38, 6) NULL,
	[PRNNetAmt] [numeric](38, 6) NULL,
	[PrdSchemeFlag] [nvarchar](10)  NULL,
	[PrdCmpSchCode] [nvarchar](100)  NULL,
	[PrdLcnCode] [nvarchar](100)  NULL,
    [PrdLcnName] [nvarchar](250),
	[PrdCode] [nvarchar](100)  NULL,
    [PrdName] [nvarchar](550)  NULL,
	[PrdBatCode] [nvarchar](100)  NULL,
	[PrdSalQty] [int] NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetRate] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[Reason] [nvarchar](200)  NULL,
	[PrdLineBreakUpType] [nvarchar](100)  NULL,
	[PrdLineLcnCode] [nvarchar](100)  NULL,
	[PrdLineStockType] [nvarchar](100)  NULL,
	[PrdLineQty] [int] NULL
)
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_PurchaseReturn')
DROP PROCEDURE  Proc_AN_PurchaseReturn
GO
CREATE     PROCEDURE Proc_AN_PurchaseReturn
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
BEGIN
	DECLARE @DistNm	As nVarchar(200)
    DECLARE @DistCode AS Nvarchar(100)
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @DistNm = Distributorname FROM Distributor	
    DELETE FROM PurchaseReturnExtractExcel
	INSERT INTO PurchaseReturnExtractExcel
	(
		DistCode			,
        DistName			,
		TransName			,
		PRNRefNo			,	
		PRNDate				,
		SpmCode				,
		SpmName				,
		PRNMode				,
		PRNType				,
		GRNNo				,
        GRNDate				,
		CmpInvNo			,
        InvRcpDate			,
		PRNGrossAmt			,
		PRNDiscAmt			,
		PRNSchAmt			,
		PRNOtherChargesAmt	,
		PRNTaxAmt			,
		PRNTotDedn			,
		PRNTotAddn			,
		PRNRoundOffAmt		,
		PRNNetAmt			,
		PrdSchemeFlag		,
		PrdCmpSchCode		,
		PrdLcnCode			,
        PrdLcnName 			,
		PrdCode				,
        PrdName				,
		PrdBatCode			,
		PrdSalQty			,
		PrdUnSalQty			,
		PrdRate				,
		PrdGrossAmt			,
		PrdDiscAmt			,
		PrdTaxAmt			,
		PrdNetRate			,
		PrdNetAmt			,
		Reason				,
		PrdLineBreakUpType	,	
		PrdLineLcnCode		,
		PrdLineStockType	,	
		PrdLineQty			
	)
	SELECT @DistCode,@DistNm,'Purchase Return',PR.PurRetRefNo,PR.PurRetDate,S.SpmCode,S.SpmName,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PRT.Invdate,PR.CmpInvNo,PRT.GoodsRcvdDate,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,PR.TotalAddition,0,PR.NetAmount,
	'No','',L.LcnCode,L.LcnName,P.PrdCCode,P.PrdName,PB.PrdBatCode,PRP.RetSalBaseQty,PRP.RetUnSalBaseQty,
	PRP.PrdUnitLSP,PRP.PrdGrossAmount,PRP.PrdDiscount,PRP.PrdTaxAmount,PRP.PrdUnitNetRate,PRP.PrdNetAmount,ISNULL(R.Description,''),
	ISNULL((CASE PRB.BreakUpType WHEN 1 THEN 'UnSaleable' WHEN 2 THEN 'Excess' END),''),
	ISNULL(PRBL.LcnCode,''),
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	ISNULL(PRB.BaseQty,0)
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnProduct PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId AND PR.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN Location L ON L.LcnId=PR.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId	
	LEFT OUTER JOIN ReasonMaster R(NOLOCK) ON PRP.ReasonId=R.ReasonId
	LEFT OUTER JOIN PurchaseReturnBreakUp PRB ON PRP.PurRetId=PRB.PurRetId AND PRP.PrdSlNo=PRB.PrdSlNo
	LEFT OUTER JOIN StockType ST ON PRB.StockTypeId=ST.StockTypeId
	LEFT OUTER JOIN Location PRBL ON PRBL.LcnId=ST.LcnId
    LEFT OUTER JOIN PurchaseReceipt PRT ON PRT.PurRcptId=PR.PurRcptId AND PRT.LcnId = PRBL.LcnId AND PRT.PurRcptRefNo=PR.PurRcptRefNo
	UNION ALL
	SELECT @DistCode,@DistNm,'Purchase Return',PR.PurRetRefNo,PR.PurRetDate,S.SpmCode,S.SpmName,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PRT.Invdate,PR.CmpInvNo,PRT.GoodsRcvdDate,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,
	PR.TotalAddition,0,PR.NetAmount,0,
	(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),ISNULL(SM.CmpSchCode,SM.SchCode),
	L.LcnCode,L.LcnName,P.PrdCCode,P.PrdName,PB.PrdBatCode,PRP.RetQty,0,
	PRP.RetValue,PRP.RetAmount,0,0,0,PRP.RetAmount,'','',
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	0
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnClaimScheme PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId AND PRP.TypeId=2
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId AND PR.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
	INNER JOIN Location L ON L.LcnId=ST.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId		
	LEFT OUTER JOIN SchemeMaster SM(NOLOCK) ON SM.SchId=PRP.RefId
	LEFT OUTER JOIN PurchaseReceipt PRT ON PRT.PurRcptId=PR.PurRcptId  AND PRT.PurRcptRefNo=PR.PurRcptRefNo
	UNION ALL
	SELECT @DistCode,@DistNm,'Purchase Return',PR.PurRetRefNo,PR.PurRetDate,S.SpmCode,S.SpmName,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PRT.Invdate,PR.CmpInvNo,PRT.GoodsRcvdDate,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,
	PR.TotalAddition,0,PR.NetAmount,0,
	(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),ISNULL(CSD.RefCode,''),
    L.LcnCode,L.LcnName,P.PrdCCode,P.PrDName,PB.PrdBatCode,PRP.RetQty,0,
	PRP.RetValue,PRP.RetAmount,0,0,0,PRP.RetAmount,'','',
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	0
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnClaimScheme PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId AND PRP.TypeId=1 
	INNER JOIN PurchaseReceiptClaimScheme PRPT(NOLOCK) ON PR.PurRcptId=PRPT.PurRcptId AND PRPT.TypeId=1
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId AND PR.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
	INNER JOIN Location L ON L.LcnId=ST.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId		
	LEFT OUTER JOIN ClaimSheetHd CSH ON CSH.ClmId=PRP.RefId
	LEFT OUTER JOIN ClaimSheetDetail CSD ON CSH.ClmId=CSD.ClmId AND PRPT.SlNo=CSD.SlNo
    LEFT OUTER JOIN PurchaseReceipt PRT ON PRT.PurRcptId=PR.PurRcptId  AND PRT.PurRcptRefNo=PR.PurRcptRefNo
END
GO

DELETE FROM RptAKSOExcelHeaders WHERE Rptid=503
INSERT INTO RptAKSOExcelHeaders VALUES (503,1,'DistCode','Distributor Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,2,'DistName','Distributor Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,3,'TransName','Transaction Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,4,'PRNRefNo','Return Reference Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,5,'PRNDate','Purchase Return Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,6,'SpmCode','Supplier Code',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,7,'SpmName','Supplier Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,8,'PRNMode','Purchase Return Mode',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,9,'PRNType','Purchase Return Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,10,'GRNNo','GRN Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,11,'GRNDate','GRN Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,12,'CmpInvNo','Company Invoice Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,13,'InvRcpdate','Company Invoice Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,14,'PRNGrossAmt','Invoice Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,15,'PRNDiscAmt','Invoice Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,16,'PRNSchAmt','Invoice Scheme Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,17,'PRNOtherChargesAmt','Net - Other Charges',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,18,'PRNTaxAmt','Invoice Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,19,'PRNTotDedn','Total Deduction',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,20,'PRNTotAddn','Total Addition',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,21,'PRNRoundOffAmt','Round Off Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,22,'PRNNetAmt','Invoice Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,23,'PrdSchemeFlag','Scheme Flag',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,24,'PrdCmpSchCode','Company Scheme Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,25,'PrdLcnCode','Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,26,'PrdLcnName','Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,27,'PrdCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,28,'PrdName','Product Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,29,'PrdBatCode','Batch Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,30,'PrdSalQty','Salable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,31,'PrdUnSalQty','Unsalable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,32,'PrdRate','LSP',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,33,'PrdGrossAmt','Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,34,'PrdDiscAmt','Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,35,'PrdTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,36,'PrdNetRate','Net Rate',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,37,'PrdNetAmt','Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,38,'Reason','Reason',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,39,'PrdLineBreakUpType','Line Breakup Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,40,'PrdLineLcnCode','Line Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,41,'PrdLineStockType','Line Stock Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,42,'PrdLineQty','Line Quantity',1,1)
GO

IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='SalesDetailExtractExcel')
	BEGIN
    CREATE TABLE SalesDetailExtractExcel
		(
			DistCode NVARCHAR(150),
			DistName NVARCHAR(150),
            TransName NVarchar(200),
            Salinvno Nvarchar(150),
            Salinvdate datetime,
            SalDlvDate	datetime,
            SalInvMode Nvarchar(150),
            SalInvType Nvarchar(200),
            SalGrossAmt numeric(18,2),
            SalSplDiscAmt numeric(18,2),
            SalSchDiscAmt numeric(18,2),
			SalCashDiscAmt numeric(18,2),
			SalDBDiscAmt numeric(18,2),
            SalTaxAmt numeric(18,2),
			SalWDSAmt numeric(18,2),
            SalDbAdjAmt	numeric(18,2),
			SalCrAdjAmt	numeric(18,2),
            SalOnAccountAmt	numeric(18,2),
			SalMktRetAmt numeric(18,2),
            SalReplaceAmt numeric(18,2),
		    SalOtherChargesAmt numeric(18,2),
            SalTotDedn	numeric(18,2),
		    SalTotAddn	numeric(18,2),
            SalRoundOffAmt numeric(18,2),
		    SalNetAmt numeric(18,2),
            LcnName Nvarchar(400),
            SalesmanCode Nvarchar(200),
		    SalesmanName Nvarchar(400),
            SalesRouteCode Nvarchar(200),
			SalesRouteName Nvarchar(400),
            RtrCode	Nvarchar(200),
		    RtrName	Nvarchar(400),
            ProductCode	NVARCHAR(550),
			ProductName	NVARCHAR(550),
            Batchcde Nvarchar(250),
            SalInvQty int,
            PrdSelRateBeforeTax numeric(18,2),
            PrdSelRateAfterTax numeric(18,2),
            PrdfreeQty int,
            PrdGrossamt numeric(18,2),
            PrdSplDiscAmt numeric(18,2),
            PrdSchDiscAmt numeric(18,2),
            PrdCashDiscAmt numeric(18,2),
            PrdDBDiscAmt numeric(18,2),
            PrdTaxAmt numeric(18,2),
            PrdNetAmt numeric(18,2)
     )
   End   
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_SalesDetail')
DROP PROCEDURE  Proc_AN_SalesDetail
GO
CREATE PROCEDURE Proc_AN_SalesDetail
(
 	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
as
BEGIN
	DECLARE @DistCode	As nVarchar(50)
    DECLARE @DistNm	As nVarchar(200)
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @DistNm = Distributorname FROM Distributor
    DELETE FROM SalesDetailExtractExcel	
    INSERT INTO SalesDetailExtractExcel
	(
			DistCode ,
			DistName ,
            TransName ,
            Salinvno ,
            Salinvdate ,
            SalDlvDate,
            SalInvMode ,
            SalInvType ,
            SalGrossAmt ,
            SalSplDiscAmt ,
            SalSchDiscAmt ,
			SalCashDiscAmt ,
			SalDBDiscAmt ,
            SalTaxAmt ,
			SalWDSAmt,
            SalDbAdjAmt	,
			SalCrAdjAmt	,
            SalOnAccountAmt	,
			SalMktRetAmt ,
            SalReplaceAmt ,
		    SalOtherChargesAmt ,
            SalTotDedn	,
		    SalTotAddn	,
            SalRoundOffAmt ,
		    SalNetAmt ,
            LcnName ,
            SalesmanCode ,
		    SalesmanName,
            SalesRouteCode ,
			SalesRouteName ,
            RtrCode,
		    RtrName	,
            ProductCode	,
			ProductName	,
            Batchcde,
            SalInvQty ,
            PrdSelRateBeforeTax ,
            PrdSelRateAfterTax ,
            PrdfreeQty ,
            PrdGrossamt ,
            PrdSplDiscAmt ,
            PrdSchDiscAmt ,
            PrdCashDiscAmt ,
            PrdDBDiscAmt ,
            PrdTaxAmt ,
            PrdNetAmt 
	)
	 SELECT  @DistCode,@DistNm,'SalesDetail',A.SalInvNo,A.SalInvDate,A.SalDlvDate,  
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,  
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,  
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,  
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,  
	A.OtherCharges,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,L.LcnName,  
	B.SMCode,B.SMName,C.RMCode,C.RMName,R.CmpRtrCode,R.RtrName,  
	H.PrdCCode,H.Prdname,I.CmpBatCode,  
	G.BaseQty AS SalInvQty ,(G.PrdGrossAmountAftEdit/G.BaseQty),G.PrdUom1EditedNetRate,G.SalManFreeQty AS Prdfreeqty ,   
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,  
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount  
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
	INNER JOIN Location L (NOLOCK) ON L.LcnId=A.LcnId  
	WHERE A.Dlvsts IN (4,5) and A.Salinvdate BETWEEN @Pi_FromDate AND @Pi_ToDate
END
GO

DELETE FROM RptAKSOExcelHeaders WHERE Rptid=504
INSERT INTO RptAKSOExcelHeaders VALUES (504,1,'DistCode','Distributor Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,2,'DistName','Distributor Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,3,'TransName','Transaction Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,4,'Salinvno','Bill Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,5,'Salinvdate','Bill Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,6,'SalDlvDate','Delivery Date',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,7,'SalInvMode','Mode',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,8,'SalInvType','Bill Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,9,'SalGrossAmt','Invoice Gross Amt',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,10,'SalSplDiscAmt','Invoice Special Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,11,'SalSchDiscAmt','Scheme Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,12,'SalCashDiscAmt','Cash Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,13,'SalDBDiscAmt','Distributor Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,14,'SalTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,15,'SalWDSAmt','Window Display Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,16,'SalDbAdjAmt','Debot Note Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,17,'SalCrAdjAmt','Credit Note Adjustment Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,18,'SalOnAccountAmt','On Account Adj. Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,19,'SalMktRetAmt','Market Return Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,20,'SalReplaceAmt','Replacement Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,21,'SalOtherChargesAmt','Net - Other charges',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,22,'SalTotDedn','Total Deduction',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,23,'SalTotAddn','Total Addition',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,24,'SalRoundOffAmt','Round Off Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,25,'SalNetAmt','Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,26,'LcnName','Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,27,'SalesmanCode','Salesman Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,28,'SalesmanName','Salesman Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,29,'SalesRouteCode','Sales Route Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,30,'SalesRouteName','Sales Route Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,31,'RtrCode','Company Retailer Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,32,'RtrName','Retailer Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,33,'ProductCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,34,'ProductName','Product Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,35,'Batchcde','Batch Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,36,'SalInvQty','Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,37,'PrdSelRateBeforeTax','Selling Rate before Tax',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,38,'PrdSelRateAfterTax','Selling Rate After Tax',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,39,'PrdfreeQty','Free Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,40,'PrdGrossamt','Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,41,'PrdSplDiscAmt','Special Discount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,42,'PrdSchDiscAmt','Scheme Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,43,'PrdCashDiscAmt','Cash Discount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,44,'PrdDBDiscAmt','Distributor Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,45,'PrdTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,46,'PrdNetAmt','Net Amount',1,1)
GO

IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='SalesReturnExtractExcel')
BEGIN
CREATE TABLE SalesReturnExtractExcel
(
	[DistCode] [nvarchar](50)  NULL,
    [DistName] [nvarchar](200)  NULL,
    [TransName] [NVarchar] (200),
	[SRNRefNo] [nvarchar](50)  NULL,
    [SRNDate] [datetime] NULL,
	[SRNRefType] [nvarchar](100)  NULL,
	[SRNMode] [nvarchar](100)  NULL,
	[SRNType] [nvarchar](100)  NULL,
	[SRNGrossAmt] [numeric](38, 6) NULL,
	[SRNCashDiscAmt] [numeric](38, 6) NULL,
	[SRNDBDiscAmt] [numeric](38, 6) NULL,
	[SRNRoundOffAmt] [numeric](38, 6) NULL,
	[SRNNetAmt] [numeric](38, 6) NULL,
    [SalesmanCode] [Nvarchar](100),
	[SalesmanName] [nvarchar](100)  NULL,
    [RouteCode] [Nvarchar] (100),
	[SalesRouteName] [nvarchar](100)  NULL,
	[RtrCode] [nvarchar](100)  NULL,
	[RtrName] [nvarchar](100)  NULL,
	[PrdSalInvNo] [nvarchar](50)  NULL,
    [Salinvdte] [Datetime]  NULL,
	[PrdLcnCode] [nvarchar](100)  NULL,
    [PrdLcnName] [nvarchar](250)  NULL,
	[PrdCode] [nvarchar](250)  NULL,
	[PrdBatCde] [nvarchar](250)  NULL,
	[PrdSalQty] [int] NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdOfferQty] [int] NULL,
	[PrdSelRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdSplDiscAmt] [numeric](38, 6) NULL,
	[PrdSchDiscAmt] [numeric](38, 6) NULL,
	[PrdCashDiscAmt] [numeric](38, 6) NULL,
	[PrdDBDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL
)
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_SalesReturn')
DROP PROCEDURE  Proc_AN_SalesReturn
GO
Create   PROCEDURE Proc_AN_SalesReturn
(
 	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
as
BEGIN
	DECLARE @DistCode	As nVarchar(50)
    DECLARE @DistNm	As nVarchar(200)
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @DistNm = Distributorname FROM Distributor
    DELETE FROM SalesReturnExtractExcel	
	INSERT INTO SalesReturnExtractExcel
	(
		DistCode		,
        DistName ,
        TransName ,
		SRNRefNo		,
		SRNDate			,
        SRNRefType		,
		SRNMode			,
		SRNType			,	
		SRNGrossAmt		,
		SRNCashDiscAmt	,
		SRNDBDiscAmt	,
		SRNRoundOffAmt	,
		SRNNetAmt		,
        SalesManCode    ,
		SalesmanName	,
        RouteCode       ,
		SalesRouteName	,
		RtrCode			,
		RtrName			,
		PrdSalInvNo		,
        Salinvdte       ,
		PrdLcnCode		,
        PrdLcnName      ,
		PrdCode			,
		PrdBatCde		,
		PrdSalQty		,
		PrdUnSalQty		,
		PrdOfferQty		,
		PrdSelRate		,
		PrdGrossAmt		,
		PrdSplDiscAmt	,
		PrdSchDiscAmt	,
		PrdCashDiscAmt	,
		PrdDBDiscAmt	,
		PrdTaxAmt		,
		PrdNetAmt		
	)
	SELECT
		@DistCode ,@DistNm,'Sales Return',
		A.ReturnCode ,
		A.ReturnDate ,
        'With Reference',
		(CASE A.ReturnMode WHEN 0 THEN '' WHEN 1 THEN 'Full' ELSE 'Partial' END),
		(CASE A.InvoiceType WHEN 1 THEN 'Single Invoice' ELSE 'Multi Invoice' END),
		A.RtnGrossAmt,A.RtnCashDisAmt,A.RtnDBDisAmt,
		A.RtnRoundOffAmt,A.RtnNetAmt,SM.SMCode,
		SM.SMName,C.RMCode,C.RMName,R.CmpRtrCode,R.RtrName,
		ISNULL(G.SalInvno,B.SalCode) AS SalInvNo,
        ISNULL(G.SalInvDate,A.ReturnDate) AS SalInvDte,
		L.LcnCode,L.LcnName,		
		D.PrdCCode,F.CmpBatCode,
		(CASE ST.SystemStockType WHEN 1 THEN BaseQty ELSE 0 END)AS SalQty,
		(CASE ST.SystemStockType WHEN 2 THEN BaseQty ELSE 0 END)AS UnSalQty,
		(CASE ST.SystemStockType WHEN 3 THEN BaseQty ELSE 0 END)AS OfferQty,
		B.PrdEditSelRte ,
		B.PrdGrossAmt,B.PrdSplDisAmt,B.PrdSchDisAmt,B.PrdCDDisAmt,B.PrdDBDisAmt,
		B.PrdTaxAmt,B.PrdNetAmt
	FROM ReturnHeader A INNER JOIN ReturnProduct B ON A.ReturnId = B.ReturnId AND A.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		INNER JOIN RouteMaster C ON	A.RMID = C.RMID
		INNER JOIN Product D ON B.PrdId = D.PrdId
		INNER JOIN Company E ON D.CmpId = E.CmpId
		INNER JOIN ProductBatch F ON B.PrdBatId = F.PrdBatId
		INNER JOIN Retailer R ON R.RtrId=A.RtrId
		LEFT OUTER JOIN SalesInvoice G ON B.SalId = G.SalId AND A.SalId=G.SalId AND G.RtrId = R.RtrId
		INNER JOIN Salesman SM ON A.SMId=SM.SMId
		INNER JOIN StockType ST ON B.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId
UPDATE SalesReturnExtractExcel SET SRNRefType='WithoutReference' WHERE PrdSalinvno=''
END
GO

DELETE FROM RptAKSOExcelHeaders WHERE Rptid=505
INSERT INTO RptAKSOExcelHeaders VALUES (505,1,'DistCode','Distributor Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,2,'DistName','Distributor Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,3,'TransName','Transaction Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,4,'SRNRefNo','Sales return Ref. Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,5,'SRNDate','Sales Return Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,6,'SRNRefType','With/Without Ref',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,7,'SRNMode','Sales Return Mode',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,8,'SRNType','Sales Return Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,9,'SRNGrossAmt','Invoice Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,10,'SRNCashDiscAmt','Invoice Cash Discount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,11,'SRNDBDiscAmt','Invoice DB Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,12,'SRNRoundOffAmt','Round Off Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,13,'SRNNetAmt','Invoice Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,14,'SalesmanCode','Salesman Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,15,'SalesmanName','Salesman Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,16,'RouteCode','Route Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,17,'SalesRouteName','Route Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,18,'RtrCode','Company Retailer Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,19,'RtrName','Retailer Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,20,'PrdSalInvNo','Bill Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,21,'Salinvdte','Bill Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,22,'PrdLcnCode','Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,23,'PrdLcnName','Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,24,'PrdCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,25,'PrdBatCde','Batch Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,26,'PrdSalQty','Salable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,27,'PrdUnSalQty','Unsalable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,28,'PrdOfferQty','Offer Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,29,'PrdSelRate','Selling Rate',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,30,'PrdGrossAmt','Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,31,'PrdSplDiscAmt','Special Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,32,'PrdSchDiscAmt','Scheme Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,33,'PrdCashDiscAmt','Cash Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,34,'PrdDBDiscAmt','DB Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,35,'PrdTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,36,'PrdNetAmt','Net Amount',1,1)
GO

DELETE FROM ExtractAksoNobal
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (1,'Purchase Order','Proc_AN_PurchaseOrder','PurchaseOrderExtractExcel','Master','Excel Extract',501)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (2,'Purchase Confirmation','Proc_AN_PurchaseConfirmation','PurchaseConfirmationExtractExcel','Master','Excel Extract',502)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (3,'Purchase Return','Proc_AN_PurchaseReturn','PurchaseReturnExtractExcel','Master','Excel Extract',503)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (4,'Sales Details','Proc_AN_SalesDetail','SalesDetailExtractExcel','Master','Excel Extract',504)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (5,'Sales Return','Proc_AN_SalesReturn','SalesReturnExtractExcel','Master','Excel Extract',505)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (6,'Stock Management','Proc_AN_StockManagement','StockManagementExtractExcel','Master','Excel Extract',506)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (7,'Stock Journal','Proc_AN_StockJournal','StockJournalExtractExcel','Master','Excel Extract',507)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (8,'Debit Notes','Proc_AN_DebitNotes','DebitNotesExtractExcel','Master','Excel Extract',508)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (9,'Credit Notes','Proc_AN_CreditNotes','CreditNotesExtractExcel','Master','Excel Extract',509)
GO

--SRF-Nanda-212-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ComputeTax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ComputeTax]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     Procedure [dbo].[Proc_ComputeTax]      
(      
 @Pi_RowId  INT,      
 @Pi_CalledFrom  INT,        
 @Pi_UserId  INT      
      
)      
AS      
/*********************************      
* PROCEDURE : Proc_ComputeTax      
* PURPOSE : To Calculate the Line Level Tax      
* CREATED : Thrinath      
* CREATED DATE : 22/03/2007      
* MODIFIED
* DATE      AUTHOR     DESCRIPTION 
24/05/2009	MURUGAN	   OID CalCulation For Nestle	
------------------------------------------------      
* {date} {developer}  {brief modification description}            
       
@Pi_CalledFrom  2  For Sales      
@Pi_CalledFrom  3  For Sales Return       
@Pi_CalledFrom  5  For Purchase      
@Pi_CalledFrom  7  For Purchase Return      
@Pi_CalledFrom  20 For Replacement      
@Pi_CalledFrom  23  For Market Return       
@Pi_CalledFrom  24 For Return And Replacement      
@Pi_CalledFrom  25 For Sales Panel      
      
*********************************/       
SET NOCOUNT ON      
BEGIN      
	DECLARE @PrdBatTaxGrp   INT      
	DECLARE @RtrTaxGrp   INT      
	DECLARE @TaxSlab  INT      
	DECLARE @MRP   NUMERIC(28,10)      
	DECLARE @SellingRate  NUMERIC(28,10)      
	DECLARE @PurchaseRate  NUMERIC(28,10)      
	DECLARE @TaxableAmount  NUMERIC(28,10)      
	DECLARE @ParTaxableAmount NUMERIC(28,10)      
	DECLARE @TaxPer   NUMERIC(38,6)      
	DECLARE @TaxId   INT      
      
	DECLARE @TaxSetting TABLE       
	(      
		TaxSlab   INT,      
		ColNo   INT,      
		SlNo   INT,      
		BillSeqId  INT,      
		TaxSeqId  INT,      
		ColType   INT,       
		ColId   INT,      
		ColVal   NUMERIC(38,6)      
	)      
      
	--To Take the Batch TaxGroup Id      
	SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) INNER JOIN      
	BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
	AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      

	--To Take the Batch MRP      
	SELECT @MRP = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
	BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
	AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
	INNER JOIN ProductBatchDetails C (NOLOCK)      
	ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
	INNER JOIN BatchCreation D (NOLOCK)      
	ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
	AND D.MRP = 1       
      
	--To Take the Batch Selling Rate      
	IF @Pi_CalledFrom = 2 OR @Pi_CalledFrom = 25 OR @Pi_CalledFrom = 3 OR @Pi_CalledFrom = 23      
	BEGIN      
		SELECT @SellingRate = ColValue FROM BilledPrddtForTax WHERE TransId = @Pi_CalledFrom       
		AND UsrId = @Pi_UserId AND RowId = @Pi_RowId AND ColId = -2      
	END      
	ELSE      
	BEGIN      
		IF @Pi_CalledFrom = 20
		BEGIN 
			SELECT @SellingRate = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
			BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
			INNER JOIN ProductBatchDetails C (NOLOCK)      
			ON A.PrdBatId = C.PrdBatID AND C.PriceId IN (SELECT max(PBD.priceid) FROM productbatchdetails PBD WHERE pbd.prdbatid=b.PrdBatId)    
			INNER JOIN BatchCreation D (NOLOCK)      
			ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
			AND D.SelRte = 1      
		END      
		ELSE      
		BEGIN      
			SELECT @SellingRate = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
			BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
			INNER JOIN ProductBatchDetails C (NOLOCK)      
			ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
			INNER JOIN BatchCreation D (NOLOCK)      
			ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
			AND D.SelRte = 1      
		END      
	END 

	--To Take the Batch List Price 
	--Added by Murugan For OID Calculation
	IF (@Pi_CalledFrom = 5 OR @Pi_CalledFrom = 7 OR @Pi_CalledFrom = 37)
	BEGIN   
		IF  EXISTS(SELECT Status FROM Configuration WHERE ModuleId = 'PURCHASERECEIPT16' and Status=1)   
		BEGIN  
			SELECT  @PurchaseRate = Isnull(ColValue,0) FROM BilledPrdDtForTax B  
			WHERE  B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom 
			and COLID=3	   
		END  
		ELSE  
		BEGIN 
			SELECT @PurchaseRate =ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
			BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
			INNER JOIN ProductBatchDetails C (NOLOCK)      
			ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
			INNER JOIN BatchCreation D (NOLOCK)      
			ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
			AND D.ListPrice = 1     
		END  
	END
	ELSE
	BEGIN
		SELECT @PurchaseRate =ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN      
		BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID      
		AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
		INNER JOIN ProductBatchDetails C (NOLOCK)      
		ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId      
		INNER JOIN BatchCreation D (NOLOCK)      
		ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo      
		AND D.ListPrice = 1  
	END

 
      
	IF (@Pi_CalledFrom = 2 OR @Pi_CalledFrom = 3 OR @Pi_CalledFrom = 20 OR @Pi_CalledFrom = 23 OR       
	@Pi_CalledFrom = 24 OR @Pi_CalledFrom = 25)      
	BEGIN      
		--To Take the Retailer TaxGroup Id      
		SELECT @RtrTaxGrp = TaxGroupId FROM Retailer A (NOLOCK) INNER JOIN      
		BilledPrdHdForTax B (NOLOCK) On A.RtrId = B.RtrId      
		AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId       
		AND B.TransId = @Pi_CalledFrom      
	END      

	IF (@Pi_CalledFrom = 5 OR @Pi_CalledFrom = 7 OR @Pi_CalledFrom = 37)      
	BEGIN      
		--To Take the Supplier TaxGroup Id      
		SELECT @RtrTaxGrp = TaxGroupId FROM Supplier A (NOLOCK) INNER JOIN      
		BilledPrdHdForTax B (NOLOCK) On A.SpmId = B.RtrId      
		AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId      
		AND B.TransId = @Pi_CalledFrom      
	END      
       
	--Store the Tax Setting for the Corresponding Retailer and Batch      
	INSERT INTO @TaxSetting (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
	SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
	FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
	TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
	INNER JOIN BilledPrdHdForTax C (NOLOCK) ON C.BillSeqId = B.BillSeqId      
	WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp AND C.UsrId = @Pi_UserId      
	AND C.RowId = @Pi_RowId AND C.TransId = @Pi_CalledFrom      
	AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
	RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)    
    
	--Delete the OLD Details From the BilledPrdDtCalculatedTax For the Row and User      
	DELETE FROM BilledPrdDtCalculatedTax WHERE RowId = @Pi_RowId AND UsrId = @Pi_UserId       
	AND TransId = @Pi_CalledFrom      

	--Cursor For Taking Each Slab and Calculate Tax      
	DECLARE  CurTax CURSOR FOR      
	SELECT DISTINCT TaxSlab FROM @TaxSetting      
	OPEN CurTax        
	FETCH NEXT FROM CurTax INTO @TaxSlab      
      
	WHILE @@FETCH_STATUS = 0        
	BEGIN      

		SET @TaxableAmount = 0      
		--To Filter the Records Which Has Tax Percentage (>=0)      
		IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0 and ColVal >= 0)      
		BEGIN
			--To Get the Tax Percentage for the selected slab      
			SELECT @TaxPer = ColVal FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1      
			AND ColId = 0      

			--To Get the TaxId for the selected slab      
			SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1      
			AND ColId > 0      
	         
			--To Get the Adjustable amount from Other Columns      
			SELECT @TaxableAmount = ISNULL(SUM(ColValue),0) FROM       
			(SELECT CASE B.ColVal WHEN 1 THEN A.ColValue WHEN 2 THEN -1 * A.ColValue END       
			AS ColValue FROM BilledPrdDtForTax A INNER JOIN @TaxSetting B      
			ON A.ColId = B.ColId AND A.RowId =  @Pi_RowId AND A.UsrId = @Pi_UserId       
			AND A.TransId = @Pi_CalledFrom      
			WHERE TaxSlab = @TaxSlab AND B.ColType = 2 and B.ColId>3      
			And B.ColVal >0) as C      

			--To add MRP to Taxable Amount if MRP Is Selected for the Slab      
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2      
			AND ColId = 1 and ColVal > 0)       
			SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP      

			--To add Selling Rate to Taxable Amount if Selling Rate Is Selected for the Slab      
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2      
			AND ColId = 2 and ColVal > 0)       
			SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @SellingRate      
	      
			--To add Purchase Rate to Taxable Amount if Purchase Rate Is Selected for the Slab      
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2      
			AND ColId = 3 and ColVal > 0)       
			SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @PurchaseRate      

			--To Get the Parent Taxable Amount for the Tax Slab      
			SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM BilledPrdDtCalculatedTax A      
			INNER JOIN @TaxSetting B ON A.TaxId = B.ColVal AND A.RowId = @Pi_RowId      
			AND A.UsrId = @Pi_UserId AND B.ColType = 3 AND B.TaxSlab = @TaxSlab      
			AND A.TransId = @Pi_CalledFrom      

			Set @TaxableAmount = @TaxableAmount + @ParTaxableAmount      
	      
			--Insert the New Tax Amounts        
			INSERT INTO BilledPrdDtCalculatedTax (RowId,PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,      
			TaxableAmount,TaxAmount,Usrid,TransId)      
			SELECT @Pi_RowId,B.PrdId,B.PrdBatId,@TaxId,@TaxSlab,@TaxPer,      
			@TaxableAmount,cast(@TaxableAmount * (@TaxPer / 100 ) AS NUMERIC(28,10)),      
			@Pi_UserId,@Pi_CalledFrom FROM BilledPrdHdForTax B (NOLOCK) WHERE       
			B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
		END      
		FETCH NEXT FROM CurTax INTO @TaxSlab      
	END        
	CLOSE CurTax        
	DEALLOCATE CurTax           
END      

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-212-008

DELETE FROM HotSearchEditorHd WHERE FormId IN(529,530,756,757)
DELETE FROM HotSearchEditorDt WHERE FormId IN(529,530,756,757)

INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
VALUES('529','Purchase Receipt','Product with Company Code','select','SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,ERPPrdCode   FROM   (   SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode   FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),Product A WITH (NOLOCK)   LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode      WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam    Union    SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode    FROM  Product A WITH (NOLOCK)    LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   WHERE PrdStatus = 1 AND A.PrdType <>3 AND A.PrdId NOT IN    (     SELECT PrdId FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK)     WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId   ) AND A.CmpId = vFParam   ) a ORDER BY PrdSeqDtId')

INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
VALUES('530','Purchase Receipt','Product with Distributor Code','select','SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,ERPPrdCode   FROM   (   SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode    FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),Product A WITH (NOLOCK)     LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam    Union    SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode    FROM  Product A WITH (NOLOCK)    LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   WHERE PrdStatus = 1 AND A.PrdType <>3 AND A.PrdId NOT IN    (     SELECT PrdId FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK)     WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId   ) AND A.CmpId = vFParam   ) a ORDER BY PrdSeqDtId')

INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
VALUES('757','Purchase Receipt','Display MRP Product with Distributor Code','select','SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,MRP,ERPPrdCode    FROM   (    SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode         FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),   ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)       LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3    AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam       and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId   AND A.PrdId = PB.PrdId       Union       SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode          FROM ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)       LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   WHERE PrdStatus = 1 AND A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND     PBD.BatchSeqId=BC.BatchSeqId AND A.PrdType <>3 AND A.PrdId NOT IN    (     SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK)     WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId   ) AND A.CmpId = vFParam   ) a  ORDER BY PrdSeqDtId')

INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
VALUES('756','Purchase Receipt','Display MRP Product with Company Code','select','SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,MRP,ERPPrdCode    FROM   (   SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode      FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),   ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)    LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId    AND A.CmpId = vFParam  and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId    AND A.PrdId = PB.PrdId       Union       SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode, A.PrdName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode       FROM ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)       LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   WHERE PrdStatus = 1 AND A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND       PBD.BatchSeqId=BC.BatchSeqId AND A.PrdType <>3 AND A.PrdId NOT IN    (     SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=vSParam       AND B.PrdSeqId=C.PrdSeqId   )  AND A.CmpId = vFParam   ) a    ORDER BY PrdSeqDtId')


INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','529','Product with Company Code','Sequence No','PrdSeqDtId','1000','0','HotSch-5-2000-1','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','756','Display MRP Product with Company Code','Sequence No','PrdSeqDtId','1000','0','HotSch-5-2000-95','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','757','Display MRP Product with Distributor Code','Sequence No','PrdSeqDtId','1000','0','HotSch-5-2000-99','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','530','Product with Distributor Code','Product Name','PrdName','1500','0','HotSch-5-2000-25','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('4','530','Product with Distributor Code','Invoice Product Code','ERPPrdCode','1000','0','HotSch-5-2000-103','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','757','Display MRP Product with Distributor Code','Product Code','PrdDCode','1000','0','HotSch-5-2000-100','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','530','Product with Distributor Code','Sequence No','PrdSeqDtId','1000','0','HotSch-5-2000-23','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','756','Display MRP Product with Company Code','Product Code','PrdCcode','1000','0','HotSch-5-2000-96','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','756','Display MRP Product with Company Code','Product Name','PrdName','1000','0','HotSch-5-2000-97','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('4','756','Display MRP Product with Company Code','MRP','MRP','500','0','HotSch-5-2000-98','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('5','756','Display MRP Product with Company Code','Invoice Product Code','ERPPrdCode','1000','0','HotSch-5-2000-103','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','757','Display MRP Product with Distributor Code','Product Name','PrdName','1000','0','HotSch-5-2000-101','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('4','757','Display MRP Product with Distributor Code','MRP','MRP','500','0','HotSch-5-2000-102','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('5','757','Display MRP Product with Distributor Code','Invoice Product Code','ERPPrdCode','1000','0','HotSch-5-2000-103','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','529','Product with Company Code','Product Code','PrdCcode','1000','0','HotSch-5-2000-17','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','529','Product with Company Code','Product Name','PrdName','1500','0','HotSch-5-2000-18','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('4','529','Product with Company Code','Invoice Product Code','ERPPrdCode','1000','0','HotSch-5-2000-103','5')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','530','Product with Distributor Code','Product Code','PrdDCode','1000','0','HotSch-5-2000-24','5')

--SRF-Nanda-212-009

UPDATE Configuration SET Condition=A.GEoLevelName,ConfigValue=A.GeoLevelId
FROM (SELECT ISNULL(GeoLevelName,'') AS GeoLevelName,ISNULL(GeoLevelId,0) AS GeoLevelId FROM GeographyLevel WHERE GeoLevelId IN (SELECT MAX(GeoLevelID) FROM GeographyLevel)) A
WHERE ModuleId LIKE 'ROUTE1'

--SRF-Nanda-212-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ReasonMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ReasonMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_ReasonMaster
EXEC Proc_Cn2Cs_ReasonMaster 0
SELECT * FROM Counters WHERE TabName='ReasonMaster'
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ReasonMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ReasonMaster
* PURPOSE		: To Download the Reason details from Console to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @Exists				INT
	DECLARE @ReasonId			INT
	DECLARE @DistCode			NVARCHAR(100)
	DECLARE @ReasonCode			NVARCHAR(100)
	DECLARE @Description		NVARCHAR(100)
	DECLARE @ApplicableTo		NVARCHAR(100)
	SET @ErrStatus=1
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_ReasonMaster'
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ReasonToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ReasonToAvoid	
	END
	CREATE TABLE ReasonToAvoid
	(		
		RSMCode		NVARCHAR(200)
	)
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')='')
	BEGIN
		INSERT INTO ReasonToAvoid(RSMCode)
		SELECT ReasonCode FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_ReasonMaster','Reason Code','Reason code should not be empty'
		FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')=''
	END	
	DECLARE Cur_Reason CURSOR	
	FOR SELECT DISTINCT ReasonCode,Description
	FROM Cn2Cs_Prk_ReasonMaster WHERE DownloadFlag='D' AND ISNULL(ReasonCode,'')<>''
	OPEN Cur_Reason
	FETCH NEXT FROM Cur_Reason INTO @ReasonCode,@Description
	WHILE @@FETCH_STATUS=0
	BEGIN		
		IF NOT EXISTS(SELECT * FROM ReasonMaster WHERE ReasonCode=@ReasonCode)
		BEGIN
			SET @ReasonId=0
			SET @ReasonId = dbo.Fn_GetPrimaryKeyInteger('ReasonMaster','ReasonId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
			IF @ReasonId>0
			BEGIN
				INSERT INTO ReasonMaster(ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
				DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,StkTransferScreen,
				BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@ReasonId,@ReasonCode,@Description,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,GETDATE(),1,GETDATE())

				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ReasonMaster' AND FldName='ReasonId'
			END
			ELSE
			BEGIN
				SET @ErrDesc='Check the System Date'
				INSERT INTO Errorlog VALUES (1,@TabName,'Description',@ErrDesc)
		  		SET @Po_ErrNo=1
			END
		END
		ELSE
		BEGIN
			SELECT @ReasonId=ReasonId FROM ReasonMaster WHERE ReasonCode=@ReasonCode
			UPDATE ReasonMaster SET PurchaseReceipt=0,SalesInvoice=0,VanLoad=0,CrNoteSupplier=0,CrNoteRetailer=0,
			DeliveryProcess=0,SalvageRegister=0,PurchaseReturn=0,SalesReturn=0,VanUnload=0,DbNoteSupplier=0,DbNoteRetailer=0,
			StkAdjustment=0,StkTransferScreen=0,BatchTransfer=0,ReceiptVoucher=0,ReturnToCompany=0,LocationTrans=0,
			Billing=0,ChequeBouncing=0,ChequeDisbursal=0 WHERE ReasonId=@ReasonId
		END
		
		IF @Po_ErrNo=0
		BEGIN
			DECLARE Cur_ReasonApplicable CURSOR	
			FOR SELECT DISTINCT ReasonCode,Description,ApplicableTo
			FROM Cn2Cs_Prk_ReasonMaster WHERE DownloadFlag='D' AND ReasonCode=@ReasonCode
			OPEN Cur_ReasonApplicable
			FETCH NEXT FROM Cur_ReasonApplicable INTO @ReasonCode,@Description,@ApplicableTo
			WHILE @@FETCH_STATUS=0
			BEGIN		
				SET @sSql=''
				IF @ApplicableTo='All'
				BEGIN
					SET @sSql='UPDATE ReasonMaster SET PurchaseReceipt=1,SalesInvoice=1,VanLoad=1,CrNoteSupplier=1,CrNoteRetailer=1,
					DeliveryProcess=1,SalvageRegister=1,PurchaseReturn=1,SalesReturn=1,VanUnload=1,DbNoteSupplier=1,DbNoteRetailer=1,
					StkAdjustment=1,StkTransferScreen=1,BatchTransfer=1,ReceiptVoucher=1,ReturnToCompany=1,LocationTrans=1,Billing=1,
					ChequeBouncing=1,ChequeDisbursal=1 WHERE ReasonId='+CAST(@ReasonId AS NVARCHAR(10))
				END
				ELSE
				BEGIN
					IF EXISTS (SELECT Id,Name FROM SysColumns WHERE Name = @ApplicableTo AND Id IN (SELECT Id FROM
					SysObjects WHERE Name ='ReasonMaster'))
					BEGIN
						SET @sSql='UPDATE ReasonMaster SET '+@ApplicableTo+'=1 WHERE ReasonId='+CAST(@ReasonId AS NVARCHAR(10))
					END					
				END
				IF LTRIM(RTRIM(@sSql))<>''
				BEGIN
					EXEC (@sSql)
				END
				FETCH NEXT FROM Cur_ReasonApplicable INTO @ReasonCode,@Description,@ApplicableTo
			END
			CLOSE Cur_ReasonApplicable
			DEALLOCATE Cur_ReasonApplicable
		END		
		FETCH NEXT FROM Cur_Reason INTO @ReasonCode,@Description
	END
	CLOSE Cur_Reason
	DEALLOCATE Cur_Reason

	UPDATE Cn2Cs_Prk_ReasonMaster SET DownloadFlag='Y' WHERE DownloadFlag='D' AND ISNULL(ReasonCode,'')<>''
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-212-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptStockandSalesVolumeHierarchy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptStockandSalesVolumeHierarchy]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptStockandSalesVolumeHierarchy 219,2,0,'HK4',0,0,1

CREATE  PROCEDURE [dbo].[Proc_RptStockandSalesVolumeHierarchy]  
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
	DECLARE @LevelId AS INT  
	DECLARE @CmpPrdCtgId AS INT  
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

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  

	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  

	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))  

	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  

	SET @IncOffStk =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,202,@Pi_UsrId))
	SET @StockValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))  
	SET @SupZeroStock =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))  

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  

	SELECT @LevelId=SUBSTRING(LevelName,6,LEN(LevelName)) FROM ProductCategoryLevel WHERE CmpPrdCtgId=@CmpPrdCtgId

	IF @IncOffStk=1  
	BEGIN  
		Exec Proc_GetStockNSalesDetailsWithOffer @FromDate,@ToDate,@Pi_UsrId  
	END  
	ELSE  
	BEGIN  
		Exec Proc_GetStockNSalesDetails @FromDate,@ToDate,@Pi_UsrId  
	END  

	CREATE TABLE #RptStockandSalesVolume  
	(  
		PrdCtgValMainId		INT,
		PrdCtgValLinkCode	NVARCHAR(200),  
		PrdId				INT,  
		PrdDCode			NVARCHAR(200),  
		PrdName				NVARCHAR(200),  
		PrdBatId			INT,  
		PrdBatCode			NVARCHAR(50),  
		CmpId				INT,  
		CmpName				NVARCHAR(50),  
		LcnId				INT,  
		LcnName				NVARCHAR(50),   
		OpeningStock		NUMERIC(38,0),    
		Purchase			NUMERIC (38,0),  
		Sales				NUMERIC (38,0),  
		AdjustmentIn		NUMERIC (38,0),  
		AdjustmentOut		NUMERIC (38,0),  
		PurchaseReturn		NUMERIC (38,0),  
		SalesReturn			NUMERIC (38,0),    
		ClosingStock		NUMERIC (38,0),  		
		ClosingStkValue		NUMERIC (38,6),
		PrdWeight			NUMERIC (38,6)
	)  

	CREATE TABLE #RptStockandSalesVolumeHierarchy  
	(  
		PrdCtgValMainId			INT,  
		PrdCtgValCode			NVARCHAR(200),  
		PrdCtgValName			NVARCHAR(200),  
		CmpId					INT,  
		CmpName					NVARCHAR(50),  
		LcnId					INT,  
		LcnName					NVARCHAR(50),   
		OpeningStock			NUMERIC(38,0),    
		Purchase				NUMERIC (38,0),  
		Sales					NUMERIC (38,0),  
		AdjustmentIn			NUMERIC (38,0),  
		AdjustmentOut			NUMERIC (38,0),  
		PurchaseReturn			NUMERIC (38,0),  
		SalesReturn				NUMERIC (38,0),    
		ClosingStock			NUMERIC (38,0),  
		ClosingStkValue			NUMERIC (38,6),
		PrdWeight				NUMERIC (38,6),
		PrdCtgValLinkCode		NVARCHAR(100)  
	)  

	SELECT * INTO #RptStockandSalesVolume1 FROM #RptStockandSalesVolume  

	SET @TblName = 'RptStockandSalesVolume'  
	SET @TblStruct = 'PrdId    INT,  
					  PrdDCode			NVARCHAR(200),  
					  PrdName			NVARCHAR(200),  
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
					  ClosingStkValue	NUMERIC (38,6),
					  PrdWeight	NUMERIC (38,6)'  
	SET @TblFields = 'PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
   					  LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,  
					  PurchaseReturn,SalesReturn,ClosingStock,ClosingStkValue,PrdWeight'  
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
		INSERT INTO #RptStockandSalesVolume1 (PrdCtgValMainId,PrdCtgValLinkCode,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
		LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,
		ClosingStock,ClosingStkValue,PrdWeight)
		SELECT DISTINCT PCV.PrdCtgValMainId,PCV.PrdCtgValLinkCode,T.PrdId,T.PrdDcode,T.PrdName,PrdBatId,PrdBatCode,T.CmpId,CmpName,LcnId,LcnName,  
		Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,
		dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId),0			
		FROM TempRptStockNSales T INNER JOIN COmpany C ON C.CmpId=T.CmpId 
		INNER JOIN Product P ON P.PrdID=T.PrdId
		INNER JOIN ProductCategoryValue PCV ON PCV.PrdCtgValMainID=P.PrdCtgValMainID
		WHERE (T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR  
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
		AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
			LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) 									
		AND UserId=@Pi_UsrId  

		--->Added By Nanda on 25/02/2011
		UPDATE Rpt SET Rpt.PrdWeight=P.PrdWgt*(CASE P.PrdUnitId WHEN 2 THEN Rpt.ClosingStock/1000000 ELSE Rpt.ClosingStock/1000 END)
		FROM Product P,#RptStockandSalesVolume1 Rpt WHERE P.PrdId=Rpt.PrdId AND P.PrdUnitId IN (2,3)
		--->Till Here
		
		IF @SupZeroStock=0
		BEGIN
			INSERT INTO #RptStockandSalesVolumeHierarchy(PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,  
			LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
			PurchaseReturn,SalesReturn,ClosingStock,ClosingStkValue,PrdWeight,PrdCtgValLinkCode)  
			SELECT PCV.PrdCtgValMainId,PCV.PrdCtgValCode,PCV.PrdCtgValName,P.CmpId,CmpName,LcnId,LcnName,  
			SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
			SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
			SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
			SUM(ClosingStock) AS ClosingStock,SUM(ClosingStkValue),SUM(PrdWeight),LEFT(PCV.PrdCtgValLinkCode,@LevelId*5)
			FROM #RptStockandSalesVolume1 Rpt,Product P,ProductCategoryValue PCV  
			WHERE Rpt.PrdId=P.PrdId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId 			
			GROUP BY PCV.PrdCtgValMainId,PCV.PrdCtgValCode,PCV.PrdCtgValName,P.CmpId,CmpName,LcnId,LcnName,PCV.PrdCtgValLinkCode  
		END
		ELSE
		BEGIN
			INSERT INTO #RptStockandSalesVolumeHierarchy(PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,  
			LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
			PurchaseReturn,SalesReturn,ClosingStock,ClosingStkValue,PrdWeight,PrdCtgValLinkCode)  
			SELECT PCV.PrdCtgValMainId,PCV.PrdCtgValCode,PCV.PrdCtgValName,P.CmpId,CmpName,LcnId,LcnName,  
			SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
			SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
			SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
			SUM(ClosingStock) AS ClosingStock,SUM(ClosingStkValue),SUM(PrdWeight),LEFT(PCV.PrdCtgValLinkCode,@LevelId*5)
			FROM #RptStockandSalesVolume1 Rpt,Product P,ProductCategoryValue PCV  
			WHERE Rpt.PrdId=P.PrdId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId AND Rpt.ClosingStock>0			
			GROUP BY PCV.PrdCtgValMainId,PCV.PrdCtgValCode,PCV.PrdCtgValName,P.CmpId,CmpName,LcnId,LcnName,PCV.PrdCtgValLinkCode  
		END

		UPDATE Rpt SET Rpt.PrdCtgValMainId=PCV.PrdCtgValMainId,Rpt.PrdCtgValCode=PCV.PrdCtgValCode,Rpt.PrdCtgValName=PCV.PrdCtgValName
		FROM #RptStockandSalesVolumeHierarchy Rpt,ProductCategoryValue PCV
		WHERE PCV.PrdCtgValLinkCode=Rpt.PrdCtgValLinkCode
		
		SELECT PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,LcnName,PrdCtgValLinkCode,
		SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase,SUM(Sales) AS Sales,SUM(AdjustmentIn) AS AdjustmentIn,
		SUM(AdjustmentOut) AS AdjustmentOut,SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
		SUM(ClosingStock) AS ClosingStock,SUM(ClosingStkValue) AS ClosingStkValue,SUM(PrdWeight) AS PrdWeight
		INTO #RptStockandSalesVolumeHierarchy1
		FROM #RptStockandSalesVolumeHierarchy
		GROUP BY PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,LcnName,PrdCtgValLinkCode

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
	
	SELECT  * FROM #RptStockandSalesVolumeHierarchy1

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		TRUNCATE TABLE RptStockandSalesVolumeHierarchy_Excel
		INSERT INTO RptStockandSalesVolumeHierarchy_Excel
		SELECT * FROM #RptStockandSalesVolumeHierarchy1
	END

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolumeHierarchy1   

	RETURN  
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 364)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(364,'D','2011-03-18',getdate(),1,'Core Stocky Service Pack 364')
