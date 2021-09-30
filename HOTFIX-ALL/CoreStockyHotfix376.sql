--[Stocky HotFix Version]=376
Delete from Versioncontrol where Hotfixid='376'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('376','2.0.0.5','D','2011-05-05','2011-05-05','2011-05-05',convert(varchar(11),getdate()),'Parle;Major:-J&J Changes;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 376' ,'376'
GO

--SRF-Nanda-236-001-From Kalai

DELETE FROM RptDetails WHERE RptId=53 AND Slno=5
INSERT INTO RptDetails
SELECT 53,5,'RptFilter',-1,'','FilterId,FilterId,FilterDesc','Display Bill No*...','',1,'',
272,1,1,'Press F4/Double Click to Select Display Bill No.',0
GO
DELETE FROM RptFilter WHERE RptId=53 AND SelcId=272
INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
SELECT 53,272,0,'Yes'
UNION
SELECT 53,272,1,'No'
GO
DELETE FROM RptSelectionHd WHERE SelcId=272
INSERT INTO RptSelectionHd(SelcId,SelcName,TblName,Condition)
SELECT 272,'Sel_DispBillNo','RptFilter',1
GO
DELETE FROM RptFormula WHERE RptId=53 AND Slno=20 AND Formula='Disp_BillNo'
INSERT INTO RptFormula
SELECT 53,20,'Disp_BillNo','',1,272
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[View_BankSlip]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[View_BankSlip]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW [dbo].[View_BankSlip] 
AS
SELECT RI.BnkId as RtrBankId,B.BnkName as RtrBnkName,RI.BnkBrID As RtrBnkBrId,
		D.BnkBrName as RtrBnkBrname,RI.DisBnkId , RI.DisBnkBrId as DisBranchId,
		R.RtrName  As DistributorBnkName,SAI.SalInvNo as DistributorBnkBrName,
		G.AccId,G.AcNo as AccountNo,RI.InvinsNo,RI.InvInsDate,
		RI.InvDepDate ,RI.InvInsSta,RI.SalInvAmt,RI.Penalty 
		From ReceiptInvoice RI
	LEFT OUTER JOIN Bank B ON B.BnkId=RI.BnkId 
	LEFT OUTER JOIN BankBranch D ON D.BnkBrId=RI.BnkBrId 
    INNER JOIN SalesInvoice SAI ON SAI.SalId=RI.SalId
    INNER JOIN Retailer R ON R.RtrId = SAI.RtrId
	INNER JOIN Bank E ON E.BnkId=RI.DisBnkId
	INNER JOIN BnkAcNo G ON G.BNKBRID=RI.DisBnkBrId
	INNER JOIN BankBranch F ON F.BnkBrId=RI.DisBnkBrId AND F.DistBank=1
	WHERE  RI.InvRcpMode=3 AND RI.InvInsSta IN(0,1) AND RI.CancelStatus=1
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBankSlipReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBankSlipReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
---EXEC Proc_RptBankSlipReport 53,2,0,'CoreStockyTempReport',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptBankSlipReport]
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
* VIEW	: Proc_RptBankSlipReport
* PURPOSE	: To get the Cheque Collection For Particular Date Period
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 6/12/2007
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
	---Filter Variables
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @BnkId 		AS	INT
	DECLARE @BnkBrId	AS	INT
	DECLARE @DispBillNo    AS  INT

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @BnkId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,70,@Pi_UsrId))
	SET @BnkBrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,71,@Pi_UsrId))
	SET @DispBillNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,272,@Pi_UsrId))

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	CREATE TABLE #RptBankSlipReport
	(
				RtrBankId	BIGINT,
				RtrBnkName	NVARCHAR(50),
				RtrBnkBrID	BIGINT,
				RtrBnkBrName  NVARCHAR(50),
				DisBnkId INT,
				DisBranchId INT,
				DistributorBnkName NVARCHAR(50),
				DistributorBnkBrName NVARCHAR(50),
				InvInsNo NVARCHAR(25),
				InvInsDate DATETIME,
				InvInsAmt NUMERIC(38,6),
				InvDepDate DATETIME 
		
	)
	SET @TblName = 'RptBankSlipReport'
	SET @TblStruct =' RtrBankId	BIGINT,
				RtrBnkName	NVARCHAR(50),
				RtrBnkBrID	BIGINT,
				RtrBnkBrName  NVARCHAR(50),
				DisBnkId INT,
				DisBranchId INT,
				DistributorBnkName NVARCHAR(50),
				DistributorBnkBrName NVARCHAR(50),
				InvInsNo NVARCHAR(25),
				InvInsDate DATETIME,
				InvInsAmt NUMERIC(38,6),
				InvDepDate DATETIME'
	SET @TblFields = 'RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvInsAmt,InvDepDate'
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
		
			INSERT INTO #RptBankSlipReport (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvInsAmt,InvDepDate)
				SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,
				CAST(InvInsNo AS NVARCHAR(25)),InvInsDate,SalInvAmt,InvDepDate
				FROM View_BankSlip			
				WHERE 	(DisBnkId = (CASE @BnkId WHEN 0 THEN DisBnkId ELSE 0 END) OR
						DisBnkId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,70,@Pi_UsrId)))
					AND
					(DisBranchId = (CASE @BnkBrId WHEN 0 THEN DisBranchId ELSE 0 END) OR
						DisBranchId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,71,@Pi_UsrId)))
					AND InvInsDate BETWEEN @FromDate AND @ToDate
		IF @DispBillNo=1
			BEGIN		
				UPDATE #RptBankSlipReport SET DistributorBnkBrName=''
			END 
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptBankSlipReport' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+ 'WHERE (DisBnkId = (CASE ' + CAST(@BnkId AS nVarchar(10)) + ' WHEN 0 THEN DisBnkId ELSE 0 END) OR '
				+ 'DisBnkId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',70,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (DisBranchId = (CASE ' + CAST(@BnkBrId AS nVarchar(10)) + ' WHEN 0 THEN DisBranchId ELSE 0 END) OR '
				+ 'DisBranchId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',71,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND InvInsDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptBankSlipReport'
		
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
			SET @SSQL = 'INSERT INTO #RptBankSlipReport ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptBankSlipReport
	-- Till Here
	SELECT * FROM #RptBankSlipReport
		DECLARE @RecCount AS BIGINT 
		SET @RecCount =(SELECT count(*) FROM #RptBankSlipReport)
    	IF @RecCount > 0
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptBankSlip_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					DROP TABLE [RptBankSlip_Excel]
					CREATE TABLE RptBankSlip_Excel (RtrBankId BIGINT,DistributorBnkName NVARCHAR(50),RtrBnkName	NVARCHAR(50),RtrBnkBrID	BIGINT,RtrBnkBrName  NVARCHAR(50),DisBnkId INT,DisBranchId INT,
						DistributorBnkBrName NVARCHAR(50),InvInsNo NVARCHAR(25),InvInsDate varchar(10),InvDepDate varchar(10),InvInsAmt NUMERIC(38,6))
                IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TbpRptBankSlipReport')
					BEGIN 
						DROP TABLE TbpRptBankSlipReport
						SELECT * INTO TbpRptBankSlipReport FROM RptBankSlip_Excel WHERE 1=2
					END 
				 ELSE
					BEGIN 
						SELECT * INTO TbpRptBankSlipReport FROM RptBankSlip_Excel WHERE 1=2
					END 
				INSERT INTO TbpRptBankSlipReport (RtrBankId ,DistributorBnkName,InvInsAmt)
					SELECT 999999,'Total',sum(InvInsAmt) 
				FROM 
						#RptBankSlipReport
				INSERT INTO RptBankSlip_Excel (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt)
                  SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,(CONVERT(NVARCHAR(11),InvInsDate ,103)),(CONVERT(NVARCHAR(11),InvDepDate ,103)),InvInsAmt
					FROM #RptBankSlipReport
				
				INSERT INTO RptBankSlip_Excel (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt)
				SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt  
					FROM TbpRptBankSlipReport 
			END
		
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
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

	IF @Pi_ScreenId = 28
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

--SRF-Nanda-236-002-From Vasanth

DELETE FROM RptGroup WHERE RptId=230
DELETE FROM RptHeader WHERE RptId=230 
DELETE FROM RptDetails WHERE RptId=230
DELETE FROM RptFilter WHERE RptId=230
DELETE FROM RptFormula WHERE RptId=230
DELETE FROM RptExcelHeaders WHERE RptId=230
GO
INSERT INTO RptGroup VALUES('J and J Reports',230,'SalesUOMBasedCurrentStockReport','Sales UOM Based Current Stock Report')
GO
INSERT INTO RptHeader VALUES('SalesUOMBasedCurrentStockReport','Sales UOM Based Current Stock Report',230,'Sales UOM Based Current Stock Report','Proc_RptCurrentStockSalesInUOMBased','RptCurrentStockSalesUOMBased','RptCurrentStockSalesUOMBased.rpt','')
GO
INSERT INTO RptDetails VALUES(230,1,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,'','Press F4/Double Click to select Company',0)
INSERT INTO RptDetails VALUES(230,2,'Location',-1,'','LcnId,LcnCode,LcnName','Location...','',1,'',22,'','','Press F4/Double Click to select Location',0)
INSERT INTO RptDetails VALUES(230,3,'ProductCategoryLevel',1,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,'','Press F4/Double Click to select Product Hierarchy Level',0)
INSERT INTO RptDetails VALUES(230,4,'ProductCategoryValue',3,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,'','','Press F4/Double Click to select Product Hierarchy Level Value',1)
INSERT INTO RptDetails VALUES(230,5,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Stock Value as per*...','',1,'',23,1,1,'Press F4/Double Click to select Stock Value',0)
INSERT INTO RptDetails VALUES(230,6,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display Batch*...','',1,'',28,1,1,'Press F4/Double Click to select Display Batch',0)
INSERT INTO RptDetails VALUES(230,7,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Product Status...','',1,'',24,1,'','Press F4/Double Click to select Product Status',0)
INSERT INTO RptDetails VALUES(230,8,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Batch Status...','',1,'',25,1,'','Press F4/Double Click to select Batch Status',0)
INSERT INTO RptDetails VALUES(230,9,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Suppress Zero Stock*...','',1,'',44,1,1,'Press F4/Double Click to Select the Supress Zero Stock',0)
GO
INSERT INTO RptFilter VALUES(230,23,1,'Selling Rate')   
INSERT INTO RptFilter VALUES(230,23,2,'List Price')
INSERT INTO RptFilter VALUES(230,23,3,'MRP')
INSERT INTO RptFilter VALUES(230,28,1,'Yes')
INSERT INTO RptFilter VALUES(230,28,2,'No')
INSERT INTO RptFilter VALUES(230,24,0,'ALL')
INSERT INTO RptFilter VALUES(230,24,1,'Active')
INSERT INTO RptFilter VALUES(230,24,2,'InActive')
INSERT INTO RptFilter VALUES(230,25,0,'ALL')
INSERT INTO RptFilter VALUES(230,25,2,'Active')
INSERT INTO RptFilter VALUES(230,25,1,'InActive')
INSERT INTO RptFilter VALUES(230,44,1,'Yes')
INSERT INTO RptFilter VALUES(230,44,2,'No')
GO
INSERT INTO RptFormula VALUES (230,1,'Product Code','Product Code',1,0)
INSERT INTO RptFormula VALUES (230,2,'Product Name','Product Name',1,0)
INSERT INTO RptFormula VALUES (230,3,'MRP','MRP',1,0)
INSERT INTO RptFormula VALUES (230,4,'Saleable stock in SUOM','Saleable stock in SUOM',1,0)
INSERT INTO RptFormula VALUES (230,5,'Unsaleable Stock in SUOM','Unsaleable Stock in SUOM',1,0)
INSERT INTO RptFormula VALUES (230,6,'Offer Stock in SUOM','Offer Stock in SUOM',1,0)
INSERT INTO RptFormula VALUES (230,7,'Total Stock in SUOM','Total Stock in SUOM',1,0)
INSERT INTO RptFormula VALUES (230,8,'Sal Stock Value','Stock value (Saleable)',1,0)
INSERT INTO RptFormula VALUES (230,9,'Unsal Stock Value','Stock Value (Unsaleable)',1,0)
INSERT INTO RptFormula VALUES (230,10,'Offer Stock Value','Stock Value (Offer)',1,0)
INSERT INTO RptFormula VALUES (230,11,'Tot Stock Value','Stock Value (Total)',1,0)
INSERT INTO RptFormula VALUES (230,12,'Fil_Company','Company',1,0)
INSERT INTO RptFormula VALUES (230,13,'Fil_Location','Location',1,0)
INSERT INTO RptFormula VALUES (230,14,'Fil_PrdCtgLvl','Product Category Level',1,0)
INSERT INTO RptFormula VALUES (230,15,'Fil_PrdCtgValue','Product Category Value',1,0)
INSERT INTO RptFormula VALUES (230,16,'Fil_Prd','Product',1,0)
INSERT INTO RptFormula VALUES (230,17,'Fil_StockValue','Stock Value as per',1,0)
INSERT INTO RptFormula VALUES (230,18,'Fil_DispBatch','Display Batch',1,0)
INSERT INTO RptFormula VALUES (230,19,'Fil_PrdStatus','Product Status',1,0)
INSERT INTO RptFormula VALUES (230,20,'Fil_BatStatus','Batch Status',1,0)
INSERT INTO RptFormula VALUES (230,21,'FilDisp_Company','ALL',1,4)
INSERT INTO RptFormula VALUES (230,22,'FilDisp_Location','ALL',1,22)
INSERT INTO RptFormula VALUES (230,23,'FilDisp_PrdCtgLvl','ALL',1,16)
INSERT INTO RptFormula VALUES (230,24,'FilDisp_PrdCtgValue','ALL',1,21)
INSERT INTO RptFormula VALUES (230,25,'FilDisp_Prd','ALL',1,5)
INSERT INTO RptFormula VALUES (230,26,'FilDisp_DispBatch','YES',1,28)
INSERT INTO RptFormula VALUES (230,27,'FilDisp_PrdStatus','ALL',1,24)
INSERT INTO RptFormula VALUES (230,28,'FilDisp_BatStatus','ALL',1,25)
INSERT INTO RptFormula VALUES (230,29,'Cap Page','Page',1,0)
INSERT INTO RptFormula VALUES (230,30,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula VALUES (230,31,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula VALUES (230,32,'Hd_Total','Grand Total',1,0)
INSERT INTO RptFormula VALUES (230,33,'Disp_SupZeroStock','Suppress Zero Stock',1,	0)
INSERT INTO RptFormula VALUES (230,34,'Fill_SupZeroStock','Suppress Zero Stock',1,	44)
INSERT INTO RptFormula VALUES (230,35,'Product BatchCode','Product BatchCode',1,0)
INSERT INTO RptFormula VALUES (230,36,'FilDisp_StockValue','Selling Rate with Tax',1,23)
GO
INSERT INTO RptExcelHeaders VALUES (230,1,'PRDID','PRDID',0,1)                       
INSERT INTO RptExcelHeaders VALUES (230,2,'PRDCCODE','PRDCCODE',1,1)                    
INSERT INTO RptExcelHeaders VALUES (230,3,'PRDNAME','PRDNAME',1,1)                    
INSERT INTO RptExcelHeaders VALUES (230,4,'PRDBATCODE','PRDBATCODE',1,1)                   
INSERT INTO RptExcelHeaders VALUES (230,5,'LCNID','LCNID',0,1)                    
INSERT INTO RptExcelHeaders VALUES (230,6,'SALEABLE STOCK IN SUOM','SALEABLE STOCK IN SUOM',1,1)       
INSERT INTO RptExcelHeaders VALUES (230,7,'Unsaleable Stock in SUOM','Unsaleable Stock in SUOM',1,1)   
INSERT INTO RptExcelHeaders VALUES (230,8,'Offer Stock in SUOM','Offer Stock in SUOM',1,1)        
INSERT INTO RptExcelHeaders VALUES (230,9,'TOTAL STOCK IN SUOM','TOTAL STOCK IN SUOM',1,1)       
INSERT INTO RptExcelHeaders VALUES (230,10,'SALEABLE STOCK VALUE','SALEABLE STOCK VALUE',1,1)       
INSERT INTO RptExcelHeaders VALUES (230,11,'UNSALEABLE STOCK VALUE','UNSALEABLE STOCK VALUE',1,1)      
INSERT INTO RptExcelHeaders VALUES (230,12,'OFFER STOCK VALUE','OFFER STOCK VALUE',1,1)          
INSERT INTO RptExcelHeaders VALUES (230,13,'TOTAL STOCK VALUE','TOTAL STOCK VALUE' ,1,1)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE name='Proc_RptCurrentStockSalesInUOMBased' AND xtype='p')
DROP PROCEDURE Proc_RptCurrentStockSalesInUOMBased
GO
Create proc Proc_RptCurrentStockSalesInUOMBased
--EXEC Proc_RptCurrentStockSalesInUOMBased 230,2,0,'JNJ',0,0,1
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
* PROCEDURE : Proc_RptCurrentStockSalesInUOMBased
* PURPOSE : To get the Current Stock sales in UOM Based Report
* CREATED : Vasantharaj.R
* CREATED DATE : 29/04/2011
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId		AS INT
	DECLARE @DBNAME			AS NVARCHAR(50)
	DECLARE @TblName		AS NVARCHAR(500)
	DECLARE @TblStruct		AS NVARCHAR(4000)
	DECLARE @TblFields		AS NVARCHAR(4000)
	DECLARE @sSql			AS NVARCHAR(4000)
	DECLARE @ErrNo			AS INT
	DECLARE @PurDBName		AS NVARCHAR(50)
	--Filter Variable
    DECLARE @CmpId          AS Int
	DECLARE @LcnId          AS Int
    DECLARE @PrdId          AS Int
	DECLARE @CmpPrdCtgId    AS Int
	DECLARE @PrdCtgMainId   AS Int
	DECLARE @StockValue     AS Int
	DECLARE @DispBatch      AS Int
	DECLARE @PrdStatus      AS Int
	DECLARE @PrdBatId       AS Int
	DECLARE @PrdBatStatus   AS Int
	DECLARE @fPrdCatPrdId   AS Int
	DECLARE @fPrdId         AS Int
	DECLARE @SupZeroStock	AS INT
    --Till Here
	--Assgin Value for the Filter Variable
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
    SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @StockValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	SET @PrdBatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
    print @DispBatch
    EXEC PROC_GR_BUILD_PH
    CREATE TABLE #RptCurrentStockSalesInUOMBased
	(	  PRDID                       INT,
		  PRDCCODE                    NVARCHAR(200),
		  PRDNAME                     NVARCHAR(400),
		  PRDBATCODE                  NVARCHAR(400),
		  LCNID                       INT,
		  [SALEABLE STOCK IN SUOM]    NUMERIC(18,2),    
		  [Unsaleable Stock in SUOM]  NUMERIC(18,2), 
		  [Offer Stock in SUOM]       NUMERIC(18,2), 
		  [TOTAL STOCK IN SUOM]       NUMERIC(18,2), 
		  [SALEABLE STOCK VALUE]      NUMERIC(18,2), 
		  [UNSALEABLE STOCK VALUE]    NUMERIC(18,2), 
		  [OFFER STOCK VALUE]         NUMERIC(18,2), 
		  [TOTAL STOCK VALUE ]        NUMERIC(18,2)
    ) 
 --For RptExcelHeaders 
	IF @DispBatch = 1
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=4 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
 --Till Here
 --If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
--	
--print @StockValue	
CREATE TABLE #TEMPCONVERSIONFACTOR
 (	    PRDID INT,
		CONVERSIONFACTOR INT
 )
	INSERT INTO #TEMPCONVERSIONFACTOR
	SELECT A.PRDID,B.CONVERSIONFACTOR
	FROM PRODUCT A INNER JOIN UOMGROUP B ON A.UOMGROUPID=B.UOMGROUPID
	INNER JOIN UOMMASTER C ON B.UOMID=C.UOMID WHERE C.UOMCODE='DZ'
	UNION 
	SELECT A.PRDID,B.CONVERSIONFACTOR
	FROM PRODUCT A INNER JOIN UOMGROUP B ON A.UOMGROUPID=B.UOMGROUPID
	INNER JOIN UOMMASTER C ON B.UOMID=C.UOMID WHERE C.UOMCODE NOT IN ('PC','DZ','CSE')
	UNION
	SELECT A.PRDID,B.CONVERSIONFACTOR
	FROM PRODUCT A INNER JOIN UOMGROUP B ON A.UOMGROUPID=B.UOMGROUPID
	INNER JOIN UOMMASTER C ON B.UOMID=C.UOMID WHERE C.UOMCODE='PC' AND A.PRDID NOT IN (SELECT A.PRDID
	FROM PRODUCT A INNER JOIN UOMGROUP B ON A.UOMGROUPID=B.UOMGROUPID
	INNER JOIN UOMMASTER C ON B.UOMID=C.UOMID WHERE C.UOMCODE NOT IN ('PC','DZ','CSE')) AND A.PRDID NOT IN (SELECT A.PRDID
	FROM PRODUCT A INNER JOIN UOMGROUP B ON A.UOMGROUPID=B.UOMGROUPID
	INNER JOIN UOMMASTER C ON B.UOMID=C.UOMID WHERE C.UOMCODE='DZ')
IF @SupZeroStock=1
	BEGIN
        INSERT INTO #RptCurrentStockSalesInUOMBased
		SELECT P.PRDID,P.PRDCCODE,P.PRDNAME,PB.PRDBATCODE,PBL.LCNID,
			   (CAST((PBL.PRDBATLCNSIH)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESSIH)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)) AS 'SALEABLE STOCK IN SUOM',
			   (CAST((PBL.PRDBATLCNUIH)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESUIH)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)) AS 'Unsaleable Stock in SUOM',
			   (CAST((PBL.PRDBATLCNFRE)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESFRE)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)) AS 'Offer Stock in SUOM',
			   SUM(((CAST((PBL.PRDBATLCNSIH)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESSIH)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)))+
			   ((CAST((PBL.PRDBATLCNUIH)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESUIH)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)))+
			   ((CAST((PBL.PRDBATLCNFRE)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESFRE)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)))) AS 'TOTAL STOCK IN SUOM', 
			   (CASE @StockValue WHEN 1 then ((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.SELLINGRATE)
								 WHEN 2 then ((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.PurchaseRate)
								 WHEN 3 then ((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.MRP)END)AS 'SALEABLE STOCK VALUE',			 
			   (CASE @StockValue WHEN 1 then ((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.SELLINGRATE)		
						         WHEN 2 then ((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.PurchaseRate)
				     	         WHEN 3 then ((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.MRP)END)AS 'UNSALEABLE STOCK VALUE',
			   (CASE @StockValue WHEN 1 then ((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.SELLINGRATE)
					             WHEN 2 then ((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.PurchaseRate)
					             WHEN 3 then ((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.MRP)END)AS 'OFFER STOCK VALUE',
			   (CASE @StockValue WHEN 1 then SUM(((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.SELLINGRATE)+((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.SELLINGRATE) +((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.SELLINGRATE))  
								 WHEN 2 then SUM(((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.PurchaseRate)+((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.PurchaseRate) +((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.PurchaseRate))  	
				                 WHEN 3 then SUM(((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.MRP)+((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.MRP) +((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.MRP))END) AS 'TOTAL STOCK VALUE'
			
		FROM PRODUCT P  
			 INNER JOIN PRODUCTBATCHLOCATION PBL ON P.PRDID=PBL.PRDID
			 INNER JOIN DEFAULTPRICEHISTORY DPH ON PBL.PRDID=DPH.PRDID AND PBL.PRDBATID=DPH.PRDBATID AND P.PRDID=DPH.PRDID  
			 INNER JOIN #TEMPCONVERSIONFACTOR TCF ON P.PRDID=TCF.PRDID AND PBL.PRDID=TCF.PRDID AND TCF.PRDID=DPH.PRDID
			 INNER JOIN Location L ON L.LcnId=PBL.LcnId
			 INNER JOIN ProductBatch PB ON PB.PrdId=PBL.PrdId AND PB.PRDBATID=PBL.PRDBATID
			 INNER JOIN TBL_GR_BUILD_PH TBLG ON TBLG.PRDID=P.PRDID 			
		 
		WHERE (PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)<>0  AND (DPH.CurrentDefault = 1) AND
			  (P.CmpId=  (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END ) OR
  			  P.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			  AND   (L.LcnId=  (CASE @LcnId WHEN 0 THEN L.LcnId ELSE 0 END ) OR
			  L.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			  AND   (P.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN P.PrdId Else 0 END) OR
			  P.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			  AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
			  PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			  AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
			  Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
		GROUP BY P.PRDID,P.PRDCCODE,P.PRDNAME,PBL.LCNID,DPH.SELLINGRATE,PBL.PRDBATLCNSIH,PBL.PRDBATLCNUIH,PBL.PRDBATLCNFRE,PBL.PRDBATLCNRESSIH,PBL.PRDBATLCNRESUIH,
			     PBL.PRDBATLCNRESFRE,TCF.CONVERSIONFACTOR,DPH.PurchaseRate,DPH.MRP,PB.PRDBATCODE,TBLG.FRANCHISE_ID
		ORDER BY TBLG.FRANCHISE_ID 
					
    END
	ELSE
    BEGIN
	    INSERT INTO #RptCurrentStockSalesInUOMBased
		SELECT P.PRDID,P.PRDCCODE,P.PRDNAME,PB.PRDBATCODE,PBL.LCNID,
			   (CAST((PBL.PRDBATLCNSIH)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESSIH)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)) AS 'SALEABLE STOCK IN SUOM',
			   (CAST((PBL.PRDBATLCNUIH)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESUIH)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)) AS 'Unsaleable Stock in SUOM',
			   (CAST((PBL.PRDBATLCNFRE)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESFRE)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)) AS 'Offer Stock in SUOM',
			   SUM(((CAST((PBL.PRDBATLCNSIH)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESSIH)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)))+
			   ((CAST((PBL.PRDBATLCNUIH)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESUIH)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)))+
			   ((CAST((PBL.PRDBATLCNFRE)AS NUMERIC(18,2))-CAST((PBL.PRDBATLCNRESFRE)AS NUMERIC(18,2)))/CAST((TCF.CONVERSIONFACTOR)AS NUMERIC(18,2)))) AS 'TOTAL STOCK IN SUOM', 
			   (CASE @StockValue WHEN 1 then ((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.SELLINGRATE)
								 WHEN 2 then ((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.PurchaseRate)
								 WHEN 3 then ((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.MRP)END)AS 'SALEABLE STOCK VALUE',			 
			   (CASE @StockValue WHEN 1 then ((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.SELLINGRATE)		
						         WHEN 2 then ((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.PurchaseRate)
				     	         WHEN 3 then ((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.MRP)END)AS 'UNSALEABLE STOCK VALUE',
			   (CASE @StockValue WHEN 1 then ((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.SELLINGRATE)
					             WHEN 2 then ((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.PurchaseRate)
					             WHEN 3 then ((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.MRP)END)AS 'OFFER STOCK VALUE',
			   (CASE @StockValue WHEN 1 then SUM(((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.SELLINGRATE)+((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.SELLINGRATE) +((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.SELLINGRATE))  
								 WHEN 2 then SUM(((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.PurchaseRate)+((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.PurchaseRate) +((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.PurchaseRate))  	
				                 WHEN 3 then SUM(((PBL.PRDBATLCNSIH-PBL.PRDBATLCNRESSIH)*DPH.MRP)+((PBL.PRDBATLCNUIH-PBL.PRDBATLCNRESUIH)*DPH.MRP) +((PBL.PRDBATLCNFRE-PBL.PRDBATLCNRESFRE)*DPH.MRP))END) AS 'TOTAL STOCK VALUE'
			
		FROM PRODUCT P  
			 INNER JOIN PRODUCTBATCHLOCATION PBL ON P.PRDID=PBL.PRDID
			 INNER JOIN DEFAULTPRICEHISTORY DPH ON PBL.PRDID=DPH.PRDID AND PBL.PRDBATID=DPH.PRDBATID AND P.PRDID=DPH.PRDID  
			 INNER JOIN #TEMPCONVERSIONFACTOR TCF ON P.PRDID=TCF.PRDID AND PBL.PRDID=TCF.PRDID AND TCF.PRDID=DPH.PRDID
			 INNER JOIN Location L ON L.LcnId=PBL.LcnId
			 INNER JOIN ProductBatch PB ON PB.PrdId=PBL.PrdId AND PB.PRDBATID=PBL.PRDBATID
			 INNER JOIN TBL_GR_BUILD_PH TBLG ON TBLG.PRDID=P.PRDID 			
		 
		WHERE (DPH.CurrentDefault = 1) AND
			  (P.CmpId=  (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END ) OR
  			  P.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			  AND   (L.LcnId=  (CASE @LcnId WHEN 0 THEN L.LcnId ELSE 0 END ) OR
			  L.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			  AND   (P.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN P.PrdId Else 0 END) OR
			  P.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			  AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
			  PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			  AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
			  Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
		GROUP BY P.PRDID,P.PRDCCODE,P.PRDNAME,PBL.LCNID,DPH.SELLINGRATE,PBL.PRDBATLCNSIH,PBL.PRDBATLCNUIH,PBL.PRDBATLCNFRE,PBL.PRDBATLCNRESSIH,PBL.PRDBATLCNRESUIH,
			     PBL.PRDBATLCNRESFRE,TCF.CONVERSIONFACTOR,DPH.PurchaseRate,DPH.MRP,PB.PRDBATCODE,TBLG.FRANCHISE_ID
		ORDER BY TBLG.FRANCHISE_ID 	 
	END	
		 DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
		 INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		 SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStockSalesInUOMBased
		 PRINT 'Data Executed'
 IF @DispBatch=2
	  BEGIN 
			SELECT PRDID,PRDCCODE,PRDNAME,''AS PRDBATCODE,LCNID,SUM([SALEABLE STOCK IN SUOM]) AS 'SALEABLE STOCK IN SUOM' ,SUM([Unsaleable Stock in SUOM])AS 'Unsaleable Stock in SUOM',SUM([Offer Stock in SUOM])AS 'Offer Stock in SUOM',
			SUM([TOTAL STOCK IN SUOM])AS 'TOTAL STOCK IN SUOM',SUM([SALEABLE STOCK VALUE])AS 'SALEABLE STOCK VALUE',SUM([UNSALEABLE STOCK VALUE])AS 'UNSALEABLE STOCK VALUE',SUM([OFFER STOCK VALUE])AS 'OFFER STOCK VALUE',SUM([TOTAL STOCK VALUE ]) AS 'TOTAL STOCK VALUE '
			FROM  #RptCurrentStockSalesInUOMBased
			GROUP BY PRDID,PRDCCODE,PRDNAME,LCNID
      END
	  ELSE
		    SELECT * FROM #RptCurrentStockSalesInUOMBased 

      END
GO 

--SRF-Nanda-236-003-From Vasanth

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptStoreSchemeDetails')
DROP PROCEDURE  Proc_RptStoreSchemeDetails
GO
/*
SELECT  * FROM RPTStoreSchemeDetails ORDER By SchId,ReferNo
EXEC Proc_RptStoreSchemeDetails 15,2
*/
CREATE PROCEDURE [Proc_RptStoreSchemeDetails]
(	
	@Pi_RptId		INT,
	@Pi_UsrId		INT
)
AS
/*********************************
* PROCEDURE: Proc_RptStoreSchemeDetails
* PURPOSE: General Procedure To Get the Scheme Details into Scheme Temp Table
* NOTES:
* CREATED: Thrinath Kola	30-07-2007
* MODIFIED
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 15/11/2010	Nanda	   Free and Gift Value changes for Sales Return	
*********************************/
SET NOCOUNT ON
BEGIN
	--Filter Variable
	DECLARE @FromDate	AS 	DateTime
	DECLARE @ToDate		AS	DateTime
	DECLARE @fSchId		AS	Int
	DECLARE @fSMId		AS	Int
	DECLARE @fRMId		AS	Int
	DECLARE @CtgLevelId AS    INT
	DECLARE @CtgMainId  AS    INT
	DECLARE @RtrClassId AS    INT
	DECLARE @fRtrId		AS	Int
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
	--select * from RPTStoreSchemeDetails
	DELETE FROM RPTStoreSchemeDetails WHERE UserId = @Pi_UsrId
	--Values For Scheme Amount From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,B.PrdId,B.PrdBatId,ISNULL(SUM(B.FlatAmount),0) As FlatAmount,
		ISNULL(SUM(B.DisCountPerAmount),0) as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,A.VehicleId,A.DlvBoyId,
		B.PrdId,B.PrdBatId,Budget,K.SMName,D.RMName,E.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,G.VehicleRegNo,H.DlvBoyName,
		I.PrdName,J.PrdBatCode,SalInvDate
	
	--->Added By Nanda on 06/04/2010-For QPS Scheem Amount-Credit Conversion
	--Values For Scheme Amount From SalesInvoice-QPS Convesrion-Qty Based
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId AS SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,0 AS PrdId,0 AS PrdBatId,ISNULL(SUM(B.CrNoteAmount),0) As FlatAmount,
		0 as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		'' AS PrdName,'' AS PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceQPSSchemeAdj B ON A.SalId = B.SalId AND B.Mode=1
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId 
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,A.VehicleId,A.DlvBoyId,
		Budget,K.SMName,D.RMName,E.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,G.VehicleRegNo,H.DlvBoyName,SalInvDate
	--Values For Scheme Amount From SalesInvoice-QPS Convesrion-Date Based
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId AS SlabId,'' AS SalInvNo,0 AS SMId,0 AS RMId,0 AS DlvRMId,0 AS CtgLevelId,0 AS CtgMainId,0 AS RtrValueClassId,
		0 AS RtrId,4,0 AS VehicleId,0 AS DlvBoyId,0 AS PrdId,0 AS PrdBatId,ISNULL(SUM(B.CrNoteAmount),0) As FlatAmount,
		0 as DiscountPer,0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,'' AS SMName,'' AS RMName,'' AS DlvRMName,'' AS CtgLevelName,'' AS CtgName,'' AS ValueClassName,'' AS RtrName,'' AS VehicleRegNo,
		'' AS DlvBoyName,'' AS PrdName,'' AS PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		1 as LineType,B.LastModDate
	FROM SalesInvoiceQPSSchemeAdj B 
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND B.Mode=2
	WHERE B.LastModDate Between @FromDate AND @ToDate 
	GROUP BY B.SchId,B.SlabId,Budget,B.LastModDate
	--->Till Here
	--Values For Points From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
		Points AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN SalesInvoiceSchemeDtPoints L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND B.SlabId = L.SlabId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	--Values For Free Product From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,
		FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT DISTINCT L.SchId,L.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,L.FreePrdId AS PrdId,L.FreePrdBatId AS PrdBatId,0 As FlatAmount,0 as DiscountPer,
		0 AS Points,L.FreePrdId As FreePrdId,L.FreePrdBatId AS FreePrdBatId,L.FreeQty as FreeQty,
		(L.FreeQty * O.PrdBatDetailValue) as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(L.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,'' AS PrdBatCode,M.PrdName as FreePrdName,N.PrdBatCode as FreeBatchName,
		'-' as GiftPrdName,'' as GiftBatchName,1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
	INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
	AND P.ClmRte = 1
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	--Values For Gift Product From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,
		FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,
		L.GiftPrdId as GiftPrdId,L.GiftPrdBatId As GiftPrdBatId,L.GiftQty as GiftQty,
		(L.GiftQty * O.PrdBatDetailValue) as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),
		1 as Selected,@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,
		ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,
		M.PrdName as GiftPrdName,N.PrdBatCode as GiftBatchName,1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
	INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
	AND P.ClmRte = 1
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	--rathi
	--Values For Scheme Amount From Return
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,0 as DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,0 AS VehicleId,
		0 AS DlvBoyId,B.PrdId,B.PrdBatId,-1 * ISNULL(SUM(B.ReturnFlatAmount),0) As FlatAmount,
		-1 * ISNULL(SUM(B.ReturnDiscountPerAmount),0) as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,'' AS VehicleRegNo,'' AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		2 as LineType,ReturnDate
	FROM ReturnHeader A INNER JOIN ReturnSchemeLineDt B ON A.ReturnId = B.ReturnId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId  INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,
		B.PrdId,B.PrdBatId,Budget,K.SMName,D.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,I.PrdName,J.PrdBatCode,ReturnDate
	--Values For Points From Return
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,0 as DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,0 AS VehicleId,
		0 AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
		-1 * ISNULL(SUM(ReturnPoints),0) AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,'' AS VehicleRegNo,''AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		2 as LineType,ReturnDate
	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
		INNER JOIN SalesInvoiceSchemeDtBilled B ON A1.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
		AND A1.PrdBatId = B.PrdBatId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN ReturnSchemePointsDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId
		AND B.SlabId = L.SlabId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,B.PrdId,B.PrdBatId,
		Budget,K.SMName,D.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,I.PrdName,J.PrdBatCode,ReturnDate
	--Values For Free Product From Return
--	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
--		PrdID,PrdBatId,FlatAmount,DiscountPer,
--		Points,FreePrdId,FreePrdBatId,FreeQty,
--		FreeValue,GiftPrdId,GiftPrdBatId,
--		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
--		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
--		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
--	SELECT B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,0 as DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,0 AS VehicleId,
--		0 AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
--		0 AS Points,L.FreePrdId As FreePrdId,L.FreePrdBatId AS FreePrdBatId,(-1 * ISNULL(SUM(L.ReturnFreeQty),0)) as FreeQty,
--		(-1 * (ISNULL(SUM(L.ReturnFreeQty),0) * O.PrdBatDetailValue)) as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
--		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
--		@Pi_UsrId,K.SMName,D.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,'' AS VehicleRegNo,
--		'' AS DlvBoyName,I.PrdName,J.PrdBatCode,M.PrdName as FreePrdName,N.PrdBatCode as FreeBatchName,
--		'-' as GiftPrdName,'' as GiftBatchName,2 as LineType,ReturnDate
--	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
--		INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
--		AND A1.PrdBatId = B.PrdBatId
--		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
--		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
--		INNER JOIN RouteMaster D ON A.RMId = D.RMId
--		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
--		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
--		INNER JOIN ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId
--		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId
--		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
--		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
--	INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
--	AND P.ClmRte = 1
--		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
--		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
--		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
--		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
--	WHERE ReturnDate Between @FromDate AND @ToDate  AND
--		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
--		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
--		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
--		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
--		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
--		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
--		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
--		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
--		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
--		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
--		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
--		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
--		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
--		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
--		A.Status =0
--	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,
--		 A.RtrId,A.Status,B.PrdId,B.PrdBatId,L.FreePrdId,L.FreePrdBatId,O.PrdBatDetailValue,Budget,
--		 K.SMName,D.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,I.PrdName,
--		 J.PrdBatCode,M.PrdName,N.PrdBatCode,ReturnDate
		
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,
		FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT RSF.SchId,RSF.SlabId,RH.ReturnCode,S.SMId,RM.RMId,0 AS DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,RH.RtrId,RH.Status,0 AS VehicleId,
		0 AS DlvBoyId,0 AS PrdId,0 AS PrdBatId,0 AS FlatAmount,0 AS DiscountPer,
		0 AS Points,RSF.FreePrdId,RSF.FreePrdBatId,(-1 * ISNULL(SUM(RSF.ReturnFreeQty),0)) AS FreeQty,
		(-1 * (ISNULL(SUM(RSF.ReturnFreeQty),0) * PBD.PrdBatDetailValue)) AS FreeValue,0 AS GiftPrdId,0 AS GiftPrdBatId,
		0 AS GiftQty,0 AS GiftValue,SM.Budget AS SchemeBudget,dbo.Fn_ReturnBudgetUtilized(RSF.SchId),1 AS Selected,
		@Pi_UsrId,S.SMName,RM.RMName,'' AS DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,'' AS VehicleRegNo,
		'' AS DlvBoyName,P.PrdName,PB.PrdBatCode,P.PrdName AS FreePrdName,PB.PrdBatCode AS FreeBatchName,
		'-' AS GiftPrdName,'' AS GiftBatchName,2 AS LineType,ReturnDate
	FROM ReturnHeader RH 
		INNER JOIN ReturnSchemeFreePrdDt RSF ON  RH.ReturnId = RSF.ReturnId 
		INNER JOIN SchemeMaster SM ON  SM.SchId = RSF.SchId 
		INNER JOIN SalesMan S ON  S.SMId = RH.SMId
		INNER JOIN RouteMaster RM ON  RM.RMId = RH.RMId
		INNER JOIN Retailer R ON  R.RtrId = RH.RtrId 
		INNER JOIN RetailerValueClassMap RVCM ON  RVCM.RtrId=R.RtrId
		INNER JOIN RetailerValueClass RVC ON  RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON  RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON  RCL.CtgLevelId=RC.CtgLevelId 
		INNER JOIN Product P ON RSF.FreePrdId = P.PrdId
		INNER JOIN ProductBatch PB ON RSF.FreePrdBatId = PB.PrdBatId AND SM.CmpId=RCL.CmpId
		INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId = PBD.PrdBatID AND PBD.PriceId=RSF.FreePriceId
		INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId = PBD.BatchSeqId AND PBD.SlNo = BC.SlNo AND BC.ClmRte = 1
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(RH.SMId = (CASE @fSMId WHEN 0 THEN RH.SMId Else 0 END) OR
		RH.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(RH.RMId = (CASE @fRMId WHEN 0 THEN RH.RMId Else 0 END) OR
		RH.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(RH.RtrID = (CASE @fRtrId WHEN 0 THEN RH.RtrID Else 0 END) OR
		RH.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(SM.SchId = (CASE @fSchId WHEN 0 THEN SM.SchId Else 0 END) OR
		SM.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		RH.Status =0
	GROUP BY RSF.SchId,RSF.SlabId,RH.ReturnCode,S.SMId,RM.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,RH.RtrId,RH.Status,
		RSF.FreePrdId,RSF.FreePrdBatId,PBD.PrdBatDetailValue,SM.Budget,S.SMName,RM.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,
		P.PrdName,PB.PrdBatCode,P.PrdName,PB.PrdBatCode,ReturnDate
	--Values For Gift Product From Return
--	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
--		PrdID,PrdBatId,FlatAmount,DiscountPer,
--		Points,FreePrdId,FreePrdBatId,FreeQty,
--		FreeValue,GiftPrdId,GiftPrdBatId,
--		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
--		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
--		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
--	SELECT B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,0 as DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,0 AS VehicleId,
--		0 AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
--		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,
--		L.GiftPrdId as GiftPrdId,L.GiftPrdBatId As GiftPrdBatId,(-1 * ISNULL(SUM(L.ReturnGiftQty),0)) as GiftQty,
--		(-1 * ISNULL(SUM(L.ReturnGiftQty),0) * O.PrdBatDetailValue) as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),
--		1 as Selected,@Pi_UsrId,K.SMName,D.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,
--		'' AS VehicleRegNo,'' AS DlvBoyName,
--		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,
--		M.PrdName as GiftPrdName,N.PrdBatCode as GiftBatchName,2 as LineType,ReturnDate
--	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
--		INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
--		AND A1.PrdBatId = B.PrdBatId
--		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
--		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
--		INNER JOIN RouteMaster D ON A.RMId = D.RMId
--		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
--		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
--		INNER JOIN dbo.ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId
--		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId
--		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
--		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
--	INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
--	AND P.ClmRte = 1
--		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
--		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
--		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
--		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
--	WHERE ReturnDate Between @FromDate AND @ToDate  AND
--		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
--		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
--		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
--		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
--		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
--		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
--		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
--		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
--		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
--		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
--		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
--		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
--		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
--		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
--		A.Status =0
--	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,
--		 A.RtrId,A.Status,B.PrdId,B.PrdBatId,L.GiftPrdId,L.GiftPrdBatId,O.PrdBatDetailValue,Budget,
--		 K.SMName,D.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,I.PrdName,
--		 J.PrdBatCode,M.PrdName,N.PrdBatCode,ReturnDate
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,
		FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT RSF.SchId,RSF.SlabId,RH.ReturnCode,S.SMId,RM.RMId,0 AS DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,RH.RtrId,RH.Status,0 AS VehicleId,
		0 AS DlvBoyId,0 AS PrdId,0 AS PrdBatId,0 AS FlatAmount,0 AS DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,
		RSF.GiftPrdId,RSF.GiftPrdBatId,(-1 * ISNULL(SUM(RSF.ReturnGiftQty),0)) as GiftQty,
		(-1 * ISNULL(SUM(RSF.ReturnGiftQty),0) * PBD.PrdBatDetailValue) as GiftValue,SM.Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(RSF.SchId),
		1 as Selected,@Pi_UsrId,S.SMName,RM.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,
		'' AS VehicleRegNo,'' AS DlvBoyName,
		P.PrdName,PB.PrdBatCode,'-' AS FreePrdName,'' AS FreeBatchName,
		P.PrdName AS GiftPrdName,PB.PrdBatCode AS GiftBatchName,2 AS LineType,ReturnDate
	FROM ReturnHeader RH 
		INNER JOIN ReturnSchemeFreePrdDt RSF ON  RH.ReturnId = RSF.ReturnId 
		INNER JOIN SchemeMaster SM ON  SM.SchId = RSF.SchId 
		INNER JOIN SalesMan S ON  S.SMId = RH.SMId
		INNER JOIN RouteMaster RM ON  RM.RMId = RH.RMId
		INNER JOIN Retailer R ON  R.RtrId = RH.RtrId 
		INNER JOIN RetailerValueClassMap RVCM ON  RVCM.RtrId=R.RtrId
		INNER JOIN RetailerValueClass RVC ON  RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON  RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON  RCL.CtgLevelId=RC.CtgLevelId 
		INNER JOIN Product P ON RSF.GiftPrdId = P.PrdId
		INNER JOIN ProductBatch PB ON RSF.GiftPrdBatId = PB.PrdBatId AND SM.CmpId=RCL.CmpId
		INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId = PBD.PrdBatID AND PBD.PriceId=RSF.GiftPriceId
		INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId = PBD.BatchSeqId AND PBD.SlNo = BC.SlNo AND BC.ClmRte = 1
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(RH.SMId = (CASE @fSMId WHEN 0 THEN RH.SMId Else 0 END) OR
		RH.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(RH.RMId = (CASE @fRMId WHEN 0 THEN RH.RMId Else 0 END) OR
		RH.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(RH.RtrID = (CASE @fRtrId WHEN 0 THEN RH.RtrID Else 0 END) OR
		RH.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(SM.SchId = (CASE @fSchId WHEN 0 THEN SM.SchId Else 0 END) OR
		SM.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		RH.Status =0
	GROUP BY RSF.SchId,RSF.SlabId,RH.ReturnCode,S.SMId,RM.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,RH.RtrId,RH.Status,
		RSF.GiftPrdId,RSF.GiftPrdBatId,PBD.PrdBatDetailValue,SM.Budget,S.SMName,RM.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,
		P.PrdName,PB.PrdBatCode,P.PrdName,PB.PrdBatCode,ReturnDate
	--Values For UnSelected Scheme From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,0 as PrdId,0 as PrdBatId,0 As FlatAmount,0 as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),2 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		'' As PrdName,'' as PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		3 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceUnSelectedScheme B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,A.VehicleId,A.DlvBoyId,
		Budget,K.SMName,D.RMName,E.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,G.VehicleRegNo,H.DlvBoyName,SalInvDate
END
GO 

--SRF-Nanda-236-004

if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplateFinal]
GO

CREATE TABLE [dbo].[RptBillTemplateFinal]
(
	[Base Qty] [numeric](38, 2) NULL,
	[Batch Code] [nvarchar](100) NULL,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](100) NULL,
	[Bill Mode] [tinyint] NULL,
	[Bill Type] [tinyint] NULL,
	[CD Disc Base Qty Amount] [numeric](38, 2) NULL,
	[CD Disc Effect Amount] [numeric](38, 2) NULL,
	[CD Disc Header Amount] [numeric](38, 2) NULL,
	[CD Disc LineUnit Amount] [numeric](38, 2) NULL,
	[CD Disc Qty Percentage] [numeric](38, 2) NULL,
	[CD Disc Unit Percentage] [numeric](38, 2) NULL,
	[CD Disc UOM Amount] [numeric](38, 2) NULL,
	[CD Disc UOM Percentage] [numeric](38, 2) NULL,
	[Company Address1] [nvarchar](100) NULL,
	[Company Address2] [nvarchar](100) NULL,
	[Company Address3] [nvarchar](100) NULL,
	[Company Code] [nvarchar](40) NULL,
	[Company Contact Person] [nvarchar](200) NULL,
	[Company EmailId] [nvarchar](100) NULL,
	[Company Fax Number] [nvarchar](100) NULL,
	[Company Name] [nvarchar](200) NULL,
	[Company Phone Number] [nvarchar](100) NULL,
	[Contact Person] [nvarchar](100) NULL,
	[CST Number] [nvarchar](100) NULL,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](200) NULL,
	[Delivery Boy] [nvarchar](100) NULL,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](100) NULL,
	[Distributor Address2] [nvarchar](100) NULL,
	[Distributor Address3] [nvarchar](100) NULL,
	[Distributor Code] [nvarchar](40) NULL,
	[Distributor Name] [nvarchar](100) NULL,
	[Drug Batch Description] [nvarchar](100) NULL,
	[Drug Licence Number 1] [nvarchar](100) NULL,
	[Drug Licence Number 2] [nvarchar](100) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) NULL,
	[EmailID] [nvarchar](100) NULL,
	[Geo Level] [nvarchar](100) NULL,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](100) NULL,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](100) NULL,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](100) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](100) NULL,
	[Product Name] [nvarchar](400) NULL,
	[Product Short Name] [nvarchar](200) NULL,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](400) NULL,
	[Retailer Address1] [nvarchar](200) NULL,
	[Retailer Address2] [nvarchar](200) NULL,
	[Retailer Address3] [nvarchar](200) NULL,
	[Retailer Code] [nvarchar](100) NULL,
	[Retailer ContactPerson] [nvarchar](200) NULL,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](100) NULL,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](100) NULL,
	[Retailer EmailId] [nvarchar](200) NULL,
	[Retailer GeoLevel] [nvarchar](100) NULL,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](100) NULL,
	[Retailer Name] [nvarchar](300) NULL,
	[Retailer OffPhone1] [nvarchar](100) NULL,
	[Retailer OffPhone2] [nvarchar](100) NULL,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](100) NULL,
	[Retailer PhoneNo] [nvarchar](100) NULL,
	[Retailer Pin Code] [nvarchar](100) NULL,
	[Retailer ResPhone1] [nvarchar](100) NULL,
	[Retailer ResPhone2] [nvarchar](100) NULL,
	[Retailer Ship Address1] [nvarchar](200) NULL,
	[Retailer Ship Address2] [nvarchar](200) NULL,
	[Retailer Ship Address3] [nvarchar](200) NULL,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](100) NULL,
	[Retailer Village] [nvarchar](200) NULL,
	[Route Code] [nvarchar](100) NULL,
	[Route Name] [nvarchar](100) NULL,
	[Sales Invoice Number] [nvarchar](100) NULL,
	[SalesInvoice ActNetRateAmount] [numeric](38, 2) NULL,
	[SalesInvoice CDPer] [numeric](38, 2) NULL,
	[SalesInvoice CRAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice DBAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice GrossAmount] [numeric](38, 2) NULL,
	[SalesInvoice Line Gross Amount] [numeric](38, 2) NULL,
	[SalesInvoice Line Net Amount] [numeric](38, 2) NULL,
	[SalesInvoice MarketRetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetRateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice OnAccountAmount] [numeric](38, 2) NULL,
	[SalesInvoice OtherCharges] [numeric](38, 2) NULL,
	[SalesInvoice RateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice ReplacementDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice RoundOffAmt] [numeric](38, 2) NULL,
	[SalesInvoice TotalAddition] [numeric](38, 2) NULL,
	[SalesInvoice TotalDeduction] [numeric](38, 2) NULL,
	[SalesInvoice WindowDisplayAmount] [numeric](38, 2) NULL,
	[SalesMan Code] [nvarchar](100) NULL,
	[SalesMan Name] [nvarchar](100) NULL,
	[SalId] [int] NULL,
	[Sch Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Sch Disc Effect Amount] [numeric](38, 2) NULL,
	[Sch Disc Header Amount] [numeric](38, 2) NULL,
	[Sch Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Sch Disc Qty Percentage] [numeric](38, 2) NULL,
	[Sch Disc Unit Percentage] [numeric](38, 2) NULL,
	[Sch Disc UOM Amount] [numeric](38, 2) NULL,
	[Sch Disc UOM Percentage] [numeric](38, 2) NULL,
	[Scheme Points] [numeric](38, 2) NULL,
	[Spl. Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Spl. Disc Effect Amount] [numeric](38, 2) NULL,
	[Spl. Disc Header Amount] [numeric](38, 2) NULL,
	[Spl. Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Spl. Disc Qty Percentage] [numeric](38, 2) NULL,
	[Spl. Disc Unit Percentage] [numeric](38, 2) NULL,
	[Spl. Disc UOM Amount] [numeric](38, 2) NULL,
	[Spl. Disc UOM Percentage] [numeric](38, 2) NULL,
	[Tax 1] [numeric](38, 2) NULL,
	[Tax 2] [numeric](38, 2) NULL,
	[Tax 3] [numeric](38, 2) NULL,
	[Tax 4] [numeric](38, 2) NULL,
	[Tax Amount1] [numeric](38, 2) NULL,
	[Tax Amount2] [numeric](38, 2) NULL,
	[Tax Amount3] [numeric](38, 2) NULL,
	[Tax Amount4] [numeric](38, 2) NULL,
	[Tax Amt Base Qty Amount] [numeric](38, 2) NULL,
	[Tax Amt Effect Amount] [numeric](38, 2) NULL,
	[Tax Amt Header Amount] [numeric](38, 2) NULL,
	[Tax Amt LineUnit Amount] [numeric](38, 2) NULL,
	[Tax Amt Qty Percentage] [numeric](38, 2) NULL,
	[Tax Amt Unit Percentage] [numeric](38, 2) NULL,
	[Tax Amt UOM Amount] [numeric](38, 2) NULL,
	[Tax Amt UOM Percentage] [numeric](38, 2) NULL,
	[Tax Type] [tinyint] NULL,
	[TIN Number] [nvarchar](100) NULL,
	[Uom 1 Desc] [nvarchar](100) NULL,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](100) NULL,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](100) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[AmtInWrd] [nvarchar](500) NULL,
	[Product Weight] [numeric](38, 2) NULL,
	[Product UPC] [numeric](38, 0) NULL,
	[SalesInvoice Level Discount] [numeric](38, 6) NULL,
	[SalesInvoice Bill Book No] [nvarchar](100) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-236-005

if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal_Group]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplateFinal_Group]
GO

CREATE TABLE [dbo].[RptBillTemplateFinal_Group]
(
	[Base Qty] [numeric](38, 2) NULL,
	[Batch Code] [nvarchar](100) NULL,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](100) NULL,
	[Bill Mode] [tinyint] NULL,
	[Bill Type] [tinyint] NULL,
	[CD Disc Base Qty Amount] [numeric](38, 2) NULL,
	[CD Disc Effect Amount] [numeric](38, 2) NULL,
	[CD Disc Header Amount] [numeric](38, 2) NULL,
	[CD Disc LineUnit Amount] [numeric](38, 2) NULL,
	[CD Disc Qty Percentage] [numeric](38, 2) NULL,
	[CD Disc Unit Percentage] [numeric](38, 2) NULL,
	[CD Disc UOM Amount] [numeric](38, 2) NULL,
	[CD Disc UOM Percentage] [numeric](38, 2) NULL,
	[Company Address1] [nvarchar](100) NULL,
	[Company Address2] [nvarchar](100) NULL,
	[Company Address3] [nvarchar](100) NULL,
	[Company Code] [nvarchar](40) NULL,
	[Company Contact Person] [nvarchar](200) NULL,
	[Company EmailId] [nvarchar](100) NULL,
	[Company Fax Number] [nvarchar](100) NULL,
	[Company Name] [nvarchar](200) NULL,
	[Company Phone Number] [nvarchar](100) NULL,
	[Contact Person] [nvarchar](100) NULL,
	[CST Number] [nvarchar](100) NULL,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](200) NULL,
	[Delivery Boy] [nvarchar](100) NULL,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](100) NULL,
	[Distributor Address2] [nvarchar](100) NULL,
	[Distributor Address3] [nvarchar](100) NULL,
	[Distributor Code] [nvarchar](40) NULL,
	[Distributor Name] [nvarchar](100) NULL,
	[Drug Batch Description] [nvarchar](100) NULL,
	[Drug Licence Number 1] [nvarchar](100) NULL,
	[Drug Licence Number 2] [nvarchar](100) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) NULL,
	[EmailID] [nvarchar](100) NULL,
	[Geo Level] [nvarchar](100) NULL,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](100) NULL,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](100) NULL,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](100) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](100) NULL,
	[Product Name] [nvarchar](400) NULL,
	[Product Short Name] [nvarchar](200) NULL,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](400) NULL,
	[Retailer Address1] [nvarchar](200) NULL,
	[Retailer Address2] [nvarchar](200) NULL,
	[Retailer Address3] [nvarchar](200) NULL,
	[Retailer Code] [nvarchar](100) NULL,
	[Retailer ContactPerson] [nvarchar](200) NULL,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](100) NULL,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](100) NULL,
	[Retailer EmailId] [nvarchar](200) NULL,
	[Retailer GeoLevel] [nvarchar](100) NULL,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](100) NULL,
	[Retailer Name] [nvarchar](300) NULL,
	[Retailer OffPhone1] [nvarchar](100) NULL,
	[Retailer OffPhone2] [nvarchar](100) NULL,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](100) NULL,
	[Retailer PhoneNo] [nvarchar](100) NULL,
	[Retailer Pin Code] [nvarchar](100) NULL,
	[Retailer ResPhone1] [nvarchar](100) NULL,
	[Retailer ResPhone2] [nvarchar](100) NULL,
	[Retailer Ship Address1] [nvarchar](200) NULL,
	[Retailer Ship Address2] [nvarchar](200) NULL,
	[Retailer Ship Address3] [nvarchar](200) NULL,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](100) NULL,
	[Retailer Village] [nvarchar](200) NULL,
	[Route Code] [nvarchar](100) NULL,
	[Route Name] [nvarchar](100) NULL,
	[Sales Invoice Number] [nvarchar](100) NULL,
	[SalesInvoice ActNetRateAmount] [numeric](38, 2) NULL,
	[SalesInvoice CDPer] [numeric](38, 2) NULL,
	[SalesInvoice CRAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice DBAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice GrossAmount] [numeric](38, 2) NULL,
	[SalesInvoice Line Gross Amount] [numeric](38, 2) NULL,
	[SalesInvoice Line Net Amount] [numeric](38, 2) NULL,
	[SalesInvoice MarketRetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetRateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice OnAccountAmount] [numeric](38, 2) NULL,
	[SalesInvoice OtherCharges] [numeric](38, 2) NULL,
	[SalesInvoice RateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice ReplacementDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice RoundOffAmt] [numeric](38, 2) NULL,
	[SalesInvoice TotalAddition] [numeric](38, 2) NULL,
	[SalesInvoice TotalDeduction] [numeric](38, 2) NULL,
	[SalesInvoice WindowDisplayAmount] [numeric](38, 2) NULL,
	[SalesMan Code] [nvarchar](100) NULL,
	[SalesMan Name] [nvarchar](100) NULL,
	[SalId] [int] NULL,
	[Sch Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Sch Disc Effect Amount] [numeric](38, 2) NULL,
	[Sch Disc Header Amount] [numeric](38, 2) NULL,
	[Sch Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Sch Disc Qty Percentage] [numeric](38, 2) NULL,
	[Sch Disc Unit Percentage] [numeric](38, 2) NULL,
	[Sch Disc UOM Amount] [numeric](38, 2) NULL,
	[Sch Disc UOM Percentage] [numeric](38, 2) NULL,
	[Scheme Points] [numeric](38, 2) NULL,
	[Spl. Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Spl. Disc Effect Amount] [numeric](38, 2) NULL,
	[Spl. Disc Header Amount] [numeric](38, 2) NULL,
	[Spl. Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Spl. Disc Qty Percentage] [numeric](38, 2) NULL,
	[Spl. Disc Unit Percentage] [numeric](38, 2) NULL,
	[Spl. Disc UOM Amount] [numeric](38, 2) NULL,
	[Spl. Disc UOM Percentage] [numeric](38, 2) NULL,
	[Tax 1] [numeric](38, 2) NULL,
	[Tax 2] [numeric](38, 2) NULL,
	[Tax 3] [numeric](38, 2) NULL,
	[Tax 4] [numeric](38, 2) NULL,
	[Tax Amount1] [numeric](38, 2) NULL,
	[Tax Amount2] [numeric](38, 2) NULL,
	[Tax Amount3] [numeric](38, 2) NULL,
	[Tax Amount4] [numeric](38, 2) NULL,
	[Tax Amt Base Qty Amount] [numeric](38, 2) NULL,
	[Tax Amt Effect Amount] [numeric](38, 2) NULL,
	[Tax Amt Header Amount] [numeric](38, 2) NULL,
	[Tax Amt LineUnit Amount] [numeric](38, 2) NULL,
	[Tax Amt Qty Percentage] [numeric](38, 2) NULL,
	[Tax Amt Unit Percentage] [numeric](38, 2) NULL,
	[Tax Amt UOM Amount] [numeric](38, 2) NULL,
	[Tax Amt UOM Percentage] [numeric](38, 2) NULL,
	[Tax Type] [tinyint] NULL,
	[TIN Number] [nvarchar](100) NULL,
	[Uom 1 Desc] [nvarchar](100) NULL,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](100) NULL,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](100) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[AmtInWrd] [nvarchar](500) NULL,
	[Product Weight] [numeric](38, 2) NULL,
	[Product UPC] [numeric](38, 0) NULL,
	[SalesInvoice Level Discount] [numeric](38, 6) NULL,
	[SalesInvoice Bill Book No] [nvarchar](100) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-236-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBillTemplateFinal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
		SET @SSQL1='UPDATE Rpt SET Rpt.[Product UPC]=P.ConversionFactor 
					FROM 
					(
						SELECT P.PrdId,P.PrdCCode,MAX(U.ConversionFactor)AS ConversionFactor FROM Product P,UOMGroup U
						WHERE P.UOMGroupId=U.UOMGroupId
						GROUP BY P.PrdId,P.PrdCCode
					) P,RptBillTemplateFinal Rpt WHERE P.PrdCCode=Rpt.[Product Code]'
		EXEC (@SSQL1)
	END
	--->Till Here

	--->Added By Nanda on 2011/04/15 for J&J
	if not exists (Select Id,name from Syscolumns where name = 'SalesInvoice Level Discount' and id in (Select id from 
		Sysobjects where name ='RptBillTemplateFinal'))
	begin
		ALTER TABLE [dbo].[RptBillTemplateFinal]
		ADD [SalesInvoice Level Discount] NUMERIC(38,6) NULL DEFAULT 0 WITH VALUES
	END

	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='SalesInvoice Level Discount')
	BEGIN
		SET @SSQL1='UPDATE Rpt SET Rpt.[SalesInvoice Level Discount]=SI.SalInvLvlDisc
		FROM SalesInvoice SI,RptBillTemplateFinal Rpt WHERE SI.SalId=Rpt.[SalId]'

		EXEC (@SSQL1)
	END
	--->Till Here


	--->Added By Nanda on 2011/05/02 for J&J
	if not exists (Select Id,name from Syscolumns where name = 'SalesInvoice Bill Book No' and id in (Select id from 
		Sysobjects where name ='RptBillTemplateFinal'))
	begin
		ALTER TABLE [dbo].[RptBillTemplateFinal]
		ADD [SalesInvoice Bill Book No] NVARCHAR(100) NULL 
	END

	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='SalesInvoice Bill Book No')
	BEGIN
		SET @SSQL1='UPDATE Rpt SET Rpt.[SalesInvoice Bill Book No]=SI.BillBookNo
		FROM SalesInvoice SI,RptBillTemplateFinal Rpt WHERE SI.SalId=Rpt.[SalId]'

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

	----------------------------------Credit Debit Adjustment
	SELECT @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	IF @Sub_Val = 1
	BEGIN
		INSERT INTO RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		SELECT A.SalId,S.SalInvNo,A.CrNoteNumber,A.CrAdjAmount,A.AdjSoFar,CNR.Remarks,@Pi_UsrId
		FROM SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B,CreditNoteRetailer CNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND CNR.CrNoteNumber=A.CrNoteNumber
		UNION ALL
		SELECT A.SalId,S.SalInvNo,A.DbNoteNumber,A.DbAdjAmount,A.AdjSoFar,DNR.Remarks,@Pi_UsrId
		FROM SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B,DebitNoteRetailer DNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND DNR.DbNoteNumber=A.DbNoteNumber
	END

	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId,
		Rate,MRP,GrossAmount,SchemeAmount,DBDiscAmount,CDAmount,SplDiscAmount,TaxAmount)
		Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId,
		D.PrdUnitSelRte,D.PrdUnitMRP,D.PrdGrossAmt,D.PrdSchDisAmt,D.PrdDBDisAmt,D.PrdCDDisAmt,D.PrdSplDisAmt,D.PrdTaxAmt
		From ReturnHeader H,ReturnProduct D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B
		Where returntype = 1
		and H.ReturnID = D.ReturnID
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId,0,0,0,0,0,0,0,0
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
			[UsrId],[Visibility],[AmtInWrd],[Product Weight],[Product UPC],[SalesInvoice Level Discount],[SalesInvoice Bill Book No]
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
		[UsrId],[Visibility],[AmtInWrd],SUM([Product Weight]),SUM([Product UPC]),[SalesInvoice Level Discount],[SalesInvoice Bill Book No]
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
		[UsrId],[Visibility],[AmtInWrd],[SalesInvoice Level Discount],[SalesInvoice Bill Book No]
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
		[UsrId],[Visibility],[AmtInWrd],[Product Weight],[Product UPC],[SalesInvoice Level Discount],[SalesInvoice Bill Book No]
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-236-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_UpdateFBMSchemeBudget]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_UpdateFBMSchemeBudget]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_UpdateFBMSchemeBudget 45,'SCH1000157',157,'2010-10-09',2,0
--SELECT * FROM FBMTrackIn WHERE PrdId=272
SELECT * FROM FBMSchDetails WHERE SchId=157
SELECT Budget,* FROM SchemeMaster WHERE SchId=157
ROLLBACK TRANSACTION
*/

CREATE	PROCEDURE [dbo].[Proc_UpdateFBMSchemeBudget]
(
	@Pi_TransId		INT,
	@Pi_TransRefNo	NVARCHAR(50),
	@Pi_TransRefId	INT,
	@Pi_TransDate	DATETIME,
	@Pi_UserId		INT,
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_UpdateFBMSchemeBudget
* PURPOSE		: To Track FBM(Free Bonus Merchandise)
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 16/04/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
	IF @Pi_TransId=2 OR @Pi_TransId=7
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
		UNION
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
								
		--->Added By Nanda on 08/10/2010 For PRN 
		IF @Pi_TransId=7
		BEGIN
			UPDATE S SET S.Budget=S.Budget-A.DiscAmt		
			FROM SchemeMaster S,
			(
				SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId =@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
		--->Till Here
	END
	IF @Pi_TransId=3 OR @Pi_TransId=5 OR @Pi_TransId=45
	BEGIN
		
		IF @Pi_TransId=45
		BEGIN
			DELETE FROM FBMSchDetails WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			DELETE FROM FBMSchDetails WHERE SchId=@Pi_TransRefId
			INSERT INTO FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT TransId,TransRefId,TransRefNo,FBMDate,SchId,0,PrdId,DiscAmtOut,1,1,GETDATE(),1,GETDATE()
			FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
			UPDATE S SET S.Budget=A.DiscAmt
			FROM SchemeMaster S,
			(
				SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
				FROM
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId = @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) AA LEFT OUTER JOIN
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (0)
				GROUP BY SchId
				) BB ON AA.SchId=BB.SChId			
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId 
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
		ELSE
		BEGIN
			INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,SUM(F.DiscAmtOut),
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN Product C On B.Prdid = C.PrdId 
			INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
			GROUP BY F.FBMDate,A.SchId,F.SchId,B.PrdId
			UNION
			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,SUM(G.DiscAmtOut),
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
			INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			INNER JOIN ProductBatch F On F.PrdId = E.Prdid
			INNER JOIN FBMTrackIn G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
			GROUP BY G.FBMDate,A.SchId,G.SchId,B.PrdId
			--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
			UPDATE S SET S.Budget=A.DiscAmt
			FROM SchemeMaster S,
			(
				SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
				FROM
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (3,5,45,255,267) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) AA LEFT OUTER JOIN
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (7) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) BB ON AA.SchId=BB.SChId			
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId 
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
	END
	IF @Pi_TransId=255
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,-1*F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
		UNION
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,-1*G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
								
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
			
		UNION
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackIn G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
		--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
		UPDATE S SET S.Budget=A.DiscAmt
		FROM SchemeMaster S,
		(
			SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
			FROM
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (3,5,45,255,267) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) AA LEFT OUTER JOIN
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (7) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) BB ON AA.SchId=BB.SChId			
		) A
		WHERE S.FBM=1 AND S.SchId=A.SchId 
		AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
	END	
	--FBM Adjustments
	IF @Pi_TransId=267
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,-1*F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
			
		UNION
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,-1*G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId										
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
		UNION
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackIn G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
		--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
		UPDATE S SET S.Budget=A.DiscAmt
		FROM SchemeMaster S,
		(
			SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
			FROM
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (3,5,45,255,267) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) AA LEFT OUTER JOIN
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (7) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) BB ON AA.SchId=BB.SChId			
		) A
		WHERE S.FBM=1 AND S.SchId=A.SchId 
		AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
	END
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-236-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme(NOLOCK) WHERE SchId=527
--SELECT * FROM BillAppliedSchemeHd
DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 69,47,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
--SELECT * FROM BillAppliedSchemeHd (NOLOCK)
--SELECT * FROM ApportionSchemeDetails (NOLOCK)
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=522
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM BilledPrdHdForScheme
ROLLBACK TRANSACTION
*/

CREATE        Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
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
* {date} {developer}  {brief modification description}
	
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
	DECLARE @QPSGivenPoints TABLE
	(
		SchId   INT,		
		Points  NUMERIC(38,0)
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
		SELECT '1',* FROM @TempBilled1
	END
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.SumQty),0) AS SchemeOnQty,
			ISNULL(SUM(A.SumValue),0) AS SchemeOnAmount,
			ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(SumInKG),0)
			WHEN 3 THEN ISNULL(SUM(SumInKG),0) END,0) AS SchemeOnKg,
			ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(SumInLitre),0)
			WHEN 5 THEN ISNULL(SUM(SumInLitre),0) END,0) AS SchemeOnLitre,@Pi_SchId
			FROM SalesInvoiceQPSCumulative A (NOLOCK)
			INNER JOIN Product C ON A.PrdId = C.PrdId
			INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
			WHERE A.SchId = @Pi_SchId AND A.RtrId = @Pi_RtrId
			GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
		SELECT '2',* FROM @TempBilled1
--		IF @QPSBasedOn<>1
--		BEGIN
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
--		END
		SELECT '3',* FROM @TempBilled1
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
		SELECT '4',* FROM @TempBilled1
		--NNN
		IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
		BEGIN
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
			SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
				-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
				-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
				FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
				AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
		END
		SELECT '5',* FROM @TempBilled1
--		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
--		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
--			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
	SELECT '6',* FROM @TempBilled1
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
	--->Added By Nanda on 26/11/2010
	DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG=0
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
	SELECT * FROM @TempBilled
--	SELECT 'N',@QPSReset
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
		SELECT @SlabId
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
	--->Added By Boo and Nanda on 29/11/2010
	IF @SchType = 3 AND @QPSReset=1
	--IF @QPSReset=1
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
		SELECT 'New ',* FROM #TemAppQPSSchemes
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here

	--->Added By Nanda on 23/03/2011
	SELECT @SchType
	IF @SchType = 2 AND @QPSReset=1	
	BEGIN
		CREATE TABLE  #TemAppQPSSchemesAmt
		(
			SchId		INT,
			SlabId		INT,
			NoOfTime	INT
		)
		
		DECLARE @NewNoOfTimesAmt AS INT
		DECLARE @NewSlabIdAmt AS INT
		DECLARE @NewTotalValueAmt AS NUMERIC(38,6)
		SET @NewTotalValueAmt=@TotalValue
		SET @NewSlabIdAmt=@SlabId
		WHILE @NewTotalValueAmt>0 AND @NewSlabIdAmt>0
		BEGIN
			SELECT @NewNoOfTimesAmt=FLOOR(@NewTotalValueAmt/(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmt AND SchId=@Pi_SchId
			IF @NewNoOfTimesAmt>0
			BEGIN
				SELECT @NewTotalValueAmt=@NewTotalValueAmt-(@NewNoOfTimesAmt*(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmt AND SchId=@Pi_SchId
				INSERT INTO #TemAppQPSSchemesAmt
				SELECT @Pi_SchId,@NewSlabIdAmt,@NewNoOfTimesAmt
			END
			SET @NewSlabIdAmt=@NewSlabIdAmt-1
		END
		SELECT 'New ',* FROM #TemAppQPSSchemesAmt
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemesAmt B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here

	--->Added By Nanda on 04/05/2011
	IF @SchType = 1 AND @QPSReset=1	
	BEGIN
		CREATE TABLE  #TemAppQPSSchemesQty
		(
			SchId		INT,
			SlabId		INT,
			NoOfTime	INT
		)
		
		DECLARE @NewNoOfTimesQty AS INT
		DECLARE @NewSlabIdAmtQty AS INT
		DECLARE @NewTotalValueQty AS NUMERIC(38,6)
		SET @NewTotalValueQty=@TotalValue
		SET @NewSlabIdAmtQty=@SlabId
		WHILE @NewTotalValueQty>0 AND @NewSlabIdAmtQty>0
		BEGIN
			SELECT @NewNoOfTimesQty=FLOOR(@NewTotalValueQty/(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmtQty AND SchId=@Pi_SchId
			IF @NewNoOfTimesQty>0
			BEGIN
				SELECT @NewTotalValueQty=@NewTotalValueQty-(@NewNoOfTimesQty*(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmtQty AND SchId=@Pi_SchId
				INSERT INTO #TemAppQPSSchemesQty
				SELECT @Pi_SchId,@NewSlabIdAmtQty,@NewNoOfTimesQty
			END
			SET @NewSlabIdAmtQty=@NewSlabIdAmtQty-1
		END
		SELECT 'New ',* FROM #TemAppQPSSchemesQty
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemesQty B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here

--	SELECT 'N',@QPSResetAvail
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
--		SELECT 'SSSS',* FROM @TempBilledAch
		
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
				SELECT @SlabAssginValue
				WHILE @SlabAssginValue > CAST(0 AS NUMERIC(38,6))
				BEGIN
					SET @AssignQty  = 0
					SET @AssignAmount = 0
					SET @AssignKG = 0
					SET @AssignLitre = 0
					SELECT @SlabAssginValue
					SELECT @FrmSchAchRem
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
--				SELECT 'Slab',@SlabAssginValue 
--				SELECT 'Slab',* FROM BillAppliedSchemeHd
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
--					SELECT 'S1',* FROM @TempRedeem
--					SELECT 'S1',* FROM @TempBilledAch
--					SELECT 'S1',* FROM @TempBilledQPSReset
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
		
		--SELECT * FROM @TempRedeem		
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
				--((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
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
	--IF @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillApplied FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillApplied
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime 
		FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
		AND A.SchId=@Pi_SchId
	END
	--->Till Here

	--->Added By Nanda on 23/03/2011
	IF @SchType = 2 AND @QPSReset=1
	--IF @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillAppliedAmt FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillAppliedAmt
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemesAmt B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here

	--->Added By Nanda on 23/03/2011
	IF @SchType = 1 AND @QPSReset=1
	--IF @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillAppliedQty FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillAppliedQty
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemesQty B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here


	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount),SUM(SchemeDiscount),
		SUM(Points),FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,(FreePrdId) as FreePrdId ,
		FreePrdBatId,SUM(FreeToBeGiven),GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven),SUM(NoOfTimes),
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0 FROM @BillAppliedSchemeHd
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId
		,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
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
		AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
			AND SchemeAmount =0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
	END

	SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId

	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId

	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId


	SELECT '111',* FROM BillAppliedSchemeHd 

	INSERT INTO @QPSGivenFlat
	SELECT SchId,SUM(FlatAmount)
	FROM
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId ) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A 
	WHERE SchId=@Pi_SchId GROUP BY A.SchId	
	
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
	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat

	--->Added By Nanda for Points on 10/01/2011  
	INSERT INTO @QPSGivenPoints
	SELECT SchId,SUM(Points)
	FROM
	(
		SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(Points-ReturnPoints,0) AS Points
		FROM SalesInvoiceSchemeDtPoints SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3	
	) A  
	WHERE SchId=@Pi_SchId
	GROUP BY A.SchId	
	--->Till Here

	--->Added By Nanda on 21/02/2011
	UPDATE A SET SchemeAmount=B.SchemeAmount
	FROM BillAppliedSchemeHd A,
	(
		SELECT SchId,SlabId,MAX(SchemeAmount) AS SchemeAmount FROM BillAppliedSchemeHd
		WHERE TransID=@Pi_TransId AND UsrId=@Pi_UsrId
		GROUP BY SchId,SlabId 
	) B
	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId  AND A.SchId=@Pi_SchId
	--->Till Here

	--->For Scheme Amount Update
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

	--->For Scheme Points Update
	UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=CAST(BillAppliedSchemeHd.Points-A.Points AS NUMERIC(38,4))
	FROM @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
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
--				SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHd 
--				WHERE SlabId=@MaxSlabId AND SchId=@MSSchId
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
--			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
--			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
--			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
	
	--->For Points QPS Reset
	SET @MSSchId=0
	SET @MaxSlabId=0
	DECLARE @PointsToReduced AS NUMERIC(38,0)
	SET @PointsToReduced=0
	DECLARE Cur_QPSSlabsPoints CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabsPoints
	FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenPoints WHERE SchId=@MSSchId)
			BEGIN
				SELECT @PointsToReduced=ISNULL(SUM(Points),0) FROM @QPSGivenPoints WHERE SchId=@MSSchId
				UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				
				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId )		
				BEGIN
					SELECT @PointsToReduced=ABS(Points) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
					UPDATE BillAppliedSchemeHd SET Points=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @PointsToReduced=0
				END
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabsPoints
	DEALLOCATE Cur_QPSSlabsPoints
	--->Till Here
	--->Added By Boo for Free Product Calculation For QPS without QPS Reset
	IF @QPS<>0 AND @QPSReset=0 --AND @QPSApplicapple=1
	BEGIN
		UPDATE A SET FreeToBeGiven=FreeToBeGiven-FreeQty,GiftToBeGiven=GiftToBeGiven-GiftQty FROM BillAppliedSchemeHd A INNER JOIN
		(SELECT A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,
		(SUM(A.FreeQty)-SUM(A.ReturnFreeQty)) AS FreeQty,
		(SUM(A.GiftQty)-SUM(A.ReturnGiftQty)) AS GiftQty FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId=B.SalId 
		WHERE A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId AND B.DlvSts>3
		GROUP BY A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId) B ON
		A.SchId=B.SchId AND A.FreePrdId=B.FreePrdId AND	A.GiftPrdId=B.GiftPrdId 
		WHERE A.TransId=@Pi_TransId AND A.Usrid=@Pi_UsrId
	END
	--->Till Here	
	DELETE FROM BillAppliedSchemeHd WHERE ROUND(SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd,3)=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
		IF @FlexiSch=0
		BEGIN
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB 		
		END
		ELSE
		BEGIN
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB WHERE CAST(TB.PrdId AS NVARCHAR(10))+'~'+CAST(TB.PrdBatId AS NVARCHAR(10)) IN
			(SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForScheme)		
			
--			--->For QPS Flexi(Range Based Started with Slab From 1)
--			IF @RangeBase=1
--			BEGIN
--				UPDATE BP SET GrossAmount=GrossAmount+SchemeOnAmount,BaseQty=(BaseQty+SchemeOnQty)
--				FROM BilledPrdHdForQPSScheme BP, 
--				(SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--				-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--				-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre
--				FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--				AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId) A
--				WHERE BP.PrdId=A.PrdId AND BP.PrdBatId=A.PrdBatId AND BP.RowId=10000
--			END
		END
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
	
	SELECT DISTINCT * INTO #Temp_BillAppliedSchemeHd FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TRansId=@Pi_TransId AND SchId=@Pi_SchId
	DELETE FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TRansId=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillAppliedSchemeHd
	SELECT * FROM #Temp_BillAppliedSchemeHd 
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-236-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_PurchaseReceipt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_PurchaseReceipt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PurchaseReceipt 0
--SELECT * FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE CompInvNo='7083240274'--'7083240274'
--SELECT MIN(TransDate) FROM StockLedger
SELECT * FROM ErrorLog
SELECT * FROM ETLTempPurchaseReceipt
SELECT * FROM ETLTempPurchaseReceiptProduct
SELECT * FROM ETLTempPurchaseReceiptPrdLineDt
SELECT * FROM ETLTempPurchaseReceiptClaimScheme
SELECT * FROM ETLTempPurchaseReceiptOtherCharges
SELECT * FROM ETLTempPurchaseReceiptCrDbAdjustments
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_PurchaseReceipt]
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
	DELETE FROM ETLTempPurchaseReceiptCrDbAdjustments WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)	
	DELETE FROM ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1

	TRUNCATE TABLE ETL_Prk_PurchaseReceiptCrDbAdjustments
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptOtherCharges
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
	DECLARE @VatBatch			INT
	DECLARE @BundleDeal			INT

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

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0)	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Qty','Invoice Qty should be gretaer than zero for Product:'+ProductCode+
		' for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0
	END			
	--->Till Here

	--->Added By Nanda on 10/11/2010
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreePurchaseClaim' AND Status=1)
	BEGIN
		IF NOT EXISTS(SELECT * FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
		WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote')
		BEGIN
			INSERT INTO InvToAvoid(CmpInvNo)
			SELECT DISTINCT CompInvNo FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote'
			
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Purchase Receipt',' Debit Note',' Debit Note:'+Prk.RefNo+
			' not adjusted agains claim for Invoice:'+CompInvNo 
			FROM DebitNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='DebitNote'
		END

		IF NOT EXISTS(SELECT * FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
		WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote')
		BEGIN
			INSERT INTO InvToAvoid(CmpInvNo)
			SELECT DISTINCT CompInvNo FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote'
			
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Purchase Receipt','Credit Note',' Credit Note:'+Prk.RefNo+
			' not available for Invoice:'+CompInvNo 
			FROM CreditNoteSupplier DB,Cn2Cs_Prk_PurchaseReceiptAdjustments Prk
			WHERE SUBSTRING(DB.PostedRefNo,4,LEN(DB.PostedRefNo))=Prk.RefNo AND DownLoadFlag='D' AND AdjType='CreditNote'
		END
	END

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE NetValue<=0)
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE NetValue<=0

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','NetValue','NetValue<=0 for Company Invoice No:'+CompInvNo+' ' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE NetValue<=0
	END
	--->Till Here

	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT DISTINCT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,Qty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,ISNULL(VatBatch,0),ISNULL(BundleDeal,0) AS BundleDeal
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	ORDER BY CompInvNo,BundleDeal,ProductCode,BatchNo
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
	@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
	@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@VatBatch,@BundleDeal
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--To insert into ETL_Prk_PurchaseReceiptPrdDt
		IF(@FreeSchemeFlag='0')
		BEGIN
			INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount],[NewPrd])
			VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@Qty*@ListPrice,
			@PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty,@VatBatch)
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
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@VatBatch,@BundleDeal
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase

	--To insert into ETL_Prk_PurchaseReceipt
	SELECT @SupplierCode=SpmCode FROM Supplier WHERE SpmDefault=1
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter)

	--->Added By Nanda on 10/11/2010
	--To insert into ETL_Prk_PurchaseReceiptOtherCharges
	INSERT INTO ETL_Prk_PurchaseReceiptOtherCharges([Company Invoice No],[OC Description],Amount)
	SELECT CompInvNo,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE CompInvNo IN 
	(SELECT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid))
	AND DownLoadFlag='D' AND AdjType='OtherCharges'
	
	--To insert into ETL_Prk_PurchaseReceiptCrDbAdjustement
	INSERT INTO ETL_Prk_PurchaseReceiptCrDbAdjustments([Company Invoice No],[Adjustment Type],[Ref No],[Amount])
	SELECT CompInvNo,AdjType,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE CompInvNo IN 
	(SELECT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid))
	AND DownLoadFlag='D' AND AdjType<>'OtherCharges'
	--->Till Here

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

	--->Added By Nanda on 17/09/2009
	DELETE FROM ETLTempPurchaseReceipt WHERE CmpInvNo NOT IN
	(SELECT DISTINCT CmpInvNo FROM ETLTempPurchaseReceiptProduct)

	UPDATE Cn2Cs_Prk_BLPurchaseReceipt SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceipt)
	--->Till Here

	--->Added By Nanda on 10/11/2010
	UPDATE Cn2Cs_Prk_PurchaseReceiptAdjustments SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceiptOtherCharges)
	AND AdjType='OtherCharges'	

	UPDATE Cn2Cs_Prk_PurchaseReceiptAdjustments SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceiptCrDbAdjustments)
	AND AdjType<>'OtherCharges'
	--->Till Here

	SET @Po_ErrNo= @ErrStatus	
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-236-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportTaxConfigGroupSetting]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportTaxConfigGroupSetting]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec Proc_ImportTaxConfigGroupSetting '<Data></Data>'

CREATE        Procedure [dbo].[Proc_ImportTaxConfigGroupSetting]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportTaxConfigGroupSetting
* PURPOSE	: To Insert records from xml file in the Table Etl_Prk_TaxConfig_GroupSetting
* CREATED	: Mahalakshmi .A
* CREATED DATE	: 02/09/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @hDoc INTEGER
	DELETE FROM Etl_Prk_TaxSetting WHERE DownloadFlag='Y'
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Etl_Prk_TaxSetting(TaxGroupCode,Type,PrdTaxGroupCode,TaxCode,Percentage,ApplyOn,Discount,SchDiscount,DBDiscount,CDDiscount,ApplyTax,DownloadFlag)
	SELECT TaxGroupCode,Type,PrdTaxGroupCode,TaxCode,Percentage,ApplyOn,Discount,SchDiscount,DBDiscount,CDDiscount,ApplyTax,DownloadFlag
	FROM OPENXML (@hdoc,'/Root/Console2CS_TaxSettings',1)
	WITH (
		TaxGroupCode		 NVARCHAR(100),
		Type			     NVARCHAR(100),
		PrdTaxGroupCode		 NVARCHAR(100),
		TaxCode				 NVARCHAR(100),
		Percentage			 NVARCHAR(100),
		ApplyOn				 NVARCHAR(100),
		Discount 			 NVARCHAR(100),
		SchDiscount 		 NVARCHAR(100),
		DBDiscount 			 NVARCHAR(100),
		CDDiscount 			 NVARCHAR(100),
		ApplyTax			 NVARCHAR(100),
		DownLoadFlag		 NVARCHAR(100)
	) XMLObj

	
	EXEC sp_xml_removedocument @hDoc 
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-236-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_VoucherPostingSales]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_VoucherPostingSales]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Proc_VoucherPostingSales]
(
	@Pi_TransId		Int,
	@Pi_SubTransId		Int,
	@Pi_ReferNo		nVarChar(100),
	@Pi_VocType		INT,
	@Pi_SubVocType		INT,	
	@Pi_UserId		Int,
	@Pi_VocDate		DateTime,
	@Po_PurErrNo		Int OutPut
)
AS
/*********************************
* PROCEDURE	: Proc_VoucherPostingSales
* PURPOSE	: General SP for posting Sales Account
* CREATED	: Thrinath
* CREATED DATE	: 26/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
DECLARE @AcmId 		INT
DECLARE @AcpId		INT
DECLARE @CoaId		INT
DECLARE @VocRefNo	nVarChar(100)
DECLARE @sStr		nVarChar(4000)
DECLARE @Amt		Numeric(25,6)
DECLARE @SalRtnId	INT
DECLARE @Cnt		INT
DECLARE @DCoaId		INT
DECLARE @CCoaId		INT
DECLARE @sSql           VARCHAR(4000)
SET @Po_PurErrNo = 1

IF @Pi_TransId = 3 AND @Pi_SubTransId = 1	--Sales Return
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	
	--For Posting Sale Return Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From SalesReturn ' + @Pi_ReferNo +
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'
	
	--For Posting Sales Return Account in Details Table on Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110002')
	BEGIN
		SET @Po_PurErrNo = -19
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110002'
	SELECT  @Amt = SUM(B.PrdActualGross) FROM ReturnHeader A INNER JOIN ReturnProduct B
	ON A.ReturnId=B.ReturnId WHERE A.ReturnCode = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Retailer Account in Details Table to Credit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN ReturnHeader C ON B.RtrId = C.RtrId
		WHERE C.ReturnCode = @Pi_ReferNo)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN ReturnHeader C ON B.RtrId = C.RtrId
		WHERE C.ReturnCode = @Pi_ReferNo
	IF NOT EXISTS (SELECT RtnRoundOff FROM ReturnHeader WHERE ReturnCode = @Pi_ReferNo 
			AND RtnRoundOff=1)
	BEGIN
		SELECT @Amt = SUM(A.PrdNetAmt)+SUM(A.EditedNetRte) FROM ReturnProduct A 
			      INNER JOIN ReturnHeader B ON A.ReturnId=B.ReturnId
			      WHERE B.ReturnCode = @Pi_ReferNo
	END
	ELSE
	BEGIN
		SELECT @Amt = SUM(A.PrdNetAmt)+SUM(A.EditedNetRte) 
					FROM ReturnProduct A 
			      INNER JOIN ReturnHeader B ON A.ReturnId=B.ReturnId
			      WHERE B.ReturnCode = @Pi_ReferNo
		SELECT @Amt=@Amt+RtnRoundOffAmt FROM ReturnHeader 
				WHERE ReturnCode = @Pi_ReferNo
	END
	

	--->Added By Nanda on 11/04/2011 for Invoice Level Discount
	SELECT @Amt=@Amt-ISNULL(RtnInvLvlDisc,0) FROM ReturnHeader WHERE ReturnCode = @Pi_ReferNo

	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)


	--For Posting Sales Invoice Level Discount Account in Details Table On Credit
	--Added By Nanda on 11/04/2011 
	IF EXISTS (SELECT RtnInvLvlDisc FROM ReturnHeader (NOLOCK) WHERE ReturnCode = @Pi_ReferNo AND RtnInvLvlDisc>0)
	BEGIN
		SELECT @Amt=0
		SELECT @CoaId = D.CoaId FROM  ReturnHeader A (NOLOCK) INNER JOIN BillSequenceDetail D (NOLOCK) ON
							D.BillSeqId = A.BillSeqId AND D.RefCode='G' WHERE A.ReturnCode =@Pi_ReferNo

		SELECT @Amt =RtnInvLvlDisc FROM ReturnHeader (NOLOCK) WHERE ReturnCode = @Pi_ReferNo

		IF NOT EXISTS (SELECT CoaId FROM StdVocDetails WHERE CoaId =@CoaId AND VocRefNo=@VocRefNo)
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate)
			SELECT @VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121)
		END
		ELSE
		BEGIN
			UPDATE StdVocDetails SET Amount=Amount+@Amt WHERE CoaId=@CoaId AND VocRefNo=@VocRefNo
		END
	END 
	--Till Here



	--For Posting Sales Return Discount Account in Details Table to Credit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM ReturnHeader A INNER JOIN ReturnHDAmount B ON
			A.ReturnId = B.ReturnId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.ReturnCode = @Pi_ReferNo AND
			B.EffectInNetAmount = 2 AND B.BaseQtyAmount > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',D.CoaId,2,B.BaseQtyAmount,1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		 FROM ReturnHeader A INNER JOIN ReturnHDAmount B ON
			A.ReturnId = B.ReturnId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.ReturnCode = ''' + @Pi_ReferNo + ''' AND
			B.EffectInNetAmount = 2 AND B.BaseQtyAmount > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Sales Return Addition in Details Table to Debit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,D.CoaId,1,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM ReturnHeader A INNER JOIN ReturnHDAmount B ON
			A.ReturnId = B.ReturnId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.ReturnCode = @Pi_ReferNo AND B.RefCode <> 'H' AND
			B.EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',D.CoaId,1,B.BaseQtyAmount,1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		 FROM ReturnHeader A INNER JOIN ReturnHDAmount B ON
			A.ReturnId = B.ReturnId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.ReturnCode = ''' + @Pi_ReferNo + ''' AND B.RefCode <> ''' + 'H' + ''' AND
			B.EffectInNetAmount = 1 AND B.BaseQtyAmount > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Sales Return Tax Account in Details Table on Debit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,C.OutPutTaxId,1,ISNULL(SUM(B.TaxAmt),0),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM ReturnHeader A INNER JOIN ReturnProductTax B ON
			A.ReturnId = B.ReturnId
		INNER JOIN TaxConfiguration C ON
			B.TaxId = C.TaxId
		WHERE A.ReturnCode = @Pi_ReferNo
		Group By C.OutPutTaxId
		HAVING ISNULL(SUM(B.TaxAmt),0) > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',C.OutPutTaxId,1,ISNULL(SUM(B.TaxAmt),0),1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		FROM ReturnHeader A INNER JOIN ReturnProductTax B ON
			A.ReturnId = B.ReturnId
		INNER JOIN TaxConfiguration C ON
			B.TaxId = C.TaxId
		WHERE A.ReturnCode = ''' + @Pi_ReferNo + '''
		Group By C.OutPutTaxId
		HAVING ISNULL(SUM(B.TaxAmt),0) > 0'
	
	-- Posting the Selling Rate and Net Rate Difference
	SET @Amt = 0
	SELECT @SalRtnId= ReturnId FROM ReturnHeader WHERE ReturnCode=@Pi_ReferNo
	SET @SalRtnId = ISNULL(@SalRtnId,0)
	SELECT @Amt=SUM(RateDiff) FROM 
	(SELECT CASE  WHEN Slno > 0 THEN PrdRateDiffAmt + EditedNetRte WHEN Slno<0 THEN PrdRateDiffAmt + EditedNetRte  END AS RateDiff
	FROM ReturnProduct WHERE ReturnId = @SalRtnId)a
	HAVING SUM(RateDiff) <> 0
	
	IF @Amt < 0
	BEGIN
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210003')
		BEGIN
			SET @Po_PurErrNo = -15
			Return
		END
	
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210003'
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	IF @Amt > 0
	BEGIN
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220007')
		BEGIN
			SET @Po_PurErrNo = -16
			Return
		END
	
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4220007'
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	--For Posting Round Off Account reduce in Details Table to Credit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3220001')
	BEGIN
		SET @Po_PurErrNo = -4
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3220001'
	SET @Amt = 0
	SELECT @Amt = RtnRoundoffAmt FROM ReturnHeader WHERE ReturnCode = @Pi_ReferNo
		AND RtnRoundOffAmt > 0
	
	IF @Amt > 0
	BEGIN
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,Abs(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(Abs(@Amt) As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	--For Posting Round Off Account Add in Details Table to Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4210001')
	BEGIN
		SET @Po_PurErrNo = -5
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4210001'
	SET @Amt = 0
	SELECT @Amt = RtnRoundoffAmt FROM ReturnHeader WHERE ReturnCode = @Pi_ReferNo
		AND RtnRoundOffAmt < 0
	
	IF @Amt < 0
	BEGIN
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(ABS(@Amt) As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	--For Posting Round Off Account Add in Details Table to Debit
	SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
	IF @sSql='-4'
	BEGIN
		SET @Po_PurErrNo = -4
		Return
	END
	ELSE IF @sSql='-5'
	BEGIN
		SET @Po_PurErrNo = -5
		Return
	END
	ELSE IF @sSql<>'0'
	BEGIN
		EXEC(@sSql)
	END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END
IF @Pi_TransId=24		--Return And Replacement
BEGIN
	IF @Pi_SubTransId=1	--Return
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		--For Posting Return Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Return & Replacement - Return '
			+ @Pi_ReferNo + ' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
	
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'
			
		--For Posting Sales Return Account in Details Table on Debit
	
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110002')
		BEGIN
			SET @Po_PurErrNo = -19
			Return
		END
	
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110002'
	
		SELECT @Amt = ROUND(SUM(RtnQty*SelRte),2) FROM ReplacementIn WHERE RepRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)		
	
		--For Posting Input Tax in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,C.OutputTaxId,1,ROUND(ISNULL(SUM(B.TaxAmount),0),2),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM ReplacementHd A INNER JOIN ReplacementInPrdTax B ON A.RepRefNo = B.RepRefNo
			INNER JOIN TaxConfiguration C ON B.TaxId = C.TaxId
			WHERE A.RepRefNo = @Pi_ReferNo Group By C.OutputTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',C.OutputTaxId,1,ISNULL(SUM(B.TaxAmount),0),1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			FROM ReplacementHd A INNER JOIN ReplacementInPrdTax B ON A.RepRefNo = B.RepRefNo
			INNER JOIN TaxConfiguration C ON B.TaxId = C.TaxId
			WHERE A.RepRefNo = ''' + @Pi_ReferNo + '''Group By C.OutputTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)				
	
		--For Posting Retailer Account in Details Table to Credit
	
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
			A.CoaId = B.CoaId INNER JOIN ReplacementHd C ON B.RtrId = C.RtrId
			WHERE C.RepRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -13
			Return
		END
	
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
			A.CoaId = B.CoaId INNER JOIN ReplacementHd C ON B.RtrId = C.RtrId
			WHERE C.RepRefNo = @Pi_ReferNo
	
		SELECT @Amt = ROUND(SUM(RtnAmount),2) FROM ReplacementIn WHERE RepRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	
		--Validate Credit amount is Equal to Debit
		
			SELECT DebitCredit,Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo
		
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	
	END
	ELSE IF @Pi_SubTransId=2	--Replacement
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
	
		--For Posting Replacement Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Return and Replacement - Replacement '
			+ @Pi_ReferNo + ' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'
	
		--For Posting Replacement Account in Details Table on Credit
	
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110001')
		BEGIN
			SET @Po_PurErrNo = -17
			Return
		END
	
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110001'
	
		SELECT @Amt = ROUND(SUM(RepQty*SelRte),2) FROM ReplacementOut WHERE RepRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Output Tax in Details Table on Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,C.OutputTaxId,2,ROUND(ISNULL(SUM(B.TaxAmount),0),2),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM ReplacementHd A INNER JOIN ReplacementOutPrdTax B ON A.RepRefNo = B.RepRefNo
			INNER JOIN TaxConfiguration C ON B.TaxId = C.TaxId
			WHERE A.RepRefNo = @Pi_ReferNo Group By C.OutputTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',C.OutputTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			FROM ReplacementHd A INNER JOIN ReplacementOutPrdTax B ON A.RepRefNo = B.RepRefNo
			INNER JOIN TaxConfiguration C ON B.TaxId = C.TaxId
			WHERE A.RepRefNo = ''' + @Pi_ReferNo + '''Group By C.OutputTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)		
	
		--For Posting Retailer Account in Details Table to Debit
	
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
			A.CoaId = B.CoaId INNER JOIN ReplacementHd C ON B.RtrId = C.RtrId
			WHERE C.RepRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -13
			Return
		END
	
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
			A.CoaId = B.CoaId INNER JOIN ReplacementHd C ON B.RtrId = C.RtrId
			WHERE C.RepRefNo = @Pi_ReferNo
	
		SELECT @Amt = ROUND(SUM(RepAmount),2) FROM ReplacementOut WHERE RepRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END	
		
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END
END	
IF @Pi_TransId = 29 AND @Pi_SubTransId = 1	--Sales Voucher
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE CONVERT(nVarChar(10),@Pi_VocDate,121) between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	--For Posting Sales Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,CONVERT(nVarChar(10),@Pi_VocDate,121),'Posted From Billing ' + @Pi_ReferNo +
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'

	SELECT @Pi_VocDate=Salinvdate FROM Salesinvoice (NOLOCK) WHERE SalInvNo = @Pi_ReferNo
	

	--For Posting Retailer Account in Details Table on Debit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN SalesInvoice C ON B.RtrId = C.RtrId
		WHERE C.SalInvNo = @Pi_ReferNo)-- AND C.SalInvDate = Convert(varchar(10),@Pi_VocDate,121))
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN SalesInvoice C ON B.RtrId = C.RtrId
		WHERE C.SalInvNo = @Pi_ReferNo --AND C.SalInvDate = Convert(varchar(10),@Pi_VocDate,121)
	SELECT @Amt = (SalNetAmt + OnAccountAmount + MarketRetAmount + CrAdjAmount -
		ReplacementDiffAmount - DBAdjAmount) FROM SalesInvoice Where SalInvNo = @Pi_ReferNo AND SalInvDate = Convert(varchar(10),@Pi_VocDate,121)
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Sales Account in Details Table on Credit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110001')
	BEGIN
		SET @Po_PurErrNo = -17
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110001'
	SELECT @Amt = SUM(PrdGrossAmount) FROM SalesInvoiceProduct WHERE SalId IN 
	(SELECT SalId FROM SalesInvoice Where SalInvNo = @Pi_ReferNo AND SalInvDate = Convert(varchar(10),@Pi_VocDate,121))
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Sales Discount Account in Details Table On Debit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,D.CoaId,1,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM SalesInvoice A INNER JOIN SalesInvoiceHdAmount B ON
			A.SalId = B.SalId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.SalInvNo = @Pi_ReferNo AND A.SalInvDate = Convert(varchar(10),@Pi_VocDate,121) AND 
			EffectInNetAmount = 2 AND B.BaseQtyAmount > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',D.CoaId,1,B.BaseQtyAmount,1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		 FROM SalesInvoice A INNER JOIN SalesInvoiceHdAmount B ON
			A.SalId = B.SalId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.SalInvNo = ''' + @Pi_ReferNo + ''' AND A.SalInvDate = ''' + Convert(varchar(10),@Pi_VocDate,121) + ''' AND
			EffectInNetAmount = 2 AND B.BaseQtyAmount > 0'


	--For Posting Sales Invoice Level Discount Account in Details Table On Debit
	--Added By Mary on 24/06/2009 
	IF EXISTS (SELECT SalInvLvlDisc FROM SalesInvoice (NOLOCK) WHERE SalInvNo = @Pi_ReferNo AND SalInvLvlDisc>0)
	BEGIN
		SELECT @Amt=0
		SELECT @CoaId = D.CoaId FROM  SalesInvoice A (NOLOCK) INNER JOIN BillSequenceDetail D (NOLOCK) ON
							D.BillSeqId = A.BillSeqId AND D.RefCode='G' WHERE A.SalInvNo =@Pi_ReferNo
		SELECT @Amt =SalInvLvlDisc FROM SalesInvoice (NOLOCK) WHERE SalInvNo = @Pi_ReferNo
		IF NOT EXISTS (SELECT CoaId FROM StdVocDetails WHERE CoaId =@CoaId AND VocRefNo=@VocRefNo)
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate)
			SELECT @VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121)
		END
		ELSE
		BEGIN
			UPDATE StdVocDetails SET Amount=Amount+@Amt WHERE CoaId=@CoaId AND VocRefNo=@VocRefNo
		END
	END 
	--Till Here


	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Addition Account in Details Table To Credit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM SalesInvoice A INNER JOIN SalesInvoiceHdAmount B ON
			A.SalId = B.SalId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.SalInvNo = @Pi_ReferNo AND A.SalInvDate = Convert(varchar(10),@Pi_VocDate,121) AND D.RefCode <> 'H' AND
			EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',D.CoaId,2,B.BaseQtyAmount,1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		 FROM SalesInvoice A INNER JOIN SalesInvoiceHdAmount B ON
			A.SalId = B.SalId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.SalInvNo = ''' + @Pi_ReferNo + ''' AND A.SalInvDate = ''' + Convert(varchar(10),@Pi_VocDate,121) + ''' AND D.RefCode <> ''H'' AND
			EffectInNetAmount = 1 AND B.BaseQtyAmount > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Sales Tax Account in Details Table To Credit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,C.OutputTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM SalesInvoice A INNER JOIN SalesInvoiceProductTax B ON
			A.SalId = B.SalId
		INNER JOIN TaxConfiguration C ON
			B.TaxId = C.TaxId
		WHERE A.SalInvNo = @Pi_ReferNo AND A.SalInvDate = Convert(varchar(10),@Pi_VocDate,121)
		Group By C.OutputTaxId
		HAVING ISNULL(SUM(B.TaxAmount),0) > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',C.OutputTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		FROM SalesInvoice A INNER JOIN SalesInvoiceProductTax B ON
			A.SalId = B.SalId
		INNER JOIN TaxConfiguration C ON
			B.TaxId = C.TaxId
		WHERE A.SalInvNo = ''' + @Pi_ReferNo + ''' AND A.SalInvDate = ''' + Convert(varchar(10),@Pi_VocDate,121) + '''
		Group By C.OutputTaxId
		HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Window Display Scheme Discount in Details Table to Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220005')
	BEGIN
		SET @Po_PurErrNo = -14
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4220005'
	SET @Amt = 0
	SELECT @Amt = WindowDisplayAmount FROM SalesInvoice WHERE Salinvno = @Pi_ReferNo AND SalInvDate = Convert(varchar(10),@Pi_VocDate,121)
		AND WindowDisplayAmount > 0
	
	IF @Amt > 0
	BEGIN
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	--For Posting Rate Difference Amount in Details Table Amount > 0 Debit and < 0 Credit
	SET @Amt = 0
	SELECT @Amt = (SalNetRateDiffAmount+SalRateDiffAmount) FROM SalesInvoice
		WHERE Salinvno = @Pi_ReferNo AND SalInvDate = Convert(varchar(10),@Pi_VocDate,121) AND (SalNetRateDiffAmount+SalRateDiffAmount) <> 0
	
	IF @Amt > 0
	BEGIN
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220007')
		BEGIN
			SET @Po_PurErrNo = -16
			Return
		END
	
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4220007'
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	-- Posting the Selling Rate and Net Rate Difference
	--SET @Amt = 0
	--SELECT @SalRtnId= ReturnId FROM ReturnHeader WHERE ReturnCode=@Pi_ReferNo
	--SET @SalRtnId = ISNULL(@SalRtnId,0)
	--SELECT @Amt=SUM(RateDiff) FROM 
	--(SELECT CASE  WHEN Slno > 0 THEN PrdRateDiffAmt + EditedNetRte WHEN Slno<0 THEN PrdRateDiffAmt + EditedNetRte  END AS RateDiff
	--FROM ReturnProduct WHERE ReturnId = @SalRtnId)a
	--HAVING SUM(RateDiff) <> 0
	IF @Amt < 0
	BEGIN
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210003')
		BEGIN
			SET @Po_PurErrNo = -15
			Return
		END
	
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210003'
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(ABS(@Amt) As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	--For Posting Other Charges Add in Details Table For Credit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,C.CoaId,1,ISNULL(SUM(B.AdjAmt),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM SalesInvoice A INNER JOIN SalInvOtherAdj B ON
			A.SalId = B.SalId INNER JOIN PurSalAccConfig C
			ON C.AccDescId = B.AccDescId AND C.TransactionId=2
		WHERE A.SalInvno = @Pi_ReferNo AND A.SalInvDate = @Pi_VocDate AND C.Effect = 0
		Group By C.CoaId
		HAVING ISNULL(SUM(B.AdjAmt),0) > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',C.CoaId,1,ISNULL(SUM(B.AdjAmt),0),1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		FROM SalesInvoice A INNER JOIN SalInvOtherAdj B ON
			A.SalId = B.SalId INNER JOIN PurSalAccConfig C
			ON C.AccDescId = B.AccDescId AND C.TransactionId=2
		WHERE A.SalInvno = ''' + @Pi_ReferNo + ''' AND A.SalInvDate = ''' + Convert(varchar(10),@Pi_VocDate,121)  + ''' AND C.Effect = 0
		Group By C.CoaId
		HAVING ISNULL(SUM(B.AdjAmt),0) > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Other Charges Reduce in Details Table To Debit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,C.CoaId,2,ISNULL(SUM(B.AdjAmt),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM SalesInvoice A INNER JOIN SalInvOtherAdj B ON
			A.SalId = B.SalId INNER JOIN PurSalAccConfig C
			ON C.AccDescId = B.AccDescId AND C.TransactionId=2
		WHERE A.SalInvno = @Pi_ReferNo AND A.SalInvDate = Convert(varchar(10),@Pi_VocDate,121) AND C.Effect = 1
		Group By C.CoaId
		HAVING ISNULL(SUM(B.AdjAmt),0) > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',C.CoaId,2,ISNULL(SUM(B.AdjAmt),0),1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		FROM SalesInvoice A INNER JOIN SalInvOtherAdj B ON
			A.SalId = B.SalId INNER JOIN PurSalAccConfig C
			ON C.AccDescId = B.AccDescId AND C.TransactionId=2
		WHERE A.SalInvno = ''' + @Pi_ReferNo + ''' AND A.SalInvDate = ''' + Convert(varchar(10),@Pi_VocDate,121) + ''' AND C.Effect = 1
		Group By C.CoaId
		HAVING ISNULL(SUM(B.AdjAmt),0) > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account reduce in Details Table to Credit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3220001')
	BEGIN
		SET @Po_PurErrNo = -4
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3220001'
	SET @Amt = 0
	SELECT @Amt = SalRoundoffAmt FROM SalesInvoice WHERE SalInvno = @Pi_ReferNo AND SalInvDate = Convert(varchar(10),@Pi_VocDate,121)
		AND SalRoundoffAmt > 0
	
	IF @Amt > 0
	BEGIN
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,Abs(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(Abs(@Amt) As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	--For Posting Round Off Account Add in Details Table to Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4210001')
	BEGIN
		SET @Po_PurErrNo = -5
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4210001'
	SET @Amt = 0
	SELECT @Amt = SalRoundoffAmt FROM SalesInvoice WHERE SalInvno = @Pi_ReferNo AND 
	SalInvDate = Convert(varchar(10),@Pi_VocDate,121)
		AND SalRoundoffAmt < 0
	
	IF @Amt < 0
	BEGIN
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(ABS(@Amt) As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END
IF @Pi_TransId = 29 AND @Pi_SubTransId = 3	--Market Return
BEGIN
	
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	
	--For Posting Sale Return Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Market Return ' + @Pi_ReferNo +
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'
	
	--For Posting Sales Return Account in Details Table on Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110002')
	BEGIN
		SET @Po_PurErrNo = -19
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110002'
	SELECT @Pi_ReferNo = ReturnCode FROM ReturnHeader A INNER JOIN
		SalesInvoiceMarketReturn B ON B.ReturnId = A.ReturnId
		INNER JOIN SalesInvoice C ON B.SalId = C.SalId AND C.SalInvNo = @Pi_ReferNo
	SELECT @Amt = SUM(B.PrdActualGross) FROM ReturnHeader A INNER JOIN ReturnProduct B
	ON A.ReturnId=B.ReturnId WHERE A.ReturnCode = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Retailer Account in Details Table to Credit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN ReturnHeader C ON B.RtrId = C.RtrId
		WHERE C.ReturnCode = @Pi_ReferNo)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
--------	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
--------		A.CoaId = B.CoaId INNER JOIN ReturnHeader C ON B.RtrId = C.RtrId
--------		WHERE C.ReturnCode = @Pi_ReferNo
--------
--------	SELECT @Amt = SUM(A.PrdNetAmt)+SUM(A.EditedNetRte) FROM ReturnProduct A 
--------	      INNER JOIN ReturnHeader B ON A.ReturnId=B.ReturnId
--------	      WHERE B.ReturnCode = @Pi_ReferNo
	
SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN ReturnHeader C ON B.RtrId = C.RtrId
		WHERE C.ReturnCode = @Pi_ReferNo
	IF NOT EXISTS (SELECT RtnRoundOff FROM ReturnHeader WHERE ReturnCode = @Pi_ReferNo 
			AND RtnRoundOff=1)
	BEGIN
		SELECT @Amt = SUM(A.PrdNetAmt)+SUM(A.EditedNetRte) FROM ReturnProduct A 
			      INNER JOIN ReturnHeader B ON A.ReturnId=B.ReturnId
			      WHERE B.ReturnCode = @Pi_ReferNo
	END
	ELSE
	BEGIN
		SELECT @Amt = SUM(A.PrdNetAmt)+SUM(A.EditedNetRte) 
					FROM ReturnProduct A 
			      INNER JOIN ReturnHeader B ON A.ReturnId=B.ReturnId
			      WHERE B.ReturnCode = @Pi_ReferNo
		SELECT @Amt=@Amt+RtnRoundOffAmt FROM ReturnHeader 
				WHERE ReturnCode = @Pi_ReferNo
	END 
--Till here
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Sales Return Discount Account in Details Table to Credit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM ReturnHeader A INNER JOIN ReturnHDAmount B ON
			A.ReturnId = B.ReturnId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.ReturnCode = @Pi_ReferNo AND
			B.EffectInNetAmount = 2 AND B.BaseQtyAmount > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',D.CoaId,2,B.BaseQtyAmount,1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		 FROM ReturnHeader A INNER JOIN ReturnHDAmount B ON
			A.ReturnId = B.ReturnId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.ReturnCode = ''' + @Pi_ReferNo + ''' AND
			B.EffectInNetAmount = 2 AND B.BaseQtyAmount > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Sales Return Addition in Details Table to Debit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,D.CoaId,1,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM ReturnHeader A INNER JOIN ReturnHDAmount B ON
			A.ReturnId = B.ReturnId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.ReturnCode = @Pi_ReferNo AND B.RefCode <> 'H' AND
			B.EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',D.CoaId,1,B.BaseQtyAmount,1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		 FROM ReturnHeader A INNER JOIN ReturnHDAmount B ON
			A.ReturnId = B.ReturnId
		INNER JOIN BillSequenceMaster C ON
			A.BillSeqId = C.BillSeqId
		INNER JOIN BillSequenceDetail D ON
			C.BillSeqId = D.BillSeqId AND B.RefCode = D.RefCode
		WHERE A.ReturnCode = ''' + @Pi_ReferNo + ''' AND B.RefCode <> ''' + 'H' + ''' AND
			B.EffectInNetAmount = 1 AND B.BaseQtyAmount > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Sales Return Tax Account in Details Table on Debit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,C.OutPutTaxId,1,ISNULL(SUM(B.TaxAmt),0),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM ReturnHeader A INNER JOIN ReturnProductTax B ON
			A.ReturnId = B.ReturnId
		INNER JOIN TaxConfiguration C ON
			B.TaxId = C.TaxId
		WHERE A.ReturnCode = @Pi_ReferNo
		Group By C.OutPutTaxId
		HAVING ISNULL(SUM(B.TaxAmt),0) > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',C.OutPutTaxId,1,ISNULL(SUM(B.TaxAmt),0),1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		FROM ReturnHeader A INNER JOIN ReturnProductTax B ON
			A.ReturnId = B.ReturnId
		INNER JOIN TaxConfiguration C ON
			B.TaxId = C.TaxId
		WHERE A.ReturnCode = ''' + @Pi_ReferNo + '''
		Group By C.OutPutTaxId
		HAVING ISNULL(SUM(B.TaxAmt),0) > 0'
	
	--For Posting Rate Diff Discount allowed in Details Table on Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220007')
	BEGIN
		SET @Po_PurErrNo = -19
		Return
	END
-- 	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4220007'
-- 	IF @Amt>0
-- 	BEGIN
-- 		SELECT  @Amt =  SUM(B.PrdRateDiffAmt) FROM ReturnHeader A INNER JOIN ReturnProduct B
-- 		ON A.ReturnId=B.ReturnId WHERE A.ReturnCode = @Pi_ReferNo
-- 		
-- 		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
-- 			LastModDate,AuthId,AuthDate) VALUES
-- 		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
-- 			@Pi_UserId,Convert(varchar(10),Getdate(),121))
-- 	
-- 		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
-- 			LastModDate,AuthId,AuthDate) VALUES
-- 		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
-- 			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
-- 			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
-- 			Convert(nvarchar(10),Getdate(),121) + ''')'
-- 	
-- 		--INSERT INTO Translog(strSql1) Values (@sstr)
-- 	END
	-- Posting the Selling Rate and Net Rate Difference
	SET @Amt = 0
	SELECT @SalRtnId= ReturnId FROM ReturnHeader WHERE ReturnCode=@Pi_ReferNo
	SET @SalRtnId = ISNULL(@SalRtnId,0)
-- 	SELECT SUM(RateDiff) FROM 
-- 	(SELECT CASE  WHEN Slno > 0 THEN PrdRateDiffAmt WHEN Slno<0 THEN PrdRateDiffAmt END AS RateDiff
-- 	FROM ReturnProduct WHERE ReturnId = 28)a
-- 	HAVING SUM(RateDiff) <> 0
	PRINT @SalRtnId
	SELECT @Amt=SUM(RateDiff) FROM 
	(SELECT CASE  WHEN Slno > 0 THEN PrdRateDiffAmt+EditedNetRte WHEN Slno<0 THEN PrdRateDiffAmt+EditedNetRte  END AS RateDiff
	FROM ReturnProduct WHERE ReturnId = @SalRtnId)a
	HAVING SUM(RateDiff) <> 0
-- 	SELECT @Amt = SUM(PrdRateDiffAmt) FROM ReturnProduct
-- 		WHERE ReturnId = @SalRtnId
-- 		HAVING SUM(PrdRateDiffAmt)<> 0
	
	IF @Amt < 0
	BEGIN
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210003')
		BEGIN
			SET @Po_PurErrNo = -15
			Return
		END
	PRINT @Amt
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210003'
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	IF @Amt > 0
	BEGIN
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220007')
		BEGIN
			SET @Po_PurErrNo = -16
			Return
		END
	
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4220007'
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
	END
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END
IF @Pi_TransId=29 AND @Pi_SubTransId =4	--Return And Replacement
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	--For Posting Replacement Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Billing - Replacement '
		+ @Pi_ReferNo + ' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'
	
	--For Posting Replacement Account in Details Table on Credit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110001')
	BEGIN
		SET @Po_PurErrNo = -17
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110001'
	SELECT @Amt = ReplacementDiffAmount FROM SalesInvoice WHERE SalInvno = @Pi_ReferNo
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	
	--For Posting Retailer Account in Details Table to Debit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN SalesInvoice C ON B.RtrId = C.RtrId
		WHERE C.SalInvno = @Pi_ReferNo)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN SalesInvoice C ON B.RtrId = C.RtrId
		WHERE C.SalInvno = @Pi_ReferNo
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)	
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END	
IF @Pi_TransId=29 AND @Pi_SubTransId=5		--Return And Replacement
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	--For Posting Replacement Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Billing - Replacement '
		+ @Pi_ReferNo + ' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'
	
	--For Posting Replacement Account in Details Table on Credit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110002')
	BEGIN
		SET @Po_PurErrNo = -19
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110002'
	SELECT @Amt = ReplacementDiffAmount FROM SalesInvoice WHERE SalInvno = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Retailer Account in Details Table to Debit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN SalesInvoice C ON B.RtrId = C.RtrId
		WHERE C.SalInvno = @Pi_ReferNo)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN SalesInvoice C ON B.RtrId = C.RtrId
		WHERE C.SalInvno = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)	
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END	
IF @Pi_TransId=29 AND @Pi_SubTransId=7		--Replacement Debit Entry
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	--For Posting Replacement Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Billing - Replacement '
		+ @Pi_ReferNo + ' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'
	
	--For Posting Replacement Account in Details Table on Credit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110001')
	BEGIN
		SET @Po_PurErrNo = -17
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110001'
	SELECT @Amt = SUM(RepQty*SelRte) FROM ReplacementOut WHERE RepRefNo = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Output Tax in Details Table on Credit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT @VocRefNo,C.OutputTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
		FROM ReplacementHd A INNER JOIN ReplacementOutPrdTax B ON A.RepRefNo = B.RepRefNo
		INNER JOIN TaxConfiguration C ON B.TaxId = C.TaxId
		WHERE A.RepRefNo = @Pi_ReferNo Group By C.OutputTaxId
		HAVING ISNULL(SUM(B.TaxAmount),0) > 0
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT ''' + @VocRefNo + ''',C.OutputTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,' +
		CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		FROM ReplacementHd A INNER JOIN ReplacementOutPrdTax B ON A.RepRefNo = B.RepRefNo
		INNER JOIN TaxConfiguration C ON B.TaxId = C.TaxId
		WHERE A.RepRefNo = ''' + @Pi_ReferNo + '''Group By C.OutputTaxId
		HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
	--INSERT INTO Translog(strSql1) Values (@sstr)		
	--For Posting Retailer Account in Details Table to Debit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN ReplacementHd C ON B.RtrId = C.RtrId
		WHERE C.RepRefNo = @Pi_ReferNo)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN ReplacementHd C ON B.RtrId = C.RtrId
		WHERE C.RepRefNo = @Pi_ReferNo
	SELECT @Amt = SUM(RepAmount) FROM ReplacementOut WHERE RepRefNo = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)	
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END
IF @Pi_TransId=31		--Resell damage goods
BEGIN
	IF @Pi_SubTransId=1	
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','SalesVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		--For Posting Resell damage goods Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Resell damage goods'
			+ @Pi_ReferNo + ' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
		
	
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='SalesVoc'
	
		
		--For Posting Sales Resell damage goods Account in Details Table on Debit
	
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3110003')
		BEGIN
			SET @Po_PurErrNo = -23
			Return
		END	
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3110003'
	
		SELECT @Amt = DbAmt FROM ReSellDamageMaster WHERE ReDamRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)						
	
		--For Posting Retailer Account in Details Table to Credit
	
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
			A.CoaId = B.CoaId INNER JOIN ReSellDamageMaster C ON B.RtrId = C.RtrId
			WHERE C.ReDamRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -13
			Return
		END
	
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
			A.CoaId = B.CoaId INNER JOIN ReSellDamageMaster C ON B.RtrId = C.RtrId
			WHERE C.ReDamRefNo = @Pi_ReferNo
	
		SELECT @Amt = DbAmt FROM ReSellDamageMaster WHERE ReDamRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	
	END
	
END
IF @Po_PurErrNo=1
BEGIN
		EXEC Proc_PostStdDetails @Pi_VocDate,@VocRefNo,1
END
Return
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-236-012-From Boo

IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='Track_RtrCategoryandClassChange')
CREATE TABLE Track_RtrCategoryandClassChange
(
	TransIdentity	BIGINT,
	RtrId			BIGINT,
	OldCtgLevelId	BIGINT,
	OldCtgManinId	BIGINT,
	OldRtrClassId	BIGINT,
	NewCtgLevelId	BIGINT,
	NewCtgManinId	BIGINT,
	NewRtrClassId	BIGINT,
	ShiftDate		DATETIME,
	ShiftTime		DATETIME,
	TransId			INT
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_UpdateRetailerClassShift')
DROP PROCEDURE Proc_UpdateRetailerClassShift
GO
--EXEC Proc_UpdateRetailerClassShift 1
--SELECT * FROM RetailerValueClassMap
--SELECT * FROM AutoRetailerClassShift

CREATE      Proc [dbo].[Proc_UpdateRetailerClassShift]
(
	@Pi_UsrId INT
)
AS
/************************************************************
* VIEW	: [Proc_UpdateRetailerClassShift]
* PURPOSE	: To Update Retailer Class Values
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 19/04/2010
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NoOfMonths AS INT 
	DECLARE @CmpId AS INT 
	DECLARE @GrossorNet AS INT 
	DECLARE @Return AS INT 
	DECLARE @FromDate AS DATETIME 
	DECLARE @ToDate AS DATETIME 
	DECLARE @RtrClassId AS INT
	DECLARE @OldRtrClassId AS INT
	DECLARE @RtrId AS INT 
	DECLARE @Amount AS INT 
	DECLARE @CtgMainId AS INT 
	DECLARE @MaxAmount AS NUMERIC(38,2)
	DECLARE @MinAmount AS NUMERIC(38,2)
	DECLARE @MaxRtrClassId AS INT
	DECLARE @MinRtrClassId AS INT
	SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
	DECLARE @RetailerClassShift  TABLE
	(
		RtrId INT,
		SalesGrossAmount NUMERIC(38,6),
		SalesNetAmount NUMERIC(38,6),
		SalesRtnGrossAmount NUMERIC(38,6),
		SalesRtnNetAmount NUMERIC(38,6),
		RtrValueClassId INT,
		TurnOver NUMERIC(38,6),
		RtrClassId  INT ,
		CtgMainId INT ,
		CtgLevelId INT,
		NewClassId INT
	)
	DECLARE @RetailerNewClass TABLE
	(
		RtrId INT,
		Amount NUMERIC(38,6),
		CtgMainId INT
	)
	IF NOT EXISTS (SELECT *  FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS2' AND Status=1)
	BEGIN
		SET @NoOfMonths=-3
	END
	ELSE
	BEGIN
		SELECT @NoOfMonths=(-1)*CAST(ConfigValue AS INT) FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS2'
	END 
	SET @FromDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	SET @FromDate=CONVERT(NVARCHAR(10),DATEADD(M,@NoOfMonths,GETDATE()),121)
	SET @ToDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	
	IF NOT EXISTS (SELECT *  FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS3' AND Status=1)
	BEGIN
		SET @GrossorNet=0
	END
	ELSE
	BEGIN
		SELECT @GrossorNet=ConfigValue FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS3'
	END 
	IF NOT EXISTS (SELECT *  FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS4' AND Status=1)
	BEGIN
		SET @Return=0
	END
	ELSE
	BEGIN
		SET @Return=1
	END
	INSERT INTO @RetailerClassShift (RtrId,SalesGrossAmount,SalesNetAmount,SalesRtnGrossAmount,
		SalesRtnNetAmount,RtrValueClassId,TurnOver,RtrClassId,CtgMainId,CtgLevelId,NewClassId)
			
	SELECT RtrId,SUM(GrossAmount),SUM(NetAmount),SUM(ReturnGrossAmt),SUM(ReturnNetAmt),
		RtrValueClassId,Turnover,RtrClassId,CtgMainId,CtgLevelId,NewClassId
	FROM (
	SELECT SI.RtrId,SUM(SI.SalGrossAmount) AS GrossAmount,SUM(SI.SalNetAmt) AS NetAmount,0 AS ReturnGrossAmt,0 AS ReturnNetAmt,
		RVC.RtrValueClassId,RC.Turnover,RC.RtrClassId,
	RCC.CtgMainId,RCL.CtgLevelId,0 AS NewClassId FROM SalesInvoice SI 
	LEFT OUTER JOIN Retailer RTR ON RTR.RtrId = SI.RTRId 
	LEFT OUTER JOIN  RetailerValueClassmap RVC ON RVC.RtrId = SI.RtrId 
	INNER JOIN RetailerValueClass RC ON RVC.RtrValueClassId = RC.RtrClassId and RC.CmpId= @CmpId
	INNER JOIN RetailerCategory RCC ON RCC.CtgMainId = RC.CtgMainId
	INNER JOIN RetailerCategoryLevel RCL ON RCL.CtgLevelId = RCC.CtgLevelId and RCL.CmpId=@CmpId
	WHERE SI.OrderDate BETWEEN @FromDate AND @ToDate AND SI.DlvSts IN(4,5)
	GROUP BY SI.RtrId,RVC.RtrValueClassId,RCC.CtgMainId,RCL.CtgLevelId,RC.Turnover,RC.RtrClassId
	UNION 
	SELECT SI.RtrId,0 AS GrossAmount,0  AS NetAmount,SUM(SI.RtnGrossAmt) AS ReturnGrossAmt,SUM(SI.RtnNetAmt)AS ReturnNetAmt,
		RVC.RtrValueClassId,RC.TurnOver,RC.RtrClassId,
	RCC.CtgMainId,RCL.CtgLevelId,0 FROM ReturnHeader SI 
	LEFT OUTER JOIN Retailer RTR ON RTR.RtrId = SI.RTRId 
	LEFT OUTER JOIN  RetailerValueClassmap RVC ON RVC.RtrId = SI.RtrId 
	INNER JOIN RetailerValueClass RC ON RVC.RtrValueClassId = RC.RtrClassId and RC.CmpId= @CmpId
	INNER JOIN RetailerCategory RCC ON RCC.CtgMainId = RC.CtgMainId
	INNER JOIN RetailerCategoryLevel RCL ON RCL.CtgLevelId = RCC.CtgLevelId and RCL.CmpId=@CmpId
	WHERE SI.ReturnDate BETWEEN @FromDate AND @ToDate AND SI.ReturnType=2 AND SI.Status=0
	GROUP BY SI.RtrId,RVC.RtrValueClassId,RCC.CtgMainId,RCL.CtgLevelId,RC.Turnover,RC.RtrClassId) A
	GROUP BY  RtrId,RtrValueClassId,Turnover,RtrClassId,CtgMainId,CtgLevelId,NewClassId
	IF @GrossorNet=1 
	BEGIN
		IF @Return=1
		BEGIN 
			INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
			SELECT RtrId,ABS(SalesGrossAmount-SalesRtnGrossAmount),CtgMainId FROM @RetailerClassShift 
		END 
		ELSE
		BEGIN 
			INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
			SELECT RtrId,SalesGrossAmount,CtgMainId FROM @RetailerClassShift 
		END 
	END
	ELSE
	BEGIN
		IF @Return=1
		BEGIN 
			INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
			SELECT RtrId,ABS(SalesNetAmount-SalesRtnNetAmount),CtgMainId FROM @RetailerClassShift 
		END 
		ELSE
		BEGIN 
			INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
			SELECT RtrId,SalesNetAmount,CtgMainId FROM @RetailerClassShift 
		END 
	END 
	--SELECT RtrId,CtgMainId,Amount FROM @RetailerNewClass
	DELETE FROM AutoRetailerClassShift WHERE ShiftDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	DECLARE Cur_RetailerSlassShift CURSOR
          FOR SELECT RtrId,CtgMainId,Amount FROM @RetailerNewClass
    OPEN Cur_RetailerSlassShift
	FETCH NEXT FROM Cur_RetailerSlassShift INTO @RtrId,@CtgMainId,@Amount
	WHILE @@FETCH_STATUS=0
    BEGIN
		
----		SELECT @MaxRtrClassId=RtrClassId,@MaxAmount=TurnOver FROM RetailerValueClass WHERE CtgMainId=@CtgMainId
----			AND TurnOver IN
----		 (SELECT MIN(TurnOver) FROM RetailerValueClass WHERE  CtgMainId=@CtgMainId AND 
----			TurnOver > @Amount AND  CmpId = @CmpId) AND CmpId=@CmpId
----		
		SELECT @MinRtrClassId=RtrClassId,@MinAmount=TurnOver FROM RetailerValueClass WHERE CtgMainId=@CtgMainId
			AND TurnOver IN
		 (SELECT MAX(TurnOver) FROM RetailerValueClass WHERE  CtgMainId=@CtgMainId AND 
			TurnOver < @Amount AND  CmpId = @CmpId) AND CmpId=@CmpId

		SET @RtrClassId=@MinRtrClassId
		--IF @Amount
		
		IF @RtrClassId<>0 
		BEGIN
			IF EXISTS (SELECT RtrValueClassId FROM RetailerValueClassMap WHERE RtrId=@RtrId )
			BEGIN
				SELECT @OldRtrClassId=RtrValueClassId FROM RetailerValueClassMap WHERE RtrId=@RtrId 

				UPDATE RetailerValueClassMap SET RtrValueClassId=@RtrClassId WHERE RtrId=@RtrId
				INSERT INTO AutoRetailerClassShift (ShiftDate,RtrId,OldRtrClassId,NewRtrClassId)
				SELECT CONVERT(NVARCHAR(10),GETDATE(),121),@RtrId,@OldRtrClassId,@RtrClassId
				--DELETE FROM AutoRetailerClassShift WHERE OldRtrClassId=NewRtrClassId	

				INSERT INTO Track_RtrCategoryandClassChange
				SELECT -1000,@RtrId,B.CtgLevelId,A.CtgMainId,@OldRtrClassId,B.CtgLevelId,A.CtgMainId, 
				@RtrClassId,CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(23),GETDATE(),121),2
				FROM RetailerValueClass A INNER JOIN RetailerCategory B
				ON A.CtgMainId=B.CtgMainId	

				UPDATE Retailer SET Upload='N' WHERE RtrId=@RtrId
			END
		END
    FETCH NEXT FROM Cur_RetailerSlassShift INTO  @RtrId,@CtgMainId,@Amount
    END
    CLOSE Cur_RetailerSlassShift
    DEALLOCATE Cur_RetailerSlassShift
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_Cn2Cs_RetailerApproval')
DROP PROCEDURE Proc_Cn2Cs_RetailerApproval
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_RetailerApproval 0
SELECT * FROM Cn2Cs_Prk_RetailerApproval
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_RetailerApproval]
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
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_RetailerApproval'
	SET @Pi_UserId=1
	
	
	DECLARE Cur_RetailerApproval CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([RtrCode])),''),ISNULL(LTRIM(RTRIM([CmpRtrCode])),''),ISNULL(LTRIM(RTRIM([RtrChannelCode])),''),ISNULL(LTRIM(RTRIM([RtrGroupCode])),''),
	ISNULL(LTRIM(RTRIM([RtrClassCode])),''),ISNULL(LTRIM(RTRIM([Status])),'Active'),ISNULL(LTRIM(RTRIM([KeyAccount])),'Yes')
	FROM Cn2Cs_Prk_RetailerApproval WHERE [DownLoadFlag] ='D'
	OPEN Cur_RetailerApproval
	FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,@Status,@KeyAcc
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Po_ErrNo=0
		IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode)
		BEGIN
			SET @ErrDesc = 'Retailer Code:'+@RtrCode+'does not exists'
			INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
			SET @RtrId=0
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
			
		IF @Po_ErrNo=0
		BEGIN
			UPDATE Retailer SET RtrStatus=@Status,Approved=1,RtrKeyAcc=@KeyAccId WHERE RtrId=@RtrId
			
			SET @sSql='UPDATE Retailer SET RtrStatus='+CAST(@Status AS NVARCHAR(100))+',RtrKeyAcc='+CAST(@KeyAccId AS NVARCHAR(100))+' WHERE RtrId='+CAST(@RtrId AS NVARCHAR(100))+''
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


		END
		FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,@Status,@KeyAcc
	END
	CLOSE Cur_RetailerApproval
	DEALLOCATE Cur_RetailerApproval
	UPDATE Cn2Cs_Prk_RetailerApproval SET DownLoadFlag='Y' WHERE DownLoadFlag ='D'
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_ValidateRetailerValueClassMap')
DROP PROCEDURE Proc_ValidateRetailerValueClassMap
GO
--Exec Proc_ValidateRetailerValueClassMap 0 
--select * from errorlog
--delete from errorlog
--delete from RetailerValueClassMap
--select * from RetailerValueClassMap order by rtrid
--select * from ETL_Prk_RetailerValueClassMap order by RetailerCode
CREATE                      Procedure [dbo].[Proc_ValidateRetailerValueClassMap]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateRetailerValueClassMap
* PURPOSE	: To Insert and Update records  from xml file in the Table RetailerValueClassMap 
* CREATED	: MarySubashini.S
* CREATED DATE	: 13/09/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @RetailerCode AS NVARCHAR(100)
	DECLARE @ValueClassCode AS NVARCHAR(100)
	DECLARE @CtgCode AS NVARCHAR(100)
	DECLARE @RtrId AS INT
	DECLARE @RtrValueClassId AS INT
	DECLARE @Taction AS INT
	DECLARE @Tabname AS NVARCHAR(100)
	DECLARE @TransType AS INT 
	DECLARE @SelectionType AS NVARCHAR(100)
	DECLARE @ErrDesc AS NVARCHAR(1000)
	DECLARE @sSql AS NVARCHAR(4000)
	DECLARE @CtgMainId AS NVARCHAR(100)
	DECLARE @CmpId AS NVARCHAR(100)
	
	SET @Taction=1
	SET @Po_ErrNo=0
	SET @TransType=1
	SET @Tabname='ETL_Prk_RetailerValueClassMap'
	DECLARE Cur_RetailerValueClassMap CURSOR 
	FOR SELECT ISNULL([Retailer Code],''),ISNULL([Value Class Code],''),ISNULL([Category Level Value],''),ISNULL([Selection Type],'')
	FROM ETL_Prk_RetailerValueClassMap ORDER BY [Retailer Code]
	OPEN Cur_RetailerValueClassMap
	FETCH NEXT FROM Cur_RetailerValueClassMap INTO @RetailerCode,@ValueClassCode,@CtgCode,@SelectionType
	WHILE @@FETCH_STATUS=0
	BEGIN	
		SET @CmpId=0
		IF NOT EXISTS (SELECT * FROM Retailer WHERE RtrCode = @RetailerCode)    
  		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Retailer Code ' + @RetailerCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (1,@Tabname,'RetailerCode',@ErrDesc)
		END
		ELSE
		BEGIN						
			SELECT @RtrId =RtrId FROM Retailer WHERE RtrCode = @RetailerCode
		END
		IF NOT EXISTS (SELECT * FROM RetailerCategory WHERE  CtgCode=@CtgCode)    
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Category Code ' + @CtgCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (2,@Tabname,'Category Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @CtgMainId =CtgMainId FROM RetailerCategory WHERE CtgCode=@CtgCode
		END
		
		IF NOT EXISTS  (SELECT * FROM RetailerValueClass WHERE  ValueClassCode=@ValueClassCode AND CtgMainId=@CtgMainId )    
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Value Class Code ' + @ValueClassCode + ' does not exist'  		 
			INSERT INTO Errorlog VALUES (3,@Tabname,'ValueClassCode',@ErrDesc)
		END
		ELSE
		BEGIN						
			SELECT @RtrValueClassId =RtrClassId,@CmpId=CmpId FROM RetailerValueClass WITH (NOLOCK)
			WHERE ValueClassCode=@ValueClassCode AND CtgMainId=@CtgMainId 
		END
		IF EXISTS (SELECT * FROM RetailerValueClassMap WHERE  RtrValueClassId=@RtrValueClassId AND RtrId=@RtrId)    
		BEGIN
			SET @Taction=2
		END
		ELSE
		BEGIN
			SET @Taction=1				
		END
		
		IF LTRIM(RTRIM(@SelectionType))=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Value Class Selection Type should not be empty'  		 
			INSERT INTO Errorlog VALUES (4,@Tabname,'SelectionType',@ErrDesc)
		END
		ELSE
		BEGIN
			IF LTRIM(RTRIM(@SelectionType))='ADD' OR LTRIM(RTRIM(@SelectionType))='REDUCE'
			BEGIN
				IF LTRIM(RTRIM(@SelectionType))='ADD' 
				BEGIN
					SET @TransType=1
				END
				IF LTRIM(RTRIM(@SelectionType))='REDUCE' 
				BEGIN
					SET @TransType=2
				END
			END
			ELSE 
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Value Class Type '+@SelectionType+' is not available'  		 
				INSERT INTO Errorlog VALUES (5,@Tabname,'SelectionType',@ErrDesc)
			END
		END
			
		IF @TransType=1 
		BEGIN
			IF  @Po_ErrNo=0 
			BEGIN
				DECLARE @OldCtgMainId	NUMERIC(38,0)
				DECLARE @OldCtgLevelId	NUMERIC(38,0)
				DECLARE @OldRtrClassId	NUMERIC(38,0)
				DECLARE @NewCtgMainId	NUMERIC(38,0)
				DECLARE @NewCtgLevelId	NUMERIC(38,0)
				DECLARE @NewRtrClassId	NUMERIC(38,0)
				DECLARE @RtrCnt			NUMERIC(38,0)
				SET @RtrCnt=0
				IF EXISTS(SELECT * FROM RetailerValueClassMap WHERE RtrId=@RtrId AND RtrValueClassId IN
						(SELECT RtrClassId FROM RetailerValueClass WHERE CmpId=@CmpId))
				BEGIN
			
					SELECT @OldCtgMainId=A.CtgMainId,@OldCtgLevelId=B.CtgLevelId,@OldRtrClassId=C.RtrClassId 
					FROM RetailerCategory A INNER JOIN RetailerCategoryLevel B ON A.CtgLevelId=B.CtgLevelId
					INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
					INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
					WHERE D.RtrId=@RtrId
					SET @RtrCnt=1
				END

				--DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId AND RtrValueClassId=@RtrValueClassId
				DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId AND RtrValueClassId IN
				(SELECT RtrClassId FROM RetailerValueClass WHERE CmpId=@CmpId)
				SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+
				' AND RtrValueClassId='+CAST(@RtrValueClassId AS NVARCHAR(10))

				INSERT INTO Translog(strSql1) VALUES (@sSql)
				INSERT INTO RetailerValueClassMap 
				(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@RtrId,@RtrValueClassId,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))

				IF @RtrCnt=1
				BEGIN
					SELECT @OldCtgMainId=A.CtgMainId,@OldCtgLevelId=B.CtgLevelId,@OldRtrClassId=C.RtrClassId 
					FROM RetailerCategory A INNER JOIN RetailerCategoryLevel B ON A.CtgLevelId=B.CtgLevelId
					INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
					INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
					WHERE D.RtrId=@RtrId

					INSERT INTO Track_RtrCategoryandClassChange
					SELECT -4000,@RtrId,@OldCtgLevelId,@OldCtgMainId,@OldRtrClassId,@NewCtgLevelId,@NewCtgMainId, 
					@NewRtrClassId,CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(23),GETDATE(),121),5					
				END
				
				SET @sSql='INSERT INTO RetailerValueClassMap 
				(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RtrValueClassId AS VARCHAR(10))+', 
				1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
			
		IF @TransType=2 
		BEGIN
			IF @Po_ErrNo=0
			BEGIN
				DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId AND RtrValueClassId=@RtrValueClassId
				SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(10))+' AND RtrValueClassId='+CAST(@RtrValueClassId AS VARCHAR(10))+''
				INSERT INTO Translog(strSql1) VALUES (@sSql)
			END
		END
		
		FETCH NEXT FROM Cur_RetailerValueClassMap INTO @RetailerCode,@ValueClassCode,@CtgCode,@SelectionType		
	END
	CLOSE Cur_RetailerValueClassMap
	DEALLOCATE Cur_RetailerValueClassMap
	--->Added By Nanda on 04/03/2010
	IF EXISTS(SELECT * FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap))
	BEGIN		
		INSERT INTO Errorlog(SlNo,TableName,FieldName,ErrDesc) 
		SELECT 100,'Retailer','Value Class','Value Class is not mapped correctly for Retailer Code:'+RtrCode
		FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap)
		DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerValueClassMap))
		DELETE FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap)
		SET @sSql='DELETE FROM CoaMaster WHERE CoaId IN (SELECT CoaId FROM Retailer WHERE RtrId NOT IN (SELECT RtrId FROM RetailerValueClassMap))'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
		SET @sSql='DELETE FROM Retailer WHERE RtrId NOT IN (SELECT DISTINCT RtrId FROM RetailerValueClassMap)'
		INSERT INTO Translog(strSql1) VALUES (@sSql)
	END
	--->Till Here
	RETURN
END
GO

--SRF-Nanda-236-013-From Boo

DELETE FROM RptGroup WHERE  Rptid=231
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'DailyReports',231,'RetailerCategoryandClassificationShift','Retailer Category and Classification Shift'
GO
DELETE FROM RptHeader WHERE Rptid=231
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'RetailerCategoryandClassificationShift','Retailer Category and Classification Shift',231,'Retailer Category and Classification Shift','Proc_RptRtrCategoryandClassShift','RptRtrCategoryandClassShift','RptRtrCategoryandClassShift.rpt',NULL
GO
DELETE FROM RptDetails WHERE RptId=231
INSERT INTO RptDetails
SELECT 231,1,'FromDate',-1,'','','From Date*','',1,'',10,'','','Enter From Date',0
UNION
SELECT 231,2,'ToDate',-1,'','','To Date*','',1,'',11,'','','Enter To Date',0
UNION 
SELECT 231,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,'','Press F4/Double Click to select Company',0
UNION
SELECT 231,4,'SalesMan',-1,'','SMId,SMCode,SMName','SalesMan...','',1,'',1,1,'','Press F4/Double Click to select Salesman',0
UNION
SELECT 231,5,'RouteMaster',-1,'','RMId,RMCode,RMName','Route...','',1,'',2,1,'','Press F4/Double Click to select Route',0
UNION
SELECT 231,6,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'',3,'','','Press F4/Double Click to select Retailer',0
GO
DELETE FROM RptFormula WHERE RptId=231
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,1,'Fill_Salesman','',1,1
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,2,'Fill_Route','',1,2
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,3,'Fill_Retailer','',1,3
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,4,'Fill_FromDate','',1,10
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,5,'Fill_ToDate','',1,11
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,6,'Fill_Company','',1,4

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,7,'Disp_Salesman','Salesman',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,8,'Disp_Route','Route',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,9,'Dis_Retailer','Retailer',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,10,'Disp_FromDate','From Date',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,11,'Disp_ToDate','To Date',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,12,'Disp_Company','Company',1,0

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,13,'HdModeofShift','Mode of Shift',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,14,'HdNewCtgLevel','New Category Level',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,15,'HdNewCtgMain','New Category Level Value',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,16,'HdNewRtrClass','New Classification',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,17,'HdOldCtgLevel','Old Category Level',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,18,'HdOldCtgmain','Old Category Level Value',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,19,'HdOldRtrClass','Old Classification',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,20,'HdRtrCode','Retailer Code',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,21,'HdRtrName','Retailer Name',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,22,'HdShiftDate','Shift Date',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 231,23,'HdShiftTime','Shift Time',1,0

GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptRtrCategoryandClassShift')
DROP PROCEDURE Proc_RptRtrCategoryandClassShift
GO 
--EXEC Proc_RptRtrCategoryandClassShift 231,1,0,'Dabur1',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptRtrCategoryandClassShift]
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
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @CmpId	 	AS	INT
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	
	
	Create TABLE #RptRtrCategoryandClassShift
	(
		RtrId			BIGINT,
		RtrCode			NVARCHAR(100),
		RtrName			NVARCHAR(200),
		OldLevelId		BIGINT,
		OldLevelCode	NVARCHAR(100),
		OldLevelName	NVARCHAR(200),
		OldMainId		BIGINT,
		OldMainCode		NVARCHAR(100),
		OldMainName		NVARCHAR(200),
		OldClassId		BIGINT,
		OldClassCode	NVARCHAR(100),
		OldClassName	NVARCHAR(200),
		NewLevelId		BIGINT,
		NewLevelCode	NVARCHAR(100),
		NewLevelName	NVARCHAR(200),
		NewMainId		BIGINT,
		NewMainCode		NVARCHAR(100),
		NewMainName		NVARCHAR(200),
		NewClassId		BIGINT,
		NewClassCode	NVARCHAR(100),
		NewClassName	NVARCHAR(200),
		ShiftDate		DATETIME,
		ShiftTime		VARCHAR(8),
		TransId			BIGINT,
		TransName		NVARCHAR(100)
	)

	SET @TblName = 'RptRtrCategoryandClassShift'
	
	SET @TblStruct = '	RtrId			BIGINT,
		RtrCode			NVARCHAR(100),
		RtrName			NVARCHAR(200),
		OldLevelId		BIGINT,
		OldLevelCode	NVARCHAR(100),
		OldLevelName	NVARCHAR(200),
		OldMainId		BIGINT,
		OldMainCode		NVARCHAR(100),
		OldMainName		NVARCHAR(200),
		OldClassId		BIGINT,
		OldClassCode	NVARCHAR(100),
		OldClassName	NVARCHAR(200),
		NewLevelId		BIGINT,
		NewLevelCode	NVARCHAR(100),
		NewLevelName	NVARCHAR(200),
		NewMainId		BIGINT,
		NewMainCode		NVARCHAR(100),
		NewMainName		NVARCHAR(200),
		NewClassId		BIGINT,
		NewClassCode	NVARCHAR(100),
		NewClassName	NVARCHAR(200),
		ShiftDate		DATETIME,
		ShiftTime		VARCHAR(8),
		TransId			BIGINT,
		TransName		NVARCHAR(100)'
	
	SET @TblFields = 'RtrId,RtrCode,RtrName,OldLevelId,OldLevelCode,OldLevelName,
		OldMainId,OldMainCode,OldMainName,OldClassId,OldClassCode,OldClassName,
		NewLevelId,NewLevelCode,NewLevelName,NewMainId,NewMainCode,NewMainName,
		NewClassId,NewClassCode,NewClassName,ShiftDate,ShiftTime,TransId,TransName'
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

			INSERT INTO #RptRtrCategoryandClassShift(RtrId,RtrCode,RtrName,OldLevelId,OldLevelCode,OldLevelName,
				OldMainId,OldMainCode,OldMainName,OldClassId,OldClassCode,OldClassName,
				NewLevelId,NewLevelCode,NewLevelName,NewMainId,NewMainCode,NewMainName,
				NewClassId,NewClassCode,NewClassName,ShiftDate,ShiftTime,TransId,TransName)
			SELECT DISTINCT A.RtrId,B.RtrCode,B.RtrName,A.OldCtgLevelId,C.LevelName,C.CtgLevelName,
				   A.OldCtgManinId,D.CtgCode,D.CtgName,A.OldRtrClassId,F.ValueClassCode,F.ValueClassName,
				   A.NewCtgLevelId,C1.LevelName,C1.CtgLevelName,A.NewCtgManinId,D1.CtgCode,D1.CtgName,
				   A.NewRtrClassId,F1.ValueClassCode,F1.ValueClassName,CONVERT(NVARCHAR(10),A.ShiftDate,121),
				   CONVERT(CHAR(8), A.ShiftTime, 108),A.TransId,
				   CASE A.TransId 
						WHEN 1 THEN 'Class Shift Tool'
						WHEN 2 THEN 'Auto Classification'
						WHEN 3 THEN 'Manual Edit'
						WHEN 4 THEN 'Retailer Approval'
						WHEN 5 THEN 'ETL Import' END
			FROM Track_RtrCategoryandClassChange A 
			INNER JOIN Retailer B ON A.RtrId=B.RtrId
			INNER JOIN RetailerCategoryLevel C ON A.OldCtgLevelId=C.CtgLevelId AND
						(C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId Else 0 END) OR
						C.CmpId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN RetailerCategory D ON A.OldCtgManinId=D.CtgMainId
			INNER JOIN RetailerValueClass F ON A.OldRtrClassId=F.RtrClassId AND
						(F.CmpId = (CASE @CmpId WHEN 0 THEN F.CmpId Else 0 END) OR
						F.CmpId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN Retailer B1 ON A.RtrId=B1.RtrId
			INNER JOIN RetailerCategoryLevel C1 ON A.NewCtgLevelId=C1.CtgLevelId AND
						(C1.CmpId = (CASE @CmpId WHEN 0 THEN C1.CmpId Else 0 END) OR
						C1.CmpId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN RetailerCategory D1 ON A.NewCtgManinId=D1.CtgMainId
			INNER JOIN RetailerValueClass F1 ON A.NewRtrClassId=F1.RtrClassId AND
						(F1.CmpId = (CASE @CmpId WHEN 0 THEN F1.CmpId Else 0 END) OR
						F1.CmpId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))	
			INNER JOIN RetailerMarket G ON A.RtrId=G.RtrId AND
							(G.RMId = (CASE @RMId WHEN 0 THEN G.RMId Else 0 END) OR
							 G.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			INNER JOIN SalesmanMarket H ON G.RMID=H.RMID AND
							(H.SMId = (CASE @SMId WHEN 0 THEN H.SMId Else 0 END) OR
							 H.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 		
			WHERE A.ShiftDate Between @FromDate AND @ToDate  AND
				(A.RtrID = (CASE @RtrId WHEN 0 THEN A.RtrID Else 0 END) OR
				A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))

		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptRtrCategoryandClassShift ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
				
				'WHERE (RtrId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN RtrId ELSE 0 END) OR
						RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))
						
				AND (RMId=(CASE ' + CAST(@RMId AS INTEGER) + ' WHEN 0 THEN RMId ELSE 0 END) OR
									RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) +')))
									
				AND (SMId=(CASE '+ CAST(@SMId AS INTEGER) + 'WHEN 0 THEN SMId ELSE 0 END) OR
									SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) + ')))


				AND ([ShiftDate] Between ' + @FromDate +' and ' + @ToDate + ')'

--				
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRtrCategoryandClassShift'
		
				EXEC (@SSQL)
				PRINT 'Saved Data Into SnapShot Table'
		   END
	   END
	END
	ELSE
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
			@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptRtrCategoryandClassShift ' +
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
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptRtrCategoryandClassShift

	SELECT * FROM #RptRtrCategoryandClassShift Order By TransId
 	RETURN
END
GO
Delete From RptExcelHeaders  Where RptId  = 231
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,1,'RtrId','RtrId',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,2,'RtrCode','Retailer Code',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,3,'RtrName','Retailer Name',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,4,'OldLevelId','OldLevelId',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,5,'OldLevelCode','OldLevelCode',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,6,'OldLevelName','Old Category Level',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,7,'OldMainId','OldMainId',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,8,'OldMainCode','OldMainCode',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,9,'OldMainName','Old Category Level Value',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,10,'OldClassId','OldClassId',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,11,'OldClassCode','OldClassCode',0,1)
GO 
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,12,'OldClassName','Old Classification',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,13,'NewLevelId','NewLevelId',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,14,'NewLevelCode','NewLevelCode',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,15,'NewLevelName','New Category Level',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,16,'NewMainId','NewMainId',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,17,'NewMainCode','NewMainCode',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,18,'NewMainName','New Category Level Value',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,19,'NewClassId','NewClassId',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,20,'NewClassCode','NewClassCode',0,1)
GO 
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,21,'NewClassName','New Classification',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,22,'ShiftDate','Shift Date',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,23,'ShiftTime','Shift Time',1,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,24,'TransId','TransId',0,1)
GO
Insert Into RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(231,25,'TransName','Mode Of Shift',1,1)
GO

--SRF-Nanda-236-014-From Kalai

DELETE FROM RptExcelHeaders WHERE RptId=29 

INSERT INTO RptExcelHeaders VALUES (29,1,'InvId','InvId',	0,1)
INSERT INTO RptExcelHeaders VALUES (29,2,'RefNo','Transaction No',1,1)
INSERT INTO RptExcelHeaders VALUES (29,3,'BillBookBo','Buill Book Bo',1,1)
INSERT INTO RptExcelHeaders VALUES (29,4,'InvDate','Transaction Date',1,1)
INSERT INTO RptExcelHeaders VALUES (29,5,'BaseTransNo','Base Transaction Ref No',1,1)
INSERT INTO RptExcelHeaders VALUES (29,6,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders VALUES (29,7,'RtrName','Retailer',1,1)
INSERT INTO RptExcelHeaders VALUES (29,8,'RtrTINNo','TIN No',1,1)
INSERT INTO RptExcelHeaders VALUES (29,9,'UsrId','UsrId',0,1)

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptOUTPUTVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [RptOUTPUTVATSummary_Excel]

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
	SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType,
	'Net Amount',SUM(SalNetAmt),0,2000.000000
	FROM #RptOUTPUTVATSummary A INNER JOIN SalesInvoice B ON A.InvId=B.SalId AND 
	A.RefNo=B.SalInvNo WHERE TaxFlag=0 AND A.IoTaxType='Sales'
	GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType
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

if not exists (select * from hotfixlog where fixid = 376)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(376,'D','2011-05-05',getdate(),1,'Core Stocky Service Pack 376')
