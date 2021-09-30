--[Stocky HotFix Version]=388
Delete from Versioncontrol where Hotfixid='388'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('388','2.0.0.5','D','2011-09-12','2011-09-12','2011-09-12',convert(varchar(11),getdate()),'Major: Product Release FOR J&J Upgrad')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 388' ,'388'
GO
--SRF-Nanda-262-001
if not exists (select * from dbo.sysobjects where id = object_id(N'[MultiUserTransValidation]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
	CREATE TABLE [dbo].[MultiUserTransValidation]
	(
		[UserId] [int] NOT NULL,
		[UserName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TransId] [int] NOT NULL,
		[TransName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LockedDate] [datetime] NOT NULL
	) ON [PRIMARY]
END
GO
--SRF-Nanda-262-002
DELETE FROM Configuration WHERE ModuleId ='BotreeMultiUser'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('BotreeMultiUser','BotreeMultiUser','Enable Multi User Validation',1,'',0.00,1)
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
GO
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (4,10,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Show Report Based On*...',NULL,1,NULL,243,1,1,'Press F4/Double Click to select Show Report Based On',0)

Delete from Rptfilter Where SelcId = 244 and Rptid = 4
GO
Insert Into Rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values (4,243,1,'Collection Ref No.')
Insert Into Rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values (4,243,2,'Bill Ref No.')

Delete from Rptformula Where SelcId = 244 and RptId = 4
GO
Insert Into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values (4,37,'Disp_Show','Show Report Based On',1,243)
----------------************************END*********************************************------------------
----------------****************************Stock and Sales Volume Report Issue Fixed in CK********************************-----------
IF EXISTS (Select * from Sysobjects where Xtype = 'P' and name = 'Proc_RptStockandSalesVolume')
DROP PROCEDURE Proc_RptStockandSalesVolume
GO
set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF
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
----**********************Hierarchy Sales and Volume Report Issue Fixed in CK******************----------
Delete from Rptfilter where rptid = 219 and Selcid in(202,23,44)
GO
Insert into rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values(219,202,1,'Yes')
Insert into rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values(219,202,2,'No')
Insert into rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values(219,23,1,'Selling Rate')
Insert into rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values(219,23,2,'List Price')
Insert into rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values(219,23,3,'MRP')
Insert into rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values(219,44,1,'Yes')
Insert into rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values(219,44,2,'No')
GO
-----***********************************Effective Coverage Analysis Report Issue Fixed in CK************************------
--BUG Number = 23672
--SELECT * from RptFormula where RptId = 211 ORDER BY SlNo
DELETE FROM RptFormula WHERE Rptid = 211
GO
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	1,	'FromDate',	'From Date',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	2,	'ToDate',	'To Date',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	3,	'Company',	'Company',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	4,	'Salesman',	'Salesman',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	5,	'Route',	'Route',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	6,	'CatLevel',	'Retailer Category Level',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	7,	'CatVal',	'Retailer Category Level Value',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	8,	'ValClass',	'Retailer Value Classification',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	9,	'Cap_RetailerGroup',	'Retailer Group',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	10,	'Cap_Retailer',	'Retailer',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	11,	'PrdLevel',	'Product Hierarchy Level',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	12,	'ProductCategoryValue',	'Product Hierarchy Level Value',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	13,	'Cap_Product',	'Product',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	14,	'Cap_BasedOn',	'Display Based On',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	15,	'Dis_FromDate',	'From Date',	1,	10	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	16,	'Dis_ToDate',	'To Date',	1,	11	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	17,	'Dis_Company',	'Company',	1,	4	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	18,	'Dis_SalesMan',	'Salesman',	1,	1	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	19,	'Dis_Route',	'Route',	1,	2	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	20,	'Disp_CategoryLevel',	'Retailer Category Level',	1,	29	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	21,	'Disp_CategoryLevelValue',	'Retailer Category Level Value',	1,	30	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	22,	'Disp_ValueClassification',	'Retailer Value Classification',	1,	31	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	23,	'Disp_RetailerGroup',	'Retailer Group',	1,	215	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	24,	'Disp_Retailer',	'Retailer',	1,	3	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	25,	'Dis_PrdLevel',	'Product Hierarchy Level',	1,	16	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	26,	'Dis_PrdLvlValue',	'Product Hierarchy Level Value',	1,	21	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	27,	'Disp_Product',	'Product',	1,	5	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	28,	'Disp_BasedOn',	'Display Based On',	1,	246	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	29,	'Cap User Name',	'User Name',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	30,	'Cap Print Date',	'Date',	1,	0	)
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(	211,	31,	'Disp_BillSts',	'',	1,	263	)
GO
 
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_Cn2Cs_BLSchemeAttributes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_Cn2Cs_BLSchemeAttributes]
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeAttributes 0
--SELECT * FROM ErrorLog
SELECT * FROM SchemeRetAttr WHERE SchId=50 AND AttrType=6
ROLLBACK TRANSACTION
*/
Create    PROCEDURE [Proc_Cn2Cs_BLSchemeAttributes]
(
@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeAttributes
* PURPOSE: To Insert and Update Scheme Attributes
* CREATED: Boopathy.P on 02/01/2009
***************************************************************************************************
* 12.09.2011  Panner AttrType Checking (Product or SKU)
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 	AS VARCHAR(50)
	DECLARE @AttrType 	AS VARCHAR(50)
	DECLARE @AttrCode 	AS VARCHAR(50)
	DECLARE @AttrTypeId 	AS INT
	DECLARE @AttrId  	AS INT
	DECLARE @CmpId  	AS INT
	DECLARE @SchLevelId 	AS INT
	DECLARE @SelMode 	AS INT
	DECLARE @ChkCount 	AS INT
	DECLARE @ErrDesc  	AS VARCHAR(1000)
	DECLARE @TabName  	AS VARCHAR(50)
	DECLARE @GetKey  	AS VARCHAR(50)
	DECLARE @Taction  	AS INT
	DECLARE @sSQL   	AS VARCHAR(4000)
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @CombiId	AS INT
	DECLARE @SLevel		AS INT
	DECLARE @iCnt		AS INT
	DECLARE @DepChk		AS INT
	DECLARE @MasterRecordID AS INT
	DECLARE @AttrName 	AS VARCHAR(100)
	SET @DepChk=0
	SET @TabName = 'Etl_Prk_Scheme_OnAttributes'
	SET @Po_ErrNo =0
	SET @iCnt=0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	
	DELETE FROM Etl_Prk_SchemeAttribute_Temp
	DECLARE  @Temp_CtgAttrDt TABLE
	(
		SchId		INT,
		CtgMainId	INT
	)
	DECLARE  @Temp_CtgAttrDt_Temp TABLE
	(
		SchId		NVARCHAR(50),
		CtgMainId	INT
	)
	DECLARE  @Temp_ValAttrDt TABLE
	(
		SchId		INT,
		ValClass	VARCHAR(400)
	)
	
	DECLARE  @Temp_ValAttrDt_Temp TABLE
	(
		SchId		NVARCHAR(50),
		ValClass	VARCHAR(400)
	)
	DECLARE  @Temp_KeyAttrDt TABLE
	(
		SchId		INT,
		RtrId		INT
	)
	DECLARE Cur_SchemeAttr CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL([AttrType],'') AS [Attribute Type],
	ISNULL([AttrName],'') AS [Attribute Master Code] FROM Etl_Prk_Scheme_OnAttributes 
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D' 
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code], [Attribute Type]
	OPEN Cur_SchemeAttr
	FETCH NEXT FROM Cur_SchemeAttr INTO @SchCode,@AttrType,@AttrCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @iCnt=@iCnt+1
		SET @Taction = 2
		SET @Po_ErrNo =0
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@AttrType))<>''
		BEGIN
			IF LTRIM(RTRIM(@AttrCode))=''
			BEGIN
				SET @ErrDesc = 'Attribute Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Attribute Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		ELSE IF LTRIM(RTRIM(@AttrCode))<>''
		BEGIN
			IF LTRIM(RTRIM(@AttrType))=''
			BEGIN
				SET @ErrDesc = 'Attribute Type should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Attribute Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
					
				END
				ELSE
				BEGIN
					SET @DepChk=1
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @DepChk=1
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN	
						IF NOT EXISTS(SELECT [CmpSchCode] FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE
						[CmpSchCode]=LTRIM(RTRIM(@SchCode)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode+ ' in table Etl_Prk_SchemeHD_Slabs_Rules  '
							INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
							B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
							SELECT @SchLevelId=C.CmpPrdCtgId,
								@SelMode=(CASE A.SchemeLevelMode
								WHEN 'PRODUCT' THEN 0 ELSE 1 END),@CombiId=(CASE A.CombiSch
								WHEN 'NO' THEN 0 ELSE 1 END)
							FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
							INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
							AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
						END
					END
					ELSE
					BEGIN
						SET @DepChk=2
						SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SchLevelId=SchLevelId FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END	
				END
			END
			IF UPPER(LTRIM(RTRIM(@AttrType)))= 'SALESMAN'
				BEGIN
				SET @AttrTypeId=1
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT SMID FROM SALESMAN WITH (NOLOCK) WHERE
						SMCODE=LTRIM(RTRIM(@AttrCode)) AND STATUS = 1)
					BEGIN
						SET @ErrDesc = 'Salesman Code:'+ @AttrCode+ ' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'SalesMan',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=SMID FROM SALESMAN WITH (NOLOCK) WHERE
						SMCODE=LTRIM(RTRIM(@AttrCode)) AND STATUS = 1
					END
				END
			END
			--->Added By Nanda on 28/07/2010
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CLUSTER'
				BEGIN
				SET @AttrTypeId=21
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT ClusterId FROM ClusterMaster WITH (NOLOCK) WHERE
						ClusterCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Cluster Code:'+ @AttrCode+ ' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Cluster',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=ClusterId FROM ClusterMaster WITH (NOLOCK) WHERE
						ClusterCode=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			--->Till Here
			
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROUTE'
			BEGIN
				SET @AttrTypeId=2
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RMID FROM RouteMaster WITH (NOLOCK) WHERE
						RMCODE=LTRIM(RTRIM(@AttrCode)) AND RMStatus = 1)
					BEGIN
						SET @ErrDesc = 'Route Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Route',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RMID FROM RouteMaster WITH (NOLOCK) WHERE
						RMCODE=LTRIM(RTRIM(@AttrCode)) AND RMStatus = 1
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VILLAGE'
			BEGIN
				SET @AttrTypeId=3
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT VillageId FROM RouteVillage WITH (NOLOCK) WHERE
						VILLAGECODE=LTRIM(RTRIM(@AttrCode)) AND VillageStatus = 1)
					BEGIN
						SET @ErrDesc = 'Route Village Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RouteVillage',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=VillageId FROM RouteVillage WITH (NOLOCK) WHERE
						VILLAGECODE=LTRIM(RTRIM(@AttrCode)) AND VillageStatus = 1
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CATEGORY LEVEL'
			BEGIN
				SET @AttrTypeId=4
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CtgLevelId FROM RetailerCategoryLevel WITH (NOLOCK) WHERE
						CtgLevelName=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Category Level:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Category Level',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=CtgLevelId FROM RetailerCategoryLevel WITH (NOLOCK) WHERE
						CtgLevelName=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CATEGORY LEVEL VALUE'
			BEGIN
				SET @AttrTypeId=5
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CtgMainId FROM RetailerCategory WITH (NOLOCK) WHERE
					CtgCOde=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Category Level Value not found''' + LTRIM(RTRIM(@SchCode)) + ''''
						INSERT INTO Errorlog VALUES (1,@TabName,'Category Level Value',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=CtgMainId FROM RetailerCategory WITH (NOLOCK) WHERE
						CtgCOde=LTRIM(RTRIM(@AttrCode))
						--->Modified By Nanda on 24/08/2009
						IF @DepChk=1
						BEGIN
							INSERT INTO @Temp_CtgAttrDt SELECT @GetKey,@AttrId
						END
						ELSE
						BEGIN
							INSERT INTO @Temp_CtgAttrDt_Temp SELECT @GetKey,@AttrId
						END
						--Till Here
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VALUECLASS'
			BEGIN
				SET @AttrTypeId=6
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RtrClassId FROM RETAILERVALUECLASS WITH (NOLOCK) WHERE
						ValueClassCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Value Class Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Value Class',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RtrClassId FROM RETAILERVALUECLASS WITH (NOLOCK) WHERE
						ValueClassCode=LTRIM(RTRIM(@AttrCode))
						--->Modified By Nanda on 24/08/2009
						IF @DepChk=1
						BEGIN
							INSERT INTO @Temp_ValAttrDt SELECT @GetKey,@AttrCode
						END
						ELSE
						BEGIN
							INSERT INTO @Temp_ValAttrDt_Temp SELECT @GetKey,@AttrCode
						END
						--Till Here
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'POTENTIALCLASS'
			BEGIN
				SET @AttrTypeId=7
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RtrClassId FROM RETAILERPOTENTIALCLASS WITH (NOLOCK) WHERE
						PotentialClassCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Potential Class Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Potential Class',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RtrClassId FROM RETAILERPOTENTIALCLASS WITH (NOLOCK) WHERE
						PotentialClassCode=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			ELSE IF ((UPPER(LTRIM(RTRIM(@AttrType)))= 'KEYGROUP') OR (UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER'))
			BEGIN
				SET @AttrTypeId=8
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN	
					IF (UPPER(LTRIM(RTRIM(@AttrType)))= 'KEYGROUP')
					BEGIN
						IF NOT EXISTS(SELECT GrpId FROM KeyGroupMaster WITH (NOLOCK) WHERE
								GrpCode = @AttrCode)
						BEGIN
							SET @ErrDesc = 'Key Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Key Group',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @AttrName = GrpName FROM KeyGroupMaster WITH (NOLOCK) WHERE GrpCode = LTRIM(RTRIM(@AttrCode))
							DECLARE Cur_KeyGrp CURSOR FOR 
							SELECT ISNULL(MasterRecordID,0) AS [MasterRecordID] FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN RETAILER R ON A.MasterRecordId=R.RtrId INNER JOIN KeyGroupMaster K 
							ON K.GrpName=A.ColumnValue Where A.ColumnValue=@AttrName AND C.MAsterID = 2
							OPEN Cur_KeyGrp
							FETCH NEXT FROM Cur_KeyGrp INTO @MasterRecordID
							WHILE @@FETCH_STATUS=0
							BEGIN
								INSERT INTO @Temp_KeyAttrDt SELECT @GetKey,@MasterRecordID
							FETCH NEXT FROM Cur_KeyGrp INTO @MasterRecordID
							END
							CLOSE Cur_KeyGrp
							DEALLOCATE Cur_KeyGrp
						END
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER'
					BEGIN
						IF NOT EXISTS (SELECT RtrId FROM Retailer WITH (NOLOCK) WHERE CmpRtrCode = LTRIM(RTRIM(@AttrCode)))
						BEGIN
							SET @ErrDesc = 'Retailer Code:'+ @AttrCode + ' not found for Scheme Code:'+ @SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @AttrId = RtrId FROM Retailer WITH (NOLOCK) WHERE CmpRtrCode = LTRIM(RTRIM(@AttrCode))
						END
					END
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@AttrType))) = 'SKU' OR UPPER(LTRIM(RTRIM(@AttrType)))= 'PRODUCT')
			BEGIN
				SET @AttrTypeId=9
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF @SelMode=0
					BEGIN
						SET @AttrId=1
					END
					ELSE IF @SelMode=1
					BEGIN
						IF NOT EXISTS(SELECT DISTINCT A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
							Where A.UdcMasterId=@SchLevelId)
						BEGIN
							SET @AttrId=@AttrCode
						END
						ELSE
						BEGIN
							SELECT DISTINCT @AttrId=A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
							Where A.UdcMasterId=@SchLevelId
						END
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL TYPE'
			BEGIN
				SET @AttrTypeId=10
				IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VAN SALES' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'READY STOCK'
					AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ORDER BOOKING'
				BEGIN
					SET @ErrDesc = 'BILL TYPE SHOULD BE(VAN SALES OR READY STOCK OR ORDER BOOKING) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Bill Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VAN SALES'
				BEGIN
					SET @AttrId=3
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='READY STOCK'
				BEGIN
					SET @AttrId=2
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ORDER BOOKING'
				BEGIN
					SET @AttrId=1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE'
			BEGIN
				SET @AttrTypeId=11
				IF UPPER(LTRIM(RTRIM(@AttrCode)))='ALL'
				BEGIN
					SET @AttrId=1
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'CASH' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'CREDIT'
					BEGIN
						SET @ErrDesc = 'BILL MODE SHOULD BE(CASH OR CREDIT) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Bill Mode',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='CASH'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='CREDIT'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER TYPE'
			BEGIN
				SET @AttrTypeId=12
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'KEY OUTLET' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'NON-KEY OUTLET'
					BEGIN
						SET @ErrDesc = 'RETAIER TYPE SHOULD BE(KEY OUTLET OR NON-KEY OUTLET) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RETAILER TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='KEY OUTLET'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='NON-KEY OUTLET'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CLASS TYPE'
			BEGIN
				SET @AttrTypeId=13
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VALUE CLASSIFICATION' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POTENTIAL CLASSIFICATION'
					BEGIN
						SET @ErrDesc = 'CLASS TYPE SHOULD BE(VALUE CLASSIFICATION OR POTENTIAL CLASSIFICATION) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'CLASS TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VALUE CLASSIFICATION'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POTENTIAL CLASSIFICATION'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROAD CONDITION'
			BEGIN
				SET @AttrTypeId=14
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'ROAD CONDITION SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ROAD CONDITION',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'INCOME LEVEL'
			BEGIN
				SET @AttrTypeId=15
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'INCOME LEVEL SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'INCOME LEVEL',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'					
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ACCEPTABILITY'
			BEGIN
				SET @AttrTypeId=16
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'ACCEPTABILITY SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ACCEPTABILITY',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'AWARENESS'
			BEGIN
				SET @AttrTypeId=17
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'AWARENESS SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'AWARENESS',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END 					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROUTE TYPE'
			BEGIN
				SET @AttrTypeId=18
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'SALES ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'DELIVERY ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'MERCHANDISING ROUTE'
					BEGIN
						SET @ErrDesc = 'ROUTE TYPE SHOULD BE(SALES ROUTE OR DELIVERY ROUTE OR MERCHANDISING ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ROUTE TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='SALES ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='DELIVERY ROUTE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='MERCHANDISING ROUTE'
					BEGIN
						SET @AttrId=3
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'LOCALUPCOUNTRY'
			BEGIN
				SET @AttrTypeId=19
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'LOCAL ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'UPCOUNTRY ROUTE'
					BEGIN
						SET @ErrDesc = 'LOCAL/UPCOUNTRY SHOULD BE(LOCAL ROUTE OR UPCOUNTRY ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'LOCALUPCOUNTRY',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='LOCAL ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='UPCOUNTRY ROUTE'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VAN/NON VAN ROUTE'
			BEGIN
				SET @AttrTypeId=20
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VAN ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'NON VAN ROUTE'
					BEGIN
						SET @ErrDesc = 'VAN/NON VAN ROUTE SHOULD BE(VAN ROUTE OR NON VAN ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'NON VAN ROUTE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VAN ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='NON VAN ROUTE'
					BEGIN
						SET @AttrId=2
					END
				END
			END
		END
		IF @Po_ErrNo =1
		BEGIN
			IF @DepChk=1
			BEGIN
				EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					SET @Taction = 0
				END
			END
		END
		ELSE
		BEGIN
			IF @ConFig=1
			BEGIN
				SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @SchLevelId <@SLevel
				BEGIN
					SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
					WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='NO'
					AND A.SlabId=0 AND A.SlabValue=0
					SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
					WHERE A.[PrdCode] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
					A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='NO'
					AND A.SlabId=0 AND A.SlabValue=0
				END
				ELSE
				BEGIN
					SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
					WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='YES'
					AND A.SlabId=0 AND A.SlabValue=0
					SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
					WHERE A.[PrdCode] IN (SELECT PrdCCode FROM Product)
					AND  A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='YES'
					AND A.SlabId=0 AND A.SlabValue=0				
				END					
	
				IF @EtlCnt=@CmpCnt
				BEGIN
					SELECT @EtlCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
					WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode))
	
					SELECT @CmpCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
					INNER JOIN Product B ON A.[PrdCode]=b.PrdCCode
					WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode))	
					IF @EtlCnt=@CmpCnt
					BEGIN
			
						IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE' OR UPPER(LTRIM(RTRIM(@AttrType)))='BILL TYPE' OR UPPER(LTRIM(RTRIM(@AttrType)))='CATEGORY LEVEL VALUE'
						BEGIN
							DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
							AND AttrId=@AttrId
			
							SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
							' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10)) + ' AND AttrId=' + CAST(@AttrId AS VARCHAR(10))
						END
						ELSE
						BEGIN
							DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId AND AttrId=@AttrId
			
							SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
							' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10))
						END
						
						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
						AuthId,AuthDate) VALUES(ISNULL(@GetKey,0),@AttrTypeId,@AttrId,1,1,convert(varchar(10),getdate(),121),
						1,convert(varchar(10),getdate(),121))
		
						SET @sSQL='INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
						AuthId,AuthDate) VALUES(' + CAST(@GetKey AS VARCHAR(10)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) +
						',' + CAST(@AttrId AS VARCHAR(10)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
				
					END					
					ELSE
					BEGIN	
						INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
						VALUES (LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId,'N')
						SET @sSQL='INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag
						) VALUES(' + CAST(@SchCode AS VARCHAR(50)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) + ',''N'''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
			
				END
				ELSE
				BEGIN	
					--Nanda
					--SELECT LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId
					INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
						VALUES (LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId,'N')
					SET @sSQL='INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag
					) VALUES(' + CAST(@SchCode AS VARCHAR(50)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) + ',''N'''')'
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--Nanda
					--SELECT * FROM Etl_Prk_SchemeAttribute_Temp					
				END					
			END
			ELSE
			BEGIN
				IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE' OR UPPER(LTRIM(RTRIM(@AttrType)))='BILL TYPE' OR  UPPER(LTRIM(RTRIM(@AttrType)))='CATEGORY LEVEL VALUE'
				BEGIN
					DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
					AND AttrId=@AttrId
	
					SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
					' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10)) + ' AND AttrId=' + CAST(@AttrId AS VARCHAR(10))
				END
				ELSE
				BEGIN
					DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
	
					SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
					' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10))
				END
	
				INSERT INTO Translog(strSql1) Values (@sSQL)
				INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
				AuthId,AuthDate) VALUES(ISNULL(@GetKey,0),@AttrTypeId,@AttrId,1,1,convert(varchar(10),getdate(),121),
				1,convert(varchar(10),getdate(),121))
	
				SET @sSQL='INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
				AuthId,AuthDate) VALUES(' + CAST(@GetKey AS VARCHAR(10)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) +
				',' + CAST(@AttrId AS VARCHAR(10)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
				INSERT INTO Translog(strSql1) Values (@sSQL)
			END			
		END
	FETCH NEXT FROM Cur_SchemeAttr INTO @SchCode,@AttrType,@AttrCode
	END
	CLOSE Cur_SchemeAttr
	DEALLOCATE Cur_SchemeAttr
	--SELECT * FROM SchemeRetAttr WHERE SchId=10
	IF EXISTS (SELECT * FROM Etl_Prk_Scheme_OnAttributes)
	BEGIN
		-->Modified By Nanda on 30/11/2009  
		IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchAttrToAvoid') 
		AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
		BEGIN
			DROP TABLE SchAttrToAvoid	
		END
		CREATE TABLE SchAttrToAvoid
		(
			SchId INT
		)
		INSERT INTO SchAttrToAvoid
		SELECT SchId FROM SchemeRetAttr WHERE AttrId=0 AND AttrType=6
		DELETE FROM SchemeRetAttr WHERE AttrType=6 AND SchId IN  (SELECT DISTINCT SchId FROM @Temp_CtgAttrDt)
		AND SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
--		INSERT INTO SchemeRetAttr
--		SELECT DISTINCT B.SchId,6,A.RtrClassId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) 
--		FROM RETAILERVALUECLASS A 
--		INNER JOIN @Temp_CtgAttrDt B ON A.CtgMainId=B.CtgMainId 
--		INNER JOIN @Temp_ValAttrDt C ON A.ValueClassCode = C.ValClass AND B.SchId=C.SchId
--		AND B.SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
		INSERT INTO SchemeRetAttr
		SELECT DISTINCT C.SchId,6,A.RtrValueClassId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM 
		(SELECT DISTINCT RVC.ValueClassCode,RVCM.RtrValueClassId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId,
		R.RtrKeyAcc,R.VillageId,RC.CtgLinkCode
		FROM Retailer R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId 
		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId) A
		INNER JOIN @Temp_ValAttrDt C ON A.ValueClassCode = C.ValClass 
		INNER JOIN @Temp_CtgAttrDt B ON A.CtgLinkId=B.CtgMainId 
		AND C.SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
		-->Till Here
		
		DELETE FROM Etl_Prk_SchemeAttribute_Temp WHERE AttrType=6 AND CmpSchCode IN  (SELECT DISTINCT SchId FROM @Temp_CtgAttrDt_Temp)
		INSERT INTO Etl_Prk_SchemeAttribute_Temp
		SELECT DISTINCT B.SchId,6,A.RtrClassId,'N'
		FROM RETAILERVALUECLASS A INNER JOIN @Temp_CtgAttrDt_Temp B
		ON A.CtgMainId=B.CtgMainId INNER JOIN @Temp_ValAttrDt_Temp C ON
		A.ValueClassCode = C.ValClass AND B.SchId=C.SchId
		IF EXISTS (SELECT * FROM @Temp_KeyAttrDt)
		BEGIN
			DELETE FROM SchemeRetAttr WHERE AttrType=8 AND SchId IN (SELECT DISTINCT SchId FROM @Temp_KeyAttrDt)
			INSERT INTO SchemeRetAttr
			SELECT DISTINCT SchID,8,RtrId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)
			FROM @Temp_KeyAttrDt
		END
		IF EXISTS (SELECT * FROM @Temp_KeyAttrDt)
		BEGIN
			DELETE FROM Etl_Prk_SchemeAttribute_Temp WHERE AttrType=8 AND CmpSchCode IN  (SELECT DISTINCT SchId FROM @Temp_KeyAttrDt)
			INSERT INTO Etl_Prk_SchemeAttribute_Temp
			SELECT DISTINCT SchID,8,RtrId,'N' FROM @Temp_KeyAttrDt
		END
	END
END
GO
Delete from Rptgroup where rptid = 41 
GO
Insert into Rptgroup (PId,RptId,GrpCode,GrpName)
Values ('StockReports',41,'PrdTrack','Product Track Report')
Delete from rptheader where Rptid = 41
GO
Insert into rptheader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
Values ('PrdTrack','Product Track Report',41,'Product Track Report','Proc_RptProductTrackDetails','RptProductTrackDetails','RptProductTrackDetails.rpt','')
Delete from rptdetails where rptid = 41
GO
Insert into rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	41,	1,	'FromDate',	-1,	'',	'',	'From Date*',	'',	1,	'',	10,	0,	0,	'Enter From Date',	0	)
Insert into rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	41,	2,	'ToDate',	-1,	'',	'',	'To Date*',	'',	1,	'',	11,	0,	0,	'Enter To Date',	0	)
Insert into rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	41,	3,	'Location',	-1,	'',	'LcnId,LcnCode,LcnName',	'Location*...',	'',	1,	'',	22,	0,	1,	'Press F4/Double Click to Select Location',	0	)
Insert into rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	41,	4,	'Company',	-1,	'',	'CmpId,CmpCode,CmpName',	'Company...',	'',	1,	'',	4,	1,	0,	'Press F4/Double Click to Select Company',	0	)
Insert into rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	41,	5,	'ProductCategoryLevel',	4,	'CmpId',	'CmpPrdCtgId,LevelName,CmpPrdCtgName',	'Product Hierarchy Level...',	'Company',	1,	'CmpId',	16,	1,	0,	'Press F4/Double click to select Product Hierarchy Level',	1	)
Insert into rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	41,	6,	'ProductCategoryValue',	5,	'CmpPrdCtgId',	'PrdCtgValMainId,PrdCtgValCode,  PrdCtgValName',	'Product Hierarchy Level Value...',	'ProductCategoryLevel',	1,	'CmpPrdCtgId',	21,	0,	0,	'Press F4/Double click to select Product Hierarchy Level Value',	1	)
Insert into rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	41,	7,	'Product',	6,	'PrdCtgValMainId',	'PrdId,PrdDcode,PrdName',	'Product*...',	'ProductCategoryValue',	1,	'PrdCtgValMainId',	5,	1,	1,	'Press F4/Double click to select Product',	0	)
Insert into rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(	41,	8,	'RptFilter',	-1,	NULL,	'FilterId,FilterDesc,FilterDesc',	'Suppress Zero Stock*...',	NULL,	1,	NULL,	44,	1,	1,	'Press F4/Double Click to Select the Supress Zero Stock',	0	)
Delete from Rptfilter where rptid = 41
GO
Insert into Rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values (41,44,1,'Yes')
Insert into Rptfilter (RptId,SelcId,FilterId,FilterDesc)
Values (41,44,2,'No')
Delete from Rptformula where rptid = 41
GO
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	1,	'Fil_FromDate',	'From Date',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	2,	'Fil_ToDate',	'To Date',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	3,	'FilDisp_FromDate',	'',	1,	10	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	4,	'FilDisp_ToDate',	'',	1,	11	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	5,	'Company',	'Company',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	6,	'CompanyDisp',	'ALL',	1,	4	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	7,	'TransactionType',	'Transaction Type',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	8,	'TransactionRef',	'Transaction Reference Number',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	9,	'SalesQty',	'Saleable Qty',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	10,	'FreeQty',	'Offer Qty',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	11,	'PurQty',	'Purchase Qty',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	12,	'PurFreeQty',	'Purchase Free Qty',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	13,	'SalesRet',	'Sales Return Qty',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	14,	'PurchaseRet',	'Pur. Return Qty',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	15,	'AdjIn',	'Adjustment In',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	16,	'AdjOut',	'Adjustment Out',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	17,	'StkType',	'Stock Type',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	18,	'Retailer',	'Retailer / Supplier',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	19,	'GrossAmt',	'Gross Amount',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	20,	'PrdName',	'Product Name :',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	21,	'BatName',	'Product Batch Name :',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	22,	'OpenSalQty',	'Opening Qty (Saleable) :',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	23,	'OpenUnsalQty',	'Opening Qty (UnSaleable) :',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	24,	'OpenFreeQty',	'Opening Qty (Offer) :',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	25,	'ClsSalQty',	'Closing Qty (Saleable) :',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	26,	'ClsUnsalQty',	'Closing Qty (UnSaleable) :',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	27,	'ClsFreeQty',	'Closing Qty (Offer) :',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	28,	'PrdLevel',	'Product Level',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	29,	'PrdLevelDisp',	'ALL',	1,	21	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	30,	'PrdLevelVal',	'Product Level Value',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	31,	'PrdLevelValDisp',	'ALL',	1,	16	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	32,	'Product',	'Product ',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	33,	'ProductDisp',	'ALL',	1,	5	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	34,	'Cap Print Date',	'Date',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	35,	'Cap User Name',	'User Name',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	36,	'UnSalesQty',	'UnSaleable Qty',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	37,	'TransDate',	'Transaction Date',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	38,	'Fil_Location',	'Location',	1,	22	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	39,	'Cap_Locaiton',	'Location',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	40,	'Disp_SupZeroStock',	'Suppress Zero Stock',	1,	0	)
Insert into Rptformula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
Values(	41,	41,	'Fill_SupZeroStock',	'Suppress Zero Stock',	1,	44	)
Delete From RptExcelheaders where rptid = 41
GO
Insert into RptExcelheaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	41,	1,	'TransactionDate',	'Transaction Date',	1,	1)
Insert into RptExcelheaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	41,	3,	'TransactionNumber',	'Transaction Reference Number',	1,	1)
Insert into RptExcelheaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	41,	2,	'TransactionType',	'Transaction Type',	1,	1)
Insert into RptExcelheaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	41,	4,	'SalQty',	'Salable Qty',	1,	1)
Insert into RptExcelheaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	41,	8,	'PrdId',	'PrdId',	0,	1)
Insert into RptExcelheaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	41,	5,	'UnSalQty',	'Unsalable Qty',	1,	1)
Insert into RptExcelheaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	41,	6,	'OfferQty',	'Offer Qty',	1,	1)
Insert into RptExcelheaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(	41,	7,	'SlNo',	'SlNo',	0,	1)

------------**************************Store Procedure**********************************-----------------------------
IF EXISTS ( Select * from sysobjects where xtype = 'P' and Name = 'Proc_RptProductTrackDetails')
DROP PROCEDURE Proc_RptProductTrackDetails
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER OFF
GO

----  Exec [Proc_RptProductTrackDetails] 41,2,0,'Loreal',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptProductTrackDetails]
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
* PROCEDURE : Proc_RptProductTrackDetails
* PURPOSE : To Return the Product transaction details
* CREATED : MarySubashini.S
* CREATED DATE : 01/08/2008
* NOTE  : General SP Returning the Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------------------------------------
* {date}     {developer}  {brief modification description}
* 06.11.2009 Aarthi       Added TransactionDate to Asc Format
***************************************************************************************************/
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
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	
	SET @PrdId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SupZeroStock = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	EXEC Proc_ProductTrackDetails @Pi_UsrId,@FromDate,@ToDate
	CREATE TABLE #RptProductTrackDetails
	(
		TransactionDate  DATETIME,
		TransactionType  NVARCHAR(300),
		TransactionNumber  NVARCHAR(100),
		SalQty     NUMERIC(38,0),
		UnSalQty   NUMERIC(38,0),
		OfferQty   NUMERIC(38,0),
		SlNo    INT ,
		PrdId Int
	)
	SET @TblName = 'RptProductTrackDetails'
	SET @TblStruct = '	TransactionDate  DATETIME,
						TransactionType  NVARCHAR(300),
						TransactionNumber  NVARCHAR(100),
						SalQty   NUMERIC(38,0),
						UnSalQty   NUMERIC(38,0),
						OfferQty   NUMERIC(38,0),
						SlNo    INT,
						PrdId INT'
	SET @TblFields = 'TransactionDate,TransactionType,TransactionNumber,SalQty,UnSalQty,OfferQty,SlNo,PrdId'
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
	--SET @Po_Errno = 0
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
			  INSERT INTO #RptProductTrackDetails ( TransactionDate,TransactionType,TransactionNumber,
										   SalQty,UnSalQty,OfferQty,SlNo,PrdId)
			  SELECT 
					TransactionDate,TransactionType,TransactionNumber,
					SUM(SalQty),SUM(UnSalQty),SUM(OfferQty),SlNo,PrdId
			  FROM 
					RptProductTrack 
			  WHERE 
					(CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
							CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
										
					AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
							LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) )
					 AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId ELSE 0 END) OR
							PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) )
					AND  TransactionDate BETWEEN @FromDate AND  @ToDate AND UsrId=@Pi_UsrId
			  GROUP BY 
					TransactionDate,TransactionType,TransactionNumber,SlNo,PrdId
			  ORDER BY 
					TransactionDate,SlNo
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptProductTrackDetails ' +
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptProductTrackDetails'
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
			SET @SSQL = 'INSERT INTO #RptProductTrackDetails ' +
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
	IF @SupZeroStock=1
	BEGIN
		DELETE FROM #RptProductTrackDetails WHERE (SalQty+UnSalQty+OfferQty)=0 AND 
		TransactionType NOT IN ('Opening Stock','Closing Stock') 
	END
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptProductTrackDetails
	PRINT 'Data Executed'
	SELECT * FROM #RptProductTrackDetails ORDER BY TransactionDate,SlNo ASC 
	RETURN
END
-----------------*****************************************END*********************************--------------------------------
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='TempRetialerWiseTax' AND xtype='u')
DROP TABLE TempRetialerWiseTax
GO
CREATE TABLE TempRetialerWiseTax
(
	[RefNo] [nvarchar](100)  NULL,
	[InvDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrCode] varchar(100),
	[RtrName] nvarchar(200),
	[RtrTinNo] nvarchar(100),
	[TaxPerc] [nvarchar](50)  NULL,
	[TaxableAmount] [numeric](38, 6) NULL,
	[IOTaxType] [nvarchar](100)  NULL,
	[TaxFlag] [int] NULL,
	[TaxPercent] [numeric](38, 6) NULL,
	[TaxId] [int] NULL
) 
GO
DELETE FROM tbl_Generic_Reports WHERE  rptid=12
INSERT INTO tbl_Generic_Reports VALUES
(12,'RetailerWiseBillWiseTax','Proc_GR_RetailerWiseBillWiseTax','Retailer Wise Transaction With Tax','Not Available')
GO
DELETE FROM TBL_GENERIC_REPORTS_FILTERS WHERE RptId=12
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 12,1,'Company','Proc_GR_RetailerWiseBillWiseTax_Values','RetailerWiseBillWiseTax'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 12,2,'Salesman','Proc_GR_RetailerWiseBillWiseTax_Values','RetailerWiseBillWiseTax'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 12,3,'Route','Proc_GR_RetailerWiseBillWiseTax_Values','RetailerWiseBillWiseTax'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 12,4,'Retailer','Proc_GR_RetailerWiseBillWiseTax_Values','RetailerWiseBillWiseTax'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 12,5,'Not Applicable','Proc_GR_RetailerWiseBillWiseTax_Values','RetailerWiseBillWiseTax'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 12,6,'Not Applicable','Proc_GR_RetailerWiseBillWiseTax_Values','RetailerWiseBillWiseTax'
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_GR_RetailerWiseBillWiseTax_Values' AND xtype='P')
DROP PROCEDURE Proc_GR_RetailerWiseBillWiseTax_Values
GO
--EXEC Proc_GR_RetailerWiseBillWiseTax_Values 'Retailer',''
CREATE PROCEDURE Proc_GR_RetailerWiseBillWiseTax_Values
(
	@FILTERCAPTION  NVARCHAR(100),
	@TEXTLIKE  NVARCHAR(100)
)
AS
BEGIN
	SET @TEXTLIKE='%'+ISNULL(@TEXTLIKE,'')+'%'
	print @filtercaption
	IF @FILTERCAPTION='Company' 
	begin
	SELECT DISTINCT cmpcode as Filtervalues  FROM Company WHERE cmpcode LIKE @textlike
	end
	IF @FILTERCAPTION='Salesman' 
	begin
	SELECT DISTINCT SMName as Filtervalues FROM Salesman WHERE SMName LIKE @textlike
	end 
	IF @FILTERCAPTION='Route' 
	begin
	SELECT DISTINCT RMName as Filtervalues FROM Routemaster WHERE RMName LIKE @textlike
	end 
	IF @FILTERCAPTION='Retailer' 
	begin
	SELECT DISTINCT RtrName as Filtervalues FROM Retailer WHERE RtrName LIKE @textlike
	end 
END
GO
--EXEC Proc_GR_RetailerWiseBillWiseTax 'Stock Ledger','2011-08-01','2011-08-18','','','','','',''  
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_GR_RetailerWiseBillWiseTax' AND xtype='P')
DROP PROCEDURE Proc_GR_RetailerWiseBillWiseTax
GO 
CREATE PROCEDURE Proc_GR_RetailerWiseBillWiseTax
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
DELETE FROM RptRetailerWiseTax
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
if not exists (select * from hotfixlog where fixid = 388)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(388,'D','2011-09-12',getdate(),1,'Core Stocky Service Pack 388')
GO