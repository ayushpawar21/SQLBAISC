
--[Stocky HotFix Version]=384
Delete from Versioncontrol where Hotfixid='384'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('384','2.0.0.5','D','2011-09-02','2011-09-02','2011-09-02',convert(varchar(11),getdate()),'Major: Product Release FOR PM,CK,B&L-Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 384' ,'384'
GO

--SRF-Nanda-258-001

if not exists (select * from dbo.sysobjects where id = object_id(N'[SchQPSConvDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[SchQPSConvDetails]
	(
		[SchId] [int] NULL,
		[CmpSchCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ConvDate] [datetime] NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-258-002

if not exists (select * from dbo.sysobjects where id = object_id(N'[UomConfig]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[UomConfig]
	(
		[ModuleId] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UomId] [int] NOT NULL,
		[Value] [tinyint] NOT NULL,
		[Availability] [tinyint] NOT NULL,
		[LastModBy] [tinyint] NOT NULL,
		[LastModDate] [datetime] NOT NULL,
		[AuthId] [tinyint] NOT NULL,
		[AuthDate] [datetime] NOT NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-258-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptTrialBalance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptTrialBalance]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptTrialBalance 36,1,0,'BILLTEST',0,0,1

CREATE                        PROCEDURE [dbo].[Proc_RptTrialBalance]
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
SET ANSI_WARNINGS OFF

	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	
	--Filter Variable
	
	DECLARE @FromDate	        AS	DATETIME
	DECLARE @ToDate	 	        AS	DATETIME
	
	DECLARE @CoaLvl	        	AS	INT
	DECLARE @SupZV		        AS	INT
	DECLARE @SupSD			AS	INT
	DECLARE @RptType		AS	INT
	DECLARE @SupJV			AS	INT
	

	DECLARE @Expenses AS	Numeric(38,6)
	DECLARE @Incomes  AS	Numeric(38,6)
	DECLARE @CoaId	  AS 	INT
	DECLARE @ClsStk	  AS 	NUMERIC(38,6)

	DECLARE @OpnPLAmount  AS	Numeric(38,6)

	DECLARE @AcmId		AS INT
	DECLARE @AcmSdt		AS DATETIME
	DECLARE @AcmEdt		AS DATETIME
	DECLARE @CurSdt		AS DATETIME
	DECLARE @PrevDate	AS DATETIME
	--Till Here
	
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CoaLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,43,@Pi_UsrId))
	SET @SupZV = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @SupSD = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,45,@Pi_UsrId))
	SET @SupJV = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,46,@Pi_UsrId))
	SET @RptType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,69,@Pi_UsrId))
	--Till Here
	
	EXEC Proc_OpeningBalance @Pi_RptId,@Pi_UsrId,@FromDate

	--Added By Nanda on 30/03/2009	
	DECLARE Cur_PL CURSOR
	FOR SELECT A.AcmId,MIN(A.AcmSdt) AS AcmSdt,MAX(A.AcmEdt) AS AcmEdt  FROM YearEnd Y,AcPeriod A 
	WHERE Y.AcmId<(
	SELECT AcmId FROM AcPeriod WHERE @ToDate BETWEEN AcmSdt AND AcmEdt)
	AND Y.AcmId=A.AcmId
	GROUP BY A.AcmId

	SET @CurSdt=@FromDate

	SET @OpnPLAmount=0
	OPEN Cur_PL
	FETCH NEXT FROM Cur_PL INTO @AcmId,@AcmSdt,@AcmEdt
	WHILE @@FETCH_STATUS=0
    	BEGIN
		--EXEC Proc_ProfitAndLoss @AcmSdt,@AcmEdt
		EXEC Proc_ReturnProfitLossNew @Pi_RptId,@Pi_UsrId,1,@AcmSdt,@AcmEdt
	
		SELECT @Incomes=SUM(Balance) FROM AccountsDerivedTemplate
		WHERE PlSeq IN (5000000,6000000,7000000,8000000)
	
		SELECT @Expenses=SUM(Balance) FROM AccountsDerivedTemplate
		WHERE PlSeq IN (1000000,2000000,3000000,4000000)

		SET @OpnPLAmount=@OpnPLAmount+@Incomes-@Expenses

		SELECT @ClsStk=Balance FROM AccountsDerivedTemplate 
		WHERE PlSeq=8000000

		SET @Incomes=0
		SET @Expenses=0

		SET @CurSdt=DATEADD(DAY,1,@AcmEdt)

		FETCH NEXT FROM Cur_PL INTO @AcmId,@AcmSdt,@AcmEdt
	END
	CLOSE Cur_PL
	DEALLOCATE Cur_PL
	--Till Here

	CREATE TABLE #RptTrialBalance
	(
	       CoaId                 INT,
	       Level1                NVARCHAR(50),
	       Level2                NVARCHAR(50),
	       Level3                NVARCHAR(50),
	       LevelCode1            NVARCHAR(50),
	       LevelCode2            NVARCHAR(50),
	       LevelCode3            NVARCHAR(50),
	       AcCode                NVARCHAR(50),
	       AcName                NVARCHAR(50),
	       AcLevel               INT,
	       OpeningDebit          NUMERIC(38,2),
	       OpeningCredit         NUMERIC(38,2),
	       Credit                NUMERIC(38,2),
	       Debit                 NUMERIC(38,2),
	       ClosingDebit          NUMERIC(38,2),
	       ClosingCredit         NUMERIC(38,2),
	       CoaLevel              INT,
	       RptType		     INT
	)

	SET @TblName = 'RptTrialBalance'
	
	SET @TblStruct = '     CoaId                 INT,
			       Level1                NVARCHAR(50),
			       Level2                NVARCHAR(50),
			       Level3                NVARCHAR(50),
			       LevelCode1            NVARCHAR(50),
			       LevelCode2            NVARCHAR(50),
			       LevelCode3            NVARCHAR(50),
			       AcCode                NVARCHAR(50),
			       AcName                NVARCHAR(50),
			       AcLevel               INT,
			       OpeningDebit          NUMERIC(38,2),
			       OpeningCredit         NUMERIC(38,2),
			       Credit                NUMERIC(38,2),
			       Debit                 NUMERIC(38,2),
			       ClosingDebit          NUMERIC(38,2),
			       ClosingCredit         NUMERIC(38,2),
			       CoaLevel              INT,
			       RptType		     INT'
	
	SET @TblFields = 'CoaId,Level1,Level2,Level3,LevelCode1,LevelCode2,LevelCode3,AcCode,
	AcName,AcLevel,OpeningDebit,OpeningCredit,Credit,Debit,ClosingDebit,ClosingCredit,CoaLevel,RptType'
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

	EXEC Proc_ReturnStockMgmtAccounts @Pi_RptId,@Pi_UsrId,@FromDate,@ToDate
	EXEC Proc_OpeningBalance @Pi_RptId,@Pi_UsrId,@FromDate
	
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptTrialBalance (CoaId,Level1,Level2,Level3,LevelCode1,LevelCode2,
		LevelCode3,AcCode,AcName,AcLevel,OpeningDebit,OpeningCredit,Credit,Debit,
		ClosingDebit,ClosingCredit,CoaLevel,RptType)	
	        SELECT Amt.CoaId,Amt.Level1,Amt.Level2,Amt.Level3,
	        Amt.LevelCode1,Amt.LevelCode2,Amt.LevelCode3,
	        Amt.AcCode,Amt.AcName,Amt.AcLevel,
	        dbo.Fn_ConvertCurrency(ABS(Opn.OpeningDebit),@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(ABS(Opn.OpeningCredit),@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(ABS(Amt.Credit),@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(ABS(Amt.Debit),@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency((CASE WHEN (ABS(Amt.Debit)+ABS(Opn.OpeningDebit))>(ABS(Amt.Credit)+ABS(Opn.OpeningCredit)) THEN
		(ABS(Amt.Debit)+ABS(Opn.OpeningDebit))-(ABS(Amt.Credit)+ABS(Opn.OpeningCredit)) 
		ELSE 0 END),@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency((CASE WHEN (ABS(Amt.Debit)+ABS(Opn.OpeningDebit))<(ABS(Amt.Credit)+ABS(Opn.OpeningCredit)) THEN
		(ABS(Amt.Credit)+ABS(Opn.OpeningCredit)-(ABS(Amt.Debit)+ABS(Opn.OpeningDebit))) 
		ELSE 0 END),@Pi_CurrencyId),
		@CoaLvl,@RptType
	        FROM
	        (SELECT COA.CoaId,COA.AcCode,COA.AcName,COA.AcLevel,
	        SUM((CASE SVD.DebitCredit WHEN 2 THEN SVD.Amount ELSE 0 END)) AS Credit,
	        SUM((CASE SVD.DebitCredit WHEN 1 THEN SVD.Amount ELSE 0 END)) AS Debit,
	        COAL1.AcName AS Level1,COAL1.AcCode AS LevelCode1,COAL2.AcName AS Level2,COAL2.AcCode AS LevelCode2,
	        COAL3.AcName AS Level3,COAL3.AcCode AS LevelCode3
	        FROM
	        COAMaster COAL1,COAMaster COAL2,COAMaster COAL3,
	        StdVocMaster SVM (NOLOCK) LEFT OUTER JOIN StdVocDetails SVD (NOLOCK) ON SVM.VocRefNo=SVD.VocRefNo 
			AND SVM.VocDate BETWEEN @FromDate AND @ToDate AND SVM.YEEntry=0
	        RIGHT OUTER JOIN COAMaster COA (NOLOCK) ON COA.CoaId=SVD.CoaId
	        WHERE COAL1.AcCode LIKE CAST(LEFT(COA.AcCode,1) AS NVARCHAR(1))+'000000'
	        AND COAL2.AcCode LIKE CAST(LEFT(COA.AcCode,2) AS NVARCHAR(2))+'00000'
	        AND COAL3.AcCode LIKE CAST(LEFT(COA.AcCode,3) AS NVARCHAR(3))+'0000' 
	        GROUP BY COA.CoaId,COA.AcCode,COA.AcName,COA.AcLevel,COAL1.AcName,COAL2.AcName,COAL3.AcName,
	        COAL1.AcCode,COAL2.AcCode,COAL3.AcCode) Amt,
	        RptOpeningBalance Opn (NOLOCK)
	        WHERE Opn.CoaId=Amt.CoaId AND Opn.RptId=@Pi_RptId AND Opn.UserId=@Pi_UsrId AND Amt.AcLevel=4
	        ORDER BY Amt.AcCode,Amt.CoaId	
		

		--Added By Nanda on 11/12/2008
		EXEC Proc_ReturnStockMgmtAccounts @Pi_RptId,@Pi_UsrId,@FromDate,@ToDate
		
		CREATE TABLE #StkMgmtCoaIds
		(
			CoaID INT
		)
		
		INSERT INTO #StkMgmtCoaIds
		SELECT CoaId FROM StkMgmtCoaIds

		UPDATE #RptTrialBalance SET #RptTrialBalance.Debit=#RptTrialBalance.Debit-B.Debit,
		#RptTrialBalance.Credit=#RptTrialBalance.Credit-B.Credit		
		FROM StkMgmtCoaIds B
		WHERE #RptTrialBalance.CoaId=B.CoaId AND B.RptId=@Pi_RptId AND B.UserId=@Pi_UsrId

		SET @PrevDate=DATEADD(D,-1,@FromDate)
		EXEC Proc_ReturnStockMgmtAccounts @Pi_RptId,@Pi_UsrId,'2001-01-01',@PrevDate
		
		INSERT INTO #StkMgmtCoaIds
		SELECT CoaId FROM StkMgmtCoaIds


		UPDATE #RptTrialBalance SET #RptTrialBalance.OpeningDebit=#RptTrialBalance.OpeningDebit-B.Debit,
		#RptTrialBalance.OpeningCredit=#RptTrialBalance.OpeningCredit-B.Credit		
		FROM StkMgmtCoaIds B
		WHERE #RptTrialBalance.CoaId=B.CoaId AND B.RptId=@Pi_RptId AND B.UserId=@Pi_UsrId

		DELETE FROM #RptTrialBalance WHERE CoaId IN (SELECT CoaId FROM StkMgmtCoaIds)
		AND (AcCode LIKE '4%' OR AcCode LIKE '3%')
 
		UPDATE #RptTrialBalance SET ClosingDebit=OpeningDebit+Debit,ClosingCredit=OpeningCredit+Credit
		WHERE CoaId IN (SELECT CoaId FROM #StkMgmtCoaIds)

		UPDATE #RptTrialBalance SET ClosingDebit=ClosingDebit-ClosingCredit
		WHERE CoaId IN (SELECT CoaId FROM #StkMgmtCoaIds) AND ClosingDebit>ClosingCredit

		UPDATE #RptTrialBalance SET ClosingCredit=ClosingCredit-ClosingDebit
		WHERE CoaId IN (SELECT CoaId FROM #StkMgmtCoaIds) AND ClosingDebit<ClosingCredit

		UPDATE #RptTrialBalance SET ClosingCredit=0,ClosingDebit=0
		WHERE CoaId IN (SELECT CoaId FROM #StkMgmtCoaIds) AND ClosingDebit=ClosingCredit	

		--Added By Nanda on 19/03/2008		
		SELECT @CoaId=CoaId FROM CoaMaster WHERE AcCode='1210001'
		
		--SELECT @OpnPLAmount 

		IF @OpnPLAmount<0 
		BEGIN			
			UPDATE #RptTrialBalance SET OpeningDebit=ABS(@OpnPLAmount),OpeningCredit=0
			WHERE CoaId=@CoaId 	
		END
		ELSE IF @OpnPLAmount>0 
		BEGIN			
			UPDATE #RptTrialBalance SET OpeningCredit=ABS(@OpnPLAmount),OpeningDebit=0
			WHERE CoaId=@CoaId 	
		END
		
		IF @OpnPLAmount=0
		BEGIN
			UPDATE #RptTrialBalance SET Credit=0,Debit=0,OpeningCredit=0,OpeningDebit=0,
			ClosingCredit=0,ClosingDebit=0
			WHERE CoaId=@CoaId
		END

		UPDATE #RptTrialBalance SET ClosingDebit=Debit+OpeningDebit,
		ClosingCredit=OpeningCredit+Credit
		WHERE CoaId=@CoaId 			

		SELECT @CoaId=CoaId FROM CoaMaster WHERE AcCode='2150001'

		IF @OpnPLAmount<>0
		BEGIN
			UPDATE #RptTrialBalance SET Debit=0,Credit=0,ClosingDebit=@ClsStk,ClosingCredit=0,
			OpeningCredit=0,OpeningDebit=@ClsStk
			WHERE CoaId=@CoaId 	
		END
		--Till Here	

		--Added By Nanda on 19/03/2008
		UPDATE 	#RptTrialBalance SET OpeningDebit=OpeningDebit-OpeningCredit,OpeningCredit=0
		WHERE OpeningDebit>OpeningCredit

		UPDATE 	#RptTrialBalance SET OpeningCredit=OpeningCredit-OpeningDebit,OpeningDebit=0
		WHERE OpeningCredit>OpeningDebit

		UPDATE 	#RptTrialBalance SET OpeningDebit=0,OpeningCredit=0
		WHERE OpeningDebit=OpeningCredit

		UPDATE 	#RptTrialBalance SET Debit=Debit-Credit,Credit=0
		WHERE Debit>Credit

		UPDATE 	#RptTrialBalance SET Credit=Credit-Debit,Debit=0
		WHERE Credit>Debit

		UPDATE 	#RptTrialBalance SET Credit=0,Debit=0
		WHERE Credit=Debit

		UPDATE #RptTrialBalance SET ClosingDebit=-1*ClosingCredit,ClosingCredit=0
		WHERE ClosingCredit<0

		UPDATE #RptTrialBalance SET ClosingCredit=-1*ClosingDebit,ClosingDebit=0
		WHERE ClosingDebit<0 

		UPDATE #RptTrialBalance SET ClosingCredit=OpeningCredit+Credit,ClosingDebit=OpeningDebit+Debit

		UPDATE 	#RptTrialBalance SET ClosingDebit=ClosingDebit-ClosingCredit,ClosingCredit=0
		WHERE ClosingDebit>ClosingCredit

		UPDATE 	#RptTrialBalance SET ClosingCredit=ClosingCredit-ClosingDebit,ClosingDebit=0
		WHERE ClosingCredit>ClosingDebit

		UPDATE 	#RptTrialBalance SET ClosingCredit=0,ClosingDebit=0
		WHERE ClosingCredit=ClosingDebit		
----		Till Here	
	

		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL='INSERT INTO #RptTrialBalance (CoaId,Level1,Level2,Level3,LevelCode1,LevelCode2,LevelCode3,
			AcCode,AcName,AcLevel,OpeningDebit,OpeningCredit,Credit,Debit,
			ClosingDebit,ClosingCredit,CoaLevel,RptType)
			SELECT Amt.CoaId,Amt.Level1,Amt.Level2,Amt.Level3,
			Amt.LevelCode1,Amt.LevelCode2,Amt.LevelCode3,
			Amt.AcCode,Amt.AcName,Amt.AcLevel,
			Opn.OpeningDebit,Opn.OpeningCredit,Amt.Credit,Amt.Debit,
			(CASE WHEN (ABS(Amt.Debit)+ABS(Opn.OpeningDebit))>(ABS(Amt.Credit)+ABS(Opn.OpeningCredit)) THEN
			(ABS(Amt.Debit)+ABS(Opn.OpeningDebit))-(ABS(Amt.Credit)+ABS(Opn.OpeningCredit)) 
			ELSE 0 END) AS ClosingDebit,
			(CASE WHEN (ABS(Amt.Debit)+ABS(Opn.OpeningDebit))<(ABS(Amt.Credit)+ABS(Opn.OpeningCredit)) THEN
			(ABS(Amt.Credit)+ABS(Opn.OpeningCredit)-(ABS(Amt.Debit)+ABS(Opn.OpeningDebit))) 
			ELSE 0 END) AS ClosingCredit,@CoaLvl,@RptType
			FROM
			(SELECT COA.CoaId,COA.AcCode,COA.AcName,COA.AcLevel,
			SUM((CASE SVD.DebitCredit WHEN 2 THEN SVD.Amount ELSE 0 END)) AS Credit,
			SUM((CASE SVD.DebitCredit WHEN 1 THEN SVD.Amount ELSE 0 END)) AS Debit,
			COAL1.AcName AS Level1,COAL1.AcCode AS LevelCode1,COAL2.AcName AS Level2,COAL2.AcCode AS LevelCode2,
			COAL3.AcName AS Level3,COAL3.AcCode AS LevelCode3
			FROM ['
			+ @PurDBName + '].dbo.COAMaster COAL1,['+ @PurDBName + '].dbo.COAMaster COAL2,['+ @PurDBName + '].dbo.COAMaster COAL3,['
			+ @PurDBName + '].dbo.StdVocMaster SVM (NOLOCK) LEFT OUTER JOIN ['+ @PurDBName + '].dbo.StdVocDetails SVD (NOLOCK) ON SVM.VocRefNo=SVD.VocRefNo AND SVM.VocDate BETWEEN '+ @FromDate +' AND '+ @ToDate +
			'RIGHT OUTER JOIN ['+ @PurDBName + '].dbo.COAMaster COA (NOLOCK) ON COA.CoaId=SVD.CoaId
			WHERE COAL1.AcCode LIKE CAST(LEFT(COA.AcCode,1) AS NVARCHAR(1))'+CAST('000000' AS NVARCHAR(6))+'
			AND COAL2.AcCode LIKE CAST(LEFT(COA.AcCode,2) AS NVARCHAR(2))'+CAST('00000' AS NVARCHAR(5))+'
			AND COAL3.AcCode LIKE CAST(LEFT(COA.AcCode,3) AS NVARCHAR(3))'+CAST('0000' AS NVARCHAR(4))+'
			 AND SVM.YEEntry=0 GROUP BY COA.CoaId,COA.AcCode,COA.AcName,COA.AcLevel,COAL1.AcName,COAL2.AcName,COAL3.AcName,
			COAL1.AcCode,COAL2.AcCode,COAL3.AcCode) Amt,['
			+ @PurDBName + '].dbo.RptOpeningBalance Opn (NOLOCK)
			WHERE Opn.CoaId=Amt.CoaId AND Opn.RptId=@Pi_RptId AND Opn.UserId=@Pi_UsrId AND Amt.AcLevel=4
			ORDER BY Amt.AcCode,Amt.CoaId'
	
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
		' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptTrialBalance'
		
		EXEC (@SSQL)
		PRINT 'Saved Data Into SnapShot Table'
		END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		PRINT @Pi_DbName
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptTrialBalance ' +
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
			PRINT 'DataBase or Table not Found'
			RETURN
		END
	END

	IF @SupZV=1
	BEGIN
		DELETE FROM #RptTrialBalance WHERE Credit+Debit+OpeningDebit+OpeningCredit=0
	END

	IF @SupSD=1
	BEGIN
		INSERT INTO #RptTrialBalance(CoaId,Level1,Level2,Level3,LevelCode1,LevelCode2,
		LevelCode3,AcCode,AcName,AcLevel,OpeningDebit,OpeningCredit,Credit,Debit,
		ClosingDebit,ClosingCredit,CoaLevel,RptType)
		SELECT 0,'Assets','Current Assets','Customer A/C (Sundry Debtors)','2000000',
		'2100000','2160000','2160001','Sundry Debtors',4,
		SUM(OpeningDebit),SUM(OpeningCredit),SUM(Credit),SUM(Debit),
		SUM(ClosingDebit),SUM(ClosingCredit),@CoaLvl,@RptType FROM #RptTrialBalance
		WHERE CoaId IN (SELECT CoaId FROM COAMaster (NOLOCK) WHERE AcCode LIKE '216%' AND AcLevel=4)
		
		DELETE FROM #RptTrialBalance WHERE 
		CoaId IN (SELECT CoaId FROM COAMaster (NOLOCK) WHERE AcCode LIKE '216%' AND AcLevel=4)
		AND CoaId<>0
	END

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptTrialBalance
	PRINT 'Data Executed'

	if exists (select * from dbo.sysobjects where id = object_id(N'[RptTrialBalance_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [RptTrialBalance_Excel]

	IF @CoaLvl=5 
	BEGIN		
		SELECT * INTO RptTrialBalance_Excel FROM #RptTrialBalance ORDER BY ACName

		SELECT * FROM #RptTrialBalance ORDER BY ACName
	END
	ELSE
	BEGIN
		SELECT * INTO RptTrialBalance_Excel FROM #RptTrialBalance ORDER BY LevelCode1,LevelCode2,LevelCode3

		SELECT * FROM #RptTrialBalance ORDER BY LevelCode1,LevelCode2,LevelCode3
	END  

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-258-004

UPDATE HotSearchEditorHd 
SET RemainSltString='SELECT InvRcpNo,InvRcpDate,InvRcpAmt,CollectedById,CollectedMode,InvCollectedDate,RcpType FROM     
(SELECT  DISTINCT RC.InvRcpNo,RC.InvRcpDate,RC.InvRcpAmt,RC.CollectedById,  RC.CollectedMode ,RC.InvCollectedDate,RC.RcpType  
FROM Receipt RC WITH (NOLOCK) ,ReceiptInvoice RI WITH (NOLOCK)   WHERE RC.InvRcpNo = RI.InvRcpNo   AND RI.CancelStatus = 1  
UNION   
SELECT  DISTINCT RC.InvRcpNo,RC.InvRcpDate,RC.InvRcpAmt,RC.CollectedById,  RC.CollectedMode,RC.InvCollectedDate,RC.RcpType 
FROM Receipt RC WITH (NOLOCK) ,DebitInvoice RI WITH (NOLOCK)    WHERE RC.InvRcpNo = RI.InvRcpNo AND RI.CancelStatus = 1  )  MainQry'
WHERE FormId=646
GO
DELETE FROM SpreadDisplayColumns WHERE MasterId=210
INSERT INTO SpreadDisplayColumns
SELECT 210,1,'RtrCode',1,1,1,GETDATE(),1,GETDATE()
UNION
SELECT 210,2,'RtrName',1,1,1,GETDATE(),1,GETDATE()
UNION
SELECT 210,3,'RetailerCatName',1,1,1,GETDATE(),1,GETDATE()
UNION
SELECT 210,4,'RetailerCatLevelName',1,1,1,GETDATE(),1,GETDATE()
UNION
SELECT 210,5,'Short Name',1,1,1,GETDATE(),1,GETDATE()
UNION
SELECT 210,6,'PrdName',1,1,1,GETDATE(),1,GETDATE()
UNION
SELECT 210,7,'SalesQuantity',1,1,1,GETDATE(),1,GETDATE()
UNION
SELECT 210,8,'PrdGrossAmount',1,1,1,GETDATE(),1,GETDATE()
GO
DELETE FROM RptExcelHeaders WHERE RptId=210
INSERT INTO RptExcelHeaders
SELECT 210,1,'RtrCode','Retailer Code',1,1
UNION
SELECT 210,2,'RtrName','Retailer Name',1,1
UNION
SELECT 210,3,'RetailerCatName','Retailer Category',1,1
UNION
SELECT 210,4,'RetailerCatLevelName','Retailer Classification',1,1
UNION
SELECT 210,5,'PrdCcode','Short Name',1,1
UNION
SELECT 210,6,'PrdName','Product Name',1,1
UNION
SELECT 210,7,'SalesQuantity','Quantity',1,1
UNION
SELECT 210,8,'SalesValue','Value',1,1
UNION
SELECT 210,9,'SlNo','Value',0,1
GO
--SRF-Nanda-259-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeCombiPrd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeCombiPrd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeCombiPrd 0
SELECT * FROM ErrorLog
SELECT * FROM SchemeSlabCombiPrds
ROLLBACK TRANSACTION
*/
CREATE        PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeCombiPrd]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeCombiPrd
* PURPOSE: To Insert and Update Scheme Combi Products
* CREATED: Boopathy.P on 03/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode	AS VARCHAR(200)
	DECLARE @SlabId		AS Varchar(200)
	DECLARE @Value		AS VARCHAR(50)
	DECLARE @PrdCode	AS VARCHAR(200)
	DECLARE @PrdBatCode	AS VARCHAR(200)
	DECLARE @SlabCode	AS VARCHAR(200)
	DECLARE @GetKeyCode	AS VARCHAR(200)
	DECLARE @PrdBatOpt	AS INT
	DECLARE @CombiSchId	AS INT
	DECLARE @BatchLvl	AS INT
	DECLARE @CmpId		AS INT
	DECLARE @PrdId		AS VARCHAR(200)
	DECLARE @PrdBatId	AS VARCHAR(200)	
	DECLARE @SchLevelId	AS INT
	DECLARE @PrdCtgId	AS INT
	DECLARE @CombiSch	AS INT
	DECLARE @ChkCount	AS INT
	DECLARE @ErrDesc 	AS VARCHAR(1000)
	DECLARE @TabName 	AS VARCHAR(50)
	DECLARE @GetKey 	AS INT
	DECLARE @Taction 	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @sSQL 		AS VARCHAR(4000)
	DECLARE @MaxSchLevelId	AS	INT
	DECLARE @SLevel		AS	INT
	DECLARE @CmpPrdCtgId	AS	INT
	DECLARE @SchLevelMode	AS	NVARCHAR(200)
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	SET @TabName = 'Etl_Prk_SchemeProducts_Combi'
	SET @Po_ErrNo =0
	DECLARE Cur_SchemeCombiPrds CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL(SlabId,'') AS [SlabId],
	ISNULL([PrdCode],'') AS [Code],ISNULL([PrdBatCode],'') AS [Batch Code],
	ISNULL([SlabValue],'') AS [Value] FROM Etl_Prk_SchemeProducts_Combi
	WHERE SlabValue > 0
	AND CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code],[SlabId]
	OPEN Cur_SchemeCombiPrds
	FETCH NEXT FROM Cur_SchemeCombiPrds INTO @SchCode,@SlabId,@PrdCode,@PrdBatCode,@Value
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		SET @SlabCode=@SlabId

		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF EXISTS (SELECT * FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
		BEGIN
			SELECT @SchLevelId=SchLevelId,@CombiSchId=CombiSch, 
			@BatchLvl=BatchLevel FROM SchemeMaster
			WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		END
		ELSE IF EXISTS (SELECT * FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
		BEGIN
			SELECT @SchLevelId=SchLevelId,@CombiSchId=CombiSch,@BatchLvl=BatchLevel
			FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		END
		IF @CombiSchId=1
		BEGIN
			IF LTRIM(RTRIM(@SlabId))= ''
			BEGIN
				SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@PrdCode))= ''
			BEGIN
				SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@Value))= ''
			BEGIN
				SET @ErrDesc = 'Slab Value should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab Value',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@SchLevelMode))=''
			BEGIN
				SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
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
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
		
					SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
					IF @MaxSchLevelId=@SchLevelId
					BEGIN

						IF NOT EXISTS(SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
						BEGIN
							SET @ErrDesc = 'Product Code:'+@PrdCode+ ' not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
						END
					END

					IF NOT EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SET @ErrDesc = 'Slab Details not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND
						SlabId=LTRIM(RTRIM(@SlabCode))
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
					ELSE IF EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
							CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN
						SELECT @GetKeyCode=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@CombiSch=CombiSch,@CmpPrdCtgId=SchLevelId 
						FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END	
					ELSE
					BEGIN
						SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
						B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=C.CmpPrdCtgId,@CombiSch=A.CombiSch
						FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
						INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
						AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
					END
					IF EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND
						SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N' AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND
						UpLoadFlag='N' AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
				END

				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @MaxSchLevelId=@SchLevelId
				BEGIN
					IF @BatchLvl=1
					BEGIN
						IF LTRIM(RTRIM(@PrdBatCode))= ''
						BEGIN
							SET @ErrDesc = 'Batch Code should not be blank for Product Code:'+@PrdCode+ 'of Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Batch Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
						
						IF NOT EXISTS(SELECT PrdId FROM Product WHERE CmpId=@CmpId
							AND PrdCCode=LTRIM(RTRIM(@PrdCode)))
						BEGIN
							SET @ErrDesc = 'Product Code:'+@PrdCode +' Not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @PrdId=PrdId FROM Product WHERE CmpId=@CmpId
							AND PrdCCode=LTRIM(RTRIM(@PrdCode))
							SET @PrdCtgId=0
							IF @BatchLvl=1
							BEGIN
								IF NOT EXISTS(SELECT PrdBatId FROM ProductBatch WHERE PrdId=@PrdId)
								BEGIN
		
									SET @ErrDesc = 'No Batch Code Found for Product Code:'+@PrdCode+ ' in Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (11,@TabName,'Batch Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId
								END
							END
							ELSE
							BEGIN
-- 								SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId
								SET @PrdBatId=0
							END
						END
-- 					END
				END
				ELSE
				BEGIN
					--->Modified By Nanda on 24/08/2009
					IF NOT EXISTS(SELECT A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId)
					BEGIN
						SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @PrdCtgId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
						SET @PrdId=0
						SET @PrdBatId=0
					END
					--Till Here
				END
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
			SELECT @ChkCount=COUNT(*) FROM TempDepCheck
			IF @ChkCount > 0
			BEGIN				
				SET @Taction = 0
			END
			ELSE
			BEGIN
				IF @ConFig=1
				BEGIN
					SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
					IF @CmpPrdCtgId<@SLevel
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
							DELETE FROM SchemeSlabCombiPrds WHERE SlabId=@SlabId AND SchId=@GetKey 
							AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND PrdCtgValMainId=@PrdCtgId
							
							SET @sSQL ='DELETE FROM SchemeSlabCombiPrds WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
								   ' AND SchId=' + CAST(@GetKey AS VARCHAR(200))
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
			
							INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
								    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,
								    @PrdCtgId,@PrdId,@PrdBatId,@Value,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
				
							SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
								    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
								   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
								   ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=@SlabId AND CmpSchCode=@GetKey
							AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UpLoadFlag='N'
							
							SET @sSQL ='DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
								   ' AND CmpSchCode=' + CAST(@GetKey AS VARCHAR(200)) + ' AND PrdId='+ CAST(@PrdId AS VARCHAR(200)) +
								   ' AND PrdBatId=' +  CAST(@PrdBatId AS VARCHAR(200)) + ' AND UpLoadFlag=''N'''
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
			
							INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
							VALUES(@GetKey,@SlabId,@PrdCtgId,@PrdId,@PrdBatId,@Value,'N')
				
							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
								    VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
								   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
								   ',''N'')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE
					BEGIN
						DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=@SlabId AND CmpSchCode=@GetKey
						AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UpLoadFlag='N'
						
						SET @sSQL ='DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
							   ' AND CmpSchCode=' + CAST(@GetKey AS VARCHAR(200)) + ' AND PrdId='+ CAST(@PrdId AS VARCHAR(200)) +
							   ' AND PrdBatId=' +  CAST(@PrdBatId AS VARCHAR(200)) + ' AND UpLoadFlag=''N'''
		
						INSERT INTO Translog(strSql1) Values (@sSQL)
		
						INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
						VALUES(@GetKey,@SlabId,@PrdCtgId,@PrdId,@PrdBatId,@Value,'N')
			
						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
							    VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
							   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
							   ',''N'')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END
				ELSE
				BEGIN
					DELETE FROM SchemeSlabCombiPrds WHERE SlabId=@SlabId AND SchId=@GetKey 
					AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND PrdCtgValMainId=@PrdCtgId
					
					SET @sSQL ='DELETE FROM SchemeSlabCombiPrds WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
						   ' AND SchId=' + CAST(@GetKey AS VARCHAR(200))
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
	
					INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
						    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,
						    @PrdCtgId,@PrdId,@PrdBatId,@Value,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
		
					SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
						    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
						   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
						   ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
			END
		END
		FETCH NEXT FROM Cur_SchemeCombiPrds INTO @SchCode,@SlabId,@PrdCode,@PrdBatCode,@Value
	END
	CLOSE Cur_SchemeCombiPrds
	DEALLOCATE Cur_SchemeCombiPrds
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-259-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidatePurchaseOrder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidatePurchaseOrder]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_ValidatePurchaseOrder 0
SELECT * FROM PurchaseOrderMaster WHERE PurOrderRefNo='POR0800024'
SELECT * FROM PurchaseOrderDetails WHERE PurOrderRefNo='POR0800024'
ROLLBACK TRANSACTION
*/

CREATE          Procedure [dbo].[Proc_ValidatePurchaseOrder]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValiadatePurchaseOrder
* PURPOSE	: To Validate the Purchase Order
* CREATED	: Boopathy.P
* CREATED DATE	: 17/11/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	DECLARE @Taction  Int
	DECLARE @ErrDesc  Varchar(1000)
	DECLARE @Tabname  Varchar(50)
	DECLARE @CmpId int
	DECLARE @CmpCode Varchar(50)
	DECLARE @PONo Varchar(50)
	DECLARE @PORefNo Varchar(50)
	DECLARE @PODate Varchar(50)
	DECLARE @POExpDate Varchar(50)
	DECLARE @PrdId int
	DECLARE @PrdCode Varchar(50)
	DECLARE @UomId1 int
	DECLARE @UomCode1 Varchar(50)
	DECLARE @UomId2 int
	DECLARE @UomCode2 Varchar(50)
	DECLARE @Qty1 Varchar(50)
	DECLARE @Qty2 Varchar(50)
	DECLARE @sStr	nVarchar(4000)
	DECLARE @SpmId INT
	DECLARE @CmpPrdCtgCode Varchar(50)
	DECLARE @PrdCtgValCode Varchar(50)
	DECLARE @PrdCtgValLinkCode Varchar(50)
	DECLARE @CmpPrdCtgId INT
	DECLARE @PrdCtgValMainId INT
	Set @Tabname = 'ETL_Prk_POMaster'
	DECLARE Cur_POMaster CURSOR
	FOR
		SELECT Distinct ISNULL([PORefNo],''),ISNULL([Company Code],''),ISNULL([Hierarchy Level Code],''),
		ISNULL([Hierarchy Value Code],''),ISNULL([PODate],''),
		ISNULL([POExpiryDate],'') FROM ETL_Prk_POMaster
	OPEN Cur_POMaster
	FETCH NEXT FROM Cur_POMaster INTO @PONo,@CmpCode,@CmpPrdCtgCode,@PrdCtgValCode,@PODate,@POExpDate
	SET @Po_ErrNo = 0
	WHILE @@FETCH_STATUS=0
	BEGIN
		Set @Tabname = 'ETL_Prk_POMaster'
		IF IsNull(@CmpCode,'') =''
		BEGIN
			SET @ErrDesc = 'Company Code Should Not Be Null'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Code',@ErrDesc)
			SET @Po_ErrNo = 1
		END
		IF ISNULL(@CmpPrdCtgCode,'') =''
		BEGIN
			SET @ErrDesc = 'Product Hierarchy Level Should Not Be Empty'
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarchy Level Code',@ErrDesc)
			SET @Po_ErrNo = 1
		END
		IF ISNULL(@PrdCtgValCode,'') =''
		BEGIN
			SET @ErrDesc = 'Product Hierarchy Level Value Should Not Be Empty'
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarchy Level VAlue Code',@ErrDesc)
			SET @Po_ErrNo = 1
		END
		IF IsNull(@PODate,'') =''
		BEGIN
			SET @ErrDesc = 'Purchase Date Should Not Be Null'
			INSERT INTO Errorlog VALUES (2,@TabName,'Purchase Date',@ErrDesc)
			SET @Po_ErrNo = 1
		END
		IF IsNull(@POExpDate,'') =''
		BEGIN
			SET @ErrDesc = 'Purchase Expiry Date Should Not Be Null'
			INSERT INTO Errorlog VALUES (3,@TabName,'Purchase Expiry Date',@ErrDesc)
			SET @Po_ErrNo = 1
		END
		IF ISDATE(LTRIM(RTRIM(@PODate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Purchase Date'
			INSERT INTO Errorlog VALUES (4,@TabName,'Purchase Date',@ErrDesc)
			SET @Po_ErrNo =1
		END
		IF ISDATE(LTRIM(RTRIM(@POExpDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Purchase Expiry Date'
			INSERT INTO Errorlog VALUES (5,@TabName,'Purchase Expiry Date',@ErrDesc)
			SET @Po_ErrNo =1
		END
		IF DATEDIFF(d,@PODate,@POExpDate)<=0
		BEGIN
			SET @ErrDesc = 'Purchase Expiry Date Should be greater than Purchase Date'
			INSERT INTO Errorlog VALUES (5,@TabName,'Purchase Expiry Date',@ErrDesc)
			SET @Po_ErrNo =1
		END
		-- Company Code
		IF Not exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
		BEGIN
			  SET @ErrDesc = ' Company Code ' + @CmpCode + ' not found in Master table'
			  INSERT INTO Errorlog VALUES (6,@TabName,'Company Code',@ErrDesc)           	
			  SET @Po_ErrNo = 1
		END
		ELSE IF exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
		BEGIN
			SELECT @CmpId = CmpId FROM Company WHERE CmpCode = @CmpCode
		END
		IF Not exists (SELECT * FROM ProductCategoryLevel WHERE CmpPrdCtgName = @CmpPrdCtgCode AND CmpId=@CmpId) and IsNull(@CmpPrdCtgCode,'') <> ''
		BEGIN
			  SET @ErrDesc = ' Product Hierarchy Level Code ' + @CmpCode + ' not found in Master table'
			  INSERT INTO Errorlog VALUES (6,@TabName,'Product Hierarchy Level Code',@ErrDesc)           	
			  SET @Po_ErrNo = 1
		END
		ELSE
		BEGIN
			SELECT @CmpPrdCtgId = CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName = @CmpPrdCtgCode AND CmpId=@CmpId
		END
		IF Not exists (SELECT * FROM ProductCategoryValue WHERE PrdCtgValCode = @PrdCtgValCode ) and IsNull(@CmpPrdCtgCode,'') <> ''
		BEGIN
			  SET @ErrDesc = ' Product Hierarchy Level Value Code ' + @CmpCode + ' not found in Master table'
			  INSERT INTO Errorlog VALUES (6,@TabName,'Product Hierarchy Level Value Code',@ErrDesc)           	
			  SET @Po_ErrNo = 1
		END
		ELSE
		BEGIN
			SELECT @PrdCtgValMainId = PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode = @PrdCtgValCode
			SELECT @PrdCtgValLinkCode = PrdCtgValLinkCode FROM ProductCategoryValue WHERE PrdCtgValCode = @PrdCtgValCode
			
		END
		IF @Po_ErrNo = 0
		BEGIN
			
			SET @PORefNo = dbo.Fn_GetPrimaryKeyString('PurchaseOrderMaster','PurOrderRefNo',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
			
		
			INSERT INTO PurchaseOrderMaster (PurorderRefNo,Cmpid,purOrderDate,PurOrderExpiryDate,
				FillAllPrds,GenQtyAuto,Availability,LastModBy,LastModDate,AuthId,AuthDate,PurOrderStatus,
				ConfirmSts,DownLoad,CmpPoNo,CmpPoDate,Upload,SpmId,CmpPrdCtgId,PrdCtgValMainId,SiteId)
			VALUES (@PORefNo,@CmpId,convert(varchar(10),@PODate,121),convert(varchar(10),@POExpDate,121),0,0,1,1,
				convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),0,0,1,@PONo,@PODate,0,0,@CmpPrdCtgId,@PrdCtgValMainId,0)
			
			SET @sStr = 'INSERT INTO PurchaseOrderMaster (PurorderRefNo,Cmpid,purOrderDate,PurOrderExpiryDate
				    ,FillAllPrds,GenQtyAuto,Availability,LastModBy,LastModDate,AuthId,AuthDate,PurOrderStatus,
				    ConfirmSts,DownLoad,CmpPoNo,CmpPoDate,Upload,SpmId,SiteId)
				    VALUES(''' + @PORefNo + ''',''' + CAST(@CmpId AS NVARCHAR(10))+ ''',''' +
				    convert(varchar(10),@PODate,121) + ''',''' + convert(varchar(10),getdate(),121) + ''',0,0,1,1,
				    ,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,1''' +
				   @PONo + ''',''' + convert(varchar(10),@PODate,121) + ''',0,0,'+
				   + CAST(@CmpPrdCtgId AS NVARCHAR(10))+ ','+CAST(@PrdCtgValMainId AS NVARCHAR(10))+',0)'
			INSERT INTO Translog(strSql1) Values (@sstr)
			Set @Tabname = 'ETL_Prk_PODetails'
		
			DECLARE Cur_PODetails CURSOR
			FOR
				SELECT Distinct ISNULL([PrdCCode],''),ISNULL([SysUomCode],''),
				ISNULL([SysQty],''),ISNULL([OrdUomCode],''),ISNULL([OrdQty],'') FROM ETL_Prk_PODetails
				WHERE [PORefNo] = @PONo
			OPEN Cur_PODetails
			FETCH NEXT FROM Cur_PODetails INTO @PrdCode,@UomCode1,@Qty1,@UomCode2,@Qty2
			SET @Po_ErrNo = 0
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF IsNull(@PrdCode,'') =''
				BEGIN
					SET @ErrDesc = 'Product Code Should Not Be Null'
					INSERT INTO Errorlog VALUES (7,@TabName,'Product Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo = 1
				END		
				ELSE IF IsNull(@UomCode1,'') =''
				BEGIN
					SET @ErrDesc = 'System Uom Code Should Not Be Null'
					INSERT INTO Errorlog VALUES (8,@TabName,'UOM Code 1',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo = 1
				END
				ELSE IF IsNull(@Qty1,'') =''
				BEGIN
					SET @ErrDesc = 'System Quantity Should Not Be Null'
					INSERT INTO Errorlog VALUES (9,@TabName,'System Quantity',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo = 1
				END
				ELSE IF IsNull(@UomCode2,'') =''
				BEGIN
					SET @ErrDesc = 'Ordered Uom Code Should Not Be Null'
					INSERT INTO Errorlog VALUES (10,@TabName,'UOM Code 2',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo = 1
				END
				ELSE IF IsNull(@Qty2,'') =''
				BEGIN
					SET @ErrDesc = 'Order Quantity Should Not Be Null'
					INSERT INTO Errorlog VALUES (11,@TabName,'Ordered Quantity',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo = 1
				END
				-- Product Code
				IF Not exists (SELECT * FROM Product WHERE PrdCCode = @PrdCode ) and IsNull(@PrdCode,'') <> ''
				BEGIN
					  SET @ErrDesc = ' Product Code ' + @PrdCode + ' not found in Master table'
					  INSERT INTO Errorlog VALUES (12,@TabName,'Product Code',@ErrDesc)           	
					  SET @Taction = 0
					  SET @Po_ErrNo = 1
				END
				ELSE IF exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
				BEGIN
					SELECT @PrdId = PrdId FROM Product WHERE PrdCCode = @PrdCode
				END
				
				IF NOT EXISTS(SELECT P.* FROM Product P,ProductCategoryValue PCV
				WHERE P.PrdCtgValMainId=PCV.PrdCtgValMainId AND P.PrdId=@PrdId AND PCV.PrdCtgValLinkCode LIKE @PrdCtgValLinkCode+'%')
				BEGIN
					  SET @ErrDesc = ' Product Code ' + @PrdCode + ' not under '+ @PrdCtgValCode +''
					  INSERT INTO Errorlog VALUES (12,@TabName,'Product Code',@ErrDesc)           	
					  SET @Taction = 0
					  SET @Po_ErrNo = 1
				END
				-- System Uom Code
				IF Not exists (SELECT * FROM UOMMaster WHERE UomCode = @UomCode1 ) and IsNull(@UomCode1,'') <> ''
				BEGIN
					  SET @ErrDesc = 'System UOM Code ' + @PrdCode + ' not found in Master table'
					  INSERT INTO Errorlog VALUES (12,@TabName,'System UOM Code',@ErrDesc)           	
					  SET @Taction = 0
					  SET @Po_ErrNo = 1
				END
				ELSE IF exists (SELECT * FROM UOMMaster WHERE UomCode = @UomCode1 ) and IsNull(@UomCode1,'') <> ''
				BEGIN
					SELECT @UOMId1 = UOMId FROM UOMMaster WHERE UomCode = @UomCode1
				END
				-- Ordered Uom Code
				IF Not exists (SELECT * FROM UOMMaster WHERE UomCode = @UomCode2 ) and IsNull(@UomCode2,'') <> ''
				BEGIN
					  SET @ErrDesc = 'Ordered UOM Code ' + @PrdCode + ' not found in Master table'
					  INSERT INTO Errorlog VALUES (12,@TabName,'Ordered UOM Code',@ErrDesc)           	
					  SET @Taction = 0
					  SET @Po_ErrNo = 1
				END
				ELSE IF exists (SELECT * FROM UOMMaster WHERE UomCode = @UomCode2 ) and IsNull(@UomCode2,'') <> ''
				BEGIN
					SELECT @UOMId2 = UOMId FROM UOMMaster WHERE UomCode = @UomCode2
				END
				IF @Po_ErrNo = 0
				BEGIN
					-- Check the Purchase Order
					IF Not exists (SELECT * FROM PurchaseOrderDetails WHERE PurorderRefNo = @PORefNo AND PrdId=@PrdId)
					BEGIN
						INSERT INTO PurchaseOrderDetails (PurorderRefNo,PrdId,SysGenUomid,SysGenQty,
							    OrdUomId,OrdQty,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES (@PORefNo,@PrdId,@UOMId1,@Qty1,@UOMId2,@Qty2,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121))
						
						SET @sStr = 'INSERT INTO PurchaseOrderDetails (PurorderRefNo,PrdId,SysGenUomid,SysGenQty,
							     OrdUomId,OrdQty,Availability,LastModBy,LastModDate,AuthId,AuthDate)
							     VALUES (''' + @PORefNo + ''',''' +CAST(@PrdId AS NVARCHAR(10)) + ''',''' + CAST(@UOMId1 AS NVARCHAR(10)) + ''','''
							     + CAST(@Qty1 AS NVARCHAR(10)) + ''',''' + CAST(@UOMId2 AS NVARCHAR(10)) + ''',''' + CAST(@Qty2 AS NVARCHAR(10)) + ''',1,1,''' + convert(varchar(10),getdate(),121) +
							      ''',1,''' + convert(varchar(10),getdate(),121) + ''',1)'
	
						INSERT INTO Translog(strSql1) Values (@sstr)
					END
					ELSE IF exists (SELECT * FROM PurchaseOrderDetails WHERE PurorderRefNo = @PORefNo AND PrdId=@PrdId)
					BEGIN
						UPDATE PurchaseOrderDetails SET PrdId=@PrdId,SysGenUomid=@UOMId1,SysGenQty=@Qty1,
							OrdUomId=@UOMId2,OrdQty=@Qty2 WHERE PurorderRefNo=@PORefNo
	
						SET @sStr = 'UPDATE PurchaseOrderDetails SET PrdId='''+ CAST(@PrdId AS NVARCHAR(10)) + ''',SysGenUomid=''' + CAST(@UOMId1 AS NVARCHAR(10)) + '''
							    ,SysGenQty='''+ CAST(@Qty1 AS NVARCHAR(10)) + ''',OrdUomId=''' + CAST(@UOMId2 AS NVARCHAR(10)) + ''',OrdQty=''' + CAST(@Qty2 AS NVARCHAR(10)) + '''
							    WHERE PurorderRefNo=''' + @PORefNo +''''
	
						INSERT INTO Translog(strSql1) Values (@sstr)
					END
				END
				
				FETCH NEXT FROM Cur_PODetails INTO @PrdCode,@UomCode1,@Qty1,@UomCode2,@Qty2
			END
			CLOSE Cur_PODetails
			DEALLOCATE Cur_PODetails
			IF @Po_ErrNo = 0
			BEGIN
				UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'PurchaseOrderMaster' and fldname = 'PurOrderRefNo'
				SET @sStr = 'UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = ' + '''PurchaseOrderMaster''' + ' and fldname = ' + '''PurOrderRefNo'''
				INSERT INTO Translog(strSql1) Values (@sstr)	
			END
		END
	FETCH NEXT FROM Cur_POMaster INTO @PONo,@CmpCode,@CmpPrdCtgCode,@PrdCtgValCode,@PODate,@POExpDate
	END
	CLOSE Cur_POMaster
	DEALLOCATE Cur_POMaster
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-259-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLPurchaseOrder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLPurchaseOrder]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
UPDATE Cn2Cs_Prk_BLPurchaseOrder SET SiteCode=''
DELETE FROM ErrorLog
SELECT * FROM Cn2Cs_Prk_BLPurchaseOrder
EXEC Proc_Cn2Cs_BLPurchaseOrder 0
SELECT * FROM ETL_Prk_POMaster
SELECT * FROM ETL_Prk_PODetails
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE        PROC [dbo].[Proc_Cn2Cs_BLPurchaseOrder]
(
@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE: Proc_Cn2Cs_BLPurchaseOrder
* PURPOSE: To Insert the records From Console into ETL_Prk_Product,
			ETL_Prk_ProductHierarchyLevelvalue
* SCREEN : Console Integration-Product Download
* CREATED: Nandakumar R.G 31-12-2008
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpCode nVarChar(50)	
	DECLARE @ErrStatus INT
	
	TRUNCATE TABLE ETL_Prk_POMaster
	TRUNCATE TABLE ETL_Prk_PODetails

	--->Added By Nanda on 29/08/2011
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'POToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE POToAvoid	
	END

	CREATE TABLE POToAvoid
	(
		PORefNo NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO POToAvoid(PORefNo)
		SELECT DISTINCT PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Order','Product','Product:'+PrdCCode+' Not Available for PO:'+PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
	END	

	IF EXISTS(SELECT DISTINCT PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
	WHERE LevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel))
	BEGIN
		INSERT INTO POToAvoid(PORefNo)
		SELECT DISTINCT PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
		WHERE LevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Order','Product Category level','Product Cate3gory level:'+LevelCode+' Not Available for PO:'+PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
		WHERE LevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel)
	END	

	IF EXISTS(SELECT DISTINCT PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
	WHERE LevelValueCode NOT IN (SELECT PrdCtgValCode FROM ProductCategoryValue))
	BEGIN
		INSERT INTO POToAvoid(PORefNo)
		SELECT DISTINCT PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
		WHERE LevelValueCode NOT IN (SELECT PrdCtgValCode FROM ProductCategoryValue)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Order','Product Category level Value','Product Category level Value:'+LevelCode+' Not Available for PO:'+PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
		WHERE LevelValueCode NOT IN (SELECT PrdCtgValCode FROM ProductCategoryValue)
	END	

	IF EXISTS(SELECT DISTINCT PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster))
	BEGIN
		INSERT INTO POToAvoid(PORefNo)
		SELECT DISTINCT PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
		WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Order','UOM','UOM:'+UOMCode+' Not Available for PO:'+PORefNo FROM Cn2Cs_Prk_BLPurchaseOrder
		WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster)
	END	
	--->Till Here

	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany=1
	
	INSERT INTO ETL_Prk_POMaster(PORefNo,[Company Code],[Hierarchy Level Code],
	[Hierarchy Value Code],PODate,POExpiryDate,SiteCode)
	SELECT DISTINCT PORefNo,@CmpCode,LevelCode,LevelValueCode,
	CONVERT(NVARCHAR(11),DATEADD(DD,0,PODate),121),
	CONVERT(NVARCHAR(11),DATEADD(DD,1,PODate),121),SiteCode FROM Cn2Cs_Prk_BLPurchaseOrder
	WHERE DownLOadFlag='D' AND PORefNo NOT IN (SELECT PORefNo FROM POToAvoid)

	INSERT INTO ETL_Prk_PODetails(PORefNo,PrdCCode,SysUomCode,SysQty,OrdUomCode,OrdQty,SiteCode)
	SELECT DISTINCT PORefNo,PrdCCode,UOMCode,Qty,UOMCode,Qty,SiteCode FROM Cn2Cs_Prk_BLPurchaseOrder 
	WHERE DownLOadFlag='D' AND PORefNo NOT IN (SELECT PORefNo FROM POToAvoid)

	EXEC Proc_ValidatePurchaseOrder @Po_ErrNo= @ErrStatus OUTPUT

	IF(@ErrStatus=0)
	BEGIN		
		UPDATE Cn2Cs_Prk_BLPurchaseOrder SET DownLoadFlag='Y' 
		WHERE PORefNo IN (SELECT CmpPoNo FROM PurchaseOrderMaster) 
	END
	
	SET @Po_ErrNo= @ErrStatus
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportBLPurchaseOrder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportBLPurchaseOrder]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec Proc_ImportBLPurchaseOrder '<Root></Root>'

CREATE          Procedure [dbo].[Proc_ImportBLPurchaseOrder]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportBLPurchaseOrder
* PURPOSE	: To Insert records from xml file in the Table Cn2Cs_Prk_BLPurchaseOrder
* CREATED	: Mahalakshmi.A
* CREATED DATE	: 09/01/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Cn2Cs_Prk_BLPurchaseOrder(DistCode,PORefNo,PODate,LevelCode,
	LevelValueCode,PrdCCode,UOMCode,Qty,SiteCode,DownLoadFlag)
	SELECT [DistCode],[PORefNo] ,[PODate],[LevelCode],[LevelValueCode],[PrdCCode],[UOMCode],[Qty],ISNULL([SiteCode],''),[DownloadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_PurchaseOrder ',1)
	WITH (
		[DistCode]	VARCHAR(50),
		[PORefNo]	VARCHAR(50),
		[PODate]	DATETIME,
		[LevelCode]  	NVARCHAR(100),
		[LevelValueCode]NVARCHAR(100),
		[PrdCCode]	VARCHAR(100),
		[UOMCode]	VARCHAR(100),
		[Qty]		INT,
		[SiteCode]	NVARCHAR(100),
		[DownloadFlag] 	 NVARCHAR(1)
	) XMLObj
	
	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Proc_RptSupplierCreditNote') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Proc_RptSupplierCreditNote
GO
--EXEC Proc_RptSupplierCreditNote 84,2,0,'Cavin',0,0,1,0
CREATE   PROCEDURE [dbo].[Proc_RptSupplierCreditNote]
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
/************************************************
* PROCEDURE  : Proc_RptCreditNoteSupplier
* PURPOSE    : To Generate  Credit Note Supplier Report
* CREATED BY : Mahalakshmi.A
* CREATED ON : 20/02/2008  
* MODIFICATION 
*************************************************   
* DATE       AUTHOR      DESCRIPTION    

*************************************************/       
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	NVARCHAR(50)
	DECLARE @TblName 			AS	NVARCHAR(500)
	DECLARE @TblStruct 			AS	NVARCHAR(4000)
	DECLARE @TblFields 			AS	NVARCHAR(4000)
	DECLARE @sSql				AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	NVARCHAR(50)

	--Filter Variable
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @SpmId				AS INT
	DECLARE @CrNoteNumber		AS NVARCHAR(50)
	DECLARE @Status				AS INT
	DECLARE @EXLFlag AS INT 
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SpmId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId))
	SET @CrNoteNumber = (SElect  TOP 1 sCountid FRom Fn_ReturnRptFilterString(@Pi_RptId,102,@Pi_UsrId))
	SET @Status = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId))
	--Till Here


	Create TABLE #RptSupplierCreditNote
	(
			SpmId 				 INT,
			SpmCode				 NVARCHAR(50),
			SpmName 			 NVARCHAR(50),
			CrNoteNo			 NVARCHAR(50),
			CrNoteDate			 DATETIME,
			Reason				 NVARCHAR(50),
			CrAmount			 Numeric(38,2),
			CrAdjAmount			 Numeric(38,2),
			BalanceAmount		 Numeric(38,2),
			Status				 NVARCHAR(50),
			TaxName NVARCHAR(100),
			TaxPerc NUMERIC (38,2) ,
			TaxAmt NUMERIC (38,2)
			
	)
	SET @TblName = 'RptSupplierCreditNote'
	SET @TblStruct ='SpmId 				 INT,
					 SpmCode			 NVARCHAR(50),
					 SpmName 			 NVARCHAR(50),
					 CrNoteNo			 NVARCHAR(50),
					 CrNoteDate			 DATETIME,
					 Reason				 NVARCHAR(50),
					 CrAmount			 Numeric(38,2),
					 CrAdjAmount			 Numeric(38,2),
					 BalanceAmount		 Numeric(38,2),
					 Status				 NVARCHAR(50),
					TaxName NVARCHAR(100),
					TaxPerc NUMERIC (38,2) ,
					TaxAmt NUMERIC (38,2)'
	SET @TblFields = 'SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,CrAdjAmount,
					BalanceAmount,Status,TaxName,TaxPerc,TaxAmt'
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
 		INSERT INTO #RptSupplierCreditNote (SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status,TaxName,TaxPerc,TaxAmt)
 			SELECT DISTINCT B.SpmId,B.SpmCode,B.SpmName,A.CrNoteNumber,A.CrNoteDate,C.Description,
				A.Amount,A.CrAdjAmount,(ISNULL(A.Amount,0)-ISNULL(A.CrAdjAmount,0)) as BalanceAmount,
					(CASE A.Status WHEN 1 THEN 'Active' ELSE 'InActive' END),
					ISNULL(TC.TaxName,'')+' Tax Amt',ISNULL(CTB.TaxPerc,0),ISNULL(CTB.TaxAmt,0)
				FROM CreditNoteSupplier A
			INNER JOIN Supplier B ON A.SpmId=B.SpmId
			INNER JOIN reasonMaster C ON A.ReasonId=C.ReasonId
			LEFT OUTER JOIN CrDbNoteTaxBreakUp CTB ON CTB.RefNo=A.CrNoteNumber AND CTB.TransId=32
			LEFT OUTER JOIN TaxConfiguration TC ON TC.TaxId=CTB.TaxId
 			WHERE 	(B.SpmId = (CASE @SpmID WHEN 0 THEN B.SpmID ELSE 0 END) OR
							B.SpmId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
					AND
						(A.CrNoteNumber=(CASE @CrNoteNumber WHEN '0' THEN A.CrNoteNumber ELSE '' END)OR
 							A.CrNoteNumber IN (SELECT sCountid FROM Fn_ReturnRptFilterString(84,102,1)))
					AND
 						(A.Status = (CASE @Status WHEN 0 THEN A.Status ELSE 3 END) OR
 							A.Status IN (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))
					AND
						 A.CrNoteDate BETWEEN @FromDate AND @ToDate 

			INSERT INTO #RptSupplierCreditNote (SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status,TaxName,TaxPerc,TaxAmt)
 			SELECT DISTINCT B.SpmId,B.SpmCode,B.SpmName,A.CrNoteNumber,A.CrNoteDate,C.Description,
				A.Amount,A.CrAdjAmount,(ISNULL(A.Amount,0)-ISNULL(A.CrAdjAmount,0)) as BalanceAmount,
			(CASE A.Status WHEN 1 THEN 'Active' ELSE 'InActive' END),
				ISNULL(TC.TaxName,'')+' Gross Amt' AS TaxName,ISNULL(CTB.TaxPerc,0),ISNULL(CTB.GrossAmt,0)
				FROM CreditNoteSupplier A
			INNER JOIN Supplier B ON A.SpmId=B.SpmId
			INNER JOIN reasonMaster C ON A.ReasonId=C.ReasonId
			LEFT OUTER JOIN CrDbNoteTaxBreakUp CTB ON CTB.RefNo=A.CrNoteNumber AND CTB.TransId=32
			LEFT OUTER JOIN TaxConfiguration TC ON TC.TaxId=CTB.TaxId
 			WHERE 	(B.SpmId = (CASE @SpmID WHEN 0 THEN B.SpmID ELSE 0 END) OR
							B.SpmId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
					AND
						(A.CrNoteNumber=(CASE @CrNoteNumber WHEN '0' THEN A.CrNoteNumber ELSE '' END)OR
 							A.CrNoteNumber IN (SELECT sCountid FROM Fn_ReturnRptFilterString(84,102,1)))
					AND
 						(A.Status = (CASE @Status WHEN 0 THEN A.Status ELSE 3 END) OR
 							A.Status IN (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))
					AND
						 A.CrNoteDate BETWEEN @FromDate AND @ToDate 
		 
    		IF LEN(@PurDBName) > 0
 		BEGIN
 			SET @SSQL = 'INSERT INTO #RptSupplierCreditNote ' +
 				'(' + @TblFields + ')' +
 				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
 				 +' WHERE (SpmId=  (CASE @SpmId WHEN 0 THEN SpmId ELSE 0 END ) OR
 					SpmId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))'
				 +' AND
					(A.CrNoteNumber=(CASE @CrNoteNumber WHEN ''0'' THEN A.CrNoteNumber ELSE '' END))OR
 						A.CrNoteNumber IN (SELECT iCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,102,@Pi_UsrId)))'
				 +' AND
 					(A.Status = (CASE @StatusID WHEN 0 THEN A.Status ELSE 0 END) OR
 						A.Status IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))'
				 +'AND
					 A.CrNoteDate BETWEEN @FromDate AND @ToDate '
				
 			EXEC (@SSQL)
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSupplierCreditNote'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
			END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		PRINT @Pi_DbName
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO #RptSupplierCreditNote ' +
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
			SET @Po_Errno = 1
			PRINT 'DataBase or Table not Found'
			RETURN
		END
	END
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptSupplierCreditNote
	PRINT 'Data Executed'
	SELECT * FROM #RptSupplierCreditNote

	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
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
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSupplierCreditNote_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptSupplierCreditNote_Excel]
		DELETE FROM RptExcelHeaders Where RptId=@Pi_RptId AND SlNo>10
		CREATE TABLE [RptSupplierCreditNote_Excel] (SpmId INT,SpmCode	NVARCHAR(50),SpmName NVARCHAR(50),
					CrNoteNo NVARCHAR(50),CrNoteDate DATETIME,Reason	NVARCHAR(50),CrAmount NUMERIC(38,2),
					CrAdjAmount	NUMERIC(38,2),BalanceAmount NUMERIC(38,2),Status NVARCHAR(50))
		SET @iCnt=11
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT TaxName FROM #RptSupplierCreditNote --ORDER BY CrNoteNumber 
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptSupplierCreditNote_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
				FETCH NEXT FROM Column_Cur INTO @Column
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		--Insert table values
		DELETE FROM [RptSupplierCreditNote_Excel]
		INSERT INTO [RptSupplierCreditNote_Excel](SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status)
		SELECT DISTINCT SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status FROM #RptSupplierCreditNote --WHERE UsrId=@Pi_UsrId
		--Select * from RptOUTPUTVATSummary_Excel
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT CrNoteNo,SpmId,TaxName,TaxAmt FROM #RptSupplierCreditNote
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @RefNo,@SpmId,@TaxPerc,@TaxableAmount
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSupplierCreditNote_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL+ ' WHERE CrNoteNo =''' + CAST(@RefNo AS VARCHAR(1000)) +''' AND  SpmId=' + CAST(@SpmId AS VARCHAR(1000))
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @RefNo,@SpmId,@TaxPerc,@TaxableAmount
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSupplierCreditNote_Excel]')
		OPEN NullCursor_Cura
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSupplierCreditNote_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
	END

RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Proc_QuantityFillRatio') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Proc_QuantityFillRatio
GO
--EXEC [Proc_QuantityFillRatio] 60,1,2
--Select * from TempOrderChange
CREATE PROCEDURE [dbo].[Proc_QuantityFillRatio]
(
	@Pi_RptId		INT,
	@Pi_UserId		INT,
	@Pi_TypeId		INT
)
AS
BEGIN

DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate	 	AS	DATETIME
/*********************************
* PROCEDURE: Proc_QuantityFillRatio
* PURPOSE: DISPLAY THE QTYFILL
* NOTES:
* CREATED: MAHALAKSHMI.A
* ON DATE: 15-12-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/

SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UserId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UserId)

SET NOCOUNT ON
--print @Pi_TypeId
print @FromDate


	DELETE FROM TempOrderChange WHERE RptId=@Pi_RptId AND UserId=@Pi_UserId
 IF @Pi_TypeId = 1 --LineFill
 BEGIN

 	INSERT INTO TempOrderChange (ORDERDATE,ORDERNO,CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,
		PRDNAME,RECEIVED,SERVICED,Type,CTGLEVELID,CTGMAINID,RtrClassId,RptId,UserId)
			SELECT DISTINCT C.ORDERDATE,C.ORDERNO,C.CMPID,C.SMID,C.RMID,C.RTRID,0 AS PRDID,F.SMNAME,D.RMNAME,E.RTRNAME,
			E.RTRCODE,'' AS PRDNAME,COUNT(DISTINCT B.PRDID) AS RECEIVED,COUNT(DISTINCT A.PRDID) AS SERVICED,1 as Type,RG.CTGLEVELID,
			RC.CTGMAINID,RV.RtrValueClassId AS RtrClassId,@Pi_RptId,@Pi_UserId
 			FROM SALESINVOICEPRODUCT A
				INNER JOIN SALESINVOICEORDERBOOKING H ON A.SalID = H.SalId AND A.PrdId=H.PrdId AND A.PrdBatId=H.PrdBatId
 				Right OUTER JOIN ORDERBOOKINGPRODUCTS B ON H.ORDERNO=B.ORDERNO 
 				Right JOIN ORDERBOOKING C ON B.ORDERNO=C.ORDERNO
 				INNER JOIN ROUTEMASTER  D ON C.RMID=D.RMID
 				INNER JOIN RETAILER E ON C.RTRID=E.RTRID
 				INNER JOIN SALESMAN F ON C.SMID=F.SMID
 				INNER JOIN RETAILERVALUECLASSMAP RV ON RV.RtrId=E.RtrId
 				INNER JOIN RETAILERVALUECLASS RC ON RC.RtrClassId=RV.RtrValueClassId
 				INNER JOIN RetailerCategory RG ON RG.CtgMainId=RC.CtgMainId
-- 				INNER JOIN PRODUCT G ON  B.PRDID=G.PRDID 
--				INNER JOIN PRODUCTBATCH I ON G.PRDID=I.PRDID AND A.PrdId=I.PrdId 
--				AND A.PrdBatId=I.PrdBatId AND B.PrdID=I.PrdID --AND B.PrdBatId=I.PrdBatId 
--				AND H.PrdID=I.PrdID AND H.PrdBatId=I.PrdBatId
				WHERE OrderDate BETWEEN @FromDate AND @ToDate		
 				GROUP BY C.ORDERDATE,C.ORDERNO,C.CMPID,C.SMID,C.RMID,C.RTRID,F.SMNAME,--ISNULL(B.PrdId,0),
				D.RMNAME,E.RTRNAME,E.RTRCODE,RG.CTGLEVELID,RC.CTGMAINID,RV.RtrValueClassId  
 END
 IF @Pi_TypeId = 2 --QtyFill
 BEGIN
 	INSERT INTO TempOrderChange (ORDERDATE,ORDERNO,CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,
		PRDNAME,RECEIVED,SERVICED,Type,CTGLEVELID,CTGMAINID,RtrClassId,RptId,UserId)
 	SELECT DISTINCT C.ORDERDATE,C.ORDERNO,G.CMPID,C.SMID,C.RMID,C.RTRID,B.PRDID,F.SMNAME,D.RMNAME,E.RTRNAME,
	E.RTRCODE,G.PRDNAME,B.TOTALQTY AS RECEIVED,ISNULL(A.BaseQty,0) AS SERVICED,2 as Type,RG.CTGLEVELID,
	RC.CTGMAINID,RV.RtrValueClassId AS RtrClassId,@Pi_RptId as RptID,@Pi_UserId as UserID
 		FROM SALESINVOICEPRODUCT A
		INNER JOIN SALESINVOICEORDERBOOKING H ON A.SalID = H.SalId
 		Right OUTER JOIN ORDERBOOKINGPRODUCTS B ON H.PRDID=B.PRDID
		AND H.ORDERNO=B.ORDERNO 
 		Right JOIN ORDERBOOKING C ON B.ORDERNO=C.ORDERNO
 		INNER JOIN ROUTEMASTER  D ON C.RMID=D.RMID
 		INNER JOIN RETAILER E ON C.RTRID=E.RTRID
 		INNER JOIN SALESMAN F ON C.SMID=F.SMID
 		INNER JOIN RETAILERVALUECLASSMAP RV ON RV.RtrId=E.RtrId
 		INNER JOIN RETAILERVALUECLASS RC ON RC.RtrClassId=RV.RtrValueClassId
 		INNER JOIN RetailerCategory RG ON RG.CtgMainId=RC.CtgMainId
 		INNER JOIN PRODUCT G ON  B.PRDID=G.PRDID 
		INNER JOIN PRODUCTBATCH I ON G.PRDID=I.PRDID AND A.PrdId=I.PrdId 
			AND A.PrdBatId=I.PrdBatId AND B.PrdID=I.PrdID --AND B.PrdBatId=I.PrdBatId 
			AND H.PrdID=I.PrdID AND H.PrdBatId=I.PrdBatId
		WHERE OrderDate BETWEEN @FromDate AND @ToDate		
		GROUP BY C.ORDERDATE,C.ORDERNO,G.CMPID,C.SMID,C.RMID,C.RTRID,B.PRDID,F.SMNAME,ISNULL(A.PrdId,0),
				D.RMNAME,E.RTRNAME,E.RTRCODE,G.PRDNAME,RG.CTGLEVELID,RC.CTGMAINID,RV.RtrValueClassId,A.BaseQty,RG.CTGLEVELID,B.TOTALQTY,G.CMPID
		
 END
END
GO
DELETE FROM RptFormula WHERE RptId=150 and slno IN(30,31,32,33,34,35)
INSERT INTO RptFormula
SELECT 150,30,'Disp_SplDisc','Spl Discount',1,0
UNION ALL
SELECT 150,	31,	'Disp_SchDisc',	'Sch Discount',	1,	0
UNION ALL
SELECT 150,	32,	'Disp_CDDisc',	'CD Discount',	1,	0
UNION ALL
SELECT 150,	33,	'Disp_DBDisc',	'DB Discount',	1,	0
UNION ALL
SELECT 150,	34,	'Disp_Tax',	'Tax Amount',	1,	0
UNION ALL
SELECT 150,	35,	'Hd_Total',	'Total',	1,	0
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' and NAME='Proc_DatewiseProductwiseSales')
DROP PROCEDURE Proc_DatewiseProductwiseSales
GO
-- Exec Proc_DatewiseProductwiseSales 150,'2008/01/01','2010/10/30',0,0,0,0,0,1
CREATE PROCEDURE [Proc_DatewiseProductwiseSales]
(	
	@Pi_RptId		INT,
	@Pi_FromDate		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_CmpId		INT,
	@Pi_CmpPrdCtgId		INT,
	@Pi_PrdId		INT,
	@Pi_LcnId		INT,
	@Pi_PrdBatId		INT,
	@Pi_UsrId		INT	
)
AS
/*************************************************************
* PROCEDURE		: Proc_DatewiseProductwiseSales
* PURPOSE		: To get the Datewise Productwise Sales Details
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 15/05/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN	

	DELETE FROM TempDatewiseProductwiseSales WHERE UsrId in (@Pi_UsrId,0,NULL)

	INSERT INTO TempDatewiseProductwiseSales(SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,CmpId,
	PrdCtgValMainId,CmpPrdCtgId,SellingRate,BaseQty,FreeQty,GrossAmount,SplDiscAmount,SchDiscAmount,DBDiscAmount,
	CDDiscAmount,TaxAmount,NetAmount,UsrId,DlvSts)		

	SELECT	SalId,SalInvDate,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,PrdCtgValMainId,
			CmpPrdCtgId,PrdUnitSelRate,BaseQty,FreeQty,PrdGrossAmountAftEdit AS Gross,
			PrdSplDiscAmount AS SplDisc,PrdSchDiscAmount AS SchDisc,PrdDBDiscAmount AS DBDisc,
			PrdCDAmount AS CDDIsc,PrdTaxAmount AS TAx,PrdNetAmount AS Net ,UserId,DlvSts
	FROM
	(
		SELECT	SI.SalId,SI.SalInvDate,SP.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,P.CmpId,P.PrdCtgValMainId,
				PV.CmpPrdCtgId,SP.PrdUnitSelRate,SP.BaseQty,SP.SalManFreeQty AS FreeQty,SP.PrdGrossAmountAftEdit,
				SP.PrdSplDiscAmount,SP.PrdSchDiscAmount,SP.PrdDBDiscAmount,SP.PrdCDAmount,SP.PrdTaxAmount,SP.PrdNetAmount,@Pi_UsrId AS UserId,SI.DlvSts
		FROM	SalesInvoice SI WITH (NOLOCK)
				INNER JOIN SalesInvoiceProduct SP WITH (NOLOCK) ON SI.SalId=SP.SalId
				INNER JOIN Product P WITH (NOLOCK) ON SP.PrdId=P.PrdID
				INNER JOIN ProductCategoryValue PV WITH (NOLOCK) ON P.PrdCtgValMainId=PV.PrdCtgValMainId
				INNER JOIN ProductBatch PB WITH (NOLOCK) ON P.PrdId=PB.PrdId AND SP.PrdId=PB.PrdID and SP.PrdBatId=PB.PrdBatID			
		WHERE 
			(
				P.CmpId = (CASE @Pi_CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
				P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
			)
			AND
			(
				SI.LcnId = (CASE @Pi_LcnId WHEN 0 THEN SI.LcnId Else 0 END) OR
				SI.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
			)
			AND
			(
				SP.PrdId = (CASE @Pi_CmpPrdCtgId WHEN 0 THEN SP.PrdId Else 0 END) OR
				SP.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
			)
			AND
			(
				SP.PrdId = (CASE @Pi_PrdId WHEN 0 THEN SP.PrdId Else 0 END) OR
				SP.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
			)
			AND
			(
				SP.PrdBatId = (CASE @Pi_PrdBatId WHEN 0 THEN SP.PrdBatId Else 0 END) OR
				SP.PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
			)
			AND SI.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate

		UNION
		
		SELECT  SI.SalId,SI.SalInvDate,SP.FreePrdId,P.PrdDCode,P.PrdName,SP.FreePrdBatId AS PrdBatId,PB.PrdBatCode,P.CmpId,P.PrdCtgValMainId,
				PV.CmpPrdCtgId,PBD.PrdBatDetailValue AS PrdUnitSelRate, 0 AS BaseQty,SP.FreeQty,0 AS Gross,0 AS SplDisc,0 AS SchDisc,0 AS DBDisc,
				0 AS CDDisc,0 AS Tax,0 AS Net,@Pi_UsrId  AS UserId,SI.DlvSts
		FROM	SalesInvoice SI WITH (NOLOCK)
				INNER JOIN SalesInvoiceSchemeDtFreePrd SP WITH (NOLOCK) ON SP.SalId=SI.SalId
				INNER JOIN Product P WITH (NOLOCK) ON SP.FreePrdId=P.PrdID
				INNER JOIN ProductCategoryValue PV WITH (NOLOCK) ON P.PrdCtgValMainId=PV.PrdCtgValMainId
				INNER JOIN ProductBatch PB WITH (NOLOCK) ON P.PrdId=PB.PrdId AND SP.FreePrdId=PB.PrdID and SP.FreePrdBatId=PB.PrdBatID
				INNER JOIN ProductBatchDetails PBD WITH (NOLOCK)ON PB.PrdBatId=PBD.PrdBatId AND PBD.PriceId=PB.DefaultPriceId
				INNER JOIN BatchCreation BC WITH (NOLOCK) ON PBD.SlNo =BC.SlNo AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1	
		WHERE 
			(
				P.CmpId = (CASE @Pi_CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
				P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
			)
			AND			
			(
				SI.LcnId = (CASE @Pi_LcnId WHEN 0 THEN SI.LcnId Else 0 END) OR
				SI.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
			)
			AND
			(
				SP.FreePrdId = (CASE @Pi_CmpPrdCtgId WHEN 0 THEN SP.FreePrdId Else 0 END) OR
				SP.FreePrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
			)
			AND
			(
				SP.FreePrdId = (CASE @Pi_PrdId WHEN 0 THEN SP.FreePrdId Else 0 END) OR
				SP.FreePrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
			)
			AND
			(	
				SP.FreePrdBatId = (CASE @Pi_PrdBatId WHEN 0 THEN SP.FreePrdBatId Else 0 END) OR
				SP.FreePrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
			)
			AND SI.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate

		UNION

		SELECT  SI.SalId,SI.SalInvDate,SP.GiftPrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,P.CmpId,P.PrdCtgValMainId,
			    PV.CmpPrdCtgId,PBD.PrdBatDetailValue AS PrdUnitSelRate, 0 AS BaseQty,SP.GiftQty,0 AS Gross,0 AS SplDisc,0 AS SchDisc,0 AS DBDisc,
			    0 AS CDDisc,0 AS Tax,0 AS Net,@Pi_UsrId  AS UserId,SI.DlvSts
		FROM	SalesInvoice SI WITH (NOLOCK)
				INNER JOIN SalesInvoiceSchemeDtFreePrd SP WITH (NOLOCK) ON SP.SalId=SI.SalId
				INNER JOIN Product P WITH (NOLOCK) ON SP.GiftPrdId=P.PrdID
				INNER JOIN ProductCategoryValue PV WITH (NOLOCK) ON P.PrdCtgValMainId=PV.PrdCtgValMainId
				INNER JOIN ProductBatch PB WITH (NOLOCK) ON P.PrdId=PB.PrdId AND SP.GiftPrdId=PB.PrdID and SP.GiftPrdBatId=PB.PrdBatID
				INNER JOIN ProductBatchDetails PBD WITH (NOLOCK)ON PB.PrdBatId=PBD.PrdBatId AND PBD.PriceId=PB.DefaultPriceId
				INNER JOIN BatchCreation BC WITH (NOLOCK) ON PBD.SlNo =BC.SlNo AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		WHERE 
			(
				P.CmpId = (CASE @Pi_CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
				P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
			)
			AND
			(
				SI.LcnId = (CASE @Pi_LcnId WHEN 0 THEN SI.LcnId Else 0 END) OR
				SI.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
			)
			AND
			(
				SP.GiftPrdId = (CASE @Pi_CmpPrdCtgId WHEN 0 THEN SP.GiftPrdId Else 0 END) OR
				SP.GiftPrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
			)
			AND
			(
				SP.GiftPrdId = (CASE @Pi_PrdId WHEN 0 THEN SP.GiftPrdId Else 0 END) OR
				SP.GiftPrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
			)
			AND
			(
				SP.GiftPrdBatId = (CASE @Pi_PrdBatId WHEN 0 THEN SP.GiftPrdBatId Else 0 END) OR
				SP.GiftPrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
			)
			AND SI.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	)	A
	ORDER BY SalId,SalInvDate,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpPrdCtgId,PrdCtgValMainId
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' and NAME='Proc_RptDatewiseProductwiseSales')
DROP PROCEDURE Proc_RptDatewiseProductwiseSales
GO
--EXEC Proc_RptDatewiseProductwiseSales 150,2,0,'CK20100206',0,0,1
CREATE PROCEDURE [Proc_RptDatewiseProductwiseSales]
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
BEGIN
SET NOCOUNT ON
/***************************************************
* PROCEDURE: Proc_RptDatewiseProductwiseSales
* PURPOSE: General Procedure
* NOTES:
* CREATED: Mahalakshmi.A	31-07-2008
* MODIFIED
* DATE          AUTHOR				DESCRIPTION
-----------------------------------------------------
* 07.08.2009    Panneerselvam.K		BugNo : 20207
*****************************************************/
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId			AS	INT
	DECLARE @LcnId			AS	INT
	DECLARE @PrdBatId		AS	INT
	DECLARE @PrdId			AS	INT
	DECLARE @CmpPrdCtgId		AS	INT
	DECLARE @CancelStatus		AS	INT
	DECLARE @ExcelFlag		AS	INT

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @PrdBatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @CancelStatus = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId

	SET @CmpPrdCtgId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))

	CREATE     TABLE #RptDatewiseProductwiseSales
	(
		SalId				INT,
		SalInvDate			DATETIME,
		PrdId				INT,
		PrdCode				NVARCHAR(50),
		PrdName				NVARCHAR(200),
		PrdBatId			INT,
		PrdBatCode			NVARCHAR(50),
		SellingRate			NUMERIC (38,6),
		BaseQty				INT,
		FreeQty				INT,
		GrossAmount			NUMERIC (38,6),
		SplDiscAmount		NUMERIC (38,6),
		SchDiscAmount		NUMERIC (38,6),
		DBDiscAmount		NUMERIC (38,6),
		CDDiscAmount		NUMERIC (38,6),
		TaxAmount			NUMERIC (38,6),
		NetAmount			NUMERIC(38,6)		
	)

	SET @TblName = 'RptDatewiseProductwiseSales'
		SET @TblStruct = 'SalId			INT,
		SalInvDate		DATETIME,
		PrdId			INT,
		PrdCode			NVARCHAR(50),
		PrdName			NVARCHAR(200),
		PrdBatId			INT,
		PrdBatCode		NVARCHAR(50),
		SellingRate		NUMERIC (38,6),
		BaseQty			INT,
		FreeQty			INT,
		GrossAmount		NUMERIC (38,6),
		SplDiscAmount		NUMERIC (38,6),
		SchDiscAmount		NUMERIC (38,6),
		DBDiscAmount		NUMERIC (38,6),
		CDDiscAmount		NUMERIC (38,6),
		TaxAmount		NUMERIC (38,6),
		NetAmount		NUMERIC(38,6)'

	SET @TblFields = 'SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,BaseQty,FreeQty,
					  GrossAmount,SplDiscAmount,SchDiscAmount,DBDiscAmount,CDDiscAmount,TaxAmount,NetAmount'

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

	--SET @Po_Errno = 0
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		EXEC Proc_DatewiseProductwiseSales @Pi_RptId,@FromDate,@ToDate,@CmpId,@CmpPrdCtgId,@PrdId,@LcnId,@PrdBatId,@Pi_UsrId
		
		IF @CancelStatus=1 	--'NO'
		BEGIN	
			INSERT INTO #RptDatewiseProductwiseSales (SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,
			BaseQty,FreeQty,GrossAmount,SplDiscAmount,SchDiscAmount,DBDiscAmount,CDDiscAmount,TaxAmount,NetAmount)			
			SELECT 0 AS SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,SUM(BaseQty),SUM(FreeQty),
			SUM(GrossAmount),SUM(SplDiscAmount),SUM(SchDiscAmount),SUM(DBDiscAmount),SUM(CDDiscAmount),SUM(TaxAmount),SUM(NetAmount)
			FROM TempDatewiseProductwiseSales
			WHERE DlvSts NOT IN(3)						
			GROUP BY SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate
		END
		ELSE
		BEGIN	
			INSERT INTO #RptDatewiseProductwiseSales (SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,
			BaseQty,FreeQty,GrossAmount,SplDiscAmount,SchDiscAmount,DBDiscAmount,CDDiscAmount,TaxAmount,NetAmount)			
			SELECT 0 AS SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,SUM(BaseQty),SUM(FreeQty),
			SUM(GrossAmount),SUM(SplDiscAmount),SUM(SchDiscAmount),SUM(DBDiscAmount),SUM(CDDiscAmount),SUM(TaxAmount),SUM(NetAmount)
			FROM TempDatewiseProductwiseSales			
			GROUP BY SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate
		END
		
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptDatewiseProductwiseSales ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
				' CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
				+ ' PrdId = (CASE ' + CAST(@CmpPrdCtgId AS nVarchar(10)) + ' WHEN 0 THEN PrdId ELSE 0 END) OR ' +
				' PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '
				+ 'AND PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId ELSE 0 END) OR ' +
				'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND SalInvDate BETWEEN @FromDate AND @ToDate'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptDatewiseProductwiseSales'
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
			SET @SSQL = 'INSERT INTO #RptDatewiseProductwiseSales ' +
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

	DELETE FROM RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptDatewiseProductwiseSales
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptDatewiseProductwiseSales_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptDatewiseProductwiseSales_Excel
		SELECT  * INTO RptDatewiseProductwiseSales_Excel FROM #RptDatewiseProductwiseSales 
	END 
	SELECT * FROM #RptDatewiseProductwiseSales 

	RETURN
END
GO
Delete from RptDetails where TblName='Company' and Rptid=171
Delete from RptDetails where TblName='JCMast'  and Rptid=171  
Delete from RptDetails where TblName='JCMonth' and Rptid=171 
GO
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (171,1,'Company',-1,'','CmpId,CmpCode,CmpName','Company*...',NULL,1,NULL,4,1,1,'Press F4/Double Click to select Company',0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (171,2,'JCMast',-1,'','JcmId,JcmYr,JcmYr','JC Year*...','',1,NULL,12,1,1,'Press F4/Double Click to select JC Year',0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (171,3,'JCMonth',2,'JcmId','JcmJc,JcmSdt,JcmSdt','From JC Month*...','JcMast',1,'JcmId',13,1,1,'Press F4/Double Click to select From JC Month',0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (171,4,'JCMonth',2,'JcmId','JcmJc,JcmEdt,JcmEdt','To JC Month*...','JcMast',1,'JcmId',20,1,1,'Press F4/Double Click to select To JC Month',0)
GO
DELETE FROM RptExcelHeaders WHERE RptId=211 
INSERT INTO RptExcelHeaders
SELECT 211,1,'Code','Code',1,1
UNION
SELECT 211,2,'Name','Name',1,1
UNION
SELECT 211,3,'Unit','Unit',0,1
UNION
SELECT 211,4,'SalesValue','Sales Value',1,1
UNION
SELECT 211,5,'EC','Effective Coverage',1,1
UNION
SELECT 211,6,'TLS','Total Lines Sold',1,1
GO
Delete from RptHeader where RptId in (166,209,211,171)

----*******ADD RptId-211,171*******---------
Insert Into RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds) 
values ('EFFECTIVECOVERAGEANALYSISREPORT','Effective Coverage Analysis Report',211,
'Effective Coverage Analysis Report','Proc_RptECAnalysisReport','RptECAnalysisReport','RptECAnalysisRouteReport.rpt','')

Insert Into RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds) 
Values ('RetailerWiseValueReport','Retailer Wise Value Report',171,'Retailer Wise Value Report',	
'Proc_RptRetailerWiseValueReport','RptRetailerWiseValueReport','RptRetailerWiseValueReport.rpt','')
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Fn_ReturnFiltersValue') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].Fn_ReturnFiltersValue
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
	IF @Pi_ScreenId = 217 OR @Pi_ScreenId = 241 OR @Pi_ScreenId = 260 OR @Pi_ScreenId =  261 OR @Pi_ScreenId =  262 OR @Pi_ScreenId = 246
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CS2CNPurchaseOrder')
DROP PROCEDURE Proc_CS2CNPurchaseOrder
GO
CREATE        PROCEDURE [dbo].[Proc_CS2CNPurchaseOrder]  
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
 P.PrdDCode,(PD.OrdQty*UG.ConversionFactor) AS Quantity,  
 (CASE PM.DownLoad WHEN 0 THEN 'Manual' ELSE 'Automatic' END ) AS POType,  
 (CASE PM.DownLoad WHEN 0 THEN PM.PurOrderExpiryDate ELSE '' END ) AS POExpiryDate,  
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
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Proc_Cn2Cs_BLSchemeAttributes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Proc_Cn2Cs_BLSchemeAttributes
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeAttributes 0
--SELECT * FROM ErrorLog
SELECT * FROM SchemeRetAttr WHERE SchId=50 AND AttrType=6
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeAttributes]
(
@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeAttributes
* PURPOSE: To Insert and Update Scheme Attributes
* CREATED: Boopathy.P on 02/01/2009
*********************************/
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
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'PRODUCT'
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
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Proc_ReturnSchemeApplicable') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Proc_ReturnSchemeApplicable
GO
CREATE    Procedure [dbo].[Proc_ReturnSchemeApplicable]
(
	@Pi_SrpId		INT,
	@Pi_RmId		INT,
	@Pi_RtrId		INT,
	@Pi_BillType		INT,
	@Pi_BillMode		INT,
	@Pi_SchId  		INT,
	@Po_Applicable 		INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ReturnSchemeApplicable
* PURPOSE		: To Return whether the Scheme is applicable for the Retailer or Not
* CREATED		: Thrinath
* CREATED DATE	: 12/04/2007
* NOTE			: General SP for Returning the whether the Scheme is applicable for the Retailer or Not
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @RetDet TABLE
	(
		RtrId 				INT,
		RtrValueClassId		INT,
		CtgMainId			INT,
		CtgLinkId           INT,
		CtgLevelId			INT,
		RtrPotentialClassId	INT,
		RtrKeyAcc			INT,
		VillageId			INT,
		CtgLinkCode         NVARCHAR(100)
	)
	DECLARE @RMDet TABLE
	(
		RMId				INT,
		RMVanRoute			INT,
		RMSRouteType		INT,
		RMLocalUpcountry	INT
	)
	DECLARE @VillageDet TABLE
	(
		VillageId			INT,
		RoadCondition		INT,
		Incomelevel			INT,
		Acceptability		INT,
		Awareness			INT
	)
	DECLARE @SchemeRetAttr TABLE
	(
		AttrType			INT,
		AttrId				INT
	)
	DECLARE @AttrType 				INT
	DECLARE	@AttrId					INT
	DECLARE @Applicable_SM			INT
	DECLARE @Applicable_RM			INT
	DECLARE @Applicable_Vill		INT
	DECLARE @Applicable_RtrLvl		INT
	DECLARE @Applicable_RtrVal		INT
	DECLARE @Applicable_VC			INT
	DECLARE @Applicable_PC			INT
	DECLARE @Applicable_Rtr			INT
	DECLARE @Applicable_BT			INT
	DECLARE @Applicable_BM			INT
	DECLARE @Applicable_RT			INT
	DECLARE @Applicable_CT			INT
	DECLARE @Applicable_VRC			INT
	DECLARE @Applicable_VI			INT
	DECLARE @Applicable_VA			INT
	DECLARE @Applicable_VAw			INT
	DECLARE @Applicable_RouteType	INT
	DECLARE @Applicable_LocUpC		INT
	DECLARE @Applicable_VanRoute	INT
	DECLARE @Applicable_Cluster		INT
	SET @Applicable_SM=0
	SET @Applicable_RM=0
	SET @Applicable_Vill=0
	SET @Applicable_RtrLvl=1
	SET @Applicable_RtrVal=0
	SET @Applicable_VC=0
	SET @Applicable_PC=0
	SET @Applicable_Rtr=0
	SET @Applicable_BT=0
	SET @Applicable_BM=0
	SET @Applicable_RT=0
	SET @Applicable_CT=0
	SET @Applicable_VRC=0
	SET @Applicable_VI=0
	SET @Applicable_VA=0
	SET @Applicable_VAw=0
	SET @Applicable_RouteType=0
	SET @Applicable_LocUpC=0
	SET @Applicable_VanRoute=0	
	SET @Applicable_Cluster=0
	SET @Po_Applicable = 1
	INSERT INTO @RetDet(RtrId,RtrValueClassId,CtgMainId,CtgLinkId,CtgLevelId,RtrPotentialClassId,RtrKeyAcc,VillageId,CtgLinkCode)
	SELECT R.RtrId,RVCM.RtrValueClassId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId,
		ISNULL(RPCM.RtrPotentialClassId,0) AS RtrPotentialClassId,R.RtrKeyAcc,R.VillageId,RC.CtgLinkCode
		FROM Retailer  R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
		LEFT OUTER JOIN RetailerPotentialClassmap RPCM on R.RtrId = RPCM.RtrId
		LEFT OUTER JOIN RetailerPotentialClass [RPC] on RPCM.RtrPotentialClassId = [RPC].RtrClassId
	
	INSERT INTO @RMDet(RMId,RMVanRoute,RMSRouteType,RMLocalUpcountry)
	SELECT  RMId,RMVanRoute,RMSRouteType,RMLocalUpcountry
		FROM RouteMaster RM WHERE RM.RMId = @Pi_RmId

	INSERT INTO @VillageDet(VillageId,RoadCondition,Incomelevel,Acceptability,Awareness)
	SELECT  A.VillageId,ISNULL(RoadCondition,0),ISNULL(Incomelevel,0),ISNULL(Acceptability,0),
		ISNULL(Awareness,0) FROM @RetDet A  LEFT OUTER JOIN Routevillage RV
		ON A.VillageId = RV.VillageId

	INSERT INTO @SchemeRetAttr (AttrType,AttrId)
	SELECT AttrType,AttrId FROM SchemeRetAttr  WHERE SchId = @Pi_SchId AND AttrId > 0 ORDER BY AttrType
	
	IF NOT EXISTS(SELECT AttrId FROM SchemeRetAttr WHERE SchId = @Pi_SchId AND AttrType=3)
	BEGIN
		SET @Applicable_Vill=1
	END
	IF NOT EXISTS(SELECT AttrId FROM SchemeRetAttr WHERE SchId = @Pi_SchId AND AttrType=7)
	BEGIN
		SET @Applicable_PC=1
	END
	DECLARE  CurSch1 CURSOR FOR
	SELECT DISTINCT AttrType FROM SchemeRetAttr WHERE AttrId=0 AND SchId = @Pi_SchId ORDER BY AttrType
		OPEN CurSch1
		FETCH NEXT FROM CurSch1 INTO @AttrType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AttrType = 1
			SET @Applicable_SM=1
		ELSE IF @AttrType =2
			SET @Applicable_RM=1
		ELSE IF @AttrType =3
			SET @Applicable_Vill=1
		ELSE IF @AttrType =4
			SET @Applicable_RtrLvl=1
		ELSE IF @AttrType =5
			SET @Applicable_RtrVal=1
		ELSE IF @AttrType =6
			SET @Applicable_VC=1
		ELSE IF @AttrType =7
			SET @Applicable_PC=1
		ELSE IF @AttrType =8
			SET @Applicable_Rtr=1
		ELSE IF @AttrType =10
			SET @Applicable_BT=1
		ELSE IF @AttrType =11
			SET @Applicable_BM=1
		ELSE IF @AttrType =12
			SET @Applicable_RT=1
		ELSE IF @AttrType =13
			SET @Applicable_CT=1
		ELSE IF @AttrType =14
			SET @Applicable_VRC=1
		ELSE IF @AttrType =15
			SET @Applicable_VI=1
		ELSE IF @AttrType =16
			SET @Applicable_VA=1
		ELSE IF @AttrType =17
			SET @Applicable_VAw=1
		ELSE IF @AttrType =18
			SET @Applicable_RouteType=1
		ELSE IF @AttrType =19
			SET @Applicable_LocUpC=1
		ELSE IF @AttrType =20
			SET @Applicable_VanRoute=1		
		ELSE IF @AttrType =21
			SET @Applicable_Cluster=1
		FETCH NEXT FROM CurSch1 INTO @AttrType
	END
	CLOSE CurSch1
	DEALLOCATE CurSch1
	
	DECLARE  CurSch CURSOR FOR
	SELECT AttrType,AttrId FROM @SchemeRetAttr ORDER BY AttrType
		OPEN CurSch
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AttrType = 1 AND @Applicable_SM=0		--SalesMan
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_SrpId)
				SET @Applicable_SM = 1
		END
		IF @AttrType = 2 AND @Applicable_RM=0		--Route
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RmId)
				SET @Applicable_RM = 1
		END
		IF @AttrType = 3 AND @Applicable_Vill=0		--Village
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.VillageId AND A.AttrType = @AttrType)
				SET @Applicable_Vill = 1
		END
--		IF @AttrType = 4 AND @Applicable_RtrLvl=0		--Retailer Category Level
--		BEGIN
--			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
--						ON A.AttrId = B.CtgLevelId  AND A.AttrType = @AttrType)
--				SET @Applicable_RtrLvl = 1
--		END
		IF @AttrType = 5 AND @Applicable_RtrVal=0		--Retailer Category Level Value
		BEGIN
			IF (SELECT COUNT(A.AttrId) FROM @SchemeRetAttr A WHERE A.AttrType = 4)=1
			BEGIN
				IF EXISTS(SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN RetailerCategoryLevel B
							ON A.AttrId = B.CtgLevelId  AND A.AttrType = 4 AND LevelName='Level1')
				BEGIN
					IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.CtgLinkId AND A.AttrType = @AttrType)
							SET @Applicable_RtrVal = 1			
				END
				ELSE
				BEGIN
					IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
								ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
					BEGIN
						SET @Applicable_RtrVal = 1
					END
				END
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
								ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
				BEGIN
					SET @Applicable_RtrVal = 1
				END
			END
		END
		IF @AttrType = 6 AND @Applicable_VC=0		--Retailer Class Value
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.RtrValueClassId AND A.AttrType = @AttrType)
				SET @Applicable_VC = 1
		END
--		IF @AttrType = 7 AND @Applicable_PC=0		--Retailer Potential Class
--		BEGIN
--			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A LEFT JOIN @RetDet B
--						ON A.AttrId = B.RtrPotentialClassId AND A.AttrType = @AttrType)
--				SET @Applicable_PC = 1
--		END
		IF @AttrType = 8 AND @Applicable_Rtr=0		--Retailer
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RtrId)
			BEGIN
				SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RtrId
				SET @Applicable_Rtr = 1
			END
		END
		IF @AttrType = 10 AND @Applicable_BT=0		--Bill Type
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_BillType)
				SET @Applicable_BT = 1
		END
		IF @AttrType = 11 AND @Applicable_BM=0		--Bill Mode
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_BillMode)
				SET @Applicable_BM = 1
		END
		IF @AttrType = 12 AND @Applicable_RT=0		--Retailer Type
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.RtrKeyAcc AND A.AttrType = @AttrType)
				SET @Applicable_RT = 1
		END
		IF @AttrType = 13 AND @Applicable_CT=0		--Class Type
		BEGIN
			IF EXISTS (SELECT B.RtrPotentialClassId FROM @RetDet B WHERE B.RtrPotentialClassId > 0 )
				SET @Applicable_CT = 1
		END
		IF @AttrType = 14 AND @Applicable_VRC=0		--Village Road Condition
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.RoadCondition AND A.AttrType = @AttrType)
				SET @Applicable_VRC = 1
		END
		IF @AttrType = 15 AND @Applicable_VI=0		--Village Income Level
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Incomelevel AND A.AttrType = @AttrType)
				SET @Applicable_VI = 1
		END
		IF @AttrType = 16 AND @Applicable_VA=0		--Village Acceptability
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Acceptability AND A.AttrType = @AttrType)
				SET @Applicable_VA = 1
		END
		IF @AttrType = 17 AND @Applicable_VAw=0		--Village Awareness
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Awareness AND A.AttrType = @AttrType)
				SET @Applicable_VAw = 1
		END
		IF @AttrType = 18 AND @Applicable_RouteType=0		--Route Type
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMSRouteType AND A.AttrType = @AttrType)
				SET @Applicable_RouteType = 1
		END
		IF @AttrType = 19 AND @Applicable_LocUpC=0		--Local / UpCountry
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMLocalUpcountry AND A.AttrType = @AttrType)
				SET @Applicable_LocUpC = 1
		END
		IF @AttrType = 20 AND @Applicable_VanRoute=0		--Van / NonVan Route
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMVanRoute AND A.AttrType = @AttrType)
				SET @Applicable_VanRoute = 1
		END
		IF @AttrType = 21 AND @Applicable_Cluster=0		--Cluster
		BEGIN			
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId IN(SELECT DISTINCT ClusterId FROM ClusterAssign WHERE MasterId=79 AND MAsterRecordId=@Pi_RtrId AND Status=1))
				SET @Applicable_Cluster = 1
		END
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	END
	CLOSE CurSch
	DEALLOCATE CurSch
--
	PRINT @Applicable_SM
	PRINT @Applicable_RM
	PRINT @Applicable_Vill
	PRINT @Applicable_RtrLvl
	PRINT @Applicable_RtrVal
	PRINT @Applicable_VC
	PRINT @Applicable_PC
	PRINT @Applicable_Rtr
	PRINT @Applicable_BT
	PRINT @Applicable_BM
	PRINT @Applicable_RT
	PRINT @Applicable_CT
	PRINT @Applicable_VRC
	PRINT @Applicable_VI
	PRINT @Applicable_VA
	PRINT @Applicable_VAw
	PRINT @Applicable_RouteType
	PRINT @Applicable_LocUpC
	PRINT @Applicable_VanRoute
	PRINT @Applicable_Cluster
	IF @Applicable_SM=1 AND @Applicable_RM=1 AND @Applicable_Vill=1 AND --@Applicable_RtrLvl=1 AND
	@Applicable_RtrVal=1 AND @Applicable_VC=1 AND @Applicable_PC=1 AND @Applicable_Rtr = 1 AND
	@Applicable_BT=1 AND @Applicable_BM=1 AND @Applicable_RT=1 AND @Applicable_CT=1 AND
	@Applicable_VRC=1 AND @Applicable_VI=1 AND @Applicable_VA=1 AND @Applicable_VAw=1 AND
	@Applicable_RouteType=1 AND @Applicable_LocUpC=1 AND @Applicable_VanRoute=1 AND @Applicable_Cluster=1
	BEGIN
		SET @Po_Applicable=1
	END
	ELSE
	BEGIN
		SET @Po_Applicable=0
	END
	--->Added By Nanda on 08/10/2010 for FBM Validations
	IF @Po_Applicable=1
	BEGIN
		IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId=@Pi_SchId AND FBM=1)
		BEGIN
			IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId=@Pi_SchId AND Budget>0)
			BEGIN
				SET @Po_Applicable=1
			END
			ELSE
			BEGIN
				SET @Po_Applicable=0
			END
		END
	END
	--->Till Here
	--PRINT @Po_Applicable
	RETURN
END
GO

if not exists (select * from hotfixlog where fixid = 384)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(384,'D','2011-09-02',getdate(),1,'Core Stocky Service Pack 384')
GO
