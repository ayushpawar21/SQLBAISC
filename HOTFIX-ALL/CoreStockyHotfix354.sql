--[Stocky HotFix Version]=354
Delete from Versioncontrol where Hotfixid='354'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('354','2.0.0.5','D','2010-12-29','2010-12-29','2010-12-29',convert(varchar(11),getdate()),'Parle;Major:-;Minor:Changes and Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 354' ,'354'
GO

--SRF-Nanda-186-001

UPDATE RptDetails SET PrntId=10 WHERE RptId=50 AND SlNo=11
UPDATE RptDetails SET PrntId=5 WHERE RptId=205 AND SlNo=6

--SRF-Nanda-186-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_SchemePayout]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_SchemePayout]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Import_SchemePayout '<Root></Root>

CREATE   PROCEDURE [dbo].[Proc_Import_SchemePayout]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_SchemePayout
* PURPOSE		: To Insert the records from xml file in the Table Scheme Payout
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/12/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Cn2Cs_Prk_SchemePayout(DistCode,CmpSchCode,CmpRtrCode,CrDbType,CrDbNoteNo,
	CrDbDate,CrDbAmt,ResField1,ResField2,ResField3,DownLoadFlag)
	SELECT DistCode,CmpSchCode,CmpRtrCode,CrDbType,CrDbNoteNo,
	CrDbDate,CrDbAmt,ResField1,ResField2,ResField3,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2Cs_BandhanPayout',1)
	WITH (
				[DistCode]				NVARCHAR(50),
				[CmpSchCode]			NVARCHAR(200),
				[CmpRtrCode]			NVARCHAR(200),
				[CrDbType]				NVARCHAR(100),
				[CrDbNoteNo]			NVARCHAR(100),
				[CrDbDate]				DATETIME,
				[CrDbAmt]				NUMERIC(38,6),
				[ResField1]				NVARCHAR(100),
				[ResField2]				NVARCHAR(100),
				[ResField3]				NVARCHAR(100),
				[DownLoadFlag]			NVARCHAR(10)
	     ) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-186-003

if exists (select * from dbo.sysobjects where id = object_id(N'[RptReplacement_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptReplacement_Excel]
GO

CREATE TABLE [dbo].[RptReplacement_Excel]
(
	[RepRefNo] [nvarchar](50) NULL,
	[RepDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](50) NULL,
	[PrdId] [int] NULL,
	[PrdDcode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](50) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[UserStockType] [nvarchar](50) NULL,
	[RtnQty] [int] NULL,
	[RtnRate] [numeric](38, 6) NULL,
	[RtnAmount] [numeric](38, 6) NULL,
	[RPrdId] [int] NULL,
	[RPrdDcode] [nvarchar](50) NULL,
	[RPrdName] [nvarchar](50) NULL,
	[RPrdBatId] [int] NULL,
	[RPrdBatCode] [nvarchar](50) NULL,
	[RUserStockType] [nvarchar](50) NULL,
	[RepQty] [int] NULL,
	[RepRate] [numeric](38, 6) NULL,
	[RepAmount] [numeric](38, 6) NULL,
	[RValue] [numeric](38, 6) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-186-004

if exists (select * from dbo.sysobjects where id = object_id(N'[RptSalavageAll_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptSalavageAll_Excel]
GO

CREATE TABLE [dbo].[RptSalavageAll_Excel]
(
	[Reference Number] [nvarchar](20) NULL,
	[Salvage Date] [datetime] NULL,
	[LocationId] [int] NULL,
	[Location Name] [nvarchar](50) NULL,
	[DocRefNo] [nvarchar](20) NULL,
	[Product Code] [nvarchar](20) NULL,
	[Product Name] [nvarchar](100) NULL,
	[Product Batch Code] [nvarchar](50) NULL,
	[Qty] [numeric](38, 0) NULL,
	[Rate] [numeric](38, 6) NULL,
	[Amount] [numeric](38, 6) NULL,
	[Amount For Claim] [numeric](38, 6) NULL,
	[StkTypeId] [int] NULL,
	[StkType] [nvarchar](100) NULL,
	[ReasonId] [int] NULL,
	[Reason] [nvarchar](100) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-186-005

DELETE FROM RptExcelHeaders WHERE RptId=21

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','1','Reference Number','Ref. Number','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','2','Salvage Date','Date','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','3','LocationId','LocationId','0','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','4','Location Name','Location Name','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','5','DocRefNo','DocRefNo','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','6','Product Code','Product Code','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','7','Product Name','Product Name','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','8','Product Batch Code','Product Batch Code','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','9','Qty','Salvage Qty','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','10','Rate','Rate','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','11','Amount','Amount','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','12','Amount For Claim','Amount For Claim','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','13','StkTypeId','StkTypeId','0','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','14','StkType','StkType','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','15','ReasonId','ReasonId','0','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('21','16','Reason','Reason','1','1')

--SRF-Nanda-186-006

DELETE FROM RptExcelHeaders WHERE RptId=12

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','1','RepRefNo','Ref.Number','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','2','RepDate','Date','0','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','3','RtrId','RtrId','0','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','4','RtrName','Retailer Name','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','5','PrdId','PrdId','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','6','PrdDcode','Product Code','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','7','PrdName','Product Name','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','8','PrdBatId','PrdBatId','0','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','9','PrdBatCode','Batch Code','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','10','UserStockType','User Stock Type','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','11','RtnQty','Return Qty','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','12','RtnRate','Rate','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','13','RtnAmount','Return Amount','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','14','RPrdId','RPrdId','0','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','15','RPrdDcode','Product Code','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','16','RPrdName','Product Name','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','17','RPrdBatId','PrdBatId','0','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','18','RPrdBatCode','Batch Code','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','19','RUserStockType','User Stock Type','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','20','RepQty','Replacement Qty','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','21','RepRate','Replacement Rate','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','22','RepAmount','Replacement Amount','1','1')

INSERT INTO  RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('12','23','RValue','Replacement Value','1','1')

--SRF-Nanda-186-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptReplacement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptReplacement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptReplacement 12,2,0,'NVSuperStk',0,0,1,0

CREATE PROCEDURE [dbo].[Proc_RptReplacement]      
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
* PROCEDURE		: Proc_RptReplacement      
* PURPOSE		: To get the Replacement details for Report      
* CREATED		: Nandakumar R.G      
* CREATED DATE	: 30/07/2007      
* MODIFIED      
* DATE      AUTHOR     DESCRIPTION      
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
	  
	DECLARE @RtnCnt   AS INT      
	DECLARE @RepCnt   AS INT      
	DECLARE @RepRefNo AS  NVARCHAR(50)      
	  
	   
	--Filter Variable       
	DECLARE @RtrId          AS Int      
	DECLARE @FromDate         AS DATETIME      
	DECLARE @ToDate           AS DATETIME      
	--Till Here      
      
	--Assgin Value for the Filter Variable      
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))      
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)      
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)      
	--Till Here      
  
	Create TABLE #RptReplacement      
	(      
		RepRefNo             NVARCHAR(50),      
		RepDate              DATETIME,      
		RtrId                INT,      
		RtrName              NVARCHAR(50),      
		PrdId         INT,      
		PrdDcode       NVARCHAR(50),      
		PrdName        NVARCHAR(50),      
		PrdBatId             INT,      
		PrdBatCode        NVARCHAR(50),      
		UserStockType        NVARCHAR(50),      
		RtnQty               INT,      
		RtnRate              NUMERIC (38,6),      
		RtnAmount            NUMERIC (38,6),      
		RPrdId         INT,      
		RPrdDcode       NVARCHAR(50),      
		RPrdName        NVARCHAR(50),      
		RPrdBatId            INT,      
		RPrdBatCode    NVARCHAR(50),      
		RUserStockType       NVARCHAR(50),      
		RepQty               INT,      
		RepRate              NUMERIC (38,6),      
		RepAmount            NUMERIC (38,6),      
		RValue               NUMERIC (38,6)      
	)      
       
	SET @TblName = 'RptReplacement'      
	   
	SET @TblStruct = ' RepRefNo             NVARCHAR(50),      
			   RepDate              DATETIME,      
			   RtrId                INT,      
			   RtrName              NVARCHAR(50),      
			   PrdId         INT,      
			   PrdDcode       NVARCHAR(50),      
			   PrdName        NVARCHAR(50),      
			   PrdBatId             INT,      
			   PrdBatCode        NVARCHAR(50),      
			   UserStockType        NVARCHAR(50),      
			   RtnQty               INT,      
			   RtnRate              NUMERIC (38,6),      
			   RtnAmount            NUMERIC (38,6),      
			   RPrdId         INT,      
			   RPrdDcode       NVARCHAR(50),      
			   RPrdName        NVARCHAR(50),      
			   RPrdBatId            INT,      
			   RPrdBatCode    NVARCHAR(50),      
			   RUserStockType       NVARCHAR(50),      
			   RepQty               INT,      
			   RepRate              NUMERIC (38,6),      
			   RepAmount            NUMERIC (38,6),      
			   RValue               NUMERIC (38,6)'      
      
	SET @TblFields = 'RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,      
				   UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,      
				   RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue'      
	IF @Pi_GetFromSnap = 1      
	BEGIN      
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId      
		SET @DBNAME = @DBNAME      
	END      
	ELSE      
	BEGIN      
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3    SET @DBNAME = @PI_DBNAME + @DBNAME      
	END      
	  
	SET @Po_Errno = 0      
	   
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data      
	BEGIN      
      
		DECLARE Cur_Replacement      
		CURSOR FOR      
		SELECT RepRefNo FROM ReplacementHd WHERE RepDate BETWEEN @FromDate AND @ToDate      
		    
		OPEN Cur_Replacement      
		FETCH NEXT FROM Cur_Replacement      
		INTO @RepRefNo      
        
		WHILE @@FETCH_STATUS=0      
		BEGIN        

			SELECT Ret.RepRefNo,RH.RepDate,RH.RtrId,Rt.RtrName,Ret.SlNo,Ret.PrdId,Prd.PrdDcode,Prd.PrdName,Ret.PrdBatId,PrdBat.PrdBatCode,      
			Ret.StockTypeId,ST.UserStockType,ST.SystemStockType,Ret.RtnQty,Ret.SelRte,(Ret.Tax/Ret.RtnQty) AS Tax,Ret.RtnAmount      
			INTO #TempRtnDetails      
			FROM ReplacementIn Ret,Product Prd,ProductBatch PrdBat,StockType ST,ReplacementHd RH,Retailer Rt      
			WHERE Ret.PrdId=Prd.PrdId AND Ret.PrdBatId=PrdBat.PrdBatId AND Ret.StockTypeId=ST.StockTypeId AND      
			RH.RtrId=Rt.RtrId AND Ret.RepRefNo=RH.RepRefNo AND      
			(RH.RtrId=  (CASE @RtrId WHEN 0 THEN RH.RtrId ELSE 0 END ) OR      
			RH.RtrId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))      
			AND Ret.RepRefNo=@RepRefNo      


			SELECT Rep.RepRefNo,RH.RepDate,RH.RtrId,Rt.RtrName,Rep.SlNo AS RSlNo,Rep.PrdId AS RPrdId,Prd.PrdDcode AS RPrdDcode,Prd.PrdName AS RPrdName,Rep.PrdBatId AS RPrdBatId,PrdBat.PrdBatCode AS RPrdBatCode,      
			Rep.StockTypeId AS RStockTypeId,ST.UserStockType AS RUserStockType,ST.SystemStockType AS RSystemStockType,Rep.RepQty,Rep.SelRte AS RSelRte,(Rep.Tax/Rep.RepQty) AS RTax,Rep.RepAmount      
			INTO #TempRepDetails      
			FROM ReplacementOut Rep,Product Prd,ProductBatch PrdBat,StockType ST,ReplacementHd RH,Retailer Rt      
			WHERE Rep.PrdId=Prd.PrdId AND Rep.PrdBAtId=PrdBat.PrdBatId AND Rep.StockTypeId=ST.StockTypeId AND      
			RH.RtrId=Rt.RtrId AND Rep.RepRefNo=RH.RepRefNo AND      
			(RH.RtrId=  (CASE @RtrId WHEN 0 THEN RH.RtrId ELSE 0 END ) OR      
			RH.RtrId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))      
			AND Rep.RepRefNo=@RepRefNo      

       
			SELECT @RtnCnt=COUNT(*) FROM #TempRtnDetails      
			SELECT @RepCnt=COUNT(*) FROM #TempRepDetails         

			IF @RtnCnt<@RepCnt       
			BEGIN      
				INSERT INTO #RptReplacement(RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,      
				PrdName,PrdBatId,PrdBatCode,UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,      
				RPrdDcode,RPrdName,RPrdBatId,RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue)      
				SELECT Rpl.RepRefNo,Rpl.RepDate,Rpl.RtrId,Rpl.RtrName,ISNULL(Rtn.PrdId,0),ISNULL(Rtn.PrdDcode,''),      
				ISNULL(Rtn.PrdName,''),ISNULL(Rtn.PrdBatId,0),ISNULL(Rtn.PrdBatCode,''),ISNULL(Rtn.UserStockType,''),ISNULL(Rtn.RtnQty,0),      
				(ISNULL(Rtn.SelRte,0)+ISNULL(Rtn.Tax,0)) AS RtnRate,      
				Rtn.RtnAmount,Rpl.RPrdId,Rpl.RPrdDcode,Rpl.RPrdName,Rpl.RPrdBatId,Rpl.RPrdBatCode,      
				Rpl.RUserStockType,Rpl.RepQty,(Rpl.RSelRte+Rpl.RTax) AS RepRate,Rpl.RepAmount,      
				(ISNULL(Rtn.RtnAmount,0)-Rpl.RepAmount)AS RValue      
				FROM #TempRtnDetails Rtn       
				RIGHT OUTER JOIN #TempRepDetails Rpl ON Rtn.SlNo=Rpl.RSlNo AND       
				Rtn.RepRefNo=Rpl.RepRefNo      
			END      
			ELSE      
			BEGIN      
				INSERT INTO #RptReplacement(RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,      
				PrdName,PrdBatId,PrdBatCode,UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,      
				RPrdDcode,RPrdName,RPrdBatId,RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue)      
				SELECT Rtn.RepRefNo,Rtn.RepDate,Rtn.RtrId,Rtn.RtrName,Rtn.PrdId,Rtn.PrdDcode,      
				Rtn.PrdName,Rtn.PrdBatId,Rtn.PrdBatCode,Rtn.UserStockType,Rtn.RtnQty,      
				(Rtn.SelRte+Rtn.Tax) AS RtnRate,      
				Rtn.RtnAmount,ISNULL(Rpl.RPrdId,0),ISNULL(Rpl.RPrdDcode,''),ISNULL(Rpl.RPrdName,''),ISNULL(Rpl.RPrdBatId,0),ISNULL(Rpl.RPrdBatCode,''),      
				ISNULL(Rpl.RUserStockType,''),ISNULL(Rpl.RepQty,0),(ISNULL(Rpl.RSelRte,0)+ISNULL(Rpl.RTax,0)) AS RepRate,ISNULL(Rpl.RepAmount,0),      
				(Rtn.RtnAmount-ISNULL(Rpl.RepAmount,0))AS RValue      
				FROM #TempRtnDetails Rtn       
				LEFT OUTER JOIN #TempRepDetails Rpl ON Rtn.SlNo=Rpl.RSlNo AND       
				Rtn.RepRefNo=Rpl.RepRefNo      
			END        

			DROP TABLE #TempRtnDetails      
			DROP TABLE #TempRepDetails      

			FETCH NEXT FROM Cur_Replacement      
			INTO @RepRefNo      
		END      
      
		CLOSE Cur_Replacement      
		DEALLOCATE Cur_Replacement      
    
		IF LEN(@PurDBName) > 0      
		BEGIN      
			SET @SSQL = 'INSERT INTO #RptReplacement ' + '(' + @TblFields + ')' +      
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName      
			+' WHERE (RtrId=  (CASE '+CAST(@RtrId AS VARCHAR(10))+' WHEN 0 THEN RtrId ELSE 0 END ) OR      
			RtrId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters( '+CAST(@Pi_RptId AS VARCHAR(10))+',3,'+CAST(@Pi_UsrId AS VARCHAR(10))+')))      
			AND RepDate BETWEEN '+CAST(@FromDate AS VARCHAR(10))+' AND '+CAST(@ToDate AS VARCHAR(10))+''      

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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptReplacement'      

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
			SET @SSQL = 'INSERT INTO #RptReplacement ' +      
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptReplacement      

	--->Added By Nanda on 24/12/2010
	DELETE FROM RptReplacement_Excel
	INSERT INTO RptReplacement_Excel(RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,UserStockType,
	RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue)
	SELECT RepRefNo,RepDate,RtrId,RtrName,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,UserStockType,
	RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue FROM #RptReplacement
	--->Till Here
       
	-- SELECT * FROM #RptReplacement  CAST(RtnQty AS INT) CAST(RepQty AS INT)  

	-- Added on 25-Jun-2009
	SELECT RepRefNo,RepDate,RtrId,RtrName,A.PrdId,A.PrdDcode,PrdName,PrdBatId,      
	PrdBatCode,UserStockType,RtnQty,    
	---
	--Case When CAST(RtnQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As Uom1,
	--Case When (CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as Uom2,
	--Case When (CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	--(CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as Uom3,
	--Case When CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
	--CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as Uom4,
	---- Modified on 09-Jul-2009
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RtnQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(RtnQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(RtnQty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(RtnQty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(RtnQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(RtnQty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(RtnQty) AS INT) End			
		ELSE CAST(Sum(RtnQty) AS INT) END
	END as Uom4,
	--- Modified end here on 09-Jul-2009
	RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,    
	RPrdBatCode,RUserStockType,RepQty,    
	--Case When CAST(RepQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(RepQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As RepUom1,
	--Case When (CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as RepUom2,
	--Case When (CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	--(CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as RepUom3,
	--Case When CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
	--CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as RepUom4,    
	--- Modified  on 09-Jul-2009
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RepQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RepQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As RepUom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as RepUom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as RepUom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(RepQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(RepQty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(RepQty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(RepQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(RepQty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(RepQty) AS INT) End			
		ELSE CAST(Sum(RepQty) AS INT) END
	END as RepUom4,
	--- Modified end here on 09-Jul-2009
	RepRate,RepAmount,RValue  INTO #RptReplacementGrid
	FROM #RptReplacement A,View_ProdUOMDetails B WHERE a.PrdId=b.PrdId    
	GROUP BY RepRefNo,RepDate,RtrId,RtrName,A.PrdId,A.PrdDcode,PrdName,PrdBatId,      
	PrdBatCode,UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,    
	RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1

	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId  
	INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,C19,C20,C21,C22,C23,c24,c25,c26,Rptid,Usrid)  
	SELECT RepRefNo,RepDate,RtrName,PrdDcode,PrdName,PrdBatCode,UserStockType,RtnQty,Uom1,Uom2,Uom3,Uom4,RtnRate,RtnAmount,RPrdDcode,RPrdName,RPrdBatCode,RUserStockType,RepQty,RepUom1,RepUom2,RepUom3,RepUom4,RepRate,RepAmount,RValue,@Pi_RptId,@Pi_UsrId  
	FROM #RptReplacementGrid  
	--- End here 25-Jun-2009  
	-- Added on 20-Jun-2009    
	SELECT RepRefNo,RepDate,RtrId,RtrName,A.PrdId,A.PrdDcode,PrdName,PrdBatId,      
	PrdBatCode,UserStockType,RtnQty,    
	--Case When CAST(RtnQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As Uom1,    
	--Case When (CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as Uom2,    
	--Case When (CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then    
	--(CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as Uom3,    
	--Case When CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))  
	--*nullif(ConverisonFactor3,0))+(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then    
	--CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+    
	--(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + nullif(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as Uom4,    
	---- Modified on 09-Jul-2009
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RtnQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(RtnQty AS INT)-(((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RtnQty AS INT)-((CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RtnQty AS INT)-(CAST(RtnQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(RtnQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(RtnQty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(RtnQty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(RtnQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(RtnQty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(RtnQty) AS INT) End			
		ELSE CAST(Sum(RtnQty) AS INT) END
	END as Uom4,
	--- Modified end here on 09-Jul-2009
	RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,    
	RPrdBatCode,RUserStockType,RepQty,    
	--
	--Case When CAST(RepQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(RepQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As RepUom1,
	--Case When (CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as RepUom2,
	--Case When (CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	--(CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as RepUom3,
	--Case When CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
	--CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	--(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as RepUom4,    
	--- Modified  on 09-Jul-2009
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RepQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RepQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As RepUom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as RepUom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as RepUom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(RepQty AS INT)-(((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(RepQty AS INT)-((CAST(RepQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RepQty AS INT)-(CAST(RepQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(RepQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
						CAST(Sum(RepQty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(RepQty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(RepQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
						CAST(Sum(RepQty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(RepQty) AS INT) End			
		ELSE CAST(Sum(RepQty) AS INT) END
	END as RepUom4,
	--- Modified end here on 09-Jul-2009
	RepRate,RepAmount,RValue    
	FROM #RptReplacement A LEFT OUTER JOIN View_ProdUOMDetails B ON a.PrdId=b.PrdId    
	GROUP BY RepRefNo,RepDate,RtrId,RtrName,A.PrdId,A.PrdDcode,PrdName,PrdBatId,      
	PrdBatCode,UserStockType,RtnQty,RtnRate,RtnAmount,RPrdId,RPrdDcode,RPrdName,RPrdBatId,    
	RPrdBatCode,RUserStockType,RepQty,RepRate,RepAmount,RValue,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1
	-- End here      
	RETURN      
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-186-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSalvage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptSalvage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptSalvage 21,2,0,'',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptSalvage]
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
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @CmpId		   AS   INT
	DECLARE @LcnId	 	   AS	INT
	DECLARE @StkId	 	   AS	INT
	DECLARE @ReasonId	 	   AS	INT
	DECLARE @ReferenceId	   AS	NVarchar(100)
	--Till Here
	EXEC Proc_RptSalvageAll @Pi_RptId ,@Pi_UsrId
	
	--Assgin Value for the Filter Variable
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StkId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,164,@Pi_UsrId))
	SET @ReasonId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,159,@Pi_UsrId))
	SET @ReferenceId = (SELECT  TOP 1 sCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,199,@Pi_UsrId))
	--Till Here
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	--Till Here
	CREATE TABLE #RptSalvageAll
	(
	       [Reference Number] nVArchar(20),
	       [Salvage Date] datetime,
	       [LocationId] int,
	       [Location Name] nvarchar(50),
	       [DocRefNo] nvarchar(20),
	       [Product Code] nvarchar(20),
	       [Product Name] nvarchar(100),
	       [Product Batch Code] nvarchar(50),
	       [Qty] numeric(38,0),
	       [Rate] numeric(38,6),
	       [Amount] numeric(38,6),
	       [Amount For Claim] numeric(38,6),
	       [StkTypeId] int,
	       [StkType]nvarchar(100),
	       [ReasonId]int,
	       [Reason]nvarchar(100)
	)
	SET @TblName = 'RptSalageAll'
	
	SET @TblStruct = '       [Reference Number] nVArchar(20),
	       [Salvage Date] datetime,
	       [LocationId] int,
	       [Location Name] nvarchar(50),
	       [DocRefNo] nvarchar(20),
	       [Product Code] nvarchar(20),
	       [Product Name] nvarchar(100),
	       [Product Batch Code] nvarchar(50),
	       [Qty] numeric(38,0),
	       [Rate] numeric(38,6),
	       [Amount] numeric(38,6),
	       [Amount For Claim] numeric(38,6),
	       [StkTypeId] int,
	       [StkType]nvarchar(100),
	       [ReasonId]int,
	       [Reason]nvarchar(100)'
	
	SET @TblFields = '[Reference Number] ,[Salvage Date] ,
	       [LocationId] , [Location Name] ,
	       [DocRefNo] , [Product Code] ,
	       [Product Name] , [Product Batch Code] ,
	       [Qty] ,  [Rate] ,
	       [Amount] ,  [Amount For Claim] ,
	       [StkTypeId],
	       [StkType],
	       [ReasonId],
	       [Reason]'
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
		INSERT INTO #RptSalvageAll([Reference Number] ,[Salvage Date] ,
		[LocationId] , [Location Name] ,
		[DocRefNo] , [Product Code] ,
		[Product Name] , [Product Batch Code] ,
		[Qty] ,  [Rate] ,
		[Amount] ,  [Amount For Claim],[StkTypeId], [StkType],
		[ReasonId], [Reason])
		
		SELECT RefNo, SalvageDate, LcnId, LocationName, DocRefNo,
		PrdCode,PrdName,PrdBatCode,Qty,Rate,Amount,AmountForClaim,StockTypeId,UserStockType,ReasonId,Description
		FROM RptSalvageAll
		WHERE UsrId = @Pi_UsrId
		AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
		LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) )
		AND (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )		
		AND (StockTypeId = (CASE @StkId WHEN 0 THEN StockTypeId ELSE 0 END) OR
		StockTypeId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,164,@Pi_UsrId)) )		
		AND (ReasonId = (CASE @ReasonId WHEN 0 THEN ReasonId ELSE -1 END) OR
		ReasonId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,159,@Pi_UsrId)) )		
		AND (RefNo = (CASE @ReferenceId WHEN '0' THEN RefNo ELSE '0' END) OR
		RefNo in (SELECT sCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,199,@Pi_UsrId)) )
		AND [SalvageDate] Between @FromDate and @ToDate
			
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
			SET @SSQL = 'INSERT INTO #RptSalvageAll ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ 'WHERE
			UsrId = ' + @Pi_UsrId + ' and
			(LcnId=(CASE ' + @LcnId + ' WHEN 0 THEN LcnId ELSE 0 END) OR
			LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ' ,22,' + @Pi_UsrId + ')) )
			
			AND (CmpId = (CASE ' + @CmpId + ' WHEN 0 THEN CmpId ELSE 0 END) OR
			CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ' ,4, ' + @Pi_UsrId + ')) )
			
			AND SalvageDate Between ' + @FromDate + ' and ' + @ToDate
	
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSalvageAll'
				
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
			SET @SSQL = 'INSERT INTO #RptSalvageAll ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSalvageAll
	-- Till Here

	--->Added By Nanda on 23/12/2010 for Excel Reports
	DELETE FROM RptSalavageAll_Excel 	
	INSERT INTO RptSalavageAll_Excel ([Reference Number],[Salvage Date],[LocationId],[Location Name],[DocRefNo],[Product Code],
	[Product Name],[Product Batch Code],[Qty],[Rate],[Amount],[Amount For Claim],[StkTypeId],[StkType],[ReasonId],[Reason])
	SELECT [Reference Number],[Salvage Date],[LocationId],[Location Name],[DocRefNo],[Product Code],[Product Name],
	[Product Batch Code],[Qty],[Rate],[Amount],[Amount For Claim],[StkTypeId],[StkType],[ReasonId],[Reason] FROM #RptSalvageAll
	--->Till Here
	
	--Added on 16.06.2009
	-- CAST(Qty AS INT)
	--SELECT A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	--A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],
	--ISNULL(Cast(CAST(Qty AS INT)/NULLIF(ConverisonFactor2,0) AS Int),0)AS Uom1, --Cases
	--ISNULL(Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)/NULLIF(ConverisonFactor3,0),0) AS Uom2, --Boxes
	----ISNULL(Cast(((Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)/NULLIF(ConverisonFactor3,0))%NULLIF(ConverisonFactor3,0))/NULLIF(ConverisonFactor4,0) AS Int),0) AS Uom3, --Strips
	----CASE ISNULL(Cast(((Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)/NULLIF(ConverisonFactor3,0))%NULLIF(ConverisonFactor3,0))/NULLIF(ConverisonFactor4,0) AS Int),0)
	--ISNULL(Cast((Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)%NULLIF(ConverisonFactor3,0))/NULLIF(ConverisonFactor4,0) AS Int),0) AS Uom3, --Strips
	--CASE ISNULL(Cast((Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)%NULLIF(ConverisonFactor3,0))/NULLIF(ConverisonFactor4,0) AS Int),0)
	--
	--WHEN 0 THEN CASE ISNULL(Cast(CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0) AS Int)/NULLIF(ConverisonFactor3,0),0)
	--WHEN 0 THEN CASE ISNULL(Cast(CAST(Qty AS INT)/NULLIF(ConverisonFactor2,0) AS Int),0)
	--WHEN 0 THEN ISNULL(Qty,0) ELSE ISNULL((CAST(Qty AS INT)%NULLIF(ConverisonFactor2,0)) ,0) END
	--ELSE ISNULL((CAST(Qty AS INT)%NULLIF(ConverisonFactor4,0)),0) END
	--ELSE ISNULL((CAST(Qty AS INT)%NULLIF(ConverisonFactor4,0)),0) END AS Uom4,
	--A.Rate,A.Amount,A.[Amount For Claim],A.ReasonId,A.Reason
	--FROM #RptSalvageAll A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode ORDER BY A.[Reference Number]
	----	SELECT * FROM #RptSalvageAll
	--	SELECT [Reference Number],[Salvage Date],[LocationId],[Location Name],
	--	[DocRefNo],[StkTypeId],[StkType],[Product Code],[Product Name],[Product Batch Code],
	--	[Qty],[Rate],[Amount],[Amount For Claim],[ReasonId],[Reason]
	--	FROM #RptSalvageAll ORDER BY [Reference Number]
	-- Added on 20-Jun-2009  CAST(Qty AS INT)
	SELECT A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.Qty AS INT)>nullif(ConverisonFactor2,0) Then CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>Isnull(ConverisonFactor2,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(A.Qty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>Isnull(ConverisonFactor3,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(A.Qty) AS INT) End			
		ELSE CAST(Sum(A.Qty) AS INT) END
	END as Uom4,A.Rate,A.Amount,A.[Amount For Claim],A.ReasonId,A.Reason
	FROM #RptSalvageAll A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
	Group by A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,
	ConversionFactor1,Rate,Amount,A.[Amount For Claim],A.ReasonId,A.Reason
	ORDER BY A.[Reference Number]
	-- End Here
	--------- Added on 26-Jun-2009
	SELECT A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.Qty AS INT)>nullif(ConverisonFactor2,0) Then CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
	(CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
	CASE 
		WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
			Case When 
					CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
	CAST(A.Qty AS INT)-(((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
	(((CAST(A.Qty AS INT)-((CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Qty AS INT)-(CAST(A.Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
	ELSE
		CASE 
			WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>Isnull(ConverisonFactor2,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor2,0)
					Else CAST(Sum(A.Qty) AS INT) End
			WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
				Case
					When CAST(Sum(A.Qty) AS INT)>Isnull(ConverisonFactor3,0) Then
						CAST(Sum(A.Qty) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(A.Qty) AS INT) End			
		ELSE CAST(Sum(A.Qty) AS INT) END
	END as Uom4,
	A.Rate,A.Amount,A.[Amount For Claim],A.ReasonId,A.Reason INTO #RptSalvageAllGrid
	FROM #RptSalvageAll A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
	Group by A.[Reference Number],A.[Salvage Date],A.[LocationId],A.[Location Name],A.[DocRefNo],A.[StkTypeId],A.[StkType],
	A.[Product Code],A.[Product Name],A.[Product Batch Code],A.[Qty],ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,
	ConversionFactor1,Rate,Amount,A.[Amount For Claim],A.ReasonId,A.Reason
	ORDER BY A.[Reference Number]


	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
	INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,Rptid,Usrid)
	SELECT [Reference Number],[Salvage Date],[Location Name],[StkType],[Product Name],[Product Batch Code],[Qty],Uom1,Uom2,Uom3,Uom4,Rate,Amount,[Amount For Claim],Reason,@Pi_RptId,@Pi_UsrId
	FROM #RptSalvageAllGrid
	-- select * from RptColValues WHERE RptId=21 AND Usrid=1
	--- End here on 26-Jun-2009
	RETURN

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-186-009

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
BEGIN
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
		Description,
		Rate AS Amount1,
		PrdCCode,
		PrdBatCode AS Batch,
		RtnQty AS Quantity1,
		0 AS Quantity2 ,
		0 AS Amount2,
		0 AS Amount3,
		Amount,
		'N' AS UploadFlag
		FROM Company C WITH (NOLOCK)
		INNER JOIN ClaimSheetHd CM WITH (NOLOCK)
		ON CM.CmpID=C.CmpID
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON CD.ClmId=CM.ClmId AND CM.ClmGrpId= 6
		INNER JOIN ReturnToCompanyDt RH WITH (NOLOCK) ON RH.RtnCmpRefNo=CD.RefCode
		INNER JOIN ReasonMaster RM WITH (NOLOCK) ON RM.ReasonId=RH.ReasonId
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=RH.PrdId
		INNER JOIN ProductBatch PB WITH(NOLOCK) ON PB.PrdBatId=RH.PrdBatId
		INNER JOIN ReturnToCompany RC WITH(NOLOCK) ON RC.RtnCmpRefNo=RH.RtnCmpRefNo
		WHERE RC.Status=1 AND CD.Status=1 AND CM.Confirm=1 AND CM.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-186-010

UPDATE RPtDetails SET PrntId=2 WHERE RptId=153 AND SlNo=4

--SRF-Nanda-186-011

DELETE FROM RptExcelHeaders WHERE RptId=30

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(30,'1','RtrId','RtrId','0','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(30,'2','RtrCode','Retailer Code','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(30,'3','RtrName','Retailer Name','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(30,'4','DebitAmount','Debit Balance','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(30,'5','CreditAmount','Credit Balance','1','1')

INSERT RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(30,'6','NetAmount','Net Balance','1','1')

--SRF-Nanda-186-012

--SELECT * FROM [RptRetailerWiseVatTax_Excel]

DELETE FROM RptExcelHeaders WHERE RptId=26

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','1','CmpId','CmpId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','2','SMId','SMId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','3','RMId','RMId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','4','RtrId','RtrId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','5','RtrName','Retailer/Supplier Name','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','6','TINNumber','TIN Number','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','7','PrdId','PrdId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','8','PrdName','Product Name','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','9','Quantity','Quantity','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','10','GrossAmount','GrossAmount','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','11','INTax','InPut VAT%','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','12','OutTax','OutPut VAT%','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','13','INTaxableAmount','Taxable Amount','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','14','INTaxAmount','Tax Amount','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','15','OutTaxableAmount','Taxable Amount','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','16','OutTaxAmount','Tax Amount','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('26','17','TaxType','TaxType','0','1')

--SRF-Nanda-186-013

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetStockNSalesDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetStockNSalesDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM StockLedger  
--SELECT * FROM Product   
--Exec Proc_GetStockNSalesDetails '2010/01/01','2010/01/31',1  
--SELECT * FROM TempRptStockNSales WHERE PrdId=242  
CREATE PROCEDURE [dbo].[Proc_GetStockNSalesDetails]  
(  
	@Pi_FromDate   DATETIME,  
	@Pi_ToDate  DATETIME,  
	@Pi_UserId  INT  
)  
AS  
/*********************************  
* PROCEDURE : Proc_GetStockLedgerSummaryPrdwise  
* PURPOSE : To Get Stock Ledger Detail  
* CREATED : Nandakumar R.G  
* CREATED DATE : 12/02/2007  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
SET NOCOUNT ON  
BEGIN  
	DECLARE @Count BIGINT  
	DELETE FROM TempRptStockNSales WHERE UserId=@Pi_UserId  
	DECLARE @OpenClose TABLE  
	(  
		TransDate DATETIME,  
		PrdId INT,  
		PrdBatId INT,  
		LcnId INT,  
		SalOpenStock NUMERIC(38,0),  
		UnSalOpenStock NUMERIC(38,0),  
		OfferOpenStock NUMERIC(38,0),  
		SalClsStock NUMERIC(38,0),  
		UnSalClsStock NUMERIC(38,0),  
		OfferClsStock NUMERIC(38,0)  
	)  
	DECLARE @TempDate TABLE  
	(  
		TransDate DATETIME,  
		PrdId INT,  
		PrdBatId INT,  
		LcnId INT  
	)  
	INSERT INTO @TempDate  
	(  
		TransDate,  
		PrdId,  
		PrdBatId,  
		LcnId  
	)  
	SELECT MAX(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId  
	FROM Stockledger Sl WHERE  
	TransDate<=@Pi_ToDate  
	GROUP BY PrdId,PrdBatid,LcnId  
	--SELECT * FROM @TempDate  
	INSERT INTO @OpenClose  
	(  
		TransDate ,  
		PrdId ,  
		PrdBatId ,  
		LcnId ,  
		SalOpenStock ,  
		UnSalOpenStock ,  
		OfferOpenStock ,  
		SalClsStock ,  
		UnSalClsStock,  
		OfferClsStock  
	)  
	SELECT Stk.TransDate,Stk.LcnId,Stk.PrdId,Stk.PrdBatId,  
	Stk.SalOpenStock,Stk.UnSalOpenStock,Stk.OfferOpenStock,  
	Stk.SalClsStock,Stk.UnSalClsStock,Stk.OfferClsStock  
	From StockLedger Stk,@TempDate Dte  
	WHERE Stk.TransDate=Dte.TransDate AND Stk.PrdId=Dte.PrdId AND Stk.PrdBatId=Dte.PrdBatId AND Stk.LcnId=Dte.LcnId  
	-------Up to this to take max transdate with Closing Date--------  
	DECLARE @ProdDetail TABLE  
	(  
		LcnId INT,  
		PrdBatId INT,  
		TransDate DATETIME  
	)  
	DELETE FROM @ProdDetail  
	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT Stk.LcnId,Stk.PrdBatId,MAX(Stk.TransDate) FROM StockLedger Stk (nolock)  
	WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate AND  
	Stk.PrdBatId NOT IN 
	(  
		SELECT Stk.PrdBatId FROM StockLedger Stk (nolock)  
		WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate  
		GROUP BY Stk.PrdBatId  
	)  
	GROUP BY Stk.LcnId,Stk.PrdId,Stk.PrdBatId HAVING MAX(Stk.TransDate)<@Pi_FromDate  
	UNION  
	SELECT Stk.LcnId,Stk.PrdBatId,MAX(Stk.TransDate) FROM StockLedger Stk (nolock),  
	(  
		SELECT STK.LcnId,Stk.PrdBatId,  
		CAST(Stk.LcnId AS NVARCHAR(1000))+'-'+ CAST(Stk.PrdBatId AS NVARCHAR(10)) AS Col  
		FROM StockLedger Stk (nolock)  
		WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate  
		GROUP BY Stk.PrdBatId,STK.LcnId  
	) AS A  
	WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate  
	AND A.Col <>CAST(Stk.LcnId AS NVARCHAR(10))+'-'+CAST(Stk.PrdBatId AS NVARCHAR(10))  
	GROUP BY Stk.LcnId,Stk.PrdId,Stk.PrdBatId HAVING MAX(Stk.TransDate)>=@Pi_FromDate  
	 
	--DELETE FROM TempStockLedDet  
	--      Stocks for the given date---------  
	--select * from TempStockLedSummary  
	INSERT INTO TempRptStockNSales  
	(  
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,  
		Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,  
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,PurRetPurRte,SalRetPurRte,  
		CloPurRte,SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,  
		PurRetSelRte,SalRetSelRte,CloSelRte,MRP,  
		OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,  
		PurRetMRPRte,SalRetMRPRte,CloMRPRte,  
		BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock  
	)   
	SELECT @Pi_FromDate AS TransDate,Sl.LcnId AS LcnId,  
	Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,  
	-- (SUM(Sl.SalOpenStock)+SUM(Sl.UnSalOpenStock)) AS Opening,  
	0 AS Opening,  
	(SUM(Sl.SalPurchase)+SUM(Sl.UnsalPurchase))AS Purchase ,  
	(SUM(Sl.SalSales)+SUM(Sl.UnSalSales))AS Sales,  
	(SUM(Sl.SalStockIn)+SUM(Sl.UnSalStockIn)+SUM(Sl.DamageIn)+SUM(Sl.SalStkJurIn)  
	+SUM(Sl.UnSalStkJurIn)+SUM(Sl.SalBatTfrIn)+SUM(Sl.UnSalBatTfrIn)+  
	SUM(Sl.SalLcnTfrIn)+SUM(Sl.UnSalLcnTfrIn)) AS AdjustmentIn,  
	(SUM(Sl.SalStockOut)+SUM(Sl.UnSalStockOut)+SUM(Sl.DamageOut)+SUM(Sl.SalStkJurOut)  
	+SUM(Sl.UnSalStkJurOut)+SUM(Sl.SalBatTfrOut)+SUM(Sl.UnSalBatTfrOut)  
	+SUM(Sl.SalLcnTfrOut)+SUM(Sl.UnSalLcnTfrOut)  
	+SUM(Sl.SalReplacement)) AS AdjustmentOut,  
	(SUM(Sl.SalPurReturn)+SUM(Sl.UnSalPurReturn)) as PurchaseReturn,  
	(SUM(Sl.SalSalesReturn)+SUM(Sl.UnSalSalesReturn)) as SalesReturn,   
	(SUM(Sl.SalClsStock)+SUM(Sl.UnSalClsStock)) AS Closing,  
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0  
	FROM  
	Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)  
	WHERE Sl.PrdId = Prd.PrdId AND  
	Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  
	PrdBat.PrdBatId = Sl.PrdBatId AND  
	Lcn.LcnId = Sl.LcnId AND   
	Prd.PrdCtgValMainId=PCV.PrdCtgValMainId  
	GROUP BY Sl.LcnId,Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,PrdBat.BatchSeqId  
	--ORDER BY Sl.TransDate,Sl.PrdId,Sl.PrdBatId,Lcn.LcnId  
	ORDER BY Sl.PrdId,Sl.PrdBatId,Sl.LcnId

	UPDATE TempRptStockNSales  SET Closing=(OpCl.SalClsStock+OpCl.UnSalClsStock+OpCl.OfferClsStock)  
	FROM @OpenClose OpCl  
	WHERE TempRptStockNSales.PrdId=OpCl.PrdId AND TempRptStockNSales.PrdBatId=OpCl.PrdBatId AND TempRptStockNSales.LcnId=OpCl.LcnId  
	--- To get Opening Stock---------  
	DELETE FROM  @TempDate  
	DELETE FROM  @OpenClose  
	INSERT INTO @TempDate  
	(  
		TransDate,  
		PrdId,  
		PrdBatId,  
		LcnId  
	)  
	SELECT MAX(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId  
	FROM Stockledger Sl   
	WHERE TransDate<=@Pi_FromDate  
	GROUP BY PrdId,PrdBatid,LcnId  
	SET @Count=0   
	SELECT @Count=COUNT(*) FROM @TempDate  
	IF @Count=0  
	BEGIN  
	INSERT INTO @TempDate  
	(  
		TransDate,  
		PrdId,  
		PrdBatId,  
		LcnId  
	)  
	SELECT MIN(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId  
	FROM Stockledger Sl   
	WHERE TransDate<=@Pi_ToDate  
	GROUP BY PrdId,PrdBatid,LcnId  
	END  
	INSERT INTO @OpenClose  
	(  
		TransDate ,  
		PrdId ,  
		PrdBatId ,  
		LcnId ,  
		SalOpenStock ,  
		UnSalOpenStock ,  
		OfferOpenStock ,  
		SalClsStock ,  
		UnSalClsStock,  
		OfferClsStock  
	)  
	SELECT Stk.TransDate,Stk.PrdId,Stk.PrdBatId,Stk.LcnId,  
	Stk.SalOpenStock,Stk.UnSalOpenStock,Stk.OfferOpenStock,  
	Stk.SalClsStock,Stk.UnSalClsStock,Stk.OfferClsStock  
	FROM StockLedger Stk,@TempDate Dte  
	WHERE Stk.TransDate=Dte.TransDate AND Stk.PrdId=Dte.PrdId AND Stk.PrdBatId=Dte.PrdBatId AND Stk.LcnId=Dte.LcnId  
	UPDATE TempRptStockNSales  SET Opening=(OpCl.SalOpenStock+OpCl.UnSalOpenStock+OpCl.OfferOpenStock)  
	FROM @OpenClose OpCl  
	WHERE TempRptStockNSales.PrdId=OpCl.PrdId AND TempRptStockNSales.PrdBatId=OpCl.PrdBatId AND TempRptStockNSales.LcnId=OpCl.LcnId  
	-- Till here------------------  
	--      Stocks for those not included in the given date---------  
	INSERT INTO TempRptStockNSales  
	(  
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,  
		Purchase,Sales,AdjustmentIn,AdjustmentOut,SalesReturn,PurchaseReturn,Closing,  
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,SalRetPurRte,PurRetPurRte,CloPurRte,  
		SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,SalRetSelRte,PurRetSelRte,CloSelRte,  
		MRP,OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,SalRetMRPRte,PurRetMRPRte,CloMRPRte,  
		BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock  
	)     
	SELECT PrdDet.TransDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,  
	IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,  
	ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,  
	ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,  
	(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Opening,  
	0 AS Purchase,0 AS Sales,0 AS AdjustmentIn,0 as AdjustmentOut,  
	0 as SalesReturn,0 as PurchaseReturn,  
	(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Closing,  
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0  
	FROM  
	Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)  
	LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId   
	WHERE  
	Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate   
	AND Sl.TransDate< @Pi_FromDate  
	AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId  
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PrdDet.LcnId=Sl.LcnId  
	--      Stocks for those not included in the stockLedger---------  
	INSERT INTO TempRptStockNSales  
	(  
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,  
		Purchase,Sales,Adjustmentin,AdjustmentOut,SalesReturn,PurchaseReturn,Closing,  
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,SalRetPurRte,PurRetPurRte,CloPurRte,  
		SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,SalRetSelRte,PurRetSelRte,CloSelRte,  
		MRP,OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,SalRetMRPRte,PurRetMRPRte,CloMRPRte,  
		BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock  
	)     
	SELECT @Pi_FromDate AS TransDate,Lcn.LcnId,  
	Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,Prd.PrdName,PrdBat.PrdBatId,  
	PrdBat.PrdBatCode,0 AS Opening,0 AS Purchase,0 AS Sales,0 AS AdjustmentIn,0 as AdjustmentOut,  
	0 AS PurchaseReturn,0 AS SalesReturn,0 AS Closing,  
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0  
	FROM  
	ProductBatch PrdBat (NOLOCK),ProductCategoryValue PCV (NOLOCK),Product Prd (NOLOCK)  
	CROSS JOIN Location Lcn (NOLOCK)  
	WHERE  
	PrdBat.PrdBatId IN  
	(  
		SELECT PrdBatId FROM 
		(  
			SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM  
			ProductBatch A (NOLOCK) LEFT OUTER JOIN StockLedger B (NOLOCK)  
			ON A.PrdId =B.PrdId
		) a  
		WHERE ISNULL(NewPrdBatId,0) = 0  
	)  
	AND PrdBat.PrdId=Prd.PrdId  
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId  
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,  
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,PrdBat.BatchSeqId  
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId  
	UPDATE TempRptStockNSales SET Closing=(Opening+Purchase-Sales+AdjustmentIn-AdjustmentOut+SalesReturn-PurchaseReturn)  
	UPDATE TempRptStockNSales SET TotalStock=Closing  
	UPDATE TempRptStockNSales SET TempRptStockNSales.PurchaseRate=PrdBatDet.PrdBatDetailValue  
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,  
	BatchCreation BatCr,Product Prd  
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo  
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId  
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND TempRptStockNSales.PrdId=PrdBat.PrdId  
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND PrdBat.PrdId=TempRptStockNSales.PrdID  
	AND PrdBat.PrdId=Prd.PrdID  
	AND BatCr.ListPrice=1  
	UPDATE TempRptStockNSales SET TempRptStockNSales.SellingRate=PrdBatDet.PrdBatDetailValue  
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,  
	BatchCreation BatCr,Product Prd  
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo  
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId  
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND TempRptStockNSales.PrdId=PrdBat.PrdId  
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND PrdBat.PrdId=TempRptStockNSales.PrdID  
	AND PrdBat.PrdId=Prd.PrdID  
	AND BatCr.SelRte=1  
	UPDATE TempRptStockNSales SET TempRptStockNSales.MRP=PrdBatDet.PrdBatDetailValue  
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,  
	BatchCreation BatCr,Product Prd  
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo  
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId  
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND TempRptStockNSales.PrdId=PrdBat.PrdId  
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND PrdBat.PrdId=TempRptStockNSales.PrdID  
	AND PrdBat.PrdId=Prd.PrdID  
	AND BatCr.MRP=1  
	UPDATE TempRptStockNSales  
	SET OpnPurRte=Opening * (PurchaseRate+  ISNULL(PurchaseTaxAmount,0)) ,PurPurRte=Purchase * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	SalPurRte=Sales * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),AdjInPurRte=AdjustmentIn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	AdjOutPurRte=AdjustmentOut * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	SalRetPurRte=SalesReturn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),PurRetPurRte=PurchaseReturn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	CloPurRte=Closing * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	OpnSelRte=Opening * (SellingRate+ISNULL(SellingTaxAmount,0)),PurSelRte=Purchase * (SellingRate+ISNULL(SellingTaxAmount,0)),  
	SalSelRte=Sales * (SellingRate+ISNULL(SellingTaxAmount,0)),  
	AdjInSelRte=AdjustmentIn * (SellingRate+ISNULL(SellingTaxAmount,0)),AdjOutSelRte=AdjustmentOut * (SellingRate+ISNULL(SellingTaxAmount,0)),  
	SalRetSelRte=SalesReturn * (SellingRate+ISNULL(SellingTaxAmount,0)),PurRetSelRte=PurchaseReturn * (SellingRate+ISNULL(SellingTaxAmount,0))  
	,CloSelRte=Closing * (SellingRate+ISNULL(SellingTaxAmount,0)),  
	OpnMRPRte=Opening * MRP,PurMRPRte=Purchase * MRP,SalMRPRte=Sales * MRP,  
	AdjInMRPRte=AdjustmentIn * MRP,AdjOutMRPRte=AdjustmentOut * MRP,  
	SalRetMRPRte=SalesReturn * MRP,PurRetMRPRte=PurchaseReturn * MRP  
	,CloMRPRte=Closing * MRP  
	From  TempRptStockNSales TRS LEFT OUTER JOIN TaxForReport Tax ON TRS.PrdId = Tax.PrdId and TRS.PrdBatid = Tax.PrdBatid and  
	TRS.UserId = Tax.UsrId AND Tax.RptId=7  
END  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-186-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_SchemeUtilizationDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_SchemeUtilizationDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_SchemeUtilizationDetails 0
SELECT * FROM Cs2Cn_Prk_SchemeUtilizationDetails
--SELECT * FROM SalesInvoiceSchemeLineWise
ROLLBACK TRANSACTION
*/
CREATE    PROCEDURE [dbo].[Proc_Cs2Cn_SchemeUtilizationDetails]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_SchemeUtilizationDetails
* PURPOSE		: To Extract Scheme Utilization Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 19/10/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @ChkSRDate	AS DATETIME
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 1
	SELECT @ChkSRDate = NextUpDate FROM DayEndProcess Where ProcId = 4
	--->Billing-Scheme Amount
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,(ISNULL(SUM(FlatAmount),0)+ISNULL(SUM(DiscountPerAmount),0)) As Utilized,		
	A.DiscPer,'','',0,'N'
	FROM SalesInvoiceSchemeLineWise A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId = B.SalId AND A.SalId=SIP.SalId AND SIP.PrdId=A.PrdID AND SIP.PrdBatId=A.PrdBatId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0 AND (FlatAmount+DiscountPerAmount)>0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,A.DiscPer
	--->Billing-Free Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','Free Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Free Product','',0,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0) As Utilized,0,
	P.PrdCCode,C.PrdBatCode,SUM(FreeQty) as FreeQty,'N'
	FROM SalesInvoiceSchemeDtFreePrd A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.FreePrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode
	
	--->Billing-Gift Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','Gift Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Gift Product','',0,ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0) As Utilized,0,
	P.PrdCCode,C.PrdBatCode,SUM(GiftQty) as GiftQty,'N'
	FROM SalesInvoiceSchemeDtFreePrd A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.GiftPrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode
	--->Billing-Window Display
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','WDS',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	0,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(AdjAmt),0) As Utilized,0,
	'','',0,'N'
	FROM SalesInvoiceWindowDisplay A
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0--B.SalInvDate >= @ChkDate
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode
	
	--->Billing-QPS Credit Note Conversion
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','QPS Converted Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(A.CrNoteAmount),0) As Utilized,0,
	'','',0,'N'
	FROM SalesInvoiceQPSSchemeAdj A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId AND Mode=1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode
	UNION ALL
	SELECT @DistCode,'Billing','QPS Converted Amount(Auto)',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,'AutoQPSConversion' AS SalInvNo,A.LastModDate,A.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(A.CrNoteAmount),0) As Utilized,0,
	'','',0,'N'
	FROM SalesInvoiceQPSSchemeAdj A 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId AND Mode=2
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Retailer R ON R.RtrId = A.RtrId
	WHERE CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,A.LastModDate,
	A.RtrId,R.CmpRtrCode,R.RtrCode
	--->Cheque Disbursal
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Cheque Disbursal','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	0,B.ChqDisRefNo,A.ChqDisDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(Amount),0) As Utilized,0,
	'','',0,'N'
	FROM ChequeDisbursalMaster A
	INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo
	INNER JOIN SchemeMaster SM ON A.TransId = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE TransType = 1 AND CM.CmpID = @CmpID AND A.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,B.ChqDisRefNo,A.ChqDisDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode
	--->Sales Return-Amount
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,-1 * (ISNULL(SUM(ReturnFlatAmount),0) + ISNULL(SUM(ReturnDiscountPerAmount),0)),0,	
	'','',0,'N'
	FROM ReturnSchemeLineDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN ReturnProduct SIP ON SIP.ReturnId = B.ReturnId AND A.ReturnId=SIP.ReturnId AND SIP.PrdId=A.PrdId AND SIP.PrdBatId=A.PrdBatId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty
	--->Sales Return-Free Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Free Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Free Product','',0,-1 * ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0),0,
	P.PrdCCode,C.PrdBatCode,-1 * SUM(ReturnFreeQty),'N'
	FROM ReturnSchemeFreePrdDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.FreePrdId = P.PrdId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode
	--->Sales Return-Gift Product
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Gift Product',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'Gift Product','',0,-1 * ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0),0,
	P.PrdCCode,C.PrdBatCode,-1 * SUM(ReturnGiftQty),'N'
	FROM ReturnSchemeFreePrdDt A 
	INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
	INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
	INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Product P ON A.GiftPrdId = P.PrdId 
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	WHERE B.Status = 0 AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.ReturnCode,B.ReturnDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,C.PrdBatCode

	SELECT SchId INTO #SchId FROM SchemeMaster WHERE SchCode IN (SELECT SchCode FROM Cs2Cn_Prk_SchemeUtilizationDetails
	WHERE UploadFlag='N')

	UPDATE SalesInvoice SET SchemeUpLoad=1 WHERE SalId IN (SELECT DISTINCT SalId FROM
	SalesInvoiceSchemeHd WHERE SchId IN (SELECT SchId FROM #SchId)) AND DlvSts IN (4,5)
	AND SalInvNo IN (SELECT TransNo FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE TransName='Billing')

	UPDATE SalesInvoice SET SchemeUpLoad=1 WHERE SalId IN (SELECT DISTINCT SalId FROM
	SalesInvoiceWindowDisplay WHERE SchId IN (SELECT SchId FROM #SchId)) AND DlvSts IN (4,5)
	AND SalInvNo IN (SELECT TransNo FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE TransName='Billing')
	
	UPDATE SalesInvoiceQPSSchemeAdj SET Upload=1
	WHERE SalId IN (SELECT SalId FROM SalesInvoice WHERE SchemeUpload=1) AND Mode=1

	UPDATE SalesInvoiceQPSSchemeAdj SET Upload=1
	WHERE SalId = -1000 AND Mode=2

	UPDATE ReturnHeader SET SchemeUpLoad=1 WHERE ReturnId IN (SELECT DISTINCT ReturnId FROM (
	SELECT ReturnId FROM ReturnSchemeFreePrdDt WHERE SchId IN (SELECT SchId FROM #SchId)
	UNION
	SELECT ReturnId FROM ReturnSchemeLineDt WHERE SchId IN (SELECT SchId FROM #SchId))A) AND Status=0
	AND ReturnCode IN (SELECT TransNo FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE TransName='Sales Return')

	UPDATE ChequeDisbursalMaster SET SchemeUpLoad=1 WHERE ChqDisRefNo IN (SELECT DISTINCT ChqDisRefNo FROM
	ChequeDisbursalDetails WHERE TransId IN (SELECT SchId AS TransId FROM #SchId))
	AND TransType = 1 
	AND ChqDisRefNo IN (SELECT TransNo FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE TransName='Cheque Disbursal')
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-186-015

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApportionSchemeAmountInLine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApportionSchemeAmountInLine]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--DELETE FROM ApportionSchemeDetails 
--DELETE FROM BilledPrdHdForQPSScheme
--DELETE FROM BilledPrdHdForScheme
--DELETE FROM BillAppliedSchemeHd
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
--SELECT * FROM BillQPSSchemeAdj(NOLOCK)
DELETE FROM ApportionSchemeDetails
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 2,2
SELECT * FROM ApportionSchemeDetails WHERE TransId=2
SELECT * FROM BillQPSSchemeAdj 
--SELECT * FROM TP
--SELECT * FROM TG
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_ApportionSchemeAmountInLine]
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT
)
AS
/*********************************
* PROCEDURE		: Proc_ApportionSchemeAmountInLine
* PURPOSE		: To Apportion the Scheme amount line wise
* CREATED		: Thrinath
* CREATED DATE	: 25/04/2007
* NOTE			: General SP for Returning Scheme amount line wise
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}       {developer}        {brief modification description}
* 28/04/2009    Nandakumar R.G    Modified for Discount Calculation on MRP with Tax
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchId   INT
	DECLARE @SlabId  INT
	DECLARE @RefCode nVarChar(10)
	DECLARE @RtrId  INT
	DECLARE @PrdCnt  INT
	DECLARE @PrdBatCnt INT
	DECLARE @PrdId  INT
	DECLARE @MRP  INT
	DECLARE @WithTax INT
	DECLARE @BillSeqId  INT
	DECLARE @QPS  INT
	DECLARE @QPSDateQty  INT
	DECLARE @Combi  INT
	--NNN
	DECLARE @RtrQPSId  INT
	DECLARE @TempSchGross TABLE
	(
		SchId   INT,
		GrossAmount  NUMERIC(38,6),
		QPSGrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6),
		QPSGrossAmount  NUMERIC(38,6)
	)
	DECLARE @FreeQtyDt TABLE
	(
		FreePrdid  INT,
		FreePrdBatId  INT,
		FreeQty   INT
	)
	DECLARE @FreeQtyRow TABLE
	(
		RowId   INT,
		PrdId   INT,
		PrdBatId  INT
	)
	DECLARE @PDSchID TABLE
	(
		PrdId   INT,
		PrdBatId  INT,
		PDSchId   INT,
		PDSlabId  INT
	)
	DECLARE @SchFlatAmt TABLE
	(
		SchId  INT,
		SlabId  INT,
		FlatAmt  NUMERIC(18,6),
		DiscPer  NUMERIC(18,6),
		SchType  INT
	)
	DECLARE @MoreBatch TABLE
	(
		SchId  INT,
		SlabId  INT,
		PrdId  INT,
		PrdCnt  INT,
		PrdBatCnt INT,
		SchType  INT
	)
	DECLARE @QPSGivenDisc TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @RtrQPSIds TABLE
	(
		RtrId   INT,		
		SchId   INT
	)
	DECLARE @QPSNowAvailable TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)	
	
	--NNN
	SELECT @RtrQPSId=RtrId FROM BilledPrdHdForQPSScheme WHERE TransId= @Pi_TransId AND UsrId=@Pi_UsrId
	if exists (select * from dbo.sysobjects where id = object_id(N'TP') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TP
	if exists (select * from dbo.sysobjects where id = object_id(N'TG') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TG
	if exists (select * from dbo.sysobjects where id = object_id(N'TPQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TPQ
	if exists (select * from dbo.sysobjects where id = object_id(N'TGQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TGQ
	if exists (select * from dbo.sysobjects where id = object_id(N'SchMaxSlab') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table SchMaxSlab

	SET @RtrId = (SELECT TOP 1 RtrId FROM BilledPrdHdForScheme WHERE TransID = @Pi_TransId
	AND UsrId = @Pi_Usrid)
	DECLARE  CurSchid CURSOR FOR
	SELECT DISTINCT Schid,SlabId FROM BillAppliedSchemeHd WHERE IsSelected = 1
	AND TransID = @Pi_TransId AND UsrId = @Pi_Usrid
	OPEN CurSchid
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @QPS =QPS,@Combi=CombiSch,@QPSDateQty=ApyQPSSch	FROM SchemeMaster WHERE Schid=@SchId	
		SELECT @MRP=ApplyOnMRPSelRte,@WithTax=ApplyOnTax FROM SchemeMaster WHERE --MasterType=2 AND
		SchId=@SchId
		
		IF NOT EXISTS(SELECT * FROM @TempSchGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 --OR (@Combi=1 AND @QPS=1)
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF  @QPS<>0 --AND @Combi=0
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 --OR (@Combi=1 AND @QPS=1)
			BEGIN			
				--SELECT @SchId,@MRP,@WithTax,@SlabId	
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 --AND @Combi=0
			BEGIN
--				IF @QPSDateQty=2 
--				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount,0 FROM BilledPrdHdForQPSScheme A
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount,0 FROM BilledPrdHdForQPSScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
					--NNN

					IF @QPSDateQty=2 
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross TPGS,BilledPrdHdForQPSScheme BP
						WHERE TPGS.PrdId=BP.PrdId AND TPGS.PrdBatId=BP.PrdBatId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND BP.RowId<>10000
						AND TPGS.SchId=BP.SchId
--						SELECT 'S',* FROM @TempPrdGross
--						UPDATE TPGS SET TPGS.RowId=BP.RowId
--						FROM @TempPrdGross  TPGS,
--						(
--							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
--							GROUP BY SchId
--						) AS BP
--						WHERE TPGS.SchId=BP.SchId
--						SELECT 'NS',SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
--						GROUP BY SchID
						
						UPDATE C SET C.GrossAmount=C.GrossAmount+A.OtherGross
						FROM @TempPrdGross C,
						(SELECT SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
						GROUP BY SchID) A,
						(SELECT SchId,ISNULL(MIN(RowId),2)  AS RowId FROM @TempPrdGross WHERE RowId<>10000 
						GROUP BY SchId) B
						WHERE A.SchId=B.SchId AND B.SchId=C.SchId AND B.RowId=C.RowId
						DELETE FROM @TempPrdGross WHERE RowId=10000
--						SELECT 'S',* FROM @TempPrdGross
					END
					ELSE
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,
						(
							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
							WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
							GROUP BY SchId
						) AS BP
						WHERE TPGS.SchId=BP.SchId --AND TPGS.PrdBatId=BP.PrdBatId
					END	
					---
--				END
--				ELSE
--				BEGIN
--					SELECT 'NNN'
--					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					LEFT JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
--					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=0					
--					UNION ALL
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
--				END
			END
		END
		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
		COUNT(DISTINCT PrdBatId),SchType FROM BillAppliedSchemeHd
		WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId,SchType
		HAVING COUNT(DISTINCT PrdBatId)> 1
		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@SchId AND SlabId=@SlabId)
		BEGIN
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,0 FROM SchemeSlabs
			WHERE SchId=@SchId AND SlabId=@SlabId
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,1 FROM SchemeAnotherPrdDt
			WHERE SchId=@SchId AND SlabId=@SlabId
		END
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	END
	CLOSE CurSchid
	DEALLOCATE CurSchid
	----->
	SELECT DISTINCT * INTO TG FROM @TempSchGross
	SELECT DISTINCT * INTO TP FROM @TempPrdGross
	DELETE FROM @TempPrdGross
	
	INSERT INTO @TempPrdGross
	SELECT * FROM TP 
	
	---->For Scheme on Another Product QPS	
	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
	@TempSchGross TSG1,SchemeMaster SM ,SchemeAnotherPrdHd SMA
	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId AND SM.SchId=SMA.SchId
	----->	

	--->2010/12/03
	SELECT * FROM @TempPrdGross
	SELECT * FROM BilledPrdHdForQPSScheme

	UPDATE T1 SET QPSGrossAmount=A.GrossAmount
	FROM @TempPrdGross T1,BilledPrdHdForQPSScheme A
	WHERE T1.RowId=A.RowID AND T1.PrdId=A.PrdId AND T1.PrdBatId=A.PrdBatId AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	AND A.QPSPrd=0 AND A.SchId=T1.SchId 

	UPDATE S1 SET S1.QPSGrossAmount=A.QPSGross	
	FROM @TempSchGross S1,(SELECT SchId,SUM(QPSGrossAmount) AS QPSGross FROM @TempPrdGross GROUP BY SchId) AS A
	WHERE A.SchId=S1.SchId
	--->


	--->Commented By Nanda on 13/10/2010
--	DECLARE  CurMoreBatch CURSOR FOR
--	SELECT DISTINCT Schid,SlabId,PrdId,PrdCnt,PrdBatCnt FROM @MoreBatch
--	OPEN CurMoreBatch
--	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
--	WHILE @@FETCH_STATUS = 0
--	BEGIN
--		IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
--			AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
--		BEGIN
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
--			PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=0
--
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
--			PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=1
--		END		
--		ELSE
--		BEGIN
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=0
--			AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
--			PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchId=@SchId AND SlabId=@SlabId
--			AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=0)
--
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=1
--			AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
--			PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchId=@SchId AND SlabId=@SlabId
--			AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=1)
--		END
--
--		UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
--		FROM @TempPrdGross A
--		INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
--		INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
--		WHERE (B.SchemeAmount)>0 AND B.PrdId=@PrdId  AND B.SchType=0
--		AND B.PrdBatId IN
--		(SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
--		AND PrdId=@PrdId AND  IsSelected = 1 AND (SchemeAmount)>0 AND SchType=0 )
--
--		UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
--		FROM @TempPrdGross A
--		INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
--		INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
--		WHERE B.SchemeAmount>0 AND B.PrdId=@PrdId  AND B.SchType=1
--		AND B.PrdBatId IN
--		(SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
--		AND PrdId=@PrdId AND  IsSelected = 1 AND SchemeAmount>0 AND SchType=1 )
--		
--	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
--	END
--	CLOSE CurMoreBatch
--	DEALLOCATE CurMoreBatch
	--->Till Here

	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1
		INSERT INTO @PDSchID (PrdId,PrdBatId,PDSchId,PDSlabId)
		SELECT SP.PrdId,SP.PrdBatId,BAS.SchId AS PDSchId,MIN(BAS.SlabId) AS PDSlabId
		FROM @TempPrdGross SP
		INNER JOIN BillAppliedSchemeHd BAS ON SP.SchId=BAS.SchId AND SchemeDiscount>0
		INNER JOIN (SELECT DISTINCT SP1.PrdId,SP1.PrdBatId,MIN(BAS1.SchId) AS MinSchId
		FROM BillAppliedSchemeHd BAS1,@TempPrdGross SP1
		WHERE SP1.SchId=BAS1.SchId
		AND SchemeDiscount >0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
		GROUP BY SP1.PrdId,SP1.PrdBatId) AS A ON A.MinSchId=BAS.SchId AND A.PrdId=SP.PrdId
		AND A.PrdBatId=SP.PrdBatId AND BAS.UsrId = @Pi_Usrid AND BAS.TransId = @Pi_TransId
		GROUP BY SP.PrdId,SP.PrdBatId,BAS.SchId
		IF @Pi_TransId=2
		BEGIN
			DECLARE @DiscPer TABLE
			(
				PrdId  INT,
				PrdBatId INT,
				DiscPer  NUMERIC(18,6),
				GrossAmount NUMERIC(18,6),
				RowId  INT
			)
			INSERT INTO @DiscPer
			SELECT SP1.PrdId,SP1.PrdBatId,ISNULL(SUM(BAS1.SchemeDiscount),0),SP1.GrossAmount,SP1.RowId
			FROM BillAppliedSchemeHd BAS1 LEFT OUTER JOIN @TempPrdGross SP1
			ON SP1.SchId=BAS1.SchId AND SP1.PrdId=BAS1.PrdId AND SP1.PrdBatId=BAS1.PrdBatId WHERE IsSelected=1 AND
			SchemeDiscount>0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
			GROUP BY SP1.PrdId,SP1.PrdBatId,SP1.RowId,SP1.GrossAmount
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			--    (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			--SchemeAmount As SchemeAmount,
			CASE 
				WHEN QPS=1 THEN
					--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
					(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
				ELSE  
					SchemeAmount 
				END  
			As SchemeAmount,
			C.GrossAmount - (C.GrossAmount / (1  +
			(
			(
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second Case Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second Case End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId INNER JOIN @TempPrdGross C ON A.Schid = C.SchId
			AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId and B.SchId = C.SchId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 		
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			AND PD.PDSchId=A.SchId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND (A.SchemeAmount + A.SchemeDiscount) > 0
			SELECT  A.RowId,A.PrdId,A.PrdBatId,D.PrdBatDetailValue,
			C.GrossAmount - (C.GrossAmount / (1  +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			 D.PrdBatDetailValue  END     --Second Case End
			ELSE 0 END) + DiscPer)/100)) AS SchAmt,F.SchId,F.SlabId
			INTO #TempFinal
			FROM @DiscPer A
			INNER JOIN @TempPrdGross C ON  A.PrdId = C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId AND D.PrdbatId=A.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON A.PrdId= PD.PrdId AND PD.PDSchId=C.SchId AND
			(CASE PD.PrdBatId WHEN 0 THEN A.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			INNER JOIN BillAppliedSchemeHd F ON F.SchId=PD.PDSCHID AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
			
			SELECT A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,
			--(A.DiscPer+isnull(PrdbatDetailValue,0))/SUM(A.DiscPer+isnull(PrdbatDetailValue,0))
			(A.DiscPer+isnull(PrdbatDetailValue,0))
			as DISC,
			isnull(SUM(A.DiscPer+PrdbatDetailValue),SUM(A.DiscPer)) AS DiscSUM,ISNULL(B.SchAmt,0) AS SchAmt,
			CASE  WHEN (ISNULL(PrdbatDetailValue,0)>0 AND A.DiscPer > 0 )THEN 1
			  WHEN (ISNULL(PrdbatDetailValue,0)=0 AND A.DiscPer > 0) THEN 2
			  ELSE 3 END as Status
			INTO #TempSch1
			FROM ApportionSchemeDetails A LEFT OUTER JOIN #TempFinal B ON
			A.RowId =B.RowId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId
			AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.DiscPer > 0
			GROUP BY A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,B.PrdbatDetailValue,B.SchAmt
			UPDATE #TempSch1 SET SchAmt=B.SchAmt
			FROM #TempFinal B
			WHERE  #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			SELECT A.RowId,A.PrdId,A.PrdBatId,ISNULL(SUM(Disc),0) AS SUMDisc
			INTO #TempSch2
			FROM #TempSch1 A
			GROUP BY A.RowId,A.PrdId,A.PrdBatId
			UPDATE #TempSch1 SET DiscSUM=ISNULL((Disc/NULLIF(SUMDisc,0)),0)*SchAmt
			FROM #TempSch2 B
			WHERE #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			UPDATE ApportionSchemeDetails SET SchemeDiscount=DiscSUM
			FROM #TempSch1 B,ApportionSchemeDetails A
			WHERE A.RowId=B.RowId AND A.PrdId = B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId AND
			A.SlabId= B.SlabId AND B.Status<3
		END
		ELSE
		BEGIN
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			D.PrdBatDetailValue  ELSE 0 END     --Second Case End
			ELSE 0 END) + SchemeDiscount)/100))       --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId AND
			A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 	
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		END
	END
	ELSE
	BEGIN
		---->For Scheme on Another Product QPS
--		SELECT * FROM BillAppliedSchemeHd
--		SELECT * FROM @TempSchGross
--		SELECT * FROM @TempPrdGross
		IF EXISTS(SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		BEGIN
			SELECT DISTINCT TP.SchId,BA.SlabId,TP.PrdId,TP.PrdBatId,TP.RowId,TP.GrossAmount 
			INTO TPQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempPrdGross TP ON TP.SchId=BA.SchId
			SELECT DISTINCT TG.SchId,BA.SlabId,TG.GrossAmount 
			INTO TGQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempSchGross TG ON TG.SchId=BA.SchId
			
			SELECT A.SchId,A.MaxSlabId,SS.PurQty
			INTO SchMaxSlab FROM
			(SELECT SM.SchId,MAX(SS.SlabId) AS MaxSlabId
			FROM SchemeMaster SM,SchemeSlabs SS
			WHERE SM.SchId=SS.SchId AND SM.QPSReset=1 
			GROUP BY SM.SchId) A,
			SchemeSlabs SS
			WHERE A.SchId=SS.SchId AND A.MaxSlabId=SS.SlabId 
	--		SELECT * FROM TG
	--		SELECT * FROM TP
	--
	--		SELECT * FROM TGQ
	--		--SELECT * FROM SchMaxSlab 
	--		SELECT * FROM TPQ
	--		SELECT * FROM BillAppliedSchemeHd
			DECLARE @MSSchId AS INT
			DECLARE @MaxSlabId AS INT
			DECLARE @MSPurQty AS NUMERIC(38,6)
			DECLARE Cur_QPSSlabs CURSOR FOR 
			SELECT SchId,MaxSlabId,PurQty
			FROM SchMaxSlab
			OPEN Cur_QPSSlabs
			FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			WHILE @@FETCH_STATUS=0
			BEGIN		
				UPDATE TGQ SET GrossAmount=@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId=@MaxSlabId
				UPDATE TGQ SET GrossAmount=GrossAmount-@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId<@MaxSlabId
				FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			END
			CLOSE Cur_QPSSlabs
			DEALLOCATE Cur_QPSSlabs

			UPDATE T SET T.GrossAmount=(T.GrossAmount/TG.GrossAmount)*TGQ.GrossAmount
			FROM TPQ T,TG,TGQ
			WHERE T.SchId=TG.SchId AND TG.SchId=TGQ.SchId AND TGQ.SlabId=T.SlabId 	

			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
			SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			--(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount
			,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
			@Pi_TransId AS TransId,@Pi_UsrId AS UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN TGQ B ON
			A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN TPQ C ON A.Schid = C.SchId and B.SchId = C.SchId AND A.SlabId=B.SlabId AND B.SlabId=C.SlabId
			--AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
			WHERE A.UsrId = @Pi_UsrId AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)	
			AND SM.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		END

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId		
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid and SM.QPS=1 	  		
		INNER JOIN SchemeAnotherPrdDt SOP ON SM.SchId=SOP.SchId AND A.SchId=SOP.SchId AND A.SlabId=SOP.SlabId
		AND A.PrdId=SOP.PrdId AND SOP.Prdid=C.PrdId 
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1 
		AND SM.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

--		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
--		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
--		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
--		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
--		Case WHEN QPS=1 THEN
--		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
--		ELSE  SchemeAmount END  As SchemeAmount
--		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
--		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
--		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
--		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
--		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
--		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
--		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
--		AND SM.CombiSch=0
--		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
--		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
--		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		--(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=0
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		SchemeAmount 
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)		
		---->
	END

	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	--SELECT FreePrdId,FreePrdBatId,Sum(FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	SELECT FreePrdId,FreePrdBatId,Sum(DISTINCT FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY FreePrdId,FreePrdBatId

	INSERT INTO @FreeQtyRow (RowId,PrdId,PrdBatId)
	SELECT MIN(A.RowId) as RowId,A.Prdid,A.PrdBatId FROM BilledPrdHdForScheme A
	INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.PrdId AND
	A.PrdBatid = B.PrdBatId
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND
	B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY A.Prdid,A.PrdBatId

	UPDATE ApportionSchemeDetails SET FreeQty = A.FreeQty FROM
	@FreeQtyDt A INNER JOIN @FreeQtyRow B ON
	A.FreePrdId  = B.PrdId
	WHERE ApportionSchemeDetails.RowId = B.RowId
	AND ApportionSchemeDetails.UsrId = @Pi_UsrId AND ApportionSchemeDetails.TransId = @Pi_TransId
	AND CAST(ApportionSchemeDetails.SchId AS NVARCHAR(10))+'~'+CAST(ApportionSchemeDetails.SlabId AS NVARCHAR(10)) 
	IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10)) FROM BillAppliedSchemeHd WHERE FreeToBeGiven>0)
	--->Added the SchId+SlabId Concatenation By Nanda on 15/12/2010 in the above statement


	--->Added By Nanda on 20/09/2010
	SELECT * INTO #TempApp FROM ApportionSchemeDetails	
	DELETE FROM ApportionSchemeDetails
	INSERT INTO ApportionSchemeDetails
	SELECT DISTINCT * FROM #TempApp
	--->Till Here

	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
	FROM 
	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
	WHERE RowId=10000 GROUP BY SchId) A,
	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails
	GROUP BY SchId) B
	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
	AND ApportionSchemeDetails.RowId=B.RowId  
	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	INSERT INTO @RtrQPSIds
	SELECT DISTINCT RtrId,SchId FROM BilledPrdHdForQPSScheme WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	
--	INSERT INTO @QPSGivenDisc
--	SELECT A.SchId,SUM(A.DiscountPerAmount) FROM 
--	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount
--	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
--	WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
--	AND SISl.SlabId<=A.SlabId) A	
--	GROUP BY A.SchId

	INSERT INTO @QPSGivenDisc
	SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount,SISL.FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
	WHERE SchemeAmount=0
	) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
	AND SISl.SlabId<=A.SlabId) A	
	GROUP BY A.SchId

	--SELECT 'N1',* FROM @QPSGivenDisc

	UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
	FROM @QPSGivenDisc A,
	(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
	WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3
	GROUP BY B.SchId) C
	WHERE A.SchId=C.SchId 	

	SELECT 'N2',* FROM @QPSGivenDisc

	INSERT INTO @QPSGivenDisc
	SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
	WHERE B.RtrId=QPS.RtrID AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
	AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0)
	AND SI.SalId=B.SalId AND SI.DlvSts>3
	GROUP BY B.SchId	

	UPDATE A SET A.Amount=A.Amount-S.Amount
	FROM @QPSGivenDisc A,
	(SELECT A.SchId,SUM(A.ReturnDiscountPerAmount+A.ReturnFlatAmount) AS Amount FROM 
	(SELECT DISTINCT SISL.ReturnId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.ReturnDiscountPerAmount,SISL.ReturnFlatAmount
	FROM ReturnSchemeLineDt SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
	WHERE SchemeAmount=0
	) A,SchemeMaster SM ,ReturnHeader SI,@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.ReturnId=SISL.ReturnId AND SI.Status=0
	AND SISl.SlabId<=A.SlabId) A	
	GROUP BY A.SchId) S
	WHERE A.SchId=S.SchId 	

	SELECT 'N3',* FROM @QPSGivenDisc

	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) FROM ApportionSchemeDetails A
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId
	GROUP BY A.SchId,B.Amount

	SELECT * FROM @QPSNowAvailable

--	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
--	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId	

	SELECT * FROM ApportionSchemeDetails
	SELECT * FROM BillQPSSchemeAdj

	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId
	
	SELECT * FROM ApportionSchemeDetails
	SELECT * FROM @QPSNowAvailable

	--->Modified By Nanda
--	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
--	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
--	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId)	

	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount>0)	

	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount=0)	
	-->Till Here

	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId
	AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 354)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(354,'D','2010-12-29',getdate(),1,'Core Stocky Service Pack 354')
