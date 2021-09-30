--[Stocky HotFix Version]=394
Delete from Versioncontrol where Hotfixid='394'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('394','2.0.0.5','D','2011-11-01','2011-11-01','2011-11-01',convert(varchar(11),getdate()),'Major: Product Release')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 394' ,'394'
GO
Delete From Configuration where Moduleid = 'RTNTOCOMPANY1'
GO
Insert into Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
Values ('RTNTOCOMPANY1','ReturnToCompany','Fill Batches automatically once product is selected',0,'',0.00,1)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptRetailerMasterDetReport')
DROP PROCEDURE Proc_RptRetailerMasterDetReport
GO
---- EXEC Proc_RptRetailerMasterDetReport 206,1,0,'NV02100309',0,0,1
CREATE PROCEDURE [Proc_RptRetailerMasterDetReport] 
( 
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT, 
	@Pi_DbName			Nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/****************************************************************************************************************
* PROCEDURE  : Proc_RptProductMasterDetReport
* PURPOSE    : To Generate Retailer Master Details Report 
* CREATED BY : Panneerselvam.k
* CREATED ON : 07/01/2010
* MODIFICATION 
*****************************************************************************************************************   
* DATE       AUTHOR      DESCRIPTION   
*****************************************************************************************************************/ 
BEGIN
SET NOCOUNT ON
	/* Get the Filter Values  */		
		DECLARE @CmpId	 				AS	INT
		DECLARE @SMId      				AS	INT
		DECLARE @RMId					AS	INT
		DECLARE @RetCatLevelId      	AS	INT
		DECLARE @RetCatLevelValId    	AS	INT
		DECLARE @RetLevelClassId		AS	INT
		DECLARE @RetailerId      		AS	INT
		DECLARE @RetStatusId    		AS	INT
		DECLARE @RetOrderBy    			AS	INT
		
		SET @CmpId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @SMId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
		SET @RMId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
		SET @RetCatLevelId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
		SET @RetCatLevelValId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
		SET @RetLevelClassId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
		SET @RetailerId			= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
		SET @RetStatusId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
		SET @RetOrderBy			= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,90,@Pi_UsrId))
/*  CREATE TABLE STRUCTURE */
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	nvarchar(50)
	DECLARE @TblName 		AS	nvarchar(500)
	DECLARE @TblStruct 		AS	nVarchar(4000)
	DECLARE @TblFields 		AS	nVarchar(4000)
	DECLARE @SSQL			AS 	VarChar(8000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
			/*  Till Here  */
		SET @TblName = 'RptRetailerMasterDetReport'
		
		SET @TblStruct ='	RtrId INT,RtrCode Varchar(100),
							RtrName Varchar(100),RtrAdd1 Varchar(100),
							RtrAdd2 Varchar(100) ,RtrAdd3 Varchar(100),
							RtrPinNo Varchar(100),RtrPhoneNo Varchar(100),
							RtrEmailId Varchar(100) ,RtrKeyAcc Varchar(100),
							RtrTINNo Varchar(100),RtrCovMode Varchar(100),							
							RtrStatus Varchar(100),RtrCrBills INT,RtrCrLimit Numeric(18,3),
							RtrCrDays INT,GeoName Varchar(100),SalesRoute Varchar(100),
							DelvRoute Varchar(100),MerRoute Varchar(100),
							CategoryLevel Varchar(100),Category  Varchar(100),Class  Varchar(100),
							UDCColumn Varchar(100),UDCValue  Varchar(100)	'		
											
		SET @TblFields =	'RtrId,RtrCode,RtrName ,RtrAdd1,RtrAdd2,RtrAdd3,
							 RtrPinNo,RtrPhoneNo,RtrEmailId,RtrKeyAcc,
							 RtrTINNo ,RtrCovMode,RtrStatus,RtrCrBills ,RtrCrLimit,
							 RtrCrDays ,GeoName,SalesRoute,DelvRoute ,MerRoute ,
							 CategoryLevel ,Category ,Class '
		CREATE TABLE #TmpRptRetailerMasterDetReport(RtrId INT,RtrCode Varchar(100),
							RtrName Varchar(100),RtrAdd1 Varchar(100),
							RtrAdd2 Varchar(100) ,RtrAdd3 Varchar(100),
							RtrPinNo Varchar(100),RtrPhoneNo Varchar(100),
							RtrEmailId Varchar(100) ,RtrKeyAcc Varchar(100),
							RtrTINNo Varchar(100),RtrCovMode Varchar(100),							
							RtrStatus Varchar(100),RtrCrBills INT,RtrCrLimit Numeric(18,3),
							RtrCrDays INT,GeoName Varchar(100),SalesRoute Varchar(100),
							DelvRoute Varchar(100),MerRoute Varchar(100),
							CategoryLevel Varchar(100),Category  Varchar(100),Class  Varchar(100),
							UDCColumn Varchar(100),UDCValue  Varchar(100))
			/*  Snap Shot Query    */
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
			
			INSERT INTO #TmpRptRetailerMasterDetReport
			SELECT  Distinct
				R.RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,
				RtrPinNo,RtrPhoneNo,RtrEmailId,
				CASE RtrKeyAcc  WHEN 1 THEN 'Yes' ELSE 'No' END AS RtrKeyAcc,
				RtrTINNo,
				CASE RtrCovMode WHEN 1 THEN 'Order Booking' 
								WHEN 2 THEN 'Van Sales'
								WHEN 3 THEN 'Counter Sales'  END AS RtrCovMode,
				CASE RtrStatus  WHEN 1 THEN 'Active' ELSE 'InActive' END AS RtrStatus,
				RtrCrBills,RtrCrLimit,RtrCrDays,
				G.GeoName,RMName AS SalesRoute,	'' AS DelvRoute,'' AS MerRoute,
				RCL.CtgLevelName CategoryLevel, RC.CtgName AS Category,	RVC.ValueClassName AS Class,
				B.ColumnName  UDCColumn,C.ColumnValue UDCValue
			FROM  Retailer R WITH (NOLOCK)
						LEFT OUTER JOIN UdcDetails C ON R.RtrId = C.MasterRecordId 
						Inner JOIN UdcHD A ON C.MasterId = A.MasterId AND A.MasterName = 'Retailer Master' 
						LEFT OUTER JOIN UdcMaster B  ON A.MasterId = B.MasterId AND C.UdcMasterId = B.UdcMasterId ,
				  RetailerMarket RM,
				  RetailerCategoryLevel RCL WITH (NOLOCK),
				  RetailerCategory RC WITH (NOLOCK),
				  RetailerValueClass RVC WITH (NOLOCK),
				  RetailerValueClassMap RVCM WITH (NOLOCK) ,
				  RouteMaster Rot,Geography G,
				  SalesMan S,SalesmanMarket SM
			WHERE	RVCM.RtrValueClassId = RVC.RtrClassId
					AND RVCM.RtrId = R.RtrId 		AND RCL.CtgLevelId=RC.CtgLevelId
					AND RVC.CtgMainId=RC.CtgMainId  AND  R.RtrId = RM.RtrId	
					AND ROT.RMId = RM.RMId			AND Rot.RMSRouteType = 1
					AND R.GeoMainId = G.GeoMainId	AND S.SMId = SM.SMId AND RM.RMId = SM.RMId
					--- Company  
					AND (S.CmpId =  (CASE @CmpId WHEN 0 THEN S.CmpId ELSE 0 END) OR 
								S.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				--- SalesMan
					And (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
							    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route 
					AND (ROT.RMId = (CASE @RMId WHEN 0 THEN ROT.RMId Else 0 END) OR
		    						ROT.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level 
				 AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category  
				 AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				 AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (R.RtrId = (CASE @RetailerId WHEN 0 THEN R.RtrId ELSE 0 END) OR
								R.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				---- Product Status
				AND   (R.RtrStatus  =(CASE @RetStatusId WHEN 0 THEN R.RtrStatus  ELSE 0 END ) OR
							R.RtrStatus  IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
					/*   Sales Route Update */
			SELECT DISTINCT R.RtrId,RtrCode,ROT.RMName  INTO #TmpSalRoute
			FROM RouteMaster ROT,Retailer R 
			WHERE RMSRouteType = 2
				  AND R.RtrId IN ( SELECT DISTINCT  RtrId FROM #TmpRptRetailerMasterDetReport)
				  AND R.RMId = ROt.RMId
			UPDATE #TmpRptRetailerMasterDetReport  SET DelvRoute = RMName
			FROM #TmpRptRetailerMasterDetReport a,#TmpSalRoute B
			WHERE A.RtrId = B.RtrId
					/*   Merchandising Route Update */
			SELECT DISTINCT R.RtrId,RtrCode,ROT.RMName INTO #TmpMerRoute
			FROM RouteMaster ROT,Retailer R,RetailerMarket RM 
			WHERE RMSRouteType = 3
				  AND R.RtrId IN( SELECT DISTINCT  RtrId FROM #TmpRptRetailerMasterDetReport)
				  AND R.RtrId = RM.RtrId AND RM.RMId = ROt.RMId	
			UPDATE #TmpRptRetailerMasterDetReport  SET MerRoute = RMName
					FROM #TmpRptRetailerMasterDetReport a,#TmpMerRoute B
					WHERE A.RtrId = B.RtrId
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #TmpRptRetailerMasterDetReport
		IF @RetOrderBy = 1
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY RtrCode
		END
		IF @RetOrderBy = 2
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY RtrName
		END
		IF @RetOrderBy = 3
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY SalesRoute
		END
		IF @RetOrderBy = 4
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY Category
		END
		IF @RetOrderBy = 5
		BEGIN
			SELECT  RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,
					RtrTinNo,RtrKeyAcc,RtrCovMode,RtrStatus,RtrCrBills,RtrCrLimit,RtrCrDays,
					GeoName,SalesRoute,DelvRoute,MerRoute,CategoryLevel,Category,Class,UDCColumn,UDCValue 
			FROM 	#TmpRptRetailerMasterDetReport ORDER BY Class
		END
	END
END
GO
--Prepared by Rajandar for database Housekeeping Tool
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'spEXECsp_RECOMPILE') AND type in (N'P', N'PC'))
DROP PROCEDURE spEXECsp_RECOMPILE
GO  
CREATE PROCEDURE dbo.spEXECsp_RECOMPILE 
AS  
BEGIN
/*  
----------------------------------------------------------------------------  
-- Object Name: dbo.spEXECsp_RECOMPILE   
-- Project: SQL Server Database Maintenance  
-- Business Process: SQL Server Database Maintenance  
-- Purpose: Execute sp_recompile for all tables in a database  
-- Detailed Description: Execute sp_recompile for all tables in a database  
-- Database: Admin  
-- Dependent Objects: None  
-- Called By: TBD  
-- Upstream Systems: None  
-- Downstream Systems: None  
--   
--------------------------------------------------------------------------------------  
-- Rev | CMR | Date Modified | Developer | Change Summary  
--------------------------------------------------------------------------------------  
--  
*/  
SET NOCOUNT ON   
-- 1a - Declaration statements for all variables  
DECLARE @TableName varchar(128)  
DECLARE @OwnerName varchar(128)  
DECLARE @CMD1 varchar(8000)  
DECLARE @TableListLoop int  
DECLARE @TableListTable table  
(
	UIDTableList int IDENTITY (1,1),  
	OwnerName varchar(128),  
	TableName varchar(128)
)  
	-- 2a - Outer loop for populating the database names  
	INSERT INTO @TableListTable(OwnerName, TableName)  
	SELECT  u.[Name], o.[Name]  
	FROM dbo.sysobjects o  
	INNER JOIN dbo.sysusers u  
	ON o.uid = u.uid  
	WHERE o.Type = 'U'  
	ORDER BY o.[Name]  

	-- 2b - Determine the highest UIDDatabaseList to loop through the records  
	SELECT @TableListLoop = MAX(UIDTableList) FROM @TableListTable  
	-- 2c - While condition for looping through the database records  
	WHILE @TableListLoop > 0  
	BEGIN  
		-- 2d - Set the @DatabaseName parameter  
		SELECT @TableName = TableName,  
		@OwnerName = OwnerName  
		FROM @TableListTable  
		WHERE UIDTableList = @TableListLoop  
		-- 3f - String together the final backup command  
		SELECT @CMD1 = 'EXEC sp_recompile ' + '[' + @OwnerName + '.' + @TableName + ']' + char(13)  
		-- 3g - Execute the final string to complete the backups  
		-- SELECT @CMD1  
		EXEC (@CMD1)  
		-- 2h - Descend through the database list  
		SELECT @TableListLoop = @TableListLoop - 1  
	END
END
GO
IF NOT EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.ID=SC.ID AND S.NAME='OrderBooking' and SC.NAME='PDADownLoadFlag')
BEGIN
	ALTER TABLE OrderBooking ADD PDADownLoadFlag TinyInt DEFAULT 0 WITH values
END
GO

Update HotsearchEditorHd Set RemainSltstring=' 
SELECT OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,  RtrId,OrdType,Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,  RndOffValue,TotalAmount,Status,Availability,LastModBy,LastModDate,  AuthId,AuthDate,RtrName,PDADownLoadFlag FROM (  
Select OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,A.SmId,A.RmId,  A.RtrId,OrdType,Priority,FillAllPrd,ShipTo,A.RtrShipId,Remarks,RoundOff,  RndOffValue,TotalAmount,Status,A.Availability,A.LastModBy,A.LastModDate,  A.AuthId,A.AuthDate,B.RtrName,ISNULL(PDADownLoadFlag,0) as PDADownLoadFlag
from OrderBooking A INNER JOIN Retailer B ON A.RtrId=B.RtrId ) a'
where FormId=680
GO
DELETE FROM CustomCaptions WHERE TransId=3 and CtrlId=2000 and SubCtrlId=36
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 3,2000,36,'HotSch-3-2000-36','Reference No','','',1,1,1,Getdate(),1,Getdate(),'Reference No','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=3 and CtrlId=2000 and SubCtrlId=37
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 3,2000,37,'HotSch-3-2000-37','Retailer Code','','',1,1,1,Getdate(),1,Getdate(),'Retailer Code','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=3 and CtrlId=2000 and SubCtrlId=38
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 3,2000,38,'HotSch-3-2000-38','Retailer Name','','',1,1,1,Getdate(),1,Getdate(),'Retailer Name','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=3 and CtrlId=1000 and SubCtrlId=55
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 3,1000,55,'PnlMsg-3-1000-55','','Press F4/Double click to Select Down Loaded  SalesReturn','',1,1,1,Getdate(),1,Getdate(),'','Press F4/Double click to Select Down Loaded  SalesReturn','',1,1
GO

DELETE FROM HotsearchEditorHD WHERE FormId=10049
INSERT INTO HotsearchEditorHD(FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10049,'Sales Return','DocRefNo','Select','SELECT R.RtrId,Srno,RtrCode,RtrName,SMID,SMName,RM.RMID,RMNAME FROM PDA_SalesReturn  PD (NOLOCK)  INNER JOIN Retailer R (NOLOCK) ON R.Rtrid=Pd.Rtrid INNER JOIN RetailerMarket RTM (NOLOCK) ON RTM.RMID=PD.MktId AND RTM.Rtrid=R.Rtrid INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=RTM.RMID and RM.RMID=PD.MktId INNER JOIN SalesMan SM (NOLOCK) ON SM.SMID=PD.SrpID WHERE PD.Status=0' 

DELETE FROM HotsearchEditorDT WHERE FormId=10049
INSERT INTO HotsearchEditorDT(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10049,'Doc Reference No','Reference No','Srno',4500,0,'HotSch-3-2000-36',3
UNION ALL
SELECT 1,10049,'Retailer Code','Retailer Code','RtrCode',4500,0,'HotSch-3-2000-37',3
UNION ALL
SELECT 1,10049,'Retailer Name','Retailer Name','RtrName',4500,0,'HotSch-3-2000-38',3
GO

IF NOT EXISTS(SELECT C.NAME FROM SYSCOLUMNS C INNER JOIN SYSOBJECTS S ON S.ID=C.ID AND C.NAME='PDAReturn' and S.NAME='ReturnHeader')
BEGIN
	ALTER TABLE ReturnHeader ADD PDAReturn TinyInt
END
GO
UPDATE ReturnHeader SET PDAReturn=0
GO

UPDATE HotsearchEditorHD SET RemainsltString='
SELECT ReturnId,ReturnCode,RtnRoundOff,RtnRoundOffAmt,PDAReturn FROM   (
Select DISTINCT RH.ReturnId,RH.ReturnCode,RH.RtnRoundOff,RH.RtnRoundOffAmt,PDAReturn  
From  ReturnHeader RH (NOLOCK)   Where RH.ReturnType = 2   
and (RH.Status = ''vFParam'' or RH.Status = ''vSParam''))MainSql' WHERE FormId=221
GO

IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='TF' AND NAME='Fn_ReturnPDAProductDt')
DROP FUNCTION Fn_ReturnPDAProductDt
GO
CREATE    FUNCTION [Fn_ReturnPDAProductDt](@SrNo as Varchar(50))
RETURNS @PDAProducts TABLE
	(
		PrdId		INT,
		PrdName		Varchar(150),
		PrdCCode	Varchar(50),
		PrdBatID	INT,
		BatchCode	Varchar(100),
		Qty			INT,
		MRP			NUMERIC(18,6),
		SellRate	NUMERIC(18,6),
		PriceId		INT,
		SplPriceId  INT,
		StockTypeId	INT
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnPDAProductDt
* PURPOSE: Returns the PDA Product details
* NOTES:
* CREATED: MURURGAN.R
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
INSERT INTO	@PDAProducts
Select F.PrdId,F.PrdName,F.PrdCCode,A.PrdBatID,CmpBatCode AS BatchCode, [SrQty],B.PrdBatDetailValue as 'MRP',D.PrdBatDetailValue as 'SellRate',A.DefaultPriceId as PriceId, 0 as SplPriceId,UsrStkTyp 
FROM ProductBatch A (NOLOCK) 
INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND   C.MRP = 1 
INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID  AND D.DefaultPrice=1 
INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.SelRte = 1 
INNER JOIN PRODUCT F (NOLOCK) ON A.PrdId=F.PrdId 
INNER JOIN PDA_SalesReturnProduct G (NOLOCK) ON G.[PrdId] = F.Prdid And G.[PrdBatId] = A.Prdbatid AND A.DefaultPriceId=G.PriceId WHERE [Srno]=@SrNo Order By F.PrdCCode
RETURN
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_SalesRepresentative' AND xtype ='P')
DROP PROCEDURE [Proc_Export_PDA_SalesRepresentative]
GO
--Exec Proc_Export_PDA_SalesRepresentative 'test','inter','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_SalesRepresentative]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.SalesRepresentative Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.SalesRepresentative(SrpId,SrpCde,SrpNm,SrpSts,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT SMId,SMCode,SMName,Status,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.SalesMan WHERE Status = 1 and SMCode = ''' + @SalRpCode + ''''
	EXEC (@InsSQL)
END
GO
--FOR MARKET--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Market' AND xtype ='P')
DROP PROCEDURE [Proc_Export_PDA_Market]
GO
--Exec Proc_Export_PDA_Market 'Test','Intermediate','KS'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Market]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Market Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Market(SrpCde,MktId,MktCde,MktNm,MktDist,MktPopu,mktsts,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + @SalRpCode + ''', RM.RMId,RMCode,RMName,RMDistance,RMPopulation,RMstatus,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.RouteMaster RM 
							 INNER JOIN SalesmanMarket SM ON SM.RMId = RM.RMId INNER JOIN Salesman S ON S.SMId = SM.SMId
							 WHERE S.SMCode=''' + @SalRpCode + '''  AND RMstatus=1'
	EXEC (@InsSQL)
END
GO
--FOR TABLE BANK--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Bank' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Bank
GO
--Exec Proc_Export_PDA_Bank 'Test','Intermediate','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_Bank]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Bank Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Bank(SrpCde,BnkId,BnkCode,BnkName,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + @SalRpCode + ''',BnkId,BnkCode,BnkName,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.Bank'
	EXEC (@InsSQL)

END
--FOR TABLE BANKBRANCH--
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_BankBranch' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_BankBranch
GO
--Exec Proc_Export_PDA_BankBranch 'Test','Inter','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_BankBranch]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.BankBranch Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.BankBranch(SrpCde,BnkId,BnkBrId,BnkBrCode,BnkBrName,BnkBrAdd1,BnkBrAdd2,BnkBrAdd3,BnkBrPhone,BnkBrFax,BnkBrACNo,BnkBrContact,BnkBrEmailId,BnkBrRemarks,DistBank,CoaId,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + @SalRpCode + ''',BnkId,BnkBrId,BnkBrCode,BnkBrName,BnkBrAdd1,BnkBrAdd2,BnkBrAdd3,BnkBrPhone,BnkBrFax,BnkBrACNo,BnkBrContact,BnkBrEmailId,BnkBrRemarks,DistBank,CoaId,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.BankBranch'
	EXEC (@InsSQL)
END
GO
--FOR TABLE PRODUCTCATEGORY--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_ProductCategory' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_ProductCategory
GO
--Exec Proc_Export_PDA_ProductCategory 'Test','Inter','KS'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_ProductCategory]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.ProductCategory Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.ProductCategory(SrpCde,CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.ProductCategoryLevel'
	EXEC (@InsSQL)

END
GO
--FOR TABLE PRODUCTCATEGORYVALUE--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_ProductCategoryValue' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_ProductCategoryValue
GO
--Exec Proc_Export_PDA_ProductCategoryValue 'Test','Inter','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_ProductCategoryValue]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.ProductCategoryValue Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.ProductCategoryValue(SrpCde,PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.ProductCategoryValue'
	EXEC (@InsSQL)

END
GO
--FOR PRODUCT--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Products' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Products
GO
--Exec Proc_Export_PDA_Products 'QPS','Intermediate','S02'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Products]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @FromDate AS datetime
DECLARE @ToDate AS datetime

BEGIN
--	SELECT @FromDate=dateadd(MM,-6,getdate())
--	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)

--	SELECT DISTINCT prdid,PrdBatId INTO #Tempproduct FROM SalesInvoiceProduct SIP INNER JOIN SalesInvoice SI ON SI.SalId = SIP.SalId
--	WHERE salinvdate BETWEEN @FromDate AND @ToDate

	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Product Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Product(SrpCde,PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdStatus,CmpId,PrdCtgValMainId,Vending,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdStatus,CmpId,PrdCtgValMainId,Vending,''N'' AS UploadFlag
	 FROM '+ (@FromDBName) +'.dbo.Product where PrdStatus=1'
	EXEC (@InsSQL)
END
GO
--Product Batch
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_ProductBatch') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_ProductBatch
GO
--Exec Proc_Export_PDA_ProductBatch 'jnj','JnJIntermediate','SM01'
CREATE PROCEDURE Proc_Export_PDA_ProductBatch
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: [Proc_Export_PDA_ProductBatch]
* PURPOSE: To Insert the records From Zoom into Intermediate Database
* SCREEN : PRODUCTBATCH
* CREATED: MURUGAN.R
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @FromDate AS datetime
DECLARE @ToDate AS datetime

BEGIN

CREATE TABLE #Tempproductbatch (Prdid int,prdbatid int)

DECLARE @Prdid AS int
DECLARE Cur_Productbatch CURSOR
FOR SELECT prdid FROM Product WHERE PrdStatus=1
OPEN  Cur_Productbatch 
FETCH next FROM Cur_Productbatch INTO  @Prdid
WHILE @@fetch_status=0
BEGIN
 IF NOT EXISTS(SELECT prdid,prdbatid,sum(PrdBatLcnSih-PrdBatLcnRessih)Qty FROM productbatchlocation 
		       WHERE PrdId=@Prdid AND (PrdBatLcnSih-PrdBatLcnRessih)>0 GROUP BY prdid,PrdBatID)
	BEGIN  
		INSERT INTO #Tempproductbatch	
		SELECT prdid,max(PrdBatId)PrdBatId FROM ProductBatch WHERE PrdId=@Prdid GROUP BY prdid
	END  
 ELSE
    BEGIN 
		INSERT INTO #Tempproductbatch	
		SELECT prdid,min(prdbatid)prdbatid FROM productbatchlocation WHERE prdid=@Prdid 
			AND (PrdBatLcnSih-PrdBatLcnRessih)>0 GROUP BY prdid
    END 
FETCH next FROM Cur_Productbatch INTO  @Prdid
END 
CLOSE Cur_Productbatch
DEALLOCATE Cur_Productbatch

	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.ProductBatch Where SrpCde = ''' + @SalRpCode + ''''
	PRINT @DelSQL
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.ProductBatch (SrpCde,PrdId,PrdBatId,PriceId,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,MRP,[List Price],[Selling Price],CurStock,UploadFlag)'
	Set @InsSQL = @InsSQL +  

' SELECT ''' + @SalRpCode + ''', P.PrdId,PB.Prdbatid,DP.PriceId,CmpBatCode,MnfDate,ExpDate,Status,'+
' Pb.TaxGroupId,MRP,'+
' PurchaseRate AS ListPrice,SellingRate,sum(PrdBatLcnSih-PrdBatLcnRessih)Qty,''N'''+
' FROM '+ QuoteName(@FromDBName) + '..Product P INNER JOIN '+ QuoteName(@FromDBName) +'..ProductBatch Pb ON P.PrdId=Pb.Prdid'+
' inner join #Tempproductbatch T on PB.prdid=T.prdid and PB.prdbatid=T.prdbatid'+
' INNER JOIN '+ QuoteName(@FromDBName) + '..DefaultPriceHistory DP ON DP.PrdId=P.prdid '+
' AND DP.PrdId=PB.prdid AND DP.PrdBatId=PB.prdbatid AND DP.PrdId=T.prdid AND DP.PrdBatId=T.prdbatid AND dp.priceid=pb.defaultpriceid'+
' INNER JOIN Productbatchlocation PBL on PBL.prdid=	P.prdid and PBL.prdbatid=PB.prdbatid and PBL.prdid=PB.prdid '+
' and PBL.prdid=T.prdid and PBL.prdbatid=T.prdbatid and PBL.prdid=DP.prdid and PBL.prdbatid=DP.prdbatid '+
' GROUP BY  P.PrdId,PB.Prdbatid,DP.PriceId,CmpBatCode,MnfDate,ExpDate,Status,Pb.TaxGroupId,MRP,PurchaseRate,SellingRate'

exec (@InsSQL)
END
GO
--Retailer
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Retailer' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Retailer
GO
--Exec Proc_Export_PDA_Retailer 'Test','Intermediate','KS'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Retailer]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Retailer Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Retailer (SrpCde,RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,
	RtrPhoneNo,RtrEmailId,RtrContactPerson,RtrKeyAcc,RtrCovMode,RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,
	RtrCSTNo,RtrDepositAmt,RtrCrBills,RtrCrLimit,RtrCrDays,RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,
	RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,GeoMainId,RMId,VillageId,RtrShipId,TaxGroupId,RtrResPhone1,
	RtrResPhone2,RtrOffPhone1,RtrOffPhone2,RtrDOB,RtrAnniversary,CoaId,RtrOnAcc,RtrType,RtrFrequency,
	CtgLevelId,CtgMainID,RtrClassId,ValueClassCode,ValueClassName,CtgLinkCode,CtgName,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',R.RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrContactPerson,RtrKeyAcc,RtrCovMode,
	RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,RtrCSTNo,RtrDepositAmt,RtrCrBills,RtrCrLimit,RtrCrDays,
	RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,
	RtrPestExpiryDate,GeoMainId,RM.RMId,VillageId,RtrShipId,TaxGroupId,RtrResPhone1,RtrResPhone2,RtrOffPhone1,RtrOffPhone2,
	RtrDOB,RtrAnniversary,CoaId,RtrOnAcc,RtrType,RtrFrequency,CtgLevelId,I.CtgMainID,RtrClassId,ValueClassCode,ValueClassName,CtgLinkCode,CtgName,
	''N'' UploadFlag  FROM '+ (@FromDBName) +'.dbo.Retailer R WITH (NOLOCK) INNER JOIN RETAILERVALUECLASSMAP H  WITH (NOLOCK) 
	ON H.RtrId=R.RtrId  INNER JOIN RETAILERVALUECLASS I  WITH (NOLOCK) ON I.RtrClassId=H.RtrValueClassId INNER JOIN RetailerCategory J WITH (NOLOCK) ON J.CtgMainId=I.CtgMainId
	inner join RetailerMarket RM on RM.rtrid=R.Rtrid and RM.rtrid=H.rtrid INNER JOIN SalesmanMarket SM ON SM.RMId = RM.RMId INNER JOIN Salesman S ON S.SMId = SM.SMId
	where SMCode = ''' + @SalRpCode + ''' and RtrStatus=1'	
	EXEC (@InsSQL)

END
GO
--Collection
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Collection' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Collection
GO
--Exec Proc_Export_PDA_Collection 'Test','Inter','KS'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Collection]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Collection Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Collection(SrpCde,SalInvNo,SalInvDte,RtrId,SalNetAmt,UploadFlag,PaidAmount)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',SalInvNo,salinvdate,Rtrid,SalNetAmt,''N'' AS UploadFlag,SalPayAmt 
			FROM '+ (@FromDBName) +'.dbo.salesinvoice WHERE DlvSts=4 AND SalInvDate > DateAdd(m, -3, getdate())'
	EXEC (@InsSQL)

END
GO
--CreditNote
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_CreditNote' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_CreditNote
GO
--Exec Proc_Export_PDA_CreditNote 'Test','Inter','KS'
CREATE PROCEDURE Proc_Export_PDA_CreditNote
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	
	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.CreditNote Where SrpCde = ''' + @SalRpCode + ''''
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.CreditNote (SrpCde,CrNo,CrAmount,RtrId,CrAdjAmount,TranNo,Reasonid,UploadFlag)'
	Set @InsSQL = @InsSQL +  ' SELECT ''' + @SalRpCode + ''',CrNoteNumber,Amount,RtrId,CrAdjAmount,Transid,Reasonid, ''N'' AS UploadFlag FROM '+ QuoteName(@FromDBName) + '.dbo.CreditNoteRetailer WHERE (Amount-CrAdjAmount)>0'
	exec (@InsSQL)
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_DebitNote') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_DebitNote
GO
--Exec Proc_Export_PDA_DebitNote 'Test','Inter','KS'
CREATE PROCEDURE Proc_Export_PDA_DebitNote
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.DebitNote Where SrpCde = ''' + @SalRpCode + ''''
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.DebitNote (SrpCde,DbNo,DbAmount,RtrId,DbAdjAmount,TransNo,Reasonid,UploadFlag)'
	Set @InsSQL = @InsSQL +  ' SELECT ''' + @SalRpCode + ''',DbNoteNumber,Amount,RtrId,DbAdjAmount,Transid,Reasonid,''N'' AS UploadFlag FROM '+ QuoteName(@FromDBName) + '.dbo.DebitNoteRetailer'
	exec (@InsSQL)

END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_ReasonMaster') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_ReasonMaster
GO
--Exec Proc_Export_PDA_ReasonMaster 'Test','Inter','KS'
CREATE PROCEDURE Proc_Export_PDA_ReasonMaster
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.ReasonMaster Where SrpCde = ''' + @SalRpCode + ''''
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.ReasonMaster (SrpCde,ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
					DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,
					StkTransferScreen,BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,UploadFlag)'
	Set @InsSQL = @InsSQL +  ' SELECT ''' + @SalRpCode + ''',ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,
StkTransferScreen,BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal, ''N'' AS UploadFlag
FROM '+ QuoteName(@FromDBName) + '.dbo.ReasonMaster'
	exec (@InsSQL)

END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_Distributor') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_Distributor
GO
--Exec Proc_Export_PDA_Distributor 'QPS','Intermediate','KS'
CREATE PROCEDURE Proc_Export_PDA_Distributor
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.Distributor'
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.Distributor (DistributorId,DistributorCode,DistributorName)'
	Set @InsSQL = @InsSQL +  ' SELECT DistributorId,DistributorCode,DistributorName
			FROM '+ QuoteName(@FromDBName) + '.dbo.Distributor'
	exec (@InsSQL)

END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='tempSalesmanMTDDashBoard' AND xtype='U')
DROP TABLE tempSalesmanMTDDashBoard
GO
CREATE TABLE  tempSalesmanMTDDashBoard 
	(
		TransType int,
		Smid int,
		Smcode nvarchar(50),
		Items	NVARCHAR(100),
		[VALUES]  numeric(18,2)
	)
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_SalesmanMTDDashBoard') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_SalesmanMTDDashBoard
GO
--Exec Proc_Export_PDA_SalesmanMTDDashBoard 'Loreal','InterDb','DS01'
CREATE PROCEDURE Proc_Export_PDA_SalesmanMTDDashBoard
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @SmId AS int
DECLARE @Fromdate AS datetime 
DECLARE @ToDate AS datetime 
BEGIN
	DELETE FROM tempSalesmanMTDDashBoard

	SELECT  @SmId =Smid FROM Salesman WHERE SMCode=@SalRpCode
	SELECT @Fromdate=CONVERT(VARCHAR(10),DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()),121)  
	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)

	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.SalesmanMTDDashBoard'
	exec (@DelSQL)

		INSERT INTO TempSalesmanMTDDashBoard
		SELECT 1,@SmId,@SalRpCode,'DS Productive %',0
		UNION ALL 
		SELECT 2,@SmId,@SalRpCode,'SKU per call',0
		UNION ALL 
		SELECT 3,@SmId,@SalRpCode,'Total Sales  Value',0
		UNION ALL
		SELECT 4,@SmId,@SalRpCode,'RDBN-Incentive Product',0
		UNION ALL
		SELECT 5,@SmId,@SalRpCode,'Zero Transaction Outlets',0
		UNION ALL
		SELECT 6,@SmId,@SalRpCode,'New Outlet enrolled',0

--UOM TO Convert Metric Tonne

	Select Prdid, Case PrdUnitId WHEN 2 THEN (PrdWgt/1000)/1000
								 WHEN 3 THEN PrdWgt/1000 END AS MetricTon 
	INTO #METRIC FROM Product	

SELECT a.SMID,a.RMID,MAX(RCPMASTERID) RCPMASTERID
INTO #STEP1 FROM RouteCovPlanMaster a,salesman b,routemaster c
where a.smid=b.smid and a.rmid=c.rmid and b.SMId=@SmId 
GROUP BY a.SMID,a.RMID

SELECT SMID,RMID,RCPGENERATEDDATES INTO #STEP2 FROM RouteCovPlanDetails B,#STEP1 A
WHERE A.RCPMASTERID=B.RCPMASTERID

SELECT B.RMID,COUNT(DISTINCT B.RtrId) AS ScheduledCalls INTO #STEP3 FROM Retailer A WITH (NOLOCK) 
INNER JOIN RetailerMarket B WITH (NOLOCK) ON  A.RtrId=B.RtrId 
AND A.RtrStatus=1 GROUP BY B.RMID 

SELECT SMID,B.RMID,RCPGENERATEDDATES,ScheduledCalls INTO #STEP4 FROM #STEP3 A,#STEP2 B WHERE  A.RMID=B.RMID

SELECT A.SMID,SMNAME,A.RMID,RMNAME,RCPGENERATEDDATES,SCHEDULEDCALLS into #PCALLS FROM #step4 A,SALESMAN B,ROUTEMASTER C 
WHERE A.SMID=B.SMID AND A.RMID=C.RMID and RCPGENERATEDDATES BETWEEN @FromDate and @ToDate

SELECT SMNAME [Salesman Name],RMNAme [Route Name],RCPGeneratedDates [Calendar Date],ScheduledCalls [Planned Calls] into #Calendar from #Pcalls

SELECT SMID,SMNAME,SUM(SCHEDULEDCALLS) CALLS INTO #SMPLANNEDCALLS FROM #PCALLS WHERE RCPGENERATEDDATES BETWEEN @FromDate and @ToDate GROUP BY smid,SMNAME

SELECT RMID,RMNAME,SUM(SCHEDULEDCALLS) CALLS INTO #RMPLANNEDCALLS FROM #PCALLS WHERE RCPGENERATEDDATES BETWEEN @FromDate and @ToDate GROUP BY rmid,RMNAME

SELECT
		Salesman.Smid,Salesman.SMCode AS [Salesman Code], Salesman.SMName AS [Salesman Name],
		Routemaster.rmid,RouteMaster.RMCode AS [Route Code], RouteMaster.RMName AS [Route Name],
		TBL_GR_BUILD_RH.HIERARCHY3CAP AS [Retailer Hierarchy 1],
		TBL_GR_BUILD_RH.HIERARCHY2CAP AS [Retailer Hierarchy 2],
		TBL_GR_BUILD_RH.HIERARCHY1CAP AS [Retailer Hierarchy 3],
		Retailer.RtrCode AS [Retailer Code] ,
		Retailer.RtrNAme as [Retailer Name],
		Retailer.RtrRegDate as [Registered Date]
		         INTO #COV
FROM         SalesmanMarket INNER JOIN
Salesman ON SalesmanMarket.SMId = Salesman.SMId INNER JOIN
RouteMaster ON SalesmanMarket.RMId = RouteMaster.RMId INNER JOIN
Retailer INNER JOIN
RetailerMarket ON Retailer.RtrId = RetailerMarket.RtrId ON SalesmanMarket.RMId = RetailerMarket.RMId INNER JOIN
TBL_GR_BUILD_RH ON Retailer.RtrId = TBL_GR_BUILD_RH.RTRID
where rtrstatus=1 and Salesman.SMId =@SmId

SELECT smid,[SALESMAN CODE],COUNT(DISTINCT [RETAILER CODE]) RTRCOUNT INTO #SALRETCOUNT FROM #COV
GROUP BY smid,[SALESMAN CODE]

SELECT rmid,[Route Code],COUNT(DISTINCT [RETAILER CODE]) RTRCOUNT INTO #ROTRETCOUNT FROM #COV
GROUP BY rmid,[Route Code]

SELECT COUNT(DISTINCT [RETAILER CODE]) CNT INTO #TOTALCNT FROM #COV
	
	SELECT a.* INTO #SALINV
	FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D  ,TBL_GR_BUILD_RH E
	WHERE SALINVDATE BETWEEN @FromDate and @ToDate AND A.RMID=B.RMID
		    and E.RTRID=A.RTRID AND
			DLVSTS in (4,5) and
			C.SMID=A.SMID AND C.SMId=@SmId
			AND A.RTRID=D.RTRID  
SELECT A.*,C.Brand_Caption INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID  

--- EXCLUSION PRODUCTS
SELECT PRDID INTO #EXCLUSIONS FROM TBL_GR_BUILD_PH A WHERE BRAND_CODE NOT IN (SELECT BRANDCODE FROM BRANDEXCLUSION )
SELECT PRDID,BRAND_cODE,BRAND_CAPTION,COMPANY_CODE,COMPANY_cAPTION INTO #BRANDEXCLUSIONS FROM TBL_GR_BUILD_PH WHERE  BRAND_CODE IN (SELECT BRANDCODE FROM BRANDEXCLUSION)

CREATE TABLE #SALESMAN
(
	smid int,
	[Salesman Name] nvarchar(100),
	[Active Retailers] int,  
	[Total Retailers Billed] int,  	
	[Planned Calls] int,  
	[Effective Reach] int,
	[Productivity %] numeric(18,2),
	[Lines Sold (All SKU)] int,
	[SKU per Call (All SKU)] numeric(18,2),
    [Outlets Created] int,
	[RDBN (All SKU)] numeric(18,2),
)

Insert into #salesman Select smid,SMNAME,0,0,0,0,0,0,0,0,0 from Salesman WHERE SMCode=@SalRpCode

UPDATE #SALESMAN SET [Active Retailers]= RTRCOUNT  
FROM #SALESMAN A,#SALRETCOUNT B WHERE A.SMID=B.SMID  


SELECT     smid,COUNT(DISTINCT RTRID) trb into #RtrBilled FROM    #salinv INNER JOIN
#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
Product ON #Salesinvoiceproduct.PrdId = Product.PrdId
group by smid

UPDATE #SALESMAN  SET [Total Retailers Billed]= trb  FROM #SALESMAN A,#rtrBilled B  
WHERE A.SMID=B.SMID  

UPDATE #SALESMAN SET [Outlets Created]=cnt from #salesman a,
	(SELECT smid,COUNT([Registered Date]) CNT FROM #cov WHERE [Registered Date] 
		BETWEEN @FromDate and @ToDate group by smid) B
Where a.smid=b.smid

UPDATE #SALESMAN  SET [Planned Calls]= calls  FROM #SALESMAN A,#smplannedcalls B  
WHERE A.SMID=B.SMID  

SELECT     smid,COUNT(DISTINCT RTRID) EffectiveReach
	into #effectiverch FROM    #salinv INNER JOIN
	#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
	Product ON #Salesinvoiceproduct.PrdId = Product.PrdId
	group by smid,salinvdate

UPDATE #SALESMAN SET [Effective Reach]= efr 
FROM #SALESMAN A,(Select SMid,Sum(EffectiveReach)efr from #effectiverch group by smid) B
WHERE A.SMID=B.SMID

SELECT smid,COUNT(DISTINCT #Salesinvoiceproduct.Prdid) linessold into #linessold FROM    #salinv INNER JOIN    
#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN    
Product ON #Salesinvoiceproduct.PrdId = Product.PrdId  group by smid,rtrid,salinvdate    

UPDATE #SALESMAN SET [Lines Sold (All SKU)]= efr FROM #SALESMAN A,(Select SMid,Sum(linessold)efr
from #linessold group by smid) B    
WHERE A.SMID=B.SMID 

SELECT     smid,sum(PrdNetAmount) red,Sum(BaseQty * MetricTon) as MTON
into #Redistribution FROM    #salinv INNER JOIN
#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
Product ON #Salesinvoiceproduct.PrdId = Product.PrdId
INNER JOIN #METRIC MT ON Product.Prdid=MT.Prdid
group by smid

SELECT     smid,sum(PrdNetAmount) red
into #Redistributionex FROM    #salinv INNER JOIN
#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
Product ON #Salesinvoiceproduct.PrdId = Product.PrdId INNER JOIN #EXCLUSIONS ON PRODUCT.PRDID=#EXCLUSIONS.PRDID
group by smid

UPDATE #SALESMAN SET [RDBN (All SKU)]= red FROM #SALESMAN A,#Redistribution B WHERE A.SMID=B.SMID  

UPDATE #SALESMAN SET [SKU Per Call (All SKU)]=cast ([Lines Sold (All SKU)] as numeric(18,2))/case [Effective Reach] when 0 then 1 else cast([Effective Reach] as numeric(18,2)) end
UPDATE #SALESMAN SET [Productivity %]=(cast([Effective Reach] as numeric(18,2))/case [Planned Calls] when 0 then 1.00 else cast([Planned Calls] as numeric(18,2)) end)*100
UPDATE #SALESMAN SET [Productivity %]=0 where [Planned Calls]=0

---Infant Nutrition Sales
--SELECT X.SMID,Smcode,SUM(PrdNetAmount-RetPrdNetAmt) as NetSales
--INTO #InfantNutritionSales FROM(
--	SELECT SMID,RMID,SUM(PrdNetAmount) as PrdNetAmount,0 as RetPrdNetAmt
--	FROM SalesInvoice SI
--	INNER JOIN SalesInvoiceProduct SIP On SIP.Salid=Si.Salid
--	INNER JOIN Product P ON P.PrdId=SIP.prdid
--	WHERE Salinvdate Between @Fromdate and @ToDate and Dlvsts>3
--	AND SMID=@SmId AND P.Vending=3
--	GROUP BY SMID,RMID,BillMode
--UNION ALL
--	SELECT SMID,RMID,0 as PrdNetAmount,SUM(PrdNetAmt)  as RetPrdNetAmt
--	FROM ReturnHeader SI
--	INNER JOIN ReturnProduct SIP ON SI.ReturnID=SIP.ReturnID
--	INNER JOIN Product P ON P.PrdId=SIP.prdid
--	WHERE ReturnDate Between @FromDate and @ToDate and Status=0
--	AND SMID=@SmId AND P.Vending=3
--	GROUP BY SMID,RMID
--)X INNER JOIN salesman SM ON X.smid=SM.smid GROUP BY X.SMID,Smcode

SELECT SM.SMID,Smcode,SUM(PrdNetAmount) as NetSales
	INTO #InfantNutritionSales  FROM SalesInvoice SI
	INNER JOIN SalesInvoiceProduct SIP On SIP.Salid=Si.Salid
	INNER JOIN Product P ON P.PrdId=SIP.prdid
	INNER JOIN #EXCLUSIONS E ON E.Prdid=SIP.Prdid and E.Prdid=P.Prdid
	INNER JOIN salesman SM ON SI.smid=SM.smid 
	WHERE Salinvdate Between @FromDate and @ToDate and Dlvsts>3
	AND SM.SMID=@SmId
	GROUP BY SM.SMID,Smcode

UPDATE tempSalesmanMTDDashBoard SET [VALUES]=[Productivity %] FROM tempSalesmanMTDDashBoard T INNER JOIN #SALESMAN S
ON T.smid=S.smid WHERE TransType=1

UPDATE tempSalesmanMTDDashBoard SET [VALUES]=[SKU per Call (All SKU)] FROM tempSalesmanMTDDashBoard T INNER JOIN #SALESMAN S
ON T.smid=S.smid WHERE TransType=2

UPDATE tempSalesmanMTDDashBoard SET [VALUES]=[RDBN (All SKU)] FROM tempSalesmanMTDDashBoard T INNER JOIN #SALESMAN S
ON T.smid=S.smid WHERE TransType=3

UPDATE K SET K.[VALUES]=P.NetSales FROM TempSalesmanMTDDashBoard K INNER JOIN #InfantNutritionSales P 
ON P.Smcode=K.Smcode WHERE TransType=4

UPDATE K SET K.[VALUES]=[Active Retailers]-[Total Retailers Billed] FROM TempSalesmanMTDDashBoard K INNER JOIN #SALESMAN S
ON K.smid=S.smid WHERE TransType=5

UPDATE tempSalesmanMTDDashBoard SET [VALUES]=[Outlets Created] FROM tempSalesmanMTDDashBoard T INNER JOIN #SALESMAN S
ON T.smid=S.smid WHERE TransType=6

Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.SalesmanMTDDashBoard (srpCde,Items,[VALUES])'
Set @InsSQL = @InsSQL +'select Smcode,Items,[VALUES]
		FROM '+ QuoteName(@FromDBName) + '.dbo.TempSalesmanMTDDashBoard'
exec (@InsSQL)
--SELECT *   FROM tempSalesmanMTDDashBoard
--SELECT * FROM SalesmanMTDDashBoard
END 
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_ExportImport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_ExportImport]
GO
--Exec Proc_ExportImport 'jnj','jnjinter','S3','S3',0
CREATE PROCEDURE [Proc_ExportImport]
(
	@FromDBName VARCHAR(50),
	@ToDBName VARCHAR(50),
	@SalRpCode VARCHAR(50),
	@MktCode VARCHAR(50),
	@Process INT
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)

BEGIN
	IF @Process = 0
	BEGIN
		Exec Proc_Export_PDA_SalesRepresentative @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Market @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Bank @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_BankBranch @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_ProductCategory @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_ProductCategoryValue @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Products @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_ProductBatch @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Retailer @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Collection @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_CreditNote @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_DebitNote @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_ReasonMaster @FromDBName,@ToDBName,@SalRpCode
		EXEC Proc_Export_PDA_Distributor @FromDBName,@ToDBName,@SalRpCode
		--EXEC Proc_Export_PDA_SalesmanMTDDashBoard  @FromDBName,@ToDBName,@SalRpCode
		EXEC Proc_Export_PDA_RetailerWisesales @FromDBName,@ToDBName,@SalRpCode
		
	END
	ELSE IF @Process = 1
	BEGIN
		Exec Proc_Import_PDA_OrderBooking @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Import_PDA_SalesReturn @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Import_PDA_CreditNote @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Import_PDA_DebitNote @FromDBName,@ToDBName,@SalRpCode
		
	END
END
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'PDALog') AND type in (N'U'))
DROP TABLE PDALog
GO
CREATE TABLE PDALog(
	[Sno] [int] IDENTITY(1,1) NOT NULL,
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataPoint] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_OrderBooking]') AND type in (N'U'))
DROP TABLE [PDA_Temp_OrderBooking]
GO

CREATE TABLE [PDA_Temp_OrderBooking](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrdKeyNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrdDt] [datetime] NULL,
	[RtrCde]  Nvarchar(20) NOT NULL,
	[Mktid] [int] NULL,	
	[SrpId] [int] NOT NULL,
	[Rtrid]	[Int] NOT NULL,
	[UploadFlag] varchar(1) NULL)
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_OrderProduct]') AND type in (N'U'))
DROP TABLE [PDA_Temp_OrderProduct]
GO

CREATE TABLE [PDA_Temp_OrderProduct](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrdKeyNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[PriceId]	[Int] NOT NULL,
	[OrdQty] [int] NULL,
	[UploadFlag] varchar(1) NULL
)
GO

--SALES RETURN
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_SalesReturn]') AND type in (N'U'))
DROP TABLE [PDA_Temp_SalesReturn]
GO

CREATE TABLE [PDA_Temp_SalesReturn](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SrNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SrDate] [datetime] NULL,
	[SalInvNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrCde]  Nvarchar(20) NULL,
	[Mktid] [int] NULL DEFAULT (0),
	[Srpid] [int] NULL DEFAULT (0),
	[ReturnMode] [INT] NOT NULL  DEFAULT (0),
	[InvoiceType] [INT] NOT NULL  DEFAULT (0),
	[RtrId]			[INT] NOT NULL DEFAULT (0),
	[UploadFlag] varchar(1) NULL
)
GO

--SALES RETURN PRODUCT
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_SalesReturnProduct]') AND type in (N'U'))
DROP TABLE [PDA_Temp_SalesReturnProduct]
GO

CREATE TABLE [PDA_Temp_SalesReturnProduct](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SrNo]    Nvarchar(25),
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[PriceId]	[Int] NOT NULL,
	[SrQty] [int] NULL,
	[UsrStkTyp] [int] NOT NULL,
	[salinvno] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (0),
	[SlNo] [int] NOT NULL DEFAULT (0),
	[UploadFlag] varchar(1) NULL
) 
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_SalesReturn]') AND type in (N'U'))
DROP TABLE [PDA_SalesReturn]
GO

CREATE TABLE [PDA_SalesReturn](
	[SrNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SrDate] [datetime] NULL,
	[SalInvNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId]			[INT] NOT NULL DEFAULT (0),
	[Mktid] [int] NULL DEFAULT (0),
	[Srpid] [int] NULL DEFAULT (0),
	[ReturnMode] [INT] NOT NULL  DEFAULT (0),
	[InvoiceType] [INT] NOT NULL  DEFAULT (0),
	[Status] INT
)
GO

--SALES RETURN PRODUCT
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_SalesReturnProduct]') AND type in (N'U'))
DROP TABLE [PDA_SalesReturnProduct]
GO

CREATE TABLE [PDA_SalesReturnProduct](
    [SrNo]    Nvarchar(25),
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[PriceId]	[Int] NOT NULL,
	[SrQty] [int] NULL,
	[UsrStkTyp] [int] NOT NULL,
	[salinvno] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (0),
	[SlNo] [int] NOT NULL DEFAULT (0)
) 
GO


IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_CreditNote]') AND type in (N'U'))
DROP TABLE [PDA_Temp_CreditNote]
GO

CREATE TABLE [PDA_Temp_CreditNote](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CrNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CrAmount] [numeric](18, 2) NULL,
	[RtrId] [numeric](18, 0) NOT NULL,
	[CrAdjAmount] [numeric](18, 2) NULL,
	[TranNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] varchar(1) NULL
)
GO

--DEBIT NOTE
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_DebitNote]') AND type in (N'U'))
DROP TABLE [PDA_Temp_DebitNote]
GO

CREATE TABLE [PDA_Temp_DebitNote](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DbNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DbAmount] [numeric](18, 2) NOT NULL,
	[RtrId] [numeric](18, 0) NOT NULL,
	[DbAdjAmount] [numeric](18, 2) NULL,
	[TransNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] varchar(1) NULL
)
GO

--Import OrderBooking
IF EXISTS (SELECT * FROM sysobjects WHERE name ='Proc_Import_PDA_OrderBooking'  AND xtype='P')
DROP PROCEDURE [Proc_Import_PDA_OrderBooking]
GO
CREATE PROCEDURE [Proc_Import_PDA_OrderBooking]      
(      
	@FromDBName varchar(50),      
	@ToDBName varchar(50),      
	@SalRpCode varchar(50)      
)      
AS      
      
/*********************************/      
DECLARE @SQL AS nvarchar(3000)      
DECLARE @OPSQL AS nvarchar(3000)      
DECLARE @DelSQL AS varchar(1000)      
DECLARE @InsSQL AS varchar(5000)      
DECLARE @UpdSQL AS varchar(1000)      
DECLARE @UpdFlgSQL AS varchar(1000)      
DECLARE @OrdKeyNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT      
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @RtrShipId AS INT
DECLARE @OrdPrdCnt AS INT
DECLARE @PdaOrdPrdCnt AS INT
DECLARE @OrderDate AS DateTime
      
BEGIN
	BEGIN TRANSACTION T1
	IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_OrderBooking]') AND type in (N'U'))
	BEGIN
		DROP TABLE PDA_Temp_OrderBooking
	END

	Set @SQL = ' SELECT SrpCde,OrdKeyNo,OrdDt,RtrCde,Mktid,SrpId,R.Rtrid,UploadFlag INTO PDA_Temp_OrderBooking '
	SET  @SQL = @SQL+ 'FROM '+ QuoteName(@ToDBName) + '.dbo.OrderBooking OB INNER JOIN Retailer R on OB.RtrCde=R.RtrCode '
	SET  @SQL = @SQL+' WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''''

	EXEC(@SQL)

	SET @SrpId = (SELECT SMId FROM SalesMan Where SMCode = @SalRpCode)
	DECLARE CUR_Import Cursor For
	Select DISTINCT OrdKeyNo  From PDA_Temp_OrderBooking
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo
	While @@Fetch_Status = 0
	BEGIN
		SET @OrdPrdCnt=0
		SET @PdaOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0
		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking WHERE DocRefNo = @OrdKeyNo)
		BEGIN
			SET @RtrId = (Select RtrId FROM PDA_Temp_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@RtrId,'Retailer Does Not Exists for the Order ' + @OrdKeyNo--FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			SELECT @RtrShipId=RS.RtrShipId   
			FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid WHERE RtrShipDefaultAdd=1  
			AND R.RtrId=@RtrId  

			SET @MktId = (Select MktId FROM PDA_Temp_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			IF NOT EXISTS (SELECT * FROM SalesManMarket WHERE RMID = @MktId AND SMID = @SrpId)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Not Maped with the DBSR for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			IF EXISTS (SELECT NAME FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_OrderProduct]') AND type in (N'U'))
			BEGIN
				DROP TABLE PDA_Temp_OrderProduct
			END
			Set @OPSQL = 'SELECT * INTO PDA_Temp_OrderProduct FROM '+ QuoteName(@ToDBName) + '.dbo.OrderProduct WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
			EXEC(@OPSQL)

			IF NOT EXISTS(SELECT OrdKeyNo FROM  PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Product Details Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END
			IF @lError=0
			BEGIN
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @OrdQty AS INT
				DECLARE CUR_ImportOrderProduct CURSOR FOR
				SELECT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  From PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo GROUP BY PrdId,PrdBatId,PriceId
				OPEN CUR_ImportOrderProduct
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
						IF NOT EXISTS(SELECT PrdId From Product WHERE Prdid=@Prdid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdid,' Product Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdbatid,' Product Batch Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@PriceId,' Product Batch Price Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF @OrdQty<=0
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdQty,' Ordered Qty Should be Greater than Zero for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END

						

				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				END
				CLOSE CUR_ImportOrderProduct
				DEALLOCATE CUR_ImportOrderProduct

				SET @GetKeyStr=''  
				SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('OrderBooking','OrderNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
				IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
				BEGIN  
					SET @lError = 1
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Ordered Key No not generated' --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
					BREAK  
				END

			IF @lError = 0
			BEGIN
				--HEDER 
					SELECT  @OrderDate= OrdDt FROM PDA_Temp_OrderBooking WHERE  OrdKeyNo=@OrdKeyNo
					INSERT INTO OrderBooking(  
					OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,RtrId,OrdType,  
					Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,RndOffValue,TotalAmount,Status,  
					Availability,LastModBy,LastModDate,AuthId,AuthDate,PDADownLoadFlag)  
					SELECT @GetKeyStr,Convert(DateTime,@OrderDate,121),  
					Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					0,@OrdKeyNo,0, @SrpId as Smid,  
					@MktId as RmId,@RtrId as RtrId,0 as OrdType,0 as Priority,0 as FillAllPrd,0 as ShipTo,  
					@RtrShipId as RtrShipId,'' as Remarks,0  as RoundOff,0 as RndOffValue,  
					0 as TotalAmount,0 as Status,1,1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),1  

				   --DETAILS  
				  INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,  
						  ConvFact2,TotalQty,BilledQty,Rate,MRP,GrossAmount,PriceId,  
						  Availability,LastModBy,LastModDate,AuthId,AuthDate)  
				  SELECT @GetKeyStr,P.Prdid,PB.Prdbatid,UG.UomID,  
				  --Cast(QtyPUnit as Int)*Cast(numberOfPackingUnits as Int),  
				  OrdQty ,  
				  ConversionFactor,0,0,0,  
				  --Cast(QtyPUnit as Int)*Cast(numberOfPackingUnits as Int),0,  
				  OrdQty,0,  
				  PBD.PrdBatDetailValue,PBD1.PrdBatDetailValue,  
				  --PBD.PrdBatDetailValue*(Cast(QtyPUnit as Int)*Cast(numberOfPackingUnits as Int)),  
				  PBD.PrdBatDetailValue*OrdQty,  
				  PBD.PriceId,  
				  1,1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
				  1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121)  
				  FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
				  INNER JOIN (SELECT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  FROM PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo
							 GROUP BY PrdId,PrdBatId,PriceId) PT ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
				  INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
				  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId  
					 and BC.slno=PBD.SLNo AND BC.SelRte=1  and PBD.PriceId=PT.PriceId
				  INNER JOIN BatchCreation BC1 (NOLOCK) ON BC1.BatchSeqId=PB.BatchSeqId  
				  INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD1.PriceId  
					 and BC1.slno=PBD1.SLNo AND BC1.MRP=1  and PBD1.PriceId=PT.PriceId
				  INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y'  
--				  GROUP BY  
--				  P.Prdid,PB.Prdbatid,UG.UomID,PBD.PrdBatDetailValue,  
--				  PBD1.PrdBatDetailValue,PBD.PriceId,ConversionFactor 

				  UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB   
				  INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X   
				  ON X.OrderNo=OB.OrderNo   

				SELECT SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId,--@GetKeyStr as CSOrderNo,
				SUM(OrdQty) as Qty  
				INTO #TEMPCHECK   
				FROM PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo
				GROUP BY  
				SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId
        
					
				
				SELECT @OrdPrdCnt=ISNULL(Count(OrderNo),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
				SELECT @PdaOrdPrdCnt=ISNULL(Count(OrdKeyNo),0) FROM #TEMPCHECK (NOLOCK) WHERE OrdKeyNo=@OrdKeyNo
						IF @OrdPrdCnt=@PdaOrdPrdCnt  
						BEGIN 
							UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
				
							SET @UpdFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.OrderBooking SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
							EXEC(@UpdFlgSQL)

							SET @UpdOPFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.OrderProduct SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
							EXEC(@UpdOPFlgSQL)
						END
						ELSE
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Ordered Product Number of line count not match for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
							DELETE FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr  
							DELETE FROM ORDERBOOKING WHERE OrderNo=@GetKeyStr  
						END 
	
				
				DROP TABLE #TEMPCHECK
				END
			END
		END
		ELSE
		BEGIN
			Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'ORDERBOOKING'
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,'Order Already exists' --FROM TempOrderBooking WHERE OrdKeyNo=@OrdKeyNo
		END
		
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo
	END
	Close CUR_Import
	DeAllocate CUR_Import

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION T1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION T1
	END
END
GO
--SalesReturn
IF EXISTS (SELECT * FROM sysobjects WHERE name ='Proc_Import_PDA_SalesReturn'  AND xtype='P')
DROP PROCEDURE [Proc_Import_PDA_SalesReturn]
GO
CREATE  PROCEDURE [Proc_Import_PDA_SalesReturn]      
(      
 @FromDBName varchar(50),      
 @ToDBName varchar(50),      
 @SalRpCode varchar(50)      
)      
AS      
DECLARE @SQL AS nvarchar(3000)      
DECLARE @OPSQL AS nvarchar(3000)      
DECLARE @DelSQL AS varchar(1000)      
DECLARE @InsSQL AS varchar(5000)      
DECLARE @UpdSQL AS varchar(1000)      
DECLARE @UpdFlgSQL AS varchar(1000)      
DECLARE @SrNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT    
DECLARE @SalInvNo AS nVarchar(50)
DECLARE @Salid AS INT  
      
BEGIN      
 BEGIN TRANSACTION T1      
 IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_SalesReturn]') AND type in (N'U'))      
 BEGIN      
  DROP TABLE PDA_Temp_SalesReturn      
 END   

 IF  EXISTS(SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)
 BEGIN
      
		 Set @SQL = 'SELECT SrpCde,SrNo,SrDate,SalInvNo,RtrCde,Mktid,Srpid,ReturnMode,InvoiceType,R.RtrId,UploadFlag '  
		 Set @SQL =@SQL+ ' INTO PDA_Temp_SalesReturn FROM '+ QuoteName(@ToDBName) + '.dbo.SalesReturn SR INNER JOIN Retailer R ON R.RtrCode=SR.RtrCde '  
		 Set @SQL =@SQL+ ' WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''''   
		 EXEC(@SQL)      
		--SELECT * From PDA_Temp_SalesReturnProduct      
		 SET @SrpId = (SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)      
				
		 DECLARE CUR_Import Cursor For      
		 Select Distinct SrNo From PDA_Temp_SalesReturn          
		 OPEN CUR_Import      
		 FETCH NEXT FROM CUR_Import INTO @SrNo      
		 While @@Fetch_Status = 0      
		 BEGIN      
		  SET @lError = 0
		  SET @SalInvNo	=''
		  SET @RtrId=0
		  SET @MktId=0
		  SET @SalId=0			
		  IF NOT EXISTS (SELECT DocRefNo FROM ReturnHeader WHERE DocRefNo = @SrNo)      
		  BEGIN      
			   SET @RtrId = (Select RtrId FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo)       
			   IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE Rtrid = @RtrId and RtrStatus = 1)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@RtrId,'Retailer Does Not Exists for the SalesReturn No ' + @SrNo 
			   END      
		      
			   SET @MktId = (Select MktId FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo)       
			   IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Does Not Exists for the SalesReturn No ' + @SrNo 
			   END      
		      
			   IF NOT EXISTS (SELECT RMId,SMId FROM SalesManMarket WHERE RMId = @MktId AND SMId = @SrpId)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Not Maped with the DBSR for the SalesReturn No ' + @SrNo  
			   END

			   IF NOT EXISTS (SELECT RMId,RtrId FROM RetailerMarket WHERE RMId = @MktId AND RtrId = @RtrId)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Not Maped with the Retailer for the SalesReturn No ' + @SrNo  
			   END

				IF EXISTS(SELECT SalInvNo FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo and InvoiceType=1)
				BEGIN
					SELECT @SalInvNo=ISNULL(SalInvNo,'') FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo and InvoiceType=1
					IF LEN(@SalInvNo)=0 
					BEGIN
						SET @lError = 1      
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
						SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Reference Invoice not exist for the SalesReturn No' + @SrNo 
					END
					ELSE IF NOT EXISTS(SELECT SalId From SalesInvoice WHERE Salinvno=@SalInvNo)
					BEGIN
						SET @lError = 1      
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
						SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Reference  SalesInvoice not exist for the SalesReturn No' + @SrNo 
					END
				END

				IF EXISTS (SELECT NAME FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_SalesReturnProduct]') AND type in (N'U'))
				BEGIN
					DROP TABLE PDA_Temp_SalesReturnProduct
				END
				Set @OPSQL = 'SELECT * INTO PDA_Temp_SalesReturnProduct FROM '+ QuoteName(@ToDBName) + '.dbo.SalesReturnProduct WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''' AND SrNo = ''' + @SrNo + ''''
				EXEC(@OPSQL)

				IF NOT EXISTS(SELECT SrNo FROM  PDA_Temp_SalesReturnProduct WHERE SrNo=@SrNo)
				BEGIN
					SET @lError = 1
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Product Details Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
				END


			IF @lError=0
			BEGIN
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @RtnQty AS INT
				DECLARE @StockType AS INT
				DECLARE @SalinvnoRef AS nVarchar(50)
				DECLARE @UsrStkTyp AS INT
				DECLARE @Slno AS INT
				DECLARE CUR_ImportReturnProduct CURSOR FOR
				SELECT PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,SlNo From PDA_Temp_SalesReturnProduct WHERE SrNo=@SrNo  ORDER BY SlNo 
				OPEN CUR_ImportReturnProduct
				FETCH NEXT FROM CUR_ImportReturnProduct INTO @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
						IF NOT EXISTS(SELECT PrdId From Product (NOLOCK) WHERE Prdid=@Prdid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdid,' Product Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdbatid,' Product Batch Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@PriceId,' Product Batch Price Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF @RtnQty<=0
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Return Qty Should be Greater than Zero for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END

						

				FETCH NEXT FROM CUR_ImportReturnProduct INTO  @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno
				END
				CLOSE CUR_ImportReturnProduct
				DEALLOCATE CUR_ImportReturnProduct
		 

					IF @lError = 0       
					BEGIN
						--HEADER	   
						INSERT INTO PDA_SalesReturn (SrNo,SrDate,SalInvNo,RtrId,Mktid,Srpid,ReturnMode,InvoiceType,Status)
						SELECT SrNo,Getdate(),SalInvNo,RtrId,Mktid,@SrpId,ReturnMode,InvoiceType,0
						FROM PDA_Temp_SalesReturn WHERE SrNo=@SrNo
						--DETAILS
						INSERT INTO PDA_SalesReturnProduct(SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo)
						SELECT @SrNo,PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,SlNo From PDA_Temp_SalesReturnProduct  
						WHERE SrNo=@SrNo


						SET @UpdFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.SalesReturn SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND SrNo = ''' + @SrNo + ''''      
						EXEC(@UpdFlgSQL)      

						SET @UpdOPFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.SalesReturnProduct SET [UploadFlag] = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and [UploadFlag] = ''N'' AND SrNo = ''' + @SrNo + ''''      
						EXEC(@UpdOPFlgSQL)      


					END 
			END      
		  END      
		  ELSE      
		  BEGIN      
			   Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'SALESRETURN'      
			   INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			   SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Sales Return Already exists'      
		  END       
		FETCH NEXT FROM CUR_Import INTO @SrNo      
		END      
		CLOSE CUR_Import      
		DEALLOCATE CUR_Import     
END
ELSE
BEGIN
		 INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
		 SELECT '' + @SalRpCode + '','SALESRETURN',@SalRpCode,'SalesMan Does not exists ' 
END 
      
 IF @@ERROR = 0      
 BEGIN      
  COMMIT TRANSACTION T1      
 END      
 ELSE      
 BEGIN      
  ROLLBACK TRANSACTION T1      
 END      
END      
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Import_PDA_CreditNote') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Import_PDA_CreditNote
GO
--Exec Proc_Import_PDA_CreditNote 'NesFresh','NestleConsole','S001'
CREATE PROCEDURE Proc_Import_PDA_CreditNote
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: [Proc_Import_PDA_CreditNote]
* PURPOSE: To Insert the records From Intermediate into CoreStocky Database
* SCREEN : CREDITNOTE
* CREATED: MURUGAN.R
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS nvarchar(3000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @UpdSQL AS varchar(1000)
DECLARE @Crno AS varchar(20)
DECLARE @Cramount AS numeric(18,2)
DECLARE @Rtrid AS numeric(18,0)
DECLARE @Cradjamt AS numeric(18,2)
DECLARE @Tranno AS varchar(20)
DECLARE @Reasonid AS int
DECLARE @CurrVal AS INT
DECLARE @lError AS INT
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @CoaId AS INT
DECLARE @VocDate AS DATETIME 
BEGIN
	BEGIN TRANSACTION C1

	IF EXISTS(SELECT SMCODE FROM SalesMan WHERE SMCODE=@SalRpCode)
	BEGIN
			IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_CreditNote]') AND type in (N'U'))
			BEGIN
				DROP TABLE PDA_Temp_CreditNote
			END

			Set @SQL = 'SELECT * INTO PDA_Temp_CreditNote FROM '+ QuoteName(@ToDBName) + '.dbo.CreditNote_Import WHERE SrpCde= ''' + @SalRpCode + ''' AND [UploadFlag] =''N'''    
			EXEC(@SQL)

			DECLARE Cur_ImportCreditNote CURSOR
			FOR SELECT DISTINCT CrNo FROM PDA_Temp_CreditNote
			OPEN Cur_ImportCreditNote
			FETCH NEXT FROM Cur_ImportCreditNote INTO @Crno
			WHILE @@FETCH_STATUS=0
			BEGIN
				SET @lError = 0
				SET @RtrId=0
				SET @CoaId=0
				IF NOT EXISTS(SELECT PostedRefNo FROM CreditNoteRetailer WHERE PostedRefNo=@Crno)
				BEGIN
		 
					SELECT @RtrId =RtrId FROM PDA_Temp_CreditNote WHERE CrNo=@Crno 
					IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
					BEGIN
						SET @lError = 1
						Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'CREDITNOTE' AND [Name]=@RtrId
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','CREDITNOTE',@RtrId,'Retailer Does Not Exists For the CreditNote ' +@Crno
					END
					ELSE
					BEGIN
						SELECT @CoaId=CoaId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1
					END
					IF EXISTS(SELECT CrAmount FROM PDA_Temp_CreditNote WHERE CrNo=@Crno AND CrAmount<=0)
					BEGIN
							SET @lError = 1
							Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'CREDITNOTE' AND [Name]=@Crno
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','CREDITNOTE',@Crno,'Credit Amount should be Greater than zero for the CreditNote ' +@Crno
					END
					SET @GetKeyStr=''  
					SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
					IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
					BEGIN  
						SET @lError = 1
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','CREDITNOTE',@Crno,' Credit Note Key Number not generated' --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						BREAK  
					END

					

					IF @lError = 0
					BEGIN 
						INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,Status,PostedFrom,TransId,PostedRefNo,
														Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
						SELECT @GetKeyStr,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),@RtrId,@CoaId,ReasonId,
						CrAmount,ISNULL(CrAdjAmount,0),1,
						CASE WHEN LEN(ISNULL(TranNo,'') )=0 THEN @GetKeyStr ELSE TranNo END, 
						254,@Crno,1,1,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),
						1,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),'PDA Down Credit Note'
						FROM PDA_Temp_CreditNote WHERE CrNo=@Crno
						IF EXISTS(SELECT PostedRefNo FROM CreditNoteRetailer WHERE PostedRefNo=@Crno)
						BEGIN
								UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TABNAME='CreditNoteRetailer' AND FldName='CrNoteNumber'
								---VOUCHER NOTE
								SELECT @VocDate= Convert(DateTime,Convert(Varchar(10),Getdate(),121),121)--CrNoteDate FROM CreditNoteRetailer WHERE CrNoteNumber=@GetKeyStr
								EXEC Proc_VoucherPosting 18,1,@GetKeyStr,3,6,1,@VocDate,0
								SET @UpdSQL=''
								SET @UpdSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.CreditNote_Import SET [UploadFlag] = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and [UploadFlag] = ''N'''
								EXEC(@UpdSQL)
						END
					END 
				END 
				ELSE
				BEGIN
					Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'CREDITNOTE' AND [Name]=@Crno
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','CREDITNOTE',@Crno,'Credit Already exists' FROM PDA_Temp_CreditNote WHERE CrNo=@Crno
				END	
				FETCH NEXT FROM Cur_ImportCreditNote INTO @Crno
			END
				CLOSE Cur_ImportCreditNote
				DEALLOCATE Cur_ImportCreditNote 
	END
	ELSE
	BEGIN
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','CREDITNOTE',@SalRpCode,'Sales Man Does not Exists'
	END	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION C1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION C1
	END
END
GO
--Import DebitNote
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Import_PDA_DebitNote') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Import_PDA_DebitNote
GO
CREATE PROCEDURE Proc_Import_PDA_DebitNote
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: [Proc_Import_PDA_DebitNote]
* PURPOSE: To Insert the records From Intermediate into CoreStocky Database
* SCREEN : DEBITNOTE
* CREATED: Murugan.R 
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS nvarchar(3000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @UpdSQL AS varchar(1000)
DECLARE @Dbno AS varchar(20)
DECLARE @Dbamount AS numeric(18,2)
DECLARE @Rtrid AS numeric(18,0)
DECLARE @Dbadjamt AS numeric(18,2)
DECLARE @Transno AS varchar(20)
DECLARE @Reasonid AS int
DECLARE @CurrVal AS INT
DECLARE @lError AS INT
DECLARE @CoaId AS INT
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @VocDate AS DATETIME

BEGIN
	BEGIN TRANSACTION D1
	IF EXISTS(SELECT SMCODE FROM SalesMan WHERE SMCODE=@SalRpCode)
	BEGIN
			IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_DebitNote]') AND type in (N'U'))
			BEGIN
				DROP TABLE PDA_Temp_DebitNote
			END

			Set @SQL = 'SELECT * INTO PDA_Temp_DebitNote FROM '+ QuoteName(@ToDBName) + '.dbo.DebitNote_Import WHERE SrpCde= ''' + @SalRpCode +''' AND [UploadFlag] =''N'''    
			EXEC(@SQL)
			
			DECLARE Cur_ImportDebitNote CURSOR
			FOR SELECT DISTINCT DbNo FROM PDA_Temp_DebitNote
			OPEN Cur_ImportDebitNote
			FETCH NEXT FROM Cur_ImportDebitNote INTO @Dbno
			WHILE @@FETCH_STATUS=0
			BEGIN
				SET @lError = 0
				SET @RtrId=0
				SET @CoaId=0
				IF NOT EXISTS(SELECT * FROM DebitNoteRetailer WHERE PostedRefNo=@Dbno)
				BEGIN
					SET @RtrId = (Select RtrId FROM PDA_Temp_DebitNote WHERE DbNo=@Dbno) 
					IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId  AND RtrStatus = 1)
					BEGIN
						SET @lError = 1
						Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'DEBITNOTE' AND [Name]=@RtrId
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','DEBITNOTE',@RtrId,'Retailer Does Not Exists For the DebitNote ' + @Dbno
					END
					ELSE
					BEGIN
						SELECT @CoaId=CoaId FROM  Retailer WHERE RtrID = @RtrId  AND RtrStatus = 1
					END

					IF EXISTS(SELECT DbAmount FROM PDA_Temp_DebitNote WHERE DbNo=@Dbno AND DbAmount<=0)
					BEGIN
						SET @lError = 1
						Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'DEBITNOTE' AND [Name]=@Dbno
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','DEBITNOTE',@Dbno,'Debit Amount should be Greater than zero for the Debit Note ' + @Dbno
					END

					SET @GetKeyStr=''  
					SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('DebitNoteRetailer','DbNoteNumber',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))     
					IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
					BEGIN  
						SET @lError = 1
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','DEBITNOTE',@Dbno,' Debit Note Key Number Not generated' 
						BREAK  
					END

					IF @lError = 0 
					BEGIN 
					
						INSERT INTO DebitNoteRetailer(DbNoteNumber,DbNoteDate,RtrId,CoaId,ReasonId,Amount,DbAdjAmount,Status,PostedFrom,TransId,
														PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
								SELECT @GetKeyStr,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),@RtrId,@CoaId,Reasonid,
								DbAmount,ISNULL(DbAdjAmount,0),1,
								CASE WHEN LEN(ISNULL(TransNo,'') )=0 THEN @GetKeyStr ELSE TransNo END, 
								254,@Dbno,1,1,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),
								1,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),'PDA Down Debit Note'
								FROM PDA_Temp_DebitNote WHERE DbNo=@Dbno

								IF EXISTS(SELECT PostedRefNo FROM DebitNoteRetailer WHERE PostedRefNo=@Dbno)
								BEGIN
										UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TABNAME='DebitNoteRetailer' AND FldName='DbNoteNumber'
										---VOUCHER NOTE
										SELECT @VocDate= Convert(DateTime,Convert(Varchar(10),Getdate(),121),121)--CrNoteDate FROM CreditNoteRetailer WHERE CrNoteNumber=@GetKeyStr
										EXEC Proc_VoucherPosting 19,1,@GetKeyStr,3,7,1,@VocDate,0
										SET @UpdSQL=''
										SET @UpdSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.DebitNote_Import SET [UploadFlag] = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and [UploadFlag] = ''N'''
										EXEC(@UpdSQL)
								END

					
						
					END 
				END
				ELSE
				BEGIN
					Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'DEBITNOTE' AND [Name]=@Dbno
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','DEBITNOTE',@Dbno,'Debit Already exists'
				END	 
				FETCH NEXT FROM Cur_ImportDebitNote INTO @Dbno
			END
				CLOSE Cur_ImportDebitNote
				DEALLOCATE Cur_ImportDebitNote
	END
	ELSE
	BEGIN
			DELETE FROM PDALog Where SrpCde = @SalRpCode And DataPoint = 'DEBITNOTE' AND [Name]=@SalRpCode
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','DEBITNOTE',@SalRpCode,'Sales Man Does not Exists'
	END
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION D1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION D1
	END 
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='TempPDA_RtrWiseProductSales' AND xtype='U')
DROP TABLE TempPDA_RtrWiseProductSales
GO
CREATE TABLE TempPDA_RtrWiseProductSales
(
salinvno varchar(100),
Salinvdate datetime,
RtrCode nvarchar(100),
RtrName nvarchar(200),
PrdCCode nvarchar(100),
PrdName nvarchar(200),
Qty int,
InvType varchar(50)
)
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_RetailerWisesales') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_RetailerWisesales
GO
--Exec Proc_Export_PDA_RetailerWisesales 'test','JnJIntermediate','01'
CREATE PROCEDURE Proc_Export_PDA_RetailerWisesales
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: Proc_Export_PDA_RetailerWisesales
* PURPOSE: To Insert the records From main db into Intermediate Database
* SCREEN : RetailerWisesales
* CREATED: KARTHICK.K.J
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @UpSQL AS varchar(2000)
DECLARE @Smid AS int 

BEGIN

DELETE FROM TempPDA_RtrWiseProductSales
SET @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales Where SrpCode = ''' + @SalRpCode + ''''
EXEC (@DelSQL)

SELECT @Smid=SMID FROM Salesman WHERE SMCode=@SalRpCode


DECLARE @Rtrid AS int
DECLARE @prdid AS int 
DECLARE @Rtrcode AS varchar(100)
DECLARE @Rtrname AS varchar(200)
DECLARE @Prdccode AS varchar(100)
DECLARE @prdName AS varchar(200)
DECLARE @Baseqty AS int
DECLARE @Cnt AS int
DECLARE @SalInvDate datetime
DECLARE @salinvno varchar(100)

DECLARE Cur_RtrwiseProdut CURSOR 
FOR 
SELECT DISTINCT si.rtrid,sip.prdid FROM salesinvoice si 
INNER JOIN SalesInvoiceProduct sip ON si.SalId=sip.salid
WHERE DlvSts<>2 AND SMId=@Smid
ORDER BY si.RtrId
OPEN Cur_RtrwiseProdut
FETCH next  FROM Cur_RtrwiseProdut INTO  @Rtrid,@prdid
WHILE @@fetch_status=0
BEGIN
SET @Cnt=0

	DECLARE Cur_RtrwiseProdutSales CURSOR 
	FOR SELECT SalInvDate,salinvno,rtrcode,Rtrname,prdccode,prdName,baseqty FROM (
		SELECT TOP 3 si.salid,SalInvDate,salinvno,rtrcode,RtrName,prdccode,PrdName,sum(baseqty) baseqty
		FROM salesinvoice si 
			INNER JOIN SalesInvoiceProduct sip ON si.SalId=sip.salid
			INNER JOIN Retailer R ON R.rtrid=si.RtrId 
			INNER JOIN Product P ON P.prdid=sip.prdid
		WHERE SI.RtrId=@Rtrid AND sip.prdid=@prdid AND DlvSts<>2
		GROUP BY SalInvDate,salinvno,rtrcode,prdccode,RtrName,PrdName,si.SalId ORDER BY SalInvDate DESC,si.salid desc)A
	OPEN Cur_RtrwiseProdutSales
	FETCH next  FROM Cur_RtrwiseProdutSales INTO @SalInvDate,@salinvno,@Rtrcode,@Rtrname,@Prdccode,@prdName,@Baseqty
	WHILE @@fetch_status=0
	BEGIN
		SET @Cnt=@Cnt+1
		
		INSERT INTO TempPDA_RtrWiseProductSales
		SELECT @salinvno,@SalInvDate,@Rtrcode,@Rtrname,@Prdccode,@prdName,@Baseqty,'Invoice'+cast(@Cnt AS varchar(1))


	FETCH next  FROM Cur_RtrwiseProdutSales INTO @SalInvDate,@salinvno,@Rtrcode,@Rtrname,@Prdccode,@prdName,@Baseqty
	END 
	CLOSE Cur_RtrwiseProdutSales
	DEALLOCATE Cur_RtrwiseProdutSales


FETCH next  FROM Cur_RtrwiseProdut INTO  @Rtrid,@prdid
END 
CLOSE Cur_RtrwiseProdut
DEALLOCATE Cur_RtrwiseProdut


Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales(SrpCode,RtrCode,RtrName,PrdCCode,PrdName )'
Set @InsSQL = @InsSQL + 'SELECT DISTINCT ''' + @SalRpCode + ''',RtrCode,RtrName,PrdCCode,PrdName FROM '+ QuoteName(@FromDBName) + '..TempPDA_RtrWiseProductSales'
EXEC (@InsSQL)

SET @UpSQL='UPDATE '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales SET  Invoice1=Qty FROM '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales R INNER JOIN'
Set @UpSQL = @UpSQL +' '+ QuoteName(@FromDBName) + '..TempPDA_RtrWiseProductSales T ON R.RtrCode=T.RtrCode AND R.PrdCCode=T.PrdCCode WHERE InvType=''Invoice1'''
EXEC (@UpSQL)

SET @UpSQL='UPDATE '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales SET  Invoice2=Qty FROM '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales R INNER JOIN'
Set @UpSQL = @UpSQL +' '+ QuoteName(@FromDBName) + '..TempPDA_RtrWiseProductSales T ON R.RtrCode=T.RtrCode AND R.PrdCCode=T.PrdCCode WHERE InvType=''Invoice2'''
EXEC (@UpSQL)

SET @UpSQL='UPDATE '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales SET  Invoice3=Qty FROM '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales R INNER JOIN'
Set @UpSQL = @UpSQL +' '+ QuoteName(@FromDBName) + '..TempPDA_RtrWiseProductSales T ON R.RtrCode=T.RtrCode AND R.PrdCCode=T.PrdCCode WHERE InvType=''Invoice3'''
EXEC (@UpSQL)

END 
GO
--FOR PRODUCT--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Products' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Products
GO
--Exec Proc_Export_PDA_Products 'jnj','jnjinter','s1'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Products]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @FromDate AS datetime
DECLARE @ToDate AS datetime

BEGIN
--	SELECT @FromDate=dateadd(MM,-6,getdate())
--	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)

--	SELECT DISTINCT prdid,PrdBatId INTO #Tempproduct FROM SalesInvoiceProduct SIP INNER JOIN SalesInvoice SI ON SI.SalId = SIP.SalId
--	WHERE salinvdate BETWEEN @FromDate AND @ToDate

	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Product Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Product(SrpCde,PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdStatus,CmpId,PrdCtgValMainId,Vending,CurStock,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',P.PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdStatus,CmpId,PrdCtgValMainId,Vending,sum(PrdBatLcnSih-PrdBatLcnRessih)QTY,''N'' AS UploadFlag
	 FROM '+ (@FromDBName) +'.dbo.Product P inner join '+ (@FromDBName) +'.dbo.ProductbatchLocation PBL on P.prdid=PBL.prdid where PrdStatus=1 
	   group by P.PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdStatus,CmpId,PrdCtgValMainId,Vending '
	EXEC (@InsSQL)
END
GO
--Product Batch
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_ProductBatch') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_ProductBatch
GO
--Exec Proc_Export_PDA_ProductBatch 'jnj','jnjinter','SM01'
CREATE PROCEDURE Proc_Export_PDA_ProductBatch
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: [Proc_Export_PDA_ProductBatch]
* PURPOSE: To Insert the records From Zoom into Intermediate Database
* SCREEN : PRODUCTBATCH
* CREATED: MURUGAN.R
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @FromDate AS datetime
DECLARE @ToDate AS datetime

BEGIN

CREATE TABLE #Tempproductbatch (Prdid int,prdbatid int)

DECLARE @Prdid AS int
DECLARE Cur_Productbatch CURSOR
FOR SELECT prdid FROM Product WHERE PrdStatus=1
OPEN  Cur_Productbatch 
FETCH next FROM Cur_Productbatch INTO  @Prdid
WHILE @@fetch_status=0
BEGIN
 IF NOT EXISTS(SELECT prdid,prdbatid,sum(PrdBatLcnSih-PrdBatLcnRessih)Qty FROM productbatchlocation 
		       WHERE PrdId=@Prdid AND (PrdBatLcnSih-PrdBatLcnRessih)>0 GROUP BY prdid,PrdBatID)
	BEGIN  
		INSERT INTO #Tempproductbatch	
		SELECT prdid,max(PrdBatId)PrdBatId FROM ProductBatch WHERE PrdId=@Prdid GROUP BY prdid
	END  
 ELSE
    BEGIN 
		INSERT INTO #Tempproductbatch	
		SELECT prdid,min(prdbatid)prdbatid FROM productbatchlocation WHERE prdid=@Prdid 
			AND (PrdBatLcnSih-PrdBatLcnRessih)>0 GROUP BY prdid
    END 
FETCH next FROM Cur_Productbatch INTO  @Prdid
END 
CLOSE Cur_Productbatch
DEALLOCATE Cur_Productbatch

	SET @DELSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.ProductBatch Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DELSQL)
	SET @INSSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.ProductBatch (SrpCde,PrdId,PrdBatId,PriceId,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,MRP,[List Price],[Selling Price],UploadFlag)'
	SET @INSSQL = @INSSQL +  

' SELECT ''' + @SalRpCode + ''', P.PrdId,PB.Prdbatid,DP.PriceId,CmpBatCode,MnfDate,ExpDate,Status,'+
' Pb.TaxGroupId,MRP,'+
' PurchaseRate AS ListPrice,SellingRate,''N'''+
' FROM '+ QuoteName(@FromDBName) + '..Product P INNER JOIN '+ QuoteName(@FromDBName) +'..ProductBatch Pb ON P.PrdId=Pb.Prdid'+
' inner join #Tempproductbatch T on PB.prdid=T.prdid and PB.prdbatid=T.prdbatid'+
' INNER JOIN '+ QuoteName(@FromDBName) + '..DefaultPriceHistory DP ON DP.PrdId=P.prdid '+
' AND DP.PrdId=PB.prdid AND DP.PrdBatId=PB.prdbatid AND DP.PrdId=T.prdid AND DP.PrdBatId=T.prdbatid AND dp.priceid=pb.defaultpriceid'

EXEC (@INSSQL)
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name ='Proc_Import_PDA_OrderBooking'  AND xtype='P')
DROP PROCEDURE [Proc_Import_PDA_OrderBooking]
GO
--Exec Proc_Import_PDA_OrderBooking 'jnj','jnjinter','s1'
CREATE PROCEDURE [Proc_Import_PDA_OrderBooking]      
(      
	@FromDBName varchar(50),      
	@ToDBName varchar(50),      
	@SalRpCode varchar(50)      
)      
AS      
      
/*********************************/      
DECLARE @SQL AS nvarchar(3000)      
DECLARE @OPSQL AS nvarchar(3000)      
DECLARE @DelSQL AS varchar(1000)      
DECLARE @InsSQL AS varchar(5000)      
DECLARE @UpdSQL AS varchar(1000)      
DECLARE @UpdFlgSQL AS varchar(1000)      
DECLARE @OrdKeyNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT      
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @RtrShipId AS INT
DECLARE @OrdPrdCnt AS INT
DECLARE @PdaOrdPrdCnt AS INT
DECLARE @OrderDate AS DateTime
Declare @Psql as varchar(max)
      
BEGIN
	BEGIN TRANSACTION T1
	IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_OrderBooking]') AND type in (N'U'))
	BEGIN
		DROP TABLE PDA_Temp_OrderBooking
	END

	Set @SQL = ' SELECT SrpCde,OrdKeyNo,OrdDt,RtrCde,Mktid,SrpId,R.Rtrid,UploadFlag INTO PDA_Temp_OrderBooking '
	SET  @SQL = @SQL+ 'FROM '+ QuoteName(@ToDBName) + '.dbo.OrderBooking OB INNER JOIN Retailer R on OB.RtrCde COLLATE Latin1_General_CI_AS=R.RtrCode '
	SET  @SQL = @SQL+' WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''''

	EXEC(@SQL)

	SET @SrpId = (SELECT SMId FROM SalesMan Where SMCode = @SalRpCode)
	DECLARE CUR_Import Cursor For
	Select DISTINCT OrdKeyNo  From PDA_Temp_OrderBooking
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo
	While @@Fetch_Status = 0
	BEGIN
		SET @OrdPrdCnt=0
		SET @PdaOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0
		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking WHERE DocRefNo = @OrdKeyNo)
		BEGIN
			SET @RtrId = (Select RtrId FROM PDA_Temp_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@RtrId,'Retailer Does Not Exists for the Order ' + @OrdKeyNo--FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			SELECT @RtrShipId=RS.RtrShipId   
			FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid WHERE RtrShipDefaultAdd=1  
			AND R.RtrId=@RtrId  

			SET @MktId = (Select MktId FROM PDA_Temp_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			IF NOT EXISTS (SELECT * FROM SalesManMarket WHERE RMID = @MktId AND SMID = @SrpId)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Not Maped with the DBSR for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			IF EXISTS (SELECT NAME FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_OrderProduct]') AND type in (N'U'))
			BEGIN
				DROP TABLE PDA_Temp_OrderProduct
			END
			Set @OPSQL = 'SELECT * INTO PDA_Temp_OrderProduct FROM '+ QuoteName(@ToDBName) + '.dbo.OrderProduct WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
			EXEC(@OPSQL)

			IF NOT EXISTS(SELECT OrdKeyNo FROM  PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Product Details Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END
			IF @lError=0
			BEGIN
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @OrdQty AS INT
				DECLARE CUR_ImportOrderProduct CURSOR FOR
				SELECT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  From PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo GROUP BY PrdId,PrdBatId,PriceId
				OPEN CUR_ImportOrderProduct
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
						IF NOT EXISTS(SELECT PrdId From Product WHERE Prdid=@Prdid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdid,' Product Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdbatid,' Product Batch Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@PriceId,' Product Batch Price Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF @OrdQty<=0
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdQty,' Ordered Qty Should be Greater than Zero for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END

						

				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				END
				CLOSE CUR_ImportOrderProduct
				DEALLOCATE CUR_ImportOrderProduct

				SET @GetKeyStr=''  
				SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('OrderBooking','OrderNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
				IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
				BEGIN  
					SET @lError = 1
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Ordered Key No not generated' --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
					BREAK  
				END

			IF @lError = 0
			BEGIN
				--HEDER 
					SELECT  @OrderDate= OrdDt FROM PDA_Temp_OrderBooking WHERE  OrdKeyNo=@OrdKeyNo
					INSERT INTO OrderBooking(  
					OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,RtrId,OrdType,  
					Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,RndOffValue,TotalAmount,Status,  
					Availability,LastModBy,LastModDate,AuthId,AuthDate,PDADownLoadFlag)  
					SELECT @GetKeyStr,Convert(DateTime,@OrderDate,121),  
					Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					0,@OrdKeyNo,0, @SrpId as Smid,  
					@MktId as RmId,@RtrId as RtrId,0 as OrdType,0 as Priority,0 as FillAllPrd,0 as ShipTo,  
					@RtrShipId as RtrShipId,'' as Remarks,0  as RoundOff,0 as RndOffValue,  
					0 as TotalAmount,0 as Status,1,1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),1  

				   --DETAILS  
set @Psql='INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,  
					  ConvFact2,TotalQty,BilledQty,Rate,MRP,GrossAmount,PriceId,  
					  Availability,LastModBy,LastModDate,AuthId,AuthDate)  
			SELECT '''+ @GetKeyStr +''',Prdid,Prdbatid,UomID,OrdQty,ConversionFactor,0,0,0,OrdQty,0,
			SUM(Rate)Rate ,SUM(MRP)MRP,sum(GrossAmount)GrossAmount,sum(PriceId)PriceId,
			1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
			1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121) 
			FROM ( 
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			PBD.PrdBatDetailValue Rate,0 as Mrp,(PBD.PrdBatDetailValue*OrdQty) as GrossAmount,PBD.PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  FROM PDA_Temp_OrderProduct WHERE OrdKeyNo='''+ @OrdKeyNo +'''
			 GROUP BY PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId  
			and BC.slno=PBD.SLNo AND BC.SelRte=1  --and PBD.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom=''Y''
		UNION ALL
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			0 Rate,PBD1.PrdBatDetailValue as Mrp,0 as GrossAmount,0 as PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  FROM PDA_Temp_OrderProduct WHERE OrdKeyNo='''+ @OrdKeyNo + '''
			 GROUP BY PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC1 (NOLOCK) ON BC1.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD1.PriceId  
			and BC1.slno=PBD1.SLNo AND BC1.MRP=1  --and PBD1.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom=''Y'')A
			GROUP BY Prdid,Prdbatid,UomID,OrdQty,ConversionFactor'

exec (@Psql)
				  UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB   
				  INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X   
				  ON X.OrderNo=OB.OrderNo   

				SELECT SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId,--@GetKeyStr as CSOrderNo,
				SUM(OrdQty) as Qty  
				INTO #TEMPCHECK   
				FROM PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo
				GROUP BY  
				SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId
        
					
				
				SELECT @OrdPrdCnt=ISNULL(Count(OrderNo),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
				SELECT @PdaOrdPrdCnt=ISNULL(Count(OrdKeyNo),0) FROM #TEMPCHECK (NOLOCK) WHERE OrdKeyNo=@OrdKeyNo
						IF @OrdPrdCnt=@PdaOrdPrdCnt  
						BEGIN 
							UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
				
							SET @UpdFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.OrderBooking SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
							EXEC(@UpdFlgSQL)

							SET @UpdOPFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.OrderProduct SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
							EXEC(@UpdOPFlgSQL)
						END
						ELSE
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Ordered Product Number of line count not match for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
							DELETE FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr  
							DELETE FROM ORDERBOOKING WHERE OrderNo=@GetKeyStr  
						END 
	
				
				DROP TABLE #TEMPCHECK
				END
			END
		END
		ELSE
		BEGIN
			Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'ORDERBOOKING'
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,'Order Already exists' --FROM TempOrderBooking WHERE OrdKeyNo=@OrdKeyNo
		END
		
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo
	END
	Close CUR_Import
	DeAllocate CUR_Import

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION T1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION T1
	END
END

GO
--SalesReturn
IF EXISTS (SELECT * FROM sysobjects WHERE name ='Proc_Import_PDA_SalesReturn'  AND xtype='P')
DROP PROCEDURE [Proc_Import_PDA_SalesReturn]
GO
--Exec Proc_Import_PDA_SalesReturn 'jnj','jnjinter','s1'
CREATE  PROCEDURE [Proc_Import_PDA_SalesReturn]      
(      
 @FromDBName varchar(50),      
 @ToDBName varchar(50),      
 @SalRpCode varchar(50)      
)      
AS      
DECLARE @SQL AS nvarchar(3000)      
DECLARE @OPSQL AS nvarchar(3000)      
DECLARE @DelSQL AS varchar(1000)      
DECLARE @InsSQL AS varchar(5000)      
DECLARE @UpdSQL AS varchar(1000)      
DECLARE @UpdFlgSQL AS varchar(1000)      
DECLARE @SrNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT    
DECLARE @SalInvNo AS nVarchar(50)
DECLARE @Salid AS INT  
      
BEGIN      
 BEGIN TRANSACTION T1      
 IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_SalesReturn]') AND type in (N'U'))      
 BEGIN      
  DROP TABLE PDA_Temp_SalesReturn      
 END   

 IF  EXISTS(SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)
 BEGIN
      
		 Set @SQL = 'SELECT SrpCde,SrNo,SrDate,SalInvNo,RtrCde,Mktid,Srpid,ReturnMode,InvoiceType,R.RtrId,UploadFlag '  
		 Set @SQL =@SQL+ ' INTO PDA_Temp_SalesReturn FROM '+ QuoteName(@ToDBName) + '.dbo.SalesReturn SR INNER JOIN Retailer R ON R.RtrCode COLLATE Latin1_General_CI_AS=SR.RtrCde '  
		 Set @SQL =@SQL+ ' WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''''   
		 EXEC(@SQL)      
		--SELECT * From PDA_Temp_SalesReturnProduct      
		 SET @SrpId = (SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)      
				
		 DECLARE CUR_Import Cursor For      
		 Select Distinct SrNo From PDA_Temp_SalesReturn          
		 OPEN CUR_Import      
		 FETCH NEXT FROM CUR_Import INTO @SrNo      
		 While @@Fetch_Status = 0      
		 BEGIN      
		  SET @lError = 0
		  SET @SalInvNo	=''
		  SET @RtrId=0
		  SET @MktId=0
		  SET @SalId=0			
		  IF NOT EXISTS (SELECT DocRefNo FROM ReturnHeader WHERE DocRefNo = @SrNo)      
		  BEGIN      
			   SET @RtrId = (Select RtrId FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo)       
			   IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE Rtrid = @RtrId and RtrStatus = 1)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@RtrId,'Retailer Does Not Exists for the SalesReturn No ' + @SrNo 
			   END      
		      
			   SET @MktId = (Select MktId FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo)       
			   IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Does Not Exists for the SalesReturn No ' + @SrNo 
			   END      
		      
			   IF NOT EXISTS (SELECT RMId,SMId FROM SalesManMarket WHERE RMId = @MktId AND SMId = @SrpId)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Not Maped with the DBSR for the SalesReturn No ' + @SrNo  
			   END

			   IF NOT EXISTS (SELECT RMId,RtrId FROM RetailerMarket WHERE RMId = @MktId AND RtrId = @RtrId)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Not Maped with the Retailer for the SalesReturn No ' + @SrNo  
			   END

				IF EXISTS(SELECT SalInvNo FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo and InvoiceType=1)
				BEGIN
					SELECT @SalInvNo=ISNULL(SalInvNo,'') FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo and InvoiceType=1
					IF LEN(@SalInvNo)=0 
					BEGIN
						SET @lError = 1      
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
						SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Reference Invoice not exist for the SalesReturn No' + @SrNo 
					END
					ELSE IF NOT EXISTS(SELECT SalId From SalesInvoice WHERE Salinvno=@SalInvNo)
					BEGIN
						SET @lError = 1      
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
						SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Reference  SalesInvoice not exist for the SalesReturn No' + @SrNo 
					END
				END

				IF EXISTS (SELECT NAME FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_SalesReturnProduct]') AND type in (N'U'))
				BEGIN
					DROP TABLE PDA_Temp_SalesReturnProduct
				END
				Set @OPSQL = 'SELECT * INTO PDA_Temp_SalesReturnProduct FROM '+ QuoteName(@ToDBName) + '.dbo.SalesReturnProduct WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''' AND SrNo = ''' + @SrNo + ''''
				EXEC(@OPSQL)

				IF NOT EXISTS(SELECT SrNo FROM  PDA_Temp_SalesReturnProduct WHERE SrNo=@SrNo)
				BEGIN
					SET @lError = 1
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Product Details Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
				END


			IF @lError=0
			BEGIN
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @RtnQty AS INT
				DECLARE @StockType AS INT
				DECLARE @SalinvnoRef AS nVarchar(50)
				DECLARE @UsrStkTyp AS INT
				DECLARE @Slno AS INT
				DECLARE CUR_ImportReturnProduct CURSOR FOR
				SELECT PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,SlNo From PDA_Temp_SalesReturnProduct WHERE SrNo=@SrNo  ORDER BY SlNo 
				OPEN CUR_ImportReturnProduct
				FETCH NEXT FROM CUR_ImportReturnProduct INTO @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
						IF NOT EXISTS(SELECT PrdId From Product (NOLOCK) WHERE Prdid=@Prdid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdid,' Product Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdbatid,' Product Batch Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@PriceId,' Product Batch Price Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF @RtnQty<=0
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Return Qty Should be Greater than Zero for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END

						

				FETCH NEXT FROM CUR_ImportReturnProduct INTO  @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno
				END
				CLOSE CUR_ImportReturnProduct
				DEALLOCATE CUR_ImportReturnProduct
		 

					IF @lError = 0       
					BEGIN
						--HEADER	   
						INSERT INTO PDA_SalesReturn (SrNo,SrDate,SalInvNo,RtrId,Mktid,Srpid,ReturnMode,InvoiceType,Status)
						SELECT SrNo,Getdate(),SalInvNo,RtrId,Mktid,@SrpId,ReturnMode,InvoiceType,0
						FROM PDA_Temp_SalesReturn WHERE SrNo=@SrNo
						--DETAILS
						INSERT INTO PDA_SalesReturnProduct(SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo)
						SELECT @SrNo,PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,SlNo From PDA_Temp_SalesReturnProduct  
						WHERE SrNo=@SrNo


						SET @UpdFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.SalesReturn SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND SrNo = ''' + @SrNo + ''''      
						EXEC(@UpdFlgSQL)      

						SET @UpdOPFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.SalesReturnProduct SET [UploadFlag] = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and [UploadFlag] = ''N'' AND SrNo = ''' + @SrNo + ''''      
						EXEC(@UpdOPFlgSQL)      


					END 
			END      
		  END      
		  ELSE      
		  BEGIN      
			   Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'SALESRETURN'      
			   INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			   SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Sales Return Already exists'      
		  END       
		FETCH NEXT FROM CUR_Import INTO @SrNo      
		END      
		CLOSE CUR_Import      
		DEALLOCATE CUR_Import     
END
ELSE
BEGIN
		 INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
		 SELECT '' + @SalRpCode + '','SALESRETURN',@SalRpCode,'SalesMan Does not exists ' 
END 
      
 IF @@ERROR = 0      
 BEGIN      
  COMMIT TRANSACTION T1      
 END      
 ELSE      
 BEGIN      
  ROLLBACK TRANSACTION T1      
 END      
END
GO
DELETE FROM tbl_downloadintegration WHERE SequenceNo=34
INSERT INTO tbl_downloadintegration
VALUES(34,'Data Health Check','CN2CS_Prk_DHCSettings','Proc_Import_DHCDetails',0,500,getdate())

DELETE FROM tbl_uploadintegration WHERE SequenceNo=30
INSERT INTO tbl_uploadintegration
VALUES(30,'Data Health Check','Data Health Check','CS2CN_Prk_DHCDetails',getdate())

DELETE FROM CustomUpdownload WHERE Slno=132
INSERT INTO CustomUpdownload
SELECT 132,1,'Data Health Check','Data Health Check','Proc_CS2CNDHCDetails','Proc_Import_DHCDetails','CS2CN_Prk_DHCDetails','Proc_CS2CN_DHCPeriod','MASTER','Upload',1

DELETE FROM CustomUpdownload WHERE Slno=229
INSERT INTO CustomUpdownload
SELECT 229,1,'Data Health Check','Data Health Check','Proc_CS2CNDHCDetails','Proc_Import_DHCDetails','CN2CS_Prk_DHCSettings','Proc_CS2CN_DHCPeriod','MASTER','Download',1
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].CN2CS_Prk_DHCSettings') AND type in (N'U'))
DROP TABLE [dbo].[CN2CS_Prk_DHCSettings]
GO
CREATE TABLE [dbo].CN2CS_Prk_DHCSettings
(

	[DistCode]		[nvarchar](200) ,
	[DHCNo]			[nvarchar](200) ,
	[DHCDesc]		[nvarchar](1000) ,
	[FromDate]		[datetime] ,
	[ToDate]		[datetime] ,
	[DownloadFlag]	[nvarchar](10) 
)
GO 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].CS2CN_Prk_DHCDetails') AND type in (N'U'))
DROP TABLE [dbo].CS2CN_Prk_DHCDetails
GO
CREATE TABLE [dbo].[CS2CN_Prk_DHCDetails]
(
	 [Slno]			NUMERIC(18,0) NOT NULL IDENTITY(1,1),
	 [Distcode]		[nvarchar](200) ,
	 [DHCNo]		[nvarchar](200) ,
	 [Process]		[nvarchar](200) ,
	 [Attribute1]	[nvarchar](200) ,
	 [Attribute2]	[nvarchar](200) ,
	 [Attribute3]	[nvarchar](200) ,
	 [Attribute4]	[nvarchar](200) ,
	 [Attribute5]	[nvarchar](200) ,
	 [Attribute6]	[nvarchar](200) ,
	 [Attribute7]	[nvarchar](200) ,
	 [Attribute8]	[nvarchar](200) ,
	 [Attribute9]	[nvarchar](200) ,
	 [Attribute10]	[nvarchar](200) ,
	 [UploadFlag]	[nvarchar](10) 
) 
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].HealthCheckMaster') AND type in (N'U'))
DROP TABLE [dbo].HealthCheckMaster
GO
CREATE TABLE [dbo].HealthCheckMaster
(
	[DHCNo]			[nvarchar](200) ,
	[DHCDesc]		[nvarchar](1000) ,
	[FromDate]		[datetime] ,
	[ToDate]		[datetime] ,
	[DownloadDate]	[datetime] ,
	Upload			INT 
)
GO 
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_Import_DHCDetails')
DROP PROCEDURE  Proc_Import_DHCDetails
GO  
--Exec Proc_ImportBulletingBoard '<Data></Data>'
CREATE        Procedure [dbo].[Proc_Import_DHCDetails]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_DHCDetails
* PURPOSE		: To Insert records from xml file in the Table CN2CS_Prk_DHCSettings
* CREATED		: Boopathy.P
* CREATED DATE	: 2011-10-27
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER

	DELETE FROM CN2CS_Prk_DHCSettings WHERE DownloadFlag='Y'
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO CN2CS_Prk_DHCSettings
	SELECT Distcode,DHCNo,DHCDesc,FromDate,ToDate,'D' FROM OPENXML (@hdoc,'/Root/Console2CS_DHCSettings',1)
	WITH 
	(
		Distcode 	NVARCHAR(100) ,
		DHCNo		NVARCHAR(200) ,
		DHCDesc		NVARCHAR(1000) ,
		FromDate	DATETIME,
		ToDate      DATETIME
	) XMLObj	
	EXEC sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_CS2CNDHCDetails')
DROP PROCEDURE  Proc_CS2CNDHCDetails
GO  
CREATE    PROCEDURE [dbo].[Proc_CS2CNDHCDetails]  
(  
	@Po_ErrNo INT OUTPUT  
)  
AS  
SET NOCOUNT ON  
BEGIN  
/*********************************  
* PROCEDURE: Proc_CS2CNBidcoSchemeUtilization  
* PURPOSE: Extract Scheme Utilization Details from CoreStocky to Console  
* NOTES:  
* CREATED: Thrinath Kola 16-12-2007  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
	DECLARE @DistCode	As	nVarchar(50)
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @DHCNo		AS  NVARCHAR(200)

	SELECT @DistCode = DistributorCode FROM Distributor
	SET @Po_ErrNo=0

	IF NOT EXISTS (SELECT * FROM HealthCheckMaster WHERE Upload=0) 
	BEGIN
		RETURN
	END

	SELECT @FromDate=CONVERT(VARCHAR(10),FromDate,121),@DHCNo=DHCNo,
		   @ToDate=CONVERT(VARCHAR(10),ToDate,121) FROM HealthCheckMaster WHERE Upload=0


	INSERT INTO CS2CN_Prk_DHCDetails(Distcode,DHCNo,Process,Attribute1,Attribute2,Attribute3,UploadFlag)
	SELECT @DistCode,@DHCNo,'Product Master' AS ProcessName,ISNULL(SUM(PrdCnt),0) AS PrdCnt,SUM(ISNULL(ActPrd,0)) AS ActPrd,
	SUM(ISNULL(InActPrd,0)) AS InActPrd,'N' FROM
	(	
		SELECT COUNT(PrdId) AS PrdCnt,
			CASE PrdStatus WHEN 1 THEN COUNT(PrdId) END AS ActPrd,
			CASE PrdStatus WHEN 2 THEN COUNT(PrdId) END AS InActPrd
		FROM Product GROUP BY PrdStatus
	)S

	INSERT INTO CS2CN_Prk_DHCDetails(Distcode,DHCNo,Process,Attribute1,Attribute2,Attribute3,UploadFlag)
	SELECT @DistCode,@DHCNo,'Retailer Count' AS ProcessName,ISNULL(SUM(RtrCnt),0) AS RtrCnt,SUM(ISNULL(ActRtr,0)) AS ActRtr,
	SUM(ISNULL(InActRtr,0)) AS InActRtr,'N' FROM
	(	
		SELECT COUNT(RtrId) AS RtrCnt,
			CASE RtrStatus WHEN 1 THEN COUNT(RtrId) END AS ActRtr,
			CASE RtrStatus WHEN 0 THEN COUNT(RtrId) END AS InActRtr
		FROM Retailer GROUP BY RtrStatus
	)S 

	INSERT INTO CS2CN_Prk_DHCDetails(Distcode,DHCNo,Process,Attribute1,Attribute2,Attribute3,UploadFlag)
	SELECT @DistCode,@DHCNo,'Salesman Master' AS ProcessName,ISNULL(SUM(SmCnt),0) AS SmCnt,SUM(ISNULL(ActSal,0)) AS ActSal,
	SUM(ISNULL(InActSal,0)) AS InActSal,'N' FROM
	(	
		SELECT COUNT(SmId) As SmCnt,
			CASE Status WHEN 1 THEN COUNT(SMId) END AS ActSal,
			CASE Status WHEN 0 THEN COUNT(SMId) END AS InActSal
		FROM Salesman GROUP BY Status
	)S 

	INSERT INTO CS2CN_Prk_DHCDetails(Distcode,DHCNo,Process,Attribute1,Attribute2,Attribute3,UploadFlag)
	SELECT @DistCode,@DHCNo,'Route Master' AS ProcessName,ISNULL(SUM(RMCnt),0) AS RMCnt,SUM(ISNULL(ActRoute,0)) AS ActRoute,
	SUM(ISNULL(InActRoute,0)) AS InActRoute,'N' FROM
	(	
		SELECT COUNT(RMId) AS RMCnt,
			CASE RMstatus WHEN 1 THEN COUNT(RMId) END AS ActRoute,
			CASE RMstatus WHEN 0 THEN COUNT(RMId) END AS InActRoute
		FROM RouteMaster GROUP BY RMstatus
	)S 

	INSERT INTO CS2CN_Prk_DHCDetails(Distcode,DHCNo,Process,Attribute1,Attribute2,Attribute3,Attribute4,UploadFlag)
	SELECT @DistCode,@DHCNo,'Sales details',ISNULL(COUNT(SalId),0), 
	(
		SELECT ISNULL(COUNT(SIP.PrdId),0) AS SalInvLineCount   
		FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId 
		WHERE SI.DlvSts >3 AND SalInvDate BETWEEN @FromDate AND @ToDate
	),ISNULL(SUM(SalGrossAmount),0) AS SalGrossAmount,ISNULL(SUM(SalTaxAmount),0),'N'
	FROM SalesInvoice WHERE DlvSts>3 AND SalInvDate BETWEEN @FromDate AND @ToDate
	
	INSERT INTO CS2CN_Prk_DHCDetails(Distcode,DHCNo,Process,Attribute1,Attribute2,Attribute3,Attribute4,UploadFlag)
	SELECT @DistCode,@DHCNo,'Purchase Confirmation',ISNULL(COUNT(PurRcptId),0),ISNULL(SUM(TaxAmount),0) AS TaxAmount,ISNULL(SUM(GrossAmount),0) AS GrossAmount,ISNULL(SUM(NetAmount),0) AS NetAmount,'N'
	FROM PurchaseReceipt WHERE Status=1 AND GoodsRcvdDate BETWEEN @FromDate AND @ToDate

	INSERT INTO CS2CN_Prk_DHCDetails(Distcode,DHCNo,Process,Attribute1,Attribute2,Attribute3,Attribute4,UploadFlag)
	SELECT @DistCode,@DHCNo,'Sales return',ISNULL(COUNT(ReturnId),0), 
	(
		SELECT ISNULL(COUNT(RP.PrdId),0) AS SalInvLineCount   
		FROM ReturnHeader RH INNER JOIN ReturnProduct RP ON RH.ReturnId=RP.ReturnId 
		WHERE RH.Status=0 AND RH.ReturnDate BETWEEN @FromDate AND @ToDate
	),ISNULL(SUM(RtnGrossAmt),0) AS RtnGrossAmt,ISNULL(SUM(RtnTaxAmt),0),'N'
	FROM ReturnHeader WHERE Status=0  AND ReturnDate BETWEEN @FromDate AND @ToDate

	INSERT INTO CS2CN_Prk_DHCDetails(Distcode,DHCNo,Process,Attribute1,Attribute2,Attribute3,UploadFlag)
	 SELECT @DistCode,@DHCNo,'Scheme Utilization',cast(ISNULL(SUM(Utilized),0) AS numeric(18,6)) AS Utilized,
	 ISNULL(COUNT(SchCode),0) AS NoofLines,ISNULL(SUM(SchemeUtilizedQty),0) AS SchemeUtilizedQty,'N' FROM
	 (
		SELECT
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.SalInvDate ,B.SalInvNo, 
			CASE SM.SchType WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END AS SchType,
			(ISNULL(SUM(FlatAmount),0) + ISNULL(SUM(DiscountPerAmount),0)) As Utilized,
			'' as SchemeFreeProduct ,0 as SchemeUtilizedQty ,SM.CmpSchCode
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON 
			A.SalId = B.SalId INNER JOIN SchemeMaster SM ON 
			A.Schid = SM.SchId INNER JOIN Company CM ON
			SM.CmpId = CM.CmpId
			WHERE DlvSts > 3  AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.SalInvDate BETWEEN @FromDate AND @ToDate 
		GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.SalInvDate ,SM.SchType,SM.CmpSchCode,B.SalInvNo
	UNION ALL
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.SalInvDate ,B.SalInvNo, 
			CASE SM.SchType WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END  AS SchType,
			ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0) As Utilized ,
			P.PrdCCode as SchemeFreeProduct,SUM(FreeQty) as SchemeUtilizedQty ,SM.CmpSchCode
			FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
			INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
			A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
			C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
				ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
			INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId INNER JOIN Company CM ON
			SM.CmpId = CM.CmpId INNER JOIN Product P ON A.FreePrdId = P.PrdId
			WHERE DlvSts in (4,5) AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.SalInvDate BETWEEN @FromDate AND @ToDate 
		GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.SalInvDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,B.SalInvNo
	UNION ALL	
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.SalInvDate ,B.SalInvNo,  
			CASE SM.SchType 	WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END  AS SchType,
			ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0) As Utilized ,
			P.PrdCCode as SchemeFreeProduct,SUM(GiftQty) as SchemeUtilizedQty ,SM.CmpSchCode
			FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
			INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
			A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
			C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
				ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
			INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId INNER JOIN Company CM ON
			SM.CmpId = CM.CmpId INNER JOIN Product P ON A.GiftPrdId = P.PrdId
			WHERE DlvSts in (4,5) AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.SalInvDate BETWEEN @FromDate AND @ToDate 
		GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.SalInvDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,B.SalInvNo
	UNION ALL	
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.SalInvDate ,B.SalInvNo,  
			CASE SM.SchType WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END  AS SchType,
			ISNULL(SUM(AdjAmt),0) As Utilized,
			'' as SchemeFreeProduct ,0 as SchemeUtilizedQty ,SM.CmpSchCode
			FROM SalesInvoiceWindowDisplay A 
			INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId INNER JOIN Company CM ON
			SM.CmpId = CM.CmpId
			WHERE DlvSts in (4,5) AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.SalInvDate BETWEEN @FromDate AND @ToDate 
		GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.SalInvDate ,SM.SchType,SM.CmpSchCode,B.SalInvNo

	UNION ALL
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.SalInvDate ,B.SalInvNo,  
			CASE SM.SchType WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END  AS SchType,  
			ISNULL(SUM(A.CrNoteAmount),0) As Utilized ,  
			'' AS SchemeFreeProduct, 0 AS SchemeUtilizedQty ,SM.CmpSchCode
		  FROM SalesInvoiceQPSSchemeAdj A   
		  INNER JOIN SalesInvoice B ON A.SalId = B.SalId AND Mode=1  
		  INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId   
		  INNER JOIN Company CM ON SM.CmpId = CM.CmpId   
		  INNER JOIN Retailer R ON R.RtrId = B.RtrId  
		  WHERE DlvSts in (4,5) AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.SalInvDate BETWEEN @FromDate AND @ToDate 
		  GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.SalInvDate ,SM.SchType,SM.CmpSchCode,B.SalInvNo

	UNION ALL
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.SalInvDate ,B.SalInvNo,  
			CASE SM.SchType WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END  AS SchType,  
			ISNULL(SUM(A.CrNoteAmount),0) As Utilized ,  
			'' AS SchemeFreeProduct, 0 AS SchemeUtilizedQty ,SM.CmpSchCode
		  FROM SalesInvoiceQPSSchemeAdj A   
		  INNER JOIN SalesInvoice B ON A.SalId = B.SalId AND Mode=2  
		  INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId   
		  INNER JOIN Company CM ON SM.CmpId = CM.CmpId   
		  INNER JOIN Retailer R ON R.RtrId = B.RtrId  
		  WHERE DlvSts in (4,5) AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.SalInvDate BETWEEN @FromDate AND @ToDate 
		  GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.SalInvDate ,SM.SchType,SM.CmpSchCode,B.SalInvNo
	UNION ALL	
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,A.ChqDisDate ,A.ChqDisRefNo,  
			CASE SM.SchType WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END  AS SchType,
			ISNULL(SUM(Amount),0) As Utilized ,'' as SchemeFreeProduct ,0 as SchemeUtilizedQty ,SM.CmpSchCode
		FROM ChequeDisbursalMaster A 
			INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo 
			INNER JOIN SchemeMaster SM ON A.TransId = SM.SchId INNER JOIN Company CM ON
			SM.CmpId = CM.CmpId
		WHERE TransType = 1 AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND A.ChqDisDate BETWEEN @FromDate AND @ToDate 
		GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,A.ChqDisDate ,SM.SchType,SM.CmpSchCode,A.ChqDisRefNo
	UNION ALL
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.ReturnDate ,B.ReturnCode,  
			CASE SM.SchType 	WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END AS SchType,
			-1 * (ISNULL(SUM(ReturnFlatAmount),0) + ISNULL(SUM(ReturnDiscountPerAmount),0)),
			'' as SchemeFreeProduct ,0 as SchemeUtilizedQty ,SM.CmpSchCode 
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN SchemeMaster SM ON 
			A.Schid = SM.SchId INNER JOIN Company CM ON
			SM.CmpId = CM.CmpId
			WHERE Status = 0 AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.ReturnDate BETWEEN @FromDate AND @ToDate 
		GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.ReturnDate ,SM.SchType,SM.CmpSchCode,B.ReturnCode
	UNION ALL	
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.ReturnDate ,B.ReturnCode, 
			CASE SM.SchType 	WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END  AS SchType,
			-1 * ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0),
			P.PrdCCode as SchemeFreeProduct ,-1 * SUM(ReturnFreeQty) as SchemeUtilizedQty ,SM.CmpSchCode 	
			FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
			A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
			C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
				ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
			INNER JOIN SchemeMaster SM ON 
			A.Schid = SM.SchId INNER JOIN Company CM ON
			SM.CmpId = CM.CmpId INNER JOIN Product P ON A.FreePrdId = P.PrdId
			WHERE B.Status = 0 AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.ReturnDate BETWEEN @FromDate AND @ToDate 
		GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.ReturnDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,B.ReturnCode
	UNION ALL	
		SELECT 
			SM.SchCode ,SM.SchDsc ,	CM.CmpCode ,B.ReturnDate ,B.ReturnCode,  
			CASE SM.SchType 	WHEN 1 THEN 'Quantity Based' 
					WHEN 2 THEN 'Amount Based'
					WHEN 3 THEN 'Weight Based'
					WHEN 4 THEN 'Display' END  AS SchType,
			ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0),
			P.PrdCCode as SchemeFreeProduct ,
			-1 * SUM(ReturnGiftQty) as SchemeUtilizedQty ,SM.CmpSchCode 	
			FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
			A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
			C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
				ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
			INNER JOIN SchemeMaster SM ON 
			A.Schid = SM.SchId INNER JOIN Company CM ON
			SM.CmpId = CM.CmpId INNER JOIN Product P ON A.GiftPrdId = P.PrdId
			WHERE B.Status = 0 AND CM.CmpID = (SELECT CmpId FROM Company WHERE DefaultCompany = 1) AND B.ReturnDate BETWEEN @FromDate AND @ToDate 
		GROUP BY SM.SchCode ,SM.SchDsc ,CM.CmpCode ,B.ReturnDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,B.ReturnCode
	) A

	UPDATE A SET A.Upload=1 FROM HealthCheckMaster A INNER JOIN CS2CN_Prk_DHCDetails B ON A.DHCNo=B.DHCNo
	WHERE B.UploadFlag='N'
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_CS2CN_DHCPeriod')
DROP PROCEDURE  Proc_CS2CN_DHCPeriod
GO 
CREATE PROCEDURE [dbo].Proc_CS2CN_DHCPeriod
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE: Proc_Cn2Cs_BarCode
* PURPOSE: To Insert and Update records Of Barcode
* CREATED: Boopathy.P on 20/09/2010
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @ErrDesc	AS VARCHAR(1000)
	DECLARE @TabName	AS VARCHAR(200)
	DECLARE @GetKey		AS INT
	DECLARE @Taction	AS INT
	DECLARE @sSQL		AS VARCHAR(4000)
	DECLARE @FromDate	AS VARCHAR(10)
	DECLARE @ToDate		AS VARCHAR(10)
	DECLARE @HcCode		AS VARCHAR(200)
	DECLARE @HcDesc		AS VARCHAR(1000)

	SET @TabName = 'CN2CS_Prk_DHCSettings'
	SET @Po_ErrNo =0


	DECLARE Cur_HealthChk CURSOR
	FOR SELECT DHCNo,DHCDesc,CONVERT(VARCHAR(10),FromDate,121),CONVERT(VARCHAR(10),ToDate,121) 
		FROM CN2CS_Prk_DHCSettings WHERE DownloadFlag='D' AND DHCNo NOT IN (SELECT DHCNo FROM HealthCheckMaster)			
	OPEN Cur_HealthChk
	FETCH NEXT FROM Cur_HealthChk INTO @HcCode,@HcDesc,@FromDate,@ToDate
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		
		IF LTRIM(RTRIM(@HcCode))= ''
		BEGIN
			SET @ErrDesc = 'Health Check Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Health Check Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@HcDesc))= ''
		BEGIN
			SET @ErrDesc = 'Health Check Desc should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Health Check Desc',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FromDate))= ''
		BEGIN
			SET @ErrDesc = 'Health Check From Date should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Health Check From Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ToDate))= ''
		BEGIN
			SET @ErrDesc = 'Health Check To Date should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Health Check To Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@FromDate)))= 0 OR ISDATE(LTRIM(RTRIM(@ToDate))) =0
		BEGIN
			SET @ErrDesc = 'Invalid Health Check Date Formate :' + LTRIM(RTRIM(@HcCode))
			INSERT INTO Errorlog VALUES (1,@TabName,'Invalid Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END

		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS (SELECT * FROM HealthCheckMaster WHERE DHCNo=LTRIM(RTRIM(@HcCode)))
			BEGIN
				SET @ErrDesc = 'Health Check Code already exists:' + LTRIM(RTRIM(@HcCode))
				INSERT INTO Errorlog VALUES (1,@TabName,'Health Check Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1			
			END
			ELSE
			BEGIN
				INSERT INTO HealthCheckMaster
				SELECT LTRIM(RTRIM(@HcCode)),LTRIM(RTRIM(@HcDesc)),@FromDate,@ToDate,CONVERT(VARCHAR(10),GETDATE(),121),0
	
				UPDATE CN2CS_Prk_DHCSettings SET DownloadFlag='Y' WHERE DownloadFlag='D' AND DHCNo=LTRIM(RTRIM(@HcCode))
			END
		END
		FETCH NEXT FROM Cur_HealthChk INTO @HcCode,@HcDesc,@FromDate,@ToDate
	END
	CLOSE Cur_HealthChk
	DEALLOCATE Cur_HealthChk
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='Cs2Cn_Prk_SchemeUtilization_Archive')
DROP TABLE Cs2Cn_Prk_SchemeUtilization_Archive
GO
CREATE TABLE [Cs2Cn_Prk_SchemeUtilization_Archive]
(
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [nvarchar](50) NOT NULL,
	[SchemeCode] [nvarchar](50) NOT NULL,
	[SchemeDescription] [nvarchar](200) NOT NULL,
	[InvoiceNo] [nvarchar](50) NOT NULL,
	[RtrCode] [nvarchar](50) NOT NULL,
	[Company] [nvarchar](100) NOT NULL,
	[SchDate] [datetime] NULL,
	[SchemeType] [nvarchar](50) NOT NULL,
	[SchemeUtilizedAmt] [numeric](18, 2) NULL,
	[SchemeFreeProduct] [nvarchar](50) NOT NULL,
	[SchemeUtilizedQty] [int] NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[CompanySchemeCode] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[SchemeMode] nvarchar (50),
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]

if not exists (Select Id,name from Syscolumns where name = 'SchemeMode' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_SchemeUtilization'))
begin
	ALTER TABLE [dbo].[Cs2Cn_Prk_SchemeUtilization]
	ADD [SchemeMode] nvarchar (50)
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_Cs2Cn_SchemeUtilization')
DROP PROCEDURE  Proc_Cs2Cn_SchemeUtilization
GO
--SELECT * FROM DayEndProcess Where procId = 4
--EXEC Proc_Cs2Cn_SchemeUtilization 0
--SELECT * FROM  Cs2Cn_Prk_SchemeUtilization
Create PROCEDURE [Proc_Cs2Cn_SchemeUtilization]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_Cs2Cn_SchemeUtilization
* PURPOSE: Extract Scheme Utilization Details from CoreStocky to Console
* NOTES:
* CREATED: Thrinath Kola 16-12-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @ChkSRDate	AS DATETIME

	SET @Po_ErrNo=0

	DELETE FROM Cs2Cn_Prk_SchemeUtilization WHERE UploadFlag = 'Y'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 1
	SELECT @ChkSRDate = NextUpDate FROM DayEndProcess Where ProcId = 4

	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END,
		(ISNULL(SUM(FlatAmount),0) + ISNULL(SUM(DiscountPerAmount),0)) As Utilized,
		'' as SchemeFreeProduct ,
		0 as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceSchemeLineWise A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,CM.CmpCode,B.SalInvNo,R.CmpRtrCode,B.SalInvDate ,SM.SchType,SM.CmpSchCode,SM.Download

	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0) As Utilized ,
		P.PrdCCode as SchemeFreeProduct,
		SUM(FreeQty) as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Product P ON A.FreePrdId = P.PrdId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,B.SalInvNo,R.CmpRtrCode,CM.CmpCode,B.SalInvDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,SM.Download
	
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType 	WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0) As Utilized ,
		P.PrdCCode as SchemeFreeProduct,
		SUM(GiftQty) as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Product P ON A.GiftPrdId = P.PrdId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,B.SalInvNo,R.CmpRtrCode,CM.CmpCode,B.SalInvDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,SM.Download
	
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(AdjAmt),0) As Utilized,
		'' as SchemeFreeProduct ,
		0 as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceWindowDisplay A
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,B.SalInvNo,R.CmpRtrCode,CM.CmpCode ,B.SalInvDate ,SM.SchType,SM.CmpSchCode,SM.Download
	

	--->Added By Nanda on 06/04/2010 For QPS Scheme-Credit Note Conversion
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.SalInvDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(A.CrNoteAmount),0) As Utilized ,
		'' AS SchemeFreeProduct,
		0 AS SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceQPSSchemeAdj A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId AND Mode=1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY SM.SchCode,SM.SchDsc,B.SalInvNo,R.CmpRtrCode,CM.CmpCode,B.SalInvDate,SM.SchType,SM.CmpSchCode,SM.Download

	UNION ALL

	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		'AutoQPSConversion' AS SalInvNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		A.LastModDate,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(A.CrNoteAmount),0) As Utilized ,
		'' AS SchemeFreeProduct,
		0 AS SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121) ,
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM SalesInvoiceQPSSchemeAdj A 
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId AND Mode=2
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Retailer R ON R.RtrId = A.RtrId
		WHERE CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY SM.SchCode,SM.SchDsc,R.CmpRtrCode,CM.CmpCode,A.LastModDate,SM.SchType,SM.CmpSchCode,SM.Download
	--->Till Here

	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.ChqDisRefNo,
		R.CmpRtrCode,
		CM.CmpCode ,
		A.ChqDisDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END ,
		ISNULL(SUM(Amount),0) As Utilized ,
		'' as SchemeFreeProduct ,
		0 as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM ChequeDisbursalMaster A
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo
		INNER JOIN SchemeMaster SM ON A.TransId = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE TransType = 1 AND CM.CmpID = @CmpID AND A.SchemeUpLoad=0--A.ChqDisDate >= @ChkDate
	GROUP BY SM.SchCode,SM.SchDsc,B.ChqDisRefNo,R.CmpRtrCode,CM.CmpCode ,A.ChqDisDate ,SM.SchType,SM.CmpSchCode,SM.Download

	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.ReturnCode,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.ReturnDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END,
		-1 * (ISNULL(SUM(ReturnFlatAmount),0) + ISNULL(SUM(ReturnDiscountPerAmount),0)),
		'' as SchemeFreeProduct ,
		0 as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM ReturnSchemeLineDt A 
		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.ReturnDate >= @ChkSRDate
	GROUP BY SM.SchCode,SM.SchDsc,B.ReturnCode,R.CmpRtrCode,CM.CmpCode ,B.ReturnDate ,SM.SchType,SM.CmpSchCode,SM.Download
	
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.ReturnCode,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.ReturnDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END,
		-1 * ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0),
		P.PrdCCode as SchemeFreeProduct ,
		-1 * SUM(ReturnFreeQty) as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode ,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 	
		FROM ReturnSchemeFreePrdDt A 
		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Product P ON A.FreePrdId = P.PrdId
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.ReturnDate >= @ChkSRDate
	GROUP BY SM.SchCode,SM.SchDsc,B.ReturnCode,R.CmpRtrCode,CM.CmpCode ,B.ReturnDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,SM.Download
	
	INSERT INTO Cs2Cn_Prk_SchemeUtilization
	(
		[DistCode] 		,
		[SchemeCode] 		,
		[SchemeDescription] 	,
		[InvoiceNo]		,
		[RtrCode]		,
		[Company] 		,
		[SchDate] 		,
		[SchemeType] 		,
		[SchemeUtilizedAmt] 	,
		[SchemeFreeProduct] 	,
		[SchemeUtilizedQty] 	,
		[UploadFlag]		,
		[CompanySchemeCode],
		[CreatedDate],
		[SchemeMode]
	)
	SELECT
		@DistCode,
		SM.SchCode ,
		SM.SchDsc ,
		B.ReturnCode,
		R.CmpRtrCode,
		CM.CmpCode ,
		B.ReturnDate ,
		CASE SM.SchType WHEN 1 THEN 'Quantity Based'
				WHEN 2 THEN 'Amount Based'
				WHEN 3 THEN 'Weight Based'
				WHEN 4 THEN 'Display' END,
		ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0),
		P.PrdCCode as SchemeFreeProduct ,
		-1 * SUM(ReturnGiftQty) as SchemeUtilizedQty ,
		'N' as UploadFlag,SM.CmpSchCode ,CONVERT(NVARCHAR(10),GETDATE(),121),
		CASE SM.Download 	WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes' END 
		FROM ReturnSchemeFreePrdDt A 
		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
		INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
		INNER JOIN Product P ON A.GiftPrdId = P.PrdId 
		INNER JOIN Retailer R ON R.RtrId = B.RtrId
		WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.ReturnDate >= @ChkSRDate
	GROUP BY SM.SchCode,SM.SchDsc,B.ReturnCode,R.CmpRtrCode,CM.CmpCode ,B.ReturnDate ,SM.SchType ,P.PrdCCode,SM.CmpSchCode,SM.Download

	SELECT SchId INTO #SchId FROM SchemeMaster WHERE SchCode IN (SELECT SchemeCode FROM Cs2Cn_Prk_SchemeUtilization
	WHERE UploadFlag='N')

	UPDATE SalesInvoice SET SchemeUpLoad=1 WHERE SalId IN (SELECT DISTINCT SalId FROM
	SalesInvoiceSchemeHd WHERE SchId IN (SELECT SchId FROM #SchId)) AND DlvSts IN (4,5)

	UPDATE SalesInvoice SET SchemeUpLoad=1 WHERE SalId IN (SELECT DISTINCT SalId FROM
	SalesInvoiceWindowDisplay WHERE SchId IN (SELECT SchId FROM #SchId)) AND DlvSts IN (4,5)
	
	UPDATE SalesInvoiceQPSSchemeAdj SET Upload=1
	WHERE SalId IN (SELECT SalId FROM SalesInvoice WHERE SchemeUpload=1) AND Mode=1

	UPDATE SalesInvoiceQPSSchemeAdj SET Upload=1
	WHERE SalId = -1000 AND Mode=2

	UPDATE ReturnHeader SET SchemeUpLoad=1 WHERE ReturnId IN (SELECT DISTINCT ReturnId FROM (
	SELECT ReturnId FROM ReturnSchemeFreePrdDt WHERE SchId IN (SELECT SchId FROM #SchId)
	UNION
	SELECT ReturnId FROM ReturnSchemeLineDt WHERE SchId IN (SELECT SchId FROM #SchId))A) AND Status=0

	UPDATE ChequeDisbursalMaster SET SchemeUpLoad=1 WHERE ChqDisRefNo IN (SELECT DISTINCT ChqDisRefNo FROM
	ChequeDisbursalDetails WHERE TransId IN (SELECT SchId AS TransId FROM #SchId))
	AND TransType = 1

END
GO
IF EXISTS (Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_DefaultPriceHistory')
DROP PROCEDURE Proc_DefaultPriceHistory
GO
Create Procedure [dbo].[Proc_DefaultPriceHistory]
(
	@Pi_PrdId			INT,	
	@Pi_PrdBatId			INT,
	@Pi_PriceId			INT,
	@Pi_Mode			INT,
	@Pi_UserId			INT
)
AS
/*********************************
* PROCEDURE		: Proc_DefaultPriceHistory
* PURPOSE		: To Store the Default Price History
* CREATED		: Nandakumar R.G
* CREATED DATE	: 02/10/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
/*
	@Pi_Mode=1 ---> Through Front End
	@Pi_Mode=2 ---> Changes Through ETL/Download
*/
SET NOCOUNT ON
BEGIN
	DECLARE @PrdId		INT
	DECLARE @PrdBatId	INT
	DECLARE @PriceId	INT
	IF @Pi_Mode=1
	BEGIN
		IF NOT EXISTS(SELECT * FROM DefaultPriceHistory WHERE PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId 
		AND PriceId=@Pi_PriceId AND ToDate='1900-01-01')
		BEGIN
			
			-->To Set the To Date for old default price
			UPDATE DefaultPriceHistory SET ToDate=GETDATE()
			WHERE PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId AND CurrentDefault=1
			-->To update the old prices as non defaults
			UPDATE DefaultPriceHistory SET CurrentDefault=0
			WHERE PrdId=@Pi_PrdId AND PrdBatId=@Pi_PrdBatId
		
			-->To insert the new defaults
			INSERT INTO DefaultPriceHistory(PrdId,PrdBatId,PriceId,SellingRate,PurchaseRate,MRP,FromDate,ToDate,CurrentDefault,
			Availability,LastModBy,LastModDate,AuthId,AuthDate) 	
			SELECT PB.PrdId,PB.PrdBatId,PBDS.PriceId,PBDS.PrdBatDetailValue,PBDP.PrdBatDetailValue,PBDM.PrdBatDetailValue,GETDATE(),'1900-01-01',1, 
			1,@Pi_UserId,GETDATE(),1,GETDATE() FROM ProductBatchDetails PBDS,ProductBatchDetails PBDP,ProductBatchDetails PBDM,
			ProductBatch PB,BatchCreation BCS,BatchCreation BCP,BatchCreation BCM
			WHERE PBDS.PriceId=PBDP.PriceId AND PBDS.PriceId=PBDM.PriceId AND PBDS.PrdbatId=@Pi_PrdBatId AND
			PBDS.PriceId=@Pi_PriceId AND PBDS.PrdBatId=PB.PrdBatId AND PB.PrdId=@Pi_PrdId
			AND PBDS.SlNo=BCS.SlNo AND PBDS.BatchSeqId=BCS.BatchSeqId AND BCS.SelRte=1
			AND PBDP.SlNo=BCP.SlNo AND PBDP.BatchSeqId=BCP.BatchSeqId AND BCP.ListPrice=1
			AND PBDM.SlNo=BCM.SlNo AND PBDM.BatchSeqId=BCM.BatchSeqId AND BCM.MRP=1
			AND PBDS.DefaultPrice=1 AND PBDP.DefaultPrice=1 AND PBDM.DefaultPrice=1
		END
	END
	ELSE IF @Pi_Mode=2
	BEGIN
		DECLARE Cur_DefaultPrice CURSOR
		FOR SELECT PB.PrdId,PB.PrdBatId,PBD.PriceId FROM ProductBatch PB(NOLOCK),ProductBatchDetails PBD(NOLOCK)
		WHERE PB.PrdBatId=PBD.PrdBatId AND PBD.PriceId>=@Pi_PriceId AND PBD.SlNo=1 AND PBD.DefaultPrice=1
		ORDER BY PB.PrdId,PB.PrdBatId,PBD.PriceId
		OPEN Cur_DefaultPrice
		FETCH NEXT FROM Cur_DefaultPrice INTO @PrdId,@PrdBatId,@PriceId
		WHILE @@FETCH_STATUS=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM DefaultPriceHistory WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId 
			AND PriceId=@PriceId AND ToDate='1900-01-01')
			BEGIN
				-->To Set the To Date for old default price
				UPDATE DefaultPriceHistory SET ToDate=GETDATE()
				WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId AND CurrentDefault=1
				-->To update the old prices as non defaults
				UPDATE DefaultPriceHistory SET CurrentDefault=0
				WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId
			
				-->To insert the new defaults
				INSERT INTO DefaultPriceHistory(PrdId,PrdBatId,PriceId,SellingRate,PurchaseRate,MRP,FromDate,ToDate,CurrentDefault,
				Availability,LastModBy,LastModDate,AuthId,AuthDate) 	
				SELECT PB.PrdId,PB.PrdBatId,PBDS.PriceId,PBDS.PrdBatDetailValue,PBDP.PrdBatDetailValue,PBDM.PrdBatDetailValue,GETDATE(),'1900-01-01',1, 
				1,@Pi_UserId,GETDATE(),1,GETDATE() FROM ProductBatchDetails PBDS,ProductBatchDetails PBDP,ProductBatchDetails PBDM,
				ProductBatch PB,BatchCreation BCS,BatchCreation BCP,BatchCreation BCM
				WHERE PBDS.PriceId=PBDP.PriceId AND PBDS.PriceId=PBDM.PriceId AND PBDS.PrdBatId=@PrdBatId AND
				PBDS.PriceId=@PriceId AND PBDS.PrdBatId=PB.PrdBatId AND PB.PrdId=@PrdId
				AND PBDS.SlNo=BCS.SlNo AND PBDS.BatchSeqId=BCS.BatchSeqId AND BCS.SelRte=1
				AND PBDP.SlNo=BCP.SlNo AND PBDP.BatchSeqId=BCP.BatchSeqId AND BCP.ListPrice=1
				AND PBDM.SlNo=BCM.SlNo AND PBDM.BatchSeqId=BCM.BatchSeqId AND BCM.MRP=1
				AND PBDS.DefaultPrice=1 AND PBDP.DefaultPrice=1 AND PBDM.DefaultPrice=1
			
			END
			FETCH NEXT FROM Cur_DefaultPrice INTO @PrdId,@PrdBatId,@PriceId
		END
		CLOSE Cur_DefaultPrice
		DEALLOCATE Cur_DefaultPrice
	END
END
GO
EXEC Proc_DefaultPriceHistory 1,1,1,2,1
GO
--*****************************BNL Default Price History*******************************-------------------------
Delete From Tbl_Downloadintegration Where ProcessName = 'Product Batch'
GO
Insert Into Tbl_Downloadintegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values (14,'Product Batch','Cn2Cs_Prk_ProductBatch','Proc_Import_ProductBatch',7,200,'2011-11-03 14:18:59.187')
GO
Delete From Customupdownload Where Module = 'Product Batch'
GO
Insert Into Customupdownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
Values(16,1,'Product Batch','Product Batch','Proc_Cs2Cn_ProductBatch','Proc_Import_ProductBatch','Cn2Cs_Prk_ProductBatch','Proc_Cn2Cs_ProductBatch','Master','Download',1)
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name ='Proc_Cn2Cs_ProductBatch')
DROP PROCEDURE Proc_Cn2Cs_ProductBatch
GO
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_ProductBatch]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ProductBatch
* PURPOSE		: To Insert and Update records in the Tables ProductBatch and ProductBatchDetails
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 12/04/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
    DECLARE @Po_BatchTransfer	AS  INT
    DECLARE @BatchTransfer		AS  INT
    DECLARE @Tabname 			AS  NVARCHAR(100)
	DECLARE @Exist 				AS  INT
	DECLARE @PrdCCode 	        AS 	NVARCHAR(100)
	DECLARE @BatchCode			AS 	NVARCHAR(100)
	DECLARE @PriceCode			AS 	NVARCHAR(4000)		
	DECLARE @MnfDate			AS 	NVARCHAR(100)
	DECLARE @ExpDate			AS 	NVARCHAR(100)
	DECLARE	@BatchSeqCode 		AS 	NVARCHAR(100)
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
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
	DECLARE @ContPriceCode		AS	NVARCHAR(100)
	DECLARE @ContPrdBatId1		AS	INT
	DECLARE @ContPriceId1		AS	INT
	DECLARE @OldPriceId 		AS 	INT
	DECLARE @NewPriceId			AS  INT
	DECLARE @OldLSP				AS  NUMERIC(38,6)
	DECLARE @StockInHand		AS  NUMERIC(38,0)
	DECLARE @ValDiffRefNo		AS  NVARCHAR(50)
	DECLARE @MRP				AS  NUMERIC(38,6)
	DECLARE @LSP				AS  NUMERIC(38,6)
	DECLARE @SR					AS  NUMERIC(38,6)
	DECLARE @CR					AS  NUMERIC(38,6)
	DECLARE @AR1				AS  NUMERIC(38,6)
	DECLARE @AR2				AS  NUMERIC(38,6)
	DECLARE @AR3				AS  NUMERIC(38,6)
	DECLARE @AR4				AS  NUMERIC(38,6)
	DECLARE @AR5				AS  NUMERIC(38,6)
	DECLARE @AR6				AS  NUMERIC(38,6)
	SET @Po_ErrNo=0
	SET @Exist=0
    SET @Tabname = 'ETL_Prk_ProductBatch'
	SELECT @ExistPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch
	SELECT @OldPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails		
	SELECT @BatchSeqId=BatchSeqId FROM BatchCreationMaster WHERE BatchSeqId IN
	(SELECT MAX(BatchSeqId) FROM BatchCreationMaster)
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PrdBatToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE PrdBatToAvoid	
	END
	CREATE TABLE PrdBatToAvoid
	(
		PrdCCode NVARCHAR(200),
		PrdBatCode NVARCHAR(200)
	)
--->Added
    SELECT [Product Code],[Batch Code],[Price Code],[Batch Sequence Code],COUNT(DISTINCT [Default Price]) AS DefaultPrice
	INTO #TempErrorLog	
	FROM ETL_Prk_ProductBatch
	GROUP BY [Product Code],[Batch Code],[Price Code],[Batch Sequence Code]
	HAVING COUNT(DISTINCT [Default Price])>1
 
    IF (SELECT COUNT(*) FROM #TempErrorLog)>0
	BEGIN
	INSERT INTO Errorlog VALUES (1,@TabName,'Default Price',
	 	'Default Price is not set correctly')
	 	SET @Po_ErrNo=1
	END
--->Till Here
--Added By Murugan
	--Check Product Code
	INSERT INTO Errorlog
	SELECT DISTINCT 1,@TabName,'Product','Product Code ['+ISNULL([Product Code],'') +'] does not exists for Batch Code ['+ISNULL([Batch Code],'')+']'
	FROM ETL_Prk_ProductBatch WHERE [Product Code] NOT IN(SELECT PrdCCode FROM Product)	
	--Till Here

	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdCCode','Product :'+PrdCCode+' not available'
		FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		--->Added By Nanda on 05/05/2010
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Product Batch',PrdBatCode,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		--->Till Here				
	END
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch
	WHERE LEN(ISNULL(PrdBatCode,''))=0)
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch
		WHERE LEN(ISNULL(PrdBatCode,''))=0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdBatCode','Batch Code should not be empty for Product:'+PrdCCode
		FROM Cn2Cs_Prk_ProductBatch
		WHERE LEN(ISNULL(PrdBatCode,''))=0
	END
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PB.PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,MRP,ListPrice,SellingRate,ClaimRate,
	AddRate1,AddRate2,AddRate3,AddRate4,AddRate5,AddRate6
	FROM Cn2Cs_Prk_ProductBatch PB INNER JOIN Product P ON P.PrdCCode=PB.PrdCCode
	WHERE DownLoadFlag='D' AND PB.PrdCCode+'~'+PrdBatCode
	NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid)	
	ORDER BY PB.PrdCCode,PrdBatCode,EffectiveDate
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@AR1,@AR2,@AR3,@AR4,@AR5,@AR6	
	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @Exist=0
		SET @Po_ErrNo=0
		SET @DefaultPriceId=1
		SET @BatchStatus=1
		SET @PriceCode=@BatchCode+'-'+CAST(@MRP AS NVARCHAR(25))+'-'+CAST(@LSP AS NVARCHAR(25))+'-'+
		CAST(@SR AS NVARCHAR(25))+'-'+CAST(@CR AS NVARCHAR(25))+'-'+CAST(@AR1 AS NVARCHAR(25))
		SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode
		SELECT @TaxGroupId=ISNULL(TaxGroupId,0) FROM Product WITH (NOLOCK) WHERE PrdId=@PrdId
		
		IF NOT EXISTS(SELECT * FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@BatchCode AND PrdId=@PrdId)
		BEGIN
			SET @Exist=0
		END
		ELSE
		BEGIN
			SET @Exist=1 				
			SELECT @PrdBatId=PrdBatId FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@BatchCode AND PrdId=@PrdId
			SELECT @OldLSP=ISNULL(PBD.PrdBatDetailValue,0),@ExistPriceId=PriceId FROM ProductBatchDetails PBD
			WHERE PrdBatId=@PrdBatId AND DefaultPrice=1 AND SlNo=2
		END
		
		IF @Exist=0
		BEGIN
			SELECT @PrdBatId=dbo.Fn_GetPrimaryKeyInteger('ProductBatch','PrdBatId',YEAR(GETDATE()),MONTH(GETDATE()))
			IF @PrdBatId>(SELECT ISNULL(MAX(PrdBatId),0) AS PrdBatId FROM ProductBatch)
			BEGIN
				INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,
				TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PrdId,@PrdBatId,@BatchCode,@BatchCode,@MnfDate,@ExpDate,@BatchStatus,@TaxGroupId,@BatchSeqId,6,
				0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
				
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatch' AND FldName='PrdBatId'
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_ProductBatch','System Date',
				'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
				SET @Po_ErrNo=1
				CLOSE Cur_ProductBatch
				DEALLOCATE Cur_ProductBatch
				RETURN
			END
		END	
		ELSE
		BEGIN
			UPDATE ProductBatch SET MnfDate=@MnfDate,ExpDate=@ExpDate,TaxGroupId=@TaxGroupId,Status=@BatchStatus
			WHERE PrdBatId=@PrdBatId
		END			
			
		IF @Po_ErrNo=0
		BEGIN
			SELECT @PriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))
			IF @PriceId>(SELECT ISNULL(MAX(PriceId),0) AS PriceId FROM ProductBatchDetails)
			BEGIN
				IF @DefaultPriceId=1
				BEGIN
					UPDATE ProductBatchDetails SET DefaultPrice=0 WHERE PrdBatId=@PrdBatId AND PriceId<>@PriceId
				END
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,1,@MRP,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,2,@LSP,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,3,@SR,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,4,@CR,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatchSeqId)>4
				BEGIN
					INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
					DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,5,@AR1,@DefaultPriceId,1,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 
				END
				UPDATE ProductBatch SET DefaultPriceId=@PriceId WHERE PrdBatId=@PrdBatId AND PrdId=@PrdId
	
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'				
				IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRateForOldBatch'
				AND ModuleName='Botree Product Batch Download' AND Status=1)
				BEGIN
					IF @OldLSP-@LSP<>0 AND @Exist=1		
					BEGIN
						SELECT @StockInHand=ISNULL((PrdBatLcnSih+PrdBatLcnUih-PrdBatLcnRessih-PrdBatLcnResUih),0)
						FROM ProductBatchLocation WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId			
						IF @StockInHand>0
						BEGIN
							SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
							
							INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
							VALUES(@ValDiffRefNo,GETDATE(),@PrdId,@PrdBatId,@ExistPriceId,@PriceId,@OldLSP,@LSP,@StockInHand,(@OldLSP-@LSP),(@StockInHand*(@OldLSP-@LSP)),1,1,GETDATE(),1,GETDATE())
							UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'
						END
					END
				END
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_ProductBatch','System Date',
				'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
				SET @Po_ErrNo=1
				CLOSE Cur_ProductBatch
				DEALLOCATE Cur_ProductBatch
				RETURN
			END
		END
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@AR1,@AR2,@AR3,@AR4,@AR5,@AR6		
--		IF (SELECT COUNT(DISTINCT A.PriceId) AS COUNT FROM ProductBatchDetails A INNER JOIN ProductBatch B (NOLOCK) ON
--		A.PrdBatId=B.PrdBatId And B.PrdId=@PrdId WHERE A.DefaultPrice=1 AND A.PrdBatId=@PrdBatId GROUP BY A.PrdBatId	
--		HAVING COUNT(DISTINCT A.PriceId)>1)>1
--		BEGIN
--			UPDATE ProductBatchDetails SET DefaultPrice=0
--			WHERE PrdBatId=@PrdBatId AND PriceId NOT IN
--			(
--				SELECT MAX(DISTINCT PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK)
--				WHERE PrdBatId=@PrdBatId AND DefaultPrice=1
--			)						
--			
--			UPDATE ProductBatch SET DefaultPriceId=B.PriceId
--			FROM ProductBatchDetails B (NOLOCK) WHERE ProductBatch.PrdBatId=B.PrdBatId AND
--			ProductBatch.PrdBatId=@PrdBatId AND B.DefaultPrice=1 AND B.SlNo=1
--		END
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	UPDATE ProductBatch SET ProductBatch.DefaultPriceId=PBD.PriceId,ProductBatch.BatchSeqId=PBD.BatchSeqId
	FROM ProductBatchDetails PBD WHERE ProductBatch.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
	
	UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId IN
	(
	 SELECT PrdBatId FROM ProductBatchDetails GROUP BY PrdBatId  HAVING(COUNT(DISTINCT PriceId)>1)
	)
	
	SELECT PrdBatId INTO #ZeroBatches FROM ProductBatchDetails
	GROUP BY PrdBatId HAVING SUM(DefaultPrice)=0
	
	SELECT B.PrdId,B.PrdBatId,MAX(PriceId) As PriceId INTO #ZeroMaxPrices
	FROM ProductBatchDetails A INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
	INNER JOIN #ZeroBatches C ON A.PrdBatId=C.PrdBatId
	WHERE A.DefaultPrice=0 GROUP BY B.PrdId,B.PrdBatId
	
	UPDATE ProductBatch Set DefaultPriceId=B.PriceId FROM ProductBatch A,#ZeroMaxPrices B
	WHERE A.PrdBatId=B.PrdbatId and A.PrdId=B.PrdId
	
	UPDATE ProductBatchDetails Set DefaultPrice=1 FROM #ZeroMaxPrices A
	WHERE ProductBatchDetails.PrdbatId=A.PrdBatId AND ProductBatchDetails.PriceId=A.PriceId
	
	SET @Po_ErrNo=0	
	--->Added By Nanda on 03/12/2009 for Special Rate
	IF @ExistPrdBatMaxId>0
	BEGIN
		SELECT @NewPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch
		IF @NewPrdBatMaxId>@ExistPrdBatMaxId
		BEGIN
			DECLARE Cur_NewPrdBat CURSOR
			FOR SELECT PB.PrdId,PB.PrdBatId FROM ProductBatch PB WHERE PB.PrdBatId>@ExistPrdBatMaxId
			ORDER BY PB.PrdId,PB.PrdBatId
			OPEN Cur_NewPrdBat
			FETCH NEXT FROM Cur_NewPrdBat INTO @ContPrdId,@ContPrdBatId
			WHILE @@FETCH_STATUS=0
			BEGIN			
				SET @ContExistPrdBatId=0
				SELECT @ContExistPrdBatId=ISNULL(MAX(PB.PrdBatId),0) FROM ProductBatch PB WHERE
				PB.PrdId=@ContPrdId AND PB.PrdBatId <>@ContPrdBatId AND PB.PrdBatId IN
				(SELECT CPD.PrdBatId FROM ContractPricingDetails CPD,ProductBatch PB WHERE PB.PrdId=@ContPrdId
				 AND CPD.PrdId=PB.PrdId	AND CPD.PrdBatId=PB.PrdBatId)
				SELECT @ContPriceCode=PriceCode FROM ProductBatchDetails WHERE PrdBatId <>@ContPrdBatId
				IF @ContExistPrdBatId<>0
				BEGIN
					DECLARE Cur_NewCont CURSOR
					FOR SELECT DISTINCT PrdBatId,PriceId FROM ProductBatchDetails WHERE PriceId IN
					(SELECT PriceId FROM ContractPricingDetails WHERE PrdBatId=@ContExistPrdBatId) AND
					PrdBatId=@ContExistPrdBatId AND SlNo=3 AND PrdBatDetailValue>0
					OPEN Cur_NewCont
					FETCH NEXT FROM Cur_NewCont INTO @ContPrdBatId1,@ContPriceId
					WHILE @@FETCH_STATUS=0
					BEGIN					
						SELECT @ContPriceId1=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))		
						UPDATE Counters SET CurrValue=@ContPriceId1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=1
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=2
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId1 AND PriceId=@ContPriceId AND SlNo=3
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=4

						IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatchSeqId)>4
						BEGIN
							INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
							Availability,LastModBy,LastModDate,AuthId,AuthDate)
							SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
							SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
							FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=5
						END
						
						INSERT INTO ContractPricingDetails(ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,
						Availability,LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId,ClaimablePercOnMRP)
						SELECT ContractId,PrdId,@ContPrdBatId,@ContPriceId1,Discount,FlatAmtDisc,
						Availability,LastModBy,GETDATE(),AuthId,GETDATE(),CtgValMainId,0
						FROM ContractPricingDetails WHERE PrdBatId=@ContPrdBatId1 AND PriceId=@ContPriceId
						FETCH NEXT FROM Cur_NewCont INTO @ContPrdBatId1,@ContPriceId
					END
					CLOSE Cur_NewCont
					DEALLOCATE Cur_NewCont
				END
				FETCH NEXT FROM Cur_NewPrdBat INTO @ContPrdId,@ContPrdBatId
			END
			CLOSE Cur_NewPrdBat
			DEALLOCATE Cur_NewPrdBat
		END
	END
	--->Till Here
	SELECT @NewPriceId=CurrValue FROM Counters (NOLOCK)	WHERE TabName='ProductBatchDetails' AND FldName='PriceId' 		
	--->Added By Nanda on 24/03/2010

	--->To Update Price
	IF @NewPriceId>@OldPriceId
	BEGIN
		IF EXISTS(SELECT * FROM Configuration(NOLOCK) WHERE ModuleId='BotreeRateForOldBatch'
		AND ModuleName='Botree Product Batch Download' AND Status=1)
		BEGIN
			EXEC Proc_DefaultPriceUpdation @ExistPrdBatMaxId,@OldPriceId,1
		END
	END
	--->Till Here
	
	--->Added By Nanda on 02/10/2009
	--->To Write Price History
	IF EXISTS(SELECT * FROM ProductBatchDetails WHERE DefaultPrice=1 AND PriceId>@OldPriceId)
	BEGIN
		EXEC Proc_DefaultPriceHistory 0,0,@OldPriceId,2,1
	END
	--->Till Here
	UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y' 
	WHERE PrdCCode+'~'+PrdBatCode IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode
	FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		--->Added By Nanda on 03/12/2009 for Special Rate
	IF @ExistPrdBatMaxId>0
	BEGIN		
		SET @BatchTransfer=0
		SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='BotreeAutoBatchTransfer'
		IF @BatchTransfer=1
		BEGIN
			EXEC Proc_AutoBatchTransfer @ExistPrdBatMaxId,@Po_ErrNo = @Po_BatchTransfer OUTPUT
			IF @Po_BatchTransfer=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Batch-Auto Batch Transfer',
				'Auto Batch Transfer is not done properly')           	
				SET @Po_ErrNo=1				
			END
		END
	END
--->Till Here
	RETURN	
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptProductWise')
DROP TABLE RptProductWise
GO
CREATE TABLE [dbo].[RptProductWise](
	[SalId] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[CmpId] [int] NULL,
	[LcnId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdUnitMRP] [numeric](38, 6) NULL,
	[PrdUnitSelRate] [numeric](38, 6) NULL,
	[FreeQty] [int] NULL,
	[RepQty] [int] NULL,
	[ReturnQty] [int] NULL,
	[SalesQty] [int] NULL,
	[SalesGrossValue] [numeric](38, 6) NULL,
	[TaxAmount] [numeric](38, 6) NULL,
	[ReturnGrossValue] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[DlvSts] [int] NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL,
	[SalesPrdWeight] [numeric](38, 6) NULL,
	[FreePrdWeight] [numeric](38, 6) NULL,
	[RepPrdWeight] [numeric](38, 6) NULL,
	[RetPrdWeight] [numeric](38, 6) NULL
) ON [PRIMARY]

GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_ProductWiseSalesOnly')
DROP PROCEDURE Proc_ProductWiseSalesOnly
GO
--EXEC Proc_ProductWiseSalesOnly 2,2
--SELECT * FROM RptProductWise (NOLOCK)
CREATE PROCEDURE [dbo].[Proc_ProductWiseSalesOnly]
(
@Pi_RptId   INT,
@Pi_UsrId   INT
)
/************************************************************
* PROC			: Proc_ProductWiseSalesOnly
* PURPOSE		: To get the Product details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 18/02/2010
* NOTE			:
* MODIFIED		:
* DATE        AUTHOR   DESCRIPTION
14-09-2009   Mahalakshmi.A     BugFixing for BugNo : 20625
------------------------------------------------
* {date} {developer}  {brief modification description}
*************************************************************/
AS
BEGIN
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate   AS DATETIME
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	DELETE FROM RptProductWise WHERE RptId= @Pi_RptId And UsrId IN(0,@Pi_UsrId)
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		SIP.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SIP.SalManFreeQty AS FreeQty,0 AS RepQty,0 AS ReturnQty,
		SIP.BaseQty AS SalesQty,SIP.PrdGrossAmount,SIP.PrdTaxAmount,0 AS ReturnGrossValue,DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,PrdNetAmount,((P.PrdWgt*SIP.BaseQty)/1000),((P.PrdWgt*SIP.SalManFreeQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceProduct SIP WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SIP.SalId=SI.SalId AND P.PrdId=SIP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SIP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId  AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.FreeQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts---@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.FreeQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SSF.SalId=SI.SalId  AND P.PrdId=SSF.FreePrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.FreePrdBatId
		AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.GiftQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.GiftQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SSF.SalId=SI.SalId AND P.PrdId=SSF.GiftPrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.GiftPrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementOut REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo <>'RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		0 AS RepQty,REO.RtnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,REO.RtnAmount AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,0,((P.PrdWgt*REO.RtnQty)/1000)
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementIn REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,REO.RepAmount AS SalesGrossValue,REO.Tax AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID ,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementOut REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Return Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		0 AS FreeQty,0 AS RepQty,RP.BaseQty AS ReturnQty,
		0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,RP.PrdGrossAmt,SI.DlvSts--@
		,@Pi_RptId AS RptId,@Pi_UsrId AS UsrId,-1*PrdNetAmt,0,0,0,((P.PrdWgt*RP.BaseQty)/1000)
		FROM SalesInvoice SI WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK),
		ReturnHeader RH WITH (NOLOCK),
		ReturnProduct RP WITH (NOLOCK)
		WHERE SI.SalId=RH.SalId AND RH.ReturnId=RP.ReturnId AND P.PrdId=RP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=RP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RtrLoadSheetItemWise')
DROP TABLE RtrLoadSheetItemWise
GO
CREATE TABLE RtrLoadSheetItemWise
(
	[SalId] [bigint] NULL,
	[SalInvNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvDate] [datetime] NULL,
	[DlvRMId] [int] NULL,
	[VehicleId] [int] NULL,
	[AllotmentNumber] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MRP] [numeric](38, 6) NULL,
	[SellingRate] [numeric](38, 6) NULL,
	[BillQty] [numeric](38, 0) NULL,
	[FreeQty] [numeric](38, 0) NULL,
	[ReturnQty] [numeric](38, 0) NULL,
	[RepalcementQty] [numeric](38, 0) NULL,
	[TotalQty] [numeric](38, 0) NULL,
	[PrdWeight] [numeric](38, 4) NULL,
	[GrossAmount] [numeric](38, 2) NULL,
	[TaxAmount] [numeric](38, 2) NULL,
	[NetAmount] [numeric](38, 2) NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]

GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptItemWise')
DROP PROCEDURE Proc_RptItemWise
GO
--EXEC Proc_RptItemWise 2,1

Create   Procedure [dbo].[Proc_RptItemWise]
(
	@Pi_RptId 		INT,
	@Pi_UsrId 		INT
)
/************************************************************

* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
BEGIN
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate   AS DATETIME  

	EXEC Proc_ProductWiseSalesOnly @Pi_RptId,@Pi_UsrId
	DELETE FROM RtrLoadSheetItemWise WHERE RptId= @Pi_RptId And UsrId IN(0,@Pi_UsrId)

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  

	INSERT INTO RtrLoadSheetItemWise(SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId,AllotmentNumber,
				SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,MRP,SellingRate,
				BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,PrdWeight,GrossAmount,TaxAmount,NetAmount,RptId,UsrId)
		SELECT SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId, allotmentid,
				SMId,RtrId,RtrName,
				PrdId,PrdDCode,PrdName,
				PrdBatId,PrdBatCode,MRP,SellingRate,
				SUM(SalesQty) BillQty,
				SUM(FreeQty) FreeQty,SUM(ReturnQty) ReturnQty,SUM(RepQty) ReplacementQty,
				SUM(SalesQty) + SUM(FreeQty) + SUM(ReturnQty) + SUM(RepQty) TotalQty,SUM(SalesPrdWeight)AS PrdWeight,SUM(SalesGrossValue) AS GrossAmount,
				SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,
				@Pi_RptId RPtId,@Pi_UsrId USrId
		FROM (

		SELECT X.* ,V.AllotmentId FROM
		(
			SELECT P.SalId,SI.SalInvNo,P.SalInvDate,SI.DlvRMId,SI.VehicleId,
			P.SMId,P.RtrId,R.RtrName,
			P.PrdId,P.PrdDCode,P.PrdName,P.PrdBatId,P.PrdBatCode,P.PrdUnitMRP AS MRP,
			P.PrdUnitSelRate AS SellingRate,
			P.SalesQty,P.FreeQty,P.ReturnQty,P.RepQty,P.SalesPrdWeight,P.SalesGrossValue,P.TaxAmount,P.NetAmount
			FROM SalesInvoice SI
			LEFT OUTER JOIN RptProductWise P ON SI.SalId  = P.SalId
			LEFT OUTER JOIN Retailer R ON SI.RtrId = R.RtrId
			WHERE SI.DlvSts = 2 AND P.RptId = @Pi_RptId AND P.UsrId = @Pi_UsrId 
			AND SI.SalInvDate BETWEEN  @FromDate AND @ToDate
			) X
			LEFT OUTER JOIN
			(
				SELECT VM.AllotmentId,VM.AllotmentNumber,VM.VehicleId,SaleInvNo FROM VehicleAllocationMaster VM,
				VehicleAllocationDetails VD	WHERE VM.AllotmentNumber = VD.AllotmentNumber
			) V  ON X.VehicleId  = V.VehicleId and X.SalInvNo = V.SaleInvNo
		 ) F
		GROUP BY SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId, AllotmentId,
		SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,MRP,SellingRate

END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptLoadSheetItemWise')
DROP PROCEDURE Proc_RptLoadSheetItemWise
GO
--EXEC Proc_RptLoadSheetItemWise 18,1,0,'Parle',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptLoadSheetItemWise]
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
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
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
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @UOMId	 	AS	INT
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
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
	SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @ToBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	
	--Till Here
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	
	
	--Till Here
	CREATE TABLE #RptLoadSheetItemWise
	(
			[SalId]				  INT,
			[PrdId]        	      INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,----@
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0)	
	)
	
	SET @TblName = 'RptLoadSheetItemWise'
	
	SET @TblStruct = '
			[SalId]				  INT,		
			[PrdId]        	      INT,    	
			[Product Code]        VARCHAR (100),
			[Product Description] VARCHAR(200),
			[Batch Number]        VARCHAR(50),		
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0)'
	
	SET @TblFields = '	
			[SalId]
			[PrdId]        	      ,
			[Product Code]        ,
			[Product Description] ,
			[Batch Number],
			[MRP]				  ,
			[Selling Rate]
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],
			[PrdWeight],
			[GrossAmount],
			[TaxAmount],[NetAmount],[TotalBills]'
	
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
		IF @FromBillNo <> 0 AND @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
				[TaxAmount],[NetAmount])
	
			SELECT [SalId],PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) from RtrLoadSheetItemWise
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
			 AND (SalId Between @FromBillNo and @ToBillNo)
	GROUP BY [SalId],PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount]
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
					[TaxAmount],[NetAmount])
			
			SELECT [SalId],PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],GrossAmount,TaxAmount,dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) FROM RtrLoadSheetItemWise
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
			GROUP BY [SalId],PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight]
		END 
		
		UPDATE #RptLoadSheetItemWise SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWise)
	
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
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWise ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
	 + '         WHERE
	 RptId = ' + @Pi_RptId + ' and UsrId = ' + @Pi_UsrId + ' and
	  (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
	
	 AND (Allotmentnumber = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
	
	 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
	
	 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
	
	 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
					
	 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetItemWise'
	
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
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWise ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLoadSheetItemWise
	-- Till Here
	
	--SELECT * FROM #RptLoadSheetItemWise
-- 	SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],
-- 	SUM(LSB.[Billed Qty]) AS [Billed Qty],SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
-- 	SUM(LSB.[Replacement Qty]) AS [Replacement Qty],SUM(LSB.[Total Qty]) AS [Total Qty],
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
-- 	CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
-- 	CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece
-- 	FROM #RptLoadSheetItemWise LSB,Product P 
-- 	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
-- 	WHERE LSB.PrdId=P.PrdId
-- 	GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],UG.ConversionFactor
	SELECT LSB.[SalId],LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
	CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
	SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
	SUM(LSB.[Replacement Qty]) AS [Replacement Qty],
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
	CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece,
	SUM(LSB.[Total Qty]) AS [Total Qty],
	[PrdWeight],
	SUM(LSB.[Billed Qty]) AS [Billed Qty],
	LSB.GrossAmount AS GrossAmount,
	LSB.TaxAmount AS TaxAmount,
	SUM(LSB.NETAMOUNT) as NETAMOUNT,LSB.TotalBills
	FROM #RptLoadSheetItemWise LSB,Product P 
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
	WHERE LSB.PrdId=P.PrdId
	GROUP BY LSB.SalId,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor,
	LSB.[PrdWeight],LSB.GrossAmount,LSB.TaxAmount,LSB.TotalBills
	Order by LSB.[Product Description]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetItemWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetItemWise_Excel
		SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
		CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
		SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
		SUM(LSB.[Replacement Qty]) AS [Replacement Qty],
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
		CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece,
		SUM(LSB.[Total Qty]) AS [Total Qty],
		SUM(LSB.[Billed Qty]) AS [Billed Qty],
		SUM(NETAMOUNT) as NETAMOUNT
		INTO RptLoadSheetItemWise_Excel FROM #RptLoadSheetItemWise LSB,Product P 
		LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
		WHERE LSB.PrdId=P.PrdId
		GROUP BY LSB.SalId,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor
		Order by LSB.[Product Description]
	END
RETURN
--SELECT * FROM #RptLoadSheetItemWise
END
GO
DELETE FROM RptExcelHeaders WHERE RptId=18 
GO
INSERT INTO RptExcelHeaders
SELECT 18,1,'PrdId','PrdId',0,1
UNION 
SELECT 18,2,'Product Code','Product Code',0,1
UNION 
SELECT 18,3,'Product Description','Product Name',0,1
UNION 
SELECT 18,4,'Batch Number','Batch Code',1,1
UNION 
SELECT 18,5,'MRP','MRP',1,1
UNION 
SELECT 18,6,'Selling Rate','Selling Rate',1,1
UNION 
SELECT 18,7,'BillCase','Billed Qty in Selected UOM',1,1
UNION 
SELECT 18,8,'BillPiece','Billed Qty in Piece',1,1
UNION 
SELECT 18,9,'Free Qty','Free Qty',1,1
UNION 
SELECT 18,10,'Return Qty','Return Qty',1,1
UNION 
SELECT 18,11,'Replacement Qty','Replacement Qty',1,1
UNION 
SELECT 18,12,'TotalCase','Total Qty in Selected UOM',1,1
UNION 
SELECT 18,13,'TotalPiece','Total Qty in Piece',1,1
UNION 
SELECT 18,14,'Total Qty','Total Qty',0,1
UNION 
SELECT 18,15,'Billed Qty','Billed Qty',0,1
UNION 
SELECT 18,16,'NetAmount','Net Amount',1,1
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptPendingBillReport')
DROP PROCEDURE Proc_RptPendingBillReport
GO
--EXEC Proc_RptPendingBillReport 3,1,0,'CoreStockyTempReport',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptPendingBillReport]
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
	
	DECLARE @AsOnDate	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @PDCTypeId	 	AS	INT
	SELECT @AsOnDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @PDCTypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@AsOnDate,@AsOnDate)
	Create TABLE #RptPendingBillsDetails
	(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         		INT,
			RtrCode         NVARCHAR(50),
			RtrName 		NVARCHAR(50),	
			SalId         		BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate              DATETIME,
			DueDate              DATETIME,
			SalInvRef 		NVARCHAR(50),
			BillAmount      	NUMERIC (38,6),
			CashAmount			NUMERIC (38,6),
			ChequeAmount		NUMERIC (38,6),
			ChequeNumber		BigInt, 
			CollectedAmount 	NUMERIC (38,6),
			BalanceAmount   	NUMERIC (38,6),
			ArDays			INT
	)
	CREATE TABLE #TempReceiptInvoice
	(
		SalId		INT,
		InvInsSta	INT,
		InvInsAmt	NUMERIC(38,2)
	)
	
	SET @TblName = 'RptPendingBillsDetails'
	
	SET @TblStruct = '	SMId 			INT,
				SMName			NVARCHAR(50),
				RMId 			INT,
				RMName 			NVARCHAR(50),
				RtrId         		INT,
				RtrCode         NVARCHAR(50),
				RtrName 		NVARCHAR(50),	
				SalId         		BIGINT,
				SalInvNo 		NVARCHAR(50),
				SalInvDate              DATETIME,
				DueDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				BillAmount      	NUMERIC (38,6),
				CashAmount			NUMERIC (38,6),
				ChequeAmount		NUMERIC (38,6),
				ChequeNumber		BigInt, 
				CollectedAmount 	NUMERIC (38,6),
				BalanceAmount   	NUMERIC (38,6),
				ArDays			INT'
	
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,SalId,SalInvNo,
			  SalInvDate,DueDate,SalInvRef,BillAmount,CashAmount,ChequeAmount,ChequeNumber,CollectedAmount,
			  BalanceAmount,ArDays'
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
			IF @PDCTypeId=1 --Include PDC
			BEGIN
			
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrCode,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,DateAdd(d,SIC.CrDays,SI.SalinvDate) AS DueDate,
						SI.SalInvRef,SI.SalNetAmt,Cast(null as numeric(18,2))AS PaidAmt,0 AS CashAmount ,0 AS ChequeAmount,0 AS ChequeNumber,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SI.SalInvDate,GetDate()) AS ArDays
				 INTO #PendingBills1
				 FROM Salesinvoice  SI INNER JOIN Salesman S ON S.SMId = SI.SMId
					   INNER JOIN RouteMaster R ON SI.RMId = R.RMId 
					   INNER JOIN Retailer RE ON SI.RtrId = RE.RtrId
					   LEFT OUTER JOIN SalesInvoiceCrDays SIC ON Si.SalId=SIC.SalID	
				 WHERE  SI.DlvSts IN(4,5)
						AND SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(#PendingBills1.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				Update #PendingBills1
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills1
			END
			IF @PDCTypeId<>1 --Exclude PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrCode,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,DateAdd(d,SIC.CrDays,SI.SalinvDate) AS DueDate,
						SI.SalInvRef,SI.SalNetAmt,Cast(null as numeric(18,2))AS PaidAmt,0 AS CashAmount ,0 AS ChequeAmount,0 AS ChequeNumber,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SalInvDate,GetDate()) AS ArDays
				 Into #PendingBills
				
				 FROM Salesinvoice  SI INNER JOIN Salesman S ON S.SMId = SI.SMId
					  INNER JOIN RouteMaster R ON SI.RMId = R.RMId
					  INNER JOIN Retailer RE  ON SI.RtrId = RE.RtrId
					  LEFT OUTER JOIN SalesInvoiceCrDays SIC ON Si.SalId=SIC.SalID	
				 WHERE  SI.DlvSts IN (4,5)
						and SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(#PendingBills.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 AND InvInsDate<=CONVERT(DATETIME,@AsOnDate,103) and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				Update #PendingBills
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills
			END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR' +
				' SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '+
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR ' +
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR '+
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND SalInvDate<=''' + @AsOnDate + ''''
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptPendingBillsDetails'
	
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
		SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPendingBillsDetails
-- Till Here
--	SELECT * FROM #RptPendingBillsDetails ORDER BY SMId,SalId,ArDays,SalInvDate
	--Added by Thiru on 13/11/2009
	DELETE FROM #RptPendingBillsDetails WHERE (BillAmount-CollectedAmount)<=0
	SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptPendingBillsDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptPendingBillsDetails_Excel
		SELECT  * INTO RptPendingBillsDetails_Excel FROM #RptPendingBillsDetails
	END
	RETURN
END
GO
DELETE FROM RptExcelHeaders WHERE RptId=3
GO
INSERT INTO RptExcelHeaders
SELECT 3,1,'SMId','SMId',0,1
UNION 
SELECT 3,2,'SMName','Salesman',1,1
UNION 
SELECT 3,3,'RMId','RMId',1,1
UNION 
SELECT 3,4,'RMName','Route',1,1
UNION 
SELECT 3,5,'RtrId','RtrId',0,1
UNION 
SELECT 3,6,'RtrCode','Retailer Code',0,1
UNION 
SELECT 3,7,'RtrName','Retailer',1,1
UNION 
SELECT 3,8,'SalId','SalId',0,1
UNION 
SELECT 3,9,'SalInvNo','Bill Number',1,1
UNION 
SELECT 3,10,'SalInvDate','Bill Date',1,1
UNION 
SELECT 3,11,'DueDate','Due Date',1,1
UNION 
SELECT 3,12,'SalInvRef','Doc Ref No',0,1
UNION 
SELECT 3,13,'BillAmount','Bill Amount',1,1
UNION 
SELECT 3,14,'CashAmount','Cash Amount',1,1
UNION 
SELECT 3,15,'ChequeAmount','Cheque Amount',1,1
UNION 
SELECT 3,16,'Chequenumber','Cheque Number',1,1
UNION 
SELECT 3,17,'CollectedAmount','Collected Amount',1,1
UNION 
SELECT 3,18,'BalanceAmount','Balance Amount',1,1
UNION 
SELECT 3,19,'ArDays','AR Days',1,1
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptCollectionValue')
DROP TABLE RptCollectionValue
GO
CREATE TABLE [dbo].[RptCollectionValue](
	[SalId] [bigint] NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvRef] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[SMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvRcpDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RMId] [int] NULL,
	[RMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DlvRMId] [int] NULL,
	[DelRMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BillAmount] [numeric](38, 6) NULL,
	[CrAdjAmount] [numeric](38, 6) NULL,
	[DbAdjAmount] [numeric](38, 6) NULL,
	[CashDiscount] [numeric](38, 6) NULL,
	[CollectedAmount] [numeric](38, 6) NULL,
	[PayAmount] [numeric](38, 6) NULL,
	[CurPayAmount] [numeric](38, 6) NULL,
	[CollCashAmt] [numeric](38, 6) NULL,
	[CollChqAmt] [numeric](38, 6) NULL,
	[CollDDAmt] [numeric](38, 6) NULL,
	[CollRTGSAmt] [numeric](38, 6) NULL,
	[InvRcpNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	
	
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_CollectionValues')
DROP PROCEDURE Proc_CollectionValues
GO
--EXEC Proc_CollectionValues 1
CREATE PROCEDURE [dbo].[Proc_CollectionValues]
(
	@Pi_TypeId INT
)
/**********************************************************************************
* PROCEDURE		: Proc_CollectionValues
* PURPOSE		: To Display the Collection details
* CREATED		: MarySubashini.S
* CREATED DATE	: 01/06/2007
* NOTE			: General SP for Returning the Collection details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 01-09-2009	Thiruvengadam.L		CR changes
* 08-12-2009	Thiruvengadam.L		Cheque and DD are displayed in single column	
************************************************************************************/
AS
BEGIN	
SET NOCOUNT ON
	DECLARE @SalId AS BIGINT
	DECLARE @InvRcpDate AS DATETIME
	DECLARE @CrAdjAmount AS NUMERIC (38, 6)
	DECLARE @DbAdjAmount AS NUMERIC (38, 6)
	DECLARE @SalNetAmt AS NUMERIC (38, 6)
	DECLARE @CollectedAmount AS NUMERIC (38, 6)
	DECLARE @Count AS INT
	DECLARE @Prevamount AS NUMERIC (38, 6)
	DECLARE @CurPrevamount AS NUMERIC (38, 6)
	DECLARE @PrevSalId AS BIGINT
	DELETE FROM RptCollectionValue	
	
	INSERT INTO RptCollectionValue (SalId ,SalInvDate,SalInvNo,SalInvRef,
				SMId ,SMName,InvRcpDate,RtrId ,
				RtrName ,RMId ,RMName ,DlvRMId ,
				DelRMName ,BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollectedAmount,PayAmount,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo)
	SELECT SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,
	 SalNetAmt AS BillAmount,
	 SUM(CrAdjAmount) AS CrAdjAmount,SUM(DbAdjAmount) AS DbAdjAmount,
	 SUM(CashDiscount) AS CashDiscount,
	 SUM(CollectedAmount) AS CollectedAmount,
	 SUM(PayAmount) AS PayAmount, SUM(PayAmount) AS CurPayAmount,
	 SUM(CollCashAmt) AS CollCashAmt,SUM(CollChqAmt) AS CollChqAmt,SUM(CollDDAmt) AS CollDDAmt,SUM(CollRTGSAmt) AS CollRTGSAmt,InvRcpNo
	FROM(
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (1) --AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				SUM(RI.DebitAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (1) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
		    SUM(RI.SalInvAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,SUM(RI.DebitAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
					AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    SUM(RI.SalInvAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (4)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,SUM(RI.DebitAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (4) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    0 AS CollDDAmt,SUM(RI.SalInvAmt) AS  CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (8)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,SUM(RI.DebitAmt) AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (8) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			SUM(RI.SalInvAmt) AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=5 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				SUM(RI.DebitAmt) AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (5) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			SUM(RI.SalInvAmt) AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=6 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpMode,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,SUM(RI.SalInvAmt) AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=2 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,SUM(RI.DebitAmt) AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (2) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
--->Commented By Nanda to Remove On Account(Need to check thoroughly on Exccess Collections)
--	UNION
--		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,
--			RMD.RMName as DelRMName,0 AS CrAdjAmount,0 AS DbAdjAmount,
--			0 AS CashDiscount,0 AS SalNetAmt,
--			ISNULL(ROA.Amount,0) AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
--			0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
--		FROM ReceiptInvoice RI WITH (NOLOCK),
--			Receipt RE WITH (NOLOCK),
--			Retailer R WITH (NOLOCK),
--		        Salesman SM WITH (NOLOCK),
--			RouteMaster RM WITH (NOLOCK),
--			RouteMaster RMD WITH (NOLOCK),
--			RetailerOnAccount ROA WITH (NOLOCK),
--			SalesInvoice SI WITH (NOLOCK)
--		WHERE ROA.RtrId=R.RtrId AND SI.SMId=SM.SMId
--		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
--			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo
--			AND ROA.LastModDate=RE.InvRcpDate
--			AND ROA.TransactionType=0 AND ROA.OnAccType=0 AND ROA.RtrId=SI.RtrId
--		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--		 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
--		 ROA.Amount,RI.InvRcpNo
--->Till Here
			) A
	GROUP BY SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 	InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,SalNetAmt,InvRcpNo
	IF NOT EXISTS (SELECT SalId FROM RptCollectionValue WHERE SalId<>0)
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalId,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalId=B.SalId AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalId,A.InvRcpDate) A WHERE A.SalId=RptCollectionValue.SalId
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	ELSE
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalInvNo,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate) A WHERE A.SalInvNo=RptCollectionValue.SalInvNo
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	
--	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollectedAmount+CashDiscount+CrAdjAmount-DbAdjAmount-PayAmount) WHERE BillAmount>0
	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollCashAmt+CollChqAmt+CollDDAmt+CollRTGSAmt+CashDiscount+CrAdjAmount-DbAdjAmount) WHERE BillAmount>0

END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptCollectionReport')
DROP PROCEDURE Proc_RptCollectionReport
GO
--EXEC Proc_RptCollectionReport 4,1,0,'CoreStocky',0,0,1
 CREATE PROCEDURE [dbo].[Proc_RptCollectionReport]
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
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @DlvRId		AS  INT
	DECLARE @SColId		AS  INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @TypeId		AS	INT
	DECLARE @TotBillAmount	AS	NUMERIC(38,6)
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @DlvRId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	SET @SColId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))	
	IF @SColId=1
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (5,6)
	END
	ELSE
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (5,6)
	END 
	Create TABLE #RptCollectionDetail
	(
		SalId 			BIGINT,
		SalInvNo		NVARCHAR(50),
		SalInvDate              DATETIME,
		SalInvRef 		NVARCHAR(50),
		RtrId 			INT,
		RtrName                 NVARCHAR(50),
		BillAmount              NUMERIC (38,6),
		CrAdjAmount             NUMERIC (38,6),
		DbAdjAmount             NUMERIC (38,6),
		CashDiscount		NUMERIC (38,6),
		CollectedAmount         NUMERIC (38,6),
		BalanceAmount           NUMERIC (38,6),
		PayAmount           	NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		AmtStatus 			NVARCHAR(10),
		InvRcpDate			DATETIME,
		CurPayAmount        NUMERIC (38,6),
		CollCashAmt			NUMERIC (38,6),
		CollChqAmt			NUMERIC (38,6),
		CollDDAmt			NUMERIC (38,6),
		CollRTGSAmt			NUMERIC (38,6),
		[CashBill]			[numeric](38, 0) NULL,
		[ChequeBill]		[numeric](38, 0) NULL,
		[DDbill]			[numeric](38, 0) NULL,
		[RTGSBill]			[numeric](38, 0) NULL,
		[TotalBills]		[numeric](38, 0) NULL,		
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		
	)
	SET @TblName = 'RptCollectionDetail'
	SET @TblStruct = '	SalId 			BIGINT,
				SalInvNo		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				RtrId 			INT,
				RtrName                 NVARCHAR(50),
				BillAmount              NUMERIC (38,6),
				CrAdjAmount             NUMERIC (38,6),
				DbAdjAmount             NUMERIC (38,6),
				CashDiscount		NUMERIC (38,6),
				CollectedAmount         NUMERIC (38,6),
				BalanceAmount           NUMERIC (38,6),
				PayAmount           	NUMERIC (38,6),
				TotalBillAmount		NUMERIC (38,6),
				AmtStatus 		NVARCHAR(10),
				InvRcpDate		DATETIME,
				CurPayAmount           	NUMERIC (38,6),
				CollCashAmt NUMERIC (38,6),
				CollChqAmt NUMERIC (38,6),
				CollDDAmt  NUMERIC (38,6),
				CollRTGSAmt NUMERIC (38,6),
				[CashBill] [numeric](38, 0) NULL,
				[ChequeBill] [numeric](38, 0) NULL,
				[DDbill] [numeric](38, 0) NULL,
				[RTGSBill] [numeric](38, 0) NULL,
				[TotalBills]		[numeric](38, 0) NULL,
				InvRcpNo nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
				'
	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,[CashBill],[ChequeBill],[DDbill],[RTGSBill],[TotalBills],InvRcpNo'
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
	IF @TypeId=1 
	BEGIN
		EXEC Proc_CollectionValues 4
		
	END
	ELSE
	BEGIN	
		EXEC Proc_CollectionValues 1
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN 
		INSERT INTO #RptCollectionDetail (SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt
		,InvRcpNo)
		SELECT SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId))
		--dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)
		AS BalanceAmount,dbo.Fn_ConvertCurrency(PayAmount,@Pi_CurrencyId),0 AS TotalBillAmount,
		(	--Commented and Added by Thiru on 20/11/2009
--			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
--			THEN 'Db' 
--			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
--			THEN 'Cr' 
--			ELSE '' END
			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
			THEN 'Db' 
			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
			THEN 'Cr' 
			ELSE '' END
--Till Here
		) AS AmtStatus,
		R.InvRcpDate,dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollCashAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollChqAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollDDAmt,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),R.InvRcpNo
		FROM RptCollectionValue R
		WHERE (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
		SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 
		AND 
		(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
		RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
		AND
		(DlvRMId=(CASE @DlvRId WHEN 0 THEN DlvRMId ELSE 0 END) OR
		DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		AND 
		(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
		RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		(SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
		SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
		AND InvRcpDate BETWEEN @FromDate AND @ToDate 
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+  ' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '+
				'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@DlvRId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',35,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '+
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR ' +
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND INvRcpDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
	
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCollectionDetail'
				
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
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCollectionDetail
	-- Till Here
	
	CREATE TABLE #Tempbalance
	(
		Billamt numeric(18,4),
		CurPayAmt numeric(18,4),
		Balance numeric(18,4),
		RtrId int,
		Salesinvoice nvarchar(50),
		Receiptinvoice nvarchar(50)
	)
	DECLARE @BillAmount NUMERIC (38,6)
	DECLARE @CurPayAmount NUMERIC (38,6)
	DECLARE @BalanceAmount NUMERIC (38,6)
	DECLARE @InvRcpNo nvarchar(50)
	DECLARE @SalinvNo nvarchar(50)
	DECLARE @TempInvoiceRcpNo nvarchar(50)
	DECLARE @CurPayAmountbal NUMERIC (38,6)
	DECLARE @BalRtrId int
	DECLARE Cur_BalanceAmt CURSOR FOR
	SELECT BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	OPEN Cur_BalanceAmt
	FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT into #Tempbalance(BillAmt,CurPayAmt,RtrId,Salesinvoice,Receiptinvoice) VALUES (@BillAmount,@CurPayAmount,@BalRtrId,@SalinvNo,@InvRcpNo)
        SELECT @CurPayAmountbal=sum(CurPayAmt) FROM #Tempbalance WHERE RtrId=@BalRtrId AND Salesinvoice=@SalinvNo --AND Receiptinvoice=@InvRcpNo
        UPDATE #RptCollectionDetail SET BalanceAmount=BillAmount-@CurPayAmountbal WHERE CurPayAmount=@CurPayAmount
		AND SalInvNo=@SalinvNo AND InvRcpNo=@InvRcpNo AND RtrId=@BalRtrId
		FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	END
	CLOSE Cur_BalanceAmt
	DEALLOCATE Cur_BalanceAmt
	
	UPDATE #RptCollectionDetail SET  [CashBill]=(CASE WHEN CollCashAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [ChequeBill]=(CASE WHEN CollChqAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [DDbill]=(CASE WHEN CollDDAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [RTGSBill]=(CASE WHEN  CollRTGSAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [TotalBills]=(SELECT Count(Salid) FROM #RptCollectionDetail)
	
	SELECT SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,
	CashBill,Chequebill,DDBill,RTGSBill,InvRcpNo,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCollectionDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptCollectionDetail_Excel
		SELECT  SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
			BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
			ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,
			ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus INTO RptCollectionDetail_Excel FROM #RptCollectionDetail
	END

RETURN
END
GO
if not exists (select * from hotfixlog where fixid = 394)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(394,'D','2011-11-01',getdate(),1,'Core Stocky Service Pack 394')
GO
