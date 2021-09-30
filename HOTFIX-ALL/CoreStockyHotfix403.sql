--[Stocky HotFix Version]=403
DELETE FROM Versioncontrol WHERE Hotfixid='403'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('403','2.0.0.5','D','2013-08-16','2013-08-16','2013-08-16',CONVERT(VARCHAR(11),GETDATE()),'PARLE-Major: Product Release Dec CR')
GO
UPDATE CustomCaptions SET Caption = 'Product Short Name*' WHERE TransId = 91 and CtrlId = 45 and CtrlName = 'DGCommon-91-45-27'
GO
DELETE FROM Configuration WHERE ModuleId IN ('DISTAXCOLL1','DISTAXCOLL3','DISTAXCOLL4','DISTAXCOLL5','DISTAXCOLL6','DISTAXCOLL7','DISTAXCOLL8','DISTAXCOLL9')
INSERT INTO Configuration
SELECT 'DISTAXCOLL1','Discount & Tax Collection','Allow Editing of Cash Discount in the billing screen',1,'',0.00,1 UNION
SELECT 'DISTAXCOLL3','Discount & Tax Collection','Calculate Tax in Line Level',1,'LEVEL',0.00,3 UNION
SELECT 'DISTAXCOLL4','Discount & Tax Collection','Post Vouchers on Delivery date',1,'1',0.00,4	UNION
SELECT 'DISTAXCOLL5','Discount & Tax Collection','Perform auto confirmation of bill',0,'',0.00,5 UNION
SELECT 'DISTAXCOLL6','Discount & Tax Collection','Automatically perform Vehicle allocation while saving the bill',1,'',0.00,6 UNION
SELECT 'DISTAXCOLL7','Discount & Tax Collection','Enable Bill Book Number Tracking in Billing Screen',1,'',0.00,7 UNION
SELECT 'DISTAXCOLL8','Discount & Tax Collection','Enable Invoice Level Discount field in the Billing Screen',1,'',3.00,8 UNION
SELECT 'DISTAXCOLL9','Discount & Tax Collection','Treat Invoice Level Discount as ',1,'',1.00,9
GO
DELETE FROM FieldLevelAccessDt WHERE TransId = 91 AND CtrlId = 100002
INSERT INTO FieldLevelAccessDt (PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,91,'100002',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD WITH (NOLOCK)
GO
IF NOT EXISTS (SELECT * FROM CustomCaptions WHERE transid=242 and CtrlId=45)
INSERT INTO CustomCaptions SELECT 242,45,0,'fxtProdStatus','','Press F4/Doubleclick to select Product Status','',1,1,1,CONVERT(VARCHAR,GETDATE(),121),1,CONVERT(VARCHAR,GETDATE(),121),'','Press F4/Doubleclick to select Product Status','',1,1
GO
IF NOT EXISTS (SELECT * FROM CustomCaptions WHERE TransId=91 AND CtrlId=100027)
INSERT INTO CustomCaptions SELECT 91,100027,0,'fxtProdStatus','Product Status','','',1,1,1,CONVERT(VARCHAR,GETDATE(),121),1,CONVERT(VARCHAR,GETDATE(),121),'','','',1,1
GO
IF NOT EXISTS (SELECT * FROM FieldLevelAccessdt WHERE TransId=91 AND CtrlId=100027)
INSERT INTO FieldLevelAccessdt SELECT 1,91,100027,1,1,1,CONVERT(VARCHAR,GETDATE(),121),1,CONVERT(VARCHAR,GETDATE(),121)
GO
IF NOT EXISTS (SELECT * FROM HotSearchEditorHd WHERE FormId=10054)
INSERT INTO HotSearchEditorHd SELECT 10054,'Mass Update Tool','SMRoute','Select','SELECT RMId,RMCode,RMName FROM (SELECT RM.RMId,RM.RMCode,RM.RMName FROM RouteMaster RM LEFT OUTER JOIN SalesManMarket SM (NOLOCK) ON SM.RMId=RM.RMId WHERE SM.SMId=vFParam AND RM.RMId NOT IN(vSParam))a'
GO
IF NOT EXISTS (SELECT * FROM HotSearchEditorHd WHERE FormId=10055)
INSERT INTO HotSearchEditorHd SELECT 10055,'Mass Update Tool','AllSMRoute','Select','SELECT RMId,RMCode,RMName FROM RouteMaster (NOLOCK) WHERE RMId NOT IN (vFParam)'
GO
UPDATE RptFormula SET FormulaValue='Box' WHERE RptId=24 and SlNo=11
GO
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo in(10,11,13,14) and RptId=24
GO
IF EXISTS (SELECT * FROM sysobjects WHERE Name = 'Proc_RptProductPurchase' AND Xtype = 'P')
DROP PROCEDURE Proc_RptProductPurchase
GO
--  exec [Proc_RptProductPurchase] 24,2,0,'',0,0,1
CREATE PROCEDURE Proc_RptProductPurchase  
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
	DECLARE @CmpId   AS INT  
	DECLARE @CmpInvNo  AS INT  
	DECLARE @PrdCatId AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @PrdId  AS INT  
	
	DECLARE @UOMID AS INTEGER
	
	SELECT @UOMID = UOMID FROM UOMMASTER WHERE UOMDESCRIPTION='BOX'
	
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
		CmpId    INT,  
		CmpName    NVARCHAR(50),    
		PurRcptId   BIGINT,  
		PurRcptRefNo   NVARCHAR(50),  
		InvDate   DATETIME,    
		PrdId     INT,  
		PrdDCode   NVARCHAR(100),  
		PrdName   NVARCHAR(100),  
		InvBaseQty   INT,  
		PrdGrossAmount   NUMERIC(38,6),  
		CmpInvNo   nVarchar(100)  
	)  
	SET @TblName = 'RptProductPurchase'  
	SET @TblStruct = 'CmpId    INT,  
	CmpName    NVARCHAR(50),    
	PurRcptId   BIGINT,  
	PurRcptRefNo   NVARCHAR(50),  
	InvDate   DATETIME,    
	PrdId     INT,  
	PrdDCode   NVARCHAR(100),  
	PrdName   NVARCHAR(100),  
	InvBaseQty   INT,  
	PrdGrossAmount   NUMERIC(38,6),  
	CmpInvNo   nVarchar(100)'  
	 
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
		SlNo INT IDENTITY(1,1),  
		UOMId INT  
	)   
	INSERT INTO UOMIdWise(UOMId)  
	SELECT UOMId FROM UOMMaster ORDER BY UOMId   
	EXEC Proc_GRNListing @Pi_UsrId,@Pi_RptId
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		
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
		 
		(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR  
		 PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
		 
		AND   
		(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
		 PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
		 AND  
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
	ELSE    --To Retrieve Data From Snap Data  
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
		
		-- Added By Sathish.P on 26/Jul/2013			
		SELECT * INTO #TEMPUOM
		FROM
		(Select 
			P.PrdId,UG.ConversionFactor
		From
			Product P Inner Join UomGroup UG On P.UomGroupId=UG.UomGroupId 
			and UG.UomId = @UOMID
		Union	
		Select
			P.PrdId,A.ConversionFactor
		From
			Product P Inner Join
		(Select 
			UomGroupId,MAX(ConversionFactor) ConversionFactor 
		from 
			UOMGroup 
		Where 
			UomGroupId Not in(Select UomGroupid from UomGroup Where UomId=@UOMID)
		Group By 
			UomGroupId) A On P.UomGroupId=A.UomGroupId) B
		
		
		Select CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PP.PrdId,PrdDCode,PrdName,Cast(InvBaseQty/ConversionFactor as Int) InvBaseQty,PrdGrossAmount,CmpInvNo From #RptProductPurchase PP Inner Join #TEMPUOM U On PP.PrdId=U.PrdId 
		Order by PurRcptId,PurRcptRefNo,InvDate,PrdDCode

		--Till Here
	
		/* Grid View Output Query  09-July-2009   */  
				
		SELECT  a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,  
		a.InvDate,a.PrdId,a.PrdDCode,a.PrdName, a.InvBaseQty,  
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(a.InvBaseQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,  
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(a.InvBaseQty AS INT)-
		(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,  
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.
		InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then  
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
		a.InvDate,a.PrdId,a.PrdDCode,a.PrdName, a.InvBaseQty,a.PrdGrossAmount,ConverisonFactor2,  
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
		 CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(a.InvBaseQty AS INT
		)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,  
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
		a.InvDate,a.PrdId,a.PrdDCode,a.PrdName, a.InvBaseQty,a.PrdGrossAmount,ConverisonFactor2,  
		ConverisonFactor3,ConverisonFactor4  


		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
		BEGIN  
			IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptProductPurchase_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
			DROP TABLE RptProductPurchase_Excel  
			----SELECT CmpId, CmpName,CmpInvNo,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,InvBaseQty,0 AS Uom1,0 AS  Uom2,0 AS  Uom3,0 AS  Uom4,PrdGrossAmount 
			----INTO RptProductPurchase_Excel FROM #RptProductPurchase  
			-- Added By Sathish.P on 30/Jul/2013			
			SELECT
				CmpId, CmpName,CmpInvNo,PurRcptId,PurRcptRefNo,InvDate,PP.PrdId,PrdDCode,  
				PrdName,InvBaseQty,0 AS Uom1,
				Cast(InvBaseQty/ConversionFactor as Int) AS  Uom2,0 AS  Uom3,0 AS  Uom4,PrdGrossAmount 
			INTO 
				RptProductPurchase_Excel 
			FROM
				#RptProductPurchase PP Inner Join #TEMPUOM U On PP.PrdId=U.PrdId 
			ORDER BY PurRcptId,PurRcptRefNo,InvDate,PrdDCode
			--Till Here
		END   
-- End Here  
RETURN  
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE Name= 'Proc_MassRetailerDetails' AND Xtype ='P')
DROP PROCEDURE Proc_MassRetailerDetails
GO
--select * from retailermarket where rmid=8=2699
--SELECT * FROM TempMassRetailer
--EXEC Proc_MassRetailerDetails 1,8,2,10,34,1
CREATE PROCEDURE Proc_MassRetailerDetails
(
	@Pi_SMId	INT,
	@Pi_RMId	INT,
	@Pi_CtgLevelId	INT,
	@Pi_CtgMainId	INT,
	@Pi_RtrClassId	INT,
	@Pi_TaxGroupId      INT
)
AS
/************************************************************
* PROCEDURE	: Proc_MassRetailerDetails
* PURPOSE	: To get the  Retailer Details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 29/01/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	
	DELETE FROM TempMassRetailer
	DECLARE @SMRetailer1 TABLE
	(
		RtrId 		INT,
		SMId 		INT,
		RMId 		INT,
		CtgLevelId 	INT,
		CtgMainId 	INT,
		RtrClassId 	INT,
		TaxGroupId 	INT
		
	)
	DECLARE @SMRetailer2 TABLE
	(
		RtrId 		INT,
		SMId 		INT,
		RMId 		INT,
		CtgLevelId 	INT,
		CtgMainId 	INT,
		RtrClassId 	INT,
		TaxGroupId 	INT
		
	)
	DECLARE @SMRetailer3 TABLE
	(
		RtrId 		INT,
		SMId 		INT,
		RMId 		INT,
		CtgLevelId 	INT,
		CtgMainId 	INT,
		RtrClassId 	INT,
		TaxGroupId 	INT
		
	)

	IF @Pi_SMId<>0 
	BEGIN
		IF @Pi_RMId<>0 
		BEGIN
			
			INSERT INTO @SMRetailer1
			SELECT DISTINCT R.RtrId,@Pi_SMId,@Pi_RMId,RC.CtgLevelId,RV.CtgMainId,
				RVC.RtrValueClassId,R.TaxGroupId
				FROM Retailer R (NOLOCK)
				INNER JOIN RetailerMarket RM (NOLOCK) ON RM.RtrId=R.RtrId AND RM.RMId=@Pi_RMId
				INNER JOIN RetailerValueClassMap RVC (NOLOCK) ON RVC.RtrId=R.RtrId 
				INNER JOIN RetailerValueClass RV (NOLOCK) ON RV.RtrClassId=RVC.RtrValueClassId
				INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RV.CtgMainId
				
		END 
		ELSE
		BEGIN
			INSERT INTO @SMRetailer1
			SELECT DISTINCT R.RtrId,@Pi_SMId,RM.RMId,RC.CtgLevelId,RV.CtgMainId,
				RVC.RtrValueClassId,R.TaxGroupId
				FROM Retailer R (NOLOCK)
				INNER JOIN RetailerMarket RM (NOLOCK) ON RM.RtrId=R.RtrId 
				INNER JOIN SalesManMarket SM (NOLOCK) ON SM.RMId=RM.RMId AND SM.SMId=@Pi_SMId
				INNER JOIN RetailerValueClassMap RVC (NOLOCK) ON RVC.RtrId=R.RtrId 
				INNER JOIN RetailerValueClass RV (NOLOCK) ON RV.RtrClassId=RVC.RtrValueClassId
				INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RV.CtgMainId
		END 
	END
	ELSE
	BEGIN
		IF @Pi_RMId<>0 
		BEGIN
			
			INSERT INTO @SMRetailer1
			SELECT DISTINCT R.RtrId,ISNULL(SM.SMId,0),@Pi_RMId,RC.CtgLevelId,RV.CtgMainId,
				RVC.RtrValueClassId,R.TaxGroupId
				FROM Retailer R (NOLOCK)
				INNER JOIN RetailerMarket RM (NOLOCK) ON RM.RtrId=R.RtrId AND RM.RMId=@Pi_RMId
				LEFT OUTER JOIN SalesManMarket SM (NOLOCK) ON SM.RMId=RM.RMId 
				INNER JOIN RetailerValueClassMap RVC (NOLOCK) ON RVC.RtrId=R.RtrId 
				INNER JOIN RetailerValueClass RV (NOLOCK) ON RV.RtrClassId=RVC.RtrValueClassId
				INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RV.CtgMainId
				
		END 
	END 
	IF @Pi_CtgLevelId<>0 AND @Pi_CtgMainId=0 AND @Pi_RtrClassId=0
	BEGIN
		
		INSERT INTO @SMRetailer2
			SELECT DISTINCT R.RtrId,ISNULL(SM.SMId,0),RM.RMId,RC.CtgLevelId,RV.CtgMainId,
				RVC.RtrValueClassId,R.TaxGroupId
				FROM Retailer R (NOLOCK)
				INNER JOIN RetailerMarket RM (NOLOCK) ON RM.RtrId=R.RtrId 
				LEFT OUTER JOIN  SalesManMarket SM (NOLOCK) ON SM.RMId=RM.RMId 
				INNER JOIN RetailerValueClassMap RVC (NOLOCK) ON RVC.RtrId=R.RtrId 
				INNER JOIN RetailerValueClass RV (NOLOCK) ON RV.RtrClassId=RVC.RtrValueClassId
				INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RV.CtgMainId
				AND RC.CtgLevelId=@Pi_CtgLevelId
	END 
	IF @Pi_CtgLevelId<>0 AND @Pi_CtgMainId<>0 AND @Pi_RtrClassId=0
	BEGIN
		
		INSERT INTO @SMRetailer2
			SELECT DISTINCT R.RtrId,ISNULL(SM.SMId,0),RM.RMId,RC.CtgLevelId,RV.CtgMainId,
				RVC.RtrValueClassId,R.TaxGroupId
				FROM Retailer R (NOLOCK)
				INNER JOIN RetailerMarket RM (NOLOCK) ON RM.RtrId=R.RtrId 
				LEFT OUTER JOIN SalesManMarket SM (NOLOCK) ON SM.RMId=RM.RMId 
				INNER JOIN RetailerValueClassMap RVC (NOLOCK) ON RVC.RtrId=R.RtrId 
				INNER JOIN RetailerValueClass RV (NOLOCK) ON RV.RtrClassId=RVC.RtrValueClassId
				INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RV.CtgMainId 
				AND RC.CtgMainId=@Pi_CtgMainId
	END 
	IF @Pi_CtgLevelId<>0 AND @Pi_CtgMainId<>0 AND @Pi_RtrClassId<>0
	BEGIN
		
		INSERT INTO @SMRetailer2
			SELECT DISTINCT R.RtrId,ISNULL(SM.SMId,0),RM.RMId,RC.CtgLevelId,RV.CtgMainId,
				RVC.RtrValueClassId,R.TaxGroupId
				FROM Retailer R (NOLOCK)
				INNER JOIN RetailerMarket RM (NOLOCK) ON RM.RtrId=R.RtrId 
				LEFT OUTER JOIN SalesManMarket SM (NOLOCK) ON SM.RMId=RM.RMId 
				INNER JOIN RetailerValueClassMap RVC (NOLOCK) ON RVC.RtrId=R.RtrId 
					AND RVC.RtrValueClassId=@Pi_RtrClassId
				INNER JOIN RetailerValueClass RV (NOLOCK) ON RV.RtrClassId=RVC.RtrValueClassId
				INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RV.CtgMainId
	END 
	
	
	IF EXISTS (SELECT RtrId FROM @SMRetailer1)
	BEGIN
		IF EXISTS (SELECT RtrId FROM @SMRetailer2)
		BEGIN
			INSERT INTO @SMRetailer3 
				SELECT DISTINCT R1.RtrId,R1.SMId,R1.RMId,R1.CtgLevelId,R1.CtgMainId,
				R1.RtrClassId,R1.TaxGroupId FROM @SMRetailer1 R1
				INNER JOIN @SMRetailer2 R2 ON R1.RtrId=R2.RtrId
		END 
		ELSE
		BEGIN
			IF @Pi_CtgLevelId=0 AND @Pi_CtgMainId=0 AND @Pi_RtrClassId=0
			BEGIN
				INSERT INTO @SMRetailer3
					SELECT * FROM @SMRetailer1
			END
		END 
		
	END 
	ELSE
	BEGIN
		IF EXISTS (SELECT RtrId FROM @SMRetailer2)
		BEGIN
			INSERT INTO @SMRetailer3
				SELECT * FROM @SMRetailer2
		END  
	END 
	
	IF EXISTS (SELECT RtrId FROM @SMRetailer3)
	BEGIN
		IF @Pi_TaxGroupId<>0
		BEGIN
			INSERT INTO TempMassRetailer
			SELECT DISTINCT R.RtrId,R.RtrCode,R.RtrName FROM Retailer R
				INNER JOIN @SMRetailer3 R3 ON R3.RtrId=R.RtrId AND R.TaxGroupId=@Pi_TaxGroupId
			ORDER BY R.RtrId
		END
		ELSE
		BEGIN
			INSERT INTO TempMassRetailer
			SELECT DISTINCT R.RtrId,R.RtrCode,R.RtrName FROM Retailer R
				INNER JOIN @SMRetailer3 R3 ON R3.RtrId=R.RtrId  ORDER BY R.RtrId
		END 
	END
	---- Commented By Sathish.P on 1/Aug/2013
	
	----ELSE	
	----BEGIN
	----	IF @Pi_TaxGroupId<>0
	----	BEGIN
	----		INSERT INTO TempMassRetailer
	----		SELECT RtrId,RtrCode,RtrName FROM Retailer (NOLOCK)
	----			WHERE TaxGroupId=@Pi_TaxGroupId ORDER BY RtrId
	----	END
	----	ELSE
	----	BEGIN
	----		INSERT INTO TempMassRetailer
	----		SELECT RtrId,RtrCode,RtrName FROM Retailer (NOLOCK) ORDER BY RtrId
				
	----	END 
	----END 
	
	----Till Here
END
GO
UPDATE PRODUCT SET PrdCCode='BCHBBA2L1' WHERE PrdCCode='BCHBB150gms-30+0-5+0'
UPDATE PRODUCT SET PrdCCode='BCHBBA7L1' WHERE PrdCCode='BCHBB150gms-33+3-11+1'
UPDATE PRODUCT SET PrdCCode='BCHBBACL1' WHERE PrdCCode='BCHBB150gms-36+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHBBE4L1' WHERE PrdCCode='BCHBB155gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHBBE2L2' WHERE PrdCCode='BCHBB167gms-30+0-5+0'
UPDATE PRODUCT SET PrdCCode='BCHBBA4L1' WHERE PrdCCode='BCHBB32.1gms-288+0-24+0'
UPDATE PRODUCT SET PrdCCode='BCHBBADL1' WHERE PrdCCode='BCHBB32.1gms-288+12-24+1'
UPDATE PRODUCT SET PrdCCode='BCHBBA3L1' WHERE PrdCCode='BCHBB32.1gms-300+0-30+0'
UPDATE PRODUCT SET PrdCCode='BCHBBE6L1' WHERE PrdCCode='BCHBB40gms-300+0-20+0'
UPDATE PRODUCT SET PrdCCode='BCHBBE3L1' WHERE PrdCCode='BCHBB44.5gms-300+0-20+0'
UPDATE PRODUCT SET PrdCCode='BCHBBA9L1' WHERE PrdCCode='BCHBB75+25gms-55+5-11+1'
UPDATE PRODUCT SET PrdCCode='BCHBBA6L1' WHERE PrdCCode='BCHBB75gms-55+5-11+1'
UPDATE PRODUCT SET PrdCCode='BCHBBA1L1' WHERE PrdCCode='BCHBB75gms-60+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCHBBABL1' WHERE PrdCCode='BCHBB75gms-60+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHBBE1L2' WHERE PrdCCode='BCHBB78gms-60+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCHFCA2L1' WHERE PrdCCode='BCHFC100gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHFCA3L1' WHERE PrdCCode='BCHFC100gms-68+4-17+1'
UPDATE PRODUCT SET PrdCCode='BCHFCA4L1' WHERE PrdCCode='BCHFC100gms-72+0-18+0'
UPDATE PRODUCT SET PrdCCode='BCHFCA1L1' WHERE PrdCCode='BCHFC112gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHFOA2L1' WHERE PrdCCode='BCHFO100gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHFOA3L1' WHERE PrdCCode='BCHFO100gms-68+4-17+1'
UPDATE PRODUCT SET PrdCCode='BCHFOA4L1' WHERE PrdCCode='BCHFO100gms-72+0-18+0'
UPDATE PRODUCT SET PrdCCode='BCHFOA1L1' WHERE PrdCCode='BCHFO112gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHFSA2L1' WHERE PrdCCode='BCHFS100gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHFSA3L1' WHERE PrdCCode='BCHFS100gms-68+4-17+1'
UPDATE PRODUCT SET PrdCCode='BCHFSA4L1' WHERE PrdCCode='BCHFS100gms-72+0-18+0'
UPDATE PRODUCT SET PrdCCode='BCHFSA1L1' WHERE PrdCCode='BCHFS112gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHFVA2L1' WHERE PrdCCode='BCHFV100gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHFVA3L1' WHERE PrdCCode='BCHFV100gms-68+4-17+1'
UPDATE PRODUCT SET PrdCCode='BCHFVA4L1' WHERE PrdCCode='BCHFV100gms-72+0-18+0'
UPDATE PRODUCT SET PrdCCode='BCHFVA1L1' WHERE PrdCCode='BCHFV112gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHCASL1' WHERE PrdCCode='BCHHC120gms-72+0-18+0'
UPDATE PRODUCT SET PrdCCode='BCHHCAOL1' WHERE PrdCCode='BCHHC33gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHHCA7L1' WHERE PrdCCode='BCHHC44gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHHCARL1' WHERE PrdCCode='BCHHC75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHCAGL1' WHERE PrdCCode='BCHHC75gms-75+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHCAEL1' WHERE PrdCCode='BCHHC82.5+16.5gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHCA3L1' WHERE PrdCCode='BCHHC82.5gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHCAKL1' WHERE PrdCCode='BCHHC82.5gms-60+4-15+1'
UPDATE PRODUCT SET PrdCCode='BCHHCA1L1' WHERE PrdCCode='BCHHC93.75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHMAGL1' WHERE PrdCCode='BCHHM75gms-75+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHMA3L1' WHERE PrdCCode='BCHHM82.5gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHMA1L1' WHERE PrdCCode='BCHHM93.75gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHNAFL1' WHERE PrdCCode='BCHHN121+22gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHNA8L1' WHERE PrdCCode='BCHHN121gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHNAIL1' WHERE PrdCCode='BCHHN150gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHNA7L1' WHERE PrdCCode='BCHHN44gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHHNAGL1' WHERE PrdCCode='BCHHN75gms-75+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHNAEL1' WHERE PrdCCode='BCHHN82.5+16.5gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHNA6L1' WHERE PrdCCode='BCHHN82.5gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHOAGL1' WHERE PrdCCode='BCHHO75gms-75+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHOA3L1' WHERE PrdCCode='BCHHO82.5gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHOA1L1' WHERE PrdCCode='BCHHO93.75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAHL1' WHERE PrdCCode='BCHHS100gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAPL1' WHERE PrdCCode='BCHHS120gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSASL1' WHERE PrdCCode='BCHHS120gms-72+0-18+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAFL1' WHERE PrdCCode='BCHHS121+22gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSA8L1' WHERE PrdCCode='BCHHS121gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAIL1' WHERE PrdCCode='BCHHS150gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAQL1' WHERE PrdCCode='BCHHS16.5gms-384+0-32+0'
UPDATE PRODUCT SET PrdCCode='BCHHSA9L1' WHERE PrdCCode='BCHHS165gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSA2L2' WHERE PrdCCode='BCHHS187.5gms-48+0-2+0'
UPDATE PRODUCT SET PrdCCode='BCHHSC1M1' WHERE PrdCCode='BCHHS200gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSATL1' WHERE PrdCCode='BCHHS200gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSADL1' WHERE PrdCCode='BCHHS22gms-240+0-60+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAAL1' WHERE PrdCCode='BCHHS22gms-288+0-24+0'
UPDATE PRODUCT SET PrdCCode='BCHHSACL1' WHERE PrdCCode='BCHHS22gms-324+0-27+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAOL1' WHERE PrdCCode='BCHHS33gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHHSA7L1' WHERE PrdCCode='BCHHS44gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHHSA5L1' WHERE PrdCCode='BCHHS50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHHSABL1' WHERE PrdCCode='BCHHS528gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSE8L1' WHERE PrdCCode='BCHHS600gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSARL1' WHERE PrdCCode='BCHHS75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAGL1' WHERE PrdCCode='BCHHS75gms-75+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAEL1' WHERE PrdCCode='BCHHS82.5+16.5gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHSA6L1' WHERE PrdCCode='BCHHS82.5gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHHSAKL1' WHERE PrdCCode='BCHHS82.5gms-60+4-15+1'
UPDATE PRODUCT SET PrdCCode='BCHHSJ1M2' WHERE PrdCCode='BCHHS900gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHHSA1L1' WHERE PrdCCode='BCHHS93.75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BCHMBE2L1' WHERE PrdCCode='BCHMB135gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMBE5L1' WHERE PrdCCode='BCHMB144gms-44+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMBE3L1' WHERE PrdCCode='BCHMB65gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMBE4L1' WHERE PrdCCode='BCHMB72gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMCE8L1' WHERE PrdCCode='BCHMC100gms-48+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHMCE2L2' WHERE PrdCCode='BCHMC135gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMCE5L1' WHERE PrdCCode='BCHMC144gms-44+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMCE7L1' WHERE PrdCCode='BCHMC150gms-44+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMCE3L2' WHERE PrdCCode='BCHMC65gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMCE4L1' WHERE PrdCCode='BCHMC72gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMCA2L1' WHERE PrdCCode='BCHMC75gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMCE9L1' WHERE PrdCCode='BCHMC75gms-44+4-11+1'
UPDATE PRODUCT SET PrdCCode='BCHMCA1L1' WHERE PrdCCode='BCHMC75gms-48+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCHMCE6L1' WHERE PrdCCode='BCHMC75gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMDE2L1' WHERE PrdCCode='BCHMD135gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMDE5L1' WHERE PrdCCode='BCHMD144gms-44+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMDE3L1' WHERE PrdCCode='BCHMD65gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMDE4L1' WHERE PrdCCode='BCHMD72gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMEE2L1' WHERE PrdCCode='BCHME135gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMEE5L1' WHERE PrdCCode='BCHME144gms-44+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMEE3L1' WHERE PrdCCode='BCHME65gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMEE4L1' WHERE PrdCCode='BCHME72gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCHMVE3L1' WHERE PrdCCode='BCHMV390gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCA6L1' WHERE PrdCCode='BCKBC100gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCAGL1' WHERE PrdCCode='BCKBC100gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCKBCA2L1' WHERE PrdCCode='BCKBC108gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCA97L' WHERE PrdCCode='BCKBC110gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCKBCP8L3' WHERE PrdCCode='BCKBC117gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCA5L1' WHERE PrdCCode='BCKBC195gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCA8L1' WHERE PrdCCode='BCKBC195gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCA3L1' WHERE PrdCCode='BCKBC198gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCAAL1' WHERE PrdCCode='BCKBC200gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCP7L3' WHERE PrdCCode='BCKBC215gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCAHL1' WHERE PrdCCode='BCKBC45gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BCKBCADL1' WHERE PrdCCode='BCKBC45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKBCABL1' WHERE PrdCCode='BCKBC50gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BCKBCA4L1' WHERE PrdCCode='BCKBC50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKBCA1L1' WHERE PrdCCode='BCKBC60gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCP6L3' WHERE PrdCCode='BCKBC65gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCAEL1' WHERE PrdCCode='BCKBC90gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKBCAFL1' WHERE PrdCCode='BCKBC90gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCKCBA6L1' WHERE PrdCCode='BCKCB100gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBAGL1' WHERE PrdCCode='BCKCB100gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCKCBA2L1' WHERE PrdCCode='BCKCB108gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBA97L' WHERE PrdCCode='BCKCB110gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCKCBP8L3' WHERE PrdCCode='BCKCB117gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBA5L1' WHERE PrdCCode='BCKCB195gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBA8L1' WHERE PrdCCode='BCKCB195gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBA3L1' WHERE PrdCCode='BCKCB198gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBAAL1' WHERE PrdCCode='BCKCB200gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBP7L3' WHERE PrdCCode='BCKCB215gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBAHL1' WHERE PrdCCode='BCKCB45gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BCKCBADL1' WHERE PrdCCode='BCKCB45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKCBA4L1' WHERE PrdCCode='BCKCB50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKCBA1L1' WHERE PrdCCode='BCKCB60gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBP6L3' WHERE PrdCCode='BCKCB65gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCBAFL1' WHERE PrdCCode='BCKCB90gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCKCBAEL1' WHERE PrdCCode='BCKCB90gms-90+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKCNA6L1' WHERE PrdCCode='BCKCN100gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCNA1L1' WHERE PrdCCode='BCKCN150gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCNA8L1' WHERE PrdCCode='BCKCN200gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCNA3L1' WHERE PrdCCode='BCKCN300gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCNA4L1' WHERE PrdCCode='BCKCN50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKCNA5L1' WHERE PrdCCode='BCKCN60gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKCNA7L1' WHERE PrdCCode='BCKCN60gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKCNA2L1' WHERE PrdCCode='BCKCN75gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKHHA4L1' WHERE PrdCCode='BCKHH100gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKHHA7L1' WHERE PrdCCode='BCKHH150gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKHHA8L1' WHERE PrdCCode='BCKHH40gms-138+6-23+1'
UPDATE PRODUCT SET PrdCCode='BCKHHA5L1' WHERE PrdCCode='BCKHH40gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKHHAAL1' WHERE PrdCCode='BCKHH40gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BCKHHA1L1' WHERE PrdCCode='BCKHH45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKHHA3L1' WHERE PrdCCode='BCKHH50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKHHA6L1' WHERE PrdCCode='BCKHH75gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKHHA9L1' WHERE PrdCCode='BCKHH75gms-92+4-23+1'
UPDATE PRODUCT SET PrdCCode='BCKHHABL1' WHERE PrdCCode='BCKHH75gms-96+0-24+0'
UPDATE PRODUCT SET PrdCCode='BCKHHA2L1' WHERE PrdCCode='BCKHH85gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKKEA6L1' WHERE PrdCCode='BCKKE100gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKKEA8L1' WHERE PrdCCode='BCKKE195gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKKEAAL1' WHERE PrdCCode='BCKKE200gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCKKEAHL1' WHERE PrdCCode='BCKKE45gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BCKKEADL1' WHERE PrdCCode='BCKKE45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCKKEABL1' WHERE PrdCCode='BCKKE50gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BCKKEA4L1' WHERE PrdCCode='BCKKE50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BCRBBE2L3' WHERE PrdCCode='BCRBB100gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCRBBE7L1' WHERE PrdCCode='BCRBB150gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCRBBE5L1' WHERE PrdCCode='BCRBB160gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCRBBE3L3' WHERE PrdCCode='BCRBB200gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BCRBBE6L1' WHERE PrdCCode='BCRBB75gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BCRBBE4L1' WHERE PrdCCode='BCRBB80gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BFSCHA6L1' WHERE PrdCCode='BFSCH100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSCHA2L1' WHERE PrdCCode='BFSCH107.6gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSCHA5L1' WHERE PrdCCode='BFSCH57.2gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSCHA1L1' WHERE PrdCCode='BFSCH61.5gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSELA6L1' WHERE PrdCCode='BFSEL100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSELA2L1' WHERE PrdCCode='BFSEL122.5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSELA5L1' WHERE PrdCCode='BFSEL57.2gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSELA1L1' WHERE PrdCCode='BFSEL70gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSMGA6L1' WHERE PrdCCode='BFSMG100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSMGA2L1' WHERE PrdCCode='BFSMG122.5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSMGA5L1' WHERE PrdCCode='BFSMG57.2gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSMGA1L1' WHERE PrdCCode='BFSMG70gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSORA6L1' WHERE PrdCCode='BFSOR100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSORA2L1' WHERE PrdCCode='BFSOR122.5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSORA5L1' WHERE PrdCCode='BFSOR57.2gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSORA1L1' WHERE PrdCCode='BFSOR70gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSPNA6L1' WHERE PrdCCode='BFSPN100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSPNA2L1' WHERE PrdCCode='BFSPN122.5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BFSPNA5L1' WHERE PrdCCode='BFSPN57.2gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BFSPNA1L1' WHERE PrdCCode='BFSPN70gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BGFASA6L1' WHERE PrdCCode='BGFAS700gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFASA4L1' WHERE PrdCCode='BGFAS797.5gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFASA5L1' WHERE PrdCCode='BGFAS816gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFASA1L1' WHERE PrdCCode='BGFAS822gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BGFASA3L1' WHERE PrdCCode='BGFAS903.7gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFASA2L1' WHERE PrdCCode='BGFAS971gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='BGFBBA1L1' WHERE PrdCCode='BGFBB702gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFFSA1L1' WHERE PrdCCode='BGFFS980gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFHSA2L1' WHERE PrdCCode='BGFHS495gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFHSA1L1' WHERE PrdCCode='BGFHS609gms-84+0-12+0'
UPDATE PRODUCT SET PrdCCode='BGFMCA2L1' WHERE PrdCCode='BGFMC400gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFMCA1L1' WHERE PrdCCode='BGFMC432gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGFMLA1L1' WHERE PrdCCode='BGFML360gms-60+0-12+0'
UPDATE PRODUCT SET PrdCCode='BGSBCA3L1' WHERE PrdCCode='BGSBC150+50gms-45+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGSBCA1L1' WHERE PrdCCode='BGSBC75+15gms-56+4-14+1'
UPDATE PRODUCT SET PrdCCode='BGSCBA2L1' WHERE PrdCCode='BGSCB100+20gms-56+4-14+1'
UPDATE PRODUCT SET PrdCCode='BGSCBA3L1' WHERE PrdCCode='BGSCB150+50gms-45+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGSCBA4L1' WHERE PrdCCode='BGSCB200+50gms-45+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGSCBA1L1' WHERE PrdCCode='BGSCB75+15gms-56+4-14+1'
UPDATE PRODUCT SET PrdCCode='BGSCHA2L1' WHERE PrdCCode='BGSCH150gms-45+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGSCHA1L1' WHERE PrdCCode='BGSCH75gms-59+1-14+1'
UPDATE PRODUCT SET PrdCCode='BGSCNA2L1' WHERE PrdCCode='BGSCN150gms-45+0-1+0'
UPDATE PRODUCT SET PrdCCode='BGSCNA1L1' WHERE PrdCCode='BGSCN75gms-56+4-14+1'
UPDATE PRODUCT SET PrdCCode='BJMINA3L1' WHERE PrdCCode='BJMIN150gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BJMINA2L1' WHERE PrdCCode='BJMIN75gms-72+0-6+0'
UPDATE PRODUCT SET PrdCCode='BJMINA1L1' WHERE PrdCCode='BJMIN77gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGCHR6L1' WHERE PrdCCode='BKGCH100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGCHR2L1' WHERE PrdCCode='BKGCH100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGCHR3L1' WHERE PrdCCode='BKGCH200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGCHR5L1' WHERE PrdCCode='BKGCH50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGCHR4L1' WHERE PrdCCode='BKGCH50gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BKGCHR1L1' WHERE PrdCCode='BKGCH50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGELR6L1' WHERE PrdCCode='BKGEL100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGELR2L1' WHERE PrdCCode='BKGEL100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGELR3L1' WHERE PrdCCode='BKGEL200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGELR5L1' WHERE PrdCCode='BKGEL50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGELR4L1' WHERE PrdCCode='BKGEL50gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BKGELR1L1' WHERE PrdCCode='BKGEL50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGMGR6L1' WHERE PrdCCode='BKGMG100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGMGR2L1' WHERE PrdCCode='BKGMG100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGMGR3L1' WHERE PrdCCode='BKGMG200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGMGR5L1' WHERE PrdCCode='BKGMG50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGMGR4L1' WHERE PrdCCode='BKGMG50gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BKGMGR1L1' WHERE PrdCCode='BKGMG50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGORR6L1' WHERE PrdCCode='BKGOR100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGORR2L1' WHERE PrdCCode='BKGOR100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGORR3L1' WHERE PrdCCode='BKGOR200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGORR5L1' WHERE PrdCCode='BKGOR50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGORR4L1' WHERE PrdCCode='BKGOR50gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BKGORR1L1' WHERE PrdCCode='BKGOR50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGPNR6L1' WHERE PrdCCode='BKGPN100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGPNR2L1' WHERE PrdCCode='BKGPN100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGPNR3L1' WHERE PrdCCode='BKGPN200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKGPNR5L1' WHERE PrdCCode='BKGPN50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKGPNR4L1' WHERE PrdCCode='BKGPN50gms-132+12-11+1'
UPDATE PRODUCT SET PrdCCode='BKGPNR1L1' WHERE PrdCCode='BKGPN50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRCHA5L1' WHERE PrdCCode='BKRCH100+12gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHA2L1' WHERE PrdCCode='BKRCH100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHP5L1' WHERE PrdCCode='BKRCH104gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHP2L1' WHERE PrdCCode='BKRCH130gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHR2L1' WHERE PrdCCode='BKRCH138.4gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHP8L1' WHERE PrdCCode='BKRCH20gms-264+0-33+0'
UPDATE PRODUCT SET PrdCCode='BKRCHP4L1' WHERE PrdCCode='BKRCH20gms-360+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHP3L1' WHERE PrdCCode='BKRCH25gms-280+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHP7L1' WHERE PrdCCode='BKRCH25gms-280+0-35+0'
UPDATE PRODUCT SET PrdCCode='BKRCHA4L1' WHERE PrdCCode='BKRCH50+6gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BKRCHA3L1' WHERE PrdCCode='BKRCH50gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BKRCHA1L1' WHERE PrdCCode='BKRCH50gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKRCHP6L1' WHERE PrdCCode='BKRCH52gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHP1L2' WHERE PrdCCode='BKRCH65gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRCHR1L1' WHERE PrdCCode='BKRCH69.2gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRELA6L1' WHERE PrdCCode='BKREL100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRELE8L1' WHERE PrdCCode='BKREL100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRELA2L1' WHERE PrdCCode='BKREL120gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRELE6L1' WHERE PrdCCode='BKREL140gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRELE4L1' WHERE PrdCCode='BKREL160gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRELE9L1' WHERE PrdCCode='BKREL200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRELA4L1' WHERE PrdCCode='BKREL50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRELA5L1' WHERE PrdCCode='BKREL50+7gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKRELA7L1' WHERE PrdCCode='BKREL50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRELE7L1' WHERE PrdCCode='BKREL50gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKRELA1L1' WHERE PrdCCode='BKREL60gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRELA3L1' WHERE PrdCCode='BKREL60gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BKRELE5L1' WHERE PrdCCode='BKREL70gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRELE3L1' WHERE PrdCCode='BKREL80gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRELE1M1' WHERE PrdCCode='BKREL90gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMCA4L1' WHERE PrdCCode='BKRMC152gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMCA2L1' WHERE PrdCCode='BKRMC190gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMCA3L1' WHERE PrdCCode='BKRMC76gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BKRMCA1L1' WHERE PrdCCode='BKRMC95gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNA6L1' WHERE PrdCCode='BKRMN100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE8L1' WHERE PrdCCode='BKRMN100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNA2L1' WHERE PrdCCode='BKRMN120gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE6L1' WHERE PrdCCode='BKRMN140gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE4L1' WHERE PrdCCode='BKRMN160gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE2L2' WHERE PrdCCode='BKRMN180gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE9L1' WHERE PrdCCode='BKRMN200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNA4L1' WHERE PrdCCode='BKRMN50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRMNA5L1' WHERE PrdCCode='BKRMN50+7gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKRMNA7L1' WHERE PrdCCode='BKRMN50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE7L1' WHERE PrdCCode='BKRMN50gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKRMNA1L1' WHERE PrdCCode='BKRMN60gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRMNA3L1' WHERE PrdCCode='BKRMN60gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE5L1' WHERE PrdCCode='BKRMN70gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE3L1' WHERE PrdCCode='BKRMN80gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRMNE1L1' WHERE PrdCCode='BKRMN90gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKROCA6L1' WHERE PrdCCode='BKROC100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKROCE8L1' WHERE PrdCCode='BKROC100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKROCA2L1' WHERE PrdCCode='BKROC120gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKROCE6L1' WHERE PrdCCode='BKROC140gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKROCE4L1' WHERE PrdCCode='BKROC160gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKROCE9L1' WHERE PrdCCode='BKROC200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKROCA4L1' WHERE PrdCCode='BKROC50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKROCA5L1' WHERE PrdCCode='BKROC50+7gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKROCA7L1' WHERE PrdCCode='BKROC50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKROCE7L1' WHERE PrdCCode='BKROC50gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKROCA1L1' WHERE PrdCCode='BKROC60gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKROCA3L1' WHERE PrdCCode='BKROC60gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BKROCE5L1' WHERE PrdCCode='BKROC70gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKROCE3L1' WHERE PrdCCode='BKROC80gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRPNA6L1' WHERE PrdCCode='BKRPN100+14gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRPNE8L1' WHERE PrdCCode='BKRPN100gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRPNA2L1' WHERE PrdCCode='BKRPN120gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRPNE6L1' WHERE PrdCCode='BKRPN140gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRPNE4L1' WHERE PrdCCode='BKRPN160gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRPNE2L1' WHERE PrdCCode='BKRPN180gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRPNE9L1' WHERE PrdCCode='BKRPN200gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BKRPNA4L1' WHERE PrdCCode='BKRPN50+7gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRPNA5L1' WHERE PrdCCode='BKRPN50+7gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKRPNA7L1' WHERE PrdCCode='BKRPN50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRPNE7L1' WHERE PrdCCode='BKRPN50gms-144+0-6+0'
UPDATE PRODUCT SET PrdCCode='BKRPNA1L1' WHERE PrdCCode='BKRPN60gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRPNA3L1' WHERE PrdCCode='BKRPN60gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BKRPNE5L1' WHERE PrdCCode='BKRPN70gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BKRPNE3L1' WHERE PrdCCode='BKRPN80gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMPMCA6L1' WHERE PrdCCode='BMPMC120gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMPMCA4L1' WHERE PrdCCode='BMPMC150gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMPMCA2L1' WHERE PrdCCode='BMPMC152gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMPMCA5L1' WHERE PrdCCode='BMPMC60gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BMPMCA3L1' WHERE PrdCCode='BMPMC75gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BMPMCA1L1' WHERE PrdCCode='BMPMC76gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BMRDIAEL1' WHERE PrdCCode='BMRDI100gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRDIAHL1' WHERE PrdCCode='BMRDI120gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRDIA7L1' WHERE PrdCCode='BMRDI134.4gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRDIA5L1' WHERE PrdCCode='BMRDI144gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRDIA3L1' WHERE PrdCCode='BMRDI160gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRDIE8L1' WHERE PrdCCode='BMRDI170gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRDIAFL1' WHERE PrdCCode='BMRDI250gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRDIA8L1' WHERE PrdCCode='BMRDI264gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRDIA6L1' WHERE PrdCCode='BMRDI279gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRDIAIL1' WHERE PrdCCode='BMRDI300gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRDIE9L1' WHERE PrdCCode='BMRDI330gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRDIADL1' WHERE PrdCCode='BMRDI50gms-120+0-5+0'
UPDATE PRODUCT SET PrdCCode='BMRDIAGL1' WHERE PrdCCode='BMRDI60gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BMRDIA4L1' WHERE PrdCCode='BMRDI67gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BMRDIAAL1' WHERE PrdCCode='BMRDI67gms-120+0-24+0'
UPDATE PRODUCT SET PrdCCode='BMRDIE7L1' WHERE PrdCCode='BMRDI77gms-160+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCM1L1' WHERE PrdCCode='BMRMC10.34gms-810+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCCOL1' WHERE PrdCCode='BMRMC100+20gms-30+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRMCCML1' WHERE PrdCCode='BMRMC100+20gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRMCCGL1' WHERE PrdCCode='BMRMC100gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBNL1' WHERE PrdCCode='BMRMC100gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRMCR2L1' WHERE PrdCCode='BMRMC10gms-810+0-45+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBWL1' WHERE PrdCCode='BMRMC120gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBBL1' WHERE PrdCCode='BMRMC134.4gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB7L1' WHERE PrdCCode='BMRMC134+10gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB5L1' WHERE PrdCCode='BMRMC140+20gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBKL1' WHERE PrdCCode='BMRMC144gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB2L1' WHERE PrdCCode='BMRMC150+20gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBOL1' WHERE PrdCCode='BMRMC150gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB3L1' WHERE PrdCCode='BMRMC201+25gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB8L1' WHERE PrdCCode='BMRMC201gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCC1L1' WHERE PrdCCode='BMRMC202+30gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBPL1' WHERE PrdCCode='BMRMC250gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBIL1' WHERE PrdCCode='BMRMC264gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB9L1' WHERE PrdCCode='BMRMC279gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB4L1' WHERE PrdCCode='BMRMC300+30gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCC4L1' WHERE PrdCCode='BMRMC300+40gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBQL1' WHERE PrdCCode='BMRMC300gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCCBL1' WHERE PrdCCode='BMRMC300gms-16+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBDL1' WHERE PrdCCode='BMRMC301.5+50gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBJL1' WHERE PrdCCode='BMRMC310gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBEL1' WHERE PrdCCode='BMRMC322+50gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCE8L1' WHERE PrdCCode='BMRMC342+30gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCE7L2' WHERE PrdCCode='BMRMC342+50gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCAAL1' WHERE PrdCCode='BMRMC400gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCCCL1' WHERE PrdCCode='BMRMC400gms-16+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBML1' WHERE PrdCCode='BMRMC50gms-120+0-5+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBVL1' WHERE PrdCCode='BMRMC60gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB1L1' WHERE PrdCCode='BMRMC67+10gms-160+0-1+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBUL1' WHERE PrdCCode='BMRMC67gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BMRMCB6L1' WHERE PrdCCode='BMRMC67gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BMRMCBFL1' WHERE PrdCCode='BMRMC67gms-120+0-5+0'
UPDATE PRODUCT SET PrdCCode='BSFCCA1L1' WHERE PrdCCode='BSFCC100gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSFCCA3L1' WHERE PrdCCode='BSFCC106.96gms-48+0-16+0'
UPDATE PRODUCT SET PrdCCode='BSFCCA8L1' WHERE PrdCCode='BSFCC120gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSFCCA7L1' WHERE PrdCCode='BSFCC200+50gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSFCCA5L1' WHERE PrdCCode='BSFCC200gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSFCCA2L1' WHERE PrdCCode='BSFCC214gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSFCCA4L1' WHERE PrdCCode='BSFCC229.5gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSFCCA6L1' WHERE PrdCCode='BSFCC250gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLCHAAB1' WHERE PrdCCode='BSLCH150gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLCHADB1' WHERE PrdCCode='BSLCH150gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLCHABB1' WHERE PrdCCode='BSLCH300gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLCHACT1' WHERE PrdCCode='BSLCH3500gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLCHD2T1' WHERE PrdCCode='BSLCH3700gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLJZJ1B1' WHERE PrdCCode='BSLJZ200gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLJZD1T1' WHERE PrdCCode='BSLJZ4500gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMIR2B1' WHERE PrdCCode='BSLMI120gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMIR1B3' WHERE PrdCCode='BSLMI75gms-75+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNAMB1' WHERE PrdCCode='BSLMN100+20gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNAHB1' WHERE PrdCCode='BSLMN100gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNA4B1' WHERE PrdCCode='BSLMN120+24gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNA6B1' WHERE PrdCCode='BSLMN120gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNAFB1' WHERE PrdCCode='BSLMN196+44gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNABB1' WHERE PrdCCode='BSLMN196gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNANB1' WHERE PrdCCode='BSLMN200+40gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNAIB1' WHERE PrdCCode='BSLMN200gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNA5B1' WHERE PrdCCode='BSLMN240+48gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNP8B2' WHERE PrdCCode='BSLMN240gms-42+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNB5L1' WHERE PrdCCode='BSLMN40gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSLMNB1B1' WHERE PrdCCode='BSLMN40gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMNAOL1' WHERE PrdCCode='BSLMN50+10gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSLMNALB1' WHERE PrdCCode='BSLMN50+10gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMNAKL1' WHERE PrdCCode='BSLMN50gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSLMNAGB1' WHERE PrdCCode='BSLMN50gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMNACB1' WHERE PrdCCode='BSLMN51.8+8.2gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMNA7L1' WHERE PrdCCode='BSLMN51.8gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMNA2L1' WHERE PrdCCode='BSLMN60+12gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNB7B1' WHERE PrdCCode='BSLMN60gms-75+0-25+0'
UPDATE PRODUCT SET PrdCCode='BSLMNR9L1' WHERE PrdCCode='BSLMN60gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMNADB1' WHERE PrdCCode='BSLMN63.3+11.7gms-75+0-25+0'
UPDATE PRODUCT SET PrdCCode='BSLMNA8B1' WHERE PrdCCode='BSLMN63.3gms-75+0-25+0'
UPDATE PRODUCT SET PrdCCode='BSLMNA3B1' WHERE PrdCCode='BSLMN75+15gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNR1B6' WHERE PrdCCode='BSLMN75gms-75+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNB2B1' WHERE PrdCCode='BSLMN80gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNAEB1' WHERE PrdCCode='BSLMN98+22gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMNA9B1' WHERE PrdCCode='BSLMN98gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZA8L1' WHERE PrdCCode='BSLMZ100+20gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZA6L1' WHERE PrdCCode='BSLMZ100gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZA4L1' WHERE PrdCCode='BSLMZ120+24gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZR2B1' WHERE PrdCCode='BSLMZ120gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZB3B1' WHERE PrdCCode='BSLMZ40gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZB1B1' WHERE PrdCCode='BSLMZ40gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMZA7L1' WHERE PrdCCode='BSLMZ50+10gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMZA5L1' WHERE PrdCCode='BSLMZ50gms-90+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSLMZR4L1' WHERE PrdCCode='BSLMZ63.3gms-75+0-25+0'
UPDATE PRODUCT SET PrdCCode='BSLMZA3L1' WHERE PrdCCode='BSLMZ75+15gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZR1B3' WHERE PrdCCode='BSLMZ75gms-75+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZB2B1' WHERE PrdCCode='BSLMZ80gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLMZR3L1' WHERE PrdCCode='BSLMZ98gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLNKEDL1' WHERE PrdCCode='BSLNK100gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLNKE6L1' WHERE PrdCCode='BSLNK120gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLNKEEL1' WHERE PrdCCode='BSLNK45gms-96+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSLNKECL1' WHERE PrdCCode='BSLNK50gms-96+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSLNKEAL1' WHERE PrdCCode='BSLNK60+9gms-96+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSLNKE9L1' WHERE PrdCCode='BSLNK60gms-96+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSLNKE8L1' WHERE PrdCCode='BSLNK72gms-96+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLNKE1L5' WHERE PrdCCode='BSLNK75gms-96+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLSXJ5B1' WHERE PrdCCode='BSLSX200gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSLSXD1T1' WHERE PrdCCode='BSLSX5000gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAKL1' WHERE PrdCCode='BSSKJ100+20gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAFL1' WHERE PrdCCode='BSSKJ100gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJB5L1' WHERE PrdCCode='BSSKJ104+19.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJABL1' WHERE PrdCCode='BSSKJ104gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJA7L1' WHERE PrdCCode='BSSKJ110.5gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJA2L1' WHERE PrdCCode='BSSKJ117gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJASL1' WHERE PrdCCode='BSSKJ120gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJB2L1' WHERE PrdCCode='BSSKJ165.7gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJALL1' WHERE PrdCCode='BSSKJ200+40gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAGL1' WHERE PrdCCode='BSSKJ200gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJB6L1' WHERE PrdCCode='BSSKJ208+39gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJACL1' WHERE PrdCCode='BSSKJ208gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAPL1' WHERE PrdCCode='BSSKJ220+20gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJA8L1' WHERE PrdCCode='BSSKJ221gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJA3L1' WHERE PrdCCode='BSSKJ234gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJF4B1' WHERE PrdCCode='BSSKJ240gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAUL1' WHERE PrdCCode='BSSKJ40gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAQL1' WHERE PrdCCode='BSSKJ40gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAML1' WHERE PrdCCode='BSSKJ50+10gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAJL1' WHERE PrdCCode='BSSKJ50+10gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAIL1' WHERE PrdCCode='BSSKJ50gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAEL1' WHERE PrdCCode='BSSKJ50gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSSKJB3L1' WHERE PrdCCode='BSSKJ52+13gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSSKJADL1' WHERE PrdCCode='BSSKJ52gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSSKJB7L1' WHERE PrdCCode='BSSKJ58.5+16.25gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSSKJB4L1' WHERE PrdCCode='BSSKJ58.5+16.25gms-96+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSSKJB8L1' WHERE PrdCCode='BSSKJ58.5gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSSKJA9L1' WHERE PrdCCode='BSSKJ58.5gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAAL1' WHERE PrdCCode='BSSKJ58.5gms-96+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAVL1' WHERE PrdCCode='BSSKJ60gms-96+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSSKJA1L1' WHERE PrdCCode='BSSKJ65gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJAHL1' WHERE PrdCCode='BSSKJ65gms-96+0-16+0'
UPDATE PRODUCT SET PrdCCode='BSSKJB1L1' WHERE PrdCCode='BSSKJ71.5gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJE1B7' WHERE PrdCCode='BSSKJ75gms-96+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSKJARL1' WHERE PrdCCode='BSSKJ80gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSTPA4L1' WHERE PrdCCode='BSSTP100gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSTPA7L1' WHERE PrdCCode='BSSTP200+50gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSTPA6L1' WHERE PrdCCode='BSSTP200gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSTPA3L1' WHERE PrdCCode='BSSTP210gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSTPA1L1' WHERE PrdCCode='BSSTP240+30gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSTPA2L1' WHERE PrdCCode='BSSTP240gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSSTPACL1' WHERE PrdCCode='BSSTP40gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSSTPA5L1' WHERE PrdCCode='BSSTP50gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSSTPABL1' WHERE PrdCCode='BSSTP90gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWGAO3L1' WHERE PrdCCode='BSWGA130gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWGAO2L1' WHERE PrdCCode='BSWGA65gms-112+0-14+0'
UPDATE PRODUCT SET PrdCCode='BSWGAO4L1' WHERE PrdCCode='BSWGA65gms-162+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWGCA6L1' WHERE PrdCCode='BSWGC12.5gms-1200+0-50+0'
UPDATE PRODUCT SET PrdCCode='BSWGCA7L1' WHERE PrdCCode='BSWGC12.5gms-600+0-50+0'
UPDATE PRODUCT SET PrdCCode='BSWGCA5L1' WHERE PrdCCode='BSWGC150gms-48+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWGCA4L1' WHERE PrdCCode='BSWGC75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BSWGLA6L1' WHERE PrdCCode='BSWGL12.5gms-1200+0-50+0'
UPDATE PRODUCT SET PrdCCode='BSWGLA7L1' WHERE PrdCCode='BSWGL12.5gms-600+0-50+0'
UPDATE PRODUCT SET PrdCCode='BSWGLA5L1' WHERE PrdCCode='BSWGL150gms-48+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWGLA4L1' WHERE PrdCCode='BSWGL75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BSWGOA6L1' WHERE PrdCCode='BSWGO12.5gms-1200+0-50+0'
UPDATE PRODUCT SET PrdCCode='BSWGOA7L1' WHERE PrdCCode='BSWGO12.5gms-600+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWGOA2L1' WHERE PrdCCode='BSWGO130gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWGOA5L1' WHERE PrdCCode='BSWGO150gms-48+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWGOA1L1' WHERE PrdCCode='BSWGO65gms-112+0-14+0'
UPDATE PRODUCT SET PrdCCode='BSWGOA3L1' WHERE PrdCCode='BSWGO65gms-162+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWGOA4L1' WHERE PrdCCode='BSWGO75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BSWGPA2L1' WHERE PrdCCode='BSWGP130gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWGPA1L1' WHERE PrdCCode='BSWGP65gms-112+0-14+0'
UPDATE PRODUCT SET PrdCCode='BSWGPA3L1' WHERE PrdCCode='BSWGP65gms-162+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWGSA6L1' WHERE PrdCCode='BSWGS12.5gms-1200+0-50+0'
UPDATE PRODUCT SET PrdCCode='BSWGSA7L1' WHERE PrdCCode='BSWGS12.5gms-600+0-50+0'
UPDATE PRODUCT SET PrdCCode='BSWGSA5L1' WHERE PrdCCode='BSWGS150gms-48+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWGSA4L1' WHERE PrdCCode='BSWGS75gms-60+0-15+0'
UPDATE PRODUCT SET PrdCCode='BSWMGA2L1' WHERE PrdCCode='BSWMG100gms-48+0-8+0'
UPDATE PRODUCT SET PrdCCode='BSWMGA1L1' WHERE PrdCCode='BSWMG50gms-96+0-8+0'
UPDATE PRODUCT SET PrdCCode='BSWMPA7L1' WHERE PrdCCode='BSWMP100gms-64+0-16+0'
UPDATE PRODUCT SET PrdCCode='BSWMPA4L1' WHERE PrdCCode='BSWMP128gms-64+0-16+0'
UPDATE PRODUCT SET PrdCCode='BSWMPA2L1' WHERE PrdCCode='BSWMP128gms-90+0-15+0'
UPDATE PRODUCT SET PrdCCode='BSWMPA6L1' WHERE PrdCCode='BSWMP50gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWMPA5L1' WHERE PrdCCode='BSWMP60gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWMPA1L1' WHERE PrdCCode='BSWMP85gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSWMPA3L1' WHERE PrdCCode='BSWMP85gms-96+0-16+0'
UPDATE PRODUCT SET PrdCCode='BSWMSA9L1' WHERE PrdCCode='BSWMS100+26gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMSA4L1' WHERE PrdCCode='BSWMS100+50gms-108+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWMSA3L1' WHERE PrdCCode='BSWMS100+50gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMSA7L1' WHERE PrdCCode='BSWMS100+50gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWMSP9L1' WHERE PrdCCode='BSWMS120+30gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMSAAL1' WHERE PrdCCode='BSWMS-134+260gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWMSP8L4' WHERE PrdCCode='BSWMS150+46gms-64+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMSA1A1' WHERE PrdCCode='BSWMS150gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMSP6L6' WHERE PrdCCode='BSWMS150gms-96+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMSA8L1' WHERE PrdCCode='BSWMS50+13gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWMSA2L1' WHERE PrdCCode='BSWMS50+25gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWMSP7L2' WHERE PrdCCode='BSWMS75+23gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMSP5L1' WHERE PrdCCode='BSWMS75gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMWA8L1' WHERE PrdCCode='BSWMW100gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSWMWA6L1' WHERE PrdCCode='BSWMW103.4gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSWMWA4L1' WHERE PrdCCode='BSWMW121gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMWA2L1' WHERE PrdCCode='BSWMW137.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMWA7L1' WHERE PrdCCode='BSWMW50gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWMWA5L1' WHERE PrdCCode='BSWMW56.4gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWMWA3L1' WHERE PrdCCode='BSWMW66gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMWA1L1' WHERE PrdCCode='BSWMW75gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMXA8L1' WHERE PrdCCode='BSWMX100gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSWMXA6L1' WHERE PrdCCode='BSWMX103.4gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSWMXA4L1' WHERE PrdCCode='BSWMX121gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMXA2L1' WHERE PrdCCode='BSWMX137.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMXA7L1' WHERE PrdCCode='BSWMX50gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWMXA5L1' WHERE PrdCCode='BSWMX56.4gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWMXA3L1' WHERE PrdCCode='BSWMX66gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWMXA1L1' WHERE PrdCCode='BSWMX75gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBML1' WHERE PrdCCode='BSWPG100gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCPB1' WHERE PrdCCode='BSWPG133.4gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCQL1' WHERE PrdCCode='BSWPG133.4gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBGL1' WHERE PrdCCode='BSWPG133+26.6gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAZL1' WHERE PrdCCode='BSWPG14.1gms-480+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBHL1' WHERE PrdCCode='BSWPG140+28gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGEIB1' WHERE PrdCCode='BSWPG144gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGEJL1' WHERE PrdCCode='BSWPG144gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDIB1' WHERE PrdCCode='BSWPG150gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDLL1' WHERE PrdCCode='BSWPG150gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAQL1' WHERE PrdCCode='BSWPG156+32gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAOL1' WHERE PrdCCode='BSWPG159.8gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM8L1' WHERE PrdCCode='BSWPG16.5gms-480+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBJL1' WHERE PrdCCode='BSWPG16.8gms-480+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGOCL1' WHERE PrdCCode='BSWPG160+20gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGOBL1' WHERE PrdCCode='BSWPG160gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAUL1' WHERE PrdCCode='BSWPG169.2gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGN2L1' WHERE PrdCCode='BSWPG173.5+5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGO3B1' WHERE PrdCCode='BSWPG176gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGR2L1' WHERE PrdCCode='BSWPG178+34gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAJL1' WHERE PrdCCode='BSWPG18.8gms-480+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAEB1' WHERE PrdCCode='BSWPG188gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAPL1' WHERE PrdCCode='BSWPG188gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGC3L1' WHERE PrdCCode='BSWPG190gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGN8B1' WHERE PrdCCode='BSWPG198gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGN6L1' WHERE PrdCCode='BSWPG209+22gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM4B1' WHERE PrdCCode='BSWPG209gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGN4L1' WHERE PrdCCode='BSWPG210.5gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGO7B1' WHERE PrdCCode='BSWPG2190gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCGB1' WHERE PrdCCode='BSWPG25gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSWPGENB1' WHERE PrdCCode='BSWPG28gms-348+12-29+1'
UPDATE PRODUCT SET PrdCCode='BSWPGEAB1' WHERE PrdCCode='BSWPG28gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCBB1' WHERE PrdCCode='BSWPG29.19gms-348+12-29+1'
UPDATE PRODUCT SET PrdCCode='BSWPGDAB1' WHERE PrdCCode='BSWPG29.19gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBFL1' WHERE PrdCCode='BSWPG294+58.8gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCRL1' WHERE PrdCCode='BSWPG300gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM5B1' WHERE PrdCCode='BSWPG313.5gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGASB1' WHERE PrdCCode='BSWPG32.9gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDTL1' WHERE PrdCCode='BSWPG33.33+4.17gms-240+12-20+1'
UPDATE PRODUCT SET PrdCCode='BSWPGAVB1' WHERE PrdCCode='BSWPG338.4gms-36+0-18+0'
UPDATE PRODUCT SET PrdCCode='BSWPGQ1B1' WHERE PrdCCode='BSWPG33gms-360+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGO4B1' WHERE PrdCCode='BSWPG352gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCTL1' WHERE PrdCCode='BSWPG37.5gms-138+6-23+1'
UPDATE PRODUCT SET PrdCCode='BSWPGCKL1' WHERE PrdCCode='BSWPG37.5gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBRL1' WHERE PrdCCode='BSWPG37.5gms-144+6-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGCUB1' WHERE PrdCCode='BSWPG37.5gms-184+8-23+1'
UPDATE PRODUCT SET PrdCCode='BSWPGCJL1' WHERE PrdCCode='BSWPG37.5gms-192+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCML1' WHERE PrdCCode='BSWPG37.5gms-192+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBSL1' WHERE PrdCCode='BSWPG37.5gms-192+8-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGCVL1' WHERE PrdCCode='BSWPG37.5gms-216+8-27+1'
UPDATE PRODUCT SET PrdCCode='BSWPGCLL1' WHERE PrdCCode='BSWPG37.5gms-224+0-28+0'
UPDATE PRODUCT SET PrdCCode='BSWPGABB1' WHERE PrdCCode='BSWPG37.6gms-360+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAFB1' WHERE PrdCCode='BSWPG376gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM2B1' WHERE PrdCCode='BSWPG38.5gms-360+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGEBL1' WHERE PrdCCode='BSWPG40gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGETL1' WHERE PrdCCode='BSWPG40gms-144+6-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGEEL1' WHERE PrdCCode='BSWPG40gms-192+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWPGECL1' WHERE PrdCCode='BSWPG40gms-192+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGERL1' WHERE PrdCCode='BSWPG40gms-192+8-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGEFL1' WHERE PrdCCode='BSWPG40gms-224+0-28+0'
UPDATE PRODUCT SET PrdCCode='BSWPGC4L1' WHERE PrdCCode='BSWPG41.7gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCCL1' WHERE PrdCCode='BSWPG41.7gms-138+6-23+1'
UPDATE PRODUCT SET PrdCCode='BSWPGDEL1' WHERE PrdCCode='BSWPG41.7gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCEL1' WHERE PrdCCode='BSWPG41.7gms-184+8-23+1'
UPDATE PRODUCT SET PrdCCode='BSWPGDDL1' WHERE PrdCCode='BSWPG41.7gms-192+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDGL1' WHERE PrdCCode='BSWPG41.7gms-192+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCDL1' WHERE PrdCCode='BSWPG41.7gms-216+8-27+1'
UPDATE PRODUCT SET PrdCCode='BSWPGDFL1' WHERE PrdCCode='BSWPG41.7gms-224+0-28+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM6B1' WHERE PrdCCode='BSWPG418gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBOL1' WHERE PrdCCode='BSWPG42+8.4gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBDL1' WHERE PrdCCode='BSWPG42+8.4gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBIL1' WHERE PrdCCode='BSWPG42+8.4gms-192+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBEL1' WHERE PrdCCode='BSWPG42+8.4gms-224+0-28+0'
UPDATE PRODUCT SET PrdCCode='BSWPGD7L6' WHERE PrdCCode='BSWPG440gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDVL1' WHERE PrdCCode='BSWPG45+5gms-144+6-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGANL1' WHERE PrdCCode='BSWPG47+9.4gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBCL1' WHERE PrdCCode='BSWPG47+9.4gms-224+0-28+0'
UPDATE PRODUCT SET PrdCCode='BSWPGP9L1' WHERE PrdCCode='BSWPG50+10gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGOFA1' WHERE PrdCCode='BSWPG50+5gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGXIP1' WHERE PrdCCode='BSWPG500gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAWB1' WHERE PrdCCode='BSWPG507.6gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCHB1' WHERE PrdCCode='BSWPG50gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCZB1' WHERE PrdCCode='BSWPG50gms-144+6-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGO5B1' WHERE PrdCCode='BSWPG528gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGO8L1' WHERE PrdCCode='BSWPG55+5.5gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGB9L1' WHERE PrdCCode='BSWPG55+5.5gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGOAL1' WHERE PrdCCode='BSWPG55gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGO9L1' WHERE PrdCCode='BSWPG55gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGADL1' WHERE PrdCCode='BSWPG56.4gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAKL1' WHERE PrdCCode='BSWPG56.4gms-244+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGXBP1' WHERE PrdCCode='BSWPG564gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBAL1' WHERE PrdCCode='BSWPG564gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAGB1' WHERE PrdCCode='BSWPG564gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGEGB1' WHERE PrdCCode='BSWPG56gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGEOB1' WHERE PrdCCode='BSWPG56gms-144+6-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGDBB1' WHERE PrdCCode='BSWPG58.38gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGX7P1' WHERE PrdCCode='BSWPG587.5gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGN1L1' WHERE PrdCCode='BSWPG60.5+12.1gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM9L1' WHERE PrdCCode='BSWPG60.5+6gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM3L1' WHERE PrdCCode='BSWPG60.5gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDPL1' WHERE PrdCCode='BSWPG600gms-16+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGX8P1' WHERE PrdCCode='BSWPG611gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGX9P1' WHERE PrdCCode='BSWPG648.6gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCWB1' WHERE PrdCCode='BSWPG66.7gms-138+6-23+1'
UPDATE PRODUCT SET PrdCCode='BSWPGCIB1' WHERE PrdCCode='BSWPG66.7gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDUB1' WHERE PrdCCode='BSWPG66.7gms-144+6-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGAXB1' WHERE PrdCCode='BSWPG676.8gms-16+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGX4P1' WHERE PrdCCode='BSWPG687.5gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGX5P1' WHERE PrdCCode='BSWPG693gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGX6L1' WHERE PrdCCode='BSWPG693gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGATB1' WHERE PrdCCode='BSWPG70.5gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCSL1' WHERE PrdCCode='BSWPG700gms-14+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGP7B1' WHERE PrdCCode='BSWPG71.5gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGX3P1' WHERE PrdCCode='BSWPG726gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGEQL1' WHERE PrdCCode='BSWPG72gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='BSWPGEHB1' WHERE PrdCCode='BSWPG72gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGEPB1' WHERE PrdCCode='BSWPG72gms-144+6-24+1'
UPDATE PRODUCT SET PrdCCode='BSWPGX2P1' WHERE PrdCCode='BSWPG742.5gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAAB1' WHERE PrdCCode='BSWPG75.2gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDRL1' WHERE PrdCCode='BSWPG750gms-14+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAHB1' WHERE PrdCCode='BSWPG752gms-16+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDWL1' WHERE PrdCCode='BSWPG75gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSWPGCAB1' WHERE PrdCCode='BSWPG75gms-138+6-23+1'
UPDATE PRODUCT SET PrdCCode='BSWPGDCB1' WHERE PrdCCode='BSWPG75gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGODB1' WHERE PrdCCode='BSWPG77gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGELL1' WHERE PrdCCode='BSWPG800gms-14+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGDYL1' WHERE PrdCCode='BSWPG80gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM1B1' WHERE PrdCCode='BSWPG82.5gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGM7L1' WHERE PrdCCode='BSWPG825gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGARB1' WHERE PrdCCode='BSWPG84.6gms-144+0-24+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAYB1' WHERE PrdCCode='BSWPG846gms-14+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGP8B1' WHERE PrdCCode='BSWPG88+5.5gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGO6B1' WHERE PrdCCode='BSWPG880gms-14+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGD9L4' WHERE PrdCCode='BSWPG880gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGD1B1' WHERE PrdCCode='BSWPG88gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGA1E3' WHERE PrdCCode='BSWPG88gms-168+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAIB1' WHERE PrdCCode='BSWPG940gms-14+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGACB1' WHERE PrdCCode='BSWPG94gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGBNL1' WHERE PrdCCode='BSWPG94gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSWPGAMB1' WHERE PrdCCode='BSWPG94gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPGALL1' WHERE PrdCCode='BSWPG99gms-120+0-20+0'
UPDATE PRODUCT SET PrdCCode='BSWPGA2E3' WHERE PrdCCode='BSWPG99gms-160+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPMC7L1' WHERE PrdCCode='BSWPM121gms-90+0-10+0'
UPDATE PRODUCT SET PrdCCode='BSWPMC5L2' WHERE PrdCCode='BSWPM137.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPMC6L1' WHERE PrdCCode='BSWPM66gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='BSWPMC1L4' WHERE PrdCCode='BSWPM75gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='CCKCHA1L1' WHERE PrdCCode='CCKCH80gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='CCKTFA2L1' WHERE PrdCCode='CCKTF50gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='CCKTFA1L1' WHERE PrdCCode='CCKTF80gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='CCKVNA2L1' WHERE PrdCCode='CCKVN50gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='CCKVNA1L1' WHERE PrdCCode='CCKVN80gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACBJL1' WHERE PrdCCode='MCPAC13+2.6gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACBNL1' WHERE PrdCCode='MCPAC13+2.6gms-180+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPACBDL1' WHERE PrdCCode='MCPAC13+2.6gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPACC4L1' WHERE PrdCCode='MCPAC13gms-161+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACC1L1' WHERE PrdCCode='MCPAC13gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACP4L1' WHERE PrdCCode='MCPAC14.65+7.35gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACA3L1' WHERE PrdCCode='MCPAC14+2.8gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACB1L1' WHERE PrdCCode='MCPAC14+3gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACBAL1' WHERE PrdCCode='MCPAC14+3gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPACA2L2' WHERE PrdCCode='MCPAC17gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACBEL1' WHERE PrdCCode='MCPAC25+5gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPACC2L1' WHERE PrdCCode='MCPAC26gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACC5L1' WHERE PrdCCode='MCPAC26gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACB5L1' WHERE PrdCCode='MCPAC28+6gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACB9L1' WHERE PrdCCode='MCPAC28+6gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACB2L1' WHERE PrdCCode='MCPAC30+6gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACA4L1' WHERE PrdCCode='MCPAC30+6gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACBKL1' WHERE PrdCCode='MCPAC30gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACBOL1' WHERE PrdCCode='MCPAC30gms-120+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPACP5L1' WHERE PrdCCode='MCPAC33.5+16.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPACA1L1' WHERE PrdCCode='MCPAC9+1.8gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPBBA1L1' WHERE PrdCCode='MCPBB108+36gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPBBA2L1' WHERE PrdCCode='MCPBB168gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBJL1' WHERE PrdCCode='MCPCO13+2.6gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBNL1' WHERE PrdCCode='MCPCO13+2.6gms-180+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBDL1' WHERE PrdCCode='MCPCO13+2.6gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPCOC4L1' WHERE PrdCCode='MCPCO13gms-161+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOC1L1' WHERE PrdCCode='MCPCO13gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOB1L1' WHERE PrdCCode='MCPCO14+3gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBAL1' WHERE PrdCCode='MCPCO14+3gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBEL1' WHERE PrdCCode='MCPCO25+5gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPCOC2L1' WHERE PrdCCode='MCPCO26gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOC5L1' WHERE PrdCCode='MCPCO26gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOB5L1' WHERE PrdCCode='MCPCO28+6gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOB9L1' WHERE PrdCCode='MCPCO28+6gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOB2L1' WHERE PrdCCode='MCPCO30+6gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBKL1' WHERE PrdCCode='MCPCO30gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBOL1' WHERE PrdCCode='MCPCO30gms-120+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBML1' WHERE PrdCCode='MCPCO32gms-120+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBIL1' WHERE PrdCCode='MCPCO54+11gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBFL1' WHERE PrdCCode='MCPCO54+11gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOC3L1' WHERE PrdCCode='MCPCO56gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOB8L1' WHERE PrdCCode='MCPCO60+12gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOB6L1' WHERE PrdCCode='MCPCO60+12gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBBL1' WHERE PrdCCode='MCPCO61+12.2gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBLL1' WHERE PrdCCode='MCPCO61gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBQL1' WHERE PrdCCode='MCPCO7.5+1.5gms-260+20-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOB4L1' WHERE PrdCCode='MCPCO70+14gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCOBPL1' WHERE PrdCCode='MCPCO70gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSD2L1' WHERE PrdCCode='MCPCS102gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBJL1' WHERE PrdCCode='MCPCS13+2.6gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBNL1' WHERE PrdCCode='MCPCS13+2.6gms-180+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBDL1' WHERE PrdCCode='MCPCS13+2.6gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPCSC4L1' WHERE PrdCCode='MCPCS13gms-161+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSC1L1' WHERE PrdCCode='MCPCS13gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSP4L1' WHERE PrdCCode='MCPCS14.65+7.35gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSA3L1' WHERE PrdCCode='MCPCS14+2.8gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSB1L1' WHERE PrdCCode='MCPCS14+3gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBAL1' WHERE PrdCCode='MCPCS14+3gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPCSA2L1' WHERE PrdCCode='MCPCS17gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBEL1' WHERE PrdCCode='MCPCS25+5gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPCSC2L1' WHERE PrdCCode='MCPCS26gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSC5L1' WHERE PrdCCode='MCPCS26gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSB5L1' WHERE PrdCCode='MCPCS28+6gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSB9L1' WHERE PrdCCode='MCPCS28+6gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSB7L1' WHERE PrdCCode='MCPCS28+6gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSB2L1' WHERE PrdCCode='MCPCS30+6gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSA4L1' WHERE PrdCCode='MCPCS30+6gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBKL1' WHERE PrdCCode='MCPCS30gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBOL1' WHERE PrdCCode='MCPCS30gms-120+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBML1' WHERE PrdCCode='MCPCS32gms-120+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBGL1' WHERE PrdCCode='MCPCS32gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPCSP5L1' WHERE PrdCCode='MCPCS33.5+16.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSD1L1' WHERE PrdCCode='MCPCS36gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBFL1' WHERE PrdCCode='MCPCS54+11gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSA5L1' WHERE PrdCCode='MCPCS56+28gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSC3L1' WHERE PrdCCode='MCPCS56gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSB8L1' WHERE PrdCCode='MCPCS60+12gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSB6L1' WHERE PrdCCode='MCPCS60+12gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBBL1' WHERE PrdCCode='MCPCS61+12.2gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBLL1' WHERE PrdCCode='MCPCS61gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBQL1' WHERE PrdCCode='MCPCS7.5+1.5gms-260+20-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSB4L1' WHERE PrdCCode='MCPCS70+14gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBPL1' WHERE PrdCCode='MCPCS70gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSA1L1' WHERE PrdCCode='MCPCS9+1.8gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPCSBHL1' WHERE PrdCCode='MCPCS95gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPKMC4L1' WHERE PrdCCode='MCPKM13gms-161+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPKMC1L1' WHERE PrdCCode='MCPKM13gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBJL1' WHERE PrdCCode='MCPMM13+2.6gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBNL1' WHERE PrdCCode='MCPMM13+2.6gms-180+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBDL1' WHERE PrdCCode='MCPMM13+2.6gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPMMC4L1' WHERE PrdCCode='MCPMM13gms-161+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMC1L1' WHERE PrdCCode='MCPMM13gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMB1L1' WHERE PrdCCode='MCPMM14+3gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBAL1' WHERE PrdCCode='MCPMM14+3gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBEL1' WHERE PrdCCode='MCPMM25+5gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPMMC2L1' WHERE PrdCCode='MCPMM26gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMC5L1' WHERE PrdCCode='MCPMM26gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMB5L1' WHERE PrdCCode='MCPMM28+6gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMB9L1' WHERE PrdCCode='MCPMM28+6gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMB2L1' WHERE PrdCCode='MCPMM30+6gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBKL1' WHERE PrdCCode='MCPMM30gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBOL1' WHERE PrdCCode='MCPMM30gms-120+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBML1' WHERE PrdCCode='MCPMM32gms-120+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBGL1' WHERE PrdCCode='MCPMM32gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPMMD1L1' WHERE PrdCCode='MCPMM36gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMBQL1' WHERE PrdCCode='MCPMM7.5+1.5gms-260+20-1+0'
UPDATE PRODUCT SET PrdCCode='MCPMMB4L1' WHERE PrdCCode='MCPMM70+14gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPPPC4L1' WHERE PrdCCode='MCPPP13gms-161+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPPPC1L1' WHERE PrdCCode='MCPPP13gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCBJL1' WHERE PrdCCode='MCPRC13+2.6gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCBNL1' WHERE PrdCCode='MCPRC13+2.6gms-180+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPRCBDL1' WHERE PrdCCode='MCPRC13+2.6gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPRCC4L1' WHERE PrdCCode='MCPRC13gms-161+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCC1L1' WHERE PrdCCode='MCPRC13gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCP4L1' WHERE PrdCCode='MCPRC14.65+7.35gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCA3L1' WHERE PrdCCode='MCPRC14+2.8gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCB1L1' WHERE PrdCCode='MCPRC14+3gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCBAL1' WHERE PrdCCode='MCPRC14+3gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPRCA2L1' WHERE PrdCCode='MCPRC17gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCBEL1' WHERE PrdCCode='MCPRC25+5gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPRCC2L1' WHERE PrdCCode='MCPRC26gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCC5L1' WHERE PrdCCode='MCPRC26gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCB5L1' WHERE PrdCCode='MCPRC28+6gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCB9L1' WHERE PrdCCode='MCPRC28+6gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCB2L1' WHERE PrdCCode='MCPRC30+6gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCA4L1' WHERE PrdCCode='MCPRC30+6gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCBKL1' WHERE PrdCCode='MCPRC30gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCBOL1' WHERE PrdCCode='MCPRC30gms-120+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPRCP5L1' WHERE PrdCCode='MCPRC33.5+16.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPRCA1L1' WHERE PrdCCode='MCPRC9+1.8gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPSSP4L1' WHERE PrdCCode='MCPSS14.65+7.35gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPSSA3L1' WHERE PrdCCode='MCPSS14+2.8gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPSSA4L1' WHERE PrdCCode='MCPSS30+6gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPSSP5L1' WHERE PrdCCode='MCPSS33.5+16.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPSSA1L1' WHERE PrdCCode='MCPSS9+1.8gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBJL1' WHERE PrdCCode='MCPTT13+2.6gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBNL1' WHERE PrdCCode='MCPTT13+2.6gms-180+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBDL1' WHERE PrdCCode='MCPTT13+2.6gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPTTC4L1' WHERE PrdCCode='MCPTT13gms-161+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTC1L1' WHERE PrdCCode='MCPTT13gms-173+7-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTP4L1' WHERE PrdCCode='MCPTT14.65+7.35gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTA3L1' WHERE PrdCCode='MCPTT14+2.8gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTB1L1' WHERE PrdCCode='MCPTT14+3gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBAL1' WHERE PrdCCode='MCPTT14+3gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MCPTTA2L1' WHERE PrdCCode='MCPTT17gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBEL1' WHERE PrdCCode='MCPTT-20+50gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPTTC2L1' WHERE PrdCCode='MCPTT26gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTC5L1' WHERE PrdCCode='MCPTT26gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTB5L1' WHERE PrdCCode='MCPTT28+6gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTB9L1' WHERE PrdCCode='MCPTT28+6gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTB7L1' WHERE PrdCCode='MCPTT28+6gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTB2L1' WHERE PrdCCode='MCPTT30+6gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTA4L1' WHERE PrdCCode='MCPTT30+6gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBKL1' WHERE PrdCCode='MCPTT30gms-115+5-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBOL1' WHERE PrdCCode='MCPTT30gms-120+0-15+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBML1' WHERE PrdCCode='MCPTT32gms-120+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBGL1' WHERE PrdCCode='MCPTT32gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MCPTTP5L1' WHERE PrdCCode='MCPTT33.5+16.5gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTD1L1' WHERE PrdCCode='MCPTT36gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBFL1' WHERE PrdCCode='MCPTT54+11gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTA5L1' WHERE PrdCCode='MCPTT56+28gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTC3L1' WHERE PrdCCode='MCPTT560gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBCL1' WHERE PrdCCode='MCPTT60.8+12.2gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTB8L1' WHERE PrdCCode='MCPTT60+12gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTB6L1' WHERE PrdCCode='MCPTT60+12gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBBL1' WHERE PrdCCode='MCPTT61+12.2gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBLL1' WHERE PrdCCode='MCPTT61gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBQL1' WHERE PrdCCode='MCPTT7.5+1.5gms-260+20-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTB4L1' WHERE PrdCCode='MCPTT70+14gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTBPL1' WHERE PrdCCode='MCPTT70gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MCPTTA1L1' WHERE PrdCCode='MCPTT9+1.8gms-192+0-1+0'
UPDATE PRODUCT SET PrdCCode='MDLMGA3L1' WHERE PrdCCode='MDLMG150gms-96+0-8+0'
UPDATE PRODUCT SET PrdCCode='MDLMGAAL1' WHERE PrdCCode='MDLMG20+5gms-346+14-1+0'
UPDATE PRODUCT SET PrdCCode='MDLMGA7L1' WHERE PrdCCode='MDLMG20+5gms-360+0-12+0'
UPDATE PRODUCT SET PrdCCode='MDLMGA1L1' WHERE PrdCCode='MDLMG20gms-600+0-50+0'
UPDATE PRODUCT SET PrdCCode='MDLMGA4L1' WHERE PrdCCode='MDLMG25gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='MDLMGABL1' WHERE PrdCCode='MDLMG40+10gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MDLMGA8L1' WHERE PrdCCode='MDLMG40+10gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MDLMGA2L1' WHERE PrdCCode='MDLMG40gms-300+0-25+0'
UPDATE PRODUCT SET PrdCCode='MDLMGA5L1' WHERE PrdCCode='MDLMG55gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MDLMGACL1' WHERE PrdCCode='MDLMG80+20gms-46+2-1+0'
UPDATE PRODUCT SET PrdCCode='MDLMGA9L1' WHERE PrdCCode='MDLMG80+20gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA6L1' WHERE PrdCCode='MMXKM100gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA9L1' WHERE PrdCCode='MMXKM140gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA3L1' WHERE PrdCCode='MMXKM150gms-96+0-8+0'
UPDATE PRODUCT SET PrdCCode='MMXKMAFL1' WHERE PrdCCode='MMXKM20+5gms-346+14-1+0'
UPDATE PRODUCT SET PrdCCode='MMXKMACL1' WHERE PrdCCode='MMXKM20+5gms-360+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA4L1' WHERE PrdCCode='MMXKM25gms-300+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA7L1' WHERE PrdCCode='MMXKM30gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA1L1' WHERE PrdCCode='MMXKM35gms-300+0-25+0'
UPDATE PRODUCT SET PrdCCode='MMXKMADL1' WHERE PrdCCode='MMXKM40+10gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MMXKMAAL1' WHERE PrdCCode='MMXKM40+10gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA5L1' WHERE PrdCCode='MMXKM50gms-180+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA8L1' WHERE PrdCCode='MMXKM65gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXKMA2L1' WHERE PrdCCode='MMXKM70gms-150+0-15+0'
UPDATE PRODUCT SET PrdCCode='MMXKMAEL1' WHERE PrdCCode='MMXKM80+20gms-46+2-1+0'
UPDATE PRODUCT SET PrdCCode='MMXKMABL1' WHERE PrdCCode='MMXKM80+20gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MMXMXAEL1' WHERE PrdCCode='MMXMX-100+200gms-46+2-1+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA6L1' WHERE PrdCCode='MMXMX100gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA9L1' WHERE PrdCCode='MMXMX140gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA3L1' WHERE PrdCCode='MMXMX150gms-96+0-8+0'
UPDATE PRODUCT SET PrdCCode='MMXMXAFL1' WHERE PrdCCode='MMXMX20+5gms-346+14-1+0'
UPDATE PRODUCT SET PrdCCode='MMXMXACL1' WHERE PrdCCode='MMXMX20+5gms-360+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA4L1' WHERE PrdCCode='MMXMX25gms-300+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA7L1' WHERE PrdCCode='MMXMX30gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA1L1' WHERE PrdCCode='MMXMX35gms-300+0-25+0'
UPDATE PRODUCT SET PrdCCode='MMXMXADL1' WHERE PrdCCode='MMXMX40+10gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MMXMXAAL1' WHERE PrdCCode='MMXMX490+10gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA5L1' WHERE PrdCCode='MMXMX50gms-180+0-12+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA8L1' WHERE PrdCCode='MMXMX65gms-144+0-15+0'
UPDATE PRODUCT SET PrdCCode='MMXMXA2L1' WHERE PrdCCode='MMXMX70gms-150+0-15+0'
UPDATE PRODUCT SET PrdCCode='MMXMXAGL1' WHERE PrdCCode='MMXMX80+20gms-46+2-1+0'
UPDATE PRODUCT SET PrdCCode='MMXMXABL1' WHERE PrdCCode='MMXMX80+20gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCCCP1B1' WHERE PrdCCode='MSCCC25gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCCCM1B1' WHERE PrdCCode='MSCCC50gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCMMP1B1' WHERE PrdCCode='MSCMM25gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCMMP3B1' WHERE PrdCCode='MSCMM28gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCMMP2B1' WHERE PrdCCode='MSCMM50gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCSSP1B1' WHERE PrdCCode='MSCSS25gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCSSP2B1' WHERE PrdCCode='MSCSS50gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCTTP1B1' WHERE PrdCCode='MSCTT25gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCTTP3B1' WHERE PrdCCode='MSCTT28gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSCTTM1B1' WHERE PrdCCode='MSCTT50gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLACA2A1' WHERE PrdCCode='MSLAC160gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLACA4A1' WHERE PrdCCode='MSLAC20gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLACA3A1' WHERE PrdCCode='MSLAC320gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLACA1A1' WHERE PrdCCode='MSLAC55gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCHA9B1' WHERE PrdCCode='MSLCH150gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCHA2A1' WHERE PrdCCode='MSLCH160gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCHA8B1' WHERE PrdCCode='MSLCH300gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCHA3A1' WHERE PrdCCode='MSLCH320gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCHD4T1' WHERE PrdCCode='MSLCH3500gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCHD2T1' WHERE PrdCCode='MSLCH3700gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCHA5A1' WHERE PrdCCode='MSLCH70gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCHA4A1' WHERE PrdCCode='MSLCH70gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSLCSA2A1' WHERE PrdCCode='MSLCS160gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCSA4A1' WHERE PrdCCode='MSLCS20gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCSA3A1' WHERE PrdCCode='MSLCS320gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCSA1A1' WHERE PrdCCode='MSLCS55gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLCSA7A1' WHERE PrdCCode='MSLCS55gms-96+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLGMA2A1' WHERE PrdCCode='MSLGM160gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLGMA4A1' WHERE PrdCCode='MSLGM20gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLGMA3A1' WHERE PrdCCode='MSLGM320gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLGMA1A1' WHERE PrdCCode='MSLGM55gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLMMA2A1' WHERE PrdCCode='MSLMM160gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLMMA4A1' WHERE PrdCCode='MSLMM20gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLMMA3A1' WHERE PrdCCode='MSLMM320gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSLMMA1A1' WHERE PrdCCode='MSLMM55gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTBBA1L1' WHERE PrdCCode='MSTBB180+60gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTBBA2L1' WHERE PrdCCode='MSTBB300gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTCCP7L1' WHERE PrdCCode='MSTCC20+10gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTCCB4L1' WHERE PrdCCode='MSTCC21+4.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTCCBDL1' WHERE PrdCCode='MSTCC21+4.2gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTCCA3L1' WHERE PrdCCode='MSTCC22+4.4gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTCCB7L1' WHERE PrdCCode='MSTCC46+9.2gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTCCA4L1' WHERE PrdCCode='MSTCC50+10gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTCCP8L1' WHERE PrdCCode='MSTCC50+20gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMB6L1' WHERE PrdCCode='MSTGM110+22gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMB8L1' WHERE PrdCCode='MSTGM110+22gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBYL1' WHERE PrdCCode='MSTGM110gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBEL1' WHERE PrdCCode='MSTGM111+22.2gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMB3L1' WHERE PrdCCode='MSTGM120+30gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBZL1' WHERE PrdCCode='MSTGM19+4gms-202+8-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBWL1' WHERE PrdCCode='MSTGM19+4gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBHL1' WHERE PrdCCode='MSTGM20+5gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTGMB4L1' WHERE PrdCCode='MSTGM21+4.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBDL1' WHERE PrdCCode='MSTGM21+4.2gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBNL1' WHERE PrdCCode='MSTGM21gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBRL1' WHERE PrdCCode='MSTGM21gms-225+0-15+0'
UPDATE PRODUCT SET PrdCCode='MSTGMB1L1' WHERE PrdCCode='MSTGM22+5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBIL1' WHERE PrdCCode='MSTGM43+9gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBOL1' WHERE PrdCCode='MSTGM45gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBSL1' WHERE PrdCCode='MSTGM45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTGMB5L1' WHERE PrdCCode='MSTGM46+9.2gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMB7L1' WHERE PrdCCode='MSTGM46+9.2gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBBL1' WHERE PrdCCode='MSTGM46+9.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMB2L1' WHERE PrdCCode='MSTGM50+10gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBXL1' WHERE PrdCCode='MSTGM50gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBUL1' WHERE PrdCCode='MSTGM52gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBLL1' WHERE PrdCCode='MSTGM95+20gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBKL1' WHERE PrdCCode='MSTGM95+20gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTGMBQL1' WHERE PrdCCode='MSTGM95gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMB6L1' WHERE PrdCCode='MSTJM110+22gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMB3L1' WHERE PrdCCode='MSTJM120+30gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBZL1' WHERE PrdCCode='MSTJM19+4gms-202+8-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBWL1' WHERE PrdCCode='MSTJM19+4gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBHL1' WHERE PrdCCode='MSTJM20+5gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTJMB4L1' WHERE PrdCCode='MSTJM21+4.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBDL1' WHERE PrdCCode='MSTJM21+4.2gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBNL1' WHERE PrdCCode='MSTJM21gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBRL1' WHERE PrdCCode='MSTJM21gms-225+0-15+0'
UPDATE PRODUCT SET PrdCCode='MSTJMB1L1' WHERE PrdCCode='MSTJM22+5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBIL1' WHERE PrdCCode='MSTJM43+9gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBOL1' WHERE PrdCCode='MSTJM45gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBSL1' WHERE PrdCCode='MSTJM45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTJMB5L1' WHERE PrdCCode='MSTJM46+9.2gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMB7L1' WHERE PrdCCode='MSTJM46+9.2gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBBL1' WHERE PrdCCode='MSTJM46+9.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMB2L1' WHERE PrdCCode='MSTJM50+10gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTJMBXL1' WHERE PrdCCode='MSTJM50gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBZL1' WHERE PrdCCode='MSTMK19+4gms-202+8-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBWL1' WHERE PrdCCode='MSTMK19+4gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBHL1' WHERE PrdCCode='MSTMK20+5gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBDL1' WHERE PrdCCode='MSTMK21+4.2gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBNL1' WHERE PrdCCode='MSTMK21gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBRL1' WHERE PrdCCode='MSTMK21gms-225+0-15+0'
UPDATE PRODUCT SET PrdCCode='MSTMKB1L1' WHERE PrdCCode='MSTMK22+5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKB4L1' WHERE PrdCCode='MSTMK247.8+4.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBIL1' WHERE PrdCCode='MSTMK43+9gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBOL1' WHERE PrdCCode='MSTMK45gms-138+6-23+1'
UPDATE PRODUCT SET PrdCCode='MSTMKBSL1' WHERE PrdCCode='MSTMK45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMKB5L1' WHERE PrdCCode='MSTMK46+9.2gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKB7L1' WHERE PrdCCode='MSTMK46+9.2gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBBL1' WHERE PrdCCode='MSTMK46+9.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBAL1' WHERE PrdCCode='MSTMK46+9.2gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKB2L1' WHERE PrdCCode='MSTMK50+10gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBXL1' WHERE PrdCCode='MSTMK50gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBPL1' WHERE PrdCCode='MSTMK50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBVL1' WHERE PrdCCode='MSTMK50gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBUL1' WHERE PrdCCode='MSTMK52gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBJL1' WHERE PrdCCode='MSTMK54gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMKBCL1' WHERE PrdCCode='MSTMK60gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB9L1' WHERE PrdCCode='MSTMM10.4+2.6gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB6L1' WHERE PrdCCode='MSTMM110+22gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB8L1' WHERE PrdCCode='MSTMM110+22gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBYL1' WHERE PrdCCode='MSTMM110gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBEL1' WHERE PrdCCode='MSTMM111+22.2gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB3L1' WHERE PrdCCode='MSTMM120+30gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBGL1' WHERE PrdCCode='MSTMM12gms-416+0-13+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBZL1' WHERE PrdCCode='MSTMM19+4gms-202+8-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBWL1' WHERE PrdCCode='MSTMM19+4gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMP7L1' WHERE PrdCCode='MSTMM20+10gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBHL1' WHERE PrdCCode='MSTMM20+5gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB4L1' WHERE PrdCCode='MSTMM21+4.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBDL1' WHERE PrdCCode='MSTMM21+4.2gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBNL1' WHERE PrdCCode='MSTMM21gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBRL1' WHERE PrdCCode='MSTMM21gms-225+0-15+0'
UPDATE PRODUCT SET PrdCCode='MSTMMA3L1' WHERE PrdCCode='MSTMM22+4.4gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB1L1' WHERE PrdCCode='MSTMM22+5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMA2L1' WHERE PrdCCode='MSTMM27gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMP4L2' WHERE PrdCCode='MSTMM27gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMQ2L1' WHERE PrdCCode='MSTMM30gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMQ3L1' WHERE PrdCCode='MSTMM30gms-180+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMMQ1L1' WHERE PrdCCode='MSTMM30gms-60+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMP1L1' WHERE PrdCCode='MSTMM35gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBBL1' WHERE PrdCCode='MSTMM42.8+9.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBIL1' WHERE PrdCCode='MSTMM43+9gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBOL1' WHERE PrdCCode='MSTMM45gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBSL1' WHERE PrdCCode='MSTMM45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB5L1' WHERE PrdCCode='MSTMM46+9.2gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB7L1' WHERE PrdCCode='MSTMM46+9.2gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBAL1' WHERE PrdCCode='MSTMM46+9.2gms-90+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMB2L1' WHERE PrdCCode='MSTMM50+10gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMA4L1' WHERE PrdCCode='MSTMM50+10gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMP8L1' WHERE PrdCCode='MSTMM50+20gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBXL1' WHERE PrdCCode='MSTMM50gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBPL1' WHERE PrdCCode='MSTMM50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBVL1' WHERE PrdCCode='MSTMM50gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBUL1' WHERE PrdCCode='MSTMM52gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBJL1' WHERE PrdCCode='MSTMM54gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBCL1' WHERE PrdCCode='MSTMM60gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBLL1' WHERE PrdCCode='MSTMM95+20gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBKL1' WHERE PrdCCode='MSTMM95+20gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTMMBQL1' WHERE PrdCCode='MSTMM95gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTSCP9L1' WHERE PrdCCode='MSTSC120+30gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTSCP7L1' WHERE PrdCCode='MSTSC20+10gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTSCA3L1' WHERE PrdCCode='MSTSC22+4.4gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTSCA2L1' WHERE PrdCCode='MSTSC27gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTSCA4L1' WHERE PrdCCode='MSTSC50+10gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTSCP8L1' WHERE PrdCCode='MSTSC50+20gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBZL1' WHERE PrdCCode='MSTTP19+4gms-202+8-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBWL1' WHERE PrdCCode='MSTTP19+4gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBHL1' WHERE PrdCCode='MSTTP20+5gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTTPB4L1' WHERE PrdCCode='MSTTP21+4.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBDL1' WHERE PrdCCode='MSTTP21+4.2gms-84+0-14+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBNL1' WHERE PrdCCode='MSTTP21gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBRL1' WHERE PrdCCode='MSTTP21gms-225+0-15+0'
UPDATE PRODUCT SET PrdCCode='MSTTPB1L1' WHERE PrdCCode='MSTTP22+5gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBIL1' WHERE PrdCCode='MSTTP43+9gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBOL1' WHERE PrdCCode='MSTTP45gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBSL1' WHERE PrdCCode='MSTTP45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTTPB5L1' WHERE PrdCCode='MSTTP46+9.2gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPB7L1' WHERE PrdCCode='MSTTP46+9.2gms-54+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBBL1' WHERE PrdCCode='MSTTP46+9.2gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPB2L1' WHERE PrdCCode='MSTTP50+10gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBXL1' WHERE PrdCCode='MSTTP50gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBJL1' WHERE PrdCCode='MSTTP54gms-72+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTTPBCL1' WHERE PrdCCode='MSTTP60gms-72+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBYL1' WHERE PrdCCode='MSTTT110gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTP9L1' WHERE PrdCCode='MSTTT120+30gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBZL1' WHERE PrdCCode='MSTTT19+4gms-202+8-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBWL1' WHERE PrdCCode='MSTTT19+4gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTP7L1' WHERE PrdCCode='MSTTT20+10gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBNL1' WHERE PrdCCode='MSTTT21gms-216+9-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBRL1' WHERE PrdCCode='MSTTT21gms-225+0-15+0'
UPDATE PRODUCT SET PrdCCode='MSTTTA3L1' WHERE PrdCCode='MSTTT22+4.4gms-144+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBOL1' WHERE PrdCCode='MSTTT45gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBSL1' WHERE PrdCCode='MSTTT45gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTTTA4L1' WHERE PrdCCode='MSTTT50+10gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTP8L1' WHERE PrdCCode='MSTTT50+20gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBXL1' WHERE PrdCCode='MSTTT50gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBPL1' WHERE PrdCCode='MSTTT50gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBVL1' WHERE PrdCCode='MSTTT50gms-96+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSTTTBQL1' WHERE PrdCCode='MSTTT95gms-80+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSVABA6L1' WHERE PrdCCode='MSVAB140gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSVABA3L1' WHERE PrdCCode='MSVAB150gms-96+0-8+0'
UPDATE PRODUCT SET PrdCCode='MSVABACL1' WHERE PrdCCode='MSVAB20+5gms-346+14-1+0'
UPDATE PRODUCT SET PrdCCode='MSVABA9L1' WHERE PrdCCode='MSVAB20+5gms-360+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSVABA1L1' WHERE PrdCCode='MSVAB20gms-600+0-50+0'
UPDATE PRODUCT SET PrdCCode='MSVABA4L1' WHERE PrdCCode='MSVAB30gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='MSVABAAL1' WHERE PrdCCode='MSVAB40+10gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSVABA7L1' WHERE PrdCCode='MSVAB40+10gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSVABA2L1' WHERE PrdCCode='MSVAB40gms-300+0-25+0'
UPDATE PRODUCT SET PrdCCode='MSVABA5L1' WHERE PrdCCode='MSVAB65gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSVABABL1' WHERE PrdCCode='MSVAB80+20gms-46+2-1+0'
UPDATE PRODUCT SET PrdCCode='MSVABA8L1' WHERE PrdCCode='MSVAB80+20gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSVBBABL1' WHERE PrdCCode='MSVBB-100+200gms-46+2-1+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA6L1' WHERE PrdCCode='MSVBB140gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA3L1' WHERE PrdCCode='MSVBB150gms-96+0-8+0'
UPDATE PRODUCT SET PrdCCode='MSVBBACL1' WHERE PrdCCode='MSVBB20+5gms-346+14-1+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA9L1' WHERE PrdCCode='MSVBB20+5gms-360+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA1L1' WHERE PrdCCode='MSVBB20gms-600+0-50+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA4L1' WHERE PrdCCode='MSVBB30gms-360+0-30+0'
UPDATE PRODUCT SET PrdCCode='MSVBBAAL1' WHERE PrdCCode='MSVBB40+10gms-138+6-1+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA7L1' WHERE PrdCCode='MSVBB40+10gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA2L1' WHERE PrdCCode='MSVBB40gms-300+0-25+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA5L1' WHERE PrdCCode='MSVBB65gms-144+0-12+0'
UPDATE PRODUCT SET PrdCCode='MSVBBADL1' WHERE PrdCCode='MSVBB80+20gms-46+2-1+0'
UPDATE PRODUCT SET PrdCCode='MSVBBA8L1' WHERE PrdCCode='MSVBB80+20gms-48+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRAMAAL1' WHERE PrdCCode='SFRAM1038+31gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRAMABL1' WHERE PrdCCode='SFRAM2076+104gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRAMP5L1' WHERE PrdCCode='SFRAM346+21gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRAMA9L1' WHERE PrdCCode='SFRAM346gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRAMP8L1' WHERE PrdCCode='SFRAM692+35gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRAMP7L1' WHERE PrdCCode='SFRAM692+35gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRAMP6L1' WHERE PrdCCode='SFRAM69gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='SFRGGP7L1' WHERE PrdCCode='SFRGG296+20.72gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRGGA1L1' WHERE PrdCCode='SFRGG296gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRGGP2L6' WHERE PrdCCode='SFRGG335gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRGGP9L1' WHERE PrdCCode='SFRGG592+35.5gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRGGA2L1' WHERE PrdCCode='SFRGG888+26.6gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRGGP8L1' WHERE PrdCCode='SFRGG888+59.2gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRGGP6L4' WHERE PrdCCode='SFRGG955+66gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRGGP3L4' WHERE PrdCCode='SFRGG957+63gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRIBP7L3' WHERE PrdCCode='SFRIB334gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRIBP5L4' WHERE PrdCCode='SFRIB955+53gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAJL1' WHERE PrdCCode='SFRKM1264+94.8gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAGL1' WHERE PrdCCode='SFRKM1580+126gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAIL1' WHERE PrdCCode='SFRKM1580+69gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAFL1' WHERE PrdCCode='SFRKM1580+79gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMA6L1' WHERE PrdCCode='SFRKM1731+138gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMA3L1' WHERE PrdCCode='SFRKM1731+86gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAML1' WHERE PrdCCode='SFRKM1896+95gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMA8L1' WHERE PrdCCode='SFRKM1915gms-1+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMP7L1' WHERE PrdCCode='SFRKM1920+96gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMABL1' WHERE PrdCCode='SFRKM316gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMA1L1' WHERE PrdCCode='SFRKM346gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMP1L3' WHERE PrdCCode='SFRKM385gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAHL1' WHERE PrdCCode='SFRKM3950+316gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMA4L1' WHERE PrdCCode='SFRKM4329+346gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMANL1' WHERE PrdCCode='SFRKM4424+354gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMACL1' WHERE PrdCCode='SFRKM474gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMP6L1' WHERE PrdCCode='SFRKM4801+385gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMA2L1' WHERE PrdCCode='SFRKM519gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMP2L4' WHERE PrdCCode='SFRKM575gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMADL1' WHERE PrdCCode='SFRKM632+16gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMALL1' WHERE PrdCCode='SFRKM632gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAAL1' WHERE PrdCCode='SFRKM63gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='SFRKMA7L1' WHERE PrdCCode='SFRKM69gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAEL1' WHERE PrdCCode='SFRKM790+41gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMA5L1' WHERE PrdCCode='SFRKM865+45gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMAPL1' WHERE PrdCCode='SFRKM948gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRKMP9L1' WHERE PrdCCode='SFRKM960+50gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA5L1' WHERE PrdCCode='SFRMB1560+109gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA4L1' WHERE PrdCCode='SFRMB1790+78gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBP9L7' WHERE PrdCCode='SFRMB1822+137gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBJ2L6' WHERE PrdCCode='SFRMB1822+91gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBAAL1' WHERE PrdCCode='SFRMB1920+96gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBB2L1' WHERE PrdCCode='SFRMB1950+86gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBB5L1' WHERE PrdCCode='SFRMB320gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA6L1' WHERE PrdCCode='SFRMB389gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBB3L1' WHERE PrdCCode='SFRMB3900+312gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA2L1' WHERE PrdCCode='SFRMB400gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBB7L1' WHERE PrdCCode='SFRMB4480+358gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBP3M8' WHERE PrdCCode='SFRMB455gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA8L1' WHERE PrdCCode='SFRMB584gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA7L1' WHERE PrdCCode='SFRMB778gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBB1L1' WHERE PrdCCode='SFRMB780+19gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA9L1' WHERE PrdCCode='SFRMB78gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA3L1' WHERE PrdCCode='SFRMB800gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBA1L8' WHERE PrdCCode='SFRMB911+46gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRMBB6L1' WHERE PrdCCode='SFRMB960+28.8gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROBA8L1' WHERE PrdCCode='SFROB1920+96gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROBA5L1' WHERE PrdCCode='SFROB320gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROBA4L1' WHERE PrdCCode='SFROB389gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROBA1L1' WHERE PrdCCode='SFROB390+23gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROBA9L1' WHERE PrdCCode='SFROB4480+358gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROBA7L1' WHERE PrdCCode='SFROB780+19gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROBA2L1' WHERE PrdCCode='SFROB780+39gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROBA6L1' WHERE PrdCCode='SFROB960+28.8gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCA8L1' WHERE PrdCCode='SFROC1080+32gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCA6L1' WHERE PrdCCode='SFROC1620+108gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCB7L1' WHERE PrdCCode='SFROC1620+81gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCA3L9' WHERE PrdCCode='SFROC1895+105gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCA4L8' WHERE PrdCCode='SFROC1895+162gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCA9L1' WHERE PrdCCode='SFROC2160+130gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCA7L1' WHERE PrdCCode='SFROC2429+81gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCB8L1' WHERE PrdCCode='SFROC2430+54gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCP9M1' WHERE PrdCCode='SFROC320gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCP2L1' WHERE PrdCCode='SFROC324gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCB1B1' WHERE PrdCCode='SFROC805gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCA5L1' WHERE PrdCCode='SFROC810+27gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCB6B1' WHERE PrdCCode='SFROC810gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFROCB5L1' WHERE PrdCCode='SFROC948+81gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRPPA4L1' WHERE PrdCCode='SFRPP1000+40gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRPPR7L1' WHERE PrdCCode='SFRPP1080gms-1200+0-20+0'
UPDATE PRODUCT SET PrdCCode='SFRPPA6L1' WHERE PrdCCode='SFRPP421.2gms-500+20-25+1'
UPDATE PRODUCT SET PrdCCode='SFRPPA1L1' WHERE PrdCCode='SFRPP450+18gms-500+0-25+0'
UPDATE PRODUCT SET PrdCCode='SFRPPA3L1' WHERE PrdCCode='SFRPP500+20gms-25+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRPPR5L2' WHERE PrdCCode='SFRPP540gms-600+0-20+0'
UPDATE PRODUCT SET PrdCCode='SFRPPA5L1' WHERE PrdCCode='SFRPP60gms-180+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRPPA8L1' WHERE PrdCCode='SFRPP729gms-180+0-12+0'
UPDATE PRODUCT SET PrdCCode='SFRPPR8L1' WHERE PrdCCode='SFRPP810gms-180+0-15+0'
UPDATE PRODUCT SET PrdCCode='SFRPPA7L1' WHERE PrdCCode='SFRPP842.4gms-1000+40-50+2'
UPDATE PRODUCT SET PrdCCode='SFRPPA2L1' WHERE PrdCCode='SFRPP900+36gms-1000+0-50+0'
UPDATE PRODUCT SET PrdCCode='SFRWMA1L1' WHERE PrdCCode='SFRWM385gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SFRWMA2L1' WHERE PrdCCode='SFRWM770+38.5gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLKMA5L1' WHERE PrdCCode='SJLKM1140+57gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLKMA1L1' WHERE PrdCCode='SJLKM190gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLKMA2L1' WHERE PrdCCode='SJLKM380gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLKMA4L1' WHERE PrdCCode='SJLKM570+19gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLKMA3L1' WHERE PrdCCode='SJLKM589+19gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLLCA5L1' WHERE PrdCCode='SJLLC1140+57gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLLCA1L1' WHERE PrdCCode='SJLLC190gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLLCA2L1' WHERE PrdCCode='SJLLC380gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLLCA4L1' WHERE PrdCCode='SJLLC570+19gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLLCA3L1' WHERE PrdCCode='SJLLC589+19gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLMGA5L1' WHERE PrdCCode='SJLMG1140+57gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLMGA1L1' WHERE PrdCCode='SJLMG190gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLMGA4L1' WHERE PrdCCode='SJLMG570+19gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLSBA5L1' WHERE PrdCCode='SJLSB1140+57gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLSBA1L1' WHERE PrdCCode='SJLSB190gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLSBA2L1' WHERE PrdCCode='SJLSB380gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLSBA4L1' WHERE PrdCCode='SJLSB570+19gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SJLSBA3L1' WHERE PrdCCode='SJLSB589+19gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBB6L1' WHERE PrdCCode='SLBBB1480+74gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBB3L1' WHERE PrdCCode='SLBBB1481+65gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBA5L1' WHERE PrdCCode='SLBBB1520+67gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBA9L1' WHERE PrdCCode='SLBBB296+17gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBB1L1' WHERE PrdCCode='SLBBB296gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBA3L1' WHERE PrdCCode='SLBBB300gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBB4L1' WHERE PrdCCode='SLBBB3704+296gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBA6L1' WHERE PrdCCode='SLBBB3800+304gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBB2L1' WHERE PrdCCode='SLBBB592+29gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBB8L1' WHERE PrdCCode='SLBBB592gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBA8L1' WHERE PrdCCode='SLBBB59gms-120+0-12+0'
UPDATE PRODUCT SET PrdCCode='SLBBBA4L1' WHERE PrdCCode='SLBBB600+30gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBBBA7L1' WHERE PrdCCode='SLBBB608+30gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBLDA4L1' WHERE PrdCCode='SLBLD1776+89gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBLDA1L1' WHERE PrdCCode='SLBLD296gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBLDA5L1' WHERE PrdCCode='SLBLD4144+332gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBLDA3L1' WHERE PrdCCode='SLBLD592+17.8gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBLDA2L1' WHERE PrdCCode='SLBLD592gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SLBLDA6L1' WHERE PrdCCode='SLBLD888+26.6gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMICLP4L1' WHERE PrdCCode='SMICL2430+243gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMICLP5L1' WHERE PrdCCode='SMICL2430gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMICLP3L1' WHERE PrdCCode='SMICL244+24gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMICLP2L1' WHERE PrdCCode='SMICL488+24gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMICMP5L1' WHERE PrdCCode='SMICM260+26gms-30+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMICMP3L1' WHERE PrdCCode='SMICM284+28gms-20+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMICMP4L1' WHERE PrdCCode='SMICM426+42gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMISCA1B1' WHERE PrdCCode='SMISC18gms-288+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMISDA1B1' WHERE PrdCCode='SMISD18gms-288+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMISFC1B1' WHERE PrdCCode='SMISF18gms-288+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMISLA1B1' WHERE PrdCCode='SMISL18gms-288+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMISMA1B1' WHERE PrdCCode='SMISM18gms-288+0-1+0'
UPDATE PRODUCT SET PrdCCode='SMISXA1B1' WHERE PrdCCode='SMISX18gms-288+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCBP8B1' WHERE PrdCCode='TCHCB20gms-552+24-23+1'
UPDATE PRODUCT SET PrdCCode='TCHCHA9B1' WHERE PrdCCode='TCHCH1014+44gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHG3B1' WHERE PrdCCode='TCHCH1130+49gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHA3B1' WHERE PrdCCode='TCHCH1130+78gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHAHB1' WHERE PrdCCode='TCHCH1173+59gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHG1B1' WHERE PrdCCode='TCHCH1290+89gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHABB1' WHERE PrdCCode='TCHCH1323+66gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHF5B1' WHERE PrdCCode='TCHCH1869+140gms-6+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHAEB1' WHERE PrdCCode='TCHCH195.5gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHA7B1' WHERE PrdCCode='TCHCH220.5gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHA1B1' WHERE PrdCCode='TCHCH245gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHF8L2' WHERE PrdCCode='TCHCH263gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHAIB1' WHERE PrdCCode='TCHCH2737+219gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHP8B1' WHERE PrdCCode='TCHCH280gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHAAB1' WHERE PrdCCode='TCHCH2941+221gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHACB1' WHERE PrdCCode='TCHCH3087+247gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHA4B1' WHERE PrdCCode='TCHCH3275+245gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHP9B1' WHERE PrdCCode='TCHCH3737+280gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHAFB1' WHERE PrdCCode='TCHCH391gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHA6B1' WHERE PrdCCode='TCHCH44.1gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHA8B1' WHERE PrdCCode='TCHCH441+13.2gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHADB1' WHERE PrdCCode='TCHCH441gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHG4B1' WHERE PrdCCode='TCHCH491+15gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHA2B1' WHERE PrdCCode='TCHCH491+24gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHA5B1' WHERE PrdCCode='TCHCH49gms-120+0-10+0'
UPDATE PRODUCT SET PrdCCode='TCHCHF9L2' WHERE PrdCCode='TCHCH527gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHF6B1' WHERE PrdCCode='TCHCH560+28gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHAGB1' WHERE PrdCCode='TCHCH586.5+19.6gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCHF7B1' WHERE PrdCCode='TCHCH934+73gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHCXP7B1' WHERE PrdCCode='TCHCX20gms-480+0-24+0'
UPDATE PRODUCT SET PrdCCode='TCHCXP8B1' WHERE PrdCCode='TCHCX20gms-552+24-23+1'
UPDATE PRODUCT SET PrdCCode='TCHCXP6B1' WHERE PrdCCode='TCHCX22gms-460+20-23+1'
UPDATE PRODUCT SET PrdCCode='TCHCXP5B1' WHERE PrdCCode='TCHCX22gms-480+0-24+0'
UPDATE PRODUCT SET PrdCCode='TCHCXP4B1' WHERE PrdCCode='TCHCX432gms-576+0-36+0'
UPDATE PRODUCT SET PrdCCode='TCHCXP3B2' WHERE PrdCCode='TCHCX432gms-720+0-36+0'
UPDATE PRODUCT SET PrdCCode='TCHECA6L1' WHERE PrdCCode='TCHEC1081+47gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECADL1' WHERE PrdCCode='TCHEC1245+62gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECAAL1' WHERE PrdCCode='TCHEC1410+71gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECABL1' WHERE PrdCCode='TCHEC207.5gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECA7L1' WHERE PrdCCode='TCHEC2350+141gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECA4L1' WHERE PrdCCode='TCHEC235gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECA1L2' WHERE PrdCCode='TCHEC263gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECAEL1' WHERE PrdCCode='TCHEC2905+232gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECA8L1' WHERE PrdCCode='TCHEC3290+263gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECA9L1' WHERE PrdCCode='TCHEC470gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECA5L1' WHERE PrdCCode='TCHEC540.5+23.5gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECA3L2' WHERE PrdCCode='TCHEC605+52gms-15+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHECACL1' WHERE PrdCCode='TCHEC622.5+20.8gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHMKA3L1' WHERE PrdCCode='TCHMK1035+55gms-8+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHMKA1L1' WHERE PrdCCode='TCHMK172.5gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCHMKA2L1' WHERE PrdCCode='TCHMK517.5+13.8gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBBL1' WHERE PrdCCode='TCREC1580+79gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB2L1' WHERE PrdCCode='TCREC1720+86gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB7L1' WHERE PrdCCode='TCREC1725+86gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB4L1' WHERE PrdCCode='TCREC1755+88gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBJL1' WHERE PrdCCode='TCREC1776+89gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBEL1' WHERE PrdCCode='TCREC1896+95gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECA2L3' WHERE PrdCCode='TCREC1898+114gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBHL1' WHERE PrdCCode='TCREC296gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB9L1' WHERE PrdCCode='TCREC316gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB3L1' WHERE PrdCCode='TCREC3450+276gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECA9L1' WHERE PrdCCode='TCREC345gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECA3L3' WHERE PrdCCode='TCREC3796+304gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECP9L3' WHERE PrdCCode='TCREC379gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBKL1' WHERE PrdCCode='TCREC4144+332gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBCL1' WHERE PrdCCode='TCREC4360+348gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBGL1' WHERE PrdCCode='TCREC4424+354gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB8L1' WHERE PrdCCode='TCREC4761+379gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBDL1' WHERE PrdCCode='TCREC63.2gms-120+0-12+0'
UPDATE PRODUCT SET PrdCCode='TCRECBAL1' WHERE PrdCCode='TCREC632+22gms-10+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBFL1' WHERE PrdCCode='TCREC632gms-10+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB6L1' WHERE PrdCCode='TCREC690+24gms-10+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB1L1' WHERE PrdCCode='TCREC690+34gms-10+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECB5L1' WHERE PrdCCode='TCREC69gms-120+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECA4L3' WHERE PrdCCode='TCREC874+38gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECBIL1' WHERE PrdCCode='TCREC888+29.6gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TCRECA1L3' WHERE PrdCCode='TCREC949+38gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TGFCHA3L1' WHERE PrdCCode='TGFCH176.4gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TGFCHA2L1' WHERE PrdCCode='TGFCH196.4gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TGFCHA1L1' WHERE PrdCCode='TGFCH211gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA8L1' WHERE PrdCCode='TPCCR1623+81gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRAAL1' WHERE PrdCCode='TPCCR245.5gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA4L1' WHERE PrdCCode='TPCCR270.5gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA7L1' WHERE PrdCCode='TPCCR3787+303gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA1L1' WHERE PrdCCode='TPCCR392gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA5L1' WHERE PrdCCode='TPCCR541+27gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA6L1' WHERE PrdCCode='TPCCR541gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRACL1' WHERE PrdCCode='TPCCR736.5+24.6gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRABL1' WHERE PrdCCode='TPCCR736.5+49.1gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA3L1' WHERE PrdCCode='TPCCR784+23gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA2L1' WHERE PrdCCode='TPCCR784gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCCRA9L1' WHERE PrdCCode='TPCCR811.5+27.1gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCMLP3G3' WHERE PrdCCode='TPCML465gms-36+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCMLP1G3' WHERE PrdCCode='TPCML925gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA8L1' WHERE PrdCCode='TPCRM1623+81gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA4L1' WHERE PrdCCode='TPCRM270.5gms-32+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA7L1' WHERE PrdCCode='TPCRM3787+303gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA1L1' WHERE PrdCCode='TPCRM392gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA5L1' WHERE PrdCCode='TPCRM541+27gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA6L1' WHERE PrdCCode='TPCRM541gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMACL1' WHERE PrdCCode='TPCRM736.5+24.6gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA3L1' WHERE PrdCCode='TPCRM784+23gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA2L1' WHERE PrdCCode='TPCRM784gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMABL1' WHERE PrdCCode='TPCRM785.6gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TPCRMA9L1' WHERE PrdCCode='TPCRM811.5+27.1gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKBR7L3' WHERE PrdCCode='TSPKB15gms-960+0-60+0'
UPDATE PRODUCT SET PrdCCode='TSPKBR9L1' WHERE PrdCCode='TSPKB694gms-8+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGA6L1' WHERE PrdCCode='TSPKG1368+51gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGA9L1' WHERE PrdCCode='TSPKG2052+103gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGA4L1' WHERE PrdCCode='TSPKG342gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGA3L1' WHERE PrdCCode='TSPKG467gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGAAL1' WHERE PrdCCode='TSPKG4788+383gms-2+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGA5L1' WHERE PrdCCode='TSPKG684+34.2gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGA8L1' WHERE PrdCCode='TSPKG684gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGA2L1' WHERE PrdCCode='TSPKG934+117gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKGA1L1' WHERE PrdCCode='TSPKG934+70gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSA4L1' WHERE PrdCCode='TSPKS1368+68gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSA5L1' WHERE PrdCCode='TSPKS1368+78gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSA9L1' WHERE PrdCCode='TSPKS1560.4+93.6gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSB5M1' WHERE PrdCCode='TSPKS1850+105gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSB4M1' WHERE PrdCCode='TSPKS1850+185gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSB8L1' WHERE PrdCCode='TSPKS1850+92gms-9+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSABL1' WHERE PrdCCode='TSPKS1884+94gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSA6L1' WHERE PrdCCode='TSPKS1950+39gms-4+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSA2L1' WHERE PrdCCode='TSPKS232gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSA7L1' WHERE PrdCCode='TSPKS234gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSADL1' WHERE PrdCCode='TSPKS314gms-40+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSACL1' WHERE PrdCCode='TSPKS314gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSP9G1' WHERE PrdCCode='TSPKS315gms-50+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSG9L3' WHERE PrdCCode='TSPKS467gms-24+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSA3L1' WHERE PrdCCode='TSPKS581gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSA8L1' WHERE PrdCCode='TSPKS780+23.4gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSB1B1' WHERE PrdCCode='TSPKS785gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSB6L1' WHERE PrdCCode='TSPKS925+53gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSB7L1' WHERE PrdCCode='TSPKS925+92gms-18+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSG8L4' WHERE PrdCCode='TSPKS934+117gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSG7L3' WHERE PrdCCode='TSPKS934+70gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='TSPKSAAL1' WHERE PrdCCode='TSPKS942+31.4gms-12+0-1+0'
UPDATE PRODUCT SET PrdCCode='ZBISQU1P1' WHERE PrdCCode='ZBISQ875gms-1+0-1+0'
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND name = 'Cn2Cs_Prk_Product')
DROP TABLE Cn2Cs_Prk_Product
GO
CREATE TABLE Cn2Cs_Prk_Product(
	[DistCode] [nvarchar](20) NULL,
	[BusinessCode] [nvarchar](50) NULL,
	[BusinessName] [nvarchar](50) NULL,
	[CategoryCode] [nvarchar](50) NULL,
	[CategoryName] [nvarchar](50) NULL,
	[FamilyCode] [nvarchar](50) NULL,
	[FamilyName] [nvarchar](50) NULL,
	[GroupCode] [nvarchar](50) NULL,
	[GroupName] [nvarchar](50) NULL,
	[SubGroupCode] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[BrandCode] [nvarchar](50) NULL,
	[BrandName] [nvarchar](50) NULL,
	[AddHier1Code] [nvarchar](50) NULL,
	[AddHier1Name] [nvarchar](50) NULL,
	[AddHier2Code] [nvarchar](50) NULL,
	[AddHier2Name] [nvarchar](50) NULL,
	[AddHier3Code] [nvarchar](50) NULL,
	[AddHier3Name] [nvarchar](50) NULL,
	[AddHier4Code] [nvarchar](50) NULL,
	[AddHier4Name] [nvarchar](50) NULL,
	[AddHier5Code] [nvarchar](50) NULL,
	[AddHier5Name] [nvarchar](50) NULL,
	[AddHier6Code] [nvarchar](50) NULL,
	[AddHier6Name] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdWgt] [numeric](38, 6) NULL,
	[UOMGroupCode] [nvarchar](50) NULL,
	[PrdUPC] [int] NULL,
	[SerialNo] [nvarchar](50) NULL,
	[EANCode] [nvarchar](50) NULL,
	[Vending] [nvarchar](10) NULL,
	[ProductType] [nvarchar](100) NULL,
	[ProductUnit] [nvarchar](100) NULL,
	[ProductStatus][NVARCHAR](100) NULL,
	[DownLoadFlag] [nvarchar](5) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND name = 'Proc_Import_Product')
DROP PROCEDURE Proc_Import_Product
GO
CREATE PROCEDURE Proc_Import_Product
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_Product
* PURPOSE		: To Insert records from xml file in the Table Cn2Cs_Prk_Product
* CREATED		: Nandakumar R.G
* CREATED DATE	: 04/04/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @hDoc INTEGER 
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Cn2Cs_Prk_Product([DistCode],[BusinessCode],[BusinessName],[CategoryCode],[CategoryName],[FamilyCode],[FamilyName],
	[GroupCode],[GroupName],[SubGroupCode],[SubGroupName],[BrandCode],[BrandName],[AddHier1Code],[AddHier1Name],[AddHier2Code],[AddHier2Name],
	[AddHier3Code],[AddHier3Name],[AddHier4Code],[AddHier4Name],[AddHier5Code],[AddHier5Name],[AddHier6Code],[AddHier6Name],
	[PrdCCode],[PrdName],[PrdWgt],[UOMGroupCode],[PrdUPC],[SerialNo],[EANcode],[Vending],[ProductType],[ProductUnit],[ProductStatus],[DownLoadFlag])
	SELECT [DistCode],[BusinessCode],[BusinessName],[CategoryCode],[CategoryName],[FamilyCode],[FamilyName],
	[GroupCode],[GroupName],[SubGroupCode],[SubGroupName],[BrandCode],[BrandName],[AddHier1Code],[AddHier1Name],[AddHier2Code],[AddHier2Name],
	[AddHier3Code],[AddHier3Name],[AddHier4Code],[AddHier4Name],[AddHier5Code],[AddHier5Name],[AddHier6Code],[AddHier6Name],
	[PrdCCode],[PrdName],[PrdWgt],[UOMGroupCode],[PrdUPC],[SerialNo],[EANcode],[Vending],[ProductType],[ProductUnit],[ProductStatus],[DownLoadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_Product',1)
	WITH (
		[DistCode] 		NVARCHAR(50) ,
		[BusinessCode]  NVARCHAR(20) ,
		[BusinessName]  NVARCHAR(50) ,
		[CategoryCode]  NVARCHAR(20) ,
		[CategoryName]  NVARCHAR(50) ,
		[FamilyCode] 	NVARCHAR(20) ,
		[FamilyName] 	NVARCHAR(50) ,
		[GroupCode] 	NVARCHAR(20) ,
		[GroupName] 	NVARCHAR(50) ,
		[SubGroupCode] 	NVARCHAR(20) ,
		[SubGroupName] 	NVARCHAR(50) ,
		[BrandCode] 	NVARCHAR(20) ,
		[BrandName] 	NVARCHAR(50) ,
		[AddHier1Code]  NVARCHAR(20) ,
		[AddHier1Name]  NVARCHAR(50) ,
		[AddHier2Code]  NVARCHAR(20) ,
		[AddHier2Name]  NVARCHAR(50) ,
		[AddHier3Code]  NVARCHAR(20) ,
		[AddHier3Name]  NVARCHAR(50) ,
		[AddHier4Code]  NVARCHAR(20) ,
		[AddHier4Name]  NVARCHAR(50) ,
		[AddHier5Code]  NVARCHAR(20) ,
		[AddHier5Name]  NVARCHAR(50) ,
		[AddHier6Code]  NVARCHAR(20) ,
		[AddHier6Name]  NVARCHAR(50) ,
		[PrdCCode] 		NVARCHAR(50) ,
		[PrdName] 		NVARCHAR(100) ,
		[PrdWgt] 		NUMERIC(18,2),
		[UOMGroupCode] 	NVARCHAR(10),
		[PrdUPC] 		INT ,
		[SerialNo] 		NVARCHAR(50),
		[EANCode]		NVARCHAR(50),
		[Vending]		NVARCHAR(10),
		[ProductType]	NVARCHAR(100),
		[ProductUnit]	NVARCHAR(100),
		[ProductStatus] NVARCHAR(100),
		[DownLoadFlag]  NVARCHAR(10) 
	) XMLObj

	EXEC sp_xml_removedocument @hDoc 
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND name = 'Proc_Validate_Product')
DROP PROCEDURE Proc_Validate_Product
GO
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
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND name = 'Proc_Cn2Cs_Product')
DROP PROCEDURE Proc_Cn2Cs_Product
GO
--select * from Cn2Cs_Prk_Product
--EXEC Proc_Cn2Cs_Product 0
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
 C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,C.ProductStatus,  
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
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 403' ,'403'
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE Fixid = 403)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed)
VALUES(403,'D','2013-08-16',GETDATE(),1,'Core Stocky Service Pack 403')
GO