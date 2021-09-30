--[Stocky HotFix Version]=379
Delete from Versioncontrol where Hotfixid='379'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('379','2.0.0.5','D','2011-05-31','2011-05-31','2011-05-31',convert(varchar(11),getdate()),'Major: Product Release FOR JANDJ,HENKEL')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 379' ,'379'
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Cs2Cn_Prk_SchemeUtilizationDetails_Archive]') AND type in (N'U'))
DROP TABLE [Cs2Cn_Prk_SchemeUtilizationDetails_Archive]
GO
CREATE TABLE [Cs2Cn_Prk_SchemeUtilizationDetails_Archive](
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [nvarchar](50)   NULL,
	[TransName] [nvarchar](50)   NULL,
	[SchUtilizeType] [nvarchar](50)   NULL,
	[CmpCode] [nvarchar](100)   NULL,
	[CmpSchCode] [nvarchar](50)   NULL,
	[SchCode] [nvarchar](50)   NULL,
	[SchDescription] [nvarchar](200)   NULL,
	[SchType] [nvarchar](50)   NULL,
	[SlabId] [int] NULL,
	[TransNo] [nvarchar](50)   NULL,
	[TransDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[CmpRtrCode] [nvarchar](50)   NULL,
	[RtrCode] [nvarchar](50)   NULL,
	[BilledPrdCCode] [nvarchar](50)   NULL,
	[BilledPrdBatCode] [nvarchar](50)   NULL,
	[BilledQty] [int] NULL,
	[SchUtilizedAmt] [numeric](38, 6) NULL,
	[SchDiscPerc] [numeric](38, 6) NULL,
	[FreePrdCCode] [nvarchar](50)   NULL,
	[FreePrdBatCode] [nvarchar](50)   NULL,
	[FreeQty] [int] NULL,
	[UploadFlag] [nvarchar](10)   NULL,
	[NoOfTimes] [int] NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO
-- Boopathy Script Starts
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].Proc_RptRtrCategoryandClassShift') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Proc_RptRtrCategoryandClassShift
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
						WHEN 1  THEN 'Class Shift Tool'
						WHEN 2 THEN 'Auto Classification'
						WHEN 3 THEN 'Manual Edit'
						WHEN 4 THEN 'Retailer Approval'
						WHEN 5 THEN 'ETL Import' 
						WHEN 6  THEN 'Class Shift Tool' END
			FROM Track_RtrCategoryandClassChange A (NOLOCK)
			INNER JOIN Retailer B (NOLOCK) ON A.RtrId=B.RtrId
			INNER JOIN RetailerCategoryLevel C (NOLOCK) ON A.OldCtgLevelId=C.CtgLevelId AND
						(C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId Else 0 END) OR
						C.CmpId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN RetailerCategory D (NOLOCK) ON A.OldCtgManinId=D.CtgMainId
			INNER JOIN RetailerValueClass F (NOLOCK) ON A.OldRtrClassId=F.RtrClassId AND
						(F.CmpId = (CASE @CmpId WHEN 0 THEN F.CmpId Else 0 END) OR
						F.CmpId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN Retailer B1 (NOLOCK) ON A.RtrId=B1.RtrId
			INNER JOIN RetailerCategoryLevel C1 (NOLOCK) ON A.NewCtgLevelId=C1.CtgLevelId AND
						(C1.CmpId = (CASE @CmpId WHEN 0 THEN C1.CmpId Else 0 END) OR
						C1.CmpId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN RetailerCategory D1 (NOLOCK) ON A.NewCtgManinId=D1.CtgMainId
			INNER JOIN RetailerValueClass F1 (NOLOCK) ON A.NewRtrClassId=F1.RtrClassId AND
						(F1.CmpId = (CASE @CmpId WHEN 0 THEN F1.CmpId Else 0 END) OR
						F1.CmpId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))	
			INNER JOIN RetailerMarket G (NOLOCK) ON A.RtrId=G.RtrId AND
							(G.RMId = (CASE @RMId WHEN 0 THEN G.RMId Else 0 END) OR
							 G.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			INNER JOIN SalesmanMarket H(NOLOCK)  ON G.RMID=H.RMID AND
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
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_UpdateRetailerClassShift]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_UpdateRetailerClassShift]
GO
CREATE PROCEDURE [dbo].[Proc_UpdateRetailerClassShift]
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
	DECLARE @NewCtgMainId AS INT 
	DECLARE @OldCtgMainId AS INT 

	DECLARE @NewCtgLevelId AS INT 
	DECLARE @OldCtgLevelId AS INT 

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
	SET @FromDate='2011-06-18' --CONVERT(NVARCHAR(10),GETDATE(),121)
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
				SELECT RtrId,(CAST(ABS(SalesGrossAmount-SalesRtnGrossAmount) AS NUMERIC(38,6)) / CAST (ABS(@NoOfMonths) AS  NUMERIC(38,6))) AS Amount ,CtgMainId FROM @RetailerClassShift 
			END 
			ELSE
			BEGIN 
				INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
				SELECT RtrId, (CAST(SalesGrossAmount AS NUMERIC(38,6)) / CAST (ABS(@NoOfMonths) AS  NUMERIC(38,6))) AS Amount,CtgMainId FROM @RetailerClassShift 
			END 
		END
	ELSE
		BEGIN
			IF @Return=1
			BEGIN 
				INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
				SELECT RtrId,(CAST(ABS(SalesNetAmount-SalesRtnNetAmount) AS NUMERIC(38,6)) / CAST (ABS(@NoOfMonths) AS  NUMERIC(38,6))) AS Amount,CtgMainId FROM @RetailerClassShift 
			END 
			ELSE
			BEGIN 
				INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
				SELECT RtrId,(CAST(SalesNetAmount AS NUMERIC(38,6)) / CAST (ABS(@NoOfMonths) AS  NUMERIC(38,6))) AS Amount,CtgMainId FROM @RetailerClassShift 
			END 
		END 

	DECLARE @MainRtrDt TABLE
	(
		Mode		INT,
		RtrId		INT,
		CtgMainId	INT,
		RtrClassId	INT,
		TurnOver	NUMERIC(18,6),
		Amount		NUMERIC(18,6)
	)

	DELETE FROM AutoRetailerClassShift WHERE ShiftDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	DECLARE Cur_RetailerSlassShift CURSOR
          FOR SELECT RtrId,CtgMainId,Amount FROM @RetailerNewClass
    OPEN Cur_RetailerSlassShift
	FETCH NEXT FROM Cur_RetailerSlassShift INTO @RtrId,@CtgMainId,@Amount
	WHILE @@FETCH_STATUS=0
    BEGIN
		INSERT INTO @MainRtrDt
		SELECT 1,@RtrId,@CtgMainId,RtrClassId,TurnOver,@Amount FROM RetailerValueClass WHERE CtgMainId=@CtgMainId
			AND TurnOver IN
		 (SELECT MAX(TurnOver) FROM RetailerValueClass WHERE  CtgMainId=@CtgMainId AND 
			TurnOver > @Amount AND  CmpId = @CmpId) AND CmpId=@CmpId

		INSERT INTO @MainRtrDt
		SELECT 2,@RtrId,@CtgMainId,RtrClassId,TurnOver,@Amount FROM RetailerValueClass WHERE CtgMainId=@CtgMainId
			AND TurnOver IN
		 (SELECT MAX(TurnOver) FROM RetailerValueClass WHERE  CtgMainId=@CtgMainId AND 
			TurnOver < @Amount AND  CmpId = @CmpId) AND CmpId=@CmpId

		INSERT INTO @MainRtrDt
		SELECT 3,@RtrId,@CtgMainId,A.RtrClassId,A.TurnOver,@Amount FROM RetailerValueClass A 
		INNER JOIN RetailerValueClassMap B On A.RtrClassId=B.RtrValueClassId WHERE A.CtgMainId=@CtgMainId
		AND B.RtrId=@RtrId
	

    FETCH NEXT FROM Cur_RetailerSlassShift INTO  @RtrId,@CtgMainId,@Amount
    END
    CLOSE Cur_RetailerSlassShift
    DEALLOCATE Cur_RetailerSlassShift


		IF EXISTS (SELECT * FROM @MainRtrDt)
		BEGIN
			IF EXISTS (SELECT RtrValueClassId FROM RetailerValueClassMap WHERE RtrId=@RtrId )
			BEGIN

				UPDATE A SET A.RtrValueClassId=B.RtrClassId FROM RetailerValueClassMap A
				INNER JOIN 
						(SELECT A.RtrId,B.RtrClassId FROM @MainRtrDt B INNER JOIN 
							(SELECT DISTINCT Max(Mode) As Mode,RtrId FROM @MainRtrDt WHERE Mode<3 GROUP BY RtrId) A
							ON A.RtrId=B.RtrId AND A.Mode=B.Mode) B ON A.RtrId=B.RtrId

				INSERT INTO AutoRetailerClassShift (ShiftDate,RtrId,OldRtrClassId,NewRtrClassId)
				SELECT CONVERT(NVARCHAR(10),GETDATE(),121),A.RtrId,A.RtrClassId,B.RtrClassId
				FROM (SELECT DISTINCT RtrId,RtrClassId FROM @MainRtrDt WHERE Mode=3) A INNER JOIN
				(SELECT A.RtrId,B.RtrClassId FROM @MainRtrDt B INNER JOIN 
						(SELECT DISTINCT Max(Mode) As Mode,RtrId FROM @MainRtrDt WHERE Mode<3 GROUP BY RtrId) A
					ON A.RtrId=B.RtrId AND A.Mode=B.Mode) B ON A.RtrId=B.RtrId

				INSERT INTO Track_RtrCategoryandClassChange
				SELECT -1000,A.RtrId,C.CtgLevelId,A.CtgMainId,A.RtrClassId,C.CtgLevelId,A.CtgMainId,B.RtrClassId,
				CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(23),GETDATE(),121),2 FROM 
				(SELECT DISTINCT RtrId,CtgMainId,RtrClassId FROM @MainRtrDt WHERE Mode=3) A INNER JOIN
				(SELECT A.RtrId,B.RtrClassId FROM @MainRtrDt B INNER JOIN 
						(SELECT DISTINCT Max(Mode) As Mode,RtrId FROM @MainRtrDt WHERE Mode<3 GROUP BY RtrId) A
					ON A.RtrId=B.RtrId AND A.Mode=B.Mode) B ON A.RtrId=B.RtrId
				INNER JOIN RetailerCategory C ON A.CtgMainId=C.CtgMainId
				WHERE A.RtrClassId<>B.RtrClassId

				UPDATE Retailer SET Upload='N' WHERE RtrId IN (SELECT RtrId FROM AutoRetailerClassShift WHERE ShiftDate=CONVERT(NVARCHAR(10),GETDATE(),121) )
			END
		END

RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'Cs2Cn_Prk_DownloadedDetails_Archive') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table Cs2Cn_Prk_DownloadedDetails_Archive
GO
DECLARE @default_name AS Varchar(500)
SELECT @default_name=object_name(cdefault) FROM syscolumns
WHERE [id] = object_id('Cs2Cn_Prk_SchemeUtilizationDetails_Archive')
AND [name] = 'UploadedDate'
IF LEN(@default_name)>0 
BEGIN
	EXEC('ALTER TABLE Cs2Cn_Prk_SchemeUtilizationDetails_Archive DROP CONSTRAINT ' + @default_name)
END
GO
IF EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'UploadedDate' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='Cs2Cn_Prk_SchemeUtilizationDetails_Archive'))
BEGIN
	ALTER TABLE Cs2Cn_Prk_SchemeUtilizationDetails_Archive Drop COLUMN UploadedDate  
END
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'UploadedDate' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='Cs2Cn_Prk_SchemeUtilizationDetails_Archive'))
BEGIN
	ALTER TABLE Cs2Cn_Prk_SchemeUtilizationDetails_Archive ADD UploadedDate  datetime NULL
END
GO
-- Boopathy Script Ended
-- Kalai Script Starts Here
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
INSERT INTO RptDetails VALUES(54,8,'RetailerCategory',7,'CtgLevelID','CtgMainId,CtgCode,CtgName','Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,1,'','Press F4/Double Click to select Category Level Value',1)
INSERT INTO RptDetails VALUES(54,9,'RetailerValueClass',8,'CtgMainID','RtrClassID,ValueClassCode,ValueClassName','Value Classification...','RetailerCategory',1,'CtgMainId',31,1,'','Press F4/Double Click to select Value Classification',0)
INSERT INTO RptDetails VALUES(54,10,'ProductCategoryLevel',5,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,'','Press F4/Double Click to select Product Hierarchy Level',1)
INSERT INTO RptDetails VALUES(54,11,'ProductCategoryValue',10,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,'','','Press F4/Double Click to select Product Hierarchy Level Value',0)
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptSchemeUtilizationWithOutPrimary')
DROP PROCEDURE Proc_RptSchemeUtilizationWithOutPrimary
GO
--EXEC Proc_RptSchemeUtilizationWithOutPrimary 152,2,0,'JnJCRFinal',0,0,1
CREATE PROCEDURE [Proc_RptSchemeUtilizationWithOutPrimary]
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
		UPDATE RtpSchemeWithOutPrimary SET selected=0
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
			SELECT @SchIId,PrdId FROM Fn_ReturnSchemeProductBatch(@SchIId)
			FETCH NEXT FROM Cur_SchPrd INTO @SchIId
		END  
		CLOSE Cur_SchPrd  
		DEALLOCATE Cur_SchPrd  
		--->Till Here
		SELECT SchId,PrdId,SUM(BaseQty) AS BaseQty INTO #TmpFinal FROM
		(SELECT DISTINCT C.SchId,A.PrdId, A.BaseQty-ReturnedQty AS BaseQty  FROM SalesInvoice D 
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
-- Kalai Script Ended
-- Karthick Script Start Here
DELETE FROM RptGroup WHERE  Rptid=232
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'TaxReports',232,'SalesVatReport','Sales Vat Report' 
GO
DELETE FROM RptHeader WHERE Rptid=232
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'SalesVatReport','Sales Vat Report',232,'Sales Vat Report','Proc_RptSalesVatReport','RptSalesVatDetails','RptSalesvatDetails.rpt',NULL
GO
DELETE FROM Rptdetails WHERE Rptid=232
INSERT INTO Rptdetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
SELECT 232,1,'FromDate',-1,NULL,'','From Date*',NULL,1,NULL,10,NULL,NULL,'Enter From Date',0
UNION ALL 
SELECT 232,2,'ToDate',-1,NULL,'','To Date*',NULL,1,NULL,11,NULL,NULL,'Enter To Date',0
UNION ALL 
SELECT 232,3,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company...',NULL,1,NULL,4,1,NULL,'Press F4/Double Click to Select Company',0
UNION ALL 
SELECT 232,4,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Invoice Type...',NULL,1,NULL,274,1,NULL,'Press F4/Double Click to Select Invoice Type',0
GO
DELETE FROM RptFilter WHERE Rptid=232
INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
SELECT 232,274,0,'ALL'
UNION ALL
SELECT 232,274,1,'Sales'
UNION ALL
SELECT 232,274,2,'SalesReturn'
GO
DELETE FROM RptFormula WHERE RptId=232
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 232,1,'Disp_Fromdate','From Date',1,0 UNION ALL
SELECT 232,2,'Fill_Fromdate','From Date',1,10 UNION ALL
SELECT 232,3,'Disp_Todate','To Date',1,0 UNION ALL
SELECT 232,4,'Fill_Todate','To Date',1,11 UNION ALL
SELECT 232,5,'Disp_Company',	'Company',	1,	0 UNION ALL
SELECT 232,6,'Fill_Company',	'Company',	1	,4 UNION ALL
SELECT 232,7,'Disp_InvoiceType',	'Invoice Type'	,1,	0 UNION ALL
SELECT 232,8,'Fill_InvoiceType',	'Invoice Type',	1	,274  UNION ALL
SELECT 232,9,'Cap User Name',	'User Name'	,1,	0 UNION ALL
SELECT 232,10,'Cap Print Date',	'Date',	1	,0 
GO
DELETE FROM RptSelectionHD WHERE SelcId=274
INSERT INTO RptSelectionHD
SELECT 274,'sel_InvoiceType','RptFilter',1
GO
--DELETE FROM RptExcelHeaders WHERE RptId=232
--INSERT INTO RptExcelHeaders VALUES(232,1,'InvId','InvId',0,1)
--INSERT INTO RptExcelHeaders VALUES(232,2,'RefNo','Transaction No',1,1)
--INSERT INTO RptExcelHeaders VALUES(232,3,'InvDate','Transaction Date',1,1)
--INSERT INTO RptExcelHeaders VALUES(232,4,'RtrId','RtrId',0,1)
--INSERT INTO RptExcelHeaders VALUES(232,5,'RtrName','Retailer',1,1)
--INSERT INTO RptExcelHeaders VALUES(232,6,'RtrTINNo','TIN No',1,1)
--INSERT INTO RptExcelHeaders VALUES(232,7,'UsrId','UsrId',0,1)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='TempRptSalestaxsumamry' AND xtype='U')
DROP table TempRptSalestaxsumamry
GO
CREATE TABLE TempRptSalestaxsumamry
(
	InvId bigint,
	RefNo  nvarchar(200),
	InvDate datetime,
	RtrId int,
	RtrName nvarchar(200),
	RtrTINNo nvarchar(100),
	GrossAmount numeric(18,2),
	cashDiscount numeric(18,2),
	visibilityAmount numeric(18,2),
	NetAmount numeric(18,2),
	CmpId int,
	TaxPerc nvarchar(200),
	TaxableAmount  numeric(18,6),
	IOTaxType  nvarchar(100),
	TaxFlag int ,
	TaxPercent numeric(10,6),
	TaxId int,
	ColNo int,
	UserId int
)
GO
--select * from TempRptSalestaxsumamry  order by colno,refno
--EXEC Proc_SalesTaxSummary '2011-05-25','2011-05-26',1,0,0
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_SalesTaxSummary' AND xtype='P')
DROP PROCEDURE Proc_SalesTaxSummary
GO
CREATE Procedure Proc_SalesTaxSummary
(    
 @FromDate AS datetime,
 @ToDate AS Datetime,   
 @Pi_UserId AS int,
 @InvoiceType AS int,
 @Cmpid int 
)    
/************************************************************    
* VIEW : Proc_SalesTaxSummary    
* PURPOSE : To get the Tax Summary details    
* CREATED BY : karthick   
* CREATED DATE : 25-05-2011
* NOTE  :    
* MODIFIED    
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
* {date}        {developer}  {brief modification description}    
*************************************************************/    
AS    
BEGIN    
 Delete from TempRptSalestaxsumamry where UserId in (0,@Pi_UserId)  

	IF (@InvoiceType=0) OR (@InvoiceType=1)
	BEGIN   
		 --Taxable Amount for Sales    
		 Insert INTO TempRptSalestaxsumamry (InvId,RefNo,InvDate,RtrId,Rtrname,RtrTinNO,GrossAmount,cashDiscount,visibilityAmount,
					 NetAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,ColNo,UserId)    
		 Select DISTINCT SI.SalId AS InvId,SI.SalInvNo AS RefNo,SI.SalInvDate as InvDate,    
				R.RtrId AS RtrId,r.RtrName,r.RtrTINNo,Sum(SIP.PrdGrossAmount) AS GrossAmount,si.SalCDAmount,si.WindowDisplayAmount,
				si.SalNetAmt,C.CmpId AS CmpId,'Taxable Amount'+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,
				Sum(TaxableAmount) as TaxableAmount,'Sales' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,
				SPT.TaxId,1,@Pi_UserId AS UserId    
		 From SalesInvoice SI WITH (NOLOCK)    
			  INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId    
			  INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo    
			  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = SI.RtrId     
			  LEFT OUTER JOIN Company C ON C.CmpId =si.CmpId 
		 WHERE SI.DlvSts in (4,5)  AND SalInvDate BETWEEN CONVERT(varchar(10),CONVERT(datetime,@FromDate,121),121)  AND 
			   CONVERT(varchar(10),CONVERT(datetime,@ToDate,121),121) AND
			  ( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR  
			  C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(232,4,@Pi_UserId))) 
		 Group By 
				TaxPerc,SI.SalInvDate,C.CmpId,SI.SalId,SI.SalInvNo,R.RtrId,SPT.TaxId,
				si.SalCDAmount,si.WindowDisplayAmount,si.SalNetAmt,r.RtrName,r.RtrTINNo
		 Having 
				Sum(SPT.TaxAmount) >0 AND SUM(TAXAMOUNT)>0
		  
		 --Tax Amount for Sales    
		 Insert INTO TempRptSalestaxsumamry (InvId,RefNo,InvDate,RtrId,Rtrname,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,
					 NetAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,ColNo,UserId)    
		 Select distinct  SI.SalId AS InvId,SI.SalInvNo AS RefNo,SI.SalInvDate as InvDate,    
				R.RtrId AS RtrId,r.RtrName,r.RtrTINNo,Sum(SIP.PrdGrossAmount) AS GrossAmount,si.SalCDAmount,si.WindowDisplayAmount,
				si.SalNetAmt,C.CmpId AS CmpId,'Tax Amount'+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(SPT.TaxAmount) as TaxableAmount,    
				'Sales' as IOTaxType,2 as TaxFlag,TaxPerc as TaxPercent,SPT.TaxId,2,@Pi_UserId AS UserId    
		 From SalesInvoice SI WITH (NOLOCK)    
			  INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId    
			  INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId 
						 AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo    
			  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = SI.RtrId     
			  LEFT OUTER JOIN Company C ON C.CmpId = si.CmpId     
		 WHERE 
				SI.DlvSts in (4,5) AND SalInvDate BETWEEN CONVERT(varchar(10),CONVERT(datetime,@FromDate,121),121)  AND 
				CONVERT(varchar(10),CONVERT(datetime,@ToDate,121),121) and ( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR  
				C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(232,4,@Pi_UserId)))  
		 Group By 
				TaxPerc,SI.SalInvDate,C.CmpId,SI.SalId,SI.SalInvNo,R.RtrId,SPT.TaxId,
				si.SalCDAmount,si.WindowDisplayAmount,si.SalNetAmt,r.RtrName,r.RtrTINNo
		 Having 
				Sum(SPT.TaxAmount) >0 AND SUM(TAXAMOUNT)>0

		--Taxable Amount for MarketReturn    
		  Insert INTO TempRptSalestaxsumamry (InvId,RefNo,InvDate,RtrId,Rtrname,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,
					  NetAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,ColNo,UserId)    
		  Select distinct RH.salid AS InvId,SI.SalInvNo AS RefNo,si.SalInvDate as InvDate,    
				 R.RtrId AS RtrId,r.RtrName,RtrTINNo,Sum(RP.PrdGrossAmt) AS GrossAmount,rh.RtnCashDisAmt,0 AS visibilityAmount,
				 rh.RtnNetAmt,si.CmpId AS CmpId,'SalesReturn TaxableAmt'+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,
				 Sum(TaxableAmt) as TaxableAmount,'Sales' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,
				 RPT.TaxId,3,@Pi_UserId AS UserId    
		  From ReturnHeader RH WITH (NOLOCK)    
			   INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1    
			   INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo    
			   INNER JOIN SalesInvoiceMarketReturn SMR ON SMR.SalId=rh.SalId AND SMR.ReturnId=RH.ReturnID
			   INNER JOIN salesinvoice SI ON si.SalId=SMR.SalId AND SI.SalId=rh.SalId 
			   INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId    
			   INNER JOIN Company  C ON C.CmpId=si.CmpId
		  WHERE
   			   RH.Status = 0 AND si.SalInvDate BETWEEN CONVERT(varchar(10),CONVERT(datetime,@FromDate,121),121)  AND 
			   CONVERT(varchar(10),CONVERT(datetime,@ToDate,121),121)  AND si.DlvSts IN(4,5) 
			   and ( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR  
			   C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(232,4,@Pi_UserId)))  
		  Group By 
				TaxPerc,si.salinvdate,si.CmpId,RH.SalId,si.salinvno,
				R.RtrId,RPT.TaxId,rh.RtnCashDisAmt,rh.RtnNetAmt,r.RtrName,r.RtrTINNo
		  Having
				Sum(TaxableAmt) > 0  AND sum(TaxAmt)>0  

		--Tax Amount for MarketReturn    
		  Insert INTO TempRptSalestaxsumamry (InvId,RefNo,InvDate,RtrId,Rtrname,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,
					  NetAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,ColNo,UserId)    
		  Select distinct RH.SalId AS InvId,si.salinvno AS RefNo,si.salinvdate as InvDate,    
				  R.RtrId AS RtrId,r.RtrName,r.RtrTINNo,Sum(RP.PrdGrossAmt) AS GrossAmount,rh.RtnCashDisAmt,0 AS visibilityAmount,
				  rh.RtnNetAmt,si.CmpId AS CmpId,'SalesReturn TaxAmt'+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,
				  Sum(RPT.TaxAmt) as TaxableAmount,'Sales' as IOTaxType,3 as TaxFlag,TaxPerc as TaxPercent,
				  RPT.TaxId,4,@Pi_UserId AS UserId    
		  From ReturnHeader RH WITH (NOLOCK)    
			  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1    
			  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo    
			  INNER JOIN SalesInvoiceMarketReturn SMR ON SMR.SalId=rh.SalId AND SMR.ReturnId=RH.ReturnID
			  INNER JOIN salesinvoice SI ON si.SalId=SMR.SalId AND SI.SalId=rh.SalId  
			  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId     
			  INNER JOIN Company  C ON C.CmpId=si.CmpId   
		  WHERE RH.Status = 0 AND SalInvDate BETWEEN CONVERT(varchar(10),CONVERT(datetime,@FromDate,121),121)  AND 
				CONVERT(varchar(10),CONVERT(datetime,@ToDate,121),121) AND si.DlvSts IN(4,5)
				and ( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR  
				C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(232,4,@Pi_UserId)))       
		  Group By	
				 TaxPerc,si.salinvdate,si.CmpId,RH.SalId,si.salinvno,
				 R.RtrId,RPT.TaxId,rh.RtnCashDisAmt,rh.RtnNetAmt,r.RtrName,r.RtrTINNo
		  Having 
				Sum(TaxableAmt) > 0  AND sum(TaxAmt)>0 
	END 
	IF (@InvoiceType=0) OR (@InvoiceType=2)
	BEGIN 
	 --Taxable Amount for SalesReturn    
	  Insert INTO TempRptSalestaxsumamry (InvId,RefNo,InvDate,RtrId,Rtrname,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,
				  NetAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,ColNo,UserId)    
	  Select distinct RH.ReturnId AS InvId,RH.ReturnCode AS RefNo,Rh.ReturnDate as InvDate,    
			 R.RtrId AS RtrId,r.RtrName,r.RtrTINNo,-1*Sum(RP.PrdGrossAmt) AS GrossAmount,-1*rh.RtnCashDisAmt,0 AS visibilityAmount,
			 -1*(rh.RtnNetAmt),CmpId AS CmpId,'SalesReturn TaxableAmt'+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,
			 -1*Sum(TaxableAmt) as TaxableAmount,'SalesReturn' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,
			 RPT.TaxId,5,@Pi_UserId AS UserId    
	  From ReturnHeader RH WITH (NOLOCK)    
		   INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1    
		   INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo    
		   INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId    
		   CROSS JOIN Company 
	  WHERE
   		   RH.Status = 0 AND ReturnDate BETWEEN CONVERT(varchar(10),CONVERT(datetime,@FromDate,121),121)  AND 
		   CONVERT(varchar(10),CONVERT(datetime,@ToDate,121),121) 
		   AND CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(232,4,@Pi_UserId))     
	  Group By 
			TaxPerc,RH.ReturnDate,CmpId,RH.ReturnId,RH.ReturnCode,
			R.RtrId,RPT.TaxId,rh.RtnCashDisAmt,rh.RtnNetAmt,r.RtrName,r.RtrTINNo
	  Having
			Sum(TaxableAmt) > 0  AND sum(TaxAmt)>0  

	--Tax Amount for SalesReturn    
	  Insert INTO TempRptSalestaxsumamry (InvId,RefNo,InvDate,RtrId,Rtrname,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,
				  NetAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,ColNo,UserId)    
	  Select distinct RH.ReturnId AS InvId,RH.ReturnCode AS RefNo,Rh.ReturnDate as InvDate,    
			  R.RtrId AS RtrId,r.RtrName,r.RtrTINNo,-1*Sum(RP.PrdGrossAmt) AS GrossAmount,-1*rh.RtnCashDisAmt,0 AS visibilityAmount,
			  -1*rh.RtnNetAmt,CmpId AS CmpId,'SalesReturn TaxAmt'+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,
			  -1*Sum(RPT.TaxAmt) as TaxableAmount,'SalesReturn' as IOTaxType,3 as TaxFlag,TaxPerc as TaxPercent,
			  RPT.TaxId,6,@Pi_UserId AS UserId    
	  From ReturnHeader RH WITH (NOLOCK)    
		  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1    
		  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo    
		  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId     
		  CROSS JOIN Company     
	  WHERE RH.Status = 0 AND ReturnDate BETWEEN CONVERT(varchar(10),CONVERT(datetime,@FromDate,121),121)  AND 
			CONVERT(varchar(10),CONVERT(datetime,@ToDate,121),121) 
			AND CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(232,4,@Pi_UserId))      
	  Group By	
			 TaxPerc,RH.ReturnDate,CmpId,RH.ReturnId,RH.ReturnCode,
			 R.RtrId,RPT.TaxId,rh.RtnCashDisAmt,rh.RtnNetAmt,r.RtrName,r.RtrTINNo
	  Having 
			Sum(TaxableAmt) > 0  AND sum(TaxAmt)>0  
	END 
END    
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptSalesVatReport')
DROP PROCEDURE Proc_RptSalesVatReport
GO
CREATE PROCEDURE Proc_RptSalesVatReport
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
--exec Proc_RptSalesVatReport 232,1,0,'jnj',0,0,1
/*******************************************************************************************************
* VIEW	: Proc_RptSalesVatReport
* PURPOSE	: To get sales tax Details
* CREATED BY	: Karthick.K.J
* CREATED DATE	: 25/05/2011
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------
* {date} {developer}  {brief modification description}	
********************************************************************************************************/
BEGIN
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @InvoiceType AS  INT 

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,274,@Pi_UsrId))

	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_SalesTaxSummary @FromDate,@ToDate,@Pi_UsrId,@InvoiceType,@CmpId

		INSERT INTO TempRptSalestaxsumamry 
		  SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Cash Discount',(cashDiscount),IOTaxType,4 TaxFlag,0 TaxPercent,0 TaxId,7,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
		 UNION ALL  
		 SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Visibility Amount',(visibilityAmount),IOTaxType,5 TaxFlag,0 TaxPercent,0 TaxId,8,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
	UNION ALL
		 SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Net Amount',(NetAmount),IOTaxType,6 TaxFlag,0 TaxPercent,0 TaxId,9,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
	END 

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM TempRptSalestaxsumamry  

  DECLARE  @InvId BIGINT  
  DECLARE  @RefNo NVARCHAR(100)  
  DECLARE  @PurRcptRefNo NVARCHAR(50)  
  DECLARE  @TaxPerc   NVARCHAR(100)  
  DECLARE  @TaxableAmount NUMERIC(38,6)  
  DECLARE  @IOTaxType    NVARCHAR(100)  
  DECLARE  @SlNo INT    
  DECLARE  @TaxFlag      INT  
  DECLARE  @Column VARCHAR(80)  
  DECLARE  @C_SSQL VARCHAR(4000)  
  DECLARE  @iCnt INT  
  DECLARE  @TaxPercent NUMERIC(38,6)  
  DECLARE  @Name   NVARCHAR(100)  
  DECLARE  @RtrId INT  

  --DROP TABLE [RptSalesVatDetails_Excel]  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesVatDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE RptSalesVatDetails_Excel  
  DELETE FROM RptExcelHeaders Where RptId=232 AND SlNo>7  
  CREATE TABLE RptSalesVatDetails_Excel (
				InvId BIGINT,RefNo NVARCHAR(100),InvDate DATETIME,
				RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)  
  SET @iCnt=8  
  DECLARE Column_Cur CURSOR FOR  
  SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag FROM TempRptSalestaxsumamry  ORDER BY TaxFlag,TaxPercent
  OPEN Column_Cur  
      FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='ALTER TABLE RptSalesVatDetails_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'  
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
  DELETE FROM RptSalesVatDetails_Excel  
  INSERT INTO RptSalesVatDetails_Excel(InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId)  
  SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId  
    FROM TempRptSalestaxsumamry  
  --Select * from [RptSalesVatDetails_Excel]  
  DECLARE Values_Cur CURSOR FOR  
  SELECT DISTINCT InvId,RefNo,RtrId,TaxPerc,TaxableAmount FROM TempRptSalestaxsumamry  
  OPEN Values_Cur  
      FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptSalesVatDetails_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))  
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
  SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSalesVatDetails_Excel]')  
  OPEN NullCursor_Cur  
      FETCH NEXT FROM NullCursor_Cur INTO @Name  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptSalesVatDetails_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM NullCursor_Cur INTO @Name  
    END  
  CLOSE NullCursor_Cur  
  DEALLOCATE NullCursor_Cur  
select * from TempRptSalestaxsumamry
RETURN  
END 
GO
--Dead OutLet Report
DELETE FROM RptFilter WHERE RptId=50 AND SelcId=104
INSERT INTO RptFilter VALUES (50,104,1,'InActive')
INSERT INTO RptFilter VALUES (50,104,2,'Active')
GO
DELETE FROM  RptDetails WHERE RptId=50 AND SlNo=15
INSERT INTO RptDetails VALUES
(50,15,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Status...',NULL,1,NULL,104,1,0,'Press F4/Double Click to Select Status',0)
GO
--EXEC Proc_RptDeadOutLet 50,1,0,'jnj',0,0,1,0
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptDeadOutLet' AND xtype='P' )
DROP PROCEDURE Proc_RptDeadOutLet
GO
CREATE PROCEDURE Proc_RptDeadOutLet

/***************************************************************************************************************
* PROCEDURE	: Proc_RptDeadOutLet
* PURPOSE	: To get Dead Outlet
* CREATED BY	: R.Murugan
* CREATED DATE	: 05/12/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
* 20-11-2009	Thiruvengadam	Bill Number will displayed for the billed Salesman wise Route Wise Retailer Wise
*****************************************************************************************************************/

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
	DECLARE @sSql		AS 	VarChar(8000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)


	DECLARE @DeadOutletDt TABLE 
	(	
		CmpId INT,
		SMId INT,
		SMName VARCHAR(100),
		RMId INT,
		RMName VARCHAR(100),
		CtgLevelId INT,
		CtgLevelName VARCHAR(100),
		CtgName VARCHAR(100),
		RtrClassId INT,
		ValueClassName VARCHAR(100),
		Rtrid INT,
		RtrName VARCHAR(150),
		VillageId INT,
		SalNetAmount Numeric(38,4),
		SalInvDate DATETIME,
		SalInvNo VARCHAR(100),
		Usrid INT
	)
	
	CREATE TABLE #DEAD
	(
		RTRID INT,
		PRDID INT,
		NETAMOUNT NUMERIC(38,4)
	)

	CREATE  TABLE #RPTDEADOUTLET  
	(
		CMPID INT,
		SMId INT,
		SMName VARCHAR(100),
		RMId INT,
		RMName VARCHAR(100),
		CtgLevelId INT,
		CtgLevelName VARCHAR(100),
		CtgName VARCHAR(100),
		RtrClassId INT,
		ValueClassName VARCHAR(100),
		Rtrid INT,
		RtrName VARCHAR(150),
		VillageId INT,
		SalNetAmount Numeric(38,4),
		SalInvDate DATETIME,
		SalInvNo VARCHAR(100)		
	)
	
	DECLARE @TEMPPRDID TABLE 
	(
		RTRID  INT
	)

	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @PrdCatValId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @CmpId	 	AS	INT
	DECLARE @SMId           AS	INT
	DECLARE @RMId           AS	INT
	DECLARE @Basedon        AS	INT
	DECLARE @RtrId		AS 	INT
	DECLARE @CtgLevelId	AS 	INT
	DECLARE @RtrClassId	AS 	INT
	DECLARE @Amount		AS 	VARCHAR(40)
	DECLARE @VillageId 	AS 	INT
	DECLARE @PastPeriod 	AS 	INT
	DECLARE @Measure 	AS 	INT
	DECLARE @CtgMainId	AS 	INT
    DECLARE @Status  AS  TINYINT  
	
	SET @PastPeriod =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,66,@Pi_UsrId))
	SET @ToDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @VillageId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,65,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @Measure=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,63,@Pi_UsrId))
	SET @Amount=(SELECT  TOP 1 SelDate FROM ReportFilterDt Where Rptid=@Pi_RptId and Selid=64 and Usrid=@Pi_UsrId)
	SET @PastPeriod='-'+Cast(@PastPeriod as Varchar(10))	
	SET @FromDate=DATEAdd(Day,@PastPeriod , Convert(varchar(10),@ToDate,121))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate) 
	SET @Status = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId))  
	
	PRint @FromDate
	
	DELETE FROM DeadOutlet Where Usrid=@Pi_UsrId
	DELETE FROM @DeadOutletDt 	DELETE FROM @TEMPPRDID
	
	INSERT INTO @TEMPPRDID (RTRID)
	SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)
	,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL
	WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
		RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
		RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
	AND (RCL.CmpId = (CASE @CmpId WHEN 0 THEN RCL.CmpId ELSE 0 END) OR 
			RCL.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
	AND (RVC.CmpId = (CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR 
			RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
	AND  (R.RtrStatus = (CASE @Status WHEN 0 THEN R.RtrStatus ELSE 3 END) OR  
     R.RtrStatus IN (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId))) 

	SET @TblName = 'RptDeadOutLet'
	
	SET @TblStruct ='CmpId INT,
			SMId INT,
			SMName VARCHAR(100),
			RMId INT,
			RMName VARCHAR(100),
			CtgLevelId INT,
			CtgLevelName VARCHAR(100),
			CtgName VARCHAR(100),
			RtrClassId INT,
			ValueClassName VARCHAR(100),
			Rtrid INT,
			RtrName VARCHAR(150),
			VillageId INT,
			SalNetAmount Numeric(38,4),
			SalInvDate DATETIME,
			SalInvNo VARCHAR(100)'
			

	SET @TblFields = 'CmpId,SMId,SMName,RMId,RMName,CtgLevelId,CtgLevelName,CtgName,RtrClassId,
	ValueClassName,Rtrid,RtrName,VillageId ,SalNetAmount,SalInvDate,SalInvNo'

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

	INSERT INTO DeadOutlet (Rtrid,PrdId,SalinvDate,SalInvNo,NetAmount,Usrid)
	select Distinct R.Rtrid,P.Prdid,Max(SalinvDate) as SalinvDate ,Max(SalInvno) as SalInvno,
	sum(PrdNetAmount) as Netamount,@Pi_UsrId as Usrid FROM Salesinvoice SI WITH (NOLOCK) 
	INNER JOIN SalesinvoiceProduct  SIP WITH (NOLOCK) on SI.salid=SIP.salid 
	INNER JOIN PRODUCT P ON SIP.Prdid=P.Prdid 
	AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
		P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
	AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
		P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
	AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR 
		p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
	INNER JOIN Salesman S WITH (NOLOCK) ON SI.SMid=S.SMid
	AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId Else 0 END) OR
        	SI.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
	INNER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMid=RM.RMid 
	AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId Else 0 END) OR
	    	SI.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
	INNER JOIN Retailer R WITH (NOLOCK) ON   SI.Rtrid=R.Rtrid
	INNER JOIN @TEMPPRDID TP ON TP.RTRID= SI.Rtrid AND TP.RTRID=R.Rtrid
		LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON RV.RMID=RM.RMid AND SI.RMid=RV.RMid 
		AND (RV.VillageId=(CASE @VillageId WHEN 0 THEN RV.VillageId ELSE 0 END) OR
		RV.VillageId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,65,@Pi_UsrId)))
	WHERE 
		SI.Salinvdate BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121) 
		AND  RM.RMSRouteType=1  AND SI.Dlvsts In(4,5)
	GROUP BY r.rtrid,P.Prdid
			
	If @PrdId=0 AND @CtgLevelId=0
	Begin
		Set @ssql='INSERT INTO #DEAD(RTRID,PRDID,NETAMOUNT) Select Distinct Rtrid,0 as Prdid,SUM(NetAmount) as NetAmount from DeadOutlet where Usrid =' + CAST(@Pi_UsrId AS nVarchar(10)) + ' Group by Rtrid'
		If @Measure=1
		Set @ssql=@ssql + ' Having Sum(NetAmount)>='+Cast( @Amount as Varchar(40))
		If @Measure=2
		Set @ssql=@ssql + ' Having Sum(NetAmount)<='+Cast( @Amount as Varchar(40))
		If @Measure=3
		Set @ssql=@ssql + ' Having Sum(NetAmount)<'+Cast( @Amount as Varchar(40))
		If @Measure=4
		Set @ssql=@ssql + ' Having Sum(NetAmount)>'+Cast( @Amount as Varchar(40))
		If @Measure=5
		Set @ssql=@ssql + ' Having Sum(NetAmount)='+Cast( @Amount as Varchar(40))
		If @Measure=6
		Set @ssql=@ssql + ' Having Sum(NetAmount) Between '+Cast( @Amount as Varchar(40))
		Set @ssql=@ssql + ' Delete DeadOutlet From  #Dead Where #Dead.Rtrid=DeadOutlet.Rtrid and Usrid=' + CAST(@Pi_UsrId AS nVarchar(10))  
	End
	Else
	Begin
		Set @ssql='INSERT INTO #DEAD(RTRID,PRDID,NETAMOUNT)Select Distinct Rtrid,Prdid,SUM(NetAmount) as NetAmount from DeadOutlet where Usrid =' + CAST(@Pi_UsrId AS nVarchar(10)) + ' Group by Rtrid,Prdid'
		If @Measure=1
		Set @ssql=@ssql + ' Having Sum(NetAmount)>='+Cast( @Amount as Varchar(40))
		If @Measure=2
		Set @ssql=@ssql + ' Having Sum(NetAmount)<='+Cast( @Amount as Varchar(40))
		If @Measure=3
		Set @ssql=@ssql + ' Having Sum(NetAmount)<'+Cast( @Amount as Varchar(40))
		If @Measure=4
		Set @ssql=@ssql + ' Having Sum(NetAmount)>'+Cast( @Amount as Varchar(40))
		If @Measure=5
		Set @ssql=@ssql + ' Having Sum(NetAmount)='+Cast( @Amount as Varchar(40))
		If @Measure=6
		Set @ssql=@ssql + ' Having Sum(NetAmount) Between '+Cast( @Amount as Varchar(40))
		
		Set @ssql=@ssql + ' Delete DeadOutlet From #Dead Where #Dead.Prdid=DeadOutlet.Prdid and #Dead.Rtrid=DeadOutlet.Rtrid and Usrid=' + CAST(@Pi_UsrId AS nVarchar(10))  

	End
			
	Exec(@ssql)	
			
	INSERT INTO @DeadOutletDt
	(
	CmpId,SMId,SMName,RMId,RMName,CtgLevelId,CtgLevelName,CtgName,RtrClassId,
	ValueClassName,Rtrid,RtrName,VillageId,SalNetAmount,SalInvDate,SalInvNo,Usrid 
	)
	select DISTINCT @CmpId as CmpId, S.SMId, S.SMName, SM.RMId, RM.RMName,RCL.CtgLevelId, RCL.CtgLevelName AS 'CtgLevelName',
	        RC.CtgName as 'LevelName',RVC.RtrClassId, RVC.ValueClassName,R.Rtrid,RtrName,R.VillageId,
		0 as SalNetAMount,(D.SalinvDate) as SalinvDate ,(D.SalInvno) as SalInvno,@Pi_UsrId  as Usrid
	FROM DeadOutlet D WITH (NOLOCK) INNER JOIN PRODUCT P ON P.Prdid=D.PrdId
		AND (P.PrdId = (CASE @PrdCatValId WHEN 0 THEN P.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND (P.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else 0 END) OR
			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))		
		AND (p.CmpId = (CASE @CmpId WHEN 0 THEN p.CmpId ELSE 0 END) OR 
			p.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
		AND Usrid=@Pi_UsrId
	RIGHT OUTER JOIN RETAILER R WITH (NOLOCK)ON  R.Rtrid=D.Rtrid
		INNER JOIN  RetailerMarket RTM WITH (NOLOCK) ON R.Rtrid=RTM.Rtrid --and RTM.Rtrid=D.Rtrid
	INNER JOIN RouteMaster RM WITH (NOLOCK) ON RTM.RMid=RM.RMid
		AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
	INNER JOIN SalesmanMarket SM WITH (NOLOCK) ON  RM.RMid =  SM.RMid
	INNER JOIN Salesman S WITH (NOLOCK) ON S.SMid =SM.SMid
		 AND (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
                    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
	INNER JOIN RetailerValueClassMap RVCM WITH (NOLOCK) ON  R.Rtrid = RVCM.RtrId AND RVCM.RtrId = RTM.RtrId	
	INNER JOIN RetailerValueClass RVC WITH (NOLOCK) ON  RVCM.RtrValueClassId = RVC.RtrClassId
		AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
			RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
		AND (RVC.CmpId = (CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR 
			RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	INNER JOIN RetailerCategory RC WITH (NOLOCK) ON    RVC.CtgMainId=RC.CtgMainId 
		AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	INNER JOIN RetailerCategoryLevel RCL WITH (NOLOCK) ON  RCL.CtgLevelId=RC.CtgLevelId
		AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
			RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
		AND (RCL.CmpId = (CASE @CmpId WHEN 0 THEN RCL.CmpId ELSE 0 END) OR 
			RCL.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId=RV.VillageId AND RM.RMid=RV.RMid 
		AND (R.VillageId=(CASE @VillageId WHEN 0 THEN R.VillageId ELSE 0 END) OR
			R.VillageId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,65,@Pi_UsrId)))
WHERE (R.RtrStatus = (CASE @Status WHEN 0 THEN R.RtrStatus ELSE 3 END) OR  
     R.RtrStatus IN (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))  
	Order By R.RtrName,ValueClassName	

--	Select * from @DeadOutletDt

	select Distinct si.Rtrid,SI.SMID,SI.RMID,sum(SIP.PrdNetAmount) as Netamount,MAX(SI.SalInvNo) as SalinvNo,MAX(SI.SalInVDate) as SalinvDate 
	INTO #TEMP 
	FROM Salesinvoice SI WITH (NOLOCK) 
	INNER JOIN SalesinvoiceProduct  SIP WITH (NOLOCK) on SI.salid=SIP.salid
	WHERE
	SI.Salinvdate   BETWEEN  Convert(Varchar(10),@FromDate,121) AND  Convert(Varchar(10),@ToDate,121)
	and Si.dlvsts not in (2,3,1)
	GROUP BY SI.Rtrid,SI.SMID,SI.RMID 
	
	SELECT * INTO #TEMP1 FROM @DeadOutletDt WHERE Isnull(SALINVDATE,0) =0 and Isnull(SALINVNO,0)=0
------	--select * from #TEMP1
	UPdate T1 SET T1.SalNetAmount=T.Netamount,T1.SalinvNo=T.SalInvNo,T1.SalInvDate=T.SalInvDate
	From #TEMP T,#TEMP1 T1 WHERE T.Rtrid=T1.Rtrid AND T.Smid=T1.SMID and T.RmId=T1.RmId --Added by Thiru on 20-11-2009
			
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RPTDEADOUTLET(
		CMPID,SMId,SMName,RMId,RMName,CtgLevelId,CtgLevelName,CtgName,RtrClassId,
		ValueClassName,Rtrid,RtrName,VillageId, SalNetAmount,SalInvDate,SalInvNo--,Usrid 
		)
		SELECT CMPID,SMId,SMName,RMId,RMName,CtgLevelId,CtgLevelName,CtgName,RtrClassId,
		ValueClassName,Rtrid,RtrName,Isnull(VillageId,0) INT,Isnull(SalNetAmount,0),SalInvDate,IsNull(SalInvNo,'')--,Usrid 
		FROM #TEMP1 ORder By RtrName,ValueClassName

		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
			SET @SSQL = 'INSERT INTO #RPTDEADOUTLET' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				--+ ' WHERE RptId=' + CAST(@Pi_RptId AS nVarchar(10)) + ' AND UsrId=' + CAST(@Pi_UsrId AS nVarchar(10)) + '' 
				+ ' WHERE UsrId=' + CAST(@Pi_UsrId AS nVarchar(10)) + '' 
				+ 'AND 	(CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR ' 
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '
				+ 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatValId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (VillageId = (CASE ' + CAST(@VillageId AS nVarchar(10)) + ' WHEN 0 THEN VillageId Else 0 END) OR '
				+ 'VillageId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',65,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (CtgLevelId = (CASE ' + CAST(@CtgLevelId AS nVarchar(10)) + ' WHEN 0 THEN CtgLevelId Else 0 END) OR '
				+ 'CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',29,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RtrClassId = (CASE ' + CAST(@RtrClassId AS nVarchar(10)) + ' WHEN 0 THEN RtrClassId Else 0 END) OR '
				+ 'RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',31,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
			
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RPTDEADOUTLET'
				PRINT @SSQL
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
			SET @SSQL = 'INSERT INTO #RPTDEADOUTLET ' + 
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RPTDEADOUTLET 
	SELECT * FROM #RPTDEADOUTLET 

RETURN
END
GO
-- Karthick Script Ended
-- JayaKumar Script Starts Here
      DELETE FROM dbo.Tbl_Generic_Reports WHERE RPTID=11
	DELETE FROM dbo.Tbl_Generic_Reports_Filters WHERE RPTID=11
	INSERT INTO dbo.Tbl_Generic_Reports  VALUES (11,'Retailer Buying Trend-JCWise Report','Proc_GR_CrossTabJCWise','Retailer Buying Trend-JCWise Report','Not Available')
	INSERT INTO dbo.Tbl_Generic_Reports_Filters VALUES (11,1,'Salesman','Proc_GR_CrossTabJCWise_Values','Retailer Buying Trend-JCWise Report')
	INSERT INTO dbo.Tbl_Generic_Reports_Filters VALUES (11,2,'Retailer Hierarchy','Proc_GR_CrossTabJCWise_Values','Retailer Buying Trend-JCWise Report')
	INSERT INTO dbo.Tbl_Generic_Reports_Filters VALUES (11,3,'Not Applicable','Proc_GR_CrossTabJCWise_Values','Retailer Buying Trend-JCWise Report')
	INSERT INTO dbo.Tbl_Generic_Reports_Filters VALUES (11,4,'Retailer Name','Proc_GR_CrossTabJCWise_Values','Retailer Buying Trend-JCWise Report')
	INSERT INTO dbo.Tbl_Generic_Reports_Filters VALUES (11,5,'Route Name','Proc_GR_CrossTabJCWise_Values','Retailer Buying Trend-JCWise Report')
	INSERT INTO dbo.Tbl_Generic_Reports_Filters VALUES (11,6,'Product Hierarchy Value','Proc_GR_CrossTabJCWise_Values','Retailer Buying Trend-JCWise Report')
GO
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GR_CrossTabJCWise_Values]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Proc_GR_CrossTabJCWise_Values]
GO
	CREATE PROCEDURE [dbo].[Proc_GR_CrossTabJCWise_Values]  
	(  
		@FILTERCAPTION  NVARCHAR(100),  
		@TEXTLIKE  NVARCHAR(100)  
	)  
	as  
	begin  
	SET @TEXTLIKE='%'+ISNULL(@TEXTLIKE,'')+'%'  
	IF @FILTERCAPTION='Salesman'   
	begin  
		SELECT DISTINCT SMName as FilterValues FROM Salesman WHERE smname LIKE @textlike  
	end  
	IF @FILTERCAPTION='Retailer Hierarchy'   
	begin  
		select ctgcode+':'+ctgname as filtervalues from retailercategory WHERE ctgcode+':'+CTGNAME LIKE @TEXTLIKE  
	end   
	IF @FILTERCAPTION='Retailer Name'   
	begin  
		SELECT DISTINCT rtrname as Filtervalues FROM retailer WHERE rtrname LIKE @textlike  
	end   
	IF @FILTERCAPTION='Route Name'   
	begin  
		SELECT DISTINCT RmName as Filtervalues FROM Routemaster WHERE RmName LIKE @textlike  
	end   
	IF @FILTERCAPTION='Product Hierarchy Value'   
	begin  
		SELECT  PrdCtgValName as Filtervalues FROM productcategoryvalue WHERE  PrdCtgValName LIKE @textlike  
	end   
	END
GO
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GR_CrossTabJCWise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Proc_GR_CrossTabJCWise]
GO
	-- EXEC Proc_GR_CrossTabJCWise 'Retailer Buying Trend-JCWise Report','2011-05-23','2011-05-24','','','','','',''          
	CREATE PROCEDURE [dbo].[Proc_GR_CrossTabJCWise]                  
	(                  
	@Pi_RptName  NVARCHAR(100),                  
	@Pi_FromDate DATETIME,                  
	@Pi_ToDate  DATETIME,                  
	@Pi_Filter1  NVARCHAR(100),               
	@Pi_Filter2  NVARCHAR(100),                  
	@Pi_Filter3  NVARCHAR(100),                  
	@Pi_Filter4  NVARCHAR(100),                  
	@Pi_Filter5  NVARCHAR(100),                  
	@Pi_Filter6  NVARCHAR(100)                  
	)                  
	AS                   
	/*******************************************************************************                  
	* PROCEDURE     :Proc_GR_CrossTabJCWise              
	* PURPOSE       :To Get JCWISE(Month) Details - Dynamic report purpose               
	* CREATED BY    :Jayakumar.E                  
	* CREATED DATE  :06/05/2011                   
	---------------------------------------------------------------------------------                  
	* {date}       {developer}  {brief modification description}                  
	*********************************************************************************/                  
	BEGIN                  
	DECLARE @PHLEVEL VARCHAR(7500)                  
	DECLARE @SQL_STR1 VARCHAR(8000)                  
	DECLARE @SQL_STR2 VARCHAR(8000)                  
	DECLARE @CAPHLEVEL VARCHAR(8000)                  
	     
	DECLARE @SName    Varchar(100)                  
	DECLARE @RName    Varchar(100)                  
	DECLARE @RetName  Varchar(100)                  
	DECLARE @RtrId   INT                  
	DECLARE @RetCode  Varchar(100)                  
	DECLARE @MonthId     INT                  
	DECLARE @YearId      INT                   
	DECLARE @Qty      INT                  
	DECLARE @GAmt     Numeric(38,6)                  
	DECLARE @NetAmt     Numeric(38,6)                  
	DECLARE @Monthname   varchar(8000)                  
	DECLARE @sStrql varchar(8000)                  
	DECLARE @Cnt as INT                  
	DECLARE @MntCnt as INT                  
	         
	SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'                          
	SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'                          
	SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'                          
	SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'                          
	SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'                    
	SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'                    
	          
	      
	-------------------FILTER OUT THE REQUIRED RECORDS HERE                  
	SELECT a.* INTO #SALINV FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D  ,TBL_GR_BUILD_RH E                  
	WHERE  salinvdate between @pi_fromdate and @pi_todate                   
	AND A.RMID=B.RMID AND B.RMNAME LIKE @PI_FILTER5 and E.RTRID=A.RTRID                    
	and DLVSTS in (4,5) and C.SMID=A.SMID AND C.SMNAME LIKE @PI_FILTER1  AND A.RTRID=D.RTRID                   
	AND D.RTRNAME LIKE @PI_FILTER4 AND E.HASHPRODUCTS LIKE @PI_FILTER2                    
	     
	SELECT A.* INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D                  
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID AND  HASHPRODUCTS LIKE @PI_FILTER6                   
	-----------------------------------------------------------------         
	SELECT   
	Jcmid,JcmJc,ColName,JCMSDT,JCMEDT INTO #JCWISE FROM         
	(Select A.JcmJc,A.Jcmid,A.JCMSDT,A.JCMEDT,  'JC'+ Cast(A.JcmJc as varchar(10)) +'-'+ Cast(B.JCMYR as varchar(10)) as ColName----,JcmSDt,JcmEdt          
	From JCMonth A INNER JOIN JCMAST B ON A.JCMID=B.JCMID Where           
	A.JcmId in ( Select Jcmid From JcMast Where JcmYr between Year(@pi_fromdate) and Year(@pi_todate) )          
	and @pi_fromdate between JcmSdt and  JcmEdt           
	or  @pi_todate between JcmSdt and  JcmEdt          
	Or  JCmSdt between @pi_fromdate and @pi_todate            
	or  JcmSdt between @pi_fromdate and @pi_todate           
	) A order by A.Jcmid,A.JcmJc           
	------------------------------------------------------------------------              
	SELECT   
	SMNAME [Salesman Name],RMNAME [Route Name] ,RH.HIERARCHY3CAP [Retailer Hierarchy 1] ,  
	RH.HIERARCHY2CAP [Retailer Hierarchy 2],RH.HIERARCHY1CAP [Retailer Hierarchy 3],RET.RTRCODE [Retailer Code],  
	RET.RTRNAME [Retailer Name],CAST(0 AS INT) AS  [Total Quantity],CAST(0 AS NUMERIC(18,6)) AS  [Gross Amount],  
	CAST(0 AS NUMERIC(18,6)) AS [Net Amount]                
	INTO #OVERALL                  
	FROM                   
	#JCWISE,#SALINV SI,#SALESINVOICEPRODUCT SP,RETAILER RET,SALESMAN SM,ROUTEMASTER RM,                  
	TBL_GR_BUILD_RH RH,TBL_GR_BUILD_PH PH                  
	WHERE                 
	salinvdate BETWEEN JCMSDT AND JCMEDT AND DLVSTS in (4,5) AND                 
	SI.SALID=SP.SALID AND SI.RTRID=RET.RTRID AND SI.RTRID=RH.RTRID                   
	AND PH.PRDID=SP.PRDID AND SM.SMID=SI.SMID AND RM.RMID=SI.RMID ----------------and si.rtrid  = 28                  
	GROUP BY SMNAME,RMNAME,RET.RTRCODE,RET.RTRNAME,RH.HIERARCHY2CAP,RH.HIERARCHY1CAP,RH.HIERARCHY3CAP               
	---------------------------------------------------------------------------------------------           
	 
	DECLARE @C_SSQL  varchar(8000)                  
	DECLARE @Column  Varchar(100)                  
	DECLARE @YearCnt  INT                  
	DECLARE @monthCnt INT                  
	DECLARE @COLNAME VARCHAR(8000)                
	DECLARE  @sColumnName Varchar(8000)                  
	DECLARE  @sColumnNameTable Varchar(8000)                  
	DECLARE  @sColumnNameSum   Varchar(8000)                  
	DECLARE @iCnt INT                  
	Set @iCnt = 0                  
	Set @sColumnName = ''                  
	Set @sColumnNameTable = ''                  
	DECLARE @JCMJC INT                
	DECLARE @JCMYR INT           
	DECLARE @JCMID INT           
	    
	     
	DECLARE Column_Cur CURSOR FOR                  
	SELECT   
	jcmJc,Jcmid,COLNAME --RIGHT(COLNAME,10)                  
	FROM #JCWISE   
	Order By Jcmid asc,jcmJc --LEFT(COLNAME,4)--RIGHT(COLNAME,10)                
	OPEN Column_Cur                   
	FETCH NEXT FROM Column_Cur INTO @JCMJC, @JCMID,@Column                
	WHILE @@FETCH_STATUS = 0                  
	BEGIN                  
	print @column                
	SET @C_SSQL='ALTER TABLE #OverAll  ADD ['+ @Column +'] NUMERIC(38,6) NOT NULL DEFAULT 0 WITH VALUES'                  
	EXEC (@C_SSQL)                  
		If @sColumnName = ''                  
		BEgin                  
			SET @sColumnName =  '['+@Column+']'                  
			SET @sColumnNameTable = '['+@Column+']' + ' NUMERIC(38,6)'                  
			SET @sColumnNameSum = 'Sum(' + '['+@Column+']' + ') ' + '['+@Column+']'                   
		END                  
	SET @iCnt=@iCnt+1                  
	FETCH NEXT FROM Column_Cur INTO  @JCMJC, @JCMID,@Column                
	END                  
	CLOSE Column_Cur                  
	DEALLOCATE Column_Cur                  
	     
	     
	DECLARE @FielName1 as Varchar(50)                
	DECLARE @Fromdate as DATETIME                
	DECLARE @Todate as DATETIME                
	DECLARE @SSQL as Varchar(8000)                
	    
	DECLARE Cur_LastYear CURSOR                
	FOR SELECT ColName,JcmSdt,JcmEdt FROM #JCWISE  Order By JcmJc              
	OPEN Cur_LastYear                
	FETCH NEXT FROM Cur_LastYear INTO @FielName1,@Fromdate,@Todate                
	WHILE @@FETCH_STATUS=0                
	BEGIN          
	SELECT SM.SMNAME,SI.RtrId,R.RTRCODE,RM.RMNAME,CAST(SUM(SIP.BASEQTY) AS INT)QTY,SUM(SIP.PRDGROSSAMOUNT)GAMT,SUM(SIP.PRDNETAMOUNT) NETAMT        
	INTO #TempCurYearSales                 
	FROM #SALESINVOICEPRODUCT SIP                
	INNER JOIN SalesInvoice SI  ON SI.Salid=SIP.Salid     
	INNER JOIN Salesman SM on SM.SmId=SI.SmId    
	INNER JOIN RouteMaster RM  ON RM.RMID=SI.RMID    
	INNER JOIN Retailer R ON R.RTRID=SI.RTRID                
	WHERE  SI.Salinvdate Between @Fromdate and  @Todate AND SI.DLVSTS in (4,5)                  
	GROUP BY SI.RtrId,SM.SMNAME,RM.RMNAME,R.RTRCODE                
	SET @ssql ='Update RJ SET ['+ @FielName1 +']=T.NETAMT FROM #OVERALL RJ  INNER JOIN #TempCurYearSales T'+         
	' ON [Retailer Code]=T.RTRCODE AND [Salesman Name]=T.SMNAME AND [Route Name]=T.RMNAME '      
	EXEC(@SSQL)                
	DROP TABLE #TempCurYearSales                
	FETCH NEXT FROM Cur_LastYear INTO  @FielName1,@Fromdate,@Todate                
	END                
	CLOSE Cur_LastYear                
	DEALLOCATE Cur_LastYear                
	     
	UPDATE A SET [Net Amount]=B.NETAMT,[Gross Amount]=B.GAMT,[Total Quantity]=B.QTY FROM #OVERALL A INNER JOIN                 
	(      
	SELECT SM.SMNAME,R.RTRCODE,RM.RMNAME,CAST(SUM(SIP.BASEQTY) AS INT)QTY,SUM(SIP.PRDGROSSAMOUNT)GAMT,SUM(SIP.PRDNETAMOUNT) NETAMT                  
	FROM #SALESINVOICEPRODUCT SIP                
	INNER JOIN SalesInvoice SI  ON SI.Salid=SIP.Salid       
	INNER JOIN Salesman SM on SM.SmId=SI.SmId    
	INNER JOIN RouteMaster RM  ON RM.RMID=SI.RMID    
	INNER JOIN Retailer R ON R.RTRID=SI.RTRID          
	WHERE  SI.Salinvdate Between @pi_fromdate and  @pi_Todate AND SI.DLVSTS in (4,5)                  
	GROUP BY SM.SMNAME,R.RTRCODE,RM.RMNAME  
	)B ON [Retailer Code]=B.RTRCODE  AND [Salesman Name]=B.SMNAME  AND [Route Name]=B.RMNAME  
	      
	Select  'Retailer Buying Trend-JCWise Report',* from #OverAll    

	END     
GO
-- JayaKumar Script Ended
--Vasanth Script Starts Here
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Fn_ReturnModernTradeClaim' AND XTYPE IN('TF','FN'))
DROP FUNCTION [dbo].[Fn_ReturnModernTradeClaim]
GO
CREATE FUNCTION [dbo].[Fn_ReturnModernTradeClaim](@Pi_ClmId INT,@Pi_FrmDate DateTime,@Pi_ToDate DateTime,@Pi_CmpId INT,@Pi_RtrId INT,@Pi_PrdHierLvl INT,@Pi_PrdHierVal INT)
RETURNS @SplDiscountClaim TABLE
	(
		SalID	 	BigInt,
		SalInvNo 	nVarChar(100),
		SalInvDate	Datetime,
		Status		INT,
		RtrCode		nvarchar(50),
		RtrName		nVarChar(100),
		SpentAmt	Numeric(38,2),
		ClaimAmt	Numeric(38,2),
		RecAmt		Numeric(38,2),
		[Type]		TinyINT,
		Quantity	BigInt,
		PrdId		INT
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnModernTradeClaim
* PURPOSE: Returns the Special Discount Claim
* NOTES: 
* CREATED: MarySubashini.S	18-06-2010
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
SELECT * FROM Fn_ReturnModernTradeClaim(0,'2007-01-01','2007-12-31',2)
*********************************/
	INSERT INTO @SplDiscountClaim (SalID,SalInvNo,SalInvDate,Status,RtrCode,RtrName,SpentAmt,ClaimAmt,RecAmt,Type,Quantity,PrdId)
	SELECT A.SalId,A.SalInvno,SalInvDate,0 as Status,R.RtrCode,R.RtrName,SUM(PrdSplDiscAmount) as SpentAmt,SUM(ClaimablePercOnMRP) as ClaimAmt,0 as RecAmt,1,SUM(BaseQty) as Quantity,B.PrdId
		FROM SalesInvoice A INNER JOIN SalesInvoiceProduct B 
		ON A.SalId = B.SalId 
		INNER JOIN (SELECT DISTINCT P.PrdId,PB.PrdBatId,PBL.LcnId 
	FROM ProductCategoryValue PCV1 INNER JOIN ProductCategoryValue PCV2 ON PCV2.PrdCtgValLinkCode LIKE (CAST(PCV1.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%') 
	INNER JOIN Product P ON P.PrdCtgValMainId = PCV2.PrdCtgValMainId AND P.PrdStatus=1 AND P.PrdType<>3 AND 
	PCV1.PrdCtgValMainId=CASE @Pi_PrdHierVal WHEN 0 THEN P.PrdCtgValMainId ELSE @Pi_PrdHierVal END 
	INNER JOIN ProductBatch PB ON P.PrdId = PB.PrdId AND PB.Status=1 
	INNER JOIN ProductBatchLocation PBL ON P.PrdId = PBL.PrdId) T ON T.PrdId=B.PrdId AND T.PrdBatId=B.PrdBatId AND A.LcnId=T.LcnId
		INNER JOIN Retailer R ON A.RtrId = R.RtrId AND R.RtrStatus=1
		INNER JOIN Product P ON B.PrdId = P.PrdId AND T.PrdId=P.PrdId
		WHERE B.SPLDiscClaimId IN (0,@Pi_ClmId) AND P.CmpId = @Pi_CmpId AND 
		A.SalInvDate Between @Pi_FrmDate AND @Pi_ToDate AND A.Dlvsts in (4,5) AND 
		A.RtrId = (CASE @Pi_RtrId WHEN 0 THEN R.RtrId ELSE @Pi_RtrId END)
		GROUP BY A.SalId,A.SalInvno,SalInvDate,R.RtrCode,R.RtrName,B.PrdId
		HAVING SUM(ClaimablePercOnMRP) > 0
	INSERT INTO @SplDiscountClaim (SalID,SalInvNo,SalInvDate,Status,RtrCode,RtrName,SpentAmt,ClaimAmt,RecAmt,Type,Quantity,PrdId)
	SELECT SI.SalId,SI.SalInvNo,SalInvDate,0 as Status,RT.RtrCode,RT.RtrName,
		SUM(Sp.BaseQty * (B.PrdBatDetailValue-D.PrdBatDetailValue)) as SpentAmt,0.00 as ClaimAmt,0.00 as RecAmt,1,SUM(BaseQty) as Quantity,SP.PrdId
		FROM SalesInvoice SI 
		INNER JOIN Retailer RT ON SI.RtrId=RT.RtrId 
		INNER JOIN SalesInvoiceProduct SP ON SI.SalID = SP.SalID
		INNER JOIN Product PR WITH (NOLOCK) ON SP.PrdId = PR.PrdId 
		INNER JOIN ProductBatch A (NOLOCK) ON A.PrdId = PR.PrdId AND A.PrdBatId = SP.PrdBatID
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID
		INNER JOIN BatchCreation C (NOLOCK) ON
		C.BatchSeqId = A.BatchSeqId And B.SlNo = C.SlNo And C.SelRte = 1
		AND B.PriceId=SP.SplPriceId
		INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID
		AND D.PriceId=SP.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON
		E.BatchSeqId = A.BatchSeqId And D.SlNo = E.SlNo And E.SelRte = 1 AND
		A.PrdId=SP.PrdId AND A.PrdBatId= SP.PrdBatId
		WHERE SI.SalInvDate Between @Pi_FrmDate and @Pi_ToDate
		AND SI.dlvsts in (4,5) AND SP.SplDiscClaimId IN (0,@Pi_ClmId)
		AND PR.CmpId= @Pi_CmpId 
		AND SI.RtrId = (CASE @Pi_RtrId WHEN 0 THEN RT.RtrId ELSE @Pi_RtrId END)
		GROUP BY SI.SalId,SI.SalInvNo,SalInvDate,RT.RtrCode,RT.RtrName,SP.PrdId
  		Having SUM(Sp.BaseQty * (B.PrdBatDetailValue-D.PrdBatDetailValue)) > 0
	INSERT INTO @SplDiscountClaim (SalID,SalInvNo,SalInvDate,Status,RtrCode,RtrName,SpentAmt,ClaimAmt,RecAmt,Type,Quantity,PrdId)
	SELECT A.ReturnId,A.ReturnCode,ReturnDate,0 as Status,R.RtrCode,R.RtrName,-1 * SUM(PrdSplDisAmt) as SpentAmt,-1 * SUM(ClaimablePercOnMRP) as ClaimAmt,0 as RecAmt,2,SUM(BaseQty) as Quantity,B.PrdId
		FROM ReturnHeader A INNER JOIN ReturnProduct B ON A.ReturnId = B.ReturnId INNER JOIN SalesInvoice SI ON SI.SalId=B.SalId
		INNER JOIN (SELECT DISTINCT P.PrdId,PB.PrdBatId,PBL.LcnId 
	FROM ProductCategoryValue PCV1 INNER JOIN ProductCategoryValue PCV2 ON PCV2.PrdCtgValLinkCode LIKE (CAST(PCV1.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%') 
	INNER JOIN Product P ON P.PrdCtgValMainId = PCV2.PrdCtgValMainId AND P.PrdStatus=1 AND P.PrdType<>3 AND 
	PCV1.PrdCtgValMainId=CASE @Pi_PrdHierVal WHEN 0 THEN P.PrdCtgValMainId ELSE @Pi_PrdHierVal END 
	INNER JOIN ProductBatch PB ON P.PrdId = PB.PrdId AND PB.Status=1 
	INNER JOIN ProductBatchLocation PBL ON P.PrdId = PBL.PrdId) T ON T.PrdId=B.PrdId AND T.PrdBatId=B.PrdBatId AND T.LcnId=SI.LcnId
		INNER JOIN Retailer R ON A.RtrId = R.RtrId 
		INNER JOIN Product P ON B.PrdId = P.PrdId AND T.PrdId=P.PrdId
		WHERE B.SPLDiscClaimId IN (0,@Pi_ClmId) AND P.CmpId = @Pi_CmpId AND 
		A.ReturnDate Between @Pi_FrmDate AND @Pi_ToDate AND A.Status = 0
		AND A.RtrId = (CASE @Pi_RtrId WHEN 0 THEN R.RtrId ELSE @Pi_RtrId END)
		GROUP BY A.ReturnId,A.ReturnCode,ReturnDate,R.RtrCode,R.RtrName,B.PrdId
		Having SUM(PrdSplDisAmt) > 0
	INSERT INTO @SplDiscountClaim (SalID,SalInvNo,SalInvDate,Status,RtrCode,RtrName,SpentAmt,ClaimAmt,RecAmt,Type,Quantity,PrdId)
	SELECT SI.ReturnId,SI.ReturnCode,ReturnDate,0 as Status,RT.RtrCode,RT.RtrName,
		-1 * SUM(Sp.BaseQty * (B.PrdBatDetailValue-D.PrdBatDetailValue)) as SpentAmt,0.00 as ClaimAmt,0.00 as RecAmt,2,SUM(BaseQty) as Quantity,SP.PrdId
		FROM ReturnHeader SI 
		INNER JOIN Retailer RT ON SI.RtrId=RT.RtrId 
		INNER JOIN ReturnProduct SP ON SI.ReturnId = SP.ReturnId
		INNER JOIN Product PR WITH (NOLOCK) ON SP.PrdId = PR.PrdId 
		INNER JOIN ProductBatch A (NOLOCK) ON A.PrdId = PR.PrdId AND A.PrdBatId = SP.PrdBatID
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID
		INNER JOIN BatchCreation C (NOLOCK) ON
		C.BatchSeqId = A.BatchSeqId And B.SlNo = C.SlNo And C.SelRte = 1
		AND B.PriceId=SP.SplPriceId
		INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID
		AND D.PriceId=SP.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON
		E.BatchSeqId = A.BatchSeqId And D.SlNo = E.SlNo And E.SelRte = 1 AND
		A.PrdId=SP.PrdId AND A.PrdBatId= SP.PrdBatId
		WHERE SI.ReturnDate Between @Pi_FrmDate and @Pi_ToDate
		AND SI.Status = 0 AND SP.SplDiscClaimId IN (0,@Pi_ClmId)
		AND PR.CmpId= @Pi_CmpId 
		AND SI.RtrId = (CASE @Pi_RtrId WHEN 0 THEN RT.RtrId ELSE @Pi_RtrId END)
		GROUP BY SI.ReturnId,SI.ReturnCode,ReturnDate,RT.RtrCode,RT.RtrName,SP.PrdId
  		HAVING SUM(Sp.BaseQty * (B.PrdBatDetailValue-D.PrdBatDetailValue)) > 0
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ComputeOId' AND XTYPE='P')
DROP PROCEDURE [Proc_ComputeOId]
GO
CREATE Procedure [dbo].[Proc_ComputeOId]  
(  
	@Pi_RowId  INT,  
	@Pi_CalledFrom  INT,  
	@Pi_Oid Numeric(36,4),  
	@Pi_Octroi Numeric(36,4),  
	@Pi_UserId  INT ,  
	@Pi_Lsp Numeric(36,4) OutPut,  
	@Pi_Gross Numeric(36,4) OutPut,  
	@Pi_NetValue Numeric(36,4) OutPut   
)  
AS  
/*********************************  
* PROCEDURE : Proc_ComputeOId  
* PURPOSE : To Calculate the Line Level LSP and OID  
* CREATED : MURUGAN  
* CREATED DATE : 24/05/2009  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
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
BEGIN  
SET NOCOUNT ON  
DECLARE @TaxSetting TABLE  
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
DECLARE @PrdBatTaxGrp   INT  
DECLARE @RtrTaxGrp   INT  
DECLARE @TaxSlab  INT  
DECLARE @MRP   NUMERIC(28,10)  
DECLARE @SellingRate  NUMERIC(28,10)  
DECLARE @PurchaseRate  NUMERIC(28,10)  
DECLARE @TaxableAmount  NUMERIC(28,10)  
DECLARE @ParTaxableAmount NUMERIC(28,10)  
DECLARE @CD NUMERIC(28,10)  
DECLARE @TaxPer   NUMERIC(38,2)  
DECLARE @TaxId   INT  
Declare @Octroi NUMERIC(36,10)  
Declare @CDAmt NUMERIC(36,10)  
Declare @ActTaxAmt NUMERIC(36,10)  
Declare @SellingRateWoTax NUMERIC(36,10)  
Declare @CDFACTOR NUMERIC(36,10)  
Declare @DM NUMERIC(36,10)  
Declare @BaseQty NUMERIC(36,10)  
Declare @ActBaseQty Int  
Declare @TotalTax Numeric(36,4)   
 --CD FROM BATCH  
 SELECT @CD =ISnull(B.PrdBatDetailValue,0) FROM  
 ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)  
 ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1  
 INNER JOIN BatchCreation C (NOLOCK)ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.Refcode='E'  
 and C.Slno=5 and C.MRP=0 and C.SelRte=0 and C.ListPrice=0  
 INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 and D.slno=5  
 INNER JOIN BilledPrdHdForTax H (NOLOCK) On A.PrdId = H.PrdId AND A.PrdBatID = H.PrdBatID  
 and B.PrdBatID=H.PrdBatID and H.RowId = @Pi_RowId AND H.UsrId = @Pi_UserId AND H.TransId = @Pi_CalledFrom  
 SET @CD=ISnull(@CD,0)  
 --DM FROM BATCH  
 SELECT @DM =ISnull(B.PrdBatDetailValue,0) FROM  
 ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)  
 ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1  
 INNER JOIN BatchCreation C (NOLOCK)ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.Refcode='F'  
 and C.Slno=6 and C.MRP=0 and C.SelRte=0 and C.ListPrice=0  
 INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 and D.slno=6  
 INNER JOIN BilledPrdHdForTax H (NOLOCK) On A.PrdId = H.PrdId AND A.PrdBatID = H.PrdBatID  
 and B.PrdBatID=H.PrdBatID and H.RowId = @Pi_RowId AND H.UsrId = @Pi_UserId AND H.TransId = @Pi_CalledFrom  
   
 SET @DM=ISNULL(@DM,0)  
  --To Take the Batch MRP  
 SELECT @MRP = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN  
 BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID  
 AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
 INNER JOIN ProductBatchDetails C (NOLOCK)  
 ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId  
 INNER JOIN BatchCreation D (NOLOCK)  
 ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo  
 AND D.MRP = 1  
 SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK)  INNER JOIN  
 BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID  
 AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
 SELECT @BaseQty= Isnull(Cast(BaseQty as Numeric(18,4))/NullIf(Cast(UG.ConversionFactor as Numeric(18,4)),0),0) ,@ActBaseQty=Isnull(BaseQty,0) FROM ProductBatch A (NOLOCK)  INNER JOIN  
 BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID  
 AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
 INNER JOIN Product  P  (NOLOCK) ON P.Prdid=A.prdid and B.Prdid=P.Prdid  
 Inner Join Uomgroup Ug (NOLOCK) On Ug.Uomgroupid=P.UomGroupId  
 INNER JOIN UOMMASTER UM (NOLOCK) ON UM.UomId = UG.UomId  
 WHERE UM.UOmid=(Select Max(uomid) from UomMaster with (nolock))  
 SELECT @RtrTaxGrp = TaxGroupId FROM Supplier A (NOLOCK) INNER JOIN  
 BilledPrdHdForTax B (NOLOCK) On A.SpmId = B.RtrId  
 AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId  
 AND B.TransId = @Pi_CalledFrom  
 INSERT INTO @TaxSetting (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)  
 SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal  
 FROM TaxSettingMaster A (NOLOCK) INNER JOIN  
 TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId  
 INNER JOIN BilledPrdHdForTax C (NOLOCK) ON C.BillSeqId = B.BillSeqId  
 WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp AND C.UsrId = @Pi_UserId  
 AND C.RowId = @Pi_RowId AND C.TransId = @Pi_CalledFrom  
 AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE  
 RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)  
DELETE FROM PurchaseTaxOID WHERE RowId = @Pi_RowId AND UsrId = @Pi_UserId  
  AND TransId = @Pi_CalledFrom  
 DECLARE  CurOIdTax CURSOR FOR  
 SELECT DISTINCT TaxSlab FROM @TaxSetting  
 OPEN CurOIdTax  
 FETCH NEXT FROM CurOIdTax INTO @TaxSlab  
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
   IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1  
   AND ColId = 0 and ColVal >= 0)  
   BEGIN  
     --To Get the Tax Percentage for the selected slab  
     SELECT @TaxPer = ColVal FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1  
     AND ColId = 0  
     --To Get the TaxId for the selected slab  
     SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1  
     AND ColId > 0  
     SET @TaxableAmount=1  
     SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM [PurchaseTaxOID] A (NOLOCK)  
     INNER JOIN @TaxSetting B ON A.TaxId = B.ColVal AND A.RowId = @Pi_RowId  
     AND A.UsrId = @Pi_UserId AND B.ColType = 3 AND B.TaxSlab = @TaxSlab  
     AND A.TransId = @Pi_CalledFrom  
    
     
     --Insert the New Tax Amounts  
     INSERT INTO PurchaseTaxOID (RowId,PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,  
     TaxableAmount,TaxAmount,TaxValue,OctroiPer,OctroiPerVal,CDPer,CDPerVal,SellRateWOTax,  
     SellRateTax,[CDFact],[OCTFact],[TotalFact],BaseQty ,Usrid,TransId)  
     SELECT @Pi_RowId,B.PrdId,B.PrdBatId,@TaxId,@TaxSlab,@TaxPer,  
     @TaxableAmount,cast(@TaxableAmount * (@TaxPer / 100 ) AS NUMERIC(28,10)),  
     Cast((@TaxPer / 100 ) AS NUMERIC(28,10)),@Pi_Octroi,0 as OctroiPerVal,  
     Isnull(@CD,0),0 as CDPerVal,0 as SellRateWOTax,0 as SellRateTax,  
     (@CD*(@TaxPer / 100 )),(@CD*(@Pi_Octroi/100)),(@CD*@Pi_Octroi*(@TaxPer / 100 ))/100,@BaseQty,  
     @Pi_UserId,@Pi_CalledFrom FROM BilledPrdHdForTax B (NOLOCK) WHERE  
     B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom      
        
    
 END  
 FETCH NEXT FROM CurOIdTax INTO @TaxSlab  
 END  
 CLOSE CurOIdTax  
 DEALLOCATE CurOIdTax  
 Select sum(TaxAmount) as TaxAmt ,Prdid,Prdbatid,RowId,TransId,Usrid Into #TaxSum  
 From PurchaseTaxOID B (NOLOCK)  
 Where B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
 Group by Prdid,Prdbatid,RowId,TransId,Usrid   
 Update PT Set OctroiPerVal=(@TaxableAmount+TaxAmt) *(@Pi_Octroi/100),  
 CDPerVal=(@TaxableAmount+TaxAmt+((@TaxableAmount+TaxAmt) *(@Pi_Octroi/100)))*(Isnull(@CD,0)/100),  
 SellRateWOTax=(@TaxableAmount+(TaxAmt+(@TaxableAmount+TaxAmt) *(@Pi_Octroi/100)+(@TaxableAmount+TaxAmt+((@TaxableAmount+TaxAmt) *(@Pi_Octroi/100)))*(@CD/100))-Taxamt),  
 SellRateTax=((@TaxableAmount+(TaxAmt+(@TaxableAmount+TaxAmt) *(@Pi_Octroi/100)+(@TaxableAmount+TaxAmt+((@TaxableAmount+TaxAmt) *(@Pi_Octroi/100)))*(@CD/100))-Taxamt))*TaxValue  
 FROM PurchaseTaxOID PT (NOLOCK)  INNER JOIN  #TaxSum TS On  
 PT.Prdid=Ts.Prdid and PT.Prdbatid=TS.Prdbatid  
 and PT.Rowid=TS.RowId and PT.Usrid=TS.Usrid  
 and PT.TransId=Ts.Transid  
 WHere PT.RowId = @Pi_RowId AND PT.UsrId = @Pi_UserId AND PT.TransId = @Pi_CalledFrom  
 Select @ActTaxAmt=Isnull(sum(SellRateTax),0), @SellingRateWoTax=SellRatewoTax,  
 @CDFACTOR=1+((Isnull(@CD,0)+OctFact+Sum(CDFACT+TotalFact))/100)  
From PurchaseTaxOID B (NOLOCK) Where  
 B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
 Group by Prdid,Prdbatid,RowId,TransId,Usrid,SellRatewoTax,OctFact   
   
   
 SET @SellingRateWoTax=(@SellingRateWoTax+@ActTaxAmt)+(((@SellingRateWoTax+@ActTaxAmt)*Isnull(@DM,0))/100)  
   
 --OID Value Deducted  
 Set @Pi_NetValue=ISnull((@MRP/Nullif(@SellingRateWoTax,0)),0)-Isnull(@Pi_Oid/(Nullif(@CDFACTOR,0))*@BaseQty,0)  
 Set @SellingRateWoTax=ISnull((@MRP/Nullif(@SellingRateWoTax,0)),0)----Isnull(@Pi_Oid/(Nullif(@CDFACTOR,0))*@BaseQty,0)  
 --UPDATE GROSS  
 Update  BP Set BP.ColValue=ISNULL(@SellingRateWoTax,0)  FROM PurchaseTaxOID PT  
 INNER JOIN BilledPrdDtForTax BP ON BP.Rowid=PT.Rowid and BP.Usrid=Pt.Usrid  
 and BP.TransId=PT.TransID  
 WHERE BP.Colid In(3) and BP.Rowid=@Pi_RowId  and BP.Usrid=@Pi_UserId and BP.TransId=@Pi_CalledFrom  
 --UPDATE GROSS  
 Update  BP Set BP.ColValue=ISNULL(@SellingRateWoTax,0)  FROM PurchaseTaxOID PT  
 INNER JOIN BilledPrdDtForTax BP ON BP.Rowid=PT.Rowid and BP.Usrid=Pt.Usrid  
 and BP.TransId=PT.TransID  
 WHERE BP.Colid In(Select Max(Colid) from BilledPrdDtForTax BT where BT.Rowid=@Pi_RowId  and BT.Usrid=@Pi_UserId and BT.TransId=@Pi_CalledFrom) and BP.Rowid=@Pi_RowId  and BP.Usrid=@Pi_UserId and BP.TransId=@Pi_CalledFrom  
 --OID VALUE UPDATE  
 Update  BP Set BP.ColValue=ISNULL(@Pi_Oid/(@CDFACTOR)*@BaseQty ,0) FROM PurchaseTaxOID PT  
 INNER JOIN BilledPrdDtForTax BP ON BP.Rowid=PT.Rowid and BP.Usrid=Pt.Usrid  
 and BP.TransId=PT.TransID  
 WHERE BP.Rowid=@Pi_RowId  and BP.Usrid=@Pi_UserId and BP.TransId=@Pi_CalledFrom and BP.Colid =6  
   
 --GET TOTAL TAX  
 SELECT @TotalTax=Isnull(sum(TaxAmount),0) FROM BilledPrdDtCalculatedTax (NOLOCK) WHERE Rowid=@Pi_RowId  and Usrid=@Pi_UserId and TransId=@Pi_CalledFrom  
 --OCTROI VALUE UPDATE  
 Update  BP Set BP.ColValue=ISNULL((@SellingRateWoTax+@TotalTax)*(@Pi_Octroi/100),0) FROM PurchaseTaxOID PT  
 INNER JOIN BilledPrdDtForTax BP ON BP.Rowid=PT.Rowid and BP.Usrid=Pt.Usrid  
 and BP.TransId=PT.TransID  
 WHERE BP.Rowid=@Pi_RowId  and BP.Usrid=@Pi_UserId and BP.TransId=@Pi_CalledFrom and BP.Colid =8  
 ---FIND LIST PRICE  
 SET @Pi_Lsp =Isnull(@SellingRateWoTax/Nullif(@ActBaseQty,0),0)  
 SET @Pi_Gross=Isnull(@SellingRateWoTax,0)  
   
 RETURN  
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_ClusterMaster' AND XTYPE='P')
DROP PROCEDURE [Proc_Cn2Cs_ClusterMaster]
GO
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_ClusterMaster]
/*    
BEGIN TRANSACTION    
EXEC Proc_Cn2Cs_ClusterMaster 0    
SELECT * FROM Cn2Cs_Prk_ClusterMaster    
SELECT * FROM errorlog    
ROLLBACK TRANSACTION    
*/      
(    
 @Po_ErrNo INT OUTPUT    
)    
AS    
/*********************************    
* PROCEDURE  : Proc_Cn2Cs_ClusterMaster    
* PURPOSE  : To validate the downloaded Cluster details from Console    
* CREATED  : Nandakumar R.G    
* CREATED DATE : 30/07/2010    
* MODIFIED    
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
* {date} {developer}  {brief modification description}    
*********************************/    
SET NOCOUNT ON    
BEGIN    
 DECLARE @TabName  NVARCHAR(100)    
 DECLARE @ErrDesc  NVARCHAR(1000)    
 DECLARE @ClusterCode  NVARCHAR(50)    
 DECLARE @ClusterName   NVARCHAR(100)    
 DECLARE @Remarks    NVARCHAR(200)    
 DECLARE @Salesman  NVARCHAR(10)    
 DECLARE @Retailer  NVARCHAR(10)    
 DECLARE @AddMast1    NVARCHAR(10)    
 DECLARE @AddMast2    NVARCHAR(10)    
 DECLARE @AddMast3    NVARCHAR(10)    
 DECLARE @AddMast4    NVARCHAR(10)    
 DECLARE @AddMast5    NVARCHAR(10)    
 DECLARE @ClusterId   INT    
 DECLARE @Exist    INT    
 DECLARE @Value   NUMERIC(38,6)    
 DECLARE @PrdCtgLevelCode NVARCHAR(100)    
 DECLARE @CmpPrdCtgId   INT    
 SET @TabName = 'Cn2Cs_Prk_ClusterMaster'    
 SET @Po_ErrNo=0    
 IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsToAvoid')    
 AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)    
 BEGIN    
  DROP TABLE ClsToAvoid     
 END    
 CREATE TABLE ClsToAvoid    
 (    
  ClusterCode NVARCHAR(50)    
 )    
 IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster    
 WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))='')    
 BEGIN    
  INSERT INTO ClsToAvoid(ClusterCode)    
  SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster    
  WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''    
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)    
  SELECT DISTINCT 1,'Cluster Master','ClusterCode','Cluster Code/Name Should not be empty' FROM Cn2Cs_Prk_ClusterMaster    
  WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''    
 END      
 IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster    
 WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes')    
 BEGIN    
  INSERT INTO ClsToAvoid(ClusterCode)    
  SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster    
  WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes'    
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)    
  SELECT DISTINCT 1,'Cluster Master','ClusterCode','Product Category Level:'+PrdCtgLevelCode+' not found' FROM Cn2Cs_Prk_ClusterMaster    
  WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes'    
 END    
     
 DECLARE Cur_ClusterMaster CURSOR    
 FOR SELECT ISNULL(LTRIM(RTRIM([ClusterCode])),''),ISNULL(LTRIM(RTRIM([ClusterName])),''),ISNULL(LTRIM(RTRIM([Remarks])),''),    
 ISNULL(LTRIM(RTRIM([Salesman])),'No'),ISNULL(LTRIM(RTRIM([Retailer])),'No'),ISNULL(LTRIM(RTRIM([AddMast1])),'No'),    
 ISNULL(LTRIM(RTRIM([AddMast2])),'No'),ISNULL(LTRIM(RTRIM([AddMast3])),'No'),ISNULL(LTRIM(RTRIM([AddMast4])),'No'),    
 ISNULL(LTRIM(RTRIM([AddMast5])),'No'),ISNULL([Value],0),ISNULL(LTRIM(RTRIM(PrdCtgLevelCode)),'')    
 FROM Cn2Cs_Prk_ClusterMaster WHERE [DownLoadFlag] ='D' AND    
 ClusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)    
 OPEN Cur_ClusterMaster    
 FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,    
 @AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5,@Value,@PrdCtgLevelCode    
 WHILE @@FETCH_STATUS=0    
 BEGIN      
  SET @Po_ErrNo=0    
  SET @Exist=0    
  IF @AddMast1='Yes'   
  BEGIN    
   SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName=@PrdCtgLevelCode    
  END    
  ELSE    
  BEGIN    
   SET @CmpPrdCtgId=0    
  END    
  IF NOT EXISTS (SELECT * FROM ClusterMaster WHERE ClusterCode=@ClusterCode)    
  BEGIN       
   SET @ClusterId = dbo.Fn_GetPrimaryKeyInteger('ClusterMaster','ClusterId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))    
   SET @Exist=0       
   IF @ClusterId<=(SELECT ISNULL(MAX(ClusterId),0) AS ClusterId FROM ClusterMaster)    
   BEGIN    
    SELECT @ClusterId    
    SET @ErrDesc = 'Reset the counters/Check the system date'    
    INSERT INTO Errorlog VALUES (67,@TabName,'ClusterId',@ErrDesc)    
    SET @Po_ErrNo =1    
   END    
  END    
  ELSE    
  BEGIN    
   SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode       
   SET @Exist=1    
  END      
      
  IF @Exist=1    
  BEGIN    
   EXEC Proc_DependencyCheck 'ClusterMaster',@ClusterId    
   IF (SELECT COUNT(*) FROM TempDepCheck)>0    
   BEGIN    
    SET @Exist=2    
   END       
  END    
  IF @Po_ErrNo=0    
  BEGIN    
   IF @Exist=0    
   BEGIN    
    INSERT INTO ClusterMaster(ClusterId,ClusterCode,ClusterName,Remarks,Status,    
    Availability,LastModBy,LastModDate,AuthId,AuthDate,ClusterValues)       
    VALUES(@ClusterId,@ClusterCode,@ClusterName,@Remarks,1,1,1,GETDATE(),1,GETDATE(),@Value)    
       
    UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterMaster' AND FldName='ClusterId'     
    DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId    
   
    --Update For DownLoaded 
  
    Update  ClusterMaster Set  DownLoaded = 1 Where  ClusterId=@ClusterId     
        
    INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,    
    Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)    
    SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),    
    1,1,GETDATE(),1,GETDATE(),0    
    INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,    
    Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)    
    SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),    
    1,1,GETDATE(),1,GETDATE(),0    
    INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,    
    Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)    
    SELECT @ClusterId,91,'Product',(CASE @AddMast1 WHEN 'Yes' THEN 1 ELSE 0 END),    
    1,1,GETDATE(),1,GETDATE(),@CmpPrdCtgId    
   END      
   ELSE IF @Exist=1    
   BEGIN    
    UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks    
    WHERE ClusterId=@ClusterId   
  
    --Update For DownLoaded  
  
    Update  ClusterMaster Set  DownLoaded = 1 Where  ClusterId=@ClusterId     
        
    DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId    
    INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,    
    Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)    
    SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),    
    1,1,GETDATE(),1,GETDATE(),0    
    INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,    
    Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)    
    SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),    
    1,1,GETDATE(),1,GETDATE(),0    
    INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,    
    Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)    
    SELECT @ClusterId,91,'Product',(CASE @AddMast1 WHEN 'Yes' THEN 1 ELSE 0 END),    
    1,1,GETDATE(),1,GETDATE(),@CmpPrdCtgId    
   END    
   ELSE IF @Exist=2    
   BEGIN    
    UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks    
    WHERE ClusterId=@ClusterId       
   END    
  END    
  FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,    
  @AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5,@Value,@PrdCtgLevelCode    
 END    
 CLOSE Cur_ClusterMaster    
 DEALLOCATE Cur_ClusterMaster    
 UPDATE Cn2Cs_Prk_ClusterMaster SET DownLoadFlag='Y' WHERE    
 DownLoadFlag ='D' AND ClusterCode IN (SELECT ClusterCode FROM ClusterMaster)    
 AND CLusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)    
 RETURN    
END
GO
-- Vasanth Script Ended
if exists (select * from dbo.sysobjects where id = object_id(N'Proc_ReturnSchemeLineWiseUpdate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Proc_ReturnSchemeLineWiseUpdate
GO
/*
BEGIN TRANSACTION
SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=3086
EXEC Proc_ReturnSchemeLineWiseUpdate 84,1,3
SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=3086
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ReturnSchemeLineWiseUpdate]
(
	@Pi_SchId		INT,
	@Pi_Usrid		INT,
	@Pi_TransId		INT
)
/******************************************************************************************
* PROCEDURE	: Proc_ReturnSchemeLineWiseUpdate
* PURPOSE	: To Update Return Scheme Line wise Amount
* CREATED	: Boopathy
* CREATED DATE	: 15/12/2010
* NOTE		: General SP for Returning the Scheme Details for the all type of Schemes
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------
******************************************************************************************/
AS
BEGIN
	DECLARE @FlatAmt	AS	NUMERIC(18,6)
	DECLARE @DiscAmt	AS	NUMERIC(18,6)
	DECLARE @Points		AS	NUMERIC(18,0)
	DECLARE @PrdId		AS	INT
	DECLARE @PrdBatId	AS	INT
	DECLARE @PrdId1		AS	INT
	DECLARE @PrdBatId1	AS	INT
	DECLARE @PrdId2		AS	INT
	DECLARE @PrdBatId2	AS	INT
	DECLARE @PrdId3		AS	INT
	DECLARE @PrdBatId3	AS	INT
	DECLARE @Pi_SalId	AS  INT
	DECLARE @DiscAmt1	AS	NUMERIC(18,6)
	DECLARE @DiscAmt2	AS	NUMERIC(18,6)
	DECLARE @FlatAmt1	AS	NUMERIC(18,6)
	DECLARE @FlatAmt2	AS	NUMERIC(18,6)
	DECLARE @Points1	AS	NUMERIC(18,0)
	DECLARE @Points2	AS	NUMERIC(18,0)
	DECLARE @SlabId		AS	INT

--	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN19' AND Status=0)
--	BEGIN
--		RETURN
--	END
	DECLARE Cur_ReturnHeader CURSOR
	FOR 
		SELECT SalId,SlabId,PrdId,PrdBatId,SUM(Discamt),SUM(Flatamt),SUM(Points) FROM UserFetchReturnScheme 
		WHERE SchId=@Pi_SchId AND Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		AND (Discamt+Flatamt+Points)>0 GROUP BY SalId,SlabId,PrdId,PrdBatId
	OPEN Cur_ReturnHeader
	FETCH NEXT FROM Cur_ReturnHeader INTO @Pi_SalId,@SlabId,@PrdId,@PrdBatId,@DiscAmt,@FlatAmt,@Points
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF @DiscAmt>0
		BEGIN
			IF EXISTS(SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId
						AND PrdId=@PrdId and PrdBatId=@PrdBatId AND @DiscAmt<=(DiscountPerAmount-ReturnDiscountPerAmount))
			BEGIN
				UPDATE SalesInvoiceSchemeLineWise SET ReturnDiscountPerAmount=ReturnDiscountPerAmount+@DiscAmt WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId
			END
			ELSE
			BEGIN
				SELECT @DiscAmt1=(DiscountPerAmount-ReturnDiscountPerAmount) FROM SalesInvoiceSchemeLineWise WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId	
		
				UPDATE SalesInvoiceSchemeLineWise SET ReturnDiscountPerAmount= CASE WHEN DiscountPerAmount<=@DiscAmt1 THEN ReturnDiscountPerAmount+@DiscAmt1 ELSE DiscountPerAmount END WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId
				
				SET @DiscAmt=@DiscAmt-@DiscAmt1
				IF @DiscAmt>0
				BEGIN
					DECLARE Cur_ReturnDisc CURSOR
					FOR SELECT PrdId,PrdBatId,DiscAmt FROM 
						(SELECT SalId,SchId,PrdId,PrdBatId,(DiscountPerAmount-ReturnDiscountPerAmount) AS DiscAmt FROM SalesInvoiceSchemeLineWise 
						WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId) A WHERE NOT EXISTS
						(SELECT B.SalId,B.SchId,B.PrdId,B.PrdBatId FROM UserFetchReturnScheme B WHERE Discamt>0 AND
						 B.SalId=@Pi_SalId AND B.SchId=@Pi_SchId AND B.Usrid=@Pi_Usrid AND B.TransId=@Pi_TransId AND
						 A.SalId=B.SalId AND A.SchId=B.SchId AND A.PrdId=B.PrdId AND A.PrdbatId=B.PrdbatId)
					OPEN Cur_ReturnDisc
					FETCH NEXT FROM Cur_ReturnDisc INTO @PrdId1,@PrdBatId1,@DiscAmt2
					WHILE @@FETCH_STATUS=0
					BEGIN
						IF @DiscAmt>=@DiscAmt2
						BEGIN
							UPDATE SalesInvoiceSchemeLineWise SET ReturnDiscountPerAmount=ReturnDiscountPerAmount+@DiscAmt2 WHERE
							SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId1 and PrdBatId=@PrdBatId1
							SET @DiscAmt=@DiscAmt-@DiscAmt2
						END
						ELSE
						BEGIN
							UPDATE SalesInvoiceSchemeLineWise SET ReturnDiscountPerAmount=ReturnDiscountPerAmount+@DiscAmt WHERE
							SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId1 and PrdBatId=@PrdBatId1
							BREAK
						END
						IF @DiscAmt<=0 BREAK
						FETCH NEXT FROM Cur_ReturnDisc INTO @PrdId1,@PrdBatId1,@DiscAmt2
					END
					CLOSE Cur_ReturnDisc
					DEALLOCATE Cur_ReturnDisc
				END
			END
		END
		IF @FlatAmt>0
		BEGIN
			IF EXISTS(SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId
						AND PrdId=@PrdId and PrdBatId=@PrdBatId AND @FlatAmt<=(FlatAmount-ReturnFlatAmount))
			BEGIN
				UPDATE SalesInvoiceSchemeLineWise SET ReturnFlatAmount=ReturnFlatAmount+@FlatAmt WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId
			END
			ELSE
			BEGIN
				SELECT @FlatAmt1=SUM(FlatAmount-ReturnFlatAmount) FROM SalesInvoiceSchemeLineWise WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId		
	
				UPDATE SalesInvoiceSchemeLineWise SET ReturnFlatAmount=CASE WHEN FlatAmount<=@FlatAmt1 THEN ReturnFlatAmount+@FlatAmt1 ELSE FlatAmount END WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId
				
				SET @FlatAmt=@FlatAmt-@FlatAmt1
				IF @FlatAmt>0
				BEGIN
					DECLARE Cur_ReturnFlat CURSOR
					FOR SELECT PrdId,PrdBatId,FlatAmt FROM 
						(SELECT SalId,SchId,PrdId,PrdBatId,(FlatAmount-ReturnFlatAmount) AS FlatAmt FROM SalesInvoiceSchemeLineWise 
						WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId) A WHERE NOT EXISTS
						(SELECT B.SalId,B.SchId,B.PrdId,B.PrdBatId FROM UserFetchReturnScheme B WHERE Flatamt>0 AND
						 B.SalId=@Pi_SalId AND B.SchId=@Pi_SchId AND B.Usrid=@Pi_Usrid AND B.TransId=@Pi_TransId AND
						 A.SalId=B.SalId AND A.SchId=B.SchId AND A.PrdId=B.PrdId AND A.PrdbatId=B.PrdbatId)
					OPEN Cur_ReturnFlat
					FETCH NEXT FROM Cur_ReturnFlat INTO @PrdId2,@PrdBatId2,@FlatAmt2
					WHILE @@FETCH_STATUS=0
					BEGIN
						IF @FlatAmt>=@FlatAmt2
						BEGIN
							UPDATE SalesInvoiceSchemeLineWise SET ReturnFlatAmount=ReturnFlatAmount+@FlatAmt2 WHERE
							SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId2 and PrdBatId=@PrdBatId2
							SET @FlatAmt=@FlatAmt-@FlatAmt2
						END
						ELSE
						BEGIN
							UPDATE SalesInvoiceSchemeLineWise SET ReturnFlatAmount=ReturnFlatAmount+@FlatAmt WHERE
							SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId2 and PrdBatId=@PrdBatId2
							BREAK
						END
						IF @FlatAmt<=0 BREAK
						FETCH NEXT FROM Cur_ReturnFlat INTO @PrdId2,@PrdBatId2,@FlatAmt2
					END
					CLOSE Cur_ReturnFlat
					DEALLOCATE Cur_ReturnFlat
				END
			END
		END
		IF @Points>0
		BEGIN
			IF EXISTS(SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId
						AND PrdId=@PrdId and PrdBatId=@PrdBatId AND @Points<=(Points-ReturnPoints))
			BEGIN
				UPDATE SalesInvoiceSchemeDtPoints SET ReturnPoints=ReturnPoints+@Points WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId
			END
			ELSE
			BEGIN
				SELECT @Points1=(Points-ReturnPoints) FROM SalesInvoiceSchemeDtPoints WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId			
				UPDATE SalesInvoiceSchemeDtPoints SET ReturnPoints=CASE WHEN Points<=@Points1 THEN ReturnPoints+@Points1 ELSE @Points1 END WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND SlabId=@SlabId AND PrdId=@PrdId and PrdBatId=@PrdBatId
				
				SET @Points=@Points-@Points1
				IF @Points>0
				BEGIN
					DECLARE Cur_ReturnPoint CURSOR
					FOR SELECT PrdId,PrdBatId,Points FROM 
						(SELECT SalId,SchId,PrdId,PrdBatId,(Points-ReturnPoints) AS Points FROM SalesInvoiceSchemeDtPoints 
						WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId) A WHERE NOT EXISTS
						(SELECT B.SalId,B.SchId,B.PrdId,B.PrdBatId FROM UserFetchReturnScheme B WHERE Points>0 AND
						 B.SalId=@Pi_SalId AND B.SchId=@Pi_SchId AND B.Usrid=@Pi_Usrid AND B.TransId=@Pi_TransId AND
						 A.SalId=B.SalId AND A.SchId=B.SchId AND A.PrdId=B.PrdId AND A.PrdbatId=B.PrdbatId)
					OPEN Cur_ReturnPoint
					FETCH NEXT FROM Cur_ReturnPoint INTO @PrdId3,@PrdBatId3,@Points2
					WHILE @@FETCH_STATUS=0
					BEGIN
						IF @Points>=@Points2
						BEGIN
							UPDATE SalesInvoiceSchemeDtPoints SET ReturnPoints=ReturnPoints+@Points2 WHERE
							SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId3 and PrdBatId=@PrdBatId3
							SET @Points=@Points-@Points2
						END
						ELSE
						BEGIN
							UPDATE SalesInvoiceSchemeDtPoints SET ReturnPoints=ReturnPoints+@Points WHERE
							SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId3 and PrdBatId=@PrdBatId3
							BREAK
						END
						IF @Points<=0 BREAK
						FETCH NEXT FROM Cur_ReturnPoint INTO @PrdId3,@PrdBatId3,@Points2
					END
					CLOSE Cur_ReturnPoint
					DEALLOCATE Cur_ReturnPoint
				END
			END
		END
		FETCH NEXT FROM Cur_ReturnHeader INTO @Pi_SalId,@SlabId,@PrdId,@PrdBatId,@DiscAmt,@FlatAmt,@Points
	END
	CLOSE Cur_ReturnHeader
	DEALLOCATE Cur_ReturnHeader
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClaimFreePrdSettlement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClaimFreePrdSettlement]
GO
/*
BEGIN TRANSACTION
DELETE FROM ErrorLog
--SELECT * FROM Cn2Cs_Prk_ClaimFreePrdSettlement
--UPDATE Cn2Cs_Prk_ClaimFreePrdSettlement SET ClaimRefNo='SCH1000379' WHERE ClaimRefNo='SCH1000418'
EXEC Proc_Cn2Cs_ClaimFreePrdSettlement 0
SELECT * FROM ErrorLog
--SELECT * FROM Cn2Cs_Prk_ClaimFreePrdSettlement
--SELECT * FROM ClaimSheetDetail
--SELECT * FROM ClaimSheetHd
SELECT * FROM StockLedger WHERE TransDate='2011-05-12'
SELECT * FROM CreditNoteSupplier
--SELECT * FROM ClaimFreePrdSettlement
--SELECT * FROM ProductBatchLOcation WHERE PrdBatId=1120
ROLLBACK TRANSACTION
*/
CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ClaimFreePrdSettlement]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClaimFreePrdSettlement
* PURPOSE		: To Download the Claim Free Product Settlement details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/05/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @Taction  			INT
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @DebitNoteNumber	NVARCHAR(500)
	DECLARE @CrNoteDate			DATETIME
	DECLARE @CrDbNoteReason		NVARCHAR(500)
	DECLARE @CreditNoteNumber	NVARCHAR(500)
	DECLARE @SpmId				INT
	DECLARE @DebitNo			NVARCHAR(500)
	DECLARE @CreditNo			NVARCHAR(500)
	DECLARE @ClaimNumber		NVARCHAR(500)
	DECLARE @ClmId				INT
	DECLARE @AccCoaId			INT
	DECLARE @ClmGroupId			INT
	DECLARE @ClmGroupNumber		NVARCHAR(500)
	DECLARE @CrNoteAmount		NUMERIC(38,6)
	DECLARE @CmpId				INT
	DECLARE @VocNo				NVARCHAR(500)
	DECLARE @ClaimSheetNo		NVARCHAR(500)
	DECLARE @CmpInvNo			NVARCHAR(500)
	DECLARE @CmpInvDate			DATETIME
	DECLARE @Status				NVARCHAR(100)
	DECLARE @SettlementNo		NVARCHAR(500)
	DECLARE @PrdId				INT
	DECLARE @PrdBatId			INT
	DECLARE @LcnId				INT
	DECLARE @Qty				INT
	DECLARE @Date				DATETIME
	DECLARE @Po_StkPosting		INT 
	
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimFreePrdSettleToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimFreePrdSettleToAvoid	
	END
	CREATE TABLE ClaimFreePrdSettleToAvoid
	(
		ClaimSheetNo NVARCHAR(50),
		ClaimRefNo	 NVARCHAR(50),
		CreditNoteNo NVARCHAR(50)
	)
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')='')
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','ClaimRefNo','Claim Ref No should not be empty for :'+CreditNoteNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE ISNULL(CmpInvNo,'')='' OR ISNULL(CmpInvDate,'')='')
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CmpInvNo,'')='' OR ISNULL(CmpInvDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','CmpInvNo','Company Inv No/Date should not be empty for :'+CreditNoteNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CmpInvNo,'')='' OR ISNULL(CmpInvDate,'')=''
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE CreditNoteAmt<0)
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE CreditNoteAmt<0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Amount','Amount should be greater than zero for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE CreditNoteAmt<0
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE ISNULL(CreditNoteNo,'')='')
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CreditNoteNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Credit Note No','Credit Note No should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CreditNoteNo,'')=''
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE ISNULL(CreditNoteDate,'')='')
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CreditNoteDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Date','Date should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE ISNULL(CreditNoteDate,'')=''
	END
	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
	(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId AND B.SelectMode=1))
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','ClaimRefNo','Claim Reference Number :'+ClaimRefNo+'does not exists'
		FROM Cn2Cs_Prk_ClaimFreePrdSettlement WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)
	END
	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT DISTINCT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Product','Product:'+PrdCCode+' Not Available for Claim:'+ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Claim Free Product Settlement',ClaimRefNo,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
	END
	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
	WHERE PrdCCode+'~'+PrdBatCode
	NOT IN
	(SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId))
	BEGIN
		INSERT INTO ClaimFreePrdSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT DISTINCT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode+'~'+PrdBatCode
		NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Free Product Settlement','Product Batch','Product Batch:'+PrdBatCode+'Not Available for Product:'+PrdCCode+' in Claim:'+ClaimRefNo FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode+'~'+PrdBatCode
		NOT IN
		(SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Claim Free Product Settlement',ClaimRefNo,'Product Batch',PrdCCode,PrdBatCode,'N' FROM Cn2Cs_Prk_ClaimFreePrdSettlement
		WHERE PrdCCode+'~'+PrdBatCode
		NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
	END
	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1
	SET @Date=CONVERT(NVARCHAR(10),GETDATE(),121)
	DECLARE Cur_ClaimSettlement CURSOR	
	FOR SELECT ISNULL(CmpInvNo,''),ISNULL(CmpInvDate,GETDATE()),ISNULL([ClaimSheetNo],''),ISNULL([ClaimRefNo],''),ISNULL([CreditNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CreditNoteDate],121),CAST(ISNULL([CreditNoteAmt],0)AS NUMERIC(38,6)),ISNULL(Status,'Partial')
	FROM Cn2Cs_Prk_ClaimFreePrdSettlement WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CreditNoteNo NOT IN
	(SELECT ClaimRefNo+'~'+CreditNoteNo FROM ClaimFreePrdSettleToAvoid)	
	OPEN Cur_ClaimSettlement
	FETCH NEXT FROM Cur_ClaimSettlement INTO @CmpInvNo,@CmpInvDate,@ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@CrNoteDate,@CrNoteAmount,@Status
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @ErrStatus=1
		SELECT @ClmId=B.ClmId FROM ClaimSheetDetail B INNER JOIN ClaimSheetHd A ON A.ClmId=B.ClmId
		WHERE B.RefCode=@ClaimNumber AND A.ClmCode=@ClaimSheetNo
		SELECT @ClmGroupId=ClmGrpId,@ClmGroupNumber=ClmCode,@CmpId=CmpId FROM ClaimSheetHd WHERE ClmId=@ClmId
		SELECT @AccCoaId=CoaId FROM ClaimGroupMaster WHERE ClmGrpId=@ClmGroupId
		SELECT @SpmId=SpmId FROM Supplier WHERE SpmDefault=1 AND CmpId=@CmpId
		IF @SpmId=0
		BEGIN
			SET @ErrDesc = 'Default Supplier does not exists'
			INSERT INTO Errorlog VALUES (8,'Claim Free Product Settlement','Supplier',@ErrDesc)
			SET @Po_ErrNo=1	
		END
		
		IF @Po_ErrNo=0
		BEGIN		
			SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteSupplier','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SELECT @SettlementNo=dbo.Fn_GetPrimaryKeyString('ClaimFreePrdSettlement','SettlementNo',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			INSERT INTO CreditNoteSupplier(CrNoteNumber,CrNoteDate,SpmId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
			PostedFrom,TransId,PostedRefNo,CrNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			VALUES(@CreditNo,@CrNoteDate,@SpmId,@AccCoaId,9,@CrNoteAmount,0,1,@ClmGroupNumber,16,
			'Cmp-'+@CreditNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteSupplier' AND Fldname = 'CrNoteNumber'

			INSERT INTO ClaimFreePrdSettlement(SettlementNo,SettlementDate,CmpInvNo,CmpInvDate,ClaimSheetNo,ClaimRefNo,CreditNoteNo,CreditNoteDate,
			CreditNoteAmt,PrdId,PrdBatId,Qty,Rate,Amount,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT @SettlementNo,CONVERT(NVARCHAR(10),GETDATE(),121),@CmpInvNo,@CmpInvDate,@ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@CrNoteDate,
			@CrNoteAmount,P.PrdId,PB.PrdBatId,Prk.Qty,Prk.Rate,Prk.Amount,(CASE Prk.Status WHEN 'Settled' THEN 1 ELSE 0 END),
			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
			FROM Cn2Cs_Prk_ClaimFreePrdSettlement Prk,Product P,ProductBatch PB
			WHERE P.PrdId=PB.PrdId AND P.PrdCCOde=Prk.PrdCCOde AND PB.PrdBatCode=Prk.PrdBatCode AND Prk.CmpInvNo=@CmpInvNo AND
			ClaimSheetNo=@ClaimSheetNo AND ClaimRefNo=@ClaimNumber

			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'ClaimFreePrdSettlement' AND Fldname = 'SettlementNo'

			DECLARE Cur_ClaimSettlementPrd CURSOR	
			FOR SELECT P.PrdId,PB.PrdBatId,Prk.Qty
			FROM Cn2Cs_Prk_ClaimFreePrdSettlement Prk,Product P,ProductBatch PB
			WHERE P.PrdId=PB.PrdId AND P.PrdCCOde=Prk.PrdCCOde AND PB.PrdBatCode=Prk.PrdBatCode AND Prk.CmpInvNo=@CmpInvNo AND
			ClaimSheetNo=@ClaimSheetNo AND ClaimRefNo=@ClaimNumber AND DownLoadFlag='D'
			OPEN Cur_ClaimSettlementPrd
			FETCH NEXT FROM Cur_ClaimSettlementPrd INTO @PrdId,@PrdBatId,@Qty
			WHILE @@FETCH_STATUS=0
			BEGIN
				Exec Proc_UpdateStockLedger 12,1,@PrdId,@PrdBatId,@LcnId,@Date,@Qty,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting = 0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 3,1,@PrdId,@PrdBatId,@LcnId,@Date,@Qty,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				END
				FETCH NEXT FROM Cur_ClaimSettlementPrd INTO @PrdId,@PrdBatId,@Qty
			END
			CLOSE Cur_ClaimSettlementPrd
			DEALLOCATE Cur_ClaimSettlementPrd
			
			IF @Status='Partial'
			BEGIN
				UPDATE ClaimSheetDetail SET ReceivedAmount=ReceivedAmount+@CrNoteAmount,CrDbmode=2,CrDbStatus=1,CrDbNotenumber=@CreditNo,Status=1
				WHERE ClmId=@ClmId AND RefCode=@ClaimNumber
			END
			ELSE
			BEGIN
				UPDATE ClaimSheetDetail SET ReceivedAmount=ReceivedAmount+@CrNoteAmount,CrDbmode=2,CrDbStatus=1,CrDbNotenumber=@CreditNo,Status=2
				WHERE ClmId=@ClmId AND RefCode=@ClaimNumber
			END

			UPDATE Cn2Cs_Prk_ClaimFreePrdSettlement SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber AND ClaimSheetNo=@ClaimSheetNo			
		END
		FETCH NEXT FROM Cur_ClaimSettlement INTO @CmpInvNo,@CmpInvDate,@ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@CrNoteDate,@CrNoteAmount,@Status
	END
	CLOSE Cur_ClaimSettlement
	DEALLOCATE Cur_ClaimSettlement
	SET @Po_ErrNo=0
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_Import_ClaimFreePrdSettlement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_Import_ClaimFreePrdSettlement]
GO
----EXEC Proc_Import_ClaimFreePrdSettlement '<Root></Root>'
CREATE   PROCEDURE [Proc_Import_ClaimFreePrdSettlement]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_ClaimFreePrdSettlement
* PURPOSE		: To Insert the records from xml file in the Table Claim Free Product Settlement
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/05/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_ClaimFreePrdSettlement(DistCode,CmpInvNo,CmpInvDate,ClaimSheetNo,ClaimRefNo,CreditNoteNo,
	CreditNoteDate,CreditNoteAmt,PrdCCode,PrdBatCode,Qty,Rate,Amount,Status,DownLoadFlag)
	SELECT DistCode,CmpInvNo,CmpInvDate,ClaimSheetNo,ClaimRefNo,CreditNoteNo,
	CreditNoteDate,CreditNoteAmt,PrdCCode,PrdBatCode,Qty,Rate,Amount,Status,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2CS_ClaimFreePrdSettlement',1)
	WITH (
				[DistCode]				NVARCHAR(50),
				[CmpInvNo]				NVARCHAR(200),
				[CmpInvDate]			DATETIME,
				[ClaimSheetNo]			NVARCHAR(200),
				[ClaimRefNo]			NVARCHAR(200),
				[CreditNoteNo]			NVARCHAR(100),
				[CreditNoteDate]		DATETIME,
				[CreditNoteAmt]			NUMERIC(38,6),
				[PrdCCode]				NVARCHAR(200),
				[PrdBatCode]			NVARCHAR(200),
				[Qty]					NUMERIC(38,0),
				[Rate]					NUMERIC(38,6),
				[Amount]				NUMERIC(38,6),
				[Status]				NVARCHAR(100),			
				[DownLoadFlag]			NVARCHAR(10)
	     ) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
END
GO
Update  tbl_DownloadIntegration  SET PrkTableName = 'Cn2Cs_Prk_ClaimSettlementDetails' ,
SPName = 'Proc_Import_ClaimSettlementDetails'
Where ProcessName = 'Claim Settlement' AND SequenceNo = 29
GO
Update  CustomUpDownload  SET ParkTable = 'Cn2Cs_Prk_ClaimSettlementDetails' ,ImportProcName  = 'Proc_Import_ClaimSettlementDetails'
Where Module = 'Claim Settlement' AND SlNo = 225
GO
if not exists (select * from hotfixlog where fixid = 379)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(379,'D','2011-05-31',getdate(),1,'Core Stocky Service Pack 379')
